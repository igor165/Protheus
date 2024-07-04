#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OMSXCPL4.CH"

Static _oBrwCPL4

/*/{Protheus.doc} OMSXCPL4
	Listagem de registro de falhas de envio de mensagem
@author siegklenes.beulke
@since 09/12/2015
@version 1.0
/*/
Function OMSXCPL4(cTab)
	Local aRotina := MenuDef()
	Local nX
	Default cTab := ''

	If SuperGetMv("MV_CPLSTP",.F.,"2") == "1"
		MsgInfo(STR0001) // "Integração com o Cockpit Logístico suspensa."
		Return
	EndIf

	_oBrwCPL4 := FWMBrowse():New()
	_oBrwCPL4:SetAlias("DJW")
	_oBrwCPL4:SetMenuDef("")
	For nX := 1 To Len(aRotina)
		If "VIEWDEF" $ aRotina[nX][2]
			_oBrwCPL4:AddButton(aRotina[nX][1],&("{|| FwExecView('" + aRotina[nX][1] + "','" + StrToKarr(aRotina[nX][2],'.')[2] + "'," + If(aRotina[nX][4] == 2,'',cValToChar(aRotina[nX][4])) + ")}") ,,aRotina[nX][4],,.F.)
		Else
			If At("(",aRotina[nX][2]) == 0
				aRotina[nX][2] += "()"
			EndIf
			_oBrwCPL4:AddButton(aRotina[nX][1],&("{|| " + aRotina[nX][2] + "}") ,,aRotina[nX][4],,.F.)
		EndIf
	Next nX
	If Empty(cTab)
		_oBrwCPL4:SetFilterDefault("DJW_TPREG = '2'")
		_oBrwCPL4:SetOnlyFields( { 'DJW_FILIAL', 'DJW_CDREG', 'DJW_TABELA', 'DJW_CHAVE', 'DJW_RECTAB', 'DJW_USRREG' , 'DJW_HORA' , 'DJW_DATA' , 'DJW_USRREG' } )
		_oBrwCPL4:SetDescription(STR0002) // "Registro de falhas de envio de mensagem"
	Else
		_oBrwCPL4:AddLegend("DJW_SITENV = '0'", "BLACK", STR0003, "SITENV") // "Falha de envio da mensagem"
		_oBrwCPL4:AddLegend("DJW_SITENV = '1'", "GREEN", STR0004, "SITENV") // "Sucesso no envio do e-mail"
		_oBrwCPL4:AddLegend("DJW_SITENV = '2'", "RED"  , STR0005, "SITENV") // "Falha no envio do e-mail"
		_oBrwCPL4:AddLegend("DJW_TPREG = '1'", "BLACK", STR0006, "TPREG") // "Falhas de conexão"
		_oBrwCPL4:AddLegend("DJW_TPREG = '2'", "RED"  , STR0007, "TPREG") // "Falhas de transmissão"
		_oBrwCPL4:SetFilterDefault("DJW_TABELA = '" + cTab + "'")
		If cTab == "DT6"
			_oBrwCPL4:SetDescription(STR0008) // "Registro de falhas de documentos"
		Else
			_oBrwCPL4:SetDescription(STR0009) // "Registro de falhas"
		EndIf
	EndIf
	_oBrwCPL4:Activate()
	OMSXCLRCH()
	_oBrwCPL4 := Nil
Return

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0010 ACTION "AxPesqui"                   OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0011 ACTION "VIEWDEF.OMSXCPL4"           OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0012 ACTION "VIEWDEF.OMSXCPL4"           OPERATION 5 ACCESS 0 // "Excluir"
	ADD OPTION aRotina TITLE STR0013 ACTION "OMSXCPL4DEL()"              OPERATION 5 ACCESS 0 DISABLE MENU // "Excluir Todos"
	ADD OPTION aRotina TITLE STR0014 ACTION "OMSXCPL401_REENVIAR()"      OPERATION 4 ACCESS 0 DISABLE MENU // "Reenviar"
	ADD OPTION aRotina TITLE STR0015 ACTION "OMSXCPL402_REENVIARTODOS()" OPERATION 4 ACCESS 0 DISABLE MENU // "Reenviar Todos"


