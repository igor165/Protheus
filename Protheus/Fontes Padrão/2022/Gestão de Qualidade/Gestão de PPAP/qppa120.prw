#INCLUDE "QPPA120.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA120  ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 08.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³FMEA de Projeto                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA120(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPPAP                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Robson Ramiro³01.07.02³Meta  ³ Alteracao para Visualizacao de BMP     ³±±
±±³              ³        ³      ³ na caracterista. Melhoria para a       ³±±
±±³              ³        ³      ³ ordenacao de itens                     ³±±
±±³              ³        ³      ³ Troca do CvKey por GetSXENum           ³±±
±±³              ³        ³      ³ Adequacao a ult. rev. da norma         ³±±
±±³              ³        ³      ³ Inclusao de Parametro para NPR maximo  ³±±
±±³              ³        ³      ³ Inclusao de Campo para Cod. Responsavel³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui"  ,	 0, 1,,.F.},;		//"Pesquisar"
					{ OemToAnsi(STR0002), "PPA120Visu",	 0, 2},;			//"Visualizar"
					{ OemToAnsi(STR0003), "PPA120Incl",	 0, 3},;			//"Incluir"
					{ OemToAnsi(STR0004), "PPA120Alte",	 0, 4},;			//"Alterar"
					{ OemToAnsi(STR0005), "PPA120Excl",	 0, 5},;			//"Excluir"
					{ OemToAnsi(STR0030), "QPPR120(.T.)",0, 6,,.T.}}		//"Imprimir"

Return aRotina

Function QPPA120
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0006)  //"FMEA de Projeto"

Private aRotina := MenuDef()
Private lFMEA4a := GetMV("MV_QVEFMEA",.T.,"3") == "4" //FMEA 4a. EDICAO...

DbSelectArea("QK5")    
DbSetOrder(1)

mBrowse( 6, 1, 22, 75,"QK5",,,,,,)

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA120Visu  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³29.08.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Visualizacao                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA120Visu(ExpC1,ExpN1,ExpN2)                           ³±±
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
Function PPA120Visu(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local aButtons		:= {}
Local nTamSeq   	:= TamSX3("QK6_SEQ")[1]
Local aPosEnch  	:= {}
Local oPanel1		:= NIL
Local oPanel2		:= NIL
Local oEnch		:= NIL

Private oScrollBox	:= NIL
Private oPanel			:= NIL
Private nLin 			:= 1
Private nCont 			:= 0
Private aValues		:= {}
Private aPanels 		:= {}
Private aOGets			:= {}
Private oGet			:= NIL
Private aObjects  	:= {}
Private aSize   		:= MsAdvSize(.T.)
Private aInfo     		:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }  
Private aPosObj   	:= {}


DbSelectArea(cAlias)

AAdd( aObjects, { 100, 40, .T., .T. } ) // Dados da Enchoice 
AAdd( aObjects, { 100, 60, .T., .T. } ) // Dados da getdados 
aPosObj:= MsObjSize( aInfo, aObjects, .T. ,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) + ' - VISUALIZAÇÃO'  ;  //"FMEA de Projeto"
						FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL

@ 000,000 MSPANEL oPanel1 SIZE 100,aPosObj[1,3] OF oDlg
@ 000,000 MSPANEL oPanel2 SIZE 100,050 			OF oDlg
						
RegToMemory("QK5")
aPosEnch := {aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]}  // ocupa todo o  espaço da janela

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnch := MsmGet():New( "QK5", nReg, nOpc,,,,,aPosEnch, , 3, , , ,oPanel1, ,.F. )
aButtons := {{"BMPVISUAL",	{ || QPPR120() }, OemToAnsi(STR0009), OemToAnsi(STR0031) },;  //"Visualizar/Imprimir"###"Vis/Prn"
			 {"GRAF2D",     { || QPPM040(M->QK5_PECA,M->QK5_REV,"1")} , OemToAnsi(STR0035), OemToAnsi(STR0036)}}  //"Diagrama de Pareto"###"Diag.Par"
				
DbSelectArea("QK6")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Scroll                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                                          
oScrollBox :=TScrollBox():New(oPanel2,,,,,.T.,.T.,.T.)

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT 

DbSelectArea("QK6")
DbSetOrder(4)
DbSeek(xFilial("QK6")+M->QK5_PECA+M->QK5_REV)

Do While !Eof() .and. M->QK5_PECA+M->QK5_REV == QK6->QK6_PECA+QK6->QK6_REV
	QPP120ADIC(nOpc,.F.)
	DbSelectArea("QK6")
	DbSkip()
Enddo
                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}, , aButtons) CENTERED

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA120Incl  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³29.08.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Inclusao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA120Incl(ExpC1,ExpN1,ExpN2)                           ³±±
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
Function PPA120Incl(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local lOk 			:= .F.
Local aButtons		:= {}
Local aPosEnch  	:= {}
Local oPanel1
Local oPanel2
Local oEnch

Private oScrollBox 	:= NIL
Private oPanel		:= NIL
Private nLin 		:= 1
Private nCont 		:= 0
Private aValues		:= {}
Private aPanels 	:= {}
Private aOGets		:= {}
Private oGet	    := NIL
Private aObjects  	:= {}
Private aSize   	:= MsAdvSize(.T.)
Private aInfo     	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }  
Private aPosObj   	:= {}

DbSelectArea(cAlias)	
DbSelectArea("QK6")
DbGoTop()

AAdd( aObjects, { 100, 40, .T., .T. } ) // Dados da Enchoice 
AAdd( aObjects, { 100, 60, .T., .T. } ) // Dados da getdados 
aPosObj:= MsObjSize( aInfo, aObjects, .T. ,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) + ' - INCLUSÃO' ;  //"FMEA de Projeto"
						FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL

@ 000,000 MSPANEL oPanel1 SIZE 100,aPosObj[1,3] OF oDlg
@ 000,000 MSPANEL oPanel2 SIZE 100,050 			OF oDlg

aPosEnch := {aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]}  // ocupa todo o  espaço da janela
RegToMemory("QK5",.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnch := MsmGet():New( "QK5", nReg, nOpc,,,,,aPosEnch, , 3, , , ,oPanel1, ,.F. )

aButtons := {   {"BMPINCLUIR",	{ || QPP120ADIC(nOpc,.T.) },	OemToAnsi(STR0007), OemToAnsi(STR0032)},; 	//"Incluir Item"###"Inc Item"
				{"EDIT", 		{ || QPP120APRO(nOpc) }, 		OemToAnsi(STR0008), OemToAnsi("Apr/Limp")},; 	//"Aprovar / Limpar"
  			    {"GRAF2D",     { || QPPM040(M->QK5_PECA,M->QK5_REV,"1")} , OemToAnsi(STR0035), OemToAnsi(STR0036)}}  //"Diagrama de Pareto"###"Diag.Par"

DbSelectArea("QK6")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Scroll                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                            
oScrollBox :=TScrollBox():New(oPanel2,,,,,.T.,.T.,.T.)

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT 

QPP120ADIC(nOpc,.T.)
                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP120TudOk(nOpc), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

If lOk
	A120Grav(nOpc)
Endif

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA120Alte  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³30.08.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Alteracao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA120Alte(ExpC1,ExpN1,ExpN2)                           ³±±
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
Function PPA120Alte(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local lOk 		:= .F.
Local aCposAlt	:= {}
Local aButtons	:= {}
Local aPosEnch  	:= {}
Local oPanel1
Local oPanel2
Local oEnch

Private oScrollBox 	:= NIL
Private oPanel		:= NIL
Private nLin 		:= 1
Private nCont 		:= 0
Private aValues		:= {}
Private aPanels 	:= {}
Private aOGets		:= {}
Private aObjects  	:= {}
Private aSize   	:= MsAdvSize(.T.)
Private aInfo     	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }  
Private aPosObj   	:= {}
Private oGet		:= NIL

If !QPPVldAlt(QK5->QK5_PECA,QK5->QK5_REV,QK5->QK5_APRPOR)
	Return
Endif

DbSelectArea(cAlias)
DbSelectArea("QK6")
DbGoTop()

AAdd( aObjects, { 100, 40, .T., .T. } ) // Dados da Enchoice 
AAdd( aObjects, { 100, 60, .T., .T. } ) // Dados da getdados 
aPosObj:= MsObjSize( aInfo, aObjects, .T. ,.F.)

If lFMEA4a
	aCposAlt := {	"QK5_FMEA"  , 	"QK5_PREPOR", 	"QK5_RESPON", "QK5_IDPROD",;
					"QK5_EQUIPE", 	"QK5_OBS"   , 	"QK5_APRPOR", "QK5_DATA"  ,;
					"QK5_DTINI" ,	"QK5_DTREV" , 	"QK5_DTCHAV", "QK5_TPFMEA",;
					"QK5_ANOMOD"}		
Else
	aCposAlt := {	"QK5_FMEA", 	"QK5_PREPOR", 	"QK5_RESPON", "QK5_IDPROD",;
				"QK5_EQUIPE", 	"QK5_OBS", 		"QK5_APRPOR", "QK5_DATA", ;
				"QK5_DTINI",	"QK5_DTREV", 	"QK5_DTCHAV" }		
Endif				
				

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) + ' - ALTERAÇÃO'  ;  //"FMEA de Projeto"
						FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL

