#INCLUDE "WFTransD.ch"
#include "SigaWF.CH"

#define WFHEADERMAIL	"X-Transdados"
#define WFHEADERTYPE	"811" 

class TWFTransDados
	data cMailBox
	data cMailAdmim
	data cAddressAuto
	data lAttachOnly
	data lSendAuto
	data lSendMail
	data lNF001
	data lNF002
	data lNF003
	data cBody
	data cRootDir
	data cTempDir
	data cSendDir
	data cSndBkDir
	data cReceiveDir
	data cRcvBkDir
	data cZipFileExt
	data cZipFile
	data aAttachs

	method New( aParams )
	method Send( cID )
	method Receive()
	method LoadParams()
	method GetAddress( aAddress )
	method AttachFiles( oHtml, oLogFile )
	method ExceptError( oE, cError )
endclass

method New( aParams ) class TWFTransDados
	default aParams := { cEmpAnt, cFilAnt }
	WFPrepEnv( aParams[1], aParams[2] )
	::cZipFile := ""
	::aAttachs := {}
	::lSendMail := .f.
	::LoadParams()
return

method LoadParams() class TWFTransDados
	::cMailBox 		:= AllTrim( WFGetMV( "MV_TDMLBOX", "" ) )	// Caixa de correio do workflow
	::cMailAdmim 	:= AllTrim( WFGetMV( "MV_TDADMIN", "" ) )	// E-mail do(s) administrador(es)
	::lSendAuto 	:= WFGetMV( "MV_TDSNDAU", .t. )	// Envio automatico de mensagens
	::lAttachOnly 	:= WFGetMV( "MV_TDENVAT", .t. )	// Enviar somente com arquivos anexos
	::cAddressAuto := WFGetMV( "MV_TDMLAUT", .t. )	// Emails autorizados
	::cZipFileExt	:= WFGetMV( "MV_TDZIPEX", .t. )	// Extensao de arquivo compactado
	::lNF001 		:= WFGetMV( "MV_TDNF001", .t. )	// Copia do resumo de envio
	::lNF002 		:= WFGetMV( "MV_TDNF002", .t. )	// Resumo do recebimento
	::lNF003 		:= WFGetMV( "MV_TDNF003", .t. )	// Erro de execucao

	::cRootDir		:= "\transdados\emp" + cEmpAnt + "\"
	::cTempDir		:= ::cRootDir + "temp\"
	
	WFForceDir( ::cTempDir )
	
	::cSendDir		:= Lower( AllTrim( WFGetMV( "MV_TDENV  ","enviar" ) ) )	// Diretorio de envio
	::cSendDir		:= if( Left( ::cSendDir,1 ) == "\", SubStr( ::cSendDir,2 ), ::cSendDir )
	::cSendDir		+= if( Right( ::cSendDir,1 ) <> "\", "\", "" )
	::cSendDir		:= ::cRootDir + ::cSendDir
	::cSndBkDir		:= ::cSendDir + "backup\"

	WFForceDir( ::cSndBkDir )

	::cReceiveDir	:= Lower( AllTrim( WFGetMV( "MV_TDREC  ","receber" ) ) )	// Diretorio de recebimento
	::cReceiveDir	:= if( Left( ::cReceiveDir, 1 ) == "\", SubStr( ::cReceiveDir,2 ), ::cReceiveDir )
	::cReceiveDir	+= if( Right( ::cReceiveDir, 1 ) <> "\", "\", "" )
	::cReceiveDir	:= ::cRootDir + ::cReceiveDir
	::cRcvBkDir		:= ::cReceiveDir + "backup\"

	WFForceDir( ::cRcvBkDir )
	
//	::cRootPath := Alltrim( WFGetMV( "MV_WFROOTP", "" ) )
//	::cRootPath := if( Empty( ::cRootPath ), GetSrvProfString("RootPath","\"), ::cRootPath )
//	::cRootPath += if( Right( ::cRootPath, 1 ) <> "\", "\", "" )
return

/******************************************************************************
	Send
	Este method e responsavel pelo envio da mensagem
******************************************************************************/
method Send( cID ) class TWFTransDados
	local nC1, nC2
	local bLastError
	local lResult := .f.
	local oHtml, oLogFile, oSelf := Self
	local aHeaders := { { WFHEADERMAIL, WFHEADERTYPE } }
	local cTo, cCC, cBCC, cSubject, cBody, cMsg, cUserFunc, cLastAlias := Alias()
	
	default cID := ""
	::lSendMail := .f.

	oLogFile := WFFileSpec( ::cTempDir + "Send.log" )
	cMsg := Replicate( "*", 80 )
	oLogFile:WriteLN( cMsg )
	ConOut( cMsg )
	
	ChkFile( "WF5" )
	dbSelectArea( "WF5" )
	dbSetOrder(1)
	
	cMsg := "TRANSDADOS - ["
	cMsg += WF5->WF5_COD + "] " + AllTrim( WF5->WF5_DESCR ) + " ]" 
	WFConOut( cMsg, oLogFile )

	if dbSeek( xFilial( "WF5" ) + cID )	
		cTo := WFGetAddress( AllTrim( WF5->WF5_PARA ) )
		cCC := WFGetAddress( AllTrim( WF5->WF5_CCOPIA ) )
		cBCC := WFGetAddress( AllTrim( WF5->WF5_OCULTA ) )
			
		if Empty( cTo + cCC + cBCC )
			cMsg := STR0001 //"Lista de enderecos de destinatarios nao especificados."
			WFConOut( cMsg, oLogFile, .f. )
		else
			cBuffer := '<html><head><title>Untitled Document</title>'
			cBuffer += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"></head>'
			cBuffer += '<body><form name="form1" method="post" action="">'
			cBuffer += '<table width="75%" border="1">'
			cBuffer += '<tr><td bgcolor="#0099FF">'
			cBuffer += '<div align="center"><p><font color="#FFFFFF"><strong>'
			cBuffer += STR0002 //'RESUMO DO ENVIO DE ARQUIVOS'
			cBuffer += '</strong></font></p><p><font color="#FFFFFF">'
			cBuffer += STR0003 //'Remetente'
			cBuffer += ':</font> %Empresa%   <font color="#FFFFFF">'
			cBuffer += STR0004 //'Filial'
			cBuffer += ':</font> %Filial%</p></div></td></tr>'
			cBuffer += '<tr><td bgcolor="#0099FF"><div align="center"><font color="#FFFFFF">%Resumo_Arquivos%</font></div></td></tr></table>'
			cBuffer += '<table width="75%" border="1"><tr bgcolor="#0099FF">'
			cBuffer += '<td> <div align="center"><strong><font color="#FFFFFF">'
			cBuffer += STR0005 //'Arquivos'
			cBuffer += '</font></strong></div></td>'
			cBuffer += '<td> <div align="center"><strong><font color="#FFFFFF">'
			cBuffer += STR0006 //'Tamanho'
			cBuffer += '(Kb)</font></strong></div></td>'
			cBuffer += '<td> <div align="center"><strong><font color="#FFFFFF">'
			cBuffer += STR0007 //'Data'
			cBuffer += '</font></strong></div></td></tr>'
			cBuffer += '<tr><td height="23">%Arq.Arquivos%</td>'
			cBuffer += '<td><div align="right">%Arq.Tamanho%</div></td>'
			cBuffer += '<td><div align="right">%Arq.Data%</div></td></tr></table>'
			
			if !Empty( AllTrim( WF5->WF5_CORPO ) )
				cBuffer += '<p>&nbsp;</p><table width="75%" border="1">'
				cBuffer += '<tr><td width="20%" bgcolor="#0099FF"> <div align="center"><font color="#FFFFFF">'
				cBuffer += STR0008 //'Observacao'
				cBuffer += ':</font></div></td><td width="80%">%Observacao%</td></tr></table>'
			end

			cBuffer += '</form></body></html>'
			
			oHtml := TWFHtml():New()
			oHtml:lUsaJS := .f.
			oHtml:LoadStream( cBuffer )
			oHtml:ValByName( "Empresa", AllTrim( SM0->M0_NOMECOM ) )
			oHtml:ValByName( "Filial", AllTrim( SM0->M0_FILIAL ) )

			if !Empty( AllTrim( WF5->WF5_CORPO ) )
				oHtml:ValByName( "Observacao", AllTrim( WF5->WF5_CORPO ) )
			end

			cSubject := AllTrim( WF5->WF5_DESCR )
			bLastError := ErrorBlock( { |e| oSelf:ExceptError( e ) } )

			BEGIN SEQUENCE
			
				if WF5->WF5_ANTENV == "2" .and. !Empty( WF5->WF5_ANTFUN )
					cUserFunc := AllTrim( WF5->WF5_ANTFUN )
					if At( "(", cUserFunc ) == 0
						cUserFunc += "("
					end
					if At( ")", cUserFunc ) == 0
						cUserFunc += ")"
					end
					cMsg := STR0009 + cUserFunc + STR0010 //"Executando funcao de usuário "###" ANTES do envio."
					WFConOut( cMsg, oLogFile, .f. )
					Eval( &( "{|| " + cUserFunc + " }" ) )
					dbSelectArea( "WF5" )
				end

				::AttachFiles( oHtml, oLogFile )

				if ::lAttachOnly .or. Len( aAttachs ) > 0 
					cBuffer := oHtml:HtmlCode()
					if ::lNF001 .and. !Empty( ::cMailAdmim )
						WFNewMsg( ::cMailBox, ::cMailAdmim,,, TD_NOTIFY, cBuffer )
					end
					if file( ::cSendDir + ::cZipFile )
						::aAttachs := { ::cSendDir + ::cZipFile }
					end
					WFNewMsg( ::cMailBox, cTo, cCC, cBCC, cSubject, cBuffer, ::aAttachs, aHeaders )
					if WF5->WF5_POSENV == "2" .and. !Empty( WF5->WF5_POSFUN )
						cUserFunc := AllTrim( WF5->WF5_POSFUN )
						if At( "(", cUserFunc ) == 0
							cUserFunc += "("
						end
						if At( ")", cUserFunc ) == 0
							cUserFunc += ")"
						end
						cMsg := STR0009 + cUserFunc + STR0011 //"Executando funcao de usuário "###" APOS do envio."
						WFConOut( cMsg, oLogFile, .f. )
						Eval( &( "{|| " + cUserFunc + " }" ) )
						DbSelectArea( "WF5" )
					end
				else                         
					cMsg := STR0012 //"Nao ha arquivo(s) anexo(s) a ser(em) enviado(s)."
					WFConOut( cMsg, oLogFile, .f. )
				end
				
			END SEQUENCE

			ErrorBlock( bLastError )
		end	
	else
		cMsg := STR0013 //"Codigo de envio nao cadastrado."
		WFConOut( cMsg, oLogFile, .f. )
	end
	
	if ::lSendAuto .or. ::lSendMail
		TDSendMail( { cEmpAnt, cFilAnt } )
	end
	
	cMsg := Replicate( "*", 80 )
	oLogFile:WriteLN( cMsg )
	ConOut( cMsg )
	oLogFile:Close()

	if !Empty( cLastAlias )
		dbSelectArea( cLastAlias )
	end
return

/******************************************************************************
	AttachFiles
	Este method e responsavel pela inclusao dos arquivos que serao anexos a
	mensagem.
******************************************************************************/
method AttachFiles( oHtml, oLogFile ) class TWFTransDados
	local nC1, nC2, nTotalSize := 0
	local aMaskFiles, aFiles, aZipFiles
	local cMsg, cMaskFiles, cPathFiles, cResumo
	
	::aAttachs := {}
	::cZipFile := ""
	
	if Empty( cMaskFiles := AllTrim( WF5->WF5_ANEXOS ) )
		cMaskFiles := "*.*"
	end

	while (Left(cMaskFiles,1) $ "/\")
		cMaskFiles := SubStr( cMaskFiles,2 )
	end
	
	cMaskFiles := ::cSendDir + cMaskFiles

	if Len( aMaskFiles := WFTokenChar( cMaskFiles, ";" ) ) > 0
		for nC1 := 1 to Len( aMaskFiles )
			cMaskFiles := aMaskFiles[ nC1 ]
			cPathFiles := ExtractPath( cMaskFiles )
			if Len( aFiles := Directory( cMaskFiles,"D" ) ) > 0
				for nC2 := 1 to Len( aFiles )
					if ( aFiles[ nC2,5 ] <> "D" )
						AAdd( oHtml:ValByName( "Arq.Arquivos" ), aFiles[ nC2,1 ] )
						AAdd( oHtml:ValByName( "Arq.Tamanho" ), Int( aFiles[ nC2,2 ] / 1024 ) )
						AAdd( oHtml:ValByName( "Arq.Data" ), aFiles[ nC2,3 ] )
						AAdd( ::aAttachs, cPathFiles + aFiles[ nC2,1 ] )
						nTotalSize += aFiles[ nC2,2 ]
						cMsg := STR0014 //"Anexando"
						cMsg += ": " + aFiles[ nC2,1 ]
						WFConOut( cMsg, oLogFile, .f. )
					end
				next
			end
		next
		if ( nFiles := Len( ::aAttachs ) ) > 0
			if !Empty( ::cZipFile := AllTrim( WF5->WF5_ARQCAB ) )
				::cZipFile := "{|| " + ::cZipFile + " }"
				::cZipFile := Lower( Eval( &( ::cZipFile ) ) )
				::cZipFile := AllTrim( ChgFileExt( ::cZipFile, ".mzp" ) )
				cMsg := STR0015 + ::cSendDir + ::cZipFile //"Compactando arquivos em "
				WFConOut( cMsg, oLogFile, .f. )
				fErase( ::cSendDir + ::cZipFile )
				aZipFiles := WFZipFile( ::aAttachs, ::cSendDir + ::cZipFile ) 
				if Len( aZipFiles ) <> Len( ::aAttachs )
					cMsg := STR0016 //"PROBLEMAS ENCONTRADOS:"
					WFConOut( cMsg, oLogFile, .f. )
					for nC1 := 1 to Len( ::aAttachs )
						if AScan( aZipFiles,{ |x| upper( x ) == upper( ::aAttachs[ nC1 ] ) } ) == 0
							cMsg := STR0017 //"Não foi possível anexar o arquivos..."
							cMsg += ::aAttachs[ nC1 ] 
							WFConOut( cMsg, oLogFile, .f. )
						end
					next
				else
					AEval( ::aAttachs,{ |x| WFMoveFiles( x, ::cSndBkDir ) } )
				end
			end				
      end
	end

	cResumo := AllTrim( Str( Len( ::aAttachs ) ) ) + " " 
	cResumo += STR0018 //"Arquivos"
	cResumo += " " + AllTrim( Str( nTotalSize/1024000,12,1 ) ) + "Mb ("
	cResumo += AllTrim( Str( Int( nTotalSize / 1024 ) ) ) + " Kbytes)"
	oHtml:ValByName( STR0019, cResumo ) //"Resumo_Arquivos"
return

method Receive( aUserFuncs ) class TWFTransDados
	Local nC
	local bLastError
	local oMail, oMailBox
	local cMsg, cLastAlias := Alias()

	PUBLIC oTransDados := self, oLogFile
		
	::lSendMail := .f.

	oLogFile := WFFileSpec( ::cTempDir + "receive.log" )
	cMsg := Replicate( "*", 80 )
	oLogFile:WriteLN( cMsg )
	ConOut( cMsg )

	cMsg := FormatStr( STR0020, ::cMailBox ) //"VERIFICANDO CAIXA DE ENTRADA... [%c]"
	WFConOut( cMsg, oLogFile )
		
	oMail := TWFMail():New()
	oMailBox := oMail:GetMailBox( ::cMailBox )

	if !oMailBox:lExists
		cMsg := STR0021 //"Recipiente de mensagem nao encontrado."
		WFConOut( cMsg, oLogFile, .f. )
		cMsg := Replicate( "*", 80 )
		oLogFile:WriteLN( cMsg )
		WFConOut( cMsg )
		return
	end
	                  
	oMailBox:bBeforeReceive := "TDBeforeReceive"
   oMailBox:Receive()  // Obtem as mensagens da caixa de entrada 
   
	if Len( aUserFuncs ) > 0
		cMsg := STR0032 //"Executando funcoes de usuário após o recebimento..."
		WFConOut( cMsg, oLogFile, .f. )
		bLastError := ErrorBlock( { |e| oSelf:ExceptError( e ) } )

		BEGIN SEQUENCE
		                         
			for nC := 1 to Len( aUserFuncs )
				if !Empty( cUserFunc := AllTrim( aUserFuncs[ nC ] ) )
					if At( "(", cUserFunc ) == 0
						cUserFunc += "("
					end
					if At( ")", cUserFunc ) == 0
						cUserFunc += ")"
					end
					cMsg := STR0033 //"Executando"
					cMsg += " '" + cUserFunc + "' "
					WFConOut( cMsg, oLogFile, .f. )
					Eval( &( "{|| " + cUserFunc + " }" ) )
				end
			next
			
		END SEQUENCE

		ErrorBlock( bLastError )		
	end

	if ::lSendAuto .or. ::lSendMail
		StartJob( "WFLauncher", GetEnvServer(), .f., { "WFSndMsg", { cEmpAnt, cFilAnt, ::cMailBox } } )
	end

	cMsg := Replicate( "*", 80 )
	oLogFile:WriteLN( cMsg )
	ConOut( cMsg )
	oLogFile:Close()

	if !Empty( cLastAlias )
		dbSelectArea( cLastAlias )
	end

return

/******************************************************************************
	TDBeforeReceive
	Complemento da funcao TDJobSndMail. Envento ocorrido apos o envio da mensagem.
******************************************************************************/
Procedure TDBeforeReceive( oMsg, oMailBox )
	local oInboxFolder, oArchiveFolder
	local nC1, nC2 := 1, nAttachs
	local cMsg, cAttachFile, cRootPath
	local aMails := WFTokenChar( WFGetAddress( AllTrim( WFGetMV( "MV_TDMLAUT", "" ) ) ), ";" ), aAttachFiles
	local lMailAutoriz
	
	if (oMsg == nil)
		return
	end

	cRootPath := AllTrim( GetSrvProfString( "RootPath","" ) )
	cRootPath := if( Right( cRootPath, 1 ) == "\", Left( cRootPath, Len( cRootPath ) -1 ), cRootPath )
	
	oArchiveFolder := oMailBox:NewFolder( MBF_ARCHIVE )
	oInboxFolder := oMailBox:GetFolder( MBF_INBOX )
	
	lMailAutoriz := .f.
	
	for nC1 := 1 to Len( aMails )
		if At( AllTrim( Upper( aMails[ nC1 ] ) ), Upper( oMsg:cFrom ) ) > 0
			lMailAutoriz := .t.
		end
	next
	
	if Empty( oMsg:GetCustomHeader( WFHEADERMAIL + ":" ) ) .and. !( lMailAutoriz )
		cMsg := STR0023 //"Mensagem NAO reconhecida ou NAO autorizada."
		WFConOut( cMsg, oLogFile, .f. )
		/*/
		cMsg := STR0024 //"Movido para"
		cMsg += " '" + Upper( oArchiveFolder:cRootPath + aFiles[ nC1,1 ] ) + "'"
		WFConOut( cMsg, oLogFile, .f. )
		oInboxFolder:MoveFiles(aFiles[ nC1,1 ], oArchiveFolder )
		/*/
	else
		aAttachFiles := {}
		if ( nAttachs := oMsg:GetAttachCount() ) > 0
			if oTransDados:lNF002 .and. !Empty( oTransDados:cMailAdmim ) .and. !(lMailAutoriz)
				if ( oMsg:GetAttachInfo( nC2 )[2] == "text/html" )
					while file( cAttachFile := oTransDados:cTempDir + ChgFileExt( CriaTrab(,.f.),".htm" ) )
					end
					oMsg:SaveAttach( nC2++, cRootPath + cAttachFile )
					WFNewMsg( oTransDados:cMailBox, oTransDados:cMailAdmim,,, TD_NOTIFY, WFLoadFile( cAttachFile ) )
					FErase( cAttachFile )
					oTransDados:lSendMail := .t.
				end
			end
			for nC1 := nC2 to nAttachs
				if ( cAttachFile := oMsg:GetAttachInfo( nC1 )[1] ) <> NIL
					if !Empty( cAttachFile := AllTrim( cAttachFile ) )
						AAdd( aAttachFiles, { nC1, cAttachFile } )
					end
				end
			next
		end
		if len( aAttachFiles ) > 0
			cMsg := STR0025 //"Ha %c arquivo(s) anexo(s)."
			cMsg := FormatStr( cMsg, StrZero( Len( aAttachFiles ),4 ) )
			WFConOut( cMsg, oLogFile, .f. )
			for nC2 := 1 to Len( aAttachFiles )
				cAttachFile := aAttachFiles[ nC2,2 ]
				cMsg := "[#%c| "
				cMsg += STR0026 //"Gravando"
				cMsg += " '" + cAttachFile + "' "
				cMsg += STR0027  //"em"
				cMsg += " %c"
				cMsg := FormatStr( cMsg, { StrZero( nC2,4 ), oTransDados:cReceiveDir + cAttachFile } )
				WFConOut( cMsg, oLogFile, .f. )
				if At( "AP5", Upper( GetVersao() ) ) > 0
				   oMsg:SaveAttach( aAttachFiles[ nC2,1 ], cRootPath + oTransDados:cReceiveDir + cAttachFile )
				else
				   oMsg:SaveAttach( aAttachFiles[ nC2,1 ] -1, cRootPath + oTransDados:cReceiveDir + cAttachFile )   
				end
				if Upper( ExtractExt( cAttachFile ) ) == ".MZP" 
					if File( oTransDados:cReceiveDir + cAttachFile )
						cMsg := STR0028 //"Descompactando"
						cMsg += " '" + cAttachFile + "' "
						cMsg += STR0027 //"em"
						cMsg += " '" + oTransDados:cReceiveDir + "'"
						WFConOut( cMsg, oLogFile, .f. )
						WFUnZipFile( oTransDados:cReceiveDir + cAttachFile, oTransDados:cReceiveDir )
						cMsg := STR0029 //"Movendo"
						cMsg += " '" + cAttachFile + "' "
						cMsg += STR0030 //"para"
						cMsg += " '" + oTransDados:cRcvBkDir + "'"
						WFConOut( cMsg, oLogFile, .f. )
						WFMoveFiles( oTransDados:cReceiveDir + cAttachFile, oTransDados:cRcvBkDir )
					end
				end
			next
		else
			cMsg := STR0031 //"Nao ha arquivos anexos."
			WFConOut( cMsg, oLogFile, .f. )
			cMsg := STR0029 //"Movendo"
			cMsg += " '" + oArchiveFolder:cRootPath + "' "
			WFConOut( cMsg, oLogFile, .f. )
		end
	end
	
return

method ExceptError( oE ) class TWFTransDados
	Local nC := 2
	Local cMsg, cBuffer
	Local oStream := WFStream()
	
	If oE:GenCode > 0
		cBuffer := '<html><head><title>Untitled Document</title>'
		cBuffer += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
		cBuffer += '</head><body><form name="form1" method="post" action="">'
		cBuffer += '<table width="75%" border="1"><tr>'
		cBuffer += '<td bgcolor="#0099FF"><div align="center"><strong><font color="#FFFFFF">TRANSDADOS - '
		cBuffer += STR0035 //'ERRO DE EXECUCAO'
		cBuffer += '</font></strong></div></td></tr><tr><td bgcolor="#000000"><font color="#FFFF00">'

		ConOut( replicate( "*",79 ) )
		WFConOut( STR0036,, .f., .f. ) //"Ocorreu um erro na execucao do transdados."
		WFConOut( oE:Description, oStream, .f., .f. )

		While ProcName( nC ) <> ""
			cMsg := "Called from: "
			cMsg += ProcName( nC )
			cMsg += " - Line: " + AllTrim( str( ProcLine( nC ) ) )
			WFConOut( cMsg, oStream, .f., .f. )
			nC++
		end

		ConOut( replicate( "*",79 ) )
		
		if ::lNF003 .and. !Empty( ::cMailAdmim )
			cBuffer += oStream:GetBuffer()
			cBuffer += '</font></td></tr></table></form></body></html>'
			WFNewMsg( ::cMailBox, ::cMailAdmim,,, TD_NOTIFY, cBuffer )
			::lSendMail := .t.
		end
		
		BREAK 
	End

return 
