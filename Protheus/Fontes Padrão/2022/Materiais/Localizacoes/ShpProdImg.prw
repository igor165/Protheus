#INCLUDE "TOTVS.CH"
#INCLUDE "Shopify.ch"
#INCLUDE "ShopifyExt.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} ShpProdImg
    Class used to integrate Shopify's Product Images
    @author Yves Oliveira
    @since 09/04/2020
    /*/
Class ShpProdImg From ShpBase
    Data source     As String
    Data productId  As String
    Data productRec As String
    Data variantId  As String
    Data position   As String
    Data delete     As Boolean

    Method new() Constructor
    Method setPath(cPath)
    Method setVerb(cVerb)
    Method setRequestBody()
    Method procResponse(oResponse,cResponse)
EndClass

/*/{Protheus.doc} new
This method sets the constructor
@author Yves Oliveira
@since 09/04/2020
@type method
/*/
Method new() Class ShpProdImg
    ::source    := ""
    ::productId := ""
    ::productRec:= ""
    ::variantId := ""
    ::position  := 0
    ::delete    := .F.
    ::cIntegration := ID_INT_IMAGE
    _Super:new()
Return

/*/{Protheus.doc} new
This method sets the API path
@author Yves Oliveira
@since 09/04/2020
@type method
/*/
Method setPath(cPath) Class ShpProdImg
    Local lRet := .T.
    If !Empty(::idExt) .And. Val(::idExt) > 0
        ::path := "/admin/api/" + ::apiVer + "/" + Lower(ID_INT_PRODUCT)  + "/" + AllTrim(::productId) + "/" + Lower(::cIntegration) + "/" + AllTrim(::idExt) + ".json"//PUT
    Else
        ::path := "/admin/api/" + ::apiVer + "/" + Lower(ID_INT_PRODUCT)  + "/" + AllTrim(::productId) + "/" + Lower(::cIntegration) + ".json"//POST
    EndIf
Return lRet

/*/{Protheus.doc} new
Method to set the verb
@author Yves Oliveira
@since 17/04/2020
@type method
/*/
Method setVerb(cVerb) class ShpProdImg
    If ::delete
        ::verb := REST_METHOD_DELETE
    Else
        _Super:setVerb()
    EndIf    
Return .T.

/*/{Protheus.doc} setRequestBody
    Method to create a request body
    @author Yves Oliveira
    @since 09/04/2020
    @version version
/*/
Method setRequestBody() Class ShpProdImg
    Local lRet      := .F.
    Local oJsonRoot := Nil
    Local oJsonReq  := Nil
    
    BEGIN SEQUENCE
        If ::delete
            ::body = "{}"
        Else
            oJsonRoot := JsonObject():new()
            oJsonReq  := JsonObject():new() 
            
            oJsonRoot["image"] := Nil
            
            If ::idExt <> Nil .And. Val(::idExt) > 0
                oJsonReq["id"] := AllTrim(::idExt)
            EndIf

            oJsonReq["src"        ] := ::source
            oJsonReq["position"   ] := ::position
            oJsonReq["variant_ids"] := { ::variantId }
            
            oJsonRoot["image"] := oJsonReq            
            
            ::body := oJsonRoot:ToJson()
        EndIf

        lRet := .T.

    END SEQUENCE
Return lRet

/*/{Protheus.doc} procResponse
    Method for processing the API response
    @author Yves Oliveira
    @since 13/03/2020
    /*/
Method procResponse(oResponse,cResponse) Class ShpProdImg
        
     If !::delete   
        ::idExt := cValToChar(oResponse:image:id)
        
        ShpSaveId(SHP_ALIAS_IMAGE, ::id, ::idExt, SHP_ALIAS_PRODUCT, ::productRec)
    EndIf
    
Return
