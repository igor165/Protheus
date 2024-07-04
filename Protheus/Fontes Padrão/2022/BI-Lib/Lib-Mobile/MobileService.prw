#Include "totvs.ch"
// #Include "topconn.ch"
// #Include "restful.ch"

//--------------------------------------------------------------------
// Posições do array aQUERYSTRUCT
//--------------------------------------------------------------------
#DEFINE MAINTABLE       1   // nome da tabela principal do fluxo       
#DEFINE FIELDS          2   // array ou string com os campos retornados na query
#DEFINE CONDITIONS      3   // array com as condições do Where para a tabela principal
#DEFINE JOINS           4   // array com as informações de JOIN
#DEFINE GROUPBY         5   // string com a condição de GROUP BY, caso necessário
#DEFINE ORDERBY         6   // string com a condição de ORDER BY, caso não seja informado será usada o índice 1 da tabela principal

//--------------------------------------------------------------------
// Estrutura da posição JOINS do array aQUERYSTRUCT
//--------------------------------------------------------------------
#DEFINE JOIN_TABLE      1   // nome da tabela para o JOIN
#DEFINE JOIN_TYPE       2   // tipo de join
#DEFINE JOIN_FIELDS     3   // array ou string com os campos adicionais da query vindos do JOIN
#DEFINE JOIN_WHERE      4   // array com as condições do Where para o JOIN

#DEFINE JOIN_WHERE_CONDITION    1   // condição do Where
#DEFINE JOIN_WHERE_VARIABLES    2   // array com o conteúdo das variáveis

//--------------------------------------------------------------------
// Posições do array aCONDITIONS
//--------------------------------------------------------------------
#DEFINE CONDITION_STRING            1   // string com condição do Where
#DEFINE CONDITION_VARIABLES         2   // array com o conteúdo das variáveis


Static __oWSMobileService := FWHashMap():New()

Class MobileService
    Data cServiceName                       // Nome do serviço
    Data cOper                              // Nome da operação
    Data cQuery                             // Query do endpoint
    Data cMainTable                         // Tabela principal do endpoint
    Data cExecBlock                         // Ponto de entrada para adicionar campos na query
    Data cFields                            // Todos os campos apresentados na query
    Data cPEFields                          // Campos específicos adicionados pelo PE
    Data cJoin                              // Bloco de JOIN
    Data cWhere                             // Codição de WHERE da tabela principal
    Data cAggregation                       // String de agregação da query
    Data cOrder                             // Ordenação da query    

    Data nPage                              // Indica o número da página que será retornado na requisição
    Data nPageSize                          // Indica a quantidade de registros retornados por requisição

    Data aConditions                        // Vetor com as condições de WHERE
    Data aJoin                              // Vetor com os blocos do JOIN
    Data aVariables                         // Vetor com as informações variáveis da query

    Data lPageControl                       // Define se a query terá controle de paginação automática
    Data lMakeAuto                          // Indica se a query foi montada pela classe ( .T. ) ou informada pelo usuário ( .F. ).
    Data lMainID                            // Indica se será adicionado o R_E_C_N_O_ da tabela principal nos campos da query, caso não tenha sido informado
    Data lAutoProperty                      // Indica se será adicionado automaticamente todos os campos da query no Json da requisição.

    Data oJsonProperties                    // Objeto com as propriedades do JSON de resposta

    Method New( cName, cExecBlock )                                     // Construtor da classe
    Method MakeQueryModel( aQueryStruct )                               // Cria a estrutura da consulta base

    Method SetExecBlock( cExecBlock )                                   // Seta um PE para adicionar os campos à consulta
    Method GetExecBlock()                                               // Retorna o nome do PE

    Method SetPageControl( lPageControl )                               // Atribui se o componente terá controle de paginação
    Method GetPageControl()                                             // Retorna se o componente usa o controle de paginação
    
    Method SetMainID( lMainID )                                         // 
    Method GetMainID()                                                  //

    Method SetAutoProperty( lAutoProperty )                             //
    Method GetAutoProperty()                                            //

    Method SetVariables( aVariables )                                   //
    Method SetQueryVariables( oQuery, nPage, nPageSize )                //
    Method SetQueryStruct( aQryStruct )                                 // 
    Method SetJsonProperties( aProperties )                             // 

    Method SetQuery( cQuery, lPageControl )                             // 
    Method GetQuery()                                                   // 
    Method ExecQuery()                                                  // 

    Method AddFieldsbyPE()                                              // Adiciona campos que venham por PE na consulta SQL 

    // Method AddPEProperties( aProperties )                               //
    Method AddProperties( cFields )                                     // Adiciona as propriedades na estrutura do JSON
    Method RecordsToJson( cAlias, oJson, oProperties, cItemsName )      //
    
    Method Destroy()                                                    // Limpa o componente
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor do controlador do serviço
 
@param cName, caracter, Nome do serviço

@author  Marcia Junko
@since   11/01/2022
/*/
//------------------------------------------------------------------- 
Method New( cName, cExecBlock ) Class MobileService
    Default cName := ProcSource(1) 
    Default cExecBlock := ""

    cName := StrTran( cName, '.PRW', '')

    ::cServiceName  := cName
    ::cOper         := Procname(2)
    ::cQuery        := ""
    ::cMainTable    := ""
    ::cFields       := ""
    ::cPEFields     := ""
    ::cJoin         := ""
    ::cWhere        := ""
    ::cOrder        := ""

    ::aConditions   := {}
    ::aJoin         := {}
    ::aVariables    := {}

    ::lPageControl  := .T.
    ::lMakeAuto     := .F.
    ::lMainID       := .T.
    ::lAutoProperty := .T.

    ::oJsonProperties := JsonObject():New()

    ::SetExecBlock( cExecBlock )
Return self

//-------------------------------------------------------------------
/*/{Protheus.doc} SetQuery  
Atribui ao componente uma consulta informada pelo sistema.
 
@param cReceivedQry, caracter, Consulta SQL
@param lPageControl, lógico, Indica se a consulta terá controle de paginação.
    Por padrão este parâmetro é FALSO, mas pode ter o seu comteúdo alterado se 
    a consulta tiver explícito o parser <<PAGE_CONTROL>>

