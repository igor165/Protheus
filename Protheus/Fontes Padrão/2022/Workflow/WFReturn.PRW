#INCLUDE "WFReturn.ch"
#include "SigaWF.ch"
 
/******************************************************************************
	WFReturn
	Funcao especifica para recebimento de retorno de mensagens do workflow.
 ******************************************************************************/
function WFReturn( aParams, lDebug, lHttp )
	local cResult := STR0016 // "Controle de semaforo ativo. Tente novamente."
	
	Default aParams 	:= { cEmpAnt, cFilAnt }
	Default lDebug 	:= .F.
	Default lHttp 	:= .F.

	if !( lHttp )	
		WFForceDir( WF_ROOTDIR + aParams[1] )
	end
	
	if lDebug .or. lHttp
		cResult := WFJobReturn( aParams, lDebug, lHttp )
	else
		StartJob( "WFLauncher", GetEnvServer(), .f., { "WFJobReturn", aParams } )
		cResult := ""
	end
return cResult

/******************************************************************************
	WFJobReturn()
	Executa os retornos dos processo que chegaram atraves de e-mails ou post-html
 *****************************************************************************/ 
Procedure WFJobReturn( aParams, lDebug, lHttp )
	Local cFindKey 		:= ""
	Local cMailBox		:= ""
	Local cMsg     		:= ""
	Local cProcessID		:= ""
	Local cResult 		:= STR0016 // "Controle de semaforo ativo. Tente novamente."
	Local nC				:= 0
	Local nC2         	:= 0
	Local nJobs       	:= 0
	Local nMaxJobs   		:= 0
	Local nPos       		:= 0
	Local aFiliais 		:= {}
	Local aPostParams		:= Nil
	Local lWFStartJob 	:= .f.

	Default aParams 		:= { cEmpAnt, cFilAnt }
	Default lDebug 		:= .f.
	Default lHttp  		:= .f.

	If ( lHttp )	
		aPostParams := aParams[ 3 ] 
		ADel( aParams, 3 )
		ASize( aParams, len( aParams ) -1 )
	Else
		WFForceDir( WF_ROOTDIR + aParams[1] )
	EndIf    

	// Abre os arquivos de sistema. SX´s...
	WFPrepEnv( aParams[1], aParams[2], "WFJobReturn",, WFGetModulo( aParams[1], aParams[2] ) )

	// Se os dados nao vierem por http... deverao ser lidos por e-mail
	if ! ( lHttp )
   		// Verifica a caixa de mensagens do workflow e extrai o octect das mensagens.
		if ( cMailBox := WFGetMV( "MV_WFMLBOX", nil ) ) <> nil
			cMailBox := AllTrim( cMailBox )
			WFJobRcvMail( { aParams[ 1 ], aParams[ 2 ], cMailBox } )  // Verifica a caixa de entrada
		end

		// Verifica se a tabela de empresas foi aberta pelo sistema.	
		if Select( "SM0" ) == 0
			return ""
		end
		
		dbSelectArea("SM0")
	
		if dbSeek( aParams[1] )
			// Lista todas as filiais existentes para a mesma empresa e guarda-os em um array
			while !Eof() .and. ( M0_CODIGO == aParams[1] )
				// Verifica se a filial encontrada, nao esta inclusa na lista de itens do array
				if Ascan( aFiliais, M0_CODFIL ) == 0
					AAdd( aFiliais, M0_CODFIL )
				end
				dbSkip()
			end
			
		end
	
		// Volta para a posicao original do arquivo de empresa.
		dbSeek( aParams[1] + aParams[2] )	
	end
	// Abre o arquivo de mensagens do messenger
	ChkFile( "WF6" )
	dbSelectArea( "WF6" )
	dbSetOrder( 3 )
	
	// Abre o arquivo de controle de entrada/saida/status de mensagens de processo do workflow
	ChkFile( "WFA" )
	dbSelectArea( "WFA" )
	dbSetOrder( 1 )

    // Se for via servico http...
	if (lDebug .and. lHttp) .or. lHttp

		// Separa as mensagens reconhecidas pelo workflow e gera os arquivos .OCT (octets)	
		if !Empty( cResult := WFChkReturn( cMailBox, aPostParams ) )
			return cResult
		end

		// Nao conseguiu identificar o numero do processo para ser executado atraves
		// da resposta enviada pelo browser do usuario.
		if ( nPos := AScan( aPostParams, { |x| Upper( x[1] ) == Upper(EH_MAILID) } ) ) == 0
			cResult := STR0017 // "ID do Processo NAO IDENTIFICADO. Solicite suporte."
			Conout( cResult )
			return cResult
		end
		
		cProcessID := Lower( aPostParams[ nPos,2 ] )
			
		if left( cProcessID,2 ) == "wf"
			cProcessID := Substr( cProcessID,3 )
		end
		
		cProcessID := Left( cProcessID + Space( 20 ),20 )
		cMsg := "[" + AllTrim( WFA->WFA_IDENT ) + "]: "

		dbSelectArea( "WFA" )
		dbSetOrder( 4 )
		cFindKey := xFilial( "WFA" ) + WF_INBOX + cProcessID

		if dbSeek( cFindKey )
			
			if RecLock( "WFA", .f. )
				WFA->WFA_TIPO := WF_RUNNING
				MsUnLock()
			end
			
			dbSelectArea( "WF6" )
			
			if !DbSeek( xFilial( "WF6" ) + WF_RUNNING + WFA->WFA_IDENT ) 
				if !DbSeek( xFilial( "WF6" ) + WF_INBOX + WFA->WFA_IDENT )
					DbSeek( xFilial( "WF6" ) + WF_SENT + WFA->WFA_IDENT )
				end
			end
			
			if Found()
				If RecLock( "WF6", .f. )
					WF6->WF6_STATUS := WF_RUNNING
					MsUnLock()
				end
			end
			
			dbSelectArea( "WFA" )
			cMsg := "[" + AllTrim( WFA->WFA_IDENT ) + "] "
			cMsg += STR0011 //"Executando o retorno do processo..."
			conout( cMsg )
			cResult := WFStartRet( { aParams[1], aParams[2], WFA->WFA_IDENT, aPostParams }, lDebug, lHttp )
 		else
 			Conout( cMsg += STR0018 )  //"Processo NAO LOCALIZADO. Solicite suporte."
		end
		
		return cResult
	else
		// Separa as mensagens reconhecidas pelo workflow e gera os arquivos .OCT (octets)	
		WFChkReturn( cMailBox, aPostParams )
	end

	nC := 1
	nJobs := 1
	
	// Obtem o numero maximo de execucoes de jobs que serao executados por vez.
	nMaxJobs := WFGetMV( "MV_WFMAXJB", 5 )
	
	// Habilita o novo recurso de execucao dos jobs 
	lWFStartJob := WFGetMV( "MV_WFNEWJB", .f. )
			
	if lWFStartJob
	
		for nC := 1 to len( aFiliais )
			cFilAnt := aFiliais[ nC ]
			cFindKey := xFilial( "WFA" ) + WF_INBOX
			dbSelectArea("WFA")
			dbSetOrder(1)
			
			while dbSeek( cFindKey, .T. ) .and. ( nJobs <= nMaxJobs )
				nJobs++
				if lDebug
	 				WFStartJob( { aParams[1], aFiliais[ nC ], nJobs }, lDebug )
	 			else
	 				StartJob( "WFLauncher", GetEnvServer(), .f., { "WFStartJob", { aParams[1], aFiliais[ nC ], nJobs } } )
	 			end
			end
			
		next
		
	else
		while ( nC <= len( aFiliais ) .and. nJobs <= nMaxJobs )
			dbSelectArea( "WFA" )
			dbSetOrder( 1 )
			cFilAnt := aFiliais[ nC ]
			cFindKey := xFilial( "WFA" ) + WF_INBOX
			
			while dbSeek( cFindKey, .T. ) .and. ( nJobs <= nMaxJobs )
			
				if RecLock( "WFA", .f. )
					WFA->WFA_TIPO := WF_RUNNING
					MsUnLock()
				end
				dbSelectArea( "WF6" )
				if !DbSeek( xFilial( "WF6" ) + WF_RUNNING + WFA->WFA_IDENT ) 
					if !DbSeek( xFilial( "WF6" ) + WF_INBOX + WFA->WFA_IDENT )
						DbSeek( xFilial( "WF6" ) + WF_SENT + WFA->WFA_IDENT )
					end
				end
				if Found()
					If RecLock( "WF6", .f. )
						WF6->WF6_STATUS := WF_RUNNING
						MsUnLock()
					end
				end
				dbSelectArea( "WFA" )
				cMsg := "[" + AllTrim( WFA->WFA_IDENT ) + "] "
				cMsg += STR0011 //"Executando o retorno do processo..."
				conout( cMsg )
				if lDebug
					WFStartRet( { aParams[1], aFiliais[ nC ], WFA->WFA_IDENT, aPostParams } )
					dbSelectArea( "WFA" )
				else
	 				StartJob( "WFLauncher", GetEnvServer(), .f., { "WFStartRet", { aParams[1], aFiliais[ nC ], WFA->WFA_IDENT, aPostParams } } )
	 			end
				dbSetOrder( 1 )
				nJobs++
			end
			
			nC++
		end
	end
	
