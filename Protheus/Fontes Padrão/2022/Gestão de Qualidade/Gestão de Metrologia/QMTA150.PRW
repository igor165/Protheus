//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ IMPORTANTE: As funcoes a150calRR e a150CurRR dever„o ter mais³
//³ um parƒmetro que ser  um array que armazenar  os valores dos ³
//³ resultados de REPRE/REPRO e este array de resultados dever   ³
//³ ser passado por parƒmetro.                                   ³
//³                                                              ³
//³ Ap¢s a altera‡„o, a vari vel PRIVATE aFim, declarada na      ³
//³ fun‡„o QMTA150 dever  ser retirada.                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

#include "qmta150.ch"
#INCLUDE "FILEIO.CH"
#include "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QMTA150  ³ Autor ³ Wanderley Goncalves Jr³ Data ³ 22/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Ensaios de R&R                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³	MOTIVO DA ALTERACAO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Denis Martins ³04.12.00³Melhor³Validacao do campo QM4_NENSR, nao habili³±±
±±³              ³        ³      ³tar o quadro de ensaiadores qdo numero  ³±±
±±³              ³        ³      ³de medicoes for < 2 e > 15.             ³±±
±±³Denis Martins ³23.04.01³Melhor³Criacao de Tipo de Ensaio R&R - por Atri³±±
±±³              ³        ³      ³buto.                                   ³±±
±±³Denis Martins ³23.04.01³006123³Permitir realizar mais de um estudo de  ³±±
±±³              ³        ³      ³R&R por data.                           ³±±
±±³Denis Martins ³12.09.01³XXXXXX³Integracao com o Modulo PPAP.           ³±±
±±³Robson Ramiro ³26.03.02³META  ³Melhorias e ajustes com integracao PPAP ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()

Local aRotina := {	{OemToAnsi(STR0001),"AxPesqui"    , 0 , 1,,.F.},;    // "Pesquisar"
					{OemToAnsi(STR0002),"A150Visual"  , 0 , 2},;     // "Visualizar"
					{OemToAnsi(STR0003),"A150Inclui"  , 0 , 3},;     // "Incluir"
					{OemToAnsi(STR0004),"A150Altera"  , 0 , 4},;     // "Alterar"
					{OemToAnsi(STR0005),"A150Excl"    , 0 , 5, 3},; // "Excluir"
					{OemToAnsi(STR0062),"QMT150PERF"  , 0 , 4} } //"Avaliacao"

If nModulo == 47 // Modulo PPAP
	aAdd(aRotina, {OemToAnsi(STR0043), "QMTR150(.T.)", 0, 6,,.T.}) //"Imprimir"
Endif

Return aRotina

Function QMTA150
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aFixe := {}
Local nSavOrd1 := QM4->(IndexOrd())

Private aFim := {}
Private cCadastro := OemtoAnsi(STR0006) //"C lculo de R&R"
Private lExist := .T.
Private cIndQM4
Private cKeyQM4
Private cCondQM4
Private nIndexQM4
Private cIndInc
Private cIndAlt
Private cIndExc
Private cIndVis
Private oMonoAs	:= TFont():New("Mono AS",5,14,,.T.)
Private cTipoAnt := ""
Static oTmpTable1 := NIL
Static oTmpTable2 := NIL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cTitulo := Padc(OemtoAnsi(STR0006),22)  //"C lculo de R&R"
Private aPos   := { 15, 1 , 70 , 339 } //{ 15, 1 , 70 , 315 }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE por Modulo(Metrologia ou PPAP)   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nModulo == 47 // Modulo PPAP
	aFixe := {{ TitSx3("QM4_PECA1")[1]	,"QM4_PECA1" 	},;	//"Numero da Peca"
               { TitSx3("QM4_REV")[1]	,"QM4_REV" 		},;	//"Revisao da Peca"
               { TitSx3("QM4_CARAC")[1]	,"QM4_CARAC " 	},; //"Caracteristica"
               { TitSx3("QM4_DATA")[1]	,"QM4_DATA" 	},;	//"Data"
               { TitSx3("QM4_HORA")[1]	,"QM4_HORA" 	},;	//"Hora"
               { TitSx3("QM4_TIPO")[1]	,"QM4_TIPO" 	},;	//"Tipo"
               { TitSx3("QM4_PVE")[1]	,"QM4_PVE   " 	},; //"PVE"
               { TitSx3("QM4_PVA")[1]  	,"QM4_PVA   " 	},; //"PVA"
               { TitSx3("QM4_PRR")[1]  	,"QM4_PRR   " 	},; //"PRR"
               { TitSx3("QM4_PVP")[1]  	,"QM4_PVP   " 	}}

	dbSelectArea("QM4")
	dbSetOrder(03)
	cIndQM4	:= CriaTrab( nil,.f. )
	cKeyQM4	:= IndexKey()
	cCondQM4:= "QM4_PECA1<>'"+Space(40)+"'"

	IndRegua( "QM4",cIndQM4,cKeyQM4,,cCondQM4,STR0040) //"Aguarde..."
	nIndexQM4 := RetIndex("QM4")
	dbSelectArea("QM4")
	DbSetFilter({|| &(cCondQM4)},cCondQM4)

	dbSetOrder(nIndexQM4+1)
	DbGoTop()

Else
	aFixe := {{ TitSx3("QM4_INSTR")[1]		,"QM4_INSTR " 	},;	//"Numero da Peca"
               { TitSx3("QM4_REVINS")[1]	,"QM4_REVINS"	},;	//"Revisao da Peca"
               { TitSx3("QM4_DATA")[1]		,"QM4_DATA  " 	},;	//"Data"
               { TitSx3("QM4_HORA")[1]		,"QM4_HORA  " 	},;	//"Hora"
               { TitSx3("QM4_TIPO")[1]		,"QM4_TIPO  " 	},;	//"Tipo"
               { TitSx3("QM4_PVE")[1]		,"QM4_PVE   " 	},; //"PVE"
               { TitSx3("QM4_PVA")[1]  		,"QM4_PVA   " 	},; //"PVA"
               { TitSx3("QM4_PRR")[1]  		,"QM4_PRR   " 	},; //"PRR"
               { TitSx3("QM4_PVP")[1]  		,"QM4_PVP   " 	}}

	dbSelectArea("QM4")
	dbSetOrder(01)
	cIndQM4 := CriaTrab( nil,.f. )
	cKeyQM4 := IndexKey()
	cCondQM4 := "QM4_INSTR<>'"+Space(16)+"'"

	IndRegua( "QM4", cIndQM4, cKeyQM4,,cCondQM4, STR0040) //"Aguarde..."
	nIndexQM4 := RetIndex("QM4")
	DbSetFilter({|| &(cCondQM4)},cCondQM4)

	dbSelectArea("QM4")
	dbSetOrder(nIndexQM4+1)
	DbGoTop()

Endif

Qmt150AjQM4()
mBrowse( 6, 1,22,75,"QM4",aFixe)

Set Key VK_F12 To

//Esses arquivos temporarios sao construidos em todas as rotinas e serao deletados
//na rotina principal

If !Empty(cIndInc)
	dbSelectArea("QM4")
	dbSetOrder(3)
	RetIndex("QM4")
	nSavOrd1 := QM4->(IndexOrd())
	dbSetOrder(nSavOrd1)
	Set Filter to
	FErase (cIndInc+OrdBagExt())
Endif

If !Empty(cIndAlt)
	dbSelectArea("QM4")
	dbSetOrder(3)
	RetIndex("QM4")
	nSavOrd1 := QM4->(IndexOrd())
	dbSetOrder(nSavOrd1)
	Set Filter to
	FErase (cIndAlt+OrdBagExt())
Endif

If !Empty(cIndExc)
	dbSelectArea("QM4")
	dbSetOrder(3)
	RetIndex("QM4")
	nSavOrd1 := QM4->(IndexOrd())
	dbSetOrder(nSavOrd1)
	Set Filter to
	FErase (cIndExc+OrdBagExt())
Endif

If !Empty(cIndVis)
	dbSelectArea("QM4")
	dbSetOrder(3)
	RetIndex("QM4")
	nSavOrd1 := QM4->(IndexOrd())
	dbSetOrder(nSavOrd1)
	Set Filter to
	FErase (cIndVis+OrdBagExt())
Endif


