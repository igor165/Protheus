#INCLUDE "APWEBEX.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGAWIN.CH"   

#define LIMITPERPAGE 100 // define a numero maximo de apontamentos a serem retornados por chamada



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±																		  			±±
±±  MENU (Portal Projetos)										   				±±
±±	   ÀÄ> GERENCIAR PROJETOS											   		±±
±±						    ÀÄ> APONTAMENTOS 						   			±±
±±																		   			±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP030   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pagina inicial de item "Apontamentos" do menu principal.   º±±
±±º          ³ Escopo do filtro                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP030()

Local cHtml := ""

WEB EXTENDED INIT cHtml

cHtml += ExecInPage( "PWSP030" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP031   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Resposta do filtro para apontamnetos.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP031()

Local cHtml 				:= ""
Local cRrcInitial			:= ""
Local cRrcFinal			:= ""
Local cProjectInitial	:= ""
Local cProjectFinal		:= ""
Local cBsc					:= ""	
Local cOpc					:= ""
Local nPageFirst			:= 0
Local nPageLen 			:= LIMITPERPAGE // apontamentos por pagina 
Local nRecordCount		:= 0
Local lBuscaAvcd			:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta variaveis para chamada desta pagina     ³
//³ de diversos pontos do portal, sem a necessidade³
//³ de se passa-las via Form Metodo POST           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType( HttpPost->cRESOURCEFROM) == "U"
	cRrcInitial      	:= HttpSession->cRrcInitial
Else
	cRrcInitial		 	:= HttpPost->cRESOURCEFROM
Endif
If ValType( HttpPost->cRESOURCETO) == "U"
	cRrcFinal        	:= HttpSession->cRrcFinal
Else
	cRrcFinal			:= HttpPost->cRESOURCETO
Endif
If ValType( HttpPost->cPROJECTINITIAL) == "U"
	cProjectInitial 	:= HttpSession->cProjectInitial
Else
	cProjectInitial	:= HttpPost->cPROJECTINITIAL
Endif
If ValType( HttpPost->cPROJECTFINAL) == "U"
	cProjectFinal		:= HttpSession->cProjectFinal
Else
	cProjectFinal		:= HttpPost->cPROJECTFINAL
Endif

lBuscaAvcd := ValType( HttpPost->cBuscaAv) <> "U"

If ValType( HttpPost->nPageFirst) == "U"
	If ValType( HttpGet->nPageFirst) == "U"
		If lBuscaAvcd .And. ValType( HttpSession->nPageFirst) <> "U"
			nPageFirst := HttpSession->nPageFirst
		Else
			nPageFirst := 0
		EndIf
	Else
		If ValType( HttpGet->nPageFirst) == "C"
			nPageFirst := Val(HttpGet->nPageFirst)
		EndIf
	EndIf
Else
	nPageFirst		:= HttpPost->nPageFirst
Endif

If ValType( HttpPost->nPageLen) == "U"
	If !ValType(HttpSession->nPageLen) == "U"
		nPageLen := HttpSession->nPageLen
	EndIf
Else
	nPageLen		:= HttpPost->nPageLen
Endif

If ValType( HttpPost->nRecordCount) == "U"
	If !ValType(HttpSession->nRecordCount) == "U"
		nRecordCount := HttpSession->nRecordCount
	EndIf
Else
	nRecordCount := HttpPost->nRecordCount
Endif

If !lBuscaAvcd
	HttpSession->cBuscaAv	:= ""  
	HttpSession->cBuscaOpc	:= ""
	cBsc 						:= ""	
	cOpc						:= ""
Else
	cBsc						:= HttpPost->cBuscaAv
	cOpc						:= HttpPost->cComboAv
	HttpSession->cBuscaAv	:= cBsc
	HttpSession->cBuscaOpc	:= cOpc
Endif


WEB EXTENDED INIT cHtml

	HttpSession->cRrcInitial 		:= cRrcInitial
	HttpSession->cRrcFinal   		:= cRrcFinal
	HttpSession->cProjectInitial	:= cProjectInitial
	HttpSession->cProjectFinal		:= cProjectFinal
	HttpSession->nPageFirst			:= nPageFirst
	HttpSession->nPageLen			:= nPageLen // apontamentos por pagina
	
	oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSANNOTATIONS' ), WSPMSANNOTATIONS():New() )
	WsChgURL( @oObj, "PMSANNOTATIONS.APW" )
	
	oObj:cUSERCODE			:= GtPtUsrCod()[1]
	oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
	oObj:cResourceInitial	:= cRrcInitial
	oObj:cResourceFinal		:= cRrcFinal
	oObj:cPROJECTINITIAL		:= cProjectInitial
	oObj:cPROJECTFINAL		:= cProjectFinal
	oObj:nPAGEFIRST			:= nPageFirst
	oObj:nPAGELEN				:= nPageLen
	
	If oObj:GetRecordCount()
		// retorna o numero total d registros
		HttpSession->nRecordCount := oObj:nGETRECORDCOUNTRESULT
		cHtml += ExecInPage( "PWSP031" )

	Else
		HttpSession->nRecordCount := 0
		HttpSession->cLinkErro	:= ""
		HttpSession->cBotaoErro	:= ""
		HttpSession->cErro		:=	StrGantt( GetWscError(3) )
		cHtml 						:= ExecInPage( "PWSP001" )
	Endif

WEB EXTENDED END

Return cHtml


/*/{Protheus.doc} PWSP031A
Resposta do filtro para apontamnetos. (apresenta no iFrame)

@author Cristiano Denardi
@since 08/11/05
@version 1.0
@return String, contem a pagina HTML para ser apresentada
/*/
Web Function PWSP031A()
Local cHtml	:= ""
Local cBsc		:= ""
Local aBsc		:= {}
Local lBsc		:= .F.
Local cOpc		:= ""
Local lNext	:= .T.
Local oObj
Local nX
Local cRrcInitial, cRrcFinal, cProjectInitial, cProjectFinal
Local nPageFirst	:= 0 // a partir de qual apontamento
Local nPageLen 	:= LIMITPERPAGE // apontamentos por pagina 
Local nRecordCount	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta variaveis para chamada desta pagina     ³
//³ de diversos pontos do portal, sem a necessidade³
//³ de se passa-las via Form Metodo POST           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType( HttpPost->cRESOURCEFROM ) == "U"
	cRrcInitial	:= HttpSession->cRrcInitial
Else
	cRrcInitial	:= HttpPost->cRESOURCEFROM
Endif

If ValType( HttpPost->cRESOURCETO ) == "U"
	cRrcFinal		:= HttpSession->cRrcFinal
Else
	cRrcFinal	:= HttpPost->cRESOURCETO
Endif

If ValType( HttpPost->cPROJECTINITIAL ) == "U"
	cProjectInitial	:= HttpSession->cProjectInitial
Else
	cProjectInitial	:= HttpPost->cPROJECTINITIAL
Endif

If ValType( HttpPost->cPROJECTFINAL ) == "U"
	cProjectFinal	:= HttpSession->cProjectFinal
Else
	cProjectFinal	:= HttpPost->cPROJECTFINAL
Endif                           

If ValType( HttpPost->nPAGEFIRST ) == "U"
	If ValType( HttpSession->nPAGEFIRST ) == "U"
		nPageFirst	:= 0
	Else
		nPageFirst	:= HttpSession->nPAGEFIRST
	EndIf
Else
	nPageFirst	:= HttpPost->nPAGEFIRST
Endif                           

If ValType( HttpPost->nPAGELEN) == "U"
	If ValType( HttpSession->nPAGELEN ) == "U"
		nPageLen := 0
	Else
		nPageLen := HttpSession->nPAGELEN
	EndIf
Else
	nPageLen	:= HttpPost->nPAGELEN
Endif                           

If ValType( HttpPost->nRECORDCOUNT) == "U"
	If ValType( HttpSession->nRECORDCOUNT ) == "U"
		nRecordCount := 0
	Else
		nRecordCount := HttpSession->nRECORDCOUNT
	EndIf
Else
	nRecordCount := HttpPost->nRECORDCOUNT
Endif                           


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica variaveis da Busca Avancada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( HttpSession->cBuscaAv )
	lBsc						:= .F.
	HttpSession->cBuscaAv	:= ""
	HttpSession->cBuscaOpc	:= ""
	cBsc 						:= ""	
	cOpc						:= ""
Else
	lBsc						:= .T.
	cBsc						:= HttpSession->cBuscaAv
	cOpc						:= HttpSession->cBuscaOpc
	HttpSession->cBuscaAv	:= cBsc
	HttpSession->cBuscaOpc	:= cOpc
Endif                             

WEB EXTENDED INIT cHtml

	oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSANNOTATIONS' ), WSPMSANNOTATIONS():New() )
	WsChgURL( @oObj, "PMSANNOTATIONS.APW" )
	
	oObj:cUSERCODE			:= GtPtUsrCod()[1]
	oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
	oObj:cResourceInitial	:= cRrcInitial
	oObj:cResourceFinal		:= cRrcFinal
	oObj:cPROJECTINITIAL		:= cProjectInitial
	oObj:cPROJECTFINAL		:= cProjectFinal
	oObj:nPAGEFIRST			:= nPageFirst
	oObj:nPAGELEN				:= nPageLen
	
	HttpSession->cRrcInitial 		:= cRrcInitial
	HttpSession->cRrcFinal   		:= cRrcFinal
	HttpSession->cProjectInitial	:= cProjectInitial
	HttpSession->cProjectFinal		:= cProjectFinal
	HttpSession->nPageFirst			:= nPageFirst
	HttpSession->nPageLen			:= nPageLen // apontamentos por pagina
	
	If oObj:GetRecordCount()
		// retorna o numero total d registros
		HttpSession->nRecordCount := oObj:nGETRECORDCOUNTRESULT
	Else
		HttpSession->nRecordCount := 0
	EndIf 
	
	If oObj:GetAnnotationsList()
	
		If lBsc .And. !Empty(cBsc) // Dados Enviados pelo Form de Busca Avancada
			aBsc := aIntStrFil( cBsc )
			If cOpc == "4" // Busca avancada por data
				For nX := 1 to len(aBsc)
					aBsc[nX,1] := dtos(ctod(aBsc[nX,1]))
				Next nX
			EndIf
		Endif
	
		HttpSession->WSPMS30RESULT := {}
		For nX := 1 To Len(oObj:oWSGETANNOTATIONSLISTRESULT:oWSANNOTATIONSLISTVIEW)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ .: BUSCA AVANCADA :. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lBsc .And. !Empty(cBsc) // Dados Enviados pelo Form de Busca Avancada
				lNext := BscAvanWeb( cOpc, aBsc, {	oObj:oWSGETANNOTATIONSLISTRESULT:oWSANNOTATIONSLISTVIEW[nX]:cPROJECTCODE						,;
														oObj:oWSGETANNOTATIONSLISTRESULT:oWSANNOTATIONSLISTVIEW[nX]:cPROJECTTASK				,;
														oObj:oWSGETANNOTATIONSLISTRESULT:oWSANNOTATIONSLISTVIEW[nX]:cRESOURCECODE				,;
														Dtos(oObj:oWSGETANNOTATIONSLISTRESULT:oWSANNOTATIONSLISTVIEW[nX]:dANNOTATIONDATE)	})
			Endif
			If lNext
				AAdd(HttpSession->WSPMS30RESULT,{	oObj:oWSGETANNOTATIONSLISTRESULT:oWSANNOTATIONSLISTVIEW[nX]:cProjectCode						,;
														oObj:oWSGETANNOTATIONSLISTRESULT:oWSANNOTATIONSLISTVIEW[nX]:cProjectTask				,;
														oObj:oWSGETANNOTATIONSLISTRESULT:oWSANNOTATIONSLISTVIEW[nX]:cResourceCode				,;
														oObj:oWSGETANNOTATIONSLISTRESULT:oWSANNOTATIONSLISTVIEW[nX]:dAnnotationdate			,;
														oObj:oWSGETANNOTATIONSLISTRESULT:oWSANNOTATIONSLISTVIEW[nX]:cExecutedInitialHour		,;
														oObj:oWSGETANNOTATIONSLISTRESULT:oWSANNOTATIONSLISTVIEW[nX]:cFinalHourExecuted		,;
														oObj:oWSGETANNOTATIONSLISTRESULT:oWSANNOTATIONSLISTVIEW[nX]:nNumberofHours			,;
														oObj:oWSGETANNOTATIONSLISTRESULT:oWSANNOTATIONSLISTVIEW[nX]:cDocumentCode				,;
														oObj:oWSGETANNOTATIONSLISTRESULT:oWSANNOTATIONSLISTVIEW[nX]:cDocumentItem				,;
														oObj:oWSGETANNOTATIONSLISTRESULT:oWSANNOTATIONSLISTVIEW[nX]:nDbRecord					})
																	
			Endif
		Next nX
		cHtml += ExecInPage( "PWSP031A" )
	Else
		HttpSession->cLinkErro	:= ""
		HttpSession->cBotaoErro	:= ""
		HttpSession->cErro		:=	StrGantt( GetWscError(3) )
		cHtml 						:= ExecInPage( "PWSP001" )
	Endif

WEB EXTENDED END

Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP032   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pagina p/ Inclusao-Exclusao-Visualizacao-Edicao dos        º±±
±±º          ³ apontamentos de uma tarefa.								        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP032()

Local cHtml			:= ""
Local nA			:= 0
Local cDbRecord		:= HttpGet->cChave
Local cOpc			:= HttpGet->cOpc
Local aF3Web		:= Nil
Local cParamAdicF3	:=	""
Local cSizeWndF3	:= ""		
Local nX			:=	""
Local lContinua	:= .T.

WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSANNOTATIONS' ), WSPMSANNOTATIONS():New() )
WsChgURL( @oObj, "PMSANNOTATIONS.APW" )

oObj:cUSERCODE			:= GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
oObj:nOperationNumber	:= Val(cOpc)

HttpSession->cOpc   := cOpc
HttpSession->cChave := cDbRecord

oObj:cHeaderType := "ANNOTATIONVIEW"
If oObj:GetHeaderPms()
	HttpSession->WSPMS32RESULT := {}

	AAdd(HttpSession->WSPMS32RESULT,{} ) // Posicao 1 Reservado para campos do aHeader
	For nA := 1 To Len( oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS )
		If oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:CHEADERFIELD == "AFU_HQUANT"
			If cOpc == "3" .OR. cOpc == "4"
				lContinua := .F.
			Else
				lContinua := .T.
			EndIf
		Else
			lContinua := .T.
		EndIf
		If lContinua
			aF3Web			:=	Nil       
			cParamAdicF3  :=	""
			cSizeWndF3		:= ""		
			Do Case 
				Case Alltrim(oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERF3) == "AF8"
					aF3Web	:=	{{'GETPROJECT',;
										{'AFU_PROJET','CPROJECTCODE'    },;
										 {'AFU_REVISA','CPROJECTREVISION'};
										},;
										{'CPROJECTCODE','CDESCRIPTION'}}
				Case Alltrim(oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERF3) == "AF9"
					aF3Web	:=	{{'GETTASK',;
										{'AFU_TAREFA','CTASKCODE'    };
										},;
										{'CTASKCODE','CTASKDESCRIPTION','DESTIMATEDINITIALDATE','DESTIMATEDFINALDATE'}}
					cParamAdicF3	:=	"new Array('cPROJECTCODE','AFU_PROJET')"
					cSizeWndF3 		:=	'width=500,height=300'
				Case Alltrim(oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERF3) == "AE8"
					aF3Web	:=	{{'GETRESOURCE',;
										{'AFU_RECURS','CRESOURCECODE'    };
										},;
										{'CRESOURCECODE','CRESOURCENAME'}}
				Case Alltrim(oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERF3) == "SB1"
					aF3Web	:=	{{'GETCATALOG',;
										{'AFU_COD','CPRODUCTCODE'    };
										},;
										{'CPRODUCTCODE','CDESCRIPTION'}}
			EndCase
			AAdd(HttpSession->WSPMS32RESULT[1],{	oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERCOMBOBOX,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:nHEADERDEC     ,;
																{aF3Web,cParamAdic,cSizeWndF3}									      ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERFIELD   ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:lHEADEROBLIG   	,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERPICTURE ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:nHEADERSIZE   	,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERTITLE  	,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERTYPE   	,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERFOLDER 	,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERORDER   ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cEDITABLE     	,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cPROPRIETYNAME	,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cINITIALVALUE  ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERTYPE2   	,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:lUSERFIELD     })
		EndIf
	Next nA                                                              
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Indica que foi acessado pelo menu principal de Apontamentos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	HttpSession->cPage22 := "0" 
	
	If cOpc == "3" // Incluir
		AAdd( HttpSession->WSPMS32RESULT, {	} )
		nA := Len( HttpSession->WSPMS32RESULT )  
		For nX := 1 To Len(HttpSession->WSPMS32RESULT[1])                           
			If !Empty(HttpSession->WSPMS32RESULT[1,nX,14])
				Do Case
					Case HttpSession->WSPMS32RESULT[1,nX,9] == "D"
						AAdd(HttpSession->WSPMS32RESULT[nA],Ctod(HttpSession->WSPMS32RESULT[1,nX,14]))		
					Case HttpSession->WSPMS32RESULT[1,nX,9] == "N"
						AAdd(HttpSession->WSPMS32RESULT[nA],Val(HttpSession->WSPMS32RESULT[1,nX,14]))		
					Case HttpSession->WSPMS32RESULT[1,nX,9] == "L"
						AAdd(HttpSession->WSPMS32RESULT[nA],HttpSession->WSPMS32RESULT[1,nX,14]==".T.")		
					OtherWise 
						AAdd(HttpSession->WSPMS32RESULT[nA],HttpSession->WSPMS32RESULT[1,nX,14])		
				EndCase	
			Else
				AAdd(HttpSession->WSPMS32RESULT[nA],"")	
			Endif

			If HttpSession->WSPMS32RESULT[1,nX,4] == "AFU_DATA" .And. Empty(HttpSession->WSPMS32RESULT[nA,nX])
				HttpSession->WSPMS32RESULT[nA,nX]	:=	Date()
			Endif

			// obtem o codigo do recurso, caso este esteja associado ao usuario de sistema e consequentemente pelo usuario do portal
			If HttpSession->WSPMS32RESULT[1,nX,4] == "AFU_RECURS"
				HttpSession->WSPMS32RESULT[nA,nX]	:=	GetRecCode(HttpSession->USR_INFO[1]:cUserCode)
			EndIf

		Next nX
		cHtml += ExecInPage( "PWSP032" )
	Else                                        
		If cDbRecord <> Nil
			oObj:nDbRecord				:= Val(cDbRecord)
		Endif
		If oObj:GetAnnotation()  
	
			AAdd( HttpSession->WSPMS32RESULT, {	} )
			nA := Len( HttpSession->WSPMS32RESULT )

			For nX := 1 To Len(HttpSession->WSPMS32RESULT[1])       
				If HttpSession->WSPMS32RESULT[1,nX,16]   
					nPosCpo	:=	Ascan(oObj:oWSGETANNOTATIONRESULT:oWSANNOTATIONVIEW[1]:oWSUserFields:OWSUSERFIELD,{|x| x:cUserName==HttpSession->WSPMS32RESULT[1,nX,13]})
					AAdd(HttpSession->WSPMS32RESULT[nA],oObj:oWSGETANNOTATIONRESULT:oWSANNOTATIONVIEW[1]:oWSUserFields:OWSUSERFIELD[nPosCpo]:cUserTag)
				Else
					If Upper(Alltrim(HttpSession->WSPMS32RESULT[1,nX,13])) == 'NOTES'                    //Tratamento especial pois e um objeto
						AAdd(HttpSession->WSPMS32RESULT[nA],	oObj:oWSGETANNOTATIONRESULT:oWSANNOTATIONVIEW[1]:oWSNOTES)
					Else
						AAdd(HttpSession->WSPMS32RESULT[nA],  &("oObj:oWSGETANNOTATIONRESULT:oWSANNOTATIONVIEW[1]:"+HttpSession->WSPMS32RESULT[1,nX,15]+HttpSession->WSPMS32RESULT[1,nX,13] ))
					Endif
				Endif				
			Next nX
			cHtml += ExecInPage( "PWSP032" )
			
		Else
			HttpSession->cLinkErro	:= ""
			HttpSession->cBotaoErro	:= ""
			HttpSession->nNewWin		:= 1
			HttpSession->cErro		:=	StrGantt( GetWscError(3) )
			cHtml 						:= ExecInPage( "PWSP001" )
		Endif
	Endif
Else
	HttpSession->cLinkErro	:= ""
	HttpSession->cBotaoErro	:= ""
	HttpSession->nNewWin		:= 1
	HttpSession->cErro		:=	StrGantt( GetWscError(3) )
	cHtml 						:= ExecInPage( "PWSP001" )
Endif

WEB EXTENDED END

Return cHtml                                   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP033   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pagina p/ Inclusao dos apontamentos que veem da pagina 22  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP033()

Local cHtml			:= ""
Local cRev			:= ""
Local nA			:= 0 
Local nX			:= 0 
Local aF3Web		:= Nil
Local cParamAdicF3  := ""
Local cSizeWndF3	:= ""		
Local cResource		:= ""
Local cRecurso		:= ""

WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSANNOTATIONS' ), WSPMSANNOTATIONS():New() )
WsChgURL( @oObj, "PMSANNOTATIONS.APW" )

oObj:cUSERCODE			:= GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
oObj:cPROJECTCODE			:= HttpGet->cProjectCode
oObj:cTASKCODE			:= HttpGet->cTaskCode

oObj:cHeaderType := "INSERTANNOTATIONVIEW"
If oObj:GetHeaderPms()
	HttpSession->WSPMS32RESULT := {}

	AAdd(HttpSession->WSPMS32RESULT,{} ) // Posicao 1 Reservado para campos do aHeader
	For nA := 1 To Len( oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS )        
		aF3Web			:=	Nil       
		cParamAdicF3  :=	""
		cSizeWndF3		:= ""		
		Do Case 
			Case Alltrim(oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERF3) == "AF8"
				aF3Web	:=	{{'GETPROJECT',;
									{'AFU_PROJET','CPROJECTCODE'    },;
									 {'AFU_REVISA','CPROJECTREVISION'};
									},;
									{'CPROJECTCODE','CDESCRIPTION'}}
			Case Alltrim(oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERF3) == "AF9"
				aF3Web	:=	{{'GETTASK',;
									{'AFU_TAREFA','CTASKCODE'    };
									},;
									{'CTASKCODE','CTASKDESCRIPTION','DESTIMATEDINITIALDATE','DESTIMATEDFINALDATE'}}
				cParamAdicF3	:=	"new Array('cPROJECTCODE','AFU_PROJET')"
				cSizeWndF3 		:=	'width=500,height=300'
			Case Alltrim(oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERF3) == "AE8"
				aF3Web	:=	{{'GETRESOURCE',;
									{'AFU_RECURS','CRESOURCECODE'    };
									},;
									{'CRESOURCECODE','CRESOURCENAME'}}
			Case Alltrim(oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERF3) == "SB1"
				aF3Web	:=	{{'GETCATALOG',;
									{'AFU_COD','CPRODUCTCODE'    };
									},;
									{'CPRODUCTCODE','CDESCRIPTION'}}
		EndCase
		AAdd(HttpSession->WSPMS32RESULT[1],{	oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERCOMBOBOX,;
															oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:nHEADERDEC     ,;
															{aF3Web,cParamAdic,cSizeWndF3}									      ,;
															oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERFIELD    ,;
															oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:lHEADEROBLIG    ,;
															oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERPICTURE  ,;
															oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:nHEADERSIZE     ,;
															oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERTITLE    ,;
															oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERTYPE     ,;
															oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERFOLDER   ,;
															oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERORDER    ,;
															oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cEDITABLE       ,;
															oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cPROPRIETYNAME  ,;
															oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cINITIALVALUE   ,;
															oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERTYPE2   	,;
															oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:lUSERFIELD     })
	Next nA
      
	If oObj:GetInsertAnnotation()
	
		cRev := oObj:cGETINSERTANNOTATIONRESULT

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa o Objeto WS - WSMTPROJECT³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObjRes := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPmsReport' ), WSPmsReport():New() )
		WsChgUrl( @oObjRes, "PMSREPORT.APW" )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETResource
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObjRes:cUSERCODE				:= GtPtUsrCod()[1]
		oObjRes:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
		
		// Seta se o usuario atual do portal é administrador
		cRecurso := GetRecCode(oObjRes:cUSERCODE)
		
		//cUSERCODE,cTYPEOFPRODUCTIN,cGROUPOFPRODUCTIN,cPRODUCTCODELIKE,cDESCRIPTIONLIKE,nPAGELEN,nPAGEFIRST,cQUERYADDWHERE,cINDEXKEY
		If oObjRes:GetMyResource()
			If (oObjRes:oWSGETMYRESOURCERESULT:cResourceCode)==Nil
				cResource	:=	""
			else
				cResource	:=	oObjRes:oWSGETMYRESOURCERESULT:cResourceCode
			Endif
		Endif
			
		AAdd( HttpSession->WSPMS32RESULT, {	} )
		nA := Len( HttpSession->WSPMS32RESULT )

		For nX := 1 To Len(HttpSession->WSPMS32RESULT[1])                           
			If !Empty(HttpSession->WSPMS32RESULT[1,nX,14])
				Do Case
				Case HttpSession->WSPMS32RESULT[1,nX,9] == "D"
		 			AAdd(HttpSession->WSPMS32RESULT[nA],Ctod(HttpSession->WSPMS32RESULT[1,nX,14]))		
				Case HttpSession->WSPMS32RESULT[1,nX,9] == "N"                      
		 			AAdd(HttpSession->WSPMS32RESULT[nA],Val(HttpSession->WSPMS32RESULT[1,nX,14]))		
				Case HttpSession->WSPMS32RESULT[1,nX,9] == "L"
		 			AAdd(HttpSession->WSPMS32RESULT[nA],HttpSession->WSPMS32RESULT[1,nX,14]==".T.")		
				OtherWise 
		 			AAdd(HttpSession->WSPMS32RESULT[nA],HttpSession->WSPMS32RESULT[1,nX,14])	
				EndCase	
			Else
	 			AAdd(HttpSession->WSPMS32RESULT[nA],"")	
			Endif
			If HttpSession->WSPMS32RESULT[1,nX,4] == "AFU_PROJET"
				HttpSession->WSPMS32RESULT[nA,nX]	:=	HttpGet->cProjectCode
			ElseIf HttpSession->WSPMS32RESULT[1,nX,4] == "AFU_DATA" .And. Empty(HttpSession->WSPMS32RESULT[nA,nX])
				HttpSession->WSPMS32RESULT[nA,nX]	:=	Date()
			ElseIf HttpSession->WSPMS32RESULT[1,nX,4] == "AFU_REVISA"
				HttpSession->WSPMS32RESULT[nA,nX]	:=	cRev
			ElseIf HttpSession->WSPMS32RESULT[1,nX,4] == "AFU_TAREFA"
				HttpSession->WSPMS32RESULT[nA,nX]	:=	HttpGet->cTaskCode
			ElseIf !Empty(cResource) .And. HttpSession->WSPMS32RESULT[1,nX,4] == "AFU_RECURS" 
				HttpSession->WSPMS32RESULT[nA,nX]	:=	cResource
			Endif
		Next nX
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Indica que foi acessado pela pagina 22 de projetos ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		HttpSession->cPage22	:= "1" 
		HttpSession->cOpc 	:= "3" 
			
		cHtml += ExecInPage( "PWSP032" )
	Else
		HttpSession->cLinkErro	:= ""
		HttpSession->cBotaoErro	:= ""
		HttpSession->nNewWin		:= 1
		HttpSession->cErro		:=	StrGantt( GetWscError(3) )
		cHtml 						:= ExecInPage( "PWSP001" )
	Endif
	
Else
	HttpSession->cLinkErro	:= ""
	HttpSession->cBotaoErro	:= ""
	HttpSession->nNewWin		:= 1
	HttpSession->cErro		:=	StrGantt( GetWscError(3) )
	cHtml 						:= ExecInPage( "PWSP001" )
Endif

WEB EXTENDED END

Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP034   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Deleta Apontamento											        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP034()

Local cHtml		:= ""
Local aDados	:= {}
Local nOpc		:= Val(HttpGet->cOpc) 
Local aPost		:= HttpPost->aPost
Local nPos		:= 0
Local nX

WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSANNOTATIONS' ), WSPMSANNOTATIONS():New() )
WsChgURL( @oObj, "PMSANNOTATIONS.APW" )

oObj:cUSERCODE				:= GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]

