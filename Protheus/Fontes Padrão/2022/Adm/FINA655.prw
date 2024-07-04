#INCLUDE "FINA655.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/*/{Protheus.doc} FINA655
Sincronização do cadastro de Centro de Custo do Protheus no Reserve executado via rotina CTBA030.

@author Totvs
@since 31/08/2013
@version P11 R9
@return Nil
/*/
Function FINA655(nOpc,aAprovCC)
Local cTipoInteg	:= SuperGetMV("MV_RESEXP",.F.,"0")
Local nOpcAux		:= 0

Default nOpc		:= 0
Default aAprovCC	:= {}

nOpcAux := nOpc

If FINA655Vld(@nOpcAux) //Valida se o registro precisa ser sincronizado

	If FINA655Atu(nOpcAux,CTT->CTT_RESERV) //Atualiza registro como pendente

		If cTipoInteg $ "1|3"

			MsgRun(STR0001,STR0002,{|| FINA655Man(nOpcAux,aAprovCC)}) //"Integrando com o Sistema Reserve"###"Integração Reserve"

		EndIf

	EndIf

EndIf

Return

/*/{Protheus.doc} FINA655Man
Sincroniza o cadastro de Centro de Custo do Protheus no Reserve.

@author Totvs
@since 31/08/2013
@version P11 R9

@param nOpc, numérico, Processo executado (3=Inclusão,4=Alteracao,5=Exclusao)

@return Nil
/*/
Function FINA655Man(nOpcAux,aAprovCC)
Local aSaveArea	:= GetArea()
Local oCC			:= Nil
Local cSessao		:= ""
Local oSvc			:= Nil

Default nOpcAux	:= 0
Default aAprovCC	:= {}

If FINXRESOSe(@cSessao,@oSvc,"CTT",CTT->CTT_CUSTO) //Abre sessão

	oCC := WSCentrosCusto():New() //Cria objeto para envio

	FINA655Car(@oCC,cSessao,nOpcAux,CTT->CTT_CUSTO,CTT->CTT_DESC01,aAprovCC) //Carrega os dados no objeto

	If FINA655Env(@oCC,nOpcAux,CTT->CTT_CUSTO) //Envia os dados ao Sistema Reserve

		If nOpcAux == 5
			FINA655Atu(6) //Limpa o flag de controle
		Else
			FINA655Atu() //Marca registro como enviado
		EndIf

	EndIf

	FINXRESCSe(@cSessao,@oSvc) //Encerra sessão

EndIf

RestArea(aSaveArea)

Return

/*/{Protheus.doc} FINA655Job
Sincroniza o cadastro de Centro de Custo do Protheus no Reserve via Schedule.

@author Totvs
@since 31/08/2013
@version P11 R9

