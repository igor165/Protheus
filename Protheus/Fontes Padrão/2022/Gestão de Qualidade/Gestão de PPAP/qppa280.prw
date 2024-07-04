#INCLUDE "QPPA280.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA280  ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 14.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Checklist APQP - A4 QUALIDADE DO PRODUTO/PROCESSO          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA280(void)                                              ³±±
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

Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui"  	, 	0, 1,,.F.},; //"Pesquisar"
					{ OemToAnsi(STR0002), "PPA280Roti"	, 	0, 2},; 	  //"Visualizar"
					{ OemToAnsi(STR0003), "PPA280Roti"	, 	0, 3},;	 	  //"Incluir"
					{ OemToAnsi(STR0004), "PPA280Roti"	, 	0, 4},;		  //"Alterar"
					{ OemToAnsi(STR0005), "PPA280Roti", 	0, 5},; 	  //"Excluir"
					{ OemToAnsi(STR0104), "QPPR280(.T.)",	0, 6,,.T.} } //"Imprimir"

Return aRotina

Function QPPA280()

Private cFiltro
						
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0006) //"Checklist APQP - A4 QUALIDADE DO PRODUTO/PROCESSO"

Private aRotina := MenuDef()

DbSelectArea("QKT")
DbSetOrder(1)

cFiltro := 'QKT_NPERG == "01"'

Set Filter To &cFiltro
mBrowse( 6, 1, 22, 75,"QKT",,,,,,)
Set Filter To


Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
?????????????????????????????????????????????????????????????????????????????
??ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ???
??ºPrograma  ?QPPA280CE   ºAutor  ?Klaus Daniel L.C   º Data ?  09/28/09   º??
??ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ???
??ºDesc.     ?Função que verifica com qual Edição foi feio a A3            ??
??º          ?                                                    º??
??ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ???
??ºUso       ? QPPA280, QPPR280                                            º??
??ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ???
?????????????????????????????????????????????????????????????????????????????
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
  
//Consistencia para verificar se na base de dados a Lista  (A3) foi realizada
//na primeira ou na segunda edicao do APQP, 


Function QPPA280CE()

Local nCont      :=0
Local cPecaR     :=""
Local aArea		 := {}


cPecaR 	:= (QKT->QKT_FILIAL+QKT->QKT_PECA+QKT->QKT_REV)

aArea := GetArea()                                         

DbSelectArea("QKT")
Set Filter To
DbSetOrder(1)
DbGoTop()
DbSeek(cPecaR+"01")   


Do while !Eof().and. QKT->QKT_FILIAL+QKT->QKT_PECA+QKT->QKT_REV == cPecaR
	nCont++
	Dbskip()  
	
Enddo
RestArea(aArea)


Return nCont



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA280Roti  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³14.08.02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Manutencao dos Dados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA280Roti(ExpC1,ExpN1,ExpN2)                           ³±±
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

Function PPA280Roti(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local lOk 			:= .F.
Local aCposVis		:= {}
Local aCposAlt		:= {}
Local aButtons		:= {}
Local nNresp        := 0 
Local lPriED280     := GetMV("MV_QAPQPED",.T.,"1") == '1' // Define se o APQP deve ser feito na primeira ou segunda edição 1 - Primeira Edição 2 - Segunda Edição
Local cTitulo       := ""
Private cChave		:= ""
Private aItems      := {}


nNresp := QPPA280CE()  //Verifica pelo numEro de NResp em qual modelo foi feio o APQP

If (nNresp == 59 .and. lPriED280)  .and. nOpc <> 3
Set filter to &cFiltro
	AVISO(STR0122,STR0123+STR0124+STR0125,{"Ok"},3,"MV_QAPQPED")	
	Return Nil

EndIf

If (nNresp == 53  .and. !lPriED280) .and. nOpc <> 3
Set filter to &cFiltro
	AVISO(STR0122,STR0123+STR0124+STR0125,{"Ok"},3,"MV_QAPQPED")		
	Return Nil

EndIF
 
If lPriED280
	 aItems 		:= {STR0007,STR0008} //"Sim"###"Nao"
Else
	 aItems 		:= {STR0007,STR0008,STR0106} //"Sim"###"Nao"###"N/a"
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
Private cComent45, cComent46, cComent47, cComent48
Private cComent49, cComent50, cComent51, cComent52
Private cComent53, cComent54, cComent55, cComent56
Private  cComent57, cComent58, cComent59

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
Private cChoice45 	:= cChoice46 := cChoice47 := cChoice48 	:= aItems[1]
Private cChoice49 	:= cChoice50 := cChoice51 := cChoice52 	:= aItems[1]
Private cChoice53 	:= cChoice54 := cChoice55 := cChoice56 	:= aItems[1]
Private cChoice57 	:= cChoice58 := cChoice59  	:= aItems[1]



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
Private cResp45 	:= cResp46 := cResp47 := cResp48			:= Space(10)
Private cResp49 	:= cResp50 := cResp51 := cResp52			:= Space(10)
Private cResp53 	:= cResp54 := cResp55 := cResp56			:= Space(10)
Private cResp57 	:= cResp58 := cResp59 	:= Space(10)


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
Private dData45 	:= dData46 := dData47 := dData48 			:= dDataBase
Private dData49 	:= dData50 := dData51 := dData52 			:= dDataBase
Private dData53 	:= dData54 := dData55 := dData56 			:= dDataBase
Private dData57 	:= dData58 := dData59 		:= dDataBase


aCposVis := { "QKT_PECA", "QKT_REV", "QKT_DTREVI",	"QKT_RESPOR", "QKT_PREPOR" }

aCposAlt := { "QKT_DTREVI", "QKT_RESPOR", "QKT_PREPOR" }
				
If nOpc == 2 
	aButtons := {{"BMPVISUAL",	{ || QPPR280() }, OemToAnsi(STR0009), OemToAnsi(STR0105) }} //"Visualizar/Imprimir"###"Vis/Prn"
Endif

If nOpc == 4
	If !QPPVldAlt(QKT->QKT_PECA,QKT->QKT_REV)
		Return
	Endif
Endif

DbSelectArea(cAlias)

Set Filter To

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lPriED280  //Monta o titulo de acordo com o Parametro MV_QAPQPED
	cTitulo := STR0006
Else
	cTitulo := STR0006+STR0126
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitulo) ; //"Checklist APQP - A4 QUALIDADE DO PRODUTO/PROCESSO"
						FROM 120,000 TO 580,795 OF oMainWnd PIXEL
						
RegToMemory("QKT",(nOpc == 3))

Enchoice("QKT",nReg,nOpc, , , ,aCposVis ,{30,03,85,395}, , , , ,)

If GetMV("MV_QAPQPED",.F.,"1") == '1'
	QP280TEL(nOpc, oDlg)
Else
	QP280TED(nOpc, oDlg)
Endif
                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP280TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, ,aButtons ) CENTERED

If lOk .and. (nOpc == 3 .or. nOpc == 4)
	PPA280Grav(nOpc)
Endif

If nOpc == 5 .and. lOk
	A280Dele()
Endif

Set Filter To &cFiltro

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QP280TEL³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 14.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para informacoes do ScrollBox                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QP280TEL(ExpN1, ExpO1) Primeira Edição                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±³          ³ ExpO1 = Dialog       									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA280                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QP280TEL(nOpc, oDlg)

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
	QPP280CHEC()
Endif

@ 088,003 MSPANEL oPanel1 PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE 395,012 OF oDlg
@ 004,004 SAY OemToAnsi(STR0010)	COLOR CLR_WHITE SIZE 065,010 OF oPanel1 PIXEL  //"Item - Pergunta"
@ 004,150 SAY OemToAnsi(STR0011) 	COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL  //"Sim/Nao"
@ 004,190 SAY OemToAnsi(STR0012)	COLOR CLR_WHITE SIZE 090,010 OF oPanel1 PIXEL  //"Comentarios/Acao Requerida"
@ 004,300 SAY OemToAnsi(STR0013)	COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL  //"Responsavel"
@ 004,347 SAY OemToAnsi(STR0014)	COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL  //"Dt. Prevista"

oScrollBox := TScrollBox():New(oDlg,103,03,125,395,.T.,.F.,.T.)

@ 001,002 TO 2145,142 		OF oScrollBox PIXEL
@ 001,002 TO 2145,167 		OF oScrollBox PIXEL
@ 001,002 TO 2145,298 		OF oScrollBox PIXEL
@ 001,002 TO 2145,345.5	    OF oScrollBox PIXEL
@ 001,002 TO 2145,385		OF oScrollBox PIXEL

