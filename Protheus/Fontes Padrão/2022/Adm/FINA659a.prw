#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://homolog.totvs.reserve.com.br/ReserveXml300/projetos.asmx?WSDL
Gerado em        12/06/13 10:17:30
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

Function FINA659A ; Return 

/* -------------------------------------------------------------------------------
WSDL Service WSProjeto
------------------------------------------------------------------------------- */

WSCLIENT WSProjeto

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
	WSDATA   oWSConsultarProjetosRQ    AS Projeto_ConsultarProjetosRQ
	WSDATA   oWSConsultarResult        AS Projeto_ConsultarProjetosRS
	WSDATA   oWSInserirProjetosRQ      AS Projeto_InserirProjetosRQ
	WSDATA   oWSInserirResult          AS Projeto_InserirProjetosRS
	WSDATA   oWSExcluirProjetosRQ      AS Projeto_ExcluirProjetosRQ
	WSDATA   oWSExcluirResult          AS Projeto_ExcluirProjetosRS

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSProjeto
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20130625] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSProjeto
	::oWSConsultarProjetosRQ := Projeto_CONSULTARPROJETOSRQ():New()
	::oWSConsultarResult := Projeto_CONSULTARPROJETOSRS():New()
	::oWSInserirProjetosRQ := Projeto_INSERIRPROJETOSRQ():New()
	::oWSInserirResult   := Projeto_INSERIRPROJETOSRS():New()
	::oWSExcluirProjetosRQ := Projeto_EXCLUIRPROJETOSRQ():New()
	::oWSExcluirResult   := Projeto_EXCLUIRPROJETOSRS():New()
Return

WSMETHOD RESET WSCLIENT WSProjeto
	::oWSConsultarProjetosRQ := NIL 
	::oWSConsultarResult := NIL 
	::oWSInserirProjetosRQ := NIL 
	::oWSInserirResult   := NIL 
	::oWSExcluirProjetosRQ := NIL 
	::oWSExcluirResult   := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSProjeto
Local oClone := WSProjeto():New()
	oClone:_URL          := ::_URL 
	oClone:oWSConsultarProjetosRQ :=  IIF(::oWSConsultarProjetosRQ = NIL , NIL ,::oWSConsultarProjetosRQ:Clone() )
	oClone:oWSConsultarResult :=  IIF(::oWSConsultarResult = NIL , NIL ,::oWSConsultarResult:Clone() )
	oClone:oWSInserirProjetosRQ :=  IIF(::oWSInserirProjetosRQ = NIL , NIL ,::oWSInserirProjetosRQ:Clone() )
	oClone:oWSInserirResult :=  IIF(::oWSInserirResult = NIL , NIL ,::oWSInserirResult:Clone() )
	oClone:oWSExcluirProjetosRQ :=  IIF(::oWSExcluirProjetosRQ = NIL , NIL ,::oWSExcluirProjetosRQ:Clone() )
	oClone:oWSExcluirResult :=  IIF(::oWSExcluirResult = NIL , NIL ,::oWSExcluirResult:Clone() )
Return oClone

// WSDL Method Consultar of Service WSProjeto

WSMETHOD Consultar WSSEND oWSConsultarProjetosRQ WSRECEIVE oWSConsultarResult WSCLIENT WSProjeto
Local cSoap		:= "" , oXmlRet
Local cUrlAmb	:= SuperGetMv("MV_RESAMB",,"")

cUrlAmb += "/ReserveXml300/projetos.asmx"

BEGIN WSMETHOD

cSoap += '<Consultar xmlns="http://www.reserve.com.br/ReserveXML300/">'
cSoap += WSSoapValue("ConsultarProjetosRQ", ::oWSConsultarProjetosRQ, oWSConsultarProjetosRQ , "ConsultarProjetosRQ", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Consultar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.reserve.com.br/ReserveXML300/Consultar",; 
	"DOCUMENT","http://www.reserve.com.br/ReserveXML300/",,,; 
	cUrlAmb)