@return object, Objeto contendo a query base a ser executada pelo REST.
@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Method SetQuery( cReceivedQry, lPageControl ) Class MobileService
    Local oPrepare 
    Local aQryStruct := {}
    Local cOrder := ''

    Default lPageControl := .F.
    
    If !Empty( cReceivedQry )
        //----------------------------------------------------------------------
        // Seta o controle de paginação
        //----------------------------------------------------------------------    
        If !lPageControl .And. ( '<<PAGE_CONTROL>>' $ cReceivedQry )
            lPageControl := .T.
        EndIf 
        ::SetPageControl( lPageControl )

        //----------------------------------------------------------------------
        // Informa a estrutura da query de acordo com a consulta passada.
        //----------------------------------------------------------------------    
        aQryStruct := QryAttribute( cReceivedQry )
        ::SetQueryStruct( aQryStruct )        

        //----------------------------------------------------------------------
        // Adiciona o parser de paginação, caso não tenha sido informado na consulta
        //----------------------------------------------------------------------    
        If lPageControl .And. !( '<<PAGE_CONTROL>>' $ cReceivedQry )
            cReceivedQry := StrTran( cReceivedQry, aQryStruct[ FIELDS ], '<<PAGE_CONTROL>>, ' + aQryStruct[ FIELDS ] )
        EndIf

        //----------------------------------------------------------------------
        // Converte o parser de paginação
        //----------------------------------------------------------------------    
        IF ( '<<PAGE_CONTROL>>' $ cReceivedQry ) .And. ::GetPageControl()
            IF !::lMakeAuto 
                If !Empty( ::cOrder )
                    cOrder :=  ::cOrder
                else
                    cOrder := SqlOrder( ( ::cMainTable )->( IndexKey( 1 ) ) )
                EndIf
            EndIf
            
            cReceivedQry := QueryPageControl( cReceivedQry, cOrder )
        EndIf 

        //----------------------------------------------------------------------
        // Adiciona os campos informados pelo PE na consulta
        //----------------------------------------------------------------------    
        If !Empty( ::cExecBlock )
            ::cPEFields := ::AddFieldsbyPE( )
            IF !Empty( ::cPEFields )
                cReceivedQry := StrTran( cReceivedQry, aQryStruct[ FIELDS ], aQryStruct[ FIELDS ]  + ::cPEFields )
            EndIf
        EndIF

        ::cQuery := ChangeQuery( cReceivedQry )
        
        oPrepare := FWPreparedStatement():New( ::cQuery )
        __oWSMobileService:put( ::cOper, oPrepare )
    EndIf

    FWFreeArray( aQryStruct )
Return oPrepare 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetQuery  
Retorna a consulta atribuída ao componente.

@return caracter, consulta SQL atribuída ao componente.>

@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Method GetQuery( ) Class MobileService
Return ::cQuery 

//-------------------------------------------------------------------
/*/{Protheus.doc} ExecQuery  
Executa a query atribuída ao componente e retorna as informações no JSON
 
@param oQuery, object, Objeto contendo a query a ser executada pelo REST.
@param @oResponse, object, Objeto JSON que armazena os registros a apresentar

@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Method ExecQuery( oQuery, oResponse ) Class MobileService
    Local aSvAlias := GetArea()
    Local cTmp := ''
    Local nRecords := 0
    Local lHasNext := .T.

    cTmp := GetNextAlias()
    MPSysOpenQuery( oQuery:getFixQuery(), cTmp )
    dbSelectArea( cTmp )

    oResponse[ "hasNext" ] := .F.

    If ( cTmp )->( !Eof() )
        //----------------------------------------------------------------------
        // Transforma os dados da consulta em JSON
        //----------------------------------------------------------------------    
        ::RecordsToJson( cTmp, @oResponse )
        
        //----------------------------------------------------------------------
        // Ajusta o controle de execução da próxima consulta.
        //----------------------------------------------------------------------    
        COUNT TO nRecords
        IF !::GetPageControl() .Or. ( ::GetPageControl() .And. ( nRecords < ::nPageSize ) ) 
            lHasNext := .F.
        Else
            lHasNext := .T.
        EndIf
    Else
        lHasNext := .F.
    EndIf  
    
    oResponse[ "hasNext" ] := lHasNext

    ( cTmp )->( DBCloseArea() )

    If !Empty( aSvAlias )
        RestArea( aSvAlias )
    ENDIF

    FWFreeArray( aSvAlias )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetExecBlock  
Atribui o nome do PE ao componente.
 
@param cExecBlock, caracter, Nome do PE para adicionar os campos à consulta.

@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Method SetExecBlock( cExecBlock ) Class MobileService
    Default cExecBlock := ''
    
    If !Empty( cExecBlock )
        ::cExecBlock := cExecBlock
    EndIf
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetExecBlock  
Retorna o nome do PE utilizado pelo componente.
 
@return caracter, Nome do PE para adição de campos à consulta.
@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Method GetExecBlock( ) Class MobileService
Return ::cExecBlock 

//-------------------------------------------------------------------
/*/{Protheus.doc} SetPageControl  
Atribui o controle de paginação à consulta.

@param lPageControl, boolean, Determina se o controle de paginação 
    será efetuada pela consulta.

@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Method SetPageControl( lPageControl ) Class MobileService
    Default lPageControl := .T.
    
    ::lPageControl := lPageControl
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPageControl  
Retorna a configuração do controle de paginação
 
@return boolean, Indica se o controle de paginação será efetuada pela consulta.
@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Method GetPageControl( ) Class MobileService
Return ::lPageControl

//-------------------------------------------------------------------
/*/{Protheus.doc} SetVariables  
Executa a query atribuída ao componente e retorna as informações no JSON
 
@param aReceivedVar, array, Vetor com as informações variáveis da query. 
    São os valores "?" que serão substituídos no FWPreparedStatement.

@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Method SetVariables( aReceivedVar ) Class MobileService
    Local nX := 0

    Default aReceivedVar := {}
    
    If !Empty( aReceivedVar )
        aAdd( ::aVariables, {} )
        For nX := 1 to len( aReceivedVar )
            aAdd( ::aVariables[1], aclone( aReceivedVar[ nX ] ) )
        Next
    Endif
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} SetMainID  
Atribui a consulta se será adicionada o campo R_E_C_N_O_ da tabela 
principal nos campos da query, caso não tenha sido informado.
 
@param lMainID, boolean, Indica se o R_E_C_N_O_ será adicionado à consulta

@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Method SetMainID( lMainID ) Class MobileService
    Default lMainID := .T.
    
    ::lMainID := lMainID
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMainID  
Retorna se deve ser adicionado o R_E_C_N_O_ da tabela principal nos 
campos da query.
 
@return boolean, Indica se o campo R_E_C_N_O_ será adicionado à consulta.
@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Method GetMainID( ) Class MobileService
Return ::lMainID

//-------------------------------------------------------------------
/*/{Protheus.doc} SetAutoProperty  
Atribui se a consulta irá montar a lista de propriedades automaticamente, 
através dos campos da query, caso as propriedades do JSON não tenham sido
informadas.
 
