#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WSFIN677.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/ {REST Web Service} WSFin677
    App Minha Prestacao de Contas integrado com Protheus
    @version 12.1.17
    @since 23/08/2017
    @author Igor Sousa do Nascimento
/*/
//-------------------------------------------------------------------
WSRESTFUL WSFin677	DESCRIPTION "Servico de prestacao de contas"

    WSDATA order          As BOOLEAN Optional
    WSDATA default        As BOOLEAN Optional
    WSDATA page           As INTEGER Optional
    WSDATA pageSize       As INTEGER Optional
    WSDATA fields         As STRING  Optional
    WSDATA expenseID      As STRING  Optional
    WSDATA itemID         As STRING  Optional
    WSDATA isTravel       As STRING  Optional
    // Campos de filtro
    WSDATA international  As BOOLEAN Optional
    WSDATA departure_date As STRING  Optional
    WSDATA arrival_date   As STRING  Optional  
    WSDATA travelNumber   As STRING  Optional
    WSDATA travel         As BOOLEAN Optional
    WSDATA status         As STRING  Optional
    WSDATA open           As BOOLEAN Optional
    WSDATA searchKey      As STRING  Optional
    WSDATA dDepartDate    As STRING  Optional

    WSMETHOD GET Main ;
    DESCRIPTION "Carrega as prestacoes de contas na tela principal" ;
    WSSYNTAX "/expenses" ;
    PATH "/expenses"
    
    WSMETHOD GET Checked ;
    DESCRIPTION "Carrega as prestações liberadas para aprovação" ;
    WSSYNTAX "/checked" ;
    PATH "/checked"

    WSMETHOD GET CheckItems ;
    DESCRIPTION "Carrega os itens da prestacao de contas em aprovação" ;
    WSSYNTAX "/checked/{expenseID}/{isTravel}/items" ;
    PATH "/checked/{expenseID}/{isTravel}/items"

    WSMETHOD GET CheckAttch ;
    DESCRIPTION "Carrega os anexos da despesa em aprovação" ;
    WSSYNTAX "/checked/{expenseID}/{isTravel}/items/{itemID}/attachment" ;
    PATH "/checked/{expenseID}/{isTravel}/items/{itemID}/attachment"
 
    WSMETHOD GET Acc ;
    DESCRIPTION "Carrega uma prestacao de contas em especifico" ;
    WSSYNTAX "/expenses/{expenseID}/{isTravel}" ;
    PATH "/expenses/{expenseID}/{isTravel}"

    WSMETHOD GET Items ;
    DESCRIPTION "Carrega os itens da prestacao de contas" ;
    WSSYNTAX "/expenses/{expenseID}/{isTravel}/items" ;
    PATH "/expenses/{expenseID}/{isTravel}/items"

    WSMETHOD GET Attch ;
    DESCRIPTION "Carrega os anexos da despesa" ;
    WSSYNTAX "/expenses/{expenseID}/{isTravel}/items/{itemID}/attachment" ;
    PATH "/expenses/{expenseID}/{isTravel}/items/{itemID}/attachment"

    WSMETHOD GET Clients ; 
    DESCRIPTION "Metodo para retornar a lista de clientes disponiveis" ;
    WSSYNTAX "/clients" ;
    PATH "/clients"

    WSMETHOD GET CostCenters ; 
    DESCRIPTION "Metodo para retornar a lista de centros de custo" ;
    WSSYNTAX "/cost_centers" ;
    PATH "/cost_centers"

    WSMETHOD GET Currencies ; 
    DESCRIPTION "Metodo para retornar a lista de moedas disponiveis" ;
    WSSYNTAX "/currencies" ;
    PATH "/currencies"

    WSMETHOD GET Destinations ; 
    DESCRIPTION "Metodo para retornar a lista de destinos de viagens" ; 
    WSSYNTAX "/destinations" ;
    PATH "/destinations"

    WSMETHOD GET XpenseType ; 
    DESCRIPTION "Metodo para retornar a lista dos tipos de despesas" ; 
    WSSYNTAX "/items/types" ;
    PATH "/items/types"

    WSMETHOD GET isApprover ; 
    DESCRIPTION "Metodo para retornar se um usuario e aprovador no cenario de despesas." ; 
    WSSYNTAX "/isapprover" ;
    PATH "/isapprover"

    WSMETHOD POST Acc ; 
    DESCRIPTION "Inclusao da prestacao de contas e item" ;
    WSSYNTAX "/expenses" ;
    PATH "/expenses"

    WSMETHOD POST Xpenses ; 
    DESCRIPTION "Inclusao de item na prestacao de contas" ;
    WSSYNTAX "/expenses/{expenseID}/{isTravel}/items" ;
    PATH "/expenses/{expenseID}/{isTravel}/items"

    WSMETHOD POST Attch ; 
    DESCRIPTION "Inclusao de anexo na despesa" ;
    WSSYNTAX "/expenses/{expenseID}/{isTravel}/items/{itemID}/attachment" ;
    PATH "/expenses/{expenseID}/{isTravel}/items/{itemID}/attachment"

    WSMETHOD POST Advance ; 
    DESCRIPTION "Inclusao de adiantamento da viagem" ;
    WSSYNTAX "/advance" ;
    PATH "/advance"

    WSMETHOD PUT ToCheck ;
    DESCRIPTION "Envia prestacao de contas para conferencia" ;
    WSSYNTAX "/expenses/{expenseID}/{isTravel}" ;
    PATH "/expenses/{expenseID}/{isTravel}"

    WSMETHOD PUT Update ; 
    DESCRIPTION "Atualiza item da prestacao de contas" ;
    WSSYNTAX "/expenses/{expenseID}/{isTravel}/items/{itemID}" ;
    PATH "/expenses/{expenseID}/{isTravel}/items/{itemID}"

    WSMETHOD PUT Checked;
    DESCRIPTION "Aprova a prestação de contas" ;
    WSSYNTAX "/checked/{expenseID}/{isTravel}" ;
    PATH "/checked/{expenseID}/{isTravel}"

    WSMETHOD DELETE Acc ; 
    DESCRIPTION "Exclui prestacao de contas e item" ;
    WSSYNTAX "/expenses/{expenseID}/{isTravel}" ;
    PATH "/expenses/{expenseID}/{isTravel}"

    WSMETHOD DELETE Item ; 
    DESCRIPTION "Exclui item da prestacao de contas" ;
    WSSYNTAX "/expenses/{expenseID}/{isTravel}/items/{itemID}" ;
    PATH "/expenses/{expenseID}/{isTravel}/items/{itemID}"

    WSMETHOD DELETE Attch ; 
    DESCRIPTION "Exclui anexo da despesa" ;
    WSSYNTAX "/expenses/{expenseID}/{isTravel}/items/{itemID}/attachment" ;
    PATH "/expenses/{expenseID}/{isTravel}/items/{itemID}/attachment"

END WSRESTFUL

/*/--------------------------------------------------------------------------/*/
WSMETHOD GET Main WSRECEIVE order,page,pageSize,fields,international,departure_date,arrival_date,travelNumber,travel,status,open,searchKey WSSERVICE WSFin677
    Local aFilter   As Array
    Local cJson     As Character
    Local cSign     As Character
    Local lRet      As Logical
    Local oExpenses As Object

    Default Self:order          := .F.
    Default Self:page           := 1
    Default Self:pageSize       := 10
    Default Self:departure_date := ""
    Default Self:arrival_date   := ""
    Default Self:travelNumber   := ""
    Default Self:status         := ""
    Default Self:searchKey      := ""

    oExpenses     := JsonObject():New()

    // Converte parametro fields em array 
    If ValType(Self:fields) == "C"
        Self:fields   := StrToKarr(Self:fields,",")
    EndIf

    /* Estrutura do array para filtro:
       pos1 - Campo da tabela 
       pos2 - Valor a ser filtrado na query
       pos3 - Operador logico
       pos4 - Usada pelo searchKey, campos considerados na busca
       obs1: Todos os valores em String
    */
    aFilter       := {}
    If ValType(Self:international) == "L"
        cSign := If(Self:international," <> "," = ")
        Aadd(aFilter,{"FLF_NACION","'1'",cSign})
    EndIf
    If !Empty(Self:departure_date)
        Aadd(aFilter,{"FLF_DTINI", "'" + Self:departure_date + "'", " >= "})
    EndIf
    If !Empty(Self:arrival_date)
        Aadd(aFilter,{"FLF_DTFIM", "'" + Self:arrival_date + "'", " <= "})
    EndIf
    If !Empty(Self:travelNumber)
        Aadd(aFilter,{"FL5_VIAGEM", "'" + Self:travelNumber + "'", " = "})
    EndIf
    If ValType(Self:travel) == "L"
        cSign := If(Self:travel," <> "," = ")
        Aadd(aFilter,{"FLF_TIPO","'2'",cSign})
    EndIf
    If !Empty(Self:status)
        Aadd(aFilter,{"FLF_STATUS", "'" + Self:status + "'", " = "})
        
        If (Self:status == "2")
            aFilter[Len(aFilter)][2] := "('2', '3', '4')"
            aFilter[Len(aFilter)][3] := " IN"
        EndIf 

        If (Self:status == "8")
            aFilter[Len(aFilter)][2] := "('8', '9')"
            aFilter[Len(aFilter)][3] := " IN"
        EndIf

    EndIf
    If ValType(Self:open) == "L"
        If Self:open
            Aadd(aFilter,{"FLF_STATUS","('1','5')"," IN"})
        Else
            Aadd(aFilter,{"FLF_STATUS","('1','5')"," NOT IN"})
        EndIf
    EndIf

    If !Empty(Self:searchKey)
        Aadd(aFilter,{"SEARCHKEY", "'%" + Self:searchKey + "%' ", " LIKE ",{"FLF_PRESTA","FL5_DESDES","A1_NOME","FL5_VIAGEM"}})
    EndIf

    lRet := LoadXpense(Self:order,Self:page,Self:pageSize,Self:fields,aFilter,@oExpenses)

    cJson := FWJsonSerialize(oExpenses, .F., .F., .T.)
    ::SetResponse(cJson)

Return lRet


/*/--------------------------------------------------------------------------/*/
WSMETHOD GET Checked WSRECEIVE page, pageSize, fields, searchKey WSSERVICE WSFin677
    Local aFilter   As Array
    Local cJson     As Character
    Local lRet       As Logical
    Local oExpenses  As Object

    Default Self:page     := 1
    Default Self:pageSize := 10
    Default Self:searchKey:= ""

    oExpenses     := JsonObject():New()
    
    If ValType(Self:fields) == "C"
        Self:fields   := StrToKarr(Self:fields, ",")
    EndIf

    aFilter       := {}
    If !Empty(Self:searchKey)
        Aadd(aFilter,{"SEARCHKEY", "'%" + Self:searchKey + "%' ", " LIKE ",{"FLF_PRESTA","FLF_PARTIC"}})
    EndIf

    lRet := LoadXpense( , Self:page, Self:pageSize, Self:fields, aFilter, @oExpenses, .T. )
    
    cJson := FWJsonSerialize(oExpenses, .F., .F., .T.)
    ::SetResponse(cJson)

Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD GET Acc PATHPARAM expenseID,isTravel WSRECEIVE fields WSSERVICE WSFin677

    Local aFilter   As Array
    Local cJson     As Character
    Local cSign     As Character
    Local lRet      As Logical
    Local oExpenses As Object

    Default Self:expenseID := ""
    Default Self:isTravel := ""

    oExpenses     := JsonObject():New()
    aFilter       := {}

    // Converte parametro fields em array 
    If ValType(Self:fields) == "C"
        Self:fields   := StrToKarr(Self:fields,",")
    EndIf

    If "travel" $ Self:isTravel
        cSign := " <> "
    ElseIf "detached" $ Self:isTravel
        cSign := " = "
    EndIf

    Aadd(aFilter,{"FLF_PRESTA", "'" + Self:expenseID + "'", " = "})
    Aadd(aFilter,{"FLF_TIPO","'2'",cSign})

    lRet := LoadXpense(,Self:page,Self:pageSize,Self:fields,aFilter,@oExpenses)

    cJson := FWJsonSerialize(oExpenses, .F., .F., .T.)
    ::SetResponse(cJson)

Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD GET Items PATHPARAM expenseID,isTravel WSRECEIVE page,pageSize,fields WSSERVICE WSFin677

    Local cJson     As Character
    Local lRet      As Logical
    Local oExpenses As Object

    Default Self:page           := 1
    Default Self:pageSize       := 10

    oExpenses     := JsonObject():New()

    // Converte parametro fields em array 
    If ValType(Self:fields) == "C"
        Self:fields   := StrToKarr(Self:fields,",")
    EndIf
    If "travel" $ Self:isTravel
        Self:isTravel := "1"
    ElseIf "detached" $ Self:isTravel
        Self:isTravel := "2"
    EndIf

    lRet := LoadItems(Self:page,Self:pageSize,Self:fields,@oExpenses,Self:expenseID,Self:isTravel)

    cJson := FWJsonSerialize(oExpenses, .F., .F., .T.)
    ::SetResponse(cJson)

Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD GET CheckItems PATHPARAM expenseID, isTravel WSRECEIVE page, pageSize, fields WSSERVICE WSFin677
    Local cJson     As Character
    Local lRet      As Logical
    Local oExpenses As Object

    Default Self:page           := 1
    Default Self:pageSize       := 10

    oExpenses     := JsonObject():New()

    // Converte parametro fields em array 
    If ValType( Self:fields ) == "C"
        Self:fields   := StrToKarr( Self:fields, "," )
    EndIf

    If "travel" $ Self:isTravel
        Self:isTravel := "1"
    ElseIf "detached" $ Self:isTravel
        Self:isTravel := "2"
    EndIf

    lRet := LoadItems( Self:page, Self:pageSize, Self:fields, @oExpenses, Self:expenseID, Self:isTravel, .T. )

    cJson := FWJsonSerialize( oExpenses, .F., .F., .T. )
    ::SetResponse( cJson )
Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD GET Attch PATHPARAM expenseID, isTravel, itemID WSSERVICE WSFin677
    Local oJsonRet  := NIL
    Local lRet      := .T.
    Local cJson     := ''

    oJsonRet     := JsonObject():New()

    If "travel" $ Self:isTravel
        Self:isTravel := "1"
    ElseIf "detached" $ Self:isTravel
        Self:isTravel := "2"
    EndIf

    lRet   := LoadAttach( Self:expenseID, Self:isTravel, Self:itemID, @oJsonRet )

    cJson := FWJsonSerialize( oJsonRet, .F., .F., .T. )
    ::SetResponse( cJson )
Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD GET CheckAttch PATHPARAM expenseID, isTravel, itemID WSSERVICE WSFin677
    Local oJsonRet  := NIL
    Local lRet      := .T.
    Local cJson     := ''

    oJsonRet     := JsonObject():New()

    If "travel" $ Self:isTravel
        Self:isTravel := "1"
    ElseIf "detached" $ Self:isTravel
        Self:isTravel := "2"
    EndIf

    lRet := LoadAttach( Self:expenseID, Self:isTravel, Self:itemID, @oJsonRet, .T. )

    cJson := FWJsonSerialize( oJsonRet, .F., .F., .T. )
    ::SetResponse( cJson )

    FreeObj( oJsonRet )
Return lRet


