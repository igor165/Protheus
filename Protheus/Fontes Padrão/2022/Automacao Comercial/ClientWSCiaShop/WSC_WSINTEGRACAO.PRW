#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    https://br-store.acer.com/ws/wsintegracao.asmx?WSDL
Gerado em        03/08/19 08:34:13
Observaùùes      Cùdigo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alteraùùes neste arquivo podem causar funcionamento incorreto
                 e serùo perdidas caso o cùdigo-fonte seja gerado novamente.
=============================================================================== */

User Function _ZUMYIPA ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSIntegracao
------------------------------------------------------------------------------- */

WSCLIENT WSWSIntegracao

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Compradores
	WSMETHOD ConfirmaCompradores
	WSMETHOD Pedidos
	WSMETHOD Remessas
	WSMETHOD PedidoDocumentoFiscal
	WSMETHOD ConfirmaPedidos
	WSMETHOD StatusPedidos
	WSMETHOD Produtos
	WSMETHOD AtualizaPreco
	WSMETHOD Variantes
	WSMETHOD AtualizaEstoqueArmazem
	WSMETHOD AtualizaEstoque
	WSMETHOD ListaPresente
	WSMETHOD Descricao
	WSMETHOD Departamentos
	WSMETHOD DepartamentosProdutos
	WSMETHOD EnviaImagem
	WSMETHOD Afiliados
	WSMETHOD ConfirmaAfiliado
	WSMETHOD CamposExtras
	WSMETHOD TabelaPrecoVariante
	WSMETHOD TabelaPrecoProduto

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   clogin                    AS string
	WSDATA   csenha                    AS string
	WSDATA   cxml                      AS string
	WSDATA   nCompradoresResult        AS int
	WSDATA   lConfirmaCompradoresResult AS boolean
	WSDATA   nPedidosResult            AS int
	WSDATA   nRemessasResult           AS int
	WSDATA   lPedidoDocumentoFiscalResult AS boolean
	WSDATA   lConfirmaPedidosResult    AS boolean
	WSDATA   lStatusPedidosResult      AS boolean
	WSDATA   lProdutosResult           AS boolean
	WSDATA   lAtualizaPrecoResult      AS boolean
	WSDATA   lVariantesResult          AS boolean
	WSDATA   lAtualizaEstoqueArmazemResult AS boolean
	WSDATA   lAtualizaEstoqueResult    AS boolean
	WSDATA   lListaPresenteResult      AS boolean
	WSDATA   lDescricaoResult          AS boolean
	WSDATA   lDepartamentosResult      AS boolean
	WSDATA   lDepartamentosProdutosResult AS boolean
	WSDATA   cpassword                 AS string
	WSDATA   cstream                   AS string
	WSDATA   ccaminho                  AS string
	WSDATA   cnome_arquivo             AS string
	WSDATA   csku                      AS string
	WSDATA   nidx                      AS int
	WSDATA   ctipo                     AS string
	WSDATA   lEnviaImagemResult        AS boolean
	WSDATA   nAfiliadosResult          AS int
	WSDATA   lConfirmaAfiliadoResult   AS boolean
	WSDATA   nCamposExtrasResult       AS int
	WSDATA   lTabelaPrecoVarianteResult AS boolean
	WSDATA   lTabelaPrecoProdutoResult AS boolean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSIntegracao
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Cùdigo-Fonte Client atual requer os executùveis do Protheus Build [7.00.131227A-20181218 NG] ou superior. Atualize o Protheus ou gere o Cùdigo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSIntegracao
Return

WSMETHOD RESET WSCLIENT WSWSIntegracao
	::clogin             := NIL 
	::csenha             := NIL 
	::cxml               := NIL 
	::nCompradoresResult := NIL 
	::lConfirmaCompradoresResult := NIL 
	::nPedidosResult     := NIL 
	::nRemessasResult    := NIL 
	::lPedidoDocumentoFiscalResult := NIL 
	::lConfirmaPedidosResult := NIL 
	::lStatusPedidosResult := NIL 
	::lProdutosResult    := NIL 
	::lAtualizaPrecoResult := NIL 
	::lVariantesResult   := NIL 
	::lAtualizaEstoqueArmazemResult := NIL 
	::lAtualizaEstoqueResult := NIL 
	::lListaPresenteResult := NIL 
	::lDescricaoResult   := NIL 
	::lDepartamentosResult := NIL 
	::lDepartamentosProdutosResult := NIL 
	::cpassword          := NIL 
	::cstream            := NIL 
	::ccaminho           := NIL 
	::cnome_arquivo      := NIL 
	::csku               := NIL 
	::nidx               := NIL 
	::ctipo              := NIL 
	::lEnviaImagemResult := NIL 
	::nAfiliadosResult   := NIL 
	::lConfirmaAfiliadoResult := NIL 
	::nCamposExtrasResult := NIL 
	::lTabelaPrecoVarianteResult := NIL 
	::lTabelaPrecoProdutoResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSIntegracao
Local oClone := WSWSIntegracao():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:clogin        := ::clogin
	oClone:csenha        := ::csenha
	oClone:cxml          := ::cxml
	oClone:nCompradoresResult := ::nCompradoresResult
	oClone:lConfirmaCompradoresResult := ::lConfirmaCompradoresResult
	oClone:nPedidosResult := ::nPedidosResult
	oClone:nRemessasResult := ::nRemessasResult
	oClone:lPedidoDocumentoFiscalResult := ::lPedidoDocumentoFiscalResult
	oClone:lConfirmaPedidosResult := ::lConfirmaPedidosResult
	oClone:lStatusPedidosResult := ::lStatusPedidosResult
	oClone:lProdutosResult := ::lProdutosResult
	oClone:lAtualizaPrecoResult := ::lAtualizaPrecoResult
	oClone:lVariantesResult := ::lVariantesResult
	oClone:lAtualizaEstoqueArmazemResult := ::lAtualizaEstoqueArmazemResult
	oClone:lAtualizaEstoqueResult := ::lAtualizaEstoqueResult
	oClone:lListaPresenteResult := ::lListaPresenteResult
	oClone:lDescricaoResult := ::lDescricaoResult
	oClone:lDepartamentosResult := ::lDepartamentosResult
	oClone:lDepartamentosProdutosResult := ::lDepartamentosProdutosResult
	oClone:cpassword     := ::cpassword
	oClone:cstream       := ::cstream
	oClone:ccaminho      := ::ccaminho
	oClone:cnome_arquivo := ::cnome_arquivo
	oClone:csku          := ::csku
	oClone:nidx          := ::nidx
	oClone:ctipo         := ::ctipo
	oClone:lEnviaImagemResult := ::lEnviaImagemResult
	oClone:nAfiliadosResult := ::nAfiliadosResult
	oClone:lConfirmaAfiliadoResult := ::lConfirmaAfiliadoResult
	oClone:nCamposExtrasResult := ::nCamposExtrasResult
	oClone:lTabelaPrecoVarianteResult := ::lTabelaPrecoVarianteResult
	oClone:lTabelaPrecoProdutoResult := ::lTabelaPrecoProdutoResult
Return oClone

// WSDL Method Compradores of Service WSWSIntegracao

WSMETHOD Compradores WSSEND clogin,csenha,BYREF cxml WSRECEIVE nCompradoresResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Compradores xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Compradores>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/Compradores",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::nCompradoresResult :=  WSAdvValue( oXmlRet,"_COMPRADORESRESPONSE:_COMPRADORESRESULT:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_COMPRADORESRESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConfirmaCompradores of Service WSWSIntegracao

WSMETHOD ConfirmaCompradores WSSEND clogin,csenha,BYREF cxml WSRECEIVE lConfirmaCompradoresResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConfirmaCompradores xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConfirmaCompradores>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/ConfirmaCompradores",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::lConfirmaCompradoresResult :=  WSAdvValue( oXmlRet,"_CONFIRMACOMPRADORESRESPONSE:_CONFIRMACOMPRADORESRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_CONFIRMACOMPRADORESRESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Pedidos of Service WSWSIntegracao

WSMETHOD Pedidos WSSEND clogin,csenha,BYREF cxml WSRECEIVE nPedidosResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Pedidos xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Pedidos>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/Pedidos",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::nPedidosResult     :=  WSAdvValue( oXmlRet,"_PEDIDOSRESPONSE:_PEDIDOSRESULT:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_PEDIDOSRESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Remessas of Service WSWSIntegracao

WSMETHOD Remessas WSSEND clogin,csenha,BYREF cxml WSRECEIVE nRemessasResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Remessas xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Remessas>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/Remessas",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::nRemessasResult    :=  WSAdvValue( oXmlRet,"_REMESSASRESPONSE:_REMESSASRESULT:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_REMESSASRESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PedidoDocumentoFiscal of Service WSWSIntegracao

