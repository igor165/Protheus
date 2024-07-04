#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/AndamentoProcessual.wsdl?
Gerado em        08/15/16 16:43:52
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _JJPOCQJ ; Return  // "dummy" function - Internal Use 


/* ====================== SERVICE WARNING MESSAGES ======================
Definition for arrayCoordinate as simpletype FOUND AS [xs:string]. This Object COULD NOT HAVE RETURN.
====================================================================== */

/* -------------------------------------------------------------------------------
WSDL Service JURA224 - Web Service de andamentos automáticos
------------------------------------------------------------------------------- */

WSCLIENT JURA224

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD cadastrar
	WSMETHOD remover
	WSMETHOD getAndamentos
	WSMETHOD getAndamentosAgendados
	WSMETHOD getProcesso
	WSMETHOD getAndamentosAtualizados

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cnomeRelacional           AS string
	WSDATA   ctoken                    AS string
	WSDATA   cnProcesso                AS string
	WSDATA   cuf                       AS string
	WSDATA   ccomarca                  AS string
	WSDATA   ctribunal                 AS string
	WSDATA   ncodEscritorio            AS int
	WSDATA   cpartes                   AS string
	WSDATA   creturn                   AS string
	WSDATA   oWSgetAndamentosreturn    AS AndamentoProcessualService_ArrayOfProcesso
	WSDATA   oWSgetAndamentosAgendadosreturn AS AndamentoProcessualService_ArrayOfProcesso
	WSDATA   oWSgetProcessoreturn      AS AndamentoProcessualService_Processo
	WSDATA   cdata                     AS string
	WSDATA   oWSgetAndamentosAtualizadosreturn AS AndamentoProcessualService_ArrayOfProcesso
	WSDATA   lreturn				   AS boolean					//propriedade incluida na mão, o assitente para geração de web service não estava gerando ela.

ENDWSCLIENT

WSMETHOD NEW WSCLIENT JURA224
	::Init()
	If !FindFunction("XMLCHILDEX")
		UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160510 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
	EndIf
Return Self

WSMETHOD INIT WSCLIENT JURA224
	::oWSgetAndamentosreturn := AndamentoProcessualService_ARRAYOFPROCESSO():New()
	::oWSgetAndamentosAgendadosreturn := AndamentoProcessualService_ARRAYOFPROCESSO():New()
	::oWSgetProcessoreturn := AndamentoProcessualService_PROCESSO():New()
	::oWSgetAndamentosAtualizadosreturn := AndamentoProcessualService_ARRAYOFPROCESSO():New()
Return

WSMETHOD RESET WSCLIENT JURA224
	::cnomeRelacional    := NIL 
	::ctoken             := NIL 
	::cnProcesso         := NIL 
	::cuf                := NIL 
	::ccomarca           := NIL 
	::ctribunal          := NIL 
	::ncodEscritorio     := NIL 
	::cpartes            := NIL 
	::creturn            := NIL 
	::oWSgetAndamentosreturn := NIL 
	::oWSgetAndamentosAgendadosreturn := NIL 
	::oWSgetProcessoreturn := NIL 
	::cdata              := NIL 
	::oWSgetAndamentosAtualizadosreturn := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT JURA224
Local oClone := JURA224():New()

	oClone:_URL          := ::_URL 
	oClone:cnomeRelacional := ::cnomeRelacional
	oClone:ctoken        := ::ctoken
	oClone:cnProcesso    := ::cnProcesso
	oClone:cuf           := ::cuf
	oClone:ccomarca      := ::ccomarca
	oClone:ctribunal     := ::ctribunal
	oClone:ncodEscritorio := ::ncodEscritorio
	oClone:cpartes       := ::cpartes
	oClone:creturn       := ::creturn
	oClone:oWSgetAndamentosreturn :=  IIF(::oWSgetAndamentosreturn = NIL , NIL ,::oWSgetAndamentosreturn:Clone() )
	oClone:oWSgetAndamentosAgendadosreturn :=  IIF(::oWSgetAndamentosAgendadosreturn = NIL , NIL ,::oWSgetAndamentosAgendadosreturn:Clone() )
	oClone:oWSgetProcessoreturn :=  IIF(::oWSgetProcessoreturn = NIL , NIL ,::oWSgetProcessoreturn:Clone() )
	oClone:cdata         := ::cdata
	oClone:oWSgetAndamentosAtualizadosreturn :=  IIF(::oWSgetAndamentosAtualizadosreturn = NIL , NIL ,::oWSgetAndamentosAtualizadosreturn:Clone() )