// 1a pergunta
@ 015,144 COMBOBOX oCombo VAR cChoice01 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 015,168 GET oComent VAR cComent01 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 015,298 MSGET oResp VAR cResp01 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 015,346 MSGET oData VAR dData01 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 2a pergunta
@ 055,144 COMBOBOX oCombo VAR cChoice02 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 055,168 GET oComent VAR cComent02 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 055,298 MSGET oResp VAR cResp02 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 055,346 MSGET oData VAR dData02 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 3a pergunta
@ 095,144 COMBOBOX oCombo VAR cChoice03 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 095,168 GET oComent VAR cComent03 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 095,298 MSGET oResp VAR cResp03 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 095,346 MSGET oData VAR dData03 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 4a pergunta
@ 145,144 COMBOBOX oCombo VAR cChoice04 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 145,168 GET oComent VAR cComent04 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 145,298 MSGET oResp VAR cResp04 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 145,346 MSGET oData VAR dData04 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 5a pergunta
@ 185,144 COMBOBOX oCombo VAR cChoice05 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 185,168 GET oComent VAR cComent05 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 185,298 MSGET oResp VAR cResp05 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 185,346 MSGET oData VAR dData05 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 6a pergunta
@ 225,144 COMBOBOX oCombo VAR cChoice06 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 225,168 GET oComent VAR cComent06 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 225,298 MSGET oResp VAR cResp06 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 225,346 MSGET oData VAR dData06 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 7a pergunta
@ 265,144 COMBOBOX oCombo VAR cChoice07 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 265,168 GET oComent VAR cComent07 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 265,298 MSGET oResp VAR cResp07 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 265,346 MSGET oData VAR dData07 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 8a pergunta
@ 305,144 COMBOBOX oCombo VAR cChoice08 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 305,168 GET oComent VAR cComent08 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 305,298 MSGET oResp VAR cResp08 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 305,346 MSGET oData VAR dData08 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 9a pergunta
@ 345,144 COMBOBOX oCombo VAR cChoice09 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 345,168 GET oComent VAR cComent09 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 345,298 MSGET oResp VAR cResp09 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 345,346 MSGET oData VAR dData09 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 10a pergunta
@ 385,144 COMBOBOX oCombo VAR cChoice10 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 385,168 GET oComent VAR cComent10 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 385,298 MSGET oResp VAR cResp10 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 385,346 MSGET oData VAR dData10 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 11a pergunta
@ 425,144 COMBOBOX oCombo VAR cChoice11 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 425,168 GET oComent VAR cComent11 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 425,298 MSGET oResp VAR cResp11 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 425,346 MSGET oData VAR dData11 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 12a pergunta
@ 465,144 COMBOBOX oCombo VAR cChoice12 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 465,168 GET oComent VAR cComent12 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 465,298 MSGET oResp VAR cResp12 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 465,346 MSGET oData VAR dData12 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 13a pergunta
@ 505,144 COMBOBOX oCombo VAR cChoice13 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 505,168 GET oComent VAR cComent13 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 505,298 MSGET oResp VAR cResp13 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 505,346 MSGET oData VAR dData13 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 14a pergunta
@ 545,144 COMBOBOX oCombo VAR cChoice14 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 545,168 GET oComent VAR cComent14 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 545,298 MSGET oResp VAR cResp14 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 545,346 MSGET oData VAR dData14 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 15a pergunta
@ 585,144 COMBOBOX oCombo VAR cChoice15 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 585,168 GET oComent VAR cComent15 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 585,298 MSGET oResp VAR cResp15 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 585,346 MSGET oData VAR dData15 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 16a pergunta
@ 625,144 COMBOBOX oCombo VAR cChoice16 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 625,168 GET oComent VAR cComent16 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 625,298 MSGET oResp VAR cResp16 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 625,346 MSGET oData VAR dData16 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 17a pergunta
@ 665,144 COMBOBOX oCombo VAR cChoice17 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 665,168 GET oComent VAR cComent17 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 665,298 MSGET oResp VAR cResp17 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 665,346 MSGET oData VAR dData17 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 18a pergunta
@ 705,144 COMBOBOX oCombo VAR cChoice18 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 705,168 GET oComent VAR cComent18 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 705,298 MSGET oResp VAR cResp18 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 705,346 MSGET oData VAR dData18 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 19a pergunta
@ 745,144 COMBOBOX oCombo VAR cChoice19 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 745,168 GET oComent VAR cComent19 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 745,298 MSGET oResp VAR cResp19 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 745,346 MSGET oData VAR dData19 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 20a pergunta
@ 785,144 COMBOBOX oCombo VAR cChoice20 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 785,168 GET oComent VAR cComent20 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 785,298 MSGET oResp VAR cResp20 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 785,346 MSGET oData VAR dData20 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 21a pergunta
@ 825,144 COMBOBOX oCombo VAR cChoice21 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 825,168 GET oComent VAR cComent21 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 825,298 MSGET oResp VAR cResp21 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 825,346 MSGET oData VAR dData21 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 22a pergunta
@ 865,144 COMBOBOX oCombo VAR cChoice22 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 865,168 GET oComent VAR cComent22 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 865,298 MSGET oResp VAR cResp22 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 865,346 MSGET oData VAR dData22 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 23a pergunta
@ 905,144 COMBOBOX oCombo VAR cChoice23 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 905,168 GET oComent VAR cComent23 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 905,298 MSGET oResp VAR cResp23 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 905,346 MSGET oData VAR dData23 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 24a pergunta
@ 945,144 COMBOBOX oCombo VAR cChoice24 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 945,168 GET oComent VAR cComent24 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 945,298 MSGET oResp VAR cResp24 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 945,346 MSGET oData VAR dData24 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 25a pergunta
@ 985,144 COMBOBOX oCombo VAR cChoice25 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 985,168 GET oComent VAR cComent25 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 985,298 MSGET oResp VAR cResp25 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 985,346 MSGET oData VAR dData25 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 26a pergunta
@ 1025,144 COMBOBOX oCombo VAR cChoice26 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1025,168 GET oComent VAR cComent26 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1025,298 MSGET oResp VAR cResp26 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1025,346 MSGET oData VAR dData26 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 27a pergunta
@ 1065,144 COMBOBOX oCombo VAR cChoice27 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1065,168 GET oComent VAR cComent27 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1065,298 MSGET oResp VAR cResp27 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1065,346 MSGET oData VAR dData27 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 28a pergunta
@ 1105,144 COMBOBOX oCombo VAR cChoice28 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1105,168 GET oComent VAR cComent28 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1105,298 MSGET oResp VAR cResp28 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1105,346 MSGET oData VAR dData28 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 29a pergunta
@ 1145,144 COMBOBOX oCombo VAR cChoice29 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1145,168 GET oComent VAR cComent29 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1145,298 MSGET oResp VAR cResp29 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1145,346 MSGET oData VAR dData29 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 30a pergunta
@ 1185,144 COMBOBOX oCombo VAR cChoice30 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1185,168 GET oComent VAR cComent30 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1185,298 MSGET oResp VAR cResp30 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1185,346 MSGET oData VAR dData30 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 31a pergunta
@ 1225,144 COMBOBOX oCombo VAR cChoice31 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1225,168 GET oComent VAR cComent31 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1225,298 MSGET oResp VAR cResp31 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1225,346 MSGET oData VAR dData31 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 32a pergunta
@ 1265,144 COMBOBOX oCombo VAR cChoice32 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1265,168 GET oComent VAR cComent32 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1265,298 MSGET oResp VAR cResp32 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1265,346 MSGET oData VAR dData32 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 33a pergunta
@ 1305,144 COMBOBOX oCombo VAR cChoice33 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1305,168 GET oComent VAR cComent33 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1305,298 MSGET oResp VAR cResp33 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1305,346 MSGET oData VAR dData33 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 34a pergunta
@ 1345,144 COMBOBOX oCombo VAR cChoice34 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1345,168 GET oComent VAR cComent34 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1345,298 MSGET oResp VAR cResp34 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1345,346 MSGET oData VAR dData34 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 35a pergunta
@ 1385,144 COMBOBOX oCombo VAR cChoice35 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1385,168 GET oComent VAR cComent35 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1385,298 MSGET oResp VAR cResp35 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1385,346 MSGET oData VAR dData35 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})
                                             