@return Nil
/*/
Function FINA655Job()
Local aSaveArea	:= GetArea()
Local cTipoInteg	:= SuperGetMV("MV_RESEXP",.F.,"0")
Local lExpCCusto	:= SubStr(SuperGetMV("MV_RESCAD",.F.,"111"),1,1) == "1"	//Verifica se a exportacao do centro de custo esta habilitada
Local cAliasCTT	:= ""
Local oCC			:= Nil
Local cSessao		:= ""
Local oSvc			:= Nil
Local lFA655ICC	:= ExistBlock("FA655ICC")
Local aArrayPE		:= {}
Local nX			:= 0
Local aCentroCli	:= {}
Local nOpc			:= 0
Local lCCliente	:= .F.
Local aAprovCC		:= {}

If lExpCCusto .And. cTipoInteg $ "2|3"

	//-----------------------------------------------------------------------------------------
	// Identifica a pendencia de inclusao do centro de custo que identifica rateio com cliente
	//-----------------------------------------------------------------------------------------
	aCentroCli := StrToKarr(SuperGetMv("MV_RESCTT",,""),";")
	If Fina655VlP(aCentroCli) //Valida se o parametro MV_RESCTT foi preenchido corretamente
		lCCliente := aCentroCli[3] == "0"
	EndIf

	//----------------------------------------------------------------------------
	// Identifica a pendencia de inclusao do centro de custo via ponto de entrada
	//----------------------------------------------------------------------------
	If lFA655ICC	
		aArrayPE := ExecBlock("FA655ICC",.F.,.F.) //Obtém o dados para integração
		If ValType(aArrayPE) != "A" .Or. Empty(aArrayPE)
			lFA655ICC := .F.
		EndIf
	EndIf

	If FINA655Qry(@cAliasCTT) .Or. lCCliente .Or. lFA655ICC

		If FINXRESOSe(@cSessao,@oSvc,"CTT",(cAliasCTT)->CTT_CUSTO) //Abre sessão no Sistema Reserve

			oCC := WSCentrosCusto():New()

			//-----------------------------------------------
			// Sincronizacao do cadastro de Centros de Custo
			//-----------------------------------------------
			While (cAliasCTT)->(!Eof())

				nOpc := FINA655Opc(cAliasCTT) //Identifica a operacao

				aAprovCC := Fina655Apr((cAliasCTT)->CTT_CUSTO)

				FINA655Car(@oCC,cSessao,nOpc,(cAliasCTT)->CTT_CUSTO,(cAliasCTT)->CTT_DESC01,aAprovCC) //Carrega os dados no objeto

				If FINA655Env(@oCC,nOpc,(cAliasCTT)->CTT_CUSTO) //Envia os dados ao Sistema Reserve

					CTT->(DbGoTo((cAliasCTT)->R_E_C_N_O_))
					If nOpc == 5
						FINA655Atu(6) //Limpa o campo de envio
					Else
						FINA655Atu(0) //Marca o registro como sincronizado
					EndIf

				EndIf

			(cAliasCTT)->(DbSkip())
			EndDo

			//--------------------------------------------------------
			// Inclusao do "Centro de Custo" para indentificar quando  
			// o valor da despesa será rateada com o cliente
			//--------------------------------------------------------
			If lCCliente

				FINA655Car(@oCC,cSessao,3,aCentroCli[1],aCentroCli[2]) //Carrega os dados no objeto

				If FINA655Env(@oCC,3,aCentroCli[1]) //Envia os dados ao Sistema Reserve

					PutMv("MV_RESCTT",aCentroCli[1]+";"+aCentroCli[2]+";1")

				EndIf

			EndIf

			//-----------------------------------------------------
			// Executa ponto de entrada para gravação complementar
			//-----------------------------------------------------
			If lFA655ICC
				//----------------------------------------------------------------------------------------
				// aArrayPE[1]		- númerico		- Operação desejada (3-Inclusão/4-Alteracao/5-Exclusao)
				// aArrayPE[2]		- caractere	- Código do centro de custo
				// aArrayPE[3]		- caractere	- Descrição do centro de custo
				// aArrayPE[4]		- array		- ID Reserve dos aprovadores
				// aArrayPE[4][nX]	- numerico		- ID Reserve do aprovador
				// aArrayPE[5]		- lógico		- Controle de sucesso na sincronização
				//----------------------------------------------------------------------------------------

				For nX := 1 To Len(aArrayPE)

					nOpc := aArrayPE[nX][1]

					FINA655Car(@oCC,cSessao,nOpc,aArrayPE[nX][2],aArrayPE[nX][3],aArrayPE[nX][4]) //Carrega os dados no objeto

					Aadd(aArrayPE[nX],FINA655Env(@oCC,nOpc,aArrayPE[nX][2])) //Envia os dados ao Sistema Reserve

				Next nX

				ExecBlock("FA655ICC",.F.,.F.,aArrayPE) //Retorna o resultado da integração

			EndIf

			FINXRESCSe(@cSessao,@oSvc) //Encerra sessão

		EndIf

	EndIf

	If !Empty(cAliasCTT) .And. Select(cAliasCTT) > 0
		(cAliasCTT)->(DbCloseArea())
	EndIf

EndIf 

RestArea(aSaveArea)

Return

/*/{Protheus.doc} FINA655Qry
Executa query para obtenção dos Centros de Custo pendentes de sincronização no Sistema Reserve.

@author Totvs
@since 31/08/2013
@version P11 R9

@param cAliasCTT, caractere, Alias da tabela temporária

