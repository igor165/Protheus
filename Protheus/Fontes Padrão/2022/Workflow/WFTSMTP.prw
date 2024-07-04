#INCLUDE "WFTSMTP.ch"
#include "SigaWF.CH" 


/***************************
/ CLASS TWFSmtpSrv
/ Classe responsavel pelo envio de mensagens via SMTP
/***************************/

class TWFSmtpSrv
	data oMsg
	data oMailMan
	data cName
	data cUserName
	data cPassword
	data nPort
	data lConnected
	data oMailBox
	method New( oManager ) CONSTRUCTOR
	method Send( oLogFile )
	method Connect( oLogFile )
	method Disconnect( oLogFile )
	method LoadFile( cFile )
	method SaveFile( cFile )
endclass

method New( oManager ) class TWFSmtpSrv
	::oMsg := TMailMessage():New()
	::oMailMan := oManager
	::cName := "Localhost"
	::nPort := 25
	::cUserName := ""
	::cPassword := ""
	::lConnected := .f.
return

method Send( oLogFile ) class TWFSmtpSrv
	local cMsg     		:= ''
	local nError 		:= -1
	local cBCCAux		:=::oMsg:cBCC //Quando ::oMsg:Send é executado , perde se a propriedade ::cBBC      
	Local oLogNotify	:= WFStream()  
	Local oWF 			:= TWFObj()
	
	Default oLogFile 	:= WFStream()  
	
	if ::Connect( oLogFile )
		if ( ( nError := ::oMsg:Send( ::oMailMan:oServer ) ) == 0 )
			cMsg := STR0001 //"Envio de mensagem com sucesso."
			WFConOut( cMsg, oLogFile, .f. )
			cMsg := STR0002 + StrTran(::oMsg:cTo, ";", CRLF+SPACE(23)) //"Para....: "
			WFConOut( cMsg, oLogFile, .f. )
			if( !Empty( ::oMsg:cCC ), WFConOut(  STR0003 + StrTran(::oMsg:cCC, ";", CRLF+SPACE(23)), oLogFile, .f. ), nil) //"c/Copia.: "
			if( !Empty( cBCCAux ), WFConOut( STR0004 + StrTran(cBCCAux, ";", CRLF+SPACE(23)) , oLogFile, .f.), nil ) //"Oculto..: "
			cMsg := STR0005 + ::oMsg:cSubject //"Assunto.: "
			WFConOut( cMsg, oLogFile, .f. )
		else  
			cMsg := STR0019 + ::oMailMan:oServer:getErrorString(nError) // "Falha ao enviar mensagem: "
			WFConOut( cMsg, oLogFile, .f. ) 
			oLogNotify:WriteLN( cMsg ) 

			cMsg := STR0002 + ::oMsg:cTo //"Para....: "
			WFConOut( cMsg, oLogFile, .f. )
			oLogNotify:WriteLN( cMsg ) 
			
			cMsg := STR0005 + ::oMsg:cSubject //"Assunto.: "
			WFConOut( cMsg, oLogFile, .f. )   
			oLogNotify:WriteLN( cMsg ) 
              
   			//-------------------------------------------------------------------
			// Notifica administrador quando há falha no envio de mensagem. 
			//------------------------------------------------------------------- 
			If ( oWF:lNotif004 .And. !Empty( oWF:cMailAdmin ) )
	   	   		WFNotifyAdmin( , WF_NOTIFY, oLogNotify:GetBuffer( .T. ) ) 
	   		EndIf		
		end
	end	
return ( nError == 0 )

method LoadFile( cFile ) class TWFSmtpSrv
	::oMsg:Clear()
	WFConOut( STR0007 + cFile ) //"Lendo arquivo para envio: "
	::oMsg:Load( cFile )
return 

method SaveFile( cFile ) class TWFSmtpSrv
	::oMsg:Save( cFile )
return 

