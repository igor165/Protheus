#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:8080/axis2/services/SmartCTIWSCommand?wsdl
Gerado em        05/20/13 11:18:30
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _VRPDNPP ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSSmartCTIWSCommand
------------------------------------------------------------------------------- */

WSCLIENT WSSmartCTIWSCommand

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD LogonPass
	WSMETHOD GetInfoChamAtiv
	WSMETHOD queryAgentState
	WSMETHOD SystemStatus
	WSMETHOD ImmediateTransfer
	WSMETHOD Logoff
	WSMETHOD Redirect
	WSMETHOD AgentOutOfService
	WSMETHOD Logon
	WSMETHOD ReadyPass
	WSMETHOD LogoffPass
	WSMETHOD NotReady
	WSMETHOD selfTest
	WSMETHOD showVersion
	WSMETHOD Alternate
	WSMETHOD MakeCallPass
	WSMETHOD GetCallList
	WSMETHOD StartRec
	WSMETHOD Ready
	WSMETHOD Consultation
	WSMETHOD OneStepCallTransfer
	WSMETHOD Answer
	WSMETHOD Transfer
	WSMETHOD MakeCall
	WSMETHOD Retrieve
	WSMETHOD AgentInService
	WSMETHOD ConnectionClear
	WSMETHOD Hold
	WSMETHOD getActiveCallInfo
	WSMETHOD NotReadyPass
	WSMETHOD StopRec
	WSMETHOD Conference

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cdevice                   AS string
	WSDATA   cagentID                  AS string
	WSDATA   cgroupID                  AS string
	WSDATA   cagentPass                AS string
	WSDATA   nreturn                   AS int
	WSDATA   ccDevice                  AS string
	WSDATA   cdeviceTo                 AS string
	WSDATA   ctelephoneNumber          AS string
	WSDATA   croute                    AS string
	WSDATA   cipaddress                AS string
	WSDATA   cCallID                   AS string
	WSDATA   cReturn                   AS string

ENDWSCLIENT

WSMETHOD NEW WSSEND _URL WSCLIENT WSSmartCTIWSCommand
::_URL := _URL
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20130402] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSSmartCTIWSCommand
Return

WSMETHOD RESET WSCLIENT WSSmartCTIWSCommand
	::cdevice            := NIL 
	::cagentID           := NIL 
	::cgroupID           := NIL 
	::cagentPass         := NIL 
	::nreturn            := NIL 
	::ccDevice           := NIL 
	::cdeviceTo          := NIL 
	::ctelephoneNumber   := NIL 
	::croute             := NIL 
	::cipaddress         := NIL 
	::cCallID            := NIL 
	::cReturn				:= NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSSmartCTIWSCommand
Local oClone := WSSmartCTIWSCommand():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:cdevice       := ::cdevice
	oClone:cagentID      := ::cagentID
	oClone:cgroupID      := ::cgroupID
	oClone:cagentPass    := ::cagentPass
	oClone:nreturn       := ::nreturn
	oClone:cReturn		:= ::cReturn
	oClone:ccDevice      := ::ccDevice
	oClone:cdeviceTo     := ::cdeviceTo
	oClone:ctelephoneNumber := ::ctelephoneNumber
	oClone:croute        := ::croute
	oClone:cipaddress    := ::cipaddress
	oClone:cCallID       := ::cCallID
Return oClone

// WSDL Method LogonPass of Service WSSmartCTIWSCommand

