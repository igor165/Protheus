#INCLUDE "WFC001.CH"
#INCLUDE "OLECONT.CH"
#include "DbTree.ch"
#include "SIGAWF.ch"
#INCLUDE "APVISIO.CH"
    
/******************************************************************************
	WFC001
	Rastreabilidade de processos do workflow
	Esta funcao eh chamada a partir da janela de cadastro de processos (WFA001)
******************************************************************************/
Function WFC001( nOption, uParam2, uParam3, uParam4 )
	Local oDlg      	:= Nil
	Local oShape    	:= Nil
	Local cCaption  	:= ""
	Local cFileName 	:= ""
	Local nC        	:= 0
	Local nWidth 		:= 1024
	Local nHeight		:= 768
	
	Default nOption := 0

	Do case
		Case ( nOption == 0 )
			PUBLIC oVisioTracking := TWFVisioTracking():New( uParam2, uParam3 )
			oVisioTracking:ShowDlg()
			oVisioTracking:Free()
			
		Case ( nOption == 1 )
			Default uParam2 := Space( 6 )
			Default uParam3 := Space( WF_PROC_ID_LEN )

			PRIVATE oOle, oVisioApp, oTimer
			
			ChkFile("WFC")
			dbSelectArea("WFC")
			dbSetOrder(1)

			ChkFile("WFD")
			dbSelectArea("WFD")
			dbSetOrder(1)

			dbSelectArea("WF1")
			dbSetOrder(1)

			dbSeek( xFilial("WF1") + uParam2 )
			
			if empty( cFileName := lower( AllTrim( WF1->WF1_VISIO ) ) )
				MsgAlert(STR0026) //"O arquivo documento visio nao foi especificado."
				return
			endif				
			
			if !file( cFileName )
				MsgAlert(STR0027 + cFileName + STR0028 ) //"O arquivo documento visio "###" nao foi encontrado."
				return
			endif
			
			cCaption := AllTrim( WF1_DESCR ) + " - " + Upper( cFileName )

			if oMainWnd <> Nil
				if oMainWnd:nClientWidth > 800
					nHeight := 768
					nWidth := 1024
				elseif oMainWnd:nClientWidth > 640
					nHeight := 600
					nWidth := 800
				endif
			endif
			
			DEFINE MSDIALOG oDlg FROM 0,0 TO nHeight,nWidth TITLE cCaption PIXEL
			
			if SetMDIChild()
				oDlg:lMaximized := .t.
			endif

			do case
				case nWidth == 640
					@ 13, 0 OLECONTAINER oOle SIZE (nWidth - 300), (nHeight - 210) OF oDlg AUTOACTIVATE 
				case nWidth == 800
					@ 13, 0 OLECONTAINER oOle SIZE (nWidth - 400), (nHeight - 310) OF oDlg AUTOACTIVATE 
				case nWidth == 1024
					@ 13, 0 OLECONTAINER oOle SIZE (nWidth - 500), (nHeight - 410) OF oDlg AUTOACTIVATE 
			end
			
			DEFINE TIMER oTimer INTERVAL 1000 ACTION WFC001( 3 ) OF oDlg
			
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( WFC001( 2, uParam2, uParam3, cFileName ), oTimer:Activate(), EnchoiceBar( oDlg, {|| oDlg:End() }, {|| oDlg:End()} ) )
			
			oVisioApp:Release()
	                  
		Case ( nOption == 2 )
			oOle:OpenFromFile( uParam4, .f., .t. )
			oOle:DoVerbDefault()
			oVisioApp := TWFVisioApp():New( uParam2, uParam3, "OnCellChg2" )
			oVisioApp:OpenDocument( 1 )
			oVisioApp:LoadWFC()
			oVisioApp:oShapes:lPaintShapes := .t.

		Case ( nOption == 3 )
			oVisioApp:oShapes:PaintShapes()
			oShape := oVisioApp:oShapes:GetFocusShape()

			if oShape <> nil
				oTimer:DeActivate()
				oShape:Execute()
				oVisioApp:oShapes:SetFocusShape(nil)
				oTimer:Activate()
			endif
	endcase
return

