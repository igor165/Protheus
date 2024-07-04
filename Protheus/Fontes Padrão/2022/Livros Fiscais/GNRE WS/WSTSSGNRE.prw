#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch" 

/* ===============================================================================
WSDL Location    http://10.172.67.17:8050/TSSGNRE.apw?WSDL
Gerado em        10/31/18 13:56:23
Observaùùes      Cùdigo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alteraùùes neste arquivo podem causar funcionamento incorreto
                 e serùo perdidas caso o cùdigo-fonte seja gerado novamente.
=============================================================================== */

Static cURL      := AllTrim(PadR(GetNewPar("MV_SPEDURL","http://"),250))

User Function _GZYQKJS ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSTSSGNRE
------------------------------------------------------------------------------- */

WSCLIENT WSTSSGNRE

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD CONSULTAAREA
	WSMETHOD GETCONFGNREUF
	WSMETHOD MONITOR
	WSMETHOD OBTERPDFDUA
	WSMETHOD REMESSA
	WSMETHOD RETORNA
	WSMETHOD SCHEMA

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cUSERTOKEN                AS string
	WSDATA   cIDENT                    AS string
	WSDATA   cAMBIENTE                 AS string
	WSDATA   cCNPJ                     AS string
	WSDATA   oWSCONSULTAAREARESULT     AS TSSGNRE_CONSULTAAREAS
	WSDATA   cUF                       AS string
	WSDATA   cCODRECEITA               AS string
	WSDATA   oWSGETCONFGNREUFRESULT    AS TSSGNRE_RETCONFIGUF
	WSDATA   dDATAINI                  AS date
	WSDATA   dDATAFIM                  AS date
	WSDATA   cIDINI                    AS string
	WSDATA   cIDFIM                    AS string
	WSDATA   oWSMONITORRESULT          AS TSSGNRE_MONITORRETDOCS
	WSDATA   cID                       AS string
	WSDATA   oWSOBTERPDFDUARESULT      AS TSSGNRE_RETORNAPDFS
	WSDATA   oWSDOCS                   AS TSSGNRE_REMESSADOCS
	WSDATA   cVERSAO                   AS string
	WSDATA   oWSREMESSARESULT          AS TSSGNRE_REMESSARETDOCS
	WSDATA   oWSRETORNARESULT          AS TSSGNRE_RETORNARETDOCS
	WSDATA   cXML                      AS base64Binary
	WSDATA   oWSSCHEMARESULT           AS TSSGNRE_SCHEMARETDOCS

	// Estruturas mantidas por compatibilidade - NùO USAR
	WSDATA   oWSREMESSADOCS            AS TSSGNRE_REMESSADOCS

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSTSSGNRE
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Cùdigo-Fonte Client atual requer os executùveis do Protheus Build [7.00.131227A-20171213 NG] ou superior. Atualize o Protheus ou gere o Cùdigo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSTSSGNRE
	::oWSCONSULTAAREARESULT := TSSGNRE_CONSULTAAREAS():New()
	::oWSGETCONFGNREUFRESULT := TSSGNRE_RETCONFIGUF():New()
	::oWSMONITORRESULT   := TSSGNRE_MONITORRETDOCS():New()
	::oWSOBTERPDFDUARESULT := TSSGNRE_RETORNAPDFS():New()
	::oWSDOCS            := TSSGNRE_REMESSADOCS():New()
	::oWSREMESSARESULT   := TSSGNRE_REMESSARETDOCS():New()
	::oWSRETORNARESULT   := TSSGNRE_RETORNARETDOCS():New()
	::oWSSCHEMARESULT    := TSSGNRE_SCHEMARETDOCS():New()

	// Estruturas mantidas por compatibilidade - NùO USAR
	::oWSREMESSADOCS     := ::oWSDOCS
Return

WSMETHOD RESET WSCLIENT WSTSSGNRE
	::cUSERTOKEN         := NIL 
	::cIDENT             := NIL 
	::cAMBIENTE          := NIL 
	::cCNPJ              := NIL 
	::oWSCONSULTAAREARESULT := NIL 
	::cUF                := NIL 
	::cCODRECEITA        := NIL 
	::oWSGETCONFGNREUFRESULT := NIL 
	::dDATAINI           := NIL 
	::dDATAFIM           := NIL 
	::cIDINI             := NIL 
	::cIDFIM             := NIL 
	::oWSMONITORRESULT   := NIL 
	::cID                := NIL 
	::oWSOBTERPDFDUARESULT := NIL 
	::oWSDOCS            := NIL 
	::cVERSAO            := NIL 
	::oWSREMESSARESULT   := NIL 
	::oWSRETORNARESULT   := NIL 
	::cXML               := NIL 
	::oWSSCHEMARESULT    := NIL 

	// Estruturas mantidas por compatibilidade - NùO USAR
	::oWSREMESSADOCS     := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSTSSGNRE
