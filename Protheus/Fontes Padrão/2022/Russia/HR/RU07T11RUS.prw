#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/
{Protheus.doc} RU07T11RUS
    HR Referencies File

    @author Fedorova Anna
    @since 30/09/2019
    @version 1.0
    @project MA3 - Russia
/*/
Function RU07T11RUS()
    Local oBrowse As Object

    oBrowse := BrowseDef()
    oBrowse:Activate()

Return BrowseDef()

/*/
{Protheus.doc} BrowseDef
    Browse definition

    @author Fedorova Anna
    @since 30/09/2019
    @version 1.0
    @project DMA3 - Russia
/*/
Static Function BrowseDef
Return FwLoadBrw("RU07T11")

/*/
{Protheus.doc} MenuDef
    Menu definition

    @author Fedorova Anna
    @since 30/09/2019
    @version 1.0
    @project DMA3 - Russia
/*/
Static Function MenuDef()
Return FWLoadMenuDef("RU07T11")

/*/
{Protheus.doc} ModelDef
    Model definition

    @author Fedorova Anna
    @since 30/09/2019
    @version 1.0
    @project DMA3 - Russia
/*/
Static Function ModelDef()
Return FWLoadModel("RU07T11")

/*/
{Protheus.doc} ViewDef
    View definition

    @author Fedorova Anna
    @since 30/09/2019
    @version 1.0
    @project DMA3 - Russia
/*/
Static Function ViewDef()
Return FWLoadView("RU07T11")
