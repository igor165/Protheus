#INCLUDE "QPPA260.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA260  ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 07.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Checklist APQP - A2 INFORMACAO DO PROJETO                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA260(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PPAP                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui"  , 	0, 1,,.F.},; //"Pesquisar"
					{ OemToAnsi(STR0002), "PPA260Roti", 	0, 2},; 	  //"Visualizar"
					{ OemToAnsi(STR0003), "PPA260Roti", 	0, 3},; 	  //"Incluir"
					{ OemToAnsi(STR0004), "PPA260Roti", 	0, 4},; 	  //"Alterar"
					{ OemToAnsi(STR0005), "PPA260Roti", 	0, 5},; 	  //"Excluir"
					{ OemToAnsi(STR0088), "QPPR260(.T.)", 	0, 6,,.T.} } //"Imprimir"

Return aRotina

Function QPPA260()

Private cFiltro
						
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0006) //"Checklist APQP - A2 INFORMACAO DO PROJETO"

Private aRotina := MenuDef()

DbSelectArea("QKR")
DbSetOrder(1)

cFiltro := 'QKR_NPERG == "01"'

Set Filter To &cFiltro
mBrowse( 6, 1, 22, 75,"QKR",,,,,,)
Set Filter To


Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
?????????????????????????????????????????????????????????????????????????????
??ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ???
??ºPrograma  ?QPPA260CE   ºAutor  ?Klaus Daniel L.C   º Data ?  09/28/09   º??
??ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ???
??ºDesc.     ?Função que verifica com qual Edição foi feio a Lista de Veri-??
??º          ?ficacação                                                    º??
??ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ???
??ºUso       ? AP                                                        º??
??ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ???
?????????????????????????????????????????????????????????????????????????????
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
  
//Consistencia para verificar se na base de dados a Lista de verificacao  (A2) foi realizada
//na primeira ou na segunda edicao do APQP, se o retorno do nCont for 40, foi feita na primeira,
// se for 41 foi feito na segunda

Function QPPA260CE()

Local nCont      :=0
Local cPecaR     :=""
Local aArea		 := {}


cPecaR 	:= (QKR->QKR_FILIAL+QKR->QKR_PECA+QKR->QKR_REV)

aArea := GetArea()                                         

DbSelectArea("QKR")
Set Filter To
DbSetOrder(1)
DbGoTop()
DbSeek(cPecaR+"01")   


Do while !Eof().and. QKR->QKR_FILIAL+QKR->QKR_PECA+QKR->QKR_REV == cPecaR
	nCont++
	Dbskip()  
	
Enddo
RestArea(aArea)


Return nCont

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA260Roti  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³07.08.02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Manutencao dos Dados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA260Roti(ExpC1,ExpN1,ExpN2)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                     ³±±
±±³          ³ ExpN1 = Numero do registro                                   ³±±
±±³          ³ ExpN2 = Numero da opcao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA260Roti(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local lOk 			:= .F.
Local aCposVis		:= {}
Local aCposAlt		:= {}
Local aButtons		:= {}
Local nNresp        := 0 
Local lPriED260     := GetMV("MV_QAPQPED",.T.,"1") == '1' // Define se o APQP deve ser feito na primeira ou segunda edição 1 - Primeira Edição 2 - Segunda Edição
Local cTitulo       := ""
Private cChave		:= ""
Private aItems      := {}

nNresp := QPPA260CE()  //Verifica pelo numro de NResp em qual modelo foi feio o APQP

// Consistência Para Verificar se permite ou Não a Visualização, Exclusão e Alteração dos Dados.

If (nNresp == 41 .and. lPriED260)  .and. nOpc <> 3
Set filter to &cFiltro
	AVISO(STR0126,STR0127+STR0128+STR0129,{"Ok"},3,"MV_QAPQPED")	
	Return Nil

EndIf

If (nNresp == 40  .and. !lPriED260) .and. nOpc <> 3
Set filter to &cFiltro
	AVISO(STR0126,STR0127+STR0128+STR0129,{"Ok"},3,"MV_QAPQPED")	
	Return Nil

EndIF
 
If lPriED260  //Montagem do array do combobox  com as Respostas do Combobx de acordo com o Parametro MV_QAPQPED
	 aItems 		:= {STR0007,STR0008} //"Sim"###"Nao"
Else
	 aItems 		:= {STR0007,STR0008,STR0121} //"Sim"###"Nao"###"N/a"
EndIF

Private cComent01, cComent02, cComent03, cComent04
Private cComent05, cComent06, cComent07, cComent08
Private cComent09, cComent10, cComent11, cComent12
Private cComent13, cComent14, cComent15, cComent16
Private cComent17, cComent18, cComent19, cComent20
Private cComent21, cComent22, cComent23, cComent24
Private cComent25, cComent26, cComent27, cComent28
Private cComent29, cComent30, cComent31, cComent32
Private cComent33, cComent34, cComent35, cComent36
Private cComent37, cComent38, cComent39, cComent40
Private cComent41, cComent42, cComent43, cComent44
Private cComent45 


Private cChoice01 	:= cChoice02 := cChoice03 := cChoice04 	:= aItems[1]
Private cChoice05 	:= cChoice06 := cChoice07 := cChoice08 	:= aItems[1]
Private cChoice09 	:= cChoice10 := cChoice11 := cChoice12 	:= aItems[1]
Private cChoice13 	:= cChoice14 := cChoice15 := cChoice16 	:= aItems[1]
Private cChoice17 	:= cChoice18 := cChoice19 := cChoice20 	:= aItems[1]
Private cChoice21 	:= cChoice22 := cChoice23 := cChoice24 	:= aItems[1]
Private cChoice25 	:= cChoice26 := cChoice27 := cChoice28 	:= aItems[1]
Private cChoice29 	:= cChoice30 := cChoice31 := cChoice32 	:= aItems[1]
Private cChoice33 	:= cChoice34 := cChoice35 := cChoice36 	:= aItems[1]
Private cChoice37 	:= cChoice38 := cChoice39 := cChoice40 	:= aItems[1]
Private cChoice41 	:= cChoice42 := cChoice43 := cChoice44 	:= aItems[1]
Private cChoice45 	:= aItems[1]

Private cResp01 	:= cResp02 := cResp03 := cResp04 			:= Space(10)
Private cResp05 	:= cResp06 := cResp07 := cResp08 			:= Space(10)
Private cResp09 	:= cResp10 := cResp11 := cResp12 			:= Space(10)
Private cResp13 	:= cResp14 := cResp15 := cResp16 			:= Space(10)
Private cResp17 	:= cResp18 := cResp19 := cResp20 			:= Space(10)
Private cResp21 	:= cResp22 := cResp23 := cResp24 			:= Space(10)
Private cResp25 	:= cResp26 := cResp27 := cResp28			:= Space(10)
Private cResp29 	:= cResp30 := cResp31 := cResp32			:= Space(10)
Private cResp33 	:= cResp34 := cResp35 := cResp36			:= Space(10)
Private cResp37 	:= cResp38 := cResp39 := cResp40			:= Space(10)
Private cResp41 	:= cResp42 := cResp43 := cResp44			:= Space(10)
Private cResp45 	:= Space(10)

Private dData01 	:= dData02 := dData03 := dData04 			:= dDataBase
Private dData05 	:= dData06 := dData07 := dData08 			:= dDataBase
Private dData09 	:= dData10 := dData11 := dData12 			:= dDataBase
Private dData13 	:= dData14 := dData15 := dData16 			:= dDataBase
Private dData17 	:= dData18 := dData19 := dData20 			:= dDataBase
Private dData21 	:= dData22 := dData23 := dData24 			:= dDataBase
Private dData25 	:= dData26 := dData27 := dData28 			:= dDataBase
Private dData29 	:= dData30 := dData31 := dData32 			:= dDataBase
Private dData33 	:= dData34 := dData35 := dData36 			:= dDataBase
Private dData37 	:= dData38 := dData39 := dData40 			:= dDataBase
Private dData41 	:= dData42 := dData43 := dData44 			:= dDataBase
Private dData45     := dDataBase

aCposVis := { "QKR_PECA", "QKR_REV", "QKR_DTREVI",	"QKR_RESPOR", "QKR_PREPOR" }

aCposAlt := { "QKR_DTREVI", "QKR_RESPOR", "QKR_PREPOR" }
				
If nOpc == 2 
	aButtons := {{"BMPVISUAL",	{ || QPPR260() }, OemToAnsi(STR0009), OemToAnsi(STR0089) }} //"Visualizar/Imprimir"###"Vis/Prn"
Endif

If nOpc == 4
	If !QPPVldAlt(QKR->QKR_PECA,QKR->QKR_REV)
		Return
	Endif
Endif

DbSelectArea(cAlias)

Set Filter To

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lPriED260        //Verificando valor do parametro para Montar o Titulo da Janela
	cTitulo := STR0006
Else
	cTitulo := STR0006+STR0130
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitulo) ; //"Checklist APQP - A2 INFORMACAO DO PROJETO"
						FROM 120,000 TO 580,795 OF oMainWnd PIXEL
						