// 36a pergunta
@ 1425,144 COMBOBOX oCombo VAR cChoice36 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1425,168 GET oComent VAR cComent36 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1425,298 MSGET oResp VAR cResp36 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1425,346 MSGET oData VAR dData36 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 37a pergunta
@ 1465,144 COMBOBOX oCombo VAR cChoice37 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1465,168 GET oComent VAR cComent37 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1465,298 MSGET oResp VAR cResp37 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1465,346 MSGET oData VAR dData37 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 38a pergunta
@ 1505,144 COMBOBOX oCombo VAR cChoice38 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1505,168 GET oComent VAR cComent38 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1505,298 MSGET oResp VAR cResp38 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1505,346 MSGET oData VAR dData38 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 39a pergunta
@ 1545,144 COMBOBOX oCombo VAR cChoice39 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1545,168 GET oComent VAR cComent39 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1545,298 MSGET oResp VAR cResp39 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1545,346 MSGET oData VAR dData39 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 40a pergunta
@ 1585,144 COMBOBOX oCombo VAR cChoice40 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1585,168 GET oComent VAR cComent40 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1585,298 MSGET oResp VAR cResp40 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1585,346 MSGET oData VAR dData40 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 41a pergunta
@ 1625,144 COMBOBOX oCombo VAR cChoice41 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1625,168 GET oComent VAR cComent41 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1625,298 MSGET oResp VAR cResp41 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1625,346 MSGET oData VAR dData41 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 42a pergunta
@ 1665,144 COMBOBOX oCombo VAR cChoice42 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1665,168 GET oComent VAR cComent42 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1665,298 MSGET oResp VAR cResp42 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1665,346 MSGET oData VAR dData42 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 43a pergunta
@ 1705,144 COMBOBOX oCombo VAR cChoice43 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1705,168 GET oComent VAR cComent43 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1705,298 MSGET oResp VAR cResp43 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1705,346 MSGET oData VAR dData43 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 44a pergunta
@ 1745,144 COMBOBOX oCombo VAR cChoice44 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1745,168 GET oComent VAR cComent44 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1745,298 MSGET oResp VAR cResp44 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1745,346 MSGET oData VAR dData44 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 45a pergunta
@ 1785,144 COMBOBOX oCombo VAR cChoice45 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1785,168 GET oComent VAR cComent45 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1785,298 MSGET oResp VAR cResp45 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1785,346 MSGET oData VAR dData45 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 46a pergunta
@ 1825,144 COMBOBOX oCombo VAR cChoice46 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1825,168 GET oComent VAR cComent46 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1825,298 MSGET oResp VAR cResp46 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1825,346 MSGET oData VAR dData46 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 47a pergunta
@ 1865,144 COMBOBOX oCombo VAR cChoice47 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1865,168 GET oComent VAR cComent47 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1865,298 MSGET oResp VAR cResp47 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1865,346 MSGET oData VAR dData47 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 48a pergunta
@ 1905,144 COMBOBOX oCombo VAR cChoice48 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1905,168 GET oComent VAR cComent48 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1905,298 MSGET oResp VAR cResp48 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1905,346 MSGET oData VAR dData48 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 49a pergunta
@ 1945,144 COMBOBOX oCombo VAR cChoice49 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1945,168 GET oComent VAR cComent49 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1945,298 MSGET oResp VAR cResp49 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1945,346 MSGET oData VAR dData49 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 50a pergunta
@ 1985,144 COMBOBOX oCombo VAR cChoice50 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1985,168 GET oComent VAR cComent50 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1985,298 MSGET oResp VAR cResp50 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1985,346 MSGET oData VAR dData50 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 51a pergunta
@ 2025,144 COMBOBOX oCombo VAR cChoice51 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 2025,168 GET oComent VAR cComent51 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 2025,298 MSGET oResp VAR cResp51 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 2025,346 MSGET oData VAR dData51 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 52a pergunta
@ 2065,144 COMBOBOX oCombo VAR cChoice52 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 2065,168 GET oComent VAR cComent52 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 2065,298 MSGET oResp VAR cResp52 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 2065,346 MSGET oData VAR dData52 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 53a pergunta
@ 2105,144 COMBOBOX oCombo VAR cChoice53 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 2105,168 GET oComent VAR cComent53 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 2105,298 MSGET oResp VAR cResp53 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 2105,346 MSGET oData VAR dData53 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


Q280S1ED(oScrollBox, oFont)   //Montas as Pèrguntas da Rotina da Primeira Edição

If !Empty(M->QKT_CHAVE)
	cChave := M->QKT_CHAVE
Endif

