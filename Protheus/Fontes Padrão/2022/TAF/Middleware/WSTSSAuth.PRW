#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} WSTSSAuth
@type			method
@description	Serviço para obtenção do Token JWT para comunicação 
segura com o TSS.
@author			Evandro dos Santos Oliveira 
@since			28/10/2021
/*/
//---------------------------------------------------------------------
WSRESTFUL WSTSSAuth DESCRIPTION "Serviço para o retorno do Token JWT do TSS" FORMAT APPLICATION_JSON

WSMETHOD POST V1;
	DESCRIPTION "Método para a geração e retorno do token de autenticação do TSS (TSSAUTHENTICATION)";
	WSSYNTAX "/v1/";
	PATH "/v1/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON
END WSRESTFUL

WSMETHOD POST V1 WSRESTFUL WSTSSAuth

    Local lPost         := .T. 
    Local cBody	        := ""
    Local oResponse	    :=	Nil
    Local cMsgReturn	:=	""

    cBody       := self:GetContent()
    oRequest    := JsonObject():New()
    oResponse   := JsonObject():New()

    If Empty( cBody )

        lPost := .F.
        cMsgReturn := "Requisição não possui parâmetros no corpo da mensagem."
    Else

        cMsgReturn := oRequest:FromJSON( cBody )
        lPost := Empty( cMsgReturn )

        If lPost

            lPost := AuthTSS(@oRequest,@oResponse,@cMsgReturn)
        EndIf
    EndIf

    If lPost

        self:SetResponse( oResponse:ToJson() )
    Else

        SetRestFault( 400, EncodeUTF8( cMsgReturn ) )
    EndIf  

    oRequest	:= Nil
    oResponse	:= Nil

    FreeObj( oRequest )
    FreeObj( oResponse )


Return( lPost )

//---------------------------------------------------------------------
/*/{Protheus.doc} AuthTSS
@type			function
@description	Realiza as validações e chama a função para solictar o 
token
@param oRequest   - Objeto com os atributos enviados para o Request
@param oResponse  - Objeto com os atributos de retorno
@param cMsgReturn - Mensagem de Falha
@author			Evandro dos Santos Oliveira 
@since			28/10/2021
@return			lOk - retorna verdadeiro se o Token foi criado com sucesso
/*/

//---------------------------------------------------------------------
Static Function AuthTSS(oRequest,oResponse,cMsgReturn)

    Local cUrlTSS       := ""
    Local nGrantType    := ""
    Local cGrantType    := ""
    Local cClientId     := ""
    Local cClientSecret := ""
    Local cRefreshToken := ""
    Local aToken        := {}
    Local lOk           := .T.

    cUrlTSS         := oRequest["urlTSS"]
    nGrantType      := oRequest["grantType"]
    cClientId       := oRequest["clientId"]
    cClientSecret   := oRequest["clientSecret"]
    cGrantType      := "CLIENT_CREDENTIALS"

    If Empty(cClientId) .And. Empty(cClientSecret)

        cRefreshToken := oRequest["refreshToken"]
         If nGrantType == 2 
            cGrantType := "REFRESH_TOKEN"
        EndIf 
    EndIf 

	If TSSOnAir( cUrlTSS )
		    
        aToken := getTokenTSS(cUrlTSS,cGrantType,cClientId,cClientSecret,cRefreshToken,@cMsgReturn)

        If aToken[1]
            oResponse["accesstoken"]    := aToken[2]
            oResponse["refreshToken"]   := aToken[3]
            oResponse["tokenType"]      := aToken[4]
            oResponse["expiresIn"]      := aToken[5]
        Else 
            lOk := .F. 
        EndIf 
	Else

		cMsgReturn := "Falha ao tentar se conectar ao TSS." + CRLF + CRLF
		cMsgReturn += "Configurações usadas: " + CRLF
		cMsgReturn += "Url Totvs Service SOA: " + AllTrim( cUrlTSS ) + CRLF + CRLF
		cMsgReturn += "Verifique as configurações do servidor e se o mesmo está ativo."
        lOk := .F. 
	EndIf

    aSize(aToken,0)

Return lOk

//---------------------------------------------------------------------
/*/{Protheus.doc} getTokenTSS
@type			function
@description	Realiza as validações e chama a função para solictar o 
token
@param cUrl          - Url do TSS
@param cGrantType    - Tipo de requisição (1 para geração do token 
(CLIENT_CREDENTIALS) e 2 para a atualização do token (REFRESH_TOKEN) )  
@param cClientId     - Id da credencial gerada pelo TSS
@param cClientSecret - Senha da credencial gerada pelo TSS
@param cRToken       - Refresh Token (Token para atualização do tempo 
de expiração, o mesmo pode ser utilizado para substituir o clientId e 
clientSecret após a primeira requisição)
@param cMsgReturn    - Mensagem de Erro
@author			Evandro dos Santos Oliveira 
@since			28/10/2021
@return			lOk - retorna verdadeiro se o Token foi criado com sucesso
/*/
//---------------------------------------------------------------------
Static Function getTokenTSS(cUrl,cGrantType,cClientId,cClientSecret,cRToken,cMsgReturn)

    Local lResponseOk := .F.
    Local cAccessToken := ""
    Local cRefreshToken := ""
    Local cTokenType := ""
    Local nExpiresIn := 0

    Default cGrantType  := "CLIENT_CREDENTIALS"
    Default cClientId   := ""
    Default cClientSecret := ""
    Default cRToken := ""
    Default cUrl := ""
    Default cMsgReturn := ""

    oWS := WSTSSAUTHENTICATION():New()
    oWS:_Url := cUrl + "/TSSAUTHENTICATION.apw" 

    oWS:oWSTOKEN := WsClassNew("TSSAUTHENTICATION_TOKEN")
    oWS:oWSTOKEN:cGRANT_TYPE := cGrantType 
    oWS:oWSTOKEN:cCLIENT_ID := cClientId 
    oWS:oWSTOKEN:cCLIENT_SECRET := cClientSecret 
    oWS:oWSTOKEN:cREFRESH_TOKEN := cRToken 
    oWS:TOKEN()

    lResponseOk := ValType(oWS:OWSTOKENRESULT:CACCESS_TOKEN) == "C"

    If lResponseOk
        
        cAccessToken := oWS:OWSTOKENRESULT:CACCESS_TOKEN
        cRefreshToken := oWS:OWSTOKENRESULT:CREFRESH_TOKEN
        cTokenType := oWS:OWSTOKENRESULT:CTOKEN_TYPE
        nExpiresIn := oWS:OWSTOKENRESULT:NEXPIRES_IN
    Else 

        cMsgReturn := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))

        If "WSCERR044" $ cMsgReturn
            cMsgReturn := "Falha ao tentar se conectar ao TSS." + CRLF + CRLF
            cMsgReturn += "Configurações usadas: " + CRLF
            cMsgReturn += "Url Totvs Service SOA: " + AllTrim( cUrl ) + CRLF + CRLF
            cMsgReturn += "Verifique as configurações do servidor e se o mesmo está ativo."
        EndIf
    EndIf 

Return {lResponseOk, cAccessToken, cRefreshToken, cTokenType, nExpiresIn}

//---------------------------------------------------------------------
/*/{Protheus.doc} TafSetTssHeader
@type			function
@description	Inclui o Token de autenticação no cabeçalho dos objetos
do TSS (ADMEMPRESAS, CFGCERTIFICATEPFX, CFGHSM)

@param oSelf          - objeto Soap
@param cBearerToken   - Token de Autenticação


@author			Evandro dos Santos Oliveira 
@since			28/10/2021
@return			oSelf - Objeto SOAP 
/*/
//---------------------------------------------------------------------
Function TafSetTssHeader(oSelf,cBearerToken)

	Default cBearerToken := ""

	If Empty(cBearerToken)
		oSelf := IIf( FindFunction( "ObjSelf" ), ObjSelf(oSelf), oSelf )
	Else 

		If( Empty( oSelf:_HEADOUT) )
			oSelf:_HEADOUT := {}
		EndIf 

		aAdd( oSelf:_HEADOUT, "Authorization: baerer " + cBearerToken)
	EndIf 

Return oSelf 
