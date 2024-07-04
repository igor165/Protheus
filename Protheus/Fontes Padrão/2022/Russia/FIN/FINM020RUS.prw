#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} FINM020RUS
@author Alexander Ivanov
@since 1/11/2019
@version 12.27
/*/
Function FINM020RUS()
Return Nil

/*/{Protheus.doc} ModelDef
@author 	Alexander Ivanov
@since 		1/11/2019
@version 12.27
/*/
Static Function ModelDef()
Local oModel as object
oModel 	:= FwLoadModel('FINM020')
Return oModel
