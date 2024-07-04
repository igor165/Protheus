#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FINA847.ch'

Static Function MenuDef()
Local aRotina	:= FWLoadMenuDef('FINA847')

Return aRotina


Static Function ModelDef()
Local oModel := FwLoadModel('FINA847')
Return oModel

Function FINA847RUS()
Local oBrowse := NIL
Private aRotina  :=  NIL
oBrowse := BrowseDef()
oBrowse:Activate()

Return

Static Function ViewDef()
Local oView		:= FWLoadView('FINA847')

//oView:AddUserButton(STR0030,'PAY', {||RU06S850("Changeable")}) //""
oView:SetViewProperty('VIEW_SEK2', "GRIDDOUBLECLICK",{{|oFormulario,cFieldName,nLineGrid,nLineModel| RUF050DbClk(oFormulario,cFieldName,nLineGrid,nLineModel)}})
Return oView

Static Function BrowseDef()
Local oBrowse := FWLoadBrw('FINA847')

Return oBrowse

Function RUF050DbClk(oFormulario,cFieldName,nLineGrid,nLineModel)
	
	Local oMdlSE2		:= Nil
	Local lRetorno	:= .T.
	
	Local aAreaSE2 := getArea()
	Local cPayment	:= ''
	Local cPayNum	:= ''
	Local cPrefix	:= ''
	Local cFornec	:= ''
	Local cLoja		:= ''
	Local cParcela	:= ''
	Local cTipo		:= ''
	Private cCadastro := ''
	
	Default oFormulario := Nil
	Default cFieldName  := ""
	Default nLineGrid   := 0
	Default nLineModel  := 0
	
	If cFieldName == "EK_NUM"
		cPayNum := PADR(oFormulario:GetModel("SEKDETAIL2"):GetValue("EK_NUM"),TamSx3("E2_NUM")[1])
		cPrefix := PADR(oFormulario:GetModel("SEKDETAIL2"):GetValue("EK_PREFIXO"),TamSx3("E2_PREFIXO")[1])
		cFornec := PADR(oFormulario:GetModel("SEKDETAIL2"):GetValue("EK_FORNECE"),TamSx3("E2_FORNECE")[1])
		cLoja	:= PADR(oFormulario:GetModel("SEKDETAIL2"):GetValue("EK_LOJA"),TamSx3("E2_LOJA")[1])
		cParcela:= PADR(oFormulario:GetModel("SEKDETAIL2"):GetValue("EK_PARCELA"),TamSx3("E2_PARCELA")[1])
		cTipo	:= PADR(oFormulario:GetModel("SEKDETAIL2"):GetValue("EK_TIPO"),TamSx3("E2_TIPO")[1])
		dbSelectArea('SE2')
		DbSetOrder(1)
		If DbSeek(xFilial('SE2')+cPrefix+cPayNum+cParcela+cTipo+cFornec+cLoja)	
			AxVisual('SE2',SE2->(Recno()),)
			//ConPad1(,,,"SEKPAY")                                                                                                 
			lRetorno := .F.
		EndIf
		RestArea(aAreaSE2)
	EndIf
	
Return lRetorno

//merge branch 12.1.19

// Russia_R5
