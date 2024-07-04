#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"    
#INCLUDE "TAFA090.CH"                                   

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA090
Cadastro MVC - Documentos Fiscais com AIDF

@author Rodrigo Aguilar
@since 22/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA090
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Documentos Fiscais com AIDF"
oBrw:SetAlias( 'C6A' )
oBrw:SetMenuDef( 'TAFA090' )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu                                                                                        

@author Rodrigo Aguilar
@since 22/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA090" )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rodrigo Aguilar
@since 22/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC6A 	:= 	FWFormStruct( 1, 'C6A' )
Local oStruC6B 	:= 	FWFormStruct( 1, 'C6B' )
Local oModel 	:= 	MPFormModel():New( 'TAFA090' )
      
oModel:AddFields('MODEL_C6A', /*cOwner*/, oStruC6A )

oModel:AddGrid('MODEL_C6B', 'MODEL_C6A', oStruC6B)  
oModel:GetModel( 'MODEL_C6B' ):SetUniqueLine( { 'C6B_DIINI' , 'C6B_DIFIN' } )
oModel:GetModel( 'MODEL_C6B' ):SetOptional( .T. )

oModel:SetRelation( 'MODEL_C6B' , { { 'C6B_FILIAL' , 'xFilial( "C6B" )' } , { 'C6B_ID' , 'C6A_ID' } } , C6B->( IndexKey( 3 ) ) )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 22/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef() 

Local oModel 	:= 	FWLoadModel( 'TAFA090' )
Local oStruC6A 	:= 	FWFormStruct( 2, 'C6A' )  //Doctos.Fiscais com AIDF
Local oStruC6B 	:= 	FWFormStruct( 2, 'C6B' )  //Doctos Fiscais Cancel/Inutil
Local oView 	:= 	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C6A', oStruC6A, 'MODEL_C6A' )
oView:EnableTitleView( 'VIEW_C6A', STR0001 ) //"Documentos Fiscais com AIDF"

oView:AddGrid ( 'VIEW_C6B', oStruC6B, 'MODEL_C6B' )

oView:CreateHorizontalBox( 'FIELDSC6A', 30 )          

oView:CreateHorizontalBox( 'PANFOLDER1', 70 )
oView:CreateFolder( 'FOLDER1', 'PANFOLDER1' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0002 ) //"Documentos Fiscais Cancelados"

oView:CreateHorizontalBox( 'GRIDC6B', 100,,, 'FOLDER1', 'ABA01' )

oView:SetOwnerView( 'VIEW_C6A', 'FIELDSC6A' )
oView:SetOwnerView( 'VIEW_C6B', 'GRIDC6B' )

Return oView