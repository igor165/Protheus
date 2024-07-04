#Include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA283
Cadastro de Requisições - Conferencia (habilitação de campo)
@author  SIGAGTP   
@since   07/08/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FwLoadView('GTPA283')
Local oStrGQW	:= oView:GetViewStruct('VIEW_GQW') 

oStrGQW:SetProperty('*'         , MVC_VIEW_CANCHANGE, .F. )
oStrGQW:SetProperty("GQW_CONFER", MVC_VIEW_CANCHANGE, .T. )

oView:SetNoInsertLine("GRIDGIC")
oView:SetNoDeletLine("GRIDGIC")

Return oView
