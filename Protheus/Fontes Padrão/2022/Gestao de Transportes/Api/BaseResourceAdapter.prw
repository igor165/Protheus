#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BaseResourceAdapter
Super Classe para criação de resource Adapters

@author Izac Silvério Ciszevski
/*/

CLASS BaseResourceAdapter FROM LongNameClass

    DATA oResponse     As OBJECT
    DATA oRequest      As OBJECT
    DATA aFieldMap     As ARRAY
    DATA aSendDef      As OBJECT
    DATA aReceiveDef   As OBJECT
    DATA oError        As OBJECT
    DATA lOK           As LOGICAL
    DATA lBatch        As LOGICAL
    DATA aReturnFields As ARRAY
    DATA oRestObj      As OBJECT
    DATA cAlias        As OBJECT
    DATA cMainAlias    As OBJECT
    DATA nRecno        As NUMERIC

    METHOD New()
    METHOD FieldMap()
    METHOD SendObject()
    METHOD ReceiveObject()
    METHOD TransFormData()

    METHOD Get()
    METHOD GetAction()
    METHOD Put()
    METHOD PutAction()
    METHOD Post()
    METHOD PostAction()
    METHOD Delete()
    METHOD DeleteAction()

    METHOD SetMainAlias()
    METHOD CreateQuery()
    METHOD ExecuteQuery()
    METHOD AddFilter()
    METHOD RetFilter()
    METHOD RetOrder()
    METHOD IsValidField()

    METHOD SetQueryString()
    METHOD SetReturnFields()
    METHOD GetFieldName()
    METHOD GetFieldValue()

    METHOD RestResponse()
    METHOD Response()
    METHOD ErrorResponse()
    METHOD SetError()

EndClass

/**
 * Construtor da classe
 */
Method New( oRestObj ) CLASS BaseResourceAdapter

    ::oRestObj      := oRestObj
    ::oError        := JsonObject():New()
    ::oResponse     := FwEaiObj():New()
    ::oRequest      := FwEaiObj():New()
    ::aFieldMap     := ::FieldMap()
    ::aSendDef      := ::SendObject( ::aFieldMap )
    ::aReceiveDef   := ::ReceiveObject( ::aFieldMap )
    ::aReturnFields := {}

    ::oResponse:Activate()
    ::oRequest:Activate()
    ::SetQueryString( oRestObj:aQueryString )
    ::lBatch      := .T.
    ::lOK         := .T.
    ::cMainAlias  := ""

    Return Self

/**
 * Define o mapeamento dos campos do sistema com as propriedades do objeto
 * do recurso
 */
Method FieldMap() CLASS BaseResourceAdapter

    Local  aFieldMap := { { "campo", "" } }

    ::SetError( "FieldMap não definido." )

    Return aFieldMap

/**
 * Define o tratamento para o Objeto recebido.
 */
Method ReceiveObject( aFieldMap ) CLASS BaseResourceAdapter

    Local aReceiveDef := {}

    Default aFieldMap := ::aFieldMap

    AEval( aFieldMap, { | field | If( !Empty( field[ 2 ] ), AAdd( aReceiveDef, { field[ 2 ] } ), Nil ) } )

    Return aReceiveDef

/**
 * Define o tratamento para o Objeto enviado.
 */
Method SendObject( aFieldMap ) CLASS BaseResourceAdapter

    Local aProperties := {}
    Local aSendDef    := {}
    Local cProperty   := ""
    Local oObject     := JsonObject():New()
    Local nProperty   := 1
    Local nX, nY

    Default aFieldMap := ::aFieldMap

    For nX := 1 To Len( aFieldMap )
        cProperty := aFieldMap[ nX ][ nProperty ]
        xValue := oObject

        If At( ".", cProperty ) > 0
            aProperties := StrTokArr( cProperty, "." )
            For nY := 1 To Len( aProperties )
                cProperty := aProperties[ nY ]
                If xValue[ cProperty ] == Nil
                    xValue[ cProperty ] := JsonObject():New()
                EndIf
                xValue := xValue[ cProperty ]
            Next
            xValue := Nil
        Else
            xValue[ cProperty ] := Nil
        EndIf
    Next

    aSendDef := ReturnDef( oObject )

    Return aSendDef

/**
 * Retorna a definição do objeto recebido.
 */
