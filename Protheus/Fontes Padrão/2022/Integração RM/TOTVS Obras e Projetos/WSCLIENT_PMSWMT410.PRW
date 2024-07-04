#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:83/WSMATA410.apw?WSDL
Gerado em        11/16/10 15:44:06
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.100712
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _XUGBOVP ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSMATA410
------------------------------------------------------------------------------- */

WSCLIENT WSWSMATA410

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ALTERAR
	WSMETHOD EXCLUI
	WSMETHOD INCLUI

	WSDATA   _URL                      AS String
	WSDATA   oWSSPEDIDOVENDA           AS WSMATA410_STPEDIDOVENDA
	WSDATA   cNUM_PEDIDO               AS string
	WSDATA   cALTERARRESULT            AS string
	WSDATA   oWSSSC5EXCLUI             AS WSMATA410_STEXCLUISC5
	WSDATA   cEXCLUIRESULT             AS string
	WSDATA   cINCLUIRESULT             AS string

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSSTPEDIDOVENDA          AS WSMATA410_STPEDIDOVENDA
	WSDATA   oWSSTEXCLUISC5            AS WSMATA410_STEXCLUISC5

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSMATA410
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.081215P-20090714] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSMATA410
	::oWSSPEDIDOVENDA    := WSMATA410_STPEDIDOVENDA():New()
	::oWSSSC5EXCLUI      := WSMATA410_STEXCLUISC5():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSTPEDIDOVENDA   := ::oWSSPEDIDOVENDA
	::oWSSTEXCLUISC5     := ::oWSSSC5EXCLUI
Return

WSMETHOD RESET WSCLIENT WSWSMATA410
	::oWSSPEDIDOVENDA    := NIL 
	::cNUM_PEDIDO        := NIL 
	::cALTERARRESULT     := NIL 
	::oWSSSC5EXCLUI      := NIL 
	::cEXCLUIRESULT      := NIL 
	::cINCLUIRESULT      := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSTPEDIDOVENDA   := NIL
	::oWSSTEXCLUISC5     := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSMATA410
Local oClone := WSWSMATA410():New()
	oClone:_URL          := ::_URL 
	oClone:oWSSPEDIDOVENDA :=  IIF(::oWSSPEDIDOVENDA = NIL , NIL ,::oWSSPEDIDOVENDA:Clone() )
	oClone:cNUM_PEDIDO   := ::cNUM_PEDIDO
	oClone:cALTERARRESULT := ::cALTERARRESULT
	oClone:oWSSSC5EXCLUI :=  IIF(::oWSSSC5EXCLUI = NIL , NIL ,::oWSSSC5EXCLUI:Clone() )
	oClone:cEXCLUIRESULT := ::cEXCLUIRESULT
	oClone:cINCLUIRESULT := ::cINCLUIRESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSSTPEDIDOVENDA := oClone:oWSSPEDIDOVENDA
	oClone:oWSSTEXCLUISC5 := oClone:oWSSSC5EXCLUI
Return oClone

// WSDL Method ALTERAR of Service WSWSMATA410

WSMETHOD ALTERAR WSSEND oWSSPEDIDOVENDA,cNUM_PEDIDO WSRECEIVE cALTERARRESULT WSCLIENT WSWSMATA410
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ALTERAR xmlns="http://www.totvs.com.br/rm/">'
cSoap += WSSoapValue("SPEDIDOVENDA", ::oWSSPEDIDOVENDA, oWSSPEDIDOVENDA , "STPEDIDOVENDA", .T. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("NUM_PEDIDO", ::cNUM_PEDIDO, cNUM_PEDIDO , "string", .T. , .F., 0 , NIL, .T.) 
cSoap += "</ALTERAR>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.totvs.com.br/rm/ALTERAR",; 
	"DOCUMENT","http://www.totvs.com.br/rm/",,"1.031217",; 
	"http://localhost:83/WSMATA410.apw")

