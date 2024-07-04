#Include "Protheus.ch"

/*/{Protheus.doc} Fina137E
Efetua o GET para recuperar o TOKEN, junto ao RAC / Carol TOTVS

@author     Victor Furukawa
@version    1.0
@type       Function
@since      21/01/2021
@param      nil
@return     cToken, Character,  retorna Token válido para o GET com as operações 
/*/

Function FINA137E() as Character

Local aToken as Array
Local lRet as Logical

lRet := .T.
aToken := {}

aToken := FinAuth()

    If !(Empty(aToken))
        If TimePass(aToken[4], aToken[5], aToken[3])
            cToken := alltrim(aToken[2])
        EndIf
    EndIf
    
Return cToken

/*/{Protheus doc} TimePass
Verifica a validade do Token de autenticação.

@author     Victor Furukawa
@since      
@param      dData, date, data do token
@param      nTempo, numeric, tempo do token
@param      nExpiresIn, numeric, validade do token
@return     Logical, Retorna falso caso o token tenha expirado
/*/
Static Function TimePass(dData As Date, nTempo As Numeric, nExpiresIn As Numeric) As Logical

    Local dDataAtual  As Date

    Local nExpires    As Numeric
    Local nTempoAtua  As Numeric
    Local nTempoPass  As Numeric

    dDataAtual := Date()
    nTempoAtua := Seconds()
    nExpires   := nExpiresIn - (nExpiresIn * 0.01) 

    If dDataAtual == dData
        nTempoPass := nTempoAtua - nTempo
        If nTempoPass > nExpires
            Return .F.
        EndIf
    EndIf

Return .T.

/*/{Protheus.doc} FinAuth
Autentica e recupera o Token para comunicação com a plataforma 

@author     Victor Furukawa
@version    1.0
@since      08/12/2020
@return     array, com o Token atualizado e data de validade apta para conexão
/*/
Static Function FinAuth() As Array

    Local aHeader       As Array
    Local __aToken      As Array

    Local cBody         As Character
    Local cEndPoint     As Character
    Local cFormParam    As Character
    Local cResultado    As Character

    Local dData         As Date

    Local nTempo        As Numeric

    Local oJSON         As Object
    Local oTFConfig     As Object

        aHeader     := {}
        __aToken    := {}

        dData       := Date()
        nTempo      := Seconds()
        oTFConfig   := FwTFConfig()

        AAdd(aHeader, "Content-Type: application/x-www-form-urlencoded")
        AAdd(aHeader, "charset: UTF-8")

        cFormParam := "client_id=" + oTFConfig["platform-clientId"] + "&"   
        cFormParam += "client_secret=" + oTFConfig["platform-secret"] + "&" 
        
        cFormParam += "grant_type=client_credentials&"
        cFormParam += "scope=authorization_api"

        cEndPoint := oTFConfig["rac-endpoint"]
        oRestClien := FwRest():New(cEndPoint)

        // Chamada da classe exemplo de REST com retorno de lista
        oRestClien:setPath("/totvs.rac/connect/token") //https://totvs.rac.dev.totvs.io/totvs.rac/connect/token
        oRestClien:SetPostParams(cFormParam)

        Begin Sequence
            If !(oRestClien:Post(aHeader))
                cResultado := IIf(oRestClien:GetResult() <> Nil, oRestClien:GetResult(), "")
                FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", "FINAuth Post" + oRestClien:GetLastError(), 0, 0, {})   //"FINAuth Post"
                FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", "FINAuth Post" + cResultado, 0, 0, {})      //"FINAuth Post"
                AAdd(__aToken, oRestClien:GetHTTPCode())
                AAdd(__aToken, oRestClien:GetLastError())
                cBody := oRestClien:GetResult()
                oJSON := JSONObject():New()

                If ValType(oJSON:FromJSON(cBody)) == "C"
                    FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", "Formato JSON inválido", 0, 0, {}) //Formato JSON inválido.
                    Break
                EndIf
                AAdd(__aToken, oJSON["error"])
                Break
            EndIf

            // Obtém o JSON de entrada
            cBody := oRestClien:GetResult()

            oJSON := JSONObject():New()

            If ValType(oJSON:FromJSON(cBody)) == "C"
                FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", "Formato JSON inválido", 0, 0, {}) //Formato JSON inválido.
                AAdd(__aToken, "")
                AAdd(__aToken, "Formato JSON inválido")
                Break
            EndIf
            If !(Empty(oJSON["access_token"]))
                AAdd(__aToken, oRestClien:GetHTTPCode())
                AAdd(__aToken, oJSON["access_token"])
                AAdd(__aToken, oJSON["expires_in"])
                AAdd(__aToken, dData)
                AAdd(__aToken, nTempo)
            EndIf
        End Sequence

        FreeObj(oJSON)
        FreeObj(oRestClien)

Return __aToken








