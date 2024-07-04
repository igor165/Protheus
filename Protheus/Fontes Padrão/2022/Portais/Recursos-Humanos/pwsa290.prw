#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA290.CH"

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
���Fun��o    � PWSA290  � Autor � Emerson Campos                   � Data � 15/06/12 ���
������������������������������������������������������������������������������������Ĵ��
���Descri��o � Espelho de Ponto                                                      ���
������������������������������������������������������������������������������������Ĵ��
���Uso       � RH/Portais                                                            ���
������������������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                                ���
������������������������������������������������������������������������������������Ĵ��
��� Analista        � Data       � FNC ou REQ     � 	Motivo da Alteracao          ���
������������������������������������������������������������������������������������Ĵ�� 
���Emerson Campos   � 04/09/2012 � Req126-12      � Adaptar o fonte para apresentar o���
���                 �            �                � espelho de ponto para a fase 4.  ���
���Marcelo Faria    � 06/05/2013 � TCYCJW         � Buscar transferencias do         ���
���                 �            �                � funcionario logado no portal.    ���
���Allyson M    	� 27/11/2013 � TIBOT0         � Ajuste p/ disponibilizar a busca ���
���                 �            �                � transferencias do funcionario    ���
���                 �            �                � logado no portal p/ todas versoes���
�������������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������/*/
Web Function PWSA290()
	Local cHtml   	:= ""
    
	HttpCTType("text/html; charset=ISO-8859-1")

	WEB EXTENDED INIT cHtml START "InSite"              
		HttpSession->cTypeRequest := "F"     //"Espelho de Ponto"    
		HttpGet->titulo          := STR0001 //"Consulta de Espelho de Ponto"    
		HttpGet->objetivo        := STR0003
		HttpSession->aStructure   := {}
		HttpSession->cHierarquia  := ""
	   HttpSession->IndTransf    := "0"
  		
		fGetInfRotina("W_PWSA290.APW")
		GetMat()								//Pega a Matricula e a filial do participante logado
        
		cHtml := ExecInPage("PWSA260A")
	WEB EXTENDED END
Return cHtml 

Web Function PWSA290B()
	Local cHtml   			:= ""
	Local oWSAnotations
	Private nCurrentPage
	Private nPageTotal	
	Private aFilter			:= {}
	Private aPeriods		   := {}
	Private cPeriodView
	Private cPerAponta
	Private cIndice       := "" 

   If (HttpGet->nIndice != "0") .And. (HttpSession->IndTransf		== "0")
	   cIndice := HttpGet->nIndice
	   HttpSession->DadosFunc := HttpSession->aStructure[val(cIndice)]
   Else
     If HttpGet->nIndiceTransf != "0" .Or. HttpSession->IndTransf != "0"
	   	  //Carrega Dados atuais do funcionario
   		  HttpSession->DadosFunc := HttpSession->aStructure[1]

		  //Pagina recarregada pelo filtro 
		  If HttpSession->IndTransf		!= "0"
			 HttpGet->nIndiceTransf := HttpSession->IndTransf 
		  EndIf
		  cIndice := HttpGet->nIndiceTransf

		  //Atualiza informacoes com dados da matricula transferida
		  HttpSession->DadosFunc:cEmployeeFilial		:= HttpSession->aUserTransf:OWSLISTOFTRANSFERS:OWSDATAEMPLOYEETRANSF[val(HttpGet->nIndiceTransf)]:cFilTransfFrom 
		  HttpSession->DadosFunc:cFilialDescr   		:= HttpSession->aUserTransf:OWSLISTOFTRANSFERS:OWSDATAEMPLOYEETRANSF[val(HttpGet->nIndiceTransf)]:cFilialDescr
		  HttpSession->DadosFunc:cRegistration		 	:= 	HttpSession->aUserTransf:OWSLISTOFTRANSFERS:OWSDATAEMPLOYEETRANSF[val(HttpGet->nIndiceTransf)]:cRegTransfFrom 
		  HttpSession->DadosFunc:cName 					:= HttpSession->aUserTransf:OWSLISTOFTRANSFERS:OWSDATAEMPLOYEETRANSF[val(HttpGet->nIndiceTransf)]:cName 
		  HttpSession->DadosFunc:cAdmissionDate			:= HttpSession->aUserTransf:OWSLISTOFTRANSFERS:OWSDATAEMPLOYEETRANSF[val(HttpGet->nIndiceTransf)]:cAdmissionDate 
		  HttpSession->DadosFunc:cNameSup				:= "" 
		  HttpSession->DadosFunc:cPosition				:= HttpSession->aUserTransf:OWSLISTOFTRANSFERS:OWSDATAEMPLOYEETRANSF[val(HttpGet->nIndiceTransf)]:cPosition 
		  HttpSession->DadosFunc:cFunctionDesc			:= HttpSession->aUserTransf:OWSLISTOFTRANSFERS:OWSDATAEMPLOYEETRANSF[val(HttpGet->nIndiceTransf)]:cFunctionDesc 
		  HttpSession->DadosFunc:cDescrDepartment	  	:= HttpSession->aUserTransf:OWSLISTOFTRANSFERS:OWSDATAEMPLOYEETRANSF[val(HttpGet->nIndiceTransf)]:cDescrDepartment 
		  HttpSession->DadosFunc:cCost					:= HttpSession->aUserTransf:OWSLISTOFTRANSFERS:OWSDATAEMPLOYEETRANSF[val(HttpGet->nIndiceTransf)]:cCost 
		  HttpSession->DadosFunc:nSalary				:= HttpSession->aUserTransf:OWSLISTOFTRANSFERS:OWSDATAEMPLOYEETRANSF[val(HttpGet->nIndiceTransf)]:nSalary 
		EndIf
	EndIf

	HttpCTType("text/html; charset=ISO-8859-1")
	
	WEB EXTENDED INIT cHtml START "InSite"	
		
	   If cIndice == ""   	
		  HttpSession->_HTMLERRO := { "Info", "Indice nao localizado!", "W_PWSA290.APW" }
		  Return ExecInPage("PWSAMSG" )
	   EndIf
		
		oWSAnotations := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHAnotations"), WSRHAnotations():New())
		WsChgURL(@oWSAnotations, "RHAnotations.APW",,,GetEmpFun())
		                 
		oWSAnotations:cRegistration		:= HttpSession->DadosFunc:cRegistration  
		oWSAnotations:cBranch	 		:= HttpSession->DadosFunc:cEmployeeFilial
		oWSAnotations:cFilterField		:= HttpGet->FilterField
		oWSAnotations:cFilterValue		:= HttpGet->FilterValue	
		oWSAnotations:nCurrentPage		:= nCurrentPage
		
		If oWSAnotations:GetAnotationsFields()
			aFields		:= oWSAnotations:OWSGETANOTATIONSFIELDSRESULT:OWSFIELDS:OWSTANOTATIONSFIELDS
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA290.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf
		
		If oWSAnotations:GetPeriods()			
		   	aPeriods	:= oWSAnotations:OWSGETPERIODSRESULT:OWSPERIODS:OWSTPERIODSLIST		   			               
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA290.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf
			
		If oWSAnotations:GetAnotations()			
			aAnotations	:= oWSAnotations:OWSGETANOTATIONSRESULT:OWSITENS:OWSTANOTATIONSLIST
			cPeriodView	:= oWSAnotations:OWSGETANOTATIONSRESULT:CPERIODVIEW
			cPerAponta	:= oWSAnotations:OWSGETANOTATIONSRESULT:CPERIODFIELTER			               
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA290.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf 		
		
		cHtml := ExecInPage("PWSA290C")	
	WEB EXTENDED END	
	
Return cHtml
