#INCLUDE "PWSP020.ch"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGAWIN.CH"   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±																		  							±±
±±  MENU (Portal Projetos)										   						±±
±±	   ÀÄ> GERENCIAR PROJETOS											   				±±
±±						    ÀÄ> PROJETOS								   					±±
±±																		   						±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP020   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pagina inicial de item "Projetos" do menu principal.       º±±
±±º          ³ Escopo do filtro                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP020()

Local cHtml := ""

WEB EXTENDED INIT cHtml

cHtml += ExecInPage( "PWSP020" )

WEB EXTENDED END

Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP020   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Resposta do filtro para projetos.                          º±±
±±º          ³ (lista projetos dentro do escopo do filtro)                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP021()

Local cHtml := ""
Local cBsc	:= ""
Local aBsc	:= {}
Local lBsc	:= ( HttpPost->cBusca == "2" )
Local cOpc	:= ""
Local lNext	:= .T.
Local oObj
Local nX
Local dDtInitial, dDtFinal, cProjectInitial, cProjectFinal
Local cClientInitial := "", cClientFinal := ""
Local aClients := {}
Local lFilterClients := GetFilClients() == 1
Local i := 0

// Ajusta variaveis para chamada desta pagina
// de diversos pontos do portal, sem a necessidade
// de se passa-las via Form Metodo POST

// Data do Projeto
If ValType( HttpPost->dREGISTERDATEFROM ) == "U"
	dDtInitial      := HttpSession->dDtInitial
Else
	dDtInitial		 := HttpPost->dREGISTERDATEFROM
Endif
If ValType( HttpPost->dREGISTERDATETO   ) == "U"
	dDtFinal        := HttpSession->dDtFinal
Else
	dDtFinal			 := HttpPost->dREGISTERDATETO
Endif

// Projeto
If ValType( HttpPost->cPROJECTINITIAL   ) == "U"
	cProjectInitial := HttpSession->cProjectInitial
Else
	cProjectInitial := HttpPost->cPROJECTINITIAL
Endif
If ValType( HttpPost->cPROJECTFINAL     ) == "U"
	cProjectFinal   := HttpSession->cProjectFinal
Else
	cProjectFinal   := HttpPost->cPROJECTFINAL
Endif

// Cliente

If lFilterClients
	//cClientInitial := ""
	//cClientFinal   := ""
Else
	If ValType(HttpPost->cCLIENTINITIAL) == "U"
		cClientInitial := HttpSession->cClientInitial
	Else
		cClientInitial := HttpPost->cCLIENTINITIAL
	EndIf

	If ValType(HttpPost->cCLIENTFINAL) == "U"
		cClientFinal := HttpSession->cClientFinal
	Else
		cClientFinal := HttpPost->cCLIENTFINAL
	EndIf	
EndIf	

// zera variavel com estrutura do Projeto
HttpSession->aResult := Nil

WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSPROJECTS' ), WSPMSPROJECTS():New() )
WsChgURL( @oObj, "PMSPROJECTS.APW" )

oObj:cUSERCODE				:= GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
oObj:dDATEINITIAL			:= Ctod(dDtInitial)
oObj:dDATEFINAL			:= Ctod(dDtFinal  )
oObj:cPROJECTINITIAL		:= cProjectInitial
oObj:cPROJECTFINAL		:= cProjectFinal

If !lFilterClients
	oObj:cCLIENTINITIAL := cClientInitial
	oObj:cCLIENTFINAL   := cClientFinal
EndIf

cBsc := HttpPost->cBuscaAv
cOpc := HttpPost->cComboAv

HttpSession->dDtInitial 		:= dDtInitial
HttpSession->dDtFinal   		:= dDtFinal
HttpSession->cProjectInitial	:= cProjectInitial
HttpSession->cProjectFinal		:= cProjectFinal
HttpSession->cClientInitial	:= cClientInitial
HttpSession->cClientFinal		:= cClientFinal