Return oClone

// WSDL Method cadastrar of Service JURA224

WSMETHOD cadastrar WSSEND cnomeRelacional,ctoken,cnProcesso,cuf,ccomarca,ctribunal,ncodEscritorio,cpartes WSRECEIVE creturn WSCLIENT JURA224
Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<q1:cadastrar xmlns:q1="http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php">'
		cSoap += WSSoapValue("nomeRelacional", ::cnomeRelacional, cnomeRelacional , "string", .T. , .T. , 0 , NIL, .F.) 
		cSoap += WSSoapValue("token", ::ctoken, ctoken , "string", .T. , .T. , 0 , NIL, .F.) 
		cSoap += WSSoapValue("nProcesso", ::cnProcesso, cnProcesso , "string", .T. , .T. , 0 , NIL, .F.) 
		cSoap += WSSoapValue("uf", ::cuf, cuf , "string", .T. , .T. , 0 , NIL, .F.) 
		cSoap += WSSoapValue("comarca", ::ccomarca, ccomarca , "string", .T. , .T. , 0 , NIL, .F.) 
		cSoap += WSSoapValue("tribunal", ::ctribunal, ctribunal , "string", .T. , .T. , 0 , NIL, .F.) 
		cSoap += WSSoapValue("codEscritorio", ::ncodEscritorio, ncodEscritorio , "int", .T. , .T. , 0 , NIL, .F.) 
		cSoap += WSSoapValue("partes", ::cpartes, cpartes , "string", .T. , .T. , 0 , NIL, .F.) 
		cSoap += "</q1:cadastrar>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
			"http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php#cadastrar",; 
			"RPCX","http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php",,,; 
			"http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php")

		::Init()
		::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method remover of Service JURA224

WSMETHOD remover WSSEND cnomeRelacional,ctoken,cnProcesso,ncodEscritorio WSRECEIVE lreturn WSCLIENT JURA224
Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<q1:remover xmlns:q1="http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php">'
		cSoap += WSSoapValue("nomeRelacional", ::cnomeRelacional, cnomeRelacional , "string", .T. , .T. , 0 , NIL, .F.) 
		cSoap += WSSoapValue("token", ::ctoken, ctoken , "string", .T. , .T. , 0 , NIL, .F.) 
		cSoap += WSSoapValue("nProcesso", ::cnProcesso, cnProcesso , "string", .T. , .T. , 0 , NIL, .F.) 
		cSoap += WSSoapValue("codEscritorio", ::ncodEscritorio, ncodEscritorio , "int", .T. , .T. , 0 , NIL, .F.) 
		cSoap += "</q1:remover>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
			"http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php#remover",; 
			"RPCX","http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php",,,; 
			"http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php")

		::Init()
		::lreturn            :=  WSAdvValue( oXmlRet,"_RETURN","boolean",NIL,NIL,NIL,"L",NIL,NIL) 

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method getAndamentos of Service JURA224

