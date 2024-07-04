#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA813C.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA813c
Função responsavel pela definição da view
@type Function
@author jacomo.fernandes
@since 12/11/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Function GTPA813c()
Local aButtons  := GtpBtnView()

If (GI9->GI9_STATRA <> "6") 
	If GI9->GI9_STATUS == "1"
		FWExecView(STR0001,"VIEWDEF.GTPA813C",MODEL_OPERATION_INSERT, /*oDlg*/, /*bCloseOk*/,/*bOk*/,75/*nPercRed*/,aButtons)//"Cancelamento"
	Else
		FwAlertHelp(STR0002,STR0003,STR0004)//"Não é possivel realizar a operação de cancelamento em um manifesto que não se encontra em Aberto","Verifique o registro selecionado","Atenção")
	Endif
Else
	FwAlertHelp(STR0005)//'Não Existem Eventos para Manifestos Operacionais'
	Return
EndIf

Return 
	
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author jacomo.fernandes
@since 25/11/2019
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= FwLoadModel('GTPA813')
Local oMdlGIK	:= oModel:GetModel('GIKMASTER')
Local oStrGIK	:= oMdlGIK:GetStruct()


oStrGIK:DeActivate()

oStrGIK:SetProperty('GIK_TPEVEN',MODEL_FIELD_INIT,{||'1'})
GTPxCriaCpo(oStrGIK,{"GI9_OBSERV"},.T.)
oStrGIK:SetProperty('GI9_OBSERV',MODEL_FIELD_OBRIGAT,.T.)

oStrGIK:Activate()


Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author jacomo.fernandes
@since 25/11/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPA813C')

oView:SetModel(oModel)

oView:AddOtherObject("VIEW_GIK", {|oPanel| ShowMemoPanel(oPanel,oView)})

oView:CreateHorizontalBox('TELA', 100)

oView:SetOwnerView('VIEW_GIK','TELA')

oView:SetDescription(STR0001) //'Cancelamento'

Return oView



/*/{Protheus.doc} ShowMemoPanel
(long_description)
@type function
@author jacomo.fernandes
@since 01/02/2019
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ShowMemoPanel(oPanel,oView)
Local oMdlGIK		:= oView:GetModel('GIKMASTER')
Local aClientRect	:= oPanel:GetClientRect()
Local nRow			:= aClientRect[1]+2
Local nCol			:= aClientRect[2]+2
Local nWidth		:= Round(aClientRect[3]*0.493,0)
Local nHeight		:= Round(aClientRect[4]*0.485,0)
Local bSetGet		:=  { | U |If(ValType(oMdlGIK)=="O" .and. oMdlGIK:IsActive(),IF( PCOUNT() == 0, oMdlGIK:GetValue('GI9_OBSERV'),  oMdlGIK:SetValue('GI9_OBSERV', U )),U  )  }
Local oFont 		:= TFont():New('Courier new',,-16,.F.)
Local oMemo			:= TMultiGet():Create( oPanel, bSetGet, nRow,  nCol, nWidth, nHeight, oFont,,,,, .T. )

oMemo:EnableVSCroll(.T.)
Return