::Init()
::oWSConsultarResult:SoapRecv( WSAdvValue( oXmlRet,"_CONSULTARRESPONSE:_CONSULTARRESULT","ConsultarProjetosRS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL

Return .T.

// WSDL Method Inserir of Service WSProjeto

WSMETHOD Inserir WSSEND oWSInserirProjetosRQ WSRECEIVE oWSInserirResult WSCLIENT WSProjeto
Local cSoap := "" , oXmlRet
Local cUrlAmb	:= SuperGetMv("MV_RESAMB",,"")

cUrlAmb += "/ReserveXml300/projetos.asmx"

BEGIN WSMETHOD

cSoap += '<Inserir xmlns="http://www.reserve.com.br/ReserveXML300/">'
cSoap += WSSoapValue("InserirProjetosRQ", ::oWSInserirProjetosRQ, oWSInserirProjetosRQ , "InserirProjetosRQ", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Inserir>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.reserve.com.br/ReserveXML300/Inserir",; 
	"DOCUMENT","http://www.reserve.com.br/ReserveXML300/",,,; 
	cUrlAmb)

::Init()
::oWSInserirResult:SoapRecv( WSAdvValue( oXmlRet,"_INSERIRRESPONSE:_INSERIRRESULT","InserirProjetosRS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Excluir of Service WSProjeto

WSMETHOD Excluir WSSEND oWSExcluirProjetosRQ WSRECEIVE oWSExcluirResult WSCLIENT WSProjeto
Local cSoap		:= "" , oXmlRet
Local cUrlAmb	:= SuperGetMv("MV_RESAMB",,"")

cUrlAmb += "/ReserveXml300/projetos.asmx"

BEGIN WSMETHOD

cSoap += '<Excluir xmlns="http://www.reserve.com.br/ReserveXML300/">'
cSoap += WSSoapValue("ExcluirProjetosRQ", ::oWSExcluirProjetosRQ, oWSExcluirProjetosRQ , "ExcluirProjetosRQ", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Excluir>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.reserve.com.br/ReserveXML300/Excluir",; 
	"DOCUMENT","http://www.reserve.com.br/ReserveXML300/",,,; 
	cUrlAmb)

::Init()
::oWSExcluirResult:SoapRecv( WSAdvValue( oXmlRet,"_EXCLUIRRESPONSE:_EXCLUIRRESULT","ExcluirProjetosRS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ConsultarProjetosRQ

WSSTRUCT Projeto_ConsultarProjetosRQ
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSCODBKOs                AS Projeto_ArrayOfString OPTIONAL
	WSDATA   oWSGrupos                 AS Projeto_ArrayOfString1 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Projeto_ConsultarProjetosRQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Projeto_ConsultarProjetosRQ
Return

WSMETHOD CLONE WSCLIENT Projeto_ConsultarProjetosRQ
	Local oClone := Projeto_ConsultarProjetosRQ():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSCODBKOs           := IIF(::oWSCODBKOs = NIL , NIL , ::oWSCODBKOs:Clone() )
	oClone:oWSGrupos            := IIF(::oWSGrupos = NIL , NIL , ::oWSGrupos:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Projeto_ConsultarProjetosRQ
	Local cSoap := ""
	cSoap += WSSoapValue("Sessao", ::cSessao, ::cSessao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CODBKOs", ::oWSCODBKOs, ::oWSCODBKOs , "ArrayOfString", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Grupos", ::oWSGrupos, ::oWSGrupos , "ArrayOfString1", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ConsultarProjetosRS

WSSTRUCT Projeto_ConsultarProjetosRS
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSProjetos               AS Projeto_ArrayOfProjeto OPTIONAL
	WSDATA   oWSErros                  AS Projeto_ArrayOfErro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Projeto_ConsultarProjetosRS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Projeto_ConsultarProjetosRS
Return

WSMETHOD CLONE WSCLIENT Projeto_ConsultarProjetosRS
	Local oClone := Projeto_ConsultarProjetosRS():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSProjetos          := IIF(::oWSProjetos = NIL , NIL , ::oWSProjetos:Clone() )
	oClone:oWSErros             := IIF(::oWSErros = NIL , NIL , ::oWSErros:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Projeto_ConsultarProjetosRS
	Local oNode2
	Local oNode3
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSessao            :=  WSAdvValue( oResponse,"_SESSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_PROJETOS","ArrayOfProjeto",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSProjetos := Projeto_ArrayOfProjeto():New()
		::oWSProjetos:SoapRecv(oNode2)
	EndIf
	oNode3 :=  WSAdvValue( oResponse,"_ERROS","ArrayOfErro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode3 != NIL
		::oWSErros := Projeto_ArrayOfErro():New()
		::oWSErros:SoapRecv(oNode3)
	EndIf
Return

// WSDL Data Structure InserirProjetosRQ

WSSTRUCT Projeto_InserirProjetosRQ
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSProjetos               AS Projeto_ArrayOfProjeto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Projeto_InserirProjetosRQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Projeto_InserirProjetosRQ
Return

WSMETHOD CLONE WSCLIENT Projeto_InserirProjetosRQ
	Local oClone := Projeto_InserirProjetosRQ():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSProjetos          := IIF(::oWSProjetos = NIL , NIL , ::oWSProjetos:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Projeto_InserirProjetosRQ
	Local cSoap := ""
	cSoap += WSSoapValue("Sessao", ::cSessao, ::cSessao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Projetos", ::oWSProjetos, ::oWSProjetos , "ArrayOfProjeto", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure InserirProjetosRS

WSSTRUCT Projeto_InserirProjetosRS
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSErros                  AS Projeto_ArrayOfErro OPTIONAL
	WSDATA   oWSProjetos               AS Projeto_ArrayOfProjeto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Projeto_InserirProjetosRS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Projeto_InserirProjetosRS
Return

WSMETHOD CLONE WSCLIENT Projeto_InserirProjetosRS
	Local oClone := Projeto_InserirProjetosRS():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSErros             := IIF(::oWSErros = NIL , NIL , ::oWSErros:Clone() )
	oClone:oWSProjetos          := IIF(::oWSProjetos = NIL , NIL , ::oWSProjetos:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Projeto_InserirProjetosRS
	Local oNode2
	Local oNode3
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSessao            :=  WSAdvValue( oResponse,"_SESSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_ERROS","ArrayOfErro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSErros := Projeto_ArrayOfErro():New()
		::oWSErros:SoapRecv(oNode2)
	EndIf
	oNode3 :=  WSAdvValue( oResponse,"_PROJETOS","ArrayOfProjeto",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode3 != NIL
		::oWSProjetos := Projeto_ArrayOfProjeto():New()
		::oWSProjetos:SoapRecv(oNode3)
	EndIf
Return

// WSDL Data Structure ExcluirProjetosRQ

WSSTRUCT Projeto_ExcluirProjetosRQ
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSCODBKOs                AS Projeto_ArrayOfString OPTIONAL
	WSDATA   cGrupo                    AS string OPTIONAL
	WSDATA   oWSProjetos               AS Projeto_ArrayOfString2 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Projeto_ExcluirProjetosRQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Projeto_ExcluirProjetosRQ
Return

WSMETHOD CLONE WSCLIENT Projeto_ExcluirProjetosRQ
	Local oClone := Projeto_ExcluirProjetosRQ():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSCODBKOs           := IIF(::oWSCODBKOs = NIL , NIL , ::oWSCODBKOs:Clone() )
	oClone:cGrupo               := ::cGrupo
	oClone:oWSProjetos          := IIF(::oWSProjetos = NIL , NIL , ::oWSProjetos:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Projeto_ExcluirProjetosRQ
	Local cSoap := ""
	cSoap += WSSoapValue("Sessao", ::cSessao, ::cSessao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CODBKOs", ::oWSCODBKOs, ::oWSCODBKOs , "ArrayOfString", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Grupo", ::cGrupo, ::cGrupo , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Projetos", ::oWSProjetos, ::oWSProjetos , "ArrayOfString2", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ExcluirProjetosRS

WSSTRUCT Projeto_ExcluirProjetosRS
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSErros                  AS Projeto_ArrayOfErro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Projeto_ExcluirProjetosRS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Projeto_ExcluirProjetosRS
Return

WSMETHOD CLONE WSCLIENT Projeto_ExcluirProjetosRS
	Local oClone := Projeto_ExcluirProjetosRS():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSErros             := IIF(::oWSErros = NIL , NIL , ::oWSErros:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Projeto_ExcluirProjetosRS
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSessao            :=  WSAdvValue( oResponse,"_SESSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_ERROS","ArrayOfErro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSErros := Projeto_ArrayOfErro():New()
		::oWSErros:SoapRecv(oNode2)
	EndIf
Return

// WSDL Data Structure ArrayOfString

WSSTRUCT Projeto_ArrayOfString
	WSDATA   cCODBKO                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Projeto_ArrayOfString
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Projeto_ArrayOfString
	::cCODBKO              := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT Projeto_ArrayOfString
	Local oClone := Projeto_ArrayOfString():NEW()
	oClone:cCODBKO              := IIf(::cCODBKO <> NIL , aClone(::cCODBKO) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Projeto_ArrayOfString
	Local cSoap := ""
	aEval( ::cCODBKO , {|x| cSoap := cSoap  +  WSSoapValue("CODBKO", x , x , "string", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfString1

WSSTRUCT Projeto_ArrayOfString1
	WSDATA   cGrupo                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Projeto_ArrayOfString1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Projeto_ArrayOfString1
	::cGrupo               := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT Projeto_ArrayOfString1
	Local oClone := Projeto_ArrayOfString1():NEW()
	oClone:cGrupo               := IIf(::cGrupo <> NIL , aClone(::cGrupo) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Projeto_ArrayOfString1
	Local cSoap := ""
	aEval( ::cGrupo , {|x| cSoap := cSoap  +  WSSoapValue("Grupo", x , x , "string", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfProjeto

WSSTRUCT Projeto_ArrayOfProjeto
	WSDATA   oWSProjeto                AS Projeto_Projeto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Projeto_ArrayOfProjeto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Projeto_ArrayOfProjeto
	::oWSProjeto           := {} // Array Of  Projeto_PROJETO():New()
Return

WSMETHOD CLONE WSCLIENT Projeto_ArrayOfProjeto
	Local oClone := Projeto_ArrayOfProjeto():NEW()
	oClone:oWSProjeto := NIL
	If ::oWSProjeto <> NIL 
		oClone:oWSProjeto := {}
		aEval( ::oWSProjeto , { |x| aadd( oClone:oWSProjeto , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Projeto_ArrayOfProjeto
	Local cSoap := ""
	aEval( ::oWSProjeto , {|x| cSoap := cSoap  +  WSSoapValue("Projeto", x , x , "Projeto", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Projeto_ArrayOfProjeto
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_PROJETO","Projeto",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSProjeto , Projeto_Projeto():New() )
			::oWSProjeto[len(::oWSProjeto)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfErro

WSSTRUCT Projeto_ArrayOfErro
	WSDATA   oWSErro                   AS Projeto_Erro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Projeto_ArrayOfErro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Projeto_ArrayOfErro
	::oWSErro              := {} // Array Of  Projeto_ERRO():New()
Return

WSMETHOD CLONE WSCLIENT Projeto_ArrayOfErro
	Local oClone := Projeto_ArrayOfErro():NEW()
	oClone:oWSErro := NIL
	If ::oWSErro <> NIL 
		oClone:oWSErro := {}
		aEval( ::oWSErro , { |x| aadd( oClone:oWSErro , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Projeto_ArrayOfErro
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ERRO","Erro",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSErro , Projeto_Erro():New() )
			::oWSErro[len(::oWSErro)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfString2

WSSTRUCT Projeto_ArrayOfString2
	WSDATA   cProjeto                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Projeto_ArrayOfString2
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Projeto_ArrayOfString2
	::cProjeto             := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT Projeto_ArrayOfString2
	Local oClone := Projeto_ArrayOfString2():NEW()
	oClone:cProjeto             := IIf(::cProjeto <> NIL , aClone(::cProjeto) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Projeto_ArrayOfString2
	Local cSoap := ""
	aEval( ::cProjeto , {|x| cSoap := cSoap  +  WSSoapValue("Projeto", x , x , "string", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure Projeto

WSSTRUCT Projeto_Projeto
	WSDATA   cCODBKO                   AS string OPTIONAL
	WSDATA   cProjeto                  AS string OPTIONAL
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   nIDReserve                AS int
	WSDATA   cGrupo                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Projeto_Projeto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Projeto_Projeto
Return

WSMETHOD CLONE WSCLIENT Projeto_Projeto
	Local oClone := Projeto_Projeto():NEW()
	oClone:cCODBKO              := ::cCODBKO
	oClone:cProjeto             := ::cProjeto
	oClone:cDescricao           := ::cDescricao
	oClone:nIDReserve           := ::nIDReserve
	oClone:cGrupo               := ::cGrupo
Return oClone

WSMETHOD SOAPSEND WSCLIENT Projeto_Projeto
	Local cSoap := ""
	cSoap += WSSoapValue("CODBKO", ::cCODBKO, ::cCODBKO , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Projeto", ::cProjeto, ::cProjeto , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Descricao", ::cDescricao, ::cDescricao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("IDReserve", ::nIDReserve, ::nIDReserve , "int", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Grupo", ::cGrupo, ::cGrupo , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Projeto_Projeto
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODBKO            :=  WSAdvValue( oResponse,"_CODBKO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cProjeto           :=  WSAdvValue( oResponse,"_PROJETO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nIDReserve         :=  WSAdvValue( oResponse,"_IDRESERVE","int",NIL,"Property nIDReserve as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cGrupo             :=  WSAdvValue( oResponse,"_GRUPO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure Erro

WSSTRUCT Projeto_Erro
	WSDATA   cCodErro                  AS string OPTIONAL
	WSDATA   cMensagem                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Projeto_Erro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Projeto_Erro
Return

WSMETHOD CLONE WSCLIENT Projeto_Erro
	Local oClone := Projeto_Erro():NEW()
	oClone:cCodErro             := ::cCodErro
	oClone:cMensagem            := ::cMensagem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Projeto_Erro
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodErro           :=  WSAdvValue( oResponse,"_CODERRO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


