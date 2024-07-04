#INCLUDE "FINA659.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/*/{Protheus.doc} FINA659
Sincronização do cadastro de Clientes do Protheus no Reserve chamada via rotina.

@author Totvs
@since 31/08/2013
@version P11 R9

@return Nil
/*/
Function FINA659(nOpc)
Local cTipoInteg	:= GetMV("MV_RESEXP",.F.,"0")
Local nOpcAux		:= 0

Default nOpc		:= 0

nOpcAux := nOpc

If FINA659Vld(@nOpcAux) //Valida se o registro precisa ser sincronizado

	If FINA659Atu(nOpcAux) //Atualiza registro como pendente

		If cTipoInteg $ "1|3"

			MsgRun(STR0001,STR0002,{|| FINA659Man(nOpcAux)}) //"Integrando com o Sistema Reserve"###"Integração Reserve"

		EndIf

	EndIf

EndIf

Return

/*/{Protheus.doc} FINA659Man
Sincroniza o cadastro de Clientes do Protheus no Reserve.

@author Totvs
@since 31/08/2013
@version P11 R9

@param nOpc, numérico, Processo executado (3=Inclusão,4=Alteracao,5=Exclusao)

@return Nil
/*/
Function FINA659Man(nOpcAux)
Local aSaveArea	:= GetArea()
Local oCliente	:= Nil
Local cSessao	:= ""
Local oSvc		:= Nil
Local cCodCli	:= SA1->A1_COD + SA1->A1_LOJA //O codigo deve manter os espaços a esquerda e direita se houver 

Default nOpcAux	:= 0

If FINXRESOSe(@cSessao,@oSvc,"SA1",cCodCli) //Abre sessão

	oCliente := WSProjeto():New() //Cria objeto para envio

	FINA659Car(@oCliente,cSessao,nOpcAux,cCodCli,SA1->A1_NOME) //Carrega os dados no objeto

	If FINA659Env(@oCliente,nOpcAux,cSessao,cCodCli,SA1->A1_NOME) //Envia os dados ao Sistema Reserve

		If nOpcAux == 5
			FINA659Atu(6) //Limpa o campo de envio
		Else
			FINA659Atu(0) //Marca registro como sincronizado
		EndIf

	EndIf

	FINXRESCSe(@cSessao,@oSvc) //Encerra sessão

EndIf

RestArea(aSaveArea)

Return

/*/{Protheus.doc} FINA659Job
Sincroniza o cadastro de Clientes do Protheus no Reserve via Schedule.

@author Totvs
@since 31/08/2013
@version P11 R9

@return Nil
/*/
Function FINA659Job()
Local aSaveArea		:= GetArea()
Local cTipoInteg	:= SuperGetMV("MV_RESEXP",.F.,"0")
Local lExpSA1		:= SubStr(SuperGetMV("MV_RESCAD",.F.,"111"),2,1) == "1"	//Verifica se a exportacao do cliente esta habilitada
Local cAliasSA1		:= ""
Local oCliente		:= Nil
Local cSessao		:= ""
Local oSvc			:= Nil
Local nOpc			:= 0
Local cCodCli		:= ""

If lExpSA1 .And. cTipoInteg $ "2|3"

	If FINA659Qry(@cAliasSA1)

		If FINXRESOSe(@cSessao,@oSvc,"SA1",(cAliasSA1)->(A1_COD+A1_LOJA)) //Abre sessão no Sistema Reserve

			oCliente := WSProjeto():New()

			//-----------------------------------------------
			// Sincronizacao do cadastro de Clientes
			//-----------------------------------------------
			While (cAliasSA1)->(!Eof())

				cCodCli := (cAliasSA1)->A1_COD + (cAliasSA1)->A1_LOJA

				FINA659Opc(cAliasSA1,@nOpc) //Identifica a operacao

				FINA659Car(@oCliente,cSessao,nOpc,cCodCli,(cAliasSA1)->A1_NOME) //Carrega os dados no objeto

				If FINA659Env(@oCliente,nOpc,cSessao,cCodCli,(cAliasSA1)->A1_NOME) //Envia os dados ao Sistema Reserve

					SA1->(DbGoTo((cAliasSA1)->R_E_C_N_O_))
					If nOpc == 5
						FINA659Atu(6) //Limpa o campo de envio
					Else
						FINA659Atu(0) //Marca registro como sincronizado
					EndIf

				EndIf

			(cAliasSA1)->(DbSkip())
			EndDo

			FINXRESCSe(@cSessao,@oSvc) //Encerra sessão

		EndIf

	EndIf

	If !Empty(cAliasSA1) .And. Select(cAliasSA1) > 0
		(cAliasSA1)->(DbCloseArea())
	EndIf

EndIf 

RestArea(aSaveArea)

Return

/*/{Protheus.doc} FINA659Qry
Executa query para obtenção dos Clientes pendentes de sincronização no Sistema Reserve.