Function OnCellChg2( nEvent, nEventID, nEventSeq, cInfo, cSubject )
	local oShape        := Nil
	local nShapeID 		:= 0
	local cShapeID 		:= "/SHAPE=SHEET."

	Default nEvent 		:= 0
	Default nEventID 	:= 0
	Default nEventSeq 	:= 0
	Default cInfo 		:= ""
	Default cSubject 	:= Space( 50 )

	if ( nPos := at( cShapeID, upper( cInfo ) ) ) > 0
		cShapeID 	:= Substr( cInfo, nPos + len( cShapeID ) )
		cShapeID 	:= left( cShapeID, at( " ", cShapeID ) -1 )
		nShapeID 	:= val( cShapeID )
		oShape		:= oVisioApp:oShapes:FindItem( nShapeID )
		oVisioApp:oShapes:SetFocusShape( oShape )
	endif
return
	

/******************************************************************************
	CLASS TWFVisioTracking
	Rastreabilidade de processos do workflow
 ******************************************************************************/
class TWFVisioTracking
	data oTreeView
	data nTreeViewCount
	data nTaskCount
	data oRadioButtons
	data nRadioButton
	data oVisio
	data oFolder
	data oBrowser
	data oProcFinish
	data oTaskFinish
	data oEditProcessID
	data cEditProcessID
	data cComboboxSXB
	data cF3Key
	data cIndexFile
	data cIndexKey
	data cProcessCode
	data aF3Alias
	data aBrowser

	method New( cProcCode, cProcessID ) CONSTRUCTOR
	method ShowDlg()
	method OnChange()
	method OnTabChange( nTab )
	method OnComboChange()
	method OnTreeChange()
	method RefreshTreeView()
	method OpenF3Alias( cF3 )
	method LoadData()
	method Refresh()
	method ProcFinish()
	method TaskFinish()
	method CallVisio()
	method Free()
endclass

/******************************************************************************
 New()
 Inicializador da classe TTrackForm
******************************************************************************/
method New( cProcCode, cProcessID ) class TWFVisioTracking
	Default cProcCode 	:= Space(6)
	Default cProcessID 	:= Space( WF_PROC_ID_LEN )
		
	::cProcessCode 	:= Left( cProcCode + Space( 6 ), 6 )
	cProcessID 		:= Left( cProcessID + Space( WF_PROC_ID_LEN ), WF_PROC_ID_LEN )
	
	ChkFile("WF1")
	dbSelectArea("WF1")
	dbSetOrder( 1 )
	dbSeek( xFilial("WF1") + ::cProcessCode )

	ChkFile("WF2")
	ChkFile("WF3")
	ChkFile("WFC")
	ChkFile("WFD")
	
	::aF3Alias 			:= {}
	::aBrowser 			:= {}
	::cEditProcessID 	:= PadR(cProcessID,8)
	::cComboboxSXB 		:= ""
	::nRadioButton 		:= 2
	
	DbSelectArea( "WF3" )
	DbSetOrder( 4 )

	::cIndexFile 	:= CriaTrab( nil, .F. )
	::cIndexKey 	:= IndexKey( 4 )
return