RegToMemory("QKR",(nOpc == 3))

Enchoice("QKR",nReg,nOpc, , , ,aCposVis ,{30,03,85,395}, , , , ,)

If GetMV("MV_QAPQPED",.F.,"1") == '1'
	QP260TEL(nOpc, oDlg)
Else
	QP260TED(nOpc, oDlg)
Endif

                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP260TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, ,aButtons ) CENTERED

If lOk .and. (nOpc == 3 .or. nOpc == 4)
	PPA260Grav(nOpc)
Endif

If nOpc == 5 .and. lOk
	A260Dele()
Endif

Set Filter To &cFiltro

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QP260TEL³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 07.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para informacoes do ScrollBox                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QP260TEL(ExpN1, ExpO1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±³          ³ ExpO1 = Dialog       									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA260                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QP260TEL(nOpc, oDlg)

Local oScrollBox := Nil
Local oCombo
Local oComent
Local oData
Local oResp

Local nCont

Private aObj := {}

DEFINE FONT oFont 	 NAME "Arial" SIZE 5.5,12.5
DEFINE FONT oFontTxt NAME "Courier New" SIZE 6,0
DEFINE FONT oFontCou NAME "Courier New" SIZE 5,15

If nOpc <> 3
	QPP260CHEC()
Endif

@ 088,003 MSPANEL oPanel1 PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE 395,012 OF oDlg
@ 004,004 SAY OemToAnsi(STR0010)	COLOR CLR_WHITE SIZE 065,010 OF oPanel1 PIXEL  //"Item - Pergunta"
@ 004,142 SAY OemToAnsi(STR0011) 	COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL  //"Sim/Nao"
@ 004,190 SAY OemToAnsi(STR0012)	COLOR CLR_WHITE SIZE 090,010 OF oPanel1 PIXEL  //"Comentarios/Acao Requerida"
@ 004,300 SAY OemToAnsi(STR0013)	COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL  //"Responsavel"
@ 004,347 SAY OemToAnsi(STR0014)	COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL  //"Dt. Prevista"

oScrollBox := TScrollBox():New(oDlg,103,03,125,395,.T.,.F.,.T.)

@ 001,002 TO 1625,142 		OF oScrollBox PIXEL
@ 001,002 TO 1625,167 		OF oScrollBox PIXEL
@ 001,002 TO 1625,298 		OF oScrollBox PIXEL
@ 001,002 TO 1625,345.5	OF oScrollBox PIXEL
@ 001,002 TO 1625,385		OF oScrollBox PIXEL

// 1a pergunta
@ 015,144 COMBOBOX oCombo VAR cChoice01 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 015,168 GET oComent VAR cComent01 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 015,298 MSGET oResp VAR cResp01 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 015,346 MSGET oData VAR dData01 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 2a pergunta
@ 055,144 COMBOBOX oCombo VAR cChoice02 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 055,168 GET oComent VAR cComent02 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 055,298 MSGET oResp VAR cResp02 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 055,346 MSGET oData VAR dData02 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 3a pergunta
@ 095,144 COMBOBOX oCombo VAR cChoice03 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 095,168 GET oComent VAR cComent03 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 095,298 MSGET oResp VAR cResp03 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 095,346 MSGET oData VAR dData03 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 4a pergunta
@ 145,144 COMBOBOX oCombo VAR cChoice04 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 145,168 GET oComent VAR cComent04 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 145,298 MSGET oResp VAR cResp04 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 145,346 MSGET oData VAR dData04 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 5a pergunta
@ 185,144 COMBOBOX oCombo VAR cChoice05 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 185,168 GET oComent VAR cComent05 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 185,298 MSGET oResp VAR cResp05 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 185,346 MSGET oData VAR dData05 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 6a pergunta
@ 225,144 COMBOBOX oCombo VAR cChoice06 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 225,168 GET oComent VAR cComent06 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 225,298 MSGET oResp VAR cResp06 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 225,346 MSGET oData VAR dData06 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 7a pergunta
@ 265,144 COMBOBOX oCombo VAR cChoice07 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 265,168 GET oComent VAR cComent07 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 265,298 MSGET oResp VAR cResp07 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 265,346 MSGET oData VAR dData07 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 8a pergunta
@ 305,144 COMBOBOX oCombo VAR cChoice08 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 305,168 GET oComent VAR cComent08 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 305,298 MSGET oResp VAR cResp08 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 305,346 MSGET oData VAR dData08 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 9a pergunta
@ 345,144 COMBOBOX oCombo VAR cChoice09 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 345,168 GET oComent VAR cComent09 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 345,298 MSGET oResp VAR cResp09 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 345,346 MSGET oData VAR dData09 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 10a pergunta
@ 385,144 COMBOBOX oCombo VAR cChoice10 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 385,168 GET oComent VAR cComent10 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 385,298 MSGET oResp VAR cResp10 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 385,346 MSGET oData VAR dData10 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 11a pergunta
@ 425,144 COMBOBOX oCombo VAR cChoice11 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 425,168 GET oComent VAR cComent11 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 425,298 MSGET oResp VAR cResp11 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 425,346 MSGET oData VAR dData11 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 12a pergunta
@ 465,144 COMBOBOX oCombo VAR cChoice12 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 465,168 GET oComent VAR cComent12 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 465,298 MSGET oResp VAR cResp12 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 465,346 MSGET oData VAR dData12 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 13a pergunta
@ 505,144 COMBOBOX oCombo VAR cChoice13 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 505,168 GET oComent VAR cComent13 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 505,298 MSGET oResp VAR cResp13 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 505,346 MSGET oData VAR dData13 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 14a pergunta
@ 545,144 COMBOBOX oCombo VAR cChoice14 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 545,168 GET oComent VAR cComent14 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 545,298 MSGET oResp VAR cResp14 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 545,346 MSGET oData VAR dData14 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 15a pergunta
@ 585,144 COMBOBOX oCombo VAR cChoice15 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 585,168 GET oComent VAR cComent15 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 585,298 MSGET oResp VAR cResp15 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 585,346 MSGET oData VAR dData15 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 16a pergunta
@ 625,144 COMBOBOX oCombo VAR cChoice16 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 625,168 GET oComent VAR cComent16 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 625,298 MSGET oResp VAR cResp16 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 625,346 MSGET oData VAR dData16 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 17a pergunta
@ 665,144 COMBOBOX oCombo VAR cChoice17 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 665,168 GET oComent VAR cComent17 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 665,298 MSGET oResp VAR cResp17 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 665,346 MSGET oData VAR dData17 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 18a pergunta
@ 705,144 COMBOBOX oCombo VAR cChoice18 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 705,168 GET oComent VAR cComent18 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 705,298 MSGET oResp VAR cResp18 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 705,346 MSGET oData VAR dData18 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 19a pergunta
@ 745,144 COMBOBOX oCombo VAR cChoice19 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 745,168 GET oComent VAR cComent19 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 745,298 MSGET oResp VAR cResp19 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 745,346 MSGET oData VAR dData19 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 20a pergunta
@ 785,144 COMBOBOX oCombo VAR cChoice20 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 785,168 GET oComent VAR cComent20 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 785,298 MSGET oResp VAR cResp20 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 785,346 MSGET oData VAR dData20 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 21a pergunta
@ 825,144 COMBOBOX oCombo VAR cChoice21 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 825,168 GET oComent VAR cComent21 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 825,298 MSGET oResp VAR cResp21 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 825,346 MSGET oData VAR dData21 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 22a pergunta
@ 865,144 COMBOBOX oCombo VAR cChoice22 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 865,168 GET oComent VAR cComent22 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 865,298 MSGET oResp VAR cResp22 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 865,346 MSGET oData VAR dData22 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 23a pergunta
@ 905,144 COMBOBOX oCombo VAR cChoice23 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 905,168 GET oComent VAR cComent23 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 905,298 MSGET oResp VAR cResp23 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 905,346 MSGET oData VAR dData23 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 24a pergunta
@ 945,144 COMBOBOX oCombo VAR cChoice24 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 945,168 GET oComent VAR cComent24 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 945,298 MSGET oResp VAR cResp24 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 945,346 MSGET oData VAR dData24 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 25a pergunta
@ 985,144 COMBOBOX oCombo VAR cChoice25 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 985,168 GET oComent VAR cComent25 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 985,298 MSGET oResp VAR cResp25 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 985,346 MSGET oData VAR dData25 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 26a pergunta
@ 1025,144 COMBOBOX oCombo VAR cChoice26 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1025,168 GET oComent VAR cComent26 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1025,298 MSGET oResp VAR cResp26 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1025,346 MSGET oData VAR dData26 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 27a pergunta
@ 1065,144 COMBOBOX oCombo VAR cChoice27 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1065,168 GET oComent VAR cComent27 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1065,298 MSGET oResp VAR cResp27 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1065,346 MSGET oData VAR dData27 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 28a pergunta
@ 1105,144 COMBOBOX oCombo VAR cChoice28 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1105,168 GET oComent VAR cComent28 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1105,298 MSGET oResp VAR cResp28 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1105,346 MSGET oData VAR dData28 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 29a pergunta
@ 1145,144 COMBOBOX oCombo VAR cChoice29 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1145,168 GET oComent VAR cComent29 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1145,298 MSGET oResp VAR cResp29 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1145,346 MSGET oData VAR dData29 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 30a pergunta
@ 1185,144 COMBOBOX oCombo VAR cChoice30 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1185,168 GET oComent VAR cComent30 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1185,298 MSGET oResp VAR cResp30 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1185,346 MSGET oData VAR dData30 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 31a pergunta
@ 1225,144 COMBOBOX oCombo VAR cChoice31 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1225,168 GET oComent VAR cComent31 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1225,298 MSGET oResp VAR cResp31 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1225,346 MSGET oData VAR dData31 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 32a pergunta
@ 1265,144 COMBOBOX oCombo VAR cChoice32 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1265,168 GET oComent VAR cComent32 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1265,298 MSGET oResp VAR cResp32 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1265,346 MSGET oData VAR dData32 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 33a pergunta
@ 1305,144 COMBOBOX oCombo VAR cChoice33 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1305,168 GET oComent VAR cComent33 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1305,298 MSGET oResp VAR cResp33 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1305,346 MSGET oData VAR dData33 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 34a pergunta
@ 1345,144 COMBOBOX oCombo VAR cChoice34 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1345,168 GET oComent VAR cComent34 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1345,298 MSGET oResp VAR cResp34 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1345,346 MSGET oData VAR dData34 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 35a pergunta
@ 1385,144 COMBOBOX oCombo VAR cChoice35 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1385,168 GET oComent VAR cComent35 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1385,298 MSGET oResp VAR cResp35 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1385,346 MSGET oData VAR dData35 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})
                                             

