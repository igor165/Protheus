#include "SIGAWF.CH"
#include "WF.CH"

/******************************************************************************
	WFOnStart
	Funcao especifica para executar o servico do scheduler no server do protheus atraves
	de um arquivo texto de configuracao.
	Parametros:
		cFile: Nome do arquivo texto que contem os parametros necessarios para inicializar o scheduler.
******************************************************************************/
function WFOnStart( __cEmpresa, __cFilial, __cAmbiente, __cReativar, __cModulos, __cMonitor )
	Local aParameters   	:= {}
	Local aParams       	:= {} 
	Local aParametros		:= {} 
	Local aThreads			:= GetUserInfoArray()  	 
	Local cParameters   	:= ""
	Local cSchedulerFile    := ""
	Local pcRotina			:= ""
	Local pcEmpresa        	:= ""
	Local pcFilial         	:= ""  
	Local nC				:= 0
	Local nThread			:= 0  
	Local lResult 			:= .F. 
	Local lExecutando		:= .F. 

	Default __cReativar 	:= "T"
	Default __cModulos		:= ""
	Default __cMonitor 		:= "F"
	
	__cReativar := Upper( Left( AsString( __cReativar ), 1 ) )
	
	If !( __cReativar $ "T|F" )
		__cReativar := "T"
	EndIf
	
	__cMonitor := Upper( Left( AsString( __cMonitor ), 1 ) )
	
	If !( __cMonitor $ "T|F" )
		__cMonitor := "T"
	EndIf

	__cModulos := AsString( __cModulos )
		
	If ( __cEmpresa == Nil .And. __cFilial == Nil .And. __cAmbiente == Nil )
		// -------------------------------------------------------- 
		// Define os parâmetros de execução default.  
		// -------------------------------------------------------- 
		__cEmpresa 	:= "99"
		__cFilial 	:= "01"
		__cAmbiente := "environment"   
		        
		// -------------------------------------------------------- 
		// Define a localização do arquivo scheduler.wf.  
		// -------------------------------------------------------- 
		cSchedulerFile := AllTrim( GetSrvProfString( "StartPath","\" ) )
		cSchedulerFile += if( Right( cSchedulerFile, 1 ) == "\", "", "\" )
		cSchedulerFile += "scheduler.wf"
       
		// -------------------------------------------------------- 
		// Cria o arquivo scheduler.wf caso ainda não exista.    
		// -------------------------------------------------------- 
		If ! ( File( cSchedulerFile ) )
			cParameters := __cEmpresa + "," + __cFilial + "," + __cAmbiente + "," + __cReativar + "," + __cModulos + "," + __cMonitor
			WFSaveFile( cSchedulerFile, cParameters )
		EndIf
         
		// -------------------------------------------------------- 
		// Recupera os parâmetros para execução do arquivo scheduler.wf  
		// -------------------------------------------------------- 
		If ( File( cSchedulerFile ) )
			cParameters := AllTrim( WFLoadFile( cSchedulerFile ) )
			cParameters := StrTran( cParameters, chr(13), "" )
			cParameters := StrTran( cParameters, chr(10), "" )
			aParameters := WFTokenChar( cParameters, ";" )

			For nC := 1 to Len( aParameters )
				aParams := WFTokenChar( aParameters[ nC ], "," )  
				   
				// -------------------------------------------------------- 
				// Recupera os parâmetros para execução.  
				// -------------------------------------------------------- 
			    __cEmpresa	:= If( Len( aParams ) >= 1, aParams[1], __cEmpresa )
				__cFilial   := If( Len( aParams ) >= 2, aParams[2], __cFilial )     
				__cAmbiente := If( Len( aParams ) >= 3, aParams[3], __cAmbiente )
				__cReativar := If( Len( aParams ) >= 4, aParams[4], __cReativar )
				__cModulos  := If( Len( aParams ) >= 5, aParams[5], __cModulos )
				__cMonitor  := If( Len( aParams ) >= 6, aParams[6], __cMonitor )				
	
				// -------------------------------------------------------- 
				// Verifica se o scheduler já está sendo executado para uma 
				// empresa e filial. 
				// --------------------------------------------------------     
				For nThread := 1 To Len( aThreads )
					aParametros := WFTokenChar( aThreads[nThread][11], "|" ) 
				  
				 	If ( Len( aParametros ) >= 3 ) 
				 		pcRotina 	:= aParametros[1]
				 		pcEmpresa 	:= aParametros[2]
				 		pcFilial	:= aParametros[3]  
				 		
				 		If ( AllTrim( pcRotina ) == "WFScheduler";
			 				.And. AllTrim( pcEmpresa ) == AllTrim( __cEmpresa );
			 			 	.And. AllTrim( pcFilial ) == AllTrim( __cFilial ) ) 
				 			 	lExecutando := .T. 
				 			 	Exit		 		     
				 		EndIf
				 	EndIf  
				Next nThread
				
  		       	// -------------------------------------------------------- 
				// Inicia o scheduler para a empresa e filial. 
				// -------------------------------------------------------- 
		      	If ! ( lExecutando ) 			
	   				StartJob( "WFLauncher", __cAmbiente, .F., { "WFScheduler", { __cEmpresa, __cFilial, __cReativar, __cModulos, __cMonitor } } ) 
			 	EndIf 						
			Next
		End
	Else  
		// -------------------------------------------------------- 
		// Verifica se o scheduler já está sendo executado para uma 
		// empresa e filial. 
		// --------------------------------------------------------       
		For nThread := 1 To Len( aThreads )
			aParametros := WFTokenChar( aThreads[nThread][11], "|" ) 
		  
		 	If ( Len( aParametros ) >= 3 ) 
		 		pcRotina 	:= aParametros[1]
		 		pcEmpresa 	:= aParametros[2]
		 		pcFilial	:= aParametros[3]  
		 		
		 		If ( AllTrim( pcRotina ) == "WFScheduler";
	 				.And. AllTrim( pcEmpresa ) == AllTrim( __cEmpresa );
	 			 	.And. AllTrim( pcFilial ) == AllTrim( __cFilial ) ) 
		 			 	lExecutando := .T. 
		 			 	Exit		 		     
		 		EndIf
		 	EndIf  
		Next nThread
		
  		// -------------------------------------------------------- 
		// Inicia o scheduler para a empresa e filial. 
		// --------------------------------------------------------      
      	If ! ( lExecutando ) 			
	   		StartJob( "WFLauncher", __cAmbiente, .F., { "WFScheduler", { __cEmpresa, __cFilial, __cReativar, __cModulos, __cMonitor } } ) 
	 	EndIf 
	EndIf
Return lResult

function WFGetModulo( cEmp, cFil )
	Local nC		:= 0
	Local aSched1 	:= {}
	Local aSched2 	:= {}
	Local cFile 	:= ""
	Local cPath 	:= ""
	Local cSched 	:= ""
	Local cMod 		:= ""
	
	default cEmp := cEmpAnt, cFil := cFilAnt

	cPath := AllTrim( GetSrvProfString( "StartPath", "\" ) )
	cPath += if( Right( cPath, 1 ) == "\", "", "\" )
	cFile := cPath + "scheduler.wf"

	if File( cFile )
		if !empty( cSched := AllTrim( WFLoadFile( cFile ) ) )
			cSched := StrTran( cSched, chr(13) + chr(10), "" )
			aSched1 := WFTokenChar( cSched, ";" )
			for nC := 1 to Len( aSched1 )
				if len( aSched2 := WFTokenChar( aSched1[nC], "," ) ) >= 5
					if ( upper( alltrim( aSched2[1] ) ) == upper( alltrim( cEmp ) ) ) .and. ;
						( upper( alltrim( aSched2[2] ) ) == upper( alltrim( cFil ) ) ) .and. ;
						( upper( alltrim( aSched2[3] ) ) == upper( alltrim( GetEnvServer() ) ) )
						cMod := aSched2[5]
					endif
				endif
			next
		endif
	endif
return cMod

/******************************************************************************
	WFStart( <aParams> )
	Funcao especifica para executar o servico do scheduler no server do protheus sem o uso
	de um arquivo de configuracao.
	Parametros:
		aParams: (<cEmpresa>, <cFilial> )
******************************************************************************/
Function WFStart( aParams )
	local lResult := .F.
	
	default aParams := {}
	
	if Len( aParams ) >= 2
		if Len( aParams ) < 3
			AAdd( aParams, "T" )
		endif
		StartJob( "WFLauncher", GetEnvServer(), .F., { "WFScheduler", { aParams[1], aParams[2], aParams[3] } } )
		lResult := .T.
	endif
return lResult

/******************************************************************************
	WFReaddMail
	Rotina especifica para recebimento de mensagens do workflow
	Parametros:
		aParams: { <cEmpresa>, <cFilial> }
******************************************************************************/
Procedure WFReadMail( aParams, lDebug )
	if aParams <> nil
		if lDebug
			WFJobRcvMail( aParams )
		else
			StartJob( "WFLauncher", GetEnvServer(), .F., { "WFJobRcvMail", aParams } )
		endif
	endif
return

/******************************************************************************
	WFJobRcvMail
	Complemento da funcao WFReadMail para execucao via job
	Parametros:
		aParams: { <cEmpresa>, <cFilial> }
******************************************************************************/
Procedure WFJobRcvMail( aParams )
	local nFile
	local oMail
	local oMailBox
	local cMailBox
	local cLCKFile := "\semaforo"
	local cMsg
	
	default aParams := {}
	
	if len( aParams ) == 0
		return
	endIf
	
	cLCKFile += lower( "\wfreceivemail" + aParams[1] + ".lck" )

	if ( nFile := FCreate( cLCKFile, FC_NORMAL ) ) <> -1
		cMsg := "Thread ID: " + alltrim( str( ThreadID() ) ) + " - Data: " + DtoC( MsDate() ) + " - Hora: " + Time()
		FWrite( nFile, cMsg, Len( cMsg ) )

		oMail := TWFMail():New( aParams )
		cMailBox := AllTrim( WFGetMV( "MV_WFMLBOX", "" ) )
		oMailBox := oMail:GetMailBox( cMailBox )
	
		oMailBox:Receive()
		
		FClose( nFile )
		FErase( cLCKFile )
	else
		if FindFunction('U_WFPE006')
			StartJob( "WFLauncher", GetEnvServer(), .F., { "U_WFPE006",	aParams } )
		endif
	endIf
return


/******************************************************************************
	WFSendMail
	Rotina especifica para envio de mensagens do workflow
	Parametros:
		aParams: { <cEmpresa>, <cFilial> } - Parâmetros de conexão
		lDebug - Define se está executando a função em modo debug
		cFila - Nome da fila que está sendo processada
******************************************************************************/
Procedure WFSendMail( aParams, lDebug, cFila )
	Default aParams 	:= { cEmpAnt, cFilAnt }
	Default lDebug 	:= .F.
	Default cFila 	:= ""

	If ! ( aParams == Nil )
		//Identifica se está sendo executado pelo novo schedule. 
		If ( Len( aParams ) >= 4 )
			//Ignora os parâmetros __cUserID e uIdTask passados pelo schedule. 
			aParams := { aParams[1], aParams[2] }	
		EndIf 

		If ! Empty( cFila )
			AAdd( aParams, Alltrim( cFila ) )
		EndIf
		
		if lDebug
			WFJobSndMail( aParams )
		else
			StartJob( "WFLauncher", GetEnvServer(), .F., { "WFJobSndMail", aParams } )
		endif
	endif
return

/******************************************************************************
	WFJobSndMail
	Complemento da funcao WFSendMail para execucao via job
	Parametros:
		aParams:
			[1] - <cEmpresa> - Empresa utilizada na conexão
			[2] - <cFilial> - Filial para conexão
			[3] - [<cFila>] - opcional - Nome da fila que está sendo processada
******************************************************************************/
Procedure WFJobSndMail( aParams )
	local nFile
	local oMail
	local oMailBox
	local cMailBox
	local cLCKFile := "\semaforo"
	local cMsg
	local cFila		:= ""
	
	default aParams := {}
	
	if len( aParams ) == 0
		return
	endIf
	
	// O sistema está utilizando as filas para envio de email.
	If Len(aParams) > 2
		cFila := aParams[3]
	EndIf 

	If Empty(cFila)
		cLCKFile += lower( "\wfsendmail" + aParams[1] + ".lck" )
	Else
		cLCKFile += lower( "\wfsendmail" + aParams[1] + Alltrim(lower( cFila )) + ".lck" )
	EndIf

	if ( nFile := FCreate( cLCKFile, FC_NORMAL ) ) <> -1
		cMsg := "Thread ID: " + alltrim( str( ThreadID() ) ) + " - Data: " + DtoC( MsDate() ) + " - Hora: " + Time()
		FWrite( nFile, cMsg, Len( cMsg ) )

		oMail := TWFMail():New( aParams )
		If Empty(cFila)
			cMailBox := AllTrim( WFGetMV( "MV_WFMLBOX", "" ) )
		Else
			Dbselectarea( "WFQ" )
			WFQ->( dbSetOrder( 1 ) )
			If DbSeek(xFilial( "WFQ" ) + Alltrim(Upper( cFila )))
				cMailBox := WFQ_EMAIL
			Else
				cMailBox := AllTrim( WFGetMV( "MV_WFMLBOX", "" ) )
			EndIf
		EndIf

		oMailBox := oMail:GetMailBox( cMailBox )
		oMailBox:Send( , cFila )
		
		FClose( nFile )
		FErase( cLCKFile )
	else
		if FindFunction('U_WFPE005')
			StartJob( "WFLauncher", GetEnvServer(), .F., { "U_WFPE005",	aParams } )
		endif
	endIf
return

/******************************************************************************
	WFAfterSend
	Complemento da funcao WFJobSndMail. Envento ocorrido apos o envio da mensagem.
	Parametros:
		oMsg: Objeto mensagem (tmailmessage).
******************************************************************************/
Procedure WFAfterSend( oMsg, pcMailID, pcEmp, pcFil )
	local cMailID := pcMailID
	
	if( oMsg <> NIL)  
		if !empty( cMailID := oMsg:GetCustomHeader( "X-" + EH_MAILID + ":" ) )
			dbSelectArea( "WFA" )
			if dbSeek( xFilial( "WFA" ) + WF_OUTBOX + cMailID )
				if RecLock( "WFA", .F. )
					WFA_TIPO := WF_SENT
					MsUnLock()
				EndIf
			EndIf
		EndIf	
	Else		   		
		if!empty(cMailID) //Sera utilizado caso o email for mandado por uma fila de envio de email
			WFPREPENV(pcEmp,pcFil)
	       	dbSelectArea( "WFA" )
		   	if dbSeek( xFilial( "WFA" ) + WF_OUTBOX + cMailID )
				if RecLock( "WFA", .F. )
			      	WFA_TIPO := WF_SENT
				  	MsUnLock()
				EndIf
		   	EndIf  
	    EndIf		   		
   EndIf 
return

/******************************************************************************
	WFLauncher( <aParams> )
	Funcao especifica para tratamento de licenca do protheus na execucao de jobs pelo workflow
	Parametros:
		aParams: { <cNome da funcao>, { <array de parametros>, <...>,... } ) }
******************************************************************************/
Function WFLauncher( aParams, cFWlog, uIdTask)
	local nPos
	local hLCKFile
	local cFunct
	local lResult 	:= .F.
	local oSXMTable
	// Verifica se a chave "RegionalLanguage" foi informada no ambiente
	Local cAux		:= GetPvProfString(GetEnvServer(),"REGIONALLANGUAGE","",GetAdv97())
	Local oFwLog
	
	If cFWlog <> Nil .And. !Empty(cFWlog)
		oFwLog := FWGetLogObj('SCHEDULE','JOBEXECUTING')
		oFwLog:Deserializer(cFWlog)
	EndIf
	
	// Força a atualização do cPaisLoc caso a chave tenha sido modificada no INI
	If !Empty(cAux)
		Public cPaisLoc := cAux
	EndIf

	// Determina o cPaisLoc se ainda não foi preenchido
	If Type("cPaisloc") == "U"
		Public cPaisLoc := "BRA"	
	EndIf
	
	if aParams <> nil
		SetsDefault()
		if FindFunction( "RPCSetType" ) 
			RPCSetType( WF_RPCSETTYPE )
		endif
		
		if !empty( cFunct := AllTrim( aParams[1] ) )
			if ( nPos := At( "(", cFunct ) ) > 0
				if nPos > 1
					cFunct := Left( cFunct, nPos - 1 )
				else
					cFunct := ""
				endif
			endif
			
			if ( nPos := At( ")", cFunct ) ) > 0
				if nPos > 1
					cFunct := Left( cFunct, nPos - 1 )
				else
					cFunct := ""
				endif
			endif
			
			if !empty( cFunct )
				cFunct += "("
				if Len( aParams ) > 1
					cFunct += AsString( aParams[ 2 ], .T. )
				endif	
				cFunct += ")" 
				
				// Verifica se os parâmetros foram passados para atualizar os dados de execução no Monitor.
				If Empty(aParams[2])
					ptInternal( 1, STR0001 + aParams[ 1 ] ) //"Executando: " 
				Else
					ptInternal( 1, cBIStr( aParams[1] ) + "|" + cBIStr( aParams[2][1] ) + "|" + cBIStr( aParams[2][2] ) ) 
				EndIf
				
				if Len( aParams ) > 2
					oSXMTable := TWFSXMObj( "sxm" + aParams[3] + "0" + GetDbExtension(), "SXM" )
					
					if oSXMTable:lOpen()
						if Len( aParams ) > 3
							oSXMTable:lGoto( aParams[ 4 ] )
							
							if oSXMTable:nValue( "XM_NUMTENT" ) > 0 .and. oSXMTable:xValue( "XM_TENTEXE" ) > 0
								oSXMTable:lUpdate( { { "XM_TENTEXE", oSXMTable:xValue( "XM_TENTEXE" ) - 1 } } )
							elseif oSXMTable:nValue( "XM_NUMTENT" ) > 0 .and. oSXMTable:xValue( "XM_TENTEXE" ) > 0
								oSXMTable:lUpdate( { { "XM_TENTEXE", oSXMTable:xValue( "XM_NUMTENT" ) - 1 } } )
							endif
						endif		
					
						if Len( aParams ) > 4 
							WFForceDir( ExtractPath( aParams[ 5 ] ) )
							
							if ( hLCKFile := WFCreate( aParams[ 5 ], FC_NORMAL ) ) == -1
								return lResult
							endif
						
							WFClose( hLCKFile )
						
							if ( hLCKFile := WFOpen( aParams[ 5 ], FO_READWRITE + FO_EXCLUSIVE ) ) == -1
								return lResult
							endif
						endif
						oSXMTable:lClose()	
					endif
				endif

				&( cFunct )

				If cFWlog <> Nil .And. !Empty(cFWlog)
					//SCHD0017
					oFwLog:SetStep('END')
					oFWlog:Warn(I18n("Execução da tarefa #1 finalizada.",{uIDTask}),,,.T.)
				EndIf

				if Len( aParams ) > 2
					if oSXMTable:lOpen()
						if Len( aParams ) > 3
							oSXMTable:lGoto( aParams[ 4 ] )
							oSXMTable:lUpdate( { { "XM_TENTEXE", oSXMTable:nValue( "XM_NUMTENT" ) } } )
						endif
						oSXMTable:lClose()
					endif

					if Len( aParams ) > 4
						WFClose( hLCKFile )				
					endif					
				endif				
				lResult := .T.
			endif
		endif
	endif
Return lResult