WSMETHOD getAndamentos WSSEND cnomeRelacional,ctoken WSRECEIVE oWSgetAndamentosreturn WSCLIENT JURA224
Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<q1:getAndamentos xmlns:q1="http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php">'
		cSoap += WSSoapValue("nomeRelacional", ::cnomeRelacional, cnomeRelacional , "string", .T. , .T. , 0 , NIL, .F.) 
		cSoap += WSSoapValue("token", ::ctoken, ctoken , "string", .T. , .T. , 0 , NIL, .F.) 
		cSoap += "</q1:getAndamentos>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
			"http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php#getAndamentos",; 
			"RPCX","http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php",,,; 
			"http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php")

		::Init()
		::oWSgetAndamentosreturn:SoapRecv( WSAdvValue( oXmlRet,"_RETURN","ArrayOfProcesso",NIL,NIL,NIL,"O",NIL,NIL) )

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method getAndamentosAgendados of Service JURA224

WSMETHOD getAndamentosAgendados WSSEND cnomeRelacional,ctoken WSRECEIVE oWSgetAndamentosAgendadosreturn WSCLIENT JURA224
Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<q1:getAndamentosAgendados xmlns:q1="http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php">'
		cSoap += WSSoapValue("nomeRelacional", ::cnomeRelacional, cnomeRelacional , "string", .T. , .T. , 0 , NIL, .F.) 
		cSoap += WSSoapValue("token", ::ctoken, ctoken , "string", .T. , .T. , 0 , NIL, .F.) 
		cSoap += "</q1:getAndamentosAgendados>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
			"http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php#getAndamentosAgendados",; 
			"RPCX","http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php",,,; 
			"http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php")

		::Init()
		::oWSgetAndamentosAgendadosreturn:SoapRecv( WSAdvValue( oXmlRet,"_RETURN","ArrayOfProcesso",NIL,NIL,NIL,"O",NIL,NIL) )

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method getProcesso of Service JURA224

WSMETHOD getProcesso WSSEND cnomeRelacional,ctoken,cnProcesso,ncodEscritorio WSRECEIVE oWSgetProcessoreturn WSCLIENT JURA224
Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<q1:getProcesso xmlns:q1="http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php">'
		cSoap += WSSoapValue("nomeRelacional", ::cnomeRelacional, cnomeRelacional , "string", .T. , .T. , 0 , NIL, .F.) 
		cSoap += WSSoapValue("token", ::ctoken, ctoken , "string", .T. , .T. , 0 , NIL, .F.) 
		cSoap += WSSoapValue("nProcesso", ::cnProcesso, cnProcesso , "string", .T. , .T. , 0 , NIL, .F.) 
		cSoap += WSSoapValue("codEscritorio", ::ncodEscritorio, ncodEscritorio , "int", .T. , .T. , 0 , NIL, .F.) 
		cSoap += "</q1:getProcesso>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
			"http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php#getProcesso",; 
			"RPCX","http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php",,,; 
			"http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php")

		::Init()
		::oWSgetProcessoreturn:SoapRecv( WSAdvValue( oXmlRet,"_RETURN","Processo",NIL,NIL,NIL,"O",NIL,NIL) )

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method getAndamentosAtualizados of Service JURA224

WSMETHOD getAndamentosAtualizados WSSEND cnomeRelacional,ctoken,ncodEscritorio,cdata WSRECEIVE oWSgetAndamentosAtualizadosreturn WSCLIENT JURA224
Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<q1:getAndamentosAtualizados xmlns:q1="http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php">'
		cSoap += WSSoapValue("nomeRelacional", ::cnomeRelacional, cnomeRelacional , "string", .T. , .T. , 0 , NIL, .F.) 
		cSoap += WSSoapValue("token", ::ctoken, ctoken , "string", .T. , .T. , 0 , NIL, .F.) 
		cSoap += WSSoapValue("codEscritorio", ::ncodEscritorio, ncodEscritorio , "int", .T. , .T. , 0 , NIL, .F.) 
		cSoap += WSSoapValue("data", ::cdata, cdata , "string", .T. , .T. , 0 , NIL, .F.) 
		cSoap += "</q1:getAndamentosAtualizados>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
			"http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php#getAndamentosAtualizados",; 
			"RPCX","http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php",,,; 
			"http://legaldata.totvsbpo.com.br:9090/andamento-processual/webservice/soap/20151210/webservice.php")

		::Init()
		::oWSgetAndamentosAtualizadosreturn:SoapRecv( WSAdvValue( oXmlRet,"_RETURN","ArrayOfProcesso",NIL,NIL,NIL,"O",NIL,NIL) )

	END WSMETHOD

	oXmlRet := NIL