return ""


Function WFStartJob( aParams, lDebug )
Local cFindKey, cLCKFile
Local aPostParams
Local hFile
Local nJob

default aParams := { cEmpAnt, cFilAnt, 1 }, lDebug := .f.

nJob := aParams[3]

cLCKFile := "wf" + aParams[1] + aParams[2] + StrZero( nJob,3 ) + ".lck"

WFForceDir( WF_ROOTDIR + aParams[1] )
cLCKFile := WF_ROOTDIR + aParams[1] + "\temp\" + cLCKFile 

if ( hFile := WFCreate( cLCKFile, FC_NORMAL ) ) == -1
	return ""
end

WFClose( hFile )

if ( hFile := WFOpen( cLCKFile, FO_READWRITE + FO_EXCLUSIVE ) ) == -1
	return ""
end    

if len( aParams ) > 2
	aPostParams := aParams[ 3 ] 
	ADel( aParams, 3 )
	ASize( aParams, len( aParams ) -1 )
end

WFPrepEnv( aParams[1], aParams[2], "WFStartJob",, WFGetModulo( aParams[1], aParams[2] ) )

// Abre o arquivo de mensagens do messenger
ChkFile( "WF6" )
dbSelectArea( "WF6" )
dbSetOrder( 3 )

// Abre o arquivo de controle de entrada/saida/status de mensagens de processo do workflow
ChkFile( "WFA" )
dbSelectArea( "WFA" )
dbSetOrder( 1 )