/*/--------------------------------------------------------------------------/*/
WSMETHOD GET Clients WSRECEIVE page,pageSize,searchKey WSSERVICE WSFin677
    
    Local lRet      As Logical
    Local oClients  As Object

    // - Parametros enviados pela URL - QueryString
    Default Self:page     := 1
    Default Self:pageSize := 10
    Default Self:searchKey := ""

    oClients    := JsonObject():New()
    
    // Monta objeto do response
    lRet := LoadClients(Self:page,Self:pageSize,Self:searchKey,@oClients)
    
    cJson := FWJsonSerialize(oClients, .F., .F., .T.)
    ::SetResponse(cJson)
    
Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD GET CostCenters WSRECEIVE page,pageSize,searchKey,default WSSERVICE WSFin677
    
    Local lRet      As Logical
    Local oCosts    As Object

    // - Parametros enviados pela URL - QueryString
    Default Self:page      := 1
    Default Self:pageSize  := 10
    Default Self:searchKey := ""
    Default Self:default   := .T.

    oCosts    := JsonObject():New()
    
    // Monta objeto do response
    lRet := LoadCC(Self:page,Self:pageSize,Self:searchKey,Self:default,@oCosts)
    
    cJson := FWJsonSerialize(oCosts, .F., .F., .T.)
    ::SetResponse(cJson)
    
Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD GET Currencies WSRECEIVE page,pageSize WSSERVICE WSFin677
    
    Local lRet      As Logical
    Local oCurrence As Object

    // - Parametros enviados pela URL - QueryString
    Default Self:page     := 1
    Default Self:pageSize := 10

    oCurrence := JsonObject():New()
    
    // Monta objeto do response
    lRet := Currencies(@oCurrence,Self:page,Self:pageSize)
    
    cJson := FWJsonSerialize(oCurrence, .F., .F., .T.)
    ::SetResponse(cJson)
    
Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD GET Destinations WSRECEIVE page,pageSize,international,searchKey WSSERVICE WSFin677
    
    Local lRet           As Logical
    Local oDestinations  As Object

    // - Parametros enviados pela URL - QueryString
    Default Self:page          := 1
    Default Self:pageSize      := 10
    Default Self:international := .F.
    Default Self:searchKey     := ""

    oDestinations    := JsonObject():New()

    // Monta objeto do response
    lRet := Locations(Self:page,Self:pageSize,Self:international,Self:searchKey,@oDestinations)
    
    cJson := FWJsonSerialize(oDestinations, .F., .F., .T.)
    ::SetResponse(cJson)    
Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD GET XpenseType WSRECEIVE page,pageSize,searchKey,dDepartDate WSSERVICE WSFin677
    
    Local lRet         As Logical
    Local oItemsTypes  As Object
    
    Default Self:page       := 1
    Default Self:pageSize   := 10
    Default Self:searchKey := ""
    Default Self:dDepartDate := dDatabase    
    
    oItemsTypes     := JsonObject():New()

    // Monta objeto do response
    lRet := XpenseType(Self:page,Self:pageSize,Self:searchKey,@oItemsTypes,Self:dDepartDate)
    
    cJson := FWJsonSerialize(oItemsTypes, .F., .F., .T.)
    ::SetResponse(cJson)    
Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD GET isApprover WSSERVICE WSFin677
    
    Local lRet         As Logical
    Local oJSONResp  As Object
     
    oJSONResp := JsonObject():New()

    // Monta objeto do response
    lRet := isApprover( @oJSONResp )
    
    cJson := FWJsonSerialize( oJSONResp, .F., .F., .T. )
    ::SetResponse(cJson) 

Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD POST Acc WSSERVICE WSFin677

    Local cBody     As Character
    Local cJson  As Character
    Local lRet      As Logical
    Local oExpenses As Object

    cBody 	   := ::GetContent()
    oExpenses  := JsonObject():New()

    lRet := NewXpense(@oExpenses,cBody)

    cJson := FWJsonSerialize(oExpenses, .F., .F., .T.)
    ::SetResponse(cJson)

Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD POST Xpenses PATHPARAM expenseID,isTravel WSSERVICE WSFin677

    Local cBody     As Character
    Local cJson     As Character
    Local cTipo     As Character
    Local lRet      As Logical
    Local oExpenses As Object

    cBody 	   := ::GetContent()
    oExpenses  := JsonObject():New()

    cTipo := ""
    If ("travel" $ Self:isTravel)
        cTipo := "1"
    ElseIf "detached" $ Self:isTravel
        cTipo := "2"
    EndIf
    lRet := NewItem(@oExpenses,cBody,Self:expenseID,cTipo)

    cJson := FWJsonSerialize(oExpenses, .F., .F., .T.)
    ::SetResponse(cJson)

Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD POST Attch PATHPARAM expenseID,isTravel,itemID WSSERVICE WSFin677

    Local aUser     As Array
    Local aSeek     As Array
    Local cJson     As Character
    Local cBody     As Character
    Local lRet      As Logical
    Local oModel677 As Object
    Local oModelFLE As Object
    Local oJsonTmp  As Object
    Local oMessages As Object

    oJsonTmp     := JsonObject():New()
    oMessages    := JsonObject():New()
    cBody 	     := ::GetContent()

    If "travel" $ Self:isTravel
        Self:isTravel := "1"
    ElseIf "detached" $ Self:isTravel
        Self:isTravel := "2"
    EndIf

    lRet   := .T.

    If FINXUser(__cUserID,@aUser,.F.)
        cCatch   := oJsonTmp:FromJSON(cBody)
        If cCatch == Nil
            dbSelectArea("FLE")
            dbSetOrder(1)
            dbSelectArea("FLF")
            dbSetOrder(1)
            If FLE->(dbSeek(xFilial("FLE") + Self:isTravel + Self:expenseID + aUser[1] + Self:itemID))
                FLF->(dbSeek(xFilial("FLF") + Self:isTravel + Self:expenseID + aUser[1]))
                oModel677:= FWLoadModel("FINA677")
                oModel677:SetOperation(MODEL_OPERATION_UPDATE)
                F677LoadMod(oModel677,MODEL_OPERATION_UPDATE)
                oModel677:Activate()

                oModelFLE:= oModel677:GetModel("FLEDETAIL")

                If (oModel677:GetValue("FLFMASTER","FLF_STATUS") == "1") .OR. oModel677:GetValue("FLFMASTER","FLF_STATUS") == "5"  
                    aSeek := { {"FLE_FILIAL", xFilial("FLE")},; 
                             {"FLE_TIPO", Self:isTravel},; 
                             {"FLE_PRESTA", Self:expenseID},; 
                             {"FLE_PARTIC", aUser[1]},;
                             {"FLE_ITEM", Self:itemID } }
                    oModelFLE:SeekLine( aSeek )
            
                    oModelFLE:LoadValue("FLE_FILE",oJsonTmp["name"])
                    
                    aImg := F677ImgApp(3,oModel677,oJsonTmp["content"])
                    If Len(aImg) > 0 .and. aImg[1] == "400"
                        oMessages["code"] 	:= aImg[1]
                        oMessages["message"]	:= "Bad Request"
                        oMessages["detailMessage"] := aImg[2]
                        lRet := .F.
                    Else
                        oJsonTmp := JsonObject():New()  // Retorna objeto vazio se deu tudo certo
                        oJsonTmp["name"] := aImg[2]
                        
                        If oModel677:GetValue("FLFMASTER","FLF_STATUS") == "5"
                            AltStatus()
                        EndIf
                        
                    EndIf
                Else
                    oMessages["code"] 	:= "403"
                    oMessages["message"]	:= "Forbidden"
                    oMessages["detailMessage"] := STR0009 //"Status da prestacao de contas nao permite alteracao."
                    lRet := .F.
                EndIf
                oModel677:DeActivate()
                oModel677:Destroy()
                oModel677 := NIL
            Else
                oMessages["code"] 	:= "404"
                oMessages["message"]	:= "Not Found"
                oMessages["detailMessage"] := "Nenhuma despesa encontrada para gravar o anexo enviado."   // "N?o foi encontrado anexo para essa despesa."
                lRet := .F.
            EndIf
        Else
            oMessages["code"] 	:= "400"
            oMessages["message"]	:= "Bad Request"
            oMessages["detailMessage"] := cCatch
            lRet := .F.
        EndIf
    Else
        oMessages["code"] 	:= "403"
        oMessages["message"]	:= "Forbidden"
        oMessages["detailMessage"] := STR0003   // "Usu rio inativo no sistema ou n?o autorizado para esta opera‡?o."
        lRet := .F.
    EndIf

    If !lRet
        oMessages["detailMessage"] := EncodeUTF8(oMessages["detailMessage"])
        oJsonTmp := oMessages
        SetRestFault(Val(oMessages["code"]),oMessages["detailMessage"])
    EndIf

    cJson := FWJsonSerialize(oJsonTmp, .F., .F., .T.)
    ::SetResponse(cJson)

Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD POST Advance WSSERVICE WSFin677
    Local cBody     As Character
    Local cJson     As Character
    Local lRet      As Logical
    Local oExpenses As Object

    cBody 	   := ::GetContent()
    oExpenses  := JsonObject():New()

    lRet := NewAdvance( @oExpenses, cBody )

    If lRet
        cJson := FWJsonSerialize( oExpenses, .F., .F., .T. )
        ::SetResponse( cJson )
    EndIf
    
Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD PUT ToCheck PATHPARAM expenseID,isTravel  WSSERVICE WSFin677

    Local aUser     As Array
    Local cTipo     As Character
    Local cIDFLF    As Character
    Local cLog      As Character
    Local lRet      As Logical
    Local oExpenses As Object
    Local oMessages As Object

    oExpenses  := JsonObject():New()
    oMessages  := JsonObject():New()

    cIDFLF := Self:expenseID
    cTipo  := ""
    lRet   := .T.

    If "travel" $ Self:isTravel
        cTipo := "1"
    ElseIf "detached" $ Self:isTravel
        cTipo := "2"
    EndIf

    If FINXUser(__cUserID,@aUser,.F.)
        oJsonTmp := JsonObject():New()
        
        dbSelectArea("FLE")
        FLE->(dbSetOrder(1))

        dbSelectArea("FLF")
        FLF->(dbSetOrder(1))

        If FLF->(dbSeek(xFilial("FLF") + cTipo + cIDFLF + aUser[1]))
            // Envia para conferencia
            F677ENVCON(@cLog)
            If !Empty(cLog)
                oMessages["code"] 	:= "400"
                oMessages["message"]	:= "Bad Request"
                oMessages["detailMessage"] := cLog
                lRet := .F.
            EndIf
        EndIf
    Else
        oMessages["code"] 	:= "403"
        oMessages["message"]	:= "Forbidden"
        oMessages["detailMessage"] := STR0003   // "Usu rio inativo no sistema ou n?o autorizado para esta opera‡?o."
        lRet := .F.
    EndIf

    If !lRet
        oMessages["detailMessage"] := EncodeUTF8(oMessages["detailMessage"])
        oExpenses["messages"] := oMessages
        SetRestFault(Val(oMessages["code"]),oMessages["detailMessage"])
    EndIf

    cJson := FWJsonSerialize(oExpenses, .F., .F., .T.)
    ::SetResponse(cJson)

Return lRet


/*/--------------------------------------------------------------------------/*/
WSMETHOD PUT Checked PATHPARAM expenseID,isTravel  WSSERVICE WSFin677

    Local aUser     As Array
    Local cType     As Character
    Local cCatch    As Character
    Local cIDFLN    As Character
    Local cBody     As Character
    Local lRet      As Logical
    Local oExpenses As Object
    Local oMessages As Object
    Local oJsonTmp  As Object

    Local cAction As Character
    Local cReason as Character
    Local cTpAprov as Character
    
    cBody 	   := ::GetContent()

    oExpenses  := JsonObject():New()
    oMessages  := JsonObject():New()
    
    cIDFLN := Self:expenseID
    cType  := ""
    cAction := ""
    cReason := ""
    cTpAprov := ""
    lRet   := .T.

    If "travel" $ Self:isTravel
        cType := "1"
    ElseIf "detached" $ Self:isTravel
        cType := "2"
    EndIf

    If FINXUser(__cUserID, @aUser, .F.)
        oJsonTmp := JsonObject():New()
        cCatch   := oJsonTmp:FromJSON(cBody)
        If cCatch == Nil    

            If oJsonTmp["action"] == "approve"
                cAction := 'A'
            else
                cAction := 'R'
                cReason := DecodeUTF8( oJsonTmp["reason"] )
            endif
            
            dbSelectArea("FLN")
            FLN->(dbSetOrder(1)) //FLN_FILIAL+FLN_TIPO+FLN_PRESTA+FLN_PARTIC+FLN_SEQ+FLN_TPAPR

            If FLN->(dbSeek(xFilial("FLN") + cType + cIDFLN ))
                If FLN->FLN_APROV == aUser[1]
                    cTpAprov := 'O'
                EndIf
                
                If Empty(cTpAprov)
                    RD0->(DbSetOrder(1)) // Filial + Participante
                    If RD0->(DbSeek( xFilial("RD0") + FLN->FLN_PARTIC ))
                        If aUser[1] == RD0->RD0_APROPC
                            cTpAprov := 'O'
                        Else
                            cTpAprov := 'S'
                        EndIf
                    EndIf 
                EndIf

                F677APRGRV(cAction, cTpAprov, aUser, FLN->FLN_TIPO, FLN->FLN_PRESTA, FLN->FLN_PARTIC, FLN->FLN_SEQ, cReason, '1',)

                If FLN->(dbSeek(xFilial("FLN") + cType + cIDFLN ))
                    If FLN->FLN_STATUS == '1'
                        oMessages["code"] 	:= "400"
                        oMessages["message"]	:= "Bad Request"
                        oMessages["detailMessage"] := STR0010 //"A operação de aprovação não foi concluída."
                        lRet := .F.
                    else
                        oExpenses["id"] := cIDFLN
                    EndIf
                EndIf
            EndIf
        Else
            oMessages["code"] 	:= "400"
            oMessages["message"]	:= "Bad Request"
            oMessages["detailMessage"] := cCatch
            lRet := .F.
        ENDIF
    Else
        oMessages["code"] 	:= "403"
        oMessages["message"]	:= "Forbidden"
        oMessages["detailMessage"] := STR0003   // "Usu rio inativo no sistema ou n?o autorizado para esta opera‡?o."
        lRet := .F.
    EndIf

    If !lRet
        oMessages["detailMessage"] := EncodeUTF8(oMessages["detailMessage"])
        oExpenses["messages"] := oMessages
        SetRestFault(Val(oMessages["code"]),oMessages["detailMessage"])
    EndIf

    cJson := FWJsonSerialize(oExpenses, .F., .F., .T.)
    ::SetResponse(cJson)

Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD PUT Update PATHPARAM expenseID,isTravel,itemID  WSSERVICE WSFin677

    Local cBody     As Character
    Local cTipo     As Character
    Local lRet      As Logical
    Local oExpenses As Object

    cBody 	   := ::GetContent()
    oExpenses  := JsonObject():New()

    cTipo := ""
    If ("travel" $ Self:isTravel)
        cTipo := "1"
    ElseIf "detached" $ Self:isTravel
        cTipo := "2"
    EndIf
    lRet := UpdXpense(@oExpenses,cBody,Self:expenseID,cTipo,Self:itemID)

    cJson := FWJsonSerialize(oExpenses, .F., .F., .T.)
    ::SetResponse(cJson)

Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD DELETE Acc PATHPARAM expenseID,isTravel WSSERVICE WSFin677

    Local cTipo     As Character
    Local lRet      As Logical
    Local oResponse As Object

    oResponse  := JsonObject():New()

    cTipo := ""
    If "travel" $ Self:isTravel
        cTipo := "1"
    ElseIf "detached" $ Self:isTravel
        cTipo := "2"
    EndIf
    lRet := DelXpense(@oResponse,Self:expenseID,cTipo)    

    cJson := FWJsonSerialize(oResponse, .F., .F., .T.)
    ::SetResponse(cJson)

Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD DELETE Item PATHPARAM expenseID,isTravel,itemID WSSERVICE WSFin677

    Local cTipo     As Character
    Local lRet      As Logical
    Local oResponse As Object

    oResponse  := JsonObject():New()

    cTipo := ""
    If "travel" $ Self:isTravel
        cTipo := "1"
    ElseIf "detached" $ Self:isTravel
        cTipo := "2"
    EndIf
    lRet := DelItem(@oResponse,Self:expenseID,cTipo,Self:itemID)

    cJson := FWJsonSerialize(oResponse, .F., .F., .T.)
    ::SetResponse(cJson)

Return lRet

/*/--------------------------------------------------------------------------/*/
WSMETHOD DELETE Attch PATHPARAM expenseID,isTravel,itemID WSSERVICE WSFin677

    Local aUser     As Array
    Local aImg      As Array
    Local aSeek     As Array
    Local cJson     As Character
    Local lRet      As Logical
    Local oModel677 As Object
    Local oModelFLE As Object
    Local oJsonRet  As Object
    Local oMessages As Object

    oJsonRet     := JsonObject():New()
    oMessages    := JsonObject():New()

    If "travel" $ Self:isTravel
        Self:isTravel := "1"
    ElseIf "detached" $ Self:isTravel
        Self:isTravel := "2"
    EndIf

    lRet   := .T.

    If FINXUser(__cUserID,@aUser,.F.)
        dbSelectArea("FLE")
        dbSetOrder(1)
        dbSelectArea("FLF")
        dbSetOrder(1)
        If FLE->(dbSeek(xFilial("FLE") + Self:isTravel + Self:expenseID + aUser[1] + Self:itemID))
            FLF->(dbSeek(xFilial("FLF") + Self:isTravel + Self:expenseID + aUser[1]))
            oModel677:= FWLoadModel("FINA677")
            oModel677:SetOperation(MODEL_OPERATION_UPDATE)  // Update, pois nao estamos deletando o registro
            F677LoadMod(oModel677,MODEL_OPERATION_UPDATE)
            oModel677:Activate()
            oModelFLE:= oModel677:GetModel("FLEDETAIL")
           aSeek := { {"FLE_FILIAL", xFilial("FLE")},; 
                      {"FLE_TIPO", Self:isTravel},; 
                      {"FLE_PRESTA", Self:expenseID},; 
                      {"FLE_PARTIC", aUser[1]},;
                      {"FLE_ITEM", Self:itemID } }
            oModelFLE:SeekLine( aSeek )
            aImg := F677ImgApp(5,oModel677)
            If Len(aImg) > 0 .and. aImg[1] == "202"
                oJsonRet["message"]    := aImg[2]
            ElseIf aImg[1] <> Nil
                oMessages["code"] 	:= aImg[1]
                oMessages["message"]	:= "Bad Request"
                oMessages["detailMessage"] := aImg[2]
                lRet := .F.
            Else
                oMessages["code"] 	:= "404"
                oMessages["message"]	:= "Not Found"
                oMessages["detailMessage"] := STR0008 //"Nao foi encontrado anexo para essa despesa."   // "N?o foi encontrado anexo para essa despesa."
                lRet := .F.
            EndIf
            oModel677:DeActivate()
            oModel677:Destroy()
            oModel677 := NIL
        EndIf
    Else
        oMessages["code"] 	:= "403"
        oMessages["message"]	:= "Forbidden"
        oMessages["detailMessage"] := STR0003   // "Usu rio inativo no sistema ou n?o autorizado para esta opera‡?o."
        lRet := .F.
    EndIf

    If !lRet
        oJsonRet := oMessages
        SetRestFault(Val(oMessages["code"]),oMessages["detailMessage"])
    EndIf

    cJson := FWJsonSerialize(oJsonRet, .F., .F., .T.)
    ::SetResponse(cJson)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadXpense
    Carrega prestacao de contas na tela principal
    @author Igor Sousa do Nascimento
    @since 23/08/2017
