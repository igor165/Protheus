#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://bhd0005489:86/WSMATA120.apw?WSDL
Gerado em        04/09/13 18:02:37
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _ZSAHZNH ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSMATA120
------------------------------------------------------------------------------- */

WSCLIENT WSWSMATA120

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ALTERAR
	WSMETHOD EXCLUI
	WSMETHOD INCLUI

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSSPEDIDOCOMPRA          AS WSMATA120_STPEDIDOCOMPRA
	WSDATA   cNUM_PEDIDO               AS string
	WSDATA   cALTERARRESULT            AS string
	WSDATA   oWSSSC7EXCLUI             AS WSMATA120_STEXCLUISC7
	WSDATA   cEXCLUIRESULT             AS string
	WSDATA   cINCLUIRESULT             AS string

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSSTPEDIDOCOMPRA         AS WSMATA120_STPEDIDOCOMPRA
	WSDATA   oWSSTEXCLUISC7            AS WSMATA120_STEXCLUISC7

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSMATA120
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.120420A-20120726] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSMATA120
	::oWSSPEDIDOCOMPRA   := WSMATA120_STPEDIDOCOMPRA():New()
	::oWSSSC7EXCLUI      := WSMATA120_STEXCLUISC7():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSTPEDIDOCOMPRA  := ::oWSSPEDIDOCOMPRA
	::oWSSTEXCLUISC7     := ::oWSSSC7EXCLUI
Return

WSMETHOD RESET WSCLIENT WSWSMATA120
	::oWSSPEDIDOCOMPRA   := NIL 
	::cNUM_PEDIDO        := NIL 
	::cALTERARRESULT     := NIL 
	::oWSSSC7EXCLUI      := NIL 
	::cEXCLUIRESULT      := NIL 
	::cINCLUIRESULT      := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSTPEDIDOCOMPRA  := NIL
	::oWSSTEXCLUISC7     := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSMATA120
Local oClone := WSWSMATA120():New()
	oClone:_URL          := ::_URL 
	oClone:oWSSPEDIDOCOMPRA :=  IIF(::oWSSPEDIDOCOMPRA = NIL , NIL ,::oWSSPEDIDOCOMPRA:Clone() )
	oClone:cNUM_PEDIDO   := ::cNUM_PEDIDO
	oClone:cALTERARRESULT := ::cALTERARRESULT
	oClone:oWSSSC7EXCLUI :=  IIF(::oWSSSC7EXCLUI = NIL , NIL ,::oWSSSC7EXCLUI:Clone() )
	oClone:cEXCLUIRESULT := ::cEXCLUIRESULT
	oClone:cINCLUIRESULT := ::cINCLUIRESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSSTPEDIDOCOMPRA := oClone:oWSSPEDIDOCOMPRA
	oClone:oWSSTEXCLUISC7 := oClone:oWSSSC7EXCLUI
Return oClone

// WSDL Method ALTERAR of Service WSWSMATA120

WSMETHOD ALTERAR WSSEND oWSSPEDIDOCOMPRA,cNUM_PEDIDO WSRECEIVE cALTERARRESULT WSCLIENT WSWSMATA120
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ALTERAR xmlns="http://www.totvs.com.br/rm/">'
cSoap += WSSoapValue("SPEDIDOCOMPRA", ::oWSSPEDIDOCOMPRA, oWSSPEDIDOCOMPRA , "STPEDIDOCOMPRA", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NUM_PEDIDO", ::cNUM_PEDIDO, cNUM_PEDIDO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</ALTERAR>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.totvs.com.br/rm/ALTERAR",; 
	"DOCUMENT","http://www.totvs.com.br/rm/",,"1.031217",; 
	"http://bhd0005489:86/WSMATA120.apw")

