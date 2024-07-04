#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://localhost:9292/TSSWSSIGNATURE.apw?WSDL
Generado en        10/15/18 16:25:20
Observaciones      Codigo Fuente generado por ADVPL WSDL Client 1.120703
                 Modificaciones en este archivo pueden causar funcionamiento incorrecto
                 y se perderan en caso de que se genere nuevamente el codigo fuente.

=============================================================================== */

User Function _PMZUMRC ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSTSSWSSIGNATURE
------------------------------------------------------------------------------- */

WSCLIENT WSTSSWSSIGNATURE

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD CFGEMPRESA
	WSMETHOD CONSULTADOC
	WSMETHOD GETCFGEMPRESA
	WSMETHOD MONITORDOC
	WSMETHOD REMESSADOC

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cUSERTOKEN                AS string
	WSDATA   cENTIDADE                 AS string
	WSDATA   oWSCONFIGEMPRESA          AS TSSWSSIGNATURE_CONFIGEMPRESA
	WSDATA   oWSCFGEMPRESARESULT       AS TSSWSSIGNATURE_CONFIGEMPRESARESULT
	WSDATA   cMODELO                   AS string
	WSDATA   cDOCINI                   AS string
	WSDATA   cDOCFIN                   AS string
	WSDATA   oWSCONSULTADOCRESULT      AS TSSWSSIGNATURE_ARRAYOFCONSULTADOCRESULT
	WSDATA   oWSGETCFGEMPRESARESULT    AS TSSWSSIGNATURE_GETCFGEMPRESARESULT
	WSDATA   oWSMONITORSIG             AS TSSWSSIGNATURE_MONITORSIG
	WSDATA   oWSMONITORDOCRESULT       AS TSSWSSIGNATURE_MONITORSIGRESULT
	WSDATA   oWSREMESSA                AS TSSWSSIGNATURE_LOTESIG
	WSDATA   oWSREMESSADOCRESULT       AS TSSWSSIGNATURE_LOTESIGRESULT
	WSDATA   oWSLOTESIG                AS TSSWSSIGNATURE_LOTESIG

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSTSSWSSIGNATURE
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20170816 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSTSSWSSIGNATURE
	::oWSCONFIGEMPRESA   := TSSWSSIGNATURE_CONFIGEMPRESA():New()
	::oWSCFGEMPRESARESULT := TSSWSSIGNATURE_CONFIGEMPRESARESULT():New()
	::oWSCONSULTADOCRESULT := TSSWSSIGNATURE_ARRAYOFCONSULTADOCRESULT():New()
	::oWSGETCFGEMPRESARESULT := TSSWSSIGNATURE_GETCFGEMPRESARESULT():New()
	::oWSMONITORSIG      := TSSWSSIGNATURE_MONITORSIG():New()
	::oWSMONITORDOCRESULT := TSSWSSIGNATURE_MONITORSIGRESULT():New()
	::oWSREMESSA         := TSSWSSIGNATURE_LOTESIG():New()
	::oWSREMESSADOCRESULT := TSSWSSIGNATURE_LOTESIGRESULT():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSCONFIGEMPRESA   := ::oWSCONFIGEMPRESA
	::oWSMONITORSIG      := ::oWSMONITORSIG
	::oWSLOTESIG         := ::oWSREMESSA
Return

WSMETHOD RESET WSCLIENT WSTSSWSSIGNATURE
	::cUSERTOKEN         := NIL 
	::cENTIDADE          := NIL 
	::oWSCONFIGEMPRESA   := NIL 
	::oWSCFGEMPRESARESULT := NIL 
	::cMODELO            := NIL 
	::cDOCINI            := NIL 
	::cDOCFIN            := NIL 
	::oWSCONSULTADOCRESULT := NIL 
	::oWSGETCFGEMPRESARESULT := NIL 
	::oWSMONITORSIG      := NIL 
	::oWSMONITORDOCRESULT := NIL 
	::oWSREMESSA         := NIL 
	::oWSREMESSADOCRESULT := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSCONFIGEMPRESA   := NIL
	::oWSMONITORSIG      := NIL
	::oWSLOTESIG         := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSTSSWSSIGNATURE
