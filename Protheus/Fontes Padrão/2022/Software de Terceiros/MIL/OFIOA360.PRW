#Include "OFIOA360.ch"
#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ OFIOA360 | Autor ³  Andre Luis Almeida   ³ Data ³ 21/09/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estoque Minimo e Seguranca OFICINA ( VAN )                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA360()
Private aCampos := {}
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0006)
mBrowse( 6, 1,22,75,"VAN")
Return 

Function OFIOA360S(nTp)
	Private lSair   := .f.			// Sair
   Private cGruIte := space(4)	// Grupo do Item    
   Private cCodIte := space(27)	// Codigo do Item   
   Private cDesIte := space(200)	// Descricao do Item
   Private lOk     := .t.			// Pode digitar todos os campos ???
   Private cTitulo := ""         // Titulo Janela
   Private nRecVAN := 0          // RecNo VAN
	Private aVAN    := {}         // Vetor com os Grupos do Arquivo VAN
	Private lItem   := .t.			// Pode Digitar o Item do Grupo ???
	Private lOkM    := .t.			// Pode digitar os campos ???
	Private nMPerio := nMDivid := 1					// Periodo / Divisor
	Private nMPerAA := nMPerAB := nMPerAC := 0	// % AA AB AC
	Private nMPerBA := nMPerBB := nMPerBC := 0	// % BA BB BC
	Private nMPerCA := nMPerCB := nMPerCC := 0	// % CA CB CC
	Private lOkS    := .t.			// Pode digitar os campos ???
	Private nSPerio := nSDivid := 1					// Periodo / Divisor
	Private nSPerAA := nSPerAB := nSPerAC := 0	// % AA AB AC
	Private nSPerBA := nSPerBB := nSPerBC := 0	// % BA BB BC
	Private nSPerCA := nSPerCB := nSPerCC := 0	// % CA CB CC
	Private aMDeman := {}
	Private aMTpPer := {}
	Private cMDeman := "0" 
	Private cMTpPer := "1"
	Private aSDeman := {}
	Private aSTpPer := {}
	Private cSDeman := "0"
	Private cSTpPer := "1"
	Private cTpMenu := " "
	aMDeman := FS_CBOX("VAN_MDEMAN")  // Cria ComboBox com SX3
	aMTpPer := FS_CBOX("VAN_MTPPER")  // Cria ComboBox com SX3
	aSDeman := FS_CBOX("VAN_SDEMAN")  // Cria ComboBox com SX3
	aSTpPer := FS_CBOX("VAN_STPPER")  // Cria ComboBox com SX3
   If nTp == 1 		// Visualizar
		lOk := .f.
		cTitulo := STR0002
		cTpMenu := "V"
		FS_MONTAR()
	ElseIf nTp == 2	// Incluir
		lOk  := .t.
		lOkM := .f.
		lOkS := .f.
		cTitulo := STR0003
		cTpMenu := "I"
		FS_VAN("CRIA")
   ElseIf nTp == 3	// Alterar
		lOk := .t.
		cTitulo := STR0004
		cTpMenu := "A"
		FS_MONTAR()
		FS_VAN("CRIA")
   ElseIf nTp == 4	// Excluir
		lOk := .f.
		cTitulo := STR0005
		cTpMenu := "E"
		FS_MONTAR()
	EndIf

	DEFINE MSDIALOG oEstq FROM 000,000 TO 026,070 TITLE (cTitulo+" - "+STR0006) OF oMainWnd

		// Grupo/Cod.Item //
			@ 010,007 SAY STR0007 SIZE 35,08 OF oEstq PIXEL COLOR CLR_BLUE
	   	@ 009,027 MSGET oGruIte VAR cGruIte PICTURE "!!!!" F3 "BMZ" VALID lSair .or. ( FS_VALID("SBM") .and. FS_VAN("VERG") ) SIZE 20,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN lOk ON CHANGE(lItem:=.t.)
			@ 010,065 SAY STR0008 SIZE 35,08 OF oEstq PIXEL COLOR CLR_BLUE
		   @ 009,080 MSGET oCodIte VAR cCodIte PICTURE "@!" F3 "B16" VALID lSair .or. ( FS_VALID("SB1") .and. FS_VAN("VERI") ) SIZE 100,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN lOk .and. lItem
		   @ 019,080 MSGET oDesIte VAR cDesIte PICTURE "@!" SIZE 100,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN .f.
		   @ 001,003 TO 037,275 LABEL "" OF oEstq PIXEL // Caixa Grupo/Cod.Item

		// Estoque Minimo //
			@ 048,010 SAY STR0009 SIZE 80,08 OF oEstq PIXEL COLOR CLR_BLUE 
			@ 047,050 MSCOMBOBOX oMDeman VAR cMDeman ITEMS aMDeman VALID lSair .or. FS_VALID("MDE") SIZE 100,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk ) ON CHANGE(lOkM:=.t.)
			@ 057,050 MSCOMBOBOX oMTpPer VAR cMTpPer ITEMS aMTpPer SIZE 70,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkM )
			@ 058,010 SAY STR0010 SIZE 80,08 OF oEstq PIXEL COLOR CLR_BLUE 
	   	@ 067,050 MSGET oMPerio VAR nMPerio PICTURE "999" VALID lSair .or. nMPerio > 0 SIZE 40,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkM )
			@ 068,010 SAY STR0011 SIZE 80,08 OF oEstq PIXEL COLOR CLR_BLUE 
	   	@ 077,050 MSGET oMDivid VAR nMDivid PICTURE "99" VALID lSair .or. nMDivid > 0 SIZE 40,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkM )
			@ 078,010 SAY STR0012 SIZE 80,08 OF oEstq PIXEL COLOR CLR_BLUE 
			@ 101,010 SAY STR0013 SIZE 80,08 OF oEstq PIXEL COLOR CLR_BLUE 
			@ 101,235 SAY "( 0 - 100% )" SIZE 80,08 OF oEstq PIXEL COLOR CLR_BLUE 
			@ 092,055 SAY "AA        AB        AC         BA        BB        BC         CA         CB        CC" SIZE 500,08 OF oEstq PIXEL COLOR CLR_BLUE
	   	@ 100,050 MSGET oMPerAA VAR nMPerAA PICTURE "999" VALID lSair .or. ( nMPerAA >= 0 .and. nMPerAA <= 100 ) SIZE 15,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkM )
	   	@ 100,070 MSGET oMPerAB VAR nMPerAB PICTURE "999" VALID lSair .or. ( nMPerAB >= 0 .and. nMPerAB <= 100 ) SIZE 15,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkM )
	   	@ 100,090 MSGET oMPerAC VAR nMPerAC PICTURE "999" VALID lSair .or. ( nMPerAC >= 0 .and. nMPerAC <= 100 ) SIZE 15,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkM )
	   	@ 100,110 MSGET oMPerBA VAR nMPerBA PICTURE "999" VALID lSair .or. ( nMPerBA >= 0 .and. nMPerBA <= 100 ) SIZE 15,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkM )
	   	@ 100,130 MSGET oMPerBB VAR nMPerBB PICTURE "999" VALID lSair .or. ( nMPerBB >= 0 .and. nMPerBB <= 100 ) SIZE 15,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkM )
	   	@ 100,150 MSGET oMPerBC VAR nMPerBC PICTURE "999" VALID lSair .or. ( nMPerBC >= 0 .and. nMPerBC <= 100 ) SIZE 15,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkM )
	   	@ 100,170 MSGET oMPerCA VAR nMPerCA PICTURE "999" VALID lSair .or. ( nMPerCA >= 0 .and. nMPerCA <= 100 ) SIZE 15,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkM )
	   	@ 100,190 MSGET oMPerCB VAR nMPerCB PICTURE "999" VALID lSair .or. ( nMPerCB >= 0 .and. nMPerCB <= 100 ) SIZE 15,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkM )
	   	@ 100,210 MSGET oMPerCC VAR nMPerCC PICTURE "999" VALID lSair .or. ( nMPerCC >= 0 .and. nMPerCC <= 100 ) SIZE 15,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkM )
   		@ 040,003 TO 115,275 LABEL STR0014 OF oEstq PIXEL // Caixa Estoque Minimo

		// Estoque Seguranca //
			@ 127,010 SAY STR0009 SIZE 80,08 OF oEstq PIXEL COLOR CLR_BLUE 
			@ 126,050 MSCOMBOBOX oSDeman VAR cSDeman ITEMS aSDeman VALID lSair .or. FS_VALID("SDE") SIZE 100,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk ) ON CHANGE(lOkS:=.t.)
			@ 136,050 MSCOMBOBOX oSTpPer VAR cSTpPer ITEMS aSTpPer SIZE 70,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkS )
			@ 137,010 SAY STR0010 SIZE 80,08 OF oEstq PIXEL COLOR CLR_BLUE 
	   	@ 146,050 MSGET oSPerio VAR nSPerio PICTURE "999" VALID lSair .or. nSPerio > 0 SIZE 40,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkS )
			@ 147,010 SAY STR0011 SIZE 80,08 OF oEstq PIXEL COLOR CLR_BLUE 
	   	@ 156,050 MSGET oSDivid VAR nSDivid PICTURE "99" VALID lSair .or. nSDivid > 0 SIZE 40,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkS )
			@ 157,010 SAY STR0012 SIZE 80,08 OF oEstq PIXEL COLOR CLR_BLUE 
			@ 180,010 SAY STR0013 SIZE 80,08 OF oEstq PIXEL COLOR CLR_BLUE 
			@ 180,235 SAY "( 0 - 100% )" SIZE 80,08 OF oEstq PIXEL COLOR CLR_BLUE 
			@ 171,055 SAY "AA        AB        AC         BA        BB        BC         CA         CB        CC" SIZE 500,08 OF oEstq PIXEL COLOR CLR_BLUE
	   	@ 179,050 MSGET oSPerAA VAR nSPerAA PICTURE "999" VALID lSair .or. ( nSPerAA >= 0 .and. nSPerAA <= 100 ) SIZE 15,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkS )
	   	@ 179,070 MSGET oSPerAB VAR nSPerAB PICTURE "999" VALID lSair .or. ( nSPerAB >= 0 .and. nSPerAB <= 100 ) SIZE 15,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkS )
	   	@ 179,090 MSGET oSPerAC VAR nSPerAC PICTURE "999" VALID lSair .or. ( nSPerAC >= 0 .and. nSPerAC <= 100 ) SIZE 15,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkS )
	   	@ 179,110 MSGET oSPerBA VAR nSPerBA PICTURE "999" VALID lSair .or. ( nSPerBA >= 0 .and. nSPerBA <= 100 ) SIZE 15,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkS )
	   	@ 179,130 MSGET oSPerBB VAR nSPerBB PICTURE "999" VALID lSair .or. ( nSPerBB >= 0 .and. nSPerBB <= 100 ) SIZE 15,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkS )
	   	@ 179,150 MSGET oSPerBC VAR nSPerBC PICTURE "999" VALID lSair .or. ( nSPerBC >= 0 .and. nSPerBC <= 100 ) SIZE 15,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkS )
	   	@ 179,170 MSGET oSPerCA VAR nSPerCA PICTURE "999" VALID lSair .or. ( nSPerCA >= 0 .and. nSPerCA <= 100 ) SIZE 15,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkS )
	   	@ 179,190 MSGET oSPerCB VAR nSPerCB PICTURE "999" VALID lSair .or. ( nSPerCB >= 0 .and. nSPerCB <= 100 ) SIZE 15,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkS )
	   	@ 179,210 MSGET oSPerCC VAR nSPerCC PICTURE "999" VALID lSair .or. ( nSPerCC >= 0 .and. nSPerCC <= 100 ) SIZE 15,08 OF oEstq PIXEL COLOR CLR_HBLUE WHEN ( lOk .and. lOkS )
   		@ 119,003 TO 194,275 LABEL STR0015 OF oEstq PIXEL // Caixa Estoque Seguranca

  	 	// Botoes //
			If nTp == 2 .or. nTp == 3
			   @ 009,202 BUTTON oOk PROMPT OemToAnsi(STR0016) OF oEstq SIZE 58,10 PIXEL ACTION (FS_SALVAR(nTp),oEstq:End())
		   ElseIf nTp == 4
			   @ 009,202 BUTTON oOk PROMPT OemToAnsi(STR0017) OF oEstq SIZE 58,10 PIXEL ACTION (FS_EXCLUIR(),oEstq:End())
			EndIf
		   @ 021,202 BUTTON oSair PROMPT OemToAnsi(STR0018) OF oEstq SIZE 58,10 PIXEL ACTION (lSair:=.t.,oEstq:End())

   ACTIVATE MSDIALOG oEstq CENTER 
