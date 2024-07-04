#INCLUDE "QPPA250.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA250  ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 02.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Checklist APQP - A1 DFMEA                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA250(void)                                              ³±±
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

Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui"  , 	0, 1},;  	//"Pesquisar"
					{ OemToAnsi(STR0002), "PPA250Roti", 	0, 2},;  	//"Visualizar"
					{ OemToAnsi(STR0003), "PPA250Roti", 	0, 3},;  	//"Incluir"
					{ OemToAnsi(STR0004), "PPA250Roti", 	0, 4},;  	//"Alterar"
					{ OemToAnsi(STR0005), "PPA250Roti", 	0, 5},;		//"Excluir"
					{ OemToAnsi(STR0031), "QPPR250(.T.)", 	0, 6} } 	//"Imprimir"
Return aRotina

Function QPPA250()

Private cFiltro

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0006) //"Checklist APQP - A1 DFMEA"

Private aRotina := MenuDef()

DbSelectArea("QKQ")
DbSetOrder(1)

cFiltro := 'QKQ_NPERG == "01"'

Set Filter To &cFiltro
mBrowse( 6, 1, 22, 75,"QKQ",,,,,,)
Set Filter To


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
?????????????????????????????????????????????????????????????????????????????
??ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ???
??ºPrograma  ?QPPA250CE   ºAutor  ?Klaus Daniel L.C   º Data ?  09/28/09   º??
??ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ???
??ºDesc.     ?Função que verifica com qual Edição foi feio o DFMEA       º??
??º          ?                                                            º??
??ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ???
??ºUso       ? AP                                                        º??
??ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ???
?????????????????????????????????????????????????????????????????????????????
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
  
// Consistencia para verificar se na base de dados a DFMEA foi gerada na primeira ou na segunda edicao;

Function QPPA250CE()

Local nCont      :=0
Local cPecaR     :=""
Local aArea		 := {}


cPecaR 	:= (QKQ->QKQ_FILIAL+QKQ->QKQ_PECA+QKQ->QKQ_REV)

aArea := GetArea()                                         

DbSelectArea("QKQ")
Set Filter To
DbSetOrder(1)
DbGoTop()
DbSeek(cPecaR+"01")   


Do while !Eof().and. QKQ->QKQ_FILIAL+QKQ->QKQ_PECA+QKQ->QKQ_REV == cPecaR
	nCont++
	Dbskip()  
	
Enddo
RestArea(aArea)


Return nCont


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA250Roti  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³08.05.02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Manutencao dos Dados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA250Roti(ExpC1,ExpN1,ExpN2)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                     ³±±
±±³          ³ ExpN1 = Numero do registro                                   ³±±
±±³          ³ ExpN2 = Numero da opcao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PPA250Roti(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local lOk 			:= .F.
Local aCposVis		:= {}
Local aCposAlt		:= {}
Local aButtons		:= {}
Local nNresp        := 0 
Local lPriED250     := GetMV("MV_QAPQPED",.T.,"1") == '1' // Define se o APQP deve ser feito na primeira ou segunda edição 1 - Primeira Edição 2 - Segunda Edição
Local cTitulo       := ""   //Titulo da Janela
Private cChave		:= ""
Private aItems 		:= {}

nNresp := QPPA250CE()  //Verifica pelo numro de NResp em qual modelo foi feio o APQP, se primeira ou segunda edição
                         
//Consistência para Verificar se pode ou nao Visualizar, Excluir e Alterar os dados.        

If (nNresp == 10 .and. lPriED250)  .and. nOpc <> 3
Set filter to &cFiltro
		AVISO(STR0057,STR0058+STR0059+STR0060,{"Ok"},3,"MV_QAPQPED")	
	    Return Nil

EndIf

If (nNresp == 8  .and. !lPriED250) .and. nOpc <> 3
Set filter to &cFiltro
	    AVISO(STR0057,STR0058+STR0059+STR0060,{"Ok"},3,"MV_QAPQPED")				
		Return Nil

EndIF


// Montando o Array das Respostas do ComboBox (SIM-NAO-N/A)

If lPriED250
	 aItems 		:= {STR0007,STR0008} //"Sim"###"Nao"
Else
	 aItems 		:= {STR0007,STR0008,STR0033} //"Sim"###"Nao"###"N/a"
EndIF

Private cComent01, cComent02, cComent03, cComent04
Private cComent05, cComent06, cComent07, cComent08, cComent09, cComent10
Private cChoice01 	:= cChoice02 := cChoice03 := cChoice04 	:= aItems[1]
Private cChoice05 	:= cChoice06 := cChoice07 := cChoice08 	:= cChoice09 	:= cChoice10 	:=aItems[1]
Private cResp01 	:= cResp02 := cResp03 := cResp04 			:= Space(10)
Private cResp05 	:= cResp06 := cResp07 := cResp08  := cResp09 := cResp10		:= Space(10)
Private dData01 	:= dData02 := dData03 := dData04 			:= dDataBase
Private dData05 	:= dData06 := dData07 := dData08 := dData09 := dData10			:= dDataBase

aCposVis := { "QKQ_PECA", "QKQ_REV", "QKQ_DTREVI",	"QKQ_RESPOR", "QKQ_PREPOR" }

aCposAlt := { "QKQ_DTREVI", "QKQ_RESPOR", "QKQ_PREPOR" }
				
If nOpc == 2 
	aButtons := {{"BMPVISUAL",	{ || QPPR250() }, OemToAnsi(STR0009), OemToAnsi(STR0032) }} //"Visualizar/Imprimir"###"Vis/Prn"
Endif

If nOpc == 4
	If !QPPVldAlt(QKQ->QKQ_PECA,QKQ->QKQ_REV)
		Return
	Endif
Endif

DbSelectArea(cAlias)

Set Filter To

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lPriED250   //Monta o Titulo de acordo com o Parametro
	cTitulo := STR0006
Else 
	cTitulo := STR0006+STR0048
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitulo) ;  //"Checklist APQP - A1 DFMEA"
						FROM 120,000 TO 580,795 OF oMainWnd PIXEL
						
