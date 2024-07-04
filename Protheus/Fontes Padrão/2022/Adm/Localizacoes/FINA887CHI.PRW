#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE SOURCEFATHER "FINA887"

/*/{Protheus.doc} FINA887CHI
Fonte de cobros diversos (Chile)
@author 	raul.medina
@since 		25/05/2021
@version	12.1.27 / Superior
/*/
Function FINA887CHI()
Local oBrowse := Nil
	
	oBrowse := BrowseDef()
	
	oBrowse:Activate()
	
Return nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author	 	raul.medina
@since 		25/05/2021
@version	12.1.27 / Superior
/*/
Static Function BrowseDef() 
Local oBrowse := Nil

	oBrowse := FwLoadBrw(SOURCEFATHER)

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		25/05/2021
@version	12.1.27 / Superior
/*/
Static Function ModelDef()
Local oModel		:= FwLoadModel(SOURCEFATHER)
Local oModelSEL 	:= oModel:GetModel( 'SEL_DETAIL' )
Local oStruSEL		:= oModelSEL:oFormModelStruct
Local oStruRET		:= FWFormModelStruct():New()
Local oEvtTit		:= F887FINCHI():New()
	
	oStruSEL:SetProperty( 'EL_DIACTB'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| .T. } ) //?
	
	oModel:InstallEvent("F887FINCHI", "F887FIN", oEvtTit)

Return oModel