@param lAuto, lógico, Indica se cria o JSON de retorno de acordo com os 
    campos da consulta.

@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Method SetAutoProperty( lAuto ) Class MobileService
    Default lAuto := .T.
    
    ::lAutoProperty := lAuto
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAutoProperty  
Retorna se a consulta irá montar a lista de propriedades automaticamente, 
através dos campos da query, caso as propriedades do JSON não tenham sido
informadas.

@return boolean, Indica se monta as propriedades de retorno do JSON de 
    forma automática, caso a estrutura do JSON não tenha sido definida.
@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Method GetAutoProperty( ) Class MobileService
Return ::lAutoProperty

//-------------------------------------------------------------------
/*/{Protheus.doc} MakeQueryModel  
Método que cria a query base utilizada pelo FWPrepareStatement de acordo
com a estrutura passada como parâmetro.
 
@param aQueryStruct, array, Vetor com os dados de estrutura da query.
    [1] - nome da tabela principal do fluxo
    [2] - array ou string com os campos retornados na query
    [3] - array com as condições do Where para a tabela principal
        [1] - condição do Where
        [2] - array com o conteúdo das variáveis
    [4] - array com as informações de JOIN
        [1] - nome da tabela para o JOIN
        [2] - tipo de join
        [3] - array ou string com os campos adicionais da query vindos do JOIN
        [4] - array com as condições do Where para o JOIN
        [1] - condição do Where
        [2] - array com o conteúdo das variáveis
    [5] - string com a condição de GROUP BY, caso necessário. Caso não tenha 
        sido informado e a query utilizar um campo de aggregação, o 
        GROUP BY será feito pelos demais campos.
    [6] - string com a condição de ORDER BY, caso não seja informado será 
        usada o índice 1 da tabela principal

@obs As posições principais da variável aQueryStruct devem seguir as
    constantes definidas no início da classe 
    
@return object, Objeto contendo a query base a ser executada pelo REST.
@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Method MakeQueryModel( aQueryStruct ) Class MobileService
    Local oPrepare := NIL
    Local cQuery := ''
    Local cQryFields := ''
    Local cFields := ''
    Local cAggregation := ''
    Local cOrder := ''
    Local cJoinFields := ''
    Local cAggField := ''
    Local nAgg := 0
    Local nAggAS := 0
    Local nAggComma := 0

    If !Empty( aQueryStruct )
        ::cMainTable := aQueryStruct[ MAINTABLE ]
        ::lMakeAuto     := .T.

        //----------------------------------------------------------------------
        // Formata os campos da query
        //----------------------------------------------------------------------    
        If !Empty( aQueryStruct[ FIELDS ] )
            IF valtype( aQueryStruct[ FIELDS ] ) == "A"
                aEval( aQueryStruct[ FIELDS ], {|x| cFields += x + ', '} )
            else
                cFields := aQueryStruct[ FIELDS ] + ', '
            EndIf

            If ::GetMainID()
                If !( ".R_E_C_N_O_" $ cFields )
                    cFields += ::cMainTable + '.R_E_C_N_O_ AS ' + ::cMainTable + '_ID, '
                EndIf
            EndIf
        EndIf


        //----------------------------------------------------------------------
        // Monta o bloco dos JOINs
        //----------------------------------------------------------------------    
        If !Empty( aQueryStruct[ JOINS ] )
            ::aJoin := GetJoinStruct( aQueryStruct[ JOINS ], @cJoinFields )
            
            ::cJoin := ::aJoin[1]

            If !Empty( ::aJoin[2] )
                aEval( ::aJoin[2], {|x| aAdd( ::aVariables, aClone( x ) ) } )
            EndIf
        EndIf

        //----------------------------------------------------------------------
        // Monta a condição de WHERE    
        //----------------------------------------------------------------------    
        If !Empty( aQueryStruct[ CONDITIONS ] )
            ::aConditions := SetWhereConditions( aQueryStruct[ CONDITIONS ], ::cMainTable )
            
            ::cWhere := ::aConditions[ CONDITION_STRING ]

            If !Empty( ::aConditions[ CONDITION_VARIABLES ] )
                aAdd( ::aVariables, aclone( ::aConditions[ CONDITION_VARIABLES ] ) )
            EndIf
        EndIf

        //----------------------------------------------------------------------
        // Adiciona campos a partir do PE
        //----------------------------------------------------------------------    
        If !Empty( ::cExecBlock )
            ::cPEFields := ::AddFieldsbyPE( )
        EndIF

        //----------------------------------------------------------------------
        // Formata os campos que serão retornados na query
        //----------------------------------------------------------------------    
        cQryFields := cFields + cJoinFields + ::cPEFields
        cQryFields := Iif( Right( cQryFields, 2 ) == ', ', Subs( cQryFields, 1, Len( cQryFields ) - 2 ), cQryFields )

        ::cFields := cQryFields

        //----------------------------------------------------------------------
        // Monta a instrução de agregação, caso exista
        //----------------------------------------------------------------------    
        If Len( aQueryStruct ) >= GROUPBY 
            IF !Empty( aQueryStruct[ GROUPBY ] )
                cAggregation :=  aQueryStruct[ GROUPBY ]
            Else
                If "SUM(" $ cQryFields

                    nAgg := At( 'SUM(', cQryFields )
                    nAggAS := At( ' AS ', Subs( cQryFields, nAgg ) )
                    nAggComma := At( ', ', Subs( cQryFields, nAggAS  ) )

                    cAggField := Subs( cQryFields, nAgg, nAggAS + nAggComma )

                    cAggregation := StrTran( cQryFields, cAggField, "" )

                    If ' AS ' + ::cMainTable + '_ID' $ cAggregation
                        cAggregation := StrTran( cAggregation, ' AS ' + ::cMainTable + '_ID', "" )
                    EndIf
                EndIf
            EndIf
        EndIf
        ::cAggregation := cAggregation


        //----------------------------------------------------------------------
        // Monta a instrução SQL
        //----------------------------------------------------------------------    
        cQuery := "SELECT " + Iif( ::GetPageControl(), "<<PAGE_CONTROL>>, ",  '')  + cQryFields + ;
            " FROM " + RetSqlName( ::cMainTable ) + " " + ::cMainTable + CRLF + ;
            ::cJoin + " WHERE " + ::cWhere

        If Len( aQueryStruct ) >= ORDERBY .And. !Empty( aQueryStruct[ ORDERBY ] )
            cOrder :=  aQueryStruct[ ORDERBY ]
        else
            cOrder := SqlOrder( ( ::cMainTable )->( IndexKey(1) ) )
        EndIf
        ::cOrder := cOrder

        If !Empty( cAggregation )
            cQuery += " GROUP BY " + cAggregation
        EndIf 

        If !::GetPageControl()
            cQuery += " ORDER BY " + cOrder
        Else
            cQuery := QueryPageControl( cQuery, cOrder )
        EndIf
        ::cQuery := cQuery
    EndIf

    If !Empty( cQuery )
        cQuery := ChangeQuery( cQuery )
        oPrepare := FWPreparedStatement():New( cQuery )
        __oWSMobileService:put( ::cOper, oPrepare )
    EndIf
Return oPrepare

/*//----------------------------------------------------------------------------------
{Protheus.doc} SetQueryStruct
Método responsável por atribuir os valores na query de acordo com as informações fornecidas.

