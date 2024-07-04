#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://homologacao.ikeda.com.br/totvs/ikcwebservice/estoque.asmx?wsdl
Gerado em        01/22/13 17:15:43
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.111215
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _IPRKUIF ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSEstoque
------------------------------------------------------------------------------- */

WSCLIENT WSEstoque

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Salvar
	WSMETHOD Retornar

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   nLojaCodigo               AS int
	WSDATA   cCodigoProdutoInterno     AS string
	WSDATA   cPartNumber               AS string
	WSDATA   nQtdEstoque               AS int
	WSDATA   nQtdMinima                AS int
	WSDATA   nTipoAlteracao            AS int
	WSDATA   cA1                       AS string
	WSDATA   cA2                       AS string
	WSDATA   oWS                       AS SCHEMA
	WSDATA   oWSSalvarResult           AS Estoque_clsRetornoOfclsEstoque
	WSDATA   oWSRetornarResult         AS Estoque_clsRetornoOfclsEstoque

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSEstoque
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.111010P-20120314] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSEstoque
	::oWS                := NIL 
	::oWSSalvarResult    := Estoque_CLSRETORNOOFCLSESTOQUE():New()
	::oWSRetornarResult  := Estoque_CLSRETORNOOFCLSESTOQUE():New()
Return

WSMETHOD RESET WSCLIENT WSEstoque
	::nLojaCodigo        := NIL 
	::cCodigoProdutoInterno := NIL 
	::cPartNumber        := NIL 
	::nQtdEstoque        := NIL 
	::nQtdMinima         := NIL 
	::nTipoAlteracao     := NIL 
	::cA1                := NIL 
	::cA2                := NIL 
	::oWS                := NIL 
	::oWSSalvarResult    := NIL 
	::oWSRetornarResult  := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSEstoque
Local oClone := WSEstoque():New()
	oClone:_URL          := ::_URL 
	oClone:nLojaCodigo   := ::nLojaCodigo
	oClone:cCodigoProdutoInterno := ::cCodigoProdutoInterno
	oClone:cPartNumber   := ::cPartNumber
	oClone:nQtdEstoque   := ::nQtdEstoque
	oClone:nQtdMinima    := ::nQtdMinima
	oClone:nTipoAlteracao := ::nTipoAlteracao
	oClone:cA1           := ::cA1
	oClone:cA2           := ::cA2
	oClone:oWSSalvarResult :=  IIF(::oWSSalvarResult = NIL , NIL ,::oWSSalvarResult:Clone() )
	oClone:oWSRetornarResult :=  IIF(::oWSRetornarResult = NIL , NIL ,::oWSRetornarResult:Clone() )
Return oClone

// WSDL Method Salvar of Service WSEstoque

WSMETHOD Salvar WSSEND nLojaCodigo,cCodigoProdutoInterno,cPartNumber,nQtdEstoque,nQtdMinima,nTipoAlteracao,cA1,cA2,oWS WSRECEIVE oWSSalvarResult WSCLIENT WSEstoque
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
cSoap += WSSoapValue("CodigoProdutoInterno", ::cCodigoProdutoInterno, cCodigoProdutoInterno , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PartNumber", ::cPartNumber, cPartNumber , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("QtdEstoque", ::nQtdEstoque, nQtdEstoque , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("QtdMinima", ::nQtdMinima, nQtdMinima , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("TipoAlteracao", ::nTipoAlteracao, nTipoAlteracao , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += "</Salvar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Salvar",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/estoque.asmx")

