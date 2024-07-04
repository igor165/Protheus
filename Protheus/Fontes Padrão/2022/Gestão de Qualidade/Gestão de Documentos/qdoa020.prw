#INCLUDE "TOTVS.CH"
#INCLUDE "QDOA020.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QDOA020    ³ Autor ³ Aldo Marini Junior ³ Data ³ 24/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Cadastro de Tipos de Documentos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QDOA020()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ SIGAQDO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Data  ³ BOPS ³Programador³ Alteracao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³26/11/01³012341³Eduardo S. ³ Acertado para gravar corretamente a filial³±±
±±³        ³      ³           ³ corrente.                           	  ³±±
±±³22/03/02³ META ³Eduardo S. ³ Otimizacao e Melhorias na Rotina.         ³±±
±±³02/08/02³059419³Eduardo S. ³ Incluido o campo "Qtde Num Seq" utilizado ³±±
±±³        ³      ³           ³ na geracao do numero sequencial do Docto. ³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

Local aRotina  := {{OemToAnsi(STR0001), "AxPesqui", 0,1,,.F.},; //"Pesquisar"
					{OemToAnsi(STR0002), "QD020Telas",0,2},; //"Visualizar"
					{OemToAnsi(STR0003), "QD020Telas",0,3},; //"Incluir"
					{OemToAnsi(STR0004), "QD020Telas",0,4},; //"Alterar"
					{OemToAnsi(STR0005), "QD020Telas",0,5}}  //"Excluir"

Return aRotina

Function QDOA020()

Private nQaConpad:= 7
Private cCadastro:= OemToAnsi(STR0006) // "Cadastro Tipo de Documento"
Private aRotina  := MenuDef()

DbSelectArea("QD2")
DbSetOrder(1)
DbGoTop()
mBrowse(006,001,022,075,"QD2")

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD020Telas ³ Autor ³ Aldo Marini Junior ³ Data ³ 30/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Cadastro de Tipos de Documentos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD020Telas(ExpC1,ExpN1,ExpN2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1 - Alias do Arquivo                                  ³±±
±±³           ³ ExpN1 - Registro Atual ( Recno() )                        ³±±
±±³           ³ ExpN2 - Opcao de selecao do aRotina                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA020                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD020Telas(cAlias,nReg,nOpc)

Local oDlg
Local nI       := 0
Local aMemos   := {{"QD2_PROTOC", "QD2_MEMO1"}} // Texto Protocolo
Local aColsRsp := {}
Local aColsNiv := {}
Local aHeadRsp := {}
Local aHeadNiv := {}
Local oEnch
Local aObjects  	:= {}
Local aSize    	:= MsAdvSize(.T.)
Local aInfo     	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
Local aPosObj   	:= {}

Private bCampo := {|nCPO| Field( nCPO ) }
Private aTELA[0][0]
Private aGETS[0]
Private aHeader:= {}
Private aCols  := {}
Private nUsado := 0
Private cFilDep:= xFilial("QAD") // Utilizada no SXB
Private lIntGPE:= If(GetMv("MV_QGINT",.F.,"N") == "S",.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa campos MEMO                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI:=1 to Len(aMemos)
	cMemo := aMemos[nI][2]
	If ExistIni(cMemo)
		&cMemo := InitPad(GetSx3Cache(cMemo, "X3_RELACAO"))
	Else
		&cMemo := ""
	EndIf
Next nI

If nOpc == 3
	For nI := 1 To FCount()
		cCampo := Eval( bCampo, nI )
		lInit  := .f.
		If ExistIni( cCampo )
			lInit := .t.
			M->&( cCampo ) := InitPad( GetSx3Cache(cCampo, "X3_RELACAO") )
			If ValType( M->&( cCampo ) ) = "C"
				M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo, "X3_TAMANHO") )
			EndIf
			If M->&( cCampo ) == Nil
				lInit := .f.
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
	M->QD2_FILIAL:= xFilial("QD2")
Else
	For nI := 1 To FCount()
		M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
	Next nI
EndIf

AAdd( aObjects, { 100, 100, .T., .T. } ) // Dados da Enchoice 
aPosObj:= MsObjSize( aInfo, aObjects, .T. ,.F.)



DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ;  // "Cadastro Tipo de Documento"
						FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL

oEnch := MsmGet():New( "QD2", nReg, nOpc,,,,,aPosObj[1], , , , , ,oDlg)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da GetDados em ARRAY                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QD020FGet("QDD",nOpc)
aHeadRsp := aClone(aHeader)
aColsRsp := aClone(aCols)


QD020FGet("QD5",1,nOpc)
aHeadNiv := aClone(aHeader)
aColsNiv := aClone(aCols)

aButtons:= {{"RESPONSA", {|| IF(!EMPTY(M->QD2_CODTP),QD020CdRsp(nOpc,@aColsRsp,aHeadRsp),"") },OemToAnsi(STR0007),OemToAnsi(STR0011)},; // "Respons veis"
				 {"SUMARIO" , {|| IF(!EMPTY(M->QD2_CODTP),QD020Nivel(nOpc,@aColsNiv,aHeadNiv),"")},OemToAnsi(STR0008),OemToAnsi(STR0012)}} // "N¡veis Respons veis"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(QD020Final(nOpc,aColsNiv,aHeadNiv,aColsRsp,aHeadRsp),oDlg:End(),.F.)},;
																 {||oDlg:End()},,aButtons)  CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDA020GrTP³ Autor ³ Eduardo de Souza      ³ Data ³ 20/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Tipo de Documentos                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDA020GrTP(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDA020GrTP(nOpc)

Local lRecLock:= .F.
Local nI      := 0

If nOpc == 3
	lRecLock:= .T.
EndIf

RecLock("QD2",lRecLock)
For nI := 1 TO FCount()
	FieldPut(nI,M->&(Eval(bCampo,nI)))
Next nI
MsUnLock()             
FKCOMMIT()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravacao das chaves dos Campos Memo na Inclusao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(M->QD2_MEMO1) .Or. nOpc == 4
	MSMM(QD2_PROTOC,,,M->QD2_MEMO1,1,,,"QD2","QD2_PROTOC")
	FKCOMMIT()
Endif

Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QDA020Dele ³ Autor ³ Aldo Marini Junior ³ Data ³ 24/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Exclusao de Tipos de Documentos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QDA020Dele()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA020                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDA020Dele()

Local lRet:= .T.

If !Inclui
	CursorWait()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe algum documento cadastrado com o tipo de documento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QDH->(DbGoTop())
	While QDH->(!Eof())
		If QDH->QDH_CODTP == M->QD2_CODTP
			lRet:= .F.
			Exit
		EndIf
		QDH->(DbSkip())
	EndDo		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe cadastrado alguma Pasta com o tipo de documento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QDC->(DbGoTop())
	While QDC->(!Eof())
		If QDC->QDC_CODTP == M->QD2_CODTP
			lRet:= .F.
			Exit
		EndIf
		QDC->(DbSkip())
	EndDo
	CursorArrow()
EndIf

If lRet
	Begin Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe responsaveis cadastrados por tipo de documento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QDD->(DbSeek(xFilial("QDD")+M->QD2_CODTP))
			While QDD->(!Eof()) .And. M->QD2_FILIAL + M->QD2_CODTP == QDD->QDD_FILIAL + QDD->QDD_CODTP
				RecLock("QDD",.F.)
				QDD->(DbDelete())
				MsUnlock()
				QDD->(DbSkip())
			Enddo
		EndIf		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe niveis obrigatorios cadastrados por tipo de documento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QD5->(DbSeek(xFilial("QD5")+M->QD2_CODTP))
			While QD5->(!Eof()) .And. M->QD2_FILIAL + M->QD2_CODTP == QD5->QD5_FILIAL + QD5->QD5_CODTP
				RecLock("QD5",.F.)
				QD5->(DbDelete())
				MsUnlock()
				QD5->(DbSkip())
			Enddo
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe tipo de Documento         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QD2->(DbSeek(xFilial("QD2")+M->QD2_CODTP))
			RecLock("QD2",.F.)
			QD2->(DbDelete())
			MsUnlock()
			MSMM(M->QD2_PROTOC,,,,2)
			QD2->(DbSkip())
		EndIf
	End Transaction		
Else
	Help(" ",1,"QD_DCTOEXT") // "Existem Documentos/Pastas associadas a este Tipo de Documento"
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD020CdRsp ³ Autor ³ Aldo Marini Junior ³ Data ³ 24/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Cadastra Responsaveis por Tipo de Documento               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD020CdRsp(ExpN1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpN1 - Opcao do Browse                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA020                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD020CdRsp(nOpc,aColsRsp,aHeadRsp)
Local cCodigo    := M->QD2_CODTP
Local cDescr     := Left(M->QD2_DESCTP,50)
Local nI         := 0
Local nMaxQtdLin := 10000000000000000
Local oCodigo    := NIL
Local oDescr     := NIL
Local oDlg1      := NIL
Local oGet1      := NIL

Private nPosFil:= 0

DbSelectArea("QDD")
QDD->(DbSetOrder(1))
If nOpc == 3
	For nI := 1 To FCount()
		cCampo := Eval( bCampo, nI )
		lInit  := .f.
		If ExistIni( cCampo )
			lInit := .t.
			M->&( cCampo ) := InitPad( GetSx3Cache(cCampo, "X3_RELACAO") )
			If ValType( M->&( cCampo ) ) = "C"
				M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo, "X3_TAMANHO") )
			EndIf
			If M->&( cCampo ) == Nil
				lInit := .f.
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
	M->QDD_FILIAL:= xFilial("QDD")
