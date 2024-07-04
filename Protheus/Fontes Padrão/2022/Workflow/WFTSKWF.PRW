#INCLUDE "WFTSKWF.ch"
#INCLUDE "COLORS.CH"
#Include "SIGAWF.CH"

STATIC __oTaskWF

function WFTaskWF( oTaskDlg, nOpc, cFile, lReturn )
	default nOpc := 0
	do case
		case nOpc == 0
			__oTaskWF := TWFTaskWF():New( oTaskDlg )
		case nOpc == 1
			__oTaskWF:Rastreability()
		case nOpc == 2
			__oTaskWF:IBrowser( cFile, lReturn )
		case nOpc == 3
			__oTaskWF:Remove( cFile, lReturn )
	end
return

class TWFTaskWF
	data oTaskDlg
	method New( oOwner ) CONSTRUCTOR
	method IBrowser( cHtmlFile, lReturn )
	method Rastreability() 
	method Remove()
endclass

method New( oOwner ) class TWFTaskWF
	Local bBlock := "{ || " 
	::oTaskDlg := oOwner

	bBlock += "WF6_FILIAL == '" + xFilial("WF6") + "' .and. "
	bBlock += "WF6_PROPRI == '" + Upper( Left( ::oTaskDlg:oTaskMan:cUserName + Space( 15 ),15 ) ) + "' .and. "
	bBlock += "WF6_GRUPO == '00001' .and. "

	::oTaskDlg:AddFolder( STR0001, &( bBlock + "WF6_STATUS $ '13' }" ), "PMSTASK1" ) //"Processos em Aberto"
	::oTaskDlg:AddFolder( STR0002, &( bBlock + "WF6_STATUS == '0' }" ), "PMSTASK2" ) //"Processos em Execucao"
	::oTaskDlg:AddFolder( STR0003, &( bBlock + "WF6_STATUS == '2' }" ), "PMSTASK4" ) //"Processos Respondidos"
	::oTaskDlg:AddButton( STR0004, { |oTsk| WFTaskWF( oTsk,1 ) } ) //"Rastreabilidade..."
	::oTaskDlg:AddButton( STR0005, { |oTsk| WFTaskWF( oTsk,3 ) } ) //"Remover"
return

method IBrowser( cHtmlFile, lReturn ) class TWFTaskWF
	Local oWF
	Local lExecute := .t.
	local cMsg, cExecBrowser, cHttpServer
	
	default cHtmlFile := "", lReturn := .t.
    
	if ValType(::oTaskDlg) == "O" .and. ValType(::oTaskDlg:nRecnoWF6) == "N"
		dbSelectArea('WF6')
		WF6->(dbSetOrder(1))
		WF6->(dbGoTo(::oTaskDlg:nRecnoWF6))
	Endif 

	If !( WF6_STATUS $ "02" )
			
		If RecLock( "WF6", .f. )
			WF6_STATUS := WF_RUNNING
			WF6_DTVISU := MsDate()
			WF6_HRVISU := Left( Time(),5 )
			MSUnlock( "WF6" )
		end
		
	else

		if WF6_STATUS == "0"
			cMsg := STR0006 //"Este processo encontra-se em execucao desde %d as %c. Deseja executa-lo novamente?"
			cMsg := FormatStr( cMsg, { WF6_DTVISU, WF6_HRVISU } )
		
			if !( lExecute := MsgYesNo( cMsg, STR0007 ) ) //"Processo"
				Return
			end
		
		elseif WF6_STATUS == "2"
			cMsg := STR0008 //"Este processo foi respondido em %d as %c. Deseja executa-lo novamente?"
			cMsg := FormatStr( cMsg, { WF6_DTRESP, WF6_HRRESP } )
		
			if !( lExecute := MsgYesNo( cMsg, STR0007 ) ) //"Processo"
				Return
			end
		
		end

	end

	oWF := TWFObj()
	cExecBrowser := Lower( AllTrim( oWF:cBrowser ) ) + Space( 1 )
	cHttpServer := "http://" + AllTrim( oWF:cBrwServer )
	cHttpServer := Lower( StrTran( cHttpServer, "\", "/" ) )
	cHtmlFile	:= Lower( StrTran( cHtmlFile, "\", "/" ) )
	
	if Right( cHttpServer, 1 ) <> "/"
		cHttpServer += "/"
	end

	oWF:Free()
	oWF := nil
	WinExec( cExecBrowser + cHttpServer + cHtmlFile )
return

method Rastreability() class TWFTaskWF
	Local cLastAlias := Alias()
	Local cProcID     

	
	if ValType(::oTaskDlg) == "O" .and. ValType(::oTaskDlg:nRecnoWF6) == "N"
		dbSelectArea('WF6')
		WF6->(dbSetOrder(1))
		WF6->(dbGoTo(::oTaskDlg:nRecnoWF6))
	Endif

	If !( Eof() )
		If ( len(trim(WF6_IDENT1)) == WF_MAIL_ID_LEN) //Tamanho do ID de processos com 8 posições
		  cProcID := pad(AllTrim( WF6_IDENT1 ), WF_PROC_ID_LEN + WF_TASK_ID_LEN)
		  cProcID := Left( cProcID,WF_PROC_ID_LEN ) + "." + SubStr( cProcID, WF_PROC_ID_LEN + 1 ,WF_TASK_ID_LEN)
		else
			cProcID := Pad( AllTrim( WF6_IDENT1 ), WF_OLD_TOTAL_ID_LEN )
			cProcID := Left( cProcID,WF_OLD_PROC_ID_LEN ) + "." + SubStr( cProcID, WF_OLD_PROC_ID_LEN + 1 , 3)
		endif
		
		ChkFile( "WF3" )
		dbSelectArea( "WF3" )
		dbSetOrder( 1 )

		if dbSeek( xFilial( "WF3" ) + Upper( cProcID ) )
			WFC001( 0, WF3_PROC,  Upper( cProcID ) )
		end
		
		if !Empty( cLastAlias )
			dbSelectArea( cLastAlias )
		end
	end
return

method Remove() class TWFTaskWF
	Local nPos
	Local cFileName
	Local cMsg := STR0009	// "Deseja remover este processo de sua lista de pendencias?"
	
	if !Eof()

		if MsgYesNo( cMsg, "Remover" )
			cFileName := StrTran( AllTrim( WF6_ACAO ), "/", "\" )
		
			if ( nPos := At( '"', cFileName ) ) > 0
				cFileName := SubStr( cFileName, nPos +1 )
				
				if ( nPos := At( '"', cFileName ) ) > 0
					cFileName := Left( cFileName, nPos -1 )
				end
			
			end

			if RecLock( "WF6", .f. )
				dbDelete()
				MSUnlock("WF6")
		
				if File( cFileName )
					FErase( cFileName )
				end

			end

			::oTaskDlg:ReloadData()
			::oTaskDlg:Refresh()
		end
		
	end

return