@ 000,000 MSPANEL oPanel1 SIZE 100,aPosObj[1,3] OF oDlg
@ 000,000 MSPANEL oPanel2 SIZE 100,050 			OF oDlg

aPosEnch := {aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]}  // ocupa todo o  espaço da janela					
RegToMemory("QK5")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnch := MsmGet():New( "QK5", nReg, nOpc,,,,,aPosEnch, , 3, , , ,oPanel1, ,.F. )

aButtons := {  	{"BMPINCLUIR",	{ || QPP120ADIC(nOpc,.T.) },	OemToAnsi(STR0007), OemToAnsi(STR0032)},; 	//"Incluir Item"###"Inc Item"
				{"EDIT", 		{ || QPP120APRO(nOpc) }, 		OemToAnsi(STR0008), OemToAnsi(STR0033)},; 	//"Aprovar / Limpar"###"Apr/Limp"
  			    {"GRAF2D",     { || QPPM040(M->QK5_PECA,M->QK5_REV,"1")} , OemToAnsi(STR0035), OemToAnsi(STR0036)}}  //"Diagrama de Pareto"###"Diag.Par"

DbSelectArea("QK6")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Scroll                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                                     
oScrollBox :=TScrollBox():New(oPanel2,,,,,.T.,.T.,.T.)

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT 

DbSelectArea("QK6")
DbSetOrder(4)
DbSeek(xFilial("QK6")+M->QK5_PECA+M->QK5_REV)

Do While !Eof() .and. M->QK5_PECA+M->QK5_REV == QK6->QK6_PECA+QK6->QK6_REV
	QPP120ADIC(nOpc,.F.)
	DbSelectArea("QK6")
	DbSkip()
Enddo
                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP120TudOk(nOpc), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

If lOk
	A120Grav(nOpc)
Endif

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA120Excl  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³30.08.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Exclusao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA120Excl(ExpC1,ExpN1,ExpN2)                           ³±±
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
Function PPA120Excl(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local aButtons	:= {}
Local aPosEnch  	:= {}
Local oPanel1
Local oPanel2
Local oEnch

Private oScrollBox 	:= NIL
Private oPanel		:= NIL
Private nLin 		:= 1
Private nCont 		:= 0
Private aValues		:= {}
Private aPanels 	:= {}
Private aOGets		:= {}
Private aObjects  	:= {}
Private aSize   	:= MsAdvSize(.T.)
Private aInfo     	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }  
Private aPosObj   	:= {}
Private oGet	:= NIL  

If !QPPVldExc(QK5->QK5_REV,QK5->QK5_APRPOR)
	Return
Endif

DbSelectArea(cAlias)

AAdd( aObjects, { 100, 40, .T., .T. } ) // Dados da Enchoice 
AAdd( aObjects, { 100, 60, .T., .T. } ) // Dados da getdados 
aPosObj:= MsObjSize( aInfo, aObjects, .T. ,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) + ' - EXCLUSÃO'  ;  //"FMEA de Projeto"
						FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL

@ 000,000 MSPANEL oPanel1 SIZE 100,aPosObj[1,3] OF oDlg
@ 000,000 MSPANEL oPanel2 SIZE 100,050 			OF oDlg

aPosEnch := {aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]}  // ocupa todo o  espaço da janela				
RegToMemory("QK5")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnch := MsmGet():New( "QK5", nReg, nOpc,,,,,aPosEnch, , 3, , , ,oPanel1, ,.F. )
aButtons := { {"BMPVISUAL", { || QPPR120() }, OemToAnsi(STR0009), OemToAnsi(STR0031)},;  //"Visualizar/Imprimir"###"Vis/Prn"
		    {"GRAF2D",     { || QPPM040(M->QK5_PECA,M->QK5_REV,"1")} , OemToAnsi(STR0035), OemToAnsi(STR0036)}}  //"Diagrama de Pareto"###"Diag.Par"

DbSelectArea("QK6")                                                                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Scroll                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                                      
oScrollBox :=TScrollBox():New(oPanel2,,,,,.T.,.T.,.T.)

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT 

DbSelectArea("QK6")
DbSetOrder(4)
DbSeek(xFilial("QK6")+M->QK5_PECA+M->QK5_REV)

Do While !Eof() .and. M->QK5_PECA+M->QK5_REV == QK6->QK6_PECA+QK6->QK6_REV
	QPP120ADIC(nOpc,.F.)
	DbSelectArea("QK6")
	DbSkip()