Else
	For nI := 1 To FCount()
		M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
	Next nI
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Organiza o Acols da Grade de Responsaveis E,R,A,H    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aColsRsp:=QD020OrAr(aColsRsp)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da GetDados						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader :=aClone(aHeadRsp)
aCols   :=aClone(aColsRsp)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Erro no Binario de Deletar a primeira linha do aCols³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF aCols[1,Len(aCols[1])]
	aCols[1,Len(aCols[1])]:=.F.
	lErroDel:= .T.
Else
	lErroDel:= .F.	
Endif	

nPosFil:= aScan(aHeader, { |x| AllTrim(x[2]) == "QDD_FILA"   })


DEFINE MSDIALOG oDlg1 TITLE cCadastro+" - "+OemToAnsi(STR0007) FROM 000,000 TO 315,625 OF oMainWnd PIXEL // "Respons veis"

@ 031,002 TO 060,312 OF oDlg1 PIXEL

@ 035,010 SAY OemToAnsi(STR0009) SIZE 030,007 OF oDlg1 PIXEL // "C¢digo"
@ 032,045 MSGET oCodigo VAR cCodigo SIZE 024,008 OF oDlg1 PIXEL
oCodigo:lReadOnly:= .T.

@ 047,010 SAY OemToAnsi(STR0010) SIZE 030,007 OF oDlg1 PIXEL // "Descri‡ao"
@ 044,045 MSGET oDescr VAR cDescr SIZE 170, 08 OF oDlg1 PIXEL
oDescr:lReadOnly:= .T.

oGet1 := MSGetDados():New(065,002,150,312,nOpc,"QD020LinOk","","",If(nOpc==2 .Or. nOpc==5,.F.,.T.),,,,nMaxQtdLin)

IF lErroDel
	aCols[1,Len(aCols[1])]:=.T.
Endif	

ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, {|| If(Obrigatorio(aGets,aTela) .And. QD020LinOk(),;
														 (aColsRsp:=aClone(aCols),oDlg1:End()),.F.)},{|| oDlg1:End()}) CENTERED
