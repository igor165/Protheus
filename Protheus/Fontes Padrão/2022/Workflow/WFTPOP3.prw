#INCLUDE "WFTPOP3.ch"
#include "SigaWF.CH" 

STATIC __oWFPop3Obj := nil

function TWFPop3Obj( lForce )
	default lForce := .f.
	if __oWFPop3Obj == nil
		__oWFPop3Obj := TWFPop3Srv():New()
	else
		if lForce 
			__oWFPop3Obj := NIL
			TWFPop3Obj()
		end
	end
return __oWFPop3Obj 

class TWFPop3Srv
	data oMsg
	data oMailMan
	data cName
	data nPort
	data lConnected
	method New( oManager ) CONSTRUCTOR
	method Receive( nMsg, oLogFile )
	method Connect( oLogFile )
	method Disconnect( oLogFile )
	method GetNumMsgs( nMsg )
	method DeleteMsg( nMsg )
endclass

method New( oManager ) class TWFPop3Srv
	::oMsg := TMailMessage():New()
	::oMailMan := oManager
	::cName := "Localhost"
	::nPort := 110
	::lConnected := .f.
return

method Receive( nMsg, oLogFile ) class TWFPop3Srv
	local cMsg
	local nCount, nError
	
	default nMsg := 1
	default oLogFile := WFStream()
	::oMsg := TMailMessage():New()
	
	if ::Connect( oLogFile )
		::GetNumMsgs( @nCount )
		if ( nCount > 0 )
			if ( ( nError := ::oMsg:Receive( ::oMailMan:oServer, nMsg ) ) <> 0 )
				cMsg := STR0001 //"Ocorreu um erro ao receber a mensagem: "
				cMsg += "%999n"
				WFConOut( FormatStr( cMsg, nMsg ), oLogFile, .f. )
			end
		else
			cMsg := STR0002 //"Nao ha mensagens na caixa de entrada."
			WFConOut( cMsg, oLogFile, .f. )
		end
	end
	
return ( nError == 0 )

method Connect( oLogFile ) class TWFPop3Srv
	local cMsg
	local nC := 1, nMax := 4, nCount, nError

	default oLogFile := WFStream()
	
	if ( ::oMailMan:oServer <> nil )
		while ( nC <= nMax ) .and. !( ::lConnected )
			if nC > 1
				::Disconnect( oLogFile )
				cMsg := "%99n# - "
				if nC < nMax
					cMsg += STR0003 //"Proxima tentativa de conexao em 20 segundos."
					cMsg := FormatStr( cMsg, nC )
				else
					cMsg += STR0004 //"Ultima tentativa de conexao em 20 segundos."
					cMsg := FormatStr( cMsg, nC )
				end
				WFConOut( cMsg, oLogFile, .f. )
				Sleep( 20000 )
			end	
			cMsg := STR0005 //"Conectando no servidor"
			cMsg += " %c... [ %c:%c ]"
			cMsg := FormatStr( cMsg, { WFGetProtocol()[2], ::cName, AllTrim( Str( ::nPort ) ) } )
			WFConOut( cMsg, oLogFile, .f. )
			nCount := 1
			nError := -1
			while ( nError <> 0 ) .and. ( nCount < 5 )
				if ( nError := ::oMailMan:oServer:POPConnect() ) <> 0 
					Sleep( 3000 )
				end
				nCount++
			end
			if ( nError <> 0 )
				cMsg := STR0006 //"Nao foi possivel estabelecer conexao com o servidor de e-mail. Erro: "
				cMsg += AsString( nError )
				WFConOut( cMsg, oLogFile, .f. )
			else
				::lConnected := .t.	
			end
			nC++
		end
	else
		cMsg := STR0007 //"O servidor de e-mail nao foi inicializado corretamente."
		WFConOut( cMsg, oLogFile, .f. )
	end
	
return ( ::lConnected )
	
method Disconnect( oLogFile ) class TWFPop3Srv
	local nCount := 0, nError := -1
	local cMsg := STR0008 //"Desconectando do servidor"

	cMsg += " %c..."
	cMsg := FormatStr( cMsg, WFGetProtocol()[2] )

	default oLogFile := WFStream()
	
	if ::oMailMan == nil
		return !( ::lConnected )
	end
	if ::oMailMan:oServer <> nil
		if ( ::lConnected )
			WFConOut( cMsg, oLogFile, .f. )
			while ( nError <> 0 ) .and. ( nCount < 10 )
				nError := ::oMailMan:oServer:POPDisconnect()
				if ( nCount > 0 ) .and. ( nError <> 0 )
					Sleep( 3000 )
				end
				nCount++
			end
			if ( nError <> 0 )
				cMsg := STR0009 //"Ocorreu um erro durante a desconexao. Erro: "
				cMsg += AsString( nError )
				WFConOut( cMsg, oLogFile, .f. )
			else
				::lConnected := .f.
			end
		end
	else
		cMsg := STR0007 //"O servidor de e-mail nao foi inicializado corretamente."
		WFConOut( cMsg, oLogFile, .f. )
	end
	
return !( ::lConnected )

method GetNumMsgs( nMsg ) class TWFPop3Srv 
	nMsg := 0

	if ::lConnected
		::oMailMan:oServer:GetNumMsgs( @nMsg )
	end

return nMsg

method DeleteMsg( nMsg ) class TWFPop3Srv 
	default nMsg := 0

	if ( ::lConnected ) .and. ( nMsg > 0 )
		::oMailMan:oServer:DeleteMsg( nMsg )
	end

return


