#INCLUDE "WFSched.ch"
#include "SigaWF.ch"

#define _SCHEDULER	1

/******************************************************************************
	TWFSchedObj()
	Retorna um objeto da classe TWFScheduler
******************************************************************************/
function TWFSchedObj( aParams )
return TWFScheduler():New( aParams )

function WFSchOpen()
	local oSXMTable
	
	if Select( "SXM" ) == 0
		oSXMTable := TWFSXMObj( "sxm" + cEmpAnt + "0" + GetDbExtension(), "SXM" )

   		if !oSXMTable:lIsOpen()
			oSXMTable:lOpen()
		endif
	endif
return ( Select("sxm" + cEmpAnt + "0") <> 0)

function WFSchClose()
	if Select( "SXM" ) <> 0
		dbSelectArea("SXM")
		dbCloseArea()
	endif
return ( Select( "SXM" ) == 0 )

function WFSchLocate( cTaskID, aTaskFields )
	local oScheduler := TWFSchedObj( { cEmpAnt, cFilAnt } )
return oScheduler:LocateTask( cTaskID, aTaskFields )

function WFSchInsert( aTaskFields )
	local oScheduler := TWFSchedObj( { cEmpAnt, cFilAnt } )
return oScheduler:SaveTasks( aTaskFields )

function WFSchDelete( cTaskID )
	local oScheduler := TWFSchedObj( { cEmpAnt, cFilAnt } )
return oScheduler:DeleteTask( cTaskID )

function WFSchUpdate( cTaskID, aTaskFields )
	local lResult
	local oScheduler := TWFSchedObj( { cEmpAnt, cFilAnt } )
	lResult := oScheduler:UpdateTask( cTaskID, aTaskFields )
return lResult


class TWFScheduler
	data oSXMTable
	data cRootDir
	data cTaskDir

	method New( aParams ) constructor
	method Free()
	method ExecTask( cTaskID )
	method Reactive()
	method Recalc()
	method RecalcAll()
	method AppendTasks()
	method DelTimeOuts( cMailID, aID )
	method SaveTasks( aTasks )
	method FindExecTask( ADate, ATime )
	method LocateTask( cTaskID, aTaskFields )
	method UpdateTask( cTaskID, aTaskFields )
	method DeleteTask( cTaskID )
endclass

/******************************************************************************
	New()
	Construtor da classe TWFScheduler
******************************************************************************/
method New( aParams ) class TWFScheduler
	WFPrepEnv( aParams[1], aParams[2], "WFScheduler",, WFGetModulo( aParams[1], aParams[2] ) )
	::cRootDir := WF_ROOTDIR + aParams[1] + "\"
	::cTaskDir := ::cRootDir + "tasks\"
	WFForceDir( ::cTaskDir )
	::oSXMTable := TWFSXMObj( "sxm" + aParams[1] + "0" + GetDbExtension(), "SXM" )
return

/******************************************************************************
	Free()
	Destrutor da classe TWFScheduler
******************************************************************************/
method Free() class TWFScheduler
	WFConOut( STR0001 ) //"Finalizando SCHEDULER"
	::oSXMTable:lClose()	
	WFConOut( STR0002 ) //"Finalização do SCHEDULER completada"
return

/******************************************************************************
	LocateTask()
	Localiza a tarefa a partir do codigo informado em cTaskID (XM_CODIGO)
	e retorna um array com todo o conteudo dos campos do registro encontrado.
	Caso nao localize, retornará um array vazio {}
******************************************************************************/
method LocateTask( cTaskID, aTaskFields ) class TWFScheduler
return ::oSXMTable:LocateTask( cTaskID, aTaskFields )

/******************************************************************************
	UpdateTask()
	Localiza a tarefa a partir do codigo informado em cTaskID (XM_CODIGO)
	e atualiza o registro localizado com o conteudo do array multidimensional (aTaskFiels)
	aTaskFiels = { { "<cNome_do_campo>", <conteudo> } }
******************************************************************************/
method UpdateTask( cTaskID, aTaskFields ) class TWFScheduler
return ::oSXMTable:UpdateTask( cTaskID, aTaskFields )
 
