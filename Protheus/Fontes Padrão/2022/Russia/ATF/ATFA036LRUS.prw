#include 'protheus.ch'
#include 'FWMVCDef.ch'
#include 'ATFA036L.CH'

#define SOURCEFATHER	"ATFA036L"

//-----------------------------------------------------------------------
/*/{Protheus.doc} ATFA036RUS()

Russian localization of Badge FA write-off routine (ATFA036L)

@param		None
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function ATFA036LRUS()
Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef()

Browse definition

@param		None
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse		AS OBJECT
oBrowse		:= FWLoadBrw(SOURCEFATHER)
Return oBrowse

//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

Menu definition

@param		None
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()
Local aRotina		AS ARRAY
aRotina		:= FWLoadMenuDef(SOURCEFATHER)
Return aRotina

//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

MVC Model definition

@param		None
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ModelDef()
Local oModel		AS OBJECT
Local oEventRUS		AS OBJECT

oModel		:= FWLoadModel(SOURCEFATHER)
oEventRUS	:= EV01A036RU():New()
oModel:InstallEvent("EV01A036RU",,oEventRUS)

Return oModel

//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

MVC View definition

@param		None
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()
Local oView			AS OBJECT
oView		:= FWLoadView(SOURCEFATHER)
Return oView

// Russia_R5