@param aQryStruct, array, Vetor com os dados parseados da query, onde:
    [1] - tabela principal da query
    [2] - campos da query
    [3] - condição WHERE
    [4] - instrução de JOIN da query
    [5] - condição de agregação
    [6] - ordenação da query

@author Marcia Junko
@since 11/02/2022
*/
//----------------------------------------------------------------------------------
Method SetQueryStruct( aQryStruct ) Class MobileService
    //----------------------------------------------------------------------
    // Alimenta a tabela principal da consulta
    //----------------------------------------------------------------------    
    If !Empty( aQryStruct[ MAINTABLE ] )
        ::cMainTable := aQryStruct[ MAINTABLE ]
    ENDIF

    //----------------------------------------------------------------------
    // Alimenta os campos da consulta
    //----------------------------------------------------------------------    
    If !Empty( aQryStruct[ FIELDS ] )
        ::cFields := aQryStruct[ FIELDS ]              
    ENDIF

    //----------------------------------------------------------------------
    // Alimenta os campos adicionais
    //----------------------------------------------------------------------    
    ::cPEFields := ::AddFieldsbyPE()
    If !( Empty( ::cPEFields ) )
        ::cFields += ::cPEFields
    EndIf
    
    //----------------------------------------------------------------------
    // Alimenta a Codição de WHERE da tabela principal na consulta
    //----------------------------------------------------------------------    
    If !Empty( aQryStruct[ CONDITIONS ] )
        ::cWhere := aQryStruct[ CONDITIONS ]              
    ENDIF
    
    //----------------------------------------------------------------------
    // Alimenta Bloco de JOIN da consulta
    //----------------------------------------------------------------------    
    If !Empty( aQryStruct[ JOINS ] )
        ::cJoin := aQryStruct[ JOINS ]              
    ENDIF
    
    //----------------------------------------------------------------------
    // Alimenta a string de agregação da query
    //----------------------------------------------------------------------    
    If !Empty( aQryStruct[ GROUPBY ] )
        ::cAggregation := aQryStruct[ GROUPBY ]              
    ENDIF
    
    //----------------------------------------------------------------------
    // Alimenta a Ordenação da query
    //----------------------------------------------------------------------    
    If !Empty( aQryStruct[ ORDERBY ] )
        ::cOrder := aQryStruct[ ORDERBY ]              
    ENDIF
RETURN

/*//----------------------------------------------------------------------------------
{Protheus.doc} SetQueryVariables
Função responsável por atribuir os valores na query de acordo com as variáveis e 
a paginação solicitada.

@param @oQuery, object, Objeto que armazena as informações da query
@param nPage, number, Número da página
@param nPageSize, number, Número de registros por página

@author Marcia Junko
@since 11/02/2022
*/
//----------------------------------------------------------------------------------
Method SetQueryVariables( oQuery, nPage, nPageSize ) Class MobileService
    Local nRecStart     := 0
    Local nRecFinish    := 0 
    Local nI            := 0
    Local nJ            := 0
    Local nX            := 0
    Local nCount        := 1

    Default nPage := 1
    Default nPageSize := 20

    IF ::GetPageControl()
        nRecStart := ( ( nPage - 1 ) * nPageSize ) + 1
        nRecFinish := ( nRecStart + nPageSize ) - 1

        ::nPage := nPage
        ::nPageSize := nPageSize
    EndIf

    For nI := 1 to len( ::aVariables )
        For nJ := 1 to Len( ::aVariables[ nI ] )
            
            Do Case
                Case ::aVariables[ nI ][ nJ ][1] == "C"
                    If Valtype( ::aVariables[ nI ][ nJ ][3] ) == "C"
                        oQuery:setString( nCount, ::aVariables[ nI ][ nJ ][3] )
                    ElseIF Valtype( ::aVariables[ nI ][ nJ ][3] ) == "A"
                        For nX := 1 to len( ::aVariables[ nI ][ nJ ][3] )
                            oQuery:setString( nCount, ::aVariables[ nI ][ nJ ][3][ nX ] )
                            If nX < len( ::aVariables[ nI ][ nJ ][3] )
                                nCount++
                            EndIf
                        Next
                    EndIf             
                Case ::aVariables[ nI ][ nJ ][1] == "N"
                    oQuery:setNumeric( nCount, ::aVariables[ nI ][ nJ ][3] )
            EndCase
            nCount++
        Next
    Next

    If ::GetPageControl()
        oQuery:setNumeric( nCount, nRecStart )
        nCount++
        oQuery:setNumeric( nCount, nRecFinish )     
    EndIf
Return

