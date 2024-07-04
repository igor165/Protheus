#INCLUDE "PWSP070.ch"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGAWIN.CH"   
#DEFINE _SEPARADOR ' |'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±																		  							±±
±±  MENU (Portal Projetos)										   						±±
±±	   ÀÄ> CONSULTAS          										   					±±
±±				    ÀÄ> ALOCACAO DE EQUIPES 					  							±±
±±																		   						±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP070   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pagina inicial do item "Aloc. Equipes" do menu principal.  º±±
±±º          ³ Escopo do filtro                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP070()

Local cHtml := ""

WEB EXTENDED INIT cHtml

cHtml += ExecInPage( "PWSP070" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP071   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Resposta do filtro para Alocacao de Recursos.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP071()

Local cHtml := ""
Local aBsc	:= {}
Local cBsc	:= ""
Local lBsc	:= ( HttpPost->cBusca == "2" )
Local cOpc	:= ""
Local lNext	:= .T.
Local oObj
Local nX
Local cTeamInitial, cTeamFinal


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta variaveis para chamada desta pagina     ³
//³ de diversos pontos do portal, sem a necessidade³
//³ de se passa-las via Form Metodo POST           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType( HttpPost->cTeamINITIAL	) == "U"
	cTeamInitial := HttpSession->cTeamInitial
Else
	cTeamInitial := HttpPost->cTeamINITIAL
Endif
If ValType( HttpPost->cTeamFINAL	) == "U"
	cTeamFinal   := HttpSession->cTeamFinal
Else
	cTeamFinal   := HttpPost->cTeamFINAL
Endif


WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSREPORT' ), WSPMSREPORT():New() )
WsChgURL( @oObj, "PMSREPORT.APW" )

oObj:cUSERCODE				:= GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
oObj:cTeamINITIAL			:= cTeamInitial
oObj:cTeamFINAL			:= cTeamFinal
cBsc							:= HttpPost->cBuscaAv
cOpc							:= HttpPost->cComboAv

HttpSession->cTeamInitial := cTeamInitial
HttpSession->cTeamFinal   := cTeamFinal

oObj:cHeaderType := "TeamView"
If oObj:GetHeader()
	HttpSession->WSPMS70RESULT := {}
	
	AAdd(HttpSession->WSPMS70RESULT,{} ) // Posicao 1 Reservado para campos do aHeader
	//Incluir cabecalho para checkbox
	AAdd(HttpSession->WSPMS70RESULT[1],{	"" ,;//oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:cHEADERCOMBOBOX ,;
														0 	,;//oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:nHEADERDEC      ,;
														""	,;//oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:cHEADERF3       ,;
														""	,;//oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:cHEADERFIELD    ,;
														.F.,;//oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:lHEADEROBLIG    ,;
														""	,;//oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:cHEADERPICTURE  ,;
														5	,;//oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:nHEADERSIZE     ,;
														""	,;//oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:cHEADERTITLE    ,;
														"C",;//	oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:cHEADERTYPE     ,;
														} )		
	For nX := 1 To Len( oObj:oWSGETHEADERRESULT:oWSBRWHEADER )
		AAdd(HttpSession->WSPMS70RESULT[1],{	oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:cHEADERCOMBOBOX ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:nHEADERDEC      ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:cHEADERF3       ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:cHEADERFIELD    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:lHEADEROBLIG    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:cHEADERPICTURE  ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:nHEADERSIZE     ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:cHEADERTITLE    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:cHEADERTYPE     ,;
														} )		
	Next nX

	If oObj:GetTeamList()  
		If lBsc .And. !Empty(cBsc) // Dados Enviados pelo Form de Busca Avancada
			aBsc := aIntStrFil( cBsc )
		Endif
		For nX := 1 To Len(oObj:oWSGETTEAMLISTRESULT:oWSTEAMVIEW)
			If lBsc .And. !Empty(cBsc) // Dados Enviados pelo Form de Busca Avancada
				lNext := BscAvanWeb( cOpc, aBsc, {	oObj:oWSGETTEAMLISTRESULT:oWSTEAMVIEW[nX]:cTeamCODE,;
																oObj:oWSGETTEAMLISTRESULT:oWSTEAMVIEW[nX]:cTeamNAME})
			Endif
			If lNext
				AAdd(HttpSession->WSPMS70RESULT,{	" ",;
																oObj:oWSGETTEAMLISTRESULT:oWSTEAMVIEW[nX]:cTEAMCODE		,;
																oObj:oWSGETTEAMLISTRESULT:oWSTEAMVIEW[nX]:cTEAMNAME		})
			Endif
		Next nX
 		cHtml += ExecInPage( "PWSP071" )
	Else
		HttpSession->cLinkErro	:= "W_PWSP070.APW"
		HttpSession->cBotaoErro	:= STR0006 //"voltar"
		HttpSession->cErro		:=	StrGantt( GetWscError() )
		cHtml 						:= ExecInPage( "PWSP001" )
	Endif

Else
	HttpSession->cLinkErro	:= "W_PWSP070.APW"
	HttpSession->cBotaoErro	:= STR0006 //"voltar"
	HttpSession->cErro		:=	StrGantt( GetWscError() )
	cHtml 						:= ExecInPage( "PWSP001" )
Endif

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP072   ºAutor  ³Bruno Sobieski      º Data ³  31/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de parametro para a montagem do grafico de Gantt      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP072()

Local cHtml  := ""
Local aTeams := {}
Local aPost  := {}


WEB EXTENDED INIT cHtml

	aPost	 := HttpPost->aPost
	aTeams := GetPost( aPost )
	HttpSession->aTeams := aTeams
	
	cHtml += ExecInPage( "PWSP072" )
	
WEB EXTENDED END

Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP073   ºAutor  ³Bruno Sobieski      º Data ³  31/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta dados para o Gantt de equipes                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP073()

Local cHtml := ""
Local oObj
Local nX
Local aTeams	:=	{}


WEB EXTENDED INIT cHtml

If HttpGet->Applet<>"1"
	
	aTeams := HttpSession->aTeams
	oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSREPORT' ), WSPMSREPORT():New() )
	WsChgURL( @oObj, "PMSREPORT.APW" )
	
	oObj:cUSERCODE				:= GtPtUsrCod()[1]
	oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
	
	oObj:cTeamsCodes   		:= ""
	oObj:dDateInitial     	:= Ctod(HttpPost->cDateInitial)
	oObj:dDateFinal     		:= Ctod(HttpPost->cDateFinal)
	
	For nX:= 1 to Len(aTeams)
		If Upper(Substr(aTeams[nX,1],1,3))=="EQP"
			oObj:cTeamsCodes +=	Padr(Substr(aTeams[nX,2],1,10),10)
		Endif
	Next
	If !Empty(oObj:cTeamsCodes) .And. oObj:GETGANTTTEAM()
		HttpSession->WSGANTTRESULT	:=	{}      
		
		HttpSession->WSGANTTHEADER	:=	"TASKTYPE#PROJECTCODE#TASKCODE#TASKDESCRIPTION#TIMEDURATION#ESTIMATEDINITIALDATE#ESTIMATEDFINALDATE#"+;
													"ESTIMATEDINITIALHOUR#ESTIMATEDFINALHOUR#EXECUTIONINITIALDATE#EXECUTIONFINALDATE#POC#"+;
													"CPM#LEVEL#RESOURCES#BITMAP#DBRECORD"
		For nX := 1 To Len( oObj:oWSGETGANTTTEAMRESULT:OWSGANTTTASKVIEW)
			AAdd(HttpSession->WSGANTTRESULT	, 	Alltrim(Str(oObj:oWSGETGANTTTEAMRESULT:OWSGANTTTASKVIEW[nX]:nTaskType))					+_SEPARADOR+;				
														 	oObj:oWSGETGANTTTEAMRESULT:OWSGANTTTASKVIEW[nX]:cProjectCode         	   				+_SEPARADOR+;
														 	oObj:oWSGETGANTTTEAMRESULT:OWSGANTTTASKVIEW[nX]:cTaskCode            	   				+_SEPARADOR+;
															oObj:oWSGETGANTTTEAMRESULT:OWSGANTTTASKVIEW[nX]:cTaskDescription 							+_SEPARADOR+;    
															TransForm(oObj:oWSGETGANTTTEAMRESULT:OWSGANTTTASKVIEW[nX]:nTimeDuration,"9999.99")	+_SEPARADOR+;
															Dtos(oObj:oWSGETGANTTTEAMRESULT:OWSGANTTTASKVIEW[nX]:dEstimatedInitialDate)			+_SEPARADOR+;
															Dtos(oObj:oWSGETGANTTTEAMRESULT:OWSGANTTTASKVIEW[nX]:dEstimatedFinalDate)				+_SEPARADOR+;
															oObj:oWSGETGANTTTEAMRESULT:OWSGANTTTASKVIEW[nX]:cEstimatedInitialHour						+_SEPARADOR+;
															oObj:oWSGETGANTTTEAMRESULT:OWSGANTTTASKVIEW[nX]:cEstimatedFinalHour						+_SEPARADOR+;
															Dtos(oObj:oWSGETGANTTTEAMRESULT:OWSGANTTTASKVIEW[nX]:dExecutionInitialDate)			+_SEPARADOR+;
															Dtos(oObj:oWSGETGANTTTEAMRESULT:OWSGANTTTASKVIEW[nX]:dExecutionFinalDate)				+_SEPARADOR+;
															TransForm(oObj:oWSGETGANTTTEAMRESULT:OWSGANTTTASKVIEW[nX]:nPOC,"999.99%")				+_SEPARADOR+;
															Alltrim(Str(oObj:oWSGETGANTTTEAMRESULT:OWSGANTTTASKVIEW[nX]:nCPM))						+_SEPARADOR+;
															oObj:oWSGETGANTTTEAMRESULT:OWSGANTTTASKVIEW[nX]:cLevel		           						+_SEPARADOR+;
															oObj:oWSGETGANTTTEAMRESULT:OWSGANTTTASKVIEW[nX]:cResources	           					+_SEPARADOR+;
															oObj:oWSGETGANTTTEAMRESULT:OWSGANTTTASKVIEW[nX]:cBitMap		           					+_SEPARADOR+;
															Alltrim(Str(oObj:oWSGETGANTTTEAMRESULT:OWSGANTTTASKVIEW[nX]:nDbRecord)) 				+_SEPARADOR)
		Next nX        
		If Len(HttpSession->WSGANTTRESULT) > 0
			cHtml += ExecInPage( "PWSP073" )
		Else
			HttpSession->cLinkErro	:= "W_PWSP071.APW"
			HttpSession->cBotaoErro	:= STR0006 //"voltar"
			HttpSession->cErro		:=	STR0007  //"Nao foram achadas tarefas para os parametros selecionados"
			cHtml 						:= ExecInPage( "PWSP001" )
		Endif
	Else
		HttpSession->cLinkErro	:= ""
		HttpSession->cBotaoErro	:= ""
		HttpSession->nNewWin		:= 1
		HttpSession->cErro		:=	StrGantt( GetWscError() )
		cHtml 						:= ExecInPage( "PWSP001" )
	Endif
Else
	cHtml += ExecInPage( "PWSP073" )
Endif	

WEB EXTENDED END

Return cHtml