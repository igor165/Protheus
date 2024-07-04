#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE "TMSA110.CH"

//-----------------------------------------------------------------------------------------------------------
/* Pagadores do Frete 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		14/05/2020
@return 	*/
//-----------------------------------------------------------------------------------------------------------
FUNCTION TMSA110()

Local oMBrowse 		:= Nil

Private aRotina   := MenuDef()

oMBrowse:= FWMBrowse():New()	
oMBrowse:SetAlias( "DTJ" )
oMBrowse:SetDescription( STR0001 )
oMBrowse:Activate()

Return
//-----------------------------------------------------------------------------------------------------------
/* ModelDef
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		14/05/2020
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel 	:= NIL
Local oStruFDTJ := Nil

oStruFDTJ := FwFormStruct( 1, "DTJ" ) 
FWMemoVirtual( oStruFDTJ,{ {"DTJ_CODOBS" , "DTJ_OBS" } }  )

oModel := MPFormModel():New ( "TMSA110",/*bPreValid*/, /*bPosValid*/,, /*bCancel*/ )

oModel:SetDescription(STR0001)

oModel:AddFields( 'MdFieldDTJ',	, oStruFDTJ, /*bLinePre*/, /*bLinePost*/, /*bPre*/ , /*bPost*/,/* bLoad*/)	

oModel:GetModel ( 'MdFieldDTJ' )
oModel:SetPrimaryKey( { "DTJ_FILIAL","DTJ_CNDREM","DTJ_CNDDES","DTJ_CNDCON","DTJ_CNDDEP" } )

Return( oModel )

//-----------------------------------------------------------------------------------------------------------
/* ViewDef 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		14/05/2020
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView 	:= NIL
Local oModel   	:= NIL 
Local oStruFDTJ 	:= Nil

oModel   := FwLoadModel( "TMSA110" )
oStruFDTJ := FwFormStruct( 2, "DTJ" ) 
oStruFDTJ:RemoveField("DTJ_CODOBS")

oView := FwFormView():New()
oView:SetModel(oModel)	

oView:AddField( 'VwFieldDTJ', oStruFDTJ , 'MdFieldDTJ' )

oView:CreateHorizontalBox( 'TOPO'   , 100 )

oView:SetOwnerView( 'VwFieldDTJ' , 'TOPO' )

Return( oView )

//===========================================================================================================
/* MenuDef
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		14/05/2020
@return 	aRotina - Array com as opçoes de Menu */                                                                                                         
//===========================================================================================================
Static Function MenuDef()

Local aArea		:= GetArea() 

Private	aRotina	:= {}

aAdd( aRotina, { STR0002     , "PesqBrw"          , 0, 1, 0, .T. } ) // Pesquisar
aAdd( aRotina, { STR0003     , "VIEWDEF.TMSA110"  , 0, 2, 0, .F. } ) // Visualizar
aAdd( aRotina, { STR0004     , "VIEWDEF.TMSA110"  , 0, 3, 0, Nil } ) // Incluir
aAdd( aRotina, { STR0005     , "VIEWDEF.TMSA110"  , 0, 4, 0, Nil } ) // Alterar
aAdd( aRotina, { STR0006     , "VIEWDEF.TMSA110"  , 0, 5, 3, Nil } ) // Excluir	

RestArea( aArea )							 

Return(aRotina)


