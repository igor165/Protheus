
// 17/08/2009 -- Filial com mais de 2 caracteres

#INCLUDE "CTBA130.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWLIBVERSION.CH"

#DEFINE C_SALDOSINTERNOS	"012349"

Static _oCTBA130
Static cIdioma 		:= Upper( Left( FWRetIdiom(), 2 ) )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBA130   ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 11.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao do Cadastro de Estruturas Contabeis             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTBA130()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA130()

Local oDlg
Local oRadio
Local nRadio
Local nOpca 		:= 1
Local lGrupoCont    := GetNewPar("MV_CTBNATC","1") == "1"

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

While nOpca == 1

	DEFINE MSDIALOG oDlg FROM  94,1 TO 300,293 TITLE STR0001 PIXEL // "Configurações Contabeis"

	If lGrupoCont

		@ 05,17 Say STR0002 SIZE 150,7 OF oDlg PIXEL  // "Cadastro das Configurações Contabeis"

		@ 17,07 TO 82, 140 OF oDlg  PIXEL

		@ 25,10 Radio 	oRadio VAR nRadio;
						ITEMS 	STR0003,;		// "Mascara Entidades Contábeis"
								STR0004,;		// "Grupos Contábeis"
								STR0005,;		// "Set of Books"
								STR0017,;		// Apropriacao Custos
								STR0026; 		//"Saldos contabeis"
						SIZE 110,10 OF oDlg PIXEL
	Else

		@ 05,17 Say STR0002 SIZE 150,7 OF oDlg PIXEL  // "Cadastro das Configurações Contabeis"

		@ 17,07 TO 82, 140 OF oDlg  PIXEL

		@ 25,10 Radio 	oRadio VAR nRadio;
						ITEMS 	STR0003,;		// "Mascara Entidades Contábeis"
								STR0080,;		// "Naturezas Contábeis"
								STR0005,;		// "Set of Books"
								STR0017,;		// Apropriacao Custos
								STR0026; 		//"Saldos contabeis"
						SIZE 110,10 OF oDlg PIXEL
	EndIf

	DEFINE SBUTTON FROM 85,085 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
	DEFINE SBUTTON FROM 85,115 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)	// Zero nOpca caso
                                                               //	para saida com ESC

	If nOpca == 1
		If nRadio == 1
			Ctb130Est()					// Mascara entidades contabeis

		ElseIf nRadio == 2
			Ctb130Grp()					// Grupos Contabeis

		ElseIf nRadio == 3
			Ctb130Set()					// Set Of Books

		ElseIf nRadio == 4
			Ctb130Apro()				// Apropriacao de Custos

		ElseIf nRadio == 5				// Saldos contabeis
			Ctb130Sld()

		EndIf
	EndIf

EndDo

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb130GRP  ³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro Grupos Contabeis                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb130Grp()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA130                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ctb130Grp()
Local aCTBA130 := {}
Local lGrupoCont    := GetNewPar("MV_CTBNATC","1") == "1"
Local nX := 0

Private aRotina := { 	{ STR0006,"AxPesqui", 0 , 1},;  //"Pesquisar"
						{ STR0007,"AxVisual", 0 , 2},;  //"Visualizar"
						{ STR0008,"C130GrpInc", 0 , 3},;  //"Incluir"
						{ STR0009,"C130GrpAlt", 0 , 4},;  //"Alterar"
						{ STR0010,"C130GrpDel", 0 , 5} }  //"Excluir"

PRIVATE cCadastro := If( lGrupoCont,STR0012,STR0080 )  // "Grupos Contabeis"###"Naturezas Contabeis"
IF ExistBlock( "CTGRPBUT" )
	aCTBA130 := ExecBlock( "CTGRPBUT",.F.,.F.,aRotina)

	IF ValType(aCTBA130) == "A" .AND. Len(aCTBA130) > 0
		FOR nX := 1 to len(aCTBA130)
			aAdd(aRotina, aCTBA130[nX])
		NEXT
	ENDIF
ENDIF

mBrowse( 6, 1,22,75,"CTR")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb130Set  ³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro Set Of Book                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb130Set()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA130                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb130Set()
Local aCTBA130 := {}
Local nX := 0

Private aRotina := { 	{ STR0006,"AxPesqui"  , 0 , 1},;  //"Pesquisar"
						{ STR0007,"AxVisual"  , 0 , 2},;  //"Visualizar"
						{ STR0008,"CtbBookInc", 0 , 3},;  //"Incluir"
						{ STR0009,"CtbBookAlt", 0 , 4},;  //"Alterar"
						{ STR0010,"CtbBookDel", 0 , 5} }  //"Excluir"

PRIVATE cCadastro := STR0011  // "Cadastro Set Of Books"

IF ExistBlock( "CTSETBUT" )
	aCTBA130 := ExecBlock( "CTSETBUT",.F.,.F.,aRotina)

	IF ValType(aCTBA130) == "A" .AND. Len(aCTBA130) > 0
		FOR nX := 1 to len(aCTBA130)
			aAdd(aRotina, aCTBA130[nX])
		NEXT
	ENDIF
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"CTN")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbBookInc ³ Autor ³ Renato F. Campos     ³ Data ³ 24/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro Set Of Book                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbBookInc(cAlias, nReg, nOpc)
Local nOpcA := 0

BEGIN TRANSACTION

nOpcA := AxInclui(cAlias,nReg,nOpc,,,," VldPlRef(M->CTN_CODIGO,M->CTN_PLREF, M->CTN_VERSAO, M->CTN_PLAGER)")

IF nOpcA == 1
	// ponto de entrada para antes da gravação
	IF ExistBlock( "CtBookInc" )
		ExecBlock( "CtBookInc", .F. , .F. )
	Endif
Endif

END TRANSACTION

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbBookAlt ³ Autor ³ Renato F. Campos     ³ Data ³ 24/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro Set Of Book                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbBookAlt(cAlias, nReg, nOpc)
Local nOpcA := 0

BEGIN TRANSACTION

nOpcA := AxAltera(cAlias,nReg,nOpc,,,,," VldPlRef(M->CTN_CODIGO,M->CTN_PLREF, M->CTN_VERSAO, M->CTN_PLAGER)")

IF nOpcA == 1
	// ponto de entrada para antes da gravação
	IF ExistBlock( "CtBookAlt" )
		ExecBlock( "CtBookAlt", .F. , .F. )
	Endif
Endif

END TRANSACTION

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbBookDel ³ Autor ³ Renato F. Campos     ³ Data ³ 24/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro Set Of Book                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbBookDel(cAlias, nReg, nOpc)
Local nOpcA := 0

BEGIN TRANSACTION

nOpcA := AxDeleta(cAlias, nReg, nOpc)

IF nOpcA == 2
	// ponto de entrada para antes da gravação
	IF ExistBlock( "CtBookDel" )
		ExecBlock( "CtBookDel" , .F. , .F. )
	Endif
Endif

END TRANSACTION

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CT130Cap   ³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro Inc/Alt/Exc da estrutura da conta                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct130Cap(cAlias,nReg,nOpc)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA130                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do Arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do Registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ct130Cap(cAlias,nReg,nOpc)

Local aSaveArea	:= GetArea()
Local cCodMasC
Local cDescMasc
Local oSize
Local nLin		:= 0
Local nCol		:= 0
Local bOk, bCancel