/*/
//-------------------------------------------------------------------
Static Function LoadXpense(lAsc,nPage,nPageSize,aFields,aFilter,oExpenses, lChecked)

    Local aUser        As Array
    Local aDePara      As Array
    Local aBillInfo    As Array
    Local cTmp         As Character
    Local cQry         As Character
    Local cBranchFLF   As Character
    Local cBranchSA1   As Character
    Local cBranchCTT   As Character
    Local cBranchFO7   As Character
    Local cOrderBy     As Character
    Local cFilter      As Character
    Local cFilterSub   As Character
    Local cSGBD        As Character
    Local cApprovers   As Character
    Local cInApprovers As Character 
    Local lRet         As Logical
    Local nInitPage    As Numeric
    Local nI           As Numeric
    Local nAt  	       As Numeric
    Local nT           As Numeric
    Local oJsonTmp     As Object
    Local oMessages    As Object

    Default lAsc      := .F.
    Default nPage     := 1
    Default nPageSize := 10
    Default aFields   := { "id","client","reason","destination",;
                           "travel","travelNumber","departure_date","arrival_date",;
                           "status","balances","balances.advance_money","reason_for_refusal",;
                           "company_billing_percent","cc_code","cc_description","financial" }
    Default aFilter   := {}
    Default oExpenses := JsonObject():New()
    Default lChecked  := .F.

    lRet       := .T.
    // Trata response negativo
    oMessages  := JsonObject():New()
    aDePara    := {}

    aBillInfo := { "due_date", "posting_date", "payment_bank", "payment_agency", 'payment_account' }

    If FINXUser(__cUserID,@aUser,.F.)

        cTmp       := CriaTrab(,.F.)
        cQry       := ""
        cSGBD      := Alltrim(Upper(TCGetDB()))
        cBranchFLF := xFilial( "FLF" )
        cBranchSA1 := xFilial( "SA1" )
        cBranchCTT := xFilial( "CTT" )
        cBranchFO7 := xFilial( "FO7" )

        cApprovers  := GetApprovers( aUser[1] )
        cInApprovers := FormatIn( cApprovers, "," )

        If !lChecked
            cFilter    := "FLF.FLF_PARTIC = '" + aUser[1] + "'"
            cFilterSub := "SUBFLF.FLF_PARTIC = '" + aUser[1] + "'"
        else
            cFilter    := ''
            cFilterSub := ''
        EndIf

        If !Empty(aFilter)
            For nI := 1 to Len(aFilter)
                If !Empty( cFilter)
                    cFilter += " AND "
                    cFilterSub += " AND "
                ENDIF

                Do Case
                    Case aFilter[nI,1] == "SEARCHKEY"  // Filtro coringa em campos especificos
                        cFilter += "("
                        cFilterSub += "("
                        For nT := 1 to Len(aFilter[nI,4])   // Campos do searchKey
                            nAt := At("_",aFilter[nI,4,nT])
                            If nAt < 4
                                cFilter += "S"+SubStr(aFilter[nI,4,nT],1,nAt-1) +"."+ aFilter[nI,4,nT] + aFilter[nI,3] + AllTrim(aFilter[nI,2])
                                cFilterSub += "SUBS"+SubStr(aFilter[nI,4,nT],1,nAt-1) +"."+ aFilter[nI,4,nT] + aFilter[nI,3] + AllTrim(aFilter[nI,2])
                            Else
                                cFilter += SubStr(aFilter[nI,4,nT],1,nAt-1) +"."+ aFilter[nI,4,nT] + aFilter[nI,3] + AllTrim(aFilter[nI,2])
                                cFilterSub += "SUB"+SubStr(aFilter[nI,4,nT],1,nAt-1) +"."+ aFilter[nI,4,nT] + aFilter[nI,3] + AllTrim(aFilter[nI,2])
                            EndIf
                            cFilter += If(nT < Len(aFilter[nI,4]), " OR ", "")
                            cFilterSub += If(nT < Len(aFilter[nI,4]), " OR ", "")
                        Next nT
                        cFilter += ")"
                        cFilterSub += ")"
                    Otherwise
                        nAt := At("_",aFilter[nI,1])
                        cFilter += SubStr(aFilter[nI,1],1,nAt-1) +"."+ aFilter[nI,1] + aFilter[nI,3] + aFilter[nI,2]
                        cFilterSub += "SUB"+SubStr(aFilter[nI,1],1,nAt-1) +"."+ aFilter[nI,1] + aFilter[nI,3] + aFilter[nI,2]
                EndCase
            Next nI
        EndIf

        cOrderBy   := If(lAsc,"FLF_DTINI ASC","FLF_DTINI DESC")
        // Trata selecao de paginas
        nInitPage  := (nPage - 1) * (nPageSize)  

        /*--------------------------------------------------------------------------
         Query responsavel por trazer toda a amarracao das prestacoes x viagens 
        --------------------------------------------------------------------------*/
        cQry += "SELECT "
        // Accountability Header
        cQry +=     "FLF.FLF_FILIAL, FLF.FLF_PRESTA, FLF.FLF_DTINI, FLF.FLF_DTFIM, FLF.FLF_NACION, " 
        cQry +=     "FLF.FLF_CLIENT, FLF.FLF_LOJA, FLF.FLF_VIAGEM, FLF.FLF_TIPO, FLF.FLF_PARTIC, " 
        cQry +=     "FLF.FLF_STATUS, FLF.FLF_DTINI, FLF.FLF_DTFIM, FLF.FLF_NACION, FLF.FLF_FATEMP, "
        cQry +=     "FLF.FLF_TDESP1, FLF.FLF_TDESP2, FLF.FLF_TDESP3, " 
        cQry +=     "FLF.FLF_TVLRE1, FLF.FLF_TVLRE2, FLF.FLF_TVLRE3, " 
        cQry +=     "FLF.FLF_TDESC1, FLF.FLF_TDESC2, FLF.FLF_TDESC3, "
        cQry +=     "FLF.FLF_TADIA1, FLF.FLF_TADIA2, FLF.FLF_TADIA3, " 
        cQry +=     "FLF.FLF_MOTVFL, FLF.FLF_OBCONF, FLF.R_E_C_N_O_ AS IDFLF, "
        // Travels
        cQry +=     "COALESCE(FL5.FL5_FILIAL, ' ') AS FL5_FILIAL, COALESCE(FL5.FL5_VIAGEM, ' ') AS FL5_VIAGEM, "
        cQry +=     "COALESCE(FL5.FL5_NACION, ' ') AS FL5_NACION, COALESCE(FL5.FL5_STATUS, ' ') AS FL5_STATUS, "
        cQry +=     "COALESCE(FL5.FL5_CODORI, ' ') AS FL5_CODORI, COALESCE(FL5.FL5_DESORI, ' ') AS FL5_DESORI, "
        cQry +=     "COALESCE(FL5.FL5_CODDES, ' ') AS FL5_CODDES, COALESCE(FL5.FL5_DESDES, ' ') AS FL5_DESDES, "
        cQry +=     "COALESCE(FL5.FL5_DTINI , ' ') AS FL5_DTINI, COALESCE(FL5.FL5_DTFIM , ' ') AS FL5_DTFIM, "
        cQry +=     "FL5.D_E_L_E_T_, "
        // Client
        cQry +=     "COALESCE(SA1.A1_NOME, ' ') AS A1_NOME, "
        // Cost Centers
        cQry +=     "COALESCE(CTT.CTT_CUSTO, ' ') AS CTT_CUSTO, COALESCE(CTT.CTT_DESC01, ' ') AS CTT_DESC01, "
        // Financial
        cQry +=     "COALESCE(FO7_FILIAL, ' ') AS FO7_FILIAL, COALESCE(FO7_CODIGO, ' ') AS FO7_CODIGO, "
        cQry +=     "COALESCE(FO7_PREFIX, ' ') AS FO7_PREFIX, COALESCE(FO7_TITULO, ' ') AS FO7_TITULO, "
        cQry +=     "COALESCE(FO7_PARCEL, ' ') AS FO7_PARCEL, COALESCE(FO7_TIPO, ' ') AS FO7_TIPO, "
        cQry +=     "COALESCE(FO7_DTBAIX, ' ') AS FO7_DTBAIX, COALESCE(FO7_RECPAG, ' ') AS FO7_RECPAG "
         // Checked
        If lChecked
            cQry += ", FLN.FLN_TIPO, FLN.FLN_PRESTA, FLN.FLN_PARTIC, FLN.FLN_SEQ, FLN.FLN_APROV "
        EndIf

        cQry += "FROM " +RetSQLName("FLF")+ " FLF "
        If lChecked
            cQry += "INNER JOIN " + RetSqlName("FLN") + " FLN "
            cQry += "ON FLN.FLN_FILIAL = FLF.FLF_FILIAL "
            cQry += "AND FLN.FLN_TIPO = FLF.FLF_TIPO "
            cQry += "AND FLN.FLN_PRESTA = FLF.FLF_PRESTA "
            cQry += "AND FLN.FLN_PARTIC = FLF.FLF_PARTIC "
            cQry += "AND FLN.FLN_STATUS = '1' "
            cQry += "AND FLF.FLF_STATUS = '4' "
            cQry += "AND FLN.FLN_TPAPR = '1' "
            cQry += "AND FLN.FLN_APROV IN " + cInApprovers +  " 
            cQry += "AND FLN.D_E_L_E_T_ = ' ' "
        EndIf 

        cQry +=    "LEFT JOIN " +RetSQLName("FL5")+ " FL5 "
        cQry +=    "ON FL5.FL5_FILIAL = FLF.FLF_FILIAL "
        cQry +=    "AND FL5.FL5_VIAGEM = FLF.FLF_VIAGEM "
        cQry +=    "LEFT JOIN " + RetSQLName( "FO7" ) + " FO7 "
        cQry +=    "ON FO7.FO7_FILIAL = '" + cBranchFO7 + "' "
        cQry +=    "AND FO7.FO7_TPVIAG = FLF.FLF_TIPO "
        cQry +=    "AND FO7.FO7_PRESTA = FLF.FLF_PRESTA "
        cQry +=    "AND FO7.FO7_PARTIC = FLF.FLF_PARTIC "
        cQry +=    "AND FO7.D_E_L_E_T_ = ' ' "
        cQry +=    "LEFT JOIN " +RetSQLName("SA1")+ " SA1 "
        cQry +=    "ON SA1.A1_FILIAL = '" +cBranchSA1+ "' "
        cQry +=    "AND SA1.A1_COD <> '"+Space(TamSx3("A1_COD")[1])+"' "        
        cQry +=    "AND SA1.A1_COD = FLF.FLF_CLIENT "
        cQry +=    "AND SA1.A1_LOJA = FLF.FLF_LOJA "
        cQry +=    "LEFT JOIN " +RetSQLName("CTT")+ " CTT "
        cQry +=    "ON CTT.CTT_FILIAL = '" +cBranchCTT+ "' "
        cQry +=    "AND CTT.CTT_CUSTO = FLF.FLF_CC "
        cQry +=    "AND CTT.D_E_L_E_T_  = ' ' "

        cQry += "WHERE "
        // Select Pages
        cQry +=     "FLF.R_E_C_N_O_ NOT IN "
        cQry +=     "("
        cQry +=         "SELECT "
        If !(cSGBD $ "ORACLE|POSTGRES|DB2") .and. cSGBD <> "MYSQL" // SQL e demais bancos
            cQry +=         "TOP " +cValToChar(nInitPage)+ " "
        EndIf
        cQry +=             "SUBFLF.R_E_C_N_O_ "
        cQry +=         "FROM " +RetSQLName("FLF")+ " SUBFLF "
        If lChecked
            cQry += "INNER JOIN " + RetSqlName("FLN") + " SUBFLN "
            cQry += "ON SUBFLN.FLN_FILIAL = SUBFLF.FLF_FILIAL "
            cQry += "AND SUBFLN.FLN_TIPO = SUBFLF.FLF_TIPO "
            cQry += "AND SUBFLN.FLN_PRESTA = SUBFLF.FLF_PRESTA "
            cQry += "AND SUBFLN.FLN_PARTIC = SUBFLF.FLF_PARTIC "
            cQry += "AND SUBFLN.FLN_STATUS = '1' "
            cQry += "AND SUBFLN.FLN_TPAPR = '1' "
            cQry += "AND SUBFLN.FLN_APROV IN " + cInApprovers +  " 
            cQry += "AND SUBFLN.D_E_L_E_T_ = ' ' "
        EndIf 
        cQry +=             "LEFT JOIN " +RetSQLName("FL5")+ " SUBFL5 "
        cQry +=             "ON SUBFL5.FL5_FILIAL = SUBFLF.FLF_FILIAL "
        cQry +=             "AND SUBFL5.FL5_VIAGEM = SUBFLF.FLF_VIAGEM "
        cQry +=             "LEFT JOIN " + RetSQLName( "FO7" ) + " SUBFO7 "
        cQry +=             "ON SUBFO7.FO7_FILIAL = '" + cBranchFO7 + "' "
        cQry +=             "AND SUBFO7.FO7_TPVIAG = SUBFLF.FLF_TIPO "
        cQry +=             "AND SUBFO7.FO7_PRESTA = SUBFLF.FLF_PRESTA "
        cQry +=             "AND SUBFO7.FO7_PARTIC = SUBFLF.FLF_PARTIC "
        cQry +=             "AND SUBFO7.D_E_L_E_T_ = ' ' "
        cQry +=             "LEFT JOIN " +RetSQLName("SA1")+ " SUBSA1 "
        cQry +=             "ON SUBSA1.A1_FILIAL = '" +cBranchSA1+ "' "
        cQry +=             "AND SUBSA1.A1_COD <> '"+Space(TamSx3("A1_COD")[1])+"' "
        cQry +=             "AND SUBSA1.A1_COD = SUBFLF.FLF_CLIENT "
        cQry +=             "AND SUBSA1.A1_LOJA = SUBFLF.FLF_LOJA "
        cQry +=         "WHERE "
        cQry +=             "SUBFLF.FLF_FILIAL = '" +cBranchFLF+ "' "
        IF !Empty( cFilterSub )
            cQry +=         "AND " + cFilterSub + " 
        Endif 
        cQry += " AND SUBFLF.D_E_L_E_T_ = ' ' " 
        cQry +=             "AND (SUBFL5.D_E_L_E_T_ = ' ' OR SUBFL5.D_E_L_E_T_ IS NULL) "
        If cSGBD $ "ORACLE"
            cQry +=         "AND ROWNUM < " +cValToChar(nInitPage)+ " "
        ElseIf cSGBD == "POSTGRES" .or. cSGBD == "MYSQL" .or. cSGBD == "DB2"
            cQry +=     "LIMIT " +cValToChar(nInitPage)+ " "
        EndIf
        cQry +=     ") " // End Select Pages
        cQry +=     "AND FLF.FLF_FILIAL = '" +cBranchFLF+ "' "
        IF !Empty( cFilter )
            cQry +=     "AND " + cFilter + " 
        EndIf
        cQry +=     " AND FLF.D_E_L_E_T_ = ' ' "
        cQry +=     "AND (FL5.D_E_L_E_T_ = ' ' OR FL5.D_E_L_E_T_ IS NULL) "
        cQry += "ORDER BY "
        cQry +=     "FLF." +cOrderBy+ ", FLF.R_E_C_N_O_"
        cQry := ChangeQuery(cQry)

        MPSysOpenQuery(cQry, cTmp)
        dbSelectArea(cTmp)

        oExpenses["userName"]:= aUser[2]  // Nome do usu rio logado
        oExpenses["hasNext"]:= .F.  // Propriedade para controle de paginas
        oExpenses["expenses"]:= {}  // Array para composi‡ao das presta‡oes de contas

        If !(cTmp)->(EoF())
            /*  aDePara = Array com campos do mobile e do protheus (De/Para)
                aDePara[n][1] = campo ou objeto do request
                aDePara[n][2] = se array 
                aDePara[n][3] = conteudo a ser atribuido
                aDePara[n][4] = se objeto JSON (.T. ou .F.)
                aDePara[n][5] = se propriedade de objeto JSON (.T. ou .F.)
                aDePara[n][6] = propriedades do array (olha para posicao 3)
            */

            /* TODO - sugerir a mudança de onde o nome do participante é armazenado e a troca do nome da propriedade */
            Aadd(aDePara,{"id",,"FLF_PRESTA",.F.,.F.})
            Aadd(aDePara,{"client",,,.T.,.F.})
            Aadd(aDePara,{"client.name",,"EncodeUTF8(A1_NOME)",.F.,.T.})
            Aadd(aDePara,{"client.id",,"FLF_CLIENT",.F.,.T.})
            Aadd(aDePara,{"client.unit",,"FLF_LOJA",.F.,.T.})
            Aadd(aDePara,{"client.namepartic",, "EncodeUTF8( Posicione('RD0', 1, xFilial( 'RD0' ) + FLF_PARTIC, 'RD0_NOME' ))", .F., .T. })
            Aadd(aDePara,{"reason",,"",.F.,.F.})
            Aadd(aDePara,{"destination",,,.T.,.F.})
            Aadd(aDePara,{"destination.international",,"FLF_NACION == '2'",.F.,.T.})
            Aadd(aDePara,{"destination.name",,"EncodeUTF8(FL5_DESDES)",.F.,.T.})
            Aadd(aDePara,{"destination.id",,"FL5_CODDES",.F.,.T.})
            Aadd(aDePara,{"travel",,"AllTrim(FL5_VIAGEM) <> ''",.F.,.F.})
            Aadd(aDePara,{"travelNumber",,"If(AllTrim(FL5_VIAGEM) <> '',FL5_VIAGEM,Nil)",.F.,.F.})
            Aadd(aDePara,{"departure_date",,"FLF_DTINI",.F.,.F.})
            Aadd(aDePara,{"arrival_date",,"FLF_DTFIM",.F.,.F.})
            Aadd(aDePara,{"status",,"FLF_STATUS",.F.,.F.})
            Aadd(aDePara,{"balances",,,.T.,.F.})
            Aadd(aDePara,{"balances.advance_money",.T.,"Loadvance(FL5_FILIAL,FL5_VIAGEM)",.F.,.F.,{"current","dolar","euro","date", "status"}})
            Aadd(aDePara,{"balances.refundable_expenses",,,.T.,.F.})
            Aadd(aDePara,{"balances.refundable_expenses.current",,"RetTMobile()",.F.,.T.})
            Aadd(aDePara,{"balances.refundable_expenses.dolar",,"FLF_TVLRE2",.F.,.T.})
            Aadd(aDePara,{"balances.refundable_expenses.euro",,"FLF_TVLRE3",.F.,.T.})
            Aadd(aDePara,{"balances.non_refundable_expenses",,,.T.,.F.})
            Aadd(aDePara,{"balances.non_refundable_expenses.current",,"RetTMobile() - FLF_TVLRE1",.F.,.T.})
            Aadd(aDePara,{"balances.non_refundable_expenses.dolar",,"FLF_TDESP1 - FLF_TVLRE1",.F.,.T.})
            Aadd(aDePara,{"balances.non_refundable_expenses.euro",,"FLF_TDESP1 - FLF_TVLRE1",.F.,.T.})
            Aadd(aDePara,{"balances.refund",,,.T.,.F.})
            Aadd(aDePara,{"balances.refund.current",,"RetTMobile() - FLF_TDESC1 - nTotalAdv1",.F.,.T.})
            Aadd(aDePara,{"balances.refund.dolar",,"FLF_TVLRE2 - FLF_TDESC2 - nTotalAdv2",.F.,.T.})
            Aadd(aDePara,{"balances.refund.euro",,"FLF_TVLRE3 - FLF_TDESC3 - nTotalAdv3",.F.,.T.})
            Aadd(aDePara,{"reason_for_refusal",,"IF( FLF_STATUS == '5' .And. Empty( FLF_MOTVFL ), IF(EMPTY(FLF_OBCONF), EncodeUTF8( '"+STR0011+"' ), EncodeUTF8( FLF_OBCONF )), EncodeUTF8( FLF_MOTVFL ) )",.F.,.F.}) // "Prestação de contas reprovada pelo conferente."
            Aadd(aDePara,{"company_billing_percent",,"FLF_FATEMP",.F.,.F.})
            Aadd(aDePara,{"cc_code",,"CTT_CUSTO",.F.,.F.})
            Aadd(aDePara,{"cc_description",,"EncodeUTF8(CTT_DESC01)",.F.,.F.})
            Aadd(aDePara,{"financial",.T.,"LoadBillInfo( FO7_FILIAL, FO7_CODIGO, FLF_STATUS )",.F.,.F., aBillInfo })

            For nI := 1 to nPageSize
                If (cTmp)->(EoF())
                    Exit
                Else
                    // Carrega objeto com os valores da query
                    oJsonTmp := JSONFromTo(aFields,aDePara)

                    // Carrega as informações do memo
                    FLF->(DbGoto((cTmp)->IDFLF))
                    oJsonTmp["reason"] := AllTrim(EncodeUTF8(FLF->FLF_MOTIVO))
        
                    Aadd(oExpenses["expenses"],oJsonTmp)
                    (cTmp)->(dbSkip())
                EndIf
            Next nI
            If !(cTmp)->(EoF())
                oExpenses["hasNext"] := .T.
            EndIf
        EndIf
        (cTmp)->(dbCloseArea())
    Else
        oMessages["code"] 	:= "403"
        oMessages["message"]	:= "Forbidden"
        oMessages["detailMessage"] := STR0003   // "Usu rio inativo no sistema ou n?o autorizado para esta opera‡?o."
        lRet := .F.
    EndIf

    If !lRet
        oMessages["detailMessage"] := EncodeUTF8(oMessages["detailMessage"])
        oExpenses := oMessages
        SetRestFault(Val(oMessages["code"]),oMessages["detailMessage"])
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadItems
    Carrega itens da prestacao de contas
    @author Igor Sousa do Nascimento
    @since 25/08/2017
