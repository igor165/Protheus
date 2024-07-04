#include "SigaWF.CH" 
#include "WFMAIL.CH" 
#INCLUDE "OLECONT.CH"

/******************************************************************************
	WFSendMsg( <cMailBox>, <lAtivo>,<pcQueueName> )
	Envia todas as mensagens contidas na caixa de saida de uma determinada caixa de correio.
 *****************************************************************************/
procedure WFSndMsg( cMailBox, lAtivo, pcQueueName)
	local oMail
	local aParams
	local cLastAlias := Alias()
	local lFila := .F.
	
	if (!Empty(pcQueueName))   
		lFila := .T.
	EndIf
	
	if valtype( cMailBox ) == "A"
		aParams := { cMailBox[1], cMailBox[2] }
		if len( cMailBox ) >= 5
            lFila := cMailBox[5]
		else                     
			lFila := .F.
		endif
					
		if len( cMailBox ) >= 4
			lAtivo := cMailBox[4]
		else                     
			lAtivo := .F.
		endif
		
		if len( cMailBox ) >= 3
			cMailBox := cMailBox[3]
		endif
	else
		aParams := { cEmpAnt, cFilAnt }
	endif
	
	oMail := TWFMail():New( aParams )   	
	oMail:Send( cMailBox, lAtivo, pcQueueName )	
	
	if !Empty( cLastAlias )
		dbSelectArea( cLastAlias )
	endif
return

/******************************************************************************
	WFSndMsgAll( <lAtivo> )
	Envia todas as mensagens contidas na caixa de saida de uma determinada caixa de correio.
 *****************************************************************************/
procedure WFSndMsgAll( lAtivo )
	local oMail
	local aParams
	local cLastAlias := Alias()
	
	if valtype( lAtivo ) == "A"
		aParams := { lAtivo[1], lAtivo[2] }
		if len( lAtivo ) >= 3
			lAtivo := lAtivo[3]
		else
			lAtivo := .F.
		endif
	else
		aParams := { cEmpAnt, cFilAnt }
	endif
	
	oMail := TWFMail():New( aParams )
	oMail:SendAll( lAtivo )
	
	if !Empty( cLastAlias )
		dbSelectArea( cLastAlias )
	endif
return

/******************************************************************************
	WFRcvMsg( <cMailBox>, <lAtivo> )
	Recebe as mensagens e as depositam na caixa de entrada de uma determinada caixa de correio.
 *****************************************************************************/
procedure WFRcvMsg( cMailBox, lAtivo )
	local oMail
	local aParams
	local cLastAlias := Alias()
	
	if valtype( cMailBox ) == "A"
		aParams := { cMailBox[1], cMailBox[2] }
		if len( cMailBox ) >= 4
			lAtivo := cMailBox[4]
		else
			lAtivo := .F.
		endif
		
		if len( cMailBox ) >= 3
			cMailBox := cMailBox[3]
		endif
	else
		aParams := { cEmpAnt, cFilAnt }
	endif
	
	oMail := TWFMail():New( aParams )
	oMail:Receive( cMailBox, lAtivo )
	
	if !Empty( cLastAlias )
		dbSelectArea( cLastAlias )
	endif
return

/******************************************************************************
	WFRcvAllMsg( <lAtivo> )
	Recebe todas as mensagens e as depositam na caixa de entrada de uma determinada caixa de correio.
 *****************************************************************************/
procedure WFRcvMsgAll( lAtivo )
	local oMail
	local aParams
	local cLastAlias := Alias()
	
	if valtype( lAtivo ) == "A"
		aParams := { lAtivo[1], lAtivo[2] }
		if len( lAtivo ) >= 3
			lAtivo := lAtivo[3]
		else
			lAtivo := .F.
		endif
	else
		aParams := { cEmpAnt, cFilAnt }
	endif
	
	oMail := TWFMail():New( aParams )
	oMail:ReceiveAll( lAtivo )
	
	if !Empty( cLastAlias )
		dbSelectArea( cLastAlias )
	endif
return

/******************************************************************************
	WFNewMessage(...)
	Cria uma nova mensagem para envio
 ******************************************************************************/
procedure WFNewMsg( cMailBox, cTo, cCC, cBCC, cSubject, cBody, aAttachs, aHeaders, cBodyType, nEncodeMime, cSaveFile )
	local cLastAlias := Alias()
	local oMail := TWFMail():New()
	local oMailBox := oMail:GetMailBox( cMailBox )
	
	if oMailBox:lExists
		oMailBox:NewMessage( cTo, cCC, cBCC, cSubject, cBody, aAttachs, aHeaders, cBodyType, nEncodeMime, cSaveFile )
	endif
	
	if !Empty( cLastAlias )
		dbSelectArea( cLastAlias )
	endif
return

/******************************************************************************
	WFGetProtocol
	Retorna o corrente protocolo de e-mail em uso pelo protheus (POP3,MAPI,IMAP), usado
	na secao [MAIL] do ap?srv.ini
 ******************************************************************************/
function WFGetProtocol()
	local aResult 	:= { "SMTP", "" }
	local cFileIni 	:= GetADV97()
                                                            
	if Empty( GetPvProfString( "Mail", "Protocol", "", cFileIni ) )
		aResult[2] := "POP3"
	else
		if Upper( AllTrim( GetPvProfString( "Mail", "Protocol", "", cFileIni ) ) ) == "MAPI"
			aResult[2] := "MAPI"
		else
			if Upper( AllTrim( GetPvProfString( "Mail", "Protocol", "", cFileIni ) ) ) == "IMAP"
				aResult[2] := "IMAP"
			endif
		endif
	endif
return aResult

/******************************************************************************
	WFGetAddress()
	Retorna um array com todos os enderecos eletronicos para cada elemento
	lida a partir de uma string de enderecos separados por ponto-e-virgula
 *****************************************************************************/
function WFGetAddress( cAddress, cNoAddress )
	local nC
	local cFile
	Local cBuffer
	local aAddress
	
	default cAddress := "", cNoAddress := ""
	
	cAddress := AllTrim( cAddress )
	cAddress := StrTran( cAddress, Chr(10), "" )
	cAddress := StrTran( cAddress, Chr(13), "" )
	
	cNoAddress := AllTrim( cNoAddress )
	cNoAddress := StrTran( cNoAddress, Chr(10), "" )
	cNoAddress := StrTran( cNoAddress, Chr(13), "" )
	
	if len( aAddress := WFTokenChar( cAddress, ";" ) ) > 0
		cAddress := ""
	
		for nC := 1 to len( aAddress )
			aAddress[ nC ] := AllTrim( aAddress[ nC ] )
			if At( lower( aAddress[ nC ] ), lower( cNoAddress ) ) == 0
				if At( chr(64), aAddress[ nC ] ) > 0
					if Left( aAddress[ nC ], 1 ) == chr(64)  
						if file( cFile := subStr( aAddress[ nC ], 2 ) )
							if !empty( cBuffer := WFLoadFile( cFile ) )
								if empty( cAddress )
									cBuffer := WFGetAddresss( cBuffer, cNoAddress )
								else
									if !empty( cBuffer := WFGetAddress( cBuffer, cNoAddress + ";" + cAddress ) )
										cAddress += ";"
									endif
								endif
								cAddress += cBuffer
							endif				
						endif
					else
						if !Empty( cAddress )
							cAddress += ";"
						endif
						cAddress += aAddress[ nC ]
					endif
				else
					if Left( aAddress[ nC ], 1 ) == "&"
						if !Empty( cBuffer := SubStr( aAddress[ nC ], 2 ) )
							if ( cBuffer := &( cBuffer ) <> NIL )
								if Empty( cAddress )
									cBuffer := WFGetAddress( cBuffer, cNoAddress )
								else
									if !Empty( cBuffer := WFGetAddress( cBuffer, cNoAddress + ";" + cAddress ) )
										cAddress += ";"
									endif
								endif
								cAddress += cBuffer
							endif
						endif
					else
						if !Empty( cAddress )
							cAddress += ";"
						endif
						cAddress += aAddress[ nC ]
					endif
				endif
			endif
		next
	endif
return cAddress

