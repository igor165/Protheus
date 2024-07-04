#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE "TMSAF50.ch"

//===========================================================================================================
/* Cadastro de contas Especiais 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	*/
//===========================================================================================================
Function TMSAF50()
Local oMBrowse 		:= Nil

Private aRotina   := MenuDef()

oMBrowse:= FWMBrowse():New()	
oMBrowse:SetAlias( "DFW" )
oMBrowse:SetDescription( STR0003 )
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
Local oStruDFW 	:= Nil

oStruDFW := FwFormStruct( 1, "DFW" ) 

oModel := MPFormModel():New ( "TMSAF50",/*bPreValid*/, /*bPosValid*/,, /*bCancel*/ )

oModel:SetDescription(STR0001)

oModel:AddFields( 'MdFieldDFW',	, oStruDFW, /*bLinePre*/, /*bLinePost*/, /*bPre*/ , /*bPost*/,/* bLoad*/)	

oModel:GetModel ( 'MdFieldDFW' )
oModel:SetPrimaryKey( { "DFW_FILIAL","DFW_CONTA" } )

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
Local oStruDFW 	:= Nil

oModel   := FwLoadModel( "TMSAF50" )
oStruDFW := FwFormStruct( 2, "DFW" ) 

oView := FwFormView():New()
oView:SetModel(oModel)	
                                                                   
oView:AddUserButton( STR0001, 'BMPPOST', {|| TMSAF50BUT(oModel)  } )	//Ajustar

oView:AddField( 'VwFieldDFW', oStruDFW , 'MdFieldDFW' )

oView:CreateHorizontalBox( 'TOPO'   , 100 )

oView:SetOwnerView( 'VwFieldDFW' , 'TOPO' )

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

aAdd( aRotina, { STR0004	, "PesqBrw"          , 0, 1, 0, .T. } ) // Pesquisar
aAdd( aRotina, { STR0005	, "VIEWDEF.TMSAF50"  , 0, 2, 0, .F. } ) // Visualizar
aAdd( aRotina, { STR0006	, "VIEWDEF.TMSAF50"  , 0, 3, 0, Nil } ) // Incluir
aAdd( aRotina, { STR0007	, "VIEWDEF.TMSAF50"  , 0, 4, 0, Nil } ) // Alterar
aAdd( aRotina, { STR0008	, "VIEWDEF.TMSAF50"  , 0, 5, 3, Nil } ) // Excluir	

RestArea( aArea )

Return(aRotina)

//===========================================================================================================
/* TMSAF50BUT
@author  	Katia
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	Função que executa o Botao de Tipo de Documentos */                                                                                                      
//===========================================================================================================
Function TMSAF50BUT(oModel)
Local cRet   := ""
Local oView  := FwViewActive()
 
If oModel <> Nil 
   
    If oModel:GetOperation() <> MODEL_OPERATION_INSERT
        M->DFW_DOCCUS:= DFW->DFW_DOCCUS
    EndIf

    cRet:= TMSSelField('DOCTMS', 'M->DFW_DOCCUS' )

    If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
        oView:ValidField("MdFieldDFW" , "DFW_DOCCUS", cRet)  
    EndIf

EndIf

Return .T.  


