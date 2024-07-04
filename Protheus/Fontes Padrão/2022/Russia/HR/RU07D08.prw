#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU07D08.CH"

/*{Protheus.doc} RU07D08
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
Function RU07D08()
Local   oBrowse  as Object

oBrowse := BrowseDef()

oBrowse:Activate()

Return Nil
//-------------------------------------------------------------------

/*{Protheus.doc} BrowseDef
	(long_description)
	@type  Static Function
	@author  Din Belotserkovsky
	@since 2018-08-22
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	*/
 Static Function BrowseDef
 Local aFields 	as Array
 Local aIndex 	as Array
 Local aSeek 	as Array
 Local oBrwTMP 	as Object

oBrwTMP	:= FWmBrowse():New()

oBrwTMP:SetAlias( "F5C" )
oBrwTMP:SetDescription( STR0001  ) //"Tariff Rates"  
oBrwTMP:DisableDetails() 
Return oBrwTMP
//-------------------------------------------------------------------

/*{Protheus.doc} ModelDef()
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
 Local oModel        	as Object
 Local oStrF5C       	as Object
 Local oModelEvent 		as object
 
oModel:= MPFormModel():New("RU07D08", /*bPreValid*/,/*bUpdBrw*/ , /* */, /*bCancel*/)
oStrF5C :=  FWFormStruct(1, "F5C")

oModel:SetDescription( STR0001 ) //"Tariff Rates"
oModel:AddFields("F5CMASTER", Nil, oStrF5C)

Return oModel
//-------------------------------------------------------------------

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
Local oStructF5C as Object

oModel := FWLoadModel("RU07D08")
oStructF5C := FWFormStruct(2, "F5C")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_F5CM", oStructF5C, "F5CMASTER" )

oView:CreateHorizontalBox("HEADERBOX", 100)

oView:SetOwnerView("VIEW_F5CM", "HEADERBOX")

oView:SetCloseOnOk({|| .T.})

Return oView
//-------------------------------------------------------------------

/*{Protheus.doc} MenuDef
	(long_description)
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	*/
 Static Function MenuDef()
 Local aMenu as Array

 aMenu := { {STR0004, "VIEWDEF.RU07D08", 0, 3, 0, Nil} ,; // "Add" 
 			{STR0005, "VIEWDEF.RU07D08", 0, 4, 0, Nil} ,; // "Edit"
			{STR0006, "VIEWDEF.RU07D08", 0, 2, 0, Nil} ,; // "View"
			{STR0008, "PesqBrw", 0, 1, 0, Nil} ,; // "Search"
			{STR0007, "VIEWDEF.RU07D08", 0, 5, 0, Nil} } // "Delete"

	// aMenu := FWMVCMenu( 'RU07D08' )
return aMenu
//-------------------------------------------------------------------