Return 

Static Function FS_CBOX(cSeek)	// Cria ComboBox com SX3
	Local cRet := ""
	Local cCBx := ""
	Local ni   := 0
	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek(cSeek)
	cCBx := SX3->X3_CBOX
	cRet := '"'
	For ni := 1 to len(cCBx)
		cRet += If(substr(cCBx,ni,1)==";",'","',substr(cCBx,ni,1))
	Next
	cRet := "{"+Alltrim(cRet)+'"}'
Return(&cRet)

Static Function FS_MONTAR()	// Monta Tela com VAN selecionado
	DbSelectArea("VAN")
	nRecVAN := VAN->(RecNo())
	cGruIte := VAN->VAN_GRUITE
	cCodIte := VAN->VAN_CODITE
	DbSelectArea("SB1")
	DbSetOrder(7)
	If DbSeek( xFilial("SB1") + cGruIte + cCodIte )
		cDesIte := SB1->B1_DESC
   EndIf	 
	cMDeman := left(aMDeman[Val(VAN->VAN_MDEMAN)+1],1)
	If cMDeman == "0"
		lOkM := .f.
	EndIf
	cMTpPer := left(aMTpPer[Val(VAN->VAN_MTPPER)],1)
	nMPerio := VAN->VAN_MPERIO
	nMDivid := VAN->VAN_MDIVID
	nMPerAA := VAN->VAN_MPERAA
	nMPerAB := VAN->VAN_MPERAB
	nMPerAC := VAN->VAN_MPERAC
	nMPerBA := VAN->VAN_MPERBA
	nMPerBB := VAN->VAN_MPERBB
	nMPerBC := VAN->VAN_MPERBC
	nMPerCA := VAN->VAN_MPERCA
	nMPerCB := VAN->VAN_MPERCB
	nMPerCC := VAN->VAN_MPERCC
	cSDeman := left(aSDeman[Val(VAN->VAN_SDEMAN)+1],1)
	If cSDeman == "0"
		lOkS := .f.
	EndIf
	cSTpPer := left(aSTpPer[Val(VAN->VAN_STPPER)],1)
	nSPerio := VAN->VAN_SPERIO
	nSDivid := VAN->VAN_SDIVID
	nSPerAA := VAN->VAN_SPERAA
	nSPerAB := VAN->VAN_SPERAB
	nSPerAC := VAN->VAN_SPERAC
	nSPerBA := VAN->VAN_SPERBA
	nSPerBB := VAN->VAN_SPERBB
	nSPerBC := VAN->VAN_SPERBC
	nSPerCA := VAN->VAN_SPERCA
	nSPerCB := VAN->VAN_SPERCB
	nSPerCC := VAN->VAN_SPERCC
