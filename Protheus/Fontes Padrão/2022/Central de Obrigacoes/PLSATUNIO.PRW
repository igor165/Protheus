#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PLSMGER.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE MVCERRCOD		5
#DEFINE MVCERRDES		6
#DEFINE MVCERRSOL		7
#DEFINE PDTE_VALID		"1" // Pendente Validacao
#DEFINE VALIDO			"2" // Valido
#DEFINE INVALIDO		"3" // Invalido
#DEFINE ENV_ANS			"4" // Enviado ANS
#DEFINE CRIT_ANS		"5" // Criticado ANS
#DEFINE ACAT_ANS		"6" // Acatado ANS
#DEFINE CANCELADO		"7" // Cancelado
#DEFINE JOB_VALID		"1" // Job Validacao
#DEFINE ESPELHO_COMP	"2" // Comparacao de Espelhos
#DEFINE ARQ_RETORNO		"3" // Arquivo Retorno
#DEFINE OBRIG_SIP		"1"
#DEFINE OBRIG_SIB		"2"
#DEFINE SIB_INCLUIR		"1" // Incluir
#DEFINE SIB_RETIFIC		"2" // Retificar
#DEFINE SIB_MUDCONT		"3" // Mud.Contrat
#DEFINE SIB_CANCELA		"4" // Cancelar
#DEFINE SIB_REATIVA		"5" // Reativar

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSAtuNIO

Realiza a atuazacao do NIO apos uma alteracao no PLS

@param cAlias		Nome da Area de trabalho ativa
@param aDados		Lista dos campos que serao atualizados
@param nOpc			Operacao que sera executada
@param dDtRef		Data de referencia recebida por parametro
@param lRotBloq	Em conjunto com lBloqueio indica se e uma operacao de bloqueio/desbloqueio
@param lBloqueio	Indicacao de bloqueio / desbloqueio do beneficiario
@param aDadCob		Matriz de cobertura do beneficiario
@param aCrit		Matriz de críticas geradas no processo
@param lTransf		Indica que e uma operacao de transferência de beneficiario
@param lOriTran	Indica que e a origem da transferência
@param lSoValid	Indica se ira somemente .T. validar ou .F. tambem gravar
@param lManCCO		Incica se mantera .T. ou nao .F. o CCO do beneficiario
@param lEnviaOpe	//TODO Everton

@return lRetorno Retorna .T. Verdadeiro para atualizacao realizada com sucesso, senao retorna .F. Falso

