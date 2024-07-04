#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA300.CH"
/*
������������������������������������ͳ��
���Data Fonte Sustenta��o� ChangeSet ���
������������������������������������ĳ��  
���    25/09/2014        �  256419   ��� 
�������������������������������������ͱ�
*/ 
/*/
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������Ŀ��
���Fun��o    � PWSA300  � Autor � Emerson Campos                   � Data � 29/05/12 ���
������������������������������������������������������������������������������������Ĵ��
���Descri��o � Banco de horas                                                        ���
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
Web Function PWSA300()
Local cHtml   	:= ""
	HttpCTType("text/html; charset=ISO-8859-1")
	WEB EXTENDED INIT cHtml START "InSite"	              
		HttpSession->cTypeRequest 	:= "E"		//"Banco de Horas"    
		HttpGet->titulo           	:= STR0001 	//"Consulta de Banco de Horas"    
		HttpGet->objetivo           := STR0003
		HttpSession->aStructure	   	:= {}
		HttpSession->cHierarquia	:= ""
		
		fGetInfRotina("W_PWSA300.APW")
		GetMat()								//Pega a Matricula e a filial do participante logado

		cHtml := ExecInPage("PWSA260A")
	WEB EXTENDED END
Return cHtml

Web Function PWSA300B()
	Local cHtml:= ""
	Local oWSHoursBank
	Private aFields
	Private aHoursBank    
	HttpCTType("text/html; charset=ISO-8859-1")
	HttpSession->DadosFunc := HttpSession->aStructure[val(HttpGet->nIndice)]
	
	WEB EXTENDED INIT cHtml START "InSite"
		
		oWSHoursBank := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHHoursBank"), WSRHHoursBank():New())
		WsChgURL(@oWSHoursBank, "RHHoursBank.APW",,,GetEmpFun())
		
		oWSHoursBank:cBranch	 		:= HttpSession->DadosFunc:cEmployeeFilial
		oWSHoursBank:cRegistration		:= HttpSession->DadosFunc:cRegistration
	
		If oWSHoursBank:GetHoursBank()
			cHtml	:= oWSHoursBank:cGetHoursBankResult			
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA300.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf
			
	WEB EXTENDED END	
Return cHtml
