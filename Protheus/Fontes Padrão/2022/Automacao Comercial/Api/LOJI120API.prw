#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "LOJI120API.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc}
WebServices em Rest para manutenção do cadastro de Operadores.
Utilização via API

@author  Rafael Tenorio da Costa
@since   17/12/18
/*/
//-------------------------------------------------------------------
WSRESTFUL CashierOperators DESCRIPTION STR0001 FORMAT "application/json,text/html"    //"Api para manutenção de Operadores de Caixa, no Protheus"

    WSDATA InternalId   as Character    Optional
    WSDATA Fields       as Charecter    Optional
    WSDATA Page         as Integer 	    Optional
    WSDATA PageSize     as Integer		Optional
    WSDATA Order    	as Character   	Optional

    WSMETHOD GET CashOperators;
        DESCRIPTION STR0002;
        PATH "/api/retail/v1/CashierOperators";
        WSSYNTAX "/api/retail/v1/CashierOperators/{Order, Page, PageSize, Fields}";        
        PRODUCES APPLICATION_JSON RESPONSE EaiObj   //"Busca todos os Operadores de Caixa disponiveis de acordo com os parâmetros Page, PageSize e Order. Por default Page = 1 e PageSize = 10"

    WSMETHOD GET Cashier;
        DESCRIPTION STR0004;
        PATH "/api/retail/v1/CashierOperators/{InternalId}";
        WSSYNTAX "/api/retail/v1/CashierOperators/{InternalId}";
        PRODUCES APPLICATION_JSON RESPONSE EaiObj   //"Retorna um Operador de Caixa de acordo com o parâmetro informado"

    WSMETHOD POST ;
        DESCRIPTION STR0006;
        PATH "/api/retail/v1/CashierOperators";
        WSSYNTAX "/api/retail/v1/CashierOperators";
        PRODUCES APPLICATION_JSON RESPONSE EaiObj   //"Inclui um Operador de Caixa de acordo com as informações recebidas"

    WSMETHOD PUT ;
        DESCRIPTION STR0008;
        PATH "/api/retail/v1/CashierOperators/{InternalId}";
        WSSYNTAX "/api/retail/v1/CashierOperators/{InternalId}";
        PRODUCES APPLICATION_JSON RESPONSE EaiObj   //"Atualiza um Operador de Caixa de acordo com o parâmetro informado"

    WSMETHOD DELETE ;
        DESCRIPTION STR0010;
        PATH "/api/retail/v1/CashierOperators/{InternalId}";
        WSSYNTAX "/api/retail/v1/CashierOperators/{InternalId}";
        PRODUCES APPLICATION_JSON RESPONSE EaiObj   //"Deleta um Operador de Caixa de acordo com o parâmetro informado"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc}
Metodo GET para retornar todos os Operadores.

@author  Rafael Tenorio da Costa
@since   17/12/18
/*/
//-------------------------------------------------------------------
WSMETHOD GET CashOperators QUERYPARAM Fields, Page, PageSize, Order WSREST CashierOperators

    Local lRet       as Logical
    Local oCashOpera as Object
    Local oEaiObj    as Object
    Local nX         as Numeric

    oJsonFilter := JsonObject():New()

    oEaiObj := FwEaiObj():New()
    oEaiObj:SetRestMethod("GET")
    oEaiObj:Activate()

    If !Empty(self:Fields)
        oEaiObj:setPathParam("Fields", StrTokArr( Alltrim( Upper(self:Fields) ), ",") )
    EndIf
    
    If !Empty(self:Page)
        oEaiObj:setPage(self:Page)
    Else
        oEaiObj:setPage(1)
    EndIf

    If !Empty(self:PageSize)
        oEaiObj:setPageSize(self:PageSize)
    Else
        oEaiObj:setPageSize(10)
    EndIf

    If !Empty(self:Order)
        oEaiObj:setOrder(self:Order)
    EndIf

    For nX := 1 To Len(self:aQueryString)
        If !(   Upper( self:aQueryString[nX][1]) == "FIELDS"    .Or.; 
                Upper( self:aQueryString[nX][1]) == "PAGESIZE"  .Or.;
                Upper( self:aQueryString[nX][1]) == "PAGE"      .Or.;
                Upper( self:aQueryString[nX][1]) == "ORDER"     )
            oJsonFilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    Next nX
    
    oEaiObj:setFilter(oJsonFilter)    

    oCashOpera := CashierOperatorAdapter():New(oEaiObj)
    oCashOpera:GetApi()
    
    If oCashOpera:GetOk()
        lRet := .T.
        self:SetResponse( EncodeUtf8( oCashOpera:oEaiObjSnd:getJson( , .T.) ) )
    Else
        lRet := .F.
        SetRestFault(404, EncodeUtf8( oCashOpera:GetError() ) )
    EndIf

    FwFreeObj(oCashOpera)
    FwFreeObj(oEaiObj)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}
