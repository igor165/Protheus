#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://172.16.32.243:84/WSFINA850.apw?WSDL
Generado en        10/24/12 16:43:31
Observaciones      Codigo Fuente generado por ADVPL WSDL Client 1.120703
                 Modificaciones en este archivo pueden causar funcionamiento incorrecto
                 y se perderan en caso de que se genere nuevamente el codigo fuente.
=============================================================================== */

User Function _VWQAMBL ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSFINA850
------------------------------------------------------------------------------- */

WSCLIENT WSWSFINA850

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD BLOQUEAR
	WSMETHOD PESQUISA

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSSBLOQUEIA              AS WSFINA850_STBLOQUEIA
	WSDATA   oWSBLOQUEARRESULT         AS WSFINA850_STRET
	WSDATA   oWSSPESQ                  AS WSFINA850_STPESQ
	WSDATA   oWSPESQUISARESULT         AS WSFINA850_STARETPESQ

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSSTBLOQUEIA             AS WSFINA850_STBLOQUEIA
	WSDATA   oWSSTPESQ                 AS WSFINA850_STPESQ

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSFINA850
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.120420A-20120529] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSFINA850
	::oWSSBLOQUEIA       := WSFINA850_STBLOQUEIA():New()
	::oWSBLOQUEARRESULT  := WSFINA850_STRET():New()
	::oWSSPESQ           := WSFINA850_STPESQ():New()
	::oWSPESQUISARESULT  := WSFINA850_STARETPESQ():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSTBLOQUEIA      := ::oWSSBLOQUEIA
	::oWSSTPESQ          := ::oWSSPESQ
Return

WSMETHOD RESET WSCLIENT WSWSFINA850
	::oWSSBLOQUEIA       := NIL 
	::oWSBLOQUEARRESULT  := NIL 
	::oWSSPESQ           := NIL 
	::oWSPESQUISARESULT  := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSTBLOQUEIA      := NIL
	::oWSSTPESQ          := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSFINA850
Local oClone := WSWSFINA850():New()
	oClone:_URL          := ::_URL 
	oClone:oWSSBLOQUEIA  :=  IIF(::oWSSBLOQUEIA = NIL , NIL ,::oWSSBLOQUEIA:Clone() )
	oClone:oWSBLOQUEARRESULT :=  IIF(::oWSBLOQUEARRESULT = NIL , NIL ,::oWSBLOQUEARRESULT:Clone() )
	oClone:oWSSPESQ      :=  IIF(::oWSSPESQ = NIL , NIL ,::oWSSPESQ:Clone() )
	oClone:oWSPESQUISARESULT :=  IIF(::oWSPESQUISARESULT = NIL , NIL ,::oWSPESQUISARESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSSTBLOQUEIA := oClone:oWSSBLOQUEIA
	oClone:oWSSTPESQ     := oClone:oWSSPESQ
Return oClone

// WSDL Method BLOQUEAR of Service WSWSFINA850

WSMETHOD BLOQUEAR WSSEND oWSSBLOQUEIA WSRECEIVE oWSBLOQUEARRESULT WSCLIENT WSWSFINA850
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BLOQUEAR xmlns="http://www.totvs.com.br/rm/">'
cSoap += WSSoapValue("SBLOQUEIA", ::oWSSBLOQUEIA, oWSSBLOQUEIA , "STBLOQUEIA", .T. , .F., 0 , NIL, .F.) 
cSoap += "</BLOQUEAR>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.totvs.com.br/rm/BLOQUEAR",; 
	"DOCUMENT","http://www.totvs.com.br/rm/",,"1.031217",; 
	"http://172.16.32.243:84/WSFINA850.apw")

