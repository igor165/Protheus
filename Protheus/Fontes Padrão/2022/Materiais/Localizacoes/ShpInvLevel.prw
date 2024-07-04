#INCLUDE "TOTVS.CH"
#INCLUDE "Shopify.ch"
#INCLUDE "ShopifyExt.ch"

/*/{Protheus.doc} ShpInvLevel
    Class used to integrate Shopify's Inventory Level
    @author Yves Oliveira
    @since 26/03/2020
    /*/
Class ShpInvLevel From ShpBase
    Data inventId   As String//Invetory item Id
    Data locationId As String// Location Id
    Data quantity   As Float

    Method new() Constructor
    Method setRequestBody()
    Method setVerb(cVerb)
    Method setPath()
    Method procResponse(oResponse,cResponse)
EndClass

/*/{Protheus.doc} new
This method sets the constructor
@author Yves Oliveira
@since 268/03/2020
@type method
/*/
Method new() Class ShpInvLevel
    ::inventId     := ""
    ::locationId   := ""
    ::quantity     := Nil
    ::cIntegration := ID_INT_INVENTORY_LEVEL
    ::verb         := REST_METHOD_POST
    _Super:new()
Return

/*/{Protheus.doc} new
Method to set the verb
@author Yves Oliveira
@since 28/04/2020
@type method
/*/
Method setVerb(cVerb) class ShpInvLevel
    ::verb := REST_METHOD_POST
Return .T.

/*/{Protheus.doc} new
This method sets the API path
@author Yves Oliveira
@since 28/03/2020
@type method
/*/
Method setPath() Class ShpInvLevel
    Local lRet := .T.
    ::path := "/admin/api/" + ::apiVer + "/" + Lower(::cIntegration) + "/set.json"
Return lRet

/*/{Protheus.doc} setRequestBody
    Method to create a request body
    @author Yves Oliveira
    @since 26/02/2020
    @version version
/*/
Method setRequestBody() Class ShpInvLevel
    Local lRet      := .F.
    Local oJsonRoot := Nil
    
    BEGIN SEQUENCE
        oJsonRoot := JsonObject():new()

        oJsonRoot["location_id"      ] := ::locationId
        oJsonRoot["inventory_item_id"] := ::inventId
        oJsonRoot["available"        ] := ::quantity

        ::body := oJsonRoot:ToJson()

        lRet := .T.

    END SEQUENCE
Return lRet

/*/{Protheus.doc} procResponse
    Method for processing the API response
    @author Yves Oliveira
    @since 13/03/2020
    /*/
Method procResponse(oResponse,cResponse) Class ShpInvLevel
    Local nRecnoSB2  := 0
    Local nRecnoSb1  := ""
    Local aArea      := GetArea()
    Local aAreaSB1   := {}
    Local cUpdatedAt := ""

    ::idExt    := cValToChar(oResponse:inventory_level:inventory_item_id)
    cUpdatedAt := oResponse:inventory_level:updated_at
    
    nRecnoSb1 := ShpInvInf(::idExt, "SB1.R_E_C_N_O_")
    DbSelectArea("SB1")
    aAreaSB1 := SB1->(GetArea())
    SB1->(DbGoTo(nRecnoSb1))

    nRecnoSB2 := ShpSb2Rec(SB1->B1_COD)
    
    ShpSaveId(SHP_ALIAS_INVENTORY, cValToChar(nRecnoSB2), ::idExt, SHP_ALIAS_VARIANT, cValToChar(nRecnoSb1), cUpdatedAt)
    
    RestArea(aArea)
    RestArea(aAreaSB1)
Return