Local oClone := WSTSSWSSIGNATURE():New()
	oClone:_URL          := ::_URL 
	oClone:cUSERTOKEN    := ::cUSERTOKEN
	oClone:cENTIDADE     := ::cENTIDADE
	oClone:oWSCONFIGEMPRESA :=  IIF(::oWSCONFIGEMPRESA = NIL , NIL ,::oWSCONFIGEMPRESA:Clone() )
	oClone:oWSCFGEMPRESARESULT :=  IIF(::oWSCFGEMPRESARESULT = NIL , NIL ,::oWSCFGEMPRESARESULT:Clone() )
	oClone:cMODELO       := ::cMODELO
	oClone:cDOCINI       := ::cDOCINI
	oClone:cDOCFIN       := ::cDOCFIN
	oClone:oWSCONSULTADOCRESULT :=  IIF(::oWSCONSULTADOCRESULT = NIL , NIL ,::oWSCONSULTADOCRESULT:Clone() )
	oClone:oWSGETCFGEMPRESARESULT :=  IIF(::oWSGETCFGEMPRESARESULT = NIL , NIL ,::oWSGETCFGEMPRESARESULT:Clone() )
	oClone:oWSMONITORSIG :=  IIF(::oWSMONITORSIG = NIL , NIL ,::oWSMONITORSIG:Clone() )
	oClone:oWSMONITORDOCRESULT :=  IIF(::oWSMONITORDOCRESULT = NIL , NIL ,::oWSMONITORDOCRESULT:Clone() )
	oClone:oWSREMESSA    :=  IIF(::oWSREMESSA = NIL , NIL ,::oWSREMESSA:Clone() )
	oClone:oWSREMESSADOCRESULT :=  IIF(::oWSREMESSADOCRESULT = NIL , NIL ,::oWSREMESSADOCRESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSCONFIGEMPRESA := oClone:oWSCONFIGEMPRESA
	oClone:oWSMONITORSIG := oClone:oWSMONITORSIG
	oClone:oWSLOTESIG    := oClone:oWSREMESSA
Return oClone

// WSDL Method CFGEMPRESA of Service WSTSSWSSIGNATURE

WSMETHOD CFGEMPRESA WSSEND cUSERTOKEN,cENTIDADE,oWSCONFIGEMPRESA WSRECEIVE oWSCFGEMPRESARESULT WSCLIENT WSTSSWSSIGNATURE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CFGEMPRESA xmlns="http://webservices.totvs.com.br">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.,.F.) 
cSoap += WSSoapValue("ENTIDADE", ::cENTIDADE, cENTIDADE , "string", .T. , .F., 0 , NIL, .F.,.F.,.F.) 
cSoap += WSSoapValue("CONFIGEMPRESA", ::oWSCONFIGEMPRESA, oWSCONFIGEMPRESA , "CONFIGEMPRESA", .T. , .F., 0 , NIL, .F.,.F.,.F.) 
cSoap += "</CFGEMPRESA>"

oXmlRet := SvcSoapCall(ObjSelf(Self),cSoap,;  
	"http://webservices.totvs.com.br/CFGEMPRESA",; 
	"DOCUMENT","http://webservices.totvs.com.br",,"1.031217",; 
	"http://localhost:9292/TSSWSSIGNATURE.apw")