Return aRotina

Static Function ModelDef()

Local oModel
Local oStructDJW := FWFormStruct(1,"DJW")

// cID     Identificador do modelo
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição

oModel := MPFormModel():New("OMSXCPL4", /*bPre*/, /* bPost*/, /*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição

oModel:AddFields("OMSXCPL4_DJW", Nil, oStructDJW,/*bPre*/,/*bPost*/,/*bLoad*/)

oModel:SetDescription( STR0016 ) // "Registro de falha de envio de mensagem"
oModel:GetModel( "OMSXCPL4_DJW" ):SetDescription( STR0016 ) // "Registro de falha de envio de mensagem"

oModel:SetPrimaryKey({"DJW_FILIAL", "DJW_CDREG"})


Return oModel

Static Function ViewDef()
Local oModel := FWLoadModel("OMSXCPL4")
Local oStructDJW := FWFormStruct(2,"DJW")
Local oView := FWFormView():New()

oStructDJW:RemoveField("DJW_FILIAL")
oStructDJW:RemoveField("DJW_SITENV")
oStructDJW:RemoveField("DJW_MSGENV")

oView:SetModel(oModel)

oView:AddField("OMSXCPL4_DJW", oStructDJW)

oView:CreateHorizontalBox("MASTER", 100)

oView:SetOwnerView("OMSXCPL4_DJW", "MASTER")

Return oView
/*/{Protheus.doc} OMSXCPL4REG
	Registra falha de transmissão
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param oData, object, Instância da classe OMSXCPL3CLS
@example
(examples)
@see (links_or_references)
/*/
Function OMSXCPL4REG(oData)
	Local aAreaDJW := DJW->(GetArea())
	Local aArea	 := GetArea()

	OMSXCPL4VER(oData)
	oData:TPREG  := "2"
	OMSXCPL3GRV(oData)
	RestArea(aAreaDJW)
	RestArea(aArea)
Return oData

//Verifica e elimina registro de falha de transmissão existente
Function OMSXCPL4VER(oData)
	Local ax3
	Local lDeletou := .F.
	Static __nTamREC1
	Static __nTamREC2

	If Empty(__nTamREC1)
		ax3 := TamSx3("DJW_RECTAB")
		__nTamREC1 := ax3[1]
		__nTamREC2 := ax3[2]
	EndIf

	dbSelectArea("DJW")
	DJW->(dbsetorder(3))
	If DJW->(dbSeek(oData:TABELA+STR(oData:RECTAB,__nTamREC1,__nTamREC2)))
		RecLock("DJW",.F.)
		dbDelete()
		MsUnLock("DJW")
		lDeletou := .T.
	EndIf

Return lDeletou
/*/{Protheus.doc} OMSXCPL401_REENVIAR
	Reenvia o registro de falha de tranmissão
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param nRecno, numeric, descricao
@example
(examples)
@see (links_or_references)
/*/
Function OMSXCPL401_REENVIAR(nRecno)
	Local cTabela
	Local nRecTab
	Local aArea := GetArea()
	Local lRet := .F.

	If !Empty(nRecno)
		DJW->(dbGoto(nRecno))
		If DJW->DJW_TPREG != '2'
			Return .T.
		EndIf
	ElseIf DJW->DJW_TPREG != '2'
		MsgAlert(STR0017) // "Não é possível reenviar registros de falha de conexão"
		Return .T.
	EndIf

	cTabela := DJW->DJW_TABELA
	nRecTab := DJW->DJW_RECTAB

	dbSelectArea(cTabela)
	(cTabela)->(dbGoTo(nRecTab))
	lRet := OMSXCPLENVIA(cTabela,If(DJW->DJW_ACAO == "2",5,4))
	If lRet
		dbSelectArea("DJW")

		RecLock("DJW",.F.)
		dbDelete()
		MsUnlock("DJW")

		If Empty(nRecno)
			MsgInfo(STR0018) // "Registro reenviado com sucesso"
		EndIf
	Else
		If Empty(nRecno)
			MsgInfo(STR0019) // "Falha ao reenviar o registro. Foi gerado um novo registro de falha de conexão."
		EndIf
	EndIf

	If !Empty(nRecno)
		RestArea(aArea)
	Else
		_oBrwCPL4:Refresh()
	EndIf

