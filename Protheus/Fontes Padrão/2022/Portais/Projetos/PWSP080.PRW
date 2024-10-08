#INCLUDE "PWSP080.ch"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGAWIN.CH"   

#DEFINE _TaskType                1
#DEFINE _TaskCode                2
#DEFINE _TaskDescription         3
#DEFINE _EstimatedInitialDate	 4
#DEFINE _EstimatedFinalDate		 5
#DEFINE _EstimatedInitialHour	 6
#DEFINE _EstimatedFinalHour		 7
#DEFINE _ExecutionInitialDate	 8
#DEFINE _ExecutionFinalDate		 9
#DEFINE _POC                		10
#DEFINE _CPM                		11
#DEFINE _TimeDuration       	   12
#DEFINE _DbRecord           		13
#DEFINE _Resources          		14
#DEFINE _Level              		15
#DEFINE _ProjectCode            16
#DEFINE _BitMap                 17

#DEFINE _GANTT_ELEMENTS    		17

#DEFINE _SEPARADOR ' |'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��																		  							��
��  MENU (Portal Projetos)										   						��
��	   ��> CONSULTAS          										   					��
��				    ��> GRAFICO DE GANTT   					  							��
��																		   						��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PWSP080   �Autor  �Cristiano Denardi   � Data �  08/11/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Pagina inicial do item "Grafico Gantt" do menu principal.  ���
���          � Escopo do filtro                                           ���
�������������������������������������������������������������������������͹��
���Uso       � Portal PMS                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Web Function PWSP080()

Local cHtml := ""

WEB EXTENDED INIT cHtml

cHtml += ExecInPage( "PWSP080" )

WEB EXTENDED END

Return cHtml

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PWSP081   �Autor  �Cristiano Denardi   � Data �  08/11/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Resposta do filtro para projetos.                          ���
���          � (lista projetos dentro do escopo do filtro)                ���
�������������������������������������������������������������������������͹��
���Uso       � Portal PMS                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Web Function PWSP081()

Local cHtml := ""
Local cBsc	:= ""
Local aBsc	:= {}
Local lBsc	:= ( HttpPost->cBusca == "2" )
Local cOpc	:= ""
Local lNext	:= .T.
Local oObj
Local nX
Local dDtInitial, dDtFinal, cProjectInitial, cProjectFinal

Local lFilterClients := GetFilClients() == 1
Local aClients := {}
Local i := 0

//������������������������������������������������Ŀ
//� Ajusta variaveis para chamada desta pagina     �
//� de diversos pontos do portal, sem a necessidade�
//� de se passa-las via Form Metodo POST           �
//��������������������������������������������������
If ValType( HttpPost->cDATEINITIAL		) == "U"
	dDtInitial      := HttpSession->dDtInitial
Else
	dDtInitial		 := HttpPost->cDATEINITIAL
Endif
If ValType( HttpPost->cDATEFINAL			) == "U"
	dDtFinal        := HttpSession->dDtFinal
Else
	dDtFinal			 := HttpPost->cDATEFINAL
Endif
If ValType( HttpPost->cPROJECTINITIAL	) == "U"
	cProjectInitial := HttpSession->cProjectInitial
Else
	cProjectInitial := HttpPost->cPROJECTINITIAL
Endif
If ValType( HttpPost->cPROJECTFINAL		) == "U"
	cProjectFinal   := HttpSession->cProjectFinal
Else
	cProjectFinal   := HttpPost->cPROJECTFINAL
Endif


WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSREPORT' ), WSPMSREPORT():New() )
WsChgURL( @oObj, "PMSREPORT.APW" )

oObj:cUSERCODE				:= GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
oObj:dDATEINITIAL			:= Ctod(dDtInitial)
oObj:dDATEFINAL			:= Ctod(dDtFinal  )
oObj:cPROJECTINITIAL		:= cProjectInitial
oObj:cPROJECTFINAL		:= cProjectFinal
cBsc							:= HttpPost->cBuscaAv
cOpc							:= HttpPost->cComboAv

HttpSession->dDtInitial 		:= dDtInitial
HttpSession->dDtFinal   		:= dDtFinal
HttpSession->cProjectInitial	:= cProjectInitial
HttpSession->cProjectFinal		:= cProjectFinal

