#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://homologacao.ikeda.com.br/totvs/ikcwebservice/categoria.asmx?wsdl
Gerado em        02/01/13 15:55:09
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.111215
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _KUTLKRG ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSCategoria
------------------------------------------------------------------------------- */

WSCLIENT WSCategoria

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
	WSDATA   cCodigoInternoCategoria   AS string
	WSDATA   cNomeCategoria            AS string
	WSDATA   nCategoriaStatus          AS int
	WSDATA   cCategoriaPai             AS string
	WSDATA   cA1                       AS string
	WSDATA   cA2                       AS string
	WSDATA   oWS                       AS SCHEMA
	WSDATA   oWSSalvarResult           AS Categoria_clsRetornoOfclsCategoria
	WSDATA   oWSExcluirResult          AS Categoria_clsRetornoOfclsCategoria
	WSDATA   oWSListarResult           AS Categoria_clsRetornoOfclsCategoria

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSCategoria
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.111010P-20120314] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
If val(right(GetWSCVer(),8)) < 1.040504
	UserException("O Código-Fonte Client atual requer a versão de Lib para WebServices igual ou superior a ADVPL WSDL Client 1.040504. Atualize o repositório ou gere o Código-Fonte novamente utilizando o repositório atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSCategoria
	::oWS                := NIL 
	::oWSSalvarResult    := Categoria_CLSRETORNOOFCLSCATEGORIA():New()
	::oWSExcluirResult   := Categoria_CLSRETORNOOFCLSCATEGORIA():New()
	::oWSListarResult    := Categoria_CLSRETORNOOFCLSCATEGORIA():New()
Return

WSMETHOD RESET WSCLIENT WSCategoria
	::nLojaCodigo        := NIL 
	::cCodigoInternoCategoria := NIL 
	::cNomeCategoria     := NIL 
	::nCategoriaStatus   := NIL 
	::cCategoriaPai      := NIL 
	::cA1                := NIL 
	::cA2                := NIL 
	::oWS                := NIL 
	::oWSSalvarResult    := NIL 
	::oWSExcluirResult   := NIL 
	::oWSListarResult    := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSCategoria
Local oClone := WSCategoria():New()
	oClone:_URL          := ::_URL 
	oClone:nLojaCodigo   := ::nLojaCodigo
	oClone:cCodigoInternoCategoria := ::cCodigoInternoCategoria
	oClone:cNomeCategoria := ::cNomeCategoria
	oClone:nCategoriaStatus := ::nCategoriaStatus
	oClone:cCategoriaPai := ::cCategoriaPai
	oClone:cA1           := ::cA1
	oClone:cA2           := ::cA2
	oClone:oWSSalvarResult :=  IIF(::oWSSalvarResult = NIL , NIL ,::oWSSalvarResult:Clone() )
	oClone:oWSExcluirResult :=  IIF(::oWSExcluirResult = NIL , NIL ,::oWSExcluirResult:Clone() )
	oClone:oWSListarResult :=  IIF(::oWSListarResult = NIL , NIL ,::oWSListarResult:Clone() )
Return oClone

// WSDL Method Salvar of Service WSCategoria

WSMETHOD Salvar WSSEND nLojaCodigo,cCodigoInternoCategoria,cNomeCategoria,nCategoriaStatus,cCategoriaPai,cA1,cA2,oWS WSRECEIVE oWSSalvarResult WSCLIENT WSCategoria
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
cSoap += WSSoapValue("CodigoInternoCategoria", ::cCodigoInternoCategoria, cCodigoInternoCategoria , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NomeCategoria", ::cNomeCategoria, cNomeCategoria , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CategoriaStatus", ::nCategoriaStatus, nCategoriaStatus , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CategoriaPai", ::cCategoriaPai, cCategoriaPai , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Salvar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Salvar",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/categoria.asmx")

::Init()
::oWSSalvarResult:SoapRecv( WSAdvValue( oXmlRet,"_SALVARRESPONSE:_SALVARRESULT","clsRetornoOfclsCategoria",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Excluir of Service WSCategoria

WSMETHOD Excluir WSSEND nLojaCodigo,cCodigoInternoCategoria,cA1,cA2,oWS WSRECEIVE oWSExcluirResult WSCLIENT WSCategoria
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
cSoap += WSSoapValue("CodigoInternoCategoria", ::cCodigoInternoCategoria, cCodigoInternoCategoria , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Excluir>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Excluir",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/categoria.asmx")

::Init()
::oWSExcluirResult:SoapRecv( WSAdvValue( oXmlRet,"_EXCLUIRRESPONSE:_EXCLUIRRESULT","clsRetornoOfclsCategoria",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Listar of Service WSCategoria

WSMETHOD Listar WSSEND nLojaCodigo,cCodigoInternoCategoria,nCategoriaStatus,cA1,cA2,oWS WSRECEIVE oWSListarResult WSCLIENT WSCategoria
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
cSoap += WSSoapValue("CodigoInternoCategoria", ::cCodigoInternoCategoria, cCodigoInternoCategoria , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CategoriaStatus", ::nCategoriaStatus, nCategoriaStatus , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += "</Listar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Listar",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/categoria.asmx")

::Init()
::oWSListarResult:SoapRecv( WSAdvValue( oXmlRet,"_LISTARRESPONSE:_LISTARRESULT","clsRetornoOfclsCategoria",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure clsRetornoOfclsCategoria

WSSTRUCT Categoria_clsRetornoOfclsCategoria
	WSDATA   cAcao                     AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   nCodigo                   AS int
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   oWSLista                  AS Categoria_ArrayOfClsCategoria OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Categoria_clsRetornoOfclsCategoria
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Categoria_clsRetornoOfclsCategoria
Return

WSMETHOD CLONE WSCLIENT Categoria_clsRetornoOfclsCategoria
	Local oClone := Categoria_clsRetornoOfclsCategoria():NEW()
	oClone:cAcao                := ::cAcao
	oClone:cData                := ::cData
	oClone:nCodigo              := ::nCodigo
	oClone:cDescricao           := ::cDescricao
	oClone:oWSLista             := IIF(::oWSLista = NIL , NIL , ::oWSLista:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Categoria_clsRetornoOfclsCategoria
	Local oNode5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAcao              :=  WSAdvValue( oResponse,"_ACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nCodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,"Property nCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode5 :=  WSAdvValue( oResponse,"_LISTA","ArrayOfClsCategoria",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSLista := Categoria_ArrayOfClsCategoria():New()
		::oWSLista:SoapRecv(oNode5)
	EndIf
Return

// WSDL Data Structure ArrayOfClsCategoria

WSSTRUCT Categoria_ArrayOfClsCategoria
	WSDATA   oWSclsCategoria           AS Categoria_clsCategoria OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Categoria_ArrayOfClsCategoria
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Categoria_ArrayOfClsCategoria
	::oWSclsCategoria      := {} // Array Of  Categoria_CLSCATEGORIA():New()
Return

WSMETHOD CLONE WSCLIENT Categoria_ArrayOfClsCategoria
	Local oClone := Categoria_ArrayOfClsCategoria():NEW()
	oClone:oWSclsCategoria := NIL
	If ::oWSclsCategoria <> NIL 
		oClone:oWSclsCategoria := {}
		aEval( ::oWSclsCategoria , { |x| aadd( oClone:oWSclsCategoria , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Categoria_ArrayOfClsCategoria
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLSCATEGORIA","clsCategoria",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclsCategoria , Categoria_clsCategoria():New() )
			::oWSclsCategoria[len(::oWSclsCategoria)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure clsCategoria

WSSTRUCT Categoria_clsCategoria
	WSDATA   nLojaCodigo               AS int
	WSDATA   cCategoriaCodigoInterno   AS string OPTIONAL
	WSDATA   cPaiInterno               AS string OPTIONAL
	WSDATA   oWSCategoriaStatus        AS Categoria_CategoriaStatus
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   nOrdem                    AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Categoria_clsCategoria
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Categoria_clsCategoria
Return

WSMETHOD CLONE WSCLIENT Categoria_clsCategoria
	Local oClone := Categoria_clsCategoria():NEW()
	oClone:nLojaCodigo          := ::nLojaCodigo
	oClone:cCategoriaCodigoInterno := ::cCategoriaCodigoInterno
	oClone:cPaiInterno          := ::cPaiInterno
	oClone:oWSCategoriaStatus   := IIF(::oWSCategoriaStatus = NIL , NIL , ::oWSCategoriaStatus:Clone() )
	oClone:cNome                := ::cNome
	oClone:nOrdem               := ::nOrdem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Categoria_clsCategoria
	Local oNode4
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nLojaCodigo        :=  WSAdvValue( oResponse,"_LOJACODIGO","int",NIL,"Property nLojaCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCategoriaCodigoInterno :=  WSAdvValue( oResponse,"_CATEGORIACODIGOINTERNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPaiInterno        :=  WSAdvValue( oResponse,"_PAIINTERNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode4 :=  WSAdvValue( oResponse,"_CATEGORIASTATUS","CategoriaStatus",NIL,"Property oWSCategoriaStatus as tns:CategoriaStatus on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode4 != NIL
		::oWSCategoriaStatus := Categoria_CategoriaStatus():New()
		::oWSCategoriaStatus:SoapRecv(oNode4)
	EndIf
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nOrdem             :=  WSAdvValue( oResponse,"_ORDEM","int",NIL,"Property nOrdem as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Enumeration CategoriaStatus

WSSTRUCT Categoria_CategoriaStatus
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Categoria_CategoriaStatus
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Nenhum" )
	aadd(::aValueList , "Ativo" )
	aadd(::aValueList , "Inativo" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Categoria_CategoriaStatus
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Categoria_CategoriaStatus
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Categoria_CategoriaStatus
Local oClone := Categoria_CategoriaStatus():New()
	oClone:Value := ::Value
Return oClone


