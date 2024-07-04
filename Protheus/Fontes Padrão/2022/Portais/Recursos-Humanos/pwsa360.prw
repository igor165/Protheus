#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA360.CH"

#DEFINE PAGE_LENGTH 10
/*/
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������Ŀ��
���Fun��o    � PWSA360  � Autor � Emerson Campos                   � Data � 06/08/12 ���
������������������������������������������������������������������������������������Ĵ��
���Descri��o � Resultado Grafico de Avaliacao                                        ���
������������������������������������������������������������������������������������Ĵ��
���Uso       � RH/Portais                                                            ���
������������������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                                ���
������������������������������������������������������������������������������������Ĵ��
��� Analista	    � Data       � FNC ou REQ     � 	Motivo da Alteracao          ���
������������������������������������������������������������������������������������Ĵ�� 
���                 �            �                �                                  ���
���                 �            �                �                                  ���
���                 �            �                �                                  ���
�������������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������/*/
Web Function PWSA360()	//Resultado Grafico de Avaliacao  

Local cHtml := ""
Local oWSMonitoring
Local oMsg

HttpSession->nPageLength	:= PAGE_LENGTH
Private lLoginOk	:= .F.

HttpSession->nPageTotal		:= 0
HttpSession->nCurrentPage	:= 0
HttpSession->CurrentPage	:= 0
HttpSession->FiltroEval		:= ''
HttpSession->FiltroField	:= ''
HttpSession->FiltroVagas1	:= ''
HttpSession->FiltroField1	:= ''
HttpSession->GetMonitoring	:= {}
HttpSession->cMsg			:= ''

WEB EXTENDED INIT cHtml START "InSite"
	
    oWSMonitoring := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHMonitoring"), WSRHMonitoring():New())
	WsChgURL(@oWSMonitoring, "RHMONITORING.APW")   					
	
	oMsg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
	WsChgURL(@oMsg,"CFGDICTIONARY.APW")	
    
	If !Empty(HttpPost->cFilterValue)
		oWSMonitoring:cFilterValue	:= HttpPost->cFilterValue
		oWSMonitoring:cFilterField	:= HttpPost->cFilterField
		HttpSession->FiltroEval		:= HttpPost->cFilterValue
		HttpSession->FiltroField	:= HttpPost->cFilterField 
	EndIf
    		
    //Registration somente deve ser enviado a Matricula do usuario qdo proveniente da rotina Avalia��o do Processo Seletivo
    oWSMonitoring:cBranch	 	:= HTTPSession->RHFilMat 		//Filial
	oWSMonitoring:cRegistration	:= HttpSession->RHMat 			//Matricula
	
	If oWSMonitoring:BrowseMonitoring()

		If Len( oWSMonitoring:oWSBrowseMonitoringResult:oWSItens:oWSTMonitoringList ) > 0
			HttpSession->nPageTotal	:=  Ceiling( Len(oWSMonitoring:oWSBrowseMonitoringResult:oWSItens:oWSTMonitoringList)/PAGE_LENGTH)	
			
			If !Empty(HttpPost->cCurrentPage)
				If Val(HttpPost->cCurrentPage) > 0 .AND. Val(HttpPost->cCurrentPage) <= HttpSession->nPageTotal 
					HttpSession->nCurrentPage	:= Val(HttpPost->cCurrentPage)
					HttpSession->CurrentPage	:= HttpSession->nCurrentPage
				Else
					HttpSession->nCurrentPage	:= HttpSession->CurrentPage
				EndIf
			Else
				HttpSession->nCurrentPage	:= 1	
			EndIf	
		 
			HttpSession->GetMonitoring := oWSMonitoring:oWSBrowseMonitoringResult:oWSItens:oWSTMonitoringList
       EndIf
			cHtml += ExecInPage( "PWSA360" )

	Else
		conout( PWSGetWSError() )
	EndIf

WEB EXTENDED END

Return cHtml

Web Function PWSA360B()
	Local cHtml   	:= ""
	Private aDados	:= {}
	Private cDescSelec
	Private cEndDtSelec  
	
	HttpCTType("text/html; charset=ISO-8859-1")	
	
	WEB EXTENDED INIT cHtml START "InSite"
		oWSMonitoring := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHMonitoring"), WSRHMonitoring():New())
		WsChgURL(@oWSMonitoring, "RHMONITORING.APW")
		oWSMonitoring:cCode			:= HttpPost->cCode
		
		If oWSMonitoring:GetMonitoring()
			aDados	:= oWSMonitoring:OWSGetMonitoringResult:oWSItens:oWSTGraphicsList
			cDescSelec	:= oWSMonitoring:OWSGetMonitoringResult:cDescripSelec
			cEndDtSelec := oWSMonitoring:OWSGetMonitoringResult:cEndDateSelec
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA000.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf
		
		cHtml := ExecInPage( "PWSA360B" )		
	WEB EXTENDED END
	
Return cHtml