//----------------------------------------------------------------------------------
/*{Protheus.doc} SetJsonProperties
Método responsável por atribuir a estrutura do JSON de acordo com as propriedades passadas.

@param aProperties, array, vetor com a lista de propriedades do JSON
    [1] - nome do campo
    [2] - label no JSON
@return json, componente com a estrutura do Json
@author Marcia Junko
@since 11/02/2022
*/
//----------------------------------------------------------------------------------
Method SetJsonProperties( aProperties ) Class MobileService
    Local oJsonProperties
    Local nProp := 0
    Local cField := ''
    Local cLabel := ''

    oJsonProperties := JsonObject():New()
    
    For nProp := 1 to len( aProperties )
        cField := aProperties[ nProp ][1]
        cLabel := aProperties[ nProp ][2]

        ::oJsonProperties[ cField ] := SetJSonField( cLabel )
    Next

    IF ::cMainTable + '_ID' $ ::cFields .And. Ascan( aProperties, {|x| x[1] == ::cMainTable + '_ID' } ) == 0
        ::oJsonProperties[ ::cMainTable + '_ID' ] := SetJSonField( lower( ::cMainTable ) + 'Id' )
    EndIf
Return ::oJsonProperties


//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy  
Destroi o objeto e libera a memória alocada. 

@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Method Destroy() Class MobileService
    ::cServiceName  := NIL
    ::cQuery        := NIL
    ::cExecBlock    := NIL
    ::cOper         := NIL

    ::cMainTable    := NIL
    ::cFields       := NIL
    ::cPEFields     := NIL
    ::cJoin         := NIL
    ::cWhere        := NIL
    ::cAggregation  := NIL
    ::cOrder        := NIL

    ::nPage         := NIL
    ::nPageSize     := NIL

    ::lPageControl  := NIL
    ::lMakeAuto     := NIL
    ::lMainID       := NIL
    ::lAutoProperty := NIL

    FWFreeArray( ::aContions )
    ::aConditions   := NIL
    FWFreeArray( ::aJoin )
    ::aJoin         := NIL
    FWFreeArray( aVariables )
    ::aVariables    := NIL

    FreeObj( ::oJsonProperties )
    ::oJsonProperties := NIL
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} VldDeletCondition  
Função que avalia se a condição de WHERE com D_E_L_E_T_ existe. Caso 
não tenha sido informada, adiciona a condição de D_E_L_E_T_ da tabela.
 
@param cTable, caracter, Tabela onde a condição de D_E_L_E_T_ deve ser adicionada
@param @cWhere, caracter, String com a condição do WHERE recebida como 
    parâmetro e que deve ser ajustada.

@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Static Function VldDeletCondition( cTable, cWhere )
    IF !( "D_E_L_E_T_" $ cWhere )
        cWhere += " AND " + cTable + ".D_E_L_E_T_ = ' ' "
    EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetJoinStruct  
Função que monta o bloco de JOINs da consulta, de acordo com os parâmetros passados
 
@param aJoins, array, Array com as informações para montagem do bloco de JOIN
    [1] - nome da tabela para o JOIN
    [2] - tipo de join
    [3] - array ou string com os campos adicionais da query vindos do JOIN
    [4] - array com as condições do Where para o JOIN
        [1] - condição do Where
        [2] - array com o conteúdo das variáveis
@param @cFields, caracter, armazena os campos adicionais que foram passados no JOIN. 

@return array, Retorna a string completa do join e a lista de variáveis
    [1] - string, bloco de JOINs
    [2] - variáveis para substituição durante o FWPrepareStatement.
@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Static Function GetJoinStruct( aJoins, cFields )
    Local aWhere := {}
    Local aVariables := {}
    Local cJoins := ''
    Local cTable := ''
    Local nI := 0

    For nI := 1 to len( aJoins )
        cTable := aJoins[ nI ][ JOIN_TABLE ]

        If !Empty( aJoins[ nI ][ JOIN_FIELDS ] )
            If valtype( aJoins[ nI ][ JOIN_FIELDS ] ) == "A"
                aEval( aJoins[ nI ][ JOIN_FIELDS ], {|x| cFields += x + ', '})
            else
                cFields += aJoins[ nI ][ JOIN_FIELDS ] + ', '
            EndIf
        EndIf

        If !Empty( aJoins[ nI ][ JOIN_WHERE ] )  
            aWhere := SetWhereConditions( aJoins[ nI ][ JOIN_WHERE ], cTable )
        EndIf

        cJoins += " " + aJoins[ nI ][ JOIN_TYPE ] + " JOIN " + RetSqlName( cTable ) + " " + cTable + " ON " + aWhere[ CONDITION_STRING ] + CRLF

        aAdd( aVariables, aClone( aWhere[ CONDITION_VARIABLES ] ) )
    Next

    FWFreeArray( aWhere )
Return { cJoins, aVariables }

//-------------------------------------------------------------------
/*/{Protheus.doc} SetWhereConditions  
Atribui ao componente uma consulta informada pelo sistema.
 
@param aWhere, array, Vetor com as informações do Where para o JOIN
    [1] - condição do Where
    [2] - array com o conteúdo das variáveis
@param cTable, caracter, nome da tabela na qual a condição se refere

@return array, Retorna a string completa do WHERE e a lista de variáveis 
    [1] - string, bloco de WHERE
    [2] - informações das variáveis para substituição durante o FWPrepareStatement.
@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Static Function SetWhereConditions( aWhere, cTable )
    Local cWhere := ''
    Local cCondition := ''
    Local cVariables := ''
    Local aVariables := {}
    Local nI := 0

    For nI := 1 to len( aWhere )
        If nI > 1
            cWhere += " AND "
        EndIf
        cCondition := aWhere[ nI ][ JOIN_WHERE_CONDITION ]

        If '?' $ cCondition
            cVariables := aWhere[ nI ][ JOIN_WHERE_VARIABLES ]
            aAdd( aVariables, { Valtype( cVariables ), cCondition, cVariables } )
        EndIf
        cWhere += cCondition
    Next
    cWhere += " "
    VldDeletCondition( cTable, @cWhere )
Return { cWhere, aVariables }


//-------------------------------------------------------------------
/*/{Protheus.doc} AddFieldsbyPE  
Método que retorna os campo adicionais vindos do PE.

@return caracter, String com os campos retornados pelo PE separados por ",".
@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Method AddFieldsbyPE(  ) Class MobileService
    Local aFields := {}
    Local cResult := ""
    Local cField := ""
    Local cPEFields := ""
    Local nItem := 0

    If !Empty( ::cExecBlock )
        If ExistBlock( ::cExecBlock )
            cResult := ExecBlock( ::cExecBlock, .F., .F. )

            IF !Empty( cResult )
                aFields := StrToArray( cResult, '|' )
                For nItem := 1 to len( aFields )
                    cField := aFields[ nItem ]

                    If !( cField + ',' $ cPEFields + ',' )
                        cPEFields += ', ' + cField
                    EndIf
                Next
            EndIf

            FWFreeArray( aFields )
        endif
    EndIf