// 36a pergunta
@ 1425,144 COMBOBOX oCombo VAR cChoice36 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1425,168 GET oComent VAR cComent36 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1425,298 MSGET oResp VAR cResp36 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1425,346 MSGET oData VAR dData36 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 37a pergunta
@ 1465,144 COMBOBOX oCombo VAR cChoice37 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1465,168 GET oComent VAR cComent37 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1465,298 MSGET oResp VAR cResp37 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1465,346 MSGET oData VAR dData37 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 38a pergunta
@ 1505,144 COMBOBOX oCombo VAR cChoice38 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1505,168 GET oComent VAR cComent38 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1505,298 MSGET oResp VAR cResp38 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1505,346 MSGET oData VAR dData38 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 39a pergunta
@ 1545,144 COMBOBOX oCombo VAR cChoice39 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1545,168 GET oComent VAR cComent39 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1545,298 MSGET oResp VAR cResp39 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1545,346 MSGET oData VAR dData39 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 40a pergunta
@ 1585,144 COMBOBOX oCombo VAR cChoice40 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1585,168 GET oComent VAR cComent40 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1585,298 MSGET oResp VAR cResp40 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1585,346 MSGET oData VAR dData40 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

QP260ST(oScrollBox, oFont)  // Monta as Strings da Primeira Edição

If !Empty(M->QKR_CHAVE)
	cChave := M->QKR_CHAVE
Endif

If nOpc <> 3 .and. nOpc <> 4
	For nCont := 1 To Len(aObj)
		aObj[nCont,1]:lReadOnly := .T.
		aObj[nCont,2]:lReadOnly := .T.
		aObj[nCont,3]:lReadOnly := .T.
		aObj[nCont,4]:lReadOnly := .T.
	Next nCont
Else
	For nCont := 1 To Len(aObj)
		aObj[nCont,4]:lReadOnly := .F.
	Next nCont
Endif