/*/
//-------------------------------------------------------------------
Static Function LoadItems( nPage, nPageSize, aFields, oItems, cIDFLE, cTipo, lChecked )

    Local aUser      As Array
    Local aDePara    As Array
    Local cTmp       As Character
    Local cQry       As Character
    Local cSGBD      As Character
    Local cBranchFLE As Character
    Local cBranchFLG As Character
    Local cBranchFLS As Character
    Local cBranchSX5 As Character
    Local cFilter    As Character
    Local cSubFilter As Character
    Local cApprovers  As Character
    Local cInApprovers As Character
    Local lRet       As Logical
    Local lNote      As Logical
    Local nInitPage  As Numeric
    Local nI         As Numeric
    Local nY         As Numeric
    Local dDtIniDev  As Data 
    Local oJsonTmp   As Object
    Local oMessages  As Object

    Default nPage     := 1
    Default nPageSize := 10
    Default aFields   := {  "id","date","local","type","currency","quantity",;
                            "converstion_rate","total_value","attachment", "note"   }
    Default oItems    := JsonObject():New()
    Default cIDFLE    := ""
    Default cTipo     := ""
    Default lChecked  := .F.

    lRet       := .T.
    // Trata response negativo
    oMessages  := JsonObject():New()
    aDePara    := {}

    If FINXUser(__cUserID,@aUser,.F.)

        cTmp       := CriaTrab(,.F.)
        cQry       := ""
        cSGBD      := Alltrim(Upper(TCGetDB()))
        cBranchFLE := xFilial( "FLE" )
        cBranchFLG := xFilial( "FLG" )
        cBranchFLS := xFilial( "FLS" )
        cBranchSX5 := xFilial( "SX5" )
        lNote      := FLE->(ColumnPos("FLE_OBS")) > 0
        cApprovers  := GetApprovers( aUser[1] )
        cInApprovers := FormatIn( cApprovers, "," )

        If !lChecked
            cFilter    := "FLE.FLE_PARTIC = '" + aUser[1] + "' "
            cSubFilter := "SUBFLE.FLE_PARTIC = '" + aUser[1] + "' "
        else
            cFilter    := ''
            cSubFilter := ''
            dDtIniDev  := dDatabase - SuperGetMV( "MV_MPCDDES", .F., 30 ) //Define os dias a retroceder da data atual para o cáculo do desvio
            aAdd( aFields, "deviation" )
        EndIf

        // Trata selecao de paginas
        nInitPage  := (nPage - 1) * (nPageSize)  

        /*--------------------------------------------------------------------------
        Query responsavel por trazer toda a amarra‡?o das presta‡?es x viagens 
        --------------------------------------------------------------------------*/
        cQry += "SELECT "
        // Accountability Grid
        cQry +=     "FLE.FLE_PRESTA, FLE.FLE_ITEM, FLE.FLE_LOCAL, FLE.FLE_DESPES, FLE.FLE_QUANT, "
        cQry +=     "FLE.FLE_TOTAL, FLE.FLE_TXCONV, FLE.FLE_VALREE, FLE.FLE_VALNRE, FLE.FLE_DESCON, "
        cQry +=     "FLE.FLE_MOEDA, FLE.FLE_DETDES, FLE.FLE_VALUNI, FLE.FLE_DATA, FLE.FLE_PARTIC, "
        cQry +=     "FLE.FLE_TIPO, FLE.R_E_C_N_O_, "
        
        If lNote
            cQry += "FLE.FLE_OBS, "
        EndIf

        // Expense Types
        cQry +=     "FLG.FLG_DESCRI, "
        cQry +=     "FLS_VALUNI, FLS_DTINI, FLS_DTFIM, "
        // Location
        cQry +=     "SX5.X5_DESCRI "
        
        If lChecked
            cQry += ", ( SELECT COALESCE( ROUND( AVG( FLE_TOTAL ), 2), 0 ) " 
            cQry += " FROM " + RetSqlName( "FLF" ) + " FLF1 " 
            cQry += " INNER JOIN " + RetSqlName( "FLE" ) + " FLE1 " 
            cQry += " ON FLE1.FLE_FILIAL = FLF_FILIAL " 
            cQry +=     " AND FLE1.FLE_PRESTA = FLF_PRESTA "  
            cQry +=     " AND FLE1.FLE_TIPO = FLF_TIPO " 
            cQry +=     " AND FLE1.FLE_LOCAL = FLE.FLE_LOCAL " 
            cQry +=     " AND FLE1.FLE_DESPES = FLE.FLE_DESPES " 
            cQry +=     " AND FLE1.FLE_MOEDA = FLE.FLE_MOEDA "  
            cQry +=     " AND FLE1.FLE_DATA BETWEEN '" + dtos( dDtIniDev ) + "' AND '" + dtos( dDatabase ) + "' "  
            cQry +=     " AND FLE1.D_E_L_E_T_ = ' ' " 
            cQry += " WHERE FLF_FILIAL = '" + xFilial( "FLF" ) + "' AND (FLF_STATUS = '7' OR FLF_STATUS = '6') AND FLF1.D_E_L_E_T_ = ' ' ) AS DESVIO "
        EndIf 
        
        cQry += "FROM " +RetSQLName("FLE")+ " FLE "
        cQry +=     "INNER JOIN " +RetSQLName("FLG")+ " FLG "
        cQry +=     "ON FLG.FLG_FILIAL = '" +cBranchFLG+ "' "
        cQry +=     "AND FLG.FLG_CODIGO = FLE.FLE_DESPES "
        cQry +=     "INNER JOIN " +RetSQLName("SX5")+ " SX5 "
        cQry +=     "ON SX5.X5_FILIAL = '" + cBranchSX5 + "' "
        cQry +=     "AND SX5.X5_TABELA IN ('12','BH') " 
        cQry +=     "AND SX5.X5_CHAVE = FLE.FLE_LOCAL "
        
        If lChecked
            cQry += "INNER JOIN " + RetSqlName("FLN") + " FLN "
            cQry += "ON FLN.FLN_FILIAL = FLE.FLE_FILIAL "
            cQry += "AND FLN.FLN_TIPO = FLE.FLE_TIPO "
            cQry += "AND FLN.FLN_PRESTA = FLE.FLE_PRESTA "
            cQry += "AND FLN.FLN_PARTIC = FLE.FLE_PARTIC "
            cQry += "AND FLN.FLN_STATUS = '1' "
            cQry += "AND FLN.FLN_TPAPR = '1' "
            cQry += "AND FLN.FLN_APROV IN " + cInApprovers +  " 
            cQry += "AND FLN.D_E_L_E_T_ = ' ' "
        EndIf 
        
        cQry +=     "LEFT JOIN " + RetSQLName("FLS") + " FLS " 
        cQry +=     "ON FLS.FLS_FILIAL = '" + cBranchFLS + "' "
        cQry +=     "AND FLS.FLS_CODIGO = FLG.FLG_CODIGO "
        cQry +=     "AND FLS.FLS_DTINI <= '" + dtos(ddatabase) + "' "
        cQry +=     "AND (FLS.FLS_DTFIM >= '" + dtos(ddatabase) + "' OR FLS.FLS_DTFIM = ' ') "
        cQry +=     "AND FLS.D_E_L_E_T_ = ' ' "
        cQry += "WHERE "
        // Select Pages
        cQry +=     "FLE.R_E_C_N_O_ NOT IN "
        cQry +=     "( "
        cQry +=         "SELECT "
        If !(cSGBD $ "ORACLE|POSTGRES|DB2") .and. cSGBD <> "MYSQL" // SQL e demais bancos
            cQry +=         "TOP " +cValToChar(nInitPage)+ " " 
        EndIf
        cQry +=             "SUBFLE.R_E_C_N_O_ "
        cQry +=         "FROM " +RetSQLName("FLE")+ " SUBFLE "
        cQry +=             "INNER JOIN " +RetSQLName("FLG")+ " SUBFLG "
        cQry +=             "ON SUBFLG.FLG_FILIAL = '" +cBranchFLG+ "' "
        cQry +=             "AND SUBFLG.FLG_CODIGO = SUBFLE.FLE_DESPES "
        cQry +=             "INNER JOIN " +RetSQLName("SX5")+ " SUBSX5 "
        cQry +=             "ON SUBSX5.X5_FILIAL = '" + cBranchSX5 + "' "
        cQry +=             "AND SUBSX5.X5_TABELA IN ('12','BH') " 
        cQry +=             "AND SUBSX5.X5_CHAVE = SUBFLE.FLE_LOCAL "
        
        If lChecked
            cQry += "INNER JOIN " + RetSqlName("FLN") + " SUBFLN "
            cQry += "ON SUBFLN.FLN_FILIAL = SUBFLE.FLE_FILIAL "
            cQry += "AND SUBFLN.FLN_TIPO = SUBFLE.FLE_TIPO "
            cQry += "AND SUBFLN.FLN_PRESTA = SUBFLE.FLE_PRESTA "
            cQry += "AND SUBFLN.FLN_PARTIC = SUBFLE.FLE_PARTIC "
            cQry += "AND SUBFLN.FLN_STATUS = '1' "
            cQry += "AND SUBFLN.FLN_TPAPR = '1' "
            cQry += "AND SUBFLN.FLN_APROV IN " + cInApprovers +  " 
            cQry += "AND SUBFLN.D_E_L_E_T_ = ' ' "
        EndIf 
        
        cQry +=             "LEFT JOIN " + RetSQLName("FLS") + " SUBFLS " 
        cQry +=             "ON SUBFLS.FLS_FILIAL = '" + cBranchFLS + "' "
        cQry +=             "AND SUBFLS.FLS_CODIGO = FLG_CODIGO "
        cQry +=             "AND SUBFLS.FLS_DTINI <= '" + dtos(ddatabase) + "' "
        cQry +=             "AND (SUBFLS.FLS_DTFIM >= '" + dtos(ddatabase) + "' OR SUBFLS.FLS_DTFIM = ' ') "
        cQry +=             "AND SUBFLS.D_E_L_E_T_ = ' ' "
        cQry +=         "WHERE "
        cQry +=             "SUBFLE.FLE_FILIAL = '" +cBranchFLE+ "' " 
        cQry +=             "AND SUBFLE.FLE_PRESTA = '" +cIDFLE+ "' "
        cQry +=             "AND SUBFLE.FLE_TIPO = '" +cTipo+ "' "
        
        IF !Empty( cSubFilter )
            cQry +=         "AND " + cSubFilter + " 
        EndIf

        cQry +=             " AND SUBFLE.D_E_L_E_T_ = ' ' AND SUBFLG.D_E_L_E_T_ = ' ' "
        cQry +=             "AND SUBSX5.D_E_L_E_T_ = ' ' "
        If cSGBD $ "ORACLE"
            cQry +=         "AND ROWNUM < " +cValToChar(nInitPage)+ " "
        ElseIf cSGBD == "POSTGRES" .or. cSGBD == "MYSQL" .or. cSGBD == "DB2"
            cQry +=     "LIMIT " +cValToChar(nInitPage)+ " "
        EndIf
        cQry +=     ") "
        cQry +=     "AND FLE.FLE_FILIAL = '" +cBranchFLE+ "' " 
        cQry +=     "AND FLE.FLE_PRESTA = '" +cIDFLE+ "' "
        cQry +=     "AND FLE.FLE_TIPO = '" +cTipo+ "' "

        IF !Empty( cFilter )
            cQry +=     "AND " + cFilter + " 
        EndIf

        cQry +=     " AND FLE.D_E_L_E_T_ = ' ' AND FLG.D_E_L_E_T_ = ' ' "
        cQry +=     "AND SX5.D_E_L_E_T_ = ' ' "

        //cQry += "ORDER BY "
        //cQry +=     "FLE.FLE_DATA ASC, FLE.R_E_C_N_O_"
        cQry := ChangeQuery(cQry)

        MPSysOpenQuery(cQry, cTmp)
        dbSelectArea(cTmp)

        oItems["hasNext"]:= .F.  // Propriedade para controle de paginas
        oItems["items"]:= {}  // Array para composi‡ao das presta‡oes de contas

        If !(cTmp)->(EoF())
            /*  aDePara = Array com campos do mobile e do protheus (De/Para)
                aDePara[n][1] = campo ou objeto do request
                aDePara[n][2] = se array ou propriedade de array (criar propriedades na funcao JSONFromTo)
                aDePara[n][3] = array com campos (ou conteudo) Protheus
                aDePara[n][4] = se objeto JSON (.T. ou .F.)
                aDePara[n][5] = se propriedade de objeto JSON (.T. ou .F.)
            */
            Aadd(aDePara,{"id",,"FLE_ITEM",.F.,.F.})
            Aadd(aDePara,{"date",,"FLE_DATA",.F.,.F.})
            Aadd(aDePara,{"local",,,.T.,.F.})
            Aadd(aDePara,{"local.id",,"FLE_LOCAL",.F.,.T.})
            Aadd(aDePara,{"local.name",,"EncodeUTF8(X5_DESCRI)",.F.,.T.})
            Aadd(aDePara,{"type",,,.T.,.F.})
            Aadd(aDePara,{"type.id",,"FLE_DESPES",.F.,.T.})
            Aadd(aDePara,{"type.description",,"EncodeUTF8(FLG_DESCRI)",.F.,.T.})
            Aadd(aDePara,{"type.unit_value",,"FLS_VALUNI",.F.,.T.})
            Aadd(aDePara,{"currency",,,.T.,.F.})
            Aadd(aDePara,{"currency.id",,"FLE_MOEDA",.F.,.T.})
            Aadd(aDePara,{"currency.description",,"",.F.,.T.})
            Aadd(aDePara,{"currency.symbol",,"",.F.,.T.})
            Aadd(aDePara,{"quantity",,"FLE_QUANT",.F.,.F.})
            Aadd(aDePara,{"converstion_rate",,"FLE_TXCONV",.F.,.F.})
            Aadd(aDePara,{"total_value",,"FLE_TOTAL",.F.,.F.})
            Aadd(aDePara,{"attachment",,"HasAttch()",.F.,.F.})

            If lNote
                Aadd(aDePara,{"note",,"EncodeUTF8(AllTrim(FLE_OBS))",.F.,.F.})
            Endif

            If lChecked
                Aadd(aDePara, { "deviation", , , .T., .F. } )
                Aadd(aDePara, { "deviation.average_value", , "DESVIO", .F., .T. } )
                Aadd(aDePara, { "deviation.min_value", , "DeviationValue( 'MIN', DESVIO )", .F., .T. } )
                Aadd(aDePara, { "deviation.max_value", , "DeviationValue( 'MAX', DESVIO )", .F., .T. } )
                Aadd(aDePara, { "deviation.info", , "DeviationInfo( DESVIO, FLE_TOTAL )", .F., .T. } )
            EndIf

            For nI := 1 to nPageSize
                If (cTmp)->(EoF())
                    Exit
                Else
                    oJsonTmp := JsonObject():New()
                    // Texto descritivo da moeda e Simbolo
                    Do Case
                        Case (cTmp)->FLE_MOEDA == "1"   
                            nY := AScan(aDePara,{|x| x[1] == "currency.description" })
                            aDePara[nY][3]:= "'Real'"
                            nY := AScan(aDePara,{|x| x[1] == "currency.symbol" })
                            aDePara[nY][3]:= "'R$'"
                        Case (cTmp)->FLE_MOEDA == "2"   
                            nY := AScan(aDePara,{|x| x[1] == "currency.description" })
                            aDePara[nY][3]:= "'Dolar'"
                            nY := AScan(aDePara,{|x| x[1] == "currency.symbol" })
                            aDePara[nY][3]:= "'U$'"
                        Case (cTmp)->FLE_MOEDA == "3"   
                            nY := AScan(aDePara,{|x| x[1] == "currency.description" })
                            aDePara[nY][3]:= "'Euro'"
                            nY := AScan(aDePara,{|x| x[1] == "currency.symbol" })
                            aDePara[nY][3]:= "'?'"
                        Case (cTmp)->FLE_MOEDA == "9"   
                            nY := AScan(aDePara,{|x| x[1] == "currency.description" })
                            aDePara[nY][3]:= "'Outras'"
                            nY := AScan(aDePara,{|x| x[1] == "currency.symbol" })
                            aDePara[nY][3]:= "''"
                    EndCase
                    // Carrega objeto com campos do usuario
                    oJsonTmp := JSONFromTo(aFields,aDePara)
					Aadd(oItems["items"],oJsonTmp)
                    (cTmp)->(dbSkip())
                EndIf
            Next nI
            
            If !(cTmp)->(EoF())
                oItems["hasNext"] := .T.
            EndIf
        EndIf
        (cTmp)->(dbCloseArea())
    Else
        oMessages["code"] 	:= "403"
        oMessages["message"]	:= "Forbidden"
        oMessages["detailMessage"] := STR0003   // "Usu rio inativo no sistema ou n?o autorizado para esta opera‡?o."
        lRet := .F.
    EndIf

    If !lRet
        oMessages["detailMessage"] := EncodeUTF8(oMessages["detailMessage"])
        oItems["messages"] := oMessages
        SetRestFault(Val(oMessages["code"]),oMessages["detailMessage"])
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Loadvance
    Carrega informacoes dos adiantamentos da viagem
    @author Igor Sousa do Nascimento
    @since 23/08/2017
/*/
//-------------------------------------------------------------------
Function Loadvance(cBranchFL5,cIDFL5)

    Local aArea     As Array
    Local aAdvances As Array
    Local aUser     As Array
    Local cTmp      As Character

    Default cBranchFL5 := xFilial( "FL5" )
    Default cIDFL5     := ""

    aAdvances  := {}
    aArea      := GetArea()
    cTmp       := CriaTrab(,.F.)
    cBranchFL5 := xFilial( "FL5" )

    If FINXUser(__cUserID,@aUser,.F.)

        BEGINSQL ALIAS cTmp
            SELECT
                FLD.FLD_VIAGEM, FLD.FLD_ADIANT, 
                FLD.FLD_DTPREV, FLD_MOEDA, FLD_VALOR, FLD_STATUS

            FROM %Table:FLD% FLD

            WHERE
                FLD.FLD_FILIAL = %exp:cBranchFL5%
                AND FLD.FLD_VIAGEM = %exp:cIDFL5%
                AND FLD.FLD_PARTIC = %exp:aUser[1]%
                AND FLD.%NotDel%
        ENDSQL 

        dbSelectArea(cTmp)

        While !(cTmp)->(EoF())
            Aadd(aAdvances,{ If((cTmp)->FLD_MOEDA=="1",(cTmp)->FLD_VALOR,0), If((cTmp)->FLD_MOEDA=="2",(cTmp)->FLD_VALOR,0), If((cTmp)->FLD_MOEDA=="3", (cTmp)->FLD_VALOR,0), (cTmp)->FLD_DTPREV, (cTmp)->FLD_STATUS  })
            (cTmp)->(dbSkip())
        EndDo

        (cTmp)->(dbCloseArea())

        RestArea(aArea)

    EndIf

Return aAdvances

//-------------------------------------------------------------------
/*/{Protheus.doc} NewXpense
    Insere nova prestacao de contas Avulsa
    @author Igor Sousa do Nascimento
    @since 25/08/2017
