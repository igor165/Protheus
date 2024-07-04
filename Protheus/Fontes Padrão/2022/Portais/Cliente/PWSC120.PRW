#INCLUDE "PWSC120.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

#DEFINE MYUSERCODE GetUsrCode()

#DEFINE CLIENTERP_ENTIDADE		1
#DEFINE CLIENTERP_CODIGO		2
#DEFINE CLIENTERP_NOMEFANT		3
#DEFINE CLIENTERP_RAZAOSOC		4
#DEFINE CLIENTERP_CPFCNPJ		5



//-------------------------------------------------------------------------------------------------------------------------
// Tela 01 : Seleção de Cliente
//-------------------------------------------------------------------------------------------------------------------------
Web Function PWSC120()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWSC120CLI := GetUserCli()

HttpSession->PWSC120APH := { STR0001, ;							// Titulo //"Gerenciamento de Tarefas"
									  "W_PWSC121.APW", ;											// Proxima Tela
									  ""	} 															// Msg de Erro
	
If Len( HttpPost->PWSC120CLI ) <= 1
	HttpSession->PWSC120APH[3] := STR0002 //"Não há clientes a consultar."

	cHtml += ExecInPage( "PWSC121" )
ElseIf Len( HttpPost->PWSC120CLI ) = 2 
	HttpPost->CODCLIERP := HttpPost->PWSC120CLI[2][CLIENTERP_CODIGO]
	
	cHtml += W_PWSC121()
Else
	cHtml += ExecInPage( "PWSC120" )
EndIf

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------------------------
// Tela 02 : Seleção de Tarefas - Data De -> Data Ate
//-------------------------------------------------------------------------------------------------------------------------
Web Function PWSC121()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWSC121CLI := GetUserCli()

HttpSession->PWSC121APH := { STR0003, ; //"Gerenciamento de Tarefas - TAREFAS"
									  "W_PWSC122.APW", ;
									  "" }

cHtml := ExecInPage( "PWSC121" )

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------------------------
// Tela 02 : Seleção de Tarefas
//-------------------------------------------------------------------------------------------------------------------------
Web Function PWSC122()

Local oObj
Local cHtml := ""
Local nPosCli := 0

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWSC122CLI := GetUserCli()

HttpSession->PWSC122APH := { STR0003, ; //"Gerenciamento de Tarefas - TAREFAS"
							  "W_PWSC123.APW", ;
							  "" }

HttpSession->PWSC122INFO := { NIL, NIL }

If !Empty( HttpGet->CODCLIERP ) .OR. !Empty( HttpGet->DataDe ) .OR. !Empty( HttpGet->DataAte )
	HttpPost->CODCLIERP := HttpGet->CODCLIERP
	HttpPost->DataDe := HttpGet->DataDe
	HttpPost->DataAte := HttpGet->DataAte
EndIf

If !Empty( HttpPost->CODCLIERP )
	nPosCli := ascan( HttpPost->PWSC122CLI , { |x| x[CLIENTERP_CODIGO] == HttpPost->CODCLIERP } )
EndIf

If nPosCli > 0
	oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFTCUSTOMERTASK' ), WSFTCUSTOMERTASK():New() )
	WsChgUrl(@oObj,"FTCUSTOMERTASK.apw")
	
	If oObj:GETHEADER( "TASKVIEW" )
		HttpSession->PWSC122INFO[1] := oObj:oWSGETHEADERRESULT:oWSBRWHEADER
	EndIf
	
	If oObj:BRWTASK( MYUSERCODE, HttpPost->CODCLIERP, CToD( HttpPost->DataDe ), CToD( HttpPost->DataAte ) )
		HttpSession->PWSC122INFO[2] := oObj:oWSBRWTASKRESULT:oWSTASKVIEW
	EndIf
EndIf

If Empty( HttpSession->PWSC122INFO[2] )
	HttpSession->PWSC122APH[3] := PWSGetWSError()
EndIf

cHtml := ExecInPage( "PWSC122" )

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------------------------
// Tela 03 : Dados da Tarefa
//-------------------------------------------------------------------------------------------------------------------------
Web Function PWSC123()