::Init()
::oWSCFGEMPRESARESULT:SoapRecv( WSAdvValue( oXmlRet,"_CFGEMPRESARESPONSE:_CFGEMPRESARESULT","CONFIGEMPRESARESULT",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CONSULTADOC of Service WSTSSWSSIGNATURE

WSMETHOD CONSULTADOC WSSEND cUSERTOKEN,cENTIDADE,cMODELO,cDOCINI,cDOCFIN WSRECEIVE oWSCONSULTADOCRESULT WSCLIENT WSTSSWSSIGNATURE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONSULTADOC xmlns="http://webservices.totvs.com.br">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ENTIDADE", ::cENTIDADE, cENTIDADE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MODELO", ::cMODELO, cMODELO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DOCINI", ::cDOCINI, cDOCINI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DOCFIN", ::cDOCFIN, cDOCFIN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CONSULTADOC>"

oXmlRet := SvcSoapCall(ObjSelf(Self),cSoap,;  
	"http://webservices.totvs.com.br/CONSULTADOC",; 
	"DOCUMENT","http://webservices.totvs.com.br",,"1.031217",; 
	"http://localhost:9292/TSSWSSIGNATURE.apw")

::Init()
::oWSCONSULTADOCRESULT:SoapRecv( WSAdvValue( oXmlRet,"_CONSULTADOCRESPONSE:_CONSULTADOCRESULT","ARRAYOFCONSULTADOCRESULT",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETCFGEMPRESA of Service WSTSSWSSIGNATURE

WSMETHOD GETCFGEMPRESA WSSEND cUSERTOKEN,cENTIDADE WSRECEIVE oWSGETCFGEMPRESARESULT WSCLIENT WSTSSWSSIGNATURE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETCFGEMPRESA xmlns="http://webservices.totvs.com.br">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ENTIDADE", ::cENTIDADE, cENTIDADE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETCFGEMPRESA>"

oXmlRet := SvcSoapCall(ObjSelf(Self),cSoap,;  
	"http://webservices.totvs.com.br/GETCFGEMPRESA",; 
	"DOCUMENT","http://webservices.totvs.com.br",,"1.031217",; 
	"http://localhost:9292/TSSWSSIGNATURE.apw")

::Init()
::oWSGETCFGEMPRESARESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETCFGEMPRESARESPONSE:_GETCFGEMPRESARESULT","GETCFGEMPRESARESULT",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method MONITORDOC of Service WSTSSWSSIGNATURE

WSMETHOD MONITORDOC WSSEND cUSERTOKEN,cENTIDADE,cMODELO,oWSMONITORSIG WSRECEIVE oWSMONITORDOCRESULT WSCLIENT WSTSSWSSIGNATURE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<MONITORDOC xmlns="http://webservices.totvs.com.br">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ENTIDADE", ::cENTIDADE, cENTIDADE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MODELO", ::cMODELO, cMODELO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MONITORSIG", ::oWSMONITORSIG, oWSMONITORSIG , "MONITORSIG", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</MONITORDOC>"

oXmlRet := SvcSoapCall(ObjSelf(Self),cSoap,;  
	"http://webservices.totvs.com.br/MONITORDOC",; 
	"DOCUMENT","http://webservices.totvs.com.br",,"1.031217",; 
	"http://localhost:9292/TSSWSSIGNATURE.apw")

::Init()
::oWSMONITORDOCRESULT:SoapRecv( WSAdvValue( oXmlRet,"_MONITORDOCRESPONSE:_MONITORDOCRESULT","MONITORSIGRESULT",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method REMESSADOC of Service WSTSSWSSIGNATURE

WSMETHOD REMESSADOC WSSEND cUSERTOKEN,cENTIDADE,oWSREMESSA WSRECEIVE oWSREMESSADOCRESULT WSCLIENT WSTSSWSSIGNATURE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<REMESSADOC xmlns="http://webservices.totvs.com.br">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ENTIDADE", ::cENTIDADE, cENTIDADE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("REMESSA", ::oWSREMESSA, oWSREMESSA , "LOTESIG", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</REMESSADOC>"

oXmlRet := SvcSoapCall(ObjSelf(Self),cSoap,;  
	"http://webservices.totvs.com.br/REMESSADOC",; 
	"DOCUMENT","http://webservices.totvs.com.br",,"1.031217",; 
	"http://localhost:9292/TSSWSSIGNATURE.apw")

::Init()
::oWSREMESSADOCRESULT:SoapRecv( WSAdvValue( oXmlRet,"_REMESSADOCRESPONSE:_REMESSADOCRESULT","LOTESIGRESULT",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure CONFIGEMPRESARESULT

WSSTRUCT TSSWSSIGNATURE_CONFIGEMPRESARESULT
	WSDATA   oWSERRO                   AS TSSWSSIGNATURE_ERRO OPTIONAL
	WSDATA   cMENSAGEM                 AS string
	WSDATA   lRESULT                   AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSIGNATURE_CONFIGEMPRESARESULT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSIGNATURE_CONFIGEMPRESARESULT
Return

WSMETHOD CLONE WSCLIENT TSSWSSIGNATURE_CONFIGEMPRESARESULT
	Local oClone := TSSWSSIGNATURE_CONFIGEMPRESARESULT():NEW()
	oClone:oWSERRO              := IIF(::oWSERRO = NIL , NIL , ::oWSERRO:Clone() )
	oClone:cMENSAGEM            := ::cMENSAGEM
	oClone:lRESULT              := ::lRESULT
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSSIGNATURE_CONFIGEMPRESARESULT
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ERRO","ERRO",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSERRO := TSSWSSIGNATURE_ERRO():New()
		::oWSERRO:SoapRecv(oNode1)
	EndIf
	::cMENSAGEM          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,"Property cMENSAGEM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lRESULT            :=  WSAdvValue( oResponse,"_RESULT","boolean",NIL,"Property lRESULT as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFCONSULTADOCRESULT

WSSTRUCT TSSWSSIGNATURE_ARRAYOFCONSULTADOCRESULT
	WSDATA   oWSCONSULTADOCRESULT      AS TSSWSSIGNATURE_CONSULTADOCRESULT OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSIGNATURE_ARRAYOFCONSULTADOCRESULT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSIGNATURE_ARRAYOFCONSULTADOCRESULT
	::oWSCONSULTADOCRESULT := {} // Array Of  TSSWSSIGNATURE_CONSULTADOCRESULT():New()
Return

WSMETHOD CLONE WSCLIENT TSSWSSIGNATURE_ARRAYOFCONSULTADOCRESULT
	Local oClone := TSSWSSIGNATURE_ARRAYOFCONSULTADOCRESULT():NEW()
	oClone:oWSCONSULTADOCRESULT := NIL
	If ::oWSCONSULTADOCRESULT <> NIL 
		oClone:oWSCONSULTADOCRESULT := {}
		aEval( ::oWSCONSULTADOCRESULT , { |x| aadd( oClone:oWSCONSULTADOCRESULT , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSSIGNATURE_ARRAYOFCONSULTADOCRESULT
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CONSULTADOCRESULT","CONSULTADOCRESULT",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSCONSULTADOCRESULT , TSSWSSIGNATURE_CONSULTADOCRESULT():New() )
			::oWSCONSULTADOCRESULT[len(::oWSCONSULTADOCRESULT)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure GETCFGEMPRESARESULT

WSSTRUCT TSSWSSIGNATURE_GETCFGEMPRESARESULT
	WSDATA   oWSCONFIGEMPRESA          AS TSSWSSIGNATURE_CONFIGEMPRESA
	WSDATA   dDATACONFIG               AS date
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSIGNATURE_GETCFGEMPRESARESULT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSIGNATURE_GETCFGEMPRESARESULT
Return

WSMETHOD CLONE WSCLIENT TSSWSSIGNATURE_GETCFGEMPRESARESULT
	Local oClone := TSSWSSIGNATURE_GETCFGEMPRESARESULT():NEW()
	oClone:oWSCONFIGEMPRESA     := IIF(::oWSCONFIGEMPRESA = NIL , NIL , ::oWSCONFIGEMPRESA:Clone() )
	oClone:dDATACONFIG          := ::dDATACONFIG
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSSIGNATURE_GETCFGEMPRESARESULT
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_CONFIGEMPRESA","CONFIGEMPRESA",NIL,"Property oWSCONFIGEMPRESA as s0:CONFIGEMPRESA on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSCONFIGEMPRESA := TSSWSSIGNATURE_CONFIGEMPRESA():New()
		::oWSCONFIGEMPRESA:SoapRecv(oNode1)
	EndIf
	::dDATACONFIG        :=  WSAdvValue( oResponse,"_DATACONFIG","date",NIL,"Property dDATACONFIG as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
Return

// WSDL Data Structure MONITORSIG

WSSTRUCT TSSWSSIGNATURE_MONITORSIG
	WSDATA   cIDFINAL                  AS string
	WSDATA   cIDINICIAL                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSIGNATURE_MONITORSIG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSIGNATURE_MONITORSIG
Return

WSMETHOD CLONE WSCLIENT TSSWSSIGNATURE_MONITORSIG
	Local oClone := TSSWSSIGNATURE_MONITORSIG():NEW()
	oClone:cIDFINAL             := ::cIDFINAL
	oClone:cIDINICIAL           := ::cIDINICIAL
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSWSSIGNATURE_MONITORSIG
	Local cSoap := ""
	cSoap += WSSoapValue("IDFINAL", ::cIDFINAL, ::cIDFINAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IDINICIAL", ::cIDINICIAL, ::cIDINICIAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure MONITORSIGRESULT

WSSTRUCT TSSWSSIGNATURE_MONITORSIGRESULT
	WSDATA   oWSMONITORSIGRESULT       AS TSSWSSIGNATURE_ARRAYOFDOCSIGRET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSIGNATURE_MONITORSIGRESULT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSIGNATURE_MONITORSIGRESULT
Return

WSMETHOD CLONE WSCLIENT TSSWSSIGNATURE_MONITORSIGRESULT
	Local oClone := TSSWSSIGNATURE_MONITORSIGRESULT():NEW()
	oClone:oWSMONITORSIGRESULT  := IIF(::oWSMONITORSIGRESULT = NIL , NIL , ::oWSMONITORSIGRESULT:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSSIGNATURE_MONITORSIGRESULT
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_MONITORSIGRESULT","ARRAYOFDOCSIGRET",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSMONITORSIGRESULT := TSSWSSIGNATURE_ARRAYOFDOCSIGRET():New()
		::oWSMONITORSIGRESULT:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure LOTESIG

WSSTRUCT TSSWSSIGNATURE_LOTESIG
	WSDATA   oWSLOTESIG                AS TSSWSSIGNATURE_ARRAYOFDOCSIG
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSIGNATURE_LOTESIG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSIGNATURE_LOTESIG
Return

WSMETHOD CLONE WSCLIENT TSSWSSIGNATURE_LOTESIG
	Local oClone := TSSWSSIGNATURE_LOTESIG():NEW()
	oClone:oWSLOTESIG           := IIF(::oWSLOTESIG = NIL , NIL , ::oWSLOTESIG:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSWSSIGNATURE_LOTESIG
	Local cSoap := ""
	cSoap += WSSoapValue("LOTESIG", ::oWSLOTESIG, ::oWSLOTESIG , "ARRAYOFDOCSIG", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure LOTESIGRESULT

WSSTRUCT TSSWSSIGNATURE_LOTESIGRESULT
	WSDATA   oWSLOTESIGRESULT          AS TSSWSSIGNATURE_ARRAYOFDOCSIGRESULT
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSIGNATURE_LOTESIGRESULT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSIGNATURE_LOTESIGRESULT
Return

WSMETHOD CLONE WSCLIENT TSSWSSIGNATURE_LOTESIGRESULT
	Local oClone := TSSWSSIGNATURE_LOTESIGRESULT():NEW()
	oClone:oWSLOTESIGRESULT     := IIF(::oWSLOTESIGRESULT = NIL , NIL , ::oWSLOTESIGRESULT:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSSIGNATURE_LOTESIGRESULT
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_LOTESIGRESULT","ARRAYOFDOCSIGRESULT",NIL,"Property oWSLOTESIGRESULT as s0:ARRAYOFDOCSIGRESULT on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSLOTESIGRESULT := TSSWSSIGNATURE_ARRAYOFDOCSIGRESULT():New()
		::oWSLOTESIGRESULT:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ERRO

WSSTRUCT TSSWSSIGNATURE_ERRO
	WSDATA   nCODIGO                   AS integer
	WSDATA   cDESCRICAO                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSIGNATURE_ERRO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSIGNATURE_ERRO
Return

WSMETHOD CLONE WSCLIENT TSSWSSIGNATURE_ERRO
	Local oClone := TSSWSSIGNATURE_ERRO():NEW()
	oClone:nCODIGO              := ::nCODIGO
	oClone:cDESCRICAO           := ::cDESCRICAO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSSIGNATURE_ERRO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","integer",NIL,"Property nCODIGO as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure CONSULTADOCRESULT

WSSTRUCT TSSWSSIGNATURE_CONSULTADOCRESULT
	WSDATA   cIDDOC                    AS string
	WSDATA   cPDF                      AS base64Binary OPTIONAL
	WSDATA   nSTATUS                   AS integer
	WSDATA   cXML                      AS base64Binary OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSIGNATURE_CONSULTADOCRESULT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSIGNATURE_CONSULTADOCRESULT
Return

WSMETHOD CLONE WSCLIENT TSSWSSIGNATURE_CONSULTADOCRESULT
	Local oClone := TSSWSSIGNATURE_CONSULTADOCRESULT():NEW()
	oClone:cIDDOC               := ::cIDDOC
	oClone:cPDF                 := ::cPDF
	oClone:nSTATUS              := ::nSTATUS
	oClone:cXML                 := ::cXML
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSSIGNATURE_CONSULTADOCRESULT
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cIDDOC             :=  WSAdvValue( oResponse,"_IDDOC","string",NIL,"Property cIDDOC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPDF               :=  WSAdvValue( oResponse,"_PDF","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
	::nSTATUS            :=  WSAdvValue( oResponse,"_STATUS","integer",NIL,"Property nSTATUS as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cXML               :=  WSAdvValue( oResponse,"_XML","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
Return

// WSDL Data Structure CONFIGEMPRESA

WSSTRUCT TSSWSSIGNATURE_CONFIGEMPRESA
	WSDATA   cADMINEMAIL               AS string OPTIONAL
	WSDATA   cADMINPASS                AS base64Binary OPTIONAL
	WSDATA   cADMINUSER                AS string OPTIONAL
	WSDATA   cCERTIFICADO              AS base64Binary OPTIONAL
	WSDATA   lDELIVERY                 AS boolean OPTIONAL
	WSDATA   cIMGLOGO                  AS base64Binary OPTIONAL
	WSDATA   lPRINT                    AS boolean OPTIONAL
	WSDATA   cROLE                     AS string OPTIONAL
	WSDATA   cSENHA                    AS base64Binary OPTIONAL
	WSDATA   lSTORAGE                  AS boolean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSIGNATURE_CONFIGEMPRESA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSIGNATURE_CONFIGEMPRESA
Return

WSMETHOD CLONE WSCLIENT TSSWSSIGNATURE_CONFIGEMPRESA
	Local oClone := TSSWSSIGNATURE_CONFIGEMPRESA():NEW()
	oClone:cADMINEMAIL          := ::cADMINEMAIL
	oClone:cADMINPASS           := ::cADMINPASS
	oClone:cADMINUSER           := ::cADMINUSER
	oClone:cCERTIFICADO         := ::cCERTIFICADO
	oClone:lDELIVERY            := ::lDELIVERY
	oClone:cIMGLOGO             := ::cIMGLOGO
	oClone:lPRINT               := ::lPRINT
	oClone:cROLE                := ::cROLE
	oClone:cSENHA               := ::cSENHA
	oClone:lSTORAGE             := ::lSTORAGE
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSWSSIGNATURE_CONFIGEMPRESA
	Local cSoap := ""
	cSoap += WSSoapValue("ADMINEMAIL", ::cADMINEMAIL, ::cADMINEMAIL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ADMINPASS", ::cADMINPASS, ::cADMINPASS , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ADMINUSER", ::cADMINUSER, ::cADMINUSER , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CERTIFICADO", ::cCERTIFICADO, ::cCERTIFICADO , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DELIVERY", ::lDELIVERY, ::lDELIVERY , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IMGLOGO", ::cIMGLOGO, ::cIMGLOGO , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PRINT", ::lPRINT, ::lPRINT , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ROLE", ::cROLE, ::cROLE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SENHA", ::cSENHA, ::cSENHA , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("STORAGE", ::lSTORAGE, ::lSTORAGE , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSSIGNATURE_CONFIGEMPRESA
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cADMINEMAIL        :=  WSAdvValue( oResponse,"_ADMINEMAIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cADMINPASS         :=  WSAdvValue( oResponse,"_ADMINPASS","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
	::cADMINUSER         :=  WSAdvValue( oResponse,"_ADMINUSER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCERTIFICADO       :=  WSAdvValue( oResponse,"_CERTIFICADO","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
	::lDELIVERY          :=  WSAdvValue( oResponse,"_DELIVERY","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cIMGLOGO           :=  WSAdvValue( oResponse,"_IMGLOGO","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
	::lPRINT             :=  WSAdvValue( oResponse,"_PRINT","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cROLE              :=  WSAdvValue( oResponse,"_ROLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSENHA             :=  WSAdvValue( oResponse,"_SENHA","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
	::lSTORAGE           :=  WSAdvValue( oResponse,"_STORAGE","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFDOCSIGRET

WSSTRUCT TSSWSSIGNATURE_ARRAYOFDOCSIGRET
	WSDATA   oWSDOCSIGRET              AS TSSWSSIGNATURE_DOCSIGRET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSIGNATURE_ARRAYOFDOCSIGRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSIGNATURE_ARRAYOFDOCSIGRET
	::oWSDOCSIGRET         := {} // Array Of  TSSWSSIGNATURE_DOCSIGRET():New()
Return

WSMETHOD CLONE WSCLIENT TSSWSSIGNATURE_ARRAYOFDOCSIGRET
	Local oClone := TSSWSSIGNATURE_ARRAYOFDOCSIGRET():NEW()
	oClone:oWSDOCSIGRET := NIL
	If ::oWSDOCSIGRET <> NIL 
		oClone:oWSDOCSIGRET := {}
		aEval( ::oWSDOCSIGRET , { |x| aadd( oClone:oWSDOCSIGRET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSSIGNATURE_ARRAYOFDOCSIGRET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_DOCSIGRET","DOCSIGRET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSDOCSIGRET , TSSWSSIGNATURE_DOCSIGRET():New() )
			::oWSDOCSIGRET[len(::oWSDOCSIGRET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFDOCSIG

WSSTRUCT TSSWSSIGNATURE_ARRAYOFDOCSIG
	WSDATA   oWSDOCSIG                 AS TSSWSSIGNATURE_DOCSIG OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSIGNATURE_ARRAYOFDOCSIG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSIGNATURE_ARRAYOFDOCSIG
	::oWSDOCSIG            := {} // Array Of  TSSWSSIGNATURE_DOCSIG():New()
Return

WSMETHOD CLONE WSCLIENT TSSWSSIGNATURE_ARRAYOFDOCSIG
	Local oClone := TSSWSSIGNATURE_ARRAYOFDOCSIG():NEW()
	oClone:oWSDOCSIG := NIL
	If ::oWSDOCSIG <> NIL 
		oClone:oWSDOCSIG := {}
		aEval( ::oWSDOCSIG , { |x| aadd( oClone:oWSDOCSIG , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSWSSIGNATURE_ARRAYOFDOCSIG
	Local cSoap := ""
	aEval( ::oWSDOCSIG , {|x| cSoap := cSoap  +  WSSoapValue("DOCSIG", x , x , "DOCSIG", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFDOCSIGRESULT

WSSTRUCT TSSWSSIGNATURE_ARRAYOFDOCSIGRESULT
	WSDATA   oWSDOCSIGRESULT           AS TSSWSSIGNATURE_DOCSIGRESULT OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSIGNATURE_ARRAYOFDOCSIGRESULT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSIGNATURE_ARRAYOFDOCSIGRESULT
	::oWSDOCSIGRESULT      := {} // Array Of  TSSWSSIGNATURE_DOCSIGRESULT():New()
Return

WSMETHOD CLONE WSCLIENT TSSWSSIGNATURE_ARRAYOFDOCSIGRESULT
	Local oClone := TSSWSSIGNATURE_ARRAYOFDOCSIGRESULT():NEW()
	oClone:oWSDOCSIGRESULT := NIL
	If ::oWSDOCSIGRESULT <> NIL 
		oClone:oWSDOCSIGRESULT := {}
		aEval( ::oWSDOCSIGRESULT , { |x| aadd( oClone:oWSDOCSIGRESULT , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSSIGNATURE_ARRAYOFDOCSIGRESULT
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_DOCSIGRESULT","DOCSIGRESULT",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSDOCSIGRESULT , TSSWSSIGNATURE_DOCSIGRESULT():New() )
			::oWSDOCSIGRESULT[len(::oWSDOCSIGRESULT)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure DOCSIGRET

WSSTRUCT TSSWSSIGNATURE_DOCSIGRET
	WSDATA   nAMBIENTE                 AS integer
	WSDATA   cAUTORIZACAO              AS string OPTIONAL
	WSDATA   nCODIGO                   AS integer
	WSDATA   dDTAUTORIZACAO            AS date OPTIONAL
	WSDATA   cHRAUTORIZACAO            AS string OPTIONAL
	WSDATA   cID                       AS string
	WSDATA   oWSLOTE                   AS TSSWSSIGNATURE_ARRAYOFLOTE OPTIONAL
	WSDATA   cMENSAGEM                 AS string
	WSDATA   cRECOMENDACAO             AS string
	WSDATA   nSTATUS                   AS integer
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSIGNATURE_DOCSIGRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSIGNATURE_DOCSIGRET
Return

WSMETHOD CLONE WSCLIENT TSSWSSIGNATURE_DOCSIGRET
	Local oClone := TSSWSSIGNATURE_DOCSIGRET():NEW()
	oClone:nAMBIENTE            := ::nAMBIENTE
	oClone:cAUTORIZACAO         := ::cAUTORIZACAO
	oClone:nCODIGO              := ::nCODIGO
	oClone:dDTAUTORIZACAO       := ::dDTAUTORIZACAO
	oClone:cHRAUTORIZACAO       := ::cHRAUTORIZACAO
	oClone:cID                  := ::cID
	oClone:oWSLOTE              := IIF(::oWSLOTE = NIL , NIL , ::oWSLOTE:Clone() )
	oClone:cMENSAGEM            := ::cMENSAGEM
	oClone:cRECOMENDACAO        := ::cRECOMENDACAO
	oClone:nSTATUS              := ::nSTATUS
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSSIGNATURE_DOCSIGRET
	Local oNode7
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nAMBIENTE          :=  WSAdvValue( oResponse,"_AMBIENTE","integer",NIL,"Property nAMBIENTE as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cAUTORIZACAO       :=  WSAdvValue( oResponse,"_AUTORIZACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","integer",NIL,"Property nCODIGO as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::dDTAUTORIZACAO     :=  WSAdvValue( oResponse,"_DTAUTORIZACAO","date",NIL,NIL,NIL,"D",NIL,NIL) 
	::cHRAUTORIZACAO     :=  WSAdvValue( oResponse,"_HRAUTORIZACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	oNode7 :=  WSAdvValue( oResponse,"_LOTE","ARRAYOFLOTE",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode7 != NIL
		::oWSLOTE := TSSWSSIGNATURE_ARRAYOFLOTE():New()
		::oWSLOTE:SoapRecv(oNode7)
	EndIf
	::cMENSAGEM          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,"Property cMENSAGEM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRECOMENDACAO      :=  WSAdvValue( oResponse,"_RECOMENDACAO","string",NIL,"Property cRECOMENDACAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nSTATUS            :=  WSAdvValue( oResponse,"_STATUS","integer",NIL,"Property nSTATUS as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure DOCSIG

WSSTRUCT TSSWSSIGNATURE_DOCSIG
	WSDATA   cID                       AS string
	WSDATA   cMODELO                   AS string
	WSDATA   cXML                      AS base64Binary
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSIGNATURE_DOCSIG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSIGNATURE_DOCSIG
Return

WSMETHOD CLONE WSCLIENT TSSWSSIGNATURE_DOCSIG
	Local oClone := TSSWSSIGNATURE_DOCSIG():NEW()
	oClone:cID                  := ::cID
	oClone:cMODELO              := ::cMODELO
	oClone:cXML                 := ::cXML
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSWSSIGNATURE_DOCSIG
	Local cSoap := ""
	cSoap += WSSoapValue("ID", ::cID, ::cID , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("MODELO", ::cMODELO, ::cMODELO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("XML", ::cXML, ::cXML , "base64Binary", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure DOCSIGRESULT

WSSTRUCT TSSWSSIGNATURE_DOCSIGRESULT
	WSDATA   oWSERRO                   AS TSSWSSIGNATURE_ERRO OPTIONAL
	WSDATA   cID                       AS string OPTIONAL
	WSDATA   lRESULTDOC                AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSIGNATURE_DOCSIGRESULT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSIGNATURE_DOCSIGRESULT
Return

WSMETHOD CLONE WSCLIENT TSSWSSIGNATURE_DOCSIGRESULT
	Local oClone := TSSWSSIGNATURE_DOCSIGRESULT():NEW()
	oClone:oWSERRO              := IIF(::oWSERRO = NIL , NIL , ::oWSERRO:Clone() )
	oClone:cID                  := ::cID
	oClone:lRESULTDOC           := ::lRESULTDOC
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSSIGNATURE_DOCSIGRESULT
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ERRO","ERRO",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSERRO := TSSWSSIGNATURE_ERRO():New()
		::oWSERRO:SoapRecv(oNode1)
	EndIf
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lRESULTDOC         :=  WSAdvValue( oResponse,"_RESULTDOC","boolean",NIL,"Property lRESULTDOC as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFLOTE

WSSTRUCT TSSWSSIGNATURE_ARRAYOFLOTE
	WSDATA   oWSLOTE                   AS TSSWSSIGNATURE_LOTE OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSIGNATURE_ARRAYOFLOTE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSIGNATURE_ARRAYOFLOTE
	::oWSLOTE              := {} // Array Of  TSSWSSIGNATURE_LOTE():New()
Return

WSMETHOD CLONE WSCLIENT TSSWSSIGNATURE_ARRAYOFLOTE
	Local oClone := TSSWSSIGNATURE_ARRAYOFLOTE():NEW()
	oClone:oWSLOTE := NIL
	If ::oWSLOTE <> NIL 
		oClone:oWSLOTE := {}
		aEval( ::oWSLOTE , { |x| aadd( oClone:oWSLOTE , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSSIGNATURE_ARRAYOFLOTE
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_LOTE","LOTE",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSLOTE , TSSWSSIGNATURE_LOTE():New() )
			::oWSLOTE[len(::oWSLOTE)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure LOTE

WSSTRUCT TSSWSSIGNATURE_LOTE
	WSDATA   nCODIGO                   AS integer OPTIONAL
	WSDATA   cDESCRICAO                AS string OPTIONAL
	WSDATA   dDTENVIO                  AS date
	WSDATA   dDTPROC                   AS date OPTIONAL
	WSDATA   cHRENVIO                  AS string
	WSDATA   cHRPROC                   AS string OPTIONAL
	WSDATA   nNUMERO                   AS integer
	WSDATA   cPDF                      AS base64Binary OPTIONAL
	WSDATA   lPROCESSADO               AS boolean
	WSDATA   cXML                      AS base64Binary OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSIGNATURE_LOTE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSIGNATURE_LOTE
Return

WSMETHOD CLONE WSCLIENT TSSWSSIGNATURE_LOTE
	Local oClone := TSSWSSIGNATURE_LOTE():NEW()
	oClone:nCODIGO              := ::nCODIGO
	oClone:cDESCRICAO           := ::cDESCRICAO
	oClone:dDTENVIO             := ::dDTENVIO
	oClone:dDTPROC              := ::dDTPROC
	oClone:cHRENVIO             := ::cHRENVIO
	oClone:cHRPROC              := ::cHRPROC
	oClone:nNUMERO              := ::nNUMERO
	oClone:cPDF                 := ::cPDF
	oClone:lPROCESSADO          := ::lPROCESSADO
	oClone:cXML                 := ::cXML
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSSIGNATURE_LOTE
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::dDTENVIO           :=  WSAdvValue( oResponse,"_DTENVIO","date",NIL,"Property dDTENVIO as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::dDTPROC            :=  WSAdvValue( oResponse,"_DTPROC","date",NIL,NIL,NIL,"D",NIL,NIL) 
	::cHRENVIO           :=  WSAdvValue( oResponse,"_HRENVIO","string",NIL,"Property cHRENVIO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cHRPROC            :=  WSAdvValue( oResponse,"_HRPROC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nNUMERO            :=  WSAdvValue( oResponse,"_NUMERO","integer",NIL,"Property nNUMERO as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cPDF               :=  WSAdvValue( oResponse,"_PDF","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
	::lPROCESSADO        :=  WSAdvValue( oResponse,"_PROCESSADO","boolean",NIL,"Property lPROCESSADO as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cXML               :=  WSAdvValue( oResponse,"_XML","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
Return