/*/
//-------------------------------------------------------------------
Static Function NewXpense(oExpenses,cBody)
    
    Local aUser     As Array
    Local cIDFLF    As Character
    Local cCatch    As Character
    Local dDataIni  As Date
    Local dDataFim  As Date
    Local dEmissao  As Date
    Local dXpense   As Date
    Local lRet      As Logical
    Local lNote     As Logical
    Local nI        As Numeric
    Local oJsonTmp  As Object
    Local oMessages As Object
    Local oModel677 As Object
    Local oModelFLE As Object
    Local oModelFLF As Object
    Local oModelTot As Object

    Default oExpenses := JsonObject():New()
    Default cBody     := ""

    lRet      := .T.
    oMessages := JsonObject():New()

    If FINXUser(__cUserID,@aUser,.F.)
        oJsonTmp := JsonObject():New()
        cCatch   := oJsonTmp:FromJSON(cBody)
        If cCatch == Nil    
            lNote := FLE->(ColumnPos("FLE_OBS")) > 0

            dbSelectArea("FLF")
            FLF->(dbSetOrder(1))  // FLF_FILIAL, FLF_TIPO, FLF_PRESTA, FLF_PARTIC
        
            oModel677:= FWLoadModel("FINA677")
            oModel677:SetOperation(MODEL_OPERATION_INSERT) 
            F677LoadMod(oModel677,MODEL_OPERATION_INSERT)
            oModelFLE:= oModel677:GetModel("FLEDETAIL")
            oModelFLF:= oModel677:GetModel("FLFMASTER")
            oModelTot:= oModel677:GetModel("TOTAL")
            cIDFLF   := oModelFLF:GetValue("FLF_PRESTA")

            dDataIni := StoD(oJsonTmp["departure_date"])
            dDataFim := StoD(oJsonTmp["arrival_date"])
            dEmissao := StoD(oJsonTmp["emission"])
            oModelFLF:SetValue("FLF_FILIAL", xFilial("FLF"))
            oModelFLF:SetValue("FLF_TIPO"  , "2")
            oModelFLF:SetValue("FLF_FATEMP", oJsonTmp["company_billing_percent"])
            oModelFLF:SetValue("FLF_FATCLI", 100-oJsonTmp["company_billing_percent"])
            oModelFLF:SetValue("FLF_STATUS", "1")   // Em Aberto
            oModelFLF:SetValue("FLF_EMISSA", dEmissao)
            oModelFLF:SetValue("FLF_DTINI" , dDataIni)
            oModelFLF:SetValue("FLF_DTFIM" , dDataFim)
            oModelFLF:SetValue("FLF_NACION", If(oJsonTmp["international"],"2","1"))        // 1 - Nacional | 2 - Internacional
            oModelFLF:SetValue("FLF_MOTIVO", DecodeUTF8( oJsonTmp["reason"] ) )
            oModelFLF:SetValue("FLF_CLIENT", oJsonTmp["client"])
            oModelFLF:SetValue("FLF_LOJA"  , oJsonTmp["unit"])
            oModelFLF:SetValue("FLF_CC"    , oJsonTmp["cc_code"])
            For nI := 1 to Len(oJsonTmp["items"])
                dXpense  := StoD(oJsonTmp["items"][nI]["date"])
                oModelFLE:SetValue("FLE_FILIAL", xFilial("FLE"))
                oModelFLE:SetValue("FLE_ITEM"  , StrZero(nI,TamSX3("FLE_ITEM")[1]))
                oModelFLE:SetValue("FLE_TIPO"  , "2")
                oModelFLE:SetValue("FLE_PRESTA", cIDFLF)
                oModelFLE:SetValue("FLE_PARTIC", aUser[1])
                oModelFLE:SetValue("FLE_DATA"  , dXpense)
                oModelFLE:SetValue("FLE_LOCAL" , oJsonTmp["items"][nI]["local"])
                oModelFLE:SetValue("FLE_DESPES", oJsonTmp["items"][nI]["type"])
                oModelFLE:SetValue("FLE_MOEDA" , oJsonTmp["items"][nI]["currency"])
                oModelFLE:SetValue("FLE_QUANT" , oJsonTmp["items"][nI]["quantity"])
                If oJsonTmp["items"][nI]["currency"] <> '1'
                    oModelFLE:SetValue("FLE_TXCONV", oJsonTmp["items"][nI]["conversion_rate"])
                EndIf
                
                If lNote .and. ValType(oJsonTmp["items"][nI]["note"]) <> 'U'
                    oModelFLE:SetValue("FLE_OBS" , DecodeUTF8(oJsonTmp["items"][nI]["note"]))
                EndIf

                oModelFLE:SetValue("FLE_TOTAL" , oJsonTmp["items"][nI]["total_value"])
                
                If nI < Len(oJsonTmp["items"])
                    oModelFLE:AddLine()
                EndIf
            Next nI

            If !oModel677:VldData()
                oMessages["code"] 	:= "400"
                oMessages["message"]	:= "Bad Request"
                oMessages["detailMessage"] := cValToChar(oModel677:GetErrorMessage()[6])
                lRet := .F.
            Else
                oModel677:CommitData()
                oExpenses["id"] := cIDFLF
            EndIf
            oModel677:DeActivate()
            oModel677:Destroy()
            oModel677 := NIL
        Else
            oMessages["code"] 	:= "400"
            oMessages["message"]	:= "Bad Request"
            oMessages["detailMessage"] := cCatch
            lRet := .F.
        EndIf
    Else
        oMessages["code"] 	:= "403"
        oMessages["message"]	:= "Forbidden"
        oMessages["detailMessage"] := STR0003   // "Usu rio inativo no sistema ou n?o autorizado para esta opera‡?o."
        lRet := .F.
    EndIf

    If !lRet
        oMessages["detailMessage"] := EncodeUTF8(oMessages["detailMessage"])
        oExpenses := oMessages
        SetRestFault(Val(oMessages["code"]),oMessages["detailMessage"])
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} NewItem
    Insere nova despesa na prestacao de contas
    @author Igor Sousa do Nascimento
    @since 31/08/2017
/*/
//-------------------------------------------------------------------
Static Function NewItem(oExpenses,cBody,cIDFLF,cTipo)

    Local aUser     As Array
    Local cItem     As Character
    Local cCatch    As Character
    Local dData     As Date
    Local lRet      As Logical
    Local lNote     As Logical
    Local oJsonTmp  As Object
    Local oMessages As Object
    Local oModel677 As Object
    Local oModelFLE As Object
    Local oModelFLF As Object
    Local oModelTot As Object

    Default oExpenses := JsonObject():New()
    Default cBody     := ""
    Default cIDFLF    := ""
    Default cTipo     := ""

    lRet      := .T.
    oMessages := JsonObject():New()

    If FINXUser(__cUserID,@aUser,.F.)
        oJsonTmp := JsonObject():New()
        cCatch   := oJsonTmp:FromJSON(cBody)

        If cCatch == Nil
            dbSelectArea("FLF")
            FLF->(dbSetOrder(1))  // FLF_FILIAL, FLF_TIPO, FLF_PRESTA, FLF_PARTIC

            If  dbSeek(xFilial("FLF") + cTipo + cIDFLF + aUser[1])
                If FLF->FLF_STATUS == "1" .or. FLF->FLF_STATUS == "5"   // Aberta ou Reprovada
                    lNote := FLE->(ColumnPos("FLE_OBS")) > 0

                    oModel677:= FWLoadModel("FINA677")
                    oModel677:SetOperation(MODEL_OPERATION_UPDATE)  
                    F677LoadMod(oModel677,MODEL_OPERATION_UPDATE)
                    oModel677:Activate()
                    oModelFLF:= oModel677:GetModel("FLFMASTER")
                    oModelFLE:= oModel677:GetModel("FLEDETAIL")
                    oModelTot:= oModel677:GetModel("TOTAL")

                    dData  := StoD(oJsonTmp["date"])
                    cItem  := StrZero(oModelFLE:Length(),TamSX3("FLE_ITEM")[1])
                    If oModelFLE:Length() > 1
                        oModelFLE:GoLine(oModelFLE:Length())
                        cItem := oModelFLE:GetValue("FLE_ITEM")
                        oModelFLE:AddLine()
                    Else
                        If oModelFLE:Length() > 0
                            oModelFLE:GoLine(oModelFLE:Length())
                            cItem := oModelFLE:GetValue("FLE_ITEM")
                            If oModelFLE:GetValue("FLE_TOTAL") > 0 
                                oModelFLE:AddLine()
                            EndIf
                        EndIf
                    EndIf
                    oModelFLE:SetValue("FLE_FILIAL", xFilial("FLE"))
                    oModelFLE:SetValue("FLE_ITEM"  , Soma1(cItem))
                    oModelFLE:SetValue("FLE_DATA"  , dData)
                    oModelFLE:SetValue("FLE_LOCAL" , oJsonTmp["local"])
                    oModelFLE:SetValue("FLE_DESPES", oJsonTmp["type"])
                    oModelFLE:SetValue("FLE_MOEDA" , oJsonTmp["currency"])
                    oModelFLE:SetValue("FLE_QUANT" , oJsonTmp["quantity"])
                    If oJsonTmp["currency"] <> '1' .and. ValType(oJsonTmp["conversion_rate"]) <> 'U'
                        oModelFLE:SetValue("FLE_TXCONV", oJsonTmp["conversion_rate"])
                    EndIf
                    
                    If lNote .and. ValType(oJsonTmp["note"]) <> 'U'
                        oModelFLE:SetValue("FLE_OBS" , DecodeUtf8(oJsonTmp["note"]))
                    EndIf

                    oModelFLE:SetValue("FLE_TOTAL" , oJsonTmp["total_value"])

                    If !oModel677:VldData()
                        oMessages["code"] 	:= "400"
                        oMessages["message"]	:= "Bad Request"
                        oMessages["detailMessage"] := cValToChar(oModel677:GetErrorMessage()[6])
                        lRet := .F.
                    Else
                        oModel677:CommitData()
                        oExpenses["id"]     := oModelFLE:GetValue("FLE_ITEM")
                    EndIf
                    oModel677:DeActivate()
                    oModel677:Destroy()
                    oModel677 := NIL
                Else
                    oMessages["code"] 	:= "403"
                    oMessages["message"]	:= "Forbidden"
                    oMessages["detailMessage"] :=  STR0006  // "Status do registro n?o permite altera‡?o / exclus?o."
                    lRet := .F.
                EndIf
            EndIf
        Else
            oMessages["code"] 	:= "400"
            oMessages["message"]	:= "Bad Request"
            oMessages["detailMessage"] := cCatch
            lRet := .F.
        EndIf
    Else
        oMessages["code"] 	:= "403"
        oMessages["message"]	:= "Forbidden"
        oMessages["detailMessage"] := STR0003   // "Usu rio inativo no sistema ou n?o autorizado para esta opera‡?o."
        lRet := .F.
    EndIf

    If !lRet
        oMessages["detailMessage"] := EncodeUTF8(oMessages["detailMessage"])
        oExpenses := oMessages
        SetRestFault(Val(oMessages["code"]),oMessages["detailMessage"])
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdXpense
    Alteracao da prestacao de contas e item
    @author Igor Sousa do Nascimento
    @since 31/08/2017
/*/
//-------------------------------------------------------------------
Static Function UpdXpense(oExpenses,cBody,cIDFLF,cTipo,cItem,cAnexo)

    Local aUser     As Array
    Local aFields   As Array
    Local cCatch    As Character
    Local lRet      As Logical
    Local lNote     As Logical
    Local oJsonTmp  As Object
    Local oMessages As Object
    Local oModel677 As Object
    Local oModelFLE As Object
    Local oModelFLF As Object
    Local nR := 0

    Default oExpenses := JsonObject():New()
    Default cBody     := ""
    Default cIDFLF    := ""
    Default cTipo     := ""
    Default cItem     := ""
    Default cAnexo    := .F.

    lRet      := .T.
    oMessages := JsonObject():New()

    If FINXUser(__cUserID,@aUser,.F.)
        oJsonTmp := JsonObject():New()
        cCatch   := oJsonTmp:FromJSON(cBody)

        If cCatch == Nil
            dbSelectArea("FLE")
            FLE->(dbSetOrder(1))

            dbSelectArea("FLF")
            FLF->(dbSetOrder(1))

            If FLF->(dbSeek(xFilial("FLF") + cTipo + cIDFLF + aUser[1]))
                aFields := oJsonTmp:GetProperties()
                lNote := FLE->(ColumnPos("FLE_OBS")) > 0

                If FLF->FLF_STATUS == "1" .or. FLF->FLF_STATUS == "5"   // Aberta ou Reprovada
                    If FLE->(dbSeek(xFilial("FLF") + cTipo + cIDFLF + aUser[1] + cItem))
                        cItemNew := cItem
                        Begin Transaction
                            oModel677:= FWLoadModel("FINA677")
                            oModel677:SetOperation(MODEL_OPERATION_UPDATE)   
                            F677LoadMod(oModel677,MODEL_OPERATION_UPDATE)
                            oModel677:Activate()

                            oModelFLF:= oModel677:GetModel("FLFMASTER")
                            oModelFLE:= oModel677:GetModel("FLEDETAIL")

                            For nR := 1 To oModelFLE:Length()
                                oModelFLE:GOLINE(nR)
                                If AllTrim(oModelFLE:GetValue("FLE_ITEM")) == AllTrim(cItem)
                                    Exit    
                                EndIf
                            Next nR

                            If ( AScan(aFields,{|x| x ='date'}) ) > 0
                                dXpense  := StoD(oJsonTmp["date"])
                                oModelFLE:SetValue("FLE_DATA"  , dXpense)
                            EndIf
                            If ( AScan(aFields,{|x| x ='type'}) ) > 0
                                oModelFLE:SetValue("FLE_DESPES", oJsonTmp["type"])
                            EndIf
                            If ( AScan(aFields,{|x| x ='currency'}) ) > 0
                                oModelFLE:SetValue("FLE_MOEDA" , oJsonTmp["currency"])
                            EndIf
                            If ( AScan(aFields,{|x| x ='quantity'}) ) > 0
                                oModelFLE:SetValue("FLE_QUANT" , oJsonTmp["quantity"])
                            EndIf
                            If ( AScan(aFields,{|x| x ='conversion_rate'}) ) > 0
                                oModelFLE:SetValue("FLE_TXCONV", oJsonTmp["conversion_rate"])
                            EndIf
                            If ( AScan(aFields,{|x| x ='local'}) ) > 0
                                oModelFLE:SetValue("FLE_LOCAL" , oJsonTmp["local"])
                            EndIf
                            If ( AScan(aFields,{|x| x ='total_value'}) ) > 0
                                oModelFLE:SetValue("FLE_TOTAL" , oJsonTmp["total_value"])
                            EndIf              
                            If lNote .and. ( AScan(aFields,{|x| x ='note'}) ) > 0 
                                oModelFLE:SetValue("FLE_OBS" , DecodeUtf8(oJsonTmp["note"]))
                            EndIf            

                            oModelFLF:SetValue("FLF_STATUS", "1")  // Retorna status para "em aberto"

                            If !oModel677:VldData()
                                oMessages["code"] 	:= "400"
                                oMessages["message"]	:= "Bad Request"
                                oMessages["detailMessage"] := cValToChar(oModel677:GetErrorMessage()[6])
                                lRet := .F.
                            Else
                                oModel677:CommitData()
                            EndIf
                            oModel677:DeActivate()
                            oModel677:Destroy()
                            oModel677 := NIL
                        End Transaction
                    EndIf
                Else
                    oMessages["code"] 	:= "403"
                    oMessages["message"]	:= "Forbidden"
                    oMessages["detailMessage"] := STR0006  // "Status do registro n?o permite altera‡?o / exclus?o."
                    lRet := .F.
                EndIf
            EndIf
        Else
            oMessages["code"] 	:= "400"
            oMessages["message"]	:= "Bad Request"
            oMessages["detailMessage"] := cCatch
            lRet := .F.
        EndIf
    Else
        oMessages["code"] 	:= "403"
        oMessages["message"]	:= "Forbidden"
        oMessages["detailMessage"] := STR0003   // "Usu rio inativo no sistema ou n?o autorizado para esta opera‡?o."
        lRet := .F.
    EndIf

    If !lRet
        oMessages["detailMessage"] := EncodeUTF8(oMessages["detailMessage"])
        oExpenses := oMessages
        SetRestFault(Val(oMessages["code"]),oMessages["detailMessage"])
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DelXpense
    Deleta registro da FLF/FLE
    @author Igor Sousa do Nascimento
    @since 30/08/2017
/*/
//-------------------------------------------------------------------
Static Function DelXpense(oResponse,cIDFLF,cTipo)

    Local aUser     As Array
    Local lRet      As Logical
    Local oMessages As Object
    Local oModel677 As Object
    Local oModelFLE As Object
    Local oModelFLF As Object

    Default oResponse := JsonObject():New()
    Default cIDFLF    := ""
    Default cTipo     := ""

    lRet      := .T.
    oMessages := JsonObject():New()

    If FINXUser(__cUserID,@aUser,.F.)
        // Deleta prestacao e item
        dbSelectArea("FLE")
        FLE->(dbSetOrder(1))

        dbSelectArea("FLF")
        FLF->(dbSetOrder(1))

        If FLF->(dbSeek(xFilial("FLF") + cTipo + cIDFLF + aUser[1]))
            Begin Transaction  
                oModel677:= FWLoadModel("FINA677")
                oModel677:SetOperation(MODEL_OPERATION_DELETE)  
                oModel677:Activate()
                oModelFLE:= oModel677:GetModel("FLEDETAIL")
                oModelFLF:= oModel677:GetModel("FLFMASTER")

                If !oModel677:VldData()
                    oMessages["code"] 	:= "400"
                    oMessages["message"]	:= "Bad Request"
                    oMessages["detailMessage"] := cValToChar(oModel677:GetErrorMessage()[6])
                    lRet := .F.
                Else
                    oModel677:CommitData()
                EndIf
                oModel677:DeActivate()
                oModel677:Destroy()
                oModel677 := NIL
            End Transaction
        EndIf
    Else
        oMessages["code"] 	:= "403"
        oMessages["message"]	:= "Forbidden"
        oMessages["detailMessage"] := STR0003   // "Usu rio inativo no sistema ou n?o autorizado para esta opera‡?o."
        lRet := .F.
    EndIf

    If !lRet
        oMessages["detailMessage"] := EncodeUTF8(oMessages["detailMessage"])
        oResponse := oMessages
        SetRestFault(Val(oMessages["code"]),oMessages["detailMessage"])
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DelItem
    Deleta registro da FLF/FLE
    @author Igor Sousa do Nascimento
    @since 30/08/2017