Return .T.                                  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QP260ST ³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 13.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra os SAYS da funcao QP260Tel                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QP260ST(ExpO1, ExpO2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do Scrool                                   ³±±
±±³          ³ ExpO2 = Objeto da font                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA260                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Obs      ³ Funcao criada devido a erro de Memory Overbooked           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function QP260ST(oScrollBox, oFont)

// 1a pergunta

@ 015,003 SAY OemToAnsi(STR0015) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"  A. GERAL"
@ 025,003 SAY OemToAnsi(STR0016) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"  O Projeto exige :"
@ 035,003 SAY OemToAnsi("1 - "+STR0017)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Novos Materiais ?"

@ 045,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 2a pergunta
@ 055,003 SAY OemToAnsi("2 - "+STR0018) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Ferramentas especiais ?"

@ 085,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 3a pergunta
@ 095,003 SAY OemToAnsi("3 - "+STR0019) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foi Considerada a analise de variacao de montagem ?"

@ 135,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 4a pergunta
@ 145,003 SAY OemToAnsi("4 - "+STR0020) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foi considerado Delineamento de Experimentos ?"

@ 175,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 5a pergunta
@ 185,003 SAY OemToAnsi("5 - "+STR0021) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Existe algum plano para prototipos em andamento ?"

@ 215,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 6a pergunta
@ 225,003 SAY OemToAnsi("6 - "+STR0022) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"O FMEA foi completado ?"

@ 255,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 7a pergunta
@ 265,003 SAY OemToAnsi("7 - "+STR0023) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"O DFMA foi completado ?"

@ 295,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 8a pergunta
@ 305,003 SAY OemToAnsi("8 - "+STR0024) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram consideradas questoes relativas a assistencia"
@ 315,003 SAY OemToAnsi(STR0025) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"    tecnica e manutencao ?"

@ 335,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 9a pergunta
@ 345,003 SAY OemToAnsi("9 - "+STR0026) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"O Plano de Verificacao de Projeto foi completado ?"

@ 375,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 10a pergunta
@ 385,003 SAY OemToAnsi("10 - "+STR0027) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Em caso positivo, foi completado por uma equipe "
@ 395,003 SAY OemToAnsi(STR0125) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Multifuncional ? "

@ 415,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 11a pergunta
@ 425,003 SAY OemToAnsi("11 - "+STR0028)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram claramente definidos e comprometidos todos os"
@ 435,003 SAY OemToAnsi(STR0029) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     testes, metodos, equipamentos e criterios de aceitacao ?"

@ 455,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 12a pergunta
@ 465,003 SAY OemToAnsi("12 - "+STR0030) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram Selecionadas as Caracteristicas Especiais ?"

@ 495,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 13a pergunta
@ 505,003 SAY OemToAnsi("13 - "+STR0031) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"A lista de materiais/pecas esta completa ?"

@ 535,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 14a pergunta
@ 545,003 SAY OemToAnsi("14 - "+STR0032)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As Caracteristicas Especiais estao apropriadamente"
@ 555,003 SAY OemToAnsi(STR0033)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     documentadas ?"

@ 575,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 15a pergunta
@ 585,003 SAY OemToAnsi(STR0034) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"   B. DESENHOS DE ENGENHARIA"
@ 595,003 SAY OemToAnsi("15 - "+STR0035) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram identificadas as dimensoes que afetam ajuste,"
@ 605,003 SAY OemToAnsi(STR0036) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     funcoes e durabilidade ?"

@ 615,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 16a pergunta
@ 625,003 SAY OemToAnsi("16 - "+STR0037) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram identificadas as dimensoes de referencia para"
@ 635,003 SAY OemToAnsi(STR0038) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     minimizar o tempo de layout de inspecao ?"

@ 655,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 17a pergunta
@ 665,003 SAY OemToAnsi("17 - "+STR0039) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Existem pontos de controle e superficies de referencia"
@ 675,003 SAY OemToAnsi(STR0040) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     suficientemente indentificados para projetar dispositivos"
@ 685,003 SAY OemToAnsi(STR0041) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     funcionais ?"

@ 695,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 18a pergunta
@ 705,003 SAY OemToAnsi("18 - "+STR0042) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As Tolerancias sao compativeis com normas de"
@ 715,003 SAY OemToAnsi(STR0043) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     manufatura aceitaveis ?"

@ 735,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 19a pergunta
@ 745,003 SAY OemToAnsi("19 - "+STR0044) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Existem quaisquer requisitos especificados que nao"
@ 755,003 SAY OemToAnsi(STR0045) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     possam ser avaliados atraves de tecnicas de inspecao"
@ 765,003 SAY OemToAnsi(STR0046) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     conhecidas ?"

@ 775,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 20a pergunta
@ 785,003 SAY OemToAnsi(STR0047)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"   C. ESPECIFICACOES DE DESEMPENHO DE ENGENHARIA"
@ 795,003 SAY OemToAnsi("20 - "+STR0048)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Todas as Caracteristicas especiais foram"
@ 805,003 SAY OemToAnsi(STR0049)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     identificadas ?"

@ 815,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 21a pergunta
@ 825,003 SAY OemToAnsi("21 - "+STR0050) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"A Quantidade de Ensaios e suficiente para oferecer"
@ 835,003 SAY OemToAnsi(STR0051) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     todas as condicoes, ou seja, validacao de producao"
@ 845,003 SAY OemToAnsi(STR0052)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     e uso final ?"

@ 855,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 22a pergunta
@ 865,003 SAY OemToAnsi("22 - "+STR0053) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Pecas fabricadas nas especificacoes minimas e"
@ 875,003 SAY OemToAnsi(STR0054) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     maximas foram testadas ?"

@ 895,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 23a pergunta
@ 905,003 SAY OemToAnsi("23 - "+STR0055)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Amostras adicionais podem ser testadas quando algum"
@ 915,003 SAY OemToAnsi(STR0056) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     plano de reacao assim exigir e ainda conduzir os"
@ 925,003 SAY OemToAnsi(STR0057) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     testes regulares em processo ?"

@ 935,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 24a pergunta
@ 945,003 SAY OemToAnsi("24 - "+STR0058) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Todos os Ensaios de produto serao feitos internamente ?"

@ 975,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 25a pergunta
@ 985,003 SAY OemToAnsi("25 - "+STR0059) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Em caso contrario, eles serao o efetuados por um "
@ 995,003 SAY OemToAnsi(STR0060) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     subfornecedor aprovado ?"

@ 1015,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 26a pergunta
@ 1025,003 SAY OemToAnsi("26 - "+STR0061) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"E viavel a frequencia e tamanho de amostragem para"
@ 1035,003 SAY OemToAnsi(STR0062) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     ensaios ?"

@ 1055,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 27a pergunta
@ 1065,003 SAY OemToAnsi("27 - "+STR0063) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Se necessario, foi obtido aprovacao do cliente para"
@ 1075,003 SAY OemToAnsi(STR0064) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     o equipamento de ensaio ?"

@ 1095,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 28a pergunta
@ 1105,003 SAY OemToAnsi(STR0065) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"   D. ESPECIFICACAO DE MATERIAIS"
@ 1115,003 SAY OemToAnsi("28 - "+STR0066) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As caracteristicas especiais de material estao"
@ 1125,003 SAY OemToAnsi(STR0049) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     identificadas ?"

@ 1135,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 29a pergunta
@ 1145,003 SAY OemToAnsi("29 - "+STR0067) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Os materiais, tratamento termico e tratamento de"
@ 1155,003 SAY OemToAnsi(STR0068)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     superficie especificados sao compativeis com a"
@ 1165,003 SAY OemToAnsi(STR0069)  SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     durabilidade no ambiente identificado ?"

@ 1175,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 30a pergunta
@ 1185,003 SAY OemToAnsi("30 - "+STR0070) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //" Os fornecedores do material previsto estao na lista"
@ 1195,003 SAY OemToAnsi(STR0071) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     de clientes aprovados ?"

@ 1215,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 31a pergunta
@ 1225,003 SAY OemToAnsi("31 - "+STR0072) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Sera solicitado aos fornecedores de material"
@ 1235,003 SAY OemToAnsi(STR0073) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     certificado a cada lote de entrega ?"

@ 1255,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 32a pergunta
@ 1265,003 SAY OemToAnsi("32 - "+STR0074) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram identificadas caracteristicas de material"
@ 1275,003 SAY OemToAnsi(STR0075) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     que necessitam de inspecao ?"
@ 1285,003 SAY OemToAnsi(STR0076) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     Em caso positivo, "

@ 1295,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 33a pergunta
@ 1305,003 SAY OemToAnsi("33 * "+STR0077) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As caracteristicas serao verificadas internamente ?"

@ 1335,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 34a pergunta
@ 1345,003 SAY OemToAnsi("34 * "+STR0078) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"O equipamento de teste esta disponivel ?"

@ 1375,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 35a pergunta
@ 1385,003 SAY OemToAnsi("35 * "+STR0079) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Havera a necessidade de treinamento para assegurar"
@ 1395,003 SAY OemToAnsi(STR0080) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     resultados precisos ?"

@ 1415,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL
                                            

// 36a pergunta
@ 1425,003 SAY OemToAnsi("36 - "+STR0081) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Serao utilizados laboratorios externos ?"

@ 1455,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 37a pergunta
@ 1465,003 SAY OemToAnsi("37 - "+STR0082)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Todos os laboratorios utilizados sao credenciados"
@ 1475,003 SAY OemToAnsi(STR0083) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     (se necessario) ?"

@ 1495,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 38a pergunta
@ 1505,003 SAY OemToAnsi(STR0084) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"    Foram considerados os seguintes requisitos materiais ?"
@ 1515,003 SAY OemToAnsi("38 * "+STR0085) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Manuseio ?"

@ 1535,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 39a pergunta
@ 1545,003 SAY OemToAnsi("39 * "+STR0086) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Estocagem ?"

@ 1575,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 40a pergunta
@ 1585,003 SAY OemToAnsi("40 * "+STR0087) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Ambiental ?"

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QP260TED³ Autor ³ KLAUS DANIEL          ³ Data ³ 07.08.02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para informacoes do ScrollBox da 2 EDICAO APQP         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QP260TED(ExpN1, ExpO1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±³          ³ ExpO1 = Dialog       									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA260                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QP260TED(nOpc, oDlg)  //--> Segunda Edição do APQP

Local oScrollBox := Nil
Local oCombo
Local oComent
Local oData
Local oResp  


Local nCont

Private aObj := {}

DEFINE FONT oFont 	  NAME "Arial" SIZE 5.5,12.5
DEFINE FONT oFontNegi NAME "Arial"  SIZE 7,12.5 BOLD
DEFINE FONT oFontTxt  NAME "Courier New" SIZE 6,0
DEFINE FONT oFontCou  NAME "Courier New" SIZE 5,15

If nOpc <> 3
	QPP260CHEC()
Endif

// MSPANEL cabecalho//
@ 088,003 MSPANEL oPanel1 PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE 395,012 OF oDlg
@ 004,004 SAY OemToAnsi(STR0010)	COLOR CLR_WHITE SIZE 065,010 OF oPanel1 PIXEL  //"Item - Pergunta"
@ 004,135 SAY OemToAnsi(STR0011) 	COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL  //"Sim/Nao"
@ 004,155 SAY OemToAnsi("/"+STR0121) 	COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL  //"N/a"
@ 004,190 SAY OemToAnsi(STR0012)	COLOR CLR_WHITE SIZE 090,010 OF oPanel1 PIXEL  //"Comentarios/Acao Requerida"
@ 004,300 SAY OemToAnsi(STR0013)	COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL  //"Responsavel"
@ 004,347 SAY OemToAnsi(STR0014)	COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL  //"Dt. Prevista"

oScrollBox := TScrollBox():New(oDlg,103,03,125,395,.T.,.F.,.T.)

// Quadrados maiores //
@ 001,002 TO 1685,142 		OF oScrollBox PIXEL
@ 001,002 TO 1685,167 		OF oScrollBox PIXEL
@ 001,002 TO 1685,298 		OF oScrollBox PIXEL
@ 001,002 TO 1685,345.5	    OF oScrollBox PIXEL
@ 001,002 TO 1685,385		OF oScrollBox PIXEL

// 1a pergunta
@ 015,144 COMBOBOX oCombo VAR cChoice01 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 015,168 GET oComent VAR cComent01 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 015,298 MSGET oResp VAR cResp01 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 015,346 MSGET oData VAR dData01 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 1a pergunta  (B)
@ 055,144 COMBOBOX oCombo VAR cChoice02 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 055,168 GET oComent VAR cComent02 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 055,298 MSGET oResp VAR cResp02 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 055,346 MSGET oData VAR dData02 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 1a pergunta  (C)
@ 095,144 COMBOBOX oCombo VAR cChoice03 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 095,168 GET oComent VAR cComent03 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 095,298 MSGET oResp VAR cResp03 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 095,346 MSGET oData VAR dData03 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 2a pergunta 
@ 145,144 COMBOBOX oCombo VAR cChoice04 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 145,168 GET oComent VAR cComent04 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 145,298 MSGET oResp VAR cResp04 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 145,346 MSGET oData VAR dData04 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 3a pergunta
@ 185,144 COMBOBOX oCombo VAR cChoice05 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 185,168 GET oComent VAR cComent05 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 185,298 MSGET oResp VAR cResp05 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 185,346 MSGET oData VAR dData05 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 4a pergunta
@ 225,144 COMBOBOX oCombo VAR cChoice06 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 225,168 GET oComent VAR cComent06 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 225,298 MSGET oResp VAR cResp06 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 225,346 MSGET oData VAR dData06 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 5a pergunta
@ 265,144 COMBOBOX oCombo VAR cChoice07 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 265,168 GET oComent VAR cComent07 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 265,298 MSGET oResp VAR cResp07 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 265,346 MSGET oData VAR dData07 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 6a pergunta
@ 305,144 COMBOBOX oCombo VAR cChoice08 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 305,168 GET oComent VAR cComent08 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 305,298 MSGET oResp VAR cResp08 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 305,346 MSGET oData VAR dData08 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 7a pergunta
@ 345,144 COMBOBOX oCombo VAR cChoice09 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 345,168 GET oComent VAR cComent09 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 345,298 MSGET oResp VAR cResp09 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 345,346 MSGET oData VAR dData09 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 8a pergunta
@ 385,144 COMBOBOX oCombo VAR cChoice10 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 385,168 GET oComent VAR cComent10 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 385,298 MSGET oResp VAR cResp10 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 385,346 MSGET oData VAR dData10 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 9a pergunta
@ 425,144 COMBOBOX oCombo VAR cChoice11 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 425,168 GET oComent VAR cComent11 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 425,298 MSGET oResp VAR cResp11 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 425,346 MSGET oData VAR dData11 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 10a pergunta
@ 465,144 COMBOBOX oCombo VAR cChoice12 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 465,168 GET oComent VAR cComent12 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 465,298 MSGET oResp VAR cResp12 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 465,346 MSGET oData VAR dData12 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 11a pergunta
@ 510,144 COMBOBOX oCombo VAR cChoice13 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 510,168 GET oComent VAR cComent13 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 510,298 MSGET oResp VAR cResp13 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 510,346 MSGET oData VAR dData13 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 12a pergunta
@ 555,144 COMBOBOX oCombo VAR cChoice14 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 555,168 GET oComent VAR cComent14 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 555,298 MSGET oResp VAR cResp14 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 555,346 MSGET oData VAR dData14 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 13a pergunta
@ 595,144 COMBOBOX oCombo VAR cChoice15 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 595,168 GET oComent VAR cComent15 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 595,298 MSGET oResp VAR cResp15 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 595,346 MSGET oData VAR dData15 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 14a pergunta
@ 640,144 COMBOBOX oCombo VAR cChoice16 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 640,168 GET oComent VAR cComent16 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 640,298 MSGET oResp VAR cResp16 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 640,346 MSGET oData VAR dData16 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 15a pergunta
@ 680,144 COMBOBOX oCombo VAR cChoice17 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 680,168 GET oComent VAR cComent17 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 680,298 MSGET oResp VAR cResp17 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 680,346 MSGET oData VAR dData17 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 16a pergunta
@ 720,144 COMBOBOX oCombo VAR cChoice18 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 720,168 GET oComent VAR cComent18 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 720,298 MSGET oResp VAR cResp18 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 720,346 MSGET oData VAR dData18 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 17a pergunta
@ 760,144 COMBOBOX oCombo VAR cChoice19 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 760,168 GET oComent VAR cComent19 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 760,298 MSGET oResp VAR cResp19 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 760,346 MSGET oData VAR dData19 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 18a pergunta
@ 800,144 COMBOBOX oCombo VAR cChoice20 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 800,168 GET oComent VAR cComent20 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 800,298 MSGET oResp VAR cResp20 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 800,346 MSGET oData VAR dData20 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 19a pergunta
@ 845,144 COMBOBOX oCombo VAR cChoice21 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 845,168 GET oComent VAR cComent21 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 845,298 MSGET oResp VAR cResp21 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 845,346 MSGET oData VAR dData21 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 20a pergunta
@ 885,144 COMBOBOX oCombo VAR cChoice22 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 885,168 GET oComent VAR cComent22 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 885,298 MSGET oResp VAR cResp22 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 885,346 MSGET oData VAR dData22 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 21a pergunta
@ 925,144 COMBOBOX oCombo VAR cChoice23 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 925,168 GET oComent VAR cComent23 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 925,298 MSGET oResp VAR cResp23 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 925,346 MSGET oData VAR dData23 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 22a pergunta
@ 965,144 COMBOBOX oCombo VAR cChoice24 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 965,168 GET oComent VAR cComent24 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 965,298 MSGET oResp VAR cResp24 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 965,346 MSGET oData VAR dData24 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 23a pergunta
@ 1005,144 COMBOBOX oCombo VAR cChoice25 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1005,168 GET oComent VAR cComent25 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1005,298 MSGET oResp VAR cResp25 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1005,346 MSGET oData VAR dData25 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 24a pergunta
@ 1045,144 COMBOBOX oCombo VAR cChoice26 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1045,168 GET oComent VAR cComent26 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1045,298 MSGET oResp VAR cResp26 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1045,346 MSGET oData VAR dData26 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 25a pergunta
@ 1085,144 COMBOBOX oCombo VAR cChoice27 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1085,168 GET oComent VAR cComent27 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1085,298 MSGET oResp VAR cResp27 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1085,346 MSGET oData VAR dData27 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 26a pergunta
@ 1130,144 COMBOBOX oCombo VAR cChoice28 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1130,168 GET oComent VAR cComent28 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1130,298 MSGET oResp VAR cResp28 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1130,346 MSGET oData VAR dData28 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 27a pergunta
@ 1170,144 COMBOBOX oCombo VAR cChoice29 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1170,168 GET oComent VAR cComent29 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1170,298 MSGET oResp VAR cResp29 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1170,346 MSGET oData VAR dData29 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 28a pergunta
@ 1210,144 COMBOBOX oCombo VAR cChoice30 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1210,168 GET oComent VAR cComent30 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1210,298 MSGET oResp VAR cResp30 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1210,346 MSGET oData VAR dData30 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 29a pergunta
@ 1250,144 COMBOBOX oCombo VAR cChoice31 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1250,168 GET oComent VAR cComent31 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1250,298 MSGET oResp VAR cResp31 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1250,346 MSGET oData VAR dData31 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 30a pergunta
@ 1290,144 COMBOBOX oCombo VAR cChoice32 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1290,168 GET oComent VAR cComent32 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1290,298 MSGET oResp VAR cResp32 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1290,346 MSGET oData VAR dData32 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 30a pergunta    (A)
@ 1330,144 COMBOBOX oCombo VAR cChoice33 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1330,168 GET oComent VAR cComent33 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1330,298 MSGET oResp VAR cResp33 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1330,346 MSGET oData VAR dData33 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 30a pergunta  (B)
@ 1370,144 COMBOBOX oCombo VAR cChoice34 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1370,168 GET oComent VAR cComent34 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1370,298 MSGET oResp VAR cResp34 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1370,346 MSGET oData VAR dData34 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 30a pergunta  (C)
@ 1410,144 COMBOBOX oCombo VAR cChoice35 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1410,168 GET oComent VAR cComent35 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1410,298 MSGET oResp VAR cResp35 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1410,346 MSGET oData VAR dData35 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})
                                             