If nOpc <> 3 .and. nOpc <> 4
	For nCont := 1 To Len(aObj)
		aObj[nCont,1]:lReadOnly := .T.
		aObj[nCont,2]:lReadOnly := .T.
		aObj[nCont,3]:lReadOnly := .T.
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
±±³Funcao    ³Q280S1ED ³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 14.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra os SAYS da funcao QPP280Tela                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q280S1ED(ExpO1, ExpO2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do Scrool                                   ³±±
±±³          ³ ExpO2 = Objeto da font                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA280                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Obs      ³ Funcao criada devido a erro de Memory Overbooked           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Q280S1ED(oScrollBox, oFont)

// 1a pergunta

@ 015,003 SAY OemToAnsi("1 - "+STR0015) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  	//"E necessaria a assistencia da qualidade assegurado do"
@ 025,003 SAY OemToAnsi(STR0016) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  	//"    cliente ou atividade da engenharia do produto para"
@ 035,003 SAY OemToAnsi(STR0017) SIZE 150,010 OF oScrollBox PIXEL FONT oFont 	//"    desenvolver ou aprovar o plano de controle ?"

@ 045,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 2a pergunta
@ 055,003 SAY OemToAnsi("2 - "+STR0018) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"O fornecedor identificou quem sera o contato da"
@ 065,003 SAY OemToAnsi(STR0019) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"    qualidade com o cliente ?"

@ 085,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 3a pergunta
@ 095,003 SAY OemToAnsi("3 - "+STR0020) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"O fornecedor indentificou quem sera o contato da"
@ 105,003 SAY OemToAnsi(STR0021) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"    qualidade com seus fornecedores ?"

@ 135,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 4a pergunta
@ 145,003 SAY OemToAnsi("4 - "+STR0022) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"O sistema da qualidade foi analisado criticamente"
@ 155,003 SAY OemToAnsi(STR0023) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"    atraves da utilizacao do manual de Avaliacao do Sistema"
@ 165,003 SAY OemToAnsi(STR0024) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"    da Qualidade da Chrysler, Ford e General Motors ?"

@ 175,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 5a pergunta
@ 185,003 SAY OemToAnsi(STR0025) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"  Existe pessoal suficiente identificado para cobrir :"
@ 195,003 SAY OemToAnsi("5 * "+STR0026) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Requisitos do plano de controle ?"

@ 215,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 6a pergunta
@ 225,003 SAY OemToAnsi("6 * "+STR0027) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Inspecao dimensional ?"

@ 255,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 7a pergunta
@ 265,003 SAY OemToAnsi("7 * "+STR0028) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Testes de desempenho de engenharia ?"

@ 295,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 8a pergunta
@ 305,003 SAY OemToAnsi("8 * "+STR0029) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Analise de solucao de problemas ?"

@ 335,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 9a pergunta
@ 345,003 SAY OemToAnsi(STR0030) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"  Existe um programa de treinamento documentado que :"
@ 355,003 SAY OemToAnsi("9 * "+STR0031) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Inclusa todos os funcionarios ?"

@ 375,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 10a pergunta
@ 385,003 SAY OemToAnsi("10 * "+STR0032) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Descreva aqueles que foram treinados ?"

@ 415,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 11a pergunta
@ 425,003 SAY OemToAnsi("11 * "+STR0033) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Forneca uma programacao de treinamento ?"

@ 455,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 12a pergunta
@ 465,003 SAY OemToAnsi(STR0034) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"   Foi completado treinamento para :"
@ 475,003 SAY OemToAnsi("12 * "+STR0035) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Controle Estatistico de Processo"

@ 495,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 13a pergunta
@ 505,003 SAY OemToAnsi("13 * "+STR0036) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Estudos de Capabilidade ?"

@ 535,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 14a pergunta
@ 545,003 SAY OemToAnsi("14 * "+STR0037)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Solucao de Problemas ?"

@ 575,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 15a pergunta
@ 585,003 SAY OemToAnsi("15 * "+STR0038) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Prova de erros ?"

@ 615,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 16a pergunta
@ 625,003 SAY OemToAnsi("16 * "+STR0039) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Outros topicos, conforme identificados ?"

@ 655,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 17a pergunta
@ 665,003 SAY OemToAnsi("17 * "+STR0040) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Cada operacao e dotada de instrucoes de processo"
@ 675,003 SAY OemToAnsi(STR0041) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     ligadas com o plano de controle ?"
                                  
@ 695,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 18a pergunta
@ 705,003 SAY OemToAnsi("18 * "+STR0042) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Instrucoes padrao para o operador estao disponiveis"
@ 715,003 SAY OemToAnsi(STR0043) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     para cada operacao ?"

@ 735,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 19a pergunta
@ 745,003 SAY OemToAnsi(STR0044) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"19 * Lideres de operacao/equipe estiveram envolvidos no"
@ 755,003 SAY OemToAnsi(STR0045) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     desenvolvimento de instrucoes padrao de operacao ?"

@ 775,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 20a pergunta
@ 785,003 SAY OemToAnsi(STR0046) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"   As instrucoes de inspecao incluem :"
@ 795,003 SAY OemToAnsi("20 * "+STR0047) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Especificacoes de desempenho de engenharia"
@ 805,003 SAY OemToAnsi(STR0048) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     facilmente compreendidas ?"

@ 815,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 21a pergunta
@ 825,003 SAY OemToAnsi("21 * "+STR0049) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Frequencia de testes ?"

@ 855,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 22a pergunta
@ 865,003 SAY OemToAnsi("22 * "+STR0050) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Tamanho das amostras ?"

@ 895,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 23a pergunta
@ 905,003 SAY OemToAnsi("23 * "+STR0051) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Planos de reacao ?"

@ 935,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 24a pergunta
@ 945,003 SAY OemToAnsi("24 * "+STR0052) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Documentacao ?"

@ 975,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 25a pergunta
@ 985,003 SAY OemToAnsi(STR0053) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"   As instrucoes visuais sao :"
@ 995,003 SAY OemToAnsi("25 * "+STR0054) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Facilmente compreendidas ?"

@ 1015,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 26a pergunta
@ 1025,003 SAY OemToAnsi("26 * "+STR0055) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Disponiveis ?"

@ 1055,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 27a pergunta
@ 1065,003 SAY OemToAnsi("27 * "+STR0056) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Acessiveis ?"

@ 1095,002 SAY Replicate(OemToAnsi("_"),150)	SIZE 385,007 OF oScrollBox PIXEL

// 28a pergunta
@ 1105,003 SAY OemToAnsi("28 * "+STR0057) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Aprovados ?"

@ 1135,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 29a pergunta
@ 1145,003 SAY OemToAnsi("29 * "+STR0058) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Datadas e atualizadas ?"

@ 1175,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 30a pergunta
@ 1185,003 SAY OemToAnsi("30 - "+STR0059) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Existe procedimento para implementar, manter e"
@ 1195,003 SAY OemToAnsi(STR0060) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     estabelecer planos de reacao para cartas de controle"
@ 1205,003 SAY OemToAnsi(STR0061) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     estatistico ?"

@ 1215,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 31a pergunta
@ 1225,003 SAY OemToAnsi("31 - "+STR0062) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Existe um sistema de analise de causa de raiz efetivo ?"

@ 1255,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 32a pergunta
@ 1265,003 SAY OemToAnsi("32 - "+STR0063) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram feitas provisoes para deixar os desenhos e "
@ 1275,003 SAY OemToAnsi(STR0064) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     especificacoes em seu ultimo nivel de revisao no ponto"
@ 1285,003 SAY OemToAnsi(STR0065) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     de inspecao ?"

@ 1295,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 33a pergunta
@ 1305,003 SAY OemToAnsi("33 - "+STR0066) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Formularios/registros estao disponiveis para que o"
@ 1315,003 SAY OemToAnsi(STR0067) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     pessoal adequado registre os resultados de inspecao ?"

@ 1335,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 34a pergunta
@ 1345,003 SAY OemToAnsi(STR0068) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"   Foram feitas provisoes para se colocar o seguinte material"
@ 1355,003 SAY OemToAnsi(STR0069) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"   na operacao monitorada :"
@ 1365,003 SAY OemToAnsi("34 * "+STR0070) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Instrumento de inspecao ?"

@ 1375,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 35a pergunta
@ 1385,003 SAY OemToAnsi("35 * "+STR0071) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Instrucoes sobre instrumentos ?"

@ 1415,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL
                                            

// 36a pergunta
@ 1425,003 SAY OemToAnsi("36 * "+STR0072) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Amostras de referencia ?"

@ 1455,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 37a pergunta
@ 1465,003 SAY OemToAnsi("37 * "+STR0073) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Registros de inspecao"

@ 1495,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 38a pergunta
@ 1505,003 SAY OemToAnsi("38 - "+STR0074) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram feitas provisoes para certificar e calibrar"
@ 1515,003 SAY OemToAnsi(STR0075) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     rotineiramente os dispositivos de medicao e"
@ 1525,003 SAY OemToAnsi(STR0076) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     equipamentos de teste ?"

@ 1535,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 39a pergunta
@ 1545,003 SAY OemToAnsi(STR0077) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"   Os estudos de capabilidade do sistema de medicao"
@ 1555,003 SAY OemToAnsi(STR0078) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"   necessarios foram :"
@ 1565,003 SAY OemToAnsi("39 - "+STR0079) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Completados"

@ 1575,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 40a pergunta
@ 1585,003 SAY OemToAnsi("40 * "+STR0080) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Aceitos ?"

@ 1615,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 41a pergunta
@ 1625,003 SAY OemToAnsi("41 - "+STR0081) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"As intalacoes e equipamentos de inspecao sao"
@ 1635,003 SAY OemToAnsi(STR0082) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"     adequados para proporcionar uma inspecao dimensional"
@ 1645,003 SAY OemToAnsi(STR0083) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"     inicial e continua em todos os detalhes e componentes ?"

@ 1655,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 42a pergunta
@ 1665,003 SAY OemToAnsi(STR0084) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"   Existe algum procedimento para o controle de recebimento"
@ 1675,003 SAY OemToAnsi(STR0085) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"   de produtos que identifica :"
@ 1685,003 SAY OemToAnsi("42 * "+STR0086) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Caracteristicas a serem inspecionadas ?"

@ 1695,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 43a pergunta
@ 1705,003 SAY OemToAnsi("43 * "+STR0087) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Frequencia da inspecao ?"

@ 1735,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 44a pergunta
@ 1745,003 SAY OemToAnsi("44 * "+STR0088) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Tamanho da amostra ?"

@ 1775,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 45a pergunta
@ 1785,003 SAY OemToAnsi("45 * "+STR0089) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Local designado para o produto aprovado ?"

@ 1815,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 46a pergunta
@ 1825,003 SAY OemToAnsi("46 * "+STR0090) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Disposicao de produtos nao-conforme ?"

@ 1855,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 47a pergunta
@ 1865,003 SAY OemToAnsi("47 - "+STR0091) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Existe algum procedimento para identificar, segregar"
@ 1875,003 SAY OemToAnsi(STR0092) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"     e controlar produtos nao-conforme para evitar a"
@ 1885,003 SAY OemToAnsi(STR0093) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"     sua entrega ?"

@ 1895,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 48a pergunta
@ 1905,003 SAY OemToAnsi("48 - "+STR0094) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Estao disponiveis procedimentos de retrabalho/reparo ?"

@ 1935,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 49a pergunta
@ 1945,003 SAY OemToAnsi("49 - "+STR0095) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Existe algum procedimento para requalificar material"
@ 1955,003 SAY OemToAnsi(STR0096) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"     reparado/retrabalhado ?"

@ 1975,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 50a pergunta
@ 1985,003 SAY OemToAnsi("50 - "+STR0097) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Existe um sistema adequado de rastreabilidade de"
@ 1995,003 SAY OemToAnsi(STR0098) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"     lotes ?"

@ 2015,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 51a pergunta
@ 2025,003 SAY OemToAnsi("51 - "+STR0099) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Foram planejadas e implementadas, auditorias"
@ 2035,003 SAY OemToAnsi(STR0100) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"     periodicas de produto acabado ?"

@ 2055,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 52a pergunta
@ 2065,003 SAY OemToAnsi("52 - "+STR0101) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Foram planejadas e implementadas pesquisas"
@ 2075,003 SAY OemToAnsi(STR0102) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"     periodicas do sistema da qualidade"

@ 2095,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 53a pergunta
@ 2105,003 SAY OemToAnsi("53 - "+STR0103) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"O cliente aprovou a especificacao de embalagem ?"


Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QP280TED³ Autor ³ klaus daniel l cabral    Data ³ 14.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para informacoes do ScrollBox 2ª Edição                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QP280TED(ExpN1, ExpO1) Segunda Edição                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±³          ³ ExpO1 = Dialog       									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA280                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QP280TED(nOpc, oDlg)   //--> Segunda Edição do APQP

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
	QPP280CHEC()
Endif

@ 088,003 MSPANEL oPanel1 PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE 395,012 OF oDlg
@ 004,004 SAY OemToAnsi(STR0010)	COLOR CLR_WHITE SIZE 065,010 OF oPanel1 PIXEL  //"Item - Pergunta"
@ 004,135 SAY OemToAnsi(STR0011) 	COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL  //"Sim/Nao"
@ 004,155 SAY OemToAnsi("/"+STR0106) 	COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL  //"N/a"
@ 004,190 SAY OemToAnsi(STR0012)	COLOR CLR_WHITE SIZE 090,010 OF oPanel1 PIXEL  //"Comentarios/Acao Requerida"
@ 004,300 SAY OemToAnsi(STR0013)	COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL  //"Responsavel"
@ 004,347 SAY OemToAnsi(STR0014)	COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL  //"Dt. Prevista"

oScrollBox := TScrollBox():New(oDlg,103,03,125,395,.T.,.F.,.T.)

@ 001,002 TO 2385,142 		OF oScrollBox PIXEL
@ 001,002 TO 2385,167 		OF oScrollBox PIXEL
@ 001,002 TO 2385,298 		OF oScrollBox PIXEL
@ 001,002 TO 2385,345.5	    OF oScrollBox PIXEL
@ 001,002 TO 2385,385		OF oScrollBox PIXEL

// 1a pergunta
@ 015,144 COMBOBOX oCombo VAR cChoice01 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 015,168 GET oComent VAR cComent01 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 015,298 MSGET oResp VAR cResp01 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 015,346 MSGET oData VAR dData01 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 2a pergunta
@ 055,144 COMBOBOX oCombo VAR cChoice02 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 055,168 GET oComent VAR cComent02 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 055,298 MSGET oResp VAR cResp02 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 055,346 MSGET oData VAR dData02 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 3a pergunta
@ 095,144 COMBOBOX oCombo VAR cChoice03 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 095,168 GET oComent VAR cComent03 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 095,298 MSGET oResp VAR cResp03 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 095,346 MSGET oData VAR dData03 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 4a pergunta
@ 145,144 COMBOBOX oCombo VAR cChoice04 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 145,168 GET oComent VAR cComent04 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 145,298 MSGET oResp VAR cResp04 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 145,346 MSGET oData VAR dData04 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 5a pergunta
@ 185,144 COMBOBOX oCombo VAR cChoice05 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 185,168 GET oComent VAR cComent05 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 185,298 MSGET oResp VAR cResp05 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 185,346 MSGET oData VAR dData05 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 6a pergunta
@ 225,144 COMBOBOX oCombo VAR cChoice06 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 225,168 GET oComent VAR cComent06 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 225,298 MSGET oResp VAR cResp06 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 225,346 MSGET oData VAR dData06 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 7a pergunta
@ 265,144 COMBOBOX oCombo VAR cChoice07 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 265,168 GET oComent VAR cComent07 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 265,298 MSGET oResp VAR cResp07 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 265,346 MSGET oData VAR dData07 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 8a pergunta
@ 305,144 COMBOBOX oCombo VAR cChoice08 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 305,168 GET oComent VAR cComent08 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 305,298 MSGET oResp VAR cResp08 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 305,346 MSGET oData VAR dData08 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 9a pergunta
@ 345,144 COMBOBOX oCombo VAR cChoice09 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 345,168 GET oComent VAR cComent09 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 345,298 MSGET oResp VAR cResp09 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 345,346 MSGET oData VAR dData09 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 10a pergunta
@ 385,144 COMBOBOX oCombo VAR cChoice10 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 385,168 GET oComent VAR cComent10 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 385,298 MSGET oResp VAR cResp10 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 385,346 MSGET oData VAR dData10 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 11a pergunta
@ 425,144 COMBOBOX oCombo VAR cChoice11 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 425,168 GET oComent VAR cComent11 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 425,298 MSGET oResp VAR cResp11 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 425,346 MSGET oData VAR dData11 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 12a pergunta
@ 465,144 COMBOBOX oCombo VAR cChoice12 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 465,168 GET oComent VAR cComent12 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 465,298 MSGET oResp VAR cResp12 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 465,346 MSGET oData VAR dData12 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 13a pergunta
@ 505,144 COMBOBOX oCombo VAR cChoice13 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 505,168 GET oComent VAR cComent13 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 505,298 MSGET oResp VAR cResp13 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 505,346 MSGET oData VAR dData13 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 14a pergunta
@ 545,144 COMBOBOX oCombo VAR cChoice14 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 545,168 GET oComent VAR cComent14 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 545,298 MSGET oResp VAR cResp14 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 545,346 MSGET oData VAR dData14 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 15a pergunta
@ 585,144 COMBOBOX oCombo VAR cChoice15 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 585,168 GET oComent VAR cComent15 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 585,298 MSGET oResp VAR cResp15 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 585,346 MSGET oData VAR dData15 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 16a pergunta
@ 625,144 COMBOBOX oCombo VAR cChoice16 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 625,168 GET oComent VAR cComent16 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 625,298 MSGET oResp VAR cResp16 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 625,346 MSGET oData VAR dData16 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 17a pergunta
@ 665,144 COMBOBOX oCombo VAR cChoice17 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 665,168 GET oComent VAR cComent17 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 665,298 MSGET oResp VAR cResp17 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 665,346 MSGET oData VAR dData17 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 18a pergunta
@ 705,144 COMBOBOX oCombo VAR cChoice18 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 705,168 GET oComent VAR cComent18 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 705,298 MSGET oResp VAR cResp18 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 705,346 MSGET oData VAR dData18 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 19a pergunta
@ 745,144 COMBOBOX oCombo VAR cChoice19 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 745,168 GET oComent VAR cComent19 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 745,298 MSGET oResp VAR cResp19 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 745,346 MSGET oData VAR dData19 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 20a pergunta
@ 785,144 COMBOBOX oCombo VAR cChoice20 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 785,168 GET oComent VAR cComent20 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 785,298 MSGET oResp VAR cResp20 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 785,346 MSGET oData VAR dData20 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 21a pergunta
@ 825,144 COMBOBOX oCombo VAR cChoice21 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 825,168 GET oComent VAR cComent21 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 825,298 MSGET oResp VAR cResp21 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 825,346 MSGET oData VAR dData21 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 22a pergunta
@ 865,144 COMBOBOX oCombo VAR cChoice22 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 865,168 GET oComent VAR cComent22 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 865,298 MSGET oResp VAR cResp22 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 865,346 MSGET oData VAR dData22 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 23a pergunta
@ 905,144 COMBOBOX oCombo VAR cChoice23 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 905,168 GET oComent VAR cComent23 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 905,298 MSGET oResp VAR cResp23 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 905,346 MSGET oData VAR dData23 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 24a pergunta
@ 945,144 COMBOBOX oCombo VAR cChoice24 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 945,168 GET oComent VAR cComent24 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 945,298 MSGET oResp VAR cResp24 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 945,346 MSGET oData VAR dData24 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 25a pergunta
@ 985,144 COMBOBOX oCombo VAR cChoice25 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 985,168 GET oComent VAR cComent25 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 985,298 MSGET oResp VAR cResp25 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 985,346 MSGET oData VAR dData25 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 26a pergunta
@ 1025,144 COMBOBOX oCombo VAR cChoice26 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1025,168 GET oComent VAR cComent26 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1025,298 MSGET oResp VAR cResp26 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1025,346 MSGET oData VAR dData26 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 27a pergunta
@ 1065,144 COMBOBOX oCombo VAR cChoice27 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1065,168 GET oComent VAR cComent27 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1065,298 MSGET oResp VAR cResp27 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1065,346 MSGET oData VAR dData27 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 28a pergunta
@ 1105,144 COMBOBOX oCombo VAR cChoice28 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1105,168 GET oComent VAR cComent28 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1105,298 MSGET oResp VAR cResp28 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1105,346 MSGET oData VAR dData28 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 29a pergunta
@ 1145,144 COMBOBOX oCombo VAR cChoice29 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1145,168 GET oComent VAR cComent29 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1145,298 MSGET oResp VAR cResp29 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1145,346 MSGET oData VAR dData29 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 30a pergunta
@ 1185,144 COMBOBOX oCombo VAR cChoice30 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1185,168 GET oComent VAR cComent30 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1185,298 MSGET oResp VAR cResp30 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1185,346 MSGET oData VAR dData30 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 31a pergunta
@ 1225,144 COMBOBOX oCombo VAR cChoice31 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1225,168 GET oComent VAR cComent31 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1225,298 MSGET oResp VAR cResp31 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1225,346 MSGET oData VAR dData31 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 32a pergunta
@ 1265,144 COMBOBOX oCombo VAR cChoice32 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1265,168 GET oComent VAR cComent32 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1265,298 MSGET oResp VAR cResp32 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1265,346 MSGET oData VAR dData32 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 33a pergunta
@ 1305,144 COMBOBOX oCombo VAR cChoice33 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1305,168 GET oComent VAR cComent33 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1305,298 MSGET oResp VAR cResp33 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1305,346 MSGET oData VAR dData33 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 34a pergunta
@ 1345,144 COMBOBOX oCombo VAR cChoice34 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1345,168 GET oComent VAR cComent34 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1345,298 MSGET oResp VAR cResp34 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1345,346 MSGET oData VAR dData34 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 35a pergunta
@ 1385,144 COMBOBOX oCombo VAR cChoice35 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1385,168 GET oComent VAR cComent35 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1385,298 MSGET oResp VAR cResp35 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1385,346 MSGET oData VAR dData35 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})
                                             