oObj1 := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():New() )
WsChgURL( @oObj1, "CFGDICTIONARY.APW" )

oObj1:cUSERCODE 	:= GetUsrCode()
oObj1:cALIAS		:= "AFU"

//////////////////////////////////////////////////////
// Alimenta Dados para Gravacao pela Rotina Automatica

	oObj:nOperationNumber := nOpc
	////////////////
	// Dados do Form
	aDados := GetPost( aPost )
	oObj:oWSANNOTATIONHANDLE := PMSANNOTATIONS_ANNOTATIONVIEW():New()
	If oObj1:GETUSERFIELD()
		oObj:oWSANNOTATIONHANDLE:oWSUserFields := PMSANNOTATIONS_ARRAYOFUSERFIELD():New()
		For nX := 1 To Len( oObj1:oWSGETUSERFIELDRESULT:oWSUSERFIELD )
			AAdd( oObj:oWSANNOTATIONHANDLE:oWSUserFields:oWsUserField, PMSANNOTATIONS_USERFIELD():New() ) 
						
			oObj:oWSANNOTATIONHANDLE:oWSUserFields:oWSUSERFIELD[nX]:nUSERDEC		:= oObj1:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nX]:nUSERDEC
			oObj:oWSANNOTATIONHANDLE:oWSUserFields:oWSUSERFIELD[nX]:cUSERNAME		:= oObj1:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nX]:cUSERNAME
			oObj:oWSANNOTATIONHANDLE:oWSUserFields:oWSUSERFIELD[nX]:lUSEROBLIG		:= oObj1:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nX]:lUSEROBLIG
			oObj:oWSANNOTATIONHANDLE:oWSUserFields:oWSUSERFIELD[nX]:cUSERPICTURE	:= oObj1:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nX]:cUSERPICTURE
			oObj:oWSANNOTATIONHANDLE:oWSUserFields:oWSUSERFIELD[nX]:nUSERSIZE		:= oObj1:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nX]:nUSERSIZE
			oObj:oWSANNOTATIONHANDLE:oWSUserFields:oWSUSERFIELD[nX]:cUSERTAG		:= oObj1:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nX]:cUSERTAG
			oObj:oWSANNOTATIONHANDLE:oWSUserFields:oWSUSERFIELD[nX]:cUSERTITLE		:= oObj1:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nX]:cUSERTITLE
			oObj:oWSANNOTATIONHANDLE:oWSUserFields:oWSUSERFIELD[nX]:cUSERTYPE		:= oObj1:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nX]:cUSERTYPE
			oObj:oWSANNOTATIONHANDLE:oWSUserFields:oWSUSERFIELD[nX]:cUSERCOMBOBOX	:= oObj1:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nX]:cUSERCOMBOBOX
		Next					
	Endif
	For nX := 1 To Len(HttpSession->WSPMS32RESULT[1])       
		If HttpSession->WSPMS32RESULT[1,nX,16]   
			nPosCpo	:=	Ascan(oObj:oWSANNOTATIONHANDLE:oWSUserFields:OWSUSERFIELD,{|x| x:cUserName==HttpSession->WSPMS32RESULT[1,nX,13]})
			cTipo		:=	oObj:oWSANNOTATIONHANDLE:oWSUserFields:OWSUSERFIELD[nPosCpo]:cUserType
			cField	:=	"oObj:oWSANNOTATIONHANDLE:oWSUserFields:OWSUSERFIELD[nPosCpo]:cUserTag"
		 	nPos := aScan(aDados,{|x| x[1]=oObj:oWSANNOTATIONHANDLE:oWSUserFields:OWSUSERFIELD[nPosCpo]:cUserName})
		 	
		ElseIf HttpSession->WSPMS32RESULT[1,nX,4] == "AFU_OBS"
		 	nPos := aScan(aDados,{|x| x[1]=HttpSession->WSPMS32RESULT[1,nX,4]})
			cTipo		:=	"C"
			cField	:=	"oObj:oWSANNOTATIONHANDLE:cObs"
		Else		
		 	nPos 	:= aScan(aDados,{|x| x[1]=HttpSession->WSPMS32RESULT[1,nX,4]})
			cTipo		:=	HttpSession->WSPMS32RESULT[1,nX,15]
			cField	:=	"oObj:oWSANNOTATIONHANDLE:"+HttpSession->WSPMS32RESULT[1,nX,15]+HttpSession->WSPMS32RESULT[1,nX,13] 
		Endif
		If nPos > 0
			cCont		:=	aDados[nPos][2]
			Do Case
			Case cTipo == "D"
				&cField	:=	Ctod(cCont)
			Case cTipo == "N"
				&cField	:=	Val(cCont)
			Case cTipo == "L"
				&cField	:=	"T"$(cCont)
			OtherWise 
				&cField	:=	  cCont
			EndCase	
		Endif                 	
	Next nX

If oObj:AnnotationHandle()

	HttpSession->WSPMS32XRESULT := { oObj:oWSANNOTATIONHANDLERESULT:oWSMESSAGEVIEW }

	//////////////////////////////////////////
	// Pagina em comum para todas as operacoes
	// Inclusao - Exclusao - Edicao                          


	cHtml += ExecInPage( "PWSP032X" ) 

Else
	HttpSession->cLinkErro	:= ""
	HttpSession->cBotaoErro	:= ""
	HttpSession->nNewWin		:= 1
	HttpSession->cErro		:=	StrGantt( GetWscError(3) )
	cHtml 						:= ExecInPage( "PWSP001" )
Endif

WEB EXTENDED END

Return cHtml
