#INCLUDE "QPPA270.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA270  ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 13.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Checklist APQP - A3 NOVOS EQUIPAMENTOS, FERRAMENTAL E TESTE³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA270(void)                                              ³±±
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

Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui"  , 	0, 1,,.F.},; 	//"Pesquisar"
					{ OemToAnsi(STR0002), "PPA270Roti", 	0, 2},;  		//"Visualizar"
					{ OemToAnsi(STR0003), "PPA270Roti", 	0, 3},; 		//"Incluir"
					{ OemToAnsi(STR0004), "PPA270Roti", 	0, 4},; 		//"Alterar"
					{ OemToAnsi(STR0005), "PPA270Roti", 	0, 5},; 		//"Excluir"
					{ OemToAnsi(STR0054), "QPPR270(.T.)", 	0, 6,,.T.} }	//"Imprimir"

Return aRotina

Function QPPA270()

Private cFiltro
						
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0006) //"Checklist APQP - A3 NOVOS EQUIPAMENTOS, FERRAMENTAL E TESTE"

Private aRotina := MenuDef()

DbSelectArea("QKS")
DbSetOrder(1)

cFiltro := 'QKS_NPERG == "01"'

Set Filter To &cFiltro
mBrowse( 6, 1, 22, 75,"QKS",,,,,,)
Set Filter To


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
?????????????????????????????????????????????????????????????????????????????
??ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ???
??ºPrograma  ?QPPA270CE   ºAutor  ?Klaus Daniel L.C   º Data ?  09/28/09   º??
??ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ???
??ºDesc.     ?Função que verifica com qual Edição foi feio                 ??
??º          ?                                                            º??
??ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ???
??ºUso       ? AP                                                        º??
??ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ???
?????????????????????????????????????????????????????????????????????????????
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
  
//Consistencia para verificar se na base de dados (A3) foi realizada
//na primeira ou na segunda edicao do APQP, 


Function QPPA270CE()

Local nCont      :=0
Local cPecaR     :=""
Local aArea		 := {}


cPecaR 	:= (QKS->QKS_FILIAL+QKS->QKS_PECA+QKS->QKS_REV)

aArea := GetArea()                                         

DbSelectArea("QKS")
Set Filter To
DbSetOrder(1)
DbGoTop()
DbSeek(cPecaR+"01")   


Do while !Eof().and. QKS->QKS_FILIAL+QKS->QKS_PECA+QKS->QKS_REV == cPecaR
	nCont++
	Dbskip()  
	
Enddo
RestArea(aArea)


Return nCont

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA270Roti  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³13.08.02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Manutencao dos Dados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA270Roti(ExpC1,ExpN1,ExpN2)                           ³±±
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

Function PPA270Roti(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local lOk 			:= .F.
Local aCposVis		:= {}
Local aCposAlt		:= {}
Local aButtons		:= {}
Local nNresp        := 0 
Local lPriED270     := GetMV("MV_QAPQPED",.T.,"1") == '1' // Define se o APQP deve ser feito na primeira ou segunda edição 1 - Primeira Edição 2 - Segunda Edição
Local cTitulo       := ""
Private cChave		:= ""
Private aItems      := {}  


nNresp := QPPA270CE()  //Verifica pelo numro de NResp em qual modelo foi feio o APQP

If (nNresp == 21 .and. lPriED270)  .and. nOpc <> 3
Set filter to &cFiltro
	AVISO(STR0064,STR0065+STR0066+STR0067,{"Ok"},3,"MV_QAPQPED")
	Return Nil

EndIf

If (nNresp == 20 .and. !lPriED270) .and. nOpc <> 3
Set filter to &cFiltro
	AVISO(STR0064,STR0065+STR0066+STR0067,{"Ok"},3,"MV_QAPQPED")
     Return Nil
EndIF
 
If lPriED270
	 aItems 		:= {STR0007,STR0008} //"Sim"###"Nao"
Else
	 aItems 		:= {STR0007,STR0008,STR0056} //"Sim"###"Nao"###"N/a"
EndIF



Private cComent01, cComent02, cComent03, cComent04
Private cComent05, cComent06, cComent07, cComent08
Private cComent09, cComent10, cComent11, cComent12
Private cComent13, cComent14, cComent15, cComent16
Private cComent17, cComent18, cComent19, cComent20, cComent21

Private cChoice01 	:= cChoice02 := cChoice03 := cChoice04 	:= aItems[1]
Private cChoice05 	:= cChoice06 := cChoice07 := cChoice08 	:= aItems[1]
Private cChoice09 	:= cChoice10 := cChoice11 := cChoice12 	:= aItems[1]
Private cChoice13 	:= cChoice14 := cChoice15 := cChoice16 	:= aItems[1]
Private cChoice17 	:= cChoice18 := cChoice19 := cChoice20 := cChoice21	:= aItems[1]


Private cResp01 	:= cResp02 := cResp03 := cResp04 			        := Space(10)
Private cResp05 	:= cResp06 := cResp07 := cResp08 			        := Space(10)
Private cResp09 	:= cResp10 := cResp11 := cResp12 			        := Space(10)
Private cResp13 	:= cResp14 := cResp15 := cResp16 		        	:= Space(10)
Private cResp17 	:= cResp18 := cResp19 := cResp20 := cResp21			:= Space(10)

Private dData01 	:= dData02 := dData03 := dData04 			        := dDataBase
Private dData05 	:= dData06 := dData07 := dData08 			        := dDataBase
Private dData09 	:= dData10 := dData11 := dData12 			        := dDataBase
Private dData13 	:= dData14 := dData15 := dData16 		        	:= dDataBase
Private dData17 	:= dData18 := dData19 := dData20 := dData21			:= dDataBase

aCposVis := { "QKS_PECA", "QKS_REV", "QKS_DTREVI",	"QKS_RESPOR", "QKS_PREPOR" }

aCposAlt := { "QKS_DTREVI", "QKS_RESPOR", "QKS_PREPOR" }
				
If nOpc == 2 
	aButtons := {{"BMPVISUAL",	{ || QPPR270() }, OemToAnsi(STR0009), OemToAnsi(STR0055) }} //"Visualizar/Imprimir"###"Vis/Prn"
Endif

If nOpc == 4
	If !QPPVldAlt(QKS->QKS_PECA,QKS->QKS_REV)
		Return
	Endif
Endif

DbSelectArea(cAlias)

Set Filter To

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lPriED270   //Monta o Titulo de acordo com o Parametro MV_QAPQPED
	cTitulo := STR0006
Else
	cTitulo := STR0006+STR0068
Endif

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitulo) ; //"Checklist APQP - A3 NOVOS EQUIPAMENTOS, FERRAMENTAL E TESTE"
						FROM 120,000 TO 580,795 OF oMainWnd PIXEL
						