/******************************************************************************
 ShowDlg()
 Mostra a janela de rastreabilidade
******************************************************************************/
method ShowDlg() class TWFVisioTracking
	Local lVisio 		:= .F.
	Local cTViewRoot    := ""
	Local oDlg          := Nil 
	Local oSelf 		:= Self
	Local oGroup        := Nil
	Local oComboboxSXB  := Nil
	Local nC            := 1
	Local nPos          := 1
	Local nFolder 		:= 1
	Local nCol 			:= 15
	Local aFolders 		:= {}
	Local aRadioButtons := {}
	Local aSXB 			:= SeleF3()
	Local aCmdBar 		:= {}

	if WF1->( Found() )
		if !empty( ::cF3Key := AllTrim( WF1->WF1_SXB ) )
			if ( nPos := At( "-", ::cF3Key ) ) > 0
				::cF3Key := Left( AllTrim( Left( ::cF3Key, nPos - 1 ) ) + Space( 6 ), 6 )
			endif
			
			if ( nPos := AScan( aSXB, { |x| Left( x, len( ::cF3Key ) ) == ::cF3Key } ) ) > 0
				::cComboboxSXB := aSXB[ nPos ]
			endif
		endif
	endif
	
	if Empty( ::cF3Key )
		::cF3Key := "XXXXXX"
	endif

	//-------------------------------------------------------
	// Monta o Formulário de Rastreabilidade.
	//-------------------------------------------------------
	
	AAdd( aFolders, STR0017 ) //"Processos"
	AAdd( aFolders, STR0018 ) //"Historico de ocorrencias"

	AAdd( aRadioButtons, STR0009 ) //"Somente Status do Sistema"
	AAdd( aRadioButtons, STR0010 ) //"Somente Status do Usuário"
	AAdd( aRadioButtons, STR0011 ) //"Todos Status"
	
	DEFINE MSDIALOG oDlg FROM 0,0 TO 550,700 TITLE STR0029 PIXEL //"Rastreabilidade"

	@  35, 05 GROUP oGroup TO 78,210 LABEL STR0020 PIXEL OF oDlg //" Localizar: "
	
	@  45, 15 SAY WFX3Title( "WF1_SXB" ) COLOR CLR_BLUE PIXEL OF oDlg 
	@  45, 50 COMBOBOX oComboboxSXB VAR ::cComboboxSXB ITEMS aSXB PIXEL SIZE 110,10 OF oDlg ;
			ON CHANGE oSelf:OnComboChange()

	@  58, 15 SAY STR0021 COLOR CLR_BLUE PIXEL OF oDlg //"Processo:"
	@  58, 50 MSGET ::oEditProcessID VAR ::cEditProcessID F3 ::cF3Key PIXEL SIZE 50, 10 OF oDlg;
			VALID oSelf:OnChange()

	@  40,220 Radio ::oRadioButtons VAR ::nRadioButton ITEMS aRadioButtons[1], aRadioButtons[2], aRadioButtons[3] 3D ;
			ON CHANGE ::OnChange() SIZE 100,10 OF oDlg PIXEL

	::OnTabChange(1)

	@ 80, 05 FOLDER ::oFolder ITEMS aFolders[1], aFolders[2] OPTION nFolder SIZE 340, 160 OF oDlg PIXEL
		
	::oFolder:bSetOption := { |nTab| ::OnTabChange( nTab ) }
	::nTreeViewCount := 0

	DEFINE DBTREE ::oTreeView FROM 05, 05 TO 140, 325 OF ::oFolder:aDialogs[ nFolder ] PIXEL CARGO ON CHANGE ::OnTreeChange()

	if !Empty( cTViewRoot := ::cComboboxSXB )
		if ( nPos := At( "-", cTViewRoot ) ) > 0
			cTViewRoot := SubStr( cTViewRoot, nPos + 1 )
		endif
		cTViewRoot := AllTrim( cTViewRoot ) 
	endif

	cTViewRoot := pad( cTViewRoot, WF_KEY_PROC_LEN )
	nFolder++

	@ 05, 05 LISTBOX ::oBrowser ;
		FIELDS "" ;
		HEADER WFX3Title("WF3_STATUS"), WFX3Title("WF3_DESC"), WFX3Title("WF3_DATA"), WFX3Title("WF3_HORA"), WFX3Title("WF3_USU");
		SIZE 325, 130 ;
		OF ::oFolder:aDialogs[ nFolder ] PIXEL

	if ( lVisio := ( WF1->(FieldPos("WF1_VISIO") ) > 0 ) )
		if ( lVisio := ApOleClient("MSVISIO") )
			AAdd( aCmdBar, { "MSVISIO", {|| oSelf:CallVisio() }, "Microsoft Visio", "Visio" } )
		endif
	endif

	@ 245,05 BUTTON ::oProcFinish PROMPT STR0030 SIZE 60,15 OF oDlg PIXEL ACTION oSelf:ProcFinish() //"Finaliza Processo"
	::oProcFinish:SetDisable()
	@ 245,70 BUTTON ::oTaskFinish PROMPT STR0031 SIZE 60,15 OF oDlg PIXEL ACTION oSelf:TaskFinish() //"Finaliza Tarefa"
	::oTaskFinish:SetDisable()

	::LoadData()
	::Refresh()

	if lVisio
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( oSelf:Refresh(), oSelf:oEditProcessID:SetFocus(), EnchoiceBar( oDlg, {|| oDlg:End() },{|| oDlg:End()},, aCmdBar ) ) 
	else
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( oSelf:Refresh(), oSelf:oEditProcessID:SetFocus(), EnchoiceBar( oDlg, {|| oDlg:End() },{|| oDlg:End()} ) ) 
	endif
