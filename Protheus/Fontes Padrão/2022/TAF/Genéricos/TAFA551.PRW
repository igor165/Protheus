#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA551
@type			function
@description	Cadastro MVC de RequisiÃ§Ãµes de ServiÃ§os.
@author			Felipe C. Seolin
@since			16/04/2019
/*/
//---------------------------------------------------------------------
Function TAFA551() 

Local oBrowse	:=	FWMBrowse():New()

oBrowse:SetDescription( "Cadastro de Resultados de requisições de API" )
oBrowse:SetAlias( "V45" )
oBrowse:SetMenuDef( "TAFA551" )
oBrowse:Activate()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@type			function
@description	Função genérica MVC do menu.
@author			Felipe C. Seolin
@since			16/04/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()
Return( FWMVCMenu( "TAFA551" ) )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Função genérica MVC do menu.
@author			Felipe C. Seolin
@since			16/04/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

Local oStruV45	:=	FWFormStruct( 1, "V45" )
Local oModel	:=	MPFormModel():New( "TAFA551" )

oModel:AddFields( "MODEL_V45", /*cOwner*/, oStruV45 )
oModel:GetModel( "MODEL_V45" ):SetPrimaryKey( { "V45_FILIAL", "V45_ID", "V45_SEQ" } )

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type			function
@description	Função genérica MVC do menu.
@author			Felipe C. Seolin
@since			16/04/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:=	FWLoadModel( "TAFA551" )
Local oStruV3J	:=	FWFormStruct( 2, "V45" )
Local oView		:=	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_V45", oStruV3J, "MODEL_V45" )

oView:EnableTitleView( "VIEW_V45", "Cadastro de Resultados de requisições de API" )
oView:CreateHorizontalBox( "FIELDSV45", 100 )
oView:SetOwnerView( "VIEW_V45", "FIELDSV45" )

Return( oView )