/*/
//-------------------------------------------------------------------
Static Function DelItem(oResponse,cIDFLF,cTipo,cItem)

    Local aUser     As Array
    Local aKeyFLE   As Array
    Local aDelImg   As Array
    Local lRet      As Logical
    Local oMessages As Object
    Local oModel677 As Object
    Local oModelFLE As Object
    Local oModelFLF As Object

    Default oResponse := JsonObject():New()
    Default cIDFLF    := ""
    Default cTipo     := ""
    Default cItem     := ""

    lRet      := .T.
    oMessages := JsonObject():New()

    If FINXUser(__cUserID,@aUser,.F.)
        // Deleta somente item
        dbSelectArea("FLE")
        FLE->(dbSetOrder(1))

        dbSelectArea("FLF")
        FLF->(dbSetOrder(1))

        If FLF->(dbSeek(xFilial("FLF") + cTipo + cIDFLF + aUser[1]))
            If FLE->(dbSeek(xFilial("FLF") + cTipo + cIDFLF + aUser[1] + cItem))  
                oModel677:= FWLoadModel("FINA677")
                oModel677:SetOperation(MODEL_OPERATION_UPDATE)  
                F677LoadMod(oModel677,MODEL_OPERATION_UPDATE)
                oModel677:Activate()
                oModelFLE:= oModel677:GetModel("FLEDETAIL")
                oModelFLF:= oModel677:GetModel("FLFMASTER")
                aKeyFLE := { {"FLE_FILIAL",xFilial("FLE")},{"FLE_TIPO",cTipo},{"FLE_PRESTA",cIDFLF},;
                                {"FLE_PARTIC",aUser[1]}, {"FLE_ITEM",cItem} }

                If oModelFLE:SeekLine(aKeyFLE)
                    // Exclui tambem o anexo, caso houver
                    aDelImg := F677ImgApp(5,oModel677)
                    If Len(aDelImg) > 0 .and. aDelImg[1] == "400"
                        lRet := .F.
                    EndIf
                    If lRet .and. oModelFLE:DeleteLine()
                        If !oModel677:VldData()
                            oMessages["code"]   := "400"
                            oMessages["message"]    := "Bad Request"
                            oMessages["detailMessage"] := cValToChar(oModel677:GetErrorMessage()[6])
                            lRet := .F.
                        Else
                            oModel677:CommitData()
                        EndIf
                    Else
                        oMessages["code"]   := "400"
                        oMessages["message"]    := "Bad Request"
                        oMessages["detailMessage"] := STR0004 + If(aDelImg[1] == "400", " " + aDelImg[2], " ") // A opera‡?o n?o p“de ser conclu¡da." 
                        lRet := .F.
                    EndIf
                EndIf
                oModel677:DeActivate()
                oModel677:Destroy()
                oModel677 := NIL
            EndIf
        EndIf
    Else
        oMessages["code"] 	:= "403"
        oMessages["message"]	:= "Forbidden"
        oMessages["detailMessage"] := STR0003   // "Usu rio inativo no sistema ou n?o autorizado para esta opera‡?o."
        lRet := .F.
    EndIf

    If !lRet
        oMessages["detailMessage"] := EncodeUTF8(oMessages["detailMessage"])
        oResponse := oMessages
        SetRestFault(Val(oMessages["code"]),oMessages["detailMessage"])
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadClients
    Carrega os clientes disponiveis no objeto do response
    @author Leonardo Castro
    @since 28/08/2017
    @version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function LoadClients(nPage,nPageSize,cSearchKey,oClients)

    Local cTmp       As Character
    Local cBranchSA1 As Character
    Local cCond      As Character
    Local cSGBD      As Character
    Local lRet       As Logical
    Local nInitPage  As Numeric
    Local nI         As Numeric
    Local oJsonTmp   As Object
    Local oMessages  As Object
    Local aFilter    As Array
    Local lSync      As Logical

    Default oClients := JsonObject():New()
    Default nPage     := 1
    Default nPageSize := 10
    Default cSearchKey := ""

    lSync := SuperGetMV( "MV_MPCSCLI", .F., .T. )

    If !lSync
        oClients["hasNext"] := .F. // Propriedade para controle de paginas
        oClients["clients"] := {}  // Array para composicao dos clientes
        Return .T.    
    EndIf

    aFilter  := {}
    cCond    := ""
    cSGBD    := Alltrim(Upper(TCGetDB()))
    lRet     := .T.
    oMessages:= JsonObject():New()

    nInitPage := (nPage - 1) * nPageSize // Define o comeco da pagina escolhida

    // Alias arquivo temporario
    cTmp := CriaTrab(,.F.)

    // Monta expressoes para query
    cBranchSA1  := xFilial( "SA1" )

    If !(cSGBD $ "ORACLE|POSTGRES|DB2") .and. cSGBD <> "MYSQL" // SQL e demais bancos
        cCond       := " SA1.R_E_C_N_O_ NOT IN ( SELECT TOP " + CValToChar(nInitPage)
        cCond       += " SA1SUB.R_E_C_N_O_ FROM "+ RetSqlName("SA1") +" SA1SUB WHERE SA1SUB.A1_FILIAL = '" + cBranchSA1 + "' AND "
    Else
        cCond       := " SA1.R_E_C_N_O_ NOT IN ( SELECT"
        cCond       += " SA1SUB.R_E_C_N_O_ FROM "+ RetSqlName("SA1") +" SA1SUB WHERE SA1SUB.A1_FILIAL = '" + cBranchSA1 + "' AND "
    EndIf
    //Filtro de busca via searchKey
    If !Empty(cSearchKey)
        cCond   += "(SA1SUB.A1_COD LIKE '%"+cSearchKey+"%' "
        cCond   +=      " OR SA1SUB.A1_NOME LIKE '%"+cSearchKey+"%') AND "
    EndIf

    If cSGBD $ "ORACLE"
        cCond   += " SA1SUB.D_E_L_E_T_ = ' ' AND ROWNUM < " +cValToChar(nInitPage)+ " ) AND "
    ElseIf cSGBD == "POSTGRES" .or. cSGBD == "MYSQL" .or. cSGBD == "DB2"
        cCond   += " SA1SUB.D_E_L_E_T_ = ' ' "
        cCond   += " LIMIT " +cValToChar(nInitPage)
        cCond   += " ) AND "
    Else
        cCond   += " SA1SUB.D_E_L_E_T_ = ' ' "
        cCond   += " ORDER BY SA1SUB.A1_NOME) AND "
    EndIf

    If !Empty(cSearchKey)
        cCond   += "(SA1.A1_COD LIKE '%"+cSearchKey+"%' "
        cCond   += " OR SA1.A1_CGC LIKE '%"+cSearchKey+"%' "
        cCond   += " OR SA1.A1_NOME LIKE '%"+cSearchKey+"%') AND "
    EndIf

    If SA1->(ColumnPos("A1_MSBLQL")) > 0
        cCond   += "A1_MSBLQL <> '1' AND "
    EndIf

    cCond   += " A1_COD <> '"+Space(TamSx3("A1_COD")[1])+"' AND "


    cCond       := "%" + cCond + "%"

    BEGINSQL ALIAS cTmp
        /*--------------------------------------------------------------------------------------------------
          Query responsavel por trazer todos os Clientes possiveis que podem ser selecionados
        --------------------------------------------------------------------------------------------------*/
        SELECT
            // Client
            SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_CGC, SA1.A1_PESSOA, SA1.R_E_C_N_O_

        FROM %Table:SA1% SA1

        WHERE
            %exp:cCond%
            SA1.A1_FILIAL = %exp:cBranchSA1% AND 
            SA1.%NotDel%

        ORDER BY
            SA1.A1_NOME
    ENDSQL
    
    dbSelectArea(cTmp)

    oClients["hasNext"] := .F. // Propriedade para controle de paginas
    oClients["clients"] := {}  // Array para composicao dos clientes
        
    If !(cTmp)->(EoF())
        For nI := 1 to nPageSize
            If (cTmp)->(EoF())
                Exit
            Else 
                oJsonTmp := JsonObject():New()
                oJsonTmp["id"]:= (cTmp)->A1_COD  // ID do Cliente
                oJsonTmp["unit"]:= (cTmp)->A1_LOJA  // Loja do cliente
                oJsonTmp["name"]:= EncodeUTF8((cTmp)->A1_NOME)  // Nome do cliente
                if !Empty((cTmp)->A1_CGC)
                    if (cTmp)->A1_PESSOA == 'F'
                        oJsonTmp["cgc"]:= TRANSFORM((cTmp)->A1_CGC, "@R 999.999.999-99")   // CPF
                    else 
                        oJsonTmp["cgc"]:= TRANSFORM((cTmp)->A1_CGC, "@R 99.999.999/9999-99")   // CNPJ
                    endif
                else
                    oJsonTmp["cgc"]:= ''
                endif
                Aadd(oClients["clients"],oJsonTmp)
                (cTmp)->(dbSkip())
            EndIf
        Next nI
        If !(cTmp)->(EoF())
            oClients["hasNext"] := .T.
        Endif
    EndIf

    (cTmp)->(dbCloseArea())

    If !lRet
        oMessages["detailMessage"] := EncodeUTF8(oMessages["detailMessage"])
        oClients := oMessages
        SetRestFault(Val(oMessages["code"]),oMessages["detailMessage"])
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadCC
    Carrega os centros de custo disponiveis no objeto do response
    @author Igor Sousa do Nascimento
    @since 10/11/2019
    @version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function LoadCC(nPage,nPageSize,cSearchKey,lDefault,oCosts)

    Local aUser      As Array
    Local cTmp       As Character
    Local cBranchCTT As Character
    Local cBranchRD0 As Character
    Local cCond      As Character
    Local cCondCTT   As Character
    Local cSGBD      As Character
    Local lRet       As Logical
    Local nInitPage  As Numeric
    Local nI         As Numeric
    Local oJsonTmp   As Object
    Local oMessages  As Object
    Local aFilter    As Array
    Local lSyncReserve As Logical

    Default nPage      := 1
    Default nPageSize  := 10
    Default cSearchKey := ""
    Default lDefault   := .T.
    Default oCosts     := JsonObject():New()

    aUser    := {}
    aFilter  := {}
    cCond    := ""
    cCondCTT := ""
    cSGBD    := Upper(TCGetDB())
    lRet     := .T.
    oMessages:= JsonObject():New()

    lSyncReserve := SuperGetMV( "MV_MPCSCTT", .F., .F. )

    nInitPage := (nPage - 1) * nPageSize // Define o comeco da pagina escolhida

    cTmp := CriaTrab(,.F.)

    cBranchCTT  := xFilial("CTT")
    cBranchRD0  := xFilial("RD0")

    oCosts["hasNext"] := .F. // Propriedade para controle de paginas
    oCosts["items"]   := {} 

    If Empty(oCosts["items"])
        If !(cSGBD $ "ORACLE|POSTGRES|DB2") .and. cSGBD <> "MYSQL" // SQL e demais bancos
            cCond       := " CTT.R_E_C_N_O_ NOT IN ( SELECT TOP " + CValToChar(nInitPage)
            cCond       += " CTTSUB.R_E_C_N_O_ FROM "+ RetSqlName("CTT") +" CTTSUB WHERE CTTSUB.CTT_FILIAL = '" + cBranchCTT + "' AND "
        Else
            cCond       := " CTT.R_E_C_N_O_ NOT IN ( SELECT"
            cCond       += " CTTSUB.R_E_C_N_O_ FROM "+ RetSqlName("CTT") +" CTTSUB WHERE CTTSUB.CTT_FILIAL = '" + cBranchCTT + "' AND "
        EndIf
        //Filtro de busca via searchKey
        If !Empty(cSearchKey)
            cCond   += "(CTTSUB.CTT_CUSTO LIKE '%"+cSearchKey+"%' "
            cCond   +=      " OR CTTSUB.CTT_DESC01 LIKE '%"+cSearchKey+"%') AND "
        EndIf

        If cSGBD $ "ORACLE"
            cCond   += " CTTSUB.D_E_L_E_T_ = ' ' AND ROWNUM < " +cValToChar(nInitPage)+ " ) AND "
        ElseIf cSGBD == "POSTGRES" .or. cSGBD == "MYSQL" .or. cSGBD == "DB2"
            cCond   += " CTTSUB.D_E_L_E_T_ = ' ' "
            cCond   += " LIMIT " +cValToChar(nInitPage)
            cCond   += " ) AND "
        Else
            cCond   += " CTTSUB.D_E_L_E_T_ = ' ' "
            cCond   += " ORDER BY CTTSUB.CTT_DESC01) AND "
        EndIf

        If !Empty(cSearchKey)
            cCond   += "(CTT.CTT_CUSTO LIKE '%"+cSearchKey+"%' "
            cCond   +=      " OR CTT.CTT_DESC01 LIKE '%"+cSearchKey+"%') AND "
        EndIf
        
        If CTT->(ColumnPos("CTT_MSBLQL")) > 0
            cCond   += "CTT_MSBLQL <> '1' AND "
        EndIf

        If CTT->(ColumnPos("CTT_BLOQ")) > 0
            cCond   += "CTT_BLOQ <> '1' AND "
        EndIf

        if lDefault
            cCondCTT += "AND RD0.RD0_USER = '"+__cUserID+"' "
            cCond += "RD0.RD0_USER = '"+__cUserID+"' AND "
        endif

        If lSyncReserve
            cCond   += "CTT_INTRES = '1' AND "
        EndIf

        cCondCTT    := "%" + cCondCTT + "%"
        cCond       := "%" + cCond + "%"

        BEGINSQL ALIAS cTmp
            SELECT DISTINCT
                CTT.CTT_CUSTO, CTT.CTT_DESC01, CTT.R_E_C_N_O_, COALESCE(RD0.RD0_USER, '') RD0USER
            FROM %Table:CTT% CTT
                LEFT JOIN %Table:RD0% RD0 ON RD0.RD0_FILIAL = %exp:cBranchRD0% AND CTT.CTT_CUSTO = RD0.RD0_CC %exp:cCondCTT%
            WHERE
                %exp:cCond%
                CTT.CTT_FILIAL = %exp:cBranchCTT% AND 
                CTT.%NotDel%
            ORDER BY
                CTT.CTT_DESC01
        ENDSQL
        
        dbSelectArea(cTmp)
            
        If !(cTmp)->(EoF())
            For nI := 1 to nPageSize
                If (cTmp)->(EoF())
                    Exit
                Else
                    oJsonTmp := JsonObject():New()
                    oJsonTmp["cc_code"]:= (cTmp)->CTT_CUSTO
                    oJsonTmp["cc_description"]:= EncodeUTF8((cTmp)->CTT_DESC01) 

                    If AllTrim(__cUserId) == AllTrim((cTmp)->RD0USER)
                        oJsonTmp["cc_default"] := .T.
                    else
                        oJsonTmp["cc_default"] := .F.       
                    EndIf
                    
                    Aadd(oCosts["items"],oJsonTmp)
                    (cTmp)->(dbSkip())
                EndIf
            Next nI
            If !(cTmp)->(EoF())
                oCosts["hasNext"] := .T.
            Endif
        EndIf

        (cTmp)->(dbCloseArea())
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Currencies
    Carrega as moedas disponiveis no objeto do response
    @author Leonardo Castro
    @since 28/08/2017
    @version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function Currencies(oCurrence,nPage,nPageSize)

    Local aCurrence  As Array
    Local cBranchCTO As Character
    Local nI         As Numeric
    Local oJsonTmp   As Object

    Default nPage     := 1
    Default nPageSize := 10
    Default oCurrence := JsonObject():New()

    aCurrence := { {"1","Real","R$"},;
                   {"2","Dolar","U$"},;
                   {"3","Euro","?"},;
                   {"9","Outras",""} }
    // Monta expressoes para query
    cBranchCTO  := xFilial( "CTO" )

    oCurrence["hasNext"] := .F. // Propriedade para controle de paginas
    oCurrence["types"] := {}  // Array para composicao das Moedas
        
    For nI := 1 to Len(aCurrence)
        oJsonTmp := JsonObject():New()
        oJsonTmp["id"]:= aCurrence[nI,1]
        oJsonTmp["description"]:= aCurrence[nI,2]
        oJsonTmp["symbol"]:= aCurrence[nI,3]
        Aadd(oCurrence["types"],oJsonTmp)
    Next nI

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Locations
    Carrega os clientes disponiveis no objeto do response
    @author Totvs SA
    @since 28/08/2017
    @version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function Locations(nPage,nPageSize,lInter,cSearchKey,oDestinations)
    Local cTmp       As Character
	Local cBranchSX5 As Character
    Local lRet       As Logical
	Local nInitPage  As Numeric
	Local nI         As Numeric
	Local oJsonTmp   As Object
    Local oMessages  As Object
	Local cCond      As Character
	Local cCondPag   As Character
    Local cSGBD      As Character
	
	Default oDestinations := JsonObject():New()
	Default nPage      := 1
	Default nPageSize  := 10
    Default lInter    := .T.
    Default cSearchKey := ""

    lRet      := .T.
    oMessages := JsonObject():New()
    
    cCond     := ""
    cCondPag  := ""
    cSGBD     := Alltrim(Upper(TCGetDB()))
	nInitPage := ( (nPage - 1) * nPageSize ) // Define o comeco da pagina escolhida

	// Alias arquivo temporario
	cTmp := CriaTrab(,.F.)
	
	// Monta expressoes para query
	cBranchSX5  := xFilial( "SX5" )

    If !(cSGBD $ "ORACLE|POSTGRES|DB2") .and. cSGBD <> "MYSQL" // SQL e demais bancos
        cCondPag := " SX5.R_E_C_N_O_ NOT IN (SELECT TOP " + cValToChar(nInitPage) + " R_E_C_N_O_ FROM " + RetSqlName("SX5") + " SX51 "
        cCondPag += "WHERE SX51.X5_FILIAL = '" + xFilial("SX5") + "' AND "
    Else
        cCondPag := " SX5.R_E_C_N_O_ NOT IN (SELECT R_E_C_N_O_ FROM " + RetSqlName("SX5") + " SX51 "
        cCondPag += "WHERE SX51.X5_FILIAL = '" + xFilial("SX5") + "' AND "
    EndIf
    If lInter
        cCond := "SX5.X5_TABELA IN ('BH')  AND "
        cCondPag += "SX51.X5_TABELA IN ('BH') AND "
    Else
        cCond := "SX5.X5_TABELA IN ('12')  AND "
        cCondPag += "SX51.X5_TABELA IN ('12') AND "
    EndIf
    If !Empty(cSearchKey)
        cCond += "(SX5.X5_CHAVE LIKE '%"+cSearchKey+"%' "
        cCond += " OR SX5.X5_DESCRI LIKE '%"+cSearchKey+"%') AND "
        cCondPag += "(SX51.X5_CHAVE LIKE '%"+cSearchKey+"%' "
        cCondPag += " OR SX51.X5_DESCRI LIKE '%"+cSearchKey+"%') AND "
    EndIf

    If cSGBD $ "ORACLE"
        cCondPag += "SX51.D_E_L_E_T_= ' ' AND ROWNUM < " +cValToChar(nInitPage)+ " ) AND "
    ElseIf cSGBD == "POSTGRES" .or. cSGBD == "MYSQL" .or. cSGBD == "DB2"
        cCondPag += "SX51.D_E_L_E_T_= ' ' "
        cCondPag += "LIMIT " +cValToChar(nInitPage)
        cCondPag += " ) AND "
    Else
        cCondPag += "SX51.D_E_L_E_T_= ' ' ) AND "
    EndIf

    cCond := "%" + cCond  + "%"
    cCondPag := "%" + cCondPag + "%"
	
	BEGINSQL ALIAS cTmp
		SELECT
			SX5.X5_TABELA, SX5.X5_CHAVE, SX5.X5_DESCRI
		FROM %Table:SX5% SX5
		WHERE
            %exp:cCond%
            SX5.X5_FILIAL = %exp:cBranchSX5% AND 
            %exp:cCondPag%
			SX5.%NotDel%
		ORDER BY
			SX5.X5_TABELA, SX5.X5_CHAVE, SX5.X5_DESCRI
	ENDSQL
	
	oDestinations["hasNext"] := .F. 	 // Propriedade para controle de paginas
	oDestinations["destinations"] := {}  // Array para composicao dos clientes
	
	dbSelectArea(cTmp)

	If !(cTmp)->(EoF())
		For nI := 1 to nPageSize  
			If (cTmp)->(EoF())
				Exit
			Else
				oJsonTmp := JsonObject():New()
				oJsonTmp["id"]:= (cTmp)->X5_CHAVE  
				oJsonTmp["name"]:= EncodeUTF8(OemtoAnsi(AllTrim((cTmp)->X5_DESCRI)))
				oJsonTmp["international"]:= AllTrim((cTmp)->X5_TABELA) == "BH" // indica se é internacional
				
				Aadd(oDestinations["destinations"],oJsonTmp)
				(cTmp)->(dbSkip())
			EndIf		  
        Next nI
        If !(cTmp)->(EoF())
            oDestinations["hasNext"] := .T.
        Endif
    EndIf

    (cTmp)->(dbCloseArea())

    If !lRet
        oMessages["detailMessage"] := EncodeUTF8(oMessages["detailMessage"])
        oDestinations := oMessages
        SetRestFault(Val(oMessages["code"]),oMessages["detailMessage"])
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XpenseType
    Carrega os tipos de despesas
    @author Totvs SA
    @since 28/08/2017
    @version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function XpenseType(nPage,nPageSize,cSearchKey,oItemsTypes,dDepartDate)
    Local cTmp       As Character
	Local cBranchFLG As Character
	Local cIniTPage  As Character
    Local cFilter    As Character
    Local cSGBD      As Character
    Local cExpenseType As Character
    Local lRet       As Logical
	Local nInitPage  As Numeric
    Local nCount     As Numeric
	Local oJsonTmp   As Object
    Local oMessages  As Object
	
	Default oItemsTypes := JsonObject():New()
	Default nPage      := 1
	Default nPageSize  := 10
	Default cSearchKey := ""
    Default dDepartDate := dDatabase

    lRet      := .T.
    oMessages := JsonObject():New()

	nInitPage := ( (nPage - 1) * nPageSize ) // Define o comeco da pagina escolhida
	aFilter   := {}
	cInitPage := ""
    cSGBD     := Alltrim(Upper(TCGetDB()))
    cExpenseType := ''
    nCount    := 0
	
	// Alias arquivo temporario
	cTmp := CriaTrab(,.F.)	
	
	// Monta expressoes para query
	cBranchFLG  := xFilial("FLG") 
	
    cFilter := "% FLG.FLG_FILIAL = '" + xFilial("FLG") + "' "
    If !(cSGBD $ "ORACLE|POSTGRES|DB2") .and. cSGBD <> "MYSQL" // SQL e demais bancos
        cIniTPage := "%FLG.R_E_C_N_O_ NOT IN (SELECT TOP " + cValToChar(nInitPage) + " FLG1.R_E_C_N_O_ FROM " + RetSqlName("FLG") + " FLG1 "
        cIniTPage += "WHERE FLG1.FLG_FILIAL = '" + cBranchFLG + "' "
    Else
        cIniTPage := "%FLG.R_E_C_N_O_ NOT IN (SELECT FLG1.R_E_C_N_O_ FROM " + RetSqlName("FLG") + " FLG1 "
        cIniTPage += "WHERE FLG1.FLG_FILIAL = '" + cBranchFLG + "' "
    EndIf
    If !Empty(cSearchKey)
        cFilter   += "AND (FLG.FLG_CODIGO LIKE '%"+cSearchKey+"%' "
        cFilter   +=      " OR FLG.FLG_DESCRI LIKE '%"+cSearchKey+"%') "
        cIniTPage += "AND (FLG1.FLG_CODIGO LIKE '%"+cSearchKey+"%' "
        cIniTPage +=      " OR FLG1.FLG_DESCRI LIKE '%"+cSearchKey+"%') "
    EndIf
    cIniTPage += "AND FLG1.D_E_L_E_T_ = ' ' " 
    If cSGBD $ "ORACLE"
        cIniTPage += "AND ROWNUM < " +cValToChar(nInitPage)+ " ) %"
    ElseIf cSGBD == "POSTGRES" .or. cSGBD == "MYSQL" .or. cSGBD == "DB2"
        cIniTPage += "LIMIT " +cValToChar(nInitPage)+ " ) %"
    Else
        cIniTPage += ") %"
    EndIf

    If FLG->(ColumnPos("FLG_MSBLQL")) > 0
        cFilter   += " AND FLG_MSBLQL <> '1' "
    EndIf

    cFilter   += " AND %"
	
	BEGINSQL ALIAS cTmp
		SELECT
			FLG.FLG_FILIAL, FLG.FLG_CODIGO, FLG.FLG_DESCRI, FLG.FLG_LIMITE, FLG.FLG_GRUPO, 
            FWD_LOCAL, FLS_VALUNI, FLS_DTINI, FLS_DTFIM, FLS_LIMITS
		FROM %Table:FLG% FLG
        INNER JOIN %Table:FWC% FWC 
            ON FWC_FILIAL = %xFilial:FWC%
            AND FWC_DESPES = FLG_CODIGO
            AND FWC.%NotDel%
        INNER JOIN %Table:FWD% FWD 
            ON FWD_FILIAL = %xFilial:FWD%
            AND FWC_CODIGO = FWD_CODIGO 
            AND FWD.%NotDel%
        LEFT JOIN %Table:FLS% FLS 
            ON FLS_FILIAL = %xFilial:FLS%
            AND FLS_CODIGO = FLG_CODIGO
            AND FLS_DTINI <= %exp:dDepartDate%
            AND (FLS_DTFIM >= %exp:dDepartDate% OR FLS_DTFIM = ' ')
            AND FLS.%NotDel%
		WHERE
			%exp:cIniTPage% AND
            %exp:cFilter% 
			FLG.%NotDel% 
		ORDER BY
			FLG.FLG_FILIAL, FLG.FLG_DESCRI
	ENDSQL
	
    oItemsTypes["hasNext"] := .F. 		// Propriedade para controle de paginas
	oItemsTypes["types"] := {}  // Array para composicao dos clientes
	
	dbSelectArea(cTmp)

	If !(cTmp)->(EoF())
		While ( cTmp )->( !Eof() )    
            If nCount == nPageSize
                Exit
            Else
                /* TODO - sugerir a troca do nome da propriedade do payload de locals para locales */
                If cExpenseType == (cTmp)->FLG_CODIGO
                    AAdd( oJsonTmp["locals"], (cTmp)->FWD_LOCAL)
                Else
                    IF oJsonTmp != Nil
                        nCount++ 
                        Aadd( oItemsTypes["types"], oJsonTmp )
                        oJsonTmp := Nil                        
                    EndIf

                    oJsonTmp := JsonObject():New()
                    oJsonTmp["id"]:= (cTmp)->FLG_CODIGO
                    oJsonTmp["name"]:= EncodeUTF8((cTmp)->FLG_DESCRI)
                    oJsonTmp["unit_value"]:= (cTmp)->FLS_VALUNI
                    oJsonTmp["unit_limit"]:= (cTmp)->FLS_LIMITS
                    oJsonTmp["limit_type"]:= (cTmp)->FLG_LIMITE
                    oJsonTmp["locals"] := {}
                
                    Aadd( oJsonTmp["locals"], (cTmp)->FWD_LOCAL)
                EndIf
                
                cExpenseType := (cTmp)->FLG_CODIGO

                (cTmp)->(dbSkip())
            EndIf			  
        End      

        IF oJsonTmp != Nil
            Aadd( oItemsTypes["types"], oJsonTmp )
        EndIf
        
        If !(cTmp)->(EoF())
            oItemsTypes["hasNext"] := .T.
        Endif
    EndIf

    (cTmp)->(dbCloseArea())

    If !lRet
        oMessages["detailMessage"] := EncodeUTF8(oMessages["detailMessage"])
        oItemsTypes := oMessages
        SetRestFault(Val(oMessages["code"]),oMessages["detailMessage"])
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JSONFromTo
    Carrega objeto com campos solicitados pelo usuario
    @author Igor Sousa do Nascimento
    @since 02/10/2017
    @param aFields = campos do request
    @param aDePara = Array com campos do mobile e do protheus (De/Para)
            aDePara[n][1] = campo ou objeto do request
            aDePara[n][2] = se array 
            aDePara[n][3] = conteudo a ser atribuido
            aDePara[n][4] = se objeto JSON (.T. ou .F.)
            aDePara[n][5] = se propriedade de objeto JSON (.T. ou .F.)
            aDePara[n][6] = propriedades do array (olha para posicao 3)
            obs1: Caso [n][3] for um campo, a tabela deve estar aberta
            obs2: Conteudo fora dessa estrutura devera ser tratado na funcao
