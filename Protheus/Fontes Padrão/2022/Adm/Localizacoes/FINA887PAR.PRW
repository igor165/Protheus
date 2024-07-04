#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE SOURCEFATHER "FINA887"

/*/{Protheus.doc} FINA887COL
Fonte de cobros diversos (Paraguay)
@author 	raul.medina
@since 		10/2021
@version	12.1.27 / Superior
/*/
Function FINA887PAR()
Local oBrowse := Nil
	
	oBrowse := BrowseDef()
	
	oBrowse:Activate()
	
Return nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author	 	raul.medina
@since 		10/2021
@version	12.1.27 / Superior
/*/
Static Function BrowseDef() 
Local oBrowse := Nil

	oBrowse := FwLoadBrw(SOURCEFATHER)

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		10/2021
@version	12.1.27 / Superior
/*/
Static Function ModelDef()
Local oModel		:= FwLoadModel(SOURCEFATHER)
Local oEvtRetPAR	:= F887RETPAR():New()
Local oEvtTit		:= F887FINPAR():New()

	oModel:InstallEvent("F887FINPAR", "F887FIN", oEvtTit)
	oModel:InstallEvent("F887RETPAR",/*cOwner*/,oEvtRetPAR)

Return oModel
