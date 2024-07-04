#Include 'Protheus.ch'
#INCLUDE 'TMSAC15.CH'
//-----------------------------------------------------------------
/*/{Protheus.doc} TMSBCARepomFrete()
Classe criada para comunicação com a REPOM

@author Caio Murakami
@since 15/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
CLASS TMSBCARepomFrete

    //-- Auth
    DATA url_repom      As Character
    DATA grant_type     As Character
    DATA username       As Character
    DATA password       As Character
    DATA partner        As Character 
    DATA api_version    As Character
    DATA access_token   As Character
    DATA expires        As Numeric

    //-- Dados Cliente    
    DATA deg_codope     As Character

    //-- Driver
    DATA driver_codigo              As Character
    DATA driver_country             As Character
    DATA driver_national_id         As Character
    DATA driver_license_number      As Character
    DATA driver_address_street      As Character
    DATA driver_address_number      As Character
    DATA driver_address_complement  As Character
    DATA driver_address_neighborhood As Character
    DATA driver_address_zipcode     As Character
    DATA driver_phone_areacode      As Character
    DATA driver_phone_number        As Character
    DATA driver_phone_preferential  As Logical
    DATA driver_phone_typeid        As Character
    DATA driver_birthdate           As Character //-- FwTimeStamp
    DATA driver_name                As Character
    DATA driver_gender              As Character

    //-- Hired
    DATA hired_codigo               As Character
    DATA hired_loja                 As Character
    DATA hired_country              As Character
    DATA hired_type                 As Character
    DATA hired_national_id          As Character
    DATA hired_email                As Character
    DATA hired_phone_areacode       As Character
    DATA hired_phone_number         As Character
    DATA hired_phone_preferential   As Logical
    DATA hired_phone_typeid         As Character
    DATA hired_rntrc                As Character
    DATA hired_inss                 As Character
    DATA hired_rg                   As Character
    DATA hired_ie                   As Character
    DATA hired_im                   As Character
    DATA hired_nomefantasia         As Character
    DATA hired_simplesnacional      As Logical
    DATA hired_address_street       As Character
    DATA hired_address_number       As Character
    DATA hired_address_complement   As Character
    DATA hired_address_neighboorhod As Character
    DATA hired_address_zipcode      As Character
    DATA hired_companyname          As Character
    DATA hired_name                 As Character
    DATA hired_birthdate            As Character
    DATA hired_gender               As Character
    DATA hired_dependents           As Numeric
    DATA hired_fuelvoucher_percent  As Character
    
    //-- Vehicle
    DATA vehicle_codigo         As Character
    DATA vehicle_country        As Character
    DATA vehicle_licenseplate   As Character
    DATA vehicle_classification As Character
    DATA vehicle_category       As Character
    DATA vehicle_axles          As Character
    DATA vehicle_type           As Character
    DATA vehicle_owner_country  As Character
    DATA vehicle_owner_id       As Character
    DATA vehicle_owner_rntrc    As Character 
    DATA vehicle_owner_nomefantasia As Character
    DATA vehicle_owner_type     As Character
    DATA vehicle_owner_name     As Character

    //-- Route
    DATA route_BranchIdentifier     As Character
    DATA route_OriginIBGECode       As Character
    DATA route_DestinyIBGECode      As Character
    DATA route_RoundTrip            As Logical
    DATA route_Note                 As Character
    DATA route_TraceIdentifier      As Character
    DATA route_ShippingPaymentPlaceType     As Character
    DATA route_PreferredWays        As Array
    
    //-- Shipping informations
    DATA shipp_id                       As Character
    DATA shipp_country                  As Character
    DATA shipp_hiredcountry             As Character
    DATA shipp_HiredNationalId          As Character
    DATA shipp_OperationIdentifier      As Character
    DATA shipp_CardNumber               As Numeric
    DATA shipp_VPRCardNumber            As Numeric
    DATA shipp_BrazilianRouteTraceCode  As Numeric
    DATA shipp_BrazilianRouteRouteCode  As Numeric
    DATA shipp_IssueDate                As Character
    DATA shipp_TotalFreightValue        As Numeric
    DATA shipp_TotalLoadWeight          As Numeric
    DATA shipp_TotalLoadValue           As Numeric
    DATA shipp_AdvanceMoneyValue        As Numeric
    DATA shipp_vpr_issue                As Logical 
    DATA shipp_vpr_OneWay               As Logical 
    DATA shipp_vpr_SuspAxle             As Numeric 
    DATA shipp_vpr_ReturnSuspAxle       As Numeric 
    DATA shipp_drivers                  As Array
    DATA shipp_documents                As Array  
    DATA shipp_vehicles                 As Array 
    DATA shipp_shippreceiver            As Array 
    DATA shipp_shipppay_date            As Character
    DATA shipp_shipppay_type            As Character 
    DATA shipp_BranchCode               As Character
    DATA shipp_LoadBrazilianNCM         As Character
    DATA shipp_LoadBrazilianANTTCodeType    As Numeric
    DATA shipp_br_ibgesource            As Character
    DATA shipp_br_ibgedest              As Character
    DATA shipp_br_cepsource             As Character
    DATA shipp_br_cepdest               As Character
    DATA shipp_TravelledDistance        As Numeric
    DATA shipp_OperationKey             As Character
    DATA shipp_taxes                    As Array 
    
    DATA shipp_receive_Country          As Character
    DATA shipp_receive_NationalId       As Character
    DATA shipp_receive_Name             As Character  
    DATA shipp_receive_ReceiverType     As Character

    //-- Shipping Payment    
    DATA payment_BranchCode         As Character
    DATA payment_ShippingID         As Character
    DATA payment_TotalUnloadWeight  As Numeric
    DATA payment_Documents          As Array
    
    //-- Payment Authorization
    DATA auth_autorizations     As Array 

    DATA last_error As Character
    DATA message_error As Array 
    DATA exibe_erro As Logical 

    METHOD New()    Constructor  
    METHOD NewDriver()  
    METHOD ExibeErro()
    METHOD GetDriverInfo()
    METHOD RepomInfo()
    METHOD IsTokenActive()
    METHOD NewHired()
    METHOD GetHiredInfo()
    METHOD NewVehicle()
    METHOD GetVehicleInfo()
    METHOD RetCategory()
    METHOD RetVehicleType()
    METHOD NewRoute()
    METHOD GetRouteInfo()
    METHOD NewShipping()
    METHOD GetShippingInfo()
    METHOD GetIdShipping()
    METHOD NewPayment()
    METHOD PaymentInfo()
    METHOD NewAuthorization()
    METHOD AuthInfo()   

    //-- Token
    METHOD Auth()           //-- POST /token    
    //-- Driver
    METHOD DriverCreate()   //-- POST /Driver
    METHOD DriverUpdate()   //-- PUT /Driver/{country}/{nationalId}
    METHOD DriverLock()     //-- PATCH /Driver/lockUnlock/{country}/{nationalId}
    METHOD GetDrvrByName()  //-- GET /Driver/ByName/{name}
    METHOD GetDrvrByDoc()   //-- GET /Driver/ByDocument/{country}/{nationalId}
    //-- Hired
    METHOD HiredCreate()    //-- POST /Hired
    METHOD HiredUpdate()    //-- PUT /Hired/{country}/{nationalId}
    METHOD HiredLock()      //-- PATCH /Hired/lockUnlock/{country}/{nationalId}
    METHOD GetHrdByName()   //-- GET /Hired/ByName/{name}
    METHOD GetHrdByDoc()    //-- GET /Hired/ByDocument/{country}/{nationalId}
    //-- Vehicle
    METHOD VehicleCreate()  //-- POST /Vehicle
    METHOD VehicleUpdate()  //-- PUT /Vehicle/{country}/{license}
    METHOD VehicleLock()    //-- PATCH /Vehicle/{country}/{license}
    METHOD GetVeicByDoc()   //-- GET /Vehicle/ByDocument/{country}/{license}    
    //-- Route
    METHOD RouteCreate()    //-- POST /RouteRequest
    METHOD GetRtByCEP()     //-- GET /Route/ByCEP/{cep}/{toCep}/{vehicleAxles}
    METHOD GetRtByIBGE()    //-- GET /Route/ByIBGE/{IBGECode}/{toIBGECode}/{vehicleAxles}
    METHOD GetRtByTrcId()   //-- GET /Route/ByTraceIdentifier/{traceIdentifier}/{vehicleAxles}    
    METHOD GetByRtCode()    //-- GET /Route/ByRouteCode/{traceCode}/{routeCode}/{vehicleAxles}  
    
    //-- RouteRequest
    METHOD GetRtRequest()   //-- GET /RouteRequest/{traceIdentifier}
    //-- Shipping   
    METHOD ShippingCreate() //-- POST /Shipping
    METHOD ShippingDocAdd() //-- PATCH /Shipping/AddDocument/{shippingId}
    METHOD ShippingMovAdd() //-- PATCH /Shipping/AddMovement/{shippingId}
    METHOD ShippingCancel() //-- PATCH /Shipping/Cancel/{id}
    METHOD ShippingLock()   //-- PATCH /Shipping/lockUnlock/{shippingId}
    METHOD GetShipByShip()  //-- GET /Shipping/ByShipping/{shippingId}   
    METHOD GetShipById()    //-- GET /Shipping/ByIdentifier/{identifier}    
    METHOD ShippingInter()  //-- PATCH /Shipping/Interruption/{id}
    METHOD GetShipStPrcBy() //-- GET /Shipping/StatusProcessing/ByIdentifier/{id}
    METHOD ShippingAddTax() //-- PATCH /Shipping/AddTaxes
   
    //-- Shipping Payment
    METHOD PaymentCreate()  //-- POST /ShippingPayment
    METHOD PaymentCancel()  //-- PATCH /ShippingPayment/Cancel/{shippingID}
    METHOD PaymLostDoc()    //-- PATCH /ShippingPayment/DocumentLost/{shippingID}
    METHOD PaymReshipDoc()  //-- PATCH /ShippingPayment/DocumentReship/{shippingID}
    METHOD PaymDeliverDoc() //-- PATCH /ShippingPayment/DocumentDelivered/{shippingID}
    METHOD PaymDismisDoc()  //-- PATCH /ShippingPayment/DocumentDismissed/{shippingID}     
    //-- Shipping Validations
    METHOD GetShipVeicVld()     //-- GET /ShippingValidation/ByVehicles/{vehicles}
    METHOD GetShipHiredVld()    //-- GET /ShippingValidation/ByHiredDocument/{country}/{document}
    //-- Payment Authorization    
    METHOD AuthorizationCreate()    //-- POST /PaymentAuthorization               
    METHOD AuthCancel()             //-- PATCH /PaymentAuthorization/Cancel
    METHOD GetPayAutShip()          //-- GET /PaymentAuthorization/ByShippingId/{shippingId}
    //-- Card
    METHOD GetCardHired()   //-- GET /Card/GetActiveCardsByHired/{HiredNationalID}
    METHOD GetCardDriver()  //-- GET /Card/GetActiveCardsByDriver/{DriverNationalID}
    METHOD GetCardDvrHrd()  //-- GET /Card/GetActiveCardsByHiredAndByDriver/{HiredNationalID}/{DriverNationalID}
    //-- Load
    METHOD GetLoadTypes()   //-- GET /AnttTypes/LoadTypes
    //-- VPR
    METHOD GetVPR()         //-- GET /VPR/TollList/ByShippingIdentifier/{shippingIdentifier}
    //-- ShippingFuelBenefit
    METHOD GetFuelbyCard()  //-- GET /ShippingFuelBenefit/GetLinkByCardNumber/{cardNumber}
    //--Operation
    METHOD GetOperation()   //-- GET /Operation
    METHOD GetOperById()    //-- GET /Operation/ByIdentifier/{operationIdentifier}

    //-- Movements
    METHOD GetMovement()   //-- GET /Movement/GetMovement

    //-- Outros
    METHOD GetRepom()
    METHOD GetInfoArr()
    METHOD GetError()
    METHOD GetHiredCountry()
    METHOD RetDocType()
    METHOD GetRoteiro()
    METHOD Destroy()

END CLASS

//-----------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe

@author Caio Murakami
@since 15/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD New() CLASS TMSBCARepomFrete

    ::RepomInfo()
    ::NewDriver()
    ::NewHired()
    ::NewVehicle()
    ::NewRoute()
    ::NewShipping()
    ::NewPayment()
    ::NewAuthorization()

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} RepomInfo()
Método para carregar os dados de conexão.

@author Rodrigo Pirolo
@since 09/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD RepomInfo() CLASS TMSBCARepomFrete

    Local aArea         := GetArea()
    Local aAreaDEG      := DEG->(GetArea())
    Local cCodOpe       := "01"
    Local lRet          := .F.

    DbSelectArea("DEG")
    DEG->( DbSetOrder(1) )

    If DEG->( DbSeek( xFilial("DEG") + cCodOpe ) )
        ::url_repom     := AllTrim(DEG->DEG_URLWS) //"http://qa.repom.com.br/Repom.Frete.WebAPI"
        ::grant_type    := "password"
        ::username      := AllTrim(DEG->DEG_USER)   //"1601"
        ::password      := AllTrim(DEG->DEG_SENHA)  //"z=nF7v"
        ::partner       := AllTrim(DEG->DEG_CNPJOP) //"29081265000143"
        ::last_error    := ""
        ::message_error := {} 
        ::api_version   := "2.2"
        ::exibe_erro    := !IsBlind()
        ::access_token  := AllTrim(DEG->DEG_TOKEN)  //""
        ::deg_codope    := cCodOpe                  //-- REPOM
        ::expires       := DEG->DEG_EXPIRE
        lRet := .T.
    Else 
         ::url_repom    := ""
        ::grant_type    := ""
        ::username      := ""
        ::password      := ""
        ::partner       := ""
        ::last_error    := ""
        ::message_error := {} 
        ::api_version   := "2.2"
        ::exibe_erro    := !IsBlind()
        ::access_token  := "" 
        ::deg_codope    := cCodOpe                  //-- REPOM
        ::expires       := 0
    EndIf

    RestArea( aAreaDEG )
    RestArea(aArea)

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} NewDriver()
Método construtor da classe

@author Caio Murakami
@since 16/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD NewDriver() CLASS TMSBCARepomFrete

::driver_codigo                 := ""
::driver_country                := ""
::driver_national_id            := ""
::driver_license_number         := ""
::driver_address_street         := ""
::driver_address_number         := ""
::driver_address_complement     := ""
::driver_address_neighborhood   := ""
::driver_address_zipcode        := ""
::driver_phone_areacode         := ""
::driver_phone_number           := ""
::driver_phone_preferential     := .F.
::driver_phone_typeid           := ""
::driver_birthdate              := ""
::driver_name                   := ""
::driver_gender                 := ""

Return 

//-----------------------------------------------------------------
/*/{Protheus.doc} NewHired()
Método construtor da classe

@author Caio Murakami
@since 16/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD NewHired() CLASS TMSBCARepomFrete

::hired_codigo               := ""
::hired_loja                 := ""
::hired_country              := ""
::hired_type                 := ""
::hired_national_id          := ""
::hired_email                := ""
::hired_phone_areacode       := ""
::hired_phone_number         := ""
::hired_phone_preferential   := .F.
::hired_phone_typeid         := ""
::hired_rntrc                := ""
::hired_inss                 := ""
::hired_rg                   := ""
::hired_ie                   := ""
::hired_im                   := ""
::hired_nomefantasia         := ""
::hired_simplesnacional      := .F.
::hired_address_street       := ""
::hired_address_number       := ""
::hired_address_complement   := ""
::hired_address_neighboorhod := ""
::hired_address_zipcode      := ""
::hired_companyname          := ""
::hired_name                 := ""
::hired_birthdate            := ""
::hired_gender               := ""
::hired_dependents           := 0
::hired_fuelvoucher_percent  := ""

Return 

//-----------------------------------------------------------------
/*/{Protheus.doc} NewVehicle()
Método construtor da classe

@author Caio Murakami
@since 22/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD NewVehicle() CLASS TMSBCARepomFrete

::vehicle_codigo         := ""
::vehicle_country        := ""
::vehicle_licenseplate   := ""
::vehicle_classification := ""
::vehicle_category       := ""
::vehicle_axles          := ""
::vehicle_type           := ""
::vehicle_owner_country  := ""
::vehicle_owner_id       := ""
::vehicle_owner_rntrc    := ""
::vehicle_owner_nomefantasia := ""
::vehicle_owner_type     := ""

Return 

//-----------------------------------------------------------------
/*/{Protheus.doc} NewShipping()
Inicializa variaveis da rota

@author Caio Murakami
@since 24/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD NewShipping() CLASS TMSBCARepomFrete

::shipp_id                       := ""
::shipp_country                  := ""
::shipp_hiredcountry             := ""
::shipp_HiredNationalId          := ""
::shipp_OperationIdentifier      := ""
::shipp_CardNumber               := 0
::shipp_VPRCardNumber            := 0 
::shipp_BrazilianRouteTraceCode  := 0
::shipp_BrazilianRouteRouteCode  := 0
::shipp_IssueDate                := ""
::shipp_TotalFreightValue        := 0
::shipp_TotalLoadWeight          := 0
::shipp_TotalLoadValue           := 0
::shipp_AdvanceMoneyValue        := 0
::shipp_vpr_issue                := .F. 
::shipp_vpr_OneWay               := .F. 
::shipp_vpr_SuspAxle             := 0
::shipp_vpr_ReturnSuspAxle       := 0
::shipp_drivers                  := {}
::shipp_documents                := {}
::shipp_vehicles                 := {} 
::shipp_shippreceiver            := {}
::shipp_taxes                       := {} 
::shipp_shipppay_date            := ""
::shipp_shipppay_type            := ""
::shipp_BranchCode               := ""
::shipp_LoadBrazilianNCM         := ""
::shipp_LoadBrazilianANTTCodeType    := 0
::shipp_br_ibgesource            := ""
::shipp_br_ibgedest              := ""
::shipp_br_cepsource             := ""
::shipp_br_cepdest               := ""
::shipp_TravelledDistance        := 0
::shipp_OperationKey             := ""  
::shipp_receive_Country          := ""
::shipp_receive_NationalId       := ""
::shipp_receive_Name             := ""
::shipp_receive_ReceiverType     := ""


Return

//-----------------------------------------------------------------
/*/{Protheus.doc} NewRoute()
Inicializa variaveis da rota

@author Caio Murakami
@since 24/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD NewRoute() CLASS TMSBCARepomFrete

::route_BranchIdentifier     := ""
::route_OriginIBGECode       := ""
::route_DestinyIBGECode      := ""
::route_RoundTrip            := .F.
::route_Note                 := ""
::route_TraceIdentifier      := ""
::route_ShippingPaymentPlaceType     := ""
::route_PreferredWays       := {}

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} NewPayment()
Novo pagamento

@author Caio Murakami
@since 01/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD NewPayment() CLASS TMSBCARepomFrete

::payment_BranchCode         := ""
::payment_ShippingID         := ""
::payment_TotalUnloadWeight  := 0 
::payment_Documents          := {} 
    
Return 

//-----------------------------------------------------------------
/*/{Protheus.doc} NewAuthorization()
Autorização de pagamento

@author Caio Murakami
@since 01/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD NewAuthorization() CLASS TMSBCARepomFrete

::auth_autorizations     := {} 

Return 

//-----------------------------------------------------------------
/*/{Protheus.doc} Auth()
Método autenticador

@author Caio Murakami
@since 15/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD Auth() CLASS TMSBCARepomFrete
Local cEndPoint     := "/token"
Local aHeader       := {} 
Local lRet          := .T. 
Local oRest         := FwRest():New( ::url_repom ) 
Local cResult       := ""
Local oObj          := Nil 
Local cParams       := ""
Local aTokenAti     := {}

aTokenAti := ::IsTokenActive()

If !aTokenAti[1]
    Aadd(aHeader, "Accept: application/json" )
    Aadd(aHeader, "Content-Type: application/json" )

    cParams := "grant_type="    + ::grant_type
    cParams += "&username="     + ::username
    cParams += "&password="     + ::password
    cParams += "&partner="      + ::partner

    oRest:SetPath(cEndPoint) 
    oRest:SetPostParams( EncodeUTF8(cParams) )

    TmsRepTrac("TMSBCARepomFrete - Auth")
    TmsRepTrac( cParams )

    lRet    := oRest:Post( aHeader ) 
    
    If oRest:GetResult() <> Nil
        cResult := oRest:GetResult() 
    EndIf

    If lRet
        If FWJsonDeserialize(cResult,@oObj)
            ::access_token  := oObj:access_token
            ::expires       := oObj:expires_in
            lRet := TMSGravDEG( ::access_token, ::expires )
        EndIf

        TmsRepTrac( cResult )
    Else
        ::last_error   := AllTrim( oRest:GetLastError() ) + CHR(13) + AllTrim( Decodeutf8( cResult ) )
        
        Aadd( ::message_error , { AllTrim( oRest:GetLastError() ) , "04", ""})
        Aadd( ::message_error , { AllTrim( Decodeutf8( cResult )) , "04" , "" } )  
        Aadd( ::message_error , { AllTrim(cParams) , "04" , "" } ) 

        If ::exibe_erro
            TmsMsgErr( ::message_error , "TMS X REPOM" )
            FwFreeArray(::message_error )
            ::message_error     := {}             
        EndIf
        
        TmsRepTrac( ::last_error )
    EndIf
EndIf

FwFreeObj(oRest)

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} IsTokenActive()

@author Rodrigo.Pirolo
@since 09/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD IsTokenActive() CLASS TMSBCARepomFrete

    Local lRet          := .F.
    Local cToken        := ""
    Local aAreaDEG      := DEG->(GetArea())
    Local dDtToken      := CToD("")
    Local cHrToken      := ""
    Local nExpire       := 0     
    Local cHour         := ""
    Local cMin          := ""
    Local cSecs         := ""
    Local cTime         := ""
    Local nSecs         := 0
    
    DbSelectArea("DEG")
    DEG->( DbSetOrder( 1 ) )

    If DEG->( DbSeek( xFilial("DEG") + "01" ) ) // Garanto que estou posicionado no registro da repom
        
        dDtToken    := DEG->DEG_DTTOKE
        cHrToken    := DEG->DEG_HRTOKE
        nExpire     := DEG->DEG_EXPIRE

        If dDataBase == dDtToken
            cTime   := ElapTime( cHrToken, Time() )

            cHour   := SubStr( cTime, 1, 2 )
            cMin    := SubStr( cTime, 4, 2 )
            cSecs   := SubStr( cTime, 7, 2 )
            
            nSecs   := Val(cSecs) + ( Val( cMin ) * 60 ) + ( Hrs2Min(cHour) * 60 )

            If nExpire > nSecs
                lRet    := .T.
                cToken  := DEG->DEG_TOKEN
            EndIf
        EndIf
    EndIf

    RestArea(aAreaDEG)

Return { lRet, cToken }

//-----------------------------------------------------------------
/*/{Protheus.doc} DriverCreate()
POST - Driver - Creates a new driver
@author Caio Murakami
@since 16/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD DriverCreate( cCodMot ) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/driver"
Local oRest     := FwRest():New( ::url_repom ) 
Local oBody     := JsonObject():New()
Local aPhones   := {} 
Local oPhones   := JsonObject():New()
Local oAddress  := JsonObject():New()
Local oPersonal := JsonObject():New()
Local cBody     := ""

Default cCodMot := ""

lRet   := ::GetDriverInfo( cCodMot )

