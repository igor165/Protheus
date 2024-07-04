#include "WFTSXM.ch"
#include "SigaWF.ch"

/******************************************************************************
 TWFSXMObj()
 Retorno o objeto da classe TSXMTable = Agendamento de rotinas
 *****************************************************************************/
function TWFSXMObj( cTablename, cAlias )
return TSXMTable():New( cTablename, cAlias )

function WFExecTask( cTaskID )
	local oSXM := TWFSXMObj( "sxm" + cEmpAnt + "0" + GetDbExtension(), "SXM" )
	oSXM:ExecTask( cTaskID )
return

/******************************************************************************
 WFDelTimeOuts
 Apaga todos os registros (timeouts) de relacionados a um processo (<cMailID>)
 no arquivo SXM para nao serem executados
 ******************************************************************************/
function WFDelTimeOuts( cMailID, aID )
	local cLastAlias := Alias()
	local oSXMTable
	oSXMTable := TWFSXMObj( "sxm" + cEmpAnt + "0" + GetDbExtension(), CriaTrab(,.f.) )
	oSXMTable:DelTimeOuts( cMailID, aID )
	oSXMTable:lClose()
	if !Empty( cLastAlias )
		dbSelectArea( cLastAlias )
	end
return

/******************************************************************************
	CLASS TSXMTable
 Classe de gerenciamento do arquivo de agendamento de rotinas
 ******************************************************************************/
class TSXMTable from TBITable
	method New( cTableName, cAliasName ) CONSTRUCTOR
	method NewSXMTable( cTablename, cAlias )
	method Recalc()
	method RecalcAll()
	method Reactive()
	method CalcDateTime( dDate, cTime )
	method NextDate( dDate, nStart, nFinish, cSequence )
	method FindExecTask( dDate, cTime )
	method LocateTask( cTaskID, aTaskFields )
	method UpdateTask( cTaskID, aTaskFields )
	method DeleteTask( cTaskID )
	method AppendTask( cTaskFile )
	method DelTimeOuts( cMailID, aID )
	method SaveTasks( cTaskDir, aTasks )
	method ExecTask( cTaskID )
endclass

/******************************************************************************
	New()
	Construtor da class TSXMTable
******************************************************************************/
method New( cTableName, cAliasName ) class TSXMTable
	
	default cTableName := "sxm" + cEmpAnt + "0" + GetDbExtension(), cAliasName := "SXM"

	cTableName := Upper(Left(cTableName,At('.',cTableName)-1))

	//-------------------------------------------------------------------
    // Verifica se a tabela SXM existe no banco, se não existe cria.
    //-------------------------------------------------------------------

	::fcAlias 		:= cAliasName
	::fcTablename 	:= cTablename

	IF !(::lIsOpen())
		::NewSXMTable( cTableName, cAliasName)
	else
		::NewTable( cTableName , cTableName )	
	endif
return

