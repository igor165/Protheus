#INCLUDE "QAXA030.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QAXA030  ³ Autor ³ Aldo Marini Junior    ³ Data ³ 03/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Depto\Setor                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAXA030()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()
Local aRotina 	:= {}
Private lIntLox	:= GetMv("MV_QALOGIX") == "1"

	If lIntLox
		aRotina  := {{ OemToAnsi(STR0001),"AxPesqui" ,0 ,1,,.F.},; //"Pesquisar"
					{ OemToAnsi(STR0002),"QAX30Telas",0 ,2},; //"Visualizar"
					{ OemToAnsi(STR0004),"QAX30Telas",0 ,4}} //"Alterar"
	Else
		aRotina  := {{ OemToAnsi(STR0001),"AxPesqui" ,0 ,1,,.F.},; //"Pesquisar"
					{ OemToAnsi(STR0002),"QAX30Telas",0 ,2},; //"Visualizar"
					{ OemToAnsi(STR0003),"QAX30Telas",0 ,3},; //"Incluir"
					{ OemToAnsi(STR0004),"QAX30Telas",0 ,4},; //"Alterar"
					{ OemToAnsi(STR0005),"QAX30Telas",0 ,5}}  // "Excluir"
	Endif

Return aRotina

Function QAXA030()
Local cFiltro := ""

Private aRotina  := MenuDef()
Private cCadastro:= OemToAnsi(STR0006)  //"Cadastro de Departamentos/Setor"

	If ExistBlock("QX030FIL")
		cFiltro := ExecBlock("QX030FIL",.F.,.F.,{cFiltro})
	EndIf

	dbSelectArea("QAD")
	QAD->(dbSetOrder(1))
	Set Filter to &(cFiltro)
	QAD->(DbSeek(xFilial("QAD")))

	mBrowse(006,001,022,075,"QAD")

	dbSelectArea("QAD")
	QAD->(dbSetOrder(1))
	DbClearFilter()
	QAD->(DbSeek(xFilial("QAD")))  

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QAX30Telas³ Autor ³ Aldo Marini Junior    ³ Data ³ 03/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela de Cadastro                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAX30Telas(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias do arquivo                                   ³±±
±±³          ³ ExpN1 - Numero do registro                                 ³±±
±±³          ³ ExpN2 - Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Modulos Quality                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QAX30Telas(cAlias,nReg,nOpc)

Local nI    := 0
Local nOpcao:= 0
Local nSaveSX8	:= GetSX8Len()
Local oDlg
Local oEnchoice

Private aGETS[0]
Private aTELA[0][0]
Private bCampo := {|nCPO| Field( nCPO ) }
Private cFilMat:= xFilial("QAA")
Private lIntGPE:= If(GetMv("MV_QGINT") == "S",.T.,.F.)

	DbSelectArea("QAD")
	DbSetOrder(1)

	If nOpc == 3 
	For nI := 1 To FCount()
		cCampo := Eval( bCampo, nI )
		lInit  := .F.
		If ExistIni( cCampo )
			lInit := .T.
			M->&( cCampo ) := InitPad( GetSx3Cache(cCampo, 'X3_RELACAO') )
			If ValType( M->&( cCampo ) ) = "C"
				M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo, 'X3_TAMANHO') )
			EndIf
			If M->&( cCampo ) == Nil
				lInit := .F.
			EndIf
		EndIf
		If !lInit
			M->&( cCampo ) := FieldGet( nI )
			If ValType( M->&( cCampo ) ) = "C"
				M->&( cCampo ) := Space( Len( M->&( cCampo ) ) )
			ElseIf ValType( M->&( cCampo ) ) = "N"
				M->&( cCampo ) := 0
			ElseIf ValType( M->&( cCampo ) ) = "D"
				M->&( cCampo ) := CtoD( "  /  /  " )
			ElseIf ValType( M->&( cCampo ) ) = "L"
				M->&( cCampo ) := .f.
			EndIf
		EndIf
	Next nI
	M->QAD_FILIAL := xFilial("QAD")
	
	Else
	For nI := 1 To FCount()
		M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
	Next nI
	EndIf

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 000,000 TO 385,625 PIXEL // "Departamento/Setor"

	oDlg:lMaximized := .T.

	oEnchoice := Msmget():New("QAD",nReg,nOpc,,,,,{014,002,190,312})

	oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	If nOpc <> 2 .And. nOpc <> 5
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela),(QAX030GrCC(nOpc),nOpcao:=1,oDlg:End()),)},{|| oDlg:End()})
	Else
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(nOpc == 5,QAX030Dele(),),oDlg:End() },{|| oDlg:End()})
	EndIf

	While (GetSX8Len() > nSaveSx8)
		If nOpcao == 1
			ConfirmSX8()		
		Else
			RollBackSX8()
		Endif
	Enddo

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QAX030GrCC³ Autor ³ Aldo Marini Junior    ³ Data ³ 03/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Departamentos/Setor                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAX030GrCC(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Modulos Quality                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QAX030GrCC(nOpc)

Local lRecLock:= .F.
Local nCnt    := 0

	If nOpc == 3
		lRecLock:= .T.
	EndIf

	Begin Transaction
		DbSelectArea("QAD")
		RecLock("QAD",lRecLock)
		For nCnt := 1 TO FCount()
			FieldPut(nCnt,M->&(Eval(bCampo,nCnt)))
		Next
		MsUnLock()

	End Transaction
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QAX030Dele³ Autor ³ Aldo Marini Junior    ³ Data ³ 03/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de exclusao de Departamentos                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAX030Dele()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Modulos Quality                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QAX030Dele()

Local lExiste  := .F.
Local lQADComp := Empty(xFilial("QAD"))

	CursorWait()
	dbSelectArea("QAA")
	dbGoTop()
	While !Eof()
		If QAA->QAA_CC == QAD->QAD_CUSTO .And. ;
			(lQADComp .Or. (!lQADComp .And. QAA->QAA_FILIAL == QAD->QAD_FILIAL))
			lExiste := .T.
			Exit
		EndIf
		dbSkip()
	EndDo
	CursorArrow()

	dbSelectArea("QAD")

	If !lExiste
		Begin Transaction
			RecLock("QAD",.F.)
			DbDelete()
			MsUnlock()
			dbSkip()
		End Transaction
	Else
		Help( " ", 1, "EXISTELARE") // Existe Relacao
	EndIf

Return
