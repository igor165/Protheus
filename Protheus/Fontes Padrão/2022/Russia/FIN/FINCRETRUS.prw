#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEDITPANEL.CH'
#INCLUDE 'FINCRET.CH'

/*/{Protheus.doc} FINM020RUS
@author Alexander Ivanov
@since 5/11/2019
@version 12.27
/*/
Function FINCRETRUS()
Return Nil

/*/{Protheus.doc} ModelDef
Defini1o do modelo de dados
@author 	Alexander Ivanov
@since 		5/11/2019
@version 12.27
/*/
Static Function ModelDef()
Local oModel as object
oModel 	:= FwLoadModel('FINCRET')
Return oModel

/*/{Protheus.doc} ModelDef
@author 	Alexander Ivanov
@since 		5/11/2019
@version 12.27
/*/
Static Function ViewDef()
Local oView as object
oView 	:= FwLoadView('FINCRET')
Return oView