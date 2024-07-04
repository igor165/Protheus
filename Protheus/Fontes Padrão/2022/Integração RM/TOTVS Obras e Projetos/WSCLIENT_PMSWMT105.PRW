#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:86/WSMATA105.apw?WSDL
Gerado em        07/09/13 18:13:35
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _MYMQNUO ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSMATA105
------------------------------------------------------------------------------- */

WSCLIENT WSWSMATA105

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD EXCLUI
	WSMETHOD INCLUI

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSSCPEXCLUI              AS WSMATA105_STCPDEL
	WSDATA   cEXCLUIRESULT             AS string
	WSDATA   oWSSSOLICITACAO           AS WSMATA105_STSOLICITACAO
	WSDATA   cINCLUIRESULT             AS string

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSSTCPDEL                AS WSMATA105_STCPDEL
	WSDATA   oWSSTSOLICITACAO          AS WSMATA105_STSOLICITACAO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSMATA105
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20130604] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSMATA105
	::oWSSCPEXCLUI       := WSMATA105_STCPDEL():New()
	::oWSSSOLICITACAO    := WSMATA105_STSOLICITACAO():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSTCPDEL         := ::oWSSCPEXCLUI
	::oWSSTSOLICITACAO   := ::oWSSSOLICITACAO
Return

WSMETHOD RESET WSCLIENT WSWSMATA105
	::oWSSCPEXCLUI       := NIL 
	::cEXCLUIRESULT      := NIL 
	::oWSSSOLICITACAO    := NIL 
	::cINCLUIRESULT      := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSTCPDEL         := NIL
	::oWSSTSOLICITACAO   := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSMATA105
Local oClone := WSWSMATA105():New()
	oClone:_URL          := ::_URL 
	oClone:oWSSCPEXCLUI  :=  IIF(::oWSSCPEXCLUI = NIL , NIL ,::oWSSCPEXCLUI:Clone() )
	oClone:cEXCLUIRESULT := ::cEXCLUIRESULT
	oClone:oWSSSOLICITACAO :=  IIF(::oWSSSOLICITACAO = NIL , NIL ,::oWSSSOLICITACAO:Clone() )
	oClone:cINCLUIRESULT := ::cINCLUIRESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSSTCPDEL    := oClone:oWSSCPEXCLUI
	oClone:oWSSTSOLICITACAO := oClone:oWSSSOLICITACAO
Return oClone

// WSDL Method EXCLUI of Service WSWSMATA105

WSMETHOD EXCLUI WSSEND oWSSCPEXCLUI WSRECEIVE cEXCLUIRESULT WSCLIENT WSWSMATA105
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EXCLUI xmlns="http://www.totvs.com.br/rm/">'
cSoap += WSSoapValue("SCPEXCLUI", ::oWSSCPEXCLUI, oWSSCPEXCLUI , "STCPDEL", .T. , .F., 0 , NIL, .F.) 
cSoap += "</EXCLUI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.totvs.com.br/rm/EXCLUI",; 
	"DOCUMENT","http://www.totvs.com.br/rm/",,"1.031217",; 
	"http://localhost:86/WSMATA105.apw")

::Init()
::cEXCLUIRESULT      :=  WSAdvValue( oXmlRet,"_EXCLUIRESPONSE:_EXCLUIRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INCLUI of Service WSWSMATA105

WSMETHOD INCLUI WSSEND oWSSSOLICITACAO WSRECEIVE cINCLUIRESULT WSCLIENT WSWSMATA105
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INCLUI xmlns="http://www.totvs.com.br/rm/">'
cSoap += WSSoapValue("SSOLICITACAO", ::oWSSSOLICITACAO, oWSSSOLICITACAO , "STSOLICITACAO", .T. , .F., 0 , NIL, .F.) 
cSoap += "</INCLUI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.totvs.com.br/rm/INCLUI",; 
	"DOCUMENT","http://www.totvs.com.br/rm/",,"1.031217",; 
	"http://localhost:86/WSMATA105.apw")

