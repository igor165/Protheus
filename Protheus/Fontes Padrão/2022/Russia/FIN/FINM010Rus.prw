#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH' 

/*{Protheus.doc} ModelDef
@author Alexander Ivanov
@since 11/11/2019
@version 12.27
*/
Function FINM010Rus()
Return


/*{Protheus.doc} ModelDef
@author Alexander Ivanov
@since 11/11/2019
@version 12.27
*/
Static Function ModelDef()
Local oModel as Object
oModel 	:= FwLoadModel('FINM010')
Return oModel
