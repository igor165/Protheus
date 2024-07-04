#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://172.16.31.88:83/WSFINA050.apw?WSDL
Gerado em        09/28/11 19:01:06
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110425
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _LXABRSR ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSFINA050
------------------------------------------------------------------------------- */

WSCLIENT WSWSFINA050

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD EXCLUI
	WSMETHOD INCLUI

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   oWSSSE2EXCLUI             AS WSFINA050_STSE2DEL
	WSDATA   cEXCLUIRESULT             AS string
	WSDATA   oWSSCONTASAPAGAR          AS WSFINA050_STCONTASAPAGAR
	WSDATA   oWSINCLUIRESULT           AS WSFINA050_STCHAVESE2

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSSTSE2DEL               AS WSFINA050_STSE2DEL
	WSDATA   oWSSTCONTASAPAGAR         AS WSFINA050_STCONTASAPAGAR

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSFINA050
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.100812P-20100901] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSFINA050
	::oWSSSE2EXCLUI      := WSFINA050_STSE2DEL():New()
	::oWSSCONTASAPAGAR   := WSFINA050_STCONTASAPAGAR():New()
	::oWSINCLUIRESULT    := WSFINA050_STCHAVESE2():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSTSE2DEL        := ::oWSSSE2EXCLUI
	::oWSSTCONTASAPAGAR  := ::oWSSCONTASAPAGAR
Return

WSMETHOD RESET WSCLIENT WSWSFINA050
	::oWSSSE2EXCLUI      := NIL 
	::cEXCLUIRESULT      := NIL 
	::oWSSCONTASAPAGAR   := NIL 
	::oWSINCLUIRESULT    := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSTSE2DEL        := NIL
	::oWSSTCONTASAPAGAR  := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSFINA050
Local oClone := WSWSFINA050():New()
	oClone:_URL          := ::_URL 
	oClone:oWSSSE2EXCLUI :=  IIF(::oWSSSE2EXCLUI = NIL , NIL ,::oWSSSE2EXCLUI:Clone() )
	oClone:cEXCLUIRESULT := ::cEXCLUIRESULT
	oClone:oWSSCONTASAPAGAR :=  IIF(::oWSSCONTASAPAGAR = NIL , NIL ,::oWSSCONTASAPAGAR:Clone() )
	oClone:oWSINCLUIRESULT :=  IIF(::oWSINCLUIRESULT = NIL , NIL ,::oWSINCLUIRESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSSTSE2DEL   := oClone:oWSSSE2EXCLUI
	oClone:oWSSTCONTASAPAGAR := oClone:oWSSCONTASAPAGAR
Return oClone

// WSDL Method EXCLUI of Service WSWSFINA050

WSMETHOD EXCLUI WSSEND oWSSSE2EXCLUI WSRECEIVE cEXCLUIRESULT WSCLIENT WSWSFINA050
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EXCLUI xmlns="http://www.totvs.com.br/rm/">'
cSoap += WSSoapValue("SSE2EXCLUI", ::oWSSSE2EXCLUI, oWSSSE2EXCLUI , "STSE2DEL", .T. , .F., 0 , NIL, .F.) 
cSoap += "</EXCLUI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.totvs.com.br/rm/EXCLUI",; 
	"DOCUMENT","http://www.totvs.com.br/rm/",,"1.031217",; 
	"http://172.16.31.88:83/WSFINA050.apw")

::Init()
::cEXCLUIRESULT      :=  WSAdvValue( oXmlRet,"_EXCLUIRESPONSE:_EXCLUIRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INCLUI of Service WSWSFINA050

WSMETHOD INCLUI WSSEND oWSSCONTASAPAGAR WSRECEIVE oWSINCLUIRESULT WSCLIENT WSWSFINA050
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INCLUI xmlns="http://www.totvs.com.br/rm/">'
cSoap += WSSoapValue("SCONTASAPAGAR", ::oWSSCONTASAPAGAR, oWSSCONTASAPAGAR , "STCONTASAPAGAR", .T. , .F., 0 , NIL, .F.) 
cSoap += "</INCLUI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.totvs.com.br/rm/INCLUI",; 
	"DOCUMENT","http://www.totvs.com.br/rm/",,"1.031217",; 
	"http://172.16.31.88:83/WSFINA050.apw")

