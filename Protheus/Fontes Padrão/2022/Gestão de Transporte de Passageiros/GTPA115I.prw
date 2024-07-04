#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

Function GTPA115I()

FWExecView('Inutilização de Bilhetes',"VIEWDEF.GTPA115I",MODEL_OPERATION_INSERT,,{|| .T.},,75)

Return

Static Function ViewDef()
Local oView		:= nil
Local oModel	:= FwLoadModel("GTPA115")
Local oStrVGIC	:= FWFormStruct( 2, "GIC",{|x| AllTrim(x)+"|"  $  'GIC_TIPO|GIC_AGENCI|GIC_DESAGE|GIC_TIPDOC|GIC_SERIE|GIC_SUBSER|'+;
                                                                    'GIC_NUMCOM|GIC_NUMDOC|GIC_DTVEND|GIC_COLAB|GIC_NCOLAB|' } )	//Bilhetes
Local oStrMGIC	:= oModel:GetModel('GICMASTER'):GetStruct()


SetModelStruct(oStrMGIC)
SetViewStruct(oStrVGIC)

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:AddField("VIEW_GIC", oStrVGIC, "GICMASTER" )

// Divisão Horizontal
oView:CreateHorizontalBox( 'SUPERIOR'  	, 100)

oView:SetOwnerView("VIEW_GIC", "SUPERIOR")

Return oView


Static Function SetViewStruct(oStrVGIC)
Local aTipos	:= GTPXCBox('GIC_TIPO')
Local nPos		:= 0
While (nPos := aScan(aTipos,{|x| !( SUBSTR(x,1,1) $ 'E/M') } ) )  > 0
	aDel(aTipos,nPos)
	aSize(aTipos,Len(aTipos)-1)
EndDo 

oStrVGIC:SetProperty('GIC_TIPO',MVC_VIEW_COMBOBOX,aTipos)

oStrVGIC:SetProperty('GIC_AGENCI'	,MVC_VIEW_ORDEM,'01')
oStrVGIC:SetProperty('GIC_DESAGE'	,MVC_VIEW_ORDEM,'02')
oStrVGIC:SetProperty('GIC_DTVEND'	,MVC_VIEW_ORDEM,'03')
oStrVGIC:SetProperty('GIC_COLAB'	,MVC_VIEW_ORDEM,'04')
oStrVGIC:SetProperty('GIC_NCOLAB'	,MVC_VIEW_ORDEM,'05')
oStrVGIC:SetProperty('GIC_TIPO'		,MVC_VIEW_ORDEM,'06')
oStrVGIC:SetProperty('GIC_TIPDOC'	,MVC_VIEW_ORDEM,'07')
oStrVGIC:SetProperty('GIC_SERIE'	,MVC_VIEW_ORDEM,'08')
oStrVGIC:SetProperty('GIC_SUBSER'	,MVC_VIEW_ORDEM,'09')
oStrVGIC:SetProperty('GIC_NUMCOM'	,MVC_VIEW_ORDEM,'10')
oStrVGIC:SetProperty('GIC_NUMDOC'	,MVC_VIEW_ORDEM,'11')

oStrVGIC:SetProperty('GIC_SUBSER'	,MVC_VIEW_CANCHANGE,.F.)
oStrVGIC:SetProperty('GIC_NUMCOM'	,MVC_VIEW_CANCHANGE,.F.)

Return

Static Function SetModelStruct(oStrMGIC)

oStrMGIC:SetProperty('GIC_TIPO'		,MODEL_FIELD_INIT,{|| 'M' })//TIPO MANUAL
oStrMGIC:SetProperty('GIC_STATUS'	,MODEL_FIELD_INIT,{|| 'I' })//INUTILIZADO

oStrMGIC:SetProperty('*'			,MODEL_FIELD_OBRIGAT,.F.)

oStrMGIC:SetProperty('GIC_AGENCI'	,MODEL_FIELD_OBRIGAT,.T.)
oStrMGIC:SetProperty('GIC_DTVEND'	,MODEL_FIELD_OBRIGAT,.T.)
oStrMGIC:SetProperty('GIC_COLAB'	,MODEL_FIELD_OBRIGAT,.T.)
oStrMGIC:SetProperty('GIC_TIPO'		,MODEL_FIELD_OBRIGAT,.T.)
oStrMGIC:SetProperty('GIC_TIPDOC'	,MODEL_FIELD_OBRIGAT,.T.)
oStrMGIC:SetProperty('GIC_SERIE'	,MODEL_FIELD_OBRIGAT,.T.)
oStrMGIC:SetProperty('GIC_NUMDOC'	,MODEL_FIELD_OBRIGAT,.T.)


Return