Enddo
                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| A120Dele(),oDlg:End()},{||oDlg:End()}, , aButtons) CENTERED

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP120ADIC³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 29.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Resultados dos Estudos                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP120ADIC(ExpN1,ExpL1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									       ³±±
±±³          ³ ExpL1 = Diferenciacao se foi inclusao manual				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP120ADIC(nOpc,lManual)

Local nx
Local bBlock
Local aGets	:= {}
Local cChave
Local axTextos1, axTextos2, axTextos3, axTextos4, axTextos5, axTextos6, axTextos7, axTextos8, axTextos9, axTextos10, axTextos11 
Local bValid
Local oGet1,oGet2,oGet3,oGet4,oGet5,oGet6
Local oGet7,oGet8,oGet9,oGet10,oGet11,oGet12
Local oGet13,oGet14,oGet15,oGet16,oGet17,oGet18
Local oGet19,oGet20,oGet21,oGet22,oGet61
Local oGet23, oGet24, oGet25
Local oBtn
Local oBmp
Local nTamLin 	:= 17
Local cSeq 		:= Space(TamSX3("QK6_SEQ")[1])
Local nSaveSX8	:= GetSX8Len()
Local nTamSeq   := TamSX3("QK6_SEQ")[1]
Local nTamTela  
Local nItFMEA   
nx := Len(aPanels) 

If lFMEA4a
	nItFMEA := 20
	nTamTela := 1350
		
Else
	nItFMEA := 19
	nTamTela := 1050	
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao permite incluir mais de 30 caracteristicas devido problemas de ambiente.                     ³
//³Nesse caso utilizar o programa QPPA121.prw que utiliza ListBox para controle das caracteristicas.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nx == 30
	Return
EndIf	

If nx > 999
	Alert(STR0025) //"Limite maximo de 999 itens !"
	Return
Endif 

If lManual .and. Len(aValues) > 0
	If Val(aValues[Iif(nx > 0,nx,1), nItFMEA]) <= 0
		Help(" ",1,"QPPITFMEA") // "Nao e possivel inserir + 1 item sem numerar o anterior !"
		Return
	Endif
Endif

nCont ++

oScrollBox:Reset()

If nCont == 1 .or. Mod(nCont,Int((aPosObj[2,3]/2) / 30)) == 0
	If lFMEA4a                  
		//nTamTela := 1400 + - 
		@ nLin  ,003 MSPANEL oPanel1 PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE nTamTela,013 OF oScrollBox
		@ 003	,003 SAY OemToAnsi(STR0026)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Seq."
		@ 003	,036 SAY OemToAnsi(STR0010) 	COLOR CLR_WHITE OF oPanel1 PIXEL //"Item Funcao"
		@ 003	,130 SAY OemToAnsi(STR0038)	COLOR CLR_WHITE OF oPanel1 PIXEL //"Requisito"
		@ 003	,224 SAY OemToAnsi(STR0011)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Modo de Falha Potencial"
		@ 003	,315 SAY OemToAnsi(STR0012)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Efeito Potencial da Falha"
		@ 003	,411 SAY OemToAnsi(STR0013)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Sever"
		@ 003	,438 SAY OemToAnsi(STR0014) 	COLOR CLR_WHITE OF oPanel1 PIXEL //"Class"
		@ 003	,453 SAY OemToAnsi(STR0015)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Causa/Mecanismo Potencial da Falha"
		@ 003	,550 SAY OemToAnsi(STR0016)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Ocorr"
		@ 003	,569 SAY OemToAnsi(STR0017)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Controles Atuais do Projeto - P / D"
		@ 003	,673 SAY OemToAnsi(STR0039)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Causas
		@ 003	,724 SAY OemToAnsi(STR0040)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Modo de Falha
		@ 003	,775 SAY OemToAnsi(STR0018)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Detec"
		@ 003	,798 SAY OemToAnsi(STR0019)		COLOR CLR_WHITE OF oPanel1 PIXEL //"NPR"
		@ 003	,818 SAY OemToAnsi(STR0020)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Acoes Recomendadas"
		@ 003	,908 SAY OemToAnsi(STR0021)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Responsavel"
		@ 003	,1015 SAY OemToAnsi(STR0022)  	COLOR CLR_WHITE OF oPanel1 PIXEL //"Prazo"
		@ 003	,1062 SAY OemToAnsi(STR0023)  	COLOR CLR_WHITE OF oPanel1 PIXEL //"Acoes Tomadas"
		@ 003	,1157 SAY OemToAnsi(STR0041)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Data Efetiva
		@ 003	,1204 SAY OemToAnsi(STR0013)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Sever"
		@ 003	,1222 SAY OemToAnsi(STR0016)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Ocorr"
		@ 003	,1240 SAY OemToAnsi(STR0018)  	COLOR CLR_WHITE OF oPanel1 PIXEL //"Detec"
		@ 003	,1258 SAY OemToAnsi(STR0019)		COLOR CLR_WHITE OF oPanel1 PIXEL //"NPR"		
		
	Else
		nTamTela := 1050
		@ nLin	,001  MSPANEL oPanel1 PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE nTamTela,013 OF oScrollBox
		@ 003	,003 SAY OemToAnsi(STR0026)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Seq."
		@ 003	,026 SAY OemToAnsi(STR0010) 	COLOR CLR_WHITE OF oPanel1 PIXEL //"Item Funcao"
		@ 003	,120 SAY OemToAnsi(STR0011)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Modo de Falha Potencial"
		@ 003	,214 SAY OemToAnsi(STR0012)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Efeito Potencial da Falha"
		@ 003	,305 SAY OemToAnsi(STR0013)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Sever"
		@ 003	,321 SAY OemToAnsi(STR0014) 	COLOR CLR_WHITE OF oPanel1 PIXEL //"Class"
		@ 003	,337 SAY OemToAnsi(STR0015)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Causa/Mecanismo Potencial da Falha"
		@ 003	,431 SAY OemToAnsi(STR0016)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Ocorr"
		@ 003	,448 SAY OemToAnsi(STR0017)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Controles Atuais do Projeto - P / D"
		@ 003	,541 SAY OemToAnsi(STR0018)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Detec"
		@ 003	,559 SAY OemToAnsi(STR0019)		COLOR CLR_WHITE OF oPanel1 PIXEL //"NPR"
		@ 003	,586 SAY OemToAnsi(STR0020)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Acoes Recomendadas"
		@ 003	,680 SAY OemToAnsi(STR0021)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Responsavel"
		@ 003	,777 SAY OemToAnsi(STR0022)  	COLOR CLR_WHITE OF oPanel1 PIXEL //"Prazo"
		@ 003	,819 SAY OemToAnsi(STR0023)  	COLOR CLR_WHITE OF oPanel1 PIXEL //"Acoes Tomadas"
		@ 003	,911 SAY OemToAnsi(STR0013)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Sever"
		@ 003	,927 SAY OemToAnsi(STR0016)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Ocorr"
		@ 003	,945 SAY OemToAnsi(STR0018)  	COLOR CLR_WHITE OF oPanel1 PIXEL //"Detec"
		@ 003	,961 SAY OemToAnsi(STR0019)		COLOR CLR_WHITE OF oPanel1 PIXEL //"NPR"	
	Endif	
	

	nLin += 15
Endif

If MOD(nCont,2) == 0
	oPanel := TPanel():New(nLin,03,"",oScrollBox, , .T., .T.,,/*RGB(200,230,247)*/,nTamTela,30,.T.,.T. )
Else
	oPanel := TPanel():New(nLin,03,"",oScrollBox, , .T., .T.,,,nTamTela,30,.T.,.T. )
Endif

oScrollBox:Refresh()
  
Aadd(aPanels,oPanel)
nx := Len(aPanels) 

If (nOpc == 2 .or. nOpc == 4 .or. nOpc == 5) .and. !lManual
	If !Empty(QK6->QK6_CHAVE1)
		axTextos1 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"A",1, nTamLin,"QKO",axTextos1) //Item Funcao
		axTextos2 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"B",1, nTamLin,"QKO",axTextos2) //Modo de falha
		axTextos3 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"C",1, nTamLin,"QKO",axTextos3) //Efeito da falha
		axTextos4 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"D",1, If(lFMEA4a,12,nTamLin),"QKO",axTextos4) //Causa/Mecanismo
		axTextos5 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"E",1, 8,"QKO",axTextos5) 		//Controles atuais Prevencao
		axTextos6 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"F",1, nTamLin,"QKO",axTextos6) //Acoes recomendadas
		axTextos7 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"G",1, nTamLin,"QKO",axTextos7) //Acoes Tomadas
		axTextos8 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"H",1, 8,"QKO",axTextos8) 		//Controles atuais Deteccao 
		If lFMEA4a
			axTextos9 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"I",1, nTamLin,"QKO",axTextos9) 		//Controles atuais Deteccao
			axTextos10 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"J",1, nTamLin,"QKO",axTextos10) 		//Causas
			axTextos11 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"K",1, nTamLin,"QKO",axTextos11) 		//Modo de Falha
		Endif	
	Endif
	If lFMEA4a
	   	
	   	aGets := {	axTextos1,axTextos9,axTextos2,axTextos3,QK6->QK6_CLASS,QK6->QK6_SEVER,;
					axTextos4,QK6->QK6_OCORR,axTextos5,QK6->QK6_DETEC,QK6->QK6_NPR,;
					axTextos6,QK6->QK6_RESP,QK6->QK6_PRAZO,axTextos7,QK6->QK6_RSEVER,;
					QK6->QK6_ROCORR,QK6->QK6_RDETEC,QK6->QK6_RNPR,QK6->QK6_SEQ,axTextos8,;
					QK6->QK6_CODRES,QK6->QK6_CHAVE1,axTextos10,axTextos11,QK6->QK6_DATEEF,.T.} 					
	
					
	Else
		aGets := {	axTextos1,axTextos2,axTextos3,QK6->QK6_SEVER,QK6->QK6_CLASS,;
					axTextos4,QK6->QK6_OCORR,axTextos5,QK6->QK6_DETEC,QK6->QK6_NPR,;
					axTextos6,QK6->QK6_RESP,QK6->QK6_PRAZO,axTextos7,QK6->QK6_RSEVER,;
					QK6->QK6_ROCORR,QK6->QK6_RDETEC,QK6->QK6_RNPR,QK6->QK6_SEQ,axTextos8,;
					QK6->QK6_CODRES,QK6->QK6_CHAVE1,.T.}
	Endif				
Else
	If Len(aValues) > 0
		cSeq := Val(aValues[Iif(nx-1 > 0,nx-1,1), nItFMEA])+1
		cSeq := StrZero(ProxDez(cSeq),TamSX3("QK6_SEQ")[1])
	Else
		If nTamSeq == 5
			cSeq := "00010"
		Else
			cSeq := "010"
		EndIf		
	Endif
	If lFMEA4a
		aGets := {	axTextos1,axTextos9,axTextos2,axTextos3,Space(02),Space(02),;
					axTextos4,Space(02),axTextos5,Space(02),Space(04),;
					axTextos6,Space(30),CtoD(" / / "),axTextos7,Space(02),;
					Space(02),Space(02),Space(04),cSeq,axTextos8,Space(10),;
					Space(08),axTextos10,axTextos11,CtoD(" / / "),.T.}
	Else		
		aGets := {	axTextos1,axTextos2,axTextos3,Space(02),Space(02),;
					axTextos4,Space(02),axTextos5,Space(02),Space(04),;
					axTextos6,Space(30),CtoD(" / / "),axTextos7,Space(02),;
					Space(02),Space(02),Space(04),cSeq,axTextos8,Space(10),;
					Space(08),.T.}
	Endif			
Endif