@return lógico,Indica se a tabela possui dados
/*/
Function FINA655Qry(cAliasCTT)
Local lRet := .T.

cAliasCTT := GetNextAlias()

BeginSQL Alias cAliasCTT
SELECT	CTT.CTT_FILIAL,CTT.CTT_CUSTO,CTT.CTT_DESC01,CTT.CTT_BLOQ,CTT.CTT_RESERV,CTT_INTRES,CTT.D_E_L_E_T_,CTT.R_E_C_N_O_
FROM	%Table:CTT% CTT
WHERE	CTT.CTT_FILIAL = %XFilial:CTT%
		AND CTT.CTT_RESERV <> '4'
		AND (CTT.CTT_CLASSE <> '1' OR CTT.CTT_RESERV = '3')
		AND (CTT.CTT_BLOQ <> '1' OR CTT.CTT_RESERV = '3')
		AND (CTT.%NotDel% OR CTT.CTT_RESERV = '3')
		AND CTT.CTT_INTRES = '1'
ORDER BY CTT.CTT_RESERV
EndSQL

lRet := (cAliasCTT)->(!Eof())

Return lRet

/*/{Protheus.doc} FINA655Vld
Valida se o registro de Centro de Custo precisa ser sincronizado no Sistema Reserve

@author Totvs
@since 31/08/2013
@version P11 R9

@param nOpcAux, numérico, Opção do processo (3=Inclusão,4=Alteração,5=Exclusão)

@return lógico,Indica se o registro precisa ser sincronizado
/*/
Function FINA655Vld(nOpcAux)
Local lRet		:= .T.

Default nOpcAux	:= 0

//--------------------------------------------------
// Tratamento para Centros Sinteticos ou Bloqueados
//--------------------------------------------------
If CTT->CTT_CLASSE == "1" .Or. CTT->CTT_BLOQ == "1"

	If Empty(CTT->CTT_RESERV) //Se nunca enviado não realiza os demais processos
		lRet := .F.

	ElseIf CTT->CTT_RESERV == "1" //Se pendente de envio, altera para flag vazio
		FINA655Atu(6)
		lRet := .F.

	ElseIf CTT->CTT_RESERV $ "2|4" //Se pendente de alteracao ou sincronizado, altera para flag pendente de exclusao
		nOpcAux := 5

	EndIf

EndIf

If lRet .And. nOpcAux == 4
	If Empty(CTT->CTT_RESERV) .Or. CTT->CTT_RESERV == "1" //Caso o centro nunca foi enviado ou esta pendente de envio altera para opcao de inclusao
		nOpcAux := 3
	EndIf
EndIf

If lRet .And. nOpcAux == 5 
	If Empty(CTT->CTT_RESERV) //Desconsidera a exclusao de Centros Exclusos que nunca foram enviados
		lRet := .F.
	ElseIf CTT->CTT_RESERV == "1" //Se o centro está pendente de envio, limpa o flag para não ficar pendente de exclusao
		lRet := .F.
		FINA655Atu(6)
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} FINA655Car
Carrega no objeto os dados para sincronização do registro de Centro de Custo
 
@author Totvs
@since 31/08/2013
@version P11 R9
 
@param oCC, objeto, Objeto de envio de dados via XML
@param cSessao, caractere, Sessao aberta no Sistema Reserve
@param nOpc, numérico, Opção do processo (3=Inclusão,4=Alteração,5=Exclusão)
@param cCCusto, caractere, Código do registro de Centro de Custo
@param cDescCusto, caractere, Descrição do registro de Centro de Custo

@return Nil
/*/
Function FINA655Car(oCC,cSessao,nOpc,cCCusto,cDescCusto,aAprovCC)
Local oAddCCusto		:= Nil
Local cCodBKO			:= BKO2AGE(cEmpAnt+cFilAnt)
Local cGrupo			:= BKO2GruCC(cEmpAnt+cFilAnt)
Local nX				:= 0

Default oCC			:= Nil
Default cSessao		:= ""
Default nOpc		:= 0
Default cCCusto		:= ""
Default cDescCusto	:= "" 
Default aAprovCC		:= {}

If nOpc == 3 .Or. nOpc == 4 //Inclusao ou Alteracao
	oCC:OWSINSERIRCENTROSCUSTORQ:CSESSAO			:= cSessao
	oCC:OWSINSERIRCENTROSCUSTORQ:OWSCENTROSCUSTO	:= CentrosCusto_ArrayOfCentroCusto():New()

	oAddCCusto := CentrosCusto_CentroCusto():NEW() //Instancia objeto para incremento de dados a enviar
    if Empty(cGrupo)
		oAddCCusto:cCODBKO	:= AllTrim(cCodBKO)				//Código BKO
	else 
		oAddCCusto:cGrupo		:= AllTrim(cGrupo)				//Código do Grupo
	endif	
	oAddCCusto:cCentroCusto	:= cCCusto					//Código Centro de Custo
	oAddCCusto:cDescricao	:= AllTrim(cDescCusto)			//Descrição Centro de Custo
	oAddCCusto:nIdReserve 	:= 0						//ID Reserve

	oAddCCusto:oWSIDAutorizadores := CentrosCusto_ArrayOfInt():New() 

	For nX := 1 To Len(aAprovCC)
		Aadd(oAddCCusto:oWSIDAutorizadores:nIDAutorizador,Val(aAprovCC[nX]))
	Next nX

	Aadd(oCC:OWSINSERIRCENTROSCUSTORQ:OWSCENTROSCUSTO:oWSCENTROCUSTO,oAddCCusto)

