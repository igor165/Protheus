#INCLUDE 'TOTVS.CH'
#INCLUDE 'MATA200.CH'
#INCLUDE 'DBTREE.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWADAPTEREAI.CH"

STATIC lPCPREVTAB	:= FindFunction('PCPREVTAB')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
STATIC lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
STATIC lTemMapa	:= .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MATA200  ³ Autor ³ Fernando Joly/Eduardo ³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manuten‡„o na Estrutura dos produtos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Mata200(ExpA1,ExpA2,ExpN1)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = (ROT.AUT) Array do cabecalho dos campos            ³±±
±±³          ³ ExpA2 = (ROT.AUT) Array dos campos                         ³±±
±±³          ³ ExpN1 = (ROT.AUT) Numero da opcao selecionada              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MatA200(xAutoCab,xAutoItens,nOpcAuto)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Locais                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAreaAnt		:= GetArea()
Local aIndexSG1		:= {}
Local cFiltraSG1	:= " "
Local lCalcNivel	:= NIL
Local nPos
Local oMBrowse		:= NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Private                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRecDel	   := {}
Private oTree
Private cCadastro  := OemToAnsi(STR0001) // 'Estruturas'
Private cCodAtual  := Replicate('ú', Len(SG1->G1_COD))
Private cValComp   := Replicate('ú', Len(SG1->G1_COD)) + 'ú'
Private ldbTree    := .F.
Private cInd5      := ''
Private nNAlias    := 0
Private lM200CPTX	:=   IIf(ExistBlock("M200CPTX"),.T.,.F.)
Private aValAnt    := {}
Private nseqori  := 0
Private nseqdest := 0
Private nSeqAux	 := 0
Private nSeqAux1	 := 0
PRIVATE CESTRUTURA 	:= ''
Private lestigual	:= .F.  // identifica se esta comparando o mesmo produto
Private cOrdeRev	:= '1'  // Identifica a ordem da revisão, se revisao de origem e maior que revisao de destino, utilizado para montar ordem na tree de comparacao

//1 - RECNO_1 = RECNO -- SG1
//2 - SEQ_1   = TRT   -- SG1
//3 - COMP_1  = COMP  -- SG1
//4 - RECNO_2 = RECNO -- SGF
//5 - SEQ_2   = RECNO -- SGF
//6 - COMP_2  = RECNO -- SGF

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
Private aBkpARot := {}
Private aRotina := MenuDef()
Private ARegsSGF := {}
Private ARegsSGFdel := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao para rotina automatica                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private l200Auto	:= ( ValType(xAutoCab)=="A" .And. (ValType(xAutoItens)=="A" .Or. nOpcAuto==5))

Private aAutoCab	:= {}
Private aAutoItens	:= {}

private lExpEst     := .T.
Private cIteAlt	 	:= ''
Private cstatus 	:= ''
Private	cMsgProc	:= ''
Default	nOpcAuto	:= 3


dbSelectArea('SG1')
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Se atualiza a data de revisao B1_UREV  ³
//³ mv_par02 - Atualiza arquivo de revisoes           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte('MTA200', .F.)

If !(l200Auto)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificacao de filtro na Mbrowse                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( ExistBlock("M200FIL") )
		cRet := AllTrim(ExecBlock("M200FIL",.F.,.F.))
		If ( Valtype(cRet) == "C" )
			cFiltraSG1 := cRet
		EndIf
	EndIf

	SetKey( VK_F12, { || Pergunte('MTA200', .T.) } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("SG1")
	oMBrowse:SetDescription( cCadastro )
	oMBrowse:SetAttach( .T. )
	oMBrowse:SetTotalDefault('G1_FILIAL','COUNT',STR0076) //'Total de Registros'
	If !Empty(cFiltraSG1)
		oMBrowse:SetFilterDefault(cFiltraSG1)
	EndIf

	// Tela com aviso de descontinuação do programa
	PCPMsgExp("MATA200", STR0119, "https://tdn.totvs.com/pages/viewpage.action?pageId=652584487", "https://tdn.totvs.com/display/PROT/Estrutura+-+PCPA200") // "Estrutura - Nova Versão (PCPA200)"
	
	oMBrowse:Activate()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desativa tecla que aciona pergunta            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Set Key VK_F12 To
Else //Executa a rotina automatica
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa/Desativa o calculo de niveis            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPos :=	aScan(xAutoCab,{|x| x[1] == "NIVALT"})
	If ( nPos > 0 .and. xAutoCab[nPos,2] == "S" )
		lCalcNivel	:= .T.
	Else
		lCalcNivel	:= .F.
	EndIf
	aAutoCab	:= aClone(xAutoCab)
	aAutoItens	:= aClone(xAutoItens)

	a200TamVar()

	If nOpcAuto <> 7
		a200Proc("SG1",RecNo(),nOpcAuto)
	Else
		INCLUI := .F.
		ALTERA := .T.
		BEGIN TRANSACTION
			A200Subs()
		END TRANSACTION

	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recalcula os Niveis                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetMv('MV_NIVALT') == 'S' .And. If(ExistBlock("MA200CNI"),ExecBlock("MA200CNI",.F.,.F.),.T.)
	MA320Nivel(Nil,lCalcNivel,!l200Auto)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PE no final da rotina de Recalculo dos Niveis |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("MA200FNI")
		ExecBlock("MA200FNI",.F.,.F.)
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura Area de trabalho.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaAnt)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  a200Proc  ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Processamento da Estrutura                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200Proc(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F. 	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function a200Proc(cAlias,nRecno,nOpcX)
Local lTranEst  := SuperGetMv("MV_TRANEST",.F.,.T.)
Local lTransact	:= cValtoChar(nOpcX) $ '3456'
Local nX        := 0

if lTranEst

	If Type('aEndEstrut')=="U"
		Private aEndEstrut := {}
	EndIf

	BEGIN TRANSACTION

		a200Exe(cAlias,nRecno,nOpcX)

		If Len(aEndEstrut) > 0
			For nX := 1 to Len(aEndEstrut)
				FimEstrut2(aEndEstrut[nX,1],aEndEstrut[nX,2])
			Next nX
			aEndEstrut := {}
		EndIf

	END TRANSACTION

else

	if nOpcX != 3 .And. nOpcX != 2
		if SoftLock("SG1")
			a200Exe(cAlias,nRecno,nOpcX)
		EndIf
	Else
		a200Exe(cAlias,nRecno,nOpcX)
	EndIf

EndIf

Return

/*---------------------------------------
{Protheus.doc} a200Exe()                |
 Programa de Processamento da Estrutura |
@author Lucas Pereira                   |
@since 01/09/2014                       |
@version 1.0                            |
---------------------------------------*/
Function a200Exe(cAlias,nRecno,nOpcX)
Local oDlg
Local oUm
Local oRevisao
Local oQtdBase
Local oButPosic
Local cTitulo	 	:= STR0001 + ' - ' // 'Estruturas'
Local cGetTrt	 	:= Space(TamSx3("G1_TRT")[1])
Local cAutTrt	 	:= Space(TamSx3("G1_TRT")[1])
Local cGetRevIni 	:= ''
Local cAutRevIni 	:= ''
Local lGetRevisa 	:= .T.
Local lRet       	:= .T.
Local lAltOpc    	:= .F.
Local lConfirma  	:= .F.
Local lAbandona  	:= .F.
Local lTransact		:= cValtoChar(nOpcX) $ '3456'
Local lAchou        := .F.
Local bKey279    	:= bkey300:= bkey274:= bkey281:= bkey305:= bkey301 :=""
Local aAreaAnt   	:= GetArea()
Local aUndo      	:= {}
Local lMudou     	:= .F.
Local aAltEstru  	:= {}
Local aPaiEstru	:= {}
Local aObjects	:= {}
Local aPosObj 	:= {}
Local aInfo	 	:= {}
Local aSize	 	:= {}
Local aValidGet	:= {}
Local aKey       	:= {279, 300, 274, 281, 305, 301, 303}
Local aBkey      	:= {}
Local aSFCJaInt  	:= {}
Local lExpand    	:= mv_par03 == 1
Local lRevAut    	:= SuperGetMv("MV_REVAUT",.F.,.F.)
Local lPriNivel  	:= If(l200Auto .And. ProcP(aAutoCab,"NIVEL1")>0,aAutoCab[ProcP(aAutoCab,"NIVEL1"),2]=="S",.F.)
Local nPosGet	 	:= 0
Local nPosAut	 	:= 0
Local nI,nJ,nPos,nX:=0
Local nOpcOrig      := 0
Local oPanel1
Local oPanel2
Local oPanel3
Local oPanelRight
Local oPanelB1
Local oPanelB2
Local oPanelB3
Local oPanelB4
Local oPanelB5
Local oPanelB6
Local oPanelB7
Local oPanelB8
Local oButton2
Local oButton3
Local oButton4
Local oButton6
Local oButton7
Local oButton8
Local oGroup
Local lIntSFC	:= IntegraSFC()
Local RevSim
Local aNewRecs  := {}
Local aRecProc  := {}
Local aDadosInt := {}
Local lExclusao := .F.
Local lExec     := .T.
Local nTotal    := 0
Local nError    := 0
Local nSucess   := 0

Local nRecAtu := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variavel lPyme utilizada para Tratamento do Siga PyME        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lPyme:= Iif(Type("__lPyme") <> "U",__lPyme,.F.)

Private nIndex   := 1
Private nQtdBasePai
Private cRevisao := CriaVar('B1_REVATU')
Private cRevisaoA
Private cRevSim  := CriaVar('B1_REVATU')

Private cProduto   := CriaVar('G1_COD')
Private cCodSim    := CriaVar('G1_COD')
Private cUm        := CriaVar('B1_UM')
Private nQtdBase   := CriaVar('B1_QB')
Private oButton1

Private cProdPA0   := CriaVar('G1_COD')

Private lCadSOW    := .F.

Private lEdtRevSim := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para barrar a alteracao da estrutura        |
//| do produto.                                                  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MT200ALT")
	lAltOpc := ExecBlock("MT200ALT",.F.,.F.,)
	If ValType(lAltOpc)=="L" .And. lAltOpc .And. nOpcx==4
		nOpcx := 2
	EndIf
EndIf

If AliasInDic("SOW")
	SOW->(DbSetOrder(1))
	If SOW->(dbSeek(xFilial('SOW'), .F.))
		lCadSOW := .T.
	EndIf
EndIf

nOpcOrig := nOpcX

If nOpcX == 2
	cTitulo += OemToAnsi(STR0018) // 'Visualisa‡„o'
ElseIf nOpcX == 3
	cTitulo += OemToAnsi(STR0016) // 'Inclus„o'
ElseIf nOpcX == 4
	cTitulo += OemToAnsi(STR0015) // 'Altera‡„o'
ElseIf nOpcX == 5
	ldbTree := .T.
	cTitulo += OemToAnsi(STR0017) // 'Exclus„o'
EndIf

ARegsSGF := {}
ARegsSGFdel := {}

If nOpcX == 3
	cUm        := ''
	cRevisao   := ''
	cProduto   := Space(TamSX3("G1_COD")[1]/*Len(SG1->G1_COD)*/)
	cProdPA0   := Space(TamSX3("G1_COD")[1]/*Len(SG1->G1_COD)*/)
	cCodAtual  := Replicate('ú', TamSX3("G1_COD")[1]/*Len(SG1->G1_COD)*/)
	cValComp   := Replicate('ú', TamSX3("G1_COD")[1]/*Len(SG1->G1_COD)*/) + 'ú'
	nQtdBasePai:= nQtdBase := 0
Else
	If nOpcX == 4 .And. l200Auto
		SG1->(dbSetOrder(1))
		If !SG1->(dbSeek(xFilial("SG1")+aAutoCab[ProcP(aAutoCab,"G1_COD"),2]))
			Help(" ",1,"REGNOIS")
			lRet := .F.
		EndIf
	EndIf
	SB1->(dbSetOrder(1))
	If lRet .And. !SB1->(dbSeek(xFilial('SB1')+SG1->G1_COD, .F.))
		Help('  ', 1, 'NOFOUNDSB1')
		lRet := .F.
	EndIf
	cUm         := SB1->B1_UM
	cRevisao    := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)   //SB1->B1_REVATU
	cRevSim     := ''
	cProduto    := SG1->G1_COD
	cCodAtual   := SG1->G1_COD
	cValComp    := SG1->G1_COD + 'ú'
	nQtdBasePai := nQtdBase := RetFldProd(SB1->B1_COD,"B1_QB")

	cProdPA0   := SG1->G1_COD
EndIf

If lRet .And. (nOpcX == 4 .Or. nOpcX == 5) .And.;
	IsProdProt(cProduto) .And. !IsInCallStack("DPRA340INT")
	Aviso(STR0061,STR0075,{"OK"}) //-- Protótipos podem ser manipulados somente através do módulo Desenvolvedor de Produtos (DPR).
	lRet := .F.
EndIf

If lRet
	If !l200Auto
		aSize := MsAdvSize()
		aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

		AADD(aObjects,{100,30,.T.,.F.})
		AADD(aObjects,{100,100,.T.,.T.})
		aPosObj := MsObjSize(aInfo, aObjects)

		DEFINE MSDIALOG oDlg FROM  aSize[7],0 TO aSize[6],aSize[5]  TITLE cTitulo STYLE DS_MODALFRAME PIXEL
		oDlg:lEscClose  := .F. //Nao permite sair ao se pressionar a tecla ESC.
		oDlg:lMaximized := .T.

		@ 000,000 MSPANEL oPanel1 OF oDlg

		@ 001,005 GROUP oGroup TO 40,aPosObj[2,4] OF oPanel1  PIXEL
		oGroup:Align := CONTROL_ALIGN_ALLCLIENT
		@ 008, 033 SAY   OemToAnsi(STR0019) SIZE 037, 007 OF oPanel1 PIXEL // 'C¢digo:'
		@ 006, 053 MSGET cProduto           SIZE 105, 010 OF oPanel1 PIXEL PICTURE PesqPict('SG1','G1_COD') ;
			WHEN (!ldbTree .And. nOpcX==3) VALID A200Codigo(cProduto, @cUm, @cRevisao, @nQtdBase, oUm, oRevisao, oQtdBase, oDlg) ;
			F3 'SB1'

		@ 008, 190 SAY   OemToAnsi(STR0020) SIZE 040, 007 OF oPanel1 PIXEL	//'Unidade:'
		@ 006, 215 MSGET oUm Var cUm        SIZE 015, 010 OF oPanel1 PIXEL ;
			WHEN .F.

		@ 008, 240 SAY   OemToAnsi(STR0023)    SIZE 030, 007 OF oPanel1 PIXEL // 'Revis„o'
		@ 006, 265 MSGET oRevisao Var cRevisao SIZE 015, 010 OF oPanel1 PIXEL PICTURE PesqPict('SB1','B1_REVATU',3) ;
			WHEN (!ldbTree .And. nOpcX == 2 .And. lGetRevisa) .Or. (nOpcX == 4 .And. lGetRevisa) VALID A200GetRev(@lGetRevisa, oDlg, oTree, cProduto, cRevisao, nOpcX,lRevAut,@aPaiEstru)

		@ 022, 012 SAY   OemToAnsi(STR0021)  SIZE 054, 007 OF oPanel1 PIXEL // 'Estrutura Similar:'
		@ 020, 053 MSGET oCodSim Var cCodSim SIZE 105, 010 OF oPanel1 PIXEL PICTURE PesqPict('SG1','G1_COD') ;
			WHEN (!ldbTree .And. lEdtRevSim .And. nOpcX == 3 .And. lGetRevisa) VALID a200RevMax(cCodSim, @cRevSim) .And. A200CodSim(cProduto, cCodSim, @aUndo);
			F3 'SG1'

		@ 022, 170 SAY OemToAnsi(STR0023)   SIZE 030, 007 OF oPanel1 PIXEL // 'Revisão da estrutura similar'
		@ 020, 195 MSGET RevSim Var cRevSim SIZE 015, 010 OF oPanel1 PIXEL PICTURE PesqPict('SB1','B1_REVATU',3);
			WHEN (!ldbTree .And. nOpcX == 3 .And. lGetRevisa) VALID A200RevSim(@lGetRevisa, oDlg, oTree, cProduto, cCodSim, cRevSim, nOpcX,lRevAut,@aPaiEstru);

		@ 022, 220 SAY   OemToAnsi(STR0022)    SIZE 053, 007 Of oPanel1 PIXEL // 'Quantidade Base:'
		@ 020, 265 MSGET oQtdBase Var nQtdBase SIZE 071, 010 Of oPanel1 PIXEL PICTURE PesqPictQt('B1_QB',20) ;
			WHEN (nOpcX==3.Or.nOpcX==4) VALID A200QBase(nQtdBase, nOpcX, cProduto, cCodSim, oTree, oDlg)

		@ 000,000 MSPANEL oPanel2 OF oDlg
		oTree := DbTree():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3]-25,aPosObj[2,4], oPanel2,,,.T.)
		oTree:Align := CONTROL_ALIGN_ALLCLIENT

		@ 000,000 MSPANEL oPanel3 OF oDlg

		@ 000,000 MSPANEL oPanelRight SIZE __DlgWidth(oMainWnd)/1,5 OF oPanel3
		oPanelRight:Align := CONTROL_ALIGN_RIGHT

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Defini‡„o dos Bot”es Utilizados                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//-- Operacao x Componente
		If !lPyme .And. (nOpcx == 3 .Or. nOpcx == 4)
			@ 000,000 MSPANEL oPanelB1 SIZE 90,40 OF oPanelRight
			@ 000,000 BUTTON oButton1 PROMPT "&"+A635Titulo() ACTION Ma200Oper(nOpcX, oTree:GetCargo(), oTree) SIZE 65,11 OF oPanelB1 PIXEL
            If nOpcx == 3
				oButton1:Disable()
			EndIf
		Endif

		//-- Inclus„o
		@ 000,000 MSPANEL oPanelB2 SIZE 30,40 OF oPanelRight
		If nOpcX == 2 .Or. nOpcX == 5
			DEFINE SBUTTON oButton2 FROM 000,000  TYPE 4 DISABLE OF oPanelB2 //-- Desabilita Inlus„o
		Else
			DEFINE SBUTTON oButton2 FROM 000,000  TYPE 4 ENABLE OF oPanelB2 ;
			ACTION If(!ldbTree .And. nOpcX < 4, .T., Ma200Edita(nOpcX, oTree:GetCargo(), oTree, 3, @aUndo, @lMudou, @aAltEstru,, aKey, aBkey,@aPaiEstru))
			oButton2:cTOOLTIP:=OemToAnsi(STR0068)//--"Incluir-<Alt-I>"
			bkey279:={|| If(!ldbTree .And. nOpcX < 4, .T., Ma200Edita(nOpcX, oTree:GetCargo(), oTree, 3, @aUndo, @lMudou, @aAltEstru,, aKey, aBkey,@aPaiEstru))}
			AADD(aBkey, {bkey279, 279})
			SetKey(279, bkey279)
		EndIf

		@ 000,000 MSPANEL oPanelB3 SIZE 30,40 OF oPanelRight
		//-- Altera‡„o
		DEFINE SBUTTON oButton3 FROM 000,000 TYPE 11 ENABLE OF oPanelB3 ;
			ACTION If(!ldbTree .And. nOpcX < 4, .T., Ma200Edita(nOpcX, oTree:GetCargo(), oTree, 4, @aUndo, @lMudou, @aAltEstru,, aKey, aBkey,@aPaiEstru))
			oButton3:cTOOLTIP:=OemToAnsi(STR0069)//--"Editar-<Alt-M>"
			bKey300 := {|| Ma200Edita(nOpcX, oTree:GetCargo(), oTree, 4, @aUndo, @lMudou, @aAltEstru,, aKey, aBkey,@aPaiEstru)}
			AADD(aBkey, {bkey300, 300})
			SetKey(300, bKey300)

		@ 000,000 MSPANEL oPanelB4 SIZE 30,40 OF oPanelRight
		//-- Exclus„o
		If nOpcX == 2 .Or. nOpcX == 5
			DEFINE SBUTTON oButton4 FROM 000,000  TYPE 3 DISABLE OF oPanelB4 //-- Desabilita Exclus„o
		Else
			DEFINE SBUTTON oButton4 FROM 000,000  TYPE 3 ENABLE OF oPanelB4 ;
				ACTION If(!ldbTree .And. nOpcX < 4, .T., Ma200Edita(nOpcX, oTree:GetCargo(), oTree, 5, @aUndo, @lMudou, @aAltEstru,, aKey, aBkey,@aPaiEstru))
				oButton4:cTOOLTIP:=OemToAnsi(STR0070)//--"Excluir-<Alt-E>"
				bKey274 :={|| If(!ldbTree .And. nOpcX < 4, .T., Ma200Edita(nOpcX, oTree:GetCargo(), oTree, 5, @aUndo, @lMudou, @aAltEstru,, aKey, aBkey,@aPaiEstru))}
				AADD(aBkey, {bkey274, 274})
				SetKey(274, bKey274)
		EndIf

		@ 000,000 MSPANEL oPanelB5 SIZE 30,40 OF oPanelRight
		//-- Pesquisa e Posiciona
		DEFINE SBUTTON oButPosic FROM 000,000 TYPE 15 ENABLE OF oPanelB5 ;
			ACTION If(!ldbTree .And. nOpcX < 4, .T., Ma200Posic(nOpcX, oTree:GetCargo(), oTree, aKey, aBkey))
			oButPosic:cToolTip:=OemToAnsi(STR0071) //--"Pesquisar-<Alt-P>"
			oButPosic:cTitle := OemToAnsi(STR0002) // 'Pesquisar'
			bKey281:={|| Ma200Posic(nOpcX, oTree:GetCargo(), oTree, aKey, aBkey)}
			AADD(aBkey,{bkey281, 281})
			SetKey(281, bKey281)

		@ 000,000 MSPANEL oPanelB6 SIZE 30,40 OF oPanelRight

		//-- Confirma
		If nOpcX == 5
			DEFINE SBUTTON oButton6 FROM 000,000 TYPE 1 ENABLE OF oPanelB6 ;
				ACTION(lConfirma:=.T., Ma200Del(cCodAtual), Ma200Fecha(oDlg, oTree, nOpcX, .T., cUm, cProduto, nQtdBase, cRevisao, .T., aAltEstru,aKey,aBkey,aUndo,aPaiEstru))
				oButton6:cToolTip:=OemToAnsi(STR0072)//--"OK-<Alt-N>"
				bKey305:={|| (lConfirma:=.T., Ma200Del(cCodAtual,aKey,aBKey), Ma200Fecha(oDlg, oTree, nOpcX, .T., cUm, cProduto, nQtdBase, cRevisao, .T., aAltEstru, aKey, aBkey, aUndo,aPaiEstru))}
				AADD(aBkey, {bkey305, 305})
				SetKey(305, bKey305)
		Else
			DEFINE SBUTTON oButton6 FROM 000,000 TYPE 1 ENABLE OF oPanelB6 ;
				ACTION (lConfirma:=.T., If(Btn200Ok(aUndo, cProduto, nOpcX) .And. ldbTree, Ma200Fecha(oDlg, oTree, nOpcX, lMudou, cUm, cProduto, nQtdBase, cRevisao, .T., aAltEstru, aKey, aBkey, aUndo,aPaiEstru), .T.))
				oButton6:cToolTip:=OemToAnsi(STR0072)//--"OK-<Alt-N>"
				bKey305:={|| (lConfirma:=.T., If(Btn200Ok(aUndo, cProduto, nOpcX) .And. ldbTree, Ma200Fecha(oDlg, oTree, nOpcX, lMudou, cUm, cProduto, nQtdBase, cRevisao, .T., aAltEstru, aKey, aBkey, aUndo,aPaiEstru), .T.))}
				AADD(aBkey, {bkey305, 305})
				SetKey(305, bKey305)
		EndIf

		@ 000,000 MSPANEL oPanelB7 SIZE 30,40 OF oPanelRight

		//-- Abandona
		DEFINE SBUTTON oButton7 FROM 000,000  TYPE 2 ENABLE OF oPanelB7 ;
			ACTION (lAbandona := .T., Ma200Undo(aUndo, nOpcx), Ma200Fecha(oDlg, oTree, nOpcX, .F., cUm, cProduto, nQtdBase, cRevisao, .F., aAltEstru, aKey, aBkey, aUndo,aPaiEstru))
			oButton7:cToolTip:=OemToAnsi(STR0073)//--"Cancela-<Alt-X>"
			bKey301:={|| (lAbandona := .T., Ma200Undo(aUndo, nOpcx), Ma200Fecha(oDlg, oTree, nOpcX, .F., cUm, cProduto, nQtdBase, cRevisao, .F., aAltEstru, aKey, aBkey, aUndo,aPaiEstru))}
			AADD(aBkey, {bkey301, 301})
			SetKey(301, bKey301)

		//-- Explode Proximo Nivel
		If !lExpand
			@ 000,000 MSPANEL oPanelB8 SIZE 30,40 OF oPanelRight
			If nOpcX <> 2 .And. nOpcX <> 4
				DEFINE SBUTTON oButton8 FROM 000,000  TYPE 19 DISABLE OF oPanelB8 //-- Desabilita Explode Nivel
			Else
				DEFINE SBUTTON oButton8 FROM 000,000  TYPE 19 ENABLE OF oPanelB8 ;
				ACTION NextNivel(nOpcX, oTree:GetCargo(), oTree, oDlg, akey, aBkey)
				oButton8:cToolTip:=OemToAnsi(STR0074)//--"Avançar-<Alt-V>"
				bkey303:= {|| NextNivel(nOpcX, oTree:GetCargo(), oTree, oDlg, akey, aBkey)}
				AADD(aBkey, {bkey303, 303})
				Setkey(303, bKey303)
			EndIf
		EndIf

		oPanelB7:Align := CONTROL_ALIGN_RIGHT
		oPanelB6:Align := CONTROL_ALIGN_RIGHT
		oPanelB5:Align := CONTROL_ALIGN_RIGHT
		oPanelB4:Align := CONTROL_ALIGN_RIGHT
		oPanelB3:Align := CONTROL_ALIGN_RIGHT
		oPanelB2:Align := CONTROL_ALIGN_RIGHT
		If !lExpand
			oPanelB8:Align := CONTROL_ALIGN_RIGHT
        EndIf
        If !lPyme .and. (nOpcx == 3 .Or. nOpcx == 4)
			oPanelB1:Align := CONTROL_ALIGN_RIGHT
		EndIf

		If !lPyme .And. (nOpcx == 3 .Or. nOpcx == 4)
			oButton1:Align := CONTROL_ALIGN_RIGHT
		EndIf
		If !lExpand
			oButton8:Align := CONTROL_ALIGN_RIGHT
		EndIf
		oButton2:Align := CONTROL_ALIGN_RIGHT
		oButton3:Align := CONTROL_ALIGN_RIGHT
		oButton4:Align := CONTROL_ALIGN_RIGHT
		oButPosic:Align := CONTROL_ALIGN_RIGHT
		oButton6:Align := CONTROL_ALIGN_RIGHT
		oButton7:Align := CONTROL_ALIGN_RIGHT

		If ExistBlock("MA200CAB")
			ExecBlock("MA200CAB",.F.,.F.,{cProduto,nOpcx,oPanel1,8,22,270})
		EndIf

		ACTIVATE MSDIALOG oDlg ON INIT ( Ma200Monta(oTree, oDlg, cCodAtual, cCodSim, cRevisao, nOpcX),;
			AlignObject(oDlg,{oPanel1,oPanel2,oPanel3},1,2,{070,,020}),;
			If(nOpcx==4,oRevisao:SetFocus(),NIL));
			VALID If(nOpcX>2.And.nOpcX<=5.And.!(lConfirma.Or.lAbandona), (Ma200Undo(aUndo), Ma200Fecha(,, nOpcX, .F., cUm, cProduto, nQtdBase, cRevisao, .F., aAltEstru,aKey, aBKey,aUndo,aPaiEstru)), .T.)
	Else

		lConfirma := .T.
		If Type('aEndEstrut')=="U"
			Private aEndEstrut := {}
		EndIf
		aValidGet := {}
		cProduto  := aAutoCab[ProcP(aAutoCab,"G1_COD"),2]
		If nOpcx # 4
			aAdd(aValidGet,{"cProduto"    ,cProduto+Space(Len(SG1->G1_COD)-Len(cProduto)),"A200Codigo(cProduto, @cUm, @cRevisao, @nQtdBase)",.t.})
		EndIf
		If nOpcx # 5 .And. !Empty(nPos := ProcP(aAutoCab,"G1_QUANT"))
			Aadd(aValidGet,{"nQtdBase"    ,aAutoCab[nPos,2],"A200QBase(nQtdBase,"+Str(nOpcX)+", cProduto)",.t.})
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a conistencia dos gets do cabecalho.                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !SG1->(MsVldGAuto(aValidGet)) // consiste os gets
			lRet := .F.
		EndIf

		Do Case
		//-- Inclusao
		Case lRet .And. nOpcx == 3
			cCodAtual	:= cProduto
			cCargo		:= cProduto + Space(TamSx3("G1_TRT")[1]) + cProduto + '000000000' + '000000000' + 'NOVO'
			For nI:=1 To Len(aAutoItens)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Faz a validacao dos gets dos NOs(itens)                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lDbTree := .T. //Esta variavel somente foi setada para .T. para nao ser necessario alterar as validacoes dos gets
				aValidGet := SG1->(MSArrayXDB(aAutoItens[nI],.T.,nOpcX))

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cria variaveis de memoria para ser usada nas rotinas posteriores ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nJ:=1 To Len(aValidGet)
					If Type('M->'+aValidGet[nJ,1])=='U'
						CriaVar(aValidGet[nJ,1],.F.)
					EndIf
					&('M->'+aValidGet[nJ,1]) := aValidGet[nJ,2]
				Next

				If Empty(aValidGet) .Or. !SG1->(MsVldGAuto(aValidGet)) // consiste os gets
					lRet := .F.
					Exit
				EndIf
				lDbTree := .F. //Restaurada para false para evitar problemas de atualizacao de objetos

				// Atualiza Revisao Inicial
				nPosGet := aScan(aValidGet , {|x| Alltrim(x[1])=="G1_REVINI"})
		        If nPosGet > 0
		        	cGetRevIni := aValidGet[nPosGet,2]
		        EndIf
				nPosAut := aScan(aAutoItens[nI], {|x| Alltrim(x[1])=='G1_REVINI'})
		    	If nPosAut > 0
		    		cAutRevIni := aAutoItens[nI][nPosAut,2]
		    	EndIf
			    If cGetRevIni <> cAutRevIni
			    	aValidGet[nPosGet,2] := Trim(cAutRevIni)
			    EndIf

				// Atualiza Sequencia
				nPosGet := aScan(aValidGet , {|x| Alltrim(x[1])=="G1_TRT"})
		        If nPosGet > 0
		        	cGetTrt := aValidGet[nPosGet,2]
		        EndIf
				nPosAut := aScan(aAutoItens[nI], {|x| Alltrim(x[1])=='G1_TRT'})
		    	If nPosAut > 0
		    		cAutTrt := aAutoItens[nI][nPosAut,2]
		    	EndIf
			    If nPosGet > 0 .And. nPosAut > 0 .And. cGetTrt <> cAutTrt
			    	aValidGet[nPosGet,2] := cAutTrt
			    EndIf

				If nI > 1
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Emula o possicionamento do Gargo(GetGargo)do objeto dbTree   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SG1")
					DbSetOrder(1)
					If MsSeek(xFilial("SG1")+M->G1_COD)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Caso encontre, possiciona o NO pai, capturando o Recno()     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cCargo  := M->G1_COD + M->G1_TRT + M->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) +'CODI'
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Se o pai nao existir informa um cargo com caracteristicas de ³
						//³ um NO novo para ser usada a variavel cCodAtual como NO pai.  ³
						//³ Neste caso as informacoes importantes sao: Recno Zero e stri-³
						//³ ng 'NOVO', para utilizar a logica ja existente no Ma200Edita.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cCargo  := M->G1_COD + M->G1_TRT + M->G1_COMP + StrZero(0, 9) + StrZero(nIndex ++, 9) +'NOVO'
					EndIf
					cCodAtual := M->G1_COD
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Faz a inclusao do NO na estrutura a partir do cargo informado³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Ma200Edita(nOpcX,cCargo,NIL,nOpcX,@aUndo,@lMudou,@aAltEstru,,,,@aPaiEstru)
					lRet := .f.
					Exit
				EndIf
			Next nI
		//-- Alteracao
		Case lRet .And. nOpcx == 4
			cCodAtual := cProduto
			cCargo 	  := SG1->(G1_COD+G1_TRT+G1_COMP+StrZero(Recno(),9)+StrZero(nIndex++,9)+'CODI')

			//-- Deleta componentes nao recebidos na nova estrutura
			A200Auto4E(SG1->G1_COD,@aUndo,@lMudou,@aAltEstru,@aPaiEstru,lPriNivel)

			For nI := 1 To Len(aAutoItens)
				nRecAtu := 0
				For nJ := 1 To Len(aAutoItens[nI])
					CriaVar(aAutoItens[nI,nJ,1],.F.)
					&('M->'+aAutoItens[nI,nJ,1]) := aAutoItens[nI,nJ,2]
				Next nJ

				//-- Para nao permitir o cadastro de itens que nao sejam da estrutura
				If cProduto # M->G1_COD .And.; //-- Verifica se o item pai neste no e o pai da estrutura
					aScan(aAutoItens,{|x| x[ProcP(aAutoItens[nI],"G1_COMP"),2] == M->G1_COD}) == 0 //-- Verifica se e componente em outro no
					Aviso( STR0061 /*"Atenção"*/,STR0102 /*"Estrutura incosistente: produto "*/ +AllTrim(M->G1_COD) + STR0103/*" sem elo."*/,{"OK"})
					lRet := .F.
					Exit
				EndIf

				If lRevAut .And. lCadSOW
					A200UltRev(aAutoItens[nI,ProcP(aAutoItens[nI],"G1_COD"),2],aAutoItens[nI,ProcP(aAutoItens[nI],"G1_COMP"),2],aAutoItens[nI,ProcP(aAutoItens[nI],"G1_TRT"),2],@nRecAtu)
					If nRecAtu > 0
						SG1->(dbGoTo(nRecAtu))
					EndIf
				EndIf
				//-- Seta nOpcx para execucao de axInclui ou axAltera
				SG1->(dbSetOrder(1))
				If (nRecAtu > 0) .Or. ;
					( !(lRevAut .And. lCadSOW) .And. SG1->(MsSeek(xFilial("SG1")+aAutoItens[nI,ProcP(aAutoItens[nI],"G1_COD"),2]+aAutoItens[nI,ProcP(aAutoItens[nI],"G1_COMP"),2]+aAutoItens[nI,ProcP(aAutoItens[nI],"G1_TRT"),2])))

					//Se utiliza revisão automática, verifica se o registro da SG1 é referente a última revisão.
					//Se não for a última revisão, irá fazer a inclusão e não alteração.
					If lRevAut
						lAchou := .F.
						//Busca revisão do Pai Direto
						SB1->(dbSetOrder(1))
						If SB1->(dbSeek(xFilial('SB1') + aAutoItens[nI,ProcP(aAutoItens[nI],"G1_COD"),2], .F.))
							cRev := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU) //SB1->B1_REVATU

							While SG1->(!Eof()) .And. SG1->(G1_FILIAL+G1_COD+G1_COMP+G1_TRT) == ;
														xFilial("SG1")+aAutoItens[nI,ProcP(aAutoItens[nI],"G1_COD"),2]+aAutoItens[nI,ProcP(aAutoItens[nI],"G1_COMP"),2]+aAutoItens[nI,ProcP(aAutoItens[nI],"G1_TRT"),2]

								If SG1->G1_REVINI > cRev .Or. SG1->G1_REVFIM < cRev
									SG1->(dbSkip())
									Loop
								EndIf
								lAchou := .T.
								Exit
							End
						EndIf
					Else
						lAchou := .T.
					EndIf
					If lAchou
						nOpcx := 4
						//-- Emula preenchimento da cCargo (ja que nao ha tree) para uso das funcoes
						cCargo  := SG1->(G1_COD+G1_TRT+G1_COMP+StrZero(Recno(),9)+StrZero(nIndex++,9)+'COMP')
						T_CARGO := SG1->(G1_COD+G1_TRT+G1_COMP+StrZero(Recno(),9)+StrZero(nIndex++,9)+'COMP')
					Else
						nOpcx := 3
						//-- Emula preenchimento da cCargo (ja que nao ha tree) para uso das funcoes
						cCargo  := aAutoItens[nI,ProcP(aAutoItens[nI],"G1_COD"),2]+aAutoItens[nI,ProcP(aAutoItens[nI],"G1_TRT"),2]+aAutoItens[nI,ProcP(aAutoItens[nI],"G1_COMP"),2]+StrZero(0,9)+StrZero(nIndex++,9)+'NOVO'
						T_CARGO := aAutoItens[nI,ProcP(aAutoItens[nI],"G1_COD"),2]+aAutoItens[nI,ProcP(aAutoItens[nI],"G1_TRT"),2]+aAutoItens[nI,ProcP(aAutoItens[nI],"G1_COMP"),2]+StrZero(0,9)+StrZero(nIndex++,9)+'NOVO'
					EndIf
				Else
					nOpcx := 3
					//-- Emula preenchimento da cCargo (ja que nao ha tree) para uso das funcoes
					cCargo  := aAutoItens[nI,ProcP(aAutoItens[nI],"G1_COD"),2]+aAutoItens[nI,ProcP(aAutoItens[nI],"G1_TRT"),2]+aAutoItens[nI,ProcP(aAutoItens[nI],"G1_COMP"),2]+StrZero(0,9)+StrZero(nIndex++,9)+'NOVO'
					T_CARGO := aAutoItens[nI,ProcP(aAutoItens[nI],"G1_COD"),2]+aAutoItens[nI,ProcP(aAutoItens[nI],"G1_TRT"),2]+aAutoItens[nI,ProcP(aAutoItens[nI],"G1_COMP"),2]+StrZero(0,9)+StrZero(nIndex++,9)+'NOVO'
				EndIf

				//-- Monta array com os campos da SG1 a serem validados
				aValidGet := SG1->(MSArrayXDB(aAutoItens[nI],.T.,nOpcX))

				//-- Cria variaveis de memoria para serem usadas nas rotinas posteriores
				For nJ := 1 To Len(aValidGet)
					If Type('M->'+aValidGet[nJ,1]) == 'U'
						CriaVar(aValidGet[nJ,1],.F.)
					EndIf
					&('M->'+aValidGet[nJ,1]) := aValidGet[nJ,2]
				Next nJ

				//-- Faz a validacao dos gets dos NOs(itens)
				lDbTree := .T. //Esta variavel somente foi setada para .T. para nao ser necessario alterar as validacoes dos gets
				If Empty(aValidGet) .Or. !SG1->(MsVldGAuto(aValidGet))
					lRet := .F.
					Exit
				EndIf
				lDbTree := .F. //Restaurada para false para evitar problemas de atualizacao de objetos

				cCodAtual := M->G1_COD

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Faz a inclusao do NO na estrutura a partir do cargo informado³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Ma200Edita(nOpcX,cCargo,NIL,nOpcX,@aUndo,@lMudou,@aAltEstru,,,,@aPaiEstru,aAutoItens[nI])
					lRet := .f.
					Exit
				EndIf
			Next nI
		//-- Exclusao
		Case lRet .And. nOpcx == 5
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui todos os G1_COD iguais ao cProduto (alimentado somente³
			//³ pelo array do cabecalho, onde sera obrigatorio apenas passar |
			//³ o codigo do Produto (G1_COD) que deseja excluir.             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lRet := Ma200Del(cProduto)
		EndCase

		//Restaura a variável nOpcX para o seu valor original. Quando executado alteração de estrutura por MsExecAuto
		//o valor da nOpcX é alterado durante o processamento.
		nOpcX := nOpcOrig

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nao ocorreu nenhum erro, finaliza o processo, caso contra-³
		//³ rio restaura a situacao anterior a execucao da rotina automa-|
		//³ tica.                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			Ma200Fecha(oDlg, oTree, nOpcX, .T. , cUm, cProduto, nQtdBase, cRevisao, .T., aAltEstru, , , aUndo,aPaiEstru)
		Else
			Ma200Undo(aUndo)
		EndIf

		If !lRet .AND. lTransact
			DisarmTransaction()
		EndIf

		If nOpcx <> 5 .And. PCPIntgPPI()
			SG1->(dbSetOrder(1))
			For nI := 1 To Len(aUndo)
				SG1->(dbGoTo(aUndo[nI,1]))
				If aUndo[nI,2] == 2
					lExclusao := .T.
					ALTERA := .F.
					INCLUI := .F.
				Else
					lExclusao := .F.
					If aUndo[nI,2] == 1
						ALTERA := .F.
						INCLUI := .T.
					Else
						ALTERA := .T.
						INCLUI := .F.
					EndIf
				EndIf

				//Verifica se esta estrutura já foi processada.
				aNewRecs := {}
				cCodPai := SG1->G1_COD
				SG1->(dbSeek(xFilial("SG1")+cCodPai))
				While SG1->(!Eof()) .And. xFilial("SG1")+cCodPai == SG1->(G1_FILIAL+G1_COD)
					aAdd(aNewRecs,SG1->(Recno()))
					SG1->(dbSkip())
				End
				lExec := .T.
				For nX := 1 To Len(aRecProc)
					If aScan(aNewRecs,{|x| x == aRecProc[nX]}) > 0
						lExec := .F.
						Exit
					EndIf
				Next nX
				If !lExec
					//Se a estrutura já foi processada, pula para a próxima alteração
					Loop
				EndIf
				SG1->(dbGoTo(aUndo[nI,1]))
				If PCPFiltPPI("SG1", SG1->G1_COD+"|"+SG1->G1_COMP, "SG1")
					aAdd(aRecProc,SG1->(Recno()))
					nTotal++
					If MATA200PPI(, SG1->G1_COD, lExclusao, .F., .T.)
						nSucess++
						aAdd(aDadosInt, {SG1->G1_COD,"", STR0062, STR0082}) //"OK" // "Processado com sucesso"
					Else
						nError++
					EndIf
				EndIf
			Next nI
		EndIf
	EndIf

	nPos := SG1->(Recno())

	//-- Integracao Chao de Fabrica
	If lRet .And. lConfirma .And. !lAbandona .And. (nOpcX == 3 .Or. nOpcX == 4 .Or. nOpcX == 5) .And. lIntSFC
   		If nOpcX != 5
			For nX := 1 To Len(aUndo)
				SG1->(dbGoTo(aUndo[nX,1]))
				If aUndo[nX,2] == 1 .And. Empty(aScan(aSFCJaInt,{|x| x == SG1->G1_COD}))
					A200IntSFC(SG1->G1_COD,'2')
					aAdd(aSFCJaInt,SG1->G1_COD)
				EndIf
			Next nX
		Else
			SG1->(dbGoTo(aRecDel[1]))
			A200IntSFC(SG1->G1_COD,'1')
		EndIf
	EndIf

	SG1->(dbGoTo(nPos))
EndIf

//--Destativa teclas de atalho
For nX:=1 to Len(aKey)
	Set Key aKey[nX] To
Next nX

//-- Reinicializa Variaveis
cInd5     := ''
ldbTree   := .F.
cValComp  := Replicate('ú', Len(SG1->G1_COD)) + 'ú'
cCodAtual := Replicate('ú', Len(SG1->G1_COD))

RestArea(aAreaAnt)

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} A200UltRev()
Buscar a ultima revisão da estrutura para execução automática
@author Renan Roeder
@since 29/03/2018
/*/
//------------------------------------------------------------------
Static Function A200UltRev(cProdPai,cProdCom,cSequen,nRecAtu)
Local aAreaAnt := GetArea()
Local cRevAtu  := CriaVar("B1_REVATU",.F.)

SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1") + cProdPai, .F.))
	cRevAtu := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)  //SB1->B1_REVATU
EndIf

SG1->(dbSetOrder(1))
SG1->(dbSeek(xFilial("SG1")+cProdPai+cProdCom+cSequen))
While !SG1->(EOF()) .And. SG1->(G1_FILIAL+G1_COD+G1_COMP+G1_TRT) == xFilial("SG1")+cProdPai+cProdCom+cSequen
	If SG1->G1_REVFIM == cRevAtu
		nRecAtu := Recno()
	EndIf
	SG1->(dbSkip())
End

RestArea(aAreaAnt)
Return nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ma200Monta ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Montagem do Arquivo Temporario para o Tree(Func.Recurssiva)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ma200Monta(ExpO1,ExpO2,ExpC1,ExpC2,ExpC3,ExpN1,ExpC4,ExpC5)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto Tree                                        ³±±
±±³          ³ ExpO2 = Objeto Dlg                                         ³±±
±±³          ³ ExpC1 = Codigo do Produto                                  ³±±
±±³          ³ ExpC2 = Codigo da estrutura similar		 (OPC)	          ³±±
±±³          ³ ExpC3 = Codigo da revisao				 (OPC)	          ³±±
±±³          ³ ExpN1 = Numero da Op‡„o Escolhida         (OPC)            ³±±
±±³          ³ ExpC4 = Cargo do Produto no Tree          (OPC)            ³±±
±±³          ³ ExpC5 = Sequencia Pai                     (OPC)            ³±±
±±³          ³ ExpL1 = Zera cont. das variaves staticas  (OPC) 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False se o Codigo do Produto nao existir, e True em C.C.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ma200Monta(oTree, oDlg, cProduto, cCodSim, cRevisao, nOpcX, cCargo, cTRTPai, lZeraStatic, lOpc)

Local nRecAnt    := 0
Local cComp      := ''
Local cPrompt    := ''
Local cFolderA   := 'FOLDER5'
Local cFolderB   := 'FOLDER6'
Local cRevPI 	 := ""
Local nRecCargo  := 0
Local dValIni    := CtoD('  /  /  ')
Local dValFim    := CtoD('  /  /  ')
Local lRet		 := .T.
Local lContinua	 := .T.
Local nQtdeSG1   := 0
Local lExpand    := mv_par03 == 1
Local lExibeOPC  := .T.
Local lRetPE
Local lA200rvPi  := ExistBlock("A200RVPI")
Local nIndSG1	 := 1
Local lM200BMP   := ExistBlock("M200BMP")
Local uRet       := Nil
Local lRevAut    := SuperGetMv("MV_REVAUT",.F.,.F.)
Local lOpcional  := .F.
Local lOpcAux    := .T.
Local cOpc       := ""
Local aOpc       := {}
Static nNivelTr  := 0
Static cFistCargo:= NIL

Default lOpc := .T.
Default lAutomacao := .F.

// -- Atualiza nivel da estrutura
nNivelTr += 1

nOpcX := If(nOpcX==Nil,0,nOpcX)

lExpEst := .T.

If ExistBlock("MA200ORD")
	nIndSG1 := ExecBlock("MA200ORD",.F.,.F.)
	If ValType(nIndSG1) # "N"
		nIndSG1 := 1
	EndIf
EndIf

If !ldbTree .And. nOpcX < 5
	oDlg:SetFocus()
	lRet := .F.
EndIf

If lRet
	lExpEst := .T.

	//-- Posiciona no SB1
	cPrompt := cProduto + Space(400)
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial('SB1') + cProduto, .F.))
		cPrompt := AllTrim(cProduto) + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(AllTrim(cProduto)))
	EndIf
	cPrompt += Space(Len(STR0060)+TamSX3("G1_QUANT")[1]) //"QTDE:"
	cPrompt += Space(200)

	SG1->(dbSetOrder(nIndSG1))
	If nOpcX == 3 .And. cProduto # Replicate('ú', Len(SG1->G1_COD)) .And. Empty(cCodSim)

		If lM200BMP
			uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
			If ValType(uRet) == "A"
				cFolderA := uRet[1]
				cFolderB := uRet[2]
			EndIf
		EndIf

		//-- Cria‡„o de uma nova estrutura
		oTree:AddTree(A200Prompt(cPrompt,"",,cProduto),.T.,cFolderA,cFolderB,,,cProduto+Space(TamSx3("G1_TRT")[1])+cProduto+'000000000'+'000000000'+'NOVO')
		oTree:EndTree()
		oTree:Refresh()
		oTree:SetFocus()
		lContinua := .F.

	ElseIf !SG1->(dbSeek(xFilial('SG1') + cProduto, .F.))
		If !lAutomacao
			If ldbTree
				oTree:Refresh()
				oTree:SetFocus()
			Else
				oDlg:SetFocus()
			EndIf
		EndIf
		lRet := .F.
	EndIf

	If lRet .And. lContinua
		cTRTPai := If(cTRTPai==Nil,SG1->G1_TRT,cTRTPai)

		dValIni := SG1->G1_INI
		dValFim := SG1->G1_FIM
		If cCargo == Nil
			cCargo := SG1->G1_COD + cTRTPai + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) + 'CODI'
		ElseIf (nRecCargo := Val(SubStr(cCargo,Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))) > 0
			nRecAnt := SG1->(Recno())
			SG1->(dbGoto(nRecCargo))
			dValIni := SG1->G1_INI
			dValFim := SG1->G1_FIM
			nQtdeSG1 := SG1->G1_QUANT
			If GetMV("MV_SELEOPC") == "S" .And. lOpc
           cOpc := Padr(SG1->G1_GROPC, TamSX3("G1_GROPC")[1]) + Padr(SG1->G1_OPC, TamSX3("G1_OPC")[1]) + "/"
           aOpc := aClone(ListOpc(Nil,Nil,cOpc))
        EndIf
			SG1->(dbGoto(nRecAnt))
		EndIf

		//-- Define as Pastas a serem usadas
		cFolderA := 'FOLDER5'
		cFolderB := 'FOLDER6'
		If Right(cCargo, 4) == 'COMP' .And. ;
			(dDataBase < dValIni .Or. dDataBase > dValFim)
			cFolderA := 'FOLDER7'
			cFolderB := 'FOLDER8'
		EndIf

		If lM200BMP
			uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
			If ValType(uRet) == "A"
				cFolderA := uRet[1]
				cFolderB := uRet[2]
			EndIf
		EndIf

		//-- Adiciona o Pai na Estrutura
		If !lAutomacao
		oTree:AddTree(A200Prompt(cPrompt,cCargo,nQtdeSG1,,aOpc),.T.,cFolderA,cFolderB,,,cCargo)
		EndIf

		Do While !SG1->(Eof()) .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cProduto

			lExpEst := .T.

			//-- Nao Adiciona Componentes fora da Revis„o
			If (nOpcX == 2 .Or. nOpcX == 4) .And. (cRevisao # Nil) .And. ;
				!(SG1->G1_REVINI <= cRevisao .And. (SG1->G1_REVFIM >= cRevisao .Or. SG1->G1_REVFIM = ' '))
				SG1->(dbSkip())
				Loop
			EndIf

			nRecAnt  := SG1->(Recno())
			cComp    := SG1->G1_COMP
			cCargo   := SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) + 'COMP'
			nQtdeSG1 := SG1->G1_QUANT

		If Empty(SG1->G1_GROPC)
           lOpcAux := .F.
        Else
           lOpcAux := .T.
        EndIf

        If GetMV("MV_SELEOPC") == "S"
           cOpc := Padr(SG1->G1_GROPC, TamSX3("G1_GROPC")[1]) + Padr(SG1->G1_OPC, TamSX3("G1_OPC")[1]) + "/"
           aOpc := aClone(ListOpc(Nil,Nil,cOpc))
        EndIf

			If cFistCargo == NIL
				cFistCargo := cCargo
			EndIf

			//-- Define as Pastas a serem usadas
			cFolderA := 'FOLDER5'
			cFolderB := 'FOLDER6'
			If dDataBase < SG1->G1_INI .Or. dDataBase > SG1->G1_FIM
				cFolderA := 'FOLDER7'
				cFolderB := 'FOLDER8'
			EndIf

			//-- Posiciona no SB1
			cPrompt := cComp + Space(400)
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial('SB1') + cComp, .F.))
				cPrompt := AllTrim(cComp) + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(AllTrim(cComp)))
			EndIf
			cPrompt += Space(Len(STR0060)+TamSX3("G1_QUANT")[1]) //"QTDE:"
			cPrompt += Space(200)

			lExpEst := .T.
			If ExistBlock("MT200EXP")
				lExpEst := ExecBlock("MT200EXP",.F.,.F., {cComp})
			endIf

   			If SG1->(dbSeek(xFilial('SG1') + SG1->G1_COMP, .F.)) .and. lExpEst
				If ExistBlock("MT200OPC")
					lRetPE := ExecBlock("MT200OPC",.F.,.F.,SG1->G1_COMP)
					lExibeOPC := IIF(ValType(lRetPE)=="L",lRetPE,lExibeOPC)
				EndIf

				cRevPi := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)  //PCPREVATU(SB1->B1_COD)
				IF empty(cRevPI)
					cRevPi := '001'
				endif
				//cRevPi := IIf(SB1->B1_REVATU = ' ','001',SB1->B1_REVATU)

				If lA200rvPi
					cRevPi := Execblock ("A200RVPI",.F.,.F.,{cProduto, cRevisao, SG1->G1_COD, cRevPi})
				EndIf

   				If lExpand .And. lExibeOPC
					//-- Adiciona um Nivel a Estrutura
					If cComp == SG1->G1_COD .And. !lOpcAux
                lOpcional := .F.
             Else
                lOpcional := .T.
             EndIf
					Ma200Monta(oTree, oDlg, SG1->G1_COD,'',cRevPi,IIF(lRevaut,2,If(nOpcX==3,0,nOpcX)), cCargo, cTRTPai,,lOpcional)
				Else
					If lM200BMP
						uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
						If ValType(uRet) == "A"
							cFolderA := uRet[1]
							cFolderB := uRet[2]
						EndIf
					EndIf
					oTree:AddItem(A200Prompt(cPrompt, cCargo, nQtdeSG1,,aOpc), cCargo, cFolderA, cFolderB,,, 2)
				EndIf
			Else
				//-- Adiciona um Componente a Estrutura
				If lM200BMP
					uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
					If ValType(uRet) == "A"
						cFolderA := uRet[1]
						cFolderB := uRet[2]
					EndIf
				EndIf

				DBADDITEM oTree PROMPT A200Prompt(cPrompt, cCargo ,nQtdeSG1,,aOpc) RESOURCE cFolderA CARGO cCargo
			EndIf

			SG1->(dbGoto(nRecAnt))
			SG1->(dbSkip())
		EndDo
		If !lAutomacao
			oTree:EndTree()

			If ldbTree
				// --- Atualiza obj.dbtree apos processar a estrutura
				If nNivelTr == 1
					If( cFistCargo <> NIL )
						cCargo := cFistCargo
						cFirstCargo := NIL
					EndIf
					oTree:TreeSeek(cCargo)
					oTree:Refresh()
					oTree:SetFocus()
				EndIf
			Else
				oDlg:SetFocus()
			EndIf
		EndIf
	EndIf
EndIf
If lContinua
	// --- Atualiza nivel da estrutura
	nNivelTr -= 1
EndIf

//Zera conteudo das variaveis static, necessario para montagem do tree na rotina MATC015.
If ValType(lZeraStatic)=="L" .And. lZeraStatic
	nNivelTr  := 0
	cFistCargo:= NIL
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ma200ATree ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Adiciona Componentes ao Tree existente (Func.Recursiva) 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ma200ATree(ExpO1, ExpC1, ExpC2, ExpC3)		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto Tree                                        ³±±
±±³          ³ ExpC1 = Codigo do Produto                                  ³±±
±±³          ³ ExpC2 = Cargo do Produto no Tree                           ³±±
±±³          ³ ExpC3 = TRT Pai (sequencia)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ma200ATree(oTree, cProduto, cCargo, cTRTPai, aOpcPai)

Local aAreaAnt   := GetArea()
Local nRecAnt    := 0
Local cComp      := ''
Local cPrompt    := ''
Local cFolderA   := 'FOLDER5'
Local cFolderB   := 'FOLDER6'
Local dValIni    := CtoD('  /  /  ')
Local dValFim    := CtoD('  /  /  ')
Local nRecCargo  := 0
Local cCargoPai  := ''
Local nQtdeSG1   := 0
Local lM200BMP   := ExistBlock("M200BMP")
Local uRet       := Nil
Local cRevAtual  := ''
Local cOpc       := ""
Local aOpc       := {}

Default aOpcPai  := {}
Default lAutomacao := .F.
cTRTPai := If(cTRTPai==Nil,SG1->G1_TRT,cTRTPai)

dValIni := SG1->G1_INI
dValFim := SG1->G1_FIM
If cCargo == Nil
	cCargo := SG1->G1_COD + cTRTPai + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) + 'COMP'
ElseIf (nRecCargo := Val(SubStr(cCargo,Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))) > 0
	nRecAnt := SG1->(Recno())
	SG1->(dbGoto(nRecCargo))
	dValIni  := SG1->G1_INI
	dValFim  := SG1->G1_FIM
	nQtdeSG1 := SG1->G1_QUANT
	SG1->(dbGoto(nRecAnt))
EndIf

If GetMV("MV_SELEOPC") == "S" .And. (nRecAnt != nRecCargo .Or. SG1->G1_COMP == cProduto)
   If Len(aOpcPai) > 0
      aOpc := aClone(aOpcPai)
   Else
      cOpc := Padr(SG1->G1_GROPC, TamSX3("G1_GROPC")[1]) + Padr(SG1->G1_OPC, TamSX3("G1_OPC")[1]) + "/"
      aOpc := aClone(ListOpc(Nil,Nil,cOpc))
   EndIf
EndIf

//-- Define as Pastas a serem usadas
cFolderA := 'FOLDER5'
cFolderB := 'FOLDER6'
If Right(cCargo, 4) == 'COMP' .And. ;
	(dDataBase < dValIni .Or. dDataBase > dValFim)
	cFolderA := 'FOLDER7'
	cFolderB := 'FOLDER8'
EndIf

//-- Posiciona no SB1
cPrompt := cProduto + Space(400)
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial('SB1') + cProduto, .F.))
	cPrompt := AllTrim(cProduto) + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(AllTrim(cProduto)))
	cRevAtual :=  IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)  // SB1->B1_REVATU
EndIf
cPrompt += Space(Len(STR0060)+TamSX3("G1_QUANT")[1]) //"QTDE:"
cPrompt += Space(200)

If lM200BMP
	uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
	If ValType(uRet) == "A"
		cFolderA := uRet[1]
		cFolderB := uRet[2]
	EndIf
EndIf

//-- Adiciona o Componente na Estrutura
If !lAutomacao
oTree:AddItem(A200Prompt(cPrompt, cCargo, nQtdeSG1,,aOpc), cCargo, cFolderA, cFolderB,,, 2)
oTree:TreeSeek(cCargo)
EndIf
cCargoPai := cCargo

//-- Se o Componente for Pai, Adiciona sua Estrutura
SG1->(dbSetOrder(1))
If SG1->(dbSeek(xFilial('SG1') + cProduto, .F.))
	Do While !SG1->(Eof()) .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cProduto

		If !( Empty(cRevAtual) .Or. ( SG1->G1_REVINI <= cRevAtual .And. SG1->G1_REVFIM >= cRevAtual ) )
			SG1->(dbSkip())
			Loop
		EndIf
		nRecAnt  := SG1->(Recno())
		cComp    := SG1->G1_COMP
		cCargo   := SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) + 'COMP'
		nQtdeSG1 := SG1->G1_QUANT

		If GetMV("MV_SELEOPC") == "S"
		   cOpc := Padr(SG1->G1_GROPC, TamSX3("G1_GROPC")[1]) + Padr(SG1->G1_OPC, TamSX3("G1_OPC")[1]) + "/"
		   aOpc := aClone(ListOpc(Nil,Nil,cOpc))
		EndIf

		//-- Define as Pastas a serem usadas
		cFolderA := 'FOLDER5'
		cFolderB := 'FOLDER6'
		If dDataBase < SG1->G1_INI .Or. dDataBase > SG1->G1_FIM
			cFolderA := 'FOLDER7'
			cFolderB := 'FOLDER8'
		EndIf

		//-- Posiciona no SB1
		cPrompt := cComp + Space(400)
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial('SB1') + cComp, .F.))
			cPrompt := AllTrim(cComp) + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(AllTrim(cComp)))
		EndIf
		cPrompt += Space(Len(STR0060)+TamSX3("G1_QUANT")[1]) //"QTDE:"
		cPrompt += Space(200)

		If SG1->(dbSeek(xFilial('SG1') + SG1->G1_COMP, .F.))
			//-- Adiciona um Nivel a Estrutura
			Ma200ATree(oTree, SG1->G1_COD, cCargo, , aOpc)
			oTree:TreeSeek(cCargoPai)
		Else
			If lM200BMP
				uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
				If ValType(uRet) == "A"
					cFolderA := uRet[1]
					cFolderB := uRet[2]
				EndIf
			EndIf
			//-- Adiciona um Componente a Estrutura
			If !lAutomacao
			oTree:AddItem(A200Prompt(cPrompt, cCargo, nQtdeSG1,,aOpc), cCargo, cFolderA, cFolderB,,, 2)
			EndIf
		EndIf

		SG1->(dbGoto(nRecAnt))
		SG1->(dbSkip())
	EndDo

EndIf

If !lAutomacao
oTree:Refresh()
oTree:SetFocus()
EndIf
RestArea(aAreaAnt)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ma200Edita ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Edi‡„o dos Itens da Estrutura                              ³±±
±±³          ³          			 		                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ma200Edita(ExpN1,ExpC1,ExpO1,ExpN2,ExpA1,ExpL1,ExpA2,ExpN3,³±±
±±³			 ³ ExpN4,ExpA3)											 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Op‡„o da Edi‡„o                                    ³±±
±±³          ³ ExpC1 = Chave do Registro                                  ³±±
±±³          ³ ExpO1 = Objeto Tree                                        ³±±
±±³          ³ ExpN2 = Op‡„o escolhida no Bot„o                           ³±±
±±³          ³ ExpA1 = Array com os Recnos dos Componentes Incl/Excl      ³±±
±±³          ³ ExpL1 = variavel logica a ser atualizada na funcao         ³±±
±±³          ³ ExpA2 = Array c/ a descendˆncia dos produtos incluidos     ³±±
±±³          ³ ExpN3 = qtde. basica                                       ³±±
±±³          ³ ExpA3 = tecla de atalho                                    ³±±
±±³          ³ ExpA4 = Array con. blo. de cod. que sera exe. pela tecla de³±±
±±³          ³ atalho e tecla de atalho,Exeplo: aBkey -> aBkey[bKey][aKey]³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso ocorra algum problema, True C.C. 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Ma200Edita(nOpcX, cCargo, oTree, nOpcY, aUndo, lMudou, aAltEstru, nQtdBase, aKey, aBKey, aPaiEstru , aAuto)
Local aAreaAnt   := GetArea()
Local aCampos    := {}
Local aAreaSG1   := SG1->(GetArea())
Local aUsrBut 	 := {}
Local aButtons	 := {}
Local nRecno	 := 0
Local nPos       := 0
Local nX         := 0
Local lInclui    := (nOpcY==3 .And. nOpcX#2)
Local lAltera    := (nOpcY==4 .And. nOpcX#2)
Local lExclui    := (nOpcY==5 .And. nOpcX#2)
Local lRet       := .T.
Local cTipo      := ''
Local nUndoRecno := 0
Local cFolderA   := 'FOLDER5'
Local cFolderB   := 'FOLDER6'
Local aDescend   := {}
Local cCargoPai  := ''
Local cPrompt    := ""
Local lM200BMP   := Existblock("M200BMP")
Local uRet       := Nil
Local lRevAut    := SuperGetMv("MV_REVAUT",.F.,.F.)
Local nInd       := 0
Local cOpc       := ""
Local aOpc       := {}
Local lExclusao  := .F.
Local aNewRecs   := {}
Default aKey     := {}

//-- Variaveis utilizadas nos Ax's
Private aAlter     := {}
Private aAcho      := {}
Private cDelFunc   := 'a200TudoOk("E")'
Private lDelFunc   := .T.
Private cCodPai    := ''
Private aUndo2 	:= aUndo
If Type('aEndEstrut')=="U"
	Private aEndEstrut := {}
EndIf

//--Desativa teclas de atalho
For nX := 1 to len(aKey)
	Set Key aKey[nX] to
Next nX

aUndo := If(aUndo==Nil,{},aUndo)

//-- Variaveis do Componente Tree referentes ao registro Atual
nRecno := Val(SubStr(cCargo,Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))
cTipo  := Right(cCargo,4)

if oTree != nil .AND. ! lExclui
	oTree:TreeSeek(cCargo)
	oTree:Refresh()
	oTree:SetFocus()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para adicionar botoes na enchoice  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "MA200BUT" )
	If Valtype( aUsrBut := Execblock( "MA200BUT", .f., .f. ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButtons, x ) } )
	EndIF
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validar manutenção da estrutura³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "MT200ALCO" )
	lRet := Execblock( "MT200ALCO", .f., .f. )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta do Array aAcho os campos que n„o devem aparecer       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
a200Fields(@aAcho)
If (nPos := aScan(aAcho, {|x| 'G1_FILIAL' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'G1_COD'    $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'G1_NIV'    $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'G1_NIVINV' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'G1_OK' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'G1_LISTA' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'G1_LOCCONS' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'G1_FANTASM' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'G1_USAALT' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta do Array aAlter os campos que n„o devem ser alterados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAlter := aClone(aAcho)
If lAltera
	If (nPos := aScan(aAlter, {|x| 'G1_COMP' $ Upper(x)})) > 0
		aDel(aAlter, nPos); aSize(aAlter, Len(aAlter)-1)
	EndIf
EndIf
If lAltera .Or. lInclui
	If lRevAut .And. lCadSOW
		If (nPos := aScan(aAlter, {|x| 'G1_REVINI' $ Upper(x)})) > 0
			aDel(aAlter, nPos); aSize(aAlter, Len(aAlter)-1)
		EndIf
		If (nPos := aScan(aAlter, {|x| 'G1_REVFIM' $ Upper(x)})) > 0
			aDel(aAlter, nPos); aSize(aAlter, Len(aAlter)-1)
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona o SG1 no registro a ser editado                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo # 'NOVO' .And. nRecno <= 0
	Help(' ', 1, 'CODNEXIST')
	lRet	:= .F.
EndIf

dbSelectArea('SG1')
dbSetOrder(1)
dbGoto(If(nRecno>0,nRecno,aAreaSG1[3]))

If lRet .And. FindFunction("RodaNewPCP") .And. RodaNewPCP() .And. lAltera .And. (!Empty(SG1->G1_LISTA) .Or. !Empty(SG1->G1_FANTASM) .Or. !Empty(SG1->G1_LOCCONS))
	Aviso(STR0100,STR0104,{"Ok"})
	lRet := .F.
EndIf


If lAltera .Or. lExclui
	AADD(aValAnt,{nRecno, SG1->G1_TRT, SG1->G1_COMP, ' ', ' ', ' '})

	//Relaciona as tabelas SGF e SG1
	//SG1 ja esta no array aValAnt de 1 a 3

	SGF->(dbSeek(xFilial("SGF")+SG1->G1_COD))
	While SGF->(!Eof()) .And. SGF->(GF_FILIAL) == xFilial("SGF") .And. SGF->GF_PRODUTO == SG1->G1_COD
		If SGF->GF_TRT == SG1->G1_TRT
			For nInd := 1 To Len(aValAnt)
				If  aValAnt[nInd][2] == SGF->GF_TRT  .And.;
					aValAnt[nInd][3] == SGF->GF_COMP

					aValAnt[nInd][4] := SGF->(RecNo())
					aValAnt[nInd][5] := SGF->GF_TRT
					aValAnt[nInd][6] :=	SGF->GF_COMP
				EndIf
			Next
		EndIf
		SGF->(dbSkip())
	EndDo

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³N„o edita o Pai                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. !lInclui .And. (cTipo == 'CODI' .Or. cTipo == 'NOVO')
	Help(' ',1,'REGNOIS') //-- Help NAO PODE EDITAR O PAI
	lRet	:= .F.
EndIf
If lRet
	cCodPai   := If(nRecno>0,If(cTipo=='CODI',SG1->G1_COD,SG1->G1_COMP),cCodAtual)
	/*If (nOpcX == 3) .And. !Vazio(cCodSim) .And. !Vazio(cRevSim)
		cCodPai := cProduto
	EndIf*/
	If l200Auto
		If lInclui
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Comando utilizado para habilitar chamada do PE generico em cada chamada ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SetStartMod(.T.)
			INCLUI := .T.
			ALTERA := .F.
			aRotina := ACLONE(aBkpARot)
			If AxIncluiAuto(Alias(), 'a200TudoOK("I")') == 1
				lMudou := .T.
				BEGIN TRANSACTION
					RecLock('SG1', .F.)
					Replace G1_COD With cCodPai
					MsUnlock()
				END TRANSACTION
				If aScan(aUndo, {|x| x[1]==Recno()}) == 0
					aAdd(aUndo, {Recno(), 1}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
				EndIf
				//-- Carrega o array para efetuar a revisao inicial e final de forma automatica
				If lRevAut
					For nX := 1 To IIF(Len(aPaiEstru)=0,1,Len(aPaiEstru))
						If aScan(aPaiEstru, {|x| x[1]==SG1->G1_COD}) == 0
							aAdd(aPaiEstru,{SG1->G1_COD,.T.})
						ElseIF aPaiEstru[nX][1] == SG1->G1_COD
							aPaiEstru[nX][2] := .T.
						EndIf
					Next nX
				EndIf
			Else
				lRet	:= .F.
			EndIf
		ElseIf lAltera
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Guarda o Status inicial do Registro ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCampos := {}
			If aScan(aUndo, {|x| x[1]==Recno()}) == 0
				For nX := 1 To FCount()
					aAdd(aCampos, FieldGet(nX))
				Next nX
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Comando utilizado para habilitar chamada do PE generico em cada chamada ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SetStartMod(.T.)
			INCLUI := .F.
			ALTERA := .T.
			aRotina := ACLONE(aBkpARot)
			If AxAltera(Alias(),Recno(),4,aAcho,aAlter,,,'a200TudoOk("A")',,,aButtons,,aAuto) == 1

				If aScan(aUndo, {|x| x[1]==Recno()}) == 0
					aAdd(aUndo, {Recno(), 3, aCampos}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
				EndIf

				//-- Alimenta Array com a Descendˆncia dos Produtos Alterados
				If Len(aDescend) > 0
					For nX := 1 to Len(aDescend)
						If aScan(aAltEstru, aDescend[nX]) == 0
							aAdd(aAltEstru, aDescend[nX])
						EndIf
					Next nX
				EndIf
				//-- Carrega o array para efetuar a revisao inicial e final de forma automatica
				If lRevAut .And. lCadSOW
					For nX := 1 To IIF(Len(aPaiEstru)=0,1,Len(aPaiEstru))
						If aScan(aPaiEstru, {|x| x[1]==SG1->G1_COD}) == 0
							aAdd(aPaiEstru,{SG1->G1_COD,.T.})
						ElseIF aPaiEstru[nX][1] == SG1->G1_COD
							aPaiEstru[nX][2] := .T.
						EndIf
					Next nX
				EndIf
			Else
				lRet	:= .F.
			EndIf
		ElseIf lExclui
			nUndoRecno := Recno()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Comando utilizado para habilitar chamada do PE generico em cada chamada ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SetStartMod(.T.)
			INCLUI := .F.
			ALTERA := .F.
			If !lRevAut
				aRotina := ACLONE(aBkpARot)
				If AxDeleta(Alias(),Recno(),5,,,aButtons,,aAuto) == 2
					If lDelFunc
						lMudou := .T.
						If (nPos := aScan(aUndo,{|x| x[1] == nUndoRecno})) == 0
							aAdd(aUndo,{nUndoRecno,2}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
						Else
							If aUndo[nPos,2] != 1
								aUndo[nPos,2] := 2
							EndIf
						EndIf
						//-- Alimenta Array com a Descendˆncia dos Produtos Alterados
						If Len(aDescend) > 0
							For nX := 1 to Len(aDescend)
								If aScan(aAltEstru, aDescend[nX]) == 0
									aAdd(aAltEstru, aDescend[nX])
								EndIf
							Next nX
						EndIf
					EndIf
				Else
					lRet := .F.
				EndIf
			Else
				nPos:=aScan(aUndo, {|x| x[1]==nUndoRecno .AND. x[2]==2 })

				If nPos == 0
					aAdd(aUndo, {nUndoRecno, 2}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
				Else
					aUndo[nPos,2] := 2 //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
				EndIf
			EndIf
		EndIf
	Else
		cCargoPai := oTree:GetCargo()
		If nOpcX == 3 .Or. nOpcX == 4	//-- Inclui ou Altera
			aDescend := {}
			a200Descen(@cValComp, @aDescend, oTree)
			If lInclui
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Comando utilizado para habilitar chamada do PE generico em cada chamada ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SetStartMod(.T.)
				INCLUI := .T.
				ALTERA := .F.
				aRotina := ACLONE(aBkpARot)
				If AxInclui(Alias(), Recno(), 3, aAcho,, aAlter, 'a200TudoOK("I")', , ,aButtons) == 1
					aAdd(aDescend, G1_COMP)
					lMudou := .T.
					BEGIN TRANSACTION
					RecLock('SG1', .F.)
						Replace G1_COD With cCodPai
					MsUnlock()
					END TRANSACTION
					If aScan(aUndo, {|x| x[1]==Recno()}) == 0
						aAdd(aUndo, {Recno(), 1}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
					EndIf
					//-- Alimenta Array com a Descendˆncia dos Produtos Incluidos
					If Len(aDescend) > 0
						For nX := 1 To Len(aDescend)
							If aScan(aAltEstru, aDescend[nX]) == 0
								aAdd(aAltEstru, aDescend[nX])
							EndIf
						Next nX
					EndIf
					//-- Carrega o array para efetuar a revisao inicial e final de forma automatica
					If lRevAut
						For nX := 1 To IIF(Len(aPaiEstru)=0,1,Len(aPaiEstru))
							If aScan(aPaiEstru, {|x| x[1]==SG1->G1_COD}) == 0
								aAdd(aPaiEstru,{SG1->G1_COD,.T.})
							ElseIF aPaiEstru[nX][1] == SG1->G1_COD
								aPaiEstru[nX][2] := .T.
							EndIf
						Next nX
					EndIf
					If cTipo == 'NOVO'
						oTree:Reset()
						Ma200ATree(oTree, SG1->G1_COD, SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP + StrZero(SG1->(Recno()),9) + StrZero(nIndex ++, 9) + 'CODI')
					Else
						Ma200ATree(oTree, SG1->G1_COMP, SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP + StrZero(SG1->(Recno()),9) + StrZero(nIndex ++, 9) + 'COMP')
					EndIf
					oTree:TreeSeek(cCargoPai)
				Else
					lRet := .F.
				EndIf
				INCLUI := .F.
			ElseIf lAltera
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Guarda o Status inicial do Registro ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCampos := {}
				If aScan(aUndo, {|x| x[1]==Recno()}) == 0
					For nX := 1 To FCount()
						aAdd(aCampos, FieldGet(nX))
					Next nX
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Comando utilizado para habilitar chamada do PE generico em cada chamada ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SetStartMod(.T.)
				aRotina := ACLONE(aBkpARot)
				INCLUI := .F.
				ALTERA := .T.
				If AxAltera(Alias(), Recno(), 4, aAcho, aAlter,,, 'a200TudoOk("A")', , ,aButtons) == 1

					If aScan(aUndo, {|x| x[1]==Recno()}) == 0
						aAdd(aUndo, {Recno(), 3, aCampos}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
					EndIf

					//-- Alimenta Array com a Descendˆncia dos Produtos Alterados
					If Len(aDescend) > 0
						For nX := 1 to Len(aDescend)
							If aScan(aAltEstru, aDescend[nX]) == 0
								aAdd(aAltEstru, aDescend[nX])
							EndIf
						Next nX
					EndIf
					//-- Carrega o array para efetuar a revisao inicial e final de forma automatica
					If lRevAut .And. lCadSOW
						For nX := 1 To IIF(Len(aPaiEstru)=0,1,Len(aPaiEstru))
							If aScan(aPaiEstru, {|x| x[1]==SG1->G1_COD}) == 0
								aAdd(aPaiEstru,{SG1->G1_COD,.T.})
							ElseIF aPaiEstru[nX][1] == SG1->G1_COD
								aPaiEstru[nX][2] := .T.
							EndIf
						Next nX
					EndIf

					If oTree != nil
						oTree:TreeSeek(cCargo)
						oTree:Refresh()
						oTree:SetFocus()
					EndIf

					//-- Remonta o Prompt do Tree
					SB1->(dbSeek(xFilial("SB1")+SG1->G1_COMP))
					dbSelectArea(oTree:cArqTree)
					RecLock((oTree:cArqTree), .F.)
					Replace T_CARGO With (SG1->G1_COD+SG1->G1_TRT+SG1->G1_COMP+StrZero(SG1->(Recno()),9)+StrZero(nIndex ++, 9)+'COMP')
					MsUnlock()

					If GetMV("MV_SELEOPC") == "S"
                		cOpc := Padr(SG1->G1_GROPC, TamSX3("G1_GROPC")[1]) + Padr(SG1->G1_OPC, TamSX3("G1_OPC")[1]) + "/"
                		aOpc := aClone(ListOpc(Nil,Nil,cOpc))
             		EndIf

					cCargo  := T_CARGO
					cPrompt := AllTrim(SG1->G1_COMP) + " - " + AllTrim(SB1->B1_DESC)
					cPrompt := AllTrim(A200Prompt(cPrompt,cCargo, SG1->G1_QUANT,,aOpc))
					oTree:ChangePrompt(cPrompt, cCargo)

					//-- Define as Pastas a serem usadas
					cFolderA := 'FOLDER5'
					cFolderB := 'FOLDER6'
					If Right(oTree:GetCargo(), 4) == 'COMP' .And. ;
						(dDataBase < SG1->G1_INI .Or. dDataBase > SG1->G1_FIM)
						cFolderA := 'FOLDER7'
						cFolderB := 'FOLDER8'
					EndIf

					If lM200BMP
						uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
						If ValType(uRet) == "A"
							cFolderA := uRet[1]
							cFolderB := uRet[2]
						EndIf
					EndIf

					oTree:ChangeBMP(cFolderA, cFolderB)

					// Atualiza array de SGF

					For nX := 1 to Len(aValAnt)
						if !Empty(aValAnt[nX][4])

							SGF->(dbGoTo(aValAnt[nX][4]))

							If !(alltrim(str(aValAnt[nX][4])) $ cIteAlt)
							cIteAlt += alltrim(str(aValAnt[nX][4]))+"/"

								aadd(ARegsSGFdel,{SGF->GF_PRODUTO,SGF->GF_ROTEIRO, SGF->GF_OPERAC, SGF->GF_COMP, SGF->GF_TRT})
								aadd(ARegsSGF,{SGF->GF_PRODUTO,SGF->GF_ROTEIRO, SGF->GF_OPERAC, SGF->GF_COMP, SG1->G1_TRT})
							Endif
						Endif
					Next
				Else
					lRet	:= .F.
				EndIf
			ElseIf lExclui
				a200Desc(SG1->G1_COMP)
				nUndoRecno := Recno()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Comando utilizado para habilitar chamada do PE generico em cada chamada ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SetStartMod(.T.)
				INCLUI := .F.
				ALTERA := .F.
				If lRevAut .And. nOpcX#3
					aRotina := ACLONE(aBkpARot)
				   IF AxVisual(Alias(), Recno(), 2, aAcho) == 1
				   		nPos:=aScan(aUndo, {|x| x[1]==nUndoRecno .AND. x[2]==2 })

						If nPos == 0
							aAdd(aUndo, {nUndoRecno, 2}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
						Else
							//elimina registro deletado do array para não gerar revisão
							ADel(aUndo,nPos)
							ASize(aUndo,Len(aUndo)-1)
							//eliminar g1 criado
							RecLock('SG1',.F.)
				 				SG1->(dbDelete())
							SG1->(MsUnlock())
						EndIf
						oTree:DelItem()
						oTree:Refresh()
						For nX := 1 To Len(aPaiEstru)
							IF aPaiEstru[nX][1] == SG1->G1_COD
								aPaiEstru[nX][2] := .T.
							EndIf
						Next nX
				   EndIf
				Else
					REGTOMEMORY( "SG1", .T. )
					aRotina := ACLONE(aBkpARot)
					If AxDeleta(Alias(), Recno(), 5, , aAcho, aButtons) == 2
						If lDelFunc
							lMudou := .T.
							nPos:=aScan(aUndo, {|x| x[1]==nUndoRecno})
							If nPos == 0
								aAdd(aUndo, {nUndoRecno, 2}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
							Else
								If aUndo[nPos,2] != 1
									aUndo[nPos,2]:=2
								EndIf
							EndIf
							//-- Alimenta Array com a Descendˆncia dos Produtos Alterados
							If Len(aDescend) > 0
								For nX := 1 to Len(aDescend)
									If aScan(aAltEstru, aDescend[nX]) == 0
										aAdd(aAltEstru, aDescend[nX])
									EndIf
								Next nX
							EndIf
							oTree:DelItem()
							oTree:Refresh()
							oTree:SetFocus()
						EndIf
					Else
						lRet := .F.
					EndIf
				EndIf
			EndIf
		ElseIf nOpcX == 2 .Or. nOpcX == 5 //-- Visualiza ou Exclui
			aRotina := ACLONE(aBkpARot)
			AxVisual(Alias(), Recno(), 2, aAcho)
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua o EndEstrut2 apos o END TRANSACTION                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. Len(aEndEstrut) > 0 .And. SuperGetMv("MV_TRANEST",.F.,.T.) != .T.
	For nX := 1 to Len(aEndEstrut)
		FimEstrut2(aEndEstrut[nX,1],aEndEstrut[nX,2])
	Next nX
	aEndEstrut := {}
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta tecla de atalho		                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Ma200StKey(aKey,aBkey)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura Area de trabalho.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±³                   ROTINAS DE CRITICA DE CAMPOS                        ³±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ a200Codigo ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡„o do C¢digo do Produto na Estrutura                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200Codigo(ExpC1,ExpC2,ExpC3,ExpN1,ExpO1,ExpO2,ExpO3,ExpO4)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = C¢digo a ser Validado                              ³±±
±±³          ³ ExpC2 = Unidade de Medida a ser Atualizada                 ³±±
±±³          ³ ExpC3 = Numero da Revis„o a ser atualizado                 ³±±
±±³          ³ ExpN1 = qtde. basica digitada		               		  ³±±
±±³          ³ ExpO1 = objeto da unidade de medida 		           		  ³±±
±±³          ³ ExpO2 = objeto da revisao           		           		  ³±±
±±³          ³ ExpO3 = objeto da qtde. basica			           		  ³±±
±±³          ³ ExpO4 = objeto Dlg                 		           		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ True para C¢digos Validos e False para C¢digos Inv lidos   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A200Codigo(cProduto, cUm, cRevisao, nQtdBase, oUm, oRevisao, oQtdBase, oDlg)

Local aAreaAnt   := GetArea()
Local aAreaSB1   := SB1->(GetArea())
Local aAreaSG1   := SG1->(GetArea())
Local lRet       := .T.
Local lRetPE
Local cQuery	 := ""

If !Empty(oDlg)
   If oDlg:oCtlFocus:cTooltip == OemToAnsi(STR0073)
      return .T.
   Endif
Endif

SB1->(dbSetOrder(1))
If !SB1->(dbSeek(xFilial('SB1') + cProduto, .F.))
	Help(' ',1, 'NOFOUNDSB1')
	lRet := .F.
   	if ! __lPyme .and. !l200Auto
		oButton1:Disable()
	Endif
Else
	cUm         := SB1->B1_UM
	cRevisao    := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU) //SB1->B1_REVATU
	nQtdBasePai := nQtdBase := RetFldProd(SB1->B1_COD,"B1_QB")
	If oUm # Nil
		oUm:Refresh()
	EndIf
	If oRevisao # Nil
		oRevisao:Refresh()
	EndIf
	If oQtdBase # Nil
		oQtdBase:Refresh()
	EndIf
EndIf

If lRet .And. !ldbTree
	If oDlg # Nil
		oDlg:Refresh()
	EndIf
	SG1->(dbSetOrder(1))
	If SG1->(dbSeek(xFilial('SG1') + cProduto, .F.))
		Help(' ',1, 'CODEXIST')
		lRet := .F.
		if ! __lPyme .and. !l200Auto
			oButton1:Disable()
		Endif
	EndIf

	If lRet .And. !SuperGetMv( 'MV_NEGESTR' , .F. , .F. ,  )
		SG1->(dbSetOrder(2))

		cQuery	:= "SELECT COUNT(*) TOTREC FROM "+RetSqlName('SG1')
		cQuery	+= " WHERE "
		cQuery	+= " G1_FILIAL = '"+xFilial("SG1")+"' AND "
		cQuery	+= " G1_COMP = '"+cProduto+"' AND "
		cQuery	+= " G1_QUANT  < 0 AND "
		cQuery	+= " D_E_L_E_T_ <> '*'"
		cQuery := ChangeQuery(cQuery)
		dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYSG1",.F.,.T.)
	    If QRYSG1->TOTREC > 0
			Help(' ',1,'A200NAOINC')
			lRet := .F.
			if ! __lPyme .and. !l200Auto
				oButton1:Disable()
			Endif
	    EndIf
	    QRYSG1->(dbCloseArea())
	EndIf
EndIf

If lRet .And. IsProdProt(cProduto) .And. !IsInCallStack("DPRA340INT")
	Aviso(STR0061,STR0075,{"OK"}) //-- Protótipos podem ser manipulados somente através do módulo Desenvolvedor de Produtos (DPR).
	lRet := .F.
EndIf

If lRet .And. !__lPyme .and. !l200Auto
	oButton1:Enable()
EndIf

If lRet
	If ExistBlock("MT200PAI")
		lRetPE := ExecBlock("MT200PAI",.F.,.F.,cProduto)
		lRet   := IIF(ValType(lRetPE)=="L",lRetPE,lRet)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura Area de trabalho.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSG1)
RestArea(aAreaSB1)
RestArea(aAreaAnt)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ a200CodSim ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida Estrutura Similar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ a200CodSim(ExpC1,ExpC2,ExpA1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = C¢digo do Produto                                  ³±±
±±³          ³ ExpC2 = C¢digo do Produto Similar                          ³±±
±±³          ³ ExpA1 = Array com os recnos                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ True se a Estrutura Silinar for Validada, ou False ne n„o. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A200CodSim(cProduto, cCodSim, aUndo)
Local lRet		 := .T.
Local aAreaAnt   := GetArea()
Local aAreaSB1   := SB1->(GetArea())
Local aAreaSG1   := SG1->(GetArea())
Local cNomeArq   := ''
Local oTempTable := NIL
Local cAliasEstr := GetNextAlias()

Private nEstru   := 0

If !Empty(cCodSim)

	SB1->(dbSetOrder(1))
	If !SB1->(dbSeek(xFilial('SB1') + cCodSim))
		Help(' ',1,'NOFOUNDSB1')
		lRet := .F.
	EndIf

	SG1->(dbSetOrder(1))
	If lRet .And. !SG1->((dbSeek(xFilial('SG1') + cCodSim)))
		Help(' ',1,'ESTNEXIST')
		lRet := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o produto similar n„o contem o      ³
	//³ produto principal em sua estrutura.             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		cNomeArq := Estrut2(cCodSim,,@cAliasEstr,@oTempTable)
		dbSelectArea(cAliasEstr)
		(cAliasEstr)->(dbGotop())
		Do While !(cAliasEstr)->(Eof())
			If (cAliasEstr)->COMP == cProduto
				Help(' ',1,'SIMINVALID')
				lRet := .F.
				Exit
			EndIf
			(cAliasEstr)->(dbSkip())
		EndDo

		If lRet
			If SuperGetMv("MV_TRANEST",.F.,.T.) == .T. .And. Type('aEndEstrut')=="A"
				aAdd(aEndEstrut,{cAliasEstr,oTempTable})
			Else
				FimEstrut2(cAliasEstr,oTempTable)
			EndIf


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Restaura Area de trabalho.                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RestArea(aAreaSG1)
			RestArea(aAreaSB1)
			RestArea(aAreaAnt)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera Registros da Estrutura Similar                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Ma200GrSim(cProduto, cCodSim, @aUndo)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de Entrada para alteracao da Estrutura Similar         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock('MT200CSI')
				//-- Sao passados os seguintes parametros:
				//-- aParamIXB[1] = Codigo do Produto
				//-- aParamIXB[2] = Codigo do Produto Similar
				ExecBlock('MT200CSI', .F., .F., {cProduto, cCodSim})
			EndIf
		EndIf
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a200GetRev  ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Indica se d  Get na revisÆo da estrutura ou n„o            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200GetRev(ExpL1,ExpO1,ExpO2,ExpC1,ExpC2,ExpN1)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Variavel Làgica a ser atualizada na fun‡„o         ³±±
±±³          ³ ExpO1 = Objeto Dlg                                         ³±±
±±³          ³ ExpO2 = Objeto Tree                                        ³±±
±±³          ³ ExpC1 = codigo produto                                     ³±±
±±³          ³ ExpC2 = revisao                                            ³±±
±±³          ³ ExpN1 = Op‡„o Escolhida                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ True                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A200GetRev(lGetRevisao, oDlg, oTree, cProduto, cRevisao, nOpcX, lReAuto, aPaiEstru)
Default lReAuto   := .F.
Default aPaiEstru := {}

lGetRevisao := !lGetRevisao
ldbTree	:= .T.
cCodAtual := cProduto
cValComp  := cProduto + 'ú'
Ma200Monta(oTree, oDlg, cCodAtual, '', cRevisao, nOpcX)
IF lReAuto
	SG1->(DbSetOrder(1))
	If SG1->(dbSeek(xFilial("SG1")+cCodAtual))
		If aScan(aPaiEstru, {|x| x[1]==SG1->G1_COD}) == 0
			aAdd(aPaiEstru,{cCodAtual,.F.})
		EndIf
	EndIf
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A200QBase  ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consiste a Quantidade Basica da Estrutura                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200QBase(ExpN1,ExpN2,ExpC1,ExpC2,ExpO1,ExpO2)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Quantidade Basica Digitada                         ³±±
±±³          ³ ExpN2 = Op‡„o Escolhida                                    ³±±
±±³          ³ ExpC1 = codigo produto                                     ³±±
±±³          ³ ExpC2 = codigo produto similar                             ³±±
±±³          ³ ExpO1 = Objeto Tree                                        ³±±
±±³          ³ ExpO2 = Objeto Dlg                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ True se a Quantidade Base for Maior que Zero, ou False C.C.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A200QBase(nQtdBase, nOpcX, cProduto, cCodSim, oTree, oDlg)
Local lRet := .T.
If QtdComp(nQtdBase) < QtdComp(0) .And. !SuperGetMv( 'MV_NEGESTR' , .F. , .F. ,  )
	Help(' ',1,'MA200QBNEG')
	lRet := .F.
EndIf

If lRet
	nQtdBasePai := M->G1_QUANT := nQtdBase

	If !ldbTree .And. !l200Auto
		ldbTree := .T.
		If nOpcX < 5
			cCodAtual := cProduto
			cValComp  := cProduto + 'ú'
			Ma200Monta(oTree, oDlg, cCodAtual, cCodSim,, nOpcX)
			oTree:TreeSeek(oTree:GetCargo())
		EndIf
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  A200Comp  ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o c¢digo do componente na Estrutura                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200Comp()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ True caso o c¢digo seja validado e False em caso contr rio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function a200Comp()

Local lRet := .T.

lRet := A200ChkNod(M->G1_COMP, cValComp)
If lRet
	lRet := A200Codigo(M->G1_COMP, '', 0, 0)
	If lRet
		lRet := A200OutPai(M->G1_COMP, cValComp)
	EndIf
EndIf

If lRet .And. IsProdProt(M->G1_COMP) .And. !IsInCallStack("DPRA340INT")
	Aviso(STR0061,STR0075,{"OK"}) //-- Protótipos podem ser manipulados somente através do módulo Desenvolvedor de Produtos (DPR).
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A200ChkNod ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica existencia de um mesmo c¢digo em um n¢ da estrutur³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200ChkNod(ExpC1,ExpC2) 	                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = C¢digo a ser pesquisado                            ³±±
±±³          ³ ExpC2 = Lista de C¢digos a ser pesquizada                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A200ChkNod(cProduto, cLista)

Local aAreaAnt := GetArea()
Local aAreaSG1 := SG1->(GetArea())
Local cNomeArq := ''
Local cNomeAli := ''
Local lRet     := .T.
Local oTempTable := NIL

Private nEstru := 0

If cProduto $(cLista)
	Help(' ',1,'A200NODES')
	lRet := .F.
EndIf

//-- Verifica se o Produto possui Estrutura
If lRet
	dbSelectArea('SG1')
	dbSetorder(1)
	If dbSeek(xFilial('SG1') + cProduto, .F.)
		nNAlias ++
		cNomeAli := "ES"+StrZero(nNAlias,3)
		cNomeArq := Estrut2(cProduto, 1,cNomeAli,@oTempTable,,,,.F.)
		dbSelectArea(cNomeAli)
		dbGoTop()
		Do While !Eof() .And. lRet
			If COMP $(cLista)
				Help(' ',1,'A200NODES')
				lRet := .F.
				Exit
			EndIf
			dbSkip()
		EndDo
		If Type('aEndEstrut') == 'A'
			aAdd(aEndEstrut,{cNomeAli,oTempTable})
		Else
			FimEstrut2(Nil, oTempTable)
		EndIf
	EndIf
EndIf

RestArea(aAreaSG1)
RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A200OutPai  ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica a existencia de uma mesmo c¢digo em um n¢ da estru³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200OutPai(ExpC1,ExpC2)		                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = C¢digo a ser pesquizado                            ³±±
±±³          ³ ExpC2 = Lista de C¢gigos a ser pesquizada                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso encontre um c¢digo repetido e True em C.C.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A200OutPai(cProduto, cLista)

Local cPai   := Substr(cLista,1,Tamsx3("G1_COD")[1])
Local nRecno := Recno()
Local nOrdem := IndexOrd()
Local lRet   := .T.

SG1->(dbSetOrder(2))
SG1->(dbSeek(xFilial('SG1')+cPai))
Do While !SG1->(Eof()) .And. SG1->G1_FILIAL == xFilial("SG1")
	If SG1->G1_COD == cProduto
		Help(' ',1,'A200NODES2',,cProduto,2,26)
		lRet := .F.
		Exit
	EndIf
	SG1->(dbSeek(xFilial('SG1')+SG1->G1_COD))
EndDo
dbSetOrder(1)

dbSetOrder(nOrdem)
dbGoto(nRecno)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A200Desc   ³ Autor ³Rodrigo de A.Sartorio³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Posiciona no produto desejado e preenche descricao		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200Desc(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Produto a ser pesquizado                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso encontre um c¢digo repetido e True em C.C.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A200Desc(cCod)

Local aAreaAnt := GetArea()
Local lRet     := .T.

cCod := If(cCod==Nil,M->G1_COMP,cCod)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no produto desejado e preenche descricao      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SB1->(dbSeek(xFilial('SB1')+cCod, .F.))
	M->G1_DESC := SB1->B1_DESC
Else
	Help(' ', 1, 'NOFOUNDSB1')
	lRet := .F.
EndIf

RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MA200Quant ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡„o da quantidade do Produto na Estrutura            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ma200Quant(ExpN1, ExpC1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Quantidade a ser validada                          ³±±
±±³          ³ ExpC1 = Codigo do Produto                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso o valor nao possa ser negativo, e True em C.C.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MA200Quant(nQuant,cCod)

Local nVar       := 0
Local lRet       := .T.
Local cAlias     := ''
Local nRecno     := 0

nVar := If(nQuant==Nil,&(ReadVar()),nQuant)

If IsProdMod(cCod) .And. GetMV('MV_TPHR') == 'N'
	nVar := nVar - Int(nVar)
	If nVar > .5999999999
		HELP(' ',1,'NAOMINUTO')
		lRet := .F.
	EndIf
ElseIf QtdComp(nVar) < QtdComp(0) .And. !SuperGetMv( 'MV_NEGESTR' , .F. , .F. ,  )
	Help(,,'Help',,STR0114,; //"Não é permitido informar quantidades negativas para os componentes."
	     1,0,,,,,,{STR0115}) //"Para que seja possível informar quantidades negativas na estrutura, configure o parâmetro MV_NEGESTR."
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MA200Fecha ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a Integridade do Sistema apos a finaliza‡„o        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ma200Fecha(ExpO1,ExpO2,ExpN1,ExpL1,ExpC1,ExpC2,ExpN1 ...   ³±±
±±³          ³        ... ExpC3,ExpL2,ExpA1,ExpA2,ExpA3)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto Dlg                                         ³±±
±±³          ³ ExpO2 = Objeto Tree                                        ³±±
±±³          ³ ExpN1 = numero da opcao                                    ³±±
±±³          ³ ExpL1 = indica se mudou                                    ³±±
±±³          ³ ExpC1 = unidade de medida                                  ³±±
±±³          ³ ExpC2 = produto                                            ³±±
±±³          ³ ExpN1 = qtde. basica digitada                              ³±±
±±³          ³ ExpC3 = revisao                                            ³±±
±±³          ³ ExpL2 = indica se atualiza o campo B1_QB na confirmacao    ³±±
±±³          ³ ExpA1 = Array c/ a descendˆncia dos produtos incluidos     ³±±
±±³          ³ ExpA2 = tecla de atalho                                    ³±±
±±³          ³ ExpA3 = Array con. blo. de cod. que sera exe. pela tecla de³±±
±±³          ³ atalho e tecla de atalho,Exeplo: aBkey -> aBkey[bKey][aKey]³±±
±±³          ³ ExpA4 = Array com os produtos alterados                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso ocorra algum problema no fechamento, True C.C.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Ma200Fecha(oDlg, oTree, nOpcX, lMudou, cUm, cProduto, nQtdBase, cRevisao, lConfirma, aAltEstru, aKey, aBKey, aUndo,aPaiEstru)

Local lRet       := .T.
Local cLinha1    := STR0024+CHR(13)	//"Cada altera‡„o em uma estrutura pode gerar uma nova revis„o para"
Local cLinha2    := STR0025+CHR(13)	//"o controle hist¢rico de altera‡”es em determinado produto."
Local cLinha3    := STR0026+CHR(13)	//"A altera‡„o deve gerar uma nova revis„o para esta estrutura ?"
Local cTitulo    := STR0027	//"Revis„o Estrutura"
Local aAreaTRB   := {}
Local aAreaSB1   := {}
Local aAreaSG1   := {}
Local cCod       := ''
Local cCodPai    := ''
Local cTipo      := ''
Local cAliasAnt  := ''
Local aExplode   := {}
Local aPai       := {}
Local nX         := 0
Local nY         := 0
Local nPos       := 0
Local nQuant     := 0
Local nQuant1    := 0
Local nQtdNivel  := 0
Local lMap       := .F.
Local nCount     := 0
Local cArqTrab   := ''
Local lIniMap    := .F.
Local lContinua	 := .T.
Local lRetPE     := .T.
Local cConsidUM  := SuperGetMV( "MV_CONSDUM",.F., "KG" )
Local cAliasB1BZ := If(GetMv('MV_ARQPROD')=="SBZ","SBZ","SB1")
Local lAltRev	 := GetNewPar("MV_ALTREV",.F.)
Local lRevAut    := SuperGetMv("MV_REVAUT",.F.,.F.)
Local lDadosSBZ  := .F.
Local cCargo	 := ''
Local nRecno     := 0
Local nInd       := 0
Local lIntgPPI   := PCPIntgPPI()
Local cMsg       := ""
Local lAchou     := .F.
Local lEdita     := .T.

Local aIncRevisa := {}
Local aAltNRev   := {}

Local aAtuCmp    := {}
Local nR         := 0
Local nS         := 0

Private lGravaRev := .T.
Default aKey 	 :={}
Default aUndo	 := {}
Default aPaiEstru := {}
If ( Type("aRecDel") == "U" )
	PRIVATE aRecDel := {}
EndIf

//--Desativa Tecla de atalho
For nX := 1 to len(aKey)
	Set Key aKey[nX] to
Next nX

If lConfirma
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o campo B1_QB na Confirma‡„o da Inclus„o/Altera‡Æo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcX == 3 .Or. nOpcX == 4
		cAliasAnt := Alias()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona SB1 no codigo pai                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cAliasB1BZ == "SBZ"
			dbSetOrder(1)
			SB1->(MsSeek(xFilial('SB1')+cProduto))
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona SB1 ou no SBZ                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lDadosSBZ:=RetArqProd(cProduto)

		dbSelectArea(cAliasB1BZ)
		aAreaSB1 := SB1->(GetArea())
		dbSetOrder(1)
		MsSeek(xFilial(cAliasB1BZ) + cProduto)

		If !(cValToChar(RetFldProd(SB1->B1_COD,"B1_QB")) == cValToChar(nQtdBase))
			If lIntgPPI .And. nOpcX == 4 //Se alterou apenas a quantidade base.
				aAreaSG1 := SG1->(GetArea())
				SG1->(dbSeek(xFilial("SG1")+cProduto))
				//Verifica no array aUndo se algum componente desta estrutura foi alterado.
				//Se encontrar, a integração já foi realizada para este produto, e não é necessário
				//enviar novamente.
				lAchou := .F.
				While SG1->(!Eof()) .And. SG1->(G1_FILIAL+G1_COD) == xFilial("SG1")+cProduto
					If aScan(aUndo,{|x| x[1]==SG1->(Recno())}) > 0
						lAchou := .T.
						Exit
					EndIf
					SG1->(dbSkip())
				End
				SG1->(dbSeek(xFilial("SG1")+cProduto))
				If !lAchou .And. !MATA200PPI(, SG1->G1_COD, .F., .T., .T.)
					cMsg := STR0090 + AllTrim(cProduto) + STR0091 //"Não foi possível realizar a integração com o TOTVS MES para o produto '"XXX"'. Foi gerada uma pendência de integração para este produto."
					Help( ,, 'Help',, cMsg, 1, 0 )
				EndIf
				SG1->(RestArea(aAreaSG1))
			EndIf
			BEGIN TRANSACTION
				If !lDadosSBZ
					RecLock('SBZ')
					Replace SBZ->BZ_QB With nQtdBase
					MsUnlock()
				Else
					RecLock('SB1')
					Replace SB1->B1_QB With nQtdBase
					MsUnlock()
				EndIf
			END TRANSACTION
		EndIf
		RestArea(aAreaSB1)
		dbSelectArea(cAliasAnt)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o campo B1_UREV                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par01 == 1 .And. nOpcX > 2 .And. Len(aAltEstru) > 0
		BEGIN TRANSACTION
			For nX := 1 to Len(aAltEstru)
				If SB1->(dBSeek(xFilial('SB1') + aAltEstru[nX], .F.))
					RecLock('SB1')
					Replace B1_UREV With dDataBase
					MsUnlock()
				EndIf
			Next nX
		END TRANSACTION
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza arquivo de Operacoes x Componentes caso haja exclusao de componentes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Len(aUndo) > 0
		For nY := 1 To Len(aUndo)
			If !lRevAut .And. aUndo[nY][2] == 2
				SG1->(DbGoTo(aUndo[ny][1]))

				IF nOpcX == 4 .And. Empty(ARegsSGFdel)
					ARegsSGFdel := {}

					SGF->(dbSeek(xFilial("SGF")+SG1->G1_COD))
					While SGF->(!Eof()) .And. SGF->(GF_FILIAL) == xFilial("SGF") .And. SGF->GF_PRODUTO == SG1->G1_COD
						If SGF->GF_COMP == SG1->G1_COMP
							aadd(ARegsSGFdel,{SGF->GF_PRODUTO,SGF->GF_ROTEIRO, SGF->GF_OPERAC, SGF->GF_COMP, SGF->GF_TRT})
						EndIf
						SGF->(dbSkip())
					EndDo
				EndIf
			EndIf
			If aUndo[nY][2] == 3
				SG1->(DbGoTo(aUndo[ny][1]))

				SGF->(dbSeek(xFilial("SGF")+SG1->G1_COD))
				While SGF->(!Eof()) .And. SGF->(GF_FILIAL) == xFilial("SGF") .And. SGF->GF_PRODUTO == SG1->G1_COD
					If SGF->GF_COMP == SG1->G1_COMP
						For nInd := 1 To Len(aValAnt)
							If !empty(aValAnt[nInd][4]) .And. !empty(aValAnt[nInd][1])
								If aValAnt[nInd][4] == SGF->(RecNo()) .And. aValAnt[nInd][1] == SG1->(RecNo())
									RecLock('SGF',.F.)
									SGF->GF_TRT := SG1->G1_TRT
									MsUnlock()
								EndIf
							EndIf
						next
					EndIf
					SGF->(dbSkip())
				EndDo
			EndIf
		Next
	EndIf

	aValAnt   := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Revisao Estrutura caso atualize arquivo de revisoes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Len(aUndo) > 0
		For nY := 1 To Len(aUndo)
			If aUndo[nY][2] != 3
				lEdita := .F.
			EndIf
		Next
	EndIf

	If nOpcX > 2 .And. (MV_PAR02 == 1 .Or. lRevAut) .And. !lEdita
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ P.E. para Gerar ou nao uma nova revisao para a estrutura sem a apresentacao do Aviso. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("MT200GRE")
			lRetPE := ExecBlock("MT200GRE",.F.,.F.)
			lGravaRev := IIF(ValType(lRetPE)=="L",lRetPE,lGravaRev)
        Else
			TONE(3500,1)
			If Len (aUndo) > 0 .And. (MV_PAR02 == 1 .Or. lRevAut)
				If l200Auto .Or. lRevAut
					lGravaRev := .T.
				Else
					lGravaRev := (MsgYesNo(OemToAnsi(cLinha1+cLinha2+cLinha3),OemToAnsi(cTitulo)))
				EndIf
			EndIf
        EndIf

		If lGravaRev
			cRevisaoA := cRevisao
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o cadastro de revisoes da estrutura ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCodPai := cProduto

			If !lRevAut
				If Len (aUndo) > 0
			   		cRevisao := A200Revis(cProduto)
			 	EndIf
				If lAltRev .And. !l200Auto .And. (nOpcX == 4 .Or. nOpcX == 3)
					If Len( aUndo ) > 0
						A200AltRev( aUndo )
					Endif
				Endif
			Else
				nRecno := SG1->(Recno())
				For nY := 1 To Len(aUndo)
					SG1->(dbGoto(aUndo[nY][1]))
					If aUndo[nY][2] == 2
						If SG1->(dbSeek(xFilial("SG1")+SG1->G1_COD))
							If aScan(aPaiEstru, {|x| x[1]==SG1->G1_COD}) == 0
								aAdd(aPaiEstru,{SG1->G1_COD,.T.})
							EndIf
						EndIf
					EndIf
				Next nY
				SG1->(dbGoto(nRecno))

				IF nOpcx = 4 .And. lCadSOW
					A200RevEdi(aUndo,aPaiEstru,@aIncRevisa,@aAltNRev,lEdita)
				EndIf
				BEGIN TRANSACTION
					For nX := 1 to Len(aPaiEstru)
						If aPaiEstru[nx,2]
							IF nOpcx = 4 .And. lCadSOW .And. Len(aIncRevisa) > 0
								If (nY := aScan(aIncRevisa,{|x| x[2] == aPaiEstru[nx,1]})) > 0
									cRevisao := aIncRevisa[nY,3]
								Else
									cRevisao := A200Revis(aPaiEstru[nx,1],,lRevAut)
								EndIf
							Else
								cRevisao := A200Revis(aPaiEstru[nx,1],,lRevAut)
							EndIf
							SG1->(dbSetOrder(1))
							SG1->(dbSeek(xFilial("SG1")+aPaiEstru[nX,1]))
							While !SG1->(EOF()) .And. SG1->(G1_FILIAL+G1_COD) == xFilial("SG1")+aPaiEstru[nX,1]
								If (!((nY := aScan(aUndo,{|x| x[1] == SG1->(Recno())})) > 0 .And. aUndo[nY,2] == 3 .And. lCadSOW) .Or. aScan(aAltNRev,{|x| x[1] == SG1->(Recno())}) > 0) .And. aScan(aIncRevisa,{|x| x[1] == SG1->(Recno())}) == 0
									If !SG1->(A200RevDel(G1_COD,G1_COMP,G1_TRT,aUndo))
										If l200Auto .Or. Right(oTree:GetCargo(),4) == 'COMP' .Or. (Right(oTree:GetCargo(),4) == 'CODI' .And. oTree:Nivel() == 1)
											If (nY := aScan(aUndo,{|x| x[1] == SG1->(Recno())})) == 0 .Or. aUndo[nY,2] # 2
												RecLock('SG1',.F.)
												If Empty(SG1->G1_REVINI) .And. SG1->G1_REVFIM == 'ZZZ'
													Replace SG1->G1_REVINI With cRevisao
													Replace SG1->G1_REVFIM With cRevisao
												ElseIf (Val(cRevisao)-Val(SG1->G1_REVFIM)) < 2 .And. Val(SG1->G1_REVINI) <= Val(cRevisao)
													Replace SG1->G1_REVFIM With cRevisao
												ElseIf (Val(cRevisao)-Val(SG1->G1_REVFIM)) > 1 .And. ( Val(SG1->G1_REVINI) <= Val(cRevisao) .And. Val(SG1->G1_REVFIM) >= Val(cRevisao) )
													aAdd(aAtuCmp,SG1->(Recno()))
												EndIf
												SG1->(MsUnlock())
											ElseIf aUndo[nY,2] == 2 .And. Empty(SG1->G1_REVINI) .And. SG1->G1_REVFIM == 'ZZZ'
												RecLock('SG1',.F.)
												Replace SG1->G1_REVINI With '001'
												Replace SG1->G1_REVFIM With cRevisaoA
												SG1->(MsUnlock())
											EndIf
										Else
											If !Vazio(cCodSim) .And. !Vazio(cRevSim) .And. nOpcX == 3
												If (nY := aScan(aUndo,{|x| x[1] == SG1->(Recno())})) == 0 .Or. aUndo[nY,2] # 2
													RecLock('SG1',.F.)
													If Empty(SG1->G1_REVINI) .And. SG1->G1_REVFIM == 'ZZZ'
														Replace SG1->G1_REVINI With cRevisao
														Replace SG1->G1_REVFIM With cRevisao
													ElseIf (Val(cRevisao)-Val(SG1->G1_REVFIM)) < 2
														Replace SG1->G1_REVFIM With cRevisao
													EndIf
														SG1->(MsUnlock())
												EndIf
											EndIf
										EndIf
									ElseIf Empty(SG1->G1_REVINI) .And. SG1->G1_REVFIM == 'ZZZ'
										RecLock('SG1',.F.)
											SG1->(dbDelete())
										SG1->(MsUnlock())
									EndIf
								EndIf
								SG1->(dbSkip())
								If !l200Auto
									oTree:SetFocus()
								EndIf
							End
							For nR := 1 To Len(aAtuCmp)
								SG1->(dbGoTo(aAtuCmp[nR]))
								aCampos := {}
								For nS := 1 To FCount()
									aAdd(aCampos, FieldGet(nS))
								Next nS
								RecLock("SG1",.T.)
								For nS := 1 To Len(aCampos)
									If FieldPos("G1_REVINI") == nS
										FieldPut(nS,cRevisao)
									ElseIf FieldPos("G1_REVFIM") == nS
										FieldPut(nS,cRevisao)
									Else
										FieldPut(nS,aCampos[nS])
									EndIf
								Next nS
								SG1->(MsUnlock())
							Next nR
						EndIf
					Next nX
				END TRANSACTION
			EndIf

			If nOpcX == 5
				A200DelSG5(cCodPai)
			EndIf
		EndIf
	ElseIf nOpcX == 5 .And. (MV_PAR02 == 1 .Or. lRevAut)
		A200DelSG5(cProduto)
	ElseIf nOpcx = 4 .And. lRevAut .And. lCadSOW
		A200RevEdi(aUndo,aPaiEstru,,,lEdita)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mapa de Divergencias                                      ³
	//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//³ lIniMap = Habilita/Desabilita o Mapa de Divergencias      ³
	//³ lIniMap == .T. - Habilita                                 ³
	//³ lIniMap == .F. - Desabilita                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ P.E. MT200MAP - Validar a rotina do Mapa de Divergencias. ³
	//³ Parametros Enviados:                                      ³
	//³ PARAMIXB[1] = Cod.Produto                                 ³
	//³ PARAMIXB[2] = Unidade de Medida                           ³
	//³ PARAMIXB[3] = Quantidade Base                             ³
	//³ PARAMIXB[4] = Revisao                                     ³
	//³ PARAMIXB[5] = Opcao Selecionada                           ³
	//³ PARAMIXB[6] = Contador                                    ³
	//³ Retorno     = Logico                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	lTemMapa := .F.

	If (lIniMap := ExistBlock("MT200MAP"))
		lIniMap := ExecBlock("MT200MAP",.F.,.F.,{cProduto,cUm,nQtdBase,cRevisao,nOpcx,nCount})
		If ValType(lIniMap) <> "L"
			lIniMap := .T.
		Endif
		lIniMap := !lIniMap
	EndIf

	If !l200Auto .And. nOpcX < 5 .And. AllTrim(Upper(cUm)) $ Upper(cConsidUM) .And. !lIniMap

		a200IniMap(nQtdBase, oTree)

		aExplode := {}
		Explode(cProduto, @aExplode, cRevisao, @nCount, oTree)

		aPai := {}
		For nX := 1 to Len(aExplode)
			If (nPos := aScan(aPai, {|x| x[2] == aExplode[nX, 2]})) == 0
				aAdd(aPai, {1, aExplode[nX, 2]})
			ElseIf nPos > 0
				aPai[nPos, 1]++
			EndIf
		Next nX

		cCodPai   := cProduto
		nQtdNivel := CriaVar('B1_QB')
		For nX:=1 to Len(aPai)
			nQuant1 := CriaVar('B1_QB')
			If aPai[nX, 2] # cCodPai
				nPos   := aScan(aExplode,{|x| x[3] == aPai[nX, 2]})
				nQuant := If(nPos>0,aExplode[nPos, 4],0)
				For nY := 1 to Len(aExplode)
					If aExplode[nY, 2] == aPai[nX, 2]
						nQuant1 += aExplode[nY, 4]
					EndIf
				Next nY
				If nQuant1 # nQuant
					lMap := .T.
				EndIf
			Else
				For nY := 1 to Len(aExplode)
					If aExplode[nY, 2] == cCodPai
						nQuant1 += aExplode[nY, 4]
					EndIf
				Next nY
				If nQuant1 # nQtdBase
					lMap := .T.
					nQtdNivel += nQuant1
					Exit
				Else
					nQtdNivel += nQuant1
				EndIf
			EndIf
		Next nX

		If lMap .and. lTemMapa
			lContinua := A200ShowMap(nQtdNivel)
			If ExistBlock("MT200DIV")
				lRetPE := ExecBlock("MT200DIV",.F.,.F.,{cProduto,@oTree})
				If ValType(lRetPE) == "L"
					lContinua := lRetPE
				EndIf
			EndIf
		EndIf
	EndIf

	If lContinua
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seta o parametro MV_NIVALT                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lMudou .And. (nOpcX > 2 .And. nOpcX <= 5)
			If lMudou .And. nOpcx == 4
				If a630SeekSG2(3,cProduto,xFilial("SG2")+cProduto) .And. !l200Auto
					Help(" ",1,"A200ALTROT")
				EndIf
			EndIf
			a200NivAlt()
		EndIf

		// Quando existir revisão, não deverá eliminar registros de operações x componentes
 		lRet := A637VLDDel(ARegsSGFdel)

 		//Grava novos registros de operações x componentes
		For nX := 1 to Len(aRegsSGF)
			lRet := A637VldGrava(aRegsSGF[nX, 1], aRegsSGF[nX, 2], aRegsSGF[nX, 3], aRegsSGF[nX, 4], aRegsSGF[nX, 5], .T., .F.)
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa Ponto de Entrada na Grava‡„o da Estrutura         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock('A200GrvE')
			Execblock('A200GrvE',.F.,.F.,{nOpcx,lMap,aRecDel,aUndo})
		EndIf
	EndIf
EndIf

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta o 5o Indice de Trabalho do arquivo dbTree                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cInd5) .And. File(cInd5+OrdBagExt()) .And. ValType(oTree)=='O'
		cArqTrab := oTree:cArqTree
		dbSelectArea(cArqTrab)
		dbClearIndex()
		fErase(cInd5+OrdBagExt())
		cInd5 := ''
		dbSetIndex(SubStr(cArqTrab,2)+'A'+OrdBagExt())
		dbSetIndex(SubStr(cArqTrab,2)+'B'+OrdBagExt())
		dbSetIndex(SubStr(cArqTrab,2)+'C'+OrdBagExt())
		dbSetIndex(SubStr(cArqTrab,2)+'D'+OrdBagExt())
		dbSetOrder(1)
	EndIf

	If oDlg # Nil .And. oTree # Nil
		Release Object oTree
		oDlg:End()
	Endif
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta tecla de atalho                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Ma200StKey(aKey,aBkey)

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} A200RevEdi()
Executa revisão automática na alteração da estrutura.
@author Renan Roeder
@since 26/03/2018
/*/
//------------------------------------------------------------------
Static Function A200RevEdi(aUndo,aPaiEstru,aIncRevisa,aAltNRev,lEdita)
Local nX        := 0
Local nY        := 0
Local nZ        := 0
Local lRevAut   := SuperGetMv("MV_REVAUT",.F.,.F.)
Local aAreaSG1  := SG1->(GetArea())
local cRev		:= ''
Private aIncRev   := {}
Private aAltera   := aUndo
Private lAtualiza := .T.
Private cRevisao  := CriaVar("G1_REVINI")

Default aIncRevisa := {}
Default aAltNRev   := {}

BEGIN TRANSACTION
	For nX := 1 to Len(aPaiEstru)
		If aPaiEstru[nX,2]

			lAtualiza := .T.

			SG1->(dbSetOrder(1))
			SG1->(dbSeek(xFilial("SG1")+aPaiEstru[nX,1]))
			While !SG1->(EOF()) .And. SG1->(G1_FILIAL+G1_COD) == xFilial("SG1")+aPaiEstru[nX,1]
				If l200Auto .Or. Right(oTree:GetCargo(),4) == 'COMP' .Or. (Right(oTree:GetCargo(),4) == 'CODI' .And. oTree:Nivel() == 1)
					/** PRIMEIRO ENCONTRAR O QUE FOI ALTERADO, VERIFICAR SE GERA NOVA REVISÃO, E CRIAR NOVO REGISTRO COM NOVA REVISÃO E AS ALTERAÇÕES **/
					If (nY := aScan(aUndo,{|x| x[1] == SG1->(Recno())})) > 0 .And. aUndo[nY,2] == 3
						A200IncSG1(aPaiEstru[nX,1],aUndo[nY],@aIncRevisa,@aAltNRev)
					EndIf
				EndIf
				SG1->(dbSkip())
				If !l200Auto
					oTree:SetFocus()
				EndIf
			End
		EndIf
	Next nX

	/*/ Tratamento necessário devido a rotina automatica, existem itens que estao no array da rotina automatica mas nao sofrerão
	atualizações, mas é necessário alterar a revisao desses itens.
	/*/
	If len(aAltNRev) > 0 .AND. (l200Auto .Or. lEdita)
		For nZ := 1 to len(aAltNRev)
			SG1->(dbGoTo(aAltNRev[nz][1]) )

			dbSelectArea("SB1")
			aASB1:=GetArea()
			dbSetOrder(1)
			If dbSeek(xFilial("SB1")+aAltNRev[nz][2])
				cRev :=	 IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)
			EndIf
			RestArea(aASB1)

			RecLock('SG1',.F.)
			Replace SG1->G1_REVFIM With cRev
			SG1->(MsUnlock())
		Next nZ
	EndIf

END TRANSACTION


SG1->(RestArea(aAreaSG1))
Return nil

//------------------------------------------------------------------
/*/{Protheus.doc} A200IncSG1()
Incluir registro com nova revisão na tabela SG1
@author Renan Roeder
@since 26/03/2018
/*/
//------------------------------------------------------------------
Static Function A200IncSG1(cProdPai,aStrutAnt,aIncRevisa,aAltNRev)
Local aAreaSG1  := SG1->(GetArea())
Local aCampos   := {}
Local i         := 0
Local aRevisoes := {}
Local aInclui   := {}
Local aAreaTRE  := {}
Default l200Auto := .F.

dbSelectArea("SG1")

For i := 1 To FCount()
	aAdd(aCampos, FieldGet(i))
Next i

A200VerAlt(aCampos,aStrutAnt[3],@aRevisoes)

If Len(aRevisoes) > 0 .Or. l200Auto
	If (Len(aRevisoes) > 0 .And. A200VerSOW(aRevisoes))

		If lAtualiza
			cRevisao := A200Revis(cProdPai,,.T.)
		EndIf

		A200AltOri(aRevisoes)

		RecLock("SG1",.T.)

		For i := 1 To Len(aCampos)
			If FieldPos("G1_REVINI") == i
				FieldPut(i,cRevisao)
			ElseIf FieldPos("G1_REVFIM") == i
				FieldPut(i,cRevisao)
			Else
				FieldPut(i,aCampos[i])
			EndIf
		Next i

		SG1->(MsUnlock())

		If !(l200Auto)
			dbSelectArea(oTree:cArqTree)
			aAreaTRE := GetArea()
			(oTree:cArqTree)->(dbSetOrder(1))
			(oTree:cArqTree)->(dbGoTop())

			Do While (oTree:cArqTree)->(!Eof())
				If (SubStr(T_CARGO, 0, Len(SG1->G1_COD) + Len(SG1->G1_TRT) + Len(SG1->G1_COD)) == (SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) .And. !(Right(T_CARGO,4)$'CODI|NOVO'))
					RecLock((oTree:cArqTree), .F.)
					Replace T_CARGO With (SG1->G1_COD+SG1->G1_TRT+SG1->G1_COMP+StrZero(SG1->(Recno()),9)+StrZero(nIndex ++, 9)+'COMP')
					(oTree:cArqTree)->(MsUnlock())
					Exit
				Else
					(oTree:cArqTree)->(dbSkip())
				EndIf			
			EndDo	

			(oTree:cArqTree)->(RestArea(aAreaTRE))
		EndIf	

		For i := 1 To FCount()
			aAdd(aInclui, FieldGet(i))
		Next i

		aAdd(aIncRev,{SG1->(Recno()),aInclui})

		aAdd(aIncRevisa,{SG1->(Recno()),SG1->G1_COD,cRevisao})

		If lAtualiza
			A200AtuRev(cRevisao,cProdPai)
		EndIf
	Else
		aAdd(aAltNRev,{SG1->(Recno()),SG1->G1_COD})

	EndIf
EndIf

SG1->(RestArea(aAreaSG1))

Return nil

//------------------------------------------------------------------
/*/{Protheus.doc} A200VerAlt()
Verificar campos que foram alterados na estrutura.
@author Renan Roeder
@since 26/03/2018
/*/
//------------------------------------------------------------------
Static Function A200VerAlt(aStrut,aStrutAnt,aRevisoes)
Local aCampos  := {}
Local i        := 0

aRevisoes := {}

For i := 1 To Len(aStrut)
	If aStrut[i] != aStrutAnt[i]
		aAdd(aRevisoes,{FieldName(i),aStrutAnt[i],aStrut[i]})
	EndIf
Next i

Return nil

//------------------------------------------------------------------
/*/{Protheus.doc} A200VerSOW()
Validar campos alterados com o cadastro da tabela SOW
@author Renan Roeder
@since 26/03/2018
/*/
//------------------------------------------------------------------
Static Function A200VerSOW(aRevisoes)
Local i    := 0
Local lRev := .F.

If AliasInDic("SOW")
	SOW->(dbSelectArea("SOW"))
	SOW->(dbSetOrder(1))
	For i := 1 To Len(aRevisoes)
		If SOW->(dbSeek(xFilial("SOW")+aRevisoes[i][1]))
			If SOW->OW_REVISA = "2"
				lRev := .T.
				Exit
			EndIf
		EndIf

	Next i
EndIf

Return lRev

//------------------------------------------------------------------
/*/{Protheus.doc} A200AltOri()
Voltar as alterações realizadas na tabela SG1, para que a alteração
seja feito apenas no novo registro criado a partir da nova revisão.
@author Renan Roeder
@since 26/03/2018
/*/
//------------------------------------------------------------------
Static Function A200AltOri(aRevisoes)
Local aAreaSG1  := SG1->(GetArea())
Local i         := 0

dbSelectArea("SG1")

RecLock("SG1",.F.)

For i := 1 To Len(aRevisoes)
	&('SG1->'+aRevisoes[i][1]) := aRevisoes[i][2]
Next i
SG1->(MsUnlock())

SG1->(RestArea(aAreaSG1))

Return Nil

//------------------------------------------------------------------
/*/{Protheus.doc} A200AtuRev()
Incrementa a revisão dos componentes da estrutura que não
foram alterados.
@author Renan Roeder
@since 26/03/2018
/*/
//------------------------------------------------------------------
Static Function A200AtuRev(cRevisao,cProdPai)
Local aAreaSG1 := SG1->(GetArea())
Local i        := 0

SG1->(dbSetOrder(1))
SG1->(dbSeek(xFilial("SG1")+cProdPai))
While !SG1->(EOF()) .And. SG1->(G1_FILIAL+G1_COD) == xFilial("SG1")+cProdPai
	If l200Auto .Or. Right(oTree:GetCargo(),4) == 'COMP' .Or. (Right(oTree:GetCargo(),4) == 'CODI' .And. oTree:Nivel() == 1)
		/** **/
		If aScan(aAltera,{|x| x[1] == SG1->(Recno())}) == 0 .And. aScan(aIncRev,{|x| x[1] == SG1->(Recno())}) == 0
			RecLock('SG1',.F.)
			If (Val(cRevisao)-Val(SG1->G1_REVFIM)) < 2
				Replace SG1->G1_REVFIM With cRevisao
			EndIf
			SG1->(MsUnlock())
		EndIf
	EndIf
	SG1->(dbSkip())
End

lAtualiza := .F.

SG1->(RestArea(aAreaSG1))

Return Nil
//------------------------------------------------------------------
/*/{Protheus.doc} A200DelSG5()
Deleta registros da SG5
@author Michele Girardi
@since 26/04/2016
/*/
//------------------------------------------------------------------
Function A200DelSG5(cProduto)

dbSelectArea("SG5")
dbSetOrder(1)
If dbSeek(xFilial("SG5")+SubStr(cProduto,1,Len(G5_PRODUTO)))
	Do While !Eof() .And. G5_FILIAL+G5_PRODUTO == xFilial("SG5")+SubStr(cProduto,1,Len(G5_PRODUTO))
		RecLock('SG5',.F.)
			SG5->(dbDelete())
		SG5->(MsUnlock())
		dbSkip()
	EndDo
EndIf

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MA200Del   ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Deleta a Estrutura Atual                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ma200Del(ExpC1, ExpN1, ExpA1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Produto                                  ³±±
±±³          ³ ExpA1 = tecla de atalho                                    ³±±
±±³          ³ ExpA2 = Array con. blo. de cod. que sera exe. pela tecla de³±±
±±³          ³ atalho e tecla de atalho,Exeplo: aBkey -> aBkey[bKey][aKey]³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso ocorra algum problema na Dele‡„o, True C.C.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ma200Del(cProduto, aKey, aBkey)

Local aAreaAnt   := GetArea()
Local cSeek      := xFilial('SG1')+cProduto
Local aDelet     := {}
Local nX         := 0
Local nI         := 0
Local lRet       := .T.
Local oModel637
Local lIntgPPI   := PCPIntgPPI()
Local lContinua  := .T.
Local lExec      := .T.
Local aNewRecs   := {}
Local aRecProc   := {}
Local cCodPai    := ""
Local lRevAut    := SuperGetMv("MV_REVAUT",.F.,.F.)
Default aKey     := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Execblock MTA200 verif. permissão de exclusão na browse alem do detalhe da estrutura
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock('MTA200')
	if  ExecBlock('MTA200',.F.,.F.) = .F.
   	  return .F.
	EndIf
Endif

If ( Type("aRecDel") == "U" )
	PRIVATE aRecDel := {}
EndIf

//--Desativa tecla de atalho
For nX := 1 to len(aKey)
	Set Key aKey[nX] to
Next nX

dbSelectArea('SG1')
dbSetOrder(1)
If !(lRet:=dbSeek(cSeek, .F.))
	Help(' ', 1, 'REGNOIS')
Else
	Do While !Eof() .And. G1_FILIAL+G1_COD == cSeek
		aAdd(aDelet, Recno())
		dbSkip()
	EndDo
	aRecDel:= aClone(aDelet)
	BEGIN TRANSACTION
		aNewRecs := {}
		For nX := 1 to Len(aDelet)
			dbGoto(aDelet[nX])
			If lIntgPPI
				//Verifica se esta estrutura já foi processada.
				cCodPai := SG1->G1_COD
				SG1->(dbSeek(xFilial("SG1")+cCodPai))
				While SG1->(!Eof()) .And. xFilial("SG1")+cCodPai == SG1->(G1_FILIAL+G1_COD)
					aAdd(aNewRecs,SG1->(Recno()))
					SG1->(dbSkip())
				End
				SG1->(dbGoto(aDelet[nX]))
				lExec := .T.
				For nI := 1 To Len(aRecProc)
					If aScan(aNewRecs,{|x| x == aRecProc[nI]}) > 0
						lExec := .F.
						Exit
					EndIf
				Next nI
				If lExec
					aAdd(aRecProc, aDelet[nX])
					lContinua := MATA200PPI(, SG1->G1_COD, .T., .T., .F.)
				EndIf

				If !lContinua
					DisarmTransaction()
					Exit
				EndIf
			EndIf
			RecLock('SG1', .F., .T.)
				SG1->(dbDelete())
			MsUnlock()
		Next nX
		If lContinua
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza arquivo de Operacoes x Componentes caso haja exclusao da estrura	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX := 1 to Len(aDelet)
				SG1->(DbGoTo(aDelet[nX]))

				SGF->(dbSetOrder(1))
				if SGF->(dbSeek(xFilial('SGF')+SG1->G1_COD))
					oModel637 := FwLoadModel('MATA637')

					While SGF->(!EOF()) .And. SGF->(GF_FILIAL) == xFilial("SGF") .And. SGF->GF_PRODUTO == SG1->G1_COD
						oModel637:SetOperation(5)
						oModel637:Activate()

						if oModel637:VldData()
							oModel637:CommitData()
						Else
							lRet := .F.
							MSGINFO(STR0079 + oModel637:GetErrorMessage()[6]) // 'Não foi possível eliminar relação componentes x operações: '
						Endif

						oModel637:DeActivate()

						SGF->(dbSkip())
					End
				Endif
			Next
			If lRevAut
				A200UpdSB1(SG1->G1_COD)
			EndIf
		EndIf
	END TRANSACTION
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta tecla de Atalho                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Ma200StKey(aKey,aBkey)

RestArea(aAreaAnt)

Return lRet

/*/{Protheus.doc} A200UpdSB1
Integra dados com a API
@author Marcos Wagner Jr
@since 23/12/2020
@version P12
@param cProduto, Caracter, Codigo do produto
@return Nil
/*/
Static Function A200UpdSB1(cProduto)
Local aAreaSB1 := SB1->(GetArea())

dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial("SB1")+cProduto)
	Reclock("SB1", .f.)
	SB1->B1_REVATU = " "
	SB1->(MsUnlock())
EndIf

RestArea(aAreaSB1)

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MA200Undo  ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Desfaz as Inclus”es/Exclus”es/Alteracoes                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ma200Undo(ExpA1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os recnos                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso ocorra algum problema, True em caso contrario   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Ma200Undo(aUndo, nOpcX)

Local lRet       := .T.
Local nX         := 0
Local nY         := 0
Local aAreaAnt   := GetArea()
Local aUndoBkp   := aUndo

BEGIN TRANSACTION

	dbSelectArea('SG1')

	// Precisa desfazer primeiro a inclusão para depois a exclusão para não ocorrer erro de chave duplicada
	For nX := 1 to Len(aUndo)
		If aUndo[nX,1] > 0 .And. aUndo[nX,1] <= LastRec() .And. (aUndo[nX,2] == 1 .Or. aUndo[nX,2] == 3)
			dbGoto(aUndo[nX,1])
			If (lRet:=RecLock('SG1', .F.))
				If aUndo[nX, 2] == 1 //-- O Registro foi Incluido
					//-- Deleta o Registro
					If !Deleted()
						SG1->(dbDelete())
					EndIf
				ElseIf aUndo[nX, 2] == 2 //-- O Registro foi Excluido
					//-- Restaura O REGISTRO
					If Deleted()
						dbRecall()
					ElseIf nOpcX == 3
						SG1->(dbDelete())
					EndIf
				ElseIf aUndo[nX, 2] == 3 //-- O Registro foi Alterado
					//-- Restaura OS DADOS do Registro
					For nY := 1 to Len(aUndo[nX, 3])
						FieldPut(nY, aUndo[nX, 3, nY])
					Next nY
				EndIf
				MsUnlock()
			Else
				Exit
			EndIf

		EndIf
	Next nX

	For nX := 1 to Len(aUndo)

		If aUndo[nX,1] > 0 .And. aUndo[nX,1] <= LastRec() .And. aUndo[nX,2] == 2
			dbGoto(aUndo[nX,1])
			If (lRet:=RecLock('SG1', .F.))
				If aUndo[nX, 2] == 1 //-- O Registro foi Incluido
					//-- Deleta o Registro
					If !Deleted()
						SG1->(dbDelete())
					EndIf
				ElseIf aUndo[nX, 2] == 2 //-- O Registro foi Excluido
					//-- Restaura O REGISTRO
					If Deleted()
						If aScan(aUndoBkp,{|x| x[1] == aUndo[nX, 1] .And. x[2] == 1 }) == 0
							dbRecall()
						EndIf
					ElseIf nOpcX == 3
						SG1->(dbDelete())
					EndIf
				ElseIf aUndo[nX, 2] == 3 //-- O Registro foi Alterado
					//-- Restaura OS DADOS do Registro
					For nY := 1 to Len(aUndo[nX, 3])
						FieldPut(nY, aUndo[nX, 3, nY])
					Next nY
				EndIf
				MsUnlock()
			Else
				Exit
			EndIf
		EndIf
	Next nX

	If ExistBlock("A200UNDO")
		//--- Parametros passados para PARAMIXB:
		//--- PARAMIXB[nX,1] = Nro. do Registro
		//--- PARAMIXB[nX,2] = Tipo - 1. Inclusao/2. Exclusao/3. Alteracao
		//--- PARAMIXB[nX,3,nY] = Campos Alterados do componente
		ExecBlock("A200UNDO",.F.,.F.,aUndo)
	EndIf

END TRANSACTION

RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A200Descen ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche a Variavel cValComp com a Descendencia do Produto ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200Descen(ExpC1,ExpA1,ExpO1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Variavel Caracter com a Descendˆncia do Produto    ³±±
±±³          ³ ExpA1 = Array com a descendˆncia dos Produtos Incluidos 	  ³±±
±±³          ³ ExpO1 = Objeto Tree                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso ocorra algum problema na Montagem, True C.C.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A200Descen(cValComp, aDescend, oTree)

Local aAreaAnt   := GetArea()
Local aAreaTRE   := {}
Local cPai       := ''
Local cCod       := ''
Local lRet       := .T.
Local nX		 := 0

cValComp := ''
aDescend := {}

dbSelectArea(oTree:cArqTree)
aAreaTRE := GetArea()
cPai     := T_IDTREE
cCod     := If(Right(T_CARGO, 4)=='COMP',SubStr(T_CARGO, Len(SG1->G1_COD) + Len(SG1->G1_TRT) + 1, Len(SG1->G1_COD) ),Left(T_CARGO, Len(SG1->G1_COD)))
aAdd(aDescend, cCod)

Do While .T.
	dbSetOrder(3) //-- Ordem de T_IDCODE (Filho)
	If Val(cPai) # 0 .And. dbSeek(cPai, .F.)
		cCod   := If(Right(T_CARGO, 4)=='COMP',SubStr(T_CARGO, Len(SG1->G1_COD) + Len(SG1->G1_TRT) + 1, Len(SG1->G1_COD) ),Left(T_CARGO, Len(SG1->G1_COD)))
		aAdd(aDescend, cCod)
		cPai := T_IDTREE
		Loop
	Else
		Exit
	EndIf
EndDo

If Len(aDescend) > 0
	For nX := Len(aDescend) to 1 Step -1
		cValComp += aDescend[nX] + 'ú'
	Next nX
EndIf

//-- Restaura a Area de Trabalho
dbSetOrder(aAreaTRE[2])
dbGoto(aAreaTRE[3])
RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A200TudoOk ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡„o Final da Inclus„o/Altera‡„o                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200TudoOk(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Variavel Caracter com o a Origem da Chamada (I/A/E)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso ocorra algum problema na Valida‡„o, True C.C.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A200TudoOk(cOpc)

Local aAreaAnt   := GetArea()
Local aAreaTRE   := {}
Local aAreaSG1   := {}
Local cSeek      := ''
Local lRet       := .T.
Local lRetPE     := .T.
Local nRecno     := 0
Local nTamCod    := TamSX3("G1_COD")[1]
Local lRevAut    := SuperGetMv("MV_REVAUT",.F.,.F.)
Local cSomaTRT	 := ''
Local cCodPaiOk	 := cCodPai
Local cRev       := ""
Local cRevisao1  := ""
Local aArea := {}
Local lReInclu	:= .F.
local nPosExc := 0

cOpc := If(cOpc==Nil,Space(1),cOpc) //-- "I" = Inclus„o / "A" = Altera‡„o / "E" = Exclus„o

If !(cOpc=='E')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida grupo de opcionais e item de opcionais   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If AliasInDic("SVC") .And. (!Empty(M->G1_GROPC) .Or. !Empty(M->G1_OPC))
		dbSelectArea("SVC")
		dbSetOrder(1)
		If SVC->(DbSeek(xFilial("SVC")))
			Help( ,  , "Help", ,  STR0105,;  //"Não é permitido utilizar a versão da produção em conjunto com o conceito de Componentes Opcionais."
	 		1, 0, , , , , , {STR0106})  //"Para a utilização dos opcionais, não pode haver versão de produção cadastrada."
			lRet := .F.
		EndIf
	Endif

	If lRet .And. ((!Empty(M->G1_GROPC).And.Empty(M->G1_OPC)) .Or. (!Empty(M->G1_OPC).And.Empty(M->G1_GROPC)))
		Help(' ',1,'A200OPCOBR')
		lRet := .F.
	EndIf

	If !(l200Auto)
		If cCodPai == M->G1_COMP
			cCodPaiOk := Left(oTree:GetCargo(), nTamCod)
		EndIf
	EndIf

	If !(l200Auto)
		dbSelectArea(oTree:cArqTree)
		aAreaTRE := GetArea()
		dbSetOrder(4)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida a Existencia de Similaridade na Estrutura Atual (DBTree)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			//dbSelectArea(oTree:cArqTree)
			//aAreaTRE := GetArea()
			//dbSetOrder(4)
			nRecno := Recno()
			/* If cCodPai == M->G1_COMP
				cCodPaiOk := Left(oTree:GetCargo(), nTamCod)
			EndIf */
			If cCodPaiOk <> Left(T_CARGO, nTamCod)
				// Qdo. o componente torna-se pai pela 1a.vez nao existe ainda T_CARGO com sua chave
				dbSeek(cSeek := cCodPaiOk + M->G1_TRT + M->G1_COMP, .T.)
			Else
				dbSeek(cSeek := Left(T_CARGO, nTamCod) + M->G1_TRT + M->G1_COMP, .T.)
			EndIf
			If ! Eof()
				Do While !Eof() .And. cSeek == Left(T_CARGO, Len(cSeek))
					If !(nRecno==Recno()) .And. !(Right(T_CARGO,4)$'CODIúNOVO') .And. ;
					   ( M->G1_TRT == SubsTr(T_CARGO, nTamCod+1, 3) .And.!Empty(M->G1_TRT) )
						Help(' ',1,'MESMASEQ')
						lRet := .F.
						Exit
					EndIf
					dbSkip()
				EndDo
			EndIf
			dbSetOrder(aAreaTRE[2])
			dbGoto(aAreaTRE[3])
		EndIf
	EndIf

	// Valida a Existencia de Similaridade na Estrutura Gravada (SG1)
	If lRet .And. ( cOpc=='I' .Or. (cOpc=='A' .And. M->G1_TRT <> SubsTr(T_CARGO, nTamCod+1, 3)) )
		dbSelectArea('SG1')
		aAreaSG1 := GetArea()
		dbSetOrder(1)
		If dbSeek(xFilial("SG1")+cCodPaiOk+M->G1_COMP+M->G1_TRT, .F.)

			//Busca revisão do Pai Direto
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial('SB1') + SG1->G1_COD, .F.))
				cRev := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU) //SB1->B1_REVATU
			EndIf

			While SG1->(!Eof()) .And. SG1->(G1_FILIAL+G1_COD+G1_COMP+G1_TRT) == xFilial("SG1")+cCodPaiOk+M->G1_COMP+M->G1_TRT
				If SG1->G1_REVINI > cRev .Or. SG1->G1_REVFIM < cRev
					SG1->(dbSkip())
					Loop
				EndIf

				If !lRevAut .Or. l200Auto .Or. (oTree:TreeSeek(cCodPai+M->G1_TRT+M->G1_COMP) .And. !(Right(oTree:GetCargo(),4)$'CODIúNOVO'))
					Help(' ',1,'MESMASEQ')
					lRet := .F.
				EndIf

				//valida se o mesmo registro foi eliminado e recriado igual. Se sim, não ajusta trt.
				IF LEN(AUNDO2) > 0
					nPosExc := aScan(aUndo2, {|x| x[1] == SG1->(Recno()) .And. x[2] == 2 })
					IF nPosExc > 0
						lReInclu := .T.
						BEGIN TRANSACTION
							RecLock('SG1')
								SG1->(DbDelete())
							MsUnlock()
						END TRANSACTION
					ENDIF
				ENDIF

				IF lRet .And. lRevAut .And. !lReInclu
					Do While !Eof() .And. SG1->G1_FILIAL+SG1->G1_COD+SG1->G1_COMP == xFilial("SG1")+cCodPai+M->G1_COMP
						cSomaTRT := SG1->G1_TRT
						SG1->(dbSkip())
					EndDo
					M->G1_TRT := Val(cSomaTRT) + 1
					M->G1_TRT := StrZero(M->G1_TRT,3)
				EndIF

				SG1->(dbSkip())
			End
		EndIf
		RestArea(aAreaSG1)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida revisao na alteracao da estrutura		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. cOpc == 'A'

		If !Empty(cProdPA0)
			If cProdPA0 == SG1->G1_COD
				cRevisao1 := cRevisao
			Else
				//Busca revisão do Pai Direto
				SB1->(dbSetOrder(1))
				If SB1->(dbSeek(xFilial('SB1') + SG1->G1_COD, .F.))
					cRevisao1 := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU) //SB1->B1_REVATU
				EndIf
			EndIf
		Else
			cRevisao1 := cRevisao
		EndIf

		If Empty(cRevisao1)
			cRevisao1 := cRevisao
		EndIf


		/*
		aArea := GetArea()
		dbSelectArea("SG5")
		dbSetOrder(1)
		If dbSeek(xFilial("SG5")+SubStr(SG1->G1_COD,1,Len(G5_PRODUTO)))
			Do While !Eof() .And. G5_FILIAL+G5_PRODUTO == xFilial("SG5")+SubStr(SG1->G1_COD,1,Len(G5_PRODUTO))
				cRevisao1 := G5_REVISAO
				dbSkip()
			EndDo
		EndIf
		RestArea(aArea)


		cRevisao2 := MIN(cRevisao1,cRevisao)
		*/

		If M->G1_REVINI > cRevisao1 .Or. M->G1_REVFIM < cRevisao1
			Aviso(OemToAnsi(STR0054),STR0056,{"Ok"})
			lRet := .F.
		EndIf

		/*
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial('SB1') + SG1->G1_COMP, .F.))
			If !SB1->B1_REVATU == CriaVar('B1_REVATU')
				cRevisao := SB1->B1_REVATU
			EndIf
		EndIf
		*/

	EndIf

	If lRet .And. !lRevAut
		If !a200ExiEst(cCodPai)
			lRet := .F.
		EndIf
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Execblock MTA200 ap¢s Conf.da InclusÆo/Altera‡„o/Dele‡„o          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If ExistBlock('MTA200')
		lRet := If(ValType(lRetPE:=ExecBlock('MTA200',.F.,.F.,cOpc))=='L',lRetPE,.T.)
	EndIf
EndIf

If cOpc == 'E' .And. Type('lDelFunc') == 'L'
	lDelFunc := lRet
EndIf

RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ma200GrSim ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava‡„o das Estruturas Similares                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ma200GrSim(ExpC1,ExpC2,ExpA1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Variavel Caracter com o Codigo do Produto          ³±±
±±³          ³ ExpC2 = cod.produto similar                                ³±±
±±³          ³ ExpA1 = Array com os Recnos dos Componentes Incl/Excl      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso ocorra algum problema na Valida‡„o, True C.C.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ma200GrSim(cProduto, cCodSim, aUndo)

Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local aAreaTRE   := {}
Local aRecnos    := {}
Local nX         := 0
Local i          := 0
Local cRevisao   := ""
Local aCampos    := {}
Local lRevaut	 := Getnewpar("MV_REVAUT",.F.)
Local nUltRev 	 := 0
Local aAreaSB1   := SB1->(GetArea())

If !Empty(cCodSim)
	If !Empty(cRevSim)
		dbSelectArea('SG1')
		dbSetOrder(1)
		dbgotop()
		If dbSeek(xFilial('SG1') + cCodSim, .F.)
			Do While !Eof() .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cCodSim
				//Não adiciona componentes fora da revisão
				If (cRevSim # Nil) .And. ;
					!(SG1->G1_REVINI <= cRevSim .And. (SG1->G1_REVFIM >= cRevSim .Or. SG1->G1_REVFIM = ' '))
					SG1->(dbSkip())
					Loop
				EndIf

				dbSelectArea("SB1")
				dbSetOrder(1)
				If DbSeek(xFilial("SB1")+cCodSim)

				   cRevSB := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)

					If !Empty(cRevSB) .And. cRevSB != SG1->G1_REVFIM
						nUltRev := ExplEstr(1,SG1->G1_INI,SB1->B1_OPC,cRevSB)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Se nUltRev == 0, indica que o componente nao faz parte da revisao       ³
						//³ atual da estrutura,logo, nao deve ser carregado.                        ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						//If nUltRev <> 0
							aAdd(aRecnos, SG1->(Recno()))
						//EndIf
					Else
						aAdd(aRecnos, SG1->(Recno()))
					EndiF
				EndIf
				SG1->(dbSkip())
			EndDo
		EndIf
	EndIf

	dbSelectarea('SG1')
	If Len(aRecnos) > 0
		For nX := 1 to Len(aRecnos)
			dbGoto(aRecnos[nX])
			//-- Grava o Campo Atual
			aCampos := {}
			For i := 1 To FCount()
				aAdd(aCampos, FieldGet(i))
			Next i

			//-- Cria o Novo Registro
			BEGIN TRANSACTION
				RecLock('SG1', .T.)
				For i:=1 To FCount()
					If FieldPos("G1_REVINI") == i
				 	   FieldPut(i,Space((TamSX3("G1_REVINI")[1])))
					ElseIf FieldPos("G1_REVFIM") == i
					   FieldPut(i,Replicate('Z',((TamSX3("G1_REVFIM")[1]))))
					Else
				   		FieldPut(i,aCampos[i])
				 	Endif
				Next 1
				Replace G1_COD With cProduto
				MsUnlock()
				If aScan(aUndo, {|x| x[1]==Recno()}) == 0
					aAdd(aUndo, {Recno(), 1}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
				EndIf
			END TRANSACTION

		Next nX
	EndIf
EndIf
//-- Restaura a Area de Trabalho
RestArea(aAreaSB1)
RestArea(aAreaAnt)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A200Revis ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 05/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza cadastro de revisao de componentes                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpC1 := A200ReVis(ExpC2)			                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC2 = codigo do componente		                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpC1 = revisao 		 	        			       		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A200Revis(cProduto,lShow,lRevAut)

Local cRevisao   := CriaVar("G1_REVINI")
Local aArea      := {}
Local aAreaSG5   := {}
Local aAreaSB1   := {}
Local aRevisoes  := {}

Default lShow	 := .T.
Default lRevAut  := .F.

aArea := GetArea()
dbSelectArea("SG5")
aAreaSG5 := GetArea()
dbSetOrder(1)
If dbSeek(xFilial("SG5")+SubStr(cProduto,1,Len(G5_PRODUTO)))
	Do While !Eof() .And. G5_FILIAL+G5_PRODUTO == xFilial("SG5")+SubStr(cProduto,1,Len(G5_PRODUTO))
		AADD(aRevisoes,{.F.,G5_REVISAO,DTOC(G5_DATAREV)})
		cRevisao:=G5_REVISAO
		dbSkip()
	EndDo
EndIf

dbSelectArea("SB1")
aAreaSB1:=GetArea()
dbSetOrder(1)
If dbSeek(xFilial("SB1")+cProduto)
	cRevSB := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)
	if(cRevSB > cRevisao)
	   cRevisao :=	 cRevSB //SB1->B1_REVATU
	endif
EndIf
RestArea(aAreaSB1)

cRevisao:=Soma1(cRevisao)
AADD(aRevisoes,{.T.,cRevisao,DTOC(dDataBase)})

If lShow .And. !lRevAut
	cRevisao:=A200SelRev(aRevisoes)
Endif

If !Empty(cRevisao)
	dbSelectArea("SG5")
	dbSetOrder(1)

	If dbSeek(xFilial("SG5")+SubStr(cProduto,1,Len(G5_PRODUTO))+cRevisao)
		RecLock("SG5",.F.)
	Else
		RecLock("SG5",.T.)
		G5_FILIAL  := xFilial("SG5")
		G5_PRODUTO := cProduto
		G5_REVISAO := cRevisao
	Endif

	G5_DATAREV := dDataBase
	IF FieldPos("G5_USER") > 0
		G5_USER := RetCodUsr()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quando Controle de Revisao estiver ativo, grava os campos conforme ³
	//³ realizado na A201AtuAx() para Revisao de Estruturas                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SuperGetMv("MV_REVPROD",.F.,.F.) .And. Posicione("SB5",1,xFilial("SB5")+cProduto,"B5_REVPROD") == "1"
		G5_STATUS := "2"
		G5_MSBLQL := "1"
	EndIf

	If ExistBlock("M200REVI")
		ExecBlock("M200REVI",.f.,.f.)
	EndIf

	SG5->(MsUnlock())


	IF lPCPREVTAB
		PCPREVTAB(cProduto,cRevisao)
	Else
		dbSelectArea("SB1")
		aAreaSB1:=GetArea()
		dbSetOrder(1)
		If dbSeek(xFilial("SB1")+cProduto)
			RecLock("SB1",.F.)
			Replace B1_REVATU With cRevisao
			MsUnlock()
		EndIf
		RestArea(aAreaSB1)
	ENDIF


EndIf
RestArea(aAreaSG5)
RestArea(aArea)
Return cRevisao


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A200Revis ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 05/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza cadastro de revisao de componentes SG5            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpC1 := A200ReVisG5(ExpC2)	                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC2 = codigo do componente		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpC1 = revisao 		 	        			       		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A200RevisG5(cProduto,lShow,lRevAut)

Local cRevisao   := CriaVar("G1_REVINI")
Local aArea      := {}
Local aAreaSG5   := {}
Local aAreaSB1   := {}
Local aRevisoes  := {}
Local lV116      := (VAL(GetVersao(.F.)) == 11 .And. GetRpoRelease() >= "R6" .Or. VAL(GetVersao(.F.))  > 11)

Default lShow	 := .T.
Default lRevAut  := .F.

aArea := GetArea()
dbSelectArea("SG5")
aAreaSG5 := GetArea()
dbSetOrder(1)
If dbSeek(xFilial("SG5")+SubStr(cProduto,1,Len(G5_PRODUTO)))
	Do While !Eof() .And. G5_FILIAL+G5_PRODUTO == xFilial("SG5")+SubStr(cProduto,1,Len(G5_PRODUTO))
		AADD(aRevisoes,{.F.,G5_REVISAO,DTOC(G5_DATAREV)})
		cRevisao:=G5_REVISAO
		dbSkip()
	EndDo
EndIf

dbSelectArea("SB1")
aAreaSB1:=GetArea()
dbSetOrder(1)
If dbSeek(xFilial("SB1")+cProduto)
	cRevSB := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)
	if(cRevSB > cRevisao)
	   cRevisao :=	cRevSB //SB1->B1_REVATU
	endif
EndIf
RestArea(aAreaSB1)

//cRevisao:=Soma1(cRevisao)
AADD(aRevisoes,{.T.,cRevisao,DTOC(dDataBase)})

If lShow .And. !lRevAut
	cRevisao:=A200SelRev(aRevisoes)
Endif

If !Empty(cRevisao)
   dbSelectArea("SG5")
   dbSetOrder(1)

   If dbSeek(xFilial("SG5")+SubStr(cProduto,1,Len(G5_PRODUTO))+cRevisao)
      RecLock("SG5",.F.)
   Else
      RecLock("SG5",.T.)
      G5_FILIAL  := xFilial("SG5")
      G5_PRODUTO := cProduto
      G5_REVISAO := cRevisao
   Endif

   G5_DATAREV := dDataBase
   IF FieldPos("G5_USER") > 0
	   G5_USER := RetCodUsr()
   EndIf
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Quando Controle de Revisao estiver ativo, grava os campos conforme ³
   //³ realizado na A201AtuAx() para Revisao de Estruturas                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If lV116 .And. SuperGetMv("MV_REVPROD",.F.,.F.) .And. Posicione("SB5",1,xFilial("SB5")+cProduto,"B5_REVPROD") == "1"
	   G5_STATUS := "2"
	   G5_MSBLQL := "1"
   EndIf

   If ExistBlock("M200REVI")
   		ExecBlock("M200REVI",.f.,.f.)
   EndIf

   SG5->(MsUnlock())

EndIf
RestArea(aAreaSG5)
RestArea(aArea)
Return cRevisao


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200SelRev³ Autor ³Rodrigo de A. Sartorio ³ Data ³05/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona revisao atual do produto                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpC1 := A200SelRev(ExpA1)			                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = array de revisoes  		                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpC1 = revisao 		 	        			       		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A200SelRev(aRevisoes)

Local oQual,nOpca:=1,cVarQ:="   "
Local cRevisao:=CriaVar("B1_REVATU")
Local oOk := LoadBitmap( GetResources(), "LBOK")
Local oNo := LoadBitmap( GetResources(), "LBNO")
Local oDlg,cTitle:=OemToAnsi(STR0028)	//"Sele‡„o da Revis„o Atual"
Local i:=0,nAchou:=0
If Len(aRevisoes) > 0
	If !l200Auto
		DEFINE MSDIALOG oDlg TITLE cTitle From 145,70 To 400,340 OF oMainWnd PIXEL
		@ 10,13 TO 90,122 LABEL "" OF oDlg  PIXEL
		@ 20,18 LISTBOX oQual VAR cVarQ Fields HEADER "",OemToAnsi(STR0023),STR0029  SIZE 100,62 ON DBLCLICK (aRevisoes:=MA200Troca(oQual:nAt,@aRevisoes),oQual:Refresh()) NOSCROLL OF oDlg PIXEL	//"Revis„o"###"Data"
		oQual:SetArray(aRevisoes)
		oQual:bLine := { || {If(aRevisoes[oQual:nAt,1],oOk,oNo),aRevisoes[oQual:nAt,2],aRevisoes[oQual:nAt,3]}}
		DEFINE SBUTTON FROM 110,042 TYPE 1 Action IF(MA200Valida(aRevisoes),(nOpca:=2,oDlg:End()),.F.) ENABLE OF oDlg PIXEL
		//DEFINE SBUTTON FROM 110,069 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg PIXEL
		ACTIVATE MSDIALOG oDlg
	ElseIf aScan(aAutoCab,{|x| x[1] == "ATUREVSB1" .And. x[2] == "S"}) > 0
		nOpca := 2
	EndIf
	If nOpca == 2
		nAchou:=ASCAN(aRevisoes,{|x| x[1] })
		If nAchou > 0
			cRevisao:=aRevisoes[nAchou,2]
		EndIf
	EndIf
EndIf
Return cRevisao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MA200Valida ³ Autor ³Katiaen Koch³ Data ³ 01/12/2015       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se selecionou alguma revisão                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpA1 := MA200Valida(Array)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = array para ser validadooes                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False se não selecionu revisão, true se selecionou         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MA200Valida(aArray)
Local lRet := .F.
Local nX   := 0

For nX:=1 to Len(aArray)
	If aArray[nX,1]
		lRet := .T.
	EndIf
Next nX

if(!lRet)
   //Help('Selecione uma revisão ', 1)
   Aviso(OemToAnsi(STR0054),STR0080,{"Ok"})
endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MA200Troca ³ Autor ³Rodrigo de A.Sartorio³ Data ³ 05/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ MarcaXDesmarca revisao utilizada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpA1 := A200IniMap(ExpN1,ExpA2)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = nivel no array de revisoes                         ³±±
±±³          ³ ExpA2 = array de revisoes                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA1 = (ExpA2 atualizado)	       			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MA200Troca(nx,aRevisoes)
Local i:=0
aRevisoes[nx,1]:=!aRevisoes[nx,1]
For i:=1 to Len(aRevisoes)
	If nx # i
		aRevisoes[i,1] := .F.
	EndIf
Next i
Return aRevisoes

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A200NivAlt ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Seta o Parametro MV_NIVALT para 'S'                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200NivAlt()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso ocorra algum problema na Valida‡„o, True C.C.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function a200NivAlt()

Local aAreaAnt   := GetArea()
Local lRet       := .F.

//-- Seta o Parametro para Altera‡Æo de Niveis
If !(GetMV('MV_NIVALT')=='S')
	lRet := .T.
	PutMV('MV_NIVALT','S')
EndIf

RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A200Fields ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria um Array com os Campos do SG1                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200Fields(ExpA1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os campos do SG1                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso ocorra algum problema na Valida‡„o, True C.C.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A200Fields(aAcho)

Local aAreaAnt   := GetArea()
Local aAreaSX3   := {}
Local lRet       := .T.

dbSelectArea('SX3')
aAreaSX3 := GetArea()
dbSetOrder(1)
If dbSeek('SG1' + '01', .F.)
	aAcho := {}
	Do While !Eof() .And. X3_ARQUIVO == 'SG1'
		If ! __lPyme .Or. (__lPyme .And. X3_PYME <> "N")
			aAdd(aAcho, X3_CAMPO)
		EndIf
		dbSkip()
	EndDo
Else
	aAcho := Array(SG1->(fCount()))
	SG1->(aFields(aAcho))
EndIf

RestArea(aAreaSX3)
RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200IniMap³ Autor ³ Jose Lucas            ³ Data ³ 11.08.93³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta arquivo binario para armazenar divergencias nas Qtd. ³±±
±±³          ³ dos Componentes em relacao a Qtd. Basica do Produto.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void := A200IniMap(ExpN1,ExpO1)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Quantidade do Componente                           ³±±
±±³          ³ ExpO1 = Objeto Tree                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum 		  	       			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A200IniMap(nQtdBase, oTree)

Local aAreaSG1   := SG1->(GetArea())
Local aAreaAnt   := GetArea()
Local aAreaTRE   := {}
Local cMapaFile  := ''
Local nMapaHdl   := 0
Local nQuant     := 0
Local nSeq       := 0
Local cText      := ''
Local nRecno     := 0
Local nQuantSG1  := 0
Local nQtdComp   := 0
Local cProdPai   := ""
Local aTamSX3	 := TamSX3("G1_QUANT")

cCodAtual := fAjustStr(cCodAtual) //Remove os caracteres proibidos para nomes de arquivo

cMapaFile := 'MAPA'+Alltrim(cCodAtual)+'.DIV'
If File(cMapaFile)
	fErase(cMapaFile)
EndIf
nMapaHdl := MSFCREATE(cMapaFile, 0)

lTemMapa := .T.

dbSelectArea(oTree:cArqTree)
aAreaTRE := GetArea()
dbSetOrder(1)
dbGoTop()
nSeq := 1
Do While !Eof()
    nRecno := Val(SubStr(T_CARGO,Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))
	If nRecno > 0
		SG1->(dbGoto(nRecno))
		nQuantSG1 := SG1->G1_QUANT
	Else
		nQuantSG1 := 0
	EndIf
	If nSeq == 1
		fSeek(nMapaHdl,0,2)
		cText := STR0031 +CHR(13) +CHR(10) //'  Produto                   Qtd. Basica'
		fWrite(nMapaHdl,cText,Len(cText))
		fSeek(nMapaHdl,0,2)
		nQtdBasePai := nQtdBase += CriaVar('B1_QB')
		cProdPai    := SG1->G1_COD
		cText := Space(2) +cProdPai + Space(19-Len(Str(nQtdBase,aTamSX3[1],aTamSX3[2]))) +Str(nQtdBase,aTamSX3[1],aTamSX3[2]) +CHR(13) +CHR(10)
		fWrite(nMapaHdl,cText,Len(cText))
		fSeek(nMapaHdl,0,2)
		cText := + CHR(13) + CHR(10) +Space(2) + STR0032 + CHR(13) + CHR(10) //'Componentes                Quantidade'
		fWrite(nMapaHdl,Replicate('=',43),43)
		fWrite(nMapaHdl,cText,Len(cText))
	Else
	    If  dDataBase >= SG1->G1_INI .And. dDataBase <= SG1->G1_FIM
			nQuant := nQuantSG1
			fSeek(nMapaHdl,0,2)
			If SG1->G1_COD == cProdPai
				If nSeq > 2 .And. nQtdComp > 0
					cText := STR0013 +Space(31) +Str(nQtdComp,aTamSX3[1],aTamSX3[2]) +CHR(13) +CHR(10)
					fWrite(nMapaHdl,cText,Len(cText))
				ElseIf nSeq == 2
					fWrite(nMapaHdl,Replicate('=',43) +CHR(13) +CHR(10),43)
				EndIf
				cText := +CHR(13) +CHR(10) +Space(2) +SG1->G1_COMP +Space(13) +Str(nQuant,aTamSX3[1],aTamSX3[2])
				nQtdComp := 0
			Else
				cText := +CHR(13) +CHR(10) +Space(4) +SG1->G1_COMP +Space(11) +Str(nQuant,aTamSX3[1],aTamSX3[2])
				nQtdComp += nQuant
			EndIf
			fWrite(nMapaHdl,cText,Len(cText))
		Endif
	EndIf
	nSeq++
	dbSkip()
End
If nSeq > 2 .And. nQtdComp > 0
	cText := +CHR(13) +CHR(10) +STR0013 +Space(31) +Str(nQtdComp,aTamSX3[1],aTamSX3[2])
	fWrite(nMapaHdl,cText,Len(cText))
EndIf

RestArea(aAreaTRE)
RestArea(aAreaSG1)
RestArea(aAreaAnt)
FClose(nMapaHdl)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A200ShowMap³ Autor ³ Jose Lucas            ³ Data ³ 11.08.93³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Totalizar e Exibir Mapa de Divergencias nas quantidades    ³±±
±±³          ³ dos ProdutoxElementos.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := A200ShowMap(ExpN1)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor Total da Quantidade dos Componentes          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.  (conf. Confirmacao da Operacao)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function A200ShowMap(nQtdNivel)

Local oGet
Local oDlg
Local oFontLoc
Local aAreaAnt   := GetArea()
Local cMapaFile  := ''
Local cString    := ''
Local cText      := ''
Local nNumLinhas := 0
Local lRet       := .F.
Local aTamSX3	 := TamSX3("G1_QUANT")

Default lAutomacao := .F.

cMapaFile := 'MAPA'+Alltrim(cCodAtual)+'.DIV'
If !File(cMapaFile)
	cString    := STR0012 // '  Nenhuma Divergencia...'
	nNumLinhas := 1
Else
	nMapaHdl := FOpen(cMapaFile,2+64)
	FSeek(nMapaHdl,0,2)
	cText := +CHR(13)+CHR(10) +STR0013 + Space(40 - Len(Str(nQtdNivel,aTamSX3[1],4))) +Str(nQtdNivel,aTamSX3[1],aTamSX3[2]) // '  Total'
	FWrite(nMapaHdl,+CHR(13)+CHR(10),43)
	FWrite(nMapaHdl,Replicate("=",43),43)
	FWrite(nMapaHdl,cText,Len(cText))
	FClose(nMapaHdl)
	cString := MEMOREAD(cMapaFile)
EndIf

oFontLoc := TFont():New('Arial',6,15)
If !lAutomacao
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0014) FROM 15,20 to 38,54 // 'Mapa de Divergencias'
DEFINE SBUTTON FROM 156,070 TYPE 1  ENABLE OF oDlg ACTION (lRet := .T.,oDlg:End())
DEFINE SBUTTON FROM 156,100 TYPE 2  ENABLE OF oDlg ACTION (lRet := .F.,oDlg:End())
@ 0.5,0.7  GET oGet VAR cString OF oDlg MEMO size 125,145 READONLY COLOR CLR_BLACK,CLR_HGRAY
oGet:oFont     := oFontLoc
oGet:bRClicked := {||AllwaysTrue()}
ACTIVATE MSDIALOG oDlg Centered
oFontLoc:End()
EndIf

cRevisao := IIF(lPCPREVATU , PCPREVATU(SG1->G1_COD), SB1->B1_REVATU) 

RestArea(aAreaAnt)
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ Explode  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 03/08/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Faz a explosao de uma estrutura                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ Explode(ExpC1,ExpA1,ExpC2,ExpN1,ExpO1)					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do produto a ser explodido                  ³±±
±±³          ³ ExpA1 = Array com estrutura                                ³±±
±±³          ³ ExpC2 = Revisao da Estrutura Utilizada                     ³±±
±±³          ³ ExpN1 = contador                                           ³±±
±±³          ³ ExpO1 = obj Tree  	                 	  	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum 		  	       			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Explode(cProduto, aExplode, cRevisao, nCount, oTree)

Local aAreaAnt   := GetArea()
Local aAreaSG1   := SG1->(GetArea())
Local aAreaTRE   := {}
Local cCod       := cProduto
Local cSeq       := ''
Local cComp      := ''
Local nRecno     := 0
Local cFilSG1    := xFilial('SG1')

nCount++
SG1->(dbSetOrder(1))

dbSelectArea(oTree:cArqTree)
aAreaTRE := GetArea()
dbSetOrder(1)
dbGoTop()
(aAreaTRE[1])->(dbSkip())// ignora o primeiro recno do arquivo temporario pois esta relacionado ao PA.
Do While !Eof()
	cCod   := Left(T_CARGO, Len(SG1->G1_COD))
	cSeq   := SubStr(T_CARGO, Len(SG1->G1_COD) + 1, Len(SG1->G1_TRT))
	cComp  := SubStr(T_CARGO, Len(SG1->G1_COD + SG1->G1_TRT) + 1, Len(SG1->G1_COMP))
	nRecno := Val(SubStr(T_CARGO,Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))

    If !SG1->(DbSeek(cFilSG1+cCod+cComp+cSeq))
		(aAreaTRE[1])->(dbSkip())
		Loop
    EndIf
	If cCod # cProduto
		dbSkip()
		Loop
	EndIf

	If nRecno > 0
		SG1->(dbGoto(nRecno))
	Else
		Exit
	EndIf
	
	If SB1->(dbSeek(xFilial("SB1") + cCod, .F.))
		cRevisao := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU) 
	EndIf

	If cCod # cComp .And. SG1->G1_REVINI <= cRevisao .And. SG1->G1_REVFIM >= cRevisao
		nPos := aScan(aExplode,{|x| x[1] == nCount .And. x[2] == cCod .And. x[3] == cComp .And. x[5] == cSeq})
		If nPos == 0 .And. dDataBase >= SG1->G1_INI .And. dDataBase <= SG1->G1_FIM
			aAdd(aExplode,{nCount, cCod, cComp, SG1->G1_QUANT, cSeq, SG1->G1_REVINI, SG1->G1_REVFIM})
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe sub-estrutura                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nRecno := SG1->(Recno())
		If SG1->(dbSeek(cFilSG1+cComp, .F.))
			Explode( SG1->G1_COD, @aExplode, cRevisao, @nCount, oTree)
			nCount --
		Else
			SG1->(dbGoto(nRecno))
			nPos := aScan(aExplode,{|x| x[1] == nCount .And. x[2] == cCod .And. x[3] == cComp .And. x[5] == cSeq})
			If nPos == 0 .And. dDataBase >= SG1->G1_INI .And. dDataBase <= SG1->G1_FIM
				aAdd(aExplode,{nCount, cCod, cComp, SG1->G1_QUANT, cSeq, SG1->G1_REVINI, SG1->G1_REVFIM})
			EndIf
		Endif
	EndIf
	(aAreaTRE[1])->(dbSkip())
Enddo

RestArea(aAreaTRE)
RestArea(aAreaSG1)
RestArea(aAreaAnt)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³Ma200PosicºAutor  ³Fernando Joly       º Data ³  10/15/99   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Posiciona sobre o Item desejado na Estrutura                º±±
±±º          ³Esta fun‡„o  cria o  5o  indice  do dbTree , atualizando  a º±±
±±º          ³variavel cInd5. Para  tal  assume-se  como  nomes para os 4 º±±
±±º          ³primeiros : SubStr(oTree:cArqTree,2) + "A", "B", "C" e "D". º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ Ma200Posic(ExpN1,ExpC1,ExpO1,ExpA1,ExpA2)                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpN1 = Op‡„o da Edi‡„o                                    º±±
±±º          ³ ExpC1 = Chave do Registro                                  º±±
±±º          ³ ExpO1 = Objeto Tree                                        º±±
±±³          ³ ExpA1 = tecla de atalho                                    ³±±
±±³          ³ ExpA2 = Array con. blo. de cod. que sera exe. pela tecla de³±±
±±³          ³ atalho e tecla de atalho,Exeplo: aBkey -> aBkey[bKey][aKey]³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ .T.        			       			                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA200.PRW                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ma200Posic(nOpcX, cCargo, oTree, aKey, aBkey)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa Variaveis Locais                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAreaAnt   := GetArea()
Local aAreaTRB   := ''
Local cComp      := Space(Min(TamSX3('G1_COMP')[1],15))
Local cOrdem     := ''
Local cTarget    := ''
Local cArqTrab   := oTree:cArqTree
Local nRecno     := 0
Local nX		 := 0

Private cA200ICod := AllTrim(Str(Len(SG1->G1_COD+SG1->G1_TRT)+1))
Private cA200TCod := AllTrim(Str(Len(SG1->G1_COMP)))
Default aKey     := {}

//--Desativa tecla de atalho
For nX := 1 to len(aKey)
	Set Key aKey[nX] to
Next nX

If Ma200Pesq(@cComp)
	If !Empty(cComp)
		dbSelectArea(cArqTrab)
		aAreaTRB  := GetArea()
		cOrdem    := T_IDCODE
		nRecno    := Recno()
		If cComp==cCodAtual
			dbGoto(1)
			cTarget := T_CARGO
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria o 5o Indice de Trabalho do arquivo dbTree                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cInd5) .Or. !File(cInd5+OrdBagExt())
				cInd5 := CriaTrab('', .F.)
				IndRegua(Alias(),cInd5,'Subs(T_CARGO,'+cA200ICOD+', '+cA200TCOD+')',,,STR0007)
				dbClearIndex()
				dbSetIndex(SubStr(cArqTrab,2)+'A'+OrdBagExt())
				dbSetIndex(SubStr(cArqTrab,2)+'B'+OrdBagExt())
				dbSetIndex(SubStr(cArqTrab,2)+'C'+OrdBagExt())
				dbSetIndex(SubStr(cArqTrab,2)+'D'+OrdBagExt())
				dbSetIndex(cInd5+OrdBagExt())
			EndIf
			dbSetOrder(5)
			dbGoto(nRecno)
			If dbSeek(cComp, .F.)

				//-- Desconsidera a linha do Produto Pai
				If !(Right(T_CARGO,4)=='COMP')
					Do While !Eof() .And. Subs(T_CARGO,Len(SG1->G1_COD+SG1->G1_TRT)+1,Len(SG1->G1_COMP)) == cComp
						If	Right(T_CARGO,4)=='COMP'
							cTarget := T_CARGO
							Exit
						EndIf
						dbSkip()
					EndDo
				Else
					cTarget := T_CARGO
				EndIf

				//-- Caso J  esteja posicionado procura a Pr¢xima ocorrˆncia
				If !Empty(cTarget) .And. T_IDCODE <= cOrdem
					Do While !Eof() .And. Subs(T_CARGO,Len(SG1->G1_COD+SG1->G1_TRT)+1,Len(SG1->G1_COMP)) == cComp
						If Right(T_CARGO,4) == 'COMP' .And. T_IDCODE > cOrdem
							cTarget := T_CARGO
							Exit
						EndIf
						dbSkip()
					EndDo
				EndIf

			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorna Integridade do Sistema                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RestArea(aAreaTRB)
		RestArea(aAreaAnt)

		//-- Posiciona o dbTree sobre o Componente Encontrado
		If !Empty(cTarget)
			oTree:TreeSeek(cTarget)
		Else
			Help(' ',1, 'REGNOIS')
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta Tecla de atalho                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Ma200StKey(aKey,aBkey)

Return .T.


/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Ma200Pesq    ³ Autor ³ Larson Zordan       ³ Data ³ 12/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pesquisa o codigo e o nome do componente no Tree  	        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ma200Pesq(ExpC1)			                       				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = codigo do componente                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.			       			                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Mata200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ma200Pesq(cComp)
Local oDlg
Local oCbx
Local oGet
Local cOrd  := STR0010
Local aOrd  := {STR0010,STR0033} //###Componente ###Descricao
Local lRet  := .F.
Local lSB1  := .F.
Local aArea := SB1->(GetArea())

SB1->(dbSetOrder(3))

Define MsDialog oDlg From 0,0 To 100,490 Pixel Title OemToAnsi(STR0002) //"Pesquisar"
@  5, 5 ComboBox oCbx Var cOrd  Items aOrd Size 206,36 Pixel Of oDlg FONT oDlg:oFont Valid ( If(cOrd==STR0033,cComp:=Space(Len(SB1->B1_DESC)),Space(Len(cComp))) )
@ 22, 5 MsGet    oGet Var cComp Size 206,10 Pixel Valid( Ma200Descr(cOrd,@cComp,@lSB1),If(lSB1,(lRet:=.T.),.T.) )
Define SButton From  5,215 Type 1 Of oDlg Enable Action (lRet:=.T.,oDlg:End())
Define SButton From 20,215 Type 2 Of oDlg Enable Action oDlg:End()
Activate MsDialog oDlg Centered

cComp := If(lRet.And.lSB1,SB1->B1_COD,cComp)

RestArea(aArea)
Return(lRet)

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Ma200Descr   ³ Autor ³ Larson Zordan       ³ Data ³ 12/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pesquisa a descricao no SB1							        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ma200Descr(ExpC1,ExpC2,ExpL1)                       			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Titulo do campo                                      ³±±
±±³          ³ ExpC2 = cod. do componente                                   ³±±
±±³          ³ ExpL1 = .F. se nao existe o componente em SB1                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.			       			                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Mata200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ma200Descr(cOrd,cComp,lSB1)
Local aAreaAnt := GetArea()
Local lRet     := .T.
Default lAutomacao := .F.

If !lAutomacao
	cDesc := STR0033
EndIf

If cOrd == cDesc   //Descricao
	dbSelectArea("SB1")
	dbSetOrder(3)
	dbSeek(xFilial("SB1")+cComp)
	If !(Eof())
		lSB1  := .T.
	Else
		lSB1  := .F.
	EndIf
EndIf
RestArea(aAreaAnt)
Return(lRet)

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Btn200Ok     ³ Autor ³ Marcelo Iuspa       ³ Data ³ 10/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ FUNCAO ACIONADA NO BOTAO DE CONFIRMACAO DA ESTRUTURA         ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Btn200Ok(ExpA1,ExpC1)                             			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os Recnos dos Componentes Incl/Excl        ³±±
±±³          ³ ExpC1 = cod. do componente                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.			       			                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Mata200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Btn200Ok(aUndo, c200Cod, nOpcX)
Local lRet := .T.
Local aArea := {SG1->(IndexOrd()), SG1->(RecNo()), Alias()}
Local nI        := 0
Local nX        := 0
Local aAreaSG1  := SG1->(GetArea())
Local lExclusao := .F.
Local aRecProc  := {}
Local aNewRecs  := {}
Local aDadosInt := {}
Local cCodPai   := ""
Local lExec     := .T.
Local nTotal    := 0
Local nError    := 0
Local nSucess   := 0

Private aIntegPPI := {}
Default lAutomacao := .F.

If !lAutomacao
lIncBkp   := INCLUI
lAltBkp   := ALTERA
EndIf

If ExistBlock('A200BOK')
	lRet := If(ValType(lRet:=ExecBlock('A200BOK',.F.,.F.,{aUndo, c200Cod, nOpcX}))=='L',lRet,.T.)
	SG1->(dbSetOrder(aArea[1]))
	SG1->(dbGoto(aArea[2]))
	dbSelectArea(aArea[3])
EndIf
If PCPIntgPPI()
	SG1->(dbSetOrder(1))
	For nI := 1 To Len(aUndo)
		SG1->(dbGoTo(aUndo[nI,1]))
		If aUndo[nI,2] == 2 .And. SG1->(EOF())
			lExclusao := .T.
			ALTERA := .F.
			INCLUI := .F.
		Else
			lExclusao := .F.
			If aUndo[nI,2] == 1
				ALTERA := .F.
				INCLUI := .T.
			Else
				ALTERA := .T.
				INCLUI := .F.
			EndIf
		EndIf

		//Verifica se esta estrutura já foi processada.
		aNewRecs := {}
		cCodPai := SG1->G1_COD
		SG1->(dbSeek(xFilial("SG1")+cCodPai))
		While SG1->(!Eof()) .And. xFilial("SG1")+cCodPai == SG1->(G1_FILIAL+G1_COD)
			aAdd(aNewRecs,SG1->(Recno()))
			SG1->(dbSkip())
		End
		lExec := .T.
		For nX := 1 To Len(aRecProc)
			If aScan(aNewRecs,{|x| x == aRecProc[nX]}) > 0
				lExec := .F.
				Exit
			EndIf
		Next nX
		If !lExec
			//Se a estrutura já foi processada, pula para a próxima alteração
			Loop
		EndIf
		SG1->(dbGoTo(aUndo[nI,1]))
		If PCPFiltPPI("SG1", SG1->G1_COD+"|"+SG1->G1_COMP, "SG1")
			aAdd(aRecProc,SG1->(Recno()))
			nTotal++
			If MATA200PPI(, SG1->G1_COD, lExclusao, .F., .T., aUndo)
				nSucess++
				aAdd(aDadosInt, {SG1->G1_COD,"", STR0062, STR0082}) //"OK" // "Processado com sucesso"
			Else
				nError++
			EndIf
		EndIf
	Next nI
	If Len(aIntegPPI) > 0
		If Len(aIntegPPI) == 1
			cMsg := STR0090 + AllTrim(aIntegPPI[1,1]) + STR0091 + CHR(13)+CHR(10) + STR0083+": " + AllTrim(aIntegPPI[1,2]) //"Não foi possível realizar a integração com o TOTVS MES para o produto '"XXX"'. Foi gerada uma pendência de integração para este produto."
			Help( ,, 'Help',, cMsg, 1, 0 )
		Else
			For nI := 1 To Len(aIntegPPI)
				aAdd(aDadosInt, {aIntegPPI[nI,1], "", STR0083, aIntegPPI[nI,2]}) //"Erro"
			Next nI
			For nI := 1 To Len(aDadosInt)
				aDadosInt[nI,2] := POSICIONE('SB1',1,XFILIAL('SB1')+aDadosInt[nI,1],'B1_DESC')
			Next nI

			erroPPI(aDadosInt, nTotal, nSucess, nError)
		EndIf
	EndIf
EndIf
ALTERA := lAltBkp
INCLUI := lIncBkp
SG1->(RestArea(aAreaSG1))
Return(lRet)

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A200Prompt   ³ Autor ³ Marcelo Iuspa       ³ Data ³ 24/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Acrescenta TRT ao prompt do dbtree baseado no conteudo       ³±±
±±³          ³ da propriedade cargo                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpC3 := A200Prompt(ExpC1,ExpC2,ExpN1)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = codigo do prompt                                     ³±±
±±³          ³ ExpC2 = chave do registro                                    ³±±
±±³          ³ ExpN1 = quantidade do componente                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpC3 = prompt + TRT + Quant (codigo + sequencia + qtde.)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Mata200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A200Prompt(cPrompt, cCargo, nQtdeSG1,cProdAtu,aOpc)
Local cTRT       := Space(Len(SG1->G1_TRT)+3)
Local aTamQtde   := TamSX3("G1_QUANT")
Local cQuant     := ""
Local cRet       := ""
Local cM200TEXT  := ""
Local nTamCod    := TamSX3("G1_COD")[1]
Local nTamTRT    := TamSX3("G1_TRT")[1]
Local lM200TEXT  := ExistBlock("M200TEXT")
Local cOpc       := ""
Default cProdAtu := ""
Default nQtdeSG1 := 0
Default aOpc     := { }

If ! (cCargo == Nil .Or. Empty(cCargo) .Or. Right(cCargo, 4) $ "CODI,NOVO")
	If ! Empty(cTRT := SubStr(cCargo, nTamCod+1, nTamTRT))
		cTRT := " - " + cTRT
	Endif
	cQuant   := " / "+STR0060+Str(nQtdeSG1,aTamQtde[1],aTamQtde[2])
	If lM200TEXT
		cProdAtu := AllTrim(SubStr(cCargo, nTamCod+1+nTamTRT, nTamCod))
	EndIf
Endif

If lM200TEXT .And. Empty(cProdAtu) .And. !(Empty(cCargo)) .And. Right(cCargo, 4) $ "CODI,NOVO"
	cProdAtu := AllTrim(SubStr(cCargo, 1, nTamCod))
EndIf

If GetMV("MV_SELEOPC") == "S" .And. Len(aOpc) > 0
   cOpc := " / " + STR0077 + AllTrim(aOpc[1][3]) + " - " + AllTrim(aOpc[1][4]) + " / " + STR0078 + AllTrim(aOpc[1][5]) + " - " + AllTrim(aOpc[1][6])
EndIf

if lExpEst
	cRet := (Pad(AllTrim(cPrompt) + cTRT + cQuant + cOpc, Len(cPrompt+cTRT+cQuant+cOpc)))
else
	cRet := (Pad(AllTrim(cPrompt) + cTRT + cQuant + cOpc + '  *', Len(cPrompt+cTRT+cQuant+cOpc)))
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para manipular o texto a ser apresentado na estrutura ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lM200TEXT
	cM200TEXT := ExecBlock("M200TEXT", .F., .F., {cRet,;                                // Texto original
												  AllTrim(Substr(cCargo, 1, nTamCod)),; // Codigo do item PAI
												  SubStr(cCargo, nTamCod+1, nTamTRT),;  // TRT
												  cProdAtu,;    // Codigo do componente/item inserido na estrutura
												  nQtdeSG1})                            // Qtde. do item na estrutura
	If ValType(cM200TEXT) == "C"
		cRet := cM200TEXT
	EndIf
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200Potenc  ³Autor³Rodrigo de A. Sartorio³ Data ³ 09/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao para digitar a potencia do Lote corretamente     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A200Potenc()
LOCAL lRet      := .T.

Default lAutomacao := .F.

If !lAutomacao
cCod		:= M->G1_COMP
nPotencia 	:= M->G1_POTENCI
EndIf

If nPotencia != 0
	If !Rastro(cCod)
		Help(" ",1,"NAORASTRO")
		lRet:=.F.
	Else
		If !PotencLote(cCod)
			Help(" ",1,"NAOCPOTENC")
			lRet:=.F.
		EndIf
	EndIf
EndIf
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ma200Oper     ³ Autor ³ Marcelo Iuspa       ³ Data ³ 02-06-03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona e grava a operacao para o componente               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ma200Oper(ExpN1,ExpC1)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = numero da opcao                                      ³±±
±±³          ³ ExpC1 = chave do registro                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Mata200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ma200Oper(nOpcX, cCargo, oTree)
Local nRecno := Val(SubStr(cCargo,Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))
Local lOk    := .T.
Local cTipo  := Right(cCargo,4)
Local cCodPai:= ""

If !(cTipo == "CODI" .Or. cTipo == "NOVO")
	SG1->(dbGoto(nRecNo))

	cCodPai := SG1->G1_COD

	If lOk .And. !SG2->(dbSeek(xFilial("SG2")+cCodPai))
		Aviso(STR0054,STR0066 +Trim(cCodPai) +".",{STR0062})
		lOk := .F.
	EndIf

	lOk := A637SeleOperac(cCodPai,, .F., ,SG1->G1_COMP,SG1->G1_TRT)

EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  a200CEst  ³ Autor ³Rodrigo de A Sartorio³ Data ³29.10.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Comparacao de estruturas                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A200CEst()
Local aArea:=GetArea()
Local cCodOrig:=Criavar("G1_COMP",.F.),cCodDest:=Criavar("G1_COMP",.F.)
Local cRevOrig:=Criavar("C2_REVISAO",.F.),cRevDest:=Criavar("C2_REVISAO",.F.)
Local cDescOrig:=Criavar("B1_DESC",.F.),cDescDest:=Criavar("B1_DESC",.F.)
Local cOpcOrig:=Criavar("C2_OPC",.F.),cOpcDest:=Criavar("C2_OPC",.F.)
Local mOpcDest := ""
Local mOpcOrig := ""
Local dDtRefOrig:=dDataBase,dDtRefDest:=dDataBase
Local oSay,oSay2, oChk
Local lOk:=.F.
Local aInfo := {}
Local aObjects:= {}
Local aPosObj:= {}
Local oSizeW := FwDefSize():New()
Local oSizeI := Nil
Private lDif := .F.


oSizeW:AddObject('WND', 600,310, .F.,.F.)
oSizeW:Process()

aPosObj 	:= {oSizeW:GetDimension('WND','LININI'),oSizeW:GetDimension('WND','COLINI'),oSizeW:GetDimension('WND','LINEND'),oSizeW:GetDimension('WND','COLEND')}



DEFINE MSDIALOG oDlg FROM  aPosObj[1],aPosObj[2] TO aPosObj[3],aPosObj[4] TITLE OemToAnsi(STR0035) PIXEL //"Comparador de Estruturas"

oSizeI		:= FwDefSize():New(.T.,,,oDlg)

oSizeI:AddObject('TOP',100,45,.T.,.T.)
oSizeI:AddObject('BOT',100,45,.T.,.T.)
oSizeI:AddObject('CHK',100,10 ,.T.,.T.)

osizeI:lProp 		:= .T.
oSizeI:aMargins 	:= { 3, 3, 3, 3}
oSizeI:Process()


DEFINE SBUTTON oBtn FROM 800,800 TYPE 5 ENABLE OF oDlg

@ oSizeI:GetDimension('TOP','LININI'),oSizeI:GetDimension('TOP','COLINI') TO oSizeI:GetDimension('TOP','LINEND'),oSizeI:GetDimension('TOP','COLEND')-5 LABEL OemToAnsi(STR0036) OF oDlg PIXEL //"Dados Originais"
@ oSizeI:GetDimension('BOT','LININI'),oSizeI:GetDimension('BOT','COLINI') TO oSizeI:GetDimension('BOT','LINEND'),oSizeI:GetDimension('BOT','COLEND')-5 LABEL OemToAnsi(STR0037) OF oDlg PIXEL //"Dados para Comparacao"

@ oSizeI:GetDimension('TOP','LININI')+12,035 MSGET cCodOrig   F3 "SB1" Picture PesqPict("SG1","G1_COMP") Valid NaoVazio(cCodOrig) .And. ExistCpo("SB1",cCodOrig) SIZE 105,9 OF oDlg PIXEL
@ oSizeI:GetDimension('TOP','LININI')+12,200 MSGET cRevOrig   Picture PesqPict("SC2","C2_REVISAO") SIZE 15,09 OF oDlg PIXEL
@ oSizeI:GetDimension('TOP','LININI')+27,200 MSGET dDtRefOrig Picture PesqPict("SD3","D3_EMISSAO") Valid NaoVazio(dDtRefOrig) SIZE 40,09 OF oDlg PIXEL
@ oSizeI:GetDimension('TOP','LININI')+27,040 MSGET cOpcOrig   When .F. SIZE 93,09 OF oDlg PIXEL
@ oSizeI:GetDimension('TOP','LININI')+27,133 BUTTON "?" SIZE 06,11 Action (cOpcOrig:=SeleOpc(4,"MATA200",cCodOrig,,,,,,1,dDtRefOrig,cRevOrig,,@mOpcOrig)) OF oDlg FONT oDlg:oFont PIXEL

@ oSizeI:GetDimension('BOT','LININI')+12,035 MSGET cCodDest   F3 "SB1" Picture PesqPict("SG1","G1_COMP") Valid NaoVazio(cCodDest) .And. ExistCpo("SB1",cCodDest) SIZE 105,9 OF oDlg PIXEL
@ oSizeI:GetDimension('BOT','LININI')+12,200 MSGET cRevDest   Picture PesqPict("SC2","C2_REVISAO") SIZE 15,09 OF oDlg PIXEL
@ oSizeI:GetDimension('BOT','LININI')+27,200 MSGET dDtRefDest Picture PesqPict("SD3","D3_EMISSAO") Valid NaoVazio(dDtRefDest) SIZE 40,09 OF oDlg PIXEL
@ oSizeI:GetDimension('BOT','LININI')+27,040 MSGET cOpcDest   When .F. SIZE 93,09 OF oDlg PIXEL
@ oSizeI:GetDimension('BOT','LININI')+27,133 BUTTON "?" SIZE 06,11 Action (cOpcDest:=SeleOpc(4,"MATA200",cCodDest,,,,,,1,dDtRefDest,cRevDest,,@mOpcDest)) OF oDlg FONT oDlg:oFont PIXEL

@ aPosObj[1]+37,030 SAY oSay Prompt cDescOrig SIZE 130,6 OF oDlg PIXEL
@ aPosObj[1]+73,030 SAY oSay2 Prompt cDescDest SIZE 130,6 OF oDlg PIXEL

@ oSizeI:GetDimension('TOP','LININI')+14,010 SAY OemtoAnsi(STR0038) SIZE 25,7  OF oDlg PIXEL //"Produto"
@ oSizeI:GetDimension('TOP','LININI')+14,175 SAY OemToAnsi(STR0039) SIZE 35,13 OF oDlg PIXEL //"Revisao"
@ oSizeI:GetDimension('TOP','LININI')+29,156 SAY OemToAnsi(STR0040) SIZE 85,13 OF oDlg PIXEL //"Data Referencia"
@ oSizeI:GetDimension('TOP','LININI')+29,010 SAY OemtoAnsi(STR0041) SIZE 25,7  OF oDlg PIXEL //"Opcionais"

@ oSizeI:GetDimension('BOT','LININI')+14,010 SAY OemToAnsi(STR0038) SIZE 25,7  OF oDlg PIXEL //"Produto"
@ oSizeI:GetDimension('BOT','LININI')+14,175 SAY OemToAnsi(STR0039) SIZE 35,13 OF oDlg PIXEL //"Revisao"
@ oSizeI:GetDimension('BOT','LININI')+29,156 SAY OemToAnsi(STR0040) SIZE 85,13 OF oDlg PIXEL //"Data Referencia"
@ oSizeI:GetDimension('BOT','LININI')+29,010 SAY OemtoAnsi(STR0041) SIZE 25,7  OF oDlg PIXEL //"Opcionais"

@ oSizeI:GetDimension('CHK','LININI'),oSizeI:GetDimension('CHK','COLINI') CHECKBOX oChk VAR lDif PROMPT OemtoAnsi(STR0059) SIZE 150,009 Of oDlg PIXEL //"Mostra somente componentes diferentes?"

ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| If(A200COk(cCodOrig,cRevOrig,dDtRefOrig,cOpcOrig,cCodDest,cRevDest,dDtRefDest,cOpcDest),(lOk:=.T.,oDlg:End()),lOk:=.F.) },{||(lOk:=.F.,oDlg:End())})

// Processa comparacao das estruturas
If lOk
	Processa({|| A200PrCom(cCodOrig,cRevOrig,dDtRefOrig,cOpcOrig,cCodDest,cRevDest,dDtRefDest,cOpcDest,mOpcOrig,mOpcDest) })
EndIf
RestArea(aArea)
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A200Cok     ³ Autor ³Rodrigo de A Sartorio³ Data ³29.10.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida se pode efetuar a comparacao das estruturas         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200Cok(ExpC1,ExpC2,ExpD1,ExpC3,ExpC4,ExpC5,ExpD2,ExpC6)	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do produto origem                           ³±±
±±³          ³ ExpC2 = Codigo da revisao origem                           ³±±
±±³          ³ ExpD1 = Data de referencia origem                          ³±±
±±³          ³ ExpC3 = Opcionais do produto origem                        ³±±
±±³          ³ ExpC4 = Codigo do produto destino                          ³±±
±±³          ³ ExpC5 = Codigo da revisao destino                          ³±±
±±³          ³ ExpD2 = Data de referencia destino                         ³±±
±±³          ³ ExpC6 = Opcionais do produto destino                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A200COk(cCodOrig,cRevOrig,dDtRefOrig,cOpcOrig,cCodDest,cRevDest,dDtRefDest,cOpcDest)
Local lRet:=.T., lRetPE := .T., lExibDif := .T.
Local aEstruOrig:={},aEstruDest:={}
Private nEstru:=0
// Verifica se todas as informacoes estao iguais
If cCodOrig+cRevOrig+DTOS(dDtRefOrig)+cOpcOrig == cCodDest+cRevDest+DTOS(dDtRefDest)+cOpcDest
	Help('  ',1,'A200COMPIG')
	lRet:=.F.
EndIf
If lRet .And. cCodOrig <> cCodDest
	// Verifica se existe item dentro da outra estrutura - NAO PERMITE COMPARAR PARA EVITAR RECURSIVIDADE
	nEstru:=0;aEstruOrig:=Estrut(cCodOrig,1)
	nEstru:=0;aEstruDest:=Estrut(cCodDest,1)
	If (aScan(aEstruOrig,{|x| x[3] == cCodDest}) > 0) .Or. (aScan(aEstruDest,{|x| x[3] == cCodOrig}) > 0)
		Help('  ',1,'A200COMPES')
		lRet:=.F.
	EndIf
	// Avisa ao usuario sobre produtos diferentes
	If lRet
		If ExistBlock("MT200DIF")
			lRetPE   := ExecBlock("MT200DIF",.F.,.F.,{cCodOrig,cCodDest})
			lExibDif := IIF(ValType(lRetPE)=="L",lRetPE,lExibDif)
		EndIf
		If lExibDif
			Help('  ',1,'A200COMPDF')
		EndIf
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A200PrCom   ³ Autor ³Rodrigo de A Sartorio³ Data ³29.10.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua a comparacao das estruturas                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200PrCom (ExpC1,ExpC2,ExpD1,ExpC3,ExpC4,ExpC5,ExpD2,ExpC6)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do produto origem                           ³±±
±±³          ³ ExpC2 = Codigo da revisao origem                           ³±±
±±³          ³ ExpD1 = Data de referencia origem                          ³±±
±±³          ³ ExpC3 = Opcionais do produto origem                        ³±±
±±³          ³ ExpC4 = Codigo do produto destino                          ³±±
±±³          ³ ExpC5 = Codigo da revisao destino                          ³±±
±±³          ³ ExpD2 = Data de referencia destino                         ³±±
±±³          ³ ExpC6 = Opcionais do produto destino                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A200PrCom(cCodOrig,cRevOrig,dDtRefOrig,cOpcOrig,cCodDest,cRevDest,dDtRefDest,cOpcDest,mOpcOrig,mOpcDest)
Local aEstruOri:={}
Local aEstruDest:={}
Local aSize    := MsAdvSize(.T.)
Local oDlg,oTree,oTree2,aObjects:={},aInfo:={},aPosObj:={},aButtons:={}
Local cDescOri	:= "",cDescDest := ""
Local l800x600	:= .F.
Local nEst1

 lestigual := cCodOrig = cCodDest

 IF lestigual .and. cRevOrig > cRevDest
  cOrdeRev := '2'
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a  tela com o tree da versao base e com o tree da versao³
//³resultado da comparacao.                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aObjects, { 100, 100, .T., .T., .F. } )
aAdd( aObjects, { 100, 100, .T., .T., .F. } )
aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 }
aPosObj:= MsObjSize( aInfo, aObjects, .T.,.T. )

l800x600 := aSize[5] <= 800

If ExistBlock( "MA200BUT" )
	If Valtype( aUsrBut := Execblock( "MA200BUT", .f., .f. ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButtons, x ) } )
	EndIF
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta array com os conteudos dos tree                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SG1->(dbSeek(xFilial("SG1")+cCodOrig))
M200Expl(cCodOrig,cRevOrig,dDtRefOrig,cOpcOrig,1,aEstruOri,0,mOpcOrig)
SG1->(dbSeek(xFilial("SG1")+cCodDest))
M200Expl(cCodDest,cRevDest,dDtRefDest,cOpcDest,1,aEstruDest,0,mOpcDest)

//sequencia da estrutura para comparacao
for nEst1 := 1 to len(aEstruOri)
	aEstruOri[nEst1,11] := nEst1
next nEst1

nEst1 := 0

for nEst1 := 1 to len(aEstruDest)
	aEstruDest[nEst1,11] := nEst1
next nEst1


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Iguala os arrays de origem e destino da comparacao                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Mt200CpAr(aEstruOri,aEstruDest,cCodOrig,cCodDest)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Descricao do Produto Origem e Destino                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SB1->(MsSeek(xFilial("SB1")+cCodOrig))
	cDescOri:=SB1->B1_DESC
EndIf

If SB1->(MsSeek(xFilial("SB1")+cCodDest))
	cDescDest:=SB1->B1_DESC
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0035) FROM -20,-50 TO aSize[6]-50,aSize[5]-70 OF oMainWnd PIXEL
	@ aPosObj[1,1],aPosObj[1,2] TO If(l800x600,070,060)+15,aPosObj[1,4]-7 LABEL OemToAnsi(STR0036) OF oDlg PIXEL //"Dados Originais"

	@ aPosObj[1,1]+10,028 MSGET cCodOrig   When .F. SIZE 105,09 OF oDlg PIXEL
	@ aPosObj[1,1]+26,158 MSGET cRevOrig   Picture PesqPict("SC2","C2_REVISAO") When .F. SIZE 15,09 OF oDlg PIXEL
	@ aPosObj[1,1]+10,194 MSGET dDtRefOrig Picture PesqPict("SD3","D3_EMISSAO") When .F. SIZE 44,09 OF oDlg PIXEL

	@ aPosObj[1,1]+12,006 SAY OemtoAnsi(STR0038)  SIZE 24,7  OF oDlg PIXEL //"Produto"
	@ aPosObj[1,1]+28,135 SAY OemToAnsi(STR0039)  SIZE 32,13 OF oDlg PIXEL //"Revisao"
	@ aPosObj[1,1]+12,152 SAY OemToAnsi(STR0040)  SIZE 50,09 OF oDlg PIXEL //"Data Referencia"

	@ aPosObj[1,1]+26,194 MSGET cOpcOrig   When .F. SIZE 35,09 OF oDlg PIXEL
	@ aPosObj[1,1]+28,182 SAY OemtoAnsi(STR0099)   SIZE 24,7  OF oDlg PIXEL //Opc.
	@ aPosObj[1,1]+28,006 SAY OemtoAnsi(cDescOri) SIZE 130,6 Color CLR_HRED OF oDlg PIXEL

	@ aPosObj[2,1], aPosObj[2,2]-8 TO If(l800x600,070,060)+15,aPosObj[2,4]-8 LABEL OemToAnsi(STR0037) OF oDlg PIXEL //"Dados para Comparacao"

	@ aPosObj[2,1]+10,aPosObj[2,2]+015 MSGET cCodDest   When .F. SIZE 105,9 OF oDlg PIXEL
	@ aPosObj[2,1]+26,aPosObj[2,2]+152 MSGET cRevDest   Picture PesqPict("SC2","C2_REVISAO") When .F.  SIZE 15,09 OF oDlg PIXEL
	@ aPosObj[2,1]+10,aPosObj[2,2]+190 MSGET dDtRefDest Picture PesqPict("SD3","D3_EMISSAO") When .F. SIZE 44,09 OF oDlg PIXEL

	@ aPosObj[2,1]+12,aPosObj[2,2]-006 SAY OemToAnsi(STR0038)   SIZE 24,7  OF oDlg PIXEL //"Produto"
	@ aPosObj[2,1]+28,aPosObj[2,2]+130 SAY OemToAnsi(STR0039)   SIZE 32,13 OF oDlg PIXEL //"Revisao"
	@ aPosObj[2,1]+12,aPosObj[2,2]+147 SAY OemToAnsi(STR0040)   SIZE 50,09 OF oDlg PIXEL //"Data Referencia"

	@ aPosObj[2,1]+26,aPosObj[2,2]+190 MSGET cOpcDest   When .F. SIZE 35,09 OF oDlg PIXEL
	@ aPosObj[2,1]+28,aPosObj[2,2]+178 SAY OemtoAnsi(STR0099)    SIZE 24,7  OF oDlg PIXEL //Opc.
	@ aPosObj[2,1]+28,aPosObj[2,2]-006 SAY OemtoAnsi(cDescDest) SIZE 130,6 Color CLR_HRED OF oDlg PIXEL

	oTree:= dbTree():New(aPosObj[1,1]+If(l800x600,060,050), aPosObj[1,2],aPosObj[1,3]-10,aPosObj[1,4]-10, oDlg,,,.T.)
	oTree:lShowHint := .F.

	ProcRegua(len(aEstruOri))
	cMsgProc := 'Processando Dados Originais'
	CESTRUTURA := '1' // origem
	A200TreeCm(oTree,aEstruOri,NIL,NIL,NIL,NIL,nseqori)
	oTree2:=dbTree():New(aPosObj[2,1]+If(l800x600,060,050), aPosObj[2,2]-10,aPosObj[2,3]-10,aPosObj[2,4]-10, oDlg,,,.T.)
	oTree:lShowHint := .F.
	ProcRegua(len(aEstruDest))
	cMsgProc := 'Processando Dados para comparação'
	CESTRUTURA := '2' // destino
	A200TreeCm(oTree2,aEstruDest,NIL,NIL,NIL,NIL,nseqdest)
	AAdd( aButtons, { "PMSSETADOWN", { || Mt200Nav(1,@oTree,@oTree2,aEstruOri,aEstruDest) },OemToAnsi(STR0042)} ) //"Desce"
	AAdd( aButtons, { "PMSSETAUP"  , { || Mt200Nav(2,@oTree,@oTree2,aEstruOri,aEstruDest) },OemToAnsi(STR0043)} ) //"Sobe"
	AAdd( aButtons, { "DBG09"      , { || Mt200Inf() }, STR0049 } ) //"Legenda"
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {||oDlg:End()} ,{||oDlg:End()},,aButtons)
Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³M200Expl  ³ Autor ³Rodrigo A Sartorio     ³ Data ³ 29/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Faz a explosao de uma estrutura para comparacao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ M200Expl(ExpC1,ExpC2,ExpD1,ExpC3,ExpN1,ExpA1,ExpN2)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do produto a ser explodido                  ³±±
±±³          ³ ExpC2 = Revisao do produto a ser explodido                 ³±±
±±³          ³ ExpD1 = Data de referencia para explosao do produto        ³±±
±±³          ³ ExpC3 = Grupo de opcionais para explosao do produto        ³±±
±±³          ³ ExpN1 = Quantidade base para explosao                      ³±±
±±³          ³ ExpA1 = Array com o retorno da estrutura                   ³±±
±±³          ³ ExpN2 = Nivel da estrutura                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
STATIC Function M200Expl(cProduto,cRevisao,dDataRef,cOpcionais,nQuantPai,aEstru,nNivelEstr,mOpc,cProdAnt)
LOCAL nReg:=0,nQuantItem:=0,nHistorico:=4 // Produto ok
LOCAL nNivelBase := 999
LOCAL lExistBlock := ExistBlock("M200NIV")
LOCAL nRet
Local cComp   := ""
Local cTrt    := ""
Local cOpcPar := ""
Local aOpc    := Str2Array(mOpc,.F.)
Local nPos    := 0
Local lRevAut    	:= SuperGetMv("MV_REVAUT",.F.,.F.)

Default lAutomacao := .F.
Default cProdAnt := PadR(cProduto,TamSX3("G1_COD")[1])

// Estrutura do array
// [1] Produto PAI
// [2] Componente
// [3] TRT
// [4] Quantidade
// [5] Historico
// [6] Nivel
// [7] Cargo = [6]+[2]+[3]
// [8] Revisao inicial
// [9] Revisao final

dbSelectArea("SB1")
dbSetOrder(1)
IF  empty(cRevisao)  // PEGA A ULTIMA REVISAO CASO O PARAMETRO DE REVISAO DE ESTRUTUTA ESTIVER ATIVADO
	If SB1->(dbSeek(xFilial("SB1") + cProduto, .F.))
			cRevisao := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU) // SB1->B1_REVATU
	EndIf
ENDIF

dbSelectArea("SG1")
dbSetOrder(1)
While !Eof() .And. G1_FILIAL+G1_COD == xFilial("SG1")+cProduto

	//-- Nao Adiciona Componentes fora da Revisao


		If  (cRevisao # Nil) .And. ;
			!(SG1->G1_REVINI <= cRevisao .And. (SG1->G1_REVFIM >= cRevisao .Or. SG1->G1_REVFIM = ' '))
			SG1->(dbSkip())
			Loop
		EndIf



	nReg := Recno()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula a qtd dos componentes                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nHistorico := 4
	cOpcPar    := cOpcionais
	If aOpc != Nil .And. Len(aOpc) > 0 .And. !Empty(SG1->G1_GROPC)
		nPos := aScan(aOpc,{|x| x[1] == cProdAnt+SG1->G1_COMP+SG1->G1_TRT})
		If nPos > 0
			cOpcPar := aOpc[nPos,2]
		Else
			cOpcPar := "*NAOENTRA*"
		EndIf
	EndIf
	If !lAutomacao
	nQuantItem := ExplEstr(nQuantPai,dDataRef,cOpcPar,cRevisao,@nHistorico)
	EndIf
	dbSelectArea("SG1")
	SB1->(dbSeek(xFilial("SB1")+SG1->G1_COMP))
	If QtdComp(nQuantItem) < QtdComp(0)
		nQuantItem:=If(QtdComp(RetFldProd(SB1->B1_COD,"B1_QB"))>0,RetFldProd(SB1->B1_COD,"B1_QB"),1)
	EndIf
	If Empty(cRevisao) .And. !Empty(SG1->G1_REVINI)
		nHistorico := 3
	EndIf
	AADD(aEstru,{SG1->G1_COD,SG1->G1_COMP,SG1->G1_TRT,nQuantItem,nHistorico,nNivelEstr,StrZero(nNivelEstr,5,0)+SG1->G1_COMP+SG1->G1_TRT,SG1->G1_REVINI,SG1->G1_REVFIM,'',0})
	cComp := SG1->G1_COMP
	cTrt  := SG1->G1_TRT
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe sub-estrutura                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SG1")
	If dbSeek(xFilial("SG1")+SG1->G1_COMP)
		nNivelEstr++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para definir o nivel de comparacao                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lExistBlock
			nRet := (ExecBlock("M200NIV",.F.,.F.))
			If ( Valtype(nRet) == "N" )
				nNivelBase := nRet
			EndIf
		EndIf

		If nNivelEstr <= nNivelBase
			M200Expl(SG1->G1_COD,IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)/*SB1->B1_REVATU*/,dDataRef,cOpcionais,nQuantItem,aEstru,nNivelEstr,mOpc,cProdAnt+cComp+cTrt)
		EndIf
		nNivelEstr--
	EndIf
	dbGoto(nReg)
	dbSkip()
EndDo
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Mt200CpAr ³ Autor ³Rodrigo de A Sartorio  ³ Data ³ 05/11/2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Compara e ajusta os arrays de origem e destino   			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ Mt200CpAr(ExpA1,ExpA2,ExpC1,ExpC2)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os dados da estrutura origem da comparacao ³±±
±±³          ³ ExpA2 = Array com os dados da estrutura destino da comparacao³±±
±±³          ³ ExpC1 = Codigo do produto origem                             ³±±
±±³          ³ ExpC2 = Codigo do produto destino                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA200                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Mt200CpAr(aEstruOri,aEstruDest,cCodOrig,cCoddest)
Local nz:=0,nw:=0,nAcho:=0
Local cProcura:="",lFirstLevel:=.F.
Local nHist  := 5  // historio da comparacao, padrao sempre 5 - fora da estrutura

if lestigual  // se estrutura for igual, o historico vai ser componente fora da revisão.
	nHist := 3
endif
// Estrutura do array
// [1] Produto PAI
// [2] Componente
// [3] TRT
// [4] Quantidade
// [5] Historico
// [6] Nivel
// [7] Cargo = [6]+[2]+[3]
// [8] Revisao inicial
// [9] Revisao final

// Compara os elementos em comum do array
// Adiciona no array origem os componentes do array destino diferentes
For nz:=1 To Len(aEstruDest)
	// Verifica se esta no primeiro nivel
	If aEstruDest[nz,6]==0
		lFirstLevel:=.T.
	Else
		lFirstLevel:=.F.
	EndIf
	// Nao procura o produto pai junto
	If lFirstLevel
		cProcura:=aEstruDest[nz,2]+aEstruDest[nz,3]
	// Procura o produto pai junto
	Else
		cProcura:=aEstruDest[nz,1]+aEstruDest[nz,2]+aEstruDest[nz,3]
	EndIf
	// Efetua procura no array origem
	nAcho:=ASCAN(aEstruOri,{|x| x[6] == aEstruDest[nz,6] .And. (If(lFirstLevel,x[2]+x[3],x[1]+x[2]+x[3]) == cProcura)})
	// Caso nao achou soma componentes no array origem com a estrutura do item
	If nAcho == 0

		For nw:=nz to Len(aEstruDest)
			nseqori++
			AADD(aEstruOri,{If(lFirstLevel,If(Len(aEstruOri)> 0,aEstruOri[1,1],cCodOrig),aEstruDest[nw,1]),aEstruDest[nw,2],aEstruDest[nw,3],aEstruDest[nw,4],nHist,aEstruDest[nw,6],aEstruDest[nw,7],aEstruDest[nw,8],aEstruDest[nw,9],'fora',nseqori})
			// Desliga flag de primeiro nivel
			If lFirstLevel
				lFirstLevel:=.F.
			EndIf
			If nw == Len(aEstruDest) .Or. (aEstruDest[nz,6] == aEstruDest[nw+1,6])
				nz:=nw
				Exit
			EndIf

		Next nw
	EndIf
Next nz

// Adiciona no array destino os componentes do array origem diferentes
For nz:=1 To Len(aEstruOri)
	// Verifica se esta no primeiro nivel
	If aEstruOri[nz,6]==0
		lFirstLevel:=.T.
	Else
		lFirstLevel:=.F.
	EndIf
	// Nao procura o produto pai junto
	If lFirstLevel
		cProcura:=aEstruOri[nz,2]+aEstruOri[nz,3]
	// Procura o produto pai junto
	Else
		cProcura:=aEstruOri[nz,1]+aEstruOri[nz,2]+aEstruOri[nz,3]
	EndIf
	// Efetua procura no array origem
	nAcho:=ASCAN(aEstruDest,{|x| x[6] == aEstruOri[nz,6] .And. (If(lFirstLevel,x[2]+x[3],x[1]+x[2]+x[3]) == cProcura)})
	// Caso nao achou soma componentes no array origem com a estrutura do item
	If nAcho == 0
		For nw:=nz to Len(aEstruOri)
		nseqdest++
			AADD(aEstruDest,{If(lFirstLevel,If(Len(aEstruDest)> 0,aEstruDest[1,1],cCodDest),aEstruOri[nw,1]),aEstruOri[nw,2],aEstruOri[nw,3],aEstruOri[nw,4],nHist,aEstruOri[nw,6],aEstruOri[nw,7],aEstruOri[nw,8],aEstruOri[nw,9],'fora',nseqdest})
			// Desliga flag de primeiro nivel
			If lFirstLevel
				lFirstLevel:=.F.
			EndIf
			If nw == Len(aEstruOri) .Or. (aEstruOri[nz,6] == aEstruOri[nw+1,6])
				nz:=nw
				Exit
			EndIf
		Next nw
	EndIf
Next nz

// Ordena arrays por nivel
ASORT(aEstruOri,,,{|x,y| x[7] < y[7] })
ASORT(aEstruDest,,,{|x,y| x[7] < y[7] })
RETURN(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A200TreeCM³ Autor ³Rodrigo de A Sartorio  ³ Data ³ 05/11/2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta o objeto TREE - FUNCAO RECURSIVA           			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³A200TreeCM(ExpO1,ExpA1,ExpC1,ExpN1)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto tree utilizado                                ³±±
±±³          ³ ExpA1 = Array com os dados da estrutura                      ³±±
±±³          ³ ExpC1 = Codigo do produto a ter a estrutura explodida        ³±±
±±³          ³ ExpN1 = Posicao do array de estrutura utilizado              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA200                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A200TreeCm(oObjTree,aEstru,cProduto,nz,aDbTree,cstatus,nseq )
Local nAcho:=0
Local aOcorrencia :={}
Local cTexto:=""
Local cprodX:=""
Local cDesc	:= ""
Local cCargoVazio:=Space(5+Len(SG1->G1_COMP+SG1->G1_TRT))
Default nz:=1
Default cProduto:=""
Default aDbTree := {}
Default cstatus	:= ''
default nseq 	:= 1

// Ordem de pesquisa por codigo
SB1->(dbSetOrder(1))

// Array com as ocorrencias cadastradas
AADD(aOcorrencia,"PMSTASK4") //"Componente fora das datas inicio / fim"
AADD(aOcorrencia,"PMSTASK5") //"Componente fora dos grupos de opcionais"
AADD(aOcorrencia,"PMSTASK2") //"Componente fora das revisoes"
AADD(aOcorrencia,"PMSTASK6") //"Componente ok"
AADD(aOcorrencia,"PMSTASK1") //"Componente nao existente"

// Monta tree na primeira vez
If Empty(cProduto) .And. Len(aEstru) > 0
	cProduto:=aEstru[1,1]

	oObjTree:BeginUpdate()
	oObjTree:Reset()
	oObjTree:EndUpdate()
// Coloca titulo no TREE
	SB1->(dbSeek(xFilial("SB1")+aEstru[1,1]))
	oObjTree:AddTree(AllTrim(aEstru[1,1])+" - "+Alltrim(Substr(SB1->B1_DESC,1,30))+Space(60),.T.,,,aOcorrencia[4],aOcorrencia[4],cCargoVazio)
EndIf



While nz <=  Len(aEstru)

	 IF  ! aEstru[nz,1] == cProduto
		 nz++
		 loop
	Endif

	//Pega a sequencia da estrutura, para nao se perder na montagem do tree
	IF CESTRUTURA = cOrdeRev
			IF  aEstru[nz,10] =='fora' .and.  aEstru[nz,11] = 1 //iniciou sequencias das estrutura de fora
				nSeqAux := 1
			ENDIF

			IF  aEstru[nz,10] =='fora'
				if  aEstru[nz,11] = nSeqAux
					nSeqAux++
				else
					nz++
					loop
				endif
			endif
	Else
			IF  aEstru[nz,10] == '' .and.  aEstru[nz,11] = 1 //iniciou sequencias das estrutura de fora
				nSeqAux1 := 1
			ENDIF
		IF  aEstru[nz,10] == ''
				if  aEstru[nz,11] = nSeqAux1
					nSeqAux1++
				else
					nz++
					loop
				endif
			endif
	endif

	// Verifica se componente tem estrutura
	nAcho:= ASCAN(aEstru,{|x| x[1] == aEstru[nz,2]} )

	// Monta Texto
	cDesc :=  POSICIONE("SB1",1,XFILIAL("SB1")+aEstru[nz,2], 'B1_DESC')
	cTexto:=Alltrim(aEstru[nz,2])+" - "+cDesc /*AllTrim(Substr(SB1->B1_DESC,1,30))*/ +" / "+STR0057+ aEstru[nz,3]+" / "+STR0058+aEstru[nz,8]+" - "+aEstru[nz,9]+Space(20)

	cprodX := cTexto

	//If ExistBlock("M200CPTX")
	IF LM200CPTX
		cM200CPTX := ExecBlock("M200CPTX",.F.,.F.,{cTexto,aEstru[nz][1],aEstru[nz][2],SB1->B1_DESC,aEstru[nz][3],aEstru[nz][4],aEstru[nz][8],aEstru[nz][9]})
		If ValType(cM200CPTX) == "C"
			cTexto := cM200CPTX
		EndIf
	EndIf

	If nAcho > 0
	  		If (!lDif .OR. aEstru[nz,5] <> 4) .and. Empty(AsCan(aDbTree,{|x|x[1]==cTexto .And. x[2]==aEstru[nz,1] .And. x[3]==aEstru[nz,5] .And. x[4] == aEstru[nz,7] .And. x[5]==nz}))

				 //.And. aEstru[nz,1] == cProduto
				Aadd(aDbTree,{cTexto,aEstru[nz,1],aEstru[nz,5],aEstru[nz,7],nz})
				// Coloca titulo no TREE
					oObjTree:AddTree(cTexto,.T.,,,aOcorrencia[aEstru[nz,5]],aOcorrencia[aEstru[nz,5]],aEstru[nz,7])
					IncProc(cMsgProc)

				If aEstru[nz,10] == 'fora'
					cstatus := 'fora'
				Else
					cstatus := ''
				Endif

				// Chama funcao recursiva
				A200TreeCm(oObjTree,aEstru,aEstru[nz,2],nAcho,aDbTree,cstatus,aEstru[nz,11] )
				// Encerra TREE
				oObjTree:EndTree()

			EndIf

	ElseIf aEstru[nz,1] == cProduto

	 	IF 	LEN(aDbTree) = 0  .OR. cprodX # aDbTree[LEN(aDbTree)][1]

			// Adiciona item no tree
			If (!lDif .OR. aEstru[nz,5] <> 4) .And. Empty(AsCan(aDbTree,{|x|x[1]==cTexto .And. x[2]==aEstru[nz,1] .And. x[3]== aEstru[nz,5] .And. x[4]==aEstru[nz,7] .And. x[5]==nz}))

				If  cstatus == aEstru[nz,10] .OR. aEstru[nz,6] = 0

					Aadd(aDbTree,{cTexto,aEstru[nz,1],aEstru[nz,5],aEstru[nz,7],nz})
					oObjTree:AddTreeItem(cTexto,aOcorrencia[aEstru[nz,5]],aOcorrencia[aEstru[nz,5]],aEstru[nz,7])
					IncProc(cMsgProc)
					EndIF
			   EndIf
		ENDIF
	EndIf

	nz++
End


RETURN(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Mt200Nav  ³ Autor ³Rodrigo de A Sartorio  ³ Data ³ 04/11/2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mantem o posicionamento das duas estruturas      			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ Mt200Nav(ExpN1,Exp01,Exp02,ExpA1,ExpA2)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Codigo do Evento - 0 - Muda posicionamento           ³±±
±±³          ³                          - 1 - Desce Linha   - 2 - Sobe linha³±±
±±³          ³ Exp01 = Tree da origem da comparacao                         ³±±
±±³          ³ Exp02 = Tree do destino da comparacao                        ³±±
±±³          ³ ExpA1 = Array com os dados da estrutura origem da comparacao ³±±
±±³          ³ ExpA2 = Array com os dados da estrutura destino da comparacao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA200                                                       ³±±
±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Mt200Nav(nTipo,oTree,oTree2,aEstruOri,aEstruDest)
Local cCargoAtu  :=oTree2:GetCargo()
Local cCargoVazio:=Space(5+Len(SG1->G1_COMP+SG1->G1_TRT))
Local nPos       :=Ascan(aEstruDest,{|x| x[7] == cCargoAtu})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona o tree na linha de baixo                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 1 .And. nPos < Len(aEstruDest)
	oTree:TreeSeek(aEstruOri[nPos+1,7])
	oTree2:TreeSeek(aEstruDest[nPos+1,7])
	oTree:Refresh()
	oTree2:Refresh()
ElseIf nTipo == 2 .And. nPos >= 1
	oTree :TreeSeek(If(nPos-1<=0,cCargoVazio,aEstruOri[nPos-1,7]))
	oTree2:TreeSeek(If(nPos-1<=0,cCargoVazio,aEstruDest[nPos-1,7]))
	oTree:Refresh()
	oTree2:Refresh()
Else
	oTree:TreeSeek(If(nPos>0,aEstruOri[nPos,7],cCargoVazio))
	oTree2:TreeSeek(If(nPos>0,aEstruDest[nPos,7],cCargoVazio))
	oTree:Refresh()
	oTree2:Refresh()
EndIf
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Mt200Inf  ³ Autor ³Rodrigo de A Sartorio  ³ Data ³ 05/11/2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Legenda do comparador de estruturas                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                    	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA200                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Mt200Inf()
Local oDlg,oBmp1,oBmp2,oBmp3,oBmp4,oBmp5
Local oBut1
DEFINE MSDIALOG oDlg TITLE STR0049 OF oMainWnd PIXEL FROM 0,0 TO 200,550 //"Legenda"
@ 2,3 TO 080,273 LABEL STR0049 PIXEL //"Legenda"
@ 18,10 BITMAP oBmp1 RESNAME "PMSTASK1" SIZE 16,16 NOBORDER PIXEL
@ 18,20 SAY OemToAnsi(STR0048) OF oDlg PIXEL
@ 18,150 BITMAP oBmp2 RESNAME "PMSTASK6" SIZE 16,16 NOBORDER PIXEL
@ 18,160 SAY OemToAnsi(STR0047) OF oDlg PIXEL
@ 30,10 BITMAP oBmp3 RESNAME "PMSTASK2" SIZE 16,16 NOBORDER PIXEL
@ 30,20 SAY OemToAnsi(STR0046) OF oDlg PIXEL
@ 42,10 BITMAP oBmp4 RESNAME "PMSTASK5" SIZE 16,16 NOBORDER PIXEL
@ 42,20 SAY OemToAnsi(STR0045) OF oDlg PIXEL
@ 54,10 BITMAP oBmp5 RESNAME "PMSTASK4" SIZE 16,16 NOBORDER PIXEL
@ 54,20 SAY OemToAnsi(STR0044) OF oDlg PIXEL
DEFINE SBUTTON oBut1 FROM 085,244 TYPE 1  ACTION (oDlg:End())  ENABLE of oDlg
ACTIVATE MSDIALOG oDlg CENTERED
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  A200Subs  ³ Autor ³Rodrigo de A Sartorio³ Data ³23.06.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Substituicao de componentes na Estrutura                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A200Subs()

Local aArea    :=GetArea()
Local cCodOrig :=Criavar("G1_COMP" ,.F.),cCodDest :=Criavar("G1_COMP" ,.F.)
Local cGrpOrig :=Criavar("G1_GROPC",.F.),cGrpDest :=Criavar("G1_GROPC",.F.)
Local cDescOrig:=Criavar("B1_DESC" ,.F.),cDescDest:=Criavar("B1_DESC" ,.F.)
Local cOpcOrig :=Criavar("G1_OPC"  ,.F.),cOpcDest :=Criavar("G1_OPC"  ,.F.)
Local cSeqOrig :=Criavar("G1_TRT"  ,.F.)
Local oSay,oSay2
Local lOk:=.F.
Local aAreaSX3:=SX3->(GetArea())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variavel lPyme utilizada para Tratamento do Siga PyME        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lPyme:= Iif(Type("__lPyme") <> "U",__lPyme,.F.)
Local oSize
Local oSize2
Local oSize3
Local nI         := 0
Local nTamCod	 := tamSX3("G1_COMP")[1]
Local nTamgrpopc := tamSX3("G1_GROPC")[1]
Local nTamopc    := tamSX3("G1_OPC")[1]
Local nTamSeq    := tamSX3("G1_TRT")[1]
Local nPosCoOrig := ASCAN(aAutoCab,{|x| x[1] == "G1_CODORIG"})
Local nPosGrOrig := ASCAN(aAutoCab,{|x| x[1] == "G1_GRPORIG"})
Local nPosOpOrig := ASCAN(aAutoCab,{|x| x[1] == "G1_OPCORIG"})
Local nPosSqOrig := ASCAN(aAutoCab,{|x| x[1] == "G1_SEQORIG"})
Local nPosCoDest := ASCAN(aAutoCab,{|x| x[1] == "G1_CODDEST"})
Local nPosGrDest := ASCAN(aAutoCab,{|x| x[1] == "G1_GRPDEST"})
Local nPosOpDest := ASCAN(aAutoCab,{|x| x[1] == "G1_OPCDEST"})


IF !l200Auto
	dbSelectArea("SG1")
	DEFINE MSDIALOG oDlg FROM  140,000 TO 358,615 TITLE OemToAnsi(STR0050) PIXEL //"Substituicao de Componentes"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula dimensões Em linha                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSize := FwDefSize():New(.T.,,,oDlg)
	oSize:AddObject( "LABEL1" 	,  100, 50, .T., .T. ) // Totalmente dimensionavel
	oSize:AddObject( "LABEL2"   ,  100, 50, .T., .T. ) // Totalmente dimensionavel

	oSize:lProp 	:= .T. // Proporcional
	oSize:aMargins 	:= { 6, 6, 6, 6 } // Espaco ao lado dos objetos 0, entre eles 3

	oSize:Process() 	   // Dispara os calculos

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula dimensões Em Coluna                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSize2 := FwDefSize():New()

	oSize2:aWorkArea := oSize:GetNextCallArea( "LABEL1" )

	oSize2:AddObject( "ESQ",  100, 50, .T., .T. ) // Totalmente dimensionavel
	oSize2:AddObject( "DIR",  100, 50, .T., .T. ) // Totalmente dimensionavel

	oSize2:lLateral := .T.
	oSize2:lProp 	:= .T. // Proporcional
	oSize2:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

	oSize2:Process() 	   // Dispara os calculos

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula dimensões Em Coluna                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSize3 := FwDefSize():New()

	oSize3:aWorkArea := oSize:GetNextCallArea( "LABEL2" )

	oSize3:AddObject( "ESQ",  100, 50, .T., .T. ) // Totalmente dimensionavel
	oSize3:AddObject( "DIR",  100, 50, .T., .T. ) // Totalmente dimensionavel

	oSize3:lLateral := .T.
	oSize3:lProp 	:= .T. // Proporcional
	oSize3:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

	oSize3:Process() 	   // Dispara os calculos

	DEFINE SBUTTON oBtn FROM 800,800 TYPE 5 ENABLE OF oDlg
	@ oSize:GetDimension("LABEL1","LININI"), oSize:GetDimension("LABEL1","COLINI") TO oSize:GetDimension("LABEL1","LINEND"), oSize:GetDimension("LABEL1","COLEND") LABEL OemToAnsi(STR0051) OF oDlg PIXEL //"Componente Original"
	@ oSize:GetDimension("LABEL2","LININI"), oSize:GetDimension("LABEL2","COLINI") TO oSize:GetDimension("LABEL2","LINEND"), oSize:GetDimension("LABEL2","COLEND") LABEL OemToAnsi(STR0052) OF oDlg PIXEL //"Novo Componente"
	@ oSize2:GetDimension("ESQ","LININI")+10, oSize2:GetDimension("ESQ","COLINI")+30 MSGET cCodOrig   F3 "SB1" Picture PesqPict("SG1","G1_COMP") Valid NaoVazio(cCodOrig) .And. ExistCpo("SB1",cCodOrig) .And. A200IniDsc(1,oSay,cCodOrig,cCodDest) SIZE 105,09 OF oDlg PIXEL HASBUTTON

	If !lPyme
		@ oSize2:GetDimension("DIR","LININI")+10, oSize2:GetDimension("DIR","COLINI")+40 MSGET cGrpOrig   F3 "SGAPCP" Picture PesqPict("SG1","G1_GROPC") Valid Vazio(cGrpOrig) .Or. ExistCpo("SGA",cGrpOrig) SIZE 15,09 OF oDlg PIXEL HASBUTTON
		@ oSize2:GetDimension("DIR","LININI")+10, oSize2:GetDimension("DIR","COLINI")+120 MSGET cOpcOrig   Picture PesqPict("SG1","G1_OPC") Valid IF(!Empty(cGrpOrig),NaoVazio(cOpcOrig).And.ExistCpo("SGA",cGrpOrig+cOpcOrig),Vazio(cOpcOrig)) SIZE 15,09 OF oDlg PIXEL
	EndIf

	@ oSize3:GetDimension("ESQ","LININI")+10, oSize3:GetDimension("ESQ","COLINI")+30 MSGET cCodDest   F3 "SB1" Picture PesqPict("SG1","G1_COMP") Valid NaoVazio(cCodDest) .And. ExistCpo("SB1",cCodDest)  .And. A200IniDsc(2,oSay2,cCodDest,cCodOrig) SIZE 105,9 OF oDlg PIXEL HASBUTTON

	If !lPyme
		@ oSize3:GetDimension("DIR","LININI")+10, oSize3:GetDimension("DIR","COLINI")+40 MSGET cGrpDest   F3 "SGAPCP" Picture PesqPict("SG1","G1_GROPC") Valid Vazio(cGrpDest) .Or. ExistCpo("SGA",cGrpDest) SIZE 15,09 OF oDlg PIXEL HASBUTTON
		@ oSize3:GetDimension("DIR","LININI")+10, oSize3:GetDimension("DIR","COLINI")+120 MSGET cOpcDest   Picture PesqPict("SG1","G1_OPC") Valid IF(!Empty(cGrpDest),NaoVazio(cOpcDest).And.ExistCpo("SGA",cGrpDest+cOpcDest),Vazio(cOpcDest)) SIZE 15,09 OF oDlg PIXEL
	EndIf

	@ oSize2:GetDimension("ESQ","LININI")+24, oSize2:GetDimension("ESQ","COLINI")+33 SAY oSay Prompt cDescOrig SIZE 130,6 OF oDlg PIXEL
	@ oSize3:GetDimension("ESQ","LININI")+24, oSize3:GetDimension("ESQ","COLINI")+33 SAY oSay2 Prompt cDescDest SIZE 130,6 OF oDlg PIXEL
	@ oSize2:GetDimension("ESQ","LININI")+12, oSize2:GetDimension("ESQ","COLINI") SAY OemtoAnsi(STR0038)   SIZE 24,7  OF oDlg PIXEL //"Produto"

	If !lPyme
		@ oSize2:GetDimension("DIR","LININI")+12, oSize2:GetDimension("DIR","COLINI") SAY RetTitle("G1_GROPC") SIZE 42,13 OF oDlg PIXEL
		@ oSize2:GetDimension("DIR","LININI")+12, oSize2:GetDimension("DIR","COLINI")+85 SAY RetTitle("G1_OPC")   SIZE 30,7  OF oDlg PIXEL
	EndIf

	@ oSize3:GetDimension("ESQ","LININI")+12, oSize3:GetDimension("ESQ","COLINI") SAY OemToAnsi(STR0038)   SIZE 24,7  OF oDlg PIXEL //"Produto"

	If !lPyme
		@ oSize3:GetDimension("DIR","LININI")+12, oSize3:GetDimension("DIR","COLINI") SAY RetTitle("G1_GROPC") SIZE 42,13 OF oDlg PIXEL
		@ oSize3:GetDimension("DIR","LININI")+12, oSize3:GetDimension("DIR","COLINI")+85 SAY RetTitle("G1_OPC")   SIZE 30,7  OF oDlg PIXEL
	EndIf

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||Iif(A200SubOK(cCodOrig,cGrpOrig,cOpcOrig,cCodDest,cGrpDest,cOpcDest),(lOk:=.T.,oDlg:End()),lOk:=.F.)},{||(lOk:=.F.,oDlg:End())})
	// Processa substituicao dos componentes
	If lOk
		Processa({|| A200PrSubs(cCodOrig,cGrpOrig,cOpcOrig,cCodDest,cGrpDest,cOpcDest) })
	EndIf
Else

	//Os Campos de produto origem e destino devem ser preenchidos
	If nPosCoOrig >= 1 .And. nPosCoDest >= 1
		cCodOrig := PADR(aAutoCab[nPosCoOrig,2], nTamCod)
		cGrpOrig := PADR(aAutoCab[nPosGrOrig,2], nTamgrpopc)
		cOpcOrig := PADR(aAutoCab[nPosOpOrig,2], nTamopc)
		cCodDest := PADR(aAutoCab[nPosCoDest,2], nTamCod)
		cGrpDest := PADR(aAutoCab[nPosGrDest,2], nTamgrpopc)
		cOpcDest := PADR(aAutoCab[nPosOpDest,2], nTamopc)

		If nPosSqOrig > 0
			cSeqOrig := PADR(aAutoCab[nPosSqOrig,2], nTamSeq)
		Else
			cSeqOrig := Nil
		EndIf

		If A200SubOK(cCodOrig,cGrpOrig,cOpcOrig,cCodDest,cGrpDest,cOpcDest)
			A200PrSubs(cCodOrig,cGrpOrig,cOpcOrig,cCodDest,cGrpDest,cOpcDest,cSeqOrig)
		EndIF
	EndIf
EndIF


SX3->(RestArea(aAreaSX3))
RestArea(aArea)
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A200PrSubs  ³ Autor ³Rodrigo de A Sartorio³ Data ³23.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta markbowse para selecao e substituicao dos componentes³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200PrSubs(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do produto origem                           ³±±
±±³          ³ ExpC2 = Grupo de opcionais origem                          ³±±
±±³          ³ ExpC3 = Opcionais do produto origem                        ³±±
±±³          ³ ExpC4 = Codigo do produto destino                          ³±±
±±³          ³ ExpC5 = Grupo de opcionais destino                         ³±±
±±³          ³ ExpC6 = Opcionais do produto destino                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A200PrSubs(cCodOrig,cGrpOrig,cOpcOrig,cCodDest,cGrpDest,cOpcDest,cSeqOrig)
Local cFilSG1     := ""
Local cQrySG1     := ""
Local aIndexSG1   := {}
Local aBackRotina := MenuDef()//ACLONE(aRotina)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variavel lPyme utilizada para Tratamento do Siga PyME        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lPyme:= Iif(Type("__lPyme") <> "U",__lPyme,.F.)
Local lRevAut := SuperGetMv("MV_REVAUT",.F.,.F.)
Local oTrocaSg1
Local nI
Local cQuery
Local aFields 			:= {}
Local aCampos			:= {}
Local aStruct			:= {}
Local nCont				:= 0
Local aSeek             := {}
Local aFieFilter        := {}
Local lRvSBZ		    := lPCPREVATU .And. SuperGetMV("MV_ARQPROD",.F.,"SB1") == 'SBZ'

Private cAliasQry 		:= ""
PRIVATE cAliasTemp 	  	:= ""

Default cSeqOrig := Nil

PRIVATE cCodOrig2  := cCodOrig
PRIVATE aDadosOrig := {cCodOrig,cGrpOrig,cOpcOrig,cSeqOrig}

PRIVATE aDadosDest:= {cCodDest,cGrpDest,cOpcDest}
PRIVATE cMarca200 := ThisMark()
PRIVATE cCadastro := OemToAnsi(STR0050)
PRIVATE aRotina   := {  {STR0053,"A200DoSub", 0 , 1}} //"Substituir"
Private oMark


if !l200Auto

	cAliasQry 		:= GetNextAlias()
	cAliasTemp 	  	:= GetNextAlias()
	oTrocaSg1 		:= FWTemporaryTable():New(cAliasTemp)

	//Campos da Tabela Temporaria
	aCampos :=  {;
				{"G1_OK"		,"C", TAMSX3("G1_OK")[1]		,0						},;
				{"G1_FILIAL"	,"C", TAMSX3("G1_FILIAL")[1]	,TAMSX3("G1_FILIAL")[2]	},;
				{"G1_COD"		,"C", TAMSX3("G1_COD")[1]		,TAMSX3("G1_COD")[2]	},;
				{"G1_DESC"		,"C", TAMSX3("G1_DESC")[1]		,TAMSX3("G1_DESC")[2]	},;
				{"G1_COMP"		,"C", TAMSX3("G1_COMP")[1]		,TAMSX3("G1_COMP")[2]	},;
				{"G1_DESC2"		,"C", TAMSX3("G1_DESC")[1]		,TAMSX3("G1_DESC")[2]	},;
				{"G1_TRT"		,"C", TAMSX3("G1_TRT")[1]		,TAMSX3("G1_TRT")[2]	},;
				{"G1_QUANT"		,"N", TAMSX3("G1_QUANT")[1]		,TAMSX3("G1_QUANT")[2]	},;
				{"G1_PERDA"		,"N", TAMSX3("G1_PERDA")[1]	    ,TAMSX3("G1_PERDA")[2]	},;
				{"G1_POTENCI"	,"N", TAMSX3("G1_POTENCI")[1]	,TAMSX3("G1_POTENCI")[2]},;
				{"G1_REC"		,"N", 8							,0						}}

	For nI := 2 to Len(aCampos)-1
		If aCampos[nI][1] == "G1_DESC2"
			Aadd(aFieFilter,{aCampos[nI][1], RetTitle('G1_DESC'), aCampos[nI][2], aCampos[nI][3], aCampos[nI][4], X3Picture('G1_DESC')})
		Else
			Aadd(aFieFilter,{aCampos[nI][1], RetTitle(aCampos[nI][1]), aCampos[nI][2], aCampos[nI][3], aCampos[nI][4], X3Picture(aCampos[nI][1])})
		EndIf
	Next

	//Campos que vão aparecer na GRID.
	aFieldG :=  {;
				{STR0113		,"G1_FILIAL"	,"C", TAMSX3("G1_FILIAL")[1]	,TAMSX3("G1_FILIAL")[2]	,""},;  //"Filial"
				{STR0107		,"G1_COD"		,"C", TAMSX3("G1_COD")[1]		,TAMSX3("G1_COD")[2]	,""},;  //"Codigo"
				{STR0112		,"G1_DESC"		,"C", TAMSX3("G1_DESC")[1]		,TAMSX3("G1_DESC")[2]	,""},;  //"Descrição"
				{STR0010 		,"G1_COMP"		,"C", TAMSX3("G1_COMP")[1]		,TAMSX3("G1_COMP")[2]	,""},;  //"Componente"
				{STR0112		,"G1_DESC2"		,"C", TAMSX3("G1_DESC")[1]		,TAMSX3("G1_DESC")[2]	,""},;  //"Descrição"
				{STR0108		,"G1_TRT"		,"C", TAMSX3("G1_TRT")[1]		,TAMSX3("G1_TRT")[2]	,""},;  //"Sequencia"
				{STR0109		,"G1_QUANT"		,"N", TAMSX3("G1_QUANT")[1]		,TAMSX3("G1_QUANT")[2]	,""},;  //"Quantidade"
				{STR0110		,"G1_PERDA"		,"N", TAMSX3("G1_PERDA ")[1]	,TAMSX3("G1_PERDA")[2]	,""},;  //"Indice Perda"
				{STR0111		,"G1_POTENCI"	,"N", TAMSX3("G1_POTENCI")[1]	,TAMSX3("G1_POTENCI")[2],""}}   //"Potencia"

	oTrocaSg1:SetFields( aCampos )
	oTrocaSg1:AddIndex("IND", {"G1_FILIAL","G1_COD","G1_COMP"} )

	oTrocaSg1:Create()
	cQuery := " SELECT G1_FILIAL, G1_COD, G1_COMP, G1_TRT, G1_QUANT, G1_PERDA, G1_POTENCI, R_E_C_N_O_ REC  "
	cQuery += " FROM "+ RETSQLNAME("SG1") + " SG1 "
	cQuery += " WHERE " + RetSqlCond("SG1")
	cQuery += " And G1_COMP='"+cCodOrig+"'"

	If !lPyme
		cQuery += " And G1_GROPC='"+cGrpOrig+"'"
		cQuery += " And G1_OPC='"+cOpcOrig+"'"
	EndIf

	If !IsProdProt(cCodOrig) .And. !IsProdProt(cCodDest)
		cQuery += " And 1 = 1 "
	Else
		cQuery += " And 1 = 2 "
	Endif

	If  lRvSBZ // revisao pela sbz
		cQuery += " AND (SELECT COUNT(*) FROM "+RetSqlName('SBZ')+" SBZ WHERE BZ_COD=G1_COD AND (BZ_REVATU=G1_REVFIM OR G1_REVFIM='ZZZ') AND "
		cQuery +=  RetSqlCond("SBZ") +   ") > 0"
	Else
		cQuery += " AND (SELECT COUNT(*) FROM "+RetSqlName('SB1')+" SB1 WHERE B1_COD=G1_COD AND (B1_REVATU=G1_REVFIM OR G1_REVFIM='ZZZ') AND "
		cQuery +=  RetSqlCond("SB1") +   ") > 0"
	EndIf

	MPSysOpenQuery( cQuery, cAliasQry )

	DbSelectArea(cAliasQry)

	while (cAliasQry)->(!eof())

		RECLOCK(cAliasTemp, .T.)
			REPLACE (cAliasTemp)->G1_FILIAL		WITH 	(cAliasQry)->G1_FILIAL
			REPLACE (cAliasTemp)->G1_COD		WITH 	(cAliasQry)->G1_COD
			REPLACE (cAliasTemp)->G1_COMP		WITH 	(cAliasQry)->G1_COMP
			REPLACE (cAliasTemp)->G1_DESC		WITH 	POSICIONE('SB1',1,XFILIAL('SB1')+(cAliasQry)->G1_COD,'B1_DESC')
			REPLACE (cAliasTemp)->G1_DESC2		WITH 	POSICIONE('SB1',1,XFILIAL('SB1')+(cAliasQry)->G1_COMP,'B1_DESC')
			REPLACE (cAliasTemp)->G1_TRT		WITH 	(cAliasQry)->G1_TRT
			REPLACE (cAliasTemp)->G1_QUANT		WITH 	(cAliasQry)->G1_QUANT
			REPLACE (cAliasTemp)->G1_PERDA		WITH 	(cAliasQry)->G1_PERDA
			REPLACE (cAliasTemp)->G1_POTENCI	WITH 	(cAliasQry)->G1_POTENCI
			REPLACE (cAliasTemp)->G1_REC		WITH 	(cAliasQry)->REC
		(cAliasTemp)->(MSUNLOCK())

		(cAliasQry)->(dbskip())
	Enddo

	dbSelectArea(cAliastemp)
	dbSetOrder(1)
	dbGoTop()

	If (cAliastemp)->(Eof())
		HELP(" ",1,"RECNO")
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta o browse para a selecao                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//MarkBrow("SG1","G1_OK",,,,,,,,,,,cQrySG1,,,,,cFilSG1)
		Aadd(aSeek,{STR0116 , {{"","C",TAMSX3("G1_COD")[1]+TAMSX3("G1_COMP")[1]+TAMSX3("G1_TRT")[1],0, "G1_COD + G1_COMP + G1_TRT",""}}, 1, .T. } ) //"Código + Componente + Sequência"
		Aadd(aSeek,{STR0117 , {{"","C",TAMSX3("G1_COMP")[1]+TAMSX3("G1_COD")[1],0, "G1_COMP + G1_COD",}} , 2, .T. } ) //"Componente + Código"
		Aadd(aSeek,{STR0118 , {{"","C",TAMSX3("G1_COD")[1]+TAMSX3("G1_TRT")[1],0, "G1_COD + G1_TRT ",}} , 3, .T. } ) //"Código + Sequência"

		oMark := FWMarkBrowse():New()
		oMark:SetAlias(cAliastemp)
		oMark:SetTemporary(.T.)
		oMark:SetDescription( OemToAnsi(STR0050) )
		oMark:SetFieldMark("G1_OK")
		oMark:SetFields(aFieldG)
		oMark:SetAllMark({|| a200AllMark()})
		oMark:SetSeek(.T.,aSeek)
		oMark:SetFieldFilter(aFieFilter)		
		oMark:Activate()

	EndIf
else
	A200DoSub()
Endif


aRotina:=ACLONE(aBackRotina)

//---------------------------------------------------
//Exclui o objeto da tabela temporaria do MarkBrowse
// e Areas criadas
//---------------------------------------------------
if !l200Auto
	oTrocaSg1:Delete()
	(cAliasQry)->(dbCloseArea())
endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A200DoSub   ³ Autor ³Rodrigo de A Sartorio³ Data ³23.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava a substituicao dos componentes                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200DoSub(ExpC1,ExpN1,ExpN2,ExpC2,ExpC3,ExpL1)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo	              (OPC)               ³±±
±±³          ³ ExpN1 = Numero do registro             (OPC)               ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada    (OPC)               ³±±
±±³          ³ ExpC2 = Marca para substituicao                            ³±±
±±³          ³ ExpL1 = Inverte marcacao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A200DoSub(cAlias,nRecno,nOpc,cMarca200,lInverte)
Local aAreaSG1  := {}
Local aAreaSGF  := SGF->(GetArea())
Local aAtualiza := {}
Local aDadosInt := {}
Local aErrEstrut:= {}
Local aOrdens   := {}
Local aRecnoSEM := {}
Local aRecnosSGF:= {}
Local cAliasRev := ""
Local cCodPai   := ""
Local cFilSG1   := ""
Local cFiltro   := ""
Local cLocal
Local cLocProc  := GetMvNNR('MV_LOCPROC','99')
Local cMsg      := ""
Local cQuery    := ''
Local cQuery2   := ''
Local cRevProd  := ""
Local cTRT      := ''
Local cProdPai
Local lAltEmp   := .F.
Local lAtualiza := .F.
Local lBkpAlt   := ALTERA
Local lBkpInc   := INCLUI
Local lProc     := .F.
Local lRet      := .F.
Local lRevAut   := SuperGetMv("MV_REVAUT",.F.,.F.)
Local nError    := 0
Local nI        := 0
Local nJ        := 0
Local nPos      := 0
Local nQuant    := 0
Local nRecnoSGF
Local nSucess   := 0
Local nTotal    := 0
Local nz        := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variavel lPyme utilizada para Tratamento do Siga PyME        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lPyme:= Iif(Type("__lPyme") <> "U",__lPyme,.F.)

Local aRectemp  := {}
Local cAliasQry := Nil
Local cCodOrig  :=Criavar("G1_COMP",.F.),cCodDest:=Criavar("G1_COMP",.F.)
Local cMark     := ""
Local cOpcOrig  :=Criavar("C2_OPC",.F.),cGrpOrig := ''
Local ntemp     := 0


Private aIntegPPI   := {}
Private aRecnosSG1  := {}
Private cAliasTmp   := GetNextAlias()
Private lRvSBZ      := lPCPREVATU .And. SuperGetMV("MV_ARQPROD",.F.,"SB1") == 'SBZ' // Validade se utiliza Revisao pela tabela SBZ


If Type("lMsErroAuto") == "U"
	Private lMsErroAuto := .F.
EndIF

Pergunte('MTA200', .F.)

If l200Auto
	lRet := .T.
	For nI := 1 to len(aAutoItens)

		SG1->(dbSetOrder(2))
		If SG1->(dbSeek(xFilial("SG1")+aDadosOrig[1]+aAutoItens[nI,2]))
			While SG1->(!Eof()) .And. SG1->G1_FILIAL == xFilial("SG1") .And. SG1->G1_COMP == aDadosOrig[1] .And. SG1->G1_COD == aAutoItens[nI,2]

				If aDadosOrig[4] != Nil .And. SG1->G1_TRT != aDadosOrig[4]
					SG1->(dbSkip())
					Loop
				EndIf

				lRet := a200VldOper(aRecnosSGF,aRecnoSEM)
				If !lRet
					Exit
				EndIf

				AADD(aRecnosSG1,SG1->(Recno()))
				SG1->(dbSkip())
			EndDo
			If !lRet
				Exit
			EndIf
		Endif
	Next nI
Else

	SGF->(dbSetOrder(2))

	dbSelectArea(cAliastemp)
	(cAliastemp)->(dbgotop())
	//SG1->(dbSeek(xFilial("SG1")))
	cMark := oMark:Mark()
	While (cAliastemp)->(!Eof()) .And. (cAliastemp)->G1_FILIAL == xFilial("SG1")
		// Verifica os registros marcados para substituicao
		If (cAliastemp)->G1_OK == cMark
			lRet := .T.
			SG1->(DbGoTo((cAliastemp)->G1_REC))
			lRet := a200VldOper(aRecnosSGF,aRecnoSEM)

			If !lRet
				Exit
			EndIf

			AADD(aRecnosSG1,(cAliastemp)->G1_REC )  // Itens Alterados
			AADD(aRectemp,(cAliastemp)->(RECNO()) ) // Guarda Itens Alterados para excluir da temporaria quando reabrir o MarkBrowse
		EndIf
		(cAliastemp)->(dbSkip())
	EndDo

EndIf

If lRet

	For nz := 1 to Len(aRecnoSEM)
		SG1->(dbGoTo(aRecnoSEM[nz]))

		dbSelectArea('SC2')
		SC2->(dbSetOrder(2))
		if SC2->(dbSeek(xFilial('SC2')+SG1->G1_COD))
			While SC2->(!Eof()) .AND. SC2->C2_PRODUTO == SG1->G1_COD

				if A650DefLeg(1) .OR. A650DefLeg(2) // Prevista ou em aberto
					dbSelectArea('SD4')
					SD4->(dbSetOrder(1))
					IF SD4->(dbSeek(xFilial('SD4')+SG1->G1_COMP+Padr(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,TamSX3('D4_OP')[1])+SG1->G1_TRT))
						While SD4->(!EOF()) .AND. SD4->D4_COD == SG1->G1_COMP .AND.;
														SD4->D4_OP == Padr(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,TamSX3('D4_OP')[1]) .AND.;
														SD4->D4_TRT == SG1->G1_TRT

							nResult := aScan(aOrdens,{|x| x[2] == SD4->D4_OP})

							if nResult == 0
								aAdd(aOrdens,{.T.,SD4->D4_OP, SC2->C2_PRODUTO, {SD4->(Recno())}, .F., SG1->(Recno())})
							Else
								aadd(aOrdens[nResult][4],SD4->(Recno()))
							Endif

							SD4->(dbSkip())
						End
					Endif
				Endif

				SC2->(dbSkip())
			End
		Endif
	Next

	// Grava a substituicao de componentes
	IF !lRevAut
		fGravaSubs(@aErrEstrut,@aAtualiza)
	Else
		dbSelectArea("SG1")
		cFiltro := SG1->(dbFilter())
		SG1->(dbClearFilter())

		For nz:=1 to Len(aRecnosSG1)
			//POSICIONA NO REGISTRO DA SG1 PARA PEGAR O PRODUTO PAI E AS INFORMAÇÕES PARA GRAVAR O REGISTRO NOVO
			SG1->(dbGoto(aRecnosSG1[NZ]))

			//PELO PRODUTO PAI, POSICIONA A SB1, SALVA O VALOR DA REVISÃO E INCREMENTA
			SB1->(dbSeek(xFilial("SB1")+SG1->G1_COD))

			//PEGA REVISÃO
			cRevProd :=IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU) //SB1->B1_REVATU
			cGrpOrig := aDadosDest[2]
			cCodOrig := cCodOrig2
			cOpcOrig := aDadosDest[3]
			cCodDest := aDadosDest[1]

			If SG1->(dbSeek(xFilial("SG1")+SB1->B1_COD+aDadosDest[1]+SG1->G1_TRT))
				If SG1->G1_REVFIM >= cRevProd
					//Se já existir o componente origem na estrutura, não faz a alteração.
					AADD(aErrEstrut, {SG1->G1_COD,STR0098,SG1->(Recno())}) //"Componente já Cadastrado na Estrutura."
					Loop
				EndIf
			EndIf
			//Retorna para o registro correto da SG1.
			SG1->(dbGoto(aRecnosSG1[NZ]))

			IF lPCPREVTAB
				PCPREVTAB(SB1->B1_COD,Soma1(cRevProd) )
			ELSE
		    	//ATUALIZA REVISÃO DA SB1
				Reclock("SB1",.F.)
					Replace B1_REVATU With Soma1(cRevProd)
				MsUnlock()
			ENDIF


			aadd(aAtualiza,aRecnosSG1[NZ])

			//PEGA INFORMAÇÕES DA SG1 PARA CRIAR NOVO REGISTRO
			aDadosG1 := {SG1->G1_COD,;
				         aDadosDest[1],;
				         SG1->G1_TRT,;
				         SG1->G1_QUANT,;
				         SG1->G1_PERDA,;
				         SG1->G1_INI,;
				         SG1->G1_FIM,;
				         SG1->G1_OBSERV,;
				         SG1->G1_FIXVAR,;
				         aDadosDest[2],;
				         aDadosDest[3],;
				         Soma1(cRevProd),;
				         Soma1(cRevProd),;
				         SG1->G1_NIV,;
				         SG1->G1_NIVINV,;
				         SG1->G1_POTENCI,;
				         SG1->G1_OK,;
				         SG1->G1_VECTOR,;
				         SG1->G1_TIPVEC,;
				         SG1->G1_VLCOMPE}


			//ATUALIZA A REVISAO FINAL DOS DEMAIS COMPONENTES

			cQuery := " SELECT SG1.R_E_C_N_O_ G1REC "
			cQuery +=   " FROM " + RetSqlName("SG1") + " SG1 "
			cQuery +=  " WHERE SG1.D_E_L_E_T_ = ' ' "
			cQuery +=    " AND SG1.G1_FILIAL = '" + xFilial("SG1") + "' "
			cQuery +=    " AND SG1.G1_COD    = '" + aDadosG1[1] + "' "
			cQuery +=    " AND SG1.R_E_C_N_O_ <> " + cValToChar(aRecnosSG1[NZ])

			cQuery := ChangeQuery(cQuery)

			cAliasRev := GetNextAlias()

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRev,.T.,.T.)

			While (cAliasRev)->(!Eof())
				SG1->(dbGoTo((cAliasRev)->(G1REC)))

				If SG1->(RecNo()) == aRecnosSG1[NZ] .Or. SG1->G1_REVFIM != cRevProd
					(cAliasRev)->(dbSkip())
					Loop
				EndIf

				Reclock("SG1",.F.)
					Replace SG1->G1_REVFIM With aDadosG1[13]
				SG1->(MsUnlock())

				(cAliasRev)->(dbSkip())
			End
			(cAliasRev)->(dbCloseArea())

			A200RevisG5(aDadosG1[1],,lRevAut)
			//CRIA UM REGISTRO COM O COMPONENTE DESTINO, COM REVISAO INICIAL IGUAL A NOVA REVISAO CRIADA
			Reclock("SG1",.T.)
				Replace G1_FILIAL  With xFilial("SG1")
				Replace G1_COD     With aDadosG1[1]
				Replace G1_COMP    With aDadosG1[2]
				Replace G1_TRT     With aDadosG1[3]
				Replace G1_QUANT   With aDadosG1[4]
				Replace G1_PERDA   With aDadosG1[5]
				Replace G1_INI     With aDadosG1[6]
				Replace G1_FIM     With aDadosG1[7]
				Replace G1_OBSERV  With aDadosG1[8]
				Replace G1_FIXVAR  With aDadosG1[9]
				Replace G1_GROPC   With aDadosG1[10]
				Replace G1_OPC     With aDadosG1[11]
				Replace G1_REVINI  With aDadosG1[12]
				Replace G1_REVFIM  With aDadosG1[13]
				Replace G1_NIV     With aDadosG1[14]
				Replace G1_NIVINV  With aDadosG1[15]
				Replace G1_POTENCI With aDadosG1[16]
				Replace G1_OK      With aDadosG1[17]
				Replace G1_VECTOR  With aDadosG1[18]
				Replace G1_TIPVEC  With aDadosG1[19]
				Replace G1_VLCOMPE With aDadosG1[20]
				cGrpOrig := aDadosG1[10]
				cCodOrig := cCodOrig2
				cOpcOrig := aDadosG1[11]
				cCodDest := aDadosG1[2]
			MsUnlock()
		Next nz

		//SG1->(dbSetFilter({||&cFiltro},cFiltro))
		cFilSG1 := cFiltro
		If !l200Auto
			oMark:Refresh()
		EndIF
	EndIF

	Pergunte('MTA200',.F.)

	cFilSG1 := cFiltro
	IF !l200Auto
		oMark:Refresh()
	EndIf

	// Grava a substituicao de componentes na tabela SGF
	dbSelectArea("SGF")
	if Len(aRecnosSGF) > 0
		For nz:=1 to Len(aRecnosSGF)
			SGF->(dbGoto(aRecnosSGF[NZ]))

			// Verificar os empenhos das ordens de produção em aberto
			IF CVALTOCHAR(MV_PAR04) == '1'
				dbSelectArea("SD4")

				cAlias  := GetNextAlias()

				If AllTrim(Upper(TcGetDb())) $ "|POSTGRES|ORACLE|DB2|"
					BeginSql Alias cAlias
						SELECT SD4.D4_OP, SC2.C2_PRODUTO, SC2.R_E_C_N_O_, SD4.R_E_C_N_O_ SD4RECNO FROM %Table:SD4% SD4
						INNER JOIN %Table:SC2% SC2 ON SD4.D4_OP = SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN
						WHERE SC2.C2_FILIAL  = %Exp:SGF->GF_FILIAL% AND
							  SC2.C2_PRODUTO = %Exp:SGF->GF_PRODUTO% AND
							  SD4.D4_COD     = %Exp:SGF->GF_COMP% AND
							  SD4.D4_TRT     = %Exp:SGF->GF_TRT% AND
							  SC2.%NotDel%
					EndSql

				Else
					BeginSql Alias cAlias
						SELECT SD4.D4_OP, SC2.C2_PRODUTO, SC2.R_E_C_N_O_, SD4.R_E_C_N_O_ SD4RECNO FROM %Table:SD4% SD4
						INNER JOIN %Table:SC2% SC2 ON SD4.D4_OP = SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN
						WHERE SC2.C2_FILIAL  = %Exp:SGF->GF_FILIAL% AND
							  SC2.C2_PRODUTO = %Exp:SGF->GF_PRODUTO% AND
							  SD4.D4_COD     = %Exp:SGF->GF_COMP% AND
							  SD4.D4_TRT     = %Exp:SGF->GF_TRT% AND
							  SC2.%NotDel%
					EndSql
				EndIf

				While (cAlias)->(!EOF())
					SC2->(dbGoTo((cAlias)->R_E_C_N_O_))

					if A650DefLeg(1) .OR. A650DefLeg(2) // Prevista ou em aberto
						nResult := aScan(aOrdens,{|x| x[2] == (cAlias)->D4_OP})

						if nResult == 0
							aAdd(aOrdens,{.T.,(cAlias)->D4_OP, (cAlias)->C2_PRODUTO, {(cAlias)->SD4RECNO}, .F., SG1->(Recno())})
						Else
							aadd(aOrdens[nResult][4],(cAlias)->SD4RECNO)
						Endif
					Endif

					(cAlias)->(dbSkip())
				End

				(cAlias)->(dbCloseArea())
			EndIf

			Reclock("SGF",.F.)
				Replace SGF->GF_COMP With aDadosDest[1]
			MsUnlock()
		Next nz

		If PCPIntgPPI()
			ALTERA := .T.
			INCLUI := .F.
			cFiltro := SG1->(dbFilter())
			SG1->(dbClearFilter())
			SG1->(dbSetOrder(1))
			For nz:=1 to Len(aRecnosSG1)
				SG1->(dbGoto(aRecnosSG1[nz]))
				//Verifica se deve ser processado. (filtros)
				cCodPai := SG1->G1_COD
				lProc := .F.
				SG1->(dbSeek(xFilial("SG1")+SG1->G1_COD)) //Posiciona no primeiro componente
				While SG1->(!Eof()) .And. SG1->(G1_FILIAL+G1_COD) == xFilial("SG1")+cCodPai
					If PCPFiltPPI("SG1", SG1->G1_COD, "SG1")
						lProc := .T.
						Exit
					EndIf
					SG1->(dbSkip())
				End
				If lProc
					nTotal++
					If MATA200PPI(, SG1->G1_COD, .F., .F., .T.)
						nSucess++
						aAdd(aDadosInt, {SG1->G1_COD,"", STR0062, STR0082}) //"OK" // "Processado com sucesso"
					Else
						nError++
					EndIf
				EndIf
			Next nz

			If Len(aIntegPPI) > 0
				For nz := 1 To Len(aIntegPPI)
					aAdd(aDadosInt, {aIntegPPI[nz,1], "", STR0083, aIntegPPI[nz,2]}) //"Erro"
				Next nz
				For nz := 1 To Len(aDadosInt)
					aDadosInt[nz,2] := POSICIONE('SB1',1,XFILIAL('SB1')+aDadosInt[nz,1],'B1_DESC')
				Next nz

				erroPPI(aDadosInt, nTotal, nSucess, nError)
			EndIf

			IF !l200Auto
				oMark:Refresh()
			EndIf
			ALTERA := lBkpAlt
			INCLUI := lBkpInc
		EndIf
	EndIf

	// Replicar alteração para os empenhos da ordem
	IF Len(aOrdens) > 0

		// Eliminar ordens que não tiveram SG1 atualizado
		For nI := Len(aOrdens) to 1 Step - 1
			nResult := ASCAN(aAtualiza,aOrdens[nI][6])

			if nResult == 0
				ADEL(aOrdens, nI)
				ASIZE(aOrdens, Len(aOrdens)-1)
			Endif
		Next

		aMata380 := {}
		nQuant   := 0

		If !l200Auto
			If Len(aOrdens) > 0 .And. MATA637LIS(aOrdens)
				lAltEmp := .T.
			EndIF
		else
			nPos :=	aScan(aAutoCab,{|x| x[1] == "ALTEMPENHO"})
			If ( nPos > 0 .And. aAutoCab[nPos,2] == "S" .And. Len(aOrdens) > 0)
				lAltEmp	:= .T.
			Else
				lAltEmp	:= .F.
			EndIf
		EndIF

		if lAltEmp

			For nI := 1 to Len(aOrdens)

				if aOrdens[nI][1] == .T.

					nQuant := 0
					aMata380 := {}

					For nJ := 1 to Len(aOrdens[nI][4])

						SD4->(dbGoTo(aOrdens[nI][4][nJ]))

						nQuant  += SD4->D4_QUANT
						cTRT    := SD4->D4_TRT
						cProdPai:= SD4->D4_PRODUTO

						aAdd( aMata380, {{'D4_OP'     , SD4->D4_OP     , Nil}, ;
										 {'D4_COD'    , SD4->D4_COD    , Nil}, ;
										 {'D4_TRT'    , SD4->D4_TRT    , Nil}, ;
										 {'D4_LOTECTL', SD4->D4_LOTECTL, Nil}, ;
										 {'D4_NUMLOTE', SD4->D4_NUMLOTE, Nil}})

						MsExecAuto( { |x,y| MATA380(x,y) }, aMata380[1] , 5 )
						If lMsErroAuto
							MostraErro()
						EndIf

						aMata380 := {}

					Next

					dbSelectArea('SB1')
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial('SB1')+aDadosDest[1]))

					cLocal := If(SB1->B1_APROPRI=="I",cLocProc,SB1->B1_LOCPAD)

					dbSelectArea('SC2')
					SC2->(dbSetOrder(1))
					SC2->(dbSeek(xFilial('SC2')+aOrdens[nI][2]))

					aMata380 := {}

					dbSelectArea('SB2')
					SB2->(dbSetOrder(1))
					if !SB2->(dbSeek(xFilial("SB2")+aDadosDest[1]+cLocal))
						CriaSB2(aDadosDest[1],cLocal)
					Endif

					aAdd( aMata380, {{'D4_OP'    , aOrdens[nI][2], Nil}, ;
									 {'D4_COD'    , aDadosDest[1] , Nil},;
									 {'D4_LOCAL'  , cLocal        , Nil},;
									 {'D4_QTDEORI', nQuant        , Nil},;
									 {'D4_QUANT'  , nQuant        , Nil},;
									 {'D4_DATA'   , SC2->C2_DATPRI, Nil},;
									 {'D4_TRT'    , cTRT          , Nil},;
									 {'D4_PRODUTO', cProdPai      , Nil}})

					MsExecAuto( { |x,y| MATA380(x,y) }, aMata380[1] , 3 )
					If lMsErroAuto
							MostraErro()
					EndIf
				EndIf
			Next
		Endif
	EndIf

	dbSelectArea("SG1")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| M200SUB - Ponto de entrada executado apos a gravacao  |
	//|           da substituicao dos componentes             |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("M200SUB")
		ExecBlock("M200SUB",.F.,.F.,aRecnosSG1)
	EndIf

	// Altera conteudo do parametro de niveis
	If Len(aRecnosSG1) > 0
		a200NivAlt()
	EndIf

EndIf


SGF->(RestArea(aAreaSGF))

	If Len(aErrEstrut) > 0
		A200ErrStr(aErrEstrut)
	EndIf
	If lRet .And. !l200Auto

		//Apaga Itens da Temporaria para nao aparecer novamente na query.
		if len(aRectemp) > 0
			for ntemp := 1 to len(aRectemp)
				If aScan(aErrEstrut , {|x| aRectemp[ntemp] }) == 0
					(cAliastemp)->(dbgoto(aRectemp[ntemp]) )
					RECLOCK(cAliastemp, .F.)
						(cAliastemp)->(dbDelete())
					(cAliastemp)->(MSUNLOCK())
				EndIf
			Next ntemp
			oMark:Refresh()
		Endif

		/*DMANSMARTSQUAD1-22885
		Retirada a reabertura do FWMarkBrowse por problemas no logprofile.		
		*/
		oMark:Refresh()
EndIf
	
Return

/*/{Protheus.doc} fGravaSubs
	@type  Static Function
	@author mauricio.joao
	@since 19/11/2020
	@version 1.0
/*/
Static Function fGravaSubs(aErrEstrut,aAtualiza)
Local nz as numeric

	cGrpOrig := aDadosDest[2]
	cCodOrig := cCodOrig2
	cOpcOrig := aDadosDest[3]
	cCodDest := aDadosDest[1]
	If Len(aRecnosSG1) < 1001 .And. Len(aRecnosSG1) > 0  //tratamento para oracle pois tem limite de 1000 itens no "IN"
		cQuery2 := " WHERE G1_COD <> '"+aDadosDest[1]+"' AND R_E_C_N_O_ IN ("
		For nz:=1 to Len(aRecnosSG1)
			If nz > 1
				cQuery2+= ","
			EndIf
			cQuery2+= "'"+Str(aRecnosSG1[nz],10,0)+"'"
		Next nz
		cQuery2 += ")"

		// Primeiro busca os registros que serão alterados
		cQuery := "SELECT SG1.G1_COD, SG1.R_E_C_N_O_, "
		If "G1_REVINI+G1_REVFIM" $ FWX2Unico("SG1")
			cQuery += " (SELECT COUNT(SG12.G1_COD) "
			cQuery += "    FROM " + RetSqlName("SG1") + " SG12 "

			If  lRvSBZ // revisao pela sbz
				cQuery += "	LEFT JOIN " + RetSqlName("SBZ") + " SBZ ON SBZ.BZ_FILIAL = '" + xFilial('SBZ')+ "'  AND SBZ.D_E_L_E_T_ = ' ' "
			Else
				cQuery += "	LEFT JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial('SB1')+ "' AND SB1.D_E_L_E_T_ = ' ' "
			EndIf
			cQuery += "   WHERE SG12.G1_FILIAL  = '" + xFilial('SG1')+ "' "
			cQuery += "     AND SG12.G1_COD     = SG1.G1_COD "
			cQuery += "     AND SG12.G1_COMP    = '"+aDadosDest[1]+"' "
			cQuery += "     AND SG12.G1_TRT     = SG1.G1_TRT "

			IF lRvSBZ
				cQuery += " 	AND SBZ.BZ_COD = SG1.G1_COD "
			ELSE
				cQuery += " 	AND SB1.B1_COD = SG1.G1_COD "
			ENDIF

			cQuery += " 	  AND SG12.D_E_L_E_T_ = ' ' "
			If lRvSBZ // revisao pela sbz
				cQuery += "	AND SBZ.BZ_REVATU BETWEEN SG12.G1_REVINI AND SG12.G1_REVFIM "
			Else
				cQuery += "	AND SB1.B1_REVATU BETWEEN SG12.G1_REVINI AND SG12.G1_REVFIM "
			EndIf
			cQuery += "	) EXISTE "
		Else
			cQuery += " (SELECT COUNT(SG12.G1_COD) "
			cQuery += "    FROM " + RetSqlName("SG1") + " SG12 "
			cQuery += "   WHERE SG12.G1_FILIAL  = '" + xFilial('SG1')+ "' "
			cQuery += "     AND SG12.G1_COD     = SG1.G1_COD "
			cQuery += "     AND SG12.G1_COMP    = '"+aDadosDest[1]+"' "
			cQuery += "     AND SG12.G1_TRT     = SG1.G1_TRT "
			cQuery += " 	  AND SG12.D_E_L_E_T_ = ' ' "
			cQuery += "	) EXISTE "
		EndIf
		cQuery += "FROM " + RetSqlName("SG1") + " SG1 "
		cQuery += cQuery2

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

		While (cAliasTmp)->(!EOF())

			If (cAliasTmp)->EXISTE > 0
				AADD(aErrEstrut, {(cAliasTmp)->G1_COD,STR0098,(cAliasTmp)->R_E_C_N_O_}) //"Componente já Cadastrado na Estrutura."
				(cAliasTmp)->(dbSkip())
				Loop
			EndIf
			aadd(aAtualiza,(cAliasTmp)->R_E_C_N_O_)

			(cAliasTmp)->(dbSkip())
		End

		(cAliasTmp)->(dbCloseArea())

		If Len(aAtualiza) > 0
			// Depois atualiza
			cQuery := "UPDATE "
			cQuery += RetSqlName("SG1")+" "
			cQuery += "SET G1_COMP = '"+aDadosDest[1]+"' , G1_GROPC = '"+aDadosDest[2]+"' , G1_OPC = '"+aDadosDest[3]+"'"
				cQuery += " WHERE G1_COD <> '"+aDadosDest[1]+"' AND R_E_C_N_O_ IN ("
				For nz:=1 to Len(aAtualiza)
					If nz > 1
						cQuery += ","
					EndIf
					cQuery += "'"+Str(aAtualiza[nz],10,0)+"'"
				Next nz
				cQuery += ")"

			TcSqlExec(cQuery)
		EndIf
	Else
		// subs componentes acima de 1001 itens.
		fSubComp(@aErrEstrut,@aAtualiza)
	EndIf
Return .T.

/*/{Protheus.doc} fSubComp
	update dos componentes substituidos
	@type  Static Function
	@author mauricio.joao
	@since 17/11/2020
	@version 1.0
	Variaveis Private:
	aDadosDest,aRecnosSG1,lAtualiza,lRvSBZ,lPCPREVATU,cAliasTmp
/*/
Static Function fSubComp(aErrEstrut,aAtualiza)
Local nz := 0
Default lAutomacao := .F.

	For nz:=1 to Len(aRecnosSG1)
		lAtualiza := .F.
		cQuery2 := " WHERE G1_COD <> '"+aDadosDest[1]+"' AND R_E_C_N_O_ = "
		cQuery2 += "'"+Str(aRecnosSG1[nz],10,0)+"'"
		// Primeiro busca os registros que serão alterados
		cQuery := "SELECT SG1.G1_COD, SG1.R_E_C_N_O_, "
		If "G1_REVINI+G1_REVFIM" $ FWX2Unico("SG1")
			cQuery += " (SELECT COUNT(SG12.G1_COD) "
			cQuery += "    FROM " + RetSqlName("SG1") + " SG12 "
			If lRvSBZ
				cQuery += "	LEFT JOIN " + RetSqlName("SBZ") + " SBZ ON SBZ.BZ_FILIAL = '" + xFilial('SBZ')+ "' AND SBZ.BZ_COD = SG1.G1_COD AND SBZ.D_E_L_E_T_ = ' ' "
			Else
				cQuery += "	LEFT JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial('SB1')+ "'  AND SB1.D_E_L_E_T_ = ' ' "
			EndIf
			cQuery += "   WHERE SG12.G1_FILIAL  = '" + xFilial('SG1')+ "' "
			cQuery += "     AND SG12.G1_COD     = SG1.G1_COD "
			cQuery += "     AND SG12.G1_COMP    = '"+aDadosDest[1]+"' "
			cQuery += "     AND SG12.G1_TRT     = SG1.G1_TRT "

			IF lRvSBZ
				cQuery += " 	AND SBZ.BZ_COD = SG1.G1_COD "
			ELSE
				cQuery += " 	AND SB1.B1_COD = SG1.G1_COD "
			ENDIF

			cQuery += " 	  AND SG12.D_E_L_E_T_ = ' ' "
			If lPCPREVATU .And. lUsaSBZ
				cQuery += "	AND SBZ.BZ_REVATU BETWEEN SG12.G1_REVINI AND SG12.G1_REVFIM "
			Else
				cQuery += "	AND SB1.B1_REVATU BETWEEN SG12.G1_REVINI AND SG12.G1_REVFIM "
			EndIf
			cQuery += "	) EXISTE "
		Else
			cQuery += " (SELECT COUNT(SG12.G1_COD) "
			cQuery += "    FROM " + RetSqlName("SG1") + " SG12 "
			cQuery += "   WHERE SG12.G1_FILIAL  = '" + xFilial('SG1')+ "' "
			cQuery += "     AND SG12.G1_COD     = SG1.G1_COD "
			cQuery += "     AND SG12.G1_COMP    = '"+aDadosDest[1]+"' "
			cQuery += "     AND SG12.G1_TRT     = SG1.G1_TRT "
			cQuery += " 	  AND SG12.D_E_L_E_T_ = ' ' "
			cQuery += "	) EXISTE "
		EndIf
		cQuery += "FROM " + RetSqlName("SG1") + " SG1 "
		cQuery += cQuery2

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

		While (cAliasTmp)->(!EOF())
			If (cAliasTmp)->EXISTE > 0
				If !lAutomacao
				AADD(aErrEstrut, {(cAliasTmp)->G1_COD,STR0098,(cAliasTmp)->R_E_C_N_O_}) //"Componente já Cadastrado na Estrutura."
				EndIf
				(cAliasTmp)->(dbSkip())
				Loop
			EndIf

			aadd(aAtualiza,(cAliasTmp)->R_E_C_N_O_)
			lAtualiza := .T.

			(cAliasTmp)->(dbSkip())
		End

		(cAliasTmp)->(dbCloseArea())

		If lAtualiza
			// Depois atualiza
			cQuery := "UPDATE "
			cQuery += RetSqlName("SG1")+" "
			cQuery += "SET G1_COMP = '"+aDadosDest[1]+"' , G1_GROPC = '"+aDadosDest[2]+"' , G1_OPC = '"+aDadosDest[3]+"'"
			cQuery += cQuery2

			TcSqlExec(cQuery)
		EndIf
	Next nz
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A200ErrStr  ³ Autor ³Renan Roeder         ³ Data ³28/02/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta tela para exibir o que não foi substituído pelo      ³±±
±±³          ³ componente já existir na estrutura.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200ErrStr(aErrEstrut)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aErrEstrut = Array contendo os produtos não substituídos    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Lógico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A200ErrStr(aErrEstrut)
Local aHeader  := { }
Local aSizes   := { }
Local oDlg
Local oPanel
Local oGroup
Local oBrowse
DEFAULT lAutomacao := .F.

aAdd(aHeader,STR0038) //Produto
aAdd(aHeader,STR0086) //Mensagem
aAdd(aSizes,60)
aAdd(aSizes,100)
aAdd(aSizes,30)
aAdd(aSizes,70)
aAdd(aSizes,30)
aAdd(aSizes,70)
If !lAutomacao
	DEFINE MSDIALOG oDlg TITLE STR0096 FROM 0,0 TO 350,800 PIXEL //"Listagem de Inconsistências"
	oPanel:= tPanel():Create(oDlg, 1, 1,,,,,,, 350, 800)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	oGroup:= TGroup():New(05,07,152,396,STR0097,oPanel,,,.T.) //"Dados"
	oBrowse := TWBrowse():New(14,12,380,135,,aHeader,aSizes,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,.T.,.T.)
	oBrowse:SetArray(aErrEstrut)
	oBrowse:bLine := {||{ aErrEstrut[oBrowse:nAT,01],aErrEstrut[oBrowse:nAt,02]}}
	DEFINE SBUTTON FROM 158,370 TYPE 1 ACTION (oDlg:End()) ENABLE OF oPanel
	ACTIVATE MSDIALOG oDlg CENTER
EndIf
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ProcP       ³ Autor ³Erike Yuri da Silva  ³ Data ³03/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Procura por uma palavra chave em um array padrao para      ³±±
±±³          ³ rotina automatica, pois na primeira coluna sempre eh infor-³±±
±±³          ³ mado o codigo chave de campo ou variavel.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ProcP(ExpA1,ExpC1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array contendo cabecalho ou itens da rot.automatica³±±
±±³          ³ ExpC1 = Campo ou variavel a ser pesquisada.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Numerico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ProcP(aPilha,cCampo)
Return aScan(aPilha,{|x|Trim(x[1])== cCampo })

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NextNivel   ³ Autor ³Felipe Nunes Toledo  ³ Data ³01/08/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Explode o Proximo Nivel da Estrutura                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ NextNivel(ExpN1,ExpC1,ExpO1,ExpO2,ExpA1,ExpA2)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao da Edicao                                    ³±±
±±³          ³ ExpC1 = Chave do Registro                                  ³±±
±±³          ³ ExpO1 = Objeto Tree                                        ³±±
±±³          ³ ExpO2 = objeto Dlg                 		           		  ³±±
±±³          ³ ExpA1 = tecla de atalho                                    ³±±
±±³          ³ ExpA2 = Array con. blo. de cod. que sera exe. pela tecla de³±±
±±³          ³ atalho e tecla de atalho,Exeplo: aBkey -> aBkey[bKey][aKey]³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Numerico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NextNivel(nOpcX, cCargo, oTree, oDlg, aKey,aBkey)
Local cProduto := Substr( cCargo, Len(SG1->G1_COD+SG1->G1_TRT) + 1, Len(SG1->G1_COMP))
Local cTRTPai  := ""
Local cPrompt  := ""
Local dValIni  := CtoD('  /  /  ')
Local dValFim  := CtoD('  /  /  ')
Local cFolderA, cFolderB
Local nX	   := {0}
Local lMT200Exp:= ExistBlock("MT200EXP")
Local lM200BMP := ExistBlock("M200BMP")
Local lExpEst2 := .T.
Local uRet     := Nil
Local aOpc     := {}
Local cOpc     := ""

Default lAutomacao := .F.

//--Desativa Tecla de atalho
For nX := 1 to len(aKey)
	Set Key aKey[nX] to
Next nX
If lMT200Exp
	lExpEst2 := ExecBlock("MT200EXP",.F.,.F., {cProduto})
EndIf

If Right(cCargo, 4) == 'COMP'
	SG1->(dbSetOrder(1))
	If SG1->(dbSeek(xFilial('SG1') + cProduto, .F.)) .And. lExpEst2

		Do While !SG1->(Eof()) .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cProduto

			//-- Posiciona no SB1 para descrição
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial('SB1') + SG1->G1_COMP, .F.))
				cPrompt := AllTrim(SG1->G1_COMP) + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(AllTrim(SG1->G1_COMP)))
			EndIf

			//-- Posiciona no SB1 para revisão
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial('SB1') + SG1->G1_COD, .F.))
				cRevisao := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU) //SB1->B1_REVATU
			EndIf

			//-- Nao Adiciona Componentes fora da Revisao
			If (nOpcX == 2 .Or. nOpcX == 4) .And. (cRevisao # Nil) .And. ;
				!(SG1->G1_REVINI <= cRevisao .And. SG1->G1_REVFIM >= cRevisao)
				SG1->(dbSkip())
				Loop
			EndIf

			cTRTPai  := If(cTRTPai==Nil,SG1->G1_TRT,cTRTPai)
			dValIni  := SG1->G1_INI
			dValFim  := SG1->G1_FIM
			nQtdeSG1 := SG1->G1_QUANT

	        //-- Define as Pastas a serem usadas
			cFolderA := 'FOLDER5'
			cFolderB := 'FOLDER6'
			If Right(cCargo, 4) == 'COMP' .And. ;
				(dDataBase < dValIni .Or. dDataBase > dValFim)
				cFolderA := 'FOLDER7'
				cFolderB := 'FOLDER8'
			EndIf

			cCargo := SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex, 9)  + 'COMP'

			If GetMV("MV_SELEOPC") == "S"
           cOpc := Padr(SG1->G1_GROPC, TamSX3("G1_GROPC")[1]) + Padr(SG1->G1_OPC, TamSX3("G1_OPC")[1]) + "/"
           aOpc := aClone(ListOpc(Nil,Nil,cOpc))
        EndIf

			If lM200BMP
				uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
				If ValType(uRet) == "A"
					cFolderA := uRet[1]
					cFolderB := uRet[2]
				EndIf
			EndIf
			If !lAutomacao
				If !oTree:TreeSeek(cCargo)
					//-- Adiciona um Nivel a Estrutura
					oTree:AddItem(A200Prompt(cPrompt, cCargo, nQtdeSG1,,aOpc), cCargo, cFolderA, cFolderB,,, 2)
				EndIf
			EndIf
			SG1->(dbSkip())
		EndDo
	Else
		If !lExpEst2 .And. lMT200Exp
			Aviso(STR0061,STR0095,{STR0062},2) //"Atencao!"##"Componente nao possui Nivel Inferior."##"Ok"
		Else
			Aviso(STR0061,STR0063,{STR0062},2) //"Atencao!"##"Componente nao possui Nivel Inferior."##"Ok"
		Endif
	EndIf
Else
	Aviso(STR0061,STR0064,{STR0062},2) //"Atencao!"##"Selecione um componente do Nivel Inferior, para explodir seu proximo Nivel."##"Ok"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta tecla de atalho		                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Ma200StKey(aKey,aBkey)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Fabio Alves Silva     ³ Data ³03/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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
Private aRotina	:={	{ STR0002  , 'AxPesqui' , 0, 1,0 ,.F.}, ;    	//'Pesquisar'
					{ STR0003  , 'a200Proc' , 0, 2,0 ,nil}, ;    	//'Visualizar'
					{ STR0004  , 'a200Proc' , 0, 3,0 ,nil}, ;    	//'Incluir'
					{ STR0005  , 'a200Proc' , 0, 4,13,nil}, ;		//'Alterar'
					{ STR0006  , 'a200Proc' , 0, 5,14,nil}, ;		//'Excluir'
					{ STR0034  , 'a200CEst' , 0, 6,0 ,nil},;		//'Comparar'
					{ STR0053  , 'a200Subs' , 0, 6,0 ,.F.}} 	  	//'Substituir'
If ExistBlock ("MTA200MNU")
	ExecBlock ("MTA200MNU",.F.,.F.)
EndIf

aBkpARot := ACLONE(aRotina)

return (aRotina)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200FanInv³ Autor ³ Andre Anjos	        ³ Data ³ 10/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna um PA valido ignorando os fantasmas				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cComp: Componente posicionado                              ³±±
±±³			 ³ oTree: Objeto tree que contem a estrutura e seus dados     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A200FanInv(cComp,oTree)
Local aArea   := GetArea()
Local cRet    := CriaVar("G1_COD",.F.)
Local cPAQuebr:= ""
Local cNodeID := oTree:CurrentNodeID

While Empty(cRet) .And. Val(oTree:CurrentNodeID) > 0
	cPAQuebr := Substr(oTree:GetCargo(),1,TamSX3("G1_COD")[1])
	If SB1->(dbSeek(xFilial("SB1")+cPAQuebr)) .And. RetFldProd(SB1->B1_COD,"B1_FANTASM") # "S" // Projeto Implementeacao de campos MRP e FANTASM no SBZ
		cRet := cPAQuebr
	EndIf
	While Substr(oTree:GetCargo(),1,TamSX3("G1_COD")[1]) == cPAQuebr
		oTree:CurrentNodeID := StrZero(Val(oTree:CurrentNodeID)-1,7)
	End
End

oTree:CurrentNodeID := cNodeID
RestArea(aArea)

Return cRet

/*
EXEMPLO DE UM RDMAKE QUE EXECUTA O MATA200 VIA ROTINA AUTOMATICA
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MyMata200 ³ Autor ³ Erike Yuri da Silva   ³ Data ³06.01.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de teste da rotina automatica do programa MATA200     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpc - Indica: 3=Inclusao;5=Exclusao                         ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar testes na rotina de    ³±±
±±³          ³cadastro de estruturas                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

User Function MyMATA200(nOpc)
Local aCab  :={}
Local aItem := {}
Local aGets	:= {}
Local lOK	:= .T.
Local cString
Private lMsErroAuto := .F.
Default nOpc := 3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Abertura do ambiente                                         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "PCP" TABLES "SB1","SG1","SG5"
ConOut(Repl("-",80))
ConOut(PadC("Teste de rotina automatica para estrutura de produtos",80))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verificacao do ambiente para teste                           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB1")
dbSetOrder(1)
If !SB1->(MsSeek(xFilial("SB1")+"PA001"))
	lOk := .F.
	ConOut("Cadastrar produto acabado: PA001")
EndIf

If !SB1->(MsSeek(xFilial("SB1")+"PI001"))
	lOk := .F.
	ConOut("Cadastrar produto intermediario: PI001")
EndIf

If !SB1->(MsSeek(xFilial("SB1")+"PI002"))
	lOk := .F.
	ConOut("Cadastrar produto intermediario: PI002")
EndIf

If !SB1->(MsSeek(xFilial("SB1")+"PI003"))
	lOk := .F.
	ConOut("Cadastrar produto intermediario: PA003")
EndIf


If !SB1->(MsSeek(xFilial("SB1")+"MP001"))
	lOk := .F.
	ConOut("Cadastrar produto materia prima: MP001")
EndIf

If !SB1->(MsSeek(xFilial("SB1")+"MP002"))
	lOk := .F.
	ConOut("Cadastrar produto materia prima: MP002")
EndIf

If !SB1->(MsSeek(xFilial("SB1")+"MP003"))
	lOk := .F.
	ConOut("Cadastrar produto materia prima: MP003")
EndIf

If !SB1->(MsSeek(xFilial("SB1")+"MP004"))
	lOk := .F.
	ConOut("Cadastrar produto materia prima: MP004")
EndIf
If nOpc==3
	aCab := {	{"G1_COD"		,"PA001"			,NIL},;
				{"G1_QUANT"		,1		     		,NIL},;
				{"NIVALT"		,"S"				,NIL}} //A variavel NIVALT eh utilizada pra recalcular ou nao a estrutura

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PA001"			,NIL})
	aadd(aGets,	{"G1_COMP"		,"PI001" 			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PI001" 			,NIL})
	aadd(aGets,	{"G1_COMP"		,"PI002" 			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PI001"			,NIL})
	aadd(aGets,	{"G1_COMP"		,"MP002"			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PI002"	   		,NIL})
	aadd(aGets,	{"G1_COMP"		,"MP001"			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PA001"			,NIL})
	aadd(aGets,	{"G1_COMP"		,"PI003" 			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PA001"			,NIL})
	aadd(aGets,	{"G1_COMP"		,"MP004" 			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PI003"			,NIL})
	aadd(aGets,	{"G1_COMP"		,"MP003" 			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)
	If lOk
		ConOut("Teste de Inclusao")
		ConOut("Inicio: "+Time())
		MSExecAuto({|x,y,z| mata200(x,y,z)},aCab,aItem,3) //Inclusao
		ConOut("Fim: "+Time())
	EndIf
Else
	//--------------- Exemplo de Exclusao ------------------------------------
	If lOk
		aCab := {	{"G1_COD"		,"PA001"			,NIL},;
		            {"NIVALT"		,"S"				,NIL}} //A variavel NIVALT eh utilizada pra recalcular ou nao a estrutura
		ConOut("Teste de Exclusao do codigo PA001")
		ConOut("Inicio: "+Time())
		MSExecAuto({|x,y,z| mata200(x,y,z)},aCab,NIL,5) //Exclusao
		lOk := !lMsErroAuto
		ConOut("Fim: "+Time())
	EndIf
	If lOk
		aCab := {	{"G1_COD"		,"PI001"			,NIL},;
					{"NIVALT"		,"S"				,NIL}} //A variavel NIVALT eh utilizada pra recalcular ou nao a estrutura
		ConOut("Teste de Exclusao do codigo PI001")
		ConOut("Inicio: "+Time())
		MSExecAuto({|x,y,z| mata200(x,y,z)},aCab,NIL,5) //Exclusao
		lOk := !lMsErroAuto
		ConOut("Fim: "+Time())
	EndIf
	If lOk
		aCab := {	{"G1_COD"		,"PI002"			,NIL},;
					{"NIVALT"		,"S"				,NIL}} //A variavel NIVALT eh utilizada pra recalcular ou nao a estrutura
		ConOut("Teste de Exclusao do codigo PI002")
		ConOut("Inicio: "+Time())
		MSExecAuto({|x,y,z| mata200(x,y,z)},aCab,NIL,5) //Exclusao
		lOk := !lMsErroAuto
		ConOut("Fim: "+Time())
	EndIf
	If lOk
		aCab := {	{"G1_COD"		,"PI003"			,NIL},;
					{"NIVALT"		,"S"				,NIL}} //A variavel NIVALT eh utilizada pra recalcular ou nao a estrutura
		ConOut("Teste de Exclusao do codigo PI003")
		ConOut("Inicio: "+Time())
		MSExecAuto({|x,y,z| mata200(x,y,z)},aCab,NIL,5) //Exclusao
		ConOut("Fim: "+Time())
	EndIf
EndIf
If lMsErroAuto
	If IsBlind()
		If IsTelnet()
			VTDispFile(NomeAutoLog(),.t.)
		Else
			cString := MemoRead(NomeAutoLog())
			Aviso("Aviso de Erro:",cString)
		EndIf
	Else
		MostraErro()
	EndIf
Else
	If lOk
		Aviso("Aviso","Incluido com sucesso",{"Ok"})
	Else
		Aviso("Aviso","Fazer os devidos cadastros",{"Ok"})
	EndIf
Endif
Return
*/
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ma200StKey³ Autor ³ Aécio Ferreira Gomes  ³ Data ³02.04.2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Responsável por setar as teclas de atalhos na navegacao  	   ³±±
±±³          ³do Tree da estrutura  			                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ma200StKey(ExpA1,ExpA2)			                           ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata200                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ma200StKey(aKey,aBkey)
Local nX :=0
Local nY :=0
Default aKey := {}
Default aBkey:= {}

For nX := 1 To Len(aKey)
	For nY:=1 to Len(aBkey)
   		If aKey[nX] == aBkey[nY][2]
   		    SetKey(aKey[nX], aBkey[nY][1])
   		EndIf
    Next nY
Next nX
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A200IniDsc ³ Autor ³Rodrigo de A Sartorio³ Data ³29.10.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa a descricao dos codigos digitados               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200IniDsc(ExpN1,ExpO1,ExpC1,ExpC2)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Indica se esta validando origem (1) ou destino (2) ³±±
±±³          ³ ExpO1 = Objeto say que deve ser atualizado                 ³±±
±±³          ³ ExpC1 = Codigo do produto digitado                         ³±±
±±³          ³ ExpC2 = Cod.do produto origem(ExpN1=2) ou destino(ExpN1=1) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ True                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A200IniDsc(nOpcao,oSay,cProduto,cProdDesOr)
Local aEstruOrig := {}
Local lRet		 := .T.

Default cProdDesOr := Criavar("G1_COMP",.F.)

Private nEstru   := 0

SB1->(MsSeek(xFilial("SB1")+cProduto))

If nOpcao == 1
	cDescOrig:=SB1->B1_DESC
	// Preenche descricao do produto
	oSay:SetText(cDescOrig)
ElseIf nOpcao == 2
	cDescDest:=SB1->B1_DESC
	// Preenche descricao do produto
	oSay:SetText(cDescDest)
EndIf
// Troca a cor do texto para vermelho
oSay:SetColor(CLR_HRED,GetSysColor(15))

If !Empty(cProdDesOr)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Os produtos origem e destino foram informados. Explode sempre o produto destino. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aEstruOrig := Estrut( If(nOpcao == 2,cProduto,cProdDesOr) ,1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o produto origem ja' existe na estrutura do produto destino			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (aScan(aEstruOrig,{|x| x[3] == If(nOpcao == 2,cProdDesOr,cProduto) }) > 0)
		Help(' ',1,'A200NODES')
		lRet := .F.
	EndIf
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A200AltRev  ³ Autor ³ Sergio S. Fuzinaka  ³ Data ³ 12.02.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Atualiza o cadastro de revisoes da estrutura de todos os    ³±±
±±³          ³componentes alterados.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA200                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A200AltRev( aAltRev )

Local aArea		:= GetArea()
Local aAreaSG1	:= SG1->(GetArea())
Local aCampos	:= SG1->(dbStruct())
Local nPosCod	:= Ascan( aCampos, {|x| x[1] == "G1_COD"} )
Local aCod		:= {}
Local nX		:= 0

If nPosCod > 0
	For nX := 1 To Len( aAltRev )
		If aAltRev[nX,1] > 0 .And. aAltRev[nX,1] <= SG1->(LastRec())
			SG1->(dbGoto(aAltRev[nX,1]))
			If aScan(aCod, SG1->G1_COD) == 0
				AADD(aCod, SG1->G1_COD)
			Endif
		Endif
	Next nX
	For nX := 1 To Len( aCod )
		If aCod[nX] <> cProduto
			A200Revis( aCod[nX], .F. )
		Endif
	Next
Endif

RestArea( aAreaSG1 )
RestArea( aArea )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ a200subOK  ³ Autor ³   Bruno Schmidt     ³ Data ³30.12.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡„o Final da Substituicao de Estrutura               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ a200subOK(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do produto origem                           ³±±
±±³          ³ ExpC2 = Grupo de opcionais origem                          ³±±
±±³          ³ ExpC3 = Opcionais do produto origem                        ³±±
±±³          ³ ExpC4 = Codigo do produto destino                          ³±±
±±³          ³ ExpC5 = Grupo de opcionais destino                         ³±±
±±³          ³ ExpC6 = Opcionais do produto destino                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso ocorra algum problema na Valida‡„o, True C.C.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A200SubOK(cCodOrig,cGrpOrig,cOpcOrig,cCodDest,cGrpDest,cOpcDest)
Local lRet:=.T.
Local aAreaAnt := GetArea()

//Valida a utilização do conceito de versão da produção em conjunto com o conceito de componentes opcionais
If AliasInDic("SVC") .And. (!Empty(cGrpDest) .Or. !Empty(cOpcDest))
	dbSelectArea("SVC")
	dbSetOrder(1)
	If SVC->(DbSeek(xFilial("SVC")))
		Help( ,  , "Help", ,  STR0105,;  //"Não é permitido utilizar a versão da produção em conjunto com o conceito de Componentes Opcionais."
		1, 0, , , , , , {STR0106})  //"Para a utilização dos opcionais, não pode haver versão de produção cadastrada."
		lRet := .F.
	EndIf
EndIf

Do Case
	Case Vazio(cCodOrig) .Or. !ExistCpo("SB1",cCodOrig)
		lRet:=.F.
		Help('', 1, 'A200PRDORI')
	Case Vazio(cCodDest) .Or. !ExistCpo("SB1",cCodDest)
		lRet:=.F.
		Help('', 1, 'A200PRDDES')
EndCase

RestArea(aAreaAnt)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A200IntSFC ³ Autor ³ Andre Anjos		       ³ Data ³06/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza status do produto no SFC para comprado ou fabricado.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTipo: 1- Comprado; 2-Fabricado					            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A200IntSFC(cProduto,cTipo,oModel)
Local aArea   := GetArea()
Local lRet    := .T.
Default oModel  := FWLoadModel("SFCC101")
Default lAutomacao := .F.

CZ3->(dbSetOrder(1))
CZ3->(dbSeek(xFilial("CZ3")+cProduto))
oModel:SetOperation(4)

If !(	oModel:Activate() .And. ;								//-- Ativa o modelo
		oModel:SetValue("CZ3MASTER","CZ3_TPAC",cTipo) .And. ;	//-- Seta valor para o campo
		oModel:VldData() .And. ;								//-- Valida modelo
		oModel:CommitData()	)
										//-- Efetiva gravacao
	If !lAutomacao
	A010SFCErr(oModel)
	EndIf
EndIf

oModel:DeActivate()

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A200IsDel ºAutor  ³ Andre Anjos		 º Data ³  18/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se o item da estrutura foi deletado durante a     º±±
±±º          ³ alteracao.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA200                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A200RevDel(cCod,cComp,cTrt,aUndo)
Local lRet     := .F.
Local nX       := 0
Local nPosDel  := 0
Local aAreaSG1 := SG1->(GetArea())

aSort(aUndo, , , {|x,y|x[2] > y[2]})
nPosDel:= aScan(aUndo,{|x|x[2] == 2})

If l200Auto
	lRet := ((nX := aScan(aUndo,{|x| x[1] == SG1->(Recno())})) > 0 .And. aUndo[nX,2] == 2)
Else
	If !oTree:TreeSeek(G1_COD+G1_TRT+G1_COMP)
		If nPosDel == 0
			lRet := .T.
		Else
			While nPosDel <= Len (aUndo) .And. aUndo[nPosDel][2] == 2 .And. !lRet
				SG1->(DbGoTo(aUndo[nPosDel][1]))
				If SG1->G1_COD == cCod .And. SG1->G1_COMP == cComp .And. SG1->G1_TRT == cTrt
					lRet := .T.
				Else
					nPosDel++
				 EndIf
			EndDo
		EndIf
	EndIf
EndIf

RestArea(aAreaSG1)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A200Auto4EºAutor  ³ Andre Anjos		 º Data ³  18/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Processa exclusao de componentes nao recebidos na nova     º±±
±±º          ³ estrutura alterada por rotina automatica.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A200Auto4E(cCod,aUndo,lMudou,aAltEstru,aPaiEstru,lPriNivel)
Local aAreaSB1 := {}
Local cRevAtu  := CriaVar("B1_REVATU",.F.)
Local nPCOD    := aScan(aAutoItens[1],{|x| AllTrim(x[1]) == "G1_COD"})
Local nPCOMP   := aScan(aAutoItens[1],{|x| AllTrim(x[1]) == "G1_COMP"})
Local nPTRT    := aScan(aAutoItens[1],{|x| AllTrim(x[1]) == "G1_TRT"})
Local nRecno   := 0

//Busca revisão do Pai Direto
SB1->(dbSelectArea("SB1"))
aAreaSB1 := SB1->(GetArea())
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial('SB1') + cCod, .F.))
	cRevAtu := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)
EndIf
SB1->(dbCloseArea())
RestArea(aAreaSB1)

SG1->(dbSetOrder(1))
While !SG1->(EOF()) .And. SG1->(G1_FILIAL+G1_COD) == xFilial("SG1")+cCod
	//Se a revisão atual for maior ou igual a revisão final do comp significa que o comp faz parte da estrutura.
	IF SG1->G1_REVFIM >= cRevAtu
		//-- Se nao achou item no array da ExecAuto, deleta
		If Empty(aScan(aAutoItens,{|x| x[nPCOD,2]  == SG1->G1_COD  .And.;
									   x[nPCOMP,2] == SG1->G1_COMP .And.;
									   x[nPTRT,2]  == SG1->G1_TRT}))
			cCargo  := SG1->(G1_COD+G1_TRT+G1_COMP+StrZero(Recno(),9)+StrZero(nIndex++,9)+'COMP')
			T_CARGO := SG1->(G1_COD+G1_TRT+G1_COMP+StrZero(Recno(),9)+StrZero(nIndex++,9)+'COMP')

			Ma200Edita(5,cCargo,NIL,5,@aUndo,@lMudou,@aAltEstru,,,,@aPaiEstru,{})
		ElseIf !lPriNivel
			nRecno := SG1->(Recno())
			If SG1->(dbSeek(xFilial("SG1")+SG1->G1_COMP))
				A200Auto4E(SG1->G1_COD,@aUndo,@lMudou,@aAltEstru,@aPaiEstru,lPriNivel)
			EndIf
			SG1->(dbGoTo(nRecno))
		EndIf
	ENDIF
	SG1->(dbSkip())
EndDo

Return

//------------------------------------------------------------------
/*/{Protheus.doc} A200RevSim()
 Busca estrutura similar conforme a revisão informada.
@author Lucas Pereira
@since 22/09/2014
@version 1.0
/*/
//------------------------------------------------------------------
Function A200RevSim(lGetRevisao, oDlg, oTree, cProduto, cCodSim, cRevisao, nOpcX, lReAuto, aPaiEstru)
Default lReAuto   := .F.
Default aPaiEstru := {}

If Vazio(cCodSim)
	Return .T.
else
	If Vazio(cRevisao)
		Aviso(STR0100 /*"Aviso"*/,STR0100 /*"Informe o campo Revisão da Estrutura Similar."*/,{"Ok"})
		Return .F.
	EndIf
End If

lGetRevisao := !lGetRevisao
ldbTree	:= .T.
cCodAtual := cCodSim
cValComp  := cCodSim + 'ú'
A200Cria(oTree, oDlg, cProduto, cCodAtual, cRevisao, nOpcX)
IF lReAuto
	SG1->(DbSetOrder(1))
	If SG1->(dbSeek(xFilial("SG1")+cCodAtual))
		If aScan(aPaiEstru, {|x| x[1]==SG1->G1_COD}) == 0
			aAdd(aPaiEstru,{cProduto,.T.})
		EndIf
	EndIf
EndIf
Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} A200Cria()
Montagem do Arquivo Temporario para o Tree da Estrutura Similar
(Func.Recurssiva)
@author Lucas Pereira
@since 22/09/2014
@version 1.0
/*/
//------------------------------------------------------------------
Function A200Cria(oTree, oDlg, cProduto, cCodSim, cRevisao, nOpcX, cCargo, cTRTPai, lZeraStatic)

Local nRecAnt    := 0
Local cComp      := ''
Local cPrompt    := ''
Local cFolderA   := 'FOLDER5'
Local cFolderB   := 'FOLDER6'
Local cRevPI 	 := ""
Local nRecCargo  := 0
Local dValIni    := CtoD('  /  /  ')
Local dValFim    := CtoD('  /  /  ')
Local lRet		 := .T.
Local lContinua	 := .T.
Local nQtdeSG1   := 0
Local lExpand    := mv_par03 == 1
Local lExibeOPC  := .T.
Local lRetPE
Local lA200rvPi  := ExistBlock("A200RVPI")
Local nIndSG1	 := 1
Local lM200BMP   := ExistBlock("M200BMP")
Local uRet       := Nil
Local lRevAut    := SuperGetMv("MV_REVAUT",.F.,.F.)
Local cOpc       := ""
Local aOpc       := {}

Default lAutomacao := .F.

Static nNivelTr  := 0
Static cFistCargo:= NIL
// -- Atualiza nivel da estrutura
nNivelTr += 1

nOpcX := If(nOpcX==Nil,0,nOpcX)

lExpEst := .T.

If ExistBlock("MA200ORD")
	nIndSG1 := ExecBlock("MA200ORD",.F.,.F.)
	If ValType(nIndSG1) # "N"
		nIndSG1 := 1
	EndIf
EndIf

If !ldbTree .And. nOpcX < 5
	oDlg:SetFocus()
	lRet := .F.
EndIf

If lRet
	lExpEst := .T.

	//-- Posiciona no SB1
	  cPrompt := cProduto + Space(400)

	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial('SB1') + cCodSim, .F.))
		cPrompt := AllTrim(cProduto)
		If SB1->(DbSeek(xFilial("SB1")+ cProduto, .F.))
			cPrompt += " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(AllTrim(cProduto)))
		EndIf
	EndIf
	  cPrompt += Space(Len(STR0060)+TamSX3("G1_QUANT")[1]) //"QTDE:"
	  cPrompt += Space(200)

	SG1->(dbSetOrder(nIndSG1))
	If !Vazio(cProduto)
		SG1->(DbSeek(xFilial("SG1")+cProduto))
		cCodSim := cProduto
	else
		cCodSim := cProduto
	EndIf

	If lRet .And. lContinua
		cTRTPai := If(cTRTPai==Nil,SG1->G1_TRT,cTRTPai)

		dValIni := SG1->G1_INI
		dValFim := SG1->G1_FIM
		If cCargo == Nil
			cCargo := cProduto + cTRTPai + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) + 'CODI'
		ElseIf (nRecCargo := Val(SubStr(cCargo,Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))) > 0
			nRecAnt := SG1->(Recno())
			SG1->(dbGoto(nRecCargo))
			dValIni := SG1->G1_INI
			dValFim := SG1->G1_FIM
			nQtdeSG1 := SG1->G1_QUANT

			If SuperGetMV("MV_SELEOPC",.F.,'N') == "S"
				cOpc := Padr(SG1->G1_GROPC, TamSX3("G1_GROPC")[1]) + Padr(SG1->G1_OPC, TamSX3("G1_OPC")[1]) + "/"
				aOpc := aClone(ListOpc(Nil,Nil,cOpc))
			EndIf
			SG1->(dbGoto(nRecAnt))
		EndIf

		//-- Define as Pastas a serem usadas
		cFolderA := 'FOLDER5'
		cFolderB := 'FOLDER6'
		If Right(cCargo, 4) == 'COMP' .And. ;
			(dDataBase < dValIni .Or. dDataBase > dValFim)
			cFolderA := 'FOLDER7'
			cFolderB := 'FOLDER8'
		EndIf

		If lM200BMP
			uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
			If ValType(uRet) == "A"
				cFolderA := uRet[1]
				cFolderB := uRet[2]
			EndIf
		EndIf

		//-- Adiciona o Pai na Estrutura
		If !lAutomacao
		DBADDTREE oTree PROMPT A200Prompt(cPrompt, cCargo, nQtdeSG1,,aOpc) OPENED RESOURCE cFolderA, cFolderB CARGO cCargo
		EndIf
		Do While !SG1->(Eof()) .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cCodSim

			lExpEst := .T.

			//-- Nao Adiciona Componentes fora da Revis„o
			If (cRevisao # Nil) .And. ;
				!(SG1->G1_REVINI <= cRevisao .And. (SG1->G1_REVFIM >= cRevisao .Or. SG1->G1_REVFIM = ' '))
				SG1->(dbSkip())
				Loop
			EndIf

			nRecAnt  := SG1->(Recno())
			cComp    := SG1->G1_COMP
			cCargo   := cProduto + SG1->G1_TRT + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) + 'COMP'
			nQtdeSG1 := SG1->G1_QUANT

			If SuperGetMV("MV_SELEOPC",.F.,'N') == "S"
				cOpc := Padr(SG1->G1_GROPC, TamSX3("G1_GROPC")[1]) + Padr(SG1->G1_OPC, TamSX3("G1_OPC")[1]) + "/"
				aOpc := aClone(ListOpc(Nil,Nil,cOpc))
			EndIf

			If cFistCargo == NIL
				cFistCargo := cCargo
			EndIf

			//-- Define as Pastas a serem usadas
			cFolderA := 'FOLDER5'
			cFolderB := 'FOLDER6'
			If dDataBase < SG1->G1_INI .Or. dDataBase > SG1->G1_FIM
				cFolderA := 'FOLDER7'
				cFolderB := 'FOLDER8'
			EndIf

			//-- Posiciona no SB1
			cPrompt := cComp + Space(400)
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial('SB1') + cComp, .F.))
				cPrompt := AllTrim(cComp) + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(AllTrim(cComp)))
			EndIf
			cPrompt += Space(Len(STR0060)+TamSX3("G1_QUANT")[1]) //"QTDE:"
			cPrompt += Space(200)

			lExpEst := .T.
			If ExistBlock("MT200EXP")
				lExpEst := ExecBlock("MT200EXP",.F.,.F., {cComp})
			endIf

   			If SG1->(dbSeek(xFilial('SG1') + SG1->G1_COMP, .F.)) .and. lExpEst
				If ExistBlock("MT200OPC")
					lRetPE := ExecBlock("MT200OPC",.F.,.F.,SG1->G1_COMP)
					lExibeOPC := IIF(ValType(lRetPE)=="L",lRetPE,lExibeOPC)
				EndIf
				cRevPi := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)
				if empty(cRevPi)
				cRevPi := '001'
				endif
				//cRevPi := IIf(SB1->B1_REVATU = ' ','001',SB1->B1_REVATU)

				If lA200rvPi
					cRevPi := Execblock ("A200RVPI",.F.,.F.,{cCodSim, cRevisao, SG1->G1_COD, cRevPi})
				EndIf

   				If lExpand .And. lExibeOPC
					//-- Adiciona um Nivel a Estrutura
					A200Cria(oTree, oDlg, SG1->G1_COD,'',cRevPi,IIF(lRevaut,2,If(nOpcX==3,0,nOpcX)), cCargo, cTRTPai)
				Else
					If lM200BMP
						uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
						If ValType(uRet) == "A"
							cFolderA := uRet[1]
							cFolderB := uRet[2]
						EndIf
					EndIf
					oTree:AddItem(A200Prompt(cPrompt, cCargo, nQtdeSG1,,aOpc), cCargo, cFolderA, cFolderB,,, 2)
				EndIf
			Else
				//-- Adiciona um Componente a Estrutura
				If lM200BMP
					uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
					If ValType(uRet) == "A"
						cFolderA := uRet[1]
						cFolderB := uRet[2]
					EndIf
				EndIf

				DBADDITEM oTree PROMPT A200Prompt(cPrompt, cCargo ,nQtdeSG1,,aOpc) RESOURCE cFolderA CARGO cCargo
			EndIf

			SG1->(dbGoto(nRecAnt))
			SG1->(dbSkip())
		EndDo
		If !lAutomacao
		DBENDTREE oTree
		EndIf
		If ldbTree
			// --- Atualiza obj.dbtree apos processar a estrutura
			If nNivelTr == 1
				If( cFistCargo <> NIL )
					cCargo := cFistCargo
					cFirstCargo := NIL
				EndIf
				If !lAutomacao
				oTree:TreeSeek(cCargo)
				oTree:Refresh()
				oTree:SetFocus()
				EndIf
			EndIf
		Else
			oDlg:SetFocus()
		EndIf
	EndIf
EndIf
If lContinua
	// --- Atualiza nivel da estrutura
	nNivelTr -= 1
EndIf

//Zera conteudo das variaveis static, necessario para montagem do tree na rotina MATC015.
If ValType(lZeraStatic)=="L" .And. lZeraStatic
	nNivelTr  := 0
	cFistCargo:= NIL
EndIf
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} a200RevMax()
Retorna a revisão corrente do produto
@author Ricardo Prandi
@since 29/12/2014
@version 1.0
/*/
//------------------------------------------------------------------
Function a200RevMax(cCodSim, cRevSim)

aArea := GetArea()

dbSelectArea('SB1')
dbSeek(xFilial('SB1')+cCodSim)
cRevSB :=  IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)

cRevSim := IIf (!(EOF()),IIF(cRevSB == '' .or. Empty(cRevSB),'001',cRevSB),'001')
lEdtRevSim := .F.
Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} A200SeqDPR()
Carrega sequencia TRT que será utilizada para o componente do DPR
@author Michele Girardi
@since 02/09/2015
@version 1.0
/*/
//------------------------------------------------------------------
Function A200SeqDPR(cCodPai, cCodComp, cSeq)

Local cSeqNew
Local lExistSeq
Local lRevAut    := SuperGetMv("MV_REVAUT",.F.,.F.)

If !lRevAut
	Return cSeq
EndIf

cSeqNew := cSeq

dbSelectArea('SG1')
dbSetOrder(1)

lExistSeq := .T.
While lExistSeq

	If dbSeek(xFilial("SG1")+cCodPai+cCodComp+cSeqNew)
		cSeqNew := Val(cSeqNew) + 1
		cSeqNew := StrZero(cSeqNew,3)
	Else
		lExistSeq := .F.
	EndIf
	dbSkip()
End

Return cSeqNew


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MATA200PPI

Realiza a integração com o PC-Factory - PPI Multitask

@param cXml      - XML que será enviado. Caso não seja passado esse parametro, será realizada
                   a chamada do Adapter para criação do XML.
                   Se for passado esse parâmetro, não será exibida a mensagem de erro caso exista,
                   nem será considerado o filtro da tabela SOE.
@param cProd     - Obrigatório quando utilizado o parâmetro cXml. Contém o código do produto
@param lExclusao - Indica se está chamando para rotina de exclusão de produto.
@param lFiltra   - Identifica se será realizado ou não o filtro do registro.
@param lPendAut  - Indica se será gerada a pendência sem realizar a pergunta para o usuário, caso ocorra algum erro.
@param aRegDel   - Indica os registros que foram deletados da Tree e que não deverão fazer parte da Query do MATI200.

@author  Lucas Konrad França
@version P118
@since   04/04/2016
@return  lRet  - Indica se a integração com o PC-Factory foi realizada.
           .T. -> Integração Realizada
           .F. -> Integração não realizada.
/*/
//-------------------------------------------------------------------------------------------------
Function MATA200PPI(cXml, cProd, lExclusao, lFiltra, lPendAut, aRegDel)
   Local aArea     := GetArea()
   Local aAreaSG1  := SG1->(GetArea())
   Local lRet      := .T.
   Local aRetXML   := {}
   Local aRetWS    := {}
   Local aRetData  := {}
   Local aRetArq   := {}
   Local cNomeXml  := ""
   Local cProduto  := ""
   Local cGerouXml := ""
   Local cOperacao := ""
   Local lProc     := .F.
   Local lAuto 	   := Iif(Type('l200Auto')=="L", l200Auto, .F.)

   //Variável utilizada para identificar que está sendo executada a integração para o PPI dentro do MATI200.
   Private lRunPPI := .T.

   If Type('INCLUI') == "U"
   		Private Inclui := .F.
   EndIf

   If Type('ALTERA') == "U"
   		Private Altera := .F.
   EndIf

   Default cXml      := ""
   Default cProd     := ""
   Default lExclusao := .F.
   Default lFiltra   := .T.
   Default lPendAut  := .F.
   Default aRegDel   := {}

   If Empty(cXml)
      If lExclusao
         cOperacao := Lower(STR0006) //"excluir"
      Else
         If INCLUI
            cOperacao := Lower(STR0004) //"incluir"
         Else
            cOperacao := Lower(STR0005) //"alterar"
         EndIf
      EndIf
   Else
      If PCPEvntXml(cXml) == "delete"
         lExclusao := .T.
      EndIf
   EndIf

   If Empty(cXml)
      cProduto := SG1->G1_COD
   Else
      cProduto := cProd
   EndIf

   //Realiza filtro na tabela SOE, para verificar se o produto entra na integração.
   //If !Empty(cXml) .Or. !lFiltra
      If lFiltra
         //Faz o filtro posicionando em todos os componentes. Se qualquer componente
         //entrar na integração, será realizado o processamento.
         SG1->(dbSetOrder(1))
         If SG1->(dbSeek(xFilial("SG1")+cProduto))
            While SG1->(!Eof()) .And. xFilial("SG1")+cProduto == SG1->(G1_FILIAL+G1_COD)
               If PCPFiltPPI("SG1", cProduto, "SG1")
                  lProc := .T.
                  Exit
               EndIf
               SG1->(dbSkip())
            End
            SG1->(RestArea(aAreaSG1))
         EndIf
      Else
         lProc := .T.
      EndIf
      If lProc
         //Adapter para criação do XML
         If Empty(cXml)
            aRetXML := MATI200("", TRANS_SEND, EAI_MESSAGE_BUSINESS, aRegDel)
         Else
            aRetXML := {.T.,cXml}
         EndIf
         /*
            aRetXML[1] - Status da criação do XML
            aRetXML[2] - String com o XML
         */
         If aRetXML[1]
            //Retira os caracteres especiais
            aRetXML[2] := EncodeUTF8(aRetXML[2])

            //Busca a data/hora de geração do XML
            aRetData := PCPxDtXml(aRetXML[2])
            /*
               aRetData[1] - Data de geração AAAAMMDD
               aRetData[1] - Hora de geração HH:MM:SS
            */

            //Envia o XML para o PCFactory
            aRetWS := PCPWebsPPI(aRetXML[2])
            /*
               aRetWS[1] - Status do envio (1 - OK, 2 - Pendente, 3 - Erro.)
               aRetWS[2] - Mensagem de retorno do PPI
            */

            If aRetWS[1] != "1" .And. Empty(cXml)
               If lPendAut
                  lRet := .T.
               Else
	               //"Atenção! Ocorreram erros na integração com o TOTVS MES. Erro: "
	               // XXXXXX
	               // XXXXXX
	               // "Deseja incluir/alterar/excluir a estrutura no protheus e gerar pendência para integração?"
	               If !lAuto .And. !MsgYesNo(STR0092 + AllTrim(aRetWS[2]) + CHR(10)+;
	                                            STR0093 + AllTrim(cOperacao) + STR0094)
	                  lRet := .F.
	               EndIf
	            EndIf
            EndIf

            If lRet
               //Cria o XML fisicamente no diretório parametrizado
               aRetArq := PCPXmLPPI(aRetWS[1],"SG1",cProduto,aRetData[1],aRetData[2],aRetXML[2])
               /*
                  aRetArq[1] Status da criação do arquivo. .T./.F.
                  aRetArq[2] Nome do XML caso tenha criado. Mensagem de erro caso não tenha criado o XML.
               */
               If !aRetArq[1]
                  If Empty(cXml) .And. !lPendAut
                     Alert(aRetArq[2])
                  EndIf
               Else
                  cNomeXml := aRetArq[2]
               EndIf
               If Empty(cNomeXml)
                  cGerouXml := "2"
               Else
                  cGerouXml := "1"
               EndIf
               //Cria a tabela SOF
               PCPCriaSOF("SG1",cProduto,aRetWS[1],cGerouXml,cNomeXml,aRetData[1],aRetData[2],__cUserId,aRetWS[2],aRetXML[2])
               //Array com os componentes que tiveram erro.
               If Type('aIntegPPI') == "A"
                  If aRetWS[1] != "1"
                     aAdd(aIntegPPI,{cProduto,aRetWS[2]})
                  EndIf
               EndIf
            EndIf
         EndIf
      EndIf
   //EndIf
   //Tratativa para retornar .F. mesmo quando é pendência automática;
   //Utilizado apenas para o programa de sincronização.
   If (AllTrim(FunName()) == "PCPA111" .Or. IsInCallStack("A200DoSub") .Or. IsInCallStack("Btn200Ok") .Or. IsInCallStack("Ma200Fecha")) ;
      .And. Len(aRetWs) > 0 .And. aRetWS[1] != "1"
      lRet := .F.
   EndIf
   RestArea(aArea)
   SG1->(RestArea(aAreaSG1))
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} erroPPI

Exibe uma tela com as mensagens de erro que aconteceram durante a integração

@param aDadosInt - Array com as informações dos erros.
@param nTotal	    - Quantidade total de registros processados.
@param nSucess   - Quantidade de registros processados com sucesso.
@param nError    - Quantidade de registros processados com erro.

@author  Lucas Konrad França
@version P118
@since   11/04/2016
@return  Nil
/*/
//-------------------------------------------------------------------------------------------------
Static Function erroPPI(aDadosInt, nTotal, nSucess, nError)
	Local oDlgErr, oPanel, oBrwErr, oGetTot, oGetErr, oGetSuc
	Local aCampos := {}
	Local aSizes  := {}

	DEFINE MSDIALOG oDlgErr TITLE STR0081 FROM 0,0 TO 350,800 PIXEL //"Erros integração TOTVS MES"

	oPanel := tPanel():Create(oDlgErr,01,01,,,,,,,401,156)
	//Cria o array dos campos para o browse
	aCampos := {STR0038,STR0084,STR0085,STR0086} //"Produto" / "Descrição" / "Status" / "Mensagem"
	aSizes  := {80, 110, 30, 400}

	// Cria Browse
	oBrwErr := TCBrowse():New( 0 , 0, 400, 155,,;
	                           aCampos,aSizes,;
	                           oPanel,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	// Seta vetor para a browse
	oBrwErr:SetArray(aDadosInt)
	oBrwErr:bLine := {||{ aDadosInt[oBrwErr:nAT,1],;
	                      aDadosInt[oBrwErr:nAt,2],;
	                      aDadosInt[oBrwErr:nAt,3],;
	                      aDadosInt[oBrwErr:nAt,4]}}
	oPanel:Refresh()
	oPanel:Show()

	@ 162,02 Say STR0087 Of oDlgErr Pixel //"Total de registros:"
	@ 160,48 MSGET oGetTot VAR nTotal SIZE 30,8 OF oDlgErr PIXEL NO BORDER WHEN .F.

	@ 162,90 Say STR0088 Of oDlgErr Pixel //"Processados com erro:"
	@ 160,150 MSGET oGetErr VAR nError SIZE 30,8 OF oDlgErr PIXEL NO BORDER WHEN .F.

	@ 162,190 Say STR0089 Of oDlgErr Pixel //"Processados com sucesso:"
	@ 160,260 MSGET oGetSuc VAR nSucess SIZE 30,8 OF oDlgErr PIXEL NO BORDER WHEN .F.

	DEFINE SBUTTON FROM 160,373 TYPE 1 ACTION (oDlgErr:End()) ENABLE OF oDlgErr
	ACTIVATE DIALOG oDlgErr CENTERED

Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A250descbr ³ Autor ³Michelle Ramos        ³ Data ³31/10/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Trazer a descrição do componente no browse                  ³±±
±±³           (chamada da função pelo dicionário no campo G1_COMP)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function A200descbr()

lretorno := ' '

lretorno := IF(!EMPTY(SG1->G1_COMP),POSICIONE('SB1',1,XFILIAL('SB1')+SG1->G1_COMP,'B1_DESC'),'')


return lretorno



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    a200VldOper ³ Autor ³Michelle Ramos        ³ Data ³03/09/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validar a operação x Componente							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function a200VldOper(aRecnosSGF,aRecnoSEM)

local lRet := .T.

// Valida SGF - Oper. x Compon.
	If SGF->(dbSeek(xFilial("SGF")+SG1->G1_COD))
		While SGF->(!Eof()) .And. SGF->(GF_FILIAL) == xFilial("SGF") .And. SGF->GF_PRODUTO == SG1->G1_COD
			If SGF->GF_COMP == SG1->G1_COMP // Encontra o componente a ser substituido
				nRecnoSGF := SGF->(Recno())
				If SGF->(dbSeek(xFilial("SGF")+SG1->G1_COD+SGF->GF_ROTEIRO+aDadosDest[1]))
					Help(" ",1,"A200SUBS",, AllTrim(RetTitle("GF_PRODUTO"))+": "+AllTrim(SG1->G1_COD)+"   "+;
					AllTrim(RetTitle("GF_ROTEIRO"))+": "+SGF->GF_ROTEIRO+"   "+;
					AllTrim(RetTitle("GF_COMP"))+": "+AllTrim(aDadosDest[1]), 4, 0) //Já existe o componente destino para o mesmo roteiro no cad. de Operação x Componente
					lRet := .F.
					Exit
				EndIf
				SGF->(dbGoto(nRecnoSGF))
				AADD(aRecnosSGF,nRecnoSGF)
			EndIf
			SGF->(dbSkip())
		EndDo
	ElseIf CVALTOCHAR(MV_PAR04) == '1'
		AADD(aRecnoSEM,SG1->(Recno()))
	Endif


Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} a200TamVar

Ajusta o tamanho das variáveis recebidas quando execução automática.

@author  Lucas Konrad França
@version P12
@since   13/09/2018
@return  Nil
/*/
//-------------------------------------------------------------------------------------------------
Static Function a200TamVar()
	Local nX := 0
	Local nY := 0

	If aAutoCab <> Nil
		For nX := 1 To Len(aAutoCab)
			If SubStr(aAutoCab[nX,1],1,2) == "G1" .And. ValType(aAutoCab[nX,2]) == "C" .And. Type("SG1->"+aAutoCab[nX,1]) == "C"
				aAutoCab[nX,2] := PadR(aAutoCab[nX,2],Len(&("SG1->"+aAutoCab[nX,1])))
			EndIf
		Next nX
	EndIf
	If aAutoItens <> Nil
		For nX := 1 To Len(aAutoItens)
			For nY := 1 To Len(aAutoItens[nX])
				If ValType(aAutoItens[nX,nY]) == "A"         .And. ;
					SubStr(aAutoItens[nX,nY,1],1,2) == "G1" .And. ;
					ValType(aAutoItens[nX,nY,2]) == "C"     .And. ;
					Type("SG1->"+aAutoItens[nX,nY,1]) == "C"
					aAutoItens[nX,nY,2] := PadR(aAutoItens[nX,nY,2],Len(&("SG1->"+aAutoItens[nX,nY,1])))
				EndIf
			Next nY
		Next nX
	EndIf
Return Nil



Function a200AllMark()

	Local aArea := GetArea()

	dbSelectArea(cAliastemp)
	dbGoTop()

	While (cAliastemp)->(!Eof())

		If ((cAliastemp)->G1_OK <> omark:mark())
			RecLock(cAliastemp, .F.)
				(cAliastemp)->G1_OK := omark:mark()
			MSUnlock()
		ElseIf ((cAliastemp)->G1_OK == omark:mark())
			RecLock(cAliastemp , .F.)
				(cAliastemp)->G1_OK := "  "
			MSUnlock()
		EndIf

		(cAliastemp)->(dbSkip())

	EndDo

	RestArea(aArea)

	oMark:Refresh()
	oMark:GoTop()

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} a200ExiEst

Verifica se a estrutura a ser incluída já existe.

@author  Michele Girardi
@version P12
@since   22/09/2020
@return  lRet
/*/
//-------------------------------------------------------------------------------------------------
Static Function a200ExiEst(cCodPai)

Local lRet      := .T.
Local aAreaSG1  := SG1->(GetArea())

cComp   := M->G1_COMP
cTrt    := M->G1_TRT
cIni    := M->G1_INI
cFim    := M->G1_FIM
cRevIni := M->G1_REVINI
cRevFim := M->G1_REVFIM

SG1->(dbSetOrder(1))
SG1->(dbSeek(xFilial('SG1')+cCodPai+cComp+cTrt))
Do While !SG1->(Eof())  .And. SG1->G1_FILIAL == xFilial("SG1");
						.And. SG1->G1_COD    == cCodPai;
						.And. SG1->G1_COMP   == cComp;
						.And. SG1->G1_TRT    == cTrt

	If SG1->G1_INI == cIni .And.;
		SG1->G1_FIM == cFim .And.;
		SG1->G1_REVINI == cRevIni .And.;
		SG1->G1_REVFIM == cRevFim
		Help( ,, 'Help',, STR0098, 1, 0 )
		lRet := .F.
		Exit
	EndIf
	SG1->(dbSkip())
EndDo

SG1->(RestArea(aAreaSG1))

Return lRet

/*/{Protheus.doc} fAjustStr
Remove os caracteres proibidos para nomes de arquivo
@type  Static Function
@author rafael.kleestadt
@since 18/02/2021
@version 1.0
@param cString, caractere, string a ser ajustada
@return cString, caractere, string sem caracteres proibidos para nome de arquivo
@example
(examples)
@see https://tdn.totvs.com/x/zIRsAQ
	 https://tdn.totvs.com/x/2oFzAQ
/*/
Static Function fAjustStr(cString)
Local aCarcProib  := {'~', '"', '#', '%', '&', '*', ':', '<', '>', '?', '/', '\', '{', '|', '}'}

	aEval(aCarcProib,{|x| cString := StrTran( cString, x, "-" ) })

Return cString