@author TOTVS PLS Team
@since 08/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSAtuNIO(cAlias,xDados,nOpc,dDtRef,aDadCob,aCrit,lSoVld,lEnvOpe)
	Local lRetorno			:= .F.//Variavel de retorno
	Private __cError 	:= ""//Variavel privada a ser atualizada com informacao de erro
	Private __cCallStk	:= ""//Variavel privada a ser atualizada com informacao da pilha de chamada
	Default cAlias		:= ""
	Default nOpc			:= 3
	Default dDtRef		:= STOD("")
	Default lSoVld		:= .F.
	Default lEnvOpe	    := .T.
	Default xDados		:= {}
	Default aDadCob		:= {}
	Default aCrit			:= {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama ponto de entrada logo apos a gravacao de todas as tabelas...       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("PLPRENIO")
		ExecBlock("PLPRENIO",.f.,.f.,{cAlias,xDados,nOpc,dDtRef,aDadCob,aCrit,lSoVld,lEnvOpe})
	Endif

	BEGIN TRANSACTION

		//Prepara os dados para chamar model
		If cAlias == "B3J"

			lRetorno := PLAtNIOPro(cAlias,xDados,nOpc)

		EndIf

	END TRANSACTION

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLAtNIOPro

Funcao criada para Controlar a atualizacao dos Produtos no NIO

@param cAlias	area de trabalho ativa
@param aDados	Matriz com os dados do produto que sera atualizado
@param nOpc		Operacao que sera executada

@return lRet Indica se a operacao foi executada com sucesso

@author TOTVS PLS Team
@since 11/04/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLAtNIOPro(cAlias,aDados,nOpc)
	Local lRetorno		:= .T.
	Local lExist		:= .F.
	Local lMudaCon		:= .F.
	Local lMudaSeg		:= .F.
	Local cModel 		:= "PLSMVCPRO"
	Local cStruct		:= "B3JMASTER"
	Local cCodOpe		:= ""
	Local cCodPro		:= ""
	Local cTipConAnt	:= ""
	Local cSegAnt		:= ""
	Local nI 			:= 0

	Local oModel		:= Nil

	//Verifico se a Segmentacao foi alterada. Caso tenha sido, preciso mover os dados sinteticos do produto para a nova segmentacao
	If !Empty(RetValor('B3J_SEGMEN', aDados))
		lMudaSeg := .T.
		//Recupero a segmentacao antiga se o chamado vier do cadastro de segmentacao
		cSegAnt := RetValor('B3J_SEGMEN_ANT', aDados)
	EndIf
	//Verifico se a Forma de Contratacao foi alterada. Caso tenha sido, preciso mover os dados sinteticos do produto para a nova segmentacao
	If !Empty(RetValor('B3J_FORCON', aDados))
		lMudaCon := .T.
	EndIf
	cCodPro := RetValor('B3J_CODIGO', aDados)
	cCodOpe := RetValor('B3J_CODOPE', aDados)

	//Posiciono no produto do SIP
	If !Empty(cCodOpe+cCodPro)

		B3J->(DbSetOrder(1)) //B3J_FILIAL+B3J_CODOPE+B3J_CODIGO
		lExist := B3J->(MsSeek(xFilial("B3J")+cCodOpe+cCodPro))

		If lExist .And. nOpc <> K_Excluir
			For nI := 1 to Len(aDados)

				If aDados[nI,1] == "B3J_SEGMEN"

					aDados[nI,2]:= SegPlsXCentral(aDados[nI,2])

				EndIf
			Next nI

		EndIf
		//Ativa model
		oModel	:= FWLoadModel( cModel )

		If !lExist
			nOpc := K_Incluir
			nOpcMVC := MODEL_OPERATION_INSERT
		ElseIf nOpc == K_Incluir
			nOpcMVC := MODEL_OPERATION_INSERT
		ElseIf nOpc == K_Excluir
			nOpcMVC := MODEL_OPERATION_DELETE
		ElseIf nOpc == K_Alterar
			nOpcMVC := MODEL_OPERATION_UPDATE
		EndIf

		oModel:SetOperation( nOpcMVC )
		oModel:Activate()

		//Atualizo o Produto no NIO
		//Preencho o model com os dados que vieram da rotina
		If nOpc != K_Excluir
			nLen := Len(aDados)
			For nI := 1 to nLen
				//Verifico se o campo e desse model. Em alguns casos, como Beneficiario, tem campos do produto no array que nao devem ser gravados.
				If cAlias == SubStr(aDados[nI,1],1,3)

					oModel:SetValue( cStruct, aDados[nI,1], aDados[nI,2] )

				EndIf
			Next nI
		EndIf

		If oModel:VldData()
			oModel:CommitData()
			lRetorno := .T.
		Else
			aErro := oModel:GetErrorMessage()
		EndIf

		oModel:DeActivate()
		oModel:Destroy()
		FreeObj(oModel)
		oModel := Nil
		DelClassInf()

	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetValor

Funcao criada para retornar o valor de um campo que esta dentro do array

@param cCampo		Campo que esta contido na posicao 1 do array
@param aValores	Matriz que contem [Nome_campo][Valor_campo]

@return xValor Retorna o valor do campo

@author TOTVS PLS Team
@since 11/04/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetValor(cCampo, aValores)
	Local xValor 	:= ""

	Local nPos 	:= 0

	Default cCampo 	:= ""
	Default aValores := {}

	If Len(aValores) > 0
		nPos := aScan(aValores,{|x|x[1] == cCampo })
		If nPos > 0
			xValor := aValores[nPos][2]
		EndIf
	EndIf

Return xValor

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLInHisCanCO

Inclui um item no historio de Cancelamento da Central de Obrigacoes

@param dDtRef		Data de referencia do processamento
@param lBloqueio	Indica se esta bloqueando .T. ou desbloqueando .F. o beneificario
@param cMatric		Matricula do beneficiario
@param cMotBlo		Motivo de bloqueio informado
@param cHora		Hora da realizacao do bloqueio

@author TOTVS PLS Team
@since 11/04/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLInHisCanCO(dDtRef,lBloqueio,cMatric,cMotBlo,cHora,cCodOpe,cCodCco)
	Local cTipo := IIf(lBloqueio,"0","1")
	Default cCodCco:=""
	Default cCodOpe:=""

	B4W->(DbSetOrder(1)) //B4W_FILIAL+B4W_MATRIC+DTOS(B4W_DATA)+B4W_TIPO

	RecLock("B4W",.T.)

	B4W->B4W_FILIAL	:= xFilial("B4W")
	B4W->B4W_CODOPE	:= cCodOpe
	B4W->B4W_CODCCO	:= cCodCco
	B4W->B4W_MATRIC	:= cMatric
	B4W->B4W_TIPO 	:= cTipo
	B4W->B4W_DATA	:= dDtRef
	B4W->B4W_HORA	:= cHora
	B4W->B4W_STATUS	:= "1"
	If !Empty(cMotBlo)
		B4W->B4W_MOTBLO	:= cMotBlo
	EndIf

	B4W->(MsUnlock())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlBenNaANS

Verifico se o beneficiario ja foi incluído na base da ANS

@author TOTVS PLS Team
@since 11/04/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLBenNaANS(oModel)
	Local lBenNaAns	:= .T.
	Local cCodCCO	:= ""
	Local cMatric	:= ""
	Local cCodOpe	:= ""

	If oModel == Nil
		cCodCCO := B3K->B3K_CODCCO
		cCodOpe := B3K->B3K_CODOPE
		dDatInc := B3K->B3K_DATINC
	Else
		cCodCCO := oModel:GetValue( "B3KMASTER", "B3K_CODCCO")
		cCodOpe := oModel:GetValue( "B3KMASTER", "B3K_CODOPE")
		dDatInc := oModel:GetValue( "B3KMASTER", "B3K_DATINC")
	EndIf

	If Empty(cCodCCO)
		If !IncEnvAns() //Verifico se a inclusão do beneficiário já foi enviada para a ANS
			B3W->(DbSetOrder(2)) //B3W_FILIAL+B3W_CODOPE+B3W_MATRIC+B3W_DATINC
			cMatric := RetMatric(oModel)
			lBenNaAns := B3W->(MsSeek(xFilial("B3W")+cCodOpe+PADR(cMatric,tamSX3("B3W_MATRIC")[1])+DTOS(dDatInc) ))
		EndIf
	EndIf

Return lBenNaAns

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IncEnvAns

Indica se já foi enviada a inclusão para a ANS

@return lRet .T. pendente envio de inclusao

@author everton.mateus
@since 19/05/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function IncEnvAns(nRecno)
	Local lRetorno		:= .F.

	Default nRecno := B3K->(Recno())

	cSql := " SELECT 1 "
	cSql += " FROM " + RetSqlName("B3X") + " "
	cSql += " WHERE "
	cSql += "	B3X_FILIAL = '" + xFilial('B3X') + "' "
	cSql += "	AND B3X_BENEF = '"+ PADL(AllTrim(Str(nRecno)),10) +"' "
	cSql += "	AND B3X_OPERA = '"+SIB_INCLUIR+"' "
	cSql += "	AND B3X_STATUS IN  ('"+ENV_ANS+"','"+ACAT_ANS+"')"
	cSql += "	AND D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBPTE",.F.,.T.)

	lRetorno := !TRBPTE->(Eof())

	TRBPTE->(DbCloseArea())

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetMatric

Retorna o RetMatric do beneficiario

@param oModel	Model MVC

@return cMatric

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetMatric(oModel)
	Local cMatric := ""
	Local cMatAnt := ""

	If oModel == Nil
		cMatric := B3K->B3K_MATRIC
		cMatAnt := B3K->B3K_MATANT
	Else
		cMatric := oModel:GetValue( "B3KMASTER", "B3K_MATRIC")
		cMatAnt := oModel:GetValue( "B3KMASTER", "B3K_MATANT")
	EndIf

	If GetNewPar("MV_PLMATAN",.F.)
		If !Empty(cMatAnt)
			cMatric := cMatAnt
		EndIf
	EndIf

Return cMatric

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlAtuHisOpe

Funcao criada para atualizar o historico de operacoes do SIB

@param nRecno		Recno do beneficiario
@param cCampo		Campo afetado (se a operacao envolve um campo específico)
@param dDtRef		Data de referência da operacao
@param cOpe			Operacao (1=Incluir;2=Retificar;3=Mud.Contrat;4=Cancelar;5=Reativar)
@param cChaveOri	Chave da origem da movimentacao
@param cDescOri	Descricao da movimentacao
@param lVldSibSin	Indica se deve validar a sintetizacao do SIB
@param lGrvCritic	Indica se grava .T. ou nao .F. criticados
@param cRegAns		Numero de registro da operadora na ANS
@param aCrit		Matriz de criticas
@param cHora		Hora da transacao

