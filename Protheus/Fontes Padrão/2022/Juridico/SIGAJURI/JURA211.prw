#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "JURA211.CH"

/* ===============================================================================
WSDL Location    http://www.kurier.com.br/webservicekurier/Service1.asmx?WSDL
Gerado em        03/08/16 08:43:39
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _FMPZILY ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service JURA211
------------------------------------------------------------------------------- */

WSCLIENT JURA211

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ConsultarPublicacaoIntegracaoEnviadaIdProcesso
	WSMETHOD ConsultarPublicacaoIntegracaoEnviada
	WSMETHOD ConsultarQuantidadePublicacaoEnviadaIntegracao
	WSMETHOD ConsultarPublicacaoIntegracao
	WSMETHOD ConsultarPublicacao
	WSMETHOD ConsultarPublicacao2015
	WSMETHOD CapturarPublicacoes
	WSMETHOD CapturarPublicacoesList
	WSMETHOD AtualizarCapturarPublicacoes
	WSMETHOD ConsultaPublicacaoNovas
	WSMETHOD ConsultaPublicacaoId
	WSMETHOD CarregarDiarios
	WSMETHOD CarregarDivisaoDiario
	WSMETHOD AtualizarCapturaPublicacoesPorId
	WSMETHOD RecuperarPublicacaoPorID

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cLogin                    AS string
	WSDATA   cidProcesso               AS string
	WSDATA   cnome                     AS string
	WSDATA   oWSConsultarPublicacaoIntegracaoEnviadaIdProcessoResult AS SCHEMA
	WSDATA   cData                     AS string
	WSDATA   cdiario                   AS string
	WSDATA   oWSConsultarPublicacaoIntegracaoEnviadaResult AS SCHEMA
	WSDATA   oWSConsultarQuantidadePublicacaoEnviadaIntegracaoResult AS SCHEMA
	WSDATA   oWSConsultarPublicacaoIntegracaoResult AS SCHEMA
	WSDATA   cDivisaoDiario            AS string
	WSDATA   oWSConsultarPublicacaoResult AS SCHEMA
	WSDATA   oWSConsultarPublicacao2015Result AS SCHEMA
	WSDATA   oWSCapturarPublicacoesResult AS SCHEMA
	WSDATA   oWSCapturarPublicacoesListResult AS Service1_ArrayOfPublicacoes
	WSDATA   oWSds                     AS SCHEMA
	WSDATA   lAtualizarCapturarPublicacoesResult AS boolean
	WSDATA   oWSConsultaPublicacaoNovasResult AS SCHEMA
	WSDATA   csenha                    AS string
	WSDATA   oWSConsultaPublicacaoIdResult AS SCHEMA
	WSDATA   oWSCarregarDiariosResult  AS SCHEMA
	WSDATA   cdescricaoDiario          AS string
	WSDATA   oWSCarregarDivisaoDiarioResult AS SCHEMA
	WSDATA   oWSListaId                AS Service1_ArrayOfCControleID
	WSDATA   lAtualizarCapturaPublicacoesPorIdResult AS boolean
	WSDATA   oWSRecuperarPublicacaoPorIDResult AS SCHEMA
	WSDATA   oXmlRet AS SCHEMA //criado para armazenar a referência que será derrubada para liberar memória.

ENDWSCLIENT

