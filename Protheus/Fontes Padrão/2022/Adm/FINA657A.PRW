#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://homolog.totvs.reserve.com.br/ReserveXml300/usuarios.asmx?WSDL
Gerado em        12/06/13 10:39:07
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

Function FINA657A ; Return  // "dummy" function - Usada para permitir que o fonte fique visivel para gerar o patch com base nos fontes. 

/* -------------------------------------------------------------------------------
WSDL Service WSUsuarios
------------------------------------------------------------------------------- */

WSCLIENT WSUsuarios

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Consultar
	WSMETHOD AtualizarAutorizador
	WSMETHOD Atualizar
	WSMETHOD Excluir

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSConsultarRQ            AS Usuarios_ConsultarUsuariosRQ
	WSDATA   oWSConsultarResult        AS Usuarios_ConsultarUsuariosRS
	WSDATA   oWSAtualizarAutorizadorRQ AS Usuarios_AtualizarAutorizadorRQ
	WSDATA   oWSAtualizarAutorizadorResult AS Usuarios_AtualizarAutorizadorRS
	WSDATA   oWSAtualizarRQ            AS Usuarios_AtualizarUsuariosRQ
	WSDATA   oWSAtualizarResult        AS Usuarios_AtualizarUsuariosRS
	WSDATA   oWSExcluirRQ              AS Usuarios_ExcluirUsuariosRQ
	WSDATA   oWSExcluirResult          AS Usuarios_ExcluirUsuariosRS

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSUsuarios
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20130625] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
If val(right(GetWSCVer(),8)) < 1.040504
	UserException("O Código-Fonte Client atual requer a versão de Lib para WebServices igual ou superior a ADVPL WSDL Client 1.040504. Atualize o repositório ou gere o Código-Fonte novamente utilizando o repositório atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSUsuarios
	::oWSConsultarRQ     := Usuarios_CONSULTARUSUARIOSRQ():New()
	::oWSConsultarResult := Usuarios_CONSULTARUSUARIOSRS():New()
	::oWSAtualizarAutorizadorRQ := Usuarios_ATUALIZARAUTORIZADORRQ():New()
	::oWSAtualizarAutorizadorResult := Usuarios_ATUALIZARAUTORIZADORRS():New()
	::oWSAtualizarRQ     := Usuarios_ATUALIZARUSUARIOSRQ():New()
	::oWSAtualizarResult := Usuarios_ATUALIZARUSUARIOSRS():New()
	::oWSExcluirRQ       := Usuarios_EXCLUIRUSUARIOSRQ():New()
	::oWSExcluirResult   := Usuarios_EXCLUIRUSUARIOSRS():New()
Return

WSMETHOD RESET WSCLIENT WSUsuarios
	::oWSConsultarRQ     := NIL 
	::oWSConsultarResult := NIL 
	::oWSAtualizarAutorizadorRQ := NIL 
	::oWSAtualizarAutorizadorResult := NIL 
	::oWSAtualizarRQ     := NIL 
	::oWSAtualizarResult := NIL 
	::oWSExcluirRQ       := NIL 
	::oWSExcluirResult   := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSUsuarios
Local oClone := WSUsuarios():New()
	oClone:_URL          := ::_URL 
	oClone:oWSConsultarRQ :=  IIF(::oWSConsultarRQ = NIL , NIL ,::oWSConsultarRQ:Clone() )
	oClone:oWSConsultarResult :=  IIF(::oWSConsultarResult = NIL , NIL ,::oWSConsultarResult:Clone() )
	oClone:oWSAtualizarAutorizadorRQ :=  IIF(::oWSAtualizarAutorizadorRQ = NIL , NIL ,::oWSAtualizarAutorizadorRQ:Clone() )
	oClone:oWSAtualizarAutorizadorResult :=  IIF(::oWSAtualizarAutorizadorResult = NIL , NIL ,::oWSAtualizarAutorizadorResult:Clone() )
	oClone:oWSAtualizarRQ :=  IIF(::oWSAtualizarRQ = NIL , NIL ,::oWSAtualizarRQ:Clone() )
	oClone:oWSAtualizarResult :=  IIF(::oWSAtualizarResult = NIL , NIL ,::oWSAtualizarResult:Clone() )
	oClone:oWSExcluirRQ  :=  IIF(::oWSExcluirRQ = NIL , NIL ,::oWSExcluirRQ:Clone() )
	oClone:oWSExcluirResult :=  IIF(::oWSExcluirResult = NIL , NIL ,::oWSExcluirResult:Clone() )
Return oClone

// WSDL Method Consultar of Service WSUsuarios

WSMETHOD Consultar WSSEND oWSConsultarRQ WSRECEIVE oWSConsultarResult WSCLIENT WSUsuarios
Local cSoap	:= "" , oXmlRet
Local cUrlAmb	:= SuperGetMv("MV_RESAMB",,"")

cUrlAmb += "/ReserveXml300/usuarios.asmx"


BEGIN WSMETHOD

cSoap += '<Consultar xmlns="http://www.reserve.com.br/ReserveXML300/">'
cSoap += WSSoapValue("ConsultarRQ", ::oWSConsultarRQ, oWSConsultarRQ , "ConsultarUsuariosRQ", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Consultar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.reserve.com.br/ReserveXML300/Consultar",; 
	"DOCUMENT","http://www.reserve.com.br/ReserveXML300/",,,; 
	cUrlAmb)

::Init()
::oWSConsultarResult:SoapRecv( WSAdvValue( oXmlRet,"_CONSULTARRESPONSE:_CONSULTARRESULT","ConsultarUsuariosRS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL

Return .T.

// WSDL Method AtualizarAutorizador of Service WSUsuarios

WSMETHOD AtualizarAutorizador WSSEND oWSAtualizarAutorizadorRQ WSRECEIVE oWSAtualizarAutorizadorResult WSCLIENT WSUsuarios
Local cSoap	:= "" , oXmlRet
Local cUrlAmb	:= SuperGetMv("MV_RESAMB",,"")

cUrlAmb += "/ReserveXml300/usuarios.asmx"

BEGIN WSMETHOD

cSoap += '<AtualizarAutorizador xmlns="http://www.reserve.com.br/ReserveXML300/">'
cSoap += WSSoapValue("AtualizarAutorizadorRQ", ::oWSAtualizarAutorizadorRQ, oWSAtualizarAutorizadorRQ , "AtualizarAutorizadorRQ", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AtualizarAutorizador>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.reserve.com.br/ReserveXML300/AtualizarAutorizador",; 
	"DOCUMENT","http://www.reserve.com.br/ReserveXML300/",,,; 
	cUrlAmb)

::Init()
::oWSAtualizarAutorizadorResult:SoapRecv( WSAdvValue( oXmlRet,"_ATUALIZARAUTORIZADORRESPONSE:_ATUALIZARAUTORIZADORRESULT","AtualizarAutorizadorRS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Atualizar of Service WSUsuarios

WSMETHOD Atualizar WSSEND oWSAtualizarRQ WSRECEIVE oWSAtualizarResult WSCLIENT WSUsuarios
Local cSoap	:= "" , oXmlRet
Local cUrlAmb	:= SuperGetMv("MV_RESAMB",,"")

cUrlAmb += "/ReserveXml300/usuarios.asmx"

BEGIN WSMETHOD

cSoap += '<Atualizar xmlns="http://www.reserve.com.br/ReserveXML300/">'
cSoap += WSSoapValue("AtualizarRQ", ::oWSAtualizarRQ, oWSAtualizarRQ , "AtualizarUsuariosRQ", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Atualizar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.reserve.com.br/ReserveXML300/Atualizar",; 
	"DOCUMENT","http://www.reserve.com.br/ReserveXML300/",,,; 
	cUrlAmb)

::Init()
::oWSAtualizarResult:SoapRecv( WSAdvValue( oXmlRet,"_ATUALIZARRESPONSE:_ATUALIZARRESULT","AtualizarUsuariosRS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Excluir of Service WSUsuarios

WSMETHOD Excluir WSSEND oWSExcluirRQ WSRECEIVE oWSExcluirResult WSCLIENT WSUsuarios
Local cSoap := "" , oXmlRet
Local cUrlAmb	:= SuperGetMv("MV_RESAMB",,"")

cUrlAmb += "/ReserveXml300/usuarios.asmx"

BEGIN WSMETHOD

cSoap += '<Excluir xmlns="http://www.reserve.com.br/ReserveXML300/">'
cSoap += WSSoapValue("ExcluirRQ", ::oWSExcluirRQ, oWSExcluirRQ , "ExcluirUsuariosRQ", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Excluir>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.reserve.com.br/ReserveXML300/Excluir",; 
	"DOCUMENT","http://www.reserve.com.br/ReserveXML300/",,,; 
	cUrlAmb)

::Init()
::oWSExcluirResult:SoapRecv( WSAdvValue( oXmlRet,"_EXCLUIRRESPONSE:_EXCLUIRRESULT","ExcluirUsuariosRS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ConsultarUsuariosRQ

WSSTRUCT Usuarios_ConsultarUsuariosRQ
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSFiltros                AS Usuarios_Filtros OPTIONAL
	WSDATA   nQtdeRetorno              AS int
	WSDATA   nPagina                   AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_ConsultarUsuariosRQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_ConsultarUsuariosRQ
Return

WSMETHOD CLONE WSCLIENT Usuarios_ConsultarUsuariosRQ
	Local oClone := Usuarios_ConsultarUsuariosRQ():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSFiltros           := IIF(::oWSFiltros = NIL , NIL , ::oWSFiltros:Clone() )
	oClone:nQtdeRetorno         := ::nQtdeRetorno
	oClone:nPagina              := ::nPagina
Return oClone

WSMETHOD SOAPSEND WSCLIENT Usuarios_ConsultarUsuariosRQ
	Local cSoap := ""
	cSoap += WSSoapValue("Sessao", ::cSessao, ::cSessao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Filtros", ::oWSFiltros, ::oWSFiltros , "Filtros", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("QtdeRetorno", ::nQtdeRetorno, ::nQtdeRetorno , "int", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Pagina", ::nPagina, ::nPagina , "int", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ConsultarUsuariosRS

WSSTRUCT Usuarios_ConsultarUsuariosRS
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSPassageiros            AS Usuarios_ArrayOfDados OPTIONAL
	WSDATA   oWSUsuarios               AS Usuarios_ArrayOfDados OPTIONAL
	WSDATA   oWSErros                  AS Usuarios_ArrayOfErro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_ConsultarUsuariosRS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_ConsultarUsuariosRS
Return

WSMETHOD CLONE WSCLIENT Usuarios_ConsultarUsuariosRS
	Local oClone := Usuarios_ConsultarUsuariosRS():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSPassageiros       := IIF(::oWSPassageiros = NIL , NIL , ::oWSPassageiros:Clone() )
	oClone:oWSUsuarios          := IIF(::oWSUsuarios = NIL , NIL , ::oWSUsuarios:Clone() )
	oClone:oWSErros             := IIF(::oWSErros = NIL , NIL , ::oWSErros:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_ConsultarUsuariosRS
	Local oNode2
	Local oNode3
	Local oNode4
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSessao            :=  WSAdvValue( oResponse,"_SESSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_PASSAGEIROS","ArrayOfDados",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSPassageiros := Usuarios_ArrayOfDados():New()
		::oWSPassageiros:SoapRecv(oNode2)
	EndIf
	oNode3 :=  WSAdvValue( oResponse,"_USUARIOS","ArrayOfDados",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode3 != NIL
		::oWSUsuarios := Usuarios_ArrayOfDados():New()
		::oWSUsuarios:SoapRecv(oNode3)
	EndIf
	oNode4 :=  WSAdvValue( oResponse,"_ERROS","ArrayOfErro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode4 != NIL
		::oWSErros := Usuarios_ArrayOfErro():New()
		::oWSErros:SoapRecv(oNode4)
	EndIf
Return

// WSDL Data Structure AtualizarAutorizadorRQ

WSSTRUCT Usuarios_AtualizarAutorizadorRQ
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSTipoIdentificador      AS Usuarios_TipoIdentificador
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_AtualizarAutorizadorRQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_AtualizarAutorizadorRQ
Return

WSMETHOD CLONE WSCLIENT Usuarios_AtualizarAutorizadorRQ
	Local oClone := Usuarios_AtualizarAutorizadorRQ():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSTipoIdentificador := IIF(::oWSTipoIdentificador = NIL , NIL , ::oWSTipoIdentificador:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Usuarios_AtualizarAutorizadorRQ
	Local cSoap := ""
	cSoap += WSSoapValue("Sessao", ::cSessao, ::cSessao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("TipoIdentificador", ::oWSTipoIdentificador, ::oWSTipoIdentificador , "TipoIdentificador", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure AtualizarAutorizadorRS

WSSTRUCT Usuarios_AtualizarAutorizadorRS
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSPassageiros            AS Usuarios_ArrayOfCadastro OPTIONAL
	WSDATA   oWSErros                  AS Usuarios_ArrayOfErro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_AtualizarAutorizadorRS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_AtualizarAutorizadorRS
Return

WSMETHOD CLONE WSCLIENT Usuarios_AtualizarAutorizadorRS
	Local oClone := Usuarios_AtualizarAutorizadorRS():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSPassageiros       := IIF(::oWSPassageiros = NIL , NIL , ::oWSPassageiros:Clone() )
	oClone:oWSErros             := IIF(::oWSErros = NIL , NIL , ::oWSErros:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_AtualizarAutorizadorRS
	Local oNode2
	Local oNode3
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSessao            :=  WSAdvValue( oResponse,"_SESSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_PASSAGEIROS","ArrayOfCadastro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSPassageiros := Usuarios_ArrayOfCadastro():New()
		::oWSPassageiros:SoapRecv(oNode2)
	EndIf
	oNode3 :=  WSAdvValue( oResponse,"_ERROS","ArrayOfErro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode3 != NIL
		::oWSErros := Usuarios_ArrayOfErro():New()
		::oWSErros:SoapRecv(oNode3)
	EndIf
Return

// WSDL Data Structure AtualizarUsuariosRQ

WSSTRUCT Usuarios_AtualizarUsuariosRQ
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSCadastros              AS Usuarios_ArrayOfDados OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_AtualizarUsuariosRQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_AtualizarUsuariosRQ
Return

WSMETHOD CLONE WSCLIENT Usuarios_AtualizarUsuariosRQ
	Local oClone := Usuarios_AtualizarUsuariosRQ():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSCadastros         := IIF(::oWSCadastros = NIL , NIL , ::oWSCadastros:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Usuarios_AtualizarUsuariosRQ
	Local cSoap := ""
	cSoap += WSSoapValue("Sessao", ::cSessao, ::cSessao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Cadastros", ::oWSCadastros, ::oWSCadastros , "ArrayOfDados", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure AtualizarUsuariosRS

WSSTRUCT Usuarios_AtualizarUsuariosRS
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSCadastros              AS Usuarios_Cadastros OPTIONAL
	WSDATA   oWSErros                  AS Usuarios_ArrayOfErro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_AtualizarUsuariosRS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_AtualizarUsuariosRS
Return

WSMETHOD CLONE WSCLIENT Usuarios_AtualizarUsuariosRS
	Local oClone := Usuarios_AtualizarUsuariosRS():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSCadastros         := IIF(::oWSCadastros = NIL , NIL , ::oWSCadastros:Clone() )
	oClone:oWSErros             := IIF(::oWSErros = NIL , NIL , ::oWSErros:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_AtualizarUsuariosRS
	Local oNode2
	Local oNode3
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSessao            :=  WSAdvValue( oResponse,"_SESSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_CADASTROS","Cadastros",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSCadastros := Usuarios_Cadastros():New()
		::oWSCadastros:SoapRecv(oNode2)
	EndIf
	oNode3 :=  WSAdvValue( oResponse,"_ERROS","ArrayOfErro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode3 != NIL
		::oWSErros := Usuarios_ArrayOfErro():New()
		::oWSErros:SoapRecv(oNode3)
	EndIf
Return

// WSDL Data Structure ExcluirUsuariosRQ

WSSTRUCT Usuarios_ExcluirUsuariosRQ
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSFiltros                AS Usuarios_Filtros OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_ExcluirUsuariosRQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_ExcluirUsuariosRQ
Return

WSMETHOD CLONE WSCLIENT Usuarios_ExcluirUsuariosRQ
	Local oClone := Usuarios_ExcluirUsuariosRQ():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSFiltros           := IIF(::oWSFiltros = NIL , NIL , ::oWSFiltros:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Usuarios_ExcluirUsuariosRQ
	Local cSoap := ""
	cSoap += WSSoapValue("Sessao", ::cSessao, ::cSessao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Filtros", ::oWSFiltros, ::oWSFiltros , "Filtros", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ExcluirUsuariosRS

WSSTRUCT Usuarios_ExcluirUsuariosRS
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSCadastros              AS Usuarios_Cadastros OPTIONAL
	WSDATA   oWSErros                  AS Usuarios_ArrayOfErro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_ExcluirUsuariosRS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_ExcluirUsuariosRS
Return

WSMETHOD CLONE WSCLIENT Usuarios_ExcluirUsuariosRS
	Local oClone := Usuarios_ExcluirUsuariosRS():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSCadastros         := IIF(::oWSCadastros = NIL , NIL , ::oWSCadastros:Clone() )
	oClone:oWSErros             := IIF(::oWSErros = NIL , NIL , ::oWSErros:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_ExcluirUsuariosRS
	Local oNode2
	Local oNode3
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSessao            :=  WSAdvValue( oResponse,"_SESSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_CADASTROS","Cadastros",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSCadastros := Usuarios_Cadastros():New()
		::oWSCadastros:SoapRecv(oNode2)
	EndIf
	oNode3 :=  WSAdvValue( oResponse,"_ERROS","ArrayOfErro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode3 != NIL
		::oWSErros := Usuarios_ArrayOfErro():New()
		::oWSErros:SoapRecv(oNode3)
	EndIf
Return

// WSDL Data Structure Filtros

WSSTRUCT Usuarios_Filtros
	WSDATA   oWSCODEmpresas            AS Usuarios_ArrayOfString OPTIONAL
	WSDATA   oWSTipoConsultaIdentificador AS Usuarios_TipoIdentificador
	WSDATA   oWSCPFs                   AS Usuarios_ArrayOfString1 OPTIONAL
	WSDATA   oWSMatriculas             AS Usuarios_ArrayOfString2 OPTIONAL
	WSDATA   oWSLogins                 AS Usuarios_ArrayOfString3 OPTIONAL
	WSDATA   oWSIDsReserve             AS Usuarios_ArrayOfInt OPTIONAL
	WSDATA   oWSTipoPax                AS Usuarios_TipoPax
	WSDATA   lAtivo                    AS boolean
	WSDATA   oWSTipoRequisicao         AS Usuarios_TipoRequisicao
	WSDATA   oWSNivelAutorizacao       AS Usuarios_NivelAutorizacao
	WSDATA   oWSServicoTipo            AS Usuarios_ServicoTipo
	WSDATA   oWSServicoArea            AS Usuarios_ServicoArea
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_Filtros
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_Filtros
Return

WSMETHOD CLONE WSCLIENT Usuarios_Filtros
	Local oClone := Usuarios_Filtros():NEW()
	oClone:oWSCODEmpresas       := IIF(::oWSCODEmpresas = NIL , NIL , ::oWSCODEmpresas:Clone() )
	oClone:oWSTipoConsultaIdentificador := IIF(::oWSTipoConsultaIdentificador = NIL , NIL , ::oWSTipoConsultaIdentificador:Clone() )
	oClone:oWSCPFs              := IIF(::oWSCPFs = NIL , NIL , ::oWSCPFs:Clone() )
	oClone:oWSMatriculas        := IIF(::oWSMatriculas = NIL , NIL , ::oWSMatriculas:Clone() )
	oClone:oWSLogins            := IIF(::oWSLogins = NIL , NIL , ::oWSLogins:Clone() )
	oClone:oWSIDsReserve        := IIF(::oWSIDsReserve = NIL , NIL , ::oWSIDsReserve:Clone() )
	oClone:oWSTipoPax           := IIF(::oWSTipoPax = NIL , NIL , ::oWSTipoPax:Clone() )
	oClone:lAtivo               := ::lAtivo
	oClone:oWSTipoRequisicao    := IIF(::oWSTipoRequisicao = NIL , NIL , ::oWSTipoRequisicao:Clone() )
	oClone:oWSNivelAutorizacao  := IIF(::oWSNivelAutorizacao = NIL , NIL , ::oWSNivelAutorizacao:Clone() )
	oClone:oWSServicoTipo       := IIF(::oWSServicoTipo = NIL , NIL , ::oWSServicoTipo:Clone() )
	oClone:oWSServicoArea       := IIF(::oWSServicoArea = NIL , NIL , ::oWSServicoArea:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Usuarios_Filtros
	Local cSoap := ""
	cSoap += WSSoapValue("CODEmpresas", ::oWSCODEmpresas, ::oWSCODEmpresas , "ArrayOfString", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("TipoConsultaIdentificador", ::oWSTipoConsultaIdentificador, ::oWSTipoConsultaIdentificador , "TipoIdentificador", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CPFs", ::oWSCPFs, ::oWSCPFs , "ArrayOfString1", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Matriculas", ::oWSMatriculas, ::oWSMatriculas , "ArrayOfString2", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Logins", ::oWSLogins, ::oWSLogins , "ArrayOfString3", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("IDsReserve", ::oWSIDsReserve, ::oWSIDsReserve , "ArrayOfInt", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("TipoPax", ::oWSTipoPax, ::oWSTipoPax , "TipoPax", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Ativo", ::lAtivo, ::lAtivo , "boolean", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("TipoRequisicao", ::oWSTipoRequisicao, ::oWSTipoRequisicao , "TipoRequisicao", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NivelAutorizacao", ::oWSNivelAutorizacao, ::oWSNivelAutorizacao , "NivelAutorizacao", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ServicoTipo", ::oWSServicoTipo, ::oWSServicoTipo , "ServicoTipo", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ServicoArea", ::oWSServicoArea, ::oWSServicoArea , "ServicoArea", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ArrayOfDados

WSSTRUCT Usuarios_ArrayOfDados
	WSDATA   oWSDados                  AS Usuarios_Dados OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_ArrayOfDados
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_ArrayOfDados
	::oWSDados             := {} // Array Of  Usuarios_DADOS():New()
Return

WSMETHOD CLONE WSCLIENT Usuarios_ArrayOfDados
	Local oClone := Usuarios_ArrayOfDados():NEW()
	oClone:oWSDados := NIL
	If ::oWSDados <> NIL 
		oClone:oWSDados := {}
		aEval( ::oWSDados , { |x| aadd( oClone:oWSDados , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Usuarios_ArrayOfDados
	Local cSoap := ""
	aEval( ::oWSDados , {|x| cSoap := cSoap  +  WSSoapValue("Dados", x , x , "Dados", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_ArrayOfDados
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_DADOS","Dados",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSDados , Usuarios_Dados():New() )
			::oWSDados[len(::oWSDados)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfErro

WSSTRUCT Usuarios_ArrayOfErro
	WSDATA   oWSErro                   AS Usuarios_Erro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_ArrayOfErro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_ArrayOfErro
	::oWSErro              := {} // Array Of  Usuarios_ERRO():New()
Return

WSMETHOD CLONE WSCLIENT Usuarios_ArrayOfErro
	Local oClone := Usuarios_ArrayOfErro():NEW()
	oClone:oWSErro := NIL
	If ::oWSErro <> NIL 
		oClone:oWSErro := {}
		aEval( ::oWSErro , { |x| aadd( oClone:oWSErro , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_ArrayOfErro
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ERRO","Erro",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSErro , Usuarios_Erro():New() )
			::oWSErro[len(::oWSErro)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfCadastro

WSSTRUCT Usuarios_ArrayOfCadastro
	WSDATA   oWSCadastro               AS Usuarios_Cadastro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_ArrayOfCadastro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_ArrayOfCadastro
	::oWSCadastro          := {} // Array Of  Usuarios_CADASTRO():New()
Return

WSMETHOD CLONE WSCLIENT Usuarios_ArrayOfCadastro
	Local oClone := Usuarios_ArrayOfCadastro():NEW()
	oClone:oWSCadastro := NIL
	If ::oWSCadastro <> NIL 
		oClone:oWSCadastro := {}
		aEval( ::oWSCadastro , { |x| aadd( oClone:oWSCadastro , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_ArrayOfCadastro
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CADASTRO","Cadastro",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSCadastro , Usuarios_Cadastro():New() )
			::oWSCadastro[len(::oWSCadastro)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure Cadastros

WSSTRUCT Usuarios_Cadastros
	WSDATA   oWSPassageiros            AS Usuarios_ArrayOfCadastro OPTIONAL
	WSDATA   oWSUsuarios               AS Usuarios_ArrayOfCadastro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_Cadastros
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_Cadastros
Return

WSMETHOD CLONE WSCLIENT Usuarios_Cadastros
	Local oClone := Usuarios_Cadastros():NEW()
	oClone:oWSPassageiros       := IIF(::oWSPassageiros = NIL , NIL , ::oWSPassageiros:Clone() )
	oClone:oWSUsuarios          := IIF(::oWSUsuarios = NIL , NIL , ::oWSUsuarios:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_Cadastros
	Local oNode1
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_PASSAGEIROS","ArrayOfCadastro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSPassageiros := Usuarios_ArrayOfCadastro():New()
		::oWSPassageiros:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_USUARIOS","ArrayOfCadastro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSUsuarios := Usuarios_ArrayOfCadastro():New()
		::oWSUsuarios:SoapRecv(oNode2)
	EndIf
Return

// WSDL Data Structure ArrayOfString

WSSTRUCT Usuarios_ArrayOfString
	WSDATA   cCODEmpresa               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_ArrayOfString
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_ArrayOfString
	::cCODEmpresa          := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT Usuarios_ArrayOfString
	Local oClone := Usuarios_ArrayOfString():NEW()
	oClone:cCODEmpresa          := IIf(::cCODEmpresa <> NIL , aClone(::cCODEmpresa) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Usuarios_ArrayOfString
	Local cSoap := ""
	aEval( ::cCODEmpresa , {|x| cSoap := cSoap  +  WSSoapValue("CODEmpresa", x , x , "string", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfString1

WSSTRUCT Usuarios_ArrayOfString1
	WSDATA   cCPF                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_ArrayOfString1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_ArrayOfString1
	::cCPF                 := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT Usuarios_ArrayOfString1
	Local oClone := Usuarios_ArrayOfString1():NEW()
	oClone:cCPF                 := IIf(::cCPF <> NIL , aClone(::cCPF) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Usuarios_ArrayOfString1
	Local cSoap := ""
	aEval( ::cCPF , {|x| cSoap := cSoap  +  WSSoapValue("CPF", x , x , "string", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfString2

WSSTRUCT Usuarios_ArrayOfString2
	WSDATA   cMatricula                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_ArrayOfString2
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_ArrayOfString2
	::cMatricula           := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT Usuarios_ArrayOfString2
	Local oClone := Usuarios_ArrayOfString2():NEW()
	oClone:cMatricula           := IIf(::cMatricula <> NIL , aClone(::cMatricula) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Usuarios_ArrayOfString2
	Local cSoap := ""
	aEval( ::cMatricula , {|x| cSoap := cSoap  +  WSSoapValue("Matricula", x , x , "string", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfString3

WSSTRUCT Usuarios_ArrayOfString3
	WSDATA   cLogin                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_ArrayOfString3
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_ArrayOfString3
	::cLogin               := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT Usuarios_ArrayOfString3
	Local oClone := Usuarios_ArrayOfString3():NEW()
	oClone:cLogin               := IIf(::cLogin <> NIL , aClone(::cLogin) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Usuarios_ArrayOfString3
	Local cSoap := ""
	aEval( ::cLogin , {|x| cSoap := cSoap  +  WSSoapValue("Login", x , x , "string", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfInt

WSSTRUCT Usuarios_ArrayOfInt
	WSDATA   nIDReserve                AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_ArrayOfInt
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_ArrayOfInt
	::nIDReserve           := {} // Array Of  0
Return

WSMETHOD CLONE WSCLIENT Usuarios_ArrayOfInt
	Local oClone := Usuarios_ArrayOfInt():NEW()
	oClone:nIDReserve           := IIf(::nIDReserve <> NIL , aClone(::nIDReserve) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Usuarios_ArrayOfInt
	Local cSoap := ""
	aEval( ::nIDReserve , {|x| cSoap := cSoap  +  WSSoapValue("IDReserve", x , x , "int", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Enumeration TipoRequisicao

WSSTRUCT Usuarios_TipoRequisicao
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_TipoRequisicao
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "2" )
	aadd(::aValueList , "1" )
	aadd(::aValueList , "0" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Usuarios_TipoRequisicao
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_TipoRequisicao
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Usuarios_TipoRequisicao
Local oClone := Usuarios_TipoRequisicao():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure Dados

WSSTRUCT Usuarios_Dados
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cEmail                    AS string OPTIONAL
	WSDATA   cCargo                    AS string OPTIONAL
	WSDATA   cDepartamento             AS string OPTIONAL
	WSDATA   cMatricula                AS string OPTIONAL
	WSDATA   oWSSexo                   AS Usuarios_Sexo
	WSDATA   oWSTelefone               AS Usuarios_Telefone OPTIONAL
	WSDATA   oWSIdioma                 AS Usuarios_Idioma
	WSDATA   cCodEmpresa               AS string OPTIONAL
	WSDATA   oWSUsuario                AS Usuarios_DadosAcesso OPTIONAL
	WSDATA   oWSPassageiro             AS Usuarios_DadosPax OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_Dados
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_Dados
Return

WSMETHOD CLONE WSCLIENT Usuarios_Dados
	Local oClone := Usuarios_Dados():NEW()
	oClone:cNome                := ::cNome
	oClone:cEmail               := ::cEmail
	oClone:cCargo               := ::cCargo
	oClone:cDepartamento        := ::cDepartamento
	oClone:cMatricula           := ::cMatricula
	oClone:oWSSexo              := IIF(::oWSSexo = NIL , NIL , ::oWSSexo:Clone() )
	oClone:oWSTelefone          := IIF(::oWSTelefone = NIL , NIL , ::oWSTelefone:Clone() )
	oClone:oWSIdioma            := IIF(::oWSIdioma = NIL , NIL , ::oWSIdioma:Clone() )
	oClone:cCodEmpresa          := ::cCodEmpresa
	oClone:oWSUsuario           := IIF(::oWSUsuario = NIL , NIL , ::oWSUsuario:Clone() )
	oClone:oWSPassageiro        := IIF(::oWSPassageiro = NIL , NIL , ::oWSPassageiro:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Usuarios_Dados
	Local cSoap := ""
	cSoap += WSSoapValue("Nome", ::cNome, ::cNome , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Email", ::cEmail, ::cEmail , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Cargo", ::cCargo, ::cCargo , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Departamento", ::cDepartamento, ::cDepartamento , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Matricula", ::cMatricula, ::cMatricula , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Sexo", ::oWSSexo, ::oWSSexo , "Sexo", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Telefone", ::oWSTelefone, ::oWSTelefone , "Telefone", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Idioma", ::oWSIdioma, ::oWSIdioma , "Idioma", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CodEmpresa", ::cCodEmpresa, ::cCodEmpresa , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Usuario", ::oWSUsuario, ::oWSUsuario , "DadosAcesso", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Passageiro", ::oWSPassageiro, ::oWSPassageiro , "DadosPax", .F. , .F., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_Dados
	Local oNode6
	Local oNode7
	Local oNode8
	Local oNode10
	Local oNode11
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEmail             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCargo             :=  WSAdvValue( oResponse,"_CARGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDepartamento      :=  WSAdvValue( oResponse,"_DEPARTAMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMatricula         :=  WSAdvValue( oResponse,"_MATRICULA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode6 :=  WSAdvValue( oResponse,"_SEXO","Sexo",NIL,"Property oWSSexo as tns:Sexo on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode6 != NIL
		::oWSSexo := Usuarios_Sexo():New()
		::oWSSexo:SoapRecv(oNode6)
	EndIf
	oNode7 :=  WSAdvValue( oResponse,"_TELEFONE","Telefone",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode7 != NIL
		::oWSTelefone := Usuarios_Telefone():New()
		::oWSTelefone:SoapRecv(oNode7)
	EndIf
	oNode8 :=  WSAdvValue( oResponse,"_IDIOMA","Idioma",NIL,"Property oWSIdioma as tns:Idioma on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode8 != NIL
		::oWSIdioma := Usuarios_Idioma():New()
		::oWSIdioma:SoapRecv(oNode8)
	EndIf
	::cCodEmpresa        :=  WSAdvValue( oResponse,"_CODEMPRESA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode10 :=  WSAdvValue( oResponse,"_USUARIO","DadosAcesso",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode10 != NIL
		::oWSUsuario := Usuarios_DadosAcesso():New()
		::oWSUsuario:SoapRecv(oNode10)
	EndIf
	oNode11 :=  WSAdvValue( oResponse,"_PASSAGEIRO","DadosPax",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode11 != NIL
		::oWSPassageiro := Usuarios_DadosPax():New()
		::oWSPassageiro:SoapRecv(oNode11)
	EndIf
Return

// WSDL Data Structure Erro

WSSTRUCT Usuarios_Erro
	WSDATA   cCodErro                  AS string OPTIONAL
	WSDATA   cMensagem                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_Erro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_Erro
Return

WSMETHOD CLONE WSCLIENT Usuarios_Erro
	Local oClone := Usuarios_Erro():NEW()
	oClone:cCodErro             := ::cCodErro
	oClone:cMensagem            := ::cMensagem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_Erro
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodErro           :=  WSAdvValue( oResponse,"_CODERRO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure Cadastro

WSSTRUCT Usuarios_Cadastro
	WSDATA   cMatricula                AS string OPTIONAL
	WSDATA   cLogin                    AS string OPTIONAL
	WSDATA   cCPF                      AS string OPTIONAL
	WSDATA   nIDReserve                AS int
	WSDATA   oWSErros                  AS Usuarios_ArrayOfErro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_Cadastro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_Cadastro
Return

WSMETHOD CLONE WSCLIENT Usuarios_Cadastro
	Local oClone := Usuarios_Cadastro():NEW()
	oClone:cMatricula           := ::cMatricula
	oClone:cLogin               := ::cLogin
	oClone:cCPF                 := ::cCPF
	oClone:nIDReserve           := ::nIDReserve
	oClone:oWSErros             := IIF(::oWSErros = NIL , NIL , ::oWSErros:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_Cadastro
	Local oNode5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cMatricula         :=  WSAdvValue( oResponse,"_MATRICULA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cLogin             :=  WSAdvValue( oResponse,"_LOGIN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCPF               :=  WSAdvValue( oResponse,"_CPF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nIDReserve         :=  WSAdvValue( oResponse,"_IDRESERVE","int",NIL,"Property nIDReserve as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode5 :=  WSAdvValue( oResponse,"_ERROS","ArrayOfErro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSErros := Usuarios_ArrayOfErro():New()
		::oWSErros:SoapRecv(oNode5)
	EndIf
Return

// WSDL Data Enumeration Sexo

WSSTRUCT Usuarios_Sexo
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_Sexo
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "0" )
	aadd(::aValueList , "1" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Usuarios_Sexo
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_Sexo
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Usuarios_Sexo
Local oClone := Usuarios_Sexo():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure Telefone

WSSTRUCT Usuarios_Telefone
	WSDATA   cCodArea                  AS string OPTIONAL
	WSDATA   cCodPais                  AS string OPTIONAL
	WSDATA   cTelefone                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_Telefone
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_Telefone
Return

WSMETHOD CLONE WSCLIENT Usuarios_Telefone
	Local oClone := Usuarios_Telefone():NEW()
	oClone:cCodArea             := ::cCodArea
	oClone:cCodPais             := ::cCodPais
	oClone:cTelefone            := ::cTelefone
Return oClone

WSMETHOD SOAPSEND WSCLIENT Usuarios_Telefone
	Local cSoap := ""
	cSoap += WSSoapValue("CodArea", ::cCodArea, ::cCodArea , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CodPais", ::cCodPais, ::cCodPais , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Telefone", ::cTelefone, ::cTelefone , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_Telefone
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodArea           :=  WSAdvValue( oResponse,"_CODAREA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodPais           :=  WSAdvValue( oResponse,"_CODPAIS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTelefone          :=  WSAdvValue( oResponse,"_TELEFONE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Enumeration Idioma

WSSTRUCT Usuarios_Idioma
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_Idioma
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "0" )
	aadd(::aValueList , "1" )
	aadd(::aValueList , "2" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Usuarios_Idioma
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_Idioma
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Usuarios_Idioma
Local oClone := Usuarios_Idioma():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure DadosAcesso

WSSTRUCT Usuarios_DadosAcesso
	WSDATA   nIDReserve                AS int
	WSDATA   cIDGrupoAcesso            AS string OPTIONAL
	WSDATA   cLogin                    AS string OPTIONAL
	WSDATA   lAusente                  AS boolean OPTIONAL
	WSDATA   oWSNivelAutorizacao       AS Usuarios_NivelAutorizacao
	WSDATA   oWSServicoArea            AS Usuarios_ServicoArea
	WSDATA   oWSServicoTipo            AS Usuarios_ServicoTipo
	WSDATA   lPedePaxVIP               AS boolean
	WSDATA   lAtivo                    AS boolean
	WSDATA   oWSTipoIdentificador      AS Usuarios_TipoIdentificador
	WSDATA   cCodEmpresaOriginal       AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_DadosAcesso
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_DadosAcesso
Return

WSMETHOD CLONE WSCLIENT Usuarios_DadosAcesso
	Local oClone := Usuarios_DadosAcesso():NEW()
	oClone:nIDReserve           := ::nIDReserve
	oClone:cIDGrupoAcesso       := ::cIDGrupoAcesso
	oClone:cLogin               := ::cLogin
	oClone:lAusente             := ::lAusente
	oClone:oWSNivelAutorizacao  := IIF(::oWSNivelAutorizacao = NIL , NIL , ::oWSNivelAutorizacao:Clone() )
	oClone:oWSServicoArea       := IIF(::oWSServicoArea = NIL , NIL , ::oWSServicoArea:Clone() )
	oClone:oWSServicoTipo       := IIF(::oWSServicoTipo = NIL , NIL , ::oWSServicoTipo:Clone() )
	oClone:lPedePaxVIP          := ::lPedePaxVIP
	oClone:lAtivo               := ::lAtivo
	oClone:oWSTipoIdentificador := IIF(::oWSTipoIdentificador = NIL , NIL , ::oWSTipoIdentificador:Clone() )
	oClone:cCodEmpresaOriginal  := ::cCodEmpresaOriginal
Return oClone

WSMETHOD SOAPSEND WSCLIENT Usuarios_DadosAcesso
	Local cSoap := ""
	cSoap += WSSoapValue("IDReserve", ::nIDReserve, ::nIDReserve , "int", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("IDGrupoAcesso", ::cIDGrupoAcesso, ::cIDGrupoAcesso , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Login", ::cLogin, ::cLogin , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Ausente", ::lAusente, ::lAusente , "boolean", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NivelAutorizacao", ::oWSNivelAutorizacao, ::oWSNivelAutorizacao , "NivelAutorizacao", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ServicoArea", ::oWSServicoArea, ::oWSServicoArea , "ServicoArea", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ServicoTipo", ::oWSServicoTipo, ::oWSServicoTipo , "ServicoTipo", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("PedePaxVIP", ::lPedePaxVIP, ::lPedePaxVIP , "boolean", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Ativo", ::lAtivo, ::lAtivo , "boolean", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("TipoIdentificador", ::oWSTipoIdentificador, ::oWSTipoIdentificador , "TipoIdentificador", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CodEmpresaOriginal", ::cCodEmpresaOriginal, ::cCodEmpresaOriginal , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_DadosAcesso
	Local oNode5
	Local oNode6
	Local oNode7
	Local oNode10
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nIDReserve         :=  WSAdvValue( oResponse,"_IDRESERVE","int",NIL,"Property nIDReserve as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cIDGrupoAcesso     :=  WSAdvValue( oResponse,"_IDGRUPOACESSO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cLogin             :=  WSAdvValue( oResponse,"_LOGIN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lAusente           :=  WSAdvValue( oResponse,"_AUSENTE","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	oNode5 :=  WSAdvValue( oResponse,"_NIVELAUTORIZACAO","NivelAutorizacao",NIL,"Property oWSNivelAutorizacao as tns:NivelAutorizacao on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSNivelAutorizacao := Usuarios_NivelAutorizacao():New()
		::oWSNivelAutorizacao:SoapRecv(oNode5)
	EndIf
	oNode6 :=  WSAdvValue( oResponse,"_SERVICOAREA","ServicoArea",NIL,"Property oWSServicoArea as tns:ServicoArea on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode6 != NIL
		::oWSServicoArea := Usuarios_ServicoArea():New()
		::oWSServicoArea:SoapRecv(oNode6)
	EndIf
	oNode7 :=  WSAdvValue( oResponse,"_SERVICOTIPO","ServicoTipo",NIL,"Property oWSServicoTipo as tns:ServicoTipo on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode7 != NIL
		::oWSServicoTipo := Usuarios_ServicoTipo():New()
		::oWSServicoTipo:SoapRecv(oNode7)
	EndIf
	::lPedePaxVIP        :=  WSAdvValue( oResponse,"_PEDEPAXVIP","boolean",NIL,"Property lPedePaxVIP as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::lAtivo             :=  WSAdvValue( oResponse,"_ATIVO","boolean",NIL,"Property lAtivo as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	oNode10 :=  WSAdvValue( oResponse,"_TIPOIDENTIFICADOR","TipoIdentificador",NIL,"Property oWSTipoIdentificador as tns:TipoIdentificador on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode10 != NIL
		::oWSTipoIdentificador := Usuarios_TipoIdentificador():New()
		::oWSTipoIdentificador:SoapRecv(oNode10)
	EndIf
	::cCodEmpresaOriginal :=  WSAdvValue( oResponse,"_CODEMPRESAORIGINAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure DadosPax

WSSTRUCT Usuarios_DadosPax
	WSDATA   nIDReserve                AS int
	WSDATA   oWSCelular                AS Usuarios_Telefone OPTIONAL
	WSDATA   cDataNascimento           AS dateTime OPTIONAL
	WSDATA   cCPF                      AS string OPTIONAL
	WSDATA   cIDAutPreferencial        AS string OPTIONAL
	WSDATA   cRG                       AS string OPTIONAL
	WSDATA   cEndereco                 AS string OPTIONAL
	WSDATA   cCidade                   AS string OPTIONAL
	WSDATA   cCEP                      AS string OPTIONAL
	WSDATA   cUF                       AS string OPTIONAL
	WSDATA   oWSTipopax                AS Usuarios_TipoPax OPTIONAL
	WSDATA   cCentroCusto              AS string OPTIONAL
	WSDATA   lIsentoPoliticas          AS boolean
	WSDATA   cContatoEmergencia        AS string OPTIONAL
	WSDATA   cNivelCargo               AS string OPTIONAL
	WSDATA   cTelefoneEmergencia       AS string OPTIONAL
	WSDATA   cNumeroPassaporte         AS string OPTIONAL
	WSDATA   cValidadePassaporte       AS string OPTIONAL
	WSDATA   cNumeroHabilitacao        AS string OPTIONAL
	WSDATA   cValidadeHabilitacao      AS string OPTIONAL
	WSDATA   oWSCartoesMilhagem        AS Usuarios_ArrayOfCartaoMilhagem OPTIONAL
	WSDATA   oWSPreferenciaAssento     AS Usuarios_PreferenciaAssento OPTIONAL
	WSDATA   oWSPreferenciaRefeicao    AS Usuarios_PreferenciaRefeicao OPTIONAL
	WSDATA   lAtivo                    AS boolean
	WSDATA   oWSTipoIdentificador      AS Usuarios_TipoIdentificador
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_DadosPax
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_DadosPax
Return

WSMETHOD CLONE WSCLIENT Usuarios_DadosPax
	Local oClone := Usuarios_DadosPax():NEW()
	oClone:nIDReserve           := ::nIDReserve
	oClone:oWSCelular           := IIF(::oWSCelular = NIL , NIL , ::oWSCelular:Clone() )
	oClone:cDataNascimento      := ::cDataNascimento
	oClone:cCPF                 := ::cCPF
	oClone:cIDAutPreferencial   := ::cIDAutPreferencial
	oClone:cRG                  := ::cRG
	oClone:cEndereco            := ::cEndereco
	oClone:cCidade              := ::cCidade
	oClone:cCEP                 := ::cCEP
	oClone:cUF                  := ::cUF
	oClone:oWSTipopax           := IIF(::oWSTipopax = NIL , NIL , ::oWSTipopax:Clone() )
	oClone:cCentroCusto         := ::cCentroCusto
	oClone:lIsentoPoliticas     := ::lIsentoPoliticas
	oClone:cContatoEmergencia   := ::cContatoEmergencia
	oClone:cNivelCargo          := ::cNivelCargo
	oClone:cTelefoneEmergencia  := ::cTelefoneEmergencia
	oClone:cNumeroPassaporte    := ::cNumeroPassaporte
	oClone:cValidadePassaporte  := ::cValidadePassaporte
	oClone:cNumeroHabilitacao   := ::cNumeroHabilitacao
	oClone:cValidadeHabilitacao := ::cValidadeHabilitacao
	oClone:oWSCartoesMilhagem   := IIF(::oWSCartoesMilhagem = NIL , NIL , ::oWSCartoesMilhagem:Clone() )
	oClone:oWSPreferenciaAssento := IIF(::oWSPreferenciaAssento = NIL , NIL , ::oWSPreferenciaAssento:Clone() )
	oClone:oWSPreferenciaRefeicao := IIF(::oWSPreferenciaRefeicao = NIL , NIL , ::oWSPreferenciaRefeicao:Clone() )
	oClone:lAtivo               := ::lAtivo
	oClone:oWSTipoIdentificador := IIF(::oWSTipoIdentificador = NIL , NIL , ::oWSTipoIdentificador:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Usuarios_DadosPax
	Local cSoap := ""
	cSoap += WSSoapValue("IDReserve", ::nIDReserve, ::nIDReserve , "int", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Celular", ::oWSCelular, ::oWSCelular , "Telefone", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("DataNascimento", ::cDataNascimento, ::cDataNascimento , "dateTime", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CPF", ::cCPF, ::cCPF , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("IDAutPreferencial", ::cIDAutPreferencial, ::cIDAutPreferencial , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("RG", ::cRG, ::cRG , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Endereco", ::cEndereco, ::cEndereco , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Cidade", ::cCidade, ::cCidade , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CEP", ::cCEP, ::cCEP , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("UF", ::cUF, ::cUF , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Tipopax", ::oWSTipopax, ::oWSTipopax , "TipoPax", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CentroCusto", ::cCentroCusto, ::cCentroCusto , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("IsentoPoliticas", ::lIsentoPoliticas, ::lIsentoPoliticas , "boolean", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ContatoEmergencia", ::cContatoEmergencia, ::cContatoEmergencia , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NivelCargo", ::cNivelCargo, ::cNivelCargo , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("TelefoneEmergencia", ::cTelefoneEmergencia, ::cTelefoneEmergencia , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NumeroPassaporte", ::cNumeroPassaporte, ::cNumeroPassaporte , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ValidadePassaporte", ::cValidadePassaporte, ::cValidadePassaporte , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NumeroHabilitacao", ::cNumeroHabilitacao, ::cNumeroHabilitacao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ValidadeHabilitacao", ::cValidadeHabilitacao, ::cValidadeHabilitacao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CartoesMilhagem", ::oWSCartoesMilhagem, ::oWSCartoesMilhagem , "ArrayOfCartaoMilhagem", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("PreferenciaAssento", ::oWSPreferenciaAssento, ::oWSPreferenciaAssento , "PreferenciaAssento", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("PreferenciaRefeicao", ::oWSPreferenciaRefeicao, ::oWSPreferenciaRefeicao , "PreferenciaRefeicao", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Ativo", ::lAtivo, ::lAtivo , "boolean", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("TipoIdentificador", ::oWSTipoIdentificador, ::oWSTipoIdentificador , "TipoIdentificador", .T. , .F., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_DadosPax
	Local oNode2
	Local oNode11
	Local oNode21
	Local oNode22
	Local oNode23
	Local oNode25
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nIDReserve         :=  WSAdvValue( oResponse,"_IDRESERVE","int",NIL,"Property nIDReserve as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_CELULAR","Telefone",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSCelular := Usuarios_Telefone():New()
		::oWSCelular:SoapRecv(oNode2)
	EndIf
	::cDataNascimento    :=  WSAdvValue( oResponse,"_DATANASCIMENTO","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCPF               :=  WSAdvValue( oResponse,"_CPF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cIDAutPreferencial :=  WSAdvValue( oResponse,"_IDAUTPREFERENCIAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRG                :=  WSAdvValue( oResponse,"_RG","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEndereco          :=  WSAdvValue( oResponse,"_ENDERECO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCidade            :=  WSAdvValue( oResponse,"_CIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCEP               :=  WSAdvValue( oResponse,"_CEP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cUF                :=  WSAdvValue( oResponse,"_UF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode11 :=  WSAdvValue( oResponse,"_TIPOPAX","TipoPax",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode11 != NIL
		::oWSTipopax := Usuarios_TipoPax():New()
		::oWSTipopax:SoapRecv(oNode11)
	EndIf
	::cCentroCusto       :=  WSAdvValue( oResponse,"_CENTROCUSTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lIsentoPoliticas   :=  WSAdvValue( oResponse,"_ISENTOPOLITICAS","boolean",NIL,"Property lIsentoPoliticas as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cContatoEmergencia :=  WSAdvValue( oResponse,"_CONTATOEMERGENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNivelCargo        :=  WSAdvValue( oResponse,"_NIVELCARGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTelefoneEmergencia :=  WSAdvValue( oResponse,"_TELEFONEEMERGENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNumeroPassaporte  :=  WSAdvValue( oResponse,"_NUMEROPASSAPORTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValidadePassaporte :=  WSAdvValue( oResponse,"_VALIDADEPASSAPORTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNumeroHabilitacao :=  WSAdvValue( oResponse,"_NUMEROHABILITACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValidadeHabilitacao :=  WSAdvValue( oResponse,"_VALIDADEHABILITACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode21 :=  WSAdvValue( oResponse,"_CARTOESMILHAGEM","ArrayOfCartaoMilhagem",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode21 != NIL
		::oWSCartoesMilhagem := Usuarios_ArrayOfCartaoMilhagem():New()
		::oWSCartoesMilhagem:SoapRecv(oNode21)
	EndIf
	oNode22 :=  WSAdvValue( oResponse,"_PREFERENCIAASSENTO","PreferenciaAssento",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode22 != NIL
		::oWSPreferenciaAssento := Usuarios_PreferenciaAssento():New()
		::oWSPreferenciaAssento:SoapRecv(oNode22)
	EndIf
	oNode23 :=  WSAdvValue( oResponse,"_PREFERENCIAREFEICAO","PreferenciaRefeicao",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode23 != NIL
		::oWSPreferenciaRefeicao := Usuarios_PreferenciaRefeicao():New()
		::oWSPreferenciaRefeicao:SoapRecv(oNode23)
	EndIf
	::lAtivo             :=  WSAdvValue( oResponse,"_ATIVO","boolean",NIL,"Property lAtivo as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	oNode25 :=  WSAdvValue( oResponse,"_TIPOIDENTIFICADOR","TipoIdentificador",NIL,"Property oWSTipoIdentificador as tns:TipoIdentificador on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode25 != NIL
		::oWSTipoIdentificador := Usuarios_TipoIdentificador():New()
		::oWSTipoIdentificador:SoapRecv(oNode25)
	EndIf
Return

// WSDL Data Enumeration NivelAutorizacao

WSSTRUCT Usuarios_NivelAutorizacao
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_NivelAutorizacao
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "0" )
	aadd(::aValueList , "1" )
	aadd(::aValueList , "2" )
	aadd(::aValueList , "3" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Usuarios_NivelAutorizacao
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_NivelAutorizacao
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Usuarios_NivelAutorizacao
Local oClone := Usuarios_NivelAutorizacao():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration ServicoArea

WSSTRUCT Usuarios_ServicoArea
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_ServicoArea
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "0" )
	aadd(::aValueList , "1" )
	aadd(::aValueList , "2" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Usuarios_ServicoArea
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_ServicoArea
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Usuarios_ServicoArea
Local oClone := Usuarios_ServicoArea():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration ServicoTipo

WSSTRUCT Usuarios_ServicoTipo
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_ServicoTipo
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "0" )
	aadd(::aValueList , "1" )
	aadd(::aValueList , "2" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Usuarios_ServicoTipo
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_ServicoTipo
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Usuarios_ServicoTipo
Local oClone := Usuarios_ServicoTipo():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration TipoIdentificador

WSSTRUCT Usuarios_TipoIdentificador
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_TipoIdentificador
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "0" )
	aadd(::aValueList , "1" )
	aadd(::aValueList , "2" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Usuarios_TipoIdentificador
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_TipoIdentificador
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Usuarios_TipoIdentificador
Local oClone := Usuarios_TipoIdentificador():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration TipoPax

WSSTRUCT Usuarios_TipoPax
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_TipoPax
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "0" )
	aadd(::aValueList , "1" )
	aadd(::aValueList , "2" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Usuarios_TipoPax
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_TipoPax
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Usuarios_TipoPax
Local oClone := Usuarios_TipoPax():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure ArrayOfCartaoMilhagem

WSSTRUCT Usuarios_ArrayOfCartaoMilhagem
	WSDATA   oWSCartaoMilhagem         AS Usuarios_CartaoMilhagem OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_ArrayOfCartaoMilhagem
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_ArrayOfCartaoMilhagem
	::oWSCartaoMilhagem    := {} // Array Of  Usuarios_CARTAOMILHAGEM():New()
Return

WSMETHOD CLONE WSCLIENT Usuarios_ArrayOfCartaoMilhagem
	Local oClone := Usuarios_ArrayOfCartaoMilhagem():NEW()
	oClone:oWSCartaoMilhagem := NIL
	If ::oWSCartaoMilhagem <> NIL 
		oClone:oWSCartaoMilhagem := {}
		aEval( ::oWSCartaoMilhagem , { |x| aadd( oClone:oWSCartaoMilhagem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Usuarios_ArrayOfCartaoMilhagem
	Local cSoap := ""
	aEval( ::oWSCartaoMilhagem , {|x| cSoap := cSoap  +  WSSoapValue("CartaoMilhagem", x , x , "CartaoMilhagem", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_ArrayOfCartaoMilhagem
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CARTAOMILHAGEM","CartaoMilhagem",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSCartaoMilhagem , Usuarios_CartaoMilhagem():New() )
			::oWSCartaoMilhagem[len(::oWSCartaoMilhagem)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Enumeration PreferenciaAssento

WSSTRUCT Usuarios_PreferenciaAssento
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_PreferenciaAssento
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "0" )
	aadd(::aValueList , "1" )
	aadd(::aValueList , "2" )
	aadd(::aValueList , "3" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Usuarios_PreferenciaAssento
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_PreferenciaAssento
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Usuarios_PreferenciaAssento
Local oClone := Usuarios_PreferenciaAssento():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration PreferenciaRefeicao

WSSTRUCT Usuarios_PreferenciaRefeicao
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_PreferenciaRefeicao
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "0" )
	aadd(::aValueList , "1" )
	aadd(::aValueList , "2" )
	aadd(::aValueList , "3" )
	aadd(::aValueList , "4" )
	aadd(::aValueList , "5" )
	aadd(::aValueList , "6" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Usuarios_PreferenciaRefeicao
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_PreferenciaRefeicao
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Usuarios_PreferenciaRefeicao
Local oClone := Usuarios_PreferenciaRefeicao():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure CartaoMilhagem

WSSTRUCT Usuarios_CartaoMilhagem
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cNumero                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Usuarios_CartaoMilhagem
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Usuarios_CartaoMilhagem
Return

WSMETHOD CLONE WSCLIENT Usuarios_CartaoMilhagem
	Local oClone := Usuarios_CartaoMilhagem():NEW()
	oClone:cNome                := ::cNome
	oClone:cNumero              := ::cNumero
Return oClone

WSMETHOD SOAPSEND WSCLIENT Usuarios_CartaoMilhagem
	Local cSoap := ""
	cSoap += WSSoapValue("Nome", ::cNome, ::cNome , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Numero", ::cNumero, ::cNumero , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Usuarios_CartaoMilhagem
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNumero            :=  WSAdvValue( oResponse,"_NUMERO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


