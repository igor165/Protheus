#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:89/WSMAT110.apw?WSDL
Gerado em        01/04/13 13:46:36
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _QSZEJUH ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSMAT110
------------------------------------------------------------------------------- */

WSCLIENT WSWSMAT110

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
	WSDATA   oWSSSOLICITACAO           AS WSMAT110_STSC1SOLICITACAO
	WSDATA   cALTERARRESULT            AS string
	WSDATA   oWSSC1EXCLUI              AS WSMAT110_STC1DEL
	WSDATA   cEXCLUIRESULT             AS string
	WSDATA   cINCLUIRESULT             AS string

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSSTSC1SOLICITACAO       AS WSMAT110_STSC1SOLICITACAO
	WSDATA   oWSSTC1DEL                AS WSMAT110_STC1DEL

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSMAT110
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.120420A-20120726] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSMAT110
	::oWSSSOLICITACAO    := WSMAT110_STSC1SOLICITACAO():New()
	::oWSSC1EXCLUI       := WSMAT110_STC1DEL():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSTSC1SOLICITACAO := ::oWSSSOLICITACAO
	::oWSSTC1DEL         := ::oWSSC1EXCLUI
Return

WSMETHOD RESET WSCLIENT WSWSMAT110
	::oWSSSOLICITACAO    := NIL 
	::cALTERARRESULT     := NIL 
	::oWSSC1EXCLUI       := NIL 
	::cEXCLUIRESULT      := NIL 
	::cINCLUIRESULT      := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSTSC1SOLICITACAO := NIL
	::oWSSTC1DEL         := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSMAT110
Local oClone := WSWSMAT110():New()
	oClone:_URL          := ::_URL 
	oClone:oWSSSOLICITACAO :=  IIF(::oWSSSOLICITACAO = NIL , NIL ,::oWSSSOLICITACAO:Clone() )
	oClone:cALTERARRESULT := ::cALTERARRESULT
	oClone:oWSSC1EXCLUI  :=  IIF(::oWSSC1EXCLUI = NIL , NIL ,::oWSSC1EXCLUI:Clone() )
	oClone:cEXCLUIRESULT := ::cEXCLUIRESULT
	oClone:cINCLUIRESULT := ::cINCLUIRESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSSTSC1SOLICITACAO := oClone:oWSSSOLICITACAO
	oClone:oWSSTC1DEL    := oClone:oWSSC1EXCLUI
Return oClone

// WSDL Method ALTERAR of Service WSWSMAT110

WSMETHOD ALTERAR WSSEND oWSSSOLICITACAO WSRECEIVE cALTERARRESULT WSCLIENT WSWSMAT110
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ALTERAR xmlns="http://www.totvs.com.br/rm/">'
cSoap += WSSoapValue("SSOLICITACAO", ::oWSSSOLICITACAO, oWSSSOLICITACAO , "STSC1SOLICITACAO", .T. , .F., 0 , NIL, .F.) 
cSoap += "</ALTERAR>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.totvs.com.br/rm/ALTERAR",; 
	"DOCUMENT","http://www.totvs.com.br/rm/",,"1.031217",; 
	"http://10.31.8.22:89/WSMAT110.apw")

::Init()
::cALTERARRESULT     :=  WSAdvValue( oXmlRet,"_ALTERARRESPONSE:_ALTERARRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EXCLUI of Service WSWSMAT110

WSMETHOD EXCLUI WSSEND oWSSC1EXCLUI WSRECEIVE cEXCLUIRESULT WSCLIENT WSWSMAT110
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EXCLUI xmlns="http://www.totvs.com.br/rm/">'
cSoap += WSSoapValue("SC1EXCLUI", ::oWSSC1EXCLUI, oWSSC1EXCLUI , "STC1DEL", .T. , .F., 0 , NIL, .F.) 
cSoap += "</EXCLUI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.totvs.com.br/rm/EXCLUI",; 
	"DOCUMENT","http://www.totvs.com.br/rm/",,"1.031217",; 
	"http://10.31.8.22:89/WSMAT110.apw")

