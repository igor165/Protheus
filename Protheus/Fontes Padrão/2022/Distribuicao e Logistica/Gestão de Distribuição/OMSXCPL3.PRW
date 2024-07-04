#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OMSXCPL3.CH"

/*/{Protheus.doc} OMSXCPL3
	Listagem de registro de falhas de conexão
@author siegklenes.beulke
@since 09/12/2015
@version 1.0
/*/

Function OMSXCPL3()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("DJW")
	oBrowse:SetMenuDef("OMSXCPL3")
	oBrowse:AddLegend("DJW_SITENV == '1'", "GREEN", STR0001) // "Sucesso no envio do e-mail"
	oBrowse:AddLegend("DJW_SITENV == '2'", "RED"  , STR0002) // "Falha no envio do e-mail"
	oBrowse:SetFilterDefault("DJW_TPREG = '1'")
	oBrowse:SetOnlyFields( { 'DJW_FILIAL', 'DJW_CDREG', 'DJW_USRREG' , 'DJW_HORA' , 'DJW_DATA' , 'DJW_USRREG' } )
	oBrowse:SetDescription(STR0003) // "Registro de falhas de conexão"

	oBrowse:Activate()
Return

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0004 ACTION "AxPesqui"         OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.OMSXCPL3" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.OMSXCPL3" OPERATION 5 ACCESS 0 // "Excluir"
	ADD OPTION aRotina TITLE STR0007 ACTION "OMSXCPL3DEL()"    OPERATION 5 ACCESS 0 // "Excluir Todos"

Return aRotina

Static Function ModelDef()

Local oModel
Local oStructDJW := FWFormStruct(1,"DJW")

// cID     Identificador do modelo
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição

oModel := MPFormModel():New("OMSXCPL3", /*bPre*/, /* bPost*/, /*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição

oModel:AddFields("OMSXCPL3_DJW", Nil, oStructDJW,/*bPre*/,/*bPost*/,/*bLoad*/)

oModel:SetDescription( STR0008 ) // "Registro de falha de conexão"
oModel:GetModel( "OMSXCPL3_DJW" ):SetDescription( STR0008 ) // "Registro de falha de conexão"

oModel:SetPrimaryKey({"DJW_FILIAL", "DJW_CDREG"})


Return oModel

Static Function ViewDef()
Local oModel := FWLoadModel("OMSXCPL3")
Local oStructDJW := FWFormStruct(2,"DJW")
Local oView := FWFormView():New()

oStructDJW:RemoveField("DJW_FILIAL")
oStructDJW:RemoveField("DJW_TABELA")
oStructDJW:RemoveField("DJW_CHAVE" )
oStructDJW:RemoveField("DJW_RECTAB")
oStructDJW:RemoveField("DJW_TPREG" )
oStructDJW:RemoveField("DJW_MSGREG")

oView:SetModel(oModel)

oView:AddField("OMSXCPL3_DJW", oStructDJW)

oView:CreateHorizontalBox("MASTER", 100)

oView:SetOwnerView("OMSXCPL3_DJW", "MASTER")

Return oView
/*/{Protheus.doc} OMSXCPL3REG
	Registra falha de conexão e envia um e-mail para o adminstrador
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param oData, object, Instância da classe OMSXCPL3CLS
@param cMsgExt, characters, Mensagem de erro externa à falha de conexão
@example
(examples)
@see (links_or_references)
/*/
Function OMSXCPL3REG(oData,cMsgExt)
	Local cMsg := STR0009 + SuperGetMv("MV_CPLURL",.F., "") + CRLF + ". " + STR0010 + cValToChar(cMsgExt) // "Falha ao conectar no Web Service " ## "Motivo: "
	Private aRetMail

	oData:TPREG  := "1"
	If !IsBlind()
		MsgRun(STR0011, STR0012, {||aRetMail := GFEMail(SuperGetMv("MV_CPLMAL",.F.,""), STR0013, cMsg, .F., {})}) // "Enviando e-mail ao administrador." ## "Aguarde" ## "Integração Protheus X CPL - Registro de falha"
	Else
		OmsLogMsg(STR0011) // "Enviando e-mail ao administrador."
		aRetMail := GFEMail(SuperGetMv("MV_CPLMAL",.F.,""), STR0013, cMsg, .F., {}) // "Integração Protheus X CPL - Registro de falha"
	EndIf

	If aRetMail[1]
		oData:SITENV := "1"
		oData:MSGENV := STR0014 + SuperGetMv("MV_CPLMAL",.F.,"") + CRLF + STR0015 + cValToChar(cMsgExt) // "E-mail enviado com sucesso para o destinatário " ## "motivo do envio: "
		If IsBlind()
			OmsLogMsg(STR0016) // "E-mail enviado com sucesso"
		EndIf
	Else
		oData:SITENV := "2"
		oData:MSGENV := STR0017 + SuperGetMv("MV_CPLMAL",.F.,"") + CRLF + STR0010 + aRetMail[2] // "Falha ao enviar o e-mail para o destinatário " ## "Motivo: "
		If IsBlind()
			OmsLogMsg(STR0018 + aRetMail[2] + STR0019 + cMsg) // "Falha ao enviar o e-mail: " ## " Mensagem: "
		EndIf
	EndIf

	OMSXCPL3GRV(oData)

