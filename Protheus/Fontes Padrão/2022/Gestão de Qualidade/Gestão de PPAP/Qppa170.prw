#INCLUDE "TOTVS.CH"
#INCLUDE "QPPA170.CH"
#INCLUDE "PROTHEUS.CH"


#DEFINE NORMAL "1"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA170  ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 06.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Estudo de Capabilidade                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA170(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPPAP                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Robson Ramiro³20/02/02³VERSAO³ Efetuado os ajustes 609 x 710          ³±±
±±³ Robson Ramiro³21/03/02³META  ³ Alteracao para que permita o estudo de ³±±
±±³              ³        ³      ³ mais que uma caracteristica da peca    ³±±
±±³ Robson Ramiro³06/09/02³xMETA ³ Troca da QA_CVKEY por GetSXENum        ³±±
±±³ Robson Ramiro³11/02/03³      ³ Implementacao de graficos              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := { 	{ OemToAnsi(STR0007), "AxPesqui"  ,		0, 1,,.F.},;  	//"Pesquisar"
					{ OemToAnsi(STR0008), "PPA170Visu",		0, 2},;		  	//"Visualizar"
					{ OemToAnsi(STR0009), "PPA170Incl", 	0, 3},;		  	//"Incluir"
					{ OemToAnsi(STR0010), "PPA170Alte", 	0, 4},;		  	//"Alterar"
					{ OemToAnsi(STR0011), "PPA170Excl", 	0, 5},;		  	//"Excluir"
					{ OemToAnsi(STR0005), "PPA170Resu", 	0, 6},;		 	//"Resultados"
					{ OemToAnsi(STR0039), "PPA170SPC",		0, 7},;		 	//"Graficos"
					{ OemToAnsi(STR0038), "QPPR170(.T.)",	0, 8,,.T.} } 	//"Imprimir"

Return aRotina

Function QPPA170
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0001) //"Estudo de Capabilidadade"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o tabela de constantes do Apendice E                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTable := {}
Private lExistChart  := FindFunction("QIEMGRAFIC") .AND. GetBuild() >= "7.00.170117A"

//                       D4       A2      d2
aTable := {		{ "1", "0,00", "0,00", "0,00"	},;
				{ "2", "3,27", "1,88", "1.128"	},;
				{ "3", "2,57", "1,02", "1.693"	},;
				{ "4", "2,28", "0,73", "2.059"	},;
				{ "5", "2,11", "0,58", "2.326"	} }

Private lSeq	:= .T.

Private aRotina := MenuDef()


DbSelectArea("QK9")
DbSetOrder(1)

mBrowse( 6, 1, 22, 75,"QK9",,,,,,)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA170Visu  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³06.08.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Visualizacao                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA170Visu(ExpC1,ExpN1,ExpN2)                           ³±±
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
Function PPA170Visu(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local aCposVis	:= {}
Local aButtons	:= {}
Local oPanel1
Local oPanel2
Local oSize
Local oEnch

Private aHeader	:= {}
Private aCols	:= {}
Private nUsado	:=	0
Private oGet	:= NIL

DbSelectArea(cAlias)

aCposVis := {	"QK9_PECA"	, "QK9_REV"		, "QK9_DTEST"	,;
				"QK9_REAPOR", "QK9_RESP"	,"QK9_DISP"		,;
				"QK9_DATA"	, "QK9_CARAC"	, "QK9_OPERAC"	,;
				"QK9_CARAC"	, "QK9_OPERAC"	, "QK9_DESCAR"	,;
				"QK9_DESOPE", "QK9_TIPOM"	, "QK9_TAMSUB" }

aCposAlt := {	"QK9_PECA"	, "QK9_REV"		, "QK9_DTEST"	,;
				"QK9_REAPOR", "QK9_CARAC"	, "QK9_OPERAC"	,;
				"QK9_CARAC"	, "QK9_OPERAC"	, "QK9_DESCAR"	,;
				"QK9_DESOPE", "QK9_TIPOM"	, "QK9_TAMSUB" }

If lSeq
	aAdd(aCposAlt, "QK9_SEQ")
	aAdd(aCposVis, "QK9_SEQ")
	aAdd(aCposAlt, "QK9_CAVMOL")
	aAdd(aCposVis, "QK9_CAVMOL")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New( .F. )

oSize:AddObject( "CIMA"  ,  100,  40, .T., .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "BAIXO",  100, 60, .T., .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) ;  //"Estudo de Capabilidadade"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

RegToMemory("QK9")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona Panel                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel1:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[1,3])
oPanel2:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[2,3])

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnch:=MsMGet():New("QK9",nReg,nOpc, , , ,aCposVis,oSize:aPosObj[1],aCposAlt,,,,,oPanel1,,,,,,,,,)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PP170Ahead("QKA")

nUsado	:= Len(aHeader)

PP170Acols(nOpc)

aButtons := {  {"RELATORIO", 	{ || QPP170OBSE(nOpc) },	OemToAnsi(STR0002), OemToAnsi(STR0044)},;	//"Observacoes"###"Obs"
				{"EDIT",		{ || QPP170APRO(nOpc) },	OemToAnsi(STR0003), OemToAnsi(STR0045)},; 	//"Aprovar / Rejeitar"###"Apro/Rej"
				{"note",		{ || QPP170LIMP(nOpc) },	OemToAnsi(STR0004), OemToAnsi(STR0004)},; 	//"Apagar"
				{"FORM",		{ || PPA170RESU(nOpc) },	OemToAnsi(STR0005), OemToAnsi(STR0046)},; 	//"Resultados"###"Result"
				{"LINE",		{ || PPA170SPC()      },	OemToAnsi(STR0039), OemToAnsi(STR0039)},; 	//"Graficos"
				{"BMPVISUAL", 	{ || QPPR170() },			OemToAnsi(STR0037), OemToAnsi(STR0047) }} 	//"Visualizar/Imprimir"###"Vis/Prn"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet:= MSGetDados():New(90,03,190,332, nOpc,"AllwaysTrue","AllwaysTrue","+QKA_ITEM",.T.,,,,,,,,,oPanel2)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}, , aButtons) CENTERED

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA170Incl  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³23.07.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Inclusao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA170Incl(ExpC1,ExpN1,ExpN2)                           ³±±
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
Function PPA170Incl(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local lOk 		:= .F.
Local aCposVis	:= {}
Local aButtons	:= {}
Local oPanel1
Local oPanel2
Local oSize
Local oEnch

Private aHeader	:= {}
Private aCols	:= {}
Private nUsado	:=	0
Private oGet	:= NIL

DbSelectArea(cAlias)

aCposVis := {	"QK9_PECA"	, "QK9_REV"		, "QK9_DTEST"	,;
				"QK9_REAPOR", "QK9_RESP"	, "QK9_DISP"	,;
				"QK9_DATA"	, "QK9_CARAC"	, "QK9_OPERAC"	,;
				"QK9_CARAC"	, "QK9_OPERAC"	, "QK9_DESCAR"	,;
				"QK9_DESOPE", "QK9_TIPOM"	, "QK9_TAMSUB" }

aCposAlt := {	"QK9_PECA"	, "QK9_REV"		, "QK9_DTEST"	,;
				"QK9_REAPOR", "QK9_CARAC"	, "QK9_OPERAC"	,;
				"QK9_CARAC"	, "QK9_OPERAC"	, "QK9_DESCAR"	,;
				"QK9_DESOPE", "QK9_TIPOM"	, "QK9_TAMSUB" }

If lSeq
	aAdd(aCposAlt, "QK9_SEQ")
	aAdd(aCposVis, "QK9_SEQ")
	aAdd(aCposAlt, "QK9_CAVMOL")
	aAdd(aCposVis, "QK9_CAVMOL")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New( .F. )

oSize:AddObject( "CIMA"  ,  100,  40, .T., .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "BAIXO",  100, 60, .T., .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) ;  //"Estudo de Capabilidadade"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

RegToMemory("QK9",.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona Panel                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel1:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[1,3])
oPanel2:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[2,3])

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnch:=MsMGet():New("QK9",nReg,nOpc, , , ,aCposVis,oSize:aPosObj[1],aCposAlt,,,,,oPanel1,,,,,,,,,)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PP170Ahead("QKA")

nUsado	:= Len(aHeader)

