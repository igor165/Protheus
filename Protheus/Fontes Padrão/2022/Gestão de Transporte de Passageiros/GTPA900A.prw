#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA900A.CH"

/*/{Protheus.doc} GTPA900A()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 18/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function GTPA900A(oViewPai)
Local oModel := oViewPai:GetModel()

if !IsBlind()
	If oModel:GetModel('GY0MASTER'):GetValue('GY0_MOTREV') <> '2'
		FwAlertWarning(STR0003) //'Opção disponível apenas para revisões de reajuste'
	Else
		ExecView(oViewPai)
	Endif

	oViewPai:Refresh()
Else
	ExecView(oViewPai)
Endif

Return

/*/{Protheus.doc} ExecView()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 18/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function ExecView(oViewPai)
Local lRet 		:= .T.
Local oStruGYY 	:= FwFormStruct(2,'GYY')
Local oView 	:= Nil
Local oExecView := FwViewExec():New()
Local oModel	:= oViewPai:GetModel()
Local aButtons	:= {	{.F., Nil}, {.F., Nil}    		, {.F., Nil}    	, {.F., Nil}, {.F., Nil}, ;
                    	{.F., Nil}, {.T., STR0005}	, {.T., STR0006}	, {.F., Nil}, {.F., Nil}, ;	// "Confirmar", "Cancelar"
                    	{.F., Nil}, {.F., Nil}    		, {.F., Nil}    	, {.F., Nil}	}

oView := FwFormView():New(oViewPai)
oView:SetModel(oModel)
oView:SetOperation(oViewPai:GetOperation())

oView:AddField('VIEW_HEADER' ,oStruGYY,'GYYFIELDS')
oView:CreateHorizontalBox('TELA', 100)
oView:SetOwnerView('VIEW_HEADER','TELA')

oStruGYY:AddGroup('CONTRATO', '', '', 2)
oStruGYY:SetProperty("GYY_NUMERO", MVC_VIEW_GROUP_NUMBER, "CONTRATO")
oStruGYY:SetProperty("GYY_REVISA", MVC_VIEW_GROUP_NUMBER, "CONTRATO")

oStruGYY:AddGroup('PERCENTUAIS'	, STR0001, '', 2) // 'Percentuais do Reajuste'
oStruGYY:SetProperty("GYY_PERGYD", MVC_VIEW_GROUP_NUMBER, "PERCENTUAIS" )
oStruGYY:SetProperty("GYY_PERGQJ", MVC_VIEW_GROUP_NUMBER, "PERCENTUAIS" )
oStruGYY:SetProperty("GYY_PERGYX", MVC_VIEW_GROUP_NUMBER, "PERCENTUAIS" )
oStruGYY:SetProperty("GYY_PERGQZ", MVC_VIEW_GROUP_NUMBER, "PERCENTUAIS" )

oView:SetViewAction( 'BUTTONOK' , { |oView| AplicaReaj(oView)})

//Proteção para execução com View ativa.
If oModel != Nil .And. oModel:isActive()
	oExecView:SetModel(oModel)
	oExecView:SetView(oView)
	oExecView:SetTitle(STR0002) //'Reajuste'
	oExecView:SetOperation(oViewPai:GetOperation())
	oExecView:SetReduction(70)
	oExecView:SetCloseOnOk({|| .T.})
	oExecView:SetOk({ || AplicaReaj(oView)})
	oExecView:SetButtons(aButtons)

	IF !IsBlind()
  		oExecView:OpenView(.F.)
  
  		If oExecView:GetButtonPress() == VIEW_BUTTON_OK
    		lRet := .T.
  		Endif
	Endif
EndIf

Return lRet

