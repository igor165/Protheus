#INCLUDE "TOTVS.CH"
#INCLUDE "QIPC010.CH"
#INCLUDE "PROTHEUS.CH"                                                                                       
#INCLUDE "DBTREE.CH"

#DEFINE ORD_PRO  1
#DEFINE LAU_FIM  2
#DEFINE LAU_OPE  3
#DEFINE LAU_LAB  4
#DEFINE DET_ENS  5

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIPC010  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 13/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Geral da Ordem de Producao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQIP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()

Local aRotina := {{STR0002,"AxPesqui"	, 0 , 1}    ,;	//"Pesquisar"
				  {STR0003,"Qpc010con"	, 0 , 2}    ,;	//"Consulta"
				  {STR0016,"Qpc010leg"	, 0 , 6,,.F.}} 	//"Legenda"

Return aRotina

Function QipC010()        
Local cCond := ""
Local cPerg := "QPC010"

Private __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
Private lProduto   := .F.
	
If Pergunte(cPerg,.T.)
	Private cCadastro :=STR0001 //"Consulta da Ordem de Produção"
	Private cTextSay  := ""
	Private oSay	  := Nil 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Array contendo as Rotinas a executar do programa      ³
	//³ ----------- Elementos contidos por dimensao ------------     ³
	//³ 1. Nome a aparecer no cabecalho                              ³
	//³ 2. Nome da Rotina associada                                  ³
	//³ 3. Usado pela rotina                                         ³
	//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
	//³    1 -Pesquisa e Posiciona em um Banco de Dados              ³
	//³    2 -Simplesmente Mostra os Campos                          ³
	//³    3 -Inclui registros no Bancos de Dados                    ³
	//³    4 -Altera o registro corrente                             ³
	//³    5 -Estorna registro selecionado gerando uma contra-partida³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aRotina := MenuDef()

	cCond := "      UPPER(QPK->QPK_OP) >= '"+ mv_par02 + "'"
	cCond += ".AND. UPPER(QPK->QPK_OP) <= '"+ mv_par03 + "'"

	cCond += ".AND. UPPER(QPK->QPK_PRODUT) >= '" + mv_par04 + "'"
	cCond += ".AND. UPPER(QPK->QPK_PRODUT) <= '" + mv_par05 + "'"
	
	cCond := UPPER(cCond)

	cCond += ".AND. DTOS(QPK->QPK_EMISSA)>='" +Dtos(mv_par06) + "'"
	cCond += ".AND. DTOS(QPK->QPK_EMISSA)<='" +Dtos(mv_par07) + "'"

	If mv_par01 == 1
		cCond += ".AND. " + Qpc010legX(1)	//Ordem de Producao em Aberto
	ElseIf mv_par01 == 2
		cCond += ".AND. " + Qpc010legX(2)	//Ordem de Producao sem coleta de resultados
	ElseIf mv_par01 == 3
		cCond += ".AND. " + Qpc010legX(3)   //Ordem de Producao com coleta de resultados
	ElseIf mv_par01 == 4
		cCond += ".AND. " + Qpc010legX(4)	//Ordem de Producao em Regime de Skip-Lote 
	EndIf

	dbSelectArea("QPK")
	QPK->(dbSetOrder(1))
	MsgRun(STR0023,STR0024,{||dbSetFilter({||&cCond},cCond)})		//"Selecionando as OPs..."###"Aguarde..."
	
	QPK->(dbGoTop())
	If QPK->(Eof())
		Help(" ",1,"RECNO")   
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Endereca a funcao de BROWSE                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		mBrowse( 6, 1,22,75,"QPK",,,,,, Qpc010leg())
	EndIf          
	dbSelectArea("QPK")
	Set Filter To
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QPC010Con ³ Autor ³ Marcelo Pimentel      ³ Data ³ 13/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta a dialog da consulta                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQIP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPC010Con()
LOCAL oTree
LOCAL oDlg
LOCAL oFont
LOCAL oPanel
LOCAL aEnch := {}
LOCAL nTop			:= oMainWnd:nTop+23
LOCAL nLeft			:= 5 //oMainWnd:nLeft+5
LOCAL nBottom		:= oMainWnd:nBottom-60
LOCAL nRight		:= oMainWnd:nRight-20  //oMainWnd:nRight-10
LOCAL nOldEncL		:= 1
LOCAL nOldEncC		:= 1
LOCAL bChange		:= {|| Nil }
LOCAL lFoundQPLF	:=.F.		//Flag para informar se encontrou Laudo Final
LOCAL lFoundQPM 	:=.F.		//Flag para informar se encontrou Laudo da Operacao
LOCAL lFoundQPLL	:=.F.		//Flag para informar se encontrou Laudo do Laboratorio
LOCAL aFields		:= {}
LOCAL aSVAlias		:= {}
LOCAL nRecnoQPLL	:= 0
LOCAL nRecnoQPLF	:= 0
LOCAL nRecnoQPM		:= 0
LOCAL cLabor		:= Criavar("QPL_LABOR")
LOCAL nRecnoQPR		:= 0
Local aCampos		:= {}
Local nC			:= 0
Local nY			:= 0
Local cRoteiro      := " "
Private aOP         := {}