cFindKey := xFilial( "WFA" ) + WF_INBOX

while WFA->( dbSeek( cFindKey, .T. ) )
		
	if RecLock( "WFA", .f. )
		if ( WFA->WFA_FILIAL + WFA->WFA_TIPO == cFindKey )
			WFA->WFA_TIPO := WF_RUNNING				
			MsUnLock()
		else
			MsUnLock()
			loop
		end
	else
		loop
	end

	dbSelectArea( "WF6" )

	if !DbSeek( xFilial( "WF6" ) + WF_RUNNING + WFA->WFA_IDENT ) 
		if !DbSeek( xFilial( "WF6" ) + WF_INBOX + WFA->WFA_IDENT )
			DbSeek( xFilial( "WF6" ) + WF_SENT + WFA->WFA_IDENT )
		end
	end

	if Found()
		If RecLock( "WF6", .f. )
		  	WF6->WF6_STATUS := WF_RUNNING
			MsUnLock()
		end
	end

	dbSelectArea( "WFA" )

	cMsg := "[" + AllTrim( WFA->WFA_IDENT ) + "] "
	cMsg += STR0011 //"Executando o retorno do processo..."
	conout( cMsg )
	WFStartRet( { aParams[1], aParams[2], WFA->WFA_IDENT, aPostParams }, .t. )
	dbSelectArea( "WFA" )
	dbSetOrder( 1 )
end

WFClose( hFile )
FErase( cLCKFile )
return
			
/******************************************************************************
	WFChkReturn()
	Executa os retornos dos processo que chegaram atraves de e-mails ou post-html
 *****************************************************************************/