::Init()
::oWSSalvarResult:SoapRecv( WSAdvValue( oXmlRet,"_SALVARRESPONSE:_SALVARRESULT","clsRetornoOfclsEstoque",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Retornar of Service WSEstoque

WSMETHOD Retornar WSSEND nLojaCodigo,cCodigoProdutoInterno,cPartNumber,cA1,cA2,oWS WSRECEIVE oWSRetornarResult WSCLIENT WSEstoque
Local cSoap := "" , oXmlRet
Local cSoapHead := "" 

BEGIN WSMETHOD

cSoapHead += '<clsSoapHeader xmlns="http://www.ikeda.com.br">'
cSoapHead += WSSoapValue("A1", ::cA1, cA1 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("A2", ::cA2, cA2 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("", ::oWS, oWS , "SCHEMA", .F. , .F., 0 , NIL, .F.) 
cSoapHead +=  "</clsSoapHeader>"

cSoap += '<Retornar xmlns="http://www.ikeda.com.br">'
cSoap += WSSoapValue("LojaCodigo", ::nLojaCodigo, nLojaCodigo , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoProdutoInterno", ::cCodigoProdutoInterno, cCodigoProdutoInterno , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PartNumber", ::cPartNumber, cPartNumber , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Retornar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Retornar",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/estoque.asmx")

::Init()
::oWSRetornarResult:SoapRecv( WSAdvValue( oXmlRet,"_RETORNARRESPONSE:_RETORNARRESULT","clsRetornoOfclsEstoque",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure clsRetornoOfclsEstoque

WSSTRUCT Estoque_clsRetornoOfclsEstoque
	WSDATA   cAcao                     AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   nCodigo                   AS int
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   oWSLista                  AS Estoque_ArrayOfClsEstoque OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Estoque_clsRetornoOfclsEstoque
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Estoque_clsRetornoOfclsEstoque
Return

WSMETHOD CLONE WSCLIENT Estoque_clsRetornoOfclsEstoque
	Local oClone := Estoque_clsRetornoOfclsEstoque():NEW()
	oClone:cAcao                := ::cAcao
	oClone:cData                := ::cData
	oClone:nCodigo              := ::nCodigo
	oClone:cDescricao           := ::cDescricao
	oClone:oWSLista             := IIF(::oWSLista = NIL , NIL , ::oWSLista:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Estoque_clsRetornoOfclsEstoque
	Local oNode5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAcao              :=  WSAdvValue( oResponse,"_ACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nCodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,"Property nCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode5 :=  WSAdvValue( oResponse,"_LISTA","ArrayOfClsEstoque",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSLista := Estoque_ArrayOfClsEstoque():New()
		::oWSLista:SoapRecv(oNode5)
	EndIf
Return

// WSDL Data Structure ArrayOfClsEstoque

WSSTRUCT Estoque_ArrayOfClsEstoque
	WSDATA   oWSclsEstoque             AS Estoque_clsEstoque OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Estoque_ArrayOfClsEstoque
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Estoque_ArrayOfClsEstoque
	::oWSclsEstoque        := {} // Array Of  Estoque_CLSESTOQUE():New()
Return

WSMETHOD CLONE WSCLIENT Estoque_ArrayOfClsEstoque
	Local oClone := Estoque_ArrayOfClsEstoque():NEW()
	oClone:oWSclsEstoque := NIL
	If ::oWSclsEstoque <> NIL 
		oClone:oWSclsEstoque := {}
		aEval( ::oWSclsEstoque , { |x| aadd( oClone:oWSclsEstoque , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Estoque_ArrayOfClsEstoque
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLSESTOQUE","clsEstoque",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclsEstoque , Estoque_clsEstoque():New() )
			::oWSclsEstoque[len(::oWSclsEstoque)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure clsEstoque

WSSTRUCT Estoque_clsEstoque
	WSDATA   nLojaCodigo               AS int
	WSDATA   nQtde                     AS int
	WSDATA   nQtdeMinimo               AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Estoque_clsEstoque
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Estoque_clsEstoque
Return

WSMETHOD CLONE WSCLIENT Estoque_clsEstoque
	Local oClone := Estoque_clsEstoque():NEW()
	oClone:nLojaCodigo          := ::nLojaCodigo
	oClone:nQtde                := ::nQtde
	oClone:nQtdeMinimo          := ::nQtdeMinimo
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Estoque_clsEstoque
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nLojaCodigo        :=  WSAdvValue( oResponse,"_LOJACODIGO","int",NIL,"Property nLojaCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nQtde              :=  WSAdvValue( oResponse,"_QTDE","int",NIL,"Property nQtde as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nQtdeMinimo        :=  WSAdvValue( oResponse,"_QTDEMINIMO","int",NIL,"Property nQtdeMinimo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return


