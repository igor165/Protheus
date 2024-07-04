#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://homologacao.ikeda.com.br/totvs/ikcwebservice/produto.asmx?WSDL
Gerado em        01/24/13 10:04:33
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.111215
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _VLSSGDE ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSProduto
------------------------------------------------------------------------------- */

WSCLIENT WSProduto

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Salvar
	WSMETHOD AlterarPreco
	WSMETHOD AlterarStatus
	WSMETHOD Excluir
	WSMETHOD Listar
	WSMETHOD SalvarPersonalizacao

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   nLojaCodigo               AS int
	WSDATA   cCodigoInternoProduto     AS string
	WSDATA   cCodigoInternoFornecedor  AS string
	WSDATA   cNomeProduto              AS string
	WSDATA   cTituloProduto            AS string
	WSDATA   cSubTituloProduto         AS string
	WSDATA   cDescricaoProduto         AS string
	WSDATA   cCaracteristicaProduto    AS string
	WSDATA   cTexto1Produto            AS string
	WSDATA   cTexto2Produto            AS string
	WSDATA   cTexto3Produto            AS string
	WSDATA   cTexto4Produto            AS string
	WSDATA   cTexto5Produto            AS string
	WSDATA   cTexto6Produto            AS string
	WSDATA   cTexto7Produto            AS string
	WSDATA   cTexto8Produto            AS string
	WSDATA   cTexto9Produto            AS string
	WSDATA   cTexto10Produto           AS string
	WSDATA   nNumero1Produto           AS int
	WSDATA   nNumero2Produto           AS int
	WSDATA   nNumero3Produto           AS int
	WSDATA   nNumero4Produto           AS int
	WSDATA   nNumero5Produto           AS int
	WSDATA   nNumero6Produto           AS int
	WSDATA   nNumero7Produto           AS int
	WSDATA   nNumero8Produto           AS int
	WSDATA   nNumero9Produto           AS int
	WSDATA   nNumero10Produto          AS int
	WSDATA   cCodigoInternoEnquadramento AS string
	WSDATA   cModeloProduto            AS string
	WSDATA   nPesoProduto              AS decimal
	WSDATA   nPesoEmbalagemProduto     AS decimal
	WSDATA   nAlturaProduto            AS decimal
	WSDATA   nAlturaEmbalagemProduto   AS decimal
	WSDATA   nLarguraProduto           AS decimal
	WSDATA   nLarguraEmbalagemProduto  AS decimal
	WSDATA   nProfundidadeProduto      AS decimal
	WSDATA   nProfundidadeEmbalagemProduto AS decimal
	WSDATA   nEntregaProduto           AS int
	WSDATA   nQuantidadeMaximaPorVenda AS int
	WSDATA   nStatusProduto            AS int
	WSDATA   cTipoProduto              AS string
	WSDATA   nPresente                 AS int
	WSDATA   nPrecoCheioProduto        AS decimal
	WSDATA   nPrecoPor                 AS decimal
	WSDATA   nPersonalizacaoExtra      AS int
	WSDATA   cPersonalizacaoLabel      AS string
	WSDATA   cISBN                     AS string
	WSDATA   cEAN13                    AS string
	WSDATA   cYouTubeCode              AS string
	WSDATA   cA1                       AS string
	WSDATA   cA2                       AS string
	WSDATA   oWS                       AS SCHEMA
	WSDATA   oWSSalvarResult           AS Produto_clsRetornoOfclsProduto
	WSDATA   nPrecoCheio               AS decimal
	WSDATA   oWSAlterarPrecoResult     AS Produto_clsRetornoOfclsProduto
	WSDATA   oWSAlterarStatusResult    AS Produto_clsRetornoOfclsProduto
	WSDATA   oWSExcluirResult          AS Produto_clsRetornoOfclsProduto
	WSDATA   cCodigoInternoFabricante  AS string
	WSDATA   nProdutoStatus            AS int
	WSDATA   oWSListarResult           AS Produto_clsRetornoOfclsProduto
	WSDATA   cCodigoInternoProdutoPrincipal AS string
	WSDATA   cCodigoInternoProdutoPersonalizacao AS string
	WSDATA   nStatusPersonlizacao      AS int
	WSDATA   oWSSalvarPersonalizacaoResult AS Produto_clsRetornoOfclsProdutoPersonalizacao

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSProduto
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.111010P-20120120] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
If val(right(GetWSCVer(),8)) < 1.040504
	UserException("O Código-Fonte Client atual requer a versão de Lib para WebServices igual ou superior a ADVPL WSDL Client 1.040504. Atualize o repositório ou gere o Código-Fonte novamente utilizando o repositório atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSProduto
	::oWS                := NIL 
	::oWSSalvarResult    := Produto_CLSRETORNOOFCLSPRODUTO():New()
	::oWSAlterarPrecoResult := Produto_CLSRETORNOOFCLSPRODUTO():New()
	::oWSAlterarStatusResult := Produto_CLSRETORNOOFCLSPRODUTO():New()
	::oWSExcluirResult   := Produto_CLSRETORNOOFCLSPRODUTO():New()
	::oWSListarResult    := Produto_CLSRETORNOOFCLSPRODUTO():New()
	::oWSSalvarPersonalizacaoResult := Produto_CLSRETORNOOFCLSPRODUTOPERSONALIZACAO():New()
Return

WSMETHOD RESET WSCLIENT WSProduto
	::nLojaCodigo        := NIL 
	::cCodigoInternoProduto := NIL 
	::cCodigoInternoFornecedor := NIL 
	::cNomeProduto       := NIL 
	::cTituloProduto     := NIL 
	::cSubTituloProduto  := NIL 
	::cDescricaoProduto  := NIL 
	::cCaracteristicaProduto := NIL 
	::cTexto1Produto     := NIL 
	::cTexto2Produto     := NIL 
	::cTexto3Produto     := NIL 
	::cTexto4Produto     := NIL 
	::cTexto5Produto     := NIL 
	::cTexto6Produto     := NIL 
	::cTexto7Produto     := NIL 
	::cTexto8Produto     := NIL 
	::cTexto9Produto     := NIL 
	::cTexto10Produto    := NIL 
	::nNumero1Produto    := NIL 
	::nNumero2Produto    := NIL 
	::nNumero3Produto    := NIL 
	::nNumero4Produto    := NIL 
	::nNumero5Produto    := NIL 
	::nNumero6Produto    := NIL 
	::nNumero7Produto    := NIL 
	::nNumero8Produto    := NIL 
	::nNumero9Produto    := NIL 
	::nNumero10Produto   := NIL 
	::cCodigoInternoEnquadramento := NIL 
	::cModeloProduto     := NIL 
	::nPesoProduto       := NIL 
	::nPesoEmbalagemProduto := NIL 
	::nAlturaProduto     := NIL 
	::nAlturaEmbalagemProduto := NIL 
	::nLarguraProduto    := NIL 
	::nLarguraEmbalagemProduto := NIL 
	::nProfundidadeProduto := NIL 
	::nProfundidadeEmbalagemProduto := NIL 
	::nEntregaProduto    := NIL 
	::nQuantidadeMaximaPorVenda := NIL 
	::nStatusProduto     := NIL 
	::cTipoProduto       := NIL 
	::nPresente          := NIL 
	::nPrecoCheioProduto := NIL 
	::nPrecoPor          := NIL 
	::nPersonalizacaoExtra := NIL 
	::cPersonalizacaoLabel := NIL 
	::cISBN              := NIL 
	::cEAN13             := NIL 
	::cYouTubeCode       := NIL 
	::cA1                := NIL 
	::cA2                := NIL 
	::oWS                := NIL 
	::oWSSalvarResult    := NIL 
	::nPrecoCheio        := NIL 
	::oWSAlterarPrecoResult := NIL 
	::oWSAlterarStatusResult := NIL 
	::oWSExcluirResult   := NIL 
	::cCodigoInternoFabricante := NIL 
	::nProdutoStatus     := NIL 
	::oWSListarResult    := NIL 
	::cCodigoInternoProdutoPrincipal := NIL 
	::cCodigoInternoProdutoPersonalizacao := NIL 
	::nStatusPersonlizacao := NIL 
	::oWSSalvarPersonalizacaoResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSProduto
Local oClone := WSProduto():New()
	oClone:_URL          := ::_URL 
	oClone:nLojaCodigo   := ::nLojaCodigo
	oClone:cCodigoInternoProduto := ::cCodigoInternoProduto
	oClone:cCodigoInternoFornecedor := ::cCodigoInternoFornecedor
	oClone:cNomeProduto  := ::cNomeProduto
	oClone:cTituloProduto := ::cTituloProduto
	oClone:cSubTituloProduto := ::cSubTituloProduto
	oClone:cDescricaoProduto := ::cDescricaoProduto
	oClone:cCaracteristicaProduto := ::cCaracteristicaProduto
	oClone:cTexto1Produto := ::cTexto1Produto
	oClone:cTexto2Produto := ::cTexto2Produto
	oClone:cTexto3Produto := ::cTexto3Produto
	oClone:cTexto4Produto := ::cTexto4Produto
	oClone:cTexto5Produto := ::cTexto5Produto
	oClone:cTexto6Produto := ::cTexto6Produto
	oClone:cTexto7Produto := ::cTexto7Produto
	oClone:cTexto8Produto := ::cTexto8Produto
	oClone:cTexto9Produto := ::cTexto9Produto
	oClone:cTexto10Produto := ::cTexto10Produto
	oClone:nNumero1Produto := ::nNumero1Produto
	oClone:nNumero2Produto := ::nNumero2Produto
	oClone:nNumero3Produto := ::nNumero3Produto
	oClone:nNumero4Produto := ::nNumero4Produto
	oClone:nNumero5Produto := ::nNumero5Produto
	oClone:nNumero6Produto := ::nNumero6Produto
	oClone:nNumero7Produto := ::nNumero7Produto
	oClone:nNumero8Produto := ::nNumero8Produto
	oClone:nNumero9Produto := ::nNumero9Produto
	oClone:nNumero10Produto := ::nNumero10Produto
	oClone:cCodigoInternoEnquadramento := ::cCodigoInternoEnquadramento
	oClone:cModeloProduto := ::cModeloProduto
	oClone:nPesoProduto  := ::nPesoProduto
	oClone:nPesoEmbalagemProduto := ::nPesoEmbalagemProduto
	oClone:nAlturaProduto := ::nAlturaProduto
	oClone:nAlturaEmbalagemProduto := ::nAlturaEmbalagemProduto
	oClone:nLarguraProduto := ::nLarguraProduto
	oClone:nLarguraEmbalagemProduto := ::nLarguraEmbalagemProduto
	oClone:nProfundidadeProduto := ::nProfundidadeProduto
	oClone:nProfundidadeEmbalagemProduto := ::nProfundidadeEmbalagemProduto
	oClone:nEntregaProduto := ::nEntregaProduto
	oClone:nQuantidadeMaximaPorVenda := ::nQuantidadeMaximaPorVenda
	oClone:nStatusProduto := ::nStatusProduto
	oClone:cTipoProduto  := ::cTipoProduto
	oClone:nPresente     := ::nPresente
	oClone:nPrecoCheioProduto := ::nPrecoCheioProduto
	oClone:nPrecoPor     := ::nPrecoPor
	oClone:nPersonalizacaoExtra := ::nPersonalizacaoExtra
	oClone:cPersonalizacaoLabel := ::cPersonalizacaoLabel
	oClone:cISBN         := ::cISBN
	oClone:cEAN13        := ::cEAN13
	oClone:cYouTubeCode  := ::cYouTubeCode
	oClone:cA1           := ::cA1
	oClone:cA2           := ::cA2
	oClone:oWSSalvarResult :=  IIF(::oWSSalvarResult = NIL , NIL ,::oWSSalvarResult:Clone() )
	oClone:nPrecoCheio   := ::nPrecoCheio
	oClone:oWSAlterarPrecoResult :=  IIF(::oWSAlterarPrecoResult = NIL , NIL ,::oWSAlterarPrecoResult:Clone() )
	oClone:oWSAlterarStatusResult :=  IIF(::oWSAlterarStatusResult = NIL , NIL ,::oWSAlterarStatusResult:Clone() )
	oClone:oWSExcluirResult :=  IIF(::oWSExcluirResult = NIL , NIL ,::oWSExcluirResult:Clone() )
	oClone:cCodigoInternoFabricante := ::cCodigoInternoFabricante
	oClone:nProdutoStatus := ::nProdutoStatus
	oClone:oWSListarResult :=  IIF(::oWSListarResult = NIL , NIL ,::oWSListarResult:Clone() )
	oClone:cCodigoInternoProdutoPrincipal := ::cCodigoInternoProdutoPrincipal
	oClone:cCodigoInternoProdutoPersonalizacao := ::cCodigoInternoProdutoPersonalizacao
	oClone:nStatusPersonlizacao := ::nStatusPersonlizacao
	oClone:oWSSalvarPersonalizacaoResult :=  IIF(::oWSSalvarPersonalizacaoResult = NIL , NIL ,::oWSSalvarPersonalizacaoResult:Clone() )
Return oClone

// WSDL Method Salvar of Service WSProduto

WSMETHOD Salvar WSSEND nLojaCodigo,cCodigoInternoProduto,cCodigoInternoFornecedor,cNomeProduto,cTituloProduto,cSubTituloProduto,cDescricaoProduto,cCaracteristicaProduto,cTexto1Produto,cTexto2Produto,cTexto3Produto,cTexto4Produto,cTexto5Produto,cTexto6Produto,cTexto7Produto,cTexto8Produto,cTexto9Produto,cTexto10Produto,nNumero1Produto,nNumero2Produto,nNumero3Produto,nNumero4Produto,nNumero5Produto,nNumero6Produto,nNumero7Produto,nNumero8Produto,nNumero9Produto,nNumero10Produto,cCodigoInternoEnquadramento,cModeloProduto,nPesoProduto,nPesoEmbalagemProduto,nAlturaProduto,nAlturaEmbalagemProduto,nLarguraProduto,nLarguraEmbalagemProduto,nProfundidadeProduto,nProfundidadeEmbalagemProduto,nEntregaProduto,nQuantidadeMaximaPorVenda,nStatusProduto,cTipoProduto,nPresente,nPrecoCheioProduto,nPrecoPor,nPersonalizacaoExtra,cPersonalizacaoLabel,cISBN,cEAN13,cYouTubeCode,cA1,cA2,oWS WSRECEIVE oWSSalvarResult WSCLIENT WSProduto
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
cSoap += WSSoapValue("CodigoInternoFornecedor", ::cCodigoInternoFornecedor, cCodigoInternoFornecedor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NomeProduto", ::cNomeProduto, cNomeProduto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("TituloProduto", ::cTituloProduto, cTituloProduto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("SubTituloProduto", ::cSubTituloProduto, cSubTituloProduto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DescricaoProduto", ::cDescricaoProduto, cDescricaoProduto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CaracteristicaProduto", ::cCaracteristicaProduto, cCaracteristicaProduto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Texto1Produto", ::cTexto1Produto, cTexto1Produto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Texto2Produto", ::cTexto2Produto, cTexto2Produto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Texto3Produto", ::cTexto3Produto, cTexto3Produto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Texto4Produto", ::cTexto4Produto, cTexto4Produto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Texto5Produto", ::cTexto5Produto, cTexto5Produto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Texto6Produto", ::cTexto6Produto, cTexto6Produto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Texto7Produto", ::cTexto7Produto, cTexto7Produto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Texto8Produto", ::cTexto8Produto, cTexto8Produto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Texto9Produto", ::cTexto9Produto, cTexto9Produto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Texto10Produto", ::cTexto10Produto, cTexto10Produto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Numero1Produto", ::nNumero1Produto, nNumero1Produto , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Numero2Produto", ::nNumero2Produto, nNumero2Produto , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Numero3Produto", ::nNumero3Produto, nNumero3Produto , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Numero4Produto", ::nNumero4Produto, nNumero4Produto , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Numero5Produto", ::nNumero5Produto, nNumero5Produto , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Numero6Produto", ::nNumero6Produto, nNumero6Produto , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Numero7Produto", ::nNumero7Produto, nNumero7Produto , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Numero8Produto", ::nNumero8Produto, nNumero8Produto , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Numero9Produto", ::nNumero9Produto, nNumero9Produto , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Numero10Produto", ::nNumero10Produto, nNumero10Produto , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoInternoEnquadramento", ::cCodigoInternoEnquadramento, cCodigoInternoEnquadramento , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ModeloProduto", ::cModeloProduto, cModeloProduto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PesoProduto", ::nPesoProduto, nPesoProduto , "decimal", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PesoEmbalagemProduto", ::nPesoEmbalagemProduto, nPesoEmbalagemProduto , "decimal", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("AlturaProduto", ::nAlturaProduto, nAlturaProduto , "decimal", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("AlturaEmbalagemProduto", ::nAlturaEmbalagemProduto, nAlturaEmbalagemProduto , "decimal", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("LarguraProduto", ::nLarguraProduto, nLarguraProduto , "decimal", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("LarguraEmbalagemProduto", ::nLarguraEmbalagemProduto, nLarguraEmbalagemProduto , "decimal", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ProfundidadeProduto", ::nProfundidadeProduto, nProfundidadeProduto , "decimal", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ProfundidadeEmbalagemProduto", ::nProfundidadeEmbalagemProduto, nProfundidadeEmbalagemProduto , "decimal", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EntregaProduto", ::nEntregaProduto, nEntregaProduto , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("QuantidadeMaximaPorVenda", ::nQuantidadeMaximaPorVenda, nQuantidadeMaximaPorVenda , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("StatusProduto", ::nStatusProduto, nStatusProduto , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("TipoProduto", ::cTipoProduto, cTipoProduto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Presente", ::nPresente, nPresente , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PrecoCheioProduto", ::nPrecoCheioProduto, nPrecoCheioProduto , "decimal", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PrecoPor", ::nPrecoPor, nPrecoPor , "decimal", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PersonalizacaoExtra", ::nPersonalizacaoExtra, nPersonalizacaoExtra , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PersonalizacaoLabel", ::cPersonalizacaoLabel, cPersonalizacaoLabel , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ISBN", ::cISBN, cISBN , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EAN13", ::cEAN13, cEAN13 , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("YouTubeCode", ::cYouTubeCode, cYouTubeCode , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Salvar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Salvar",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/produto.asmx")

::Init()
::oWSSalvarResult:SoapRecv( WSAdvValue( oXmlRet,"_SALVARRESPONSE:_SALVARRESULT","clsRetornoOfclsProduto",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AlterarPreco of Service WSProduto

WSMETHOD AlterarPreco WSSEND nLojaCodigo,cCodigoInternoProduto,nPrecoCheio,nPrecoPor,cA1,cA2,oWS WSRECEIVE oWSAlterarPrecoResult WSCLIENT WSProduto
Local cSoap := "" , oXmlRet
Local cSoapHead := "" 

BEGIN WSMETHOD

cSoapHead += '<clsSoapHeader xmlns="http://www.ikeda.com.br">'
cSoapHead += WSSoapValue("A1", ::cA1, cA1 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("A2", ::cA2, cA2 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("", ::oWS, oWS , "SCHEMA", .F. , .F., 0 , NIL, .F.) 
cSoapHead +=  "</clsSoapHeader>"

cSoap += '<AlterarPreco xmlns="http://www.ikeda.com.br">'
cSoap += WSSoapValue("LojaCodigo", ::nLojaCodigo, nLojaCodigo , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoInternoProduto", ::cCodigoInternoProduto, cCodigoInternoProduto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PrecoCheio", ::nPrecoCheio, nPrecoCheio , "decimal", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PrecoPor", ::nPrecoPor, nPrecoPor , "decimal", .T. , .F., 0 , NIL, .F.) 
cSoap += "</AlterarPreco>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/AlterarPreco",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/produto.asmx")

::Init()
::oWSAlterarPrecoResult:SoapRecv( WSAdvValue( oXmlRet,"_ALTERARPRECORESPONSE:_ALTERARPRECORESULT","clsRetornoOfclsProduto",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AlterarStatus of Service WSProduto

WSMETHOD AlterarStatus WSSEND nLojaCodigo,cCodigoInternoProduto,nStatusProduto,cA1,cA2,oWS WSRECEIVE oWSAlterarStatusResult WSCLIENT WSProduto
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
cSoap += WSSoapValue("CodigoInternoProduto", ::cCodigoInternoProduto, cCodigoInternoProduto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("StatusProduto", ::nStatusProduto, nStatusProduto , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += "</AlterarStatus>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/AlterarStatus",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/produto.asmx")

::Init()
::oWSAlterarStatusResult:SoapRecv( WSAdvValue( oXmlRet,"_ALTERARSTATUSRESPONSE:_ALTERARSTATUSRESULT","clsRetornoOfclsProduto",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Excluir of Service WSProduto

WSMETHOD Excluir WSSEND nLojaCodigo,cCodigoInternoProduto,cA1,cA2,oWS WSRECEIVE oWSExcluirResult WSCLIENT WSProduto
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
cSoap += "</Excluir>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Excluir",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/produto.asmx")

::Init()
::oWSExcluirResult:SoapRecv( WSAdvValue( oXmlRet,"_EXCLUIRRESPONSE:_EXCLUIRRESULT","clsRetornoOfclsProduto",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Listar of Service WSProduto

WSMETHOD Listar WSSEND nLojaCodigo,cCodigoInternoProduto,cCodigoInternoFabricante,cNomeProduto,nProdutoStatus,nTipoProduto,cA1,cA2,oWS WSRECEIVE oWSListarResult WSCLIENT WSProduto
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
cSoap += WSSoapValue("CodigoInternoProduto", ::cCodigoInternoProduto, cCodigoInternoProduto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoInternoFabricante", ::cCodigoInternoFabricante, cCodigoInternoFabricante , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NomeProduto", ::cNomeProduto, cNomeProduto , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ProdutoStatus", ::nProdutoStatus, nProdutoStatus , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("TipoProduto", ::nTipoProduto, nTipoProduto , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += "</Listar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Listar",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/produto.asmx")

::Init()
::oWSListarResult:SoapRecv( WSAdvValue( oXmlRet,"_LISTARRESPONSE:_LISTARRESULT","clsRetornoOfclsProduto",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SalvarPersonalizacao of Service WSProduto

WSMETHOD SalvarPersonalizacao WSSEND nLojaCodigo,cCodigoInternoProdutoPrincipal,cCodigoInternoProdutoPersonalizacao,nStatusPersonlizacao,cA1,cA2,oWS WSRECEIVE oWSSalvarPersonalizacaoResult WSCLIENT WSProduto
Local cSoap := "" , oXmlRet
Local cSoapHead := "" 

BEGIN WSMETHOD

cSoapHead += '<clsSoapHeader xmlns="http://www.ikeda.com.br">'
cSoapHead += WSSoapValue("A1", ::cA1, cA1 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("A2", ::cA2, cA2 , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("", ::oWS, oWS , "SCHEMA", .F. , .F., 0 , NIL, .F.) 
cSoapHead +=  "</clsSoapHeader>"

cSoap += '<SalvarPersonalizacao xmlns="http://www.ikeda.com.br">'
cSoap += WSSoapValue("LojaCodigo", ::nLojaCodigo, nLojaCodigo , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoInternoProdutoPrincipal", ::cCodigoInternoProdutoPrincipal, cCodigoInternoProdutoPrincipal , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CodigoInternoProdutoPersonalizacao", ::cCodigoInternoProdutoPersonalizacao, cCodigoInternoProdutoPersonalizacao , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("StatusPersonlizacao", ::nStatusPersonlizacao, nStatusPersonlizacao , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += "</SalvarPersonalizacao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/SalvarPersonalizacao",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/produto.asmx")

::Init()
::oWSSalvarPersonalizacaoResult:SoapRecv( WSAdvValue( oXmlRet,"_SALVARPERSONALIZACAORESPONSE:_SALVARPERSONALIZACAORESULT","clsRetornoOfclsProdutoPersonalizacao",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure clsRetornoOfclsProduto

WSSTRUCT Produto_clsRetornoOfclsProduto
	WSDATA   cAcao                     AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   nCodigo                   AS int
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   oWSLista                  AS Produto_ArrayOfClsProduto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Produto_clsRetornoOfclsProduto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Produto_clsRetornoOfclsProduto
Return

WSMETHOD CLONE WSCLIENT Produto_clsRetornoOfclsProduto
	Local oClone := Produto_clsRetornoOfclsProduto():NEW()
	oClone:cAcao                := ::cAcao
	oClone:cData                := ::cData
	oClone:nCodigo              := ::nCodigo
	oClone:cDescricao           := ::cDescricao
	oClone:oWSLista             := IIF(::oWSLista = NIL , NIL , ::oWSLista:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Produto_clsRetornoOfclsProduto
	Local oNode5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAcao              :=  WSAdvValue( oResponse,"_ACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nCodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,"Property nCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode5 :=  WSAdvValue( oResponse,"_LISTA","ArrayOfClsProduto",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSLista := Produto_ArrayOfClsProduto():New()
		::oWSLista:SoapRecv(oNode5)
	EndIf
Return

// WSDL Data Structure clsRetornoOfclsProdutoPersonalizacao

WSSTRUCT Produto_clsRetornoOfclsProdutoPersonalizacao
	WSDATA   cAcao                     AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   nCodigo                   AS int
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   oWSLista                  AS Produto_ArrayOfClsProdutoPersonalizacao OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Produto_clsRetornoOfclsProdutoPersonalizacao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Produto_clsRetornoOfclsProdutoPersonalizacao
Return

WSMETHOD CLONE WSCLIENT Produto_clsRetornoOfclsProdutoPersonalizacao
	Local oClone := Produto_clsRetornoOfclsProdutoPersonalizacao():NEW()
	oClone:cAcao                := ::cAcao
	oClone:cData                := ::cData
	oClone:nCodigo              := ::nCodigo
	oClone:cDescricao           := ::cDescricao
	oClone:oWSLista             := IIF(::oWSLista = NIL , NIL , ::oWSLista:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Produto_clsRetornoOfclsProdutoPersonalizacao
	Local oNode5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAcao              :=  WSAdvValue( oResponse,"_ACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nCodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,"Property nCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode5 :=  WSAdvValue( oResponse,"_LISTA","ArrayOfClsProdutoPersonalizacao",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSLista := Produto_ArrayOfClsProdutoPersonalizacao():New()
		::oWSLista:SoapRecv(oNode5)
	EndIf
Return

// WSDL Data Structure ArrayOfClsProduto

WSSTRUCT Produto_ArrayOfClsProduto
	WSDATA   oWSclsProduto             AS Produto_clsProduto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Produto_ArrayOfClsProduto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Produto_ArrayOfClsProduto
	::oWSclsProduto        := {} // Array Of  Produto_CLSPRODUTO():New()
Return

WSMETHOD CLONE WSCLIENT Produto_ArrayOfClsProduto
	Local oClone := Produto_ArrayOfClsProduto():NEW()
	oClone:oWSclsProduto := NIL
	If ::oWSclsProduto <> NIL 
		oClone:oWSclsProduto := {}
		aEval( ::oWSclsProduto , { |x| aadd( oClone:oWSclsProduto , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Produto_ArrayOfClsProduto
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLSPRODUTO","clsProduto",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclsProduto , Produto_clsProduto():New() )
			::oWSclsProduto[len(::oWSclsProduto)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfClsProdutoPersonalizacao

WSSTRUCT Produto_ArrayOfClsProdutoPersonalizacao
	WSDATA   oWSclsProdutoPersonalizacao AS Produto_clsProdutoPersonalizacao OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Produto_ArrayOfClsProdutoPersonalizacao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Produto_ArrayOfClsProdutoPersonalizacao
	::oWSclsProdutoPersonalizacao := {} // Array Of  Produto_CLSPRODUTOPERSONALIZACAO():New()
Return

WSMETHOD CLONE WSCLIENT Produto_ArrayOfClsProdutoPersonalizacao
	Local oClone := Produto_ArrayOfClsProdutoPersonalizacao():NEW()
	oClone:oWSclsProdutoPersonalizacao := NIL
	If ::oWSclsProdutoPersonalizacao <> NIL 
		oClone:oWSclsProdutoPersonalizacao := {}
		aEval( ::oWSclsProdutoPersonalizacao , { |x| aadd( oClone:oWSclsProdutoPersonalizacao , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Produto_ArrayOfClsProdutoPersonalizacao
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLSPRODUTOPERSONALIZACAO","clsProdutoPersonalizacao",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclsProdutoPersonalizacao , Produto_clsProdutoPersonalizacao():New() )
			::oWSclsProdutoPersonalizacao[len(::oWSclsProdutoPersonalizacao)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure clsProduto

WSSTRUCT Produto_clsProduto
	WSDATA   nLojaCodigo               AS int
	WSDATA   cProdutoCodigoInterno     AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cTitulo                   AS string OPTIONAL
	WSDATA   cSubtitulo                AS string OPTIONAL
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   cCaracteristica           AS string OPTIONAL
	WSDATA   cTexto1                   AS string OPTIONAL
	WSDATA   cTexto2                   AS string OPTIONAL
	WSDATA   cTexto3                   AS string OPTIONAL
	WSDATA   cTexto4                   AS string OPTIONAL
	WSDATA   cTexto5                   AS string OPTIONAL
	WSDATA   cTexto6                   AS string OPTIONAL
	WSDATA   cTexto7                   AS string OPTIONAL
	WSDATA   cTexto8                   AS string OPTIONAL
	WSDATA   cTexto9                   AS string OPTIONAL
	WSDATA   cTexto10                  AS string OPTIONAL
	WSDATA   nNumero1                  AS decimal
	WSDATA   nNumero2                  AS decimal
	WSDATA   nNumero3                  AS decimal
	WSDATA   nNumero4                  AS decimal
	WSDATA   nNumero5                  AS decimal
	WSDATA   nNumero6                  AS decimal
	WSDATA   nNumero7                  AS decimal
	WSDATA   nNumero8                  AS decimal
	WSDATA   nNumero9                  AS decimal
	WSDATA   nNumero10                 AS decimal
	WSDATA   nPeso                     AS decimal
	WSDATA   nAltura                   AS decimal
	WSDATA   nLargura                  AS decimal
	WSDATA   nProfundidade             AS decimal
	WSDATA   nPesoEmbalagem            AS decimal
	WSDATA   nAlturaEmbalagem          AS decimal
	WSDATA   nLarguraEmbalagem         AS decimal
	WSDATA   nProfundidadeEmbalagem    AS decimal
	WSDATA   nPrecoCheio               AS decimal
	WSDATA   nPrecoPor                 AS decimal
	WSDATA   nEntrega                  AS int
	WSDATA   nQuantidadeMaximaPorVenda AS int
	WSDATA   oWSProdutoStatus          AS Produto_ProdutoStatus
	WSDATA   oWSTipo                   AS Produto_ProdutoTipo
	WSDATA   oWSPresente               AS Produto_SimNao
	WSDATA   oWSPersonalizacaoExtra    AS Produto_SimNao
	WSDATA   cPersonalizacaoLabel      AS string OPTIONAL
	WSDATA   cISBN                     AS string OPTIONAL
	WSDATA   cEAN13                    AS string OPTIONAL
	WSDATA   cYouTubeCode              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Produto_clsProduto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Produto_clsProduto
Return

WSMETHOD CLONE WSCLIENT Produto_clsProduto
	Local oClone := Produto_clsProduto():NEW()
	oClone:nLojaCodigo          := ::nLojaCodigo
	oClone:cProdutoCodigoInterno := ::cProdutoCodigoInterno
	oClone:cNome                := ::cNome
	oClone:cTitulo              := ::cTitulo
	oClone:cSubtitulo           := ::cSubtitulo
	oClone:cDescricao           := ::cDescricao
	oClone:cCaracteristica      := ::cCaracteristica
	oClone:cTexto1              := ::cTexto1
	oClone:cTexto2              := ::cTexto2
	oClone:cTexto3              := ::cTexto3
	oClone:cTexto4              := ::cTexto4
	oClone:cTexto5              := ::cTexto5
	oClone:cTexto6              := ::cTexto6
	oClone:cTexto7              := ::cTexto7
	oClone:cTexto8              := ::cTexto8
	oClone:cTexto9              := ::cTexto9
	oClone:cTexto10             := ::cTexto10
	oClone:nNumero1             := ::nNumero1
	oClone:nNumero2             := ::nNumero2
	oClone:nNumero3             := ::nNumero3
	oClone:nNumero4             := ::nNumero4
	oClone:nNumero5             := ::nNumero5
	oClone:nNumero6             := ::nNumero6
	oClone:nNumero7             := ::nNumero7
	oClone:nNumero8             := ::nNumero8
	oClone:nNumero9             := ::nNumero9
	oClone:nNumero10            := ::nNumero10
	oClone:nPeso                := ::nPeso
	oClone:nAltura              := ::nAltura
	oClone:nLargura             := ::nLargura
	oClone:nProfundidade        := ::nProfundidade
	oClone:nPesoEmbalagem       := ::nPesoEmbalagem
	oClone:nAlturaEmbalagem     := ::nAlturaEmbalagem
	oClone:nLarguraEmbalagem    := ::nLarguraEmbalagem
	oClone:nProfundidadeEmbalagem := ::nProfundidadeEmbalagem
	oClone:nPrecoCheio          := ::nPrecoCheio
	oClone:nPrecoPor            := ::nPrecoPor
	oClone:nEntrega             := ::nEntrega
	oClone:nQuantidadeMaximaPorVenda := ::nQuantidadeMaximaPorVenda
	oClone:oWSProdutoStatus     := IIF(::oWSProdutoStatus = NIL , NIL , ::oWSProdutoStatus:Clone() )
	oClone:oWSTipo              := IIF(::oWSTipo = NIL , NIL , ::oWSTipo:Clone() )
	oClone:oWSPresente          := IIF(::oWSPresente = NIL , NIL , ::oWSPresente:Clone() )
	oClone:oWSPersonalizacaoExtra := IIF(::oWSPersonalizacaoExtra = NIL , NIL , ::oWSPersonalizacaoExtra:Clone() )
	oClone:cPersonalizacaoLabel := ::cPersonalizacaoLabel
	oClone:cISBN                := ::cISBN
	oClone:cEAN13               := ::cEAN13
	oClone:cYouTubeCode         := ::cYouTubeCode
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Produto_clsProduto
	Local oNode40
	Local oNode41
	Local oNode42
	Local oNode43
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nLojaCodigo        :=  WSAdvValue( oResponse,"_LOJACODIGO","int",NIL,"Property nLojaCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cProdutoCodigoInterno :=  WSAdvValue( oResponse,"_PRODUTOCODIGOINTERNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTitulo            :=  WSAdvValue( oResponse,"_TITULO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSubtitulo         :=  WSAdvValue( oResponse,"_SUBTITULO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCaracteristica    :=  WSAdvValue( oResponse,"_CARACTERISTICA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTexto1            :=  WSAdvValue( oResponse,"_TEXTO1","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTexto2            :=  WSAdvValue( oResponse,"_TEXTO2","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTexto3            :=  WSAdvValue( oResponse,"_TEXTO3","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTexto4            :=  WSAdvValue( oResponse,"_TEXTO4","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTexto5            :=  WSAdvValue( oResponse,"_TEXTO5","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTexto6            :=  WSAdvValue( oResponse,"_TEXTO6","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTexto7            :=  WSAdvValue( oResponse,"_TEXTO7","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTexto8            :=  WSAdvValue( oResponse,"_TEXTO8","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTexto9            :=  WSAdvValue( oResponse,"_TEXTO9","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTexto10           :=  WSAdvValue( oResponse,"_TEXTO10","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nNumero1           :=  WSAdvValue( oResponse,"_NUMERO1","decimal",NIL,"Property nNumero1 as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNumero2           :=  WSAdvValue( oResponse,"_NUMERO2","decimal",NIL,"Property nNumero2 as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNumero3           :=  WSAdvValue( oResponse,"_NUMERO3","decimal",NIL,"Property nNumero3 as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNumero4           :=  WSAdvValue( oResponse,"_NUMERO4","decimal",NIL,"Property nNumero4 as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNumero5           :=  WSAdvValue( oResponse,"_NUMERO5","decimal",NIL,"Property nNumero5 as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNumero6           :=  WSAdvValue( oResponse,"_NUMERO6","decimal",NIL,"Property nNumero6 as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNumero7           :=  WSAdvValue( oResponse,"_NUMERO7","decimal",NIL,"Property nNumero7 as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNumero8           :=  WSAdvValue( oResponse,"_NUMERO8","decimal",NIL,"Property nNumero8 as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNumero9           :=  WSAdvValue( oResponse,"_NUMERO9","decimal",NIL,"Property nNumero9 as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNumero10          :=  WSAdvValue( oResponse,"_NUMERO10","decimal",NIL,"Property nNumero10 as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPeso              :=  WSAdvValue( oResponse,"_PESO","decimal",NIL,"Property nPeso as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nAltura            :=  WSAdvValue( oResponse,"_ALTURA","decimal",NIL,"Property nAltura as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nLargura           :=  WSAdvValue( oResponse,"_LARGURA","decimal",NIL,"Property nLargura as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nProfundidade      :=  WSAdvValue( oResponse,"_PROFUNDIDADE","decimal",NIL,"Property nProfundidade as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoEmbalagem     :=  WSAdvValue( oResponse,"_PESOEMBALAGEM","decimal",NIL,"Property nPesoEmbalagem as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nAlturaEmbalagem   :=  WSAdvValue( oResponse,"_ALTURAEMBALAGEM","decimal",NIL,"Property nAlturaEmbalagem as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nLarguraEmbalagem  :=  WSAdvValue( oResponse,"_LARGURAEMBALAGEM","decimal",NIL,"Property nLarguraEmbalagem as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nProfundidadeEmbalagem :=  WSAdvValue( oResponse,"_PROFUNDIDADEEMBALAGEM","decimal",NIL,"Property nProfundidadeEmbalagem as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPrecoCheio        :=  WSAdvValue( oResponse,"_PRECOCHEIO","decimal",NIL,"Property nPrecoCheio as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPrecoPor          :=  WSAdvValue( oResponse,"_PRECOPOR","decimal",NIL,"Property nPrecoPor as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nEntrega           :=  WSAdvValue( oResponse,"_ENTREGA","int",NIL,"Property nEntrega as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nQuantidadeMaximaPorVenda :=  WSAdvValue( oResponse,"_QUANTIDADEMAXIMAPORVENDA","int",NIL,"Property nQuantidadeMaximaPorVenda as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode40 :=  WSAdvValue( oResponse,"_PRODUTOSTATUS","ProdutoStatus",NIL,"Property oWSProdutoStatus as tns:ProdutoStatus on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode40 != NIL
		::oWSProdutoStatus := Produto_ProdutoStatus():New()
		::oWSProdutoStatus:SoapRecv(oNode40)
	EndIf
	oNode41 :=  WSAdvValue( oResponse,"_TIPO","ProdutoTipo",NIL,"Property oWSTipo as tns:ProdutoTipo on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode41 != NIL
		::oWSTipo := Produto_ProdutoTipo():New()
		::oWSTipo:SoapRecv(oNode41)
	EndIf
	oNode42 :=  WSAdvValue( oResponse,"_PRESENTE","SimNao",NIL,"Property oWSPresente as tns:SimNao on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode42 != NIL
		::oWSPresente := Produto_SimNao():New()
		::oWSPresente:SoapRecv(oNode42)
	EndIf
	oNode43 :=  WSAdvValue( oResponse,"_PERSONALIZACAOEXTRA","SimNao",NIL,"Property oWSPersonalizacaoExtra as tns:SimNao on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode43 != NIL
		::oWSPersonalizacaoExtra := Produto_SimNao():New()
		::oWSPersonalizacaoExtra:SoapRecv(oNode43)
	EndIf
	::cPersonalizacaoLabel :=  WSAdvValue( oResponse,"_PERSONALIZACAOLABEL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cISBN              :=  WSAdvValue( oResponse,"_ISBN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEAN13             :=  WSAdvValue( oResponse,"_EAN13","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cYouTubeCode       :=  WSAdvValue( oResponse,"_YOUTUBECODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure clsProdutoPersonalizacao

WSSTRUCT Produto_clsProdutoPersonalizacao
	WSDATA   nCodigo                   AS int
	WSDATA   oWSStatus                 AS Produto_ProdutoPersonalizacaoStatus
	WSDATA   nLojaCodigo               AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Produto_clsProdutoPersonalizacao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Produto_clsProdutoPersonalizacao
Return

WSMETHOD CLONE WSCLIENT Produto_clsProdutoPersonalizacao
	Local oClone := Produto_clsProdutoPersonalizacao():NEW()
	oClone:nCodigo              := ::nCodigo
	oClone:oWSStatus            := IIF(::oWSStatus = NIL , NIL , ::oWSStatus:Clone() )
	oClone:nLojaCodigo          := ::nLojaCodigo
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Produto_clsProdutoPersonalizacao
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nCodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,"Property nCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_STATUS","ProdutoPersonalizacaoStatus",NIL,"Property oWSStatus as tns:ProdutoPersonalizacaoStatus on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSStatus := Produto_ProdutoPersonalizacaoStatus():New()
		::oWSStatus:SoapRecv(oNode2)
	EndIf
	::nLojaCodigo        :=  WSAdvValue( oResponse,"_LOJACODIGO","int",NIL,"Property nLojaCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Enumeration ProdutoStatus

WSSTRUCT Produto_ProdutoStatus
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Produto_ProdutoStatus
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Nenhum" )
	aadd(::aValueList , "Ativo" )
	aadd(::aValueList , "Inativo" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Produto_ProdutoStatus
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Produto_ProdutoStatus
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Produto_ProdutoStatus
Local oClone := Produto_ProdutoStatus():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration ProdutoTipo

WSSTRUCT Produto_ProdutoTipo
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Produto_ProdutoTipo
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

WSMETHOD SOAPSEND WSCLIENT Produto_ProdutoTipo
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Produto_ProdutoTipo
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Produto_ProdutoTipo
Local oClone := Produto_ProdutoTipo():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration SimNao

WSSTRUCT Produto_SimNao
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Produto_SimNao
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Nenhum" )
	aadd(::aValueList , "Sim" )
	aadd(::aValueList , "Não" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Produto_SimNao
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Produto_SimNao
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Produto_SimNao
Local oClone := Produto_SimNao():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration ProdutoPersonalizacaoStatus

WSSTRUCT Produto_ProdutoPersonalizacaoStatus
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Produto_ProdutoPersonalizacaoStatus
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Nenhum" )
	aadd(::aValueList , "Ativo" )
	aadd(::aValueList , "Inativo" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Produto_ProdutoPersonalizacaoStatus
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Produto_ProdutoPersonalizacaoStatus
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Produto_ProdutoPersonalizacaoStatus
Local oClone := Produto_ProdutoPersonalizacaoStatus():New()
	oClone:Value := ::Value
Return oClone