If lRet 
    Aadd(aHeader, "Accept: application/json" )
    Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
    Aadd(aHeader, "Content-Type: application/json" )

    oAddress["Street"]      := ::driver_address_street
    oAddress["Number"]      := ::driver_address_number
    oAddress["Complement"]  := ::driver_address_complement
    oAddress["ZipCode"]     := ::driver_address_zipcode 

    oPhones["AreaCode"]     := ::driver_phone_areacode
    oPhones["Number"]       := ::driver_phone_number
    oPhones["Preferential"] := ::driver_phone_preferential
    oPhones["TypeId"]       := ::driver_phone_typeid

    Aadd( aPhones , oPhones )

    oPersonal["BirthDate"]  := ::driver_birthdate
    oPersonal["Name"]       := ::driver_name
    oPersonal["Gender"]     := ::driver_gender

    oBody["Country"]                := ::driver_country
    oBody["NationalID"]             := ::driver_national_id
    oBody["DriverLicenseNumber"]    := ::driver_license_number
    oBody["Address"]                := oAddress
    oBody["Phones"]                 := aClone( aPhones ) 
    oBody["DriverPersonalInformation"]    := oPersonal

    cBody   := oBody:ToJson()

    oRest:SetPath(cEndPoint + "?x-api-version=" + ::api_version )
    oRest:SetPostParams( cBody )
    
    TmsRepTrac("TMSBCARepomFrete - DriverCreate")
    TmsRepTrac( cBody )

    lRet    := oRest:Post( aHeader ) 

    If !lRet
        ::last_error   := AllTrim( oRest:GetLastError() ) + CHR(13) + AllTrim( Decodeutf8(oRest:GetResult()) )
       
        Aadd( ::message_error , { AllTrim( oRest:GetLastError() ) , "04", ""})
        Aadd( ::message_error , { AllTrim( Decodeutf8( oRest:GetResult() )) , "04" , "" } )  
        Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 

        If ::exibe_erro
            TmsMsgErr( ::message_error , "TMS X REPOM" )
            FwFreeArray(::message_error )
            ::message_error     := {}             
        EndIf

        TmsRepTrac( ::last_error )
    EndIf

EndIf 
FwFreeObj(oRest)
FwFreeObj(oBody)

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} DriverUpdate()
Update a driver
@author Caio Murakami
@since 06/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD DriverUpdate( cCodMot ) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/driver"
Local oRest     := FwRest():New( ::url_repom ) 
Local oBody     := JsonObject():New()
Local aPhones   := {} 
Local oPhones   := JsonObject():New()
Local oAddress  := JsonObject():New()
Local oPersonal := JsonObject():New()
Local cBody     := ""
Local cCountry  := "Brazil"
Local cNatID    := ""

Default cCodMot := ""

lRet   := ::GetDriverInfo( cCodMot )

If lRet 
    Aadd(aHeader, "Accept: application/json" )
    Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
    Aadd(aHeader, "Content-Type: application/json" )

    oAddress["Street"]      := ::driver_address_street
    oAddress["Number"]      := ::driver_address_number
    oAddress["Complement"]  := ::driver_address_complement
    oAddress["ZipCode"]     := ::driver_address_zipcode 

    oPhones["AreaCode"]     := ::driver_phone_areacode
    oPhones["Number"]       := ::driver_phone_number
    oPhones["Preferential"] := ::driver_phone_preferential
    oPhones["TypeId"]       := ::driver_phone_typeid

    Aadd( aPhones , oPhones )

    oPersonal["BirthDate"]  := ::driver_birthdate
    oPersonal["Name"]       := ::driver_name
    oPersonal["Gender"]     := ::driver_gender

    oBody["DriverLicenseNumber"]    := ::driver_license_number
    oBody["Address"]                := oAddress
    oBody["Phones"]                 := aClone( aPhones ) 
    oBody["DriverPersonalInformation"]    := oPersonal

    cBody       := oBody:ToJson()
    cCountry    := ::driver_country
    cNatID      := ::driver_national_id

    oRest:SetPath(cEndPoint + "/" + cCountry + "/"  + cNatID  + "?x-api-version=" + ::api_version )
    
    TmsRepTrac("TMSBCARepomFrete - DriverUpdate")
    TmsRepTrac( cBody )

    lRet    := oRest:Put( aHeader , cBody ) 
    
    If !lRet
        ::last_error   := AllTrim( oRest:GetLastError() ) + CHR(13) + AllTrim( Decodeutf8( oRest:GetResult() ) )
        If !("204" $ oRest:GetLastError() )   
           
            Aadd( ::message_error , { AllTrim( oRest:GetLastError() ) , "04", ""})
            Aadd( ::message_error , { AllTrim( Decodeutf8( oRest:GetResult() )) , "04" , "" } )  
            Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 

            If ::exibe_erro
                TmsMsgErr( ::message_error , "TMS X REPOM" )
                FwFreeArray(::message_error )
                ::message_error     := {}             
            EndIf

            TmsRepTrac( ::last_error )
        Else
            lRet    := .T. 
        EndIf
    EndIf

EndIf 
FwFreeObj(oRest)
FwFreeObj(oBody)

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} DriverLock()
PATCH - Lock ou Unlock do driver
@author Caio Murakami
@since 06/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD DriverLock( cCodMot , lLock , cObserv ) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/driver/lockUnlock"
Local cNatId    := ""
Local cCountry  := "Brazil"
Local cBody     := ""
Local xResult   := Nil 
Local cHeader   := ""
Local oResult   := ""
Local oBody     := JsonObject():New()
Local nCount    := 0 
Local aErrors   := {} 
Local cLicense  := ""

Default cCodMot     := ""
Default lLock       := .T. 
Default cObserv     := ""

lRet   := ::GetDriverInfo( cCodMot )

cLicense    := RTrim( ::vehicle_licenseplate ) 

If lRet
    Aadd(aHeader, "Accept: application/json" )
    Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
    Aadd(aHeader, "Content-Type: application/json" )

    oBody["Locked"]         := lLock
    oBody["LockedReason"]   := cObserv

    cCountry    := RTrim( ::driver_country )
    cNatID      := RTrim( ::driver_national_id )

    cBody   := EncodeUTF8( oBody:ToJson() )
    TmsRepTrac("TMSBCARepomFrete - DriverLock")
    TmsRepTrac( cBody )

    xResult := HTTPQuote( ::url_repom+cEndPoint+"/"+cCountry+"/"+cNatId+"?x-api-version="+::api_version ,;
                "PATCH",,cBody,120,aClone(aHeader),@cHeader)

    lRet    := .F. 
    If xResult <> Nil 
        If FwJsonDeserialize(xResult,@oResult)
            If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) .And. ;
                 oResult:Response:StatusCode == 200 
                lRet    := .T.
            ElseIf  ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "ERRORS" ) 
                lRet    := .F. 
                aErrors := oResult:Errors
                For nCount := 1 To Len(aErrors)
                    ::last_error    := cValToChar(oResult:Response:StatusCode) + chr(10) + chr(13)
                    ::last_error    += cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message + chr(10) + chr(13)

                    Aadd( ::message_error , { AllTrim( cValToChar(oResult:Response:StatusCode)  ) , "04", ""})
                    Aadd( ::message_error , { AllTrim( cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message  ) , "04", ""})
                Next nCount 
                Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 
            EndIf 
        Else 
            ::last_error    := "Error FwJsonDeserialize " + chr(10) + chr(13)
            ::last_error    += ::url_repom+cEndPoint+"/"+cCountry+"/"+cLicense+"?x-api-version="+::api_version
            ::last_error    += xResult

             Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
             Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 
        Endif 
    Else 
        ::last_error    := "Error HTTPQuote - PATCH " + chr(10) + chr(13)
        ::last_error    += ::url_repom+cEndPoint+"/"+cCountry+"/"+cLicense+"?x-api-version="+::api_version
        ::last_error    += cBody
        
        Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})

    EndIf 

    If !lRet
        ::last_error    := DecodeUtf8( AllTrim(::last_error) )
        If ::exibe_erro
            TmsMsgErr( ::message_error , "TMS X REPOM" )
            FwFreeArray(::message_error )
            ::message_error     := {}             
        EndIf
        TmsRepTrac( ::last_error )
    EndIf

EndIf 

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} HiredCreate()
Creates a new hired
@author Caio Murakami
@since 16/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD HiredCreate( cCodFor, cLojFor ) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/hired"
Local oRest     := FwRest():New( ::url_repom ) 
Local oBody     := JsonObject():New()
Local oPhones   := JsonObject():New()
Local oSettings := JsonObject():New()
Local oCompany  := JsonObject():New()
Local oPersonal := JsonObject():New()
Local oPFisica  := JsonObject():New()
Local oPJurid   := JsonObject():New()
Local OAddress  := JsonObject():New()
Local cBody     := ""

Default cCodFor     := ""
Default cLojFor     := ""

::GetHiredInfo(cCodFor,cLojFor)

Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeader, "Content-Type: application/json" )

oPhones["AreaCode"]         := ::hired_phone_areacode
oPhones["Number"]           := ::hired_phone_number
oPhones["Preferential"]     := ::hired_phone_preferential
oPhones["TypeId"]           := ::hired_phone_typeid

oPFisica["INSS"]  := ::hired_inss
oPFisica["RG"]    := ::hired_rg

oPJurid["IncricaoEstadual"]        := ::hired_ie 
oPJurid["IncricaoMunicipal"]       := ::hired_im
oPJurid["NomeFantasia"]            := ::hired_nomefantasia
oPJurid["OptanteSimplesNacional"]  := ::hired_simplesnacional

oSettings["RNTRC"]                  := ::hired_rntrc             
oSettings["HiredPessoaFisica"]      := oPFisica
oSettings["HiredPessoaJuridica"]    := oPJurid

oAddress["Street"]      := ::hired_address_street
oAddress["Number"]      := ::hired_address_number
oAddress["Complement"]  := ::hired_address_complement
oAddress["Neighborhood"]:= ::hired_address_neighboorhod
oAddress["ZipCode"]     := ::hired_address_zipcode

oCompany["CompanyName"]     := ::hired_companyname

oPersonal["Name"]           := ::hired_name
oPersonal["BirthDate"]      := ::hired_birthdate
oPersonal["LegalDependents"]:= ::hired_dependents
oPersonal["Gender"]         := ::hired_gender 

oBody["Country"]            := ::hired_country
oBody["HiredType"]          := ::hired_type 
oBody["NationalID"]         := ::hired_national_id
oBody["Email"]              := ::hired_email
oBody["Phones"]             := { oPhones }
oBody["BrazilianSettings"]  := oSettings
oBody["Address"]            := oAddress
oBody["CompanyInformation"] := oCompany
oBody["HiredPersonalInformation"]   := oPersonal

cBody   := oBody:ToJson()
oRest:SetPath(cEndPoint + "?x-api-version=" + ::api_version )
oRest:SetPostParams( cBody )

TmsRepTrac("TMSBCARepomFrete - HiredCreate")
TmsRepTrac( cBody )

lRet    := oRest:Post( aHeader ) 

If !lRet
    ::last_error   := AllTrim(  oRest:GetLastError() ) + CHR(13) + AllTrim( Decodeutf8(oRest:GetResult() ) )
    
    Aadd( ::message_error , { AllTrim( oRest:GetLastError() ) , "04", ""})
    Aadd( ::message_error , { AllTrim( Decodeutf8( oRest:GetResult() )) , "04" , "" } )  
    Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 

    If ::exibe_erro
        TmsMsgErr( ::message_error , "TMS X REPOM" )
        FwFreeArray(::message_error )
        ::message_error     := {}             
    EndIf
    TmsRepTrac(::last_error )
EndIf

Return lRet  

//-----------------------------------------------------------------
/*/{Protheus.doc} HiredUpdate()
Updates a Hired
@author Caio Murakami
@since 06/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD HiredUpdate( cCodFor, cLojFor ) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/hired"
Local oRest     := FwRest():New( ::url_repom ) 
Local oBody     := JsonObject():New()
Local oPhones   := JsonObject():New()
Local oSettings := JsonObject():New()
Local oCompany  := JsonObject():New()
Local oPersonal := JsonObject():New()
Local oPFisica  := JsonObject():New()
Local oPJurid   := JsonObject():New()
Local OAddress  := JsonObject():New()
Local cCountry  := ""
Local cNatId    := ""
Local cBody     := ""
Local cResult   := ""

Default cCodFor     := ""
Default cLojFor     := ""

::GetHiredInfo(cCodFor,cLojFor)

Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeader, "Content-Type: application/json" )

oPhones["AreaCode"]         := ::hired_phone_areacode
oPhones["Number"]           := ::hired_phone_number
oPhones["Preferential"]     := ::hired_phone_preferential
oPhones["TypeId"]           := ::hired_phone_typeid

oPFisica["INSS"]  := ::hired_inss
oPFisica["RG"]    := ::hired_rg

oPJurid["IncricaoEstadual"]        := ::hired_ie 
oPJurid["IncricaoMunicipal"]       := ::hired_im
oPJurid["NomeFantasia"]            := ::hired_nomefantasia
oPJurid["OptanteSimplesNacional"]  := ::hired_simplesnacional

oSettings["RNTRC"]                  := ::hired_rntrc             
oSettings["HiredPessoaFisica"]      := oPFisica
oSettings["HiredPessoaJuridica"]    := oPJurid

oAddress["Street"]      := ::hired_address_street
oAddress["Number"]      := ::hired_address_number
oAddress["Complement"]  := ::hired_address_complement
oAddress["Neighborhood"]:= ::hired_address_neighboorhod
oAddress["ZipCode"]     := ::hired_address_zipcode

oCompany["CompanyName"]     := ::hired_companyname

oPersonal["Name"]           := ::hired_name
oPersonal["BirthDate"]      := ::hired_birthdate
oPersonal["LegalDependents"]:= ::hired_dependents
oPersonal["Gender"]         := ::hired_gender 

oBody["HiredType"]          := ::hired_type 
oBody["Email"]              := ::hired_email
oBody["Phones"]             := { oPhones }
oBody["BrazilianSettings"]  := oSettings
oBody["Address"]            := oAddress
oBody["CompanyInformation"] := oCompany
oBody["HiredPersonalInformation"]   := oPersonal

cCountry    := RTrim(::hired_country)
cNatId      := RTrim(::hired_national_id)

cBody   := EncodeUTF8( oBody:ToJson() )
oRest:SetPath(cEndPoint + "/" + cCountry + "/"  + cNatId  + "?x-api-version=" + ::api_version )

TmsRepTrac("TMSBCARepomFrete - HiredUpdate")
TmsRepTrac( cBody )

lRet    := oRest:Put( aHeader , cBody ) 

If !lRet  
    If oRest:GetResult() <> Nil
        cResult:= AllTrim( Decodeutf8( oRest:GetResult() ) )
    EndIf

    ::last_error   := AllTrim( oRest:GetLastError() ) + CHR(13) + cResult
    If !("204" $ oRest:GetLastError() )   
    
        Aadd( ::message_error , { AllTrim( oRest:GetLastError() ) , "04", ""})
        Aadd( ::message_error , { cResult , "04" , "" } )  
        Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 

        If ::exibe_erro
            TmsMsgErr( ::message_error , "TMS X REPOM" )
            FwFreeArray(::message_error )
            ::message_error     := {}             
        EndIf

        TmsRepTrac(::last_error)
    Else
        lRet    := .T. 
    EndIf
EndIf


Return lRet  

//-----------------------------------------------------------------
/*/{Protheus.doc} HiredLock()
Lock or Unlock a Hired
@author Caio Murakami
@since 06/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD HiredLock( cCodFor, cLojFor , lLock , cObserv ) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/hired/lockUnlock"
Local cNatId    := ""
Local cCountry  := "Brazil"
Local cBody     := ""
Local xResult   := Nil 
Local cHeader   := ""
Local oResult   := ""
Local oBody     := JsonObject():New()
Local nCount    := 0 
Local aErrors   := {} 

Default cCodFor     := ""
Default cLojFor     := ""
Default lLock       := .T. 
Default cObserv     := ""

lRet    := ::GetHiredInfo(cCodFor,cLojFor)

If lRet
    Aadd(aHeader, "Accept: application/json" )
    Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
    Aadd(aHeader, "Content-Type: application/json" )

    oBody["Locked"]         := lLock
    oBody["LockedReason"]   := cObserv
    
    cCountry    := RTrim(::hired_country)
    cNatId      := RTrim(::hired_national_id)

    cBody   := EncodeUTF8( oBody:ToJson() )

    TmsRepTrac("TMSBCARepomFrete - HiredLock")
    TmsRepTrac( cBody )

    xResult := HTTPQuote( ::url_repom+cEndPoint+"/"+cCountry+"/"+cNatId+"?x-api-version="+::api_version ,;
                "PATCH",,cBody,120,aClone(aHeader),@cHeader)

    lRet    := .F. 
    If xResult <> Nil 
        If FwJsonDeserialize(xResult,@oResult)
            If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) .And. ;
                 oResult:Response:StatusCode == 200 
                lRet    := .T.
            ElseIf ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "ERRORS" )  
                lRet    := .F. 
                aErrors := oResult:Errors
                For nCount := 1 To Len(aErrors)
                    ::last_error    := cValToChar(oResult:Response:StatusCode) + chr(10) + chr(13)
                    ::last_error    += cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message + chr(10) + chr(13)
                    Aadd( ::message_error , { AllTrim( cValToChar(oResult:Response:StatusCode)  ) , "04", ""})
                    Aadd( ::message_error , { AllTrim( cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message  ) , "04", ""})
                Next nCount 
                Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 
            EndIf 
        Else 
            ::last_error    := "Error FwJsonDeserialize " + chr(10) + chr(13)
            ::last_error    += ::url_repom+cEndPoint+"?x-api-version="+::api_version
            ::last_error    += xResult
            Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
            Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 
        Endif 
    Else 
        ::last_error    := "Error HTTPQuote - PATCH " + chr(10) + chr(13)
        ::last_error    += ::url_repom+cEndPoint+"?x-api-version="+::api_version
        ::last_error    += cBody
        Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
    EndIf 

    If !lRet
        ::last_error    := DecodeUtf8( AllTrim(::last_error) )
        If ::exibe_erro
            TmsMsgErr( ::message_error , "TMS X REPOM" )
            FwFreeArray(::message_error )
            ::message_error     := {}             
        EndIf
        TmsRepTrac( ::last_error )
    EndIf

EndIf 

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} VehicleCreate()
Create Vehicle
@author Caio Murakami
@since 22/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD VehicleCreate( cCodVei ) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/vehicle"
Local oRest     := FwRest():New( ::url_repom ) 
Local oBody     := JsonObject():New()
Local oOwner    := JsonObject():New()
Local oPJurid   := JsonObject():New()
Local oPFisica  := JsonObject():New()
Local oSettings := JsonObject():New()
Local cBody     := ""

Default cCodVei     := ""

::GetVehicleInfo(cCodVei)

Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeader, "Content-Type: application/json" )

oPFisica["Name"]                    := ::vehicle_owner_name
oPJurid["NomeFantasia"]             := ::vehicle_owner_nomefantasia

oSettings["RNTRC"]                  := ::vehicle_owner_rntrc
oSettings["VehiclePessoaJuridica"]  := oPJurid

oOwner["Country"]                   := ::vehicle_owner_country
oOwner["NationalID"]                := ::vehicle_owner_id
oOwner["BrazilianSettings"]         := oSettings
oOwner["Type"]                      := ::vehicle_owner_type
oOwner["VehiclePersonalInformation"]:= oPFisica

oBody["Country"]                := ::vehicle_country
oBody["LicensePlate"]           := ::vehicle_licenseplate
oBody["VehicleClassification"]  := ::vehicle_classification
oBody["VehicleCategory"]        := ::vehicle_category
oBody["VehicleAxles"]           := ::vehicle_axles
oBody["Type"]                   := ::vehicle_type
oBody["VehicleOwner"]           := oOwner

cBody   := oBody:ToJson()
oRest:SetPath(cEndPoint + "?x-api-version=" + ::api_version )
oRest:SetPostParams( cBody )

TmsRepTrac("TMSBCARepomFrete - VehicleCreate")
TmsRepTrac( cBody )

lRet    := oRest:Post( aHeader ) 

If !lRet
    ::last_error   := AllTrim( oRest:GetLastError() ) + CHR(13) + AllTrim( Decodeutf8( oRest:GetResult() ) )
    
    Aadd( ::message_error , { AllTrim( oRest:GetLastError() ) , "04", ""})
    Aadd( ::message_error , { AllTrim( Decodeutf8( oRest:GetResult() )) , "04" , "" } )  
    Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 

    If ::exibe_erro
        TmsMsgErr( ::message_error , "TMS X REPOM" )
        FwFreeArray(::message_error )
        ::message_error     := {}             
    EndIf

    TmsRepTrac(::last_error)
EndIf

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} VehicleUpdate()
Update Veículo
@author Caio Murakami
@since 05/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD VehicleUpdate( cCodVei ) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/vehicle"
Local oRest     := FwRest():New( ::url_repom ) 
Local oBody     := JsonObject():New()
Local oOwner    := JsonObject():New()
Local oPJurid   := JsonObject():New()
Local oPFisica  := JsonObject():New()
Local oSettings := JsonObject():New()
Local cLicense  := ""
Local cCountry  := "Brazil"
Local cBody     := ""

Default cCodVei     := ""

::GetVehicleInfo(cCodVei)

Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeader, "Content-Type: application/json" )

oPFisica["Name"]                    := ::vehicle_owner_name
oPJurid["NomeFantasia"]             := ::vehicle_owner_nomefantasia

oSettings["RNTRC"]                  := ::vehicle_owner_rntrc
oSettings["VehiclePessoaJuridica"]  := oPJurid

oOwner["Country"]                   := ::vehicle_owner_country
oOwner["NationalID"]                := ::vehicle_owner_id
oOwner["BrazilianSettings"]         := oSettings
oOwner["Type"]                      := ::vehicle_owner_type
oOwner["VehiclePersonalInformation"]:= oPFisica

oBody["VehicleClassification"]  := ::vehicle_classification
oBody["VehicleCategory"]        := ::vehicle_category
oBody["VehicleAxles"]           := ::vehicle_axles
oBody["Type"]                   := ::vehicle_type
oBody["VehicleOwner"]           := oOwner

cLicense    := RTrim( ::vehicle_licenseplate ) 
cCountry    := RTrim( ::vehicle_owner_country ) 

cBody   := EncodeUTF8( oBody:ToJson() )

oRest:SetPath(cEndPoint + "/" + cCountry + "/"  + cLicense  + "?x-api-version=" + ::api_version )

TmsRepTrac("TMSBCARepomFrete - VehicleUpdate")
TmsRepTrac( cBody )

lRet    := oRest:Put( aHeader , cBody ) 

If !lRet
    ::last_error   := AllTrim( oRest:GetLastError() ) + CHR(13) + AllTrim( Decodeutf8( oRest:GetResult() ) )
     If !("204" $ oRest:GetLastError() )   

        Aadd( ::message_error , { AllTrim( oRest:GetLastError() ) , "04", ""})
        Aadd( ::message_error , { AllTrim( Decodeutf8( oRest:GetResult() )) , "04" , "" } )  
        Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 

        If ::exibe_erro
            TmsMsgErr( ::message_error , "TMS X REPOM" )
            FwFreeArray(::message_error )
            ::message_error     := {}             
        EndIf

        TmsRepTrac( ::last_error )
    Else
        lRet    := .T. 
    EndIf
EndIf

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} VehicleLock()
PATCH - Lock ou Unlock do veículo
@author Caio Murakami
@since 05/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD VehicleLock( cCodVei , lLock , cObserv ) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/vehicle"
Local cLicense  := ""
Local cCountry  := "Brazil"
Local cBody     := ""
Local xResult   := Nil 
Local cHeader   := ""
Local oResult   := ""
Local oBody     := JsonObject():New()
Local nCount    := 0 
Local aErrors   := {} 

Default cCodVei     := ""
Default lLock       := .T. 
Default cObserv     := ""

::GetVehicleInfo(cCodVei)

Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeader, "Content-Type: application/json" )

oBody["Locked"]         := lLock
oBody["LockedReason"]   := cObserv

cLicense    := RTrim( ::vehicle_licenseplate )
cCountry    := RTrim( ::vehicle_owner_country )

cBody   := EncodeUTF8( oBody:ToJson() )

TmsRepTrac("TMSBCARepomFrete - VehicleLock")
TmsRepTrac( cBody )

xResult := HTTPQuote( ::url_repom+cEndPoint+"/"+cCountry+"/"+cLicense+"?x-api-version="+::api_version ,;
            "PATCH",,cBody,120,aClone(aHeader),@cHeader)

lRet    := .F. 
If xResult <> Nil 
    If FwJsonDeserialize(xResult,@oResult)
        If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) .And. ;
                 oResult:Response:StatusCode == 200  
            lRet    := .T.
        ElseIf ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "ERRORS" )  
            lRet    := .F. 
            aErrors := oResult:Errors
            For nCount := 1 To Len(aErrors)
                ::last_error    := cValToChar(oResult:Response:StatusCode) + chr(10) + chr(13)
                ::last_error    += cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message + chr(10) + chr(13)

                Aadd( ::message_error , { AllTrim( cValToChar(oResult:Response:StatusCode)  ) , "04", ""})
                Aadd( ::message_error , { AllTrim( cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message  ) , "04", ""})
            Next nCount 
            Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 
        EndIf 
    Else 
        ::last_error    := "Error FwJsonDeserialize " + chr(10) + chr(13)
        ::last_error    += ::url_repom+cEndPoint+"/"+cCountry+"/"+cLicense+"?x-api-version="+::api_version
        ::last_error    += xResult
            Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
            Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 
    Endif 
