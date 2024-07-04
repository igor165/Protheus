#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} RU07T05RUS()	
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
Function RU07T05RUS()
Local oBrowse as Object

oBrowse := BrowseDef()

oBrowse:Activate()
	
Return Nil

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

Return FWLoadBrw("RU07T05")



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

Return  FWLoadMenuDef("RU07T05")
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

Return  FWLoadModel("RU07T05") 
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

Return FWLoadView("RU07T05")
//---------------------------------------------------------------------