#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA270.CH"

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍ³±±
±±³Data Fonte Sustentação³ ChangeSet ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ³±±  
±±³    25/09/2014        ³  256418   ³±± 
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍ±±
*/ 
/***************************************************************
* Funcao: PWSA270
* Autor: Marcelo Faria
* Data: 21/05/2012
* Portal RH Ferias Programadas (Projeto P12 - Requisito 126_005)
****************************************************************/
Web Function PWSA270()

	Local cHtml   	:= ""
	HttpCTType("text/html; charset=ISO-8859-1")
	WEB EXTENDED INIT cHtml START "InSite"	              
		HttpSession->cTypeRequest 	:= "FERPROG"	 
		HttpGet->titulo          := STR0001 		//"Ferias Programados"
		HttpGet->objetivo           := STR0002
		HttpSession->aStructure   	:= {}
		HttpSession->cHierarquia  	:= ""
		
		fGetInfRotina("W_PWSA270.APW")   				//Retorno HttpSession->aInfRotina
		GetMat()															//Pega a Matricula e a filial do participante logado

		cHtml := ExecInPage("PWSA260A")
	WEB EXTENDED END

Return cHtml

/*******************************************************************
* Funcao: PWSA271
* Autor: Marcelo Faria
* Data: 21/05/2012
* Consulta Ferias Programadas - interacao
********************************************************************/
Web Function PWSA271()
Local cHtml   	:= ""
Local nIndice 	:= 0
Local oWSFerProg
//Private aFerProg
HttpCTType("text/html; charset=ISO-8859-1")
if(valtype(HttpGet->nIndice) != "U")
   nIndice := val(HttpGet->nIndice) 
endif

WEB EXTENDED INIT cHtml START "InSite"  
	 //Pega filial e matricula do participante
    GetMat() 
	
	If (HttpGet->nOperacao == "1")  
   		HttpSession->DadosFunc := HttpSession->aStructure[val(HttpGet->nIndice)]

		//Busca dados do funcionario
		oWSFerProg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WsRHVACATION"), WsRHVACATION():New())
		WsChgURL(@oWSFerProg, "RHVACATION.apw",,,GetEmpFun())

		oWSFerProg:cEmployeeFil				:= HttpSession->DadosFunc:cEmployeeFilial
		oWSFerProg:cRegistration			:= HttpSession->DadosFunc:cRegistration
		If oWSFerProg:GetVacProgEffect()
			HttpPost->aFerProg 		:= oWSFerProg:oWSGETVACPROGEFFECTRESULT:oWSListOfVacProgEffect:oWSDataVacProgEffect
		Else
			HttpSession->_HTMLERRO	:= { "Erro", PWSGetWSError(), "W_PWSA000.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf
	EndIf

    cHtml := ExecInPage( "PWSA271" )
	
WEB EXTENDED END
Return cHtml
