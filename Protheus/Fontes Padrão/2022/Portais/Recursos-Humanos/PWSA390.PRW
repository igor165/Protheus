#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH" 
#INCLUDE "PWSA390.CH"

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍ³±±
±±³Data Fonte Sustentação³ ChangeSet ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ³±±  
±±³    25/09/2014        ³  256422   ³±± 
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍ±±
*/ 
/*******************************************************************
* Funcao: PWSA390
* Autor: Emerson Campos
* Data: 20/05/2014
* Consulta histórico salarial
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Uso       ³ RH/Portais                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Analista     ³ Data   ³FNC:            ³  	Motivo da Alteracao        ³±±
±±³Emerson Campos|20/05/14|TPWQVG          |Disponibilizado a nova opção de ³±±
±±³              |        |                |Consulta histórico salarial     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PWSA390()
Local cHtml   	:= ""
	HttpCTType("text/html; charset=ISO-8859-1")
	WEB EXTENDED INIT cHtml START "InSite"	              
		HttpSession->cTypeRequest 	:= "X"		//"Banco de Horas"    
		HttpGet->titulo           	:= STR0004 	//"Consulta de histórico salarial"    
		HttpGet->objetivo           := STR0019 //'Disponibiliza para consulta o histórico salarial do funcionário, contendo todas as movimentações salariais separadas por tipo do evento ocorrido.'
		HttpSession->aStructure	   	:= {}
		HttpSession->cHierarquia	:= ""
		
		fGetInfRotina("W_PWSA390.APW")
		GetMat()								//Pega a Matricula e a filial do participante logado

		cHtml := ExecInPage("PWSA260A")
	WEB EXTENDED END
Return cHtml  

/*******************************************************************
* Funcao: PWSA391
* Autor: Emerson Campos
* Data: 20/05/2014
* Consulta histórico salarial
********************************************************************/
Web Function PWSA391()

Local cHtml := "" 
Local oObj
HttpCTType("text/html; charset=ISO-8859-1")
WEB EXTENDED INIT cHtml START "InSite"

	HttpSession->DadosFunc := HttpSession->aStructure[val(HttpGet->nIndice)]

	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHIdentify"), WSRHIdentify():New())
	WsChgURL(@oObj,"RHIdentify.APW",,,GetEmpFun())
	
    If oObj:BRWWAGEHISTORY("MSALPHA", HttpSession->DadosFunc:cParticipantID /*HttpSession->cPartAcesso[1]*/ )
    	HttpSession->BRWWAGEHISTORY := {oObj:oWSBRWWAGEHISTORYRESULT} 
    	
    	Asort(HttpSession->BRWWAGEHISTORY[1]:OWSWHHEADER:OWSWAGEHISTORYHEADER,,, {|x,y| DTOS(x:DWHDATE)+x:CWHSEQUENC > DTOS(y:DWHDATE)+y:CWHSEQUENC    })
    	Asort(HttpSession->BRWWAGEHISTORY[1]:OWSWHDATA:OWSWAGEHISTORYARRAY,,, {|x,y| DTOS(x:OWSWDITEM:OWSWAGEHISTORYVALUES[1]:DWDDATE) + x:OWSWDITEM:OWSWAGEHISTORYVALUES[1]:CWDSEQUENC > DTOS(y:OWSWDITEM:OWSWAGEHISTORYVALUES[1]:DWDDATE)+y:OWSWDITEM:OWSWAGEHISTORYVALUES[1]:CWDSEQUENC})
    	
    	cHtml += ExecInPage( "PWSA391" )
    Else
    	HttpSession->_HTMLERRO := { STR0010, PWSGetWSError(), "W_PWSA001.APW" }	//"Não há Histórico Salarial registrado"
		Return ExecInPage("PWSAMSG" )
	EndIf

WEB EXTENDED END

Return cHtml