Aadd(aValues,aGets)
If lFMEA4a
	If Empty(aValues[nx,23])
		cChave := GetSXENum("QK6", "QK6_CHAVE1",,3)
	
		While (GetSX8Len() > nSaveSx8)
			ConfirmSX8()
		End
	
		aValues[nx,23] := cChave
	Endif
	// 19o Get - Item sequencial (1o na tela)
	
	cGet19	:= "aValues["+Str(nx,nTamSeq)+",20]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet19+":=u,"+cGet19+")}")
	bValid	:= {|u| AtuaCpo(nx)}
	                                                      
	oGet19 	:= TGet():New( 01, 01, bBlock,oPanel,10,10,PesqPict("QK6","QK6_SEQ"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet19:Cargo := Str(nx,nTamSeq)+",20"

	// 1o Get - Item Funcao
	cGet1 	:= "aValues["+Str(nx,nTamSeq)+",1]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet1+":=u,"+cGet1+")}")
	                                                        
	oGet1 := TMultiGet():New(01,30,bBlock, oPanel, 93, 25, , .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	    
	oGet1:Cargo := Str(nx,nTamSeq)+",01"

	// 2o Get - Requisito
	cGet22 	:= "aValues["+Str(nx,nTamSeq)+",2]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet22+":=u,"+cGet22+")}")
	                                                        
	oGet22 := TMultiGet():New(01,125,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	     
	oGet22:Cargo := Str(nx,nTamSeq)+",02"

	// 3o Get - Modo de Falha Potencial
	cGet2 	:= "aValues["+Str(nx,nTamSeq)+",3]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet2+":=u,"+cGet2+")}")
	                                                        
	oGet2 := TMultiGet():New(01,219,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	     
	oGet2:Cargo := Str(nx,nTamSeq)+",03"

	// 4o Get - Efeito Potencial da Falha
	cGet3 	:= "aValues["+Str(nx,nTamSeq)+",4]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet3+":=u,"+cGet3+")}")
	                                                        
	oGet3 := TMultiGet():New(01,313,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	     
	oGet3:Cargo := Str(nx,nTamSeq)+",04"

	// 4o Get - Severidade
	
	cGet4	:= "aValues["+Str(nx,nTamSeq)+",6]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet4+":=u,"+cGet4+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                        
	oGet4 := TGet():New( 01, 410, bBlock,oPanel,10,10, PesqPict("QK6","QK6_SEVER"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)
	     
	oGet4:Cargo := Str(nx,nTamSeq)+",06"

	// 6o Get - Classificacao
	
	cGet6	:= "aValues["+Str(nx,nTamSeq)+",5]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet6+":=u,"+cGet6+")}")

    // 6o Get - Causa/Mecanismo Potencial da Falha

	cGet61	:= "aValues["+Str(nx,nTamSeq)+",7]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet61+":=u,"+cGet61+")}")
	
	oGet61 := TMultiGet():New(01,453,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet61:Cargo := Str(nx,nTamSeq)+",07"
                              
	// 7o Get - Ocorrencia
	
	cGet7	:= "aValues["+Str(nx,nTamSeq)+",8]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet7+":=u,"+cGet7+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                        
	oGet7 := TGet():New( 01, 549, bBlock,oPanel,10,10,PesqPict("QK6","QK6_OCORR"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet7:Cargo := Str(nx,nTamSeq)+",08"

	// 8o Get - Controles atuais do projeto prevencao
	
	cGet8	:= "aValues["+Str(nx,nTamSeq)+",9]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet8+":=u,"+cGet8+")}")
	
	oGet8 := TMultiGet():New(01,569,bBlock, oPanel, 46, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet8:Cargo := Str(nx,nTamSeq)+",09"
	
	// 20o Get - Controles atuais do projeto deteccao (9o na tela)
	
	cGet20	:= "aValues["+Str(nx,nTamSeq)+",21]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet20+":=u,"+cGet20+")}")
	
	oGet20 := TMultiGet():New(01,620,bBlock, oPanel, 46, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet20:Cargo := Str(nx,3)+",21"
	
	//Causa
	
	cGet23	:= "aValues["+Str(nx,nTamSeq)+",24]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet23+":=u,"+cGet23+")}")
	
	oGet23 := TMultiGet():New(01,671,bBlock, oPanel, 46, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet23:Cargo := Str(nx,3)+",24"
	
	
	// Modo de Falha
	
	cGet24	:= "aValues["+Str(nx,nTamSeq)+",25]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet24+":=u,"+cGet24+")}")
	
	oGet24 := TMultiGet():New(01,722,bBlock, oPanel, 46, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet24:Cargo := Str(nx,3)+",25"

	// 9o Get - Deteccao
	
	cGet9	:= "aValues["+Str(nx,nTamSeq)+",10]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet9+":=u,"+cGet9+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                      
	oGet9 := TGet():New( 01,773, bBlock,oPanel,10,10,PesqPict("QK6","QK6_DETEC"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet9:Cargo := Str(nx,nTamSeq)+",10"
	
	// 10o Get - NPR
	
	cGet10	:= "aValues["+Str(nx,nTamSeq)+",11]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet10+":=u,"+cGet10+")}")
	                                                      
	oGet10 	:= TGet():New( 01, 792, bBlock,oPanel,20,10,PesqPict("QK6","QK6_NPR"),,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/,,,,.T.)  
	     
	oGet10:Cargo := Str(nx,nTamSeq)+",11"

	// 11o Get - Acoes Recomendadas
	
	cGet11	:= "aValues["+Str(nx,nTamSeq)+",12]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet11+":=u,"+cGet11+")}")
	
	oGet11 	:= TMultiGet():New(01,812,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet11:Cargo := Str(nx,nTamSeq)+",12"

	// 12o Get - Responsavel
	
	cGet12	:= "aValues["+Str(nx,nTamSeq)+",13]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet12+":=u,"+cGet12+")}")
	bWhen	:= {|u| Empty(aValues[nx,22])}
	                                                      
	oGet12 	:= TGet():New( 15,907, bBlock,oPanel,100,10,PesqPict("QK6","QK6_RESP"),,;
	     ,,,,,.T.,,,bWhen)
	     
	oGet12:Cargo := Str(nx,nTamSeq)+",13"

	cGet21	:= "aValues["+Str(nx,nTamSeq)+",22]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet21+":=u,"+cGet21+")}")
	bValid	:= {|u| BuscaSXB(u,nx,oGet12)}
	
	oGet21	:= TGet():New( 01,907, bBlock,oPanel,40,10,PesqPict("QK6","QK6_CODRES"),bValid,;
	     , , , , ,.T., , , , , , , , ,ConSX3("QK6_CODRES"))
	    
	oGet21:Cargo := Str(nx,nTamSeq)+",22"

	// 13o Get - Prazo
	
	cGet13	:= "aValues["+Str(nx,nTamSeq)+",14]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet13+":=u,"+cGet13+")}")
	                                                      
	oGet13 	:= TGet():New( 01,1012, bBlock,oPanel,40,10,,,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet13:Cargo := Str(nx,nTamSeq)+",14"

	// 14o Get - Acoes tomadas
	
	cGet14	:= "aValues["+Str(nx,nTamSeq)+",15]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet14+":=u,"+cGet14+")}")
	
	oGet14 	:= TMultiGet():New(01,1057,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet14:Cargo := Str(nx,nTamSeq)+",15"
	//Data Efetiva     
	cGet25	:= "aValues["+Str(nx,nTamSeq)+",26]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet25+":=u,"+cGet25+")}")
	                                                      
	oGet25 	:= TGet():New( 01, 1155, bBlock,oPanel,40,10,,,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet25:Cargo := Str(nx,nTamSeq)+",26"

	// 15o Get - Severidade 
	cGet15	:= "aValues["+Str(nx,nTamSeq)+",16]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet15+":=u,"+cGet15+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                 
	                                                      
	oGet15 	:= TGet():New( 01,1202, bBlock,oPanel,10,10,PesqPict("QK6","QK6_RSEVER"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet15:Cargo := Str(nx,nTamSeq)+",16"
	
	// 16o Get - Ocorrencia
	
	cGet16	:= "aValues["+Str(nx,nTamSeq)+",17]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet16+":=u,"+cGet16+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                      
	oGet16 	:= TGet():New( 01,1220, bBlock,oPanel,10,10,PesqPict("QK6","QK6_ROCORR"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet16:Cargo := Str(nx,nTamSeq)+",17"

	// 17o Get - Deteccao
	
	cGet17	:= "aValues["+Str(nx,nTamSeq)+",18]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet17+":=u,"+cGet17+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                      
	oGet17 	:= TGet():New( 01,1238, bBlock,oPanel,10,10,PesqPict("QK6","QK6_RDETEC"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet17:Cargo := Str(nx,nTamSeq)+",18"

	// 18o Get - NPR
	
	cGet18	:= "aValues["+Str(nx,nTamSeq)+",19]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet18+":=u,"+cGet18+")}")
	                                                      
	oGet18 	:= TGet():New( 01,1256, bBlock,oPanel,10,10,PesqPict("QK6","QK6_RNPR"),,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/,,,,.T.)  
	     
	oGet18:Cargo := Str(nx,nTamSeq)+",19"

	Aadd(aOGets,{	oGet1,oGet22,oGet2,oGet3,oGet4,oGet5,;
				oGet61,oGet7,oGet8,oGet20,oGet23,oGet24,oGet9,;
				oGet10,oGet11,oGet12,oGet21,oGet13,oGet14,oGet25,;
				oGet15,oGet16,oGet17,oGet18})        

	@ 001,1280 BUTTON oBtn  PROMPT OemToAnsi(STR0024)  OF oPanel Pixel Size 65,13 ACTION QPP120REMO(nx,nOpc) //"Excluir / Recuperar"
	@ 001,424 BITMAP oBmp REPOSITORY SIZE 100,100 OF oPanel NOBORDER PIXEL
	
	If !Empty(aValues[nx,5])
		oBmp:SetBmp(aValues[nx,5])
	Else
		oBmp:SetBmp("note")
	Endif

Else
	If Empty(aValues[nx,22])
		cChave := GetSXENum("QK6", "QK6_CHAVE1",,3)
	
		While (GetSX8Len() > nSaveSx8)
			ConfirmSX8()
		End
	
		aValues[nx,22] := cChave
	Endif

	// 19o Get - Item sequencial (1o na tela)
	
	cGet19	:= "aValues["+Str(nx,nTamSeq)+",19]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet19+":=u,"+cGet19+")}")
	bValid	:= {|u| AtuaCpo(nx)}
	                                                      
	oGet19 	:= TGet():New( 01, 01, bBlock,oPanel,10,10,PesqPict("QK6","QK6_SEQ"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet19:Cargo := Str(nx,nTamSeq)+",19"
	
	
	// 1o Get - Item Funcao
	cGet1 	:= "aValues["+Str(nx,nTamSeq)+",1]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet1+":=u,"+cGet1+")}")
	                                                        
	oGet1 := TMultiGet():New(01,20,bBlock, oPanel, 93, 25, , .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	    
	oGet1:Cargo := Str(nx,nTamSeq)+",01"
	
	// 2o Get - Modo de Falha Potencial
	cGet2 	:= "aValues["+Str(nx,nTamSeq)+",2]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet2+":=u,"+cGet2+")}")
	                                                        
	oGet2 := TMultiGet():New(01,115,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	     
	oGet2:Cargo := Str(nx,nTamSeq)+",02"
	
	// 3o Get - Efeito Potencial da Falha
	cGet3 	:= "aValues["+Str(nx,nTamSeq)+",3]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet3+":=u,"+cGet3+")}")
	                                                        
	oGet3 := TMultiGet():New(01,209,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	     
	oGet3:Cargo := Str(nx,nTamSeq)+",03"
	
	// 4o Get - Severidade
	
	cGet4	:= "aValues["+Str(nx,nTamSeq)+",4]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet4+":=u,"+cGet4+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                        
	oGet4 := TGet():New( 01, 303, bBlock,oPanel,10,10, PesqPict("QK6","QK6_SEVER"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)
	     
	oGet4:Cargo := Str(nx,nTamSeq)+",04"
	
	// 5o Get - Classificacao
	
	cGet5	:= "aValues["+Str(nx,nTamSeq)+",5]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet5+":=u,"+cGet5+")}")
	                                                        
	
	//oGet5 := TGet():New( 01, 300, bBlock,oPanel,10,10,"@BMP",/* <{ValidFunc}>*/,;
	//     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	//oGet5:Cargo := Str(nx,3)+",05"
	
	// 6o Get - Causa/Mecanismo Potencial da Falha
	
	cGet6	:= "aValues["+Str(nx,nTamSeq)+",6]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet6+":=u,"+cGet6+")}")
	
	oGet6 := TMultiGet():New(01,335,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet6:Cargo := Str(nx,nTamSeq)+",06"
	                              
	// 7o Get - Ocorrencia
	
	cGet7	:= "aValues["+Str(nx,nTamSeq)+",7]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet7+":=u,"+cGet7+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                        
	oGet7 := TGet():New( 01, 429, bBlock,oPanel,10,10,PesqPict("QK6","QK6_OCORR"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet7:Cargo := Str(nx,nTamSeq)+",07"
	
	// 8o Get - Controles atuais do projeto prevencao
	
	cGet8	:= "aValues["+Str(nx,nTamSeq)+",8]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet8+":=u,"+cGet8+")}")
	
	oGet8 := TMultiGet():New(01,445,bBlock, oPanel, 46, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet8:Cargo := Str(nx,nTamSeq)+",08"
	
	// 20o Get - Controles atuais do projeto deteccao (9o na tela)
	
	cGet20	:= "aValues["+Str(nx,nTamSeq)+",20]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet20+":=u,"+cGet20+")}")
	
	oGet20 := TMultiGet():New(01,492,bBlock, oPanel, 46, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet20:Cargo := Str(nx,3)+",20"
	
	                                                         
	// 9o Get - Deteccao
	
	cGet9	:= "aValues["+Str(nx,nTamSeq)+",9]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet9+":=u,"+cGet9+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                      
	oGet9 := TGet():New( 01, 539, bBlock,oPanel,10,10,PesqPict("QK6","QK6_DETEC"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet9:Cargo := Str(nx,nTamSeq)+",09"
	
	// 10o Get - NPR
	
	cGet10	:= "aValues["+Str(nx,nTamSeq)+",10]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet10+":=u,"+cGet10+")}")
	                                                      
	oGet10 	:= TGet():New( 01, 555, bBlock,oPanel,20,10,PesqPict("QK6","QK6_NPR"),,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/,,,,.T.)  
	     
	oGet10:Cargo := Str(nx,nTamSeq)+",10"
	
	// 11o Get - Acoes Recomendadas
	
	cGet11	:= "aValues["+Str(nx,nTamSeq)+",11]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet11+":=u,"+cGet11+")}")
	
	oGet11 	:= TMultiGet():New(01,581,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet11:Cargo := Str(nx,nTamSeq)+",11"
	
	// 12o Get - Responsavel
	
	cGet12	:= "aValues["+Str(nx,nTamSeq)+",12]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet12+":=u,"+cGet12+")}")
	bWhen	:= {|u| Empty(aValues[nx,21])}
	                                                      
	oGet12 	:= TGet():New( 15, 675, bBlock,oPanel,100,10,PesqPict("QK6","QK6_RESP"),,;
	     ,,,,,.T.,,,bWhen)
	     
	oGet12:Cargo := Str(nx,nTamSeq)+",12"
	
	// 12(b)o Get - Codigo do Responsavel (21 no array)
	
	cGet21	:= "aValues["+Str(nx,nTamSeq)+",21]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet21+":=u,"+cGet21+")}")
	bValid	:= {|u| BuscaSXB(u,nx,oGet12)}
	
	oGet21	:= TGet():New( 01, 675, bBlock,oPanel,40,10,PesqPict("QK6","QK6_CODRES"),bValid,;
	     , , , , ,.T., , , , , , , , ,ConSX3("QK6_CODRES"))
	    
	oGet21:Cargo := Str(nx,nTamSeq)+",21"
	
	
	// 13o Get - Prazo
	
	cGet13	:= "aValues["+Str(nx,nTamSeq)+",13]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet13+":=u,"+cGet13+")}")
	                                                      
	oGet13 	:= TGet():New( 01, 775, bBlock,oPanel,40,10,,,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet13:Cargo := Str(nx,nTamSeq)+",13"
	
	
	// 14o Get - Acoes tomadas
	
	cGet14	:= "aValues["+Str(nx,nTamSeq)+",14]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet14+":=u,"+cGet14+")}")
	
	oGet14 	:= TMultiGet():New(01,815,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet14:Cargo := Str(nx,nTamSeq)+",14"
	
	// 15o Get - Severidade 
	cGet15	:= "aValues["+Str(nx,nTamSeq)+",15]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet15+":=u,"+cGet15+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                      
	oGet15 	:= TGet():New( 01, 909, bBlock,oPanel,10,10,PesqPict("QK6","QK6_RSEVER"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet15:Cargo := Str(nx,nTamSeq)+",15"
	
	// 16o Get - Ocorrencia
	
	cGet16	:= "aValues["+Str(nx,nTamSeq)+",16]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet16+":=u,"+cGet16+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                      
	oGet16 	:= TGet():New( 01, 925, bBlock,oPanel,10,10,PesqPict("QK6","QK6_ROCORR"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet16:Cargo := Str(nx,nTamSeq)+",16"
	
	// 17o Get - Deteccao
	
	cGet17	:= "aValues["+Str(nx,nTamSeq)+",17]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet17+":=u,"+cGet17+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                      
	oGet17 	:= TGet():New( 01, 941, bBlock,oPanel,10,10,PesqPict("QK6","QK6_RDETEC"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet17:Cargo := Str(nx,nTamSeq)+",17"
	
	// 18o Get - NPR
	
	cGet18	:= "aValues["+Str(nx,nTamSeq)+",18]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet18+":=u,"+cGet18+")}")
	                                                      
	oGet18 	:= TGet():New( 01, 957, bBlock,oPanel,10,10,PesqPict("QK6","QK6_RNPR"),,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/,,,,.T.)  
	     
	oGet18:Cargo := Str(nx,nTamSeq)+",18"
	
	Aadd(aOGets,{	oGet1,oGet2,oGet3,oGet4,oGet5,;
					oGet6,oGet7,oGet8,oGet9,oGet10,;
					oGet11,oGet12,oGet13,oGet14,oGet15,;
					oGet16,oGet17,oGet18,oGet19,oGet20,oGet21})
	 
	@ 001,985 BUTTON oBtn  PROMPT OemToAnsi(STR0024)  OF oPanel Pixel Size 65,13 ACTION QPP120REMO(nx,nOpc) //"Excluir / Recuperar"
	@ 001,319 BITMAP oBmp REPOSITORY SIZE 030,030 OF oPanel NOBORDER PIXEL
	
	If !Empty(aValues[nx,5])
		oBmp:SetBmp(aValues[nx,5])
	Else
		oBmp:SetBmp("note")
	Endif
Endif
oBmp:Refresh()
oBmp:lTransparent 	:= .T.
oBmp:cToolTip		:= STR0027 //"Duplo Click para escolher caracteristica"
oBmp:BlDblClick		:= {|o| QPPA010BMP(nOpc,nX,oBmp,aPanels,aValues,0)}

If nOpc == 2 .or. nOpc == 5
	oGet1:lReadOnly 	:= .T.
	oGet2:lReadOnly 	:= .T.	
	oGet3:lReadOnly 	:= .T.	
	oGet4:lReadOnly 	:= .T.	
//	oGet5:lReadOnly 	:= .T.
	If lFMEA4a
		oGet61:lReadOnly 	:= .T.	
		oGet23:lReadOnly    := .T.

	Else
		oGet6:lReadOnly 	:= .T.	
	Endif	
	oGet7:lReadOnly 	:= .T.
	oGet8:lReadOnly 	:= .T.	
	oGet9:lReadOnly 	:= .T.	
	oGet10:lReadOnly 	:= .T.	
	oGet11:lReadOnly 	:= .T.	
	oGet12:lReadOnly 	:= .T.	
	oGet13:lReadOnly 	:= .T.	
	oGet14:lReadOnly 	:= .T.	
	oGet15:lReadOnly 	:= .T.	
	oGet16:lReadOnly 	:= .T.	
	oGet17:lReadOnly 	:= .T.	
	oGet18:lReadOnly 	:= .T.
	oGet19:lReadOnly 	:= .T.
	oGet20:lReadOnly 	:= .T.
	oGet21:lReadOnly 	:= .T.
	oBmp:lReadOnly 		:= .T.
Endif

nLin += 27

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PP120TUDOK³ Autor ³ Robson Ramiro A Olivei³ Data ³ 03/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida Inclusao                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP120TUDOK()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpc - Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PP120TUDOK(nOpc)

Local lRetorno	:= .T.
Local nIt
Local nTot
Local nCont, nCont2
Local cComp
Local nItFMEA

If lFMEA4a
	nItFMEA := 20
Else
	nItFMEA := 19
Endif	

For nIt := 1 To Len(aValues)
	If !aValues[nIt, Len(aValues[nIt])] // Item deletado
		nTot++
	Endif
Next nIt

If Empty(M->QK5_PECA) .or. Empty(M->QK5_REV) .or. nTot == Len(aValues)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
EndIf

If INCLUI
	If !ExistChav("QK5",M->QK5_PECA+M->QK5_REV)
		lRetorno := .F.
		Help(" ",1,"JAGRAVADO")  // Campo ja Existe
	Endif
	If !ExistCpo("QK1",M->QK5_PECA+M->QK5_REV)
		lRetorno := .F.
		Help(" ",1,"REGNOIS")  // Nao existe amarracao
	Endif
Endif

For nCont := 1 To Len(aValues)
	If aValues[nCont,Len(aValues[nCont])] // Item nao deletado
		
		cComp := aValues[nCont,nItFMEA]
		
		If Empty(aValues[nCont,nItFMEA])
			lRetorno := .F.
			Help(" ",1,"QPPSEQFMEA") // "Exite Sequencia sem numeracao !"
			Exit
		Endif

		For nCont2 := 1 To Len(aValues)
		
			If cComp == aValues[nCont2,nItFMEA] .and. nCont <> nCont2 .and. ;
				aValues[nCont2,Len(aValues[nCont2])]

				lRetorno := .F.
				nCont := nCont2 := Len(aValues)
				Help(" ",1,"QPPSEQDUPL") // "Exite Sequencia duplicada !, altere-a"
			Endif

		Next nCont2

	Endif

Next nCont
If ExistBlock("QP120TOK")
	lRetorno := ExecBlock("QP120TOK",.F.,.F.,{aValues})
EndIf

Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A120GRAV  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 29.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravacao dos dados - inclusao/alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A120GRAV(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A120Grav(nOpc)
Local nIt           := 0
Local nCont         := 0
Local nNumItem      := 0
Local bCampo		:= { |nCPO| Field(nCPO) }
Local lGraOk 		:= .T.   // Indica se todas as gravacoes obtiveram sucesso
Local cEspecie		:= "QPPA120"
Local axTextos1		:= {}
Local axTextos2		:= {}
Local axTextos3		:= {}
Local axTextos4		:= {}
Local axTextos5		:= {}
Local axTextos6		:= {}
Local axTextos7		:= {}
Local aArea         := {}
Local cAtividade	:= "01 " // Definido no ID - QKZ
Local nTamLin		:= 17
Local nItFMEA

If lFMEA4a
	nItFMEA := 20
Else
	nItFMEA := 19
Endif

Begin Transaction

DbSelectArea("QK5")
DbSetOrder(1)

If INCLUI
	RecLock("QK5",.T.)
Else
	RecLock("QK5",.F.)
Endif

For nCont := 1 To FCount()

	If "FILIAL"$Field(nCont)
		FieldPut(nCont,xFilial("QK5"))
	Else
		FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
	Endif

Next nCont

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos nao informados                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QK5->QK5_REVINV := Inverte(QK5->QK5_REV)

MsUnLock()
FKCOMMIT()
If !Empty(QK5->QK5_DATA) .and. !Empty(QK5->QK5_APRPOR)
	QPP_CRONO(QK5->QK5_PECA,QK5->QK5_REV,cAtividade) // QPPXFUN - Atualiza Cronograma
Endif


DbSelectArea("QK6")
DbSetOrder(1)

nNumItem := 1  // Contador para os Itens

aValues := Asort(aValues,,,{|x,y| x[nItFMEA] < y[nItFMEA]}) // Ordena por ordem de Itens
	
For nIt := 1 To Len(aValues)
	aArea      := GetArea()
	If aValues[nIt,Len(aValues[nIt])] // Verifica se item foi excluido Item Excluido

		If ALTERA
		    QK6->(DBGotop())		
			If DbSeek(xFilial("QK6")+ M->QK5_PECA + M->QK5_REV + StrZero(nIt,TamSX3("QK6_ITEM")[1]) )
				RecLock("QK6",.F.)
			Else
				QK6->(DbSetOrder(4))
				If !DbSeek(xFilial("QK6")+ M->QK5_PECA + M->QK5_REV + aValues[nIt,nItFMEA] )
					RecLock("QK6",.T.)
				Else 
					RecLock("QK6",.F.)					
				EndIf      
				QK6->(DbSetOrder(1))
			Endif
		Else	                   
			RecLock("QK6",.T.)
		Endif
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Campos Chave nao informados                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QK6->QK6_FILIAL	:= xFilial("QK6")
		QK6->QK6_PECA 	:= M->QK5_PECA
		QK6->QK6_REV	:= M->QK5_REV
		QK6->QK6_REVINV	:= Inverte(QK5->QK5_REV)
		QK6->QK6_FILRES	:= cFilAnt
                                                                              
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle de itens                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QK6->QK6_ITEM 	:= StrZero(nIt,TamSX3("QK6_ITEM")[1])
		If lFMEA4a
			QK6->QK6_SEVER 	:= aValues[nIt,06]
			QK6->QK6_CLASS 	:= aValues[nIt,05]
			QK6->QK6_OCORR 	:= aValues[nIt,08]
			QK6->QK6_DETEC 	:= aValues[nIt,10]
			QK6->QK6_NPR   	:= aValues[nIt,11]
			QK6->QK6_RESP	:= aValues[nIt,13]
			QK6->QK6_PRAZO 	:= aValues[nIt,14]
			QK6->QK6_RSEVER	:= aValues[nIt,16]
			QK6->QK6_ROCORR	:= aValues[nIt,17]
			QK6->QK6_RDETEC	:= aValues[nIt,18]
			QK6->QK6_RNPR	:= aValues[nIt,19]
			QK6->QK6_SEQ	:= aValues[nIt,20]
			QK6->QK6_CODRES	:= aValues[nIt,22]
			QK6->QK6_DATEEF	:= aValues[nIt,26]

			If !Empty(aValues[nIt,1]) // Item funcao
				QK6->QK6_CHAVE1	:= aValues[nIt,23]
	 			axTextos1 := GeraText(nIt,nTamLin,"A")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"A",1,@axTextos1) 	//QPPXFUN
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"A")
			Endif
	
			If !Empty(aValues[nIt,2]) // Requisito
				QK6->QK6_CHAVE1	:= aValues[nIt,23]
	 			axTextos9 := GeraText(nIt,nTamLin,"I")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"I",1,@axTextos9) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"I")
			Endif

			If !Empty(aValues[nIt,3]) // Modo de falha
				QK6->QK6_CHAVE1	:= aValues[nIt,23]
	 			axTextos2 := GeraText(nIt,nTamLin,"B")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"B",1,@axTextos2) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"B")
			Endif
	
			If !Empty(aValues[nIt,4]) // Efeito da falha
				QK6->QK6_CHAVE1	:= aValues[nIt,23]
	 			axTextos3 := GeraText(nIt,nTamLin,"C")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"C",1,@axTextos3) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"C")
			Endif
			
			If !Empty(aValues[nIt,7]) // Causa/Mecanismo Potencial da Falha
				QK6->QK6_CHAVE1	:= aValues[nIt,23]
	 			axTextos4 := GeraText(nIt,12,"D")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"D",1,@axTextos4) 	
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"D")
			Endif
			
			If !Empty(aValues[nIt,9]) // Controles atuais do projeto prevencao
				QK6->QK6_CHAVE1	:= aValues[nIt,23]
	 			axTextos5 := GeraText(nIt,10,"E")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"E",1,@axTextos5) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"E")
			Endif
	
			If !Empty(aValues[nIt,21]) // Controles atuais do projeto deteccao
				QK6->QK6_CHAVE1	:= aValues[nIt,23]
	 			axTextos5 := GeraText(nIt,8,"H")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"H",1,@axTextos5) 	
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"H")
			Endif
				
				If !Empty(aValues[nIt,24]) // Causas
					QK6->QK6_CHAVE1	:= aValues[nIt,23]
		 			axTextos10 := GeraText(nIt,8,"J")
					QO_GrvTxt(aValues[nIt,23],cEspecie+"J",1,@axTextos10) 	
				ElseIf ALTERA
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"J")
				Endif
			
				If !Empty(aValues[nIt,25]) // Modos de Falha
					QK6->QK6_CHAVE1	:= aValues[nIt,23]
		 			axTextos11 := GeraText(nIt,8,"K")
					QO_GrvTxt(aValues[nIt,23],cEspecie+"K",1,@axTextos11) 	
				ElseIf ALTERA
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"K")
				Endif
			

	
			If !Empty(aValues[nIt,12]) // Acoes Recomendadas
				QK6->QK6_CHAVE1	:= aValues[nIt,23]
	 			axTextos6 := GeraText(nIt,nTamLin,"F")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"F",1,@axTextos6) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"F")
			Endif
	
			If !Empty(aValues[nIt,15]) // Acoes tomadas
				QK6->QK6_CHAVE1	:= aValues[nIt,23]
	 			axTextos7 := GeraText(nIt,nTamLin,"G")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"G",1,@axTextos7) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"G")
			Endif


		Else
			QK6->QK6_SEVER 	:= aValues[nIt,04]
			QK6->QK6_CLASS 	:= aValues[nIt,05]
			QK6->QK6_OCORR 	:= aValues[nIt,07]
			QK6->QK6_DETEC 	:= aValues[nIt,09]
			QK6->QK6_NPR   	:= aValues[nIt,10]
			QK6->QK6_RESP	:= aValues[nIt,12]
			QK6->QK6_PRAZO 	:= aValues[nIt,13]
			QK6->QK6_RSEVER	:= aValues[nIt,15]
			QK6->QK6_ROCORR	:= aValues[nIt,16]
			QK6->QK6_RDETEC	:= aValues[nIt,17]
			QK6->QK6_RNPR	:= aValues[nIt,18]
			QK6->QK6_SEQ	:= aValues[nIt,19]
			QK6->QK6_CODRES	:= aValues[nIt,21]

			If !Empty(aValues[nIt,1]) // Item funcao
				QK6->QK6_CHAVE1	:= aValues[nIt,22]
	 			axTextos1 := GeraText(nIt,nTamLin,"A")
				QO_GrvTxt(aValues[nIt,22],cEspecie+"A",1,@axTextos1) 	//QPPXFUN
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"A")
			Endif
	
			If !Empty(aValues[nIt,2]) // Modo de falha
				QK6->QK6_CHAVE1	:= aValues[nIt,22]
	 			axTextos2 := GeraText(nIt,nTamLin,"B")
				QO_GrvTxt(aValues[nIt,22],cEspecie+"B",1,@axTextos2) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"B")
			Endif
	
			If !Empty(aValues[nIt,3]) // Efeito da falha
				QK6->QK6_CHAVE1	:= aValues[nIt,22]
	 			axTextos3 := GeraText(nIt,nTamLin,"C")
				QO_GrvTxt(aValues[nIt,22],cEspecie+"C",1,@axTextos3) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"C")
			Endif
			
			If !Empty(aValues[nIt,6]) // Causa/Mecanismo Potencial da Falha
				QK6->QK6_CHAVE1	:= aValues[nIt,22]
	 			axTextos4 := GeraText(nIt,10,"D")
				QO_GrvTxt(aValues[nIt,22],cEspecie+"D",1,@axTextos4) 	
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"D")
			Endif
			
			If !Empty(aValues[nIt,8]) // Controles atuais do projeto prevencao
				QK6->QK6_CHAVE1	:= aValues[nIt,22]
	 			axTextos5 := GeraText(nIt,8,"E")
				QO_GrvTxt(aValues[nIt,22],cEspecie+"E",1,@axTextos5) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"E")
			Endif
	
			If !Empty(aValues[nIt,20]) // Controles atuais do projeto deteccao
				QK6->QK6_CHAVE1	:= aValues[nIt,22]
	 			axTextos5 := GeraText(nIt,8,"H")
				QO_GrvTxt(aValues[nIt,22],cEspecie+"H",1,@axTextos5) 	
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"H")
			Endif
	
			If !Empty(aValues[nIt,11]) // Acoes Recomendadas
				QK6->QK6_CHAVE1	:= aValues[nIt,22]
	 			axTextos6 := GeraText(nIt,nTamLin,"F")
				QO_GrvTxt(aValues[nIt,22],cEspecie+"F",1,@axTextos6) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"F")
			Endif
	
			If !Empty(aValues[nIt,14]) // Acoes tomadas
				QK6->QK6_CHAVE1	:= aValues[nIt,22]
	 			axTextos7 := GeraText(nIt,nTamLin,"G")
				QO_GrvTxt(aValues[nIt,22],cEspecie+"G",1,@axTextos7) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"G")
			Endif
		Endif
		MsUnlock()
		FKCOMMIT()
    Else
 		QK6->(dbSetOrder(1))
 		If DbSeek(xFilial("QK6")+ M->QK5_PECA + M->QK5_REV + StrZero(nIt,TamSX3("QK6_ITEM")[1]))
 			If !Empty(QK6->QK6_CHAVE1)
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"A")	//QPPXFUN
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"B")
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"C")
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"D")
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"E")
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"F")
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"G")
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"H")
				If lFMEA4a
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"I")				
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"J")				
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"K")				
				Endif
			Endif

			DbSelectArea("QK6")	
			RecLock("QK6",.F.)
			DbDelete()
			MsUnlock()
			FKCOMMIT()
		Else
	 		DbSetOrder(4)
	 		If DbSeek(xFilial("QK6")+ M->QK5_PECA + M->QK5_REV + aValues[nIt,19])
	 			If !Empty(QK6->QK6_CHAVE1)
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"A")	//QPPXFUN
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"B")
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"C")
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"D")
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"E")
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"F")
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"G")
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"H")
					If lFMEA4a
						QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"I")				
						QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"J")				
						QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"K")				
					Endif					
				Endif
	
				DbSelectArea("QK6")	
				RecLock("QK6",.F.)
				DbDelete()
				MsUnlock()
				FKCOMMIT()
	        EndIf
	        DbSetOrder(1)
		Endif
	Endif
	RestArea(aArea)