PP170Acols(nOpc)

aButtons := {  {"RELATORIO", 	{ || QPP170OBSE(nOpc) },	OemToAnsi(STR0002), OemToAnsi(STR0044)},;	//"Observacoes"###"Obs"
				{"EDIT",		{ || QPP170APRO(nOpc) },	OemToAnsi(STR0003), OemToAnsi(STR0045)},; 	//"Aprovar / Rejeitar"###"Apro/Rej"
				{"note",		{ || QPP170LIMP(nOpc) },	OemToAnsi(STR0004), OemToAnsi(STR0004)}} 	//"Apagar"

DbSelectArea("QKA")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet := MSGetDados():New(90,03,190,332, nOpc,"PP170LinOk","PP170TudOk","+QKA_ITEM",.T.,,,,,,,,,oPanel2)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP170TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

If lOk
	A170Grav(nOpc)
Endif

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA170Alte  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³06.08.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Alteracao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA170Alte(ExpC1,ExpN1,ExpN2)                           ³±±
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
Function PPA170Alte(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local lOk 		:= .F.
Local aCposVis	:= {}
Local aButtons	:= {}
Local oPanel1
Local oPanel2
Local oSize
Local oEnch

Private aHeader	:= {}
Private aCols	:= {}
Private nUsado	:=	0
Private oGet	:= NIL

If !QPPVldAlt(QK9->QK9_PECA,QK9->QK9_REV,QK9->QK9_RESP)
	Return
Endif

DbSelectArea(cAlias)

aCposVis := {	"QK9_PECA"	, "QK9_REV"		, "QK9_DTEST"	,;
				"QK9_REAPOR", "QK9_RESP"	,"QK9_DISP"		,;
				"QK9_DATA"	, "QK9_CARAC"	, "QK9_OPERAC"	,;
				"QK9_CARAC"	, "QK9_OPERAC"	, "QK9_DESCAR"	,;
				"QK9_DESOPE", "QK9_TIPOM"	, "QK9_TAMSUB" }

aCposAlt := {	"QK9_DTEST"	,;
				"QK9_REAPOR", "QK9_CARAC"	, "QK9_OPERAC"	,;
				"QK9_CARAC"	, "QK9_OPERAC"	, "QK9_DESCAR"	,;
				"QK9_DESOPE", "QK9_TIPOM"	, "QK9_TAMSUB" }

If lSeq
	aAdd(aCposVis, "QK9_SEQ")
	aAdd(aCposAlt, "QK9_CAVMOL")
	aAdd(aCposVis, "QK9_CAVMOL")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New( .F. )

oSize:AddObject( "CIMA"  ,  100,  40, .T., .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "BAIXO",  100, 60, .T., .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) ;  //"Estudo de Capabilidadade"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

RegToMemory("QK9",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona Panel                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel1:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[1,3])
oPanel2:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[2,3])

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnch:=MsMGet():New("QK9",nReg,nOpc, , , ,aCposVis,oSize:aPosObj[1],aCposAlt,,,,,oPanel1,,,,,,,,,)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PP170Ahead("QKA")

nUsado	:= Len(aHeader)

PP170Acols(nOpc)

DbSelectArea("QKA")

aButtons := {  {"RELATORIO", 	{ || QPP170OBSE(nOpc) },	OemToAnsi(STR0002), OemToAnsi(STR0044)},;	//"Observacoes"###"Obs"
				{"EDIT",		{ || QPP170APRO(nOpc) },	OemToAnsi(STR0003), OemToAnsi(STR0045)},;	//"Aprovar / Rejeitar"###"Apro/Rej"
				{"note",		{ || QPP170LIMP(nOpc) },	OemToAnsi(STR0004), OemToAnsi(STR0004)}} 	//"Apagar"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet := MSGetDados():New(90,03,190,332, nOpc,"PP170LinOk","PP170TudOk","+QKA_ITEM",.T.,,,,,,,,,oPanel2)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP170TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

If lOk
	A170Grav(nOpc)
Endif

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA170Excl  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³06.08.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Exclusao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA170Excl(ExpC1,ExpN1,ExpN2)                                ³±±
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
Function PPA170Excl(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local aCposVis	:= {}
Local aButtons	:= {}
Local oPanel1
Local oPanel2
Local oSize
Local oEnch

Private aHeader	:= {}
Private aCols	:= {}
Private nUsado	:=	0
Private oGet	:= NIL  

If !QPPVldExc(QK9->QK9_REV,QK9->QK9_RESP)
	Return
Endif


DbSelectArea(cAlias)

aCposVis := {	"QK9_PECA"	, "QK9_REV"		, "QK9_DTEST"	,;
				"QK9_REAPOR", "QK9_RESP"	,"QK9_DISP"		,;
				"QK9_DATA"	, "QK9_CARAC"	, "QK9_OPERAC"	,;
				"QK9_CARAC"	, "QK9_OPERAC"	, "QK9_DESCAR"	,;
				"QK9_DESOPE", "QK9_TIPOM"	, "QK9_TAMSUB" }

aCposAlt := {	"QK9_PECA"	, "QK9_REV"		, "QK9_DTEST"	,;
				"QK9_REAPOR", "QK9_CARAC"	, "QK9_OPERAC"	,;
				"QK9_CARAC"	, "QK9_OPERAC"	, "QK9_DESCAR"	,;
				"QK9_DESOPE", "QK9_TIPOM"	, "QK9_TAMSUB" }

If lSeq
	aAdd(aCposAlt, "QK9_SEQ")
	aAdd(aCposVis, "QK9_SEQ")
	aAdd(aCposAlt, "QK9_CAVMOL")
	aAdd(aCposVis, "QK9_CAVMOL")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New( .F. )

oSize:AddObject( "CIMA"  ,  100,  40, .T., .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "BAIXO",  100, 60, .T., .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) ;  //"Estudo de Capabilidadade"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
RegToMemory("QK9")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona Panel                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel1:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[1,3])
oPanel2:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[2,3])

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnch:=MsMGet():New("QK9",nReg,nOpc, , , ,aCposVis,oSize:aPosObj[1],aCposAlt,,,,,oPanel1,,,,,,,,,)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PP170Ahead("QKA")

nUsado	:= Len(aHeader)

PP170Acols(nOpc)

aButtons := {  {"RELATORIO", 	{ || QPP170OBSE(nOpc) },	OemToAnsi(STR0002), OemToAnsi(STR0044)},;	//"Observacoes"###"Obs"
				{"EDIT",		{ || QPP170APRO(nOpc) },	OemToAnsi(STR0003), OemToAnsi(STR0045)},; 	//"Aprovar / Rejeitar"###"Apro/Rej"
				{"NOTE",		{ || QPP170LIMP(nOpc) },	OemToAnsi(STR0004), OemToAnsi(STR0004)},; 	//"Apagar"
				{"FORM",		{ || PPA170RESU(nOpc) },	OemToAnsi(STR0005), OemToAnsi(STR0046)},; 	//"Resultados"###"Result"
				{"LINE",		{ || PPA170SPC()      },	OemToAnsi(STR0039), OemToAnsi(STR0039)},; 	//"Graficos"
				{"BMPVISUAL", 	{ || QPPR170() },			OemToAnsi(STR0037), OemToAnsi(STR0047) }} 	//"Visualizar/Imprimir"###"Vis/Prn"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
oGet := MSGetDados():New(90,03,190,332, nOpc,"AllwaysTrue","AllwaysTrue","+QKA_ITEM",.T.,,,,,,,,,oPanel2)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| A170Dele(),oDlg:End()},{||oDlg:End()}, , aButtons) CENTERED

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³PP170Acols³ Autor ³ Robson Ramiro A. Olive³ Data ³ 06.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega vetor aCols para a GetDados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q010Acols()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PP170Acols(nOpc)
Local nI, nPos, cCond

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols               					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpc == 3
	
	aCols := Array(1,nUsado+1)
	
	For nI = 1 To Len(aHeader)
		If aHeader[nI,8] == "C"
			aCols[1,nI] := Space(aHeader[nI,4])
		ElseIf aHeader[nI,8] == "N"
			aCols[1,nI] := 0
		ElseIf aHeader[nI,8] == "D"
			aCols[1,nI] := dDataBase
		ElseIf aHeader[nI,8] == "M"
			aCols[1,nI] := ""
		Else
			aCols[1,nI] := .F.
		Endif
	Next nI
	
	nPos			:= aScan(aHeader,{ |x| AllTrim(x[2])== "QKA_ITEM" })
	aCols[1,nPos]	:= StrZero(1,Len(aCols[1,nPos]))
	
	aCols[1,nUsado+1] := .F.
	
