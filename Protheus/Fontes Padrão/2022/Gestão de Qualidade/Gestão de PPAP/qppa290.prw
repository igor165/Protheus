#INCLUDE "QPPA290.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA290  ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 19.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Checklist APQP - A5 INSTALACOES                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA290(void)                                              ³±±
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

Local aRotina := { 	{ OemToAnsi(STR0001),"AxPesqui"  , 	0, 1,,.F.},; //"Pesquisar"
					{ OemToAnsi(STR0002),"PPA290Roti", 	0, 2},; 	  //"Visualizar"
					{ OemToAnsi(STR0003),"PPA290Roti", 	0, 3},; 	  //"Incluir"
					{ OemToAnsi(STR0004),"PPA290Roti", 	0, 4},; 	  //"Alterar"
					{ OemToAnsi(STR0005),"PPA290Roti", 	0, 5},; 	  //"Excluir"
					{ OemToAnsi(STR0042),"QPPR290(.T.)",0, 6,,.T.} } //"Imprimir"

Return aRotina

Function QPPA290()

Private cFiltro
						
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0006) //"Checklist APQP - A5 INSTALACOES"

Private aRotina := MenuDef()

DbSelectArea("QKU")
DbSetOrder(1)

cFiltro := 'QKU_NPERG == "01"'

Set Filter To &cFiltro
mBrowse( 6, 1, 22, 75,"QKU",,,,,,)
Set Filter To


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
?????????????????????????????????????????????????????????????????????????????
??ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ???
??ºPrograma  ?QPPA290CE   ºAutor  ?Klaus Daniel L.C   º Data ?  09/28/09   º??
??ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ???
??ºDesc.     ?Função que verifica com qual Edição foi feio A5               -??
??º          ?                                                            º??
??ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ???
??ºUso       ? AP                                                        º??
??ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ???
?????????????????????????????????????????????????????????????????????????????
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
  
//Consistencia para verificar se na base de dados a Lista de verificacao  (A5) foi realizada
//na primeira ou na segunda edicao do APQP, 


Function QPPA290CE()

Local nCont      :=0
Local cPecaR     :=""
Local aArea		 := {}


cPecaR 	:= (QKU->QKU_FILIAL+QKU->QKU_PECA+QKU->QKU_REV)

aArea := GetArea()                                         

DbSelectArea("QKU")
Set Filter To
DbSetOrder(1)
DbGoTop()
DbSeek(cPecaR+"01")   


Do while !Eof().and. QKU->QKU_FILIAL+QKU->QKU_PECA+QKU->QKU_REV == cPecaR
	nCont++
	Dbskip()  
	
Enddo
RestArea(aArea)


Return nCont

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA290Roti  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³19.08.02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Manutencao dos Dados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA290Roti(ExpC1,ExpN1,ExpN2)                           ³±±
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