::Init()
::cALTERARRESULT     :=  WSAdvValue( oXmlRet,"_ALTERARRESPONSE:_ALTERARRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EXCLUI of Service WSWSMATA120

WSMETHOD EXCLUI WSSEND oWSSSC7EXCLUI WSRECEIVE cEXCLUIRESULT WSCLIENT WSWSMATA120
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EXCLUI xmlns="http://www.totvs.com.br/rm/">'
cSoap += WSSoapValue("SSC7EXCLUI", ::oWSSSC7EXCLUI, oWSSSC7EXCLUI , "STEXCLUISC7", .T. , .F., 0 , NIL, .F.) 
cSoap += "</EXCLUI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.totvs.com.br/rm/EXCLUI",; 
	"DOCUMENT","http://www.totvs.com.br/rm/",,"1.031217",; 
	"http://bhd0005489:86/WSMATA120.apw")

::Init()
::cEXCLUIRESULT      :=  WSAdvValue( oXmlRet,"_EXCLUIRESPONSE:_EXCLUIRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INCLUI of Service WSWSMATA120

WSMETHOD INCLUI WSSEND oWSSPEDIDOCOMPRA WSRECEIVE cINCLUIRESULT WSCLIENT WSWSMATA120
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INCLUI xmlns="http://www.totvs.com.br/rm/">'
cSoap += WSSoapValue("SPEDIDOCOMPRA", ::oWSSPEDIDOCOMPRA, oWSSPEDIDOCOMPRA , "STPEDIDOCOMPRA", .T. , .F., 0 , NIL, .F.) 
cSoap += "</INCLUI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.totvs.com.br/rm/INCLUI",; 
	"DOCUMENT","http://www.totvs.com.br/rm/",,"1.031217",; 
	"http://bhd0005489:86/WSMATA120.apw")