// Posicionar SC2 e pegar o Roteiro escolhido
cRoteiro := QPC010ROT(QPK->QPK_OP) //Roteiro informado na Ordem de Producao
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona Revisao do Produto			             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QP6")
dbSetOrder(1)
dbSeek(xFilial("QP6")+QPK->QPK_PRODUT+Inverte(QPK->QPK_REVI))

AADD(aOp,{QPK->QPK_OP+QPK->QPK_LOTE+QPK->QPK_NUMSER,QPK->(Recno()),0,.f.,0,.f.,0,.f.,0})

dbSelectArea("QPR")
dbSetOrder(9)
dbSeek(xFilial("QPR")+QPK->QPK_OP+QPK->QPK_LOTE+QPK->QPK_NUMSER)
aOp[Len(aOp),3] := Recno()
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona para carregar variaveis de memoria do QPL - Laudo Final     ³
//³ Executa esse processo para agilizar na visualizacao                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QPL")
dbSetOrder(3)
aOp[Len(aOp),4]:=dbSeek(xFilial("QPL")+QPK->QPK_OP+QPK->QPK_LOTE+QPK->QPK_NUMSER+cRoteiro+Space(02)+cLabor,.T.)
If aOp[Len(aOp),4]
	aOp[Len(aOp),5]:=Recno()
EndIf
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona para carregar variaveis de memoria do QPL - Laudo Labor     ³
//³ Executa esse processo para agilizar na visualizacao                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QPL")
dbSetOrder(3)
aOp[Len(aOp),6]:=dbSeek(xFilial("QPL")+QPK->QPK_OP+QPK->QPK_LOTE+QPK->QPK_NUMSER+cRoteiro+QPR->QPR_OPERAC+QPR->QPR_LABOR,.T.)
If aOp[Len(aOp),6]
	aOp[Len(aOp),7]:=Recno()
EndIf
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona para carregar variaveis de memoria do QPM - Laudo Operacao  ³
//³ Executa esse processo para agilizar na visualizacao                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QPM")
dbSetOrder(3)
aOp[Len(aOp),8]:=dbSeek(xFilial("QPM")+QPK->QPK_OP+QPK->QPK_LOTE+QPK->QPK_NUMSER+cRoteiro+QPR->QPR_OPERAC,.T.)
If aOp[Len(aOp),8]
	aOp[Len(aOp),9]:=Recno()
EndIf
		
DEFINE FONT oFont NAME "Arial" SIZE 0, -10
DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight 

oFolder := TFolder():New(12,0,{STR0003},{},oDlg,,,, .T., .F.,Iif(!setMDIChild(),nRight-nLeft,nRight-nLeft-500),Iif(!setMDIChild(),nBottom-nTop-12,nBottom-nTop-12),) //"Consulta"
oFolder:aDialogs[1]:oFont := oDlg:oFont
oTree := dbTree():New(2, 2,((nBottom-nTop)/2)-34,159,oFolder:aDialogs[1],,,.T.)
oTree:SetFont(oFont)
oTree:lShowHint:= .F. 
oPanel := TPanel():New(2,160,'',oFolder:aDialogs[1], oDlg:oFont, .T., .T.,, ,(nRight-nLeft)/2-160,((nBottom-nTop)/2)-35,.T.,.T. )
QPC010Tree(@oTree,"")
oTree:bChange := {|| QPC010DlgV(@oTree,aSValias,@aEnch,{0,0,((nBottom-nTop)/2)-34,(nRight-nLeft)/2-160},@nOldEncL,@nOldEncC,@oPanel),Eval(bChange)}
lOneColumn := If((nRight-nLeft)/2-178>312,.F.,.T.)

