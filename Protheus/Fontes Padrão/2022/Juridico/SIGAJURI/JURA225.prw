#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    https://www.cnj.jus.br/sgt/sgt_ws.php?wsdl
Gerado em        07/07/17 15:29:51
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _UKCVMKJ ; Return  // "dummy" function - Internal Use


/* ====================== SERVICE WARNING MESSAGES ======================
Definition for arrayCoordinate as simpletype FOUND AS [xs:string]. This Object COULD NOT HAVE RETURN.
====================================================================== */

/* -------------------------------------------------------------------------------
WSDL Service WSsgt_ws_methodsService
------------------------------------------------------------------------------- */

WSCLIENT WSsgt_ws_methodsService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD inserirArquivoBanco
	WSMETHOD pesquisarItemPublicoWS
	WSMETHOD getArrayDetalhesItemPublicoWS
	WSMETHOD getArrayFilhosItemPublicoWS
	WSMETHOD getStringPaisItemPublicoWS
	WSMETHOD getComplementoMovimentoWS
	WSMETHOD getDataUltimaVersao

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSpublico                AS anyType
	WSDATA   ctipoTabela               AS string
	WSDATA   ctipoPesquisa             AS string
	WSDATA   cvalorPesquisa            AS string
	WSDATA   oWSpesquisarItemPublicoWSreturn AS sgt_ws_methodsService_ArrayOfItem
	WSDATA   cseqItem                  AS string
	WSDATA   ctipoItem                 AS string
	WSDATA   oWSgetArrayDetalhesItemPublicoWSreturn AS sgt_ws_methodsService_Array
	WSDATA   nseqItem                  AS int
	WSDATA   oWSgetArrayFilhosItemPublicoWSreturn AS sgt_ws_methodsService_ArrayOfArvoreGenerica
	WSDATA   creturn                   AS string
	WSDATA   ncodMovimento             AS int
	WSDATA   oWSgetComplementoMovimentoWSreturn AS sgt_ws_methodsService_ArrayOfComplementoMovimento

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSsgt_ws_methodsService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20170412 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSsgt_ws_methodsService
	::oWSpesquisarItemPublicoWSreturn := sgt_ws_methodsService_ARRAYOFITEM():New()
	::oWSgetArrayDetalhesItemPublicoWSreturn := sgt_ws_methodsService_ARRAY():New()
	::oWSpesquisarItemPublicoWSreturn := sgt_ws_methodsService_ARRAYOFITEM():New()
	::oWSgetArrayDetalhesItemPublicoWSreturn := sgt_ws_methodsService_ARRAY():New()
	::oWSgetArrayFilhosItemPublicoWSreturn := sgt_ws_methodsService_ARRAYOFARVOREGENERICA():New()
	::oWSgetComplementoMovimentoWSreturn := sgt_ws_methodsService_ARRAYOFCOMPLEMENTOMOVIMENTO():New()
Return

WSMETHOD RESET WSCLIENT WSsgt_ws_methodsService
	::oWSpublico         := NIL
	::ctipoTabela        := NIL
	::ctipoPesquisa      := NIL
	::cvalorPesquisa     := NIL
	::oWSpesquisarItemPublicoWSreturn := NIL
	::cseqItem           := NIL
	::ctipoItem          := NIL
	::oWSgetArrayDetalhesItemPublicoWSreturn := NIL
	::oWSpublico         := NIL
	::ctipoTabela        := NIL
	::ctipoPesquisa      := NIL
	::cvalorPesquisa     := NIL
	::oWSpesquisarItemPublicoWSreturn := NIL
	::cseqItem           := NIL
	::ctipoItem          := NIL
	::oWSgetArrayDetalhesItemPublicoWSreturn := NIL
	::oWSgetArrayFilhosItemPublicoWSreturn := NIL
	::creturn            := NIL
	::ncodMovimento      := NIL
	::oWSgetComplementoMovimentoWSreturn := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSsgt_ws_methodsService