Return lRet
/*/{Protheus.doc} OMSXCPL402_REENVIARTODOS
	Reenvia todos os registros de falha de tranmissão
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function OMSXCPL402_REENVIARTODOS(lAutom)
	Local lBlind := isBlind()
	DEFAULT lAutom := .F.

	If lBlind
		OmsLogMsg("[OMSXCPL402_REENVIARTODOS] " + STR0020) // "Reenviando registro(s) ao Cockpit Logístico"
		ReenviaProc(lBlind)
	Else
		Processa({||ReenviaProc(lBlind)},STR0020, STR0021) // "Reenviando registro(s) ao Cockpit Logístico" ## "Aguarde"
	EndIf
	DJW->(dbGotop())

	If !lAutom
		_oBrwCPL4:Refresh()
	EndIf

Return
/*/{Protheus.doc} ReenviaProc
	Processo responsável por reenvio de registro de falha de conexão.
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param lBlind, logical, Caso o processo seja executado sem tela.
@example
(examples)
@see (links_or_references)
/*/
Static Function ReenviaProc(lBlind)

	Local nX := 0
	Local nY := 0
	Local lTodos := .T.
	Local nEnv := 0
	Local cQuery := "SELECT R_E_C_N_O_ FROM " + RetSqlName("DJW") + " WHERE DJW_TPREG = '2' AND D_E_L_E_T_ = ''"
	Local cAl := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAl, .T., .T. )

	While !(cAl)->(Eof())
		nY++
		(cAl)->(dbSkip())
	EndDo

	If !lBlind
		ProcRegua(nY)
	EndIf

	(cAl)->(dbGoTop())
	While !(cAl)->(Eof())
		nX++
		If !lBlind
			IncProc(STR0022 + AllTrim(Str(nX)) + STR0023 + AllTrim(Str(nY)) + "...") // "Registro " ## " de "
		ElseIf nX == 1 .Or. Mod(nX,10) == 0
			OmsLogMsg(STR0022 + AllTrim(Str(nX)) + STR0023 + AllTrim(Str(nY)) + "...") // "Registro " ## " de "
		EndIf
		If !OMSXCPL401_REENVIAR((cAl)->R_E_C_N_O_)
			lTodos := .F.
		Else
			nEnv++
		EndIf
		(cAl)->(dbSkip())
	EndDo

	(cAl)->(dbCloseArea())
	If lBlind
		OmsLogMsg(AllTrim(Str(nEnv)) + STR0023 + AllTrim(Str(nY)) + STR0024) // " de " ## " foram reenviados com sucesso"
	Else
		If lTodos
			MsgInfo(STR0025) // "Todos os registros foram reenviados com sucesso"
		Else
			MsgInfo(AllTrim(Str(nEnv)) + STR0023 + AllTrim(Str(nY)) + STR0024) // " de " ## " foram reenviados com sucesso"
		EndIf
	EndIf
Return
/*/{Protheus.doc} OMSXCPL4DEL
	Exclui todos os registros de falhas de envio de mensagem
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function OMSXCPL4DEL()
Local cSeek
Local aAreaDJW := DJW->(GetArea())

	If MsgYesNo(STR0026) // "Esta ação irá excluir todos os registros de falhas de envio de mensagem . Deseja continuar?"
		dbSelectArea("DJW")
		DJW->(dbSetOrder(6))
		cSeek := xFilial("DJW") + '2'
		DJW->(dbSeek(cSeek))
		While !DJW->(Eof()) .And. cSeek ==  DJW->(DJW_FILIAL+DJW_TPREG)
			RecLock("DJW",.F.)
			dbDelete()
			MsUnLock()
			DJW->(dbSkip())
		EndDo
	EndIf

RestArea(aAreaDJW)
Return

Static Function OmsLogMsg(cMsg)

	FWLogMsg("INFO", "", "BusinessObject", "OMSXCPL", "", "", cMsg, 0, 0)

Return