// 36a pergunta
@ 1425,144 COMBOBOX oCombo VAR cChoice36 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1425,168 GET oComent VAR cComent36 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1425,298 MSGET oResp VAR cResp36 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1425,346 MSGET oData VAR dData36 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 37a pergunta
@ 1465,144 COMBOBOX oCombo VAR cChoice37 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1465,168 GET oComent VAR cComent37 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1465,298 MSGET oResp VAR cResp37 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1465,346 MSGET oData VAR dData37 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 38a pergunta
@ 1505,144 COMBOBOX oCombo VAR cChoice38 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1505,168 GET oComent VAR cComent38 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1505,298 MSGET oResp VAR cResp38 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1505,346 MSGET oData VAR dData38 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 39a pergunta
@ 1545,144 COMBOBOX oCombo VAR cChoice39 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1545,168 GET oComent VAR cComent39 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1545,298 MSGET oResp VAR cResp39 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1545,346 MSGET oData VAR dData39 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 40a pergunta
@ 1585,144 COMBOBOX oCombo VAR cChoice40 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1585,168 GET oComent VAR cComent40 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1585,298 MSGET oResp VAR cResp40 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1585,346 MSGET oData VAR dData40 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 41a pergunta
@ 1625,144 COMBOBOX oCombo VAR cChoice41 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1625,168 GET oComent VAR cComent41 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1625,298 MSGET oResp VAR cResp41 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1625,346 MSGET oData VAR dData41 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 42a pergunta
@ 1665,144 COMBOBOX oCombo VAR cChoice42 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1665,168 GET oComent VAR cComent42 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1665,298 MSGET oResp VAR cResp42 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1665,346 MSGET oData VAR dData42 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 43a pergunta
@ 1705,144 COMBOBOX oCombo VAR cChoice43 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1705,168 GET oComent VAR cComent43 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1705,298 MSGET oResp VAR cResp43 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1705,346 MSGET oData VAR dData43 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 44a pergunta
@ 1745,144 COMBOBOX oCombo VAR cChoice44 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1745,168 GET oComent VAR cComent44 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1745,298 MSGET oResp VAR cResp44 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1745,346 MSGET oData VAR dData44 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 45a pergunta
@ 1785,144 COMBOBOX oCombo VAR cChoice45 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1785,168 GET oComent VAR cComent45 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1785,298 MSGET oResp VAR cResp45 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1785,346 MSGET oData VAR dData45 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 46a pergunta
@ 1825,144 COMBOBOX oCombo VAR cChoice46 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1825,168 GET oComent VAR cComent46 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1825,298 MSGET oResp VAR cResp46 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1825,346 MSGET oData VAR dData46 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 47a pergunta
@ 1865,144 COMBOBOX oCombo VAR cChoice47 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1865,168 GET oComent VAR cComent47 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1865,298 MSGET oResp VAR cResp47 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1865,346 MSGET oData VAR dData47 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 48a pergunta
@ 1905,144 COMBOBOX oCombo VAR cChoice48 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1905,168 GET oComent VAR cComent48 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1905,298 MSGET oResp VAR cResp48 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1905,346 MSGET oData VAR dData48 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 49a pergunta
@ 1945,144 COMBOBOX oCombo VAR cChoice49 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1945,168 GET oComent VAR cComent49 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1945,298 MSGET oResp VAR cResp49 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1945,346 MSGET oData VAR dData49 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 50a pergunta
@ 1985,144 COMBOBOX oCombo VAR cChoice50 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 1985,168 GET oComent VAR cComent50 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 1985,298 MSGET oResp VAR cResp50 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 1985,346 MSGET oData VAR dData50 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


