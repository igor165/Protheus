#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE SOURCEFATHER "FINA887"

/*/{Protheus.doc} FINA887URU
Fonte de cobros diversos (Uruguay)
@author 	eduardo.manriquez
@since 		01/08/2022
@version	12.1.27 / Superior
/*/
Function FINA887URU()
Local oBrowse := Nil
	
	oBrowse := BrowseDef()
	
	oBrowse:Activate()
	
Return nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author 	eduardo.manriquez
@since 		01/08/2022
@version	12.1.27 / Superior
/*/
Static Function BrowseDef() 
Local oBrowse := Nil

	oBrowse := FwLoadBrw(SOURCEFATHER)

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	eduardo.manriquez
@since 		01/08/2022
@version	12.1.27 / Superior
/*/
Static Function ModelDef()
	Local oModel		:= FwLoadModel(SOURCEFATHER)
	Local oEvtDifCam	:= F887DIFCAM():New()

	oModel:InstallEvent("F887DIFCAM",/*cOwner*/,oEvtDifCam)

Return oModel
