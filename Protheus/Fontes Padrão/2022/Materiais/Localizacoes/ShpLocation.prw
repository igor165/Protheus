#INCLUDE "TOTVS.CH"
#INCLUDE "SHOPIFY.CH"
#INCLUDE "ShopifyExt.ch"

/*/{Protheus.doc} ShpLocation
    Class to get the location from Shopify
    @author Yves Oliveira
    @since 28/03/2020
    @version version
    /*/
Class ShpLocation From ShpBase
    Method new() Constructor
    Method setVerb(cVerb)
    Method setRequestBody()
    Method procResponse(oResponse,cResponse)
EndClass

/*/{Protheus.doc} new
This method sets the constructor
@author Yves Oliveira
@since 28/03/2020
@type method
/*/
Method new() Class ShpLocation
    
    ::cIntegration := ID_INT_LOCATION
    _Super:new()
Return

/*/{Protheus.doc} new
This method sets the constructor
@author Yves Oliveira
@since 28/03/2020
@type method
/*/
Method setVerb(cVerb) class ShpLocation
    ::verb := REST_METHOD_GET
Return .T.


/*/{Protheus.doc} new
This method sets the constructor
@author Yves Oliveira
@since 28/03/2020
@type method
/*/
Method setRequestBody() class ShpLocation
    ::body := ""
Return .T.

/*/{Protheus.doc} procResponse
    Method for processing the API response
    @author Yves Oliveira
    @since 28/03/2020
    /*/
Method procResponse(oResponse,cResponse) Class ShpLocation
    Local aLocations := {}
    Local nI         := 0
    aLocations := aClone(oResponse:locations)

    For nI := 1 To Len(aLocations)
        If aLocations[nI]:active
            ::idExt := cValToChar(aLocations[nI]:id)
            Exit
        EndIf
    Next nI
    
    If !Empty(::idExt)
        ShpSaveId(SHP_ALIAS_LOCATION, ::id, ::idExt)
    EndIf
    
Return