::Init()
::cEXCLUIRESULT      :=  WSAdvValue( oXmlRet,"_EXCLUIRESPONSE:_EXCLUIRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INCLUI of Service WSWSMAT110

WSMETHOD INCLUI WSSEND oWSSSOLICITACAO WSRECEIVE cINCLUIRESULT WSCLIENT WSWSMAT110
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INCLUI xmlns="http://www.totvs.com.br/rm/">'
cSoap += WSSoapValue("SSOLICITACAO", ::oWSSSOLICITACAO, oWSSSOLICITACAO , "STSC1SOLICITACAO", .T. , .F., 0 , NIL, .F.) 
cSoap += "</INCLUI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.totvs.com.br/rm/INCLUI",; 
	"DOCUMENT","http://www.totvs.com.br/rm/",,"1.031217",; 
	"http://10.31.8.22:89/WSMAT110.apw")

::Init()
::cINCLUIRESULT      :=  WSAdvValue( oXmlRet,"_INCLUIRESPONSE:_INCLUIRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure STSC1SOLICITACAO

WSSTRUCT WSMAT110_STSC1SOLICITACAO
	WSDATA   oWSSCAB                   AS WSMAT110_STCABSC1
	WSDATA   oWSSCOR                   AS WSMAT110_ARRAYOFSTCORSC1
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMAT110_STSC1SOLICITACAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMAT110_STSC1SOLICITACAO
Return

WSMETHOD CLONE WSCLIENT WSMAT110_STSC1SOLICITACAO
	Local oClone := WSMAT110_STSC1SOLICITACAO():NEW()
	oClone:oWSSCAB              := IIF(::oWSSCAB = NIL , NIL , ::oWSSCAB:Clone() )
	oClone:oWSSCOR              := IIF(::oWSSCOR = NIL , NIL , ::oWSSCOR:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMAT110_STSC1SOLICITACAO
	Local cSoap := ""
	cSoap += WSSoapValue("SCAB", ::oWSSCAB, ::oWSSCAB , "STCABSC1", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("SCOR", ::oWSSCOR, ::oWSSCOR , "ARRAYOFSTCORSC1", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure STC1DEL

WSSTRUCT WSMAT110_STC1DEL
	WSDATA   cCEMPRESA                 AS string
	WSDATA   cCFIL                     AS string
	WSDATA   cCID                      AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMAT110_STC1DEL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMAT110_STC1DEL
Return

WSMETHOD CLONE WSCLIENT WSMAT110_STC1DEL
	Local oClone := WSMAT110_STC1DEL():NEW()
	oClone:cCEMPRESA            := ::cCEMPRESA
	oClone:cCFIL                := ::cCFIL
	oClone:cCID                 := ::cCID
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMAT110_STC1DEL
	Local cSoap := ""
	cSoap += WSSoapValue("CEMPRESA", ::cCEMPRESA, ::cCEMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CFIL", ::cCFIL, ::cCFIL , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CID", ::cCID, ::cCID , "string", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure STCABSC1

WSSTRUCT WSMAT110_STCABSC1
	WSDATA   cCCODCOMP                 AS string
	WSDATA   cCEMPRESA                 AS string
	WSDATA   cCFIL                     AS string
	WSDATA   cCFILENT                  AS string
	WSDATA   cCNUM                     AS string OPTIONAL
	WSDATA   cCSOLIC                   AS string
	WSDATA   cCUNIDREQ                 AS string OPTIONAL
	WSDATA   cDEMISSAO                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMAT110_STCABSC1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMAT110_STCABSC1
Return

WSMETHOD CLONE WSCLIENT WSMAT110_STCABSC1
	Local oClone := WSMAT110_STCABSC1():NEW()
	oClone:cCCODCOMP            := ::cCCODCOMP
	oClone:cCEMPRESA            := ::cCEMPRESA
	oClone:cCFIL                := ::cCFIL
	oClone:cCFILENT             := ::cCFILENT
	oClone:cCNUM                := ::cCNUM
	oClone:cCSOLIC              := ::cCSOLIC
	oClone:cCUNIDREQ            := ::cCUNIDREQ
	oClone:cDEMISSAO            := ::cDEMISSAO
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMAT110_STCABSC1
	Local cSoap := ""
	cSoap += WSSoapValue("CCODCOMP", ::cCCODCOMP, ::cCCODCOMP , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CEMPRESA", ::cCEMPRESA, ::cCEMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CFIL", ::cCFIL, ::cCFIL , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CFILENT", ::cCFILENT, ::cCFILENT , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CNUM", ::cCNUM, ::cCNUM , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CSOLIC", ::cCSOLIC, ::cCSOLIC , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CUNIDREQ", ::cCUNIDREQ, ::cCUNIDREQ , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("DEMISSAO", ::cDEMISSAO, ::cDEMISSAO , "string", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ARRAYOFSTCORSC1

WSSTRUCT WSMAT110_ARRAYOFSTCORSC1
	WSDATA   oWSSTCORSC1               AS WSMAT110_STCORSC1 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMAT110_ARRAYOFSTCORSC1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMAT110_ARRAYOFSTCORSC1
	::oWSSTCORSC1          := {} // Array Of  WSMAT110_STCORSC1():New()
Return

WSMETHOD CLONE WSCLIENT WSMAT110_ARRAYOFSTCORSC1
	Local oClone := WSMAT110_ARRAYOFSTCORSC1():NEW()
	oClone:oWSSTCORSC1 := NIL
	If ::oWSSTCORSC1 <> NIL 
		oClone:oWSSTCORSC1 := {}
		aEval( ::oWSSTCORSC1 , { |x| aadd( oClone:oWSSTCORSC1 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMAT110_ARRAYOFSTCORSC1
	Local cSoap := ""
	aEval( ::oWSSTCORSC1 , {|x| cSoap := cSoap  +  WSSoapValue("STCORSC1", x , x , "STCORSC1", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure STCORSC1

WSSTRUCT WSMAT110_STCORSC1
	WSDATA   cCAFG_PROJETO             AS string OPTIONAL
	WSDATA   cCAFG_TAREFA              AS string OPTIONAL
	WSDATA   cCC1_ALI_WT               AS string OPTIONAL
	WSDATA   cCC1_CC                   AS string OPTIONAL
	WSDATA   cCC1_CLVL                 AS string OPTIONAL
	WSDATA   cCC1_CONTA                AS string OPTIONAL
	WSDATA   cCC1_DATPRF               AS string
	WSDATA   cCC1_DESCRI               AS string
	WSDATA   cCC1_ITEM                 AS string
	WSDATA   cCC1_ITEMCTA              AS string OPTIONAL
	WSDATA   cCC1_LOCAL                AS string
	WSDATA   cCC1_OBS                  AS string OPTIONAL
	WSDATA   cCC1_PRODUTO              AS string
	WSDATA   cCC1_REC_WT               AS string OPTIONAL
	WSDATA   cCC1_SEGUM                AS string OPTIONAL
	WSDATA   cCC1_TPOP                 AS string OPTIONAL
	WSDATA   cCC1_UM                   AS string
	WSDATA   nNC1_QTSEGUM              AS float OPTIONAL
	WSDATA   nNC1_QUANT                AS float
	WSDATA   nNC1_VUNIT                AS float
	WSDATA   oWSSPROJSC1               AS WSMAT110_ARRAYOFAPROJSC1 OPTIONAL
	WSDATA   oWSSRATCTSC1              AS WSMAT110_ARRAYOFARATCTSC1 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMAT110_STCORSC1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMAT110_STCORSC1
Return

WSMETHOD CLONE WSCLIENT WSMAT110_STCORSC1
	Local oClone := WSMAT110_STCORSC1():NEW()
	oClone:cCAFG_PROJETO        := ::cCAFG_PROJETO
	oClone:cCAFG_TAREFA         := ::cCAFG_TAREFA
	oClone:cCC1_ALI_WT          := ::cCC1_ALI_WT
	oClone:cCC1_CC              := ::cCC1_CC
	oClone:cCC1_CLVL            := ::cCC1_CLVL
	oClone:cCC1_CONTA           := ::cCC1_CONTA
	oClone:cCC1_DATPRF          := ::cCC1_DATPRF
	oClone:cCC1_DESCRI          := ::cCC1_DESCRI
	oClone:cCC1_ITEM            := ::cCC1_ITEM
	oClone:cCC1_ITEMCTA         := ::cCC1_ITEMCTA
	oClone:cCC1_LOCAL           := ::cCC1_LOCAL
	oClone:cCC1_OBS             := ::cCC1_OBS
	oClone:cCC1_PRODUTO         := ::cCC1_PRODUTO
	oClone:cCC1_REC_WT          := ::cCC1_REC_WT
	oClone:cCC1_SEGUM           := ::cCC1_SEGUM
	oClone:cCC1_TPOP            := ::cCC1_TPOP
	oClone:cCC1_UM              := ::cCC1_UM
	oClone:nNC1_QTSEGUM         := ::nNC1_QTSEGUM
	oClone:nNC1_QUANT           := ::nNC1_QUANT
	oClone:nNC1_VUNIT           := ::nNC1_VUNIT
	oClone:oWSSPROJSC1          := IIF(::oWSSPROJSC1 = NIL , NIL , ::oWSSPROJSC1:Clone() )
	oClone:oWSSRATCTSC1         := IIF(::oWSSRATCTSC1 = NIL , NIL , ::oWSSRATCTSC1:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMAT110_STCORSC1
	Local cSoap := ""
	cSoap += WSSoapValue("CAFG_PROJETO", ::cCAFG_PROJETO, ::cCAFG_PROJETO , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CAFG_TAREFA", ::cCAFG_TAREFA, ::cCAFG_TAREFA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CC1_ALI_WT", ::cCC1_ALI_WT, ::cCC1_ALI_WT , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CC1_CC", ::cCC1_CC, ::cCC1_CC , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CC1_CLVL", ::cCC1_CLVL, ::cCC1_CLVL , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CC1_CONTA", ::cCC1_CONTA, ::cCC1_CONTA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CC1_DATPRF", ::cCC1_DATPRF, ::cCC1_DATPRF , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CC1_DESCRI", ::cCC1_DESCRI, ::cCC1_DESCRI , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CC1_ITEM", ::cCC1_ITEM, ::cCC1_ITEM , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CC1_ITEMCTA", ::cCC1_ITEMCTA, ::cCC1_ITEMCTA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CC1_LOCAL", ::cCC1_LOCAL, ::cCC1_LOCAL , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CC1_OBS", ::cCC1_OBS, ::cCC1_OBS , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CC1_PRODUTO", ::cCC1_PRODUTO, ::cCC1_PRODUTO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CC1_REC_WT", ::cCC1_REC_WT, ::cCC1_REC_WT , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CC1_SEGUM", ::cCC1_SEGUM, ::cCC1_SEGUM , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CC1_TPOP", ::cCC1_TPOP, ::cCC1_TPOP , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CC1_UM", ::cCC1_UM, ::cCC1_UM , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NC1_QTSEGUM", ::nNC1_QTSEGUM, ::nNC1_QTSEGUM , "float", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NC1_QUANT", ::nNC1_QUANT, ::nNC1_QUANT , "float", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NC1_VUNIT", ::nNC1_VUNIT, ::nNC1_VUNIT , "float", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("SPROJSC1", ::oWSSPROJSC1, ::oWSSPROJSC1 , "ARRAYOFAPROJSC1", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("SRATCTSC1", ::oWSSRATCTSC1, ::oWSSRATCTSC1 , "ARRAYOFARATCTSC1", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ARRAYOFAPROJSC1

WSSTRUCT WSMAT110_ARRAYOFAPROJSC1
	WSDATA   oWSAPROJSC1               AS WSMAT110_APROJSC1 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMAT110_ARRAYOFAPROJSC1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMAT110_ARRAYOFAPROJSC1
	::oWSAPROJSC1          := {} // Array Of  WSMAT110_APROJSC1():New()
Return

WSMETHOD CLONE WSCLIENT WSMAT110_ARRAYOFAPROJSC1
	Local oClone := WSMAT110_ARRAYOFAPROJSC1():NEW()
	oClone:oWSAPROJSC1 := NIL
	If ::oWSAPROJSC1 <> NIL 
		oClone:oWSAPROJSC1 := {}
		aEval( ::oWSAPROJSC1 , { |x| aadd( oClone:oWSAPROJSC1 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMAT110_ARRAYOFAPROJSC1
	Local cSoap := ""
	aEval( ::oWSAPROJSC1 , {|x| cSoap := cSoap  +  WSSoapValue("APROJSC1", x , x , "APROJSC1", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFARATCTSC1

WSSTRUCT WSMAT110_ARRAYOFARATCTSC1
	WSDATA   oWSARATCTSC1              AS WSMAT110_ARATCTSC1 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMAT110_ARRAYOFARATCTSC1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMAT110_ARRAYOFARATCTSC1
	::oWSARATCTSC1         := {} // Array Of  WSMAT110_ARATCTSC1():New()
Return

WSMETHOD CLONE WSCLIENT WSMAT110_ARRAYOFARATCTSC1
	Local oClone := WSMAT110_ARRAYOFARATCTSC1():NEW()
	oClone:oWSARATCTSC1 := NIL
	If ::oWSARATCTSC1 <> NIL 
		oClone:oWSARATCTSC1 := {}
		aEval( ::oWSARATCTSC1 , { |x| aadd( oClone:oWSARATCTSC1 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMAT110_ARRAYOFARATCTSC1
	Local cSoap := ""
	aEval( ::oWSARATCTSC1 , {|x| cSoap := cSoap  +  WSSoapValue("ARATCTSC1", x , x , "ARATCTSC1", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure APROJSC1

WSSTRUCT WSMAT110_APROJSC1
	WSDATA   cCAFG_PROJETO             AS string
	WSDATA   cCAFG_TAREFA              AS string
	WSDATA   nNAFG_QUANT               AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMAT110_APROJSC1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMAT110_APROJSC1
Return

WSMETHOD CLONE WSCLIENT WSMAT110_APROJSC1
	Local oClone := WSMAT110_APROJSC1():NEW()
	oClone:cCAFG_PROJETO        := ::cCAFG_PROJETO
	oClone:cCAFG_TAREFA         := ::cCAFG_TAREFA
	oClone:nNAFG_QUANT          := ::nNAFG_QUANT
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMAT110_APROJSC1
	Local cSoap := ""
	cSoap += WSSoapValue("CAFG_PROJETO", ::cCAFG_PROJETO, ::cCAFG_PROJETO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CAFG_TAREFA", ::cCAFG_TAREFA, ::cCAFG_TAREFA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NAFG_QUANT", ::nNAFG_QUANT, ::nNAFG_QUANT , "float", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ARATCTSC1

WSSTRUCT WSMAT110_ARATCTSC1
	WSDATA   cCX_CC                    AS string OPTIONAL
	WSDATA   cCX_CLVL                  AS string OPTIONAL
	WSDATA   cCX_CONTA                 AS string OPTIONAL
	WSDATA   cCX_ITEMCTA               AS string OPTIONAL
	WSDATA   nCX_PERC                  AS float OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSMAT110_ARATCTSC1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSMAT110_ARATCTSC1
Return

WSMETHOD CLONE WSCLIENT WSMAT110_ARATCTSC1
	Local oClone := WSMAT110_ARATCTSC1():NEW()
	oClone:cCX_CC               := ::cCX_CC
	oClone:cCX_CLVL             := ::cCX_CLVL
	oClone:cCX_CONTA            := ::cCX_CONTA
	oClone:cCX_ITEMCTA          := ::cCX_ITEMCTA
	oClone:nCX_PERC             := ::nCX_PERC
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSMAT110_ARATCTSC1
	Local cSoap := ""
	cSoap += WSSoapValue("CX_CC", ::cCX_CC, ::cCX_CC , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CX_CLVL", ::cCX_CLVL, ::cCX_CLVL , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CX_CONTA", ::cCX_CONTA, ::cCX_CONTA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CX_ITEMCTA", ::cCX_ITEMCTA, ::cCX_ITEMCTA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CX_PERC", ::nCX_PERC, ::nCX_PERC , "float", .F. , .F., 0 , NIL, .F.) 
Return cSoap


