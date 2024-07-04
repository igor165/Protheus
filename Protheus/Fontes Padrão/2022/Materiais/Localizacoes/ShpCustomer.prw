#INCLUDE "TOTVS.CH"
#INCLUDE "Shopify.ch"
#INCLUDE "ShopifyExt.ch"

/*/{Protheus.doc} ShpCustomer
    Class used to integrate Shopify's Customers
    @author Yves Oliveira
    @since 27/02/2020
    @version version
    /*/
Class ShpCustomer From ShpBase
    Data oCustomer As Object

    Data email     As String
    Data firstName As String
    Data lastName  As String
    Data phone     As String

    //Address
    Data address1    As String
    Data address2    As String
    Data city        As String
    Data comapny     As String
    Data country     As String
    Data addressId   As Float
    Data addrFName   As String
    Data addrLName   As String
    Data addrPhone   As String
    Data province    As String
    Data zip         As String
    Data countryCode As String
    Data default     As Boolean
    Data taxsetting  As String
    //Address

    Method new() Constructor
    Method getAddrObj()
    Method setRequestBody(cBody)
    Method procResponse(oResponse,cResponse)
    
EndClass


/*/{Protheus.doc} new
    (long_description)
    @author Yves Oliveira
    @since 27/02/2020
    /*/
Method new() Class ShpCustomer
    ::cIntegration := ID_INT_CUSTOMER
    
    ::email     := ""
    ::firstName := ""
    ::lastName  := ""
    ::phone     := ""

    //Address
    ::address1    := ""
    ::address2    := ""
    ::city        := ""
    ::comapny     := ""
    ::country     := ""
    ::addressId   := Nil
    ::addrFName   := ""
    ::addrLName   := ""
    ::addrPhone   := ""
    ::province    := ""
    ::zip         := ""
    ::countryCode := ""
    ::default     := .T.

    //Tax
    ::taxsetting  := ""

    _Super:new()
Return 

/*/{Protheus.doc} getAddrObj
    Method to create an address JSON object
    @author Yves Oliveira
    @since 27/02/2020
    /*/
Method getAddrObj() Class ShpCustomer
    Local oJsonAddr := JsonObject():new() 
    Local lFilled   := .F.

    If !Empty(::address1)
        oJsonAddr["address1"] := ::address1
        lFilled := .T.
    EndIf

    If !Empty(::address2)
        oJsonAddr["address2"] := ::address2
        lFilled := .T.
    EndIf

    If !Empty(::city)
        oJsonAddr["city"] := ::city
        lFilled := .T.
    EndIf
    
    If !Empty(::comapny)
        oJsonAddr["company"] := ::comapny
        lFilled := .T.
    EndIf

    If !Empty(::country)
        oJsonAddr["country"] := ::country
        lFilled := .T.
    EndIf
    
    If ::addressId <> Nil .And. Val(::addressId) > 0
        oJsonAddr["id"] := AllTrim(::addressId)
        lFilled := .T.
    EndIf
    
    If !Empty(::addrFName)
        oJsonAddr["first_name"] := ::addrFName
        lFilled := .T.
    EndIf
    
    If !Empty(::addrLName)
        oJsonAddr["last_name"] := ::addrLName
        lFilled := .T.
    EndIf


    //incluido pelo izo para dizer se o cliente é taxado sim ou  nao
    If !Empty(::taxsetting)
        oJsonAddr["tax_exempt"] := ::taxsetting
        lFilled := .T.
    EndIf
    
    If !Empty(::addrPhone)
        oJsonAddr["addrPhone"] := ::addrPhone
        lFilled := .T.
    EndIf
    
    If !Empty(::province)
        oJsonAddr["province"] := ::province
        lFilled := .T.
    EndIf
    
    If !Empty(::zip)
        oJsonAddr["zip"] := ::zip
        lFilled := .T.
    EndIf
    
    If !Empty(::countryCode)
        oJsonAddr["countryCode"] := ::countryCode
        lFilled := .T.
    EndIf
    
    If ::default <> Nil
        oJsonAddr["default"] := ::default
        lFilled := .T.
    EndIf


Return oJsonAddr

/*/{Protheus.doc} setRequestBody
    Method to create a request body
    @author Yves Oliveira
    @since 27/02/2020
    /*/
Method setRequestBody(cBody) Class ShpCustomer
    Local lRet      := .F.
    Local oJsonRoot := Nil
    Local oJsonCust := Nil
    Local oJsonAddr := Nil
    Local oJsonAux  := Nil
    Local aAddress  := {}

    BEGIN SEQUENCE
        If cBody <> Nil
            ::body := cBody
        Else
            If Empty(::body)
                oJsonRoot := JsonObject():new()
                oJsonCust := JsonObject():new() 
                oJsonAddr := JsonObject():new()

                oJsonRoot["customer"] := Nil

                oJsonAux := ::getAddrObj()
                If oJsonAux <> Nil
                    Aadd(aAddress,oJsonAux)
                    oJsonAddr["addresses"] := aAddress
                    oJsonCust:set(oJsonAddr)
                EndIf

                If !Empty(::idExt)
                    oJsonCust["id"] := AllTrim(::idExt)
                Endif
                oJsonCust["first_name"] := ::firstName
                oJsonCust["last_name" ] := ::lastName
                oJsonCust["tax_exempt"] := ::taxsetting //incluido pelo izo 
                oJsonCust["email"    ]  := ::email
                oJsonCust["phone"    ]  := ::phone
                oJsonRoot["customer" ]  := oJsonCust

                ::body := oJsonRoot:ToJson()
            EndIf
        EndIf

        lRet := .T.
    END SEQUENCE
    
Return lRet

/*/{Protheus.doc} procResponse
    Method for processing the API response
    @author Yves Oliveira
    @since 13/03/2020
    /*/
Method procResponse(oResponse,cResponse) Class ShpCustomer
    Local cIdEnd := ""
    
    If ::verb == REST_METHOD_GET
        ::oCustomer := oResponse
    Else
        ::idExt := cValToChar(oResponse:customer:id)
        cIdEnd  := cValToChar(oResponse:customer:addresses[1]:id)
        
        Begin Transaction
            ShpSaveId(SHP_ALIAS_CUSTOMER, ::id, ::idExt)
            ShpSaveId(SHP_ALIAS_CUSTOMER_ADDRESS, ::id, cIdEnd, SHP_ALIAS_CUSTOMER, ::id)
        End Transaction
    EndIf
    
Return
