#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} RU07D07RUS()	
	(long_description)
	@type  Function
	@author Din Belotserkovsky
	@since 2018-07-31
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	*/
 Function RU07D07RUS()
 Local oBrowse as object

 oBrowse := BrowseDef()
 oBrowse:Activate()

Return NIL
//---------------------------------------------------------------------

/*{Protheus.doc} BrowseDef
	(long_description)
	@type  Static Function
	@author Din Belotserkovsky
	@since 2018-07-31
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	*/
 Static Function BrowseDef
 Local oBrowse as object

Return FwLoadBrw("RU07D07")
//---------------------------------------------------------------------

/*{Protheus.doc} MenuDef()
	(long_description)
	@type  Static Function
	@author Din Belotserkovsky
	@since 2018-07-31
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	*/
 Static Function MenuDef()

Return  FWLoadMenuDef("RU07D07")
//---------------------------------------------------------------------

/*{Protheus.doc} ModelDef
	(long_description)
	@type  Static Function
	@author Din Belotserkovsky
	@since 2018-07-31
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	*/
 Static Function ModelDef()

Return  FWLoadModel("RU07D07") 
//---------------------------------------------------------------------

/*{Protheus.doc} ViewDef
	(long_description)
	@type  Static Function
	@author Din Belotserkovsky
	@since 2018-07-31
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	*/
 Static Function ViewDef()

Return FWLoadView("RU07D07")
//---------------------------------------------------------------------