WSMETHOD LogonPass WSSEND cdevice,cagentID,cgroupID,cagentPass WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LogonPass xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("agentID", ::cagentID, cagentID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("groupID", ::cgroupID, cgroupID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("agentPass", ::cagentPass, cagentPass , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</LogonPass>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:LogonPass",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_LOGONPASSRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GetInfoChamAtiv of Service WSSmartCTIWSCommand

WSMETHOD GetInfoChamAtiv WSSEND ccDevice WSRECEIVE creturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GetInfoChamAtiv xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("cDevice", ::ccDevice, ccDevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</GetInfoChamAtiv>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:GetInfoChamAtiv",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_NS_GETINFOCHAMATIVRESPONSE:_NS_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method queryAgentState of Service WSSmartCTIWSCommand

WSMETHOD queryAgentState WSSEND ccDevice WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<queryAgentState xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("cDevice", ::ccDevice, ccDevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</queryAgentState>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:queryAgentState",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_QUERYAGENTSTATERESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SystemStatus of Service WSSmartCTIWSCommand

WSMETHOD SystemStatus WSSEND NULLPARAM WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SystemStatus xmlns="http://DefaultNamespace">'
cSoap += "</SystemStatus>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:SystemStatus",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_SYSTEMSTATUSRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ImmediateTransfer of Service WSSmartCTIWSCommand

WSMETHOD ImmediateTransfer WSSEND cdevice,cdeviceTo WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImmediateTransfer xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("deviceTo", ::cdeviceTo, cdeviceTo , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ImmediateTransfer>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:ImmediateTransfer",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_IMMEDIATETRANSFERRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Logoff of Service WSSmartCTIWSCommand

WSMETHOD Logoff WSSEND cdevice,cagentID,cgroupID WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Logoff xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("agentID", ::cagentID, cagentID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("groupID", ::cgroupID, cgroupID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Logoff>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:Logoff",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_LOGOFFRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Redirect of Service WSSmartCTIWSCommand

WSMETHOD Redirect WSSEND cdevice,cdeviceTo WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Redirect xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("deviceTo", ::cdeviceTo, cdeviceTo , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Redirect>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:Redirect",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_REDIRECTRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AgentOutOfService of Service WSSmartCTIWSCommand

WSMETHOD AgentOutOfService WSSEND cdevice WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AgentOutOfService xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AgentOutOfService>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:AgentOutOfService",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_AGENTOUTOFSERVICERESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Logon of Service WSSmartCTIWSCommand

WSMETHOD Logon WSSEND cdevice,cagentID,cgroupID WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Logon xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("agentID", ::cagentID, cagentID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("groupID", ::cgroupID, cgroupID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Logon>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:Logon",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_LOGONRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ReadyPass of Service WSSmartCTIWSCommand

WSMETHOD ReadyPass WSSEND cdevice,cagentID,cgroupID,cagentPass WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ReadyPass xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("agentID", ::cagentID, cagentID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("groupID", ::cgroupID, cgroupID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("agentPass", ::cagentPass, cagentPass , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ReadyPass>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:ReadyPass",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_READYPASSRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LogoffPass of Service WSSmartCTIWSCommand

WSMETHOD LogoffPass WSSEND cdevice,cagentID,cgroupID,cagentPass WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LogoffPass xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("agentID", ::cagentID, cagentID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("groupID", ::cgroupID, cgroupID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("agentPass", ::cagentPass, cagentPass , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</LogoffPass>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:LogoffPass",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_LOGOFFPASSRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method NotReady of Service WSSmartCTIWSCommand

WSMETHOD NotReady WSSEND cdevice,cagentID,cgroupID WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<NotReady xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("agentID", ::cagentID, cagentID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("groupID", ::cgroupID, cgroupID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</NotReady>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:NotReady",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_NOTREADYRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method selfTest of Service WSSmartCTIWSCommand

WSMETHOD selfTest WSSEND NULLPARAM WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<selfTest xmlns="http://DefaultNamespace">'
cSoap += "</selfTest>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:selfTest",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_SELFTESTRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method showVersion of Service WSSmartCTIWSCommand

WSMETHOD showVersion WSSEND NULLPARAM WSRECEIVE creturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<showVersion xmlns="http://DefaultNamespace">'
cSoap += "</showVersion>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:showVersion",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_NS_SHOWVERSIONRESPONSE:_NS_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Alternate of Service WSSmartCTIWSCommand

WSMETHOD Alternate WSSEND cdevice WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Alternate xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Alternate>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:Alternate",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_ALTERNATERESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method MakeCallPass of Service WSSmartCTIWSCommand

WSMETHOD MakeCallPass WSSEND cdevice,ctelephoneNumber,cagentID,cagentPass,croute WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<MakeCallPass xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("telephoneNumber", ::ctelephoneNumber, ctelephoneNumber , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("agentID", ::cagentID, cagentID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("agentPass", ::cagentPass, cagentPass , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("route", ::croute, croute , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</MakeCallPass>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:MakeCallPass",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_MAKECALLPASSRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GetCallList of Service WSSmartCTIWSCommand

WSMETHOD GetCallList WSSEND cgroupID WSRECEIVE creturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GetCallList xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("groupID", ::cgroupID, cgroupID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</GetCallList>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:GetCallList",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_NS_GETCALLLISTRESPONSE:_NS_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Method StartRec of Service WSSmartCTIWSCommand

WSMETHOD StartRec WSSEND cdevice WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StartRec xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</StartRec>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:StartRec",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_STARTRECRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Ready of Service WSSmartCTIWSCommand

WSMETHOD Ready WSSEND cdevice,cagentID,cgroupID WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Ready xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("agentID", ::cagentID, cagentID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("groupID", ::cgroupID, cgroupID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Ready>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:Ready",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_READYRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Consultation of Service WSSmartCTIWSCommand

WSMETHOD Consultation WSSEND cdevice,cdeviceTo,cRoute WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Consultation xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("deviceTo", ::cdeviceTo, cdeviceTo , "string", .F. , .F., 0 , NIL, .F.)
cSoap += WSSoapValue("Route", ::cRoute, cRoute , "string", .F. , .F., 0 , NIL, .F.)  
cSoap += "</Consultation>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:Consultation",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_CONSULTATIONRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method OneStepCallTransfer of Service WSSmartCTIWSCommand

WSMETHOD OneStepCallTransfer WSSEND cdevice,cdeviceTo WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<OneStepCallTransfer xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("deviceTo", ::cdeviceTo, cdeviceTo , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</OneStepCallTransfer>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:OneStepCallTransfer",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_ONESTEPCALLTRANSFERRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Answer of Service WSSmartCTIWSCommand

WSMETHOD Answer WSSEND cdevice WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Answer xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Answer>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:Answer",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_ANSWERRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Transfer of Service WSSmartCTIWSCommand

WSMETHOD Transfer WSSEND cdevice WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Transfer xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Transfer>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:Transfer",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_TRANSFERRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method MakeCall of Service WSSmartCTIWSCommand

WSMETHOD MakeCall WSSEND cdevice,ctelephoneNumber WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<MakeCall xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("telephoneNumber", ::ctelephoneNumber, ctelephoneNumber , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</MakeCall>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:MakeCall",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_MAKECALLRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Retrieve of Service WSSmartCTIWSCommand

WSMETHOD Retrieve WSSEND cdevice WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Retrieve xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Retrieve>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:Retrieve",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_RETRIEVERESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AgentInService of Service WSSmartCTIWSCommand

WSMETHOD AgentInService WSSEND cdevice,cipaddress WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AgentInService xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ipaddress", ::cipaddress, cipaddress , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AgentInService>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:AgentInService",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_AGENTINSERVICERESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConnectionClear of Service WSSmartCTIWSCommand

WSMETHOD ConnectionClear WSSEND cdevice,cCallID WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConnectionClear xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CallID", ::cCallID, cCallID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConnectionClear>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:ConnectionClear",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_CONNECTIONCLEARRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Hold of Service WSSmartCTIWSCommand

WSMETHOD Hold WSSEND cdevice WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Hold xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Hold>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:Hold",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_HOLDRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getActiveCallInfo of Service WSSmartCTIWSCommand

WSMETHOD getActiveCallInfo WSSEND ccDevice WSRECEIVE creturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getActiveCallInfo xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("cDevice", ::ccDevice, ccDevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</getActiveCallInfo>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:getActiveCallInfo",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_NS_GETACTIVECALLINFORESPONSE:_NS_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method NotReadyPass of Service WSSmartCTIWSCommand

WSMETHOD NotReadyPass WSSEND cdevice,cagentID,cgroupID,cagentPass WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<NotReadyPass xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("agentID", ::cagentID, cagentID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("groupID", ::cgroupID, cgroupID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("agentPass", ::cagentPass, cagentPass , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</NotReadyPass>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:NotReadyPass",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_NOTREADYPASSRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StopRec of Service WSSmartCTIWSCommand

WSMETHOD StopRec WSSEND cdevice WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StopRec xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</StopRec>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:StopRec",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_STOPRECRESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Conference of Service WSSmartCTIWSCommand

WSMETHOD Conference WSSEND cdevice WSRECEIVE nreturn WSCLIENT WSSmartCTIWSCommand
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Conference xmlns="http://DefaultNamespace">'
cSoap += WSSoapValue("device", ::cdevice, cdevice , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Conference>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:Conference",; 
	"DOCUMENT","http://DefaultNamespace",,,; 
	::_URL+".SmartCTIWSCommandHttpSoap11Endpoint/")

::Init()
::nreturn            :=  WSAdvValue( oXmlRet,"_NS_CONFERENCERESPONSE:_NS_RETURN:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.