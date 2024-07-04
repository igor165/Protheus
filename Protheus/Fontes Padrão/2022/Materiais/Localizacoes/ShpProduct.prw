#INCLUDE "TOTVS.CH"
#INCLUDE "Shopify.ch"
#INCLUDE "ShopifyExt.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} ShpProduct
    Class used to integrate Shopify's Product
    @author Yves Oliveira
    @since 26/02/2020
    /*/
Class ShpProduct From ShpBase
    
    Data title        As String
    Data warehouse    As String
    Data vendor       As String
    Data bodyHtml     As String
    Data tags         As String
    Data type         As String
   
    Method new() Constructor
    Method setRequestBody()
    Method getVariantObj()
    Method getSb2Recno(cProduct)
    Method getUrlImg()
    Method procResponse(oResponse,cResponse)
EndClass

/*/{Protheus.doc} new
This method sets the constructor
@author Yves Oliveira
@since 26/02/2020
@type method
/*/
Method new() Class ShpProduct
    ::title    := ""
    ::vendor   := ""
    ::bodyHtml := ""
    ::tags     := ""
    ::type     := ""

    ::cIntegration := ID_INT_PRODUCT
    _Super:new()
Return


/*/{Protheus.doc} setRequestBody
    Method to create a request body
    @author Yves Oliveira
    @since 26/02/2020
    @version version
/*/
Method setRequestBody() Class ShpProduct
    Local lRet      := .F.
    Local oJsonRoot := Nil
    Local oJsonReq  := Nil
    Local oJsonOpt  := Nil
    
    BEGIN SEQUENCE
        oJsonRoot := JsonObject():new()
        oJsonReq  := JsonObject():new()
        oJsonOpt  := JsonObject():new() 

        oJsonRoot["product"] := Nil

        oJsonReq["title"       ] := ::title
        oJsonReq["vendor"      ] := ::vendor
        oJsonReq["body_html"   ] := ::bodyHtml
        oJsonReq["tags"        ] := ::tags
        oJsonOpt["name"        ] := "Size"
        oJsonReq["options"     ] := { oJsonOpt }
        oJsonReq["product_type"] := ::type
        
        oJsonRoot["product" ] := oJsonReq

        ::body := oJsonRoot:ToJson()

        lRet := .T.

    END SEQUENCE
Return lRet


/*/{Protheus.doc} procResponse
    Method for processing the API response
    @author Yves Oliveira
    @since 13/03/2020
    /*/
Method procResponse(oResponse,cResponse) Class ShpProduct
    Local cIdVar := ""
    Local lNew    := .F.
    
    If Empty(::idExt)//New Product
        ::idExt := cValToChar(oResponse:product:id)
        cIdVar  := cValToChar(oResponse:product:variants[1]:id)
        lNew := .T.
    EndIf
    
    Begin Transaction
        ShpSaveId(SHP_ALIAS_PRODUCT, ::id,::idExt)
        //Shopify always creates a product with a default variant, so this variant record is being saved to be replaced later by the first SB1 variant created            
        If lNew
            ShpSaveId(SHP_ALIAS_DEFAULT_VARIANT, ::id,cIdVar, SHP_ALIAS_PRODUCT, ::id)
        EndIf
        
    End Transaction
    
Return
