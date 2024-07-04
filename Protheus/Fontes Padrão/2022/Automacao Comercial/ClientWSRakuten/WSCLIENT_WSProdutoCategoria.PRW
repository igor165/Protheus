#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://homologacao.ikeda.com.br/totvs/ikcwebservice/ProdutoCategoria.asmx?wsdl
Gerado em        02/01/13 15:58:21
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.111215
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _LDRNOXB ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSProdutoCategoria
------------------------------------------------------------------------------- */

WSCLIENT WSProdutoCategoria

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Salvar
	WSMETHOD Excluir

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   nLojaCodigo               AS int
	WSDATA   cCodigoInternoProduto     AS string
	WSDATA   cCodigoInternoCategoria   AS string
	WSDATA   cA1                       AS string
	WSDATA   cA2                       AS string
	WSDATA   oWS                       AS SCHEMA
	WSDATA   oWSSalvarResult           AS ProdutoCategoria_clsRetornoOfclsProdutoCategoria
	WSDATA   oWSExcluirResult          AS ProdutoCategoria_clsRetornoOfclsProdutoCategoria

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSProdutoCategoria
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.111010P-20120314] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
If val(right(GetWSCVer(),8)) < 1.040504
	UserException("O Código-Fonte Client atual requer a versão de Lib para WebServices igual ou superior a ADVPL WSDL Client 1.040504. Atualize o repositório ou gere o Código-Fonte novamente utilizando o repositório atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSProdutoCategoria
	::oWS                := NIL 
	::oWSSalvarResult    := ProdutoCategoria_CLSRETORNOOFCLSPRODUTOCATEGORIA():New()
	::oWSExcluirResult   := ProdutoCategoria_CLSRETORNOOFCLSPRODUTOCATEGORIA():New()
Return

WSMETHOD RESET WSCLIENT WSProdutoCategoria
	::nLojaCodigo        := NIL 
	::cCodigoInternoProduto := NIL 
	::cCodigoInternoCategoria := NIL 
	::cA1                := NIL 
	::cA2                := NIL 
	::oWS                := NIL 
	::oWSSalvarResult    := NIL 
	::oWSExcluirResult   := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSProdutoCategoria
Local oClone := WSProdutoCategoria():New()
	oClone:_URL          := ::_URL 
	oClone:nLojaCodigo   := ::nLojaCodigo
	oClone:cCodigoInternoProduto := ::cCodigoInternoProduto
	oClone:cCodigoInternoCategoria := ::cCodigoInternoCategoria
	oClone:cA1           := ::cA1
	oClone:cA2           := ::cA2
	oClone:oWSSalvarResult :=  IIF(::oWSSalvarResult = NIL , NIL ,::oWSSalvarResult:Clone() )
	oClone:oWSExcluirResult :=  IIF(::oWSExcluirResult = NIL , NIL ,::oWSExcluirResult:Clone() )
Return oClone

// WSDL Method Salvar of Service WSProdutoCategoria

WSMETHOD Salvar WSSEND nLojaCodigo,cCodigoInternoProduto,cCodigoInternoCategoria,cA1,cA2,oWS WSRECEIVE oWSSalvarResult WSCLIENT WSProdutoCategoria
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
cSoap += WSSoapValue("CodigoInternoProduto", ::cCodigoInternoProduto, cCodigoInternoProduto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoInternoCategoria", ::cCodigoInternoCategoria, cCodigoInternoCategoria , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Salvar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Salvar",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/ProdutoCategoria.asmx")

::Init()
::oWSSalvarResult:SoapRecv( WSAdvValue( oXmlRet,"_SALVARRESPONSE:_SALVARRESULT","clsRetornoOfclsProdutoCategoria",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Excluir of Service WSProdutoCategoria

WSMETHOD Excluir WSSEND nLojaCodigo,cCodigoInternoProduto,cCodigoInternoCategoria,cA1,cA2,oWS WSRECEIVE oWSExcluirResult WSCLIENT WSProdutoCategoria
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
cSoap += WSSoapValue("CodigoInternoProduto", ::cCodigoInternoProduto, cCodigoInternoProduto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoInternoCategoria", ::cCodigoInternoCategoria, cCodigoInternoCategoria , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Excluir>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Excluir",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/ProdutoCategoria.asmx")

::Init()
::oWSExcluirResult:SoapRecv( WSAdvValue( oXmlRet,"_EXCLUIRRESPONSE:_EXCLUIRRESULT","clsRetornoOfclsProdutoCategoria",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure clsRetornoOfclsProdutoCategoria

WSSTRUCT ProdutoCategoria_clsRetornoOfclsProdutoCategoria
	WSDATA   cAcao                     AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   nCodigo                   AS int
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   oWSLista                  AS ProdutoCategoria_ArrayOfClsProdutoCategoria OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ProdutoCategoria_clsRetornoOfclsProdutoCategoria
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ProdutoCategoria_clsRetornoOfclsProdutoCategoria
Return

WSMETHOD CLONE WSCLIENT ProdutoCategoria_clsRetornoOfclsProdutoCategoria
	Local oClone := ProdutoCategoria_clsRetornoOfclsProdutoCategoria():NEW()
	oClone:cAcao                := ::cAcao
	oClone:cData                := ::cData
	oClone:nCodigo              := ::nCodigo
	oClone:cDescricao           := ::cDescricao
	oClone:oWSLista             := IIF(::oWSLista = NIL , NIL , ::oWSLista:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ProdutoCategoria_clsRetornoOfclsProdutoCategoria
	Local oNode5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAcao              :=  WSAdvValue( oResponse,"_ACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nCodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,"Property nCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode5 :=  WSAdvValue( oResponse,"_LISTA","ArrayOfClsProdutoCategoria",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSLista := ProdutoCategoria_ArrayOfClsProdutoCategoria():New()
		::oWSLista:SoapRecv(oNode5)
	EndIf
Return

// WSDL Data Structure ArrayOfClsProdutoCategoria

WSSTRUCT ProdutoCategoria_ArrayOfClsProdutoCategoria
	WSDATA   oWSclsProdutoCategoria    AS ProdutoCategoria_clsProdutoCategoria OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ProdutoCategoria_ArrayOfClsProdutoCategoria
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ProdutoCategoria_ArrayOfClsProdutoCategoria
	::oWSclsProdutoCategoria := {} // Array Of  ProdutoCategoria_CLSPRODUTOCATEGORIA():New()
Return

WSMETHOD CLONE WSCLIENT ProdutoCategoria_ArrayOfClsProdutoCategoria
	Local oClone := ProdutoCategoria_ArrayOfClsProdutoCategoria():NEW()
	oClone:oWSclsProdutoCategoria := NIL
	If ::oWSclsProdutoCategoria <> NIL 
		oClone:oWSclsProdutoCategoria := {}
		aEval( ::oWSclsProdutoCategoria , { |x| aadd( oClone:oWSclsProdutoCategoria , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ProdutoCategoria_ArrayOfClsProdutoCategoria
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLSPRODUTOCATEGORIA","clsProdutoCategoria",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclsProdutoCategoria , ProdutoCategoria_clsProdutoCategoria():New() )
			::oWSclsProdutoCategoria[len(::oWSclsProdutoCategoria)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure clsProdutoCategoria

WSSTRUCT ProdutoCategoria_clsProdutoCategoria
	WSDATA   nLojaCodigo               AS int
	WSDATA   oWSProdutoCategoriaStatus AS ProdutoCategoria_ProdutoCategoriaStatus
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ProdutoCategoria_clsProdutoCategoria
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ProdutoCategoria_clsProdutoCategoria
Return

WSMETHOD CLONE WSCLIENT ProdutoCategoria_clsProdutoCategoria
	Local oClone := ProdutoCategoria_clsProdutoCategoria():NEW()
	oClone:nLojaCodigo          := ::nLojaCodigo
	oClone:oWSProdutoCategoriaStatus := IIF(::oWSProdutoCategoriaStatus = NIL , NIL , ::oWSProdutoCategoriaStatus:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ProdutoCategoria_clsProdutoCategoria
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nLojaCodigo        :=  WSAdvValue( oResponse,"_LOJACODIGO","int",NIL,"Property nLojaCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_PRODUTOCATEGORIASTATUS","ProdutoCategoriaStatus",NIL,"Property oWSProdutoCategoriaStatus as tns:ProdutoCategoriaStatus on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSProdutoCategoriaStatus := ProdutoCategoria_ProdutoCategoriaStatus():New()
		::oWSProdutoCategoriaStatus:SoapRecv(oNode2)
	EndIf
Return

// WSDL Data Enumeration ProdutoCategoriaStatus

WSSTRUCT ProdutoCategoria_ProdutoCategoriaStatus
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ProdutoCategoria_ProdutoCategoriaStatus
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Nenhum" )
	aadd(::aValueList , "Ativo" )
	aadd(::aValueList , "Inativo" )
Return Self

WSMETHOD SOAPSEND WSCLIENT ProdutoCategoria_ProdutoCategoriaStatus
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ProdutoCategoria_ProdutoCategoriaStatus
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT ProdutoCategoria_ProdutoCategoriaStatus
Local oClone := ProdutoCategoria_ProdutoCategoriaStatus():New()
	oClone:Value := ::Value
Return oClone