Else 
    ::last_error    := "Error HTTPQuote - PATCH " + chr(10) + chr(13)
    ::last_error    += ::url_repom+cEndPoint+"/"+cCountry+"/"+cLicense+"?x-api-version="+::api_version
    ::last_error    += cBody
    
    Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})

EndIf 

 If !lRet
    ::last_error    := DecodeUtf8( AllTrim(::last_error) )
    
    If ::exibe_erro
        TmsMsgErr( ::message_error , "TMS X REPOM" )
        FwFreeArray(::message_error )
        ::message_error     := {}             
    EndIf
    TmsRepTrac( ::last_error )
EndIf

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} GetVeicByDoc()
GET /Vehicle/ByDocument/{country}/{license}
@author Caio Murakami
@since 05/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetVeicByDoc( cCodVei ) CLASS TMSBCARepomFrete
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/Vehicle/ByDocument/"
Local cGet      := ""
Local aArea     := GetArea()
Local cLicense  := ""
Local cCountry  := ""
Local cJson     := ""
Local oResult   := ""
Local oJson     := Nil 
Local aNames    := {}
Local nCount    := 1 

Default cCodVei := ""

::GetVehicleInfo(cCodVei)

cLicense    := RTrim( ::vehicle_licenseplate )
cCountry    := RTrim( ::vehicle_owner_country )

cPathPar    += cCountry + "/" + cLicense

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )

If FwJsonDeserialize(cGet,@oResult)
    If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) .And. ;
        oResult:Response:StatusCode == 200 .And. AttIsMemberOf( oResult, "RESULT" )

        cJson   := FwJsonSerialize(oResult:Result,.F.,.T.)
        oJson   := JsonObject():New()
        oJson:FromJson(cJson)

        aNames  := oJson:GetNames()

        For nCount := 1 To Len(aNames)
            Aadd( aRet , { aNames[nCount] , oJson[aNames[nCount]]  })
        Next nCount

    EndIf 
EndIf 

RestArea( aArea )
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} RouteCreate()
Create Route
@author Caio Murakami
@since 22/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD RouteCreate( cRota , cUfOri, cMunOri, cUFDes, cMunDes , lIdaeVolta , aNomesRodo , cObserv ) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/routerequest"
Local oRest     := FwRest():New( ::url_repom ) 
Local oBody     := JsonObject():New()
Local oWays     := JsonObject():New()
Local aWays     := {} 
Local nCount    := 0 
Local cBody     := ""

Default cRota       := ""
Default cUfOri      := ""
Default cMunOri     := ""
Default cUFDes      := ""
Default cMunDes     := ""
Default lIdaeVolta  := .F. 
Default aNomesRodo  := {} 
Default cObserv     := ""

::GetRouteInfo( cRota, cUfOri , cMunOri, cUFDes, cMunDes, lIdaeVolta , aNomesRodo , cObserv )

Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeader, "Content-Type: application/json" )

For nCount := 1 To Len(::route_PreferredWays)
    oWays["HighwayNames"]   := ::route_PreferredWays[nCount]
    Aadd( aWays , oWays )
Next nCoun 

oBody["BranchIdentifier"]       := ::route_BranchIdentifier
oBody["OriginIBGECode"]         := ::route_OriginIBGECode
oBody["DestinyIBGECode"]        := ::route_DestinyIBGECode
oBody["RoundTrip"]              := ::route_RoundTrip
oBody["Note"]                   := ::route_Note
oBody["TraceIdentifier"]        := ::route_TraceIdentifier
oBody["ShippingPaymentPlaceType"]   := ::route_ShippingPaymentPlaceType
oBody["PreferredWays"]          := aWays

cBody   := oBody:ToJson()
oRest:SetPath(cEndPoint + "?x-api-version=" + ::api_version )
oRest:SetPostParams( cBody )

TmsRepTrac("TMSBCARepomFrete - RouteCreate")
TmsRepTrac( cBody )

lRet    := oRest:Post( aHeader ) 


If !lRet
    ::last_error   := AllTrim( oRest:GetLastError() ) + CHR(13) + AllTrim( Decodeutf8( oRest:GetResult() ) )
    
    Aadd( ::message_error , { AllTrim( oRest:GetLastError() ) , "04", ""})
    Aadd( ::message_error , { AllTrim( Decodeutf8( oRest:GetResult() )) , "04" , "" } )  
    Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 

    If ::exibe_erro
        TmsMsgErr( ::message_error , "TMS X REPOM" )
        FwFreeArray(::message_error )
        ::message_error     := {}             
    EndIf

    TmsRepTrac( ::last_error )
EndIf

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} ShippingCreate()
Create Shipping
@author Caio Murakami
@since 22/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD ShippingCreate( cFilOri , cViagem ) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/Shipping"
Local oRest     := FwRest():New( ::url_repom ) 
Local oBody     := {}
Local oVPR      := JsonObject():New()
Local oShippPay := JsonObject():New()
Local aDrivers  := {} 
Local oDrivers  := Nil
Local aVehicles := {} 
Local oVehicles := Nil
Local oShippRec := JsonObject():New()
Local aDocs     := {} 
Local oDocs     := Nil
Local nCount    := 1
Local oResult   := Nil 
Local cJsonKey  := ""
Local aResult   := {} 
Local nAuxDoc   := 1 
Local lAddBody  := .F. 
Local cJson     := ""
Local nPeso     := 0 
Local nValTot   := 0 
Local aTaxes    := {} 
Local oTaxes    := Nil
Local cResult   := ""

Default cFilOri     := ""
Default cViagem     := ""

::GetShippingInfo(cFilOri,cViagem)

Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeader, "Content-Type: application/json" )

For nCount := 1 To Len(::shipp_drivers)
    oDrivers    := JsonObject():New()

    oDrivers["Country"]     := ::GetInfoArr( ::shipp_drivers[nCount] , "Country" , 1 )
    oDrivers["NationalId"]  := ::GetInfoArr( ::shipp_drivers[nCount] , "NationalId" , 1 )
    oDrivers["Main"]        := ::GetInfoArr( ::shipp_drivers[nCount] , "Main" , 1 )

    Aadd( aDrivers , oDrivers )
    
    oDrivers    := Nil 
    FreeObj(oDrivers)
Next nCount 

For nCount := 1 To Len(::shipp_vehicles)

    oVehicles   := JsonObject():New()

    oVehicles["Country"]       := ::GetInfoArr( ::shipp_vehicles[nCount] , "Country" , 1 )
    oVehicles["LicensePlate"]  := ::GetInfoArr( ::shipp_vehicles[nCount] , "LicensePlate" , 1 )

    Aadd( aVehicles , oVehicles)

    oVehicles   := Nil 
    FreeObj( oVehicles )
Next nCount 

For nCount := 1 To Len(::shipp_taxes)

    oTaxes   := JsonObject():New()

    oTaxes["Type"]      := ::GetInfoArr( ::shipp_taxes[nCount] , "Type" , 1 )
    oTaxes["Value"]     := ::GetInfoArr( ::shipp_taxes[nCount] , "Value" , 1 )

    Aadd( aTaxes , oTaxes)

    oTaxes  := Nil 
    FreeObj(oTaxes )

Next nCount 


oVPR["Issue"]                       := ::shipp_vpr_issue
oVPR["VPROneWay"]                   := ::shipp_vpr_OneWay
oVPR["VPRSuspendedAxleNumber"]      := ::shipp_vpr_SuspAxle
oVPR["VPRReturnSuspendedAxleNumber"]:= ::shipp_vpr_ReturnSuspAxle

oShippPay["ExpectedDeliveryDate"]           := ::shipp_shipppay_date
oShippPay["ExpectedDeliveryLocationType"]   := ::shipp_shipppay_type

For nAuxDoc := 1 To Len(::shipp_documents)
    oDocs       := JsonObject():New()
    lAddBody    := .T. 
    nPeso       := ::GetInfoArr( ::shipp_documents[nAuxDoc] , "DT6_PESO" , 1 )
    nValTot     := ::GetInfoArr( ::shipp_documents[nAuxDoc] , "DT6_VALTOT" , 1 )

    oDocs["BranchCode"]     := ::GetInfoArr( ::shipp_documents[nAuxDoc] , "BranchCode" , 1 )
    oDocs["DocumentType"]   := ::GetInfoArr( ::shipp_documents[nAuxDoc] , "DocumentType" , 1 )
    oDocs["Series"]         := ::GetInfoArr( ::shipp_documents[nAuxDoc] , "Series" , 1 )
    oDocs["Number"]         := ::GetInfoArr( ::shipp_documents[nAuxDoc] , "Number" , 1 )
    oDocs["EletronicKey"]   := ::GetInfoArr( ::shipp_documents[nAuxDoc] , "EletronicKey" , 1 )

    Aadd( aDocs, oDocs )
    ::shipp_TotalLoadWeight += nPeso 
    ::shipp_TotalLoadValue  += nValTot
    
    oDocs   := Nil 
    FreeObj(oDocs)
Next nAuxDoc 

oShippRec                   := JsonObject():New()

oShippRec["Country"]        := ::shipp_receive_Country 
oShippRec["NationalId"]     := ::shipp_receive_NationalId
oShippRec["Name"]           := ::shipp_receive_Name 
oShippRec["ReceiverType"]   := ::shipp_receive_ReceiverType
    
Aadd( oBody , JsonObject():New() )

oBody[Len(oBody)]["Identifier"]                 := ::shipp_id
oBody[Len(oBody)]["Country"]                    := ::shipp_country
oBody[Len(oBody)]["HiredCountry"]               := ::shipp_hiredcountry
oBody[Len(oBody)]["HiredNationalId"]            := ::shipp_HiredNationalId
oBody[Len(oBody)]["OperationIdentifier"]        := ::shipp_OperationIdentifier
oBody[Len(oBody)]["CardNumber"]                 := ::shipp_CardNumber
oBody[Len(oBody)]["VPRCardNumber"]              := ::shipp_VPRCardNumber
oBody[Len(oBody)]["BrazilianRouteTraceCode"]    := ::shipp_BrazilianRouteTraceCode
oBody[Len(oBody)]["BrazilianRouteRouteCode"]    := ::shipp_BrazilianRouteRouteCode
oBody[Len(oBody)]["IssueDate"]                  := ::shipp_IssueDate
oBody[Len(oBody)]["TotalFreightValue"]          := ::shipp_TotalFreightValue
oBody[Len(oBody)]["TotalLoadWeight"]            := ::shipp_TotalLoadWeight
oBody[Len(oBody)]["TotalLoadValue"]             := ::shipp_TotalLoadValue
oBody[Len(oBody)]["AdvanceMoneyValue"]          := ::shipp_AdvanceMoneyValue
oBody[Len(oBody)]["VPR"]                        := oVPR
oBody[Len(oBody)]["ShippingPayment"]            := oShippPay
oBody[Len(oBody)]["Drivers"]                    := aDrivers

If Len(aDocs) > 0 
    oBody[Len(oBody)]["Documents"]                  := aDocs
EndIf 

oBody[Len(oBody)]["Vehicles"]                   := aVehicles
oBody[Len(oBody)]["BranchCode"]                 := ::shipp_BranchCode
oBody[Len(oBody)]["LoadBrazilianNCM"]           := ::shipp_LoadBrazilianNCM
oBody[Len(oBody)]["LoadBrazilianANTTCodeType"]  := ::shipp_LoadBrazilianANTTCodeType
oBody[Len(oBody)]["ShippingReceiver"]           := oShippRec 
oBody[Len(oBody)]["BrazilianIBGECodeSource"]    := ::shipp_br_ibgesource
oBody[Len(oBody)]["BrazilianIBGECodeDestination"]   := ::shipp_br_ibgedest
oBody[Len(oBody)]["BrazilianCEPSource"]             := ::shipp_br_cepsource
oBody[Len(oBody)]["BrazilianCEPDestination"]        := ::shipp_br_cepdest
oBody[Len(oBody)]["TravelledDistance"]          := ::shipp_TravelledDistance
oBody[Len(oBody)]["Taxes"]                      := aTaxes

cJson   := FwJsonSerialize( oBody )

oRest:SetPath(cEndPoint + "?x-api-version=" + ::api_version )
oRest:SetPostParams( cJson )  

TmsRepTrac("TMSBCARepomFrete - ShippingCreate")
TmsRepTrac( cJson )

lRet    := oRest:Post( aHeader ) 

If !lRet
    cResult         := oRest:GetResult()
    
    ::last_error    := AllTrim( oRest:GetLastError() ) + CHR(13) 

    If ValType(cResult) == "C"
        ::last_error    +=  AllTrim( Decodeutf8( cResult ) )
    EndIf    
    
    Aadd( ::message_error , { AllTrim( STR0002 + " " + STR0003 ) , "04", ""}) //-- "Entre em contato com a operadora"  "Repom"
    Aadd( ::message_error , { AllTrim( oRest:GetLastError() ) , "04", ""})
   
    If ValType(cResult) == "C"
        Aadd( ::message_error , { AllTrim( Decodeutf8( cResult )) , "04" , "" } )  
    EndIf 

    Aadd( ::message_error , { AllTrim(cJson) , "04" , "" } ) 

    If ::exibe_erro
        TmsMsgErr( ::message_error , "TMS X REPOM" )
        FwFreeArray(::message_error )
        ::message_error     := {}             
    EndIf
    
    TmsRepTrac( ::last_error )
Else 
    cResult := Decodeutf8( oRest:GetResult() )

    If FWJsonDeserialize(cResult,@oResult)
        cJsonKey                := oResult:Response:Message 
        aResult                 := StrToKArr( cJsonKey , ":" )
        ::shipp_OperationKey    := AllTrim( aResult[2] )
        
        TmsRepTrac( "Operation Key: " + ::shipp_OperationKey )

    EndIf 
EndIf

FwFreeArray(oBody)
For nCount := 1 To Len(aDrivers)
    //aDrivers[nCount]   := Nil
    fWFreeObj(aDrivers[nCount])
Next nCount
For nCount := 1 To Len(aTaxes)
    //aTaxes[nCount]   := Nil
    fWFreeObj(aTaxes[nCount])
Next nCount 
For nCount := 1 To Len(aDocs)
    //aDocs[nCount]   := Nil
    fWFreeObj(aDocs[nCount])
Next nCount
For nCount := 1 To Len(aVehicles)
    //aVehicles[nCount]   := Nil
    fWFreeObj(aVehicles[nCount])
Next nCount

/*oDrivers    := Nil 
oVehicles   := Nil 
oShippRec   := Nil 
oDocs       := Nil 
oVPR        := Nil 
oRest       := Nil 
oResult     := Nil 
oTaxes      := Nil */

fWFreeObj( oDrivers )
fWFreeObj( oVehicles)
fWFreeObj( oShippRec )
fWFreeObj( oDocs )
fWFreeObj( oVPR )
fWFreeObj( oRest )
fWFreeObj( oResult )
fWFreeObj( oTaxes )
fWFreeObj( aHeader )
fWFreeObj( aResult ) 

FwFreeArray(aDrivers)
FwFreeArray(aTaxes)
FwFreeArray(aDocs)
FwFreeArray(aVehicles)
FwFreeArray(oBody)

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} ShippingDocAdd()
This method adds a document to a shipping.

@author Caio Murakami
@since 06/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD ShippingDocAdd( cFilOri, cViagem , cCodVei , cFilDoc, cDoc , cSerie ) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/Shipping/AddDocument"
Local cBody     := ""
Local xResult   := Nil 
Local cHeader   := ""
Local oResult   := ""
Local oBody     := JsonObject():New()
Local nCount    := 0 
Local aErrors   := {} 
Local cShippID  := ""
Local cDocTMS   := ""
Local cSerTms   := ""
Local cKeyDT6   := ""

Default cFilOri     := ""
Default cViagem     := ""
Default cCodVei     := ""
Default cFilDoc     := ""
Default cDoc        := ""
Default cSerie      := ""

cShippID    := ::GetIdShipping( cFilOri , cViagem , cCodVei )
cSerTms     := Posicione("DTQ",2,xFilial("DTQ") + cFilOri + cViagem , "DTQ_SERTMS" )
cDocTMS     := Posicione("DT6",2,xFilial("DT6") + cFilDoc + cDoc + cSerie , "DT6_DOCTMS" )
cKeyDT6     := Posicione("DT6",1,xFilial("DT6") + cFilDoc + cDoc + cSerie , "DT6_CHVCTE" )
                                                                                                                                
Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeader, "Content-Type: application/json" )

oBody["BranchCode"]         := RTrim(cFilDoc)
oBody["DocumentType"]       := RTrim( ::RetDocType(cFilDoc,cDoc,cSerie,cDocTMS,cSerTms) )
oBody["Series"]             := cSerie
oBody["Number"]             := cDoc
oBody["EletronicKey"]       := cKeyDT6

cBody   := EncodeUTF8( oBody:ToJson() )

TmsRepTrac("TMSBCARepomFrete - ShippingDocAdd")
TmsRepTrac( cBody )

xResult := HTTPQuote( ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version ,;
            "PATCH",,cBody,120,aClone(aHeader),@cHeader)

lRet    := .F. 
If xResult <> Nil 
    If FwJsonDeserialize(xResult,@oResult)
        If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" )
            If oResult:Response:StatusCode == 200 
                lRet    := .T.
            ElseIf AttIsMemberOf( oResult, "ERRORS" )
                lRet    := .F. 
                aErrors := oResult:Errors
                Aadd( ::message_error , { ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version , "04" , ""})
            
                For nCount := 1 To Len(aErrors)
                    ::last_error    := cValToChar(oResult:Response:StatusCode) + chr(10) + chr(13)
                    ::last_error    += cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message + chr(10) + chr(13)

                    Aadd( ::message_error , { AllTrim( cValToChar(oResult:Response:StatusCode)  ) , "04", ""})
                    Aadd( ::message_error , { AllTrim( cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message  ) , "04", ""})
                Next nCount 
                Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 

            EndIf 
        ElseIf ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "MESSAGE" ) 
            ::last_error    := RTrim(oResult:Message)

            Aadd( ::message_error , { ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version , "04" , ""})
            Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
            Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 
        EndIf
    Else 
        ::last_error    := "Error FwJsonDeserialize " + chr(10) + chr(13)
        ::last_error    += ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version
        ::last_error    += xResult
        
        Aadd( ::message_error , { ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version , "04" , ""})
        Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
        Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 
    Endif 
Else 
    ::last_error    := "Error HTTPQuote - PATCH " + chr(10) + chr(13)
    ::last_error    += ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version
    ::last_error    += cBody
    Aadd( ::message_error , { ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version , "04" , ""})
    Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
    Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 

EndIf 

If !lRet
    ::last_error    := DecodeUtf8( AllTrim(::last_error) )
    
    If ::exibe_erro
        TmsMsgErr( ::message_error , "TMS X REPOM" )
        FwFreeArray(::message_error )
        ::message_error     := {}             
    EndIf

    TmsRepTrac( ::last_error )
EndIf

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} ShippingMovAdd()
This method adds a credit or debit movement to a shipping.

@author Caio Murakami
@since 07/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD ShippingMovAdd( cFilOri, cViagem , cCodVei , cCodMov , nValMov ) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/Shipping/AddMovement"
Local cBody     := ""
Local xResult   := Nil 
Local cHeader   := ""
Local oResult   := ""
Local oBody     := JsonObject():New()
Local nCount    := 0 
Local aErrors   := {} 
Local cShippID  := ""

Default cFilOri     := ""
Default cViagem     := ""
Default cCodVei     := ""
Default cCodMov     := ""
Default nValMov     := 0 

cShippID    := ::GetIdShipping( cFilOri , cViagem , cCodVei )
                                    
Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeader, "Content-Type: application/json" )

oBody["Identifier"]         := cCodMov
oBody["Value"]              := nValMov

cBody   := EncodeUTF8( oBody:ToJson() )

TmsRepTrac("TMSBCARepomFrete - ShippingMovAdd")
TmsRepTrac( cBody )

xResult := HTTPQuote( ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version ,;
            "PATCH",,cBody,120,aClone(aHeader),@cHeader)

lRet    := .F. 
If xResult <> Nil 
    If FwJsonDeserialize(xResult,@oResult)
        If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) .And. ;
            oResult:Response:StatusCode == 200 
            lRet    := .T.
        ElseIf ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "ERRORS" )  
            lRet    := .F. 
            aErrors := oResult:Errors
            For nCount := 1 To Len(aErrors)
                ::last_error    := cValToChar(oResult:Response:StatusCode) + chr(10) + chr(13)
                ::last_error    += cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message + chr(10) + chr(13)

                Aadd( ::message_error , { AllTrim( cValToChar(oResult:Response:StatusCode)  ) , "04", ""})
                Aadd( ::message_error , { AllTrim( cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message  ) , "04", ""})
            Next nCount 
            Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 
        EndIf 
    Else 
        ::last_error    := "Error FwJsonDeserialize " + chr(10) + chr(13)
        ::last_error    += ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version
        ::last_error    += xResult
            Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
            Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 
    Endif 
Else 
    ::last_error    := "Error HTTPQuote - PATCH " + chr(10) + chr(13)
    ::last_error    += ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version
    ::last_error    += cBody
    Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
EndIf 

If !lRet
    ::last_error    := DecodeUtf8( AllTrim(::last_error) )
    
    If ::exibe_erro
        TmsMsgErr( ::message_error , "TMS X REPOM" )
        FwFreeArray(::message_error )
        ::message_error     := {}             
    EndIf

    TmsRepTrac( ::last_error )
EndIf

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} ShippingCancel()
This method cancels a shipping that did not have consumption or did not use of toll credits(Vale Pedágio Repom).

@author Caio Murakami
@since 07/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD ShippingCancel( cFilOri, cViagem , cCodVei ) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/Shipping/Cancel"
Local xResult   := Nil 
Local cHeader   := ""
Local oResult   := ""
Local nCount    := 0 
Local aErrors   := {} 
Local cShippID  := ""

Default cFilOri     := ""
Default cViagem     := ""
Default cCodVei     := ""
Default cCodMov     := ""
Default nValMov     := 0 

cShippID    := ::GetIdShipping( cFilOri , cViagem , cCodVei )
                                    
Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeader, "Content-Type: application/json" )

TmsRepTrac("TMSBCARepomFrete - ShippingCancel")
TmsRepTrac( ::url_repom+cEndPoint+"/"+cShippID )

xResult := HTTPQuote( ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version ,;
            "PATCH",,,120,aClone(aHeader),@cHeader)

lRet    := .F. 
If xResult <> Nil 
    If FwJsonDeserialize(xResult,@oResult)
        If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) .And. ;
            oResult:Response:StatusCode == 200 
            lRet    := .T.
        ElseIf oResult:Response:StatusCode == 404
            ::last_error    := AllTrim(oResult:Response:Message)
            Aadd( ::message_error , { ::last_error , "04" , "" } )
        ElseIf ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "ERRORS" )  
            lRet    := .F. 
            aErrors := oResult:Errors
            For nCount := 1 To Len(aErrors)
                ::last_error    := cValToChar(oResult:Response:StatusCode) + chr(10) + chr(13)
                ::last_error    += cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message + chr(10) + chr(13)
                Aadd( ::message_error , { AllTrim( cValToChar(oResult:Response:StatusCode)  ) , "04", ""})
                Aadd( ::message_error , { AllTrim( cValToChar(aErrors[nCount]:ErrorCode) + " - " + DecodeUtf8( aErrors[nCount]:Message ) ) , "04", ""})
            Next nCount 
        EndIf 
    Else 
        ::last_error    := "Error FwJsonDeserialize " + chr(10) + chr(13)
        ::last_error    += ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version
        ::last_error    += xResult
        Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
    Endif 
Else 
    ::last_error    := "Error HTTPQuote - PATCH " + chr(10) + chr(13)
    ::last_error    += ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version

    Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
EndIf 

