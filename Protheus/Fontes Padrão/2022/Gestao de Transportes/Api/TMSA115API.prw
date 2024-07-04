#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

//dummy function
    Function GroupOfRegions(); Return

/*/{Protheus.doc} GroupOfRegions
Implementa API de Grupos de Região.

Verbos disponíveis: POST, GET, PUT, DELETE
@author Izac Silvério Ciszevski
/*/

WSRESTFUL GroupOfRegions DESCRIPTION 'Grupo de Região' FORMAT 'application/json,text/html'
    WSDATA Fields     AS STRING  OPTIONAL
	WSDATA Order      AS STRING  OPTIONAL
	WSDATA Page       AS INTEGER OPTIONAL
	WSDATA PageSize   AS INTEGER OPTIONAL
    WSDATA InternalId AS STRING  OPTIONAL
    WSDATA Code       AS STRING  OPTIONAL

    WSMETHOD POST   v1 DESCRIPTION 'Cadastra um novo grupo de região';
    PATH '/v1/region';
    PRODUCES APPLICATION_JSON

    WSMETHOD GET    all_v1 DESCRIPTION 'Carrega os grupos de região';
    PATH '/v1/region/';
    PRODUCES APPLICATION_JSON

    WSMETHOD GET    v1 DESCRIPTION 'Carrega um grupo de região específica';
    PATH '/v1/region/{InternalId}';
    PRODUCES APPLICATION_JSON

    WSMETHOD PUT    v1 DESCRIPTION 'Altera um grupo de região específica' ;
    PATH '/v1/region/{InternalId}';
    PRODUCES APPLICATION_JSON

    WSMETHOD DELETE v1 DESCRIPTION 'Deleta um grupo de região específica' ;
    PATH '/v1/region/{InternalId}';
    PRODUCES APPLICATION_JSON

ENDWSRESTFUL

WSMETHOD POST  v1 WSSERVICE GroupOfRegions
    Local oAdapter := TMSGroupOfRegionstAdapter():New(Self)

    Return oAdapter:Post()

WSMETHOD GET    all_v1 QUERYPARAM Page, PageSize, Order, Fields WSSERVICE GroupOfRegions
    Local oAdapter := TMSGroupOfRegionstAdapter():New(Self)

    Return oAdapter:Get()

WSMETHOD GET    v1 PATHPARAM InternalId QUERYPARAM Fields WSSERVICE GroupOfRegions
    Local oAdapter := TMSGroupOfRegionstAdapter():New(Self)
    Local cCode   := ""
    Local cFilCod := ""

    SetArgument(::InternalId, @cFilCod, @cCode)

    oAdapter:AddFilter('branchId', cFilCod)
    oAdapter:AddFilter('code', cCode )

    Return oAdapter:Get()

WSMETHOD PUT    v1 PATHPARAM InternalId WSSERVICE GroupOfRegions
    Local oAdapter := TMSGroupOfRegionstAdapter():New( Self )
    Local cCode   := ""
    Local cFilCod := ""

    SetArgument(::InternalId, @cFilCod, @cCode)

    oAdapter:AddFilter('branchId', cFilCod)
    oAdapter:AddFilter('code', cCode )

    Return oAdapter:Put()

WSMETHOD DELETE v1 PATHPARAM InternalId WSSERVICE GroupOfRegions
    Local oAdapter := TMSGroupOfRegionstAdapter():New(Self)
    Local cCode   := ""
    Local cFilCod := ""

    SetArgument(::InternalId, @cFilCod, @cCode)

    oAdapter:AddFilter('branchId', cFilCod)
    oAdapter:AddFilter('code', cCode )

    Return oAdapter:Delete()

Static Function SetArgument(cArgument, cFilCod, cCode)

    If Empty( XFilial( "DUY" ) )
        cFilCod := XFilial( "DUY" )
        cCode   := cArgument
    Else
        cFilCod := SubStr(cArgument, 1, Len( XFilial( "DUY" ) ) )
        cCode   := SubStr(cArgument, 1 + Len( XFilial( "DUY" ) ) )
    EndIf

Return