/******************************************************************************
	DeleteTask()
	Localiza a tarefa a partir do codigo informado em cTaskID (XM_CODIGO)
	e deleta o registro encontrado.
******************************************************************************/
method DeleteTask( cTaskID ) class TWFScheduler
return ::oSXMTable:DeleteTask( cTaskID )

/******************************************************************************
	ExecTask()
	Localiza a tarefa a partir do codigo informado em cTaskID (XM_CODIGO)
	e a executa.
******************************************************************************/
method ExecTask( cTaskID ) class TWFScheduler
return ::oSXMTable:ExecTask( cTaskID )

/******************************************************************************
	Reactive()
	Reativa todas os as tarefas pendentes que nao foram executados a partir de
	0:00hs do mesmo dia, ate o horario atual.
******************************************************************************/
method Reactive() class TWFScheduler
return ::oSXMTable:Reactive()

/******************************************************************************
	Recalc()
	Recalcula o horario da proxima execucao para o registro corrente.
******************************************************************************/
method Recalc() class TWFScheduler
return ::oSXMTable:Recalc()

/******************************************************************************
	RecalcAll()
	Recalcula os horarios das proximas execucoes de todos os registro.
******************************************************************************/
method RecalcAll() class TWFScheduler
return ::oSXMTable:RecalcAll()

/******************************************************************************
	AppendTask()
	Adiciona a tabela SXM as tarefas a serem executadas a partir dos arquivos
	encontrados no diretorio \workflow\emp??\tasks\*.sch
******************************************************************************/
method AppendTasks() class TWFScheduler
	local nC
	local cTaskFile
	local aTaskFiles

	aTaskFiles := Directory( ::cTaskDir + "*.sch", "D" )	
	if Len( aTaskFiles ) > 0
		for nC := 1 to Len( aTaskFiles )
			if aTaskFiles[ nC,5 ] <> "D" .and. File( cTaskFile := ::cTaskDir + aTaskFiles[ nC,1 ] )
				::oSXMTable:AppendTask( cTaskFile )
				FErase( cTaskFile )                                               
			endif			
		next
	endif
return

/******************************************************************************
	DelTimeOuts()
	Remove os registros encontrados com o campo XM_NOME == cMailID e XM_ID contido
	em aID das tarefas de timeouts de processos.
******************************************************************************/
method DelTimeOuts( cMailID, aID ) class TWFScheduler
return ::oSXMTable:DelTimeOuts( cMailID, aID )

/******************************************************************************
	SaveTasks()
	Grava as tarefas no formato de arquivo *.sch no diretorio \workflow\emp??\tasks
	para posteriormente serem inseridos atraves do metodo AppendTasks()
******************************************************************************/
method SaveTasks( aTasks ) class TWFScheduler
return ::oSXMTable:SaveTasks( ::cTaskDir, aTasks )

/******************************************************************************
	FindExecTask()
	Localiza a proxima tarefa a ser executada na determinada data (dDate) e horario (cTime)
******************************************************************************/
method FindExecTask( dDate, cTime ) class TWFScheduler
return ::oSXMTable:FindExecTask( dDate, cTime )