For nY:=1 to Len(aOP) 

	AADD(aEnch,{NIL,NIL,NIL,NIL,NIL})
	
	If aOP[nY,4] //Laudo Final
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Campos que devem aparecer na Enchoice                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCampos	:= {"QPL_DTENLA","QPL_HRENLA","QPL_LAUDO","QPL_DTLAUD","QPL_HRLAUD","QPL_DTVAL",;
		"QPL_TAMLOT","QPL_QTREJ","QPL_DTDILA","QPL_HRDILA","QPL_JUSTLA"}
		
		For nC := 1 To Len(aCampos)
			Aadd(aFields,aCampos[nC])
		Next nC 
		
		AADD(aSVAlias,"QPL ")
		RegToMemory("QPL",.F.)
		aEnch[nY,LAU_FIM]:=MsMGet():New("QPL",aOP[nY,5],2,,,,aFields,{0,0,((nBottom-nTop)/2)-25,(nRight-nLeft)/2-160},,3,,,,oPanel,,,lOneColumn)
		aCampos := {}
	EndIf 
	
	If aOP[nY,8] // Laudo da Operacao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Campos que devem aparecer na Enchoice                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCampos	:= {"QPM_DTENLA","QPM_HRENLA","QPM_LAUDO","QPM_DTLAUD","QPM_HRLAUD","QPM_DTVAL",;
		"QPM_TAMLOT","QPM_QTREJ","QPM_DTDILA","QPM_HRDILA","QPM_JUSTLA"}
		
		For nC := 1 To Len(aCampos)
			Aadd(aFields,aCampos[nC])
		Next nC
		
		AADD(aSVAlias,"QPM ")
		RegToMemory("QPM",.F.)            
		aEnch[nY,LAU_OPE]:=MsMGet():New("QPM",aOP[nY,9],2,,,,aFields,{0,0,((nBottom-nTop)/2)-25,(nRight-nLeft)/2-160},,3,,,,oPanel,,,lOneColumn)
		aCampos := {}
	EndIf 
	
	If aOP[nY,6] //Laudo do Laboratorio
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Campos que devem aparecer na Enchoice                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCampos := {"QPL_DTENLA","QPL_HRENLA","QPL_LAUDO","QPL_DTLAUD","QPL_HRLAUD","QPL_DTVAL",;
		"QPL_TAMLOT","QPL_QTREJ","QPL_DTDILA","QPL_HRDILA","QPL_JUSTLA"}
		
		For nC := 1 To Len(aCampos)
			Aadd(aFields,aCampos[nC])
		Next nC
		
		AADD(aSVAlias,"QPLL") 
		QPL->(dbGoTo(aOP[nY,7]))
		RegToMemory("QPL",.F.)       
		aEnch[nY,LAU_LAB]:=MsMGet():New("QPL",aOP[nY,7],2,,,,aFields,{0,0,((nBottom-nTop)/2)-25,(nRight-nLeft)/2-160},,3,,,,oPanel,,,lOneColumn)
		aCampos := {}  
	EndIf
	
	QPK->(dbGoTo(aOP[nY,2]))
	RegToMemory("QPK",.F.)
	aEnch[nY,ORD_PRO]:= MsMGet():New("QPK",aOP[nY,2],2,,,,,{0,0,((nBottom-nTop)/2)-25,(nRight-nLeft)/2-160},,3,,,,oPanel,,,lOneColumn)
Next nY   
                 
//Posiciona na primeira OP
QPK->(dbGoTo(aOP[1,2]))
RegToMemory("QPK",.F.)
aEnch[1,ORD_PRO]:Refresh()

DbSelectArea(oTree:cArqTree)
DbGotop() 
oTree:EndUpdate()
oTree:TreeSeek(T_CARGO)
oTree:Refresh()
aCampos	:= {}
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})
//Release Object oTree

Return(.T.) 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QPC010Tree³ Autor ³Marcelo Pimentel       ³ Data ³ 15-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta o Tree da consulta de produto                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³QIPC010                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPC010Tree(oTree,cAlias)
Local cChaveQPL	:= ''
Local cChaveQPR	:= ''
Local cEnsaio	:= ''
Local cProduto	:= ''
Local cRoteiro	:= ''
Local cRevi		:= ''
Local aOper		:= {}
Local cOrdProd	:= ''
Local nC		:= 0
Local nClab		:= 0
Local aOperacao	:= {}
Local cLabor	:= ''
Local nRecnoQPM	:= 0
Local nRecnoQPL	:= 0  
Local nY        := 0

DEFAULT cAlias	:= ""

// Monta tree na primeira vez
If Empty(cAlias)
	oTree:BeginUpdate()
	oTree:Reset()
	oTree:EndUpdate()
EndIf

oTree:BeginUpdate()  