Next nIt

End Transaction
				
Return lGraOk

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GeraText  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 29.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Transformacao do campo memo para gravacao no QKO           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GeraText(ExpN1,ExpN2,ExpC1)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero do Item  									  ³±±
±±³          ³ ExpN2 = Tamanho da linha 								  ³±±
±±³          ³ ExpC1 = Tipo a ser gerado     							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function GeraText(nIt, nTamlin, cTipo)

Local cDescricao
Local nLinTotal
Local nPasso
Local axTextos := {}
Local nLi
Local nPos
Local nLocal
Local lSepSil := .F.

cDescricao := ""
If lFMEA4a
	Do Case
		Case cTipo == "A" ; nLocal := 1
		Case cTipo == "B" ; nLocal := 3
		Case cTipo == "C" ; nLocal := 4
		Case cTipo == "D" ; nLocal := 7		
		Case cTipo == "E" ; nLocal := 9
		Case cTipo == "F" ; nLocal := 12
		Case cTipo == "G" ; nLocal := 15
		Case cTipo == "H" ; nLocal := 21
		Case cTipo == "J" ; nLocal := 24
		Case cTipo == "K" ; nLocal := 25
	EndCase
Else   
	Do Case
		Case cTipo == "A" ; nLocal := 1
		Case cTipo == "B" ; nLocal := 2
		Case cTipo == "C" ; nLocal := 3
		Case cTipo == "D" ; nLocal := 6		
		Case cTipo == "E" ; nLocal := 8
		Case cTipo == "F" ; nLocal := 11
		Case cTipo == "G" ; nLocal := 14
		Case cTipo == "H" ; nLocal := 20
	EndCase
