#INCLUDE "WFTSKMSG.ch"
#INCLUDE "COLORS.CH"
#Include "SIGAWF.CH"

#define	MSG_INBOX	"1"
#define	MSG_READ	"2"
#define	MSG_SENT	"4"

STATIC __oTaskMsg

function WFTaskMsg( oTaskDlg, nOpc, cFileText )
	default nOpc := 0
	do case
		case nOpc == 0
			__oTaskMsg := TWFTaskMsg():New( oTaskDlg )
		case nOpc == 1
			__oTaskMsg:HistoryDlg()
		case nOpc == 2
			__oTaskMsg:OpenMsgDlg( cFileText )
		case nOpc == 3
			__oTaskMsg:Remove()
		case nOpc == 4
			__oTaskMsg:NewMsgDlg()
	end
return

class TWFTaskMsg
	data oTaskDlg
	data oBrowser
	data aBrowser
	data aPriorityList
	data lRefresh

	method New( oTaskDlg ) CONSTRUCTOR
	method HistoryDlg()
	method OpenMsgDlg( cFileText )
	method NewMsgDlg( cFileText, lReply, lForward )
	method Remove()
	method GetFileText(nRecno)
	method GetLine( nLin, nCol )
	method GetUserList( cUserList )
	method SendMsg( cUserList, cSubject, cBuffer, cPriority, cIdent )
	method SelectAll( aBrowser, aUserList, lSelect )
	method SelectUser( oBrowser, aBrowser, aUserList )
	method SelectGroup( aUserList ) 
	method Reply( cFileText, oDlg )
	method Forward( cFileText, oDlg )
	method LoadHist()
endclass

method New( oOwner ) class TWFTaskMsg
	Local bBlock := "{ || " 
	
	::oTaskDlg := oOwner
	::lRefresh := .f.
	::aPriorityList := {}	
	AAdd( ::aPriorityList, STR0001 ) //"0-Alta"
	AAdd( ::aPriorityList, STR0002 ) //"1-Normal"
	AAdd( ::aPriorityList, STR0003 ) //"2-Baixa"

	bBlock += "WF6_FILIAL == '" + xFilial("WF6") + "' .and. "
	bBlock += "WF6_PROPRI == '" + Upper( Left( ::oTaskDlg:oTaskMan:cUserName + Space( 15 ),15 ) ) + "' .and. "
	bBlock += "WF6_GRUPO == '00002' .and. "

	::oTaskDlg:AddFolder( STR0004, &( bBlock + "WF6_STATUS $ '13' }" ), "PMSTASK1", "PMSTASK1" ) //"Itens em Aberto"
	::oTaskDlg:AddFolder( STR0005, &( bBlock + "WF6_STATUS == '2' }" ), "PMSTASK4", "PMSTASK4" ) //"Itens Lidos"
	::oTaskDlg:AddFolder( STR0006, &( bBlock + "WF6_STATUS == '4' }" ), "PMSTASK3", "PMSTASK3" ) //"Itens Enviados"
	::oTaskDlg:AddButton( STR0007, { |oTsk| WFTaskMsg( oTsk,1 ) } ) //"Historico"
	::oTaskDlg:AddButton( STR0008, { |oTsk| WFTaskMsg( oTsk,3 ) } ) //"Remover"
	::oTaskDlg:AddButton( STR0009, { |oTsk| WFTaskMsg( oTsk,4 ) } ) //"Nova mensagem"
return