If !lRet
    ::last_error    := DecodeUtf8( AllTrim(::last_error) )
    If ::exibe_erro
        TmsMsgErr( ::message_error , "TMS X REPOM" )
        FwFreeArray(::message_error )
        ::message_error     := {}             
    EndIf
    TmsRepTrac( ::last_error )
EndIf

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} ShippingLock()
This method blocks or unblocks a shipping

@author Caio Murakami
@since 16/11/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD ShippingLock( cFilOri, cViagem , cCodVei, lLock , cObserv) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/Shipping/lockUnlock"
Local cBody     := ""
Local xResult   := Nil 
Local cHeader   := ""
Local oResult   := ""
Local nCount    := 0 
Local aErrors   := {} 
Local cShippID  := ""
Local oBody     := JsonObject():New()

Default cFilOri     := ""
Default cViagem     := ""
Default cCodVei     := ""
Default lLock       := .T.
Default cObserv     := ""

cShippID    := ::GetIdShipping( cFilOri , cViagem , cCodVei )
             
oBody["Locked"]         := lLock
oBody["LockedReason"]   := cObserv

cBody   := EncodeUTF8( oBody:ToJson() )

Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeader, "Content-Type: application/json" )

TmsRepTrac("TMSBCARepomFrete - ShippingLock")
TmsRepTrac( ::url_repom+cEndPoint+"/"+cShippID )

xResult := HTTPQuote( ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version ,;
            "PATCH",,cBody,120,aClone(aHeader),@cHeader)

lRet    := .F. 
If xResult <> Nil 
    If FwJsonDeserialize(xResult,@oResult)
        If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) .And. ;
            oResult:Response:StatusCode == 200 
            lRet    := .T.
        ElseIf oResult:Response:StatusCode == 404
            ::last_error    := AllTrim(oResult:Response:Message)
            Aadd( ::message_error , { ::last_error , "04" , "" } )
        ElseIf ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "ERRORS" )  
            lRet    := .F. 
            aErrors := oResult:Errors
            For nCount := 1 To Len(aErrors)
                ::last_error    := cValToChar(oResult:Response:StatusCode) + chr(10) + chr(13)
                ::last_error    += cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message + chr(10) + chr(13)

                Aadd( ::message_error , { AllTrim( cValToChar(oResult:Response:StatusCode)  ) , "04", ""})
                Aadd( ::message_error , { AllTrim( cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message  ) , "04", ""})
            Next nCount 
        EndIf 
    Else 
        ::last_error    := "Error FwJsonDeserialize " + chr(10) + chr(13)
        ::last_error    += ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version
        ::last_error    += xResult

        Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
    Endif 
Else 
    ::last_error    := "Error HTTPQuote - PATCH " + chr(10) + chr(13)
    ::last_error    += ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version


    Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
EndIf 

If !lRet
    ::last_error    := DecodeUtf8( AllTrim(::last_error) )
    If ::exibe_erro
        TmsMsgErr( ::message_error , "TMS X REPOM" )
        FwFreeArray(::message_error )
        ::message_error     := {}             
    EndIf
    TmsRepTrac( ::last_error )
EndIf

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} ShippingAddTax()
This method creates tax movements on the shipping.
PATCH /Shipping/AddTaxes ['IRRF', 'SEST', 'SENAT', 'INSS'],

@author Caio Murakami
@since 07/05/2021
@version 1.0
@type function
/*/
//--------------------------------------------------------------------
METHOD ShippingAddTax( cFilOri , cViagem , cCodVei , nValSEST , nValSENAT , nValINSS, nValIRRF ) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/Shipping/AddTaxes"
Local cBody     := ""
Local xResult   := Nil 
Local cHeader   := ""
Local oResult   := ""
Local nCount    := 0 
Local aErrors   := {} 
Local cShippID  := ""
Local oBody     := JsonObject():New()
Local oTaxes    := JsonObject():New()
Local nSest     := 2 
Local nSenat    := 3 
Local nINSS     := 34
Local nIRRF     := 1 
Local aTaxes    := {} 

Default cFilOri     := ""
Default cViagem     := ""
Default cCodVei     := ""
Default cTipo       := ""
Default nValSEST    := 0 
Default nValSENAT   := 0 
Default nValINSS    := 0 
Default nValIRRF    := 0 

cShippID    := ::GetIdShipping( cFilOri , cViagem , cCodVei )

//-- 'IRRF', 'SEST', 'SENAT', 'INSS'
oTaxes["Type"]  := "SEST"
oTaxes["Value"] := nValSEST

Aadd( aTaxes , oTaxes )

oTaxes    := JsonObject():New()

oTaxes["Type"]  := "SENAT"
oTaxes["Value"] := nValSENAT

Aadd( aTaxes , oTaxes )

oTaxes    := JsonObject():New()

oTaxes["Type"]  := "INSS"
oTaxes["Value"] := nValINSS

Aadd( aTaxes , oTaxes )

oTaxes    := JsonObject():New()

oTaxes["Type"]  := "IRRF"
oTaxes["Value"] := nValIRRF

Aadd( aTaxes , oTaxes )

oBody["ShippingId"]         := Val( cShippID ) 
oBody["ShippingTaxes"]      := aTaxes

cBody   := "[ " + EncodeUTF8( oBody:ToJson() ) + " ]"

Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeader, "Content-Type: application/json" )

TmsRepTrac("TMSBCARepomFrete - ShippingAddTax")
TmsRepTrac( ::url_repom+cEndPoint+"/"+cShippID )

xResult := HTTPQuote( ::url_repom+cEndPoint+"?x-api-version="+::api_version ,;
            "PATCH",,cBody,120,aClone(aHeader),@cHeader)

lRet    := .F. 
If xResult <> Nil 
    If FwJsonDeserialize(xResult,@oResult)
        If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) .And. ;
            ( oResult:Response:StatusCode == 200  .Or.  oResult:Response:StatusCode == 201 )
            lRet    := .T.
        ElseIf oResult:Response:StatusCode == 404
            ::last_error    := AllTrim(oResult:Response:Message)
            Aadd( ::message_error , { ::last_error , "04" , "" } )
        ElseIf ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "ERRORS" )  
            lRet    := .F. 
            aErrors := oResult:Errors
            For nCount := 1 To Len(aErrors)
                ::last_error    := cValToChar(oResult:Response:StatusCode) + chr(10) + chr(13)
                ::last_error    += cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message + chr(10) + chr(13)

                Aadd( ::message_error , { AllTrim( cValToChar(oResult:Response:StatusCode)  ) , "04", ""})
                Aadd( ::message_error , { AllTrim( cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message  ) , "04", ""})
            Next nCount 
        EndIf 
    Else 
        ::last_error    := "Error FwJsonDeserialize " + chr(10) + chr(13)
        ::last_error    += ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version
        ::last_error    += xResult

        Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
    Endif 
Else 
    ::last_error    := "Error HTTPQuote - PATCH " + chr(10) + chr(13)
    ::last_error    += ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version


    Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
EndIf 

If !lRet
    ::last_error    := DecodeUtf8( AllTrim(::last_error) )
    If ::exibe_erro
        TmsMsgErr( ::message_error , "TMS X REPOM" )
        FwFreeArray(::message_error )
        ::message_error     := {}             
    EndIf
    TmsRepTrac( ::last_error )
EndIf

Return lRet


//-----------------------------------------------------------------
/*/{Protheus.doc} GetShipByShip()
This method returns shipping informations from searching for its ID.
GET /Shipping/ByShipping/{shippingId}

@author Caio Murakami
@since 07/10/2020
@version 1.0
@type function
/*/
//--------------------------------------------------------------------
METHOD GetShipByShip( cFilOri , cViagem , cCodVei ) CLASS TMSBCARepomFrete
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/Shipping/ByShipping/"
Local cGet      := ""
Local aArea     := GetArea()
Local cJson     := ""
Local oResult   := ""
Local oJson     := Nil 
Local aNames    := {}
Local nCount    := 1 
Local cShippID  := ""

Default cFilOri     := ""
Default cViagem     := ""
Default cCodVei     := ""

cShippID    := ::GetIdShipping( cFilOri , cViagem , cCodVei )

cPathPar    += cShippID

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )

If FwJsonDeserialize(cGet,@oResult)
    If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) .And. ;
        oResult:Response:StatusCode == 200 .And. AttIsMemberOf( oResult, "RESULT" )

        cJson   := FwJsonSerialize(oResult:Result,.F.,.T.)
        oJson   := JsonObject():New()
        oJson:FromJson(cJson)

        aNames  := oJson:GetNames()

        For nCount := 1 To Len(aNames)
            Aadd( aRet , { aNames[nCount] , oJson[aNames[nCount]]  })
        Next nCount
    ElseIf ValType(oResult) <> "O"
        Aadd( aRet , { "GET - Shipping/ByIdentifier/" +  cFilOri + cViagem  })
        Aadd( aRet , { cGet })
    EndIf 
EndIf 

RestArea( aArea )
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetShipById()
This method returns shipping informations from searching for its ID.
GET /Shipping/ByIdentifier/{identifier} 

@author Caio Murakami
@since 10/11/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetShipById( cFilOri , cViagem ) CLASS TMSBCARepomFrete
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/Shipping/ByIdentifier/"
Local cGet      := ""
Local aArea     := GetArea()
Local cJson     := ""
Local oResult   := ""
Local oJson     := Nil 
Local aNames    := {}
Local nCount    := 1 

Default cFilOri     := ""
Default cViagem     := ""

cPathPar    += Escape( cFilOri + cViagem )

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )

If FwJsonDeserialize(cGet,@oResult)
    If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) .And. ;
        oResult:Response:StatusCode == 200 .And. AttIsMemberOf( oResult, "RESULT" )

        cJson   := FwJsonSerialize(oResult:Result,.F.,.T.)
        oJson   := JsonObject():New()
        oJson:FromJson(cJson)

        aNames  := oJson:GetNames()

        For nCount := 1 To Len(aNames)
            Aadd( aRet , { aNames[nCount] , oJson[aNames[nCount]]  })
        Next nCount
    ElseIf ValType(oResult) <> "O"
        Aadd( aRet , { "GET - Shipping/ByIdentifier/" +  cFilOri + cViagem  })
        Aadd( aRet , { cGet })
    EndIf 
EndIf 

RestArea( aArea )
Return aRet
//-----------------------------------------------------------------
/*/{Protheus.doc} PaymentCreate()
PaymentPost

@author Caio Murakami
@since 01/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD PaymentCreate(cFilOri,cViagem) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aArea     := GetArea()
Local aHeader   := {} 
Local cEndPoint := "/ShippingPayment"
Local oRest     := FwRest():New( ::url_repom ) 
Local oBody     := JsonObject():New()
Local oResult   := Nil 
Local aResult   := {} 
Local cResult   := ""
Local oDocs     := Nil
Local aDocs     := {} 
Local nCount    := 1 
Local cJsonKey  := ""
Local cBody     := ""

Default cFilOri     := ""
Default cViagem     := ""

::PaymentInfo(cFilOri,cViagem)

Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeader, "Content-Type: application/json" )

For nCount := 1 To Len(::payment_Documents)
    oDocs   := JsonObject():New()

    oDocs["Number"]         := ::GetInfoArr( ::payment_Documents[nCount] , "Number" , 1 )
    oDocs["Series"]         := ::GetInfoArr( ::payment_Documents[nCount] , "Series" , 1 )
    oDocs["BranchCode"]     := ::GetInfoArr( ::payment_Documents[nCount] , "BranchCode" , 1 )
    oDocs["DocumentType"]   := ::GetInfoArr( ::payment_Documents[nCount] , "DocumentType" , 1 )
    oDocs["DocumentStatus"] := ::GetInfoArr( ::payment_Documents[nCount] , "DocumentStatus" , 1 )

    Aadd( aDocs, oDocs )
Next nCount 

oBody["BranchCode"]         := ::payment_BranchCode
oBody["ShippingID"]         := ::payment_ShippingID
oBody["TotalUnloadWeight"]  := ::payment_TotalUnloadWeight
oBody["Documents"]          := aClone( aDocs )

cBody   := oBody:ToJson()

oRest:SetPath(cEndPoint + "?x-api-version=" + ::api_version )
oRest:SetPostParams( cBody )  

TmsRepTrac("TMSBCARepomFrete - PaymentCreate")
TmsRepTrac( cBody )

lRet    := oRest:Post( aHeader ) 

If !lRet
    If ValType(oRest) == "O"
        ::last_error   := AllTrim( oRest:GetLastError() ) + CHR(13) + AllTrim( Decodeutf8( oRest:GetResult() ) )
        
        Aadd( ::message_error , { AllTrim( oRest:GetLastError() ) , "04", ""})
        Aadd( ::message_error , { AllTrim( Decodeutf8( oRest:GetResult() )) , "04" , "" } )  
        Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 

        If ::exibe_erro
            TmsMsgErr( ::message_error , "TMS X REPOM" )
            FwFreeArray(::message_error )
            ::message_error     := {}             
        EndIf        
        TmsRepTrac( ::last_error )
    EndIf
        
Else 
    cResult := Decodeutf8( oRest:GetResult() )

    If FWJsonDeserialize(cResult,@oResult)
        cJsonKey                := oResult:Response:Message 
        aResult                 := StrToKArr( cJsonKey , ":" )
    EndIf 
EndIf

For nCount := 1 To Len(aDocs)
    FwFreeObj(aDocs[nCount])
Next nCount 

FwFreeArray(aDocs)
FwFreeObj( oRest )
FwFreeObj( aResult )
FwFreeObj( oResult )
FwFreeObj( oBody )

RestArea( aArea )
Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} PaymentCancel()
This method cancels a shipping that did not have consumption or did not use of toll credits(Vale Pedágio Repom).

@author Caio Murakami
@since 14/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD PaymentCancel(cFilOri,cViagem) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/ShippingPayment/Cancel"
Local xResult   := Nil 
Local cHeader   := ""
Local oResult   := ""
Local nCount    := 0 
Local aErrors   := {} 
Local cShippID  := ""

Default cFilOri     := ""
Default cViagem     := ""

Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeader, "Content-Type: application/json" )

cShippID    := ::GetIdShipping( cFilOri , cViagem )

cEndPoint   += "/"+ cShippID

TmsRepTrac("TMSBCARepomFrete - PaymentCancel")
TmsRepTrac( ::url_repom+cEndPoint )

xResult := HTTPQuote( ::url_repom+cEndPoint+ "?x-api-version="+::api_version ,;
            "PATCH",,,120,aClone(aHeader),@cHeader)

lRet    := .F. 
If xResult <> Nil 
    If FwJsonDeserialize(xResult,@oResult)
        If AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "StatusCode" )  .And.  oResult:Response:StatusCode == 200 
            lRet    := .T.
        ElseIf AttIsMemberOf( oResult, "Errors" ) 
            lRet    := .F. 
            aErrors := oResult:Errors
            For nCount := 1 To Len(aErrors)
                ::last_error    := cValToChar(oResult:Response:StatusCode) + chr(10) + chr(13)
                ::last_error    += cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message + chr(10) + chr(13)
                Aadd( ::message_error , { AllTrim( cValToChar(oResult:Response:StatusCode)  ) , "04", ""})
                Aadd( ::message_error , { AllTrim( cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message  ) , "04", ""})
            Next nCount 
        EndIf 
    Else 
        ::last_error    := "Error FwJsonDeserialize " + chr(10) + chr(13)
        ::last_error    += ::url_repom+cEndPoint+"?x-api-version="+::api_version
        ::last_error    += xResult
        Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
    Endif 
Else 
    ::last_error    := "Error HTTPQuote - PATCH " + chr(10) + chr(13)
    ::last_error    += ::url_repom+cEndPoint+"?x-api-version="+::api_version
    Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
EndIf 

If !lRet
    ::last_error    := DecodeUtf8( AllTrim(::last_error) )
    If ::exibe_erro
        TmsMsgErr( ::message_error , "TMS X REPOM" )
        FwFreeArray(::message_error )
        ::message_error     := {}             
    EndIf
    TmsRepTrac( ::last_error )
EndIf

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} PaymLostDoc()
This method updates the status of a document to "Lost".

@author Caio Murakami
@since 14/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD PaymLostDoc(cFilOri,cViagem,cFilDoc,cDoc,cSerie) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/ShippingPayment/DocumentLost"
Local xResult   := Nil 
Local cHeader   := ""
Local oResult   := ""
Local nCount    := 0 
Local aErrors   := {} 
Local cShippID  := ""
Local oBody     := JsonObject():New()
Local cBody     := ""
Local cSerTms   := ""
Local cDocTms   := ""

Default cFilOri     := ""
Default cViagem     := ""
Default cFilDoc     := ""
Default cDoc        := ""
Default cSerie      := ""

Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeader, "Content-Type: application/json" )

cShippID    := ::GetIdShipping( cFilOri , cViagem )

cEndPoint   += "/"+ cShippID

cSerTms     := Posicione("DTQ",2,xFilial("DTQ") + cFilOri + cViagem , "DTQ_SERTMS" )
cDocTMS     := Posicione("DT6",2,xFilial("DT6") + cFilDoc + cDoc + cSerie , "DT6_DOCTMS" )

oBody["Number"]             := cDoc  
oBody["Series"]             := cSerie                                                                                                                           
oBody["BranchCode"]         := RTrim(cFilDoc)
oBody["DocumentType"]       := RTrim( ::RetDocType(cFilDoc,cDoc,cSerie,cDocTMS,cSerTms) )
oBody["IssuerBranchCode"]   := Rtrim(cFilDoc)

cBody   := EncodeUTF8( oBody:ToJson() )

TmsRepTrac("TMSBCARepomFrete - PaymLostDoc")
TmsRepTrac( cBody )

xResult := HTTPQuote( ::url_repom+cEndPoint+ "?x-api-version="+::api_version ,;
            "PATCH",,cBody,120,aClone(aHeader),@cHeader)

lRet    := .F. 
If xResult <> Nil 
    If FwJsonDeserialize(xResult,@oResult)
        If AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "StatusCode" )  .And.  oResult:Response:StatusCode == 200 
            lRet    := .T.
        ElseIf oResult:Response:StatusCode == 404
            ::last_error    := AllTrim(oResult:Response:Message)
            Aadd( ::message_error , { ::last_error , "04" , "" } )
        ElseIf AttIsMemberOf( oResult, "Errors" ) 
            lRet    := .F. 
            aErrors := oResult:Errors
            For nCount := 1 To Len(aErrors)
                ::last_error    := cValToChar(oResult:Response:StatusCode) + chr(10) + chr(13)
                ::last_error    += cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message + chr(10) + chr(13)
                Aadd( ::message_error , { AllTrim( cValToChar(oResult:Response:StatusCode)  ) , "04", ""})
                Aadd( ::message_error , { AllTrim( cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message  ) , "04", ""})
            Next nCount 
            Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } )
        EndIf 
    Else 
        ::last_error    := "Error FwJsonDeserialize " + chr(10) + chr(13)
        ::last_error    += ::url_repom+cEndPoint+"?x-api-version="+::api_version
        ::last_error    += xResult
        Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
        Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 
    Endif 
Else 
    ::last_error    := "Error HTTPQuote - PATCH " + chr(10) + chr(13)
    ::last_error    += ::url_repom+cEndPoint+"?x-api-version="+::api_version
    ::last_error    += cBody
    Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
EndIf 

If !lRet
    ::last_error    := DecodeUtf8( AllTrim(::last_error) )
    If ::exibe_erro
        TmsMsgErr( ::message_error , "TMS X REPOM" )
        FwFreeArray(::message_error )
        ::message_error     := {}             
    EndIf
    TmsRepTrac( ::last_error )
EndIf

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} PaymReshipDoc()
This method updates the status of a document to "Reshipped".

@author Caio Murakami
@since 14/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD PaymReshipDoc(cFilOri,cViagem,cFilDoc,cDoc,cSerie) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/ShippingPayment/DocumentReship"
Local xResult   := Nil 
Local cHeader   := ""
Local oResult   := ""
Local nCount    := 0 
Local aErrors   := {} 
Local cShippID  := ""
Local oBody     := JsonObject():New()
Local cBody     := ""
Local cSerTms   := ""
Local cDocTms   := ""

Default cFilOri     := ""
Default cViagem     := ""
Default cFilDoc     := ""
Default cDoc        := ""
Default cSerie      := ""

Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeader, "Content-Type: application/json" )

cShippID    := ::GetIdShipping( cFilOri , cViagem )

cEndPoint   += "/"+ cShippID

cSerTms     := Posicione("DTQ",2,xFilial("DTQ") + cFilOri + cViagem , "DTQ_SERTMS" )
cDocTMS     := Posicione("DT6",2,xFilial("DT6") + cFilDoc + cDoc + cSerie , "DT6_DOCTMS" )

oBody["Number"]             := cDoc  
oBody["Series"]             := cSerie                                                                                                                           
oBody["BranchCode"]         := RTrim(cFilDoc)
oBody["DocumentType"]       := RTrim( ::RetDocType(cFilDoc,cDoc,cSerie,cDocTMS,cSerTms) )
oBody["IssuerBranchCode"]   := RTrim(cFilDoc)

cBody   := EncodeUTF8( oBody:ToJson() )

TmsRepTrac("TMSBCARepomFrete - PaymReshipDoc")
TmsRepTrac( cBody )

xResult := HTTPQuote( ::url_repom+cEndPoint+ "?x-api-version="+::api_version ,;
            "PATCH",,cBody,120,aClone(aHeader),@cHeader)

lRet    := .F. 
If xResult <> Nil 
    If FwJsonDeserialize(xResult,@oResult)
        If AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "StatusCode" )  .And.  oResult:Response:StatusCode == 200 
            lRet    := .T.
        ElseIf AttIsMemberOf( oResult, "Errors" ) 
            lRet    := .F. 
            aErrors := oResult:Errors
            For nCount := 1 To Len(aErrors)
                ::last_error    := cValToChar(oResult:Response:StatusCode) + chr(10) + chr(13)
                ::last_error    += cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message + chr(10) + chr(13)
                Aadd( ::message_error , { AllTrim( cValToChar(oResult:Response:StatusCode)  ) , "04", ""})
                Aadd( ::message_error , { AllTrim( cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message  ) , "04", ""})
            Next nCount 
            Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 
        EndIf 
    Else 
        ::last_error    := "Error FwJsonDeserialize " + chr(10) + chr(13)
        ::last_error    += ::url_repom+cEndPoint+"?x-api-version="+::api_version
        ::last_error    += xResult

            Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
            Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 
    Endif 
Else 
    ::last_error    := "Error HTTPQuote - PATCH " + chr(10) + chr(13)
    ::last_error    += ::url_repom+cEndPoint+"?x-api-version="+::api_version
    ::last_error    += cBody
    
    Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
EndIf 

If !lRet
    ::last_error    := DecodeUtf8( AllTrim(::last_error) )
    
    If ::exibe_erro
        TmsMsgErr( ::message_error , "TMS X REPOM" )
        FwFreeArray(::message_error )
        ::message_error     := {}             
    EndIf
    TmsRepTrac( ::last_error )
EndIf

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} PaymDeliverDoc()
This method updates the status of a document to "Delivered".

@author Caio Murakami
@since 14/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD PaymDeliverDoc(cFilOri,cViagem,cFilDoc,cDoc,cSerie) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/ShippingPayment/DocumentDelivered"
Local xResult   := Nil 
Local cHeader   := ""
Local oResult   := ""
Local nCount    := 0 
Local aErrors   := {} 
Local cShippID  := ""
Local oBody     := JsonObject():New()
Local cBody     := ""
Local cSerTms   := ""
Local cDocTms   := ""

Default cFilOri     := ""
Default cViagem     := ""
Default cFilDoc     := ""
Default cDoc        := ""
Default cSerie      := ""

Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeader, "Content-Type: application/json" )

cShippID    := ::GetIdShipping( cFilOri , cViagem )

cEndPoint   += "/"+ cShippID

cSerTms     := Posicione("DTQ",2,xFilial("DTQ") + cFilOri + cViagem , "DTQ_SERTMS" )
cDocTMS     := Posicione("DT6",2,xFilial("DT6") + cFilDoc + cDoc + cSerie , "DT6_DOCTMS" )

oBody["Number"]             := cDoc  
oBody["Series"]             := cSerie                                                                                                                           
oBody["BranchCode"]         := RTrim(cFilDoc)
oBody["DocumentType"]       := RTrim( ::RetDocType(cFilDoc,cDoc,cSerie,cDocTMS,cSerTms) )
oBody["IssuerBranchCode"]   := RTrim(cFilDoc)