/******************************************************************************
	WFExtrOct()
	Extrai o Octect da mensagem para localizar o ID do processo
 *****************************************************************************/
Function WFExtrOct( oMsg )
	Local nC
	Local cAttFile
	Local cDirTemp
	Local aResult := {}

	if oMsg <> nil
		if oMsg:GetAttachCount() <> 0
			if !empty( cDirTemp := AllTrim( WFGetMV( "MV_WFDTEMP", "" ) ) )
				cDirTemp += if( Right( cDirTemp, 1 ) == "\", "", "\" )
			endif
			
			if oMsg:GetAttachCount() > 0
				for nC := 1 to oMsg:GetAttachCount()
					// verifica se é um octet-stream
					if ( "octet-stream" $ Lower( oMsg:GetAttachInfo( nC )[ 2 ] ) )
						aResult := WFOctetStr( oMsg:GetAttach( nC ) )
						if AScan( aResult, { |x| Upper( x[1] ) == Upper(EH_MAILID) } ) > 0
							exit
						else
							aResult := {}
						endif
					elseif ( upper( EH_MAILID ) $ upper( oMsg:GetAttach( nC ) ) )
						aResult := WFOctetStr( oMsg:GetAttach( nC ) )
						exit
					elseif !empty( cDirTemp )
						cAttFile := ExtractFile( oMsg:GetAttachInfo( nC )[ 1 ] )
						if file( cDirTemp + cAttFile )
							if ( Upper( EH_MAILID ) $ upper( WFLoadFile( cDirTemp + cAttFile ) ) )
								aResult := WFOctetStr( WFLoadFile( cDirTemp + cAttFile ) )
								exit
							endif
						endif
					endif
				next          
			elseif ( upper( EH_MAILID ) $ upper( oMsg:cBody ) )
				aResult := WFOctetStr( oMsg:cBody )
			endif
		endif
		
		if Len( aResult ) == 0
			if !empty( oMsg:cBody )
				if At( Upper( EH_MAILID ), Upper( oMsg:cBody ) ) > 0
					aResult := WFOctetStr( oMsg:cBody )
				endif
			endif
		endif
	endif
return aResult

/******************************************************************************
	WFOctetStr
	Extrai o octect da mensagem que esta em um texto
 *****************************************************************************/
Function WFOctetStr( cText )
	local nC, nPos
	local aRemove := {}
	Local aResult := {}
	Local aToken
	local bLastError
	
	if cText <> nil
		cText := AllTrim( cText )
		AAdd( aRemove, { "=" + chr(10), "" } )
		AAdd( aRemove, { "=" + chr(13), "" } )
		AAdd( aRemove, { Chr(10), "" } )
		AAdd( aRemove, { Chr(13), "" } )
		AAdd( aRemove, { Chr(0), "" } )
		AAdd( aRemove, { "=3D", "=" } )
		
		for nC := 1 to len( aRemove )
			cText := StrTran( cText, aRemove[ nC, 1 ], aRemove[ nC, 2 ] )
		next
		bLastError := ErrorBlock( { |e| WFErrorBlock( e, aResult, 100100 ) } )
		
		BEGIN SEQUENCE
			if len( aResult := WFTokenChar( cText, "&" ) ) > 0
				for nC := 1 to Len( aResult )
					if len( aToken := WFTokenChar( aResult[ nC ], "=" ) ) > 1
						while ( nPos := At( "%", aToken[ 2 ] ) ) > 0
							aToken[ 2 ] := Stuff( aToken[ 2 ], nPos, 3, Hex2Chr( SubStr( aToken[ 2 ], nPos + 1, 2 ) ) )
						end
				
						while ( nPos := At( "+", aToken[ 2 ] ) ) > 0
							aToken[ 2 ] := Stuff( aToken[ 2 ], nPos, 1, " " )
						end
					else
						aToken := { aToken[1], "" }
					endif
					aResult[ nC ] := { aToken[ 1 ], aToken[ 2 ] }
				next
			endif
		END SEQUENCE
	endif
return aResult


/******************************************************************************
	WFNotifyAdmin()
	Notifica o(s) administrador(es) sobre qualquer evento que podera ter ocorrido
	durante a execucao de um processo.
 *****************************************************************************/
function WFNotifyAdmin( cTo, cSubject, cBody, aAttachs, lFila )
	local oMail := TWFMail():New()
Return oMail:NotifyAdmin( cTo, cSubject, cBody, aAttachs, lFila )
                 

/******************************************************************************
	CLASS TWFMAIL
 ******************************************************************************/

class TWFMail
	data oSmtpSrv
	data oPop3Srv
	data oServer
	data oDialUp
	data lInitServer
	
	method New( aParams ) CONSTRUCTOR
	method GetMailBox( cMailBox )
	method InitServer( oMailBox, oLogFile )
	method InitDialUp( oMailBox, oLogFile )
	method Send( cMailBox, lForce, pcQueueName )
	method SendAll( lForce )
	method SendMail( oMailBox, lForce, pcQueueName )
	method Receive( cMailBox, lForce )
	method ReceiveAll( lForce )
	method ReceiveMail( oMailBox )
	method Error( oE, oLogFile, cError )
	method NotifyAdmin( cTo, cSubject, cBody, aAttachs, lFila )   
	method Free()
endclass

method New( aParams ) class TWFMail
	default aParams := { cEmpAnt, cFilAnt }

	WFPrepEnv( aParams[1], aParams[2], "WFMail",, WFGetModulo( aParams[1], aParams[2] ) )
	ChkFile( "WF7" )
	::lInitServer := .F.
	::oSmtpSrv := TWFSmtpSrv():New( Self )
	::oPop3Srv := TWFPop3Srv():New( Self )
return

method GetMailBox( cMailBox ) class TWFMail
	local oMailBox := TWFMailBox():New( self )

	oMailBox:Recipient( cMailBox )
return oMailBox
	
method InitServer( oMailBox, oLogFile ) class TWFMail
	If ( ::oServer == Nil ) 	
		::lInitServer := .F.
		
		If ( oMailBox:lExists ) 		
			Default oLogFile := WFFileSpec( oMailBox:cRootPath + "\" + ".log" ) 
			
			If ( ::oSmtpSrv <> Nil )
			   ::oSmtpSrv:oMailBox := oMailBox
			EndIf      
			
			If ( oMailBox:nConnType == WFC_DIALUP )
				::lInitServer := ::InitDialUp( oMailBox, oLogFile )
			Else
				::lInitServer := .T.
			EndIf  
			
			If ( ::lInitServer )				
				WFConOut( STR0001, oLogFile, .F. ) //"Inicializando o servidor de e-mail..."
				::oServer := TMailManager():New()  
				                                             
				//----------------------------------------------------------
				// Verifica se a Build contempla autenticação SSL. 
				//----------------------------------------------------------
				If ( PadR( GetBuild() , 12 ) >=  "7.00.101202A" ) 
					//----------------------------------------------------------
					// Verifica se a configuração de SSL está correta.  
					//---------------------------------------------------------- 
					If ( ValType( oMailBox:lSSL ) == "L" )   
						::oServer:SetUseSSL( oMailBox:lSSL )  
					EndIf
					//----------------------------------------------------------
					// Verifica se a configuração de TLS está correta.  
					//---------------------------------------------------------- 
					If ( ValType( oMailBox:lTLS ) == "L" )   
						::oServer:SetUseTLS( oMailBox:lTLS )  
					EndIf
				EndIf
				
				::oServer:Init( ::oPop3Srv:cName, ::oSmtpSrv:cName, AllTrim( oMailBox:cUserName ), AllTrim( oMailBox:cPassword ), ::oPop3Srv:nPort, ::oSmtpSrv:nPort )
				
				If ( oMailBox:nTimeOut > 0 )
					::oServer:SetSMTPTimeOut( oMailBox:nTimeOut )
					::oServer:SetPOPTimeOut( oMailBox:nTimeOut ) 
				EndIf
			EndIf 
		EndIf 
	EndIf 	
Return ::lInitServer

method InitDialUp( oMailBox, oLogFile ) class TWFMail
	local lResult := .F.
	
	if oMailBox:lExists
		if oMailBox:nConnType == WFC_DIALUP
			WFConOut( STR0002, oLogFile, .F. ) //"Inicializando conexao Dial-up..."
			if ::oDialUp == nil 
				::oDialUp := TDialUpConnection():New()
				::oDialUp:Setup( oMailBox:cConnName, oMailBox:cDialUser, oMailBox:cDialPassw, oMailBox:cDialFone, "", oMailBox:nTimeOut )
			endif
			
			if !( lResult := ::oDialUp:Connect( oLogFile ) )
				WFConOut( STR0003, oLogFile, .F. ) //"Conexao Dial-up falhou. Tente novamente."
			endif
		endif
	endif   
return lResult

method Send( cMailBox, lForce, pcQueueName ) class TWFMail
	local lResult := .F.
	
	if cMailBox	<> nil
		if valtype( cMailBox ) == "C"
			lResult := ::SendMail( ::GetMailBox( cMailBox ), lForce, pcQueueName )
		else
			lResult := ::SendMail( cMailBox, lForce, pcQueueName )
		endif
	else
		return lResult
	endif
return lResult

method SendAll( lForce ) class TWFMail
	local cKey := xFilial( "WF7" )

	if WF7->( dbSeek( cKey ) )
		while !WF7->( Eof() ) .and. ( WF7->WF7_FILIAL == cKey )
			::Send( AllTrim( WF7->WF7_PASTA ), lForce )
			WF7->( dbSkip() )
		end
	endif
return

method SendMail( oMailBox, lForce, pcQueueName ) class TWFMail
	Local lResult 		:= .F.
	Local lConnected  	:= .F.
	Local lSendErr 		:= .F.
	Local lFila 	  	:= iif( !Empty( pcQueueName ), .T., .F. )
	                                                          	
	local cEMLFile 		:= ""
 	Local cMsg         	:= ""
	Local cBody        	:= ""
 	Local cWFMFile     	:= ""
 	Local cMessage     	:= ""
  	Local cLCKFile		:= ""
  	Local cFileName		:= ""		// Armazena os dados do arquivo que foi enviado.
  	Local cAliasAux		:= ""		// Armazena a tabela que estava sendo utilizada no momento do envio 
  	Local cFile			:= ""	 	// Nome do arquivo que está sendo enviado. 
	
	local nC1
 	Local nC2
 	Local nC3
	Local nPos1
 	Local nPos2
 	Local nAux 
 	local nInd 
 	Local nHandle 
 	Local nFormaEnvio 	:= WFGetMV( "MV_WFENVIO", 1 )
	Local nCont       	:= 1
	Local nWFAOrder 	:= WFA->(IndexOrd())
	
	local aFiles
 	Local aMessage
 	Local aDest
 	Local aTo 
 	
	local oLogFile
 	Local oOutboxFolder
 	Local oSentFolder
 	Local oErrorFolder
 	Local oError
	Local oSelf 		:= self 
	
	local bBefore
	Local bAfter
	Local bError
	Local bLastError 
	
	Local aFileError := {}
	Local lReProcMail:= xBIConvTo( 'L', WFGetMV( "MV_WFREPRO", .F. ) )
	
	Default lForce := .F.
	
	If oMailBox == Nil
		Return lResult
	EndIf
	
	If ( oMailBox:lExists ) 
		//--------------------------------------------------
		// Verifica se a caixa de correio está ativa no configurador.
		//--------------------------------------------------
		If !( oMailBox:lActive ) .And. !( lForce )
			WFConOut( FormatStr( STR0028 , oMailBox:cRecipient ), oLogFile, .F. ) //"A caixa de correio [%c] não está ativa no configurador"*/
			Return lResult
		EndIf
  
  		//--------------------------------------------------
		// Monta o arquivo de lock.
		//--------------------------------------------------    
		cLCKFile := "\semaforo\wfmail[" 
		cLCKFile +=	Iif( ValType( oMailBox:cRecipient) == "C", AllTrim( oMailBox:cRecipient ) , "DEFAULT" )
		cLCKFile += Iif( lFila, AllTrim( pcQueueName ) , "" ) 
		cLCKFile += "].lck"
		
        //--------------------------------------------------
		// Bloqueia o processo de envio de e-mail para impedir que ocorra concorrência.
		//--------------------------------------------------
		If lFila .Or. !( (nHandle := FCreate(cLCKFile, FC_READONLY) ) == -1 )
			If ( !Empty( pcQueueName ) )
				oOutboxFolder := oMailBox:GetFolder( MBF_OUTBOX + "\" + pcQueueName )
				oLogFile := WFFileSpec( oMailBox:cRootPath + "\" + MBF_OUTBOX + "\" + pcQueueName + "\" + oMailBox:cRecipient + ".log" )
			Else 
				oOutboxFolder := oMailBox:GetFolder( MBF_OUTBOX )  
				oLogFile := WFFileSpec( oMailBox:cRootPath + "\" + oMailBox:cRecipient + ".log" )
			EndIf

			oErrorFolder 	:= oMailBox:GetFolder( MBF_OUTBOX + MBF_ERROR + MBF_DATE )

			oLogFile:WriteLN( Replicate("*", 80 ) )

			//---------------------------------------------------------
			// Caso a seja para reprocessar os e-mails da pasta error.
			//---------------------------------------------------------
			If lReProcMail				
				cMsg := FormatStr( STR0055, oMailBox:cRecipient ) // "VERIFICANDO A PASTA ERROR... [%c]"
				WFConOut( cMsg, oLogFile )

				//---------------------------------------------------------
				// Recebe todos os arquivos wfm da pasta error.
				//---------------------------------------------------------
				aFileError := oErrorFolder:GetFiles("*.wfm")

				//---------------------------------------------------------
				// Move todos os wfm de erro para a outbox, para tentar reprocessar.
				//---------------------------------------------------------
				For nC1 := 1 To Len(aFileError)
					cFile := aFileError[ nC1, 1 ]
					oErrorFolder:MoveFiles( cFile, oOutboxFolder )
				Next nC1

				//---------------------------------------------------------
				// Mostra a quantidade de arquivos movidos para outbox.
				//---------------------------------------------------------
				If Len(aFileError) > 0
					WFConOut( cBIStr( Len( aFileError ) ) + STR0057, oLogFile, .F.  ) // " Arquivo(s) da pasta error foram movidos para outbox. "
				Else
					WFConOut( STR0056, oLogFile, .F. ) // "Não há arquivos na pasta ERROR para serem movidos."
				EndIf
				
				cMsg := Replicate( "-", 40 )
				WFConOut( cMsg, oLogFile, .F. )
			EndIf
			
			cMsg := FormatStr( STR0004, oMailBox:cRecipient ) //"VERIFICANDO CAIXA DE SAIDA... [%c]"
			WFConOut( cMsg, oLogFile )
			
			WFConOut( FormatStr( STR0029, oMailBox:cRecipient ) , oLogFile, .F. ) //'Abrindo a caixa de saída [%c] em modo exclusívo.'*/
			
			If Len( aFiles := oOutboxFolder:GetFiles("*.wfm") ) == 0
				cMsg := STR0005 //"Nada consta."
				WFConOut( cMsg, oLogFile, .F. )

				//---------------------------------------------------------
				// Fecha e exclui o semáforo.
				//---------------------------------------------------------
				FClose( nHandle )
				FErase( cLCKFile )

				oLogFile:Close()
				Return lResult
			Else
				cMsg := STR0006 //"Ha %c nova(s) mensagen(s) a enviar"
				cMsg := FormatStr( cMsg, StrZero( Len( aFiles ), 4 ) )
				WFConOut( cMsg, oLogFile, .F. )
			EndIf                                      
			
			If (oMailBox:bAfterSend <> Nil) 
				bAfter := AllTrim( oMailBox:bAfterSend ) 
			
				If At( "(", bAfter ) > 0
					bAfter := Left( bAfter, At( "(", bAfter ) - 1 )
				Endif
				
				If FindFunction( bAfter )
					bAfter := &( "{ |o,a| " + bAfter + "(o,a) }" )
				Else
					bAfter := Nil
				EndIf
			EndIf

			If oMailBox:bBeforeSend <> Nil
				bBefore := AllTrim( oMailBox:bBeforeSend )
				
				If At( "(", bBefore ) > 0
					bBefore := Left( bBefore, At( "(", bBefore ) - 1 )
				EndIf
				
				If FindFunction( bBefore )
					bBefore := &( "{ |o,a| " + bBefore + "(o,a) }" )
				Else
					bBefore := Nil
				EndIf
			EndIf
			
			If oMailBox:bErrorSend <> Nil
				bError := AllTrim( oMailBox:bErrorSend )
				
				If At( "(", bError ) > 0
					bError := Left( bError, At( "(", bError ) - 1 )
				EndIf
				
				If FindFunction( bError )
					bError := &( "{ |o,a| " + bError + "(o,a) }" )
				Else
					bError := Nil
				EndIf
			EndIf
			
			oSentFolder 	:= oMailBox:GetFolder( MBF_SENT + MBF_DATE )			
			oError := WFStream()
			::oSmtpSrv:cName := AllTrim( oMailBox:cSmtpServer )
			::oSmtpSrv:nPort := oMailBox:nSmtpPort
			bLastError := ErrorBlock( { |e| oSelf:Error( e, oLogFile ) } )
			nC1 := 1			
			
			//---------------------------------------------------------
			// Envia os arquivos disponíveis na pasta Outbox.
			//---------------------------------------------------------
			While ( nC1 <= Len( aFiles ) )
				//---------------------------------------------------------
				// Faz a conexão com o servidor de envio.
				//---------------------------------------------------------
				If ( lConnected := ::InitServer( oMailBox, oLogFile ) )
					lConnected := ::oSmtpSrv:Connect( oLogFile )
				EndIf
				
				If !( lConnected )
					Exit
				EndIf
				
				cFile := aFiles[ nC1, 1 ]
				If !( lSendErr )
					cMsg := "[#%c|%c]%c"
					cMsg := FormatStr( cMsg, { StrZero( nC1, 4 ), Left( Time(), 5), Upper( oOutboxFolder:cRootPath + "\" + cFile ) } )
					WFConOut( cMsg, oLogFile, .F., .F. )
					
					If !( oOutboxFolder:FileExists( cFile ) )
						nC1++
						Loop
					EndIf
					
					aTo := {}
					nAux := 1
					cBody := Nil
					cMessage := oOutboxFolder:LoadFile( cFile )
					
					If ( nPos1 := At( "<wfbodytag>", cMessage ) ) > 0 .And. ( nPos2 := At( "</wfbodytag>", cMessage ) ) > 0
						cBody := Substr( cMessage, nPos1 + 11, nPos2 - ( nPos1 + 11 ) )
						cMessage := Stuff( cMessage, nPos1, ( nPos2 + 12 ) - nPos1, "" )
					Else
						cMessage := StrTran( cMessage, "'+chr(10)+'", "" )
						cMessage := StrTran( cMessage, "'+chr(13)+'", "" )
						cMessage := StrTran( cMessage, "'+chr(34)+'", '"' )
					EndIf
					
					aMessage := &(cMessage)
					
					If Len( aDest := WFTokenChar( aMessage[ MSG_TO ], ";" ) ) > 0
						AEval( aDest, { |x| AAdd( aTo, x ) } )
					EndIf
					
					If Len( aDest := WFTokenChar( aMessage[ MSG_CC ], ";" ) ) > 0
						AEval( aDest, { |x| AAdd( aTo, x ) } )
					EndIf
					
					If Len( aDest := WFTokenChar( aMessage[ MSG_BCC ], ";" ) ) > 0
						AEval( aDest, { |x| AAdd( aTo, x ) } )
					EndIf

					If ( Len( aTo ) == 0 )
						oOutboxFolder:MoveFiles( cFile, oErrorFolder )
						cMsg := STR0008 //"Nao foi especificado o(s) endereco(s) do(s) destinatario(s) para o envio."
						WFConOut( cMsg, oLogFile, .F. )
						cMsg := STR0009 //"Mensagem disponivel em: "
						cMsg += oErrorFolder:cRootPath + "\" + cFile
						WFConOut( cMsg, oLogFile, .F. )
						nC1++
						Loop
					EndIf

					If( nFormaEnvio == 2 ) // Forma de envio individual. 
						  aMessage[ MSG_TO  ] 	:= aMessage[ MSG_CC  ] := aMessage[ MSG_BCC ] := cMessage := ""
						  nCont 				:= Len ( aTo ) 	
					EndIf 
				
					//---------------------------------------------------------
					// Bloco para envio dos arquivos para os destinatários.
					//---------------------------------------------------------				    
				    For nC2 := 1 to nCont  
				        If( nFormaEnvio == 2 ) // Forma de envio individual.
					 		aMessage[ MSG_TO ]		 := aTo[ nC2 ]
				        EndIf 
				        
						::oSmtpSrv:oMsg          := TMailMessage():New()
						::oSmtpSrv:oMsg:cFrom    := aMessage[ MSG_FROM    ]
						::oSmtpSrv:oMsg:cTo      := aMessage[ MSG_TO      ]
						::oSmtpSrv:oMsg:cCC      := aMessage[ MSG_CC      ]
						::oSmtpSrv:oMsg:cBCC     := aMessage[ MSG_BCC     ]
						::oSmtpSrv:oMsg:cSubject := aMessage[ MSG_SUBJECT ]
						
						If Lower( aMessage[ MSG_BODYTYPE ] ) == "text"
							::oSmtpSrv:oMsg:MsgBodyType( Lower( aMessage[ MSG_BODYTYPE ] ) )
						EndIf
						
						::oSmtpSrv:oMsg:MsgBodyEncode( aMessage[ MSG_ENCODE ] )
						
						If cBody == Nil
							::oSmtpSrv:oMsg:cBody := aMessage[ MSG_BODY ]
						Else
							::oSmtpSrv:oMsg:cBody := cBody
						EndIf
						
						If Len( aMessage[ MSG_ATTACHS ] ) > 0
							For nC3 := 1 to Len( aMessage[ MSG_ATTACHS ] )
								If ValType( aMessage[ MSG_ATTACHS ][ nC3 ] ) == "A"
									If File( aMessage[ MSG_ATTACHS ][ nC3 ][ 1 ] )
										::oSmtpSrv:oMsg:AttachFile( aMessage[ MSG_ATTACHS ][ nC3 ][ 1 ] )
										::oSmtpSrv:oMsg:AddAttHTag( aMessage[ MSG_ATTACHS ][ nC3 ][ 2 ] )
									EndIf
								Else
									If File( aMessage[ MSG_ATTACHS ][ nC3 ] )
										::oSmtpSrv:oMsg:AttachFile( aMessage[ MSG_ATTACHS ][ nC3 ] )
									EndIf
								EndIf
							Next
						EndIf
						
						If Len( aMessage[ MSG_HEADERS ] ) > 0
							For nC3 := 1 to Len( aMessage[ MSG_HEADERS ] )
								::oSmtpSrv:oMsg:AddCustomHeader( aMessage[ MSG_HEADERS ][ nC3 ][ 1 ], aMessage[ MSG_HEADERS ][ nC3 ][ 2 ] )
							Next
						EndIf
						
						BEGIN SEQUENCE
						
							If bBefore <> NIL
								Eval( bBefore, ::oSmtpSrv:oMsg, aMessage )
							EndIf
						
							//---------------------------------------------------------
							// Efetua o envio da mensagem.
							//---------------------------------------------------------
							If ::oSmtpSrv:Send( oLogFile )
								lSendErr := .F.
								
								cFileName := Lower( StrTran(cFile, ".WFM", "") )
								cAliasAux := Alias()
								
							    //---------------------------------------------------------
								// Altera o status do registro para enviado.
								//---------------------------------------------------------
								DbSelectArea( "WFA" )
							    DbSetOrder( 2 )
							    If DbSeek( xFilial( "WFA" ) + cFileName )
									If WFA->WFA_TIPO == WF_OUTBOX   
										//---------------------------------------------------------
										// Proteção para atualizar a informação do status de envio 
										// somente nos registros que não estão sendo utilizados.
										//---------------------------------------------------------						
										If SimpleLock()
											If RecLock( "WFA" )
												WFA_TIPO := WF_SENT
												MsUnLock()
											EndIf
										EndIf
									EndIf
								EndIf
								
								//---------------------------------------------------------
								// Retorna o ponteiro para a tabela que estava sendo utilizada 
								//---------------------------------------------------------
								DbSetOrder( nWFAOrder )
								If !Empty( cAliasAux )
									DbSelectArea( cAliasAux )
								EndIf
								
								//---------------------------------------------------------
								// Caso tenha sido definida, executa a função de  
								// complemento do envio.
								//---------------------------------------------------------
								If bAfter <> Nil  
									Eval( bAfter, ::oSmtpSrv:oMsg, aMessage )
								EndIf
	
								//---------------------------------------------------------
								// Move o arquivo para a pasta de itens enviados.
								//---------------------------------------------------------
								If ( nFormaEnvio == 1 ) // Forma de envio em lote
									oOutboxFolder:MoveFiles( cFile, oSentFolder )	 
									
									cMsg := Replicate( "-", 40 )
		 					     	WFConOut( cMsg, oLogFile, .F. ) 
								Else     
									If ( Len( aTo ) == 1 )
										oOutboxFolder:MoveFiles( cFile, oSentFolder )
									Else								
										If ( nC2 == Len( aTo ) )
											oOutboxFolder:MoveFiles( cFile, oSentFolder )
										EndIf								
									EndIf  
								
									If ( nC2 < Len( aTo ) )
										cMsg := Replicate( "-", 40 )
										WFConOut( cMsg, oLogFile, .F. )
									EndIf
								EndIf
							Else
								lSendErr := .T.
								
								//---------------------------------------------------------
								// Desconecta do servidor SMTP.
								//---------------------------------------------------------
								::oSmtpSrv:Disconnect( oLogFile )
								
								If ( oMailBox:nConnType == WFC_DIALUP ) .And. ( ::oDialUp <> Nil )
									::oDialUp:Disconnect( oLogFile )
								EndIf
								
								::oServer := Nil
								
								//---------------------------------------------------------
								// Move o arquivo para a pasta de erro.
								//---------------------------------------------------------
								If ( nFormaEnvio == 1 ) // Forma de envio em lote
									oOutboxFolder:MoveFiles( cFile, oErrorFolder )
									nC1++
								Else     
									If ( Len( aTo ) == 1 )
										oOutboxFolder:MoveFiles( cFile, oErrorFolder )
										nC1++
									Else								
										If ( nC2 < Len( aTo ) )
											cMsg := Replicate( "-", 40 )
											WFConOut( cMsg, oLogFile, .F. )
											
											//---------------------------------------------------------
											// Se existirem mais destinatários, realiza novamente
											// a conexão com o servidor para envio.
											//---------------------------------------------------------
											If ( lConnected := ::InitServer( oMailBox, oLogFile ) )
												lConnected := ::oSmtpSrv:Connect( oLogFile )
											EndIf											
										EndIf
										
										aMessage[ MSG_BODY ] := "<wfbodytag></wfbodytag>"
										cMessage := AsString( aMessage, .T. )
										
										If ( nPos1 := At( "<wfbodytag>", cMessage ) ) > 0
											cMessage := Stuff( cMessage, nPos1 + 11, 0, cBody )
										EndIf
										
										//---------------------------------------------------------
										// Faz uma cópia do arquivo na pasta de Erro.
										//---------------------------------------------------------
										If ( nPos1 := At( ".", cFile ) ) > 0
											cWFMFile := Left( cFile, nPos1 - 1 ) + "_" + StrZero( nC2, 2 ) + SubStr( cFile, nPos1 )
										EndIf
										
										oErrorFolder:SaveFile( cMessage, cWFMFile )
										
										//---------------------------------------------------------
										// Se for o último destinatário, move o arquivo para a 
										// pasta Enviados para continuar com o envio.
										//---------------------------------------------------------
										If ( nC2 == Len( aTo ) )
											oOutboxFolder:MoveFiles( cFile, oSentFolder )
											nC1++
										EndIf
									EndIf
								EndIf

								If ( bError <> Nil )
									Eval( bError, ::oSmtpSrv:oMsg, aMessage )  
								EndIf
							EndIf
						
						END SEQUENCE
						
						//---------------------------------------------------------
						// Altera o conteúdo da variável, conforme necessidade
						// para prosseguir com o envio dos demais arquivos.
						//---------------------------------------------------------
						If ( lSendErr )
							If ( nFormaEnvio == 1 ) // Forma de envio em lote
								lSendErr := .F.
							Else   						
								If ( nC2 == Len( aTo ) )
									lSendErr := .F.
								EndIf
							EndIf
						EndIf
					Next
				EndIf
			End
			
			//---------------------------------------------------------
			// Desconecta do servidor SMTP.
			//---------------------------------------------------------
			If ( ::oServer <> Nil )
				::oSmtpSrv:Disconnect( oLogFile )
				
				If ( oMailBox:nConnType == WFC_DIALUP ) .And. ( ::oDialUp <> Nil )
					::oDialUp:Disconnect( oLogFile )
				EndIf
				
				::oServer := Nil
			EndIf
			
			If !lSendErr .And. ValType( aMessage ) == "A" .And. Len( aMessage ) > 10
				If Len( aMessage[11] ) > 0
					WFConOut(STR0026, oLogFile, .F. ) //"Arquivos enviados como anexos e removidos devido a solicitação"*/
					For nInd := 1 to Len( aMessage[11] )
						If File( aMessage[11, nInd] )
							WFConOut(". " + aMessage[11, nInd], oLogFile, .F. )
							FErase( aMessage[11, nInd] )
						EndIf
					Next
				EndIf
			EndIf

			WFConOut( FormatStr( STR0030, oMailBox:cRecipient ), oLogFile, .F. )  //"Liberando a caixa de saída [%c]"*/
            
			//---------------------------------------------------------
			// Fecha e exclui o semáforo.
			//---------------------------------------------------------
            FClose( nHandle )
            FErase( cLCKFile )
		
			ErrorBlock( bLastError )
			oLogFile:Close()
		Else
			WFConOut( FormatStr( STR0027, oMailBox:cRecipient ), oLogFile, .F. ) //"Processo de envio de mensagens do workflow em execução [%c]."*/
		EndIf
	EndIf	
Return .T.

method Receive( cMailBox, lForce ) class TWFMail
	local lResult := .F.
	
	if cMailBox	<> nil
		if valtype( cMailBox ) == "C"
			lResult := ::ReceiveMail( ::GetMailBox( cMailBox ), lForce )
		else
			lResult := ::ReceiveMail( cMailBox, lForce )
		endif
	else
		return lResult
	endif
return lResult

method ReceiveAll( lForce ) class TWFMail
	local cKey := xFilial( "WF7" )
	
	if WF7->( dbSeek( cKey ) )
		while !WF7->( Eof() ) .and. ( WF7->WF7_FILIAL == cKey )
			::Receive( AllTrim( WF7->WF7_PASTA ), lForce )
			WF7->( dbSkip() )
		end
	endif
return

method ReceiveMail( oMailBox, lForce ) class TWFMail
	local nC
	Local nMaxMsg := WFGetMV("MV_WFMXNUM", 10000 )
	local lResult := .F.
	local cEMLFile
	Local cMsg
	Local cProtocol
	local oLogFile 
	Local oError
	Local oInboxFolder
	local bBefore
	Local bAfter
	Local bError
	Local bLastError
	
	default lForce := .F.
	
	if oMailBox	== nil
		return lResult
	endif
	
	if oMailBox:lExists
		if !( oMailBox:lActive ) .and. !( lForce )
			return lResult
		endif
		
		if oMailBox:bBeforeReceive <> nil
			bBefore := AllTrim( oMailBox:bBeforeReceive )
			if at( "(", bBefore ) > 0
				bBefore := left( bBefore, at( "(", bBefore ) - 1 )
			endif
			
			if FindFunction( bBefore )
				bBefore := &( "{ |oMsg,oMbox| " + bBefore + "(oMsg,oMbox) }" )
			else
				bBefore := nil
			endif
		endif
		
		if oMailBox:bAfterReceive <> nil
			bAfter := AllTrim( oMailBox:bAfterReceive )
			if at( "(", bAfter ) > 0
				bAfter := left( bAfter, at( "(", bAfter ) - 1 )
			endif
			
			if FindFunction( bAfter )
				bAfter := &( "{ |oMsg,oMbox,cPath| " + bAfter + "(oMsg,oMbox,cPath) }" )
			else
				bAfter := nil
			endif
		endif
		
		if oMailBox:bErrorReceive <> nil
			bError := AllTrim( oMailBox:bErrorReceive )
			if at( "(", bError ) > 0
				bError := left( bError, at( "(", bError ) - 1 )
			endif
			
			if FindFunction( bError )
				bError := &( "{ |o,a| " + bError + "(o,a) }" )
			else
				bError := nil
			endif
		endif
		
		oError := WFStream()
		oLogFile := WFFileSpec( oMailBox:cRootPath + "\" + oMailBox:cRecipient + ".log" )
		oLogFile:WriteLN( Replicate("*", 80 ) )
		cMsg := FormatStr( STR0010, oMailBox:cRecipient ) //"VERIFICANDO CAIXA DE ENTRADA... [%c]"
		WFConOut( cMsg, oLogFile )
		cProtocol := WFGetProtocol()[2]
		do case
			case cProtocol == "MAPI"
				::oPop3Srv:cName := AllTrim( oMailBox:cMapiServer )
				::oPop3Srv:nPort := oMailBox:nMapiPort
			case cProtocol == "IMAP"
				::oPop3Srv:cName := AllTrim( oMailBox:cImapServer )
				::oPop3Srv:nPort := oMailBox:nImapPort
			otherwise
				::oPop3Srv:cName := AllTrim( oMailBox:cPop3Server )
				::oPop3Srv:nPort := oMailBox:nPop3Port
		end

		if ::InitServer( oMailBox, oLogFile )
			if ::oPop3Srv:Connect( oLogFile )
				nMsg := ::oPop3Srv:GetNumMsgs()
				if ( nMsg > 0 .and. nMsg < nMaxMsg )
					cMsg := STR0011 //"Ha %c nova(s) mensagen(s) a receber"
					WFConOut( FormatStr( cMsg, StrZero( nMsg, 4 ) ), oLogFile, .F. )
					for nC := 1 to nMsg
						if ::oPop3Srv:Receive( nC, oLogFile )
							if bBefore <> nil
								eval( bBefore, ::oPop3Srv:oMsg, oMailBox )
							endif
				
							oInboxFolder := oMailBox:GetFolder( MBF_INBOX )
							While oInboxFolder:FileExists( cEMLFile := ChgFileExt( CriaTrab( , .F.), ".eml" ) )
							end
				
							oInboxFolder:SaveFile( ::oPop3Srv:oMsg, cEMLFile )
							cMsg := "[#%c|%c]%c"
							cMsg := FormatStr( cMsg, { StrZero( nC, 4 ), left( Time(), 5), upper( oInboxFolder:cRootPath + "\" + cEMLFile ) } )
							WFConOut( cMsg, oLogFile, .F., .F. )
							cMsg := STR0012 + ::oPop3Srv:oMsg:cFrom //"De......: "
							WFConOut( cMsg, oLogFile, .F. )
							cMsg := STR0013 + ::oPop3Srv:oMsg:cSubject //"Assunto.: "
							WFConOut( cMsg, oLogFile, .F. )
							::oPop3Srv:DeleteMsg( nC )
				
							if bAfter <> nil
								::oPop3Srv:oMsg:Clear()
								::oPop3Srv:oMsg:Load( oInboxFolder:cRootPath + "\" + cEMLFile )
								eval( bAfter, oInboxFolder:cRootPath + "\" + cEMLFile, ::oPop3Srv:oMsg, oMailBox )
							endif
						else                     
							cMsg := STR0014 //"Ocorreu um erro na leitura da mensagem na caixa de entrada."
							WFConOut( cMsg, oLogFile, .F. )
						endif
					next
				elseif nMsg >= nMaxMsg
					WFConOut( STR0023, oLogFile, .F. ) //"Verificacao da caixa postal CANCELADA. Limite de mensagens excedido."
					cMsg := FormatStr( STR0024, { allTrim(str(nMsg)), allTrim(str(nMaxMsg)) } ) //"A quantidade de %c mensagens excedeu o limite de %c"
					WFConOut( cMsg, oLogFile, .F. )
				else
					WFConOut( STR0005, oLogFile, .F. ) //"Nada consta."
				endif
				::oPop3Srv:Disconnect( oLogFile )
			endif
			::oServer := nil
			oLogFile:Close()

			if ( oMailBox:nConnType == WFC_DIALUP ) .and. ( ::oDialUp <> nil )
				::oDialUp:Disconnect( oLogFile )
			endif
		endif
	endif
return lResult

method Error( oE, oLogFile ) class TWFMail
	Local cMsg
	Local nC := 2
	Local oStream := WFStream()
	
	If oE:GenCode > 0
		ConOut( replicate( "*",79 ) )
		oStream:WriteLN( oE:Description )
		WFConOut( oE:Description, oLogFile, .F., .F. )

		While !(ProcName( nC ) == "")
			cMsg := "Called from: "
			cMsg += ProcName( nC )
			cMsg += " - Line: " + AllTrim( str( ProcLine( nC ) ) )
			oStream:WriteLN( cMsg )
			WFConOut( cMsg, oLogFile, .F., .F. )
			nC++
		end

		ConOut( replicate( "*", 79 ) )
		::NotifyAdmin( , WF_NOTIFY, oStream:GetBuffer() )
		BREAK 
	Endif
return

//-------------------------------------------------------------------
/*/{Protheus.doc} NotifyAdmin
Método de envio das notificações de evento.

@param 	cTo			Lista de destinatários da notificação
@param	cSubject	Assunto da notificação
@param	cBody		Conteúdo da mensagem
@param	aAttachs	Vetor com os anexos
@param	lFila		Determina se a notificação veio do controle de filas
/*/
//-------------------------------------------------------------------
method NotifyAdmin( cTo, cSubject, cBody, aAttachs, lFila ) class TWFMail
	Local oMailBox
	Local lResult 	:= .F.
	Local cHtml
	Local cMailBox 	:= AllTrim( WFGetMV( "MV_WFMLBOX", "" ) )
	Local lNotifyAuto := WFGetMV( "MV_WFSNDAU", .T. )
	
	default cSubject := ""
	default cBody 	 := ""
	default aAttachs := {}
	default cTo 	 := AllTrim( WFGetMV( "MV_WFADMIN", "" ) )
	default lFila 	 := .F.
	
	if ( lResult := ( !empty( cMailBox ) .and. !Empty( cTo ) ) )
		oMailBox := ::GetMailBox( cMailBox )
		if( lResult := oMailBox:lExists )
			If ( at( "<html>", Lower( cBody ) ) > 0 .and. at( "</html>" , lower( cBody ) ) > 0 )
				cHtml := cBody
			else
				cHtml := WFHtmlTemplate( "TOTVS | Workflow", cBody, "Ocorrência" )
			EndIf 

			oMailBox:NewMessage( cTo, , , cSubject, cHtml, aAttachs )
			
			If (lNotifyAuto .Or. lFila) 
				oMailBox:Send()
			EndIf
		endif
	endif
return lResult

method Free() class TWFMail
return

/******************************************************************************
	CLASSF TWFMsgDialog
	Cria uma nova mensagem para envio a partir de uma janela de mensagem
******************************************************************************/

class TWFMsgDialog
	data cMailBox
	data cTo
	data cCC
	data cBCC
	data cBody
	data cBodyType
	data cSubject
	data cCaption
	data cHtmlFileTemp
	data aAttachs
	data aHeaders
	data lForward
	data lReply
	data lReadOnly
	data lNew
	data bOk_OnClick
	data bCancel_OnClick

	method New() CONSTRUCTOR
	method Show( cCaption )
	method LoadFile( cFileName )
	method SaveFile( cFileName )
	method BtnOk_OnClick( oDlg )
	method ImportText( cBuffer )
	method Forward()
	method Reply()
	method BrowserUpdate(oBrowser)
	method AttachsDlg()
	method AttachFile()  
	method ChkAttachFiles() 
	method AddAttachFile( oListBox, oDelButton ) 
	method DelAttachFile( nItem, oListBox, oButton )
endclass

method New() class TWFMsgDialog
	local cBuffer := ""
	
	::cMailBox 			:= space(20)
	::lForward 			:= .F.
	::lReply 			:= .F.
	::lReadOnly 		:= .F.
	::lNew 				:= .T.
	::cTo 				:= space(255)
	::cCC 				:= space(255)
	::cBCC 				:= space(255)
	::cBody 			:= space(500)
	::cSubject 			:= space(255)
	::cCaption 			:= STR0031 // "Nova mensagem" 
	::aAttachs 			:= {}
	::aHeaders 			:= {}
	::bOk_OnClick 		:= {|oDlg| ::BtnOk_OnClick(), oDlg:End() }
	::bCancel_OnClick 	:= {|oDlg| oDlg:End() }

	while file( ::cHtmlFileTemp := ChgFileExt(CriaTrab( , .F.),".htm") )
	end

	cBuffer += '<html>' + CHR(13) + CHR(10)
	cBuffer += '<head>' + CHR(13) + CHR(10)
	cBuffer += '<title>Untitled Document</title>' + CHR(13) + CHR(10)
	cBuffer += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">' + CHR(13) + CHR(10)
	cBuffer += '</head>' + CHR(13) + CHR(10)

	WFSaveFile( ::cHtmlFileTemp, cBuffer )
return

method Forward() class TWFMsgDialog
	local oMsg := TWFMsgDialog():New()

	oMsg:lForward 	:= .F.
	oMsg:lReply 	:= .F.
	oMsg:lReadOnly 	:= .F.
	oMsg:cSubject 	:= "RE:" + ::cSubject
	oMsg:cBody 		:= ::cBody
	WFSaveFile( oMsg:cHtmlFileTemp, ::cBody )
return oMsg:Show(STR0032) // "Encaminhar mensagem..."

method Reply() class TWFMsgDialog
	local oMsg := TWFMsgDialog():New()

	oMsg:lForward 	:= .F.
	oMsg:lReply 	:= .F.
	oMsg:lReadOnly 	:= .F.
	oMsg:cTo 		:= ::cMailBox
	oMsg:cSubject 	:= "RE:" + ::cSubject
	oMsg:cBody 		:= ::cBody
	WFSaveFile( oMsg:cHtmlFileTemp, ::cBody )
return oMsg:Show(STR0033) // "Responder mensagem..."

method AttachsDlg() class TWFMsgDialog
	local oSelf
	Local oDlg
	Local oAttachs
	Local oAddButton
	Local oDelButton
	local cTitle := STR0034 // "Anexos"
	local aFiles := AClone( ::aAttachs )
		
	oSelf := self

	DEFINE MSDIALOG oDlg FROM 0,0 TO 300,450 TITLE cTitle PIXEL
	
	@ 15,05 LISTBOX oAttachs FIELDS HEADER STR0035 FIELDSIZES 255 SIZE 170,140 OF oDlg PIXEL // "Arquivos"
	@ 15,180 BUTTON oAddButton PROMPT STR0036 SIZE 40,12 FONT oDlg:oFont OF oDlg PIXEL ACTION ( oSelf:AddAttachFile( oAttachs, oDelButton ) ) // "Adicionar..."
	@ 28,180 BUTTON oDelButton PROMPT STR0037 SIZE 40,12 FONT oDlg:oFont OF oDlg PIXEL ACTION ( oSelf:DelAttachFile( oAttachs, oDelButton, oAttachs:nAt ) ) // "Remover"

	::ChkAttachFiles()

	oAttachs:SetArray( aFiles )
	oAttachs:bLine := {|| { oSelf:aAttachs[ oAttachs:nAt ] } }
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( EnchoiceBar( oDlg, { || lResult := .T., oDlg:End() }, {|| oDlg:End() } ) )
	
	::aAttachs := aFiles
return

method ChkAttachFiles() class TWFMsgDialog
	if len( aFiles ) == 0
		AAdd( ::aAttachs, STR0038 ) // 'Selecione um arquivo a partir do botao "Adicionar..."'
		oDelButton:SetDisable()
	endif
return

method AddAttachFile( oListBox, oDelButton ) class TWFMsgDialog
	local cFileName
	Local cFiltro := STR0054 + " (*.*)| *.*" // Todos os arquivos

	if !Empty( cFileName := cGetFile( cFiltro, STR0039, 1, ,.F.) ) // "Anexar arquivo"
		if File( cFileName )
			if lFlag
				::aAttachs := {}
			endif
			
			if AScan( ::aAttachs, { |x| upper(Alltrim(x)) == upper(Alltrim(cFileName)) } ) == 0
				AAdd( ::aAttachs, cFileName )
			endif
			oButton:SetEnable()
			oListBox:SetArray( ::aAttachs )
			oListBox:Refresh()	
		endif
	endif
return

method DelAttachFile( nItem, oListBox, oButton ) class TWFMsgDialog
	default nItem := 0

	if len( ::aAttachs ) > 0
		if ( nItem > 0 ) .and. ( nItem <= len( ::aAttachs ) )
			ADel( ::aAttachs, nItem )
			::aAttachs := ASize( ::aAttachs, len( ::aAttachs ) - 1 )
		endif
		
		if len( ::aAttachs ) == 0
			oButton:SetDisable()
		endif
		oListBox:SetArray( ::aAttachs )
		oListBox:Refresh()
	endif
return

method LoadFile( cFileName ) class TWFMsgDialog
	local oMsg
	local nPos1
	Local nPos2
	local aMessage
	
	default cFileName := "" 
	
	::lNew 		:= .F.
	::lForward 	:= .T.
	::lReply 	:= .T.
	::lReadOnly := .T.
	::cCaption 	:= cFileName
	
	if file( cFileName )
		if upper( ExtractExt( cFileName ) ) == ".EML"
			oMsg := TMailMessage():New()
			oMsg:Load( cFileName )
			::cMailBox 	:= oMsg:cFrom
			::cTo 		:= oMsg:cTo
			::cTo 		:= StrTran( ::cTo, "<", "" )
			::cTo 		:= StrTran( ::cTo, ">", "" )
			::cCC 		:= oMsg:cCC
			::cBCC 		:= oMsg:cBCC
			::cSubject 	:= oMsg:cSubject
			::cBody 	:= oMsg:cBody
		elseif upper( ExtractExt( cFileName ) ) == ".WFM"
			aMessage := WFLoadFile( cFileName ) 
			if ( nPos1 := at( "<wfbodytag>", aMessage ) ) > 0 .and. ( nPos2 := at( "</wfbodytag>", aMessage ) ) > 0
				::cBody  := substr( aMessage, nPos1 + 11, nPos2 - ( nPos1 + 11 ) )
				aMessage := stuff( aMessage, nPos1, ( nPos2 + 12 ) - nPos1, "" )
				aMessage := &(aMessage)
			else
				aMessage := strtran( aMessage, "'+chr(10)+'", "" )
				aMessage := strtran( aMessage, "'+chr(13)+'", "" )
				aMessage := strtran( aMessage, "'+chr(34)+'", '"' )
				aMessage := &(aMessage)
				::cBody	 := aMessage[ MSG_BODY ]
			endif
			::cMailBox  := aMessage[ MSG_FROM ]
			::cTo		:= aMessage[ MSG_TO ]
			::cCC		:= aMessage[ MSG_CC ]
			::cBCC		:= aMessage[ MSG_BCC ]
			::cSubject	:= aMessage[ MSG_SUBJECT ]
			::aAttachs	:= aMessage[ MSG_ATTACHS ]
		endif
		WFSaveFile( ::cHtmlFileTemp, ::cBody )
	else
		::lForward 	:= .F.
		::lReply 	:= .F.
	endif
return
                    
method Show( cTitle ) class TWFMsgDialog
	local lHtml := .T.
	Local lSend := .T.
	Local lResult := .F.
	local nC
	Local nPos := 1
	Local nFolder := 1
	local aMailBox := {}
	Local aCmdBar := {}
	Local aFolders := { STR0040, STR0041 } // "Formato Texto" // "Formato Html"
	local cAttachs
	Local cBodyFormat := "text"
	local oSelf
	Local oDlg
	Local oFolder
	Local oFont
	Local oFrom
	Local oTo
	Local oCC
	Local oBCC
	Local oBody
	Local oSubject
	Local oAttachs
	Local oHeaders
	local oBrowser
	Local oBtnTo
	Local oBtnCC
	Local oBtnBCC
	Local oBtnAttachs
	Local oBtnImport
	Local oChkBtnHtml
	Local oChkBtnSend
	
	default cTitle := ::cCaption

	oSelf := self
		
	::cMailBox 	:= PadR( ::cMailBox, 20 )
	::cTo 		:= PadR( ::cTo, 255 )
	::cCC 		:= PadR( ::cCC, 255 )
	::cBCC 		:= PadR( ::cBCC, 255 )
	::cSubject 	:= PadR( ::cSubject, 255 )
	::cBody 	:= PadR( ::cBody, Max( 500, len( ::cBody ) ) )
	cAttachs 	:= PadR( WFUnTokenChar( ::aAttachs, ";" ), 300 )

   	aMailBox := WFMBoxList()
	
	DEFINE MSDIALOG oDlg FROM 0,0 TO 480, 640 TITLE cTitle PIXEL
	
	@ 15, 05 SAY "De:" SIZE 33, 11 OF oDlg PIXEL
	
   	if len( aMailBox ) > 0
   		if empty( ::cMailBox )
   			::cMailBox := aMailBox[1]
   		endif
   		
		if ::lReadOnly
			@ 15, 50 MSGET oFrom VAR ::cMailBox SIZE 265, 10 OF oDlg PIXEL 
		else
			@ 15, 50 COMBOBOX oFrom VAR ::cMailBox ITEMS aMailBox SIZE 265, 10 OF oDlg PIXEL
		endif
	else
	   	::cMailBox := STR0042 // "Crie uma caixa de correio pelo Configurador (SIGACFG)"
		@ 15, 50 MSGET oFrom VAR ::cMailBox SIZE 265, 10 OF oDlg PIXEL 
	   	::lReply 	:= .F.
	   	::lForward 	:= .F.
	   	::lReadOnly := .T.
	endif

	@ 28, 05 BUTTON oBtnTo PROMPT STR0043 SIZE 40, 12 FONT oDlg:oFont OF oDlg PIXEL // "Para..." 
	@ 28, 50 MSGET oTo VAR ::cTo SIZE 265,10 OF oDlg PIXEL 
	@ 41, 05 BUTTON oBtnCC PROMPT STR0044 SIZE 40, 12 OF oDlg PIXEL // "C/Copia..."
	@ 41, 50 MSGET oCC VAR ::cCC SIZE 265,10 OF oDlg PIXEL 
	@ 54, 05 BUTTON oBtnBCC PROMPT STR0045 SIZE 40, 12 OF oDlg PIXEL // "Oculto..."
	@ 54, 50 MSGET oBCC VAR ::cBCC SIZE 265, 10 OF oDlg PIXEL
	@ 67, 05 SAY STR0046 SIZE 33,11 OF oDlg PIXEL // "Assunto:"
	@ 67, 50 MSGET oSubject VAR ::cSubject SIZE 265, 10 OF oDlg PIXEL
	@ 80, 05 BUTTON oBtnAttachs PROMPT STR0047 SIZE 40, 12 OF oDlg PIXEL ACTION ( ::AttachsDlg() ) // "Anexos..."
	@ 80, 50 MSGET oAttachs VAR cAttachs SIZE 265, 10 OF oDlg PIXEL
	@ 93, 05 FOLDER oFolder ITEMS aFolders[1], aFolders[2] OPTION nFolder SIZE 310, 132 OF oDlg PIXEL
	@ 0, 0 GET oBody VAR ::cBody MEMO SIZE 310, 120 OF oFolder:aDialogs[1] PIXEL
	oBrowser := TiBrowser():New(0, 0, 310, 120, '', oFolder:aDialogs[2] )

	@ 225, 05 BUTTON oBtnImport PROMPT STR0048 SIZE 40, 12 OF oDlg PIXEL ACTION ( ::ImportText( @::cBody ), oBody:Refresh(), oSelf:BrowserUpdate(oBrowser) ) // "Importar..."
	@ 225, 50 CHECKBOX oChkBtnHtml VAR lHtml PROMPT STR0049 SIZE 150, 10 OF oDlg PIXEL // "Enviar no formato HTML"
	@ 225, 150 CHECKBOX oChkBtnSend VAR lSend PROMPT STR0050 SIZE 150, 10 OF oDlg PIXEL // "Enviar imediatamente"

	if ::lReadOnly
		oFrom:SetDisable()
		oBtnTo:SetDisable()
		oTo:lReadOnly := .T.
		oBtnCC:SetDisable()
		oCC:lReadOnly := .T.
		oBtnBCC:SetDisable()
		oBCC:lReadOnly := .T.
		oSubject:lReadOnly := .T.
		oBtnAttachs:SetDisable()
		oAttachs:lReadOnly := .T.
		oBody:lReadOnly := .T.
		oBtnImport:SetDisable()
		oChkBtnHtml:SetDisable()
		oChkBtnSend:SetDisable()
	endif

	if ::lReply
		AAdd( aCmdBar, { "MSGREPLY", {|| oSelf:Reply() }, STR0051 } ) // "Responder..."
	endif

	if ::lForward
		AAdd( aCmdBar, { "MSGFORWD", {|| oSelf:Forward() }, STR0052 } ) // "Encaminhar..."
	endif
	
	if len( aCmdBar ) > 0
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( oSelf:BrowserUpdate(oBrowser), EnchoiceBar( oDlg, { || lResult := .T., Eval( oSelf:bCancel_OnClick, oDlg ) }, {|| Eval( oSelf:bCancel_OnClick, oDlg ) },, aCmdBar ) )
	else
		if ::lReadOnly
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT (  oSelf:BrowserUpdate(oBrowser), EnchoiceBar(oDlg, {|| lResult := .T., Eval( oSelf:bCancel_OnClick, oDlg ) }, {|| Eval( oSelf:bCancel_OnClick, oDlg ) } ) )
		else
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT (  oSelf:BrowserUpdate(oBrowser), EnchoiceBar(oDlg, {|| lResult := .T., Eval( oSelf:bOk_OnClick, oDlg ) }, {|| Eval( oSelf:bCancel_OnClick, oDlg ) } ) )
		endif
	endif

	if file( ::cHtmlFileTemp )
		fErase( ::cHtmlFileTemp )
	endif
Return lResult

method BrowserUpdate(oBrowser) class TWFMsgDialog
	local cURL := "file://C:/data/system/"

	if oBrowser <> nil
		cURL += ::cHtmlFileTemp
		oBrowser:Navigate(cURL)
		oBrowser:Refresh()
	endif
return

method ImportText( cBuffer ) class TWFMsgDialog
	local cFileName
	Local cFiltro := STR0054 + " (*.*)| *.*" // Todos os arquivos
									       	
	default cBuffer := ""
	
	if !Empty( cFileName := cGetFile( cFiltro, STR0053, 1, , .F.) ) // "Importar arquivo"	
		if File( cFileName )
			cBuffer := WFLoadFile( cFileName )
			WFSaveFile( ::cHtmlFileTemp, cBuffer )
		endif
	endif
return cBuffer

method BtnOk_OnClick( lSend ) class TWFMsgDialog
	default lSend := .T.
	
	if valtype( ::aAttachs ) == "C" 
		if empty( ::aAttachs )
			::aAttachs := nil
		else
			::aAttachs := WFTokenChar( ::aAttachs, ";" )
		endif
	endif
	WFNewMsg( ::cMailBox, ::cTo, ::cCC, ::cBCC, ::cSubject, ::cBody, ::aAttachs, ::aHeaders, ::cBodyType )
	if lSend
		WFSndMsg( ::cMailBox, .T. )
	endif
return