/*/
//-------------------------------------------------------------------
Static Function JSONFromTo(aFields,aDePara)
    Local aJsonProp  As Array
    Local cCampoApp  As Character
    Local cJsonProp  As Character
    Local nT         As Numeric
    Local nX         As Numeric
    Local nY         As Numeric
    Local nZ         As Numeric
    Local nTotalAdv1 As Numeric
    Local nTotalAdv2 As Numeric
    Local nTotalAdv3 As Numeric
    Local oJsonObj   As Object

    Default aFields := {}
    Default aDePara := {}

    oJsonObj := JsonObject():New()

    If !Empty(aFields) .and. !Empty(aDePara)
        For nT := 1 to Len(aFields)
            If (nY := AScan(aDePara,{|x| x[1] == aFields[nT] }) ) > 0
                cCampoApp := aDePara[nY][1]
                Do Case
                    Case aDePara[nY][4]   // Se for campo de objeto
                        While aDePara[nY][1] = cCampoApp 
                            If aDePara[nY][3] <> Nil    
                                cJsonProp := '["' + StrTran(aDePara[nY][1],'.','"]["') + '"]'
                                If aDePara[nY][2]   // Trata array
                                    oJsonObj&(cJsonProp) := {}
                                    aAux := &(aDePara[nY][3])
                                    // Variaveis utilizadas no calculo do saldo totalizador
                                    nTotalAdv1 := 0
                                    nTotalAdv2 := 0
                                    nTotalAdv3 := 0
                                    // Monta array de adiantamentos
                                    For nX := 1 to Len(aAux)
                                        oAux := JsonObject():New()  // Objeto auxiliar onde serao criadas as propriedades
                                        For nZ := 1 to Len(aDePara[nY][6])
                                            cArrayProp := '["' + aDePara[nY][6][nZ] + '"]'
                                            oAux&(cArrayProp):= aAux[nX,nZ]
                                            If aAux[nX][5] == '4'
                                                If "current" $ cArrayProp
                                                    nTotalAdv1 += aAux[nX,nZ]
                                                ElseIf "dolar" $ cArrayProp
                                                    nTotalAdv2 += aAux[nX,nZ]
                                                ElseIf "euro" $ cArrayProp
                                                    nTotalAdv3 += aAux[nX,nZ]
                                                EndIf
                                            EndIf
                                        Next nZ
                                        Aadd(oJsonObj&(cJsonProp),oAux)
                                    Next nX
                                Else
                                    oJsonObj&(cJsonProp) := &(aDePara[nY][3])
                                EndIf
                            Else
                                cJsonProp := ""
                                aJsonProp := StrToKarr(aDePara[nY][1],".")
                                For nZ := 1 to Len(aJsonProp)
                                    cJsonProp += '["' + aJsonProp[nZ] + '"]'
                                    If ValType(oJsonObj&(cJsonProp)) == "U"  // Cria objeto dentro do objeto
                                        oJsonObj&(cJsonProp) := JsonObject():New()   // Cria objeto
                                    EndIf
                                Next nZ
                                ASize(aJsonProp,0)
                            EndIf
                            IF nY < len( aDePara )
                                nY++    // Percorre para proxima propriedade
                            Else
                                cCampoApp := '' // Para sair do while
                            EndIf
                         EndDo
                    Case aDePara[nY][5]   // Se for propriedade de objeto
                        cJsonProp := ""
                        aJsonProp := StrToKarr(aDePara[nY][1],".")
                        For nZ := 1 to Len(aJsonProp)
                            cJsonProp += '["' + aJsonProp[nZ] + '"]'
                            If nZ < Len(aJsonProp)     // Ultima propriedade nao e objeto
                                If ValType(oJsonObj&(cJsonProp)) == "U"  // Cria objeto dentro do objeto
                                    oJsonObj&(cJsonProp) := JsonObject():New()   // Cria objeto
                                EndIf
                            EndIf
                        Next nZ
                        oJsonObj&(cJsonProp) := &(aDePara[nY][3])   // Grava propriedade
                        cJsonProp := ""
                        ASize(aJsonProp,0)
                    Case aDePara[nY][2]     // Se array
                        cJsonProp := ""
                        cArrayProp:= ""
                        aJsonProp := StrToKarr(aDePara[nY][1],".")
                        For nZ := 1 to Len(aJsonProp)
                            cJsonProp += '["' + aJsonProp[nZ] + '"]'
                            If ValType(oJsonObj&(cJsonProp)) == "U" .and. nZ < Len(aJsonProp)  // Cria objeto dentro do objeto
                                oJsonObj&(cJsonProp) := JsonObject():New()   // Cria objeto
                            EndIf
                        Next nZ
                        oJsonObj&(cJsonProp) := {}
                        aAux := &(aDePara[nY][3])
                        // Variaveis utilizadas no calculo do saldo totalizador
                        nTotalAdv1 := 0
                        nTotalAdv2 := 0
                        nTotalAdv3 := 0
                        // Monta array de adiantamentos
                        If Type("aAux") == "A"
                            For nX := 1 to Len(aAux)
                                oAux := JsonObject():New()  // Objeto auxiliar onde serao criadas as propriedades
                                For nZ := 1 to Len(aDePara[nY][6])
                                    cArrayProp := '["' + aDePara[nY][6][nZ] + '"]'
                                    oAux&(cArrayProp):= aAux[nX,nZ]
                                    If "current" $ cArrayProp
                                        nTotalAdv1 += aAux[nX,nZ]
                                    ElseIf "dolar" $ cArrayProp
                                        nTotalAdv2 += aAux[nX,nZ]
                                    ElseIf "euro" $ cArrayProp
                                        nTotalAdv3 += aAux[nX,nZ]
                                    EndIf
                                Next nZ
                                Aadd(oJsonObj&(cJsonProp),oAux)
                            Next nX
                        EndIf
                    Otherwise
                        oJsonObj[cCampoApp] := &(aDePara[nY][3])
                EndCase
            EndIf
        Next nT
    EndIf

Return oJsonObj

//-------------------------------------------------------------------
/*/{Protheus.doc} HasAttch
    Verifica se a despesa posicionada possui anexo
    @author Igor Sousa do Nascimento
    @since 28/03/2019
    @version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function HasAttch()
    Local aArea  As Array
    Local lRet   As Logical
    Local cKey   As Character
    Local cAlias As Character

    cAlias := Alias()

    If !Empty(cAlias)
        cKey := xFilial("FLE") +;
                (cAlias)->FLE_TIPO +;
                (cAlias)->FLE_PRESTA +;
                (cAlias)->FLE_PARTIC +;
                (cAlias)->FLE_ITEM

        aArea := GetArea()

        dbSelectArea("AC9")
        AC9->(dbSetOrder(2))    // AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ

        If AC9->(dbSeek(xFilial("AC9")+"FLE"+xFilial("FLE")+Alltrim(cKey)))
            dbSelectArea("ACB")
            ACB->(dbSetOrder(1))    // ACB_FILIAL+ACB_CODOBJ
            If ACB->(dbSeek(xFilial("ACB")+AC9->AC9_CODOBJ))
                lRet := .T.
            Else
                lRet := .F.
            EndIf
        Else
            lRet := .F.
        EndIf
        RestArea(aArea)
    Else
        lRet := .F.
    EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} RetTMobile
    Retorna o total de uma prestação via query nos itens.
    @author Robson Santos
    @since 27/02/2020
    @version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function RetTMobile()

Local aArea := GetArea()
Local nRet := 0
Local cQry := ""

cQry := " SELECT SUM(FLE_VALREE) VALREE FROM "+RetSqlName("FLE")+ " " 
cQry += " WHERE FLE_PRESTA = '"+AllTrim(FLF_PRESTA)+"' "
cQry += " AND FLE_TIPO = '"+AllTrim(FLF_TIPO)+"' "
cQry += " AND FLE_PARTIC = '"+AllTrim(FLF_PARTIC)+"' "
cQry += " AND D_E_L_E_T_ = ' ' "
cQry += " AND FLE_FILIAL = '"+XFilial("FLE")+"' "
cQry += " GROUP BY FLE_FILIAL, FLE_TIPO, FLE_PRESTA, FLE_PARTIC "

If Select("TMPXPENSE") > 0
    TMPXPENSE->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS "TMPXPENSE"

TMPXPENSE->(dbGoTop())

nRet := TMPXPENSE->VALREE

TMPXPENSE->(dbCloseArea())

RestArea(aArea)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AltStatus
    Altera o status de uma prestação para aberto. 
    OBS: A prestação tem que estar previamente posicionada.
    @author Robson Santos
    @since 27/02/2020
    @version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function AltStatus()

If F677EXCAPR(FLF->FLF_TIPO, FLF->FLF_PRESTA, FLF->FLF_PARTIC)

    dbSelectArea("FLF")
    RecLock("FLF", .F.)
    FLF->FLF_STATUS := "1"
    FLF->(MsRUnLock())
    
EndIf

Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadAttach
Função auxiliar para separar os registros do endpoint por filial

@param cExpenseID, string, código da prestação
@param cType, string, tipo da prestação ( 1 = viagem e 2 = avulsa )
@param cItemID, string, código do item da prestação a verificar
@param @oAttach, object, objeto com o anexo
@param lChecked, boolean, Se .T. o serviço está executando uma aprovação.

@return boolean, indica se conseguiu carregar o anexo.

