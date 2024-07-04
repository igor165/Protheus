#INCLUDE "PWSV120.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

//-------------------------------------------------------------------------------------------------------
// Tela de Seleção de vendedor - Para tarefas
Web Function PWSV120()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HTTPPOST->PWSV020VEN	:= GetUserVen()

HttpSession->PWSV020APH := {	STR0001 ,;		// Processamento de Pedidos //"Tarefas"
								"W_PWSV121.APW"	,;	// Proxima Tela
								"" ,;	 			// Msg de Erro
								"110" }				// Função chamadora
										
HttpSession->FONTES := {"W_PWSV120.APW","W_PWSV122.APW"}
	
If Len(HTTPPOST->PWSV020VEN) <= 1   

	HttpSession->PWSV020APH[3] := STR0002 //"Não há vendedores a consultar."
	cHtml += ExecInPage( "PWSV020" )
	
ElseIF Len(HTTPPOST->PWSV020VEN) = 2

	// Apenas 1 vendedor . Define a navegação para pular a tela de seleção de vendedores
	
	HTTPPOST->CODVENERP	:= HTTPPOST->PWSV020VEN[2][2]
	
	cHtml += W_PWSV121()

Else

	// Mais de 1 vendedores ? Chama tela de seleção
	
	cHtml += ExecInPage( "PWSV020" )

Endif

WEB EXTENDED END

Return cHtml


//-------------------------------------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV121   ºAutor  ³Microsiga            º Data ³  23/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para escolha de tarefas			   					   º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³30/03/06³95202 ³- Corrigida a passagem de parametro para a   º±±
±±º          ³        ³      ³GridLinesEx() e a visualizacao dos registros º±±
±±º          ³        ³      ³de Tarefas cadastradas.                      º±±
±±º          ³        ³      ³- Alterado o obj. oTmp como HttpSession.     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV121()

Local cHtml 	:= ""						//Pagina Web
Local aWebCols 	:= {}						//Array contendo os campos a serem mostrados na tela
Local oObj 									//Objeto WS - WSFTSELLERTASK
Local nX		:= 0						//Variavel auxiliar usada em lacos For..Next
Private cMsg 	:= ""						//Mensagem

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSFTSELLERTASK"), WSFTSELLERTASK():NEW() )
WsChgUrl(@oObj,"FTSELLERTASK.apw")

HTTPSession->oTmp := Nil
HTTPSession->_BrwTask := {}
HTTPSession->_Tasks   := {}

If HttpPost->CODVENERP != Nil
	HttpSession->_CODVEN := HttpPost->CODVENERP
EndIf


HttpSession->HEADV120_1 := {}

If oObj:GETHEADER("TASKVIEW")
	HttpSession->HEADV120_1 := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
Else
	PWSGetWSError()
EndIf


If HttpPost->DataDe == Nil .Or. HttpPost->DataAte == Nil

	HttpPost->Busca := ""
	HttpPost->Tipo  := "1"

	Return ExecInPage( "PWSV121" )

Else

	HTTPSession->_BrwTask := {}
	HTTPSession->_Tasks   := {}
	
	If ExistBlock( "PEV121" )
		aWebCols := ExecBlock( "PEV121", .F., .F., {1} )
	EndIf

	GridHeader(	HTTPSession->_BrwTask ,;
					HttpSession->HEADV120_1 ,;
					aWebCols )

	oObj:dDATEFROM	:= CtoD( HttpPost->DataDe )
	oObj:dDATETO 	:= CtoD( HttpPost->DataAte )
	oObj:cQUERYADDWHERE	 	:= ""
	oObj:cINDEXKEY			:= "AD8.AD8_DTINI"

	If oObj:BRWTASK( GetUsrCode(), HttpSession->_CODVEN )

		HTTPSession->_Tasks := oObj:oWSBRWTASKRESULT:oWSTASKVIEW
		
		For nX := 1 to Len(oObj:oWSBRWTASKRESULT:oWSTASKVIEW)
			GridLinesEX( {	HTTPSession->_BrwTask ,;
							HttpSession->HEADV120_1,;
							oObj:oWSBRWTASKRESULT:oWSTASKVIEW[nX] ,;
							aWebCols,.F.,"A",,0 } )
		Next nX

	Else
		cMsg := PWSGetWSError()
	EndIf

EndIf

cHtml += ExecInPage( "PWSV121" )

WEB EXTENDED END

Return cHtml


//-------------------------------------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV122   ºAutor  ³Microsiga            º Data ³  23/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para manutencao de tarefas			   				   º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³26/12/06³116086³- Passagem dos campos necessarios no aWebColsº±±
±±º          ³        ³      ³para evitar a exibicao de campos nao usados. º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV122()

Local cHtml := ""		//Pagina HTML
Local aWebCols := {}	//Array com os campos a serem exibidos

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->DetalhesTask := {}