@return nRet		Recno do registro gravado na B3X

@author TOTVS PLS Team
@since 11/04/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlAtuHisOpe(nRecno,cCampos,dDtRef,cOpe,cChaveOri,;
		cDescOri,lVldSibSin,lGrvCritic,cRegAns,aCrit,;
		cHora,cVlrAnt,cVlrNovo,cCodCCO,lChange)

	Local lInclui		:= .T.
	Local nRet			:= 0
	Local cArquivo		:= IIf(cOpe == SIB_INCLUIR , "", PADR("",tamSX3("B3X_ARQUIV")[1]) )
	Local lNaoAlt       := .F.
	Default lVldSibSin	:= OBRIG_SIB $ GetNewPar("MV_PLVLDSI",OBRIG_SIB) .AND. OBRIG_SIB $ GetNewPar("MV_PLOBRSI",OBRIG_SIP + "," + OBRIG_SIB)
	Default lGrvCritic	:= GetNewPar("MV_PLGRCRI",.T.) //Indica se pode gravar o registro mesmo com críticas.
	Default cVlrAnt		:= ""
	Default cVlrNovo	:= ""
	Default cRegAns		:= PADR("",tamSX3("B3K_CODOPE")[1])
	Default cCodCCO 	:= PADR("",tamSX3("B3K_CODCCO")[1])
	Default lChange     := .F.

	If cOpe == SIB_RETIFIC .And. lChange
		If cVlrAnt == cVlrNovo
			lNaoAlt:= .T. //somente gravo b3x caso o conteúdo da alteração seja diferente do que já tenho gravado.
		EndIf
	EndIF

	B3X->(DbSetOrder(3)) //B3X_FILIAL+STR(B3X_BENEF)+B3X_CAMPO+B3X_OPERA+B3X_ARQUIV+DTOS(B3X_DATA)

	lB3X_CODOPE := B3X->(FieldPos("B3X_CODOPE")) > 0
	lB3X_VLRANT := B3X->(FieldPos("B3X_VLRANT")) > 0
	lB3X_VLRNOV := B3X->(FieldPos("B3X_VLRNOV")) > 0
	lB3X_CODCCO := B3X->(FieldPos("B3X_CODCCO")) > 0

	If cOpe $ SIB_CANCELA + "," + SIB_REATIVA

		lInclui := .T.

	Else

		lInclui := !B3X->(MsSeek(xFilial("B3X")+PADL(AllTrim(Str(B3K->(Recno()))),10)+PADR(cCampos,tamSX3("B3X_CAMPO")[1])+cOpe+cArquivo))

	EndIf

	If !lNaoAlt
		RecLock("B3X",lInclui)
		B3X->B3X_FILIAL := xFilial("B3X")
		If lB3X_CODOPE
			B3X->B3X_CODOPE := cRegAns
		EndIf
		B3X->B3X_BENEF := nRecno
		B3X->B3X_CAMPO := cCampos
		If lInclui .OR. B3X->B3X_STATUS <> INVALIDO //Entendo que se o status e invalido, essa alteracao e para corrigir o erro. Entao eu mantenho a data da alteracao original.
			B3X->B3X_DATA := dDtRef
			B3X->B3X_HORA := cHora
		EndIf
		B3X->B3X_OPERA := cOpe
		B3X->B3X_IDEORI 	:= cChaveOri
		B3X->B3X_DESORI 	:= cDescOri
		B3X->B3X_STATUS 	:= PDTE_VALID
		B3X->B3X_DATOPE 	:= dDataBase
		B3X->B3X_USUARI 	:= cUserName
		If lB3X_VLRANT .And. lB3X_VLRNOV
			B3X->B3X_VLRANT := IIf(ValType(cVlrAnt) == "D", DTOS(cVlrAnt), cVlrAnt)
			B3X->B3X_VLRNOV := IIf(ValType(cVlrNovo) == "D", DTOS(cVlrNovo), cVlrNovo)
		EndIf
		If lB3X_CODCCO
			B3X->B3X_CODCCO := cCodCCO
		EndIf

		B3X->(MsUnlock())

		nRet := B3X->(Recno())

		If cOpe $ SIB_CANCELA + ","+ SIB_REATIVA
			CnBlReaPdte(nRecno)
		EndIf

		// Eu so valido depois da gravacao se for permitido gravar criticados
		If lVldSibSin .AND. lGrvCritic
			lBenVld := PLSIBVLOP(cEmpAnt,cFilAnt,{},DTOS(dDataBase),cRegAns,cEmpAnt,Nil,JOB_VALID,aCrit,,,B3K->(Recno()),cCampos)
		EndIf

		If cOpe == SIB_INCLUIR
			PlCOExcAltPd(nRecno)
		EndIf
	EndIf