Local oClone := WSsgt_ws_methodsService():New()
	oClone:_URL          := ::_URL
	oClone:oWSpublico    := ::oWSpublico
	oClone:ctipoTabela   := ::ctipoTabela
	oClone:ctipoPesquisa := ::ctipoPesquisa
	oClone:cvalorPesquisa := ::cvalorPesquisa
	oClone:oWSpesquisarItemPublicoWSreturn :=  IIF(::oWSpesquisarItemPublicoWSreturn = NIL , NIL ,::oWSpesquisarItemPublicoWSreturn:Clone() )
	oClone:cseqItem      := ::cseqItem
	oClone:ctipoItem     := ::ctipoItem
	oClone:oWSgetArrayDetalhesItemPublicoWSreturn :=  IIF(::oWSgetArrayDetalhesItemPublicoWSreturn = NIL , NIL ,::oWSgetArrayDetalhesItemPublicoWSreturn:Clone() )
	oClone:oWSpublico    := ::oWSpublico
	oClone:ctipoTabela   := ::ctipoTabela
	oClone:ctipoPesquisa := ::ctipoPesquisa
	oClone:cvalorPesquisa := ::cvalorPesquisa
	oClone:oWSpesquisarItemPublicoWSreturn :=  IIF(::oWSpesquisarItemPublicoWSreturn = NIL , NIL ,::oWSpesquisarItemPublicoWSreturn:Clone() )
	oClone:cseqItem      := ::cseqItem
	oClone:ctipoItem     := ::ctipoItem
	oClone:oWSgetArrayDetalhesItemPublicoWSreturn :=  IIF(::oWSgetArrayDetalhesItemPublicoWSreturn = NIL , NIL ,::oWSgetArrayDetalhesItemPublicoWSreturn:Clone() )
	oClone:oWSgetArrayFilhosItemPublicoWSreturn :=  IIF(::oWSgetArrayFilhosItemPublicoWSreturn = NIL , NIL ,::oWSgetArrayFilhosItemPublicoWSreturn:Clone() )
	oClone:creturn       := ::creturn
	oClone:ncodMovimento := ::ncodMovimento
	oClone:oWSgetComplementoMovimentoWSreturn :=  IIF(::oWSgetComplementoMovimentoWSreturn = NIL , NIL ,::oWSgetComplementoMovimentoWSreturn:Clone() )
Return oClone

// WSDL Method inserirArquivoBanco of Service WSsgt_ws_methodsService

WSMETHOD inserirArquivoBanco WSSEND oWSpublico WSRECEIVE NULLPARAM WSCLIENT WSsgt_ws_methodsService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:inserirArquivoBanco xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("publico", ::oWSpublico, oWSpublico , "anyType", .T. , .T. , 0 , NIL, .F.,.F.)
cSoap += "</q1:inserirArquivoBanco>"

oXmlRet := SvcSoapCall(	Self,cSoap,;
	"https://www.cnj.jus.br/sgt/sgt_ws.php#inserirArquivoBanco",;
	"RPCX","https://www.cnj.jus.br/sgt/sgt_ws.php",,,;
	"https://www.cnj.jus.br/sgt/sgt_ws.php")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method pesquisarItemPublicoWS of Service WSsgt_ws_methodsService

WSMETHOD pesquisarItemPublicoWS WSSEND ctipoTabela,ctipoPesquisa,cvalorPesquisa WSRECEIVE oWSpesquisarItemPublicoWSreturn WSCLIENT WSsgt_ws_methodsService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:pesquisarItemPublicoWS xmlns:q1="https://www.cnj.jus.br/sgt/sgt_ws.php">'
cSoap += WSSoapValue("tipoTabela", ::ctipoTabela, ctipoTabela , "string", .T. , .T. , 0 , NIL, .F.,.F.)
cSoap += WSSoapValue("tipoPesquisa", ::ctipoPesquisa, ctipoPesquisa , "string", .T. , .T. , 0 , NIL, .F.,.F.)
cSoap += WSSoapValue("valorPesquisa", ::cvalorPesquisa, cvalorPesquisa , "string", .T. , .T. , 0 , NIL, .F.,.F.)
cSoap += "</q1:pesquisarItemPublicoWS>"

