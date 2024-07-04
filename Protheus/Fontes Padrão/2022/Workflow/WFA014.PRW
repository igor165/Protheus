#INCLUDE "DBTREE.CH"
#INCLUDE "SIGAWF.CH"


/*
	_nLibCre
   Retorna o numero de liberacao de credito em aberto
*/
FUNCTION _nLibCred()
	Local nResult := 0, nIndex
	Local cIndex, cKey, cCond

	dbSelectArea("SC9")
	dbGoTop()
	
	if !Eof()
		cIndex := CriaTrab( nil,.f. )
		cKey := IndexKey()
		cCond := "C9_FILIAL == '" + xFilial("SC9") + "' .AND. ( C9_BLCRED == '01' .OR. C9_BLCRED == '04' )" 

		IndRegua( "SC9", cIndex, cKey,, cCond, '', .f. )
		nIndex := RetIndex("SC9")
	
#IFNDEF TOP
		DbSetIndex( cIndex + OrdBagExt() )
#ENDIF

		dbSetOrder(nIndex+1)
		dbGoTop()
	
		while !Eof()
			nResult++
			dbSkip()
		end
		
		dbCloseArea()
		fErase( cIndex + OrdBagExt() )
	end

return nResult

FUNCTION _nPedCom()
	local nResult := 0, nIndex
	local cIndex, cKey, cCond

	dbSelectArea("SCR")
	dbSetOrder( 2 )
	dbGoTop()
	
	if !Eof()
		cIndex := CriaTrab( nil,.f. )
		cKey := IndexKey()
		cCond := "CR_FILIAL == '" + xFilial("SCR") + "' .And. CR_USER == '" + RetCodUsr() + "' .And. CR_STATUS == '02'"
		IndRegua( "SCR", cIndex, cKey,, cCond, '', .f. )
		nIndex := RetIndex("SCR")
	
#IFNDEF TOP
		DbSetIndex( cIndex + OrdBagExt() )
#ENDIF

		dbSetOrder(nIndex+1)
		dbGoTop()
	
		while !Eof()
			nResult++
			dbSkip()
		end
		
		dbCloseArea()
		fErase( cIndex + OrdBagExt() )
	end

return nResult

/*
	_nFINA070()
	Retorna o numero de tituloa a Receber em aberto ou semi-aberto
*/
FUNCTION _nFINA070()
	local nResult := 0, nIndex
	local cIndex, cKey, cCond

	dbSelectArea("SE1")
	dbGoTop()
	
	if !Eof()
		cIndex := CriaTrab( nil,.f. )
		cKey := IndexKey()
		cCond := "E1_FILIAL == '" + xFilial("SE1") + "' .And. E1_SALDO <> 0"
		IndRegua( "SE1", cIndex, cKey,, cCond, '', .f. )
		nIndex := RetIndex("SE1")
	
#IFNDEF TOP
		DbSetIndex( cIndex + OrdBagExt() )
#ENDIF

		dbSetOrder(nIndex+1)
		dbGoTop()
	
		while !Eof()
			nResult++
			dbSkip()
		end
		
		dbCloseArea()
		fErase( cIndex + OrdBagExt() )
	end

return nResult

/*
	eFINA070()
	Exibe somente os titulos em abertos ou semi-abertos.
*/
FUNCTION _eFINA070()
	local nIndex
	local cIndex, cKey, cCond

	dbSelectArea("SE1")
	dbGoTop()
	
	if !Eof()
		cIndex := CriaTrab( nil,.f. )
		cKey := IndexKey()
		cCond := "E1_FILIAL == '" + xFilial("SE1") + "' .And. E1_SALDO <> 0"
		IndRegua( "SE1", cIndex, cKey,, cCond, '', .f. )
		nIndex := RetIndex("SE1")
	
#IFNDEF TOP
		DbSetIndex( cIndex + OrdBagExt() )
#ENDIF

		dbSetOrder(nIndex+1)
		dbGoTop()
	end
	
	FINA070()
	
	dbCloseArea()
	fErase( cIndex + OrdBagExt() )
return	


user function solcom()
conout("executando solcom")
return

user function versolcom()
conout("executando versolcom")
return 5

function WFA014()
local oWFToDo := TWFToDoDlg():New()
oWFTodo:ShowDlg()
return