return cPEFields

//-------------------------------------------------------------------
/*/{Protheus.doc} AddPEProperties  
Adiciona na lista de propriedades as informações dos campos retornados pelo PE. 
@param @aProperties, array, Vetor com a estrutura das propriedades retornadas no JSON.

@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
// Method AddPEProperties( aProperties ) Class MobileService
//     // Local aStruct := {}
//     Local aFields := {}
//     Local cField := ''
//     Local cLabel := ''
//     Local nI := 0

//     Default aProperties := {}

//     If !Empty( ::cPEFields ) 
//         aFields := StrToArray( ::cPEFields, ',' )
//         For nI := 1 to len( aFields )
//             cField := aFields[ nI ]

//             cLabel := TreatJSONLabel( cField )

//             // aStruct := FWSX3Util():GetFieldStruct( cField )

//             // aAdd( aProperties, { cField, cLabel, aStruct[2], aStruct[3], aStruct[4] } )
//             If Ascan( aProperties, { |x| x[ 1 ] == cField } ) == 0
//                 aAdd( aProperties, { cField, cLabel } )
//             EndIf
//         Next
//     EndIf
// Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddProperties  
Adiciona as propriedades na resposta do JSON.
 
@param cFields, caracter, Campos que devem ser apresentados no JSON

@return array, Lista com as propriedades que serão retornadas no JSON.
@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Method AddProperties( cFields ) Class MobileService
    Local aProperties := {}
    Local aExists := {}
    Local aFields := {}
    Local cField := ''
    Local cLabel := ''
    Local nI := 0
    Local lSeek := ::GetAutoProperty()

    Default cFields := ''

    If !Empty( cFields ) 
        aFields := StrToArray( cFields, ',' )
        aExists := ::self:oJsonProperties:getnames()

        For nI := 1 to len( aFields )
            cField := aFields[ nI ]

            If ' AS ' $ cField
                cField := Subs( cField, At( ' AS ', cField ) + 4)  
            EndIf

            If lSeek .And. Ascan( aExists, {|x| x == alltrim( cField ) } ) == 0
                cLabel := TreatJSONLabel( cField )

                aAdd( aProperties, { cField, cLabel } )
            EndIf
        Next
    EndIf

    FWFreeArray( aFields )
    FWFreeArray( aExists )
Return aProperties

//----------------------------------------------------------------------------------
/*{Protheus.doc} ResultToJson
Método que atribui o resultado da query ao JSON

@param cAlias, caracter, Alias da query
@param @oJson, JSON, componente que receberá os registros
@param oProperties, JSON, componente com a estrutura do Json
@param cItemsName, caracter, Nome do nó principal onde os registros serão armazenados

@author Marcia Junko
@since 11/02/2022
*/
//----------------------------------------------------------------------------------
Method RecordsToJson( cAlias, oJson, oProperties, cItemsName ) Class MobileService
    local aFields := ( cAlias )->( dbStruct() )
    Local aSymbol := { GETMV("MV_SIMB1"), GETMV("MV_SIMB2"), GETMV("MV_SIMB3"), GETMV("MV_SIMB4"), GETMV("MV_SIMB5") }
    Local aProperties := {}
    local oItem
    local cPropertyName := ''
    Local xAux := ''
    local nField := 0

    Default oProperties := NIL
    Default cItemsName := 'records' 

    oJson[ cItemsName ] := {}

    //----------------------------------------------------------------------
    // Se as propriedades de retorno não tiverem sido informadas, monta a 
    // lista de acordo com os campos da query
    //----------------------------------------------------------------------    
    If Empty( ::oJsonProperties:getNames() ) .Or. ::GetAutoProperty()
        aProperties := ::AddProperties( ::cFields ) 
        ::SetJsonProperties( aProperties )
    EndIf
    
    ( cAlias )->( DBGoTop() )
    While ( cAlias )->( !EOF() )
        oItem := JsonObject():new()

        For nField := 1 to len( aFields )
            If aFields[ nField ][ 1 ] != 'LINE'
                cPropertyName := ::oJsonProperties[ aFields[ nField ][ 1 ] ][ "name" ]
                If cPropertyName == 'currency'
                    xAux := ( cAlias )->( fieldget( nField ) )
                    IF xAux == 0
                        xAux := 1
                    Endif 
                    oItem[ cPropertyName ] := aSymbol[ xAux ]
                Else
                    If empty( cPropertyName )
                        cPropertyName := aFields[ nField ][1]
                    Endif
                    oItem[ cPropertyName ] := getValueJson( ( cAlias )->( fieldget( nField ) ), aFields[ nField ][2] )
                EndIf
            EndIf
        Next 

        aAdd( oJson[ cItemsName ], oItem )
        
        ( cAlias )->( dbskip() )
    End

    FWFreeArray( aFields )
    FWFreeArray( aSymbol )
    FreeObj( oItem )
return 

//----------------------------------------------------------------------------------
/*{Protheus.doc} QueryPageControl
Função responsável por atribuir o tratamento de paginação, caso a tag PAGE_CONTROL
seja utilizada ma query.

@param cQuery, caracter, Query original para tratamento
@param cOrderBy, caracter, Instrução de ordenação por operação

@return caracter, Query com o tratamento para paginação
@author Marcia Junko
@since   11/02/2022
*/
//----------------------------------------------------------------------------------
Static Function QueryPageControl( cQuery, cOrderBy )
	Local nPosStart   := 0
	Local nPosEnd     := 0
	Local nPosFrom    := 0
	Local cAuxQuery    := ""
    Local cFields      := ""
    Local cPageControl := ""
    Local cTag         := "<<PAGE_CONTROL>>"

	Default cQuery   := ""

	IF At( cTag, cQuery ) > 0 
		nPosStart  := At( cTag, cQuery )
		cAuxQuery  := SubStr( cQuery, nPosStart )
	
        nPosEnd := Len( cTag )
        nPosFrom := At( " FROM ", cAuxQuery )
        cFields := Alltrim( Subs( cAuxQuery, nPosEnd + 2, nPosFrom - nPosEnd - 2 ) )
        cFields := AdjustFields( cFields )

        cPageControl := cFields + ' FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ' + cOrderBy + ' ) AS LINE '
    
        cQuery := StrTran( cQuery, cTag, cPageControl )
        cQuery += ' ) TABLE_AUX WHERE LINE BETWEEN ? AND ? '
	EndIf
