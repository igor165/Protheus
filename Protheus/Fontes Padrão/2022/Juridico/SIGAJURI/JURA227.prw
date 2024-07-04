#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "JURA227.CH"

/* ===============================================================================
WSDL Location    http://juridico.totvsbpo.com.br:8082/WSPUBLICACOES.apw?WSDL
Gerado em        08/30/16 07:33:27
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _SFXXLMB ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service JURA227
------------------------------------------------------------------------------- */

WSCLIENT JURA227

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD MTPUBLICACOES

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cUSUARIO                  AS string
	WSDATA   cSENHA                    AS string
	WSDATA   oWSMTPUBLICACOESRESULT    AS WSPUBLICACOES_ARRAYOFSTRUACESSOPUB

ENDWSCLIENT

WSMETHOD NEW WSCLIENT JURA227
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160606 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT JURA227
	::oWSMTPUBLICACOESRESULT := WSPUBLICACOES_ARRAYOFSTRUACESSOPUB():New()
Return

WSMETHOD RESET WSCLIENT JURA227
	::cUSUARIO           := NIL 
	::cSENHA             := NIL 
	::oWSMTPUBLICACOESRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT JURA227
Local oClone := JURA227():New()
	oClone:_URL          := ::_URL 
	oClone:cUSUARIO      := ::cUSUARIO
	oClone:cSENHA        := ::cSENHA
	oClone:oWSMTPUBLICACOESRESULT :=  IIF(::oWSMTPUBLICACOESRESULT = NIL , NIL ,::oWSMTPUBLICACOESRESULT:Clone() )
Return oClone

// WSDL Method MTPUBLICACOES of Service JURA227

