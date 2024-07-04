#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://testewebserver.averba.com.br/index.soap?wsdl
Gerado em        09/26/17 10:08:54
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente. 
=============================================================================== */

User Function _IQMJZMZ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSATMWebSvr
------------------------------------------------------------------------------- */

WSCLIENT WSATMWebSvr

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD averbaCTe
	WSMETHOD averbaNFe
	WSMETHOD declaraMDFe
	WSMETHOD AddBackMail 

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cusuario                  AS string
	WSDATA   csenha                    AS string
	WSDATA   ccodatm                   AS string
	WSDATA   cxmlCTe                   AS string
	WSDATA   oWSaverbaCTeResponse      AS ATMWebSvr_Retorno
	WSDATA   cxmlNFe                   AS string
	WSDATA   oWSaverbaNFeResponse      AS ATMWebSvr_Retorno
	WSDATA   cxmlMDFe                  AS string
	WSDATA   oWSdeclaraMDFeResponse    AS ATMWebSvr_RetornoMDFe
	WSDATA   caplicacao                AS string
	WSDATA   cassunto                  AS string
	WSDATA   cremetentes               AS string
	WSDATA   cdestinatarios            AS string
	WSDATA   ccorpo                    AS string
	WSDATA   cchave                    AS string
	WSDATA   cchaveresp                AS string
	WSDATA   creturn                   AS string
	WSDATA   cLinkSoap                 AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSATMWebSvr
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20170221] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSATMWebSvr
	::oWSaverbaCTeResponse := ATMWebSvr_RETORNO():New()
	::oWSaverbaNFeResponse := ATMWebSvr_RETORNO():New()
	::oWSdeclaraMDFeResponse := ATMWebSvr_RETORNOMDFE():New()
Return

WSMETHOD RESET WSCLIENT WSATMWebSvr
	::cusuario           := NIL 
	::csenha             := NIL 
	::ccodatm            := NIL 
	::cxmlCTe            := NIL 
	::oWSaverbaCTeResponse := NIL 
	::cxmlNFe            := NIL 
	::oWSaverbaNFeResponse := NIL 
	::cxmlMDFe           := NIL 
	::oWSdeclaraMDFeResponse := NIL 
	::caplicacao         := NIL 
	::cassunto           := NIL 
	::cremetentes        := NIL 
	::cdestinatarios     := NIL 
	::ccorpo             := NIL 
	::cchave             := NIL 
	::cchaveresp         := NIL 
	::creturn            := NIL 
	::cLinkSoap          := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSATMWebSvr
Local oClone := WSATMWebSvr():New()
	oClone:_URL          := ::_URL 
	oClone:cusuario      := ::cusuario
	oClone:csenha        := ::csenha
	oClone:ccodatm       := ::ccodatm
	oClone:cxmlCTe       := ::cxmlCTe
	oClone:oWSaverbaCTeResponse :=  IIF(::oWSaverbaCTeResponse = NIL , NIL ,::oWSaverbaCTeResponse:Clone() )
	oClone:cxmlNFe       := ::cxmlNFe
	oClone:oWSaverbaNFeResponse :=  IIF(::oWSaverbaNFeResponse = NIL , NIL ,::oWSaverbaNFeResponse:Clone() )
	oClone:cxmlMDFe      := ::cxmlMDFe
	oClone:oWSdeclaraMDFeResponse :=  IIF(::oWSdeclaraMDFeResponse = NIL , NIL ,::oWSdeclaraMDFeResponse:Clone() )
	oClone:caplicacao    := ::caplicacao
	oClone:cassunto      := ::cassunto
	oClone:cremetentes   := ::cremetentes
	oClone:cdestinatarios := ::cdestinatarios
	oClone:ccorpo        := ::ccorpo
	oClone:cchave        := ::cchave
	oClone:cchaveresp    := ::cchaveresp
	oClone:creturn       := ::creturn
	oClone:cLinkSoap     := ::cLinkSoap
Return oClone

// WSDL Method averbaCTe of Service WSATMWebSvr

WSMETHOD averbaCTe WSSEND cusuario,csenha,ccodatm,cxmlCTe WSRECEIVE oWSaverbaCTeResponse WSCLIENT WSATMWebSvr
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:averbaCTe xmlns:q1="urn:ATMWebSvr">'
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codatm", ::ccodatm, ccodatm , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xmlCTe", ::cxmlCTe, cxmlCTe , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:averbaCTe>"

If FindFunction("ObjSelf")
	oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
		"urn:ATMWebSvr#averbaCTe",; 
		"RPCX","urn:ATMWebSvr",,,; 
		::cLinkSoap)

