#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

// Adm\FINM030RUS.prw

/*/{Protheus.doc} FINM030RUS
@author Anton Stepanov
@since 05 November 2019
@version MA3 - Russia
/*/
Function FINM030RUS()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini1o do modelo de dados
@author 	Anton Stepanov
@since 		05 November 2019
@version 	1.0
@project	MA3
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Return FwLoadModel("FINM030")