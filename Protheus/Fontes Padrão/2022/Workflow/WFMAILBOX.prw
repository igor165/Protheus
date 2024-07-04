#INCLUDE "WFMAILBOX.ch"
#Include "SIGAWF.CH" 
/*
* 16/04/09 | Alan Cândido - 0548  | FNC 0000009475/2009                                |
*          |                      | Implementação de opção para remover anexos após o  |
*          |                      | envio do e-mail no método NewMessage.              |
*          |                      | Procedimentos de remoção de anexos, após o envio   |
*          |                      | da mensagem.                                       |
*/

function TWFMBoxObj( cMailBox )
return TWFMailBox():New( cMailBox )

function WFMBoxList()
	local cKey 
	local aList := {}
	
	ChkFile( "WF7" )
	if Select( "WF7" ) <> 0
		DbSelectArea( "WF7")
		if DbSeek( cKey := xFilial( "WF7" ) )
			While !Eof() .and. ( WF7_FILIAL == cKey )
				AAdd( aList, WF7_PASTA )
				DbSkip()
			end
		endif
	endif
return aList

class TWFMailBox
	data lExists
	data cRootPath
	data cRootDir
	data cRemetent
	data cAddress
	data cRecipient
	data cPop3Server
	data cUserName
	data cPassword
	data cSmtpServer
	data cSmtpUser
	data cSmtpPswd
	data cMapiServer
	data cImapServer
	data nTimeOut
	data nPop3Port
	data nSmtpPort
	data nMapiPort
	data nImapPort
	data lActive
	data nConnType
	data cConnName
	data cDialUser
	data cDialPassw
	data cDialFone
	data bAfterSend
	data bBeforeSend
	data bErrorSend
	data bAfterReceive
	data bBeforeReceive
	data bErrorReceive
	data cMailAdmin
	data oMail 
	data lSSL
	data lTLS
	data cQueueName
	
	method New( oParent ) CONSTRUCTOR
	method Recipient( cMailBox )
	method NewMessage( cTo, cCC, cBCC, cSubject, cBody, aAttachs, aHeaders, cBodyType, nEncodeMime, cSaveFile )
	method Send( lForce )
	method Receive( lForce )
	method NewFolder( cFolder )
	method GetFolder( cFolder )
	method SubStrAddr( cAddressList )
endclass

method New( oParent ) class TWFMailBox
	::oMail := oParent
	::lExists := .f.
return

