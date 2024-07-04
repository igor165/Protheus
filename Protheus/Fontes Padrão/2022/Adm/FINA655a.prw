#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://homolog.totvs.reserve.com.br/ReserveXml300/centroscusto.asmx?WSDL
Gerado em        12/06/13 10:12:41
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

Function FINA655A ; Return

/* -------------------------------------------------------------------------------
WSDL Service WSCentrosCusto
------------------------------------------------------------------------------- */

WSCLIENT WSCentrosCusto

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Consultar
	WSMETHOD Inserir
	WSMETHOD Excluir

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSConsultarCentrosCustoRQ AS CentrosCusto_ConsultarCentrosCustoRQ
	WSDATA   oWSConsultarResult        AS CentrosCusto_ConsultarCentrosCustoRS
	WSDATA   oWSInserirCentrosCustoRQ  AS CentrosCusto_InserirCentrosCustoRQ
	WSDATA   oWSInserirResult          AS CentrosCusto_InserirCentrosCustoRS
	WSDATA   oWSExcluirCentrosCustoRQ  AS CentrosCusto_ExcluirCentrosCustoRQ
	WSDATA   oWSExcluirResult          AS CentrosCusto_ExcluirCentrosCustoRS

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSCentrosCusto
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20130625] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSCentrosCusto
	::oWSConsultarCentrosCustoRQ := CentrosCusto_CONSULTARCENTROSCUSTORQ():New()
	::oWSConsultarResult := CentrosCusto_CONSULTARCENTROSCUSTORS():New()
	::oWSInserirCentrosCustoRQ := CentrosCusto_INSERIRCENTROSCUSTORQ():New()
	::oWSInserirResult   := CentrosCusto_INSERIRCENTROSCUSTORS():New()
	::oWSExcluirCentrosCustoRQ := CentrosCusto_EXCLUIRCENTROSCUSTORQ():New()
	::oWSExcluirResult   := CentrosCusto_EXCLUIRCENTROSCUSTORS():New()
Return

WSMETHOD RESET WSCLIENT WSCentrosCusto
	::oWSConsultarCentrosCustoRQ := NIL 
	::oWSConsultarResult := NIL 
	::oWSInserirCentrosCustoRQ := NIL 
	::oWSInserirResult   := NIL 
	::oWSExcluirCentrosCustoRQ := NIL 
	::oWSExcluirResult   := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSCentrosCusto
Local oClone := WSCentrosCusto():New()
	oClone:_URL          := ::_URL 
	oClone:oWSConsultarCentrosCustoRQ :=  IIF(::oWSConsultarCentrosCustoRQ = NIL , NIL ,::oWSConsultarCentrosCustoRQ:Clone() )
	oClone:oWSConsultarResult :=  IIF(::oWSConsultarResult = NIL , NIL ,::oWSConsultarResult:Clone() )
	oClone:oWSInserirCentrosCustoRQ :=  IIF(::oWSInserirCentrosCustoRQ = NIL , NIL ,::oWSInserirCentrosCustoRQ:Clone() )
	oClone:oWSInserirResult :=  IIF(::oWSInserirResult = NIL , NIL ,::oWSInserirResult:Clone() )
	oClone:oWSExcluirCentrosCustoRQ :=  IIF(::oWSExcluirCentrosCustoRQ = NIL , NIL ,::oWSExcluirCentrosCustoRQ:Clone() )
	oClone:oWSExcluirResult :=  IIF(::oWSExcluirResult = NIL , NIL ,::oWSExcluirResult:Clone() )
Return oClone

// WSDL Method Consultar of Service WSCentrosCusto

WSMETHOD Consultar WSSEND oWSConsultarCentrosCustoRQ WSRECEIVE oWSConsultarResult WSCLIENT WSCentrosCusto
Local cSoap	:= "" , oXmlRet
Local cUrlAmb	:= SuperGetMv("MV_RESAMB",,"")

cUrlAmb += "/ReserveXml300/centroscusto.asmx"

BEGIN WSMETHOD

cSoap += '<Consultar xmlns="http://www.reserve.com.br/ReserveXML300/">'
cSoap += WSSoapValue("ConsultarCentrosCustoRQ", ::oWSConsultarCentrosCustoRQ, oWSConsultarCentrosCustoRQ , "ConsultarCentrosCustoRQ", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Consultar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.reserve.com.br/ReserveXML300/Consultar",; 
	"DOCUMENT","http://www.reserve.com.br/ReserveXML300/",,,; 
	cUrlAmb)