Endif
//Tratamento para FMEA 4a Edicao
If cTipo == "I"
	nLocal := 2
Endif
			
nLinTotal  := MlCount( aValues[nIt,nLocal] , nTamLin)

If ChkFile("QAL")
	lSepSil := .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza vetor com o texto digitado		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nPasso := 1 to nLinTotal

	cDescricao += MemoLine( aValues[nIt,nLocal], nTamLin, nPasso ) + Chr(13)+Chr(10)
	
Next nPasso
		
nLi := 1

nPos := ascan(axTextos, {|x| x[1] == nLi })

If nPos == 0
	Aadd(axTextos, { nLi, cDescricao } )
Else
	axTextos[nPos][2] := cDescricao
Endif

Return(axTextos)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP120REMO³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 30.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclui Item                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP120REMO(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Linha que esta posicionado						  ³±±
±±³          ³ ExpN2 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP120REMO(nx,nOpc)
Local ny
Local nTmArr

If lFMEA4a
	nTmArr := 21
Else
	nTmArr := 21
Endif

If nOpc == 3 .or. nOpc == 4

	If aValues[nx,Len(aValues[nx])]
		aPanels[nx]:SetColor(CLR_WHITE,CLR_HGRAY)
		For ny := 1 To nTmArr
			If aOGets[nx,ny] <> Nil
				aOGets[nx,ny]:SetColor(CLR_WHITE,CLR_HGRAY)
				aOGets[nx,ny]:lReadOnly := .T.
			Endif
		Next ny
		aValues[nx,Len(aValues[nx])] := .F.
    Else
		aPanels[nx]:SetColor(CLR_BLACK,CLR_WHITE)
		For ny := 1 To nTmArr
			If aOGets[nx,ny] <> Nil
				aOGets[nx,ny]:SetColor(CLR_BLACK,CLR_WHITE)
				aOGets[nx,ny]:lReadOnly := .F.
			Endif
		Next ny
		aValues[nx,Len(aValues[nx])] := .T.
	Endif
Endif

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A120Dele ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 30/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Exclusao                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A120Dele(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A120Dele()

Local cEspecie 	:= "QPPA120"

DbSelectArea("QK6")
DbSetOrder(1)
	
If DbSeek(xFilial("QK6") + QK5->QK5_PECA + QK5->QK5_REV)

	Do While !Eof() .and. ;
		QK5->QK5_PECA + QK5->QK5_REV == QK6_PECA + QK6_REV
		
		If !Empty(QK6->QK6_CHAVE1)
			QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"A")    //QPPXFUN
			QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"B")
			QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"C")
			QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"D")
			QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"E")
			QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"F")
			QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"G")
			QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"H")
			If lFMEA4a
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"I")
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"J")			
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"K")
			Endif			
		EndIf		 
		
		DbSelectArea("QK6")
		RecLock("QK6",.F.)
		DbDelete()
		MsUnLock()
		FKCOMMIT()
		DbSkip()
		
	Enddo