/*/{Protheus.doc} AplicaReaj()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 18/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function AplicaReaj(oView)
Local oModel	:= oView:GetModel()
Local oMdlBase	:= FwLoadModel('GTPA900')
Local lRet 		:= .T.
Local nPercGQJ	:= oModel:GetModel('GYYFIELDS'):GetValue('GYY_PERGQJ')
Local nPercGYD	:= oModel:GetModel('GYYFIELDS'):GetValue('GYY_PERGYD')
Local nPercGYX	:= oModel:GetModel('GYYFIELDS'):GetValue('GYY_PERGYX')
Local nPercGQZ	:= oModel:GetModel('GYYFIELDS'):GetValue('GYY_PERGQZ')
Local nVlrGQJ	:= 0
Local nVlrGYD	:= 0
Local nVlrExt	:= 0
Local nVlrGYX	:= 0
Local nVlrGQZ	:= 0
Local nQtdGQJ	:= 0
Local nQtdGYX	:= 0
Local nQtdGQZ	:= 0
Local nX		:= 0
Local nY		:= 0

dbSelectArea('GY0')
GY0->(DbSetOrder(1))

If GY0->(dbSeek(xFilial('GY0')+oModel:GetModel('GY0MASTER'):GetValue('GY0_NUMERO')+'1'))
	oMdlBase:SetOperation(MODEL_OPERATION_VIEW)
	oMdlBase:Activate()
Endif

For nX := 1 To oMdlBase:GetModel('GQJDETAIL'):Length()
	nVlrGQJ := oMdlBase:GetModel('GQJDETAIL'):GetValue('GQJ_CUSUNI', nX)
	nQtdGQJ := oMdlBase:GetModel('GQJDETAIL'):GetValue('GQJ_QUANT', nX)
	nVlrGQJ += Round(nVlrGQJ * (nPercGQJ / 100), 2)
	oModel:GetModel('GQJDETAIL'):GoLine(nX)
	oModel:GetModel('GQJDETAIL'):ForceValue('GQJ_CUSUNI', nVlrGQJ)
	oModel:GetModel('GQJDETAIL'):ForceValue('GQJ_VALTOT', (nQtdGQJ * nVlrGQJ))
Next

For nX := 1 To oMdlBase:GetModel('GYDDETAIL'):Length()
	nVlrGYD := oMdlBase:GetModel('GYDDETAIL'):GetValue('GYD_VLRTOT', nX)
	nVlrExt := oMdlBase:GetModel('GYDDETAIL'):GetValue('GYD_VLREXT', nX)
	nVlrGYD += Round(nVlrGYD * (nPercGYD / 100), 2)
	nVlrExt += Round(nVlrExt * (nPercGYD / 100), 2)
	oModel:GetModel('GYDDETAIL'):GoLine(nX)
	oModel:GetModel('GYDDETAIL'):ForceValue('GYD_VLRTOT', nVlrGYD)
	oModel:GetModel('GYDDETAIL'):ForceValue('GYD_VLREXT', nVlrExt)

	For nY := 1 To oMdlBase:GetModel('GYXDETAIL'):Length()
		nVlrGYX := oMdlBase:GetModel('GYXDETAIL'):GetValue('GYX_CUSUNI', nY)
		nQtdGYX := oMdlBase:GetModel('GYXDETAIL'):GetValue('GYX_QUANT', nY)
		nVlrGYX += Round(nVlrGYX * (nPercGYX / 100), 2)
		oModel:GetModel('GYXDETAIL'):GoLine(nY)
		oModel:GetModel('GYXDETAIL'):ForceValue('GYX_CUSUNI', nVlrGYX)
		oModel:GetModel('GYXDETAIL'):ForceValue('GYX_VALTOT', (nQtdGYX * nVlrGYX))
	Next

	For nY := 1 To oMdlBase:GetModel('GQZDETAIL'):Length()
		nVlrGQZ := oMdlBase:GetModel('GQZDETAIL'):GetValue('GQZ_CUSUNI', nY)
		nQtdGQZ := oMdlBase:GetModel('GQZDETAIL'):GetValue('GQZ_QUANT', nY)
		nVlrGQZ += Round(nVlrGQZ * (nPercGQZ / 100), 2)
		oModel:GetModel('GQZDETAIL'):GoLine(nY)
		oModel:GetModel('GQZDETAIL'):ForceValue('GQZ_CUSUNI', nVlrGQZ)
		oModel:GetModel('GQZDETAIL'):ForceValue('GQZ_VALTOT', (nQtdGQZ * nVlrGQZ))
	Next

Next

FwAlertSuccess(STR0004) //"Reajuste aplicado") 

oMdlBase:DeActivate()
oMdlBase:Destroy()

Return lRet
 
