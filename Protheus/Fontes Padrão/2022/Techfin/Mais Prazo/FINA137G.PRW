#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FINA137G.CH"

/*/{Protheus.doc} Fina137G 
Efetua o Retorno das operações feitas no Protheus a Techfin

@author     Victor Furukawa
@version    1.0
@type       Function
@since      21/01/2021
@param      aPost, Array, Array com os dados a serem enviados a Techfin
@return     lRet, Logical,  retorna .T. ou .F. para sucesso ou insucesso da operação
/*/

Function FINA137G(aPost as Array) as Logical

    Local lRet       as Logical

    Local cUrl       as Character
    Local cPath      as Character
    Local cParams    as Character
    Local cResult    as Character
    Local jBody      as Character
    Local cToken     as Character
    Local cHttp      as Character
    Local cMensagem  as Character

    Local n          as Numeric

    Local oRest      as Object
    Local oBody      as Object

    Local aHeader    as array


    lRet     := .T.
    cParams  := ""
    cResult  := ""
    jBody    := ""
    cHttp    := ""
    n        := 1

    cUrl  := FwTotvsAppsRegistry():GetServiceURL("mais-prazo-boletos")
    cPath := ""

    If Empty(cUrl)
        
        lRet := .F.
        cMensagem := STR0001 //"URL de acesso TOTVS Mais Prazo não pode estar em branco." 

        If IsBlind()
            FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", cMensagem, 0, 0, {})
        Else
            Help("", 1, "HELP", "HELP", cMensagem, 1,,,,,,, {})
        EndIf
        
        Return lRet

    EndIf

    cToken := FINA137E()   //Traz o Token valido para o Post

    For n:= 1 to Len(aPost)

        aHeader := {}

        oRest := FWRest():New(cUrl)   //https://api-maisprazo.totvs.app/api/erp/v1/boletos
        oRest:setPath(cPath)  
        oRest:SetChkStatus(.F.)  

        //Cabeçalho de requisição
        AAdd(aHeader, "Content-Type: application/json")    
        AAdd(aHeader, "charset: UTF-8")
        AAdd(aHeader, "Authorization: Bearer " + cToken)
        AAdd(aHeader, "User-Agent: Protheus")

        oBody := JsonObject():New()
        oBody["descricao"]     := aPost[n][3]
        oBody["codigoRetorno"] := aPost[n][2]
        oBody["platformId"]    := aPost[n][4]
        oBody["operacao"]      := aPost[n][5]    

        jBody := EncodeUTF8(oBody:ToJSON())

        oRest:SetPostParams(jBody)       

        If oRest:Post(aHeader)
        
            cResult:= oRest:GetResult()
            cHttp := oRest:GetHTTPCode()
            FwLogMsg("INFO",, "TECHFIN", FunName(), "", "01", cResult,  0, 0, {}) 

        Else

            lRet := .F.
            cResult := oRest:GetLastError()
            cHttp := oRest:GetHTTPCode()
            FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", cResult,  0, 0, {}) 

        Endif     

        FreeObj(oBody)
        FreeObj(oRest)
        
    Next

Return lRet