Else 
	oXmlRet := SvcSoapCall(	Self,cSoap,; 
		"urn:ATMWebSvr#averbaCTe",; 
		"RPCX","urn:ATMWebSvr",,,; 
		::cLinkSoap)
EndIf 
::Init()
::oWSaverbaCTeResponse:SoapRecv( WSAdvValue( oXmlRet,"_RESPONSE","Retorno",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method averbaNFe of Service WSATMWebSvr

WSMETHOD averbaNFe WSSEND cusuario,csenha,ccodatm,cxmlNFe WSRECEIVE oWSaverbaNFeResponse WSCLIENT WSATMWebSvr
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:averbaNFe xmlns:q1="urn:ATMWebSvr">'
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codatm", ::ccodatm, ccodatm , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xmlNFe", ::cxmlNFe, cxmlNFe , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:averbaNFe>"

If FindFunction("ObjSelf")
	oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
		"urn:ATMWebSvr#averbaNFe",; 
		"RPCX","urn:ATMWebSvr",,,; 
		::cLinkSoap)

Else
	oXmlRet := SvcSoapCall(	Self,cSoap,; 
		"urn:ATMWebSvr#averbaNFe",; 
		"RPCX","urn:ATMWebSvr",,,; 
		::cLinkSoap)
EndIf 

::Init()
::oWSaverbaNFeResponse:SoapRecv( WSAdvValue( oXmlRet,"_RESPONSE","Retorno",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method declaraMDFe of Service WSATMWebSvr

WSMETHOD declaraMDFe WSSEND cusuario,csenha,ccodatm,cxmlMDFe WSRECEIVE oWSdeclaraMDFeResponse WSCLIENT WSATMWebSvr
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:declaraMDFe xmlns:q1="urn:ATMWebSvr">'
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codatm", ::ccodatm, ccodatm , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xmlMDFe", ::cxmlMDFe, cxmlMDFe , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:declaraMDFe>"

If FindFunction("ObjSelf")
	oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
		"urn:ATMWebSvr#declaraMDFe",; 
		"RPCX","urn:ATMWebSvr",,,; 
		::cLinkSoap)

Else 
	oXmlRet := SvcSoapCall(	Self,cSoap,; 
		"urn:ATMWebSvr#declaraMDFe",; 
		"RPCX","urn:ATMWebSvr",,,; 
		::cLinkSoap)

EndIf 

::Init()
::oWSdeclaraMDFeResponse:SoapRecv( WSAdvValue( oXmlRet,"_RESPONSE","RetornoMDFe",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AddBackMail of Service WSATMWebSvr

WSMETHOD AddBackMail WSSEND cusuario,csenha,ccodatm,caplicacao,cassunto,cremetentes,cdestinatarios,ccorpo,cchave,cchaveresp WSRECEIVE creturn WSCLIENT WSATMWebSvr
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:AddBackMail xmlns:q1="urn:ATMWebSvr">'
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codatm", ::ccodatm, ccodatm , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("aplicacao", ::caplicacao, caplicacao , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("assunto", ::cassunto, cassunto , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("remetentes", ::cremetentes, cremetentes , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("destinatarios", ::cdestinatarios, cdestinatarios , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("corpo", ::ccorpo, ccorpo , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("chave", ::cchave, cchave , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("chaveresp", ::cchaveresp, cchaveresp , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:AddBackMail>"

If FindFunction("ObjSelf")
	oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
		"urn:ATMWebSvr#AddBackMail",; 
		"RPCX","urn:ATMWebSvr",,,; 
		::cLinkSoap)
Else 
	oXmlRet := SvcSoapCall(	Self,cSoap,; 
		"urn:ATMWebSvr#AddBackMail",; 
		"RPCX","urn:ATMWebSvr",,,; 
		::cLinkSoap)
EndIf 

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure Retorno

WSSTRUCT ATMWebSvr_Retorno
	WSDATA   cNumero                   AS string
	WSDATA   cSerie                    AS string
	WSDATA   cFil                      AS string
	WSDATA   cCNPJCli                  AS string OPTIONAL
	WSDATA   nTpDoc                    AS integer OPTIONAL
	WSDATA   cInfAdic                  AS string OPTIONAL
	WSDATA   oWSErros                  AS ATMWebSvr_ErrosProcesso OPTIONAL
	WSDATA   oWSAverbado               AS ATMWebSvr_SuccessProcesso OPTIONAL
	WSDATA   oWSInfos                  AS ATMWebSvr_InfosProcesso OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ATMWebSvr_Retorno
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ATMWebSvr_Retorno
Return

WSMETHOD CLONE WSCLIENT ATMWebSvr_Retorno
	Local oClone := ATMWebSvr_Retorno():NEW()
	oClone:cNumero              := ::cNumero
	oClone:cSerie               := ::cSerie
	oClone:cFil              := ::cFil
	oClone:cCNPJCli             := ::cCNPJCli
	oClone:nTpDoc               := ::nTpDoc
	oClone:cInfAdic             := ::cInfAdic
	oClone:oWSErros             := IIF(::oWSErros = NIL , NIL , ::oWSErros:Clone() )
	oClone:oWSAverbado          := IIF(::oWSAverbado = NIL , NIL , ::oWSAverbado:Clone() )
	oClone:oWSInfos             := IIF(::oWSInfos = NIL , NIL , ::oWSInfos:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ATMWebSvr_Retorno
	Local oNode7
	Local oNode8
	Local oNode9
	::Init()
	If oResponse = NIL ; Return ; Endif 

	::cNumero            :=  WSAdvValue( oResponse,"_NUMERO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSerie             :=  WSAdvValue( oResponse,"_SERIE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cFil            :=  WSAdvValue( oResponse,"_FILIAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCNPJCli           :=  WSAdvValue( oResponse,"_CNPJCLI","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nTpDoc             :=  WSAdvValue( oResponse,"_TPDOC","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::cInfAdic           :=  WSAdvValue( oResponse,"_INFADIC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode7 :=  WSAdvValue( oResponse,"_ERROS","ErrosProcesso",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode7 != NIL
		::oWSErros := ATMWebSvr_ErrosProcesso():New()
		::oWSErros:SoapRecv(oNode7)
	EndIf
	oNode8 :=  WSAdvValue( oResponse,"_AVERBADO","SuccessProcesso",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode8 != NIL
		::oWSAverbado := ATMWebSvr_SuccessProcesso():New()
		::oWSAverbado:SoapRecv(oNode8)
	EndIf
	oNode9 :=  WSAdvValue( oResponse,"_INFOS","InfosProcesso",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode9 != NIL
		::oWSInfos := ATMWebSvr_InfosProcesso():New()
		::oWSInfos:SoapRecv(oNode9)
	EndIf
Return

// WSDL Data Structure ErrosProcesso

WSSTRUCT ATMWebSvr_ErrosProcesso
	WSDATA   oWSErro                   AS ATMWebSvr_ErroProcesso
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ATMWebSvr_ErrosProcesso
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ATMWebSvr_ErrosProcesso
	::oWSErro              := {} // Array Of  ATMWebSvr_ERROPROCESSO():New()
Return

WSMETHOD CLONE WSCLIENT ATMWebSvr_ErrosProcesso
	Local oClone := ATMWebSvr_ErrosProcesso():NEW()
	oClone:oWSErro := NIL
	If ::oWSErro <> NIL 
		oClone:oWSErro := {}
		aEval( ::oWSErro , { |x| aadd( oClone:oWSErro , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ATMWebSvr_ErrosProcesso
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	If nTElem1 = 0 ; UserException("WSCERR015 / Node Erro as tns:ErroProcesso on SOAP Response not found.") ; Endif 
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSErro , ATMWebSvr_ErroProcesso():New() )
  			::oWSErro[len(::oWSErro)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure SuccessProcesso

WSSTRUCT ATMWebSvr_SuccessProcesso
	WSDATA   cdhAverbacao              AS dateTime
	WSDATA   cProtocolo                AS string
	WSDATA   oWSDadosSeguro            AS ATMWebSvr_DadosSeguro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ATMWebSvr_SuccessProcesso
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ATMWebSvr_SuccessProcesso
	::oWSDadosSeguro       := {} // Array Of  ATMWebSvr_DADOSSEGURO():New()
Return

WSMETHOD CLONE WSCLIENT ATMWebSvr_SuccessProcesso
	Local oClone := ATMWebSvr_SuccessProcesso():NEW()
	oClone:cdhAverbacao         := ::cdhAverbacao
	oClone:cProtocolo           := ::cProtocolo
	oClone:oWSDadosSeguro := NIL
	If ::oWSDadosSeguro <> NIL 
		oClone:oWSDadosSeguro := {}
		aEval( ::oWSDadosSeguro , { |x| aadd( oClone:oWSDadosSeguro , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ATMWebSvr_SuccessProcesso
	Local nRElem3 , nTElem3
	Local aNodes3 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cdhAverbacao       :=  WSAdvValue( oResponse,"_DHAVERBACAO","dateTime",NIL,"Property cdhAverbacao as xsd:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cProtocolo         :=  WSAdvValue( oResponse,"_PROTOCOLO","string",NIL,"Property cProtocolo as xsd:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	nTElem3 := len(aNodes3)
	For nRElem3 := 1 to nTElem3 
		If !WSIsNilNode( aNodes3[nRElem3] )
			aadd(::oWSDadosSeguro , ATMWebSvr_DadosSeguro():New() )
  			::oWSDadosSeguro[len(::oWSDadosSeguro)]:SoapRecv(aNodes3[nRElem3])
		Endif
	Next
Return

// WSDL Data Structure InfosProcesso

WSSTRUCT ATMWebSvr_InfosProcesso
	WSDATA   oWSInfo                   AS ATMWebSvr_InfoProcesso
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ATMWebSvr_InfosProcesso
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ATMWebSvr_InfosProcesso
	::oWSInfo              := {} // Array Of  ATMWebSvr_INFOPROCESSO():New()
Return

WSMETHOD CLONE WSCLIENT ATMWebSvr_InfosProcesso
	Local oClone := ATMWebSvr_InfosProcesso():NEW()
	oClone:oWSInfo := NIL
	If ::oWSInfo <> NIL 
		oClone:oWSInfo := {}
		aEval( ::oWSInfo , { |x| aadd( oClone:oWSInfo , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ATMWebSvr_InfosProcesso
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	If nTElem1 = 0 ; UserException("WSCERR015 / Node Info as tns:InfoProcesso on SOAP Response not found.") ; Endif 
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSInfo , ATMWebSvr_InfoProcesso():New() )
  			::oWSInfo[len(::oWSInfo)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure RetornoMDFe

WSSTRUCT ATMWebSvr_RetornoMDFe
	WSDATA   cNumero                   AS string
	WSDATA   cSerie                    AS string
	WSDATA   cFil                      AS string
	WSDATA   oWSErros                  AS ATMWebSvr_ErrosProcesso OPTIONAL
	WSDATA   oWSDeclarado              AS ATMWebSvr_SuccessProcessoMDFe OPTIONAL
	WSDATA   oWSInfos                  AS ATMWebSvr_InfosProcesso OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ATMWebSvr_RetornoMDFe
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ATMWebSvr_RetornoMDFe
Return

WSMETHOD CLONE WSCLIENT ATMWebSvr_RetornoMDFe
	Local oClone := ATMWebSvr_RetornoMDFe():NEW()
	oClone:cNumero              := ::cNumero
	oClone:cSerie               := ::cSerie
	oClone:cFil              := ::cFil
	oClone:oWSErros             := IIF(::oWSErros = NIL , NIL , ::oWSErros:Clone() )
	oClone:oWSDeclarado         := IIF(::oWSDeclarado = NIL , NIL , ::oWSDeclarado:Clone() )
	oClone:oWSInfos             := IIF(::oWSInfos = NIL , NIL , ::oWSInfos:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ATMWebSvr_RetornoMDFe
	Local oNode4
	Local oNode5
	Local oNode6
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cNumero            :=  WSAdvValue( oResponse,"_NUMERO","string",NIL,"Property cNumero as xsd:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSerie             :=  WSAdvValue( oResponse,"_SERIE","string",NIL,"Property cSerie as xsd:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFil            :=  WSAdvValue( oResponse,"_FILIAL","string",NIL,"Property cFil as xsd:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	oNode4 :=  WSAdvValue( oResponse,"_ERROS","ErrosProcesso",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode4 != NIL
		::oWSErros := ATMWebSvr_ErrosProcesso():New()
		::oWSErros:SoapRecv(oNode4)
	EndIf
	oNode5 :=  WSAdvValue( oResponse,"_DECLARADO","SuccessProcessoMDFe",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSDeclarado := ATMWebSvr_SuccessProcessoMDFe():New()
		::oWSDeclarado:SoapRecv(oNode5)
	EndIf
	oNode6 :=  WSAdvValue( oResponse,"_INFOS","InfosProcesso",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode6 != NIL
		::oWSInfos := ATMWebSvr_InfosProcesso():New()
		::oWSInfos:SoapRecv(oNode6)
	EndIf
Return

// WSDL Data Structure SuccessProcessoMDFe

WSSTRUCT ATMWebSvr_SuccessProcessoMDFe
	WSDATA   cdhChancela               AS dateTime
	WSDATA   cProtocolo                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ATMWebSvr_SuccessProcessoMDFe
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ATMWebSvr_SuccessProcessoMDFe
Return

WSMETHOD CLONE WSCLIENT ATMWebSvr_SuccessProcessoMDFe
	Local oClone := ATMWebSvr_SuccessProcessoMDFe():NEW()
	oClone:cdhChancela          := ::cdhChancela
	oClone:cProtocolo           := ::cProtocolo
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ATMWebSvr_SuccessProcessoMDFe
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cdhChancela        :=  WSAdvValue( oResponse,"_DHCHANCELA","dateTime",NIL,"Property cdhChancela as xsd:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cProtocolo         :=  WSAdvValue( oResponse,"_PROTOCOLO","string",NIL,"Property cProtocolo as xsd:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ErroProcesso

WSSTRUCT ATMWebSvr_ErroProcesso
	WSDATA   cCodigo                   AS string
	WSDATA   cDescricao                AS string
	WSDATA   cValorEsperado            AS string OPTIONAL
	WSDATA   cValorInformado           AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ATMWebSvr_ErroProcesso
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ATMWebSvr_ErroProcesso
Return

WSMETHOD CLONE WSCLIENT ATMWebSvr_ErroProcesso
	Local oClone := ATMWebSvr_ErroProcesso():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:cDescricao           := ::cDescricao
	oClone:cValorEsperado       := ::cValorEsperado
	oClone:cValorInformado      := ::cValorInformado
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ATMWebSvr_ErroProcesso
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCodigo as xsd:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDescricao as xsd:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cValorEsperado     :=  WSAdvValue( oResponse,"_VALORESPERADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValorInformado    :=  WSAdvValue( oResponse,"_VALORINFORMADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure DadosSeguro

WSSTRUCT ATMWebSvr_DadosSeguro
	WSDATA   cNumeroAverbacao          AS string
	WSDATA   cCNPJSeguradora           AS string OPTIONAL
	WSDATA   cNomeSeguradora           AS string OPTIONAL
	WSDATA   cNumApolice               AS string OPTIONAL
	WSDATA   cTpMov                    AS string OPTIONAL
	WSDATA   cTpDDR                    AS string OPTIONAL
	WSDATA   cValorAverbado            AS string OPTIONAL
	WSDATA   cRamoAverbado             AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ATMWebSvr_DadosSeguro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ATMWebSvr_DadosSeguro
Return

WSMETHOD CLONE WSCLIENT ATMWebSvr_DadosSeguro
	Local oClone := ATMWebSvr_DadosSeguro():NEW()
	oClone:cNumeroAverbacao     := ::cNumeroAverbacao
	oClone:cCNPJSeguradora      := ::cCNPJSeguradora
	oClone:cNomeSeguradora      := ::cNomeSeguradora
	oClone:cNumApolice          := ::cNumApolice
	oClone:cTpMov               := ::cTpMov
	oClone:cTpDDR               := ::cTpDDR
	oClone:cValorAverbado       := ::cValorAverbado
	oClone:cRamoAverbado        := ::cRamoAverbado
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ATMWebSvr_DadosSeguro
	::Init()
	If oResponse = NIL ; Return ; Endif 

	::cNumeroAverbacao   :=  WSAdvValue( oResponse,"_NUMEROAVERBACAO","string",NIL,NIL,NIL,"S",NIL,NIL)	
	::cCNPJSeguradora    :=  WSAdvValue( oResponse,"_CNPJSEGURADORA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNomeSeguradora    :=  WSAdvValue( oResponse,"_NOMESEGURADORA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNumApolice        :=  WSAdvValue( oResponse,"_NUMAPOLICE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTpMov             :=  WSAdvValue( oResponse,"_TPMOV","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTpDDR             :=  WSAdvValue( oResponse,"_TPDDR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValorAverbado     :=  WSAdvValue( oResponse,"_VALORAVERBADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRamoAverbado      :=  WSAdvValue( oResponse,"_RAMOAVERBADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure InfoProcesso

WSSTRUCT ATMWebSvr_InfoProcesso
	WSDATA   cCodigo                   AS string
	WSDATA   cDescricao                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ATMWebSvr_InfoProcesso
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ATMWebSvr_InfoProcesso
Return

WSMETHOD CLONE WSCLIENT ATMWebSvr_InfoProcesso
	Local oClone := ATMWebSvr_InfoProcesso():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:cDescricao           := ::cDescricao
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ATMWebSvr_InfoProcesso
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCodigo as xsd:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDescricao as xsd:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


