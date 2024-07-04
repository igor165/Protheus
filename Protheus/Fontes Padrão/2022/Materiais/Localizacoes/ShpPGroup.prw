#INCLUDE "TOTVS.CH"
#INCLUDE "Shopify.ch"
#INCLUDE "ShopifyExt.ch"

/*/{Protheus.doc} ShpPGroup
    Class used for Shopify Custom Collections integration
    @author Yves Oliveira
    @since 17/02/2020
    @version 1
    /*/
Class ShpPGroup From ShpBase

    Data title  	As String
    Data code   	As String
    Data bodyHtml   As String    
    
    Method new() Constructor
    Method setRequestBody()
    Method isIntValid()
    Method procResponse(oResponse,cResponse)

EndClass

/*/{Protheus.doc} new
This method sets the constructor
@author Yves Oliveira
@since 17/02/2020
@type method
/*/
Method new() Class ShpPGroup
   ::cIntegration := ID_INT_CUSTOM_COLLECTION
   ::title := ""
   ::code  := ""
   ::bodyHtml := ""   
   _Super:new()
Return


/*/{Protheus.doc} setRequestBody
    Method to create a request body
    @author Yves Oliveira
    @since 17/02/2020
    @version version
/*/
Method setRequestBody() Class ShpPGroup
    Local oJsonRoot := JsonObject():new()
    Local oJsonReq  := JsonObject():new() 
    
    oJsonRoot["custom_collection"] := Nil

    If !Empty(::idExt)
        oJsonReq["id"] := ::idExt
    Endif
    oJsonReq["title"]     			:= ::title
    oJsonReq["body_html"   ] 		:= ::bodyHtml    
    oJsonRoot["custom_collection"] 	:= oJsonReq
    ::body := oJsonRoot:ToJson()
Return .T.

/*/{Protheus.doc} isIntValid
    Method to implement validations
    @author Yves Oliveira
    @since 02/03/2020
    /*/
Method isIntValid() Class ShpPGroup
    Local lRet := .T.
    If Empty(::title)
        ::error := STR0131 //"[Title] is required"
        lRet := .F.
    Endif
    
Return lRet

/*/{Protheus.doc} procResponse
    Method for processing the API response
    @author Yves Oliveira
    @since 26/03/2020
    /*/
Method procResponse(oResponse,cResponse) Class ShpPGroup
    
    Local nVarNameLen := SetVarNameLen(100)

    ::idExt := cValToChar(oResponse:custom_collection:id)
    
    Begin Transaction
        ShpSaveId(SHP_ALIAS_CUSTOM_COLLECTION, ::id, ::idExt)
    End Transaction
    
    SetVarNameLen(nVarNameLen)
Return 