::Init()
::cALTERARRESULT     :=  WSAdvValue( oXmlRet,"_ALTERARRESPONSE:_ALTERARRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EXCLUI of Service WSWSMATA410

WSMETHOD EXCLUI WSSEND oWSSSC5EXCLUI WSRECEIVE cEXCLUIRESULT WSCLIENT WSWSMATA410
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EXCLUI xmlns="http://www.totvs.com.br/rm/">'
cSoap += WSSoapValue("SSC5EXCLUI", ::oWSSSC5EXCLUI, oWSSSC5EXCLUI , "STEXCLUISC5", .T. , .F., 0 , NIL, .T.) 
cSoap += "</EXCLUI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.totvs.com.br/rm/EXCLUI",; 
	"DOCUMENT","http://www.totvs.com.br/rm/",,"1.031217",; 
	"http://localhost:83/WSMATA410.apw")

::Init()
::cEXCLUIRESULT      :=  WSAdvValue( oXmlRet,"_EXCLUIRESPONSE:_EXCLUIRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INCLUI of Service WSWSMATA410

WSMETHOD INCLUI WSSEND oWSSPEDIDOVENDA WSRECEIVE cINCLUIRESULT WSCLIENT WSWSMATA410
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INCLUI xmlns="http://www.totvs.com.br/rm/">'
cSoap += WSSoapValue("SPEDIDOVENDA", ::oWSSPEDIDOVENDA, oWSSPEDIDOVENDA , "STPEDIDOVENDA", .T. , .F., 0 , NIL, .T.) 
cSoap += "</INCLUI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.totvs.com.br/rm/INCLUI",; 
	"DOCUMENT","http://www.totvs.com.br/rm/",,"1.031217",; 
	"http://localhost:83/WSMATA410.apw")