// 31a pergunta  
@ 1450,144 COMBOBOX oCombo VAR cChoice36 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1450,168 GET oComent VAR cComent36 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1450,298 MSGET oResp VAR cResp36 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1450,346 MSGET oData VAR dData36 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 31a pergunta  (A)
@ 1490,144 COMBOBOX oCombo VAR cChoice37 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1490,168 GET oComent VAR cComent37 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1490,298 MSGET oResp VAR cResp37 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1490,346 MSGET oData VAR dData37 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 32a pergunta    (A)
@ 1535,144 COMBOBOX oCombo VAR cChoice38 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1535,168 GET oComent VAR cComent38 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1535,298 MSGET oResp VAR cResp38 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1535,346 MSGET oData VAR dData38 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 32a pergunta  (B)
@ 1575,144 COMBOBOX oCombo VAR cChoice39 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1575,168 GET oComent VAR cComent39 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1575,298 MSGET oResp VAR cResp39 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1575,346 MSGET oData VAR dData39 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 32a pergunta (C)
@ 1615,144 COMBOBOX oCombo VAR cChoice40 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1615,168 GET oComent VAR cComent40 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1615,298 MSGET oResp VAR cResp40 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1615,346 MSGET oData VAR dData40 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 32a pergunta (D)
@ 1655,144 COMBOBOX oCombo VAR cChoice41 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1655,168 GET oComent VAR cComent41 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1655,298 MSGET oResp VAR cResp41 PICTURE PesqPict("QKR","QKR_RESP") ;
						ReadOnly F3 ConSX3("QKR_RESP") VALID CheckSx3("QKR_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1655,346 MSGET oData VAR dData41 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})



QP260SED(oScrollBox, oFont)   // Função que monta as String da 2Edição APQP

If !Empty(M->QKR_CHAVE)
	cChave := M->QKR_CHAVE
Endif §

If nOpc <> 3 .and. nOpc <> 4
	For nCont := 1 To Len(aObj)
		aObj[nCont,1]:lReadOnly := .T.
		aObj[nCont,2]:lReadOnly := .T.
	  §	aObj[nCont,3]:lReadOnly := .T.
		aObj[nCont,4]:lReadOnly := .T.
	Next nCont
Else
	For nCont := 1 To Len(aObj)
		aObj[nCont,4]:lReadOnly := .F.
	Next nCont
Endif

Return .T.                                  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QP260SED ³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 13.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra os SAYS da funcao QPP260Tela                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QP260SED(ExpO1, ExpO2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do Scrool                                   ³±±
±±³          ³ ExpO2 = Objeto da font                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA260                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Obs      ³ Funcao criada devido a erro de Memory Overbooked           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function QP260SED(oScrollBox, oFont) //--> Segunda Edição APQP

Local oDlg := nil 

// 1a pergunta (A)

@ 001,003 MSPANEL oPanel1 PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE 395,012 OF oScrollBox
@ 004,004 SAY OemToAnsi(STR0015)	COLOR CLR_WHITE SIZE 065,010 OF oPanel1 PIXEL  //"  A. GERAL"
@ 025,003 SAY OemToAnsi(STR0016) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"  O Projeto exige :"
@ 035,003 SAY OemToAnsi("A - "+STR0119)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Novos Materiais?"

@ 045,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 1a pergunta  (B)
@ 055,003 SAY OemToAnsi("B - "+STR0120) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Ferramenta Especial?"

@ 085,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 3a pergunta  (C)
@ 095,003 SAY OemToAnsi("C -"+STR0090) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Novas Tecnologias ou Processos ? "

@ 135,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 2a pergunta
@ 145,003 SAY OemToAnsi("2 - "+STR0019) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //Foi Considerada a analise de variacao de montagem ?"

@ 175,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 3a pergunta
@ 185,003 SAY OemToAnsi("3 - "+STR0020) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foi considerado Delineamento de Experimentos ?"

@ 215,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 4a pergunta
@ 225,003 SAY OemToAnsi("4 - "+STR0021) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Existe algum plano para prototipos em andamento ?"

@ 255,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 5a pergunta
@ 265,003 SAY OemToAnsi("5 - "+STR0131) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"O DFMEA foi concluido?"

@ 295,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 6a pergunta
@ 305,003 SAY OemToAnsi("6 - "+STR0132) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //""A DFMA (Projeto para Manufaturabilidade e montagem)"
@ 315,003 SAY OemToAnsi(STR0133) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"foi concluída ? "


@ 335,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 7a pergunta
@ 345,003 SAY OemToAnsi("7 - "+STR0024) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram consideradas questoes relativas a assistencia"
@ 355,003 SAY OemToAnsi(STR0025) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"    tecnica e manutencao ?"

@ 375,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 8a pergunta
@ 385,003 SAY OemToAnsi("8 - "+STR0026) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"O Plano de Verificacao de Projeto foi completado ?"

@ 415,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 9a pergunta
@ 425,003 SAY OemToAnsi("9 - "+STR0027) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Em caso positivo, foi completado por uma equipe "
@ 435,003 SAY OemToAnsi(STR0125) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"multifuncional ?"

@ 455,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 10a pergunta
@ 465,003 SAY OemToAnsi("10 - "+STR0028)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram claramente definidos e comprometidos todos os"
@ 475,003 SAY OemToAnsi(STR0029) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     testes, metodos, equipamentos e criterios de aceitacao ?"

@ 495,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 11a pergunta
@ 505,003 SAY OemToAnsi("11 - "+STR0030) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram Selecionadas as Caracteristicas Especiais ?"

@ 545,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 12a pergunta
@ 555,003 SAY OemToAnsi("12 - "+STR0031) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"A lista de materiais/pecas esta completa ?"

@ 585,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 13a pergunta
@ 595,003 SAY OemToAnsi("13 - "+STR0032)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As Caracteristicas Especiais estao apropriadamente"
@ 605,003 SAY OemToAnsi(STR0033)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     documentadas ?"


// 14a pergunta
@ 627,003 MSPANEL oPanel1 PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE 395,012 OF oScrollBox
@ 004,004 SAY OemToAnsi(STR0034)	COLOR CLR_WHITE SIZE 150,010 OF oPanel1 PIXEL   //"   B. DESENHOS DE ENGENHARIA"
@ 645,003 SAY OemToAnsi("14 - "+STR0037) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram identificadas as dimensoes de referencia para"
@ 655,003 SAY OemToAnsi(STR0038) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     minimizar o tempo de layout de inspecao ?"

@ 670,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 15a pergunta
@ 680,003 SAY OemToAnsi("15 - "+STR0134) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Existem pontos de controle e superficies de referencia" 
@ 690,003 SAY OemToAnsi(STR0135) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     suficientemente indentificados para projetar dispositivos"
@ 700,003 SAY OemToAnsi(STR0136) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     funcionais ?"

@ 710,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 16a pergunta
@ 725,003 SAY OemToAnsi("16 - "+STR0042) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As Tolerancias sao compativeis com normas de" 
@ 735,003 SAY OemToAnsi(STR0043) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     manufatura aceitaveis ?"

@ 750,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 17a pergunta
@ 760,003 SAY OemToAnsi("17 - "+STR0091) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"As Técnicas de inspeção conhecidas podem"
@ 770,003 SAY OemToAnsi(STR0092) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"medir todos os requisitos do projeto?"
 

@ 790,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 18a pergunta
@ 800,003 SAY OemToAnsi("18 - "+STR0093) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"O processo de gerenciamento de alterações de" 
@ 810,003 SAY OemToAnsi(STR0094) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"engenharia designado pelo cliente é usado para"
@ 820,003 SAY OemToAnsi(STR0095) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont // "gerenciar as alterações de engenharia?"

//@ 825,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 19a pergunta
@ 832,003 MSPANEL oPanel1 PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE 395,012 OF oScrollBox
@ 004,004 SAY OemToAnsi(STR0047)	COLOR CLR_WHITE SIZE 350,010 OF oPanel1 PIXEL   //"   C. ESPECIFICACOES DE DESEMPENHO DE ENGENHARIA"
@ 850,003 SAY OemToAnsi("19 - "+STR0137)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As Caracteristicas especiais foram identificadas ?"

@ 875,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 20a pergunta
@ 885,003 SAY OemToAnsi("20 - "+STR0096) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"os Parametros de Teste sao suficientes para oferecer"
@ 895,003 SAY OemToAnsi(STR0097) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"todas as condições de uso, ou seja, validacão de"
@ 905,003 SAY OemToAnsi(STR0098)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"producão e uso final ?"

@ 915,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 21a pergunta
@ 925,003 SAY OemToAnsi("21 - "+STR0053) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Pecas fabricadas nas especificacoes minimas e"
@ 935,003 SAY OemToAnsi(STR0138) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     maximas foram testadas, conforme necessario ?"


@ 955,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 22a pergunta
@ 965,003 SAY OemToAnsi("22 - "+STR0139) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Todos os testes de produto serao feitos internamente ?"

@ 995,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 23a pergunta
@ 1005,003 SAY OemToAnsi("23 - "+STR0059) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Em caso contrario, eles serao o efetuados por um "
@ 1015,003 SAY OemToAnsi(STR0140) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     subfornecedor aprovado ?" 

@ 1035,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 24a pergunta
@ 1045,003 SAY OemToAnsi("24 - "+STR0099) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"A frequência e/ou tamanho de amostragem para "
@ 1055,003 SAY OemToAnsi(STR0100) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"os testes especificados de desempenho sao"
@ 1065,003 SAY OemToAnsi(STR0101) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"consistentes com os volumes de manufatura?"

@ 1075,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 25a pergunta
@ 1085,003 SAY OemToAnsi("25 - "+STR0122) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foi obtida a aprovação do Cliente, por exemplo, para"
@ 1095,003 SAY OemToAnsi(STR0123) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"os testes e documentação, conforme necessário?"

@ 1115,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 26a pergunta
@ 1117,003 MSPANEL oPanel1 PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE 395,012 OF oScrollBox
@ 004,004 SAY OemToAnsi(STR0065)	COLOR CLR_WHITE SIZE 156,010 OF oPanel1 PIXEL   //"   D. ESPECIFICACAO DE MATERIAIS" 
@ 1140,003 SAY OemToAnsi("26 - "+STR0066) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As caracteristicas especiais de material estao"
@ 1150,003 SAY OemToAnsi(STR0049) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     identificadas ?"

@ 1160,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 27a pergunta
@ 1170,003 SAY OemToAnsi("27 - "+STR0141) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Quando a Organização for responsável pelo projeto, os materiais,"
@ 1180,003 SAY OemToAnsi(STR0142)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"tratamento termino, e tratamento de superficie especificados são"
@ 1190,003 SAY OemToAnsi(STR0143)  SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"compatíveis com os requisitos de durabilidade no ambiente identificado?"

@ 1200,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 28a pergunta
@ 1210,003 SAY OemToAnsi("28 - "+STR0144) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Onde necessário, os fornecedores de material estao na lista
@ 1220,003 SAY OemToAnsi(STR0145) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     aprovada do cliente ?"


@ 1240,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 29a pergunta
@ 1250,003 SAY OemToAnsi("29 - "+STR0102) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"A organização desenvolveu e implementou um"
@ 1260,003 SAY OemToAnsi(STR0103) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"processo para controlar a qualidade dos materiais"
@ 1270,003 SAY OemToAnsi(STR0104) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"recebidos ?"

@ 1280,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 30a pergunta
@ 1290,003 SAY OemToAnsi("30 -"+STR0074) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram identificadas caracteristicas de material"
@ 1300,003 SAY OemToAnsi(STR0075) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     que necessitam de inspecao ?"
@ 1310,003 SAY OemToAnsi(STR0076) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     Em caso positivo, "

@ 1320,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 30a pergunta   (A)
@ 1330,003 SAY OemToAnsi("A - "+STR0077) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As caracteristicas serao verificadas internamente ?"

@ 1360,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 30a pergunta      (B)
@ 1370,003 SAY OemToAnsi("B - "+STR0146) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Se forem verificadas internamente, o equipamento"
@ 1380,003 SAY OemToAnsi(STR0147) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"de teste está disponível ?"

@ 1400,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 30a pergunta     (C)
@ 1410,003 SAY OemToAnsi("C - "+STR0105) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //" Se forem verificadas internamente , existem"
@ 1420,003 SAY OemToAnsi(STR0106) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"pessoas capacitadas para assegurar testes"
@ 1430,003 SAY OemToAnsi(STR0107) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"precisos ?"

@ 1440,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL
                                            

// 31a pergunta
@ 1450,003 SAY OemToAnsi("31 - "+STR0081) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Serao utilizados laboratorios externos ?"


@ 1480,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 31a pergunta     (A)
@ 1490,003 SAY OemToAnsi("A - "+STR0148)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"A organização possui um processo implantado"
@ 1500,003 SAY OemToAnsi(STR0149) 	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"para assegurar a competência do laboratório, tal"
@ 1510,003 SAY OemToAnsi(STR0124)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"como creditação? (Deve ser certificada)
@ 1520,003 SAY OemToAnsi(STR0111)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //""da Organização com o laboratório."

@ 1525,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 32a pergunta    (A)
@ 1535,003 SAY OemToAnsi("32 - "+STR0084) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"    Foram considerados os seguintes requisitos materiais ?" 
@ 1545,003 SAY OemToAnsi("A - "+STR0112) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Manuseio, incluindo aspectos ambientais ?"

@ 1565,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 32a pergunta     (B)
@ 1575,003 SAY OemToAnsi("B - "+STR0113) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Estocagem, incluindo aspectos ambientais ?"

@ 1605,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 32a pergunta        (C)
@ 1615,003 SAY OemToAnsi("C - "+STR0114) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"A Composição dos materiasi / Substancias foram"
@ 1625,003 SAY OemToAnsi(STR0115) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"reportadas de acordo com os requisitos do cliente,"
@ 1635,003 SAY OemToAnsi(STR0116) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"por exemplo, IMDS? "

@ 1645,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 32a pergunta   (D)
@ 1655,003 SAY OemToAnsi("D - "+STR0117) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As peças Polimetricas foram identificadas / Marcadas"
@ 1665,003 SAY OemToAnsi(STR0118) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"de acordo com os requisitos do cliente ?"

@ 1685,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL



Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP260Chec³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 07.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza conteudo das Variaveis                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP260Chec()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA260                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP260Chec()

Local nTamLin 	:= 38 // Tamanho da linha do texto
Local cEspecie 	:= "PPA260"
Local nSeq
Local aArea		:= {}

aArea := GetArea()

DbSelectArea("QKR")
DbSetOrder(1)
DbSeek(xFilial("QKR")+M->QKR_PECA+M->QKR_REV+"01")

Do While xFilial("QKR")+M->QKR_PECA+M->QKR_REV == QKR->QKR_FILIAL+QKR->QKR_PECA+QKR->QKR_REV ;
			.and. !Eof()
	
	nSeq := QKR->QKR_NPERG
	
	cChoice&(nSeq)	:= Iif(QKR_RPOSTA == "1", aItems[1],(Iif(QKR_RPOSTA == "2", aItems[2],aItems[3])))
	dData&(nSeq)	:= QKR->QKR_DTPREV
	cResp&(nSeq)	:= QKR->QKR_RESP

	If !Empty(QKR->QKR_CHAVE)
		cComent&(nSeq) := QO_Rectxt(M->QKR_CHAVE,cEspecie+nSeq,1, nTamLin,"QKO")
	Endif
		
	DbSelectArea("QKR")
	DbSkip()

Enddo


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA260Grav³ Autor ³ Robson Ramiro A Olivei³ Data ³ 07.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Gravacao Checklist APQP - A2 (Incl./Alter.)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA260Grav(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA260                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA260Grav(nOpc)

Local nCont, nRec
Local bCampo	:= { |nCPO| Field(nCPO) }
Local lGraOk	:= .T.
Local nTamLin	:= 38
Local cEspecie	:= "PPA260"
Local nSeq
Local nSaveSX8	:= GetSX8Len()
Local lMVQAPQPED := GetMV("MV_QAPQPED",.T.,"1") == "1"

DbSelectArea("QKR")
	
Begin Transaction

// Verifica se existe texto antes de criar chave
If Empty(cChave)
	cChave := GetSXENum("QKR", "QKR_CHAVE",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

Endif

DbSelectArea("QKR")
DbSetOrder(1)

For nRec := 1 To Iif(lMVQAPQPED,40,41)// 40 ou 41  perguntas
	
	nSeq := StrZero(nRec,2)

	If ALTERA
		If DbSeek(xFilial("QKR")+M->QKR_PECA+M->QKR_REV+nSeq)
			RecLock("QKR",.F.)
		Else
			RecLock("QKR",.T.)
		Endif
	Else
		RecLock("QKR",.T.)
	Endif

	For nCont := 1 To FCount()
		If "FILIAL"$Field(nCont)
			FieldPut(nCont,xFilial("QKR"))
		Else
			FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
		Endif
	Next nCont

	QKR->QKR_REVINV	:= Inverte(M->QKR_REV)
	QKR->QKR_NPERG	:= nSeq
	QKR->QKR_RPOSTA	:= Iif(cChoice&(nSeq) == STR0007,"1",Iif(cChoice&(nSeq) == STR0008,"2", "3") ) //"Sim"###"NAO"###"N/A"    
	QKR->QKR_DTPREV	:= &("dData"+Padr(nSeq,2))
	QKR->QKR_RESP	:= &("cResp"+Padr(nSeq,2))
	QKR->QKR_FILRES	:= cFilAnt
	QKR->QKR_CHAVE	:= cChave

	If !Empty(cComent&(nSeq))
		aComent&(nSeq) := GeraText(nTamLin, cComent&(nSeq))
		QO_GrvTxt(cChave,cEspecie+nSeq,1,@aComent&(nSeq))
	Endif
	
	DbSelectArea("QKR")

Next nRec
	
MsUnLock()

End Transaction

			
Return lGraOk

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PP260TudOk ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 07.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para inclusao/alteracao geral                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP260TudOk                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QPPA260                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PP260TudOk

Local lRetorno	:= .T.

If Empty(M->QKR_PECA) .or. Empty(M->QKR_REV)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
Endif

If INCLUI
	If !ExistChav("QKR",M->QKR_PECA+M->QKR_REV)
		lRetorno := .F.
		Help(" ",1,"JAGRAVADO")  // Campo ja Existe
	Endif
	If !ExistCpo("QK1",M->QKR_PECA+M->QKR_REV)
		lRetorno := .F.
		Help(" ",1,"REGNOIS")  // Nao existe amarracao
	Endif
Endif

Return lRetorno


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A260Dele ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 07.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fucao para exclusao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A260Dele()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA260                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A260Dele()

Local cEspecie := "PPA260"
Local nSeq, nRec, cKey
Local aArqRec := {}
Local lMVQAPQPED := GetMV("MV_QAPQPED",.T.,"1") == "1"

DbSelectArea("QKR")
DbSeek(xFilial("QKR")+M->QKR_PECA+M->QKR_REV+"01")

cKey := QKR->QKR_CHAVE

Do While xFilial("QKR")+M->QKR_PECA+M->QKR_REV == QKR->QKR_FILIAL+QKR->QKR_PECA+QKR->QKR_REV ;
			.and. !Eof()

	aAdd(aArqRec, Recno())  //alimenta array com os enderecos a serem deletados
	DbSkip()
Enddo

Begin Transaction

If Len(aArqRec) > 0

	For nRec := 1 To Iif(lMVQAPQPED,40,41)// 40 ou 41  perguntas    

		nSeq := StrZero(nRec,2)

		If !Empty(cKey)
			QO_DelTxt(cKey,cEspecie+nSeq) //QPPXFUN
		Endif
	 
		DbSelectArea("QKR")
		DbGoTo(aArqRec[nRec])
		RecLock("QKR",.F.)
		DbDelete()

	Next nRec

Endif

MsUnLock()
		
End Transaction

Return