Else
	
	DbSelectArea("QKA")
	DbSetOrder(1)

	If lSeq
		DbSeek(xFilial()+QK9->QK9_PECA+QK9->QK9_REV+QK9->QK9_CARAC+QK9->QK9_SEQ)
		cCond := "QKA->QKA_PECA+QKA->QKA_REV+QKA->QKA_CARAC+QKA->QKA_SEQ == QK9->QK9_PECA+QK9->QK9_REV+QK9->QK9_CARAC+QK9->QK9_SEQ"
	Else
		DbSeek(xFilial()+QK9->QK9_PECA+QK9->QK9_REV+QK9->QK9_CARAC)
		cCond := "QKA->QKA_PECA+QKA->QKA_REV+QKA->QKA_CARAC == QK9->QK9_PECA+QK9->QK9_REV+QK9->QK9_CARAC"  //AQUI
	Endif

	Do While QKA->(!Eof()) .and. xFilial("QKA") == QK9->QK9_FILIAL .and. &cCond
		
		aAdd(aCols,Array(nUsado+1))
		
		For nI := 1 to nUsado
			
			If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
				aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
			Else										// Campo Virtual
				cCpo := AllTrim(Upper(aHeader[nI,2]))
				aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
			Endif
			
		Next nI
		
		aCols[Len(aCols),nUsado+1] := .F.
		
		DbSkip()
		
	Enddo
	
Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PP170Ahead³ Autor ³ Robson Ramiro A. Olive³ Data ³ 06.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Ahead para aCols                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP170Ahead()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PP170Ahead(cAlias)

Local aStruAlias := FWFormStruct(3, cAlias)[3]
Local nX

aHeader := {}
nUsado 	:= 0

For nX := 1 To Len(aStruAlias)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ignora campos que nao devem aparecer na getdados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  Upper(AllTrim(aStruAlias[nX,1])) == "QKA_PECA" 	.or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKA_REV" 	.or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKA_CARAC"
		Loop
	Endif
	
	If cNivel >= GetSX3Cache(aStruAlias[nX,1],"X3_NIVEL")
		nUsado++
 		aAdd(aHeader,{ Trim(QAGetX3Tit(aStruAlias[nX,1])),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_CAMPO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_PICTURE'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_TAMANHO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_DECIMAL'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_VALID'),;              
		              GetSx3Cache(aStruAlias[nX,1],'X3_USADO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_TIPO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_ARQUIVO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_CONTEXT')})
	Endif	
Next nX 

