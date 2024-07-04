#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA310.CH"

/*
������������������������������������ͳ��
���Data Fonte Sustenta��o� ChangeSet ���
������������������������������������ĳ��  
���    31/07/2014        �  243473   ��� 
�������������������������������������ͱ�
*/ 
/*/
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������Ŀ��
���Fun��o    � PWSA310  � Autor � Emerson Campos                   � Data � 31/05/12 ���
������������������������������������������������������������������������������������Ĵ��
���Descri��o � Tabela de Horario                                                     ���
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
Web Function PWSA310()	
	Local cHtml   	:= ""
	HttpCTType("text/html; charset=ISO-8859-1")
	WEB EXTENDED INIT cHtml START "InSite"	              
		HttpSession->cTypeRequest 	:= "G"		//"Tabela de Hor�rios"    
		HttpGet->titulo           	:= STR0001 	//"Consulta de Tabela de Hor�rios"    
		HttpGet->objetivo           := STR0003
		HttpSession->aStructure	   	:= {}
		HttpSession->cHierarquia	:= ""
		
		fGetInfRotina("W_PWSA310.APW")
		GetMat()								//Pega a Matricula e a filial do participante logado

		cHtml := ExecInPage("PWSA260A")
	WEB EXTENDED END
Return cHtml

Web Function PWSA310B()
	Local cHtml:= ""
	Local oWSScheduleChart
	Private aFields
	Private aScheduleChart	
		
	HttpCTType("text/html; charset=ISO-8859-1")
	HttpSession->DadosFunc := HttpSession->aStructure[val(HttpGet->nIndice)]
	
	WEB EXTENDED INIT cHtml START "InSite"		
		
		oWSScheduleChart := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHScheduleChart"), WSRHScheduleChart():New())
		WsChgURL(@oWSScheduleChart, "RHScheduleChart.APW",,,GetEmpFun())
		
		oWSScheduleChart:cRegistration		:= HttpSession->DadosFunc:cRegistration  
		oWSScheduleChart:cBranch	 		:= HttpSession->DadosFunc:cEmployeeFilial
	
		If oWSScheduleChart:GetScheduleChart()
			aScheduleChart	:= oWSScheduleChart:OWSGETSCHEDULECHARTRESULT:OWSITENS:OWSTSCHEDULECHARTLIST
			aFields			:= oWSScheduleChart:OWSGETSCHEDULECHARTRESULT:OWSFIELDS:OWSTSCHEDULECHARTFIELDS			 
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA310.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf
		
		cHtml += ExecInPage( "PWSA310B" )	
	WEB EXTENDED END	
Return cHtml
