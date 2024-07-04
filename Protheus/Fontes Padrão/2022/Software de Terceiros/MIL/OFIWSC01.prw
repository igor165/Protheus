// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 01     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

#INCLUDE "OFIWSC01.CH"

/* ===============================================================================
WSDL Location    https://edu.claw.scania.com/clawapi/Service5_0.svc?wsdl
Gerado em        10/16/13 09:08:51
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

#DEFINE INTERFACE_VERSION "5.0"

User Function _AVPCYUY ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSMIL_ScaniaClaw
------------------------------------------------------------------------------- */

WSCLIENT WSMIL_ScaniaClaw

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ChangePassword
	WSMETHOD GetCampaignDetails
	WSMETHOD GetClaimData
	WSMETHOD GetSSOToken
	WSMETHOD IsAlive
	WSMETHOD SaveClaimData
	
	WSMETHOD ExibeErro
	WSMETHOD SetDebug	

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	
	WSDATA   _USER   AS String
	WSDATA   _PASSWD AS String
	
	WSDATA   _INTERFACE_VERSION AS String
	
	WSDATA   _WS_USER     AS String
	WSDATA   _WS_PASSWD   AS String	
	WSDATA   _SOAP_HEADER AS String	
	
	WSDATA   cconsumerName             AS string
	WSDATA   cIsAliveResult            AS string
	
	WSDATA   oWSrequest                AS MIL_ScaniaClaw_passwordRequest
	WSDATA   oWSChangePasswordResult   AS MIL_ScaniaClaw_passwordRequestReply
	
	WSDATA   oWScampaign                 AS MIL_ScaniaClaw_camp
	WSDATA   oWSGetCampaignDetailsResult AS MIL_ScaniaClaw_campReply
	
	WSDATA   oWSclaim                  AS MIL_ScaniaClaw_claimStatus
	WSDATA   oWSGetClaimDataResult     AS MIL_ScaniaClaw_claimStatusReply

	WSDATA   oWSGetSSOToken            AS MIL_ScaniaClaw_tokenRequest
	WSDATA   oWSGetSSOTokenResult      AS MIL_ScaniaClaw_tokenRequestReply
	
	WSDATA   oWSSaveClaim              AS MIL_ScaniaClaw_claimRequest
	WSDATA   oWSSaveClaimDataResult    AS MIL_ScaniaClaw_claimRequestReply

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSMIL_ScaniaClaw
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20130909] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
If !GetMv("MV_MIL0004",.T.,) .or. Empty(GetMv("MV_MIL0004"))
	Alert(STR0001) // "Parâmetros de comunicação com o Claw não estão configurados."
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSMIL_ScaniaClaw

	Local MVMIL0004 := GetMV("MV_MIL0004") // https://edu.claw.scania.com/clawapi/Service5_0.svc
	
	aParam := StrTokArr(MVMIL0004,"¨")
	
	::_URL := aParam[1]

	::_WS_USER   := IIf( Len(aParam) >= 2 , aParam[2] , "" ) // "BrazilDmsUser"
	::_WS_PASSWD := IIf( Len(aParam) >= 3 , aParam[3] , "" ) // "ArcticCat,11"
	
	::_USER := AllTrim(FM_SQL("SELECT VAI_FABUSR FROM " + RetSQLname("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODUSR = '" + __cUserID + "' AND D_E_L_E_T_ = ' '"))
	::_PASSWD := AllTrim(FM_SQL("SELECT VAI_FABPWD FROM " + RetSQLname("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODUSR = '" + __cUserID + "' AND D_E_L_E_T_ = ' '"))
	
	::_INTERFACE_VERSION := "5.0"

	::_SOAP_HEADER := '<wsse:Security soap:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
	::_SOAP_HEADER += '<wsse:UsernameToken wsse:Id="uuid-' + AllTrim(FWUUID(StrZero(Randomize(1000,33766),5))) + '">'
	::_SOAP_HEADER += '<wsse:Username>' + ::_WS_USER + '</wsse:Username>'
	::_SOAP_HEADER += '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + ::_WS_PASSWD + '</wsse:Password>'
	::_SOAP_HEADER += '</wsse:UsernameToken>'
	::_SOAP_HEADER += '</wsse:Security>'

	::oWSrequest              := MIL_ScaniaClaw_PASSWORDREQUEST():New()
	::oWSChangePasswordResult := MIL_ScaniaClaw_PASSWORDREQUESTREPLY():New()
	
	::oWScampaign                 := MIL_ScaniaClaw_CAMP():New()
	::oWSGetCampaignDetailsResult := MIL_ScaniaClaw_CAMPREPLY():New()
	
	::oWSclaim              := MIL_ScaniaClaw_CLAIMSTATUS():New()
	::oWSGetClaimDataResult := MIL_ScaniaClaw_CLAIMSTATUSREPLY():New()
	
	::oWSGetSSOToken       := MIL_ScaniaClaw_TOKENREQUEST():New()
	::oWSGetSSOTokenResult := MIL_ScaniaClaw_TOKENREQUESTREPLY():New()
	
	::oWSSaveClaim           := MIL_ScaniaClaw_CLAIMREQUEST():New()
	::oWSSaveClaimDataResult := MIL_ScaniaClaw_CLAIMREQUESTREPLY():New()
Return

WSMETHOD RESET WSCLIENT WSMIL_ScaniaClaw
	::oWSrequest                  := NIL 
	::oWSChangePasswordResult     := NIL 
	::oWScampaign                 := NIL 
	::oWSGetCampaignDetailsResult := NIL 
	::oWSclaim                    := NIL 
	::oWSGetClaimDataResult       := NIL 
	::oWSGetSSOToken              := NIL
	::oWSGetSSOTokenResult        := NIL 
	::cconsumerName               := NIL 
	::cIsAliveResult              := NIL 
	::oWSSaveClaim                := NIL 
	::oWSSaveClaimDataResult      := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSMIL_ScaniaClaw
Local oClone := WSMIL_ScaniaClaw():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:oWSrequest    :=  IIF(::oWSrequest = NIL , NIL ,::oWSrequest:Clone() )
	oClone:oWSChangePasswordResult :=  IIF(::oWSChangePasswordResult = NIL , NIL ,::oWSChangePasswordResult:Clone() )
	oClone:oWScampaign   :=  IIF(::oWScampaign = NIL , NIL ,::oWScampaign:Clone() )
	oClone:oWSGetCampaignDetailsResult :=  IIF(::oWSGetCampaignDetailsResult = NIL , NIL ,::oWSGetCampaignDetailsResult:Clone() )
	oClone:oWSclaim      :=  IIF(::oWSclaim = NIL , NIL ,::oWSclaim:Clone() )
	oClone:oWSGetClaimDataResult :=  IIF(::oWSGetClaimDataResult = NIL , NIL ,::oWSGetClaimDataResult:Clone() )
	oClone:oWSGetSSOToken :=  IIF(::oWSGetSSOToken = NIL , NIL ,::oWSGetSSOToken:Clone() )
	oClone:oWSGetSSOTokenResult :=  IIF(::oWSGetSSOTokenResult = NIL , NIL ,::oWSGetSSOTokenResult:Clone() )
	oClone:cconsumerName := ::cconsumerName
	oClone:cIsAliveResult := ::cIsAliveResult
	oClone:oWSSaveClaim      :=  IIF(::oWSSaveClaim = NIL , NIL ,::oWSSaveClaim:Clone() )
	oClone:oWSSaveClaimDataResult :=  IIF(::oWSSaveClaimDataResult = NIL , NIL ,::oWSSaveClaimDataResult:Clone() )
Return oClone


WSMETHOD SetDebug WSCLIENT WSMIL_ScaniaClaw
	WSDLDbgLevel(2)
	WSDLSaveXML(.t.)
	WSDLSetProfile(.t.) 
Return

WSMETHOD ExibeErro WSSEND cMensagem WSCLIENT WSMIL_ScaniaClaw

	Local cSvcError   := GetWSCError(1)		// Resumo do erro
	Local cSoapFCode  := GetWSCError(2)		// Soap Fault Code
	Local cSoapFDescr := GetWSCError(3)		// Soap Fault Description
	
	Default cMensagem := ""
	
	If !Empty(cSoapFCode)
		// Caso a ocorrência de erro esteja com o fault_code preenchido ,
		// a mesma teve relação com a chamada do serviço .
		MsgStop(cMensagem + chr(13) + chr(10) + cSoapFDescr,cSoapFCode)
	Else
		// Caso a ocorrência não tenha o soap_code preenchido
		// Ela está relacionada a uma outra falha ,
		// provavelmente local ou interna.
		MsgStop(cMensagem + chr(13) + chr(10) + cSvcError,STR0002)
	Endif

Return


// WSDL Method ChangePassword of Service WSMIL_ScaniaClaw

WSMETHOD ChangePassword WSSEND oWSrequest WSRECEIVE oWSChangePasswordResult WSCLIENT WSMIL_ScaniaClaw
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ChangePassword xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("request", ::oWSrequest, oWSrequest , "passwordRequest", .F. , .F., 0 , "http://tempuri.org/", .F.) 
cSoap += "</ChangePassword>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/IService5_0/ChangePassword",; 
	"DOCUMENT","http://tempuri.org/",::_SOAP_HEADER,,; 
	::_URL)

::Init()
::oWSChangePasswordResult:SoapRecv( WSAdvValue( oXmlRet,"_CHANGEPASSWORDRESPONSE:_CHANGEPASSWORDRESULT","passwordRequestReply",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GetCampaignDetails of Service WSMIL_ScaniaClaw

WSMETHOD GetCampaignDetails WSSEND oWScampaign WSRECEIVE oWSGetCampaignDetailsResult WSCLIENT WSMIL_ScaniaClaw
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GetCampaignDetails xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("campagin", ::oWScampaign, oWScampaign , "camp", .F. , .F., 0 , "http://tempuri.org/", .F.) 
cSoap += "</GetCampaignDetails>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/IService5_0/GetCampaignDetails",; 
	"DOCUMENT","http://tempuri.org/",::_SOAP_HEADER,,; 
	::_URL)

//::Init()
::oWSGetCampaignDetailsResult:SoapRecv( WSAdvValue( oXmlRet,"_GETCAMPAIGNDETAILSRESPONSE:_GETCAMPAIGNDETAILSRESULT","campReply",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GetClaimData of Service WSMIL_ScaniaClaw

WSMETHOD GetClaimData WSSEND oWSclaim WSRECEIVE oWSGetClaimDataResult WSCLIENT WSMIL_ScaniaClaw
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GetClaimData xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("claim", ::oWSclaim, oWSclaim , "claimStatus", .F. , .F., 0 , "http://tempuri.org/", .F.) 
cSoap += "</GetClaimData>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/IService5_0/GetClaimData",; 
	"DOCUMENT","http://tempuri.org/",::_SOAP_HEADER,,; 
	::_URL)
	
::Init()
::oWSGetClaimDataResult:SoapRecv( WSAdvValue( oXmlRet,"_GETCLAIMDATARESPONSE:_GETCLAIMDATARESULT","claimStatusReply",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GetSSOToken of Service WSMIL_ScaniaClaw

WSMETHOD GetSSOToken WSSEND oWSGetSSOToken WSRECEIVE oWSGetSSOTokenResult WSCLIENT WSMIL_ScaniaClaw
Local cSoap := "" , oXmlRet

::oWSGetSSOToken:cusername := ::_USER
::oWSGetSSOToken:cpassword := ::_PASSWD

BEGIN WSMETHOD

cSoap += '<GetSSOToken xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("request", ::oWSGetSSOToken, oWSGetSSOToken , "tokenRequest", .F. , .F., 0 , "http://tempuri.org/", .F.) 
cSoap += "</GetSSOToken>"

oXmlRet := SvcSoapCall(	Self,;
	cSoap,; 
	"http://tempuri.org/IService5_0/GetSSOToken",; 
	"DOCUMENT","http://tempuri.org/",::_SOAP_HEADER,,; 
	::_URL)

//::Init()
::oWSGetSSOTokenResult:SoapRecv( WSAdvValue( oXmlRet,"_GETSSOTOKENRESPONSE:_GETSSOTOKENRESULT","tokenRequestReply",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IsAlive of Service WSMIL_ScaniaClaw

WSMETHOD IsAlive WSSEND cconsumerName WSRECEIVE cIsAliveResult WSCLIENT WSMIL_ScaniaClaw
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IsAlive xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("consumerName", ::cconsumerName, cconsumerName , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</IsAlive>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/IService5_0/IsAlive",; 
	"DOCUMENT","http://tempuri.org/",::_SOAP_HEADER,,; 
	::_URL)

::Init()
::cIsAliveResult     :=  WSAdvValue( oXmlRet,"_ISALIVERESPONSE:_ISALIVERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SaveClaimData of Service WSMIL_ScaniaClaw

WSMETHOD SaveClaimData WSSEND oWSSaveClaim WSRECEIVE oWSSaveClaimDataResult WSCLIENT WSMIL_ScaniaClaw
Local cSoap := "" , oXmlRet
Local nCont

For nCont := 1 to Len(Self:oWSSaveClaim:oWSSaveClaimRec:oWSSaveClaimRequestClaimRec)
	If ::oWSSaveClaim:oWSSaveClaimRec:oWSSaveClaimRequestClaimRec[nCont]:oWSclawValues:cstartClaiming == "Y"
		::oWSSaveClaim:oWSSaveClaimRec:oWSSaveClaimRequestClaimRec[nCont]:oWSclawValues:cusername := ::_USER
		::oWSSaveClaim:oWSSaveClaimRec:oWSSaveClaimRequestClaimRec[nCont]:oWSclawValues:cpassword := ::_PASSWD
	EndIf	
Next nCont

BEGIN WSMETHOD

cSoap += '<SaveClaimData xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("claim", ::oWSSaveClaim, oWSSaveClaim , "claimRequest", .F. , .F., 0 , "http://tempuri.org/", .F.) 
cSoap += "</SaveClaimData>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/IService5_0/SaveClaimData",; 
	"DOCUMENT","http://tempuri.org/",::_SOAP_HEADER,,; 
	::_URL)

::Init()
::oWSSaveClaimDataResult:SoapRecv( WSAdvValue( oXmlRet,"_SAVECLAIMDATARESPONSE:_SAVECLAIMDATARESULT","claimRequestReply",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure passwordRequest

WSSTRUCT MIL_ScaniaClaw_passwordRequest
	WSDATA   cinterfaceVersion         AS string OPTIONAL
	WSDATA   cnewPassword              AS string OPTIONAL
	WSDATA   cpreviousPassword         AS string OPTIONAL
	WSDATA   cusername                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_passwordRequest
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_passwordRequest
	::cInterfaceVersion := INTERFACE_VERSION
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_passwordRequest
	Local oClone := MIL_ScaniaClaw_passwordRequest():NEW()
	oClone:cinterfaceVersion    := ::cinterfaceVersion
	oClone:cnewPassword         := ::cnewPassword
	oClone:cpreviousPassword    := ::cpreviousPassword
	oClone:cusername            := ::cusername
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_passwordRequest
	Local cSoap := ""
	cSoap += WSSoapValue("interfaceVersion", ::cinterfaceVersion, ::cinterfaceVersion , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("newPassword", ::cnewPassword, ::cnewPassword , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("previousPassword", ::cpreviousPassword, ::cpreviousPassword , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("username", ::cusername, ::cusername , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
Return cSoap

// WSDL Data Structure passwordRequestReply

WSSTRUCT MIL_ScaniaClaw_passwordRequestReply
	WSDATA   cdescription              AS string OPTIONAL
	WSDATA   cinterfaceVersion         AS string OPTIONAL
	WSDATA   cresultCode               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_passwordRequestReply
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_passwordRequestReply
	::cInterfaceVersion := INTERFACE_VERSION
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_passwordRequestReply
	Local oClone := MIL_ScaniaClaw_passwordRequestReply():NEW()
	oClone:cdescription         := ::cdescription
	oClone:cinterfaceVersion    := ::cinterfaceVersion
	oClone:cresultCode          := ::cresultCode
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_passwordRequestReply
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cinterfaceVersion  :=  WSAdvValue( oResponse,"_INTERFACEVERSION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cresultCode        :=  WSAdvValue( oResponse,"_RESULTCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure camp

WSSTRUCT MIL_ScaniaClaw_camp
	WSDATA   oWScampRec                AS MIL_ScaniaClaw_ArrayOfcampCampRec OPTIONAL
	WSDATA   cinterfaceVersion         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_camp
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_camp
	::cInterfaceVersion := INTERFACE_VERSION
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_camp
	Local oClone := MIL_ScaniaClaw_camp():NEW()
	oClone:oWScampRec           := IIF(::oWScampRec = NIL , NIL , ::oWScampRec:Clone() )
	oClone:cinterfaceVersion    := ::cinterfaceVersion
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_camp
	Local cSoap := ""
	cSoap += WSSoapValue("campRec", ::oWScampRec, ::oWScampRec , "ArrayOfcampCampRec", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("interfaceVersion", ::cinterfaceVersion, ::cinterfaceVersion , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
Return cSoap

// WSDL Data Structure campReply

WSSTRUCT MIL_ScaniaClaw_campReply
	WSDATA   oWScampRRec               AS MIL_ScaniaClaw_ArrayOfcampReplyCampRRec OPTIONAL
	WSDATA   cinterfaceVersion         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_campReply
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_campReply
	::cInterfaceVersion := INTERFACE_VERSION
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_campReply
	Local oClone := MIL_ScaniaClaw_campReply():NEW()
	oClone:oWScampRRec          := IIF(::oWScampRRec = NIL , NIL , ::oWScampRRec:Clone() )
	oClone:cinterfaceVersion    := ::cinterfaceVersion
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_campReply
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_CAMPRREC","ArrayOfcampReplyCampRRec",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWScampRRec := MIL_ScaniaClaw_ArrayOfcampReplyCampRRec():New()
		::oWScampRRec:SoapRecv(oNode1)
	EndIf
	::cinterfaceVersion  :=  WSAdvValue( oResponse,"_INTERFACEVERSION","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure claimStatus

WSSTRUCT MIL_ScaniaClaw_claimStatus
	WSDATA   oWSclaimStatusRec         AS MIL_ScaniaClaw_ArrayOfclaimStatusClaimStatusRec OPTIONAL
	WSDATA   cinterfaceVersion         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatus
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatus
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatus
	Local oClone := MIL_ScaniaClaw_claimStatus():NEW()
	oClone:oWSclaimStatusRec    := IIF(::oWSclaimStatusRec = NIL , NIL , ::oWSclaimStatusRec:Clone() )
	oClone:cinterfaceVersion    := ::cinterfaceVersion
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_claimStatus
	Local cSoap := ""
	cSoap += WSSoapValue("claimStatusRec", ::oWSclaimStatusRec, ::oWSclaimStatusRec , "ArrayOfclaimStatusClaimStatusRec", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("interfaceVersion", ::cinterfaceVersion, ::cinterfaceVersion , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
Return cSoap

// WSDL Data Structure claimStatusReply

WSSTRUCT MIL_ScaniaClaw_claimStatusReply
	WSDATA   oWSclaimRec               AS MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRec OPTIONAL
	WSDATA   cinterfaceVersion         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReply
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReply
	::cInterfaceVersion := INTERFACE_VERSION
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReply
	Local oClone := MIL_ScaniaClaw_claimStatusReply():NEW()
	oClone:oWSclaimRec          := IIF(::oWSclaimRec = NIL , NIL , ::oWSclaimRec:Clone() )
	oClone:cinterfaceVersion    := ::cinterfaceVersion
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReply
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_CLAIMREC","ArrayOfclaimStatusReplyClaimRec",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSclaimRec := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRec():New()
		::oWSclaimRec:SoapRecv(oNode1)
	EndIf
	::cinterfaceVersion  :=  WSAdvValue( oResponse,"_INTERFACEVERSION","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return














// WSDL Data Structure tokenRequestReply

WSSTRUCT MIL_ScaniaClaw_tokenRequest
	WSDATA   cinterfaceVersion AS string OPTIONAL
	WSDATA   cusername         AS string OPTIONAL
	WSDATA   cpassword         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_tokenRequest
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_tokenRequest
	::cInterfaceVersion := INTERFACE_VERSION
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_tokenRequest
	Local oClone := MIL_ScaniaClaw_tokenRequest():NEW()
	oClone:cinterfaceVersion := ::cinterfaceVersion
	oClone:cusername         := ::cusername        
	oClone:cpassword         := ::cpassword        
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_tokenRequest
	Local cSoap := ""
	cSoap += WSSoapValue("interfaceVersion", ::cinterfaceVersion, ::cinterfaceVersion , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("password", ::cpassword, ::cpassword , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("username", ::cusername, ::cusername , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
Return cSoap


// WSDL Data Structure tokenRequestReply

WSSTRUCT MIL_ScaniaClaw_tokenRequestReply
	WSDATA   cSSOToken                 AS string OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSDATA   cinterfaceVersion         AS string OPTIONAL
	WSDATA   cresultCode               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_tokenRequestReply
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_tokenRequestReply
	::cInterfaceVersion := INTERFACE_VERSION
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_tokenRequestReply
	Local oClone := MIL_ScaniaClaw_tokenRequestReply():NEW()
	oClone:cSSOToken            := ::cSSOToken
	oClone:cdescription         := ::cdescription
	oClone:cinterfaceVersion    := ::cinterfaceVersion
	oClone:cresultCode          := ::cresultCode
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_tokenRequestReply
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSSOToken          :=  WSAdvValue( oResponse,"_SSOTOKEN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cinterfaceVersion  :=  WSAdvValue( oResponse,"_INTERFACEVERSION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cresultCode        :=  WSAdvValue( oResponse,"_RESULTCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


// WSDL Data Structure ArrayOfcampCampRec

WSSTRUCT MIL_ScaniaClaw_ArrayOfcampCampRec
	WSDATA   oWScampCampRec            AS MIL_ScaniaClaw_campCampRec OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD ADDCAMP
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfcampCampRec
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfcampCampRec
	::oWScampCampRec       := {} // Array Of  MIL_ScaniaClaw_CAMPCAMPREC():New()
Return

WSMETHOD ADDCAMP WSCLIENT MIL_ScaniaClaw_ArrayOfcampCampRec
	AADD(::oWScampCampRec, MIL_ScaniaClaw_CAMPCAMPREC():New())
Return Len(::oWScampCampRec)

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfcampCampRec
	Local oClone := MIL_ScaniaClaw_ArrayOfcampCampRec():NEW()
	oClone:oWScampCampRec := NIL
	If ::oWScampCampRec <> NIL 
		oClone:oWScampCampRec := {}
		aEval( ::oWScampCampRec , { |x| aadd( oClone:oWScampCampRec , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_ArrayOfcampCampRec
	Local cSoap := ""
	aEval( ::oWScampCampRec , {|x| cSoap := cSoap  +  WSSoapValue("campCampRec", x , x , "campCampRec", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfcampReplyCampRRec

WSSTRUCT MIL_ScaniaClaw_ArrayOfcampReplyCampRRec
	WSDATA   oWScampReplyCampRRec      AS MIL_ScaniaClaw_campReplyCampRRec OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfcampReplyCampRRec
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfcampReplyCampRRec
	::oWScampReplyCampRRec := {} // Array Of  MIL_ScaniaClaw_CAMPREPLYCAMPRREC():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfcampReplyCampRRec
	Local oClone := MIL_ScaniaClaw_ArrayOfcampReplyCampRRec():NEW()
	oClone:oWScampReplyCampRRec := NIL
	If ::oWScampReplyCampRRec <> NIL 
		oClone:oWScampReplyCampRRec := {}
		aEval( ::oWScampReplyCampRRec , { |x| aadd( oClone:oWScampReplyCampRRec , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_ArrayOfcampReplyCampRRec
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CAMPREPLYCAMPRREC","campReplyCampRRec",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWScampReplyCampRRec , MIL_ScaniaClaw_campReplyCampRRec():New() )
			::oWScampReplyCampRRec[len(::oWScampReplyCampRRec)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfclaimStatusClaimStatusRec

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimStatusClaimStatusRec
	WSDATA   oWSclaimStatusClaimStatusRec AS MIL_ScaniaClaw_claimStatusClaimStatusRec OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusClaimStatusRec
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusClaimStatusRec
	::oWSclaimStatusClaimStatusRec := {} // Array Of  MIL_ScaniaClaw_CLAIMSTATUSCLAIMSTATUSREC():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusClaimStatusRec
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimStatusClaimStatusRec():NEW()
	oClone:oWSclaimStatusClaimStatusRec := NIL
	If ::oWSclaimStatusClaimStatusRec <> NIL 
		oClone:oWSclaimStatusClaimStatusRec := {}
		aEval( ::oWSclaimStatusClaimStatusRec , { |x| aadd( oClone:oWSclaimStatusClaimStatusRec , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusClaimStatusRec
	Local cSoap := ""
	aEval( ::oWSclaimStatusClaimStatusRec , {|x| cSoap := cSoap  +  WSSoapValue("claimStatusClaimStatusRec", x , x , "claimStatusClaimStatusRec", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfclaimStatusReplyClaimRec

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRec
	WSDATA   oWSclaimStatusReplyClaimRec AS MIL_ScaniaClaw_claimStatusReplyClaimRec OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRec
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRec
	::oWSclaimStatusReplyClaimRec := {} // Array Of  MIL_ScaniaClaw_CLAIMSTATUSREPLYCLAIMREC():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRec
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRec():NEW()
	oClone:oWSclaimStatusReplyClaimRec := NIL
	If ::oWSclaimStatusReplyClaimRec <> NIL 
		oClone:oWSclaimStatusReplyClaimRec := {}
		aEval( ::oWSclaimStatusReplyClaimRec , { |x| aadd( oClone:oWSclaimStatusReplyClaimRec , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRec
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLAIMSTATUSREPLYCLAIMREC","claimStatusReplyClaimRec",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclaimStatusReplyClaimRec , MIL_ScaniaClaw_claimStatusReplyClaimRec():New() )
			::oWSclaimStatusReplyClaimRec[len(::oWSclaimStatusReplyClaimRec)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return







// WSDL Data Structure campCampRec

WSSTRUCT MIL_ScaniaClaw_campCampRec
	WSDATA   cSpCostLimitCurrency      AS string OPTIONAL
	WSDATA   ccampNo                   AS string OPTIONAL
	WSDATA   cchassiNo                 AS string OPTIONAL
	WSDATA   ccustNo                   AS string OPTIONAL
	WSDATA   cdistrCampCode            AS string OPTIONAL
	WSDATA   cdistrNationCode          AS string OPTIONAL
	WSDATA   cdistrNo                  AS string OPTIONAL
	WSDATA   cnationCode               AS string OPTIONAL
	WSDATA   cprodType                 AS string OPTIONAL
	WSDATA   crepDate                  AS dateTime OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_campCampRec
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_campCampRec
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_campCampRec
	Local oClone := MIL_ScaniaClaw_campCampRec():NEW()
	oClone:cSpCostLimitCurrency := ::cSpCostLimitCurrency
	oClone:ccampNo              := ::ccampNo
	oClone:cchassiNo            := ::cchassiNo
	oClone:ccustNo              := ::ccustNo
	oClone:cdistrCampCode       := ::cdistrCampCode
	oClone:cdistrNationCode     := ::cdistrNationCode
	oClone:cdistrNo             := ::cdistrNo
	oClone:cnationCode          := ::cnationCode
	oClone:cprodType            := ::cprodType
	oClone:crepDate             := ::crepDate
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_campCampRec
	Local cSoap := ""
	cSoap += WSSoapValue("SpCostLimitCurrency", ::cSpCostLimitCurrency, ::cSpCostLimitCurrency , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("campNo", ::ccampNo, ::ccampNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("chassiNo", ::cchassiNo, ::cchassiNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("custNo", ::ccustNo, ::ccustNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("distrCampCode", ::cdistrCampCode, ::cdistrCampCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("distrNationCode", ::cdistrNationCode, ::cdistrNationCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("distrNo", ::cdistrNo, ::cdistrNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("nationCode", ::cnationCode, ::cnationCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("prodType", ::cprodType, ::cprodType , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("repDate", ::crepDate, ::crepDate , "dateTime", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
Return cSoap

// WSDL Data Structure campReplyCampRRec

WSSTRUCT MIL_ScaniaClaw_campReplyCampRRec
	WSDATA   cSpCostLimitCurrency      AS string OPTIONAL
	WSDATA   ccampNo                   AS string OPTIONAL
	WSDATA   oWScampOp                 AS MIL_ScaniaClaw_ArrayOfcampReplyCampRRecCampOp OPTIONAL
	WSDATA   oWScampPart               AS MIL_ScaniaClaw_ArrayOfcampReplyCampRRecCampPart OPTIONAL
	WSDATA   ccampType                 AS string OPTIONAL
	WSDATA   cchassiNo                 AS string OPTIONAL
	WSDATA   oWScomp                   AS MIL_ScaniaClaw_ArrayOfcampReplyCampRRecComp OPTIONAL
	WSDATA   ccustNo                   AS string OPTIONAL
	WSDATA   oWSdescrCode              AS MIL_ScaniaClaw_campReplyCampRRecDescrCode OPTIONAL
	WSDATA   cdistrCampCode            AS string OPTIONAL
	WSDATA   cdistrCampDescr           AS string OPTIONAL
	WSDATA   cdistrCampRefNo           AS string OPTIONAL
	WSDATA   cdistrNationCode          AS string OPTIONAL
	WSDATA   cdistrNo                  AS string OPTIONAL
	WSDATA   oWSfaultDescr             AS MIL_ScaniaClaw_ArrayOfcampReplyCampRRecFaultDescr OPTIONAL
	WSDATA   cmaingroup                AS string OPTIONAL
	WSDATA   cnationCode               AS string OPTIONAL
	WSDATA   cprodType                 AS string OPTIONAL
	WSDATA   crepDate                  AS dateTime OPTIONAL
	WSDATA   cresultCode               AS string OPTIONAL
	WSDATA   csubgroup                 AS string OPTIONAL
	WSDATA   cswCampCode               AS string OPTIONAL
	WSDATA   oWStitleCode              AS MIL_ScaniaClaw_campReplyCampRRecTitleCode OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_campReplyCampRRec
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_campReplyCampRRec
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_campReplyCampRRec
	Local oClone := MIL_ScaniaClaw_campReplyCampRRec():NEW()
	oClone:cSpCostLimitCurrency := ::cSpCostLimitCurrency
	oClone:ccampNo              := ::ccampNo
	oClone:oWScampOp            := IIF(::oWScampOp = NIL , NIL , ::oWScampOp:Clone() )
	oClone:oWScampPart          := IIF(::oWScampPart = NIL , NIL , ::oWScampPart:Clone() )
	oClone:ccampType            := ::ccampType
	oClone:cchassiNo            := ::cchassiNo
	oClone:oWScomp              := IIF(::oWScomp = NIL , NIL , ::oWScomp:Clone() )
	oClone:ccustNo              := ::ccustNo
	oClone:oWSdescrCode         := IIF(::oWSdescrCode = NIL , NIL , ::oWSdescrCode:Clone() )
	oClone:cdistrCampCode       := ::cdistrCampCode
	oClone:cdistrCampDescr      := ::cdistrCampDescr
	oClone:cdistrCampRefNo      := ::cdistrCampRefNo
	oClone:cdistrNationCode     := ::cdistrNationCode
	oClone:cdistrNo             := ::cdistrNo
	oClone:oWSfaultDescr        := IIF(::oWSfaultDescr = NIL , NIL , ::oWSfaultDescr:Clone() )
	oClone:cmaingroup           := ::cmaingroup
	oClone:cnationCode          := ::cnationCode
	oClone:cprodType            := ::cprodType
	oClone:crepDate             := ::crepDate
	oClone:cresultCode          := ::cresultCode
	oClone:csubgroup            := ::csubgroup
	oClone:cswCampCode          := ::cswCampCode
	oClone:oWStitleCode         := IIF(::oWStitleCode = NIL , NIL , ::oWStitleCode:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_campReplyCampRRec
	Local oNode3
	Local oNode4
	Local oNode7
	Local oNode9
	Local oNode15
	Local oNode23
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSpCostLimitCurrency :=  WSAdvValue( oResponse,"_SPCOSTLIMITCURRENCY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccampNo            :=  WSAdvValue( oResponse,"_CAMPNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode3 :=  WSAdvValue( oResponse,"_CAMPOP","ArrayOfcampReplyCampRRecCampOp",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode3 != NIL
		::oWScampOp := MIL_ScaniaClaw_ArrayOfcampReplyCampRRecCampOp():New()
		::oWScampOp:SoapRecv(oNode3)
	EndIf
	oNode4 :=  WSAdvValue( oResponse,"_CAMPPART","ArrayOfcampReplyCampRRecCampPart",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode4 != NIL
		::oWScampPart := MIL_ScaniaClaw_ArrayOfcampReplyCampRRecCampPart():New()
		::oWScampPart:SoapRecv(oNode4)
	EndIf
	::ccampType          :=  WSAdvValue( oResponse,"_CAMPTYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cchassiNo          :=  WSAdvValue( oResponse,"_CHASSINO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode7 :=  WSAdvValue( oResponse,"_COMP","ArrayOfcampReplyCampRRecComp",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode7 != NIL
		::oWScomp := MIL_ScaniaClaw_ArrayOfcampReplyCampRRecComp():New()
		::oWScomp:SoapRecv(oNode7)
	EndIf
	::ccustNo            :=  WSAdvValue( oResponse,"_CUSTNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode9 :=  WSAdvValue( oResponse,"_DESCRCODE","campReplyCampRRecDescrCode",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode9 != NIL
		::oWSdescrCode := MIL_ScaniaClaw_campReplyCampRRecDescrCode():New()
		::oWSdescrCode:SoapRecv(oNode9)
	EndIf
	::cdistrCampCode     :=  WSAdvValue( oResponse,"_DISTRCAMPCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdistrCampDescr    :=  WSAdvValue( oResponse,"_DISTRCAMPDESCR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdistrCampRefNo    :=  WSAdvValue( oResponse,"_DISTRCAMPREFNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdistrNationCode   :=  WSAdvValue( oResponse,"_DISTRNATIONCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdistrNo           :=  WSAdvValue( oResponse,"_DISTRNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode15 :=  WSAdvValue( oResponse,"_FAULTDESCR","ArrayOfcampReplyCampRRecFaultDescr",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode15 != NIL
		::oWSfaultDescr := MIL_ScaniaClaw_ArrayOfcampReplyCampRRecFaultDescr():New()
		::oWSfaultDescr:SoapRecv(oNode15)
	EndIf
	::cmaingroup         :=  WSAdvValue( oResponse,"_MAINGROUP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cnationCode        :=  WSAdvValue( oResponse,"_NATIONCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cprodType          :=  WSAdvValue( oResponse,"_PRODTYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::crepDate           :=  WSAdvValue( oResponse,"_REPDATE","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::cresultCode        :=  WSAdvValue( oResponse,"_RESULTCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::csubgroup          :=  WSAdvValue( oResponse,"_SUBGROUP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cswCampCode        :=  WSAdvValue( oResponse,"_SWCAMPCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode23 :=  WSAdvValue( oResponse,"_TITLECODE","campReplyCampRRecTitleCode",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode23 != NIL
		::oWStitleCode := MIL_ScaniaClaw_campReplyCampRRecTitleCode():New()
		::oWStitleCode:SoapRecv(oNode23)
	EndIf
Return

// WSDL Data Structure claimStatusClaimStatusRec

WSSTRUCT MIL_ScaniaClaw_claimStatusClaimStatusRec
	WSDATA   cchassiNo                 AS string OPTIONAL
	WSDATA   cclaimNo                  AS string OPTIONAL
	WSDATA   oWSclawValues             AS MIL_ScaniaClaw_claimStatusClaimStatusRecClawValues OPTIONAL
	WSDATA   ccustNo                   AS string OPTIONAL
	WSDATA   cfailNo                   AS string OPTIONAL
	WSDATA   cjobNo                    AS string OPTIONAL
	WSDATA   cnationCode               AS string OPTIONAL
	WSDATA   cprodType                 AS string OPTIONAL
	WSDATA   creconNo                  AS string OPTIONAL
	WSDATA   cworkOrdNo                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusClaimStatusRec
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusClaimStatusRec
	::oWSclawValues := MIL_ScaniaClaw_claimStatusClaimStatusRecClawValues():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusClaimStatusRec
	Local oClone := MIL_ScaniaClaw_claimStatusClaimStatusRec():NEW()
	oClone:cchassiNo            := ::cchassiNo
	oClone:cclaimNo             := ::cclaimNo
	oClone:oWSclawValues        := IIF(::oWSclawValues = NIL , NIL , ::oWSclawValues:Clone() )
	oClone:ccustNo              := ::ccustNo
	oClone:cfailNo              := ::cfailNo
	oClone:cjobNo               := ::cjobNo
	oClone:cnationCode          := ::cnationCode
	oClone:cprodType            := ::cprodType
	oClone:creconNo             := ::creconNo
	oClone:cworkOrdNo           := ::cworkOrdNo
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_claimStatusClaimStatusRec
	Local cSoap := ""
	cSoap += WSSoapValue("chassiNo", ::cchassiNo, ::cchassiNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("claimNo", ::cclaimNo, ::cclaimNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("clawValues", ::oWSclawValues, ::oWSclawValues , "claimStatusClaimStatusRecClawValues", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("custNo", ::ccustNo, ::ccustNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("failNo", ::cfailNo, ::cfailNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("jobNo", ::cjobNo, ::cjobNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("nationCode", ::cnationCode, ::cnationCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("prodType", ::cprodType, ::cprodType , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("reconNo", ::creconNo, ::creconNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("workOrdNo", ::cworkOrdNo, ::cworkOrdNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
Return cSoap

// WSDL Data Structure claimStatusReplyClaimRec

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRec
	WSDATA   oWSclawValues             AS MIL_ScaniaClaw_claimStatusReplyClaimRecClawValues OPTIONAL
	WSDATA   oWSrequestValues          AS MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValues OPTIONAL
	WSDATA   oWSresponseValues         AS MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValues OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRec
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRec
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRec
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRec():NEW()
	oClone:oWSclawValues        := IIF(::oWSclawValues = NIL , NIL , ::oWSclawValues:Clone() )
	oClone:oWSrequestValues     := IIF(::oWSrequestValues = NIL , NIL , ::oWSrequestValues:Clone() )
	oClone:oWSresponseValues    := IIF(::oWSresponseValues = NIL , NIL , ::oWSresponseValues:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRec
	Local oNode1
	Local oNode2
	Local oNode3
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_CLAWVALUES","claimStatusReplyClaimRecClawValues",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSclawValues := MIL_ScaniaClaw_claimStatusReplyClaimRecClawValues():New()
		::oWSclawValues:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_REQUESTVALUES","claimStatusReplyClaimRecRequestValues",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSrequestValues := MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValues():New()
		::oWSrequestValues:SoapRecv(oNode2)
	EndIf
	oNode3 :=  WSAdvValue( oResponse,"_RESPONSEVALUES","claimStatusReplyClaimRecResponseValues",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode3 != NIL
		::oWSresponseValues := MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValues():New()
		::oWSresponseValues:SoapRecv(oNode3)
	EndIf
Return


// WSDL Data Structure ArrayOfcampReplyCampRRecCampOp

WSSTRUCT MIL_ScaniaClaw_ArrayOfcampReplyCampRRecCampOp
	WSDATA   oWScampReplyCampRRecCampOp AS MIL_ScaniaClaw_campReplyCampRRecCampOp OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfcampReplyCampRRecCampOp
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfcampReplyCampRRecCampOp
	::oWScampReplyCampRRecCampOp := {} // Array Of  MIL_ScaniaClaw_CAMPREPLYCAMPRRECCAMPOP():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfcampReplyCampRRecCampOp
	Local oClone := MIL_ScaniaClaw_ArrayOfcampReplyCampRRecCampOp():NEW()
	oClone:oWScampReplyCampRRecCampOp := NIL
	If ::oWScampReplyCampRRecCampOp <> NIL 
		oClone:oWScampReplyCampRRecCampOp := {}
		aEval( ::oWScampReplyCampRRecCampOp , { |x| aadd( oClone:oWScampReplyCampRRecCampOp , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_ArrayOfcampReplyCampRRecCampOp
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CAMPREPLYCAMPRRECCAMPOP","campReplyCampRRecCampOp",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWScampReplyCampRRecCampOp , MIL_ScaniaClaw_campReplyCampRRecCampOp():New() )
			::oWScampReplyCampRRecCampOp[len(::oWScampReplyCampRRecCampOp)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfcampReplyCampRRecCampPart

WSSTRUCT MIL_ScaniaClaw_ArrayOfcampReplyCampRRecCampPart
	WSDATA   oWScampReplyCampRRecCampPart AS MIL_ScaniaClaw_campReplyCampRRecCampPart OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfcampReplyCampRRecCampPart
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfcampReplyCampRRecCampPart
	::oWScampReplyCampRRecCampPart := {} // Array Of  MIL_ScaniaClaw_CAMPREPLYCAMPRRECCAMPPART():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfcampReplyCampRRecCampPart
	Local oClone := MIL_ScaniaClaw_ArrayOfcampReplyCampRRecCampPart():NEW()
	oClone:oWScampReplyCampRRecCampPart := NIL
	If ::oWScampReplyCampRRecCampPart <> NIL 
		oClone:oWScampReplyCampRRecCampPart := {}
		aEval( ::oWScampReplyCampRRecCampPart , { |x| aadd( oClone:oWScampReplyCampRRecCampPart , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_ArrayOfcampReplyCampRRecCampPart
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CAMPREPLYCAMPRRECCAMPPART","campReplyCampRRecCampPart",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWScampReplyCampRRecCampPart , MIL_ScaniaClaw_campReplyCampRRecCampPart():New() )
			::oWScampReplyCampRRecCampPart[len(::oWScampReplyCampRRecCampPart)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfcampReplyCampRRecComp

WSSTRUCT MIL_ScaniaClaw_ArrayOfcampReplyCampRRecComp
	WSDATA   oWScampReplyCampRRecComp  AS MIL_ScaniaClaw_campReplyCampRRecComp OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfcampReplyCampRRecComp
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfcampReplyCampRRecComp
	::oWScampReplyCampRRecComp := {} // Array Of  MIL_ScaniaClaw_CAMPREPLYCAMPRRECCOMP():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfcampReplyCampRRecComp
	Local oClone := MIL_ScaniaClaw_ArrayOfcampReplyCampRRecComp():NEW()
	oClone:oWScampReplyCampRRecComp := NIL
	If ::oWScampReplyCampRRecComp <> NIL 
		oClone:oWScampReplyCampRRecComp := {}
		aEval( ::oWScampReplyCampRRecComp , { |x| aadd( oClone:oWScampReplyCampRRecComp , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_ArrayOfcampReplyCampRRecComp
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CAMPREPLYCAMPRRECCOMP","campReplyCampRRecComp",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWScampReplyCampRRecComp , MIL_ScaniaClaw_campReplyCampRRecComp():New() )
			::oWScampReplyCampRRecComp[len(::oWScampReplyCampRRecComp)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure campReplyCampRRecDescrCode

WSSTRUCT MIL_ScaniaClaw_campReplyCampRRecDescrCode
	WSDATA   ccodeId                   AS string OPTIONAL
	WSDATA   ccodeTypeId               AS string OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_campReplyCampRRecDescrCode
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_campReplyCampRRecDescrCode
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_campReplyCampRRecDescrCode
	Local oClone := MIL_ScaniaClaw_campReplyCampRRecDescrCode():NEW()
	oClone:ccodeId              := ::ccodeId
	oClone:ccodeTypeId          := ::ccodeTypeId
	oClone:cdescription         := ::cdescription
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_campReplyCampRRecDescrCode
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccodeId            :=  WSAdvValue( oResponse,"_CODEID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccodeTypeId        :=  WSAdvValue( oResponse,"_CODETYPEID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfcampReplyCampRRecFaultDescr

WSSTRUCT MIL_ScaniaClaw_ArrayOfcampReplyCampRRecFaultDescr
	WSDATA   oWScampReplyCampRRecFaultDescr AS MIL_ScaniaClaw_campReplyCampRRecFaultDescr OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfcampReplyCampRRecFaultDescr
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfcampReplyCampRRecFaultDescr
	::oWScampReplyCampRRecFaultDescr := {} // Array Of  MIL_ScaniaClaw_CAMPREPLYCAMPRRECFAULTDESCR():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfcampReplyCampRRecFaultDescr
	Local oClone := MIL_ScaniaClaw_ArrayOfcampReplyCampRRecFaultDescr():NEW()
	oClone:oWScampReplyCampRRecFaultDescr := NIL
	If ::oWScampReplyCampRRecFaultDescr <> NIL 
		oClone:oWScampReplyCampRRecFaultDescr := {}
		aEval( ::oWScampReplyCampRRecFaultDescr , { |x| aadd( oClone:oWScampReplyCampRRecFaultDescr , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_ArrayOfcampReplyCampRRecFaultDescr
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CAMPREPLYCAMPRRECFAULTDESCR","campReplyCampRRecFaultDescr",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWScampReplyCampRRecFaultDescr , MIL_ScaniaClaw_campReplyCampRRecFaultDescr():New() )
			::oWScampReplyCampRRecFaultDescr[len(::oWScampReplyCampRRecFaultDescr)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure campReplyCampRRecTitleCode

WSSTRUCT MIL_ScaniaClaw_campReplyCampRRecTitleCode
	WSDATA   ccodeId                   AS string OPTIONAL
	WSDATA   ccodeTypeId               AS string OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_campReplyCampRRecTitleCode
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_campReplyCampRRecTitleCode
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_campReplyCampRRecTitleCode
	Local oClone := MIL_ScaniaClaw_campReplyCampRRecTitleCode():NEW()
	oClone:ccodeId              := ::ccodeId
	oClone:ccodeTypeId          := ::ccodeTypeId
	oClone:cdescription         := ::cdescription
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_campReplyCampRRecTitleCode
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccodeId            :=  WSAdvValue( oResponse,"_CODEID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccodeTypeId        :=  WSAdvValue( oResponse,"_CODETYPEID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure claimStatusClaimStatusRecClawValues

WSSTRUCT MIL_ScaniaClaw_claimStatusClaimStatusRecClawValues
	WSDATA   cdmsRefNo                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusClaimStatusRecClawValues
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusClaimStatusRecClawValues
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusClaimStatusRecClawValues
	Local oClone := MIL_ScaniaClaw_claimStatusClaimStatusRecClawValues():NEW()
	oClone:cdmsRefNo            := ::cdmsRefNo
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_claimStatusClaimStatusRecClawValues
	Local cSoap := ""
	cSoap += WSSoapValue("dmsRefNo", ::cdmsRefNo, ::cdmsRefNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
Return cSoap

// WSDL Data Structure claimStatusReplyClaimRecClawValues

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecClawValues
	WSDATA   ccampType                 AS string OPTIONAL
	WSDATA   cdmsRefNo                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecClawValues
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecClawValues
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecClawValues
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecClawValues():NEW()
	oClone:ccampType            := ::ccampType
	oClone:cdmsRefNo            := ::cdmsRefNo
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecClawValues
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccampType          :=  WSAdvValue( oResponse,"_CAMPTYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdmsRefNo          :=  WSAdvValue( oResponse,"_DMSREFNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure claimStatusReplyClaimRecRequestValues

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValues
	WSDATA   cassortmentCode           AS string OPTIONAL
	WSDATA   cbookDate                 AS dateTime OPTIONAL
	WSDATA   lbookDateSpecified        AS boolean OPTIONAL
	WSDATA   ccampNo                   AS string OPTIONAL
	WSDATA   cchassiNo                 AS string OPTIONAL
	WSDATA   cclaimNo                  AS string OPTIONAL
	WSDATA   cclaimType                AS string OPTIONAL
	WSDATA   ccomplMgCode              AS string OPTIONAL
	WSDATA   ccomplainDate             AS dateTime OPTIONAL
	WSDATA   ccontractWorkshop         AS string OPTIONAL
	WSDATA   oWScostL                  AS MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostL OPTIONAL
	WSDATA   oWScostP                  AS MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostP OPTIONAL
	WSDATA   oWScostS                  AS MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostS OPTIONAL
	WSDATA   oWScostU                  AS MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostU OPTIONAL
	WSDATA   oWScostX01                AS MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostX01 OPTIONAL
	WSDATA   ncustAmt                  AS decimal OPTIONAL
	WSDATA   ccustNo                   AS string OPTIONAL
	WSDATA   ccustText                 AS string OPTIONAL
	WSDATA   cdamagePartNo             AS string OPTIONAL
	WSDATA   cdelCode                  AS string OPTIONAL
	WSDATA   cdemFactorL               AS string OPTIONAL
	WSDATA   cdemFactorP               AS string OPTIONAL
	WSDATA   cdemFactorS               AS string OPTIONAL
	WSDATA   cdemFactorU               AS string OPTIONAL
	WSDATA   cdemType                  AS string OPTIONAL
	WSDATA   cdistrNationCode          AS string OPTIONAL
	WSDATA   cdistrNo                  AS string OPTIONAL
	WSDATA   celapsedTime              AS string OPTIONAL
	WSDATA   cepsName                  AS string OPTIONAL
	WSDATA   cfailNo                   AS string OPTIONAL
	WSDATA   cfailRepNo                AS string OPTIONAL
	WSDATA   cfailureCode              AS string OPTIONAL
	WSDATA   cfieldTestNo              AS string OPTIONAL
	WSDATA   cforVehicle               AS string OPTIONAL
	WSDATA   cjobNo                    AS string OPTIONAL
	WSDATA   clocalClaimCode           AS string OPTIONAL
	WSDATA   clocationCode             AS string OPTIONAL
	WSDATA   cmaingroup                AS string OPTIONAL
	WSDATA   cmaintCode                AS string OPTIONAL
	WSDATA   cmanufCode                AS string OPTIONAL
	WSDATA   cmechanic                 AS string OPTIONAL
	WSDATA   cmileage                  AS string OPTIONAL
	WSDATA   cmountDate                AS dateTime OPTIONAL
	WSDATA   lmountDateSpecified       AS boolean OPTIONAL
	WSDATA   cmountMileage             AS string OPTIONAL
	WSDATA   cnationCode               AS string OPTIONAL
	WSDATA   copenDate                 AS dateTime OPTIONAL
	WSDATA   lopenDateSpecified        AS boolean OPTIONAL
	WSDATA   cpriceList                AS string OPTIONAL
	WSDATA   cprodType                 AS string OPTIONAL
	WSDATA   creceptionist             AS string OPTIONAL
	WSDATA   creconNo                  AS string OPTIONAL
	WSDATA   crefClaimNo               AS string OPTIONAL
	WSDATA   crefNo                    AS string OPTIONAL
	WSDATA   crefText                  AS string OPTIONAL
	WSDATA   crepDate                  AS dateTime OPTIONAL
	WSDATA   crepairCode               AS string OPTIONAL
	WSDATA   csourceCode               AS string OPTIONAL
	WSDATA   csubgroup                 AS string OPTIONAL
	WSDATA   csymptomCode              AS string OPTIONAL
	WSDATA   oWStimeStamp              AS MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesTimeStamp OPTIONAL
	WSDATA   ctimeStampCode            AS string OPTIONAL
	WSDATA   cuserConf                 AS string OPTIONAL
	WSDATA   cverCode                  AS string OPTIONAL
	WSDATA   cworkOrdNo                AS string OPTIONAL
	WSDATA   cworkshopText             AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValues
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValues
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValues
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValues():NEW()
	oClone:cassortmentCode      := ::cassortmentCode
	oClone:cbookDate            := ::cbookDate
	oClone:lbookDateSpecified   := ::lbookDateSpecified
	oClone:ccampNo              := ::ccampNo
	oClone:cchassiNo            := ::cchassiNo
	oClone:cclaimNo             := ::cclaimNo
	oClone:cclaimType           := ::cclaimType
	oClone:ccomplMgCode         := ::ccomplMgCode
	oClone:ccomplainDate        := ::ccomplainDate
	oClone:ccontractWorkshop    := ::ccontractWorkshop
	oClone:oWScostL             := IIF(::oWScostL = NIL , NIL , ::oWScostL:Clone() )
	oClone:oWScostP             := IIF(::oWScostP = NIL , NIL , ::oWScostP:Clone() )
	oClone:oWScostS             := IIF(::oWScostS = NIL , NIL , ::oWScostS:Clone() )
	oClone:oWScostU             := IIF(::oWScostU = NIL , NIL , ::oWScostU:Clone() )
	oClone:oWScostX01           := IIF(::oWScostX01 = NIL , NIL , ::oWScostX01:Clone() )
	oClone:ncustAmt             := ::ncustAmt
	oClone:ccustNo              := ::ccustNo
	oClone:ccustText            := ::ccustText
	oClone:cdamagePartNo        := ::cdamagePartNo
	oClone:cdelCode             := ::cdelCode
	oClone:cdemFactorL          := ::cdemFactorL
	oClone:cdemFactorP          := ::cdemFactorP
	oClone:cdemFactorS          := ::cdemFactorS
	oClone:cdemFactorU          := ::cdemFactorU
	oClone:cdemType             := ::cdemType
	oClone:cdistrNationCode     := ::cdistrNationCode
	oClone:cdistrNo             := ::cdistrNo
	oClone:celapsedTime         := ::celapsedTime
	oClone:cepsName             := ::cepsName
	oClone:cfailNo              := ::cfailNo
	oClone:cfailRepNo           := ::cfailRepNo
	oClone:cfailureCode         := ::cfailureCode
	oClone:cfieldTestNo         := ::cfieldTestNo
	oClone:cforVehicle          := ::cforVehicle
	oClone:cjobNo               := ::cjobNo
	oClone:clocalClaimCode      := ::clocalClaimCode
	oClone:clocationCode        := ::clocationCode
	oClone:cmaingroup           := ::cmaingroup
	oClone:cmaintCode           := ::cmaintCode
	oClone:cmanufCode           := ::cmanufCode
	oClone:cmechanic            := ::cmechanic
	oClone:cmileage             := ::cmileage
	oClone:cmountDate           := ::cmountDate
	oClone:lmountDateSpecified  := ::lmountDateSpecified
	oClone:cmountMileage        := ::cmountMileage
	oClone:cnationCode          := ::cnationCode
	oClone:copenDate            := ::copenDate
	oClone:lopenDateSpecified   := ::lopenDateSpecified
	oClone:cpriceList           := ::cpriceList
	oClone:cprodType            := ::cprodType
	oClone:creceptionist        := ::creceptionist
	oClone:creconNo             := ::creconNo
	oClone:crefClaimNo          := ::crefClaimNo
	oClone:crefNo               := ::crefNo
	oClone:crefText             := ::crefText
	oClone:crepDate             := ::crepDate
	oClone:crepairCode          := ::crepairCode
	oClone:csourceCode          := ::csourceCode
	oClone:csubgroup            := ::csubgroup
	oClone:csymptomCode         := ::csymptomCode
	oClone:oWStimeStamp         := IIF(::oWStimeStamp = NIL , NIL , ::oWStimeStamp:Clone() )
	oClone:ctimeStampCode       := ::ctimeStampCode
	oClone:cuserConf            := ::cuserConf
	oClone:cverCode             := ::cverCode
	oClone:cworkOrdNo           := ::cworkOrdNo
	oClone:cworkshopText        := ::cworkshopText
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValues
	Local oNode11
	Local oNode12
	Local oNode13
	Local oNode14
	Local oNode15
	Local oNode61
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cassortmentCode    :=  WSAdvValue( oResponse,"_ASSORTMENTCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbookDate          :=  WSAdvValue( oResponse,"_BOOKDATE","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::lbookDateSpecified :=  WSAdvValue( oResponse,"_BOOKDATESPECIFIED","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::ccampNo            :=  WSAdvValue( oResponse,"_CAMPNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cchassiNo          :=  WSAdvValue( oResponse,"_CHASSINO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cclaimNo           :=  WSAdvValue( oResponse,"_CLAIMNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cclaimType         :=  WSAdvValue( oResponse,"_CLAIMTYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccomplMgCode       :=  WSAdvValue( oResponse,"_COMPLMGCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccomplainDate      :=  WSAdvValue( oResponse,"_COMPLAINDATE","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccontractWorkshop  :=  WSAdvValue( oResponse,"_CONTRACTWORKSHOP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode11 :=  WSAdvValue( oResponse,"_COSTL","ArrayOfclaimStatusReplyClaimRecRequestValuesCostL",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode11 != NIL
		::oWScostL := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostL():New()
		::oWScostL:SoapRecv(oNode11)
	EndIf
	oNode12 :=  WSAdvValue( oResponse,"_COSTP","ArrayOfclaimStatusReplyClaimRecRequestValuesCostP",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode12 != NIL
		::oWScostP := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostP():New()
		::oWScostP:SoapRecv(oNode12)
	EndIf
	oNode13 :=  WSAdvValue( oResponse,"_COSTS","ArrayOfclaimStatusReplyClaimRecRequestValuesCostS",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode13 != NIL
		::oWScostS := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostS():New()
		::oWScostS:SoapRecv(oNode13)
	EndIf
	oNode14 :=  WSAdvValue( oResponse,"_COSTU","ArrayOfclaimStatusReplyClaimRecRequestValuesCostU",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode14 != NIL
		::oWScostU := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostU():New()
		::oWScostU:SoapRecv(oNode14)
	EndIf
	oNode15 :=  WSAdvValue( oResponse,"_COSTX01","ArrayOfclaimStatusReplyClaimRecRequestValuesCostX01",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode15 != NIL
		::oWScostX01 := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostX01():New()
		::oWScostX01:SoapRecv(oNode15)
	EndIf
	::ncustAmt           :=  WSAdvValue( oResponse,"_CUSTAMT","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::ccustNo            :=  WSAdvValue( oResponse,"_CUSTNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccustText          :=  WSAdvValue( oResponse,"_CUSTTEXT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdamagePartNo      :=  WSAdvValue( oResponse,"_DAMAGEPARTNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdelCode           :=  WSAdvValue( oResponse,"_DELCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdemFactorL        :=  WSAdvValue( oResponse,"_DEMFACTORL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdemFactorP        :=  WSAdvValue( oResponse,"_DEMFACTORP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdemFactorS        :=  WSAdvValue( oResponse,"_DEMFACTORS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdemFactorU        :=  WSAdvValue( oResponse,"_DEMFACTORU","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdemType           :=  WSAdvValue( oResponse,"_DEMTYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdistrNationCode   :=  WSAdvValue( oResponse,"_DISTRNATIONCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdistrNo           :=  WSAdvValue( oResponse,"_DISTRNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::celapsedTime       :=  WSAdvValue( oResponse,"_ELAPSEDTIME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cepsName           :=  WSAdvValue( oResponse,"_EPSNAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cfailNo            :=  WSAdvValue( oResponse,"_FAILNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cfailRepNo         :=  WSAdvValue( oResponse,"_FAILREPNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cfailureCode       :=  WSAdvValue( oResponse,"_FAILURECODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cfieldTestNo       :=  WSAdvValue( oResponse,"_FIELDTESTNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cforVehicle        :=  WSAdvValue( oResponse,"_FORVEHICLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cjobNo             :=  WSAdvValue( oResponse,"_JOBNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::clocalClaimCode    :=  WSAdvValue( oResponse,"_LOCALCLAIMCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::clocationCode      :=  WSAdvValue( oResponse,"_LOCATIONCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmaingroup         :=  WSAdvValue( oResponse,"_MAINGROUP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmaintCode         :=  WSAdvValue( oResponse,"_MAINTCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmanufCode         :=  WSAdvValue( oResponse,"_MANUFCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmechanic          :=  WSAdvValue( oResponse,"_MECHANIC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmileage           :=  WSAdvValue( oResponse,"_MILEAGE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmountDate         :=  WSAdvValue( oResponse,"_MOUNTDATE","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::lmountDateSpecified :=  WSAdvValue( oResponse,"_MOUNTDATESPECIFIED","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cmountMileage      :=  WSAdvValue( oResponse,"_MOUNTMILEAGE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cnationCode        :=  WSAdvValue( oResponse,"_NATIONCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::copenDate          :=  WSAdvValue( oResponse,"_OPENDATE","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::lopenDateSpecified :=  WSAdvValue( oResponse,"_OPENDATESPECIFIED","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cpriceList         :=  WSAdvValue( oResponse,"_PRICELIST","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cprodType          :=  WSAdvValue( oResponse,"_PRODTYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::creceptionist      :=  WSAdvValue( oResponse,"_RECEPTIONIST","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::creconNo           :=  WSAdvValue( oResponse,"_RECONNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::crefClaimNo        :=  WSAdvValue( oResponse,"_REFCLAIMNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::crefNo             :=  WSAdvValue( oResponse,"_REFNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::crefText           :=  WSAdvValue( oResponse,"_REFTEXT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::crepDate           :=  WSAdvValue( oResponse,"_REPDATE","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::crepairCode        :=  WSAdvValue( oResponse,"_REPAIRCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::csourceCode        :=  WSAdvValue( oResponse,"_SOURCECODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::csubgroup          :=  WSAdvValue( oResponse,"_SUBGROUP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::csymptomCode       :=  WSAdvValue( oResponse,"_SYMPTOMCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode61 :=  WSAdvValue( oResponse,"_TIMESTAMP","ArrayOfclaimStatusReplyClaimRecRequestValuesTimeStamp",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode61 != NIL
		::oWStimeStamp := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesTimeStamp():New()
		::oWStimeStamp:SoapRecv(oNode61)
	EndIf
	::ctimeStampCode     :=  WSAdvValue( oResponse,"_TIMESTAMPCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cuserConf          :=  WSAdvValue( oResponse,"_USERCONF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cverCode           :=  WSAdvValue( oResponse,"_VERCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cworkOrdNo         :=  WSAdvValue( oResponse,"_WORKORDNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cworkshopText      :=  WSAdvValue( oResponse,"_WORKSHOPTEXT","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure claimStatusReplyClaimRecResponseValues

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValues
	WSDATA   cagreementId              AS string OPTIONAL
	WSDATA   cchassiNo                 AS string OPTIONAL
	WSDATA   cclaimNo                  AS string OPTIONAL
	WSDATA   oWSclaimsReply            AS MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesClaimsReply OPTIONAL
	WSDATA   ncompLcAmt                AS decimal OPTIONAL
	WSDATA   lcompLcAmtSpecified       AS boolean OPTIONAL
	WSDATA   ncompMiscAmt              AS decimal OPTIONAL
	WSDATA   lcompMiscAmtSpecified     AS boolean OPTIONAL
	WSDATA   oWScostL                  AS MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostL OPTIONAL
	WSDATA   oWScostP                  AS MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostP OPTIONAL
	WSDATA   oWScostS                  AS MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostS OPTIONAL
	WSDATA   oWScostU                  AS MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostU OPTIONAL
	WSDATA   ccreditDate               AS dateTime OPTIONAL
	WSDATA   lcreditDateSpecified      AS boolean OPTIONAL
	WSDATA   ccreditNote               AS string OPTIONAL
	WSDATA   ccustNo                   AS string OPTIONAL
	WSDATA   oWSexplanationCode        AS MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesExplanationCode OPTIONAL
	WSDATA   cfailNo                   AS string OPTIONAL
	WSDATA   oWSfaultDescr             AS MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesFaultDescr OPTIONAL
	WSDATA   cjobNo                    AS string OPTIONAL
	WSDATA   clocalClaimCode           AS string OPTIONAL
	WSDATA   cnationCode               AS string OPTIONAL
	WSDATA   cprodType                 AS string OPTIONAL
	WSDATA   creconNo                  AS string OPTIONAL
	WSDATA   creplyText                AS string OPTIONAL
	WSDATA   cresultCode               AS string OPTIONAL
	WSDATA   oWSresultCodeDescr        AS MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesResultCodeDescr OPTIONAL
	WSDATA   cworkOrdNo                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValues
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValues
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValues
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValues():NEW()
	oClone:cagreementId         := ::cagreementId
	oClone:cchassiNo            := ::cchassiNo
	oClone:cclaimNo             := ::cclaimNo
	oClone:oWSclaimsReply       := IIF(::oWSclaimsReply = NIL , NIL , ::oWSclaimsReply:Clone() )
	oClone:ncompLcAmt           := ::ncompLcAmt
	oClone:lcompLcAmtSpecified  := ::lcompLcAmtSpecified
	oClone:ncompMiscAmt         := ::ncompMiscAmt
	oClone:lcompMiscAmtSpecified := ::lcompMiscAmtSpecified
	oClone:oWScostL             := IIF(::oWScostL = NIL , NIL , ::oWScostL:Clone() )
	oClone:oWScostP             := IIF(::oWScostP = NIL , NIL , ::oWScostP:Clone() )
	oClone:oWScostS             := IIF(::oWScostS = NIL , NIL , ::oWScostS:Clone() )
	oClone:oWScostU             := IIF(::oWScostU = NIL , NIL , ::oWScostU:Clone() )
	oClone:ccreditDate          := ::ccreditDate
	oClone:lcreditDateSpecified := ::lcreditDateSpecified
	oClone:ccreditNote          := ::ccreditNote
	oClone:ccustNo              := ::ccustNo
	oClone:oWSexplanationCode   := IIF(::oWSexplanationCode = NIL , NIL , ::oWSexplanationCode:Clone() )
	oClone:cfailNo              := ::cfailNo
	oClone:oWSfaultDescr        := IIF(::oWSfaultDescr = NIL , NIL , ::oWSfaultDescr:Clone() )
	oClone:cjobNo               := ::cjobNo
	oClone:clocalClaimCode      := ::clocalClaimCode
	oClone:cnationCode          := ::cnationCode
	oClone:cprodType            := ::cprodType
	oClone:creconNo             := ::creconNo
	oClone:creplyText           := ::creplyText
	oClone:cresultCode          := ::cresultCode
	oClone:oWSresultCodeDescr   := IIF(::oWSresultCodeDescr = NIL , NIL , ::oWSresultCodeDescr:Clone() )
	oClone:cworkOrdNo           := ::cworkOrdNo
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValues
	Local oNode4
	Local oNode9
	Local oNode10
	Local oNode11
	Local oNode12
	Local oNode17
	Local oNode19
	Local oNode27
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cagreementId       :=  WSAdvValue( oResponse,"_AGREEMENTID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cchassiNo          :=  WSAdvValue( oResponse,"_CHASSINO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cclaimNo           :=  WSAdvValue( oResponse,"_CLAIMNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode4 :=  WSAdvValue( oResponse,"_CLAIMSREPLY","claimStatusReplyClaimRecResponseValuesClaimsReply",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode4 != NIL
		::oWSclaimsReply := MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesClaimsReply():New()
		::oWSclaimsReply:SoapRecv(oNode4)
	EndIf
	::ncompLcAmt         :=  WSAdvValue( oResponse,"_COMPLCAMT","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::lcompLcAmtSpecified :=  WSAdvValue( oResponse,"_COMPLCAMTSPECIFIED","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::ncompMiscAmt       :=  WSAdvValue( oResponse,"_COMPMISCAMT","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::lcompMiscAmtSpecified :=  WSAdvValue( oResponse,"_COMPMISCAMTSPECIFIED","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	oNode9 :=  WSAdvValue( oResponse,"_COSTL","ArrayOfclaimStatusReplyClaimRecResponseValuesCostL",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode9 != NIL
		::oWScostL := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostL():New()
		::oWScostL:SoapRecv(oNode9)
	EndIf
	oNode10 :=  WSAdvValue( oResponse,"_COSTP","ArrayOfclaimStatusReplyClaimRecResponseValuesCostP",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode10 != NIL
		::oWScostP := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostP():New()
		::oWScostP:SoapRecv(oNode10)
	EndIf
	oNode11 :=  WSAdvValue( oResponse,"_COSTS","ArrayOfclaimStatusReplyClaimRecResponseValuesCostS",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode11 != NIL
		::oWScostS := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostS():New()
		::oWScostS:SoapRecv(oNode11)
	EndIf
	oNode12 :=  WSAdvValue( oResponse,"_COSTU","ArrayOfclaimStatusReplyClaimRecResponseValuesCostU",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode12 != NIL
		::oWScostU := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostU():New()
		::oWScostU:SoapRecv(oNode12)
	EndIf
	::ccreditDate        :=  WSAdvValue( oResponse,"_CREDITDATE","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::lcreditDateSpecified :=  WSAdvValue( oResponse,"_CREDITDATESPECIFIED","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::ccreditNote        :=  WSAdvValue( oResponse,"_CREDITNOTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccustNo            :=  WSAdvValue( oResponse,"_CUSTNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode17 :=  WSAdvValue( oResponse,"_EXPLANATIONCODE","claimStatusReplyClaimRecResponseValuesExplanationCode",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode17 != NIL
		::oWSexplanationCode := MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesExplanationCode():New()
		::oWSexplanationCode:SoapRecv(oNode17)
	EndIf
	::cfailNo            :=  WSAdvValue( oResponse,"_FAILNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode19 :=  WSAdvValue( oResponse,"_FAULTDESCR","ArrayOfclaimStatusReplyClaimRecResponseValuesFaultDescr",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode19 != NIL
		::oWSfaultDescr := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesFaultDescr():New()
		::oWSfaultDescr:SoapRecv(oNode19)
	EndIf
	::cjobNo             :=  WSAdvValue( oResponse,"_JOBNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::clocalClaimCode    :=  WSAdvValue( oResponse,"_LOCALCLAIMCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cnationCode        :=  WSAdvValue( oResponse,"_NATIONCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cprodType          :=  WSAdvValue( oResponse,"_PRODTYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::creconNo           :=  WSAdvValue( oResponse,"_RECONNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::creplyText         :=  WSAdvValue( oResponse,"_REPLYTEXT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cresultCode        :=  WSAdvValue( oResponse,"_RESULTCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode27 :=  WSAdvValue( oResponse,"_RESULTCODEDESCR","claimStatusReplyClaimRecResponseValuesResultCodeDescr",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode27 != NIL
		::oWSresultCodeDescr := MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesResultCodeDescr():New()
		::oWSresultCodeDescr:SoapRecv(oNode27)
	EndIf
	::cworkOrdNo         :=  WSAdvValue( oResponse,"_WORKORDNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


// WSDL Data Structure campReplyCampRRecCampOp

WSSTRUCT MIL_ScaniaClaw_campReplyCampRRecCampOp
	WSDATA   copCode                   AS string OPTIONAL
	WSDATA   cqty                      AS string OPTIONAL
	WSDATA   ntime                     AS decimal OPTIONAL
	WSDATA   cvariants                 AS string OPTIONAL
	WSDATA   cworkScope                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_campReplyCampRRecCampOp
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_campReplyCampRRecCampOp
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_campReplyCampRRecCampOp
	Local oClone := MIL_ScaniaClaw_campReplyCampRRecCampOp():NEW()
	oClone:copCode              := ::copCode
	oClone:cqty                 := ::cqty
	oClone:ntime                := ::ntime
	oClone:cvariants            := ::cvariants
	oClone:cworkScope           := ::cworkScope
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_campReplyCampRRecCampOp
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::copCode            :=  WSAdvValue( oResponse,"_OPCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cqty               :=  WSAdvValue( oResponse,"_QTY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ntime              :=  WSAdvValue( oResponse,"_TIME","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::cvariants          :=  WSAdvValue( oResponse,"_VARIANTS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cworkScope         :=  WSAdvValue( oResponse,"_WORKSCOPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure campReplyCampRRecCampPart

WSSTRUCT MIL_ScaniaClaw_campReplyCampRRecCampPart
	WSDATA   cassortmentCode           AS string OPTIONAL
	WSDATA   cclaimCode                AS string OPTIONAL
	WSDATA   cdamageCode               AS string OPTIONAL
	WSDATA   cdescr                    AS string OPTIONAL
	WSDATA   cpartNo                   AS string OPTIONAL
	WSDATA   cqty                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_campReplyCampRRecCampPart
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_campReplyCampRRecCampPart
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_campReplyCampRRecCampPart
	Local oClone := MIL_ScaniaClaw_campReplyCampRRecCampPart():NEW()
	oClone:cassortmentCode      := ::cassortmentCode
	oClone:cclaimCode           := ::cclaimCode
	oClone:cdamageCode          := ::cdamageCode
	oClone:cdescr               := ::cdescr
	oClone:cpartNo              := ::cpartNo
	oClone:cqty                 := ::cqty
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_campReplyCampRRecCampPart
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cassortmentCode    :=  WSAdvValue( oResponse,"_ASSORTMENTCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cclaimCode         :=  WSAdvValue( oResponse,"_CLAIMCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdamageCode        :=  WSAdvValue( oResponse,"_DAMAGECODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescr             :=  WSAdvValue( oResponse,"_DESCR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cpartNo            :=  WSAdvValue( oResponse,"_PARTNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cqty               :=  WSAdvValue( oResponse,"_QTY","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure campReplyCampRRecComp

WSSTRUCT MIL_ScaniaClaw_campReplyCampRRecComp
	WSDATA   ncompPercent              AS decimal OPTIONAL
	WSDATA   cmaxDelDays               AS string OPTIONAL
	WSDATA   cmaxMileage               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_campReplyCampRRecComp
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_campReplyCampRRecComp
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_campReplyCampRRecComp
	Local oClone := MIL_ScaniaClaw_campReplyCampRRecComp():NEW()
	oClone:ncompPercent         := ::ncompPercent
	oClone:cmaxDelDays          := ::cmaxDelDays
	oClone:cmaxMileage          := ::cmaxMileage
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_campReplyCampRRecComp
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncompPercent       :=  WSAdvValue( oResponse,"_COMPPERCENT","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::cmaxDelDays        :=  WSAdvValue( oResponse,"_MAXDELDAYS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmaxMileage        :=  WSAdvValue( oResponse,"_MAXMILEAGE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure campReplyCampRRecFaultDescr

WSSTRUCT MIL_ScaniaClaw_campReplyCampRRecFaultDescr
	WSDATA   ccodeId                   AS string OPTIONAL
	WSDATA   ccodeTypeId               AS string OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_campReplyCampRRecFaultDescr
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_campReplyCampRRecFaultDescr
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_campReplyCampRRecFaultDescr
	Local oClone := MIL_ScaniaClaw_campReplyCampRRecFaultDescr():NEW()
	oClone:ccodeId              := ::ccodeId
	oClone:ccodeTypeId          := ::ccodeTypeId
	oClone:cdescription         := ::cdescription
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_campReplyCampRRecFaultDescr
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccodeId            :=  WSAdvValue( oResponse,"_CODEID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccodeTypeId        :=  WSAdvValue( oResponse,"_CODETYPEID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfclaimStatusReplyClaimRecRequestValuesCostL

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostL
	WSDATA   oWSclaimStatusReplyClaimRecRequestValuesCostL AS MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostL OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostL
	::oWSclaimStatusReplyClaimRecRequestValuesCostL := {} // Array Of  MIL_ScaniaClaw_CLAIMSTATUSREPLYCLAIMRECREQUESTVALUESCOSTL():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostL
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostL():NEW()
	oClone:oWSclaimStatusReplyClaimRecRequestValuesCostL := NIL
	If ::oWSclaimStatusReplyClaimRecRequestValuesCostL <> NIL 
		oClone:oWSclaimStatusReplyClaimRecRequestValuesCostL := {}
		aEval( ::oWSclaimStatusReplyClaimRecRequestValuesCostL , { |x| aadd( oClone:oWSclaimStatusReplyClaimRecRequestValuesCostL , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostL
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLAIMSTATUSREPLYCLAIMRECREQUESTVALUESCOSTL","claimStatusReplyClaimRecRequestValuesCostL",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclaimStatusReplyClaimRecRequestValuesCostL , MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostL():New() )
			::oWSclaimStatusReplyClaimRecRequestValuesCostL[len(::oWSclaimStatusReplyClaimRecRequestValuesCostL)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfclaimStatusReplyClaimRecRequestValuesCostP

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostP
	WSDATA   oWSclaimStatusReplyClaimRecRequestValuesCostP AS MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostP OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostP
	::oWSclaimStatusReplyClaimRecRequestValuesCostP := {} // Array Of  MIL_ScaniaClaw_CLAIMSTATUSREPLYCLAIMRECREQUESTVALUESCOSTP():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostP
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostP():NEW()
	oClone:oWSclaimStatusReplyClaimRecRequestValuesCostP := NIL
	If ::oWSclaimStatusReplyClaimRecRequestValuesCostP <> NIL 
		oClone:oWSclaimStatusReplyClaimRecRequestValuesCostP := {}
		aEval( ::oWSclaimStatusReplyClaimRecRequestValuesCostP , { |x| aadd( oClone:oWSclaimStatusReplyClaimRecRequestValuesCostP , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostP
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLAIMSTATUSREPLYCLAIMRECREQUESTVALUESCOSTP","claimStatusReplyClaimRecRequestValuesCostP",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclaimStatusReplyClaimRecRequestValuesCostP , MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostP():New() )
			::oWSclaimStatusReplyClaimRecRequestValuesCostP[len(::oWSclaimStatusReplyClaimRecRequestValuesCostP)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfclaimStatusReplyClaimRecRequestValuesCostS

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostS
	WSDATA   oWSclaimStatusReplyClaimRecRequestValuesCostS AS MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostS
	::oWSclaimStatusReplyClaimRecRequestValuesCostS := {} // Array Of  MIL_ScaniaClaw_CLAIMSTATUSREPLYCLAIMRECREQUESTVALUESCOSTS():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostS
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostS():NEW()
	oClone:oWSclaimStatusReplyClaimRecRequestValuesCostS := NIL
	If ::oWSclaimStatusReplyClaimRecRequestValuesCostS <> NIL 
		oClone:oWSclaimStatusReplyClaimRecRequestValuesCostS := {}
		aEval( ::oWSclaimStatusReplyClaimRecRequestValuesCostS , { |x| aadd( oClone:oWSclaimStatusReplyClaimRecRequestValuesCostS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLAIMSTATUSREPLYCLAIMRECREQUESTVALUESCOSTS","claimStatusReplyClaimRecRequestValuesCostS",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclaimStatusReplyClaimRecRequestValuesCostS , MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostS():New() )
			::oWSclaimStatusReplyClaimRecRequestValuesCostS[len(::oWSclaimStatusReplyClaimRecRequestValuesCostS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfclaimStatusReplyClaimRecRequestValuesCostU

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostU
	WSDATA   oWSclaimStatusReplyClaimRecRequestValuesCostU AS MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostU OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostU
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostU
	::oWSclaimStatusReplyClaimRecRequestValuesCostU := {} // Array Of  MIL_ScaniaClaw_CLAIMSTATUSREPLYCLAIMRECREQUESTVALUESCOSTU():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostU
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostU():NEW()
	oClone:oWSclaimStatusReplyClaimRecRequestValuesCostU := NIL
	If ::oWSclaimStatusReplyClaimRecRequestValuesCostU <> NIL 
		oClone:oWSclaimStatusReplyClaimRecRequestValuesCostU := {}
		aEval( ::oWSclaimStatusReplyClaimRecRequestValuesCostU , { |x| aadd( oClone:oWSclaimStatusReplyClaimRecRequestValuesCostU , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostU
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLAIMSTATUSREPLYCLAIMRECREQUESTVALUESCOSTU","claimStatusReplyClaimRecRequestValuesCostU",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclaimStatusReplyClaimRecRequestValuesCostU , MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostU():New() )
			::oWSclaimStatusReplyClaimRecRequestValuesCostU[len(::oWSclaimStatusReplyClaimRecRequestValuesCostU)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfclaimStatusReplyClaimRecRequestValuesCostX01

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostX01
	WSDATA   oWSclaimStatusReplyClaimRecRequestValuesCostX01 AS MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostX01 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostX01
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostX01
	::oWSclaimStatusReplyClaimRecRequestValuesCostX01 := {} // Array Of  MIL_ScaniaClaw_CLAIMSTATUSREPLYCLAIMRECREQUESTVALUESCOSTX01():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostX01
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostX01():NEW()
	oClone:oWSclaimStatusReplyClaimRecRequestValuesCostX01 := NIL
	If ::oWSclaimStatusReplyClaimRecRequestValuesCostX01 <> NIL 
		oClone:oWSclaimStatusReplyClaimRecRequestValuesCostX01 := {}
		aEval( ::oWSclaimStatusReplyClaimRecRequestValuesCostX01 , { |x| aadd( oClone:oWSclaimStatusReplyClaimRecRequestValuesCostX01 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesCostX01
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLAIMSTATUSREPLYCLAIMRECREQUESTVALUESCOSTX01","claimStatusReplyClaimRecRequestValuesCostX01",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclaimStatusReplyClaimRecRequestValuesCostX01 , MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostX01():New() )
			::oWSclaimStatusReplyClaimRecRequestValuesCostX01[len(::oWSclaimStatusReplyClaimRecRequestValuesCostX01)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfclaimStatusReplyClaimRecRequestValuesTimeStamp

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesTimeStamp
	WSDATA   oWSclaimStatusReplyClaimRecRequestValuesTimeStamp AS MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesTimeStamp OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
	WSMETHOD ADDAPONT
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesTimeStamp
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesTimeStamp
	::oWSclaimStatusReplyClaimRecRequestValuesTimeStamp := {} // Array Of  MIL_ScaniaClaw_CLAIMSTATUSREPLYCLAIMRECREQUESTVALUESTIMESTAMP():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesTimeStamp
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesTimeStamp():NEW()
	oClone:oWSclaimStatusReplyClaimRecRequestValuesTimeStamp := NIL
	If ::oWSclaimStatusReplyClaimRecRequestValuesTimeStamp <> NIL 
		oClone:oWSclaimStatusReplyClaimRecRequestValuesTimeStamp := {}
		aEval( ::oWSclaimStatusReplyClaimRecRequestValuesTimeStamp , { |x| aadd( oClone:oWSclaimStatusReplyClaimRecRequestValuesTimeStamp , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesTimeStamp
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLAIMSTATUSREPLYCLAIMRECREQUESTVALUESTIMESTAMP","claimStatusReplyClaimRecRequestValuesTimeStamp",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclaimStatusReplyClaimRecRequestValuesTimeStamp , MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesTimeStamp():New() )
			::oWSclaimStatusReplyClaimRecRequestValuesTimeStamp[len(::oWSclaimStatusReplyClaimRecRequestValuesTimeStamp)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

WSMETHOD ADDAPONT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecRequestValuesTimeStamp
	AADD(::oWSclaimStatusReplyClaimRecRequestValuesTimeStamp, MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesTimeStamp():New() )
Return (Len(::oWSclaimStatusReplyClaimRecRequestValuesTimeStamp))


// WSDL Data Structure claimStatusReplyClaimRecResponseValuesClaimsReply

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesClaimsReply
	WSDATA   ccodeId                   AS string OPTIONAL
	WSDATA   ccodeTypeId               AS string OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesClaimsReply
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesClaimsReply
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesClaimsReply
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesClaimsReply():NEW()
	oClone:ccodeId              := ::ccodeId
	oClone:ccodeTypeId          := ::ccodeTypeId
	oClone:cdescription         := ::cdescription
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesClaimsReply
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccodeId            :=  WSAdvValue( oResponse,"_CODEID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccodeTypeId        :=  WSAdvValue( oResponse,"_CODETYPEID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfclaimStatusReplyClaimRecResponseValuesCostL

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostL
	WSDATA   oWSclaimStatusReplyClaimRecResponseValuesCostL AS MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostL OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostL
	::oWSclaimStatusReplyClaimRecResponseValuesCostL := {} // Array Of  MIL_ScaniaClaw_CLAIMSTATUSREPLYCLAIMRECRESPONSEVALUESCOSTL():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostL
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostL():NEW()
	oClone:oWSclaimStatusReplyClaimRecResponseValuesCostL := NIL
	If ::oWSclaimStatusReplyClaimRecResponseValuesCostL <> NIL 
		oClone:oWSclaimStatusReplyClaimRecResponseValuesCostL := {}
		aEval( ::oWSclaimStatusReplyClaimRecResponseValuesCostL , { |x| aadd( oClone:oWSclaimStatusReplyClaimRecResponseValuesCostL , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostL
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLAIMSTATUSREPLYCLAIMRECRESPONSEVALUESCOSTL","claimStatusReplyClaimRecResponseValuesCostL",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclaimStatusReplyClaimRecResponseValuesCostL , MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostL():New() )
			::oWSclaimStatusReplyClaimRecResponseValuesCostL[len(::oWSclaimStatusReplyClaimRecResponseValuesCostL)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfclaimStatusReplyClaimRecResponseValuesCostP

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostP
	WSDATA   oWSclaimStatusReplyClaimRecResponseValuesCostP AS MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostP OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostP
	::oWSclaimStatusReplyClaimRecResponseValuesCostP := {} // Array Of  MIL_ScaniaClaw_CLAIMSTATUSREPLYCLAIMRECRESPONSEVALUESCOSTP():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostP
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostP():NEW()
	oClone:oWSclaimStatusReplyClaimRecResponseValuesCostP := NIL
	If ::oWSclaimStatusReplyClaimRecResponseValuesCostP <> NIL 
		oClone:oWSclaimStatusReplyClaimRecResponseValuesCostP := {}
		aEval( ::oWSclaimStatusReplyClaimRecResponseValuesCostP , { |x| aadd( oClone:oWSclaimStatusReplyClaimRecResponseValuesCostP , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostP
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLAIMSTATUSREPLYCLAIMRECRESPONSEVALUESCOSTP","claimStatusReplyClaimRecResponseValuesCostP",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclaimStatusReplyClaimRecResponseValuesCostP , MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostP():New() )
			::oWSclaimStatusReplyClaimRecResponseValuesCostP[len(::oWSclaimStatusReplyClaimRecResponseValuesCostP)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfclaimStatusReplyClaimRecResponseValuesCostS

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostS
	WSDATA   oWSclaimStatusReplyClaimRecResponseValuesCostS AS MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostS
	::oWSclaimStatusReplyClaimRecResponseValuesCostS := {} // Array Of  MIL_ScaniaClaw_CLAIMSTATUSREPLYCLAIMRECRESPONSEVALUESCOSTS():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostS
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostS():NEW()
	oClone:oWSclaimStatusReplyClaimRecResponseValuesCostS := NIL
	If ::oWSclaimStatusReplyClaimRecResponseValuesCostS <> NIL 
		oClone:oWSclaimStatusReplyClaimRecResponseValuesCostS := {}
		aEval( ::oWSclaimStatusReplyClaimRecResponseValuesCostS , { |x| aadd( oClone:oWSclaimStatusReplyClaimRecResponseValuesCostS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLAIMSTATUSREPLYCLAIMRECRESPONSEVALUESCOSTS","claimStatusReplyClaimRecResponseValuesCostS",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclaimStatusReplyClaimRecResponseValuesCostS , MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostS():New() )
			::oWSclaimStatusReplyClaimRecResponseValuesCostS[len(::oWSclaimStatusReplyClaimRecResponseValuesCostS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfclaimStatusReplyClaimRecResponseValuesCostU

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostU
	WSDATA   oWSclaimStatusReplyClaimRecResponseValuesCostU AS MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostU OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostU
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostU
	::oWSclaimStatusReplyClaimRecResponseValuesCostU := {} // Array Of  MIL_ScaniaClaw_CLAIMSTATUSREPLYCLAIMRECRESPONSEVALUESCOSTU():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostU
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostU():NEW()
	oClone:oWSclaimStatusReplyClaimRecResponseValuesCostU := NIL
	If ::oWSclaimStatusReplyClaimRecResponseValuesCostU <> NIL 
		oClone:oWSclaimStatusReplyClaimRecResponseValuesCostU := {}
		aEval( ::oWSclaimStatusReplyClaimRecResponseValuesCostU , { |x| aadd( oClone:oWSclaimStatusReplyClaimRecResponseValuesCostU , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostU
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLAIMSTATUSREPLYCLAIMRECRESPONSEVALUESCOSTU","claimStatusReplyClaimRecResponseValuesCostU",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclaimStatusReplyClaimRecResponseValuesCostU , MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostU():New() )
			::oWSclaimStatusReplyClaimRecResponseValuesCostU[len(::oWSclaimStatusReplyClaimRecResponseValuesCostU)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure claimStatusReplyClaimRecResponseValuesExplanationCode

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesExplanationCode
	WSDATA   ccodeId                   AS string OPTIONAL
	WSDATA   ccodeTypeId               AS string OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesExplanationCode
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesExplanationCode
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesExplanationCode
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesExplanationCode():NEW()
	oClone:ccodeId              := ::ccodeId
	oClone:ccodeTypeId          := ::ccodeTypeId
	oClone:cdescription         := ::cdescription
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesExplanationCode
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccodeId            :=  WSAdvValue( oResponse,"_CODEID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccodeTypeId        :=  WSAdvValue( oResponse,"_CODETYPEID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfclaimStatusReplyClaimRecResponseValuesFaultDescr

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesFaultDescr
	WSDATA   oWSclaimStatusReplyClaimRecResponseValuesFaultDescr AS MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesFaultDescr OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesFaultDescr
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesFaultDescr
	::oWSclaimStatusReplyClaimRecResponseValuesFaultDescr := {} // Array Of  MIL_ScaniaClaw_CLAIMSTATUSREPLYCLAIMRECRESPONSEVALUESFAULTDESCR():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesFaultDescr
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesFaultDescr():NEW()
	oClone:oWSclaimStatusReplyClaimRecResponseValuesFaultDescr := NIL
	If ::oWSclaimStatusReplyClaimRecResponseValuesFaultDescr <> NIL 
		oClone:oWSclaimStatusReplyClaimRecResponseValuesFaultDescr := {}
		aEval( ::oWSclaimStatusReplyClaimRecResponseValuesFaultDescr , { |x| aadd( oClone:oWSclaimStatusReplyClaimRecResponseValuesFaultDescr , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesFaultDescr
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLAIMSTATUSREPLYCLAIMRECRESPONSEVALUESFAULTDESCR","claimStatusReplyClaimRecResponseValuesFaultDescr",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclaimStatusReplyClaimRecResponseValuesFaultDescr , MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesFaultDescr():New() )
			::oWSclaimStatusReplyClaimRecResponseValuesFaultDescr[len(::oWSclaimStatusReplyClaimRecResponseValuesFaultDescr)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure claimStatusReplyClaimRecResponseValuesResultCodeDescr

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesResultCodeDescr
	WSDATA   ccodeId                   AS string OPTIONAL
	WSDATA   ccodeTypeId               AS string OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesResultCodeDescr
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesResultCodeDescr
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesResultCodeDescr
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesResultCodeDescr():NEW()
	oClone:ccodeId              := ::ccodeId
	oClone:ccodeTypeId          := ::ccodeTypeId
	oClone:cdescription         := ::cdescription
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesResultCodeDescr
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccodeId            :=  WSAdvValue( oResponse,"_CODEID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccodeTypeId        :=  WSAdvValue( oResponse,"_CODETYPEID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure claimStatusReplyClaimRecRequestValuesCostL

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostL
	WSDATA   cextRowId                 AS string OPTIONAL
	WSDATA   copCode                   AS string OPTIONAL
	WSDATA   cqty                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostL
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostL
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostL():NEW()
	oClone:cextRowId            := ::cextRowId
	oClone:copCode              := ::copCode
	oClone:cqty                 := ::cqty
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostL
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cextRowId          :=  WSAdvValue( oResponse,"_EXTROWID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::copCode            :=  WSAdvValue( oResponse,"_OPCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cqty               :=  WSAdvValue( oResponse,"_QTY","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure claimStatusReplyClaimRecRequestValuesCostP

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostP
	WSDATA   cassortmentCode           AS string OPTIONAL
	WSDATA   cextRowId                 AS string OPTIONAL
	WSDATA   cpartNo                   AS string OPTIONAL
	WSDATA   cqty                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostP
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostP
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostP():NEW()
	oClone:cassortmentCode      := ::cassortmentCode
	oClone:cextRowId            := ::cextRowId
	oClone:cpartNo              := ::cpartNo
	oClone:cqty                 := ::cqty
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostP
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cassortmentCode    :=  WSAdvValue( oResponse,"_ASSORTMENTCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cextRowId          :=  WSAdvValue( oResponse,"_EXTROWID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cpartNo            :=  WSAdvValue( oResponse,"_PARTNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cqty               :=  WSAdvValue( oResponse,"_QTY","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure claimStatusReplyClaimRecRequestValuesCostS

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostS
	WSDATA   oWSdescr                  AS MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostSDescr OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSDATA   cextRowId                 AS string OPTIONAL
	WSDATA   nspCostAmt                AS decimal OPTIONAL
	WSDATA   ctypeSpecCode             AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostS
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostS
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostS():NEW()
	oClone:oWSdescr             := IIF(::oWSdescr = NIL , NIL , ::oWSdescr:Clone() )
	oClone:cdescription         := ::cdescription
	oClone:cextRowId            := ::cextRowId
	oClone:nspCostAmt           := ::nspCostAmt
	oClone:ctypeSpecCode        := ::ctypeSpecCode
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostS
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_DESCR","claimStatusReplyClaimRecRequestValuesCostSDescr",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSdescr := MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostSDescr():New()
		::oWSdescr:SoapRecv(oNode1)
	EndIf
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cextRowId          :=  WSAdvValue( oResponse,"_EXTROWID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nspCostAmt         :=  WSAdvValue( oResponse,"_SPCOSTAMT","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::ctypeSpecCode      :=  WSAdvValue( oResponse,"_TYPESPECCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure claimStatusReplyClaimRecRequestValuesCostU

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostU
	WSDATA   oWSdescr                  AS MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostUDescr OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSDATA   cextRowId                 AS string OPTIONAL
	WSDATA   nnoOfHours                AS decimal OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostU
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostU
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostU
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostU():NEW()
	oClone:oWSdescr             := IIF(::oWSdescr = NIL , NIL , ::oWSdescr:Clone() )
	oClone:cdescription         := ::cdescription
	oClone:cextRowId            := ::cextRowId
	oClone:nnoOfHours           := ::nnoOfHours
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostU
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_DESCR","claimStatusReplyClaimRecRequestValuesCostUDescr",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSdescr := MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostUDescr():New()
		::oWSdescr:SoapRecv(oNode1)
	EndIf
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cextRowId          :=  WSAdvValue( oResponse,"_EXTROWID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nnoOfHours         :=  WSAdvValue( oResponse,"_NOOFHOURS","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure claimStatusReplyClaimRecRequestValuesCostX01

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostX01
	WSDATA   cdescr                    AS string OPTIONAL
	WSDATA   cextRowId                 AS string OPTIONAL
	WSDATA   ntravelDist               AS decimal OPTIONAL
	WSDATA   ntravelTime               AS decimal OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostX01
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostX01
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostX01
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostX01():NEW()
	oClone:cdescr               := ::cdescr
	oClone:cextRowId            := ::cextRowId
	oClone:ntravelDist          := ::ntravelDist
	oClone:ntravelTime          := ::ntravelTime
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostX01
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cdescr             :=  WSAdvValue( oResponse,"_DESCR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cextRowId          :=  WSAdvValue( oResponse,"_EXTROWID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ntravelDist        :=  WSAdvValue( oResponse,"_TRAVELDIST","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::ntravelTime        :=  WSAdvValue( oResponse,"_TRAVELTIME","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure claimStatusReplyClaimRecRequestValuesTimeStamp

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesTimeStamp
	WSDATA   cStartTime                AS string OPTIONAL
	WSDATA   cstopTime                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesTimeStamp
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesTimeStamp
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesTimeStamp
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesTimeStamp():NEW()
	oClone:cStartTime           := ::cStartTime
	oClone:cstopTime            := ::cstopTime
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesTimeStamp
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cStartTime         :=  WSAdvValue( oResponse,"_STARTTIME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cstopTime          :=  WSAdvValue( oResponse,"_STOPTIME","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure claimStatusReplyClaimRecResponseValuesCostL

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostL
	WSDATA   ncompAmt                  AS decimal OPTIONAL
	WSDATA   ncompFactor               AS decimal OPTIONAL
	WSDATA   ccompQty                  AS string OPTIONAL
	WSDATA   ncompTime                 AS decimal OPTIONAL
	WSDATA   cextRowId                 AS string OPTIONAL
	WSDATA   nhourPrice                AS decimal OPTIONAL
	WSDATA   copCode                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostL
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostL
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostL():NEW()
	oClone:ncompAmt             := ::ncompAmt
	oClone:ncompFactor          := ::ncompFactor
	oClone:ccompQty             := ::ccompQty
	oClone:ncompTime            := ::ncompTime
	oClone:cextRowId            := ::cextRowId
	oClone:nhourPrice           := ::nhourPrice
	oClone:copCode              := ::copCode
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostL
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncompAmt           :=  WSAdvValue( oResponse,"_COMPAMT","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::ncompFactor        :=  WSAdvValue( oResponse,"_COMPFACTOR","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::ccompQty           :=  WSAdvValue( oResponse,"_COMPQTY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ncompTime          :=  WSAdvValue( oResponse,"_COMPTIME","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::cextRowId          :=  WSAdvValue( oResponse,"_EXTROWID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nhourPrice         :=  WSAdvValue( oResponse,"_HOURPRICE","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::copCode            :=  WSAdvValue( oResponse,"_OPCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure claimStatusReplyClaimRecResponseValuesCostP

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostP
	WSDATA   cassortmentCode           AS string OPTIONAL
	WSDATA   ncompAmt                  AS decimal OPTIONAL
	WSDATA   lcompAmtSpecified         AS boolean OPTIONAL
	WSDATA   ncompFactor               AS decimal OPTIONAL
	WSDATA   lcompFactorSpecified      AS boolean OPTIONAL
	WSDATA   ccompQty                  AS string OPTIONAL
	WSDATA   ndiscount                 AS decimal OPTIONAL
	WSDATA   ldiscountSpecified        AS boolean OPTIONAL
	WSDATA   cextRowId                 AS string OPTIONAL
	WSDATA   oWSgoodsAddress           AS MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostPGoodsAddress OPTIONAL
	WSDATA   ngrossPrice               AS decimal OPTIONAL
	WSDATA   lgrossPriceSpecified      AS boolean OPTIONAL
	WSDATA   cpartNo                   AS string OPTIONAL
	WSDATA   cresultGoodsCode          AS string OPTIONAL
	WSDATA   oWSresultGoodsDescr       AS MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostPResultGoodsDescr OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostP
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostP
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostP():NEW()
	oClone:cassortmentCode      := ::cassortmentCode
	oClone:ncompAmt             := ::ncompAmt
	oClone:lcompAmtSpecified    := ::lcompAmtSpecified
	oClone:ncompFactor          := ::ncompFactor
	oClone:lcompFactorSpecified := ::lcompFactorSpecified
	oClone:ccompQty             := ::ccompQty
	oClone:ndiscount            := ::ndiscount
	oClone:ldiscountSpecified   := ::ldiscountSpecified
	oClone:cextRowId            := ::cextRowId
	oClone:oWSgoodsAddress      := IIF(::oWSgoodsAddress = NIL , NIL , ::oWSgoodsAddress:Clone() )
	oClone:ngrossPrice          := ::ngrossPrice
	oClone:lgrossPriceSpecified := ::lgrossPriceSpecified
	oClone:cpartNo              := ::cpartNo
	oClone:cresultGoodsCode     := ::cresultGoodsCode
	oClone:oWSresultGoodsDescr  := IIF(::oWSresultGoodsDescr = NIL , NIL , ::oWSresultGoodsDescr:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostP
	Local oNode10
	Local oNode15
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cassortmentCode    :=  WSAdvValue( oResponse,"_ASSORTMENTCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ncompAmt           :=  WSAdvValue( oResponse,"_COMPAMT","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::lcompAmtSpecified  :=  WSAdvValue( oResponse,"_COMPAMTSPECIFIED","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::ncompFactor        :=  WSAdvValue( oResponse,"_COMPFACTOR","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::lcompFactorSpecified :=  WSAdvValue( oResponse,"_COMPFACTORSPECIFIED","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::ccompQty           :=  WSAdvValue( oResponse,"_COMPQTY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ndiscount          :=  WSAdvValue( oResponse,"_DISCOUNT","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::ldiscountSpecified :=  WSAdvValue( oResponse,"_DISCOUNTSPECIFIED","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cextRowId          :=  WSAdvValue( oResponse,"_EXTROWID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode10 :=  WSAdvValue( oResponse,"_GOODSADDRESS","ArrayOfclaimStatusReplyClaimRecResponseValuesCostPGoodsAddress",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode10 != NIL
		::oWSgoodsAddress := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostPGoodsAddress():New()
		::oWSgoodsAddress:SoapRecv(oNode10)
	EndIf
	::ngrossPrice        :=  WSAdvValue( oResponse,"_GROSSPRICE","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::lgrossPriceSpecified :=  WSAdvValue( oResponse,"_GROSSPRICESPECIFIED","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cpartNo            :=  WSAdvValue( oResponse,"_PARTNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cresultGoodsCode   :=  WSAdvValue( oResponse,"_RESULTGOODSCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode15 :=  WSAdvValue( oResponse,"_RESULTGOODSDESCR","claimStatusReplyClaimRecResponseValuesCostPResultGoodsDescr",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode15 != NIL
		::oWSresultGoodsDescr := MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostPResultGoodsDescr():New()
		::oWSresultGoodsDescr:SoapRecv(oNode15)
	EndIf
Return

// WSDL Data Structure claimStatusReplyClaimRecResponseValuesCostS

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostS
	WSDATA   ncompFactor               AS decimal OPTIONAL
	WSDATA   ncompSpCostAmt            AS decimal OPTIONAL
	WSDATA   cextRowId                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostS
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostS
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostS():NEW()
	oClone:ncompFactor          := ::ncompFactor
	oClone:ncompSpCostAmt       := ::ncompSpCostAmt
	oClone:cextRowId            := ::cextRowId
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncompFactor        :=  WSAdvValue( oResponse,"_COMPFACTOR","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::ncompSpCostAmt     :=  WSAdvValue( oResponse,"_COMPSPCOSTAMT","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::cextRowId          :=  WSAdvValue( oResponse,"_EXTROWID","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure claimStatusReplyClaimRecResponseValuesCostU

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostU
	WSDATA   ncompAmt                  AS decimal OPTIONAL
	WSDATA   ncompFactor               AS decimal OPTIONAL
	WSDATA   ncompTime                 AS decimal OPTIONAL
	WSDATA   cextRowId                 AS string OPTIONAL
	WSDATA   nhourPrice                AS decimal OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostU
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostU
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostU
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostU():NEW()
	oClone:ncompAmt             := ::ncompAmt
	oClone:ncompFactor          := ::ncompFactor
	oClone:ncompTime            := ::ncompTime
	oClone:cextRowId            := ::cextRowId
	oClone:nhourPrice           := ::nhourPrice
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostU
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncompAmt           :=  WSAdvValue( oResponse,"_COMPAMT","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::ncompFactor        :=  WSAdvValue( oResponse,"_COMPFACTOR","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::ncompTime          :=  WSAdvValue( oResponse,"_COMPTIME","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::cextRowId          :=  WSAdvValue( oResponse,"_EXTROWID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nhourPrice         :=  WSAdvValue( oResponse,"_HOURPRICE","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure claimStatusReplyClaimRecResponseValuesFaultDescr

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesFaultDescr
	WSDATA   ccodeId                   AS string OPTIONAL
	WSDATA   ccodeTypeId               AS string OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesFaultDescr
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesFaultDescr
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesFaultDescr
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesFaultDescr():NEW()
	oClone:ccodeId              := ::ccodeId
	oClone:ccodeTypeId          := ::ccodeTypeId
	oClone:cdescription         := ::cdescription
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesFaultDescr
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccodeId            :=  WSAdvValue( oResponse,"_CODEID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccodeTypeId        :=  WSAdvValue( oResponse,"_CODETYPEID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure claimStatusReplyClaimRecRequestValuesCostSDescr

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostSDescr
	WSDATA   ccodeId                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostSDescr
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostSDescr
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostSDescr
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostSDescr():NEW()
	oClone:ccodeId              := ::ccodeId
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostSDescr
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccodeId            :=  WSAdvValue( oResponse,"_CODEID","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure claimStatusReplyClaimRecRequestValuesCostUDescr

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostUDescr
	WSDATA   ccodeId                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostUDescr
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostUDescr
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostUDescr
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostUDescr():NEW()
	oClone:ccodeId              := ::ccodeId
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecRequestValuesCostUDescr
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccodeId            :=  WSAdvValue( oResponse,"_CODEID","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfclaimStatusReplyClaimRecResponseValuesCostPGoodsAddress

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostPGoodsAddress
	WSDATA   oWSclaimStatusReplyClaimRecResponseValuesCostPGoodsAddress AS MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostPGoodsAddress OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostPGoodsAddress
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostPGoodsAddress
	::oWSclaimStatusReplyClaimRecResponseValuesCostPGoodsAddress := {} // Array Of  MIL_ScaniaClaw_CLAIMSTATUSREPLYCLAIMRECRESPONSEVALUESCOSTPGOODSADDRESS():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostPGoodsAddress
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostPGoodsAddress():NEW()
	oClone:oWSclaimStatusReplyClaimRecResponseValuesCostPGoodsAddress := NIL
	If ::oWSclaimStatusReplyClaimRecResponseValuesCostPGoodsAddress <> NIL 
		oClone:oWSclaimStatusReplyClaimRecResponseValuesCostPGoodsAddress := {}
		aEval( ::oWSclaimStatusReplyClaimRecResponseValuesCostPGoodsAddress , { |x| aadd( oClone:oWSclaimStatusReplyClaimRecResponseValuesCostPGoodsAddress , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_ArrayOfclaimStatusReplyClaimRecResponseValuesCostPGoodsAddress
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLAIMSTATUSREPLYCLAIMRECRESPONSEVALUESCOSTPGOODSADDRESS","claimStatusReplyClaimRecResponseValuesCostPGoodsAddress",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclaimStatusReplyClaimRecResponseValuesCostPGoodsAddress , MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostPGoodsAddress():New() )
			::oWSclaimStatusReplyClaimRecResponseValuesCostPGoodsAddress[len(::oWSclaimStatusReplyClaimRecResponseValuesCostPGoodsAddress)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure claimStatusReplyClaimRecResponseValuesCostPResultGoodsDescr

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostPResultGoodsDescr
	WSDATA   ccodeId                   AS string OPTIONAL
	WSDATA   ccodeTypeId               AS string OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostPResultGoodsDescr
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostPResultGoodsDescr
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostPResultGoodsDescr
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostPResultGoodsDescr():NEW()
	oClone:ccodeId              := ::ccodeId
	oClone:ccodeTypeId          := ::ccodeTypeId
	oClone:cdescription         := ::cdescription
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostPResultGoodsDescr
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccodeId            :=  WSAdvValue( oResponse,"_CODEID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccodeTypeId        :=  WSAdvValue( oResponse,"_CODETYPEID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure claimStatusReplyClaimRecResponseValuesCostPGoodsAddress

WSSTRUCT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostPGoodsAddress
	WSDATA   caddress                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostPGoodsAddress
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostPGoodsAddress
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostPGoodsAddress
	Local oClone := MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostPGoodsAddress():NEW()
	oClone:caddress             := ::caddress
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimStatusReplyClaimRecResponseValuesCostPGoodsAddress
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::caddress           :=  WSAdvValue( oResponse,"_ADDRESS","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return












































// WSDL Data Structure claimRequest

WSSTRUCT MIL_ScaniaClaw_claimRequest
	WSDATA   oWSSaveClaimRec               AS MIL_ScaniaClaw_ArrayOfclaimRequestClaimRec OPTIONAL
	WSDATA   cinterfaceVersion         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimRequest
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimRequest
	::cInterfaceVersion := INTERFACE_VERSION
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimRequest
	Local oClone := MIL_ScaniaClaw_claimRequest():NEW()
	oClone:oWSSaveClaimRec          := IIF(::oWSSaveClaimRec = NIL , NIL , ::oWSSaveClaimRec:Clone() )
	oClone:cinterfaceVersion    := ::cinterfaceVersion
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_claimRequest
	Local cSoap := ""
	cSoap += WSSoapValue("claimRec", ::oWSSaveClaimRec, ::oWSSaveClaimRec , "ArrayOfclaimRequestClaimRec", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("interfaceVersion", ::cinterfaceVersion, ::cinterfaceVersion , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
Return cSoap

// WSDL Data Structure claimRequestReply

WSSTRUCT MIL_ScaniaClaw_claimRequestReply
	WSDATA   oWSSaveClaimRec               AS MIL_ScaniaClaw_ArrayOfclaimRequestReplyClaimRec OPTIONAL
	WSDATA   cinterfaceVersion         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimRequestReply
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimRequestReply
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimRequestReply
	Local oClone := MIL_ScaniaClaw_claimRequestReply():NEW()
	oClone:oWSSaveClaimRec          := IIF(::oWSSaveClaimRec = NIL , NIL , ::oWSSaveClaimRec:Clone() )
	oClone:cinterfaceVersion    := ::cinterfaceVersion
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimRequestReply
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_CLAIMREC","ArrayOfclaimRequestReplyClaimRec",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSSaveClaimRec := MIL_ScaniaClaw_ArrayOfclaimRequestReplyClaimRec():New()
		::oWSSaveClaimRec:SoapRecv(oNode1)
	EndIf
	::cinterfaceVersion  :=  WSAdvValue( oResponse,"_INTERFACEVERSION","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfclaimRequestClaimRec

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRec
	WSDATA   oWSSaveClaimRequestClaimRec   AS MIL_ScaniaClaw_claimRequestClaimRec OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRec
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRec
	::oWSSaveClaimRequestClaimRec := {} // Array Of  MIL_ScaniaClaw_CLAIMREQUESTCLAIMREC():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRec
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimRequestClaimRec():NEW()
	oClone:oWSSaveClaimRequestClaimRec := NIL
	If ::oWSSaveClaimRequestClaimRec <> NIL 
		oClone:oWSSaveClaimRequestClaimRec := {}
		aEval( ::oWSSaveClaimRequestClaimRec , { |x| aadd( oClone:oWSSaveClaimRequestClaimRec , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRec
	Local cSoap := ""
	aEval( ::oWSSaveClaimRequestClaimRec , {|x| cSoap := cSoap  +  WSSoapValue("claimRequestClaimRec", x , x , "claimRequestClaimRec", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfclaimRequestReplyClaimRec

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimRequestReplyClaimRec
	WSDATA   oWSSaveClaimRequestReplyClaimRec AS MIL_ScaniaClaw_claimRequestReplyClaimRec OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestReplyClaimRec
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestReplyClaimRec
	::oWSSaveClaimRequestReplyClaimRec := {} // Array Of  MIL_ScaniaClaw_CLAIMREQUESTREPLYCLAIMREC():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestReplyClaimRec
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimRequestReplyClaimRec():NEW()
	oClone:oWSSaveClaimRequestReplyClaimRec := NIL
	If ::oWSSaveClaimRequestReplyClaimRec <> NIL 
		oClone:oWSSaveClaimRequestReplyClaimRec := {}
		aEval( ::oWSSaveClaimRequestReplyClaimRec , { |x| aadd( oClone:oWSSaveClaimRequestReplyClaimRec , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestReplyClaimRec
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLAIMREQUESTREPLYCLAIMREC","claimRequestReplyClaimRec",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSaveClaimRequestReplyClaimRec , MIL_ScaniaClaw_claimRequestReplyClaimRec():New() )
			::oWSSaveClaimRequestReplyClaimRec[len(::oWSSaveClaimRequestReplyClaimRec)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure claimRequestClaimRec

WSSTRUCT MIL_ScaniaClaw_claimRequestClaimRec
	WSDATA   cassortmentCode           AS string OPTIONAL
	WSDATA   cbookDate                 AS dateTime OPTIONAL
	WSDATA   lbookDateSpecified        AS boolean OPTIONAL
	WSDATA   ccampNo                   AS string OPTIONAL
	WSDATA   cchassiNo                 AS string OPTIONAL
	WSDATA   cclaimType                AS string OPTIONAL
	WSDATA   oWSclawValues             AS MIL_ScaniaClaw_claimRequestClaimRecClawValues OPTIONAL
	WSDATA   ccomplMgCode              AS string OPTIONAL
	WSDATA   ccomplainDate             AS dateTime OPTIONAL
	WSDATA   lcomplainDateSpecified    AS boolean OPTIONAL
	WSDATA   ccontractWorkshop         AS string OPTIONAL
	WSDATA   oWScostL                  AS MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostL OPTIONAL
	WSDATA   oWScostP                  AS MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostP OPTIONAL
	WSDATA   oWScostS                  AS MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostS OPTIONAL
	WSDATA   oWScostU                  AS MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostU OPTIONAL
	WSDATA   oWScostX01                AS MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostX01 OPTIONAL
	WSDATA   ncustAmt                  AS decimal OPTIONAL
	WSDATA   lcustAmtSpecified         AS boolean OPTIONAL
	WSDATA   ccustNo                   AS string OPTIONAL
	WSDATA   ccustText                 AS string OPTIONAL
	WSDATA   cdamagePartNo             AS string OPTIONAL
	WSDATA   cdelCode                  AS string OPTIONAL
	WSDATA   cdemFactorL               AS string OPTIONAL
	WSDATA   cdemFactorP               AS string OPTIONAL
	WSDATA   cdemFactorS               AS string OPTIONAL
	WSDATA   cdemFactorU               AS string OPTIONAL
	WSDATA   cdemType                  AS string OPTIONAL
	WSDATA   cdistrNationCode          AS string OPTIONAL
	WSDATA   cdistrNo                  AS string OPTIONAL
	WSDATA   celapsedTime              AS string OPTIONAL
	WSDATA   cepsName                  AS string OPTIONAL
	WSDATA   cfailRepNo                AS string OPTIONAL
	WSDATA   cfailureCode              AS string OPTIONAL
	WSDATA   cfieldTestNo              AS string OPTIONAL
	WSDATA   cforVehicle               AS string OPTIONAL
	WSDATA   cjobNo                    AS string OPTIONAL
	WSDATA   clocalClaimCode           AS string OPTIONAL
	WSDATA   clocationCode             AS string OPTIONAL
	WSDATA   cmaingroup                AS string OPTIONAL
	WSDATA   cmaintCode                AS string OPTIONAL
	WSDATA   cmanufCode                AS string OPTIONAL
	WSDATA   cmechanic                 AS string OPTIONAL
	WSDATA   cmileage                  AS string OPTIONAL
	WSDATA   cmountDate                AS dateTime OPTIONAL
	WSDATA   lmountDateSpecified       AS boolean OPTIONAL
	WSDATA   cmountMileage             AS string OPTIONAL
	WSDATA   cnationCode               AS string OPTIONAL
	WSDATA   copenDate                 AS dateTime OPTIONAL
	WSDATA   lopenDateSpecified        AS boolean OPTIONAL
	WSDATA   cpriceList                AS string OPTIONAL
	WSDATA   cprodType                 AS string OPTIONAL
	WSDATA   creceptionist             AS string OPTIONAL
	WSDATA   crefClaimNo               AS string OPTIONAL
	WSDATA   crefNo                    AS string OPTIONAL
	WSDATA   crefText                  AS string OPTIONAL
	WSDATA   crepDate                  AS dateTime OPTIONAL
	WSDATA   crepairCode               AS string OPTIONAL
	WSDATA   csourceCode               AS string OPTIONAL
	WSDATA   csubgroup                 AS string OPTIONAL
	WSDATA   csymptomCode              AS string OPTIONAL
	WSDATA   oWStimeStamp              AS MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecTimeStamp OPTIONAL
	WSDATA   ctimeStampCode            AS string OPTIONAL
	WSDATA   cuserConf                 AS string OPTIONAL
	WSDATA   cverCode                  AS string OPTIONAL
	WSDATA   cworkOrdNo                AS string OPTIONAL
	WSDATA   cworkshopText             AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimRequestClaimRec
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimRequestClaimRec
	::oWSclawValues := MIL_ScaniaClaw_claimRequestClaimRecClawValues():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimRequestClaimRec
	Local oClone := MIL_ScaniaClaw_claimRequestClaimRec():NEW()
	oClone:cassortmentCode      := ::cassortmentCode
	oClone:cbookDate            := ::cbookDate
	oClone:lbookDateSpecified   := ::lbookDateSpecified
	oClone:ccampNo              := ::ccampNo
	oClone:cchassiNo            := ::cchassiNo
	oClone:cclaimType           := ::cclaimType
	oClone:oWSclawValues        := IIF(::oWSclawValues = NIL , NIL , ::oWSclawValues:Clone() )
	oClone:ccomplMgCode         := ::ccomplMgCode
	oClone:ccomplainDate        := ::ccomplainDate
	oClone:lcomplainDateSpecified := ::lcomplainDateSpecified
	oClone:ccontractWorkshop    := ::ccontractWorkshop
	oClone:oWScostL             := IIF(::oWScostL = NIL , NIL , ::oWScostL:Clone() )
	oClone:oWScostP             := IIF(::oWScostP = NIL , NIL , ::oWScostP:Clone() )
	oClone:oWScostS             := IIF(::oWScostS = NIL , NIL , ::oWScostS:Clone() )
	oClone:oWScostU             := IIF(::oWScostU = NIL , NIL , ::oWScostU:Clone() )
	oClone:oWScostX01           := IIF(::oWScostX01 = NIL , NIL , ::oWScostX01:Clone() )
	oClone:ncustAmt             := ::ncustAmt
	oClone:lcustAmtSpecified    := ::lcustAmtSpecified
	oClone:ccustNo              := ::ccustNo
	oClone:ccustText            := ::ccustText
	oClone:cdamagePartNo        := ::cdamagePartNo
	oClone:cdelCode             := ::cdelCode
	oClone:cdemFactorL          := ::cdemFactorL
	oClone:cdemFactorP          := ::cdemFactorP
	oClone:cdemFactorS          := ::cdemFactorS
	oClone:cdemFactorU          := ::cdemFactorU
	oClone:cdemType             := ::cdemType
	oClone:cdistrNationCode     := ::cdistrNationCode
	oClone:cdistrNo             := ::cdistrNo
	oClone:celapsedTime         := ::celapsedTime
	oClone:cepsName             := ::cepsName
	oClone:cfailRepNo           := ::cfailRepNo
	oClone:cfailureCode         := ::cfailureCode
	oClone:cfieldTestNo         := ::cfieldTestNo
	oClone:cforVehicle          := ::cforVehicle
	oClone:cjobNo               := ::cjobNo
	oClone:clocalClaimCode      := ::clocalClaimCode
	oClone:clocationCode        := ::clocationCode
	oClone:cmaingroup           := ::cmaingroup
	oClone:cmaintCode           := ::cmaintCode
	oClone:cmanufCode           := ::cmanufCode
	oClone:cmechanic            := ::cmechanic
	oClone:cmileage             := ::cmileage
	oClone:cmountDate           := ::cmountDate
	oClone:lmountDateSpecified  := ::lmountDateSpecified
	oClone:cmountMileage        := ::cmountMileage
	oClone:cnationCode          := ::cnationCode
	oClone:copenDate            := ::copenDate
	oClone:lopenDateSpecified   := ::lopenDateSpecified
	oClone:cpriceList           := ::cpriceList
	oClone:cprodType            := ::cprodType
	oClone:creceptionist        := ::creceptionist
	oClone:crefClaimNo          := ::crefClaimNo
	oClone:crefNo               := ::crefNo
	oClone:crefText             := ::crefText
	oClone:crepDate             := ::crepDate
	oClone:crepairCode          := ::crepairCode
	oClone:csourceCode          := ::csourceCode
	oClone:csubgroup            := ::csubgroup
	oClone:csymptomCode         := ::csymptomCode
	oClone:oWStimeStamp         := IIF(::oWStimeStamp = NIL , NIL , ::oWStimeStamp:Clone() )
	oClone:ctimeStampCode       := ::ctimeStampCode
	oClone:cuserConf            := ::cuserConf
	oClone:cverCode             := ::cverCode
	oClone:cworkOrdNo           := ::cworkOrdNo
	oClone:cworkshopText        := ::cworkshopText
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_claimRequestClaimRec
	Local cSoap := ""
	cSoap += WSSoapValue("assortmentCode", ::cassortmentCode, ::cassortmentCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("bookDate", ::cbookDate, ::cbookDate , "dateTime", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("bookDateSpecified", ::lbookDateSpecified, ::lbookDateSpecified , "boolean", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("campNo", ::ccampNo, ::ccampNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("chassiNo", ::cchassiNo, ::cchassiNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("claimType", ::cclaimType, ::cclaimType , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("clawValues", ::oWSclawValues, ::oWSclawValues , "claimRequestClaimRecClawValues", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("complMgCode", ::ccomplMgCode, ::ccomplMgCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("complainDate", ::ccomplainDate, ::ccomplainDate , "dateTime", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("complainDateSpecified", ::lcomplainDateSpecified, ::lcomplainDateSpecified , "boolean", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("contractWorkshop", ::ccontractWorkshop, ::ccontractWorkshop , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("costL", ::oWScostL, ::oWScostL , "ArrayOfclaimRequestClaimRecCostL", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("costP", ::oWScostP, ::oWScostP , "ArrayOfclaimRequestClaimRecCostP", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("costS", ::oWScostS, ::oWScostS , "ArrayOfclaimRequestClaimRecCostS", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("costU", ::oWScostU, ::oWScostU , "ArrayOfclaimRequestClaimRecCostU", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("costX01", ::oWScostX01, ::oWScostX01 , "ArrayOfclaimRequestClaimRecCostX01", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("custAmt", ::ncustAmt, ::ncustAmt , "decimal", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("custAmtSpecified", ::lcustAmtSpecified, ::lcustAmtSpecified , "boolean", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("custNo", ::ccustNo, ::ccustNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("custText", ::ccustText, ::ccustText , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("damagePartNo", ::cdamagePartNo, ::cdamagePartNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("delCode", ::cdelCode, ::cdelCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("demFactorL", ::cdemFactorL, ::cdemFactorL , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("demFactorP", ::cdemFactorP, ::cdemFactorP , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("demFactorS", ::cdemFactorS, ::cdemFactorS , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("demFactorU", ::cdemFactorU, ::cdemFactorU , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("demType", ::cdemType, ::cdemType , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("distrNationCode", ::cdistrNationCode, ::cdistrNationCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("distrNo", ::cdistrNo, ::cdistrNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("elapsedTime", ::celapsedTime, ::celapsedTime , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("epsName", ::cepsName, ::cepsName , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("failRepNo", ::cfailRepNo, ::cfailRepNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("failureCode", ::cfailureCode, ::cfailureCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("fieldTestNo", ::cfieldTestNo, ::cfieldTestNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("forVehicle", ::cforVehicle, ::cforVehicle , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("jobNo", ::cjobNo, ::cjobNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("localClaimCode", ::clocalClaimCode, ::clocalClaimCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("locationCode", ::clocationCode, ::clocationCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("maingroup", ::cmaingroup, ::cmaingroup , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("maintCode", ::cmaintCode, ::cmaintCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("manufCode", ::cmanufCode, ::cmanufCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("mechanic", ::cmechanic, ::cmechanic , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("mileage", ::cmileage, ::cmileage , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("mountDate", ::cmountDate, ::cmountDate , "dateTime", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("mountDateSpecified", ::lmountDateSpecified, ::lmountDateSpecified , "boolean", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("mountMileage", ::cmountMileage, ::cmountMileage , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("nationCode", ::cnationCode, ::cnationCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("openDate", ::copenDate, ::copenDate , "dateTime", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("openDateSpecified", ::lopenDateSpecified, ::lopenDateSpecified , "boolean", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("priceList", ::cpriceList, ::cpriceList , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("prodType", ::cprodType, ::cprodType , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("receptionist", ::creceptionist, ::creceptionist , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("refClaimNo", ::crefClaimNo, ::crefClaimNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("refNo", ::crefNo, ::crefNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("refText", ::crefText, ::crefText , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("repDate", ::crepDate, ::crepDate , "dateTime", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("repairCode", ::crepairCode, ::crepairCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("sourceCode", ::csourceCode, ::csourceCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("subgroup", ::csubgroup, ::csubgroup , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("symptomCode", ::csymptomCode, ::csymptomCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("timeStamp", ::oWStimeStamp, ::oWStimeStamp , "ArrayOfclaimRequestClaimRecTimeStamp", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("timeStampCode", ::ctimeStampCode, ::ctimeStampCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("userConf", ::cuserConf, ::cuserConf , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("verCode", ::cverCode, ::cverCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("workOrdNo", ::cworkOrdNo, ::cworkOrdNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("workshopText", ::cworkshopText, ::cworkshopText , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
Return cSoap

// WSDL Data Structure claimRequestReplyClaimRec

WSSTRUCT MIL_ScaniaClaw_claimRequestReplyClaimRec
	WSDATA   cchassiNo                 AS string OPTIONAL
	WSDATA   oWSclawValues             AS MIL_ScaniaClaw_claimRequestReplyClaimRecClawValues OPTIONAL
	WSDATA   ccustNo                   AS string OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSDATA   cjobNo                    AS string OPTIONAL
	WSDATA   cresultCode               AS string OPTIONAL
	WSDATA   cworkOrdNo                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimRequestReplyClaimRec
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimRequestReplyClaimRec
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimRequestReplyClaimRec
	Local oClone := MIL_ScaniaClaw_claimRequestReplyClaimRec():NEW()
	oClone:cchassiNo            := ::cchassiNo
	oClone:oWSclawValues        := IIF(::oWSclawValues = NIL , NIL , ::oWSclawValues:Clone() )
	oClone:ccustNo              := ::ccustNo
	oClone:cdescription         := ::cdescription
	oClone:cjobNo               := ::cjobNo
	oClone:cresultCode          := ::cresultCode
	oClone:cworkOrdNo           := ::cworkOrdNo
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimRequestReplyClaimRec
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cchassiNo          :=  WSAdvValue( oResponse,"_CHASSINO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_CLAWVALUES","claimRequestReplyClaimRecClawValues",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSclawValues := MIL_ScaniaClaw_claimRequestReplyClaimRecClawValues():New()
		::oWSclawValues:SoapRecv(oNode2)
	EndIf
	::ccustNo            :=  WSAdvValue( oResponse,"_CUSTNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cjobNo             :=  WSAdvValue( oResponse,"_JOBNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cresultCode        :=  WSAdvValue( oResponse,"_RESULTCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cworkOrdNo         :=  WSAdvValue( oResponse,"_WORKORDNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure claimRequestClaimRecClawValues

WSSTRUCT MIL_ScaniaClaw_claimRequestClaimRecClawValues
	WSDATA   ccampType                 AS string OPTIONAL
	WSDATA   cdmsRefNo                 AS string OPTIONAL
	WSDATA   cpassword                 AS string OPTIONAL
	WSDATA   cstartClaiming            AS string OPTIONAL
	WSDATA   cusername                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecClawValues
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecClawValues
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecClawValues
	Local oClone := MIL_ScaniaClaw_claimRequestClaimRecClawValues():NEW()
	oClone:ccampType            := ::ccampType
	oClone:cdmsRefNo            := ::cdmsRefNo
	oClone:cpassword            := ::cpassword
	oClone:cstartClaiming       := ::cstartClaiming
	oClone:cusername            := ::cusername
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecClawValues
	Local cSoap := ""
	cSoap += WSSoapValue("campType", ::ccampType, ::ccampType , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("dmsRefNo", ::cdmsRefNo, ::cdmsRefNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("password", ::cpassword, ::cpassword , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("startClaiming", ::cstartClaiming, ::cstartClaiming , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("username", ::cusername, ::cusername , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
Return cSoap

// WSDL Data Structure ArrayOfclaimRequestClaimRecCostL

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostL
	WSDATA   oWSSaveClaimRequestClaimRecCostL AS MIL_ScaniaClaw_claimRequestClaimRecCostL OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostL
	::oWSSaveClaimRequestClaimRecCostL := {} // Array Of  MIL_ScaniaClaw_CLAIMREQUESTCLAIMRECCOSTL():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostL
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostL():NEW()
	oClone:oWSSaveClaimRequestClaimRecCostL := NIL
	If ::oWSSaveClaimRequestClaimRecCostL <> NIL 
		oClone:oWSSaveClaimRequestClaimRecCostL := {}
		aEval( ::oWSSaveClaimRequestClaimRecCostL , { |x| aadd( oClone:oWSSaveClaimRequestClaimRecCostL , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostL
	Local cSoap := ""
	aEval( ::oWSSaveClaimRequestClaimRecCostL , {|x| cSoap := cSoap  +  WSSoapValue("claimRequestClaimRecCostL", x , x , "claimRequestClaimRecCostL", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfclaimRequestClaimRecCostP

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostP
	WSDATA   oWSSaveClaimRequestClaimRecCostP AS MIL_ScaniaClaw_claimRequestClaimRecCostP OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostP
	::oWSSaveClaimRequestClaimRecCostP := {} // Array Of  MIL_ScaniaClaw_CLAIMREQUESTCLAIMRECCOSTP():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostP
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostP():NEW()
	oClone:oWSSaveClaimRequestClaimRecCostP := NIL
	If ::oWSSaveClaimRequestClaimRecCostP <> NIL 
		oClone:oWSSaveClaimRequestClaimRecCostP := {}
		aEval( ::oWSSaveClaimRequestClaimRecCostP , { |x| aadd( oClone:oWSSaveClaimRequestClaimRecCostP , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostP
	Local cSoap := ""
	aEval( ::oWSSaveClaimRequestClaimRecCostP , {|x| cSoap := cSoap  +  WSSoapValue("claimRequestClaimRecCostP", x , x , "claimRequestClaimRecCostP", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfclaimRequestClaimRecCostS

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostS
	WSDATA   oWSSaveClaimRequestClaimRecCostS AS MIL_ScaniaClaw_claimRequestClaimRecCostS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostS
	::oWSSaveClaimRequestClaimRecCostS := {} // Array Of  MIL_ScaniaClaw_CLAIMREQUESTCLAIMRECCOSTS():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostS
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostS():NEW()
	oClone:oWSSaveClaimRequestClaimRecCostS := NIL
	If ::oWSSaveClaimRequestClaimRecCostS <> NIL 
		oClone:oWSSaveClaimRequestClaimRecCostS := {}
		aEval( ::oWSSaveClaimRequestClaimRecCostS , { |x| aadd( oClone:oWSSaveClaimRequestClaimRecCostS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostS
	Local cSoap := ""
	aEval( ::oWSSaveClaimRequestClaimRecCostS , {|x| cSoap := cSoap  +  WSSoapValue("claimRequestClaimRecCostS", x , x , "claimRequestClaimRecCostS", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfclaimRequestClaimRecCostU

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostU
	WSDATA   oWSSaveClaimRequestClaimRecCostU AS MIL_ScaniaClaw_claimRequestClaimRecCostU OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostU
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostU
	::oWSSaveClaimRequestClaimRecCostU := {} // Array Of  MIL_ScaniaClaw_CLAIMREQUESTCLAIMRECCOSTU():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostU
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostU():NEW()
	oClone:oWSSaveClaimRequestClaimRecCostU := NIL
	If ::oWSSaveClaimRequestClaimRecCostU <> NIL 
		oClone:oWSSaveClaimRequestClaimRecCostU := {}
		aEval( ::oWSSaveClaimRequestClaimRecCostU , { |x| aadd( oClone:oWSSaveClaimRequestClaimRecCostU , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostU
	Local cSoap := ""
	aEval( ::oWSSaveClaimRequestClaimRecCostU , {|x| cSoap := cSoap  +  WSSoapValue("claimRequestClaimRecCostU", x , x , "claimRequestClaimRecCostU", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfclaimRequestClaimRecCostX01

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostX01
	WSDATA   oWSSaveClaimRequestClaimRecCostX01 AS MIL_ScaniaClaw_claimRequestClaimRecCostX01 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostX01
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostX01
	::oWSSaveClaimRequestClaimRecCostX01 := {} // Array Of  MIL_ScaniaClaw_CLAIMREQUESTCLAIMRECCOSTX01():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostX01
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostX01():NEW()
	oClone:oWSSaveClaimRequestClaimRecCostX01 := NIL
	If ::oWSSaveClaimRequestClaimRecCostX01 <> NIL 
		oClone:oWSSaveClaimRequestClaimRecCostX01 := {}
		aEval( ::oWSSaveClaimRequestClaimRecCostX01 , { |x| aadd( oClone:oWSSaveClaimRequestClaimRecCostX01 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostX01
	Local cSoap := ""
	aEval( ::oWSSaveClaimRequestClaimRecCostX01 , {|x| cSoap := cSoap  +  WSSoapValue("claimRequestClaimRecCostX01", x , x , "claimRequestClaimRecCostX01", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfclaimRequestClaimRecTimeStamp

WSSTRUCT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecTimeStamp
	WSDATA   oWSSaveClaimRequestClaimRecTimeStamp AS MIL_ScaniaClaw_claimRequestClaimRecTimeStamp OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecTimeStamp
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecTimeStamp
	::oWSSaveClaimRequestClaimRecTimeStamp := {} // Array Of  MIL_ScaniaClaw_CLAIMREQUESTCLAIMRECTIMESTAMP():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecTimeStamp
	Local oClone := MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecTimeStamp():NEW()
	oClone:oWSSaveClaimRequestClaimRecTimeStamp := NIL
	If ::oWSSaveClaimRequestClaimRecTimeStamp <> NIL 
		oClone:oWSSaveClaimRequestClaimRecTimeStamp := {}
		aEval( ::oWSSaveClaimRequestClaimRecTimeStamp , { |x| aadd( oClone:oWSSaveClaimRequestClaimRecTimeStamp , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecTimeStamp
	Local cSoap := ""
	aEval( ::oWSSaveClaimRequestClaimRecTimeStamp , {|x| cSoap := cSoap  +  WSSoapValue("claimRequestClaimRecTimeStamp", x , x , "claimRequestClaimRecTimeStamp", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.)  } ) 
Return cSoap

// WSDL Data Structure claimRequestReplyClaimRecClawValues

WSSTRUCT MIL_ScaniaClaw_claimRequestReplyClaimRecClawValues
	WSDATA   cSSOToken                 AS string OPTIONAL
	WSDATA   cdmsRefNo                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimRequestReplyClaimRecClawValues
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimRequestReplyClaimRecClawValues
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimRequestReplyClaimRecClawValues
	Local oClone := MIL_ScaniaClaw_claimRequestReplyClaimRecClawValues():NEW()
	oClone:cSSOToken            := ::cSSOToken
	oClone:cdmsRefNo            := ::cdmsRefNo
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaClaw_claimRequestReplyClaimRecClawValues
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSSOToken          :=  WSAdvValue( oResponse,"_SSOTOKEN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdmsRefNo          :=  WSAdvValue( oResponse,"_DMSREFNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure claimRequestClaimRecCostL

WSSTRUCT MIL_ScaniaClaw_claimRequestClaimRecCostL
	WSDATA   cextRowId                 AS string OPTIONAL
	WSDATA   copCode                   AS string OPTIONAL
	WSDATA   cqty                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostL
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostL
	Local oClone := MIL_ScaniaClaw_claimRequestClaimRecCostL():NEW()
	oClone:cextRowId            := ::cextRowId
	oClone:copCode              := ::copCode
	oClone:cqty                 := ::cqty
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostL
	Local cSoap := ""
	cSoap += WSSoapValue("extRowId", ::cextRowId, ::cextRowId , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("opCode", ::copCode, ::copCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("qty", ::cqty, ::cqty , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
Return cSoap

// WSDL Data Structure claimRequestClaimRecCostP

WSSTRUCT MIL_ScaniaClaw_claimRequestClaimRecCostP
	WSDATA   cassortmentCode           AS string OPTIONAL
	WSDATA   cextRowId                 AS string OPTIONAL
	WSDATA   cpartNo                   AS string OPTIONAL
	WSDATA   cqty                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostP
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostP
	Local oClone := MIL_ScaniaClaw_claimRequestClaimRecCostP():NEW()
	oClone:cassortmentCode      := ::cassortmentCode
	oClone:cextRowId            := ::cextRowId
	oClone:cpartNo              := ::cpartNo
	oClone:cqty                 := ::cqty
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostP
	Local cSoap := ""
	cSoap += WSSoapValue("assortmentCode", ::cassortmentCode, ::cassortmentCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("extRowId", ::cextRowId, ::cextRowId , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("partNo", ::cpartNo, ::cpartNo , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("qty", ::cqty, ::cqty , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
Return cSoap

// WSDL Data Structure claimRequestClaimRecCostS

WSSTRUCT MIL_ScaniaClaw_claimRequestClaimRecCostS
	WSDATA   oWSdescr                  AS MIL_ScaniaClaw_claimRequestClaimRecCostSDescr OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSDATA   cextRowId                 AS string OPTIONAL
	WSDATA   nspCostAmt                AS decimal OPTIONAL
	WSDATA   ctypeSpecCode             AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostS
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostS
	Local oClone := MIL_ScaniaClaw_claimRequestClaimRecCostS():NEW()
	oClone:oWSdescr             := IIF(::oWSdescr = NIL , NIL , ::oWSdescr:Clone() )
	oClone:cdescription         := ::cdescription
	oClone:cextRowId            := ::cextRowId
	oClone:nspCostAmt           := ::nspCostAmt
	oClone:ctypeSpecCode        := ::ctypeSpecCode
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostS
	Local cSoap := ""
	cSoap += WSSoapValue("descr", ::oWSdescr, ::oWSdescr , "claimRequestClaimRecCostSDescr", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("description", ::cdescription, ::cdescription , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("extRowId", ::cextRowId, ::cextRowId , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("spCostAmt", ::nspCostAmt, ::nspCostAmt , "decimal", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("typeSpecCode", ::ctypeSpecCode, ::ctypeSpecCode , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
Return cSoap

// WSDL Data Structure claimRequestClaimRecCostU

WSSTRUCT MIL_ScaniaClaw_claimRequestClaimRecCostU
	WSDATA   oWSdescr                  AS MIL_ScaniaClaw_claimRequestClaimRecCostUDescr OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSDATA   cextRowId                 AS string OPTIONAL
	WSDATA   nnoOfHours                AS decimal OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostU
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostU
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostU
	Local oClone := MIL_ScaniaClaw_claimRequestClaimRecCostU():NEW()
	oClone:oWSdescr             := IIF(::oWSdescr = NIL , NIL , ::oWSdescr:Clone() )
	oClone:cdescription         := ::cdescription
	oClone:cextRowId            := ::cextRowId
	oClone:nnoOfHours           := ::nnoOfHours
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostU
	Local cSoap := ""
	cSoap += WSSoapValue("descr", ::oWSdescr, ::oWSdescr , "claimRequestClaimRecCostUDescr", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("description", ::cdescription, ::cdescription , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("extRowId", ::cextRowId, ::cextRowId , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("noOfHours", ::nnoOfHours, ::nnoOfHours , "decimal", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
Return cSoap

// WSDL Data Structure claimRequestClaimRecCostX01

WSSTRUCT MIL_ScaniaClaw_claimRequestClaimRecCostX01
	WSDATA   cdescr                    AS string OPTIONAL
	WSDATA   cextRowId                 AS string OPTIONAL
	WSDATA   ntravelDist               AS decimal OPTIONAL
	WSDATA   ntravelTime               AS decimal OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostX01
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostX01
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostX01
	Local oClone := MIL_ScaniaClaw_claimRequestClaimRecCostX01():NEW()
	oClone:cdescr               := ::cdescr
	oClone:cextRowId            := ::cextRowId
	oClone:ntravelDist          := ::ntravelDist
	oClone:ntravelTime          := ::ntravelTime
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostX01
	Local cSoap := ""
	cSoap += WSSoapValue("descr", ::cdescr, ::cdescr , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("extRowId", ::cextRowId, ::cextRowId , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("travelDist", ::ntravelDist, ::ntravelDist , "decimal", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("travelTime", ::ntravelTime, ::ntravelTime , "decimal", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
Return cSoap

// WSDL Data Structure claimRequestClaimRecTimeStamp

WSSTRUCT MIL_ScaniaClaw_claimRequestClaimRecTimeStamp
	WSDATA   cStartTime                AS string OPTIONAL
	WSDATA   cstopTime                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecTimeStamp
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecTimeStamp
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecTimeStamp
	Local oClone := MIL_ScaniaClaw_claimRequestClaimRecTimeStamp():NEW()
	oClone:cStartTime           := ::cStartTime
	oClone:cstopTime            := ::cstopTime
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecTimeStamp
	Local cSoap := ""
	cSoap += WSSoapValue("StartTime", ::cStartTime, ::cStartTime , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
	cSoap += WSSoapValue("stopTime", ::cstopTime, ::cstopTime , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
Return cSoap

// WSDL Data Structure claimRequestClaimRecCostSDescr

WSSTRUCT MIL_ScaniaClaw_claimRequestClaimRecCostSDescr
	WSDATA   ccodeId                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostSDescr
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostSDescr
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostSDescr
	Local oClone := MIL_ScaniaClaw_claimRequestClaimRecCostSDescr():NEW()
	oClone:ccodeId              := ::ccodeId
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostSDescr
	Local cSoap := ""
	cSoap += WSSoapValue("codeId", ::ccodeId, ::ccodeId , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
Return cSoap

// WSDL Data Structure claimRequestClaimRecCostUDescr

WSSTRUCT MIL_ScaniaClaw_claimRequestClaimRecCostUDescr
	WSDATA   ccodeId                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostUDescr
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostUDescr
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostUDescr
	Local oClone := MIL_ScaniaClaw_claimRequestClaimRecCostUDescr():NEW()
	oClone:ccodeId              := ::ccodeId
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaClaw_claimRequestClaimRecCostUDescr
	Local cSoap := ""
	cSoap += WSSoapValue("codeId", ::ccodeId, ::ccodeId , "string", .F. , .F., 0 , "http://www.claw.scania.com/clawapi", .F.) 
Return cSoap