RegToMemory("QKQ",(nOpc == 3))

Enchoice("QKQ",nReg,nOpc, , , ,aCposVis ,{30,03,85,395}, , , , ,)

If GetMV("MV_QAPQPED",.F.,"1") == '1'
	QP250TEL(nOpc, oDlg)     //Tela primeira Ediçao
Else
	QP250TED(nOpc, oDlg)     //Tela Segunda Edição
Endif
                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP250TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, ,aButtons ) CENTERED

If lOk .and. (nOpc == 3 .or. nOpc == 4)
	PPA250Grav(nOpc)
Endif

If nOpc == 5 .and. lOk
	A250Dele()
Endif

Set Filter To &cFiltro

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QP250TEL³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 03.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para informacoes do ScrollBox                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QP250TEL(ExpN1, ExpO1)  //Primeira Edição                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±³          ³ ExpO1 = Dialog       									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QP250TEL(nOpc, oDlg)

Local oScrollBox := Nil
Local oCombo01, oCombo02, oCombo03, oCombo04
Local oCombo05, oCombo06, oCombo07, oCombo08
Local oComent01, oComent02, oComent03, oComent04
Local oComent05, oComent06, oComent07, oComent08
Local oData01, oData02, oData03, oData04
Local oData05, oData06, oData07, oData08
Local oResp01, oResp02, oResp03, oResp04
Local oResp05, oResp06, oResp07, oResp08

DEFINE FONT oFont 	 NAME "Arial" SIZE 5.5,12.5
DEFINE FONT oFontTxt NAME "Courier New" SIZE 6,0
DEFINE FONT oFontCou NAME "Courier New" SIZE 5,15

If nOpc <> 3
	QPP250CHEC()
Endif

@ 088,003 MSPANEL oPanel1 PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE 395,012 OF oDlg
@ 004,004 SAY OemToAnsi(STR0010)	COLOR CLR_WHITE SIZE 065,010 OF oPanel1 PIXEL //"Item - Pergunta"
@ 004,150 SAY OemToAnsi(STR0011) 	COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL //"Sim/Nao"
@ 004,190 SAY OemToAnsi(STR0012)	COLOR CLR_WHITE SIZE 090,010 OF oPanel1 PIXEL //"Comentarios/Acao Requerida"
@ 004,300 SAY OemToAnsi(STR0013)	COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL //"Responsavel"
@ 004,347 SAY OemToAnsi(STR0014)	COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL //"Dt. Prevista"

oScrollBox := TScrollBox():New(oDlg,103,03,125,395,.T.,.F.,.T.)

@ 001,002 TO 340,142 	OF oScrollBox PIXEL
@ 001,002 TO 340,167 	OF oScrollBox PIXEL
@ 001,002 TO 340,298 	OF oScrollBox PIXEL
@ 001,002 TO 340,345.5 OF oScrollBox PIXEL
@ 001,002 TO 340,385	OF oScrollBox PIXEL

// 1a pergunta