/******************************************************************************
	WFSCHEDULER
	Rotina de execucao do agendamento de rotinas                               
*****************************************************************************/
procedure WFScheduler( aParams )
	Local lFirstTime := .t.
	Local nHandler
	Local cLCKMonitor := "\semaforo", cLCKScheduler, cKey
	Local __cEmpresa := "99", __cFilial := "01", __cReativar := "T", __cModulos := "", __cMonitor := "F"
	
	if !( ValType( aParams ) == "A" )
		return
	endif

	__cEmpresa := if( len( aParams ) >= 1, AllTrim( aParams[1] ), __cEmpresa )
	__cFilial := if( len( aParams ) >= 2, AllTrim( aParams[2] ), __cFilial )
	__cReativar := if( len( aParams ) >= 3, AllTrim( aParams[3] ), __cReativar )
	__cModulos := if( len( aParams ) >= 4, AllTrim( aParams[4] ), __cModulos )
	__cMonitor := if( len( aParams ) >= 5, AllTrim( aParams[5] ), __cMonitor )

	if !( __cMonitor $ "T|F" )
		__cMonitor := "F"
	endif

	if !( __cReativar $ "T|F" )
		__cReativar := "T"
	endif

	if ( __cReativar == "T" )
		StartJob( "WFLauncher", GetEnvServer(), .f., { "WFAReact", { __cEmpresa, __cFilial, if( __cModulos == "", nil, __cModulos ) } } )
	endif

	WFPrepEnv( __cEmpresa, __cFilial, "WFScheduler",, if( __cModulos == "", nil, __cModulos ) )

	if ( Upper( __cMonitor ) == "T" )
		Conout(STR0014) // "Sistema de monitoragem do scheduler foi ativado!"
		WFForceDir( cLCKMonitor )
		cLCKScheduler := cLCKMonitor + lower( "\wfsched" + aParams[1] + ".lck" )
		cLCKMonitor += lower( "\wfmonit" + aParams[1] + ".lck" )
		cKey := DTOC( MsDate() ) + Time()
		FERASE( cLCKMonitor )
		WFSaveFile( cLCKMonitor, cKey )

		while !KillApp() .and. File( cLCKMonitor )
			if WFLoadFile( cLCKMonitor ) == cKey
				if ( nHandler := FCREATE( cLCKScheduler ) ) <> -1
					FCLOSE( nHandler)
					StartJob( "WFLauncher", GetEnvServer(), .f., { "WFStartSched", { __cEmpresa, __cFilial } } )
					if !lFirstTime .and. FindFunction( "U_WFPE004" )
						StartJob( "WFLauncher", GetEnvServer(), .f., { "U_WFPE004",	{ __cEmpresa, __cFilial } } )
					endif
					lFirstTime := .f.
				endif
			else
				exit
			endif
			Sleep(60000)
		end
	else
		WFStartSched( { __cEmpresa, __cFilial } )
	endif
return

Procedure WFStartSched( aParams )
	local dDate
	local cFileCTL, cTime, cFindKey, cLCKScheduler
	local cText := STR0003 + DtoC( MSDate() ), cMsg //"DATA: "
	local oScheduler, oSXMTable
	Local cFilialSXM := ""
	
	
	cLCKScheduler := lower( "\semaforo\wfsched" + aParams[1] + ".lck" )		
			
	if LockByName(cLCKScheduler,.T.,.T.)
	
		oScheduler := TWFSchedObj( aParams )
		oSXMTable := oScheduler:oSXMTable
	
	if !oSXMTable:lOpen()
		ConOut( STR0006 ) //"Nao foi possivel abrir a tabela de agendamento."
		return
	endif
	
	cFileCTL := ChgFileExt( "wf" + aParams[1] + aParams[2] + SubStr( CriaTrab(,.f.),3 ), ".ctl" )

	cText += CHR(13) + CHR(10)
	cText += STR0007 + aParams[1] //"EMPRESA: "
	cText += CHR(13) + CHR(10)
	cText += STR0008 + aParams[2] //"FILIAL: "
	
	cMsg := Replicate( "*", 79 )
	ConOut( cMsg )
	cMsg := FormatStr( "* TOTVS S/A  *  Scheduler Protheus  *  %c  * %c *", { cFileCTL, Left( Time(),5 ) } )
	ConOut( cMsg )
	cMsg := Replicate( "*", 79 )
	ConOut( cMsg )

	WFSaveFile( cFileCTL, cText )
	
	oScheduler:RecalcAll()
	oScheduler:Reactive()

	cTime := ""
	dDate := CtoD( "/" )
	
	while !KillApp() .and. file( cFileCTL )
			
		if cTime <> Left( Time(),5 ) .or. dDate <> MsDate()
			dDate := MsDate()
			cTime := Left( Time(),5 )
			cFindKey :=  PadR( xFilial( "SXM" ) , FWSizeFilial()) + DTOS( MsDate() ) + cTime + "T"
			oSXMTable:_First()
			
			While !oSXMTable:lEof()
			  	cFilialSXM := PadR( oSXMTable:xValue("XM_FILIAL") , FWSizeFilial() )
			
				if ( oSXMTable:nFieldPos( "XM_NUMTENT" ) > 0 .and. oSXMTable:nFieldPos( "XM_TENTEXE" ) > 0 )
					if ( cFilialSXM + DTOS( oSXMTable:xValue("XM_DTPROX") ) +;
						oSXMTable:xValue( "XM_HRPROX" ) + oSXMTable:xValue( "XM_ATIVO" ) ) == cFindKey
						oSXMTable:lUpdate( { { "XM_TENTEXE", oSXMTable:xValue( "XM_NUMTENT" ) } } )
						oSXMTable:ExecTask()
					else
						if oSXMTable:xValue( "XM_NUMTENT" ) > 0 .and. oSXMTable:xValue( "XM_TENTEXE" ) > 0 .and. ;
							!( oSXMTable:xValue( "XM_NUMTENT" ) == oSXMTable:xValue( "XM_TENTEXE" ) )
							oSXMTable:ExecTask()
						endif
					endif
				else
					if ( cFilialSXM + DTOS( oSXMTable:xValue("XM_DTPROX") ) +;
						oSXMTable:xValue( "XM_HRPROX" ) + oSXMTable:xValue( "XM_ATIVO" ) ) == cFindKey
						oSXMTable:ExecTask()
					endif
				endif
				
				oSXMTable:_Next()
			enddo
		endif
		
		oScheduler:AppendTasks()
		Sleep(5000)
	enddo

	if file( cFileCTL )
		FErase( cFileCTL )
	else
		ConOut( STR0009 ) //"**** WFScheduler finalizado por solicitação do usuário"
	endif
	