Do Case
	Case HttpPost->cAct == "V"
	
		If ExistBlock( "PEV122" )
			aWebCols := ExecBlock( "PEV122", .F., .F., {1} )
		EndIf
	
		GridLinesEX( {	HttpSession->DetalhesTask ,;
						HttpSession->HEADV120_1,;
						HTTPSession->_Tasks[ val( HttpPost->radio ) ] ,;
						aWebCols, .F., "H",,0 } )

	Case HttpPost->cAct == "I"
	
		If ExistBlock( "PEV122" )
			aWebCols := ExecBlock( "PEV122", .F., .F., {2} )
		Else
			aAdd( aWebCols, { "TASKID", "D" } )
			aAdd( aWebCols, "SUBJECT" )
			aAdd( aWebCols, "STARTDATE" )
			aAdd( aWebCols, "ENDDATE" )
			aAdd( aWebCols, "STATUSCODE" )
			aAdd( aWebCols, "PRIORITY" )
			aAdd( aWebCols, "PERCENTCOMPLETE" )
			aAdd( aWebCols, "NOTE" )
		EndIf
	
		If Empty(HTTPSession->oTmp)
			HTTPSession->oTmp := FTSELLERTASK_TASKVIEW():NEW()
		EndIf
		
		HTTPSession->oTmp:dSTARTDATE := Date()
		HTTPSession->oTmp:dENDDATE := Date()
		
		GridLinesEX( {	HttpSession->DetalhesTask ,;
						HttpSession->HEADV120_1,;
						HTTPSession->oTmp ,;
						aWebCols, .T., "H",,0 },"FTSELLERTASK" )
	
	Case HttpPost->cAct == "A"
	
		If ExistBlock( "PEV122" )
			aWebCols := ExecBlock( "PEV122", .F., .F., {3} )
		Else
			aAdd( aWebCols, { "TASKID", "D" } )
			aAdd( aWebCols, "SUBJECT" )
			aAdd( aWebCols, "STARTDATE" )
			aAdd( aWebCols, "ENDDATE" )
			aAdd( aWebCols, "STATUSCODE" )
			aAdd( aWebCols, "PRIORITY" )
			aAdd( aWebCols, "PERCENTCOMPLETE" )
			aAdd( aWebCols, "NOTE" )
		EndIf	
	
		GridLinesEX( {	HttpSession->DetalhesTask ,;
						HttpSession->HEADV120_1,;
						HTTPSession->_Tasks[ val( HttpPost->radio ) ] ,;
						aWebCols, .T., "H",,0 } )
	
	Case HttpPost->cAct == "E"
	        
		If ExistBlock( "PEV122" )
			aWebCols := ExecBlock( "PEV122", .F., .F., {4} )
		EndIf	
	
		GridLinesEX( {	HttpSession->DetalhesTask ,;
						HttpSession->HEADV120_1,;
						HTTPSession->_Tasks[ val( HttpPost->radio ) ] ,;
						aWebCols, .F., "H",,0 } )

	OtherWise
		// Se não entrou em nada é erro, então volto para a tela de consulta....
		Return W_PWSV121()
EndCase

cHtml += ExecInPage( "PWSV122" )

WEB EXTENDED END

Return cHtml


//-------------------------------------------------------------------------------------------------------
// Tela para manutenção
Web Function PWSV123()

Local cHtml := ""
Local oObj
Local oTmp := FTSELLERTASK_TASKVIEW():NEW()
Private cMsg := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSFTSELLERTASK"), WSFTSELLERTASK():NEW() )
WsChgUrl(@oObj,"FTSELLERTASK.apw")

Do Case
	Case HttpPost->cAct == "I"
		PWSSetObjToPost( HTTPSession->oTmp, HttpSession->HEADV120_1, HttpPost->aPost )
	
		If oObj:PUTTASK( GetUsrCode(), HttpSession->_CODVEN, HTTPSession->oTmp )
			Return PWSHTMLALERT( "", STR0003, STR0004 + oObj:cPUTTASKRESULT + STR0005, "W_PWSV121.APW" ) //"Aviso"###"Tarefa número: "###" incluida com sucesso."
		Else
			Return PWSHTMLALERT( "", STR0006, "", "W_PWSV120.APW" ) //"Erro"
		EndIf
		
	Case HttpPost->cAct == "A"
		PWSSetObjToPost( oTmp, HttpSession->HEADV120_1, HttpPost->aPost )
		If oObj:PUTTASK( GetUsrCode(), HttpSession->_CODVEN, oTmp )
			cMsg := STR0004 + oObj:cPUTTASKRESULT + STR0007 //"Tarefa número: "###" alterada com sucesso."
		Else
			cMsg := PWSGetWSError()
		EndIf
	
	Case HttpPost->cAct == "E"
		//cUSERCODE,cSELLERCODE,oWSTASK
		If oObj:DELTASK( GetUsrCode(), HttpSession->_CODVEN, HTTPSession->_Tasks[ val( HttpPost->cPos ) ] )
			Return PWSHTMLALERT( "", STR0003, STR0004 + oObj:cDELTASKRESULT + STR0008, "W_PWSV120.APW" ) //"Aviso"###"Tarefa número: "###" excluida com sucesso."
		Else
			Return PWSHTMLALERT( "", STR0006, "", "W_PWSV120.APW" ) //"Erro"
		EndIf
	
	OtherWise
		// Se não entrou em nada é erro, então volto para a tela de consulta....
		Return W_PWSV121()
EndCase

cHtml += ExecInPage( "PWSV123" )

WEB EXTENDED END

Return cHtml