// 51a pergunta
@ 2025,144 COMBOBOX oCombo VAR cChoice51 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 2025,168 GET oComent VAR cComent51 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 2025,298 MSGET oResp VAR cResp51 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 2025,346 MSGET oData VAR dData51 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 52a pergunta
@ 2065,144 COMBOBOX oCombo VAR cChoice52 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 2065,168 GET oComent VAR cComent52 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 2065,298 MSGET oResp VAR cResp52 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 2065,346 MSGET oData VAR dData52 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 53a pergunta
@ 2105,144 COMBOBOX oCombo VAR cChoice53 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 2105,168 GET oComent VAR cComent53 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 2105,298 MSGET oResp VAR cResp53 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 2105,346 MSGET oData VAR dData53 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})  

// 54a pergunta
@ 2145,144 COMBOBOX oCombo VAR cChoice54 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 2145,168 GET oComent VAR cComent54 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 2145,298 MSGET oResp VAR cResp54 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 2145,346 MSGET oData VAR dData54 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 55a pergunta
@ 2185,144 COMBOBOX oCombo VAR cChoice55 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 2185,168 GET oComent VAR cComent55 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 2185,298 MSGET oResp VAR cResp55 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 2185,346 MSGET oData VAR dData55 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 56a pergunta
@ 2225,144 COMBOBOX oCombo VAR cChoice56 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 2225,168 GET oComent VAR cComent56 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 2225,298 MSGET oResp VAR cResp56 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 2225,346 MSGET oData VAR dData56 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 57a pergunta
@ 2265,144 COMBOBOX oCombo VAR cChoice57 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 2265,168 GET oComent VAR cComent57 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 2265,298 MSGET oResp VAR cResp57 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 2265,346 MSGET oData VAR dData57 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 58a pergunta
@ 2305,144 COMBOBOX oCombo VAR cChoice58 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 2305,168 GET oComent VAR cComent58 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 2305,298 MSGET oResp VAR cResp58 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 2305,346 MSGET oData VAR dData58 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})