return

method CallVisio() class TWFVisioTracking
	if empty( ::cProcessCode )
		dbSelectArea("WF3")
		dbSetOrder(1)
		if dbSeek( xFilial("WF3") + pad(::cEditProcessID + ".00", WF_KEY_PROC_LEN) )
			::cProcessCode := WF3->WF3_PROC
		endif
	endif
	WFC001(1, ::cProcessCode, ::cEditProcessID )
return

/******************************************************************************
 OnTreeChange()
 Este evento sera executado 
******************************************************************************/
method OnTreeChange() class TWFVisioTracking
	Local cFindKey	:= ""
	Local cAux 		:= ""
	Local nPos 		:= 0

	If ! ( Empty( cFindKey := ::oTreeView:GetCargo() ) )
		nPos := AT('.', cFindKey)
		If nPos > 0
			cAux := Subs(cFindKey, nPos + 1)
		Else
			cAux := cFindKey 		
		EndIf
		cFindKey := xFilial("WF3") + Padr(::cEditProcessID + "." + left( cAux, 2 ), WF_KEY_PROC_LEN) + strZero( EV_FINISH, 6 ) 
		
		dbSelectArea( "WF3" )
		dbSetOrder(1)
		if dbSeek( cFindKey )
			::oTaskFinish:SetDisable()
		else
			::oTaskFinish:SetEnable()
		endif
	endif
return .t.

/******************************************************************************
 OnChange()
 Este evento sera executado 
******************************************************************************/
method OnChange() class TWFVisioTracking
	::LoadData()
	::Refresh()
return .t.

/******************************************************************************
 OnComboChange()
******************************************************************************/
method OnComboChange() class TWFVisioTracking
	::oEditProcessID:cF3 := Subs( ::cComboboxSXB, 1, 6 )
	::OpenF3Alias( Subs( ::cComboboxSXB, 1, 6 ) )
	::cEditProcessID := Space( WF_PROC_ID_LEN )
	::OnChange()
return

/******************************************************************************
 OnTabChange()
 Atualiza a arvore (tree) dos eventos ocorrido pelo processo informado
 na variavel cFindKey
******************************************************************************/
method OnTabChange( nTab ) class TWFVisioTracking
	local aUsrGroups

	PswOrder(1)

	if PswSeek( __cUserId )
		aUsrGroups := PswRet()[1][10]
		if Ascan( aUsrGroups, "000000" ) > 0
			if nTab < 3
				::oRadioButtons:SetEnable()
			endif
		endif
	endif
	
	do case
		case nTab == 1 .and. ::oTreeView <> nil
			::oTreeView:SetFocus()
		case nTab == 2
			::oBrowser:SetFocus()
		case nTab == 3
			::oRadioButtons:SetDisable()
	end
return

/******************************************************************************
 Refresh()
******************************************************************************/
method Refresh() class TWFVisioTracking
	Local bLine

	if len( ::aBrowser ) > 0
		bLine := { || { ;
			::aBrowser[ ::oBrowser:nAt, 4 ],;
			::aBrowser[ ::oBrowser:nAt, 9 ],;
			::aBrowser[ ::oBrowser:nAt, 6 ],;
			::aBrowser[ ::oBrowser:nAt, 5 ],;
			::aBrowser[ ::oBrowser:nAt, 7 ] } }
	else
		bLine := { || { "", "", "", "", "" } }
	endif
	
	::oBrowser:SetArray( ::aBrowser )
	::oBrowser:bLine := bLine
	::oBrowser:Refresh()
	::oBrowser:GoTop()
	::oTreeView:TreeSeek("000")    
	::oTreeView:Refresh()
return