@author Totvs
@since 31/08/2013
@version P11 R9

@param cAliasSA1, caractere, Alias da tabela temporária

@return lógico,Indica se a tabela possui dados
/*/
Function FINA659Qry(cAliasSA1)
Local lRet := .T.

cAliasSA1 := GetNextAlias()

BeginSQL Alias cAliasSA1
SELECT	SA1.A1_FILIAL,SA1.A1_COD,SA1.A1_LOJA,SA1.A1_NOME,SA1.A1_MSBLQL,SA1.A1_RESERVE,SA1.D_E_L_E_T_,SA1.R_E_C_N_O_
FROM	%Table:SA1% SA1
WHERE	SA1.A1_FILIAL = %XFilial:SA1%
		AND SA1.A1_RESERVE <> '4'
		AND (SA1.A1_MSBLQL <> '1' OR SA1.A1_RESERVE = '3')
		AND (SA1.%NotDel% OR SA1.A1_RESERVE = '3')
ORDER BY SA1.A1_RESERVE
EndSQL

lRet := (cAliasSA1)->(!Eof())

Return lRet

/*/{Protheus.doc} FINA659Vld
Valida se o registro de Cliente precisa ser sincronizado no Sistema Reserve

@author Totvs
@since 31/08/2013
@version P11 R9

@param nOpcAux, numérico, Opção do processo (3=Inclusão,4=Alteração,5=Exclusão)

@return lógico,Indica se o registro precisa ser sincronizado
/*/
Function FINA659Vld(nOpcAux)
Local lRet		:= .T.

Default nOpcAux	:= 0

Do Case

	//----------------------
	// INCLUSAO
	//----------------------
	Case nOpcAux == 3

		//Se cliente bloqueado, altera para flag vazio e não envia para o Reserve
		If SA1->A1_MSBLQL == "1"
			FINA659Atu(6)
			lRet := .F.
		EndIf

	//----------------------
	// ALTERACAO
	//----------------------
	Case nOpcAux == 4

		//Se cliente bloqueado e pendente de alteracao ou sincronizado, altera a opcao para exclusao
		If SA1->A1_MSBLQL == "1" .And. SA1->A1_RESERVE $ "2|4"
			nOpcAux := 5

		//Se cliente bloqueado e pendente de envio, altera para flag vazio.
		ElseIf SA1->A1_MSBLQL == "1" .And. SA1->A1_RESERVE == "1" 
			FINA659Atu(6)
			lRet := .F.

		//Se cliente bloqueado e sem definição de integração, não processa o registro.
		ElseIf SA1->A1_MSBLQL == "1" .And. Empty(SA1->A1_RESERVE)
			lRet := .F.

		//Se cliente nao bloqueado e nunca foi enviado ou esta pendente de envio, altera para opcao de inclusao
		ElseIf SA1->A1_MSBLQL != "1" .And. Empty(SA1->A1_RESERVE) .Or. SA1->A1_RESERVE == "1"
			nOpcAux := 3

		EndIf

	//----------------------
	// EXCLUSAO
	//----------------------
	Case nOpcAux == 5

		//Se cliente bloqueado e sincronizado assumo que ja foi excluso no Reserve
		If SA1->A1_MSBLQL == "1" .And. SA1->A1_RESERVE $ "4"
			lRet := .F.

		//Desconsidera a exclusao de Clientes que nunca foram enviados
		ElseIf Empty(SA1->A1_RESERVE)
			lRet := .F.

		//Se o cliente está pendente de envio, limpa o flag para não ficar pendente de exclusao
		ElseIf SA1->A1_RESERVE == "1"
			lRet := .F.
			FINA659Atu(6)

		EndIf

EndCase 

Return lRet

/*/{Protheus.doc} FINA659Car
Carrega no objeto os dados para sincronização do registro de Clientes

@author Totvs
@since 31/08/2013
@version P11 R9