cBody   := EncodeUTF8( oBody:ToJson() )

TmsRepTrac("TMSBCARepomFrete - PaymDeliverDoc")
TmsRepTrac( cBody )

xResult := HTTPQuote( ::url_repom+cEndPoint+ "?x-api-version="+::api_version ,;
            "PATCH",,cBody,120,aClone(aHeader),@cHeader)

lRet    := .F. 
If xResult <> Nil 
    If FwJsonDeserialize(xResult,@oResult)
        If AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "StatusCode" )  .And.  oResult:Response:StatusCode == 200 
            lRet    := .T.
        ElseIf AttIsMemberOf( oResult, "Errors" ) 
            lRet    := .F. 
            aErrors := oResult:Errors
            For nCount := 1 To Len(aErrors)
                ::last_error    := cValToChar(oResult:Response:StatusCode) + chr(10) + chr(13)
                ::last_error    += cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message + chr(10) + chr(13)
                Aadd( ::message_error , { AllTrim( cValToChar(oResult:Response:StatusCode)  ) , "04", ""})
                Aadd( ::message_error , { AllTrim( cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message  ) , "04", ""})
            Next nCount 
            Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 
        EndIf 
    Else 
        ::last_error    := "Error FwJsonDeserialize " + chr(10) + chr(13)
        ::last_error    += ::url_repom+cEndPoint+"?x-api-version="+::api_version
        ::last_error    += xResult
            Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
            Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 
    Endif 
Else 
    ::last_error    := "Error HTTPQuote - PATCH " + chr(10) + chr(13)
    ::last_error    += ::url_repom+cEndPoint+"?x-api-version="+::api_version
    ::last_error    += cBody
    Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
EndIf 

If !lRet
    ::last_error    := DecodeUtf8( AllTrim(::last_error) )
    If ::exibe_erro
        TmsMsgErr( ::message_error , "TMS X REPOM" )
        FwFreeArray(::message_error )
        ::message_error     := {}             
    EndIf
    TmsRepTrac( ::last_error )
EndIf

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} PaymDismisDoc()
This method dismisses a document.

@author Caio Murakami
@since 14/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD PaymDismisDoc(cFilOri,cViagem,cFilDoc,cDoc,cSerie) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/ShippingPayment/DocumentDismissed"
Local xResult   := Nil 
Local cHeader   := ""
Local oResult   := ""
Local nCount    := 0 
Local aErrors   := {} 
Local cShippID  := ""
Local oBody     := JsonObject():New()
Local cBody     := ""
Local cSerTms   := ""
Local cDocTms   := ""

Default cFilOri     := ""
Default cViagem     := ""
Default cFilDoc     := ""
Default cDoc        := ""
Default cSerie      := ""

Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeader, "Content-Type: application/json" )

cShippID    := ::GetIdShipping( cFilOri , cViagem )

cEndPoint   += "/"+ cShippID

cSerTms     := Posicione("DTQ",2,xFilial("DTQ") + cFilOri + cViagem , "DTQ_SERTMS" )
cDocTMS     := Posicione("DT6",2,xFilial("DT6") + cFilDoc + cDoc + cSerie , "DT6_DOCTMS" )

oBody["Number"]             := cDoc  
oBody["Series"]             := cSerie                                                                                                                           
oBody["BranchCode"]         := RTrim(cFilDoc)
oBody["DocumentType"]       := RTrim( ::RetDocType(cFilDoc,cDoc,cSerie,cDocTMS,cSerTms) )
oBody["IssuerBranchCode"]   := RTrim(cFilDoc)

cBody   := EncodeUTF8( oBody:ToJson() )

TmsRepTrac("TMSBCARepomFrete - PaymDismisDoc")
TmsRepTrac( cBody )

xResult := HTTPQuote( ::url_repom+cEndPoint+ "?x-api-version="+::api_version ,;
            "PATCH",,cBody,120,aClone(aHeader),@cHeader)

lRet    := .F. 
If xResult <> Nil 
    If FwJsonDeserialize(xResult,@oResult)
        If AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "StatusCode" )  .And.  oResult:Response:StatusCode == 200 
            lRet    := .T.
        ElseIf AttIsMemberOf( oResult, "Errors" ) 
            lRet    := .F. 
            aErrors := oResult:Errors
            For nCount := 1 To Len(aErrors)
                ::last_error    := cValToChar(oResult:Response:StatusCode) + chr(10) + chr(13)
                ::last_error    += cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message + chr(10) + chr(13)

                Aadd( ::message_error , { AllTrim( cValToChar(oResult:Response:StatusCode)  ) , "04", ""})
                Aadd( ::message_error , { AllTrim( cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message  ) , "04", ""})
            Next nCount 
            Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 
        EndIf 
    Else 
        ::last_error    := "Error FwJsonDeserialize " + chr(10) + chr(13)
        ::last_error    += ::url_repom+cEndPoint+"?x-api-version="+::api_version
        ::last_error    += xResult

            Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
            Aadd( ::message_error , { AllTrim(cBody) , "04" , "" } ) 
    Endif 
Else 
    ::last_error    := "Error HTTPQuote - PATCH " + chr(10) + chr(13)
    ::last_error    += ::url_repom+cEndPoint+"?x-api-version="+::api_version
    ::last_error    += cBody
    
    Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
EndIf 

If !lRet
    ::last_error    := DecodeUtf8( AllTrim(::last_error) )
    If ::exibe_erro
        TmsMsgErr( ::message_error , "TMS X REPOM" )
        FwFreeArray(::message_error )
        ::message_error     := {}             
    EndIf
    TmsRepTrac( ::last_error )
EndIf

Return lRet 
//-----------------------------------------------------------------
/*/{Protheus.doc} AuthorizationCreate()
Payment Authorization

@author Caio Murakami
@since 01/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD AuthorizationCreate(cFilOri,cViagem,cCodVei) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aArea     := GetArea()
Local aHeader   := {} 
Local cEndPoint := "/PaymentAuthorization"
Local oRest     := FwRest():New( ::url_repom ) 
Local oBody     := {}
Local oResult   := Nil 
Local nCount    := 1 
Local cJson     := ""

Default cFilOri     := ""
Default cViagem     := ""
Default cCodVei     := ""

::AuthInfo(cFilOri,cViagem,cCodVei)

Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeader, "Content-Type: application/json" )

For nCount := 1 To Len(::auth_autorizations)
    Aadd( oBody , JsonObject():New() )
    oBody[Len(oBody)]["ShippingId"]         := ::GetInfoArr( ::auth_autorizations[nCount],"ShippingId",1) 
    oBody[Len(oBody)]["Identifier"]         := ::GetInfoArr( ::auth_autorizations[nCount],"Identifier",1) 
    //oBody[Len(oBody)]["Branch"]             := ::GetInfoArr( ::auth_autorizations[nCount],"Branch",1) 
    oBody[Len(oBody)]["BranchCode"]         := ::GetInfoArr( ::auth_autorizations[nCount],"BranchCode",1) 
    oBody[Len(oBody)]["PaymentDate"]        := ::GetInfoArr( ::auth_autorizations[nCount],"PaymentDate",1) 
Next nCount 

cJson   := FwJsonSerialize( aClone(oBody) )

oRest:SetPath(cEndPoint + "?x-api-version=" + ::api_version )
oRest:SetPostParams( cJson )  

TmsRepTrac("TMSBCARepomFrete - AuthorizationCreate")
TmsRepTrac( cJson )

lRet    := oRest:Post( aHeader ) 

If !lRet
    ::last_error   := AllTrim( oRest:GetLastError() ) + CHR(13) + AllTrim( Decodeutf8( oRest:GetResult() ) )
    
    Aadd( ::message_error , { AllTrim( oRest:GetLastError() ) , "04", ""})
    Aadd( ::message_error , { AllTrim( Decodeutf8( oRest:GetResult() )) , "04" , "" } )  
    Aadd( ::message_error , { AllTrim(cJson) , "04" , "" } ) 

    If ::exibe_erro
        TmsMsgErr( ::message_error , "TMS X REPOM" )
        FwFreeArray(::message_error )
        ::message_error     := {}             
    EndIf
    TmsRepTrac( ::last_error )
Else 
    cResult := Decodeutf8( oRest:GetResult() )

    If FWJsonDeserialize(cResult,@oResult)
        If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) .And. ;
            oResult:Response:StatusCode == 200 
            lRet    := .T. 
        EndIf 
    EndIf 
EndIf

RestArea( aArea )
Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} AuthCancel()
Payment Authorization Cancela

@author Caio Murakami
@since 13/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD AuthCancel(cFilOri,cViagem,cCodVei) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/PaymentAuthorization/Cancel"
Local cJson     := ""
Local xResult   := Nil 
Local cHeader   := ""
Local oResult   := ""
Local oBody     := {}
Local nCount    := 0 
Local aErrors   := {} 

Default cFilOri     := ""
Default cViagem     := ""
Default cCodVei     := ""

lRet   := ::AuthInfo(cFilOri,cViagem,cCodVei)

If lRet
    Aadd(aHeader, "Accept: application/json" )
    Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
    Aadd(aHeader, "Content-Type: application/json" )

   For nCount := 1 To Len(::auth_autorizations)
        Aadd( oBody , JsonObject():New() )
        oBody[Len(oBody)]["ShippingId"]         := ::GetInfoArr( ::auth_autorizations[nCount],"ShippingId",1) 
        oBody[Len(oBody)]["Identifier"]         := ::GetInfoArr( ::auth_autorizations[nCount],"Identifier",1) 
        oBody[Len(oBody)]["BranchCode"]         := ::GetInfoArr( ::auth_autorizations[nCount],"BranchCode",1)  
    Next nCount 

    cJson   := FwJsonSerialize( aClone(oBody) )

    TmsRepTrac("TMSBCARepomFrete - AuthCancel")
    TmsRepTrac( cJson )

    xResult := HTTPQuote( ::url_repom+cEndPoint+"?x-api-version="+::api_version ,;
                "PATCH",,cJson,120,aClone(aHeader),@cHeader)

    lRet    := .F. 
    If xResult <> Nil 
        If FwJsonDeserialize(xResult,@oResult)
            If AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "StatusCode" )  .And.  oResult:Response:StatusCode == 200 
                lRet    := .T.
            ElseIf AttIsMemberOf( oResult, "Errors" ) 
                lRet    := .F. 
                aErrors := oResult:Errors
                For nCount := 1 To Len(aErrors)
                    ::last_error    := cValToChar(oResult:Response:StatusCode) + chr(10) + chr(13)
                    ::last_error    += cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message + chr(10) + chr(13)
                    Aadd( ::message_error , { AllTrim( cValToChar(oResult:Response:StatusCode)  ) , "04", ""})
                    Aadd( ::message_error , { AllTrim( cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message  ) , "04", ""})
                Next nCount 
            EndIf 
        Else 
            ::last_error    := "Error FwJsonDeserialize " + chr(10) + chr(13)
            ::last_error    += ::url_repom+cEndPoint+"?x-api-version="+::api_version
            ::last_error    += xResult
             Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
        Endif 
    Else 
        ::last_error    := "Error HTTPQuote - PATCH " + chr(10) + chr(13)
        ::last_error    += ::url_repom+cEndPoint+"?x-api-version="+::api_version
        
        Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
    EndIf 

    If !lRet
        ::last_error    := DecodeUtf8( AllTrim(::last_error) )
        If ::exibe_erro .And. Len( ::message_error ) > 0 
            TmsMsgErr( ::message_error , "TMS X REPOM" )
            FwFreeArray(::message_error )
            ::message_error     := {}             
        EndIf
         TmsRepTrac( ::last_error )
    EndIf

EndIf 

For nCount := 1 To Len(oBody)
    FwFreeObj(oBody[nCount])    
Next nCount 

FwFreeArray(oBody)

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} PaymentInfo()
Informações de pagamento
@author Caio Murakami
@since 01/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD PaymentInfo(cFilOri,cViagem) CLASS TMSBCARepomFrete
Local aArea         := GetArea()
Local oDadosViag    := Nil
Local aDocs         := Nil 
Local nCount        := 0 
Local nPeso         := 0 
Local cDocType      := ""
Local cFilDoc       := ""
Local cDoc          := ""
Local cSerie        := ""
Local cDocTMS       := ""
Local cStatus       := ""
Local cSerTms       := Posicione("DTQ",2,xFilial("DTQ") + cFilOri + cViagem , "DTQ_SERTMS")

Default cFilOri     := ""
Default cViagem     := ""

oDadosViag	:= TMSBCADadosTMS():New(cFilOri,cViagem,3,.T.)
aDocs       := oDadosViag:GetDocs()

For nCount := 1 To Len(aDocs)
    cFilDoc     := ::GetInfoArr(aDocs[nCount],"DT6_FILDOC",1)
    cDoc        := ::GetInfoArr(aDocs[nCount],"DT6_DOC",1)
    cSerie      := ::GetInfoArr(aDocs[nCount],"DT6_SERIE",1)
    cDocTms     := ::GetInfoArr(aDocs[nCount],"DT6_DOCTMS",1)
    cDocType    := ::RetDocType(cFilDoc,cDoc,cSerie,cDocTMS,cSerTms) //-- = ['CTE', 'NFe', 'NFSe', 'CRT', 'OCC', 'Romaneio', 'MDFe']
    nPeso       += ::GetInfoArr(aDocs[nCount],"PESO",3)
    cStatus     := ::GetInfoArr(aDocs[nCount],"DT6_STATUS",1) 
    //-----------------------------------------------------------------
    /*  CBM: Verificar status do documento TMS X status documeto REPOM

        //-- = ['Dismissed', 'Lost', 'Delivered', 'Reshipping']
        
        DT6_STATUS == '1' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'1') //-- Em aberto
        DT6_STATUS == '2' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'2') //-- Carregado ### Indicado para Coleta
        DT6_STATUS == '3' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'3') //-- Em transito
        DT6_STATUS == '4' .And. DT6_SERIE <> 'COL' ) .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'5') //-- Chegada parcial ### Documento Informado
        DT6_STATUS == '5' .And. DT6_SERIE <> 'COL' ) .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'4') //-- Chegada final   ### Encerrada
        DT6_STATUS == '6'	//-- Indicado p/ entrega
        DT6_STATUS == '7'	//-- Entregue
        TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'9')	//-- Ordem de Coleta Cancelada
        DT6_STATUS == '8'	//Entrega Parcial
        DT6_STATUS == '9'//Anulado
        DT6_STATUS == 'A'	//Retorno Total
    */
    //-----------------------------------------------------------------
    
    If cStatus $ "6/7/8/4/5"
        cStatus     := "Delivered"
    ElseIf cStatus $ "9/A"
        cStatus     := "Dismissed"
    Else 
        cStatus     := "Delivered"   //Default
    EndIf 

    Aadd( ::payment_Documents , {} )
    Aadd( ::payment_Documents[Len(::payment_Documents)] , { "Number"        , RTrim( cDoc ) , "Number"})
    Aadd( ::payment_Documents[Len(::payment_Documents)] , { "Series"        , RTrim( cSerie ), "Series"})
    Aadd( ::payment_Documents[Len(::payment_Documents)] , { "BranchCode"    , RTrim(cFilDoc), "BranchCode"})
    Aadd( ::payment_Documents[Len(::payment_Documents)] , { "DocumentType"  , RTrim( cDocType ) , "DocumentType"})
    Aadd( ::payment_Documents[Len(::payment_Documents)] , { "DocumentStatus", cStatus , "DocumentStatus"}) //-- = ['Dismissed', 'Lost', 'Delivered', 'Reshipping']

Next nCount 

::payment_BranchCode        := RTrim(cFilOri)
::payment_ShippingID        := ::GetIdShipping(cFilOri,cViagem) 
::payment_TotalUnloadWeight := nPeso

RestArea( aArea )
Return 

//-----------------------------------------------------------------
/*/{Protheus.doc} AuthInfo()
Obtém informações de autorização de pagamento
@author Caio Murakami
@since 02/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD AuthInfo( cFilOri , cViagem , cCodVei ) CLASS TMSBCARepomFrete
Local aArea         := GetArea() 
Local lRet          := .T. 
Local cShippID      := ""
Local nDias         := 0 
Local aData         := {} 
Local dData         := dDataBase 
Local cTime         := Time()

Default cFilOri     := ""
Default cViagem     := ""
Default cCodVei     := ""

cShippID    := ::GetIdShipping( cFilOri , cViagem , cCodVei )

DA3->(dbSetOrder(1))
If DA3->(MsSeek(cCodVei))
    SA2->(DbSetOrder(1))
	If SA2->(MsSeek(xFilial('SA2')+DA3->DA3_CODFOR+DA3->DA3_LOJFOR))
        aData := Condicao(1,SA2->A2_COND,0,dDatabase)   //-- Conseguir a data Prevista para o pagamento, nao é necessario passar o valor exato.
		nDias := Abs( Iif(Len(aData)>0,aData[1][1],dDatabase+1) - dDatabase )
    EndIf 
Endif

If SubHoras("24:00:00",cTime) <= 1 
    dData   += 1 
    cTime   := IntToHora( SubHoras("24:00:00",cTime) ) + ":00"
Else 
    cTime   := IntToHora( HoraToInt( cTime ) + 1 ) + ":00"
EndIf 

Aadd( ::auth_autorizations, {} )
Aadd( ::auth_autorizations[Len(::auth_autorizations)],{"ShippingID"     ,cShippID,"ShippingID"})
Aadd( ::auth_autorizations[Len(::auth_autorizations)],{"Identifier"     ,cFilOri + cViagem,"Identifier"})
Aadd( ::auth_autorizations[Len(::auth_autorizations)],{"Branch"         ,RTrim(cFilOri) ,"Branch"})
Aadd( ::auth_autorizations[Len(::auth_autorizations)],{"BranchCode"     ,Rtrim(cFilOri) ,"BranchCode"})
Aadd( ::auth_autorizations[Len(::auth_autorizations)],{"PaymentDate"    ,FWTimeStamp( 5, dData + nDias, cTime ),"PaymentDate"})    

RestArea( aArea )
Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} GetDriverInfo()
Obtém informações do motorista
@author Caio Murakami
@since 16/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetDriverInfo( cCodMot ) CLASS TMSBCARepomFrete
Local aArea         := GetArea()
Local cQuery        := ""
Local cAliasQry     := GetNextAlias()
Local lRet          := .F. 
Local cTypeid       := "Fixed"

Default cCodMot     := ""

cQuery  := " SELECT SYA.YA_DESCR AS PAIS, * "
cQuery  += " FROM " + RetSQLName("DA4") + " DA4 "
cQuery  += " LEFT JOIN " + RetSQLName("SYA") + " SYA "
cQuery  += "    ON YA_FILIAL    = '" + xFilial("SYA") + "' "
cQuery  += "    AND YA_CODGI    = DA4_PAIS "
cQuery  += "    AND SYA.D_E_L_E_T_ = '' "
cQuery  += " WHERE DA4_FILIAL   = '" + xFilial("DA4") + "' "
cQuery  += " AND DA4_COD        = '" + cCodMot  + "' "
cQuery  += " AND DA4.D_E_L_E_T_ = '' "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery ), cAliasQry, .F., .T. )

TcSetField(cAliasQry,"DA4_DATNAS","D",8,0)

While (cAliasQry)->(!Eof())
    ::driver_codigo                 := (cAliasQry)->DA4_COD
    ::driver_country                := Iif( Upper(AllTrim((cAliasQry)->PAIS))=="BRASIL" .Or. Empty((cAliasQry)->PAIS) , "Brazil" , AllTrim( (cAliasQry)->PAIS ) ) //-- CBM 1.1 : Tratamento provisório pais
    ::driver_national_id            := (cAliasQry)->DA4_CGC
    ::driver_license_number         := (cAliasQry)->DA4_NUMCNH
    ::driver_address_street         := (cAliasQry)->DA4_END
    ::driver_address_number         := "0" //-- CBM - Numeração sendo enviada "0" pois não temos campos separados para numeração
    ::driver_address_complement     := ""
    ::driver_address_neighborhood   := (cAliasQry)->DA4_BAIRRO
    ::driver_address_zipcode        := (cAliasQry)->DA4_CEP
    ::driver_phone_areacode         := RTrim((cAliasQry)->DA4_DDD)
    ::driver_phone_number           := RTrim( StrTran( (cAliasQry)->DA4_TEL ,"-","" ) )
    ::driver_phone_preferential     := .T.

    If Len(RTrim( StrTran( (cAliasQry)->DA4_TEL ,"-","" ) )) >= 9 
        cTypeid:= "Cell"
    EndIf
    ::driver_phone_typeid           := cTypeid 
    
    If !Empty((cAliasQry)->DA4_DATNAS)
        ::driver_birthdate :=  SubStr(DtoS((cAliasQry)->DA4_DATNAS), 1, 4) + "-";
	            	         + SubStr(DtoS((cAliasQry)->DA4_DATNAS), 5, 2) + "-";
                             + SubStr(DtoS((cAliasQry)->DA4_DATNAS), 7, 2) + "T00:00:00"
    EndIf
    ::driver_name                   := (cAliasQry)->DA4_NOME
    ::driver_gender                 := "Uninformed" 
    
    lRet    := .T. 

    (cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->( dbCloseArea() )


RestArea(aArea)
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetHiredInfo()
Obtém informações do contratado
@author Caio Murakami
@since 21/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetHiredInfo( cCodFor, cLojFor ) CLASS TMSBCARepomFrete
Local aArea         := GetArea()
Local cQuery        := ""
Local cAliasQry     := GetNextAlias()
Local lRet          := .F. 
Local cTypeid       := "Fixed"

Default cCodFor     := ""
Default cLojFor     := ""

cQuery  := " SELECT SYA.YA_DESCR AS PAIS, * "
cQuery  += " FROM " + RetSQLName("SA2") + " SA2 "
cQuery  += " LEFT JOIN " + RetSQLName("SYA") + " SYA "
cQuery  += "    ON YA_FILIAL    = '" + xFilial("SYA") + "' "
cQuery  += "    AND YA_CODGI    = A2_PAIS "
cQuery  += "    AND SYA.D_E_L_E_T_ = '' "
cQuery  += " WHERE A2_FILIAL    = '" + xFilial("SA2") + "' "
cQuery  += " AND A2_COD         = '" + cCodFor  + "' "
cQuery  += " AND A2_LOJA        = '" + cLojFor  + "' "
cQuery  += " AND SA2.D_E_L_E_T_ = '' "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery ), cAliasQry, .F., .T. )

TcSetField(cAliasQry,"A2_DTNASC","D",8,0)

While (cAliasQry)->(!Eof())

    ::hired_codigo               := cCodFor
    ::hired_loja                 := cLojFor
    ::hired_country              := IIf( Upper(AllTrim((cAliasQry)->PAIS))=="BRASIL" .Or. Empty((cAliasQry)->PAIS) , "Brazil" , AllTrim( (cAliasQry)->PAIS ) ) //-- CBM 1.1 : Tratamento provisório para país
    ::hired_type                 := IIf( (cAliasQry)->A2_TIPO == "F","Person","Company" )         
    ::hired_national_id          := RTrim( (cAliasQry)->A2_CGC )
    ::hired_email                := RTrim( (cAliasQry)->A2_EMAIL )
    ::hired_phone_areacode       := RTrim( (cAliasQry)->A2_DDD )
    ::hired_phone_number         := RTrim( StrTran( (cAliasQry)->A2_TEL ,"-","" ) ) 
    ::hired_phone_preferential   := .T.

    If Len(RTrim( StrTran( (cAliasQry)->A2_TEL ,"-","" ) ))  >= 9 
        cTypeid:= "Cell"
    EndIf

    ::hired_phone_typeid         := cTypeid 
    ::hired_rntrc                := RTrim( (cAliasQry)->A2_RNTRC )
    ::hired_inss                 := RTrim( (cAliasQry)->A2_CODINSS )
    ::hired_rg                   := RTrim( (cAliasQry)->A2_PFISICA )
    ::hired_ie                   := RTrim( (cAliasQry)->A2_INSCR )
    ::hired_im                   := RTrim( (cAliasQry)->A2_INSCRM )
    ::hired_nomefantasia         := RTrim( (cAliasQry)->A2_NOME )
    ::hired_simplesnacional      := Iif( (cAliasQry)->A2_SIMPNAC == "1" , .T. , .F. )
    ::hired_address_street       := RTrim( (cAliasQry)->A2_END )
    ::hired_address_number       := "0"
    ::hired_address_complement   := RTrim( (cAliasQry)->A2_COMPLEM )
    ::hired_address_neighboorhod := RTrim( (cAliasQry)->A2_BAIRRO )
    ::hired_address_zipcode      := RTrim( (cAliasQry)->A2_CEP )
    ::hired_companyname          := RTrim( (cAliasQry)->A2_NOME )
    ::hired_name                 := RTrim( (cAliasQry)->A2_NOME )

    If !Empty((cAliasQry)->A2_DTNASC)
        ::hired_birthdate            := SubStr(DtoS((cAliasQry)->A2_DTNASC), 1, 4) + "-";
	    		                      + SubStr(DtoS((cAliasQry)->A2_DTNASC), 5, 2) + "-";
                                      + SubStr(DtoS((cAliasQry)->A2_DTNASC), 7, 2) + "T00:00:00"
    EndIf

    ::hired_gender               := "Uninformed" 
    ::hired_dependents           := 0
    ::hired_fuelvoucher_percent  := ""
    
    lRet    := .T. 

    (cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->( dbCloseArea() )


RestArea(aArea)
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetVehicleInfo()
Obtém informações do veículo
@author Caio Murakami
@since 22/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetVehicleInfo( cCodVei ) CLASS TMSBCARepomFrete
Local aArea         := GetArea()
Local cQuery        := ""
Local cAliasQry     := GetNextAlias()
Local lRet          := .F. 

Default cCodVei     := ""

cQuery  := " SELECT SYA.YA_DESCR AS PAIS, * "
cQuery  += " FROM " + RetSQLName("DA3") + " DA3 "
cQuery  += " LEFT JOIN " + RetSQLName("SA2") + " SA2 "
cQuery  += "    ON A2_FILIAL    = '" + xFilial("SA2") + "' "
cQuery  += "    AND A2_COD      = DA3_CODFOR "
cQuery  += "    AND A2_LOJA     = DA3_LOJFOR "
cQuery  += "    AND SA2.D_E_L_E_T_ = '' "
cQuery  += " LEFT JOIN " + RetSQLName("SYA") + " SYA "
cQuery  += "    ON YA_FILIAL    = '" + xFilial("SYA") + "' "
cQuery  += "    AND YA_CODGI    = A2_PAIS "
cQuery  += "    AND SYA.D_E_L_E_T_ = '' "
cQuery  += " LEFT JOIN " + RetSQLName("DUT") + " DUT "
cQuery  += "    ON DUT_FILIAL   = '" + xFilial("DUT") + "' "
cQuery  += "    AND DUT_TIPVEI  = DA3_TIPVEI "
cQuery  += "    AND DUT.D_E_L_E_T_ = '' "
cQuery  += " WHERE DA3_FILIAL   = '" + xFilial("DA3") + "' "
cQuery  += " AND DA3_COD        = '" + cCodVei + "' "
cQuery  += " AND DA3.D_E_L_E_T_ = '' "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery ), cAliasQry, .F., .T. )

While (cAliasQry)->(!Eof())
    ::vehicle_codigo         := cCodVei
    ::vehicle_country        := Iif( Upper(AllTrim((cAliasQry)->PAIS))=="BRASIL" .Or. Empty((cAliasQry)->PAIS) , "Brazil" , AllTrim( (cAliasQry)->PAIS ) ) //-- CBM 1.1 : Tratamento provisório pais
    ::vehicle_licenseplate   := (cAliasQry)->DA3_PLACA
    ::vehicle_classification := Iif( (cAliasQry)->DUT_CATVEI == "3" ,"Implement", "Traction") 
    ::vehicle_category       := ::RetCategory(cCodVei , (cAliasQry)->DUT_TIPROD , (cAliasQry)->DUT_TIPCAR )
    ::vehicle_axles          := "Axle" + StrZero( (cAliasQry)->DA3_QTDEIX , 2 )
    ::vehicle_type           := ::RetVehicleType( cCodVei , (cAliasQry)->DUT_TIPROD , (cAliasQry)->DUT_TIPCAR ) 
    ::vehicle_owner_country  := IIf( Upper(AllTrim((cAliasQry)->PAIS))=="BRASIL" .Or. Empty((cAliasQry)->PAIS) , "Brazil" , AllTrim( (cAliasQry)->PAIS ) ) //-- CBM 1.1 : Tratamento provisório pais
    ::vehicle_owner_id       := RTrim( (cAliasQry)->A2_CGC )
    ::vehicle_owner_rntrc    := RTrim( (cAliasQry)->A2_RNTRC )
    ::vehicle_owner_nomefantasia := RTrim( (cAliasQry)->A2_NOME )
    ::vehicle_owner_name        := RTrim( (cAliasQry)->A2_NREDUZ )
    ::vehicle_owner_type     := IIf( (cAliasQry)->A2_TIPO == "F","Person","Company" )  
    lRet    := .T. 

    (cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->( dbCloseArea() )


RestArea(aArea)
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} RetCategory()
Retorna categoria do veículo
@author Caio Murakami
@since 16/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD RetCategory(cCodVei , cTipRod , cTipCar) CLASS TMSBCARepomFrete
Local cCategory     := "HeavyCommercial"

Default cCodVei     := ""
Default cTipRod     := ""
Default cTipCar     := ""

If !Empty(cCodVei)
    If cTipRod == "04" //-- Van
        If cTipCar == "00" .Or. Empty(cTipCar)
            cCategory   := "CommercialLightweight"
        Else 
            cCategory   := "HeavyCommercial"
        EndIf
    Else 
         cCategory   := "HeavyCommercial"
    EndIf 
EndIf 

Return cCategory

//-----------------------------------------------------------------
/*/{Protheus.doc} RetVehicleType()
Retorna tipo do veículo
@author Caio Murakami
@since 16/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD RetVehicleType(cCodVei , cTipRod , cTipCar) CLASS TMSBCARepomFrete
Local cTipo     := ""