Function PPA290Roti(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local lOk 			:= .F.
Local aCposVis		:= {}
Local aCposAlt		:= {}
Local aButtons		:= {}
Local nNresp        := 0 
Local lPriED290     := GetMV("MV_QAPQPED",.T.,"1") == '1' // Define se o APQP deve ser feito na primeira ou segunda edição 1 - Primeira Edição 2 - Segunda EdiçãO
Local cTitulo       := ""
Private cChave		:= ""
Private aItems 		:= {}

nNresp := QPPA290CE()  //Verifica pelo numro de NResp em qual modelo foi feio o APQP

If (nNresp == 14 .and. lPriED290)  .and. nOpc <> 3
Set filter to &cFiltro
	AVISO(STR0057,STR0058+STR0059+STR0060,{"Ok"},3,"MV_QAPQPED")	
	Return Nil

EndIf

If (nNresp == 13  .and. !lPriED290) .and. nOpc <> 3
Set filter to &cFiltro
	AVISO(STR0057,STR0058+STR0059+STR0060,{"Ok"},3,"MV_QAPQPED")	
	Return Nil

EndIF
 
If lPriED290  //Monta O array das respostas do combobox de acordo com o parametro MV_QAPQPED
	 aItems 		:= {STR0007,STR0008} //"Sim"###"Nao"
Else
	 aItems 		:= {STR0007,STR0008,STR0044} //"Sim"###"Nao"###"N/a"
EndIF


Private cComent01, cComent02, cComent03, cComent04
Private cComent05, cComent06, cComent07, cComent08
Private cComent09, cComent10, cComent11, cComent12
Private cComent13, cComent14

Private cChoice01 	:= cChoice02 := cChoice03 := cChoice04 	:= aItems[1]
Private cChoice05 	:= cChoice06 := cChoice07 := cChoice08 	:= aItems[1]
Private cChoice09 	:= cChoice10 := cChoice11 := cChoice12 	:= aItems[1]
Private cChoice13 	:= cChoice14 := aItems[1]

Private cResp01 	:= cResp02 := cResp03 := cResp04 			:= Space(10)
Private cResp05 	:= cResp06 := cResp07 := cResp08 			:= Space(10)
Private cResp09 	:= cResp10 := cResp11 := cResp12 			:= Space(10)
Private cResp13 	:= cResp14 := Space(10)

Private dData01 	:= dData02 := dData03 := dData04 			:= dDataBase
Private dData05 	:= dData06 := dData07 := dData08 			:= dDataBase
Private dData09 	:= dData10 := dData11 := dData12 			:= dDataBase
Private dData13 	:= dData14 := dDataBase

aCposVis := { "QKU_PECA", "QKU_REV", "QKU_DTREVI",	"QKU_RESPOR", "QKU_PREPOR" }

aCposAlt := { "QKU_DTREVI", "QKU_RESPOR", "QKU_PREPOR" }
				
If nOpc == 2 
	aButtons := {{"BMPVISUAL",	{ || QPPR290() }, OemToAnsi(STR0009), OemToAnsi(STR0043) }} //"Visualizar/Imprimir"###"Vis/Prn"
Endif

If nOpc == 4
	If !QPPVldAlt(QKU->QKU_PECA,QKU->QKU_REV)
		Return
	Endif
Endif

DbSelectArea(cAlias)

Set Filter To

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lPriED290  //Monta o Titulo da Janela de acordo com o parametro MV_QAPQPED
	cTitulo := STR0006
Else
	cTitulo := STR0006+STR0061
EndIF

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitulo) ; //"Checklist APQP - A5 INSTALACOES"
						FROM 120,000 TO 580,795 OF oMainWnd PIXEL
						
RegToMemory("QKU",(nOpc == 3))

Enchoice("QKU",nReg,nOpc, , , ,aCposVis ,{30,03,85,395}, , , , ,)

If GetMV("MV_QAPQPED",.F.,"1") == '1'
	QP290TEL(nOpc, oDlg)
Else
	QP290TED(nOpc, oDlg)
EndIF                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP290TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, ,aButtons ) CENTERED

If lOk .and. (nOpc == 3 .or. nOpc == 4)
	PPA290Grav(nOpc)
Endif

If nOpc == 5 .and. lOk
	A290Dele()
Endif