::Init()
::oWSConsultarResult:SoapRecv( WSAdvValue( oXmlRet,"_CONSULTARRESPONSE:_CONSULTARRESULT","ConsultarCentrosCustoRS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL

Return .T.

// WSDL Method Inserir of Service WSCentrosCusto

WSMETHOD Inserir WSSEND oWSInserirCentrosCustoRQ WSRECEIVE oWSInserirResult WSCLIENT WSCentrosCusto
Local cSoap		:= "" , oXmlRet
Local cUrlAmb	:= SuperGetMv("MV_RESAMB",,"")

cUrlAmb += "/ReserveXml300/centroscusto.asmx"

BEGIN WSMETHOD

cSoap += '<Inserir xmlns="http://www.reserve.com.br/ReserveXML300/">'
cSoap += WSSoapValue("InserirCentrosCustoRQ", ::oWSInserirCentrosCustoRQ, oWSInserirCentrosCustoRQ , "InserirCentrosCustoRQ", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Inserir>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.reserve.com.br/ReserveXML300/Inserir",; 
	"DOCUMENT","http://www.reserve.com.br/ReserveXML300/",,,; 
	cUrlAmb)

::Init()
::oWSInserirResult:SoapRecv( WSAdvValue( oXmlRet,"_INSERIRRESPONSE:_INSERIRRESULT","InserirCentrosCustoRS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Excluir of Service WSCentrosCusto

WSMETHOD Excluir WSSEND oWSExcluirCentrosCustoRQ WSRECEIVE oWSExcluirResult WSCLIENT WSCentrosCusto
Local cSoap	:= "" , oXmlRet
Local cUrlAmb	:= SuperGetMv("MV_RESAMB",,"")

cUrlAmb += "/ReserveXml300/centroscusto.asmx"

BEGIN WSMETHOD

cSoap += '<Excluir xmlns="http://www.reserve.com.br/ReserveXML300/">'
cSoap += WSSoapValue("ExcluirCentrosCustoRQ", ::oWSExcluirCentrosCustoRQ, oWSExcluirCentrosCustoRQ , "ExcluirCentrosCustoRQ", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Excluir>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.reserve.com.br/ReserveXML300/Excluir",; 
	"DOCUMENT","http://www.reserve.com.br/ReserveXML300/",,,; 
	cUrlAmb)

::Init()
::oWSExcluirResult:SoapRecv( WSAdvValue( oXmlRet,"_EXCLUIRRESPONSE:_EXCLUIRRESULT","ExcluirCentrosCustoRS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ConsultarCentrosCustoRQ

WSSTRUCT CentrosCusto_ConsultarCentrosCustoRQ
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSCODBKOs                AS CentrosCusto_ArrayOfString OPTIONAL
	WSDATA   oWSGrupos                 AS CentrosCusto_ArrayOfString1 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CentrosCusto_ConsultarCentrosCustoRQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CentrosCusto_ConsultarCentrosCustoRQ
Return

WSMETHOD CLONE WSCLIENT CentrosCusto_ConsultarCentrosCustoRQ
	Local oClone := CentrosCusto_ConsultarCentrosCustoRQ():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSCODBKOs           := IIF(::oWSCODBKOs = NIL , NIL , ::oWSCODBKOs:Clone() )
	oClone:oWSGrupos            := IIF(::oWSGrupos = NIL , NIL , ::oWSGrupos:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT CentrosCusto_ConsultarCentrosCustoRQ
	Local cSoap := ""
	cSoap += WSSoapValue("Sessao", ::cSessao, ::cSessao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CODBKOs", ::oWSCODBKOs, ::oWSCODBKOs , "ArrayOfString", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Grupos", ::oWSGrupos, ::oWSGrupos , "ArrayOfString1", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ConsultarCentrosCustoRS

WSSTRUCT CentrosCusto_ConsultarCentrosCustoRS
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSCentrosCusto           AS CentrosCusto_ArrayOfCentroCusto OPTIONAL
	WSDATA   oWSErros                  AS CentrosCusto_ArrayOfErro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CentrosCusto_ConsultarCentrosCustoRS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CentrosCusto_ConsultarCentrosCustoRS
Return

WSMETHOD CLONE WSCLIENT CentrosCusto_ConsultarCentrosCustoRS
	Local oClone := CentrosCusto_ConsultarCentrosCustoRS():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSCentrosCusto      := IIF(::oWSCentrosCusto = NIL , NIL , ::oWSCentrosCusto:Clone() )
	oClone:oWSErros             := IIF(::oWSErros = NIL , NIL , ::oWSErros:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT CentrosCusto_ConsultarCentrosCustoRS
	Local oNode2
	Local oNode3
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSessao            :=  WSAdvValue( oResponse,"_SESSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_CENTROSCUSTO","ArrayOfCentroCusto",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSCentrosCusto := CentrosCusto_ArrayOfCentroCusto():New()
		::oWSCentrosCusto:SoapRecv(oNode2)
	EndIf
	oNode3 :=  WSAdvValue( oResponse,"_ERROS","ArrayOfErro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode3 != NIL
		::oWSErros := CentrosCusto_ArrayOfErro():New()
		::oWSErros:SoapRecv(oNode3)
	EndIf
Return

// WSDL Data Structure InserirCentrosCustoRQ

WSSTRUCT CentrosCusto_InserirCentrosCustoRQ
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSCentrosCusto           AS CentrosCusto_ArrayOfCentroCusto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CentrosCusto_InserirCentrosCustoRQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CentrosCusto_InserirCentrosCustoRQ
Return

WSMETHOD CLONE WSCLIENT CentrosCusto_InserirCentrosCustoRQ
	Local oClone := CentrosCusto_InserirCentrosCustoRQ():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSCentrosCusto      := IIF(::oWSCentrosCusto = NIL , NIL , ::oWSCentrosCusto:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT CentrosCusto_InserirCentrosCustoRQ
	Local cSoap := ""
	cSoap += WSSoapValue("Sessao", ::cSessao, ::cSessao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CentrosCusto", ::oWSCentrosCusto, ::oWSCentrosCusto , "ArrayOfCentroCusto", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure InserirCentrosCustoRS

WSSTRUCT CentrosCusto_InserirCentrosCustoRS
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSErros                  AS CentrosCusto_ArrayOfErro OPTIONAL
	WSDATA   oWSCCustos                AS CentrosCusto_ArrayOfCentroCusto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CentrosCusto_InserirCentrosCustoRS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CentrosCusto_InserirCentrosCustoRS
Return

WSMETHOD CLONE WSCLIENT CentrosCusto_InserirCentrosCustoRS
	Local oClone := CentrosCusto_InserirCentrosCustoRS():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSErros             := IIF(::oWSErros = NIL , NIL , ::oWSErros:Clone() )
	oClone:oWSCCustos           := IIF(::oWSCCustos = NIL , NIL , ::oWSCCustos:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT CentrosCusto_InserirCentrosCustoRS
	Local oNode2
	Local oNode3
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSessao            :=  WSAdvValue( oResponse,"_SESSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_ERROS","ArrayOfErro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSErros := CentrosCusto_ArrayOfErro():New()
		::oWSErros:SoapRecv(oNode2)
	EndIf
	oNode3 :=  WSAdvValue( oResponse,"_CCUSTOS","ArrayOfCentroCusto",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode3 != NIL
		::oWSCCustos := CentrosCusto_ArrayOfCentroCusto():New()
		::oWSCCustos:SoapRecv(oNode3)
	EndIf
Return

// WSDL Data Structure ExcluirCentrosCustoRQ

WSSTRUCT CentrosCusto_ExcluirCentrosCustoRQ
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSCODBKOs                AS CentrosCusto_ArrayOfString OPTIONAL
	WSDATA   cGrupo                    AS string OPTIONAL
	WSDATA   oWSCentrosCusto           AS CentrosCusto_ArrayOfString2 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CentrosCusto_ExcluirCentrosCustoRQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CentrosCusto_ExcluirCentrosCustoRQ
Return

WSMETHOD CLONE WSCLIENT CentrosCusto_ExcluirCentrosCustoRQ
	Local oClone := CentrosCusto_ExcluirCentrosCustoRQ():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSCODBKOs           := IIF(::oWSCODBKOs = NIL , NIL , ::oWSCODBKOs:Clone() )
	oClone:cGrupo               := ::cGrupo
	oClone:oWSCentrosCusto      := IIF(::oWSCentrosCusto = NIL , NIL , ::oWSCentrosCusto:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT CentrosCusto_ExcluirCentrosCustoRQ
	Local cSoap := ""
	cSoap += WSSoapValue("Sessao", ::cSessao, ::cSessao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CODBKOs", ::oWSCODBKOs, ::oWSCODBKOs , "ArrayOfString", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Grupo", ::cGrupo, ::cGrupo , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CentrosCusto", ::oWSCentrosCusto, ::oWSCentrosCusto , "ArrayOfString2", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ExcluirCentrosCustoRS

WSSTRUCT CentrosCusto_ExcluirCentrosCustoRS
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSErros                  AS CentrosCusto_ArrayOfErro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CentrosCusto_ExcluirCentrosCustoRS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CentrosCusto_ExcluirCentrosCustoRS
Return

WSMETHOD CLONE WSCLIENT CentrosCusto_ExcluirCentrosCustoRS
	Local oClone := CentrosCusto_ExcluirCentrosCustoRS():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSErros             := IIF(::oWSErros = NIL , NIL , ::oWSErros:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT CentrosCusto_ExcluirCentrosCustoRS
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSessao            :=  WSAdvValue( oResponse,"_SESSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_ERROS","ArrayOfErro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSErros := CentrosCusto_ArrayOfErro():New()
		::oWSErros:SoapRecv(oNode2)
	EndIf
Return

// WSDL Data Structure ArrayOfString

WSSTRUCT CentrosCusto_ArrayOfString
	WSDATA   cCODBKO                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CentrosCusto_ArrayOfString
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CentrosCusto_ArrayOfString
	::cCODBKO              := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT CentrosCusto_ArrayOfString
	Local oClone := CentrosCusto_ArrayOfString():NEW()
	oClone:cCODBKO              := IIf(::cCODBKO <> NIL , aClone(::cCODBKO) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT CentrosCusto_ArrayOfString
	Local cSoap := ""
	aEval( ::cCODBKO , {|x| cSoap := cSoap  +  WSSoapValue("CODBKO", x , x , "string", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfString1

WSSTRUCT CentrosCusto_ArrayOfString1
	WSDATA   cGrupo                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CentrosCusto_ArrayOfString1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CentrosCusto_ArrayOfString1
	::cGrupo               := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT CentrosCusto_ArrayOfString1
	Local oClone := CentrosCusto_ArrayOfString1():NEW()
	oClone:cGrupo               := IIf(::cGrupo <> NIL , aClone(::cGrupo) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT CentrosCusto_ArrayOfString1
	Local cSoap := ""
	aEval( ::cGrupo , {|x| cSoap := cSoap  +  WSSoapValue("Grupo", x , x , "string", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfCentroCusto

WSSTRUCT CentrosCusto_ArrayOfCentroCusto
	WSDATA   oWSCentroCusto            AS CentrosCusto_CentroCusto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CentrosCusto_ArrayOfCentroCusto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CentrosCusto_ArrayOfCentroCusto
	::oWSCentroCusto       := {} // Array Of  CentrosCusto_CENTROCUSTO():New()
Return

WSMETHOD CLONE WSCLIENT CentrosCusto_ArrayOfCentroCusto
	Local oClone := CentrosCusto_ArrayOfCentroCusto():NEW()
	oClone:oWSCentroCusto := NIL
	If ::oWSCentroCusto <> NIL 
		oClone:oWSCentroCusto := {}
		aEval( ::oWSCentroCusto , { |x| aadd( oClone:oWSCentroCusto , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT CentrosCusto_ArrayOfCentroCusto
	Local cSoap := ""
	aEval( ::oWSCentroCusto , {|x| cSoap := cSoap  +  WSSoapValue("CentroCusto", x , x , "CentroCusto", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT CentrosCusto_ArrayOfCentroCusto
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CENTROCUSTO","CentroCusto",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSCentroCusto , CentrosCusto_CentroCusto():New() )
			::oWSCentroCusto[len(::oWSCentroCusto)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfErro

WSSTRUCT CentrosCusto_ArrayOfErro
	WSDATA   oWSErro                   AS CentrosCusto_Erro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CentrosCusto_ArrayOfErro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CentrosCusto_ArrayOfErro
	::oWSErro              := {} // Array Of  CentrosCusto_ERRO():New()
Return

WSMETHOD CLONE WSCLIENT CentrosCusto_ArrayOfErro
	Local oClone := CentrosCusto_ArrayOfErro():NEW()
	oClone:oWSErro := NIL
	If ::oWSErro <> NIL 
		oClone:oWSErro := {}
		aEval( ::oWSErro , { |x| aadd( oClone:oWSErro , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT CentrosCusto_ArrayOfErro
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ERRO","Erro",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSErro , CentrosCusto_Erro():New() )
			::oWSErro[len(::oWSErro)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfString2

WSSTRUCT CentrosCusto_ArrayOfString2
	WSDATA   cCentroCusto              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CentrosCusto_ArrayOfString2
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CentrosCusto_ArrayOfString2
	::cCentroCusto         := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT CentrosCusto_ArrayOfString2
	Local oClone := CentrosCusto_ArrayOfString2():NEW()
	oClone:cCentroCusto         := IIf(::cCentroCusto <> NIL , aClone(::cCentroCusto) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT CentrosCusto_ArrayOfString2
	Local cSoap := ""
	aEval( ::cCentroCusto , {|x| cSoap := cSoap  +  WSSoapValue("CentroCusto", x , x , "string", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure CentroCusto

WSSTRUCT CentrosCusto_CentroCusto
	WSDATA   cCODBKO                   AS string OPTIONAL
	WSDATA   cCentroCusto              AS string OPTIONAL
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   cGrupo                    AS string OPTIONAL
	WSDATA   nIDReserve                AS int
	WSDATA   oWSIDAutorizadores        AS CentrosCusto_ArrayOfInt OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CentrosCusto_CentroCusto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CentrosCusto_CentroCusto
Return

WSMETHOD CLONE WSCLIENT CentrosCusto_CentroCusto
	Local oClone := CentrosCusto_CentroCusto():NEW()
	oClone:cCODBKO              := ::cCODBKO
	oClone:cCentroCusto         := ::cCentroCusto
	oClone:cDescricao           := ::cDescricao
	oClone:cGrupo               := ::cGrupo
	oClone:nIDReserve           := ::nIDReserve
	oClone:oWSIDAutorizadores   := IIF(::oWSIDAutorizadores = NIL , NIL , ::oWSIDAutorizadores:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT CentrosCusto_CentroCusto
	Local cSoap := ""
	cSoap += WSSoapValue("CODBKO", ::cCODBKO, ::cCODBKO , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CentroCusto", ::cCentroCusto, ::cCentroCusto , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Descricao", ::cDescricao, ::cDescricao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Grupo", ::cGrupo, ::cGrupo , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("IDReserve", ::nIDReserve, ::nIDReserve , "int", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("IDAutorizadores", ::oWSIDAutorizadores, ::oWSIDAutorizadores , "ArrayOfInt", .F. , .F., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT CentrosCusto_CentroCusto
	Local oNode6
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODBKO            :=  WSAdvValue( oResponse,"_CODBKO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCentroCusto       :=  WSAdvValue( oResponse,"_CENTROCUSTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cGrupo             :=  WSAdvValue( oResponse,"_GRUPO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nIDReserve         :=  WSAdvValue( oResponse,"_IDRESERVE","int",NIL,"Property nIDReserve as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode6 :=  WSAdvValue( oResponse,"_IDAUTORIZADORES","ArrayOfInt",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode6 != NIL
		::oWSIDAutorizadores := CentrosCusto_ArrayOfInt():New()
		::oWSIDAutorizadores:SoapRecv(oNode6)
	EndIf
Return

// WSDL Data Structure Erro

WSSTRUCT CentrosCusto_Erro
	WSDATA   cCodErro                  AS string OPTIONAL
	WSDATA   cMensagem                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CentrosCusto_Erro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CentrosCusto_Erro
Return

WSMETHOD CLONE WSCLIENT CentrosCusto_Erro
	Local oClone := CentrosCusto_Erro():NEW()
	oClone:cCodErro             := ::cCodErro
	oClone:cMensagem            := ::cMensagem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT CentrosCusto_Erro
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodErro           :=  WSAdvValue( oResponse,"_CODERRO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfInt

WSSTRUCT CentrosCusto_ArrayOfInt
	WSDATA   nIDAutorizador            AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CentrosCusto_ArrayOfInt
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CentrosCusto_ArrayOfInt
	::nIDAutorizador       := {} // Array Of  0
Return

WSMETHOD CLONE WSCLIENT CentrosCusto_ArrayOfInt
	Local oClone := CentrosCusto_ArrayOfInt():NEW()
	oClone:nIDAutorizador       := IIf(::nIDAutorizador <> NIL , aClone(::nIDAutorizador) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT CentrosCusto_ArrayOfInt
	Local cSoap := ""
	aEval( ::nIDAutorizador , {|x| cSoap := cSoap  +  WSSoapValue("IDAutorizador", x , x , "int", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT CentrosCusto_ArrayOfInt
	Local oNodes1 :=  WSAdvValue( oResponse,"_IDAUTORIZADOR","int",{},NIL,.T.,"N",NIL,"a") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	aEval(oNodes1 , { |x| aadd(::nIDAutorizador ,  val(x:TEXT)  ) } )
Return
