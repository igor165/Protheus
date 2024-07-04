#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://homologacao.ikeda.com.br/totvs/ikcwebservice/fabricante.asmx?WSDL
Gerado em        12/20/12 09:42:51
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _OPBKAMX ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSFabricante
------------------------------------------------------------------------------- */

WSCLIENT WSFabricante

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Salvar
	WSMETHOD Excluir
	WSMETHOD Listar

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   nLojaCodigo               AS int
	WSDATA   cCodigoInternoFabricante  AS string
	WSDATA   cNomeFabricante           AS string
	WSDATA   nFabricanteStatus         AS int
	WSDATA   cA1                       AS string
	WSDATA   cA2                       AS string
	WSDATA   oWS                       AS SCHEMA
	WSDATA   oWSSalvarResult           AS Fabricante_clsRetornoOfclsFabricante
	WSDATA   oWSExcluirResult          AS Fabricante_clsRetornoOfclsFabricante
	WSDATA   oWSListarResult           AS Fabricante_clsRetornoOfclsFabricante

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSFabricante
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.120420A-20120726] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
If val(right(GetWSCVer(),8)) < 1.040504
	UserException("O Código-Fonte Client atual requer a versão de Lib para WebServices igual ou superior a ADVPL WSDL Client 1.040504. Atualize o repositório ou gere o Código-Fonte novamente utilizando o repositório atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSFabricante
	::oWS                := NIL 
	::oWSSalvarResult    := Fabricante_CLSRETORNOOFCLSFABRICANTE():New()
	::oWSExcluirResult   := Fabricante_CLSRETORNOOFCLSFABRICANTE():New()
	::oWSListarResult    := Fabricante_CLSRETORNOOFCLSFABRICANTE():New()
Return

WSMETHOD RESET WSCLIENT WSFabricante
	::nLojaCodigo        := NIL 
	::cCodigoInternoFabricante := NIL 
	::cNomeFabricante    := NIL 
	::nFabricanteStatus  := NIL 
	::cA1                := NIL 
	::cA2                := NIL 
	::oWS                := NIL 
	::oWSSalvarResult    := NIL 
	::oWSExcluirResult   := NIL 
	::oWSListarResult    := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSFabricante
Local oClone := WSFabricante():New()
	oClone:_URL          := ::_URL 
	oClone:nLojaCodigo   := ::nLojaCodigo
	oClone:cCodigoInternoFabricante := ::cCodigoInternoFabricante
	oClone:cNomeFabricante := ::cNomeFabricante
	oClone:nFabricanteStatus := ::nFabricanteStatus
	oClone:cA1           := ::cA1
	oClone:cA2           := ::cA2
	oClone:oWSSalvarResult :=  IIF(::oWSSalvarResult = NIL , NIL ,::oWSSalvarResult:Clone() )
	oClone:oWSExcluirResult :=  IIF(::oWSExcluirResult = NIL , NIL ,::oWSExcluirResult:Clone() )
	oClone:oWSListarResult :=  IIF(::oWSListarResult = NIL , NIL ,::oWSListarResult:Clone() )
Return oClone

// WSDL Method Salvar of Service WSFabricante

WSMETHOD Salvar WSSEND nLojaCodigo,cCodigoInternoFabricante,cNomeFabricante,nFabricanteStatus,cA1,cA2,oWS WSRECEIVE oWSSalvarResult WSCLIENT WSFabricante
Local cSoap := "" , oXmlRet
Local cSoapHead := "" 

BEGIN WSMETHOD

cSoapHead += '<clsSoapHeader xmlns="http://www.ikeda.com.br">'
cSoapHead += WSSoapValue("A1", ::cA1, cA1 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("A2", ::cA2, cA2 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("", ::oWS, oWS , "SCHEMA", .F. , .F., 0 , NIL, .F.) 
cSoapHead +=  "</clsSoapHeader>"

cSoap += '<Salvar xmlns="http://www.ikeda.com.br">'
cSoap += WSSoapValue("LojaCodigo", ::nLojaCodigo, nLojaCodigo , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoInternoFabricante", ::cCodigoInternoFabricante, cCodigoInternoFabricante , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NomeFabricante", ::cNomeFabricante, cNomeFabricante , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FabricanteStatus", ::nFabricanteStatus, nFabricanteStatus , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += "</Salvar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Salvar",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/fabricante.asmx")

::Init()
::oWSSalvarResult:SoapRecv( WSAdvValue( oXmlRet,"_SALVARRESPONSE:_SALVARRESULT","clsRetornoOfclsFabricante",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Excluir of Service WSFabricante

WSMETHOD Excluir WSSEND nLojaCodigo,cCodigoInternoFabricante,cA1,cA2,oWS WSRECEIVE oWSExcluirResult WSCLIENT WSFabricante
Local cSoap := "" , oXmlRet
Local cSoapHead := "" 

BEGIN WSMETHOD

cSoapHead += '<clsSoapHeader xmlns="http://www.ikeda.com.br">'
cSoapHead += WSSoapValue("A1", ::cA1, cA1 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("A2", ::cA2, cA2 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("", ::oWS, oWS , "SCHEMA", .F. , .F., 0 , NIL, .F.) 
cSoapHead +=  "</clsSoapHeader>"

cSoap += '<Excluir xmlns="http://www.ikeda.com.br">'
cSoap += WSSoapValue("LojaCodigo", ::nLojaCodigo, nLojaCodigo , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoInternoFabricante", ::cCodigoInternoFabricante, cCodigoInternoFabricante , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Excluir>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Excluir",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/fabricante.asmx")

::Init()
::oWSExcluirResult:SoapRecv( WSAdvValue( oXmlRet,"_EXCLUIRRESPONSE:_EXCLUIRRESULT","clsRetornoOfclsFabricante",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Listar of Service WSFabricante

WSMETHOD Listar WSSEND nLojaCodigo,cCodigoInternoFabricante,cA1,cA2,oWS WSRECEIVE oWSListarResult WSCLIENT WSFabricante
Local cSoap := "" , oXmlRet
Local cSoapHead := "" 

BEGIN WSMETHOD

cSoapHead += '<clsSoapHeader xmlns="http://www.ikeda.com.br">'
cSoapHead += WSSoapValue("A1", ::cA1, cA1 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("A2", ::cA2, cA2 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("", ::oWS, oWS , "SCHEMA", .F. , .F., 0 , NIL, .F.) 
cSoapHead +=  "</clsSoapHeader>"

cSoap += '<Listar xmlns="http://www.ikeda.com.br">'
cSoap += WSSoapValue("LojaCodigo", ::nLojaCodigo, nLojaCodigo , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoInternoFabricante", ::cCodigoInternoFabricante, cCodigoInternoFabricante , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Listar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Listar",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/fabricante.asmx")

::Init()
::oWSListarResult:SoapRecv( WSAdvValue( oXmlRet,"_LISTARRESPONSE:_LISTARRESULT","clsRetornoOfclsFabricante",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure clsRetornoOfclsFabricante

WSSTRUCT Fabricante_clsRetornoOfclsFabricante
	WSDATA   cAcao                     AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   nCodigo                   AS int
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   oWSLista                  AS Fabricante_ArrayOfClsFabricante OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Fabricante_clsRetornoOfclsFabricante
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Fabricante_clsRetornoOfclsFabricante
Return

WSMETHOD CLONE WSCLIENT Fabricante_clsRetornoOfclsFabricante
	Local oClone := Fabricante_clsRetornoOfclsFabricante():NEW()
	oClone:cAcao                := ::cAcao
	oClone:cData                := ::cData
	oClone:nCodigo              := ::nCodigo
	oClone:cDescricao           := ::cDescricao
	oClone:oWSLista             := IIF(::oWSLista = NIL , NIL , ::oWSLista:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Fabricante_clsRetornoOfclsFabricante
	Local oNode5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAcao              :=  WSAdvValue( oResponse,"_ACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nCodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,"Property nCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode5 :=  WSAdvValue( oResponse,"_LISTA","ArrayOfClsFabricante",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSLista := Fabricante_ArrayOfClsFabricante():New()
		::oWSLista:SoapRecv(oNode5)
	EndIf
Return

// WSDL Data Structure ArrayOfClsFabricante

WSSTRUCT Fabricante_ArrayOfClsFabricante
	WSDATA   oWSclsFabricante          AS Fabricante_clsFabricante OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Fabricante_ArrayOfClsFabricante
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Fabricante_ArrayOfClsFabricante
	::oWSclsFabricante     := {} // Array Of  Fabricante_CLSFABRICANTE():New()
Return

WSMETHOD CLONE WSCLIENT Fabricante_ArrayOfClsFabricante
	Local oClone := Fabricante_ArrayOfClsFabricante():NEW()
	oClone:oWSclsFabricante := NIL
	If ::oWSclsFabricante <> NIL 
		oClone:oWSclsFabricante := {}
		aEval( ::oWSclsFabricante , { |x| aadd( oClone:oWSclsFabricante , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Fabricante_ArrayOfClsFabricante
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLSFABRICANTE","clsFabricante",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclsFabricante , Fabricante_clsFabricante():New() )
			::oWSclsFabricante[len(::oWSclsFabricante)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure clsFabricante

WSSTRUCT Fabricante_clsFabricante
	WSDATA   nLojaCodigo               AS int
	WSDATA   cCodigoInterno            AS string OPTIONAL
	WSDATA   oWSFabricanteStatus       AS Fabricante_FabricanteStatus
	WSDATA   cNome                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Fabricante_clsFabricante
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Fabricante_clsFabricante
Return

WSMETHOD CLONE WSCLIENT Fabricante_clsFabricante
	Local oClone := Fabricante_clsFabricante():NEW()
	oClone:nLojaCodigo          := ::nLojaCodigo
	oClone:cCodigoInterno       := ::cCodigoInterno
	oClone:oWSFabricanteStatus  := IIF(::oWSFabricanteStatus = NIL , NIL , ::oWSFabricanteStatus:Clone() )
	oClone:cNome                := ::cNome
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Fabricante_clsFabricante
	Local oNode3
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nLojaCodigo        :=  WSAdvValue( oResponse,"_LOJACODIGO","int",NIL,"Property nLojaCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCodigoInterno     :=  WSAdvValue( oResponse,"_CODIGOINTERNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode3 :=  WSAdvValue( oResponse,"_FABRICANTESTATUS","FabricanteStatus",NIL,"Property oWSFabricanteStatus as tns:FabricanteStatus on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode3 != NIL
		::oWSFabricanteStatus := Fabricante_FabricanteStatus():New()
		::oWSFabricanteStatus:SoapRecv(oNode3)
	EndIf
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Enumeration FabricanteStatus

WSSTRUCT Fabricante_FabricanteStatus
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Fabricante_FabricanteStatus
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Nenhum" )
	aadd(::aValueList , "Ativo" )
	aadd(::aValueList , "Inativo" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Fabricante_FabricanteStatus
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Fabricante_FabricanteStatus
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Fabricante_FabricanteStatus
Local oClone := Fabricante_FabricanteStatus():New()
	oClone:Value := ::Value
Return oClone