::Init()
::cINCLUIRESULT      :=  WSAdvValue( oXmlRet,"_INCLUIRESPONSE:_INCLUIRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure STPEDIDOVENDA

WSSTRUCT WSMATA410_STPEDIDOVENDA
	WSDATA   oWSSADTPV                 AS WSMATA410_ARRAYOFARADTPV OPTIONAL
	WSDATA   oWSSCAB                   AS WSMATA410_STCABSC5
	WSDATA   oWSSCOR                   AS WSMATA410_ARRAYOFCTCORSC6
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA410_STPEDIDOVENDA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA410_STPEDIDOVENDA
Return

WSMETHOD CLONE WSCLIENT WSMATA410_STPEDIDOVENDA
	Local oClone := WSMATA410_STPEDIDOVENDA():NEW()
	oClone:oWSSADTPV            := IIF(::oWSSADTPV = NIL , NIL , ::oWSSADTPV:Clone() )
	oClone:oWSSCAB              := IIF(::oWSSCAB = NIL , NIL , ::oWSSCAB:Clone() )
	oClone:oWSSCOR              := IIF(::oWSSCOR = NIL , NIL , ::oWSSCOR:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA410_STPEDIDOVENDA
	Local cSoap := ""
	cSoap += WSSoapValue("SADTPV", ::oWSSADTPV, ::oWSSADTPV , "ARRAYOFARADTPV", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("SCAB", ::oWSSCAB, ::oWSSCAB , "STCABSC5", .T. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("SCOR", ::oWSSCOR, ::oWSSCOR , "ARRAYOFCTCORSC6", .T. , .F., 0 , NIL, .T.) 
Return cSoap

// WSDL Data Structure STEXCLUISC5

WSSTRUCT WSMATA410_STEXCLUISC5
	WSDATA   cCC5_CODFIL               AS string
	WSDATA   cCC5_CODID                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA410_STEXCLUISC5
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA410_STEXCLUISC5
Return

WSMETHOD CLONE WSCLIENT WSMATA410_STEXCLUISC5
	Local oClone := WSMATA410_STEXCLUISC5():NEW()
	oClone:cCC5_CODFIL          := ::cCC5_CODFIL
	oClone:cCC5_CODID           := ::cCC5_CODID
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA410_STEXCLUISC5
	Local cSoap := ""
	cSoap += WSSoapValue("CC5_CODFIL", ::cCC5_CODFIL, ::cCC5_CODFIL , "string", .T. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CC5_CODID", ::cCC5_CODID, ::cCC5_CODID , "string", .T. , .F., 0 , NIL, .T.) 
Return cSoap

// WSDL Data Structure ARRAYOFARADTPV

WSSTRUCT WSMATA410_ARRAYOFARADTPV
	WSDATA   oWSARADTPV                AS WSMATA410_ARADTPV OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA410_ARRAYOFARADTPV
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA410_ARRAYOFARADTPV
	::oWSARADTPV           := {} // Array Of  WSMATA410_ARADTPV():New()
Return

WSMETHOD CLONE WSCLIENT WSMATA410_ARRAYOFARADTPV
	Local oClone := WSMATA410_ARRAYOFARADTPV():NEW()
	oClone:oWSARADTPV := NIL
	If ::oWSARADTPV <> NIL 
		oClone:oWSARADTPV := {}
		aEval( ::oWSARADTPV , { |x| aadd( oClone:oWSARADTPV , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA410_ARRAYOFARADTPV
	Local cSoap := ""
	aEval( ::oWSARADTPV , {|x| cSoap := cSoap  +  WSSoapValue("ARADTPV", x , x , "ARADTPV", .F. , .F., 0 , NIL, .T.)  } ) 
Return cSoap

// WSDL Data Structure STCABSC5

WSSTRUCT WSMATA410_STCABSC5
	WSDATA   cC5_CLIENTE               AS string
	WSDATA   cC5_CONDPAG               AS string
	WSDATA   cC5_FILIAL                AS string
	WSDATA   cC5_LOJACLI               AS string
	WSDATA   cC5_TIPO                  AS string
	WSDATA   cC5_TIPOCLI               AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA410_STCABSC5
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA410_STCABSC5
Return

WSMETHOD CLONE WSCLIENT WSMATA410_STCABSC5
	Local oClone := WSMATA410_STCABSC5():NEW()
	oClone:cC5_CLIENTE          := ::cC5_CLIENTE
	oClone:cC5_CONDPAG          := ::cC5_CONDPAG
	oClone:cC5_FILIAL           := ::cC5_FILIAL
	oClone:cC5_LOJACLI          := ::cC5_LOJACLI
	oClone:cC5_TIPO             := ::cC5_TIPO
	oClone:cC5_TIPOCLI          := ::cC5_TIPOCLI
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA410_STCABSC5
	Local cSoap := ""
	cSoap += WSSoapValue("C5_CLIENTE", ::cC5_CLIENTE, ::cC5_CLIENTE , "string", .T. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("C5_CONDPAG", ::cC5_CONDPAG, ::cC5_CONDPAG , "string", .T. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("C5_FILIAL", ::cC5_FILIAL, ::cC5_FILIAL , "string", .T. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("C5_LOJACLI", ::cC5_LOJACLI, ::cC5_LOJACLI , "string", .T. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("C5_TIPO", ::cC5_TIPO, ::cC5_TIPO , "string", .T. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("C5_TIPOCLI", ::cC5_TIPOCLI, ::cC5_TIPOCLI , "string", .T. , .F., 0 , NIL, .T.) 
Return cSoap

// WSDL Data Structure ARRAYOFCTCORSC6

WSSTRUCT WSMATA410_ARRAYOFCTCORSC6
	WSDATA   oWSCTCORSC6               AS WSMATA410_CTCORSC6 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA410_ARRAYOFCTCORSC6
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA410_ARRAYOFCTCORSC6
	::oWSCTCORSC6          := {} // Array Of  WSMATA410_CTCORSC6():New()
Return

WSMETHOD CLONE WSCLIENT WSMATA410_ARRAYOFCTCORSC6
	Local oClone := WSMATA410_ARRAYOFCTCORSC6():NEW()
	oClone:oWSCTCORSC6 := NIL
	If ::oWSCTCORSC6 <> NIL 
		oClone:oWSCTCORSC6 := {}
		aEval( ::oWSCTCORSC6 , { |x| aadd( oClone:oWSCTCORSC6 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA410_ARRAYOFCTCORSC6
	Local cSoap := ""
	aEval( ::oWSCTCORSC6 , {|x| cSoap := cSoap  +  WSSoapValue("CTCORSC6", x , x , "CTCORSC6", .F. , .F., 0 , NIL, .T.)  } ) 
Return cSoap

// WSDL Data Structure ARADTPV

WSSTRUCT WSMATA410_ARADTPV
	WSDATA   cFIE_NUM                  AS string OPTIONAL
	WSDATA   cFIE_PARCEL               AS string OPTIONAL
	WSDATA   cFIE_PREFIX               AS string OPTIONAL
	WSDATA   cFIE_TIPO                 AS string OPTIONAL
	WSDATA   nFIE_VALOR                AS float OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA410_ARADTPV
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA410_ARADTPV
Return

WSMETHOD CLONE WSCLIENT WSMATA410_ARADTPV
	Local oClone := WSMATA410_ARADTPV():NEW()
	oClone:cFIE_NUM             := ::cFIE_NUM
	oClone:cFIE_PARCEL          := ::cFIE_PARCEL
	oClone:cFIE_PREFIX          := ::cFIE_PREFIX
	oClone:cFIE_TIPO            := ::cFIE_TIPO
	oClone:nFIE_VALOR           := ::nFIE_VALOR
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA410_ARADTPV
	Local cSoap := ""
	cSoap += WSSoapValue("FIE_NUM", ::cFIE_NUM, ::cFIE_NUM , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("FIE_PARCEL", ::cFIE_PARCEL, ::cFIE_PARCEL , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("FIE_PREFIX", ::cFIE_PREFIX, ::cFIE_PREFIX , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("FIE_TIPO", ::cFIE_TIPO, ::cFIE_TIPO , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("FIE_VALOR", ::nFIE_VALOR, ::nFIE_VALOR , "float", .F. , .F., 0 , NIL, .T.) 
Return cSoap

// WSDL Data Structure CTCORSC6

WSSTRUCT WSMATA410_CTCORSC6
	WSDATA   cC6_CC                    AS string OPTIONAL
	WSDATA   cC6_ITEM                  AS string
	WSDATA   nC6_PRCVEN                AS float
	WSDATA   cC6_PRODUTO               AS string
	WSDATA   cC6_PROJPMS               AS string OPTIONAL
	WSDATA   nC6_QTDVEN                AS float
	WSDATA   cC6_TASKPMS               AS string OPTIONAL
	WSDATA   cC6_TES                   AS string OPTIONAL
	WSDATA   oWSSRATCTBPV              AS WSMATA410_ARRAYOFARRATCTBPV OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA410_CTCORSC6
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA410_CTCORSC6
Return

WSMETHOD CLONE WSCLIENT WSMATA410_CTCORSC6
	Local oClone := WSMATA410_CTCORSC6():NEW()
	oClone:cC6_CC               := ::cC6_CC
	oClone:cC6_ITEM             := ::cC6_ITEM
	oClone:nC6_PRCVEN           := ::nC6_PRCVEN
	oClone:cC6_PRODUTO          := ::cC6_PRODUTO
	oClone:cC6_PROJPMS          := ::cC6_PROJPMS
	oClone:nC6_QTDVEN           := ::nC6_QTDVEN
	oClone:cC6_TASKPMS          := ::cC6_TASKPMS
	oClone:cC6_TES              := ::cC6_TES
	oClone:oWSSRATCTBPV         := IIF(::oWSSRATCTBPV = NIL , NIL , ::oWSSRATCTBPV:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA410_CTCORSC6
	Local cSoap := ""
	cSoap += WSSoapValue("C6_CC", ::cC6_CC, ::cC6_CC , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("C6_ITEM", ::cC6_ITEM, ::cC6_ITEM , "string", .T. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("C6_PRCVEN", ::nC6_PRCVEN, ::nC6_PRCVEN , "float", .T. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("C6_PRODUTO", ::cC6_PRODUTO, ::cC6_PRODUTO , "string", .T. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("C6_PROJPMS", ::cC6_PROJPMS, ::cC6_PROJPMS , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("C6_QTDVEN", ::nC6_QTDVEN, ::nC6_QTDVEN , "float", .T. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("C6_TASKPMS", ::cC6_TASKPMS, ::cC6_TASKPMS , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("C6_TES", ::cC6_TES, ::cC6_TES , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("SRATCTBPV", ::oWSSRATCTBPV, ::oWSSRATCTBPV , "ARRAYOFARRATCTBPV", .F. , .F., 0 , NIL, .T.) 
Return cSoap

// WSDL Data Structure ARRAYOFARRATCTBPV

WSSTRUCT WSMATA410_ARRAYOFARRATCTBPV
	WSDATA   oWSARRATCTBPV             AS WSMATA410_ARRATCTBPV OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA410_ARRAYOFARRATCTBPV
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA410_ARRAYOFARRATCTBPV
	::oWSARRATCTBPV        := {} // Array Of  WSMATA410_ARRATCTBPV():New()
Return

WSMETHOD CLONE WSCLIENT WSMATA410_ARRAYOFARRATCTBPV
	Local oClone := WSMATA410_ARRAYOFARRATCTBPV():NEW()
	oClone:oWSARRATCTBPV := NIL
	If ::oWSARRATCTBPV <> NIL 
		oClone:oWSARRATCTBPV := {}
		aEval( ::oWSARRATCTBPV , { |x| aadd( oClone:oWSARRATCTBPV , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA410_ARRAYOFARRATCTBPV
	Local cSoap := ""
	aEval( ::oWSARRATCTBPV , {|x| cSoap := cSoap  +  WSSoapValue("ARRATCTBPV", x , x , "ARRATCTBPV", .F. , .F., 0 , NIL, .T.)  } ) 
Return cSoap

// WSDL Data Structure ARRATCTBPV

WSSTRUCT WSMATA410_ARRATCTBPV
	WSDATA   cAGG_CC                   AS string OPTIONAL
	WSDATA   cAGG_CLVL                 AS string OPTIONAL
	WSDATA   cAGG_CONTA                AS string OPTIONAL
	WSDATA   cAGG_ITEMCTA              AS string OPTIONAL
	WSDATA   nAGG_PERC                 AS float OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA410_ARRATCTBPV
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA410_ARRATCTBPV
Return

WSMETHOD CLONE WSCLIENT WSMATA410_ARRATCTBPV
	Local oClone := WSMATA410_ARRATCTBPV():NEW()
	oClone:cAGG_CC              := ::cAGG_CC
	oClone:cAGG_CLVL            := ::cAGG_CLVL
	oClone:cAGG_CONTA           := ::cAGG_CONTA
	oClone:cAGG_ITEMCTA         := ::cAGG_ITEMCTA
	oClone:nAGG_PERC            := ::nAGG_PERC
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA410_ARRATCTBPV
	Local cSoap := ""
	cSoap += WSSoapValue("AGG_CC", ::cAGG_CC, ::cAGG_CC , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("AGG_CLVL", ::cAGG_CLVL, ::cAGG_CLVL , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("AGG_CONTA", ::cAGG_CONTA, ::cAGG_CONTA , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("AGG_ITEMCTA", ::cAGG_ITEMCTA, ::cAGG_ITEMCTA , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("AGG_PERC", ::nAGG_PERC, ::nAGG_PERC , "float", .F. , .F., 0 , NIL, .T.) 
Return cSoap
