#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE SOURCEFATHER "FINA887"

/*/{Protheus.doc} FINA887ARG
Fonte de cobros diversos (Argentina)
@author 	raul.medina
@since 		09/04/2021
@version	12.1.27 / Superior
/*/
Function FINA887ARG()
Local oBrowse := Nil
	
	oBrowse := BrowseDef()
	
	oBrowse:Activate()
	
Return nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author	 	raul.medina
@since 		09/04/2021
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
Local oEvtTit		:= F887FINARG():New()
Local oEvtChq		:= F887CHQ():New()
Local oEvtChqArg	:= F887CHQARG():New()
Local oEvtRetArg	:= F887RETARG():New()
Local oEvtDifCam	:= F887DIFCAM():New()
	
	oStruSEL:AddField("EL_VALBASE", 	"EL_VALBASE", 	"EL_VALBASE",	'N', GetSx3Cache("FE_VALBASE","X3_TAMANHO")	,	GetSx3Cache("FE_VALBASE","X3_DECIMAL"))
	oStruSEL:AddField("EL_ALIQ", 		"EL_ALIQ", 		"EL_ALIQ",		'N', GetSx3Cache("FE_ALIQ","X3_TAMANHO")	,	GetSx3Cache("FE_ALIQ","X3_DECIMAL"))
	oStruSEL:AddField("EL_EST", 		"EL_EST", 		"EL_EST",		'C', GetSx3Cache("FE_EST","X3_TAMANHO"))
	oStruSEL:AddField("EL_AGREGAN", 	"EL_AGREGAN",	"EL_AGREGAN",	'C', GetSx3Cache("A2_AGREGAN","X3_TAMANHO"))
	oStruSEL:AddField("EL_CONCSUS", 	"EL_CONCSUS", 	"EL_CONCSUS",	'C', GetSx3Cache("A2_CONCSUS","X3_TAMANHO"))
	
	oStruSEL:SetProperty( 'EL_TPCRED'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887aWhen("TPCRED") } ) //a087awhen("TPCRED")
	oStruSEL:SetProperty( 'EL_TIPO'		, 	MODEL_FIELD_VALID,	{|oModelGrid| FA887VALTP(oModelGrid,.T.) } ) 

	oModel:InstallEvent("F887FINARG", "F887FIN", oEvtTit)
	oModel:InstallEvent("F887CHQ"	,/*cOwner*/,oEvtChq)
	oModel:InstallEvent("F887CHQARG", "F887CHQ",oEvtChqArg)
	oModel:InstallEvent("F887RETARG",/*cOwner*/,oEvtRetArg)
	oModel:InstallEvent("F887DIFCAM",/*cOwner*/,oEvtDifCam)

Return oModel