WSMETHOD PedidoDocumentoFiscal WSSEND clogin,csenha,BYREF cxml WSRECEIVE lPedidoDocumentoFiscalResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PedidoDocumentoFiscal xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</PedidoDocumentoFiscal>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/PedidoDocumentoFiscal",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::lPedidoDocumentoFiscalResult :=  WSAdvValue( oXmlRet,"_PEDIDODOCUMENTOFISCALRESPONSE:_PEDIDODOCUMENTOFISCALRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_PEDIDODOCUMENTOFISCALRESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConfirmaPedidos of Service WSWSIntegracao

WSMETHOD ConfirmaPedidos WSSEND clogin,csenha,BYREF cxml WSRECEIVE lConfirmaPedidosResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConfirmaPedidos xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConfirmaPedidos>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/ConfirmaPedidos",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::lConfirmaPedidosResult :=  WSAdvValue( oXmlRet,"_CONFIRMAPEDIDOSRESPONSE:_CONFIRMAPEDIDOSRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_CONFIRMAPEDIDOSRESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method StatusPedidos of Service WSWSIntegracao

WSMETHOD StatusPedidos WSSEND clogin,csenha,BYREF cxml WSRECEIVE lStatusPedidosResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<StatusPedidos xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</StatusPedidos>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/StatusPedidos",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::lStatusPedidosResult :=  WSAdvValue( oXmlRet,"_STATUSPEDIDOSRESPONSE:_STATUSPEDIDOSRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_STATUSPEDIDOSRESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Produtos of Service WSWSIntegracao

WSMETHOD Produtos WSSEND clogin,csenha,BYREF cxml WSRECEIVE lProdutosResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Produtos xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Produtos>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/Produtos",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::lProdutosResult    :=  WSAdvValue( oXmlRet,"_PRODUTOSRESPONSE:_PRODUTOSRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_PRODUTOSRESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AtualizaPreco of Service WSWSIntegracao

WSMETHOD AtualizaPreco WSSEND clogin,csenha,BYREF cxml WSRECEIVE lAtualizaPrecoResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AtualizaPreco xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</AtualizaPreco>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/AtualizaPreco",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::lAtualizaPrecoResult :=  WSAdvValue( oXmlRet,"_ATUALIZAPRECORESPONSE:_ATUALIZAPRECORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_ATUALIZAPRECORESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Variantes of Service WSWSIntegracao

WSMETHOD Variantes WSSEND clogin,csenha,BYREF cxml WSRECEIVE lVariantesResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Variantes xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Variantes>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/Variantes",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::lVariantesResult   :=  WSAdvValue( oXmlRet,"_VARIANTESRESPONSE:_VARIANTESRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_VARIANTESRESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AtualizaEstoqueArmazem of Service WSWSIntegracao

WSMETHOD AtualizaEstoqueArmazem WSSEND clogin,csenha,BYREF cxml WSRECEIVE lAtualizaEstoqueArmazemResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AtualizaEstoqueArmazem xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</AtualizaEstoqueArmazem>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/AtualizaEstoqueArmazem",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::lAtualizaEstoqueArmazemResult :=  WSAdvValue( oXmlRet,"_ATUALIZAESTOQUEARMAZEMRESPONSE:_ATUALIZAESTOQUEARMAZEMRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_ATUALIZAESTOQUEARMAZEMRESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AtualizaEstoque of Service WSWSIntegracao

WSMETHOD AtualizaEstoque WSSEND clogin,csenha,BYREF cxml WSRECEIVE lAtualizaEstoqueResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AtualizaEstoque xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</AtualizaEstoque>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/AtualizaEstoque",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::lAtualizaEstoqueResult :=  WSAdvValue( oXmlRet,"_ATUALIZAESTOQUERESPONSE:_ATUALIZAESTOQUERESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_ATUALIZAESTOQUERESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ListaPresente of Service WSWSIntegracao

WSMETHOD ListaPresente WSSEND clogin,csenha,BYREF cxml WSRECEIVE lListaPresenteResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ListaPresente xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ListaPresente>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/ListaPresente",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::lListaPresenteResult :=  WSAdvValue( oXmlRet,"_LISTAPRESENTERESPONSE:_LISTAPRESENTERESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_LISTAPRESENTERESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Descricao of Service WSWSIntegracao

WSMETHOD Descricao WSSEND clogin,csenha,BYREF cxml WSRECEIVE lDescricaoResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Descricao xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Descricao>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/Descricao",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::lDescricaoResult   :=  WSAdvValue( oXmlRet,"_DESCRICAORESPONSE:_DESCRICAORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_DESCRICAORESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Departamentos of Service WSWSIntegracao

