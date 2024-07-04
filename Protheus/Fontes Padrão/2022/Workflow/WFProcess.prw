#INCLUDE "WFProcess.ch"
#include "SigaWF.ch"
	

/*
*--------------------------------------------------------------------------------------*
| Projeto ..: SIGAWF - Siga Workflow - Versão AP5                                      |
| Módulo ...: Process - Montagem e Manipulação de processos de workflow                |
| Programa .: WFProcess - Gerencia de montagem e manipulacao de processos workflow     |
*--------------------------------------------------------------------------------------*
| Observações/Comentários                                                              |
*----------*----------------------*----------------------------------------------------*
* Versao   | Autor                | Descrição                                          |
*----------+----------------------+----------------------------------------------------*
*   00     | Alan Candido         | Implementação                                      |
*----------+----------------------+----------------------------------------------------*
* 16/04/09 | Alan Cândido - 0548  | FNC 0000009475/2009                                |
*          |                      | Implementação de opção para remover anexos após o  |
*          |                      | envio do e-mail no método AttachFile.              |
*----------+----------------------+----------------------------------------------------*
*/

// *--< Definições de uso geral >---------------------------------------------------*
#define _TASK 1

/*
*#############################################################*
| TWFProcess                                                  |
*=============================================================*
| Implementação da classe                                     |
*-------------------------------------------------------------*
*/
class TWFProcess   
	data oWF
	data oHTML
	data oSched
	data FProcessID
	data FProcCode
	data FTask
	data FTaskID
	data nTaskID
	data aParams
	data aPropertyList
	data cTask 
	data cHtmlFile
	data cFromName
	data cFromAddr
	data cTo
	data cToOrig
	data cRetFrom
	data cCc
	data cBCc
	data cSubject
	data cBody
	data cClientName
	data cPriority
	data bReturn
	data bTimeout
	data FDesc
	data aAttFiles
	data aDelFiles
	data UserSiga			
	data lTimeOut
	data cVersion
	data nEncodeMime
	data dNextTOut
	data tNextTOut

	method New( pcCodigo, pcDescricao, pcReferencia ) constructor
	method Load( pcCodigo )
	method NewTask( cDesc, cHtmlFile, lLastHtml )
	method HtmlFile( cHtmlFile, cMailID )	
	method SetHtmlBody( lBody )
	method LogEvent( nEventID, cText ) 
	method ChkEvent( nEventID )
	method ExtHttpAddr()
	method SaveObj( aObjList )
	method LoadObj( aObjList )
	method Exec( cHTMLCopyTo, lDebug )
	method Start( cHTMLCopyTo, lDebug )
	method Finish( cText )
	method AttachFile( cFileName, alDelete ) 
	method ClientName(AUser)
	method NewVersion(lActive)
	method AddTimeOuts( cMailID )
	method InitObj(AObjName)
	method Free() 
	method Track( cStatusCode, cDescription, cUserName, uShape )
	method VisioTrack( uShape, cStatusCode )
	method LoadOctFile( cFileName )
	method SaveValFile( cValFile )
endclass

//*--< Construtor >------------------------------------------------------------------*
method New( pcCodigo, pcDescricao, pcReferencia ) class TWFProcess
	Local cLastAlias 	 	:= Alias()
	
	Default pcCodigo 	 	:= ''
	Default pcDescricao  	:= ''
	Default pcReferencia 	:= ''  

	::aPropertyList 	:= { "FProcessID", "FProcCode", "FTask", "FTaskID", "nTaskID", "cTask","aParams", "cTo", "cCc", "cBCc", "cSubject", "cBody", "cClientName", "bReturn", "bTimeout", "aAttFiles", "aDelFiles", "cHtmlFile", "oHTML" }
	::oWF 				:= TWFObj( { cEmpAnt, cFilAnt } )
	::cVersion 			:= SIGAWF_2_0
	::aAttFiles 		:= {}
	::aDelFiles 		:= {}
	::bTimeout 			:= {}
	::lTimeOut 			:= .F.
	::cRetFrom 			:= ''
	::cPriority 		:= MSGP_NORMAL
	::cHtmlFile 		:= ''
	::dNextTOut 		:= CToD( "/" )
	::tNextTOut 		:= ''
	::nEncodeMime 		:= 2
	::FDesc 			:= AsString( pcDescricao )

	// Força a criação da tabela SXM 
	TWFSchedObj( { cEmpAnt, cFilAnt } )

	If ( Empty( AllTrim( pcDescricao ) ) ) 
		DbSelectArea( "WF1" )
		DbSetOrder( 1 )
		
		If DbSeek( xFilial( "WF1" ) + pcCodigo )
			pcDescricao := AllTrim( WF1_DESCR )
		EndIf
	EndIf
	
	If ( Empty ( AllTrim( pcReferencia ) ) ) 	
		::nTaskID 		:= 0      
		::FTaskID 		:= int2Hex( ::nTaskID, 2 )
		::FProcessID 	:= Lower( cBIStr( int2Hex( WFGetNum( "MV_WFPROCI" ), WF_PROC_ID_LEN ) ) )    
		::FProcCode 	:= pcCodigo
		::cTask 		:= ""
		::aParams 		:= {} 
		::LogEvent( EV_NEWPROC )
  	Else
  		::Load( pcReferencia )
		::LogEvent( EV_INITPROC, "[" + pcCodigo + "] " )
  	EndIf

	If ! ( Empty( cLastAlias ) )
		DBSelectArea( cLastAlias )
	End
Return SELF

//*--< Metodo NewTask - Inicializa nova tarefa no projeto >--------------------------*
method NewTask( cDesc, cHtmlFile, lPreserv ) class TWFProcess 
 	Local aValues 		:= {}
	Local lResult 		:= .F.

	Default cHtmlFile 	:= ""
	Default cDesc 		:= ""
	Default lPreserv 	:= .F.
	
	If ( lPreserv .And. ( ::oHtml <> NIL ) )
		::oHtml:SaveVal( aValues )
	EndIf
	
	::HtmlFile( cHtmlFile )
	::lTimeOut 	:= .F.
	::FTask 	:= cDesc  	 
	::nTaskID 	++ 
	::FTaskID 	:= int2Hex( ::nTaskID, 2 )
	::bReturn 	:= ""
	::bTimeout 	:= {}
	::LogEvent( EV_NEWTASK, "[" + ::FTask + "] " )
		
	If ( Len( aValues ) > 0 )
		::oHtml:LoadVal( aValues )
	End	
Return lResult

//*--< Propriedade HtmlFile >---------------------------------------------------------*
method HtmlFile( cFileName ) class TWFProcess
	Local lResult 		:= .F.
	
	default cFileName 	:= "" 
	
	cFileName := lower( cFileName )
	
	If ( lResult :=  file( cFileName ) )
		::cHtmlFile := cFileName     
		
		If ( ::oHtml <> NIL )
			::oHtml:LoadFile( ::cHtmlFile )
		Else
			::oHtml := TWFHtml():New( ::cHtmlFile, SELF )
		EndIf
	EndIf
Return lResult

method SetHtmlBody( lBody ) class TWFProcess
	local lResult := ::oWF:lHtmlBody  
	
	If ( lBody <> NIL )
		lResult := ( ::oWF:lHtmlBody := lBody )
	EndIf
return lResult
  
//*--< Libera a classe >-------------------------------------------------------------*
method Free() class TWFProcess
	If ( ::oHTML != NIL ) 
		::oHTML:Free()
		::oHTML := NIL
	EndIf
return

//*--< Metodo Start - Inicia a execução da tarefa >----------------------------------*
method Start( cHTMLCopyTo, lDebug ) class TWFProcess 
   	local cID 			:= ''
	local cLastAlias 	:= alias() 
	
	cID := ::Exec( cHTMLCopyTo, lDebug )
						
	if !Empty( cLastAlias )
		dbSelectArea( cLastAlias )
	end