method HistoryDlg() class TWFTaskMsg
	Local bLine
	Local cIdent, cFileText
	Local nC1, nC2
	Local aItems, aBrowser, aAllUsers
	Local oDlg, oFileText, oFont, oMsgHigh, oMsgEmpty
	
	//Posiciona na WF6
	if ValType(::oTaskDlg:nRecnoWF6) == "N" .and. ::oTaskDlg:nRecnoWF6 > 0
		dbSelectArea('WF6')
		WF6->(dbSetOrder(1))
		WF6->(dbGoTo(::oTaskDlg:nRecnoWF6))
	endif
	
	if Eof()
		return
	end

	aAllUsers := AllUsers( .T. )
	oMsgHigh := LoadBitmap( GetResource(), "MSGHIGH" )
	oMsgEmpty := LoadBitmap( GetResource(), "MSGEMPTY" )
	
	aBrowser := {}
	
	if !Empty( cIdent := WF6_IDENT1 )
	
		aBrowser := ::LoadHist()

	end
		
	if Len( aBrowser ) == 0
		aItems := {}
		AAdd( aItems, Space( 1 ) )	// WF6_STATUS 
		AAdd( aItems, CriaVar( "WF6_STATUS" ) )
		AAdd( aItems, CriaVar( "WF6_PRIORI" ) )
		AAdd( aItems, CriaVar( "WF6_DE" ) )
		AAdd( aItems, CriaVar( "WF6_DESCR" ) )
		AAdd( aItems, CriaVar( "WF6_PARA" ) )
		AAdd( aItems, CriaVar( "WF6_DATA" ) )
		AAdd( aItems, CriaVar( "WF6_HORA" ) )
		AAdd( aItems, CriaVar( "WF6_DTVENC" ) )
		AAdd( aItems, CriaVar( "WF6_HRVENC" ) )
		AAdd( aItems, CriaVar( "WF6_IDENT1" ) )
		AAdd( aItems, CriaVar( "WF6_IDENT2" ) )
		AAdd( aItems, 0 )
		AAdd( aItems, 0 )
		AAdd( aBrowser, aItems )
	end

	//aBrowser := ASort( aBrowser,,,{ |x,y| ( x[3] + DToS( x[6] ) + x[8] ) < ( y[3] + DToS( y[6] ) + y[8] ) } )
	DEFINE DIALOG oDlg TITLE STR0010 From 0,0 To 44,142 //"Historico de Mensagens"
	DEFINE FONT oFont NAME "Arial" SIZE 0, -14 BOLD
	
	@ 45,5 LISTBOX oBrowser ;
		FIELDS	" " ;
		HEADER	" ",;
					" ",;
					WFX3Title( "WF6_DE" ),;
					WFX3Title( "WF6_DESCR" ),;
					WFX3Title( "WF6_PARA" ),;
					WFX3Title( "WF6_DATA" ),;
					WFX3Title( "WF6_HORA" ),;
					WFX3Title( "WF6_DTVENC" ),;
					WFX3Title( "WF6_HRVENC" );	
		ON DBLCLICK ::OpenMsgDlg() ;
		ON CHANGE (WF6->(dbGoTo( aBrowser[oBrowser:nAt,10])),::oTaskDlg:nRecnoWF6:= aBrowser[oBrowser:nAt,10] ,cFileText := WFLoadFile( GFileText(::oTaskDlg:nRecnoWF6) ), oFileText:Refresh() );
		SIZE 550,110 OF oDlg PIXEL
        

	
	oBrowser:nFreeze := 2		
	oBrowser:SetArray(aBrowser)
   	bLine := { || { " ", " ",	aBrowser[ oBrowser:nAt,  3 ], aBrowser[ oBrowser:nAt,  4 ], aBrowser[ oBrowser:nAt,  5 ],	aBrowser[ oBrowser:nAt,  6 ], aBrowser[ oBrowser:nAt,  7 ],	aBrowser[ oBrowser:nAt,  8 ], aBrowser[ oBrowser:nAt,  9 ] } }
	oBrowser:bLine := bLine
   
	@ 130,5 GET oFileText VAR cFileText PIXEL MEMO READONLY SIZE 550,195 OF oDlg 
   	oBrowser:GoTop() 

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( EnchoiceBar( oDlg, { || dbGoTo( aBrowser[oBrowser:nAt,10] ), ::OpenMsgDlg() }, { || oDlg:End() } ) )
return