Local oClone := WSTSSGNRE():New()
	oClone:_URL          := ::_URL 
	oClone:cUSERTOKEN    := ::cUSERTOKEN
	oClone:cIDENT        := ::cIDENT
	oClone:cAMBIENTE     := ::cAMBIENTE
	oClone:cCNPJ         := ::cCNPJ
	oClone:oWSCONSULTAAREARESULT :=  IIF(::oWSCONSULTAAREARESULT = NIL , NIL ,::oWSCONSULTAAREARESULT:Clone() )
	oClone:cUF           := ::cUF
	oClone:cCODRECEITA   := ::cCODRECEITA
	oClone:oWSGETCONFGNREUFRESULT :=  IIF(::oWSGETCONFGNREUFRESULT = NIL , NIL ,::oWSGETCONFGNREUFRESULT:Clone() )
	oClone:dDATAINI      := ::dDATAINI
	oClone:dDATAFIM      := ::dDATAFIM
	oClone:cIDINI        := ::cIDINI
	oClone:cIDFIM        := ::cIDFIM
	oClone:oWSMONITORRESULT :=  IIF(::oWSMONITORRESULT = NIL , NIL ,::oWSMONITORRESULT:Clone() )
	oClone:cID           := ::cID
	oClone:oWSOBTERPDFDUARESULT :=  IIF(::oWSOBTERPDFDUARESULT = NIL , NIL ,::oWSOBTERPDFDUARESULT:Clone() )
	oClone:oWSDOCS       :=  IIF(::oWSDOCS = NIL , NIL ,::oWSDOCS:Clone() )
	oClone:cVERSAO       := ::cVERSAO
	oClone:oWSREMESSARESULT :=  IIF(::oWSREMESSARESULT = NIL , NIL ,::oWSREMESSARESULT:Clone() )
	oClone:oWSRETORNARESULT :=  IIF(::oWSRETORNARESULT = NIL , NIL ,::oWSRETORNARESULT:Clone() )
	oClone:cXML          := ::cXML
	oClone:oWSSCHEMARESULT :=  IIF(::oWSSCHEMARESULT = NIL , NIL ,::oWSSCHEMARESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NùO USAR
	oClone:oWSREMESSADOCS := oClone:oWSDOCS
Return oClone

// WSDL Method CONSULTAAREA of Service WSTSSGNRE

WSMETHOD CONSULTAAREA WSSEND cUSERTOKEN,cIDENT,cAMBIENTE,cCNPJ WSRECEIVE oWSCONSULTAAREARESULT WSCLIENT WSTSSGNRE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONSULTAAREA xmlns="'+cURL+'">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IDENT", ::cIDENT, cIDENT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("AMBIENTE", ::cAMBIENTE, cAMBIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNPJ", ::cCNPJ, cCNPJ , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CONSULTAAREA>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	cURL+"/CONSULTAAREA",; 
	"DOCUMENT",cURL+"/",,"1.031217",; 
	cURL+"/TSSGNRE.apw")

::Init()
::oWSCONSULTAAREARESULT:SoapRecv( WSAdvValue( oXmlRet,"_CONSULTAAREARESPONSE:_CONSULTAAREARESULT","CONSULTAAREAS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETCONFGNREUF of Service WSTSSGNRE

WSMETHOD GETCONFGNREUF WSSEND cUSERTOKEN,cIDENT,cAMBIENTE,cUF,cCODRECEITA WSRECEIVE oWSGETCONFGNREUFRESULT WSCLIENT WSTSSGNRE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETCONFGNREUF xmlns="'+cURL+'">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IDENT", ::cIDENT, cIDENT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("AMBIENTE", ::cAMBIENTE, cAMBIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("UF", ::cUF, cUF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODRECEITA", ::cCODRECEITA, cCODRECEITA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETCONFGNREUF>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	cURL+"/GETCONFGNREUF",; 
	"DOCUMENT",cURL+"/",,"1.031217",; 
	cURL+"/TSSGNRE.apw")

::Init()
::oWSGETCONFGNREUFRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETCONFGNREUFRESPONSE:_GETCONFGNREUFRESULT","RETCONFIGUF",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method MONITOR of Service WSTSSGNRE

WSMETHOD MONITOR WSSEND cUSERTOKEN,cIDENT,cAMBIENTE,dDATAINI,dDATAFIM,cIDINI,cIDFIM WSRECEIVE oWSMONITORRESULT WSCLIENT WSTSSGNRE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<MONITOR xmlns="'+cURL+'">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IDENT", ::cIDENT, cIDENT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("AMBIENTE", ::cAMBIENTE, cAMBIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DATAINI", ::dDATAINI, dDATAINI , "date", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DATAFIM", ::dDATAFIM, dDATAFIM , "date", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IDINI", ::cIDINI, cIDINI , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IDFIM", ::cIDFIM, cIDFIM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</MONITOR>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	cURL+"/MONITOR",; 
	"DOCUMENT",cURL+"/",,"1.031217",; 
	cURL+"/TSSGNRE.apw")