For nY:=1 to Len(aOP) 

	QPK->(dbGoTo(aOp[nY,2]))
	If Empty(cAlias)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica dados cadastrais do produto                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		oTree:TreeSeek("")
			oTree:AddItem(STR0005+QPK->QPK_OP+STR0025+QPK->QPK_LOTE+STR0026+QPK->QPK_NUMSER+Space(10),StrZero(nY,2)+"01QPK "+StrZero(aOp[nY,2],11),"BMPCONS","BMPCONS",,,1) //"Dados Gerais - O.P.: "
	EndIf
	
	// Monta Laudo Final
	If Empty(cAlias).And. aOp[nY,5]  <> 0
		oTree:TreeSeek(StrZero(nY,2)+"01QPK "+StrZero(aOp[nY,2],11))
		oTree:AddItem(STR0006,StrZero(nY,2)+"02QPL "+StrZero(aOp[nY,5],11),"BMPTABLE","BMPTABLE",,,2) //"Laudo Final"
	EndIf
	
	cProduto	:= QPK->QPK_PRODUT
	cRevi		:= QPK->QPK_REVI
	cOrdProd	:= QPK->QPK_OP
	cRoteiro	:= QPC010ROT(QPK->QPK_OP) //roteiro informado na Ordem de Producao
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta  array das Operacoes  	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(QPR->QPR_OPERAC) 
		aOper := QPC010Ope(cProduto,cRoteiro,cRevi,cOrdProd)
	EndIf
	For nC := 1 To Len(aOper)
		
		dbSelectArea("QPM")
		dbSetOrder(3)
		If dbSeek(xFilial("QPM")+cOrdProd+QPK->QPK_LOTE+QPK->QPK_NUMSER+cRoteiro+aOper[nC,1])
			oTree:TreeSeek(StrZero(nY,2)+"01QPK "+StrZero(aOp[nY,2],11))
			oTree:AddItem(STR0007+QPM->QPM_OPERAC+"-"+AllTrim(aOper[nC,2]),StrZero(nY,2)+"03QPM "+StrZero(Recno(),11),"BMPTABLE","BMPTABLE",,,2) //"Laudo Operação: "
			nRecnoQPM := StrZero(nY,2)+"03QPM "+StrZero(Recno(),11)
		Else
			nRecnoQPM := StrZero(nY,2)+"01QPK "+StrZero(aOp[nY,2],11)
		EndIf
		
		aOperacao	:= aClone(aOper[nC])
		aLab		:= QPC010Lab(cProduto,cRoteiro,aOperacao,cRevi)
		cLabor		:= ''
		For nClab	:= 1 To Len(aLab)
			
			If cLabor <> aLab[nCLab,1]
				cLabor := aLab[nCLab,1]
				
				cChaveQPL	:= cOrdProd+QPK->QPK_LOTE+QPK->QPK_NUMSER+cRoteiro+aOper[nC,1]+aLab[nCLab,1]
				dbSelectArea("QPL")
				dbSetOrder(3)
				If dbSeek(xFilial("QPL")+cChaveQPL)
					// Monta Laudo Laboratorio
					oTree:TreeSeek(nRecnoQPM)
					oTree:AddItem(STR0008+QPL->QPL_LABOR,StrZero(nY,2)+"04QPLL"+StrZero(Recno(),11),"BMPTABLE","BMPTABLE",,,2) //"Laudo Laboratório: "
					nRecnoQPL := StrZero(nY,2)+"04QPLL"+StrZero(Recno(),11)
				Else
					nRecnoQPL := StrZero(nY,2)+"01QPK "+StrZero(QPK->(Recno()),11)
				EndIf
				
				cChaveQPR	:= cOrdProd+QPK->QPK_LOTE+QPK->QPK_NUMSER+cRoteiro+aOper[nC,1]+aLab[nClab,1]
				cEnsaio		:= ''
				
				dbSelectArea("QPR")
				dbSetOrder(9)
				dbSeek(xFilial("QPR")+cChaveQPR)
				While !Eof() .And. QPR->QPR_FILIAL == xFilial("QPR") .And.;
					QPR->QPR_OP+QPR->QPR_LOTE+QPR->QPR_NUMSER+QPR->QPR_ROTEIR+QPR->QPR_OPERAC+QPR->QPR_LABOR == cChaveQPR
					// Monta Ensaios
					If cEnsaio <> QPR->QPR_ENSAIO
						cEnsaio := QPR->QPR_ENSAIO
						oTree:TreeSeek(nRecnoQPL)
						oTree:AddItem(STR0009+QPR->QPR_ENSAIO,StrZero(nY,2)+"05QPR "+StrZero(QPR->(Recno()),11),"BMPTABLE","BMPTABLE",,,2) //"Ensaio: "
					EndIf
					dbSkip()
				EndDo
			EndIf
		Next nClab
		
	Next nC
	
Next nY 

oTree:EndUpdate()
oTree:Refresh() 

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QPC010DlgV³ Autor ³Marcelo Pimentel       ³ Data ³ 15-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que mostra as informacoes detalhadas da consulta       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³QIPC010                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QPC010DlgV(oTree,aSVAlias,aEnch,aPos,nOldEncL,nOldEncC,oPanel)
Local cAlias	:= SubStr(oTree:GetCargo(),5,4)
Local nPos      := Val(SubStr(oTree:GetCargo(),1,2))
Local nRecView	:= Val(SubStr(oTree:GetCargo(),9,11))
Local nPosAlias	:= aScan(aSVAlias,cAlias)
Local aDados	:= {}
Local oScroll

If Len(aEnch[nPos]) >= 1 .AND. ValType(aEnch[nPos,ORD_PRO]) == "O"
	aEnch[nPos,ORD_PRO]:Hide()
EndIf
If Len(aEnch[nPos]) >= 2 .AND. ValType(aEnch[nPos,LAU_FIM]) == "O"
	aEnch[nPos,LAU_FIM]:Hide()
EndIf
If Len(aEnch[nPos]) >= 3 .AND. ValType(aEnch[nPos,LAU_OPE]) == "O"
	aEnch[nPos,LAU_OPE]:Hide()
EndIf
If Len(aEnch[nPos]) >= 4 .AND. ValType(aEnch[nPos,LAU_LAB]) == "O"
	aEnch[nPos,LAU_LAB]:Hide()
EndIf
If Len(aEnch[nPos]) >= 5 .AND. ValType(aEnch[nPos,DET_ENS]) == "O"
	aEnch[nPos,DET_ENS]:Hide()
EndIf

