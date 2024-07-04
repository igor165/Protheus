#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://homologacao.ikeda.com.br/totvs/ikcwebservice/filtro.asmx?wsdl
Gerado em        04/23/13 10:42:50
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _SYZMKDR ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSFiltro
------------------------------------------------------------------------------- */

WSCLIENT WSFiltro

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
	WSDATA   oWSCategoriasCodigoInterno AS Filtro_ArrayOfString
	WSDATA   cNomeFiltro               AS string
	WSDATA   cDescricaoFiltro          AS string
	WSDATA   nObrigatorio              AS int
	WSDATA   nStatusFiltro             AS int
	WSDATA   cA1                       AS string
	WSDATA   cA2                       AS string
	WSDATA   oWS                       AS SCHEMA
	WSDATA   oWSSalvarResult           AS Filtro_clsRetornoOfclsCaracteristicas
	WSDATA   oWSExcluirResult          AS Filtro_clsRetornoOfclsCaracteristicas

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSFiltro
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.120420A-20120726] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
If val(right(GetWSCVer(),8)) < 1.040504
	UserException("O Código-Fonte Client atual requer a versão de Lib para WebServices igual ou superior a ADVPL WSDL Client 1.040504. Atualize o repositório ou gere o Código-Fonte novamente utilizando o repositório atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSFiltro
	::oWSCategoriasCodigoInterno := Filtro_ARRAYOFSTRING():New()
	::oWS                := NIL 
	::oWSSalvarResult    := Filtro_CLSRETORNOOFCLSCARACTERISTICAS():New()
	::oWSExcluirResult   := Filtro_CLSRETORNOOFCLSCARACTERISTICAS():New()
Return

WSMETHOD RESET WSCLIENT WSFiltro
	::nLojaCodigo        := NIL 
	::cCodigoInternoFiltro := NIL 
	::oWSCategoriasCodigoInterno := NIL 
	::cNomeFiltro        := NIL 
	::cDescricaoFiltro   := NIL 
	::nObrigatorio       := NIL 
	::nStatusFiltro      := NIL 
	::cA1                := NIL 
	::cA2                := NIL 
	::oWS                := NIL 
	::oWSSalvarResult    := NIL 
	::oWSExcluirResult   := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSFiltro
Local oClone := WSFiltro():New()
	oClone:_URL          := ::_URL 
	oClone:nLojaCodigo   := ::nLojaCodigo
	oClone:cCodigoInternoFiltro := ::cCodigoInternoFiltro
	oClone:oWSCategoriasCodigoInterno :=  IIF(::oWSCategoriasCodigoInterno = NIL , NIL ,::oWSCategoriasCodigoInterno:Clone() )
	oClone:cNomeFiltro   := ::cNomeFiltro
	oClone:cDescricaoFiltro := ::cDescricaoFiltro
	oClone:nObrigatorio  := ::nObrigatorio
	oClone:nStatusFiltro := ::nStatusFiltro
	oClone:cA1           := ::cA1
	oClone:cA2           := ::cA2
	oClone:oWSSalvarResult :=  IIF(::oWSSalvarResult = NIL , NIL ,::oWSSalvarResult:Clone() )
	oClone:oWSExcluirResult :=  IIF(::oWSExcluirResult = NIL , NIL ,::oWSExcluirResult:Clone() )
Return oClone

// WSDL Method Salvar of Service WSFiltro

WSMETHOD Salvar WSSEND nLojaCodigo,cCodigoInternoFiltro,oWSCategoriasCodigoInterno,cNomeFiltro,cDescricaoFiltro,nObrigatorio,nStatusFiltro,cA1,cA2,oWS WSRECEIVE oWSSalvarResult WSCLIENT WSFiltro
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
cSoap += WSSoapValue("CategoriasCodigoInterno", ::oWSCategoriasCodigoInterno, oWSCategoriasCodigoInterno , "ArrayOfString", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NomeFiltro", ::cNomeFiltro, cNomeFiltro , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DescricaoFiltro", ::cDescricaoFiltro, cDescricaoFiltro , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Obrigatorio", ::nObrigatorio, nObrigatorio , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("StatusFiltro", ::nStatusFiltro, nStatusFiltro , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += "</Salvar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Salvar",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/filtro.asmx")

::Init()
::oWSSalvarResult:SoapRecv( WSAdvValue( oXmlRet,"_SALVARRESPONSE:_SALVARRESULT","clsRetornoOfclsCaracteristicas",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Excluir of Service WSFiltro

WSMETHOD Excluir WSSEND nLojaCodigo,cCodigoInternoFiltro,cA1,cA2,oWS WSRECEIVE oWSExcluirResult WSCLIENT WSFiltro
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
cSoap += "</Excluir>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ikeda.com.br/Excluir",; 
	"DOCUMENT","http://www.ikeda.com.br",cSoapHead,,; 
	"http://homologacao.ikeda.com.br/totvs/ikcwebservice/filtro.asmx")

::Init()
::oWSExcluirResult:SoapRecv( WSAdvValue( oXmlRet,"_EXCLUIRRESPONSE:_EXCLUIRRESULT","clsRetornoOfclsCaracteristicas",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ArrayOfString

WSSTRUCT Filtro_ArrayOfString
	WSDATA   cstring                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Filtro_ArrayOfString
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Filtro_ArrayOfString
	::cstring              := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT Filtro_ArrayOfString
	Local oClone := Filtro_ArrayOfString():NEW()
	oClone:cstring              := IIf(::cstring <> NIL , aClone(::cstring) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Filtro_ArrayOfString
	Local cSoap := ""
	aEval( ::cstring , {|x| cSoap := cSoap  +  WSSoapValue("string", x , x , "string", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure clsRetornoOfclsCaracteristicas

WSSTRUCT Filtro_clsRetornoOfclsCaracteristicas
	WSDATA   cAcao                     AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   nCodigo                   AS int
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   oWSLista                  AS Filtro_ArrayOfClsCaracteristicas OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Filtro_clsRetornoOfclsCaracteristicas
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Filtro_clsRetornoOfclsCaracteristicas
Return

WSMETHOD CLONE WSCLIENT Filtro_clsRetornoOfclsCaracteristicas
	Local oClone := Filtro_clsRetornoOfclsCaracteristicas():NEW()
	oClone:cAcao                := ::cAcao
	oClone:cData                := ::cData
	oClone:nCodigo              := ::nCodigo
	oClone:cDescricao           := ::cDescricao
	oClone:oWSLista             := IIF(::oWSLista = NIL , NIL , ::oWSLista:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Filtro_clsRetornoOfclsCaracteristicas
	Local oNode5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAcao              :=  WSAdvValue( oResponse,"_ACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nCodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,"Property nCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode5 :=  WSAdvValue( oResponse,"_LISTA","ArrayOfClsCaracteristicas",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSLista := Filtro_ArrayOfClsCaracteristicas():New()
		::oWSLista:SoapRecv(oNode5)
	EndIf
Return

// WSDL Data Structure ArrayOfClsCaracteristicas

WSSTRUCT Filtro_ArrayOfClsCaracteristicas
	WSDATA   oWSclsCaracteristicas     AS Filtro_clsCaracteristicas OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Filtro_ArrayOfClsCaracteristicas
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Filtro_ArrayOfClsCaracteristicas
	::oWSclsCaracteristicas := {} // Array Of  Filtro_CLSCARACTERISTICAS():New()
Return

WSMETHOD CLONE WSCLIENT Filtro_ArrayOfClsCaracteristicas
	Local oClone := Filtro_ArrayOfClsCaracteristicas():NEW()
	oClone:oWSclsCaracteristicas := NIL
	If ::oWSclsCaracteristicas <> NIL 
		oClone:oWSclsCaracteristicas := {}
		aEval( ::oWSclsCaracteristicas , { |x| aadd( oClone:oWSclsCaracteristicas , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Filtro_ArrayOfClsCaracteristicas
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLSCARACTERISTICAS","clsCaracteristicas",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSclsCaracteristicas , Filtro_clsCaracteristicas():New() )
			::oWSclsCaracteristicas[len(::oWSclsCaracteristicas)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure clsCaracteristicas

WSSTRUCT Filtro_clsCaracteristicas
	WSDATA   nLojaCodigo               AS int
	WSDATA   cCaracteristicasCodigoInterno AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   oWSObrigatorio            AS Filtro_SimNao
	WSDATA   oWSCaracteristicasStatus  AS Filtro_CaracteristicasStatus
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Filtro_clsCaracteristicas
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Filtro_clsCaracteristicas
Return

WSMETHOD CLONE WSCLIENT Filtro_clsCaracteristicas
	Local oClone := Filtro_clsCaracteristicas():NEW()
	oClone:nLojaCodigo          := ::nLojaCodigo
	oClone:cCaracteristicasCodigoInterno := ::cCaracteristicasCodigoInterno
	oClone:cNome                := ::cNome
	oClone:cDescricao           := ::cDescricao
	oClone:oWSObrigatorio       := IIF(::oWSObrigatorio = NIL , NIL , ::oWSObrigatorio:Clone() )
	oClone:oWSCaracteristicasStatus := IIF(::oWSCaracteristicasStatus = NIL , NIL , ::oWSCaracteristicasStatus:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Filtro_clsCaracteristicas
	Local oNode5
	Local oNode6
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nLojaCodigo        :=  WSAdvValue( oResponse,"_LOJACODIGO","int",NIL,"Property nLojaCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCaracteristicasCodigoInterno :=  WSAdvValue( oResponse,"_CARACTERISTICASCODIGOINTERNO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode5 :=  WSAdvValue( oResponse,"_OBRIGATORIO","SimNao",NIL,"Property oWSObrigatorio as tns:SimNao on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSObrigatorio := Filtro_SimNao():New()
		::oWSObrigatorio:SoapRecv(oNode5)
	EndIf
	oNode6 :=  WSAdvValue( oResponse,"_CARACTERISTICASSTATUS","CaracteristicasStatus",NIL,"Property oWSCaracteristicasStatus as tns:CaracteristicasStatus on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode6 != NIL
		::oWSCaracteristicasStatus := Filtro_CaracteristicasStatus():New()
		::oWSCaracteristicasStatus:SoapRecv(oNode6)
	EndIf
Return

// WSDL Data Enumeration SimNao

WSSTRUCT Filtro_SimNao
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Filtro_SimNao
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Nenhum" )
	aadd(::aValueList , "Sim" )
	aadd(::aValueList , "Não" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Filtro_SimNao
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Filtro_SimNao
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Filtro_SimNao
Local oClone := Filtro_SimNao():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration CaracteristicasStatus

WSSTRUCT Filtro_CaracteristicasStatus
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Filtro_CaracteristicasStatus
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Nenhum" )
	aadd(::aValueList , "Ativo" )
	aadd(::aValueList , "Inativo" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Filtro_CaracteristicasStatus
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Filtro_CaracteristicasStatus
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Filtro_CaracteristicasStatus
Local oClone := Filtro_CaracteristicasStatus():New()
	oClone:Value := ::Value
Return oClone


