#INCLUDE "APWEBEX.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGAWIN.CH"   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±																		  							±±
±±  MENU (Portal Projetos)										   						±±
±±	   ÀÄ> GERENCIAR PROJETOS											   				±±
±±						    ÀÄ> CONFIRMACOES 						   					±±
±±																		   						±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP040   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pagina inicial de item "Confirmacoes" do menu principal.   º±±
±±º          ³ Escopo do filtro                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP040()

Local cHtml := ""

WEB EXTENDED INIT cHtml

cHtml += ExecInPage( "PWSP040" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP041   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Resposta do filtro para confirmacoes.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP041()

Local cHtml 				:= ""
Local cTaskInitial		:= ""
Local cTaskFinal			:= ""
Local cProjectInitial	:= ""
Local cProjectFinal		:= ""
Local	cBsc					:= ""	
Local cOpc					:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta variaveis para chamada desta pagina     ³
//³ de diversos pontos do portal, sem a necessidade³
//³ de se passa-las via Form Metodo POST           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType( HttpPost->cTASKINITIAL		) == "U"
	cTaskInitial     	:= HttpSession->cTaskInitial
Else
	cTaskInitial	 	:= HttpPost->cTASKINITIAL
Endif
If ValType( HttpPost->cTASKFINAL			) == "U"
	cTaskFinal       	:= HttpSession->cTaskFinal
Else
	cTaskFinal			:= HttpPost->cTASKFINAL
Endif
If ValType( HttpPost->cPROJECTINITIAL	) == "U"
	cProjectInitial 	:= HttpSession->cProjectInitial
Else
	cProjectInitial	:= HttpPost->cPROJECTINITIAL
Endif
If ValType( HttpPost->cPROJECTFINAL		) == "U"
	cProjectFinal		:= HttpSession->cProjectFinal
Else
	cProjectFinal		:= HttpPost->cPROJECTFINAL
Endif  
If ValType( HttpPost->cBuscaAv		   ) == "U"
	HttpSession->cBuscaAv	:= ""  
	HttpSession->cBuscaOpc	:= ""
	cBsc 							:= ""	
	cOpc							:= ""
Else
	cBsc							:= HttpPost->cBuscaAv
	cOpc							:= HttpPost->cComboAv
	HttpSession->cBuscaAv	:= cBsc
	HttpSession->cBuscaOpc	:= cOpc
Endif


WEB EXTENDED INIT cHtml

HttpSession->cTaskInitial 		:= cTaskInitial
HttpSession->cTaskFinal   		:= cTaskFinal
HttpSession->cProjectInitial	:= cProjectInitial
HttpSession->cProjectFinal		:= cProjectFinal

cHtml += ExecInPage( "PWSP041" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP041A  ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Resposta do filtro para confirmacoes. (apresenta no iFrame)º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP041A()

Local cHtml := ""
Local cBsc	:= ""
Local aBsc	:= {}
Local lBsc	:= .F.
Local cOpc	:= ""
Local lNext	:= .T.
Local oObj
Local nX
Local cTaskInitial, cTaskFinal, cProjectInitial, cProjectFinal


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta variaveis para chamada desta pagina     ³
//³ de diversos pontos do portal, sem a necessidade³
//³ de se passa-las via Form Metodo POST           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType( HttpPost->cTASKINITIAL		) == "U"
	cTaskInitial      := HttpSession->cTaskInitial
Else
	cTaskInitial		:= HttpPost->cTASKINITIAL
Endif
If ValType( HttpPost->cTASKFINAL			) == "U"
	cTaskFinal        := HttpSession->cTaskFinal
Else
	cTaskFinal			:= HttpPost->cTASKFINAL
Endif
If ValType( HttpPost->cPROJECTINITIAL	) == "U"
	cProjectInitial 	:= HttpSession->cProjectInitial
Else
	cProjectInitial	:= HttpPost->cPROJECTINITIAL
Endif
If ValType( HttpPost->cPROJECTFINAL		) == "U"
	cProjectFinal		:= HttpSession->cProjectFinal
Else
	cProjectFinal		:= HttpPost->cPROJECTFINAL
Endif                           

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica variaveis da Busca Avancada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( HttpSession->cBuscaAv )
	lBsc							:= .F.
	HttpSession->cBuscaAv	:= ""
	HttpSession->cBuscaOpc	:= ""
	cBsc 							:= ""	
	cOpc							:= ""
Else
	lBsc							:= .T.
	cBsc							:= HttpSession->cBuscaAv
	cOpc							:= HttpSession->cBuscaOpc
	HttpSession->cBuscaAv	:= cBsc
	HttpSession->cBuscaOpc	:= cOpc
Endif                             


WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSCONFIRMATIONS' ), WSPMSCONFIRMATIONS():New() )
WsChgURL( @oObj, "PMSCONFIRMATIONS.APW" )

oObj:cUSERCODE				:= GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
oObj:cTaskInitial			:= cTaskInitial
oObj:cTaskFinal			:= cTaskFinal
oObj:cPROJECTINITIAL		:= cProjectInitial
oObj:cPROJECTFINAL		:= cProjectFinal

HttpSession->cTaskInitial 		:= cTaskInitial
HttpSession->cTaskFinal   		:= cTaskFinal
HttpSession->cProjectInitial	:= cProjectInitial
HttpSession->cProjectFinal		:= cProjectFinal

If oObj:GetConfirmationsList()  

	HttpSession->WSPMS40RESULT := {}
	
	If lBsc .And. !Empty(cBsc) // Dados Enviados pelo Form de Busca Avancada
		aBsc := aIntStrFil( cBsc )
	Endif
	For nX := 1 To Len(oObj:oWSGETCONFIRMATIONSLISTRESULT:oWSCONFIRMATIONSLISTVIEW)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ .: BUSCA AVANCADA :. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lBsc .And. !Empty(cBsc) // Dados Enviados pelo Form de Busca Avancada
			lNext := BscAvanWeb( cOpc, aBsc, {	oObj:oWSGETCONFIRMATIONSLISTRESULT:oWSCONFIRMATIONSLISTVIEW[nX]:cPROJECTCODE				,;
															oObj:oWSGETCONFIRMATIONSLISTRESULT:oWSCONFIRMATIONSLISTVIEW[nX]:cTASKCODE					,;
															Dtoc(oObj:oWSGETCONFIRMATIONSLISTRESULT:oWSCONFIRMATIONSLISTVIEW[nX]:dREFERENCEDATE)	})
		Endif
		If lNext
			AAdd(HttpSession->WSPMS40RESULT,{	oObj:oWSGETCONFIRMATIONSLISTRESULT:oWSCONFIRMATIONSLISTVIEW[nX]:cProjectCode					,;
															oObj:oWSGETCONFIRMATIONSLISTRESULT:oWSCONFIRMATIONSLISTVIEW[nX]:cTaskCode						,;
															oObj:oWSGETCONFIRMATIONSLISTRESULT:oWSCONFIRMATIONSLISTVIEW[nX]:dReferenceDate				,;
															oObj:oWSGETCONFIRMATIONSLISTRESULT:oWSCONFIRMATIONSLISTVIEW[nX]:nQuantityExecuted			,;
															oObj:oWSGETCONFIRMATIONSLISTRESULT:oWSCONFIRMATIONSLISTVIEW[nX]:nPercentageExecuted			,;
															oObj:oWSGETCONFIRMATIONSLISTRESULT:oWSCONFIRMATIONSLISTVIEW[nX]:cOcorrenceCode				,;
															oObj:oWSGETCONFIRMATIONSLISTRESULT:oWSCONFIRMATIONSLISTVIEW[nX]:cOcorrenceDescription		,;
															oObj:oWSGETCONFIRMATIONSLISTRESULT:oWSCONFIRMATIONSLISTVIEW[nX]:cDeliveryAuthorization		,;
															oObj:oWSGETCONFIRMATIONSLISTRESULT:oWSCONFIRMATIONSLISTVIEW[nX]:cDeliveryComboBoxText		,;
															oObj:oWSGETCONFIRMATIONSLISTRESULT:oWSCONFIRMATIONSLISTVIEW[nX]:nDbRecord						})
																
		Endif
	Next nX
	cHtml += ExecInPage( "PWSP041A" )
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
±±ºPrograma  ³PWSP042   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pagina p/ Inclusao-Exclusao-Visualizacao-Edicao dos        º±±
±±º          ³ confirmacoes de uma tarefa.								        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP042()

Local cHtml  := ""
Local nA     := 0
Local nZ     := 0
Local cRecord:= HttpGet->cChave
Local cOpc   := HttpGet->cOpc
Local aF3Web	:= Nil
Local	cParamAdicF3  :=	""
Local	cSizeWndF3		:= ""		

WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSCONFIRMATIONS' ), WSPMSCONFIRMATIONS():New() )
WsChgURL( @oObj, "PMSCONFIRMATIONS.APW" )

oObj:cUSERCODE         := GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE := GtPtUsrCod()[2]
oObj:nOPERATIONNUMBER  := Val(cOpc)
HttpSession->cOpc   := cOpc
HttpSession->cChave := cRecord

oObj:cHeaderType := "CONFIRMATIONVIEW"
If oObj:GetHeaderPms()
	HttpSession->WSPMS42RESULT := {}

	AAdd(HttpSession->WSPMS42RESULT,{} ) // Posicao 1 Reservado para campos do aHeader
	For nA := 1 To Len( oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS )
		aF3Web			:=	Nil       
		cParamAdicF3  :=	""
		cSizeWndF3		:= ""		
		Do Case 
			Case Alltrim(oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERF3) == "AF8"
				aF3Web	:=	{{'GETPROJECT',;
									{'AFF_PROJET','CPROJECTCODE'    },;
									 {'AFF_REVISA','CPROJECTREVISION'};
									},;
									{'CPROJECTCODE','CDESCRIPTION'}}
			Case Alltrim(oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERF3) == "AF9"
				aF3Web	:=	{{'GETTASK',;
									{'AFF_TAREFA','CTASKCODE'    },;
									{'AFF_DESCRI','CTASKDESCRIPTION'},;
									{'AF9_QUANT' ,'NQUANTITY'};
									},;
									{'CTASKCODE','CTASKDESCRIPTION','DESTIMATEDINITIALDATE','DESTIMATEDFINALDATE'}}
				cParamAdicF3	:=	"new Array('cPROJECTCODE','AFF_PROJET')"
				cSizeWndF3 		:=	'width=500,height=300'
			Case Alltrim(oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERF3) == "AE7"
				aF3Web	:=	{{'GETOCORRENCE',;
									{'AFF_OCORRE','COCORRENCECODE'    },;
									{'AFF_OCDESC','COCORRENCEDESCRIPTION'    };
									},;
									{'COCORRENCECODE','COCORRENCEDESCRIPTION'}}
		EndCase

		AAdd(HttpSession->WSPMS42RESULT[1],{	oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERCOMBOBOX ,;
															oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:nHEADERDEC      ,;
															{aF3Web,cParamAdic,cSizeWndF3}											,;
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
															oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cINITIALVALUE   })
	Next nA
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Indica que foi acessado pelo menu principal de Confirmacoes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	HttpSession->cPage22 := "0" 
      
	If cOpc == "3" // Incluir
		AAdd( HttpSession->WSPMS42RESULT, {	} )
		nA := Len( HttpSession->WSPMS42RESULT )
		For nZ := 1 To Len(HttpSession->WSPMS42RESULT[1])
			Do Case                                         
			Case	HttpSession->WSPMS42RESULT[1,nZ,9] == "D"	
				AAdd(HttpSession->WSPMS42RESULT[nA], Date())
			Case	HttpSession->WSPMS42RESULT[1,nZ,9] == "N"						
				AAdd(HttpSession->WSPMS42RESULT[nA], Str(0,HttpSession->WSPMS42RESULT[1,nZ,7],HttpSession->WSPMS42RESULT[1,nZ,2]))
			OtherWise
				AAdd(HttpSession->WSPMS42RESULT[nA], "")
			EndCase
		Next
		cHtml += ExecInPage( "PWSP042" )
	Else
		If cRecord <> Nil
			oObj:nDbRecord         := Val(cRecord)
		Endif
		If oObj:GetCONFIRMATIONByRecord()  
	
			AAdd( HttpSession->WSPMS42RESULT, {	} )
			nA := Len( HttpSession->WSPMS42RESULT )
			
//			oObj:oWSGETCONFIRMATIONRESULT:oWSCONFIRMATIONVIEW
						
			HttpSession->WSPMS42RESULT[nA] :=  {	oObj:oWSGETCONFIRMATIONBYRECORDRESULT:oWSCONFIRMATIONVIEW[1]:cProjectCode              	,;
																oObj:oWSGETCONFIRMATIONBYRECORDRESULT:oWSCONFIRMATIONVIEW[1]:cProjectVersion          	,;
																oObj:oWSGETCONFIRMATIONBYRECORDRESULT:oWSCONFIRMATIONVIEW[1]:cTaskCode                	,;
																oObj:oWSGETCONFIRMATIONBYRECORDRESULT:oWSCONFIRMATIONVIEW[1]:cTaskDescription         	,;
																oObj:oWSGETCONFIRMATIONBYRECORDRESULT:oWSCONFIRMATIONVIEW[1]:dReferenceDate           	,;
																oObj:oWSGETCONFIRMATIONBYRECORDRESULT:oWSCONFIRMATIONVIEW[1]:nQuantityExecuted        	,;
																oObj:oWSGETCONFIRMATIONBYRECORDRESULT:oWSCONFIRMATIONVIEW[1]:nPercentageExecuted      	,;
																oObj:oWSGETCONFIRMATIONBYRECORDRESULT:oWSCONFIRMATIONVIEW[1]:cOcorrenceCode          		,;
																oObj:oWSGETCONFIRMATIONBYRECORDRESULT:oWSCONFIRMATIONVIEW[1]:cOcorrenceDescription   		,;
																oObj:oWSGETCONFIRMATIONBYRECORDRESULT:oWSCONFIRMATIONVIEW[1]:cDeliveryAuthorization		,;
																oObj:oWSGETCONFIRMATIONBYRECORDRESULT:oWSCONFIRMATIONVIEW[1]:oWSNOTES							,;
																oObj:oWSGETCONFIRMATIONBYRECORDRESULT:oWSCONFIRMATIONVIEW[1]:cTaskQtdTot               	,;
																oObj:oWSGETCONFIRMATIONBYRECORDRESULT:oWSCONFIRMATIONVIEW[1]:nDbRecord							}
			cHtml += ExecInPage( "PWSP042" )
			
		Else
			HttpSession->cLinkErro  := ""
			HttpSession->cBotaoErro := ""
			HttpSession->nNewWin    := 1
			HttpSession->cErro      := StrGantt( GetWscError(3) )
			cHtml                   := ExecInPage( "PWSP001" )
		Endif
	Endif
Else
	HttpSession->cLinkErro  := ""
	HttpSession->cBotaoErro := ""
	HttpSession->nNewWin    := 1
	HttpSession->cErro		:=	StrGantt( GetWscError(3) )
	cHtml 						:= ExecInPage( "PWSP001" )
Endif

WEB EXTENDED END

Return cHtml                                   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP043   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pagina p/ Inclusao de COnfirmacao pela pag 22 de projetos  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP043()

Local cHtml     := ""
Local nA        := 0
Local aF3Web	:= Nil
Local	cParamAdicF3  :=	""
Local	cSizeWndF3		:= ""		
Local cEditable	:=	""


WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSCONFIRMATIONS' ), WSPMSCONFIRMATIONS():New() )
WsChgURL( @oObj, "PMSCONFIRMATIONS.APW" )

oObj:cUSERCODE         := GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE := GtPtUsrCod()[2]
oObj:nOPERATIONNUMBER  := 3

oObj:cHeaderType := "CONFIRMATIONVIEW"
If oObj:GetHeaderPms()
	HttpSession->WSPMS42RESULT := {}

	AAdd(HttpSession->WSPMS42RESULT,{} ) // Posicao 1 Reservado para campos do aHeader
	For nA := 1 To Len( oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS )
		aF3Web			:=	Nil       
		cParamAdicF3  :=	""
		cSizeWndF3		:= ""		
		Do Case 
			Case Alltrim(oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERF3) == "AF8"
				aF3Web	:=	{{'GETPROJECT',;
									{'AFF_PROJET','CPROJECTCODE'    },;
									 {'AFF_REVISA','CPROJECTREVISION'};
									},;
									{'CPROJECTCODE','CDESCRIPTION'}}
			Case Alltrim(oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERF3) == "AF9"
				aF3Web	:=	{{'GETTASK',;
									{'AFF_TAREFA','CTASKCODE'    },;
									{'AFF_DESCRI','CTASKDESCRIPTION'};
									},;
									{'CTASKCODE','CTASKDESCRIPTION','DESTIMATEDINITIALDATE','DESTIMATEDFINALDATE'}}
				cParamAdicF3	:=	"new Array('cPROJECTCODE','AFF_PROJET')"
				cSizeWndF3 		:=	'width=500,height=300'
			Case Alltrim(oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERF3) == "AE7"
				aF3Web	:=	{{'GETOCORRENCE',;
									{'AFF_OCORRE','COCORRENCECODE'    },;
									{'AFF_OCDESC','COCORRENCEDESCRIPTION'    };
									},;
									{'COCORRENCECODE','COCORRENCEDESCRIPTION'}}
		EndCase                
		If Alltrim(oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERFIELD) $ "AFF_PROJET/AFF_TAREFA/AFF_REVISA"
			cEditable	:=	"-1"
		Else
			cEditable	:=	oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cEDITABLE  		
		Endif	
		AAdd(HttpSession->WSPMS42RESULT[1],{	oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERCOMBOBOX ,;
												oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:nHEADERDEC      ,;
												{aF3Web,cParamAdic,cSizeWndF3}											,;
												oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERFIELD    ,;
												oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:lHEADEROBLIG    ,;
												oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERPICTURE  ,;
												oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:nHEADERSIZE     ,;
												oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERTITLE    ,;
												oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERTYPE     ,;
												oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERFOLDER   ,;
												oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cHEADERORDER    ,;
												cEDITABLE       ,;
												oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cPROPRIETYNAME  ,;
												oObj:oWSGETHEADERPMSRESULT:oWSBRWHEADERPMS[nA]:cINITIALVALUE   })
	Next nA
	oObj:cProjectCode := HttpGet->cProjectCode
	oObj:cTaskCode		:=	HttpGet->cTaskCode
	If oObj:GetCONFIRMATION()  
		AAdd( HttpSession->WSPMS42RESULT, {	} )
		nA := Len( HttpSession->WSPMS42RESULT )
			HttpSession->WSPMS42RESULT[nA] :=  {	oObj:oWSGETCONFIRMATIONRESULT:oWSCONFIRMATIONVIEW[1]:cProjectCode              	,;
																oObj:oWSGETCONFIRMATIONRESULT:oWSCONFIRMATIONVIEW[1]:cProjectVersion          	,;
																oObj:oWSGETCONFIRMATIONRESULT:oWSCONFIRMATIONVIEW[1]:cTaskCode                	,;
																oObj:oWSGETCONFIRMATIONRESULT:oWSCONFIRMATIONVIEW[1]:cTaskDescription         	,;
																oObj:oWSGETCONFIRMATIONRESULT:oWSCONFIRMATIONVIEW[1]:dReferenceDate           	,;
																oObj:oWSGETCONFIRMATIONRESULT:oWSCONFIRMATIONVIEW[1]:nQuantityExecuted        	,;
																oObj:oWSGETCONFIRMATIONRESULT:oWSCONFIRMATIONVIEW[1]:nPercentageExecuted      	,;
																oObj:oWSGETCONFIRMATIONRESULT:oWSCONFIRMATIONVIEW[1]:cOcorrenceCode          		,;
																oObj:oWSGETCONFIRMATIONRESULT:oWSCONFIRMATIONVIEW[1]:cOcorrenceDescription   		,;
																oObj:oWSGETCONFIRMATIONRESULT:oWSCONFIRMATIONVIEW[1]:cDeliveryAuthorization		,;
																oObj:oWSGETCONFIRMATIONRESULT:oWSCONFIRMATIONVIEW[1]:oWSNOTES							,;
																oObj:oWSGETCONFIRMATIONRESULT:oWSCONFIRMATIONVIEW[1]:cTaskQtdTot               	,;
																oObj:oWSGETCONFIRMATIONRESULT:oWSCONFIRMATIONVIEW[1]:nDbRecord							}
/*
			HttpSession->WSPMS42RESULT[nA]	:= {HttpGet->cProjectCode,cRev,HttpGet->cTaskCode,cTaskDesc,Date(), , , ,"","2","",cTaskQtd}
*/	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Indica que foi acessado pela pagina 22 de projetos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		HttpSession->cPage22	:= "1" 
		HttpSession->cOpc		:= "3"           
		HttpSession->cRefreshTask:=HttpGet->cTaskCode
		If oObj:oWSGETCONFIRMATIONRESULT:oWSCONFIRMATIONVIEW[1]:nDbRecord	 <> Nil
			
			cHtml	+=	'<script language="Javascript">'+CRLF
			cHtml	+=	'	alert("'+"Ja existe confirmacao para a data de hoje.\n A confirmacao sera aberta para edicao."+'");'+CRLF
			cHtml	+=	'</script>'+CRLF
			HttpSession->cOpc		:= "4"           

		Endif		
		cHtml += ExecInPage( "PWSP042" )
	Else
		HttpSession->cLinkErro	:= ""
		HttpSession->cBotaoErro	:= ""
		HttpSession->nNewWin	:= 1
		HttpSession->cErro		:=	StrGantt( GetWscError(3) )
		cHtml 					:= ExecInPage( "PWSP001" )
	Endif
	
Else
	HttpSession->cLinkErro	:= ""
	HttpSession->cBotaoErro	:= ""
	HttpSession->nNewWin	:= 1
	HttpSession->cErro		:=	StrGantt( GetWscError(3) )
	cHtml 					:= ExecInPage( "PWSP001" )
Endif

WEB EXTENDED END

Return cHtml 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSP044   ºAutor  ³Cristiano Denardi   º Data ³  08/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclui/Edita/Deleta Confirmacao							        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSP044()

Local cHtml		:= ""
Local aDados	:= {}
Local nOpc		:= Val(HttpGet->cOpc) 
Local aPost		:= HttpPost->aPost
Local nPos		:= 0

WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSCONFIRMATIONS' ), WSPMSCONFIRMATIONS():New() )
WsChgURL( @oObj, "PMSCONFIRMATIONS.APW" )

oObj:cUSERCODE				:= GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
//////////////////////////////////////////////////////
// Alimenta Dados para Gravacao pela Rotina Automatica
	oObj:nOperationNumber := nOpc

	////////////////
	// Dados do Form
	aDados := GetPost( aPost )              
	oObj:oWSCONFIRMATIONHANDLE := PMSCONFIRMATIONS_CONFIRMATIONVIEW():New()
		IF (nPos := aScan(aDados,{|x| x[1]="AFF_PROJET"})) > 0
			oObj:oWSCONFIRMATIONHANDLE:cProjectCode := aDados[nPos][2]
		Endif
		IF (nPos := aScan(aDados,{|x| x[1]="AFF_REVISA"})) > 0
			oObj:oWSCONFIRMATIONHANDLE:cProjectVersion := aDados[nPos][2]
		Endif
		IF (nPos := aScan(aDados,{|x| x[1]="AFF_TAREFA"})) > 0
			oObj:oWSCONFIRMATIONHANDLE:cTaskCode := aDados[nPos][2]
		Endif
		IF (nPos := aScan(aDados,{|x| x[1]="AFF_DATA"  })) > 0
			oObj:oWSCONFIRMATIONHANDLE:dReferenceDate := CtoD( aDados[nPos][2] )
		Endif
		IF (nPos := aScan(aDados,{|x| x[1]="AFF_QUANT" })) > 0
			oObj:oWSCONFIRMATIONHANDLE:nQuantityExecuted := Val( aDados[nPos][2] )
		Endif
		IF (nPos := aScan(aDados,{|x| x[1]="AFF_PERC" })) > 0
			oObj:oWSCONFIRMATIONHANDLE:nPercentageExecuted := Val( aDados[nPos][2] )
		Endif                          
		IF (nPos := aScan(aDados,{|x| x[1]="AFF_OCORRE"})) > 0
			oObj:oWSCONFIRMATIONHANDLE:cOcorrenceCode 		:= aDados[nPos][2]
		Endif
		IF (nPos := aScan(aDados,{|x| x[1]="AFF_OCDESC"})) > 0
			oObj:oWSCONFIRMATIONHANDLE:cOcorrenceDescription := aDados[nPos][2]
		Endif
		IF (nPos := aScan(aDados,{|x| x[1]="AFF_USER"   })) > 0
			oObj:oWSCONFIRMATIONHANDLE:cUserCode := aDados[nPos][2]
		Endif
		IF (nPos := aScan(aDados,{|x| x[1]="AFF_CONFIR" })) > 0
			oObj:oWSCONFIRMATIONHANDLE:cDeliveryAuthorization	:= aDados[nPos][2]
		Endif
		IF (nPos := aScan(aDados,{|x| x[1]="AFF_OBS"})) > 0
			oObj:oWSCONFIRMATIONHANDLE:cObs							:= aDados[nPos][2]
		Endif
		IF (nPos := aScan(aDados,{|x| x[1]="DBRECORD"})) > 0
			oObj:oWSCONFIRMATIONHANDLE:nDbRecord					:= Val(aDados[nPos][2])
		Endif
		
If oObj:CONFIRMATIONHandle()

	HttpSession->WSPMS42XRESULT := { oObj:oWSCONFIRMATIONHANDLERESULT:oWSMESSAGEVIEW }

	//////////////////////////////////////////
	// Pagina em comum para todas as operacoes
	// Inclusao - Exclusao - Edicao
	cHtml += ExecInPage( "PWSP042X" )
	
Else
	HttpSession->cLinkErro	:= ""
	HttpSession->cBotaoErro	:= ""
	HttpSession->nNewWin		:= 1
	HttpSession->cErro		:=	StrGantt( GetWscError(3) )
	cHtml 						:= ExecInPage( "PWSP001" )
Endif

WEB EXTENDED END

Return cHtml