oObj:cHeaderType := "PROJECTLISTVIEW"
If oObj:GetHeader()
	HttpSession->WSPMS20RESULT := {}
	
	AAdd(HttpSession->WSPMS20RESULT,{} ) // Posicao 1 Reservado para campos do aHeader
	For nX := 1 To Len( oObj:oWSGETHEADERRESULT:oWSBRWHEADER )
		AAdd(HttpSession->WSPMS20RESULT[1],{	oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:cHEADERCOMBOBOX ,;
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

	If lFilterClients

		// filtro por cliente (usuário logado)
		aClients := GetClients(GtPtUsrCod()[1])

		For i := 1 To Len(aClients)
		
			oObj:cCLIENTINITIAL := aClients[i]
			oObj:cCLIENTFINAL   := aClients[i]
					
			If oObj:GetProject()  
		
				// Dados Enviados pelo Form de Busca Avancada
				If lBsc .And. !Empty(cBsc) 
					aBsc := aIntStrFil( cBsc )
				Endif
				For nX := 1 To Len(oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW)
				
					// Dados Enviados pelo Form de Busca Avancada
					If lBsc .And. !Empty(cBsc) 
						lNext := BscAvanWeb( cOpc, aBsc, {	oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW[nX]:cPROJECTCODE			,;
																		Dtoc(oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW[nX]:dPROJECTDATE)	,;
																		oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW[nX]:cProjectCliente		})
					Endif
					
					If lNext
						AAdd(HttpSession->WSPMS20RESULT,{	oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW[nX]:cPROJECTCODE       ,;
																		Dtoc(oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW[nX]:dPROJECTDATE) ,;
																		oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW[nX]:cDESCRIPTION       ,;
																		oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW[nX]:cProjectRevision   ,;
																		oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW[nX]:cProjectStage      ,;
																		oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW[nX]:cProjectCliente    ,;
																		oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW[nX]:cProjectUnit       })
					Endif
				Next nX
				
			Else
				HttpSession->cLinkErro := "W_PWSP020.APW"
				HttpSession->cBotaoErro := STR0002 //"voltar"
				HttpSession->cErro := StrGantt(GetWscError())
				cHtml := ExecInPage("PWSP001")
			Endif
			
			
		Next		

		cHtml += ExecInPage( "PWSP021" )				
			
	Else	
	If oObj:GetProject()  

		// Dados Enviados pelo Form de Busca Avancada
		If lBsc .And. !Empty(cBsc) 
			aBsc := aIntStrFil( cBsc )
		Endif
		For nX := 1 To Len(oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW)
		
			// Dados Enviados pelo Form de Busca Avancada
			If lBsc .And. !Empty(cBsc) 
				lNext := BscAvanWeb( cOpc, aBsc, {	oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW[nX]:cPROJECTCODE			,;
																Dtoc(oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW[nX]:dPROJECTDATE)	,;
																oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW[nX]:cProjectCliente		})
			Endif
			
			If lNext
				AAdd(HttpSession->WSPMS20RESULT,{	oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW[nX]:cPROJECTCODE       ,;
																Dtoc(oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW[nX]:dPROJECTDATE) ,;
																oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW[nX]:cDESCRIPTION       ,;
																oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW[nX]:cProjectRevision   ,;
																oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW[nX]:cProjectStage      ,;
																oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW[nX]:cProjectCliente    ,;
																oObj:oWSGETPROJECTRESULT:oWSPROJECTLISTVIEW[nX]:cProjectUnit       })
			Endif
		Next nX
		cHtml += ExecInPage( "PWSP021" )
	Else
		HttpSession->cLinkErro	:= "W_PWSP020.APW"
		HttpSession->cBotaoErro	:= STR0002 //"voltar"
		HttpSession->cErro		:=	StrGantt( GetWscError() )
		cHtml 						:= ExecInPage( "PWSP001" )
	Endif
	EndIf

Else
	HttpSession->cLinkErro	:= "W_PWSP020.APW"
	HttpSession->cBotaoErro	:= STR0002 //"voltar"
	HttpSession->cErro		:=	StrGantt( GetWscError() )
	cHtml 						:= ExecInPage( "PWSP001" )
Endif

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP022   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Detalhes do Projeto.										  			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP022()

Local cHtml			:= ""
Local nA				:= 0
Local nX				:= 0
Local nPosIns		:= 0
Local nPosDel		:= 0
Local dDtInitial	:= If( ValType(HttpGet->dDateInitial)<>"C", "", CtOd(HttpGet->dDateInitial) )
Local dDtFinal		:= If( ValType(HttpGet->dDateFinal  )<>"C", "", CtOd(HttpGet->dDateFinal)   )
Local aRst			:= {}
Local aEdtPai		:= {} // Lista de EDT's Pai para a delecao
Local aEdtAux		:= {}
Local cDescr		:= ""
Local cWbsOpen		:= "" // 1 - EDT fechada | 2 - EDT aberta (flag para indicar se nivel da EDT esta aberta na visualizacao no HTML)
Local	cTaskRfr		:=	""
Local nPosTsk		:=	0
Local lErroWS		:=	.F.

If Empty(dDtInitial)
	dDtInitial := CtoD("01/01/1980")
Endif
If Empty(dDtFinal  )
	dDtFinal   := CtoD("31/12/2030")
Endif

WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSPROJECTS' ), WSPMSPROJECTS():New() )
WsChgURL( @oObj, "PMSPROJECTS.APW" )

oObj:cUSERCODE				:= GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis de filtro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:dDateInitial			:= dDtInitial
oObj:dDateFinal			:= dDtFinal
If !Empty(HttpGet->cPROJECTCODE)
	HttpSession->cPROJECTCODE 		:= HttpGet->cPROJECTCODE
Endif
HttpSession->dDteInitial		:= dDtInitial
HttpSession->dDteFinal			:= dDtFinal

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis de Sessao que serao usadas na pagina 22.aph ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(HttpGet->Target)
	HttpSession->Target		:= HttpGet->Target
Endif
If !Empty(HttpGet->WbsTarget)
	HttpSession->WbsTarget	:= HttpGet->WbsTarget
Endif  
If !Empty(HttpGet->cProjectCode)
	HttpSession->cProjectCode		:= HttpGet->cProjectCode
Endif
If !Empty(HttpGet->cWbsFather)
	HttpSession->cWbsFather		:= HttpGet->cWbsFather
Endif                               
/*                                                                        
//Setar a WsFather como a primeira de todas para que atualize todos os dados
If (HttpSession->aResult<>Nil) .And.	Len(HttpSession->aResult) > 0 .And. HttpSession->cRefreshTask	<> Nil
	HttpSession->cWbsFather		:= HttpSession->aResult[1,1]     
Endif
*/
oObj:cTarget    			:= HttpSession->Target
oObj:cWbsTarget  			:= HttpSession->WbsTarget
oObj:cPROJECTCODE			:= HttpSession->cPROJECTCODE
oObj:cWbsFather			:= HttpSession->cWbsFather

aRst := HttpSession->aResult

If (HttpSession->aResult<>Nil) .And.	Len(HttpSession->aResult) > 0 .And. HttpSession->cRefreshTask	<> Nil
	cTaskRfr	:=	HttpSession->cRefreshTask
	//Forcar Refresh so da tarefa modificada e todas as EDTs para acima
	While !lErroWs	.And. (nPosTsk	:=	Ascan(aRst,{|x| Alltrim(x[1]) == Alltrim(cTaskRfr)})) > 0 
		oObj:cWbsFather			:= aRst[nPosTsk,13]
		If oObj:GetProjectStruct()

			If (nA := Ascan(oObj:oWSGETPROJECTSTRUCTRESULT:oWSPROJECTSTRUCTVIEW,{|x| Alltrim(x:cWbsJobCode) == Alltrim(cTaskRfr)})) > 0
				aRst[nPosTsk,3] :=	oObj:oWSGETPROJECTSTRUCTRESULT:oWSPROJECTSTRUCTVIEW[nA]:cWbsOrJob    			
				aRst[nPosTsk,7] :=	oObj:oWSGETPROJECTSTRUCTRESULT:oWSPROJECTSTRUCTVIEW[nA]:dExecutionInitialDate		
				aRst[nPosTsk,8] :=	oObj:oWSGETPROJECTSTRUCTRESULT:oWSPROJECTSTRUCTVIEW[nA]:dExecutionFinalDate	
				aRst[nPosTsk,9] :=	oObj:oWSGETPROJECTSTRUCTRESULT:oWSPROJECTSTRUCTVIEW[nA]:nExecutionPercentage	       

			Endif		
			cTaskRfr	 := aRst[nPosTsk][13]
		Else
			lErroWs	:=	.T.
		Endif	
	Enddo
	HttpSession->cRefreshTask	:= Nil
	HttpSession->WSPMS22RESULT := aRst
Else
	If oObj:GetProjectStruct()
		HttpSession->WSPMS22RESULT := {}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³           .: Verifica se a EDT esta aberta ou fechada :. 					³
		//³ 1 - EDT fechada | 2 - EDT aberta 													³
		//³(flag para indicar se nivel da EDT esta aberta na visualizacao no HTML) ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If HttpGet->cWbsOpen == Nil
			cWbsOpen := "1"
		Else
			cWbsOpen := HttpGet->cWbsOpen
		Endif
	
		For nA := 1 To Len(oObj:oWSGETPROJECTSTRUCTRESULT:oWSPROJECTSTRUCTVIEW)
			cDescr := ExtraiStr( oObj:oWSGETPROJECTSTRUCTRESULT:oWSPROJECTSTRUCTVIEW[nA]:cDescription, "&nbsp;" )
			
			
			Aadd( HttpSession->WSPMS22RESULT, {	oObj:oWSGETPROJECTSTRUCTRESULT:oWSPROJECTSTRUCTVIEW[nA]:cWbsJobCode  				,;
															cDescr 																									,;
															oObj:oWSGETPROJECTSTRUCTRESULT:oWSPROJECTSTRUCTVIEW[nA]:cWbsOrJob    				,;
															oObj:oWSGETPROJECTSTRUCTRESULT:oWSPROJECTSTRUCTVIEW[nA]:nTimeDuration				,;
															oObj:oWSGETPROJECTSTRUCTRESULT:oWSPROJECTSTRUCTVIEW[nA]:dEstimatedInitialDate		,;
															oObj:oWSGETPROJECTSTRUCTRESULT:oWSPROJECTSTRUCTVIEW[nA]:dEstimatedFinalDate		,;
															oObj:oWSGETPROJECTSTRUCTRESULT:oWSPROJECTSTRUCTVIEW[nA]:dExecutionInitialDate		,;
															oObj:oWSGETPROJECTSTRUCTRESULT:oWSPROJECTSTRUCTVIEW[nA]:dExecutionFinalDate		,;
															oObj:oWSGETPROJECTSTRUCTRESULT:oWSPROJECTSTRUCTVIEW[nA]:nExecutionPercentage		,;
															oObj:oWSGETPROJECTSTRUCTRESULT:oWSPROJECTSTRUCTVIEW[nA]:cOrderList					,;
															oObj:oWSGETPROJECTSTRUCTRESULT:oWSPROJECTSTRUCTVIEW[nA]:cLevel							,;
															"1" /* Inicia sempre fechado */																	,;
															oObj:oWSGETPROJECTSTRUCTRESULT:oWSPROJECTSTRUCTVIEW[nA]:cWbsFather					})
	
		Next nA
		If (HttpSession->aResult<>Nil) .And.	Len(HttpSession->aResult) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ira' fechar nivel da EDT                                     ³
			//³ -> Deleta itens com a EDTPai com mesmo codigo que cWbsFather ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cWbsOpen == "1" 
				RstDelEdt( @aRst, HttpGet->cWbsFather )
	
				////////////////////////////////
				// Indica como Fechada novamente
				nPosIns := aScan( aRst, { |x| x[1] == HttpGet->cWbsFather } )
				If nPosIns > 0
					aRst[nPosIns][12]	:= "1" 
				Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ira' abrir nivel da EDT	                                   ³
			//³ -> Insere itens EDT no array											  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf cWbsOpen == "2" 
				nPosIns := aScan( aRst, { |x| x[1] == HttpGet->cWbsFather } )+1
				If nPosIns > 0
					aRst[nPosIns-1][12] := "2" // Indica como Aberta.
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Insere Tarefas e EDTs que pertencem a EDT Pai ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nX := 1 To Len(HttpSession->WSPMS22RESULT)
						aSize( aRst, Len(aRst)+1	)
						aIns(  aRst, nPosIns			)
						cDescr := ExtraiStr( HttpSession->WSPMS22RESULT[nX][02], "&nbsp;" )
						aRst[nPosIns] := {	HttpSession->WSPMS22RESULT[nX][01]	,;
													cDescr 										,;
													HttpSession->WSPMS22RESULT[nX][03]	,;
													HttpSession->WSPMS22RESULT[nX][04]	,;
													HttpSession->WSPMS22RESULT[nX][05]	,;
													HttpSession->WSPMS22RESULT[nX][06]	,;
													HttpSession->WSPMS22RESULT[nX][07]	,;
													HttpSession->WSPMS22RESULT[nX][08]	,;
			   									HttpSession->WSPMS22RESULT[nX][09]	,;
													HttpSession->WSPMS22RESULT[nX][10]	,;
													HttpSession->WSPMS22RESULT[nX][11]	,;
													HttpSession->WSPMS22RESULT[nX][12]	,;
													HttpSession->WSPMS22RESULT[nX][13]	}
					Next nX
				Endif
			Endif
			HttpSession->WSPMS22RESULT := aRst
		Endif
	Else
		lErroWS	:=	.T.
	Endif
Endif

If !lErroWS	
	cHtml += ExecInPage( "PWSP022" )
Else
	HttpSession->cLinkErro	:= "W_PWSP021.APW"
	HttpSession->cBotaoErro	:= STR0002 //"voltar"
	HttpSession->cErro		:= StrGantt( GetWscError() )
	cHtml 						:= ExecInPage( "PWSP001" )
Endif

WEB EXTENDED END

Return cHtml 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP024   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostra detalhes de uma EDT							      		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP024()

Local cHtml 	:= ""
Local cPrjCod	:= HttpGet->cProjectCode
Local cWbsCod	:= HttpGet->cWbsCode
Local cFolder1	:= HttpGet->cFolder1
Local cFolder2	:= HttpGet->cFolder2

WEB EXTENDED INIT cHtml

	HttpSession->cProjectCode	:= cPrjCod
	HttpSession->cWbsCode		:= cWbsCod
	HttpSession->cFolder1		:= cFolder1
	HttpSession->cFolder2		:= cFolder2
	
	If HttpGet->cBotao == "1" .OR. HttpGet->cBotao == "2"
		cHtml += ExecInPage( "PWSP024HIDE" )
	Else
		cHtml += ExecInPage( "PWSP024" )
	Endif

WEB EXTENDED END

Return cHtml 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP024   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PWSP024FRAME - Mecanismo de troca de informacoes no iFrame º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP024FRAME()

Local cHtml 	:= ""
Local cPrjCod	:= HttpGet->cProjectCode
Local cWbsCod	:= HttpGet->cWbsCode
Local cFolder1	:= HttpGet->cFolder1
Local cFolder2	:= HttpGet->cFolder2

WEB EXTENDED INIT cHtml

	HttpSession->cProjectCode	:= cPrjCod
	HttpSession->cWbsCode		:= cWbsCod
	HttpSession->cFolder1		:= cFolder1
	HttpSession->cFolder2		:= cFolder2

	cHtml += ExecInPage( "PWSP024FRAME" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP024A  ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostra detalhes de uma EDT, Cpos da AFC no iFrame superior º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP024A()

Local cHtml 	:= ""
Local nA			:= 0
Local cPrjCod	:= HttpGet->cProjectCode
Local cWbsCod	:= HttpGet->cWbsCode
Local cFolder1	:= HttpGet->cFolder1
Local cFolder2	:= HttpGet->cFolder2
Local oObj

WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSPROJECTS' ), WSPMSPROJECTS():New() )
WsChgURL( @oObj, "PMSPROJECTS.APW" )

oObj:cUSERCODE				:= GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
oObj:cPROJECTCODE			:= cPrjCod
oObj:cWbsCode				:= cWbsCod

HttpSession->cProjectCode	:= cPrjCod
HttpSession->cWbsCode		:= cWbsCod
HttpSession->cFolder1		:= cFolder1
HttpSession->cFolder2		:= cFolder2

oObj:cHeaderType := "WBSDETAILVIEW"
If oObj:GetHeaderPms()
	HttpSession->WSPMS24ARESULT := {}

	AAdd(HttpSession->WSPMS24ARESULT,{} ) // Posicao 1 Reservado para campos do aHeader
	For nA := 1 To Len( oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS )
		If oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERFOLDER == cFolder1
			AAdd(HttpSession->WSPMS24ARESULT[1],{	oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERCOMBOBOX ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:nHEADERDEC      ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERF3       ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERFIELD    ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:lHEADEROBLIG    ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERPICTURE  ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:nHEADERSIZE     ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERTITLE    ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERTYPE     ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERFOLDER   ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERORDER    ,;		
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cEDITABLE       ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cPROPRIETYNAME  })
		Endif
	Next nA

	If oObj:GetWbsDetail()
	
		AAdd(HttpSession->WSPMS24ARESULT, {} )
		HttpSession->WSPMS24ARESULT[2] := { oObj:oWSGETWBSDETAILRESULT:oWSWBSDETAILVIEW }
		
		cHtml += ExecInPage( "PWSP024A" )
		
	Else
		HttpSession->cLinkErro	:= ""
		HttpSession->cBotaoErro	:= ""
		HttpSession->cErro		:= StrGantt( GetWscError() )
		cHtml							:= ExecInPage( "PWSP001" )
	Endif
Else
	HttpSession->cLinkErro	:= ""
	HttpSession->cBotaoErro	:= ""
	HttpSession->cErro		:= StrGantt( GetWscError() )
	cHtml							:= ExecInPage( "PWSP001" )
Endif

WEB EXTENDED END

Return cHtml 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP024B  ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Lista de Tarefas de uma EDT, detalhes, iFrame de baixo     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP024B()

Local cHtml 	:= ""
Local nA			:= 0
Local cPrjCod	:= HttpGet->cProjectCode
Local cWbsCod	:= HttpGet->cWbsCode
Local cFolder1	:= HttpGet->cFolder1
Local cFolder2	:= HttpGet->cFolder2
Local oObj

WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSPROJECTS' ), WSPMSPROJECTS():New() )
WsChgURL( @oObj, "PMSPROJECTS.APW" )

oObj:cUSERCODE				:= GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
oObj:cPROJECTCODE			:= cPrjCod
oObj:cWBSFather			:= cWbsCod

HttpSession->cProjectCode	:= cPrjCod
HttpSession->cWbsCode		:= cWbsCod
HttpSession->cFolder1		:= cFolder1
HttpSession->cFolder2		:= cFolder2
           
oObj:cHeaderType := "TASKLISTVIEW"
If oObj:GetHeader()
	HttpSession->WSPMS24BRESULT := {}
	
	AAdd(HttpSession->WSPMS24BRESULT,{} ) // Posicao 1 Reservado para campos do aHeader
	For nA := 1 To Len( oObj:oWSGETHEADERRESULT:oWSBRWHEADER )
		AAdd(HttpSession->WSPMS24BRESULT[1],{	oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERCOMBOBOX ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:nHEADERDEC      ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERF3       ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERFIELD    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:lHEADEROBLIG    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERPICTURE  ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:nHEADERSIZE     ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERTITLE    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERTYPE     })
	Next nA

	If oObj:GetTaskList()
	
		For nA := 1 To Len(oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW)
			Aadd( HttpSession->WSPMS24BRESULT, {	oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cTask                	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cLevel               	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cDescription         	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cMU                  	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nQuantity            	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nTimeDuration 			,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cCalendar     			,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:dEstimatedInitialDate	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:dEstimatedFinalDate		,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cEstimatedInitialHour	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cEstimatedFinalHour		,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cMeasurementMethod		,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nUsefulHours				,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:dExecutionInitialDate	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:dExecutionFinalDate		,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cCostCenter				,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cAccountingItem			,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cValueClass				,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cInvoiced					,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nCurrentValue1			,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nCurrentValue2			,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nCurrentValue3			,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nCurrentValue4			,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nCurrentValue5			,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nFinalValue1				,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nFinalValue2				,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nFinalValue3				,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nFinalValue4				,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nFinalValue5				,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nInitialValue1			,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nInitialValue2			,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nInitialValue3			,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nInitialValue4			,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nInitialValue5			,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cMainWBS					,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nExpenseValue1			,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nExpenseValue2			,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nExpenseValue3			,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nExpenseValue4			,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nExpenseValue5			,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cCompositionCode			,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cCurrencyConversion 	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cSendEMail           	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cGroup               	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nPriority            	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:dConversionDate      	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nCurrencyCost1       	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nCurrencyCost2       	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nCurrencyCost3       	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nCurrencyCost4       	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nCurrencyCost5       	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cStructureOrder      	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cRestriction         	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:dRestrictDate        	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cRestrictTime        	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nCurrencyRate2       	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nCurrencyRate3       	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nCurrencyRate4       	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nCurrencyRate5       	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nMarkupPercent       	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nMarkupValue         	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:nGrandTotal          	,;
																oObj:oWSGETTASKLISTRESULT:oWSTASKLISTVIEW[nA]:cInvoiceProductCode  	})
		Next nA
		
		cHtml += ExecInPage( "PWSP024B" )
		
	Else
		HttpSession->cLinkErro	:= ""
		HttpSession->cBotaoErro	:= ""
		HttpSession->cErro		:= StrGantt( GetWscError() )
		cHtml							:= ExecInPage( "PWSP001" )
	Endif
Else
	HttpSession->cLinkErro	:= ""
	HttpSession->cBotaoErro	:= ""
	HttpSession->cErro		:= StrGantt( GetWscError() )
	cHtml							:= ExecInPage( "PWSP001" )
Endif

WEB EXTENDED END
Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP024C  ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Lista de Eventos de uma EDT, detalhes, iFrame de baixo     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP024C()

Local cHtml 	:= ""
Local nA			:= 0
Local cPrjCod	:= HttpGet->cProjectCode
Local cWbsCod	:= HttpGet->cWbsCode
Local cFolder1	:= HttpGet->cFolder1
Local cFolder2	:= HttpGet->cFolder2
Local oObj

WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSPROJECTS' ), WSPMSPROJECTS():New() )
WsChgURL( @oObj, "PMSPROJECTS.APW" )

oObj:cUSERCODE				:= GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
oObj:cPROJECTCODE			:= cPrjCod
oObj:cWbsTaskCode			:= cWbsCod
oObj:cWbsOrTask			:= "1" // EDT

HttpSession->cProjectCode	:= cPrjCod
HttpSession->cWbsCode		:= cWbsCod
HttpSession->cFolder1		:= cFolder1
HttpSession->cFolder2		:= cFolder2
           
oObj:cHeaderType := "EVENTLISTVIEW"
If oObj:GetHeader()
	HttpSession->WSPMS24CRESULT := {}
	
	AAdd(HttpSession->WSPMS24CRESULT,{} ) // Posicao 1 Reservado para campos do aHeader
	For nA := 1 To Len( oObj:oWSGETHEADERRESULT:oWSBRWHEADER )
		AAdd(HttpSession->WSPMS24CRESULT[1],{	oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERCOMBOBOX ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:nHEADERDEC      ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERF3       ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERFIELD    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:lHEADEROBLIG    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERPICTURE  ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:nHEADERSIZE     ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERTITLE    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERTYPE     })
	Next nA

	If oObj:GetEventList()
	
		For nA := 1 To Len(oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW)
			Aadd( HttpSession->WSPMS24CRESULT, {	oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cTaskCode 					,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cItem 						,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cUsageCode 					,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cEventDescription	 		,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:dEventEstimatedDate 		,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:dEstimatedDate 			,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:dEventExecutionDate 		,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:nPercentageExecuted 		,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cSendEmail 					,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cExecuteUserFunction 	,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cWbsCode 					,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cCustomerCode 				,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cCustomerBranch 			,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:nBillValue 					,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:nBillCurrency 				,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cGenerateTemporaryBill	,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cGenerateBillReceivable	,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cPaymentTerm 				,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cBillNumber 				,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cBillPrefix 				,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cClassCode 					,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cSalesOrderNumber 		,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cSalesOrderNumberItem 	,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:nSalesOrderRelease 		})
		Next nA
		
		cHtml += ExecInPage( "PWSP024C" )
		
	Else
		HttpSession->cLinkErro	:= ""
		HttpSession->cBotaoErro	:= ""
		HttpSession->cErro		:= StrGantt( GetWscError() )
		cHtml							:= ExecInPage( "PWSP001" )
	Endif
Else
	HttpSession->cLinkErro	:= ""
	HttpSession->cBotaoErro	:= ""
	HttpSession->cErro		:= StrGantt( GetWscError() )
	cHtml							:= ExecInPage( "PWSP001" )
Endif

WEB EXTENDED END
Return cHtml 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP025   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostra detalhes de uma Tarefa						      		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP025()

Local cHtml 	:= ""
Local cPrjCod	:= HttpGet->cProjectCode
Local cTaskCod	:= HttpGet->cTaskCode
Local cFolder1	:= HttpGet->cFolder1
Local cFolder2	:= HttpGet->cFolder2

WEB EXTENDED INIT cHtml

	HttpSession->cProjectCode	:= cPrjCod
	HttpSession->cTaskCode		:= cTaskCod
	HttpSession->cFolder1		:= cFolder1
	HttpSession->cFolder2		:= cFolder2
	
	If HttpGet->cBotao == "1" .OR. HttpGet->cBotao == "2"
		cHtml += ExecInPage( "PWSP025HIDE" )
	Else
		cHtml += ExecInPage( "PWSP025" )
	Endif

WEB EXTENDED END

Return cHtml 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP025   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PWSP025FRAME - Mecanismo de troca de informacoes no iFrame º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP25FRAME()

Local cHtml 	:= ""
Local cPrjCod	:= HttpGet->cProjectCode
Local cTaskCod	:= HttpGet->cTaskCode
Local cFolder1	:= HttpGet->cFolder1
Local cFolder2	:= HttpGet->cFolder2

WEB EXTENDED INIT cHtml

	HttpSession->cProjectCode	:= cPrjCod
	HttpSession->cTaskCode		:= cTaskCod
	HttpSession->cFolder1		:= cFolder1
	HttpSession->cFolder2		:= cFolder2

	cHtml += ExecInPage( "PWSP25FRAME" )

WEB EXTENDED END

Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP025A  ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostra detalhes de uma Tarefa. 									  º±±
±±º          ³ Cpos da AFC no iFrame superior.									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP025A()

Local cHtml 	:= ""
Local nA			:= 0
Local cPrjCod	:= HttpGet->cProjectCode
Local cTaskCod	:= HttpGet->cTaskCode
Local cFolder1	:= HttpGet->cFolder1
Local cFolder2	:= HttpGet->cFolder2
Local oObj

WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSPROJECTS' ), WSPMSPROJECTS():New() )
WsChgURL( @oObj, "PMSPROJECTS.APW" )

oObj:cUSERCODE				:= GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
oObj:cPROJECTCODE			:= cPrjCod
oObj:cTaskCode				:= cTaskCod

HttpSession->cProjectCode	:= cPrjCod
HttpSession->cTaskCode		:= cTaskCod
HttpSession->cFolder1		:= cFolder1
HttpSession->cFolder2		:= cFolder2

oObj:cHeaderType := "TASKDETAILVIEW"
If oObj:GetHeaderPms()
	HttpSession->WSPMS25ARESULT := {}

	AAdd(HttpSession->WSPMS25ARESULT,{} ) // Posicao 1 Reservado para campos do aHeader
	For nA := 1 To Len( oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS )
		If oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERFOLDER == cFolder1
			AAdd(HttpSession->WSPMS25ARESULT[1],{	oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERCOMBOBOX ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:nHEADERDEC      ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERF3       ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERFIELD    ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:lHEADEROBLIG    ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERPICTURE  ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:nHEADERSIZE     ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERTITLE    ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERTYPE     ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERFOLDER   ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERORDER    ,;		
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cEDITABLE       ,;
																oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cPROPRIETYNAME  })
		Endif
	Next nA

	If oObj:GetTaskDetail()
	
		AAdd(HttpSession->WSPMS25ARESULT, {} )
		HttpSession->WSPMS25ARESULT[2] := { oObj:oWSGETTASKDETAILRESULT:oWSTASKDETAILVIEW }
		
		cHtml += ExecInPage( "PWSP025A" )
		
	Else
		HttpSession->cLinkErro	:= ""
		HttpSession->cBotaoErro	:= ""
		HttpSession->cErro		:= StrGantt( GetWscError() )
		cHtml							:= ExecInPage( "PWSP001" )
	Endif
Else
	HttpSession->cLinkErro	:= ""
	HttpSession->cBotaoErro	:= ""
	HttpSession->cErro		:= StrGantt( GetWscError() )
	cHtml							:= ExecInPage( "PWSP001" )
Endif

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP025B  ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Lista de Produtos de uma Tarefa.									  º±±
±±º          ³ Detalhes, iFrame de baixo.    									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP025B()

Local cHtml 	:= ""
Local nA			:= 0
Local cPrjCod	:= HttpGet->cProjectCode
Local cTaskCod	:= HttpGet->cTaskCode
Local cFolder1	:= HttpGet->cFolder1
Local cFolder2	:= HttpGet->cFolder2
Local oObj

WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSPROJECTS' ), WSPMSPROJECTS():New() )
WsChgURL( @oObj, "PMSPROJECTS.APW" )

oObj:cUSERCODE				:= GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
oObj:cPROJECTCODE			:= cPrjCod
oObj:cTaskCode				:= cTaskCod

HttpSession->cProjectCode	:= cPrjCod
HttpSession->cTaskCode		:= cTaskCod
HttpSession->cFolder1		:= cFolder1
HttpSession->cFolder2		:= cFolder2
           
oObj:cHeaderType := "TASKPRODUCTSVIEW"
If oObj:GetHeader()
	HttpSession->WSPMS25BRESULT := {}
	
	AAdd(HttpSession->WSPMS25BRESULT,{} ) // Posicao 1 Reservado para campos do aHeader
	For nA := 1 To Len( oObj:oWSGETHEADERRESULT:oWSBRWHEADER )
		AAdd(HttpSession->WSPMS25BRESULT[1],{	oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERCOMBOBOX ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:nHEADERDEC      ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERF3       ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERFIELD    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:lHEADEROBLIG    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERPICTURE  ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:nHEADERSIZE     ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERTITLE    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERTYPE     })
	Next nA

	If oObj:GetTaskProductsList()
	
		For nA := 1 To Len(oObj:oWSGETTASKPRODUCTSLISTRESULT:oWSTASKPRODUCTSVIEW)
			Aadd( HttpSession->WSPMS25BRESULT, {	oObj:oWSGETTASKPRODUCTSLISTRESULT:oWSTASKPRODUCTSVIEW[nA]:cITEM                     ,;
																oObj:oWSGETTASKPRODUCTSLISTRESULT:oWSTASKPRODUCTSVIEW[nA]:cPRODUCTCODE              ,;
																oObj:oWSGETTASKPRODUCTSLISTRESULT:oWSTASKPRODUCTSVIEW[nA]:cPRODUCTTYPE              ,;
																oObj:oWSGETTASKPRODUCTSLISTRESULT:oWSTASKPRODUCTSVIEW[nA]:cDESCRIPTION              ,;
																oObj:oWSGETTASKPRODUCTSLISTRESULT:oWSTASKPRODUCTSVIEW[nA]:cUNIT                     ,;
																oObj:oWSGETTASKPRODUCTSLISTRESULT:oWSTASKPRODUCTSVIEW[nA]:cUNIT2                    ,;
																oObj:oWSGETTASKPRODUCTSLISTRESULT:oWSTASKPRODUCTSVIEW[nA]:nQUANTITY                 ,;
																oObj:oWSGETTASKPRODUCTSLISTRESULT:oWSTASKPRODUCTSVIEW[nA]:nQUANTITY2                ,;
																oObj:oWSGETTASKPRODUCTSLISTRESULT:oWSTASKPRODUCTSVIEW[nA]:nCURRENCY                 ,;
																oObj:oWSGETTASKPRODUCTSLISTRESULT:oWSTASKPRODUCTSVIEW[nA]:cCURRENCYSYMBOL           ,;
																oObj:oWSGETTASKPRODUCTSLISTRESULT:oWSTASKPRODUCTSVIEW[nA]:nSTANDARDCOST             ,;
																oObj:oWSGETTASKPRODUCTSLISTRESULT:oWSTASKPRODUCTSVIEW[nA]:dNECESSITYDATE            ,;
																oObj:oWSGETTASKPRODUCTSLISTRESULT:oWSTASKPRODUCTSVIEW[nA]:cCOSTCALCULATIONMETHOD    ,;
																oObj:oWSGETTASKPRODUCTSLISTRESULT:oWSTASKPRODUCTSVIEW[nA]:cSUBCOMPOSTIONCODE        ,;
																oObj:oWSGETTASKPRODUCTSLISTRESULT:oWSTASKPRODUCTSVIEW[nA]:cPLANNINGCODE             ,;
																oObj:oWSGETTASKPRODUCTSLISTRESULT:oWSTASKPRODUCTSVIEW[nA]:cRECALCULATECOSTS         ,;
																oObj:oWSGETTASKPRODUCTSLISTRESULT:oWSTASKPRODUCTSVIEW[nA]:cINVOICEPRODUCTCODE       })


		Next nA
		
		cHtml += ExecInPage( "PWSP025B" )
		
	Else
		HttpSession->cLinkErro	:= ""
		HttpSession->cBotaoErro	:= ""
		HttpSession->cErro	:= StrGantt( GetWscError() )
		cHtml						:= ExecInPage( "PWSP001" )
	Endif
Else
	HttpSession->cLinkErro	:= ""
	HttpSession->cBotaoErro	:= ""
	HttpSession->cErro		:= StrGantt( GetWscError() )
	cHtml							:= ExecInPage( "PWSP001" )
Endif

WEB EXTENDED END
Return cHtml 
             

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP025C  ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Lista de Despesas de uma Tarefa.									  º±±
±±º          ³ Detalhes, iFrame de baixo.    									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP025C()

Local cHtml 	:= ""
Local nA			:= 0
Local cPrjCod	:= HttpGet->cProjectCode
Local cTaskCod	:= HttpGet->cTaskCode
Local cFolder1	:= HttpGet->cFolder1
Local cFolder2	:= HttpGet->cFolder2
Local oObj

WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSPROJECTS' ), WSPMSPROJECTS():New() )
WsChgURL( @oObj, "PMSPROJECTS.APW" )

oObj:cUSERCODE				:= GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
oObj:cPROJECTCODE			:= cPrjCod
oObj:cTaskCode				:= cTaskCod

HttpSession->cProjectCode	:= cPrjCod
HttpSession->cTaskCode		:= cTaskCod
HttpSession->cFolder1		:= cFolder1
HttpSession->cFolder2		:= cFolder2
           
oObj:cHeaderType := "EXPENSELISTVIEW"
If oObj:GetHeader()
	HttpSession->WSPMS25CRESULT := {}
	
	AAdd(HttpSession->WSPMS25CRESULT,{} ) // Posicao 1 Reservado para campos do aHeader
	For nA := 1 To Len( oObj:oWSGETHEADERRESULT:oWSBRWHEADER )
		AAdd(HttpSession->WSPMS25CRESULT[1],{	oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERCOMBOBOX ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:nHEADERDEC      ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERF3       ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERFIELD    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:lHEADEROBLIG    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERPICTURE  ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:nHEADERSIZE     ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERTITLE    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERTYPE     })
	Next nA

	If oObj:GetExpenseList()
	
		For nA := 1 To Len(oObj:oWSGETEXPENSELISTRESULT:oWSEXPENSELISTVIEW)
			Aadd( HttpSession->WSPMS25CRESULT, {	oObj:oWSGETEXPENSELISTRESULT:oWSEXPENSELISTVIEW[nA]:cITEM                     ,;
																oObj:oWSGETEXPENSELISTRESULT:oWSEXPENSELISTVIEW[nA]:cEXPENSESTYPE             ,;
																oObj:oWSGETEXPENSELISTRESULT:oWSEXPENSELISTVIEW[nA]:cDESCRIPTION              ,;
																oObj:oWSGETEXPENSELISTRESULT:oWSEXPENSELISTVIEW[nA]:cTASKCODE                 ,;
																oObj:oWSGETEXPENSELISTRESULT:oWSEXPENSELISTVIEW[nA]:nCURRENCY                 ,;
																oObj:oWSGETEXPENSELISTRESULT:oWSEXPENSELISTVIEW[nA]:cCURRENCYSYMBOL           ,;
																oObj:oWSGETEXPENSELISTRESULT:oWSEXPENSELISTVIEW[nA]:nEXPENSESAMOUNT           ,;
																oObj:oWSGETEXPENSELISTRESULT:oWSEXPENSELISTVIEW[nA]:cPROJECTCODE              ,;
																oObj:oWSGETEXPENSELISTRESULT:oWSEXPENSELISTVIEW[nA]:cPROJECTVERSION           ,;
																oObj:oWSGETEXPENSELISTRESULT:oWSEXPENSELISTVIEW[nA]:cACCUMULATECOSTS          ,;
																oObj:oWSGETEXPENSELISTRESULT:oWSEXPENSELISTVIEW[nA]:dNECESSITYDATE            ,;
																oObj:oWSGETEXPENSELISTRESULT:oWSEXPENSELISTVIEW[nA]:cRESOURCECODE             ,;
																oObj:oWSGETEXPENSELISTRESULT:oWSEXPENSELISTVIEW[nA]:nALLOCATEDPERCENTAGE      ,;
																oObj:oWSGETEXPENSELISTRESULT:oWSEXPENSELISTVIEW[nA]:dINITIALALLOCATIONDATE    ,;
																oObj:oWSGETEXPENSELISTRESULT:oWSEXPENSELISTVIEW[nA]:cALLOCATIONINITIALHOUR    ,;
																oObj:oWSGETEXPENSELISTRESULT:oWSEXPENSELISTVIEW[nA]:dFINALALLOCATIONDATE      ,;		
																oObj:oWSGETEXPENSELISTRESULT:oWSEXPENSELISTVIEW[nA]:cALLOCATIONFINALHOUR      ,;
																oObj:oWSGETEXPENSELISTRESULT:oWSEXPENSELISTVIEW[nA]:cSUBCOMPOSITIONCODE       ,;
																oObj:oWSGETEXPENSELISTRESULT:oWSEXPENSELISTVIEW[nA]:cINVOICEPRODUCTCODE       })
		Next nA
		
		cHtml += ExecInPage( "PWSP025C" )
		
	Else
		HttpSession->cLinkErro	:= ""
		HttpSession->cBotaoErro	:= ""
		HttpSession->cErro		:= StrGantt( GetWscError() )
		cHtml							:= ExecInPage( "PWSP001" )
	Endif
Else
	HttpSession->cLinkErro	:= ""
	HttpSession->cBotaoErro	:= ""
	HttpSession->cErro		:= StrGantt( GetWscError() )
	cHtml							:= ExecInPage( "PWSP001" )
Endif

WEB EXTENDED END
Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP025D  ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Lista de Relacionamento entras as Tarefas.					  º±±
±±º          ³ Detalhes, iFrame de baixo.    									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP025D()

Local cHtml 	:= ""
Local nA			:= 0
Local cPrjCod	:= HttpGet->cProjectCode
Local cTaskCod	:= HttpGet->cTaskCode
Local cFolder1	:= HttpGet->cFolder1
Local cFolder2	:= HttpGet->cFolder2
Local oObj

WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSPROJECTS' ), WSPMSPROJECTS():New() )
WsChgURL( @oObj, "PMSPROJECTS.APW" )

oObj:cUSERCODE				:= GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
oObj:cPROJECTCODE			:= cPrjCod
oObj:cTaskCode				:= cTaskCod

HttpSession->cProjectCode	:= cPrjCod
HttpSession->cTaskCode		:= cTaskCod
HttpSession->cFolder1		:= cFolder1
HttpSession->cFolder2		:= cFolder2
           
oObj:cHeaderType := "RELATIONSHIPLISTVIEW"
If oObj:GetHeader()
	HttpSession->WSPMS25DRESULT := {}
	
	AAdd(HttpSession->WSPMS25DRESULT,{} ) // Posicao 1 Reservado para campos do aHeader
	For nA := 1 To Len( oObj:oWSGETHEADERRESULT:oWSBRWHEADER )
		AAdd(HttpSession->WSPMS25DRESULT[1],{	oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERCOMBOBOX ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:nHEADERDEC      ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERF3       ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERFIELD    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:lHEADEROBLIG    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERPICTURE  ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:nHEADERSIZE     ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERTITLE    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERTYPE     })
	Next nA

	If oObj:GetRelationShipList()
	
		For nA := 1 To Len(oObj:oWSGETRELATIONSHIPLISTRESULT:oWSRELATIONSHIPLISTVIEW)
			Aadd( HttpSession->WSPMS25DRESULT, {	oObj:oWSGETRELATIONSHIPLISTRESULT:oWSRELATIONSHIPLISTVIEW[nA]:cPREDECESSORITEM		,;
																oObj:oWSGETRELATIONSHIPLISTRESULT:oWSRELATIONSHIPLISTVIEW[nA]:cPREDECESSORTASKCODE	,;
																oObj:oWSGETRELATIONSHIPLISTRESULT:oWSRELATIONSHIPLISTVIEW[nA]:cTASKDESCRIPTION		,;
																oObj:oWSGETRELATIONSHIPLISTRESULT:oWSRELATIONSHIPLISTVIEW[nA]:cRELATIONSHIPTYPE		,;
																oObj:oWSGETRELATIONSHIPLISTRESULT:oWSRELATIONSHIPLISTVIEW[nA]:cPROJECTVERSION			,;
																oObj:oWSGETRELATIONSHIPLISTRESULT:oWSRELATIONSHIPLISTVIEW[nA]:nRELATIONSHIPDELAY		})
		Next nA
		
		cHtml += ExecInPage( "PWSP025D" )
		
	Else
		HttpSession->cLinkErro	:= ""
		HttpSession->cBotaoErro	:= ""
		HttpSession->cErro	:= StrGantt( GetWscError() )
		cHtml						:= ExecInPage( "PWSP001" )
	Endif
Else
	HttpSession->cLinkErro	:= ""
	HttpSession->cBotaoErro	:= ""
	HttpSession->cErro		:= StrGantt( GetWscError() )
	cHtml							:= ExecInPage( "PWSP001" )
Endif

WEB EXTENDED END
Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP025F  ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Lista de Alocacao dos Recursos para a Tarefa.				  º±±
±±º          ³ Detalhes, iFrame de baixo.    									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP025F()

Local cHtml 	:= ""
Local nA			:= 0
Local cPrjCod	:= HttpGet->cProjectCode
Local cTaskCod	:= HttpGet->cTaskCode
Local cFolder1	:= HttpGet->cFolder1
Local cFolder2	:= HttpGet->cFolder2
Local oObj

WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSPROJECTS' ), WSPMSPROJECTS():New() )
WsChgURL( @oObj, "PMSPROJECTS.APW" )

oObj:cUSERCODE				:= GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
oObj:cPROJECTCODE			:= cPrjCod
oObj:cTaskCode				:= cTaskCod

HttpSession->cProjectCode	:= cPrjCod
HttpSession->cTaskCode		:= cTaskCod
HttpSession->cFolder1		:= cFolder1
HttpSession->cFolder2		:= cFolder2
           
oObj:cHeaderType := "TASKALLOCATIONVIEW"
If oObj:GetHeader()
	HttpSession->WSPMS25FRESULT := {}
	
	AAdd(HttpSession->WSPMS25FRESULT,{} ) // Posicao 1 Reservado para campos do aHeader
	For nA := 1 To Len( oObj:oWSGETHEADERRESULT:oWSBRWHEADER )
		AAdd(HttpSession->WSPMS25FRESULT[1],{	oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERCOMBOBOX ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:nHEADERDEC      ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERF3       ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERFIELD    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:lHEADEROBLIG    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERPICTURE  ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:nHEADERSIZE     ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERTITLE    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERTYPE     })
	Next nA

	If oObj:GetTaskAllocationList()
	
		For nA := 1 To Len(oObj:oWSGETTASKALLOCATIONLISTRESULT:oWSTASKALLOCATIONVIEW)
			Aadd( HttpSession->WSPMS25FRESULT, {	oObj:oWSGETTASKALLOCATIONLISTRESULT:oWSTASKALLOCATIONVIEW[nA]:cITEM                     ,;			
																oObj:oWSGETTASKALLOCATIONLISTRESULT:oWSTASKALLOCATIONVIEW[nA]:cRESOURCECODE             ,;
																oObj:oWSGETTASKALLOCATIONLISTRESULT:oWSTASKALLOCATIONVIEW[nA]:nQUANTITY                 ,;
																oObj:oWSGETTASKALLOCATIONLISTRESULT:oWSTASKALLOCATIONVIEW[nA]:nALLOCATEDPERCENTAGE      ,;
																oObj:oWSGETTASKALLOCATIONLISTRESULT:oWSTASKALLOCATIONVIEW[nA]:cESTABLISH                ,;
																oObj:oWSGETTASKALLOCATIONLISTRESULT:oWSTASKALLOCATIONVIEW[nA]:cPRODUCTCODE              ,;
																oObj:oWSGETTASKALLOCATIONLISTRESULT:oWSTASKALLOCATIONVIEW[nA]:cDESCRIPTION              ,;
																oObj:oWSGETTASKALLOCATIONLISTRESULT:oWSTASKALLOCATIONVIEW[nA]:nCURRENCY                 ,;
																oObj:oWSGETTASKALLOCATIONLISTRESULT:oWSTASKALLOCATIONVIEW[nA]:cCURRENCYSYMBOL           ,;
																oObj:oWSGETTASKALLOCATIONLISTRESULT:oWSTASKALLOCATIONVIEW[nA]:nSTANDARDCOST             ,;
																oObj:oWSGETTASKALLOCATIONLISTRESULT:oWSTASKALLOCATIONVIEW[nA]:cUNIT                     ,;
																oObj:oWSGETTASKALLOCATIONLISTRESULT:oWSTASKALLOCATIONVIEW[nA]:cUNIT2                    ,;
																oObj:oWSGETTASKALLOCATIONLISTRESULT:oWSTASKALLOCATIONVIEW[nA]:nQUANTITY2                ,;
																oObj:oWSGETTASKALLOCATIONLISTRESULT:oWSTASKALLOCATIONVIEW[nA]:dNECESSITYDATE            ,;
																oObj:oWSGETTASKALLOCATIONLISTRESULT:oWSTASKALLOCATIONVIEW[nA]:cCOSTCALCULATIONMETHOD    ,;
																oObj:oWSGETTASKALLOCATIONLISTRESULT:oWSTASKALLOCATIONVIEW[nA]:cRECALCULATECOSTS         ,;
																oObj:oWSGETTASKALLOCATIONLISTRESULT:oWSTASKALLOCATIONVIEW[nA]:cINVOICEPRODUCTCODE       })
		Next nA
		
		cHtml += ExecInPage( "PWSP025F" )
		
	Else
		HttpSession->cLinkErro	:= ""
		HttpSession->cBotaoErro	:= ""
		HttpSession->cErro	:= StrGantt( GetWscError() )
		cHtml						:= ExecInPage( "PWSP001" )
	Endif
Else
	HttpSession->cLinkErro	:= ""
	HttpSession->cBotaoErro	:= ""
	HttpSession->cErro		:= StrGantt( GetWscError() )
	cHtml							:= ExecInPage( "PWSP001" )
Endif

WEB EXTENDED END
Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP025E  ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Lista de Eventos de uma Tarefa. 								     º±±
±±º          ³ Detalhes, iFrame de baixo.   										  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP025E()

Local cHtml 	:= ""
Local nA			:= 0
Local cPrjCod	:= HttpGet->cProjectCode
Local cTaskCod	:= HttpGet->cTaskCode
Local cFolder1	:= HttpGet->cFolder1
Local cFolder2	:= HttpGet->cFolder2
Local oObj

WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSPROJECTS' ), WSPMSPROJECTS():New() )
WsChgURL( @oObj, "PMSPROJECTS.APW" )

oObj:cUSERCODE				:= GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
oObj:cPROJECTCODE			:= cPrjCod
oObj:cWbsTaskCode			:= cTaskCod
oObj:cWbsOrTask			:= "2" // Tarefa

HttpSession->cProjectCode	:= cPrjCod
HttpSession->cTaskCode		:= cTaskCod
HttpSession->cFolder1		:= cFolder1
HttpSession->cFolder2		:= cFolder2
           
oObj:cHeaderType := "EVENTLISTVIEW"
If oObj:GetHeader()
	HttpSession->WSPMS25ERESULT := {}
	
	AAdd(HttpSession->WSPMS25ERESULT,{} ) // Posicao 1 Reservado para campos do aHeader
	For nA := 1 To Len( oObj:oWSGETHEADERRESULT:oWSBRWHEADER )
		AAdd(HttpSession->WSPMS25ERESULT[1],{	oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERCOMBOBOX ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:nHEADERDEC      ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERF3       ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERFIELD    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:lHEADEROBLIG    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERPICTURE  ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:nHEADERSIZE     ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERTITLE    ,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nA]:cHEADERTYPE     })
	Next nA

	If oObj:GetEventList()
	
		For nA := 1 To Len(oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW)
			Aadd( HttpSession->WSPMS25ERESULT, {	oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cTaskCode 					,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cItem 						,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cUsageCode 					,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cEventDescription	 		,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:dEventEstimatedDate 		,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:dEstimatedDate 			,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:dEventExecutionDate 		,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:nPercentageExecuted 		,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cSendEmail 					,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cExecuteUserFunction 	,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cWbsCode 					,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cCustomerCode 				,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cCustomerBranch 			,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:nBillValue 					,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:nBillCurrency 				,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cGenerateTemporaryBill	,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cGenerateBillReceivable	,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cPaymentTerm 				,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cBillNumber 				,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cBillPrefix 				,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cClassCode 					,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cSalesOrderNumber 		,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:cSalesOrderNumberItem 	,;
																oObj:oWSGETEVENTLISTRESULT:oWSEVENTLISTVIEW[nA]:nSalesOrderRelease 		})
		Next nA
		
		cHtml += ExecInPage( "PWSP025E" )
		
	Else
		HttpSession->cLinkErro	:= ""
		HttpSession->cBotaoErro	:= ""
		HttpSession->cErro		:= StrGantt( GetWscError() )
		cHtml							:= ExecInPage( "PWSP001" )
	Endif
Else
	HttpSession->cLinkErro	:= ""
	HttpSession->cBotaoErro	:= ""
	HttpSession->cErro		:= StrGantt( GetWscError() )
	cHtml							:= ExecInPage( "PWSP001" )
Endif

WEB EXTENDED END
Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±																		   						±±
±±                            FUNCOES AUXILIARES                           ±±
±±																		   						±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RstDelEdt ºAutor  ³Cristiano Denardi   º Data ³  09.08.05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Deleta Itens do array exibidos no HTML, passando a EDT Pai º±±
±±º          ³ os elementos de Sub-EDT's serao excluidos com recursividadeº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RstDelEdt( aStru, cWbsFather )

Local nX      	:= 0
Local aEdtPai 	:= {}
Local cCod		:= ""
Local lEDT		:= .F.

While .T.
	nPosDel	:= aScan( aStru, { |x| x[13] == cWbsFather } )
	If nPosDel > 0
		cCod  := aStru[nPosDel][1]
		lEDT  := Left(aStru[nPosDel][3],1) == "E"
		aDel( aStru, nPosDel )
		aSize( aStru, Len(aStru)-1	)
		If lEDT
			RstDelEdt( @aStru, cCod )
		Endif
	Else
		Exit
	Endif 
EndDo

Return

Function GetFilClients()

	Local oObjConfig := Nil
	Local nFilterClients := 0
	
	oObjConfig := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():New() )
	WsChgUrl(@oObjConfig, "CFGDICTIONARY.apw")

	If oObjConfig:GetParam(GtPtUsrCod()[1], "MV_PMSPCLI")
		nFilterClients := Val(oObjConfig:cGetParamResult)
	EndIf
Return nFilterClients

Function GetClients(cUserCode)

	Local oObj := Nil
	Local aClients := {}
	
	oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WsUserPortal' ), WsUserPortal():New() )
	WsChgUrl(@oObj, "USERPORTAL.apw")

	If oObj:PrtGetClientsByUser(cUserCode)
		aClients := oObj:oWSPrtGetClientsByUserResult:cString
	EndIf
Return aClients