If nRecView <> 0 .And. cAlias <> "QPR"
	dbSelectArea(Substr(cAlias,1,3))
	MsGoto(nRecView)
	RegToMemory(Substr(cAlias,1,3),.F.)
	If nPosAlias > 0
		Do Case
			Case cAlias == "QPK "
				aEnch[nPos,ORD_PRO]:Refresh()
				aEnch[nPos,ORD_PRO]:Show()
				nOldEncC:=1
				nOldEncL:=nPos     
			Case cAlias == "QPL " .And. aOP[nPos,DET_ENS] <> 0
				aEnch[nPos,LAU_FIM]:Refresh()
				aEnch[nPos,LAU_FIM]:Show()
				nOldEncC:=2
				nOldEncL:=nPos     
			Case cAlias == "QPM " .And. aOP[nPos,9] <> 0
				aEnch[nPos,LAU_OPE]:Refresh()    
				aEnch[nPos,LAU_OPE]:Show()
				nOldEncC:=3
				nOldEncL:=nPos     
			Case cAlias == "QPLL" .And. aOP[nPos,7] <> 0
			   	aEnch[nPos,LAU_LAB]:Refresh()  
				aEnch[nPos,LAU_LAB]:Show()
				nOldEncC:=4
				nOldEncL:=nPos 
		EndCase
	Else
		Do Case
			Case cAlias == "QPK "
				aAdd(aSVAlias,"QPK")
				aEnch[nPos,ORD_PRO]:Show()
				aEnch[nPos,ORD_PRO]:Refresh()
				nOldEncC:=1
				nOldEncL:=nPos     
			Case cAlias == "QPL "
				aAdd(aSVAlias,"QPL")
				aEnch[nPos,LAU_FIM]:Show()
				aEnch[nPos,LAU_FIM]:Refresh()
				nOldEncC:=2
				nOldEncL:=nPos     
			Case cAlias == "QPM "
				aAdd(aSVAlias,"QPM")
				aEnch[nPos,LAU_OPE]:Show()
				aEnch[nPos,LAU_OPE]:Refresh()               
				nOldEncC:=3
				nOldEncL:=nPos     
			Case cAlias == "QPLL"
			    aAdd(aSVAlias,"QPLL")
				aEnch[nPos,LAU_LAB]:Show()
				aEnch[nPos,LAU_LAB]:Refresh()
				nOldEncC:=4
				nOldEncL:=nPos
		EndCase
	EndIf
ElseIf cAlias == "QPR "
	aDados	:= QpcGetaDad(nRecView)   
	If ValType(aEnch[nPos,DET_ENS]) == "O"
		MsFreeObj(@aEnch[nPos,DET_ENS], .T.)
		aEnch[nPos,DET_ENS]:= Nil
	EndIf
	oScroll:= TScrollBox():New(oPanel,aPos[1],aPos[2],aPos[3],aPos[4])
	QPScrDisp(aDados,@oScroll,@oPanel,aPos,{{1,CLR_BLUE}})
	aEnch[nPos,DET_ENS]:=oScroll
	aEnch[nPos,DET_ENS]:Show()
	nOldEncC:=5 
	nOldEncL:=nPos     
EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QPScrDisp  ³ Autor ³Marcelo Pimentel      ³ Data ³ 16-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta scroll box com texto dinamico                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³QIPC010                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPScrDisp(aInfo,oScroll,oPanel,aPos,aCoresCols)
Local nX,ny,nAchou
Local cCor,cCorDefault:=CLR_BLACK
Local nCols   :=1,nSomaCols:=0
Local nLinAtu := 5
Local nColAtu := 10
Local oBmp
DEFAULT aCoresCols:={}
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
If Len(aInfo) > 0
//	@ 0,0 BITMAP oBmp RESNAME "WIZARD" oF oScroll SIZE 60,50 ADJUST NOBORDER WHEN .F. PIXEL
	nCols:=Len(aInfo[1])
	For nx := 1 to Len(aInfo)
		For ny := 1 to nCols
			If CalcFieldSize("C",Len(aInfo[nx,ny]),0) > nSomaCols
				nSomaCols:=CalcFieldSize("C",Len(aInfo[nx,1]),0)
			EndIf	
		Next ny
	Next  
	For nx := 1 to Len(aInfo)
		For ny := 1 to nCols
			nAchou  := Ascan(aCoresCols,{|x| x[1]== ny})
			If nAchou > 0
				cCor:=aCoresCols[nAchou,2]
			Else
				cCor:=cCorDefault
			EndIf
			cTextSay:= "{||' "+STRTRAN(aInfo[nx][ny],"'",'"')+" '}"
			oSay    := TSay():New(nLinAtu,nColAtu,MontaBlock(cTextSay),oScroll,,oFont,,,,.T.,cCor,,,,,,,,)
			nColAtu += nSomaCols
		Next ny
		nLinAtu += 9
		nColAtu := 10
	Next
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QpcGetaDad ³ Autor ³Marcelo Pimentel      ³ Data ³ 20-06-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta vetor para visualizar o descritivo do ensaio            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³QIPC010                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QpcGetaDad(nRecnoQPR)
Local aDados	:= {}
Local aArea		:= GetArea()
Local cOperac	:= ""
Local cLabor	:= ""
Local cOP		:= ""
Local cEnsaio	:= ""
Local nResApr	:= 0
Local nResRep	:= 0
Local cCarta	:= ""
Local cPlAmEns	:= ""
Local cChave	:= ""
Local cNewEns	:= ""
Local cRoteiro  := ""
Local cLote  := ""

cRoteiro := QPC010ROT(QPK->QPK_OP) //Roteiro de Operacoes informado na Ordem de Producao
cLote := QPK->QPK_LOTE

