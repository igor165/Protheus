#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWADAPTEREAI.CH'
#include 'TmsA760.ch'

//===========================================================================================================
/* Componentes Exclusivos da Regiao 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	*/
//===========================================================================================================
Function TMSA760()
Local oMBrowse 		:= Nil

Private aRotina   := MenuDef()

oMBrowse:= FWMBrowse():New()	
oMBrowse:SetAlias( "DUR" )
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
Local oStruDUR 	:= Nil

oStruDUR := FwFormStruct( 1, "DUR" ) 

oModel := MPFormModel():New ( "TMSA760",/*bPreValid*/, /*bPosValid*/,, /*bCancel*/ )

oModel:SetDescription(STR0001)

oModel:AddFields( 'MdFieldDUR',	, oStruDUR, /*bLinePre*/, /*bLinePost*/, /*bPre*/ , /*bPost*/,/* bLoad*/)	

oModel:GetModel ( 'MdFieldDUR' )
oModel:SetPrimaryKey( { "DUR_FILIAL","DUR_GRPVEN", "DUR_CODPAS" } )

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
Local oStruDUR 	:= Nil

oModel   := FwLoadModel( "TMSA760" )
oStruDUR := FwFormStruct( 2, "DUR" ) 

oView := FwFormView():New()
oView:SetModel(oModel)	

oView:AddField( 'VwFieldDUR', oStruDUR , 'MdFieldDUR' )

oView:CreateHorizontalBox( 'TOPO'   , 100 )

oView:SetOwnerView( 'VwFieldDUR' , 'TOPO' )

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
aAdd( aRotina, { STR0003	, "VIEWDEF.TMSA760"  , 0, 2, 0, .F. } ) // Visualizar
aAdd( aRotina, { STR0004	, "VIEWDEF.TMSA760"  , 0, 3, 0, Nil } ) // Incluir
aAdd( aRotina, { STR0005	, "VIEWDEF.TMSA760"  , 0, 4, 0, Nil } ) // Alterar
aAdd( aRotina, { STR0006	, "VIEWDEF.TMSA760"  , 0, 5, 3, Nil } ) // Excluir	

RestArea( aArea )

Return(aRotina)