Private oDescCta
Private aTELA[0][0],aGETS[0]
Private aCols 		:= {}
Private aHeader		:= {}
Private nUsado 		:= 0
Private nPosDig, nPosDesc, nPosSep
Private nMascEnt	:= 0
Private INCLUI      := (nOpc == 3)
Private ALTERA      := (nOpc == 4)

If nOpc == 3
	cCodMasc := CriaVar("CTM_CODIGO")
	cDescMasc:= CriaVar("CTM_DESCM")
	nMascEnt := 1
Else
	cCodMasc := CTM->CTM_CODIGO
	cDescMasc:= CTM->CTM_DESCM
	nMascEnt := CTM->CTM_IDENT
EndIf

c130aHead()
c130aCols(nOpc,cCodMasc)

DEFINE MSDIALOG oDlg TITLE STR0003 FROM 7.9,0 TO 37.5,80 OF oMainWnd //"Cambio Moedas Contabeis"

	oSize := FwDefSize():New(.T.,,,oDlg)

	oSize:AddObject("ENCHOICE",100,030,.T.,.T.)
	oSize:AddObject("GETDADOS",100,060,.T.,.T.)
	oSize:AddObject("BOTTOM",100,010,.T.,.T.)

	oSize:lProp := .T.

	oSize:Process()

	nLin := oSize:GetDimension("ENCHOICE","LININI")
	nCol := oSize:GetDimension("ENCHOICE","COLINI")

	DEFINE FONT oFnt	NAME "Arial" Size 10,15
	DEFINE FONT oFnt1	NAME "Arial" Size 10,12 Bold

	@ nLin + 002, nCol + 004 SAY STR0016 PIXEL  //"Codigo Mascara: "
	@ nLin + 000, nCol + 062	MSGET cCodMasc  Picture "@!" SIZE 020,08 Valid FreeForUse("CTM",cCodMasc);
				.And. Ctb130Val(cCodMasc) .And. FreeForUse("CTM",cCodMasc) When (nOpc == 3) OF oDlg PIXEL

	@ nLin + 014, nCol + 004 SAY STR0025 PIXEL	//"Descricao da Mascara"
	@ nLin + 012, nCol + 062 MSGET cDescMasc Picture "@!" SIZE 150,08;
				Valid !Empty(cDescMasc) When (nOpc == 3 .Or. nOpc == 4) Of oDlg PIXEL

	@ nLin + 000, nCol + 225 TO oSize:GetDimension("ENCHOICE","LINEND"),oSize:GetDimension("ENCHOICE","COLEND") LABEL STR0049 OF oDlg PIXEL COLOR CLR_RED //"Utilizada em"
	@ nLin + 006, nCol + 230 	Radio oRadio VAR nMascEnt;
				ITEMS 	STR0050, CtbSayApro("CTT"), CtbSayApro("CTD"),; //"Conta Contabil"
						CtbSayApro("CTH"), STR0051; //"Outros"
				SIZE 80,10 OF oDlg

	oGet := MSGetDados():New(oSize:GetDimension("GETDADOS","LININI"),;
									oSize:GetDimension("GETDADOS","COLINI"),;
									oSize:GetDimension("GETDADOS","LINEND"),;
									oSize:GetDimension("GETDADOS","COLEND"),;
									nOpc,"Ct130Linok","CT130Tudok","+CTM_SEGMEN",.T., , , , , , , ,"ct130Exibe")

	@ oSize:GetDimension("BOTTOM","LININI") + 000, oSize:GetDimension("BOTTOM","COLINI") + 000 TO;
				 oSize:GetDimension("BOTTOM","LINEND"),oSize:GetDimension("BOTTOM","COLEND") LABEL STR0015 OF oDlg PIXEL COLOR CLR_RED
	@ oSize:GetDimension("BOTTOM","LININI") + 008, oSize:GetDimension("BOTTOM","COLINI") + 005 SAY oDescCta PROMPT space(50) PIXEL FONT oFnt COLOR CLR_HBLUE

	ct130Exibe()

	bOk     := {|| If(nOpc = 3 .or. nOpc = 4 .or. nOpc = 5, If(Ct130Tudok(nOpc) .and. C130Grava(cCodMasc, nOpc, cDescMasc), oDlg:End(), nil), oDlg:End())}
	bCancel := {|| oDlg:End()}
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, bOk, bCancel)