Static Function ReturnDef( oObject )

    Local aProperties := oObject:GetProperties()
    Local nX
    Local aDefinition := {}
    Local cProperty   := ""

    For nX := 1 To Len( aProperties )
        cProperty := aProperties[ nX ]
        If oObject[ cProperty ] == Nil .Or. Empty( oObject[ cProperty ]:GetProperties() )
            AAdd( aDefinition, { cProperty } )
        Else
            AAdd( aDefinition, { cProperty, ReturnDef( oObject[ cProperty ] ) } )
        EndIf
    Next

    Return aDefinition

/**
 * Recebe os parâmetros recebidos po QueryString
 */
Method SetQueryString( aQueryString ) CLASS BaseResourceAdapter

    Local nString     := 0
    Local nLen        := Len( aQueryString )
    Local oJsonfilter := JsonObject():New()
    Local cQuery     := ""
    Local xValue

    Default cQuery := {}

    For nString := 1 To nLen
        cQuery := AllTrim(Upper( aQueryString[ nString ][ 1 ] ))
        xValue := aQueryString[ nString ][ 2 ]

        Do Case
            Case cQuery == "PAGE"
                ::oRequest:SetPage( xValue )

            Case cQuery == "PAGESIZE"
                ::oRequest:SetPageSize( xValue )

            Case cQuery == "ORDER"
                ::oRequest:SetOrder( xValue )

            Case cQuery == "FIELDS"
                ::SetReturnFields( xValue )

            OtherWise
                oJsonfilter[ cQuery ] := xValue

        EndCase
    Next

    ::oRequest:setFilter( oJsonfilter )

    Return Nil

/**
 * Define os campos de retorno do objeto
 */
Method SetReturnFields( cFields ) CLASS BaseResourceAdapter

    Local aFields := StrTokArr( cFields, "," )
    Local nX

    For nX := 1 To Len( aFields )
        cField := Upper( AllTrim( aFields[ nX ] ) )
        AAdd( ::aReturnFields, cField )

    Next

    Return

/**
 * Transforma os dados recebidos no corpo da requisição, traduzindo conforme o ReceiveDef
 */
Method TransFormData( aFieldMap, aReceiveDef ) CLASS BaseResourceAdapter

    Local aData     := {}
    Local bDefBlock := { | oObject, xValue | xValue }
    Local bSearch   := { | field | cField == field[ nValue ] }
    Local cField    := ""
    Local nProperty := 1
    Local nValue    := 2
    Local nX, nY
    Local oBody     := JsonObject():New()

    Default aFieldMap   := ::aFieldMap
    Default aReceiveDef := ::aReceiveDef

    oBody:fromJson( DecodeUTF8( ::oRestObj:GetContent() ) )

    For nX := 1 To Len( aReceiveDef )

        cField := aReceiveDef[ nX ][ nProperty ]

        If ( nPos := AScan( aFieldMap, bSearch ) ) == 0 .And. Len( aReceiveDef[ nX ] ) == 1
            Loop
        Else

        EndIf

        If Len( aReceiveDef[ nX ] ) == 1
            AAdd( aReceiveDef[ nX ], bDefBlock )
        EndIf

        If nPos > 0
            cProperty := aFieldMap[ nPos ][ nProperty ]
        Else
            cProperty := cField
        EndIf

        xValue := Eval( aReceiveDef[ nX ][ nValue ], oBody, GetPropVal( cProperty, oBody ) )

        If xValue != Nil
            AAdd( aData, { cField, xValue } )
        EndIf

    Next

    Return aData

/**
 * Método base para o verbo GET
 */
Method Get() CLASS BaseResourceAdapter

    ::oRequest:SetRestMethod( "GET" )
    ::lOK := ::GetAction()
    ::RestResponse()

    Return ::lOK

/**
 * Método base para o verbo PUT
 */
Method Put() CLASS BaseResourceAdapter

    ::oRequest:SetRestMethod( "PUT" )

    ::ExecuteQuery()
    ::lOK := ::lOK .And. ::PutAction( ::nRecno, ::TransFormData() )
    ::lOK := ::lOK .And. ::GetAction()
    ::RestResponse()

    Return ::lOK

/**
 * Método base para o verbo POST
 */
Method Post() CLASS BaseResourceAdapter

    ::oRequest:SetRestMethod( "POST" )

    ::lOK := ::lOK .And. ::PostAction( ::TransFormData() )
    ::lOK := ::lOK .And. ::GetAction()
    ::RestResponse()

    Return ::lOK

/**
 * Método base para o verbo DELETE
 */