return cID

//*--< Metodo Finish - Registra o fim do processo >-----------------------------------*
method Finish( cText ) class TWFProcess 
	::LogEvent( EV_FINISH, cText )
return             

// *--< Metodo Log - Log de eventos >-----------------------------------------------*
method LogEvent( nEventCode, cText ) class TWFProcess
	Local cResult 		:= ""
	Local cFindKey      := ""
	Local cLastAlias 	:= Alias()
	
	Default cText 		:= ""
	                 
	DBSelectArea( "WF3" )
	DBSetOrder(1)
	
	cFindKey := xFilial("WF3") + Lower( Pad( ::FProcessID + "." + ::FTaskID, WF_KEY_PROC_LEN ) + strZero( nEventCode,6 ) )

	If ! ( DBSeek( cFindKey ) )
		cResult := WFLogEvent( nEventCode, cText, asString( ::FProcessID ), asString( ::FTaskID ) )  
		
		If RecLock( "WF3",.T. )
			WF3_FILIAL		:= xFilial( "WF3" )
			WF3_ID			:= Lower( AsString( ::FProcessID ) + "." + AsString( ::FTaskID ) )
			WF3_PROC		:= ::FProcCode
			WF3_STATUS		:= StrZero( nEventCode,6 )
			WF3_HORA		:= Time()
			WF3_DATA		:= Date()
			WF3_DESC		:= cResult
			MSUnlock("WF3")
		EndIf
	EndIf
	
	If ! ( Empty( cLastAlias ) )
		dbSelectArea( cLastAlias )
	End
return cResult

// *--< Metodo VerLog - Verifica se determinado evento ocorreu >-----------------------------*
method ChkEvent( nEventID ) class TWFProcess
Return WFChkProcEvent( ::FProcessID, ::FTaskID, nEventID )

// *--< Propriedade ClientName >----------------------------------------------------*
method ClientName(AUser) class TWFProcess           
	If ( AUser == NIL )
		return ::cClientName
	Else
		::cClientName := AUser
	Endif
return

method AddTimeOuts( cMailID ) class TWFProcess 
	Local dDate
	Local nC            := 0
	Local nHH           := 0
	Local nMM        	:= 0
	Local nLen 			:= 1
	Local aFields       := {}
	Local aTasks 		:= {}
	Local aTimeOutID 	:= {}
	Local cTime         := ''
	Local cNow 			:= Left( time(),5 )
	Local cTimeOutID   	:= ''
	
	If ( Len( ::bTimeOut ) == 0 )
		Return aTimeOuts
	End
	
	If ( ValType( ::bTimeOut[1] ) == "A" )
		nLen := Len( ::bTimeOut )
	end
	
	For nC := 1 to nLen
		If ( ValType( ::bTimeOut[ nC ] ) == "A" )
			dDate := MsDate() + ::bTimeOut[ nC,2 ]
			nHH := val( left( cNow,2 ) ) + Min( Int( ::bTimeOut[ nC,3 ] ), 23 )
			nMM := val( right( cNow,2 ) ) + Min( Int( ::bTimeOut[ nC,4 ] ), 59 )
		Else
			dDate := MsDate() + ::bTimeOut[ 2 ]
			nHH := val( left( cNow,2 ) ) + Min( Int( ::bTimeOut[ 3 ] ), 23 )
			nMM := val( right( cNow,2 ) ) + Min( Int( ::bTimeOut[ 4 ] ), 59 )
		EndIf 
		
		If ( nMM > 59 )
			nHH++
			nMM := nMM - 60
		EndIf 
		
		While ( nHH > 23 )
			dDate++
			nHH := nHH - 24
		end  
		
		cTime := strZero(nHH,2) + ":" + strZero(nMM,2)  
		
		If ( nC == 1 )
			::dNextTOut := dDate
			::tNextTOut := cTime
		EndIf
		
		cTimeOutID := Int2Hex( WFGetNum( "MV_WFXMID" ),6 )
		
		AAdd( aTimeOutID, cTimeOutID )
		
		aFields := {}
		AAdd( aFields, { "XM_FILIAL", xFilial( "SXM" ) } )
		AAdd( aFields, { "XM_CODIGO", cMailID } )
		AAdd( aFields, { "XM_NOME", cMailID } )
		AAdd( aFields, { "XM_DESCR", "Rotina 'timeout' SigaWF" } )
		AAdd( aFields, { "XM_TIPO", 4 } )
		AAdd( aFields, { "XM_DTINI", dDate } )
		AAdd( aFields, { "XM_HRINI", cTime } )
		AAdd( aFields, { "XM_DTFIM", dDate } )
		AAdd( aFields, { "XM_HRFIM", cTime } )
		AAdd( aFields, { "XM_INTERV", "00:00" } )
		AAdd( aFields, { "XM_SEMANA", "" } )
		AAdd( aFields, { "XM_MENSAL", "" } )
		AAdd( aFields, { "XM_DTPROX", dDate } )
		AAdd( aFields, { "XM_HRPROX", cTime } )
		AAdd( aFields, { "XM_AMBIENT", GetEnvServer() } )
		AAdd( aFields, { "XM_ACAO", "WFTimeOut(" + asString( cEmpAnt,.t. ) + "," + asString(cFilAnt,.t.) + "," + asString( cMailID, .t.) +","+asString( nC,.t. ) + ")" } )
		AAdd( aFields, { "XM_ATIVO", "T" } )
		AAdd( aFields, { "XM_TIMEOUT", "T" } )
		AAdd( aFields, { "XM_ID", cTimeOutID } ) 
		
		AAdd( aTasks, aFields )
	next
	
	::oWF:oScheduler:SaveTasks( aTasks )
Return aTimeOutID
	