Default cCodVei     := ""
Default cTipRod     := ""
Default cTipCar     := ""

//--  ['CityDelivery', 'Toco', 'Truck', 'Utility', 'VAN', 'VUC']
If !Empty(cCodVei)
    If cTipRod == "01" .Or. cTipRod == "03"
        cTipo   := "Truck"
    ElseIf cTipRod == "02"
        cTipo   := "Toco"
    ElseIf cTipRod == "04"
        cTipo   := "VAN"
    ElseIf cTipRod == "05"
        cTipo   := "Utility"
    ElseIf cTipRod == "06"
        cTipo   := "CityDelivery"
    EndIf 
EndIf 

Return cTipo

//-----------------------------------------------------------------
/*/{Protheus.doc} GetRouteInfo()
Obtém informações da rota
@author Caio Murakami
@since 24/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetRouteInfo( cRota , cUfOri , cMunOri , cUFDes , cMunDes, lIdaeVolta, aNomesRodo , cObserv ) CLASS TMSBCARepomFrete
Local aArea         := GetArea()
Local aAreaDA8      := DA8->( GetArea() )
Local aAreaDUY      := DUY->( GetArea() )
Local cQuery        := ""
Local cAliasQry     := GetNextAlias()
Local lRet          := .F. 
Local nCount        := 0
Local cFilID        := ""

Default cRota       := ""
Default cUFOri      := ""
Default cMunOri     := ""
Default cUFDes      := ""
Default cMunDes     := ""
Default lIdaeVolta  := .F. 
Default aNomesRodo  := {} 
Default cObserv     := ""

If !Empty( cRota )

    DbSelectArea("DA8")
    DA8->( DbSetOrder(1) ) // DA8_FILIAL, DA8_COD

    DbSelectArea("DUY")
    DA8->( DbSetOrder(1) ) // DUY_FILIAL, DUY_GRPVEN

    If DA8->( DbSeek( xfilial("DA8") + cRota ) ) .AND. DUY->( DbSeek( xfilial("DUY") + DA8->DA8_CDRORI ) )
        cFilID := DUY->DUY_FILDES
    EndIf

    If Empty( cFilID )
        cFilID := cFilAnt
    EndIf
    ::route_BranchIdentifier     := RTrim( cFilID )

EndIf

cQuery  := " SELECT * "
cQuery  += " FROM " + RetSQLName("DA8") + " DA8 "
cQuery  += " INNER JOIN " + RetSQLName("DUY") + " DUY "
cQuery  += "    ON DUY_FILIAL      = '" + xFilial("DUY") + "' "
cQuery  += "    AND DUY_GRPVEN     = DA8_CDRORI "
cQuery  += "    AND DUY.D_E_L_E_T_ = '' "
cQuery  += " WHERE DA8_FILIAL   = '" + xFilial("DA8") + "' "
cQuery  += "    AND DA8_COD        = '" + cRota + "' "
cQuery  += "    AND DA8.D_E_L_E_T_ = '' "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery ), cAliasQry, .F., .T. )

While (cAliasQry)->(!Eof())
    
    cFilID := xFilial("DA8")

    If Empty( cFilID )
        cFilID := (cAliasQry)->DUY_FILDES
    EndIf

    ::route_BranchIdentifier     := RTrim( cFilID )
    ::route_OriginIBGECode       := TMS120CdUf((cAliasQry)->DUY_EST,"1") + (cAliasQry)->DUY_CODMUN
    ::route_DestinyIBGECode      := TMS120CdUf( cUFDes ,"1") + cMunDes
    ::route_RoundTrip            := lIdaeVolta
    ::route_Note                 := cObserv
    ::route_TraceIdentifier      := AllTrim( cRota )
    ::route_ShippingPaymentPlaceType     := "Branch"

    For nCount := 1 To Len(aNomesRodo)
        Aadd( ::route_PreferredWays , aNomesRodo[nCount] )
    Next nCount

    lRet    := .T. 
    (cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->( dbCloseArea() )

If !lRet
    ::route_OriginIBGECode       := TMS120CdUf( cUFOri ,"1") + cMunOri
    ::route_DestinyIBGECode      := TMS120CdUf( cUFDes ,"1") + cMunDes
    ::route_RoundTrip            := lIdaeVolta
    ::route_Note                 := cObserv
    ::route_TraceIdentifier      := AllTrim( cRota )
    ::route_ShippingPaymentPlaceType     := "Branch"

    For nCount := 1 To Len(aNomesRodo)
        Aadd( ::route_PreferredWays , aNomesRodo[nCount] )
    Next nCount
    lRet    := .T. 
EndIf 

RestArea(aArea)
RestArea(aAreaDA8)
RestArea(aAreaDUY)

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetShippingInfo()
Retorna informações da rota
@author Caio Murakami
@since 24/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetShippingInfo( cFilOri , cViagem ) CLASS TMSBCARepomFrete
Local lRet          := .T. 
Local aArea         := GetArea()
Local aAreaDA3      := DA3->(GetArea())
Local aAreaDTQ      := DTQ->(GetArea())
Local aAreaSM0    	:= SM0->(GetArea())
Local aAreaSA1    	:= SA1->(GetArea())
Local nCount        := 1 
Local oDadosViag    := Nil 
Local aVehicles     := {} 
Local aDocs         := {} 
Local aDriver       := {} 
Local cHiredID      := ""
Local cCodForn      := ""
Local cLojForn      := ""
Local cCodVei       := ""
Local cCondut       := ""
Local cPais         := "Brazil"
Local cDocType      := "CTE"
Local cDocTms       := ""
Local nEixoVeic     := 0
Local nEixoIda      := 0
Local nEixoVolta    := 0
Local cCodCli       := ""
Local cLojCli       := ""
Local cReceTipo     := ""
Local cSerTms       := Posicione("DTQ",2,xFilial("DTQ")+cFilOri + cViagem,"DTQ_SERTMS")
Local cFilDoc       := ""
Local cDoc          := ""
Local cSerie        := ""
Local nValFrete     := 0 
Local nPrvFre       := 0 
Local nAdiFre       := 0
Local aCEPeDist     := {} 
Local cCepOri       := Posicione("SM0", 1, cEmpAnt  + cFilAnt, "M0_CEPENT")
Local cCepDes       := Posicione("SM0", 1, cEmpAnt  + cFilAnt, "M0_CEPENT")
Local nDistKm       := 0 
Local cIbgeOri      := Posicione("SM0", 1, cEmpAnt  + cFilAnt, "M0_CODMUN")
Local cIbgeDes      := Posicione("SM0", 1, cEmpAnt  + cFilAnt, "M0_CODMUN")
Local cNatCarga     := "0001"
Local aRoteiro      := {} 
Local cRoute        := "0"
Local cTrace        := "0"
Local cIDOpe        := ""
Local lMainDriver   := .F. 
Local cCodRB1       := ""
Local cCodRB2       := ""
Local cCodRB3       := ""
Local lCalcPdg      := .T.   //Calcula Pedagio - Se o cliente pagar pedagio, não será pago pela REPOM
Local lPdgOneWay    := .F.
Local cCountryRec   := "Brazil"
Local cCGCReceive   := Posicione("SM0", 1, cEmpAnt  + cFilAnt , "M0_CGC")
Local cNameReceive  := AllTrim(Posicione("SM0", 1, cEmpAnt  + cFilAnt, "M0_NOME") )
Local cTypeReceive  := "Company"
Local nPos          := 0
Local cFilDct       := ""
Local cDoct         := ""
Local cSerDct       := ""
Local cImpCTC 	    := SuperGetMv("MV_IMPCTC",,"0")
Local nValIRRF      := 0
Local nValINSS      := 0 
Local nValSEST      := 0 
Local nValSENAT     := 0 

Default cFilOri     := ""
Default cViagem     := ""

oDadosViag	:= TMSBCADadosTMS():New(cFilOri,cViagem,3,.T.)
aVehicles   := oDadosViag:GetVehicles()
aDriver     := oDadosViag:GetDriver()
aDocs       := oDadosViag:GetDocs()

For nCount := 1 To Len(aDocs)

    cFilDoc     := ::GetInfoArr(aDocs[nCount],"DT6_FILDOC",1)
    cDoc        := ::GetInfoArr(aDocs[nCount],"DT6_DOC",1)
    cSerie      := ::GetInfoArr(aDocs[nCount],"DT6_SERIE",1)
    cDocTms     := ::GetInfoArr(aDocs[nCount],"DT6_DOCTMS",1)
    cCodCli     := ::GetInfoArr(aDocs[nCount],"CLIDES", 3)
    cLojCli     := ::GetInfoArr(aDocs[nCount],"LOJDES", 3)
    cPais       := ::GetInfoArr(aDocs[nCount],"DESPAISDES",3)
    cReceTipo   := Iif( Posicione("SA1",1,xFilial("SA1") + cCodCli + cLojCli , "A1_PESSOA") == "J","Company","Person") 
    cDocType    := ::RetDocType(cFilDoc,cDoc,cSerie,cDocTMS,cSerTms) 

    Aadd( ::shipp_documents , {} )
    Aadd( ::shipp_documents[Len(::shipp_documents)] , {  "BranchCode"   , RTrim(cFilDoc) , "BranchCode" } ) 
    Aadd( ::shipp_documents[Len(::shipp_documents)] , {  "DocumentType" , RTrim( cDocType ), "DocumentType" } )
    Aadd( ::shipp_documents[Len(::shipp_documents)] , {  "Series"       , RTrim( cSerie ) , "Series" } )
    Aadd( ::shipp_documents[Len(::shipp_documents)] , {  "Number"       , RTrim( cDoc ) , "Number" } )
    Aadd( ::shipp_documents[Len(::shipp_documents)] , {  "EletronicKey" , RTrim( ::GetInfoArr(aDocs[nCount],"DT6_CHVCTE",1) ) , "EletronicKey" } )
    Aadd( ::shipp_documents[Len(::shipp_documents)] , {  "Country"      , Iif(Upper(AllTrim(cPais))=="BRASIL","Brazil",AllTrim(cPais)), "Country" } )
    Aadd( ::shipp_documents[Len(::shipp_documents)] , {  "NationalID"   , RTrim( Posicione("SA1",1,xFilial("SA1") + cCodCli + cLojCli , "A1_CGC") ), "NationalID" } )
    Aadd( ::shipp_documents[Len(::shipp_documents)] , {  "Name"         , RTrim( ::GetInfoArr(aDocs[nCount],"DESNOME",3) ) , "Name" } )
    Aadd( ::shipp_documents[Len(::shipp_documents)] , {  "ReceiverType" , cReceTipo , "ReceiverType" } )
    Aadd( ::shipp_documents[Len(::shipp_documents)] , {  "DT6_PESO"     , ::GetInfoArr(aDocs[nCount],"PESO",3) , "PESO" } )
    Aadd( ::shipp_documents[Len(::shipp_documents)] , {  "DT6_VALTOT"   , ::GetInfoArr(aDocs[nCount],"VALTOT",3) , "VALTOT" } )

Next nCount 

For nCount := 1 To Len(aVehicles)
    cCodForn    := ::GetInfoArr(aVehicles[nCount],"DTR_CODFOR",1)
    cLojForn    := ::GetInfoArr(aVehicles[nCount],"DTR_LOJFOR",1) 
    cHiredID    := ::GetInfoArr(aVehicles[nCount],"A2_CGC",1) 
    cCodVei     := ::GetInfoArr(aVehicles[nCount],"DTR_CODVEI",1) 
    nEixoVeic   += ::GetInfoArr(aVehicles[nCount],"DA3_QTDEIX",1)
    nEixoIda    := ::GetInfoArr(aVehicles[nCount],"DTR_QTDEIX",1)
    nEixoVolta  := ::GetInfoArr(aVehicles[nCount],"DTR_QTEIXV",1) 
    nValFrete   += ::GetInfoArr(aVehicles[nCount],"DTR_VALFRE",3)
    nPrvFre     += ::GetInfoArr(aVehicles[nCount],"DTR_PRVFRE",3)
    nAdiFre     += ::GetInfoArr(aVehicles[nCount],"DTR_ADIFRE",3)
    cCodRB1     := ::GetInfoArr(aVehicles[nCount],"DTR_CODRB1",3)
    cCodRB2     := ::GetInfoArr(aVehicles[nCount],"DTR_CODRB2",3)
    cCodRB3     := ::GetInfoArr(aVehicles[nCount],"DTR_CODRB3",3)

    ::shipp_hiredcountry             := ::GetHiredCountry( cCodForn, cLojForn )
    ::shipp_HiredNationalId          := cHiredID
    
    Aadd( ::shipp_vehicles, {} )
    Aadd( ::shipp_vehicles[Len(::shipp_vehicles)], { "Country"      , ::shipp_hiredcountry , "Country" } )
    Aadd( ::shipp_vehicles[Len(::shipp_vehicles)], { "LicensePlate" , ::GetInfoArr(aVehicles[nCount],"DA3_PLACA",1) ,"LicensePlate"  } )

    //-- Tratamento reboques
    If !Empty(cCodRB1) 
        DA3->(dbSetOrder(1))
        If DA3->( MsSeek( xFilial("DA3") + cCodRB1 ))
            cPais   := ::GetHiredCountry( DA3->DA3_CODFOR , DA3->DA3_LOJFOR )
            Aadd( ::shipp_vehicles, {} )
            Aadd( ::shipp_vehicles[Len(::shipp_vehicles)], { "Country"      , cPais , "Country" } )
            Aadd( ::shipp_vehicles[Len(::shipp_vehicles)], { "LicensePlate" , RTrim(DA3->DA3_PLACA) ,"LicensePlate"  } )
            nEixoVeic   += DA3->DA3_QTDEIX
        EndIf 

        If !Empty(cCodRB2) 
            DA3->(dbSetOrder(1))
            If DA3->( MsSeek( xFilial("DA3") + cCodRB2 ))
                cPais   := ::GetHiredCountry( DA3->DA3_CODFOR , DA3->DA3_LOJFOR )
                Aadd( ::shipp_vehicles, {} )
                Aadd( ::shipp_vehicles[Len(::shipp_vehicles)], { "Country"      , cPais , "Country" } )
                Aadd( ::shipp_vehicles[Len(::shipp_vehicles)], { "LicensePlate" , RTrim(DA3->DA3_PLACA) ,"LicensePlate"  } )
                nEixoVeic   += DA3->DA3_QTDEIX
            EndIf 
        EndIf 
        
         If !Empty(cCodRB3) 
            DA3->(dbSetOrder(1))
            If DA3->( MsSeek( xFilial("DA3") + cCodRB3 ))
                cPais   := ::GetHiredCountry( DA3->DA3_CODFOR , DA3->DA3_LOJFOR )
                Aadd( ::shipp_vehicles, {} )
                Aadd( ::shipp_vehicles[Len(::shipp_vehicles)], { "Country"      , cPais , "Country" } )
                Aadd( ::shipp_vehicles[Len(::shipp_vehicles)], { "LicensePlate" , RTrim(DA3->DA3_PLACA) ,"LicensePlate"  } )
                nEixoVeic   += DA3->DA3_QTDEIX
            EndIf 
        EndIf 
    EndIf 
Next nCount 

If cImpCTC == "0"
    
    DTY->( dbSetOrder(2) )
    If DTY->(MsSeek( xFilial("DTY") + cFilOri + cViagem ))
        While DTY->( DTY_FILIAL + DTY_FILORI + DTY_VIAGEM ) ==  xFilial("DTY") + cFilOri + cViagem

            If DTY->DTY_TIPCTC == "1" .Or. DTY->DTY_TIPCTC == "2"
                nValIRRF    += DTY->DTY_IRRF
                nValINSS    += DTY->DTY_INSS
                nValSEST    += DTY->DTY_SEST
                nValSENAT   += 0
            EndIf 
            DTY->(dbSkip())
        EndDo
    EndIf 

    Aadd(::shipp_taxes,{})
    Aadd(::shipp_taxes[Len(::shipp_taxes)],{"Type" , 34 , "Type"})
    Aadd(::shipp_taxes[Len(::shipp_taxes)],{"Value", nValINSS , "Value"})
    Aadd(::shipp_taxes,{})
    Aadd(::shipp_taxes[Len(::shipp_taxes)],{"Type" , 1 , "Type"})
    Aadd(::shipp_taxes[Len(::shipp_taxes)],{"Value", nValIRRF , "Value"})
    Aadd(::shipp_taxes,{})
    Aadd(::shipp_taxes[Len(::shipp_taxes)],{"Type" , 2 , "Type"})
    Aadd(::shipp_taxes[Len(::shipp_taxes)],{"Value", nValSEST , "Value"})
    Aadd(::shipp_taxes,{})
    Aadd(::shipp_taxes[Len(::shipp_taxes)],{"Type" , 3 , "Type"})
    Aadd(::shipp_taxes[Len(::shipp_taxes)],{"Value", nValSENAT , "Value"})

EndIf 

For nCount := 1 To Len(aDriver)
    cCondut := ::GetInfoArr(aDriver[nCount],"DUP_CONDUT",1) 
    cPais   := ::GetInfoArr(aDriver[nCount],"CCH_PAIS",1) 
    
    If Empty(cPais) .Or. Upper( AllTrim( cPais) ) == "BRASIL"
        cPais   := "Brazil"
    EndIF 

    If cCondut == "1"
        lMainDriver := .T. 
        cIDOpe      := ::GetInfoArr(aDriver[nCount],"DUP_IDOPE",1) 
    EndIf 

    Aadd( ::shipp_drivers , {} )
    Aadd( ::shipp_drivers[Len(::shipp_drivers)] , { "Country"       , cPais , "Country" }  )
    Aadd( ::shipp_drivers[Len(::shipp_drivers)] , { "NationalID"    , RTrim( ::GetInfoArr(aDriver[nCount],"DA4_CGC",1) ) , "NationalID" }  )
    Aadd( ::shipp_drivers[Len(::shipp_drivers)] , { "Main"          , lMainDriver , "Main" }  )
Next nCount

aCEPeDist:= TMSCEOrDes( cFilOri , cViagem , cSerTMS )
If Len(aCEPeDist) > 0 
    cCepOri     := Iif( !Empty(aCEPeDist[1]) , RTrim( aCEPeDist[1] ) , cCepOri )
    cCepDes     := Iif( !Empty(aCEPeDist[2]) , RTrim( aCEPeDist[2] ) , cCepDes ) 
    nDistKm     := Iif(aCEPeDist[3]==0,1,aCEPeDist[3])
    If Len(aCEPeDist) > 3 
        cIbgeOri    := Iif( !Empty(aCEPeDist[4]) , RTrim( aCEPeDist[4] ) , cIbgeOri )
        cIbgeDes    := Iif( !Empty(aCEPeDist[5]) , RTrim( aCEPeDist[5] ) , cIbgeDes )
    EndIf

    //---- Dados do Ultimo Destino da Carga conforme MV_ULTDEST  //Orientaçao Repom
    If Len(aCEPeDist[6]) > 0
        If aCEPeDist[6][1][1] == 'DUD'  //Cliente
            cFilDct := Padr(aCEPeDist[6][1][2] ,Len(DT6->DT6_FILDOC))      
            cDoct   := Padr(aCEPeDist[6][1][3] ,Len(DT6->DT6_DOC))
            cSerDct := Padr(aCEPeDist[6][1][4] ,Len(DT6->DT6_SERIE))

            If Len(aDocs) > 0
                nPos:= aScan (aDocs, { |x| x[3][2]+x[4][2]+x[5][2] == cFilDct + cDoct + cSerDct }) 
                If nPos > 0
                    cCliDes := ::GetInfoArr(aDocs[nPos],"CLIDES", 3)
                    cLojDes := ::GetInfoArr(aDocs[nPos],"LOJDES", 3)

                    cCountryRec := ::GetInfoArr(aDocs[nPos],"DESPAISDES",3)
                    If Empty(cCountryRec) .Or. Upper( AllTrim( cCountryRec) ) == "BRASIL"
                        cCountryRec   := "Brazil"
                    EndIf
                    cCGCReceive := RTrim( Posicione("SA1",1,xFilial("SA1") + cCliDes + cLojDes , "A1_CGC") )
                    cNameReceive:= RTrim( ::GetInfoArr(aDocs[nPos],"DESNOME",3) ) 
                    cTypeReceive:= Iif( Posicione("SA1",1,xFilial("SA1") + cCliDes + cLojDes , "A1_PESSOA") == "J","Company","Person") 
                EndIf
            EndIf

        Else  //Filial
            cCountryRec := "Brazil"
            cCGCReceive := Posicione("SM0", 1, cEmpAnt  + aCEPeDist[6][1][2], "M0_CGC")     
            cNameReceive:= AllTrim(Posicione("SM0", 1, cEmpAnt  + aCEPeDist[6][1][2], "M0_NOME") )
            cTypeReceive:= "Company"    

            If Posicione("DTQ",2,xFilial("DTQ")+cFilOri+cViagem,"DTQ_SERTMS")  <> StrZero(2,Len(DTQ->DTQ_SERTMS)) 
                lPdgOneWay  := .T.   //Pedagio Ida e Volta , considera que o ultimo destino sera a Filial
            EndIf            
        EndIf  
    EndIf
    
EndIf

DTQ->(dbSetOrder(2))
If DTQ->( MsSeek( xFilial("DTQ") + cFilOri + cViagem ))
    cCepOri       := Iif( !Empty( DTQ->DTQ_CEPORI ) , RTrim(DTQ->DTQ_CEPORI) , cCepOri )
    cCepDes       := Iif( !Empty( DTQ->DTQ_CEPDES ) , RTrim(DTQ->DTQ_CEPDES) , cCepDes )
    cIbgeOri      := Iif( !Empty( DTQ->DTQ_CDMUNO ) , TMS120CdUf(DTQ->DTQ_UFORI,"1") + RTrim(DTQ->DTQ_CDMUNO) , cIbgeOri )
    cIbgeDes      := Iif( !Empty( DTQ->DTQ_CDMUND ) , TMS120CdUf(DTQ->DTQ_UFDES,"1") + RTrim(DTQ->DTQ_CDMUND) , cIbgeDes )

    If Posicione("DTR",1,xFilial("DTR")+cFilOri+cViagem,"DTR_TIPCRG") == "1"
        cNatCarga := TmsTpCrg(cFilOri, cViagem)
    EndIf 

    aRoteiro    := aClone( ::GetRoteiro( DTQ->DTQ_ROTA , cCodVei ) )
EndIf 

For nCount := 1 To Len(aRoteiro)
    cTrace  := ::GetInfoArr( aRoteiro[nCount] , "DEK_CODPER" , 1)
    cRoute  := ::GetInfoArr( aRoteiro[nCount] , "DEK_ROTEIR" , 1)
Next nCount 

lCalcPdg:= TMSA250PGR(cFilOri, cViagem, cCodVei,"01")  //Falso- Repom não Paga Pedagio 

::shipp_id                       := cFilOri + cViagem 
::shipp_country                  := ::GetHiredCountry( cCodForn, cLojForn ) //-- CBM 1.1 : Tratamento de País
::shipp_hiredcountry             := ::GetHiredCountry( cCodForn, cLojForn ) //-- CBM 1.1 : Tratamento de País
::shipp_HiredNationalId          := RTrim( Posicione("SA2",1,xFilial("SA2") + cCodForn + cLojForn , "A2_CGC") )
::shipp_OperationIdentifier      := TmsGetOp(cFilOri, cViagem, cCodVei, cCodForn, cLojForn)
//::shipp_OperationIdentifier      := "1" //-- CBM: Enviar 1 para homologação;2 = Produção, revisar para ver se o ideal não é implementar a TmsGetOp acima - será decidido em implantação
::shipp_CardNumber               := Val(cIDOpe)
::shipp_VPRCardNumber            := 0 
::shipp_BrazilianRouteTraceCode  := Val(cTrace)
::shipp_BrazilianRouteRouteCode  := Val(cRoute)
::shipp_IssueDate                := FWTimeStamp( 5 , dDataBase , Time() )
::shipp_TotalFreightValue        := Iif( nValFrete == 0 , nPrvFre , nValFrete ) 
::shipp_AdvanceMoneyValue        := nAdiFre
::shipp_vpr_issue                := lCalcPdg
::shipp_vpr_OneWay               := lPdgOneWay   
::shipp_vpr_SuspAxle             := nEixoVeic - nEixoIda
::shipp_vpr_ReturnSuspAxle       := nEixoVeic - nEixoVolta
::shipp_shipppay_date            := FWTimeStamp( 5 , dDataBase , Time() ) 
::shipp_shipppay_type            := "Branch"
::shipp_BranchCode               := RTrim(cFilOri)
::shipp_LoadBrazilianNCM         := RTrim( cNatCarga ) 
::shipp_LoadBrazilianANTTCodeType    := Val( RTrim( cNatCarga ) )
::shipp_br_ibgesource            := RTrim( cIbgeOri )
::shipp_br_ibgedest              := RTrim( cIbgeDes )
::shipp_br_cepsource             := RTrim( cCepOri )
::shipp_br_cepdest               := RTrim( cCepDes )
::shipp_TravelledDistance        := nDistKm

//--- Dados do ultimo destinatario conforme mv_ultdest
::shipp_receive_Country          := cCountryRec
::shipp_receive_NationalId       := cCGCReceive
::shipp_receive_Name             := cNameReceive
::shipp_receive_ReceiverType     := cTypeReceive  

RestArea(aAreaSM0)
RestArea(aAreaSA1)
RestArea(aAreaDA3)
RestArea(aAreaDTQ)
RestArea(aArea)
Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} GetError()
Obtém mensagem de erro
@author Caio Murakami
@since 16/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetError() CLASS TMSBCARepomFrete
Return ::last_error

//-----------------------------------------------------------------
/*/{Protheus.doc} GetInfoArr()
Obtém dados do array

