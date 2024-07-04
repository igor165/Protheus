#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'CRMA680.CH'
Function CRMA680()
Local oBrowse
Private aRotina := Menudef()
oBrowse := BrowseDef()
oBrowse:Activate()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition
@author Andrews Egas
@since 21/03/2016
@version P12/MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse as object

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('AGA')
oBrowse:SetDescription(STR0001)

Return oBrowse


//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION 'VIEWDEF.CRMA680' OPERATION 2 ACCESS 0 //View
ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.CRMA680' OPERATION 3 ACCESS 0 //Add
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.CRMA680' OPERATION 4 ACCESS 0 //Edit
ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.CRMA680' OPERATION 5 ACCESS 0 //Delete
ADD OPTION aRotina TITLE STR0006	ACTION 'VIEWDEF.CRMA680' OPERATION 9 ACCESS 0 //Copy

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruAGA := FWFormStruct( 1, 'AGA', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

oModel := MPFormModel():New('CRMA680', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
oModel:AddFields( 'AGAMASTER', /*cOwner*/, oStruAGA, /*bPreValidacao*/, , /*bCarga*/ )
oModel:SetPrimaryKey({"AGA_CODIGO"} ) //define a chave primaria se nao foi definido no x2
oModel:SetDescription( STR0001 )
oModel:GetModel( 'AGAMASTER' ):SetDescription( STR0001 )

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel('CRMA680')
Local oStruAGA := FWFormStruct( 2, 'AGA' )
Local oView
Local cField := AGA->AGA_ENTIDA + "ADR"

oView := FWFormView():New()

If oModel:GetOperation() == MODEL_OPERATION_VIEW
	oStruAGA:SetProperty('AGA_CODENT',MVC_VIEW_LOOKUP,cField)
Else
	oStruAGA:SetProperty('AGA_CODENT',MVC_VIEW_LOOKUP,"")
EndIf

oView:SetModel( oModel )
oView:AddField( 'VIEW_AGA', oStruAGA, 'AGAMASTER' )

oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_AGA', 'TELA' )

Return oView
// Russia_R5
