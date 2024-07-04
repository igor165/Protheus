#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWADAPTEREAI.CH'
#include 'TmsA260.ch'

//===========================================================================================================
/* Cadastro de Rodovia 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	*/
//===========================================================================================================
Function TMSA260()
Local oMBrowse 		:= Nil

Private aRotina   := MenuDef()

oMBrowse:= FWMBrowse():New()	
oMBrowse:SetAlias( "DTZ" )
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
Local oStruDTZ 	:= Nil

oStruDTZ := FwFormStruct( 1, "DTZ" ) 

oModel := MPFormModel():New ( "TMSA260",/*bPreValid*/, /*bPosValid*/,, /*bCancel*/ )

oModel:SetDescription(STR0001)

oModel:AddFields( 'MdFieldDTZ',	, oStruDTZ, /*bLinePre*/, /*bLinePost*/, /*bPre*/ , /*bPost*/,/* bLoad*/)	

oModel:GetModel ( 'MdFieldDTZ' )
oModel:SetPrimaryKey( { "DTZ_FILIAL","DTZ_CODROD" } )

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
Local oStruDTZ 	:= Nil

oModel   := FwLoadModel( "TMSA260" )
oStruDTZ := FwFormStruct( 2, "DTZ" ) 

oView := FwFormView():New()
oView:SetModel(oModel)	

oView:AddField( 'VwFieldDTZ', oStruDTZ , 'MdFieldDTZ' )

oView:CreateHorizontalBox( 'TOPO'   , 100 )

oView:SetOwnerView( 'VwFieldDTZ' , 'TOPO' )

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
aAdd( aRotina, { STR0003	, "VIEWDEF.TMSA260"  , 0, 2, 0, .F. } ) // Visualizar
aAdd( aRotina, { STR0004	, "VIEWDEF.TMSA260"  , 0, 3, 0, Nil } ) // Incluir
aAdd( aRotina, { STR0005	, "VIEWDEF.TMSA260"  , 0, 4, 0, Nil } ) // Alterar
aAdd( aRotina, { STR0006	, "VIEWDEF.TMSA260"  , 0, 5, 3, Nil } ) // Excluir	

RestArea( aArea )

Return(aRotina)