WSMETHOD MTPUBLICACOES WSSEND cUSUARIO,cSENHA WSRECEIVE oWSMTPUBLICACOESRESULT WSCLIENT JURA227
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<MTPUBLICACOES xmlns="http://juridico.totvsbpo.com.br:8082/">'
cSoap += WSSoapValue("USUARIO", ::cUSUARIO, cUSUARIO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("SENHA", ::cSENHA, cSENHA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</MTPUBLICACOES>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://juridico.totvsbpo.com.br:8082/MTPUBLICACOES",; 
	"DOCUMENT","http://juridico.totvsbpo.com.br:8082/",,"1.031217",; 
	"http://juridico.totvsbpo.com.br:8082/WSPUBLICACOES.apw")

::Init()
::oWSMTPUBLICACOESRESULT:SoapRecv( WSAdvValue( oXmlRet,"_MTPUBLICACOESRESPONSE:_MTPUBLICACOESRESULT","ARRAYOFSTRUACESSOPUB",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ARRAYOFSTRUACESSOPUB

WSSTRUCT WSPUBLICACOES_ARRAYOFSTRUACESSOPUB
	WSDATA   oWSSTRUACESSOPUB          AS WSPUBLICACOES_STRUACESSOPUB OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSPUBLICACOES_ARRAYOFSTRUACESSOPUB
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSPUBLICACOES_ARRAYOFSTRUACESSOPUB
	::oWSSTRUACESSOPUB     := {} // Array Of  WSPUBLICACOES_STRUACESSOPUB():New()
Return

WSMETHOD CLONE WSCLIENT WSPUBLICACOES_ARRAYOFSTRUACESSOPUB
	Local oClone := WSPUBLICACOES_ARRAYOFSTRUACESSOPUB():NEW()
	oClone:oWSSTRUACESSOPUB := NIL
	If ::oWSSTRUACESSOPUB <> NIL 
		oClone:oWSSTRUACESSOPUB := {}
		aEval( ::oWSSTRUACESSOPUB , { |x| aadd( oClone:oWSSTRUACESSOPUB , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSPUBLICACOES_ARRAYOFSTRUACESSOPUB
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STRUACESSOPUB","STRUACESSOPUB",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSTRUACESSOPUB , WSPUBLICACOES_STRUACESSOPUB():New() )
			::oWSSTRUACESSOPUB[len(::oWSSTRUACESSOPUB)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure STRUACESSOPUB

WSSTRUCT WSPUBLICACOES_STRUACESSOPUB
	WSDATA   cCODGRUPO                 AS string
	WSDATA   cNOMERELACIONAL           AS string
	WSDATA   cTOKEN                    AS string
	WSDATA   cAGRUPADOR                AS string
	WSDATA   cURL                      AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSPUBLICACOES_STRUACESSOPUB
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSPUBLICACOES_STRUACESSOPUB
Return

WSMETHOD CLONE WSCLIENT WSPUBLICACOES_STRUACESSOPUB
	Local oClone := WSPUBLICACOES_STRUACESSOPUB():NEW()
	oClone:cCODGRUPO            := ::cCODGRUPO
	oClone:cNOMERELACIONAL      := ::cNOMERELACIONAL
	oClone:cTOKEN               := ::cTOKEN
	oClone:cAGRUPADOR	        := ::cAGRUPADOR
	oClone:cURL                 := ::cURL
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSPUBLICACOES_STRUACESSOPUB
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODGRUPO          :=  WSAdvValue( oResponse,"_CODGRUPO","string",NIL,"Property cCODGRUPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOMERELACIONAL    :=  WSAdvValue( oResponse,"_NOMERELACIONAL","string",NIL,"Property cNOMERELACIONAL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTOKEN             :=  WSAdvValue( oResponse,"_TOKEN","string",NIL,"Property cTOKEN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL)
	::cAGRUPADOR         :=  WSAdvValue( oResponse,"_AGRUPADOR","string",NIL,"Property cAGRUPADOR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cURL               :=  WSAdvValue( oResponse,"_URL","string",NIL,"Property cURL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} J227Captura
Função que conecta na totvs para receber as informações de publicações.

@param lBaixa indica se deve dar baixa após baixar sa publicações
@param cNomeRel Indica o nome que deve ser usado para baixar as publicações
@param cToken indica a senha que deve ser utilizada
@param cGrupo indica o código do grupo que deve ser utilizado
@param cData1 indica a data inicial de consulta
@param cData2 indica a data final de consulta
@param cUrl indica a url do serviço

@return oXml Retorna o objeto que manipula o xml de retorno recebido com as publicações
 
@author André Spirigoni Pinto
@since 29/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J227Captura(cNomeRel, cToken, cGrupo,cData1,cData2,cUrl,lEnvBaixa)
Local oRestClient := FWRest():New(cUrl)
Local aHeadOut := {}
Local oXml := TXmlManager():New()
Local lRet := ""
Local nI

Default lEnvBaixa := .F.

cXml := '<?xml version="1.0" encoding="UTF-8"?>'
cXml += '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="' + cUrl + '/recorte/webservice/personalizado/' + cNomeRel + '/webservice.php" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
cXml += '<SOAP-ENV:Body>'
cXml += '<ns1:getPublicacoesTodosComQuantidadeLimitada>'
cXml += '<param0 xsi:type="xsd:string">' + cNomeRel + '</param0>'
cXml += '<param1 xsi:type="xsd:string">' + cToken + '</param1>'
cXml += '<param2 xsi:type="xsd:string">' + cData1 + '</param2>'
cXml += '<param3 xsi:type="xsd:string">' + cData2 + '</param3>'
cXml += '<param4 xsi:type="xsd:string">' + IIF(lEnvBaixa,"1","0") + '</param4>'
cXml += '<param5 xsi:type="xsd:string">' + cGrupo + '</param5>'
cXml += '<param5 xsi:type="xsd:string">50</param5>'
cXml += '</ns1:getPublicacoesTodosComQuantidadeLimitada>'
cXml += '</SOAP-ENV:Body>'
cXml += '</SOAP-ENV:Envelope>'

aadd(aHeadOut,'User-Agent: Mozilla/5.0 (Compatible)')
aadd(aHeadOut,'Content-Type: text/xml; charset=utf-8')
aadd(aHeadOut,'Cache-Control: no-cache')

oRestClient:nTimeOut := 600
oRestClient:setPath("/recorte/webservice/personalizado/" + cNomeRel + "/webservice.php")
oRestClient:SetPostParams(cXml)

If oRestClient:Post(aHeadOut)
	lRet := oXML:Parse( oRestClient:GetResult() )
	
	if lRet == .F.
		JA215SetLog(STR0001 + oXML:Error(), cNomeRel, Time()) //"Erro no tratamento das publicações TOTVS: "
	    return Nil
	Else
		oXML:XPathRegisterNs( "ns1", (cUrl + "/recorte/webservice/personalizado/" + cNomeRel + "/webservice.php") )
		oXML:XPathRegisterNs( "SOAP-ENV", "http://schemas.xmlsoap.org/soap/envelope/" )
	endif  
   
Else
   JA215SetLog(STR0002 + oRestClient:GetLastError(), cNomeRel, Time()) //"Erro de conexão com as publicações TOTVS: "
   FwFreeObj(oRestClient)
   Return Nil //encerra a função
Endif

FwFreeObj(oRestClient)

Return oXml

//-------------------------------------------------------------------
/*/{Protheus.doc} J227AtuPub
Função que faz a baixa das publicações para não receber a mesma publicação mais de uma vez

@param cNomeRel Indica o nome que deve ser usado para baixar as publicações
@param cToken indica a senha que deve ser utilizada
@param cPublica indica o código da publicação que deve ser marcada
@param cUrl indica a url do serviço

@return lRet Retorna se as publicações foram baixadas com sucesso e se o processo deve continuar
 
@author André Spirigoni Pinto
@since 29/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J227AtuPub(cNomeRel, cToken, cPublica, cUrl)
Local oRestClient := FWRest():New(cUrl)
Local oXml := TXmlManager():New()
Local aHeadOut := {}
Local lRet := .F.

cXml := '<?xml version="1.0" encoding="UTF-8"?>'
cXml += '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="' + cUrl + '/recorte/webservice/personalizado/' + cNomeRel + '/webservice.php" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
cXml += '<SOAP-ENV:Body>'
cXml += '<ns1:setpublicacoes>'
cXml += '<param0 xsi:type="xsd:string">' + cNomeRel + '</param0>'
cXml += '<param1 xsi:type="xsd:string">' + cToken + '</param1>'
cXml += '<param2 xsi:type="xsd:string">' + cPublica + '</param2>'
cXml += '</ns1:setpublicacoes>'
cXml += '</SOAP-ENV:Body>'
cXml += '</SOAP-ENV:Envelope>'

aadd(aHeadOut,'User-Agent: Mozilla/5.0 (Compatible)')
aadd(aHeadOut,'Content-Type: text/xml; charset=utf-8')
aadd(aHeadOut,'Cache-Control: no-cache')

oRestClient:nTimeOut := 600
oRestClient:setPath("/recorte/webservice/personalizado/" + cNomeRel + "/webservice.php")
oRestClient:SetPostParams(cXml)

If oRestClient:Post(aHeadOut)
	lRet := oXML:Parse( oRestClient:GetResult() )
	
	if lRet == .F.
		JA215SetLog(STR0003 + oXML:Error(), cNomeRel, Time()) //"Erro ao dar baixa nas publicações TOTVS: "
	    return Nil
	Else
		oXML:XPathRegisterNs( "ns1", (cUrl + "/recorte/webservice/personalizado/" + cNomeRel + "/webservice.php") )
		oXML:XPathRegisterNs( "SOAP-ENV", "http://schemas.xmlsoap.org/soap/envelope/" )
	endif  
	
   lRet := (oXML:XPathGetNodeValue( "/SOAP-ENV:Envelope/SOAP-ENV:Body/ns1:setpublicacoesResponse/return/item/value/status")=="1")
Else
   Conout(STR0002 + oRestClient:GetLastError()) //"Erro de conexão com as publicações TOTVS: "
   oRestClient := Nil //encerra o componente
   lRet := .F.
Endif

FwFreeObj(oRestClient)
FwFreeObj(oXml)
oXML := NIl //libera objeto

Return lRet