class TWFToDoDlg
	data oDlg
	data oTimer
	data oTreeView
	data aToDoList
	data nCount
	data cLastTime
	method New() CONSTRUCTOR
	method ShowDlg()
	method LoadToDoList()
	method TreeViewUpdate()
	method AdjustTime( aItem )
	method RunTimer()
	method DbClick()
endclass

method New() class TWFToDoDlg
	ChkFile( "WF1" )
	::nCount := 0
	::LoadToDoList()
return

method ShowDlg() class TWFToDoDlg
	local oSelf := self
	
	DEFINE DIALOG ::oDlg TITLE "Lista de tarefas diarias" FROM 0,0 TO 400,450 PIXEL
	
	DEFINE DBTREE ::oTreeView FROM 15,03 TO 180,200 OF ::oDlg PIXEL CARGO
	::TreeViewUpdate()

	DEFINE TIMER ::oTimer INTERVAL 5000 ACTION ::RunTimer() OF ::oDlg
	ACTIVATE MSDIALOG oSelf:oDlg CENTERED ON INIT ( oSelf:oTimer:Activate(), EnchoiceBar( oSelf:oDlg,{|| oSelf:DbClick()}, {|| oSelf:oDlg:End() } ) )
return

method LoadToDoList() class TWFToDoDlg
	local aItem
	local cFindKey
	
	::aToDoList := {}

	dbSelectArea( "WF8" )
	dbGoTop()
	
	while !Eof()
		dbSelectArea( "WFB" )
		cFindKey := xFilial( "WFB" ) + Left( Subs(cUsuario,7,15) + Space( 15 ),15 ) + WF8->WF8_CODIGO

		if dbSeek( cFindKey )
			AAdd( ::aToDoList, { WF8->WF8_CODIGO, WF8->WF8_DESCR, {} } )
			dbSelectArea( "WF9" )
			dbSeek( xFilial( "WF9" ) + WF8->WF8_CODIGO )

			while !Eof() .and. ( WF9_FILIAL + WF9_FLUXO ) == ( xFilial( "WF9" ) + WF8->WF8_CODIGO )
			   dbSelectArea( "WF1" )
				if dbSeek( xFilial( "WF1" ) + WF9->WF9_PROC )
					aItem := { WF1->WF1_COD, WF1->WF1_DESCR, WF1->WF1_ACAO, WF1->WF1_RETORN, WF1->WF1_FIGUR1, WF1->WF1_FIGUR2, 0, WF1->WF1_INTERV, "00:00", 0 }
					::AdjustTime( aItem )
					AAdd( ::aToDoList[ Len( ::aToDoList ),3 ], aItem )
				end
				dbSelectArea( "WF9" )
				dbSkip()
			end
		
		end
		
		dbSelectArea( "WF8" )
		dbSkip()
	end
	
return

method TreeViewUpdate() class TWFToDoDlg
	local nC1, nC2
	local cItem, cImage1, cImage2
	
	if ::nCount > 0
		for nC1 := 1 to ::nCount
			if ::oTreeView:TreeSeek( StrZero( nC1,3 ) )
				::oTreeView:DelItem()
			end
		next   
	end
	
	::nCount := 0
	
	for nC1 := 1 to len( ::aToDoList )
		::nCount++
		DBADDTREE ::oTreeView PROMPT Left( AllTrim( ::aToDoList[ nC1,2 ] ) + Space(50),50 ) RESOURCE "FOLDER5","FOLDER6" CARGO StrZero( ::nCount,3 ) OPENED
		
		for nC2 := 1 to len( ::aToDoList[ nC1,3 ] )
			::nCount++
			::aToDoList[ nC1,3,nC2,10 ] := ::nCount
			cItem := AllTrim( ::aToDoList[ nC1,3,nC2,2 ] )
			
			if ValType( ::aToDoList[ nC1,3,nC2,7 ] ) == "N"
				if ::aToDoList[ nC1,3,nC2,7 ] > 0
					cItem += "(" + AllTrim( Str( ::aToDoList[ nC1,3,nC2,7 ] ) ) + ")"
				end
			else
				cItem += "(*)"
			end
			
			DBADDITEM ::oTreeView PROMPT cItem CARGO StrZero( ::nCount,3 )
			cImage1 := if( Empty( cImage1 := ::aToDoList[ nC1,3,nC2,5 ] ), "FOLDER5", cImage1 )
			cImage2 := if( Empty( cImage2 := ::aToDoList[ nC1,3,nC2,6 ] ), "FOLDER6", cImage2 )
 			::oTreeView:ChangeBmp( cImage1, cImage2,,, StrZero( ::nCount,3 ) )
		next
		
	   DBENDTREE ::oTreeView
   end
   
	::oTreeView:TreeSeek("001")    
	::oTreeView:Refresh()