@author Caio Murakami
@since 25/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetInfoArr( aAux  , cLabel , nPosSeek , nPosRet  ) CLASS TMSBCARepomFrete
Local xRet      := nil 
Local nCount    := 0 

Default aAux        := {}
Default cLabel      := ""
Default nPosSeek    := 1
Default nPosRet     := 2

For nCount := 1 To Len(aAux)
    If AllTrim( Upper(aAux[nCount][nPosSeek]) ) == AllTrim( Upper(cLabel) )
        xRet    := aAux[nCount][nPosRet]
        exit
    EndIf
Next nCount

Return xRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetHiredCountry()
Obtém país do contratado

@author Caio Murakami
@since 25/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetHiredCountry( cCodFor, cLojFor ) CLASS TMSBCARepomFrete
Local cPais     := "" 
Local cCodPais  := ""

Default cCodFor     := ""
Default cLojFor     := ""

cCodPais    := Posicione("SA2",1,xFilial("SA2") + cCodFor + cLojFor , "A2_PAIS")
cPais       := RTrim( Posicione("SYA",1,xFilial("SYA") + cCodPais , "YA_DESCR") )

cPais       := Iif( Empty(cPais) .Or. Upper(cPais) == "BRASIL" , "Brazil" , cPais ) //-- CBM 1.1 : Ajuste de Country, hoje é aceitado apenas Brazil ou 55

Return cPais 

//-----------------------------------------------------------------
/*/{Protheus.doc} RetDocType()
REtorna tipo do documento

@author Caio Murakami
@since 28/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD RetDocType(cFilDoc,cDoc,cSerie,cDocTMS,cSerTms) CLASS TMSBCARepomFrete
Local cType     := "CTE"
Local aAreaDT6  := DT6->(GetArea())

Default cFilDoc     := ""
Default cDoc        := ""
Default cSerie      := ""
Default cDocTMS     := ""
Default cSerTms     := ""

// -- ['CTE', 'NFe', 'NFSe', 'CRT', 'OCC', 'Romaneio', 'MDFe'],
If cSerTms == "1"
    cType    := "OCC"
ElseIf cDocTms $ "5/D/F/G" 
    cType    := "NFe"
ElseIf cDocTms $ "6/7" // Reentrega ou Devolução pesquisa pelo Original
    DT6->(dbSetOrder(1))
    If DT6->( dbSeek( xFilial("DT6") + cFilDoc + cDoc + cSerie ))
        cType   := ::RetDocType( DT6->DT6_FILDCO ,DT6->DT6_DOCDCO ,DT6->DT6_SERDCO ,DT6->DT6_DOCTMS ,DT6->DT6_SERTMS)
    EndIf 
Else
    cType    := "CTE"
EndIf 

RestArea( aAreaDT6 )
Return cType

//-----------------------------------------------------------------
/*/{Protheus.doc} GetRoteiro()
Obtém código do roteiro

@author Caio Murakami
@since 29/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetRoteiro( cRota , cCodVei ) CLASS TMSBCARepomFrete
Local aArea     := GetArea()
Local cFroVei   := ""
Local cRoteir   := ""
Local cPercur   := ""
Local aRet      := {} 

Default cCodVei := ""

//-- Verifica a amarracao Rota X Roteiro/Percurso
cFroVei := Posicione('DA3',1,xFilial('DA3') + cCodVei,'DA3_FROVEI')

SIX->(DbSetOrder(1))
If SIX->( MsSeek( 'DEK' + '3' ) )
    DEK->(DbSetOrder(3))
    If DEK->(MsSeek(xFilial('DEK')+DTQ->DTQ_ROTA+cFroVei+ ::deg_codope ) )
        cRoteir := AllTrim(DEK->DEK_ROTEIR)
        cPercur := AllTrim(DEK->DEK_CODPER)
    ElseIf DEK->( MsSeek(xFilial('DEK')+DTQ->DTQ_ROTA+'0'+ ::deg_codope) )
        cRoteir := AllTrim(DEK->DEK_ROTEIR)
        cPercur := AllTrim(DEK->DEK_CODPER)
    ElseIf DEK->( MsSeek(xFilial('DEK')+DTQ->DTQ_ROTA+' '+ ::deg_codope ) )
        cRoteir := AllTrim(DEK->DEK_ROTEIR)
        cPercur := AllTrim(DEK->DEK_CODPER)
    EndIf
Else
    DEK->(DbSetOrder(2))
    If DEK->( MsSeek(xFilial('DEK') + DTQ->DTQ_ROTA + ::deg_codope) )
        cRoteir := AllTrim(DEK->DEK_ROTEIR)
        cPercur := AllTrim(DEK->DEK_CODPER)
    EndIf
EndIf

Aadd( aRet , {} )
Aadd( aRet[Len(aRet)] , { "DEK_ROTEIR" , cRoteir , "DEK_ROTEIR" })
Aadd( aRet[Len(aRet)] , { "DEK_CODPER" , cPercur , "DEK_CODPER" })

RestArea(aArea)
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetIdShipping()
Obtém código da operação gerado na integração Shipping

@author Caio Murakami
@since 30/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetIdShipping( cFilOri, cViagem , cCodVei ) CLASS TMSBCARepomFrete
Local cRet      := "" 
Local aArea     := GetArea()
Local aAreaDTR  := DTR->(GetArea())

Default cFilOri := ""
Default cViagem := ""
Default cCodVei := ""

DTR->(dbSetOrder(3))
If DTR->( dbSeek( xFilial("DTR") + cFilOri + cViagem + RTrim(cCodVei) ))
    cRet    := RTrim( DTR->DTR_PRCTRA )
EndIf 

RestArea(aAreaDTR)
RestArea(aArea)
Return cRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} Destroy()
Destroi objeto

@author Caio Murakami
@since 01/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD Destroy() CLASS TMSBCARepomFrete
Local nCount    := 1 

For nCount := 1 To Len( ::shipp_drivers )
    //::shipp_drivers[nCount] := Nil
    FwFreeArray( ::shipp_drivers[nCount] )
Next nCount 

For nCount := 1 To Len( ::shipp_documents )
    //::shipp_documents[nCount] := Nil
    FwFreeArray( ::shipp_documents[nCount] )
Next nCount 

For nCount := 1 To Len( ::shipp_vehicles )
    //::shipp_vehicles[nCount] := Nil
    FwFreeArray( ::shipp_vehicles[nCount] )
Next nCount 

For nCount := 1 To Len( ::shipp_taxes )
    //::shipp_taxes[nCount] := Nil
    FwFreeArray( ::shipp_taxes[nCount] )
Next nCount 

FwFreeArray( ::route_PreferredWays )
FwFreeArray( ::shipp_drivers ) 
FwFreeArray( ::shipp_documents ) 
FwFreeArray( ::shipp_vehicles ) 
FwFreeArray( ::shipp_taxes ) 
FwFreeArray( ::payment_Documents )

Return 
//-----------------------------------------------------------------
/*/{Protheus.doc} GetDriverByName()
Obtém informações do motorista a partir do nome ou parte do nome

400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      Deve conter de 3 a 250 caracteres
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//-----------------------------------------------------------------

METHOD GetDrvrByName( cCodMot ) CLASS TMSBCARepomFrete

    Local cPath     := ::url_repom
    Local cPathPar  := "/Driver/ByName/"
    Local cToken    := ::access_token
    Local cVersion  := ::api_version
    Local cGet      := ""
    Local cQueryPar := ""
    Local aRet      := {}
    Local aArea     := DA4->(GetArea())

    Default cCodMot := ""

    DbSelectArea("DA4")
    DA4->( DbSetOrder(1) )

    If !Empty(cCodMot) .AND. DA4->( DbSeek( xFilial("DA4") + cCodMot ) )
        
        cQueryPar := AllTrim( DA4->DA4_NOME )

        cGet    := ::GetREPOM( cPath, cPathPar, cToken, cQueryPar, cVersion )

        aRet    := TMSGDriver( cGet )

    EndIf

    RestArea(aArea)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetDriverByDoc()
Obtém informações do motorista a partir do Documento CPF ou CNPJ
Deve conter de 3 a 250 caracteres
400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      cCodMot
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//-----------------------------------------------------------------

METHOD GetDrvrByDoc( cCodMot ) CLASS TMSBCARepomFrete

    Local cPath     := ::url_repom
    Local cToken    := ::access_token
    Local cVersion  := ::api_version
    Local cPathPar  := "/Driver/ByDocument/Brazil/"
    Local cGet      := ""
    Local cQueryPar := ""
    Local aRet      := {}
    Local aArea     := DA4->(GetArea())

    Default cCodMot    := ""
    
    DbSelectArea("DA4")
    DA4->( DbSetOrder(1) )

    If !Empty(cCodMot) .AND. DA4->( DbSeek( xFilial("DA4") + cCodMot ) )
        
        cQueryPar := AllTrim(  DA4->DA4_CGC )

        cGet    := ::GetREPOM( cPath, cPathPar, cToken, cQueryPar, cVersion )

        aRet    := TMSGDriver( cGet )

    EndIf

    RestArea(aArea)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetREPOM()
Realiza comunicação com a api da REPOM utilizando os parametros passados

400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      cPath       url repom 
@param      cPathPar    Parametro de Endereço 
@param      cToken      Senha
@param      cQueryPar   Parametro a ser buscado
@param      cVersion    Versão
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//--------------------------------------------------------------------

METHOD GetREPOM( cPath, cPathPar, cToken, cQueryPar, cVersion ) CLASS TMSBCARepomFrete

    Local cResult       := ""
    Local oClient       := NIL
    Local oJBody        := NIL
    Local aHeader       := {}

    Default cPath       := ""
    Default cPathPar    := ""
    Default cToken      := ""
    Default cQueryPar   := ""
    Default cVersion    := ""

    If !Empty(cPath) .AND. !Empty(cPathPar) .AND. !Empty(cToken) .AND. !Empty(cVersion)
        
        cQueryPar := EncodeUTF8( cQueryPar )
        oJBody  := JsonObject():New()

        // Definição do tipo de envio JSON ou URLEncode
        AAdd( aHeader, "Accept: application/json"               )
        AAdd( aHeader, "Authorization: " + "Bearer " + cToken   )
        AAdd( aHeader, "Content-Type: application/json"         )

        // Setting e Consumo da API
        oClient := FwRest():New( cPath )
        
        oClient:SetPath( cPathPar + cQueryPar + "?x-api-version=" + cVersion )

        If oClient:Get( aHeader, cQueryPar )
            cResult := oClient:GetResult()
        Else
            cResult := oClient:GetLastError()
        EndIf

        FreeObj(oJBody)
    EndIf

Return cResult

//-----------------------------------------------------------------
/*/{Protheus.doc} GetCardHired()
Obtém informações do fornecedor a partir do Documento CPF ou CNPJ
Deve conter de 3 a 250 caracteres
400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      cCodFor codigo do fornecedor
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//-----------------------------------------------------------------

METHOD GetCardHired( cCodFor, cLoja ) CLASS TMSBCARepomFrete

    Local aRet      := {}
    Local cPath     := ::url_repom
    Local cToken    := ::access_token
    Local cVersion  := ::api_version
    Local cPathPar  := "/Card/GetActiveCardsByHired/"
    Local cGet      := ""
    Local cQueryPar := ""
    Local aArea     := SA2->(GetArea())

    Default cCodFor := ""
    Default cLoja   := ""
    
    DbSelectArea("SA2")
    SA2->( DbSetOrder(1) )

    If !Empty(cCodFor) .AND. !Empty(cLoja) .AND. SA2->( DbSeek( xFilial("SA2") + cCodFor + cLoja ) )
        
        cQueryPar := AllTrim( SA2->A2_CGC )

        cGet    := ::GetREPOM( cPath, cPathPar, cToken, cQueryPar, cVersion )

        aRet    := TMSGCard( cGet )

    EndIf

    RestArea( aArea )

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetCardDriver()
Obtém informações do motorista a partir do Documento CPF ou CNPJ
Deve conter de 3 a 250 caracteres
400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      cCodFor codigo do fornecedor
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//-----------------------------------------------------------------

METHOD GetCardDriver( cCodMot ) CLASS TMSBCARepomFrete

    Local aRet      := {}
    Local cPath     := ::url_repom
    Local cToken    := ::access_token
    Local cVersion  := ::api_version
    Local cPathPar  := "/Card/GetActiveCardsByDriver/"
    Local cGet      := ""
    Local cQueryPar := ""
    Local aArea     := DA4->(GetArea())

    Default cCodFor := ""
    
    DbSelectArea("DA4")
    DA4->( DbSetOrder(1) )

    If !Empty(cCodMot) .AND. DA4->( DbSeek( xFilial("DA4") + cCodMot ) )
        
        cQueryPar := AllTrim( DA4->DA4_CGC)

        cGet    := ::GetREPOM( cPath, cPathPar, cToken, cQueryPar, cVersion )

        aRet    := TMSGCard( cGet )
    Else
        AAdd( aRet, { 404, "404	Not Found", STR0001            } ) // STR0003 "O Servidor não conseguiu encontrar o recurso solicitado."
    EndIf

    RestArea( aArea )

Return aRet
//-----------------------------------------------------------------
/*/{Protheus.doc} GetCardDvrHrd()
Essa consulta traz o cartao que esta vinculado tanto para o prestador 
quanto para o motorista
CPF ou CNPJ. Deve conter de 3 a 250 caracteres
400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      cCodFor codigo do fornecedor
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//-----------------------------------------------------------------

METHOD GetCardDvrHrd( cCodMot, cCodFor, cLoja ) CLASS TMSBCARepomFrete

    Local aRet      := {}
    Local cPath     := ::url_repom
    Local cToken    := ::access_token
    Local cVersion  := ::api_version
    Local cPathPar  := "/Card/GetActiveCardsByHiredAndByDriver/"
    Local cGet      := ""
    Local cQueryPar := ""
    Local cCGCMot   := ""
    Local cCGCFor   := ""
    Local aAreaDA4  := DA4->(GetArea())
    Local aAreaSA2  := SA2->(GetArea())

    Default cCodMot := ""
    Default cCodFor := ""
    Default cLoja   := ""

    DbSelectArea("DA4")
    DA4->( DbSetOrder(1) )
    If DA4->( DbSeek( xFilial("DA4") + cCodMot ) )
        cCGCMot := AllTrim( DA4->DA4_CGC )
    EndIf

    DbSelectArea("SA2")
    SA2->( DbSetOrder(1) )
    If SA2->( DbSeek( xFilial("SA2") + cCodFor + cLoja ) )
        cCGCFor := AllTrim( SA2->A2_CGC )
    EndIf

    If !Empty(cCGCMot) .AND. !Empty(cCGCFor)

        cQueryPar:= cCGCFor + "/" + cCGCMot

        cGet    := ::GetREPOM( cPath, cPathPar, cToken, cQueryPar, cVersion )

        aRet    := TMSGCard( cGet )

    EndIf

    RestArea( aAreaDA4 )
    RestArea( aAreaSA2 )

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetLoadTypes()
Essa consulta traz o cartao que esta vinculado tanto para o prestador 
quanto para o motorista
CPF ou CNPJ. Deve conter de 3 a 250 caracteres
400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      cCodFor codigo do fornecedor
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//-----------------------------------------------------------------

METHOD GetLoadTypes() CLASS TMSBCARepomFrete

    Local aRet      := {}
    Local cPath     := ::url_repom
    Local cToken    := ::access_token
    Local cVersion  := ::api_version
    Local cPathPar  := "/AnttTypes/LoadTypes"
    Local cGet      := ""
    Local cQueryPar := ""

    cGet    := ::GetREPOM( cPath, cPathPar, cToken, cQueryPar, cVersion )

    aRet    := TMSGLdTp( cGet )

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetVPR()
This method returns all toll plazas that are on the route by searching for its shipping identifier.

400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      cShippID código do shipping
@author     Caio Murakami
@since      06/10/2020
@version    1.0
/*/
//-----------------------------------------------------------------
METHOD GetVPR( cShippID ) CLASS TMSBCARepomFrete
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/VPR/TollList/ByShippingIdentifier/"
Local cGet      := ""
Local aArea     := GetArea()
Local cJson     := ""
Local oResult   := ""
Local oJson     := Nil 
Local aNames    := {}
Local nCount    := 1 

Default cShippID := ""

cPathPar    += cShippID

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )

If FwJsonDeserialize(cGet,@oResult)
    If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) .And. ;
        oResult:Response:StatusCode == 200 .And. AttIsMemberOf( oResult, "RESULT" )

        cJson   := FwJsonSerialize(oResult:Result,.F.,.T.)
        oJson   := JsonObject():New()
        oJson:FromJson(cJson)

        aNames  := oJson:GetNames()

        For nCount := 1 To Len(aNames)
            Aadd( aRet , { aNames[nCount] , oJson[aNames[nCount]]  })
        Next nCount

    EndIf 
EndIf 

