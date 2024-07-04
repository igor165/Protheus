#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE SOURCEFATHER "FINA887"

/*/{Protheus.doc} FINA887PER
Fonte de cobros diversos (Perú)
@author 	raul.medina
@since 		19/05/2021
@version	12.1.27 / Superior
/*/
Function FINA887PER()
Local oBrowse := Nil
	
	oBrowse := BrowseDef()
	
	oBrowse:Activate()
	
Return nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author	 	raul.medina
@since 		19/05/2021
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
Local oEvtTit		:= F887FINPER():New()
Local oEvtRetPer	:= F887RETPER():New()
	
	
	oStruSEL:SetProperty( 'EL_TIPODOC'	, 	MODEL_FIELD_VALID,	FWBuildFeature( STRUCT_FEATURE_VALID, 'pertence(MVCHEQUE+"|EF|TF|RI|TB") .and. F887VTpDoc()') ) //FA840VALTP
	oStruSEL:SetProperty( 'EL_DIACTB'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| .T. } ) //?
	
	oModel:InstallEvent("F887FINPER", "F887FIN", oEvtTit)
	oModel:InstallEvent("F887RETPER",/*cOwner*/,oEvtRetPer)

Return oModel

/*/{Protheus.doc} F887VTpDoc
Validaciones correspondientes a las retenciones de IGV para Perú

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.

@author 	raul.medina
@version	12.1.27 / Superior
@since		20/05/2021 
/*/
Function F887VTpDoc()
Local oModel 	:= FWModelActive()
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local lRet		:= .T.
Local cTipoDoc	:= oModelSEL:GetValue("EL_TIPODOC")
Local cSerRet	:= oModelSEL:GetValue("EL_SERRET")
Local nTamSerR	:= GetSx3Cache("EL_SERRET","X3_TAMANHO")

	If cTipoDoc $ "RI" 
		If Empty(cSerRet)
			oModelSEL:SetValue("EL_SERRET",SuperGetMV("MV_CRSERIE", , Space( nTamSerR ) ))
		Endif
	Else
		oModelSEL:SetValue("EL_SERRET",Space( nTamSerR ))
	Endif

Return lRet
