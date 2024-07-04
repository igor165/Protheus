#INCLUDE "PWSP060.ch"
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
±±				    ÀÄ> ALOCACAO DE RECURSOS					  							±±
±±																		   						±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP060   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pagina inicial do item "Aloc. Recursos" do menu principal. º±±
±±º          ³ Escopo do filtro                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP060()

Local cHtml := ""

WEB EXTENDED INIT cHtml

cHtml += ExecInPage( "PWSP060" )

WEB EXTENDED END

Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP061   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Resposta do filtro para Alocacao de Recursos.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP061()

Local cHtml := ""
Local aBsc	:= {}
Local cBsc	:= ""
Local lBsc	:= ( HttpPost->cBusca == "2" )
Local cOpc	:= ""
Local lNext	:= .T.
Local oObj
Local nX
Local cResourceInitial, cResourceFinal


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta variaveis para chamada desta pagina     ³
//³ de diversos pontos do portal, sem a necessidade³
//³ de se passa-las via Form Metodo POST           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType( HttpPost->cRESOURCEINITIAL	) == "U"
	cResourceInitial := HttpSession->cResourceInitial
Else
	cResourceInitial := HttpPost->cRESOURCEINITIAL
Endif
If ValType( HttpPost->cRESOURCEFINAL	) == "U"
	cResourceFinal   := HttpSession->cResourceFinal
Else
	cResourceFinal   := HttpPost->cRESOURCEFINAL
Endif


WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSREPORT' ), WSPMSREPORT():New() )
WsChgURL( @oObj, "PMSREPORT.APW" )

oObj:cUSERCODE				:= GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
oObj:cRESOURCEINITIAL	:= cResourceInitial
oObj:cRESOURCEFINAL		:= cResourceFinal
cBsc							:= HttpPost->cBuscaAv
cOpc							:= HttpPost->cComboAv

HttpSession->cResourceInitial := cResourceInitial
HttpSession->cResourceFinal   := cResourceFinal