dbSelectArea("QM4")
dbSetOrder(1)
RetIndex("QM4")
nSavOrd1 := QM4->(IndexOrd())
dbSetOrder(nSavOrd1)
Set Filter to
FErase (cIndQM4+OrdBagExt())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga arquivo temporario                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
A150DelTmp()
A150DelATP()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A150Inclui³ Autor ³ Wanderley Goncalves   ³ Data ³22.05.98  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao de Medicoes de R&R                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A150Inclui(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A150Inclui(cAlias,nReg,nOpcx)

Local oDlg
Local nOpcA      := 0
Local nCntFor := 0
Local nUsado := 0
Local nSavOpcx   := 0
Local cCampo     := "" // Auxiliar na formata‡ao do nome do campo
Local nSaveSX8	:= GetSX8Len()
Local oEnchoice
Local oPanel
Local oPanelGet
Local oPBtn1
Local oPBtn2
Local oPBtn3
Local oPBtn4
Private oBtn
Private aTela[0][0],aGets[0]
Private bCampo := { |nField| Field(nField) }
Private CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP
Private aHeader := {}
Private aCols   := {}
Private nOpcao := nOpcx
Private aTabela := {}
Private nPosEns
Private nPosCic
Private nPosPec
Private oGet_1
Private nPosAtr
Private cQM5ATP
Private aCont := {}
Private oMedi
Private aTot	:= {}
Private aComb	:= {}
Private	aNew	:= {}
Private	aUseRef	:= {}
Private	aRef	:= {}
Private aSomRef	:= {}
Private nRefere := 0
Private nVlRef := 0
Private nCodig	:= 0
Private oBtn1
Private oBtn2
Private nSomRef	:= 0
Private nRep1	:= 0
Private nRep2	:= 0
Private nRep3	:= 0
Private nRep4	:= 0
Private nReptot := 0
Private nRepReR := 0
Private cMensg	:= ""
Private aCoUser := {}
Private lNaoPd	:= .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa as Variaveis da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QM4")
For nCntFor:= 1 To FCount()
	cCampo := "M->"+ EVAL(bCampo,nCntFor)
	&cCampo := CriaVar(FieldName(nCntFor),.t.)
Next nCntFor

dbSelectArea("QM4")
For nCntFor := 1 To nUsado
	aCols[1,nCntFor] := CriaVar(aHeader[nCntFor,2],.t.)
Next nCntFor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta tabela de ensaiadores                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
A150TabEns(.t.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega aHeader e aCols somente para exibir Getdados na tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := {}
aCols   := {}
AADD(aHeader,{"","VAR01","@!",10,0,".t.","û","C","TRB","V"})

// Inclui coluna de registro atraves de funcao generica
ADHeadRec("QM5",aHeader)

aCols := { { Space(10) , "QM5" , 0 } }

DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 35,86 OF GetWndDefault() //29,80
oDlg:lMaximized := .T.

oEnchoice := MsmGet():New( "QM4" ,nReg,nOpcx,,,,,aPos,,3,,,"A150EnOK",,,.t. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Evita a inclusao de novas linhas na Getdados                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nSavOpcx := aRotina[nOpcx,4]
aRotina[nOpcx,4] := 6

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Bot„o temporario para carregar a Getdados                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@ 000,000 MSPANEL oPanelGet OF oDlg

oGet_1 := MsGetDados():New(72,1,180,338,nOpcx,"Qmt150LOK","Qmt150tOk","",,,2,,,,,,,oPanelGet) //72,1,180,338
oGet_1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGet_1:oBrowse:Disable()

@ 000,000 MSPANEL oPanel OF oDlg

@ 000,000 MSPANEL oPBtn4 SIZE 30,30 OF oPanel
@ 000,000 MSPANEL oPBtn2 SIZE 30,30 OF oPanel
@ 000,000 MSPANEL oPBtn3 SIZE 30,30 OF oPanel
@ 000,000 MSPANEL oPBtn1 SIZE 30,30 OF oPanel

If Alltrim(M->QM4_TPMSA) == "1" .OR. Alltrim(M->QM4_TPMSA) == "3"
	@ 000, 000 BUTTON oBtn1 PROMPT OemToAnsi(STR0051) SIZE 35,15 ACTION ( If(A150ENOK(),a150Calculo(oGet_1,oDlg,oBtn1),)  ) OF oPBtn2 PIXEL //Calcular
	@ 000, 000 BUTTON oBtn PROMPT OemtoAnsi(STR0031) SIZE 35,13 ACTION ( If(A150ENOK(),a150Destroy(oGet_1,oPanelGet,oBtn,nOpcx),)  ) OF oPBtn3 PIXEL //Medicao ,oBtn1
	@ 000, 000 BUTTON oBtn2 PROMPT OemToAnsi(STR0043) SIZE 35,15 ACTION qmtr270() OF oPBtn1 PIXEL //Imprimir
	oBtn1:Hide()
	oBtn1:Disable()
	oBtn2:Hide()
Else
	@ 000, 000 BUTTON oBtn1 PROMPT OemToAnsi(STR0051) SIZE 35,15 ACTION ( If(A150ENOK(),a150Calculo(oGet_1,oDlg),)  ) OF oPBtn2 PIXEL //Calcular ,oBtn1
	@ 000, 000 BUTTON oBtn PROMPT OemtoAnsi(STR0031) SIZE 35,15 ACTION ( If(A150ENOK(),a150Destroy(oGet_1,oPanelGet,oBtn,nOpcx),)  ) OF oPBtn3 PIXEL //Medicao ,oBtn1
	@ 000, 000 BUTTON oBtn2 PROMPT OemToAnsi(STR0043) SIZE 35,15 ACTION qmtr270() OF oPBtn1 PIXEL //Imprimir
	oBtn1:Hide()
	oBtn2:Hide()
Endif

oPBtn4:Align := CONTROL_ALIGN_LEFT
oPBtn2:Align := CONTROL_ALIGN_RIGHT
oPBtn3:Align := CONTROL_ALIGN_RIGHT
oPBtn1:Align := CONTROL_ALIGN_RIGHT

If oGet_1 <> Nil
	@ 005,2 SAY oMedi PROMPT OemToAnsi(STR0044)+Alltrim(Str(n)) SIZE 100,15 OF oPBtn4 PIXEL //Peca
	If M->QM4_TIPO <> "A"
		oMedi:Hide()
	Endif
Endif

ACTIVATE MSDIALOG oDlg ON INIT (QMTA150NvBar(oDlg,{||Iif(oGet_1:TudoOk(),nOpca := (Qmt150Verif(nOpca,oDlg)),nOpca:=0)},{||nOpca:= 0,oDlg:End()},nOpcx),nOpcx,;
								AlignObject(oDlg,{oEnchoice:oBox,oPanelGet,oPanel},1,2,{195,,032})) CENTERED
aRotina[nOpcx,4] := nSavOpcx

If ( nOpcA == 1 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra resultadors finais                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( Qmt150Grav(aFim) )
		EvalTrigger()
		While (GetSX8Len() > nSaveSx8)
			ConfirmSX8()
		End
	EndIf
	aFim := {}
Else
	While (GetSX8Len() > nSaveSx8)
		RollBackSX8()
	End
Endif

dbSelectArea("QM4")

dbSetOrder(1)
dbGoTop()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A150Altera³ Autor ³ Wanderley Goncalves   ³ Data ³01.06.98  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Alteracao de Medicoes de R&R                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A150Altera(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A150Altera(cAlias,nReg,nOpcx)

Local oDlg
Local nOpcA     := 0
Local nCntFor := 0
Local nUsado := 0
Local nSavOpcx  := 0
Local cCampo    := "" // Auxiliar na formata‡ao do nome do campo
Local nSaveSX8	:= GetSX8Len()
Local oEnchoice
Local oPanel
Local oPBtn1
Local oPBtn2
Local oPBtn3

Private aTela[0][0],aGets[0]
Private bCampo := { |nField| Field(nField) }
Private CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP
Private aHeader := {}
Private aCols   := {}
Private nOpcao := nOpcx
Private aTabela := {}
Private nPosEns
Private nPosCic
Private nPosPec
Private nPosAtr
Private nPosAli
Private nPosRec
Private cQM5ATP
Private aCont := {}
Private oMedi
Private aTot	:= {}
Private aComb	:= {}
Private	aNew	:= {}
Private	aUseRef	:= {}
Private	aRef	:= {}
Private aSomRef	:= {}
Private nRefere := 0
Private nVlRef := 0
Private nCodig	:= 0
Private oBtn1
Private oBtn2
Private nSomRef	:= 0
Private nRep1	:= 0
Private nRep2	:= 0
Private nRep3	:= 0
Private nRep4	:= 0
Private nReptot := 0
Private nRepReR := 0
Private cMensg	:= ""
Private aCoUser := {}
Private nCtUser	:= 0
Private lNaoPd	:= .F.

If nModulo == 47 // PPAP
	If !QPPVldAlt(QM4->QM4_PECA1,QM4->QM4_REV)
		Return
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa as Variaveis da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QM4")
For nCntFor:= 1 To FCount()
	cCampo := "M->"+ (EVAL(bCampo,nCntFor))
	&cCampo  := FieldGet(nCntFor)
Next nCntFor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Tabela de Ensaiadores                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
a150TabEns(.f.)
If Len(aTabela) > 0 .and. nCtUser == M->QM4_NENSR
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aCols e aHeader                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols := {}
	A150Monta()

	nUsado  := Len(aHeader)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Guarda posicao dos elementos nos acols 		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	a150PosCol()
	If (Alltrim(M->QM4_TPMSA) == "1" .OR. Alltrim(M->QM4_TPMSA) == "3") .and. M->QM4_TIPO == "A"
		qmt150UseRef()
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recupera medicoes cadastradas                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	a150Recup()

	DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 35,86 OF GetWndDefault()
	oEnchoice := Msmget():New( "QM4" ,nReg,nOpcx,,,,,aPos,,3,,,"A150EnOK",,,.t.)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Evita a inclusao de novas linhas na Getdados                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nSavOpcx := aRotina[nOpcx,4]
	aRotina[nOpcx,4] := 6

	@ 000,000 MSPANEL oPanel OF oDlg
	@ 000,000 MSPANEL oPBtn2 SIZE 30,30 OF oPanel
	@ 000,000 MSPANEL oPBtn1 SIZE 30,30 OF oPanel
	@ 000,000 MSPANEL oPBtn3 SIZE 30,30 OF oPanel

	If (Alltrim(M->QM4_TPMSA) == "1" .OR. Alltrim(M->QM4_TPMSA) == "3") .and. M->QM4_TIPO == "A"
		@ 000,000 BUTTON oBtn1 PROMPT OemToAnsi(STR0051) SIZE 35,15 OF oPBtn2 ACTION ( a150Calculo(oGet,oDlg,oBtn1) ) PIXEL //Calcular
		@ 000,000 BUTTON oBtn2 PROMPT OemToAnsi(STR0043) SIZE 35,15 OF oPBtn1 ACTION (a150Calculo(oGet,oDlg,oBtn1,.t.),qmtr270()) PIXEL //Imprimir
	Endif

	oPBtn3:Align := CONTROL_ALIGN_LEFT
	oPBtn1:Align := CONTROL_ALIGN_RIGHT
	oPBtn2:Align := CONTROL_ALIGN_RIGHT

	oGet := MsGetDados():New(72,1,180,338,nOpcx,"Qmt150LOK","Qmt150tOk","",,,2,,,,,,,oDlg)

	If (Alltrim(M->QM4_TPMSA) == "1" .OR. Alltrim(M->QM4_TPMSA) == "3") .and. M->QM4_TIPO == "A"
		@ 184,2 SAY oMedi PROMPT OemToAnsi(STR0044)+Alltrim(Str(n)) SIZE 100,15 FONT oMonoAs OF oPBtn3 PIXEL //Peca
		oGet:oBrowse:bChange := {||oMedi:SetText(OemToAnsi(STR0044)+Alltrim(Str(n)))}
	Endif

	ACTIVATE MSDIALOG oDlg ON INIT (QMTA150NvBar(oDlg,{||Iif(oGet:TudoOk(),(nOpca := 1,oDlg:End()),nOpca:=0)},{||nOpca := 0,oDlg:End()},nOpcx),nOpcx,;
									AlignObject(oDlg,{oEnchoice:oBox,oGet:oBrowse,oPanel},1,2,{195,,032}))CENTERED
	aRotina[nOpcx,4] := nSavOpcx

	If ( nOpcA == 1 )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Mostra resultadors finais                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( Qmt150Grav(aFim) )
				EvalTrigger()
				While (GetSX8Len() > nSaveSx8)
					ConfirmSX8()
				End
			EndIf
			aFim := {}
	Else
		While (GetSX8Len() > nSaveSx8)
			RollBackSX8()
		End
	EndIf

	dbSelectArea("QM4")
	dbSetOrder(1)
	dbGoTop()
	If nModulo == 22 //Nao retirar devido a integridade.
		QM4->(dbSetOrder(1))
	Endif
Else
	MsgInfo(STR0052,STR0053) //"Estudo realizado em outra filial","Aviso"
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A150Visual³ Autor ³ Wanderley Goncalves   ³ Data ³02.06.98  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Visualizacao de Medicoes de R&R                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A150Visual(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A150Visual(cAlias,nReg,nOpcx)

Local oDlg
Local nCntFor := 0 
Local nUsado := 0
Local cCampo     := "" // Auxiliar na formata‡ao do nome do campo
Local nOpca		 := 0
Local aButtons	 := {}
Local oEnchoice
Local oPanel
Local oPBtn1

Private aTela[0][0],aGets[0]
Private bCampo := { |nField| Field(nField) }
Private CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP
Private aHeader := {}
Private aCols   := {}
PRIVATE aTabela := {}
PRIVATE aResult  := {}
Private nPosEns
Private nPosCic
Private nPosPec
Private nPosAtr
Private nPosAli
Private nPosRec
Private aCont := {}
Private oMedi
Private aTot	:= {}
Private aComb	:= {}
Private	aNew	:= {}
Private	aUseRef	:= {}
Private	aRef	:= {}
Private aSomRef	:= {}
Private nRefere := 0
Private nVlRef := 0
Private nCodig	:= 0
Private oBtn1
Private oBtn2
Private nSomRef	:= 0
Private nRep1	:= 0
Private nRep2	:= 0
Private nRep3	:= 0
Private nRep4	:= 0
Private nReptot := 0
Private aCoUser := {}
Private nCtUser	:= 0
Private nRepReR := 0
Private cMensg	:= ""
Private lNaoPd	:= .F.

If nModulo == 47 // PPAP
	aButtons := { {"BMPVISUAL", { || QMTR150() } , OemToAnsi(STR0042) }} //"Visualizar/Imprimir"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa as Variaveis da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QM4")
For nCntFor:= 1 To fCount()
	cCampo := "M->"+ EVAL(bCampo,nCntFor)
	&cCampo := FieldGet(nCntFor)
Next nCntFor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Tabela de Ensaiadores                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
a150TabEns(.f.)
If Len(aTabela) > 0 .and. nCtUser == M->QM4_NENSR

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aCols e aHeader                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols := {}
	A150Monta()

	nUsado  := Len(aHeader)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Guarda posicao dos elementos nos acols                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	a150PosCol()

	If (Alltrim(M->QM4_TPMSA) == "1" .OR. Alltrim(M->QM4_TPMSA) == "3") .and. M->QM4_TIPO == "A"//If Alltrim(cCons515) == "2" .and. M->QM4_TIPO == "A"
		qmt150UseRef()
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recupera medicoes cadastradas                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	a150Recup()

	DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 35,86 OF GetWndDefault()
	oEnchoice := Msmget():New( "QM4" ,nReg,nOpcx,,,,,aPos,,3,,,"A150EnOK",,,.t.)

	@ 000,000 MSPANEL oPanel OF oDlg
	@ 000,000 MSPANEL oPBtn1 SIZE 30,30 OF oPanel
	@ 000,000 MSPANEL oPBtn2 SIZE 30,30 OF oPanel

	If (Alltrim(M->QM4_TPMSA) == "1" .OR. Alltrim(M->QM4_TPMSA) == "3") .and. M->QM4_TIPO == "A"
		@ 000,000 BUTTON oBtn2 PROMPT OemToAnsi(STR0043) SIZE 35,15 OF oPBtn1 ACTION (a150Calculo(oGet,oDlg,oBtn1,.t.),qmtr270()) PIXEL //Imprimir
	Endif

	oPBtn2:Align := CONTROL_ALIGN_RIGHT
	oPBtn1:Align := CONTROL_ALIGN_RIGHT

	oGet := MsGetDados():New(72,1,180,338,nOpcx,"Qmt150LOK","Qmt150tOk","",,,2,,,,,,,oDlg)

	ACTIVATE MSDIALOG oDlg ON INIT (QMTA150NvBar(oDlg,{||Iif(oGet:TudoOk(),(nOpca := 1,oDlg:End()),nOpca:=0)},{||nOpca := 0,oDlg:End()},nOpcx),nOpcx,;
									AlignObject(oDlg,{oEnchoice:oBox,oGet:oBrowse,oPanel},1,2,{195,,032}))CENTERED

	dbSelectArea("QM4")
	dbSetOrder(1)
	dbGoTop()
Else
	MsgInfo(STR0052,STR0053) //"Estudo realizado em outra filial","Aviso"
Endif

Return(.t.)

/*
antigo a150Ensr
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³qmt150Ensr³ Autor ³ Wanderley Goncalves Jr³ Data ³ 25.05.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Selecao de ensaiadores                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ qmt150Ensr()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gatilho do QM4->QM4_NENSR                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt150Ensr()

Local oDlgEnsaiador
Local oLbx
Local cEnsAtu  := ""
Local oOk      := LoadBitmap( GetResources(), "LBOK" )
Local oNo      := LoadBitmap( GetResources(), "LBNO" )
Local lRet := .F.
Local lFecha := .F.
Private nEnsaia   := 0

If Len(aTabela) > 0
If !qmt150Valid("ENSR")
	//Return(.F.)
	lRet := .F.
Else
	lRet := .T.
EndIf

If lRet
   DEFINE MSDIALOG oDlgEnsaiador TITLE OemToAnsi(STR0032) FROM 10,10 TO 135,335 ; //Ensaiadores
   OF GetWndDefault() PIXEL

   @  05, 05 LISTBOX oLbx VAR cEnsAtu FIELDS HEADER " "," " ;
   ON DBLCLICK (aTabela[oLbx:nAt,1] := !aTabela[oLbx:nAt,1],oLbx:Refresh());
   SIZE 120, 55 OF oDlgEnsaiador PIXEL NOSCROLL
   oLbx:SetArray(aTabela)
   oLbx:bLine := { || {IiF(aTabela[oLbx:nAt,1],oOk,oNo),aTabela[oLbx:nAt,2]}}
   oLbx:bLostFocus := { || a150NumEns(@nEnsaia,aTabela)}

   DEFINE SBUTTON FROM 05, 130 TYPE 1 ENABLE OF oDlgEnsaiador ACTION (Iif(qmt150cho(),;
   (lRet :=.T.,lFecha := .t.,oDlgEnsaiador:End()),lRet := .F.)) PIXEL
   DEFINE SBUTTON FROM 18, 130 TYPE 2 ENABLE OF oDlgEnsaiador ACTION (lRet := .F.,lFecha := .t.,oDlgEnsaiador:End()) PIXEL

   ACTIVATE MSDIALOG oDlgEnsaiador CENTERED Valid lFecha
Endif

DbSelectArea("QM4")
Endif
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QMT150Cho³ Autor ³ Wanderley Goncalves   ³ Data ³25.05.98  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ensaiadores na Achoice                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMT150Cho()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FuncTion QMT150cho(nModo,nPos,nRelPos)

If M->QM4_NENSR < nEnsaia .Or. M->QM4_NENSR > nEnsaia
	Help(" ",1,"A150ENSR")  // N£mero de ensaiadores diferente da
	// quantidade informada
	Return .F.
Else
	Return .T.
EndIf

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A150Monta³ Autor ³ Wanderley Goncalves   ³ Data ³26.05.98  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta aCols e aHeader para calculo de R&R                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A150Monta()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A150Monta(nOpc)

Local nUsado    := 0
Local aCmpPCs   := {}
Local nCntFor   := 0
Local nCntFor2  := 0
Local nCntFor3  := 0
Local nCntForn  := 0
Local aTabAux   := aClone(aTabela)
Local aCmpCod   := {}
Local aCmpRef   := {}
Local nPosE	    := 0
Local aCmpVlr   := {}
Local nx	    := 1
Local aNoFields := {}
Local nPosAli   := 0
Local aArea     := {}
Local nOrdSX3   := SX3->(IndexOrd())
Local nAux      := 0

If Val(M->QM4_TPMSA) == 1 .Or. Val(M->QM4_TPMSA) == 3
	If M->QM4_TIPO <> "A"
		aArea := GetArea()
		aCmpPCs := Q150GetSX3("QM5_PECA", STR0013+" ", q150Pc("QM4_LIE"), 1)// "Pe‡a"  
		RestArea(aArea)
	Else
		aArea := GetArea()
		aCmpPCs := Q150GetSX3("QM5_ATRIB", STR0013+" ", "", 2)// "Atrib"
		aCmpRef := Q150GetSX3("QM5_REFERE", "Referencia", "", 2)// "Referencia"
		aCmpVlr := Q150GetSX3("QM5_VLRREF", "Vlr Ref", "", 2)// "Vlr Referencia"
		aCmpCod := Q150GetSX3("QM5_CODIG", "Codigo", "", 2)// "Codigo"
		RestArea(aArea)
	EndIf
Else
	If M->QM4_TIPO <> "A"
		aArea := GetArea()
		aCmpPCs := Q150GetSX3("QM5_PECA", STR0013+" ", q150Pc("QM4_LIE"), 1)// "Pe‡a"
		RestArea(aArea)
	Else

		aArea := GetArea()
		aCmpPCs := Q150GetSX3("QM5_ATRIB", STR0013+" ", "", 2)// "Atrib"
		RestArea(aArea)

	 EndIf
EndIF

aNoFields := {"QM5_CARAC","QM5_INSTR","QM5_REVINS","QM5_DATA"  ,"QM5_PECA"  ,"QM5_MEDIC",;
			  "QM5_HORA" ,"QM5_ATRIB" ,"QM5_REFERE","QM5_VLRREF","QM5_CODIG"}

If M->QM4_TIPO == "A" .And. (Val(M->QM4_TPMSA) == 1 .Or. Val(M->QM4_TPMSA) == 3)
	ADHeadRec("QM5",aHeader)
Else
	  If Alltrim(FUNNAME()) == "QMTR220"
	  	aHeader := {}
	  	aCols := {}
	  Endif
	  FillGetDados(nOpc,"QM5",1      ,     ,          ,         ,aNoFields,          ,        ,      ,        ,  .T.  ,          ,        ,          ,           ,            ,)
	//FillGetDados(nOpc,Alias ,nOrdem,cSeek,bSeekWhile,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
EndIf

nPosAli  := Ascan(aHeader,{ |X| Upper( Alltrim( X[2])) == "QM5_ALI_WT"})

If M->QM4_TIPO == "A"
	If Alltrim(M->QM4_TPMSA) $ "1|3"
		For nCntFor := 1 to M->QM4_NENSR
			nPosE := ASCAN(aTabAux,{|x| x[1] = .T. })
			For nAux := 1 To M->QM4_NCICLO
				Q150Incl(@aHeader,aClone(aCmpPcs),nPosAli)
				aHeader[nPosAli,1] := SubStr(aTabAux[nPosE][2],1,TamSX3("QM5_ENSR")[1])+" - "+"Ciclo "+Alltrim(Str(nAux))
				nPosAli++
			Next Aux
			aDel( aTabAux, nPosE )
			aSize( aTabAux, LEN( aTabAux ) -1 )
		Next nCntFor
		Q150Incl(@aHeader,aClone(aCmpRef),nPosAli)
		Q150Incl(@aHeader,aClone(aCmpVlr),nPosAli+1)
		Q150Incl(@aHeader,aClone(aCmpCod),nPosAli+2)
	Else
		For nAux := 1 To M->QM4_NPECAS
			Q150Incl(@aHeader,aClone(aCmpPcs),nPosAli)
			aHeader[nPosAli,1] += Space(1)+StrZero(nAux,2)
			nPosAli++
		Next nAux
	Endif
Else
	For nAux := 1 To M->QM4_NPECAS
		Q150Incl(@aHeader,aClone(aCmpPcs),nPosAli)
		aHeader[nPosAli,1] += Space(1)+StrZero(nAux,2)
		nPosAli++
	Next nAux
Endif

nUsado := Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aCols                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols := Asize(aCols,0)
If (Alltrim(M->QM4_TPMSA) == "1" .OR. Alltrim(M->QM4_TPMSA) == "3") .and. M->QM4_TIPO == "A"
	aCols := Array(M->QM4_NPECAS,(M->QM4_NCICLO*M->QM4_NENSR)+5)
	For nCntFor := 1 to Len(aCols)
		For nCntForn := 1 To Len(aCols[1])
			If Len(aHeader) >= nCntForn
				If aHeader[nCntForn,2] == "QM5_ALI_WT"
					aCols[nCntFor,nCntForn] := QM5->(Alias())
				ElseIF aHeader[nCntForn,2] == "QM5_REC_WT"
					aCols[nCntFor,nCntForn] := 0
				Else
					aCols[nCntFor,nCntForn] := CriaVar(aHeader[nCntForn,2],.t.)
				EndIF
			Else
				aCols[nCntFor,nCntForn] := 1
			Endif
		Next nCntFor
	Next nCntFor
Else
	For nCntFor := 1 to len(aTabela)
			If aTabela[nCntFor,1]

			For nCntFor2 := 1 to M->QM4_NCICLO

				aadd(aCols,Array(nUsado))

				nAcols := Len(aCols)

				For nCntForn := 1 To nUsado
					If !(aHeader[nCntForn,2] $ "QM5_ALI_WT | QM5_REC_WT")
						aCols[nAcols,nCntForn] := CriaVar(aHeader[nCntForn,2],.t.)
					EndIf
				Next nCntForn

				For nCntFor3 := 1 to len(aHeader)

					If ( aHeader[nCntFor3,2] $ "QM5_ENSR  " )
						aCols[nAcols,nCntFor3] := aTabela[nCntFor,2]
					ElseIf ( aHeader[nCntFor3,2] $ "QM5_CICLO ")
						aCols[nAcols,nCntFor3] := nCntFor2
					ElseIf ( aHeader[nCntFor3,2] $ "QM5_MEDIC ")
						aCols[nAcols,nCntFor3] := CriaVar(aHeader[nCntFor3,2],.t.)
					ElseIf ( aHeader[nCntFor3,2] $ "QM5_ALI_WT")
						aCols[nAcols,nCntFor3] := QM5->(Alias())
					ElseIf ( aHeader[nCntFor3,2] $ "QM5_REC_WT")
						aCols[nAcols,nCntFor3] := 0
					EndIf

				Next nCntFor3

			Next nCntFor2

		EndIf

	Next nCntFor
Endif
Return(.T.)

/*
antigo a150Pc
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ q150Pc   ³ Autor ³ Wanderley Goncalves   ³ Data ³ 27/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a funcao que monta a picture de um campo.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ q150Pc(cCampo)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do Campo que tera' a picture a ser definida   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function q150Pc(cCampo)

Local cPict
//Campo ,Valor de Referencia

If INCLUI .OR. ALTERA
	cPict := QA_PICT(cCampo,&("M->"+cCampo))
Else
	cPict := ""
EndIf

Return cPict


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A150CalRR³ Autor ³ Wanderley Goncalves   ³ Data ³ 27/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula R&R e exibe na tela                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A150CalRR()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ lTela -> Se .t., exibir na tela, senao guardar em array    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A150CalRR(lTela)

Local cVar	   	 := ""
Local nVT
Local nTole
Local aTab     	 := array(25,5) //15
Local aQM5Str  	 := {}
Local cmEnsa  	 := ""
Local cText 	 := ""
Local lRet     	 := .T.
Local nMedia
Local oDlgCalRR
Local cCorREsu 	 := CLR_HRED
Local cCorREsuT  := CLR_HRED
Local oFnt
Local cPicture 	 := ""
Local naux 		 := 0
Local aMaior	 := {}
Local nTot		 := 0
Local nCntFor 	 := 1
Local nCntfor2 	 := 1
Local nx 		 := 1
Local ny 		 := 1
Local nTolEsp
Local nprrT		 := 0

lRet			 := .F.
aResult  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda posicao dos elementos nos acols                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
a150PosCol()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados fornecidos por tabela                                                                  ³
//³ OBS.: Para trabalhar com a tabela deve-se observar os valores por coluna e nao por linha     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Alltrim(M->QM4_TPMSA) == "1" .OR. Alltrim(M->QM4_TPMSA) == "3"
		atab[ 1,1] := 0.00; atab[ 1,2] := 0.00  ; atab[ 1,3] := 0.00  ; atab[ 1,4] := 0.00; atab[ 1,5] := 1.41 // Nao utiliza
		atab[ 2,1] := 3.27; atab[ 2,2] := 0.8862; atab[ 2,3] := 0.7071; atab[ 2,4] := 0.00; atab[ 2,5] := 1.28
		atab[ 3,1] := 2.58; atab[ 3,2] := 0.5908; atab[ 3,3] := 0.5231; atab[ 3,4] := 0.00; atab[ 3,5] := 1.23
		atab[ 4,1] := 2.28; atab[ 4,2] := 0.4857; atab[ 4,3] := 0.4467; atab[ 4,4] := 0.00; atab[ 4,5] := 1.21
		atab[ 5,1] := 2.12; atab[ 5,2] := 0.4299; atab[ 5,3] := 0.4030; atab[ 5,4] := 0.00; atab[ 5,5] := 1.19
		atab[ 6,1] := 2.00; atab[ 6,2] := 0.3946; atab[ 6,3] := 0.3742; atab[ 6,4] := 0.00; atab[ 6,5] := 1.18
		atab[ 7,1] := 1.92; atab[ 7,2] := 0.3698; atab[ 7,3] := 0.3534; atab[ 7,4] := 0.08; atab[ 7,5] := 1.17
		atab[ 8,1] := 1.86; atab[ 8,2] := 0.3512; atab[ 8,3] := 0.3375; atab[ 8,4] := 0.14; atab[ 8,5] := 1.17
		atab[ 9,1] := 1.82; atab[ 9,2] := 0.3367; atab[ 9,3] := 0.3249; atab[ 9,4] := 0.18; atab[ 9,5] := 1.16
		atab[10,1] := 1.78; atab[10,2] := 0.3249; atab[10,3] := 0.3146; atab[10,4] := 0.22; atab[10,5] := 1.16
		atab[11,1] := 1.74; atab[11,2] := 0.3152; atab[11,3] := 0.3051; atab[11,4] := 0.26; atab[11,5] := 1.16
		atab[12,1] := 1.72; atab[12,2] := 0.3061; atab[12,3] := 0.2985; atab[12,4] := 0.28; atab[12,5] := 1.15
		atab[13,1] := 1.69; atab[13,2] := 0.2998; atab[13,3] := 0.2921; atab[13,4] := 0.31; atab[13,5] := 1.15
		atab[14,1] := 1.67; atab[14,2] := 0.2935; atab[14,3] := 0.2864; atab[14,4] := 0.33; atab[14,5] := 1.15
		atab[15,1] := 1.65; atab[15,2] := 0.2880; atab[15,3] := 0.2814; atab[15,4] := 0.35; atab[15,5] := 1.15

		atab[16,1] := 1.64; atab[16,2] := 0.2831; atab[16,3] := 0.2768; atab[16,4] := 0.26; atab[16,5] := 1.16
		atab[17,1] := 1.62; atab[17,2] := 0.2787; atab[17,3] := 0.2729; atab[17,4] := 0.28; atab[17,5] := 1.15
		atab[18,1] := 1.61; atab[18,2] := 0.2747; atab[18,3] := 0.2692; atab[18,4] := 0.31; atab[18,5] := 1.15
		atab[19,1] := 1.60; atab[19,2] := 0.2711; atab[19,3] := 0.2659; atab[19,4] := 0.33; atab[19,5] := 1.15
		atab[20,1] := 1.57; atab[20,2] := 0.2677; atab[20,3] := 0.2628; atab[20,4] := 0.35; atab[20,5] := 1.15

		atab[21,1] := 1.58; atab[21,2] := 0.2831; atab[21,3] := 0.2768; atab[21,4] := 0.26; atab[21,5] := 1.16
		atab[22,1] := 1.57; atab[22,2] := 0.2787; atab[22,3] := 0.2729; atab[22,4] := 0.28; atab[22,5] := 1.15
		atab[23,1] := 1.56; atab[23,2] := 0.2747; atab[23,3] := 0.2692; atab[23,4] := 0.31; atab[23,5] := 1.15
		atab[24,1] := 1.55; atab[24,2] := 0.2711; atab[24,3] := 0.2659; atab[24,4] := 0.33; atab[24,5] := 1.15
		atab[25,1] := 1.54; atab[25,2] := 0.2677; atab[25,3] := 0.2628; atab[25,4] := 0.35; atab[25,5] := 1.15
	Else
		atab[ 1,1] := 0.00; atab[ 1,2] := 0.00; atab[ 1,3] := 0.00; atab[ 1,4] := 0.00; atab[ 1,5] := 1.41 // Nao utiliza
		atab[ 2,1] := 3.27; atab[ 2,2] := 4.56; atab[ 2,3] := 3.65; atab[ 2,4] := 0.00; atab[ 2,5] := 1.28
		atab[ 3,1] := 2.58; atab[ 3,2] := 3.05; atab[ 3,3] := 2.70; atab[ 3,4] := 0.00; atab[ 3,5] := 1.23
		atab[ 4,1] := 2.28; atab[ 4,2] := 2.50; atab[ 4,3] := 2.30; atab[ 4,4] := 0.00; atab[ 4,5] := 1.21
		atab[ 5,1] := 2.12; atab[ 5,2] := 2.21; atab[ 5,3] := 2.08; atab[ 5,4] := 0.00; atab[ 5,5] := 1.19
		atab[ 6,1] := 2.00; atab[ 6,2] := 2.04; atab[ 6,3] := 1.93; atab[ 6,4] := 0.00; atab[ 6,5] := 1.18
		atab[ 7,1] := 1.92; atab[ 7,2] := 1.91; atab[ 7,3] := 1.82; atab[ 7,4] := 0.08; atab[ 7,5] := 1.17
		atab[ 8,1] := 1.86; atab[ 8,2] := 1.81; atab[ 8,3] := 1.74; atab[ 8,4] := 0.14; atab[ 8,5] := 1.17
		atab[ 9,1] := 1.82; atab[ 9,2] := 1.73; atab[ 9,3] := 1.67; atab[ 9,4] := 0.18; atab[ 9,5] := 1.16
		atab[10,1] := 1.78; atab[10,2] := 1.67; atab[10,3] := 1.62; atab[10,4] := 0.22; atab[10,5] := 1.16
		atab[11,1] := 1.74; atab[11,2] := 1.62; atab[11,3] := 1.57; atab[11,4] := 0.26; atab[11,5] := 1.16
		atab[12,1] := 1.72; atab[12,2] := 1.58; atab[12,3] := 1.54; atab[12,4] := 0.28; atab[12,5] := 1.15
		atab[13,1] := 1.69; atab[13,2] := 1.54; atab[13,3] := 1.51; atab[13,4] := 0.31; atab[13,5] := 1.15
		atab[14,1] := 1.67; atab[14,2] := 1.51; atab[14,3] := 1.48; atab[14,4] := 0.33; atab[14,5] := 1.15
		atab[15,1] := 1.65; atab[15,2] := 1.48; atab[15,3] := 1.45; atab[15,4] := 0.35; atab[15,5] := 1.15

		atab[16,1] := 1.64; atab[16,2] := 0.2831; atab[16,3] := 0.2768; atab[16,4] := 0.26; atab[16,5] := 1.16
		atab[17,1] := 1.62; atab[17,2] := 0.2787; atab[17,3] := 0.2729; atab[17,4] := 0.28; atab[17,5] := 1.15
		atab[18,1] := 1.61; atab[18,2] := 0.2747; atab[18,3] := 0.2692; atab[18,4] := 0.31; atab[18,5] := 1.15
		atab[19,1] := 1.60; atab[19,2] := 0.2711; atab[19,3] := 0.2659; atab[19,4] := 0.33; atab[19,5] := 1.15
		atab[20,1] := 1.57; atab[20,2] := 0.2677; atab[20,3] := 0.2628; atab[20,4] := 0.35; atab[20,5] := 1.15

		atab[21,1] := 1.58; atab[21,2] := 0.2831; atab[21,3] := 0.2768; atab[21,4] := 0.26; atab[21,5] := 1.16
		atab[22,1] := 1.57; atab[22,2] := 0.2787; atab[22,3] := 0.2729; atab[22,4] := 0.28; atab[22,5] := 1.15
		atab[23,1] := 1.56; atab[23,2] := 0.2747; atab[23,3] := 0.2692; atab[23,4] := 0.31; atab[23,5] := 1.15
		atab[24,1] := 1.55; atab[24,2] := 0.2711; atab[24,3] := 0.2659; atab[24,4] := 0.33; atab[24,5] := 1.15
		atab[25,1] := 1.54; atab[25,2] := 0.2677; atab[25,3] := 0.2628; atab[25,4] := 0.35; atab[25,5] := 1.15
	Endif


 d4 := atab[M->QM4_NCICLO,1]
 k1 := atab[M->QM4_NCICLO,2] // (Formula - MSA 3Edicao = (1/(Nr.Ensaiadores*Nr.Pecas)))
 k2 := atab[M->QM4_NENSR,3]  // (Formula - MSA 3Edicao - (1/Nr.Ensaiadores)
 d3 := atab[M->QM4_NCICLO,4]
 k3 := atab[M->QM4_NPECAS,3] // (Formula - MSA 3Edicao - (1/Nr.Pecas)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arq. Temporario a partir do aCols                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aQM5Str,{ "QM5_ENSR","C",TamSX3("QM5_ENSR")[1],0})
aadd(aQM5Str,{ "QM5_CICLO","N",TamSX3("QM5_CICLO")[1],0})
For nCntFor := 1 to M->QM4_NPECAS
	aadd(aQM5Str,{ "PECA"+StrZero(nCntFor,2) , 'N' ,  20 , 10 })
Next nCntFor
aadd(aQM5Str,{'MEDIA' , 'N' , 20, 10 } )
aadd(aQM5Str,{ "QM5_FILRES","C",TamSX3("QM5_FILRES")[1],0})

If Select("QM5TMP") > 0
	QM5TMP->(DbCloseArea())
EndIf

oTmpTable1 := FWTemporaryTable():New( "QM5TMP" )
oTmpTable1:SetFields( aQM5Str )
oTmpTable1:AddIndex("indice1", {"QM5_ENSR","QM5_CICLO"} )
oTmpTable1:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena aCols no Tempor rio                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QM5TMP")
For nCntFor := 1 to Len(aCols)
	RecLock("QM5TMP",.T.)
	QM5TMP->QM5_ENSR  := aCols[nCntFor,nPosEns]
	QM5TMP->QM5_CICLO := aCols[nCntFor,nPosCic]
	nMedia := 0
	For nCntfor2 := 0 to M->QM4_NPECAS-1
		cVar  := "PECA"+StrZero(nCntFor2+1,2) // Pe‡a
		cVar  := "QM5TMP->"+cVAR
		&cVar := aCols[nCntFor,nPosPec+nCntFor2]
		nMedia += aCols[nCntFor,nPosPec+nCntFor2]
	Next nCntFor2
	QM5TMP->MEDIA := nmedia / M->QM4_NPECAS
	QM5TMP->QM5_FILRES := cFilAnt
	MsUnlock()
Next nCntFor

ntole  = abs(SuperVal(M->QM4_LSE) - SuperVal(M->QM4_LIE))
If ntole = 0
	cmEnsa := oEmToAnsi(STR0016) //"Tolerƒncia igual a zero."
Endif

nTot := M->QM4_NPECAS * M->QM4_NENSR
aresult := array(nTot,6)
QM5TMP->(DbSetOrder(1))
QM5TMP->(DbGoTop())
cnome := QM5TMP->QM5_ENSR
nchave := 0
For nCntFor := 1 to M->QM4_NCICLO * M->QM4_NENSR
	For nCntFor2 := 1 to M->QM4_NPECAS
		cTEXT := 'PECA'+StrZero(nCntFor2,2)
		If nCntFor == 1 .or. !(QM5TMP->QM5_ENSR == cnome)
			aresult[nCntFor2+nchave,1] := QM5TMP->QM5_ENSR   // Ensaiador
			aresult[nCntFor2+nchave,2] := cTEXT              // Peca
		EndIf
		cVar := "QM5TMP->"+cTEXT
		nValor := &cVAR
		If nCntFor == 1 .or. !(QM5TMP->QM5_ENSR == cnome)
			aresult[nCntFor2+nchave,3] := nValor
			aresult[nCntFor2+nchave,4] := nValor
			If nCntFor2 == M->QM4_NPECAS
				cnome := QM5TMP->QM5_ENSR
			EndIf
		Else
			aresult[nCntFor2+nchave,3] := iif(nValor < aresult[nCntFor2+nchave,3], nValor ,aresult[nCntFor2+nchave,3])    // Minimo
			aresult[nCntFor2+nchave,4] := iif(nValor > aresult[nCntFor2+nchave,4], nValor ,aresult[nCntFor2+nchave,4])    // Maximo
		EndIf
		If empty(aresult[nCntFor2+nchave,5])   // Acumulado para calculo da media
			aresult[nCntFor2+nchave,5] := nValor
		Else
			aresult[nCntFor2+nchave,5] += nValor
		EndIf
		aresult[nCntFor2+nchave,6] := aresult[nCntFor2+nchave,4] - aresult[nCntFor2+nchave,3]    // Amplitude
	Next
	QM5TMP->(DbSkip())
	If QM5TMP->QM5_ENSR <> cnome
		nchave+=M->QM4_NPECAS
	EndIf
Next
*
*----    Calcula a media das medicoes    ---- (Ate aqui a array somente somava)
nTot := M->QM4_NENSR*M->QM4_NPECAS

For nCntFor := 1 to nTot
	aresult[nCntFor,5] := aresult[nCntFor,5] / M->QM4_NCICLO
Next

//----   Calcula a media das amplitudes  e das medias  ----
//1 - amplitudes  //  2 - medias
amger    := array(M->QM4_NENSR,2)
nchave   := 0
For nCntFor := 1 to M->QM4_NENSR
	nCntFor2 := 1
	cnome := aresult[nCntFor2+nchave,1]
	amger[nCntFor,1] := 0
	amger[nCntFor,2] := 0
	For nCntFor2 := 1 to M->QM4_NPECAS
		amger[nCntFor,1] += aresult[nCntFor2+nchave,6]
		amger[nCntFor,2] += aresult[nCntFor2+nchave,5]
	Next
	amger[nCntFor,1] := round(amger[nCntFor,1]/M->QM4_NPECAS,QA_NumDec(QM4_LIE)+3)
	amger[nCntFor,2] := round(amger[nCntFor,2]/M->QM4_NPECAS,QA_NumDec(QM4_LIE)+3)
	cnome := aresult[nCntFor2]
	nchave += M->QM4_NPECAS
Next

// Medias das amplitudes Geral
namp := 0
For nCntFor := 1 to M->QM4_NENSR
	namp += amger[nCntFor,1]
Next
//namp := round(namp/M->QM4_NENSR,QA_NumDec(QM4_LIE)+3)
namp := MATHC(namp,"/",M->QM4_NENSR)

// Verifica a diferenca entre o maximo e o minimo das medias
store amger[1,2] to nmin, nmax
For nCntFor := 2 to M->QM4_NENSR
	nmin = iif(amger[nCntFor,2] < nmin, amger[nCntFor,2],nmin)
	nmax = iif(amger[nCntFor,2] > nmax, amger[nCntFor,2],nmax)
Next
//xdif = nmax - nmin
//xdif = round(xdif,QA_NumDec(QM4_LIE)+2)
xdif = MATHC(nmax,"-",nmin)
//
//---    Calculo de Limite Superior de Controle da Amplitude(LSC) ----
// formula : Rbarra * D4
// sendo que Rbarra = media das amplitudes
//
//nlsc = round(namp * d4,QA_NumDec(QM4_LIE)+3)
nLSC := MATHC(namp,"*",d4)

//
//----    Calculo de Limite Inferior de Controle da Amplitude(LIC) ----
//formula : Rbarra * D3
// sendo que Rbarra = media das amplitudes
//
//nlic = round(namp * d3,QA_NumDec(QM4_LIE)+3)
nLIC := MATHC(namp,"*",d3)

//
//---    Calculo da Repetibilidade Variacao do Equipamento (V.E.)   ----
// formula: V.E. = K1 * Rbarra
// sendo que Rbarra = media das amplitudes.
//
//nvre = round(namp * k1,QA_NumDec(QM4_LIE)+3)
nvre = MATHC(namp,"*",k1)

//
//----   Calculo da Variacao do Avaliador Reprodutibilidade ( V.A.)
//
// formula: VA = sqrt({[(Xdif)*(K2)]^2} - [(V.R.E.^2)/(n*r)])
// sendo que : Xdif = diferenca das medias mais alta e media mais baixa
//             n  = numero de pecas
//             r  = numero de medicoes

//nva = ((xdif*k2)^2)-((nvre^2)/(M->QM4_NCICLO*M->QM4_NPECAS))
nva = MATHC(MATHC(MATHC(xdif,"*",k2),"e",2),"-",	MATHC(MATHC(nvre,"e",2),"/",MATHC(M->QM4_NCICLO,"*",M->QM4_NPECAS)))
//nva = iif(nva<=0,0,round(sqrt(nva),QA_NumDec(QM4_LIE)+3))
nva = iif(val(nva)<=0,"0",MATHC(nva,"e",0.5))
//
//----  Calculo de Repetibilidade e Reprodutibilidade ( R & R )  ----*
//
//formula: RR = sqrt((V.R.E.^2) + (V.A.^2))
//
//nrr = round(sqrt((val(nvre)^2) + (val(nva)^2)),QA_NumDec(QM4_LIE)+3)
nrr := MATHC(MATHC(MATHC(nvre,"e",2),"+",MATHC(nva,"e",2)),"e",0.5)

//
//----  Calculo da  Variacao da Peca (V.P.) ----*
////formula: PV = Rp x K3
// Calcula Rp: Diferenca entre a maior e a menor MEDIA DAS PECAS.

anmedp := array(M->QM4_NPECAS)
For nCntFor2 := 1 to M->QM4_NPECAS
	For nCntFor := 0 to M->QM4_NPECAS*M->QM4_NENSR-M->QM4_NPECAS step M->QM4_NPECAS
		If nCntFor == 0
			anmedp[nCntFor2] := 0
		endif
		anmedp[nCntFor2] += aresult[nCntFor2+nCntFor,5]
	Next
	anmedp[nCntFor2] := anmedp[nCntFor2] / M->QM4_NENSR
	If nCntFor2 == 1
		nnmin := nnmax := anmedp[nCntFor2]
	Else
		nnmin = iif(anmedp[nCntFor2] < nnmin, anmedp[nCntFor2],nnmin)
		nnmax = iif(anmedp[nCntFor2] > nnmax, anmedp[nCntFor2],nnmax)
	EndIf
Next
nRp := nnmax - nnmin
nvp := round(nRp * k3,QA_NumDec(QM4_LIE))

if M->QM4_TIPO=='P' // Somente se QS9000
	//
	//----  Variacao Total (V.T.)
	//
	//formula: VT = sqrt((R&R)^2+VP^2)
	//
//	nVT := round(sqrt((nrr^2) + (nvp^2)),QA_NumDec(QM4_LIE))
	nVT := MATHC(MATHC(MATHC(nrr,"e",2),"+",MATHC(nvp,"e",2)),"e",0.5)
endif

//
//----  Calculo da % de Analise
//
// Pelo Metodo GM    ====  T.E. = Tolerancia
//formula: %V.E. = 100*(V.E.) / T.E. )
//formula: %V.A. = 100*(V.A.) / T.E. )
//formula: %R.R. = Raizq( (%V.E.)^2 + (%V.A.)^2 )
//formula: %V.P. = 100*(V.P.) / T.E. )
//sendo que: tolerancia = Diferenca do Lim.Sup.especif e Lim.Inf.especif./2
//
// Para QS9000
//ormula: %V.E. = 100*(V.E.) / (V.T.)
//formula: %V.A. = 100*(V.A.) / (V.T.)
//formula: %R.R. = 100*(R&R)  / (V.T.) //Com base na variação do processo
//formula: %R.R. = 100*(R&R)  / ((1/6)*TolEsp) //Com base na tolerancia informada
//formula: %V.P. = 100*(V.P.) / (V.T.)
//

If M->QM4_TIPO=='E'  // GM
	npve  := round(100 * (val(nvre)/ntole),QA_NumDec(QM4_LIE))
	npva  := round(100 * (val(nva)/ntole),QA_NumDec(QM4_LIE))
	nprr  := sqrt( (npve^2) + (npva^2))
	npvp  := round(100 * (nvp/ntole),QA_NumDec(QM4_LIE))
else  // QS 9000
	//	npve  := round(100 * (nvre/nVT),QA_NumDec(QM4_LIE))
	npve  := MATHC(100,"*", MATHC(nvre,"/",nVT))
	//	npva  := round(100 * (val(nva)/nVT),QA_NumDec(QM4_LIE))
	npva  := MATHC(100,"*",MATHC(nva,"/",nVT))
	//	nprr  := round(100 * (val(nrr)/val(nVT)),QA_NumDec(QM4_LIE))
	nprr  := MATHC(100,"*",MATHC(nrr,"/",nVT))
	If Alltrim(M->QM4_TPMSA) == "3"
		nTolEsp:= SuperVal(M->QM4_TOLESP)
		nprrT := MATHC(100,"*",MATHC(nrr,"/",MATHC((1/6),"*",nTolEsp)))
		nprrT  := val(nprrT)
	EndIf
	//	npvp  := round(100 * (nvp/val(nVT)),QA_NumDec(QM4_LIE))
	npvp   := MATHC(100,"*",MATHC(nvp,"/",nVT))
	npve   := val(npve)
	npva   := val(npva)
	nprr   := val(nprr)
	npvp   := val(npvp)
	nVT    := val(nVT)
endif

naux  := round(1 * nprr,QA_NUMDEC(QM4_LIE))


If Alltrim(M->QM4_TPMSA) == "1" .OR. Alltrim(M->QM4_TPMSA) == "3"
	//nndc   := 1.41*(nvp/val(nrr))
	nndc   := MATHC(1.41,"*",MATHC(nvp,"/",nrr))
	nndc   := val(nndc)
Else
	nndc   := 0
Endif

//Tratamento para cores na tela do oDlg
If ExistBlock("QM150CoRes")
	cCorResu := ExecBlock("QM150CoRes",.F.,.F.,{nprr})
Else
	If nprr <= GetMv("MV_QRRIAPR")
		cresu = alltrim(GetMv("MV_QRRTAPR"))    // "BOM"
		cCorResu := CLR_GREEN
	Elseif nprr <= GetMv("MV_QRRICON")
		cresu = alltrim(GetMv("MV_QRRTCON"))    // "ACEITAVEL"
		cCorResu := CLR_YELLOW
	Else
		cresu = alltrim(GetMv("MV_QRRTREP"))    // "INACEITAVEL"
		cCorResu := CLR_HRED
	Endif
Endif

If Alltrim(M->QM4_TPMSA) == "3"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para cores na tela do oDlg para R&R sobre tolerancia         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QM150CoRes")
		cCorREsuT := ExecBlock("QM150CoRes",.F.,.F.,{nprrT})
	Else
		If nprrT <= GetMv("MV_QRRIAPR")
			cResuT = alltrim(GetMv("MV_QRRTAPR"))    // "BOM"
			cCorREsuT := CLR_GREEN
		Elseif nprrT <= GetMv("MV_QRRICON")
			cResuT = alltrim(GetMv("MV_QRRTCON"))    // "ACEITAVEL"
			cCorREsuT := CLR_YELLOW
		Else
			cResuT = alltrim(GetMv("MV_QRRTREP"))    // "INACEITAVEL"
			cCorREsuT := CLR_HRED
		Endif
	Endif
EndIf

If lTela

	DEFINE FONT oFnt NAME "Arial" BOLD

	DEFINE MSDIALOG oDlgCalRR TITLE OemToAnsi(STR0036) FROM 10,10 TO 230,380 ; //Resultado
	OF GetWndDefault() PIXEL

	@ 03,05 TO 100,140 OF oDlgCalRR PIXEL
	If M->QM4_TIPO == "P"
		@ 10,10 SAY OemToAnsi(STR0022) SIZE 40,7 OF oDlgCalRR FONT oFnt PIXEL // "%V.E.:"
		@ 20,10 SAY OemToAnsi(STR0023) SIZE 40,7 OF oDlgCalRR FONT oFnt PIXEL // "%V.A.:"
		If Alltrim(M->QM4_TPMSA) == "3"
			@ 30,10 SAY "%R&R. Base na Tol.:" SIZE 100,10 OF oDlgCalRR FONT oFnt PIXEL // "%R&R.:"
			nprrT := round(nprrT,QA_NumDec(QM4_LIE))
		EndIf
		@ 40,10 SAY "%R&R Var. Proc.:" SIZE 100,10 OF oDlgCalRR FONT oFnt PIXEL // "%R&R.:"
		@ 50,10 SAY OemToAnsi(STR0025) SIZE 40,7 OF oDlgCalRR FONT oFnt PIXEL // "%V.P.:"
		@ 60,10 SAY OemToAnsi(STR0078) SIZE 40,7 OF oDlgCalRR FONT oFnt PIXEL // "V.T.:"
		nVT   := round(nVT,QA_NumDec(QM4_LIE)) //Ajuste da mascara

	ElseIf M->QM4_TIPO == "E"
		@ 10,10 SAY OemToAnsi(STR0022) SIZE 40,7 OF oDlgCalRR FONT oFnt PIXEL // "%V.E.:"
		@ 20,10 SAY OemToAnsi(STR0023) SIZE 40,7 OF oDlgCalRR FONT oFnt PIXEL // "%V.A.:"
		@ 30,10 SAY OemToAnsi(STR0024) SIZE 40,7 OF oDlgCalRR FONT oFnt PIXEL // "%R&R.:"
		@ 40,10 SAY OemToAnsi(STR0025) SIZE 40,7 OF oDlgCalRR FONT oFnt PIXEL // "%V.P.:"
	EndIf

		If Alltrim(M->QM4_TPMSA) == "1" .OR. Alltrim(M->QM4_TPMSA) == "3"
			@ 70,10 SAY OemToAnsi("ndc")   SIZE 40,7 OF oDlgCalRR FONT oFnt PIXEL // "ndc"
		Endif

		//Ajuste  das  Mascaras dos valores exibidos
		npve  := round(npve,QA_NumDec(QM4_LIE))
		npva  := round(npva,QA_NumDec(QM4_LIE))
		nprr  := round(nprr,QA_NumDec(QM4_LIE))
		npvp  := round(npvp,QA_NumDec(QM4_LIE))

		aMaior := {}

		aadd(aMaior,nPve)
		aadd(aMaior,nPva)
		aadd(aMaior,nPrr)
		aadd(aMaior,nPvp)
		aadd(aMaior,nndc)
		If M->QM4_TIPO == "P"
	   		aadd(aMaior,nVT)
		EndIf
		aSort(aMaior,,,{|x,y| At(".",str(x)) > At(".",str(y))})

		cPicture := q150MoPict(aMaior[1])	// @E 9,99

		aSort(aMaior,,,{|x,y| x > y})

		@ 10, 35 SAY nPve             SIZE 70, 7 OF oDlgCalRR PICTURE cPicture PIXEL FONT oFnt RIGHT
		@ 20, 35 SAY nPva             SIZE 70, 7 OF oDlgCalRR PICTURE cPicture PIXEL FONT oFnt RIGHT
		If Alltrim(M->QM4_TPMSA) == "3"
			@ 30, 35 SAY nPrrT             SIZE 70, 7 OF oDlgCalRR PICTURE cPicture PIXEL FONT oFnt RIGHT
		EndIf
		@ 40, 35 SAY nPrr             SIZE 70, 7 OF oDlgCalRR PICTURE cPicture PIXEL FONT oFnt RIGHT
		@ 50, 35 SAY nPvp             SIZE 70, 7 OF oDlgCalRR PICTURE cPicture PIXEL FONT oFnt RIGHT
		@ 60, 35 SAY nVT 			  SIZE 70, 7 OF oDlgCalRR PICTURE cPicture PIXEL FONT oFnt RIGHT

		If Alltrim(M->QM4_TPMSA) == "1" .OR. Alltrim(M->QM4_TPMSA) == "3"
			@ 70, 35 SAY nndc         SIZE 70, 7 OF oDlgCalRR PICTURE cPicture PIXEL FONT oFnt RIGHT
		Endif

	@ 80,10 SAY "Result. R&R Var. Proc.:" SIZE 100,7 OF oDlgCalRR FONT oFnt PIXEL // "Resultado: "
	@ 80,70 SAY Alltrim(cResu)   SIZE 42, 7 OF oDlgCalRR PIXEL FONT oFnt RIGHT COLOR cCorResu

	If Alltrim(M->QM4_TPMSA) == "3"
		@ 90,10 SAY "Result. R&R Base na Tol.:" SIZE 100,7 OF oDlgCalRR FONT oFnt PIXEL // "Resultado: "
		@ 90,70 SAY Alltrim(cResuT)   SIZE 42, 7 OF oDlgCalRR PIXEL FONT oFnt RIGHT COLOR cCorREsuT
    EndIf
	DEFINE SBUTTON FROM 05, 160 TYPE 1 ENABLE OF oDlgCalRR Action (lRet := .T.,oDlgCalRR:End()) PIXEL
	DEFINE SBUTTON FROM 18, 160 TYPE 2 ENABLE OF oDlgCalRR Action (lRet := .F.,oDlgCalRR:End()) PIXEL

	ACTIVATE MSDIALOG oDlgCalRR CENTERED

	oFnt:End()


EndIf

nprr := naux

aadd( aFim,  { npve, npva, nprr, npvp, cResu,;
nRP, val(nAmp), nMax, nMin, val(xDif), d4, Val(nLSC),;
d3, val(nLIC), k1, val(nVre), nTole, if(nVT==NIL,0,nVT), k2,;
val(nVa), val(nrr), k3, nvp, nndc,if (Alltrim(M->QM4_TPMSA) == "3"  .AND. !Empty(nPrrT),nPrrT,0)  } )


Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A150PosCol³ Autor ³ Wanderley Gon‡alves   ³ Data ³ 27.05.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Guarda o posicao dos campos na getdados em variaveis       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A150PosCol()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A150PosCol()

nPosEns := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM5_ENSR" })
nPosCic := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM5_CICLO" })
nPosPec := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM5_PECA" })
nPosAtr := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM5_ATRIB" })
nPosAli := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM5_ALI_WT" })
nPosRec := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM5_REC_WT" })

Return(Nil)

/*/
antigo a150LinOk
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Qmt150LOK   ³ Autor ³Wanderley Gon‡alves  ³ Data ³ 20.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da Linha na GetDados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Logical Qmt150LOK(Void)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Qmt150LOK()

Local lRetorno := .t.
lRetorno := .T.
Return(lRetorno)

/*/
antigo a150TudOk
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Qmt150tOk   ³ Autor ³Wanderley Gon‡alves  ³ Data ³ 20.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da GetDados                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Logical Qmt150tOk(Void)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Qmt150tOk()

Local lRetorno := .F.
Local nd
Local nx
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda posicao dos elementos nos acols                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
a150PosCol()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa se o aCols j  esta atualizado      ³
//³ (pede para pressionar o botÆo Medi‡äes   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aCols) > 1
	If M->QM4_TIPO $ "EP"
		lRetorno := a150CalRR(.T.)
	ElseIf M->QM4_TIPO == "C"
		lRetorno := a150CurRR(.T.)
	ElseIf M->QM4_TIPO == "A"
		If nRefere == 0 //Caso de deteccao de sinal
			nRefere := Ascan(aHeader,{|x| Alltrim(x[2]) == "QM5_REFERE"})
		Endif
		If nVlRef == 0
			nVlRef := Ascan(aHeader,{|x| Alltrim(x[2]) == "QM5_VLRREF"})
		Endif

	    For nd := 1 to Len(aCols)
	        For nx := 1 to Len(aHeader) - 2
	        	If M->QM4_TPMSA == "1" .Or. M->QM4_TPMSA == "3"
					If M->QM4_TPATR == "1"
						If Empty(aCols[nd][nRefere])
							MessageDlg(OemToAnsi(STR0033),,3)// Necessario a digitacao de todas as pecas.
							lRetorno := .F.
							Return(lRetorno)
						Endif
					Else
						If Empty(aCols[nd][nVlRef])
							MessageDlg(OemToAnsi(STR0033),,3)// Necessario a digitacao de todas as pecas.
							lRetorno := .F.
							Return(lRetorno)
						Endif
					Endif
	        	Else
		        	If Empty(aCols[nd][nx])
	    	    	   MessageDlg(OemToAnsi(STR0033),,3)// Necessario a digitacao de todas as pecas.
    	    		   lRetorno := .F.
        			   Return(lRetorno)
	        		Endif
	        	Endif
	        Next nx
	    Next nd

		If Alltrim(M->QM4_TPMSA) == "2"
			lRetorno := a150CalAtri(.T.)
		Else
			lRetorno := .t.
		Endif
	EndIf
Else
	MsgInfo( Oemtoansi(STR0029), ; //"Antes de gravar cadastre as medi‡”es teclando o botao 'Medi‡”es'"
 			 Oemtoansi(STR0030) )  //"Aten‡„o"
EndIf


Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A150DelTmp  ³ Autor ³Wanderley Gon‡alves  ³ Data ³ 29.05.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Desmonta os arquivos temporarios                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void A150DelTmp                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A150DelTmp()

lMontado := .F.

If ( Select("QM5TMP") != 0 )
	oTmpTable1:Delete()
EndIf

Return(.t.)

/*/
antigo a150Grava
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Qmt150Grav  ³ Autor ³Wanderley Gon‡alves  ³ Data ³ 29.05.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Desmonta os arquivos temporarios                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void Qmt150Grav                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aFim - array com os resultados finais                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Qmt150Grav(aFim)

Local cResu		:= ""
Local cResuT	:= ""
Local cText		:= ""
Local nPVE		:= 0
Local nPVA		:= 0
Local nPRR		:= 0
Local nPVP		:= 0
Local lGrvNew	:= .F.
Local nC		:= 1
Local cRevQM4	:= ""
Local nNumQM4	:= 0
Local cTSX3Med	:= ""
Local cTSX3Usu	:= ""
Local cTSX3		:= TamSX3("QM5_MEDIC")[1]
Local dQM2Dat
Local nCntFor	:= 1
Local ny		:= 1
Local nx		:= 1
Local nCntFor2	:= 1
Local cAtividade := "06 " // Definido no ID - QKZ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o m‚todo utilizado foi o longo ou curto. A posicao dos      ³
//³ resultados no array difere entre estes dois tipos de c lculo.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->QM4_TIPO $ "E³P"

	nPVE := NoRound(aFim[1][1],2)
	nPVA := NoRound(aFim[1][2],2)
	nPRR := NoRound(aFim[1][3],2)
	nPVP := NoRound(aFim[1][4],2)

	if aFim[1][3] <= GetMv("MV_QRRIAPR")
		cResu = "A"
	elseif aFim[1][3] <= GetMv("MV_QRRICON")
		cResu = "C"
	else
		cResu = "R"
	endif

ElseIf M->QM4_TIPO == "C"

	nPRR := aFim[1][4]

	if aFim[1][4] <= GetMv("MV_QRRIAPR")
		cResu = "A"
	elseif aFim[1][4] <= GetMv("MV_QRRICON")
		cResu = "C"
	else
		cResu = "R"
	endif
ElseIf M->QM4_TIPO == "A"
	If Alltrim(M->QM4_TPMSA) == "2"
		If aFim[1][1] == "S"
		   cResu := "S"
		Else
		   cResu := "N"
		Endif
	Endif
Endif

//Declara variaveis utilizadas abaixo
cRevQM4 := Inverte(M->QM4_REVINS)
nNumQM4 := QA_NUMDEC(M->QM4_LIE)
cTSX3Med := TamSX3("QM5_MEDIC")[1]
cTSX3Usu := TamSx3("QAA_MAT")[1]

QM2->(DbSetOrder(1))
If QM2->(DbSeek(xFilial("QM2")+M->QM4_INSTR+cRevQM4))
	dQM2Dat := M->QM4_DATA + QM2->QM2_FREREP
EndIf

Begin Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava QM4                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("QM4")
If nModulo <> 47
	If !DbSeek(M->QM4_FILIAL + M->QM4_INSTR + M->QM4_REVINS + DtoS(M->QM4_DATA)+M->QM4_HORA)
		RecLock("QM4",.t.)

		For nC := 1 TO FCount()
    		FieldPut( nC, M->&( Eval( bCampo, nC ) ) )
		Next
		Replace QM4_FILIAL with xFilial("QM4")
		Replace QM4_PVE    with nPVE
		Replace QM4_PVA    with nPVA
		Replace QM4_PRR    with nPRR
		Replace QM4_PVP    with nPVP
		Replace QM4_RESULT with cResu
		Replace QM4_HORA   with M->QM4_HORA
        Replace QM4_DTPREV with dQM2Dat

		If Alltrim(M->QM4_TPMSA) == "3"
			Replace QM4_TPATR with M->QM4_TPATR
			//QM4_TPMSA for 4 Edicao de MSA gravar como 3
			Replace QM4_TPMSA with "3"
		ElseIf Alltrim(M->QM4_TPMSA) == "1"
			Replace QM4_TPATR with M->QM4_TPATR
			//QM4_TPMSA for 3 Edicao de MSA gravar como 1
			Replace QM4_TPMSA with "1"
		Else
			//QM4_TPMSA for 2 Edicao de MSA gravar como 2
			Replace QM4_TPMSA with "2"
		Endif
		lGrvNew := .T.

		MsUnlock()
        FkCommit()

   		RecLock("QM2",.f.)
		Replace QM2->QM2_VALREP with M->QM4_DATA + QM2->QM2_FREREP
		MsUnlock()
  	    FkCommit()
	Else
		RecLock("QM4",.f.)

		For nC := 1 TO FCount()
    		FieldPut( nC, M->&( Eval( bCampo, nC ) ) )
		Next

		Replace QM4_PVE    with nPVE
		Replace QM4_PVA    with nPVA
		Replace QM4_PRR    with nPRR
		Replace QM4_PVP    with nPVP
		Replace QM4_RESULT with cResu
		Replace QM4_HORA   with M->QM4_HORA
		Replace QM4_TPATR with M->QM4_TPATR

		lGrvNew := .F.
		MsUnLock()
	EndIf
Else
	dbSelectArea("QM4")
	dbSetOrder(3)
	cRevQM4 := Inverte(M->QM4_REV)
	If !DbSeek(M->QM4_FILIAL+M->QM4_PECA1+M->QM4_REV+M->QM4_CARAC+DTOS(QM4->QM4_DATA)+QM4->QM4_HORA)
		RecLock("QM4",.t.)
		For nC := 1 TO FCount()
    		FieldPut( nC, M->&( Eval( bCampo, nC ) ) )
		Next
		Replace QM4_FILIAL with xFilial("QM4")
		Replace QM4_PECA1  with M->QM4_PECA1
		Replace QM4_REV    with M->QM4_REV
		Replace QM4_REVINV with cRevQM4
		Replace QM4_CARAC  with M->QM4_CARAC
		Replace QM4_DATA   with M->QM4_DATA
		Replace QM4_LIE    with M->QM4_LIE
		Replace QM4_LSE    with M->QM4_LSE
		Replace QM4_UM     with M->QM4_UM
		Replace QM4_NENSR  with M->QM4_NENSR
		Replace QM4_NPECAS with M->QM4_NPECAS
		Replace QM4_NCICLO with M->QM4_NCICLO
		Replace QM4_PECA   with M->QM4_PECA
		Replace QM4_CARACT with M->QM4_CARACT
		Replace QM4_NUMERO with M->QM4_NUMERO
		Replace QM4_TIPO   with M->QM4_TIPO
		Replace QM4_PVE    with nPVE
		Replace QM4_PVA    with nPVA
		Replace QM4_PRR    with nPRR
		Replace QM4_PVP    with nPVP
		Replace QM4_RESULT with cResu
		Replace QM4_HORA   with M->QM4_HORA

		If Alltrim(M->QM4_TPMSA) == "3"
			Replace QM4_TPATR with M->QM4_TPATR
			//QM4_TPMSA for 4 Edicao de MSA gravar como 3
			Replace QM4_TPMSA with "3"
		ElseIf Alltrim(M->QM4_TPMSA) == "1"
			Replace QM4_TPATR with M->QM4_TPATR
			//QM4_TPMSA for 3 Edicao de MSA gravar como 1
			Replace QM4_TPMSA with "1"
		Else
			//QM4_TPMSA for 2 Edicao de MSA gravar como 2
			Replace QM4_TPMSA with "2"
		Endif


		MsUnlock()
        FkCommit()
		lGrvNew := .T.
	Else
		RecLock("QM4",.f.)
		For nC := 1 TO FCount()
    		FieldPut( nC, M->&( Eval( bCampo, nC ) ) )
		Next
		Replace QM4_LIE    with M->QM4_LIE
		Replace QM4_LSE    with M->QM4_LSE
		Replace QM4_UM     with M->QM4_UM
		Replace QM4_NENSR  with M->QM4_NENSR
		Replace QM4_NPECAS with M->QM4_NPECAS
		Replace QM4_NCICLO with M->QM4_NCICLO
		Replace QM4_PECA   with M->QM4_PECA
		Replace QM4_CARACT with M->QM4_CARACT
		Replace QM4_NUMERO with M->QM4_NUMERO
		Replace QM4_TIPO   with M->QM4_TIPO
		Replace QM4_PVE    with nPVE
		Replace QM4_PVA    with nPVA
		Replace QM4_PRR    with nPRR
		Replace QM4_PVP    with nPVP
		Replace QM4_RESULT with cResu
		Replace QM4_HORA   with M->QM4_HORA
		Replace QM4_TPATR with M->QM4_TPATR
		MsUnLock()
		lGrvNew := .F.
	EndIf

	QPP_CRONO(QM4->QM4_PECA1,QM4->QM4_REV,cAtividade) // QPPXFUN - Atualiza Cronograma

Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava QM5                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->QM4_TIPO $ "EP"
	DbSelectArea("QM5")
	DbSetOrder(1)
	QM5Tmp->(DbGoTop())
	Do while !QM5Tmp->(eof())

		For nCntFor := 1 to M->QM4_NPECAS
			cTEXT := 'QM5Tmp->PECA' + StrZero(nCntFor,2)
			cText := &cText
			cText := Alltrim(Str(cText,cTSX3,nNumQM4))
			If nModulo <> 47 //Metrologia
				If lGrvNew
					RecLock("QM5",.t.)
				Else
					QM5->(Dbseek(M->QM4_FILIAL + M->QM4_INSTR + M->QM4_REVINS +;
					DtoS(M->QM4_DATA) + QM5Tmp->QM5_ENSR +;
					Str(QM5Tmp->QM5_CICLO,2) + Str(nCntFor,2) + M->QM4_HORA))
					RecLock("QM5",.f.)
				EndIf
			Else
			// Na Ver6.10, agregar ao indice QM5 (3 e 4) os mesmos campos do indice
			// QM5 (1), fazer o mesmo com o arquivo QM4
				If lGrvNew
					RecLock("QM5",.t.)
				Else
				    dbSelectArea("QM5")
				    dbSetOrder(2)

					If QM5->(dbSeek(M->QM4_FILIAL+M->QM4_PECA1+M->QM4_REV+M->QM4_CARAC+;
							 DtoS(M->QM4_DATA)+QM5Tmp->QM5_ENSR+;
							 Str(QM5Tmp->QM5_CICLO,2)+Str(nCntFor,2)+M->QM4_HORA))
						RecLock("QM5",.f.)
					Endif

				EndIf
			Endif
			Replace QM5_FILIAL with xFilial("QM5")
			If nModulo <> 47 // Modulo Metrologia
				Replace QM5_INSTR  with M->QM4_INSTR
				Replace QM5_REVINS with M->QM4_REVINS
			Else
				Replace QM5_PECA1  with M->QM4_PECA1
				Replace QM5_REV    with M->QM4_REV
				Replace QM5_REVINV with cRevQM4
				Replace QM5_CARAC  with M->QM4_CARAC
			Endif

			Replace QM5_DATA   with M->QM4_DATA
			Replace QM5_ENSR   with QM5Tmp->QM5_ENSR
			Replace QM5_CICLO  with QM5Tmp->QM5_CICLO
			Replace QM5_PECA   with nCntFor
			Replace QM5_HORA   with M->QM4_HORA
			Replace QM5_MEDIC  with cText
			Replace QM5_FILRES with QM5Tmp->QM5_FILRES

			MsUnLock()
		Next nCntFor

		QM5Tmp->(DbSkip())
	EndDo
Else
	If (Alltrim(M->QM4_TPMSA) == "1" .OR. Alltrim(M->QM4_TPMSA) == "3") .and. M->QM4_TIPO == "A"
		For nCntFor := 1 to Len(aUseRef)
			For nx := 1 to QM4->QM4_NCICLO
				If nx == 1
					nPrim := aUseRef[nCntFor][2]
				Else
					nPrim++
				Endif
				For ny := 1 To Len(aCols)
					cRevQM4 := Inverte(M->QM4_REV)
					If nModulo <> 47
						If 	QM5->(Dbseek(M->QM4_FILIAL + M->QM4_INSTR + M->QM4_REVINS +;
							DtoS(M->QM4_DATA) + aUseRef[nCntFor][1] +;
							Str(nx,2) + Str(ny,2) + M->QM4_HORA))
							RecLock("QM5",.f.)
						Else
							RecLock("QM5",.t.)
						EndIf
					Else
						QM5->(dbSetOrder(2))
						If QM5->(dbSeek(M->QM4_FILIAL+M->QM4_PECA1+M->QM4_REV+M->QM4_CARAC+;
							DtoS(M->QM4_DATA)+aUseRef[nCntFor][1]+;
							Str(nx,2)+Str(ny,2)+M->QM4_HORA))
							RecLock("QM5",.f.)
						Else
							RecLock("QM5",.t.)
						EndIf
					Endif
					Replace QM5->QM5_FILIAL With xFilial()
					Replace QM5->QM5_DATA   With QM4->QM4_DATA
					Replace QM5->QM5_FILRES With cFilAnt
					Replace QM5->QM5_ENSR   With SubStr(aUseRef[nCntFor][1],1,cTSX3Usu)
					Replace QM5->QM5_CICLO  With nx
					Replace QM5->QM5_PECA   With ny
					Replace QM5->QM5_HORA   With QM4->QM4_HORA
					Replace QM5->QM5_ATRIB  With Alltrim(aCols[ny][nPrim])
					If nModulo == 47
						Replace QM5->QM5_PECA1  with M->QM4_PECA1
						Replace QM5->QM5_REV    with M->QM4_REV
						Replace QM5->QM5_REVINV with cRevQM4
						Replace QM5->QM5_CARAC  with M->QM4_CARAC
					Else
						Replace QM5->QM5_INSTR  With QM4->QM4_INSTR
						Replace QM5->QM5_REVINS With QM4->QM4_REVINS
					Endif

					If QM4->QM4_TPATR == "1"
						Replace QM5->QM5_REFERE With Alltrim(aCols[ny][nRefere])
					Else
						Replace QM5->QM5_VLRREF With Alltrim(aCols[ny][nVlRef])
					Endif

					If nCodig <> 0
						Replace QM5->QM5_CODIG  With Alltrim(aCols[ny][nCodig])
					Endif

					MsUnLock()
				Next ny
			Next nx
		Next nCntFor
	Else
		For nCntFor := 1 to Len(aCols)
			nEnsr := Subs(aCols[nCntFor,nPosEns],1,TamSx3("QAA_MAT")[1])
			For nCntFor2 := 1 to M->QM4_NPECAS
				cRevQM4 := Inverte(M->QM4_REV)
				nNumQM4 := QA_NUMDEC(M->QM4_LIE)
				cTSX3 := TamSX3("QM5_MEDIC")[1]
				If nModulo <> 47 //Metrologia
					If lGrvNew
						RecLock("QM5",.t.)
					Else
						QM5->(Dbseek(M->QM4_FILIAL + M->QM4_INSTR + M->QM4_REVINS +;
						DtoS(M->QM4_DATA) + nEnsr +;
						Str(aCols[nCntFor][nPosCic],2) + Str(nCntFor2,2) + M->QM4_HORA))
						RecLock("QM5",.F.)
					EndIf
				Else
					If lGrvNew
						RecLock("QM5",.t.)
        		        Else
						dbSelectArea("QM5")
						dbSetOrder(2)

						If QM5->(Dbseek(M->QM4_FILIAL + M->QM4_PECA1 + M->QM4_REV +M->QM4_CARAC +;
							DtoS(M->QM4_DATA) + nEnsr +;
							Str(aCols[nCntFor][nPosCic],2) + Str(nCntFor2,2) + M->QM4_HORA))
							RecLock("QM5",.F.)
						Endif
					Endif
				Endif
				Replace QM5_FILIAL with xFilial("QM5")
				If nModulo <> 47 // Metrologia
					Replace QM5_INSTR  with M->QM4_INSTR
					Replace QM5_REVINS with M->QM4_REVINS
				Else
					Replace QM5_PECA1  with M->QM4_PECA1
					Replace QM5_REV    with M->QM4_REV
					Replace QM5_REVINV with cRevQM4
					Replace QM5_CARAC  with M->QM4_CARAC
				Endif
				Replace QM5_DATA   with M->QM4_DATA
				Replace QM5_ENSR   with nEnsr
				Replace QM5_PECA   with nCntFor2
				Replace QM5_HORA   with M->QM4_HORA
				If M->QM4_TIPO <>"A"
					Replace QM5_CICLO  with 1
					Replace QM5_MEDIC with Alltrim(Str(aCols[nCntFor,nPosPec+nCntfor2-1],;
						cTSX3Med,nNumQM4))
				Else
					Replace QM5_CICLO  with aCols[nCntFor][nPosCic]
					Replace QM5_ATRIB with aCols[nCntFor,nPosAtr+nCntfor2-1]
				Endif
				Replace QM5_FILRES with cFilAnt
				MsUnLock()
			Next nCntFor2
		Next nCntFor
	Endif

EndIf

End Transaction

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A150TabEns  ³ Autor ³Wanderley Gon‡alves  ³ Data ³ 01.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega tabela de ensaiadores                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void A150TabEns                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SX3->X3_VALID do campo  QM4_NENSR                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A150TabEns(lSelDem)

Local nRec := QM5->(Recno())
Local nInd := Qm5->(IndexOrd())
Local nTam
Local cIndQM5 := ""
Local cKeyQM5 := ""
Local nIndexQM5 := ""
Local nCntFor := 1
Local lRet	  := .T.
Local lQM150Ens := ExistBlock("QM150Ens")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega aTabela                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aTabela := {}

DbSelectArea("QAA")
DbSetOrder(1)
dbSeek(xFilial("QAA"))
While !eof() .and. QAA->QAA_FILIAL == xFilial("QAA")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No caso de inclusao, para ensaios de Repe/Repro nao permitir usuarios com ³
	//³status inativo.															 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lQM150Ens
		lRet := ExecBlock("QM150Ens",.F.,.F.,{QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_NOME,QAA->QAA_CC})
	EndIf
	If lRet
		If Inclui
			If QA_SitFolh() //Status diferente de inativo
				Aadd(aTabela,{ .F., QAA->QAA_MAT+" - "+QAA->QAA_NOME } )
			Endif
		Else
			Aadd(aTabela,{ .F., QAA->QAA_MAT+" - "+QAA->QAA_NOME } )
		Endif
	EndIf
	QAA->(DbSkip())
EndDo

dbSelectArea("QM5")
If nModulo == 47
	QM5->(DbSetOrder(2))
	cKeyQM5	:= "QM5_FILIAL+QM5_PECA1+QM5_REV+QM5_CARAC+DTOS(QM5_DATA)"
Else
	QM5->(DbSetOrder(1))
	cKeyQM5	:= "QM5_FILIAL+QM5_INSTR+QM5_REVINS+DTOS(QM5_DATA)"
Endif

nUsuar := 0

cIndQM5	:= CriaTrab( nil,.f. )

IndRegua( "QM5",cIndQM5, cKeyQM5,,,STR0058) //"Selectionando Registros..."
nIndexQM5 := RetIndex("QM5")
dbSelectArea("QM5")
//dbSetOrder(nIndexQM5+1)
DbGoTop()

If nModulo <> 47 // Modulo Metrologia
	If QM5->(DbSeek(xFilial("QM5")+M->QM4_INSTR+M->QM4_REVINS+DtoS(M->QM4_DATA)))
		Do while xFilial("QM5")+M->QM4_INSTR+M->QM4_REVINS+DtoS(M->QM4_DATA) ==;
			QM5->QM5_FILIAL+QM5->QM5_INSTR+QM5->QM5_REVINS+DtoS(QM5->QM5_DATA);
			.and. !QM5->(Eof())
			If M->QM4_HORA == QM5->QM5_HORA
				For nCntFor := 1 to len(aTabela)
					nTam := TamSx3("QAA_MAT")[1]
					If AllTrim(Substr(aTabela[nCntFor,2],1,nTam)) == AllTrim(QM5->QM5_ENSR)
						If !aTabela[nCntFor,1]
							nCtUser++
						Endif
						aTabela[nCntFor,1] := .T.
					EndIf
				Next nCntFor
				If M->QM4_TPATR <> "1"
					QM5->(DbSkip(M->QM4_NENSR*M->QM4_NCICLO))
				Else
					nUsuar++
					If nUsuar <> (M->QM4_NENSR-1) //Para considerar o ultimo usuario
						QM5->(DbSkip(M->QM4_NPECAS*M->QM4_NCICLO))
					Endif
				Endif
			Endif
			dbSelectArea("QM5")
			dbSkip()
		EndDo
	EndIf
Else
    dbSelectArea("QM5")
    QM5->(dbSetOrder(2))
	If QM5->(DbSeek(xFilial("QM5")+M->QM4_PECA1+M->QM4_REV+M->QM4_CARAC))
		Do while xFilial("QM5")+M->QM4_PECA1+M->QM4_REV+M->QM4_CARAC ==;
			QM5->QM5_FILIAL+QM5->QM5_PECA1+QM5->QM5_REV+QM5->QM5_CARAC .and. !QM5->(Eof())
			If DtoS(M->QM4_DATA) == DtoS(QM5->QM5_DATA) .and. M->QM4_HORA == QM5->QM5_HORA
				For nCntFor := 1 to len(aTabela)
					nTam := TamSx3("QAA_MAT")[1]
					If AllTrim(Substr(aTabela[nCntFor,2],1,nTam)) == AllTrim(QM5->QM5_ENSR)
						If !aTabela[nCntFor,1]
							nCtUser++
						Endif
						aTabela[nCntFor,1] := .T.
					EndIf
				Next nCntFor
				If M->QM4_TPATR <> "1"
					QM5->(DbSkip(M->QM4_NENSR*M->QM4_NCICLO))
				Else
					nUsuar++
					If nUsuar <> (M->QM4_NENSR-1) //Para considerar o ultimo usuario
						QM5->(DbSkip(M->QM4_NPECAS*M->QM4_NCICLO))
					Endif
				Endif
			Endif
			dbSelectArea("QM5")
			dbSkip()
		EndDo
	EndIf

Endif

dbSelectArea("QM5")
Set Filter to
RetIndex("QM5")
FErase (cIndQM5+OrdBagExt())

QM5->(DbGoTo(nRec))
QM5->(Dbsetorder(nInd))

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A150Recup   ³ Autor ³Wanderley Gon‡alves  ³ Data ³ 01.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Recupera Medicoes cadastradas                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void A150Recup                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A150Recup()

Local nCntFor
Local nCntFor2
Local nEnsr
Local nPrim := 0
Local nx := 1
Local ny := 1

If nRefere == 0 //Caso de deteccao de sinal
	nRefere := Ascan(aHeader,{|x| Alltrim(x[2]) == "QM5_REFERE"})
Endif

If nVlRef == 0
	nVlRef := Ascan(aHeader,{|x| Alltrim(x[2]) == "QM5_VLRREF"})
Endif
DbSelectArea("QM5")

If nModulo == 47
	QM5->(DbSetOrder(2))
Else
	QM5->(DbSetOrder(1))
Endif

	If (Alltrim(M->QM4_TPMSA) == "1" .OR. Alltrim(M->QM4_TPMSA) == "3") .and. M->QM4_TIPO == "A"
		For nCntFor := 1 to Len(aCols)
			For ny := 1 To M->QM4_NENSR
				nEnsr  := Subs(aUseRef[ny,1],1,TamSx3("QAA_MAT")[1])
				nPrim  := aUseRef[ny,2]
				For nx := 1 to M->QM4_NCICLO
					If nx > 1
						nPrim++
					Endif
					If nModulo == 47
					    QM5->(dbSetOrder(2))
						If QM5->(dbSeek(xFilial("QM5")+M->QM4_PECA1+M->QM4_REV+M->QM4_CARAC+;
							 DtoS(M->QM4_DATA)+nEnsr+;
							 Str(nx,2)+Str(nCntFor,2)+M->QM4_HORA))

							aCols[nCntFor,nPrim] := QM5->QM5_ATRIB

							If M->QM4_TPATR == "1" //Cross Tab
								aCols[nCntFor,nRefere]	:= QM5->QM5_REFERE
							Else //Se for sinal de deteccao
								aCols[nCntFor,nVlRef]	:= QM5->QM5_VLRREF
							Endif

							If nCodig > 0
								aCols[nCntFor,nCodig]	:= QM5->QM5_CODIG
							Endif
						Endif
					Else
						If QM5->(DbSeek(xFilial("QM5")+M->QM4_INSTR+M->QM4_REVINS+	DtoS(M->QM4_DATA)+nEnsr+Str(nx,2)+Str(nCntFor,2)+M->QM4_HORA))
							aCols[nCntFor,nPrim] := QM5->QM5_ATRIB

							If M->QM4_TPATR == "1" //Cross Tab
								aCols[nCntFor,nRefere]	:= QM5->QM5_REFERE
							Else //Se for sinal de deteccao
								aCols[nCntFor,nVlRef]	:= QM5->QM5_VLRREF
							Endif

							If nCodig > 0
								aCols[nCntFor,nCodig]	:= QM5->QM5_CODIG
							Endif
						Endif
					Endif
					If nPosAli > 0 .and. nPosRec > 0
						aCols[nCntFor,nPosAli] := QM5->(Alias())
						If IsHeadRec(aHeader[nPosRec,2])
							aCols[nCntFor,nPosRec] := IIf(lQuery,QM5->QM5RECNO,QM5->(RecNo()))
						EndIf
					Endif
				Next nx
			Next ny
		Next nCntFor
	Else
		For nCntFor := 1 to M->QM4_NENSR*M->QM4_NCICLO
			If nModulo <> 47 // Se for Metrologia
				nEnsr := Subs(aCols[nCntFor,nPosEns],1,TamSx3("QAA_MAT")[1])
				For nCntFor2 := 0 to M->QM4_NPECAS-1
					If QM5->(DbSeek(xFilial("QM5")+M->QM4_INSTR+M->QM4_REVINS+;
						DtoS(M->QM4_DATA)+;
						nEnsr+;              // aCols[nCntFor,nPosEns]+;
						Str(aCols[nCntFor,nPosCic],2)+Str(nCntFor2+1,2)+M->QM4_HORA))
						If M->QM4_TIPO <> "A"
							aCols[nCntFor,nPosPec+nCntFor2] := Val(QM5->QM5_MEDIC)
						Else
							aCols[nCntFor,nPosAtr+nCntFor2] := QM5->QM5_ATRIB
						Endif
					EndIf
				Next nCntFor2
			Else
				dbSelectArea("QM5")
				nEnsr := Subs(aCols[nCntFor,nPosEns],1,TamSx3("QAA_MAT")[1])
				For nCntFor2 := 0 to M->QM4_NPECAS-1

					QM5->(dbSetOrder(2))

					If QM5->(DbSeek(xFilial("QM5")+M->QM4_PECA1+M->QM4_REV+M->QM4_CARAC+DtoS(M->QM4_DATA)+nEnsr+Str(aCols[nCntFor,nPosCic],2)+Str(nCntFor2+1,2)+M->QM4_HORA))
						If M->QM4_TIPO <> "A"
							aCols[nCntFor,nPosPec+nCntFor2] := Val(QM5->QM5_MEDIC)
						Else
							aCols[nCntFor,nPosAtr+nCntFor2] := QM5->QM5_ATRIB
						Endif
					EndIf
				Next nCntFor2
			Endif
			If nPosAli > 0 .and. nPosRec > 0
				aCols[nCntFor,nPosAli] := QM5->(Alias())
				If IsHeadRec(aHeader[nPosRec,2])
					aCols[nCntFor,nPosRec] := IIf(lQuery,QM5->QM5RECNO,QM5->(RecNo()))
				EndIf
			Endif
		Next nCntFor
	Endif
Return(Nil)

/*/
antiga A150Valida
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³qmt150Valid ³ Autor ³Wanderley Gon‡alves  ³ Data ³ 02.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida quantidade de ensaiadores, pecas e ciclos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ qmt150Valid(cVAR)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cVar := indica tipo de campo                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SX3->X3_VALID do campo  QM4_NPECAS                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function qmt150Valid(cVar)

Local lMessage := .F.
Local lRet := .t.
Local nRegs := 0
Local aArea := GetArea()
Local lMSA3ed:= .F.
dbSelectArea("QAA")
dbSetOrder(1)

nRegs := QAA->(LastRec())

RestArea(aArea)
//Verifica o numero de ensaiadores com o numero de funcionarios
If M->QM4_NENSR <= nRegs
	If Alltrim(M->QM4_TPMSA) == "2"
		If cVar == "ENSR" .and. (M->QM4_NENSR < 2 .or. M->QM4_NENSR > 15 )
			lMessage := .t.
		ElseIf cVar == "PECA" .and. (M->QM4_NPECAS < 2 .or. M->QM4_NPECAS > 15)
			lMessage := .t.
		ElseIf cVar == "CICL"
			If M->QM4_TIPO $ "EP" .and. (M->QM4_NCICLO < 2 .or. M->QM4_NCICLO > 15 )
				lMessage := .t.
			EndIf
		Endif
	Else
		If cVar == "ENSR" .and. (M->QM4_NENSR < 2 .or. M->QM4_NENSR > 5 )
			lMSA3ed := .t.
		ElseIf cVar == "PECA" .and. (M->QM4_NPECAS < 2 .or. M->QM4_NPECAS > 50)
			lMSA3ed := .t.
		ElseIf cVar == "CICL"
			If M->QM4_TIPO $ "EP" .and. (M->QM4_NCICLO < 2 .or. M->QM4_NCICLO > 15 )
				lMSA3ed := .t.
			ElseIf M->QM4_TIPO == "A" .and. (M->QM4_NCICLO < 2 .or. M->QM4_NCICLO > 3 )
				lMSA3ed := .t.
			EndIf
		Endif
	Endif
	If lMessage
		Help(" ",1,"A150VALIDA")  // N£mero minimo de ensaiadores, pecas ou ciclos:  2
		// Numero maximo de ensaiadores, pecas ou ciclos: 15
		lRet := .f.
	EndIf

	If lMSA3ed
		MessageDlg(STR0054+Chr(13)+Chr(10)+;	//"Numero minimo/maximo de ensaiadores: 2 / 5"
		STR0055+Chr(13)+Chr(10)+;				//"Numero minimo/maximo de pecas: 2 / 50"
		STR0056,,3)								//"Numero minimo/maximo de ciclos: 2 / 3"
		lRet := .F.
	Endif
Else
	MessageDlg(STR0041,,3) //"Numero de ensaiadores maior que numero de registros do arquivo de funcionarios."
	M->QM4_NENSR := QAA->(RecCount())
	lRet := .F.
Endif
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A150Excl ³ Autor ³ Wanderley Goncalves   ³ Data ³02.06.98  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclusao de Ensaio de R&R                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A150Excl()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A150Excl(cAlias,nReg,nOpcx)

Local oDlg
Local nOpcA      := 0
Local nCntFor    := 0 
Local nUsado := 0
//Local aCA := { OemToAnsi(STR0007), OemToAnsi(STR0009) } // "Confirma" ### "Abandona"
Local aButtons := {}
Local oEnchoice

Private aTela[0][0],aGets[0]
Private bCampo := { |nField| Field(nField) }
Private CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP
Private aHeader := {}
Private aCols   := {}
Private nOpcao := nOpcx
PRIVATE aTabela := {}
Private nPosEns
Private nPosCic
Private nPosPec
Private nPosAtr
Private nPosAli
Private nPosRec
Private cQM5ATP
Private aCont := {}
Private oMedi
Private aTot	:= {}
Private aComb	:= {}
Private	aNew	:= {}
Private	aUseRef	:= {}
Private	aRef	:= {}
Private aSomRef	:= {}
Private nRefere := 0
Private nVlRef := 0
Private nCodig	:= 0
Private oBtn1
Private oBtn2
Private nSomRef	:= 0
Private nRep1	:= 0
Private nRep2	:= 0
Private nRep3	:= 0
Private nRep4	:= 0
Private nReptot := 0
Private aCoUser := {}
Private nCtUser	:= 0
Private nRepReR := 0
Private cMensg	:= ""
Private lNaoPd	:= .F.

If nModulo == 47 // PPAP
	aButtons := { {"BMPVISUAL", { || QMTR150() } , OemToAnsi(STR0042) }} //"Visualizar/Imprimir"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa as Variaveis da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QM4")
For nCntFor:= 1 To FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next nCntFor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Tabela de Ensaiadores                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
a150TabEns()
If Len(aTabela) > 0 .and. nCtUser == M->QM4_NENSR

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aCols e aHeader                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols := {}
	A150Monta()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Guarda posicao dos elementos nos acols                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	a150PosCol()

	If (Alltrim(M->QM4_TPMSA) == "1" .OR. Alltrim(M->QM4_TPMSA) == "3") .and. M->QM4_TIPO == "A"
		qmt150UseRef()
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recupera medicoes cadastradas                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	a150Recup()

	DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 35,86
	oEnchoice := Msmget():New( "QM4" ,nReg,nOpcx,,,,,aPos,,3,,,"A150EnOK",,,.t.)

	oGet := MsGetDados():New(72,1,180,338,nOpcx,"Qmt150LOK","Qmt150tOk","",,,2)
	ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{||Iif(oGet:TudoOk(),(nOpca := 1,oDlg:End()),nOpca:=0)},{||nOpca:=0,oDlg:End()}, , aButtons),;
									AlignObject(oDlg,{oEnchoice:oBox,oGet:oBrowse},1,2,{195})) CENTERED

	If ( nOpcA == 1 )

		Begin Transaction

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apaga registros de medicao - QM5                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QM5")
		If nModulo <> 47 // Metrologia
			QM5->(DbSetOrder(1))
			If QM5->(DbSeek(xFilial("QM5")+M->QM4_INSTR+M->QM4_REVINS+DtoS(M->QM4_DATA)))
				Do while xFilial("QM5")+M->QM4_INSTR+M->QM4_REVINS+DtoS(M->QM4_DATA) ==;
					QM5->QM5_FILIAL+QM5->QM5_INSTR+QM5->QM5_REVINS+DtoS(QM5->QM5_DATA);
					.and. !QM5->(Eof())
					If M->QM4_HORA == QM5->QM5_HORA
						RecLock( "QM5",.f.,.t.)
						dbDelete()
						MsUnLock()
						FkCommit()
					Endif
					QM5->(DbSkip())
				EndDo
			EndIf
		Else

			dbSelectArea("QM5")
			dbSetOrder(2)
			If QM5->(DbSeek(xFilial("QM5")+M->QM4_PECA1+M->QM4_REV+M->QM4_CARAC))
				Do while xFilial("QM5")+M->QM4_PECA1+M->QM4_REV+M->QM4_CARAC ==;
					QM5->QM5_FILIAL+QM5->QM5_PECA1+QM5->QM5_REV+QM5->QM5_CARAC .and. !QM5->(Eof())

					RecLock( "QM5",.f.,.t.)
					dbDelete()
					MsUnLock()
					FkCommit()
					QM5->(DbSkip())
				EndDo
			EndIf

		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apaga registro "Mestre" no QM4                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea( cAlias )
		RecLock( cAlias ,.f.,.t.)
		dbDelete( )
		MsUnlock()

		End Transaction

	EndIf

Else
	MsgInfo(STR0052,STR0053) //"Estudo realizado em outra filial","Aviso"
Endif

Return(.t.)

/*/
antigo A150WhInc
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³qmt150WhIn³ Autor ³ Wanderley Goncalves   ³ Data ³02.06.98  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Evita alteracao de dados no QM4                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ qmt150WhIn()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function qmt150WhIn(lCons)
Default lCons := .f.
cRet := .f.
If Inclui
	cRet := .t.
Else
	cRet := .f.
EndIf
If cRet
	If lCons
		If lNaoPd
			cRet := .t.
		Else
			cRet := .f.
		Endif
	Endif
Endif
Return(cRet)

/*/
antigo A150Chave
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³qmt150Chv ³ Autor ³ Wanderley Goncalves   ³ Data ³ 02/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida‡Æo dos campos chave                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA010 - E' chamada no X3_VALID.                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function qmt150Chv()
LOCAL lRet := .T.

If ! Empty( M->QM4_INSTR ) .and. ! Empty( M->QM4_REVINS )
	DbSelectArea("QM2")
	DbSetOrder(1)
	If !Dbseek(xFilial("QM2") + M->QM4_INSTR + Inverte(M->QM4_REVINS))
       Help(" ", 1, "QMTINSTNAO") // Instrumento/Revisao nao cadastrado
	   lRet := .F.
	EndIf
EndIf

If ! Empty( M->QM4_INSTR ) .and. ! Empty( M->QM4_REVINS ) .and.	! Empty( M->Qm4_DATA  )
	dbSelectArea("QM4")
	If dbSeek( xFilial("QM4") + M->QM4_INSTR + M->QM4_REVINS + DtoS(M->QM4_DATA) + M->QM4_HORA)
		Help( " ", 1, "JAGRAVADO" )
		lRet := .F.
	Endif
EndIf

Return( lRet )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QMT150LMCP³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 29/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Limpa campos quando se altera o Tipo do Ensaio             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA010 - E' chamada no X3_VALID do QM4_TIPO	              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMT150LMCP()
If (AllTrim(cTipoAnt) <> Alltrim(M->QM4_TIPO) .OR. Empty(AllTrim(cTipoAnt)) )
	M->QM4_NPECAS := 0
	M->QM4_NCICLO := 0
	cTipoAnt := M->QM4_TIPO
	If M->QM4_TIPO == "A"
		M->QM4_LIE := REPL(" ",TamSx3("QM4_LIE")[1]-1)+"0"
		M->QM4_LSE := REPL(" ",TamSx3("QM4_LIE")[1])
	EndIf
EndIf
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a150NumEns³ Autor ³ Fernando Godoy        ³ Data ³ 6/9/1998 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Numero de ensaiadores escolhidos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Qmta150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function a150NumEns(nEnsaia,aTabela)
Local nI := 1

nEnsaia := 0

For nI := 1 to Len( aTabela )
	If ( aTabela[nI,1] )
		nEnsaia ++
	EndIf
Next nI

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a150Destro³ Autor ³ Fernando Godoy        ³ Data ³6/10/1998 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Destroy a Getdados e recontroi com as colunas certas       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QMTA150.prw                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function a150Destroy( oGet_1,oDlg, oBtn,nOpc)
Local lRet := .T.

If M->QM4_TIPO $ "EP" .and. (M->QM4_NPECAS * M->QM4_NCICLO) < 15
	Help(" ",1,"A150MINIMO")  // O N£mero de medi‡”es multiplicado pelo n£mero   2
											  // de pe‡as n„o pode ser menor que 15.
	lRet := .F.
EndIf

If nModulo == 47 //Modulo PPAP
	If ( lRet )
		If empty(M->QM4_PECA1)  .or. empty(M->QM4_REV) .or.;
			empty(M->QM4_DATA)   .or. empty(M->QM4_NENSR)  .or.;
			empty(M->QM4_NPECAS) .or. empty(M->QM4_NCICLO) .or.;
			empty(M->QM4_TIPO)
			lRet := .F.
		EndIf
	EndIf
Else
	If ( lRet )
		If empty(M->QM4_INSTR)  .or. empty(M->QM4_REVINS) .or.;
			empty(M->QM4_DATA)   .or. empty(M->QM4_NENSR)  .or.;
			empty(M->QM4_NPECAS) .or. empty(M->QM4_NCICLO) .or.;
			empty(M->QM4_TIPO)
			lRet := .F.
		EndIf
	EndIf
Endif

If ( lRet )
	n           := 1
	aCols       := {}
	aHeader     := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aCols e aHeader                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A150Monta(nOpc)

	If lExist
		nUsado  := Len(aHeader)

		If ( lRet )
//			oGet_1:oBrowse:Destroy()
	        oGet_1 := MsGetDados():New( 72,1,180,338,3,"Qmt150LOK","Qmt150tOk","",,,2,,,,,,,oDlg)
	        oGet_1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	        oGet_1:oBrowse:lDisablePaint := .T.
	        oGet_1:oBrowse:Refresh()
	        oGet_1:ForceRefresh()
	        oGet_1:oBrowse:lDisablePaint := .F.
	        oGet_1:oBrowse:Refresh()
	        lNaoPd := .F.
		EndIf

		oDlg:Refresh()

//		If oGet_1 <> Nil
//			@ 184,2 SAY oMedi PROMPT OemToAnsi(STR0044)+Alltrim(Str(n)) SIZE 100,15 FONT oMonoAs OF oDlg PIXEL //Peca
//			If M->QM4_TIPO <> "A"
//				oMedi:Hide()
//			Endif
//		Endif

		oBtn:Disable()
		oBtn:Refresh()

		If (Alltrim(M->QM4_TPMSA) == "1" .OR. Alltrim(M->QM4_TPMSA) == "3") .and. M->QM4_TIPO == "A"
			oBtn1:Show()
			oBtn1:Enable()
			oBtn1:Refresh()
			oBtn2:Show()
			oBtn2:Refresh()
		Endif
	Endif
Else
	oBtn:Enable()
	oBtn:Refresh()
EndIf

If Alltrim(M->QM4_TPMSA) == "1" .OR. Alltrim(M->QM4_TPMSA) == "3"
	If M->QM4_TIPO == "A"
		oMedi:Show()
		oGet_1:oBrowse:bChange := {||oMedi:SetText("Peca: "+Alltrim(Str(n)))}
		oMedi:Refresh()
	Endif
Endif
Return lRet

/*/
antigo a150ValLSE
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³qmt150VLSE³ Autor ³ Wanderley Goncalves   ³ Data ³ 15/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida LSE em relacao a LIE                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ X3_VALID do QM4_LSE                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function qmt150VLSE()

Local lRet := .t.
Local nLSE
Local nLIE

If !empty(M->QM4_LSE) .and. !empty(M->QM4_LIE)

	If valtype(M->QM4_LSE) == "C"
		nLSE := SuperVal(M->QM4_LSE)
	Else
		nLSE := M->QM4_LSE
	EndIf

	If valtype(M->QM4_LIE) == "C"
		nLIE := SuperVal(M->QM4_LIE)
	Else
		nLIE := M->QM4_LIE
	EndIf

	If nLSE - nLIE < 0 .or. nLSE < nLIE
		Help(" ",1,"A150VALLSE")  // Limite Inferior nao pode ser maior que o
										  // Limite Superior
		lRet := .f.
	EndIf

EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a150EnOK  ³ Autor ³ Wanderley Goncalves   ³ Data ³ 08/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ TudoOK na Enchoice da R&R                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QMAT150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function a150EnOK()

Local lRet := .t.
If nModulo <> 47
	IF Empty(M->QM4_INSTR).or. Empty(M->QM4_TIPO)
		MessageDlg(STR0076,,3)//"O campo instrumento e/ou tipo de Ensaio não foi preenchido. Para as medições os campos deverão ser preenchidos"
		Return(.F.)
	Endif
Else
	IF Empty(M->QM4_PECA1).or. Empty(M->QM4_TIPO) .or. Empty(M->QM4_CARAC)
		MessageDlg(STR0077,,3)//"O campo peça e/ou tipo de Ensaio e/ou Característica não foi preenchido. Para as medições os campos deverão ser preenchidos"
		Return(.F.)
	Endif
Endif

If M->QM4_TIPO == "C"
	If (M->QM4_NPECAS < 5 .or. M->QM4_NPECAS > 15) .or.;
		!(M->QM4_NENSR == 2) .or.;
		!(M->QM4_NCICLO == 1)
		Help(" ",1,"A150CURTO")  // "Parƒmetros necess rios para aplica‡„o do m‚todo curto:
										 // "2 Operadores"
										 // "1 Ciclo"
										 // "5 a 15 Pe‡as"
		lRet := .f.
	EndIf
ElseIf M->QM4_TIPO $ "EP"
	If (M->QM4_NPECAS < 2 .or. M->QM4_NPECAS > 25) .or.;  //15
		(M->QM4_NENSR  < 2 .or. M->QM4_NENSR  > 15) .or.;
		(M->QM4_NCICLO  < 2 .or. M->QM4_NCICLO  > 15)
		Help(" ",1,"A150OUTRO")  // "Parƒmetros necess rios para aplica‡„o destes m‚todos:
										 // "2 a 15 Operadores"
										 // "2 a 15 Ciclos"
										 // "2 a 15 Pe‡as"
		lRet := .f.
	EndIf
ElseIf M->QM4_TIPO $ "A"
	If (M->QM4_NPECAS < 2 .or. M->QM4_NENSR  < 2 .or. M->QM4_NCICLO  < 2)
		Help(" ",1,"A150ATRIB")  // Para o método por Atributo é necessário o preenchimento dos Número de Ensaiadores, Número de Ciclos e Número de Peças
		lRet := .f.
	EndIf
EndIf

If !lRet
	oBtn:Enable()
	oBtn:Refresh()
Else
	oBtn:Disable()
	oBtn:Refresh()
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a150MonTel³ Autor ³ Wanderley Goncalves   ³ Data ³ 09/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta Tela de apresentacaod de resultados conforme tipo    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QMAT150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function a150MonTel()

If M->QM4_TIPO == "E"                                        //Para tolerância de especificacao
	@ 20,04 SAY OemToAnsi(STR0022) Color "N/BG" // "%V.E.:"
	@ 20,18 SAY "%" Color "N/BG"
	@ 20,23 SAY OemToAnsi(STR0023) Color "N/BG" // "%V.A.:"
	@ 20,37 SAY "%" Color "N/BG"
	@ 20,42 SAY OemToAnsi(STR0024) Color "N/BG" // "%R&R.:"
	@ 20,56 SAY "%" Color "N/BG"
	@ 20,61 SAY OemToAnsi(STR0025) Color "N/BG" // "%V.P.:"
	@ 20,75 SAY "%" Color "N/BG"
	@ 21,30 SAY OemToAnsi(STR0026) Color "N/BG" // "Resultado: "
ElseIf M->QM4_TIPO == "P"                                     //Para tolerância de processo
	@ 20,04 SAY OemToAnsi(STR0022) Color "N/BG" // "%V.E.:"
	@ 20,18 SAY "%" Color "N/BG"
	@ 20,23 SAY OemToAnsi(STR0023) Color "N/BG" // "%V.A.:"
	@ 20,37 SAY "%" Color "N/BG"
	@ 20,42 SAY OemToAnsi(STR0024) Color "N/BG" // "%R&R.:"
	@ 20,56 SAY "%" Color "N/BG"
	@ 20,61 SAY OemToAnsi(STR0025) Color "N/BG" // "%V.P.:"
	@ 20,75 SAY "%" Color "N/BG"
	@ 21,89 SAY OemToAnsi(STR0077) Color "N/BG" // "V.T.: "
	@ 21,30 SAY OemToAnsi(STR0026) Color "N/BG" // "Resultado: "
ElseIf M->QM4_TIPO == "C"                                     //Para metodo curto
	@ 20,04 SAY OemToAnsi(STR0027) Color "N/BG" // "Amplitude M‚dia: "
	@ 20,34 SAY OemToAnsi(STR0028) Color "N/BG" // "G R&R: "
	@ 20,53 SAY OemToAnsi(STR0024) Color "N/BG" // "%R&R.:"
	@ 20,73 SAY "%" Color "N/BG"
	@ 21,30 SAY OemToAnsi(STR0026) Color "N/BG" // "Resultado: "
EndIf

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a150CurRR ³ Autor ³ Wanderley Goncalves   ³ Data ³ 09/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de Calculo para R&R Curto                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ lTela -> Se .t., exibir na tela, senao guardar em array    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QMAT150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function a150CurRR(lTela)

Local nD2
Local nCntFor
Local aAmp := {}
Local nAmp := 0
Local nGRR := 0
Local nTole
Local nPerRR
Local aTab := array(15,1)
Local lRet     := .T.
Local oDlgCalRR
Local cCorREsu := CLR_HRED
Local oFnt

lRet     := .F.
atab[ 1,1] := 1.41 // Nao utiliza
atab[ 2,1] := 1.28
atab[ 3,1] := 1.23
atab[ 4,1] := 1.21
atab[ 5,1] := 1.19
atab[ 6,1] := 1.18
atab[ 7,1] := 1.17
atab[ 8,1] := 1.17
atab[ 9,1] := 1.16
atab[10,1] := 1.16
atab[11,1] := 1.16
atab[12,1] := 1.15
atab[13,1] := 1.15
atab[14,1] := 1.15
atab[15,1] := 1.15

nD2 := aTab[M->QM4_NPECAS,1]


For nCntFor := nPosPec to nPosPec+M->QM4_NPECAS-1
	aadd(aAmp,abs(aCols[1,nCntFor] - aCols[2,nCntFor]))
Next nCntFor

For nCntFor := 1 to len(aAmp)
	nAmp := nAmp + aAmp[nCntFor]
Next nCntFor

nAmp := nAmp / Len(aAmp)


If Alltrim(M->QM4_TPMSA) == "1" .OR. Alltrim(M->QM4_TPMSA) == "3"
	nGRR := 5.15 * nAmp / nD2
Else
	nGRR := nAmp / nD2
Endif

nTole  = abs(SuperVal(M->QM4_LSE) - SuperVal(M->QM4_LIE))

nPerRR := 100 * (nGRR / nTole )

if nPerRR <= GetMv("MV_QRRIAPR")
	cresu = alltrim(GetMv("MV_QRRTAPR"))    // "BOM"
	cCorResu := CLR_GREEN
elseif nPerRR <= GetMv("MV_QRRICON")
	cresu = alltrim(GetMv("MV_QRRTCON"))    // "ACEITAVEL"
	cCorResu := CLR_YELLOW
else
	cresu = alltrim(GetMv("MV_QRRTREP"))    // "INACEITAVEL"
	cCorResu := CLR_HRED
endif

If lTela
	DEFINE FONT oFnt NAME "Arial" BOLD

	DEFINE MSDIALOG oDlgCalRR TITLE "Resultado" FROM 10,10 TO 140,300 ;
	OF GetWndDefault() PIXEL

	@ 03,05 TO 60,110 OF oDlgCalRR PIXEL

	@ 10,10 SAY OemToAnsi(STR0027) SIZE 30,7 OF oDlgCalRR FONT oFnt PIXEL // "Amplitude M‚dia: "
	@ 20,10 SAY OemToAnsi(STR0028) SIZE 30,7 OF oDlgCalRR FONT oFnt PIXEL // "G R&R: "
	@ 30,10 SAY OemToAnsi(STR0024) SIZE 30,7 OF oDlgCalRR FONT oFnt PIXEL // "%R&R.:"
	@ 51,10 SAY OemToAnsi(STR0026) SIZE 30,7 OF oDlgCalRR FONT oFnt PIXEL // "Resultado: "


	@ 20,21 SAY nAMP   PICTURE QMT140PicS("nAmp",M->QM4_LIE,.t.)
	@ 20,41 SAY nGRR   PICTURE QMT140PicS("nGRR",M->QM4_LIE,.t.)
	@ 20,60 SAY nPerRR PICTURE QMT140PicS("nPerRR",M->QM4_LIE,.t.)


	@ 10, 60 SAY nAMP             SIZE 45, 7 OF oDlgCalRR PICTURE QMT140PicS("nAmp",M->QM4_LIE,.t.) PIXEL FONT oFnt RIGHT
	@ 20, 60 SAY nGRR             SIZE 45, 7 OF oDlgCalRR PICTURE QMT140PicS("nGRR",M->QM4_LIE,.t.) PIXEL FONT oFnt RIGHT
	@ 30, 60 SAY nPerRR           SIZE 45, 7 OF oDlgCalRR PICTURE QMT140PicS("nPerRR",M->QM4_LIE,.t.)PIXEL FONT oFnt RIGHT
	@ 50, 60 SAY Alltrim(cResu)   SIZE 45, 7 OF oDlgCalRR PIXEL FONT oFnt RIGHT COLOR cCorResu

	DEFINE SBUTTON FROM 05, 115 TYPE 1 ENABLE OF oDlgCalRR Action (lRet := .T.,oDlgCalRR:End()) PIXEL
	DEFINE SBUTTON FROM 18, 115 TYPE 2 ENABLE OF oDlgCalRR Action (lRet := .F.,oDlgCalRR:End()) PIXEL

	ACTIVATE MSDIALOG oDlgCalRR CENTERED

	oFnt:End()

EndIf
aadd( aFim, { aAmp, nAmp, nGRR, nPerRR, nD2 , cResu} )

Return(lRet)

/*
antiga a150ResBr
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³qmt150ReBr³ Autor ³ Alessandro B. Freire  ³ Data ³ 15/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o resultado o campo QM4_RESULT na mBrowse          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QMAT150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt150ReBr()

Local cRetorno := ""

If QM4->QM4_RESULT == "A"
	cRetorno := GetMv("MV_QRRTAPR")
ElseIf QM4->QM4_RESULT == "C"
	cRetorno := GetMv("MV_QRRTCON")
ElseIf QM4->QM4_RESULT == "R"
	cRetorno := GetMv("MV_QRRTREP")
ElseIf QM4->QM4_RESULT == "S"
	cRetorno := OemToAnsi(STR0035) //Sistema Capaz
ElseIf QM4->QM4_RESULT == "N"
	cRetorno := OemToAnsi(STR0034)	//Sistema Nao Capaz
EndIf

Return( cRetorno )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A150CAtri³ Autor ³ Denis Martins         ³ Data ³ 23/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o Calculo de R&R por Atributo e Capaz.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A150CalAtri()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ lTela -> Se .t., exibir na tela.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A150CalAtri(lTela)
Local nd
Local nx
Local cPriMed
Local oDlgCalRR
Local cCorREsu := CLR_HRED
Local oFnt
Local lRet := .F.
Local cSistInfo := ""
Local nPecasC	:= 0
Local nPecasNc	:= 0
Local nCount	:= 0
Local nCntFor
Local aQM5Atr  := {}
aFim := {}
cPriMed := aCols[1][3]
For nd := 1 to Len(aCols)
	For nx := 3 to Len(aHeader) - 2
	   nCount++
	   If aCols[nd][nx] == "1"
           nPecasC++
	   Else
       	   nPecasNC++
	   Endif
	Next nx
Next nd

If nPecasNC == nCount
   cSistInfo := OemToAnsi(STR0035) // Sistema Capaz
   cCorResu := CLR_GREEN
   cResu := "S"
ElseIf  nPecasC == nCount
   cSistInfo := OemToAnsi(STR0035) // Sistema Capaz
   cCorResu := CLR_GREEN
   cResu := "S"
Else
   cSistInfo:= OemToAnsi(STR0034) // Sistema Nao Capaz
   cCorResu := CLR_HRED
   cResu	:= "N"
   lRet		:= .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arq. Temporario a partir do aCols                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aQM5Atr,{ "QM5_ENSR","C",TamSX3("QM5_ENSR")[1],0})
aadd(aQM5Atr,{ "QM5_CICLO","N",TamSX3("QM5_CICLO")[1],0})
aadd(aQM5Atr,{ "QM5_FILRES","C",TamSX3("QM5_FILRES")[1],0})

oTmpTable2 := FWTemporaryTable():New( "QM5ATP" )
oTmpTable2:SetFields( aQM5Atr )
oTmpTable2:AddIndex("indice1", {"QM5_ENSR","QM5_CICLO"} )
oTmpTable2:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena aCols no Tempor rio                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QM5ATP")
For nCntFor := 1 to Len(aCols) - 2
	RecLock("QM5ATP",.T.)
	QM5ATP->QM5_FILRES:= cFilAnt
	QM5ATP->QM5_ENSR  := aCols[nCntFor,nPosEns]
	MsUnlock()
Next nCntFor
If lTela
	DEFINE FONT oFnt NAME "Arial" BOLD

	DEFINE MSDIALOG oDlgCalRR TITLE OemToAnsi(STR0036) FROM 10,10 TO 140,300 ; //Resultado
	OF GetWndDefault() PIXEL

	@ 03,05 TO 60,110 OF oDlgCalRR PIXEL

	@ 10,10 SAY OemToAnsi(STR0037) SIZE 85,7 OF oDlgCalRR FONT oFnt PIXEL // "Classificacao das Pecas"
	@ 20,10 SAY OemToAnsi(STR0038) SIZE 70,7 OF oDlgCalRR FONT oFnt PIXEL // "Leitura(s) InCapaz(es)"
	@ 30,10 SAY OemToAnsi(STR0039) SIZE 70,7 OF oDlgCalRR FONT oFnt PIXEL // "Leitura(s) Capaz(es)"
	@ 50,10 SAY OemToAnsi(STR0036) SIZE 30,7 OF oDlgCalRR FONT oFnt PIXEL // "Resultado"
	@ 20,81 SAY nPecasNC	SIZE 18,7 OF oDlgCalRR FONT oFnt PIXEL
	@ 30,81 SAY nPecasC		SIZE 18,7 OF oDlgCalRR FONT oFnt PIXEL
	@ 50,41 SAY Alltrim(cSistInfo)SIZE 60,7 OF oDlgCalRR PIXEL FONT oFnt RIGHT COLOR cCorResu
	DEFINE SBUTTON FROM 05, 115 TYPE 1 ENABLE OF oDlgCalRR Action (lRet := .T.,oDlgCalRR:End()) PIXEL
	DEFINE SBUTTON FROM 18, 115 TYPE 2 ENABLE OF oDlgCalRR Action (lRet := .F.,oDlgCalRR:End()) PIXEL

	ACTIVATE MSDIALOG oDlgCalRR CENTERED

	oFnt:End()
Endif

aadd( aFim, { cResu,cSistInfo,nPecasC,nPecasNc } )

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPMSAWH ³ Autor ³ Robson Ramiro Oliveira³ Data ³ 02/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao para nao alteracao dos campos LIE / LSE no PPAP  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPMSAWH()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150  (PPAP)                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QPPMSAWH()

Local lReturn := .T.

If M->QM4_TIPO == "A" .and. M->QM4_TPATR == "1"
	lReturn := .F.
Endif

Return lReturn


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPMSALIM³ Autor ³ Robson Ramiro Oliveira³ Data ³ 02/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calculo e acerto da picture dos campos LIE / LSE           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPMSALIM()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ nOpc                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150 (PPAP)                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QPPMSALIM(nOpc)

Local cCampo := "QK2_TOL"
Local cReturn, cValor

cPict 	:= QA_PICT(cCampo,QK2->&(cCampo))

If nOpc == 1
	cValor := AllTrim(Transform(SuperVal(QK2->QK2_LIE) + SuperVal(QK2->QK2_TOL), cPict))
Else
	cValor := AllTrim(Transform(SuperVal(QK2->QK2_LSE) + SuperVal(QK2->QK2_TOL), cPict))
Endif

If Len(cValor) > 10 .or. At(",",cValor) <> 0
	If At(",",cValor) <> 0 // fixado no maximo 6 decimais para o RR do PPAP
		cReturn := SubStr(cValor,1,At(",",cValor))
		cReturn += SubStr(cValor,At(",",cValor)+1,6)
		If Len(cReturn) > 10
			cReturn := SubStr(cReturn,1,10)
		Endif
	Else
		cReturn := SubStr(cValor,1,10)
	Endif
Else
	cReturn := cValor
Endif

Return cReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPMSAWH2³ Autor ³ Robson Ramiro Oliveira³ Data ³ 05/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Nao permite Alteracoes na UM para PPAP                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPMSAWH2                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QPPMSAWH2()

Local lReturn := .T.

If !INCLUI .or. nModulo == 47 // PPAP
	lReturn := .F.
Endif

Return lReturn
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³q150MoPictºAutor  ³Denis Martins       º Data ³  04/24/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta a picture a ser apresentada na tela de resultados do  º±±
±±º          ³R&R.                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³Exp1 : Valor referencia para montagem da picture.           º±±
±±º          ³		                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA150                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function q150MoPict(nValor,cRefVal)
Local nCt	 := 0
Local cValor := " "
If ValType(nValor) == 'N'
	cValor := Alltrim(Str(nValor))
Else
	cValor := nValor
Endif

Default cRefVal := "QM4_LIE" //Default Virgula

If At(".", cValor) > 0 // Identifica se  na  formatacao de refetencia  temos . ou ,
	If ValType(nValor) == 'N'
		cPict := QA_PICT(Iif(Left(cRefVal,3)=="TRB","QM4_LIE",cRefVal),nValor)
	Else
		cPict := QA_PICT(Iif(Left(cRefVal,3)=="TRB","QM4_LIE",cRefVal),cValor)
	EndIf
	nCt:=At(".", cPict)
	If len(cPict)-nCt >= 6
		cPict := "@E 9999.99999"
	EndIf
Else
	cPict := StrTran(QA_PICT(Iif(Left(cRefVal,3)=="TRB","QM4_LIE",cRefVal),nValor),".",",",1) // Pega o numero de casas decimais do valor passado
EndIf

Return cPict
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A150DelATP  ³ Autor ³Denis Martins		³ Data ³ 29.05.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Desmonta o arquivo temporario	                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void A150DelATP                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A150DelATP()

lMontado := .F.

If ( Select("QM5ATP") != 0 )
	oTmpTable2:Delete()
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a150CalculoºAutor  ³Denis Martins       º Data ³  04/16/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza calculo do MSA 3 Edicao                              º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Calculo MSA 3 Edicao - Atributo                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a150Calculo(oGet_1,oDlg,oBtn1,lNaoCalc)
Local nx	:= 0
Local ny	:= 0
Local na	:= 0
Local cUsua := ""
Local cUsuar:= ""
Local nComb	:= 0
Local cSinals	:= ""
Local nSomas	:= 0
Local nPe		:= 0
Local nKappa	:= 0
Local nExUsu	:= 0
Local nPeRef	:= 0
Local nKappaRef	:= 0
Local lFzRefe	:= .F.
Local lCalCod	:= .f.
Local nd		:= 1
Local cToleQM4  := ""
Default lNaoCalc := .F.
//Zera arrays e variaveis
aSomRef := {}
aNew	:= {}
aTot	:= {}
aRef	:= {}
aCoUser	:= {}
aComb	:= {}
nSim	:= 0
nNao	:= 0
aUseRef := {}
//If lExTpAtr .and. lExTpMSA
	aCont := Array((M->QM4_NCICLO*M->QM4_NENSR)+1)

	For nx := 1 To Len(aCont)
		aCont[nx] := 0
	Next nx

	lAtCod := .T.
	nSim	:= 0
	nNao	:= 0

	nRefere := Ascan(aHeader,{|x| Alltrim(x[2]) = "QM5_REFERE"})
	nVlRef := Ascan(aHeader,{|x| Alltrim(x[2]) = "QM5_VLRREF"})
	nCodig	:= Ascan(aHeader,{|x| Alltrim(x[2]) = "QM5_CODIG"})
	//Depois da escolha do usuario perguntar se deseja re/calcular a coluna Referencia

	If !lNaoCalc .and. M->QM4_TPATR == "1"
		If MsgYesNo(OemToAnsi(STR0045),OemToAnsi(STR0046)) //"Deseja (re)calcular a coluna Referencia?" ### "R&R ATRIBUTO - Referencia"
			lFzRefe	:= .T.
		Endif
	Endif

	If oGet_1 <> Nil
		If MsgYesNo(OemToAnsi(STR0049),OemToAnsi(STR0050)) //"Deseja Re/Calcular a coluna Codigo ?" ### "R&R ATRIBUTO - Codigo"
			lCalCod := .T.
		Endif
	Endif


	//Calcula a coluna Codigo ( + / - / x )
	For nx := 1 To M->QM4_NPECAS
    	For ny := 1 To Len(aCols[nx])-4
			If ny > 1 //Para nao comparar a primeira peca com ela mesma
				If Alltrim(aCols[nx][1]) == Alltrim(aCols[nx][ny])
					If Alltrim(cSinals) <> "2"
						If Alltrim(aCols[nx][1]) == "1"
							cSinals := "1"
							nSim++
						ElseIf Alltrim(aCols[nx][1]) == "2"
							cSinals := "3"
							nNao++
						Endif
					Else
						If Alltrim(aCols[nx][ny]) == "1"
							nSim++
						Else
							nNao++
						Endif
					Endif
				Else
					If Alltrim(aCols[nx][ny]) == "1"
						nSim++
					Else
						nNao++
					Endif
					cSinals := "2"
				Endif
			Else
				If Alltrim(aCols[nx][ny]) == "1"
					nSim++
				Else
					nNao++
				Endif
			Endif
	    Next ny

	   	If lCalCod
		   	aCols[nx][Len(aCols[nx]) - 2] := cSinals
		Endif

		nSomRef := 0

		If lFzRefe .and. M->QM4_TPATR == "1"
			If nSim > nNao
			   	aCols[nx][nRefere] := "1"
			Else
			   	aCols[nx][nRefere] := "2"
			Endif
		Endif
		cSinals := ""
	    nSim	:= 0
    	nNao	:= 0
	    lAtCod := .T.
	Next nx

	For ny := 1 To Len(aCols)
		If M->QM4_TPATR == "2" //Realiza somatoria da coluna Referencia e divide pelo nro de pecas
			Aadd(aSomRef,{aCols[ny][nVlRef],aCols[ny][nCodig]})
			nSomRef := nSomRef + SuperVal(aCols[ny][nVlRef])
		Endif
		//Verificar essa situacao
		For nd := 1 To Len(aCols[ny])-4
    		If aCols[ny][nd] == "1"
		    	aCont[nd] := aCont[nd] + 1
		    Endif
		Next nd
	Next ny

	If Len(aSomRef) > 0 //Calcular a soma de referencia e ordernar o aSomRef
		aSort(aSomRef,,,{|x,y| x[1] > y[1]}) //Sorte da maior para menor
		nRep1 := Ascan(aSomRef,{|x| Alltrim(x[2]) == "3"})
		nRep2 := Ascan(aSomRef,{|x| Alltrim(x[2]) == "1"})
		If nRep2 > 0
			nRep2 := aSomRef[nRep2][1]
		Endif
		If nRep1 > 0
			For nx := nRep1 to Len(aSomRef)
				If Alltrim(aSomRef[nx][2]) == "3"
					nRep1 := aSomRef[nx][1]
				Else
					Exit
				Endif
			Next nx
	    Endif

		aSort(aSomRef,,,{|x,y| x[1] < y[1]}) //Sorte da maior para menor
		nRep3 := Ascan(aSomRef,{|x| Alltrim(x[2]) == "1"})
		nRep4 := Ascan(aSomRef,{|x| Alltrim(x[2]) == "3"})
		If nRep4 > 0
			For nx := nRep4 to Len(aSomRef)
				If Alltrim(aSomRef[nx][2]) == "3"
					nRep4 := aSomRef[nx][1]
				Else
					Exit
				Endif
			Next nx
		Endif
		nRep1 := SuperVal(nRep1) - SuperVal(nRep2)
		If nRep3 > 0
			nRep3 := SuperVal(aSomRef[nRep3][1]) - SuperVal(nRep4)
		Endif
		nReptot := (nRep1 + nRep3)/2
		nSomRef := (nSomRef/M->QM4_NPECAS)
		If !Empty(M->QM4_LSE) .AND. !Empty(M->QM4_LIE) .AND. Valtype(M->QM4_LSE) == 'N' .AND. Valtype(M->QM4_LIE) == 'N'
			cToleQM4 := SuperVal(M->QM4_LSE) - SuperVal(M->QM4_LIE)
		Endif
		nRepReR := 	nReptot / SuperVal(cToleQM4)
		If nRepReR == 0
			cMensg := ""
		Else
			If nRepReR < 0.1
				cMensg := OemToAnsi(STR0059) //"Sistema de medicao adequado"
			Else
				If nRepReR > 0.3
					cMensg := OemToAnsi(STR0060) //"Sistema de medicao necessita melhoria"
				Else
					cMensg := OemToAnsi(STR0061)//"Sistema de medicao deve ser analisado"
				Endif
			Endif
		Endif
		nRepReR := Round((nRepReR * 100),0)
	Endif

	For nx := 1 To Len(aCont)-1
		If nx == 1
			cUsua := ""
		Else
			cUsua := SubStr(aHeader[nx][1],1,TamSX3("QM5_ENSR")[1])
		Endif
		nUsr := ASCAN(aTot,{|x| Alltrim(x[1]) = Alltrim(cUsua)})
		If nUsr == 0
			Aadd(aTot,{SubStr(aHeader[nx][1],1,TamSX3("QM5_ENSR")[1]),aCont[nx]})
		Else
			aTot[nUsr][2] := aTot[nUsr][2] + 	aCont[nx]
		Endif
	Next nx

//Estrutura do aComb
//[1] - Combinacao de usuarios
//[2] - Coluna do acols do primeiro usuario
//[3] - Coluna do acols do segundo usuario

	For nx := 1 To Len(aHeader)-5
		For ny := 1 To Len(aHeader)-5
			If SubStr(Alltrim(aHeader[nx][1]),1,TamSx3("QM5_ENSR")[1]) <> SubStr(Alltrim(aHeader[ny][1]),1,TamSx3("QM5_ENSR")[1])
				cUsua := SubStr(Alltrim(aHeader[nx][1]),1,TamSx3("QM5_ENSR")[1])+" - "+SubStr(Alltrim(aHeader[ny][1]),1,TamSx3("QM5_ENSR")[1])
				cUsuar:= SubStr(Alltrim(aHeader[ny][1]),1,TamSx3("QM5_ENSR")[1])+" - "+SubStr(Alltrim(aHeader[nx][1]),1,TamSx3("QM5_ENSR")[1])
				If nComb := Ascan(aComb,{|x| Alltrim(x[1]) = Alltrim(cUsua) .or.  Alltrim(x[1]) = Alltrim(cUsuar)}) = 0
					Aadd(aComb,{SubStr(Alltrim(aHeader[nx][1]),1,TamSx3("QM5_ENSR")[1])+" - "+SubStr(Alltrim(aHeader[ny][1]),1,TamSx3("QM5_ENSR")[1]),nx,ny})
				Endif
			Endif
			cUsuar:= SubStr(Alltrim(aHeader[ny][1]),1,TamSx3("QM5_ENSR")[1])
			If nExUsu := Ascan(aUseRef,{|x| Alltrim(x[1]) = Alltrim(SubStr(cUsuar,1,TamSx3("QM5_ENSR")[1]))}) = 0
				Aadd(aUseRef,{cUsuar,ny})
			Endif
		Next ny
	Next nx

	nCont1 := 0
	nCont2 := 0
	nCont3 := 0
	nCont4 := 0

	For nx := 1 To Len(aComb)
		For na := 1 To M->QM4_NCICLO
			If na == 1
				nPrim := aComb[nx][2]
				nSegun:= aComb[nx][3]
			Else
				nPrim++
				nSegun++
			Endif

			For ny := 1 To Len(aCols)
				If aCols[ny][nPrim] == "2" .and. aCols[ny][nSegun] == "2" //as duas nao passam
					nCont1++
				ElseIf aCols[ny][nPrim] == "1" .and. aCols[ny][nSegun] == "1" //as duas passam
					nCont2++
				ElseIf aCols[ny][nPrim] == "2" .and. aCols[ny][nSegun] == "1" //a primeira nao passam - a segunda passa
					nCont3++
				ElseIf aCols[ny][nPrim] == "1" .and. aCols[ny][nSegun] == "2" //a primeira nao passam
					nCont4++
				Endif
			Next ny
		Next na
// Estrutura do aNew
// Codigo da combinacao
// As Duas pecas nao passam
// As Duas pecas passam
// A primeira pecas nao passa a segunda passa
// A segunda passa a primeira nao passa

		Aadd(aNew,{aComb[nx][1],nCont1,nCont2,nCont3,nCont4})
		Aadd(aNew[nx],{nCont1+nCont3,nCont4+nCont2,nCont1+nCont4,nCont3+nCont2,nCont2+nCont4+nCont3+nCont1})
		nSomas := aNew[nx][6][3]+aNew[nx][6][4]

		Aadd(aNew[nx],{	(aNew[nx][6][1]*aNew[nx][6][3])/nSomas,;
					(aNew[nx][6][1]*aNew[nx][6][4])/nSomas,;
					(aNew[nx][6][2]*aNew[nx][6][3])/nSomas,;
					(aNew[nx][6][2]*aNew[nx][6][4])/nSomas })

	// Po - 1 nivel do aNew[8] e Pe - 2 nivel do aNew[8]

		nPe := Round((aNew[nx][7][1]+aNew[nx][7][4])/nSomas,2) //Calculo do nPe
		Aadd(aNew[nx],{	(nCont2+nCont1)/nSomas,nPe})
		nKappa := (aNew[nx][8][1]-aNew[nx][8][2])/(1-aNew[nx][8][2])

		Aadd(aNew[nx],{Round(nKappa,2)})

		nCont1 := 0
		nCont2 := 0
		nCont3 := 0
		nCont4 := 0
	Next nx

	If M->QM4_TPATR == "1"
		For nx := 1 To Len(aUseRef) //Quantidade de Usuario x Referencia
			nPrim := Ascan(aHeader,{|x| Alltrim(SubStr(x[1],1,TamSx3("QM5_ENSR")[1])) = Alltrim(SubStr(aUseRef[nx][1],1,TamSx3("QM5_ENSR")[1]))})
			For na := 1 To M->QM4_NCICLO //Quantidade de Ciclos
				If na > 1
					nPrim++
				Endif
				For ny := 1 To Len(aCols)
					If aCols[ny][nPrim] == "2" .and. aCols[ny][nRefere] == "2"
						nCont1++
					ElseIf aCols[ny][nPrim] == "1" .and. aCols[ny][nRefere] == "1"
						nCont2++
					ElseIf aCols[ny][nPrim] == "2" .and. aCols[ny][nRefere] == "1"
						nCont3++
					ElseIf aCols[ny][nPrim] == "1" .and. aCols[ny][nRefere] == "2"
						nCont4++
					Endif
				Next ny
			Next na
			Aadd(aRef,{aUseRef[nx][1]+" - Ref   ",nCont1,nCont2,nCont3,nCont4})
			Aadd(aRef[nx],{nCont1+nCont3,nCont4+nCont2,nCont1+nCont4,nCont3+nCont2,nCont2+nCont4+nCont3+nCont1})

			nSomas := aRef[nx][6][5]

			Aadd(aRef[nx],{	(aRef[nx][6][1]*aRef[nx][6][3])/nSomas,;
					(aRef[nx][6][1]*aRef[nx][6][4])/nSomas,;
					(aRef[nx][6][2]*aRef[nx][6][3])/nSomas,;
					(aRef[nx][6][2]*aRef[nx][6][4])/nSomas })

		// Po - 1 nivel do aRef[8] e Pe - 2 nivel do aRef[8]

			nPeRef := Round((aRef[nx][7][1]+aRef[nx][7][4])/nSomas,2) //Calculo do nPe
			Aadd(aRef[nx],{	Round((nCont2+nCont1)/nSomas,2),nPeRef})

			nKappaRef := (aRef[nx][8][1]-aRef[nx][8][2])/(1-aRef[nx][8][2])

			Aadd(aRef[nx],{Round(nKappaRef,2)})

			nCont1 := 0
			nCont2 := 0
			nCont3 := 0
			nCont4 := 0
		Next nx

		nSoma	:= 0
		nSoCod	:= 0
		cMedAnt := ""
		lSom	:= .T.
		aCoUser	:= {}
		nDifPe	:= 0

		For nx := 1 to Len(aUseRef)
			nNome := Ascan(aHeader,{|x| Alltrim(SubStr(x[1],1,TamSx3("QM5_ENSR")[1])) = Alltrim(SubStr(aUseRef[nx][1],1,TamSx3("QM5_ENSR")[1]))})
			nPrim := nNome
			For ny := 1 to Len(aCols)
				For na := 1 to M->QM4_NCICLOS
					If na == 1
						nPrim := nNome
						cMedAnt := aCols[ny][nPrim]
					Else
						nPrim++
						If aCols[ny][nPrim] <> cMedAnt
							lSom := .f.
							cMedAnt := aCols[ny][nPrim]
						Endif
					Endif
				Next na
				If lSom
					nSoma++
				Endif
				If Alltrim(aCols[ny][nCodig]) $ "1|2" //Soma-se o "+" (1) ou o "x" (2)
					nSoCod++
				Endif
				lSom := .T.
			Next ny
	//	lCtaCod := .F. // Somar somente uma vez a coluna QM5_CODIG
			Aadd(aCoUser,{SubStr(aHeader[nNome][1],1,TamSX3("QM5_ENSR")[1]),M->QM4_NPECAS,nSoma})

			nDifPe := M->QM4_NPECAS - nSoma

			nSoma := (nSoma/M->QM4_NPECAS)*100

			Aadd(aCoUser[nx],nSoma)
			Aadd(aCoUser[nx],nSoCod)
			Aadd(aCoUser[nx],nDifPe)
			nSoma := 0
			nSoCod:= 0
		Next nx

		nSoCod := (aCoUser[1][5]/aCoUser[1][2])*100

		Aadd(aCoUser,nSoCod)
	Endif

	If oGet_1 <> Nil
		oGet_1:Refresh()
	Endif
//Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt150UseRefºAutor  ³Denis Martins       º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta Tabela de Usuarios para Calculo de Referencia           º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt150UseRef()
Local nx	:= 0
Local nComb	:= 0
Local nExUsu:= 0
Local ny	:= 0
Local cUsua := ""
Local cUsuar:= ""
aUseRef := {}
For nx := 1 To Len(aHeader)-3
	For ny := 1 To Len(aHeader)-3
		If SubStr(Alltrim(aHeader[nx][1]),1,TamSx3("QM5_ENSR")[1]) <> SubStr(Alltrim(aHeader[ny][1]),1,TamSx3("QM5_ENSR")[1])
			cUsua := SubStr(Alltrim(aHeader[nx][1]),1,TamSx3("QM5_ENSR")[1])+" - "+SubStr(Alltrim(aHeader[ny][1]),1,TamSx3("QM5_ENSR")[1])
			cUsuar:= SubStr(Alltrim(aHeader[ny][1]),1,TamSx3("QM5_ENSR")[1])+" - "+SubStr(Alltrim(aHeader[nx][1]),1,TamSx3("QM5_ENSR")[1])
			If nComb := Ascan(aComb,{|x| Alltrim(x[1]) = cUsua .or.  Alltrim(x[1]) = cUsuar}) = 0
				Aadd(aComb,{SubStr(Alltrim(aHeader[nx][1]),1,TamSx3("QM5_ENSR")[1])+" - "+SubStr(Alltrim(aHeader[ny][1]),1,TamSx3("QM5_ENSR")[1]),nx,ny})
			Endif
		Endif
		cUsuar:= SubStr(Alltrim(aHeader[ny][1]),1,TamSx3("QM5_ENSR")[1])
		If nExUsu := Ascan(aUseRef,{|x| Alltrim(x[1]) = Alltrim(SubStr(cUsuar,1,TamSx3("QM5_ENSR")[1]))}) = 0
			Aadd(aUseRef,{cUsuar,ny})
		Endif
	Next ny
Next nx

nRefere := Ascan(aHeader,{|x| Alltrim(x[2]) = "QM5_REFERE"})
nVlRef  := Ascan(aHeader,{|x| Alltrim(x[2]) = "QM5_VLRREF"})
nCodig	:= Ascan(aHeader,{|x| Alltrim(x[2]) = "QM5_CODIG"})

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMTA150NvBarºAutor  ³Denis Martins       º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta EnchoiceBar com botao de visualizacao de resultados     º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA150                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QMTA150NvBar( oDlg, bOk, bCancel, nOpc )
Local aButtons := {}

If nModulo == 47 .and. (!Inclui .and. !Altera) // PPAP
	aButtons := { {"BMPVISUAL", { || QMTR150() } , OemToAnsi(STR0042) }} //"Visualizar/Imprimir"
Else
	aButtons := { 	{"EDIT"     , { || QMT150RES(nOpc, oDlg) }, OemToAnsi(STR0063), OemToAnsi(STR0064)}} //"Responsavel/Limpa"###"Respon."
Endif

EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT150VisResulºAutor  ³Denis Martins       º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Visualiza Resultados dos Calculos                               º±±
±±º          ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA150                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT150VisResul()
MessageDlg(OemToAnsi(STR0048),,2)
/*Local oDlgRe
Local oScroll
Local oBtnRe
Local oSay1
Local oSay2
Local cTraco1 := Repl("-",120)
Local li := 35
Local nx := 1
Local cEns1,cEns2,cEns3,cEns4,cEns5,cEns6,cEns7,cEns8,cEns9,cEns10
Local cLbD := "Ensaiador: "
Local oSayUser
DEFINE MSDIALOG oDlgRe TITLE "R&R Atributo - Resultados" From 30,0 to 60,100 OF GetWndDefault()
oScroll := TScrollBox():New(oDlgRe,.1,.1,210,396,.T.,.T.,.T.)
DEFINE SBUTTON FROM 212,343	TYPE 1 ENABLE OF oDlgRe ACTION (oDlgRe:End())
@ 4,170 SAY oSay1 PROMPT "R R Atributo - Resultados" SIZE 100,15 FONT oMonoAs COLOR CLR_HRED OF oScroll PIXEL
@ 15,154 SAY oSay2 PROMPT "Estudo das Possibilidades - Usuarios" SIZE 120,15 FONT oMonoAs 	  OF oScroll PIXEL
For nx := 1 To Len(aNew)
	If nx == 1
		cEns1 := aNew[nx][1]
		@ li,165  SAY cLbD+cEns1 SIZE 80,20 OF oScroll PIXEL
	ElseIf nx == 2
		cEns2 := aNew[nx][1]
		@ li,165  SAY cLbD+cEns2 SIZE 80,20 OF oScroll PIXEL
	ElseIf nx == 3
		cEns3 := aNew[nx][1]
		@ li,165  SAY cLbD+cEns3 SIZE 80,20 OF oScroll PIXEL
	ElseIf nx == 4
		cEns4 := aNew[nx][1]
		@ li,165  SAY cLbD+cEns4 SIZE 80,20 OF oScroll PIXEL
	ElseIf nx == 5
		cEns5 := aNew[nx][1]
		@ li,165  SAY cLbD+cEns5 SIZE 80,20 OF oScroll PIXEL
	ElseIf nx == 6
		cEns6 := aNew[nx][1]
		@ li,165  SAY cLbD+cEns6 SIZE 80,20 OF oScroll PIXEL
	ElseIf nx == 7
		cEns7 := aNew[nx][1]
		@ li,165  SAY cLbD+cEns7 SIZE 80,20 OF oScroll PIXEL
	ElseIf nx == 8
		cEns8 := aNew[nx][1]
		@ li,165  SAY cLbD+cEns8 SIZE 80,20 OF oScroll PIXEL
	ElseIf nx == 9
		cEns9 := aNew[nx][1]
		@ li,165  SAY cLbD+cEns9 SIZE 80,20 OF oScroll PIXEL
	ElseIf nx == 10
		cEns10 := aNew[nx][1]
		@ li,165  SAY cLbD+cEns10 SIZE 80,20 OF oScroll PIXEL
	Endif
	li+=8
	@ li,100  SAY cTraco1 SIZE 180,20 OF oScroll PIXEL
	li+= 20
Next nx
ACTIVATE MSDIALOG oDlgRe Centered
*/
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Qmt150AjQM4ºAutor  ³Denis Martins       º Data ³  04/28/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Acerto do Flag QM4_TPMSA para impressao de ensaios de todos  º±±
±±º          ³os tipos e posterior impressao dos relatorios                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA150                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmt150AjQM4()
Local aArea := GetArea()

dbSelectArea("QM4")
dbSetOrder(1)
While !QM4->(Eof())
	If Empty(QM4->QM4_TPMSA)
		If Alltrim(QM4->QM4_TPMSA) == "1"  //MSA 3 Edicao
			RecLock("QM4",.f.)
			Replace QM4_TPMSA with "1"
			MsUnLock()
		ElseIf Empty(QM4->QM4_TPMSA)
			RecLock("QM4",.f.)
			Replace QM4_TPMSA with "2"
			MsUnLock()
		Endif
	Endif
	dbSkip()
Enddo

RestArea(aArea)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt150PictºAutor  ³Denis Martins       º Data ³  04/28/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Constroi a picture do campo QM5_VLRREF quando utilizado o   º±±
±±º          ³calculo Sinal de Deteccao                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA150                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt150Pict()
Local cPict
Local nPosRef := Ascan(aHeader,{|x| x[2] = "QM5_VLRREF"})

If nPosRef > 0
	cPict := qmt140Pics("QM5_VLRREF",aCols[n,nPosRef],.F.)
Endif

Return(cPict)

Function Qmt150Verif(nOpca,oDlg)

   	If M->QM4_TPMSA == "1" .Or. M->QM4_TPMSA == "3"
		If M->QM4_TIPO == "A"
			If Len(aUseRef) <= 0
			MessageDlg(STR0057,,3) //"Realize o calculo do estudo antes da gravacao"
			nOpca := 0
			Return .F.
		Else
			nOpca:=1
			oDlg:End()
		Endif
	Else
		nOpca:=1
		oDlg:End()
	Endif
Else
	nOpca:=1
	oDlg:End()
Endif

Return nOpca

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT150PERFºAutor  ³ Cicero Cruz        º Data ³  05/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Possibilita avaliacao do Sistema de Medicao R&R            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA150                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT150PERF()

Local cNomeArq
Local oDlgAv
Local oScroll
Local oBtn02
Local aTabela := {}
Local nHdl    := 0
Local nOp     := 0

nHdl := QMT150RAPer(@aTabela)
If QM4->QM4_TIPO <> "A"
	If QMT150VUsr() .And. nHdl > 0
		DEFINE MSDIALOG oDlgAv TITLE STR0062 FROM 030,000 TO 055,035 OF GetWndDefault()
		oScroll := TScrollBox():New(oDlgAv,005,005,180,098,.T.,.T.,.T.)
		DEFINE SBUTTON oBtn02 FROM 005,107	TYPE 13 ENABLE OF oDlgAv ACTION (nOp := 1,QMT150GAPer(@nHdl,aTabela),oDlgAv:End()) // Salvar

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta ListBox   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ .1,.1 LISTBOX oLbxAv VAR cVar Fields HEADER STR0065,STR0066 SIZE 093,178 OF oScroll // "Amostra"###"Valor Real"
		oLbxAv:SetArray(aTabela)
		oLbxAv:bLine := { || {aTabela[oLbxAv:nAT,1],aTabela[oLbxAv:nAT,2] } }
		oLbxAv:bLDblClick := {|| QMT150Edit(@aTabela,oLbxAv:nAt,NIL,NIL,oLbxAv,oBtn02),oLbxAv:Refresh()}
		oLbxAv:lAutoEdit:=.T.

		oBtn02:Disable()

		ACTIVATE MSDIALOG oDlgAv Centered

	EndIf

	//Fecha arqquvo e grava em disco
	If nHdl > 0
		FClose(nHdl)
	EndIf
Else
	Messagedlg(STR0073)
endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT150PERFºAutor  ³ Cicero Cruz        º Data ³  05/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava os valores reais de medicao da Peca adquiridos pelo  º±±
±±º          ³ responsavel                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA150                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT150GAPer(nHdl, aTabela)
Local nI       := 0
Local cNomeArq := ""
Local CR       := Chr(13)+Chr(10)

If nModulo == 47
	cNomeArq := QM4->(QM4_FILIAL+QM4_PECA1+QM4_REV+QM4_CARAC+DTOS(QM4_DATA)+SUBSTR(QM4_HORA,1,2)+SUBSTR(QM4_HORA,4,2))+".TXT"
Else
	cNomeArq := QM4->(QM4_FILIAL+QM4_INSTR+QM4_REVINS+DTOS(QM4_DATA)+SUBSTR(QM4_HORA,1,2)+SUBSTR(QM4_HORA,4,2))+".TXT"
EndIf

//Apago o arquivo anterior
FClose(nHdl)
FErase(cNomeArq)

//Gravo as  informacoes novamente
nHdl := FCreate( cNomeArq, FC_NORMAL )
If nHdl < 0
    MSGAlert(STR0067)  //"Nao foi possivel acessar o arquivo de Valores Reais"
	Return nHdl //Retorna array vazio
EndIf
FClose(nHdl)    //Fecha arqquvo e grava em disco
nHdl := FOpen( cNomeArq, FO_READWRITE )
If nHdl < 0
    MSGAlert(STR0067)  //"Nao foi possivel acessar o arquivo de Valores Reais"
	Return nHdl //Retorna array vazio
EndIf

For nI := 1 To QM4->QM4_NPECAS
	FWRITE(nHdl,aTabela[nI][1]+aTabela[nI][2]+CR)
Next

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT150PERFºAutor  ³ Cicero Cruz        º Data ³  05/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava os valores reais de medicao da Peca adquiridos pelo  º±±
±±º          ³ responsavel                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA150                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT150RAPer(aTabela)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local CR          := Chr(13)+Chr(10)

Local cTermo      := ""
Local cNomeArq    := ""
Local cRef        := qmt150VIni("QM4","QM4_LIE")

Local nTamArq     := 0
Local nI          := 0
Local i           := 0

Local lNew        := .F.

If nModulo == 47
	cNomeArq := QM4->(QM4_FILIAL+QM4_PECA1+QM4_REV+QM4_CARAC+DTOS(QM4_DATA)+SUBSTR(QM4_HORA,1,2)+SUBSTR(QM4_HORA,4,2))+".TXT"
Else
	cNomeArq := QM4->(QM4_FILIAL+QM4_INSTR+QM4_REVINS+DTOS(QM4_DATA)+SUBSTR(QM4_HORA,1,2)+SUBSTR(QM4_HORA,4,2))+".TXT"
EndIf

//Cria arquivo de valores reais
If File(cNomeArq)
	nHdl := FOpen( cNomeArq, FO_READWRITE )
	If nHdl < 0
	    MSGAlert(STR0068)	// "Nao foi possivel ler o arquivo de Valores Reais"
		Return nHdl //Retorna array vazio
	EndIf
Else
	lNew := .T.
	nHdl := FCreate( cNomeArq, FC_NORMAL )
	If nHdl < 0
	    MSGAlert(STR0067) //"Nao foi possivel criar o arquivo de Valores Reais"
		Return nHdl //Retorna array vazio
	EndIf
	FClose(nHdl)    //Fecha arqquvo e grava em disco
	nHdl := FOpen( cNomeArq, FO_READWRITE )
	If nHdl < 0
	    MSGAlert(STR0068)	// "Nao foi possivel ler o arquivo de Valores Reais"
		Return nHdl //Retorna array vazio
	EndIf
Endif

For nI := 1 To QM4->QM4_NPECAS
	AAdd(aTabela, {STRZERO(nI,2),cRef})
Next

If !lNew // Leio os dados para o array
	nTamArq :=FSEEK(nHdl,0,2)
	xBuffer :=Space(nTamArq)

	FSEEK(nHdl,0,0)
	FREAD(nHdl,@xBuffer,nTamArq)

	cTermo  :=xBuffer
	nI := 1
	i := At(CR,cTermo)
	While  i>0
		If nI <= QM4->QM4_NPECAS
			aTabela[nI][1] := Substr(cTermo,1,2)
			aTabela[nI][2] := Alltrim(Substr(cTermo,3,i-3)) //pego o valor sem o enter
			cTermo := Substr(cTermo,i+2,nTamArq)
			nI++
			i := At(CR,cTermo)
		Else
			i := 0
		EndIf
	End

EndIf

Return nHdl


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT150EditºAutor  ³ Cicero Cruz        º Data ³  06/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Simula edição do ListBox                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA150                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT150Edit(aLbx,nItem,oTimer,nTimeOut,oLbx, oBtn1)
Local aDim      := {}

Local oOwner    := oLbx:oWnd
Local oDlg1
Local oGet1
Local oRect
Local oBtn

Local lContinua := .T.
Local lValid    := .F.

Local nCol      := 2
Local nRow 		:= oLbx:nAt
Local nVal 		:= aLbx[nItem][2]

Local cCadastro := OemToAnsi("Teste")

oRect:= tRect():New(0,0,0,0)     // Obtem as coordenadas da celula (lugar onde
oLbx:GetCellRect(nCol,,oRect)    // a janela de edicao deve ficar)
aDim:= {oRect:nTop,oRect:nLeft,oRect:nBottom,oRect:nRight}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria uma janela invisivel para permitir a edicao do campo sobre o browse ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg1 OF oOwner  FROM 0, 0 TO 0, 0 STYLE nOR( WS_VISIBLE, WS_POPUP ) PIXEL

@ 0,0 MSGET oGet1 VAR nVal SIZE 0,0 OF oDlg1 FONT oOwner:oFont PICTURE PesqPict("QM4","QM4_LIE",TamSx3("QM4_LIE")[1]) PIXEL ;
			HASBUTTON WHEN .T.

oGet1:Move(-2,-2, (aDim[ 4 ] - aDim[ 2 ]) + 4, aDim[ 3 ] - aDim[ 1 ] + 4 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao criado para receber o foco - nao retirar                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 0,0 BUTTON oBtn PROMPT "X" SIZE 0,0 OF oDlg1
oBtn:bGotFocus := {|| oDlg1:nLastKey := VK_RETURN, If( lValid := .T. , oDlg1:End(0), oGet1:SetFocus() ) }

ACTIVATE MSDIALOG oDlg1 ON INIT oDlg1:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura o Objeto Listbox                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oLbx:nAt := nRow
SetFocus(oLbx:hWnd)
oLbx:Refresh()

If lValid
	If aLbx[nItem][2] <> nVal
		oBtn1:Enable()
	EndIf
	aLbx[nItem][2] := nVal
EndIf

Return lContinua

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT150EditºAutor  ³ Cicero Cruz        º Data ³  06/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Simula edição do ListBox                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA150                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT150VIni(cAlias,cCampo)
Local cValor := ""
Local cRefer := &(cAlias+"->"+cCampo)
Local nAux := 0
Local n := At(",",cRefer)

If n == 0
	cValor := STRZERO(nAux,Len(Alltrim(cRefer)))
Else
	cValor := STRZERO(nAux,(n-1))+","+STRZERO(nAux,(Len(Alltrim(cRefer))-n))
EndIf

Return cValor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT150RES ºAutor  ³ Cicero Cruz        º Data ³  22/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atribui um responsavel ao Estudo                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA150                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT150RES(nOpc, oDlg)
Local cCodMat	:= ""  		 	// Matricula do Usuario

cUsrLogin := QM150XUser(__cUserId,2)

If !Empty(cUsrLogin)
	DbSelectArea("QAA")
	DbSetOrder(6)
	If DbSeek(UPPER(cUsrLogin))
		cCodMat := QAA->QAA_MAT
	Else
		MsgAlert(STR0075)
	EndIf
EndIf

If nOpc == 4 .And. !Empty(cCodMat)
	If Empty(M->QM4_RESP)
		M->QM4_NOME 	:= QA_NUSR(xFilial("QAA"),"",.F.,"N")
		M->QM4_RESP 	:= QA_NUSR(xFilial("QAA"),"",.F.,"C")
	Else
		If Alltrim(cCodMat) == Alltrim(QM4->QM4_RESP)   // Somente o usuario responsavel pelo estudo e o usuario responsável pelo instrumento pode  alterar o campo do responsavel
			M->QM4_NOME 	:= Space(40)
			M->QM4_RESP 	:= Space(10)
		Else
			QM2->(DbSetOrder(1))
			If QM2->(DbSeek(xFilial("QM2")+QM4->QM4_INSTR+INVERTE(QM4->QM4_REVINS)))
				If (cCodMat == QM2->QM2_RESP) .Or. (!Empty(M->QM4_NOME) .And. Empty(QM4->QM4_RESP))
					M->QM4_NOME 	:= Space(40)
					M->QM4_RESP 	:= Space(10)
				Else
					MsgAlert(STR0074) //"Somente o usuário responsável pelo estudo e o usuário responsável pelo instrumento, pode alterar o campo do responsável."
				EndIf
			EndIf
		EndIf
	EndIf
ElseIf nOpc == 3
	If Empty(M->QM4_RESP)
		M->QM4_NOME 	:= QA_NUSR(xFilial("QAA"),"",.F.,"N")
		M->QM4_RESP 	:= QA_NUSR(xFilial("QAA"),"",.F.,"C")
	Else
		M->QM4_NOME 	:= Space(40)
		M->QM4_RESP 	:= Space(10)
	Endif
Endif
oDlg:Refresh()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QM150XUser ³Autor  ³ Cicero Cruz          ³ Data ³ 26/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna dados do Usuario com
 no ID User...            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpC2 := QM150XUser(ExpC1,ExpN1) 	   	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros| ExpC1 := __cUserID (Codigo de ID do Usuario).              |±±
±±³          | ExpN1 := Numero do dado a retornar.                        |±±
±±³          | 	  Onde: 1 - Devolve o proprio ID User.                    |±±
±±³          |          2 - Devolve o Login Ex. Administrador.            |±±
±±³          |          3 - Devolve o PSW.                                |±±
±±³          |          4 - Devolve o Nome do Usuario.                    |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM150XUser(cIdUser,nRet)
Local cUser := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet == 1 -> Retorna ID User                                 ³
//³ nRet == 2 -> Retorna Login                                   ³
//³ nRet == 3 -> Retorna PSW                                     ³
//³ nRet == 4 -> Retorna Nome                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default nRet := 1

PswOrder(1)
If PswSeek(cIdUser)
	cUser := PswRet()[1][nRet]
EndIf

Return( cUser )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT150VUsrºAutor  ³ Cicero Cruz        º Data ³  26/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida acesso do usuario e ao Relatorio                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA150                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT150VUsr()
Local lRet      := .F. 			// Define o acesso ao sistema
Local aArea 	:= GetArea() 	// Guardo a posicao dos registros
Local cUsrLogin := ""  		 	// Usuario logado
Local cCodMat	:= ""  		 	// Matricula do Usuario

cUsrLogin := QM150XUser(__cUserId,2)

If !Empty(cUsrLogin)
	DbSelectArea("QAA")
	DbSetOrder(6)
	If DbSeek(UPPER(cUsrLogin))
		cCodMat := QAA->QAA_MAT
	EndIf
EndIf

If cCodMat == QM4->QM4_RESP
	lRet := .T.
Else
	If Empty(QM4->QM4_RESP)
		QM2->(DbSetOrder(1))
		If QM2->(DbSeek(xFilial("QM2")+QM4->QM4_INSTR+INVERTE(QM4->QM4_REVINS)))
			If cCodMat == QM2->QM2_RESP
				lRet := .T.
			EndIf
		EndIf
	EndIf
EndIf

If !lRet
	MsgAlert(STR0069) //"Somente o responsavel pelo estudo de R&R tem acesso aos Valores Reais das amostras e ao Relatorio Avaliacao de Performance dos Sistemas de Medicao R&R."
Else
	If QM4->QM4_TIPO $ "CA"
		MsgInfo( OemToAnsi( STR0070 ) , OemToAnsi( STR0071 ) ) //"Tipo de ensaio inválido, use somente (Tolerancia de Processo ou Tolerancia de Especificação), para gerar este estudo."###"Aviso de Inconsitencia!"
		lRet := .F.
	EndIf
EndIf

RestArea( aArea )
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q150Incl  ºAutor  ³ Rafael S. Bernardi º Data ³  06/02/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclui uma Posicao no aHeader apos sua montagem na         º±±
±±º          ³ fillgetdados                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA150                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q150Incl(aArray,xValor,nPos)
aAdd(aArray,{})
aIns(aArray,nPos)
aArray[nPos] := xValor
Return aArray

//----------------------------------------------------------------------
/*/{Protheus.doc} Q150GetSX3 
Busca dados da SX3 
@author Brunno de Medeiros da Costa
@since 24/04/2018
@version 1.0
@return aHeaderTmp
/*/
//---------------------------------------------------------------------- 
Static Function Q150GetSX3(cCampo, cTitulo, cPicture, nOpc)
Local aHeaderTmp := {}
If nOpc == 1
	aHeaderTmp:= {IIf(Empty(cTitulo), QAGetX3Tit(cCampo), cTitulo),;
	              GetSx3Cache(cCampo,'X3_CAMPO'),;
	              IIf(Empty(cPicture), GetSx3Cache(cCampo,'X3_PICTURE'), cPicture),;
	              GetSx3Cache(cCampo,'X3_TAMANHO'),;
	              GetSx3Cache(cCampo,'X3_DECIMAL'),;
	              GetSx3Cache(cCampo,'X3_VALID'),;              
	              GetSx3Cache(cCampo,'X3_USADO'),;
	              GetSx3Cache(cCampo,'X3_TIPO'),;
	              GetSx3Cache(cCampo,'X3_ARQUIVO'),;
	              GetSx3Cache(cCampo,'X3_CONTEXT') }              
ElseIf nOpc == 2
	aHeaderTmp:= {IIf(Empty(cTitulo), QAGetX3Tit(cCampo), cTitulo),;
	              GetSx3Cache(cCampo,'X3_CAMPO'),;
	              IIf(Empty(cPicture), GetSx3Cache(cCampo,'X3_PICTURE'), cPicture),;
	              GetSx3Cache(cCampo,'X3_TAMANHO'),;
	              GetSx3Cache(cCampo,'X3_DECIMAL'),;
	              GetSx3Cache(cCampo,'X3_VALID'),;              
	              GetSx3Cache(cCampo,'X3_USADO'),;
	              GetSx3Cache(cCampo,'X3_TIPO'),;
	              GetSx3Cache(cCampo,'X3_ARQUIVO'),;
	              GetSx3Cache(cCampo,'X3_CONTEXT'),;
	              QAGetX3Cmb(cCampo) }
EndIf
Return aHeaderTmp