method GetFileText(nRecno) class TWFTaskMsg
	Local cFileText := ""

	
	//Posiciona na WF6
	if ValType(nRecno) == "N" .and. nRecno > 0
		dbSelectArea('WF6')
		WF6->(dbSetOrder(1))
		WF6->(dbGoTo(nRecno))
	endif
		 
	cFileText := StrTran( AllTrim( WF6_ACAO ), "/", "\" )
		
	if ( nPos := At( '"', cFileText ) ) > 0
		cFileText := SubStr( cFileText, nPos +1 )
		
		if ( nPos := At( '"', cFileText ) ) > 0
			cFileText := Left( cFileText, nPos -1 )
		end
			
	end
	
return cFileText

method OpenMsgDlg( cFileText ) class TWFTaskMsg
	Local lResult := .f.
	Local nC, nPos, nRecNo
	Local aCmdBar := {}
	Local oDlg, oSubject, oText, oUserList, oFont, oPriority
	Local cSubject, cPriority, cText, cUserList, cUserName, cCaption

	cUserName := ::oTaskDlg:oTaskMan:cUserName
	
	if cFileText == nil
		cFileText := ::GetFileText()		
	end

	cUserList := WF6_DE
	cSubject  := WF6_DESCR
	cText     := if( File( cFileText ), WFLoadFile( cFileText ), "" )
	cCaption  := STR0011 //"Mensagem"
	cGroup    := ""
	cPriority := ::aPriorityList[ Val( WF6_PRIORI ) +1 ]
	
		
	DEFINE DIALOG oDlg TITLE cCaption FROM 0,0 To  35,72
	DEFINE FONT oFont NAME "Arial" SIZE 0, -12 BOLD

	@  32, 05 SAY STR0012 SIZE 50,10 PIXEL FONT oFont OF oDlg //"Prioridade:"
	@  32, 50 MSCOMBOBOX oPriority VAR cPriority ITEMS ::aPriorityList PIXEL SIZE 50,13 OF oDlg
	@  45, 05 SAY STR0013 SIZE 50,10 PIXEL FONT oFont OF oDlg //"De:"
	@  45, 50 MSGET oUserList VAR cUserList SIZE 230, 10 PIXEL OF oDlg
	@  60, 05 SAY STR0014 SIZE 50,10 PIXEL FONT oFont OF oDlg  //"Assunto:"
	@  60, 50 MSGET oSubject VAR cSubject SIZE 230, 10 PIXEL OF oDlg
	@  75, 05 GET oText VAR cText PIXEL MEMO READONLY SIZE 275,185 OF oDlg 
	
	oUserList:SetDisable()
	oSubject:SetDisable()
	oPriority:SetDisable()
	
	nRecNo := RecNo()

//	if WF6_STATUS <> "4" .and. ( WF6_STATUS <> MSG_READ )
	if WF6_STATUS <> "4"
		AAdd( aCmdBar, { "MSGREPLY", {|| lResult := ::Reply( cFileText ), if( lResult, oDlg:End(), nil ) }, STR0015 } ) //"Responder..."
	end

	AAdd( aCmdBar, { "MSGFORWD", {|| lResult := ::Forward( cFileText ), if( lResult, oDlg:End(), nil ) }, STR0016 } ) //"Encaminhar..."
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( EnchoiceBar( oDlg, { || lResult := .t., oDlg:End() }, { || oDlg:End() },, aCmdBar ) )
	
	if ( WF6_STATUS <> MSG_SENT ) .and. ( WF6_STATUS <> MSG_READ ) .and. lResult
		::lRefresh := .t.
	
		if RecLock( "WF6", .F. )
			WF6_STATUS := MSG_READ
			WF6_DTVISU := MsDate()
			WF6_HRVISU := Left( Time(),5 )
			MSUnlock("WF6")
		end
		
	end
	
	if ::lRefresh
		::lRefresh := .f.
		::oTaskDlg:Refresh()
	end
	
return

method Reply( cFileText ) class TWFTaskMsg
return ::NewMsgDlg( cFileText, .t. )

method Forward( cFileText ) class TWFTaskMsg
return ::NewMsgDlg( cFileText,, .t. )

method NewMsgDlg( cFileText, lReply, lForward ) class TWFTaskMsg
	Local nC
	Local bOkBtn
	Local lResult := .f.
	Local oDlg, oGroup, oSubject, oText, oUserList, oFont, oPriority
	Local cSubject, cPriority, cText, cUserList, cUserName, cCaption, cIdent
	
	default cFileText := "", lReply := .f., lForward := .f.

	cUserName := ::oTaskDlg:oTaskMan:cUserName
	
	if !Empty( cFileText )
		cUserList := WF6_DE
		if lReply
	  	  cSubject  := "RE:" + WF6_DESCR
	  	else                                 
	  	  cSubject  := "FW:" + WF6_DESCR
	  	endif  
		cText     := Chr( 13 ) + Chr( 10 )
		cText     += Chr( 13 ) + Chr( 10 )
		cText     += STR0017 + Chr( 13 ) + Chr( 10 ) //"---- Mensagem Original ----"
		cText     += STR0018 + WF6_DE + Chr( 13 ) + Chr( 10 ) //"De: "
		cText     += STR0019 + DtoC( WF6_DATA ) + " " + WF6_HORA + Chr( 13 ) + Chr( 10 ) //"Enviada em: "
		cText     += STR0020 + WF6_PARA + Chr( 13 ) + Chr( 10 ) //"Para: "
		cText     += STR0021 + WF6_DESCR + Chr( 13 ) + Chr( 10 ) //"Assunto: "
		cText     += Chr( 13 ) + Chr( 10 )
		cText     += Chr( 13 ) + Chr( 10 )
		cText     += WFLoadFile( cFileText )
		
		if lReply
			cGroup := STR0022 //" Responder para: "
			cCaption := STR0023 //"Responder mensagem"
		else
			cGroup := STR0024 //" Encaminhar para: "
			cCaption := STR0025 //"Encaminhar mensagem"
			cUserList := Space( 255 )
		end
		
		cPriority := ::aPriorityList[ Val( WF6_PRIORI ) +1 ]
		
		cIdent := WF6_IDENT1
	else
		cSubject := Space( 100 )
		cText := Space( 255 )
		cUserList := Space( 255 )
		cCaption := STR0009 //"Nova mensagem"
		cGroup := ""
		cPriority := ::aPriorityList[ 2 ]
		cIdent := Int2Hex( WFGetNum( "MV_WF6IDEN" ),10 )
	end
	
	DEFINE DIALOG oDlg TITLE cCaption From 0,0 To 36,72
	DEFINE FONT oFont NAME "Arial" SIZE 0, -12 BOLD

	@ 32,05 SAY STR0012 SIZE 50,10 PIXEL FONT oFont OF oDlg  //"Prioridade:"
	@ 32,50 MSCOMBOBOX oPriority VAR cPriority ITEMS ::aPriorityList PIXEL SIZE 50,13 OF oDlg
	
   if lReply
		@ 45,05 SAY STR0026 SIZE 50,10 PIXEL FONT oFont OF oDlg //"Para:"
	else
		@ 45,05 BUTTON STR0027 SIZE 40,15 PIXEL OF oDlg ACTION ( cUserList := ::GetUserList( cUserList ) ) //"Para..."
	end

	@  45,50 GET oUserList VAR cUserList PIXEL MEMO SIZE 230,20 OF oDlg 
	
	if lReply
		oUserList:SetDisable()
	end
	
	@  70,05 SAY STR0014 SIZE 50,10 PIXEL FONT oFont OF oDlg //"Assunto:"
	@  70,50 MSGET oSubject VAR cSubject SIZE 231, 10 PIXEL OF oDlg
	@  85,05 GET oText VAR cText PIXEL MEMO SIZE 275,175 OF oDlg 

	bOkBtn := { || lResult := ::SendMsg( cUserList, cSubject, cText, cPriority, cIdent ), oDlg:End() }
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( EnchoiceBar( oDlg, bOkBtn, { || oDlg:End() } ) )
return lResult

method Remove() class TWFTaskMsg
	Local nPos
	Local cFileName
	Local cMsg := STR0028 //"Deseja remover esta mensagem da sua lista de pendencias?"
	
	if !Eof()

		if MsgYesNo( cMsg, STR0008 ) //"Remover"
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

method GetUserList( cUserList ) class TWFTaskMsg
	Local bLine
	Local nC1, nC2, nPos
	Local oDlg, oText, oFont
	Local aCmdBar := {}, aAllUsers, aGroups, aAllGroups, aUserList1, aUserList2
	Local cNGroup	:= ""
	
	default cUserList := Space( 255 )
	
	aAllUsers	:= FwSFAllUsers()
	aAllGroups	:= FWSFAllGrps()
	aUserList1	:= WFTokenChar( cUserList, ";" )
	aUserList2	:= AClone( aUserList1 )

	::aBrowser	:= {}	
	
	For nC1 := 1 to Len(aAllUsers)
	   If __cUserID <> aAllUsers[1,2] /*ID do Usuário*/
	      lSelected := AScan(aUserList1, {|x| Upper(AllTrim(x)) == Upper(AllTrim(aAllUsers[nC1,3])) /*Login do Usuário*/}) > 0
	      If Len(aGroups := FWSFUsrGrps(aAllUsers[nC1,2])) > 0 
	         For nC2 := 1 to Len(aGroups)
	             cNGroup := If((nPos := aScan(aAllGroups, {|x| x[2] == aGroups[nC2]})) > 0,;
	                           Left(aAllGroups[nPos,4] + Space(20), 20), /*Com Grupo*/Left(STR0029 + Space(20), 20))               /*Sem Grupo*/
	            aAdd(::aBrowser, {lSelected,;
	                              aAllUsers[nC1,3] /*Login do Usuário*/,;
	                              cNGroup          /*Grupo*/,;
	                              aAllUsers[nC1,4] /*Nome do usuário*/,;
	                              aAllUsers[nC1,5] /*E-Mail*/,;
	                              aAllUsers[nC1,7] /*Cargo*/,;
	                              aAllUsers[nC1,6] /*Departamento*/})
	         Next nC2
	      Else
	         aAdd(::aBrowser, {lSelected,;
	                           aAllUsers[nC1,3]              /*Login do Usuário*/,;
	                           Left(STR0029 + Space(20), 20) /*Grupo*/,;
	                           aAllUsers[nC1,4]              /*Nome do usuário*/,;
	                           aAllUsers[nC1,5]              /*E-Mail*/,;
	                           aAllUsers[nC1,7]              /*Cargo*/,;
	                           aAllUsers[nC1,6]              /*Departamento*/}) //"Sem Grupo"
	      EndIf
	   EndIf
	Next nC1
	
	if Len( ::aBrowser ) > 0
		::aBrowser := ASort( ::aBrowser,,,{ |x,y| ( x[ 2 ] + x[ 3 ] ) < ( y[ 2 ] + y[ 3 ] ) } )
	else
		AAdd( ::aBrowser, { .f., "", "", "", "", "", "" } )
	end
	
	DEFINE DIALOG oDlg TITLE STR0030 FROM 0,0 To 19,64 //"Selecionar Destinatarios"
	DEFINE FONT oFont NAME "Arial" SIZE 0, -12 BOLD

	@ 30, 5 LISTBOX ::oBrowser ;
		FIELDS	"" ;
		HEADER	" ",;
					" ",;
					STR0031,; //"Usuario"
					STR0032,; //"Grupo"
					STR0033,; //"Nome"
					STR0034,; //"Endereco eletronico"
					STR0035,; //"Cargo"
					STR0036,; //"Departamento"
		ON DBLCLICK ::SelectUser( aUserList1 ) ;
		SIZE 242, 110 OF oDlg PIXEL

	bLine := { || { ;
		if( ::aBrowser[ ::oBrowser:nAt,1 ], LoadBitmap( GetResource(), "WFCHK" ), LoadBitmap( GetResource(), "WFUNCHK" ) ),;
		LoadBitmap( GetResource(), "BMPUSER" ),;
		::aBrowser[ ::oBrowser:nAt,2 ],;
		::aBrowser[ ::oBrowser:nAt,3 ],;
		::aBrowser[ ::oBrowser:nAt,4 ],;
		::aBrowser[ ::oBrowser:nAt,5 ],;
		::aBrowser[ ::oBrowser:nAt,6 ] } }
		
	::oBrowser:SetArray( ::aBrowser )
	::oBrowser:bLine := bLine
	
	AAdd( aCmdBar, { "LBTIK", {|| ::SelectAll( aUserList1, .t. ) }, STR0037 } ) //"Marcar Todos"
	AAdd( aCmdBar, { "LBNO", {|| ::SelectAll(  aUserList1, .f. ) }, STR0038 } ) //"Desmarcar Todos"
	AAdd( aCmdBar, { "MSGGROUP", {|| ::SelectGroup(  aUserList1 ) }, STR0059 } ) //"Selecionar por grupo"
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( EnchoiceBar( oDlg, { || oDlg:End() }, { || aUserList1 := aUserList2, oDlg:End() },, aCmdBar ) )
	oChkBtn := nil
	oUnChkBtn := nil
return WFUnTokenChar( aUserList1, ";" )

method SelectGroup( aUserList ) class TWFTaskMsg
	Local nC
	Local cGroup
	
   if Len( ::aBrowser ) == 0
   	return
   end
   
	cGroup := ::aBrowser[ ::oBrowser:nAt,3 ]
	
	for nC := 1 to Len( ::aBrowser )
		if Upper( AllTrim( ::aBrowser[ nC,3 ] ) ) == Upper( AllTrim( cGroup ) )
			::aBrowser[ nC,1 ] := .t.
			if AScan( aUserList, { |x| Upper( AllTrim( x ) ) == Upper( AllTrim( ::aBrowser[ nC,3 ] ) ) } ) == 0
				AAdd( aUserList, AllTrim( ::aBrowser[ nC,2 ] ) )
			end
		end
	next

return

method SelectAll( aUserList, lSelect ) class TWFTaskMsg
	Local nC
	Local cUserName
	
	for nC := 1 to Len( ::aBrowser )
		cUserName := AllTrim( ::aBrowser[ nC,2 ] )
		
		if ( nPos := AScan( aUserList, { |x| Upper( AllTrim( x ) ) == Upper( cUserName ) } ) ) == 0 .and. lSelect
			AAdd( aUserList, cUserName )
			::aBrowser[ nC,1 ] := .t.
		elseif ( nPos > 0 ) .and. !( lSelect )
			ADel( aUserList, nPos )
			ASize( aUserList, Len( aUserList ) -1 )
			::aBrowser[ nC,1 ] := .f.
		end

	next
	
   ::oBrowser:Refresh()
return

method SelectUser( aUserList ) class TWFTaskMsg
	Local nPos
	Local cUserName := AllTrim( ::aBrowser[ ::oBrowser:nAt,2 ] )
	
	if ( nPos := AScan( aUserList, { |x| Upper( AllTrim( x ) ) == Upper( cUserName ) } ) ) == 0
		AAdd( aUserList, cUserName )
		::aBrowser[ ::oBrowser:nAt, 1 ] := .t.
	else
		ADel( aUserList, nPos )
		ASize( aUserList, Len( aUserList ) -1 )
		::aBrowser[ ::oBrowser:nAt, 1 ] := .f.
	end
	
   ::oBrowser:Refresh()
return 

method SendMsg( cUserList, cSubject, cText, cPriority, cIdent ) class TWFTaskMsg
return ( ::lRefresh := WFMessenger( ::oTaskDlg:oTaskMan:cUserName, cUserList, cSubject, cText, cPriority, cIdent ) )

function	WFMessenger( cUserName, cUserList, cSubject, cText, cPriority, cIdent )
	Local oWF
	Local lResult := .f.
	Local nC, nPos, nRecNo
	Local cFilePath, cFileName, cMsg, cInvalid := "", cLastAlias := Alias()
	Local aAllUsers, aUserList, aSendMail := {}

	default cUserName := "", cUserList := "", cSubject := "", cText := "", cPriority := "1", cIdent := Int2Hex( WFGetNum( "MV_WF6IDEN" ),10 )

	if Empty( cUserList := AllTrim( cUserList ) )
		MsgAlert( STR0039 ) //"Informe o(s) destinatario(s)!"
	else
		nRecNo := RecNo()
		oWF := TWFObj()
		aUserList := WFTokenChar( AllTrim( cUserList ) )
		
		while ( nPos := AScan( aUserList, { |x| At( chr(64), x ) > 0 } ) ) > 0
			AAdd( aSendMail, AllTrim( aUserList[ nPos ] ) )
			ADel( aUserList, nPos )
			ASize( aUserList, Len( aUserList ) -1 )
		end
		
		for nC := 1 to Len( aUserList )
			aUserList[ nC ] := Left( aUserList[ nC ] + Space( 15 ),15 )
		next
		
		nC := 1	
		aAllUsers	:= FwSFAllUsers()
		while nC <= Len( aUserList )
			if ( nPos := AScan( aAllUsers,{ |x| Upper( Left( x[ 3 ] + Space( 15 ),15 ) ) == Upper( aUserList[ nC ] ) } ) ) == 0
				if !Empty( cInvalid )
					cInvalid += "; "
				end
				
				cInvalid += "'" + AllTrim( aUserList[ nC ] ) + "'"
				ADel( aUserList, nC )
				ASize( aUserList, Len( aUserList ) -1 )
			else
				nC++
			end
		
		end

		if Empty( cInvalid )
		
			cPriority := Left( cPriority, 1 )
			dbSelectArea( "WF6" )
		
			if Len( aUserList ) > 0
		
				for nC := 1 to Len( aUserList )
					cFilePath := oWF:cMessengerDir + Lower( AllTrim( aUserList[ nC ] ) ) + "\"
					WFForceDir( cFilePath )

					while File( cFileName := cFilePath + "msg" + SubStr( CriaTrab(,.f.),3 ) + ".apm" )
					end

					if WFSaveFile( cFileName, cText )
				
						if RecLock( "WF6", .T. )
							WF6_FILIAL	:= xFilial( "WF6" )
							WF6_PROPRI	:= Upper( AllTrim( aUserList[ nC ] ) )
							WF6_PARA		:= aUserList[ nC ]
							WF6_DE		:= cUserName
							WF6_GRUPO	:= "00002"
							WF6_STATUS	:= "1"
							WF6_PRIORI	:= cPriority
							WF6_IDENT1	:= cIdent
//							WF6_IDENT2	:= cIdent2
							WF6_DATA		:= MsDate()
							WF6_HORA		:= Left( Time(),5 )
							WF6_DESCR	:= cSubject
							WF6_ACAO		:= '{|oTsk| WFTaskMsg( oTsk, 2,"' + StrTran( cFileName, "\", "/" ) + '" ) }'
							MSUnlock("WF6")
						end

					else
						cMsg := STR0040 //"Nao foi possivel gravar a mensagem em: %c."
						cMsg := FormatStr( cMsg, cFileName )
						MsgAlert( cMsg )
					end
				
				next
			
			end
		
			cFilePath := oWF:cMessengerDir + Lower( AllTrim( cUserName ) ) + "\"
			WFForceDir( cFilePath )

			while File( cFileName := cFilePath + "msg" + SubStr( CriaTrab(,.f.),3 ) + ".apm" )
			end
					
			if WFSaveFile( cFileName, cText )
					
				if RecLock( "WF6", .T. )
					WF6_FILIAL := xFilial( "WF6" )
					WF6_PROPRI := Upper( cUserName )
					WF6_PARA   := cUserList
					WF6_DE     := cUserName
					WF6_GRUPO  := "00002"
					WF6_STATUS := "4"
					WF6_PRIORI := cPriority
					WF6_IDENT1 := cIdent
