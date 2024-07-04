#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPA117.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"                 
#include "TbIconn.ch"
#include "TopConn.ch"


Function PCPA117()
	Local aArea   := GetArea()
	Local oBrowse
	oBrowse := BrowseDef()
	oBrowse:Activate()	
	RestArea(aArea)

Return NIL

Static Function BrowseDef()
	Local oBrowse
	oBrowse := FWMBrowse():New()	
	oBrowse:SetAlias('SVI')
	oBrowse:SetDescription(STR0001)//"Cadastro de Operações"
	
Return oBrowse

Static Function ModelDef()
	Local oModel 	
	Local oStruSVI := FWFormStruct( 1, 'SVI' )
	Local oEvent    := PCPA117EVDEF():New()
	
	oStruSVI:SetProperty( 'VI_CODIGO' , MODEL_FIELD_NOUPD,.T.)
	oModel := MPFormModel():New('PCPA117' )
	oModel:AddFields( 'SVIMASTER', /*cOwner*/, oStruSVI)
	oModel:SetDescription( STR0001 )//"Cadastro de Operações"
	oModel:GetModel( 'SVIMASTER' ):SetDescription(STR0001)//"Cadastro de Operações"
	oModel:SetPrimaryKey({'VI_CODIGO'})
	
	oModel:InstallEvent("PCPA117EVDEF", /*cOwner*/, oEvent)
	
Return oModel

Static Function ViewDef()	
	
	Local oModel := FWLoadModel( 'PCPA117' )
	Local oStruSVI := FWFormStruct( 2, 'SVI')
	Local oView
	
	oView :=FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( 'VIEW_SVI', oStruSVI, 'SVIMASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_SVI', 'TELA' )
	
Return oView

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.PCPA117' OPERATION OP_VISUALIZAR ACCESS 0 //VISUALIZAR
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.PCPA117' OPERATION OP_INCLUIR    ACCESS 0 //Incluir
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.PCPA117' OPERATION OP_ALTERAR    ACCESS 0 //Alterar
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.PCPA117' OPERATION OP_EXCLUIR    ACCESS 0 //Excluir
	
Return aRotina

//--------------------------------------------------------------------
/*/{Protheus.doc} A117VldCod()
Valida o codigo da operação
@author Douglas Heydt
@since 11/04/2018
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Function A117VldCod()
	Local oModel     := FWModelActive()
	Local oModelSVI := oModel:GetModel("SVIMASTER")
	Local aArea 	:= GetArea()
	Local lRet		:= .T.
	Local cFilSVI	:= xFilial("SVI")
	Local cCodSVI  := oModelSVI:GetValue("VI_CODIGO")
	If !Empty(cCodSVI)		
		dbSelectArea("SVI")
		dbSetOrder(1)
		If MsSeek( cFilSVI+cCodSVI)		
				Help(" ",1,"A117JAEXISTE")
				lRet := .F.
		EndIf       
	EndIf
	RestArea(aArea)
	
Return lRet