Return

Static Function FS_VAN(cTp)	// Vetor contendo VAN (Cria/Verifica)
	Local nPos := 0
	Local lRet := .f.
		If cTp == "CRIA" // Cria Vetor do VAN
			lRet := .t.
			DbSelectArea("VAN")
			DbSetOrder(1)
			DbSeek( xFilial("VAN") )
			While !Eof() .and. xFilial("VAN") == VAN->VAN_FILIAL
				aAdd(aVAN,{ VAN->VAN_GRUITE , VAN->VAN_CODITE , VAN->(RecNo()) })
				DbSelectArea("VAN")
				DbSkip()
			EndDo
			DbSelectArea("VAN")
			DbSetOrder(1)
			DbGoTo(nRecVAN)
		ElseIf cTp == "VERG" // Verifica se Existe o Grupo no Vetor do VAN
			nPos := aScan(aVAN,{|x| x[1]+x[2] == cGruIte+space(27) })
			lRet := .t.
		   If nPos > 0
				lItem := .t.
				If nRecVAN == aVAN[nPos,3]
					lItem := .f.
				EndIf
		   Else
				cCodIte := space(27)
				cDesIte := space(200)
				If !FS_VAN("VERI")
					lRet := .f.
				EndIf
				lItem := .f.
		   EndIf
		ElseIf cTp == "VERI" // Verifica se Existe o Grupo no Vetor do VAN
			nPos := aScan(aVAN,{|x| x[1]+x[2] == cGruIte+cCodIte })
			If nPos > 0
				If nRecVAN # aVAN[nPos,3]
					lRet := .f.
					MsgAlert(STR0020,STR0019)
				Else
					lRet := .t.
				EndIf	
			Else
				lRet := .t.
				lItem := .t.
			EndIf	
		EndIf
