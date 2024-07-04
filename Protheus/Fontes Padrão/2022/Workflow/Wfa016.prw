
#INCLUDE "SIGAWF.CH"

#DEFINE	WF_PROCESSOS	6
#DEFINE	WF_USUARIOS		7

/*
	CADASTRO DE FLUXO x USUARIO
*/
FUNCTION WFA016()
	Local cFindKey
	Local nC1, nC2, nPos
	Local lOk := .f.
	Local bLine1, bLine2
	Local aBrowser := {}, aItems, aAllUsers, aAllGroups, aGroups
	Local oDlg, oBrowser1, oBrowser2, oGroup1, oGroup2, oChkBtn, oUnChkBtn
	
	aAllUsers	:= wfAllUsers( .T. )
	aAllGroups	:= wfAllGroups( .T. )
	
	ChkFile( "WF8" )
	dbSelectArea( "WF8" )
	dbGoTop()
	
	if Eof()
		MsgAlert( "Nao ha fluxos cadastrados." )
		return
	end

	ChkFile( "WFB" )
	
	for nC1 := 1 to len( aAllUsers )
		nPos := 0

		if Len( aGroups := aAllUsers[ nC1,1,10 ] ) > 0
			
			for nC2 := 1 to Len( aGroups )
				
				if ( nPos := AScan( aAllGroups, { |x| x[ 1,1 ] == aGroups[ nC2 ] } ) ) > 0
					aItems := { aAllUsers[ nC1,1,2 ], Left( aAllGroups[ nPos,1,2 ] + Space( 20 ),20 ), aAllUsers[ nC1,1,4 ], aAllUsers[ nC1,1,14 ], aAllUsers[ nC1,1,13 ], aAllUsers[ nC1,1,12 ], {} } 
					nC2 := Len( aGroups )
				end
				
			next
			
		end
			
		if Len( aGroups ) == 0 .or. nPos == 0
			aItems := { aAllUsers[ nC1,1,2 ], Left( "Sem Grupo" + Space( 20 ),20 ), aAllUsers[ nC1,1,4 ], aAllUsers[ nC1,1,14 ], aAllUsers[ nC1,1,13 ], aAllUsers[ nC1,1,12 ], {} } 
		end
		
		dbSelectArea( "WF8" )
		cFindKey := xFilial( "WF8" )
		dbSeek( cFindKey )
 		
		while !Eof() .and. ( WF8_FILIAL == cFindKey )
			dbSelectArea( "WFB" )
			conout("WFB="+xFilial( "WFB" ) + Left( aAllUsers[ nC1,1,2 ] + Space( 15 ),15 ) + WF8->WF8_CODIGO)
			lFound := dbSeek( xFilial( "WFB" ) + Left( aAllUsers[ nC1,1,2 ] + Space( 15 ),15 ) + WF8->WF8_CODIGO )
			dbSelectArea( "WF8" )
			AAdd( aItems[ 7 ], { lFound, WF8_CODIGO, WF8_DESCR } )
			dbSkip()
		end
		
		AAdd( aBrowser, aItems )
	next
	
	oChkBtn	 := LoadBitmap( GetResource(), "WFCHK" )
	oUnChkBtn := LoadBitmap( GetResource(), "WFUNCHK" )
	
	DEFINE DIALOG oDlg TITLE "Usuario x Fluxo" FROM 8,0 TO 35,70
	
	@ 15,05 GROUP oGroup1 TO 105,275 LABEL " Usuarios: " PIXEL OF oDlg
	@ 25,10 LISTBOX oBrowser1 ;
		FIELDS	"" ;
		HEADER	"Usuario",;
					"Grupo",;
					"Nome",;
					"Endereco eletronico",;
					"Cargo",;
					"Departamento",;
		ON CHANGE ( oBrowser2:SetArray( aBrowser[ oBrowser1:nAt,7 ] ), oBrowser2:bLine := bLine2, oBrowser2:Refresh() );
		SIZE 260,75 OF oDlg PIXEL

	bLine1 := { || { ;
		aBrowser[ oBrowser1:nAt,1 ], aBrowser[ oBrowser1:nAt,2 ], aBrowser[ oBrowser1:nAt,3 ],;
		aBrowser[ oBrowser1:nAt,4 ], aBrowser[ oBrowser1:nAt,5 ], aBrowser[ oBrowser1:nAt,6 ] } }
		
	oBrowser1:SetArray( aBrowser )
	oBrowser1:bLine := bLine1

	@ 110,05 GROUP oGroup2 TO 200,275 LABEL " Fluxos: " PIXEL OF oDlg
	@ 120,10 LISTBOX oBrowser2 ;
		FIELDS	"" ;
		HEADER	" ",;
					WFX3Title( "WF8_CODIGO" ),;
					WFX3Title( "WF8_DESCR" ) ;
		ON DBLCLICK ( aBrowser[ oBrowser1:nAt,7,oBrowser2:nAt,1 ] := if( aBrowser[ oBrowser1:nAt,7,oBrowser2:nAt,1 ],.f.,.t. ) );
		SIZE 260,75 OF oDlg PIXEL

	oBrowser2:SetArray( aBrowser[ 1,7 ] )

	bLine2 := {|| { ;
		if( aBrowser[ oBrowser1:nAt,7,oBrowser2:nAt,1 ], oChkBtn, oUnChkBtn ),;
		aBrowser[ oBrowser1:nAt,7,oBrowser2:nAt,2 ], aBrowser[ oBrowser1:nAt,7,oBrowser2:nAt,3 ] } }
		
	oBrowser2:bLine := bLine2

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( EnchoiceBar( oDlg, { || lOk := .t., oDlg:End() }, { || oDlg:End() } ) )
	
	dbSelectArea( "WFB" )

	if lOk
		for nC1 := 1 to len( aBrowser )
			aItems := aBrowser[ nC1,7 ]
			for nC2 := 1 to Len( aItems )
				cFindKey := xFilial( "WFB" ) + aBrowser[ nC1,1 ] + aItems[ nC2,2 ] 
				if dbSeek( cFindKey )
					if RecLock( "WFB", .f. )
						if aItems[ nC2,1 ]
							WFB_CODUSU := Upper( aBrowser[ nC1,1 ] )
							WFB_FLUXO  := aItems[ nC2,2 ]
						else
							dbDelete()
						end
						MsUnLock()
					end
				else
					if aItems[ nC2,1 ]
						if RecLock( "WFB", .t. )
							WFB_FILIAL := xFilial( "WFB" )
							WFB_CODUSU := Upper( aBrowser[ nC1,1 ] )
							WFB_FLUXO  := aItems[ nC2,2 ]
							MsUnLock()
						end
					end
				end
			next
		next
	end
	
	dbSelectArea( "WF8" )
	dbCloseArea()
return


