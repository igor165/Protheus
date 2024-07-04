
#INCLUDE "SIGAWF.CH"

#DEFINE	WF_PROCESSOS	6
#DEFINE	WF_USUARIOS		7

/*
	CADASTRO DE FLUXO x PROCESSOS
*/
FUNCTION WFA017()
	Local cFindKey
	Local nC1, nC2
	Local lOk := .f., lFound
	Local bLine1, bLine2
	Local aBrowser := {}, aItems
	Local oDlg, oBrowser1, oBrowser2, oGroup1, oGroup2, oChkBtn, oUnChkBtn
	
	ChkFile( "WF9" )
	ChkFile( "WF1" )
	dbSelectArea( "WF1" )
	dbGoTop()
	
	if Eof()
		MsgAlert( "Nao ha processos cadastrados." )
		return
	end
		
	ChkFile( "WF8" )
	dbSelectArea( "WF8" )
	dbGoTop()
	
	if Eof()
		MsgAlert( "Nao ha fluxos cadastrados." )
		return
	end

	While !Eof() .and. ( WF8->WF8_FILIAL == xFilial( "WF8" ) )
		AAdd( aBrowser, { WF8->WF8_CODIGO, WF8->WF8_DESCR, {} } )
		dbSelectArea( "WF1" )
		dbGoTop()
		
		while !Eof() .and. ( WF1->WF1_FILIAL == xFilial( "WF1" ) )
			dbSelectArea( "WF9" )
			lFound := dbSeek( xFilial( "WF9" ) + WF8->WF8_CODIGO + WF1->WF1_COD )
			AAdd( aBrowser[ Len( aBrowser ),3 ], { lFound, WF1->WF1_COD, WF1->WF1_DESCR } )
			dbSelectArea( "WF1" )
			dbSkip()
		end
		
		dbSelectArea( "WF8" )
		dbSkip()
	end
	
	oChkBtn	 := LoadBitmap( GetResource(), "WFCHK" )
	oUnChkBtn := LoadBitmap( GetResource(), "WFUNCHK" )
	
	DEFINE DIALOG oDlg TITLE "Usuario x Fluxo" FROM 8,0 TO 35,70
	
	@ 15,05 GROUP oGroup1 TO 105,275 LABEL " Fluxo: " PIXEL OF oDlg
	@ 25,10 LISTBOX oBrowser1 ;
		FIELDS	"" ;
		HEADER	WFX3Title( "WF8_CODIGO" ),;
					WFX3Title( "WF8_DESCR" ) ;
		ON CHANGE ( oBrowser2:SetArray( aBrowser[ oBrowser1:nAt,3 ] ), oBrowser2:bLine := bLine2, oBrowser2:Refresh() );
		SIZE 260,75 OF oDlg PIXEL

	bLine1 := { || { aBrowser[ oBrowser1:nAt,1 ], aBrowser[ oBrowser1:nAt,2 ] } }
		
	oBrowser1:SetArray( aBrowser )
	oBrowser1:bLine := bLine1

	@ 110,05 GROUP oGroup2 TO 200,275 LABEL " Processos: " PIXEL OF oDlg
	@ 120,10 LISTBOX oBrowser2 ;
		FIELDS	"" ;
		HEADER	" ",;
					WFX3Title( "WF1_COD" ),;
					WFX3Title( "WF1_DESCR" ) ;
		ON DBLCLICK ( aBrowser[ oBrowser1:nAt,3,oBrowser2:nAt,1 ] := if( aBrowser[ oBrowser1:nAt,3,oBrowser2:nAt,1 ],.f.,.t. ) );
		SIZE 260,75 OF oDlg PIXEL

	oBrowser2:SetArray( aBrowser[ 1,3 ] )

	bLine2 := {|| { ;
		if( aBrowser[ oBrowser1:nAt,3,oBrowser2:nAt,1 ], oChkBtn, oUnChkBtn ),;
		aBrowser[ oBrowser1:nAt,3,oBrowser2:nAt,2 ], aBrowser[ oBrowser1:nAt,3,oBrowser2:nAt,3 ] } }
		
	oBrowser2:bLine := bLine2

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( EnchoiceBar( oDlg, { || lOk := .t., oDlg:End() }, { || oDlg:End() } ) )
	
	dbSelectArea( "WF9" )

	if lOk
		for nC1 := 1 to len( aBrowser )
			aItems := aBrowser[ nC1,3 ]
			for nC2 := 1 to Len( aItems )
				cFindKey := xFilial( "WF9" ) + aBrowser[ nC1,1 ] + aItems[ nC2,2 ]
				if dbSeek( cFindKey )
					if RecLock( "WF9", .f. )
						if aItems[ nC2,1 ]
							WF9_FLUXO := aBrowser[ nC1,1 ]
							WF9_PROC  := aItems[ nC2,2 ]
						else
							dbDelete()
						end
						MsUnLock()
					end
				else
					if aItems[ nC2,1 ]
						if RecLock( "WF9", .t. )
							WF9_FILIAL := xFilial( "WF9" )
							WF9_FLUXO  := aBrowser[ nC1,1 ]
							WF9_PROC   := aItems[ nC2,2 ]
							MsUnLock()
						end
					end
				end
			next
		next
	end
	
   dbSelectArea("WFB")
	dbCloseArea()
return


