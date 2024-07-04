#INCLUDE "Wfc001.ch"
#include "SIGAWF.ch"
#INCLUDE "OLECONT.CH"


/******************************************************************************
	WFC004
	Template Visio de processos
	Esta funcao eh chamada a partir da janela de cadastro de processos (WFA001)
 ******************************************************************************/
Function WFC004( nOption, uParam2, uParam3 )
	Local nC, nWidth := 1024,  nHeight := 768
	Local oDlg
	Local cCaption, cFileName
	
	default nOption := 0

	do case
		case nOption == 0
			default uParam2 := "", uParam3 := Space( 5 )

			PRIVATE oOle, oTemplate, oTimer, __oWFShape
			
			ChkFile("WFC")
			dbSelectArea("WFC")
			dbSetOrder(1)

			dbSelectArea("WF1")
			dbSetOrder(1)
			
			dbSeek( xFilial("WF1") + uParam2 )
			
			if !file( cFileName := lower( AllTrim( WF1_VISIO ) ) )
				return
			end
			
		   cCaption := AllTrim( WF1_DESCR ) + " - " + Upper( cFileName )

			if oMainWnd <> Nil
				if oMainWnd:nClientWidth > 800
					nHeight := 768
					nWidth := 1024
				elseif oMainWnd:nClientWidth > 640
					nHeight := 600
					nWidth := 800
				end
			end
			
			DEFINE MSDIALOG oDlg FROM 0,0 TO nHeight,nWidth TITLE cCaption PIXEL
			
			if SetMDIChild()
				oDlg:lMaximized := .t.
			end

			do case
				case nWidth == 640
					@ 13, 0 OLECONTAINER oOle SIZE (nWidth -300), (nHeight -210) OF oDlg AUTOACTIVATE 
				case nWidth == 800
					@ 13, 0 OLECONTAINER oOle SIZE (nWidth -400), (nHeight -310) OF oDlg AUTOACTIVATE 
				case nWidth == 1024
					@ 13, 0 OLECONTAINER oOle SIZE (nWidth -500), (nHeight -410) OF oDlg AUTOACTIVATE 
			end
			
			DEFINE TIMER oTimer INTERVAL 1000 ACTION WFC004( 3 ) OF oDlg
			
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( WFC004( 1, uParam2, cFileName ), oTimer:Activate(), EnchoiceBar( oDlg, {|| WFC004( 2 ), oDlg:End() },{|| oDlg:End()} ) )
			
			oTemplate:Release()
	                  
			dbSelectArea( "WFC" )
			dbCloseArea()

		case nOption == 1
			oOle:OpenFromFile( uParam3, .f., .t. )
			oOle:DoVerbDefault()
			oTemplate := TWFVisioApp():New()
			oTemplate:SetProcCode( uParam2 )
			oTemplate:SetCellChange( "OnCellChg1" ) 
			oTemplate:OpenDocument( 1 )
			oTemplate:LoadWFC()

		case nOption == 2
			oTemplate:SaveWFC()
			
		case nOption == 3
			if __oWFShape <> nil
				oTimer:DeActivate()
				__oWFShape:Properties()
				__oWFShape := nil
				oTimer:Activate()
			end

	endcase
	
return


Function OnCellChg1( nEvent, nEventID, nEventSeq, cInfo, cSubject )
	local nShapeID := 0
	local cShapeID := "/SHAPE=SHEET."
	
	default nEvent := 0, nEventID := 0, nEventSeq := 0
	default cInfo := "", cSubject := Space( 50 )
	if ( nPos := at( cShapeID, upper( cInfo ) ) ) > 0
		cShapeID := Substr( cInfo, nPos + len( cShapeID ) )
		cShapeID := left( cShapeID, at( " ", cShapeID ) -1 )
		nShapeID := val( cShapeID )
		__oWFShape := oTemplate:oShapes:FindItem( nShapeID ) 
	end
	
return 

