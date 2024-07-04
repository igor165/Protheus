#Include "PROTHEUS.CH"
#INCLUDE "QNCA140.CH"
#INCLUDE "FiveWin.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNCA140  ³ Autor ³ Leandro 				³ Data ³ 14/02/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Tipos de Documentos    						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

Local aRotina := {{STR0001, "AxPesqui"	, 0, 1,,.F.},;	//"Pesquisar"
				 {STR0002, "QNCA140ATU"	, 0, 2 },;	    //"Visualizar"
				 {STR0003, "QNCA140ATU"	, 0, 3 },;	    //"Incluir"
				 {STR0004, "QNCA140ATU"	, 0, 4, 82 },;	//"Alterar"
				 {STR0005, "QNCA140ATU"	, 0, 5, 3 }} 	//"Excluir"

Return aRotina

Function QNCA140()
PRIVATE cCadastro := STR0006//"Cadastro de Tipos de Documento"
PRIVATE aRotina   := MenuDef()

If !QNCHECK()
	Return(NIL)
Endif	

DbSelectArea("QUU")
DbSetOrder(1)

mBrowse( 6, 1,22,75,"QUU")

DbSelectArea("QUU")
Set Filter To
DbSetOrder(1)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCA140ATU³ Autor ³ Leandro				³ Data ³14/02/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao do cadastro de Tipos de Documentos			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCA140ATU(cAlias,nReg,nOpc)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA140ATU                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCA140ATU(cAlias,nReg,nOpc)
Local oDlg
Local bCampo  := { |nCPO| Field(nCPO) }
Local nI      := 0
Local aTela   := {}
Local aGets   := {}
Local lOk     := .F.
Local lDelete := .T.

DbSelectArea("QUU")
DbSetOrder(1)

If nOpc == 3 
   For nI := 1 To FCount()
       cCampo := Eval( bCampo, nI )
       lInit  := .F.
       If ExistIni( cCampo )
          lInit := .T.
          M->&( cCampo ) := InitPad( GetSx3Cache(cCampo,"X3_RELACAO") )
          If ValType( M->&( cCampo ) ) = "C"
             M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo,"X3_TAMANHO") )
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
Else
   For nI := 1 To FCount()
       M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
   Next nI
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro)	FROM 005,000 TO 300,570 OF oMainWnd PIXEL
EnChoice("QUU",nReg,nOpc,,,,,{37,3,140,280},,)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := If(Obrigatorio(aGets,aTela) .And. QNC140Valid(nOpc),oDlg:End(),.F.)},	{||lOk := .F.,oDlg:End()})CENTERED

If (!lOk) .Or. nOpc == 2
	Return NIL
Endif
	
If nOpc == 5
	
	dbSelectArea("QUT")
   	While QUT->(!Eof())
		If QUT->QUT_TIPODC == M->QUU_TIPODC
			lDelete := .F.
			Exit
		Endif	
		QUT->(dbSkip())
    Enddo

	If lDelete
		RecLock("QUU", .F.)
		dbDelete()
		MsUnLock()
		dbSkip()
	ELSE
		Aviso(STR0010,STR0011, {"ok"})//"Atencao"##"Esse titulo esta associado a uma etapa"
	Endif	
Else
	If nOpc == 3 .Or. nOpc == 4
		If QNC140Valid()
			If nOpc == 3
				RecLock( "QUU", .T. )
			Else 
				RecLock( "QUU", .F. )
			Endif			
		Else
			Return ()
		Endif	
	EndIf
	For nI := 1 TO FCount()
		FieldPut(nI,M->&(Eval(bCampo,nI)))
		QUU->QUU_FILIAL := xFilial('QUU')
	Next nI
	MsUnlock()                  
	FKCOMMIT()
Endif	

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC140Valid ³ Autor ³ Leandro              ³ Data ³14/02/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a existencia da habilidades cadastradas para uma   ³±±
±±³			 ³ mesma etapa          									   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A130Valid                                            	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNC140Valid(nOpc)
Local lRetorno  := .T.
Local aArea 	:= GetArea()

dbSelectArea("QUU")
dbSetOrder(1)
dbSeek( xFilial("QUU")+AllTrim(M->QUU_TIPODC))

If Empty(M->QUU_TIPODC)
	MsgAlert(STR0008)//"Codigo do documento nao foi preenchido!"
	lRetorno := .F.
Else
	If Empty(M->QUU_DESCDO)
		MsgAlert(STR0009)//"A descricao do documento nao foi informado"
		lRetorno := .F.
	Else
		If Found() .And. nOpc == 3  
			MSGAlert(STR0007)//"Tipo de documento jA cadastrado."
			lRetorno := .F.
		EndIf
	Endif
Endif		

RestaRea(aArea)

Return(lRetorno)