WSMETHOD NEW WSCLIENT JURA211
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20151026 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT JURA211
	ClearMem(::oWSConsultarPublicacaoIntegracaoEnviadaIdProcessoResult)
	ClearMem(::oWSConsultarPublicacaoIntegracaoEnviadaResult)
	ClearMem(::oWSConsultarQuantidadePublicacaoEnviadaIntegracaoResult)
	ClearMem(::oWSConsultarPublicacaoIntegracaoResult)
	ClearMem(::oWSConsultarPublicacaoResult)
	ClearMem(::oWSConsultarPublicacao2015Result)
	ClearMem(::oWSCapturarPublicacoesResult)
	ClearMem(::oWSCapturarPublicacoesListResult)
	ClearMem(::oWSds)
	ClearMem(::oWSConsultaPublicacaoNovasResult)
	ClearMem(::oWSConsultaPublicacaoIdResult)
	ClearMem(::oWSCarregarDiariosResult)
	ClearMem(::oWSCarregarDivisaoDiarioResult)
	ClearMem(::oWSListaId)
	ClearMem(::oWSRecuperarPublicacaoPorIDResult)
	
	::oWSConsultarPublicacaoIntegracaoEnviadaIdProcessoResult := NIL 
	::oWSConsultarPublicacaoIntegracaoEnviadaResult := NIL 
	::oWSConsultarQuantidadePublicacaoEnviadaIntegracaoResult := NIL 
	::oWSConsultarPublicacaoIntegracaoResult := NIL 
	::oWSConsultarPublicacaoResult := NIL 
	::oWSConsultarPublicacao2015Result := NIL 
	::oWSCapturarPublicacoesResult := NIL 
	::oWSCapturarPublicacoesListResult := Service1_ARRAYOFPUBLICACOES():New()
	::oWSds              := NIL 
	::oWSConsultaPublicacaoNovasResult := NIL 
	::oWSConsultaPublicacaoIdResult := NIL 
	::oWSCarregarDiariosResult := NIL 
	::oWSCarregarDivisaoDiarioResult := NIL 
	::oWSListaId         := Service1_ARRAYOFCCONTROLEID():New()
	::oWSRecuperarPublicacaoPorIDResult := NIL 
Return

WSMETHOD RESET WSCLIENT JURA211
	::cLogin             := NIL 
	::cidProcesso        := NIL 
	::cnome              := NIL 
	::oWSConsultarPublicacaoIntegracaoEnviadaIdProcessoResult := NIL 
	::cData              := NIL 
	::cdiario            := NIL 
	::oWSConsultarPublicacaoIntegracaoEnviadaResult := NIL 
	::oWSConsultarQuantidadePublicacaoEnviadaIntegracaoResult := NIL 
	::oWSConsultarPublicacaoIntegracaoResult := NIL 
	::cDivisaoDiario     := NIL 
	::oWSConsultarPublicacaoResult := NIL 
	::oWSConsultarPublicacao2015Result := NIL 
	::oWSCapturarPublicacoesResult := NIL 
	::oWSCapturarPublicacoesListResult := NIL 
	::oWSds              := NIL 
	::lAtualizarCapturarPublicacoesResult := NIL 
	::oWSConsultaPublicacaoNovasResult := NIL 
	::csenha             := NIL 
	::oWSConsultaPublicacaoIdResult := NIL 
	::oWSCarregarDiariosResult := NIL 
	::cdescricaoDiario   := NIL 
	::oWSCarregarDivisaoDiarioResult := NIL 
	::oWSListaId         := NIL 
	::lAtualizarCapturaPublicacoesPorIdResult := NIL 
	::oWSRecuperarPublicacaoPorIDResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT JURA211
Local oClone := JURA211():New()
	oClone:_URL          := ::_URL 
	oClone:cLogin        := ::cLogin
	oClone:cidProcesso   := ::cidProcesso
	oClone:cnome         := ::cnome
	oClone:cData         := ::cData
	oClone:cdiario       := ::cdiario
	oClone:cDivisaoDiario := ::cDivisaoDiario
	oClone:oWSCapturarPublicacoesListResult :=  IIF(::oWSCapturarPublicacoesListResult = NIL , NIL ,::oWSCapturarPublicacoesListResult:Clone() )
	oClone:lAtualizarCapturarPublicacoesResult := ::lAtualizarCapturarPublicacoesResult
	oClone:csenha        := ::csenha
	oClone:cdescricaoDiario := ::cdescricaoDiario
	oClone:oWSListaId    :=  IIF(::oWSListaId = NIL , NIL ,::oWSListaId:Clone() )
	oClone:lAtualizarCapturaPublicacoesPorIdResult := ::lAtualizarCapturaPublicacoesPorIdResult