oXmlRet := SvcSoapCall(	Self,cSoap,;
	"https://www.cnj.jus.br/sgt/sgt_ws.php#pesquisarItemPublicoWS",;
	"RPCX","https://www.cnj.jus.br/sgt/sgt_ws.php",,,;
	"https://www.cnj.jus.br/sgt/sgt_ws.php")

::Init()
::oWSpesquisarItemPublicoWSreturn:SoapRecv( WSAdvValue( oXmlRet,"_RETURN","ArrayOfItem",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getArrayDetalhesItemPublicoWS of Service WSsgt_ws_methodsService

WSMETHOD getArrayDetalhesItemPublicoWS WSSEND cseqItem,ctipoItem WSRECEIVE oWSgetArrayDetalhesItemPublicoWSreturn WSCLIENT WSsgt_ws_methodsService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getArrayDetalhesItemPublicoWS xmlns:q1="https://www.cnj.jus.br/sgt/sgt_ws.php">'
cSoap += WSSoapValue("seqItem", ::cseqItem, cseqItem , "string", .T. , .T. , 0 , NIL, .F.,.F.)
cSoap += WSSoapValue("tipoItem", ::ctipoItem, ctipoItem , "string", .T. , .T. , 0 , NIL, .F.,.F.)
cSoap += "</q1:getArrayDetalhesItemPublicoWS>"

oXmlRet := SvcSoapCall(	Self,cSoap,;
	"https://www.cnj.jus.br/sgt/sgt_ws.php#getArrayDetalhesItemPublicoWS",;
	"RPCX","https://www.cnj.jus.br/sgt/sgt_ws.php",,,;
	"https://www.cnj.jus.br/sgt/sgt_ws.php")

::Init()
::oWSgetArrayDetalhesItemPublicoWSreturn:SoapRecv( WSAdvValue( oXmlRet,"_RETURN","Array",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getArrayFilhosItemPublicoWS of Service WSsgt_ws_methodsService

WSMETHOD getArrayFilhosItemPublicoWS WSSEND nseqItem,ctipoItem WSRECEIVE oWSgetArrayFilhosItemPublicoWSreturn WSCLIENT WSsgt_ws_methodsService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getArrayFilhosItemPublicoWS xmlns:q1="https://www.cnj.jus.br/sgt/sgt_ws.php">'
cSoap += WSSoapValue("seqItem", ::nseqItem, nseqItem , "int", .T. , .T. , 0 , NIL, .F.,.F.)
cSoap += WSSoapValue("tipoItem", ::ctipoItem, ctipoItem , "string", .T. , .T. , 0 , NIL, .F.,.F.)
cSoap += "</q1:getArrayFilhosItemPublicoWS>"

oXmlRet := SvcSoapCall(	Self,cSoap,;
	"https://www.cnj.jus.br/sgt/sgt_ws.php#getArrayFilhosItemPublicoWS",;
	"RPCX","https://www.cnj.jus.br/sgt/sgt_ws.php",,,;
	"https://www.cnj.jus.br/sgt/sgt_ws.php")

::Init()
::oWSgetArrayFilhosItemPublicoWSreturn:SoapRecv( WSAdvValue( oXmlRet,"_RETURN","ArrayOfArvoreGenerica",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getStringPaisItemPublicoWS of Service WSsgt_ws_methodsService

WSMETHOD getStringPaisItemPublicoWS WSSEND nseqItem,ctipoItem WSRECEIVE creturn WSCLIENT WSsgt_ws_methodsService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getStringPaisItemPublicoWS xmlns:q1="https://www.cnj.jus.br/sgt/sgt_ws.php">'
cSoap += WSSoapValue("seqItem", ::nseqItem, nseqItem , "int", .T. , .T. , 0 , NIL, .F.,.F.)
cSoap += WSSoapValue("tipoItem", ::ctipoItem, ctipoItem , "string", .T. , .T. , 0 , NIL, .F.,.F.)
cSoap += "</q1:getStringPaisItemPublicoWS>"

oXmlRet := SvcSoapCall(	Self,cSoap,;
	"https://www.cnj.jus.br/sgt/sgt_ws.php#getStringPaisItemPublicoWS",;
	"RPCX","https://www.cnj.jus.br/sgt/sgt_ws.php",,,;
	"https://www.cnj.jus.br/sgt/sgt_ws.php")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL)

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getComplementoMovimentoWS of Service WSsgt_ws_methodsService

WSMETHOD getComplementoMovimentoWS WSSEND ncodMovimento WSRECEIVE oWSgetComplementoMovimentoWSreturn WSCLIENT WSsgt_ws_methodsService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getComplementoMovimentoWS xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("codMovimento", ::ncodMovimento, ncodMovimento , "int", .T. , .T. , 0 , NIL, .F.,.F.)
cSoap += "</q1:getComplementoMovimentoWS>"

oXmlRet := SvcSoapCall(	Self,cSoap,;
	"https://www.cnj.jus.br/sgt/sgt_ws.php#getComplementoMovimentoWS",;
	"RPCX","https://www.cnj.jus.br/sgt/sgt_ws.php",,,;
	"https://www.cnj.jus.br/sgt/sgt_ws.php")

::Init()
::oWSgetComplementoMovimentoWSreturn:SoapRecv( WSAdvValue( oXmlRet,"_RETURN","ArrayOfComplementoMovimento",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getDataUltimaVersao of Service WSsgt_ws_methodsService

WSMETHOD getDataUltimaVersao WSSEND NULLPARAM WSRECEIVE creturn WSCLIENT WSsgt_ws_methodsService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getDataUltimaVersao xmlns:q1="https://www.cnj.jus.br/sgt/sgt_ws.php">'
cSoap += "</q1:getDataUltimaVersao>"

oXmlRet := SvcSoapCall(	Self,cSoap,;
	"https://www.cnj.jus.br/sgt/sgt_ws.php#getDataUltimaVersao",;
	"RPCX","https://www.cnj.jus.br/sgt/sgt_ws.php",,,;
	"https://www.cnj.jus.br/sgt/sgt_ws.php")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL)

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ArrayOfItem

WSSTRUCT sgt_ws_methodsService_ArrayOfItem
	WSDATA   oWSItem                   AS sgt_ws_methodsService_Item OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sgt_ws_methodsService_ArrayOfItem
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sgt_ws_methodsService_ArrayOfItem
	::oWSItem              := {} // Array Of  sgt_ws_methodsService_ITEM():New()
Return

WSMETHOD CLONE WSCLIENT sgt_ws_methodsService_ArrayOfItem
	Local oClone := sgt_ws_methodsService_ArrayOfItem():NEW()
	oClone:oWSItem := NIL
	If ::oWSItem <> NIL
		oClone:oWSItem := {}
		aEval( ::oWSItem , { |x| aadd( oClone:oWSItem , x:Clone() ) } )
	Endif
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sgt_ws_methodsService_ArrayOfItem
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSItem , sgt_ws_methodsService_Item():New() )
  			::oWSItem[len(::oWSItem)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure Item

WSSTRUCT sgt_ws_methodsService_Item
	WSDATA   ncod_item                 AS int OPTIONAL
	WSDATA   ncod_item_pai             AS int OPTIONAL
	WSDATA   cnome                     AS string OPTIONAL
	WSDATA   cdscGlossario             AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sgt_ws_methodsService_Item
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sgt_ws_methodsService_Item
Return

WSMETHOD CLONE WSCLIENT sgt_ws_methodsService_Item
	Local oClone := sgt_ws_methodsService_Item():NEW()
	oClone:ncod_item            := ::ncod_item
	oClone:ncod_item_pai        := ::ncod_item_pai
	oClone:cnome                := ::cnome
	oClone:cdscGlossario        := ::cdscGlossario
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sgt_ws_methodsService_Item
	::Init()
	If oResponse = NIL ; Return ; Endif
	::ncod_item          :=  WSAdvValue( oResponse,"_COD_ITEM","int",NIL,NIL,NIL,"N",NIL,NIL)
	::ncod_item_pai      :=  WSAdvValue( oResponse,"_COD_ITEM_PAI","int",NIL,NIL,NIL,"N",NIL,NIL)
	::cnome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cdscGlossario      :=  WSAdvValue( oResponse,"_DSCGLOSSARIO","string",NIL,NIL,NIL,"S",NIL,NIL)
Return

// WSDL Data Structure Array

WSSTRUCT sgt_ws_methodsService_Array
	WSDATA   oWSarrayAttributes        AS sgt_ws_methodsService_arrayAttributes OPTIONAL
	WSDATA   oWScommonAttributes       AS sgt_ws_methodsService_commonAttributes OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sgt_ws_methodsService_Array
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sgt_ws_methodsService_Array
Return

WSMETHOD CLONE WSCLIENT sgt_ws_methodsService_Array
	Local oClone := sgt_ws_methodsService_Array():NEW()
	oClone:oWSarrayAttributes   := IIF(::oWSarrayAttributes = NIL , NIL , ::oWSarrayAttributes:Clone() )
	oClone:oWScommonAttributes  := IIF(::oWScommonAttributes = NIL , NIL , ::oWScommonAttributes:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sgt_ws_methodsService_Array
	Local oNode1
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif
	oNode1 :=  WSAdvValue( oResponse,"_ARRAYATTRIBUTES","arrayAttributes",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode1 != NIL
		::oWSarrayAttributes := sgt_ws_methodsService_arrayAttributes():New()
		::oWSarrayAttributes:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_COMMONATTRIBUTES","commonAttributes",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode2 != NIL
		::oWScommonAttributes := sgt_ws_methodsService_commonAttributes():New()
		::oWScommonAttributes:SoapRecv(oNode2)
	EndIf
Return

// WSDL Data Structure arrayAttributes

WSSTRUCT sgt_ws_methodsService_arrayAttributes
	WSDATA   oWSarrayType              AS sgt_ws_methodsService_arrayType OPTIONAL
	WSDATA   oWSoffset                 AS sgt_ws_methodsService_offset OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sgt_ws_methodsService_arrayAttributes
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sgt_ws_methodsService_arrayAttributes
Return

WSMETHOD CLONE WSCLIENT sgt_ws_methodsService_arrayAttributes
	Local oClone := sgt_ws_methodsService_arrayAttributes():NEW()
	oClone:oWSarrayType         := IIF(::oWSarrayType = NIL , NIL , ::oWSarrayType:Clone() )
	oClone:oWSoffset            := IIF(::oWSoffset = NIL , NIL , ::oWSoffset:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sgt_ws_methodsService_arrayAttributes
	Local oNode1
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif
	oNode1 :=  WSAdvValue( oResponse,"_ARRAYTYPE","arrayType",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode1 != NIL
		::oWSarrayType := sgt_ws_methodsService_arrayType():New()
		::oWSarrayType:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_OFFSET","offset",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode2 != NIL
		::oWSoffset := sgt_ws_methodsService_offset():New()
		::oWSoffset:SoapRecv(oNode2)
	EndIf
Return

// WSDL Data Structure commonAttributes

WSSTRUCT sgt_ws_methodsService_commonAttributes
	WSDATA   oWSid                     AS sgt_ws_methodsService_ID OPTIONAL
	WSDATA   oWShref                   AS sgt_ws_methodsService_anyURI OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sgt_ws_methodsService_commonAttributes
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sgt_ws_methodsService_commonAttributes
Return

WSMETHOD CLONE WSCLIENT sgt_ws_methodsService_commonAttributes
	Local oClone := sgt_ws_methodsService_commonAttributes():NEW()
	oClone:oWSid                := IIF(::oWSid = NIL , NIL , ::oWSid:Clone() )
	oClone:oWShref              := IIF(::oWShref = NIL , NIL , ::oWShref:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sgt_ws_methodsService_commonAttributes
	Local oNode1
	Local oNode2
	Local oNode3
	::Init()
	If oResponse = NIL ; Return ; Endif
	oNode1 :=  WSAdvValue( oResponse,"_ID","ID",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode1 != NIL
		::oWSid := sgt_ws_methodsService_ID():New()
		::oWSid:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_HREF","anyURI",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode2 != NIL
		::oWShref := sgt_ws_methodsService_anyURI():New()
		::oWShref:SoapRecv(oNode2)
	EndIf
	oNode3 :=  WSAdvValue( oResponse,"_","",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode3 != NIL
		::oWS := sgt_ws_methodsService_():New()
		::oWS:SoapRecv(oNode3)
	EndIf
Return

// WSDL Data Structure ArrayOfArvoreGenerica

WSSTRUCT sgt_ws_methodsService_ArrayOfArvoreGenerica
	WSDATA   oWSArvoreGenerica         AS sgt_ws_methodsService_ArvoreGenerica OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sgt_ws_methodsService_ArrayOfArvoreGenerica
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sgt_ws_methodsService_ArrayOfArvoreGenerica
	::oWSArvoreGenerica    := {} // Array Of  sgt_ws_methodsService_ARVOREGENERICA():New()
Return

WSMETHOD CLONE WSCLIENT sgt_ws_methodsService_ArrayOfArvoreGenerica
	Local oClone := sgt_ws_methodsService_ArrayOfArvoreGenerica():NEW()
	oClone:oWSArvoreGenerica := NIL
	If ::oWSArvoreGenerica <> NIL
		oClone:oWSArvoreGenerica := {}
		aEval( ::oWSArvoreGenerica , { |x| aadd( oClone:oWSArvoreGenerica , x:Clone() ) } )
	Endif
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sgt_ws_methodsService_ArrayOfArvoreGenerica
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSArvoreGenerica , sgt_ws_methodsService_ArvoreGenerica():New() )
  			::oWSArvoreGenerica[len(::oWSArvoreGenerica)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArvoreGenerica

WSSTRUCT sgt_ws_methodsService_ArvoreGenerica
	WSDATA   nseq_elemento             AS int OPTIONAL
	WSDATA   cdsc_elemento             AS string OPTIONAL
	WSDATA   nseq_elemento_pai         AS int OPTIONAL
	WSDATA   ctemFilhos                AS string OPTIONAL
	WSDATA   csituacao                 AS string OPTIONAL
	WSDATA   oWSfilhos                 AS sgt_ws_methodsService_ArrayOfArvoreGenerica OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sgt_ws_methodsService_ArvoreGenerica
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sgt_ws_methodsService_ArvoreGenerica
Return

WSMETHOD CLONE WSCLIENT sgt_ws_methodsService_ArvoreGenerica
	Local oClone := sgt_ws_methodsService_ArvoreGenerica():NEW()
	oClone:nseq_elemento        := ::nseq_elemento
	oClone:cdsc_elemento        := ::cdsc_elemento
	oClone:nseq_elemento_pai    := ::nseq_elemento_pai
	oClone:ctemFilhos           := ::ctemFilhos
	oClone:csituacao            := ::csituacao
	oClone:oWSfilhos            := IIF(::oWSfilhos = NIL , NIL , ::oWSfilhos:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sgt_ws_methodsService_ArvoreGenerica
	Local oNode6
	::Init()
	If oResponse = NIL ; Return ; Endif
	::nseq_elemento      :=  WSAdvValue( oResponse,"_SEQ_ELEMENTO","int",NIL,NIL,NIL,"N",NIL,NIL)
	::cdsc_elemento      :=  WSAdvValue( oResponse,"_DSC_ELEMENTO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nseq_elemento_pai  :=  WSAdvValue( oResponse,"_SEQ_ELEMENTO_PAI","int",NIL,NIL,NIL,"N",NIL,NIL)
	::ctemFilhos         :=  WSAdvValue( oResponse,"_TEMFILHOS","string",NIL,NIL,NIL,"S",NIL,NIL)
	::csituacao          :=  WSAdvValue( oResponse,"_SITUACAO","string",NIL,NIL,NIL,"S",NIL,NIL)
	oNode6 :=  WSAdvValue( oResponse,"_FILHOS","ArrayOfArvoreGenerica",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode6 != NIL
		::oWSfilhos := sgt_ws_methodsService_ArrayOfArvoreGenerica():New()
		::oWSfilhos:SoapRecv(oNode6)
	EndIf
Return

// WSDL Data Structure ArrayOfComplementoMovimento

WSSTRUCT sgt_ws_methodsService_ArrayOfComplementoMovimento
	WSDATA   oWSComplementoMovimento   AS sgt_ws_methodsService_ComplementoMovimento OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sgt_ws_methodsService_ArrayOfComplementoMovimento
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sgt_ws_methodsService_ArrayOfComplementoMovimento
	::oWSComplementoMovimento := {} // Array Of  sgt_ws_methodsService_COMPLEMENTOMOVIMENTO():New()
Return

WSMETHOD CLONE WSCLIENT sgt_ws_methodsService_ArrayOfComplementoMovimento
	Local oClone := sgt_ws_methodsService_ArrayOfComplementoMovimento():NEW()
	oClone:oWSComplementoMovimento := NIL
	If ::oWSComplementoMovimento <> NIL
		oClone:oWSComplementoMovimento := {}
		aEval( ::oWSComplementoMovimento , { |x| aadd( oClone:oWSComplementoMovimento , x:Clone() ) } )
	Endif
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sgt_ws_methodsService_ArrayOfComplementoMovimento
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSComplementoMovimento , sgt_ws_methodsService_ComplementoMovimento():New() )
  			::oWSComplementoMovimento[len(::oWSComplementoMovimento)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ComplementoMovimento

WSSTRUCT sgt_ws_methodsService_ComplementoMovimento
	WSDATA   nseqComplemento           AS int OPTIONAL
	WSDATA   nseqTipoComplemento       AS int OPTIONAL
	WSDATA   nseqComplMov              AS int OPTIONAL
	WSDATA   cdscComplemento           AS string OPTIONAL
	WSDATA   cdscObservacao            AS string OPTIONAL
	WSDATA   oWSarrayValoresTabelados  AS sgt_ws_methodsService_Array OPTIONAL
	WSDATA   oWSarrayMovimentosVinculados AS sgt_ws_methodsService_Array OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sgt_ws_methodsService_ComplementoMovimento
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sgt_ws_methodsService_ComplementoMovimento
Return

WSMETHOD CLONE WSCLIENT sgt_ws_methodsService_ComplementoMovimento
	Local oClone := sgt_ws_methodsService_ComplementoMovimento():NEW()
	oClone:nseqComplemento      := ::nseqComplemento
	oClone:nseqTipoComplemento  := ::nseqTipoComplemento
	oClone:nseqComplMov         := ::nseqComplMov
	oClone:cdscComplemento      := ::cdscComplemento
	oClone:cdscObservacao       := ::cdscObservacao
	oClone:oWSarrayValoresTabelados := IIF(::oWSarrayValoresTabelados = NIL , NIL , ::oWSarrayValoresTabelados:Clone() )
	oClone:oWSarrayMovimentosVinculados := IIF(::oWSarrayMovimentosVinculados = NIL , NIL , ::oWSarrayMovimentosVinculados:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sgt_ws_methodsService_ComplementoMovimento
	Local oNode6
	Local oNode7
	::Init()
	If oResponse = NIL ; Return ; Endif
	::nseqComplemento    :=  WSAdvValue( oResponse,"_SEQCOMPLEMENTO","int",NIL,NIL,NIL,"N",NIL,NIL)
	::nseqTipoComplemento :=  WSAdvValue( oResponse,"_SEQTIPOCOMPLEMENTO","int",NIL,NIL,NIL,"N",NIL,NIL)
	::nseqComplMov       :=  WSAdvValue( oResponse,"_SEQCOMPLMOV","int",NIL,NIL,NIL,"N",NIL,NIL)
	::cdscComplemento    :=  WSAdvValue( oResponse,"_DSCCOMPLEMENTO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cdscObservacao     :=  WSAdvValue( oResponse,"_DSCOBSERVACAO","string",NIL,NIL,NIL,"S",NIL,NIL)
	oNode6 :=  WSAdvValue( oResponse,"_ARRAYVALORESTABELADOS","Array",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode6 != NIL
		::oWSarrayValoresTabelados := sgt_ws_methodsService_Array():New()
		::oWSarrayValoresTabelados:SoapRecv(oNode6)
	EndIf
	oNode7 :=  WSAdvValue( oResponse,"_ARRAYMOVIMENTOSVINCULADOS","Array",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode7 != NIL
		::oWSarrayMovimentosVinculados := sgt_ws_methodsService_Array():New()
		::oWSarrayMovimentosVinculados:SoapRecv(oNode7)
	EndIf
Return

// WSDL Data Structure arrayCoordinate

WSSTRUCT sgt_ws_methodsService_arrayCoordinate
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sgt_ws_methodsService_arrayCoordinate
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sgt_ws_methodsService_arrayCoordinate
Return

WSMETHOD CLONE WSCLIENT sgt_ws_methodsService_arrayCoordinate
	Local oClone := sgt_ws_methodsService_arrayCoordinate():NEW()
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sgt_ws_methodsService_arrayCoordinate
	::Init()
	If oResponse = NIL ; Return ; Endif
Return

// WSDL Data Structure ID

WSSTRUCT sgt_ws_methodsService_ID
	WSDATA   oWScommonAttributes       AS sgt_ws_methodsService_commonAttributes OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sgt_ws_methodsService_ID
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sgt_ws_methodsService_ID
Return

WSMETHOD CLONE WSCLIENT sgt_ws_methodsService_ID
	Local oClone := sgt_ws_methodsService_ID():NEW()
	oClone:oWScommonAttributes  := IIF(::oWScommonAttributes = NIL , NIL , ::oWScommonAttributes:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sgt_ws_methodsService_ID
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif
	oNode1 :=  WSAdvValue( oResponse,"_COMMONATTRIBUTES","commonAttributes",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode1 != NIL
		::oWScommonAttributes := sgt_ws_methodsService_commonAttributes():New()
		::oWScommonAttributes:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure anyURI

WSSTRUCT sgt_ws_methodsService_anyURI
	WSDATA   oWScommonAttributes       AS sgt_ws_methodsService_commonAttributes OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sgt_ws_methodsService_anyURI
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sgt_ws_methodsService_anyURI
Return

WSMETHOD CLONE WSCLIENT sgt_ws_methodsService_anyURI
	Local oClone := sgt_ws_methodsService_anyURI():NEW()
	oClone:oWScommonAttributes  := IIF(::oWScommonAttributes = NIL , NIL , ::oWScommonAttributes:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sgt_ws_methodsService_anyURI
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif
	oNode1 :=  WSAdvValue( oResponse,"_COMMONATTRIBUTES","commonAttributes",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode1 != NIL
		::oWScommonAttributes := sgt_ws_methodsService_commonAttributes():New()
		::oWScommonAttributes:SoapRecv(oNode1)
	EndIf
Return


