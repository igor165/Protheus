#INCLUDE "QPPA200.CH"
#INCLUDE "PROTHEUS.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA200  ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 01.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Ensaios de Desempenho                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA200(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPPAP                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Robson Ramiro³26.07.02³XMeta ³ Inclusao de Filtro na mBrowse          ³±±
±±³              ³        ³      ³ Troca da CvKey por GetSXENum()         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := {	{OemToAnsi(STR0001), "AxPesqui"   , 	0, 1,,.F.},;//"Pesquisa"
					{OemToAnsi(STR0002), "PPA200Visu" , 	0, 2},;		 //"Visualiza"
					{OemToAnsi(STR0003), "PPA200Incl" , 	0, 3},;		 //"Inclui"
					{OemToAnsi(STR0004), "PPA200Alte" , 	0, 4},; 	 //"Altera"
					{OemToAnsi(STR0005), "PPA200Excl" , 	0, 5},;		 //"Exclui"
					{OemToAnsi(STR0012), "QPPR200(.T.)", 	0, 6,,.T.},;//"Imprimir"
					{OemToAnsi(STR0013), "QPPR200V(.T.)", 	0, 7,,.T.} }//"Imprimir VDA"

Return aRotina

Function QPPA200

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cFiltro

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private cCadastro 	:= OemToAnsi(STR0006) //"Ensaios de Desempenho"
Private cCondW, cCondS
Private aRotina := MenuDef()

cCondW := "QKC->QKC_PECA+QKC->QKC_REV+QKC->QKC_SEQ == M->QKC_PECA+M->QKC_REV+M->QKC_SEQ"
cCondS := "M->QKC_PECA+M->QKC_REV+M->QKC_SEQ"

DbSelectArea("QKC")
DbSetOrder(1)

cFiltro := "QKC_ITEM == '"+StrZero(1,Len(QKC_ITEM))+"'"

Set Filter To &cFiltro
mBrowse(6,1,22,75,"QKC",,,,,,)
Set Filter To

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA200Visu³ Autor ³ Robson Ramiro A. Olive³ Data ³ 01/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa de Visualizacao dos Ensaios de Desempenho         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA200Visu()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA200Visu(cAlias, nReg, nOpc)

Local oDlg		:= NIL
Local oGet_1	:= NIL
Local oGet_2	:= NIL
Local oGet_3	:= NIL
Local oGet_4	:= NIL
Local oGet_5	:= NIL
Local oGet_6	:= NIL
Local aButtons	:= {}

Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL
Private axTextos

RegToMemory("QKC")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

A200Ahead("QKC")
DbSelectArea("QKC")
Set Filter To

nUsado	:= Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New()