dbSelectArea("QPR")
dbGoTo(nRecnoQPR)
cChave := QPR_OP+QPR_OPERAC+QPR_LABOR+QPR_ENSAIO
While !Eof() .And. QPR->QPR_FILIAL == xFilial("QPR") .And.	QPR->QPR_OP+QPR->QPR_OPERAC+QPR->QPR_LABOR+QPR->QPR_ENSAIO == cChave
	If cNewEns <> QPR->QPR_ENSAIO
		cNewEns := QPR->QPR_ENSAIO
		
		QP1->(dbSetOrder(1))
		If QP1->(dbSeek(xFilial("QP1")+QPR->QPR_ENSAIO))
			Aadd(aDados,{"",""})
			Aadd(aDados,{STR0017,QP1->QP1_ENSAIO})		//"Ensaio "
			Aadd(aDados,{"",""})
			Aadd(aDados,{STR0018,QP1->QP1_CARTA})		//"Carta "
			Aadd(aDados,{"",""})
			cCarta := QPCarta(QP1->QP1_ENSAIO)
			If cCarta <> "TXT"
				QP7->(dbSetOrder(1))
				If QP7->(dbSeek(xFilial("QP7")+QPR->QPR_PRODUT+QPR->QPR_REVI+cRoteiro+QPR->QPR_OPERAC+QPR->QPR_ENSAIO))
					If QP7->QP7_PLAMO == "I"
						cPlAmEns	:= QP7->QP7_DESPLA
					ElseIf QP7->QP7_PLAMO == "N"
						Aadd(aDados,{STR0010,"NBR5426"})		//"Plano de Amostragem "
						Aadd(aDados,{Substr(QP7->QP7_DESPLA,1,3),AllTrim(Substr(QP7->QP7_DESPLA,4,16))})
						Aadd(aDados,{Substr(QP7->QP7_DESPLA,20,13),AllTrim(substr(QP7->QP7_DESPLA,33,3))})
						Aadd(aDados,{Substr(QP7->QP7_DESPLA,36,10),AllTrim(substr(QP7->QP7_DESPLA,49,2))})
						cPlAmEns	:= ""
					ElseIf QP7->QP7_PLAMO == "T"
						cPlAmEns	:= STR0011+QP7->QP7_DESPLA		//"Texto "
					ElseIf QP7->QP7_PLAMO == "Z"
						cPlAmEns	:= STR0012+QP7->QP7_DESPLA		//"Zero Defeito "
					EndIf
				EndIf
			Else
				QP8->(dbSetOrder(1))
				If QP8->(dbSeek(xFilial("QP8")+QPR->QPR_PRODUT+QPR->QPR_REVI+cRoteiro+QPR->QPR_OPERAC+QPR->QPR_ENSAIO))
					If QP8->QP8_PLAMO == "I"
						cPlAmEns	:= QP8->QP8_DESPLA
					ElseIf QP8->QP8_PLAMO == "N"
						Aadd(aDados,{STR0010,"NBR5426"})		//"Plano de Amostragem "
						Aadd(aDados,{Substr(QP8->QP8_DESPLA,1,3),AllTrim(Substr(QP8->QP8_DESPLA,4,16))})
						Aadd(aDados,{Substr(QP8->QP8_DESPLA,20,13),AllTrim(substr(QP8->QP8_DESPLA,33,3))})
						Aadd(aDados,{Substr(QP8->QP8_DESPLA,36,10),AllTrim(substr(QP8->QP8_DESPLA,49,2))})
						cPlAmEns	:= ""
					ElseIf QP8->QP8_PLAMO == "T"
						cPlAmEns	:= STR0011+QP8->QP8_DESPLA		//"Texto "
					ElseIf QP8->QP8_PLAMO == "Z"
						cPlAmEns	:= STR0012+QP8->QP8_DESPLA		//"Zero Defeito "
					EndIf
				EndIf
			EndIf
			Aadd(aDados,{"",""})
			If !Empty(cPlAmEns)
				Aadd(aDados,{STR0010,AllTrim(cPlAmEns)})		//"Plano de Amostragem "
			EndIf
			
			aAreaBack:=GetArea()
			cOperac	:= QPR->QPR_OPERAC
			cLabor	:= QPR->QPR_LABOR
			cOP		:= QPR->QPR_OP
			cEnsaio	:= QPR->QPR_ENSAIO

			dbSelectArea("QPR")
			dbSetOrder(8)
			If dbSeek(xFilial("QPR")+cOp+cLote+cOperac+cLabor+cEnsaio)
				While !Eof() .And. QPR_FILIAL+QPR_OP+QPR->QPR_LOTE+QPR_OPERAC+QPR_LABOR+QPR_ENSAIO == xFilial()+cOp+cLote+cOperac+cLabor+cEnsaio
					If QPR->QPR_RESULT == "A"
						nResApr++
					Else
						nResRep++
					EndIf
					dbSkip()
				EndDo
			EndIf
			Aadd(aDados,{STR0013,AllTrim(Str(nResApr+nResRep,8))})			//"Total de Medições   "
			Aadd(aDados,{STR0014,AllTrim(Str(nResApr,8))})					//"Medições Aprovadas  "
			Aadd(aDados,{STR0015,AllTrim(Str(nResRep,8))})					//"Medições Reprovadas "
			RestArea(aAreaBack)
		EndIf
	EndIf
	dbSkip()