oObj:cHeaderType := "ResourceView"
If oObj:GetHeader()
	HttpSession->WSPMS60RESULT := {}
	
	AAdd(HttpSession->WSPMS60RESULT,{} ) // Posicao 1 Reservado para campos do aHeader
	//Incluir cabecalho para checkbox
	AAdd(HttpSession->WSPMS60RESULT[1],{	"" ,;//oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:cHEADERCOMBOBOX ,;
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
		AAdd(HttpSession->WSPMS60RESULT[1],{	oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:cHEADERCOMBOBOX ,;
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

	If oObj:GetResourceList()  
		If lBsc .And. !Empty(cBsc) // Dados Enviados pelo Form de Busca Avancada
			aBsc := aIntStrFil( cBsc )
		Endif
		For nX := 1 To Len(oObj:oWSGETRESOURCELISTRESULT:oWSRESOURCEVIEW)
			If lBsc .And. !Empty(cBsc) // Dados Enviados pelo Form de Busca Avancada
				lNext := BscAvanWeb( cOpc, aBsc, {	oObj:oWSGETRESOURCELISTRESULT:oWSRESOURCEVIEW[nX]:cRESOURCECODE,;
																oObj:oWSGETRESOURCELISTRESULT:oWSRESOURCEVIEW[nX]:cRESOURCENAME})
			Endif
			If lNext
				AAdd(HttpSession->WSPMS60RESULT,{	" ",;
																oObj:oWSGETRESOURCELISTRESULT:oWSRESOURCEVIEW[nX]:cRESOURCECODE	,;
																oObj:oWSGETRESOURCELISTRESULT:oWSRESOURCEVIEW[nX]:cRESOURCENAME	,;
																oObj:oWSGETRESOURCELISTRESULT:oWSRESOURCEVIEW[nX]:cCALENDAR		,;
																oObj:oWSGETRESOURCELISTRESULT:oWSRESOURCEVIEW[nX]:cTEAMCODE		,;
																oObj:oWSGETRESOURCELISTRESULT:oWSRESOURCEVIEW[nX]:cTEAMNAME		})
			Endif
		Next nX
 		cHtml += ExecInPage( "PWSP061" )
	Else
		HttpSession->cLinkErro	:= "W_PWSP060.APW"
		HttpSession->cBotaoErro	:= STR0006 //"voltar"
		HttpSession->cErro		:=	StrGantt( GetWscError() )
		cHtml 						:= ExecInPage( "PWSP001" )
	Endif

Else
	HttpSession->cLinkErro	:= "W_PWSP060.APW"
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
±±ºPrograma  ³PWSP062   ºAutor  ³Bruno Sobieski      º Data ³  31/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Apos confirmacao dos recursos, seta paramatros para Gantt  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP062()

Local cHtml			:= ""
Local aResources	:= {}
Local aPost			:= {}

WEB EXTENDED INIT cHtml

	aPost	      := HttpPost->aPost
	aResources	:= GetPost( aPost )
	
   HttpSession->aResources	:= aResources
	cHtml += ExecInPage( "PWSP062" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP063   ºAutor  ³Bruno Sobieski      º Data ³  31/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta dados para o Gantt de recursos                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP063()

Local cHtml := ""
Local oObj
Local nX
Local aResources	:=	{}


WEB EXTENDED INIT cHtml

If HttpGet->Applet<>"1"
	
	aResources	:=	 HttpSession->aResources
	oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSREPORT' ), WSPMSREPORT():New() )
	WsChgURL( @oObj, "PMSREPORT.APW" )
	
	oObj:cUSERCODE				:= GtPtUsrCod()[1]
	oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
	
	oObj:cResourcesCodes   	:= ""
	oObj:dDateInitial     	:= Ctod(HttpPost->cDateInitial)
	oObj:dDateFinal     		:= Ctod(HttpPost->cDateFinal)
	
	
	For nX:= 1 to Len(aResources)
		If Upper(Substr(aResources[nX,1],1,3))=="REC"
			oObj:cResourcesCodes +=	Padr(Substr(aResources[nX,2],1,15),15)
		Endif
	Next
	If !Empty(oObj:cResourcesCodes) .And. oObj:GETGANTTRES()
		HttpSession->WSGANTTRESULT	:=	{}      
		
		HttpSession->WSGANTTHEADER	:=	"TASKTYPE#PROJECTCODE#TASKCODE#TASKDESCRIPTION#TIMEDURATION#ESTIMATEDINITIALDATE#ESTIMATEDFINALDATE#"+;
													"ESTIMATEDINITIALHOUR#ESTIMATEDFINALHOUR#EXECUTIONINITIALDATE#EXECUTIONFINALDATE#POC#"+;
													"CPM#LEVEL#RESOURCES#BITMAP#DBRECORD"
		
		For nX := 1 To Len( oObj:oWSGETGANTTRESRESULT:OWSGANTTTASKVIEW)
			AAdd(HttpSession->WSGANTTRESULT	, 	Alltrim(Str(oObj:oWSGETGANTTRESRESULT:OWSGANTTTASKVIEW[nX]:nTaskType))					+_SEPARADOR+;				
														 	oObj:oWSGETGANTTRESRESULT:OWSGANTTTASKVIEW[nX]:cProjectCode         	   				+_SEPARADOR+;
														 	oObj:oWSGETGANTTRESRESULT:OWSGANTTTASKVIEW[nX]:cTaskCode            	   				+_SEPARADOR+;
															oObj:oWSGETGANTTRESRESULT:OWSGANTTTASKVIEW[nX]:cTaskDescription 							+_SEPARADOR+;    
															TransForm(oObj:oWSGETGANTTRESRESULT:OWSGANTTTASKVIEW[nX]:nTimeDuration,"9999.99")	+_SEPARADOR+;
															Dtos(oObj:oWSGETGANTTRESRESULT:OWSGANTTTASKVIEW[nX]:dEstimatedInitialDate)			+_SEPARADOR+;
															Dtos(oObj:oWSGETGANTTRESRESULT:OWSGANTTTASKVIEW[nX]:dEstimatedFinalDate)				+_SEPARADOR+;
															oObj:oWSGETGANTTRESRESULT:OWSGANTTTASKVIEW[nX]:cEstimatedInitialHour						+_SEPARADOR+;
															oObj:oWSGETGANTTRESRESULT:OWSGANTTTASKVIEW[nX]:cEstimatedFinalHour						+_SEPARADOR+;
															Dtos(oObj:oWSGETGANTTRESRESULT:OWSGANTTTASKVIEW[nX]:dExecutionInitialDate)			+_SEPARADOR+;
															Dtos(oObj:oWSGETGANTTRESRESULT:OWSGANTTTASKVIEW[nX]:dExecutionFinalDate)				+_SEPARADOR+;
															TransForm(oObj:oWSGETGANTTRESRESULT:OWSGANTTTASKVIEW[nX]:nPOC,"999.99%")				+_SEPARADOR+;
															Alltrim(Str(oObj:oWSGETGANTTRESRESULT:OWSGANTTTASKVIEW[nX]:nCPM))						+_SEPARADOR+;
															oObj:oWSGETGANTTRESRESULT:OWSGANTTTASKVIEW[nX]:cLevel		           						+_SEPARADOR+;
															oObj:oWSGETGANTTRESRESULT:OWSGANTTTASKVIEW[nX]:cResources	           					+_SEPARADOR+;
															oObj:oWSGETGANTTRESRESULT:OWSGANTTTASKVIEW[nX]:cBitMap		           					+_SEPARADOR+;
															Alltrim(Str(oObj:oWSGETGANTTRESRESULT:OWSGANTTTASKVIEW[nX]:nDbRecord)) 				+_SEPARADOR)
		Next nX  
		If Len(HttpSession->WSGANTTRESULT) > 0
			cHtml += ExecInPage( "PWSP063" )
		Else
			HttpSession->cLinkErro	:= "W_PWSP061.APW"
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
	cHtml += ExecInPage( "PWSP063" )
Endif	

WEB EXTENDED END

Return cHtml