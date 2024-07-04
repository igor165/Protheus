#include 'protheus.ch'
#include 'parmtype.ch' 

/*/     @author Anna
        @since 23/04/2018
        @version 1.0
        @project MA3 - Russia       /*/
//-------------------------------------------------------------------
function RU06T02RUS()
Local oBrowse as object
Private aRotina as ARRAY
aRotina		:= {}
oBrowse := BrowseDef()
oBrowse:Activate()	
return NIL


/*/     @author Anna
        @since 23/04/2018
        @version 1.0
        @project MA3 - Russia       /*/
//-------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse as object
oBrowse := FWLoadBrw("RU06T02")
Return oBrowse 


/*/     @author Anna
        @since 23/04/2018
        @version 1.0
        @project MA3 - Russia       /*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina	AS ARRAY
aRotina :=  FWLoadMenuDef("RU06T02")
Return aRotina


/*/     @author Anna
        @since 23/04/2018
        @version 1.0
        @project MA3 - Russia       /*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel as object	
oModel 	:= FwLoadModel("RU06T02")
Return oModel

/*/     @author Anna
        @since 23/04/2018
        @version 1.0
        @project MA3 - Russia       /*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	as object
Local oView		as object
oView	:= FWLoadView("RU06T02")
Return oView