Return(lRet)

Static Function FS_SALVAR(nTp)	// Incluir/Alterar registro no VAN
	DbSelectArea("VAN")
	RecLock("VAN",If(nTp==2,.t.,.f.)) // .t. = Incluir / .f. = Alterar
		VAN->VAN_FILIAL := xFilial("VAN")
		VAN->VAN_GRUITE := cGruIte
		VAN->VAN_CODITE := cCodIte
		VAN->VAN_MDEMAN := left(cMDeman,1)
		VAN->VAN_MTPPER := left(cMTpPer,1)
		VAN->VAN_MPERIO := nMPerio
		VAN->VAN_MDIVID := nMDivid
		VAN->VAN_MPERAA := nMPerAA
		VAN->VAN_MPERAB := nMPerAB
		VAN->VAN_MPERAC := nMPerAC
		VAN->VAN_MPERBA := nMPerBA
		VAN->VAN_MPERBB := nMPerBB
		VAN->VAN_MPERBC := nMPerBC
		VAN->VAN_MPERCA := nMPerCA
		VAN->VAN_MPERCB := nMPerCB
		VAN->VAN_MPERCC := nMPerCC
		VAN->VAN_SDEMAN := left(cSDeman,1)
		VAN->VAN_STPPER := left(cSTpPer,1)
		VAN->VAN_SPERIO := nSPerio
		VAN->VAN_SDIVID := nSDivid
		VAN->VAN_SPERAA := nSPerAA
		VAN->VAN_SPERAB := nSPerAB
		VAN->VAN_SPERAC := nSPerAC
		VAN->VAN_SPERBA := nSPerBA
		VAN->VAN_SPERBB := nSPerBB
		VAN->VAN_SPERBC := nSPerBC
		VAN->VAN_SPERCA := nSPerCA
		VAN->VAN_SPERCB := nSPerCB
		VAN->VAN_SPERCC := nSPerCC
	MsUnlock()   