Return .T.


// WSDL Data Structure ArrayOfProcesso

WSSTRUCT AndamentoProcessualService_ArrayOfProcesso
	WSDATA   oWSProcesso               AS AndamentoProcessualService_Processo OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AndamentoProcessualService_ArrayOfProcesso
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AndamentoProcessualService_ArrayOfProcesso
	::oWSProcesso          := {} // Array Of  AndamentoProcessualService_PROCESSO():New()
Return

WSMETHOD CLONE WSCLIENT AndamentoProcessualService_ArrayOfProcesso
Local oClone := AndamentoProcessualService_ArrayOfProcesso():NEW()

	oClone:oWSProcesso := NIL

	If ::oWSProcesso <> NIL 
		oClone:oWSProcesso := {}
		aEval( ::oWSProcesso , { |x| aadd( oClone:oWSProcesso , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AndamentoProcessualService_ArrayOfProcesso
Local nRElem1 , nTElem1
Local aNodes1 := WSRPCGetNode(oResponse,.T.)

	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)

	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSProcesso , AndamentoProcessualService_Processo():New() )
			::oWSProcesso[len(::oWSProcesso)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure Processo

WSSTRUCT AndamentoProcessualService_Processo
	WSDATA   ccodProcesso              AS string OPTIONAL
	WSDATA   ncodEscritorio            AS int OPTIONAL
	WSDATA   cnumeroProcesso           AS string OPTIONAL
	WSDATA   cuf                       AS string OPTIONAL
	WSDATA   ccomarca                  AS string OPTIONAL
	WSDATA   cdataAtualizacaoProcesso  AS dateTime OPTIONAL
	WSDATA   creu                      AS string OPTIONAL
	WSDATA   cforum                    AS string OPTIONAL
	WSDATA   cautor                    AS string OPTIONAL
	WSDATA   cvara                     AS string OPTIONAL
	WSDATA   ctribunal                 AS string OPTIONAL
	WSDATA   oWSpartes                 AS AndamentoProcessualService_Array OPTIONAL
	WSDATA   oWSemail                  AS AndamentoProcessualService_Array OPTIONAL
	WSDATA   oWSandamentos             AS AndamentoProcessualService_ArrayOfAndamento OPTIONAL
	WSDATA   cstatus                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AndamentoProcessualService_Processo
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AndamentoProcessualService_Processo
Return

WSMETHOD CLONE WSCLIENT AndamentoProcessualService_Processo
Local oClone := AndamentoProcessualService_Processo():NEW()

	oClone:ccodProcesso         := ::ccodProcesso
	oClone:ncodEscritorio       := ::ncodEscritorio
	oClone:cnumeroProcesso      := ::cnumeroProcesso
	oClone:cuf                  := ::cuf
	oClone:ccomarca             := ::ccomarca
	oClone:cdataAtualizacaoProcesso := ::cdataAtualizacaoProcesso
	oClone:creu                 := ::creu
	oClone:cforum               := ::cforum
	oClone:cautor               := ::cautor
	oClone:cvara                := ::cvara
	oClone:ctribunal            := ::ctribunal
	oClone:oWSpartes            := IIF(::oWSpartes = NIL , NIL , ::oWSpartes:Clone() )
	oClone:oWSemail             := IIF(::oWSemail = NIL , NIL , ::oWSemail:Clone() )
	oClone:oWSandamentos        := IIF(::oWSandamentos = NIL , NIL , ::oWSandamentos:Clone() )
	oClone:cstatus              := ::cstatus
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AndamentoProcessualService_Processo
Local oNode12
Local oNode13
Local oNode14

	::Init()

	If oResponse = NIL ; Return ; Endif 

	::ccodProcesso       :=  WSAdvValue( oResponse,"_CODPROCESSO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ncodEscritorio     :=  WSAdvValue( oResponse,"_CODESCRITORIO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cnumeroProcesso    :=  WSAdvValue( oResponse,"_NUMEROPROCESSO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cuf                :=  WSAdvValue( oResponse,"_UF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccomarca           :=  WSAdvValue( oResponse,"_COMARCA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdataAtualizacaoProcesso :=  WSAdvValue( oResponse,"_DATAATUALIZACAOPROCESSO","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::creu               :=  WSAdvValue( oResponse,"_REU","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cforum             :=  WSAdvValue( oResponse,"_FORUM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cautor             :=  WSAdvValue( oResponse,"_AUTOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cvara              :=  WSAdvValue( oResponse,"_VARA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctribunal          :=  WSAdvValue( oResponse,"_TRIBUNAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode12 :=  WSAdvValue( oResponse,"_PARTES","Array",NIL,NIL,NIL,"O",NIL,NIL) 

	If oNode12 != NIL
		::oWSpartes := AndamentoProcessualService_Array():New()
		::oWSpartes:SoapRecv(oNode12)
	EndIf

	oNode13 :=  WSAdvValue( oResponse,"_EMAIL","Array",NIL,NIL,NIL,"O",NIL,NIL) 

	If oNode13 != NIL
		::oWSemail := AndamentoProcessualService_Array():New()
		::oWSemail:SoapRecv(oNode13)
	EndIf

	oNode14 :=  WSAdvValue( oResponse,"_ANDAMENTOS","ArrayOfAndamento",NIL,NIL,NIL,"O",NIL,NIL) 

	If oNode14 != NIL
		::oWSandamentos := AndamentoProcessualService_ArrayOfAndamento():New()
		::oWSandamentos:SoapRecv(oNode14)
	EndIf

	::cstatus            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure Array

WSSTRUCT AndamentoProcessualService_Array
	WSDATA   oWSarrayAttributes        AS AndamentoProcessualService_arrayAttributes OPTIONAL
	WSDATA   oWScommonAttributes       AS AndamentoProcessualService_commonAttributes OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AndamentoProcessualService_Array
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AndamentoProcessualService_Array
Return

WSMETHOD CLONE WSCLIENT AndamentoProcessualService_Array
	Local oClone := AndamentoProcessualService_Array():NEW()
	oClone:oWSarrayAttributes   := IIF(::oWSarrayAttributes = NIL , NIL , ::oWSarrayAttributes:Clone() )
	oClone:oWScommonAttributes  := IIF(::oWScommonAttributes = NIL , NIL , ::oWScommonAttributes:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AndamentoProcessualService_Array
Local oNode1
Local oNode2

	::Init()

	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ARRAYATTRIBUTES","arrayAttributes",NIL,NIL,NIL,"O",NIL,NIL) 

	If oNode1 != NIL
		::oWSarrayAttributes := AndamentoProcessualService_arrayAttributes():New()
		::oWSarrayAttributes:SoapRecv(oNode1)
	EndIf

	oNode2 :=  WSAdvValue( oResponse,"_COMMONATTRIBUTES","commonAttributes",NIL,NIL,NIL,"O",NIL,NIL) 

	If oNode2 != NIL
		::oWScommonAttributes := AndamentoProcessualService_commonAttributes():New()
		::oWScommonAttributes:SoapRecv(oNode2)
	EndIf
Return

// WSDL Data Structure ArrayOfAndamento

WSSTRUCT AndamentoProcessualService_ArrayOfAndamento
	WSDATA   oWSAndamento              AS AndamentoProcessualService_Andamento OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AndamentoProcessualService_ArrayOfAndamento
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AndamentoProcessualService_ArrayOfAndamento
	::oWSAndamento         := {} // Array Of  AndamentoProcessualService_ANDAMENTO():New()
Return

WSMETHOD CLONE WSCLIENT AndamentoProcessualService_ArrayOfAndamento
Local oClone := AndamentoProcessualService_ArrayOfAndamento():NEW()

	oClone:oWSAndamento := NIL

	If ::oWSAndamento <> NIL 
		oClone:oWSAndamento := {}
		aEval( ::oWSAndamento , { |x| aadd( oClone:oWSAndamento , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AndamentoProcessualService_ArrayOfAndamento
Local nRElem1 , nTElem1
Local aNodes1 := WSRPCGetNode(oResponse,.T.)

	::Init()
	If oResponse = NIL ; Return ; Endif 

	nTElem1 := len(aNodes1)

	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSAndamento , AndamentoProcessualService_Andamento():New() )
  			::oWSAndamento[len(::oWSAndamento)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure arrayAttributes

WSSTRUCT AndamentoProcessualService_arrayAttributes
	WSDATA   oWSarrayType              AS AndamentoProcessualService_arrayType OPTIONAL
	WSDATA   oWSoffset                 AS AndamentoProcessualService_offset OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AndamentoProcessualService_arrayAttributes
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AndamentoProcessualService_arrayAttributes
Return

WSMETHOD CLONE WSCLIENT AndamentoProcessualService_arrayAttributes
Local oClone := AndamentoProcessualService_arrayAttributes():NEW()
	oClone:oWSarrayType         := IIF(::oWSarrayType = NIL , NIL , ::oWSarrayType:Clone() )
	oClone:oWSoffset            := IIF(::oWSoffset = NIL , NIL , ::oWSoffset:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AndamentoProcessualService_arrayAttributes
Local oNode1
Local oNode2

	::Init()
	If oResponse = NIL ; Return ; Endif 

	oNode1 :=  WSAdvValue( oResponse,"_ARRAYTYPE","arrayType",NIL,NIL,NIL,"O",NIL,NIL) 

	If oNode1 != NIL
		::oWSarrayType := AndamentoProcessualService_arrayType():New()
		::oWSarrayType:SoapRecv(oNode1)
	EndIf

	oNode2 :=  WSAdvValue( oResponse,"_OFFSET","offset",NIL,NIL,NIL,"O",NIL,NIL) 

	If oNode2 != NIL
		::oWSoffset := AndamentoProcessualService_offset():New()
		::oWSoffset:SoapRecv(oNode2)
	EndIf
Return

// WSDL Data Structure commonAttributes

WSSTRUCT AndamentoProcessualService_commonAttributes
	WSDATA   oWSid                     AS AndamentoProcessualService_ID OPTIONAL
	WSDATA   oWShref                   AS AndamentoProcessualService_anyURI OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AndamentoProcessualService_commonAttributes
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AndamentoProcessualService_commonAttributes
Return

WSMETHOD CLONE WSCLIENT AndamentoProcessualService_commonAttributes
	Local oClone := AndamentoProcessualService_commonAttributes():NEW()
	oClone:oWSid                := IIF(::oWSid = NIL , NIL , ::oWSid:Clone() )
	oClone:oWShref              := IIF(::oWShref = NIL , NIL , ::oWShref:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AndamentoProcessualService_commonAttributes
Local oNode1
Local oNode2
Local oNode3

	::Init()

	If oResponse = NIL ; Return ; Endif 

	oNode1 :=  WSAdvValue( oResponse,"_ID","ID",NIL,NIL,NIL,"O",NIL,NIL) 

	If oNode1 != NIL
		::oWSid := AndamentoProcessualService_ID():New()
		::oWSid:SoapRecv(oNode1)
	EndIf

	oNode2 :=  WSAdvValue( oResponse,"_HREF","anyURI",NIL,NIL,NIL,"O",NIL,NIL) 

	If oNode2 != NIL
		::oWShref := AndamentoProcessualService_anyURI():New()
		::oWShref:SoapRecv(oNode2)
	EndIf

	oNode3 :=  WSAdvValue( oResponse,"_","",NIL,NIL,NIL,"O",NIL,NIL) 

	If oNode3 != NIL
		::oWS := AndamentoProcessualService_():New()
		::oWS:SoapRecv(oNode3)
	EndIf
Return

// WSDL Data Structure Andamento

WSSTRUCT AndamentoProcessualService_Andamento
	WSDATA   cdata                     AS dateTime OPTIONAL
	WSDATA   ctexto                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AndamentoProcessualService_Andamento
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AndamentoProcessualService_Andamento
Return

WSMETHOD CLONE WSCLIENT AndamentoProcessualService_Andamento
Local oClone := AndamentoProcessualService_Andamento():NEW()
	oClone:cdata                := ::cdata
	oClone:ctexto               := ::ctexto
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AndamentoProcessualService_Andamento

	::Init()

	If oResponse = NIL ; Return ; Endif 

	::cdata              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctexto             :=  WSAdvValue( oResponse,"_TEXTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure arrayCoordinate

WSSTRUCT AndamentoProcessualService_arrayCoordinate
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AndamentoProcessualService_arrayCoordinate
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AndamentoProcessualService_arrayCoordinate
Return

WSMETHOD CLONE WSCLIENT AndamentoProcessualService_arrayCoordinate
Local oClone := AndamentoProcessualService_arrayCoordinate():NEW()
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AndamentoProcessualService_arrayCoordinate
	::Init()
	If oResponse = NIL ; Return ; Endif 
Return

// WSDL Data Structure ID

WSSTRUCT AndamentoProcessualService_ID
	WSDATA   oWScommonAttributes       AS AndamentoProcessualService_commonAttributes OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AndamentoProcessualService_ID
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AndamentoProcessualService_ID
Return

WSMETHOD CLONE WSCLIENT AndamentoProcessualService_ID
	Local oClone := AndamentoProcessualService_ID():NEW()
	oClone:oWScommonAttributes  := IIF(::oWScommonAttributes = NIL , NIL , ::oWScommonAttributes:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AndamentoProcessualService_ID
Local oNode1

	::Init()

	If oResponse = NIL ; Return ; Endif 

	oNode1 :=  WSAdvValue( oResponse,"_COMMONATTRIBUTES","commonAttributes",NIL,NIL,NIL,"O",NIL,NIL) 

	If oNode1 != NIL
		::oWScommonAttributes := AndamentoProcessualService_commonAttributes():New()
		::oWScommonAttributes:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure anyURI

WSSTRUCT AndamentoProcessualService_anyURI
	WSDATA   oWScommonAttributes       AS AndamentoProcessualService_commonAttributes OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AndamentoProcessualService_anyURI
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AndamentoProcessualService_anyURI
Return

WSMETHOD CLONE WSCLIENT AndamentoProcessualService_anyURI
	Local oClone := AndamentoProcessualService_anyURI():NEW()
	oClone:oWScommonAttributes  := IIF(::oWScommonAttributes = NIL , NIL , ::oWScommonAttributes:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AndamentoProcessualService_anyURI
Local oNode1
	::Init()

	If oResponse = NIL ; Return ; Endif 

	oNode1 :=  WSAdvValue( oResponse,"_COMMONATTRIBUTES","commonAttributes",NIL,NIL,NIL,"O",NIL,NIL) 

	If oNode1 != NIL
		::oWScommonAttributes := AndamentoProcessualService_commonAttributes():New()
		::oWScommonAttributes:SoapRecv(oNode1)
	EndIf
Return