EndDo
RestArea(aArea)
Return(aDados)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QPC010Ope  ³ Autor ³Marcelo Pimentel      ³ Data ³ 28-06-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta vetor para o Roteiro das Operacoes					    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³QIPC010                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QPC010Ope(cProduto,cRoteiro,cRevi,cOrdProd)
Local cQuery := ''
Local aOper := {}
Local aArea	:= GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona em array as Operacoes  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QQK")
dbSetOrder(1)

cQuery := "SELECT QQK_FILIAL, QQK_PRODUT, QQK_CODIGO, QQK_OPERAC, QQK_DESCRI, QQK_RECURS, QQK_OPE_OB, QQK_SEQ_OB, QQK_LAU_OB"
cQuery += " FROM " + RetSqlName("QQK")
cQuery += " QQK WHERE QQK_FILIAL = '" + xFilial("QQK") + "' AND "
cQuery += " QQK.QQK_PRODUT = '" + cProduto + "' AND "
cQuery += " QQK.QQK_CODIGO = '" + cRoteiro + "' AND " 
cQuery += " QQK.QQK_REVIPR = '" + cRevi + "'AND " 
    cQuery += " QQK.D_E_L_E_T_<>'*' "
cQuery += " ORDER BY " + SqlOrder(QQK->(IndexKey()))
		
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QIPTRB", .F., .T.)
dbSelectArea("QIPTRB")
While !Eof()
	Aadd(aOper,{ QIPTRB->QQK_OPERAC, QIPTRB->QQK_DESCRI, QIPTRB->QQK_RECURS, QIPTRB->QQK_OPE_OB, QIPTRB->QQK_SEQ_OB, QIPTRB->QQK_LAU_OB })
	cOpera := QIPTRB->QQK_OPERAC
	dbSkip()
Enddo
dbCloseArea()
RestArea(aArea)
     
RestArea(aARea)
Return(aOper)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QPC010Lab  ³ Autor ³Marcelo Pimentel      ³ Data ³ 28-06-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta vetor para o Laboratorio na especificacao				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³QIPC010                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QPC010Lab(cProduto,cRoteiro,aOperacao,cRevi)
Local cQuery := ''
Local aLab  := {}
Local aArea	:= GetArea()

aLab := {}
dbSelectArea("QP7")
dbSetOrder(1)
	
aAreaQP7 := GetArea()
cQuery := "SELECT QP7.QP7_FILIAL, QP7.QP7_PRODUT, QP7.QP7_REVI, QP7.QP7_CODREC, QP7.QP7_OPERAC, QP7.QP7_ENSAIO, QP7.QP7_LABOR, QP7.QP7_SEQLAB, QP7.QP7_ENSOBR, QP7.QP7_PLAMO"
cQuery += " FROM " + RetSqlName("QP7")
cQuery += " QP7 WHERE QP7.QP7_FILIAL = '" + xFilial("QP7") + "' AND "
cQuery += " QP7.QP7_PRODUT = '" + cProduto + "' AND "
cQuery += " QP7.QP7_REVI = '" + cRevi + "' AND "
cQuery += " QP7.QP7_CODREC = '" + cRoteiro + "' AND "
cQuery += " QP7.QP7_OPERAC = '" + aOperacao[1] + "' AND "
    cQuery += " QP7.D_E_L_E_T_<>'*' "
cQuery += " ORDER BY " + SqlOrder(QP7->(IndexKey()))

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRBQP7", .F., .T.)
dbSelectArea("TRBQP7")
While !Eof()
	Aadd( aLab, {TRBQP7->QP7_LABOR, TRBQP7->QP7_SEQLAB,TRBQP7->QP7_ENSAIO,TRBQP7->QP7_ENSOBR,;
	TRBQP7->QP7_CODREC, TRBQP7->QP7_PLAMO } )
	dbSkip()
EndDo
dbCloseArea()
RestArea(aAreaQP7)
	
dbSelectArea("QP8")
dbSetOrder(1)

aAreaQP8 := GetArea()
cQuery := "SELECT QP8.QP8_FILIAL,QP8.QP8_PRODUT,QP8.QP8_REVI,QP8.QP8_CODREC,QP8.QP8_OPERAC,QP8.QP8_ENSAIO,QP8.QP8_LABOR,QP8.QP8_SEQLAB,QP8.QP8_ENSOBR,QP8.QP8_PLAMO"
cQuery += " FROM " + RetSqlName("QP8")
cQuery += " QP8 WHERE QP8.QP8_FILIAL = '" + xFilial("QP8") + "' AND "
cQuery += " QP8.QP8_PRODUT = '" + cProduto + "' AND "
cQuery += " QP8.QP8_REVI = '" + cRevi + "' AND "
cQuery += " QP8.QP8_CODREC = '" + cRoteiro + "' AND "
cQuery += " QP8.QP8_OPERAC = '" + aOperacao[1] + "' AND "
    cQuery += " QP8.D_E_L_E_T_<>'*' "
