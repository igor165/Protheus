#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA170.CH"

/*
������������������������������������ͳ��
���Data Fonte Sustenta��o� ChangeSet ���
������������������������������������ĳ��  
���    25/09/2014        �  256416   ��� 
�������������������������������������ͱ�
*/ 
Web Function PWSA170()
	Local cHtml   	:= ""
		
	HttpSession->cTypeRequest 	:= "K"		// Dependentes
	HttpGet->titulo				:= STR0001	//"Consulta de Dependentes"
	HttpGet->objetivo			:= STR0003	//"Disponibiliza para consulta as informa��es dos dependentes registrados para o funcion�rio.  Permite tamb�m a visualiza��o dos dependentes dos membros de sua equipe."
	HttpSession->aStructure 	:= {} 
	HttpSession->cHierarquia 	:= ""
	
	HttpCTType("text/html; charset=ISO-8859-1")	
	
	WEB EXTENDED INIT cHtml START "InSite"
		fGetInfRotina("W_PWSA170.APW")
		GetMat()
			    
		cHtml := ExecInPage("PWSA260A")	
	WEB EXTENDED END
Return cHtml


Web Function PWSA171()
	Local cHtml   	:= ""
	Local oWSDependents
	HttpCTType("text/html; charset=ISO-8859-1")	
	
	WEB EXTENDED INIT cHtml START "InSite"
		HttpSession->DadosFunc := HttpSession->aStructure[val(HttpGet->nIndice)]

		oWSDependents := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHDependents"), WSRHDependents():New())
		WsChgURL(@oWSDependents, "RHDEPENDENTS.APW",,,GetEmpFun())
	    
		oWSDependents:cBranch 	        := HttpSession->DadosFunc:cEmployeeFilial
 		oWSDependents:cRegistration    	:= HttpSession->DadosFunc:cRegistration 

		If oWSDependents:BrowseDependents()	
			oEmployee	:= oWSDependents:oWSBrowseDependentsResult:oWSEmployee
			aDependents	:= oWSDependents:oWSBrowseDependentsResult:oWSDependents:oWSTDependent
			//aDependents	:= oWSDependents:oWSBrowseDependentsResult:oWSTDependent            
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA000.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf

		cHtml := ExecInPage( "PWSA171" )	
	WEB EXTENDED END

Return cHtml