method Recipient( cMailBox ) class TWFMailBox
   	Local lUpdSMTPSE := WF7->(FieldPos('WF7_SMTPSE')) > 0 .And. PadR( GetBuild() , 12 ) >=  "7.00.101202A"
   
	::lExists := .f.
	if !( cMailBox == nil )
		cMailBox := AllTrim( cMailBox )
		::cRootDir := Lower( WF_ROOTDIR + cEmpAnt + "\mail" )
		::cRootPath := Lower( ::cRootDir + "\" + cMailBox )
		WFForceDir( ::cRootPath )
		ChkFile( "WF7" )
		DbSelectArea( "WF7" )
	
		if ( ::lExists := WF7->( DbSeek( xFilial( "WF7" ) + Upper( cMailBox ) ) ) )
			::cRemetent		:= AllTrim( WF7_REMETE )	// Remetente
			::cAddress		:= AllTrim( WF7_ENDERE )	// Endereco eletronico
			::cRecipient	:= AllTrim( WF7_PASTA )		// Recipiente
			::cPop3Server	:= AllTrim( WF7_POP3SR )	// Servidor POP3
			::cUserName		:= AllTrim( WF7_CONTA )		// Conta
			::cPassword		:= AllTrim( WF7_SENHA )		// Senha
			::cSmtpServer	:= AllTrim( WF7_SMTPSR )	// Servidor SMTP
			::cSmtpUser		:= AllTrim( WF7_AUTUSU )	// Autenticacao de usuario
			::cSmtpPswd		:= AllTrim( WF7_AUTSEN )	// Autenticacao de senha
			::cMapiServer	:= AllTrim( WF7_MAPISR )	// Servidor MAPI
			::cImapServer	:= AllTrim( WF7_IMAPSR )	// Servidor IMAP
			::nTimeOut		:= WF7_TEMPO				// TimeOut
			::nPop3Port		:= WF7_POP3PR				// Porta POP3
			::nSmtpPort		:= WF7_SMTPPR				// Porta SMTP
			::nMapiPort		:= WF7_MAPIPR				// Porta MAPI
			::nImapPort		:= WF7_IMAPPR				// Porta IMAP
			::lActive		:= WF7_ATIVO				// Ativo
			::nConnType		:= WF7_TCONEX				// Tipo de conexao: LAN ou DIALUP
			::cConnName		:= AllTrim( WF7_DNOME )		// Nome da conexao
			::cDialUser		:= AllTrim( WF7_DCONTA )	// Conta de usuario
			::cDialPassw	:= AllTrim( WF7_DSENHA )	// Senha de usuario
			::cDialFone		:= AllTrim( WF7_DTELEF )	// Telefone
			
			If (lUpdSMTPSE)
			    If (alltrim(WF7_SMTPSE) == 'SSL') 
			        ::lSSL = .T.
			        ::lTLS = .F.
			    Elseif (alltrim(WF7_SMTPSE) == 'TLS')     
			    	::lSSL = .F.
			        ::lTLS = .T.
			    Else            
				    ::lSSL = .F.
			        ::lTLS = .F.
			    EndIf    
			Else
				::lSSL = .F.
			    ::lTLS = .F.
			EndIf
		
			::NewFolder( MBF_INBOX )
			IF (!Empty(::cQueueName) )
				::NewFolder( MBF_OUTBOX+"\"+::cQueueName )
			else	
			    ::NewFolder( MBF_OUTBOX )
			endif  
			::NewFolder( MBF_SENT )
		endif
	endif
return ::lExists

method NewMessage( cTo, cCC, cBCC, cSubject, cBody, aAttachs, aHeaders, cBodyType, nEncodeMime, cSaveFile, aDelFiles ) class TWFMailBox
	local nC
	local aMsg, aAttFiles := {}
	local cMsg, cMailTo, cFromAddress, cBodyTag := "<wfbodytag></wfbodytag>"
	local oOutBoxFolder
	
	default cTo := "", cCC := "", cBCC := "", cSubject := "", cBody := "", cBodyType := "html"
	default aAttachs := {}, aHeaders := {}, aDelFiles := {}
	default nEncodeMime := 0
	
	if !::lExists
		return ""
	endif
	
	cMailTo := ( cTo := WFGetAddress( cTo ) )
	if !Empty( cCC := WFGetAddress( cCC, cMailTo ) )
		if !Empty( cMailTo )
			cMailTo += ";"
		endif
		cMailTo += cCC
	endif
	
	cBCC := WFGetAddress( cBCC, cMailTo )
	cSubject := AllTrim( cSubject )
	if ValType( aAttachs ) == "C"
		aAttachs := WFTokenChar( aAttachs, ";" )
	endif

	cTo := ::SubStrAddr( cTo )
	cCC := ::SubStrAddr( cCC )
	cBCC := ::SubStrAddr( cBCC )
	if len( aAttachs ) > 0
		nC := 1
		for nC := 1 to len( aAttachs )
			if Ascan( aAttFiles, aAttachs ) == 0
				AAdd( aAttFiles, aAttachs[ nC ] )
			endif
		next
	endif
	
	cFromAddress := AllTrim( ::cRemetent ) + " <" + AllTrim( ::cAddress ) + ">"
	aMsg := { cFromAddress, cTo, cCC, cBCC, cSubject, cBodyTag, aAttachs, aHeaders, cBodyType, nEncodeMime, aDelFiles }
	cMsg := AsString( aMsg, .t. )
	if ( nPos := at( cBodyTag, cMsg ) ) > 0
		cMsg := Stuff( cMsg, nPos += 11, 0, cBody )
	endif 
	
	IF (!Empty(::cQueueName) )
	  	oOutBoxFolder := ::GetFolder( MBF_OUTBOX+"\"+::cQueueName )
	else	
	  	oOutBoxFolder := ::GetFolder( MBF_OUTBOX )
	endif  
	
	while .t.
		if cSaveFile == nil
			cSaveFile := lower( ChgFileExt( CriaTrab(,.f.), ".wfm" ) )
			if oOutBoxFolder:FileExists( cSaveFile )
				cSaveFile := nil
				loop
			endif
		else
			oOutBoxFolder:DeleteFile( cSaveFile )
			cSaveFile := lower( ChgFileExt( AllTrim( AsString( cSaveFile ) ), ".wfm" ) )
		endif
		
		while !oOutBoxFolder:FileExists( cSaveFile )
			oOutBoxFolder:SaveFile( cMsg, cSaveFile )
		end
		exit
	end
return ExtractFile( cSaveFile )

/******************************************************************************
Send
Método responsável pelo envio de mensagens
Parametros:
	lForce - pcEmpresa - Empresa para conexão
	cFila - Nome da fila que está sendo processada
******************************************************************************/
method Send( lForce, cFila ) class TWFMailBox
	if ::lExists
		::oMail:Send( self, lForce, cFila)
	endif
return

method Receive( lForce ) class TWFMailBox
	if ::lExists
		::oMail:Receive( self, lForce )
	endif
return

method NewFolder( cFolder ) class TWFMailBox
return TWFMailFolder():New( self, cFolder )

method GetFolder( cFolder ) class TWFMailBox
return TWFMailFolder():New( self, cFolder )

method SubStrAddr( cAddressList ) class TWFMailBox
	Local nC            := 0
	Local nPos          := 0
	Local aAddressList  := {}
	Local cMailAddress	:= ""
	Local lUpdHora		:= .T.
	
	default cAddressList := ""

	if !empty( cAddressList )
		ChkFile( "WF4" )
		if Select( "WF4" ) > 0		
			lUpdHora		:= WF4->(FieldPos('WF4_HRINI')) > 0
			aAddressList 	:= WFTokenChar( cAddressList, ";" )
			
			for nC := 1 to len( aAddressList )
				if ( nPos := At( "<", aAddressList[ nC ] ) ) > 0
					cMailAddress := substr( aAddressList[ nC ], nPos + 1, At( ">", aAddressList[ nC ] ) - nPos - 1 )
				else
					cMailAddress := aAddressList[ nC ]
				endif
				cMailAddress := AllTrim( cMailAddress )
				if WF4->( dbSeek( xFilial( "WF4" ) + Upper( cMailAddress ), .f. ) )
					While !(WF4->(eof())) .and. Upper( AllTrim( WF4->WF4_DE ) ) == Upper( cMailAddress )
						//Verfica se a data atual está entre a data inicio/fim
						if ( ( MsDate() >= WF4->WF4_DTINI ) .and. ( MsDate() <= WF4->WF4_DTFIM ) )
							//Verfica se a hora atual está entre a hora inicio/fim
							if ( ! lUpdHora .Or. ( Time() >= WF4->WF4_HRINI ) .and. ( Time() <= WF4->WF4_HRFIM ) )     
								aAddressList[ nC ] := lower( AllTrim( WF4->WF4_PARA ) )
								exit
							EndIf
						endif
						WF4->( dbSkip() )
					end
				endif
			next
			cAddressList := WFUnTokenChar( aAddressList, ";" )
		endif
	endif	
return cAddressList

class TWFMailFolder
	data cRootPath
	data cFolderName
	data oMailBox
	
	method New( oParent, cFolder ) CONSTRUCTOR
	method FileExists( cFile )
	method SaveFile( uValue, cFile )
	method DeleteFile( cFile )
	method GetFiles( cMaskFiles )
	method LoadFile( cFile, uVariable )
	method CopyFile( cSourceFile, cTargetFolder, cTargetFile )
	method MoveFiles( cMaskFiles, cTargetFolder )
endclass

method New( oParent, cFolder ) class TWFMailFolder
	local Result
	
	default cFolder := MBF_INBOX
	
	::oMailBox := oParent
	if ::oMailBox:lExists .and. !empty( cFolder := lower( alltrim( cFolder ) ) )
		::cFolderName := cFolder
		::cRootPath := lower( ::oMailBox:cRootPath + AllTrim( ::cFolderName ) )
		WFForceDir( ::cRootPath )
		Result := self
	else 
		Result := nil
	endif
return Result

method FileExists( cFile ) class TWFMailFolder
	default cFile := ""
	
	cFile := AllTrim( cFile )
	while left( cFile,1 ) $ "\/"
		cFile := SubStr( cFile, 2 )
	end
	
	while Right( cFile,1 ) $ "\/"
		cFile := left( cFile, len( cFile ) -1 )
	end
return file( lower( ::cRootPath + "\" + cFile ) )

method SaveFile( uValue, cFile ) class TWFMailFolder
	if ( ::oMailBox:lExists ) .and. ( uValue <> nil ) .and. ( cFile <> nil )
		if !empty( cFile := lower( AllTrim( cFile ) ) )
			while left( cFile,1 ) $ "\/"
				cFile := SubStr( cFile, 2 )
			end
	
			if valtype( uValue ) == "O"
				uValue:Save( ::cRootPath + "\" + cFile )
			else
				WFSaveFile( ::cRootPath + "\" + cFile, uValue )
			endif
		endif
	endif
return ::FileExists( cFile )

method DeleteFile( cFile ) class TWFMailFolder
	if ::FileExists( cFile := lower( alltrim( cFile ) ) )
		while left( cFile,1 ) $ "\/"
			cFile := SubStr( cFile, 2 )
		end
		
		while Right( cFile,1 ) $ "\/"
			cFile := left( cFile, len( cFile ) -1 )
		end
		fErase( ::cRootPath + "\" + cFile )
	endif
return ::FileExists( cFile )

method GetFiles( cMaskFiles ) class TWFMailFolder
	local nC
	local aFiles := {}
	
	default cMaskFiles := "*.*"
	
	cMaskFiles := lower( ::cRootPath + "\" + lower( AllTrim( cMaskFiles ) ) )
	if len( aFiles := Directory( cMaskFiles, "D" ) ) > 0
		nC := 1
		while nC <= len( aFiles )
			if upper( aFiles[ nC,5 ] ) == "D"
				ADel( aFiles, nC )
				ASize( aFiles, len( aFiles ) -1 )
			else
				nC++
			endif
		end
	endif
return aFiles

method LoadFile( cFile, uVariable ) class TWFMailFolder
	default uVariable := ""
	
	if ( cFile <> nil )
		if ::FileExists( cFile := lower( alltrim( cFile ) ) )
			if valtype( uVariable ) == "O"
				uVariable:Load( ::cRootPath + "\" + cFile )
			else
				uVariable := WFLoadFile( ::cRootPath + "\" + cFile )
			endif
		endif
	endif
return uVariable

method CopyFile( cSourceFile, oTargetFolder, cTargetFile ) class TWFMailFolder
	default cSourceFile := "", oTargetFolder := self, cTargetFile := cSourceFile
	
	cSourceFile := Lower( AllTrim( ExtractFile( cSourceFile ) ) )
	if ::FileExists( cSourceFile )
		cTargetFile := Lower( alltrim( ExtractFile( cTargetFile ) ) )
		if valtype( oTargetFolder ) == "C"
			oTargetFolder := ::oMailBox:GetFolder( Lower( alltrim( oTargetFolder ) ) )
		endif
		
		if !( ( oTargetFolder:cFolderName == ::cFolderName ) .and. ( cSourceFile == cTargetFile ) )
			__CopyFile( ::cRootPath + "\" + cSourceFile, oTargetFolder:cRootPath + "\" + cTargetFile )
		else
			WFConOut( STR0001 ) //"NAO se pode copiar o arquivo para ele mesmo."
		endif
	else
		WFConOut( STR0002 + ::cRootPath + "\" + cSourceFile ) //"Arquivo nao existente: "
	endif
return

method MoveFiles( cMaskFiles, oTargetFolder ) class TWFMailFolder
	local nC
	local aFiles
	local lResult := .f.
	
	default cMaskFiles := "*.*", oTargetFolder := self
	
	if valtype( oTargetFolder ) == "C"
		oTargetFolder := ::oMailBox:GetFolder( Lower( alltrim( oTargetFolder ) ) )
	end

	if !( oTargetFolder:cFolderName == ::cFolderName )
		if len( aFiles := ::GetFiles( cMaskFiles ) ) > 0
			for nC := 1 to len( aFiles )
				while oTargetFolder:FileExists( aFiles[nC,1] )
					oTargetFolder:DeleteFile( aFiles[nC,1] )
				end
	
				if ::FileExists( aFiles[nC,1] )
					::CopyFile( aFiles[nC,1], oTargetFolder )
					::DeleteFile( aFiles[nC,1] )
				endif
			next
			lResult := .t.
		endif
	else
		WFConOut( STR0003 ) //"Pasta ORIGEM deve ser diferente da pasta DESTINO."
	endif
return lResult            