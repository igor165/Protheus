#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} RU07D08RUS()	
	(long_description)
	@type  Function
	@author Din Belotserkovsky
	@since 2018-08-22
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	*/
 Function RU07D08RUS()
 Local oBrowse as object

 oBrowse := BrowseDef()
 oBrowse:Activate()

Return NIL
//---------------------------------------------------------------------

/*{Protheus.doc} BrowseDef
	(long_description)
	@type  Static Function
	@author Din Belotserkovsky
	@since 2018-08-22
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	*/
 Static Function BrowseDef
 Local oBrowse as object

Return FwLoadBrw("RU07D08")
//---------------------------------------------------------------------

/*{Protheus.doc} MenuDef()
	(long_description)
	@type  Static Function
	@author Din Belotserkovsky
	@since 2018-08-22
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	*/
 Static Function MenuDef()

Return  FWLoadMenuDef("RU07D08")
//---------------------------------------------------------------------

/*{Protheus.doc} ModelDef
	(long_description)
	@type  Static Function
	@author Din Belotserkovsky
	@since 2018-08-22
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	*/
 Static Function ModelDef()

Return  FWLoadModel("RU07D08") 
//---------------------------------------------------------------------

/*{Protheus.doc} ViewDef
	(long_description)
	@type  Static Function
	@author Din Belotserkovsky
	@since 2018-08-22
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	*/
 Static Function ViewDef()

Return FWLoadView("RU07D08")
//---------------------------------------------------------------------