Return(aCols)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD020GrRsp ³ Autor ³ Aldo Marini Junior ³ Data ³ 24/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Grava Responsaveis por Tipo de Documento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD020GrRsp(ExpA1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo as informacoes iniciais do Acols   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA020                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD020GrRsp(aColsAux,aHeadRsp)

Local nCnt  := 0
Local nPos01:= GdfieldPos("QDD_AUT"   ,aHeadRsp)
Local nPos02:= GdfieldPos("QDD_FILA"  ,aHeadRsp)
Local nPos03:= GdfieldPos("QDD_DEPTOA",aHeadRsp)
Local nPos04:= GdfieldPos("QDD_CARGOA",aHeadRsp)
Local nCpo           

nUsado:=Len(aHeadRsp)

Begin Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Refaz o cadastro de responsaveis por tipo de documento            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QDD->(DbSeek(xFilial("QDD")+M->QD2_CODTP))
		While QDD->(!Eof()) .And. M->QD2_FILIAL + M->QD2_CODTP == QDD->QDD_FILIAL + QDD->QDD_CODTP
			RecLock("QDD",.F.)
			QDD->(DbDelete())
			MsUnlock()
			QDD->(DbSkip())
		Enddo
	EndIf   
	DbSelectArea("QDD")
	DbSetOrder(1)
	For nCnt:= 1 To Len(aColsAux)
		If !aColsAux[nCnt,nUsado+1] // Verifica se o item foi deletado
		    IF !EMPTY(aColsAux[nCnt,1])
				If QDD->(DbSeek(xFilial("QDD")+M->QD2_CODTP+aColsAux[nCnt,nPos01]+aColsAux[nCnt,nPos02]+aColsAux[nCnt,nPos03]+aColsAux[nCnt,nPos04]))
					RecLock("QDD",.F.)
				Else
					RecLock("QDD",.T.)
				Endif			
				For nCpo := 1 To Len(aHeadRsp)
					If aHeadRsp[nCpo, 10] <> "V"
						QDD->(FieldPut(FieldPos(Trim(aHeadRsp[nCpo,2])),aColsAux[nCnt,nCpo]))
					EndIf
				Next nCpo
				QDD->QDD_FILIAL:= xFilial("QDD") //M->QD2_FILIAL
				QDD->QDD_CODTP := M->QD2_CODTP
				MsUnlock()   
				FKCOMMIT()
			Endif
		Else
			If QDD->(DbSeek(xFilial("QDD")+M->QD2_CODTP+aColsAux[nCnt,nPos01]+aColsAux[nCnt,nPos02]+aColsAux[nCnt,nPos03]+aColsAux[nCnt,nPos04]))
				RecLock("QDD",.F.)
				QDD->(DbDelete())
				MsUnlock()
				FKCOMMIT()
			Endif
		Endif
	Next nCnt
End Transaction
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD020Nivel ³ Autor ³ Aldo Marini Junior ³ Data ³ 24/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Cadastra os Niveis dos Responsaveis                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD020CdRsp(ExpN1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpN1 - Opcao do Browse                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA020                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD020Nivel(nOpc,aColsNiv,aHeadNiv)
Local cCodigo    := M->QD2_CODTP
Local cDescr     := Left( M->QD2_DESCTP, 50 )
Local nI         := 0
Local nMaxQtdLin := 10000000000000000
Local oCodigo    := NIL
Local oDescr     := NIL
Local oDlg1      := NIL
Local oGet1      := NIL

DbSelectArea("QD5")
QD5->(DbSetOrder(1))
If nOpc == 3
	For nI := 1 To FCount()
		cCampo := Eval( bCampo, nI )
		lInit  := .f.
		If ExistIni( cCampo )
			lInit := .t.
			M->&( cCampo ) := InitPad( GetSx3Cache(cCampo, "X3_RELACAO") )
			If ValType( M->&( cCampo ) ) = "C"
				M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo, "X3_TAMANHO") )
			EndIf
			If M->&( cCampo ) == Nil
				lInit := .f.
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
	M->QD5_FILIAL:= xFilial("QD5")
Else
	For nI := 1 To FCount()
		M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
	Next nI
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Organiza o Acols da Grade de Responsaveis E,R,A,H    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aColsNiv:=QD020OrAr(aColsNiv)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da GetDados						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader:= aClone(aHeadNiv)
aCols  := aClone(aColsNiv)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Erro no Binario de Deletar a primeira linha do aCols³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF aCols[1,Len(aCols[1])]
	aCols[1,Len(aCols[1])]:=.F.
	lErroDel:= .T.
Else
	lErroDel:= .F.	
Endif	

DEFINE MSDIALOG oDlg1 TITLE cCadastro+" - "+OemToAnsi(STR0008) FROM 000,000 TO 315,625 OF oMainWnd PIXEL // "N¡veis Respons veis"

@ 031,002 TO 060,312 OF oDlg1 PIXEL