Method Delete() CLASS BaseResourceAdapter

    ::oRequest:SetRestMethod( "DELETE" )

    ::ExecuteQuery()
    ::lOK := ::lOK .And. ::DeleteAction( ::nRecno )
    ::RestResponse()

    Return ::lOK

/**
 * Define a resposta do Objeto REST confome estado do Resource
 */
Method RestResponse() CLASS BaseResourceAdapter

    If ::lOk
        ::oRestObj:SetResponse( ::Response() )
    Else
        ::oRestObj:SetResponse( ::ErrorResponse() )
    EndIf

    //-- A requisição deve retornar .T. mesmo que haja erro.
    ::lOk := .T.

    Return

/**
 * Ação do verbo PUT
 */
Method PutAction() CLASS BaseResourceAdapter

    ::SetError( "Método PUT não Implementado." , 405 )

    Return .F.

/**
 * Ação do verbo POST
 */
Method PostAction() CLASS BaseResourceAdapter

    ::SetError( "Método POST não Implementado." , 405 )

    Return .F.

/**
 * Ação do verbo DELETE
 */
Method DeleteAction() CLASS BaseResourceAdapter

    ::SetError( "Método DELETE não Implementado." , 405 )

    Return .F.

/**
 * Define o Alias principal do Resource
 */
Method SetMainAlias( cAlias ) CLASS BaseResourceAdapter

    ::cMainAlias := cAlias
    Return

/**
 * Executa a Query definida
 */
Method ExecuteQuery() CLASS BaseResourceAdapter

    Local cQuery := ::CreateQuery( ::FieldMap(), ::RetFilter(), ::RetOrder() )
    Local cAlias := ""

    If ::lOk
        cAlias := MpSysOpenQuery( cQuery )

        If ( cAlias )->( EOF() )
            ::SetError( "O servidor não localizou o recurso solicitado." , 404 )
        ElseIf ( cAlias )->( FieldPos( "nRecno" ) ) > 0
            ::nRecno := ( cAlias )->nRecno
        EndIf
    EndIf

    Return cAlias

/**
 * Retorna o filtro conforme parâmetros informados na requisição
 */
Method RetFilter() CLASS BaseResourceAdapter

    Local nX
    Local cField := ""
    Local cWhere := ""
    Local oJsonFilter := ::oRequest:getFilter()
    Local aFilter

    If oJsonFilter != Nil
        aFilter := oJsonFilter:getProperties()
        For nX := 1 To Len( aFilter )
            cField := aFilter[ nX ]

            If ::IsValidField( aFilter[ nX ] )

                cWhere += "AND "
                If ValType( oJsonFilter[ aFilter[nX ] ] ) != "C"
                    oJsonFilter[ aFilter[nX ] ] := Str( oJsonFilter[ aFilter[ nX ] ] )
                EndIf
                cWhere += ::GetFieldName( aFilter[ nX ] ) + "=  '" + oJsonFilter[ aFilter[ nX ] ] + "'"
            Else
                ::SetError( "A propriedade '" + aFilter[ nX ] + "' não é valida para filtrar!" )
                Exit
            EndIf
        Next nX
    EndIf

    cWhere := SubStr( cWhere, 4 ) //-- Remove o primeiro  AND

    If Empty(cWhere)
        cWhere += "1=1 "
    EndIf

    Return cWhere

/**
 * Retorna a ordems conforme parâmetros informados na requisição
 */
Method RetOrder() CLASS BaseResourceAdapter

    Local nX
    Local cOrder     := ""
    Local aOrder     := {}
    Local cDirection := ""

    aOrder := ::oRequest:getOrder()

    For nX := 1 To Len( aOrder )

        cDirection := ""

        If SubStr( aOrder[ nX ], 1, 1 ) == "-"
            cDirection := " desc"
            aOrder[ nX ] := SubStr( aOrder[ nX ], 2 ) //-- Remove o sinal de menos
        EndIf

        cField := AllTrim( aOrder[ nX ] )

        If !::IsValidField( cField )
            ::SetError( "A propriedade " + cField + " não é valida para ordenação!" )
            Exit
		EndIf

        cOrder += ", " + ::GetFieldName( cField ) + cDirection

	Next

    cOrder := SubStr( cOrder, 2 ) //-- Remove a primeira vírgula

    If Empty( cOrder )
		cOrder := "1"
	EndIf

    Return cOrder

/**
 * Define a query do resource, recebendo os campos, filtros e ordens informados na requisição.
 */