WSMETHOD Departamentos WSSEND clogin,csenha,BYREF cxml WSRECEIVE lDepartamentosResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Departamentos xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Departamentos>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/Departamentos",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::lDepartamentosResult :=  WSAdvValue( oXmlRet,"_DEPARTAMENTOSRESPONSE:_DEPARTAMENTOSRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_DEPARTAMENTOSRESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method DepartamentosProdutos of Service WSWSIntegracao

WSMETHOD DepartamentosProdutos WSSEND clogin,csenha,BYREF cxml WSRECEIVE lDepartamentosProdutosResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DepartamentosProdutos xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</DepartamentosProdutos>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/DepartamentosProdutos",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::lDepartamentosProdutosResult :=  WSAdvValue( oXmlRet,"_DEPARTAMENTOSPRODUTOSRESPONSE:_DEPARTAMENTOSPRODUTOSRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_DEPARTAMENTOSPRODUTOSRESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EnviaImagem of Service WSWSIntegracao

WSMETHOD EnviaImagem WSSEND clogin,cpassword,cstream,ccaminho,cnome_arquivo,csku,nidx,ctipo,BYREF cxml WSRECEIVE lEnviaImagemResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EnviaImagem xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("stream", ::cstream, cstream , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("caminho", ::ccaminho, ccaminho , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("nome_arquivo", ::cnome_arquivo, cnome_arquivo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sku", ::csku, csku , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("idx", ::nidx, nidx , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("tipo", ::ctipo, ctipo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</EnviaImagem>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/EnviaImagem",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::lEnviaImagemResult :=  WSAdvValue( oXmlRet,"_ENVIAIMAGEMRESPONSE:_ENVIAIMAGEMRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_ENVIAIMAGEMRESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Afiliados of Service WSWSIntegracao

WSMETHOD Afiliados WSSEND clogin,csenha,BYREF cxml WSRECEIVE nAfiliadosResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Afiliados xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Afiliados>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/Afiliados",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::nAfiliadosResult   :=  WSAdvValue( oXmlRet,"_AFILIADOSRESPONSE:_AFILIADOSRESULT:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_AFILIADOSRESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConfirmaAfiliado of Service WSWSIntegracao

WSMETHOD ConfirmaAfiliado WSSEND clogin,csenha,BYREF cxml WSRECEIVE lConfirmaAfiliadoResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConfirmaAfiliado xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConfirmaAfiliado>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/ConfirmaAfiliado",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::lConfirmaAfiliadoResult :=  WSAdvValue( oXmlRet,"_CONFIRMAAFILIADORESPONSE:_CONFIRMAAFILIADORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_CONFIRMAAFILIADORESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CamposExtras of Service WSWSIntegracao

WSMETHOD CamposExtras WSSEND clogin,csenha,BYREF cxml WSRECEIVE nCamposExtrasResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CamposExtras xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CamposExtras>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/CamposExtras",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::nCamposExtrasResult :=  WSAdvValue( oXmlRet,"_CAMPOSEXTRASRESPONSE:_CAMPOSEXTRASRESULT:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_CAMPOSEXTRASRESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method TabelaPrecoVariante of Service WSWSIntegracao

WSMETHOD TabelaPrecoVariante WSSEND clogin,csenha,BYREF cxml WSRECEIVE lTabelaPrecoVarianteResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<TabelaPrecoVariante xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</TabelaPrecoVariante>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/TabelaPrecoVariante",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::lTabelaPrecoVarianteResult :=  WSAdvValue( oXmlRet,"_TABELAPRECOVARIANTERESPONSE:_TABELAPRECOVARIANTERESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_TABELAPRECOVARIANTERESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method TabelaPrecoProduto of Service WSWSIntegracao

WSMETHOD TabelaPrecoProduto WSSEND clogin,csenha,BYREF cxml WSRECEIVE lTabelaPrecoProdutoResult WSCLIENT WSWSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<TabelaPrecoProduto xmlns="WSIntegB2C">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</TabelaPrecoProduto>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"WSIntegB2C/TabelaPrecoProduto",; 
	"DOCUMENT","WSIntegB2C",,,; 
	"https://br-store.acer.com/ws/wsintegracao.asmx")

::Init()
::lTabelaPrecoProdutoResult :=  WSAdvValue( oXmlRet,"_TABELAPRECOPRODUTORESPONSE:_TABELAPRECOPRODUTORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cxml               :=  WSAdvValue( oXmlRet,"_TABELAPRECOPRODUTORESPONSE:_XML:TEXT","string",NIL,NIL,NIL,NIL,@cxml,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.