Return cQuery

//----------------------------------------------------------------------------------
/*{Protheus.doc} AdjustFields
Função responsável por ajustar os campos na query de paginação quando utilizado 
alguma função de agregação ou renomear o nome do campo.
Esta função só é acionada quando o controle de paginação está sendo usado.

@param cFields, caracter, Campos da query

@return caracter, Campos tratados da query
@author Marcia Junko
@since 11/02/2022
*/
//----------------------------------------------------------------------------------
Static Function AdjustFields( cFields )
	Local aFields := {}
    Local nItem := 0
    Local nPosAs := 0
	Local cAdjustFields := ''    
    Local cField := ''

    If At( ' AS ', cFields ) > 0
        aFields := StrToArray( cFields, ',' )
        For nItem := 1 to len( aFields )
            If nItem > 1
                cAdjustFields += ', '
            EndIf

            cField := aFields[ nItem ]
            If ' AS ' $ Upper( cField )
                nPosAs := At( " AS ", Upper( cField ) )

                cAdjustFields += SubStr( cField, nPosAs + 4 )
            Else
                cAdjustFields += cField
            EndIf
        Next
    Else
        cAdjustFields := cFields
    EndIf
Return cAdjustFields

//----------------------------------------------------------------------------------
/*{Protheus.doc} SetJSonField
Atribui ao objeto JSON as propriedades da estrutura.

@param cLabel, caracter, Label da propriedade no JSON

@return json, propriedades das colunas
@author Marcia Junko
@since 11/02/2022
*/
//----------------------------------------------------------------------------------
static function SetJSonField( cLabel )
    local jField := JsonObject():New()

    jField["name"] := cLabel
return jField

/*
//----------------------------------------------------------------------------------
{Protheus.doc} getValueJson
Função para tratar os conteúdos do tipo caracter, tirando os espaços e adequando os
caracteres especiais

@param xValue, any, Conteúdo a tratar
@param cType, caracter, Tipo do campo

@return any, Conteúdo tratado do JSON
@author Marcia Junko
@since 11/02/2022
*/
//----------------------------------------------------------------------------------
static function getValueJson( xValue, cType )
    if cType == "C"
        xValue := EncodeUTF8( Alltrim( xValue ) )
    endif
return xValue

//----------------------------------------------------------------------------------
/*/{Protheus.doc} MobGetQuery
Função responsável por chamar a criação da query modelo.

@param cOper, caracter, Identifica qual a query será retornada
@param oSelf, object, Componente do serviço REST que está sendo executado
@param @oService, object, Objeto da classe de serviço ( contém a estrutura da query ) 

@return object, Objeto contendo a query a ser executada pelo REST.
@author Marcia Junko
@since 11/02/2022
/*/
//----------------------------------------------------------------------------------
Function MobGetQuery( cOper, oSelf, oService )
    Local oPrepare
    Local cProgram := ''
    Local nStep := 1

    IF FWISINCALLSTACK("MobJSONResult")
        nStep := 2
    EndIf
    cProgram := ProcSource( nStep )   // Retorna o nome do fonte PRW que fez a chamada da função
    cProgram := StrTran( cProgram, '.PRW', '')

    oPrepare := &('STATICCALL( ' + cProgram + ', QueryModel, cOper, oSelf, @oService )')  
Return oPrepare

//-------------------------------------------------------------------
/*/{Protheus.doc} QryAttribute  
Função responsável por separar as informações de estrutura da consulta 
de acordo com a query informada.
 
@param cQuery, caracter, Consulta SQL

@return array, Informações de estrutura da query
    [1] - // nome da tabela principal do fluxo       
    [2] - // array ou string com os campos retornados na query
    [3] - // array com as condições do Where para a tabela principal
    [4] - // array com as informações de JOIN
    [5] - // string com a condição de GROUP BY, caso necessário
    [6] - // string com a condição de ORDER BY, caso não seja informado será usada o índice 1 da tabela principal
@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Static Function QryAttribute( cQuery )
    Local cFields := ''
    Local cMainTable := ''
    Local cJoin := ''
    Local cWhere := ''
    Local cGroup := ''
    Local cOrder := ''

    cMainTable := QryByAttribute( cQuery, 'FROM' )
    cFields := QryByAttribute( cQuery, 'FIELDS' )
    cWhere := QryByAttribute( cQuery, 'WHERE' )
    cJoin := QryByAttribute( cQuery, 'JOIN' )
    cGroup := QryByAttribute( cQuery, 'GROUP BY')
    cOrder := QryByAttribute( cQuery, 'ORDER BY' )

    //Deve seguir a mesma ordem do array aQueryStruct para não confundir
Return { cMainTable, cFields, cWhere, cJoin, cGroup, cOrder } 
 
//-------------------------------------------------------------------
/*/{Protheus.doc} QryByAttribute  
Retorna informações da query de acordo com o atributo fornecido.
 
@param cQuery, caracter, Consulta SQL
@param cTag, caracter, Identificação da parte da query que deve ser retornada.