/******************************************************************************
 ProcFinish()
******************************************************************************/
method ProcFinish() class TWFVisioTracking
	local nTaskID := 0
	local cLastAlias := Alias(), cMsg, cFindKey, cEvent
	
	dbSelectArea( "WF1" )
	dbSetOrder(1)
	
	If ( dbSeek( xFilial("WF1") + ::cProcessCode ) )
		cMsg := STR0032 //"Deseja finalizar todo o processo "
		cMsg += "(" + ::cEditProcessID + ") "
		cMsg += AllTrim( WF1->WF1_DESCR )
		cMsg += "?"
		
		if MsgYesNo( cMsg, STR0033 ) //"Finalizar Processo"
			dbSelectArea( "WF3" )
			dbSetOrder(1)
	
			while dbSeek( cFindKey := xFilial("WF3") + Padr(::cEditProcessID + "." + StrZero( nTaskID, 2 ), WF_KEY_PROC_LEN))
				if !dbSeek( cFindKey + StrZero( EV_FINISH, 6 ) )
					cEvent := WFLogEvent( EV_FINISH, "", asString( ::cEditProcessID ), asString( StrZero( nTaskID, 2 ) ) )
					if RecLock( "WF3",.T. )
						WF3_FILIAL	:= xFilial( "WF3" )
						WF3_ID			:= Lower ( ::cEditProcessID + "." + AsString( StrZero( nTaskID, 2 ) ) )
						WF3_PROC		:= ::cProcessCode
						WF3_STATUS		:= strZero( EV_FINISH, 6 )
						WF3_HORA		:= time()
						WF3_DATA		:= msdate()
						WF3_DESC		:= cEvent
						MSUnlock("WF3")
					endif
				endif
				nTaskID++
			end
		
			::OnChange()
			MsgAlert( STR0034 ) //"Processo finalizado com sucesso!"
		endif
	Else	
	 	MsgAlert( STR0040 + cBIStr( ::cProcessCode ) + STR0041 ) // "Código "###" não encontrado no cadastro de processos do workflow"  
	endif
	
	If ! ( Empty( cLastAlias ) )
		dbSelectArea( cLastAlias )
	endif
return

/******************************************************************************
 TaskFinish()
******************************************************************************/
method TaskFinish() class TWFVisioTracking
	Local cMsg		:= ""
	Local cEvent	:= ""
	Local cCargo	:= ::oTreeView:GetCargo()
	Local cTaskID 	:= ""
	Local nPos 		:= 0

	nPos := AT('.', cCargo)
	If nPos > 0
		cTaskID := Subs(cCargo, nPos + 1, 2)
	Else
		cTaskID := Left( cCargo, 2)
	EndIf	

	cFindKey 	:= Lower( xFilial("WF3") + Padr(::cEditProcessID + "." + cTaskID, WF_KEY_PROC_LEN ) + StrZero( EV_FINISH, 6 ) )
	
	dbSelectArea( "WF3" )
	dbSetOrder(1)
	If ! dbSeek( cFindKey )
		cMsg := STR0035 //"Deseja finalizar a tarefa"
		cMsg += " [" + cTaskID + "]?"

		if MsgYesNo( cMsg, STR0036 ) //"Finalizar Tarefa"
			cEvent := WFLogEvent( EV_FINISH, "", asString( ::cEditProcessID ), cTaskID )
			if RecLock( "WF3", .T. )
				WF3_FILIAL		:= xFilial( "WF3" )
				WF3_ID			:= Lower( ::cEditProcessID + "." + cTaskID )
				WF3_PROC		:= ::cProcessCode
				WF3_STATUS		:= strZero( EV_FINISH, 6 )
				WF3_HORA		:= time()
				WF3_DATA		:= msdate()
				WF3_DESC		:= cEvent
				MSUnlock("WF3")
			endif
		
			::OnChange()
			MsgAlert( STR0037 ) //"Tarefa finalizado com sucesso!"
		endif
	endif
return