::Init()
::oWSINCLUIRESULT:SoapRecv( WSAdvValue( oXmlRet,"_INCLUIRESPONSE:_INCLUIRESULT","STCHAVESE2",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure STSE2DEL

WSSTRUCT WSFINA050_STSE2DEL
	WSDATA   cCE2_EMPRESA              AS string
	WSDATA   cCE2_FILIAL               AS string
	WSDATA   cCE2_FORNECE              AS string
	WSDATA   cCE2_LOJA                 AS string
	WSDATA   cCE2_NUM                  AS string
	WSDATA   cCE2_PARCELA              AS string
	WSDATA   cCE2_PREFIXO              AS string
	WSDATA   cCE2_TIPO                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSFINA050_STSE2DEL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSFINA050_STSE2DEL
Return

WSMETHOD CLONE WSCLIENT WSFINA050_STSE2DEL
	Local oClone := WSFINA050_STSE2DEL():NEW()
	oClone:cCE2_EMPRESA         := ::cCE2_EMPRESA
	oClone:cCE2_FILIAL          := ::cCE2_FILIAL
	oClone:cCE2_FORNECE         := ::cCE2_FORNECE
	oClone:cCE2_LOJA            := ::cCE2_LOJA
	oClone:cCE2_NUM             := ::cCE2_NUM
	oClone:cCE2_PARCELA         := ::cCE2_PARCELA
	oClone:cCE2_PREFIXO         := ::cCE2_PREFIXO
	oClone:cCE2_TIPO            := ::cCE2_TIPO
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSFINA050_STSE2DEL
	Local cSoap := ""
	cSoap += WSSoapValue("CE2_EMPRESA", ::cCE2_EMPRESA, ::cCE2_EMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE2_FILIAL", ::cCE2_FILIAL, ::cCE2_FILIAL , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE2_FORNECE", ::cCE2_FORNECE, ::cCE2_FORNECE , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE2_LOJA", ::cCE2_LOJA, ::cCE2_LOJA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE2_NUM", ::cCE2_NUM, ::cCE2_NUM , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE2_PARCELA", ::cCE2_PARCELA, ::cCE2_PARCELA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE2_PREFIXO", ::cCE2_PREFIXO, ::cCE2_PREFIXO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE2_TIPO", ::cCE2_TIPO, ::cCE2_TIPO , "string", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure STCONTASAPAGAR

WSSTRUCT WSFINA050_STCONTASAPAGAR
	WSDATA   oWSSCAB                   AS WSFINA050_STCABSE2
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSFINA050_STCONTASAPAGAR
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSFINA050_STCONTASAPAGAR
Return

WSMETHOD CLONE WSCLIENT WSFINA050_STCONTASAPAGAR
	Local oClone := WSFINA050_STCONTASAPAGAR():NEW()
	oClone:oWSSCAB              := IIF(::oWSSCAB = NIL , NIL , ::oWSSCAB:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSFINA050_STCONTASAPAGAR
	Local cSoap := ""
	cSoap += WSSoapValue("SCAB", ::oWSSCAB, ::oWSSCAB , "STCABSE2", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure STCHAVESE2

WSSTRUCT WSFINA050_STCHAVESE2
	WSDATA   cCE2_EMPRESA              AS string
	WSDATA   cCE2_FILIAL               AS string
	WSDATA   cCE2_FORNECE              AS string
	WSDATA   cCE2_LOJA                 AS string
	WSDATA   cCE2_NUM                  AS string
	WSDATA   cCE2_PARCELA              AS string
	WSDATA   cCE2_PREFIXO              AS string
	WSDATA   cCE2_TIPO                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSFINA050_STCHAVESE2
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSFINA050_STCHAVESE2
Return

WSMETHOD CLONE WSCLIENT WSFINA050_STCHAVESE2
	Local oClone := WSFINA050_STCHAVESE2():NEW()
	oClone:cCE2_EMPRESA         := ::cCE2_EMPRESA
	oClone:cCE2_FILIAL          := ::cCE2_FILIAL
	oClone:cCE2_FORNECE         := ::cCE2_FORNECE
	oClone:cCE2_LOJA            := ::cCE2_LOJA
	oClone:cCE2_NUM             := ::cCE2_NUM
	oClone:cCE2_PARCELA         := ::cCE2_PARCELA
	oClone:cCE2_PREFIXO         := ::cCE2_PREFIXO
	oClone:cCE2_TIPO            := ::cCE2_TIPO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSFINA050_STCHAVESE2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCE2_EMPRESA       :=  WSAdvValue( oResponse,"_CE2_EMPRESA","string",NIL,"Property cCE2_EMPRESA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCE2_FILIAL        :=  WSAdvValue( oResponse,"_CE2_FILIAL","string",NIL,"Property cCE2_FILIAL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCE2_FORNECE       :=  WSAdvValue( oResponse,"_CE2_FORNECE","string",NIL,"Property cCE2_FORNECE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCE2_LOJA          :=  WSAdvValue( oResponse,"_CE2_LOJA","string",NIL,"Property cCE2_LOJA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCE2_NUM           :=  WSAdvValue( oResponse,"_CE2_NUM","string",NIL,"Property cCE2_NUM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCE2_PARCELA       :=  WSAdvValue( oResponse,"_CE2_PARCELA","string",NIL,"Property cCE2_PARCELA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCE2_PREFIXO       :=  WSAdvValue( oResponse,"_CE2_PREFIXO","string",NIL,"Property cCE2_PREFIXO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCE2_TIPO          :=  WSAdvValue( oResponse,"_CE2_TIPO","string",NIL,"Property cCE2_TIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure STCABSE2

WSSTRUCT WSFINA050_STCABSE2
	WSDATA   cCAFR_PROJETO             AS string
	WSDATA   cCAFR_TAREFA              AS string
	WSDATA   cCE2_EMISSAO              AS string
	WSDATA   cCE2_EMPRESA              AS string
	WSDATA   cCE2_FILIAL               AS string
	WSDATA   cCE2_FORNECE              AS string
	WSDATA   cCE2_LOJA                 AS string
	WSDATA   cCE2_NATUREZ              AS string
	WSDATA   cCE2_NUM                  AS string
	WSDATA   cCE2_PARCELA              AS string
	WSDATA   cCE2_PREFIXO              AS string
	WSDATA   cCE2_TIPO                 AS string
	WSDATA   cCE2_VENCTO               AS string
	WSDATA   nNE2_VALOR                AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSFINA050_STCABSE2
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSFINA050_STCABSE2
Return

WSMETHOD CLONE WSCLIENT WSFINA050_STCABSE2
	Local oClone := WSFINA050_STCABSE2():NEW()
	oClone:cCAFR_PROJETO        := ::cCAFR_PROJETO
	oClone:cCAFR_TAREFA         := ::cCAFR_TAREFA
	oClone:cCE2_EMISSAO         := ::cCE2_EMISSAO
	oClone:cCE2_EMPRESA         := ::cCE2_EMPRESA
	oClone:cCE2_FILIAL          := ::cCE2_FILIAL
	oClone:cCE2_FORNECE         := ::cCE2_FORNECE
	oClone:cCE2_LOJA            := ::cCE2_LOJA
	oClone:cCE2_NATUREZ         := ::cCE2_NATUREZ
	oClone:cCE2_NUM             := ::cCE2_NUM
	oClone:cCE2_PARCELA         := ::cCE2_PARCELA
	oClone:cCE2_PREFIXO         := ::cCE2_PREFIXO
	oClone:cCE2_TIPO            := ::cCE2_TIPO
	oClone:cCE2_VENCTO          := ::cCE2_VENCTO
	oClone:nNE2_VALOR           := ::nNE2_VALOR
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSFINA050_STCABSE2
	Local cSoap := ""
	cSoap += WSSoapValue("CAFR_PROJETO", ::cCAFR_PROJETO, ::cCAFR_PROJETO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CAFR_TAREFA", ::cCAFR_TAREFA, ::cCAFR_TAREFA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE2_EMISSAO", ::cCE2_EMISSAO, ::cCE2_EMISSAO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE2_EMPRESA", ::cCE2_EMPRESA, ::cCE2_EMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE2_FILIAL", ::cCE2_FILIAL, ::cCE2_FILIAL , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE2_FORNECE", ::cCE2_FORNECE, ::cCE2_FORNECE , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE2_LOJA", ::cCE2_LOJA, ::cCE2_LOJA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE2_NATUREZ", ::cCE2_NATUREZ, ::cCE2_NATUREZ , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE2_NUM", ::cCE2_NUM, ::cCE2_NUM , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE2_PARCELA", ::cCE2_PARCELA, ::cCE2_PARCELA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE2_PREFIXO", ::cCE2_PREFIXO, ::cCE2_PREFIXO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE2_TIPO", ::cCE2_TIPO, ::cCE2_TIPO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CE2_VENCTO", ::cCE2_VENCTO, ::cCE2_VENCTO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NE2_VALOR", ::nNE2_VALOR, ::nNE2_VALOR , "float", .T. , .F., 0 , NIL, .F.) 
Return cSoap