Local cHtml := ""
Local oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFTCUSTOMERTASK' ), WSFTCUSTOMERTASK():New() )
Local nPosCli, nPosTar := 0
Local aWebCols := {}
Private aJsGrid := {}

WEB EXTENDED INIT cHtml START "InSite"
	
WsChgUrl(@oObj,"FTCUSTOMERTASK.apw")

HttpPost->PWSC123CLI := GetUserCli()
HttpSession->_TaskInfo := { { } }
HttpSession->PWSC123APH := { "", "", "" }

If !Empty( HttpGet->CODCLIERP ) .AND. !Empty( HttpGet->ACAO )
	HttpPost->CODCLIERP := HttpGet->CODCLIERP
	HttpPost->ACAO := HttpGet->ACAO
EndIf

If !Empty( HttpPost->CODCLIERP )
	nPosCli := ascan( HttpPost->PWSC123CLI , { |x| x[CLIENTERP_CODIGO] == HttpPost->CODCLIERP } )
EndIf

If !Empty( HttpPost->CODTASK )
	nPosTar := ascan( HttpSession->PWSC122INFO[2], { |x| x:cTASKID == HttpPost->CODTASK } )
EndIf

If Empty( HttpSession->PWSC123INFO )
	HttpSession->PWSC123INFO := { NIL, NIL }
EndIf

If Empty( HttpSession->PWSC123INFO[1] )
	If oObj:GETHEADER( "TASKVIEW" ) //1
		HttpSession->PWSC123INFO[1] := oObj:oWSGETHEADERRESULT:oWSBRWHEADER
	Else
		HttpSession->PWSC123APH[3] := PWSGetWSError()
	Endif
Endif

If HttpPost->ACAO == "I"
	HttpSession->PWSC123APH[1] := STR0003	//"Gerenciamento de Tarefas - TAREFAS"

	HttpSession->PWSC123INFO[2] := FTCUSTOMERTASK_TASKVIEW():New()
	
	HttpSession->PWSC123INFO[2]:dSTARTDATE := Date()
	HttpSession->PWSC123INFO[2]:dENDDATE := Date()
        
	If ExistBlock( "PEC123" )
		aWebCols := ExecBlock( "PEC123", .F., .F., {1} )
	Else
		aWebCols := {}
		aAdd( aWebCols, "SUBJECT" )
		aAdd( aWebCols, { "PRIORITY", "N", { "GETPRIORITY", ;
														{ "CPRIORITY", "CCODE" };
													}, ;
													{ "CCODE", "CDESCRIPTION" } } )
		aAdd( aWebCols, { "STATUSCODE", "D" } )	
		aAdd( aWebCols, "STARTDATE" )
		aAdd( aWebCols, "ENDDATE" )
		aAdd( aWebCols, "NOTE" )
	EndIf
  
	GridLinesEx( 	{ HttpSession->_TaskInfo[1],;
					HttpSession->PWSC123INFO[1], ;
					HttpSession->PWSC123INFO[2], ;
					aWebCols, .T., "H",,0 }, "FTCUSTOMERTASK", "AD8" )
	
	aadd( aJsGrid, GetJsGridLines() )
	
	cHtml += ExecInPage( "PWSC123" )
