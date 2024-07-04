#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

//dummy function
    Function CustomerShippingAddress(); Return

/*/{Protheus.doc} CustomerShippingAddress
Implementa API de Endereço de Solicitante.

Verbos disponíveis: POST, GET, PUT, DELETE
@author Izac Silvério Ciszevski
/*/

WSRESTFUL CustomerShippingAddress DESCRIPTION 'Endereço de Solicitante' FORMAT 'application/json,text/html'
    WSDATA Fields     AS STRING  OPTIONAL
	WSDATA Order      AS STRING  OPTIONAL
	WSDATA Page       AS INTEGER OPTIONAL
	WSDATA PageSize   AS INTEGER OPTIONAL
    WSDATA InternalId AS STRING  OPTIONAL
    WSDATA Code       AS STRING  OPTIONAL

    WSMETHOD POST   v1 DESCRIPTION 'Cadastra um novo Endereço de Solicitante';
    PATH 'api/tms/v1/CustomerShippingAddress';
    PRODUCES APPLICATION_JSON

    WSMETHOD GET    all_v1 DESCRIPTION 'Carrega os Endereços de Solicitante';
    PATH 'api/tms/v1/CustomerShippingAddress/';
    PRODUCES APPLICATION_JSON

    WSMETHOD GET    v1 DESCRIPTION 'Carrega um Endereço de Solicitante específico';
    PATH 'api/tms/v1/CustomerShippingAddress/{InternalId}';
    PRODUCES APPLICATION_JSON

    WSMETHOD PUT    v1 DESCRIPTION 'Altera um Endereço de Solicitante específico' ;
    PATH 'api/tms/v1/CustomerShippingAddress/{InternalId}';
    PRODUCES APPLICATION_JSON

    WSMETHOD DELETE v1 DESCRIPTION 'Deleta um Endereço de Solicitante específico' ;
    PATH 'api/tms/v1/CustomerShippingAddress/{InternalId}';
    PRODUCES APPLICATION_JSON

ENDWSRESTFUL

WSMETHOD POST  v1 WSSERVICE CustomerShippingAddress
    Local oAdapter := TMSCustomerShippingAddressAdapter():New(Self)

    Return oAdapter:Post()

WSMETHOD GET    all_v1 QUERYPARAM Page, PageSize, Order, Fields WSSERVICE CustomerShippingAddress
    Local oAdapter := TMSCustomerShippingAddressAdapter():New(Self)

    Return oAdapter:Get()

WSMETHOD GET    v1 PATHPARAM InternalId QUERYPARAM Fields WSSERVICE CustomerShippingAddress
    Local oAdapter := TMSCustomerShippingAddressAdapter():New(Self)
    Local cCode    := ""
    Local cFilCod  := ""

    SetArgument(::InternalId, @cFilCod, @cCode)

    oAdapter:AddFilter('branchId', cFilCod)
    oAdapter:AddFilter('code', cCode )

    Return oAdapter:Get()

WSMETHOD PUT    v1 PATHPARAM InternalId WSSERVICE CustomerShippingAddress
    Local oAdapter := TMSCustomerShippingAddressAdapter():New( Self )
    Local cCode    := ""
    Local cFilCod  := ""

    SetArgument(::InternalId, @cFilCod, @cCode)

    oAdapter:AddFilter('branchId', cFilCod)
    oAdapter:AddFilter('code', cCode )

    Return oAdapter:Put()

WSMETHOD DELETE v1 PATHPARAM InternalId WSSERVICE CustomerShippingAddress
    Local oAdapter := TMSCustomerShippingAddressAdapter():New(Self)
    Local cCode    := ""
    Local cFilCod  := ""

    SetArgument(::InternalId, @cFilCod, @cCode)

    oAdapter:AddFilter('branchId', cFilCod)
    oAdapter:AddFilter('code', cCode )

    Return oAdapter:Delete()

Static Function SetArgument(cArgument, cFilCod, cCode)

    If Empty( XFilial( "DUL" ) )
        cFilCod := XFilial( "DUL" )
        cCode   := cArgument
    Else
        cFilCod := SubStr(cArgument, 1, Len( XFilial( "DUL" ) ) )
        cCode   := SubStr(cArgument, 1 + Len( XFilial( "DUL" ) ) )
    EndIf

Return