//					WF6_IDENT2 := cIdent2
					WF6_DATA   := MsDate()
					WF6_HORA   := Left( Time(),5 )
					WF6_DESCR  := cSubject
					WF6_ACAO   := '{|oTsk| WFTaskMsg( oTsk, 2,"' + StrTran( cFileName, "\", "/" ) + '" ) }'
					MSUnlock("WF6")
				end
						
			end
		
			if Len( aSendMail ) > 0
			end
		
			lResult := .t.
			oWF:Free()
			oWF := nil
		else		
			cMsg := STR0041 //"Endereco(s) invalido(s) nao reconhecido(s): %c. Corrija-o(s) e tente novamente."
			MsgAlert( FormatStr( cMsg, { cInvalid } ) )
		end
		
		if cLastAlias <> nil
			dbSelectArea( cLastAlias )
			dbGoTo( nRecNo )
		end
		
	end
	
return lResult

Method LoadHist()  class TWFTaskMsg
Local aRet    := {}
Local cFilter := "0"

//Monta o Filtro
//Monta o Filtro
if ::oTaskDlg:oList:nAt == 1 
	//Itens em aberto
	cFilter := "13"
elseif ::oTaskDlg:oList:nAt == 2
	//Itens Lidos
	cFilter := "2"
elseif ::oTaskDlg:oList:nAt == 3
	//Itens Enviados
	cFilter := "4"
