#INCLUDE "SIGAWF.CH"
#INCLUDE "Wfc002.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ WFC002   ³ Autor ³ Marcelo Abe           ³ Data ³ 30.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta de Processos por Usuario                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void WFC002(void)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function WFC002()            
	Local nC
	Local oDlg
	Local aItens := {}
	Local cUserName := Subs(cUsuario, 7, 15), cIDProcess := "", cProcess := "", cDesc := ""
	Local nTopAdjust := 20
    
	PRIVATE oUserName, oDias, oBmp, oBmp1, oBmp2, oBmp3, oBmp4, oWF
	PRIVATE aUsers 

	oWF := TWFObj()

	ChkFile("WFA") 	 

	DEFINE MSDIALOG oDlg TITLE STR0001 From 0, 0 To 350, 620 PIXEL

	@ 125 + nTopAdjust , 06 BITMAP oBmp RESNAME "ENABLE" oF oDlg SIZE 20, 20 NOBORDER PIXEL
	@ 125 + nTopAdjust , 15 SAY STR0008 of oDlg SIZE 100, 10 PIXEL
	@ 135 + nTopAdjust , 06 BITMAP oBmp RESNAME "DISABLE" oF oDlg SIZE 20, 20 NOBORDER PIXEL
	@ 135 + nTopAdjust , 15 SAY STR0009 of oDlg SIZE 100, 10 PIXEL
	@  15 + nTopAdjust , 06 SAY STR0002 of oDlg PIXEL SIZE 20, 10    
    
    //Se for Administrador, carrega as informações dos outros usuários
	If ( __cUserID == "000000" )
		aUsers  := AllUsers(.T.)
		for nC := 1 to len( aUsers )
			if ( aUsers[nC, 1, 1] == __cUserID )
				cUserName := aUsers[nC, 1, 2]
			endif
			AAdd( aItens, aUsers[nC, 1, 2] )
		next 
		@ 15 + nTopAdjust , 50 COMBOBOX oUserName VAR cUserName ITEMS aItens PIXEL SIZE 110, 10 OF oDlg;
		ON CHANGE WFC002Ref(cUserName)
	else
		@ 15 + nTopAdjust , 50 MSGET oUserName VAR cUserName SIZE 92, 10 OF oDlg PIXEL
		oUserName:SetDisable()
	endif

	@ 33 + nTopAdjust, 6 SAY STR0003 of oDlg  PIXEL  SIZE 100, 10
	@ 40 + nTopAdjust, 6 LISTBOX oDias FIELDS HEADER " ", STR0004, STR0005, STR0006, STR0007	FIELDSIZES 14, 50, 120, 50, 50 SIZE 300, 80 PIXEL OF oDlg


	WFC002Ref(cUserName)
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( oUserName:SetFocus(), EnchoiceBar(oDlg, {|| oDlg:End() }, {|| oDlg:End()} ) )

	if Select( "WFA" ) <> 0  
		WFA->(dbCloseArea())
	endif
Return .T.

Static Function WFC002Ref(cUserName)
	Local nC, nPos
	Local oOk, oNo
	Local aDias := {}, aValues := {}
	Local cProcess, cDesc, cCodUser, cValFile, cWFAFindKey, cWF3FindKey

	oOk := LoadBitmap( GetResources(), "ENABLE" )
	oNo := LoadBitmap( GetResources(), "DISABLE" )

	if ( __cUserID == "000000" )
		for nC := 1 to Len(aUsers)
			if ( Alltrim(aUsers[nC][1][2]) == Alltrim(cUserName) )
				cCodUser := aUsers[nC][1][1] 
				exit
			endif
		next 
	else  
		cCoduser := __cUserID
	endif

	if empty( cCodUser )
		help("", 1, "WFUSERINV")  
		Return .F. 
	endif
         
	//Preenche o ListBox com os Processos do Usuário corrente
	dbSelectArea("WFA")          
	dbSetOrder(3) //filial+Usuario+Tipo+Ident
//  dbSeek(xFilial("WFA")+cCodUser+'3')
	cWFAFindKey := xFilial("WFA") + cCodUser
	dbSeek( cWFAFindKey )

	while !eof() .and. ( WFA_FILIAL + WFA_USRSIG == cWFAFindKey )
		if file( cValFile := lower( oWF:cProcessDir + AllTrim( WFA_IDENT ) + ".val" ) )
			aValues := WFLoadValFile( cValFile )
			if ( nPos := AScan( aValues, { |x| x[1] == "cSubject" } ) ) > 0
				cDesc := aValues[ nPos, 3 ]
			endif
			aValues := nil

			dbSelectArea("WF3")   
			dbSetOrder(1)
			
			If len(WFA->WFA_IDENT) >= WF_MAIL_ID_LEN //Tamanho do ID de processos com 8 posições.
				cWF3FindKey := xFilial("WF3") + PadR( left( WFA->WFA_IDENT, WF_PROC_ID_LEN ) + "." + substr( WFA->WFA_IDENT, WF_PROC_ID_LEN + 1, WF_TASK_ID_LEN ), WF_KEY_PROC_LEN )  
			Else
				cWF3FindKey := xFilial("WF3") + PadR( left( WFA->WFA_IDENT, WF_OLD_PROC_ID_LEN ) + "." + substr( WFA->WFA_IDENT, WF_OLD_PROC_ID_LEN + 1 , WF_OLD_TASK_ID_LEN ), WF_KEY_PROC_LEN ) 
			EndIf
			
			dbSeek( cWF3FindKey )
			cProcess := WF3_PROC
		
		  	dbSelectArea("WFA")
			Aadd(aDias, { WFA_TIPO == WF_ARCHIVE, cProcess, cDesc, DTOC(WFA_DATA), WFA_HORA } )
	  	endif
		dbSkip()                                       
	end
	
	if len(aDias) == 0 
		aadd(aDias, { .T., '', '', '', ''} )
	endif
  
	aDias := ASort( aDias, , , { |x,y| x[1] < y[1] } )
	oDias:SetArray(aDias)
	oDias:bLine := {|| {iif(aDias[oDias:nAt, 1], oOK, oNo), aDias[oDias:nAt, 2], aDias[oDias:nAt, 3], aDias[oDias:nAt, 4], aDias[oDias:nAt, 5] } }
	oDias:Refresh()
	oDias:GoTop()
Return .T.
