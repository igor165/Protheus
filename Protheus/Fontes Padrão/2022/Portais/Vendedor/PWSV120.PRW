#INCLUDE "PWSV120.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

//-------------------------------------------------------------------------------------------------------
// Tela de Sele��o de vendedor - Para tarefas
Web Function PWSV120()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HTTPPOST->PWSV020VEN	:= GetUserVen()

HttpSession->PWSV020APH := {	STR0001 ,;		// Processamento de Pedidos //"Tarefas"
								"W_PWSV121.APW"	,;	// Proxima Tela
								"" ,;	 			// Msg de Erro
								"110" }				// Fun��o chamadora
										
HttpSession->FONTES := {"W_PWSV120.APW","W_PWSV122.APW"}
	
If Len(HTTPPOST->PWSV020VEN) <= 1   

	HttpSession->PWSV020APH[3] := STR0002 //"N�o h� vendedores a consultar."
	cHtml += ExecInPage( "PWSV020" )
	
ElseIF Len(HTTPPOST->PWSV020VEN) = 2

	// Apenas 1 vendedor . Define a navega��o para pular a tela de sele��o de vendedores
	
	HTTPPOST->CODVENERP	:= HTTPPOST->PWSV020VEN[2][2]
	
	cHtml += W_PWSV121()

Else

	// Mais de 1 vendedores ? Chama tela de sele��o
	
	cHtml += ExecInPage( "PWSV020" )

Endif

WEB EXTENDED END

Return cHtml


//-------------------------------------------------------------------------------------------------------
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV121   �Autor  �Microsiga            � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela para escolha de tarefas			   					   ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Cleber M. �30/03/06�95202 �- Corrigida a passagem de parametro para a   ���
���          �        �      �GridLinesEx() e a visualizacao dos registros ���
���          �        �      �de Tarefas cadastradas.                      ���
���          �        �      �- Alterado o obj. oTmp como HttpSession.     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV122   �Autor  �Microsiga            � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela para manutencao de tarefas			   				   ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Cleber M. �26/12/06�116086�- Passagem dos campos necessarios no aWebCols���
���          �        �      �para evitar a exibicao de campos nao usados. ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
		// Se n�o entrou em nada � erro, ent�o volto para a tela de consulta....
		Return W_PWSV121()
EndCase

cHtml += ExecInPage( "PWSV122" )

WEB EXTENDED END

Return cHtml


//-------------------------------------------------------------------------------------------------------
// Tela para manuten��o
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
			Return PWSHTMLALERT( "", STR0003, STR0004 + oObj:cPUTTASKRESULT + STR0005, "W_PWSV121.APW" ) //"Aviso"###"Tarefa n�mero: "###" incluida com sucesso."
		Else
			Return PWSHTMLALERT( "", STR0006, "", "W_PWSV120.APW" ) //"Erro"
		EndIf
		
	Case HttpPost->cAct == "A"
		PWSSetObjToPost( oTmp, HttpSession->HEADV120_1, HttpPost->aPost )
		If oObj:PUTTASK( GetUsrCode(), HttpSession->_CODVEN, oTmp )
			cMsg := STR0004 + oObj:cPUTTASKRESULT + STR0007 //"Tarefa n�mero: "###" alterada com sucesso."
		Else
			cMsg := PWSGetWSError()
		EndIf
	
	Case HttpPost->cAct == "E"
		//cUSERCODE,cSELLERCODE,oWSTASK
		If oObj:DELTASK( GetUsrCode(), HttpSession->_CODVEN, HTTPSession->_Tasks[ val( HttpPost->cPos ) ] )
			Return PWSHTMLALERT( "", STR0003, STR0004 + oObj:cDELTASKRESULT + STR0008, "W_PWSV120.APW" ) //"Aviso"###"Tarefa n�mero: "###" excluida com sucesso."
		Else
			Return PWSHTMLALERT( "", STR0006, "", "W_PWSV120.APW" ) //"Erro"
		EndIf
	
	OtherWise
		// Se n�o entrou em nada � erro, ent�o volto para a tela de consulta....
		Return W_PWSV121()
EndCase

cHtml += ExecInPage( "PWSV123" )

WEB EXTENDED END

Return cHtml