method Connect( oLogFile ) class TWFSmtpSrv
	local cMsg
	local nC := 1, nMax := 4, nCount, nError

	default oLogFile := WFStream()
	
	if ( ::oMailMan:oServer <> nil )
		while ( nC <= nMax ) .and. !( ::lConnected )
			if nC > 1
				::Disconnect( oLogFile )
				cMsg := "%99n# - "
				if nC < nMax
					cMsg += STR0008 //"Proxima tentativa de conexao em 20 segundos."
				else
					cMsg := STR0009 //"Ultima tentativa de conexao em 20 segundos."
				end
				cMsg := FormatStr( cMsg, nC )
				WFConOut( cMsg, oLogFile, .f. )
				Sleep( 20000 )
			end	
			cMsg := STR0010 //"Conectando no servidor"
			cMsg := FormatStr( cMsg + " %c... [ %c:%c ]", { WFGetProtocol()[1], ::cName, AllTrim( Str( ::nPort ) ) } )
			WFConOut( cMsg, oLogFile, .f. )
			nCount := 1
			nError := -1
			while ( nError <> 0 ) .and. ( nCount < 5 )
				if ( nError := ::oMailMan:oServer:SMTPConnect() ) <> 0 
					Sleep( 3000 )
				end
				nCount++
			end
			if ( nError <> 0 )
				cMsg := STR0011 //"Nao foi possivel estabelecer conexao com o servidor de e-mail. Erro: "
				WFConOut( cMsg + AsString( nError ), oLogFile, .f. )
			else
				if (::oMailBox <> nil) .and. !Empty(::oMailBox:cSmtpUser) .and. !Empty(::oMailBox:cSmtpPswd)
					cMsg := STR0012 //"Autenticando no servidor"
					cMsg := FormatStr( cMsg + " %c...", WFGetProtocol()[1] )
					WFConOut( cMsg, oLogFile, .f. )
					nCount := 1
					nError := -1
					while ( nError <> 0 ) .and. ( nCount < 5 )
						if ( nCount > 1 ) .and. ( nError <> 0 )
							Sleep( 3000 )
						end	

						nError := ::oMailMan:oServer:SmtpAuth( AllTrim( ::oMailBox:cSmtpUser ) , AllTrim( ::oMailBox:cSmtpPswd ) )
						nCount++
					end
					if ( nError <> 0 )
						cMsg := STR0013 //"Nao foi possivel autenticar no servidor %c."
						WFConOut( FormatStr( cMsg, WFGetProtocol()[1] ), oLogFile, .f. ) 
						cMsg := STR0020 + ::oMailMan:oServer:getErrorString(nError) // "Falha : "	
						WFConOut( cMsg, oLogFile, .f. ) 
					end
				end
				if ( nError == 0 )
					::lConnected := .t.	
				end
			end
			nC++
		end
	else
		cMsg := STR0014 //"O servidor de e-mail nao foi inicializado corretamente."
		WFConOut( cMsg, oLogFile, .f. )
	end
return ( ::lConnected )
	
method Disconnect( oLogFile ) class TWFSmtpSrv
	local nCount := 0, nError := -1
	local cMsg := STR0015 //"Desconectando do servidor"

	cMsg := FormatStr( cMsg + " %c...", WFGetProtocol()[1] )
	default oLogFile := WFStream()
	
	if ::oMailMan == nil
		return !( ::lConnected )
	end
	if ::oMailMan:oServer <> nil
		if ( ::lConnected )
			WFConOut( cMsg, oLogFile, .f. )
			while ( nError <> 0 ) .and. ( nCount < 10 )
				nError := ::oMailMan:oServer:SMTPDisconnect()
				if ( nCount > 0 ) .and. ( nError <> 0 )
					Sleep( 3000 )
				end
				nCount++
			end
			if ( nError <> 0 )
				cMsg := STR0016 //"Ocorreu um erro durante a desconexao. Erro: "
				WFConOut( cMsg + AsString( nError ), oLogFile, .f. )
			else
				::lConnected := .f.
			end
		end
	else
		cMsg := STR0014 //"O servidor de e-mail nao foi inicializado corretamente."
		WFConOut( cMsg, oLogFile, .f. )
	end
	
return !( ::lConnected )