RegToMemory("QKS",(nOpc == 3))

Enchoice("QKS",nReg,nOpc, , , ,aCposVis ,{30,03,85,395}, , , , ,)

//Na inclusão Chama a Tela de Acordo com a Versao do APQP.

If GetMV("MV_QAPQPED",.F.,"1") == '1'
	QP270TEL(nOpc, oDlg)
Else
	QP270TED(nOpc, oDlg)
Endif
                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP270TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, ,aButtons ) CENTERED

If lOk .and. (nOpc == 3 .or. nOpc == 4)
	PPA270Grav(nOpc)
Endif

If nOpc == 5 .and. lOk
	A270Dele()
Endif

Set Filter To &cFiltro

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QP270TEL³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 13.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para informacoes do ScrollBox (1ª Edição)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QP270TEL(ExpN1, ExpO1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±³          ³ ExpO1 = Dialog       									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA270                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QP270TEL(nOpc, oDlg)

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
	QPP270CHEC()
Endif

@ 088,003 MSPANEL oPanel1 PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE 395,012 OF oDlg
@ 004,004 SAY OemToAnsi(STR0010)	COLOR CLR_WHITE SIZE 065,010 OF oPanel1 PIXEL  //"Item - Pergunta"
@ 004,150 SAY OemToAnsi(STR0011) 	COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL  //"Sim/Nao"
@ 004,190 SAY OemToAnsi(STR0012)	COLOR CLR_WHITE SIZE 090,010 OF oPanel1 PIXEL  //"Comentarios/Acao Requerida"
@ 004,300 SAY OemToAnsi(STR0013)	COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL  //"Responsavel"
@ 004,347 SAY OemToAnsi(STR0014)	COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL  //"Dt. Prevista"

oScrollBox := TScrollBox():New(oDlg,103,03,125,395,.T.,.F.,.T.)

@ 001,002 TO 825,142 		OF oScrollBox PIXEL
@ 001,002 TO 825,167 		OF oScrollBox PIXEL
@ 001,002 TO 825,298 		OF oScrollBox PIXEL
@ 001,002 TO 825,345.5		OF oScrollBox PIXEL
@ 001,002 TO 825,385		OF oScrollBox PIXEL

// 1a pergunta
@ 015,144 COMBOBOX oCombo VAR cChoice01 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 015,168 GET oComent VAR cComent01 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 015,298 MSGET oResp VAR cResp01 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 015,346 MSGET oData VAR dData01 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 2a pergunta
@ 055,144 COMBOBOX oCombo VAR cChoice02 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 055,168 GET oComent VAR cComent02 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 055,298 MSGET oResp VAR cResp02 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 055,346 MSGET oData VAR dData02 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 3a pergunta
@ 095,144 COMBOBOX oCombo VAR cChoice03 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 095,168 GET oComent VAR cComent03 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 095,298 MSGET oResp VAR cResp03 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 095,346 MSGET oData VAR dData03 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 4a pergunta
@ 145,144 COMBOBOX oCombo VAR cChoice04 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 145,168 GET oComent VAR cComent04 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 145,298 MSGET oResp VAR cResp04 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 145,346 MSGET oData VAR dData04 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 5a pergunta
@ 185,144 COMBOBOX oCombo VAR cChoice05 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 185,168 GET oComent VAR cComent05 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 185,298 MSGET oResp VAR cResp05 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 185,346 MSGET oData VAR dData05 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 6a pergunta
@ 225,144 COMBOBOX oCombo VAR cChoice06 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 225,168 GET oComent VAR cComent06 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 225,298 MSGET oResp VAR cResp06 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 225,346 MSGET oData VAR dData06 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 7a pergunta
@ 265,144 COMBOBOX oCombo VAR cChoice07 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 265,168 GET oComent VAR cComent07 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 265,298 MSGET oResp VAR cResp07 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 265,346 MSGET oData VAR dData07 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 8a pergunta
@ 305,144 COMBOBOX oCombo VAR cChoice08 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 305,168 GET oComent VAR cComent08 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 305,298 MSGET oResp VAR cResp08 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 305,346 MSGET oData VAR dData08 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 9a pergunta
@ 345,144 COMBOBOX oCombo VAR cChoice09 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 345,168 GET oComent VAR cComent09 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 345,298 MSGET oResp VAR cResp09 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 345,346 MSGET oData VAR dData09 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 10a pergunta
@ 385,144 COMBOBOX oCombo VAR cChoice10 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 385,168 GET oComent VAR cComent10 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 385,298 MSGET oResp VAR cResp10 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 385,346 MSGET oData VAR dData10 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 11a pergunta
@ 425,144 COMBOBOX oCombo VAR cChoice11 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 425,168 GET oComent VAR cComent11 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 425,298 MSGET oResp VAR cResp11 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 425,346 MSGET oData VAR dData11 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 12a pergunta
@ 465,144 COMBOBOX oCombo VAR cChoice12 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 465,168 GET oComent VAR cComent12 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 465,298 MSGET oResp VAR cResp12 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 465,346 MSGET oData VAR dData12 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 13a pergunta
@ 505,144 COMBOBOX oCombo VAR cChoice13 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 505,168 GET oComent VAR cComent13 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 505,298 MSGET oResp VAR cResp13 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 505,346 MSGET oData VAR dData13 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 14a pergunta
@ 545,144 COMBOBOX oCombo VAR cChoice14 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 545,168 GET oComent VAR cComent14 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 545,298 MSGET oResp VAR cResp14 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 545,346 MSGET oData VAR dData14 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 15a pergunta
@ 585,144 COMBOBOX oCombo VAR cChoice15 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 585,168 GET oComent VAR cComent15 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 585,298 MSGET oResp VAR cResp15 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 585,346 MSGET oData VAR dData15 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 16a pergunta
@ 625,144 COMBOBOX oCombo VAR cChoice16 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 625,168 GET oComent VAR cComent16 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 625,298 MSGET oResp VAR cResp16 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 625,346 MSGET oData VAR dData16 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 17a pergunta
@ 665,144 COMBOBOX oCombo VAR cChoice17 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 665,168 GET oComent VAR cComent17 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 665,298 MSGET oResp VAR cResp17 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 665,346 MSGET oData VAR dData17 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 18a pergunta
@ 705,144 COMBOBOX oCombo VAR cChoice18 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 705,168 GET oComent VAR cComent18 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 705,298 MSGET oResp VAR cResp18 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 705,346 MSGET oData VAR dData18 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 19a pergunta
@ 745,144 COMBOBOX oCombo VAR cChoice19 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 745,168 GET oComent VAR cComent19 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 745,298 MSGET oResp VAR cResp19 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 745,346 MSGET oData VAR dData19 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 20a pergunta
@ 785,144 COMBOBOX oCombo VAR cChoice20 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 785,168 GET oComent VAR cComent20 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 785,298 MSGET oResp VAR cResp20 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 785,346 MSGET oData VAR dData20 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

QPP270S1ED(oScrollBox, oFont)   //Monta os "says" da Primeira Edição

If !Empty(M->QKS_CHAVE)
	cChave := M->QKS_CHAVE
Endif

If nOpc <> 3 .and. nOpc <> 4
	For nCont := 1 To Len(aObj)
		aObj[nCont,1]:lReadOnly := .T.
		aObj[nCont,2]:lReadOnly := .T.
		aObj[nCont,3]:lReadOnly := .T.
	Next x
Else
	For nCont := 1 To Len(aObj)
		aObj[nCont,4]:lReadOnly := .F.
	Next x
Endif

Return .T.                                  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP270S1ED ³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 13.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra os SAYS da funcao QPP270Tela                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP270S1ED(ExpO1, ExpO2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do Scrool                                   ³±±
±±³          ³ ExpO2 = Objeto da font                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA270                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Obs      ³ Funcao criada devido a erro de Memory Overbooked           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function QPP270S1ED(oScrollBox, oFont)  //--> Primeira Edição do APQP

// 1a pergunta

@ 015,003 SAY OemToAnsi(STR0015)SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"  O PROJETO DE FERRAMENTAS E EQUIPAMENTOS FOI"
@ 025,003 SAY OemToAnsi(STR0016)SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"  PREVISTO PARA :"
@ 035,003 SAY OemToAnsi("1 * "+STR0017)SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Sistema flexivel, por exemplo, celulas de manufatura ?"

@ 045,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 2a pergunta
@ 055,003 SAY OemToAnsi("2 * "+STR0018) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Troca rapida ?"

@ 085,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 3a pergunta
@ 095,003 SAY OemToAnsi("3 * "+STR0019) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Flutuacoes de volume ?"

@ 135,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 4a pergunta
@ 145,003 SAY OemToAnsi("4 * "+STR0020) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Prova de erros ?"

@ 175,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 5a pergunta
@ 185,003 SAY OemToAnsi(STR0021) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"  FORAM PREPARADAS LISTAS PARA IDENTIFICAR :"
@ 195,003 SAY OemToAnsi("5 * "+STR0022) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Novos equipamentos ?"

@ 215,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 6a pergunta
@ 225,003 SAY OemToAnsi("6 * "+STR0023) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Novas ferramentas ?"

@ 255,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 7a pergunta
@ 265,003 SAY OemToAnsi("7 * "+STR0024) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Novos equipamentos de testes ?"

@ 295,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 8a pergunta
@ 305,003 SAY OemToAnsi(STR0025) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"  HOUVE ACORDO SOBRE OS CRITERIOS DE ACEITACAO"
@ 315,003 SAY OemToAnsi(STR0026) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"  PARA :"
@ 325,003 SAY OemToAnsi("8 * "+STR0027) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Novos equipamentos ?"

@ 335,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 9a pergunta
@ 345,003 SAY OemToAnsi("9 * "+STR0028) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Novas ferrramentas ?"

@ 375,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 10a pergunta
@ 385,003 SAY OemToAnsi("10 * "+STR0029) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Novos equipamentos de testes ?"

@ 415,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 11a pergunta
@ 425,003 SAY OemToAnsi("11 - "+STR0030) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Sera conduzido um estudo preliminar de capabilidade no"
@ 435,003 SAY OemToAnsi(STR0031) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     fabricante de ferramentas e/ou equipamentos ?"

@ 455,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 12a pergunta
@ 465,003 SAY OemToAnsi("12 - "+STR0032) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram estabelecidas a viabilidade e precisao dos"
@ 475,003 SAY OemToAnsi(STR0033) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     equipamentos de testes ?"

@ 495,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 13a pergunta
@ 505,003 SAY OemToAnsi("13 - "+STR0034) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foi completado um plano de manutencao preventiva"
@ 515,003 SAY OemToAnsi(STR0035) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     para os equipamentos e ferramental ?"

@ 535,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 14a pergunta
@ 545,003 SAY OemToAnsi("14 - "+STR0036) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As instrucoes de instalacao/ajuste para os novos"
@ 555,003 SAY OemToAnsi(STR0037) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     equipamentos e ferramental estao completas e sao"
@ 565,003 SAY OemToAnsi(STR0038) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     compreensiveis ?"

@ 575,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 15a pergunta
@ 585,003 SAY OemToAnsi("15 - "+STR0039) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Estarao disponiveis dispositivos de medicao capazes"
@ 595,003 SAY OemToAnsi(STR0040) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     para se fazer estudos preliminares da capabilidade do"
@ 605,003 SAY OemToAnsi(STR0041) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     processo nas instalacoes do fornecedor do equipamento?"

@ 615,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 16a pergunta
@ 625,003 SAY OemToAnsi("16 - "+STR0042) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Os estudos preliminares de capabilidade do processo"
@ 635,003 SAY OemToAnsi(STR0043) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     serao efetuados na planta de producao ?"

@ 655,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 17a pergunta
@ 665,003 SAY OemToAnsi("17 - "+STR0044) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As caracteristicas de processo que afetam as"
@ 675,003 SAY OemToAnsi(STR0045) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     caracteristicas especiais do produto foram"
@ 685,003 SAY OemToAnsi(STR0046) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     identificadas ?"

@ 695,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 18a pergunta
@ 705,003 SAY OemToAnsi("18 - "+STR0047) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As caracteristicas especiais do produto foram usadas"
@ 715,003 SAY OemToAnsi(STR0048) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     para se determinar os criterios de aceitacao ?"

@ 735,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 19a pergunta
@ 745,003 SAY OemToAnsi("19 - "+STR0049) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"O equipamento de manufatura possui capacidade"
@ 755,003 SAY OemToAnsi(STR0050) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     suficiente para absorver os volumes estimados para"
@ 765,003 SAY OemToAnsi(STR0051) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     producao e servicos ?"

@ 775,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 20a pergunta
@ 785,003 SAY OemToAnsi("20 - "+STR0052) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"A capacidade de teste e suficiente para oferecer"
@ 795,003 SAY OemToAnsi(STR0053) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     testes adequados ?"

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QP270TED³ Autor ³ KLAUS DANIEL L C        ³ Data ³ 13.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para informacoes do ScrollBox (2ª Edição)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QP270TED(ExpN1, ExpO1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±³          ³ ExpO1 = Dialog       									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA270                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QP270TED(nOpc, oDlg)   //--> Segunda Edição do APQP

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
	QPP270CHEC()
Endif

@ 088,003 MSPANEL oPanel1 PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE 395,012 OF oDlg
@ 004,004 SAY OemToAnsi(STR0010)	COLOR CLR_WHITE SIZE 065,010 OF oPanel1 PIXEL  //"Item - Pergunta"
@ 004,135 SAY OemToAnsi(STR0011) 	COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL  //"Sim/Nao"
@ 004,155 SAY OemToAnsi("/"+STR0056) 	COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL  //"N/a"
@ 004,190 SAY OemToAnsi(STR0012)	COLOR CLR_WHITE SIZE 090,010 OF oPanel1 PIXEL  //"Comentarios/Acao Requerida"
@ 004,300 SAY OemToAnsi(STR0013)	COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL  //"Responsavel"
@ 004,347 SAY OemToAnsi(STR0014)	COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL  //"Dt. Prevista"

oScrollBox := TScrollBox():New(oDlg,103,03,125,395,.T.,.F.,.T.)

@ 001,002 TO 865,142 		OF oScrollBox PIXEL
@ 001,002 TO 865,167 		OF oScrollBox PIXEL
@ 001,002 TO 865,298 		OF oScrollBox PIXEL
@ 001,002 TO 865,345.5		OF oScrollBox PIXEL
@ 001,002 TO 865,385		OF oScrollBox PIXEL

// 1a pergunta
@ 015,144 COMBOBOX oCombo VAR cChoice01 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 015,168 GET oComent VAR cComent01 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 015,298 MSGET oResp VAR cResp01 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 015,346 MSGET oData VAR dData01 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 2a pergunta
@ 055,144 COMBOBOX oCombo VAR cChoice02 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 055,168 GET oComent VAR cComent02 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 055,298 MSGET oResp VAR cResp02 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 055,346 MSGET oData VAR dData02 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 3a pergunta
@ 095,144 COMBOBOX oCombo VAR cChoice03 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 095,168 GET oComent VAR cComent03 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 095,298 MSGET oResp VAR cResp03 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 095,346 MSGET oData VAR dData03 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 4a pergunta
@ 145,144 COMBOBOX oCombo VAR cChoice04 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 145,168 GET oComent VAR cComent04 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 145,298 MSGET oResp VAR cResp04 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 145,346 MSGET oData VAR dData04 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 5a pergunta
@ 185,144 COMBOBOX oCombo VAR cChoice05 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 185,168 GET oComent VAR cComent05 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 185,298 MSGET oResp VAR cResp05 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 185,346 MSGET oData VAR dData05 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 6a pergunta
@ 225,144 COMBOBOX oCombo VAR cChoice06 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 225,168 GET oComent VAR cComent06 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 225,298 MSGET oResp VAR cResp06 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 225,346 MSGET oData VAR dData06 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 7a pergunta
@ 265,144 COMBOBOX oCombo VAR cChoice07 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 265,168 GET oComent VAR cComent07 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 265,298 MSGET oResp VAR cResp07 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 265,346 MSGET oData VAR dData07 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 8a pergunta
@ 305,144 COMBOBOX oCombo VAR cChoice08 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 305,168 GET oComent VAR cComent08 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 305,298 MSGET oResp VAR cResp08 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 305,346 MSGET oData VAR dData08 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 9a pergunta
@ 345,144 COMBOBOX oCombo VAR cChoice09 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 345,168 GET oComent VAR cComent09 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 345,298 MSGET oResp VAR cResp09 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 345,346 MSGET oData VAR dData09 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 10a pergunta
@ 385,144 COMBOBOX oCombo VAR cChoice10 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 385,168 GET oComent VAR cComent10 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 385,298 MSGET oResp VAR cResp10 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 385,346 MSGET oData VAR dData10 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 11a pergunta
@ 425,144 COMBOBOX oCombo VAR cChoice11 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 425,168 GET oComent VAR cComent11 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 425,298 MSGET oResp VAR cResp11 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 425,346 MSGET oData VAR dData11 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 12a pergunta
@ 465,144 COMBOBOX oCombo VAR cChoice12 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 465,168 GET oComent VAR cComent12 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 465,298 MSGET oResp VAR cResp12 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 465,346 MSGET oData VAR dData12 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 13a pergunta
@ 505,144 COMBOBOX oCombo VAR cChoice13 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 505,168 GET oComent VAR cComent13 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 505,298 MSGET oResp VAR cResp13 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 505,346 MSGET oData VAR dData13 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 14a pergunta
@ 545,144 COMBOBOX oCombo VAR cChoice14 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 545,168 GET oComent VAR cComent14 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 545,298 MSGET oResp VAR cResp14 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 545,346 MSGET oData VAR dData14 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 15a pergunta
@ 585,144 COMBOBOX oCombo VAR cChoice15 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 585,168 GET oComent VAR cComent15 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 585,298 MSGET oResp VAR cResp15 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 585,346 MSGET oData VAR dData15 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 16a pergunta
@ 625,144 COMBOBOX oCombo VAR cChoice16 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 625,168 GET oComent VAR cComent16 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 625,298 MSGET oResp VAR cResp16 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 625,346 MSGET oData VAR dData16 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 17a pergunta
@ 665,144 COMBOBOX oCombo VAR cChoice17 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 665,168 GET oComent VAR cComent17 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 665,298 MSGET oResp VAR cResp17 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 665,346 MSGET oData VAR dData17 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 18a pergunta
@ 705,144 COMBOBOX oCombo VAR cChoice18 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 705,168 GET oComent VAR cComent18 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 705,298 MSGET oResp VAR cResp18 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 705,346 MSGET oData VAR dData18 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 19a pergunta
@ 745,144 COMBOBOX oCombo VAR cChoice19 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 745,168 GET oComent VAR cComent19 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 745,298 MSGET oResp VAR cResp19 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 745,346 MSGET oData VAR dData19 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 20a pergunta
@ 785,144 COMBOBOX oCombo VAR cChoice20 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 785,168 GET oComent VAR cComent20 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 785,298 MSGET oResp VAR cResp20 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 785,346 MSGET oData VAR dData20 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 21a pergunta
@ 825,144 COMBOBOX oCombo VAR cChoice21 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 825,168 GET oComent VAR cComent21 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 825,298 MSGET oResp VAR cResp21 PICTURE PesqPict("QKS","QKS_RESP") ;
						ReadOnly F3 ConSX3("QKS_RESP") VALID CheckSx3("QKS_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 825,346 MSGET oData VAR dData21 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})



QPP270S2ED(oScrollBox, oFont)   //Monta os "says" da Segunda Edição

If !Empty(M->QKS_CHAVE)
	cChave := M->QKS_CHAVE
Endif

If nOpc <> 3 .and. nOpc <> 4
	For nCont := 1 To Len(aObj)
		aObj[nCont,1]:lReadOnly := .T.
		aObj[nCont,2]:lReadOnly := .T.
		aObj[nCont,3]:lReadOnly := .T.
	Next x
Else
	For nCont := 1 To Len(aObj)
		aObj[nCont,4]:lReadOnly := .F.
	Next x
Endif

Return .T.                                  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP270S2ED ³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 13.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra os SAYS da funcao QPP270Tela                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP270S2ED(ExpO1, ExpO2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do Scrool                                   ³±±
±±³          ³ ExpO2 = Objeto da font                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA270                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Obs      ³ Funcao criada devido a erro de Memory Overbooked           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function QPP270S2ED(oScrollBox, oFont)  //-->Segunda  Edição do APQP

// 1a pergunta

@ 015,003 SAY OemToAnsi(STR0069)SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"O Projeto requer: "
@ 025,003 SAY OemToAnsi("1 * "+STR0057)SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //" Novos materiais?"

@ 045,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 2a pergunta
@ 055,003 SAY OemToAnsi("2 * "+STR0018) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Troca rapida ?"

@ 085,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 3a pergunta
@ 095,003 SAY OemToAnsi("3 * "+STR0019) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Flutuacoes de volume ?"

@ 135,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 4a pergunta
@ 145,003 SAY OemToAnsi("4 * "+STR0020) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Prova de erros ?"

@ 175,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 5a pergunta
@ 185,003 SAY OemToAnsi(STR0070) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram preparadas listas para identificar: (inclui"
@ 195,003 SAY OemToAnsi(STR0071) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"todos os fornecedores) "
@ 205,003 SAY OemToAnsi("5 * "+STR0022) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Novos equipamentos ?"

@ 215,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 6a pergunta
@ 225,003 SAY OemToAnsi("6 * "+STR0023) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //" Novas ferramentas ?"

@ 255,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 7a pergunta
@ 265,003 SAY OemToAnsi("7 * "+STR0024) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Novos equipamentos de testes ?"
@ 275,003 SAY OemToAnsi(STR0072) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"(Incluindo recursos para verificação)

@ 295,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 8a pergunta
@ 305,003 SAY OemToAnsi(STR0073) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Houve acordo sobre os critérios de aceitação para:"
@ 315,003 SAY OemToAnsi(STR0074) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"(Inclui todos Fornecedores)"
@ 325,003 SAY OemToAnsi("8 * "+STR0027) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Novos equipamentos ?"

@ 335,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 9a pergunta
@ 345,003 SAY OemToAnsi("9 * "+STR0028) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Novas ferrramentas ?"

@ 375,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 10a pergunta
@ 385,003 SAY OemToAnsi("10 * "+STR0029) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Novos equipamentos de testes ?"
@ 395,003 SAY OemToAnsi(STR0072) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"(Incluindo recursos para verificação)

@ 415,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 11a pergunta
@ 425,003 SAY OemToAnsi("11 - "+STR0030) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Sera conduzido um estudo preliminar de capabilidade no"
@ 435,003 SAY OemToAnsi(STR0031) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     fabricante de ferramentas e/ou equipamentos ?"

@ 455,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 12a pergunta
@ 465,003 SAY OemToAnsi("12 - "+STR0032) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram estabelecidas a viabilidade e precisao dos"
@ 475,003 SAY OemToAnsi(STR0033) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     equipamentos de testes ?"

@ 495,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 13a pergunta
@ 505,003 SAY OemToAnsi("13 - "+STR0034) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foi completado um plano de manutencao preventiva"
@ 515,003 SAY OemToAnsi(STR0035) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     para os equipamentos e ferramental ?"

@ 535,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 14a pergunta
@ 545,003 SAY OemToAnsi("14 - "+STR0036) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As instrucoes de instalacao/ajuste para os novos"
@ 555,003 SAY OemToAnsi(STR0037) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     equipamentos e ferramental estao completas e sao"
@ 565,003 SAY OemToAnsi(STR0038) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     compreensiveis ?"

@ 575,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 15a pergunta
@ 585,003 SAY OemToAnsi("15 - "+STR0039) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Estarao disponiveis dispositivos de medicao capazes"
@ 595,003 SAY OemToAnsi(STR0040) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     para se fazer estudos preliminares da capabilidade do"
@ 605,003 SAY OemToAnsi(STR0041) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     processo nas instalacoes do fornecedor do equipamento?"

@ 615,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 16a pergunta
@ 625,003 SAY OemToAnsi("16 - "+STR0042) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Os estudos preliminares de capabilidade do processo"
@ 635,003 SAY OemToAnsi(STR0075) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     serao efetuados na planta de producao ?"

@ 655,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 17a pergunta
@ 665,003 SAY OemToAnsi("17 - "+STR0044) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As caracteristicas de processo que afetam as"
@ 675,003 SAY OemToAnsi(STR0045) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     caracteristicas especiais do produto foram"
@ 685,003 SAY OemToAnsi(STR0046) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     identificadas ?"

@ 695,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 18a pergunta
@ 705,003 SAY OemToAnsi("18 - "+STR0047) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"As caracteristicas especiais do produto foram usadas"
@ 715,003 SAY OemToAnsi(STR0048) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     para se determinar os criterios de aceitacao ?"

@ 735,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 19a pergunta
@ 745,003 SAY OemToAnsi("19 - "+STR0049) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"O equipamento de manufatura possui capacidade"
@ 755,003 SAY OemToAnsi(STR0050) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     suficiente para absorver os volumes estimados para"
@ 765,003 SAY OemToAnsi(STR0051) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     producao e servicos ?"

@ 775,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 20a pergunta
@ 785,003 SAY OemToAnsi("20 - "+STR0052) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"A capacidade de teste e suficiente para oferecer"
@ 795,003 SAY OemToAnsi(STR0053) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     testes adequados ?"

@ 815,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL


// 21a pergunta
@ 825,003 SAY OemToAnsi("21 - "+STR0060) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"O Equipamento de medição foi verificado e"
@ 835,003 SAY OemToAnsi(STR0061) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"documentado estando qualificado para a "
@ 845,003 SAY OemToAnsi(STR0062) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"abrangência necessaria da medições e testes?"

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP270Chec³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 13.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza conteudo das Variaveis                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP270Chec()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA270                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP270Chec()

Local nTamLin 	:= 38 // Tamanho da linha do texto
Local cEspecie 	:= "PPA270"
Local nSeq
Local aArea		:= {}

aArea := GetArea()

DbSelectArea("QKS")
DbSetOrder(1)
DbSeek(xFilial("QKS")+M->QKS_PECA+M->QKS_REV+"01")

Do While xFilial("QKS")+M->QKS_PECA+M->QKS_REV == QKS->QKS_FILIAL+QKS->QKS_PECA+QKS->QKS_REV ;
			.and. !Eof()
	
	nSeq := QKS->QKS_NPERG
	
	cChoice&(nSeq)	:= Iif(QKS_RPOSTA == "1", aItems[1],(Iif(QKS_RPOSTA == "2", aItems[2],aItems[3])))
	dData&(nSeq)	:= QKS->QKS_DTPREV
	cResp&(nSeq)	:= QKS->QKS_RESP

	If !Empty(QKS->QKS_CHAVE)
		cComent&(nSeq) := QO_Rectxt(M->QKS_CHAVE,cEspecie+nSeq,1, nTamLin,"QKO")
	Endif
		
	DbSelectArea("QKS")
	DbSkip()

Enddo

RestArea(aArea)

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA270Grav³ Autor ³ Robson Ramiro A Olivei³ Data ³ 13.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Gravacao Checklist APQP - A3 (Incl./Alter.)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA270Grav(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA270                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA270Grav(nOpc)

Local nCont, nRec
Local bCampo	:= { |nCPO| Field(nCPO) }
Local lGraOk	:= .T.
Local nTamLin	:= 38
Local cEspecie	:= "PPA270"
Local nSeq
Local nSaveSX8	:= GetSX8Len()
Local lMVQAPQPED := GetMV("MV_QAPQPED",.T.,"1") == "1"
DbSelectArea("QKS")
	
Begin Transaction

// Verifica se existe texto antes de criar chave
If Empty(cChave)
	cChave := GetSXENum("QKS", "QKS_CHAVE",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

Endif

DbSelectArea("QKS")
DbSetOrder(1)

For nRec := 1 To Iif(lMVQAPQPED,20,21)// 20 ou 21  perguntas
	
	nSeq := StrZero(nRec,2)

	If ALTERA
		If DbSeek(xFilial("QKS")+M->QKS_PECA+M->QKS_REV+nSeq)
			RecLock("QKS",.F.)
		Else
			RecLock("QKS",.T.)
		Endif
	Else
		RecLock("QKS",.T.)
	Endif

	For nCont := 1 To FCount()
		If "FILIAL"$Field(nCont)
			FieldPut(nCont,xFilial("QKS"))
		Else
			FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
		Endif
	Next nCont

	QKS->QKS_REVINV	:= Inverte(M->QKS_REV)
	QKS->QKS_NPERG	:= nSeq
	QKS->QKS_RPOSTA	:= Iif(cChoice&(nSeq) == STR0007,"1",Iif(cChoice&(nSeq) == STR0008,"2", "3") ) //"Sim"###"NAO"###"N/A"    
	QKS->QKS_DTPREV	:= &("dData"+Padr(nSeq,2))
	QKS->QKS_RESP	:= &("cResp"+Padr(nSeq,2))
	QKS->QKS_FILRES	:= cFilAnt
	QKS->QKS_CHAVE	:= cChave

	If !Empty(cComent&(nSeq))
		aComent&(nSeq) := GeraText(nTamLin, cComent&(nSeq))
		QO_GrvTxt(cChave,cEspecie+nSeq,1,@aComent&(nSeq))
	Endif
	
	DbSelectArea("QKS")

Next nRec
	
MsUnLock()

End Transaction

			
Return lGraOk

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PP270TudOk ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 13.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para inclusao/alteracao geral                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP270TudOk                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QPPA270                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PP270TudOk

Local lRetorno	:= .T.

If Empty(M->QKS_PECA) .or. Empty(M->QKS_REV)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
Endif

If INCLUI
	If !ExistChav("QKS",M->QKS_PECA+M->QKS_REV)
		lRetorno := .F.
		Help(" ",1,"JAGRAVADO")  // Campo ja Existe
	Endif
	If !ExistCpo("QK1",M->QKS_PECA+M->QKS_REV)
		lRetorno := .F.
		Help(" ",1,"REGNOIS")  // Nao existe amarracao
	Endif
Endif

Return lRetorno


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A270Dele ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 13.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fucao para exclusao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A270Dele()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA270                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A270Dele()

Local cEspecie := "PPA270"
Local nSeq, nRec, cKey
Local aArqRec := {}
Local lMVQAPQPED := GetMV("MV_QAPQPED",.T.,"1") == "1"

DbSelectArea("QKS")
DbSeek(xFilial("QKS")+M->QKS_PECA+M->QKS_REV+"01")

cKey := QKS->QKS_CHAVE

Do While xFilial("QKS")+M->QKS_PECA+M->QKS_REV == QKS->QKS_FILIAL+QKS->QKS_PECA+QKS->QKS_REV ;
			.and. !Eof()

	aAdd(aArqRec, Recno())  //alimenta array com os enderecos a serem deletados
	DbSkip()
Enddo

Begin Transaction

If Len(aArqRec) > 0

	For nRec := 1 To Iif(lMVQAPQPED,20,21) // 20 ou 21 perguntas, Depende da VErsão do APQP, Ver PArametro MV_QAPQPED

		nSeq := StrZero(nRec,2)

		If !Empty(cKey)
			QO_DelTxt(cKey,cEspecie+nSeq) //QPPXFUN
		Endif
	 
		DbSelectArea("QKS")
		DbGoTo(aArqRec[nRec])
		RecLock("QKS",.F.)
		DbDelete()

	Next nRec

Endif

MsUnLock()
		
End Transaction

Return