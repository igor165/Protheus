#INCLUDE "TOTVS.CH"
#INCLUDE "Shopify.ch"
#INCLUDE "ShopifyExt.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} ShpVariant
    Class used to integrate Shopify's Product Variants. This class is inherited from ShpBase
    @author Yves Oliveira
    @since 08/04/2020
    /*/
Class ShpVariant From ShpBase
    
    Data idProduct       As String
    Data idExtProduct As String
    Data title        As String
    Data position     As Integer
    Data barcode      As String 
    Data grams        As Float  
    Data price        As Float  
    Data sku          As String 
    Data taxable      As Boolean
    Data weight       As Float  
    Data weightUnit   As String 
    Data delete     As Boolean
    
    Method new() Constructor
    Method setVerb(cVerb)
    Method setPath(cPath)
    Method setRequestBody()
    Method procResponse(oResponse,cResponse)
EndClass

/*/{Protheus.doc} new
This method sets the constructor
@author Yves Oliveira
@since 26/02/2020
@type method
/*/
Method new() Class ShpVariant
    ::idExtProduct := ""
    ::idProduct       := ""
    ::title        := ""
    ::barcode      := "" 
    ::grams        := Nil
    ::price        := Nil
    ::sku          := "" 
    ::taxable      := Nil
    ::weight       := Nil
    ::weightUnit   := "" 
    ::position     := 1
    ::delete       := .F.
    
    ::cIntegration := ID_INT_VARIANT
    _Super:new()
Return

/*/{Protheus.doc} new
Method to set the verb
@author Yves Oliveira
@since 28/04/2020
@type method
/*/
Method setVerb(cVerb) class ShpVariant
    If ::delete
        ::verb := REST_METHOD_DELETE
    Else
        _Super:setVerb()
    EndIf    
Return .T.

/*/{Protheus.doc} new
This method sets the API path
@author Yves Oliveira
@since 08/04/2020
@type method
/*/
Method setPath(cPath) Class ShpVariant
    Local lRet := .T.
    If ::delete
        ::path := "/admin/api/" + ::apiVer + "/" + Lower(ID_INT_PRODUCT)  + "/" + AllTrim(::idExtProduct) + "/" + Lower(::cIntegration) + "/" + AllTrim(::idExt) + ".json"
    ElseIf !Empty(::idExt) .And. Val(::idExt) > 0
        ::path := "/admin/api/" + ::apiVer + "/" + Lower(::cIntegration) + "/" + AllTrim(::idExt) +  ".json"
    Else
        ::path := "/admin/api/" + ::apiVer + "/" + Lower(ID_INT_PRODUCT)  + "/" + AllTrim(::idExtProduct) + "/" + Lower(::cIntegration) + ".json"
    EndIf
Return lRet


/*/{Protheus.doc} setRequestBody
    Method to create a request body
    @author Yves Oliveira
    @since 08/04/2020
    @version version
/*/
Method setRequestBody() Class ShpVariant
    Local lRet      := .F.
    Local oJsonRoot := Nil
    Local oJsonReq  := Nil
    
    BEGIN SEQUENCE
        If ::delete
            ::body = "{}"
        Else
            oJsonRoot := JsonObject():new()
            oJsonReq  := JsonObject():new() 
            
            oJsonRoot["variant"] := Nil
            oJsonReq["inventory_management"] := "shopify"

            If ::idExt <> Nil .And. Val(::idExt) > 0
                oJsonReq["id"] := AllTrim(::idExt)
            EndIf

            oJsonReq["title"     ] := ::title
            oJsonReq["option1"   ] := ::title
            oJsonReq["position"  ] := ::position
            oJsonReq["barcode"   ] := ::barcode
            oJsonReq["grams"     ] := ::grams
            oJsonReq["price"     ] := ::price
            oJsonReq["sku"       ] := ::sku
            oJsonReq["taxable"   ] := ::taxable
            oJsonReq["weight"    ] := ::weight
            oJsonReq["weightUnit"] := ::weightUnit
            oJsonRoot["variant"  ] := oJsonReq            
            
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
Method procResponse(oResponse,cResponse) Class ShpVariant
    Local cIdInv  := ""
    Local nRecAux := 0
    
    If !::delete 
        ::idExt := cValToChar(oResponse:variant:id)
        cIdInv  := cValToChar(oResponse:variant:inventory_item_id)

        Begin Transaction
            nRecAux := ShpSb2Rec(::sku)

            ShpSaveId(SHP_ALIAS_VARIANT, ::id, ::idExt, SHP_ALIAS_PRODUCT, ::idProduct)
            ShpSaveId(SHP_ALIAS_INVENTORY, cValToChar(nRecAux), cIdInv, SHP_ALIAS_VARIANT, ::id)
        End Transaction
    EndIf
    
Return