Endif

DbSelectArea("QK5")

RecLock("QK5",.F.)
DbDelete()
MsUnLock()
FKCOMMIT()				
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CalcNpr  ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 31/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula o NPR                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CalcNpr(Exp1N)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Linha do array em que esta posicionado             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CalcNPR(nx,u)

Local cPos
Local lRetorno	:= .T.
Local nNPRMAX	:= GetMv("MV_NPRMAX")

If Empty(u:cText)
	Return .T.
EndIf

If !(Alltrim(u:cText) $"  1 2 3 4 5 6 7 8 9 10")
	lRetorno := .F.
Endif
          
cPos := Right(u:Cargo,2)

If lRetorno
	If lFMEA4a
		If cPos$"06_08_10"
			aValues[nx,11] := Str(Val(aValues[nx, 6])*Val(aValues[nx, 8])*Val(aValues[nx, 10]),4)
			If Val(aValues[nx,11]) > nNPRMAX
				MessageDlg(STR0028 +aValues[nx,11]+ STR0029,,2) //"O NPR Calculado de "###" esta acima do limite !"
			Endif
		Elseif cPos$"16_17_18"
			aValues[nx,19] := Str(Val(aValues[nx,16])*Val(aValues[nx,17])*Val(aValues[nx,18]),4)
			If Val(aValues[nx,19]) > nNPRMAX
				MessageDlg(STR0028 +aValues[nx,19]+ STR0029,,2) //"O NPR Calculado de "###" esta acima do limite !"
			Endif
		Endif
	Else
		If cPos$"04_07_09"
			aValues[nx,10] := Str(Val(aValues[nx, 4])*Val(aValues[nx, 7])*Val(aValues[nx, 9]),4)
			If Val(aValues[nx,10]) > nNPRMAX
				MessageDlg(STR0028 +aValues[nx,10]+ STR0029,,2) //"O NPR Calculado de "###" esta acima do limite !"
			Endif
		Elseif cPos$"15_16_17"
			aValues[nx,18] := Str(Val(aValues[nx,15])*Val(aValues[nx,16])*Val(aValues[nx,17]),4)
			If Val(aValues[nx,18]) > nNPRMAX
				MessageDlg(STR0028 +aValues[nx,18]+ STR0029,,2) //"O NPR Calculado de "###" esta acima do limite !"
			Endif
		Endif
	Endif
	aPanels[nx]:Refresh()
