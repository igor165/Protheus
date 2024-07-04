#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:7080/intellector/services/PolicyExecution?wsdl
Gerado em        10/29/09 10:42:39
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.090116
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _QSOPYNS ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSPolicyExecutionService
------------------------------------------------------------------------------- */

WSCLIENT WSPolicyExecutionService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD listPolicyLayouts
	WSMETHOD executePolicy

	WSDATA   _URL                      AS String
	WSDATA   cuserInputString          AS string
	WSDATA   cpasswordInputString      AS string
	WSDATA   cxmlPoliciesOutputString  AS string
	WSDATA   cxmlInputString           AS string
	WSDATA   cxmlOutputString          AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSPolicyExecutionService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.081215P-20090522] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSPolicyExecutionService
Return

WSMETHOD RESET WSCLIENT WSPolicyExecutionService
	::cuserInputString   := NIL 
	::cpasswordInputString := NIL 
	::cxmlPoliciesOutputString := NIL 
	::cxmlInputString    := NIL 
	::cxmlOutputString   := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSPolicyExecutionService
Local oClone := WSPolicyExecutionService():New()
	oClone:_URL          := ::_URL 
	oClone:cuserInputString := ::cuserInputString
	oClone:cpasswordInputString := ::cpasswordInputString
	oClone:cxmlPoliciesOutputString := ::cxmlPoliciesOutputString
	oClone:cxmlInputString := ::cxmlInputString
	oClone:cxmlOutputString := ::cxmlOutputString
Return oClone

// WSDL Method listPolicyLayouts of Service WSPolicyExecutionService

WSMETHOD listPolicyLayouts WSSEND cuserInputString,cpasswordInputString WSRECEIVE cxmlPoliciesOutputString WSCLIENT WSPolicyExecutionService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:listPolicyLayouts xmlns:q1="http://intellector.tools.com.br/services/WSPolicyExecution/">'
cSoap += WSSoapValue("userInputString", ::cuserInputString, cuserInputString , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("passwordInputString", ::cpasswordInputString, cpasswordInputString , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:listPolicyLayouts>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://intellector.tools.com.br/services/WSPolicyExecution/listPolicyLayouts",; 
	"RPCX","http://intellector.tools.com.br/services/WSPolicyExecution/",,,; 
	"http://localhost:7080/intellector/services/ListPolicyLayouts")

::Init()
::cxmlPoliciesOutputString :=  WSAdvValue( oXmlRet,"_XMLPOLICIESOUTPUTSTRING","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method executePolicy of Service WSPolicyExecutionService

WSMETHOD executePolicy WSSEND cxmlInputString WSRECEIVE cxmlOutputString WSCLIENT WSPolicyExecutionService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:executePolicy xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xmlInputString", ::cxmlInputString, cxmlInputString , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:executePolicy>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://intellector.tools.com.br/services/WSPolicyExecution/executePolicy",; 
	"RPCX","http://intellector.tools.com.br/services/WSPolicyExecution/",,,; 
	"http://localhost:7080/intellector/services/PolicyExecution")

::Init()
::cxmlOutputString   :=  WSAdvValue( oXmlRet,"_XMLOUTPUTSTRING","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



 