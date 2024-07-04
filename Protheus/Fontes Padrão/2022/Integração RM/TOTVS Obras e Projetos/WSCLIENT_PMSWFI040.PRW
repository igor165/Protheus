#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://172.16.31.88:83/WSFINA040.apw?WSDL
Gerado em        09/28/11 19:02:23
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110425
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _HJERZJJ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSFINA040
------------------------------------------------------------------------------- */

WSCLIENT WSWSFINA040

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD EXCLUI
	WSMETHOD INCLUI

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   oWSSSE1EXCLUI             AS WSFINA040_STSE1DEL
	WSDATA   cEXCLUIRESULT             AS string
	WSDATA   oWSSCONTASARECEBER        AS WSFINA040_STCONTASARECEBER
	WSDATA   oWSINCLUIRESULT           AS WSFINA040_STCHAVESE1

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSSTSE1DEL               AS WSFINA040_STSE1DEL
	WSDATA   oWSSTCONTASARECEBER       AS WSFINA040_STCONTASARECEBER

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSFINA040
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.100812P-20100901] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSFINA040
	::oWSSSE1EXCLUI      := WSFINA040_STSE1DEL():New()
	::oWSSCONTASARECEBER := WSFINA040_STCONTASARECEBER():New()
	::oWSINCLUIRESULT    := WSFINA040_STCHAVESE1():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSTSE1DEL        := ::oWSSSE1EXCLUI
	::oWSSTCONTASARECEBER := ::oWSSCONTASARECEBER
Return

WSMETHOD RESET WSCLIENT WSWSFINA040
	::oWSSSE1EXCLUI      := NIL 
	::cEXCLUIRESULT      := NIL 
	::oWSSCONTASARECEBER := NIL 
	::oWSINCLUIRESULT    := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSTSE1DEL        := NIL
	::oWSSTCONTASARECEBER := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSFINA040
Local oClone := WSWSFINA040():New()
	oClone:_URL          := ::_URL 
	oClone:oWSSSE1EXCLUI :=  IIF(::oWSSSE1EXCLUI = NIL , NIL ,::oWSSSE1EXCLUI:Clone() )
	oClone:cEXCLUIRESULT := ::cEXCLUIRESULT
	oClone:oWSSCONTASARECEBER :=  IIF(::oWSSCONTASARECEBER = NIL , NIL ,::oWSSCONTASARECEBER:Clone() )
	oClone:oWSINCLUIRESULT :=  IIF(::oWSINCLUIRESULT = NIL , NIL ,::oWSINCLUIRESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSSTSE1DEL   := oClone:oWSSSE1EXCLUI
	oClone:oWSSTCONTASARECEBER := oClone:oWSSCONTASARECEBER
Return oClone

// WSDL Method EXCLUI of Service WSWSFINA040

WSMETHOD EXCLUI WSSEND oWSSSE1EXCLUI WSRECEIVE cEXCLUIRESULT WSCLIENT WSWSFINA040
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EXCLUI xmlns="http://www.totvs.com.br/rm/">'
cSoap += WSSoapValue("SSE1EXCLUI", ::oWSSSE1EXCLUI, oWSSSE1EXCLUI , "STSE1DEL", .T. , .F., 0 , NIL, .F.) 
cSoap += "</EXCLUI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.totvs.com.br/rm/EXCLUI",; 
	"DOCUMENT","http://www.totvs.com.br/rm/",,"1.031217",; 
	"http://172.16.31.88:83/WSFINA040.apw")

::Init()
::cEXCLUIRESULT      :=  WSAdvValue( oXmlRet,"_EXCLUIRESPONSE:_EXCLUIRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INCLUI of Service WSWSFINA040

WSMETHOD INCLUI WSSEND oWSSCONTASARECEBER WSRECEIVE oWSINCLUIRESULT WSCLIENT WSWSFINA040
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INCLUI xmlns="http://www.totvs.com.br/rm/">'
cSoap += WSSoapValue("SCONTASARECEBER", ::oWSSCONTASARECEBER, oWSSCONTASARECEBER , "STCONTASARECEBER", .T. , .F., 0 , NIL, .F.) 
cSoap += "</INCLUI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.totvs.com.br/rm/INCLUI",; 
	"DOCUMENT","http://www.totvs.com.br/rm/",,"1.031217",; 
	"http://172.16.31.88:83/WSFINA040.apw")