Return



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A170Grav ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 06.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Gravacao - Incl./Alter.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A170Grav(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A170Grav(nOpc)

Local nIt
Local nCont
Local nNumItem
Local nPosDel 		:= Len(aHeader) + 1
Local nCpo
Local bCampo		:= { |nCPO| Field(nCPO) }
Local lGraOk 		:= .T.   // Indica se todas as gravacoes obtiveram sucesso
Local nPosAmos1  	:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKA_AMOS1"  })
Local nPosMedia  	:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKA_MEDIA"  })
Local nPosAmpli  	:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKA_AMPLI"  })
Local cAtividade	:= "07 " 	// Definido no ID - QKZ
Local cMaior		:= " " 		// Maior Valor
Local cMenor		:= " "		// Menor Valor
Local nTOL			:= 0 		// Nominal
Local nLIE			:= 0		// Afastamento Inferior
Local nLSE			:= 0		// Afastamento Superior
Local nPtosFora		:= 0 		// Numero de Pontos Fora das Especificacoes
Local nPtosForaMed	:= 0 		// Numero de Medias Fora dos LC
Local nPtosForaAmp 	:= 0 		// Numero de Amplitudes Fora dos LC
Local nXBB			:= 0		// Media das Medias
Local nRB			:= 0		// Media das Amplitudes
Local nValTab		:= 0		// Valor de referencia da Tabela do Apendice E
Local nPos			:= aScan( aTable, { |X| X[1] == M->QK9_TAMSUB }) // Posicao na tabela
Local nCP			:= 0
Local nCPK1			:= 0		// Para apuracao do Minimo entre os CPK's
Local nCPK2			:= 0   		// idem
Local nDesvDes		:= 0		// Desvio padrao do Desempenho
Local nPP			:= 0
Local nPPK1			:= 0		// Para apuracao do Minimo entre os CPK's
Local nPPK2			:= 0   		// idem
Local nQU			:= 0		// Quarter Upper - Metodo InterQuartil
Local nQL			:= 0		// Quarter Lower
Local nIQR			:= 0		// Resultado Interquartil
Local aIQR			:= {} 		// Array para verificacao do metodo Interquartil
Local cCond

DbSelectArea("QK2")
DbSetOrder(2)
If DbSeek(xFilial("QK2") + M->QK9_PECA + M->QK9_REV + M->QK9_CARAC)
	nTOL := SuperVal(QK2_TOL)
	nLIE := SuperVal(QK2_LIE)
	nLSE := SuperVal(QK2_LSE)
Endif

Begin Transaction

DbSelectArea("QK9")
DbSetOrder(1)

If INCLUI
	RecLock("QK9",.T.)
Else
	RecLock("QK9",.F.)
Endif

For nCont := 1 To FCount()
	
	If "FILIAL"$Field(nCont)
		FieldPut(nCont,xFilial("QK9"))
	Else
		FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
	Endif
	
Next nCont

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos nao informados                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QK9->QK9_REVINV := Inverte(QK9->QK9_REV)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Zera valores para nova apuracao                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QK9->QK9_MENMED	:= " "
QK9->QK9_MAIMED	:= " "

MsUnLock()
FKCOMMIT()

If !Empty(QK9->QK9_DATA) .and. !Empty(QK9->QK9_RESP)
	QPP_CRONO(QK9->QK9_PECA,QK9->QK9_REV,cAtividade) // QPPXFUN - Atualiza Cronograma
Endif

DbSelectArea("QKA")
DbSetOrder(1)

nNumItem := 1  // Contador para os Itens

If lSeq
	cCond := xFilial("QKA")+ M->QK9_PECA + M->QK9_REV + M->QK9_CARAC + M->QK9_SEQ
Else
	cCond := xFilial("QKA")+ M->QK9_PECA + M->QK9_REV + M->QK9_CARAC  //AQUI
Endif

For nIt := 1 To Len(aCols)
	
	If !aCols[nIt, nPosDel] .and. !Empty(aCols[nIt,nPosAmos1])  // Verifica se o item foi deletado
		
		If ALTERA
			
			If DbSeek(cCond + StrZero(nIt,2))
				RecLock("QKA",.F.)
			Else
				RecLock("QKA",.T.)
			Endif
		Else
			RecLock("QKA",.T.)
		Endif
		
		For nCpo := 1 To Len(aHeader)
			If aHeader[nCpo, 10] <> "V"
				QKA->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
			Endif
			
			// Identifica o Menor e Maior Valor Informado, e ptos fora das especificacoes
			If Subs(AllTrim(aHeader[nCpo, 2]),1,8) == "QKA_AMOS" .and. nCPO <= (Val(M->QK9_TAMSUB) + 1)
				
				If SuperVal(aCols[nIt, nCpo]) > (nTOL + nLSE) .or. ;
					SuperVal(aCols[nIt, nCpo]) < (nTOL + nLIE)
					
					nPtosFora++
				Endif
				
				If SuperVal(aCols[nIt, nCpo]) > SuperVal(cMaior)
					cMaior := aCols[nIt, nCpo]
				Endif
				
				If SuperVal(aCols[nIt, nCpo]) < SuperVal(cMenor) .or. SuperVal(cMenor) == 0
					cMenor := aCols[nIt, nCpo]
				Endif
			Endif
			
		Next nCpo
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Campos Chave nao informados                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QKA->QKA_FILIAL	:= xFilial("QKA")
		QKA->QKA_PECA	:= M->QK9_PECA
		QKA->QKA_REV	:= M->QK9_REV
		QKA->QKA_CARAC	:= M->QK9_CARAC
		QKA->QKA_REVINV	:= Inverte(QK9->QK9_REV)
		
		If lSeq
			QKA->QKA_SEQ := M->QK9_SEQ
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle de itens do acols                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QKA->QKA_ITEM := StrZero(nNumItem,2)
		
		nNumItem++
		
		MsUnlock()    
		FKCOMMIT()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Media (das Medias / Amplitude)                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nXBB := nXBB + SuperVal(QKA->QKA_MEDIA)
		nRB  := nRB + SuperVal(QKA->QKA_AMPLI)
		
		DbSelectArea("QK9")
		RecLock("QK9",.F.)
		QK9->QK9_MENMED	:= Iif(SuperVal(QK9->QK9_MENMED) > SuperVal(cMenor) .or. Empty(QK9->QK9_MENMED),cMenor, QK9->QK9_MENMED)
		QK9->QK9_MAIMED	:= Iif(SuperVal(QK9->QK9_MAIMED) < SuperVal(cMaior),cMaior, QK9->QK9_MAIMED)
		MsUnlock()
		FKCOMMIT()
		
		DbSelectArea("QKA")
	Else
    
		If DbSeek(cCond + StrZero(nIt,2)) //AQUI
			RecLock("QKA",.F.)
			DbDelete()
			MsUnLock()
			FKCOMMIT()			
		Endif
	Endif
	
Next nIt

DbSelectArea("QK9")
RecLock("QK9",.F.)
QK9->QK9_QTDSUB	:= Str((nNumItem - 1),2)
QK9->QK9_PONFOR	:= Str(nPtosFora,4)
QK9->QK9_XBB	:= fTransGrav((nXBB / (nNumItem - 1)), 'QK9_XBB')
QK9->QK9_RB		:= fTransGrav((nRB / (nNumItem - 1)), 'QK9_RB')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo dos Limites de Controle da Amplitude³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nValTab	:= (SuperVal(aTable[nPos, 2]) * SuperVal(QK9->QK9_RB))

QK9->QK9_AMPLCI	:= fTransGrav(0,'QK9_AMPLCI')  // Por definicao Segundo Tabela do Apendice E
QK9->QK9_AMPLCS	:= fTransGrav(nValTab, 'QK9_AMPLCS')


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo dos Limites de Controle da Media    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nValTab	:= (SuperVal(QK9->QK9_XBB) - (SuperVal(aTable[nPos, 3]) * SuperVal(QK9->QK9_RB)))
QK9->QK9_MEDLCI	:= fTransGrav(nValTab,'QK9_MEDLCI')

nValTab	:= (SuperVal(QK9->QK9_XBB) + (SuperVal(aTable[nPos, 3]) * SuperVal(QK9->QK9_RB)))
QK9->QK9_MEDLCS	:= fTransGrav(nValTab,'QK9_MEDLCS')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do Desvio Padrao da Capabilidade    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nValTab	:= (SuperVal(QK9->QK9_RB) / SuperVal(aTable[nPos, 4]))
QK9->QK9_CAPDES := fTransGrav(nValTab,'QK9_CAPDES')

MsUnlock()
FKCOMMIT()

// Segundo Loop no aCols para verificacao dos pontos fora dos limites das medias e amplitudes

For nIt := 1 To Len(aCols)
	
	If !aCols[nIt, nPosDel] .and. !Empty(aCols[nIt,nPosAmos1])  // Verifica se o item foi deletado
		
		// Medias fora dos limites
		If SuperVal(aCols[nIt, nPosMedia]) > SuperVal(QK9->QK9_MEDLCS) .or. ;
			SuperVal(aCols[nIt, nPosMedia]) < SuperVal(QK9->QK9_MEDLCI)
			
			nPtosForaMed++
		Endif
		
		// Amplitude fora dos limites
		If SuperVal(aCols[nIt, nPosAmpli]) > SuperVal(QK9->QK9_AMPLCS) .or. ;
			SuperVal(aCols[nIt, nPosAmpli]) < SuperVal(QK9->QK9_AMPLCI)
			
			nPtosForaAmp++
		Endif
		
		// Calculo do Devio Padrao do Desempenho e alimentacao do Array IQR
		For nCpo := 1 To Len(aHeader)
			If Subs(AllTrim(aHeader[nCpo, 2]),1,8) == "QKA_AMOS"
				If nCPO <= (Val(QK9->QK9_TAMSUB) + 1)
					                            //Medição                  - M. das Médias          ^ 2
					nDesvDes := nDesvDes + ( (SuperVal(aCols[nIt, nCpo]) - SuperVal(QK9->QK9_XBB)) ^ 2 )
					aAdd(aIQR,SuperVal(aCols[nIt, nCpo]))
				Endif
			Endif
		Next nCpo
		
	Endif
	
Next nIt

// Finalizacao do Calculo do Devio Padrao do Desempenho
nDesvDes := Sqrt((nDesvDes / ((Val(QK9->QK9_TAMSUB) * Val(QK9->QK9_QTDSUB)) - 1)))

// Calculo do CP
nCP := (((nTOL + nLSE) - (nTOL + nLIE)) / (6 * SuperVal(QK9->QK9_CAPDES)))

// Calculo do CPK
nCPK1 := (((nTOL + nLSE) - SuperVal(	QK9->QK9_XBB)) / (3 * SuperVal(QK9->QK9_CAPDES)))
nCPK2 := ((SuperVal(QK9->QK9_XBB) - (nTOL + nLIE)) / (3 * SuperVal(QK9->QK9_CAPDES)))

// Calculo do PP
nPP := (((nTOL + nLSE) - (nTOL + nLIE)) / (6 * nDesvDes))

// Calculo do PPK
nPPK1 := (((nTOL + nLSE) - SuperVal(	QK9->QK9_XBB)) / (3 * nDesvDes))
nPPK2 := ((SuperVal(QK9->QK9_XBB) - (nTOL + nLIE)) / (3 * nDesvDes))

// Apuracao do QU e QL para Metodo Interquartil

nQU := ((3 * ((Val(QK9->QK9_TAMSUB) * Val(QK9->QK9_QTDSUB)) + 1))/4) // Formulas do Metodo
nQL := (((Val(QK9->QK9_TAMSUB) * Val(QK9->QK9_QTDSUB)) + 1) / 4)

If Mod(nQU, Int(nQU)) <> 0
	nQU := Int(nQU)
Endif

If Mod(nQL, Int(nQL)) <> 0
	nQL := Int(nQL) + 1
Endif

nIQR := Abs(((aIQR[nQU] - aIQR[nQL]) / nDesvDes))
nIQR := Round(nIQR,2)

RecLock("QK9",.F.)

QK9->QK9_MEDPFO	:= Str(nPtosForaMed,4)
QK9->QK9_AMPPFO	:= Str(nPtosForaAmp,4)

QK9->QK9_CP		:= fTransGrav(nCP, 'QK9_CP')
QK9->QK9_CR		:= fTransGrav(Iif(nCP <> 0, 1/nCP, 0), 'QK9_CR')
QK9->QK9_CPK	:= fTransGrav(Iif(nCPK1 < nCPK2, nCPK1, nCPK2), 'QK9_CPK')

QK9->QK9_PERDES	:= fTransGrav(nDesvDes, 'QK9_PERDES')
QK9->QK9_PP		:= fTransGrav(nPP, 'QK9_PP')
QK9->QK9_PR		:= fTransGrav(Iif(nPP <> 0, 1/nPP, 0), 'QK9_PR')
QK9->QK9_PPK	:= fTransGrav(Iif(nPPK1 < nPPK2, nPPK1, nPPK2),'QK9_PPK')

QK9->QK9_AVANOR	:= PadL(Transform(nIQR, "@E 99.99"),13)

MsUnlock()
FKCOMMIT()

DbSelectArea("QKA")

End Transaction

Return lGraOk


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A170Dele ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 06.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Exclusao                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A170Dele(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A170Dele()

Local cEspecie 	:= "QPPA170 "
Local cCond1, cCond2

If lSeq
	cCond1 := xFilial("QKA")+ QK9->QK9_PECA + QK9->QK9_REV + QK9->QK9_CARAC + QK9_SEQ
	cCond2 := "QK9->QK9_PECA + QK9->QK9_REV + QK9->QK9_CARAC + QK9->QK9_SEQ == QKA_PECA + QKA_REV + QKA_CARAC + QKA_SEQ"
Else
	cCond1 := xFilial("QKA")+ QK9->QK9_PECA + QK9->QK9_REV + QK9->QK9_CARAC //AQUI
	cCond2 := "QK9->QK9_PECA + QK9->QK9_REV + QK9->QK9_CARAC == QKA_PECA + QKA_REV + QKA_CARAC"
Endif

DbSelectArea("QKA")
DbSetOrder(1)

If DbSeek(cCond1)
	
	Do While !Eof() .and. &cCond2
		
		RecLock("QKA",.F.)
		DbDelete()
		MsUnLock()
		FKCOMMIT()		
		DbSkip()
		
	Enddo
	
Endif

DbSelectArea("QK9")

If !Empty(QK9->QK9_CHAVE)
	QO_DelTxt(QK9->QK9_CHAVE,cEspecie)    //QPPXFUN
Endif

RecLock("QK9",.F.)
DbDelete()
MsUnLock()
FKCOMMIT()
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PP170LinOk³ Autor ³ Robson Ramiro A. Olive³ Data ³ 06.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP170LinOk                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function PP170LinOk

Local nPosDel  := Len(aHeader) + 1
Local nPosAmos1 := aScan(aHeader, { |x| AllTrim(x[2]) == "QKA_AMOS1" })
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ verifica se ao menos 1 amostra foi preenchida        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Empty(aCols[n,nPosAmos1]) .and. !aCols[n, nPosDel]
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
Endif

Return lRetorno

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PP170TudOk³ Autor ³ Robson Ramiro A. Olive³ Data ³ 06.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para inclusao/alteracao geral                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP170TudOk                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Function PP170TudOk

Local lRetorno	:= .T.
Local nIt 		:= 0
Local nTot		:= 0
Local nPosDel  	:= Len(aHeader) + 1
Local nPosAmos1	:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKA_AMOS1" })

For nIt := 1 To Len(aCols)
	If aCols[nIt, nPosDel] .or. Empty(aCols[nIt,nPosAmos1])
		nTot ++
	Endif
Next nIt

If Empty(M->QK9_PECA) .or. Empty(M->QK9_REV) .or. nTot == Len(aCols) ;
	.or. Empty(M->QK9_TAMSUB) .or. Empty(M->QK9_CARAC)
	
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
Endif

Return lRetorno


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPP170OBSE³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 06.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastra Observacoes                        				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPP170OBSE(ExpN1)                               			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA170													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP170OBSE(nOpc)

Local cChave  	:= "", cCabec := ""
Local cTitulo 	:= OemToAnsi(STR0002) //"Observacoes"
Local nTamLin 	:= TamSX3("QKO_TEXTO")[1]
Local cEspecie 	:= "QPPA170 "   //Para gravacao de textos
Local lEdit		:= .F.
Local cInf		:= ""
Local nSaveSX8	:= GetSX8Len()

If nOpc == 3 .or. nOpc == 4
	lEdit := .T.
Endif

axTextos	:= {} 	//Vetor que contem os textos dos Produtos
cCabec		:= OemToAnsi(STR0006) //"Texto da Observacao"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera/obtem a chave de ligacao com o texto da Peca/Rv     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Empty(M->QK9_CHAVE)
	cChave := GetSXENum("QK9", "QK9_CHAVE",,3)
	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End
	
	M->QK9_CHAVE := cChave
Else
	cChave := M->QK9_CHAVE
Endif

cInf := AllTrim(M->QK9_PECA) + "  " + M->QK9_REV + "  " + M->QK9_CARAC + "  " + PPA170Desc()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Digita a Observacao da Peca    							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If QO_TEXTO(cChave,cEspecie,nTamlin,cTitulo,cInf, @axtextos,1,cCabec,lEdit)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Texto da Peca no QKO							     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QO_GrvTxt(cChave,cEspecie,1,@axTextos) 	//QPPXFUN
Endif

DbSelectArea("QK9")
DbSetOrder(1)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP170APRO³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 07.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Aprova / Rejeita Estudos                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP170APRO(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP170APRO(nOpc)

If nOpc == 3 .or. nOpc == 4
	DbSelectArea("QAA")
	DbSetOrder(6)
	If Dbseek(Upper(cUserName))
		M->QK9_DATA  	:= dDataBase
		M->QK9_RESP   	:= cUserName
		M->QK9_DISP		:= Iif(M->QK9_DISP == "1", "2", "1")
	Else
   		messagedlg(STR0049) //"O usuário logado não está cadastrado no cadastro de usuários do módulo, portanto não poderá ser o aprovador
	Endif
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP170LIMP³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 07.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Limpa aprovacoes / rejeicoes                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP170LIMP(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP170LIMP(nOpc)

If nOpc == 3 .or. nOpc == 4
	DbSelectArea("QAA")
	DbSetOrder(6)
	If Dbseek(Upper(cUserName))
		M->QK9_DATA  	:= CtoD(" / / ")
		M->QK9_RESP   	:= Space(40)
		M->QK9_DISP		:= Space(01)
	
	Else
   		messagedlg(STR0050) //"O usuário logado não está cadastrado no cadastro de usuários do módulo, portanto não poderá limpar a aprovação"
	Endif

Endif
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPPA170p  ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 22/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chama a funcao que monta a picture de um campo             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPPA170p(cCampo)             							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do Campo que tera' a picture a ser definida   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA170													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QPPA170p(cCampo)

Local cPict  := " "

If Alltrim(FunName()) <> "LERDA" .And. Alltrim(FunName()) <> "EDAPP"

	QK2->(DbSetOrder(2))
	QK2->(DbSeek(xFilial("QKA") + M->QK9_PECA + M->QK9_REV + M->QK9_CARAC))
	
	If QK2->(Found())
		cPict 	:= QA_PICT(cCampo,QK2->&(cCampo))
	Else
		cPict 	:= "999999999999"
	Endif                                     

Endif

Return cPict

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPPA170c  ³ Autor ³ Wanderley / Robson    ³ Data ³ 16/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula media e amplitude.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPPA170c()                   							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA170													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QPPA170c

Local nI 	 	:= 0
Local nCont  	:= Val(M->QK9_TAMSUB)
Local nSoma	 	:= 0
Local nMedia 	:= 0
Local nAmpl 	:= 0
Local nMaior 	:= 0
Local nMenor    := 0
Local nValor 	:= 0
Local nPos 	 	:= 0
Local nPosColun	:= 0
Local nPosMEDIA	:= 0
Local nPosAMPLI	:= 0
Local cPict		:= QPPA170p("QK2_TOL")

nPos 		:= aScan(aHeader,{ |x| Subs(AllTrim(x[2]),1,8) == "QKA_AMOS" })
nPosMEDIA	:= aScan(aHeader,{ |x| AllTrim(x[2]) == "QKA_MEDIA" })
nPosAMPLI	:= aScan(aHeader,{ |x| AllTrim(x[2]) == "QKA_AMPLI" })

For nI := nPos To (nCont+1)
	nPosColun  := oGet:oBrowse:nColPos
	
	If ValType(aCols[n,nI]) == "C"
		nValor := SuperVal(aCols[n,nI])
	Else
		nValor := aCols[n,nI]
	Endif
	
	If nPosColun == nI
		nValor	:= SuperVal(&(Readvar()))
	Endif
	
	nSoma += nValor
	
	If nI == nPos
		nMenor := nValor
		nMaior := nValor
	Else
		If nMenor > nValor
			nMenor := nValor
		Endif
		If nMaior < nValor
			nMaior := nValor
		Endif
	Endif
Next nI

nAmpl  := (nMaior - nMenor)
nMedia := (nSoma /nCont)

aCols[n,nPosAMPLI]	:= Transform(nAmpl,cPict)
aCols[n,nPosMEDIA]	:= Transform(nMedia,cPict)

oGet:oBrowse:Refresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³PPA170Resu³ Autor ³ Robson Ramiro A Olivei³ Data ³ 20/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibe os Resultados dos Estudos de Capabilidade            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ PPA170Resu()                   							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA170													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PPA170Resu(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local oGroup1, oGroup2, oGroup3, oGroup4, oGroup5
Local cPict	:= ""
Local nTOL		:= 0 		// Nominal
Local nLIE		:= 0		// Afastamento Inferior
Local nLSE		:= 0		// Afastamento Superior
Local nValLIE 	:= 0
Local nValLSE := 0
Local cAval	:= ""  
Local nLICPK 	:= 1.33    // Valor de CPK definido na  norma  NAO MUDAR
Local nLSCPK 	:= 1.67    // Valor de CPK definido na  norma  NAO MUDAR

oFont := TFont():New("Arial",12,12,,.T.,,,,.F.,.F.)

RegToMemory("QK9")			// Para compatibilizacao da funcao abaixo

cPict := QPPA170p("QK2_TOL")

DbSelectArea("QK2")
DbSetOrder(2)
If DbSeek(xFilial("QK2") + QK9->QK9_PECA + QK9->QK9_REV + QK9->QK9_CARAC)
	nTOL := SuperVal(QK2_TOL)
	nLIE := nTOL + SuperVal(QK2_LIE)
	nLSE := nTOL + SuperVal(QK2_LSE)
	nValLIE := SuperVal(QK2_LIE)
	nValLSE := SuperVal(QK2_LSE)
Endif

DbSelectArea("QK1")
DbSetOrder(1)
If DbSeek(xFilial("QK1") + QK9->QK9_PECA + QK9->QK9_REV)
	nLICPK := QK1_LICPK
	nLSCPK := QK1_LSCPK
EndIf

Do Case
	Case SuperVal(QK9->QK9_CPK) < nLICPK
		cAval := STR0012 //"PROCESSO INCAPAZ"
	Case SuperVal(QK9->QK9_CPK) > nLICPK .and. SuperVal(QK9->QK9_CPK) <= nLSCPK
		cAval := STR0013 //"PROCESSO CAPAZ"
	Case SuperVal(QK9->QK9_CPK) > nLSCPK
		cAval := STR0014 //"PROCESSO ALTAMENTE CAPAZ"
EndCase

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0015+ QK2->QK2_DESC) ; //"Resultados "
				FROM 120,000 TO 516,644 OF oMainWnd PIXEL

@ 005,005 GROUP oGroup1 TO 065,317 LABEL OemToAnsi(STR0016) OF oDlg PIXEL //"Amostras"

@ 010,010 SAY OemToAnsi(STR0017) SIZE 012,010 OF oDlg PIXEL //"LIE"
@ 010,050 SAY nLIE Picture cPict SIZE 050,010 OF oDlg PIXEL

@ 020,010 SAY OemToAnsi(STR0018) SIZE 012,010 OF oDlg PIXEL //"LSE"
@ 020,050 SAY nLSE Picture cPict SIZE 050,010 OF oDlg PIXEL

@ 030,010 SAY OemToAnsi(STR0019) SIZE 028,010 OF oDlg PIXEL //"Nominal"
@ 030,050 SAY nTOL Picture cPict SIZE 050,010 OF oDlg PIXEL

@ 010,100 SAY OemToAnsi(STR0020) SIZE 052,010 OF oDlg PIXEL //"Tam. Subgrupo"
@ 010,150 SAY PadL(AllTrim(QK9->QK9_TAMSUB),3) SIZE 010,010 OF oDlg PIXEL

@ 020,100 SAY OemToAnsi(STR0021) SIZE 052,010 OF oDlg PIXEL //"Qtd. Subgrupo"
@ 020,150 SAY PadL(AllTrim(QK9->QK9_QTDSUB),3) SIZE 010,010 OF oDlg PIXEL

@ 030,100 SAY OemToAnsi(STR0022) SIZE 052,010 OF oDlg PIXEL //"Tot. Medidas"
@ 030,150 SAY (Val(QK9->QK9_QTDSUB)*Val(QK9->QK9_TAMSUB)) Picture "999" SIZE 010,010 OF oDlg PIXEL

@ 010,200 SAY OemToAnsi(STR0023) SIZE 060,010 OF oDlg PIXEL //"Av. Normalidade"
@ 010,250 SAY PadL(AllTrim(QK9->QK9_AVANOR),13) SIZE 052,010 OF oDlg PIXEL

@ 015,200 SAY OemToAnsi("=") SIZE 005,010 OF oDlg PIXEL
@ 020,200 SAY OemToAnsi("X") SIZE 005,010 OF oDlg PIXEL
@ 020,250 SAY PadL(AllTrim(QK9->QK9_XBB),13)   SIZE 052,010 OF oDlg PIXEL

@ 025,200 SAY OemToAnsi("-") SIZE 005,010 OF oDlg PIXEL
@ 030,200 SAY OemToAnsi("R") SIZE 005,010 OF oDlg PIXEL
@ 030,250 SAY PadL(AllTrim(QK9->QK9_RB),13)    SIZE 052,010 OF oDlg PIXEL

@ 045,010 SAY OemToAnsi(STR0024) SIZE 050,010 OF oDlg PIXEL //"Maior Medida"
@ 045,050 SAY QK9->QK9_MAIMED SIZE 052,010 OF oDlg PIXEL

@ 045,100 SAY OemToAnsi(STR0025) SIZE 050,010 OF oDlg PIXEL //"Menor Medida"
@ 045,150 SAY QK9->QK9_MENMED SIZE 052,010 OF oDlg PIXEL

@ 045,200 SAY OemToAnsi(STR0026) SIZE 050,010 OF oDlg PIXEL //"Ptos. Fora"
@ 045,250 SAY QK9->QK9_PONFOR SIZE 052,010 OF oDlg PIXEL

@ 055,125 SAY OemToAnsi(STR0027) SIZE 050,010 OF oDlg PIXEL //"Unilateral"
@ 055,175 SAY  Iif((nValLIE == 0) .OR. (nValLSE == 0), STR0029, STR0028) SIZE 015,010 OF oDlg PIXEL   //"Sim"###"Nao"


@ 070,005 GROUP oGroup2 TO 090,317 LABEL OemToAnsi(STR0030) OF oDlg PIXEL //"Carta das Medias"

@ 075,010 SAY OemToAnsi(STR0031) SIZE 012,010 OF oDlg PIXEL //"LCI"
@ 075,050 SAY QK9->QK9_MEDLCI SIZE 052,010 OF oDlg PIXEL

@ 075,100 SAY OemToAnsi(STR0032) SIZE 012,010 OF oDlg PIXEL //"LCS"
@ 075,150 SAY QK9->QK9_MEDLCS SIZE 052,010 OF oDlg PIXEL

@ 075,200 SAY OemToAnsi(STR0026) SIZE 050,010 OF oDlg PIXEL //"Ptos. Fora"
@ 075,250 SAY QK9->QK9_MEDPFO SIZE 052,010 OF oDlg PIXEL


@ 095,005 GROUP oGroup3 TO 115,317 LABEL OemToAnsi(STR0033) OF oDlg PIXEL //"Carta das Amplitudes"

@ 100,010 SAY OemToAnsi(STR0031) SIZE 096,010 OF oDlg PIXEL //"LCI"
@ 100,050 SAY QK9->QK9_AMPLCI SIZE 052,010 OF oDlg PIXEL

@ 100,100 SAY OemToAnsi(STR0032) SIZE 096,010 OF oDlg PIXEL //"LCS"
@ 100,150 SAY QK9->QK9_AMPLCS SIZE 052,010 OF oDlg PIXEL

@ 100,200 SAY OemToAnsi(STR0026) SIZE 050,010 OF oDlg PIXEL //"Ptos. Fora"
@ 100,250 SAY QK9->QK9_AMPPFO SIZE 052,010 OF oDlg PIXEL

@ 120,005 GROUP oGroup4 TO 140,317 LABEL OemToAnsi(STR0034) OF oDlg PIXEL //"Desempenho"

@ 125,010 SAY OemToAnsi(STR0035) SIZE 096,010 OF oDlg PIXEL //"Desvio Padrao"
@ 125,050 SAY QK9->QK9_PERDES SIZE 052,010 OF oDlg PIXEL

@ 125,100 SAY OemToAnsi("Pp") SIZE 010,010 OF oDlg PIXEL
@ 125,120 SAY QK9->QK9_PP SIZE 052,010 OF oDlg PIXEL

@ 125,180 SAY OemToAnsi("Ppk")  SIZE 010,010 OF oDlg PIXEL
@ 125,200 SAY QK9->QK9_PPK SIZE 052,010 OF oDlg PIXEL

@ 125,260 SAY OemToAnsi("PR")  SIZE 010,010 OF oDlg PIXEL
@ 125,280 SAY QK9->QK9_PR SIZE 052,010 OF oDlg PIXEL

@ 145,005 GROUP oGroup5 TO 165,317 LABEL OemToAnsi(STR0036) OF oDlg PIXEL //"Capabilidade"

@ 150,010 SAY OemToAnsi(STR0035) SIZE 096,010 OF oDlg PIXEL //"Desvio Padrao"
@ 150,050 SAY QK9->QK9_CAPDES SIZE 052,010 OF oDlg PIXEL

@ 150,100 SAY OemToAnsi("Cp")  SIZE 010,010 OF oDlg PIXEL
@ 150,120 SAY QK9->QK9_CP SIZE 052,010 OF oDlg PIXEL

@ 150,180 SAY OemToAnsi("Cpk")  SIZE 010,010 OF oDlg PIXEL
@ 150,200 SAY QK9->QK9_CPK SIZE 052,010 OF oDlg PIXEL

@ 150,260 SAY OemToAnsi("CR")  SIZE 010,010 OF oDlg PIXEL
@ 150,280 SAY QK9->QK9_CR SIZE 052,010 OF oDlg PIXEL

@ 180,010 SAY OemToAnsi(cAval) SIZE 200,015 OF oDlg PIXEL Font oFont COLOR CLR_HRED

DEFINE SBUTTON FROM 180,267 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg  CENTERED

DbSelectArea(cAlias)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³PPA170Desc³ Autor ³ Robson Ramiro A Olivei³ Data ³ 21/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza o Campo virtual no Browse                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ PPA170Desc()                   							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA170													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PPA170Desc()

Return Posicione("QK2",2,xFilial()+QK9->QK9_PECA+QK9->QK9_REV+QK9->QK9_CARAC,"QK2_DESC")


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³PPA170SPC ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 10/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera arquivo (SPC) para gerar o grafico					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ PPA170SPC()          									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA170   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA170SPC

Local aValores	:= {}
Local aArea 	:= {}
Local nCont		:= 0
Local nItem		:= 0
Local bCampo	:= { |nCPO| Field(nCPO) }
Local cDir		:= GetMv("MV_QDIRGRA")
Local cArqSPC	:= ""
Local nTol
Local nLIE
Local nLSE
Local cPict
Local cMedi
Local aItem		:= {}
Local cListBox
Local oListBox	:= Nil
Local oDlg		:= Nil
Local oBtn1		:= Nil
Local oBtn2		:= Nil
Local lRetGraf
Local bAction
Local cCond1, cCond2  
Local nAmos 	:= 1
Local cSenhas	:= "1"
Local nX        := 0 
Local nY        := 0 
Local aArrayAux := {}

Private aMed64  := {}


If Right(cDir,1) <> "\"
	cDir += "\"
Endif                      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existem os arquivos CARTA.BMP, CARTA2.BMP e HISTO.BMP se existirem, serão deletados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File(cDir+"HISTO.BMP")
	fErase(cDir+"HISTO.BMP")
Endif                          
If File(cDir+"CARTA.BMP")
	fErase(cDir+"CARTA.BMP")
EndIf 
If File(cDir+"CARTA2.BMP")
	fErase(cDir+"CARTA2.BMP")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera o Nome do arquivo do Grafico							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lExistChart
	For nCont := 1 To 99999
		cArqSPC := "PPA" + StrZero(nCont,4) + ".SPC"
		If !File(AllTrim(cDir)+cArqSPC)
			Exit
		Endif
	Next nCont
Endif

M->QK9_PECA		:= QK9->QK9_PECA 			// Para compatibilizacao da funcao abaixo
M->QK9_REV		:= QK9->QK9_REV
M->QK9_CARAC	:= QK9->QK9_CARAC

If lSeq
	M->QK9_SEQ := QK9->QK9_SEQ
Endif

cPict := QPPA170p("QK2_TOL")

If cPaisLoc == "MEX"
	cPict := STRTRAN(cPict,".",",")
Endif

DbSelectArea("QK2")
DbSetOrder(2)
If DbSeek(xFilial("QK2") + QK9->QK9_PECA + QK9->QK9_REV + QK9->QK9_CARAC)
	nTOL := SuperVal(QK2_TOL)
	nLIE := nTOL + SuperVal(QK2_LIE)
	nLSE := nTOL + SuperVal(QK2_LSE)
Endif

aAdd(aValores,"QACHART.DLL - NORMAL")

aAdd(aValores,"[USL]")
aAdd(aValores,AllTrim(Transform(nLSE, cPict)))

aAdd(aValores,"[LSL]")
aAdd(aValores,AllTrim(Transform(nLIE, cPict)))

aAdd(aValores,"[TARGET]")
aAdd(aValores,AllTrim(Transform(nTOL, cPict)))

aAdd(aValores,"[DECIMAIS]")
aAdd(aValores,Str(Qa_NumDec(QK2->QK2_TOL),2))

aAdd(aValores,"[UM]")
aAdd(aValores,AllTrim(QK2->QK2_UM))

aAdd(aValores,"[TITLE]")
aAdd(aValores,	" - " + AllTrim(QK1->QK1_PECA)+" "+QK1->QK1_REV+" "+;
				STR0040+AllTrim(QK2->QK2_CODCAR)+" "+QK2->QK2_DESC) //"Carac. "

Aadd(aValores,"[LANGUAGE]")
Aadd(aValores,Upper(__Language) )

aAdd(aValores,"[FOOT]")
aAdd(aValores,	AllTrim(QK1->QK1_PECA)+" "+QK1->QK1_REV+" "+;
				STR0040+AllTrim(QK2->QK2_CODCAR)+" "+QK2->QK2_DESC) //"Carac. "
				
aAdd(aValores,"[INICIO DE DADOS]")

DbSelectArea("QKA")

aArea := GetArea()

DbSetOrder(1)

If lSeq
	cCond1 := xFilial("QKA")+ QK9->QK9_PECA + QK9->QK9_REV + QK9->QK9_CARAC + QK9->QK9_SEQ
	cCond2 := "QK9->QK9_PECA + QK9->QK9_REV + QK9->QK9_CARAC + QK9->QK9_SEQ == QKA_PECA + QKA_REV + QKA_CARAC + QKA_SEQ"
Else
	cCond1 := xFilial("QKA")+ QK9->QK9_PECA + QK9->QK9_REV + QK9->QK9_CARAC //AQUI
	cCond2 := "QK9->QK9_PECA + QK9->QK9_REV + QK9->QK9_CARAC == QKA_PECA + QKA_REV + QKA_CARAC"
Endif

DbSeek(cCond1)

cMedi := 	StrZero(Day(QK9->QK9_DTEST),2)+"/"+;
			StrZero(Month(QK9->QK9_DTEST),2)+"/"+Str(Year(QK9->QK9_DTEST),4)+;
			"00:00"
Do While !Eof() .and. &cCond2 .and. xFilial("QK9") == xFilial("QKA")
	Aadd(aMed64,{})
	nAmos 	:= 1
	For nCont := 1 To FCount()
		cVar:="QKA_AMOS"+alltrim(str(nAmos))
		If nAmos <= Val(QK9->QK9_TAMSUB) .AND. AllTrim(QKA->(EVAL(bCampo,nCont))) == cVar
			nItem++     
			nAmos++
			aAdd(aValores,cMedi+AllTrim(QKA->&(EVAL(bCampo,nCont))))
			Aadd(aMed64[LEN(aMed64)],AllTrim(QKA->&(EVAL(bCampo,nCont))))
		Endif
	Next nCont
	
	DbSkip()
Enddo

aAdd(aValores,"[FIM DE DADOS]")

aAdd(aValores,"[SUBGRUPO]")
aAdd(aValores,QK9->QK9_TAMSUB)

If !lExistChart
	lRetGraf := GeraTxt32(aValores,cArqSPC,cDir)
Endif

aItem := {	"Xbar",;
			"Range",;
			"Standard Deviation",;
			"Individuals",;
			"Moving Range",;
			"Ind / Moving Range",;
			"Xbar / Range",;
			"Xbar / Standard Deviation",;
			"Run" }

cListBox := aItem[7]

If lExistChart
	aTitCarCon := {"Xbar(Media)", "Range(Amplitude)"}
	lRetGraf := .T.
Endif

nPosTar := ASCAN( aValores, "[TARGET]" ) + 1
nPosLSL := ASCAN( aValores, "[LSL]" ) + 1
nPosUSL := ASCAN( aValores, "[USL]" ) + 1
aLimites := {}
aLimites := {SUPERVAL(aValores[nPosTar]), SUPERVAL(aValores[nPosLSL]), SUPERVAL(aValores[nPosUSL])}

For nX := 1 To Len(aMed64)
	For nY := 1 To Len(aMed64[nX])
		aADD(aArrayAux,aMed64[nX][nY])
	Next nY
Next nX


If lExistChart
	bAction  := {|| QIEMGRAFIC(aMed64, oListBox:nAt, aMed64, aTitCarCon, aLimites,,,,,,,SUPERVAL(QK9->QK9_TAMSUB))}
Else
	bAction := 	{|| CallDll32("ShowChart",cArqSPC,Str(oListBox:nAt-1,1),cDir,;
				NORMAL,Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO")),;
				StatusBtn(cDir,oBtn1,oBtn2)}	
Endif	

PtInternal(9,"FALSE")

If lRetGraf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega a DLL para Impressao do Grafico					     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	DEFINE MSDIALOG oDlg FROM 5, 5 TO 17, 50 TITLE OemToAnsi(STR0041) //"Tipos de Cartas"
	
	@ .5, 2 LISTBOX oListBox VAR cListBox ITEMS aItem SIZE 150, 40 OF oDlg;
	ON DBLCLICK IIF(fValGrafic(aItem,oListBox:nAt), Eval(bAction),.F.)
	
	DEFINE SBUTTON FROM 055,110 TYPE 1 ENABLE OF oDlg ACTION IIF(fValGrafic(aItem,oListBox:nAt), Eval(bAction),.F.)

	DEFINE SBUTTON FROM 055,140 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()
	
	If lExistChart
		@ 055,005 BUTTON oBtn3 PROMPT OemToAnsi(STR0051) OF oDlg PIXEL SIZE 45,13 ; //"Histograma"
		ACTION QIEMGRAFIC(aArrayAux, 3, aMed64, ,aLimites,,,,,,,SUPERVAL(QK9->QK9_TAMSUB))

		@ 055,055 BUTTON oBtn1 PROMPT OemToAnsi(STR0042) OF oDlg PIXEL SIZE 45,13 ;//"Impr. Histograma"
		ACTION QPPR170(.T.,3,,,{aArrayAux,3,aMed64,,aLimites,,}) // QIPR170

		@ 073,005 BUTTON oBtn2 PROMPT OemToAnsi(STR0043) OF oDlg PIXEL SIZE 45,13 ; //"Impr. Carta Crtl"
		ACTION IIF(fValGrafic(aItem,oListBox:nAt),QPPR170(.T.,oListBox:nAt,,,{aMed64,1,aMed64,aTitCarCon,aLimites,,}),.F.) // QIPR170
		
		oBtn1:lReadOnly := .F.
		oBtn2:lReadOnly := .F.		
	Else 
		@ 055,005 BUTTON oBtn1 PROMPT OemToAnsi(STR0042) OF oDlg PIXEL SIZE 45,13 ACTION QPPR170(.T.,1) //"Impr. Histograma"
		@ 055,055 BUTTON oBtn2 PROMPT OemToAnsi(STR0043) OF oDlg PIXEL SIZE 45,13 ACTION QPPR170(.T.,2) //"Impr. Carta Crtl"

		oBtn1:lReadOnly := .T.	
		oBtn2:lReadOnly := .T.
	Endif
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Deleta o Arquivo SPC                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fErase(Alltrim(cDir)+cArqSPC)
	
Endif

PtInternal(9,"TRUE")

If File(cDir+"HISTO.BMP")
	fErase(cDir+"HISTO.BMP")
Endif                          
If File(cDir+"CARTA.BMP")
	fErase(cDir+"CARTA.BMP")
EndIf 
If File(cDir+"CARTA2.BMP")
	fErase(cDir+"CARTA2.BMP")
EndIf

If !lExistChart
	CloseDll32()
EndIf

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³StatusBtn ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 27/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Habilita/Desabilita o botao para impressao        		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ StatusBtn(cDir,oBtn1,oBtn2)          					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA170   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function StatusBtn(cDir,oBtn1,oBtn2)

If File(cDir+"HISTO.BMP")
	oBtn1:lReadOnly := .F.
Else
	oBtn1:lReadOnly := .T.
Endif

If File(cDir+"CARTA.BMP")
	oBtn2:lReadOnly := .F.
Else
	oBtn2:lReadOnly := .T.
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³PPAPSEQ   ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 04/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria um sequencial para ensaios e estudos           		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ PPAPSEQ                               					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ PPAP	  													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PPAPSEQ(cAlias, cVar, cChave, nOrd)

Local nRetorno	:= Iif(!Empty(cVar),Val(cVar),1)
Local lLoop 	:= .T.

(cAlias)->(DbSetOrder(nOrd))

Do While lLoop
	If (cAlias)->(DbSeek(xFilial(cAlias) + cChave + StrZero(nRetorno,3)))
		nRetorno++
	Else
		lLoop := .F.
	Endif
Enddo

If !Empty(Alltrim(cVar))
	If Val(cVar) <> nRetorno
		MsgInfo(STR0048) // "Numero sequencial alterado"
	Endif
Endif

Return StrZero(nRetorno,3)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³PPA170VLD ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 06/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o sequencial para o estudos                		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ PPA170VLD                               					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA170	  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PPA170Vld

If INCLUI
	If lSeq
		M->QK9_SEQ := PPAPSEQ("QK9",M->QK9_SEQ,M->QK9_PECA+M->QK9_REV+M->QK9_CARAC,1)
		PPAPVld("QK9",M->QK9_PECA+M->QK9_REV+M->QK9_CARAC+M->QK9_SEQ,1,"QK2",2,2)
	Endif
Endif

Return .T.    



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QPPA170   ºAutor  ³Microsiga           º Data ³  03/24/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao do campo QK9_OPERAC                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QPPA170                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QPVALDOP
Local lRet := .T.
   
DbSelectArea ("QKK")
QKK->(DbSetOrder(2))//QKK_FILIAL+QKK_PECA+QKK_REV+QKK_NOPE   
If !QKK->(DbSeek(xFilial("QKK")+M->QK9_PECA+M->QK9_REV+M->QK9_OPERAC))
	Help(" ",1,'REGNOIS')
	lRet := .F.
Endif

Return lRet


/*/{Protheus.doc} fValGrafic
Função de validação e apresentação de mensagem em tela
@type function
@version  
@author thiago.rover
@since 28/12/2020
@param aItem, array
@param nNum, numeric
@return return_type, return_description
/*/
Function fValGrafic(aItem, nNum)

Local lRet := .F.

If nNum == 1 .Or. nNum == 2 .Or. nNum == 7
	lRet := .T. 
Else
	MessageDlg("O gráfico "+aItem[nNum]+" ainda não está implementado, disponíveis apenas os gráficos: "+aItem[1]+", "+aItem[2]+" e "+aItem[7])
	Return .F.	
Endif

Return lRet


/*/{Protheus.doc} fTransGrav
	Retorna o nValor formatado ocupando os espaços vazios até ocupar odo o tamanho do campo conforme parâmetro cCampo
	@type  Static Function
	@author brunno.costa
	@since 09/02/2022
	@version 1.0
	@param nValor, numeric, valor a ser formatado
	@param cCampo, caracter, campo do dicionário para referencia.
	@return cReturn, caracter, string formatada conforme parametros enviados.
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function fTransGrav(nValor, cCampo)
	Local nTamCampo := GetSx3Cache(cCampo, "X3_TAMANHO")
	Local nInteiro  := Len(cValToChar(Int(nValor)))
	Local cReturn   := Transform(nValor, Replicate('9', nInteiro ) + '.' + Replicate('9', nTamCampo - nInteiro - 1))
Return cReturn