@ 035,010 SAY OemToAnsi(STR0009) SIZE 030,007 OF oDlg1 PIXEL // "C¢digo"
@ 032,045 MSGET oCodigo VAR cCodigo SIZE 024,008 OF oDlg1 PIXEL
oCodigo:lReadOnly:= .T.

@ 047,010 SAY OemToAnsi(STR0010) SIZE 030,007 OF oDlg1 PIXEL // "Descri‡ao"
@ 044,045 MSGET oDescr VAR cDescr SIZE 170,008 OF oDlg1 PIXEL
oDescr:lReadOnly:= .T.

oGet1 := MSGetDados():New(065,002,150,312,nOpc,"QD020LinOk","","",If(nOpc==2 .Or. nOpc==5,.F.,.T.),,,,nMaxQtdLin)

IF lErroDel
	aCols[1,Len(aCols[1])]:=.T.
Endif		

ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, {|| If(Obrigatorio(aGets,aTela) .And. QD020LinOk() .AND. QD020CkNiv(aCols),;
														 (aColsNiv:=aClone(aCols),oDlg1:End()),.F.)}, {|| oDlg1:End()}) CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD020GrNiv ³ Autor ³ Aldo Marini Junior ³ Data ³ 24/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Grava Niveis de Responsaveis                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD020GrNiv(ExpA1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo as informacoes iniciais do Acols   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA020                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD020GrNiv(AcolsAux,aHeadNiv)

Local nCnt  := 0
Local nPos01:= GdFieldPos("QD5_AUT" ,aHeadNiv)
Local nCpo

nUsado:=Len(aHeadNiv)

DbSelectArea("QD5")
DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Deleta os NIVEIS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCnt:= 1 To Len(AcolsAux)                                     
	If AcolsAux[nCnt,nUsado+1] // Verifica se o item foi deletado
		If QD5->(DbSeek(xFilial("QD5")+M->QD2_CODTP+AcolsAux[nCnt,nPos01]))
			RecLock("QD5",.F.)
			QD5->(DbDelete())
			MsUnlock()
			FKCOMMIT()
		Endif
	Endif	
Next nCnt		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava  os NIVEIS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCnt:= 1 To Len(AcolsAux)		
	If !AcolsAux[nCnt,nUsado+1] // Verifica se o item foi deletado
		If QD5->(DbSeek(xFilial("QD5")+M->QD2_CODTP+AcolsAux[nCnt,nPos01]))
			RecLock("QD5",.F.)
		Else
			RecLock("QD5",.T.)
		Endif
		For nCpo := 1 To Len(aHeadNiv)
			If aHeadNiv[nCpo, 10] <> "V"
				QD5->(FieldPut(FieldPos(Trim(aHeadNiv[nCpo,2])),AcolsAux[nCnt,nCpo]))
			EndIf
		Next nCpo
		QD5->QD5_FILIAL:= xFilial("QD5") //M->QD2_FILIAL
		QD5->QD5_CODTP := M->QD2_CODTP
		MsUnlock()       
		FKCOMMIT()
	Endif
Next nCnt

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD020LinOk ³ Autor ³ Aldo Marini Junior ³ Data ³ 24/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Critica Linha Digitada                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD020LinOk()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA020                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD020LinOk()

Local nCnt     := 0
Local lRet     := .t.
Local nCont    := 0
Local nPos0    := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QDD_AUT"	})
Local nPos1    := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QDD_FILA"	})
Local nPos2    := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QDD_DEPTOA"})
Local nPos3    := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QDD_CARGOA"})
Local nPos4    := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QD5_AUT" 	})
Local nPosAli  := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) $ "QDD_ALI_WT | QD5_ALI_WT" 	})
Local nPosRec  := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) $ "QDD_REC_WT | QD5_REC_WT" 	})
Local nPosDel:= Len(aCols[n])

