#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://homologacao.ikeda.com.br/totvs/ikcwebservice/filtroproduto.asmx?wsdl
Gerado em        04/23/13 10:44:36
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _VQXEPOW ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSFiltroProduto
------------------------------------------------------------------------------- */

WSCLIENT WSFiltroProduto

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
	WSDATA   cCodigoInternoFiltro      AS string
	WSDATA   cCodigoInternoProduto     AS string
	WSDATA   cValorFiltroProduto       AS string
	WSDATA   nStatusFiltroProduto      AS int
	WSDATA   cA1                       AS string
	WSDATA   cA2                       AS string
	WSDATA   oWS                       AS SCHEMA
	WSDATA   oWSSalvarResult           AS FiltroProduto_clsRetornoOfclsProdutoCaracteristicas
	WSDATA   oWSExcluirResult          AS FiltroProduto_clsRetornoOfclsProdutoCaracteristicas

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSFiltroProduto
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.120420A-20120726] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
If val(right(GetWSCVer(),8)) < 1.040504
	UserException("O Código-Fonte Client atual requer a versão de Lib para WebServices igual ou superior a ADVPL WSDL Client 1.040504. Atualize o repositório ou gere o Código-Fonte novamente utilizando o repositório atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSFiltroProduto
	::oWS                := NIL 
	::oWSSalvarResult    := FiltroProduto_CLSRETORNOOFCLSPRODUTOCARACTERISTICAS():New()
	::oWSExcluirResult   := FiltroProduto_CLSRETORNOOFCLSPRODUTOCARACTERISTICAS():New()
Return

WSMETHOD RESET WSCLIENT WSFiltroProduto
	::nLojaCodigo        := NIL 
	::cCodigoInternoFiltro := NIL 
	::cCodigoInternoProduto := NIL 
	::cValorFiltroProduto := NIL 
	::nStatusFiltroProduto := NIL 
	::cA1                := NIL 
	::cA2                := NIL 
	::oWS                := NIL 
	::oWSSalvarResult    := NIL 
	::oWSExcluirResult   := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSFiltroProduto
Local oClone := WSFiltroProduto():New()
	oClone:_URL          := ::_URL 
	oClone:nLojaCodigo   := ::nLojaCodigo
	oClone:cCodigoInternoFiltro := ::cCodigoInternoFiltro
	oClone:cCodigoInternoProduto := ::cCodigoInternoProduto
	oClone:cValorFiltroProduto := ::cValorFiltroProduto
	oClone:nStatusFiltroProduto := ::nStatusFiltroProduto
	oClone:cA1           := ::cA1
	oClone:cA2           := ::cA2
	oClone:oWSSalvarResult :=  IIF(::oWSSalvarResult = NIL , NIL ,::oWSSalvarResult:Clone() )
	oClone:oWSExcluirResult :=  IIF(::oWSExcluirResult = NIL , NIL ,::oWSExcluirResult:Clone() )
Return oClone

// WSDL Method Salvar of Service WSFiltroProduto

WSMETHOD Salvar WSSEND nLojaCodigo,cCodigoInternoFiltro,cCodigoInternoProduto,cValorFiltroProduto,nStatusFiltroProduto,cA1,cA2,oWS WSRECEIVE oWSSalvarResult WSCLIENT WSFiltroProduto
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
cSoap += WSSoapValue("CodigoInternoFiltro", ::cCodigoInternoFiltro, cCodigoInternoFiltro , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoInternoProduto", ::cCodigoInternoProduto, cCodigoInternoProduto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ValorFiltroProduto", ::cValorFiltroProduto, cValorFiltroProduto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("StatusFiltroProduto", ::nStatusFiltroProduto, nStatusFiltroProduto , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += "</Salvar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Salvar",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/filtroproduto.asmx")

::Init()
::oWSSalvarResult:SoapRecv( WSAdvValue( oXmlRet,"_SALVARRESPONSE:_SALVARRESULT","clsRetornoOfclsProdutoCaracteristicas",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Excluir of Service WSFiltroProduto

WSMETHOD Excluir WSSEND nLojaCodigo,cCodigoInternoFiltro,cCodigoInternoProduto,cA1,cA2,oWS WSRECEIVE oWSExcluirResult WSCLIENT WSFiltroProduto
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
cSoap += WSSoapValue("CodigoInternoFiltro", ::cCodigoInternoFiltro, cCodigoInternoFiltro , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoInternoProduto", ::cCodigoInternoProduto, cCodigoInternoProduto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Excluir>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Excluir",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/filtroproduto.asmx")

::Init()
::oWSExcluirResult:SoapRecv( WSAdvValue( oXmlRet,"_EXCLUIRRESPONSE:_EXCLUIRRESULT","clsRetornoOfclsProdutoCaracteristicas",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure clsRetornoOfclsProdutoCaracteristicas

WSSTRUCT FiltroProduto_clsRetornoOfclsProdutoCaracteristicas
	WSDATA   cAcao                     AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   nCodigo                   AS int
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   oWSLista                  AS FiltroProduto_ArrayOfClsProdutoCaracteristicas OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FiltroProduto_clsRetornoOfclsProdutoCaracteristicas
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FiltroProduto_clsRetornoOfclsProdutoCaracteristicas
Return

WSMETHOD CLONE WSCLIENT FiltroProduto_clsRetornoOfclsProdutoCaracteristicas
	Local oClone := FiltroProduto_clsRetornoOfclsProdutoCaracteristicas():NEW()
	oClone:cAcao                := ::cAcao
	oClone:cData                := ::cData
	oClone:nCodigo              := ::nCodigo
	oClone:cDescricao           := ::cDescricao
	oClone:oWSLista             := IIF(::oWSLista = NIL , NIL , ::oWSLista:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FiltroProduto_clsRetornoOfclsProdutoCaracteristicas
	Local oNode5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAcao              :=  WSAdvValue( oResponse,"_ACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nCodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,"Property nCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode5 :=  WSAdvValue( oResponse,"_LISTA","ArrayOfClsProdutoCaracteristicas",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSLista := FiltroProduto_ArrayOfClsProdutoCaracteristicas():New()
		::oWSLista:SoapRecv(oNode5)
	EndIf
Return

// WSDL Data Structure ArrayOfClsProdutoCaracteristicas

WSSTRUCT FiltroProduto_ArrayOfClsProdutoCaracteristicas
	WSDATA   oWSclsProdutoCaracteristicas AS FiltroProduto_clsProdutoCaracteristicas OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FiltroProduto_ArrayOfClsProdutoCaracteristicas
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FiltroProduto_ArrayOfClsProdutoCaracteristicas
	::oWSclsProdutoCaracteristicas := {} // Array Of  FiltroProduto_CLSPRODUTOCARACTERISTICAS():New()
Return

WSMETHOD CLONE WSCLIENT FiltroProduto_ArrayOfClsProdutoCaracteristicas
	Local oClone := FiltroProduto_ArrayOfClsProdutoCaracteristicas():NEW()
	oClone:oWSclsProdutoCaracteristicas := NIL
	If ::oWSclsProdutoCaracteristicas <> NIL 
		oClone:oWSclsProdutoCaracteristicas := {}
		aEval( ::oWSclsProdutoCaracteristicas , { |x| aadd( oClone:oWSclsProdutoCaracteristicas , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FiltroProduto_ArrayOfClsProdutoCaracteristicas
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLSPRODUTOCARACTERISTICAS","clsProdutoCaracteristicas",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclsProdutoCaracteristicas , FiltroProduto_clsProdutoCaracteristicas():New() )
			::oWSclsProdutoCaracteristicas[len(::oWSclsProdutoCaracteristicas)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure clsProdutoCaracteristicas

WSSTRUCT FiltroProduto_clsProdutoCaracteristicas
	WSDATA   nLojaCodigo               AS int
	WSDATA   nProdutoCaracteristicasCodigo AS int
	WSDATA   cCaracteristicasValor     AS string OPTIONAL
	WSDATA   oWSStatus                 AS FiltroProduto_ProdutoCaracteristicasStatus
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FiltroProduto_clsProdutoCaracteristicas
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FiltroProduto_clsProdutoCaracteristicas
Return

WSMETHOD CLONE WSCLIENT FiltroProduto_clsProdutoCaracteristicas
	Local oClone := FiltroProduto_clsProdutoCaracteristicas():NEW()
	oClone:nLojaCodigo          := ::nLojaCodigo
	oClone:nProdutoCaracteristicasCodigo := ::nProdutoCaracteristicasCodigo
	oClone:cCaracteristicasValor := ::cCaracteristicasValor
	oClone:oWSStatus            := IIF(::oWSStatus = NIL , NIL , ::oWSStatus:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FiltroProduto_clsProdutoCaracteristicas
	Local oNode4
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nLojaCodigo        :=  WSAdvValue( oResponse,"_LOJACODIGO","int",NIL,"Property nLojaCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nProdutoCaracteristicasCodigo :=  WSAdvValue( oResponse,"_PRODUTOCARACTERISTICASCODIGO","int",NIL,"Property nProdutoCaracteristicasCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCaracteristicasValor :=  WSAdvValue( oResponse,"_CARACTERISTICASVALOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode4 :=  WSAdvValue( oResponse,"_STATUS","ProdutoCaracteristicasStatus",NIL,"Property oWSStatus as tns:ProdutoCaracteristicasStatus on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode4 != NIL
		::oWSStatus := FiltroProduto_ProdutoCaracteristicasStatus():New()
		::oWSStatus:SoapRecv(oNode4)
	EndIf
Return

// WSDL Data Enumeration ProdutoCaracteristicasStatus

WSSTRUCT FiltroProduto_ProdutoCaracteristicasStatus
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FiltroProduto_ProdutoCaracteristicasStatus
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Nenhum" )
	aadd(::aValueList , "Ativo" )
	aadd(::aValueList , "Inativo" )
Return Self

WSMETHOD SOAPSEND WSCLIENT FiltroProduto_ProdutoCaracteristicasStatus
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FiltroProduto_ProdutoCaracteristicasStatus
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT FiltroProduto_ProdutoCaracteristicasStatus
Local oClone := FiltroProduto_ProdutoCaracteristicasStatus():New()
	oClone:Value := ::Value
Return oClone