//*--< Metodo Exec - Executa a tarefa >----------------------------------------------*
method Exec( cHTMLCopyTo, lDebug ) class TWFProcess
   	Local nC            := 0
   	Local nPos        	:= 0
	Local oMail 		:= TWFMail():New()
	Local cMailBox 		:= ::oWF:cMailBox
	Local oMailBox 		:= oMail:GetMailBox( cMailBox )
	Local cMailID   	:= ''
	Local cHTMLFile 	:= ''
	Local cValFile		:= ''
	Local cBuffer		:= ''
	Local cCIDFile		:= ''
	Local aHeaders		:= {}
	Local aHttpAddress 	:= {}
	Local aRecNoTimeout := {} 
	Local lUseQueues	:=.F.
	Local aQueues:={}
	Local nIndexOfTheSmallerQueue:=0  
	Local oSmallerQueue:=NIL
	
	Default lDebug 		:= .F.

	cMailID 			:= Lower( ::oWF:NewMailID( ::FProcessID + ::FTaskID ) )
	cHTMLFile 			:= ::oWF:cTempDir + cMailID + ".htm"
	cValFile  			:= ::oWF:cProcessDir + cMailID + ".val"

	If !( ::lTimeOut ) .and. len( ::bTimeout ) > 0
		aRecNoTimeOut := ::AddTimeOuts( cMailID )
	EndIf

	::LogEvent( EV_RUNTASK )
	
	aHeaders := {}
	AAdd( aHeaders, { "X-" + EH_PROCID, ::FProcessID } )
	AAdd( aHeaders, { "X-" + EH_TASKID, ::FTaskID } )
	AAdd( aHeaders, { "X-" + EH_MAILID, cMailID } )
	AAdd( aHeaders, { "X-" + EH_SIGAWF, "2.0" } )
	AAdd( aHeaders, { "X-" + EH_ENCODEMIME, AllTrim( Str( ::nEncodeMime ) ) } )
	AAdd( aHeaders, { "X-Priority", ::cPriority } )

	//-------------------------------------------------------------------
	// Verifica se é para ser gerada a tag X-MSMail-Priority.
	//-------------------------------------------------------------------
	If ( ::cPriority != MSGP_NONE )
		Do Case
			Case ::cPriority == MSGP_HIGH
				AAdd( aHeaders, { "X-MSMail-Priority", "High" } )
			Case ::cPriority == MSGP_NORMAL
				AAdd( aHeaders, { "X-MSMail-Priority", "Normal" } )
			Case ::cPriority == MSGP_LOW
				AAdd( aHeaders, { "X-MSMail-Priority", "Low" } )
		EndCase
	EndIf
	
	If ( ::oHTML <> Nil )
		::oHTML:cVersion := ::cVersion
		::oHTML:ValByName( EH_MAILID, "WF" + cMailID )
		::oHTML:ValByName( EH_RECNOTIMEOUT, asString( aRecNoTimeout, .t. ) )
		::oHTML:ValByName( EH_EMPRESA, cEmpAnt )
		::oHTML:ValByName( EH_FILIAL, cFilAnt )

		If ( Len( ::oHTML:aAttCID ) > 0 .and. ::oWF:lAttachImg )
			For nC := 1 To Len( ::oHTML:aAttCID )
				If !Empty( cCIDFile := StrTran( ::oHTML:aAttCID[nC,1], "/", "\" ) )
					If ( File( cCIDFile ) )
						::AttachFile( { cCIDFile, "Context-ID: " + ::oHTML:aAttCID[nC,2] } )
					EndIf
				EndIf
			Next
		EndIf

		::oHTML:SaveFile( cHTMLFile )
		
		If ( File( cHTMLFile ) )		
			If ( ::oWF:lHtmlBody )
				::cBody := ""
			Else
				::AttachFile( cHTMLFile )
			EndIf
			
			If ( cHTMLCopyTo <> NIL )
				cHTMLCopyTo := AllTrim( cHTMLCopyTo )
				WFForceDir( cHTMLCopyTo ) 
				
				If !( Right( cHTMLCopyTo, 1 ) == "\" )
					cHTMLCopyTo += "\"
				EndIf
				WFSaveFile( Lower( cHTMLCopyTo + cMailID + ".htm" ), WFLoadFile( cHTMLFile ) )
			EndIf			
		EndIf
	EndIf
	
	::cTo 	:= WFGetAddress( ::cTo 	:= AllTrim( WFCleanStr(::cTo )))
	::cCC 	:= WFGetAddress( ::cCC 	:= AllTrim( WFCleanStr(::cCC )))
	::cBCC	:= WFGetAddress( ::cBCC	:= AllTrim( WFCleanStr(::cBCC)))
	
	ChkFile( "WF6" )
	dbSelectArea( "WF6" )
   
	if ( Len( aHttpAddress := ::ExtHttpAddr() ) > 0 ) .and. ( Select( "SX6" ) > 0 )
		if ( File( cHTMLFile ) )
			cBuffer := WFLoadFile( cHTMLFile )
			
			if ( nPos := At( "MAILTO:", Upper( cBuffer ) ) ) > 0
				cMailToAddress := SubStr( cBuffer, nPos, 7 )
				
				While ( Empty( SubStr( cBuffer, nPos +7, 1 ) ) )
					cMailToAddress += " "
					nPos++
				end
				
				cBuffer := SubStr( cBuffer, nPos +7 )
				
				If ( nPos := At( " ", cBuffer ) ) > 0
					cMailToAddress += AllTrim( Left( cBuffer, nPos -1 ) )
					
					If Right( cMailToAddress,1 ) == '"'
						cMailToAddress := Left( cMailToAddress, Len( cMailToAddress ) -1 )
					EndIf
				EndIf
				
				If ! ( Empty( cMailToAddress ) )
					cBuffer := WFLoadFile( cHTMLFile )
					
					If ( nPos := At( cMailToAddress, cBuffer ) ) > 0
						If ( WFGetMV( "MV_WFWEBEX", .F. ) )
							cBuffer := Stuff( cBuffer, nPos, Len( cMailToAddress ), "WFHTTPRET.APW" )
						else
							cBuffer := Stuff( cBuffer, nPos, Len( cMailToAddress ), "WFHTTPRET.APL" )
						EndIf
					
						For nC := 1 to len( aHttpAddress )
							WFForceDir( ::oWF:cMessengerDir + aHttpAddress[ nC ] )
				 			WFSaveFile( ::oWF:cMessengerDir + aHttpAddress[ nC ] + "\" + cMailID + ".htm", cBuffer )
						           
							WFConout( "WFHTTP Folder: " + aHttpAddress[ nC ] ,,,,.T.,"WFPROCESS" )  
							WFConout( "WFHTTP HTML  : " + cMailID + ".htm" ,,,,.T.,"WFPROCESS" )
						
							If ( RecLock( "WF6", .T. ) )
								WF6_FILIAL 	:= xFilial( "WF6" )
								WF6_DE     	:= oMailBox:cRemetent
								WF6_PROPRI 	:= Upper( AllTrim( aHttpAddress[ nC ] ) )
								WF6_PARA   	:= AllTrim( aHttpAddress[ nC ] )
								WF6_GRUPO  	:= "00001"
								WF6_STATUS 	:= "1"
								WF6_IDENT1 	:= cMailID 
								WF6_DATA   	:= Date()
								WF6_HORA   	:= Left( Time(),5 )
								WF6_DESCR  	:= ::cSubject                           
								WF6_ACAO   	:= '{|oTsk| WFTaskWF( oTsk, 2, "messenger/emp' + cEmpAnt + "/" + aHttpAddress[ nC ] + "/" + cMailID + '.htm",' +IIF( Empty( ::bReturn ),".F.",".T.") + ')}'
								WF6_PRIORI 	:= ::cPriority
								WF6_DTVENC 	:= ::dNextTOut
								WF6_HRVENC 	:= ::tNextTOut
								MSUnlock("WF6")
							EndIf							
 						next 						
 					EndIf 					
 				EndIf 				
 			Else
 				WFConout( STR0019 + ::FProcessID + "." + ::FTaskID + " [" + ::FTask + "]" + STR0020,,,,.T.,"WFPROCESS" ) // "Processo " // " sem destinatário definido!"
 			EndIf
 			
 			cBuffer := "" 			
		EndIf
		
		if !Empty( ::cBody )
			for nC := 1 to len( aHttpAddress )
				cFileName := ::oWF:cMessengerDir + aHttpAddress[ nC ] + "\" + cMailID + ".apm"
				WFSaveFile( cFileName, ::cBody )
			
				if ( RecLock( "WF6", .T. ) )
					WF6_FILIAL 	:= xFilial( "WF6" )
					WF6_DE     	:= oMailBox:cRemetent
					WF6_PROPRI 	:= Upper( AllTrim( aHttpAddress[ nC ] ) )
					WF6_PARA   	:= AllTrim( aHttpAddress[ nC ] )
					WF6_GRUPO  	:= "00002"
					WF6_STATUS 	:= "1"
					WF6_IDENT1 	:= cMailID
					WF6_DATA   	:= MsDate()
					WF6_HORA   	:= Left( Time(),5 )
					WF6_DESCR  	:= ::cSubject
					WF6_ACAO   	:= '{|oTsk| WFTaskMsg( oTsk, 2, "' + StrTran( cFileName, "\", "/" ) + '" ) }'
					WF6_PRIORI 	:= ::cPriority
					MSUnlock("WF6")
				EndIf
			next
		EndIf		
	EndIf
	
	If ! ( Empty( self:cTo + ::cCC + ::cBCC ) )		
		If ( ::cFromName <> nil ) .or. ( ::cFromAddr <> nil )
			oMailBox:cRemetent := if( ::cFromName <> nil, ::cFromName, oMailBox:cRemetent )
			oMailBox:cAddress := if( ::cFromAddr <> nil, ::cFromAddr, oMailBox:cAddress )
		EndIf
		
		//--------------------------------------------------
		// Verifica utilizacao de filas de email.
		//--------------------------------------------------
		lUseQueues:= xBIConvTo("L", WFGetMV("MV_WFFILA",.F.) ) 
		
		If ( lUseQueues )
			//--------------------------------------------------
			// Verifica a quantidade de filas configuradas.
			//--------------------------------------------------
			aQueues := getQueues() 

			If ( Len( aQueues ) == 0 )  
				//--------------------------------------------------
				// Indica que o envio será feito pelo servidor.
				//--------------------------------------------------
				lUseQueues := .F.  
				//--------------------------------------------------
				// Loga a forma de envio.
				//--------------------------------------------------				
				WFConout(STR0021,,,,.T.,"WFPROCESS" ) // "Nenhuma fila disponível, o envio será realizado pelo servidor."	 
			Else  
				//--------------------------------------------------
				// Encaminha o envio para uma das filas ativas.
				//--------------------------------------------------
		 		oQueueManager 			:= TWFQueueManager():New(aQueues)
				nIndexOfTheSmallerQueue := Randomize(1, oQueueManager:nNumberOfQueues + 1 )
				oSmallerQueue 			:= oQueueManager:aQueues[nIndexOfTheSmallerQueue]
				oMailBox:cQueueName		:=oSmallerQueue:cQueueName
				oMailBox:cRootDir		:=oSmallerQueue:cRootDir
				oMailBox:cRootPath		:=oSmallerQueue:cRootPath   
				//--------------------------------------------------
				// Loga a forma de envio.
				//--------------------------------------------------	
				WFConout(STR0022 + AllTrim( oMailBox:cQueueName ) ,,,,.T.,"WFPROCESS" ) // "O envio será realizado pela fila: "
			EndIf
		EndIf      
		
		//--------------------------------------------------
		// Cria a mensagem na caixa de saída do servidor ou fila.
		//--------------------------------------------------
		oMailBox:NewMessage( ::cTo, ::cCC, ::cBCC, ::cSubject, iif ( ::oWF:lHtmlBody, WFLoadFile( cHTMLFile ), ::cBody ), ::aAttFiles, aHeaders,, ::nEncodeMime, cMailID, ::aDelFiles )

		If ( (::oWF:lSendAuto) .And. !( lUseQueues )	 )
			WFSendMail( { cEmpAnt, cFilAnt }, lDebug )
		EndIf
	EndIf 
     
	//--------------------------------------------------
	// Remove o arquivo temporário. 
	//--------------------------------------------------
	If ( ::oWF:lHtmlBody )
		FErase( cHTMLFile )
	EndIf

	ChkFile( "WFA" )
	DbSelectArea( "WFA" )

	If ( RecLock("WFA", .T. ) )
		WFA_FILIAL	:= xFilial( "WFA" )
			
		If ( Len( aHttpAddress ) > 0 )
			WFA_TIPO := WF_OUTHTTP
		Else
			WFA_TIPO := WF_OUTBOX
		EndIf
			
		WFA_IDENT	:= cMailID
		WFA_DATA		:= MSDate()                                                                                      	
		WFA_HORA		:= Time()
		WFA_USRSIG	:= ::UserSiga	
		MSUnlock("WFA")
	EndIf

	//--------------------------------------------------
	// Salva o arquivo de definição do processo. 
	//--------------------------------------------------
	::SaveValFile( cValFile )

	If !( ::lTimeOut ) .and. empty( ::bReturn )
		::LogEvent( EV_FREETASK, STR0023 )  // "[Tarefa sem retorno esperado]" 
	EndIf    
Return cMailID                     

method SaveValFile( cValFile ) class TWFProcess 
	Local nC   		:= 0
	Local nC2	   	:= 0     
	Local cBuffer   := ''  
	Local cVariable := ''
	Local cTag      := ''
	Local cText     := ''
	Local nText     := 0 
	Local nSubstr 	:= 0      
	Local aValues 	:= ::SaveObj() 
	Local aText		:= {}

	If ( cValFile <> nil )
		cBuffer := "Local aValues := {}" + chr(13) + chr(10)
		cBuffer += "Local aAux1, aAux2" + chr(13) + chr(10)
		cBuffer += "Local cAux1, cAux2, cAux3, cAux4, cAux5, cAux6, cAux7, cAux8, cAux9, cAux10, cAux11, cAux12, cAux13, cAux14, cAux15" + chr(13) + chr(10)
				
		for nC := 1 to len(aValues)
			do case
				case Upper(aValues[nC,1]) == "APARAMS"
					cBuffer += "aAux1 := " + AsString(aValues[nC,3],.t.) + chr(13) + chr(10)
					cBuffer += "AAdd(aValues,{'aParams','A',aAux1})" + chr(13) + chr(10)
				
				case Upper(aValues[nC,1]) == "BTIMEOUT"
					cBuffer += "aAux1 := " + AsString(aValues[nC,3],.t.) + chr(13) + chr(10)
					cBuffer += "AAdd(aValues,{'bTimeout','A',aAux1})" + chr(13) + chr(10)
				
				case Upper(aValues[nC,1]) == "AATTFILES"
					cBuffer += "aAux1 := " + AsString(aValues[nC,3],.t.) + chr(13) + chr(10)
					cBuffer += "AAdd(aValues,{'aAttFiles','A',aAux1})" + chr(13) + chr(10)
				
				case Upper(aValues[nC,1]) == "ADELFILES"
					cBuffer += "aAux1 := " + AsString(aValues[nC,3],.t.) + chr(13) + chr(10)
					cBuffer += "AAdd(aValues,{'aDelFiles','A',aAux1})" + chr(13) + chr(10)
			   
				case Upper(aValues[nC,1]) == "OHTML"
					cBuffer += "aAux1 := {}" + chr(13) + chr(10)
					cBuffer += "AAdd(aAux1," + AsString(aValues[nC,3,1],.t.) + ")" + chr(13) + chr(10)
					cBuffer += "AAdd(aAux1,{'aListValues','A',{}})" + chr(13) + chr(10)
					cBuffer += "aAux2 := {}" + chr(13) + chr(10)  
					
					For nC2 := 1 To Len(aValues[nC,3,2,3,1])   
                     cText := cBIStr( aValues[nC,3,2,3,1,nC2][2] )

						If ! ( cText == Nil ) .And. Len( cText ) > 1024   
							cText 		:= StrTran( cText, "'", '"' ) 
							cVariable  	:= aValues[ nC,3,2,3,1,nC2 ][1]
							cTag  		:= aValues[ nC,3,2,3,1,nC2 ][3]  
						 	aText	 	:= StrTokArr( cText, CRLF ) 
        
							cBuffer  	+= "cAux" + cBIStr( nC2 ) + " := ''" + chr(13) + chr(10)

							For nText := 1 To Len( aText )    
								If ( Len( aText[nText] ) > 1024 ) 
									For nSubstr := 1 To Len( aText[nText] ) Step 1024	
										cBuffer += 'cAux' + cBIStr( nC2 ) + " += '" + Substr( aText[nText], nSubstr, 1024 ) + "'" + chr(13) + chr(10)
									Next nSubstr 
								Else
							 		cBuffer += 'cAux' + cBIStr( nC2 ) + " += '" + aText[nText] + "'" + chr(13) + chr(10)	
								EndIf
							Next nText  
							
							cBuffer += "AAdd(aAux2," + "{'" + cVariable + "'," + "cAux" + cBIStr( nC2 ) + ",'" + cTag + "'}" + ")" + chr(13) + chr(10)
						Else
							cBuffer += "AAdd(aAux2," + AsString(aValues[nC,3,2,3,1,nC2],.T.)  + ")" + chr(13) + chr(10)
						EndIf 
					Next    
					
					cBuffer += "AAdd(aAux1[2,3],aAux2)" + chr(13) + chr(10)
					cBuffer += "aAux2 := {}" + chr(13) + chr(10) 
					
					for nC2 := 1 to len(aValues[nC,3,2,3,2])
						cBuffer += "AAdd(aAux2," + AsString(aValues[nC,3,2,3,2,nC2],.t.) + ")" + chr(13) + chr(10)
					next   
					
					cBuffer += "AAdd(aAux1[2,3],aAux2)" + chr(13) + chr(10)
					cBuffer += "AAdd(aAux1,{'aListTables','A',{}})" + chr(13) + chr(10)
					cBuffer += "aAux2 := {}" + chr(13) + chr(10) 
					
					for nC2 := 1 to len(aValues[nC,3,3,3,1])
						cBuffer += "AAdd(aAux2," + AsString(aValues[nC,3,3,3,1,nC2],.t.) + ")" + chr(13) + chr(10)
					next   
					
					cBuffer += "AAdd(aAux1[3,3],aAux2)" + chr(13) + chr(10)
					cBuffer += "aAux2 := {}" + chr(13) + chr(10)
					
					for nC2 := 1 to len(aValues[nC,3,3,3,2])   
						cBuffer += "AAdd(aAux2," + AsString(aValues[nC,3,3,3,2,nC2],.t.) + ")" + chr(13) + chr(10)
					next  
					
					cBuffer += "AAdd(aAux1[3,3],aAux2)" + chr(13) + chr(10)
					cBuffer += "AAdd(aAux1,{'aListVal2','A',{}})" + chr(13) + chr(10)
					cBuffer += "aAux2 := {}" + chr(13) + chr(10) 
					
					for nC2 := 1 to len(aValues[nC,3,4,3,1])
						cBuffer += "AAdd(aAux2," + AsString(aValues[nC,3,4,3,1,nC2],.t.) + ")" + chr(13) + chr(10)
					next  
					
					cBuffer += "AAdd(aAux1[4,3],aAux2)" + chr(13) + chr(10)
					cBuffer += "aAux2 := {}" + chr(13) + chr(10)   
					
					for nC2 := 1 to len(aValues[nC,3,4,3,2])
						cBuffer += "AAdd(aAux2," + AsString(aValues[nC,3,4,3,1,nC2],.t.) + ")" + chr(13) + chr(10)
					next     
					
					cBuffer += "AAdd(aAux1[4,3],aAux2)" + chr(13) + chr(10)
					cBuffer += "AAdd(aAux1," + AsString(aValues[nC,3,5],.t.) + ")" + chr(13) + chr(10)
					cBuffer += "AAdd(aValues,{'oHTML','O',aAux1})" + chr(13) + chr(10)
					
				otherwise
					cBuffer += "AAdd(aValues," + AsString(aValues[nC],.t.) + ")" + chr(13) + chr(10)
			end
		next   
		
		cBuffer := Strtran( cBuffer, "'+chr(34)+'", chr(34) )
		cBuffer := Strtran( cBuffer, "'+chr(39)+'", chr(34) )
		cBuffer += "return aValues"    
		
		WFSaveFile( cValFile, cBuffer )
	End
return file(cValFile)

//*--< Metodo ExtHttpAddr - Extrai todos os enderecos do tipo http >---------------*
method ExtHttpAddr() class TWFProcess 
	local nC
	local aRecipients, aAddress := {}
	
	if len( aRecipients := WFTokenChar( ::cTo, ";" ) ) > 0
		nC := 1
		while nC <= len( aRecipients )
			if At( chr(64), aRecipients[ nC ] ) == 0
				if AScan( aAddress, { |x| Upper( AllTrim( x ) ) == Upper( AllTrim( aRecipients[ nC ] ) ) } ) == 0
					AAdd( aAddress, aRecipients[ nC ] )
				end
				ADel( aRecipients, nC )
				ASize( aRecipients, Len( aRecipients ) -1 )
			else
				nC++
			end
		end
	   ::cTo := WFUnTokenChar( aRecipients )
	end
	
	if len( aRecipients := WFTokenChar( ::cCC, ";" ) ) > 0
		nC := 1
		while nC <= len( aRecipients )
			if At( chr(64), aRecipients[ nC ] ) == 0
				if AScan( aAddress, { |x| Upper( AllTrim( x ) ) == Upper( AllTrim( aRecipients[ nC ] ) ) } ) == 0
					AAdd( aAddress, aRecipients[ nC ] )
				end
				ADel( aRecipients, nC )
				ASize( aRecipients, Len( aRecipients ) -1 )
			else
				nC++
			end
		end
	   ::cCC := WFUnTokenChar( aRecipients )
	end
	
	if len( aRecipients := WFTokenChar( ::cBCC, ";" ) ) > 0
		nC := 1
		while nC <= len( aRecipients )
			if At( chr(64), aRecipients[ nC ] ) == 0
				if AScan( aAddress, { |x| Upper( AllTrim( x ) ) == Upper( AllTrim( aRecipients[ nC ] ) ) } ) == 0
					AAdd( aAddress, aRecipients[ nC ] )
				end
				ADel( aRecipients, nC )
				ASize( aRecipients, Len( aRecipients ) -1 )
			else
				nC++
			end
		end
	   ::cBCC := WFUnTokenChar( aRecipients )
	end
return aAddress

//-------------------------------------------------------------------
/*/{Protheus.doc} Load
Recarrega o objeto do processo com as informações do arquivo de definição (.val). 

@param pcProcess		Identificador do processo que deverá carregado.  
@return lLoad			Identifica se o processo foi carregado com sucesso. 

@author  BI Team
/*/
//-------------------------------------------------------------------
method Load( pcProcesso ) class TWFProcess
	Local cValFile  	:= ""
	Local cKey			:= ""
	Local aValues 	:= {}
	Local lLoad 		:= .F.

	If ! ( pcProcesso == Nil ) 
		//-------------------------------------------------------------------
		// Recupera as informações do processo da tabela de rastreabilidade. 
		//-------------------------------------------------------------------  
		DBSelectArea("WF3")
		DBSetOrder(1)   

		::FProcessID 	:= extProcID( pcProcesso )
		::FTaskID 		:= extTaskID( pcProcesso )
		::nTaskID		:= Hex2Int( ::FTaskID )

		If ( DBSeek(  xFilial("WF3") + Lower( ::FProcessID + "." + ::FTaskID ) ) )
			::FProcCode := WF3_PROC
		EndIf 
		DBCloseArea() 
		
		//-------------------------------------------------------------------
		// Recupera as informações do processo da tabela de rastreabilidade. 
		//------------------------------------------------------------------- 	
		DBSelectArea("WFA")
		DBSetOrder(2)
		
		//-------------------------------------------------------------------
		// Monta a chave de pesquisa na tabela de mensagens. 
		//-------------------------------------------------------------------	
		cKey := xFilial("WFA") + Lower( Self:FProcessID + Self:FTaskID )
		
		//-------------------------------------------------------------------
		// Localiza a mensagem correspondente ao processo. 
		//-------------------------------------------------------------------	
		If ( DBSeek( cKey ) ) 
			//-------------------------------------------------------------------
			// Localiza o arquivo de definição mais recente. 
			//------------------------------------------------------------------- 
			While ( ! Eof() .And. ( Substr( WFA->WFA_FILIAL + WFA->WFA_IDENT, 1, Len( cKey ) ) ) == cKey )  
				cValFile 	:= Lower( ::oWF:cProcessDir + AllTrim( WFA->WFA_IDENT ) + ".val" )
				WFA->( DBSkip() )
			End	

			If ( File( cValFile ) )
				//-------------------------------------------------------------------
				// Recupera as informações do processo.
				//------------------------------------------------------------------- 
				aValues := WFLoadValFile( cValFile )
			Else
				//-------------------------------------------------------------------
				// Verifica se o arquivo de definição foi gerado no temp.
				//------------------------------------------------------------------- 
				cValFile := cBIFixPath( AllTrim( WFGetMV( "MV_WFDIR", "\WORKFLOW" ) )  , "\")  
				cValFile += 'TEMP\' + AllTrim( WFA_IDENT ) + ".val"   
				
				If ( File( Lower( cValFile ) ) )
					WFMoveFiles( cValFile, ::oWF:cProcessDir )                                
					
					//-------------------------------------------------------------------
					// Recupera as informações do processo.
					//------------------------------------------------------------------- 
					If ( File( cValFile := Lower( ::oWF:cProcessDir + AllTrim( WFA_IDENT ) + ".val" ) ) )
						aValues := WFLoadValFile( cValFile )
					EndIf
				EndIf
			EndIf    
			
			//-------------------------------------------------------------------
			// Reconstroi o processo com as informações do arquivo de definição.
			//------------------------------------------------------------------- 		
			If ! ( len( aValues ) == 0 )
				::LoadObj( aValues )
				lLoad := .T.
			EndIf
		Else  
			//-------------------------------------------------------------------
			// Ignora os processo que não possuem arquivo de definição associado.
			//-------------------------------------------------------------------  
			If ! ( Self:FTaskID == "00" )
				WFConOut( STR0016 + ::FProcessID + "." + ::FTaskID ) // "Processo não localizado para carga: "
			EndIf
		EndIf
		
		DBCloseArea()
	EndIf	
Return lLoad

// *--< Método AttachFile - Inclui um arquivo na lista de anexos >-----------------*
method AttachFile( cFileName, alDelete ) class TWFProcess
	local nC
	local lResult := .f.
	
	default alDelete := .f.
	
	if cFileName <> nil
		cFileName := lower( AllTrim( cFileName ) )
		if len( ::aAttFiles ) > 0
			for nC := 1 to len( ::aAttFiles )
				if valtype( cFileName ) == "A"
					if valtype( ::aAttFiles[ nC ] ) == "A"
						lResult := ( ::aAttFiles[ nC,1 ] == cFileName[ 1 ] )
					else
						lResult := ( ::aAttFiles[ nC ] == cFileName[ 1 ] )
					end
				else
					if valtype( ::aAttFiles[ nC ] ) == "A"
						lResult := ( ::aAttFiles[ nC,1 ] == cFileName )
					else
						lResult := ( ::aAttFiles[ nC ] == cFileName )
					end
				end
				if lResult
					exit
				end
			next
		end
		if !lResult
			AAdd( ::aAttFiles, cFileName )
			if alDelete
			  aAdd( ::aDelFiles, cFileName )
			endif  
		end
	end
return !lResult

// *--< Método SaveObj - Salva as propriedades do objeto >----------------------------*
method SaveObj( aObjList ) class TWFProcess
return WFSaveObj( self, ::aPropertyList, aObjList )

// *--< Método LoadObj - Carga das propriedades do objeto >---------------------------*
method LoadObj( aObjList ) class TWFProcess
return WFLoadObj( self, aObjList )

// *--< Método InitObj - Inicializa o objeto após o Load >----------------------------*
method InitObj( cObjName ) class TWFProcess
	
	if upper( cObjName ) == "OHTML"
		::HtmlFile( ::cHtmlFile )	
	end
	
return

Method NewVersion( lActive ) Class TWFProcess
	Local lRet := ::cVersion <> SIGAWF_2_0
	
	If ( lActive )
		::cVersion := SIGAWF_2_0a
	Else
		::cVersion := SIGAWF_2_0
	EndIf           
Return lRet 

/******************************************************************************
	Track
	Rastreabilidade de processos
 ******************************************************************************/
method Track( cStatusCode, cDescription, cUserName, uShape ) class TWFProcess
	RastreiaWF( ::fProcessID + "." + ::fTaskID, ::fProcCode, cStatusCode, cDescription, cUserName )
	::VisioTrack( uShape, cStatusCode )
return

/******************************************************************************
	VisioTrack
	Rastreabilidade para o visio
 ******************************************************************************/
method VisioTrack( uShape, cStatusCode ) class TWFProcess
	Local nC
	Local nOrder
	Local aShapes
	Local cFindKey, cLastAlias := Alias()
	Local lResult := .f., lVisio
	
	Default cStatusCode := ""
	
	lVisio := WF1->( FieldPos("WF1_VISIO") ) > 0
	
	if (uShape == nil) .or. !(lVisio)
		return lResult
	end
	
	dbSelectArea( "WFC" )
	
	if ValType( uShape ) == "N"
		nOrder := 1	// WFC_FILIAL+WFC_PROC+WFC_SHAPE
		aShapes := { StrZero( uShape,4 ) }
	else
		nOrder := 2	// WFC_FILIAL+WFC_PROC+WFC_NAME
		aShapes := WFTokenChar( uShape, ";" )
		for nC := 1 to len( aShapes )
			aShapes[ nC ] := left( upper( aShapes[ nC ] ) + space(20),20 )
		next
	end
	
	dbSetOrder( nOrder )
	
	for nC := 1 to len( aShapes )
		dbSelectArea( "WFC" )
		cFindKey := xFilial("WFC") + ::fProcCode + aShapes[nC]
		if ( lResult := dbSeek( cFindKey ) )
			dbSelectArea("WFD")
			cFindKey := xFilial("WFD") + ::fProcCode + ::fProcessID + WFC->WFC_SHAPE
			if ( lResult := dbSeek( cFindKey ) )
				if !( lResult := ( WFC->WFC_DEPANT == "0000" .or. empty( WFC->WFC_DEPANT ) ) )
					cFindKey := xFilial("WFD") + ::fProcCode + ::fProcessID + WFC->WFC_DEPANT
					if ( lResult := dbSeek( cFindKey ) )
						if ( lResult := WFD_FLAG )
							cFindKey := xFilial("WFD") + ::fProcCode + ::fProcessID + WFC->WFC_SHAPE
							dbSeek( cFindKey )
						end
					end
				end
				if lResult
					if RecLock( "WFD", .f. )
						WFD_FLAG := .t.
						WFD_TASKID := ::fTaskID
						WFD_DATA := MsDate()
						WFD_HORA := left( Time(),5 )
						WFD_STATUS := cStatusCode
						MsUnLock()
					end
				end
			end
		end
	next
	
	If ! ( Empty( cLastAlias ) )
		dbSelectArea( cLastAlias )
	end
return lResult

method LoadOctFile( cFileName ) class TWFProcess
	Local cFieldName
	Local cBuffer
	Local cAux
	Local lResult := .f.
	Local lEmpty := .f.
	Local nC
	Local nPos1
	Local nPos2
	Local aValues := {}

	if ( cFileName <> nil .and. ::oHTML <> nil )

		if File( cFileName )
			cBuffer := WFLoadFile( cFileName )
			cBuffer := strtran( cBuffer, "'+chr(34)+'", chr(34) )
			cBuffer := strtran( cBuffer, "'+chr(39)+'", chr(34) )

			if at("AAdd(aOct,", cBuffer) > 0
				aValues := __runcb(__compstr(cBuffer))
			else
				cBuffer := strtran( cBuffer,'"',"")
				while ( nPos := At( chr(0), cBuffer ) ) > 0
					cBuffer := Stuff( cBuffer, nPos, 1, "" )
				end

				if (len(cBuffer) -2) > 500
			      while len(cBuffer) > 500
						cAux := Left(cBuffer,500)
						if (nPos := Rat("},{",cAux)) > 0
							cAux := Left(cAux,nPos) + "}"
							AEval(&(cAux),{|x| AAdd(aValues,x)})
							cBuffer := "{" + SubStr(cBuffer,nPos +2)
						else
							cBuffer := "" 
						end
						cAux := nil
					enddo

					if len(cBuffer) > 0
						AEval(&(cBuffer),{|x| AAdd(aValues[10],x)})
					end
				else
					aValues[10] := &cBuffer
				end

			end
			
			cBuffer := nil
			
			if len( aValues ) == 10
				if valtype( aValues[10,1] ) == "A"
					::cRetFrom := aValues[5]
					if ( nPos1 := At("<", ::cRetFrom) ) > 0
						::cRetFrom := SubStr( ::cRetFrom, nPos1 +1 )
						if ( nPos1 := At(">", ::cRetFrom) ) > 0
							::cRetFrom := Left( ::cRetFrom, nPos1 -1 )
						end
					end
					aValues := aValues[10]
				end
			end
					
			for nC := 1 to Len( aValues )
				if ( nPos := At( ".", aValues[ nC,1 ] ) ) > 0
					cFieldName := Left( aValues[ nC,1 ], nPos )
					aValues[ nC,1 ] := SubStr( aValues[ nC,1 ], nPos +1 )
					if ( nPos := At( ".", aValues[ nC,1 ] ) ) > 0
						cFieldName += Left( aValues[ nC,1 ], nPos -1 )
					end
					if ::oHTML:ExistField( 2, cFieldName )
						AAdd( ::oHTML:RetByName( cFieldName ), aValues[ nC,2 ] )
					end
				else
					if empty( aValues[ nC,1 ] )
						lEmpty := .t.
					else
						if ::oHTML:ExistField( 2, aValues[ nC,1 ] )
							::oHTML:RetByName( aValues[ nC,1 ], aValues[ nC,2 ], .t. )
						end
					end
				end
			next	

			for nC := 1 to len( ::oHTML:aListTables[ 2 ] )
				if len( ::oHTML:aListTables[ 2, nC, 2 ] ) == 0
					if len( ::oHTML:aListTables[ 1, nC, 2 ] ) > 0
						::oHTML:aListTables[ 2, nC, 2 ] := ::oHTML:aListTables[ 1, nC, 2 ]
					end
				end
			next 
			
			for nC := 1 to len( ::oHTML:aListValues[ 2 ] )
				if ::oHTML:aListValues[ 2, nC, 2 ] == nil
					if ::oHTML:aListValues[ 1, nC, 2 ] <> nil
						::oHTML:aListValues[ 2, nC, 2 ] := ::oHTML:aListValues[ 1, nC, 2 ]
					end
				end
			next

			lResult := .t.
		else
			::LogEvent( EV_FILENOTFOUND, cFileName )
		end
	end			
Return lResult

/**
*/
Function WFChkProcEvent( pcProcesso, pcTarefa, pcEvento )
	Local lResultado   	:= .F.	
	Local cChave   		:= ''

	Default pcProcesso 	:= ""
	Default pcTarefa 	:= ""
	Default pcEvento 	:= 0
	
	dbSelectArea("WF3")
	WF3->( DBSetOrder(1) )
	
	cChave := xFilial("WF3") + Lower( PadR( pcProcesso + "." + pcTarefa , WF_KEY_PROC_LEN ) + StrZero( pcEvento, 6 ) )
	
	If ( WF3->( DbSeek( cChave ) ) )
	  	lResultado := WF3->( DbSeek( cChave ) )
	EndIf
	
	WF3->( DBCloseArea() ) 
Return lResultado

//-------------------------------------------------------------------
/*/{Protheus.doc} WFKillProcess
Finaliza um processo ou uma tarefa específica. 

@param pcProcess		Identificador do processo que deverá encerrado.  
@param plKillProcess	Identifica se encerra apenas a tarefa ou o processo completo. 

@author  BI Team
/*/
//-------------------------------------------------------------------
Function WFKillProcess( pcProcess, plKillProcess )
	Local oProcess			:= Nil 
	Local cProcess    		:= ""
	Local cTask	      		:= ""
	Local cKey 				:= "" 
	Local lOk					:= .T.
	
	Default pcProcess			:= ""    
	Default plKillProcess	:= .F. 

	//-------------------------------------------------------------------
	// Recupera o código do processo e da tarefa. 
	//-------------------------------------------------------------------  
	cProcess 	:= ExtProcID( pcProcess )
	cTask	 	:= ExtTaskID( pcProcess )

	//-------------------------------------------------------------------
	// Posiciona a tabela de rastreabilidade. 
	//------------------------------------------------------------------- 
	DBSelectArea("WF3")
	WF3->( DBSetOrder(1) )
	
	//-------------------------------------------------------------------
	// Monta a chave de pesquisa para o processo. 
	//------------------------------------------------------------------- 	
	cKey := xFilial("WF3") + Lower( PadR( cProcess + ".00", WF_KEY_PROC_LEN ) )

	//-------------------------------------------------------------------
	// Localiza o processo. 
	//------------------------------------------------------------------- 
	If ( WF3->( DBSeek( cKey ) ) )
		//-------------------------------------------------------------------
		// Verifica se deve encerrar o processo ou uma tarefa específica. 
		//------------------------------------------------------------------- 
		If ( plKillProcess )
			//-------------------------------------------------------------------
			// Força o encerramento de todas as tarefas do processo. 
			//------------------------------------------------------------------- 
			While ( ! Eof() .And. ( ( WF3->WF3_FILIAL + ExtProcID(  WF3->WF3_ID ) ) == ( xFilial("WF3") + cProcess ) ) )
				oProcess := TWFProcess():New( WF3->WF3_PROC, STR0015, WF3->WF3_ID )
				oProcess:Finish(STR0024) 
				oProcess:Free()
				
				WF3->( DBSkip() )
			End		
		Else
			//-------------------------------------------------------------------
			// Encerra uma tarefa específica. 
			//------------------------------------------------------------------- 
			If ! ( Empty( cTask ) )
				oProcess := TWFProcess():New( WF3->WF3_PROC, STR0015, cProcess + "." + cTask )
				oProcess:Finish(STR0024) 
				oProcess:Free()
			Else
				lOk := .F. 
			EndIf 	
		EndIf 
	EndIf 
	 
	//-------------------------------------------------------------------
	// Fecha a tabela de rastreabilidade. 
	//-------------------------------------------------------------------
	WF3->( DBCloseArea() ) 
Return lOk


/******************************************************************************
	WFLogEvent()
	Imprime um log text no console, baseado no tipo de acao indicado pelo nEventCode
 *****************************************************************************/
function WFLogEvent( nEventCode, cText, cProcessID, cTaskID )
	local cReturn := ""
	
	default nEventCode := 0, cText := "", cProcessID := "", cTaskID := ""

	cText := AllTrim( cText )

	do case
		case nEventCode == EV_NEWPROC
			cReturn := "[ EV_NEWPROC      ] " + STR0002 //'Processo iniciado '
		case nEventCode == EV_FREEPROC
			cReturn := "[ EV_FREEPROC     ] " + STR0001  //'Processo finalizado '
		case nEventCode == EV_NEWTASK 
			cReturn := "[ EV_NEWTASK      ] " + STR0003 //'Tarefa iniciada'
		case nEventCode == EV_RUNTASK 
			cReturn := "[ EV_RUNTASK      ] " + STR0004 //'Tarefa em execução'
		case nEventCode == EV_FREETASK
			cReturn := "[ EV_FREETASK     ] " + STR0005 //'Tarefa finalizada'
		case nEventCode == EV_INITPROC
			cReturn := "[ EV_INITPROC     ] " + STR0006 //'Inicialização do processo'
		case nEventCode == EV_MAILSAVE
			cReturn := "[ EV_MAILSAVE     ] " + STR0007 //'Solicitação de e-mail executada'
		case nEventCode == EV_MAILLOAD
			cReturn := "[ EV_MAILLOAD     ] " + STR0008 //'Recebimento de e-mail executado'
		case nEventCode == EV_PREPFAIL
			cReturn := "[ EV_PREPFAIL     ] " + STR0009 //'Preparação do processo falhou'
		case nEventCode == EV_FILENOTFOUND
			cReturn := "[ EV_FILENOTFOUND ] " + STR0010 //'Arquivo não localizado'
		case nEventCode == EV_MAILIGNORED
			cReturn := "[ EV_MAILIGNORED  ] " + STR0011 //'Processamento de e-mail ignorado'
		case nEventCode == EV_FINISH
			cReturn := "[ EV_FINISH       ] " + STR0012 //'Processo encerrado'
		case nEventCode == EV_EVENTIGNORED
			cReturn := "[ EV_EVENTIGNORED ] " + STR0013 //'Evento ignorado'
		case nEventCode == EV_INFORMATION
			cReturn := "[ EV_INFORMATION  ] " + STR0014 + cText //'Aviso: '
	endcase

	If ( nEventCode <> 0 )
		ConOut( "[" + Left(DToC(MsDate()),5) + "*" + Left( Time(),5 ) + "]" + '[' + cProcessID + '.' + cTaskID + ']' + cReturn + " " + cText)
	endif
return cReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RastreiaWF| Autor ³ Marcelo Abe           ³ Data ³ 07.04.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Atualizacao de Rastreabilidade WF              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void RastreiaWF                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cIDProcess = ID do Processo                                ³±±
±±³          ³ cProcesso  = Codigo do Processo                            ³±±
±±³          ³ cStatus    = Codigo do Status                              ³±±
±±³          ³ cDescr     = Descricao Especifica                          ³±±
±±³          ³ cUsuario   = Usuario                                       ³±±                                      
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RastreiaWF( cProcessID, cProcCode, cStatusCode, cDescription, cUserName )
	Local dDate
	Local cTime  		:= ""	
	Local cLastAlias 	:= Alias()
	
	Default cProcessID 	:= ""
	Default cProcCode 	:= ""
	Default cStatusCode := ""
	Default cUserName 	:= ""
	
	cProcCode 	:= Upper( Left( cProcCode 	 + Space( 6 ),6 ) )
	cStatusCode := Upper( Left( cStatusCode  + Space( 6 ),6 ) )
	
	dbSelectArea( "WF1" )
	dbSetOrder( 1 )
	
	dbSelectArea("WF2")
	dbSetorder(1)
	
	if !dbSeek( xFilial("WF2") + cProcCode + cStatusCode )
		Help("",1,"WFNOSTAT")
		Return .f.
	End
	
	default cDescription := WF2_DESCR
	
	dDate := MSDate()
	cTime := Time()
	
	dbSelectArea("WF3")
	dbSetOrder(5) //Data+Hora+ID
	
	While dbSeek( xFilial("WF3") + DTOS(dDate) + cTime + cProcessID )
		dData := MSDate()
		cTime := Time()
	end
	
	if RecLock("WF3",.T.)
		WF3->WF3_FILIAL := xFilial("WF3")
		WF3->WF3_ID	    := Lower( cProcessID )
		WF3->WF3_PROC   := cProcCode
		WF3->WF3_STATUS := cStatusCode
		WF3->WF3_HORA   := cTime
		WF3->WF3_DATA   := dDate
		WF3->WF3_USU    := cUserName
		WF3->WF3_DESC   := cDescription
		MsUnlock()
	end
	
	If ! ( Empty( cLastAlias ) )
		dbSelectArea( cLastAlias )
	end		
Return .t.

Function WFLoadValFile( cValFile )
	local nPos1 		:= 0
	local nPos2      	:= 0
	local cBuffer    	:= ''
	local cParams      	:= ''
	local cBody       	:= ''
	local cListValues  	:= ''
	local cListTables 	:= ''
	local aValues 		:= {}
	
	If ( File( cValFile ) )
		cBuffer := WFLoadFile( cValFile )
		cBuffer := StrTran( cBuffer, Chr(0), "" )
		
		If ( At("AAdd(aValues,", cBuffer) > 0 )
			aValues := __runcb(__compstr(cBuffer))
		Else
			If ( nPos1 := At( "{'aParams','A',", cBuffer ) ) > 0
				nPos1 += 15    
				
				If ( nPos2 := At( ",{'cTo','C',", cBuffer ) ) > 0
					nPos2--
					cParams := substr( cBuffer, nPos1, nPos2 - nPos1 )
					cParams := strtran( cParams, "'+chr(34)+'", chr(34) )
					cParams := strtran( cParams, "'+chr(39)+'", chr(34) )
					cBuffer := Stuff( cBuffer, nPos1, nPos2 - nPos1, "nil" )
				End
			End
			
			if ( nPos1 := At( "{'cBody','C',", cBuffer ) ) > 0
				nPos1 += 13
				if ( nPos2 := At( ",{'cClientName','", cBuffer ) ) > 0
					nPos2--
					cBody := substr( cBuffer, nPos1, nPos2 - nPos1 )
					cBody := strtran( cBody, "'+chr(34)+'", chr(34) )
					cBody := strtran( cBody, "'+chr(39)+'", chr(34) )
					cBuffer := Stuff( cBuffer, nPos1, nPos2 - nPos1, "nil" )
				end
			end    
			
			if ( nPos1 := At( "{'aListValues','A',", cBuffer ) ) > 0
				nPos1 += 19
				if ( nPos2 := At( ",{'aListTables','A',", cBuffer ) ) > 0
					nPos2--
					cListValues := substr( cBuffer, nPos1, nPos2 - nPos1 )
					cListValues := SubStr( cListValues, 2, len( cListValues ) -2 )
					cListValues := strtran( cListValues, "'+chr(34)+'", chr(34) )
					cListValues := strtran( cListValues, "'+chr(39)+'", chr(34) )
					cBuffer := Stuff( cBuffer, nPos1, nPos2 - nPos1, "nil" )
				end
			end    
			
			if ( nPos1 := At( "{'aListTables','A',", cBuffer ) ) > 0
				nPos1 += 19
				if ( nPos2 := At( ",{'aListVal2','A',", cBuffer ) ) > 0
					nPos2--
					cListTables := substr( cBuffer, nPos1, nPos2 - nPos1 )
					cListTables := SubStr( cListTables, 2, len( cListTables ) -2 )
					cListTables := strtran( cListTables, "'+chr(34)+'", chr(34) )
					cListTables := strtran( cListTables, "'+chr(39)+'", chr(34) )
					cBuffer := Stuff( cBuffer, nPos1, nPos2 - nPos1, "nil" )
				end
			end
			
			aValues := &(cBuffer)
			cBuffer := nil
			
			aValues[7,3] := {}
			
			if ( cParams <> nil )
				aValues[7,3] := &(cParams)
				cParams := nil
			end
			
			if cBody <> nil
				if ( nPos1 := AScan( aValues,{|x| x[1] == "cBody" } ) ) > 0
					aValues[nPos1,3] := cBody
				end
			end
			
			if ( nPos1 := AScan( aValues,{|x| x[1] == "oHTML" } ) ) > 0
				aValues[nPos1,3,2,3] :=	{{},{}}
				
				if ( cListValues <> nil )
					if ( nPos2 := at( "}},{{", cListValues ) ) > 0
						aValues[nPos1,3,2,3,1] := &( left( cListValues, nPos2 +1 ) )
						aValues[nPos1,3,2,3,2] := &( SubStr( cListValues, nPos2 +3 ) )
					end
					cListValues := nil
				end
				
				aValues[nPos1,3,3,3] := {{},{}}
				
				if ( cListTables <> nil )
					if ( nPos2 := at( "}},{{", cListTables ) ) > 0
						aValues[nPos1,3,3,3,1] := &( left( cListTables, at( "}},{{", cListTables ) +1 ) )
						aValues[nPos1,3,3,3,2] := &( SubStr( cListTables, at( "}},{{", cListTables ) +3 ) )
					end
					cListTables := nil
				end
				
			end
		end
	end		
return aValues 
