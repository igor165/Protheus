#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA030.CH"
#INCLUDE "FWADAPTEREAI.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} GPEA030RUS 
Establish Positions Register File (Russia)

@author V. Selyakov
@since 03/02/2020
@version 1.0
@project DMA3 - Russia
*/
//-------------------------------------------------------------------
Function GPEA030RUS()	
Return GPEA030()

//-------------------------------------------------------------------
/*{Protheus.doc} BrowseDef
Browse definition.
@author V. Selyakov
@since 03/02/2020
@version 1.0
@project DMA3 - Russia
*/
//-------------------------------------------------------------------
Static Function BrowseDef()
Return FWLoadBrw("GPEA030") 

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Menu definition.
@author V. Selyakov
@since 03/02/2020
@version 1.0
@project DMA3 - Russia
*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWLoadMenuDef("GPEA030")

//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Model defenition.
@author V. Selyakov
@since 03/02/2020
@version 1.0
@project DMA3 - Russia
*/
//-------------------------------------------------------------------
Static Function ModelDef()
Return FwLoadModel('GPEA030')

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
View defenition.
@author V. Selyakov
@since 03/02/2020
@version 1.0
@project DMA3 - Russia
*/
//-------------------------------------------------------------------
Static Function ViewDef()
Return FWLoadView("GPEA030")
//Checked and merged by AS for Russia_R4
// Russia_R5
