#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://www.kurier.com.br/wskuriertotvs/ServiceTOTVS.asmx?WSDL
Gerado em        07/10/15 16:54:51
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _LWLSLMM ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service TJurWSKurier
------------------------------------------------------------------------------- */

WSCLIENT TJurWSKurier

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD RecuperarPublicacao
	WSMETHOD RecuperarPublicacaoPorData
	WSMETHOD AtualizarPublicacaoEnviadaConfirmacao
	WSMETHOD AtualizarPublicacaoEnviadaConfirmacao_Cliente

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   clogin                    AS string
	WSDATA   csenha                    AS string
	WSDATA   oWSRecuperarPublicacaoResult AS SCHEMA
	WSDATA   cdata                     AS string
	WSDATA   oWSRecuperarPublicacaoPorDataResult AS SCHEMA
	WSDATA   oWSds                     AS SCHEMA
	WSDATA   lAtualizarPublicacaoEnviadaConfirmacaoResult AS boolean
	WSDATA   cIdCliente                AS string
	WSDATA   cCodigo                   AS string
	WSDATA   cIdProcesso               AS string
	WSDATA   lAtualizarPublicacaoEnviadaConfirmacao_ClienteResult AS boolean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT TJurWSKurier
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20150513] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT TJurWSKurier
	::oWSRecuperarPublicacaoResult := NIL 
	::oWSRecuperarPublicacaoPorDataResult := NIL 
	::oWSds              := NIL 
Return

WSMETHOD RESET WSCLIENT TJurWSKurier
	::clogin             := NIL 
	::csenha             := NIL 
	::oWSRecuperarPublicacaoResult := NIL 
	::cdata              := NIL 
	::oWSRecuperarPublicacaoPorDataResult := NIL 
	::oWSds              := NIL 
	::lAtualizarPublicacaoEnviadaConfirmacaoResult := NIL 
	::cIdCliente         := NIL 
	::cCodigo            := NIL 
	::cIdProcesso        := NIL 
	::lAtualizarPublicacaoEnviadaConfirmacao_ClienteResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT TJurWSKurier
Local oClone := TJurWSKurier():New()
	oClone:_URL          := ::_URL 
	oClone:clogin        := ::clogin
	oClone:csenha        := ::csenha
	oClone:cdata         := ::cdata
	oClone:lAtualizarPublicacaoEnviadaConfirmacaoResult := ::lAtualizarPublicacaoEnviadaConfirmacaoResult
	oClone:cIdCliente    := ::cIdCliente
	oClone:cCodigo       := ::cCodigo
	oClone:cIdProcesso   := ::cIdProcesso
	oClone:lAtualizarPublicacaoEnviadaConfirmacao_ClienteResult := ::lAtualizarPublicacaoEnviadaConfirmacao_ClienteResult
Return oClone

// WSDL Method RecuperarPublicacao of Service TJurWSKurier

WSMETHOD RecuperarPublicacao WSSEND clogin,csenha WSRECEIVE oWSRecuperarPublicacaoResult WSCLIENT TJurWSKurier
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RecuperarPublicacao xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</RecuperarPublicacao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/RecuperarPublicacao",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv('MV_JKURL',.T.,""))

::Init()
::oWSRecuperarPublicacaoResult :=  WSAdvValue( oXmlRet,"_RECUPERARPUBLICACAORESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RecuperarPublicacaoPorData of Service TJurWSKurier

WSMETHOD RecuperarPublicacaoPorData WSSEND clogin,csenha,cdata WSRECEIVE oWSRecuperarPublicacaoPorDataResult WSCLIENT TJurWSKurier
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RecuperarPublicacaoPorData xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("data", ::cdata, cdata , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</RecuperarPublicacaoPorData>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/RecuperarPublicacaoPorData",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv('MV_JKURL',.T.,""))

::Init()
::oWSRecuperarPublicacaoPorDataResult :=  WSAdvValue( oXmlRet,"_RECUPERARPUBLICACAOPORDATARESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AtualizarPublicacaoEnviadaConfirmacao of Service TJurWSKurier

WSMETHOD AtualizarPublicacaoEnviadaConfirmacao WSSEND oWSds WSRECEIVE lAtualizarPublicacaoEnviadaConfirmacaoResult WSCLIENT TJurWSKurier
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AtualizarPublicacaoEnviadaConfirmacao xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("ds", ::oWSds, oWSds , "SCHEMA", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AtualizarPublicacaoEnviadaConfirmacao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/AtualizarPublicacaoEnviadaConfirmacao",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv('MV_JKURL',.T.,""))

::Init()
::lAtualizarPublicacaoEnviadaConfirmacaoResult :=  WSAdvValue( oXmlRet,"_ATUALIZARPUBLICACAOENVIADACONFIRMACAORESPONSE:_ATUALIZARPUBLICACAOENVIADACONFIRMACAORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AtualizarPublicacaoEnviadaConfirmacao_Cliente of Service TJurWSKurier

WSMETHOD AtualizarPublicacaoEnviadaConfirmacao_Cliente WSSEND cIdCliente,cCodigo,cIdProcesso,clogin,cSenha WSRECEIVE lAtualizarPublicacaoEnviadaConfirmacao_ClienteResult WSCLIENT TJurWSKurier
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AtualizarPublicacaoEnviadaConfirmacao_Cliente xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("IdCliente", ::cIdCliente, cIdCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Codigo", ::cCodigo, cCodigo , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("IdProcesso", ::cIdProcesso, cIdProcesso , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AtualizarPublicacaoEnviadaConfirmacao_Cliente>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/AtualizarPublicacaoEnviadaConfirmacao_Cliente",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv('MV_JKURL',.T.,""))

::Init()
::lAtualizarPublicacaoEnviadaConfirmacao_ClienteResult :=  WSAdvValue( oXmlRet,"_ATUALIZARPUBLICACAOENVIADACONFIRMACAO_CLIENTERESPONSE:_ATUALIZARPUBLICACAOENVIADACONFIRMACAO_CLIENTERESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.