ElseIf nOpc == 5 //Exclusao
	oCC:oWSExcluirCentrosCustoRQ:CSESSAO	:= cSessao
	oCC:oWSExcluirCentrosCustoRQ:oWSCODBKOs := CentrosCusto_ArrayOfString():New()
	
	If Empty(cGrupo)
		Aadd(oCC:oWSExcluirCentrosCustoRQ:oWSCODBKOs:cCODBKO,Alltrim(cCodBKO)) //Codigo BKO
	Else
		oCC:oWSExcluirCentrosCustoRQ:cGrupo := Alltrim(cGrupo)	//Codigo Grupo
	EndIf

	oCC:oWSExcluirCentrosCustoRQ:oWSCentrosCusto	:= CentrosCusto_ArrayOfString2():New()
	Aadd(oCC:oWSExcluirCentrosCustoRQ:OWSCENTROSCUSTO:CCENTROCUSTO,cCCusto)	//Código Centro de Custo

EndIf

Return

/*/{Protheus.doc} Fina655Apr
Obtem os aprovadores por Centro de Custo

@author Totvs
@since 22/10/2013
@version P11 R9

@param cCCusto, caractere, Código do registro de Centro de Custo

@return arrya,IDs Reserve dos usuarios aprovadores
/*/
Function Fina655Apr(cCCusto)
Local cTabTmp		:= GetNextAlias()
Local aAprovCC		:= {}

Default cCCusto	:= ""

BeginSQL Alias cTabTmp
SELECT	RD0.RD0_IDRESE
FROM	%Table:FLP% FLP
INNER JOIN %Table:RD0% RD0 ON
	RD0.RD0_CODIGO = FLP.FLP_CODAPR
	AND RD0.%NotDel%
WHERE	FLP.FLP_FILIAL = %XFilial:FLP%
	AND FLP.FLP_CCUSTO = %exp:cCCusto%
	AND FLP.%NotDel%
EndSQL

While (cTabTmp)->(!Eof()) //Carrega os aprovadores do Centro de Custo
	Aadd(aAprovCC,(cTabTmp)->RD0_IDRESE)
(cTabTmp)->(DbSkip())
EndDo

If Select(cTabTmp) > 0
	(cTabTmp)->(DbCloseArea())
EndIf

Return aAprovCC

/*/{Protheus.doc} FINA655Env
Executa a sincronização dos dados

@author Totvs
@since 31/08/2013
@version P11 R9

@param oCC, objeto, Objeto de envio de dados via XML
@param nOpc, numérico, Opção do processo (3=Inclusão,4=Alteração,5=Exclusão)
@param cCCusto, caractere, Código do registro de Centro de Custo

@return lógico,Indica se o envio foi realizado com sucesso
/*/
Function FINA655Env(oCC,nOpc,cCCusto)
Local lRet		:= .T.
Local aErro	:= {}
Local nX		:= 0

Default oCC	:= Nil
Default nOpc	:= 0

If nOpc == 3 .Or. nOpc == 4 //Inclusao ou Alteracao

	oCC:Inserir()

	If ValType(oCC:OWSINSERIRRESULT:OWSERROS) != "U"

		lRet := .F.

		For nX := 1 To Len(oCC:OWSINSERIRRESULT:OWSERROS:OWSERRO)
			Aadd(aErro,STR0003 + oCC:OWSINSERIRRESULT:OWSERROS:OWSERRO[nX]:CCODERRO) //"CCODERRO: "
			Aadd(aErro,STR0004+ oCC:OWSINSERIRRESULT:OWSERROS:OWSERRO[nX]:CMENSAGEM	) //"CMENSAGEM: "
		Next nX

		FINXRESLog("CTT",If(nOpc == 3,STR0005,STR0006),cCCusto,aErro) //"Inclusão"###"Alteração"

	EndIf