Metodo GET para retornar um Operador dependendo da chave passada.

@param InternalId - Chave da SLF - Filial|Código do Operador

@author  Rafael Tenorio da Costa
@since   17/12/18
/*/
//-------------------------------------------------------------------
WSMETHOD GET Cashier PATHPARAM InternalId WSREST CashierOperators

    Local lRet       as Logical
    Local oCashOpera as Object
    Local oEaiObj    as Object

    oEaiObj := FwEaiObj():New()
    oEaiObj:SetRestMethod("GET")
    oEaiObj:Activate()
    oEaiObj:setPathParam("InternalId", self:InternalId)
    oEaiObj:setPathParam("Fields"    , {})

    oCashOpera := CashierOperatorAdapter():New(oEaiObj)
    oCashOpera:GetApi()    
    
    If oCashOpera:GetOk()
        lRet := .T.
        self:SetResponse( EncodeUtf8( oCashOpera:oEaiObjSnd:getJson( , .T.) ) )
    Else
        lRet := .F.
        SetRestFault(404, EncodeUtf8( oCashOpera:GetError() ) )
    EndIf

    FwFreeObj(oCashOpera)
    FwFreeObj(oEaiObj)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}
Metodo POST para incluir um Operador.

@author  Rafael Tenorio da Costa
@since   17/12/18
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSREST CashierOperators

    Local lRet       as Logical
    Local oCashOpera as Object
    Local cBody      as Character
    Local oEaiObj    as Object

    Private INCLUI := .T.
    Private ALTERA := .F.

    cBody := self:GetContent()

    oEaiObj := FwEaiObj():New()
    oEaiObj:SetRestMethod("POST")
    oEaiObj:Activate()
    oEaiObj:LoadJson(cBody)

    oCashOpera := CashierOperatorAdapter():New(oEaiObj)
    oCashOpera:SetInformation()

    Begin Transaction
        oCashOpera:Include()
    End Transaction

    oCashOpera:GetApi()

    If oCashOpera:GetOk()
        lRet := .T.
        self:SetResponse( EncodeUtf8( oCashOpera:oEaiObjSnd:GetJson( , .T.) ) )
    Else
        lRet := .F.
        SetRestFault(400, EncodeUtf8( oCashOpera:GetError() ) )
    EndIf

    FwFreeObj(oCashOpera)
    FwFreeObj(oEaiObj)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}
Metodo PUT para atualizar um Operador dependendo da chave passada.

@param InternalId - Chave da SLF - Filial|Código do Operador

@author  Rafael Tenorio da Costa
@since   17/12/18
/*/
//-------------------------------------------------------------------
WSMETHOD PUT PATHPARAM InternalId WSREST CashierOperators

    Local lRet       as Logical
    Local oCashOpera as Object
    Local cBody      as Character
    Local oEaiObj    as Object
    Local aError     as Array
    Local aRet       as Array
    Local cOperador  as Character

    Private INCLUI := .F.
    Private ALTERA := .T.

    lRet   := .T.
    aError := {}

    aRet := ValidChave(self:InternalId)

    If aRet[1]
        lRet      := .T.
        cOperador := aRet[3]
    Else
        lRet := .F.
        Aadd(aError, 404)
        Aadd(aError, aRet[2])
    EndIf

    If lRet

        cBody := self:GetContent()

        oEaiObj := FwEaiObj():New()
        oEaiObj:Activate()
        oEaiObj:SetRestMethod("PUT")
        oEaiObj:LoadJson(cBody)

        oCashOpera := CashierOperatorAdapter():New(oEaiObj)
        oCashOpera:SetInformation()
        oCashOpera:SetCashierCode(cOperador)

        Begin Transaction
            oCashOpera:Alter()
        End Transaction

        oCashOpera:GetApi()

        If oCashOpera:GetOk()
            lRet := .T.
            self:SetResponse( EncodeUtf8( oCashOpera:oEaiObjSnd:GetJson( , .T.) ) )
        Else
            lRet := .F.
            Aadd(aError, 400)
            Aadd(aError, oCashOpera:GetError())
        EndIf
    EndIf

    If Len(aError) > 0
        SetRestFault( aError[1], EncodeUtf8(aError[2]) )
    EndIf

    FwFreeObj(aRet)
    FwFreeObj(aError)
    FwFreeObj(oCashOpera)
    FwFreeObj(oEaiObj)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}