Return nRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlCOExcAltPd

Funcao criada para excluir as alteracoes pendentes.

Na inclusao, eu verifico se ha alguma operacao de alteracao pendente.
Caso haja, eu as desconsidero e deixo apenas a inclusao. Pois no envio da inclusao, todas as alteracoes tambem serao enviadas.

@param nRecno		Recno do beneficiario

@return nRet		Retorno da instrucao delete, se menor que zero nao executou

@author TOTVS PLS Team
@since 11/04/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlCOExcAltPd(nRecno)
	Local cSql := ""
	Local nRet := 0

	cSql := " DELETE FROM " + RetSqlName('B3X')
	cSql += " WHERE "
	cSql += "	B3X_FILIAL = '" + xFilial('B3X') + "' "
	cSql += "	AND B3X_BENEF = '" + PADL(AllTrim(Str(B3K->(Recno()))),10) + "' "
	cSql += "	AND B3X_STATUS IN  ('"+PDTE_VALID+"','"+VALIDO+"','"+INVALIDO+"')"
	cSql += "	AND B3X_OPERA  = '"+SIB_RETIFIC+"' "

	nRet := TCSQLEXEC(cSql)
	If nRet >= 0 .AND. SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
		nRet := TCSQLEXEC("COMMIT")
	Endif

Return nRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CnBlReaPdte

Funcao criada para deixar os movimentos de bloqueio e reativação pendentes de validação novamente.
Quando chega um novo bloqueio ou reativação, preciso revalidar os movimentos anteriores para garantir que a linha do tempo do
beneficiário continua válida

@param nRecno		Recno do beneficiario

@return nRet		Retorno da instrucao delete, se menor que zero nao executou

@author TOTVS PLS Team
@since 16/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CnBlReaPdte(nRecno)
	Local cSql := ""
	Local nRet := 0

	cSql := " UPDATE " + RetSqlName('B3X')
	cSql += " SET "
	cSql += " B3X_STATUS = '" + PDTE_VALID + "' "
	cSql += " WHERE "
	cSql += "	B3X_FILIAL = '" + xFilial('B3X') + "' "
	cSql += "	AND B3X_BENEF = '" + PADL(AllTrim(Str(B3K->(Recno()))),10) + "' "
	cSql += "	AND B3X_STATUS IN  ('"+VALIDO+"','"+INVALIDO+"','"+CRIT_ANS+"')"
	cSql += "	AND B3X_OPERA  IN ('"+SIB_CANCELA+"','"+SIB_REATIVA+"')"

	nRet := TCSQLEXEC(cSql)
	If nRet >= 0
		if SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
			nRet := TCSQLEXEC("COMMIT")
		endif
	Else
		conout("TCSQLError() " + TCSQLError())
	Endif

Return nRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CnMvtoPdte