ElseIf nOpc == 5 //Exclusao

	oCC:Excluir()

	If ValType(oCC:OWSEXCLUIRRESULT:OWSERROS) != "U"

		lRet := .F.

		For nX := 1 To Len(oCC:OWSEXCLUIRRESULT:OWSERROS:OWSERRO)
			Aadd(aErro,STR0003 + oCC:OWSEXCLUIRRESULT:OWSERROS:OWSERRO[nX]:CCODERRO) //"CCODERRO: "
			Aadd(aErro,STR0004 + oCC:OWSEXCLUIRRESULT:OWSERROS:OWSERRO[nX]:CMENSAGEM) //"CMENSAGEM: "
		Next nX

		FINXRESLog("CTT",STR0007,cCCusto,aErro) //"Exclusão"

	EndIf

EndIf

Return lRet

/*/{Protheus.doc} FINA655Atu
Atualiza o campo que indica se o registro de Centro de Custo está sincronizado no Sistema Reserve

@author Totvs
@since 31/08/2013
@version P11 R9

@param nOpc, numérico, Opção do processo (3=Inclusão,4=Alteração,5=Exclusão)

@return lógico,Indica se o registro foi atualizado
/*/
Function FINA655Atu(nOpc,cCpoRes)
Local lRet			:= .T.
Local cStatus		:=	""

Default nOpc		:= 0
Default cCpoRes	:= ""

Do Case

	Case nOpc == 0 //Sincronizado
		cStatus := "4"

	Case nOpc == 3 .Or. cCpoRes == "1" //Pendente inclusao
		cStatus := "1"

	Case nOpc == 4 //Pendente alteracao
		cStatus := "2"

	Case nOpc == 5 //Pendente exclusão
		cStatus := "3"

	Case nOpc == 6 //Nao exportado
		cStatus := ""

EndCase

RecLock("CTT",.F.)
CTT->CTT_RESERV := cStatus
CTT->(MsUnlock())

Return lRet

/*/{Protheus.doc} FINA655Opc
Identifica a operação que será executada por meio do campo CTT_RESERV

@author Totvs
@since 31/08/2013
@version P11 R9

@param cAliasCTT, caracter, Alias da tabela de centro custo

@return numérico, Opção do processo (3=Inclusão,4=Alteração,5=Exclusão)
/*/
Function FINA655Opc(cAliasCTT)
Local nOpc			:= 0

Default cAliasCTT	:= ""

Do Case

	Case Empty((cAliasCTT)->CTT_RESERV) .Or. (cAliasCTT)->CTT_RESERV == "1" //Pendente inclusao
		nOpc := 3

	Case (cAliasCTT)->CTT_RESERV == "2" //Pendente alteracao
		nOpc := 4

	Case (cAliasCTT)->CTT_RESERV == "3" //Pendente exclusao
		nOpc := 5

End Case

Return nOpc

/*/{Protheus.doc} Fina655VlP
Funcao para validacao do preenchimento do parametro MV_RESCTT

@author Totvs
@since 31/08/2013
@version P11 R9

@param aDados, array, Dados do parâmetro MV_RESCTT

@return lógico, Validação do preenchimento do parâmetro
/*/
Function Fina655VlP(aDados)
Local lRet		:= .T.
Local aErros	:= {}

Default aDados	:= {}

If Len(aDados) != 3
	lRet := .F.
	Aadd(aErros,STR0008) //"Parâmetro MV_RESCTT com estrutura errada."
Else
	If Empty(aDados[1])
		lRet := .F.
		Aadd(aErros,STR0009) //"Código do Centro de Custo não informado no parâmetro MV_RESCTT. Primeira posição."
	EndIf

	If Empty(aDados[2])
		lRet := .F.
		Aadd(aErros,STR0010) //"Descrição do Centro de Custo não informado no parâmetro MV_RESCTT. Segunda posição."
	EndIf

	If Empty(aDados[3])
		lRet := .F.
		Aadd(aErros,STR0011) //"Identificador de envio do Centro de Custo não informado no parâmetro MV_RESCTT. Terceira posição."
	ElseIf !AllTrim(aDados[3]) $ "0|1"
		lRet := .F.
		Aadd(aErros,STR0012) //"Identificador de envio do Centro de Custo inválido no parâmetro MV_RESCTT. Terceira posição."
	EndIf
EndIf

If !lRet
	FinXResLog("CTT",STR0005,"MV_RESCTT",aErros,.T.) //"Inclusão"
EndIf

Return lRet
