#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://juridico.totvsbpo.com.br:8082/WSANDAMENTOS.apw?WSDL
Gerado em        08/15/16 15:34:48
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _OMUQUNN ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service JURA224A - Web Service de comunicação com o BPO - andamentos automáticos
------------------------------------------------------------------------------- */

WSCLIENT JURA224A

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD MTANDAMENTOS
	WSMETHOD MTRECUSADOS

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cUSUARIO                  AS string
	WSDATA   cSENHA                    AS string
	WSDATA   oWSMTANDAMENTOSRESULT     AS WSANDAMENTOS_STRUACESSO
	WSDATA   cPROCESSO                 AS string
	WSDATA   cMTRECUSADOSRESULT        AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT JURA224A
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160510 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT JURA224A
	::oWSMTANDAMENTOSRESULT := WSANDAMENTOS_STRUACESSO():New()
Return

WSMETHOD RESET WSCLIENT JURA224A
	::cUSUARIO           := NIL 
	::cSENHA             := NIL 
	::oWSMTANDAMENTOSRESULT := NIL 
	::cPROCESSO          := NIL 
	::cMTRECUSADOSRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT JURA224A
Local oClone := JURA224A():New()
	oClone:_URL          := ::_URL 
	oClone:cUSUARIO      := ::cUSUARIO
	oClone:cSENHA        := ::cSENHA
	oClone:oWSMTANDAMENTOSRESULT :=  IIF(::oWSMTANDAMENTOSRESULT = NIL , NIL ,::oWSMTANDAMENTOSRESULT:Clone() )
	oClone:cPROCESSO     := ::cPROCESSO
	oClone:cMTRECUSADOSRESULT := ::cMTRECUSADOSRESULT
Return oClone

// WSDL Method MTANDAMENTOS of Service JURA224A

WSMETHOD MTANDAMENTOS WSSEND cUSUARIO,cSENHA WSRECEIVE oWSMTANDAMENTOSRESULT WSCLIENT JURA224A
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<MTANDAMENTOS xmlns="http://juridico.totvsbpo.com.br:8082/">'
cSoap += WSSoapValue("USUARIO", ::cUSUARIO, cUSUARIO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("SENHA", ::cSENHA, cSENHA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</MTANDAMENTOS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://juridico.totvsbpo.com.br:8082/MTANDAMENTOS",; 
	"DOCUMENT","http://juridico.totvsbpo.com.br:8082/",,"1.031217",; 
	"http://juridico.totvsbpo.com.br:8082/WSANDAMENTOS.apw")

::Init()
::oWSMTANDAMENTOSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_MTANDAMENTOSRESPONSE:_MTANDAMENTOSRESULT","STRUACESSO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method MTRECUSADOS of Service JURA224A

WSMETHOD MTRECUSADOS WSSEND cUSUARIO,cSENHA,cPROCESSO WSRECEIVE cMTRECUSADOSRESULT WSCLIENT JURA224A
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<MTRECUSADOS xmlns="http://juridico.totvsbpo.com.br:8082/">'
cSoap += WSSoapValue("USUARIO", ::cUSUARIO, cUSUARIO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("SENHA", ::cSENHA, cSENHA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PROCESSO", ::cPROCESSO, cPROCESSO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</MTRECUSADOS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://juridico.totvsbpo.com.br:8082/MTRECUSADOS",; 
	"DOCUMENT","http://juridico.totvsbpo.com.br:8082/",,"1.031217",; 
	"http://juridico.totvsbpo.com.br:8082/WSANDAMENTOS.apw")

::Init()
::cMTRECUSADOSRESULT :=  WSAdvValue( oXmlRet,"_MTRECUSADOSRESPONSE:_MTRECUSADOSRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure STRUACESSO

WSSTRUCT WSANDAMENTOS_STRUACESSO
	WSDATA   cCODESCRITORIO            AS string
	WSDATA   cNOMERELACIONAL           AS string
	WSDATA   cTOKEN                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSANDAMENTOS_STRUACESSO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSANDAMENTOS_STRUACESSO
Return

WSMETHOD CLONE WSCLIENT WSANDAMENTOS_STRUACESSO
	Local oClone := WSANDAMENTOS_STRUACESSO():NEW()
	oClone:cCODESCRITORIO       := ::cCODESCRITORIO
	oClone:cNOMERELACIONAL      := ::cNOMERELACIONAL
	oClone:cTOKEN               := ::cTOKEN
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSANDAMENTOS_STRUACESSO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODESCRITORIO     :=  WSAdvValue( oResponse,"_CODESCRITORIO","string",NIL,"Property cCODESCRITORIO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOMERELACIONAL    :=  WSAdvValue( oResponse,"_NOMERELACIONAL","string",NIL,"Property cNOMERELACIONAL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTOKEN             :=  WSAdvValue( oResponse,"_TOKEN","string",NIL,"Property cTOKEN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


