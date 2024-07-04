#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWADAPTEREAI.CH'
#include 'TmsA950.ch'

//===========================================================================================================
/* Cadastro de Filiais de negociacao por cliente   
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	*/
//===========================================================================================================
Function TMSA950()
Local oMBrowse 		:= Nil

Private aRotina   := MenuDef()

oMBrowse:= FWMBrowse():New()	
oMBrowse:SetAlias( "DW3" )
oMBrowse:SetDescription( STR0001 )
oMBrowse:Activate()

Return()

//===========================================================================================================
/* ModelDef 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	*/
//===========================================================================================================
Static Function ModelDef()

Local oModel 	:= NIL
Local oStruDW3 	:= Nil

oStruDW3 := FwFormStruct( 1, "DW3" ) 

oModel := MPFormModel():New ( "TMSA950",/*bPreValid*/, /*bPosValid*/,, /*bCancel*/ )

oModel:SetDescription(STR0001)

oModel:AddFields( 'MdFieldDW3',	, oStruDW3, /*bLinePre*/, /*bLinePost*/, /*bPre*/ , /*bPost*/,/* bLoad*/)	

oModel:GetModel ( 'MdFieldDW3' )
oModel:SetPrimaryKey( { "DW3_FILIAL","DW3_CODCLI", "DW3_LOJCLI", "DW3_TIPTRA" } )

Return( oModel )

//===========================================================================================================
/* ViewDef 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	*/
//===========================================================================================================
Static Function ViewDef()

Local oView 	:= NIL
Local oModel   	:= NIL 
Local oStruDW3 	:= Nil

oModel   := FwLoadModel( "TMSA950" )
oStruDW3 := FwFormStruct( 2, "DW3" ) 

oView := FwFormView():New()
oView:SetModel(oModel)	

oView:AddField( 'VwFieldDW3', oStruDW3 , 'MdFieldDW3' )

oView:CreateHorizontalBox( 'TOPO'   , 100 )

oView:SetOwnerView( 'VwFieldDW3' , 'TOPO' )

Return( oView )

//===========================================================================================================
/* MenuDef.
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	aRotina - Array com as opçoes de Menu */                                                                                                         
//===========================================================================================================
Static Function MenuDef()
Local aArea		:= GetArea() 

Private	aRotina	:= {}

aAdd( aRotina, { STR0002	, "PesqBrw"          , 0, 1, 0, .T. } ) // Pesquisar
aAdd( aRotina, { STR0003	, "VIEWDEF.TMSA950"  , 0, 2, 0, .F. } ) // Visualizar
aAdd( aRotina, { STR0004	, "VIEWDEF.TMSA950"  , 0, 3, 0, Nil } ) // Incluir
aAdd( aRotina, { STR0005	, "VIEWDEF.TMSA950"  , 0, 4, 0, Nil } ) // Alterar
aAdd( aRotina, { STR0006	, "VIEWDEF.TMSA950"  , 0, 5, 3, Nil } ) // Excluir	

RestArea( aArea )

Return(aRotina)