cQuery += " ORDER BY " + SqlOrder(QP8->(IndexKey()))

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRBQP8", .F., .T.)
dbSelectArea("TRBQP8")
While !Eof()
	Aadd( aLab, {TRBQP8->QP8_LABOR, TRBQP8->QP8_SEQLAB, TRBQP8->QP8_ENSAIO,;
	TRBQP8->QP8_ENSOBR, TRBQP8->QP8_CODREC, TRBQP8->QP8_PLAMO} )
	dbSkip()
Enddo
dbCloseArea()
RestArea(aAreaQP8)

RestArea(aArea)

aLab := ASort( aLab ,,, { |x,y| x[1]+x[2] < y[1]+y[2] } )

Return(aLab)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Qpc010leg  ³ Autor ³ Marcelo              ³ Data ³01.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse ou retorna a ³±±
±±³          ³ para o BROWSE                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³QIPC010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Qpc010leg(cAlias, nReg)
Local aLegenda := {	{"BR_CINZA"		,STR0019 },;	//"OP em Aberto"
					{"BR_AMARELO"	,STR0020 },;	//"OP s/ Resultado"
					{"BR_AZUL"		,STR0021 },;	//"OP c/ Resultado"
					{"BR_VERDE"		,STR0022 }}		//"OP em Skip-Lote"
Local uRetorno := .T.

If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	Aadd(uRetorno, { Qpc010legX(1), aLegenda[1][1] } ) //"OP em Aberto"
	Aadd(uRetorno, { Qpc010legX(2), aLegenda[2][1] } ) //"OP s/ Resultado"
	Aadd(uRetorno, { Qpc010legX(3), aLegenda[3][1] } ) //"OP c/ Resultado"
	Aadd(uRetorno, { Qpc010legX(4), aLegenda[4][1] } ) //"OP em Skip-Lote"
Else
	BrwLegenda(STR0001, STR0016 , aLegenda)		//"Consulta da Ordem de Produção"###"Legenda"
Endif
Return uRetorno   

/*/{Protheus.doc} Qpc010legX
Função genérica que retorna a condição para exibir as legendas
@type  Function
@author thiago.rover
@since 13/01/2022
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function Qpc010legX(nOpc)
	Local aArea   := GetArea()
	Local cReturn := ''
	
	DbSelectArea("SH6")
	
	If nOpc == 1																											 //"OP em Aberto"
		cReturn := "EMPTY(QPK->QPK_SITOP)"																						
	ElseIf nOpc == 2																										 //"OP s/ Resultado"	
		cReturn := "(QPK->QPK_SITOP == '1' .OR. QPK->QPK_LAUDO == '0') .and. !EMPTY(QPK->QPK_SITOP)"																						
	ElseIf nOpc == 3																										 //"OP c/ Resultado"
		cReturn := "!(QPK->QPK_SITOP $ '1|7') .AND. !Empty(Posicione('QPR', 8, xFilial('QPR')+QPK->QPK_OP+QPK->QPK_LOTE, 'QPR_RESULT'))"
	ElseIf nOpc == 4																										 //"OP em Skip-Lote"
		cReturn := "(QPK->QPK_SITOP == '2' .AND. QPC010Ver() .AND. QPK->QPK_LAUDO == 'A' .AND. !EMPTY(QPK->QPK_CERQUA)) .AND. Empty(Posicione('QPR', 8, xFilial('QPR')+QPK->QPK_OP+QPK->QPK_LOTE, 'QPR_RESULT'))"
	EndIf

	RestArea(aArea)

Return cReturn

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QPC010ROT  ³ Autor ³ Cicero               ³ Data ³20.07.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pega o Roteiro  escolhido  no SC2                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³QIPC010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QPC010ROT(cOp)
Local cRot := "00"
dbSelectArea("SC2")
dbSetOrder(1)
If dbSeek(xFilial("SC2")+cOp)
	cRot := SC2->C2_ROTEIRO
EndIf
Return cRot   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPC010Ver  ³ Autor ³ Sergio S. Fuzinaka   ³ Data ³  27.08.07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se a OP/Apontamento eh Certificada por Skip-Lote     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³QIPC010                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPC010Ver()

Local lRet 		:= .F.
Local aArea		:= GetArea()
Local aAreaSC2	:= SC2->(GetArea())
Local aAreaSH6	:= SH6->(GetArea())
Local cInspecao := GetMV("MV_QINSPEC",.T.,"1") 

If cInspecao == "1"
	SC2->(dbSelectArea("SC2"))
	SC2->(dbSetOrder(1))
	If SC2->(dbSeek(xFilial("SC2")+QPK->QPK_OP))
		If SC2->C2_VERIFI == 2
			lRet := .T.
		Endif
	Endif
Else
	SH6->(dbSelectArea("SH6"))
	SH6->(dbSetOrder(1))
	If 	SH6->(dbSeek(xFilial("SH6")+QPK->QPK_OP))
		If SH6->H6_VERIFI == 2
			lRet := .T.
		Endif
	Endif
Endif

RestArea(aAreaSC2)
RestArea(aAreaSH6)
RestArea(aArea)

Return(lRet)
