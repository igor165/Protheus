#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//#INCLUDE "TAFA531.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA531
@type			function
@description	Cadastro MVC de Requisições de Serviços.
@author			Felipe C. Seolin
@since			16/04/2019
/*/
//---------------------------------------------------------------------
Function TAFA531()

Local oBrowse	:=	FWMBrowse():New()

oBrowse:SetDescription( "Cadastro de Requisições de Serviços" )
oBrowse:SetAlias( "V3J" )
oBrowse:SetMenuDef( "TAFA531" )
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
Return( FWMVCMenu( "TAFA531" ) )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Função genérica MVC do modelo.
@author			Felipe C. Seolin
@since			16/04/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

Local oStruV3J	:=	FWFormStruct( 1, "V3J" )
Local oModel	:=	MPFormModel():New( "TAFA531" )

oModel:AddFields( "MODEL_V3J", /*cOwner*/, oStruV3J )
oModel:GetModel( "MODEL_V3J" ):SetPrimaryKey( { "V3J_FILIAL", "V3J_ID" } )

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type			function
@description	Função genérica MVC da view.
@author			Felipe C. Seolin
@since			16/04/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:=	FWLoadModel( "TAFA531" )
Local oStruV3J	:=	FWFormStruct( 2, "V3J" )
Local oView		:=	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_V3J", oStruV3J, "MODEL_V3J" )

oView:EnableTitleView( "VIEW_V3J", "Cadastro de Requisições de Serviços" )
oView:CreateHorizontalBox( "FIELDSV3J", 100 )
oView:SetOwnerView( "VIEW_V3J", "FIELDSV3J" )

Return( oView )