Set Filter To &cFiltro

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QP290TEL³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 19.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para informacoes do ScrollBox                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QP290TEL(ExpN1, ExpO1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±³          ³ ExpO1 = Dialog       									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA290                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QP290TEL(nOpc, oDlg)

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
	QPP290CHEC()
Endif

@ 088,003 MSPANEL oPanel1 PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE 395,012 OF oDlg
@ 004,004 SAY OemToAnsi(STR0010)	COLOR CLR_WHITE SIZE 065,010 OF oPanel1 PIXEL  //"Item - Pergunta"
@ 004,150 SAY OemToAnsi(STR0011) 	COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL  //"Sim/Nao"
@ 004,190 SAY OemToAnsi(STR0012)	COLOR CLR_WHITE SIZE 090,010 OF oPanel1 PIXEL  //"Comentarios/Acao Requerida"
@ 004,300 SAY OemToAnsi(STR0013)	COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL  //"Responsavel"
@ 004,347 SAY OemToAnsi(STR0014)	COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL  //"Dt. Prevista"

oScrollBox := TScrollBox():New(oDlg,103,03,125,395,.T.,.F.,.T.)

@ 001,002 TO 545,142 	OF oScrollBox PIXEL
@ 001,002 TO 545,167 	OF oScrollBox PIXEL
@ 001,002 TO 545,298 	OF oScrollBox PIXEL
@ 001,002 TO 545,345.5	OF oScrollBox PIXEL
@ 001,002 TO 545,385	OF oScrollBox PIXEL

// 1a pergunta
@ 015,144 COMBOBOX oCombo VAR cChoice01 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 015,168 GET oComent VAR cComent01 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 015,298 MSGET oResp VAR cResp01 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 015,346 MSGET oData VAR dData01 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 2a pergunta
@ 055,144 COMBOBOX oCombo VAR cChoice02 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 055,168 GET oComent VAR cComent02 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 055,298 MSGET oResp VAR cResp02 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 055,346 MSGET oData VAR dData02 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 3a pergunta
@ 095,144 COMBOBOX oCombo VAR cChoice03 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 095,168 GET oComent VAR cComent03 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 095,298 MSGET oResp VAR cResp03 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 095,346 MSGET oData VAR dData03 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 4a pergunta
@ 145,144 COMBOBOX oCombo VAR cChoice04 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 145,168 GET oComent VAR cComent04 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 145,298 MSGET oResp VAR cResp04 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 145,346 MSGET oData VAR dData04 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 5a pergunta
@ 185,144 COMBOBOX oCombo VAR cChoice05 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 185,168 GET oComent VAR cComent05 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 185,298 MSGET oResp VAR cResp05 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 185,346 MSGET oData VAR dData05 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 6a pergunta
@ 225,144 COMBOBOX oCombo VAR cChoice06 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 225,168 GET oComent VAR cComent06 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 225,298 MSGET oResp VAR cResp06 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 225,346 MSGET oData VAR dData06 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 7a pergunta
@ 265,144 COMBOBOX oCombo VAR cChoice07 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 265,168 GET oComent VAR cComent07 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 265,298 MSGET oResp VAR cResp07 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 265,346 MSGET oData VAR dData07 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 8a pergunta
@ 305,144 COMBOBOX oCombo VAR cChoice08 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 305,168 GET oComent VAR cComent08 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 305,298 MSGET oResp VAR cResp08 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 305,346 MSGET oData VAR dData08 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 9a pergunta
@ 345,144 COMBOBOX oCombo VAR cChoice09 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 345,168 GET oComent VAR cComent09 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 345,298 MSGET oResp VAR cResp09 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 345,346 MSGET oData VAR dData09 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 10a pergunta
@ 385,144 COMBOBOX oCombo VAR cChoice10 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 385,168 GET oComent VAR cComent10 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 385,298 MSGET oResp VAR cResp10 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 385,346 MSGET oData VAR dData10 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 11a pergunta
@ 425,144 COMBOBOX oCombo VAR cChoice11 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 425,168 GET oComent VAR cComent11 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 425,298 MSGET oResp VAR cResp11 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 425,346 MSGET oData VAR dData11 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 12a pergunta
@ 465,144 COMBOBOX oCombo VAR cChoice12 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 465,168 GET oComent VAR cComent12 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 465,298 MSGET oResp VAR cResp12 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 465,346 MSGET oData VAR dData12 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 13a pergunta
@ 505,144 COMBOBOX oCombo VAR cChoice13 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 505,168 GET oComent VAR cComent13 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 505,298 MSGET oResp VAR cResp13 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 505,346 MSGET oData VAR dData13 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

QP290SE(oScrollBox, oFont)

If !Empty(M->QKU_CHAVE)
	cChave := M->QKU_CHAVE
Endif

If nOpc <> 3 .and. nOpc <> 4
	For nCont := 1 To Len(aObj)
		aObj[nCont,1]:lReadOnly 	:= .T.
		aObj[nCont,2]:lReadOnly 	:= .T.
		aObj[nCont,3]:lReadOnly 	:= .T.
	Next nCont
Else
	For nCont := 1 To Len(aObj)
		aObj[nCont,4]:lReadOnly 	:= .F.
	Next nCont
Endif

Return .T.                                  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QP290SE ³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 19.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra os SAYS da funcao QPP290Tela                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QP290SE(ExpO1, ExpO2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do Scrool                                   ³±±
±±³          ³ ExpO2 = Objeto da font                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA290                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Obs      ³ Funcao criada devido a erro de Memory Overbooked           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function QP290SE(oScrollBox, oFont)

// 1a pergunta

@ 015,003 SAY OemToAnsi("1 - "+STR0015) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As instalacoes e equipamentos de inspecao sao"
@ 025,003 SAY OemToAnsi(STR0016) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"    adequados  para proporcionar uma inspecao dimensional"
@ 035,003 SAY OemToAnsi(STR0017) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"    inicial e continua em todos os detalhes e componentes ?"

@ 045,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 2a pergunta
@ 055,003 SAY OemToAnsi("2 - "+STR0018) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Foram claramente marcadas as areas para todos os"
@ 065,003 SAY OemToAnsi(STR0019) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"    materiais, ferramentas e equipamentos para cada"
@ 075,003 SAY OemToAnsi(STR0020) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"    operacao considerada ?"
                                                     
@ 085,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 3a pergunta
@ 095,003 SAY OemToAnsi("3 - "+STR0021) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foi reservado espaco suficiente para todos os"
@ 105,003 SAY OemToAnsi(STR0022) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"    equipamentos ?"

@ 135,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 4a pergunta
@ 145,003 SAY OemToAnsi(STR0023) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"  AS AREAS DE PROCESSO E INSPECAO SAO :"
@ 155,003 SAY OemToAnsi("4 * "+STR0024) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"De tamanho adequado ?"

@ 175,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 5a pergunta
@ 185,003 SAY OemToAnsi("5 * "+STR0025) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Corretamente iluminadas ?"

@ 215,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 6a pergunta
@ 225,003 SAY OemToAnsi("6 - "+STR0026) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As areas de inspecao contem equipamentos e arquivos"
@ 235,003 SAY OemToAnsi(STR0027) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"    necessarios ?"

@ 255,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 7a pergunta
@ 265,003 SAY OemToAnsi(STR0028) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"  SAO ADEQUADAS :"
@ 275,003 SAY OemToAnsi("7 * "+STR0029) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Areas de Elevacao ?"

@ 295,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 8a pergunta
@ 305,003 SAY OemToAnsi("8 * "+STR0030) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Areas de retencao ?"

@ 335,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 9a pergunta
@ 345,003 SAY OemToAnsi("9 - "+STR0031) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Os pontos de inspecao estao logicamente localizados"
@ 355,003 SAY OemToAnsi(STR0032) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"    para evitar a entrega de produtos nao conformes ?"

@ 375,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 10a pergunta
@ 385,003 SAY OemToAnsi("10 - "+STR0033) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram estabelecidos controles para eliminar o potencial"
@ 395,003 SAY OemToAnsi(STR0034) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     para uma operacao, inclusive processamento externo,"
@ 405,003 SAY OemToAnsi(STR0035) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     contaminar ou misturar produtos similares ?"

@ 415,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 11a pergunta
@ 425,003 SAY OemToAnsi("11 - "+STR0036) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"O material esta protegido da contaminacao de sistemas"
@ 435,003 SAY OemToAnsi(STR0037) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     de manipulacao volante ou ar comprimido ?"

@ 455,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 12a pergunta
@ 465,003 SAY OemToAnsi("12 - "+STR0038) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram providenciadas instalacoes para a auditoria final ?"

@ 495,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 13a pergunta
@ 505,003 SAY OemToAnsi("13 - "+STR0039) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Os controles sao adequados para evitar o movimento"
@ 515,003 SAY OemToAnsi(STR0040) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     de material de entrada fora de conformidade para"
@ 525,003 SAY OemToAnsi(STR0041) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     estocagem ou ponto de utilizacao ?"

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QP290TED³ Autor ³ Klaus Daniel Lopes Cabral³ Data ³ 19.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para informacoes do ScrollBox   /2ª Edição APQP       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QP290TED(ExpN1, ExpO1)--> Segunda Edição do APQP           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±³          ³ ExpO1 = Dialog       									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA290                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QP290TED(nOpc, oDlg) //Segunda Edição do APQP

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
	QPP290CHEC()
Endif

@ 088,003 MSPANEL oPanel1 PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE 395,012 OF oDlg
@ 004,004 SAY OemToAnsi(STR0010)	COLOR CLR_WHITE SIZE 065,010 OF oPanel1 PIXEL  //"Item - Pergunta"
@ 004,135 SAY OemToAnsi(STR0011) 	COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL  //"Sim/Nao"
@ 004,155 SAY OemToAnsi("/"+STR0044) 	COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL  //"N/a"
@ 004,190 SAY OemToAnsi(STR0012)	COLOR CLR_WHITE SIZE 090,010 OF oPanel1 PIXEL  //"Comentarios/Acao Requerida"
@ 004,300 SAY OemToAnsi(STR0013)	COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL  //"Responsavel"
@ 004,347 SAY OemToAnsi(STR0014)	COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL  //"Dt. Prevista"

oScrollBox := TScrollBox():New(oDlg,103,03,125,395,.T.,.F.,.T.)

@ 001,002 TO 575,142 	OF oScrollBox PIXEL
@ 001,002 TO 575,167 	OF oScrollBox PIXEL
@ 001,002 TO 575,298 	OF oScrollBox PIXEL
@ 001,002 TO 575,345.5	OF oScrollBox PIXEL
@ 001,002 TO 575,385	OF oScrollBox PIXEL

// 1a pergunta
@ 015,144 COMBOBOX oCombo VAR cChoice01 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 015,168 GET oComent VAR cComent01 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 015,298 MSGET oResp VAR cResp01 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 015,346 MSGET oData VAR dData01 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 2a pergunta
@ 055,144 COMBOBOX oCombo VAR cChoice02 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 055,168 GET oComent VAR cComent02 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 055,298 MSGET oResp VAR cResp02 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 055,346 MSGET oData VAR dData02 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 3a pergunta
@ 095,144 COMBOBOX oCombo VAR cChoice03 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 095,168 GET oComent VAR cComent03 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 095,298 MSGET oResp VAR cResp03 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 095,346 MSGET oData VAR dData03 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 4a pergunta
@ 135,144 COMBOBOX oCombo VAR cChoice04 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 135,168 GET oComent VAR cComent04 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 135,298 MSGET oResp VAR cResp04 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 135,346 MSGET oData VAR dData04 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 5a pergunta
@ 175,144 COMBOBOX oCombo VAR cChoice05 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 175,168 GET oComent VAR cComent05 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 175,298 MSGET oResp VAR cResp05 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 175,346 MSGET oData VAR dData05 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 6a pergunta
@ 215,144 COMBOBOX oCombo VAR cChoice06 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 215,168 GET oComent VAR cComent06 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 215,298 MSGET oResp VAR cResp06 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 215,346 MSGET oData VAR dData06 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 7a pergunta
@ 255,144 COMBOBOX oCombo VAR cChoice07 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 255,168 GET oComent VAR cComent07 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 255,298 MSGET oResp VAR cResp07 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 255,346 MSGET oData VAR dData07 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 8a pergunta
@ 295,144 COMBOBOX oCombo VAR cChoice08 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 295,168 GET oComent VAR cComent08 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 295,298 MSGET oResp VAR cResp08 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 295,346 MSGET oData VAR dData08 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 9a pergunta
@ 335,144 COMBOBOX oCombo VAR cChoice09 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 335,168 GET oComent VAR cComent09 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 335,298 MSGET oResp VAR cResp09 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 335,346 MSGET oData VAR dData09 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 10a pergunta
@ 375,144 COMBOBOX oCombo VAR cChoice10 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 375,168 GET oComent VAR cComent10 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 375,298 MSGET oResp VAR cResp10 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 375,346 MSGET oData VAR dData10 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 11a pergunta
@ 415,144 COMBOBOX oCombo VAR cChoice11 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 415,168 GET oComent VAR cComent11 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 415,298 MSGET oResp VAR cResp11 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 415,346 MSGET oData VAR dData11 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 12a pergunta
@ 455,144 COMBOBOX oCombo VAR cChoice12 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 455,168 GET oComent VAR cComent12 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 455,298 MSGET oResp VAR cResp12 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 455,346 MSGET oData VAR dData12 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 13a pergunta
@ 495,144 COMBOBOX oCombo VAR cChoice13 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 495,168 GET oComent VAR cComent13 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 495,298 MSGET oResp VAR cResp13 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 495,346 MSGET oData VAR dData13 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 14a pergunta
@ 535,144 COMBOBOX oCombo VAR cChoice14 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 535,168 GET oComent VAR cComent14 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 535,298 MSGET oResp VAR cResp14 PICTURE PesqPict("QKU","QKU_RESP") ;
						ReadOnly F3 ConSX3("QKU_RESP") VALID CheckSx3("QKU_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 535,346 MSGET oData VAR dData14 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


QP290SED(oScrollBox, oFont)   

If !Empty(M->QKU_CHAVE)
	cChave := M->QKU_CHAVE
Endif

If nOpc <> 3 .and. nOpc <> 4
	For nCont := 1 To Len(aObj)
		aObj[nCont,1]:lReadOnly 	:= .T.
		aObj[nCont,2]:lReadOnly 	:= .T.
		aObj[nCont,3]:lReadOnly 	:= .T.
	Next nCont
Else
	For nCont := 1 To Len(aObj)
		aObj[nCont,4]:lReadOnly 	:= .F.
	Next nCont
Endif

Return .T.                                  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QP290SED ³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 19.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra os SAYS da funcao QPP290Tela                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QP290SED(ExpO1, ExpO2) //2 Edição APQP                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do Scrool                                   ³±±
±±³          ³ ExpO2 = Objeto da font                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA290                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Obs      ³ Funcao criada devido a erro de Memory Overbooked           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function QP290SED(oScrollBox, oFont)   //Segunda Edição do APQP

// 1a pergunta

@ 015,003 SAY OemToAnsi("1 - "+STR0045) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram aplicados conceitos 'Lean' ao considerar o"
@ 025,003 SAY OemToAnsi(STR0046) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Fluxo de Material?"

@ 045,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 2a pergunta

@ 055,003 SAY OemToAnsi("2 - "+STR0047) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As instalações Identificam todos os processos requeridos"
@ 065,003 SAY OemToAnsi(STR0048) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"e pontos de Inspeção?"

@ 085,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL


// 3a pergunta
@ 095,003 SAY OemToAnsi("3 - "+STR0062) SIZE 150,010 OF oScrollBox PIXEL FONT oFont   //"Foram consideradas áreas claramente marcadas para"
@ 105,003 SAY OemToAnsi(STR0063) SIZE 150,010 OF oScrollBox PIXEL FONT oFont          //"todos os materiais, ferramentas e equipamentos para "
@ 115,003 SAY OemToAnsi(STR0056) SIZE 150,010 OF oScrollBox PIXEL FONT oFont          //"cada operação ?"
                                                     
@ 125,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 4a pergunta
@ 135,003 SAY OemToAnsi("4 - "+STR0021) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foi reservado espaco suficiente para todos os"
@ 145,003 SAY OemToAnsi(STR0022) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"    equipamentos ?"

@ 165,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 5a pergunta
@ 175,003 SAY OemToAnsi(STR0023) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"  AS AREAS DE PROCESSO E INSPECAO SAO :"
@ 185,003 SAY OemToAnsi("5 * "+STR0024) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"De tamanho adequado ?"

@ 205,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 6a pergunta
@ 215,003 SAY OemToAnsi("6 * "+STR0025) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Corretamente iluminadas ?"

@ 245,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 7a pergunta
@ 255,003 SAY OemToAnsi("7 - "+STR0026) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As areas de inspecao contem equipamentos e arquivos"
@ 265,003 SAY OemToAnsi(STR0027) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"    necessarios ?"

@ 285,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 8a pergunta
@ 295,003 SAY OemToAnsi(STR0028) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"  SAO ADEQUADAS :"
@ 305,003 SAY OemToAnsi("8 * "+STR0029) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Areas de Elevacao ?"

@ 325,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 9a pergunta
@ 345,003 SAY OemToAnsi("9 * "+STR0030) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Areas de retencao ?"

@ 365,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 10a pergunta
@ 375,003 SAY OemToAnsi("10 - "+STR0031) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Os pontos de inspecao estao logicamente localizados"
@ 385,003 SAY OemToAnsi(STR0032) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"    para evitar a entrega de produtos nao conformes ?"

@ 405,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 11a pergunta
@ 415,003 SAY OemToAnsi("11 - "+STR0049) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram Estabelecidos controles para cada processo "
@ 425,003 SAY OemToAnsi(STR0050) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"para eliminar a contaminação ou mistura inadequada"
@ 435,003 SAY OemToAnsi(STR0051) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"de produtos?"

@ 445,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 12a pergunta
@ 455,003 SAY OemToAnsi("12 - "+STR0036) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"O material esta protegido da contaminacao de sistemas"
@ 465,003 SAY OemToAnsi(STR0037) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     de manipulacao volante ou ar comprimido ?"

@ 485,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 13a pergunta
@ 495,003 SAY OemToAnsi("13 - "+STR0055) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram providenciadas instalações para auditoria do "
@ 505,003 SAY OemToAnsi(STR0054) SIZE 150,010 OF oScrollBox PIXEL FONT oFont          //"produto final ?"

@ 525,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 14a pergunta
@ 535,003 SAY OemToAnsi("14 - "+STR0052) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As Instalações são adequadas para controlar o"
@ 545,003 SAY OemToAnsi(STR0053) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"movimento de material de entrada nao conforme?"


Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP290Chec³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 19.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza conteudo das Variaveis                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP290Chec()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA290                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP290Chec()

Local nTamLin 	:= 38 // Tamanho da linha do texto
Local cEspecie 	:= "PPA290"
Local nSeq
Local aArea		:= {}

aArea := GetArea()

DbSelectArea("QKU")
DbSetOrder(1)
DbSeek(xFilial("QKU")+M->QKU_PECA+M->QKU_REV+"01")

Do While xFilial("QKU")+M->QKU_PECA+M->QKU_REV == QKU->QKU_FILIAL+QKU->QKU_PECA+QKU->QKU_REV ;
			.and. !Eof()
	
	nSeq := QKU->QKU_NPERG
	
	cChoice&(nSeq)	:= Iif(QKU_RPOSTA == "1", aItems[1],(Iif(QKU_RPOSTA == "2", aItems[2],aItems[3])))
	dData&(nSeq)	:= QKU->QKU_DTPREV
	cResp&(nSeq)	:= QKU->QKU_RESP

	If !Empty(QKU->QKU_CHAVE)
		cComent&(nSeq) := QO_Rectxt(M->QKU_CHAVE,cEspecie+nSeq,1, nTamLin,"QKO")
	Endif
		
	DbSelectArea("QKU")
	DbSkip()

Enddo

RestArea(aArea)

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA290Grav³ Autor ³ Robson Ramiro A Olivei³ Data ³ 19.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Gravacao Checklist APQP - A5 (Incl./Alter.)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA290Grav(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA290                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA290Grav(nOpc)

Local nCont, nRec
Local bCampo	:= { |nCPO| Field(nCPO) }
Local lGraOk	:= .T.
Local nTamLin	:= 38
Local cEspecie	:= "PPA290"
Local nSeq
Local nSaveSX8	:= GetSX8Len()
Local lMVQAPQPED := GetMV("MV_QAPQPED",.T.,"1") == "1"
DbSelectArea("QKU")
	
Begin Transaction

// Verifica se existe texto antes de criar chave
If Empty(cChave)
	cChave := GetSXENum("QKU", "QKU_CHAVE",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

Endif

DbSelectArea("QKU")
DbSetOrder(1)

For nRec := 1 To Iif(lMVQAPQPED,13,14)// 13 ou 14 perguntas
	
	nSeq := StrZero(nRec,2)

	If ALTERA
		If DbSeek(xFilial("QKU")+M->QKU_PECA+M->QKU_REV+nSeq)
			RecLock("QKU",.F.)
		Else
			RecLock("QKU",.T.)
		Endif
	Else
		RecLock("QKU",.T.)
	Endif

	For nCont := 1 To FCount()
		If "FILIAL"$Field(nCont)
			FieldPut(nCont,xFilial("QKU"))
		Else
			FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
		Endif
	Next nCont

	QKU->QKU_REVINV	:= Inverte(M->QKU_REV)
	QKU->QKU_NPERG	:= nSeq
	QKU->QKU_RPOSTA	:= Iif(cChoice&(nSeq) == STR0007,"1",Iif(cChoice&(nSeq) == STR0008,"2", "3") ) //"Sim"###"NAO"###"N/A"    
	QKU->QKU_DTPREV	:= &("dData"+Padr(nSeq,2))
	QKU->QKU_RESP	:= &("cResp"+Padr(nSeq,2))
	QKU->QKU_FILRES	:= cFilAnt
	QKU->QKU_CHAVE	:= cChave

	If !Empty(cComent&(nSeq))
		aComent&(nSeq) := GeraText(nTamLin, cComent&(nSeq))
		QO_GrvTxt(cChave,cEspecie+nSeq,1,@aComent&(nSeq))
	Endif
	
	DbSelectArea("QKU")

Next nRec
	
MsUnLock()

End Transaction

			
Return lGraOk

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PP290TudOk ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 19.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para inclusao/alteracao geral                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP290TudOk                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QPPA290                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PP290TudOk

Local lRetorno	:= .T.

If Empty(M->QKU_PECA) .or. Empty(M->QKU_REV)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
Endif

If INCLUI
	If !ExistChav("QKU",M->QKU_PECA+M->QKU_REV)
		lRetorno := .F.
		Help(" ",1,"JAGRAVADO")  // Campo ja Existe
	Endif
	If !ExistCpo("QK1",M->QKU_PECA+M->QKU_REV)
		lRetorno := .F.
		Help(" ",1,"REGNOIS")  // Nao existe amarracao
	Endif
Endif

Return lRetorno


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A290Dele ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 19.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fucao para exclusao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A290Dele()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA290                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A290Dele()

Local cEspecie := "PPA290"
Local nSeq, nRec, cKey
Local aArqRec := {}
Local lMVQAPQPED := GetMV("MV_QAPQPED",.T.,"1") == "1"

DbSelectArea("QKU")
DbSeek(xFilial("QKU")+M->QKU_PECA+M->QKU_REV+"01")

cKey := QKU->QKU_CHAVE

Do While xFilial("QKU")+M->QKU_PECA+M->QKU_REV == QKU->QKU_FILIAL+QKU->QKU_PECA+QKU->QKU_REV ;
			.and. !Eof()

	aAdd(aArqRec, Recno())  //alimenta array com os enderecos a serem deletados
	DbSkip()
Enddo

Begin Transaction

If Len(aArqRec) > 0

	For nRec := 1 To Iif(lMVQAPQPED,13,14)  //13 ou 14 perguntas 

		nSeq := StrZero(nRec,2)

		If !Empty(cKey)
			QO_DelTxt(cKey,cEspecie+nSeq) //QPPXFUN
		Endif
	 
		DbSelectArea("QKU")
		DbGoTo(aArqRec[nRec])
		RecLock("QKU",.F.)
		DbDelete()

	Next nRec

Endif

MsUnLock()
		
End Transaction

Return