Funcao criada para deixar todos os movimentos (que não foram pra ANS) de um beneficiário pendentes de validação novamente.

@param nRecno		Recno do beneficiario

@return nRet		Retorno da instrucao delete, se menor que zero nao executou

@author TOTVS PLS Team
@since 16/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CnMvtoPdte(nRecno)
	Local cSql := ""
	Local nRet := 0

	cSql := " UPDATE " + RetSqlName('B3X')
	cSql += " SET "
	cSql += " B3X_STATUS = '" + PDTE_VALID + "' "
	cSql += " WHERE "
	cSql += "	B3X_FILIAL = '" + xFilial('B3X') + "' "
	cSql += "	AND B3X_BENEF = '" + PADL(AllTrim(Str(B3K->(Recno()))),10) + "' "
	cSql += "	AND B3X_STATUS IN  ('"+VALIDO+"','"+INVALIDO+"','"+CRIT_ANS+"')"

	nRet := TCSQLEXEC(cSql)
	If nRet >= 0 .AND. SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
		nRet := TCSQLEXEC("COMMIT")
	Endif

Return nRet


/*/{Protheus.doc} PLJOBNIO

Job de atualizacao do produto no NIO apos uma alteracao no PLS

@paramc cEmp		Empresa que iniciouo JOB
@paramc cFil		Filial que iniciouo JOB
@paramc cAlias		Nome da tabela que sera atualizada no NIO
@paramc aDados		Lista dos campos que serao atualizados
@paramc nOpcx		Operacao que sera executada
@paramc lMult		Indica se o JOB recebeu mais de um registro para atualizar
@paramc aOpc		Array com a operacao a executar para cada registro
@paramc dDataRef	Data de referencia recebida por parametro
@paramc lRotBloq	Em conjunto com lBloqueio indica se e uma operacao de bloqueio/desbloqueio
@paramc lBloqueio	Indicacao de bloqueio / desbloqueio do beneficiario
@paramc aDadCob	Matriz de cobertura do beneficiario
@paramc lTransf	Indica que e uma operacao de transferência de beneficiario
@paramc lManCCO	Indica que deve ser mantido o CCO e enviar apenas uma alteracao

@return lRet Retorna .T. Verdadeiro para atualizacao realizada com sucesso, senao retorna .F. Falso

@author TOTVS PLS Team
@since 08/01/2016
/*/
Function PLJOBNIO(cEmp,cFil,cAlias,aDados,nOpcx,lMult,aOpc,dDataRef,aDadCob,lSoVld,lEnvOpe)

	Local lRetorno		:= .T.
	Local nLen			:= 0
	Local nI				:= 0
	Local aCrit			:= {}

	Default aDados		:= {}
	Default nOpcx			:= K_Alterar
	Default aOpc			:= {}
	Default lMult			:= .F.
	Default dDataRef		:= dDataBase
	Default aDadCob		:= {}
	Default lSoVld		:= .F.
	Default lEnvOpe		:= .T.

	RpcSetType(3)
	RpcSetEnv(cEmp,cFil,,,'PLS')

	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Inicio PLJOBNIO",ARQUIVO_LOG)

	PlsAtuMonitor(1,"PLJOBNIO")

	If lMult

		nLen := len(aDados)

		For nI := 1 to nLen
			PLSAtuNIO(cAlias,aDados[nI],aOpc[nI],dDataRef,aDadCob[nI],aCrit,lSoVld,lEnvOpe)
		Next nI

	Else
		lRetorno := PLSAtuNIO(cAlias,aDados,nOpcx,dDataRef,aDadCob,aCrit,lSoVld,lEnvOpe)
	EndIf


	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Fim PLJOBNIO",ARQUIVO_LOG)

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlsAtuMonitor

Funcao criada para atualizar mensagem de observacao no servidor

@param nTerminal
@param cMsg			Mensagem informativa

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function PlsAtuMonitor(nTerminal,cMsg)
	Default nTerminal	:= 0
	Default cMsg			:= ""

	If nTerminal % 1 == 0

		PtInternal(1,AllTrim(cMsg))

	EndIf

Return Nil

/*
Chamada de funcoes para retirada de warnings de compilacao
*/
ChecErro()