Method CreateQuery( aFields, cWhere, cOrder ) CLASS BaseResourceAdapter

    Local cQuery  := ""
    Local cFields := ""
    Local cAlias  := ::cMainAlias
    Local nX

    // For nX := 1 To len( aFields )
    //     cFields += aFields[ nX ][ 2 ]
    //     cFields += ", "
    // Next nX

    cFields += cAlias+".R_E_C_N_O_ nRecno"

    cQuery += " SELECT " + cFields
    cQuery += " FROM " + RetSqlName( cAlias ) + " " + cAlias
    cQuery += " WHERE " + cWhere
    cQuery += "     AND " + cAlias + ".D_E_L_E_T_ = ' '"
    cQuery += " ORDER BY " + cOrder

    Return cQuery

Method Response() CLASS BaseResourceAdapter

    Local cResponse := EncodeUtf8( ::oResponse:getJson( , .T. ) )

    //--Paleativo, enquanto o frame não ajusta a classe.
    cResponse := StrTran( cResponse, '"Header":{},' )
    cResponse := StrTran( cResponse, ',"Header":{}' )
    cResponse := StrTran( cResponse, '"Header":{}' )
    cResponse := StrTran( cResponse, '"items":{},' )
    cResponse := StrTran( cResponse, ',"items":{}' )
    cResponse := StrTran( cResponse, '"items":{}' )
    cResponse := StrTran( cResponse, '"Content":{},' )
    cResponse := StrTran( cResponse, ',"Content":{}' )
    cResponse := StrTran( cResponse, '"Content":{}' )
    cResponse := StrTran( cResponse, '"Header":null,' )
    cResponse := StrTran( cResponse, ',"Header":null' )
    cResponse := StrTran( cResponse, '"Header":null' )
    cResponse := StrTran( cResponse, '"items":null,' )
    cResponse := StrTran( cResponse, ',"items":null' )
    cResponse := StrTran( cResponse, '"items":null' )
    cResponse := StrTran( cResponse, '"Content":null,' )
    cResponse := StrTran( cResponse, ',"Content":null' )
    cResponse := StrTran( cResponse, '"Content":null' )

    Return cResponse

Method SetError( cError, nErrorCode, cDetails, cHelpURL, aDetails ) CLASS BaseResourceAdapter

    Default cError     := ""
    Default nErrorCode := 400
    Default cDetails   := ""
    Default cHelpURL   := ""
    Default aDetails   := {}

    ::lOk        := .F.
    ::oError["code"]            := nErrorCode
    ::oError["message"]         := cError
    ::oError["detailedMessage"] := cDetails
    ::oError["helpUrl"]         := cHelpURL
    ::oError["details"]         := aDetails

    Return

Method ErrorResponse() CLASS BaseResourceAdapter

    Local cResponse := EncodeUtf8( ::oError:toJson() )

    Return cResponse

Method AddFilter( cProperty, xValue ) CLASS BaseResourceAdapter

    oJsonFilter  := ::oRequest:getFilter()
    oJsonFilter[ cProperty ] := xValue
    ::oRequest:setFilter( oJsonfilter )
    ::lBatch := .F.

    Return

Method IsValidField( cField ) Class BaseResourceAdapter

    Local nPos
    Local bSearch := { | field | Upper( AllTrim( field[ 1 ] ) ) == Upper( AllTrim( cField ) ) }

    nPos := AScan( ::aFieldMap, bSearch )

    Return nPos > 0

Method GetFieldName( cField ) Class BaseResourceAdapter
    Local bSearch := { | field | Upper( AllTrim( field[ 1 ] ) ) == Upper( AllTrim( cField ) ) }

    Return ::aFieldMap[AScan( ::aFieldMap, bSearch )][ 2 ]

Method GetAction() CLASS BaseResourceAdapter

    Local nCount    := 0
    Local cAlias    := ::ExecuteQuery()
    Local nPage     := ::oRequest:GetPage()
    Local nPageSize := ::oRequest:GetPageSize()
    Local lEmpty    := .F.

    If ::lOk

        If ::lBatch
            ::oResponse:setBatch( 1 )
        EndIf

        If nPage != 1
            ( cAlias )->( DbSkip( nPageSize * ( nPage - 1 ) ) )
        EndIf

        While nCount < nPageSize .And. !( cAlias )->( EOF() ) .And. ::lOk

            nCount++
            (::cMainAlias)->( DbGoTo( ( cAlias )->nRecno ) )

            oObject := RetObject( ::aSendDef, ::aFieldMap, ::cMainAlias )
            oObject := FilterFields( oObject, ::aReturnFields )

            lEmpty := Empty( oObject:GetProperties() )

            If !lEmpty
                ::oResponse:LoadJson( oObject:toJson() )
            Else
                nCount --
            EndIf

            ( cAlias )->( DbSkip() )

            If !lEmpty .And. nCount < nPageSize .And. !( cAlias )->( EOF() )
                ::oResponse:NextItem()
            EndIf

        Enddo

        If !( cAlias )->( EOF() ) .And. ::lOk
            ::oResponse:setHasNext( .T. )
        EndIf

    EndIf

    If !Empty(cAlias) .And. Select( cAlias ) > 0
        ( cAlias )->( DbCloseArea() )
    EndIf

    Return ::lOk

