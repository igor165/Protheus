#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://homolog.totvs.reserve.com.br/ReserveXml300/Pedidos.asmx?WSDL
Gerado em        12/06/13 10:48:08
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

Function Fina661a() ; Return

/* -------------------------------------------------------------------------------
WSDL Service WSPedidos
------------------------------------------------------------------------------- */

WSCLIENT WSPedidos

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ConsultarPedidos
	WSMETHOD ConfirmarLote
	WSMETHOD MarcarPedidos
	WSMETHOD InserirItemHistorico

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSConsultarPedidosRQ     AS Pedidos_ConsultarPedidosRQ
	WSDATA   oWSConsultarPedidosResult AS Pedidos_ConsultarPedidosRS
	WSDATA   oWSConfirmarLoteRQ        AS Pedidos_ConfirmarLoteRQ
	WSDATA   oWSConfirmarLoteResult    AS Pedidos_ConfirmarLoteRS
	WSDATA   oWSMarcarPedidoRQ         AS Pedidos_MarcarPedidoRQ
	WSDATA   oWSMarcarPedidosResult    AS Pedidos_MarcarPedidoRS
	WSDATA   oWSInserirItemHistoricoRQ AS Pedidos_InserirItemHistoricoRQ
	WSDATA   oWSInserirItemHistoricoResult AS Pedidos_InserirItemHistoricoRS

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSPedidos
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20130625] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
If val(right(GetWSCVer(),8)) < 1.040504
	UserException("O Código-Fonte Client atual requer a versão de Lib para WebServices igual ou superior a ADVPL WSDL Client 1.040504. Atualize o repositório ou gere o Código-Fonte novamente utilizando o repositório atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSPedidos
	::oWSConsultarPedidosRQ := Pedidos_CONSULTARPEDIDOSRQ():New()
	::oWSConsultarPedidosResult := Pedidos_CONSULTARPEDIDOSRS():New()
	::oWSConfirmarLoteRQ := Pedidos_CONFIRMARLOTERQ():New()
	::oWSConfirmarLoteResult := Pedidos_CONFIRMARLOTERS():New()
	::oWSMarcarPedidoRQ  := Pedidos_MARCARPEDIDORQ():New()
	::oWSMarcarPedidosResult := Pedidos_MARCARPEDIDORS():New()
	::oWSInserirItemHistoricoRQ := Pedidos_INSERIRITEMHISTORICORQ():New()
	::oWSInserirItemHistoricoResult := Pedidos_INSERIRITEMHISTORICORS():New()
Return

WSMETHOD RESET WSCLIENT WSPedidos
	::oWSConsultarPedidosRQ := NIL 
	::oWSConsultarPedidosResult := NIL 
	::oWSConfirmarLoteRQ := NIL 
	::oWSConfirmarLoteResult := NIL 
	::oWSMarcarPedidoRQ  := NIL 
	::oWSMarcarPedidosResult := NIL 
	::oWSInserirItemHistoricoRQ := NIL 
	::oWSInserirItemHistoricoResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSPedidos
Local oClone := WSPedidos():New()
	oClone:_URL          := ::_URL 
	oClone:oWSConsultarPedidosRQ :=  IIF(::oWSConsultarPedidosRQ = NIL , NIL ,::oWSConsultarPedidosRQ:Clone() )
	oClone:oWSConsultarPedidosResult :=  IIF(::oWSConsultarPedidosResult = NIL , NIL ,::oWSConsultarPedidosResult:Clone() )
	oClone:oWSConfirmarLoteRQ :=  IIF(::oWSConfirmarLoteRQ = NIL , NIL ,::oWSConfirmarLoteRQ:Clone() )
	oClone:oWSConfirmarLoteResult :=  IIF(::oWSConfirmarLoteResult = NIL , NIL ,::oWSConfirmarLoteResult:Clone() )
	oClone:oWSMarcarPedidoRQ :=  IIF(::oWSMarcarPedidoRQ = NIL , NIL ,::oWSMarcarPedidoRQ:Clone() )
	oClone:oWSMarcarPedidosResult :=  IIF(::oWSMarcarPedidosResult = NIL , NIL ,::oWSMarcarPedidosResult:Clone() )
	oClone:oWSInserirItemHistoricoRQ :=  IIF(::oWSInserirItemHistoricoRQ = NIL , NIL ,::oWSInserirItemHistoricoRQ:Clone() )
	oClone:oWSInserirItemHistoricoResult :=  IIF(::oWSInserirItemHistoricoResult = NIL , NIL ,::oWSInserirItemHistoricoResult:Clone() )
Return oClone

// WSDL Method ConsultarPedidos of Service WSPedidos

WSMETHOD ConsultarPedidos WSSEND oWSConsultarPedidosRQ WSRECEIVE oWSConsultarPedidosResult WSCLIENT WSPedidos
Local cSoap := "" , oXmlRet                      
Local cUrlAmb   := SuperGetMv("MV_RESAMB",,"")

cUrlAmb += "/ReserveXml300/Pedidos.asmx"

BEGIN WSMETHOD

cSoap += '<ConsultarPedidos xmlns="http://www.reserve.com.br/ReserveXML300/">'
cSoap += WSSoapValue("ConsultarPedidosRQ", ::oWSConsultarPedidosRQ, oWSConsultarPedidosRQ , "ConsultarPedidosRQ", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConsultarPedidos>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.reserve.com.br/ReserveXML300/ConsultarPedidos",; 
	"DOCUMENT","http://www.reserve.com.br/ReserveXML300/",,,; 
	cUrlAmb)

::Init()
::oWSConsultarPedidosResult:SoapRecv( WSAdvValue( oXmlRet,"_CONSULTARPEDIDOSRESPONSE:_CONSULTARPEDIDOSRESULT","ConsultarPedidosRS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConfirmarLote of Service WSPedidos

WSMETHOD ConfirmarLote WSSEND oWSConfirmarLoteRQ WSRECEIVE oWSConfirmarLoteResult WSCLIENT WSPedidos
Local cSoap := "" , oXmlRet
Local cUrlAmb   := SuperGetMv("MV_RESAMB",,"")

cUrlAmb += "/ReserveXml300/Pedidos.asmx"

BEGIN WSMETHOD

cSoap += '<ConfirmarLote xmlns="http://www.reserve.com.br/ReserveXML300/">'
cSoap += WSSoapValue("ConfirmarLoteRQ", ::oWSConfirmarLoteRQ, oWSConfirmarLoteRQ , "ConfirmarLoteRQ", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConfirmarLote>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.reserve.com.br/ReserveXML300/ConfirmarLote",; 
	"DOCUMENT","http://www.reserve.com.br/ReserveXML300/",,,; 
	cUrlAmb)

::Init()
::oWSConfirmarLoteResult:SoapRecv( WSAdvValue( oXmlRet,"_CONFIRMARLOTERESPONSE:_CONFIRMARLOTERESULT","ConfirmarLoteRS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL

Return .T.

// WSDL Method MarcarPedidos of Service WSPedidos

WSMETHOD MarcarPedidos WSSEND oWSMarcarPedidoRQ WSRECEIVE oWSMarcarPedidosResult WSCLIENT WSPedidos
Local cSoap := "" , oXmlRet
Local cUrlAmb   := SuperGetMv("MV_RESAMB",,"")

cUrlAmb += "/ReserveXml300/Pedidos.asmx"

BEGIN WSMETHOD

cSoap += '<MarcarPedidos xmlns="http://www.reserve.com.br/ReserveXML300/">'
cSoap += WSSoapValue("MarcarPedidoRQ", ::oWSMarcarPedidoRQ, oWSMarcarPedidoRQ , "MarcarPedidoRQ", .F. , .F., 0 , NIL, .F.) 
cSoap += "</MarcarPedidos>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.reserve.com.br/ReserveXML300/MarcarPedidos",; 
	"DOCUMENT","http://www.reserve.com.br/ReserveXML300/",,,; 
	cUrlAmb)

::Init()
::oWSMarcarPedidosResult:SoapRecv( WSAdvValue( oXmlRet,"_MARCARPEDIDOSRESPONSE:_MARCARPEDIDOSRESULT","MarcarPedidoRS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method InserirItemHistorico of Service WSPedidos

WSMETHOD InserirItemHistorico WSSEND oWSInserirItemHistoricoRQ WSRECEIVE oWSInserirItemHistoricoResult WSCLIENT WSPedidos
Local cSoap := "" , oXmlRet
Local cUrlAmb   := SuperGetMv("MV_RESAMB",,"")

cUrlAmb += "/ReserveXml300/Pedidos.asmx"


BEGIN WSMETHOD

cSoap += '<InserirItemHistorico xmlns="http://www.reserve.com.br/ReserveXML300/">'
cSoap += WSSoapValue("InserirItemHistoricoRQ", ::oWSInserirItemHistoricoRQ, oWSInserirItemHistoricoRQ , "InserirItemHistoricoRQ", .F. , .F., 0 , NIL, .F.) 
cSoap += "</InserirItemHistorico>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.reserve.com.br/ReserveXML300/InserirItemHistorico",; 
	"DOCUMENT","http://www.reserve.com.br/ReserveXML300/",,,; 
	cUrlAmb)

::Init()
::oWSInserirItemHistoricoResult:SoapRecv( WSAdvValue( oXmlRet,"_INSERIRITEMHISTORICORESPONSE:_INSERIRITEMHISTORICORESULT","InserirItemHistoricoRS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ConsultarPedidosRQ

WSSTRUCT Pedidos_ConsultarPedidosRQ
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   cDataInicial              AS dateTime OPTIONAL
	WSDATA   oWSTipoData               AS Pedidos_TipoData OPTIONAL
	WSDATA   oWSIDPedidos              AS Pedidos_ArrayOfInt OPTIONAL
	WSDATA   oWSIDGrupos               AS Pedidos_ArrayOfInt1 OPTIONAL
	WSDATA   oWSEmpresas               AS Pedidos_ArrayOfString OPTIONAL
	WSDATA   nTipoServico              AS int OPTIONAL
	WSDATA   oWSStatus                 AS Pedidos_StatusPedido
	WSDATA   oWSStatusCAV              AS Pedidos_StatusCAV
	WSDATA   nDias                     AS int OPTIONAL
	WSDATA   oWSTipoRetorno            AS Pedidos_TipoRetorno
	WSDATA   oWSExcluido               AS Pedidos_StatusExclusao
	WSDATA   oWSMigrados               AS Pedidos_StatusMigracao
	WSDATA   nQtdeRetorno              AS int
	WSDATA   cMarcacaoCondicao         AS string OPTIONAL
	WSDATA   cMarcacaoValor            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_ConsultarPedidosRQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_ConsultarPedidosRQ
	::oWSStatus  	:= Pedidos_StatusPedido():NEW()
	::oWSStatusCAV  := Pedidos_StatusCAV():NEW()
	::oWSTipoRetorno :=  Pedidos_TipoRetorno():NEW()
	::oWSExcluido :=  Pedidos_StatusExclusao():NEW()
	::oWSMigrados :=  Pedidos_StatusMigracao():NEW()
Return

WSMETHOD CLONE WSCLIENT Pedidos_ConsultarPedidosRQ
	Local oClone := Pedidos_ConsultarPedidosRQ():NEW()
	oClone:cSessao              := ::cSessao
	oClone:cDataInicial         := ::cDataInicial
	oClone:oWSTipoData          := IIF(::oWSTipoData = NIL , NIL , ::oWSTipoData:Clone() )
	oClone:oWSIDPedidos         := IIF(::oWSIDPedidos = NIL , NIL , ::oWSIDPedidos:Clone() )
	oClone:oWSIDGrupos          := IIF(::oWSIDGrupos = NIL , NIL , ::oWSIDGrupos:Clone() )
	oClone:oWSEmpresas          := IIF(::oWSEmpresas = NIL , NIL , ::oWSEmpresas:Clone() )
	oClone:nTipoServico         := ::nTipoServico
	oClone:oWSStatus            := IIF(::oWSStatus = NIL , NIL , ::oWSStatus:Clone() )
	oClone:oWSStatusCAV         := IIF(::oWSStatusCAV = NIL , NIL , ::oWSStatusCAV:Clone() )
	oClone:nDias                := ::nDias
	oClone:oWSTipoRetorno       := IIF(::oWSTipoRetorno = NIL , NIL , ::oWSTipoRetorno:Clone() )
	oClone:oWSExcluido          := IIF(::oWSExcluido = NIL , NIL , ::oWSExcluido:Clone() )
	oClone:oWSMigrados          := IIF(::oWSMigrados = NIL , NIL , ::oWSMigrados:Clone() )
	oClone:nQtdeRetorno         := ::nQtdeRetorno
	oClone:cMarcacaoCondicao    := ::cMarcacaoCondicao
	oClone:cMarcacaoValor       := ::cMarcacaoValor
Return oClone

WSMETHOD SOAPSEND WSCLIENT Pedidos_ConsultarPedidosRQ
	Local cSoap := ""
	cSoap += WSSoapValue("Sessao", ::cSessao, ::cSessao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("DataInicial", ::cDataInicial, ::cDataInicial , "dateTime", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("TipoData", ::oWSTipoData, ::oWSTipoData , "TipoData", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("IDPedidos", ::oWSIDPedidos, ::oWSIDPedidos , "ArrayOfInt", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("IDGrupos", ::oWSIDGrupos, ::oWSIDGrupos , "ArrayOfInt1", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Empresas", ::oWSEmpresas, ::oWSEmpresas , "ArrayOfString", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("TipoServico", ::nTipoServico, ::nTipoServico , "int", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Status", ::oWSStatus, ::oWSStatus , "StatusPedido", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("StatusCAV", ::oWSStatusCAV, ::oWSStatusCAV , "StatusCAV", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Dias", ::nDias, ::nDias , "int", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("TipoRetorno", ::oWSTipoRetorno, ::oWSTipoRetorno , "TipoRetorno", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Excluido", ::oWSExcluido, ::oWSExcluido , "StatusExclusao", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Migrados", ::oWSMigrados, ::oWSMigrados , "StatusMigracao", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("QtdeRetorno", ::nQtdeRetorno, ::nQtdeRetorno , "int", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("MarcacaoCondicao", ::cMarcacaoCondicao, ::cMarcacaoCondicao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("MarcacaoValor", ::cMarcacaoValor, ::cMarcacaoValor , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ConsultarPedidosRS

WSSTRUCT Pedidos_ConsultarPedidosRS
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   nNumeroLote               AS int OPTIONAL
	WSDATA   oWSErros                  AS Pedidos_ArrayOfErro OPTIONAL
	WSDATA   oWSPedidos                AS Pedidos_ArrayOfPedido OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_ConsultarPedidosRS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_ConsultarPedidosRS
Return

WSMETHOD CLONE WSCLIENT Pedidos_ConsultarPedidosRS
	Local oClone := Pedidos_ConsultarPedidosRS():NEW()
	oClone:cSessao              := ::cSessao
	oClone:nNumeroLote          := ::nNumeroLote
	oClone:oWSErros             := IIF(::oWSErros = NIL , NIL , ::oWSErros:Clone() )
	oClone:oWSPedidos           := IIF(::oWSPedidos = NIL , NIL , ::oWSPedidos:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_ConsultarPedidosRS
	Local oNode3
	Local oNode4
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSessao            :=  WSAdvValue( oResponse,"_SESSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nNumeroLote        :=  WSAdvValue( oResponse,"_NUMEROLOTE","int",NIL,NIL,NIL,"N",NIL,NIL) 
	oNode3 :=  WSAdvValue( oResponse,"_ERROS","ArrayOfErro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode3 != NIL
		::oWSErros := Pedidos_ArrayOfErro():New()
		::oWSErros:SoapRecv(oNode3)
	EndIf
	oNode4 :=  WSAdvValue( oResponse,"_PEDIDOS","ArrayOfPedido",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode4 != NIL
		::oWSPedidos := Pedidos_ArrayOfPedido():New()
		::oWSPedidos:SoapRecv(oNode4)
	EndIf
Return

// WSDL Data Structure ConfirmarLoteRQ

WSSTRUCT Pedidos_ConfirmarLoteRQ
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   nNumeroLote               AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_ConfirmarLoteRQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_ConfirmarLoteRQ
Return

WSMETHOD CLONE WSCLIENT Pedidos_ConfirmarLoteRQ
	Local oClone := Pedidos_ConfirmarLoteRQ():NEW()
	oClone:cSessao              := ::cSessao
	oClone:nNumeroLote          := ::nNumeroLote
Return oClone

WSMETHOD SOAPSEND WSCLIENT Pedidos_ConfirmarLoteRQ
	Local cSoap := ""
	cSoap += WSSoapValue("Sessao", ::cSessao, ::cSessao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NumeroLote", ::nNumeroLote, ::nNumeroLote , "int", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ConfirmarLoteRS

WSSTRUCT Pedidos_ConfirmarLoteRS
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   nNumeroLote               AS int
	WSDATA   oWSErros                  AS Pedidos_ArrayOfErro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_ConfirmarLoteRS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_ConfirmarLoteRS
Return

WSMETHOD CLONE WSCLIENT Pedidos_ConfirmarLoteRS
	Local oClone := Pedidos_ConfirmarLoteRS():NEW()
	oClone:cSessao              := ::cSessao
	oClone:nNumeroLote          := ::nNumeroLote
	oClone:oWSErros             := IIF(::oWSErros = NIL , NIL , ::oWSErros:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_ConfirmarLoteRS
	Local oNode3
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSessao            :=  WSAdvValue( oResponse,"_SESSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nNumeroLote        :=  WSAdvValue( oResponse,"_NUMEROLOTE","int",NIL,"Property nNumeroLote as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode3 :=  WSAdvValue( oResponse,"_ERROS","ArrayOfErro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode3 != NIL
		::oWSErros := Pedidos_ArrayOfErro():New()
		::oWSErros:SoapRecv(oNode3)
	EndIf
Return

// WSDL Data Structure MarcarPedidoRQ

WSSTRUCT Pedidos_MarcarPedidoRQ
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSPedidos                AS Pedidos_ArrayOfInt2 OPTIONAL
	WSDATA   nMarca                    AS int
	WSDATA   cOBS                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_MarcarPedidoRQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_MarcarPedidoRQ
Return

WSMETHOD CLONE WSCLIENT Pedidos_MarcarPedidoRQ
	Local oClone := Pedidos_MarcarPedidoRQ():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSPedidos           := IIF(::oWSPedidos = NIL , NIL , ::oWSPedidos:Clone() )
	oClone:nMarca               := ::nMarca
	oClone:cOBS                 := ::cOBS
Return oClone

WSMETHOD SOAPSEND WSCLIENT Pedidos_MarcarPedidoRQ
	Local cSoap := ""
	cSoap += WSSoapValue("Sessao", ::cSessao, ::cSessao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Pedidos", ::oWSPedidos, ::oWSPedidos , "ArrayOfInt2", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Marca", ::nMarca, ::nMarca , "int", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("OBS", ::cOBS, ::cOBS , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure MarcarPedidoRS

WSSTRUCT Pedidos_MarcarPedidoRS
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSErros                  AS Pedidos_ArrayOfErro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_MarcarPedidoRS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_MarcarPedidoRS
Return

WSMETHOD CLONE WSCLIENT Pedidos_MarcarPedidoRS
	Local oClone := Pedidos_MarcarPedidoRS():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSErros             := IIF(::oWSErros = NIL , NIL , ::oWSErros:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_MarcarPedidoRS
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSessao            :=  WSAdvValue( oResponse,"_SESSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_ERROS","ArrayOfErro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSErros := Pedidos_ArrayOfErro():New()
		::oWSErros:SoapRecv(oNode2)
	EndIf
Return

// WSDL Data Structure InserirItemHistoricoRQ

WSSTRUCT Pedidos_InserirItemHistoricoRQ
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSItensHistorico         AS Pedidos_ArrayOfItemHistorico OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_InserirItemHistoricoRQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_InserirItemHistoricoRQ
Return

WSMETHOD CLONE WSCLIENT Pedidos_InserirItemHistoricoRQ
	Local oClone := Pedidos_InserirItemHistoricoRQ():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSItensHistorico    := IIF(::oWSItensHistorico = NIL , NIL , ::oWSItensHistorico:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Pedidos_InserirItemHistoricoRQ
	Local cSoap := ""
	cSoap += WSSoapValue("Sessao", ::cSessao, ::cSessao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ItensHistorico", ::oWSItensHistorico, ::oWSItensHistorico , "ArrayOfItemHistorico", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure InserirItemHistoricoRS

WSSTRUCT Pedidos_InserirItemHistoricoRS
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSErros                  AS Pedidos_ArrayOfErro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_InserirItemHistoricoRS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_InserirItemHistoricoRS
Return

WSMETHOD CLONE WSCLIENT Pedidos_InserirItemHistoricoRS
	Local oClone := Pedidos_InserirItemHistoricoRS():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSErros             := IIF(::oWSErros = NIL , NIL , ::oWSErros:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_InserirItemHistoricoRS
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSessao            :=  WSAdvValue( oResponse,"_SESSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_ERROS","ArrayOfErro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSErros := Pedidos_ArrayOfErro():New()
		::oWSErros:SoapRecv(oNode2)
	EndIf
Return

// WSDL Data Enumeration TipoData

WSSTRUCT Pedidos_TipoData
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_TipoData
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "0" )
	aadd(::aValueList , "1" )
	aadd(::aValueList , "2" )
	aadd(::aValueList , "3" )
	aadd(::aValueList , "4" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Pedidos_TipoData
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_TipoData
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Pedidos_TipoData
Local oClone := Pedidos_TipoData():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure ArrayOfInt

WSSTRUCT Pedidos_ArrayOfInt
	WSDATA   nIDPedido                 AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_ArrayOfInt
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_ArrayOfInt
	::nIDPedido            := {} // Array Of  0
Return

WSMETHOD CLONE WSCLIENT Pedidos_ArrayOfInt
	Local oClone := Pedidos_ArrayOfInt():NEW()
	oClone:nIDPedido            := IIf(::nIDPedido <> NIL , aClone(::nIDPedido) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Pedidos_ArrayOfInt
	Local cSoap := ""
	aEval( ::nIDPedido , {|x| cSoap := cSoap  +  WSSoapValue("IDPedido", x , x , "int", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfInt1

WSSTRUCT Pedidos_ArrayOfInt1
	WSDATA   nIDGrupo                  AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_ArrayOfInt1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_ArrayOfInt1
	::nIDGrupo             := {} // Array Of  0
Return

WSMETHOD CLONE WSCLIENT Pedidos_ArrayOfInt1
	Local oClone := Pedidos_ArrayOfInt1():NEW()
	oClone:nIDGrupo             := IIf(::nIDGrupo <> NIL , aClone(::nIDGrupo) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Pedidos_ArrayOfInt1
	Local cSoap := ""
	aEval( ::nIDGrupo , {|x| cSoap := cSoap  +  WSSoapValue("IDGrupo", x , x , "int", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfString

WSSTRUCT Pedidos_ArrayOfString
	WSDATA   cEmpresa                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_ArrayOfString
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_ArrayOfString
	::cEmpresa             := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT Pedidos_ArrayOfString
	Local oClone := Pedidos_ArrayOfString():NEW()
	oClone:cEmpresa             := IIf(::cEmpresa <> NIL , aClone(::cEmpresa) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Pedidos_ArrayOfString
	Local cSoap := ""
	aEval( ::cEmpresa , {|x| cSoap := cSoap  +  WSSoapValue("Empresa", x , x , "string", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Enumeration TipoRetorno

WSSTRUCT Pedidos_TipoRetorno
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_TipoRetorno
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "0" )
	aadd(::aValueList , "1" )
	aadd(::aValueList , "2" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Pedidos_TipoRetorno
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_TipoRetorno
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Pedidos_TipoRetorno
Local oClone := Pedidos_TipoRetorno():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration StatusExclusao

WSSTRUCT Pedidos_StatusExclusao
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_StatusExclusao
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "0" )
	aadd(::aValueList , "1" )
	aadd(::aValueList , "2" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Pedidos_StatusExclusao
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_StatusExclusao
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Pedidos_StatusExclusao
Local oClone := Pedidos_StatusExclusao():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration StatusMigracao

WSSTRUCT Pedidos_StatusMigracao
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_StatusMigracao
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "0" )
	aadd(::aValueList , "1" )
	aadd(::aValueList , "2" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Pedidos_StatusMigracao
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_StatusMigracao
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Pedidos_StatusMigracao
Local oClone := Pedidos_StatusMigracao():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure ArrayOfErro

WSSTRUCT Pedidos_ArrayOfErro
	WSDATA   oWSErro                   AS Pedidos_Erro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_ArrayOfErro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_ArrayOfErro
	::oWSErro              := {} // Array Of  Pedidos_ERRO():New()
Return

WSMETHOD CLONE WSCLIENT Pedidos_ArrayOfErro
	Local oClone := Pedidos_ArrayOfErro():NEW()
	oClone:oWSErro := NIL
	If ::oWSErro <> NIL 
		oClone:oWSErro := {}
		aEval( ::oWSErro , { |x| aadd( oClone:oWSErro , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_ArrayOfErro
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ERRO","Erro",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSErro , Pedidos_Erro():New() )
			::oWSErro[len(::oWSErro)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfPedido

WSSTRUCT Pedidos_ArrayOfPedido
	WSDATA   oWSPedido                 AS Pedidos_Pedido OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_ArrayOfPedido
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_ArrayOfPedido
	::oWSPedido            := {} // Array Of  Pedidos_PEDIDO():New()
Return

WSMETHOD CLONE WSCLIENT Pedidos_ArrayOfPedido
	Local oClone := Pedidos_ArrayOfPedido():NEW()
	oClone:oWSPedido := NIL
	If ::oWSPedido <> NIL 
		oClone:oWSPedido := {}
		aEval( ::oWSPedido , { |x| aadd( oClone:oWSPedido , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_ArrayOfPedido
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_PEDIDO","Pedido",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSPedido , Pedidos_Pedido():New() )
			::oWSPedido[len(::oWSPedido)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfInt2

WSSTRUCT Pedidos_ArrayOfInt2
	WSDATA   nPedido                   AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_ArrayOfInt2
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_ArrayOfInt2
	::nPedido              := {} // Array Of  0
Return

WSMETHOD CLONE WSCLIENT Pedidos_ArrayOfInt2
	Local oClone := Pedidos_ArrayOfInt2():NEW()
	oClone:nPedido              := IIf(::nPedido <> NIL , aClone(::nPedido) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Pedidos_ArrayOfInt2
	Local cSoap := ""
	aEval( ::nPedido , {|x| cSoap := cSoap  +  WSSoapValue("Pedido", x , x , "int", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfItemHistorico

WSSTRUCT Pedidos_ArrayOfItemHistorico
	WSDATA   oWSItemHistorico          AS Pedidos_ItemHistorico OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_ArrayOfItemHistorico
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_ArrayOfItemHistorico
	::oWSItemHistorico     := {} // Array Of  Pedidos_ITEMHISTORICO():New()
Return

WSMETHOD CLONE WSCLIENT Pedidos_ArrayOfItemHistorico
	Local oClone := Pedidos_ArrayOfItemHistorico():NEW()
	oClone:oWSItemHistorico := NIL
	If ::oWSItemHistorico <> NIL 
		oClone:oWSItemHistorico := {}
		aEval( ::oWSItemHistorico , { |x| aadd( oClone:oWSItemHistorico , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Pedidos_ArrayOfItemHistorico
	Local cSoap := ""
	aEval( ::oWSItemHistorico , {|x| cSoap := cSoap  +  WSSoapValue("ItemHistorico", x , x , "ItemHistorico", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure Erro

WSSTRUCT Pedidos_Erro
	WSDATA   cCodErro                  AS string OPTIONAL
	WSDATA   cMensagem                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_Erro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_Erro
Return

WSMETHOD CLONE WSCLIENT Pedidos_Erro
	Local oClone := Pedidos_Erro():NEW()
	oClone:cCodErro             := ::cCodErro
	oClone:cMensagem            := ::cMensagem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_Erro
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodErro           :=  WSAdvValue( oResponse,"_CODERRO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure Pedido

WSSTRUCT Pedidos_Pedido
	WSDATA   cEmpresa                  AS string OPTIONAL
	WSDATA   nIDPedido                 AS int
	WSDATA   nIDGrupo                  AS int OPTIONAL
	WSDATA   nIDRemarcacao             AS int OPTIONAL
	WSDATA   cJustificativaRemarcacao  AS string OPTIONAL
	WSDATA   nTipo                     AS int OPTIONAL
	WSDATA   cDataCriacao              AS dateTime OPTIONAL
	WSDATA   oWSStatus                 AS Pedidos_StatusPedido OPTIONAL
	WSDATA   oWSOrigemPedido           AS Pedidos_OrigemPedido OPTIONAL
	WSDATA   cDataExclusao             AS dateTime OPTIONAL
	WSDATA   lExcluido                 AS boolean OPTIONAL
	WSDATA   oWSSolicitante            AS Pedidos_Solicitante OPTIONAL
	WSDATA   oWSResponsavel            AS Pedidos_Responsavel OPTIONAL
	WSDATA   nTotalFee                 AS decimal OPTIONAL
	WSDATA   nFormaPgto                AS int OPTIONAL
	WSDATA   cIDCartaoParcial          AS string OPTIONAL
	WSDATA   cNumeroCartao             AS string OPTIONAL
	WSDATA   cCodAutorizacaoCartao     AS string OPTIONAL
	WSDATA   cEmpresaAFaturar          AS string OPTIONAL
	WSDATA   oWSEmissor                AS Pedidos_Emissor OPTIONAL
	WSDATA   oWSOrigemEmissao          AS Pedidos_OrigemEmissao
	WSDATA   cDataEmissao              AS dateTime OPTIONAL
	WSDATA   cDataAutorizacao          AS dateTime OPTIONAL
	WSDATA   oWSStatusAutorizacao      AS Pedidos_StatusAutorizacao OPTIONAL
	WSDATA   cCodLegendaAutorizacao    AS string OPTIONAL
	WSDATA   oWSAutorizador            AS Pedidos_Autorizador OPTIONAL
	WSDATA   oWSAutorizadores          AS Pedidos_ArrayOfAutorizador OPTIONAL
	WSDATA   cCCusto                   AS string OPTIONAL
	WSDATA   oWSCCustos                AS Pedidos_ArrayOfCCusto OPTIONAL
	WSDATA   cMotivo                   AS string OPTIONAL
	WSDATA   cProjeto                  AS string OPTIONAL
	WSDATA   cAtividade                AS string OPTIONAL
	WSDATA   cCampoExtra1              AS string OPTIONAL
	WSDATA   cCampoExtra2              AS string OPTIONAL
	WSDATA   cCampoExtra3              AS string OPTIONAL
	WSDATA   nMarcacao                 AS int OPTIONAL
	WSDATA   cMarcacaoOBS              AS string OPTIONAL
	WSDATA   cDataMigracao             AS dateTime OPTIONAL
	WSDATA   oWSPassageiros            AS Pedidos_ArrayOfPassageiro OPTIONAL
	WSDATA   oWSReservaEscolhida       AS Pedidos_Reserva OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_Pedido
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_Pedido
Return

WSMETHOD CLONE WSCLIENT Pedidos_Pedido
	Local oClone := Pedidos_Pedido():NEW()
	oClone:cEmpresa             := ::cEmpresa
	oClone:nIDPedido            := ::nIDPedido
	oClone:nIDGrupo             := ::nIDGrupo
	oClone:nIDRemarcacao        := ::nIDRemarcacao
	oClone:cJustificativaRemarcacao := ::cJustificativaRemarcacao
	oClone:nTipo                := ::nTipo
	oClone:cDataCriacao         := ::cDataCriacao
	oClone:oWSStatus            := IIF(::oWSStatus = NIL , NIL , ::oWSStatus:Clone() )
	oClone:oWSOrigemPedido      := IIF(::oWSOrigemPedido = NIL , NIL , ::oWSOrigemPedido:Clone() )
	oClone:cDataExclusao        := ::cDataExclusao
	oClone:lExcluido            := ::lExcluido
	oClone:oWSSolicitante       := IIF(::oWSSolicitante = NIL , NIL , ::oWSSolicitante:Clone() )
	oClone:oWSResponsavel       := IIF(::oWSResponsavel = NIL , NIL , ::oWSResponsavel:Clone() )
	oClone:nTotalFee            := ::nTotalFee
	oClone:nFormaPgto           := ::nFormaPgto
	oClone:cIDCartaoParcial     := ::cIDCartaoParcial
	oClone:cNumeroCartao        := ::cNumeroCartao
	oClone:cCodAutorizacaoCartao := ::cCodAutorizacaoCartao
	oClone:cEmpresaAFaturar     := ::cEmpresaAFaturar
	oClone:oWSEmissor           := IIF(::oWSEmissor = NIL , NIL , ::oWSEmissor:Clone() )
	oClone:oWSOrigemEmissao     := IIF(::oWSOrigemEmissao = NIL , NIL , ::oWSOrigemEmissao:Clone() )
	oClone:cDataEmissao         := ::cDataEmissao
	oClone:cDataAutorizacao     := ::cDataAutorizacao
	oClone:oWSStatusAutorizacao := IIF(::oWSStatusAutorizacao = NIL , NIL , ::oWSStatusAutorizacao:Clone() )
	oClone:cCodLegendaAutorizacao := ::cCodLegendaAutorizacao
	oClone:oWSAutorizador       := IIF(::oWSAutorizador = NIL , NIL , ::oWSAutorizador:Clone() )
	oClone:oWSAutorizadores     := IIF(::oWSAutorizadores = NIL , NIL , ::oWSAutorizadores:Clone() )
	oClone:cCCusto              := ::cCCusto
	oClone:oWSCCustos           := IIF(::oWSCCustos = NIL , NIL , ::oWSCCustos:Clone() )
	oClone:cMotivo              := ::cMotivo
	oClone:cProjeto             := ::cProjeto
	oClone:cAtividade           := ::cAtividade
	oClone:cCampoExtra1         := ::cCampoExtra1
	oClone:cCampoExtra2         := ::cCampoExtra2
	oClone:cCampoExtra3         := ::cCampoExtra3
	oClone:nMarcacao            := ::nMarcacao
	oClone:cMarcacaoOBS         := ::cMarcacaoOBS
	oClone:cDataMigracao        := ::cDataMigracao
	oClone:oWSPassageiros       := IIF(::oWSPassageiros = NIL , NIL , ::oWSPassageiros:Clone() )
	oClone:oWSReservaEscolhida  := IIF(::oWSReservaEscolhida = NIL , NIL , ::oWSReservaEscolhida:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_Pedido
	Local oNode8
	Local oNode9
	Local oNode12
	Local oNode13
	Local oNode20
	Local oNode21
	Local oNode24
	Local oNode26
	Local oNode27
	Local oNode29
	Local oNode39
	Local oNode40
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cEmpresa           :=  WSAdvValue( oResponse,"_EMPRESA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nIDPedido          :=  WSAdvValue( oResponse,"_IDPEDIDO","int",NIL,"Property nIDPedido as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nIDGrupo           :=  WSAdvValue( oResponse,"_IDGRUPO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nIDRemarcacao      :=  WSAdvValue( oResponse,"_IDREMARCACAO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cJustificativaRemarcacao :=  WSAdvValue( oResponse,"_JUSTIFICATIVAREMARCACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nTipo              :=  WSAdvValue( oResponse,"_TIPO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cDataCriacao       :=  WSAdvValue( oResponse,"_DATACRIACAO","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode8 :=  WSAdvValue( oResponse,"_STATUS","StatusPedido",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode8 != NIL
		::oWSStatus := Pedidos_StatusPedido():New()
		::oWSStatus:SoapRecv(oNode8)
	EndIf
	oNode9 :=  WSAdvValue( oResponse,"_ORIGEMPEDIDO","OrigemPedido",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode9 != NIL
		::oWSOrigemPedido := Pedidos_OrigemPedido():New()
		::oWSOrigemPedido:SoapRecv(oNode9)
	EndIf
	::cDataExclusao      :=  WSAdvValue( oResponse,"_DATAEXCLUSAO","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::lExcluido          :=  WSAdvValue( oResponse,"_EXCLUIDO","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	oNode12 :=  WSAdvValue( oResponse,"_SOLICITANTE","Solicitante",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode12 != NIL
		::oWSSolicitante := Pedidos_Solicitante():New()
		::oWSSolicitante:SoapRecv(oNode12)
	EndIf
	oNode13 :=  WSAdvValue( oResponse,"_RESPONSAVEL","Responsavel",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode13 != NIL
		::oWSResponsavel := Pedidos_Responsavel():New()
		::oWSResponsavel:SoapRecv(oNode13)
	EndIf
	::nTotalFee          :=  WSAdvValue( oResponse,"_TOTALFEE","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::nFormaPgto         :=  WSAdvValue( oResponse,"_FORMAPGTO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cIDCartaoParcial   :=  WSAdvValue( oResponse,"_IDCARTAOPARCIAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNumeroCartao      :=  WSAdvValue( oResponse,"_NUMEROCARTAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodAutorizacaoCartao :=  WSAdvValue( oResponse,"_CODAUTORIZACAOCARTAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEmpresaAFaturar   :=  WSAdvValue( oResponse,"_EMPRESAAFATURAR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode20 :=  WSAdvValue( oResponse,"_EMISSOR","Emissor",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode20 != NIL
		::oWSEmissor := Pedidos_Emissor():New()
		::oWSEmissor:SoapRecv(oNode20)
	EndIf
	oNode21 :=  WSAdvValue( oResponse,"_ORIGEMEMISSAO","OrigemEmissao",NIL,"Property oWSOrigemEmissao as tns:OrigemEmissao on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode21 != NIL
		::oWSOrigemEmissao := Pedidos_OrigemEmissao():New()
		::oWSOrigemEmissao:SoapRecv(oNode21)
	EndIf
	::cDataEmissao       :=  WSAdvValue( oResponse,"_DATAEMISSAO","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataAutorizacao   :=  WSAdvValue( oResponse,"_DATAAUTORIZACAO","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode24 :=  WSAdvValue( oResponse,"_STATUSAUTORIZACAO","StatusAutorizacao",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode24 != NIL
		::oWSStatusAutorizacao := Pedidos_StatusAutorizacao():New()
		::oWSStatusAutorizacao:SoapRecv(oNode24)
	EndIf
	::cCodLegendaAutorizacao :=  WSAdvValue( oResponse,"_CODLEGENDAAUTORIZACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode26 :=  WSAdvValue( oResponse,"_AUTORIZADOR","Autorizador",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode26 != NIL
		::oWSAutorizador := Pedidos_Autorizador():New()
		::oWSAutorizador:SoapRecv(oNode26)
	EndIf
	oNode27 :=  WSAdvValue( oResponse,"_AUTORIZADORES","ArrayOfAutorizador",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode27 != NIL
		::oWSAutorizadores := Pedidos_ArrayOfAutorizador():New()
		::oWSAutorizadores:SoapRecv(oNode27)
	EndIf
	::cCCusto            :=  WSAdvValue( oResponse,"_CCUSTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode29 :=  WSAdvValue( oResponse,"_CCUSTOS","ArrayOfCCusto",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode29 != NIL
		::oWSCCustos := Pedidos_ArrayOfCCusto():New()
		::oWSCCustos:SoapRecv(oNode29)
	EndIf
	::cMotivo            :=  WSAdvValue( oResponse,"_MOTIVO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cProjeto           :=  WSAdvValue( oResponse,"_PROJETO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cAtividade         :=  WSAdvValue( oResponse,"_ATIVIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCampoExtra1       :=  WSAdvValue( oResponse,"_CAMPOEXTRA1","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCampoExtra2       :=  WSAdvValue( oResponse,"_CAMPOEXTRA2","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCampoExtra3       :=  WSAdvValue( oResponse,"_CAMPOEXTRA3","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nMarcacao          :=  WSAdvValue( oResponse,"_MARCACAO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cMarcacaoOBS       :=  WSAdvValue( oResponse,"_MARCACAOOBS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataMigracao      :=  WSAdvValue( oResponse,"_DATAMIGRACAO","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode39 :=  WSAdvValue( oResponse,"_PASSAGEIROS","ArrayOfPassageiro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode39 != NIL
		::oWSPassageiros := Pedidos_ArrayOfPassageiro():New()
		::oWSPassageiros:SoapRecv(oNode39)
	EndIf
	oNode40 :=  WSAdvValue( oResponse,"_RESERVAESCOLHIDA","Reserva",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode40 != NIL
		::oWSReservaEscolhida := Pedidos_Reserva():New()
		::oWSReservaEscolhida:SoapRecv(oNode40)
	EndIf
Return

// WSDL Data Structure ItemHistorico

WSSTRUCT Pedidos_ItemHistorico
	WSDATA   nPedido                   AS int
	WSDATA   cObservacoes              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_ItemHistorico
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_ItemHistorico
Return

WSMETHOD CLONE WSCLIENT Pedidos_ItemHistorico
	Local oClone := Pedidos_ItemHistorico():NEW()
	oClone:nPedido              := ::nPedido
	oClone:cObservacoes         := ::cObservacoes
Return oClone

WSMETHOD SOAPSEND WSCLIENT Pedidos_ItemHistorico
	Local cSoap := ""
	cSoap += WSSoapValue("Pedido", ::nPedido, ::nPedido , "int", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Observacoes", ::cObservacoes, ::cObservacoes , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Enumeration StatusPedido

WSSTRUCT Pedidos_StatusPedido
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_StatusPedido
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "0" )
	aadd(::aValueList , "1" )
	aadd(::aValueList , "2" )
	aadd(::aValueList , "3" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Pedidos_StatusPedido
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_StatusPedido
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Pedidos_StatusPedido
Local oClone := Pedidos_StatusPedido():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration OrigemPedido

WSSTRUCT Pedidos_OrigemPedido
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_OrigemPedido
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "0" )
	aadd(::aValueList , "1" )
	aadd(::aValueList , "2" )
	aadd(::aValueList , "3" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Pedidos_OrigemPedido
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_OrigemPedido
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Pedidos_OrigemPedido
Local oClone := Pedidos_OrigemPedido():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure Solicitante

WSSTRUCT Pedidos_Solicitante
	WSDATA   nID                       AS int
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cEmail                    AS string OPTIONAL
	WSDATA   cMatricula                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_Solicitante
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_Solicitante
Return

WSMETHOD CLONE WSCLIENT Pedidos_Solicitante
	Local oClone := Pedidos_Solicitante():NEW()
	oClone:nID                  := ::nID
	oClone:cNome                := ::cNome
	oClone:cEmail               := ::cEmail
	oClone:cMatricula           := ::cMatricula
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_Solicitante
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nID                :=  WSAdvValue( oResponse,"_ID","int",NIL,"Property nID as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEmail             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMatricula         :=  WSAdvValue( oResponse,"_MATRICULA","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure Responsavel

WSSTRUCT Pedidos_Responsavel
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cEmail                    AS string OPTIONAL
	WSDATA   cMatricula                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_Responsavel
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_Responsavel
Return

WSMETHOD CLONE WSCLIENT Pedidos_Responsavel
	Local oClone := Pedidos_Responsavel():NEW()
	oClone:cNome                := ::cNome
	oClone:cEmail               := ::cEmail
	oClone:cMatricula           := ::cMatricula
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_Responsavel
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEmail             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMatricula         :=  WSAdvValue( oResponse,"_MATRICULA","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure Emissor

WSSTRUCT Pedidos_Emissor
	WSDATA   cEmissor                  AS string OPTIONAL
	WSDATA   cEmissorEmail             AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_Emissor
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_Emissor
Return

WSMETHOD CLONE WSCLIENT Pedidos_Emissor
	Local oClone := Pedidos_Emissor():NEW()
	oClone:cEmissor             := ::cEmissor
	oClone:cEmissorEmail        := ::cEmissorEmail
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_Emissor
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cEmissor           :=  WSAdvValue( oResponse,"_EMISSOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEmissorEmail      :=  WSAdvValue( oResponse,"_EMISSOREMAIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Enumeration OrigemEmissao

WSSTRUCT Pedidos_OrigemEmissao
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_OrigemEmissao
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "0" )
	aadd(::aValueList , "1" )
	aadd(::aValueList , "2" )
	aadd(::aValueList , "3" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Pedidos_OrigemEmissao
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_OrigemEmissao
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Pedidos_OrigemEmissao
Local oClone := Pedidos_OrigemEmissao():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration StatusAutorizacao

WSSTRUCT Pedidos_StatusAutorizacao
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_StatusAutorizacao
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "0" )
	aadd(::aValueList , "1" )
	aadd(::aValueList , "2" )
	aadd(::aValueList , "3" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Pedidos_StatusAutorizacao
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_StatusAutorizacao
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Pedidos_StatusAutorizacao
Local oClone := Pedidos_StatusAutorizacao():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure Autorizador

WSSTRUCT Pedidos_Autorizador
	WSDATA   nIDAutorizador            AS int
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cEmail                    AS string OPTIONAL
	WSDATA   cMatricula                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_Autorizador
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_Autorizador
Return

WSMETHOD CLONE WSCLIENT Pedidos_Autorizador
	Local oClone := Pedidos_Autorizador():NEW()
	oClone:nIDAutorizador       := ::nIDAutorizador
	oClone:cNome                := ::cNome
	oClone:cEmail               := ::cEmail
	oClone:cMatricula           := ::cMatricula
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_Autorizador
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nIDAutorizador     :=  WSAdvValue( oResponse,"_IDAUTORIZADOR","int",NIL,"Property nIDAutorizador as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEmail             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMatricula         :=  WSAdvValue( oResponse,"_MATRICULA","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfAutorizador

WSSTRUCT Pedidos_ArrayOfAutorizador
	WSDATA   oWSAutorizador            AS Pedidos_Autorizador OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_ArrayOfAutorizador
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_ArrayOfAutorizador
	::oWSAutorizador       := {} // Array Of  Pedidos_AUTORIZADOR():New()
Return

WSMETHOD CLONE WSCLIENT Pedidos_ArrayOfAutorizador
	Local oClone := Pedidos_ArrayOfAutorizador():NEW()
	oClone:oWSAutorizador := NIL
	If ::oWSAutorizador <> NIL 
		oClone:oWSAutorizador := {}
		aEval( ::oWSAutorizador , { |x| aadd( oClone:oWSAutorizador , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_ArrayOfAutorizador
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_AUTORIZADOR","Autorizador",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSAutorizador , Pedidos_Autorizador():New() )
			::oWSAutorizador[len(::oWSAutorizador)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfCCusto

WSSTRUCT Pedidos_ArrayOfCCusto
	WSDATA   oWSCCusto                 AS Pedidos_CCusto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_ArrayOfCCusto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_ArrayOfCCusto
	::oWSCCusto            := {} // Array Of  Pedidos_CCUSTO():New()
Return

WSMETHOD CLONE WSCLIENT Pedidos_ArrayOfCCusto
	Local oClone := Pedidos_ArrayOfCCusto():NEW()
	oClone:oWSCCusto := NIL
	If ::oWSCCusto <> NIL 
		oClone:oWSCCusto := {}
		aEval( ::oWSCCusto , { |x| aadd( oClone:oWSCCusto , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_ArrayOfCCusto
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CCUSTO","CCusto",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSCCusto , Pedidos_CCusto():New() )
			::oWSCCusto[len(::oWSCCusto)]:SoapRecv(oNodes1[nRElem1])
			::oWSCCusto[len(::oWSCCusto)]:cCCusto := oNodes1[nRElem1]:TEXT
		Endif
	Next
Return

// WSDL Data Structure ArrayOfPassageiro

WSSTRUCT Pedidos_ArrayOfPassageiro
	WSDATA   oWSPassageiro             AS Pedidos_Passageiro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_ArrayOfPassageiro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_ArrayOfPassageiro
	::oWSPassageiro        := {} // Array Of  Pedidos_PASSAGEIRO():New()
Return

WSMETHOD CLONE WSCLIENT Pedidos_ArrayOfPassageiro
	Local oClone := Pedidos_ArrayOfPassageiro():NEW()
	oClone:oWSPassageiro := NIL
	If ::oWSPassageiro <> NIL 
		oClone:oWSPassageiro := {}
		aEval( ::oWSPassageiro , { |x| aadd( oClone:oWSPassageiro , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_ArrayOfPassageiro
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_PASSAGEIRO","Passageiro",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSPassageiro , Pedidos_Passageiro():New() )
			::oWSPassageiro[len(::oWSPassageiro)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure Reserva

WSSTRUCT Pedidos_Reserva
	WSDATA   cSisRes                   AS string OPTIONAL
	WSDATA   cLocalizador              AS string OPTIONAL
	WSDATA   cLocReservaPassiva        AS string OPTIONAL
	WSDATA   oWSOrigemReserva          AS Pedidos_OrigemReserva
	WSDATA   cDataReserva              AS dateTime
	WSDATA   nTarifaPorPax             AS decimal
	WSDATA   nTaxaPorPax               AS decimal
	WSDATA   nTaxaServico              AS decimal
	WSDATA   nTarifaAcordo             AS decimal
	WSDATA   nTarifaPromocional        AS decimal
	WSDATA   nTarifaReferencia         AS decimal
	WSDATA   nMenorTarifa              AS decimal
	WSDATA   nCambio                   AS decimal
	WSDATA   cMoeda                    AS string OPTIONAL
	WSDATA   cMoedaTaxa                AS string OPTIONAL
	WSDATA   nMulta                    AS decimal OPTIONAL
	WSDATA   nCredito                  AS decimal OPTIONAL
	WSDATA   nTotal                    AS decimal
	WSDATA   oWSItensReserva           AS Pedidos_ArrayOfItemReserva OPTIONAL
	WSDATA   cPrazoEmissao             AS dateTime OPTIONAL
	WSDATA   oWSPoliticas              AS Pedidos_Politicas OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_Reserva
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_Reserva
Return

WSMETHOD CLONE WSCLIENT Pedidos_Reserva
	Local oClone := Pedidos_Reserva():NEW()
	oClone:cSisRes              := ::cSisRes
	oClone:cLocalizador         := ::cLocalizador
	oClone:cLocReservaPassiva   := ::cLocReservaPassiva
	oClone:oWSOrigemReserva     := IIF(::oWSOrigemReserva = NIL , NIL , ::oWSOrigemReserva:Clone() )
	oClone:cDataReserva         := ::cDataReserva
	oClone:nTarifaPorPax        := ::nTarifaPorPax
	oClone:nTaxaPorPax          := ::nTaxaPorPax
	oClone:nTaxaServico         := ::nTaxaServico
	oClone:nTarifaAcordo        := ::nTarifaAcordo
	oClone:nTarifaPromocional   := ::nTarifaPromocional
	oClone:nTarifaReferencia    := ::nTarifaReferencia
	oClone:nMenorTarifa         := ::nMenorTarifa
	oClone:nCambio              := ::nCambio
	oClone:cMoeda               := ::cMoeda
	oClone:cMoedaTaxa           := ::cMoedaTaxa
	oClone:nMulta               := ::nMulta
	oClone:nCredito             := ::nCredito
	oClone:nTotal               := ::nTotal
	oClone:oWSItensReserva      := IIF(::oWSItensReserva = NIL , NIL , ::oWSItensReserva:Clone() )
	oClone:cPrazoEmissao        := ::cPrazoEmissao
	oClone:oWSPoliticas         := IIF(::oWSPoliticas = NIL , NIL , ::oWSPoliticas:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_Reserva
	Local oNode4
	Local oNode19
	Local oNode21
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSisRes            :=  WSAdvValue( oResponse,"_SISRES","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cLocalizador       :=  WSAdvValue( oResponse,"_LOCALIZADOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cLocReservaPassiva :=  WSAdvValue( oResponse,"_LOCRESERVAPASSIVA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode4 :=  WSAdvValue( oResponse,"_ORIGEMRESERVA","OrigemReserva",NIL,"Property oWSOrigemReserva as tns:OrigemReserva on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode4 != NIL
		::oWSOrigemReserva := Pedidos_OrigemReserva():New()
		::oWSOrigemReserva:SoapRecv(oNode4)
	EndIf
	::cDataReserva       :=  WSAdvValue( oResponse,"_DATARESERVA","dateTime",NIL,"Property cDataReserva as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nTarifaPorPax      :=  WSAdvValue( oResponse,"_TARIFAPORPAX","decimal",NIL,"Property nTarifaPorPax as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTaxaPorPax        :=  WSAdvValue( oResponse,"_TAXAPORPAX","decimal",NIL,"Property nTaxaPorPax as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTaxaServico       :=  WSAdvValue( oResponse,"_TAXASERVICO","decimal",NIL,"Property nTaxaServico as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTarifaAcordo      :=  WSAdvValue( oResponse,"_TARIFAACORDO","decimal",NIL,"Property nTarifaAcordo as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTarifaPromocional :=  WSAdvValue( oResponse,"_TARIFAPROMOCIONAL","decimal",NIL,"Property nTarifaPromocional as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTarifaReferencia  :=  WSAdvValue( oResponse,"_TARIFAREFERENCIA","decimal",NIL,"Property nTarifaReferencia as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nMenorTarifa       :=  WSAdvValue( oResponse,"_MENORTARIFA","decimal",NIL,"Property nMenorTarifa as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nCambio            :=  WSAdvValue( oResponse,"_CAMBIO","decimal",NIL,"Property nCambio as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cMoeda             :=  WSAdvValue( oResponse,"_MOEDA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMoedaTaxa         :=  WSAdvValue( oResponse,"_MOEDATAXA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nMulta             :=  WSAdvValue( oResponse,"_MULTA","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::nCredito           :=  WSAdvValue( oResponse,"_CREDITO","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::nTotal             :=  WSAdvValue( oResponse,"_TOTAL","decimal",NIL,"Property nTotal as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode19 :=  WSAdvValue( oResponse,"_ITENSRESERVA","ArrayOfItemReserva",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode19 != NIL
		::oWSItensReserva := Pedidos_ArrayOfItemReserva():New()
		::oWSItensReserva:SoapRecv(oNode19)
	EndIf
	::cPrazoEmissao      :=  WSAdvValue( oResponse,"_PRAZOEMISSAO","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode21 :=  WSAdvValue( oResponse,"_POLITICAS","Politicas",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode21 != NIL
		::oWSPoliticas := Pedidos_Politicas():New()
		::oWSPoliticas:SoapRecv(oNode21)
	EndIf
Return

// WSDL Data Structure CCusto

WSSTRUCT Pedidos_CCusto
	WSDATA   cpercentual               AS string OPTIONAL
	WSDATA   cCCusto                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_CCusto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_CCusto
Return

WSMETHOD CLONE WSCLIENT Pedidos_CCusto
	Local oClone := Pedidos_CCusto():NEW()
	oClone:cpercentual          := ::cpercentual
	oClone:cCCusto              := ::cCCusto
	
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_CCusto
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cpercentual        :=  WSAdvValue( oResponse,"_PERCENTUAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure Passageiro

WSSTRUCT Pedidos_Passageiro
	WSDATA   nID                       AS int
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cEmail                    AS string OPTIONAL
	WSDATA   cMatricula                AS string OPTIONAL
	WSDATA   cAutorizado               AS string OPTIONAL
	WSDATA   oWSCAV                    AS Pedidos_CAV OPTIONAL
	WSDATA   cBilhete                  AS string OPTIONAL
	WSDATA   cTipoProduto              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_Passageiro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_Passageiro
Return

WSMETHOD CLONE WSCLIENT Pedidos_Passageiro
	Local oClone := Pedidos_Passageiro():NEW()
	oClone:nID                  := ::nID
	oClone:cNome                := ::cNome
	oClone:cEmail               := ::cEmail
	oClone:cMatricula           := ::cMatricula
	oClone:cAutorizado          := ::cAutorizado
	oClone:oWSCAV               := IIF(::oWSCAV = NIL , NIL , ::oWSCAV:Clone() )
	oClone:cBilhete             := ::cBilhete
	oClone:cTipoProduto         := ::cTipoProduto
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_Passageiro
	Local oNode6
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nID                :=  WSAdvValue( oResponse,"_ID","int",NIL,"Property nID as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEmail             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMatricula         :=  WSAdvValue( oResponse,"_MATRICULA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cAutorizado        :=  WSAdvValue( oResponse,"_AUTORIZADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode6 :=  WSAdvValue( oResponse,"_CAV","CAV",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode6 != NIL
		::oWSCAV := Pedidos_CAV():New()
		::oWSCAV:SoapRecv(oNode6)
	EndIf
	::cBilhete           :=  WSAdvValue( oResponse,"_BILHETE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTipoProduto       :=  WSAdvValue( oResponse,"_TIPOPRODUTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Enumeration OrigemReserva

WSSTRUCT Pedidos_OrigemReserva
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_OrigemReserva
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "0" )
	aadd(::aValueList , "1" )
	aadd(::aValueList , "2" )
	aadd(::aValueList , "10" )
	aadd(::aValueList , "11" )
	aadd(::aValueList , "12" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Pedidos_OrigemReserva
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_OrigemReserva
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Pedidos_OrigemReserva
Local oClone := Pedidos_OrigemReserva():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure ArrayOfItemReserva

WSSTRUCT Pedidos_ArrayOfItemReserva
	WSDATA   oWSItemReserva            AS Pedidos_ItemReserva OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_ArrayOfItemReserva
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_ArrayOfItemReserva
	::oWSItemReserva       := {} // Array Of  Pedidos_ITEMRESERVA():New()
Return

WSMETHOD CLONE WSCLIENT Pedidos_ArrayOfItemReserva
	Local oClone := Pedidos_ArrayOfItemReserva():NEW()
	oClone:oWSItemReserva := NIL
	If ::oWSItemReserva <> NIL 
		oClone:oWSItemReserva := {}
		aEval( ::oWSItemReserva , { |x| aadd( oClone:oWSItemReserva , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_ArrayOfItemReserva
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ITEMRESERVA","ItemReserva",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSItemReserva , Pedidos_ItemReserva():New() )
			::oWSItemReserva[len(::oWSItemReserva)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure Politicas

WSSTRUCT Pedidos_Politicas
	WSDATA   oWSMenorTarifa            AS Pedidos_DesvioPolitica
	WSDATA   cJustificativaMenorTarifa AS string OPTIONAL
	WSDATA   oWSAntecedenciaMinima     AS Pedidos_DesvioPolitica
	WSDATA   cJustificativaAntecedencia AS string OPTIONAL
	WSDATA   oWSCiaPreferencial        AS Pedidos_DesvioPolitica
	WSDATA   cJustificativaCiaPreferencial AS string OPTIONAL
	WSDATA   oWSSelecionarCia          AS Pedidos_DesvioPolitica
	WSDATA   cJustificativaSelecionarCia AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_Politicas
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_Politicas
Return

WSMETHOD CLONE WSCLIENT Pedidos_Politicas
	Local oClone := Pedidos_Politicas():NEW()
	oClone:oWSMenorTarifa       := IIF(::oWSMenorTarifa = NIL , NIL , ::oWSMenorTarifa:Clone() )
	oClone:cJustificativaMenorTarifa := ::cJustificativaMenorTarifa
	oClone:oWSAntecedenciaMinima := IIF(::oWSAntecedenciaMinima = NIL , NIL , ::oWSAntecedenciaMinima:Clone() )
	oClone:cJustificativaAntecedencia := ::cJustificativaAntecedencia
	oClone:oWSCiaPreferencial   := IIF(::oWSCiaPreferencial = NIL , NIL , ::oWSCiaPreferencial:Clone() )
	oClone:cJustificativaCiaPreferencial := ::cJustificativaCiaPreferencial
	oClone:oWSSelecionarCia     := IIF(::oWSSelecionarCia = NIL , NIL , ::oWSSelecionarCia:Clone() )
	oClone:cJustificativaSelecionarCia := ::cJustificativaSelecionarCia
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_Politicas
	Local oNode1
	Local oNode3
	Local oNode5
	Local oNode7
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_MENORTARIFA","DesvioPolitica",NIL,"Property oWSMenorTarifa as tns:DesvioPolitica on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSMenorTarifa := Pedidos_DesvioPolitica():New()
		::oWSMenorTarifa:SoapRecv(oNode1)
	EndIf
	::cJustificativaMenorTarifa :=  WSAdvValue( oResponse,"_JUSTIFICATIVAMENORTARIFA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode3 :=  WSAdvValue( oResponse,"_ANTECEDENCIAMINIMA","DesvioPolitica",NIL,"Property oWSAntecedenciaMinima as tns:DesvioPolitica on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode3 != NIL
		::oWSAntecedenciaMinima := Pedidos_DesvioPolitica():New()
		::oWSAntecedenciaMinima:SoapRecv(oNode3)
	EndIf
	::cJustificativaAntecedencia :=  WSAdvValue( oResponse,"_JUSTIFICATIVAANTECEDENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode5 :=  WSAdvValue( oResponse,"_CIAPREFERENCIAL","DesvioPolitica",NIL,"Property oWSCiaPreferencial as tns:DesvioPolitica on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSCiaPreferencial := Pedidos_DesvioPolitica():New()
		::oWSCiaPreferencial:SoapRecv(oNode5)
	EndIf
	::cJustificativaCiaPreferencial :=  WSAdvValue( oResponse,"_JUSTIFICATIVACIAPREFERENCIAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode7 :=  WSAdvValue( oResponse,"_SELECIONARCIA","DesvioPolitica",NIL,"Property oWSSelecionarCia as tns:DesvioPolitica on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode7 != NIL
		::oWSSelecionarCia := Pedidos_DesvioPolitica():New()
		::oWSSelecionarCia:SoapRecv(oNode7)
	EndIf
	::cJustificativaSelecionarCia :=  WSAdvValue( oResponse,"_JUSTIFICATIVASELECIONARCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure CAV

WSSTRUCT Pedidos_CAV
	WSDATA   nIDCAV                    AS int
	WSDATA   cDataSolicitacao          AS dateTime
	WSDATA   cDataAutorizacao          AS dateTime OPTIONAL
	WSDATA   cDataIni                  AS dateTime
	WSDATA   cDataFim                  AS dateTime
	WSDATA   nNumDias                  AS int
	WSDATA   oWSStatus                 AS Pedidos_StatusCAV
	WSDATA   cMoeda                    AS string OPTIONAL
	WSDATA   nCambio                   AS decimal
	WSDATA   nTotal                    AS decimal
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_CAV
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_CAV
Return

WSMETHOD CLONE WSCLIENT Pedidos_CAV
	Local oClone := Pedidos_CAV():NEW()
	oClone:nIDCAV               := ::nIDCAV
	oClone:cDataSolicitacao     := ::cDataSolicitacao
	oClone:cDataAutorizacao     := ::cDataAutorizacao
	oClone:cDataIni             := ::cDataIni
	oClone:cDataFim             := ::cDataFim
	oClone:nNumDias             := ::nNumDias
	oClone:oWSStatus            := IIF(::oWSStatus = NIL , NIL , ::oWSStatus:Clone() )
	oClone:cMoeda               := ::cMoeda
	oClone:nCambio              := ::nCambio
	oClone:nTotal               := ::nTotal
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_CAV
	Local oNode7
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nIDCAV             :=  WSAdvValue( oResponse,"_IDCAV","int",NIL,"Property nIDCAV as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDataSolicitacao   :=  WSAdvValue( oResponse,"_DATASOLICITACAO","dateTime",NIL,"Property cDataSolicitacao as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDataAutorizacao   :=  WSAdvValue( oResponse,"_DATAAUTORIZACAO","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataIni           :=  WSAdvValue( oResponse,"_DATAINI","dateTime",NIL,"Property cDataIni as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDataFim           :=  WSAdvValue( oResponse,"_DATAFIM","dateTime",NIL,"Property cDataFim as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nNumDias           :=  WSAdvValue( oResponse,"_NUMDIAS","int",NIL,"Property nNumDias as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode7 :=  WSAdvValue( oResponse,"_STATUS","StatusCAV",NIL,"Property oWSStatus as tns:StatusCAV on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode7 != NIL
		::oWSStatus := Pedidos_StatusCAV():New()
		::oWSStatus:SoapRecv(oNode7)
	EndIf
	::cMoeda             :=  WSAdvValue( oResponse,"_MOEDA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nCambio            :=  WSAdvValue( oResponse,"_CAMBIO","decimal",NIL,"Property nCambio as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTotal             :=  WSAdvValue( oResponse,"_TOTAL","decimal",NIL,"Property nTotal as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ItemReserva

WSSTRUCT Pedidos_ItemReserva
	WSDATA   lInternacional            AS boolean
	WSDATA   oWSAcomodacao             AS Pedidos_Acomodacao OPTIONAL
	WSDATA   oWSSeguro                 AS Pedidos_Seguro OPTIONAL
	WSDATA   oWSLocacaoCarro           AS Pedidos_Locacao OPTIONAL
	WSDATA   oWSPassagemRodoviario     AS Pedidos_Segmento OPTIONAL
	WSDATA   oWSPassagemAereo          AS Pedidos_Segmento OPTIONAL
	WSDATA   oWSOutroServico           AS Pedidos_Segmento OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_ItemReserva
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_ItemReserva
Return

WSMETHOD CLONE WSCLIENT Pedidos_ItemReserva
	Local oClone := Pedidos_ItemReserva():NEW()
	oClone:lInternacional       := ::lInternacional
	oClone:oWSAcomodacao        := IIF(::oWSAcomodacao = NIL , NIL , ::oWSAcomodacao:Clone() )
	oClone:oWSSeguro            := IIF(::oWSSeguro = NIL , NIL , ::oWSSeguro:Clone() )
	oClone:oWSLocacaoCarro      := IIF(::oWSLocacaoCarro = NIL , NIL , ::oWSLocacaoCarro:Clone() )
	oClone:oWSPassagemRodoviario := IIF(::oWSPassagemRodoviario = NIL , NIL , ::oWSPassagemRodoviario:Clone() )
	oClone:oWSPassagemAereo     := IIF(::oWSPassagemAereo = NIL , NIL , ::oWSPassagemAereo:Clone() )
	oClone:oWSOutroServico      := IIF(::oWSOutroServico = NIL , NIL , ::oWSOutroServico:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_ItemReserva
	Local oNode2
	Local oNode3
	Local oNode4
	Local oNode5
	Local oNode6
	Local oNode7
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lInternacional     :=  WSAdvValue( oResponse,"_INTERNACIONAL","boolean",NIL,"Property lInternacional as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_ACOMODACAO","Acomodacao",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSAcomodacao := Pedidos_Acomodacao():New()
		::oWSAcomodacao:SoapRecv(oNode2)
	EndIf
	oNode3 :=  WSAdvValue( oResponse,"_SEGURO","Seguro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode3 != NIL
		::oWSSeguro := Pedidos_Seguro():New()
		::oWSSeguro:SoapRecv(oNode3)
	EndIf
	oNode4 :=  WSAdvValue( oResponse,"_LOCACAOCARRO","Locacao",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode4 != NIL
		::oWSLocacaoCarro := Pedidos_Locacao():New()
		::oWSLocacaoCarro:SoapRecv(oNode4)
	EndIf
	oNode5 :=  WSAdvValue( oResponse,"_PASSAGEMRODOVIARIO","Segmento",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSPassagemRodoviario := Pedidos_Segmento():New()
		::oWSPassagemRodoviario:SoapRecv(oNode5)
	EndIf
	oNode6 :=  WSAdvValue( oResponse,"_PASSAGEMAEREO","Segmento",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode6 != NIL
		::oWSPassagemAereo := Pedidos_Segmento():New()
		::oWSPassagemAereo:SoapRecv(oNode6)
	EndIf
	oNode7 :=  WSAdvValue( oResponse,"_OUTROSERVICO","Segmento",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode7 != NIL
		::oWSOutroServico := Pedidos_Segmento():New()
		::oWSOutroServico:SoapRecv(oNode7)
	EndIf
Return

// WSDL Data Enumeration DesvioPolitica

WSSTRUCT Pedidos_DesvioPolitica
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_DesvioPolitica
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "0" )
	aadd(::aValueList , "1" )
	aadd(::aValueList , "2" )
Return Self

WSMETHOD SOAPSEND WSCLIENT Pedidos_DesvioPolitica
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_DesvioPolitica
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Pedidos_DesvioPolitica
Local oClone := Pedidos_DesvioPolitica():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Enumeration StatusCAV

WSSTRUCT Pedidos_StatusCAV
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_StatusCAV
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

WSMETHOD SOAPSEND WSCLIENT Pedidos_StatusCAV
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_StatusCAV
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT Pedidos_StatusCAV
Local oClone := Pedidos_StatusCAV():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure Acomodacao

WSSTRUCT Pedidos_Acomodacao
	WSDATA   cIDHotel                  AS string OPTIONAL
	WSDATA   cNomeHotel                AS string OPTIONAL
	WSDATA   cCNPJHotel                AS string OPTIONAL
	WSDATA   cCodCidade                AS string OPTIONAL
	WSDATA   cCidade                   AS string OPTIONAL
	WSDATA   cCheckin                  AS dateTime
	WSDATA   cCheckout                 AS dateTime
	WSDATA   cCategoria                AS string OPTIONAL
	WSDATA   nDiarias                  AS int
	WSDATA   nIndiceReserva            AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_Acomodacao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_Acomodacao
Return

WSMETHOD CLONE WSCLIENT Pedidos_Acomodacao
	Local oClone := Pedidos_Acomodacao():NEW()
	oClone:cIDHotel             := ::cIDHotel
	oClone:cNomeHotel           := ::cNomeHotel
	oClone:cCNPJHotel           := ::cCNPJHotel
	oClone:cCodCidade           := ::cCodCidade
	oClone:cCidade              := ::cCidade
	oClone:cCheckin             := ::cCheckin
	oClone:cCheckout            := ::cCheckout
	oClone:cCategoria           := ::cCategoria
	oClone:nDiarias             := ::nDiarias
	oClone:nIndiceReserva       := ::nIndiceReserva
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_Acomodacao
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cIDHotel           :=  WSAdvValue( oResponse,"_IDHOTEL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNomeHotel         :=  WSAdvValue( oResponse,"_NOMEHOTEL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCNPJHotel         :=  WSAdvValue( oResponse,"_CNPJHOTEL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodCidade         :=  WSAdvValue( oResponse,"_CODCIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCidade            :=  WSAdvValue( oResponse,"_CIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCheckin           :=  WSAdvValue( oResponse,"_CHECKIN","dateTime",NIL,"Property cCheckin as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCheckout          :=  WSAdvValue( oResponse,"_CHECKOUT","dateTime",NIL,"Property cCheckout as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCategoria         :=  WSAdvValue( oResponse,"_CATEGORIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nDiarias           :=  WSAdvValue( oResponse,"_DIARIAS","int",NIL,"Property nDiarias as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nIndiceReserva     :=  WSAdvValue( oResponse,"_INDICERESERVA","int",NIL,"Property nIndiceReserva as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure Seguro

WSSTRUCT Pedidos_Seguro
	WSDATA   cIDSeguradora             AS string OPTIONAL
	WSDATA   cNomeSeguradora           AS string OPTIONAL
	WSDATA   cCodCidade                AS string OPTIONAL
	WSDATA   cCidade                   AS string OPTIONAL
	WSDATA   cInicioValidade           AS dateTime
	WSDATA   cFimValidade              AS dateTime
	WSDATA   cPlano                    AS string OPTIONAL
	WSDATA   nDiarias                  AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_Seguro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_Seguro
Return

WSMETHOD CLONE WSCLIENT Pedidos_Seguro
	Local oClone := Pedidos_Seguro():NEW()
	oClone:cIDSeguradora        := ::cIDSeguradora
	oClone:cNomeSeguradora      := ::cNomeSeguradora
	oClone:cCodCidade           := ::cCodCidade
	oClone:cCidade              := ::cCidade
	oClone:cInicioValidade      := ::cInicioValidade
	oClone:cFimValidade         := ::cFimValidade
	oClone:cPlano               := ::cPlano
	oClone:nDiarias             := ::nDiarias
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_Seguro
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cIDSeguradora      :=  WSAdvValue( oResponse,"_IDSEGURADORA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNomeSeguradora    :=  WSAdvValue( oResponse,"_NOMESEGURADORA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodCidade         :=  WSAdvValue( oResponse,"_CODCIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCidade            :=  WSAdvValue( oResponse,"_CIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cInicioValidade    :=  WSAdvValue( oResponse,"_INICIOVALIDADE","dateTime",NIL,"Property cInicioValidade as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFimValidade       :=  WSAdvValue( oResponse,"_FIMVALIDADE","dateTime",NIL,"Property cFimValidade as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPlano             :=  WSAdvValue( oResponse,"_PLANO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nDiarias           :=  WSAdvValue( oResponse,"_DIARIAS","int",NIL,"Property nDiarias as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure Locacao

WSSTRUCT Pedidos_Locacao
	WSDATA   cIDLocadora               AS string OPTIONAL
	WSDATA   cNomeLocadora             AS string OPTIONAL
	WSDATA   cCodCidadeRetirada        AS string OPTIONAL
	WSDATA   cCidadeRetirada           AS string OPTIONAL
	WSDATA   cCodCidadeDevolucao       AS string OPTIONAL
	WSDATA   cCidadeDevolucao          AS string OPTIONAL
	WSDATA   cDataRetirada             AS dateTime
	WSDATA   cDataDevolucao            AS dateTime
	WSDATA   cTipoVeiculo              AS string OPTIONAL
	WSDATA   cLocalDevolucao           AS string OPTIONAL
	WSDATA   nDiarias                  AS int
	WSDATA   nIndiceReserva            AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_Locacao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_Locacao
Return

WSMETHOD CLONE WSCLIENT Pedidos_Locacao
	Local oClone := Pedidos_Locacao():NEW()
	oClone:cIDLocadora          := ::cIDLocadora
	oClone:cNomeLocadora        := ::cNomeLocadora
	oClone:cCodCidadeRetirada   := ::cCodCidadeRetirada
	oClone:cCidadeRetirada      := ::cCidadeRetirada
	oClone:cCodCidadeDevolucao  := ::cCodCidadeDevolucao
	oClone:cCidadeDevolucao     := ::cCidadeDevolucao
	oClone:cDataRetirada        := ::cDataRetirada
	oClone:cDataDevolucao       := ::cDataDevolucao
	oClone:cTipoVeiculo         := ::cTipoVeiculo
	oClone:cLocalDevolucao      := ::cLocalDevolucao
	oClone:nDiarias             := ::nDiarias
	oClone:nIndiceReserva       := ::nIndiceReserva
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_Locacao
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cIDLocadora        :=  WSAdvValue( oResponse,"_IDLOCADORA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNomeLocadora      :=  WSAdvValue( oResponse,"_NOMELOCADORA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodCidadeRetirada :=  WSAdvValue( oResponse,"_CODCIDADERETIRADA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCidadeRetirada    :=  WSAdvValue( oResponse,"_CIDADERETIRADA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodCidadeDevolucao :=  WSAdvValue( oResponse,"_CODCIDADEDEVOLUCAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCidadeDevolucao   :=  WSAdvValue( oResponse,"_CIDADEDEVOLUCAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataRetirada      :=  WSAdvValue( oResponse,"_DATARETIRADA","dateTime",NIL,"Property cDataRetirada as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDataDevolucao     :=  WSAdvValue( oResponse,"_DATADEVOLUCAO","dateTime",NIL,"Property cDataDevolucao as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTipoVeiculo       :=  WSAdvValue( oResponse,"_TIPOVEICULO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cLocalDevolucao    :=  WSAdvValue( oResponse,"_LOCALDEVOLUCAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nDiarias           :=  WSAdvValue( oResponse,"_DIARIAS","int",NIL,"Property nDiarias as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nIndiceReserva     :=  WSAdvValue( oResponse,"_INDICERESERVA","int",NIL,"Property nIndiceReserva as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure Segmento

WSSTRUCT Pedidos_Segmento
	WSDATA   cVoo                      AS string OPTIONAL
	WSDATA   cCodCia                   AS string OPTIONAL
	WSDATA   cNomeCia                  AS string OPTIONAL
	WSDATA   cCodOrigem                AS string OPTIONAL
	WSDATA   cOrigem                   AS string OPTIONAL
	WSDATA   cCodDestino               AS string OPTIONAL
	WSDATA   cDestino                  AS string OPTIONAL
	WSDATA   cSaida                    AS dateTime
	WSDATA   cChegada                  AS dateTime
	WSDATA   cClasse                   AS string OPTIONAL
	WSDATA   cBaseTarifaria            AS string OPTIONAL
	WSDATA   cStatus                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Pedidos_Segmento
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Pedidos_Segmento
Return

WSMETHOD CLONE WSCLIENT Pedidos_Segmento
	Local oClone := Pedidos_Segmento():NEW()
	oClone:cVoo                 := ::cVoo
	oClone:cCodCia              := ::cCodCia
	oClone:cNomeCia             := ::cNomeCia
	oClone:cCodOrigem           := ::cCodOrigem
	oClone:cOrigem              := ::cOrigem
	oClone:cCodDestino          := ::cCodDestino
	oClone:cDestino             := ::cDestino
	oClone:cSaida               := ::cSaida
	oClone:cChegada             := ::cChegada
	oClone:cClasse              := ::cClasse
	oClone:cBaseTarifaria       := ::cBaseTarifaria
	oClone:cStatus              := ::cStatus
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Pedidos_Segmento
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cVoo               :=  WSAdvValue( oResponse,"_VOO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodCia            :=  WSAdvValue( oResponse,"_CODCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNomeCia           :=  WSAdvValue( oResponse,"_NOMECIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodOrigem         :=  WSAdvValue( oResponse,"_CODORIGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOrigem            :=  WSAdvValue( oResponse,"_ORIGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodDestino        :=  WSAdvValue( oResponse,"_CODDESTINO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDestino           :=  WSAdvValue( oResponse,"_DESTINO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSaida             :=  WSAdvValue( oResponse,"_SAIDA","dateTime",NIL,"Property cSaida as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cChegada           :=  WSAdvValue( oResponse,"_CHEGADA","dateTime",NIL,"Property cChegada as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cClasse            :=  WSAdvValue( oResponse,"_CLASSE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cBaseTarifaria     :=  WSAdvValue( oResponse,"_BASETARIFARIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cStatus            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


