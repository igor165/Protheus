#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE SOURCEFATHER "FINA887"

/*/{Protheus.doc} FINA887COL
Fonte de cobros diversos (Perú)
@author 	raul.medina
@since 		23/05/2021
@version	12.1.27 / Superior
/*/
Function FINA887COL()
Local oBrowse := Nil
	
	oBrowse := BrowseDef()
	
	oBrowse:Activate()
	
Return nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author	 	raul.medina
@since 		23/05/2021
@version	12.1.27 / Superior
/*/
Static Function BrowseDef() 
Local oBrowse := Nil

	oBrowse := FwLoadBrw(SOURCEFATHER)

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		09/04/2021
@version	12.1.27 / Superior
/*/
Static Function ModelDef()
Local oModel		:= FwLoadModel(SOURCEFATHER)
Local oModelSEL 	:= oModel:GetModel( 'SEL_DETAIL' )
Local oStruSEL		:= oModelSEL:oFormModelStruct
Local oStruRET		:= FWFormModelStruct():New()
	
	oStruSEL:SetProperty( 'EL_TPCRED'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887aWhen("TPCRED") } ) //a087awhen("TPCRED")

Return oModel