::Init()
::cINCLUIRESULT      :=  WSAdvValue( oXmlRet,"_INCLUIRESPONSE:_INCLUIRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure STCPDEL

WSSTRUCT WSMATA105_STCPDEL
	WSDATA   cCEMPRESA                 AS string
	WSDATA   cCFIL                     AS string
	WSDATA   cCID                      AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA105_STCPDEL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA105_STCPDEL
Return

WSMETHOD CLONE WSCLIENT WSMATA105_STCPDEL
	Local oClone := WSMATA105_STCPDEL():NEW()
	oClone:cCEMPRESA            := ::cCEMPRESA
	oClone:cCFIL                := ::cCFIL
	oClone:cCID                 := ::cCID
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA105_STCPDEL
	Local cSoap := ""
	cSoap += WSSoapValue("CEMPRESA", ::cCEMPRESA, ::cCEMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CFIL", ::cCFIL, ::cCFIL , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CID", ::cCID, ::cCID , "string", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure STSOLICITACAO

WSSTRUCT WSMATA105_STSOLICITACAO
	WSDATA   oWSSCAB                   AS WSMATA105_STCABSCP
	WSDATA   oWSSCOR                   AS WSMATA105_ARRAYOFSTCORSCP
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA105_STSOLICITACAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA105_STSOLICITACAO
Return

WSMETHOD CLONE WSCLIENT WSMATA105_STSOLICITACAO
	Local oClone := WSMATA105_STSOLICITACAO():NEW()
	oClone:oWSSCAB              := IIF(::oWSSCAB = NIL , NIL , ::oWSSCAB:Clone() )
	oClone:oWSSCOR              := IIF(::oWSSCOR = NIL , NIL , ::oWSSCOR:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA105_STSOLICITACAO
	Local cSoap := ""
	cSoap += WSSoapValue("SCAB", ::oWSSCAB, ::oWSSCAB , "STCABSCP", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("SCOR", ::oWSSCOR, ::oWSSCOR , "ARRAYOFSTCORSCP", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure STCABSCP

WSSTRUCT WSMATA105_STCABSCP
	WSDATA   cCCOD                     AS string
	WSDATA   cCEMPRESA                 AS string
	WSDATA   cCFIL                     AS string
	WSDATA   cCSOLIC                   AS string
	WSDATA   dDDATA                    AS date
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA105_STCABSCP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA105_STCABSCP
Return

WSMETHOD CLONE WSCLIENT WSMATA105_STCABSCP
	Local oClone := WSMATA105_STCABSCP():NEW()
	oClone:cCCOD                := ::cCCOD
	oClone:cCEMPRESA            := ::cCEMPRESA
	oClone:cCFIL                := ::cCFIL
	oClone:cCSOLIC              := ::cCSOLIC
	oClone:dDDATA               := ::dDDATA
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA105_STCABSCP
	Local cSoap := ""
	cSoap += WSSoapValue("CCOD", ::cCCOD, ::cCCOD , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CEMPRESA", ::cCEMPRESA, ::cCEMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CFIL", ::cCFIL, ::cCFIL , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CSOLIC", ::cCSOLIC, ::cCSOLIC , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("DDATA", ::dDDATA, ::dDDATA , "date", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ARRAYOFSTCORSCP

WSSTRUCT WSMATA105_ARRAYOFSTCORSCP
	WSDATA   oWSSTCORSCP               AS WSMATA105_STCORSCP OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA105_ARRAYOFSTCORSCP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA105_ARRAYOFSTCORSCP
	::oWSSTCORSCP          := {} // Array Of  WSMATA105_STCORSCP():New()
Return

WSMETHOD CLONE WSCLIENT WSMATA105_ARRAYOFSTCORSCP
	Local oClone := WSMATA105_ARRAYOFSTCORSCP():NEW()
	oClone:oWSSTCORSCP := NIL
	If ::oWSSTCORSCP <> NIL 
		oClone:oWSSTCORSCP := {}
		aEval( ::oWSSTCORSCP , { |x| aadd( oClone:oWSSTCORSCP , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA105_ARRAYOFSTCORSCP
	Local cSoap := ""
	aEval( ::oWSSTCORSCP , {|x| cSoap := cSoap  +  WSSoapValue("STCORSCP", x , x , "STCORSCP", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure STCORSCP

WSSTRUCT WSMATA105_STCORSCP
	WSDATA   cCAFH_PROJETO             AS string OPTIONAL
	WSDATA   cCAFH_TAREFA              AS string OPTIONAL
	WSDATA   cCCP_ALI_WT               AS string
	WSDATA   cCCP_CC                   AS string OPTIONAL
	WSDATA   cCCP_CLVL                 AS string OPTIONAL
	WSDATA   cCCP_CONTA                AS string OPTIONAL
	WSDATA   cCCP_DATPRF               AS string
	WSDATA   cCCP_DESCRI               AS string
	WSDATA   cCCP_ITEM                 AS string
	WSDATA   cCCP_ITEMCTA              AS string OPTIONAL
	WSDATA   cCCP_LOCAL                AS string
	WSDATA   cCCP_OBS                  AS string
	WSDATA   cCCP_OP                   AS string
	WSDATA   cCCP_PRODUTO              AS string
	WSDATA   cCCP_REC_WT               AS string
	WSDATA   cCCP_SEGUM                AS string
	WSDATA   cCCP_SEQRC                AS string
	WSDATA   cCCP_UM                   AS string
	WSDATA   nNCP_QTSEGUM              AS float
	WSDATA   nNCP_QUANT                AS float
	WSDATA   nNCP_SALBLQ               AS float
	WSDATA   oWSSPROJSCP               AS WSMATA105_ARRAYOFAPROJSCP OPTIONAL
	WSDATA   oWSSRATCTSCP              AS WSMATA105_ARRAYOFARATCTCP OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA105_STCORSCP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA105_STCORSCP
Return

WSMETHOD CLONE WSCLIENT WSMATA105_STCORSCP
	Local oClone := WSMATA105_STCORSCP():NEW()
	oClone:cCAFH_PROJETO        := ::cCAFH_PROJETO
	oClone:cCAFH_TAREFA         := ::cCAFH_TAREFA
	oClone:cCCP_ALI_WT          := ::cCCP_ALI_WT
	oClone:cCCP_CC              := ::cCCP_CC
	oClone:cCCP_CLVL            := ::cCCP_CLVL
	oClone:cCCP_CONTA           := ::cCCP_CONTA
	oClone:cCCP_DATPRF          := ::cCCP_DATPRF
	oClone:cCCP_DESCRI          := ::cCCP_DESCRI
	oClone:cCCP_ITEM            := ::cCCP_ITEM
	oClone:cCCP_ITEMCTA         := ::cCCP_ITEMCTA
	oClone:cCCP_LOCAL           := ::cCCP_LOCAL
	oClone:cCCP_OBS             := ::cCCP_OBS
	oClone:cCCP_OP              := ::cCCP_OP
	oClone:cCCP_PRODUTO         := ::cCCP_PRODUTO
	oClone:cCCP_REC_WT          := ::cCCP_REC_WT
	oClone:cCCP_SEGUM           := ::cCCP_SEGUM
	oClone:cCCP_SEQRC           := ::cCCP_SEQRC
	oClone:cCCP_UM              := ::cCCP_UM
	oClone:nNCP_QTSEGUM         := ::nNCP_QTSEGUM
	oClone:nNCP_QUANT           := ::nNCP_QUANT
	oClone:nNCP_SALBLQ          := ::nNCP_SALBLQ
	oClone:oWSSPROJSCP          := IIF(::oWSSPROJSCP = NIL , NIL , ::oWSSPROJSCP:Clone() )
	oClone:oWSSRATCTSCP         := IIF(::oWSSRATCTSCP = NIL , NIL , ::oWSSRATCTSCP:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA105_STCORSCP
	Local cSoap := ""
	cSoap += WSSoapValue("CAFH_PROJETO", ::cCAFH_PROJETO, ::cCAFH_PROJETO , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CAFH_TAREFA", ::cCAFH_TAREFA, ::cCAFH_TAREFA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CCP_ALI_WT", ::cCCP_ALI_WT, ::cCCP_ALI_WT , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CCP_CC", ::cCCP_CC, ::cCCP_CC , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CCP_CLVL", ::cCCP_CLVL, ::cCCP_CLVL , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CCP_CONTA", ::cCCP_CONTA, ::cCCP_CONTA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CCP_DATPRF", ::cCCP_DATPRF, ::cCCP_DATPRF , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CCP_DESCRI", ::cCCP_DESCRI, ::cCCP_DESCRI , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CCP_ITEM", ::cCCP_ITEM, ::cCCP_ITEM , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CCP_ITEMCTA", ::cCCP_ITEMCTA, ::cCCP_ITEMCTA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CCP_LOCAL", ::cCCP_LOCAL, ::cCCP_LOCAL , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CCP_OBS", ::cCCP_OBS, ::cCCP_OBS , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CCP_OP", ::cCCP_OP, ::cCCP_OP , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CCP_PRODUTO", ::cCCP_PRODUTO, ::cCCP_PRODUTO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CCP_REC_WT", ::cCCP_REC_WT, ::cCCP_REC_WT , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CCP_SEGUM", ::cCCP_SEGUM, ::cCCP_SEGUM , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CCP_SEQRC", ::cCCP_SEQRC, ::cCCP_SEQRC , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CCP_UM", ::cCCP_UM, ::cCCP_UM , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NCP_QTSEGUM", ::nNCP_QTSEGUM, ::nNCP_QTSEGUM , "float", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NCP_QUANT", ::nNCP_QUANT, ::nNCP_QUANT , "float", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NCP_SALBLQ", ::nNCP_SALBLQ, ::nNCP_SALBLQ , "float", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("SPROJSCP", ::oWSSPROJSCP, ::oWSSPROJSCP , "ARRAYOFAPROJSCP", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("SRATCTSCP", ::oWSSRATCTSCP, ::oWSSRATCTSCP , "ARRAYOFARATCTCP", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ARRAYOFAPROJSCP

WSSTRUCT WSMATA105_ARRAYOFAPROJSCP
	WSDATA   oWSAPROJSCP               AS WSMATA105_APROJSCP OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA105_ARRAYOFAPROJSCP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA105_ARRAYOFAPROJSCP
	::oWSAPROJSCP          := {} // Array Of  WSMATA105_APROJSCP():New()
Return

WSMETHOD CLONE WSCLIENT WSMATA105_ARRAYOFAPROJSCP
	Local oClone := WSMATA105_ARRAYOFAPROJSCP():NEW()
	oClone:oWSAPROJSCP := NIL
	If ::oWSAPROJSCP <> NIL 
		oClone:oWSAPROJSCP := {}
		aEval( ::oWSAPROJSCP , { |x| aadd( oClone:oWSAPROJSCP , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA105_ARRAYOFAPROJSCP
	Local cSoap := ""
	aEval( ::oWSAPROJSCP , {|x| cSoap := cSoap  +  WSSoapValue("APROJSCP", x , x , "APROJSCP", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFARATCTCP

WSSTRUCT WSMATA105_ARRAYOFARATCTCP
	WSDATA   oWSARATCTCP               AS WSMATA105_ARATCTCP OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA105_ARRAYOFARATCTCP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA105_ARRAYOFARATCTCP
	::oWSARATCTCP          := {} // Array Of  WSMATA105_ARATCTCP():New()
Return

WSMETHOD CLONE WSCLIENT WSMATA105_ARRAYOFARATCTCP
	Local oClone := WSMATA105_ARRAYOFARATCTCP():NEW()
	oClone:oWSARATCTCP := NIL
	If ::oWSARATCTCP <> NIL 
		oClone:oWSARATCTCP := {}
		aEval( ::oWSARATCTCP , { |x| aadd( oClone:oWSARATCTCP , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA105_ARRAYOFARATCTCP
	Local cSoap := ""
	aEval( ::oWSARATCTCP , {|x| cSoap := cSoap  +  WSSoapValue("ARATCTCP", x , x , "ARATCTCP", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure APROJSCP

WSSTRUCT WSMATA105_APROJSCP
	WSDATA   cCAFH_PROJETO             AS string
	WSDATA   cCAFH_TAREFA              AS string
	WSDATA   nNAFH_QUANT               AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA105_APROJSCP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA105_APROJSCP
Return

WSMETHOD CLONE WSCLIENT WSMATA105_APROJSCP
	Local oClone := WSMATA105_APROJSCP():NEW()
	oClone:cCAFH_PROJETO        := ::cCAFH_PROJETO
	oClone:cCAFH_TAREFA         := ::cCAFH_TAREFA
	oClone:nNAFH_QUANT          := ::nNAFH_QUANT
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA105_APROJSCP
	Local cSoap := ""
	cSoap += WSSoapValue("CAFH_PROJETO", ::cCAFH_PROJETO, ::cCAFH_PROJETO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CAFH_TAREFA", ::cCAFH_TAREFA, ::cCAFH_TAREFA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NAFH_QUANT", ::nNAFH_QUANT, ::nNAFH_QUANT , "float", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ARATCTCP

WSSTRUCT WSMATA105_ARATCTCP
	WSDATA   cGS_CC                    AS string OPTIONAL
	WSDATA   cGS_CLVL                  AS string
	WSDATA   cGS_CONTA                 AS string
	WSDATA   cGS_ITEMCTA               AS string
	WSDATA   nGS_PERC                  AS float OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMATA105_ARATCTCP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMATA105_ARATCTCP
Return

WSMETHOD CLONE WSCLIENT WSMATA105_ARATCTCP
	Local oClone := WSMATA105_ARATCTCP():NEW()
	oClone:cGS_CC               := ::cGS_CC
	oClone:cGS_CLVL             := ::cGS_CLVL
	oClone:cGS_CONTA            := ::cGS_CONTA
	oClone:cGS_ITEMCTA          := ::cGS_ITEMCTA
	oClone:nGS_PERC             := ::nGS_PERC
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMATA105_ARATCTCP
	Local cSoap := ""
	cSoap += WSSoapValue("GS_CC", ::cGS_CC, ::cGS_CC , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("GS_CLVL", ::cGS_CLVL, ::cGS_CLVL , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("GS_CONTA", ::cGS_CONTA, ::cGS_CONTA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("GS_ITEMCTA", ::cGS_ITEMCTA, ::cGS_ITEMCTA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("GS_PERC", ::nGS_PERC, ::nGS_PERC , "float", .F. , .F., 0 , NIL, .F.) 
Return cSoap