oSize:AddObject( "ENCHOICE"     ,  100, 30, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "FORMULARIO"   ,  100, 70, .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 5, 5, 5, 5 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Ensaios de Desempenho"
												FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL


@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_PECA")[1] SIZE 56,07 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_1 VAR M->QKC_PECA PICTURE PesqPict("QKC","QKC_PECA") ;
                        WHEN .F.;
						F3 "QPP" SIZE 66,10 OF oDlg PIXEL  

@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI")+125 SAY TitSX3("QKC_REV")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+178 MSGET oGet_2 VAR M->QKC_REV PICTURE PesqPict("QKC","QKC_REV") ;
					WHEN .F.;
					SIZE 15,10 OF oDlg PIXEL
					   	
@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI")+220 SAY TitSX3("QKC_SEQ")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+255 MSGET oGet_6 VAR M->QKC_SEQ PICTURE PesqPict("QKC","QKC_SEQ") ;
						WHEN .F.;
						SIZE 15,10 OF oDlg PIXEL
					   	
@ oSize:GetDimension("ENCHOICE","LININI")+15,oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_LABOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_3 VAR M->QKC_LABOR PICTURE PesqPict("QKC","QKC_LABOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL					   		

@ oSize:GetDimension("ENCHOICE","LININI")+15,oSize:GetDimension("ENCHOICE","COLINI")+127 SAY TitSX3("QKC_ASSFOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+178 MSGET oGet_4 VAR M->QKC_ASSFOR PICTURE PesqPict("QKC","QKC_ASSFOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL					   		

@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+256 MSGET oGet_5 VAR M->QKC_DTAPR PICTURE PesqPict("QKC","QKC_DTAPR") ;
						WHEN .F.;
					   	SIZE 33,10 OF oDlg PIXEL					   		

@ oSize:GetDimension("ENCHOICE","LININI")+30,oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_OBSERV")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+28,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_3 VAR M->QKC_OBSERV PICTURE PesqPict("QKC","QKC_OBSERV") ;
						WHEN .F.;
					   	SIZE 200,10 OF oDlg PIXEL
					   	
A200Acols(nOpc)

oGet := MSGetDados():New(oSize:GetDimension("FORMULARIO","LININI"),;
							oSize:GetDimension("FORMULARIO","COLINI"),;
							oSize:GetDimension("FORMULARIO","LINEND"),;
							oSize:GetDimension("FORMULARIO","COLEND"),;
							nOpc,"AllwaysTrue","AllwaysTrue","+QKC_ITEM",.T.)

aButtons := {	{"RELATORIO", 	{ || QPP200RESU(nOpc) },	OemToAnsi(STR0007), OemToAnsi(STR0014)},;		//"Resultados das Medicoes"###"Result"
				{"BMPVISUAL",  	{ || QPPR200()},			OemToAnsi(STR0011), OemToAnsi(STR0016)} }		//"Visualizar/Imprimir"###"Vis/Prn"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}, , aButtons) CENTERED

DbSelectArea("QKC")
DbSetOrder(1)
Set Filter To &cFiltro

Return .T.
          

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA200Incl³ Autor ³ Robson Ramiro A. Olive³ Data ³ 01/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa de Inclusao dos Ensaios de Desempenho             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPPA200Incl()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA200Incl(cAlias, nReg, nOpc)

Local oDlg		:= NIL
Local oGet_1	:= NIL
Local oGet_2	:= NIL
Local oGet_3	:= NIL
Local oGet_4	:= NIL
Local oGet_5	:= NIL
Local oGet_6	:= NIL
Local lOk 		:= .F.   
Local aButtons	:= {}
Local nTamGet 	:= QPPTAMGET("QKC_ITEM",1)

Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL
Private axTextos

RegToMemory("QKC",.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New()

oSize:AddObject( "ENCHOICE"     ,  100, 30, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "FORMULARIO"   ,  100, 70, .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 5, 5, 5, 5 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
A200Ahead("QKC")
DbSelectArea("QKC")
Set Filter To 

nUsado	:= Len(aHeader)      

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Ensaios de Desempenho"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL


@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_PECA")[1] SIZE 56,07 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_1 VAR M->QKC_PECA PICTURE PesqPict("QKC","QKC_PECA") ;
						Valid NaoVazio() .AND. QPPA200Valid() ;
						F3 "QPP" SIZE 66,10 OF oDlg PIXEL  

@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI")+125 SAY TitSX3("QKC_REV")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+178 MSGET oGet_2 VAR M->QKC_REV PICTURE PesqPict("QKC","QKC_REV") ;
                        VALID CheckSx3("QKC_REV",M->QKC_REV);
					   	SIZE 15,10 OF oDlg PIXEL

@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI")+220 SAY TitSX3("QKC_SEQ")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+255 MSGET oGet_6 VAR M->QKC_SEQ PICTURE PesqPict("QKC","QKC_SEQ") ;
 						VALID CheckSx3("QKC_SEQ",M->QKC_SEQ);
					SIZE 15,10 OF oDlg PIXEL
					   	
@ oSize:GetDimension("ENCHOICE","LININI")+15,oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_LABOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_3 VAR M->QKC_LABOR PICTURE PesqPict("QKC","QKC_LABOR") ;
					   	SIZE 66,10 OF oDlg PIXEL
					   	
@ oSize:GetDimension("ENCHOICE","LININI")+15,oSize:GetDimension("ENCHOICE","COLINI")+127 SAY TitSX3("QKC_ASSFOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+178 MSGET oGet_4 VAR M->QKC_ASSFOR PICTURE PesqPict("QKC","QKC_ASSFOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL					   		

@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+256 MSGET oGet_5 VAR M->QKC_DTAPR PICTURE PesqPict("QKC","QKC_DTAPR") ;
						WHEN .F.;
					   	SIZE 33,10 OF oDlg PIXEL					   		

@ oSize:GetDimension("ENCHOICE","LININI")+30,oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_OBSERV")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+28,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_3 VAR M->QKC_OBSERV PICTURE PesqPict("QKC","QKC_OBSERV") ;
					   	SIZE 200,10 OF oDlg PIXEL


A200Acols(nOpc)

oGet := MSGetDados():New(oSize:GetDimension("FORMULARIO","LININI"),;
							oSize:GetDimension("FORMULARIO","COLINI"),;
							oSize:GetDimension("FORMULARIO","LINEND"),;
							oSize:GetDimension("FORMULARIO","COLEND"),;
							nOpc,"PP200LinOk" ,"PP200TudOk","+QKC_ITEM",.T.,,1,,nTamGet)

aButtons := {	{"RELATORIO", 	{ || QPP200RESU(nOpc) },	OemToAnsi(STR0007), OemToAnsi(STR0014)},;		//"Resultados das Medicoes"###/"Result"
				{"EDIT",  		{ || QPP200APRO(nOpc) },	OemToAnsi(STR0010), OemToAnsi(STR0015) }}		//"Aprovar/Desaprovar"###"Apr/Des"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP200TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

If lOk
	PPA200Grav(nOpc)
Endif

DbSelectArea("QKC")
DbSetOrder(1)
Set Filter To &cFiltro

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA200Alte³ Autor ³ Robson Ramiro A. Olive³ Data ³ 01/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa de Alteracao dos Ensaios de Desempenho            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA200Alte()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA200Alte(cAlias, nReg, nOpc)

Local oDlg		:= NIL
Local oGet_1	:= NIL
Local oGet_2	:= NIL
Local oGet_3	:= NIL
Local oGet_4	:= NIL
Local oGet_5	:= NIL
Local oGet_6	:= NIL
Local lOk 		:= .F.   
Local aButtons	:= {}
Local nTamGet 	:= QPPTAMGET("QKC_ITEM",1)

Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL
Private axTextos

If !QPPVldAlt(QKC->QKC_PECA,QKC->QKC_REV,QKC->QKC_ASSFOR)
	Return
Endif

RegToMemory("QKC")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New()

oSize:AddObject( "ENCHOICE"     ,  100, 30, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "FORMULARIO"   ,  100, 70, .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 5, 5, 5, 5 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
A200Ahead("QKC")
DbSelectArea("QKC")
Set Filter To

nUsado	:= Len(aHeader)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Ensaios de Desempenho"
				FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL


@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_PECA")[1] SIZE 56,07 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_1 VAR M->QKC_PECA PICTURE PesqPict("QKC","QKC_PECA") ;
						Valid NaoVazio() .AND. QPPA200Valid() WHEN .F. ;
						F3 "QPP" SIZE 66,10 OF oDlg PIXEL  

@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI")+125 SAY TitSX3("QKC_REV")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+178 MSGET oGet_2 VAR M->QKC_REV PICTURE PesqPict("QKC","QKC_REV") ;
                        VALID CheckSx3("QKC_REV",M->QKC_REV) WHEN .F.;
					   	SIZE 15,10 OF oDlg PIXEL

@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI")+220 SAY TitSX3("QKC_SEQ")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+255 MSGET oGet_6 VAR M->QKC_SEQ PICTURE PesqPict("QKC","QKC_SEQ") ;
 						VALID CheckSx3("QKC_SEQ",M->QKC_SEQ) WHEN .F.;
					SIZE 15,10 OF oDlg PIXEL

@ oSize:GetDimension("ENCHOICE","LININI")+15,oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_LABOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_3 VAR M->QKC_LABOR PICTURE PesqPict("QKC","QKC_LABOR") ;
					   	SIZE 66,10 OF oDlg PIXEL
					   	
@ oSize:GetDimension("ENCHOICE","LININI")+15,oSize:GetDimension("ENCHOICE","COLINI")+127 SAY TitSX3("QKC_ASSFOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+178 MSGET oGet_4 VAR M->QKC_ASSFOR PICTURE PesqPict("QKC","QKC_ASSFOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL

@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+256 MSGET oGet_5 VAR M->QKC_DTAPR PICTURE PesqPict("QKC","QKC_DTAPR") ;
						WHEN .F.;
					   	SIZE 33,10 OF oDlg PIXEL

@ oSize:GetDimension("ENCHOICE","LININI")+30,oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_OBSERV")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+28,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_3 VAR M->QKC_OBSERV PICTURE PesqPict("QKC","QKC_OBSERV") ;
					   	SIZE 200,10 OF oDlg PIXEL
		   		
A200Acols(nOpc)

oGet := MSGetDados():New(oSize:GetDimension("FORMULARIO","LININI"),;
							oSize:GetDimension("FORMULARIO","COLINI"),;
							oSize:GetDimension("FORMULARIO","LINEND"),;
							oSize:GetDimension("FORMULARIO","COLEND"),;
							nOpc,"PP200LinOk" ,"PP200TudOk","+QKC_ITEM",.T.,,1,,nTamGet)

aButtons := {	{"RELATORIO", 	{ || QPP200RESU(nOpc) },	OemToAnsi(STR0007), OemToAnsi(STR0014)},;		//"Resultados das Medicoes"###"Result"
				{"EDIT",  		{ || QPP200APRO(nOpc) },	OemToAnsi(STR0010), OemToAnsi(STR0015) }}		//"Aprovar/Desaprovar"###"Apr/Des"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP200TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

If lOk
	PPA200Grav(nOpc)
Endif

DbSelectArea("QKC")
DbSetOrder(1)
Set Filter To &cFiltro

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA200Excl³ Autor ³ Robson Ramiro A. Olive³ Data ³ 01/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Exclusao dos Ensaios de Desempenho             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA200Excl()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA200Excl(cAlias, nReg, nOpc)

Local oDlg		:= NIL
Local oGet_1	:= NIL
Local oGet_2	:= NIL
Local oGet_3	:= NIL
Local oGet_4	:= NIL
Local oGet_5	:= NIL
Local oGet_6	:= NIL
Local aButtons	:= {}

Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL
Private axTextos        

If !QPPVldExc(QKC->QKC_REV,QKC->QKC_ASSFOR)
	Return
Endif


RegToMemory("QKC")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New()

oSize:AddObject( "ENCHOICE"     ,  100, 30, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "FORMULARIO"   ,  100, 70, .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 5, 5, 5, 5 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
A200Ahead("QKC")
DbSelectArea("QKC")
Set Filter To

nUsado	:= Len(aHeader)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Ensaios de Desempenho"
												FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL


@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_PECA")[1] SIZE 56,07 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_1 VAR M->QKC_PECA PICTURE PesqPict("QKC","QKC_PECA") ;
						Valid NaoVazio() .AND. QPPA200Valid() WHEN .F.;
						F3 "QPP" SIZE 66,10 OF oDlg PIXEL  

@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI")+125 SAY TitSX3("QKC_REV")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+178 MSGET oGet_2 VAR M->QKC_REV PICTURE PesqPict("QKC","QKC_REV") ;
                        VALID CheckSx3("QKC_REV",M->QKC_REV) WHEN .F.;
					   	SIZE 15,10 OF oDlg PIXEL

@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI")+220 SAY TitSX3("QKC_SEQ")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+255 MSGET oGet_6 VAR M->QKC_SEQ PICTURE PesqPict("QKC","QKC_SEQ") ;
 						VALID CheckSx3("QKC_SEQ",M->QKC_SEQ) WHEN .F.;
					SIZE 15,10 OF oDlg PIXEL

@ oSize:GetDimension("ENCHOICE","LININI")+15,oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_LABOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_3 VAR M->QKC_LABOR PICTURE PesqPict("QKC","QKC_LABOR") ;
					   	SIZE 66,10 WHEN .F. OF oDlg PIXEL
					   	
@ oSize:GetDimension("ENCHOICE","LININI")+15,oSize:GetDimension("ENCHOICE","COLINI")+127 SAY TitSX3("QKC_ASSFOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+178 MSGET oGet_4 VAR M->QKC_ASSFOR PICTURE PesqPict("QKC","QKC_ASSFOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL
					   	
@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+256 MSGET oGet_5 VAR M->QKC_DTAPR PICTURE PesqPict("QKC","QKC_DTAPR") ;
						WHEN .F.;
					   	SIZE 33,10 OF oDlg PIXEL					   		

@ oSize:GetDimension("ENCHOICE","LININI")+30,oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_OBSERV")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+28,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_3 VAR M->QKC_OBSERV PICTURE PesqPict("QKC","QKC_OBSERV") ;
					   	WHEN .F. SIZE 200,10 OF oDlg PIXEL
					   	
A200Acols(nOpc)

oGet := MSGetDados():New(oSize:GetDimension("FORMULARIO","LININI"),;
							oSize:GetDimension("FORMULARIO","COLINI"),;
							oSize:GetDimension("FORMULARIO","LINEND"),;
							oSize:GetDimension("FORMULARIO","COLEND"),;
							nOpc,"AllwaysTrue","AllwaysTrue","+QKC_ITEM",.T.)

aButtons := {	{"RELATORIO", 	{ || QPP200RESU(nOpc) },	OemToAnsi(STR0007), OemToAnsi(STR0014)},;		//"Resultados das Medicoes"###"Result"
				{"BMPVISUAL",  	{ || QPPR200()},			OemToAnsi(STR0011), OemToAnsi(STR0016)} }		//"Visualizar/Imprimir"###"Vis/Prn"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| A200Dele(),oDlg:End()},{||oDlg:End()}, , aButtons) CENTERED

DbSelectArea("QKC")
DbSetOrder(1)
Set Filter To &cFiltro

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A200Acols³ Autor ³ Robson Ramiro A. Olive³ Data ³ 01/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega vetor aCols para a GetDados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200Acols()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A200Acols(nOpc)
Local nI, nPos
Local aArea := {}

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
		EndIf
	Next nI

    nPos            := aScan(aHeader,{ |x| AllTrim(x[2])== "QKC_ITEM" })
	aCols[1,nPos]	:= StrZero(1,Len(aCols[1,nPos]))
	
	aCols[1,nUsado+1] := .F.	

Else
	
    DbSelectArea("QKC")
	DbSetOrder(1)
	DbSeek(xFilial("QKC") + &cCondS)
	aArea := QKC->(GetArea())
	
	Do While QKC->(!Eof()) .and. xFilial("QKC") == QKC->QKC_FILIAL .and. &cCondW
			 	
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
	RestArea(aArea)
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A200Ahead³ Autor ³ Robson Ramiro A. Olive³ Data ³ 01/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Ahead para aCols                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200Ahead()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A200Ahead(cAlias)

Local aStruAlias := FWFormStruct(3, cAlias)[3]
Local nX

Private nEdicao := Val(GetMv("MV_QPPAPED",.T.,"3"))// Indica a Edicao do PPAP default 3 Edicao

aHeader := {}
nUsado 	:= 0

For nX := 1 To Len(aStruAlias)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ignora campos que nao devem aparecer na getdados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  Upper(AllTrim(aStruAlias[nX,1])) == "QKC_PECA" 	.or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKC_REV" 	.or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKC_REVINV".or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKC_LABOR" .or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKC_ASSFOR".or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKC_DTAPR" .or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKC_OBSERV".or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKC_SEQ"
		Loop
	Endif
	
	If nEdicao == 3
		If cNivel >= GetSX3Cache(aStruAlias[nX,1],"X3_NIVEL") .And. Alltrim(aStruAlias[nX,1]) <> "QKC_DTENSA"
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
	Else
		If cNivel >= GetSX3Cache(aStruAlias[nX,1],"X3_NIVEL") .And. Alltrim(aStruAlias[nX,1]) <> "QKC_FTESTE"
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
	Endif	
Next nX  

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A200Dele ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 01/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fucao para exclusao dos Ensaios de Desempenho              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A200Dele()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A200Dele()

Local cEspecie  := "QPPA200 "

DbSelectArea("QKC")
DbSetOrder(1)
DbSeek(xFilial("QKC") + &cCondS)

Begin Transaction

Do While QKC->(!Eof()) .and. xFilial("QKC") == QKC->QKC_FILIAL .and. &cCondW

		 
    If !Empty(QKC->QKC_CHAVE)
        QO_DelTxt(QKC->QKC_CHAVE,cEspecie)    //QPPXFUN
	EndIf		 

    RecLock("QKC",.F.)
	DbDelete()
	MsUnLock()
		
	DbSkip()
		
Enddo
FKCOMMIT()
End Transaction

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA200Grav³ Autor ³ Robson Ramiro A Olivei³ Data ³ 01/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Gravacao dos Ensaios de Desempenho - Incl/Alter³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA200Grav(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA200Grav(nOpc)

Local nIt
Local nNumItem
Local nPosDel		:= Len(aHeader) + 1
Local lGraOk		:= .T.
Local cEspecie  	:= "QPPA200 "
Local cAtividade	:= "10 " // Definido no ID - QKZ
Local nCpo

DbSelectArea("QKC")
DbSetOrder(1)
	
Begin Transaction

nNumItem := 1  // Contador para os Itens
	
For nIt := 1 To Len(aCols)
	
	If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

		If ALTERA
			If DbSeek(xFilial("QKC") + &cCondS + StrZero(nIt,Len(QKC->QKC_ITEM)))
                RecLock("QKC",.F.)
			Else
                RecLock("QKC",.T.)
			Endif
		Else	                   
            RecLock("QKC",.T.)
		Endif
			
		For nCpo := 1 To Len(aHeader)
			If aHeader[nCpo, 10] <> "V"
                QKC->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
			EndIf
		Next nCpo
                                                                              
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle de itens do acols / Chave invertida                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        QKC->QKC_ITEM   := StrZero(nNumItem,Len(QKC->QKC_ITEM))
        QKC->QKC_REVINV := Inverte(M->QKC_REV)


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dados da Enchoice                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        QKC->QKC_FILIAL	:= xFilial("QKC")
        QKC->QKC_PECA  	:= M->QKC_PECA
        QKC->QKC_REV   	:= M->QKC_REV
        QKC->QKC_ASSFOR	:= M->QKC_ASSFOR
        QKC->QKC_DTAPR 	:= M->QKC_DTAPR
        QKC->QKC_LABOR 	:= M->QKC_LABOR
		QKC->QKC_OBSERV	:= M->QKC_OBSERV
		QKC->QKC_SEQ		:= M->QKC_SEQ
		        
		nNumItem++			
	
		MsUnLock()					
	Else
		If DbSeek(xFilial("QKC") + &cCondS + StrZero(nIt,Len(QKC->QKC_ITEM)))
	
            If !Empty(QKC->QKC_CHAVE)
                QO_DelTxt(QKC->QKC_CHAVE,cEspecie)    //QPPXFUN
			EndIf		 

            RecLock("QKC",.F.)
            QKC->(DbDelete())
		Endif
	Endif
	
Next nIt
FKCOMMIT()
End Transaction

If !Empty(QKC->QKC_DTAPR) .and. !Empty(QKC->QKC_ASSFOR)
	QPP_CRONO(QKC->QKC_PECA,QKC->QKC_REV,cAtividade) // QPPXFUN - Atualiza Cronograma
Endif
				
DbSelectArea("QKC")
DbSetOrder(1)

Return lGraOk


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP200RESU³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 01.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastra Observacoes                        				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP200RESU(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP200RESU(nOpc)

Local cChave  	:= "", cCabec := ""
Local cTitulo   := OemToAnsi(STR0007) //"Ensaios de Desempenho"
Local nTamLin 	:= 43
Local nPosChave := aScan(aHeader,{ |x| AllTrim(x[2]) == "QKC_CHAVE"  } )
Local cEspecie  := "QPPA200 "   //Para gravacao de textos
Local lEdit		:= .F.
Local cInf		:= ""
Local nSaveSX8	:= GetSX8Len()

If nOpc == 3 .or. nOpc == 4
	lEdit := .T.
Endif

axTextos	:= {} 	//Vetor que contem os textos dos Produtos
cCabec      := OemToAnsi(STR0008) //"Resultados dos Ensaios"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera/obtem a chave de ligacao com o texto da Peca/Rv     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Empty(aCols[n,nPosChave])
	cChave := GetSXENum("QKC", "QKC_CHAVE",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

	aCols[n,nPosChave] := cChave
Else
	cChave := aCols[n,nPosChave]
EndIf
                                              
cInf := AllTrim(M->QKC_PECA) + " " + M->QKC_REV + STR0009 + StrZero(n,Len(QKC->QKC_ITEM)) //" Item - "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Digita os resultados dos Ensaios                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If QO_TEXTO(cChave,cEspecie,nTamlin,cTitulo,cInf, @axtextos,1,cCabec,lEdit)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Texto dos ensaios no QKO						     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QO_GrvTxt(cChave,cEspecie,1,@axTextos) 	//QPPXFUN
Endif

DbSelectArea("QKC")
DbSetOrder(1)

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PP200LinOk³ Autor ³ Robson Ramiro A. Olive³ Data ³ 01.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP200LinOk                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QPPA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/                     
Function PP200LinOk

Local nPosDel  := Len(aHeader) + 1
Local nPosDesc := aScan(aHeader, { |x| AllTrim(x[2]) == "QKC_DESC" })
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ verifica se a caracteristica foi preenchida          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Empty(aCols[n,nPosDesc]) .and. !aCols[n, nPosDel]
	lRetorno := .F.
EndIf

Return lRetorno

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PP200TudOk³ Autor ³ Robson Ramiro A. Olive³ Data ³ 01.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para inclusao/alteracao geral                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP200TudOk                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QPPA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Function PP200TudOk

Local lRetorno	:= .T.
Local nIt 		:= 0
Local nTot		:= 0
Local nPosDel  	:= Len(aHeader) + 1                      
Local nPosDesc  := aScan(aHeader, { |x| AllTrim(x[2]) == "QKC_DESC" })

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para consistir obrigatoriedade de campos (enchoice)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF ExistBlock( "PP200CST" )
	lRetorno := ExecBlock( "PP200CST", .F., .F., {M->QKC_LABOR,M->QKC_ASSFOR,	M->QKC_DTAPR,M->QKC_OBSERV } )
Endif

For nIt := 1 To Len(aCols)
	If aCols[nIt, nPosDel] .or. Empty(aCols[nIt,nPosDesc])
		nTot ++
	Endif
Next nIt

If Empty(M->QKC_PECA) .or. Empty(M->QKC_REV) .or. nTot == Len(aCols)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
EndIf

Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP200APRO³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 01.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Aprova Ensaios                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP200APRO(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP200APRO(nOpc)

If nOpc == 3 .or. nOpc == 4
	DbSelectArea("QAA")
	DbSetOrder(6)
	If Dbseek(Upper(cUserName))
		M->QKC_DTAPR    := Iif(Empty(M->QKC_DTAPR) ,dDataBase     		 ,CtoD(" / / "))
		M->QKC_ASSFOR   := Iif(Empty(M->QKC_ASSFOR),cUserName,Space(40))
	Else
		messagedlg(STR0017) //"O usuário logado não está cadastrado no cadastro de usuários do módulo, portanto não poderá ser o aprovador"
	Endif
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³PPA200VLD ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 20/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o sequencial para o ensaio                		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ PPA200VLD                               					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA200	  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PPA200Vld

If INCLUI
	M->QKC_SEQ := PPAPSEQ("QKC",M->QKC_SEQ,M->QKC_PECA+M->QKC_REV,1)
	PPAPVld("QKC",M->QKC_PECA+M->QKC_REV+M->QKC_SEQ,1,"QK1",2,2)
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QPPA200Valid ºAutor  ³Microsiga           º Data ³  03/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chama o VALID do campo, prevendo uma funcao que carregue no   º±±
±±º          ³ acols. 														 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QPPA200                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPPA200Valid()
CheckSx3("QKC_REV",M->QKC_REV)
oGet:ForceRefresh()
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QPA180VTIP   ºAutor  ³Microsiga           º Data ³  03/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o tipo da caracteristica é dimensional.           º±±
±±º          ³        														 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QPPA180                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA200VTIP()

Local lret := .T.   

dbSelectArea("QK2")
dbSetOrder(2)
dbSeek(xFilial("QKC")+M->QKC_PECA+M->QKC_REV+M->QKC_CARAC)
If QK2_TPCAR <> "3"	
	MsgAlert("Esta caracteristica não é do tipo desempenho","Aviso")
	lRet := .F.
EndIf  

Return (lRet)