::Init()
::oWSBLOQUEARRESULT:SoapRecv( WSAdvValue( oXmlRet,"_BLOQUEARRESPONSE:_BLOQUEARRESULT","STRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PESQUISA of Service WSWSFINA850

WSMETHOD PESQUISA WSSEND oWSSPESQ WSRECEIVE oWSPESQUISARESULT WSCLIENT WSWSFINA850
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PESQUISA xmlns="http://www.totvs.com.br/rm/">'
cSoap += WSSoapValue("SPESQ", ::oWSSPESQ, oWSSPESQ , "STPESQ", .T. , .F., 0 , NIL, .F.) 
cSoap += "</PESQUISA>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.totvs.com.br/rm/PESQUISA",; 
	"DOCUMENT","http://www.totvs.com.br/rm/",,"1.031217",; 
	"http://172.16.32.243:84/WSFINA850.apw")

::Init()
::oWSPESQUISARESULT:SoapRecv( WSAdvValue( oXmlRet,"_PESQUISARESPONSE:_PESQUISARESULT","STARETPESQ",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure STBLOQUEIA

WSSTRUCT WSFINA850_STBLOQUEIA
	WSDATA   cC_CODADT                 AS string
	WSDATA   cC_EDT                    AS string
	WSDATA   cC_EMPRE                  AS string
	WSDATA   cC_FILI                   AS string
	WSDATA   cC_FORNECE                AS string
	WSDATA   cC_LOJA                   AS string
	WSDATA   cC_PARCELA                AS string
	WSDATA   cC_PREFIXO                AS string
	WSDATA   cC_PROJETO                AS string
	WSDATA   cC_REVISA                 AS string
	WSDATA   cC_TAREFA                 AS string
	WSDATA   cC_TIPO                   AS string
	WSDATA   cC_TIPOADT                AS string
	WSDATA   nN_LIBERADO               AS integer
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSFINA850_STBLOQUEIA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSFINA850_STBLOQUEIA
Return

WSMETHOD CLONE WSCLIENT WSFINA850_STBLOQUEIA
	Local oClone := WSFINA850_STBLOQUEIA():NEW()
	oClone:cC_CODADT            := ::cC_CODADT
	oClone:cC_EDT               := ::cC_EDT
	oClone:cC_EMPRE             := ::cC_EMPRE
	oClone:cC_FILI              := ::cC_FILI
	oClone:cC_FORNECE           := ::cC_FORNECE
	oClone:cC_LOJA              := ::cC_LOJA
	oClone:cC_PARCELA           := ::cC_PARCELA
	oClone:cC_PREFIXO           := ::cC_PREFIXO
	oClone:cC_PROJETO           := ::cC_PROJETO
	oClone:cC_REVISA            := ::cC_REVISA
	oClone:cC_TAREFA            := ::cC_TAREFA
	oClone:cC_TIPO              := ::cC_TIPO
	oClone:cC_TIPOADT           := ::cC_TIPOADT
	oClone:nN_LIBERADO          := ::nN_LIBERADO
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSFINA850_STBLOQUEIA
	Local cSoap := ""
	cSoap += WSSoapValue("C_CODADT", ::cC_CODADT, ::cC_CODADT , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C_EDT", ::cC_EDT, ::cC_EDT , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C_EMPRE", ::cC_EMPRE, ::cC_EMPRE , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C_FILI", ::cC_FILI, ::cC_FILI , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C_FORNECE", ::cC_FORNECE, ::cC_FORNECE , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C_LOJA", ::cC_LOJA, ::cC_LOJA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C_PARCELA", ::cC_PARCELA, ::cC_PARCELA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C_PREFIXO", ::cC_PREFIXO, ::cC_PREFIXO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C_PROJETO", ::cC_PROJETO, ::cC_PROJETO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C_REVISA", ::cC_REVISA, ::cC_REVISA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C_TAREFA", ::cC_TAREFA, ::cC_TAREFA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C_TIPO", ::cC_TIPO, ::cC_TIPO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C_TIPOADT", ::cC_TIPOADT, ::cC_TIPOADT , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("N_LIBERADO", ::nN_LIBERADO, ::nN_LIBERADO , "integer", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure STRET

WSSTRUCT WSFINA850_STRET
	WSDATA   cC_RET                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSFINA850_STRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSFINA850_STRET
Return

WSMETHOD CLONE WSCLIENT WSFINA850_STRET
	Local oClone := WSFINA850_STRET():NEW()
	oClone:cC_RET               := ::cC_RET
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSFINA850_STRET
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cC_RET             :=  WSAdvValue( oResponse,"_C_RET","string",NIL,"Property cC_RET as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure STPESQ

WSSTRUCT WSFINA850_STPESQ
	WSDATA   cC_CODCLI                 AS string
	WSDATA   cC_EMPRE                  AS string
	WSDATA   cC_FILI                   AS string
	WSDATA   cC_LOJA                   AS string
	WSDATA   cC_MOED                   AS string
	WSDATA   cC_PROJET                 AS string
	WSDATA   cC_TIPOADT                AS string
	WSDATA   cC_TIPOCLI                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSFINA850_STPESQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSFINA850_STPESQ
Return

WSMETHOD CLONE WSCLIENT WSFINA850_STPESQ
	Local oClone := WSFINA850_STPESQ():NEW()
	oClone:cC_CODCLI            := ::cC_CODCLI
	oClone:cC_EMPRE             := ::cC_EMPRE
	oClone:cC_FILI              := ::cC_FILI
	oClone:cC_LOJA              := ::cC_LOJA
	oClone:cC_MOED              := ::cC_MOED
	oClone:cC_PROJET            := ::cC_PROJET
	oClone:cC_TIPOADT           := ::cC_TIPOADT
	oClone:cC_TIPOCLI           := ::cC_TIPOCLI
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSFINA850_STPESQ
	Local cSoap := ""
	cSoap += WSSoapValue("C_CODCLI", ::cC_CODCLI, ::cC_CODCLI , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C_EMPRE", ::cC_EMPRE, ::cC_EMPRE , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C_FILI", ::cC_FILI, ::cC_FILI , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C_LOJA", ::cC_LOJA, ::cC_LOJA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C_MOED", ::cC_MOED, ::cC_MOED , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C_PROJET", ::cC_PROJET, ::cC_PROJET , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C_TIPOADT", ::cC_TIPOADT, ::cC_TIPOADT , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C_TIPOCLI", ::cC_TIPOCLI, ::cC_TIPOCLI , "string", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure STARETPESQ

WSSTRUCT WSFINA850_STARETPESQ
	WSDATA   oWSSARETPESQ              AS WSFINA850_ARRAYOFSTRETPESQ
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSFINA850_STARETPESQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSFINA850_STARETPESQ
Return

WSMETHOD CLONE WSCLIENT WSFINA850_STARETPESQ
	Local oClone := WSFINA850_STARETPESQ():NEW()
	oClone:oWSSARETPESQ         := IIF(::oWSSARETPESQ = NIL , NIL , ::oWSSARETPESQ:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSFINA850_STARETPESQ
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_SARETPESQ","ARRAYOFSTRETPESQ",NIL,"Property oWSSARETPESQ as s0:ARRAYOFSTRETPESQ on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSSARETPESQ := WSFINA850_ARRAYOFSTRETPESQ():New()
		::oWSSARETPESQ:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ARRAYOFSTRETPESQ

WSSTRUCT WSFINA850_ARRAYOFSTRETPESQ
	WSDATA   oWSSTRETPESQ              AS WSFINA850_STRETPESQ OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSFINA850_ARRAYOFSTRETPESQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSFINA850_ARRAYOFSTRETPESQ
	::oWSSTRETPESQ         := {} // Array Of  WSFINA850_STRETPESQ():New()
Return

WSMETHOD CLONE WSCLIENT WSFINA850_ARRAYOFSTRETPESQ
	Local oClone := WSFINA850_ARRAYOFSTRETPESQ():NEW()
	oClone:oWSSTRETPESQ := NIL
	If ::oWSSTRETPESQ <> NIL 
		oClone:oWSSTRETPESQ := {}
		aEval( ::oWSSTRETPESQ , { |x| aadd( oClone:oWSSTRETPESQ , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSFINA850_ARRAYOFSTRETPESQ
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STRETPESQ","STRETPESQ",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSTRETPESQ , WSFINA850_STRETPESQ():New() )
			::oWSSTRETPESQ[len(::oWSSTRETPESQ)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure STRETPESQ

WSSTRUCT WSFINA850_STRETPESQ
	WSDATA   cC_CCUSTO                 AS string
	WSDATA   cC_CODADT                 AS string
	WSDATA   cC_CODCLI                 AS string
	WSDATA   cC_DESCR                  AS string
	WSDATA   cC_EDT                    AS string
	WSDATA   cC_EMPRE                  AS string
	WSDATA   cC_FILI                   AS string
	WSDATA   cC_LOJA                   AS string
	WSDATA   cC_MOED                   AS string
	WSDATA   cC_PARCELA                AS string
	WSDATA   cC_PREFIXO                AS string
	WSDATA   cC_PROJET                 AS string
	WSDATA   cC_REVISA                 AS string
	WSDATA   cC_TAREFA                 AS string
	WSDATA   cC_TIPO                   AS string
	WSDATA   cC_TIPOADT                AS string
	WSDATA   cC_TIPOCLI                AS string
	WSDATA   dD_INCL                   AS date
	WSDATA   dD_VENC                   AS date
	WSDATA   nN_LIBERADO               AS integer
	WSDATA   nN_VALOR                  AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSFINA850_STRETPESQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSFINA850_STRETPESQ
Return

WSMETHOD CLONE WSCLIENT WSFINA850_STRETPESQ
	Local oClone := WSFINA850_STRETPESQ():NEW()
	oClone:cC_CCUSTO            := ::cC_CCUSTO
	oClone:cC_CODADT            := ::cC_CODADT
	oClone:cC_CODCLI            := ::cC_CODCLI
	oClone:cC_DESCR             := ::cC_DESCR
	oClone:cC_EDT               := ::cC_EDT
	oClone:cC_EMPRE             := ::cC_EMPRE
	oClone:cC_FILI              := ::cC_FILI
	oClone:cC_LOJA              := ::cC_LOJA
	oClone:cC_MOED              := ::cC_MOED
	oClone:cC_PARCELA           := ::cC_PARCELA
	oClone:cC_PREFIXO           := ::cC_PREFIXO
	oClone:cC_PROJET            := ::cC_PROJET
	oClone:cC_REVISA            := ::cC_REVISA
	oClone:cC_TAREFA            := ::cC_TAREFA
	oClone:cC_TIPO              := ::cC_TIPO
	oClone:cC_TIPOADT           := ::cC_TIPOADT
	oClone:cC_TIPOCLI           := ::cC_TIPOCLI
	oClone:dD_INCL              := ::dD_INCL
	oClone:dD_VENC              := ::dD_VENC
	oClone:nN_LIBERADO          := ::nN_LIBERADO
	oClone:nN_VALOR             := ::nN_VALOR
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSFINA850_STRETPESQ
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cC_CCUSTO          :=  WSAdvValue( oResponse,"_C_CCUSTO","string",NIL,"Property cC_CCUSTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cC_CODADT          :=  WSAdvValue( oResponse,"_C_CODADT","string",NIL,"Property cC_CODADT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cC_CODCLI          :=  WSAdvValue( oResponse,"_C_CODCLI","string",NIL,"Property cC_CODCLI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cC_DESCR           :=  WSAdvValue( oResponse,"_C_DESCR","string",NIL,"Property cC_DESCR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cC_EDT             :=  WSAdvValue( oResponse,"_C_EDT","string",NIL,"Property cC_EDT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cC_EMPRE           :=  WSAdvValue( oResponse,"_C_EMPRE","string",NIL,"Property cC_EMPRE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cC_FILI            :=  WSAdvValue( oResponse,"_C_FILI","string",NIL,"Property cC_FILI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cC_LOJA            :=  WSAdvValue( oResponse,"_C_LOJA","string",NIL,"Property cC_LOJA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cC_MOED            :=  WSAdvValue( oResponse,"_C_MOED","string",NIL,"Property cC_MOED as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cC_PARCELA         :=  WSAdvValue( oResponse,"_C_PARCELA","string",NIL,"Property cC_PARCELA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cC_PREFIXO         :=  WSAdvValue( oResponse,"_C_PREFIXO","string",NIL,"Property cC_PREFIXO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cC_PROJET          :=  WSAdvValue( oResponse,"_C_PROJET","string",NIL,"Property cC_PROJET as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cC_REVISA          :=  WSAdvValue( oResponse,"_C_REVISA","string",NIL,"Property cC_REVISA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cC_TAREFA          :=  WSAdvValue( oResponse,"_C_TAREFA","string",NIL,"Property cC_TAREFA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cC_TIPO            :=  WSAdvValue( oResponse,"_C_TIPO","string",NIL,"Property cC_TIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cC_TIPOADT         :=  WSAdvValue( oResponse,"_C_TIPOADT","string",NIL,"Property cC_TIPOADT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cC_TIPOCLI         :=  WSAdvValue( oResponse,"_C_TIPOCLI","string",NIL,"Property cC_TIPOCLI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::dD_INCL            :=  WSAdvValue( oResponse,"_D_INCL","date",NIL,"Property dD_INCL as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::dD_VENC            :=  WSAdvValue( oResponse,"_D_VENC","date",NIL,"Property dD_VENC as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::nN_LIBERADO        :=  WSAdvValue( oResponse,"_N_LIBERADO","integer",NIL,"Property nN_LIBERADO as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nN_VALOR           :=  WSAdvValue( oResponse,"_N_VALOR","float",NIL,"Property nN_VALOR as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return