RestArea(aSaveArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³C130aHead  ³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Criacao da aHeader - Getdados - Estrutura da Conta         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³C130aHead()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA130                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function c130aHead()

Local aSaveArea := GetArea()

dbSelectArea("Sx3")
dbSetOrder(1)

dbseek("CTM")
While !EOF() .And. (X3_ARQUIVO == "CTM")
	IF X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL
		If Trim(X3_CAMPO) != "CTM_CODIGO"
			nUsado++
			AADD(aHeader, {TRIM(X3Titulo()), X3_CAMPO, X3_PICTURE,;
						 X3_TAMANHO, X3_DECIMAL, X3_VALID,;
						 X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
		ENDIF
	EndIf
	dBSkip()
EndDO

RestArea(aSaveArea)

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³C130aCols  ³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria aCols da Getdados - Estrutura Contabil                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³C130aCols(nOpc,cCodMasc)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA130                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1=Numero da opcao escolhida                            ³±±
±±³          ³ ExpC1=Codigo da Mascara                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function c130aCols(nOpc,cCodMasc)

Local nCont := 1
Local aSaveArea := GetArea()

nPosDig  := Ascan(aHeader, {|x|Alltrim(x[2]) = "CTM_DIGITO"})
nPosDesc := Ascan(aHeader, {|x|Alltrim(x[2]) = "CTM_DESC"})
nPosSep  := Ascan(aHeader, {|x|Alltrim(x[2]) = "CTM_SEPARA"})

aCols := {}

dbSelectArea("CTM")
dbSetOrder(1)
If (nOpc == 2 .Or. nOpc == 4 .Or. nOpc == 5)  // Visualiza / Altera / Exclui
	dbSeek(xFilial()+cCodMasc)
	While !Eof() .And. xFilial() == CTM->CTM_FILIAL .And. CTM_CODIGO == cCodMasc

		AADD(aCols,Array(nUsado+1))
		aCols[nCont][1]		:= CTM->CTM_SEGMEN
		aCols[nCont][nPosDig]	:= CTM->CTM_DIGITO
		aCols[nCont][nPosDesc]	:= CTM->CTM_DESC
		aCols[nCont][nPosSep]	:= CTM->CTM_SEPARA
		aCols[nCont][nUsado+1]	:= .F.

		nCont++
		dbSkip()

	EndDo
ElseIf nOpc == 3				// Inclusao
	AADD(aCols,Array(nUsado+1))
	dbSelectArea("Sx3")
	dbSetOrder(1)
	dbSeek("CTM")
	nUsado:=0
	While !EOF() .And. (x3_arquivo == "CTM")
		IF X3USO(x3_usado) .and. cNivel >= x3_nivel
			If Trim(X3_CAMPO) != "CTM_CODIGO"
				nUsado++
				IF x3_tipo == "C"
					IF ExistIni(X3_CAMPO)
						aCOLS[1][nUsado]:=InitPad(SX3->X3_RELACAO)
					ELSE
						aCOLS[1][nUsado]:=SPACE(x3_tamanho)
					EndIF
				ELSEIF x3_tipo == "N"
					aCOLS[1][nUsado] := 0
				ELSEIF x3_tipo == "D"
					aCOLS[1][nUsado] := dDataBase
				ELSEIF x3_tipo == "M"
					aCOLS[1][nUsado] := ""
				ELSE
					aCOLS[1][nUsado] := .F.
				ENDIF
				If x3_context == "V"
						aCols[1][nUsado] := CriaVar(allTrim(x3_campo))
				Endif
			ENDIF
		EndIf
		dbSkip()
	EndDo
	aCols[1][nUsado+1]	:= .F.
	aCols[1][1]		:= "01"
EndIf

RestArea(aSaveArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³C130Grava  ³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao dos dados - Estrutura Conta                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³C130Graa(cCodMasc,nOpc,cDescMasc)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA130                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1=Codigo da Mascara                                    ³±±
±±³          ³ ExpN1=Numero da Opcao escolhida                            ³±±
±±³          ³ ExpC2=Descricao da Mascara                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function c130Grava(cCodMasc, nOpc, cDescMasc)

Local lRet       := .T.
Local aSaveArea  := GetArea()
Local nCont

BEGIN TRANSACTION

If nOpc == 3 .Or. nOpc == 4			// Inclusao / Alteracao
	dbSelectArea("CTM")
	dbSetOrder(1)
	For nCont := 1 To Len(aCols)
		If aCols[nCont][nUsado+1] == .F. .And. !Empty(aCols[nCont][nPosDig])
			If !dbSeek(xFilial()+cCodMasc+aCols[nCont][1])
				RecLock("CTM",.T.)
				Replace CTM_CODIGO	With cCodMasc
				Replace CTM_FILIAL	With xFilial()
				Replace CTM_SEGMEN	With aCols[nCont][1]
				Replace CTM_DESCM		With cDescMasc
			Else
				RecLock("CTM",.F.)
			EndIf
			Replace CTM_IDENT		With nMascEnt
			Replace CTM_DESCM		With cDescMasc
			Replace CTM_DIGITO		With StrZero(Val(aCols[nCont][nPosDig]),2)
			Replace CTM_DESC		With aCols[nCont][nPosDesc]
			Replace CTM_SEPARA		With aCols[nCont][nPosSep]
			MsUnlock()
		Else
			If dbSeek(xFilial()+cCodMasc+aCols[nCont][1])
				RecLock("CTM",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
		EndIf
	Next nCont
ElseIf nOpc == 5				// Exclusao
	dbSelectArea("CTM")
	dbSetOrder(1)
	dbGotop()
	If MsSeek(xFilial()+cCodMasc)
		While !Eof() .And. xFilial() == CTM->CTM_FILIAL .And. cCodMasc == CTM->CTM_CODIGO
			RecLock("CTM",.F.,.T.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf
EndIf

RestArea(aSaveArea)

// Ponto de entrada depois da gravação.
IF ExistBlock( "Ct130Grv" )
	ExecBlock( "Ct130Grv" , .F. , .F. , {nOpc} )
Endif

// Integração via Mensagem Única
If FWHasEAI('CTB130EST', .T.,, .T.)
	Private M->CTM_CODIGO := cCodMasc
	Private M->CTM_DESCM  := cDescMasc
	Private M->CTM_IDENT  := nMascEnt

	aEaiRet := FWIntegDef('CTB130Est',,,, 'CTB130Est')
	If !aEaiRet[1]
		Help(" ", 1, "HELP", STR0081, STR0082, 3, 1) //#"Erro EAI"#"Problemas na integração EAI. Transação não executada."
		DisarmTransaction()
		lRet := .F.
	Endif
Endif

END TRANSACTION

RestArea(aSaveArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CT130LinOk ³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao Linha da getdados - Estrutura Conta              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ct130LinOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.0                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA130                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ct130LinOk()

Local nCont
Local nTamMax 	:= 0
Local nTamConta := 0
Local lRet		:= .T.

If nMascEnt = 1
	nTamMax := Len(CriaVar("CT1_CONTA"))
ElseIf nMascEnt = 2
	nTamMax := Len(CriaVar("CTT_CUSTO"))
ElseIf nMascEnt = 3
	nTamMax := Len(CriaVar("CTD_ITEM"))
ElseIf nMascEnt = 4
	nTamMax := Len(CriaVar("CTH_CLVL"))
Else
	nTamMax := 70
Endif

For nCont := 1 To n
	If !aCols[nCont][nUsado+1]
		nTamConta += Val(aCols[nCont][nPosDig])
	EndIf
Next nCont

If nTamConta > nTamMax
	Help(" ",1,"CT130MAIOR")
	lRet := .f.
EndIf

IF lRet
	IF ExistBlock("Ctb130lOk") .And. !ExecBlock( "Ctb130lOk", .F. , .F. )
		lRet := .F.
	Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CT130Tudok ³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da getdados - Estrutura da Conta                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ct130Tudok()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA130                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ct130Tudok(nOpc)

Local nCont
Local nTamMax 	:= Len(CriaVar("CT1_CONTA"))
Local nTamConta := 0
Local lRet		:= .T.

If nOpc = 3 .or. nOpc = 4
	For nCont := 1 To Len(aCols)
		If !aCols[nCont][nUsado+1]
			nTamConta += Val(aCols[nCont][nPosDig])
		EndIf
	Next nCont

	If nTamConta > nTamMax
		Help(" ",1,"CT130MAIOR")
		lRet := .f.
	EndIf

	IF lRet
		IF ExistBlock("Ctb130TOk") .And. !ExecBlock( "Ctb130TOk", .F. , .F. )
			lRet := .F.
		Endif
	Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CT130Exibe ³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe Estrutura da conta                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ct130Exibe()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA130                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ct130Exibe()

Local nCont
Local cConta := ""

For nCont := 1 To Len(aCols)
	If !aCols[nCont][nUsado+1]
		cConta += Replicate("9",Val(aCols[nCont][nPosDig]))
		cConta += aCols[nCont][nPosSep]
    EndIf
Next nCont

IF Type("oDescCta")="O"
	oDescCta:SetText(cConta)
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CT130Dig   ³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida numero digitos da estrutura da conta                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct130Dig()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA130                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ct130Dig()

Local nCont
Local cConta 	:= ""
Local nTamMax 	:= Len(CriaVar("CT1_CONTA"))
Local nTamConta := 0
Local lRet		:= .T.

For nCont := 1 To Len(aCols)
	If !aCols[nCont][nUsado+1]
		If nCont == n
			cConta 		+= Replicate("9",Val(m->ctm_digito))
			nTamConta	+= Val(m->ctm_digito)
			cConta 		+= aCols[nCont][nPosSep]
		Else
			cConta 		+= Replicate("9",Val(aCols[nCont][nPosDig]))
			nTamConta	+= Val(aCols[nCont][nPosDig])
			cConta 		+= aCols[nCont][nPosSep]
		EndIf
	EndIf
Next nCont

If nTamConta > nTamMax
	HElp(" ",1,"CT130MAIOR")
	lRet := .F.
EndIf

If lRET
	IF Type("oDescCta")="O"
		oDescCta:SetText(cConta)
	Endif
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CT130Sep   ³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida separador da estrutura da conta                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct130Sep()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA130                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ct130Sep()

Local nCont
Local cConta 	:= ""
Local nTamMax	:= Len(CriaVar("CT1_CONTA"))
Local nTamConta	:= 0
Local lRet		:= .T.

For nCont := 1 To Len(aCols)
	If !aCols[nCont][nUsado+1]
		If nCont == n
			cConta 		+= Replicate("9",Val(aCols[nCont][nPosDig]))
			nTamConta 	+= Val(aCols[nCont][nPosDig])
			cConta 		+= m->ctm_separa
		Else
			cConta 		+= Replicate("9",Val(aCols[nCont][nPosDig]))
			nTamConta 	+= Val(aCols[nCont][nPosDig])
			cConta 		+= aCols[nCont][nPosSep]
		EndIf
	EndIf
Next nCont

If nTamConta > nTamMax
	Help(" ",1,"CT130MAIOR")
	lRet := .F.
EndIf

If lRet
	IF Type("oDescCta")="O"
		oDescCta:SetText(cConta)
	Endif
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CT130Val   ³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida inclusao de codigo da mascara de contas             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb130Val(cCodMasc)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA130                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Expc1 = Codigo da Mascara                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ctb130Val(cCodMasc)

Local aSaveArea:= GetArea()
Local lRet		:= .T.

IF Empty(cCodMasc)
	lRet := .F.
EndIF

If lRet
	dbSelectArea("CTM")
	dbSetOrder(1)
	If dbSeek(xFilial()+cCodMasc)
		Help(" ",1,"JAEXISMASC")
		lRet := .F.
	EndiF
EndIf

RestArea(aSaveArea)

Return lRet


*****************************************************************
*                                                               *
*					Estrutura de CUSTOS                              *
*                                                               *
*****************************************************************
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctb130Apro³ Autor ³ Pilar S. Albaladejo   ³ Data ³24.11.00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro da Estrutura de Custos                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb130Apro()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA130                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FuncTion Ctb130Apro()

Local oDlg,oLbx
Local cVar:=""
Local nOpc := 0
Local aCampos := {}
Local cArqTmp := ""
Local cDbsExt := GetDBExtension()

aCampos:={{"NIVEL"    	, 	"C" 	, 02,0},;
			{	"DESCR"    	, 	"C" 	, 10,0},;
			{	"TAMANHO"	, 	"C" 	, 02,0},;
			{	"CTR_SALDO"	,	"C"	, 01,0},;
			{	"ALIAS"    	,  "C"   , 03,0}}

If _oCTBA130 <> Nil
	_oCTBA130:Delete()
	_oCTBA130 := Nil
Endif

_oCTBA130 := FWTemporaryTable():New( "cArqTmp" )
_oCTBA130:SetFields(aCampos)
_oCTBA130:AddIndex("1", {"NIVEL","DESCR"})

//------------------
//Criação da tabela temporaria
//------------------
_oCTBA130:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ "Importa" o arquivo TXT com a tabela dos Motivos de Baixa ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "cArqTmp" )

IF !file("SIGACTB.INI")
	nHdlCusto := MSFCreate("SIGACTB.INI",0)
	IF nHdlCusto == -1
		HELP(" ",1,"CTB_ERROR")
		Final("Erro F_"+str(ferror(),2)+" em SIGACTB.INI")
	Endif
	cTitCC		:= RetTitle("CTT_CUSTO",10)
	cTitItem		:= RetTitle("CTD_ITEM",10)
	cTitClasse	:= RetTitle("CTH_CLVL",10)
	cTamCC 		:= StrZero(Len(CriaVar("CTT_CUSTO")),2)
	cTamItem		:= StrZero(Len(CriaVar("CTD_ITEM")),2)
	cTamClVL		:= StrZero(Len(CriaVar("CTH_CLVL")),2)

	fWrite(nHdlCusto,"01"+cTitCC+cTamCC+"1CTT"+chr(13)+chr(10))
	fWrite(nHdlCusto,"02"+cTitItem+cTamItem+"2CTD"+chr(13)+chr(10))
	fWrite(nHdlCusto,"03"+cTitCLasse+cTamCLVL+"2CTH"+chr(13)+chr(10))
	fClose(nHdlCusto)
Endif

APPEND FROM SIGACTB.INI SDF
dbGoTop()

While .T.
	nOpc := 0
	DEFINE MSDIALOG oDlg FROM  70,1 TO 231,480 TITLE STR0001 PIXEL  // "Tabela de Motivos de Baixas"
	@ 7,2 LISTBOX oLbx  Var cVar FIELDS NIVEL,DESCR,TAMANHO,CTR_SALDO,ALIAS ;
	HEADER 	STR0018,STR0019,;	// "Nivel" # "Descricao"
			STR0020,STR0021,;	// "Tamanho" # "Contr Saldo"
			STR0022 COLSIZES 35,35,35,35,35;
	SIZE 205	, 65 OF oDlg PIXEL  ;
	ON DBLCLICK EditaCTB( oLbx )

	DEFINE SBUTTON FROM 07, 210 TYPE  2 ENABLE OF oDlg Action (nOpc:=0,oDlg:End())
	DEFINE SBUTTON FROM 22, 210 TYPE 11 ENABLE OF oDlg Action (nOpc:=1,oDlg:End()) //edita

	ACTIVATE MSDIALOG oDlg Centered

	if nOpc == 0
		exit
	ElseIf nOpc == 1
		EditaCTB( Nil )
	ElseIf nOpc == 2
		EditaCTB( Nil,nOpc )
	Elseif nOpc == 3
		EditaCTB( Nil,nOpc )
	ENdif
	dbgotop()
EndDo
dbSelectArea( "cArqTmp" )
FERASE("SIGACTB.INI")
Copy to SIGACTB.INI SDF

cArqTmp->(DbCloseArea())

//Apaga tabela temporaria do banco de dados
If _oCTBA130 <> Nil
	_oCTBA130:Delete()
	_oCTBA130 := Nil
Endif

ReadIniCtb(.T.)

Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ EDITACTB ³ Autor ³ Vinicius Barreira     ³ Data ³ 14/02/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Edita os campos do arquivo temporario                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EDITACTB(oLbx,nModo)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto lbx                                         ³±±
±±³          ³ ExpN1 =                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EDITACTB( oLbx,nModo )

Local aCampos   :=	{}
Local cNivel 	:= if(nModo <> 2,Field->NIVEL		, space(02) )
Local cDescrCTB:= if(nModo <> 2,Field->DESCR		, space(10) )
Local cTamanho  := if(nModo <> 2,Field->TAMANHO	, space(02) )
Local cSaldo 	:= if(nModo <> 2,Field->CTR_SALDO, space(01) )
Local cAlias	:= if(nModo <> 2,Field->ALIAS		, space(03) )
Local nOpc 		:= 0
Local nCont		:= 0
Local oDlg

aCampos:={ 	{"CTT_CUSTO"   ,"" ,"CTT"},;
			{"CT2_CCD"     ,"1","CTT"},;
			{"CT2_CCC"     ,"2","CTT"},;
			{"CTS_CTTINI"  ,"" ,"CTT"},;
			{"CTS_CTTFIM"  ,"" ,"CTT"},;
			{"CT5_CCD"		,"1","CTT"},;
			{"CT5_CCC"		,"2","CTT"},;
			{"CTD_ITEM"    ,"" ,"CTD"},;
			{"CT2_ITEMD"   ,"1","CTD"},;
			{"CT2_ITEMC"   ,"2","CTD"},;
			{"CTS_CTDINI"  ,"" ,"CTD"},;
			{"CTS_CTDFIM"  ,"" ,"CTD"},;
			{"CT5_ITEMD"	,"1","CTD"},;
			{"CT5_ITEMC"	,"2","CTD"},;
			{"CTH_CLVL"    ,"" ,"CTH"},;
			{"CT2_CLVLDB"  ,"1","CTH"},;
			{"CT2_CLVLCR"  ,"2","CTH"},;
			{"CTS_CTHINI"  ,"" ,"CTH"},;
			{"CTS_CTHFIM"  ,"" ,"CTH"},;
			{"CT5_CLVLDB"	,"1","CTH"},;
			{"CT5_CLVLCR"	,"2","CTH"},;
			{"CT9_CCD" ,"1","CTT"},;
			{"CT9_CCC" ,"2","CTT"},;
			{"CT9_ITEMD" ,"1","CTD"},;
			{"CT9_ITEMC" ,"2","CTD"},;
			{"CT9_CLVLDB","1","CTH"},;
			{"CT9_CLVLCR","2","CTH"},;
			{"CTJ_CCD","1","CTT"},;
			{"CTJ_CCC","2","CTT"},;
			{"CTJ_ITEMD","1","CTD"},;
			{"CTJ_ITEMC","2","CTD"},;
			{"CTJ_CLVLDB","1","CTH"},;
			{"CTJ_CLVLCR","2","CTH"},;
			{"B1_CC","","CTT"},;
			{"B1_ITEMCC","","CTD"},;
			{"B1_CLVL","","CTH"},;
			{"C1_CC","","CTT"},;
			{"C1_ITEMCTA","","CTD"},;
			{"C1_CLVL","","CTH"},;
			{"C7_CC","","CTT"},;
			{"C7_ITEMCTA","","CTD"},;
			{"C7_CLVL","","CTH"},;
			{"C2_CC","","CTT"},;
			{"C2_ITEMCTA","","CTD"},;
			{"C2_CLVL","","CTH"},;
			{"D1_CC","","CTT"},;
			{"D1_ITEMCTA","","CTD"},;
			{"D1_CLVL","","CTH"},;
			{"CQ_CC","","CTT"},;
			{"CQ_ITEMCTA","","CTD"},;
			{"CQ_CLVL","","CTH"},;
			{"CP_CC","","CTT"},;
			{"CP_ITEMCTA","","CTD"},;
			{"CP_CLVL","","CTH"},;
			{"CT_CUSTO","","CTT"},;
			{"CT_ITEMCC","","CTD"},;
			{"CT_CLVL","","CTH"},;
			{"D2_CCUSTO","","CTT"},;
			{"D2_ITEMCC","","CTD"},;
			{"D2_CLVL","","CTH"},;
			{"D3_CC","","CTT"},;
			{"D3_ITEMCTA","","CTD"},;
			{"D3_CLVL","","CTH"},;
			{"DE_CC","","CTT"},;
			{"DE_ITEMCTA","","CTD"},;
			{"DE_CLVL","","CTH"},;
			{"CTQ_CCORI","","CTT"},;
			{"CTQ_ITORI","","CTD"},;
			{"CTQ_CLORI","","CTH"},;
			{"CTQ_CCPAR","","CTT"},;
			{"CTQ_ITPAR","","CTD"},;
			{"CTQ_CLPAR","","CTH"},;
			{"CTQ_CCCPAR","","CTT"},;
			{"CTQ_ITCPAR","","CTD"},;
			{"CTQ_CLCPAR","","CTH"}}

nModo  := if( nModo == NIL, 0, nModo)

DEFINE MSDIALOG oDlg FROM  86,1 TO 280,400 TITLE STR0023 PIXEL  // "Edicao dos Niveis de Apropriacao"

@ 07, 04 TO 92, 154 LABEL STR0024 OF oDlg  PIXEL    // "Niveis de Apropriacao"
@ 16, 08 SAY STR0018    	SIZE 53, 07 OF oDlg PIXEL  // "Nivel"
@ 29, 08 SAY STR0019    	SIZE 53, 07 OF oDlg PIXEL  // "Descricao"
@ 43, 08 SAY STR0020  		SIZE 53, 07 OF oDlg PIXEL  // "Tamanho"
@ 56, 08 SAY STR0021  		SIZE 53, 07 OF oDlg PIXEL  // "Contr Saldo?"
@ 69, 08 SAY STR0022  		SIZE 53, 07 OF oDlg PIXEL  // "Arq Saldo"

@ 14, 68 MSGET cNivel    	SIZE 24, 10 OF oDlg PIXEL Picture "@!" When .F.
@ 27, 68 MSGET cDescrCTB 	SIZE 51, 10 OF oDlg PIXEL Valid !empty(cDescrCTB)
@ 40, 68 MSGET cTamanho 	SIZE 15, 10 OF oDlg PIXEL Picture "@!" When .F.

@ 53, 68 MSCOMBOBOX oSaldo VAR cSaldo ITEMS { STR0052, STR0053 } SIZE 30,10	PIXEL //"1=Sim"###"2=Nao"

@ 66, 68 MSGET cAlias		SIZE 15, 10 OF oDlg PIXEL Picture "@!" When .F.

DEFINE SBUTTON FROM 15,160 TYPE 1 ENABLE OF oDlg Action (nOpc:=1,oDlg:End())
DEFINE SBUTTON FROM 29,160 TYPE 2 ENABLE OF oDlg Action (nOpc:=0,oDlg:End())
ACTIVATE MSDIALOG oDlg Centered

If nOpc == 1

	If nModo == 2
		RecLock( "cArqTmp",.T. )
	Else
		RecLock( "cArqTmp" )
	EndIf
	
	If Field->DESCR <> cDescrCTB 
		If FwLibVersion() >= "20210517"
			Field->DESCR    := cDescrCTB
			A130EngSx(aCampos,cDescrCTB,cAlias) // Troca do titulo do campo
		Else
			MsgInfo(STR0083) //"Para alterar o título dos campos necessário atualizar a lib para versão igual ou superior à 20210517"
		EndIf
	EndIf		
	
	Field->CTR_SALDO:= cSaldo

	IF oLbx != Nil
		oLbx:Refresh()
	Endif

	dbSelectArea("cArqTmp")
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBA130SLD³ Autor ³ Wagner Mobile Costa   ³ Data ³ 20.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao na tabela de saldos contabeis - "SL"            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb130Sld()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Ctba130                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb130Sld()

Local cVar  	:= ""
Local aCols 	:= {}
Local oLbx
Local nOpca		:= 0
Local aResources := GetResources()

If SX5->(MsSeek(xFilial("SX5") + "SL"))
	While SX5->X5_FILIAL = xFilial("SX5") .And. SX5->X5_TABELA = "SL"
		Aadd(aCols, { 	Left(SX5->X5_CHAVE, 1), X5Descri(),;
						SX5->(Recno()), CtbLegRes(Left(SX5->X5_CHAVE, 1)) })
		SX5->(DbSkip())
	EndDo
Endif

DEFINE MSDIALOG oDlg FROM 70,1 TO 360,640 TITLE STR0027 PIXEL //"Tabela de saldos contabeis"
@20,0 	LISTBOX oLbx Var cVar FIELDS HEADER STR0028,STR0029,STR0037 COLSIZES 35,140; //"Saldo"###"Descricao" //"Legenda"
		SIZE ((oDlg:nRight - oDlg:nLeft) / 2) - 3,((oDlg:nBottom - oDlg:nTop) / 2) - 25 OF oDlg PIXEL

oLbx:SetArray(aCols)
oLbx:bLine := { || { 	If(Len(oLbx:aArray) = 0, " ", aCols[oLbx:nAt,1]),;
						If(Len(oLbx:aArray) = 0, Space(55), aCols[oLbx:nAt,2]),;
						If(Len(oLbx:aArray) = 0, "f5_verd",;
						LoadBitMap(aResources, aCols[oLbx:nAt,4])) } }

ACTIVATE 	MSDIALOG oDlg Centered;
			ON INIT EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()}, {||oDlg:End()},,;
					{ 	{ "BMPINCLUIR"	, { || Ctb130Man(1, aCols, oLbx, STR0030) }, STR0030 },; //"Incluir"###"Incluir"
						{ "EDIT"		, { || Ctb130Man(2, aCols, oLbx, STR0031) }, STR0031 },; //"Editar"###"Editar"
						{ "EXCLUIR", { || Ctb130Man(3, aCols, oLbx, STR0032) }, STR0032 } }) //"EXCLUIR"###"Excluir"###"Excluir"

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb130Man ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 20.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao na tabela de saldos contabeis - "SL"            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb130Man()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Ctba130                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao de edicao [INCLUSAO/EDICAO/EXCLUSAO]         ³±±
±±³          ³ ExpA1 = Matriz com os saldos contabeis                     ³±±
±±³          ³ ExpO1 = Objeto de LIST BOX de manutencao dos saldos        ³±±
±±³          ³ ExpC1 = Descricao da acao sendo executada INCLUIR,ALTERAR..³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb130Man(nOpcao, aCols, oLbx, cAcao)

Local nOpc 		:= 0, oDlg
Local nCols 	:= If(nOpcao = 1, 0, oLbx:nAt)
Local cCod130 	:= If(nOpcao = 1, " ", aCols[nCols][1])
Local cDesc130	:= If(nOpcao = 1, Space(Len(X5Descri())), aCols[nCols][2])
Local aCores	:= Ct130CorSl()

Local aItens	:= {}, nItens
Local lSldInt	:= Ctb130SldInt(cCod130)
Local cResource := CtbLegRes(cCod130)
Local cCor130	:= ""

For nItens := 1 To Len(aCores)
	Aadd(aItens, AllTrim(Str(nItens, 2)) + "-" + aCores[nItens][2] )
Next

nItens := Ascan(aCores, { |x| x[1] = cResource })
If nItens = 0
	cCor130 := aItens[1]
Else
	cCor130 := aItens[nItens]
Endif

DEFINE 	MSDIALOG oDlg FROM  86,1 TO 205,400;
		TITLE STR0033 + cAcao PIXEL //"Edicao dos Saldos Contabeis - "

@ 05, 04 TO 55, 154 LABEL STR0034 OF oDlg PIXEL //"Saldo contabil"

@ 14, 08 SAY STR0035    	SIZE 53, 07 OF oDlg PIXEL //"Codigo"
@ 27, 08 SAY STR0029		SIZE 53, 07 OF oDlg PIXEL //"Descricao"
@ 40, 08 SAY STR0037  		SIZE 53, 07 OF oDlg PIXEL

@ 12, 68 MSGET cCod130		SIZE 18, 10 OF oDlg PIXEL Picture "!";
		 When nOpcao = 1 .And. ! lSldInt;
		 Valid 	! Empty(cCod130) .And. If(Ascan(aCols, { |x| x[1] = cCod130} ) > 0,;
		 		(HELP(" ", 1, "JAGRAVADO"), .F.), .T.)
@ 25, 68 MSGET cDesc130	SIZE 51, 10 OF oDlg PIXEL Valid ! Empty(cDesc130);
 		 When !lSldInt .And. nOpcao != 3

@ 38, 68 	MSCOMBOBOX oCores VAR cCor130 ITEMS aItens SIZE 70,08	PIXEL;
			Valid Ctb130ChkCor(	cCor130, aItens, aCores, aCols, If(nOpcao = 1, 0, aCols[nCols][3]));
			When nOpcao != 3

DEFINE 	SBUTTON oBtnOk FROM 07,160 TYPE 1 ENABLE OF oDlg;
		Action (nOpc:=1,If(Ctb130ChkCor(	cCor130, aItens, aCores, aCols,;
						 If(nOpcao = 1, 0, aCols[nCols][3])), oDlg:End(), nOpc:=0))
DEFINE 	SBUTTON oBtnCn FROM 21,160 TYPE 2 ENABLE OF oDlg Action (nOpc:=0,oDlg:End())
ACTIVATE MSDIALOG oDlg Centered

If nOpc == 1
	//Se for exclusao e saldo interno, nao gravar nada.
	If nOpcao == 3 .And. lSldInt
		Return .T.
	Else
		If nCols = 0
			Aadd(aCols, { cCod130, cDesc130, 0, "" })
			nCols := Len(aCols)
		Else
			aCols[nCols][1] := cCod130
			aCols[nCols][2] := cDesc130
		Endif

		If nOpcao = 1
			FwPutSX5("", "SL", aCols[nCols][1])
		Endif

		// Procuro a cor escolhida na matriz de escolhas

		lSldInt	:= Ctb130SldInt(cCod130, .F.)
		nItens 	:= Ascan(aItens, cCor130)
		cCor130 := ""

		// Caso seja saldo interno e tenha alterado a cor ou nao for saldo interno
		// Eh gravado nas 11 posicoes final do X5_DESCRI o resource da legenda

		If (lSldInt .And. cResource <> aCores[nItens][1]) .Or. ! lSldInt
			cCor130 := aCores[nItens][1]
		Endif

		If nOpcao < 3
			If cIdioma  == "PT" //"PORTUGUESE"
				//FwPutSX5(cFlavour, cTabela, cChave, cTextoPor, cTextoEng, cTextoEsp, cTextoAlt)
				FwPutSX5("", "SL", aCols[nCols][1], aCols[nCols][2])
			ElseIf cIdioma == "ES" //"SPANISH"
				FwPutSX5("", "SL", aCols[nCols][1],,,aCols[nCols][2])
			ElseIf cIdioma == "EN" //"ENGLISH"
				FwPutSX5("", "SL", aCols[nCols][1],,aCols[nCols][2])
			Endif
			
		ElseIf SX5->(DbSeek(xFilial() + "SL" + aCols[nCols][1]))
			RecLock("SX5", .F.)
			SX5->(DbDelete())
			SX5->(MsUnLock())
		Endif

		aCols[nCols][3] := SX5->(Recno())

		If nOpcao <> 3 .And. ! Empty(cCor130)
			FwPutSX5("", "SM", aCols[nCols][1], cCor130)

		ElseIf SX5->(DbSeek(xFilial() + "SM" + aCols[nCols][1]))
			RecLock("SX5", .F.)
			SX5->(DbDelete())
			SX5->(MsUnLock())
		Endif
		
		aCols[nCols][4] := CtbLegRes(aCols[nCols][1])

		If nOpcao = 3				// Na exclusao atualizo diretamente a matriz do objeto
			oLbx:aArray := {}		// Para atualiza a lista
			For nOpc := 1 To Len(aCols)
				If nOpc # nCols
					Aadd(oLbx:aArray, aCols[nOpc])
				Endif
			Next
			aCols := Aclone(oLbx:aArray)
			oLbx:nAt --
			If oLbx:nAt = 0
				oLbx:nAt := 1
			Endif
		Else
			Asort(aCols,,, { |x,y| X[1] < Y[1] })				// Reordeno a matriz na inclusao
			oLbx:nAt := Ascan(aCols, { |x| x[1] = cCod130 })	// Posiciono no item incluido
			oLbx:aArray := aCols								// Atualizo o list
		Endif
		oLbx:Refresh()
	EndIf
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb130SldInt³ Autor ³ Wagner Mobile Costa ³ Data ³ 20.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna se o codigo eh de saldo interno                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb130Man()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lPar1 = Indica se eh ou nao um saldo interno               ³±±
±±³          ³ lPar2 = Indica se apresenta ou nao mensagem                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SigaCtb                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do saldo sendo verificado                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb130SldInt(cSaldo, lMessage)

Local lRet := .F.

DEFAULT lMessage := .T.

If Left(cSaldo, 1) $ C_SALDOSINTERNOS
	lRet := .T.
	If lMessage
		ApMsgAlert(STR0036) //"Saldo interno do modulo, nao podendo ser editado !"
	Endif
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb130ChkCor³ Autor ³ Wagner Mobile Costa ³ Data ³ 20.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna se o codigo eh de saldo interno                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb130ChkCor(ParC1, ParA1, ParA2, ParA3, ParN1)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ParC1 = Cor escolhida na digitacao 1=Amarelo,2=Azul        ³±±
±±³          ³ ParA1 = Itens de escolha do ComboBox                       ³±±
±±³          ³ ParA2 = Array com { { "RESOURCE", Descricao da cor } }     ³±±
±±³          ³ ParA3 = Array conteudo tabela de saldos para checagem      ³±±
±±³          ³ ParN1 = Array conteudo tabela de saldos para checagem      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SigaCtb                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do saldo sendo verificado                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb130ChkCor(cCor130, aItens, aCores, aCols, nRecno)

Local lRet := .T.
Local nItens := Ascan(aItens, cCor130)
Local cResource
Local nCols

If nItens > 0
	cResource := aCores[nItens][1]
	If 	(nCols := Ascan(aCols, { |x| x[4] = cResource })) > 0 .And.;
	 	(aCols[nCols][3] <> nRecno)
		ApMsgAlert(STR0048) //"Cor de legenda ja escolhida ! Verifique !"
		lRet := .F.
	Endif
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³01/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aCTBA130 := {}
Local nX := 0

Local aRotina 	:= {	{ STR0006,"AxPesqui", 0 , 1,,.F.},;	 //"Pesquisar"
							{ STR0007,"Ct130Cap", 0 , 2},;  //"Visualizar"
							{ STR0008,"Ct130Cap", 0 , 3},;  //"Incluir"
							{ STR0009,"Ct130Cap", 0 , 4},;  //"Alterar"
							{ STR0010,"Ct130Cap", 0 , 5},; //"Excluir"
                            { STR0007,"AxVisual", 0 , 2},;  //"Visualizar"
                            { STR0008,"C130GrpInc", 0 , 3},;  //"Incluir"
						    { STR0009,"C130GrpAlt", 0 , 4},;  //"Alterar"
						    { STR0010,"C130GrpDel", 0 , 5},;   //"Excluir"
                            { STR0008,"CtbBookInc", 0 , 3},;  //"Incluir"
						    { STR0009,"CtbBookAlt", 0 , 4},;  //"Alterar"
						    { STR0010,"CtbBookDel", 0 , 5} }  //"Excluir"

IF ExistBlock( "CTESTBUT" )
	aCTBA130 := ExecBlock( "CTESTBUT",.F.,.F.,aRotina)

	IF ValType(aCTBA130) == "A" .AND. Len(aCTBA130) > 0
		FOR nX := 1 to len(aCTBA130)
			aAdd(aRotina, aCTBA130[nX])
		NEXT
	ENDIF
ENDIF

Return(aRotina)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ C130GrpInc  ³ Autor ³ José Lucas         ³ Data ³ 15/02/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclusão de Grupo ou Natureza Conatbil.		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ctba040Inc(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GENERICO                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C130GrpInc(cAlias,nReg,nOpc)
LOCAl nY 	:= 0
LOCAL nOpcA := 0
LOCAL cAliasCTR := "CTR"

PRIVATE aCposHistor := {}

DEFAULT nOpc := 3

nOpcA := AxInclui(cAlias,nReg,nOpc,,,,"Ct130GrpOk(3)")

If nOpcA == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Histórico de Alterações na tabela CW4.                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3
		CTBGrvHist(xFilial("CTR"),"CTR"		,,(cAliasCTR)->CTR_GRUPO,ValType((cAliasCTR)->CTR_GRUPO),"CTR_GRUPO",""       ,(cAliasCTR)->CTR_GRUPO,nOpc)
		//		   cFilTabela	 ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo             ,cCampo,cValorAnt,cValorNovo   ,nOpc)
	Else
		For nY := 1 To Len(aCposHistor)
			aCposHistor[nY][3] := (cAliasCTR)->&(EVAL(bCampo,nY))
				If aCposHistor[nY][2] <> aCposHistor[nY][3]
					CTBGrvHist(xFilial("CTR"),"CTR"     ,,(cAliasCTR)->CTR_GRUPO,ValType(aCposHistor[nY][1]),aCposHistor[nY][1],aCposHistor[nY][2],aCposHistor[nY][3],nOpc)
					//           cFilTabela	 ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo                 ,cCampo            ,cValorAnt         ,cValorNovo        ,nOpc)
       			EndIf
   		Next nY
	EndIf
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ C130GrpAlt  ³ Autor ³ Jose Lucas         ³ Data ³ 15/02/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alteracao de Grupos ou Natureza Contabil.		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C130GrpAlt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GENERICO                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C130GrpAlt(cAlias,nReg,nOpc)
LOCAL nY 	 := 0
LOCAL bCampo := {|nCPO| Field(nCPO)}
LOCAL nOpcA  := 0
LOCAL cAliasCTR := "CTR"

PRIVATE aCposHistor := {}

DEFAULT nOpc := 4

nOpcA := AxAltera(cAlias,nReg,nOpc,,,,,"Ct130GrpOk(4)")

If nOpcA == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Histórico de Alterações na tabela CW4.                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3
		CTBGrvHist(xFilial("CTR"),"CTR"		,,(cAliasCTR)->CTR_GRUPO,ValType((cAliasCTR)->CTR_GRUPO),"CTR_GRUPO",""       ,(cAliasCTR)->CTR_GRUPO,nOpc)
		//		   cFilTabela	 ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo             ,cCampo,cValorAnt,cValorNovo   ,nOpc)
	Else
		For nY := 1 To Len(aCposHistor)
			aCposHistor[nY][3] := (cAliasCTR)->&(EVAL(bCampo,nY))
				If aCposHistor[nY][2] <> aCposHistor[nY][3]
					CTBGrvHist(xFilial("CTR"),"CTR"     ,,(cAliasCTR)->CTR_GRUPO,ValType(aCposHistor[nY][1]),aCposHistor[nY][1],aCposHistor[nY][2],aCposHistor[nY][3],nOpc)
					//           cFilTabela	 ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo                 ,cCampo            ,cValorAnt         ,cValorNovo        ,nOpc)
       			EndIf
   		Next nY
	EndIf
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ C130GrpDel  ³ Autor ³ Jose Lucas         ³ Data ³ 15/02/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclusao de Grupos ou Natureza Contabil.		  		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C130GrpDel(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GENERICO                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C130GrpDel(cAlias,nReg,nOpc)
Local aSaveArea:= GetArea()
LOCAL nOpcA 	:= 0
Local lRet		:= .T.
Local oDlg
Local bCampo
Local i
Local cAliasCTR := "CTR"
Local aSize 	:= {}
Local aObjects  := {}
Local aInfo 	:= {}
Local aPosObj 	:= {}
PRIVATE aCposHistor := {}

DEFAULT nReg := (cAlias)->(Recno())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Variaveis de Memoria                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
bCampo := {|nCPO| Field(nCPO) }
FOR i := 1 TO FCount()
	M->&(EVAL(bCampo,i)) := FieldGet(i)
NEXT i

Private aTELA[0][0],aGETS[0]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para processamento dos Gets          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbSetOrder(1)
If !SoftLock(cAlias)
	Return
EndIf

aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .t., .t. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
ENChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0056), ,aPosObj[1])

nOpca := 1
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},;
										 {|| nOpca := 1,oDlg:End()})

If nOpcA == 2
	BEGIN TRANSACTION
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta o Item do Cadastro                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAlias)
	MsGoto(nReg)
	RecLock(cAlias,.F.,.T.)
	dbDelete()
	MsUnlock()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Histórico de Alterações na tabela CW4.         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CTBGrvHist(xFilial("CTR"),"CTR"     ,       ,(cAliasCTR)->CTR_GRUPO,ValType((cAliasCTR)->CTR_GRUPO),"CTR_GRUPO",(cAliasCTR)->CTR_GRUPO,""        ,nOpc)
	//		   cFilTabela	 ,cEntidade ,cCodigo,cGrupo        ,cTipoCampo             ,cCampo     ,cValorAnt     ,cValorNovo,nOpc)
	END TRANSACTION
EndIf
MsUnlockAll()
MsGoTo(nReg)
RestArea(aSaveArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ C130GrpAlt  ³ Autor ³ Jose Lucas         ³ Data ³ 15/02/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validação prévia do Grupo ou Natureza Contabil.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ct130GrpOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GENERICO                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ct130GrpOk(nOpc)
LOCAL nY := 0
LOCAL bCampo := {|nCPO| Field(nCPO) }
LOCAL lCTA130TOK := ExistBlock("CTA130TOK")
LOCAL cAliasCTR := "CTR"

DEFAULT nOpc := 3

If nOpc == 3
	If ! ExistChav("CTR", M->CTR_GRUPO)
		Return .F.
	EndIf
Endif

For nY := 1 To FCount()
	AADD(aCposHistor,{(cAliasCTR)->(FieldName(nY)),(cAliasCTR)->&(EVAL(bCampo,nY)),""})
Next nY

If lCTA130TOK
	If ExecBlock("CTA130TOK",.F.,.F.,nOpc)
		Return .F.
	Endif
EndIf
Return( .T. )


//-------------------------------------------------------------------
/*/{Protheus.doc} Ct130CorSl
Centraliza Legenda e cores de Saldo

@author Eduardo.flima
@since 20/09/2017
@version P12.1.17
/*/
//-------------------------------------------------------------------

Function Ct130CorSl()
Local aCores	:= { 	{ "f5_null", STR0047 },; //Amarelo, Branco
						{ "f5_amar", STR0038 },; //Amarelo, Amarelo
						{ "f5_azul", STR0039 },; //Amarelo, Azul
						{ "f5_cinz", STR0040 },; //Amarelo, Cinza
						{ "f5_lara", STR0041 },; //Amarelo, Laranja
						{ "f5_marr", STR0042 },; //Amarelo, Marron
						{ "f5_pink", STR0043 },; //Amarelo, Rosa
						{ "f5_pret", STR0044 },; //Amarelo, Preto
						{ "f5_verd", STR0045 },; //Amarelo, Verde
						{ "f5_verm", STR0046 },; //Amarelo, Vermelho
						{ "f7_amar", STR0054 },;//Vermelho, Amarelo
						{ "f7_blue", STR0055 },;//Vermelho, Azul
						{ "f7_cinz", STR0056 },;//Vermelho, Cinza
						{ "f7_lara", STR0057 },;//Vermelho, Laranja
						{ "f7_marr", STR0058 },;//Vermelho, Marron
						{ "f7_null", STR0059 },;//Vermelho, Branco
						{ "f7_pink", STR0060 },;//Vermelho, Pink
						{ "f7_pret", STR0061 },;//Vermelho, Preto
						{ "f7_verd", STR0062 },;//Vermelho, Verde
						{ "f7_verm", STR0063 },;//Vermelho, Vermelho
					   	{ "f10_amar", STR0064 },;//Verde, Amarelo
						{ "f10_azul", STR0065 },;//Verde, Azul
						{ "f10_cinz", STR0066 },;//Verde, Cinza
						{ "f10_lara", STR0067 },;//Verde, Laranja
						{ "f10_marr", STR0068 },;//Verde, Marron
						{ "f10_null", STR0069 },;//Verde, Branco
						{ "f10_pink", STR0070 },;//Verde, Pink
						{ "f10_pret", STR0071 },;//Verde, Preto
						{ "f10_verd", STR0072 },;//Verde, Verde
						{ "f10_verm", STR0073 },;//Verde, Vermelho
						{ "f12_amar", STR0074 },;//Azul, Amarelo
						{ "f12_azul", STR0075 },;//Azul, Azul
						{ "f12_cinz", STR0076 },;//Azul, Cinza
						{ "f12_lara", STR0077 },;//Azul, Laranja
						{ "f12_marr", STR0078 },;//Azul, Marron
						{ "f12_pret", STR0079 } }//Azul, Preto
Return aCores


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  A130EngSx  		³TOTVS SA            º Data ³  28/12/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chama as funções EngSX se o release da versão for 12.1.017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ A130EngSx                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/	
Static Function A130EngSx(aCampos,cDescrCTB,cAlias)

Local nCont      := 0
Local cTipo      := ""
Local cCampo     := ""
Local cTitulCTB  := ""
Local cDescCamp  := ""
Local cDescCompl := ""

For nCont := 1 to len(aCampos)

	cCampo    := aCampos[nCont][1]
	cTipo     := aCampos[nCont][2]
	cDescCamp := FWSX3Util():GetDescription( cCampo ) 

	If Subs(cCampo,1,3)== 'CTS'
		If Subs(cCampo,8,3) == 'INI'
			cDescCompl := " Ini"
		ElseIf Subs(cCampo,8,3) == 'FIM'
			cDescCompl:= " Final"
		Endif
	Else
		If cTipo == "1"
			cDescCompl := " Deb"
		Elseif cTipo == "2"
			cDescCompl := " Cred"
		Else
			cDescCompl := " "
		Endif
	Endif

	cTitulCTB := Alltrim(cDescrCTB) + cDescCompl

	If aCampos[nCont][3] == cAlias
		FWSX3Util():UpdateDescX3({cCampo},cTitulCTB,cDescCamp)
	Endif

Next nCont

Return()