If !aCols[n,nPosDel]
	If nPos0 <> 0 .And. nPos1 <> 0 .And. nPos2 <> 0 .And. nPos3 <> 0
		Aeval(aCols,{|X| IF(!X[nPosDel],If(X[nPos0] == aCols[n,nPos0] .And. X[nPos1] == aCols[n,nPos1] .And. ;
									X[nPos2] == aCols[n,nPos2] .And. X[nPos3] == aCols[n,nPos3],nCont++,nCont),"") })
		If nCont > 1
			Help( " ", 1, "QALCTOJAEX" ) // Informacao ja Cadastrada
			Return .F.
		EndIf
	EndIf	
	If nPos4 <> 0
		nCont:= 0
		Aeval(aCols,{|X| IF(!X[nPosDel],If( X[nPos4] == aCols[n,nPos4],nCont++,nCont),"")})
		If nCont > 1
			Help( " ", 1,"QALCTOJAEX" ) // Informacao ja Cadastrada
			Return .F.
		EndIf
	EndIf
	
	For nCnt = 1 To Len(aHeader)
		If nCnt == nPosAli .Or. nCnt == nPosRec
			Loop
		EndIf
		If Empty(aCols[n,nCnt])
			If Lastkey() <> 27
				Help(" ",1,"QDA020BRA")
				lRet:= .F.
			EndIf
			Exit
		EndIf
	Next nCnt
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD020CkRsp ³ Autor ³ Aldo Marini Junior ³ Data ³ 27/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Checa existencia de Responsavel cadastrado                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD020CkRsp()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA020                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD020CkRsp()

Local lRet := .F.
Local aArea:= GetArea()
Local cFilQAD:=xFilial("QAD")                                  
Local cQuery:= ""

IF FWModeAccess("QAD") == "E" //!Empty(cFilQAD)     
	cFilQAD:= M->QD2_FILDEP	
ENDIF

QAD->(DbSetOrder(1))
If QAD->(DbSeek(cFilQAD+M->QD2_DEPTO))  
    lRet := .F.      

	cQuery :="SELECT QAA.QAA_FILIAL,QAA.QAA_CC,QAA.QAA_MAT "
	cQuery +="FROM " + RetSqlName("QAA")+" QAA "
	cQuery +="WHERE "       
	cQuery +="QAA.QAA_FILIAL='"+M->QD2_FILDEP+"' AND "	
	cQuery +="QAA.QAA_CC='"+M->QD2_DEPTO+"' AND "
	cQuery +="QAA.QAA_DISTSN = '1' AND "
	cQuery += QA_FilSitF(.T.,.T.)+" AND "
	cQuery +="QAA.D_E_L_E_T_ <> '*' "
			
	If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
		cQuery += " ORDER BY 1,2,3"
	Else
		cQuery += " ORDER BY " + SqlOrder("QAA_FILIAL+QAA_CC+QAA_MAT")
	Endif
		
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQAA",.T.,.T.)
		
	DbGotop()
	lRet:= TMPQAA->(!Eof())
	TMPQAA->(DbCLOSEAREA())			

	IF !lRet
		MsgAlert(OemToAnsi(STR0013),STR0014)  //"O departamento informado deve ter no minimo um Usuario com distribuidor indicado !"###"Aviso"
	Endif	     	
Else
	lRet := .F.
	Help(" ",1,"QD050CCNE")		                                    	
EndIf

RestArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD020CkNiv ³ Autor ³ Aldo Marini Junior ³ Data ³ 27/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Checa existencia de Niveis de resposaveis cadastrado      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD020CkNiv(ExpC1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1 - Alias do Arquivo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA020                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD020CkNiv(aColsAux)

Local lRet := .T.
Local nPosE:= AsCaN(aColsAux,{|x| X[1]="E" }) // Nivel de Elaborador
    
IF nPosE==0 
	lRet:= .F.
Else
	IF aColsAux[nPosE,LEn(aColsAux[nPosE])]  // Nao esta Deletado
		lRet:= .F.
 	Endif
EndIf

IF !lRet
	Help(" ",1,"QD020NENIV" )                               
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QD020Final³ Autor ³Eduardo de Souza      ³ Data ³ 21/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida Finalizacao do Cadastro do Tipo de Documentos       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD020Final(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao no Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD020Final(nOpc,aColsNiv,aHeadNiv,aColsRsp,aHeadRsp)

Local lRet:= .T.

If Obrigatorio(aGets,aTela)
	If nOpc == 3 .Or. nOpc == 4
		lRet:= QD020CkNiv(aColsNiv) .AND. QD020CkRsp()		
		IF lRet
			Begin Transaction
				QDA020GrTP(nOpc)
				QD020GrNiv(aColsNiv,aHeadNiv)
				QD020GrRsp(aColsRsp,aHeadRsp)
			End Transaction
		Endif
	ElseIf nOpc == 5
		lRet:= QDA020Dele()
	EndIf
Else
	lRet:= .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD020VdSeq ³ Autor ³Eduardo de Souza      ³ Data ³ 02/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida os campos responsaveis pela sequencia do Documento. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD020VdSeq()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD020VdSeq()

nTamDoc:= TamSx3("QDH_DOCTO")[1]

If M->QD2_QSEQ <= 0 .And. !Empty(M->QD2_SIGLA)
	Help(" ",1,"QD020QSEQ") // "Para a utilizacao da numecao sequencial de documento e necessario informar a Quantidade de Sequencia que devera utilizar."
	Return .F.
EndIf

If Len(AllTrim(M->QD2_SIGLA))+M->QD2_QSEQ > nTamDoc
	Help(" ",1,"QD020SIGLA") // "A Sigla do Documento junto com a Quantidade da numeracao sequencial ultrapassam o tamanho do nome do Documento."
	Return .F.
EndIf

Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD020OrAr  ³ Autor ³Telso Carneiro        ³ Data ³09/03/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Organiza o Array da Matriz de Responsabilidade             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD020OrAr(aAux)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function QD020OrAr(aAux)
                              
//E -Elaboracao, R -Revisao , A -Aprovacao , H -Homologacao

AEval(aAux,{|X| X[1]:=IF(X[1]=="E","1",IF(X[1]=="R","2",IF(X[1]=="A","3",IF(X[1]=="H","4",X[1])))) })

aAux := aSort( aAux, , , {|x,y| x[1]<Y[1] } )                                    

AEval(aAux,{|X| X[1]:=IF(X[1]=="1","E",IF(X[1]=="2","R",IF(X[1]=="3","A",IF(X[1]=="4","H",X[1])))) })

Return(aAux)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QD020FGet º Autor ³Raafel S. Bernardi  º Data ³ 26/01/2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta o aHeader e Acols, utilizando a funcao FillGetDados  º±±
±±º          ³ para adequar as funcionalidades do Walk Thru               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QDOA020                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QD020FGet(cAlias,nOpc)
Local cSeek
Local cWhile
Local lInclui  := .F.

aHeader := {}
aCols   := {}

If cAlias == "QDD"
	dbSelectArea(cAlias)
	dbSetOrder(1)
	If !dbSeek(xFilial(cAlias)+M->QD2_CODTP) .And. (nOpc == 3 .Or. nOpc == 4)
		lInclui := .T.
	Endif

	cSeek  := QDD_FILIAL+QDD_CODTP
	cWhile := "QDD_FILIAL+QDD_CODTP"
	
	If !lInclui
		FillGetDados(nOpc,cAlias,1     ,cSeek ,{|| &cWhile},         ,         ,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
	  //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
	Else
		FillGetDados(nOpc,cAlias,1     ,      ,             ,         ,         ,          ,        ,      ,         ,lInclui,          ,        ,          ,           ,            ,)
	  //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile   ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
	EndIf
	
ElseIf cAlias == "QD5"
	dbSelectArea(cAlias)
	dbSetOrder(1)
	If !dbSeek(xFilial(cAlias)+M->QD2_CODTP) .And. (nOpc == 3 .Or. nOpc == 4)
		lInclui := .T.
	Endif

	cSeek  := QD5_FILIAL+QD5_CODTP
	cWhile := "QD5_FILIAL+QD5_CODTP"
	
	If !lInclui
		FillGetDados(nOpc,cAlias,1     ,cSeek ,{|| &cWhile},         ,         ,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
	  //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
	Else
		FillGetDados(nOpcao,cAlias,1     ,      ,             ,         ,         ,          ,        ,      ,         ,lInclui,          ,        ,          ,           ,            ,)
	  //FillGetDados(nOpcao,Alias ,nOrdem,cSeek  ,bSeekWhile   ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
	EndIf

EndIF
Return