/******************************************************************************
	NewSXMTable()
******************************************************************************/
method NewSXMTable( cTableName, cAlias) class TSXMTable
    Local cRDD 		:= Iif( ( "CTREE" $ RealRDD() ), "CTREECDX", "DBFCDX" )  
	Local aTable 	:= {}
	Local aSxm 		:= {}
	Local cPath		:= ""

	default cAlias := "SXM"
	
	if cTableName <> nil
		
		cTableName := upper(SubStr(cTableName, 1,6)) 
		::NewTable( cTableName, cTableName )

		::AddField( TBIField():New( "XM_FILIAL",	"C",  12 ) )
		::AddField( TBIField():New( "XM_CODIGO",	"C",  20 ) )
		::AddField( TBIField():New( "XM_NOME",		"C",  30 ) )
		::AddField( TBIField():New( "XM_DESCR",		"C", 200 ) )
		::AddField( TBIField():New( "XM_TIPO",		"N",   1 ) )	// 0-Diario 1-Semanal 3-Mensal 4-Exporádico
		::AddField( TBIField():New( "XM_DTINI",		"D",   8 ) )	// Data de inicio
		::AddField( TBIField():New( "XM_HRINI",		"C",   5 ) )	// Hora de inicio
		::AddField( TBIField():New( "XM_DTFIM",		"D",   8 ) )	// Data de termino
		::AddField( TBIField():New( "XM_HRFIM",		"C",   5 ) )	// Hora de termino
		::AddField( TBIField():New( "XM_INTERV",	"C",   5 ) )	// Intervalo entre execs
		::AddField( TBIField():New( "XM_SEMANA",	"C",   7 ) )	// Dias da semana
		::AddField( TBIField():New( "XM_MENSAL",	"C",  31 ) )	// Dias do mes
		::AddField( TBIField():New( "XM_DTPROX",	"D",   8 ) )	// Data da prox execucao
		::AddField( TBIField():New( "XM_HRPROX",	"C",   5 ) )	// Hora da prox execucao
		::AddField( TBIField():New( "XM_AMBIENT",	"C",  30 ) )	// Ambiente de execucao
		::AddField( TBIField():New( "XM_ACAO",		"C", 200 ) )	// Code block a ser executado(Nunca mudar este nome)
		::AddField( TBIField():New( "XM_ID",		"C",   6 ) )	// ID do Scheduler
		::AddField( TBIField():New( "XM_ATIVO",		"C",   1 ) )	// Ativo (SIM/NAO)
		::AddField( TBIField():New( "XM_TIMEOUT",	"C",   1 ) )	// Processo Timeout do wf
		::AddField( TBIField():New( "XM_NUMTENT",	"N",   2 ) )	// Numero de tentativas de execucao caso ocorra falhas.
		::AddField( TBIField():New( "XM_TENTEXE",	"N",   2 ) )	// Numero de tentativas executadas

		If !(MPDicInDB())
			::lLocal( .T. )
			cPath :=  GetSrvProfString("StartPath", "\system\") + "sxm" + cEmpAnt + "0" + GetDbExtension()
			
			If !(FILE(cPath))
				::CreateTable()
			EndIf	

		ElseIf !(TCCanOpen(cTableName))

				aAdd( aTable, ::self)

				/*-------------------------------------------------------------------
				/		WFReadSxm => Faz a leitura do arquivo CTREE
				/       WFGrvSxm  => Grava os dados na tabela SXM no banco.
				/-------------------------------------------------------------------*/
				aSxm := WFReadSxm()
				WFGrvSxm(aSxm,aTable,cTableName)

			::lClose()
		EndIf

	end
return

/******************************************************************************
	Recalc()
	Recalcula o horario da proxima execucao da tarefa
******************************************************************************/
method Recalc() class TSXMTable
	local lResult := .f.
	local dDate := MsDate()
	local cTime := Time()
	local aUpdateFields
	
	if !::lIsOpen()
		if !::lOpen()
			return lResult
		end
	end

	if !::lEof()
		::CalcDateTime( @dDate, @cTime )
		if ( dDate <> ::xValue( "XM_DTPROX" ) ) .or. ( cTime <> ::xValue( "XM_HRPROX" ) )
			if ( ::xValue( "XM_TIPO" ) <> 5 ) .and. ( !Empty( cTime ) .and. ( dDate <> CtoD( "/" ) ) )
				aUpdateFields := {}
				AAdd( aUpdateFields, { "XM_DTPROX", dDate } )
				AAdd( aUpdateFields, { "XM_HRPROX", cTime } )
				lResult := ::lUpdate( aUpdateFields )
			else
				lResult := ::lDelete()
			end
		else
			lResult := .t.
		end
	end
return lResult

/******************************************************************************
	RecalcAll()
	Recalcula todos os horarios de execucao de todas as tarefas
******************************************************************************/
method RecalcAll() class TSXMTable
	::SavePos()
	
	if !::lIsOpen()
		if !::lOpen()
			return
		end
	end
	
	::_First()
	
	while !::lEof()
		::Recalc()
		::_Next()
	end
	
   ::RestPos()
return

/******************************************************************************
	Reactive()
	Reativa todas os as tarefas pendentes que nao foram executados a partir de
	0:00hs do mesmo dia, ate o horario atual.
******************************************************************************/
method Reactive() class TSXMTable
	local lResult := .f.
	local cMsg, cFindKey
	local aUpdateFields

	if !::lIsOpen()
		if !::lOpen()
			return lResult
		end
	end

	cFindKey := xFilial( "SXM" ) + "T" + DtoS( MsDate() )
	::_First()
	
	While !::lEof()
	
		if ( ::xValue( "XM_FILIAL" ) + ::xValue( "XM_ATIVO" ) + DtoS( ::xValue( "XM_DTPROX" ) ) ) == cFindKey
			if Val( SubStr( ::xValue( "XM_HRPROX" ), 1, 2 ) + SubStr( ::xValue( "XM_HRPROX" ), 4, 2 ) ) < Val( SubStr( Time(), 1, 2 ) + SubStr( Time(), 4, 2 ) )
				if ::xValue( "XM_TIMEOUT" ) == "T"
					nHora := Val( SubStr( Time(), 1, 2 ) )
					nMin := Val( SubStr( Time(), 4, 2 ) )
					nMin := nMin + 10
					if nMin >= 60
						nHora++
						nMin := nMin - 60
					end
					aUpdateFields := {}
					AAdd( aUpdateFields, { "XM_HRPROX", StrZero( nHora,2 ) + ":" + StrZero( nMin,2 ) } )
					AAdd( aUpdateFields, { "XM_HRINI", StrZero( nHora,2 ) + ":" + StrZero( nMin,2 ) } )
					AAdd( aUpdateFields, { "XM_HRFIM", StrZero( nHora,2 ) + ":" + StrZero( nMin,2 ) } )
					::lUpdate( aUpdateFields )
				else
					::Recalc()
				end
				cMsg := STR0001 + AllTrim( ::xValue( "XM_NOME" )  ) + "] "  //"Reagendando ["
				cMsg += AllTrim( ::xValue( "XM_DESCR" ) )
				cMsg += STR0002 + ::xValue( "XM_HRPROX" ) + STR0003 //" Para: "###"hs"
				ConOut( cMsg )
			end
		end
		::_Next()
	end
return

method CalcDateTime( dDate, cTime ) class TSXMTable
	Local cAtivo
	Local lResult := .f.
	Local nHoras, nMinutos, nIntvSecs, nIniSecs, nDifSecs, nSecs, nHr, nMn
	
	default dDate := MsDate(), cTime := left( Time(),5 )

	if !::lIsOpen()
		if !::lOpen()
			return lResult
		end
	end

	nSecs := 0
	nIniSecs := 0
	nIntvSecs := 0
	cAtivo := ::xValue( "XM_ATIVO" )

	if dDate >= ::xValue( "XM_DTINI" ) .and. dDate <= ::xValue( "XM_DTFIM" )
		// Obtem em segundos o tempo inicial.
		If ( nHoras := val( left( ::xValue( "XM_HRINI" ),2 ) ) ) > 0
			nIniSecs := ( nHoras * 60 ) * 60		// Horas em segundos
		End
		If ( nMinutos := Val( Right( ::xValue( "XM_HRINI" ),2 ) ) ) > 0
			nIniSecs += ( nMinutos * 60 )		// Minutos em segundos 
		End
		If ::xValue( "XM_INTERV" ) == "00:00" // uma vez ao dia
			If ( nHoras := Val( Left( ::xValue( "XM_HRFIM" ),2 ) ) ) > 0
				nSecs := ( nHoras * 60 ) * 60		// Horas em segundos
			End
			If ( nMinutos := Val( Right( ::xValue( "XM_HRFIM" ),2 ) ) ) > 0
				nSecs += ( nMinutos * 60 )		// Minutos em segundos 
			End
			If Seconds() > nSecs
				nSecs += 60
			End
		else
			// Obtem em segundos, o intervalo.
			If ( nHoras := Val( Left( ::xValue( "XM_INTERV" ),2 ) ) ) > 0
				nIntvSecs := ( nHoras * 60 ) * 60	// Horas em segundos
			End
			If ( nMinutos := Val( Right( ::xValue( "XM_INTERV" ),2 ) ) ) > 0
				nIntvSecs += ( nMinutos * 60 )		// Minutos em segundos
			End
			If Seconds() > nIniSecs
				nDifSecs := Int( Seconds() ) - nIniSecs
				nDifSecs := Int( nDifSecs / nIntvSecs ) * nIntvSecs
				nSecs := nIniSecs + nDifSecs
				While Int( Seconds() ) >= nSecs
					nSecs += nIntvSecs
				End
			Else
				nSecs := nIniSecs
			End
		end
		nHr := Int( nSecs / 3600 )
		nMn := Int( ( nSecs - ( nHr * 3600 ) ) / 60 )
		cTime := strZero(nHr, 2) + ":" + strZero(nMn, 2)
		do case
		case ::xValue( "XM_TIPO" ) == 1 // Diario
			if cTime > ::xValue( "XM_HRFIM" )
					cTime := ::xValue( "XM_HRINI" )
					dDate := dDate + 1
			endif
		case ::xValue( "XM_TIPO" ) == 2 // Semanal
			if cTime > ::xValue( "XM_HRFIM" ) .or. !::NextDate( dDate, Dow( dDate ), Dow( dDate ), ::xValue( "XM_SEMANA" ) )
					cTime := ::xValue( "XM_HRINI" )
				if !::NextDate(@dDate, Dow(dDate +1), 7, ::xValue( "XM_SEMANA" ) )
					if !::NextDate(@dDate, 1, Dow(dDate), ::xValue( "XM_SEMANA" ) )
							dDate := ctod("  /  /  ")
							cTime := ""
					end
				end
			end
		case ::xValue( "XM_TIPO" ) == 3 // Mensal
			If cTime > ::xValue( "XM_HRFIM" ) .or. !::NextDate( dDate, Day( dDate ), Day( dDate ), ::xValue( "XM_MENSAL" ) )
					cTime := ::xValue( "XM_HRINI" )
				if !::NextDate( @dDate, Day( dDate + 1), Day(LastDay( dDate + 1)), ::xValue( "XM_MENSAL" ) )
					if !::NextDate(@dDate, 1, Day( dDate ), ::xValue( "XM_MENSAL" ) )
							dDate := ctod("  /  /  ")
							cTime := ""
					end
				end
			end
		case ::xValue( "XM_TIPO" ) == 4 // Exporádico
				dDate := ::xValue( "XM_DTFIM" )
				cTime := ::xValue( "XM_HRFIM" )
		case ::xValue( "XM_TIPO" ) == 5 // Exporádico já executado
				dDate := ctod("/")
				cTime := ""
		endcase
		If dDate > ::xValue( "XM_DTFIM" )
			if ::xValue( "XM_INTERV" ) == "00:00"
				dDate := ::xValue( "XM_DTFIM" )
				if ::xValue( "XM_HRFIM" ) < Left( Time(),5 )
					cTime := Left( Time(),5 )
					if ( Val( SubStr( cTime,4,2 ) ) +10 ) > 59
						if Val( Left( cTime,2 ) ) +1 > 23
							cTime := "00:" + StrZero( ( Val( SubStr( cTime,4,2 ) ) +10 ) -60,2 )
						else
							cTime := StrZero( Val( Left( cTime,2 ) ) +1,2 ) + ":" + StrZero( ( Val( SubStr( cTime,4, 2 ) ) +10 ) -60,2 )
						end
					else
						cTime := Left( cTime,3 ) + StrZero( Val( SubStr( cTime,4,2 ) ) +10,2 )
					end
				end
			else
				dDate := ctod("/")
				cTime := ""
			end
			cAtivo := "F"
		end
	else
		if dDate < ::xValue( "XM_DTINI" )
			dDate := ::xValue( "XM_DTINI" )
			cTime := ::xValue( "XM_HRINI" )
		else
			if ( dDate - ::xValue( "XM_DTFIM" ) ) > 3
				nHoras := val( left( cTime,2 ) )
				nMinutos := val( substr( cTime,4,2 ) ) + 5
				if nMinutos > 59
					nHoras++
					nMinutos := nMinutos - 60
				end
				while ( nHoras > 23 )
					dDate++
					nHoras := nHoras - 24
				end
				cTime := strZero( nHoras,2 ) + ":" + strZero( nMinutos,2 )
			else
				dDate := ctod("/")
				cTime := ""
				cAtivo := "F"
			end
		end
	end
return ( ( ::xValue( "XM_DTPROX" ) <> dDate ) .or. ( ::xValue( "XM_HRPROX" ) <> cTime ) .or. ( ::xValue( "XM_ATIVO" ) <> cAtivo ) )

/******************************************************************************
NextDate()
	Verifica qual a próxima data de execução da tarefa com base em DIAS OU MESES
*******************************************************************************/
method NextDate( dDate, nStart, nFinish, cSequence ) class TSXMTable
	local lResult := .f.
	local n
	for n := nStart to nFinish
		dDate := dDate + 1
		if ( lResult := ( substr( cSequence, n, 1 ) == "X" ) )
			return lResult
		end
	next
return lResult

/******************************************************************************
	FindExecTask()
	Verifica qual a próxima data de execução da tarefa com base em DIAS OU MESES
*******************************************************************************/
method FindExecTask( dDate, cTime ) class TSXMTable
	local lResult := .f.
	local cFindKey
	
	default dDate := MsDate(), cTime := Time()
	
	if !::lIsOpen()
		if !::lOpen()
			return lResult
		end
	end

	::_First()
	
	dDate := DToS( dDate )
	cTime := Left( cTime,5 )
	cFindKey := xFilial("SXM") + dDate + cTime + "T"
	
	while !::lEof()
		if ( ::xValue( "XM_FILIAL" ) + DtoS( ::xValue( "XM_DTPROX" ) + ::xValue( "XM_HRPROX" ) + ::xValue( "XM_ATIVO" ) ) ) == cFindKey
			exit
		end
		::_Next()
	end
	
return !::lEof()

/******************************************************************************
	LocateTask()
*******************************************************************************/ 
method LocateTask( cTaskID, aTaskFields ) class TSXMTable
	local nC
	local lResult := .f.
	local cFindKey
	local aStructure

	if cTaskID == nil
		return lResult
	end

	if !::lIsOpen()
		if !::lOpen()
	 		return lResult
		end
	end

	aStructure := ::aStruct()
	::_First()
	cFindKey 	:= xFilial( "SXM" ) + Upper( Left( cTaskID + Space( Len( ::xValue( "XM_CODIGO" ) ) ), Len( ::xValue( "XM_CODIGO" ) ) ) )

	// Varredura nos agendamentos (SXM).
	while !::lEof()
		if ( SubStr(::xValue( "XM_FILIAL" ),1, Len( xFilial( "SXM" ) ) ) + ::xValue( "XM_CODIGO" )  == ( cFindKey ) )
			lResult := .t.
			exit
		end
		::_Next()
	end

	if ( lResult ) .and. ( aTaskFields <> nil )
		aTaskFields := Array( Len( aStructure ) )
		for nC := 1 to len( aStructure )
			aTaskFields[ nC ] := ::xValue( aStructure[ nC,1 ] )
		next
	end
return lResult

/******************************************************************************
	UpdateTask()
*******************************************************************************/ 
method UpdateTask( cTaskID, aTaskFields ) class TSXMTable
	local nC
	local lResult := .f.
	local aStructure := ::aStruct()
	
	default cTaskID := "", aTaskFields := {}
	
	if Len( aTaskFields ) > 0
		
		if ( lResult := ( ::LocateTask( cTaskID ) ) )
			for nC := 1 to len( aTaskFields )
				
				if valtype( aTaskFields[ nC ] ) <> "A"
					aTaskFields[ nC ] := { aStructure[ nC,1 ], aTaskFields[ nC ] }
				end
			next
			
			lResult := ::lUpdate( aTaskFields )
		end
	end
return lResult

/******************************************************************************
	DeleteTask()
	Apaga o registro da tarefa solicitada. 
	Retorno verdadeiro caso bem sucedido e falso caso contrario.
******************************************************************************/
method DeleteTask( cTaskID ) class TSXMTable
	local lResult := .f.
	
	if cTaskID == nil
		return lResult
	end
	
	if ::LocateTask( cTaskID )
		lResult := ::lDelete()
	end
return lResult

/******************************************************************************
	AppendTask()
	Inclui no SXM os registros de tarefas encontrados nos arquivos .tsk no diretorio "\task"
******************************************************************************/ 
method AppendTask( cTaskFile ) class TSXMTable
	Local oDbTemp
	Local nPos
	Local lResult := .f.
	Local dDate, cTime
	Local aRegs
	Local oFile := Nil
	Local aTask := {}
	
	if !file( cTaskFile )
		return lResult
	end
	
	if !::lIsOpen()
		if !::lOpen()
			return lResult
		end
	end

	//--------------------------------------------------------
	// Verifica se modelo de inserção na SXM não usa CTREE.
	//--------------------------------------------------------
	If ( Left( RetFileName( cTaskFile ), 1 ) == "_" )
		oFile := FWFileReader():New( cTaskFile )
		
		If ( oFile:Open() )
			While ( oFile:hasLine() )
		      	aRegs := {}
		      	aTask := {}

		      	aTask := StrToKArr( oFile:GetLine(), "|" )
		      	
				If ( Len( aTask ) == 19 )
		      	
					AAdd( aRegs, { "XM_FILIAL",  	aTask[1] } )
					AAdd( aRegs, { "XM_CODIGO", 	aTask[2] } )
					AAdd( aRegs, { "XM_NOME",		aTask[3] } )
					AAdd( aRegs, { "XM_DESCR",		aTask[4] } )
					AAdd( aRegs, { "XM_TIPO",		Val( aTask[5] ) } )
					AAdd( aRegs, { "XM_DTINI",		CTOD( aTask[6] ) } )
					AAdd( aRegs, { "XM_HRINI",		aTask[7] } )
					AAdd( aRegs, { "XM_DTFIM",		CTOD( aTask[8] ) } )
					AAdd( aRegs, { "XM_HRFIM",		aTask[9] } )
					AAdd( aRegs, { "XM_INTERV", 	aTask[10] } )
					AAdd( aRegs, { "XM_SEMANA", 	aTask[11] } )
					AAdd( aRegs, { "XM_MENSAL", 	aTask[12] } )				
					AAdd( aRegs, { "XM_DTPROX", 	CTOD( aTask[13] ) } )
					AAdd( aRegs, { "XM_HRPROX", 	aTask[14] } )				
					AAdd( aRegs, { "XM_AMBIENT",	aTask[15] } )
					AAdd( aRegs, { "XM_ACAO",		aTask[16] } )
					AAdd( aRegs, { "XM_ATIVO",		aTask[17] } )
					AAdd( aRegs, { "XM_TIMEOUT",	aTask[18] } )
					AAdd( aRegs, { "XM_ID",			aTask[19] } )				
	
					AAdd( aRegs, { "XM_NUMTENT",	0 } )
					AAdd( aRegs, { "XM_TENTEXE",	0 } )
	
					while !::lEof()
			   		
						if ::lDeleted()
							::lRecall()
		  					exit
						end
			  				
		  				::_Next()
					end
			   		
					if ::lEof()
						::lAppend( aRegs )
					else
				   		::lUpdate( aRegs )
					end
				   
					::CalcDateTime( @dDate, @cTime )
					nPos := AScan( aRegs, {|x| x[1] == "XM_DTPROX"} )
					aRegs[nPos,2] := dDate
					nPos := AScan( aRegs, {|x| x[1] == "XM_HRPROX"} )
					aRegs[nPos,2] := cTime
		
					::lUpdate( aRegs )
					
				EndIf
			EndDo

		   oFile:Close()
		EndIf
	Else
		SET DELETED OFF
		oDbTemp := TBITable():New( cTaskFile, CriaTrab(,.f.) )
		oDbTemp:lLocal( .t. )
	
		if oDbTemp:lOpen()
			oDbTemp:_First()
			::_First()
	
			while !oDbTemp:lEof()
		   		aRegs := {}
		   		AAdd( aRegs, { "XM_FILIAL",  	oDbTemp:xValue( "XM_FILIAL" ) } )
				AAdd( aRegs, { "XM_CODIGO", 	oDbTemp:xValue( "XM_CODIGO" ) } )
				AAdd( aRegs, { "XM_NOME",		oDbTemp:xValue( "XM_NOME" ) } )
				AAdd( aRegs, { "XM_DESCR",		oDbTemp:xValue( "XM_DESCR" ) } )
				AAdd( aRegs, { "XM_TIPO",		oDbTemp:xValue( "XM_TIPO" ) } )
				AAdd( aRegs, { "XM_DTINI",		oDbTemp:xValue( "XM_DTINI" ) } )
				AAdd( aRegs, { "XM_HRINI",		oDbTemp:xValue( "XM_HRINI" ) } )
				AAdd( aRegs, { "XM_DTFIM",		oDbTemp:xValue( "XM_DTFIM" ) } )
				AAdd( aRegs, { "XM_HRFIM",		oDbTemp:xValue( "XM_HRFIM" ) } )
				AAdd( aRegs, { "XM_INTERV", 	oDbTemp:xValue( "XM_INTERV" ) } )
				AAdd( aRegs, { "XM_DTPROX", 	oDbTemp:xValue( "XM_DTPROX" ) } )
				AAdd( aRegs, { "XM_HRPROX", 	oDbTemp:xValue( "XM_HRPROX" ) } )
				AAdd( aRegs, { "XM_SEMANA", 	oDbTemp:xValue( "XM_SEMANA" ) } )
				AAdd( aRegs, { "XM_MENSAL", 	oDbTemp:xValue( "XM_MENSAL" ) } )
				AAdd( aRegs, { "XM_AMBIENT",	oDbTemp:xValue( "XM_AMBIENT" ) } )
				AAdd( aRegs, { "XM_ACAO",		oDbTemp:xValue( "XM_ACAO" ) } )
				AAdd( aRegs, { "XM_ID",			oDbTemp:xValue( "XM_ID" ) } )
				AAdd( aRegs, { "XM_ATIVO",		oDbTemp:xValue( "XM_ATIVO" ) } )
				AAdd( aRegs, { "XM_TIMEOUT",	oDbTemp:xValue( "XM_TIMEOUT" ) } )
				
				if oDbTemp:nFieldPos( "XM_NUMTENT" ) > 0 .and. oDbTemp:nFieldPos( "XM_TENTEXE" ) > 0
					AAdd( aRegs, { "XM_NUMTENT",	oDbTemp:xValue( "XM_NUMTENT" ) } )
					AAdd( aRegs, { "XM_TENTEXE",	oDbTemp:xValue( "XM_TENTEXE" ) } )
				else
					AAdd( aRegs, { "XM_NUMTENT",	0 } )
					AAdd( aRegs, { "XM_TENTEXE",	0 } )
				end
					
				while !::lEof()
		   		
					if ::lDeleted()
							::lRecall()
		  					exit
					end
		  				
				   	::_Next()
				end
	
				if ::lEof()
						::lAppend( aRegs )
				else
				   		::lUpdate( aRegs )
				end
				   
					::CalcDateTime( @dDate, @cTime )
					nPos := AScan( aRegs, {|x| x[1] == "XM_DTPROX"} )
					aRegs[nPos,2] := dDate
					nPos := AScan( aRegs, {|x| x[1] == "XM_HRPROX"} )
					aRegs[nPos,2] := cTime
		
					::lUpdate( aRegs )
				   oDbTemp:_Next()
			end
				
			oDbTemp:lClose()
		end
						
	   SET DELETED ON
	EndIf
return 

/******************************************************************************
	DelTimeOuts()
	Apaga todos ou somente as tarefas timeouts informadas em aID
******************************************************************************/ 
method DelTimeOuts( cMailID, aID ) class TSXMTable

	default cMailID := "", aID := {}
	
	if !::lIsOpen()
		if !::lOpen()
			return
		end
	end

	::_First()
	
	while !::lEof()
		
		if (::xValue( "XM_DTFIM" ) < MsDate() )
			aUpdateFields := {}
			AAdd( aUpdateFields, { "XM_ATIVO", "F" } )
			lResult := ::lUpdate( aUpdateFields )
			::lDelete()
		end
		
		if ( Alltrim(::xValue( "XM_FILIAL" )) == Alltrim(xFilial( "SXM" ) )) .and. ( ::xValue( "XM_TIPO" ) == 4 )
			if empty( cMailID ) .or. ( AllTrim( Upper( cMailID ) ) == AllTrim( Upper( ::xValue( "XM_NOME" ) ) ) )
				if len( aID ) == 0 .or. AScan( aID, ::xValue( "XM_ID" ) ) > 0
					::lDelete()
				end
			end
		end
		::_Next()
	end	
return

/******************************************************************************
	ExecTask()
	Executa a tarefa atualmente posicionada pelo recno
******************************************************************************/
method ExecTask( cTaskID ) class TSXMTable
	local lResult := .f.
	local cMsg, cCmd, cPar := "", cEnvironment, cLCKFileJob

	if !::lIsOpen()
		if !::lOpen()
			return
		end
	end
	
	if cTaskID == nil
	
		if ::lEof()
			return lResult
		else
			cTaskID := ::xValue( "XM_CODIGO" )
		end
	
	else
	
		if !::LocateTask( cTaskID )
			return lResult
		end
		
	end
	
	lResult := .t.
	cCmd := Alltrim( ::xValue( "XM_ACAO" ) )

	if left(cCmd, 1) == chr(64)
		cCmd := WFLoadFile( substr( cCmd,2 ) )
	end

	if ( nPos := At( "(", cCmd ) ) > 0
		cPar := SubStr( cCmd, nPos +1 )
		cCmd := Left( cCmd, nPos -1 )
		if ( nPos := Rat( ")", cPar ) ) > 0
			if nPos > 1
				cPar := Left( cPar, nPos -1 )
			else
				cPar := ""
			end
		end
	end
			
	cPar := "{" + cPar + "}" 
		
	if Empty( cEnvironment := ::xValue( "XM_AMBIENT" ) )
		cEnvironment := GetEnvServer()
	end
			
	cEnvironment := AllTrim( Upper( cEnvironment ) )
	
	if ::xValue( "XM_TIPO" ) <> 4
		::Recalc()
	end

	if ::xValue( "XM_ATIVO" ) == "T" .and. ( ::xValue( "XM_DTFIM" ) <= MsDate() ) .and. ( ::xValue( "XM_HRFIM" ) <= Left( Time(),5 ) )
		if ::lUpdate( { { "XM_ATIVO", "F" } } )
			::lDelete()
		end
	end

	cMsg := STR0004 //"Executando tarefa='%c' Acao='%c' Ambiente='%c'"
	cMsg := FormatStr( cMsg, { AllTrim( ::xValue( "XM_CODIGO" ) ), cCmd, AllTrim( ::xValue( "XM_AMBIENT" ) ) } )
	WFConOut( cMsg )
	
	if ::nFieldPos( "XM_NUMTENT" ) > 0 .and. ::nFieldPos( "XM_TENTEXE" ) > 0
		cLCKFileJob := "/semaforo/scheduler/emp" + cEmpAnt + "/schjob" + StrZero( ::nRecNo(),4 ) + ".lck"
		fErase( cLCKFileJob )
	
		if !file( cLCKFileJob )
		
			if ::xValue( "XM_NUMTENT" ) > 0
				StartJob( "WFLauncher", cEnvironment, .F., { cCmd, &cPar, cEmpAnt, ::nRecNo(), cLCKFileJob } )
			else
				StartJob( "WFLauncher", cEnvironment, .F., { cCmd, &cPar } )
			end
		end
	else
		StartJob( "WFLauncher", cEnvironment, .F., { cCmd, &cPar } )
	end
return lResult

/******************************************************************************
	SaveTask()
	Grava a tarefa
******************************************************************************/ 
method SaveTasks( cTaskDir, aTasks ) class TSXMTable
	Local nTask			:= 0
	Local cTaskFile     := ""
	Local cTaskAlias    := ""
	Local aTask         := {}
	Local lResult 		:= .F.   	//Indica se o processo de salvar a tarefa teve sucesso. 
	Local lCreated		:= .F.      //Indica se o arquivo '.tsk' foi criado.  
	Local nTries		:= 0		//Número de tentativa de criação do arquivo '.tsk'
	Local cFile			:= ""
	Local cPath			:= ""
	Local cDate			:= Dtos(Date())
	Local cTime			:= StrTran(Time(), ":", "")
	Local nHandle       := 0
	Local cValue        := ""
	Local nInd          := 0

	Default cTaskDir := ""

	//------------------------------------------------------------------------
	// Verifica se o SXM pode ser aberto.
	//------------------------------------------------------------------------ 
	If !( ::lIsOpen() )
		If !( ::lOpen() )
			return lResult
		EndIf
	EndIf

	cPath      := cBIFixPath( cTaskDir, "/" )
	cTaskAlias := "_WF" + cDate + cTime 

	//------------------------------------------------------------------------
   	// Cria o arquivo '.tsk'. 
   	//------------------------------------------------------------------------	      
	While ! ( lCreated )
		cFile := Lower( cPath + cTaskAlias )
	  	cTaskFile := cFile + ".tsk"

		If ( File( cFile + ".tsk" ) .Or. File( cFile + ".sch" ) )
	    	Sleep( 1000 )
	    	cTime  := StrTran(Time(), ":", "")
		 	nTries += 1
		Else
	   		WFConout( PadR( "Operational System", 20 ) + ": " + cBIStr( If( IsSrvUnix(), "Linux", "Windows" ) ) ,,,,, "WFTSXM" )
			WFConout( PadR( "Task File"			, 20 ) + ": " + cBIStr( cTaskFile ) ,,,,, "WFTSXM" ) 

			nHandle := FCreate( cTaskFile )

			//-------------------------------------------
			// Verifica se o arquivo foi criado.
			//-------------------------------------------
			If !( nHandle == -1 )
				lCreated := .T.
			EndIf
		EndIf

		//------------------------------------------------------------------------
		// Define o número máximo de 10 tentativas para evitar loop infinito.
		//------------------------------------------------------------------------   
		If ( nTries > 10 )
			Return lResult	
		EndIf
	End

	If File ( cTaskFile )
		For nTask := 1 to Len( aTasks )
			cValue := ""
			aTask  := aTasks[ nTask ]

			For nInd := 1 To Len( aTask )
				cValue += iif( cBIStr( aTask[nInd][2] ) == "", " ", cBIStr( aTask[nInd][2] ) )

				If nInd < Len( aTask )
					cValue += "|"
				EndIf
			Next nInd

			FWrite( nHandle, cValue + chr(13) + chr(10) )
		Next nTask
		FClose( nHandle )

		//------------------------------------------------------------------------
		// Mantém o aquivo com a extensão '.sch'.
		//------------------------------------------------------------------------ 
		FRename( cTaskFile, ChgFileExt( cTaskFile, ".sch" ) )
		FErase( cTaskFile )

		//------------------------------------------------------------------------
		//Indica que o processo teve sucesso.
		//------------------------------------------------------------------------ 
		lResult := .T.
	EndIf
Return lResult


/*/{Protheus.doc} WFReadSxm
    (Função que faz a leitura do arquivo em disco para importação dos registros no banco)
    @type  Static Function
	@version 12.1.33
    @author Victor Vieira 
    @since 21/10/2020
    @return aDados, Array, Retornas os dados após a leitura da tabela SXM(ctree)
    /*/
Static function WFReadSxm()

	Local aDados := {}
	Local cPath  := ""
	Local cRDD 	 := Iif( ( "CTREE" $ RealRDD() ), "CTREECDX", "DBFCDX" )  

    /*-------------------------------------------------------------------
    /  Faz a leitura do arquivo SXM990 e armazena no array aDados
    /-------------------------------------------------------------------*/
	cPath :=  GetSrvProfString("StartPath", "\system\") + "sxm" + cEmpAnt + "0" + GetDbExtension()

	If FILE(cPath)
		dbUseArea(.F.,cRDD,cPath,"TMP",.T.,.F.)
		SET DELETED OFF  //Habilita deletados  
		dbSelectarea("TMP")

		TMP->(dbGoTop())
		While TMP->(!EOF())

			aadd( aDados,{TMP->XM_FILIAL,;
				TMP->XM_CODIGO,;
				TMP->XM_NOME,;
				TMP->XM_DESCR,;
				TMP->XM_TIPO,;
				TMP->XM_DTINI,;
				TMP->XM_HRINI,;
				TMP->XM_INTERV,;
				TMP->XM_SEMANA,;
				TMP->XM_MENSAL,;
				TMP->XM_DTPROX,;
				TMP->XM_HRPROX,;
				TMP->XM_AMBIENT,;
				TMP->XM_ACAO,;
				TMP->XM_ID,;
				TMP->XM_ATIVO,;
				TMP->XM_TIMEOUT,;
				TMP->XM_NUMTENT,;
				TMP->XM_TENTEXE})

			TMP->(dbSkip())
		enddo

		TMP->(dbCloseArea())
		FERASE(cPath)
	Else
		aDados := {}
	EndIf
Return aDados


/*/{Protheus.doc} WFGrvSxm
	(Função para gravar os dados na tabela SXM no Banco)
	@type  Static Function
	@version 12.1.33
	@author Squad Business Analytics SP
	@since 17/11/2020
	@param aSxm, Array, Dados carregados do arquivo CTREE
	@param aTable, Array, Tabela SXM para que seja aberta 
	@param cTableName, caracter, Nome da tabela que será utilizada no Lock dos registros.
	@see (links_or_references)
/*/
Static Function WFGrvSxm(aSxm,aTable,cTableName)
	Local nXm := 0
	Local nTable := 0

	//-------------------------------------------------------------------
	// Abre a tabela.
	//-------------------------------------------------------------------
	For nTable := 1 To Len( aTable )
		If !( aTable[nTable]:lIsOpen() )
			aTable[nTable]:ChkStruct(.T.)
			aTable[nTable]:lOpen()
		EndIf
	Next nTable
	If !Empty(aSxm)

		For nXm := 1 To Len( aSxm)

			Reclock(cTableName,.T.)
				Replace XM_FILIAL   With  aSxm[nXm][1]
				Replace XM_CODIGO   With  aSxm[nXm][2]
				Replace XM_NOME     With  aSxm[nXm][3]
				Replace XM_DESCR    With  aSxm[nXm][4]
				Replace XM_TIPO     With  aSxm[nXm][5]
				Replace XM_DTINI    With  aSxm[nXm][6]
				Replace XM_HRINI    With  aSxm[nXm][7]
				Replace XM_INTERV   With  aSxm[nXm][8]
				Replace XM_SEMANA   With  aSxm[nXm][9]
				Replace XM_MENSAL   With  aSxm[nXm][10]
				Replace XM_DTPROX   With  aSxm[nXm][11]
				Replace XM_HRPROX   With  aSxm[nXm][12]
				Replace XM_AMBIENT  With  aSxm[nXm][13]
				Replace XM_ACAO     With  aSxm[nXm][14]
				Replace XM_ID       With  aSxm[nXm][15]
				Replace XM_ATIVO    With  aSxm[nXm][16]
				Replace XM_TIMEOUT  With  aSxm[nXm][17]
				Replace XM_NUMTENT  With  aSxm[nXm][18]
				Replace XM_TENTEXE  With  aSxm[nXm][19]
			MsUnLock()

		next nXm
	EndIf			
Return  
