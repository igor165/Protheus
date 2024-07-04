#INCLUDE "TOTVS.CH"
#INCLUDE "Shopify.ch"
#INCLUDE "ShopifyExt.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} ShpCollect
    Class to send the link between product and custom collection
    @author Yves Oliveira
    @since 26/03/2020
    /*/
Class ShpCollect From ShpBase
    Data collection As String
    Data productId  As String
    Data recnoProd  As String
    
    Method new() Constructor
    Method setRequestBody()
    Method procResponse(oResponse,cResponse)
    Method setVerb(cVerb)
    
EndClass

/*/{Protheus.doc} new
This method sets the constructor
@author Yves Oliveira
@since 26/03/2020
@type method
/*/
Method new() Class ShpCollect
    ::recnoProd  := ""
    ::collection := ""
    ::productId  := ""
    
    ::cIntegration := ID_INT_COLLECT
    _Super:new()
Return

/*/{Protheus.doc} new
Method to set the verb
@author Yves Oliveira
@since 26/02/2020
@type method
/*/
Method setVerb(cVerb) class ShpCollect
    ::verb := REST_METHOD_POST
Return .T.

/*/{Protheus.doc} setRequestBody
    Method to create a request body
    @author Yves Oliveira
    @since 26/03/2020
    @version version
/*/
Method setRequestBody() Class ShpCollect
    Local lRet      := .F.
    Local oJsonRoot := Nil
    Local oJsonReq  := Nil
    
    BEGIN SEQUENCE
        oJsonRoot := JsonObject():new()
        oJsonReq  := JsonObject():new() 
        
        oJsonRoot["collect"] := Nil

         If !Empty(::idExt)
            oJsonReq["id"] := AllTrim(::idExt)
        Endif
        oJsonReq["product_id"   ] := AllTrim(::productId)
        oJsonReq["collection_id"] := AllTrim(::collection)
        oJsonRoot["collect"]      := oJsonReq

        ::body := oJsonRoot:ToJson()

        lRet := .T.

    END SEQUENCE
Return lRet

/*/{Protheus.doc} procResponse
    Method for processing the API response
    @author Yves Oliveira
    @since 26/03/2020
    /*/
Method procResponse(oResponse,cResponse) Class ShpCollect
    ::idExt := cValToChar(oResponse:collect:id)
    
    ShpSaveId(SHP_ALIAS_COLLECT, ::id, ::idExt, SHP_ALIAS_PRODUCT, ::recnoProd)
Return
