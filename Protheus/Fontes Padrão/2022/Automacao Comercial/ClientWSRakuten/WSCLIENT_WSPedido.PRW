#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://homologacao.ikeda.com.br/totvs/ikcwebservice/pedido.asmx?WSDL
Gerado em        01/30/13 18:07:05
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.111215
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _SLLPIMG ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSPedido
------------------------------------------------------------------------------- */

WSCLIENT WSPedido

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ListarNovos
	WSMETHOD Listar
	WSMETHOD Validar
	WSMETHOD ValidarComStatus
	WSMETHOD AlterarStatus
	WSMETHOD AlterarStatusItem

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   nLojaCodigo               AS int
	WSDATA   nStatusPedido             AS int
	WSDATA   cStatusInternoPedido      AS string
	WSDATA   cA1                       AS string
	WSDATA   cA2                       AS string
	WSDATA   oWS                       AS SCHEMA
	WSDATA   oWSListarNovosResult      AS Pedido_clsRetornoOfclsPedido
	WSDATA   nCodigoPedido             AS int
	WSDATA   oWSListarResult           AS Pedido_clsRetornoOfclsPedido
	WSDATA   cCodigoInternoPedido      AS string
	WSDATA   oWSValidarResult          AS Pedido_clsRetornoOfclsPedido
	WSDATA   oWSValidarComStatusResult AS Pedido_clsRetornoOfclsPedido
	WSDATA   nPedidoStatus             AS int
	WSDATA   cObjetoSedex              AS string
	WSDATA   nNotaFiscal               AS int
	WSDATA   cSerie                    AS string
	WSDATA   oWSAlterarStatusResult    AS Pedido_clsRetornoOfclsPedido
	WSDATA   nItemPedidoCodigo         AS int
	WSDATA   cItemPedidoCodigoInterno  AS string
	WSDATA   nItemPedidoStatus         AS int
	WSDATA   cItemPedidoStatusInterno  AS string
	WSDATA   oWSAlterarStatusItemResult AS Pedido_clsRetornoOfclsPedido

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSPedido
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.111010P-20120120] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
If val(right(GetWSCVer(),8)) < 1.040504
	UserException("O Código-Fonte Client atual requer a versão de Lib para WebServices igual ou superior a ADVPL WSDL Client 1.040504. Atualize o repositório ou gere o Código-Fonte novamente utilizando o repositório atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSPedido
	::oWS                := NIL 
	::oWSListarNovosResult := Pedido_CLSRETORNOOFCLSPEDIDO():New()
	::oWSListarResult    := Pedido_CLSRETORNOOFCLSPEDIDO():New()
	::oWSValidarResult   := Pedido_CLSRETORNOOFCLSPEDIDO():New()
	::oWSValidarComStatusResult := Pedido_CLSRETORNOOFCLSPEDIDO():New()
	::oWSAlterarStatusResult := Pedido_CLSRETORNOOFCLSPEDIDO():New()
	::oWSAlterarStatusItemResult := Pedido_CLSRETORNOOFCLSPEDIDO():New()
Return

WSMETHOD RESET WSCLIENT WSPedido
	::nLojaCodigo        := NIL 
	::nStatusPedido      := NIL 
	::cStatusInternoPedido := NIL 
	::cA1                := NIL 
	::cA2                := NIL 
	::oWS                := NIL 
	::oWSListarNovosResult := NIL 
	::nCodigoPedido      := NIL 
	::oWSListarResult    := NIL 
	::cCodigoInternoPedido := NIL 
	::oWSValidarResult   := NIL 
	::oWSValidarComStatusResult := NIL 
	::nPedidoStatus      := NIL 
	::cObjetoSedex       := NIL 
	::nNotaFiscal        := NIL 
	::cSerie             := NIL 
	::oWSAlterarStatusResult := NIL 
	::nItemPedidoCodigo  := NIL 
	::cItemPedidoCodigoInterno := NIL 
	::nItemPedidoStatus  := NIL 
	::cItemPedidoStatusInterno := NIL 
	::oWSAlterarStatusItemResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSPedido
Local oClone := WSPedido():New()
	oClone:_URL          := ::_URL 
	oClone:nLojaCodigo   := ::nLojaCodigo
	oClone:nStatusPedido := ::nStatusPedido
	oClone:cStatusInternoPedido := ::cStatusInternoPedido
	oClone:cA1           := ::cA1
	oClone:cA2           := ::cA2
	oClone:oWSListarNovosResult :=  IIF(::oWSListarNovosResult = NIL , NIL ,::oWSListarNovosResult:Clone() )
	oClone:nCodigoPedido := ::nCodigoPedido
	oClone:oWSListarResult :=  IIF(::oWSListarResult = NIL , NIL ,::oWSListarResult:Clone() )
	oClone:cCodigoInternoPedido := ::cCodigoInternoPedido
	oClone:oWSValidarResult :=  IIF(::oWSValidarResult = NIL , NIL ,::oWSValidarResult:Clone() )
	oClone:oWSValidarComStatusResult :=  IIF(::oWSValidarComStatusResult = NIL , NIL ,::oWSValidarComStatusResult:Clone() )
	oClone:nPedidoStatus := ::nPedidoStatus
	oClone:cObjetoSedex  := ::cObjetoSedex
	oClone:nNotaFiscal   := ::nNotaFiscal
	oClone:cSerie        := ::cSerie
	oClone:oWSAlterarStatusResult :=  IIF(::oWSAlterarStatusResult = NIL , NIL ,::oWSAlterarStatusResult:Clone() )
	oClone:nItemPedidoCodigo := ::nItemPedidoCodigo
	oClone:cItemPedidoCodigoInterno := ::cItemPedidoCodigoInterno
	oClone:nItemPedidoStatus := ::nItemPedidoStatus
	oClone:cItemPedidoStatusInterno := ::cItemPedidoStatusInterno
	oClone:oWSAlterarStatusItemResult :=  IIF(::oWSAlterarStatusItemResult = NIL , NIL ,::oWSAlterarStatusItemResult:Clone() )
Return oClone

// WSDL Method ListarNovos of Service WSPedido

WSMETHOD ListarNovos WSSEND nLojaCodigo,nStatusPedido,cStatusInternoPedido,cA1,cA2,oWS WSRECEIVE oWSListarNovosResult WSCLIENT WSPedido
Local cSoap := "" , oXmlRet
Local cSoapHead := "" 

BEGIN WSMETHOD

cSoapHead += '<clsSoapHeader xmlns="http://www.ikeda.com.br">'
cSoapHead += WSSoapValue("A1", ::cA1, cA1 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("A2", ::cA2, cA2 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("", ::oWS, oWS , "SCHEMA", .F. , .F., 0 , NIL, .F.) 
cSoapHead +=  "</clsSoapHeader>"

cSoap += '<ListarNovos xmlns="http://www.ikeda.com.br">'
cSoap += WSSoapValue("LojaCodigo", ::nLojaCodigo, nLojaCodigo , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("StatusPedido", ::nStatusPedido, nStatusPedido , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("StatusInternoPedido", ::cStatusInternoPedido, cStatusInternoPedido , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ListarNovos>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/ListarNovos",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/pedido.asmx")

::Init()
::oWSListarNovosResult:SoapRecv( WSAdvValue( oXmlRet,"_LISTARNOVOSRESPONSE:_LISTARNOVOSRESULT","clsRetornoOfclsPedido",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Listar of Service WSPedido

WSMETHOD Listar WSSEND nLojaCodigo,nCodigoPedido,nStatusPedido,cStatusInternoPedido,cA1,cA2,oWS WSRECEIVE oWSListarResult WSCLIENT WSPedido
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
cSoap += WSSoapValue("CodigoPedido", ::nCodigoPedido, nCodigoPedido , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("StatusPedido", ::nStatusPedido, nStatusPedido , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("StatusInternoPedido", ::cStatusInternoPedido, cStatusInternoPedido , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Listar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Listar",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/pedido.asmx")

::Init()
::oWSListarResult:SoapRecv( WSAdvValue( oXmlRet,"_LISTARRESPONSE:_LISTARRESULT","clsRetornoOfclsPedido",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Validar of Service WSPedido

WSMETHOD Validar WSSEND nLojaCodigo,nCodigoPedido,cCodigoInternoPedido,cA1,cA2,oWS WSRECEIVE oWSValidarResult WSCLIENT WSPedido
Local cSoap := "" , oXmlRet
Local cSoapHead := "" 

BEGIN WSMETHOD

cSoapHead += '<clsSoapHeader xmlns="http://www.ikeda.com.br">'
cSoapHead += WSSoapValue("A1", ::cA1, cA1 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("A2", ::cA2, cA2 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("", ::oWS, oWS , "SCHEMA", .F. , .F., 0 , NIL, .F.) 
cSoapHead +=  "</clsSoapHeader>"

cSoap += '<Validar xmlns="http://www.ikeda.com.br">'
cSoap += WSSoapValue("LojaCodigo", ::nLojaCodigo, nLojaCodigo , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoPedido", ::nCodigoPedido, nCodigoPedido , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoInternoPedido", ::cCodigoInternoPedido, cCodigoInternoPedido , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Validar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Validar",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/pedido.asmx")

::Init()
::oWSValidarResult:SoapRecv( WSAdvValue( oXmlRet,"_VALIDARRESPONSE:_VALIDARRESULT","clsRetornoOfclsPedido",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ValidarComStatus of Service WSPedido

WSMETHOD ValidarComStatus WSSEND nLojaCodigo,nCodigoPedido,cCodigoInternoPedido,nStatusPedido,cA1,cA2,oWS WSRECEIVE oWSValidarComStatusResult WSCLIENT WSPedido
Local cSoap := "" , oXmlRet
Local cSoapHead := "" 

BEGIN WSMETHOD

cSoapHead += '<clsSoapHeader xmlns="http://www.ikeda.com.br">'
cSoapHead += WSSoapValue("A1", ::cA1, cA1 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("A2", ::cA2, cA2 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("", ::oWS, oWS , "SCHEMA", .F. , .F., 0 , NIL, .F.) 
cSoapHead +=  "</clsSoapHeader>"

cSoap += '<ValidarComStatus xmlns="http://www.ikeda.com.br">'
cSoap += WSSoapValue("LojaCodigo", ::nLojaCodigo, nLojaCodigo , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoPedido", ::nCodigoPedido, nCodigoPedido , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoInternoPedido", ::cCodigoInternoPedido, cCodigoInternoPedido , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("StatusPedido", ::nStatusPedido, nStatusPedido , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += "</ValidarComStatus>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/ValidarComStatus",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/pedido.asmx")

::Init()
::oWSValidarComStatusResult:SoapRecv( WSAdvValue( oXmlRet,"_VALIDARCOMSTATUSRESPONSE:_VALIDARCOMSTATUSRESULT","clsRetornoOfclsPedido",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AlterarStatus of Service WSPedido

WSMETHOD AlterarStatus WSSEND nLojaCodigo,nCodigoPedido,cCodigoInternoPedido,nPedidoStatus,cStatusInternoPedido,cObjetoSedex,nNotaFiscal,cSerie,cA1,cA2,oWS WSRECEIVE oWSAlterarStatusResult WSCLIENT WSPedido
Local cSoap := "" , oXmlRet
Local cSoapHead := "" 

BEGIN WSMETHOD

cSoapHead += '<clsSoapHeader xmlns="http://www.ikeda.com.br">'
cSoapHead += WSSoapValue("A1", ::cA1, cA1 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("A2", ::cA2, cA2 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("", ::oWS, oWS , "SCHEMA", .F. , .F., 0 , NIL, .F.) 
cSoapHead +=  "</clsSoapHeader>"

cSoap += '<AlterarStatus xmlns="http://www.ikeda.com.br">'
cSoap += WSSoapValue("LojaCodigo", ::nLojaCodigo, nLojaCodigo , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoPedido", ::nCodigoPedido, nCodigoPedido , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoInternoPedido", ::cCodigoInternoPedido, cCodigoInternoPedido , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PedidoStatus", ::nPedidoStatus, nPedidoStatus , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("StatusInternoPedido", ::cStatusInternoPedido, cStatusInternoPedido , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ObjetoSedex", ::cObjetoSedex, cObjetoSedex , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NotaFiscal", ::nNotaFiscal, nNotaFiscal , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Serie", ::cSerie, cSerie , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AlterarStatus>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/AlterarStatus",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/pedido.asmx")

::Init()
::oWSAlterarStatusResult:SoapRecv( WSAdvValue( oXmlRet,"_ALTERARSTATUSRESPONSE:_ALTERARSTATUSRESULT","clsRetornoOfclsPedido",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AlterarStatusItem of Service WSPedido

WSMETHOD AlterarStatusItem WSSEND nLojaCodigo,nCodigoPedido,cCodigoInternoPedido,nItemPedidoCodigo,cItemPedidoCodigoInterno,nItemPedidoStatus,cItemPedidoStatusInterno,cA1,cA2,oWS WSRECEIVE oWSAlterarStatusItemResult WSCLIENT WSPedido
Local cSoap := "" , oXmlRet
Local cSoapHead := "" 

BEGIN WSMETHOD

cSoapHead += '<clsSoapHeader xmlns="http://www.ikeda.com.br">'
cSoapHead += WSSoapValue("A1", ::cA1, cA1 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("A2", ::cA2, cA2 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("", ::oWS, oWS , "SCHEMA", .F. , .F., 0 , NIL, .F.) 
cSoapHead +=  "</clsSoapHeader>"

cSoap += '<AlterarStatusItem xmlns="http://www.ikeda.com.br">'
cSoap += WSSoapValue("LojaCodigo", ::nLojaCodigo, nLojaCodigo , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoPedido", ::nCodigoPedido, nCodigoPedido , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoInternoPedido", ::cCodigoInternoPedido, cCodigoInternoPedido , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ItemPedidoCodigo", ::nItemPedidoCodigo, nItemPedidoCodigo , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ItemPedidoCodigoInterno", ::cItemPedidoCodigoInterno, cItemPedidoCodigoInterno , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ItemPedidoStatus", ::nItemPedidoStatus, nItemPedidoStatus , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ItemPedidoStatusInterno", ::cItemPedidoStatusInterno, cItemPedidoStatusInterno , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AlterarStatusItem>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/AlterarStatusItem",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/pedido.asmx")

::Init()
::oWSAlterarStatusItemResult:SoapRecv( WSAdvValue( oXmlRet,"_ALTERARSTATUSITEMRESPONSE:_ALTERARSTATUSITEMRESULT","clsRetornoOfclsPedido",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure clsRetornoOfclsPedido

WSSTRUCT Pedido_clsRetornoOfclsPedido
	WSDATA   cAcao                     AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   nCodigo                   AS int
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   oWSLista                  AS Pedido_ArrayOfClsPedido OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedido_clsRetornoOfclsPedido
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedido_clsRetornoOfclsPedido
Return

WSMETHOD CLONE WSCLIENT Pedido_clsRetornoOfclsPedido
	Local oClone := Pedido_clsRetornoOfclsPedido():NEW()
	oClone:cAcao                := ::cAcao
	oClone:cData                := ::cData
	oClone:nCodigo              := ::nCodigo
	oClone:cDescricao           := ::cDescricao
	oClone:oWSLista             := IIF(::oWSLista = NIL , NIL , ::oWSLista:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedido_clsRetornoOfclsPedido
	Local oNode5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAcao              :=  WSAdvValue( oResponse,"_ACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nCodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,"Property nCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode5 :=  WSAdvValue( oResponse,"_LISTA","ArrayOfClsPedido",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSLista := Pedido_ArrayOfClsPedido():New()
		::oWSLista:SoapRecv(oNode5)
	EndIf
Return

// WSDL Data Structure ArrayOfClsPedido

WSSTRUCT Pedido_ArrayOfClsPedido
	WSDATA   oWSclsPedido              AS Pedido_clsPedido OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedido_ArrayOfClsPedido
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedido_ArrayOfClsPedido
	::oWSclsPedido         := {} // Array Of  Pedido_CLSPEDIDO():New()
Return

WSMETHOD CLONE WSCLIENT Pedido_ArrayOfClsPedido
	Local oClone := Pedido_ArrayOfClsPedido():NEW()
	oClone:oWSclsPedido := NIL
	If ::oWSclsPedido <> NIL 
		oClone:oWSclsPedido := {}
		aEval( ::oWSclsPedido , { |x| aadd( oClone:oWSclsPedido , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedido_ArrayOfClsPedido
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLSPEDIDO","clsPedido",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclsPedido , Pedido_clsPedido():New() )
			::oWSclsPedido[len(::oWSclsPedido)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure clsPedido

WSSTRUCT Pedido_clsPedido
	WSDATA   nBanco                    AS int
	WSDATA   cCheque                   AS string OPTIONAL
	WSDATA   cAgencia                  AS string OPTIONAL
	WSDATA   cConta                    AS string OPTIONAL
	WSDATA   cContaDigito              AS string OPTIONAL
	WSDATA   lEntregaAgendada          AS boolean
	WSDATA   cDataEntrega              AS dateTime
	WSDATA   cPeriodoEntrega           AS string OPTIONAL
	WSDATA   nValorAgendamento         AS decimal
	WSDATA   nLojaCodigo               AS int
	WSDATA   nPedidoCodigo             AS int
	WSDATA   cPedidoCodigoCliente      AS string OPTIONAL
	WSDATA   cPedidoCodigoInterno      AS string OPTIONAL
	WSDATA   nParceiroCodigo           AS int
	WSDATA   nAfiliadoCodigo           AS int
	WSDATA   cCestaMensagem            AS string OPTIONAL
	WSDATA   cSedex                    AS string OPTIONAL
	WSDATA   cSedexData                AS string OPTIONAL
	WSDATA   cObservacao               AS string OPTIONAL
	WSDATA   cMotivoCancel             AS string OPTIONAL
	WSDATA   nDesconto                 AS decimal
	WSDATA   oWSPessoa                 AS Pedido_ContaTipo
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cSobrenome                AS string OPTIONAL
	WSDATA   cRazaoSocial              AS string OPTIONAL
	WSDATA   cCPF                      AS string OPTIONAL
	WSDATA   cCNPJ                     AS string OPTIONAL
	WSDATA   cRG                       AS string OPTIONAL
	WSDATA   cIE                       AS string OPTIONAL
	WSDATA   cDataNascimento           AS string OPTIONAL
	WSDATA   cNomeDestinatario         AS string OPTIONAL
	WSDATA   oWSTipoLogradouro         AS Pedido_EndTipoLogradouro
	WSDATA   cLogradouro               AS string OPTIONAL
	WSDATA   cNumero                   AS string OPTIONAL
	WSDATA   cComplemento              AS string OPTIONAL
	WSDATA   cCEP                      AS string OPTIONAL
	WSDATA   cBairro                   AS string OPTIONAL
	WSDATA   cCidade                   AS string OPTIONAL
	WSDATA   cEstado                   AS string OPTIONAL
	WSDATA   cPais                     AS string OPTIONAL
	WSDATA   cDDD1                     AS string OPTIONAL
	WSDATA   cTelefone1                AS string OPTIONAL
	WSDATA   cRamal1                   AS string OPTIONAL
	WSDATA   cDDD2                     AS string OPTIONAL
	WSDATA   cTelefone2                AS string OPTIONAL
	WSDATA   cRamal2                   AS string OPTIONAL
	WSDATA   cDDD3                     AS string OPTIONAL
	WSDATA   cTelefone3                AS string OPTIONAL
	WSDATA   cRamal3                   AS string OPTIONAL
	WSDATA   cDDDCelular               AS string OPTIONAL
	WSDATA   cCelular                  AS string OPTIONAL
	WSDATA   cDDDFax                   AS string OPTIONAL
	WSDATA   cFax                      AS string OPTIONAL
	WSDATA   cReferencia               AS string OPTIONAL
	WSDATA   cEmail                    AS string OPTIONAL
	WSDATA   cNumeroNF                 AS string OPTIONAL
	WSDATA   cSerieNF                  AS string OPTIONAL
	WSDATA   nPagamento                AS int
	WSDATA   nOperadora                AS int
	WSDATA   nFormaPgto                AS int
	WSDATA   nOperadoraInterno         AS int
	WSDATA   nFormaPgtoInterno         AS int
	WSDATA   nValorSubTotal            AS decimal
	WSDATA   nValorTotal               AS decimal
	WSDATA   nValorParcela             AS decimal
	WSDATA   nValorJuros               AS decimal
	WSDATA   nValorDescontoAVista      AS decimal
	WSDATA   nValorPresente            AS decimal
	WSDATA   nValorGarantiaEstendida   AS decimal
	WSDATA   nQtdeParcelas             AS int
	WSDATA   nScore                    AS int
	WSDATA   nPedidoStatus             AS int
	WSDATA   cPedidoStatusInterno      AS string OPTIONAL
	WSDATA   oWSStatusClearSale        AS Pedido_PedidoStatusClearSale
	WSDATA   lAnaliseRisco             AS boolean
	WSDATA   cData                     AS string OPTIONAL
	WSDATA   nValorVale                AS decimal
	WSDATA   nValorRestante            AS decimal
	WSDATA   nListaCodigo              AS int
	WSDATA   oWSEnderecoLista          AS Pedido_SimNao
	WSDATA   oWSFreteGratis            AS Pedido_SimNao
	WSDATA   oWSFreteGratisRecusado    AS Pedido_FreteGratisRecusado
	WSDATA   oWSTipoFrete              AS Pedido_FreteTipo
	WSDATA   nValorFrete               AS decimal
	WSDATA   nValorFreteCobrado        AS decimal
	WSDATA   nPesoTotal                AS decimal
	WSDATA   nPesoTotalCubado          AS decimal
	WSDATA   nPesoTotalCobrado         AS decimal
	WSDATA   nPesoTotalCubadoCobrado   AS decimal
	WSDATA   nServicoEntregaCodigo     AS int
	WSDATA   nPrazoEntrega             AS int
	WSDATA   cCPFNP                    AS string OPTIONAL
	WSDATA   cTexto1                   AS string OPTIONAL
	WSDATA   cTexto2                   AS string OPTIONAL
	WSDATA   cTexto3                   AS string OPTIONAL
	WSDATA   cTexto4                   AS string OPTIONAL
	WSDATA   cTexto5                   AS string OPTIONAL
	WSDATA   nNumero1                  AS decimal
	WSDATA   nNumero2                  AS decimal
	WSDATA   nNumero3                  AS decimal
	WSDATA   nNumero4                  AS decimal
	WSDATA   nNumero5                  AS decimal
	WSDATA   lSemCadastro              AS boolean
	WSDATA   cPedidoCupomProximaCompra AS string OPTIONAL
	WSDATA   cPedidoCupomValidade      AS string OPTIONAL
	WSDATA   lPedidoRecuperado         AS boolean
	WSDATA   oWSItens                  AS Pedido_ArrayOfItem OPTIONAL
	WSDATA   oWSCartao                 AS Pedido_clsCartao OPTIONAL
	WSDATA   nTrazerTrocoPara          AS decimal
	WSDATA   cCNPJNP                   AS string OPTIONAL
	WSDATA   oWSOrigem                 AS Pedido_OrigemPedido
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedido_clsPedido
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedido_clsPedido
Return

WSMETHOD CLONE WSCLIENT Pedido_clsPedido
	Local oClone := Pedido_clsPedido():NEW()
	oClone:nBanco               := ::nBanco
	oClone:cCheque              := ::cCheque
	oClone:cAgencia             := ::cAgencia
	oClone:cConta               := ::cConta
	oClone:cContaDigito         := ::cContaDigito
	oClone:lEntregaAgendada     := ::lEntregaAgendada
	oClone:cDataEntrega         := ::cDataEntrega
	oClone:cPeriodoEntrega      := ::cPeriodoEntrega
	oClone:nValorAgendamento    := ::nValorAgendamento
	oClone:nLojaCodigo          := ::nLojaCodigo
	oClone:nPedidoCodigo        := ::nPedidoCodigo
	oClone:cPedidoCodigoCliente := ::cPedidoCodigoCliente
	oClone:cPedidoCodigoInterno := ::cPedidoCodigoInterno
	oClone:nParceiroCodigo      := ::nParceiroCodigo
	oClone:nAfiliadoCodigo      := ::nAfiliadoCodigo
	oClone:cCestaMensagem       := ::cCestaMensagem
	oClone:cSedex               := ::cSedex
	oClone:cSedexData           := ::cSedexData
	oClone:cObservacao          := ::cObservacao
	oClone:cMotivoCancel        := ::cMotivoCancel
	oClone:nDesconto            := ::nDesconto
	oClone:oWSPessoa            := IIF(::oWSPessoa = NIL , NIL , ::oWSPessoa:Clone() )
	oClone:cNome                := ::cNome
	oClone:cSobrenome           := ::cSobrenome
	oClone:cRazaoSocial         := ::cRazaoSocial
	oClone:cCPF                 := ::cCPF
	oClone:cCNPJ                := ::cCNPJ
	oClone:cRG                  := ::cRG
	oClone:cIE                  := ::cIE
	oClone:cDataNascimento      := ::cDataNascimento
	oClone:cNomeDestinatario    := ::cNomeDestinatario
	oClone:oWSTipoLogradouro    := IIF(::oWSTipoLogradouro = NIL , NIL , ::oWSTipoLogradouro:Clone() )
	oClone:cLogradouro          := ::cLogradouro
	oClone:cNumero              := ::cNumero
	oClone:cComplemento         := ::cComplemento
	oClone:cCEP                 := ::cCEP
	oClone:cBairro              := ::cBairro
	oClone:cCidade              := ::cCidade
	oClone:cEstado              := ::cEstado
	oClone:cPais                := ::cPais
	oClone:cDDD1                := ::cDDD1
	oClone:cTelefone1           := ::cTelefone1
	oClone:cRamal1              := ::cRamal1
	oClone:cDDD2                := ::cDDD2
	oClone:cTelefone2           := ::cTelefone2
	oClone:cRamal2              := ::cRamal2
	oClone:cDDD3                := ::cDDD3
	oClone:cTelefone3           := ::cTelefone3
	oClone:cRamal3              := ::cRamal3
	oClone:cDDDCelular          := ::cDDDCelular
	oClone:cCelular             := ::cCelular
	oClone:cDDDFax              := ::cDDDFax
	oClone:cFax                 := ::cFax
	oClone:cReferencia          := ::cReferencia
	oClone:cEmail               := ::cEmail
	oClone:cNumeroNF            := ::cNumeroNF
	oClone:cSerieNF             := ::cSerieNF
	oClone:nPagamento           := ::nPagamento
	oClone:nOperadora           := ::nOperadora
	oClone:nFormaPgto           := ::nFormaPgto
	oClone:nOperadoraInterno    := ::nOperadoraInterno
	oClone:nFormaPgtoInterno    := ::nFormaPgtoInterno
	oClone:nValorSubTotal       := ::nValorSubTotal
	oClone:nValorTotal          := ::nValorTotal
	oClone:nValorParcela        := ::nValorParcela
	oClone:nValorJuros          := ::nValorJuros
	oClone:nValorDescontoAVista := ::nValorDescontoAVista
	oClone:nValorPresente       := ::nValorPresente
	oClone:nValorGarantiaEstendida := ::nValorGarantiaEstendida
	oClone:nQtdeParcelas        := ::nQtdeParcelas
	oClone:nScore               := ::nScore
	oClone:nPedidoStatus        := ::nPedidoStatus
	oClone:cPedidoStatusInterno := ::cPedidoStatusInterno
	oClone:oWSStatusClearSale   := IIF(::oWSStatusClearSale = NIL , NIL , ::oWSStatusClearSale:Clone() )
	oClone:lAnaliseRisco        := ::lAnaliseRisco
	oClone:cData                := ::cData
	oClone:nValorVale           := ::nValorVale
	oClone:nValorRestante       := ::nValorRestante
	oClone:nListaCodigo         := ::nListaCodigo
	oClone:oWSEnderecoLista     := IIF(::oWSEnderecoLista = NIL , NIL , ::oWSEnderecoLista:Clone() )
	oClone:oWSFreteGratis       := IIF(::oWSFreteGratis = NIL , NIL , ::oWSFreteGratis:Clone() )
	oClone:oWSFreteGratisRecusado := IIF(::oWSFreteGratisRecusado = NIL , NIL , ::oWSFreteGratisRecusado:Clone() )
	oClone:oWSTipoFrete         := IIF(::oWSTipoFrete = NIL , NIL , ::oWSTipoFrete:Clone() )
	oClone:nValorFrete          := ::nValorFrete
	oClone:nValorFreteCobrado   := ::nValorFreteCobrado
	oClone:nPesoTotal           := ::nPesoTotal
	oClone:nPesoTotalCubado     := ::nPesoTotalCubado
	oClone:nPesoTotalCobrado    := ::nPesoTotalCobrado
	oClone:nPesoTotalCubadoCobrado := ::nPesoTotalCubadoCobrado
	oClone:nServicoEntregaCodigo := ::nServicoEntregaCodigo
	oClone:nPrazoEntrega        := ::nPrazoEntrega
	oClone:cCPFNP               := ::cCPFNP
	oClone:cTexto1              := ::cTexto1
	oClone:cTexto2              := ::cTexto2
	oClone:cTexto3              := ::cTexto3
	oClone:cTexto4              := ::cTexto4
	oClone:cTexto5              := ::cTexto5
	oClone:nNumero1             := ::nNumero1
	oClone:nNumero2             := ::nNumero2
	oClone:nNumero3             := ::nNumero3
	oClone:nNumero4             := ::nNumero4
	oClone:nNumero5             := ::nNumero5
	oClone:lSemCadastro         := ::lSemCadastro
	oClone:cPedidoCupomProximaCompra := ::cPedidoCupomProximaCompra
	oClone:cPedidoCupomValidade := ::cPedidoCupomValidade
	oClone:lPedidoRecuperado    := ::lPedidoRecuperado
	oClone:oWSItens             := IIF(::oWSItens = NIL , NIL , ::oWSItens:Clone() )
	oClone:oWSCartao            := IIF(::oWSCartao = NIL , NIL , ::oWSCartao:Clone() )
	oClone:nTrazerTrocoPara     := ::nTrazerTrocoPara
	oClone:cCNPJNP              := ::cCNPJNP
	oClone:oWSOrigem            := IIF(::oWSOrigem = NIL , NIL , ::oWSOrigem:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedido_clsPedido
	Local oNode22
	Local oNode32
	Local oNode74
	Local oNode80
	Local oNode81
	Local oNode82
	Local oNode83
	Local oNode107
	Local oNode108
	Local oNode111
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nBanco             :=  WSAdvValue( oResponse,"_BANCO","int",NIL,"Property nBanco as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCheque            :=  WSAdvValue( oResponse,"_CHEQUE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cAgencia           :=  WSAdvValue( oResponse,"_AGENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cConta             :=  WSAdvValue( oResponse,"_CONTA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cContaDigito       :=  WSAdvValue( oResponse,"_CONTADIGITO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lEntregaAgendada   :=  WSAdvValue( oResponse,"_ENTREGAAGENDADA","boolean",NIL,"Property lEntregaAgendada as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cDataEntrega       :=  WSAdvValue( oResponse,"_DATAENTREGA","dateTime",NIL,"Property cDataEntrega as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPeriodoEntrega    :=  WSAdvValue( oResponse,"_PERIODOENTREGA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nValorAgendamento  :=  WSAdvValue( oResponse,"_VALORAGENDAMENTO","decimal",NIL,"Property nValorAgendamento as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nLojaCodigo        :=  WSAdvValue( oResponse,"_LOJACODIGO","int",NIL,"Property nLojaCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPedidoCodigo      :=  WSAdvValue( oResponse,"_PEDIDOCODIGO","int",NIL,"Property nPedidoCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cPedidoCodigoCliente :=  WSAdvValue( oResponse,"_PEDIDOCODIGOCLIENTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPedidoCodigoInterno :=  WSAdvValue( oResponse,"_PEDIDOCODIGOINTERNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nParceiroCodigo    :=  WSAdvValue( oResponse,"_PARCEIROCODIGO","int",NIL,"Property nParceiroCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nAfiliadoCodigo    :=  WSAdvValue( oResponse,"_AFILIADOCODIGO","int",NIL,"Property nAfiliadoCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCestaMensagem     :=  WSAdvValue( oResponse,"_CESTAMENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSedex             :=  WSAdvValue( oResponse,"_SEDEX","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSedexData         :=  WSAdvValue( oResponse,"_SEDEXDATA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cObservacao        :=  WSAdvValue( oResponse,"_OBSERVACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMotivoCancel      :=  WSAdvValue( oResponse,"_MOTIVOCANCEL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nDesconto          :=  WSAdvValue( oResponse,"_DESCONTO","decimal",NIL,"Property nDesconto as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode22 :=  WSAdvValue( oResponse,"_PESSOA","ContaTipo",NIL,"Property oWSPessoa as tns:ContaTipo on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode22 != NIL
		::oWSPessoa := Pedido_ContaTipo():New()
		::oWSPessoa:SoapRecv(oNode22)
	EndIf
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSobrenome         :=  WSAdvValue( oResponse,"_SOBRENOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRazaoSocial       :=  WSAdvValue( oResponse,"_RAZAOSOCIAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCPF               :=  WSAdvValue( oResponse,"_CPF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCNPJ              :=  WSAdvValue( oResponse,"_CNPJ","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRG                :=  WSAdvValue( oResponse,"_RG","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cIE                :=  WSAdvValue( oResponse,"_IE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataNascimento    :=  WSAdvValue( oResponse,"_DATANASCIMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNomeDestinatario  :=  WSAdvValue( oResponse,"_NOMEDESTINATARIO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode32 :=  WSAdvValue( oResponse,"_TIPOLOGRADOURO","EndTipoLogradouro",NIL,"Property oWSTipoLogradouro as tns:EndTipoLogradouro on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode32 != NIL
		::oWSTipoLogradouro := Pedido_EndTipoLogradouro():New()
		::oWSTipoLogradouro:SoapRecv(oNode32)
	EndIf
	::cLogradouro        :=  WSAdvValue( oResponse,"_LOGRADOURO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNumero            :=  WSAdvValue( oResponse,"_NUMERO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cComplemento       :=  WSAdvValue( oResponse,"_COMPLEMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCEP               :=  WSAdvValue( oResponse,"_CEP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cBairro            :=  WSAdvValue( oResponse,"_BAIRRO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCidade            :=  WSAdvValue( oResponse,"_CIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEstado            :=  WSAdvValue( oResponse,"_ESTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPais              :=  WSAdvValue( oResponse,"_PAIS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDDD1              :=  WSAdvValue( oResponse,"_DDD1","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTelefone1         :=  WSAdvValue( oResponse,"_TELEFONE1","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRamal1            :=  WSAdvValue( oResponse,"_RAMAL1","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDDD2              :=  WSAdvValue( oResponse,"_DDD2","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTelefone2         :=  WSAdvValue( oResponse,"_TELEFONE2","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRamal2            :=  WSAdvValue( oResponse,"_RAMAL2","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDDD3              :=  WSAdvValue( oResponse,"_DDD3","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTelefone3         :=  WSAdvValue( oResponse,"_TELEFONE3","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRamal3            :=  WSAdvValue( oResponse,"_RAMAL3","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDDDCelular        :=  WSAdvValue( oResponse,"_DDDCELULAR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCelular           :=  WSAdvValue( oResponse,"_CELULAR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDDDFax            :=  WSAdvValue( oResponse,"_DDDFAX","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cFax               :=  WSAdvValue( oResponse,"_FAX","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cReferencia        :=  WSAdvValue( oResponse,"_REFERENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEmail             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNumeroNF          :=  WSAdvValue( oResponse,"_NUMERONF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSerieNF           :=  WSAdvValue( oResponse,"_SERIENF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nPagamento         :=  WSAdvValue( oResponse,"_PAGAMENTO","int",NIL,"Property nPagamento as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nOperadora         :=  WSAdvValue( oResponse,"_OPERADORA","int",NIL,"Property nOperadora as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nFormaPgto         :=  WSAdvValue( oResponse,"_FORMAPGTO","int",NIL,"Property nFormaPgto as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nOperadoraInterno  :=  WSAdvValue( oResponse,"_OPERADORAINTERNO","int",NIL,"Property nOperadoraInterno as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nFormaPgtoInterno  :=  WSAdvValue( oResponse,"_FORMAPGTOINTERNO","int",NIL,"Property nFormaPgtoInterno as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nValorSubTotal     :=  WSAdvValue( oResponse,"_VALORSUBTOTAL","decimal",NIL,"Property nValorSubTotal as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nValorTotal        :=  WSAdvValue( oResponse,"_VALORTOTAL","decimal",NIL,"Property nValorTotal as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nValorParcela      :=  WSAdvValue( oResponse,"_VALORPARCELA","decimal",NIL,"Property nValorParcela as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nValorJuros        :=  WSAdvValue( oResponse,"_VALORJUROS","decimal",NIL,"Property nValorJuros as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nValorDescontoAVista :=  WSAdvValue( oResponse,"_VALORDESCONTOAVISTA","decimal",NIL,"Property nValorDescontoAVista as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nValorPresente     :=  WSAdvValue( oResponse,"_VALORPRESENTE","decimal",NIL,"Property nValorPresente as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nValorGarantiaEstendida :=  WSAdvValue( oResponse,"_VALORGARANTIAESTENDIDA","decimal",NIL,"Property nValorGarantiaEstendida as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nQtdeParcelas      :=  WSAdvValue( oResponse,"_QTDEPARCELAS","int",NIL,"Property nQtdeParcelas as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nScore             :=  WSAdvValue( oResponse,"_SCORE","int",NIL,"Property nScore as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPedidoStatus      :=  WSAdvValue( oResponse,"_PEDIDOSTATUS","int",NIL,"Property nPedidoStatus as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cPedidoStatusInterno :=  WSAdvValue( oResponse,"_PEDIDOSTATUSINTERNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode74 :=  WSAdvValue( oResponse,"_STATUSCLEARSALE","PedidoStatusClearSale",NIL,"Property oWSStatusClearSale as tns:PedidoStatusClearSale on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode74 != NIL
		::oWSStatusClearSale := Pedido_PedidoStatusClearSale():New()
		::oWSStatusClearSale:SoapRecv(oNode74)
	EndIf
	::lAnaliseRisco      :=  WSAdvValue( oResponse,"_ANALISERISCO","boolean",NIL,"Property lAnaliseRisco as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nValorVale         :=  WSAdvValue( oResponse,"_VALORVALE","decimal",NIL,"Property nValorVale as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nValorRestante     :=  WSAdvValue( oResponse,"_VALORRESTANTE","decimal",NIL,"Property nValorRestante as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nListaCodigo       :=  WSAdvValue( oResponse,"_LISTACODIGO","int",NIL,"Property nListaCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode80 :=  WSAdvValue( oResponse,"_ENDERECOLISTA","SimNao",NIL,"Property oWSEnderecoLista as tns:SimNao on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode80 != NIL
		::oWSEnderecoLista := Pedido_SimNao():New()
		::oWSEnderecoLista:SoapRecv(oNode80)
	EndIf
	oNode81 :=  WSAdvValue( oResponse,"_FRETEGRATIS","SimNao",NIL,"Property oWSFreteGratis as tns:SimNao on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode81 != NIL
		::oWSFreteGratis := Pedido_SimNao():New()
		::oWSFreteGratis:SoapRecv(oNode81)
	EndIf
	oNode82 :=  WSAdvValue( oResponse,"_FRETEGRATISRECUSADO","FreteGratisRecusado",NIL,"Property oWSFreteGratisRecusado as tns:FreteGratisRecusado on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode82 != NIL
		::oWSFreteGratisRecusado := Pedido_FreteGratisRecusado():New()
		::oWSFreteGratisRecusado:SoapRecv(oNode82)
	EndIf
	oNode83 :=  WSAdvValue( oResponse,"_TIPOFRETE","FreteTipo",NIL,"Property oWSTipoFrete as tns:FreteTipo on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode83 != NIL
		::oWSTipoFrete := Pedido_FreteTipo():New()
		::oWSTipoFrete:SoapRecv(oNode83)
	EndIf
	::nValorFrete        :=  WSAdvValue( oResponse,"_VALORFRETE","decimal",NIL,"Property nValorFrete as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nValorFreteCobrado :=  WSAdvValue( oResponse,"_VALORFRETECOBRADO","decimal",NIL,"Property nValorFreteCobrado as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoTotal         :=  WSAdvValue( oResponse,"_PESOTOTAL","decimal",NIL,"Property nPesoTotal as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoTotalCubado   :=  WSAdvValue( oResponse,"_PESOTOTALCUBADO","decimal",NIL,"Property nPesoTotalCubado as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoTotalCobrado  :=  WSAdvValue( oResponse,"_PESOTOTALCOBRADO","decimal",NIL,"Property nPesoTotalCobrado as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoTotalCubadoCobrado :=  WSAdvValue( oResponse,"_PESOTOTALCUBADOCOBRADO","decimal",NIL,"Property nPesoTotalCubadoCobrado as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nServicoEntregaCodigo :=  WSAdvValue( oResponse,"_SERVICOENTREGACODIGO","int",NIL,"Property nServicoEntregaCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPrazoEntrega      :=  WSAdvValue( oResponse,"_PRAZOENTREGA","int",NIL,"Property nPrazoEntrega as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCPFNP             :=  WSAdvValue( oResponse,"_CPFNP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTexto1            :=  WSAdvValue( oResponse,"_TEXTO1","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTexto2            :=  WSAdvValue( oResponse,"_TEXTO2","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTexto3            :=  WSAdvValue( oResponse,"_TEXTO3","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTexto4            :=  WSAdvValue( oResponse,"_TEXTO4","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTexto5            :=  WSAdvValue( oResponse,"_TEXTO5","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nNumero1           :=  WSAdvValue( oResponse,"_NUMERO1","decimal",NIL,"Property nNumero1 as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNumero2           :=  WSAdvValue( oResponse,"_NUMERO2","decimal",NIL,"Property nNumero2 as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNumero3           :=  WSAdvValue( oResponse,"_NUMERO3","decimal",NIL,"Property nNumero3 as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNumero4           :=  WSAdvValue( oResponse,"_NUMERO4","decimal",NIL,"Property nNumero4 as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNumero5           :=  WSAdvValue( oResponse,"_NUMERO5","decimal",NIL,"Property nNumero5 as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::lSemCadastro       :=  WSAdvValue( oResponse,"_SEMCADASTRO","boolean",NIL,"Property lSemCadastro as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cPedidoCupomProximaCompra :=  WSAdvValue( oResponse,"_PEDIDOCUPOMPROXIMACOMPRA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPedidoCupomValidade :=  WSAdvValue( oResponse,"_PEDIDOCUPOMVALIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lPedidoRecuperado  :=  WSAdvValue( oResponse,"_PEDIDORECUPERADO","boolean",NIL,"Property lPedidoRecuperado as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	oNode107 :=  WSAdvValue( oResponse,"_ITENS","ArrayOfItem",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode107 != NIL
		::oWSItens := Pedido_ArrayOfItem():New()
		::oWSItens:SoapRecv(oNode107)
	EndIf
	oNode108 :=  WSAdvValue( oResponse,"_CARTAO","clsCartao",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode108 != NIL
		::oWSCartao := Pedido_clsCartao():New()
		::oWSCartao:SoapRecv(oNode108)
	EndIf
	::nTrazerTrocoPara   :=  WSAdvValue( oResponse,"_TRAZERTROCOPARA","decimal",NIL,"Property nTrazerTrocoPara as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCNPJNP            :=  WSAdvValue( oResponse,"_CNPJNP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode111 :=  WSAdvValue( oResponse,"_ORIGEM","OrigemPedido",NIL,"Property oWSOrigem as tns:OrigemPedido on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode111 != NIL
		::oWSOrigem := Pedido_OrigemPedido():New()
		::oWSOrigem:SoapRecv(oNode111)
	EndIf
Return

// WSDL Data Enumeration ContaTipo

WSSTRUCT Pedido_ContaTipo
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedido_ContaTipo
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Nenhum" )
	aadd(::aValueList , "PessoaFísica" )
	aadd(::aValueList , "PessoaJurídica" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Pedido_ContaTipo
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedido_ContaTipo
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Pedido_ContaTipo
Local oClone := Pedido_ContaTipo():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration EndTipoLogradouro

WSSTRUCT Pedido_EndTipoLogradouro
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedido_EndTipoLogradouro
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Nenhum" )
	aadd(::aValueList , "Rua" )
	aadd(::aValueList , "Avenida" )
	aadd(::aValueList , "Praça" )
	aadd(::aValueList , "Outros" )
	aadd(::aValueList , "Aeroporto" )
	aadd(::aValueList , "Alameda" )
	aadd(::aValueList , "Área" )
	aadd(::aValueList , "Beco" )
	aadd(::aValueList , "Bloco" )
	aadd(::aValueList , "Calçada" )
	aadd(::aValueList , "Campo" )
	aadd(::aValueList , "Chácara" )
	aadd(::aValueList , "Colônia" )
	aadd(::aValueList , "Condomínio" )
	aadd(::aValueList , "Conjunto" )
	aadd(::aValueList , "Distrito" )
	aadd(::aValueList , "Escadaria" )
	aadd(::aValueList , "Esplanada" )
	aadd(::aValueList , "Estação" )
	aadd(::aValueList , "Estância" )
	aadd(::aValueList , "Estrada" )
	aadd(::aValueList , "Favela" )
	aadd(::aValueList , "Fazenda" )
	aadd(::aValueList , "Feira" )
	aadd(::aValueList , "Hospital" )
	aadd(::aValueList , "Hotel" )
	aadd(::aValueList , "Jardim" )
	aadd(::aValueList , "Ladeira" )
	aadd(::aValueList , "Lago" )
	aadd(::aValueList , "Lagoa" )
	aadd(::aValueList , "Largo" )
	aadd(::aValueList , "Linha" )
	aadd(::aValueList , "Loteamento" )
	aadd(::aValueList , "Morro" )
	aadd(::aValueList , "Nucleo" )
	aadd(::aValueList , "Parque" )
	aadd(::aValueList , "Passarela" )
	aadd(::aValueList , "Pátio" )
	aadd(::aValueList , "Porto" )
	aadd(::aValueList , "Pousada" )
	aadd(::aValueList , "Povoado" )
	aadd(::aValueList , "Praia" )
	aadd(::aValueList , "Quadra" )
	aadd(::aValueList , "Recanto" )
	aadd(::aValueList , "Residencial" )
	aadd(::aValueList , "Rodovia" )
	aadd(::aValueList , "Setor" )
	aadd(::aValueList , "Sítio" )
	aadd(::aValueList , "Travessa" )
	aadd(::aValueList , "Techo" )
	aadd(::aValueList , "Trevo" )
	aadd(::aValueList , "Vale" )
	aadd(::aValueList , "Vereda" )
	aadd(::aValueList , "Via" )
	aadd(::aValueList , "Viaduto" )
	aadd(::aValueList , "Viela" )
	aadd(::aValueList , "Vila" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Pedido_EndTipoLogradouro
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedido_EndTipoLogradouro
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Pedido_EndTipoLogradouro
Local oClone := Pedido_EndTipoLogradouro():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration PedidoStatusClearSale

WSSTRUCT Pedido_PedidoStatusClearSale
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedido_PedidoStatusClearSale
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Nenhum" )
	aadd(::aValueList , "Aprovado" )
	aadd(::aValueList , "Suspenso" )
	aadd(::aValueList , "Fraude" )
	aadd(::aValueList , "Aprovação_Automática" )
	aadd(::aValueList , "Suspensão_Automática" )
	aadd(::aValueList , "Fraude_Confirmada" )
	aadd(::aValueList , "Cancelado" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Pedido_PedidoStatusClearSale
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedido_PedidoStatusClearSale
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Pedido_PedidoStatusClearSale
Local oClone := Pedido_PedidoStatusClearSale():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration SimNao

WSSTRUCT Pedido_SimNao
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedido_SimNao
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Nenhum" )
	aadd(::aValueList , "Sim" )
	aadd(::aValueList , "Não" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Pedido_SimNao
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedido_SimNao
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Pedido_SimNao
Local oClone := Pedido_SimNao():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration FreteGratisRecusado

WSSTRUCT Pedido_FreteGratisRecusado
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedido_FreteGratisRecusado
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Nao" )
	aadd(::aValueList , "Sim" )
	aadd(::aValueList , "Parcial" )
	aadd(::aValueList , "SimPromoServicoCesta" )
	aadd(::aValueList , "SimPromoServicoItem" )
	aadd(::aValueList , "SimPromoOperadora" )
	aadd(::aValueList , "NaoPromoServicoCesta" )
	aadd(::aValueList , "NaoPromoServicoItem" )
	aadd(::aValueList , "NaoPromoOperadora" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Pedido_FreteGratisRecusado
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedido_FreteGratisRecusado
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Pedido_FreteGratisRecusado
Local oClone := Pedido_FreteGratisRecusado():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration FreteTipo

WSSTRUCT Pedido_FreteTipo
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedido_FreteTipo
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Nenhum" )
	aadd(::aValueList , "Cesta" )
	aadd(::aValueList , "Item" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Pedido_FreteTipo
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedido_FreteTipo
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Pedido_FreteTipo
Local oClone := Pedido_FreteTipo():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure ArrayOfItem

WSSTRUCT Pedido_ArrayOfItem
	WSDATA   oWSItem                   AS Pedido_Item OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedido_ArrayOfItem
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedido_ArrayOfItem
	::oWSItem              := {} // Array Of  Pedido_ITEM():New()
Return

WSMETHOD CLONE WSCLIENT Pedido_ArrayOfItem
	Local oClone := Pedido_ArrayOfItem():NEW()
	oClone:oWSItem := NIL
	If ::oWSItem <> NIL 
		oClone:oWSItem := {}
		aEval( ::oWSItem , { |x| aadd( oClone:oWSItem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedido_ArrayOfItem
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ITEM","Item",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSItem , Pedido_Item():New() )
			::oWSItem[len(::oWSItem)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure clsCartao

WSSTRUCT Pedido_clsCartao
	WSDATA   cNumero                   AS string OPTIONAL
	WSDATA   cSeguranca                AS string OPTIONAL
	WSDATA   cTitular                  AS string OPTIONAL
	WSDATA   cValidadeMes              AS string OPTIONAL
	WSDATA   cValidadeAno              AS string OPTIONAL
	WSDATA   cCarTID                   AS string OPTIONAL
	WSDATA   cCarOperadoraRetornoCodigo AS string OPTIONAL
	WSDATA   cCarOperadoraRetornoMensagem AS string OPTIONAL
	WSDATA   cCarAutorizacaoCodigo     AS string OPTIONAL
	WSDATA   cCarCPFCNPJ               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedido_clsCartao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedido_clsCartao
Return

WSMETHOD CLONE WSCLIENT Pedido_clsCartao
	Local oClone := Pedido_clsCartao():NEW()
	oClone:cNumero              := ::cNumero
	oClone:cSeguranca           := ::cSeguranca
	oClone:cTitular             := ::cTitular
	oClone:cValidadeMes         := ::cValidadeMes
	oClone:cValidadeAno         := ::cValidadeAno
	oClone:cCarTID              := ::cCarTID
	oClone:cCarOperadoraRetornoCodigo := ::cCarOperadoraRetornoCodigo
	oClone:cCarOperadoraRetornoMensagem := ::cCarOperadoraRetornoMensagem
	oClone:cCarAutorizacaoCodigo := ::cCarAutorizacaoCodigo
	oClone:cCarCPFCNPJ          := ::cCarCPFCNPJ
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedido_clsCartao
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cNumero            :=  WSAdvValue( oResponse,"_NUMERO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSeguranca         :=  WSAdvValue( oResponse,"_SEGURANCA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTitular           :=  WSAdvValue( oResponse,"_TITULAR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValidadeMes       :=  WSAdvValue( oResponse,"_VALIDADEMES","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValidadeAno       :=  WSAdvValue( oResponse,"_VALIDADEANO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCarTID            :=  WSAdvValue( oResponse,"_CARTID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCarOperadoraRetornoCodigo :=  WSAdvValue( oResponse,"_CAROPERADORARETORNOCODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCarOperadoraRetornoMensagem :=  WSAdvValue( oResponse,"_CAROPERADORARETORNOMENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCarAutorizacaoCodigo :=  WSAdvValue( oResponse,"_CARAUTORIZACAOCODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCarCPFCNPJ        :=  WSAdvValue( oResponse,"_CARCPFCNPJ","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Enumeration OrigemPedido

WSSTRUCT Pedido_OrigemPedido
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedido_OrigemPedido
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Todas" )
	aadd(::aValueList , "Loja" )
	aadd(::aValueList , "Televendas" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Pedido_OrigemPedido
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedido_OrigemPedido
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Pedido_OrigemPedido
Local oClone := Pedido_OrigemPedido():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure Item

WSSTRUCT Pedido_Item
	WSDATA   nItemCodigo               AS int
	WSDATA   nItemCodigoComprado       AS int
	WSDATA   nItemStatus               AS int
	WSDATA   cItemStatusInterno        AS string OPTIONAL
	WSDATA   nItemQtde                 AS int
	WSDATA   nItemValor                AS decimal
	WSDATA   nItemValorFinal           AS decimal
	WSDATA   nItemValorPresente        AS decimal
	WSDATA   nItemValorGarantiaEstendida AS decimal
	WSDATA   nItemAnosGarantiaEstendida AS int
	WSDATA   cItemCertificadoGarantiaEstendida AS string OPTIONAL
	WSDATA   cEnqCodInterno            AS string OPTIONAL
	WSDATA   oWSItemTipo               AS Pedido_ItemTipo
	WSDATA   oWSPresente               AS Pedido_SimNao
	WSDATA   cCupom                    AS string OPTIONAL
	WSDATA   cItemNome                 AS string OPTIONAL
	WSDATA   cItemMensagem             AS string OPTIONAL
	WSDATA   cItemMsgPresente          AS string OPTIONAL
	WSDATA   cItemPartNumber           AS string OPTIONAL
	WSDATA   cCodigoInterno            AS string OPTIONAL
	WSDATA   oWSFreteGratis            AS Pedido_SimNao
	WSDATA   oWSFreteGratisRecusado    AS Pedido_FreteGratisRecusado
	WSDATA   nItemValorFrete           AS decimal
	WSDATA   nItemValorFreteCobrado    AS decimal
	WSDATA   nItemPeso                 AS decimal
	WSDATA   nItemPesoCubado           AS decimal
	WSDATA   nItemPesoCobrado          AS decimal
	WSDATA   nItemPesoCubadoCobrado    AS decimal
	WSDATA   nServicoEntregaCodigo     AS int
	WSDATA   nItemPrazoEntrega         AS int
	WSDATA   cItemDataEntrega          AS string OPTIONAL
	WSDATA   cSedex                    AS string OPTIONAL
	WSDATA   nListaCodigo              AS int
	WSDATA   cListaCodigoInterno       AS string OPTIONAL
	WSDATA   oWSListaTipoEntrega       AS Pedido_ListaTipoEntrega
	WSDATA   oWSItemTroca              AS Pedido_SimNao
	WSDATA   cItemTexto1               AS string OPTIONAL
	WSDATA   cItemTexto2               AS string OPTIONAL
	WSDATA   cItemTexto3               AS string OPTIONAL
	WSDATA   nItemNumero1              AS decimal
	WSDATA   nItemNumero2              AS decimal
	WSDATA   nItemNumero3              AS decimal
	WSDATA   oWSPersonalizacaoExtra    AS Pedido_SimNao
	WSDATA   cPersonalizacaoTexto      AS string OPTIONAL
	WSDATA   cItemCodigoInterno        AS string OPTIONAL
	WSDATA   cSeloQuantidadeMinimaProduto1 AS string OPTIONAL
	WSDATA   cSeloQuantidadeMinimaProduto2 AS string OPTIONAL
	WSDATA   cSeloQuantidadeMinimaProduto3 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedido_Item
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedido_Item
Return

WSMETHOD CLONE WSCLIENT Pedido_Item
	Local oClone := Pedido_Item():NEW()
	oClone:nItemCodigo          := ::nItemCodigo
	oClone:nItemCodigoComprado  := ::nItemCodigoComprado
	oClone:nItemStatus          := ::nItemStatus
	oClone:cItemStatusInterno   := ::cItemStatusInterno
	oClone:nItemQtde            := ::nItemQtde
	oClone:nItemValor           := ::nItemValor
	oClone:nItemValorFinal      := ::nItemValorFinal
	oClone:nItemValorPresente   := ::nItemValorPresente
	oClone:nItemValorGarantiaEstendida := ::nItemValorGarantiaEstendida
	oClone:nItemAnosGarantiaEstendida := ::nItemAnosGarantiaEstendida
	oClone:cItemCertificadoGarantiaEstendida := ::cItemCertificadoGarantiaEstendida
	oClone:cEnqCodInterno       := ::cEnqCodInterno
	oClone:oWSItemTipo          := IIF(::oWSItemTipo = NIL , NIL , ::oWSItemTipo:Clone() )
	oClone:oWSPresente          := IIF(::oWSPresente = NIL , NIL , ::oWSPresente:Clone() )
	oClone:cCupom               := ::cCupom
	oClone:cItemNome            := ::cItemNome
	oClone:cItemMensagem        := ::cItemMensagem
	oClone:cItemMsgPresente     := ::cItemMsgPresente
	oClone:cItemPartNumber      := ::cItemPartNumber
	oClone:cCodigoInterno       := ::cCodigoInterno
	oClone:oWSFreteGratis       := IIF(::oWSFreteGratis = NIL , NIL , ::oWSFreteGratis:Clone() )
	oClone:oWSFreteGratisRecusado := IIF(::oWSFreteGratisRecusado = NIL , NIL , ::oWSFreteGratisRecusado:Clone() )
	oClone:nItemValorFrete      := ::nItemValorFrete
	oClone:nItemValorFreteCobrado := ::nItemValorFreteCobrado
	oClone:nItemPeso            := ::nItemPeso
	oClone:nItemPesoCubado      := ::nItemPesoCubado
	oClone:nItemPesoCobrado     := ::nItemPesoCobrado
	oClone:nItemPesoCubadoCobrado := ::nItemPesoCubadoCobrado
	oClone:nServicoEntregaCodigo := ::nServicoEntregaCodigo
	oClone:nItemPrazoEntrega    := ::nItemPrazoEntrega
	oClone:cItemDataEntrega     := ::cItemDataEntrega
	oClone:cSedex               := ::cSedex
	oClone:nListaCodigo         := ::nListaCodigo
	oClone:cListaCodigoInterno  := ::cListaCodigoInterno
	oClone:oWSListaTipoEntrega  := IIF(::oWSListaTipoEntrega = NIL , NIL , ::oWSListaTipoEntrega:Clone() )
	oClone:oWSItemTroca         := IIF(::oWSItemTroca = NIL , NIL , ::oWSItemTroca:Clone() )
	oClone:cItemTexto1          := ::cItemTexto1
	oClone:cItemTexto2          := ::cItemTexto2
	oClone:cItemTexto3          := ::cItemTexto3
	oClone:nItemNumero1         := ::nItemNumero1
	oClone:nItemNumero2         := ::nItemNumero2
	oClone:nItemNumero3         := ::nItemNumero3
	oClone:oWSPersonalizacaoExtra := IIF(::oWSPersonalizacaoExtra = NIL , NIL , ::oWSPersonalizacaoExtra:Clone() )
	oClone:cPersonalizacaoTexto := ::cPersonalizacaoTexto
	oClone:cItemCodigoInterno   := ::cItemCodigoInterno
	oClone:cSeloQuantidadeMinimaProduto1 := ::cSeloQuantidadeMinimaProduto1
	oClone:cSeloQuantidadeMinimaProduto2 := ::cSeloQuantidadeMinimaProduto2
	oClone:cSeloQuantidadeMinimaProduto3 := ::cSeloQuantidadeMinimaProduto3
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedido_Item
	Local oNode13
	Local oNode14
	Local oNode21
	Local oNode22
	Local oNode35
	Local oNode36
	Local oNode43
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nItemCodigo        :=  WSAdvValue( oResponse,"_ITEMCODIGO","int",NIL,"Property nItemCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nItemCodigoComprado :=  WSAdvValue( oResponse,"_ITEMCODIGOCOMPRADO","int",NIL,"Property nItemCodigoComprado as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nItemStatus        :=  WSAdvValue( oResponse,"_ITEMSTATUS","int",NIL,"Property nItemStatus as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cItemStatusInterno :=  WSAdvValue( oResponse,"_ITEMSTATUSINTERNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nItemQtde          :=  WSAdvValue( oResponse,"_ITEMQTDE","int",NIL,"Property nItemQtde as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nItemValor         :=  WSAdvValue( oResponse,"_ITEMVALOR","decimal",NIL,"Property nItemValor as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nItemValorFinal    :=  WSAdvValue( oResponse,"_ITEMVALORFINAL","decimal",NIL,"Property nItemValorFinal as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nItemValorPresente :=  WSAdvValue( oResponse,"_ITEMVALORPRESENTE","decimal",NIL,"Property nItemValorPresente as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nItemValorGarantiaEstendida :=  WSAdvValue( oResponse,"_ITEMVALORGARANTIAESTENDIDA","decimal",NIL,"Property nItemValorGarantiaEstendida as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nItemAnosGarantiaEstendida :=  WSAdvValue( oResponse,"_ITEMANOSGARANTIAESTENDIDA","int",NIL,"Property nItemAnosGarantiaEstendida as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cItemCertificadoGarantiaEstendida :=  WSAdvValue( oResponse,"_ITEMCERTIFICADOGARANTIAESTENDIDA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEnqCodInterno     :=  WSAdvValue( oResponse,"_ENQCODINTERNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode13 :=  WSAdvValue( oResponse,"_ITEMTIPO","ItemTipo",NIL,"Property oWSItemTipo as tns:ItemTipo on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode13 != NIL
		::oWSItemTipo := Pedido_ItemTipo():New()
		::oWSItemTipo:SoapRecv(oNode13)
	EndIf
	oNode14 :=  WSAdvValue( oResponse,"_PRESENTE","SimNao",NIL,"Property oWSPresente as tns:SimNao on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode14 != NIL
		::oWSPresente := Pedido_SimNao():New()
		::oWSPresente:SoapRecv(oNode14)
	EndIf
	::cCupom             :=  WSAdvValue( oResponse,"_CUPOM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cItemNome          :=  WSAdvValue( oResponse,"_ITEMNOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cItemMensagem      :=  WSAdvValue( oResponse,"_ITEMMENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cItemMsgPresente   :=  WSAdvValue( oResponse,"_ITEMMSGPRESENTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cItemPartNumber    :=  WSAdvValue( oResponse,"_ITEMPARTNUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodigoInterno     :=  WSAdvValue( oResponse,"_CODIGOINTERNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode21 :=  WSAdvValue( oResponse,"_FRETEGRATIS","SimNao",NIL,"Property oWSFreteGratis as tns:SimNao on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode21 != NIL
		::oWSFreteGratis := Pedido_SimNao():New()
		::oWSFreteGratis:SoapRecv(oNode21)
	EndIf
	oNode22 :=  WSAdvValue( oResponse,"_FRETEGRATISRECUSADO","FreteGratisRecusado",NIL,"Property oWSFreteGratisRecusado as tns:FreteGratisRecusado on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode22 != NIL
		::oWSFreteGratisRecusado := Pedido_FreteGratisRecusado():New()
		::oWSFreteGratisRecusado:SoapRecv(oNode22)
	EndIf
	::nItemValorFrete    :=  WSAdvValue( oResponse,"_ITEMVALORFRETE","decimal",NIL,"Property nItemValorFrete as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nItemValorFreteCobrado :=  WSAdvValue( oResponse,"_ITEMVALORFRETECOBRADO","decimal",NIL,"Property nItemValorFreteCobrado as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nItemPeso          :=  WSAdvValue( oResponse,"_ITEMPESO","decimal",NIL,"Property nItemPeso as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nItemPesoCubado    :=  WSAdvValue( oResponse,"_ITEMPESOCUBADO","decimal",NIL,"Property nItemPesoCubado as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nItemPesoCobrado   :=  WSAdvValue( oResponse,"_ITEMPESOCOBRADO","decimal",NIL,"Property nItemPesoCobrado as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nItemPesoCubadoCobrado :=  WSAdvValue( oResponse,"_ITEMPESOCUBADOCOBRADO","decimal",NIL,"Property nItemPesoCubadoCobrado as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nServicoEntregaCodigo :=  WSAdvValue( oResponse,"_SERVICOENTREGACODIGO","int",NIL,"Property nServicoEntregaCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nItemPrazoEntrega  :=  WSAdvValue( oResponse,"_ITEMPRAZOENTREGA","int",NIL,"Property nItemPrazoEntrega as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cItemDataEntrega   :=  WSAdvValue( oResponse,"_ITEMDATAENTREGA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSedex             :=  WSAdvValue( oResponse,"_SEDEX","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nListaCodigo       :=  WSAdvValue( oResponse,"_LISTACODIGO","int",NIL,"Property nListaCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cListaCodigoInterno :=  WSAdvValue( oResponse,"_LISTACODIGOINTERNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode35 :=  WSAdvValue( oResponse,"_LISTATIPOENTREGA","ListaTipoEntrega",NIL,"Property oWSListaTipoEntrega as tns:ListaTipoEntrega on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode35 != NIL
		::oWSListaTipoEntrega := Pedido_ListaTipoEntrega():New()
		::oWSListaTipoEntrega:SoapRecv(oNode35)
	EndIf
	oNode36 :=  WSAdvValue( oResponse,"_ITEMTROCA","SimNao",NIL,"Property oWSItemTroca as tns:SimNao on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode36 != NIL
		::oWSItemTroca := Pedido_SimNao():New()
		::oWSItemTroca:SoapRecv(oNode36)
	EndIf
	::cItemTexto1        :=  WSAdvValue( oResponse,"_ITEMTEXTO1","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cItemTexto2        :=  WSAdvValue( oResponse,"_ITEMTEXTO2","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cItemTexto3        :=  WSAdvValue( oResponse,"_ITEMTEXTO3","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nItemNumero1       :=  WSAdvValue( oResponse,"_ITEMNUMERO1","decimal",NIL,"Property nItemNumero1 as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nItemNumero2       :=  WSAdvValue( oResponse,"_ITEMNUMERO2","decimal",NIL,"Property nItemNumero2 as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nItemNumero3       :=  WSAdvValue( oResponse,"_ITEMNUMERO3","decimal",NIL,"Property nItemNumero3 as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode43 :=  WSAdvValue( oResponse,"_PERSONALIZACAOEXTRA","SimNao",NIL,"Property oWSPersonalizacaoExtra as tns:SimNao on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode43 != NIL
		::oWSPersonalizacaoExtra := Pedido_SimNao():New()
		::oWSPersonalizacaoExtra:SoapRecv(oNode43)
	EndIf
	::cPersonalizacaoTexto :=  WSAdvValue( oResponse,"_PERSONALIZACAOTEXTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cItemCodigoInterno :=  WSAdvValue( oResponse,"_ITEMCODIGOINTERNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSeloQuantidadeMinimaProduto1 :=  WSAdvValue( oResponse,"_SELOQUANTIDADEMINIMAPRODUTO1","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSeloQuantidadeMinimaProduto2 :=  WSAdvValue( oResponse,"_SELOQUANTIDADEMINIMAPRODUTO2","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSeloQuantidadeMinimaProduto3 :=  WSAdvValue( oResponse,"_SELOQUANTIDADEMINIMAPRODUTO3","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Enumeration ItemTipo

WSSTRUCT Pedido_ItemTipo
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedido_ItemTipo
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Nenhum" )
	aadd(::aValueList , "Produto" )
	aadd(::aValueList , "Brinde" )
	aadd(::aValueList , "ProdutoGratis" )
	aadd(::aValueList , "ValePresente" )
	aadd(::aValueList , "Personalizado" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Pedido_ItemTipo
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedido_ItemTipo
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Pedido_ItemTipo
Local oClone := Pedido_ItemTipo():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration ListaTipoEntrega

WSSTRUCT Pedido_ListaTipoEntrega
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedido_ListaTipoEntrega
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Nenhum" )
	aadd(::aValueList , "CadaCompra" )
	aadd(::aValueList , "Semanalmente" )
	aadd(::aValueList , "Unica" )
	aadd(::aValueList , "Creditos" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Pedido_ListaTipoEntrega
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedido_ListaTipoEntrega
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Pedido_ListaTipoEntrega
Local oClone := Pedido_ListaTipoEntrega():New()
	oClone:Value := ::Value
Return oClone