Return

Static Function FS_EXCLUIR()	// Exclui registro no VAN
	Local lRet := .t.
	DbSelectArea("VAN")
	DbSetOrder(1)
	DbSeek( xFilial("VAN") + cGruIte + "0" , .t. )
	If cGruIte == VAN->VAN_GRUITE .and. cCodIte # VAN->VAN_CODITE
		lRet := .f.
		MsgAlert(STR0021+cGruIte+" !",STR0019)
	EndIf
	DbSelectArea("VAN")
	DbSetOrder(1)
	DbGoTo(nRecVAN)
	If lRet
		DbSelectArea("VAN")
		RecLock("VAN",.f.,.t.)
			DbDelete()
		MsUnlock()
		WriteSX2("VAN")
	EndIf
Return

Static Function FS_VALID(cTp) // Valida: Grupo / Item / Demanda Minima / Demanda Seguranca
	Local lRet := .f.
	Local	lVer := .t.
		If cTp == "SBM" // Grupo SBM
			lVer := .t.
			If cTpMenu == "A"
				cGruAnt := VAN->VAN_GRUITE
				cIteAnt := VAN->VAN_CODITE
				If Empty(cIteAnt) .and. cGruIte # cGruAnt
					DbSelectArea("VAN")
					DbSetOrder(1)
					DbSeek( xFilial("VAN") + cGruAnt + "0" , .t. )
					If cGruAnt == VAN->VAN_GRUITE .and. cIteAnt # VAN->VAN_CODITE
						lRet := .f.                           
						lVer := .f.
						cGruIte := cGruAnt
						cCodIte := cIteAnt
						MsgAlert(STR0021+cGruAnt+" !",STR0019)
					EndIf
					DbSelectArea("VAN")
					DbSetOrder(1)
					DbGoTo(nRecVAN)
				EndIf
			EndIf
			If lVer
				DbSelectArea("SBM")
				DbSetOrder(1)
				If DbSeek( xFilial("SBM") + cGruIte )
					If SBM->BM_TIPGRU == "1 "
						lRet := .t.
					Else
						MsgAlert(STR0022,STR0019)
					EndIf
				Else
					MsgAlert(STR0023,STR0019)
				EndIf
				DbSelectArea("SB1")
				DbSetOrder(7)
				If !DbSeek( xFilial("SB1") + cGruIte + cCodIte )
					cCodIte := space(27)
					cDesIte := space(200)
				EndIf
			EndIf
		ElseIf cTp == "SB1" // Item SB1
			cDesIte := space(200)
			DbSelectArea("SB1")
			DbSetOrder(7)
			If DbSeek( xFilial("SB1") + cGruIte + cCodIte )
				lRet := .t.
				cDesIte := SB1->B1_DESC
			Else
				If Empty(cCodIte)
					lRet := .t.
				EndIf
			EndIf
		ElseIf cTp == "MDE" 
			lRet := .t.     
			If left(cMDeman,1) == "0"
				lOkM := .f.
			Else
				lOkM := .t.
			EndIf
		ElseIf cTp == "SDE" 
			lRet := .t.     
			If left(cSDeman,1) == "0"
				lOkS := .f.
			Else
				lOkS := .t.
			EndIf
		EndIf
Return(lRet)

Static Function MenuDef()
Local aRotina := { {STR0001,"AxPesqui", 0 , 1},;			// Pesquisar
                     {STR0002,"OFIOA360S(1)", 0 , 2},;		// Visualizar
                     {STR0003,"OFIOA360S(2)", 0 , 3 },;	// Incluir
                     {STR0004,"OFIOA360S(3)", 0 , 4 },;	// Alterar
                     {STR0005,"OFIOA360S(4)", 0 , 5 }}		// Excluir
Return aRotina
