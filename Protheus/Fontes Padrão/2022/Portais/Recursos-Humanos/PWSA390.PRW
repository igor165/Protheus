#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH" 
#INCLUDE "PWSA390.CH"

/*
������������������������������������ͳ��
���Data Fonte Sustenta��o� ChangeSet ���
������������������������������������ĳ��  
���    25/09/2014        �  256422   ��� 
�������������������������������������ͱ�
*/ 
/*******************************************************************
* Funcao: PWSA390
* Autor: Emerson Campos
* Data: 20/05/2014
* Consulta hist�rico salarial
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Uso       � RH/Portais                                                   ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Analista     � Data   �FNC:            �  	Motivo da Alteracao        ���
���Emerson Campos|20/05/14|TPWQVG          |Disponibilizado a nova op��o de ���
���              |        |                |Consulta hist�rico salarial     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Web Function PWSA390()
Local cHtml   	:= ""
	HttpCTType("text/html; charset=ISO-8859-1")
	WEB EXTENDED INIT cHtml START "InSite"	              
		HttpSession->cTypeRequest 	:= "X"		//"Banco de Horas"    
		HttpGet->titulo           	:= STR0004 	//"Consulta de hist�rico salarial"    
		HttpGet->objetivo           := STR0019 //'Disponibiliza para consulta o hist�rico salarial do funcion�rio, contendo todas as movimenta��es salariais separadas por tipo do evento ocorrido.'
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
* Consulta hist�rico salarial
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
    	HttpSession->_HTMLERRO := { STR0010, PWSGetWSError(), "W_PWSA001.APW" }	//"N�o h� Hist�rico Salarial registrado"
		Return ExecInPage("PWSAMSG" )
	EndIf

WEB EXTENDED END

Return cHtml
