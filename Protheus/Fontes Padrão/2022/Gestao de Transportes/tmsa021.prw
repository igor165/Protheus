#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TMSA021.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWADAPTEREAI.CH'

//-----------------------------------------------------------------------------------------------------------
/* Classificacao ONU 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Function TMSA021()

Local oMBrowse 		:= Nil

Private aRotina   := MenuDef()

oMBrowse:= FWMBrowse():New()	
oMBrowse:SetAlias( "DY3" )
oMBrowse:SetDescription( STR0001 )
oMBrowse:Activate()

Return NIL

//-----------------------------------------------------------------------------------------------------------
/* ModelDef 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel 	:= NIL
Local oStruFDY3	:= Nil
Local oStruGDY3	:= Nil
Local cCpoField := "|DY3_ONU|DY3_DESCRI|DY3_INFCPL|"

oStruFDY3 := FwFormStruct( 1, "DY3", { |cCampo|  AllTrim( cCampo ) + "|" $ cCpoField } )
oStruGDY3 := FwFormStruct( 1, "DY3", { |cCampo| !AllTrim( cCampo ) + "|" $ cCpoField } )

oModel := MPFormModel():New( "TMSA021",/*bPreValid*/, /*bPosValid*/,, /*bCancel*/ )

oModel:SetDescription(STR0001)

oModel:AddFields( 'MdFieldDY3', Nil	, oStruFDY3, /*bLinePre*/, /*bLinePost*/, /*bPre*/ , /*bPost*/,/* bLoad*/)	

oModel:SetPrimaryKey( { "DY3_FILIAL","DY3_ONU", "DY3_ITEM" } )

oModel:AddGrid( "MdGridDY3", "MdFieldDY3", oStruGDY3 )

oModel:SetRelation( "MdGridDY3", { { "DY3_FILIAL", "xFilial('DY3')" }, { "DY3_ONU", "DY3_ONU" } }, DY3->( IndexKey( 1 ) ) )

Return( oModel )

//-----------------------------------------------------------------------------------------------------------
/* ViewDef 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView 	:= NIL
Local oModel   	:= NIL 
Local oStruGDY3	:= Nil
Local cCpoField := "|DY3_ONU|DY3_DESCRI|DY3_INFCPL|"

oStruFDY3 := FwFormStruct( 2, "DY3", { |cCampo|  AllTrim( cCampo ) + "|" $ cCpoField } )
oStruGDY3 := FwFormStruct( 2, "DY3", { |cCampo| !AllTrim( cCampo ) + "|" $ cCpoField } )

oModel   := FwLoadModel( "TMSA021" )

oView := FwFormView():New()
oView:SetModel(oModel)	

oView:AddField( 'VwFieldDY3', oStruFDY3 , 'MdFieldDY3' )

oView:AddGrid( "VwGridDY3", oStruGDY3, "MdGridDY3" )

oView:AddIncrementField( 'VwGridDY3', 'DY3_ITEM' )

oView:CreateHorizontalBox( 'FIELD'  , 40 )
oView:CreateHorizontalBox( 'GRID'   , 60 )

oView:SetOwnerView( 'VwFieldDY3' , 'FIELD')
oView:SetOwnerView( 'VwGridDY3'  , 'GRID' )

Return( oView )

//===========================================================================================================
/* MenuDef
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	aRotina - Array com as opçoes de Menu */                                                                                                         
//===========================================================================================================
Static Function MenuDef()

Local aArea		:= GetArea() 

Private	aRotina	:= {}

aAdd( aRotina, { STR0002, "PesqBrw"          , 0, 1, 0, .T. } ) // Pesquisar
aAdd( aRotina, { STR0003, "VIEWDEF.TMSA021"  , 0, 2, 0, .F. } ) // Visualizar
aAdd( aRotina, { STR0004, "VIEWDEF.TMSA021"  , 0, 3, 0, Nil } ) // Incluir
aAdd( aRotina, { STR0005, "VIEWDEF.TMSA021"  , 0, 4, 0, Nil } ) // Alterar
aAdd( aRotina, { STR0006, "VIEWDEF.TMSA021"  , 0, 5, 3, Nil } ) // Excluir	

RestArea( aArea )							 

Return(aRotina)

