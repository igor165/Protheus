#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://homologacao.ikeda.com.br/totvs/ikcwebservice/sku.asmx?wsdl
Gerado em        01/28/13 15:56:22
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.111215
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _FPVOPNJ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSSKU
------------------------------------------------------------------------------- */

WSCLIENT WSSKU

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Salvar
	WSMETHOD AlterarPreco
	WSMETHOD AlterarStatus
	WSMETHOD Excluir
	WSMETHOD Listar

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   nLojaCodigo               AS int
	WSDATA   cCodigoInternoProduto     AS string
	WSDATA   cPartNumber               AS string
	WSDATA   nPrecoPor                 AS decimal
	WSDATA   oWSsku1                   AS SKU_ArrayOfString
	WSDATA   oWSsku2                   AS SKU_ArrayOfString
	WSDATA   oWSsku3                   AS SKU_ArrayOfString
	WSDATA   oWSsku4                   AS SKU_ArrayOfString
	WSDATA   oWSsku5                   AS SKU_ArrayOfString
	WSDATA   nStatusSKU                AS int
	WSDATA   cA1                       AS string
	WSDATA   cA2                       AS string
	WSDATA   oWS                       AS SCHEMA
	WSDATA   oWSSalvarResult           AS SKU_clsRetornoOfclsProdutoCaracteristica
	WSDATA   oWSAlterarPrecoResult     AS SKU_clsRetornoOfclsProdutoCaracteristica
	WSDATA   oWSAlterarStatusResult    AS SKU_clsRetornoOfclsProdutoCaracteristica
	WSDATA   oWSExcluirResult          AS SKU_clsRetornoOfclsProdutoCaracteristica
	WSDATA   oWSListarResult           AS SKU_clsRetornoOfclsProdutoCaracteristica

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSSKU
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.111010P-20120314] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
If val(right(GetWSCVer(),8)) < 1.040504
	UserException("O Código-Fonte Client atual requer a versão de Lib para WebServices igual ou superior a ADVPL WSDL Client 1.040504. Atualize o repositório ou gere o Código-Fonte novamente utilizando o repositório atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSSKU
	::oWSsku1            := SKU_ARRAYOFSTRING():New()
	::oWSsku2            := SKU_ARRAYOFSTRING():New()
	::oWSsku3            := SKU_ARRAYOFSTRING():New()
	::oWSsku4            := SKU_ARRAYOFSTRING():New()
	::oWSsku5            := SKU_ARRAYOFSTRING():New()
	::oWS                := NIL 
	::oWSSalvarResult    := SKU_CLSRETORNOOFCLSPRODUTOCARACTERISTICA():New()
	::oWSAlterarPrecoResult := SKU_CLSRETORNOOFCLSPRODUTOCARACTERISTICA():New()
	::oWSAlterarStatusResult := SKU_CLSRETORNOOFCLSPRODUTOCARACTERISTICA():New()
	::oWSExcluirResult   := SKU_CLSRETORNOOFCLSPRODUTOCARACTERISTICA():New()
	::oWSListarResult    := SKU_CLSRETORNOOFCLSPRODUTOCARACTERISTICA():New()
Return

WSMETHOD RESET WSCLIENT WSSKU
	::nLojaCodigo        := NIL 
	::cCodigoInternoProduto := NIL 
	::cPartNumber        := NIL 
	::nPrecoPor          := NIL 
	::oWSsku1            := NIL 
	::oWSsku2            := NIL 
	::oWSsku3            := NIL 
	::oWSsku4            := NIL 
	::oWSsku5            := NIL 
	::nStatusSKU         := NIL 
	::cA1                := NIL 
	::cA2                := NIL 
	::oWS                := NIL 
	::oWSSalvarResult    := NIL 
	::oWSAlterarPrecoResult := NIL 
	::oWSAlterarStatusResult := NIL 
	::oWSExcluirResult   := NIL 
	::oWSListarResult    := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSSKU
Local oClone := WSSKU():New()
	oClone:_URL          := ::_URL 
	oClone:nLojaCodigo   := ::nLojaCodigo
	oClone:cCodigoInternoProduto := ::cCodigoInternoProduto
	oClone:cPartNumber   := ::cPartNumber
	oClone:nPrecoPor     := ::nPrecoPor
	oClone:oWSsku1       :=  IIF(::oWSsku1 = NIL , NIL ,::oWSsku1:Clone() )
	oClone:oWSsku2       :=  IIF(::oWSsku2 = NIL , NIL ,::oWSsku2:Clone() )
	oClone:oWSsku3       :=  IIF(::oWSsku3 = NIL , NIL ,::oWSsku3:Clone() )
	oClone:oWSsku4       :=  IIF(::oWSsku4 = NIL , NIL ,::oWSsku4:Clone() )
	oClone:oWSsku5       :=  IIF(::oWSsku5 = NIL , NIL ,::oWSsku5:Clone() )
	oClone:nStatusSKU    := ::nStatusSKU
	oClone:cA1           := ::cA1
	oClone:cA2           := ::cA2
	oClone:oWSSalvarResult :=  IIF(::oWSSalvarResult = NIL , NIL ,::oWSSalvarResult:Clone() )
	oClone:oWSAlterarPrecoResult :=  IIF(::oWSAlterarPrecoResult = NIL , NIL ,::oWSAlterarPrecoResult:Clone() )
	oClone:oWSAlterarStatusResult :=  IIF(::oWSAlterarStatusResult = NIL , NIL ,::oWSAlterarStatusResult:Clone() )
	oClone:oWSExcluirResult :=  IIF(::oWSExcluirResult = NIL , NIL ,::oWSExcluirResult:Clone() )
	oClone:oWSListarResult :=  IIF(::oWSListarResult = NIL , NIL ,::oWSListarResult:Clone() )
Return oClone

// WSDL Method Salvar of Service WSSKU

WSMETHOD Salvar WSSEND nLojaCodigo,cCodigoInternoProduto,cPartNumber,nPrecoPor,oWSsku1,oWSsku2,oWSsku3,oWSsku4,oWSsku5,nStatusSKU,cA1,cA2,oWS WSRECEIVE oWSSalvarResult WSCLIENT WSSKU
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
cSoap += WSSoapValue("PartNumber", ::cPartNumber, cPartNumber , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PrecoPor", ::nPrecoPor, nPrecoPor , "decimal", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("sku1", ::oWSsku1, oWSsku1 , "ArrayOfString", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("sku2", ::oWSsku2, oWSsku2 , "ArrayOfString", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("sku3", ::oWSsku3, oWSsku3 , "ArrayOfString", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("sku4", ::oWSsku4, oWSsku4 , "ArrayOfString", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("sku5", ::oWSsku5, oWSsku5 , "ArrayOfString", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("StatusSKU", ::nStatusSKU, nStatusSKU , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += "</Salvar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Salvar",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/sku.asmx")

::Init()
::oWSSalvarResult:SoapRecv( WSAdvValue( oXmlRet,"_SALVARRESPONSE:_SALVARRESULT","clsRetornoOfclsProdutoCaracteristica",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AlterarPreco of Service WSSKU

WSMETHOD AlterarPreco WSSEND nLojaCodigo,cPartNumber,nPrecoPor,cA1,cA2,oWS WSRECEIVE oWSAlterarPrecoResult WSCLIENT WSSKU
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
cSoap += WSSoapValue("PartNumber", ::cPartNumber, cPartNumber , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PrecoPor", ::nPrecoPor, nPrecoPor , "decimal", .T. , .F., 0 , NIL, .F.) 
cSoap += "</AlterarPreco>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/AlterarPreco",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/sku.asmx")

::Init()
::oWSAlterarPrecoResult:SoapRecv( WSAdvValue( oXmlRet,"_ALTERARPRECORESPONSE:_ALTERARPRECORESULT","clsRetornoOfclsProdutoCaracteristica",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AlterarStatus of Service WSSKU

WSMETHOD AlterarStatus WSSEND nLojaCodigo,cPartNumber,nStatusSKU,cA1,cA2,oWS WSRECEIVE oWSAlterarStatusResult WSCLIENT WSSKU
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
cSoap += WSSoapValue("PartNumber", ::cPartNumber, cPartNumber , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("StatusSKU", ::nStatusSKU, nStatusSKU , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += "</AlterarStatus>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/AlterarStatus",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/sku.asmx")

::Init()
::oWSAlterarStatusResult:SoapRecv( WSAdvValue( oXmlRet,"_ALTERARSTATUSRESPONSE:_ALTERARSTATUSRESULT","clsRetornoOfclsProdutoCaracteristica",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Excluir of Service WSSKU

WSMETHOD Excluir WSSEND nLojaCodigo,cPartNumber,cA1,cA2,oWS WSRECEIVE oWSExcluirResult WSCLIENT WSSKU
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
cSoap += WSSoapValue("PartNumber", ::cPartNumber, cPartNumber , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Excluir>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Excluir",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/sku.asmx")

::Init()
::oWSExcluirResult:SoapRecv( WSAdvValue( oXmlRet,"_EXCLUIRRESPONSE:_EXCLUIRRESULT","clsRetornoOfclsProdutoCaracteristica",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Listar of Service WSSKU

WSMETHOD Listar WSSEND nLojaCodigo,cCodigoInternoProduto,cPartNumber,nStatusSKU,cA1,cA2,oWS WSRECEIVE oWSListarResult WSCLIENT WSSKU
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
cSoap += WSSoapValue("PartNumber", ::cPartNumber, cPartNumber , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("StatusSKU", ::nStatusSKU, nStatusSKU , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += "</Listar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Listar",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/sku.asmx")

::Init()
::oWSListarResult:SoapRecv( WSAdvValue( oXmlRet,"_LISTARRESPONSE:_LISTARRESULT","clsRetornoOfclsProdutoCaracteristica",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ArrayOfString

WSSTRUCT SKU_ArrayOfString
	WSDATA   cstring                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SKU_ArrayOfString
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SKU_ArrayOfString
	::cstring              := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT SKU_ArrayOfString
	Local oClone := SKU_ArrayOfString():NEW()
	oClone:cstring              := IIf(::cstring <> NIL , aClone(::cstring) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT SKU_ArrayOfString
	Local cSoap := ""
	aEval( ::cstring , {|x| cSoap := cSoap  +  WSSoapValue("string", x , x , "string", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure clsRetornoOfclsProdutoCaracteristica

WSSTRUCT SKU_clsRetornoOfclsProdutoCaracteristica
	WSDATA   cAcao                     AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   nCodigo                   AS int
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   oWSLista                  AS SKU_ArrayOfClsProdutoCaracteristica OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SKU_clsRetornoOfclsProdutoCaracteristica
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SKU_clsRetornoOfclsProdutoCaracteristica
Return

WSMETHOD CLONE WSCLIENT SKU_clsRetornoOfclsProdutoCaracteristica
	Local oClone := SKU_clsRetornoOfclsProdutoCaracteristica():NEW()
	oClone:cAcao                := ::cAcao
	oClone:cData                := ::cData
	oClone:nCodigo              := ::nCodigo
	oClone:cDescricao           := ::cDescricao
	oClone:oWSLista             := IIF(::oWSLista = NIL , NIL , ::oWSLista:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SKU_clsRetornoOfclsProdutoCaracteristica
	Local oNode5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAcao              :=  WSAdvValue( oResponse,"_ACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nCodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,"Property nCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode5 :=  WSAdvValue( oResponse,"_LISTA","ArrayOfClsProdutoCaracteristica",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSLista := SKU_ArrayOfClsProdutoCaracteristica():New()
		::oWSLista:SoapRecv(oNode5)
	EndIf
Return

// WSDL Data Structure ArrayOfClsProdutoCaracteristica

WSSTRUCT SKU_ArrayOfClsProdutoCaracteristica
	WSDATA   oWSclsProdutoCaracteristica AS SKU_clsProdutoCaracteristica OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SKU_ArrayOfClsProdutoCaracteristica
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SKU_ArrayOfClsProdutoCaracteristica
	::oWSclsProdutoCaracteristica := {} // Array Of  SKU_CLSPRODUTOCARACTERISTICA():New()
Return

WSMETHOD CLONE WSCLIENT SKU_ArrayOfClsProdutoCaracteristica
	Local oClone := SKU_ArrayOfClsProdutoCaracteristica():NEW()
	oClone:oWSclsProdutoCaracteristica := NIL
	If ::oWSclsProdutoCaracteristica <> NIL 
		oClone:oWSclsProdutoCaracteristica := {}
		aEval( ::oWSclsProdutoCaracteristica , { |x| aadd( oClone:oWSclsProdutoCaracteristica , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SKU_ArrayOfClsProdutoCaracteristica
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLSPRODUTOCARACTERISTICA","clsProdutoCaracteristica",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclsProdutoCaracteristica , SKU_clsProdutoCaracteristica():New() )
			::oWSclsProdutoCaracteristica[len(::oWSclsProdutoCaracteristica)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure clsProdutoCaracteristica

WSSTRUCT SKU_clsProdutoCaracteristica
	WSDATA   nLojaCodigo               AS int
	WSDATA   cPartNumber               AS string OPTIONAL
	WSDATA   nPrecoPor                 AS decimal
	WSDATA   oWSProdutoCaracteristicaStatus AS SKU_ProdutoCaracteristicaStatus
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SKU_clsProdutoCaracteristica
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SKU_clsProdutoCaracteristica
Return

WSMETHOD CLONE WSCLIENT SKU_clsProdutoCaracteristica
	Local oClone := SKU_clsProdutoCaracteristica():NEW()
	oClone:nLojaCodigo          := ::nLojaCodigo
	oClone:cPartNumber          := ::cPartNumber
	oClone:nPrecoPor            := ::nPrecoPor
	oClone:oWSProdutoCaracteristicaStatus := IIF(::oWSProdutoCaracteristicaStatus = NIL , NIL , ::oWSProdutoCaracteristicaStatus:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SKU_clsProdutoCaracteristica
	Local oNode4
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nLojaCodigo        :=  WSAdvValue( oResponse,"_LOJACODIGO","int",NIL,"Property nLojaCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cPartNumber        :=  WSAdvValue( oResponse,"_PARTNUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nPrecoPor          :=  WSAdvValue( oResponse,"_PRECOPOR","decimal",NIL,"Property nPrecoPor as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode4 :=  WSAdvValue( oResponse,"_PRODUTOCARACTERISTICASTATUS","ProdutoCaracteristicaStatus",NIL,"Property oWSProdutoCaracteristicaStatus as tns:ProdutoCaracteristicaStatus on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode4 != NIL
		::oWSProdutoCaracteristicaStatus := SKU_ProdutoCaracteristicaStatus():New()
		::oWSProdutoCaracteristicaStatus:SoapRecv(oNode4)
	EndIf
Return

// WSDL Data Enumeration ProdutoCaracteristicaStatus

WSSTRUCT SKU_ProdutoCaracteristicaStatus
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SKU_ProdutoCaracteristicaStatus
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Nenhum" )
	aadd(::aValueList , "Ativo" )
	aadd(::aValueList , "Inativo" )
Return Self

WSMETHOD SOAPSEND WSCLIENT SKU_ProdutoCaracteristicaStatus
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SKU_ProdutoCaracteristicaStatus
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT SKU_ProdutoCaracteristicaStatus
Local oClone := SKU_ProdutoCaracteristicaStatus():New()
	oClone:Value := ::Value
Return oClone


