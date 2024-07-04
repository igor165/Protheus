#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"

function PLSA418() 
local oBrwPrinc	:= nil

//MsgInfo("As opções diferentes de visualizar são temporárias para teste","Atenção")
oBrwPrinc := FWMBrowse():New()
oBrwPrinc:SetDescription( "Tabela Nacional de Medicamentos" )
oBrwPrinc:SetAlias( "B6I" )
oBrwPrinc:DisableDetails()
oBrwPrinc:SetMenuDef("PLSA418")
oBrwPrinc:ForceQuitButton()
oBrwPrinc:SetWalkthru( .F. )
oBrwPrinc:SetAmbiente( .F. )
oBrwPrinc:Activate()

return 

static function MenuDef()
local aRotina	:= {}              

aadd( aRotina, { "Visualizar"	,	"VIEWDEF.PLSA418" , 0, MODEL_OPERATION_VIEW	} )
//aadd( aRotina, { "Excluir"		, 	"VIEWDEF.PLSA418" , 0, MODEL_OPERATION_DELETE	} )
//aadd( aRotina, { "Incluir"		, 	"VIEWDEF.PLSA418" , 0, MODEL_OPERATION_INSERT	} )
//aadd( aRotina, { "Alterar"		,	"VIEWDEF.PLSA418" , 0, MODEL_OPERATION_UPDATE	} )

return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef - MVC

@author    Lucas Nonato
@version   V12
@since     15/01/2018
/*/
//------------------------------------------------------------------------------------------
static function ModelDef()
local oStruB6I := FWFormStruct( 1,'B6I',/*bAvalCampo*/,/*lViewUsado*/ )
local oModel

//--< DADOS DO LOTE >---
oModel := MPFormModel():New( 'Medicamentos' )
oModel:AddFields( 'MODEL_B6I',,oStruB6I )

oModel:SetPrimaryKey( { "B6I_FILIAL","B6I_CODPAD","B6I_CODPRO","B6I_ICMS","B6I_LIVCOM","B6I_VIGINI" } )
oModel:SetDescription( "Medicamentos" )
oModel:GetModel( 'MODEL_B6I' ):SetDescription( "Medicamentos" )

return oModel
 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef - MVC

@author    Lucas Nonato
@version   V12
@since     15/01/2018
/*/
//------------------------------------------------------------------------------------------
static function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrB6I:= FWFormStruct(2, 'B6I')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('FrmB6I' , oStrB6I,'MODEL_B6I' ) 
oView:CreateHorizontalBox( 'BxB6I', 100)
oView:SetOwnerView('FrmB6I','BxB6I')
	
Return oView