RestArea( aArea )
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetHiredByName()
Essa consulta traz o cartao que esta vinculado tanto para o prestador 
quanto para o motorista
CPF ou CNPJ. Deve conter de 3 a 250 caracteres
400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      cCodFor codigo do fornecedor
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//-----------------------------------------------------------------

METHOD GetHrdByName( cCodFor, cLoja ) CLASS TMSBCARepomFrete

    Local aRet      := {}
    Local cPath     := ::url_repom
    Local cToken    := ::access_token
    Local cVersion  := ::api_version
    Local cPathPar  := "/Hired/ByName/"
    Local cGet      := ""
    Local cQueryPar := ""
    Local aArea     := SA2->(GetArea())

    Default cCodFor := ""
    Default cLoja   := ""

    DbSelectArea("SA2")
    SA2->( DbSetOrder(1) )
    If !Empty(cCodFor) .AND. !Empty(cLoja) .AND. SA2->( DbSeek( xFilial("SA2") + cCodFor + cLoja ) )

        cQueryPar := AllTrim( SA2->A2_NOME )
        cGet    := ::GetREPOM( cPath, cPathPar, cToken, cQueryPar, cVersion )
        aRet    := TMSGHBNm( cGet )

    EndIf

    RestArea( aArea )
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetHiredByName()
Essa consulta traz o cartao que esta vinculado tanto para o prestador 
quanto para o motorista
CPF ou CNPJ. Deve conter de 3 a 250 caracteres
400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      cCodFor codigo do fornecedor
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//-----------------------------------------------------------------

METHOD GetHrdByDoc( cCodFor, cLoja ) CLASS TMSBCARepomFrete

    Local aRet      := {}
    Local cPath     := ::url_repom
    Local cToken    := ::access_token
    Local cVersion  := ::api_version
    Local cPathPar  := "/Hired/ByDocument/Brazil/"
    Local cGet      := ""
    Local cQueryPar := ""
    Local aArea     := SA2->(GetArea())

    Default cCodFor := ""
    Default cLoja   := ""

    DbSelectArea("SA2")
    SA2->( DbSetOrder(1) )

    If !Empty(cCodFor) .AND. !Empty(cLoja) .AND. SA2->( DbSeek( xFilial("SA2") + cCodFor + cLoja ) )

        cQueryPar := AllTrim( SA2->A2_CGC )
        cGet    := ::GetREPOM( cPath, cPathPar, cToken, cQueryPar, cVersion )
        aRet    := TMSGHBNm( cGet )

    EndIf

    RestArea( aArea )

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetRtByCEP()
Essa consulta traz o cartao que esta vinculado tanto para o prestador 
quanto para o motorista
CPF ou CNPJ. Deve conter de 3 a 250 caracteres
400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      cCodFor codigo do fornecedor
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//-----------------------------------------------------------------

METHOD GetRtByCEP( cCEPOri, cCEPDes, cEixos ) CLASS TMSBCARepomFrete

    Local aRet      := {}
    Local cPath     := ::url_repom
    Local cToken    := ::access_token
    Local cVersion  := ::api_version
    Local cPathPar  := "/Route/ByCEP/"
    Local cGet      := ""
    Local cQueryPar := ""

    Default cCEPOri := ""
    Default cCEPDes := ""
    Default cEixos  := ""

    If !Empty(cCEPOri) .AND. !Empty(cCEPDes) .AND. !Empty(cEixos)

        cQueryPar := cCEPOri
        cQueryPar += "/"
        cQueryPar += cCEPDes
        cQueryPar += "/"
        cQueryPar += cEixos

        cGet    := ::GetREPOM( cPath, cPathPar, cToken, cQueryPar, cVersion )

        aRet    := TMSGRota( cGet )

    EndIf

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetRtByIBGE()
Essa consulta traz o cartao que esta vinculado tanto para o prestador 
quanto para o motorista
CPF ou CNPJ. Deve conter de 3 a 250 caracteres
400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      cCodFor codigo do fornecedor
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//-----------------------------------------------------------------

METHOD GetRtByIBGE( cUFOri, cUFDes, cMunOri, cMunDes, cEixos ) CLASS TMSBCARepomFrete

    Local aRet      := {}
    Local cPath     := ::url_repom
    Local cToken    := ::access_token
    Local cVersion  := ::api_version
    Local cPathPar  := "/Route/ByIBGE/"
    Local cGet      := ""
    Local cQueryPar := ""

    Default cUFOri  := ""
    Default cUFDes  := ""
    Default cMunOri := ""
    Default cMunDes := ""
    Default cEixos  := ""

    If !Empty(cUFOri) .AND. !Empty(cUFDes) .AND. !Empty(cMunOri) .AND. !Empty(cMunDes) .AND. !Empty(cEixos)

        cQueryPar := TMS120CdUf( cUFOri, "1") + cMunOri
        cQueryPar += "/"
        cQueryPar += TMS120CdUf( cUFDes, "1") + cMunDes
        cQueryPar += "/"
        cQueryPar += cEixos

        cGet    := ::GetREPOM( cPath, cPathPar, cToken, cQueryPar, cVersion )

        aRet    := TMSGRota( cGet )

    EndIf

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetRtByTrcId()
Essa consulta traz o cartao que esta vinculado tanto para o prestador 
quanto para o motorista
CPF ou CNPJ. Deve conter de 3 a 250 caracteres
400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      cCodFor codigo do fornecedor
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//-----------------------------------------------------------------

METHOD GetRtByTrcId( cCodRota, cEixos ) CLASS TMSBCARepomFrete

    Local aRet      := {}
    Local cPath     := ::url_repom
    Local cToken    := ::access_token
    Local cVersion  := ::api_version
    Local cPathPar  := "/Route/ByTraceIdentifier/"
    Local cGet      := ""
    Local cQueryPar := ""
    Local aArea     := DA8->(GetArea())

    Default cCodRota:= ""
    Default cEixos  := ""

    DbSelectArea("DA8")
    DA8->( DbSetOrder(1) )

    If !Empty(cCodRota) .AND. !Empty(cEixos) .AND. DA8->( DbSeek( xFilial("DA8") + cCodRota ) )

        cQueryPar := AllTrim( DA8->DA8_COD )
        cQueryPar += "/"
        cQueryPar += cValToChar( cEixos )

        cGet    := ::GetREPOM( cPath, cPathPar, cToken, cQueryPar, cVersion )

        aRet    := TMSGRota( cGet )

    EndIf

    RestArea( aArea )

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetRtRequest()
Essa consulta traz o cartao que esta vinculado tanto para o prestador 
quanto para o motorista
CPF ou CNPJ. Deve conter de 3 a 250 caracteres
400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      cCodFor codigo do fornecedor
@author     Rodrigo A. Pirolo
@since      28/09/2020
@version    1.0
/*/
//-----------------------------------------------------------------

METHOD GetRtRequest( cCodRota ) CLASS TMSBCARepomFrete

    Local aRet      := {}
    Local cPath     := ::url_repom
    Local cToken    := ::access_token
    Local cVersion  := ::api_version
    Local cPathPar  := "/RouteRequest/"
    Local cGet      := ""
    Local cQueryPar := ""
    Local aArea     := DA8->(GetArea())

    Default cCodRota := ""

    DbSelectArea("DA8")
    DA8->( DbSetOrder(1) )

    If !Empty(cCodRota) .AND. DA8->( DbSeek( xFilial("DA8") + cCodRota ) )

        cQueryPar := AllTrim( DA8->DA8_COD )

        cGet    := ::GetREPOM( cPath, cPathPar, cToken, cQueryPar, cVersion )

        aRet    := TMSGRoReq( cGet )

    EndIf

    RestArea( aArea )

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetFuelbyCard()
GET /ShippingFuelBenefit/GetLinkByCardNumber/{cardNumber}
Consultar Vinculo por Cartão
400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      cCardNumber codigo do cartão
@author     Caio Murakami
@since      09/10/2020
@version    1.0
/*/
//-----------------------------------------------------------------
METHOD GetFuelbyCard( cCardNumber ) CLASS TMSBCARepomFrete
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/ShippingFuelBenefit/GetLinkByCardNumber/"
Local cGet      := ""
Local aArea     := GetArea()
Local cJson     := ""
Local oResult   := ""
Local oJson     := Nil 
Local aNames    := {}
Local nCount    := 1 

Default cCardNumber     := ""

cPathPar    += cCardNumber

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )

If FwJsonDeserialize(cGet,@oResult)
    If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) .And. ;
        oResult:Response:StatusCode == 200 .And. AttIsMemberOf( oResult, "RESULT" )

        cJson   := FwJsonSerialize(oResult:Result,.F.,.T.)
        oJson   := JsonObject():New()
        oJson:FromJson(cJson)

        aNames  := oJson:GetNames()

        For nCount := 1 To Len(aNames)
            Aadd( aRet , { aNames[nCount] , oJson[aNames[nCount]]  })
        Next nCount

    EndIf 
EndIf 

RestArea( aArea )
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetShipVeicVld()
GET /ShippingValidation/ByVehicles/{vehicles}
Vehicles Validate for new Shipping
400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      cCodVei codigo do veículo
@author     Caio Murakami
@since      09/10/2020
@version    1.0
/*/
//-----------------------------------------------------------------
METHOD GetShipVeicVld( cCodVei ) CLASS TMSBCARepomFrete
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/ShippingValidation/ByVehicles/"
Local cGet      := ""
Local aArea     := GetArea()
Local cJson     := ""
Local oResult   := ""
Local oJson     := Nil 
Local aNames    := {}
Local nCount    := 1 

Default cCodVei     := ""

cPathPar    += RTrim( Posicione("DA3",1,xFilial("DA3") + cCodVei , "DA3_PLACA" ) )

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )

If FwJsonDeserialize(cGet,@oResult)
    If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) .And. ;
        oResult:Response:StatusCode == 200 .And. AttIsMemberOf( oResult, "RESULT" )

        cJson   := FwJsonSerialize(oResult:Result,.F.,.T.)
        oJson   := JsonObject():New()
        oJson:FromJson(cJson)

        aNames  := oJson:GetNames()

        For nCount := 1 To Len(aNames)
            Aadd( aRet , { aNames[nCount] , oJson[aNames[nCount]]  })
        Next nCount

    EndIf 
EndIf 

RestArea( aArea )
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetShipHiredVld()
GET /ShippingValidation/ByHiredDocument/{country}/{document}
This method validates the CPF/CNPJ and the RNTRC of the hired.
400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      cCodForn, cLojForn
@author     Caio Murakami
@since      09/10/2020
@version    1.0
/*/
//-----------------------------------------------------------------
METHOD GetShipHiredVld( cCodForn, cLojForn ) CLASS TMSBCARepomFrete
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/ShippingValidation/ByHiredDocument/"
Local cGet      := ""
Local aArea     := GetArea()
Local cJson     := ""
Local oResult   := ""
Local oJson     := Nil 
Local aNames    := {}
Local nCount    := 1 
Local cCountry  := ""

Default cCodForn    := ""
Default cLojForn    := "" 

cCountry    := ::GetHiredCountry( cCodForn, cLojForn )
cPathPar    += cCountry + "/" + RTrim( Posicione("SA2",1,xFilial("SA2") + cCodForn + cLojForn , "A2_CGC") )

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )

If FwJsonDeserialize(cGet,@oResult)
    If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) 
        If oResult:Response:StatusCode == 200 .And. AttIsMemberOf( oResult, "RESULT" )

            cJson   := FwJsonSerialize(oResult:Result,.F.,.T.)
            oJson   := JsonObject():New()
            oJson:FromJson(cJson)

            aNames  := oJson:GetNames()

            For nCount := 1 To Len(aNames)
                Aadd( aRet , { aNames[nCount] , oJson[aNames[nCount]]  })
            Next nCount
        ElseIf oResult:Response:StatusCode == 406 .And. AttIsMemberOf( oResult, "RESULT" )
            cJson   := FwJsonSerialize(oResult:Result,.F.,.T.)
            oJson   := JsonObject():New()
            oJson:FromJson(cJson)

            aNames  := oJson:GetNames()

            For nCount := 1 To Len(aNames)
                Aadd( aRet , { aNames[nCount] , oJson[aNames[nCount]]  })
            Next nCount
        EndIf 
    EndIf 
EndIf 

RestArea( aArea )
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetPayAutShip()
GET /PaymentAuthorization/ByShippingId/{shippingId}
this method returns a payment authorization from searching for its shippingid.

400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Server Error

@param      cCodForn, cLojForn
@author     Caio Murakami
@since      09/10/2020
@version    1.0
/*/
//-----------------------------------------------------------------
METHOD GetPayAutShip( cFilOri , cViagem , cCodVei ) CLASS TMSBCARepomFrete
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/PaymentAuthorization/ByShippingId/"
Local cGet      := ""
Local aArea     := GetArea()
Local cJson     := ""
Local oResult   := ""
Local oJson     := Nil 
Local aNames    := {}
Local nCount    := 1 
Local cShippID  := ""

Default cFilOri     := ""
Default cViagem     := "" 
Default cCodVei     := ""

cShippID    := ::GetIdShipping( cFilOri , cViagem , cCodVei )

cPathPar    += cShippID

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )

If FwJsonDeserialize(cGet,@oResult)
    If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) .And. ;
        oResult:Response:StatusCode == 200 .And. AttIsMemberOf( oResult, "RESULT" )

        cJson   := FwJsonSerialize(oResult:Result,.F.,.T.)
        oJson   := JsonObject():New()
        oJson:FromJson(cJson)

        aNames  := oJson:GetNames()

        For nCount := 1 To Len(aNames)
            Aadd( aRet , { aNames[nCount] , oJson[aNames[nCount]]  })
        Next nCount

    EndIf 
EndIf 

RestArea( aArea )
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} ShippingInter()
This method interrupsts a shipping that had consumption or used toll 
credits(Vale Pedágio Repom).

@author Katia
@since 28/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD ShippingInter( cFilOri, cViagem ) CLASS TMSBCARepomFrete
Local lRet      := .T. 
Local aHeader   := {} 
Local cEndPoint := "/Shipping/Interruption"
Local xResult   := Nil 
Local cHeader   := ""
Local oResult   := ""
Local nCount    := 0 
Local aErrors   := {} 
Local cShippID  := ""

Default cFilOri     := ""
Default cViagem     := ""

cShippID    := ::GetIdShipping( cFilOri , cViagem  )
                                    
Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeader, "Content-Type: application/json" )

TmsRepTrac("TMSBCARepomFrete - ShippingInterruption")
TmsRepTrac( ::url_repom+cEndPoint+"/"+cShippID )

xResult := HTTPQuote( ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version ,;
            "PATCH",,,120,aClone(aHeader),@cHeader)

lRet    := .F. 
If xResult <> Nil 
    If FwJsonDeserialize(xResult,@oResult)
        If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) .And. ;
            oResult:Response:StatusCode == 200  
            lRet    := .T.
        ElseIf oResult:Response:StatusCode == 404
            ::last_error    := AllTrim(oResult:Response:Message)
        ElseIf ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "ERRORS" )  
            lRet    := .F. 
            aErrors := oResult:Errors
            For nCount := 1 To Len(aErrors)
                ::last_error    := cValToChar(oResult:Response:StatusCode) + chr(10) + chr(13)
                ::last_error    += cValToChar(aErrors[nCount]:ErrorCode) + " - " + aErrors[nCount]:Message + chr(10) + chr(13)
                Aadd( ::message_error , { AllTrim( cValToChar(oResult:Response:StatusCode)  ) , "04", ""})
                Aadd( ::message_error , { AllTrim( cValToChar(aErrors[nCount]:ErrorCode) + " - " + DecodeUtf8(aErrors[nCount]:Message)  ) , "04", ""})
            Next nCount 
        EndIf 
    Else 
        ::last_error    := "Error FwJsonDeserialize " + chr(10) + chr(13)
        ::last_error    += ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version
        ::last_error    += xResult
            Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
    Endif 
Else 
    ::last_error    := "Error HTTPQuote - PATCH " + chr(10) + chr(13)
    ::last_error    += ::url_repom+cEndPoint+"/"+cShippID+"?x-api-version="+::api_version
    
    Aadd( ::message_error , { AllTrim( ::last_error ) , "04", ""})
EndIf 

If !lRet
    ::last_error    := DecodeUtf8( AllTrim(::last_error) )
    
    If ::exibe_erro
        TmsMsgErr( ::message_error , "TMS X REPOM" )
        FwFreeArray(::message_error )
        ::message_error     := {}             
    EndIf
    TmsRepTrac( ::last_error )
EndIf

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} GetShipStPrcBy() 
GET /Shipping/StatusProcessing/ByIdentifier/{identifier}
This method returns the shipping processing status from searching for 
its operation key.

@author Katia
@since 30/10/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetShipStPrcBy( cFilOri , cViagem  ) CLASS TMSBCARepomFrete
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/Shipping/StatusProcessing/ByIdentifier/"
Local cGet      := ""
Local aArea     := GetArea()
Local cJson     := ""
Local oResult   := ""
Local oJson     := Nil 
Local aNames    := {}
Local nCount    := 1 

Default cFilOri     := ""
Default cViagem     := ""

cPathPar    += Escape(cFilOri + cViagem )

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )

If FwJsonDeserialize(cGet,@oResult)
    If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) .And. ;
        oResult:Response:StatusCode == 200 .And. AttIsMemberOf( oResult, "RESULT" )

        cJson   := FwJsonSerialize(oResult:Result,.F.,.T.)
        oJson   := JsonObject():New()
        oJson:FromJson(cJson)

        aNames  := oJson:GetNames()

        For nCount := 1 To Len(aNames)
            Aadd( aRet , { aNames[nCount] ,  oJson[aNames[nCount]]   })
        Next nCount

    EndIf 
EndIf 

RestArea( aArea )
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetOperation()
GET /Operation
This method returns the registered operations

@param      
@author     Caio Murakami
@since      16/11/2020
@version    1.0
/*/
//-----------------------------------------------------------------
METHOD GetOperation() CLASS TMSBCARepomFrete
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/Operation/"
Local cGet      := ""
Local aArea     := GetArea()
Local cJson     := ""
Local oResult   := ""
Local oJson     := Nil 
Local aNames    := {}
Local nCount    := 1 
Local nAux      := 1 

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )

If FwJsonDeserialize(cGet,@oResult)
    If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) .And. ;
        oResult:Response:StatusCode == 200 .And. AttIsMemberOf( oResult, "RESULT" )

        If ValType( oResult:Result ) == "A"
            For nAux := 1 To Len(  oResult:Result )
                aNames  := {}
                cJson   := FwJsonSerialize(oResult:Result[nAux],.F.,.T.)
                oJson   := JsonObject():New()
                oJson:FromJson(cJson)

                aNames  := oJson:GetNames()
                Aadd( aRet , {} )
                For nCount := 1 To Len(aNames)                    
                    Aadd( aRet[Len(aRet)] , { aNames[nCount] ,  oJson[aNames[nCount]]   })
                Next nCount

                FwFreeArray(aNames)
                FwFreeObj(oJson)

            Next nAux 
        Else 
            cJson   := FwJsonSerialize(oResult:Result,.F.,.T.)
            oJson   := JsonObject():New()
            oJson:FromJson(cJson)

            aNames  := oJson:GetNames()
            Aadd( aRet , {} )
            For nCount := 1 To Len(aNames)
                Aadd( aRet[Len(aRet)] , { aNames[nCount] ,  oJson[aNames[nCount]]   })
            Next nCount
        EndIf 
    EndIf 
EndIf 

RestArea( aArea )
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetOperById()
GET /Operation/ByIdentifier
This method returns the operation from searching for an Identifier.

@param      cOper
@author     Caio Murakami
@since      16/11/2020
@version    1.0
/*/
//-----------------------------------------------------------------
METHOD GetOperById( cOper ) CLASS TMSBCARepomFrete
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/Operation/ByIdentifier"
Local cGet      := ""
Local aArea     := GetArea()
Local cJson     := ""
Local oResult   := ""
Local oJson     := Nil 
Local aNames    := {}
Local nCount    := 1 

Default cOper   := ""

cPathPar    += "/"+cOper

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )

If FwJsonDeserialize(cGet,@oResult)
    If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) .And. ;
        oResult:Response:StatusCode == 200 .And. AttIsMemberOf( oResult, "RESULT" )

        cJson   := FwJsonSerialize(oResult:Result,.F.,.T.)
        oJson   := JsonObject():New()
        oJson:FromJson(cJson)

        aNames  := oJson:GetNames()

        For nCount := 1 To Len(aNames)
            Aadd( aRet , { aNames[nCount] ,  oJson[aNames[nCount]]   })
        Next nCount

    EndIf 
EndIf 

RestArea( aArea )
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetMovement()
GET /Movement/GetMovement
Retrieves customer movements

@param      
@author     Caio Murakami
@since      09/12/2020
@version    1.0
/*/
//-----------------------------------------------------------------
METHOD GetMovement() CLASS TMSBCARepomFrete
Local aRet      := {}
Local cPath     := ::url_repom
Local cToken    := ::access_token
Local cVersion  := ::api_version
Local cPathPar  := "/Movement/GetMovement"
Local cGet      := ""
Local aArea     := GetArea()
Local cJson     := ""
Local oResult   := ""
Local oJson     := Nil 
Local aNames    := {}
Local nCount    := 1 
Local nAux      := 1 

cGet        := ::GetREPOM( cPath, cPathPar, cToken, "", cVersion )

If FwJsonDeserialize(cGet,@oResult)
    If ValType(oResult) == "O" .And. AttIsMemberOf( oResult, "RESPONSE" ) .And. AttIsMemberOf( oResult:Response, "STATUSCODE" ) .And. ;
        oResult:Response:StatusCode == 200 .And. AttIsMemberOf( oResult, "RESULT" )

        If ValType( oResult:Result ) == "A"
            For nAux := 1 To Len(  oResult:Result )
                aNames  := {}
                cJson   := FwJsonSerialize(oResult:Result[nAux],.F.,.T.)
                oJson   := JsonObject():New()
                oJson:FromJson(cJson)

                aNames  := oJson:GetNames()
                Aadd( aRet , {} )
                For nCount := 1 To Len(aNames)                    
                    Aadd( aRet[Len(aRet)] , { aNames[nCount] ,  oJson[aNames[nCount]]   })
                Next nCount

                FwFreeArray(aNames)
                FwFreeObj(oJson)

            Next nAux 
        Else 
            cJson   := FwJsonSerialize(oResult:Result,.F.,.T.)
            oJson   := JsonObject():New()
            oJson:FromJson(cJson)

            aNames  := oJson:GetNames()
            Aadd( aRet , {} )
            For nCount := 1 To Len(aNames)
                Aadd( aRet[Len(aRet)] , { aNames[nCount] ,  oJson[aNames[nCount]]   })
            Next nCount
        EndIf 
    EndIf 
EndIf 

RestArea( aArea )
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} ExibeErro() 
Indica se deve exibir o erro

@author Caio Murakami
@since 06/11/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD ExibeErro( lExibe ) CLASS TMSBCARepomFrete

Default lExibe  := .T. 

::exibe_erro    := lExibe

Return 

//-----------------------------------------------------------------
/*/{Protheus.doc} GetByRtCode()
This method returns a search route for the Trace Code, Route Code 
and Vehicle Axes.  (Utilizado para retorno do Valor do Pedagio)
@param      cRoteiro, cPercurso
@author     Katia
@since      23/109/2020
@version    1.0
/*/
//-----------------------------------------------------------------
METHOD GetByRtCode( cPercurso, cRoteiro, nEixos ) CLASS TMSBCARepomFrete

    Local aRet      := {}
    Local cPath     := ::url_repom
    Local cToken    := ::access_token
    Local cVersion  := ::api_version
    Local cPathPar  := "/Route/ByRouteCode/"
    Local cGet      := ""
    Local cQueryPar := ""

    Default cPercurso:= ""
    Default cRoteiro := ""
    Default nEixos   := 2

    If !Empty(cPercurso) .AND. !Empty(cRoteiro) .AND. !Empty(nEixos)

        cPathPar += cPercurso
        cPathPar += "/"
        cPathPar += cRoteiro
        cPathPar += "/"
        cPathPar += cValToChar(nEixos)
        cGet    := ::GetREPOM( cPath, cPathPar, cToken, cQueryPar , cVersion )
        aRet    := TMSGRota( cGet )

    EndIf

Return aRet