@param oCliente, objeto, Objeto de envio de dados via XML
@param cSessao, caractere, Sessao aberta no Sistema Reserve
@param nOpc, numérico, Opção do processo (3=Inclusão,4=Alteração,5=Exclusão)
@param cCliente, caractere, Código do registro de Cliente
@param cNomeCli, caractere, Nome do registro de Cliente

@return Nil
/*/
Function FINA659Car(oCliente,cSessao,nOpc,cCliente,cNomeCli)
Local oAddClient	:= Nil
Local cCodBKO		:= BKO2AGE(cEmpAnt+cFilAnt)
Local cCodGrupo		:= BKO2GruCli(cEmpAnt+cFilAnt)
Default oCliente	:= Nil
Default cSessao		:= ""
Default nOpc		:= 0
Default cCliente	:= ""
Default cNomeCli	:= ""

If nOpc == 3 //Inclusao
	oCliente:oWSInserirProjetosRQ:cSessao		:= cSessao
	oCliente:oWSInserirProjetosRQ:oWSProjetos	:= Projeto_ArrayOfProjeto():New()

	oAddClient := Projeto_Projeto():NEW() //Instancia objeto para incremento de dados a enviar
	if Empty(cCodGrupo)
		oAddClient:cCODBKO	:= AllTrim(cCodBKO)		//Código BKO
	else
		oAddClient:cGrupo	:= AllTrim(cCodGrupo)	//Código Grupo
	endif
	oAddClient:cProjeto		:= cCliente				//Código + Loja do cliente manter os espaços a esquerda e direita se houver
	oAddClient:cDescricao	:= AllTrim(cNomeCli)	//Nome do Cliente
	oAddClient:nIdReserve	:= 0

	Aadd(oCliente:oWSInserirProjetosRQ:oWSProjetos:oWSProjeto,oAddClient)

ElseIf nOpc == 4 .Or. nOpc == 5 //Alteracao ou Exclusao
	//-----------------------------------------------------------
	// O Sistema Reserve nao possui processo de alteracao, sendo
	// necessario excluir e incluir novamente o Centro de Custo
	//-----------------------------------------------------------
	oCliente:oWSExcluirProjetosRQ:CSESSAO		:= cSessao
	oCliente:oWSExcluirProjetosRQ:oWSCODBKOs	:= Projeto_ArrayOfString():New()

	If Empty(cCodGrupo)
		Aadd(oCliente:oWSExcluirProjetosRQ:OWSCODBKOS:cCODBKO,AllTrim(cCodBKO)) //Código BKO
	Else
		oCliente:oWSExcluirProjetosRQ:cGrupo := AllTrim(cCodGrupo) //Código Grupo
	EndIf

	oCliente:oWSExcluirProjetosRQ:oWSProjetos	:= Projeto_ArrayOfString2():New()
	Aadd(oCliente:oWSExcluirProjetosRQ:oWSProjetos:cProjeto,cCliente)	//Código do Cliente + loja manter os espaços a esquerda e direita se houver

EndIf

Return

/*/{Protheus.doc} FINA659Env
Executa a sincronização dos dados

@author Totvs
@since 31/08/2013
@version P11 R9

@param oCliente, objeto, Objeto de envio de dados via XML
@param nOpc, numérico, Opção do processo (3=Inclusão,4=Alteração,5=Exclusão)
@param cSessao, caractere, Sessao aberta no Sistema Reserve
@param cCliente, caractere, Código do registro de Cliente
@param cNomeCli, caractere, Descrição do registro de Cliente