::Init()
::cINCLUIRESULT      :=  WSAdvValue( oXmlRet,"_INCLUIRESPONSE:_INCLUIRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure STPEDIDOCOMPRA

WSSTRUCT WSMATA120_STPEDIDOCOMPRA
	WSDATA   oWSSADTPC                 AS WSMATA120_ARRAYOFAADTPC OPTIONAL
	WSDATA   oWSSCAB                   AS WSMATA120_STCABSC7
	WSDATA   oWSSCOR                   AS WSMATA120_ARRAYOFSTCORSC7
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA120_STPEDIDOCOMPRA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA120_STPEDIDOCOMPRA
Return

WSMETHOD CLONE WSCLIENT WSMATA120_STPEDIDOCOMPRA
	Local oClone := WSMATA120_STPEDIDOCOMPRA():NEW()
	oClone:oWSSADTPC            := IIF(::oWSSADTPC = NIL , NIL , ::oWSSADTPC:Clone() )
	oClone:oWSSCAB              := IIF(::oWSSCAB = NIL , NIL , ::oWSSCAB:Clone() )
	oClone:oWSSCOR              := IIF(::oWSSCOR = NIL , NIL , ::oWSSCOR:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA120_STPEDIDOCOMPRA
	Local cSoap := ""
	cSoap += WSSoapValue("SADTPC", ::oWSSADTPC, ::oWSSADTPC , "ARRAYOFAADTPC", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("SCAB", ::oWSSCAB, ::oWSSCAB , "STCABSC7", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("SCOR", ::oWSSCOR, ::oWSSCOR , "ARRAYOFSTCORSC7", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure STEXCLUISC7

WSSTRUCT WSMATA120_STEXCLUISC7
	WSDATA   cCC7_CODFIL               AS string
	WSDATA   cCC7_CODID                AS string
	WSDATA   cCC7_EMPRESA              AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA120_STEXCLUISC7
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA120_STEXCLUISC7
Return

WSMETHOD CLONE WSCLIENT WSMATA120_STEXCLUISC7
	Local oClone := WSMATA120_STEXCLUISC7():NEW()
	oClone:cCC7_CODFIL          := ::cCC7_CODFIL
	oClone:cCC7_CODID           := ::cCC7_CODID
	oClone:cCC7_EMPRESA         := ::cCC7_EMPRESA
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA120_STEXCLUISC7
	Local cSoap := ""
	cSoap += WSSoapValue("CC7_CODFIL", ::cCC7_CODFIL, ::cCC7_CODFIL , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CC7_CODID", ::cCC7_CODID, ::cCC7_CODID , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CC7_EMPRESA", ::cCC7_EMPRESA, ::cCC7_EMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ARRAYOFAADTPC

WSSTRUCT WSMATA120_ARRAYOFAADTPC
	WSDATA   oWSAADTPC                 AS WSMATA120_AADTPC OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA120_ARRAYOFAADTPC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA120_ARRAYOFAADTPC
	::oWSAADTPC            := {} // Array Of  WSMATA120_AADTPC():New()
Return

WSMETHOD CLONE WSCLIENT WSMATA120_ARRAYOFAADTPC
	Local oClone := WSMATA120_ARRAYOFAADTPC():NEW()
	oClone:oWSAADTPC := NIL
	If ::oWSAADTPC <> NIL 
		oClone:oWSAADTPC := {}
		aEval( ::oWSAADTPC , { |x| aadd( oClone:oWSAADTPC , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA120_ARRAYOFAADTPC
	Local cSoap := ""
	aEval( ::oWSAADTPC , {|x| cSoap := cSoap  +  WSSoapValue("AADTPC", x , x , "AADTPC", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure STCABSC7

WSSTRUCT WSMATA120_STCABSC7
	WSDATA   cC7_COND                  AS string
	WSDATA   cC7_EMISSAO               AS string
	WSDATA   cC7_EMPRESA               AS string
	WSDATA   cC7_FILIAL                AS string
	WSDATA   cC7_FORNECE               AS string
	WSDATA   cC7_LOJA                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA120_STCABSC7
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA120_STCABSC7
Return

WSMETHOD CLONE WSCLIENT WSMATA120_STCABSC7
	Local oClone := WSMATA120_STCABSC7():NEW()
	oClone:cC7_COND             := ::cC7_COND
	oClone:cC7_EMISSAO          := ::cC7_EMISSAO
	oClone:cC7_EMPRESA          := ::cC7_EMPRESA
	oClone:cC7_FILIAL           := ::cC7_FILIAL
	oClone:cC7_FORNECE          := ::cC7_FORNECE
	oClone:cC7_LOJA             := ::cC7_LOJA
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA120_STCABSC7
	Local cSoap := ""
	cSoap += WSSoapValue("C7_COND", ::cC7_COND, ::cC7_COND , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C7_EMISSAO", ::cC7_EMISSAO, ::cC7_EMISSAO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C7_EMPRESA", ::cC7_EMPRESA, ::cC7_EMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C7_FILIAL", ::cC7_FILIAL, ::cC7_FILIAL , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C7_FORNECE", ::cC7_FORNECE, ::cC7_FORNECE , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C7_LOJA", ::cC7_LOJA, ::cC7_LOJA , "string", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ARRAYOFSTCORSC7

WSSTRUCT WSMATA120_ARRAYOFSTCORSC7
	WSDATA   oWSSTCORSC7               AS WSMATA120_STCORSC7 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA120_ARRAYOFSTCORSC7
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA120_ARRAYOFSTCORSC7
	::oWSSTCORSC7          := {} // Array Of  WSMATA120_STCORSC7():New()
Return

WSMETHOD CLONE WSCLIENT WSMATA120_ARRAYOFSTCORSC7
	Local oClone := WSMATA120_ARRAYOFSTCORSC7():NEW()
	oClone:oWSSTCORSC7 := NIL
	If ::oWSSTCORSC7 <> NIL 
		oClone:oWSSTCORSC7 := {}
		aEval( ::oWSSTCORSC7 , { |x| aadd( oClone:oWSSTCORSC7 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA120_ARRAYOFSTCORSC7
	Local cSoap := ""
	aEval( ::oWSSTCORSC7 , {|x| cSoap := cSoap  +  WSSoapValue("STCORSC7", x , x , "STCORSC7", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure AADTPC

WSSTRUCT WSMATA120_AADTPC
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

WSMETHOD NEW WSCLIENT WSMATA120_AADTPC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA120_AADTPC
Return

WSMETHOD CLONE WSCLIENT WSMATA120_AADTPC
	Local oClone := WSMATA120_AADTPC():NEW()
	oClone:cFIE_NUM             := ::cFIE_NUM
	oClone:cFIE_PARCEL          := ::cFIE_PARCEL
	oClone:cFIE_PREFIX          := ::cFIE_PREFIX
	oClone:cFIE_TIPO            := ::cFIE_TIPO
	oClone:nFIE_VALOR           := ::nFIE_VALOR
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA120_AADTPC
	Local cSoap := ""
	cSoap += WSSoapValue("FIE_NUM", ::cFIE_NUM, ::cFIE_NUM , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("FIE_PARCEL", ::cFIE_PARCEL, ::cFIE_PARCEL , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("FIE_PREFIX", ::cFIE_PREFIX, ::cFIE_PREFIX , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("FIE_TIPO", ::cFIE_TIPO, ::cFIE_TIPO , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("FIE_VALOR", ::nFIE_VALOR, ::nFIE_VALOR , "float", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure STCORSC7

WSSTRUCT WSMATA120_STCORSC7
	WSDATA   cAJ7_PROJET               AS string OPTIONAL
	WSDATA   cAJ7_TAREFA               AS string OPTIONAL
	WSDATA   cC7_CC                    AS string OPTIONAL
	WSDATA   cC7_ITEM                  AS string
	WSDATA   nC7_PRECO                 AS float
	WSDATA   cC7_PRODUTO               AS string
	WSDATA   nC7_QUANT                 AS float
	WSDATA   oWSSPROJAJ7               AS WSMATA120_ARRAYOFAPROJAJ7 OPTIONAL
	WSDATA   oWSSRATCTBPC              AS WSMATA120_ARRAYOFARATCTBPC OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA120_STCORSC7
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA120_STCORSC7
Return

WSMETHOD CLONE WSCLIENT WSMATA120_STCORSC7
	Local oClone := WSMATA120_STCORSC7():NEW()
	oClone:cAJ7_PROJET          := ::cAJ7_PROJET
	oClone:cAJ7_TAREFA          := ::cAJ7_TAREFA
	oClone:cC7_CC               := ::cC7_CC
	oClone:cC7_ITEM             := ::cC7_ITEM
	oClone:nC7_PRECO            := ::nC7_PRECO
	oClone:cC7_PRODUTO          := ::cC7_PRODUTO
	oClone:nC7_QUANT            := ::nC7_QUANT
	oClone:oWSSPROJAJ7          := IIF(::oWSSPROJAJ7 = NIL , NIL , ::oWSSPROJAJ7:Clone() )
	oClone:oWSSRATCTBPC         := IIF(::oWSSRATCTBPC = NIL , NIL , ::oWSSRATCTBPC:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA120_STCORSC7
	Local cSoap := ""
	cSoap += WSSoapValue("AJ7_PROJET", ::cAJ7_PROJET, ::cAJ7_PROJET , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("AJ7_TAREFA", ::cAJ7_TAREFA, ::cAJ7_TAREFA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C7_CC", ::cC7_CC, ::cC7_CC , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C7_ITEM", ::cC7_ITEM, ::cC7_ITEM , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C7_PRECO", ::nC7_PRECO, ::nC7_PRECO , "float", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C7_PRODUTO", ::cC7_PRODUTO, ::cC7_PRODUTO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("C7_QUANT", ::nC7_QUANT, ::nC7_QUANT , "float", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("SPROJAJ7", ::oWSSPROJAJ7, ::oWSSPROJAJ7 , "ARRAYOFAPROJAJ7", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("SRATCTBPC", ::oWSSRATCTBPC, ::oWSSRATCTBPC , "ARRAYOFARATCTBPC", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ARRAYOFAPROJAJ7

WSSTRUCT WSMATA120_ARRAYOFAPROJAJ7
	WSDATA   oWSAPROJAJ7               AS WSMATA120_APROJAJ7 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA120_ARRAYOFAPROJAJ7
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA120_ARRAYOFAPROJAJ7
	::oWSAPROJAJ7          := {} // Array Of  WSMATA120_APROJAJ7():New()
Return

WSMETHOD CLONE WSCLIENT WSMATA120_ARRAYOFAPROJAJ7
	Local oClone := WSMATA120_ARRAYOFAPROJAJ7():NEW()
	oClone:oWSAPROJAJ7 := NIL
	If ::oWSAPROJAJ7 <> NIL 
		oClone:oWSAPROJAJ7 := {}
		aEval( ::oWSAPROJAJ7 , { |x| aadd( oClone:oWSAPROJAJ7 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA120_ARRAYOFAPROJAJ7
	Local cSoap := ""
	aEval( ::oWSAPROJAJ7 , {|x| cSoap := cSoap  +  WSSoapValue("APROJAJ7", x , x , "APROJAJ7", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFARATCTBPC

WSSTRUCT WSMATA120_ARRAYOFARATCTBPC
	WSDATA   oWSARATCTBPC              AS WSMATA120_ARATCTBPC OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA120_ARRAYOFARATCTBPC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA120_ARRAYOFARATCTBPC
	::oWSARATCTBPC         := {} // Array Of  WSMATA120_ARATCTBPC():New()
Return

WSMETHOD CLONE WSCLIENT WSMATA120_ARRAYOFARATCTBPC
	Local oClone := WSMATA120_ARRAYOFARATCTBPC():NEW()
	oClone:oWSARATCTBPC := NIL
	If ::oWSARATCTBPC <> NIL 
		oClone:oWSARATCTBPC := {}
		aEval( ::oWSARATCTBPC , { |x| aadd( oClone:oWSARATCTBPC , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA120_ARRAYOFARATCTBPC
	Local cSoap := ""
	aEval( ::oWSARATCTBPC , {|x| cSoap := cSoap  +  WSSoapValue("ARATCTBPC", x , x , "ARATCTBPC", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure APROJAJ7

WSSTRUCT WSMATA120_APROJAJ7
	WSDATA   cCAJ7_PROJET              AS string
	WSDATA   cCAJ7_TAREFA              AS string
	WSDATA   nNAJ7_QUANT               AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA120_APROJAJ7
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA120_APROJAJ7
Return

WSMETHOD CLONE WSCLIENT WSMATA120_APROJAJ7
	Local oClone := WSMATA120_APROJAJ7():NEW()
	oClone:cCAJ7_PROJET         := ::cCAJ7_PROJET
	oClone:cCAJ7_TAREFA         := ::cCAJ7_TAREFA
	oClone:nNAJ7_QUANT          := ::nNAJ7_QUANT
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA120_APROJAJ7
	Local cSoap := ""
	cSoap += WSSoapValue("CAJ7_PROJET", ::cCAJ7_PROJET, ::cCAJ7_PROJET , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CAJ7_TAREFA", ::cCAJ7_TAREFA, ::cCAJ7_TAREFA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NAJ7_QUANT", ::nNAJ7_QUANT, ::nNAJ7_QUANT , "float", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ARATCTBPC

WSSTRUCT WSMATA120_ARATCTBPC
	WSDATA   cCH_CC                    AS string OPTIONAL
	WSDATA   cCH_CLVL                  AS string OPTIONAL
	WSDATA   cCH_CONTA                 AS string OPTIONAL
	WSDATA   cCH_ITEMCTA               AS string OPTIONAL
	WSDATA   nCH_PERC                  AS float OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA120_ARATCTBPC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA120_ARATCTBPC
Return

WSMETHOD CLONE WSCLIENT WSMATA120_ARATCTBPC
	Local oClone := WSMATA120_ARATCTBPC():NEW()
	oClone:cCH_CC               := ::cCH_CC
	oClone:cCH_CLVL             := ::cCH_CLVL
	oClone:cCH_CONTA            := ::cCH_CONTA
	oClone:cCH_ITEMCTA          := ::cCH_ITEMCTA
	oClone:nCH_PERC             := ::nCH_PERC
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA120_ARATCTBPC
	Local cSoap := ""
	cSoap += WSSoapValue("CH_CC", ::cCH_CC, ::cCH_CC , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CH_CLVL", ::cCH_CLVL, ::cCH_CLVL , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CH_CONTA", ::cCH_CONTA, ::cCH_CONTA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CH_ITEMCTA", ::cCH_ITEMCTA, ::cCH_ITEMCTA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CH_PERC", ::nCH_PERC, ::nCH_PERC , "float", .F. , .F., 0 , NIL, .F.) 
Return cSoap