Function WFChkReturn( cMailBox, aPostParams )
	local lError := .f.
	local bLastError
	local nC, nC2, nPos, nLen := 1
	local oMail, oMailBox, oArchiveFolder, oIgnoredFolder, oInboxFolder, oMsg, oWF
	local aFiles, aValues, aTimeOutID, aReturn := {}
	local cRootPath, cBuffer, cMailID := "", cBody, cProcessID, cTaskID, cFindKey
	local cWFAFilial, cSaveFilAnt, cEMLFile, cMsg, cWFMFile, cInboxPath, cResult := ""
	Local cVariable := ''
	Local cTag      := ''
	Local cText     := ''
	Local nText     := 0
	Local nSubstr 	:= 0
	Local aText		:= {}
	
	cRootPath := GetSrvProfString( "RootPath","" )
	cRootPath += if( Right( cRootPath, 1 ) == "\", Left( cRootPath, Len( cRootPath ) -1 ), "" )
	
	if ( aPostParams == nil )
		
		if ( cMailBox <> nil )
			oMail := TWFMail():New()
			oMailBox := oMail:GetMailBox( cMailBox )
			
			if oMailBox:lExists
				oArchiveFolder := oMailBox:NewFolder( MBF_ARCHIVE + MBF_DATE )
				oIgnoredFolder := oMailBox:NewFolder( MBF_IGNORED + MBF_DATE )
			else
				return cResult
			end
			
		else
			return cResult
		end
		
		oInboxFolder := oMailBox:GetFolder( MBF_INBOX )
		nLen := len( aFiles := oInboxFolder:GetFiles( "*.eml" ) )
	end
	
	oWF := TWFObj()
	ChkFile( "WFA" )
	
	nC := 1
	
	while ( nC <= nLen )
		
		if ( aPostParams == nil )
			cWFMFile := aFiles[nC,1]
			aValues := {}
			
			if oInboxFolder:FileExists( cWFMFile )
				lError := .f.
				bLastError := ErrorBlock( { |e| lError := .t. } )
				BEGIN SEQUENCE
				oMsg := TMailMessage():New()
				oInboxFolder:LoadFile( cWFMFile, oMsg )
				aValues := WFExtrOct( oMsg )
				END SEQUENCE
				ErrorBlock(bLastError)
				if lError
					nC++
					loop
				end
			end
			
		else
			aValues := AClone( aPostParams )
		end
		
		if ( nPos := AScan( aValues, { |x| Upper( x[1] ) == Upper(EH_MAILID) } ) ) == 0
			cMsg := STR0001 //" Mensagem NAO reconhecida pelo workflow"
			cResult := STR0001 + ". " + STR0019 //" Mensagem NAO reconhecida pelo workflow" ## "Solicite suporte."
			
			if ( aPostParams == nil )
				oInboxFolder:MoveFiles( cWFMFile, oArchiveFolder )
				cEMLFile := oArchiveFolder:cRootPath + "\" + cWFMFile
				
				if oWF:lNotif003 .and. !Empty( oWF:cMailAdmin )
					WFNotifyAdmin( , AllTrim(cMsg), cRootPath + cEMLFile )
				end
				
				if FindFunction('U_WFPE001')
					StartJob( "WFLauncher", GetEnvServer(), .f., { "U_WFPE001",	{ cEmpAnt, cFilAnt, cEMLFile } } )
				end
				
			end
			
		else
			cMailID := Lower( aValues[ nPos,2 ] )
			
			if left( cMailID,2 ) == "wf"
				cMailID := Substr( cMailID,3 )
			end
			
			If ( Len( cMailID ) >= WF_MAIL_ID_LEN ) //Tamanho do ID de processos com 8 posições.
				cMailID := left( pad(cMailID, WF_MAIL_ID_LEN), WF_MAIL_ID_LEN )
			Else
				cMailID := left( pad(cMailID, WF_OLD_MAIL_ID_LEN), WF_OLD_MAIL_ID_LEN )
			EndIf
			
			if ( nPos := AScan( aValues, { |x| Upper( x[1] ) == "WFFILIAL" } ) ) > 0
				cFilAnt := aValues[ nPos,2 ]
			end
			
			if ( nPos := AScan( aValues, { |x| Upper( x[1] ) == "WFEMPRESA" } ) ) > 0
				// Se nao pertencer a mesma empresa...
				if !( cEmpAnt == aValues[ nPos,2 ] ) .and. ( aPostParams == nil )
					// Movo o arquivo para a pasta "inbox" pra outra empresa, tendo cuidado de nao
					// sobreescrever outro arquivo com o mesmo nome.
					cInboxPath := StrTran( oInboxFolder:cRootPath, "emp" + cEmpAnt, "emp" + aValues[ nPos,2 ] )
					WFForceDir( cInboxPath )
					while file( cInboxPath + "\" + cWFMFile )
						cWFMFile := ChgFileExt( CriaTrab(,.f.), ".eml" )
					end
					WFSaveFile( cInboxPath + "\" + cWFMFile, WFLoadFile( oInboxFolder:cRootPath + "\" + aFiles[nC,1] ) )
					oInboxFolder:DeleteFile( aFiles[nC,1] )
					nC++
					loop
				end
				
			else
				// exibir mensagem
				nC++
				loop
			end
			
			cProcessID := extProcID(cMailID)
			cTaskID := extTaskID(cMailID)
			cSaveFilAnt := cFilAnt
			
			if ( nPos := AScan( aValues, { |x| Upper( x[1] ) == "WFRECNOTIMEOUT" } ) ) > 0
				
				if ValType( aValues[ nPos,2 ] ) <> "A"
					aTimeOutID := &( aValues[ nPos,2 ] )
				end
				
			else
				aTimeOutID := {}
			end
			
			if !WFChkProcEvent( cProcessID, cTaskID, EV_FINISH )
				DbSelectArea( "WFA" )
				DbSetOrder( 2 )
				cWFAFilial := xFilial( "WFA" )
				cFindKey := cWFAFilial + PadR( cMailID,20 )
				
				if !dbSeek( cFindKey )
					cFindKey := cWFAFilial + upper( PadR( cMailID,20 ) )
					dbSeek( cFindKey )
				end
				
				if Found()
					WFDelTimeOuts( cMailID, aTimeOutID )
					
					if WFA->WFA_TIPO $ ( WF_OUTBOX + WF_SENT + WF_OUTHTTP )
						cBuffer := "Local aOct := {}" + chr(13) + chr(10)
						
						if ( aPostParams == nil )
							cBuffer += "AAdd(aOct," + AsString({ "X-" + EH_PROCID, oMsg:GetCustomHeader("X-" + EH_PROCID) },.t.) + ")" + chr(13) + chr(10)
							cBuffer += "AAdd(aOct," + AsString({ "X-" + EH_TASKID, oMsg:GetCustomHeader("X-" + EH_TASKID) },.t.) + ")" + chr(13) + chr(10)
							cBuffer += "AAdd(aOct," + AsString({ "X-" + EH_MAILID, oMsg:GetCustomHeader("X-" + EH_MAILID) },.t.) + ")" + chr(13) + chr(10)
							cBuffer += "AAdd(aOct," + AsString({ "X-" + EH_SIGAWF, oMsg:GetCustomHeader("X-" + EH_SIGAWF) },.t.) + ")" + chr(13) + chr(10)
							cBuffer += "AAdd(aOct," + AsString(oMsg:cFrom,.t.) + ")" + chr(13) + chr(10)
							cBuffer += "AAdd(aOct," + AsString(oMsg:cTo,.t.) + ")" + chr(13) + chr(10)
							cBuffer += "AAdd(aOct," + AsString(oMsg:cCC,.t.) + ")" + chr(13) + chr(10)
							cBuffer += "AAdd(aOct," + AsString(oMsg:cBCC,.t.) + ")" + chr(13) + chr(10)
							cBuffer += "AAdd(aOct," + AsString(oMsg:cSubject,.t.) + ")" + chr(13) + chr(10)
						else
							cBuffer += "AAdd(aOct,{'X-" + EH_PROCID + "',''})" + chr(13) + chr(10)
							cBuffer += "AAdd(aOct,{'X-" + EH_TASKID + "',''})" + chr(13) + chr(10)
							cBuffer += "AAdd(aOct,{'X-" + EH_MAILID + "',''})" + chr(13) + chr(10)
							cBuffer += "AAdd(aOct,{'X-" + EH_SIGAWF + "',''})" + chr(13) + chr(10)
							cBuffer += "AAdd(aOct,'')" + chr(13) + chr(10)
							cBuffer += "AAdd(aOct,'')" + chr(13) + chr(10)
							cBuffer += "AAdd(aOct,'')" + chr(13) + chr(10)
							cBuffer += "AAdd(aOct,'')" + chr(13) + chr(10)
							cBuffer += "AAdd(aOct,'')" + chr(13) + chr(10)
						end
						
						cBuffer += "AAdd(aOct,{})" + chr(13) + chr(10)
						
						for nC2 := 1 to len( aValues )
							cText := StrTran( aValues[nC2][2], "'", '"' )
							
							If ! ( cText == Nil ) .And. ( Len( cText ) > 1024 )
								cVariable  	:= aValues[nC2][1]
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
								
								cBuffer += "AAdd(aOct[10]," + "{'" + cVariable + "'," + "cAux" + cBIStr( nC2 ) + "}" + ")" + chr(13) + chr(10)
							Else
								cBuffer += "AAdd(aOct[10]," + AsString(aValues[nC2],.t.) + ")" + chr(13) + chr(10)
							EndIf
						Next
						
						cBuffer += "return aOct" + chr(13) + chr(10)
						
						cBuffer := Strtran( cBuffer, "'+chr(34)+'", chr(34) )
						cBuffer := Strtran( cBuffer, "'+chr(39)+'", chr(34) )
						
						WFSaveFile( oWF:cProcessDir + AllTrim( cMailID ) + ".oct", cBuffer )
						
						if RecLock( "WFA", .F. )
							WFA->WFA_TIPO := WF_INBOX
							WFA->WFA_DATA := MsDate()
							WFA->WFA_HORA := Left( Time(),5 )
							MsUnLock("WFA")
						end
						
						if ( aPostParams == nil )
							oMsg := nil
							oInboxFolder:DeleteFile( cWFMFile )
						end
						
					else
						
						if WFA->WFA_TIPO $ ( WF_INBOX + WF_RUNNING + WF_ARCHIVE )
							cMsg := FormatStr( STR0002, AllTrim( cMailID ) ) //" Processo: %c IGNORADO. Recebido anteriormente."
							cResult := STR0020 // "Processo IGNORADO. Recebido anteriormente."
							
							if ( aPostParams == nil )
								oInboxFolder:MoveFiles( aFiles[nC,1], oIgnoredFolder )
							end
						else
							oInboxFolder:MoveFiles( aFiles[nC,1], oIgnoredFolder )
						end
						
					end
					
				else
					cMsg := FormatStr( STR0003, AllTrim( cMailID ) ) //" Processo: %c IGNORADO. Nao encontrado."
					cResult := STR0021 //"Processo IGNORADO. Nao encontrado."
					
					if ( aPostParams == nil )
						oInboxFolder:MoveFiles( aFiles[nC,1], oIgnoredFolder )
					end
					
				end
				
			else
				cMsg := FormatStr( STR0004, AllTrim( cMailID ) ) //" Processo: %c IGNORADO. FINALIZADO anteriormente."
				cResult := STR0022 // "Processo IGNORADO. FINALIZADO anteriormente."
				
				if ( aPostParams == nil )
					oInboxFolder:MoveFiles( aFiles[nC,1], oIgnoredFolder )
				end
			end
			
			cFilAnt := cSaveFilAnt
		end
		
		nC++
	end
return if( aPostParams == nil, "", cResult )

Function WFStartRet( aParams, lDebug, lHttp )
	Local oWF
	Local aValues := {}
	Local bLastError
	Local nPos, nRecNo
	Local lLauncher := .f.
	Local cFuncName, cParams, cFindKey, cValFile, cMsg
	Local cMsgError := STR0005 //"* Ocorreu um ERRO na execução de RETORNO do processo: "
	Local cResult := ""
	
	if aParams == nil
		return cResult
	else
		cMsgError += aParams[3]
	end
	
	Default lDebug := .f., lHttp := .f.
	
	PRIVATE __oProc, lWFErrorBlock := .f.
	
	WFPrepEnv( aParams[1], aParams[2], "WFStartRet",, WFGetModulo( aParams[1], aParams[2] ) )

	oWF := TWFObj()
	
	cMsg := "[" + Left( aParams[ 3 ],5 ) + "][" + substr( aParams[ 3 ], 6, 2 ) + "] "

  cValFile := lower( oWF:cProcessDir + AllTrim( aParams[ 3 ] ) + ".val" )
  
	if File( cValFile )
		aValues := WFLoadValFile( cValFile )
	else
		cValFile := lower( AllTrim( WFGetMV( "MV_WFDIR  ", "\workflow" ) ) )
		if right( cValFile,1 ) <> "\"
			cValFile += "\"
		end
		cValFile += "temp\" + AllTrim( aParams[ 3 ] ) + ".val"
		if File( cValFile )
			WFMoveFiles( cValFile, oWF:cProcessDir )
			if File( cValFile := lower( oWF:cProcessDir + AllTrim( aParams[ 3 ] ) + ".val" ) )
				aValues := WFLoadValFile( cValFile )
			end
		end
	end

	if len( aValues ) > 0
		if ( nPos := AScan( aValues, { |x| Upper( AllTrim( x[1] ) ) == "BRETURN"  } ) ) > 0
			cFuncName := aValues[ nPos,3 ]
		else
			cMsg += STR0012 //"Funcao de retorno nao atribuida ao processo. Finalizando execucao..."
			WFConOut( cMsg )
			return STR0013
		end
		if ( nPos := AScan( aValues, { |x| Upper( AllTrim( x[1] ) ) == "OHTML"  } ) ) > 0
			aValues := aValues[ nPos,3 ]
			if ( nPos := AScan( aValues, { |x| Upper( AllTrim( x[1] ) ) == "ALISTVALUES"  } ) ) > 0
				aValues := aValues[ nPos,3,1 ]
				if ( nPos := AScan( aValues, { |x| x[1] == "WFEMPRESA" } ) ) > 0
					if Upper( AllTrim( aValues[ nPos,2 ] ) ) <> Upper( AllTrim( aParams[1] ) )
						aParams[1] := Upper( AllTrim( aValues[ nPos,2 ] ) )
						lLauncher := .T.
					end
					if ( nPos := AScan( aValues, { |x| x[1] == "WFFILIAL" } ) ) > 0
						if Upper( AllTrim( aValues[ nPos,2 ] ) ) <> Upper( AllTrim( aParams[2] ) )
							aParams[2] := Upper( AllTrim( aValues[ nPos,2 ] ) )
							lLauncher := .T.
						end
					end
				end
				if lLauncher
					cMsg += STR0023 // "Reiniciando WFStartRet com a empresa: "
					cMsg += aParams[1]
					cMsg += " - "
					cMsg += "filial: "
					cMsg += aParams[2]
					Conout( cMsg )
					StartJob( "WFLauncher", GetEnvServer(), .f., { "WFStartRet", aParams } )
					Return ""
				end
			end
		else
			cMsg += STR0013 // "Falha na preparacao da execucao do processo."
			WFConOut( cMsg )
			cReturn := STR0013
			return cReturn
		end
		aValues := nil
	else
		cMsg += STR0014 // "Arquivo"
		cMsg += " "
		cMsg += cValFile
		cMsg += STR0015 // "(de definicoes do processo) nao foi encontrado."
		WFConOut( cMsg )
		Return STR0013
	end
	
	ChkFile( "WFA" )
	DbSelectArea( "WFA" )
	DbSetOrder( 4 )
	cFindKey := xFilial( "WFA" ) + WF_RUNNING + aParams[3]

	if DbSeek( cFindKey )
		nRecNo := RecNo()

		if ( __oProc := WFPrepProcess( aParams[3], aParams[4] ) ) == nil
			DbSelectArea( "WFA" )
			DbGoTo( nRecNo )

			If RecLock( "WFA", .f. )
				WFA_TIPO := WF_IGNORED
				MsUnLock()
			end

			Return
		end

	else
  	Return
	end

	__oProc:LogEvent( EV_NEWTASK, "[*RETURN*]" + __oProc:FDesc )

	if ( nPos := At( "(", cFuncName ) ) > 0
		cParams := SubStr( cFuncName, nPos +1 )
		cParams := Left( cParams, Len( cParams ) -1 )
		if cParams <> ""
			cParams += ","
		end
		cFuncName := Left( cFuncName, nPos -1 ) 
	else
		cParams := ""
	endif

	cFuncName += "( " + cParams + "__oProc )"
	bLastError := ErrorBlock( { |e| WFErrorBlock( e, cMsgError ) } )

	BEGIN SEQUENCE
	
		if oWF:lUseTrans
			BEGIN TRANSACTION
				&cFuncName
			END TRANSACTION
		else
			&cFuncName
		end
		
	END SEQUENCE
	
	ErrorBlock( bLastError )

	DbSelectArea( "WFA" )
	
	if RecNo() <> nRecNo
		DbGoTo( nRecNo )
	end

	ChkFile( "WF6" )
	DbSelectArea( "WF6" )
	DbSetOrder( 3 )

	cFindKey := xFilial( "WF6" ) + "0" + Left( aParams[3] + Space( 20 ),20 )

	if lWFErrorBlock
	
		while DbSeek( cFindKey, .t. )
			If RecLock( "WF6", .f. )
				WF6_STATUS := "1"
				MsUnLock()
			end
		end
		
		DbSelectArea( "WFA" )

		if oWF:lReacProcs
			If RecLock( "WFA", .f. )
				WFA_TIPO := WF_INBOX
				MsUnLock()
			end
		end

	else

		while DbSeek( cFindKey, .t. )
		
			If RecLock( "WF6", .f. )
				WF6_STATUS := "2"
				WF6_DTRESP := MsDate()
				WF6_HRRESP := Left( Time(),5 )
				MsUnLock()
			end
			
		end

		cFindKey := xFilial( "WF6" ) + "1" + Left( aParams[3] + Space( 20 ),20 )
		
		while DbSeek( cFindKey, .t. )
		
			If RecLock( "WF6", .f. )
				WF6_STATUS := "2"
				WF6_DTRESP := MsDate()
				WF6_HRRESP := Left( Time(),5 )
				MsUnLock()
			end
			
		end
		
		DbSelectArea( "WFA" )

		If RecLock( "WFA", .f. )
			WFA_TIPO := WF_ARCHIVE
			MsUnLock()
		end
		
	end	

	__oProc:Free()
	__oProc := nil
return

function WFTimeout( aParams )

	if aParams <> nil
		StartJob( "WFLauncher", GetEnvServer(), .f., { "WFJobTimeOut", aParams } )
	end
return

function WFJobTimeOut( aParams )
	Local dDate
	Local nPos, nHH, nMM
	Local cFuncName, cParam := "", cTime
	Local cFor, cMsgError := STR0006 //"* Ocorreu um ERRO na execução de TIMEOUT do processo: "
	Local bLastError
	Local oSXMTable


	if aParams == nil
		return
	else
		cMsgError += aParams[3]
	end

	WFPrepEnv( aParams[1], aParams[2], "WFJobTimeOut",, WFGetModulo( aParams[1], aParams[2] ) )
	
	oSXMTable := TWFSXMObj( "sxm" + aParams[1] + "0" + GetDbExtension(), "SXM" )
		
	if !oSXMTable:lOpen()
		ConOut( STR0007 ) //"Nao foi possivel abrir a tabela de agendamento."
		return
	end
	
	PRIVATE __oProc, lWFErrorBlock := .f.

	if ( __oProc := WFPrepTimeOut( aParams[3], aParams[4] ) ) <> nil

		//----------------------------------------------------------
		// Verifica se foi setado o array de timeout.
		//----------------------------------------------------------
		if ValType( __oProc:bTimeOut[1] ) == "A"
			cFuncName := AllTrim( __oProc:bTimeOut[ aParams[4],1 ] )
		else
			cFuncName := AllTrim( __oProc:bTimeOut[1] )
		end 
		
		__oProc:LogEvent( EV_NEWTASK, "[*TIMEOUT*]" + __oProc:FDesc )
		__oProc:NewVersion(.t.)
		__oProc:lTimeOut := .T.

		//-------------------------------------------------------
		// Retira ( ou ) do nome da função de timeout.
		//-------------------------------------------------------
		if ( nPos := At( "(", cFuncName ) ) > 0
			cParams := SubStr( cFuncName, nPos +1 )
			cFuncName := Left( cFuncName, nPos -1 )
			if ( nPos := At( ")", cParams ) ) > 0
				cParams := left( cParams, nPos -1 )
			end
			if !empty( cParams := AllTrim( cParams ) )
				cParams += ","
			end
		else
			cParams := ""
		endif
		//-------------------------------------------------------
		// Concatena nome da função com ( parâmetros e )
		//-------------------------------------------------------
		cFuncName += "( " + cParams + "__oProc )"
		bLastError := ErrorBlock( { |e| WFErrorBlock( e, cMsgError ) } )
		
		BEGIN SEQUENCE
		
			if WFGetMV( "MV_WFTRANS", .f. )
				BEGIN TRANSACTION
					&cFuncName
				END TRANSACTION
			else
				&cFuncName
			end
			
		END SEQUENCE
	
		ErrorBlock( bLastError )
		__oProc:Free()
		__oProc := NIL
		
	end

	oSXMTable:lClose()
return

FUNCTION WFPrepProcess( cProcessID, aPostParams )
	Local oProcess		:= Nil
	Local fProcessID	:= ""
	Local fTaskID		:= ""
	
	default cProcessID := ""
	
	fProcessID := extProcID(cProcessID)
	fTaskID := extTaskID(cProcessID)

	if !WFChkProcEvent( fProcessID, fTaskID, EV_FINISH )
		oProcess := TWFProcess():New( cProcessID, "", cProcessID )

		if !oProcess:LoadOctFile( oProcess:oWF:cProcessDir + AllTrim( cProcessID ) + ".oct" )
			oProcess:LogEvent(EV_PREPFAIL)
			oProcess:Free()
			oProcess := nil
		end
	end

return oProcess

//---------------------------------------------------
// Função responsável por abrir arquivo .val que contém
// a definição do processo, e preparar um objeto do tipo
// TWFProcess para receber o array de bTimeOut. 
//
// @Documentado 08/12/2015: Helio Leal.
//---------------------------------------------------
FUNCTION WFPrepTimeOut( cProcessID, nTimeOut )
	Local oProcess
	Local aTimeOuts
	Local nPos1, nPos2
	Local cValFile, cBuffer 
	Local fProcessID, fTaskID
	Local cMsg := ""
	
	default cProcessID := "", nTimeOut := 0

	fProcessID := extProcID(cProcessID)
	fTaskID := extTaskID(cProcessID)
	
	if !WFChkProcEvent( fProcessID, fTaskID, EV_FINISH )
		oProcess := TWFProcess():New( cProcessID, "", cProcessID )
		cValFile  := oProcess:oWF:cProcessDir + cProcessID + ".val"
		if file( cValFile ) .and. nTimeOut > 0
			cBuffer := WFLoadFile( cValFile )
			if ( nPos2 := At( "AAdd(aValues,{'bTimeout','A',aAux1})", cBuffer ) ) > 0
				nPos2 -= 2
				if ( nPos1 := Rat( "aAux1 := {", left( cBuffer, nPos2 ) ) ) > 0
					nPos1 += 9
					aTimeOuts := &( SubStr( cBuffer, nPos1, nPos2 - nPos1 ) )
					if len( aTimeOuts ) >= nTimeOut
						if len( aTimeOuts[ nTimeOut ] ) == 4
							AAdd( aTimeOuts[ nTimeOut ], MsDate() )
							AAdd( aTimeOuts[ nTimeOut ], Left( Time(),5 ) )
						else
							aTimeOuts[ nTimeOut,5 ] := MsDate()
							aTimeOuts[ nTimeOut,6 ] := Left( Time(),5 )
						end
						cBuffer := Stuff( cBuffer, nPos1, nPos2 - nPos1, AsString( aTimeOuts,.t. ) )
						WFSaveFile( cValFile, cBuffer )
					end
				end
			end
		else
			cMsg := "[" + DToC(Date()) + "]"
			cMsg += "[WFPrepTimeOut]"
			cMsg += STR0014 + " " + cValFile + " " + STR0015 // "Arquivo" "(de definições do processo) não foi encontrado."
			ConOut(cMsg)
			oProcess := Nil
		end
	end
	
return oProcess

Function WFErrorBlock( oE, cError, nErrorCode )
	Local cMsg
	Local nC := 2
	Local oStream
	
	default nErrorCode := 0
	
	If oE:GenCode > 0
		do case
			case nErrorCode == 0
				oStream := WFStream()
				lWFErrorBlock := .t.
				WFConOut( replicate( "*",79 ), oStream, .f., .f. )
				WFConOut( cError, oStream, .f., .f. )
				WFConOut( oE:Description, oStream, .f., .f. )

				While !( ProcName( nC ) == "" )
					cMsg := "Called from: "
					cMsg += ProcName( nC )
					cMsg += " - Line: " + AllTrim( str( ProcLine( nC ) ) )
					WFConOut( cMsg, oStream, .f., .f. )
					nC++
				end

				WFConOut( replicate( "*",79 ), oStream, .f., .f. )
				WFNotifyAdmin( , WF_NOTIFY, oStream:GetBuffer() )
			case nErrorCode == 100100	// Erro de leitura do OCTECT
				cError := {}
			case nErrorCode == 100200
			case nErrorCode == 100300
		end
		BREAK 
	End
return