Endif

Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP120APRO³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 04.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Aprova / Limpa                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP120APRO(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP120APRO(nOpc)

Local lRet := .T.

If nOpc == 3 .or. nOpc == 4
	DbSelectArea("QAA")
	DbSetOrder(6)
	If Dbseek(Upper(cUserName))
		If ExistBlock("QP120APR")
			lRet := ExecBlock("QP120APR",.F.,.F.)
			If !lRet
				Return lret
			Endif
		EndIf	
		If nOpc == 4
			/*If !Empty(M->QK5_APRPOR)
				If Alltrim(M->QK5_APRPOR) == Alltrim(cUserName)
					M->QK5_DATA 	:= Iif(Empty(M->QK5_DATA), dDataBase, CtoD(" / / "))
					M->QK5_APRPOR	:= Iif(Empty(M->QK5_APRPOR), cUserName, Space(40))		
				Else
					MessageDlg(OemToAnsi(STR0034),,2)	//"Usuario logado nao e o responsavel pela aprovacao da FMEA de Processo. Para consultar FMEA escolha a opcao Visualizar."      	
					//Desabilitar panel para nao permitir edicao qdo responsavel for diferente do usuario logado... 
					oPanel:lReadOnly := .t.
				Endif
			Else*/
				M->QK5_DATA 	:= Iif(Empty(M->QK5_DATA), dDataBase, CtoD(" / / "))
				M->QK5_APRPOR	:= Iif(Empty(M->QK5_APRPOR),cUserName, Space(40))
//			Endif	
		Else
			M->QK5_DATA 	:= Iif(Empty(M->QK5_DATA), dDataBase, CtoD(" / / "))
			M->QK5_APRPOR	:= Iif(Empty(M->QK5_APRPOR), cUserName, Space(40))
		Endif	
	Else
		messageDlg(STR0037)//"O usuário logado não está cadastrado no cadastro de usuários do módulo, portanto não poderá ser o aprovador"
	Endif

Endif

Return lRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AtuaCpo  ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 28/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o campo com Zeros a Esquerda                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AtuaCpo(Exp1N)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Linha do array em que esta posicionado             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AtuaCpo(nx)
Local nAtCam 
Local lRetorno := .T.
Local nCont

If lFMEA4a
	nAtCam := 20
Else
	nAtCam := 19
Endif

If !Empty(aValues[nx,nAtCam])
	aValues[nx,nAtCam] := StrZero(Val(aValues[nx, nAtCam]),TamSX3("QK6_SEQ")[1])

	For nCont := 1 To Len(aValues)
		If aValues[nx,nAtCam] == aValues[nCont,nAtCam] .and. nx <> nCont .and. ;
			aValues[nCont,Len(aValues[nCont])]
			lRetorno := .F.
			Help(" ",1,"QPPSEQDUPL") // "Exite Sequencia duplicada !, altere-a"

			Exit
		Endif
	Next nCont
Endif

aPanels[nx]:Refresh()

Return lRetorno


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ProxDez  ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 28/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Acha a Proxima dezena para seguencia (que ainda nao existe ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ProxDez(Exp1N)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Valor inicial                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ProxDez(nSeed)

Local nRetorno
Local nCont
Local lLoop := .T.
Local nItFMEA 

If lFMEA4a
	nItFMEA := 20
Else
	nItFMEA := 19
Endif

Do While lLoop

	lLoop := .F.
	
	nRetorno := (nSeed - Mod(nSeed,10)) + 10
	
	For nCont := 1 To Len(aValues)
		If nRetorno == Val(aValues[nCont,nItFMEA]) .and. aValues[nCont,Len(aValues[nCont])]
			lLoop := .T.
			Exit
		Endif
	Next nCont

Enddo

Return nRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³BuscaSXB  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 24.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualizacao de descricao com retorno da consulta           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ BuscaSXB(u,nx,oGet)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do Get  									  ³±±
±±³          ³ ExpN1 = Linha do Array 									  ³±±
±±³          ³ ExpO2 = Objeto do Get 								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function BuscaSXB(u,nx,oGet)

Local lReturn := .T.
Local nPsUsa 

If lFMEA4a
	nPsUsa := 13
Else
	nPsUsa := 12
Endif

If !Empty(u:cText)
	QAA->(DbSetOrder(1))
	If (QAA->(DbSeek(cFilAnt+u:cText)))
		aValues[nx,nPsUsa]	:= QAA->QAA_NOME
		oGet:lReadOnly	:= .T.
	Else
		lReturn := .F.
	Endif
Else
	oGet:lReadOnly := .F.
Endif

Return lReturn