Else
	If nPosTar > 0
		HttpSession->PWSC123APH[1] := STR0008 + HttpSession->PWSC122INFO[2][nPosTar]:cSUBJECT //"Dados Tarefa : "
	
		If oObj:GETTASK( MYUSERCODE, HttpPost->CODCLIERP, HttpPost->CODTASK )
			HttpSession->PWSC123Info[2] := oObj:oWSGETTASKRESULT
		Else
			HttpSession->PWSC123APH[3] := PWSGetWSError()
		Endif
	Else
		HttpSession->PWSC123APH[3] := STR0004 //"ERRO PWSC040#001 : Tarefa Inválida"
	Endif
	
	If !Empty( HttpSession->PWSC123APH[3] )
		cHtml += ExecInPage( "PWSC122" )
	Else
		aWebCols := {}
		
	If ExistBlock( "PEC123" )
		aWebCols := ExecBlock( "PEC123", .F., .F., {2} )
	Else
		aWebCols := {}
		aAdd( aWebCols, "SUBJECT" )
		aAdd( aWebCols, { "PRIORITY", "N", { "GETPRIORITY", ;
															{ "CPRIORITY", "CCODE" };
														}, ;
														{ "CCODE", "CDESCRIPTION" } } )
		aAdd( aWebCols, "STATUSCODE" )
		aAdd( aWebCols, "STARTDATE" )
		aAdd( aWebCols, "ENDDATE" )
		aAdd( aWebCols, "NOTE" )
	EndIf
		      
		If HttpPost->ACAO == "A"
  
	
			GridLinesEx( { 	HttpSession->_TaskInfo[1],;
							HttpSession->PWSC123INFO[1],;
							HttpSession->PWSC123INFO[2],;
							aWebCols, .T., "H",, 0 }, "FTCUSTOMERTASK", "AD8" )
		ElseIf HttpPost->ACAO == "V"
	
			GridLinesEx( { 	HttpSession->_TaskInfo[1],;
							HttpSession->PWSC123INFO[1],;
							HttpSession->PWSC123INFO[2],;
							aWebCols, .F., "H",, 0 }, "FTCUSTOMERTASK", "AD8" )
		EndIf
		
		cHtml += ExecInPage( "PWSC123" )
	EndIf
EndIf
	
WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------------------------
// Tela 04 : Acao com a Tarefa
//-------------------------------------------------------------------------------------------------------------------------
Web Function PWSC124()

Local cHtml := ""
Local oObj := Nil
Local cTaskID := Nil

WEB EXTENDED INIT cHtml START "InSite"

If HttpPost->ACAO == "A"
	cTaskID := HttpSession->PWSC123INFO[2]:CTASKID
EndIf

PWSSetObjToPost( HttpSession->PWSC123INFO[2], HttpSession->PWSC123INFO[1], HttpPost->aPost )

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFTCUSTOMERTASK' ), WSFTCUSTOMERTASK():New() )
WsChgUrl(@oObj,"FTCUSTOMERTASK.apw")

If HttpPost->ACAO == "A"
	//cUSERCODE,cCUSTOMERID,oWSTASKVIEW
	oObj:cUSERCODE := MYUSERCODE
	oObj:cCUSTOMERID := HttpPost->CODCLIERP
	oObj:oWSTASK := HttpSession->PWSC123INFO[2]
	oObj:oWSTASK:CTASKID := cTaskID 
	If oObj:PUTTASK()
		Return PWSHTMLALERT( "", STR0005, STR0006, "W_PWSC120.APW" ) //"Aviso"###"Informações cadastradas com SUCESSO!"
	Else
		Return PWSHTMLALERT( "", STR0007, "", "W_PWSC123.APW?CODCLIERP=" + HttpPost->CODCLIERP + "&ACAO=" + HttpPost->ACAO ) //"Erro"
	EndIf
ElseIf HttpPost->ACAO == "I"
	//cUSERCODE,cCUSTOMERID,oWSTASKVIEW
	oObj:cUSERCODE := MYUSERCODE
	oObj:cCUSTOMERID := HttpPost->CODCLIERP
	oObj:oWSTASK := HttpSession->PWSC123INFO[2]
	
	oObj:oWSTASK:cSTATUSCODE := "1"
	
	If oObj:PUTTASK()
		Return PWSHTMLALERT( "", STR0005, STR0006, "W_PWSC120.APW" ) //"Aviso"###"Informações cadastradas com SUCESSO!"
	Else
		Return PWSHTMLALERT( "", STR0007, "", "W_PWSC123.APW?CODCLIERP=" + HttpPost->CODCLIERP + "&ACAO=" + HttpPost->ACAO ) //"Erro"
	EndIf
EndIf

cHtml := W_PWSC120()

WEB EXTENDED END

Return cHtml