@author  Marcia Junko
@since   02/07/2020
/*/
//-------------------------------------------------------------------------------------
Static Function LoadAttach( cExpenseID, cType, cItemID, oAttach, lChecked )
    Local aSvAlias  := GetArea()
    Local aSvFLF    := FLF->( GetArea() )
    Local aSvFLE    := FLE->( GetArea() )
    Local aUser     := {}
    Local aImg      := {}
    Local aSeek     := {}
    Local cUser     := ''
    Local lRet      := .T.
    Local oModel677 := NIL
    Local oModelFLE := NIL
    Local oMessages := NIL

    Default lChecked := .F.

    oMessages    := JsonObject():New()

    If FINXUser( __cUserID, @aUser, .F. )
        dbSelectArea( "FLE" )
        dbSetOrder( 1 )
        dbSelectArea( "FLF" )
        dbSetOrder( 1 )

        cUser := aUser[1]
        If lChecked .And. FLF->( MSSeek( xFilial( "FLF" ) + cType + cExpenseID ) )
            cUser := FLF->FLF_PARTIC
        EndIf

        If FLE->( dbSeek( xFilial( "FLE" ) + cType + cExpenseID + cUser + cItemID ) )
            FLF->( dbSeek( xFilial( "FLF" ) + cType + cExpenseID + cUser ) )
            
            oModel677:= FWLoadModel( "FINA677" )
            oModel677:SetOperation( MODEL_OPERATION_VIEW )
            F677LoadMod( oModel677, MODEL_OPERATION_VIEW )
            oModel677:Activate()
            
            oModelFLE:= oModel677:GetModel( "FLEDETAIL" )
            aSeek := { { "FLE_FILIAL", xFilial( "FLE" ) } ,; 
                       { "FLE_TIPO", cType } ,; 
                       { "FLE_PRESTA", cExpenseID } ,; 
                       { "FLE_PARTIC", cUser } ,;
                       { "FLE_ITEM", cItemID } }
            oModelFLE:SeekLine( aSeek )
            
            aImg := F677ImgApp( 2, oModel677 )
            If Len( aImg ) > 0 .and. ValType( aImg[2] ) == "C"
                oAttach[ "name" ]    := aImg[1]
                oAttach[ "content" ] := aImg[2]
            Else
                oMessages[ "code" ] 	:= "404"
                oMessages[ "message" ]	:= "Not Found"
                oMessages[ "detailMessage" ] := STR0008 //"Nao foi encontrado anexo para essa despesa."   // "N?o foi encontrado anexo para essa despesa."
                lRet := .F.
            EndIf

            oModel677:DeActivate()
            oModel677:Destroy()
            oModel677 := NIL
        EndIf
    Else
        oMessages[ "code" ] 	:= "403"
        oMessages[ "message" ]	:= "Forbidden"
        oMessages[ "detailMessage" ] := STR0003   // "Usu rio inativo no sistema ou n?o autorizado para esta opera‡?o."
        lRet := .F.
    EndIf

    If !lRet
        oAttach := oMessages
        SetRestFault( Val( oMessages[ "code" ] ), oMessages[ "detailMessage" ] )
    EndIf

    RestArea( aSvAlias )
    RestArea( aSvFLF )
    RestArea( aSvFLE )

    FWFreeArray( aSvAlias )
    FWFreeArray( aSvFLF )
    FWFreeArray( aSvFLE )
    FWFreeArray( aUser )
    FWFreeArray( aImg )
    FWFreeArray( aSeek )
    FreeObj( oModel677 )
    FreeObj( oModelFLE )
    FreeObj( oMessages )
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} isApprover
Verifica se o usuário é aprovador ou substituto.

@param @oJSONResp, object, Objecto que armazena a informação do usuário.

@return boolean, indica se o usuário é um aprovador ou substituto
@author Totvs SA
@since 23/07/2020
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function isApprover( oJSONResp )
    Local aSvAlias   As Array
    Local cTmp       As Character
    Local cQuery     As Character
    Local cQryRD0    As Character
    
    aSvAlias := GetArea()
    cTmp := GetNextAlias()

    oJSONResp[ "isApprover" ] := .F. 

    cQryRD0 := " SELECT RD0_CODIGO FROM " + RetSqlName("RD0") + " RD0 " + ;
        "WHERE RD0.RD0_FILIAL = '" + xFilial("RD0") + "' AND RD0.RD0_USER = '" + __cUserId + "' AND RD0.D_E_L_E_T_ = ' ' "

    cQuery := "SELECT RD0_CODIGO FROM " + RetSqlName("RD0") + " RD0 " + ;
		"WHERE RD0.RD0_FILIAL = '" + xFilial("RD0") + "' " + ;
            "AND ( RD0_APROPC IN ( " + cQryRD0 + " ) OR RD0_APSUBS IN ( " + cQryRD0 + " ) ) " + ;
            "AND RD0.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery( cQuery )
    MPSysOpenQuery( cQuery, cTmp )

	If ( cTmp )->( !EoF() )
        oJSONResp[ "isApprover" ] := .T.   
    EndIf

    (cTmp)->( DbCloseArea() )

    RestArea( aSvAlias )
    FWFreeArray( aSvAlias )
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadBillInfo
Carrega informacoes do título da prestação de contas

@param cBranch, caracter, filial de busca do registro na FO7
@param cID, caracter, identificador do título da prestação de contas 
@param cStatus, caracter, status da prestação 

@return array, dados do título de uma prestação específica
    [1] - vencimento
    [2] - data da baixa
    [3] - banco de pagamento
    [4] - agência de pagamento
    [5] - conta de pagamento

@author Marcia Junko
@since 11/08/2020
/*/
//-------------------------------------------------------------------
Static Function LoadBillInfo( cBranch, cID, cStatus )
    Local aSvAlias      AS Array
    Local aInfo         AS Array
    Local cTmpAlias     AS Character
    Local cQuery        AS Character
    Local cBank         AS Character
    Local cBankBranch   AS Character
    Local cAccount      AS Character
    Local nLen          AS Numeric
    Local nLenAux       AS Numeric

    If cStatus $ '7|8' //Em avaliação do financeiro ou finalizada
        aInfo := {}
        cBank := ''
        cBankBranch := ''
        cAccount := ''
        nLen := 0
        nLenAux := 0

        aSvAlias := GetArea()

        /* TODO - Implementar hash de execução de querys*/
        cQuery := "SELECT FO7_PREFIX, FO7_TITULO, FO7_PARCEL, FO7_TIPO, " + ;
            " FO7_CLIFOR, FO7_LOJA, FO7_DTBAIX, FO7_RECPAG, E2_VENCTO, " + ;
            " A2_BANCO, A2_AGENCIA, A2_DVAGE, A2_NUMCON, A2_DVCTA " + ;
            " FROM " + RetSqlName( "FO7" ) + " FO7 " + ;
            " LEFT JOIN " + RetSqlName( "SE2" ) + " SE2 " + ;
                " ON E2_FILIAL = '" + xFilial( "SE2" ) + "' " + ;
                " AND E2_PREFIXO = FO7_PREFIX " + ;
                " AND E2_NUM = FO7_TITULO " + ;
                " AND E2_PARCELA = FO7_PARCEL " + ;
                " AND E2_TIPO = FO7_TIPO " + ;
                " AND E2_FORNECE = FO7_CLIFOR " + ;
                " AND E2_LOJA = FO7_LOJA " + ;
                " AND E2_ORIGEM = 'FINA677' " + ;
                " AND SE2.D_E_L_E_T_ = ' ' " + ;
            " LEFT JOIN " + RetSqlName( "SA2" ) + " SA2 " + ;
                " ON A2_FILIAL = '" + xFilial( "SA2" ) + "' " + ;
                " AND A2_COD = FO7_CLIFOR " + ;
                " AND A2_LOJA = FO7_LOJA " + ;
                " AND SA2.D_E_L_E_T_ = ' ' " + ;
            " WHERE FO7_FILIAL = '" + cBranch + "' " + ;
                " AND FO7_CODIGO = '" + cID + "' " + ;
                " AND FO7_RECPAG = 'P' " + ;
                " AND FO7.D_E_L_E_T_ = ' '"

        cQuery := ChangeQuery( cQuery )
        cTmpAlias := MPSysOpenQuery( cQuery )    

        IF ( cTmpAlias )->( !Eof() )
            If !Empty( ( cTmpAlias )->A2_BANCO )
                cBank := ( cTmpAlias )->A2_BANCO
            
                IF !Empty( ( cTmpAlias )->A2_AGENCIA )
                    cBankBranch := Alltrim( ( cTmpAlias )->A2_AGENCIA )

                    nLen := Len( cBankBranch )
                    nLenAux := nLen / 2

                    cBankBranch := Stuff( cBankBranch, nLenAux, nLenAux, Replicate( 'x', nLenAux )  )
                    
                    IF !Empty( ( cTmpAlias )->A2_DVAGE )
                        cBankBranch += '-' + Alltrim( ( cTmpAlias )->A2_DVAGE )
                    ENDIF
                ENDIF    

                IF !Empty( ( cTmpAlias )->A2_NUMCON )
                    cAccount := Alltrim( ( cTmpAlias )->A2_NUMCON )

                    nLen := Len( cAccount )
                    nLenAux := nLen / 2

                    cAccount := Stuff( cAccount, nLenAux, nLenAux , Replicate( 'x', nLenAux ) )

                    IF !Empty( ( cTmpAlias )->A2_DVCTA )
                        cAccount += '-' + Alltrim( ( cTmpAlias )->A2_DVCTA )
                    ENDIF
                ENDIF    
            ENDIF

            Aadd( aInfo, { ( cTmpAlias )->E2_VENCTO, ( cTmpAlias )->FO7_DTBAIX, cBank, cBankBranch, cAccount } )
        ENDIF

        ( cTmpAlias )->( DbCloseArea() )

        RestArea( aSvAlias )
        FWFreeArray( aSvAlias )
    EndIf
Return aInfo

//-------------------------------------------------------------------
/*/{Protheus.doc} GetApprovers
Carrega os códigos de participante que possuem o usuário logado como 
aprovador ou substituto

@param cApprover, caracter, código do participante

@return caracter, participantes que utilizam o usuário logado como 
aprovador ou substituto.

@author Marcia Junko
@since 15/10/2020
/*/
//-------------------------------------------------------------------
Static Function GetApprovers( cApprover )
    Local aSvAlias   As Array
    Local cTmpAlias  As Character
    Local cQuery     As Character
    Local cApprovers As Character    
    
    aSvAlias := GetArea()
    cTmpAlias := GetNextAlias()

    cQuery := "SELECT RD0_APROPC " + ;
            "FROM " + RetSqlName( "RD0" ) + " RD0 " + ;
		    "WHERE RD0.RD0_FILIAL = '" + xFilial( "RD0" ) + "' " + ;
                "AND RD0.RD0_APSUBS = '" + cApprover + "' " + ;
                "AND RD0.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery( cQuery )
    MPSysOpenQuery( cQuery, cTmpAlias )

    cApprovers := cApprover

    While ( cTmpAlias )->( !EoF() )
        cApprovers += ',' + ( cTmpAlias )->RD0_APROPC
        ( cTmpAlias )->( DbSkip() )
    End

    (cTmpAlias)->( DbCloseArea() )

    RestArea( aSvAlias )
    FWFreeArray( aSvAlias )
Return cApprovers

//-------------------------------------------------------------------
/*/{Protheus.doc} DeviationInfo
Função que atribui um texto informativo para o controle de desvio.

@param nDeviation, number, valor médio
@param nValue, number, valor do item da prestação.

@return caracter, texto informativo sobre o desvio na análise de valor
do item da despesa.

@author Marcia Junko
@since 31/03/2021
/*/
//-------------------------------------------------------------------
Static Function DeviationInfo( nDeviation As Numeric, nValue As Numeric ) As Character
    
    Local nTolerance    As Numeric
    Local nDays         As Numeric
    Local nAuxMin       As Numeric
    Local nAuxMax       As Numeric
    Local nPercent      As Numeric
    Local cInfo         As Character

    nTolerance  := 0
    nDays       := 0
    nAuxMin     := 0
    nAuxMax     := 0
    nPercent    := 0
    cInfo       := ''

    IF nDeviation == 0
        nDays := SuperGetMV( "MV_MPCDDES", .F., 30 ) //Define os dias a retroceder da data atual para o cáculo do desvio
        cInfo := I18N( STR0012, { Alltrim( Str( nDays ) ) } ) // "Não foram localizados registros aprovados desta despesa e local nos últimos #1 dias."
    Else
        nTolerance := SuperGetMV( "MV_MPCTOLD", .F., 10 ) //Define a tolerância do desvio
        IF nTolerance > 0
            nAuxMin := DeviationValue( 'MIN', nDeviation ) 
            nAuxMax := DeviationValue( 'MAX', nDeviation ) 
            IF nValue >= nAuxMin .And. nValue <= nAuxMax
                cInfo := STR0013 // "O valor informado está dentro da tolerância."
            ElseIf nValue > nAuxMax
                nPercent := Int( ( ( nValue - nDeviation ) / nDeviation ) * 100 )
                cInfo := I18N( STR0014, { nPercent } ) //"Esta despesa está #1%* acima do valor médio praticado nesta região "
            EndIf
        Else
            cInfo := STR0015 // "A tolerância do desvio não foi informada."
        EndIf
    EndIf
Return EncodeUTF8( cInfo )

//-------------------------------------------------------------------
/*/{Protheus.doc} DeviationValue
Função que calcula os valores de desvio de acordo com o tipo

@param cType, caracter, identifica o valor que será calculado. MIN ou MAX.
@param nDeviation, number, valor médio

@return number, valor da tolerância MIN ou MAX.

@author Marcia Junko
@since 31/03/2021
/*/
//-------------------------------------------------------------------
Static Function DeviationValue( cType As Character, nDeviation As Number ) As Numeric
    
    Local nTolerance As Numeric
    Local nValue As Numeric

    nTolerance := SuperGetMV( "MV_MPCTOLD", .F., 10 ) //Define a tolerância do desvio
    nValue := 0

    IF nTolerance > 0
        If cType == 'MIN'
            nValue := Round( nDeviation * ( 1 - ( nTolerance / 100 ) ), 2 )
        Else
            nValue := Round( nDeviation * ( 1 + ( nTolerance / 100 ) ), 2 )
        EndIf
    EndIf
Return nValue

//-------------------------------------------------------------------
/*/{Protheus.doc} NewAdvance
Cria uma solicitação de adiantamento

@param oExpenses, object, Objeto da resposta
@param cBody, caracter, corpo da requisição

@return boolean, identifica se o adiantamento foi gerado.
@author Marcia Junko
@since 31/03/2021
/*/
//-------------------------------------------------------------------
Static Function NewAdvance( oExpenses as J, cBody as Character ) as Logical
    
    Local aSvAlias  as Array   
    Local aUser     as Array
    Local cCatch    as Character
    Local cTravel   as Character
    Local cStatusIn as Character
    Local lRet      as Logical
    Local oModel    as Object
    Local oMdlFLC   as Object
    Local oJsonTmp  as Object
    Local oMessages as Object

    Default oExpenses := JsonObject():New()
    Default cBody     := ""

    aSvAlias  := {}    
    aUser     := {}
    cCatch    := ''
    cTravel   := ''
    cStatusIn := '1|2'
    lRet      := .T.
    oModel    := NIL
    oMdlFLC   := NIL
    oJsonTmp  := NIL
    oMessages := NIL


    aSvAlias := GetArea()

    oMessages := JsonObject():New()

    If FINXUser( __cUserID, @aUser, .F. )
        oJsonTmp := JsonObject():New()
        cCatch   := oJsonTmp:FromJSON( cBody )
        If cCatch == Nil
            FL5->( DbSetOrder(1) )  //FL5_FILIAL+FL5_VIAGEM -- SOLICITAÇÕES DE VIAGEM
            FLC->( DbSetOrder(1) )  //FLC_FILIAL+FLC_VIAGEM+FLC_PARTIC -- PASSAGEIROS
            FLD->( DbSetOrder(1) )  //FLD_FILIAL+FLD_VIAGEM+FLD_PARTIC+FLD_ADIANT -- ADIANTAMENTO DE VIAGEM
            FLU->( DbSetOrder(2) )  //FLU_FILIAL+FLU_VIAGEM+FLU_PARTIC -- PASSAGEIROS POR PEDIDO

            cTravel := oJsonTmp[ "travel_number" ]

            If ( FL5->( MSSeek( xFilial( "FL5" ) + cTravel ) ) .And. FL5->FL5_STATUS $ cStatusIn )
                oModel := FwLoadModel( "FINA667A" )
                oModel:SetOperation( MODEL_OPERATION_UPDATE )
                F667AVLMod( oModel )
                oModel:Activate()
                F667ALoadMod( oModel )

                If oModel:IsActive()
                    oMdlFLC := oModel:GetModel( 'FLCDETAIL' )

                    If oMdlFLC:SeekLine( { { "FLC_PARTIC", aUser[1] } } )
                       oModel:SetValue( "FLDDETAIL", "FLD_VALOR", oJsonTmp[ "advance_value" ] )  
                       oModel:SetValue( "FLDDETAIL", "FLD_MOEDA", oJsonTmp[ "currency" ] )
                       oModel:SetValue( "FLDDETAIL", "FLD_JUSTIF", DecodeUTF8( oJsonTmp[ "reason" ] ) )
                       oModel:SetValue( "FLCDETAIL", "OK", .T. )
                           
                        If !oModel:VldData()
                            oMessages[ "code" ]    := "400"
                            oMessages[ "message" ] := "Bad Request"
                            oMessages[ "detailMessage" ] := cValToChar( oModel:GetErrorMessage()[6] )
                            lRet := .F.
                        Else
                            oModel:CommitData()
                            oExpenses[ "id" ] := cTravel
                        EndIf
                        oModel:DeActivate()
                        oModel:Destroy()
                        oModel := NIL
                    Else
                        oMessages[ "code" ] 	:= "404"
                        oMessages[ "message" ]	:= "Not Found"
                        oMessages[ "detailMessage" ] := STR0016 //"Participante não está relacionado a esta viagem."
                        lRet := .F.
                    EndIf
                Else
                    oMessages[ "code" ] 	:= "403"
                    oMessages[ "message" ]	:= "Forbidden"
                    oMessages[ "detailMessage" ] := STR0017 //"Erro na carga do modelo."
                    lRet := .F.
                EndIF
            Else
                oMessages[ "code" ] 	:= "404"
                oMessages[ "message" ]	:= "Not Found"
                oMessages[ "detailMessage" ] := STR0018 //"Adiantamento indisponível para esta viagem."
                lRet := .F.
            EndIf
        Else
            oMessages[ "code" ] 	:= "400"
            oMessages[ "message" ]	:= "Bad Request"
            oMessages[ "detailMessage" ] := cCatch
            lRet := .F.
        EndIf
    Else
        oMessages[ "code" ] 	:= "403"
        oMessages[ "message" ]	:= "Forbidden"
        oMessages[ "detailMessage" ] := STR0003   // "Usu rio inativo no sistema ou n?o autorizado para esta opera‡?o."
        lRet := .F.
    EndIf

    If !lRet
        oMessages[ "detailMessage" ] := EncodeUTF8( oMessages[ "detailMessage" ] )
        oExpenses := oMessages
        SetRestFault( Val( oMessages[ "code" ] ), oMessages[ "detailMessage" ] )
    EndIf

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aUser )
    FreeObj( oModel )
    FreeObj( oMdlFLC )
    FreeObj( oJsonTmp )
    FreeObj( oMessages )
Return lRet