Return oData
/*/{Protheus.doc} OMSXCPL3GRV
	Grava efetivamente a falha ocorrida
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param oData, object, Instância da classe OMSXCPL3CLS
@example
(examples)
@see (links_or_references)
/*/
Function OMSXCPL3GRV(oData)
	Local nSaveSX8 := GetSx8Len()
	Local cAliasSv := Alias()

	If oData:TABELA == "DUD"
		If DUD->(RecNo()) != oData:RECTAB
			DUD->(dbGoTo(oData:RECTAB))
		EndIf
		dbSelectArea('DUD')
		If RecLock("DUD",.F.)
			If DUD->DUD_SITCPL == '1'
				DUD->DUD_SITCPL := '3'
			EndIf
			DUD->DUD_DATCPL := DATE()
			DUD->DUD_HORCPL := StrTran(Substr(TIME(),1,5),':','')
			DUD->DUD_MSGCPL := oData:MSGREG
		EndIf
		MsUnlock()
	EndIf

	If oData:lDJW
		dbSelectArea("DJW")
		If Empty(oData:CDREG)
			oData:CDREG := GetSxeNum("DJW","DJW_CDREG")
		EndIf

		RecLock("DJW",.T.)
		DJW->DJW_FILIAL := oData:FILIAL
		DJW->DJW_CDREG  := oData:CDREG
		DJW->DJW_TABELA := oData:TABELA
		DJW->DJW_CHAVE  := oData:CHAVE
		DJW->DJW_RECTAB := oData:RECTAB
		DJW->DJW_USRREG := oData:USRREG
		DJW->DJW_ACAO	:= oData:ACAO
		DJW->DJW_DATA   := oData:DATA
		DJW->DJW_HORA   := oData:HORA
		DJW->DJW_TPREG  := oData:TPREG
		DJW->DJW_MSGREG := oData:MSGREG
		DJW->DJW_SITENV := oData:SITENV
		DJW->DJW_MSGENV := oData:MSGENV
		MsUnlock("DJW")
	EndIf
	If __lSX8
		While ( GetSx8Len() > nSaveSX8 )
			ConfirmSx8()
		Enddo
	EndIf

	If !Empty(cAliasSv)
		dbSelectArea(cAliasSv)
	EndIf
Return
/*/{Protheus.doc} OMSXCPL3CLS
	Classe que guarda os atributos reflexos da gravação de registros de falhas
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
CLASS OMSXCPL3CLS
	DATA FILIAL
	DATA CDREG
	DATA TABELA
	DATA CHAVE
	DATA RECTAB
	DATA ACAO
	DATA USRREG
	DATA DATA
	DATA HORA
	DATA TPREG
	DATA MSGREG
	DATA SITENV
	DATA MSGENV
	DATA lDJW
	METHOD New() CONSTRUCTOR
ENDCLASS

METHOD New() Class OMSXCPL3CLS

	//Defaults
	::FILIAL := xFilial("DJW")
	::CDREG  := ""
	::TABELA := ""
	::CHAVE  := ""
	::RECTAB := 0
	::ACAO   := '1'
	::USRREG := cUserName
	::DATA   := Date()
	::HORA   := StrTran(Time(),":","")
	::TPREG  := "0"
	::MSGREG := ""
	::SITENV := "0"
	::MSGENV := ""
	::lDJW := .T.

Return Self
/*/{Protheus.doc} OMSXCPL3DEL
	Excluí o todos os registros de falhas de conexão
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function OMSXCPL3DEL()
Local cSeek
Local aAreaDJW := DJW->(GetArea())

	If MsgYesNo(STR0020) // "Esta ação irá excluir todos os registros de falhas de conexão. Deseja continuar?"
		dbSelectArea("DJW")
		DJW->(dbSetOrder(6))
		cSeek := xFilial("DJW") + '1'
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