endif 

dbSelectArea('WF6')
WF6->(dbSetOrder(1))
WF6->(dbGoTop())
While WF6->(!Eof())
	if alltrim(WF6->WF6_PROPRI) $ alltrim(::oTaskDlg:cUserName) .and. WF6->WF6_STATUS == cFilter
		aAdd(aRet,{	" ",;
					" ",;
					alltrim(WF6_DE),;
					alltrim(WF6_DESCR),;
					alltrim(WF6_PARA),;
					iif(Valtype(WF6_DATA) == "C",CTOD(WF6_DATA),WF6_DATA),;
					WF6_HORA,;
					iif(Valtype(WF6_DTVENC) == "C",CTOD(WF6_DTVENC),WF6_DTVENC),;
					WF6_HRVENC,;
					WF6->(Recno()) })
	endif
	WF6->(dbSkip())
EndDo

if Len(aRet) == 0
	aRet := Array(1,10)
endif

Return aRet


Static Function GFileText(nRecno)
Local cFileText := ""

	//Posiciona na WF6
	if ValType(nRecno) == "N" .and. nRecno > 0
		dbSelectArea('WF6')
		WF6->(dbSetOrder(1))
		WF6->(dbGoTo(nRecno))
	endif
		 
	cFileText := StrTran( AllTrim( WF6_ACAO ), "/", "\" )
		
	if ( nPos := At( '"', cFileText ) ) > 0
		cFileText := SubStr( cFileText, nPos +1 )
		
		if ( nPos := At( '"', cFileText ) ) > 0
			cFileText := Left( cFileText, nPos -1 )
		end
			
	end
return cFileText