oObj:cHeaderType := "PROJECTLISTVIEW"
If oObj:GetHeader()
	HttpSession->WSPMS80RESULT := {}
	
	AAdd(HttpSession->WSPMS80RESULT,{} ) // Posicao 1 Reservado para campos do aHeader
	For nX := 1 To Len( oObj:oWSGETHEADERRESULT:oWSBRWHEADER )
		AAdd(HttpSession->WSPMS80RESULT[1],{	oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nX]:cHEADERCOMBOBOX ,;
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


//
// MV_PMSPCLI
// 
// Traz apenas os projetos do cliente logado no portal.
//
// 0 - desabilitado (padr�o)
// 1 - habilitado

/*
Local lFilterClients := GetFilClients() == 1

		// filtro por cliente (usu�rio logado)
		

*/
	If !lFilterClients
	If oObj:GetProjectList()  
		If lBsc .And. !Empty(cBsc) // Dados Enviados pelo Form de Busca Avancada
			aBsc := aIntStrFil( cBsc )
		Endif
		For nX := 1 To Len(oObj:oWSGETPROJECTLISTRESULT:oWSPROJECTLISTVIEW)
			If lBsc .And. !Empty(cBsc) // Dados Enviados pelo Form de Busca Avancada
				lNext := BscAvanWeb( cOpc, aBsc, {	oObj:oWSGETPROJECTLISTRESULT:oWSPROJECTLISTVIEW[nX]:cPROJECTCODE			,;
																Dtoc(oObj:oWSGETPROJECTLISTRESULT:oWSPROJECTLISTVIEW[nX]:dPROJECTDATE)	})
			Endif
			If lNext
				AAdd(HttpSession->WSPMS80RESULT,{	oObj:oWSGETPROJECTLISTRESULT:oWSPROJECTLISTVIEW[nX]:cPROJECTCODE       ,;
																Dtoc(oObj:oWSGETPROJECTLISTRESULT:oWSPROJECTLISTVIEW[nX]:dPROJECTDATE) ,;
																oObj:oWSGETPROJECTLISTRESULT:oWSPROJECTLISTVIEW[nX]:cDESCRIPTION       ,;
																oObj:oWSGETPROJECTLISTRESULT:oWSPROJECTLISTVIEW[nX]:cProjectRevision   ,;
																oObj:oWSGETPROJECTLISTRESULT:oWSPROJECTLISTVIEW[nX]:cProjectStage      ,;
																oObj:oWSGETPROJECTLISTRESULT:oWSPROJECTLISTVIEW[nX]:cProjectCliente    ,;
																oObj:oWSGETPROJECTLISTRESULT:oWSPROJECTLISTVIEW[nX]:cProjectUnit       })
			Endif
		Next nX
 		cHtml += ExecInPage( "PWSP081" )
	Else
		HttpSession->cLinkErro	:= "W_PWSP080.APW"
		HttpSession->cBotaoErro	:= STR0001 //"voltar"
		HttpSession->cErro		:=	StrGantt( GetWscError() )
		cHtml 						:= ExecInPage( "PWSP001" )
	Endif
	Else

		// filtro por cliente (usu�rio logado)
		aClients := GetClients(GtPtUsrCod()[1])

		For i := 1 To Len(aClients)
		
			oObj:cCLIENTINITIAL := aClients[i]
			oObj:cCLIENTFINAL   := aClients[i]
		
			If oObj:GetProjListByClient()  
				If lBsc .And. !Empty(cBsc) // Dados Enviados pelo Form de Busca Avancada
					aBsc := aIntStrFil( cBsc )
				Endif
				For nX := 1 To Len(oObj:oWSGETPROJLISTBYCLIENTRESULT:oWSPROJECTLISTVIEW)
					If lBsc .And. !Empty(cBsc) // Dados Enviados pelo Form de Busca Avancada
						lNext := BscAvanWeb( cOpc, aBsc, {	oObj:oWSGETPROJLISTBYCLIENTRESULT:oWSPROJECTLISTVIEW[nX]:cPROJECTCODE			,;
																		Dtoc(oObj:oWSGETPROJLISTBYCLIENTRESULT:oWSPROJECTLISTVIEW[nX]:dPROJECTDATE)	})
					Endif
					If lNext
						AAdd(HttpSession->WSPMS80RESULT,{	oObj:oWSGETPROJLISTBYCLIENTRESULT:oWSPROJECTLISTVIEW[nX]:cPROJECTCODE       ,;
																		Dtoc(oObj:oWSGETPROJLISTBYCLIENTRESULT:oWSPROJECTLISTVIEW[nX]:dPROJECTDATE) ,;
																		oObj:oWSGETPROJLISTBYCLIENTRESULT:oWSPROJECTLISTVIEW[nX]:cDESCRIPTION       ,;
																		oObj:oWSGETPROJLISTBYCLIENTRESULT:oWSPROJECTLISTVIEW[nX]:cProjectRevision   ,;
																		oObj:oWSGETPROJLISTBYCLIENTRESULT:oWSPROJECTLISTVIEW[nX]:cProjectStage      ,;
																		oObj:oWSGETPROJLISTBYCLIENTRESULT:oWSPROJECTLISTVIEW[nX]:cProjectCliente    ,;
																		oObj:oWSGETPROJLISTBYCLIENTRESULT:oWSPROJECTLISTVIEW[nX]:cProjectUnit       })
					Endif
				Next
			EndIf
		Next
		 
	cHtml += ExecInPage("PWSP081")		
	EndIf

Else
	HttpSession->cLinkErro	:= "W_PWSP080.APW"
	HttpSession->cBotaoErro	:= STR0001 //"voltar"
	HttpSession->cErro		:=	StrGantt( GetWscError() )
	cHtml 						:= ExecInPage( "PWSP001" )
Endif

WEB EXTENDED END

Return cHtml

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PWSP082   �Autor  �Bruno Sobieski      � Data �  31/10/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta dados para o Gantt                                   ���
�������������������������������������������������������������������������͹��
���Uso       � Portal PMS                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Web Function PWSP082()

Local cHtml := ""
Local oObj
Local nX

WEB EXTENDED INIT cHtml

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSPMSREPORT' ), WSPMSREPORT():New() )
WsChgURL( @oObj, "PMSREPORT.APW" )

oObj:cUSERCODE			:= GtPtUsrCod()[1]
oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
oObj:cPROJECTCODE			:= StrTran(HttpGet->cProjectCode,"@SPC@"," ")
oObj:cWBSCODE				:= StrTran(HttpGet->cWbsCode,"@SPC@"," ")

If oObj:GETGANTT()
	HttpSession->WSGANTTRESULT	:=	{}      
	
	HttpSession->WSGANTTHEADER	:=	"TASKTYPE#PROJECTCODE#TASKCODE#TASKDESCRIPTION#TIMEDURATION#ESTIMATEDINITIALDATE#ESTIMATEDFINALDATE#"+;
												"ESTIMATEDINITIALHOUR#ESTIMATEDFINALHOUR#EXECUTIONINITIALDATE#EXECUTIONFINALDATE#POC#"+;
												"CPM#LEVEL#RESOURCES#BITMAP#DBRECORD"
	
	For nX := 1 To Len( oObj:oWSGETGANTTRESULT:OWSGANTTTASKVIEW)
		AAdd(HttpSession->WSGANTTRESULT	, 	Alltrim(Str(oObj:oWSGETGANTTRESULT:OWSGANTTTASKVIEW[nX]:nTaskType))				+_SEPARADOR+;				
													 	oObj:oWSGETGANTTRESULT:OWSGANTTTASKVIEW[nX]:cProjectCode         	   			+_SEPARADOR+;
													 	oObj:oWSGETGANTTRESULT:OWSGANTTTASKVIEW[nX]:cTaskCode            	   			+_SEPARADOR+;
														oObj:oWSGETGANTTRESULT:OWSGANTTTASKVIEW[nX]:cTaskDescription 						+_SEPARADOR+;    
														TransForm(oObj:oWSGETGANTTRESULT:OWSGANTTTASKVIEW[nX]:nTimeDuration,"9999.99")+_SEPARADOR+;
														Dtos(oObj:oWSGETGANTTRESULT:OWSGANTTTASKVIEW[nX]:dEstimatedInitialDate)			+_SEPARADOR+;
														Dtos(oObj:oWSGETGANTTRESULT:OWSGANTTTASKVIEW[nX]:dEstimatedFinalDate)				+_SEPARADOR+;
														oObj:oWSGETGANTTRESULT:OWSGANTTTASKVIEW[nX]:cEstimatedInitialHour					+_SEPARADOR+;
														oObj:oWSGETGANTTRESULT:OWSGANTTTASKVIEW[nX]:cEstimatedFinalHour						+_SEPARADOR+;
														Dtos(oObj:oWSGETGANTTRESULT:OWSGANTTTASKVIEW[nX]:dExecutionInitialDate)			+_SEPARADOR+;
														Dtos(oObj:oWSGETGANTTRESULT:OWSGANTTTASKVIEW[nX]:dExecutionFinalDate)				+_SEPARADOR+;
														TransForm(oObj:oWSGETGANTTRESULT:OWSGANTTTASKVIEW[nX]:nPOC,"999.99%")			+_SEPARADOR+;
														Alltrim(Str(oObj:oWSGETGANTTRESULT:OWSGANTTTASKVIEW[nX]:nCPM))						+_SEPARADOR+;
														oObj:oWSGETGANTTRESULT:OWSGANTTTASKVIEW[nX]:cLevel		           					+_SEPARADOR+;
														oObj:oWSGETGANTTRESULT:OWSGANTTTASKVIEW[nX]:cResources	           					+_SEPARADOR+;
														oObj:oWSGETGANTTRESULT:OWSGANTTTASKVIEW[nX]:cBitMap		           					+_SEPARADOR+;
														Alltrim(Str(oObj:oWSGETGANTTRESULT:OWSGANTTTASKVIEW[nX]:nDbRecord)) 				+_SEPARADOR)
	Next nX
	cHtml += ExecInPage( "PWSP082" )
Else
	HttpSession->cLinkErro	:= ""
	HttpSession->cBotaoErro	:= ""
	HttpSession->nNewWin		:= 1
	HttpSession->cErro		:=	StrGantt( GetWscError() )
	cHtml 						:= ExecInPage( "PWSP001" )
Endif

WEB EXTENDED END

Return cHtml