@return lógico,Indica se o envio foi realizado com sucesso
/*/
Function FINA659Env(oCliente,nOpc,cSessao,cCliente,cNomeCli)
Local lRet			:= .T.
Local aErro			:= {}
Local nX			:= 0

Default oCliente	:= Nil
Default nOpc		:= 0

If nOpc == 3 //Inclusao

	oCliente:Inserir()

	If ValType(oCliente:OWSINSERIRRESULT:OWSERROS) != "U" .and. Len(oCliente:OWSINSERIRRESULT:OWSERROS:OWSERRO)> 0 

		lRet := .F.

		For nX := 1 To Len(oCliente:OWSINSERIRRESULT:OWSERROS:OWSERRO)
			Aadd(aErro,STR0003 + oCliente:OWSINSERIRRESULT:OWSERROS:OWSERRO[nX]:CCODERRO) //"CCODERRO: "
			Aadd(aErro,STR0004+ oCliente:OWSINSERIRRESULT:OWSERROS:OWSERRO[nX]:CMENSAGEM	) //"CMENSAGEM: "
		Next nX

		FINXRESLog("SA1",STR0005,cCliente,aErro) //"Inclusão"

	EndIf

ElseIf nOpc == 4 //Alteracao

	oCliente:Excluir()

	If ValType(oCliente:OWSEXCLUIRRESULT:OWSERROS) != "U" .and. Len(oCliente:OWSEXCLUIRRESULT:OWSERROS:OWSERRO)> 0 

		lRet := .F.

		For nX := 1 To Len(oCliente:OWSEXCLUIRRESULT:OWSERROS:OWSERRO)
			Aadd(aErro,STR0003 + oCliente:OWSEXCLUIRRESULT:OWSERROS:OWSERRO[nX]:CCODERRO) //"CCODERRO: "
			Aadd(aErro,STR0004+ oCliente:OWSEXCLUIRRESULT:OWSERROS:OWSERRO[nX]:CMENSAGEM	) //"CMENSAGEM: "
		Next nX

		FINXRESLog("SA1",STR0006,cCliente,aErro) //"Alteração"

	EndIf

	If lRet
		FINA659Car(@oCliente,cSessao,3,cCliente,cNomeCli)
		oCliente:Inserir()

		If ValType(oCliente:OWSINSERIRRESULT:OWSERROS) != "U" .and. Len(oCliente:OWSINSERIRRESULT:OWSERROS:OWSERRO)> 0 

			lRet := .F.

			For nX := 1 To Len(oCliente:OWSINSERIRRESULT:OWSERROS:OWSERRO)
				Aadd(aErro,STR0003 + oCliente:OWSINSERIRRESULT:OWSERROS:OWSERRO[nX]:CCODERRO) //"CCODERRO: "
				Aadd(aErro,STR0004+ oCliente:OWSINSERIRRESULT:OWSERROS:OWSERRO[nX]:CMENSAGEM	) //"CMENSAGEM: "
			Next nX

			FINXRESLog("SA1",STR0006,cCliente,aErro) //"Alteração"

		EndIf

	EndIf

ElseIf nOpc == 5 //Exclusao

	oCliente:Excluir()

	If ValType(oCliente:OWSEXCLUIRRESULT:OWSERROS) != "U"

		lRet := .F.

		For nX := 1 To Len(oCliente:OWSEXCLUIRRESULT:OWSERROS:OWSERRO)
			Aadd(aErro,STR0003 + oCliente:OWSEXCLUIRRESULT:OWSERROS:OWSERRO[nX]:CCODERRO) //"CCODERRO: "
			Aadd(aErro,STR0004+ oCliente:OWSEXCLUIRRESULT:OWSERROS:OWSERRO[nX]:CMENSAGEM	) //"CMENSAGEM: "
		Next nX

		FINXRESLog("SA1",STR0007,cCliente,aErro) //"Exclusão"

	EndIf

EndIf

Return lRet

/*/{Protheus.doc} FINA659Env
Atualiza o campo que indica se o registro de Cliente está sincronizado no Sistema Reserve

@author Totvs
@since 31/08/2013
@version P11 R9

@param nOpc, numérico, Opção do processo (3=Inclusão,4=Alteração,5=Exclusão)

@return lógico,Indica se o registro foi atualizado
/*/
Function FINA659Atu(nOpc)
Local lRet		:= .T.
Local cStatus	:=	""

Default nOpc	:= 0

Do Case

	Case nOpc == 0 //Sincronizado
		cStatus := "4"

	Case nOpc == 3	//Pendente inclusao
		cStatus := "1"

	Case nOpc == 4 //Pendente alteracao
		cStatus := "2"

	Case nOpc == 5 //Pendente exclusão
		cStatus := "3"

	Case nOpc == 6 //Excluso ou nao enviado
		cStatus := ""

EndCase

RecLock("SA1",.F.)
SA1->A1_RESERVE := cStatus
SA1->(MsUnlock())

Return lRet

Function FINA659Opc(cAliasSA1,nOpc)
Default cAliasSA1	:= ""
Default nOpc		:= 0

Do Case

	Case Empty((cAliasSA1)->A1_RESERVE) .Or. (cAliasSA1)->A1_RESERVE == "1" //Pendente inclusao
		nOpc := 3

	Case (cAliasSA1)->A1_RESERVE == "2" //Pendente alteracao
		nOpc := 4

	Case (cAliasSA1)->A1_RESERVE == "3" //Pendente exclusao
		nOpc := 5

EndCase

Return