Metodo DELETE para deletar um Operador dependendo da chave passada.

@param InternalId - Chave da SLF - Filial|Código do Operador

@author  Rafael Tenorio da Costa
@since   17/12/18
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE PATHPARAM InternalId WSREST CashierOperators

    Local lRet       as Logical
    Local oCashOpera as Object
    Local oEaiObj    as Object
    Local aError     as Array
    Local aRet       as Array
    Local cOperador  as Character
    Local cJsonRet   as Character

    Private INCLUI := .F.
    Private ALTERA := .F.

    lRet   := .T.
    aError := {}

    aRet := ValidChave(self:InternalId)

    If aRet[1]
        lRet      := .T.
        cOperador := aRet[3]
    Else
        lRet := .F.
        Aadd(aError, 404)
        Aadd(aError, aRet[2])
    EndIf

    If lRet

        oEaiObj := FwEaiObj():New()
        oEaiObj:Activate()
        oEaiObj:SetRestMethod("DELETE")

        oCashOpera := CashierOperatorAdapter():New(oEaiObj)
        oCashOpera:SetCashierCode(cOperador)
        
        //Pega as informações antes de deletar
        oCashOpera:GetApi()
        cJsonRet := oCashOpera:oEaiObjSnd:GetJson( , .T.)
        
        Begin Transaction
            oCashOpera:Delete()
        End Transaction
        
        If oCashOpera:GetOk()
            lRet := .T.
            self:SetResponse( EncodeUtf8( cJsonRet ) )
        Else
            lRet := .F.
            Aadd(aError, 400)
            Aadd(aError, oCashOpera:GetError())
        EndIf
    EndIf

    If Len(aError) > 0
        SetRestFault( aError[1], EncodeUtf8(aError[2]) )
    EndIf

    FwFreeObj(aRet)
    FwFreeObj(aError)
    FwFreeObj(oCashOpera)
    FwFreeObj(oEaiObj)    
    
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidChave()
Seta o objeto para execução via API.

@param	cIdInterno - Chave para localizar o Operador
@return aRet - Define se foi localizado o Operador e retorna o mesmo.

@since   11/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidChave(cIdInterno, cDescricao)

    Local aRet       := {.F. ,"", ""}
    Local aAux       := {}
    Local cBkpFilAnt := cFilAnt

    If Empty(cIdInterno)
        aRet[1] := .F.
        aRet[2] := I18n(STR0012, {cDescricao, cIdInterno})  //"Para #1 um Operador de Caixa é necessário informar a Filial e o Código do Operador. Ex: 'Filial|Código do Operador' (#2)"
    Else

        aAux := Separa(cIdInterno, "|")

        If Len(aAux) >= 2

            cFilOper  := PadR( AllTrim(aAux[1]), TamSx3("LF_FILIAL")[1] )
            cOperador := PadR( AllTrim(aAux[2]), TamSx3("LF_COD")[1]    )

            If !Empty(cFilOper)
                cFilAnt := cFilOper
            EndIf

	        SLF->( DbSetOrder(1) )  //LF_FILIAL + LF_COD
            If SLF->( DbSeek(xFilial("SLF") + cOperador) )
                aRet[1] := .T.
                aRet[2]	:= cFilAnt
                aRet[3] := SLF->LF_COD
            Else
                aRet[1] := .F.
                aRet[2]	:= I18n(STR0013, {cIdInterno})  //"Operador de Caixa #1 não localizado"
            EndIf

        Else

            aRet[1] := .F.
            aRet[2]	:= I18n(STR0012, {cDescricao, cIdInterno})  //"Para #1 um Operador de Caixa é necessário informar a Filial e o Código do Operador. Ex: 'Filial|Código do Operador' (#2)"
        EndIf

    EndIf

    cFilAnt := cBkpFilAnt

Return aRet