return

method DbClick() class TWFToDoDlg
	local aItem
	local cAction
	local nCargo, nC1, nC2
	
	if ::oTimer <> NIL
		ProcessMessages()
		::oTimer:DeActivate()
	end
	
	if ( nCargo := Val( ::oTreeView:GetCargo() ) ) > 0
	
		for nC1 := 1 to len( ::aToDoList )
		
			for nC2 := 1 to len( ::aToDoList[ nC1,3 ] )
			
				if ::aToDoList[ nC1,3,nC2,10 ] == nCargo
					aItem := ::aToDoList[ nC1,3,nC2 ]
					
					if !Empty( cAction := AllTrim( aItem[ 3 ] ) )
				
						if At( "(", cAction ) == 0
							cAction += "("
						end
				
						if Right( cAction,1 ) <> ")"
							cAction += ")"
						end

						BEGIN SEQUENCE
							&( cAction )
							::AdjustTime( aItem )
							::aToDoList[ nC1,3,nC2 ] := aItem
						END SEQUENCE
						
					end

				end
				
			next
			
		next
		
	end
	
   if ::oTimer <> NIL
		::oTimer:Activate()
		ProcessMessages()
	end
	
return

method AdjustTime( aItem ) class TWFToDoDlg
	local nH, nM, nS1, nS2
	local cInterval
	
	default aItem := {}
	
	if len( aItem ) > 0
		cInterval := aItem[ 8 ]
		nH := Val( Left( cInterval,2 ) )
		nM := Val( Right( cInterval,2 ) )
			
		if ( nS1 := ( ( nH * 60 ) * 60 ) + ( nM * 60 ) ) > 0  // se for maior que 00:00
			
			if Seconds() > nS1
				nS2 := Int( Seconds() ) // remove os milisegundos
				nS2 := Int( nS2 / nS1 ) * nS1
				nS2 += nS1
			else
				nS2 := nS1
			end
				
			if nS2 >= 3600
				nH := Int( nS2 / 3600 )
				nM := ( nS2 - ( nH * 3600 ) ) / 60
			else
				nH := 0
				nM := nS2 * 60
			end

		   aItem[ 9 ] := StrZero( nH,2 ) + ":" + StrZero( nM,2 )
		end
			
	end
	
return aItem

method RunTimer() class TWFToDoDlg
	local aItem
	local lRefresh := .f.
	local nC1, nC2, nResult
	local cReturn, cTime := Left( Time(),5 )
	
	if ( ::cLastTime <> cTime ) .and. len( ::aToDoList ) > 0
		::cLastTime := cTime

//		bLastError := ErrorBlock( { |e| WFErrorBlock( e, cMsgError ) } )
				
		if ::oTimer <> NIL
			ProcessMessages()
			::oTimer:DeActivate()
		end
	
		for nC1 := 1 to len( ::aToDoList )
		
			for nC2 := 1 to len( ::aToDoList[ nC1,3 ] )
				aItem := ::aToDoList[ nC1,3,nC2 ]

				if aItem[ 9 ] == cTime
					lRefresh := .t.
					
					if !Empty( cReturn := AllTrim( aItem[ 4 ] ) )
				
						if At( "(", cReturn ) == 0
							cReturn += "("
						end
				
						if Right( cReturn,1 ) <> ")"
							cReturn += ")"
						end

						BEGIN SEQUENCE
							nResult := &( cReturn )
							
							if ValType( nResult ) <> "N"
								nResult := 0
							end
							
							aItem[ 7 ] := nResult
						END SEQUENCE
						
					end

					::AdjustTime( aItem )
					::aToDoList[ nC1,3,nC2 ] := aItem
				end
			
			next
		
			if lRefresh
				::TreeViewUpdate()
			end
			
		next
		
	   if ::oTimer <> NIL
			::oTimer:Activate()
			ProcessMessages()
		end
		
	end
	
return