else
      cMsg := STR0004 //"Ja existe um agendamento em execucao para a empresa"
      cMsg += " = '" + aParams[1] + "'"
      cMsg += STR0005 //"e Filial"
	  cMsg += " = '" + aParams[2] + "'" 
      CONOUT(cMsg)
endif
	
return

FUNCTION WFAReact( aParams )
	Local nC
	Local cKey, cMsg
	Local oWF, oStream
	Local aFiliais
	Local __cEmpresa := "99", __cFilial := "01", __cModulos

	if !( ValType( aParams ) == "A" )
		Return
	endif
	
	__cEmpresa := if( len( aParams ) >= 1, AllTrim( aParams[1] ), __cEmpresa )
	__cFilial := if( len( aParams ) >= 2, AllTrim( aParams[2] ), __cFilial )
	__cModulos := if( len( aParams ) >= 3, AllTrim( aParams[3] ), __cModulos )

	WFPrepEnv( __cEmpresa, __cFilial, "WFAReact",, if( __cModulos == "", nil, __cModulos ) )

	aFiliais := {}

	if SM0->( dbSeek( __cEmpresa ) )
		while !SM0->( Eof() ) .and. ( SM0->M0_CODIGO == __cEmpresa )
			if Ascan( aFiliais, SM0->M0_CODFIL ) == 0
				AAdd( aFiliais, SM0->M0_CODFIL )
			endif
			SM0->( dbSkip() )
		end
	endif
	
	SM0->( DbSeek( __cEmpresa + __cFilial ) )

	oWF := TWFObj( { __cEmpresa, __cFilial } )
	oStream := TWFStream():New()
	
	ChkFile( "WFA" )
	dbSelectArea( "WFA" )
	dbSetOrder( 4 )
	dbGoTop()
	
	for nC := 1 to Len( aFiliais )
		cFilAnt := aFiliais[ nC ]
		cKey := xFilial( "WFA" ) + WF_RUNNING
	
		while dbSeek( cKey )
			if RecLock( "WFA",.f. )
				WFA_TIPO := WF_INBOX
				MsUnLock( "WFA" )
				cMsg := Replicate( "*",79 )
				WFConOut( cMsg, oStream, .f., .f. )
				cMsg := Time() + ": " + STR0010 //"Reativando o processo: "
				cMsg += AllTrim( WFA_IDENT )
				WFConOut( cMsg, oStream, .f., .f. )
				cMsg := Replicate( "*",79 )
				WFConOut( cMsg, oStream, .f., .f. )

				if oWF:lNotif002 .and. !Empty( oWF:cMailAdmin )
					WFNotifyAdmin( , WF_NOTIFY, oStream:GetBuffer() )
					oStream:Clear()
				endif
				dbSelectArea( "WFA" )
			endif
		end   
	next
Return