::Init()
::oWSMONITORRESULT:SoapRecv( WSAdvValue( oXmlRet,"_MONITORRESPONSE:_MONITORRESULT","MONITORRETDOCS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method OBTERPDFDUA of Service WSTSSGNRE

WSMETHOD OBTERPDFDUA WSSEND cUSERTOKEN,cIDENT,cAMBIENTE,cID WSRECEIVE oWSOBTERPDFDUARESULT WSCLIENT WSTSSGNRE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<OBTERPDFDUA xmlns="'+cURL+'">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IDENT", ::cIDENT, cIDENT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("AMBIENTE", ::cAMBIENTE, cAMBIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ID", ::cID, cID , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</OBTERPDFDUA>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	cURL+"/OBTERPDFDUA",; 
	"DOCUMENT",cURL+"/",,"1.031217",; 
	cURL+"/TSSGNRE.apw")

::Init()
::oWSOBTERPDFDUARESULT:SoapRecv( WSAdvValue( oXmlRet,"_OBTERPDFDUARESPONSE:_OBTERPDFDUARESULT","RETORNAPDFS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method REMESSA of Service WSTSSGNRE

WSMETHOD REMESSA WSSEND cUSERTOKEN,cIDENT,cAMBIENTE,cUF,oWSDOCS,cVERSAO WSRECEIVE oWSREMESSARESULT WSCLIENT WSTSSGNRE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<REMESSA xmlns="'+cURL+'">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IDENT", ::cIDENT, cIDENT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("AMBIENTE", ::cAMBIENTE, cAMBIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("UF", ::cUF, cUF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DOCS", ::oWSDOCS, oWSDOCS , "REMESSADOCS", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VERSAO", ::cVERSAO, cVERSAO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</REMESSA>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	cURL+"/REMESSA",; 
	"DOCUMENT",cURL+"/",,"1.031217",; 
	cURL+"/TSSGNRE.apw")

::Init()
::oWSREMESSARESULT:SoapRecv( WSAdvValue( oXmlRet,"_REMESSARESPONSE:_REMESSARESULT","REMESSARETDOCS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RETORNA of Service WSTSSGNRE

WSMETHOD RETORNA WSSEND cUSERTOKEN,cIDENT,cAMBIENTE,cID WSRECEIVE oWSRETORNARESULT WSCLIENT WSTSSGNRE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RETORNA xmlns="'+cURL+'">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IDENT", ::cIDENT, cIDENT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("AMBIENTE", ::cAMBIENTE, cAMBIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ID", ::cID, cID , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RETORNA>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	cURL+"/RETORNA",; 
	"DOCUMENT",cURL+"/",,"1.031217",; 
	cURL+"/TSSGNRE.apw")

::Init()
::oWSRETORNARESULT:SoapRecv( WSAdvValue( oXmlRet,"_RETORNARESPONSE:_RETORNARESULT","RETORNARETDOCS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SCHEMA of Service WSTSSGNRE

WSMETHOD SCHEMA WSSEND cUSERTOKEN,cIDENT,cAMBIENTE,cID,cUF,cXML,cVERSAO WSRECEIVE oWSSCHEMARESULT WSCLIENT WSTSSGNRE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SCHEMA xmlns="'+cURL+'">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IDENT", ::cIDENT, cIDENT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("AMBIENTE", ::cAMBIENTE, cAMBIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ID", ::cID, cID , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("UF", ::cUF, cUF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("XML", ::cXML, cXML , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VERSAO", ::cVERSAO, cVERSAO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</SCHEMA>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	cURL+"/SCHEMA",; 
	"DOCUMENT",cURL+"/",,"1.031217",; 
	cURL+"/TSSGNRE.apw")

::Init()
::oWSSCHEMARESULT:SoapRecv( WSAdvValue( oXmlRet,"_SCHEMARESPONSE:_SCHEMARESULT","SCHEMARETDOCS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure CONSULTAAREAS

WSSTRUCT TSSGNRE_CONSULTAAREAS
	WSDATA   oWSDOCUMENTOS             AS TSSGNRE_ARRAYOFCONSULTAREA
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_CONSULTAAREAS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_CONSULTAAREAS
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_CONSULTAAREAS
	Local oClone := TSSGNRE_CONSULTAAREAS():NEW()
	oClone:oWSDOCUMENTOS        := IIF(::oWSDOCUMENTOS = NIL , NIL , ::oWSDOCUMENTOS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_CONSULTAAREAS
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_DOCUMENTOS","ARRAYOFCONSULTAREA",NIL,"Property oWSDOCUMENTOS as s0:ARRAYOFCONSULTAREA on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSDOCUMENTOS := TSSGNRE_ARRAYOFCONSULTAREA():New()
		::oWSDOCUMENTOS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure RETCONFIGUF

WSSTRUCT TSSGNRE_RETCONFIGUF
	WSDATA   cAMBIENTE                 AS string
	WSDATA   oWSCAMPOSADICIONAIS       AS TSSGNRE_ARRAYOFINFCAMPOSADIC OPTIONAL
	WSDATA   cDESCRESULT               AS string
	WSDATA   cRECEITA                  AS string
	WSDATA   lSUCESSO                  AS boolean
	WSDATA   cUF                       AS string
	WSDATA   cXMLRETCONS               AS base64Binary OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_RETCONFIGUF
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_RETCONFIGUF
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_RETCONFIGUF
	Local oClone := TSSGNRE_RETCONFIGUF():NEW()
	oClone:cAMBIENTE            := ::cAMBIENTE
	oClone:oWSCAMPOSADICIONAIS  := IIF(::oWSCAMPOSADICIONAIS = NIL , NIL , ::oWSCAMPOSADICIONAIS:Clone() )
	oClone:cDESCRESULT          := ::cDESCRESULT
	oClone:cRECEITA             := ::cRECEITA
	oClone:lSUCESSO             := ::lSUCESSO
	oClone:cUF                  := ::cUF
	oClone:cXMLRETCONS          := ::cXMLRETCONS
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_RETCONFIGUF
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAMBIENTE          :=  WSAdvValue( oResponse,"_AMBIENTE","string",NIL,"Property cAMBIENTE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_CAMPOSADICIONAIS","ARRAYOFINFCAMPOSADIC",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSCAMPOSADICIONAIS := TSSGNRE_ARRAYOFINFCAMPOSADIC():New()
		::oWSCAMPOSADICIONAIS:SoapRecv(oNode2)
	EndIf
	::cDESCRESULT        :=  WSAdvValue( oResponse,"_DESCRESULT","string",NIL,"Property cDESCRESULT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRECEITA           :=  WSAdvValue( oResponse,"_RECEITA","string",NIL,"Property cRECEITA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lSUCESSO           :=  WSAdvValue( oResponse,"_SUCESSO","boolean",NIL,"Property lSUCESSO as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cUF                :=  WSAdvValue( oResponse,"_UF","string",NIL,"Property cUF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cXMLRETCONS        :=  WSAdvValue( oResponse,"_XMLRETCONS","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
Return

// WSDL Data Structure MONITORRETDOCS

WSSTRUCT TSSGNRE_MONITORRETDOCS
	WSDATA   oWSDOCUMENTOS             AS TSSGNRE_ARRAYOFMONITORRETDOC
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_MONITORRETDOCS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_MONITORRETDOCS
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_MONITORRETDOCS
	Local oClone := TSSGNRE_MONITORRETDOCS():NEW()
	oClone:oWSDOCUMENTOS        := IIF(::oWSDOCUMENTOS = NIL , NIL , ::oWSDOCUMENTOS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_MONITORRETDOCS
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_DOCUMENTOS","ARRAYOFMONITORRETDOC",NIL,"Property oWSDOCUMENTOS as s0:ARRAYOFMONITORRETDOC on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSDOCUMENTOS := TSSGNRE_ARRAYOFMONITORRETDOC():New()
		::oWSDOCUMENTOS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure RETORNAPDFS

WSSTRUCT TSSGNRE_RETORNAPDFS
	WSDATA   oWSDOCUMENTOS             AS TSSGNRE_ARRAYOFRETORNAPDF
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_RETORNAPDFS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_RETORNAPDFS
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_RETORNAPDFS
	Local oClone := TSSGNRE_RETORNAPDFS():NEW()
	oClone:oWSDOCUMENTOS        := IIF(::oWSDOCUMENTOS = NIL , NIL , ::oWSDOCUMENTOS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_RETORNAPDFS
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_DOCUMENTOS","ARRAYOFRETORNAPDF",NIL,"Property oWSDOCUMENTOS as s0:ARRAYOFRETORNAPDF on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSDOCUMENTOS := TSSGNRE_ARRAYOFRETORNAPDF():New()
		::oWSDOCUMENTOS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure REMESSADOCS

WSSTRUCT TSSGNRE_REMESSADOCS
	WSDATA   oWSDOCUMENTOS             AS TSSGNRE_ARRAYOFREMESSADOCUMENTO
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_REMESSADOCS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_REMESSADOCS
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_REMESSADOCS
	Local oClone := TSSGNRE_REMESSADOCS():NEW()
	oClone:oWSDOCUMENTOS        := IIF(::oWSDOCUMENTOS = NIL , NIL , ::oWSDOCUMENTOS:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSGNRE_REMESSADOCS
	Local cSoap := ""
	cSoap += WSSoapValue("DOCUMENTOS", ::oWSDOCUMENTOS, ::oWSDOCUMENTOS , "ARRAYOFREMESSADOCUMENTO", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure REMESSARETDOCS

WSSTRUCT TSSGNRE_REMESSARETDOCS
	WSDATA   oWSDOCUMENTOS             AS TSSGNRE_ARRAYOFREMESSARETDOC
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_REMESSARETDOCS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_REMESSARETDOCS
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_REMESSARETDOCS
	Local oClone := TSSGNRE_REMESSARETDOCS():NEW()
	oClone:oWSDOCUMENTOS        := IIF(::oWSDOCUMENTOS = NIL , NIL , ::oWSDOCUMENTOS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_REMESSARETDOCS
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_DOCUMENTOS","ARRAYOFREMESSARETDOC",NIL,"Property oWSDOCUMENTOS as s0:ARRAYOFREMESSARETDOC on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSDOCUMENTOS := TSSGNRE_ARRAYOFREMESSARETDOC():New()
		::oWSDOCUMENTOS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure RETORNARETDOCS

WSSTRUCT TSSGNRE_RETORNARETDOCS
	WSDATA   oWSDOCUMENTOS             AS TSSGNRE_ARRAYOFRETORNARETDOC
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_RETORNARETDOCS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_RETORNARETDOCS
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_RETORNARETDOCS
	Local oClone := TSSGNRE_RETORNARETDOCS():NEW()
	oClone:oWSDOCUMENTOS        := IIF(::oWSDOCUMENTOS = NIL , NIL , ::oWSDOCUMENTOS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_RETORNARETDOCS
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_DOCUMENTOS","ARRAYOFRETORNARETDOC",NIL,"Property oWSDOCUMENTOS as s0:ARRAYOFRETORNARETDOC on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSDOCUMENTOS := TSSGNRE_ARRAYOFRETORNARETDOC():New()
		::oWSDOCUMENTOS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure SCHEMARETDOCS

WSSTRUCT TSSGNRE_SCHEMARETDOCS
	WSDATA   oWSDOCUMENTOS             AS TSSGNRE_ARRAYOFSCHEMARETDOC
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_SCHEMARETDOCS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_SCHEMARETDOCS
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_SCHEMARETDOCS
	Local oClone := TSSGNRE_SCHEMARETDOCS():NEW()
	oClone:oWSDOCUMENTOS        := IIF(::oWSDOCUMENTOS = NIL , NIL , ::oWSDOCUMENTOS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_SCHEMARETDOCS
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_DOCUMENTOS","ARRAYOFSCHEMARETDOC",NIL,"Property oWSDOCUMENTOS as s0:ARRAYOFSCHEMARETDOC on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSDOCUMENTOS := TSSGNRE_ARRAYOFSCHEMARETDOC():New()
		::oWSDOCUMENTOS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ARRAYOFCONSULTAREA

WSSTRUCT TSSGNRE_ARRAYOFCONSULTAREA
	WSDATA   oWSCONSULTAREA            AS TSSGNRE_CONSULTAREA OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_ARRAYOFCONSULTAREA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_ARRAYOFCONSULTAREA
	::oWSCONSULTAREA       := {} // Array Of  TSSGNRE_CONSULTAREA():New()
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_ARRAYOFCONSULTAREA
	Local oClone := TSSGNRE_ARRAYOFCONSULTAREA():NEW()
	oClone:oWSCONSULTAREA := NIL
	If ::oWSCONSULTAREA <> NIL 
		oClone:oWSCONSULTAREA := {}
		aEval( ::oWSCONSULTAREA , { |x| aadd( oClone:oWSCONSULTAREA , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_ARRAYOFCONSULTAREA
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CONSULTAREA","CONSULTAREA",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSCONSULTAREA , TSSGNRE_CONSULTAREA():New() )
			::oWSCONSULTAREA[len(::oWSCONSULTAREA)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFINFCAMPOSADIC

WSSTRUCT TSSGNRE_ARRAYOFINFCAMPOSADIC
	WSDATA   oWSINFCAMPOSADIC          AS TSSGNRE_INFCAMPOSADIC OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_ARRAYOFINFCAMPOSADIC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_ARRAYOFINFCAMPOSADIC
	::oWSINFCAMPOSADIC     := {} // Array Of  TSSGNRE_INFCAMPOSADIC():New()
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_ARRAYOFINFCAMPOSADIC
	Local oClone := TSSGNRE_ARRAYOFINFCAMPOSADIC():NEW()
	oClone:oWSINFCAMPOSADIC := NIL
	If ::oWSINFCAMPOSADIC <> NIL 
		oClone:oWSINFCAMPOSADIC := {}
		aEval( ::oWSINFCAMPOSADIC , { |x| aadd( oClone:oWSINFCAMPOSADIC , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_ARRAYOFINFCAMPOSADIC
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_INFCAMPOSADIC","INFCAMPOSADIC",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSINFCAMPOSADIC , TSSGNRE_INFCAMPOSADIC():New() )
			::oWSINFCAMPOSADIC[len(::oWSINFCAMPOSADIC)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFMONITORRETDOC

WSSTRUCT TSSGNRE_ARRAYOFMONITORRETDOC
	WSDATA   oWSMONITORRETDOC          AS TSSGNRE_MONITORRETDOC OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_ARRAYOFMONITORRETDOC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_ARRAYOFMONITORRETDOC
	::oWSMONITORRETDOC     := {} // Array Of  TSSGNRE_MONITORRETDOC():New()
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_ARRAYOFMONITORRETDOC
	Local oClone := TSSGNRE_ARRAYOFMONITORRETDOC():NEW()
	oClone:oWSMONITORRETDOC := NIL
	If ::oWSMONITORRETDOC <> NIL 
		oClone:oWSMONITORRETDOC := {}
		aEval( ::oWSMONITORRETDOC , { |x| aadd( oClone:oWSMONITORRETDOC , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_ARRAYOFMONITORRETDOC
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_MONITORRETDOC","MONITORRETDOC",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSMONITORRETDOC , TSSGNRE_MONITORRETDOC():New() )
			::oWSMONITORRETDOC[len(::oWSMONITORRETDOC)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFRETORNAPDF

WSSTRUCT TSSGNRE_ARRAYOFRETORNAPDF
	WSDATA   oWSRETORNAPDF             AS TSSGNRE_RETORNAPDF OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_ARRAYOFRETORNAPDF
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_ARRAYOFRETORNAPDF
	::oWSRETORNAPDF        := {} // Array Of  TSSGNRE_RETORNAPDF():New()
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_ARRAYOFRETORNAPDF
	Local oClone := TSSGNRE_ARRAYOFRETORNAPDF():NEW()
	oClone:oWSRETORNAPDF := NIL
	If ::oWSRETORNAPDF <> NIL 
		oClone:oWSRETORNAPDF := {}
		aEval( ::oWSRETORNAPDF , { |x| aadd( oClone:oWSRETORNAPDF , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_ARRAYOFRETORNAPDF
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_RETORNAPDF","RETORNAPDF",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSRETORNAPDF , TSSGNRE_RETORNAPDF():New() )
			::oWSRETORNAPDF[len(::oWSRETORNAPDF)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFREMESSADOCUMENTO

WSSTRUCT TSSGNRE_ARRAYOFREMESSADOCUMENTO
	WSDATA   oWSREMESSADOCUMENTO       AS TSSGNRE_REMESSADOCUMENTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_ARRAYOFREMESSADOCUMENTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_ARRAYOFREMESSADOCUMENTO
	::oWSREMESSADOCUMENTO  := {} // Array Of  TSSGNRE_REMESSADOCUMENTO():New()
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_ARRAYOFREMESSADOCUMENTO
	Local oClone := TSSGNRE_ARRAYOFREMESSADOCUMENTO():NEW()
	oClone:oWSREMESSADOCUMENTO := NIL
	If ::oWSREMESSADOCUMENTO <> NIL 
		oClone:oWSREMESSADOCUMENTO := {}
		aEval( ::oWSREMESSADOCUMENTO , { |x| aadd( oClone:oWSREMESSADOCUMENTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSGNRE_ARRAYOFREMESSADOCUMENTO
	Local cSoap := ""
	aEval( ::oWSREMESSADOCUMENTO , {|x| cSoap := cSoap  +  WSSoapValue("REMESSADOCUMENTO", x , x , "REMESSADOCUMENTO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFREMESSARETDOC

WSSTRUCT TSSGNRE_ARRAYOFREMESSARETDOC
	WSDATA   oWSREMESSARETDOC          AS TSSGNRE_REMESSARETDOC OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_ARRAYOFREMESSARETDOC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_ARRAYOFREMESSARETDOC
	::oWSREMESSARETDOC     := {} // Array Of  TSSGNRE_REMESSARETDOC():New()
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_ARRAYOFREMESSARETDOC
	Local oClone := TSSGNRE_ARRAYOFREMESSARETDOC():NEW()
	oClone:oWSREMESSARETDOC := NIL
	If ::oWSREMESSARETDOC <> NIL 
		oClone:oWSREMESSARETDOC := {}
		aEval( ::oWSREMESSARETDOC , { |x| aadd( oClone:oWSREMESSARETDOC , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_ARRAYOFREMESSARETDOC
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_REMESSARETDOC","REMESSARETDOC",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSREMESSARETDOC , TSSGNRE_REMESSARETDOC():New() )
			::oWSREMESSARETDOC[len(::oWSREMESSARETDOC)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFRETORNARETDOC

WSSTRUCT TSSGNRE_ARRAYOFRETORNARETDOC
	WSDATA   oWSRETORNARETDOC          AS TSSGNRE_RETORNARETDOC OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_ARRAYOFRETORNARETDOC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_ARRAYOFRETORNARETDOC
	::oWSRETORNARETDOC     := {} // Array Of  TSSGNRE_RETORNARETDOC():New()
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_ARRAYOFRETORNARETDOC
	Local oClone := TSSGNRE_ARRAYOFRETORNARETDOC():NEW()
	oClone:oWSRETORNARETDOC := NIL
	If ::oWSRETORNARETDOC <> NIL 
		oClone:oWSRETORNARETDOC := {}
		aEval( ::oWSRETORNARETDOC , { |x| aadd( oClone:oWSRETORNARETDOC , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_ARRAYOFRETORNARETDOC
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_RETORNARETDOC","RETORNARETDOC",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSRETORNARETDOC , TSSGNRE_RETORNARETDOC():New() )
			::oWSRETORNARETDOC[len(::oWSRETORNARETDOC)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFSCHEMARETDOC

WSSTRUCT TSSGNRE_ARRAYOFSCHEMARETDOC
	WSDATA   oWSSCHEMARETDOC           AS TSSGNRE_SCHEMARETDOC OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_ARRAYOFSCHEMARETDOC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_ARRAYOFSCHEMARETDOC
	::oWSSCHEMARETDOC      := {} // Array Of  TSSGNRE_SCHEMARETDOC():New()
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_ARRAYOFSCHEMARETDOC
	Local oClone := TSSGNRE_ARRAYOFSCHEMARETDOC():NEW()
	oClone:oWSSCHEMARETDOC := NIL
	If ::oWSSCHEMARETDOC <> NIL 
		oClone:oWSSCHEMARETDOC := {}
		aEval( ::oWSSCHEMARETDOC , { |x| aadd( oClone:oWSSCHEMARETDOC , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_ARRAYOFSCHEMARETDOC
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_SCHEMARETDOC","SCHEMARETDOC",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSCHEMARETDOC , TSSGNRE_SCHEMARETDOC():New() )
			::oWSSCHEMARETDOC[len(::oWSSCHEMARETDOC)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure CONSULTAREA

WSSTRUCT TSSGNRE_CONSULTAREA
	WSDATA   cAMBIENTE                 AS string
	WSDATA   cIDENT                    AS string
	WSDATA   cXML                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_CONSULTAREA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_CONSULTAREA
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_CONSULTAREA
	Local oClone := TSSGNRE_CONSULTAREA():NEW()
	oClone:cAMBIENTE            := ::cAMBIENTE
	oClone:cIDENT               := ::cIDENT
	oClone:cXML                 := ::cXML
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_CONSULTAREA
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAMBIENTE          :=  WSAdvValue( oResponse,"_AMBIENTE","string",NIL,"Property cAMBIENTE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cIDENT             :=  WSAdvValue( oResponse,"_IDENT","string",NIL,"Property cIDENT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cXML               :=  WSAdvValue( oResponse,"_XML","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure INFCAMPOSADIC

WSSTRUCT TSSGNRE_INFCAMPOSADIC
	WSDATA   cCODIGO                   AS string
	WSDATA   cDECIMAL                  AS string OPTIONAL
	WSDATA   cOBRIGATORIO              AS string
	WSDATA   cTAMANHO                  AS string OPTIONAL
	WSDATA   cTIPO                     AS string
	WSDATA   cTITULO                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_INFCAMPOSADIC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_INFCAMPOSADIC
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_INFCAMPOSADIC
	Local oClone := TSSGNRE_INFCAMPOSADIC():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:cDECIMAL             := ::cDECIMAL
	oClone:cOBRIGATORIO         := ::cOBRIGATORIO
	oClone:cTAMANHO             := ::cTAMANHO
	oClone:cTIPO                := ::cTIPO
	oClone:cTITULO              := ::cTITULO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_INFCAMPOSADIC
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDECIMAL           :=  WSAdvValue( oResponse,"_DECIMAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOBRIGATORIO       :=  WSAdvValue( oResponse,"_OBRIGATORIO","string",NIL,"Property cOBRIGATORIO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTAMANHO           :=  WSAdvValue( oResponse,"_TAMANHO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTIPO              :=  WSAdvValue( oResponse,"_TIPO","string",NIL,"Property cTIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTITULO            :=  WSAdvValue( oResponse,"_TITULO","string",NIL,"Property cTITULO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure MONITORRETDOC

WSSTRUCT TSSGNRE_MONITORRETDOC
	WSDATA   cAMBIENTE                 AS string
	WSDATA   cCODBARRAS                AS string OPTIONAL
	WSDATA   cDESCRICAO                AS string OPTIONAL
	WSDATA   dDTENVSEF                 AS date OPTIONAL
	WSDATA   dDTENVTSS                 AS date
	WSDATA   dDTRECSEF                 AS date OPTIONAL
	WSDATA   cHRENVSEF                 AS string OPTIONAL
	WSDATA   cHRENVTSS                 AS string
	WSDATA   cHRRECSEF                 AS string OPTIONAL
	WSDATA   cID                       AS string
	WSDATA   cIDENT                    AS string
	WSDATA   cINFCOMPL                 AS base64Binary OPTIONAL
	WSDATA   cLINHADIGIT               AS string OPTIONAL
	WSDATA   cLOTE                     AS string OPTIONAL
	WSDATA   cNUMCONTRO                AS string OPTIONAL
	WSDATA   cPDFDUA                   AS string OPTIONAL
	WSDATA   cRECIBO                   AS string OPTIONAL
	WSDATA   cRESULTADO                AS string OPTIONAL
	WSDATA   cSTATUS                   AS string
	WSDATA   cXMLERRO                  AS base64Binary OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_MONITORRETDOC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_MONITORRETDOC
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_MONITORRETDOC
	Local oClone := TSSGNRE_MONITORRETDOC():NEW()
	oClone:cAMBIENTE            := ::cAMBIENTE
	oClone:cCODBARRAS           := ::cCODBARRAS
	oClone:cDESCRICAO           := ::cDESCRICAO
	oClone:dDTENVSEF            := ::dDTENVSEF
	oClone:dDTENVTSS            := ::dDTENVTSS
	oClone:dDTRECSEF            := ::dDTRECSEF
	oClone:cHRENVSEF            := ::cHRENVSEF
	oClone:cHRENVTSS            := ::cHRENVTSS
	oClone:cHRRECSEF            := ::cHRRECSEF
	oClone:cID                  := ::cID
	oClone:cIDENT               := ::cIDENT
	oClone:cINFCOMPL            := ::cINFCOMPL
	oClone:cLINHADIGIT          := ::cLINHADIGIT
	oClone:cLOTE                := ::cLOTE
	oClone:cNUMCONTRO           := ::cNUMCONTRO
	oClone:cPDFDUA              := ::cPDFDUA
	oClone:cRECIBO              := ::cRECIBO
	oClone:cRESULTADO           := ::cRESULTADO
	oClone:cSTATUS              := ::cSTATUS
	oClone:cXMLERRO             := ::cXMLERRO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_MONITORRETDOC
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAMBIENTE          :=  WSAdvValue( oResponse,"_AMBIENTE","string",NIL,"Property cAMBIENTE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODBARRAS         :=  WSAdvValue( oResponse,"_CODBARRAS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::dDTENVSEF          :=  WSAdvValue( oResponse,"_DTENVSEF","date",NIL,NIL,NIL,"D",NIL,NIL) 
	::dDTENVTSS          :=  WSAdvValue( oResponse,"_DTENVTSS","date",NIL,"Property dDTENVTSS as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::dDTRECSEF          :=  WSAdvValue( oResponse,"_DTRECSEF","date",NIL,NIL,NIL,"D",NIL,NIL) 
	::cHRENVSEF          :=  WSAdvValue( oResponse,"_HRENVSEF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cHRENVTSS          :=  WSAdvValue( oResponse,"_HRENVTSS","string",NIL,"Property cHRENVTSS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cHRRECSEF          :=  WSAdvValue( oResponse,"_HRRECSEF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cIDENT             :=  WSAdvValue( oResponse,"_IDENT","string",NIL,"Property cIDENT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cINFCOMPL          :=  WSAdvValue( oResponse,"_INFCOMPL","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
	::cLINHADIGIT        :=  WSAdvValue( oResponse,"_LINHADIGIT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cLOTE              :=  WSAdvValue( oResponse,"_LOTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNUMCONTRO         :=  WSAdvValue( oResponse,"_NUMCONTRO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPDFDUA            :=  WSAdvValue( oResponse,"_PDFDUA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRECIBO            :=  WSAdvValue( oResponse,"_RECIBO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRESULTADO         :=  WSAdvValue( oResponse,"_RESULTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSTATUS            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,"Property cSTATUS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cXMLERRO           :=  WSAdvValue( oResponse,"_XMLERRO","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
Return

// WSDL Data Structure RETORNAPDF

WSSTRUCT TSSGNRE_RETORNAPDF
	WSDATA   cAMBIENTE                 AS string
	WSDATA   cIDENT                    AS string
	WSDATA   cXML                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_RETORNAPDF
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_RETORNAPDF
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_RETORNAPDF
	Local oClone := TSSGNRE_RETORNAPDF():NEW()
	oClone:cAMBIENTE            := ::cAMBIENTE
	oClone:cIDENT               := ::cIDENT
	oClone:cXML                 := ::cXML
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_RETORNAPDF
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAMBIENTE          :=  WSAdvValue( oResponse,"_AMBIENTE","string",NIL,"Property cAMBIENTE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cIDENT             :=  WSAdvValue( oResponse,"_IDENT","string",NIL,"Property cIDENT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cXML               :=  WSAdvValue( oResponse,"_XML","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure REMESSADOCUMENTO

WSSTRUCT TSSGNRE_REMESSADOCUMENTO
	WSDATA   cID                       AS string
	WSDATA   cXML                      AS base64Binary
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_REMESSADOCUMENTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_REMESSADOCUMENTO
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_REMESSADOCUMENTO
	Local oClone := TSSGNRE_REMESSADOCUMENTO():NEW()
	oClone:cID                  := ::cID
	oClone:cXML                 := ::cXML
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSGNRE_REMESSADOCUMENTO
	Local cSoap := ""
	cSoap += WSSoapValue("ID", ::cID, ::cID , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("XML", ::cXML, ::cXML , "base64Binary", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure REMESSARETDOC

WSSTRUCT TSSGNRE_REMESSARETDOC
	WSDATA   cERRO                     AS string OPTIONAL
	WSDATA   cID                       AS string
	WSDATA   lSUCESSO                  AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_REMESSARETDOC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_REMESSARETDOC
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_REMESSARETDOC
	Local oClone := TSSGNRE_REMESSARETDOC():NEW()
	oClone:cERRO                := ::cERRO
	oClone:cID                  := ::cID
	oClone:lSUCESSO             := ::lSUCESSO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_REMESSARETDOC
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cERRO              :=  WSAdvValue( oResponse,"_ERRO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lSUCESSO           :=  WSAdvValue( oResponse,"_SUCESSO","boolean",NIL,"Property lSUCESSO as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
Return

// WSDL Data Structure RETORNARETDOC

WSSTRUCT TSSGNRE_RETORNARETDOC
	WSDATA   cAMBIENTE                 AS string
	WSDATA   cDESCRICAO                AS string OPTIONAL
	WSDATA   cDESCSEF                  AS string OPTIONAL
	WSDATA   dDTENVLOTE                AS date OPTIONAL
	WSDATA   dDTRECLOTE                AS date OPTIONAL
	WSDATA   cHRENVLOTE                AS string OPTIONAL
	WSDATA   cHRRECLOTE                AS string OPTIONAL
	WSDATA   cIDENT                    AS string
	WSDATA   cLOTE                     AS string OPTIONAL
	WSDATA   cRECIBO                   AS string OPTIONAL
	WSDATA   cRESULTSEF                AS string OPTIONAL
	WSDATA   cSTATSEF                  AS string OPTIONAL
	WSDATA   cSTATUS                   AS string OPTIONAL
	WSDATA   cXML                      AS base64Binary OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_RETORNARETDOC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_RETORNARETDOC
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_RETORNARETDOC
	Local oClone := TSSGNRE_RETORNARETDOC():NEW()
	oClone:cAMBIENTE            := ::cAMBIENTE
	oClone:cDESCRICAO           := ::cDESCRICAO
	oClone:cDESCSEF             := ::cDESCSEF
	oClone:dDTENVLOTE           := ::dDTENVLOTE
	oClone:dDTRECLOTE           := ::dDTRECLOTE
	oClone:cHRENVLOTE           := ::cHRENVLOTE
	oClone:cHRRECLOTE           := ::cHRRECLOTE
	oClone:cIDENT               := ::cIDENT
	oClone:cLOTE                := ::cLOTE
	oClone:cRECIBO              := ::cRECIBO
	oClone:cRESULTSEF           := ::cRESULTSEF
	oClone:cSTATSEF             := ::cSTATSEF
	oClone:cSTATUS              := ::cSTATUS
	oClone:cXML                 := ::cXML
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_RETORNARETDOC
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAMBIENTE          :=  WSAdvValue( oResponse,"_AMBIENTE","string",NIL,"Property cAMBIENTE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCSEF           :=  WSAdvValue( oResponse,"_DESCSEF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::dDTENVLOTE         :=  WSAdvValue( oResponse,"_DTENVLOTE","date",NIL,NIL,NIL,"D",NIL,NIL) 
	::dDTRECLOTE         :=  WSAdvValue( oResponse,"_DTRECLOTE","date",NIL,NIL,NIL,"D",NIL,NIL) 
	::cHRENVLOTE         :=  WSAdvValue( oResponse,"_HRENVLOTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cHRRECLOTE         :=  WSAdvValue( oResponse,"_HRRECLOTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cIDENT             :=  WSAdvValue( oResponse,"_IDENT","string",NIL,"Property cIDENT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cLOTE              :=  WSAdvValue( oResponse,"_LOTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRECIBO            :=  WSAdvValue( oResponse,"_RECIBO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRESULTSEF         :=  WSAdvValue( oResponse,"_RESULTSEF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSTATSEF           :=  WSAdvValue( oResponse,"_STATSEF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSTATUS            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cXML               :=  WSAdvValue( oResponse,"_XML","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
Return

// WSDL Data Structure SCHEMARETDOC

WSSTRUCT TSSGNRE_SCHEMARETDOC
	WSDATA   cID                       AS string
	WSDATA   cMSG                      AS string OPTIONAL
	WSDATA   lSUCESSO                  AS boolean
	WSDATA   cVERSAO                   AS string OPTIONAL
	WSDATA   cXML                      AS base64Binary OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSGNRE_SCHEMARETDOC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSGNRE_SCHEMARETDOC
Return

WSMETHOD CLONE WSCLIENT TSSGNRE_SCHEMARETDOC
	Local oClone := TSSGNRE_SCHEMARETDOC():NEW()
	oClone:cID                  := ::cID
	oClone:cMSG                 := ::cMSG
	oClone:lSUCESSO             := ::lSUCESSO
	oClone:cVERSAO              := ::cVERSAO
	oClone:cXML                 := ::cXML
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSGNRE_SCHEMARETDOC
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMSG               :=  WSAdvValue( oResponse,"_MSG","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lSUCESSO           :=  WSAdvValue( oResponse,"_SUCESSO","boolean",NIL,"Property lSUCESSO as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cVERSAO            :=  WSAdvValue( oResponse,"_VERSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cXML               :=  WSAdvValue( oResponse,"_XML","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
Return