Static Function RetObject( aDefinition, aFieldMap, cAlias, cRoot )

    Local xValue
    Local cField   := ""
    Local cDbField := ""
    Local oObject  := JsonObject():New()
    Local bBloco   := { | cAlias, Value | Value }
    Local nX, nY

    Default cRoot := ""

    For nX := 1 To Len( aDefinition )
        cField := aDefinition[ nX ][ 1 ]

        If Len( aDefinition[ nX ] ) == 1
            AAdd( aDefinition[ nX ], bBloco )
        EndIf

        If ValType( aDefinition[ nX ][ 2 ] ) == "B"
            xValue := Eval( aDefinition[ nX ][ 2 ], cAlias, GetFieldValue( cAlias, aFieldMap, cRoot + cField ) )
        Else
            xValue := aDefinition[ nX ][ 2 ]
        EndIf

        If !Empty( xValue ) .Or. ValType(xValue) == "L"
            If ValType( xValue ) == "A" .And. ValType( xValue[ 1 ] ) == "A" .And. ValType( xValue[ 1 ][ 1 ] ) == "A" //-- Array de Objetos
                oObject[ cField ] := {}
                For nY:= 1 To Len( xValue )
                    AAdd( oObject[ cField ], RetObject( xValue[ nY ], aFieldMap, cAlias, cRoot + cField + "." ) )
                Next
            ElseIf ValType( xValue ) == "A" .And. ValType( xValue[ 1 ] ) == "A" .And. ValType( xValue[ 1 ][ 1 ] ) == "C" //-- Objeto
                xValue := RetObject( xValue, aFieldMap, cAlias, cRoot + cField + "." )
                If Len(xValue:GetProperties() ) > 0
                    oObject[ cField ] := xValue

                EndIf
            Else
                oObject[ cField ] := xValue
            EndIfww
        EndIf

    Next

    Return oObject

Static Function FilterFields( oItem, aFilter )

    Local oFilteredItem := JsonObject():New()
    Local cProperty     := ""
    Local nX

    If Empty( aFilter )
        Return oItem
    EndIf

    For nX := 1 To Len( aFilter )
        oTempItem := oItem
        cProperty := aFilter[ nX ]

        oTempItem := GetPropVal( @cProperty, oTempItem )

        If oTempItem != Nil
            oFilteredItem[ cProperty ] := oTempItem
        EndIf
    Next

    Return oFilteredItem

Static Function GetPropVal( cProperty, oObject )

    Local xValue := Nil
    Local aProperties := oObject:GetProperties()
    Local bSearch := { | property | Upper( AllTrim( property ) ) == Upper( AllTrim( cProperty ) ) }
    Local nY

    If At( ".", cProperty ) > 0
        aProperty := StrTokArr( cProperty, "." )
        xValue := oObject
        For nY:= 1 To Len( aProperty )
            cProperty := aProperty[ nY ]
            xValue := GetPropVal( @cProperty, xValue )

            If xValue == Nil
                Exit
            EndIf
        Next
    Else

        If (nPos := AScan( aProperties, bSearch )) > 0
            cProperty := aProperties[ nPos ]
            xValue := oObject[ cProperty ]
        EndIf

    EndIf

    Return xValue

Static Function GetFieldValue( cAlias, aFieldMap, cField )

    Local xValue  := Nil
    Local nPos    := 0
    Local bSearch := { | field | Upper( AllTrim( field[ 1 ] ) ) == Upper( AllTrim( cField ) ) }

    If ( nPos := AScan( aFieldMap, bSearch ) ) > 0
        xValue := ( cAlias )->( FieldGet( FieldPos( aFieldMap[ nPos ][ 2 ] ) ) )
    EndIf

    Return xValue