Return oClone

// WSDL Method ConsultarPublicacaoIntegracaoEnviadaIdProcesso of Service JURA211

WSMETHOD ConsultarPublicacaoIntegracaoEnviadaIdProcesso WSSEND cLogin,cidProcesso,cnome WSRECEIVE oWSConsultarPublicacaoIntegracaoEnviadaIdProcessoResult WSCLIENT JURA211
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultarPublicacaoIntegracaoEnviadaIdProcesso xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("idProcesso", ::cidProcesso, cidProcesso , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("nome", ::cnome, cnome , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConsultarPublicacaoIntegracaoEnviadaIdProcesso>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/ConsultarPublicacaoIntegracaoEnviadaIdProcesso",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv('MV_JKURL',.T.,""))

::Init()
::oWSConsultarPublicacaoIntegracaoEnviadaIdProcessoResult :=  WSAdvValue( oXmlRet,"_CONSULTARPUBLICACAOINTEGRACAOENVIADAIDPROCESSORESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultarPublicacaoIntegracaoEnviada of Service JURA211

WSMETHOD ConsultarPublicacaoIntegracaoEnviada WSSEND cLogin,cData,cdiario WSRECEIVE oWSConsultarPublicacaoIntegracaoEnviadaResult WSCLIENT JURA211
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultarPublicacaoIntegracaoEnviada xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Data", ::cData, cData , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("diario", ::cdiario, cdiario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConsultarPublicacaoIntegracaoEnviada>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/ConsultarPublicacaoIntegracaoEnviada",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv('MV_JKURL',.T.,""))

::Init()
::oWSConsultarPublicacaoIntegracaoEnviadaResult :=  WSAdvValue( oXmlRet,"_CONSULTARPUBLICACAOINTEGRACAOENVIADARESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultarQuantidadePublicacaoEnviadaIntegracao of Service JURA211

WSMETHOD ConsultarQuantidadePublicacaoEnviadaIntegracao WSSEND cLogin,cdata WSRECEIVE oWSConsultarQuantidadePublicacaoEnviadaIntegracaoResult WSCLIENT JURA211
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultarQuantidadePublicacaoEnviadaIntegracao xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("data", ::cdata, cdata , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConsultarQuantidadePublicacaoEnviadaIntegracao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/ConsultarQuantidadePublicacaoEnviadaIntegracao",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv('MV_JKURL',.T.,""))

::Init()
::oWSConsultarQuantidadePublicacaoEnviadaIntegracaoResult :=  WSAdvValue( oXmlRet,"_CONSULTARQUANTIDADEPUBLICACAOENVIADAINTEGRACAORESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultarPublicacaoIntegracao of Service JURA211

WSMETHOD ConsultarPublicacaoIntegracao WSSEND cLogin WSRECEIVE oWSConsultarPublicacaoIntegracaoResult WSCLIENT JURA211
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultarPublicacaoIntegracao xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConsultarPublicacaoIntegracao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/ConsultarPublicacaoIntegracao",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv('MV_JKURL',.T.,""))

::Init()
::oWSConsultarPublicacaoIntegracaoResult :=  WSAdvValue( oXmlRet,"_CONSULTARPUBLICACAOINTEGRACAORESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultarPublicacao of Service JURA211

WSMETHOD ConsultarPublicacao WSSEND cDiario,cDivisaoDiario,cData,cLogin WSRECEIVE oWSConsultarPublicacaoResult WSCLIENT JURA211
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultarPublicacao xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("Diario", ::cDiario, cDiario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DivisaoDiario", ::cDivisaoDiario, cDivisaoDiario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Data", ::cData, cData , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConsultarPublicacao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/ConsultarPublicacao",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv('MV_JKURL',.T.,""))

::Init()
::oWSConsultarPublicacaoResult :=  WSAdvValue( oXmlRet,"_CONSULTARPUBLICACAORESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultarPublicacao2015 of Service JURA211

WSMETHOD ConsultarPublicacao2015 WSSEND cDiario,cDivisaoDiario,cData,cLogin WSRECEIVE oWSConsultarPublicacao2015Result WSCLIENT JURA211
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultarPublicacao2015 xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("Diario", ::cDiario, cDiario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DivisaoDiario", ::cDivisaoDiario, cDivisaoDiario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Data", ::cData, cData , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConsultarPublicacao2015>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/ConsultarPublicacao2015",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv('MV_JKURL',.T.,""))

::Init()
::oWSConsultarPublicacao2015Result :=  WSAdvValue( oXmlRet,"_CONSULTARPUBLICACAO2015RESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CapturarPublicacoes of Service JURA211

WSMETHOD CapturarPublicacoes WSSEND cLogin WSRECEIVE oWSCapturarPublicacoesResult WSCLIENT JURA211
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CapturarPublicacoes xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</CapturarPublicacoes>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/CapturarPublicacoes",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv('MV_JKURL',.T.,""))

::Init()
::oWSCapturarPublicacoesResult :=  WSAdvValue( oXmlRet,"_CAPTURARPUBLICACOESRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

Self:oXmlRet := oXmlRet
//oXmlRet := NIL
Return .T.

// WSDL Method CapturarPublicacoesList of Service JURA211

WSMETHOD CapturarPublicacoesList WSSEND cLogin WSRECEIVE oWSCapturarPublicacoesListResult WSCLIENT JURA211
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CapturarPublicacoesList xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</CapturarPublicacoesList>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/CapturarPublicacoesList",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv('MV_JKURL',.T.,""))

::Init()
::oWSCapturarPublicacoesListResult:SoapRecv( WSAdvValue( oXmlRet,"_CAPTURARPUBLICACOESLISTRESPONSE:_CAPTURARPUBLICACOESLISTRESULT","ArrayOfPublicacoes",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AtualizarCapturarPublicacoes of Service JURA211

WSMETHOD AtualizarCapturarPublicacoes WSSEND BYREF oWSds WSRECEIVE lAtualizarCapturarPublicacoesResult WSCLIENT JURA211
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AtualizarCapturarPublicacoes xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("ds", ::oWSds, oWSds , "SCHEMA", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AtualizarCapturarPublicacoes>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/AtualizarCapturarPublicacoes",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv('MV_JKURL',.T.,""))

::Init()
::lAtualizarCapturarPublicacoesResult :=  WSAdvValue( oXmlRet,"_ATUALIZARCAPTURARPUBLICACOESRESPONSE:_ATUALIZARCAPTURARPUBLICACOESRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::oWSds              :=  WSAdvValue( oXmlRet,"_ATUALIZARCAPTURARPUBLICACOESRESPONSE","SCHEMA",NIL,NIL,NIL,"O",@oWSds,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaPublicacaoNovas of Service JURA211

WSMETHOD ConsultaPublicacaoNovas WSSEND cDiario,cDivisaoDiario,cLogin WSRECEIVE oWSConsultaPublicacaoNovasResult WSCLIENT JURA211
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaPublicacaoNovas xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("Diario", ::cDiario, cDiario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DivisaoDiario", ::cDivisaoDiario, cDivisaoDiario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConsultaPublicacaoNovas>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/ConsultaPublicacaoNovas",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv('MV_JKURL',.T.,""))

::Init()
::oWSConsultaPublicacaoNovasResult :=  WSAdvValue( oXmlRet,"_CONSULTAPUBLICACAONOVASRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaPublicacaoId of Service JURA211

WSMETHOD ConsultaPublicacaoId WSSEND nidProcesso,cDiario,cDivisaoDiario,cLogin,csenha WSRECEIVE oWSConsultaPublicacaoIdResult WSCLIENT JURA211
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaPublicacaoId xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("idProcesso", ::nidProcesso, nidProcesso , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Diario", ::cDiario, cDiario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DivisaoDiario", ::cDivisaoDiario, cDivisaoDiario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConsultaPublicacaoId>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/ConsultaPublicacaoId",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv('MV_JKURL',.T.,""))

::Init()
::oWSConsultaPublicacaoIdResult :=  WSAdvValue( oXmlRet,"_CONSULTAPUBLICACAOIDRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CarregarDiarios of Service JURA211

WSMETHOD CarregarDiarios WSSEND NULLPARAM WSRECEIVE oWSCarregarDiariosResult WSCLIENT JURA211
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CarregarDiarios xmlns="http://tempuri.org/">'
cSoap += "</CarregarDiarios>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/CarregarDiarios",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv('MV_JKURL',.T.,""))

::Init()
::oWSCarregarDiariosResult :=  WSAdvValue( oXmlRet,"_CARREGARDIARIOSRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CarregarDivisaoDiario of Service JURA211

WSMETHOD CarregarDivisaoDiario WSSEND cdescricaoDiario WSRECEIVE oWSCarregarDivisaoDiarioResult WSCLIENT JURA211
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CarregarDivisaoDiario xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("descricaoDiario", ::cdescricaoDiario, cdescricaoDiario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</CarregarDivisaoDiario>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/CarregarDivisaoDiario",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv('MV_JKURL',.T.,""))

::Init()
::oWSCarregarDivisaoDiarioResult :=  WSAdvValue( oXmlRet,"_CARREGARDIVISAODIARIORESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AtualizarCapturaPublicacoesPorId of Service JURA211

WSMETHOD AtualizarCapturaPublicacoesPorId WSSEND oWSListaId WSRECEIVE lAtualizarCapturaPublicacoesPorIdResult WSCLIENT JURA211
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AtualizarCapturaPublicacoesPorId xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("ListaId", ::oWSListaId, oWSListaId , "ArrayOfCControleID", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AtualizarCapturaPublicacoesPorId>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/AtualizarCapturaPublicacoesPorId",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv('MV_JKURL',.T.,""))

::Init()
::lAtualizarCapturaPublicacoesPorIdResult :=  WSAdvValue( oXmlRet,"_ATUALIZARCAPTURAPUBLICACOESPORIDRESPONSE:_ATUALIZARCAPTURAPUBLICACOESPORIDRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RecuperarPublicacaoPorID of Service JURA211

WSMETHOD RecuperarPublicacaoPorID WSSEND nIdProcesso WSRECEIVE oWSRecuperarPublicacaoPorIDResult WSCLIENT JURA211
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RecuperarPublicacaoPorID xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("IdProcesso", ::nIdProcesso, nIdProcesso , "int", .T. , .F., 0 , NIL, .F.) 
cSoap += "</RecuperarPublicacaoPorID>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/RecuperarPublicacaoPorID",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	SuperGetMv('MV_JKURL',.T.,""))

::Init()
::oWSRecuperarPublicacaoPorIDResult :=  WSAdvValue( oXmlRet,"_RECUPERARPUBLICACAOPORIDRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ArrayOfPublicacoes

WSSTRUCT Service1_ArrayOfPublicacoes
	WSDATA   oWSPublicacoes            AS Service1_Publicacoes OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service1_ArrayOfPublicacoes
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service1_ArrayOfPublicacoes
	::oWSPublicacoes       := {} // Array Of  Service1_PUBLICACOES():New()
Return

WSMETHOD CLONE WSCLIENT Service1_ArrayOfPublicacoes
	Local oClone := Service1_ArrayOfPublicacoes():NEW()
	oClone:oWSPublicacoes := NIL
	If ::oWSPublicacoes <> NIL 
		oClone:oWSPublicacoes := {}
		aEval( ::oWSPublicacoes , { |x| aadd( oClone:oWSPublicacoes , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service1_ArrayOfPublicacoes
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_PUBLICACOES","Publicacoes",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSPublicacoes , Service1_Publicacoes():New() )
			::oWSPublicacoes[len(::oWSPublicacoes)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfCControleID

WSSTRUCT Service1_ArrayOfCControleID
	WSDATA   oWSCControleID            AS Service1_CControleID OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service1_ArrayOfCControleID
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service1_ArrayOfCControleID
	::oWSCControleID       := {} // Array Of  Service1_CCONTROLEID():New()
Return

WSMETHOD CLONE WSCLIENT Service1_ArrayOfCControleID
	Local oClone := Service1_ArrayOfCControleID():NEW()
	oClone:oWSCControleID := NIL
	If ::oWSCControleID <> NIL 
		oClone:oWSCControleID := {}
		aEval( ::oWSCControleID , { |x| aadd( oClone:oWSCControleID , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service1_ArrayOfCControleID
	Local cSoap := ""
	aEval( ::oWSCControleID , {|x| cSoap := cSoap  +  WSSoapValue("CControleID", x , x , "CControleID", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure Publicacoes

WSSTRUCT Service1_Publicacoes
	WSDATA   nIdProcesso               AS int
	WSDATA   cTexto                    AS string OPTIONAL
	WSDATA   cVara                     AS string OPTIONAL
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   cData                     AS string OPTIONAL
	WSDATA   cPartes                   AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cProcesso                 AS string OPTIONAL
	WSDATA   cJustica                  AS string OPTIONAL
	WSDATA   cEstado                   AS string OPTIONAL
	WSDATA   cForum                    AS string OPTIONAL
	WSDATA   cPagina                   AS string OPTIONAL
	WSDATA   cDiario                   AS string OPTIONAL
	WSDATA   nCodigoDiario             AS int
	WSDATA   nCodigoDivisaoDiario      AS int
	WSDATA   nCodigoTermoPesquisa      AS int
	WSDATA   cDataDiario               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service1_Publicacoes
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service1_Publicacoes
Return

WSMETHOD CLONE WSCLIENT Service1_Publicacoes
	Local oClone := Service1_Publicacoes():NEW()
	oClone:nIdProcesso          := ::nIdProcesso
	oClone:cTexto               := ::cTexto
	oClone:cVara                := ::cVara
	oClone:cCodigo              := ::cCodigo
	oClone:cData                := ::cData
	oClone:cPartes              := ::cPartes
	oClone:cNome                := ::cNome
	oClone:cProcesso            := ::cProcesso
	oClone:cJustica             := ::cJustica
	oClone:cEstado              := ::cEstado
	oClone:cForum               := ::cForum
	oClone:cPagina              := ::cPagina
	oClone:cDiario              := ::cDiario
	oClone:nCodigoDiario        := ::nCodigoDiario
	oClone:nCodigoDivisaoDiario := ::nCodigoDivisaoDiario
	oClone:nCodigoTermoPesquisa := ::nCodigoTermoPesquisa
	oClone:cDataDiario          := ::cDataDiario
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service1_Publicacoes
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nIdProcesso        :=  WSAdvValue( oResponse,"_IDPROCESSO","int",NIL,"Property nIdProcesso as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cTexto             :=  WSAdvValue( oResponse,"_TEXTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cVara              :=  WSAdvValue( oResponse,"_VARA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPartes            :=  WSAdvValue( oResponse,"_PARTES","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cProcesso          :=  WSAdvValue( oResponse,"_PROCESSO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cJustica           :=  WSAdvValue( oResponse,"_JUSTICA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEstado            :=  WSAdvValue( oResponse,"_ESTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cForum             :=  WSAdvValue( oResponse,"_FORUM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPagina            :=  WSAdvValue( oResponse,"_PAGINA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDiario            :=  WSAdvValue( oResponse,"_DIARIO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nCodigoDiario      :=  WSAdvValue( oResponse,"_CODIGODIARIO","int",NIL,"Property nCodigoDiario as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nCodigoDivisaoDiario :=  WSAdvValue( oResponse,"_CODIGODIVISAODIARIO","int",NIL,"Property nCodigoDivisaoDiario as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nCodigoTermoPesquisa :=  WSAdvValue( oResponse,"_CODIGOTERMOPESQUISA","int",NIL,"Property nCodigoTermoPesquisa as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDataDiario        :=  WSAdvValue( oResponse,"_DATADIARIO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure CControleID

WSSTRUCT Service1_CControleID
	WSDATA   nCodigoTermoPesquisa      AS int
	WSDATA   nCodigoDiario             AS int
	WSDATA   nCodigoDivisaoDiario      AS int
	WSDATA   nIdProcesso               AS int
	WSDATA   cData                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service1_CControleID
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service1_CControleID
Return

WSMETHOD CLONE WSCLIENT Service1_CControleID
	Local oClone := Service1_CControleID():NEW()
	oClone:nCodigoTermoPesquisa := ::nCodigoTermoPesquisa
	oClone:nCodigoDiario        := ::nCodigoDiario
	oClone:nCodigoDivisaoDiario := ::nCodigoDivisaoDiario
	oClone:nIdProcesso          := ::nIdProcesso
	oClone:cData                := ::cData
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service1_CControleID
	Local cSoap := ""
	cSoap += WSSoapValue("CodigoTermoPesquisa", ::nCodigoTermoPesquisa, ::nCodigoTermoPesquisa , "int", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CodigoDiario", ::nCodigoDiario, ::nCodigoDiario , "int", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CodigoDivisaoDiario", ::nCodigoDivisaoDiario, ::nCodigoDivisaoDiario , "int", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("IdProcesso", ::nIdProcesso, ::nIdProcesso , "int", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Data", ::cData, ::cData , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

//-------------------------------------------------------------------
/*/{Protheus.doc} J211AtuPub
Função para dar baixa nas publicações recebidas da Kurier


@Return lRet retorna true se as publicações foram baixadas com sucesso, para
não serem enviadas novamente

@author André Spirigoni Pinto
@since 04/04/18
@version 2.0
/*/
//-------------------------------------------------------------------

Function J211AtuPub(aBxPubl)
Local oWS                := JURA211():New()
Local oWS:oWSListaId     := Service1_ARRAYOFCCONTROLEID():New()
Local nX := 0
Local lRet := .T.

For nX := 1 To Len( aBxPubl )

    AADD( oWS:oWSListaId:oWsCControleId, WSClassNew("Service1_CControleID") )

    aTail(oWS:oWSListaId:oWsCControleId):nCodigoTermoPesquisa     := aBxPubl[nX][4]
    aTail(oWS:oWSListaId:oWsCControleId):nCodigoDiario            := aBxPubl[nX][2]
    aTail(oWS:oWSListaId:oWsCControleId):nCodigoDivisaoDiario     := aBxPubl[nX][3]
    aTail(oWS:oWSListaId:oWsCControleId):nIdProcesso              := val(aBxPubl[nX][1])
    aTail(oWS:oWSListaId:oWsCControleId):cData                    := aBxPubl[nX][5]

Next

// Executa a baixa por lote
oWS:AtualizarCapturaPublicacoesPorId()

// Retorno da baixa por lote
If oWS:lAtualizarCapturaPublicacoesPorIdResult != Nil .And. oWS:lAtualizarCapturaPublicacoesPorIdResult
	lRet     := .T.
EndIf

Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} ClearMem
Função para Limpar dados da memoria de objetos executados

@param oObj Objeto que sera Limpo durante a execução 

@author André Spirigoni Pinto
@since 04/04/18
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ClearMem(oObj)
Local i
Local aArr
Local cType := ValType(oObj)

If cType == 'O'
    aArr := ClassDataArr(oObj)
    For i := 1 To Len(aArr)
        ClearMem(aArr[i][2])
        aArr[i][2] := NIL
        Asize(aArr[i], 0)
    Next
    Asize(aArr, 0)
    FreeObj(oObj)

ElseIf cType == 'A'
    For i := 1 To Len(oObj)
        ClearMem(oObj[i])
    Next
    Asize(oObj, 0)
EndIf
Return