/******************************************************************************
 LoadData()
******************************************************************************/
method LoadData() class TWFVisioTracking
	Local nC			:= 0
	Local nRecno		:= 0
	Local aReg			:= {}
	Local cTViewRoot	:= ""
	Local cTaskID		:= ""
	Local cItem			:= ""
	Local cFindKey		:= ""

	::oTreeView:Reset()
	
	if ! ( Empty( cTViewRoot := ::cComboboxSXB ) )
		if ( nPos := At( "-", cTViewRoot ) ) > 0
			cTViewRoot := AllTrim( SubStr( cTViewRoot, nPos + 1 ) )
		endif
		cTViewRoot := AllTrim( cTViewRoot ) 
	endif

	cTViewRoot := pad( cTViewRoot, WF_KEY_PROC_LEN )	
	::nTreeViewCount := 0
	::nTaskCount := 0
	::aBrowser := {}

	cFindKey := rtrim(xFilial("WF3") + ::cEditProcessID) 
	
	dbSelectArea("WF3")
	dbSetOrder(4)

	if ! ( dbSeek( cFindKey ) )
		dbSeek( cFindKey := Lower( cFindKey ) )
	endif
		
	if ( Found() )		
		If ( Empty( ::cProcessCode ) )
			::cProcessCode := WF3->WF3_PROC
		endif

		::oProcFinish:SetEnable()
		::oTaskFinish:SetEnable()

		do while !eof() .and. ( WF3_FILIAL +  Left( WF3_ID,WF_PROC_ID_LEN) == cFindKey )
			if ( ( ::nRadioButton == 1 ) .and. ( val( WF3_STATUS ) < 1000 ) ) .or. ;
					( ( ::nRadioButton == 2 ) .and. ( val( WF3_STATUS ) >= 1000 ) ) .or. ( ::nRadioButton == 3 )
				
				aReg := {}
				
				for nC := 1 to len( dbStruct() )
					AAdd( aReg, FieldGet( nC ) )
				next
				
				AAdd( ::aBrowser, aReg )
				if cTaskID <> AllTrim( WF3_ID )
					if !Empty( cTaskID )
						DBENDTREE ::oTreeView
					endif
					cTaskID := AllTrim(  WF3_ID )
					::nTreeViewCount++
					
					cItem := PaDR( FormatStr( STR0024, { cTaskID, WF3_DATA, Left( WF3_HORA, 5 ) } ), 80 ) //"Tarefa [%c] Iniciada em %d as %c"
					nRecNo := WF3->( RecNo() )
			      	
			      	dbSetOrder(2)
			      	if dbSeek( xFilial("WF3") + ::cProcessCode + Padr(cTaskID, WF_KEY_PROC_LEN) + strZero( EV_FINISH, 6) )
						cItem += "("
						cItem += STR0042 //"Finalizado"
						cItem += ")"
			      	else
						cItem += "("
						cItem += STR0039  //"Pendente"
						cItem += ")"
			      	endif
			      	
			      	dbSetOrder(4)
			      	dbGoTo( nRecNo )
					DBADDTREE ::oTreeView PROMPT Padr(cItem, 95) RESOURCE "FOLDER5","FOLDER6" CARGO cTaskID + StrZero( ::nTreeViewCount, 3) OPENED
				endif
		      	::nTreeViewCount++
		      	
		      	cItem := PaDR( FormatStr( STR0025, { AllTrim( WF3_DESC ), WF3_DATA, Left( WF3_HORA, 5 ) } ), 80 ) //"%c em %d as %c"
   		   		
   		   		DBADDITEM ::oTreeView PROMPT cItem CARGO cTaskID + StrZero( ::nTreeViewCount, 3) 
			endif
			dbSkip()
		end
		
		if ( ::nTreeViewCount > 0 )
			DBENDTREE ::oTreeView
		endif
	else
		::oProcFinish:SetDisable()
		::oTaskFinish:SetDisable()
		for nC := 1 to len( dbStruct() )
			AAdd( aReg, FieldGet( nC ) )
		next
		AAdd( ::aBrowser, aReg )
	endif
return

/******************************************************************************
 OpenF3Alias()
******************************************************************************/
method OpenF3Alias( cF3 ) class TWFVisioTracking
	local cLastAlias := Alias()

	dbSelectArea("SXB")
	dbSetOrder(1)  

	if dbSeek( cF3 + "1" )
		if Ascan( ::aF3Alias, XB_ALIAS ) == 0
			AAdd( ::aF3Alias, left(AllTrim( XB_CONTEM ), 3) )
		endif
	endif

	if !empty( cLastAlias )
		dbSelectArea( cLastAlias )
	endif
Return

method Free() class TWFVisioTracking
	DbSelectArea( "WF1" )
	DbCloseArea()
	DbSelectArea( "WF2" )
	DbCloseArea()
	DbSelectArea( "WF3" )
	DbCloseArea()
return 