@return caracter, Objeto contendo a query base a ser executada pelo REST.
@author  Marcia Junko
@since 11/02/2022
/*/
//------------------------------------------------------------------- 
Static Function QryByAttribute( cQuery, cTag )
    Local aAttributes := { 'FROM', 'FIELDS', 'WHERE', 'JOIN', 'GROUP BY', 'ORDER BY' }
    Local cContent := ''
    Local cRemainder := ''
    Local nX := 0
    Local nPosStart   := 0
	Local nPosEnd     := 0
	Local nPosFrom    := 0
    Local nAux        := 0
    Local nAt           := 0
	Local cAuxQuery    := ""

    Default cTag := ''

    If cTag == 'FIELDS'
        nPosStart  := At( 'SELECT ', cQuery )
        cAuxQuery  := SubStr( cQuery, nPosStart + Len('SELECT ') )
        nPosFrom := At( " FROM ", cAuxQuery )

        cContent := Substr( cAuxQuery, nPosStart, nPosFrom )

        If "<<PAGE_CONTROL>>" $ cContent
            cContent := Strtran( cContent, "<<PAGE_CONTROL>>, ", '' )
        EndIf
    Else
        If Left( cTag, 1 ) != " " 
            cAttribute := " " + cTag
        EndIf
        If Right( cAttribute, 1 ) != " "
            cAttribute := cAttribute + " "
        EndIf

        IF At( cAttribute, cQuery ) > 0 
            nPosStart  := At( cAttribute, cQuery ) 

            IF cTag == 'FROM'
                cAuxQuery  := SubStr( cQuery, nPosStart + Len( cAttribute ) )
            
                nPosEnd := At( " ", cAuxQuery )
                cRemainder := SubStr( cAuxQuery, 1, nPosEnd )
                If FwSX2Util():SeekX2File( cRemainder )
                    cContent := FWX2Chave()
                Else
                    cContent := cRemainder
                EndIf
            ElseIf cTag == 'JOIN'
                cAuxQuery := subs( cQuery, 1, nPosStart - 1 )

                nAux := RAt( ' ', cAuxQuery )
                cContent := Subs( cQuery, nAux )

                nAt := Ascan( aAttributes, {|x| x == cTag }) + 1

                For nX := nAt to len( aAttributes )
                    cContent := DealOtherAttributes( cContent, aAttributes[ nX ])
                Next
            Else 
                cContent  := SubStr( cQuery, nPosStart + Len( cAttribute ) )

                nAt := Ascan( aAttributes, {|x| x == cTag }) + 1

                If nAt <= len( aAttributes )
                    For nX := nAt to len( aAttributes )
                        cContent := DealOtherAttributes( cContent, aAttributes[ nX ])
                    Next
                EndIf

            EndIf
        EndIf
    EndIf
Return Alltrim( cContent )


//-------------------------------------------------------------------
/*/{Protheus.doc} SetQuery  
Atribui ao componente uma consulta informada pelo sistema.
 
@param cReceivedQry, caracter, Consulta SQL
@param lPageControl, lógico, Indica se a consulta terá controle de paginação.
    Por padrão este parâmetro é FALSO, mas pode ter o seu comteúdo alterado se 
    a consulta tiver explícito o parser <<PAGE_CONTROL>>

@return object, Objeto contendo a query base a ser executada pelo REST.
@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Static Function DealOtherAttributes( cContent, cTag )
    Local nAux := 0
    Local cNewContent := cContent

    If cTag $ cContent
        nAux := At( ' ' + cTag + ' ', cContent )

        cNewContent := Subs( cContent, 1, nAux )

    ENDIF
Return cNewContent


//-------------------------------------------------------------------
/*/{Protheus.doc} TreatJSONLabel  
Função para tratar e retornar o nome da propriedade que será utilizada no JSON.
 
@param cField, caracter, Nome do campo que será utilizado na propriedade.

@return caracter, texto que será apresentado como label do JSON
@author  Marcia Junko
@since   11/02/2022
/*/
//------------------------------------------------------------------- 
Static Function  TreatJSONLabel( cField )
    Local cLabel := ''

    //----------------------------------------------------------------------
    // Pega o título do campo em inglês
    //----------------------------------------------------------------------    
    cLabel := GetSx3Cache( cField, "X3_TITENG" )

    //----------------------------------------------------------------------
    // Se for um campo nomeado, trata a label para ser o próprio campo
    //----------------------------------------------------------------------    
    If Empty( cLabel )
        cLabel := cField 
    ENDIF

    //----------------------------------------------------------------------
    // Retira do texto os caracteres especiais e acentos
    //----------------------------------------------------------------------    
    cLabel := BIXCleanText( cLabel ) 

    //----------------------------------------------------------------------
    // Ajusta a label, trocando os ' ' por '_' 
    //----------------------------------------------------------------------    
    cLabel := strTran( alltrim( cLabel ), ' ', '_' )
Return lower( cLabel )


//----------------------------------------------------------------------------------
/*/{Protheus.doc} MobChkApprover
Função responsável por avaliar se o usuário logado é um aprovador e retornar as 
informações conforme o tipo.

@param nType, number, indica qual o retorno da função, onde
    1 = lógico, se o usuário logado é ou não um aprovador
    2 = caracter, nome do usuário

@return any, de acordo com o tipo passado
@author Marcia Junko
@since 11/02/2022
/*/
//----------------------------------------------------------------------------------
Function MobChkApprover( nType )
    Local aSvAlias := GetArea()
    Local uRet

    Default nType := 1

    SAK->( DBSetOrder( 2 ) ) //AK_FILIAL + AK_USER

    If SAK->( MsSeek( xFilial( "SAK" ) + __cUserId ) )
        Iif( nType == 1, uRet := .T., uRet := SAK->AK_USER )
    Else
        Iif( nType == 1, uRet := .F., uRet := '' )
    EndIf
    
    If !Empty( aSvAlias )
        RestArea( aSvAlias )
    EndIf

    FWFreeArray( aSvAlias )
Return uRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} MobJUsrApprover
Função responsável por retornar em formato JSON se o usuário é ou não um aprovador 
baseado na tabela SAK.

@return caracter, informações solicitadas sobre o aprovador.
@author Marcia Junko
@since 11/02/2022
/*/
//----------------------------------------------------------------------------------
Function MobJUsrApprover()
    Local oResponse := JsonObject():New()
    Local cJson     := ""

    oResponse[ "isUserApprover" ] := MobChkApprover( 1 )   
    
    cJson := FWJsonSerialize( oResponse, .F., .F., .T. )
Return cJson

//----------------------------------------------------------------------------------
/*/{Protheus.doc} MobJSONResult
Função responsável por retornar ao serviço o JSON com os dados solicitados.

@param cOper, caracter, Identifica qual a query será retornada
@param oREST, object, Componente do serviço REST que está sendo executado
@param @oMobService, object, Objeto da classe de serviço ( contém a estrutura da query ) 

@return object, Objeto contendo a query a ser executada pelo REST.
@author Marcia Junko
@since 11/02/2022
/*/
//----------------------------------------------------------------------------------
Function MobJSONResult( cOper, oRest, oResponse )
    Local cProgram := ''
    Local oMobService
    Local oQuery
    Local aProperties   := {}

    cProgram := ProcSource( 1 )   // Retorna o nome do fonte PRW que fez a chamada da função
    cProgram := StrTran( cProgram, '.PRW', '')

    oQuery := MobGetQuery( cOper , oRest, @oMobService )

    oMobService:SetQueryVariables( @oQuery, oRest:page, oRest:pageSize  )

    aProperties := &('STATICCALL( ' + cProgram + ', SetPropByOper, cOper )')  

    oMobService:SetJsonProperties( aProperties )

    oMobService:ExecQuery( oQuery, @oResponse ) 
Return