::Init()
::oWSINCLUIRESULT:SoapRecv( WSAdvValue( oXmlRet,"_INCLUIRESPONSE:_INCLUIRESULT","STCHAVESE1",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure STSE1DEL

WSSTRUCT WSFINA040_STSE1DEL
	WSDATA   cCE1_CLIENTE              AS string
	WSDATA   cCE1_EMPRESA              AS string
	WSDATA   cCE1_FILIAL               AS string
	WSDATA   cCE1_LOJA                 AS string
	WSDATA   cCE1_NUM                  AS string
	WSDATA   cCE1_PARCELA              AS string
	WSDATA   cCE1_PREFIXO              AS string
	WSDATA   cCE1_TIPO                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSFINA040_STSE1DEL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSFINA040_STSE1DEL
Return

WSMETHOD CLONE WSCLIENT WSFINA040_STSE1DEL
	Local oClone := WSFINA040_STSE1DEL():NEW()
	oClone:cCE1_CLIENTE         := ::cCE1_CLIENTE
	oClone:cCE1_EMPRESA         := ::cCE1_EMPRESA
	oClone:cCE1_FILIAL          := ::cCE1_FILIAL
	oClone:cCE1_LOJA            := ::cCE1_LOJA
	oClone:cCE1_NUM             := ::cCE1_NUM
	oClone:cCE1_PARCELA         := ::cCE1_PARCELA
	oClone:cCE1_PREFIXO         := ::cCE1_PREFIXO
	oClone:cCE1_TIPO            := ::cCE1_TIPO
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSFINA040_STSE1DEL
	Local cSoap := ""
	cSoap += WSSoapValue("CE1_CLIENTE", ::cCE1_CLIENTE, ::cCE1_CLIENTE , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_EMPRESA", ::cCE1_EMPRESA, ::cCE1_EMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_FILIAL", ::cCE1_FILIAL, ::cCE1_FILIAL , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_LOJA", ::cCE1_LOJA, ::cCE1_LOJA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_NUM", ::cCE1_NUM, ::cCE1_NUM , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_PARCELA", ::cCE1_PARCELA, ::cCE1_PARCELA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_PREFIXO", ::cCE1_PREFIXO, ::cCE1_PREFIXO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_TIPO", ::cCE1_TIPO, ::cCE1_TIPO , "string", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure STCONTASARECEBER

WSSTRUCT WSFINA040_STCONTASARECEBER
	WSDATA   oWSSCAB                   AS WSFINA040_STCABSE1
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSFINA040_STCONTASARECEBER
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSFINA040_STCONTASARECEBER
Return

WSMETHOD CLONE WSCLIENT WSFINA040_STCONTASARECEBER
	Local oClone := WSFINA040_STCONTASARECEBER():NEW()
	oClone:oWSSCAB              := IIF(::oWSSCAB = NIL , NIL , ::oWSSCAB:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSFINA040_STCONTASARECEBER
	Local cSoap := ""
	cSoap += WSSoapValue("SCAB", ::oWSSCAB, ::oWSSCAB , "STCABSE1", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure STCHAVESE1

WSSTRUCT WSFINA040_STCHAVESE1
	WSDATA   cCE1_CLIENTE              AS string
	WSDATA   cCE1_EMPRESA              AS string
	WSDATA   cCE1_FILIAL               AS string
	WSDATA   cCE1_LOJA                 AS string
	WSDATA   cCE1_NUM                  AS string
	WSDATA   cCE1_PARCELA              AS string
	WSDATA   cCE1_PREFIXO              AS string
	WSDATA   cCE1_TIPO                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSFINA040_STCHAVESE1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSFINA040_STCHAVESE1
Return

WSMETHOD CLONE WSCLIENT WSFINA040_STCHAVESE1
	Local oClone := WSFINA040_STCHAVESE1():NEW()
	oClone:cCE1_CLIENTE         := ::cCE1_CLIENTE
	oClone:cCE1_EMPRESA         := ::cCE1_EMPRESA
	oClone:cCE1_FILIAL          := ::cCE1_FILIAL
	oClone:cCE1_LOJA            := ::cCE1_LOJA
	oClone:cCE1_NUM             := ::cCE1_NUM
	oClone:cCE1_PARCELA         := ::cCE1_PARCELA
	oClone:cCE1_PREFIXO         := ::cCE1_PREFIXO
	oClone:cCE1_TIPO            := ::cCE1_TIPO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSFINA040_STCHAVESE1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCE1_CLIENTE       :=  WSAdvValue( oResponse,"_CE1_CLIENTE","string",NIL,"Property cCE1_CLIENTE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCE1_EMPRESA       :=  WSAdvValue( oResponse,"_CE1_EMPRESA","string",NIL,"Property cCE1_EMPRESA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCE1_FILIAL        :=  WSAdvValue( oResponse,"_CE1_FILIAL","string",NIL,"Property cCE1_FILIAL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCE1_LOJA          :=  WSAdvValue( oResponse,"_CE1_LOJA","string",NIL,"Property cCE1_LOJA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCE1_NUM           :=  WSAdvValue( oResponse,"_CE1_NUM","string",NIL,"Property cCE1_NUM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCE1_PARCELA       :=  WSAdvValue( oResponse,"_CE1_PARCELA","string",NIL,"Property cCE1_PARCELA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCE1_PREFIXO       :=  WSAdvValue( oResponse,"_CE1_PREFIXO","string",NIL,"Property cCE1_PREFIXO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCE1_TIPO          :=  WSAdvValue( oResponse,"_CE1_TIPO","string",NIL,"Property cCE1_TIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure STCABSE1

WSSTRUCT WSFINA040_STCABSE1
	WSDATA   cCAFT_PROJETO             AS string
	WSDATA   cCAFT_TAREFA              AS string
	WSDATA   cCE1_AGEDEP               AS string
	WSDATA   cCE1_CLIENTE              AS string
	WSDATA   cCE1_CONTA                AS string
	WSDATA   cCE1_EMISSAO              AS string
	WSDATA   cCE1_EMPRESA              AS string
	WSDATA   cCE1_FILIAL               AS string
	WSDATA   cCE1_LOJA                 AS string
	WSDATA   cCE1_NATUREZ              AS string
	WSDATA   cCE1_NUM                  AS string
	WSDATA   cCE1_PARCELA              AS string
	WSDATA   cCE1_PORTADO              AS string
	WSDATA   cCE1_PREFIXO              AS string
	WSDATA   cCE1_TIPO                 AS string
	WSDATA   cCE1_VENCTO               AS string
	WSDATA   nNE1_VALOR                AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSFINA040_STCABSE1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSFINA040_STCABSE1
Return

WSMETHOD CLONE WSCLIENT WSFINA040_STCABSE1
	Local oClone := WSFINA040_STCABSE1():NEW()
	oClone:cCAFT_PROJETO        := ::cCAFT_PROJETO
	oClone:cCAFT_TAREFA         := ::cCAFT_TAREFA
	oClone:cCE1_AGEDEP          := ::cCE1_AGEDEP
	oClone:cCE1_CLIENTE         := ::cCE1_CLIENTE
	oClone:cCE1_CONTA           := ::cCE1_CONTA
	oClone:cCE1_EMISSAO         := ::cCE1_EMISSAO
	oClone:cCE1_EMPRESA         := ::cCE1_EMPRESA
	oClone:cCE1_FILIAL          := ::cCE1_FILIAL
	oClone:cCE1_LOJA            := ::cCE1_LOJA
	oClone:cCE1_NATUREZ         := ::cCE1_NATUREZ
	oClone:cCE1_NUM             := ::cCE1_NUM
	oClone:cCE1_PARCELA         := ::cCE1_PARCELA
	oClone:cCE1_PORTADO         := ::cCE1_PORTADO
	oClone:cCE1_PREFIXO         := ::cCE1_PREFIXO
	oClone:cCE1_TIPO            := ::cCE1_TIPO
	oClone:cCE1_VENCTO          := ::cCE1_VENCTO
	oClone:nNE1_VALOR           := ::nNE1_VALOR
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSFINA040_STCABSE1
	Local cSoap := ""
	cSoap += WSSoapValue("CAFT_PROJETO", ::cCAFT_PROJETO, ::cCAFT_PROJETO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CAFT_TAREFA", ::cCAFT_TAREFA, ::cCAFT_TAREFA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_AGEDEP", ::cCE1_AGEDEP, ::cCE1_AGEDEP , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_CLIENTE", ::cCE1_CLIENTE, ::cCE1_CLIENTE , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_CONTA", ::cCE1_CONTA, ::cCE1_CONTA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_EMISSAO", ::cCE1_EMISSAO, ::cCE1_EMISSAO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_EMPRESA", ::cCE1_EMPRESA, ::cCE1_EMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_FILIAL", ::cCE1_FILIAL, ::cCE1_FILIAL , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_LOJA", ::cCE1_LOJA, ::cCE1_LOJA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_NATUREZ", ::cCE1_NATUREZ, ::cCE1_NATUREZ , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_NUM", ::cCE1_NUM, ::cCE1_NUM , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_PARCELA", ::cCE1_PARCELA, ::cCE1_PARCELA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_PORTADO", ::cCE1_PORTADO, ::cCE1_PORTADO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_PREFIXO", ::cCE1_PREFIXO, ::cCE1_PREFIXO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_TIPO", ::cCE1_TIPO, ::cCE1_TIPO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE1_VENCTO", ::cCE1_VENCTO, ::cCE1_VENCTO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NE1_VALOR", ::nNE1_VALOR, ::nNE1_VALOR , "float", .T. , .F., 0 , NIL, .F.) 
Return cSoap