@ 015,003 SAY OemToAnsi(STR0015) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"1-O SFMEA e/ou DFMEA foi preparado utilizando o manual"
@ 025,003 SAY OemToAnsi(STR0016) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"  de referencia Analise de Modo e Efeitos de Falha"
@ 035,003 SAY OemToAnsi(STR0017) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"  Potencial(FMEA) da Chrysler, Ford e General Motors ?"

@ 015,144 COMBOBOX oCombo01 VAR cChoice01 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 015,168 GET oComent01 VAR cComent01 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 015,298 MSGET oResp01 VAR cResp01 PICTURE PesqPict("QKQ","QKQ_RESP") ;
						ReadOnly F3 ConSX3("QKQ_RESP") VALID CheckSx3("QKQ_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 015,346 MSGET oData01 VAR dData01 SIZE 40,10 OF oScrollBox PIXEL FONT oFont

@ 045,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 2a pergunta
@ 055,003 SAY OemToAnsi(STR0018) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"2-Foram analisados criticamente dados historicos de"
@ 065,003 SAY OemToAnsi(STR0019) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"  campanhas e garantia ?"

@ 055,144 COMBOBOX oCombo02 VAR cChoice02 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 055,168 GET oComent02 VAR cComent02 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 055,298 MSGET oResp02 VAR cResp02 PICTURE PesqPict("QKQ","QKQ_RESP") ;
						ReadOnly F3 ConSX3("QKQ_RESP") VALID CheckSx3("QKQ_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 055,346 MSGET oData02 VAR dData02 SIZE 40,10 OF oScrollBox PIXEL FONT oFont

@ 085,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 3a pergunta
@ 095,003 SAY OemToAnsi(STR0020) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"3-Outros DFMEA's de pecas similares foram considerados ?"

@ 095,144 COMBOBOX oCombo03 VAR cChoice03 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 095,168 GET oComent03 VAR cComent03 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 095,298 MSGET oResp03 VAR cResp03 PICTURE PesqPict("QKQ","QKQ_RESP") ;
						ReadOnly F3 ConSX3("QKQ_RESP") VALID CheckSx3("QKQ_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 095,346 MSGET oData03 VAR dData03 SIZE 40,10 OF oScrollBox PIXEL FONT oFont

@ 135,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL


// 4a pergunta
@ 145,003 SAY OemToAnsi(STR0021) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"4-O SFMEA e/ou DFMEA identifica as Caracteristica"
@ 155,003 SAY OemToAnsi(STR0022) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"  Especiais ?"


@ 145,144 COMBOBOX oCombo04 VAR cChoice04 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 145,168 GET oComent04 VAR cComent04 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 145,298 MSGET oResp04 VAR cResp04 PICTURE PesqPict("QKQ","QKQ_RESP") ;
						ReadOnly F3 ConSX3("QKQ_RESP") VALID CheckSx3("QKQ_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 145,346 MSGET oData04 VAR dData04 SIZE 40,10 OF oScrollBox PIXEL FONT oFont

@ 175,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 5a pergunta
@ 185,003 SAY OemToAnsi(STR0023) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"5-As caracteristicas de projeto que afetam os modos de"
@ 195,003 SAY OemToAnsi(STR0024) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"  falha de alta prioridade de risco foram identificas ?"


@ 185,144 COMBOBOX oCombo05 VAR cChoice05 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 185,168 GET oComent05 VAR cComent05 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 185,298 MSGET oResp05 VAR cResp05 PICTURE PesqPict("QKQ","QKQ_RESP") ;
						ReadOnly F3 ConSX3("QKQ_RESP") VALID CheckSx3("QKQ_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 185,346 MSGET oData05 VAR dData05 SIZE 40,10 OF oScrollBox PIXEL FONT oFont

@ 215,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 6a pergunta
@ 225,003 SAY OemToAnsi(STR0025) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"6-Foram designadas acoes corretivas apropriadas para"
@ 235,003 SAY OemToAnsi(STR0026) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"  os numeros de prioridade de risco elevado ?"

@ 225,144 COMBOBOX oCombo06 VAR cChoice06 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 225,168 GET oComent06 VAR cComent06 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 225,298 MSGET oResp06 VAR cResp06 PICTURE PesqPict("QKQ","QKQ_RESP") ;
						ReadOnly F3 ConSX3("QKQ_RESP") VALID CheckSx3("QKQ_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 225,346 MSGET oData06 VAR dData06 SIZE 40,10 OF oScrollBox PIXEL FONT oFont

@ 255,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL


// 7a pergunta
@ 265,003 SAY OemToAnsi(STR0027) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"7-Foram designadas acoes corretivas apropriadas para"
@ 275,003 SAY OemToAnsi(STR0028) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"  os numeros de severidade elevada ?"

@ 265,144 COMBOBOX oCombo07 VAR cChoice07 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 265,168 GET oComent07 VAR cComent07 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 265,298 MSGET oResp07 VAR cResp07 PICTURE PesqPict("QKQ","QKQ_RESP") ;
						ReadOnly F3 ConSX3("QKQ_RESP") VALID CheckSx3("QKQ_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 265,346 MSGET oData07 VAR dData07 SIZE 40,10 OF oScrollBox PIXEL FONT oFont

@ 295,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 8a pergunta
@ 305,003 SAY OemToAnsi(STR0029) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"8-As Prioridades de risco elevado foram revistas apos as"
@ 315,003 SAY OemToAnsi(STR0030) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"  acoes corretivas completadas e verificadas ?"

@ 305,144 COMBOBOX oCombo08 VAR cChoice08 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 305,168 GET oComent08 VAR cComent08 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 305,298 MSGET oResp08 VAR cResp08 PICTURE PesqPict("QKQ","QKQ_RESP") ;
						ReadOnly F3 ConSX3("QKQ_RESP") VALID CheckSx3("QKQ_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 305,346 MSGET oData08 VAR dData08 SIZE 40,10 OF oScrollBox PIXEL FONT oFont

If !Empty(M->QKQ_CHAVE)
	cChave := M->QKQ_CHAVE
Endif

If nOpc <> 3 .and. nOpc <> 4

	oCombo01:lReadOnly := .T.; oCombo02:lReadOnly := .T.; oCombo03:lReadOnly := .T.; oCombo04:lReadOnly := .T.
	oCombo05:lReadOnly := .T.; oCombo06:lReadOnly := .T.; oCombo07:lReadOnly := .T.; oCombo08:lReadOnly := .T.

	oComent01:lReadOnly := .T.; oComent02:lReadOnly := .T.; oComent03:lReadOnly := .T.; oComent04:lReadOnly := .T.
	oComent05:lReadOnly := .T.; oComent06:lReadOnly := .T.; oComent07:lReadOnly := .T.; oComent08:lReadOnly := .T.

	oData01:lReadOnly := .T.; oData02:lReadOnly := .T.; oData03:lReadOnly := .T.; oData04:lReadOnly := .T.
	oData05:lReadOnly := .T.; oData06:lReadOnly := .T.; oData07:lReadOnly := .T.; oData08:lReadOnly := .T.

Else

	oResp01:lReadOnly := .F.; oResp02:lReadOnly := .F.; oResp03:lReadOnly := .F.; oResp04:lReadOnly := .F.
	oResp05:lReadOnly := .F.; oResp06:lReadOnly := .F.; oResp07:lReadOnly := .F.; oResp08:lReadOnly := .F.

Endif

Return .T.



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QP250TED³ Autor ³ KLAUS DANIEL L CABRAL   ³ Data ³ 03.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para informacoes do ScrollBox apqp 2 Ediçao           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QP250TED(ExpN1, ExpO1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±³          ³ ExpO1 = Dialog       									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QP250TED(nOpc, oDlg)  //--> Segunda Edição APQP

Local oScrollBox := Nil
Local oCombo01, oCombo02, oCombo03, oCombo04                          
Local oCombo05, oCombo06, oCombo07, oCombo08, oCombo09, oCombo10 
Local oComent01, oComent02, oComent03, oComent04
Local oComent05, oComent06, oComent07, oComent08, oComent09, oComent10
Local oData01, oData02, oData03, oData04
Local oData05, oData06, oData07, oData08, oData09, oData10
Local oResp01, oResp02, oResp03, oResp04
Local oResp05, oResp06, oResp07, oResp08, oResp09, oResp10

DEFINE FONT oFont 	 NAME "Arial" SIZE 5.5,12.5
DEFINE FONT oFontTxt NAME "Courier New" SIZE 6,0
DEFINE FONT oFontCou NAME "Courier New" SIZE 5,15

If nOpc <> 3
	QPP250CHEC()
Endif

@ 088,003 MSPANEL oPanel1 PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE 395,012 OF oDlg
@ 004,004 SAY OemToAnsi(STR0010)	COLOR CLR_WHITE SIZE 065,010 OF oPanel1 PIXEL //"Item - Pergunta"
@ 004,135 SAY OemToAnsi(STR0011) 	COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL //"Sim/Nao"
@ 004,155 SAY OemToAnsi("/"+STR0033) 	COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL //"N/a"
@ 004,200 SAY OemToAnsi(STR0012)	COLOR CLR_WHITE SIZE 090,010 OF oPanel1 PIXEL //"Comentarios/Acao Requerida"
@ 004,300 SAY OemToAnsi(STR0013)	COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL //"Responsavel"
@ 004,347 SAY OemToAnsi(STR0014)	COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL //"Dt. Prevista"

oScrollBox := TScrollBox():New(oDlg,103,03,125,395,.T.,.F.,.T.)

@ 001,002 TO 415,142 	OF oScrollBox PIXEL
@ 001,002 TO 415,167 	OF oScrollBox PIXEL
@ 001,002 TO 415,298 	OF oScrollBox PIXEL
@ 001,002 TO 415,345.5  OF oScrollBox PIXEL
@ 001,002 TO 415,385	OF oScrollBox PIXEL

 
// 1a pergunta

@ 005,003 SAY OemToAnsi(STR0034) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"1 -A DFMEA foi preparada utilizando-se o manual de"//
@ 015,003 SAY OemToAnsi(STR0035) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"referência de Análise de Modo e Efeitos de Falha"//
@ 025,003 SAY OemToAnsi(STR0036) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"Potencial (FMEA) da Chrysler, Ford e General Motors"//
@ 035,003 SAY OemToAnsi(STR0037) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"e os requisitos específicos do cliente aplicável?"//

@ 005,144 COMBOBOX oCombo01 VAR cChoice01 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 005,168 GET oComent01 VAR cComent01 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 005,298 MSGET oResp01 VAR cResp01 PICTURE PesqPict("QKQ","QKQ_RESP") ;
						ReadOnly F3 ConSX3("QKQ_RESP") VALID CheckSx3("QKQ_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 005,346 MSGET oData01 VAR dData01 SIZE 40,10 OF oScrollBox PIXEL FONT oFont

@ 045,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 2a pergunta
@ 055,003 SAY OemToAnsi(STR0018) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"2-Foram analisados criticamente dados historicos de"
@ 065,003 SAY OemToAnsi(STR0019) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"  campanhas e garantia ?"

@ 055,144 COMBOBOX oCombo02 VAR cChoice02 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 055,168 GET oComent02 VAR cComent02 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 055,298 MSGET oResp02 VAR cResp02 PICTURE PesqPict("QKQ","QKQ_RESP") ;
						ReadOnly F3 ConSX3("QKQ_RESP") VALID CheckSx3("QKQ_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 055,346 MSGET oData02 VAR dData02 SIZE 40,10 OF oScrollBox PIXEL FONT oFont

@ 085,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 3a pergunta
@ 095,003 SAY OemToAnsi(STR0038) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"3-As Melhores Práticas e lições aprendidas de DFMEA's"//
@ 105,003 SAY OemToAnsi(STR0039) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"similares foram consideradas?"//

@ 095,144 COMBOBOX oCombo03 VAR cChoice03 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 095,168 GET oComent03 VAR cComent03 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 095,298 MSGET oResp03 VAR cResp03 PICTURE PesqPict("QKQ","QKQ_RESP") ;
						ReadOnly F3 ConSX3("QKQ_RESP") VALID CheckSx3("QKQ_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 095,346 MSGET oData03 VAR dData03 SIZE 40,10 OF oScrollBox PIXEL FONT oFont

@ 135,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL


// 4a pergunta
@ 145,003 SAY OemToAnsi(STR0040) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"4-A DFMEA identifica as Caracteristicas Especiais?"//



@ 145,144 COMBOBOX oCombo04 VAR cChoice04 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 145,168 GET oComent04 VAR cComent04 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 145,298 MSGET oResp04 VAR cResp04 PICTURE PesqPict("QKQ","QKQ_RESP") ;
						ReadOnly F3 ConSX3("QKQ_RESP") VALID CheckSx3("QKQ_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 145,346 MSGET oData04 VAR dData04 SIZE 40,10 OF oScrollBox PIXEL FONT oFont

@ 170,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 5a pergunta
@ 180,003 SAY OemToAnsi(STR0041) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"5-As Caracteristicas de repasse (glossário) foram"//
@ 190,003 SAY OemToAnsi(STR0042) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"identificadas e analisadas criticamente com os"//
@ 200,003 SAY OemToAnsi(STR0043) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"fornecedores afetados quanto ao alinhamento da"//
@ 210,003 SAY OemToAnsi(STR0044) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"FMEA e controles apropriados na base de Fornecimento?"//

@ 180,144 COMBOBOX oCombo05 VAR cChoice05 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 180,168 GET oComent05 VAR cComent05 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 180,298 MSGET oResp05 VAR cResp05 PICTURE PesqPict("QKQ","QKQ_RESP") ;
						ReadOnly F3 ConSX3("QKQ_RESP") VALID CheckSx3("QKQ_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 175,346 MSGET oData05 VAR dData05 SIZE 40,10 OF oScrollBox PIXEL FONT oFont

@ 215,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 6a pergunta
@ 225,003 SAY OemToAnsi(STR0045) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"6-As Características especiais designadas pelo cliente "//
@ 235,003 SAY OemToAnsi(STR0046) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"ou organização foram analisadas criticamente"//
@ 245,003 SAY OemToAnsi(STR0047) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"com os fornecedores afetados para assegurar o "//


@ 225,144 COMBOBOX oCombo06 VAR cChoice06 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 225,168 GET oComent06 VAR cComent06 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 225,298 MSGET oResp06 VAR cResp06 PICTURE PesqPict("QKQ","QKQ_RESP") ;
						ReadOnly F3 ConSX3("QKQ_RESP") VALID CheckSx3("QKQ_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 225,346 MSGET oData06 VAR dData06 SIZE 40,10 OF oScrollBox PIXEL FONT oFont

@ 255,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL


// 7a pergunta
@ 265,003 SAY OemToAnsi(STR0049) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"7-As características de projeto que afetam os modos de"//
@ 275,003 SAY OemToAnsi(STR0050) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"falha de prioridade de risco elevado foram identificadas?"//

@ 265,144 COMBOBOX oCombo07 VAR cChoice07 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 265,168 GET oComent07 VAR cComent07 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 265,298 MSGET oResp07 VAR cResp07 PICTURE PesqPict("QKQ","QKQ_RESP") ;
						ReadOnly F3 ConSX3("QKQ_RESP") VALID CheckSx3("QKQ_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 265,346 MSGET oData07 VAR dData07 SIZE 40,10 OF oScrollBox PIXEL FONT oFont

@ 295,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 8a pergunta
@ 305,003 SAY OemToAnsi(STR0051) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"8-Foram designadas ações corretivas apropriadas para"//
@ 315,003 SAY OemToAnsi(STR0052) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"os numeros de prioridade de risco elevado?"//

@ 305,144 COMBOBOX oCombo08 VAR cChoice08 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 305,168 GET oComent08 VAR cComent08 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 305,298 MSGET oResp08 VAR cResp08 PICTURE PesqPict("QKQ","QKQ_RESP") ;
						ReadOnly F3 ConSX3("QKQ_RESP") VALID CheckSx3("QKQ_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 305,346 MSGET oData08 VAR dData08 SIZE 40,10 OF oScrollBox PIXEL FONT oFont 

@ 338,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL


// 9a pergunta
@ 345,003 SAY OemToAnsi(STR0056) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"9-Foram designadas ações corretivas apropriadas para"  //
@ 355,003 SAY OemToAnsi(STR0053) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"os numero de severidade elevada?"//

@ 345,144 COMBOBOX oCombo09 VAR cChoice09 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 345,168 GET oComent09 VAR cComent09 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 345,298 MSGET oResp09 VAR cResp09 PICTURE PesqPict("QKQ","QKQ_RESP") ;
						ReadOnly F3 ConSX3("QKQ_RESP") VALID CheckSx3("QKQ_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 345,346 MSGET oData09 VAR dData09 SIZE 40,10 OF oScrollBox PIXEL FONT oFont  

@ 375,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

// 10a pergunta
@ 385,003 SAY OemToAnsi(STR0054) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"10-As prioridades de risco foram revistas após as"//
@ 395,003 SAY OemToAnsi(STR0055) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"ações corretivas serem concluídas e verificadas?"//

@ 385,144 COMBOBOX oCombo10 VAR cChoice10 ITEMS aItems SIZE 022,010 OF oScrollBox PIXEL FONT oFont
@ 385,168 GET oComent10 VAR cComent10 MEMO NO VSCROLL SIZE 128, 030 OF oScrollBox PIXEL FONT oFontTxt
@ 385,298 MSGET oResp10 VAR cResp10 PICTURE PesqPict("QKQ","QKQ_RESP") ;
						ReadOnly F3 ConSX3("QKQ_RESP") VALID CheckSx3("QKQ_RESP") SIZE 35,10 OF oScrollBox PIXEL FONT oFont

@ 385,346 MSGET oData10 VAR dData10 SIZE 40,10 OF oScrollBox PIXEL FONT oFont

@ 425,002 SAY Replicate(OemToAnsi("_"),150) SIZE 385,007 OF oScrollBox PIXEL

If !Empty(M->QKQ_CHAVE)
	cChave := M->QKQ_CHAVE
Endif

If nOpc <> 3 .and. nOpc <> 4

	oCombo01:lReadOnly := .T.; oCombo02:lReadOnly := .T.; oCombo03:lReadOnly := .T.; oCombo04:lReadOnly := .T.
	oCombo05:lReadOnly := .T.; oCombo06:lReadOnly := .T.; oCombo07:lReadOnly := .T.; oCombo08:lReadOnly := .T.
	oCombo09:lReadOnly := .T.; oCombo10:lReadOnly := .T.

	oComent01:lReadOnly := .T.; oComent02:lReadOnly := .T.; oComent03:lReadOnly := .T.; oComent04:lReadOnly := .T.
	oComent05:lReadOnly := .T.; oComent06:lReadOnly := .T.; oComent07:lReadOnly := .T.; oComent08:lReadOnly := .T.
	oComent09:lReadOnly := .T.; oComent10:lReadOnly := .T.

	oData01:lReadOnly := .T.; oData02:lReadOnly := .T.; oData03:lReadOnly := .T.; oData04:lReadOnly := .T.
	oData05:lReadOnly := .T.; oData06:lReadOnly := .T.; oData07:lReadOnly := .T.; oData08:lReadOnly := .T.
	oData09:lReadOnly := .T.; oData10:lReadOnly := .T.

Else

	oResp01:lReadOnly := .F.; oResp02:lReadOnly := .F.; oResp03:lReadOnly := .F.; oResp04:lReadOnly := .F.
	oResp05:lReadOnly := .F.; oResp06:lReadOnly := .F.; oResp07:lReadOnly := .F.; oResp08:lReadOnly := .F.
	oResp09:lReadOnly := .F.;oResp10:lReadOnly := .F.

Endif

Return .T.  



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP250Chec³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 09.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza conteudo das Variaveis                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP250Chec()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP250Chec()

Local nTamLin 	:= 38 // Tamanho da linha do texto
Local cEspecie 	:= "PPA250"
Local nSeq
Local aArea		:= {}

aArea := GetArea()

DbSelectArea("QKQ")
DbSetOrder(1)
DbSeek(xFilial("QKQ")+M->QKQ_PECA+M->QKQ_REV+"01")

Do While xFilial("QKQ")+M->QKQ_PECA+M->QKQ_REV == QKQ->QKQ_FILIAL+QKQ->QKQ_PECA+QKQ->QKQ_REV ;
			.and. !Eof()
	
	nSeq := QKQ->QKQ_NPERG
	
	cChoice&(nSeq)	:= Iif(QKQ_RPOSTA == "1", aItems[1],(Iif(QKQ_RPOSTA == "2", aItems[2],aItems[3])))
	dData&(nSeq)	:= QKQ->QKQ_DTPREV
	cResp&(nSeq)	:= QKQ->QKQ_RESP

	If !Empty(QKQ->QKQ_CHAVE)
		cComent&(nSeq) := QO_Rectxt(M->QKQ_CHAVE,cEspecie+nSeq,1, nTamLin,"QKO")
	Endif
		
	DbSelectArea("QKQ")
	DbSkip()

Enddo

RestArea(aArea)

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA250Grav³ Autor ³ Robson Ramiro A Olivei³ Data ³ 08.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Gravacao Checklist APQP - A1 DFMEA-Incl./Alter.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA250Grav(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA250Grav(nOpc)

Local nCont, nRec
Local bCampo	:= { |nCPO| Field(nCPO) }
Local lGraOk	:= .T.
Local nTamLin	:= 38
Local cEspecie	:= "PPA250"
Local nSeq
Local nSaveSX8	:= GetSX8Len()
Local lMVQAPQPED := GetMV("MV_QAPQPED",.T.,"1") == "1"

DbSelectArea("QKQ")
	
Begin Transaction

// Verifica se existe texto antes de criar chave
If Empty(cChave)

	cChave := GetSXENum("QKQ", "QKQ_CHAVE",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End
	
Endif

DbSelectArea("QKQ")
DbSetOrder(1)

For nRec := 1 To  Iif(lMVQAPQPED,8,10)// 8 ou 10  perguntas
	
	nSeq := StrZero(nRec,2)

	If ALTERA
		If DbSeek(xFilial("QKQ")+M->QKQ_PECA+M->QKQ_REV+nSeq)
			RecLock("QKQ",.F.)
		Else
			RecLock("QKQ",.T.)
		Endif
	Else
		RecLock("QKQ",.T.)
	Endif

	For nCont := 1 To FCount()
		If "FILIAL"$Field(nCont)
			FieldPut(nCont,xFilial("QKQ"))
		Else
			FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
		Endif
	Next nCont

	QKQ->QKQ_REVINV	:= Inverte(M->QKQ_REV)
	QKQ->QKQ_NPERG	:= nSeq
	QKQ->QKQ_RPOSTA	:= Iif(cChoice&(nSeq) == STR0007,"1",Iif(cChoice&(nSeq) == STR0008,"2", "3") ) //"Sim"###"NAO"###"N/A"    
	QKQ->QKQ_DTPREV	:= &("dData"+Padr(nSeq,2))
	QKQ->QKQ_RESP	:= &("cResp"+Padr(nSeq,2))
	QKQ->QKQ_FILRES	:= cFilAnt
	QKQ->QKQ_CHAVE	:= cChave

	If !Empty(cComent&(nSeq))
		aComent&(nSeq) := GeraText(nTamLin, cComent&(nSeq))
		QO_GrvTxt(cChave,cEspecie+nSeq,1,@aComent&(nSeq))
	Endif
	
	DbSelectArea("QKQ")

Next nRec
	
MsUnLock()

End Transaction

			
Return lGraOk

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PP250TudOk ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 08.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para inclusao/alteracao geral                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP250TudOk                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QPPA250                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PP250TudOk

Local lRetorno	:= .T.

If Empty(M->QKQ_PECA) .or. Empty(M->QKQ_REV)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
Endif

If INCLUI
	If !ExistChav("QKQ",M->QKQ_PECA+M->QKQ_REV)
		lRetorno := .F.
		Help(" ",1,"JAGRAVADO")  // Campo ja Existe
	Endif
	If !ExistCpo("QK1",M->QKQ_PECA+M->QKQ_REV)
		lRetorno := .F.
		Help(" ",1,"REGNOIS")  // Nao existe amarracao
	Endif
Endif

Return lRetorno


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A250Dele ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 09.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fucao para exclusao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A250Dele()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A250Dele()

Local cEspecie := "PPA250"
Local nSeq, nRec, cKey
Local aArqRec := {}
Local lMVQAPQPED := GetMV("MV_QAPQPED",.T.,"1") == "1"

DbSelectArea("QKQ")
DbSeek(xFilial("QKQ")+M->QKQ_PECA+M->QKQ_REV+"01")

cKey := QKQ->QKQ_CHAVE

Do While xFilial("QKQ")+M->QKQ_PECA+M->QKQ_REV == QKQ->QKQ_FILIAL+QKQ->QKQ_PECA+QKQ->QKQ_REV ;
			.and. !Eof()

	aAdd(aArqRec, Recno())  //alimenta array com os enderecos a serem deletados
	DbSkip()
Enddo

Begin Transaction

If Len(aArqRec) > 0

	For nRec := 1 To Iif(lMVQAPQPED,8,10)// 8 ou 10  perguntas

		nSeq := StrZero(nRec,2)

		If !Empty(cKey)
			QO_DelTxt(cKey,cEspecie+nSeq) //QPPXFUN
		Endif
	 
		DbSelectArea("QKQ")
		DbGoTo(aArqRec[nRec])
		RecLock("QKQ",.F.)
		DbDelete()

	Next nRec

Endif

MsUnLock()
		
End Transaction

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GeraText  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 05.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Transformacao do campo memo em array para gravacao no QKO  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GeraText(ExpN1,ExpN2,ExpC1)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Tamanho da linha 								  ³±±
±±³          ³ ExpC1 = String a ser convertida 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function GeraText(nTamlin, cVar)

Local cDescricao
Local nLinTotal
Local nPasso
Local axTextos := {}
Local nLi
Local nPos

cDescricao := ""
	
nLinTotal  := MlCount(cVar, nTamLin)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza vetor com o texto digitado		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nPasso := 1 to nLinTotal
	cDescricao += MemoLine( cVar, nTamLin, nPasso ) + Chr(13)+Chr(10)
Next nPasso
		
nLi := 1

nPos := aScan(axTextos, {|x| x[1] == nLi })

If nPos == 0
	Aadd(axTextos, { nLi, cDescricao } )
Else
	axTextos[nPos][2] := cDescricao
Endif

Return(axTextos)