// 59a pergunta
@ 2345,144 COMBOBOX oCombo VAR cChoice59 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 2345,168 GET oComent VAR cComent59 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 2345,298 MSGET oResp VAR cResp59 PICTURE PesqPict("QKT","QKT_RESP") ;
						ReadOnly F3 ConSX3("QKT_RESP") VALID CheckSx3("QKT_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 2345,346 MSGET oData VAR dData59 SIZE 40,10 OF oScrollBox PIXEL FONT oFont
aAdd(aObj, {oCombo, oComent, oData, oResp})


Q280S2ED(oScrollBox, oFont)   //Montas as Pèrguntas da Rotina da Segunda  Edição Do APQP

If !Empty(M->QKT_CHAVE)
	cChave := M->QKT_CHAVE
Endif

If nOpc <> 3 .and. nOpc <> 4
	For nCont := 1 To Len(aObj)
		aObj[nCont,1]:lReadOnly := .T.
		aObj[nCont,2]:lReadOnly := .T.
		aObj[nCont,3]:lReadOnly := .T.
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
±±³Funcao    ³Q280S2ED ³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 14.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra os SAYS da funcao QPP280Tela                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q280S2ED(ExpO1, ExpO2)-->Segunda Edição do APQP             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do Scrool                                   ³±±
±±³          ³ ExpO2 = Objeto da font                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA280                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Obs      ³ Funcao criada devido a erro de Memory Overbooked           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Q280S2ED(oScrollBox, oFont)   //2ª Edição do APQP

// 1a pergunta

@ 015,003 SAY OemToAnsi("1 * "+STR0127) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  	//"É necessária a assistência ou aprovação do cliente "
@ 025,003 SAY OemToAnsi(STR0128) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  	        //"para desenvolver o plano de controle ?"

@ 045,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 2a pergunta
@ 055,003 SAY OemToAnsi("2 * "+STR0129) SIZE 150,010 OF oScrollBox PIXEL FONT oFont   //"A organização identificou quem será o contato da "
@ 065,003 SAY OemToAnsi(STR0130) SIZE 150,010 OF oScrollBox PIXEL FONT oFont          //"qualidade com o cliente ?"

@ 085,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 3a pergunta
@ 095,003 SAY OemToAnsi("3 * "+STR0129) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"A organização  indentificou quem sera o contato da"
@ 105,003 SAY OemToAnsi(STR0021) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"    qualidade com seus fornecedores ?"

@ 135,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 4a pergunta
@ 145,003 SAY OemToAnsi("4 * "+STR0022) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"O sistema da qualidade foi analisado criticamente"
@ 155,003 SAY OemToAnsi(STR0107) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"e aprovado de acordo com os requisitos do cliente?"


@ 175,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 5a pergunta
@ 185,003 SAY OemToAnsi(STR0025) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"  Existe pessoal suficiente identificado para cobrir :"
@ 195,003 SAY OemToAnsi("5 * "+STR0026) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Requisitos do plano de controle ?"

@ 215,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 6a pergunta
@ 225,003 SAY OemToAnsi("6 * "+STR0027) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Inspecao dimensional ?"

@ 255,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 7a pergunta
@ 265,003 SAY OemToAnsi("7 * "+STR0028) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Testes de desempenho de engenharia ?"

@ 295,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 8a pergunta
@ 305,003 SAY OemToAnsi("8 * "+STR0108) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Reaçao a problemas e analise de solução de problemas?"

@ 335,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 9a pergunta
@ 345,003 SAY OemToAnsi(STR0030) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"  Existe um programa de treinamento documentado que :"
@ 355,003 SAY OemToAnsi("9 * "+STR0031) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Inclusa todos os funcionarios ?"

@ 375,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 10a pergunta
@ 385,003 SAY OemToAnsi("10 * "+STR0032) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Descreva aqueles que foram treinados ?"

@ 415,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 11a pergunta
@ 425,003 SAY OemToAnsi("11 * "+STR0033) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Forneca uma programacao de treinamento ?"

@ 455,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 12a pergunta
@ 465,003 SAY OemToAnsi(STR0034) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"   Foi completado treinamento para :"
@ 475,003 SAY OemToAnsi("12 * "+STR0035) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Controle Estatistico de Processo"

@ 495,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 13a pergunta
@ 505,003 SAY OemToAnsi("13 * "+STR0036) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Estudos de Capabilidade ?"

@ 535,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 14a pergunta
@ 545,003 SAY OemToAnsi("14 * "+STR0131)	SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Resolução  de Problemas ?"

@ 575,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 15a pergunta
@ 585,003 SAY OemToAnsi("15 * "+STR0038) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Prova de erros ?"

@ 615,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL


// 16a pergunta
@ 625,003 SAY OemToAnsi("16 * "+STR0109) SIZE 150,010 OF oScrollBox PIXEL FONT oFont // "Planos de Reação?"

@ 655,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 17a pergunta
@ 665,003 SAY OemToAnsi("17 * "+STR0039) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Outros topicos, conforme identificados ?"

@ 695,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 18a pergunta
@ 705,003 SAY OemToAnsi("18 * "+STR0040) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Cada operacao e dotada de instrucoes de processo"
@ 715,003 SAY OemToAnsi(STR0041) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     ligadas com o plano de controle ?"
                                  
@ 735,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 19a pergunta
@ 745,003 SAY OemToAnsi("19 * "+STR0132) SIZE 150,010 OF oScrollBox PIXEL FONT oFont      //"As instruções-padrão para o operador estão"
@ 755,003 SAY OemToAnsi(STR0133) SIZE 150,010 OF oScrollBox PIXEL FONT oFont              //"acessíveis em cada estação de trabalho ?"

@ 775,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL


// 20a pergunta
@ 785,003 SAY OemToAnsi("20 -"+STR0110) SIZE 150,010 OF oScrollBox PIXEL FONT oFont    //"As instruções para o operador incluem fotos e diagramas"

@ 815,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 21a pergunta
@ 825,003 SAY OemToAnsi("21 * "+STR0044) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Lideres de operacao/equipe estiveram envolvidos no"
@ 835,003 SAY OemToAnsi(STR0045) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     desenvolvimento de instrucoes padrao de operacao ?"

@ 855,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 22a pergunta
@ 865,003 SAY OemToAnsi(STR0046) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"   As instrucoes de inspecao incluem :"
@ 875,003 SAY OemToAnsi("22 * "+STR0047) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Especificacoes de desempenho de engenharia"
@ 885,003 SAY OemToAnsi(STR0048) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     facilmente compreendidas ?"

@ 895,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 23a pergunta
@ 905,003 SAY OemToAnsi("23 * "+STR0049) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Frequencia de testes ?"

@ 935,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 24a pergunta
@ 945,003 SAY OemToAnsi("24 * "+STR0050) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Tamanho das amostras ?"

@ 975,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 25a pergunta
@ 985,003 SAY OemToAnsi("25 * "+STR0051) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Planos de reacao ?"

@ 1015,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 26a pergunta
@ 1025,003 SAY OemToAnsi("26 * "+STR0134) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Requisitos de Documentacao ?"

@ 1055,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 27a pergunta
@ 1065,003 SAY OemToAnsi(STR0053) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"   As instrucoes visuais sao :"
@ 1075,003 SAY OemToAnsi("27 * "+STR0135) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Apropriadas, facilmente compreendidas e legíveis?"

@ 1095,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 28a pergunta
@ 1105,003 SAY OemToAnsi("28 * "+STR0055) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Disponiveis ?"

@ 1135,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 29a pergunta
@ 1145,003 SAY OemToAnsi("29 * "+STR0056) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Acessiveis ?"

@ 1175,002 SAY Replicate(OemToAnsi("_"),150)	SIZE 385,007 OF oScrollBox PIXEL

// 30a pergunta
@ 1185,003 SAY OemToAnsi("30 * "+STR0057) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Aprovados ?"

@ 1215,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 31a pergunta
@ 1225,003 SAY OemToAnsi("31 * "+STR0058) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Datadas e atualizadas ?"

@ 1255,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 32a pergunta
@ 1265,003 SAY OemToAnsi("32 * "+STR0136) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //""Existe um procedimento para implementar, manter e estabelecer"
@ 1275,003 SAY OemToAnsi(STR0137) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"planos de reação para questões como condições fora de controle"
@ 1285,003 SAY OemToAnsi(STR0138) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //""baseadas no controle estatístico de processo? "

@ 1295,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 33a pergunta
@ 1305,003 SAY OemToAnsi("33 * "+STR0139) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //""Existe um processo identificado para a resolução de "
@ 1315,003 SAY OemToAnsi(STR0140) SIZE 150,010 OF oScrollBox PIXEL FONT oFont          //""problemas que inclui a análise de causa raiz?"

@ 1335,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 34a pergunta
@ 1345,003 SAY OemToAnsi("34 * "+STR0141) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Os desenhos e especificações mais atualizados estão"
@ 1355,003 SAY OemToAnsi(STR0142) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //""disponíveis para o operador, em particular nos "
@ 1365,003 SAY OemToAnsi(STR0143) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //""pontos de inspeção?"

@ 1375,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 35a pergunta
@ 1385,003 SAY OemToAnsi("35 * "+STR0111) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Os testes de engenharia (dimensionais, de material, aparencia"
@ 1395,003 SAY OemToAnsi(STR0112) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"e desempenho) foram concluidos e documentados, conforme "
@ 1405,003 SAY OemToAnsi(STR0113) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"necessario, de acordo com os requisitos do cliente?"

@ 1415,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL


// 36a pergunta
@ 1425,003 SAY OemToAnsi("36 * "+STR0066) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Formularios/registros estao disponiveis para que o"
@ 1435,003 SAY OemToAnsi(STR0067) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     pessoal adequado registre os resultados de inspecao ?"

@ 1455,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 37a pergunta
@ 1465,003 SAY OemToAnsi(STR0144) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Os itens abaixo estão disponíveis e foram colocados nos "
@ 1475,003 SAY OemToAnsi(STR0145) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"pontos apropriados da operação?"
@ 1485,003 SAY OemToAnsi("37 * "+STR0114) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Dispositivos de monitoramento e medição?"

@ 1495,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 38a pergunta
@ 1505,003 SAY OemToAnsi("38 * "+STR0115) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Instruções sobre os dispositivos de medição"

@ 1535,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL
                                            

// 39a pergunta
@ 1545,003 SAY OemToAnsi("39 * "+STR0072) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Amostras de referencia ?"

@ 1575,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 40a pergunta
@ 1585,003 SAY OemToAnsi("40 * "+STR0073) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Registros de inspecao"

@ 1615,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 41a pergunta
@ 1625,003 SAY OemToAnsi("41 * "+STR0074) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Foram feitas provisoes para certificar e calibrar"
@ 1635,003 SAY OemToAnsi(STR0075) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     rotineiramente os dispositivos de medicao e"
@ 1645,003 SAY OemToAnsi(STR0076) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"     equipamentos de teste ?"

@ 1655,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 42a pergunta
@ 1665,003 SAY OemToAnsi(STR0077) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"   Os estudos de capabilidade do sistema de medicao"
@ 1675,003 SAY OemToAnsi(STR0078) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"   necessarios foram :"
@ 1685,003 SAY OemToAnsi("42 * "+STR0146) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Concluídos ?

@ 1695,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 43a pergunta
@ 1705,003 SAY OemToAnsi("43 * "+STR0080) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Aceitos ?"

@ 1735,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 44a pergunta
@ 1745,003 SAY OemToAnsi("44 * "+STR0116) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Os Estudos de capabilidade inicial do processo foram"
@ 1755,003 SAY OemToAnsi(STR0117) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"conduzidos de acordo com os requisitos do cliente?"

@ 1775,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 45a pergunta
@ 1785,003 SAY OemToAnsi("45 * "+STR0147) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"As instalações e equipamentos de inspeção de layout são"
@ 1795,003 SAY OemToAnsi(STR0148) SIZE 150,010 OF oScrollBox PIXEL FONT oFont         //"adequadas para proporcionar um layout inicial e continuo"
@ 1805,003 SAY OemToAnsi(STR0149) SIZE 150,010 OF oScrollBox PIXEL FONT oFont         //"de todos os detalhes e componentes, de acordo com os "
@ 1815,003 SAY OemToAnsi(STR0150) SIZE 150,010 OF oScrollBox PIXEL FONT oFont         //"requisitos do cliente?"

@ 1817,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 46a pergunta
@ 1830,003 SAY OemToAnsi(STR0084) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"   Existe algum procedimento para o controle de recebimento"
@ 1840,003 SAY OemToAnsi(STR0085) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"   de produtos que identifica :"
@ 1850,003 SAY OemToAnsi("46 * "+STR0086) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Caracteristicas a serem inspecionadas ?"

@ 1855,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 47a pergunta
@ 1865,003 SAY OemToAnsi("47 * "+STR0087) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Frequencia da inspecao ?"

@ 1895,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 48a pergunta
@ 1905,003 SAY OemToAnsi("48 * "+STR0088) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Tamanho da amostra ?"

@ 1935,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 49a pergunta
@ 1945,003 SAY OemToAnsi("49 * "+STR0089) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Local designado para o produto aprovado ?"

@ 1975,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 50a pergunta
@ 1985,003 SAY OemToAnsi("50 * "+STR0090) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Disposicao de produtos nao-conforme ?"

@ 2015,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 51a pergunta
@ 2025,003 SAY OemToAnsi("51 * "+STR0118) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Peças de amostra da producao foram fornecidas de acordo "
@ 2035,003 SAY OemToAnsi(STR0119) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"com os requisitos do cliente?"

@ 2055,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL


// 52a pergunta
@ 2065,003 SAY OemToAnsi("52 * "+STR0091) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Existe algum procedimento para identificar, segregar"
@ 2075,003 SAY OemToAnsi(STR0092) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"     e controlar produtos nao-conforme para evitar a"
@ 2085,003 SAY OemToAnsi(STR0093) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"     sua entrega ?"

@ 2095,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 53a pergunta
@ 2105,003 SAY OemToAnsi("53 * "+STR0151) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Estão disponiveis procedimentos de retrabalho / reparo"
@ 2115,003 SAY OemToAnsi(STR0152) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"para assegurar produtos conformes ?"

@ 2135,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 54a pergunta
@ 2145,003 SAY OemToAnsi("54 * "+STR0095) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Existe algum procedimento para requalificar material"
@ 2155,003 SAY OemToAnsi(STR0096) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"     reparado/retrabalhado ?"

@ 2175,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 55a pergunta
@ 2185,003 SAY OemToAnsi("55 * "+STR0120) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"Uma amostra mestre foi retida, se necessario, como"
@ 2195,003 SAY OemToAnsi(STR0121) SIZE 150,010 OF oScrollBox PIXEL FONT oFont  //"parte do processo de aprovacao de peça?"

@ 2215,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 56a pergunta
@ 2225,003 SAY OemToAnsi("56 * "+STR0097) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Existe um sistema adequado de rastreabilidade de"
@ 2235,003 SAY OemToAnsi(STR0098) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"     lotes ?"

@ 2255,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 57a pergunta
@ 2265,003 SAY OemToAnsi("57 * "+STR0099) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Foram planejadas e implementadas, auditorias"
@ 2275,003 SAY OemToAnsi(STR0100) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"     periodicas de produto acabado ?"

@ 2295,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 58a pergunta
@ 2305,003 SAY OemToAnsi("58 * "+STR0101) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Foram planejadas e implementadas pesquisas"
@ 2315,003 SAY OemToAnsi(STR0102) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"     periodicas do sistema da qualidade"

@ 2335,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 59a pergunta
@ 2345,003 SAY OemToAnsi("59 * "+STR0153) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"O cliente aprovou a Embalagem e a especificação da "
@ 2355,003 SAY OemToAnsi(STR0154) SIZE 150,010 OF oScrollBox PIXEL FONT oFont         //"embalagem ?"

Return




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP280Chec³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 14.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza conteudo das Variaveis                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP280Chec()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA280                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP280Chec()

Local nTamLin 	:= 38 // Tamanho da linha do texto
Local cEspecie 	:= "PPA280"
Local nSeq
Local aArea		:= {}

aArea := GetArea()

DbSelectArea("QKT")
DbSetOrder(1)
DbSeek(xFilial("QKT")+M->QKT_PECA+M->QKT_REV+"01")

Do While xFilial("QKT")+M->QKT_PECA+M->QKT_REV == QKT->QKT_FILIAL+QKT->QKT_PECA+QKT->QKT_REV ;
			.and. !Eof()
	
	nSeq := QKT->QKT_NPERG
	
	cChoice&(nSeq)	:= Iif(QKT_RPOSTA == "1", aItems[1],(Iif(QKT_RPOSTA == "2", aItems[2],aItems[3])))
	dData&(nSeq)	:= QKT->QKT_DTPREV
	cResp&(nSeq)	:= QKT->QKT_RESP

	If !Empty(QKT->QKT_CHAVE)
		cComent&(nSeq) := QO_Rectxt(M->QKT_CHAVE,cEspecie+nSeq,1, nTamLin,"QKO")
	Endif
		
	DbSelectArea("QKT")
	DbSkip()

Enddo

RestArea(aArea)

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA280Grav³ Autor ³ Robson Ramiro A Olivei³ Data ³ 14.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Gravacao Checklist APQP - A4 (Incl./Alter.)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA280Grav(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA280                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA280Grav(nOpc)

Local nCont, nRec
Local bCampo	:= { |nCPO| Field(nCPO) }
Local lGraOk	:= .T.
Local nTamLin	:= 38
Local cEspecie	:= "PPA280"
Local nSeq
Local nSaveSX8	:= GetSX8Len()
Local lMVQAPQPED := GetMV("MV_QAPQPED",.T.,"1") == "1"
DbSelectArea("QKT")
	
Begin Transaction

// Verifica se existe texto antes de criar chave
If Empty(cChave)
	cChave := GetSXENum("QKT", "QKT_CHAVE",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

Endif

DbSelectArea("QKT")
DbSetOrder(1)

For nRec := 1 To Iif(lMVQAPQPED,53,59)// 53 ou 59 perguntas 
	
	nSeq := StrZero(nRec,2)

	If ALTERA
		If DbSeek(xFilial("QKT")+M->QKT_PECA+M->QKT_REV+nSeq)
			RecLock("QKT",.F.)
		Else
			RecLock("QKT",.T.)
		Endif
	Else
		RecLock("QKT",.T.)
	Endif

	For nCont := 1 To FCount()
		If "FILIAL"$Field(nCont)
			FieldPut(nCont,xFilial("QKT"))
		Else
			FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
		Endif
	Next nCont

	QKT->QKT_REVINV	:= Inverte(M->QKT_REV)
	QKT->QKT_NPERG	:= nSeq
	QKT->QKT_RPOSTA	:= Iif(cChoice&(nSeq) == STR0007,"1",Iif(cChoice&(nSeq) == STR0008,"2", "3") ) //"Sim"###"NAO"###"N/A"    
	QKT->QKT_DTPREV	:= &("dData"+Padr(nSeq,2))
	QKT->QKT_RESP	:= &("cResp"+Padr(nSeq,2))
	QKT->QKT_FILRES	:= cFilAnt
	QKT->QKT_CHAVE	:= cChave

	If !Empty(cComent&(nSeq))
		aComent&(nSeq) := GeraText(nTamLin, cComent&(nSeq))
		QO_GrvTxt(cChave,cEspecie+nSeq,1,@aComent&(nSeq))
	Endif
	
	DbSelectArea("QKT")

Next nRec
	
MsUnLock()

End Transaction

			
Return lGraOk

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PP280TudOk ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 14.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para inclusao/alteracao geral                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP280TudOk                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QPPA280                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PP280TudOk

Local lRetorno	:= .T.

If Empty(M->QKT_PECA) .or. Empty(M->QKT_REV)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
Endif

If INCLUI
	If !ExistChav("QKT",M->QKT_PECA+M->QKT_REV)
		lRetorno := .F.
		Help(" ",1,"JAGRAVADO")  // Campo ja Existe
	Endif
	If !ExistCpo("QK1",M->QKT_PECA+M->QKT_REV)
		lRetorno := .F.
		Help(" ",1,"REGNOIS")  // Nao existe amarracao
	Endif
Endif

Return lRetorno


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A280Dele ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 14.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fucao para exclusao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A280Dele()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA280                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A280Dele()

Local cEspecie := "PPA280"
Local nSeq, nRec, cKey
Local aArqRec := {}
Local lMVQAPQPED := GetMV("MV_QAPQPED",.T.,"1") == "1"

DbSelectArea("QKT")
DbSeek(xFilial("QKT")+M->QKT_PECA+M->QKT_REV+"01")

cKey := QKT->QKT_CHAVE

Do While xFilial("QKT")+M->QKT_PECA+M->QKT_REV == QKT->QKT_FILIAL+QKT->QKT_PECA+QKT->QKT_REV ;
			.and. !Eof()

	aAdd(aArqRec, Recno())  //alimenta array com os enderecos a serem deletados
	DbSkip()
Enddo

Begin Transaction

If Len(aArqRec) > 0

	For nRec := 1 To Iif(lMVQAPQPED,53,59)// 53 ou 59  Perguntas 

		nSeq := StrZero(nRec,2)

		If !Empty(cKey)
			QO_DelTxt(cKey,cEspecie+nSeq) //QPPXFUN
		Endif
	 
		DbSelectArea("QKT")
		DbGoTo(aArqRec[nRec])
		RecLock("QKT",.F.)
		DbDelete()

	Next nRec

Endif

MsUnLock()
		
End Transaction

Return