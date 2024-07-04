#INCLUDE "QPPA130.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA130  ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 05.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³FMEA de Processo                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA130(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPPAP                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Robson Ramiro³22.07.02³Meta  ³ Alteracao para Visualizacao de BMP     ³±±
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

Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui"  , 	0, 1},;		//"Pesquisar"
					{ OemToAnsi(STR0002), "PPA130Visu", 	0, 2},;		//"Visualizar"
					{ OemToAnsi(STR0003), "PPA130Incl", 	0, 3},;		//"Incluir"
					{ OemToAnsi(STR0004), "PPA130Alte", 	0, 4},;		//"Alterar"
					{ OemToAnsi(STR0005), "PPA130Excl", 	0, 5},;		//"Excluir"
					{ OemToAnsi(STR0030), "QPPR130(.T.)",	0, 6} } 	//"Imprimir"
Return aRotina

Function QPPA130

Private aRotina := MenuDef()
						
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0006)  //"FMEA de Processo"
Private lFMEA4a := GetMV("MV_QVEFMEA",.T.,"3") == "4" 

DbSelectArea("QK7")
DbSetOrder(1)

mBrowse( 6, 1, 22, 75,"QK7",,,,,,)

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA130Visu  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³05.09.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Visualizacao                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA130Visu(ExpC1,ExpN1,ExpN2)                           ³±±
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
Function PPA130Visu(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local aButtons	:= {}
Local oPanel1
Local oPanel2
Local oEnch
Local aButtonPE := {}
Local nI 

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

DbSelectArea(cAlias)

AAdd( aObjects, { 100, 40, .T., .T. } ) // Dados da Enchoice 
AAdd( aObjects, { 100, 60, .T., .T. } ) // Dados da getdados 
aPosObj:= MsObjSize( aInfo, aObjects, .T. ,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 )+' - VISUALIZAÇÂO' ;  //"FMEA de Processo"
						FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL
						
@ 000,000 MSPANEL oPanel1 SIZE 100,aPosObj[1,3] OF oDlg
@ 000,000 MSPANEL oPanel2 SIZE 100,050 			OF oDlg
						
RegToMemory("QK7")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnch := MsmGet():New( "QK7", nReg, nOpc,,,,,aPosObj[1], , 3, , , ,oPanel1, ,.F. )
aButtons := {  {"BMPVISUAL", { || QPPR130() }, OemToAnsi(STR0009), OemToAnsi(STR0031)},; //"Visualizar/Imprimir"###"Vis/Prn"
  			    {"GRAF2D",     { || QPPM040(M->QK7_PECA,M->QK7_REV,"2")} , OemToAnsi(STR0035), OemToAnsi(STR0036)}}  //"Diagrama de Pareto"###"Diag.Par"

If ExistBlock("QP130BUT")              
    aButtonPE := ExecBlock("QP130BUT",.F., .F., {nOpc})
    If ValType(aButtonPE) == "A"
      For nI = 1 To Len(aButtonPE)
        aAdd( aButtons, aButtonPE[nI] )
      next nI
    endif
EndIf

DbSelectArea("QK8")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Scroll                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
oScrollBox :=TScrollBox():New(oPanel2,,,,,.T.,.T.,.T.)                                                                              

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT 

DbSelectArea("QK8")
DbSetOrder(4)
DbSeek(xFilial("QK8")+M->QK7_PECA+M->QK7_REV)

Do While !Eof() .and. M->QK7_PECA+M->QK7_REV == QK8->QK8_PECA+QK8->QK8_REV
	QPP130ADIC(nOpc,.F.)
	DbSelectArea("QK8")
	DbSkip()
Enddo
                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}, , aButtons) CENTERED

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA130Incl  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³05.09.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Inclusao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA130Incl(ExpC1,ExpN1,ExpN2)                           ³±±
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
Function PPA130Incl(cAlias,nReg,nOpc)


Local oDlg			:= NIL
Local lOk 		:= .F.
Local aButtons	:= {}
Local oPanel1
Local oPanel2
Local oEnch
Local aButtonPE := {}
Local nI 

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

DbSelectArea(cAlias)

				
DbSelectArea("QK8")
DbGoTop()

AAdd( aObjects, { 100, 40, .T., .T. } ) // Dados da Enchoice 
AAdd( aObjects, { 100, 60, .T., .T. } ) // Dados da getdados 
aPosObj:= MsObjSize( aInfo, aObjects, .T. ,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) +' - INCLUSÂO';  //"FMEA de Processo"
						FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL
						
@ 000,000 MSPANEL oPanel1 SIZE 100,aPosObj[1,3] OF oDlg
@ 000,000 MSPANEL oPanel2 SIZE 100,050 			OF oDlg
						
RegToMemory("QK7",.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnch := MsmGet():New( "QK7", nReg, nOpc,,,,,aPosObj[1], , , , , ,oPanel1, ,.F. )

aButtons := {  {"BMPINCLUIR",	{ || QPP130ADIC(nOpc,.T.) }	, OemToAnsi(STR0007), OemToAnsi(STR0032) },;	//"Incluir Item"###"Inc Item"
				{"EDIT"		, 	{ || QPP130APRO(nOpc) }		, OemToAnsi(STR0008), OemToAnsi(STR0033) },;	//"Aprovar / Limpar"###"Apr/Limp"
  			    {"GRAF2D",     { || QPPM040(M->QK7_PECA,M->QK7_REV,"2")} , OemToAnsi(STR0035), OemToAnsi(STR0036)}}  //"Diagrama de Pareto"###"Diag.Par"


If ExistBlock("QP130BUT")              
    aButtonPE := ExecBlock("QP130BUT",.F., .F., {nOpc})
    If ValType(aButtonPE) == "A"
      For nI = 1 To Len(aButtonPE)
        aAdd( aButtons, aButtonPE[nI] )
      next nI
    endif
EndIf


DbSelectArea("QK8")
                                                                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Scroll                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
oScrollBox :=TScrollBox():New(oPanel2,,,,,.T.,.T.,.T.)   

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT 

QPP130ADIC(nOpc,.T.)
                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP130TudOk(nOpc), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

If lOk
	A130Grav(nOpc)
Endif

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA130Alte  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³05.09.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Alteracao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA130Alte(ExpC1,ExpN1,ExpN2)                           ³±±
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
Function PPA130Alte(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local lOk 		:= .F.
Local aCposAlt	:= {}
Local aButtons	:= {}
Local oPanel1
Local oPanel2
Local oEnch
Local aButtonPE := {}
Local nI 

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

/*If !Empty(QK7->QK7_APRPOR)
	If Alltrim(QK7->QK7_APRPOR) <> Alltrim(cUserName)
		MsgAlert(STR0038)//"O usuario responsavel e diferente do usuario logado. Sera possivel apenas a visualizacao."
		nOpc := 2
	Endif
Endif*/

If !QPPVldAlt(QK7->QK7_PECA,QK7->QK7_REV,QK7->QK7_APRPOR)
	Return
Endif

AAdd( aObjects, { 100, 40, .T., .T. } ) // Dados da Enchoice 
AAdd( aObjects, { 100, 60, .T., .T. } ) // Dados da getdados 
aPosObj:= MsObjSize( aInfo, aObjects, .T. ,.F.)


DbSelectArea(cAlias)
				
DbSelectArea("QK8")
DbGoTop()

aCposAlt := {	"QK7_FMEA", 	"QK7_PREPOR", 	"QK7_RESPON", "QK7_IDPROD",;
				"QK7_EQUIPE", 	"QK7_OBS", 		"QK7_APRPOR", "QK7_DATA", ;
				"QK7_DTINI",	"QK7_DTREV", 	"QK7_DTCHAV" }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 )+' - ALTERAÇÂO' ;  //"FMEA de Processo"
						FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL

@ 000,000 MSPANEL oPanel1 SIZE 100,aPosObj[1,3] OF oDlg
@ 000,000 MSPANEL oPanel2 SIZE 100,050 			OF oDlg
						
RegToMemory("QK7")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnch := MsmGet():New( "QK7", nReg, nOpc,,,,,aPosObj[1],aCposAlt , , , , ,oPanel1, ,.F. )

aButtons := {  {"BMPINCLUIR",	{ || QPP130ADIC(nOpc,.T.) }	, OemToAnsi(STR0007), OemToAnsi(STR0032) },;	//"Incluir Item"###"Inc Item"
				{"EDIT"		, 	{ || QPP130APRO(nOpc) }		, OemToAnsi(STR0008), OemToAnsi(STR0033) },;	//"Aprovar / Limpar"###"Apr/Limp"
  			    {"GRAF2D",     { || QPPM040(M->QK7_PECA,M->QK7_REV,"2")} , OemToAnsi(STR0035), OemToAnsi(STR0036)}}  //"Diagrama de Pareto"###"Diag.Par"


If ExistBlock("QP130BUT")              
    aButtonPE := ExecBlock("QP130BUT",.F., .F., {nOpc})
    If ValType(aButtonPE) == "A"
      For nI = 1 To Len(aButtonPE)
        aAdd( aButtons, aButtonPE[nI] )
      next nI
    endif
EndIf


DbSelectArea("QK8")
                                                                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Scroll                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
oScrollBox :=TScrollBox():New(oPanel2,,,,,.T.,.T.,.T.)                                                                              

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT 

DbSelectArea("QK8")
DbSetOrder(4)
DbSeek(xFilial("QK8")+M->QK7_PECA+M->QK7_REV)

Do While !Eof() .and. M->QK7_PECA+M->QK7_REV == QK8->QK8_PECA+QK8->QK8_REV
	QPP130ADIC(nOpc,.F.)
	DbSelectArea("QK8")
	DbSkip()
Enddo
                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP130TudOk(nOpc), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

If lOk
	A130Grav(nOpc)
Endif

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA130Excl  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³05.09.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Exclusao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA130Excl(ExpC1,ExpN1,ExpN2)                           ³±±
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
Function PPA130Excl(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local aButtons	:= {}
Local lOk 		:= .F.
Local oPanel1
Local oPanel2
Local oEnch
Local aButtonPE := {}
Local nI 

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

If !QPPVldExc(QK7->QK7_REV,QK7->QK7_APRPOR)
	Return
Endif

/*If !Empty(QK7->QK7_APRPOR)
	If Alltrim(QK7->QK7_APRPOR) <> Alltrim(cUserName)
		MsgAlert(STR0038)//"O usuario responsavel e diferente do usuario logado. Sera possivel apenas a visualizacao."
		nOpc := 2
	Endif
Endif*/

DbSelectArea(cAlias)

AAdd( aObjects, { 100, 40, .T., .T. } ) // Dados da Enchoice 
AAdd( aObjects, { 100, 60, .T., .T. } ) // Dados da getdados 
aPosObj:= MsObjSize( aInfo, aObjects, .T. ,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 )+' - EXCLUSÂO' ;  //"FMEA de Processo"
						FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL

@ 000,000 MSPANEL oPanel1 SIZE 100,aPosObj[1,3] OF oDlg
@ 000,000 MSPANEL oPanel2 SIZE 100,050 			OF oDlg
						
RegToMemory("QK7")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnch := MsmGet():New( "QK7", nReg, nOpc,,,,,aPosObj[1], , , , , ,oPanel1, ,.F. )


aButtons := { {"BMPVISUAL", { || QPPR130() }, OemToAnsi(STR0009), OemToAnsi(STR0031) },;  //"Visualizar/Imprimir"###"Vis/Prn"
  			    {"GRAF2D",     { || QPPM040(M->QK7_PECA,M->QK7_REV,"2")} , OemToAnsi(STR0035), OemToAnsi(STR0036)}}  //"Diagrama de Pareto"###"Diag.Par"


If ExistBlock("QP130BUT")              
    aButtonPE := ExecBlock("QP130BUT",.F., .F., {nOpc})
    If ValType(aButtonPE) == "A"
      For nI = 1 To Len(aButtonPE)
        aAdd( aButtons, aButtonPE[nI] )
      next nI
    endif
EndIf


DbSelectArea("QK8")
                                                                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Scroll                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
oScrollBox :=TScrollBox():New(oPanel2,,,,,.T.,.T.,.T.)                                                                              

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT 

DbSelectArea("QK8")
DbSetOrder(4)
DbSeek(xFilial("QK8")+M->QK7_PECA+M->QK7_REV)

Do While !Eof() .and. M->QK7_PECA+M->QK7_REV == QK8->QK8_PECA+QK8->QK8_REV
	QPP130ADIC(nOpc,.F.)
	DbSelectArea("QK8")
	DbSkip()
Enddo
                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP130TudOk(nOpc), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

If lOk .And. nOpc != 2
	A130Dele()
Endif


Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP130ADIC³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 05.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Resultados dos Estudos                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP130ADIC(ExpN1,ExpL1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±³          ³ ExpL1 = Diferenciacao se foi inclusao manual				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP130ADIC(nOpc,lManual)

Local nx
Local bBlock
Local aGets	:= {}
Local cChave
Local axTextos1, axTextos2, axTextos3, axTextos4
Local axTextos5, axTextos6, axTextos7, axTextos8, axTextos9,axTextos10,axTextos11
Local bValid
Local oGet1,oGet2,oGet3,oGet4,oGet5,oGet6
Local oGet7,oGet8,oGet9,oGet10,oGet11,oGet12
Local oGet13,oGet14,oGet15,oGet16,oGet17,oGet18
Local oGet19,oGet20,oGet21,oGet22,oGet23, oGet24, oGet25, oGet26, oGet27
Local oBtn
Local oBmp
Local nTamLin 	:= 17  //tamanho da linha dentro do combobox que o sistema usa como parametro de "quebra de linha" na gravação na QKO...
Local cSeq 		:= TamSX3("QK8_SEQ")[1]
Local nSaveSX8	:= GetSX8Len()
Local nTamSeq   := TamSX3("QK8_SEQ")[1]
Local nItFMEA   
Local nTamTela 
Local nPsChv

If lFMEA4a 
	nTamTela := 1420
	nItFMEA  := 21
	nPsChv   := 24
Else
	nTamTela := 1080
	nItFMEA  := 20
	nPsChv   := 23			
Endif

nx := Len(aPanels)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao permite incluir mais de 30 caracteristicas devido problemas de ambiente.                     ³
//³Nesse caso utilizar o programa QPPA131.prw que utiliza ListBox para controle das caracteristicas.³
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

If nCont == 1 .or. MOD(nCont,6) == 0
	@ nLin	,001 MSPANEL oPanel1 PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE nTamTela,013 OF oScrollBox
	@ 003	,013 SAY OemToAnsi(STR0026)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Seq."
	If lFMEA4a
		@ 003	,036 SAY OemToAnsi(STR0040)	COLOR CLR_WHITE OF oPanel1 PIXEL //"Funcao" 
		@ 003	,062 SAY OemToAnsi(STR0041)	COLOR CLR_WHITE OF oPanel1 PIXEL //"Descr. Funcao"		 
		@ 003	,160 SAY OemToAnsi(STR0042)	COLOR CLR_WHITE OF oPanel1 PIXEL //"Requisito"	
		@ 003	,250 SAY OemToAnsi(STR0043)	COLOR CLR_WHITE OF oPanel1 PIXEL //"ID"	
		@ 003	,287 SAY OemToAnsi(STR0011)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Modo de Falha Potencial"
		@ 003	,387 SAY OemToAnsi(STR0012)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Efeito Potencial da Falha"
		@ 003	,481 SAY OemToAnsi(STR0013)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Sever"
		@ 003	,507 SAY OemToAnsi(STR0014) 	COLOR CLR_WHITE OF oPanel1 PIXEL //"Class"
		@ 003	,535 SAY OemToAnsi(STR0015)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Causa/Mecanismo Potencial da Falha"
		@ 003	,628 SAY OemToAnsi(STR0016)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Ocorr"
		@ 003	,644 SAY OemToAnsi(STR0017)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Controles Atuais do Processo - P / D"
		@ 003	,744 SAY OemToAnsi(STR0044)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Causas"
		@ 003	,784 SAY OemToAnsi(STR0045)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Modo de falha"
		@ 003	,831 SAY OemToAnsi(STR0018)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Detec"
		@ 003	,848 SAY OemToAnsi(STR0019)		COLOR CLR_WHITE OF oPanel1 PIXEL //"NPR"
		@ 003	,874 SAY OemToAnsi(STR0020)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Acoes Recomendadas"
		@ 003	,968 SAY OemToAnsi(STR0021)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Responsavel"
		@ 003	,1068 SAY OemToAnsi(STR0022)  	COLOR CLR_WHITE OF oPanel1 PIXEL //"Prazo"
		@ 003	,1108 SAY OemToAnsi(STR0023)  	COLOR CLR_WHITE OF oPanel1 PIXEL //"Acoes Tomadas"
		@ 003	,1199 SAY OemToAnsi(STR0046)  	COLOR CLR_WHITE OF oPanel1 PIXEL //"Data Efetiva"
		@ 003	,1240 SAY OemToAnsi(STR0013)	COLOR CLR_WHITE OF oPanel1 PIXEL //"Sever"
		@ 003	,1256 SAY OemToAnsi(STR0016)	COLOR CLR_WHITE OF oPanel1 PIXEL //"Ocorr"
		@ 003	,1272 SAY OemToAnsi(STR0018)  	COLOR CLR_WHITE OF oPanel1 PIXEL //"Detec"
		@ 003	,1288 SAY OemToAnsi(STR0019)	COLOR CLR_WHITE OF oPanel1 PIXEL //"NPR" */
	Else
		@ 003	,036 SAY OemToAnsi(STR0010) 	COLOR CLR_WHITE OF oPanel1 PIXEL //"Funcao / Requisitos"
		@ 003	,160 SAY OemToAnsi(STR0011)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Modo de Falha Potencial"
		@ 003	,248 SAY OemToAnsi(STR0012)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Efeito Potencial da Falha"
		@ 003	,341 SAY OemToAnsi(STR0013)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Sever"
		@ 003	,357 SAY OemToAnsi(STR0014) 	COLOR CLR_WHITE OF oPanel1 PIXEL //"Class"
		@ 003	,373 SAY OemToAnsi(STR0015)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Causa/Mecanismo Potencial da Falha"
		@ 003	,467 SAY OemToAnsi(STR0016)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Ocorr"
		@ 003	,484 SAY OemToAnsi(STR0017)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Controles Atuais do Processo - P / D"
		@ 003	,577 SAY OemToAnsi(STR0018)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Detec"
		@ 003	,595 SAY OemToAnsi(STR0019)		COLOR CLR_WHITE OF oPanel1 PIXEL //"NPR"
		@ 003	,622 SAY OemToAnsi(STR0020)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Acoes Recomendadas"
		@ 003	,716 SAY OemToAnsi(STR0021)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Responsavel"
		@ 003	,813 SAY OemToAnsi(STR0022)  	COLOR CLR_WHITE OF oPanel1 PIXEL //"Prazo"
		@ 003	,855 SAY OemToAnsi(STR0023)  	COLOR CLR_WHITE OF oPanel1 PIXEL //"Acoes Tomadas"
		@ 003	,947 SAY OemToAnsi(STR0013)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Sever"
		@ 003	,963 SAY OemToAnsi(STR0016)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Ocorr"
		@ 003	,981 SAY OemToAnsi(STR0018)  	COLOR CLR_WHITE OF oPanel1 PIXEL //"Detec"
		@ 003	,997 SAY OemToAnsi(STR0019)		COLOR CLR_WHITE OF oPanel1 PIXEL //"NPR"
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
	If !Empty(QK8->QK8_CHAVE1)
		axTextos1 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"A",1, nTamLin,"QKO",axTextos1) //Item Funcao
		axTextos2 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"B",1, nTamLin,"QKO",axTextos2) //Modo de falha
		axTextos3 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"C",1, If(lFMEA4a,15,nTamLin),"QKO",axTextos3) //Efeito da falha
		axTextos4 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"D",1, If(lFMEA4a,14,nTamLin),"QKO",axTextos4) //Causa/Mecanismo
		axTextos5 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"E",1, 8,"QKO",axTextos5) 		//Controles atuais Prevencao
		axTextos6 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"F",1, nTamLin,"QKO",axTextos6) //Acoes recomendadas
		axTextos7 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"G",1, nTamLin,"QKO",axTextos7) //Acoes Tomadas
		axTextos8 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"H",1, 8,"QKO",axTextos8) 		//Controles atuais Deteccao
		If lFMEA4a
			axTextos9 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"I",1, nTamLin,"QKO",axTextos9) 		//Requisitos
			axTextos10 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"J",1, nTamLin,"QKO",axTextos10) 		//Causa	
			axTextos11 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"K",1, nTamLin,"QKO",axTextos11) 		//Modo de Falha
		Endif
	Endif

	If lFMEA4a

		aGets := {	QK8->QK8_NOPE,axTextos1,axTextos9,axTextos2,axTextos3,QK8->QK8_SEVER,QK8->QK8_CLASS,;
					axTextos4,QK8->QK8_OCORR,axTextos5,QK8->QK8_DETEC,QK8->QK8_NPR,;
					axTextos6,QK8->QK8_RESP,QK8->QK8_PRAZO,axTextos7,QK8->QK8_RSEVER,;
					QK8->QK8_ROCORR,QK8->QK8_RDETEC,QK8->QK8_RNPR,QK8->QK8_SEQ,;
					axTextos8,QK8->QK8_CODRES,QK8->QK8_CHAVE1,QK8->QK8_DATEEF,QK8->QK8_ID,axTextos10,axTextos11,.T.}  
		
	Else
		aGets := {	QK8->QK8_NOPE,axTextos1,axTextos2,axTextos3,QK8->QK8_SEVER,QK8->QK8_CLASS,;
					axTextos4,QK8->QK8_OCORR,axTextos5,QK8->QK8_DETEC,QK8->QK8_NPR,;
					axTextos6,QK8->QK8_RESP,QK8->QK8_PRAZO,axTextos7,QK8->QK8_RSEVER,;
					QK8->QK8_ROCORR,QK8->QK8_RDETEC,QK8->QK8_RNPR,QK8->QK8_SEQ,;
					axTextos8,QK8->QK8_CODRES,QK8->QK8_CHAVE1,.T.}
	Endif			
Else                                                      
	If Len(aValues) > 0
		cSeq := Val(aValues[Iif(nx-1 > 0,nx-1,1), nItFMEA])+1
		cSeq := StrZero(ProxDez(cSeq),TamSX3("QK8_SEQ")[1])
	Else
		If nTamSeq == 5
			cSeq := "00010"
		Else
			cSeq := "010"
		Endif
	Endif
	
	If lFMEA4a
		aGets := {	Space(06),axTextos1,axTextos9,axTextos2,axTextos3,Space(02),Space(03),;
					axTextos4,Space(02),axTextos5,Space(02),Space(04),;
					axTextos6,Space(30),CtoD(" / / " ),axTextos7,Space(02),;
					Space(02),Space(02),Space(04),cSeq,axTextos8,Space(10),;
					Space(08),CtoD(" / / " ),Space(08),axTextos10,axTextos11,.T.}
	Else
		aGets := {	Space(06),axTextos1,axTextos2,axTextos3,Space(02),Space(03),;
					axTextos4,Space(02),axTextos5,Space(02),Space(04),;
					axTextos6,Space(30),CtoD(" / / " ),axTextos7,Space(02),;
					Space(02),Space(02),Space(04),cSeq,axTextos8,Space(10),;
					Space(08),.T.}
	Endif			
Endif

Aadd(aValues,aGets)

If Empty(aValues[nx,nPsChv])

	cChave := GetSXENum("QK8", "QK8_CHAVE1",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End
	
	aValues[nx,nPsChv] := cChave
Endif

If lFMEA4a   // Se estiver na quarta Edição do FMEA 



	// 20o Get - Item sequencial (1o na tela)
	
	cGet20	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",21]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet20+":=u,"+cGet20+")}")
	bValid	:= {|u| AtuaCpo(nx)}
	                                                      
	oGet20 	:= TGet():New( 01, 01, bBlock,oPanel,06,10,PesqPict("QK8","QK8_SEQ"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet20:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",21"
	
	
	//1o Get - Funcao 
	cGet1 	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",1]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet1+":=u,"+cGet1+")}")
	bValid	:= {|u| BuscaSXB(u,nx,oGet2,1,oBmp)}
	
	oGet1 := TGet():New( 01, 25, bBlock,oPanel,20,10,PesqPict("QK8","QK8_NOPE"),bValid,;
	     , , , , ,.T., , , , , , , , ,"QPZ")
	     
	oGet1:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",01"
	
	
	//2o Get - Descr Requisitos (Memo)
	     
	cGet2 	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",2]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet2+":=u,"+cGet2+")}")
	bWhen	:= {|u| Empty(aValues[nx,1])}
	                                                        
	oGet2 := TMultiGet():New(01,57,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., bWhen, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	    
	oGet2:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",02"
	
	
	//3o Get - Requisito (Memo)
	
	cGet23 	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",3]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet23+":=u,"+cGet23+")}")
	                                                        
	oGet23 := TMultiGet():New(01,155,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., , .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	    
	oGet23:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",3"
    
		//1o Get - ID 
		cGet25 	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",26]"
		bBlock 	:= &("{|u|If(Pcount()>0,"+cGet25+":=u,"+cGet25+")}")
	    bValid	:= {|u| BuscaSXB(u,nx,oGet25,3,oBmp)}              
		oGet25 := TGet():New( 01, 250, bBlock,oPanel,30,10,PesqPict("QKM","QKM_NCAR"),bValid,;
		     , , , , ,.T., , , , , , , , ,"QPX1")
		oGet25:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",26"
	
	// 3o Get - Modo de Falha Potencial
	cGet3 	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",4]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet3+":=u,"+cGet3+")}")
	                                                        
	oGet3 := TMultiGet():New(01,290,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil , .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	     
	oGet3:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",04"


	
	// 4o Get - Efeito Potencial da Falha
	cGet4 	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",5]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet4+":=u,"+cGet4+")}")
	                                                        
	oGet4 := TMultiGet():New(01,385,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	     
	oGet4:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",05"
	
	// 5o Get - Severidade
	
	cGet5	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",6]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet5+":=u,"+cGet5+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                        
	oGet5 := TGet():New( 01,479, bBlock,oPanel,10,10, PesqPict("QK8","QK8_SEVER"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)
	     
	oGet5:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",06"
	
	// 6o Get - Classificacao
	
	cGet6	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",7]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet6+":=u,"+cGet6+")}")
	                                                        
	cGet7	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",8]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet7+":=u,"+cGet7+")}")
	                                    
	oGet7 := TMultiGet():New(01,532,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet7:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",08"
		                              
	// 8o Get - Ocorrencia
	
	cGet8	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",9]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet8+":=u,"+cGet8+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                        
	oGet8 := TGet():New( 01,626, bBlock,oPanel,10,10,PesqPict("QK8","QK8_OCORR"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet8:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",09"
	
	// 9o Get - Controles atuais do Processo Prevencao
		
	cGet9	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",10]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet9+":=u,"+cGet9+")}")
	
	oGet9 := TMultiGet():New(01,642,bBlock, oPanel, 46, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet9:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",10"
	
	// 21o Get - Controles atuais do projeto deteccao (10o na tela)
	
	cGet21	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",22]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet21+":=u,"+cGet21+")}")
	
	oGet21 := TMultiGet():New(01,689,bBlock, oPanel, 46, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet21:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",22"
    

		
		//causa
		cGet26	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",27]"
		bBlock	:= &("{|u|If(Pcount()>0,"+cGet26+":=u,"+cGet26+")}")
		
		oGet26 := TMultiGet():New(01,736,bBlock, oPanel, 46, 25, Nil, .F.,;
									Nil, Nil, Nil, .T.,;
									Nil, .F., Nil /*bWhen*/, .F.,;
									.F., Nil, Nil,;
									Nil, .F., Nil, .T.)
		
		oGet26:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",27"
		
		//modo de falha
		cGet27	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",28]"
		bBlock	:= &("{|u|If(Pcount()>0,"+cGet27+":=u,"+cGet27+")}")
		
		oGet27 := TMultiGet():New(01,786,bBlock, oPanel, 46, 25, Nil, .F.,;
									Nil, Nil, Nil, .T.,;
									Nil, .F., Nil /*bWhen*/, .F.,;
									.F., Nil, Nil,;
									Nil, .F., Nil, .T.)
		
		oGet27:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",28"
		
	                                                         
	// 10o Get - Deteccao
	
	cGet10	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",11]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet10+":=u,"+cGet10+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                      
	oGet10 := TGet():New( 01,835, bBlock,oPanel,10,10,PesqPict("QK8","QK8_DETEC"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet10:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",11"
	
	// 11o Get - NPR
	
	cGet11	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",12]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet11+":=u,"+cGet11+")}")
	                                                      
	oGet11 	:= TGet():New( 01,850, bBlock,oPanel,20,10,PesqPict("QK8","QK8_NPR"),,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/,,,,.T.)
	     
	oGet11:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",12"

	// 12o Get - Acoes Recomendadas
	
	cGet12	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",13]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet12+":=u,"+cGet12+")}")
	
	oGet12 	:= TMultiGet():New(01,872,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet12:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",13"
	
	// 13o Get - Responsavel
	
	cGet13	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",14]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet13+":=u,"+cGet13+")}")
	bWhen	:= {|u| Empty(aValues[nx,23])} 
	                                                      
	oGet13 	:= TGet():New( 15,966, bBlock,oPanel,100,10,PesqPict("QK8","QK8_RESP"),,;
	     ,,,,,.T.,,,bWhen)
	     
	oGet13:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",14"
	
	// 13(b)o Get - Codigo do Responsavel (22 no array)
	
	cGet22	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",23]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet22+":=u,"+cGet22+")}")
	bValid	:= {|u| BuscaSXB(u,nx,oGet13,2)}
	
	oGet22	:= TGet():New( 01,966, bBlock,oPanel,40,10,PesqPict("QK8","QK8_CODRES"),bValid,;
	     , , , , ,.T., , , , , , , , ,ConSX3("QK8_CODRES"))
	    
	oGet22:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",23"
	
	
	// 14a Get - Prazo
	
	cGet14	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",15]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet14+":=u,"+cGet14+")}")
	                                                      
	oGet14 	:= TGet():New( 01,1066, bBlock,oPanel,40,10,,,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet14:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",15"
	

	
	// 15o Get - Acoes tomadas
	
	cGet15	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",16]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet15+":=u,"+cGet15+")}")
	
	oGet15 	:= TMultiGet():New(01,1106,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet15:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",16"
    
    
   	// 14b Get - Data Efetiva
	
	cGet24	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",25]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet24+":=u,"+cGet24+")}")
	                                                      
	oGet24 	:= TGet():New( 01, 1199, bBlock,oPanel,40,10,,,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet24:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",25"  
		
	
	// 16o Get - Severidade 
	cGet16	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",17]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet16+":=u,"+cGet16+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                      
	oGet16 	:= TGet():New( 01, 1240, bBlock,oPanel,10,10,PesqPict("QK8","QK8_RSEVER"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet16:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",17"
	
	// 17o Get - Ocorrencia
	
	cGet17	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",18]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet17+":=u,"+cGet17+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                      
	oGet17 	:= TGet():New( 01,1256, bBlock,oPanel,10,10,PesqPict("QK8","QK8_ROCORR"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet17:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",18"
	
	// 18o Get - Deteccao
	
	cGet18	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",19]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet18+":=u,"+cGet18+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                      
	oGet18 	:= TGet():New( 01,1272, bBlock,oPanel,10,10,PesqPict("QK8","QK8_RDETEC"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet18:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",19"
	
	// 19o Get - NPR
	
	cGet19	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",20]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet19+":=u,"+cGet19+")}")
	                                                      
	oGet19 	:= TGet():New( 01,1288, bBlock,oPanel,10,10,PesqPict("QK8","QK8_RNPR"),,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/,,,,.T.)
	     
	oGet19:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",20"


Else
	// 20o Get - Item sequencial (1o na tela)
	
	cGet20	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",20]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet20+":=u,"+cGet20+")}")
	bValid	:= {|u| AtuaCpo(nx)}
	                                                      
	oGet20 	:= TGet():New( 01, 01, bBlock,oPanel,06,10,PesqPict("QK8","QK8_SEQ"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet20:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",20"
	
	
	//1o Get - Funcao / Requisitos (Consulta Padrao)
	cGet1 	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",1]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet1+":=u,"+cGet1+")}")
	bValid	:= {|u| BuscaSXB(u,nx,oGet2,1,oBmp)}
	
	oGet1 := TGet():New( 01, 25, bBlock,oPanel,20,10,PesqPict("QK8","QK8_NOPE"),bValid,;
	     , , , , ,.T., , , , , , , , ,"QPZ")
	     
	oGet1:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",01"
	
	
	//2o Get - Funcao / Requisitos (Memo)
	     
	cGet2 	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",2]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet2+":=u,"+cGet2+")}")
	bWhen	:= {|u| Empty(aValues[nx,1])}
	                                                        
	oGet2 := TMultiGet():New(01,57,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., bWhen, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	    
	oGet2:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",02"
	
	// 3o Get - Modo de Falha Potencial
	cGet3 	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",3]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet3+":=u,"+cGet3+")}")
	                                                        
	oGet3 := TMultiGet():New(01,151,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	     
	oGet3:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",03"
	
	// 4o Get - Efeito Potencial da Falha
	cGet4 	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",4]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet4+":=u,"+cGet4+")}")
	                                                        
	oGet4 := TMultiGet():New(01,245,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	     
	oGet4:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",04"
	
	// 5o Get - Severidade
	
	cGet5	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",5]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet5+":=u,"+cGet5+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                        
	oGet5 := TGet():New( 01, 339, bBlock,oPanel,10,10, PesqPict("QK8","QK8_SEVER"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)
	     
	oGet5:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",05"
	
	// 6o Get - Classificacao
	
	cGet6	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",6]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet6+":=u,"+cGet6+")}")
	                                                        
	cGet7	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",7]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet7+":=u,"+cGet7+")}")
	                                    
	oGet7 := TMultiGet():New(01,371,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet7:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",07"
	                              
	// 8o Get - Ocorrencia
	
	cGet8	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",8]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet8+":=u,"+cGet8+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                        
	oGet8 := TGet():New( 01, 465, bBlock,oPanel,10,10,PesqPict("QK8","QK8_OCORR"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet8:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",08"
	
	// 9o Get - Controles atuais do Processo Prevencao
	
	cGet9	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",9]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet9+":=u,"+cGet9+")}")
	
	oGet9 := TMultiGet():New(01,481,bBlock, oPanel, 46, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet9:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",09"
	
	// 21o Get - Controles atuais do projeto deteccao (10o na tela)
	
	cGet21	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",21]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet21+":=u,"+cGet21+")}")
	
	oGet21 := TMultiGet():New(01,528,bBlock, oPanel, 46, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet21:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",21"
	
	                                                         
	// 10o Get - Deteccao
	
	cGet10	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",10]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet10+":=u,"+cGet10+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                      
	oGet10 := TGet():New( 01, 575, bBlock,oPanel,10,10,PesqPict("QK8","QK8_DETEC"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet10:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",10"
	
	// 11o Get - NPR
	
	cGet11	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",11]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet11+":=u,"+cGet11+")}")
	                                                      
	oGet11 	:= TGet():New( 01, 591, bBlock,oPanel,20,10,PesqPict("QK8","QK8_NPR"),,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/,,,,.T.)
	     
	oGet11:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",11"
	
	// 12o Get - Acoes Recomendadas
	
	cGet12	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",12]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet12+":=u,"+cGet12+")}")
	
	oGet12 	:= TMultiGet():New(01,617,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet12:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",12"
	
	// 13o Get - Responsavel
	
	cGet13	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",13]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet13+":=u,"+cGet13+")}")
	bWhen	:= {|u| Empty(aValues[nx,22])}
	                                                      
	oGet13 	:= TGet():New( 15, 711, bBlock,oPanel,100,10,PesqPict("QK8","QK8_RESP"),,;
	     ,,,,,.T.,,,bWhen)
	     
	oGet13:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",13"
	
	// 13(b)o Get - Codigo do Responsavel (22 no array)
	
	cGet22	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",22]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet22+":=u,"+cGet22+")}")
	bValid	:= {|u| BuscaSXB(u,nx,oGet13,2)}
	
	oGet22	:= TGet():New( 01, 711, bBlock,oPanel,40,10,PesqPict("QK8","QK8_CODRES"),bValid,;
	     , , , , ,.T., , , , , , , , ,ConSX3("QK8_CODRES"))
	    
	oGet22:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",22"
	
	
	// 14o Get - Prazo
	
	cGet14	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",14]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet14+":=u,"+cGet14+")}")
	                                                      
	oGet14 	:= TGet():New( 01, 811, bBlock,oPanel,40,10,,,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet14:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",14"
	
	
	// 15o Get - Acoes tomadas
	
	cGet15	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",15]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet15+":=u,"+cGet15+")}")
	
	oGet15 	:= TMultiGet():New(01,851,bBlock, oPanel, 93, 25, Nil, .F.,;
								Nil, Nil, Nil, .T.,;
								Nil, .F., Nil /*bWhen*/, .F.,;
								.F., Nil, Nil,;
								Nil, .F., Nil, .T.)
	
	oGet15:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",15"
	
	// 16o Get - Severidade 
	cGet16	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",16]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet16+":=u,"+cGet16+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                      
	oGet16 	:= TGet():New( 01, 945, bBlock,oPanel,10,10,PesqPict("QK8","QK8_RSEVER"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet16:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",16"
	
	// 17o Get - Ocorrencia
	
	cGet17	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",17]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet17+":=u,"+cGet17+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                      
	oGet17 	:= TGet():New( 01, 961, bBlock,oPanel,10,10,PesqPict("QK8","QK8_ROCORR"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet17:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",17"
	
	// 18o Get - Deteccao
	
	cGet18	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",18]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet18+":=u,"+cGet18+")}")
	bValid	:= {|u| CalcNPR(nx,u)}
	                                                      
	oGet18 	:= TGet():New( 01, 977, bBlock,oPanel,10,10,PesqPict("QK8","QK8_RDETEC"),bValid,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	     
	oGet18:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",18"
	
	// 19o Get - NPR
	
	cGet19	:= "aValues["+Str(nx,TamSX3("QK8_SEQ")[1])+",19]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet19+":=u,"+cGet19+")}")
	                                                      
	oGet19 	:= TGet():New( 01, 993, bBlock,oPanel,10,10,PesqPict("QK8","QK8_RNPR"),,;
	     ,,,,,.T.,,,/* <{|X|uWhen(X)}>*/,,,,.T.)
	     
	oGet19:Cargo := Str(nx,TamSX3("QK8_SEQ")[1])+",19"

Endif

If lFMEA4a  // Coloca no Array AOgets os oGets  se for na quarta edição do FMEA? 
	Aadd(aOGets,{	oGet1,oGet2,oGet23,oGet25,oGet3,oGet4,oGet5,;
					oGet6,oGet7,oGet8,oGet9,oGet21,;
					oGet10,oGet10,oGet11,oGet12,oGet13,;
					oGet22,oGet14,oGet15,oGet24,oGet16,oGet17,oGet18,;
					oGet19})
	
	@ 001,1339 BUTTON oBtn PROMPT OemToAnsi(STR0024) OF oPanel Pixel Size 65,13 ACTION QPP130REMO(nx,nOpc) //"Excluir / Recuperar"
	@ 001,515 BITMAP oBmp REPOSITORY SIZE 030,030 OF oPanel NOBORDER PIXEL
Else
	Aadd(aOGets,{	oGet1,oGet2,oGet3,oGet4,oGet5,;
					oGet6,oGet7,oGet8,oGet9,oGet10,;
					oGet11,oGet12,oGet13,oGet14,oGet15,;
					oGet16,oGet17,oGet18,oGet19,oGet20,;
					oGet21,oGet22})
	
	@ 001,1020 BUTTON oBtn PROMPT OemToAnsi(STR0024) OF oPanel Pixel Size 65,13 ACTION QPP130REMO(nx,nOpc) //"Excluir / Recuperar"
	@ 001,0355 BITMAP oBmp REPOSITORY SIZE 030,030 OF oPanel NOBORDER PIXEL
Endif
If (nOpc == 2 .or. nOpc == 4 .or. nOpc == 5) //Vis. Alt Excl.
	If lFMEA4a
		If !Empty(aValues[nx,7])
			oBmp:SetBmp(aValues[nx,7])
		Else
			oBmp:SetBmp("note")
		Endif
	Else
//		If !Empty(aValues[nx,5])		// comentado em FNC mexicoque estava usando o conteudo deste campo para usar BMP da classe 
//			oBmp:SetBmp(aValues[nx,5])
//		Else
			If !Empty(aValues[nx,6])
				oBmp:SetBmp(aValues[nx,6])
			Else
				oBmp:SetBmp("note")
			Endif	
//		Endif
	Endif
Else
	oBmp:SetBmp("note")
Endif	

oBmp:Refresh()
oBmp:lTransparent 	:= .T.
oBmp:cToolTip		:= STR0027 //"Duplo Click para escolher caracteristica"
oBmp:BlDblClick		:= {|o| QPPA010BMP(nOpc,nX,oBmp,oPanel,aValues,If(lFMEA4a,2,1))}

If nOpc == 2 .or. nOpc == 5    //VISUALIZAR OU EXCLUIR  
	oGet1:lReadOnly 	:= .T.
	oGet2:lReadOnly 	:= .T.	
	oGet3:lReadOnly 	:= .T.	
	oGet4:lReadOnly 	:= .T.	
	oGet5:lReadOnly 	:= .T.
//	oGet6:lReadOnly := .T.	
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
	oGet22:lReadOnly 	:= .T.

	oBmp:lReadOnly 		:= .T.
Endif

nLin += 27

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PP130TUDOK³ Autor ³ Robson Ramiro A Olivei³ Data ³ 05.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida Inclusao                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP130TUDOK()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpc - Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PP130TUDOK(nOpc)

Local lRetorno	:= .T.
Local nIt
Local nTot
Local nCont, nCont2
Local cComp
Local nItFMEA := 20

If lFMEA4a
	nItFMEA := 21
Endif

If lRetorno
	For nIt := 1 To Len(aValues)
		If !aValues[nIt, Len(aValues[nIt])] // Item deletado
			nTot++
		Endif
	Next nIt

	If Empty(M->QK7_PECA) .or. Empty(M->QK7_REV) .or. nTot == Len(aValues)
		lRetorno := .F.
		Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
	EndIf
Endif

If lRetorno
	If INCLUI
		If !ExistChav("QK7",M->QK7_PECA+M->QK7_REV)
			lRetorno := .F.
			Help(" ",1,"JAGRAVADO")  // Campo ja Existe
		Endif
		If !ExistCpo("QK1",M->QK7_PECA+M->QK7_REV)
			lRetorno := .F.
			Help(" ",1,"REGNOIS")  // Nao existe amarracao
		Endif
	Endif
Endif

If lRetorno
	For nCont := 1 To Len(aValues)
		If aValues[nCont,Len(aValues[nCont])] // Item nao deletado
			If lFMEA4a
				cComp := aValues[nCont,21]
			Else
				cComp := aValues[nCont,20]
			Endif
			
			If Empty(cComp)
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

		If !lRetorno
			Exit
		Endif
		
	Next nCont
Endif 
If ExistBlock("QP130TOK")
	lRetorno := ExecBlock("QP130TOK",.F.,.F.,{aValues})
EndIf

Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A130GRAV  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 05.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravacao dos dados - inclusao/alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A130GRAV(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A130Grav(nOpc)

Local nIt     
Local nCont
Local nNumItem
Local bCampo		:= { |nCPO| Field(nCPO) }
Local lGraOk 		:= .T.   // Indica se todas as gravacoes obtiveram sucesso
Local cEspecie		:= "QPPA130"
Local axTextos1		:= {}
Local axTextos2		:= {}
Local axTextos3		:= {}
Local axTextos4		:= {}
Local axTextos5		:= {}
Local axTextos6		:= {}
Local axTextos7		:= {}
Local axTextos8		:= {}
Local axTextos10    := {}
Local axTextos11	:= {}
Local cAtividade	:= "02 " // Definido no ID - QKZ
Local nTamLin 		:= 17
Local nItFMEA		:= 20

If lFMEA4a
	nItFMEA	:= 21
Endif

Begin Transaction

DbSelectArea("QK7")
DbSetOrder(1)

If INCLUI
	RecLock("QK7",.T.)
Else
	RecLock("QK7",.F.)
Endif

For nCont := 1 To FCount()

	If "FILIAL"$Field(nCont)
		FieldPut(nCont,xFilial("QK7"))
	Else
		FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
	Endif

Next nCont

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos nao informados                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QK7->QK7_REVINV := Inverte(QK7->QK7_REV)

MsUnLock()
FKCOMMIT()
If !Empty(QK7->QK7_DATA) .and. !Empty(QK7->QK7_APRPOR)
	QPP_CRONO(QK7->QK7_PECA,QK7->QK7_REV,cAtividade) // QPPXFUN - Atualiza Cronograma
Endif

DbSelectArea("QK8")
DbSetOrder(1)

aValues := Asort(aValues,,,{|x,y| x[nItFMEA] < y[nItFMEA]}) // Ordena por ordem de Itens
	
For nIt := 1 To Len(aValues)

	If aValues[nIt,Len(aValues[nIt])] // Verifica se item foi excluido Item Excluido

		If ALTERA
			If DbSeek(xFilial("QK8")+ M->QK7_PECA + M->QK7_REV + StrZero(nIt,TamSX3("QK8_SEQ")[1]))
				RecLock("QK8",.F.)
			Else
				/*
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³A Estrutura da tabala esta mal feita, visando manter o legado³
				//³e impedir lixo na base verifico a seq tambem pois existem    ³
				//³situações que gerão lixo na base                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				*/
				DbSetOrder(4)
				If !DbSeek(xFilial("QK8")+ M->QK7_PECA + M->QK7_REV + aValues[nIt,nItFMEA] )
					RecLock("QK8",.T.)
				Else 
					RecLock("QK8",.F.)
				EndIf      
				DbSetOrder(1)
			Endif
		Else	                   
			RecLock("QK8",.T.)
		Endif
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Campos Chave nao informados                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QK8->QK8_FILIAL	:= xFilial("QK8")
		QK8->QK8_PECA 	:= M->QK7_PECA
		QK8->QK8_REV 	:= M->QK7_REV
		QK8->QK8_REVINV	:= Inverte(QK7->QK7_REV)
		QK8->QK8_FILRES	:= cFilAnt
                                                                              
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle de itens                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QK8->QK8_ITEM 	:= StrZero(nIt,TamSX3("QK8_SEQ")[1])
		QK8->QK8_NOPE  	:= aValues[nIt,01]  
		If lFMEA4a
			QK8->QK8_SEVER 	:= aValues[nIt,06]
			QK8->QK8_CLASS 	:= aValues[nIt,07]
			QK8->QK8_OCORR 	:= aValues[nIt,09]
			QK8->QK8_DETEC 	:= aValues[nIt,11]
			QK8->QK8_NPR   	:= aValues[nIt,12]
			QK8->QK8_RESP	:= aValues[nIt,14]
			QK8->QK8_PRAZO 	:= aValues[nIt,15]
			QK8->QK8_RSEVER	:= aValues[nIt,17]
			QK8->QK8_ROCORR	:= aValues[nIt,18]
			QK8->QK8_RDETEC	:= aValues[nIt,19]
			QK8->QK8_RNPR	:= aValues[nIt,20]
			QK8->QK8_SEQ	:= aValues[nIt,21]
			QK8->QK8_CODRES	:= aValues[nIt,23]
			QK8->QK8_ID     := aValues[nIt,26]
			QK8->QK8_DATEEF := aValues[nIt,25]
						
			If !Empty(aValues[nIt,2]) // Funcao / Requisitos
				QK8->QK8_CHAVE1	:= aValues[nIt,24]
	 			axTextos1 := GeraText(nIt,nTamLin,"A")
				QO_GrvTxt(aValues[nIt,24],cEspecie+"A",1,@axTextos1) 	//QPPXFUN
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"A")
			Endif
	
			If !Empty(aValues[nIt,3]) // Modo de falha
				QK8->QK8_CHAVE1	:= aValues[nIt,24]
	 			axTextos9 := GeraText(nIt,nTamLin,"I")
				QO_GrvTxt(aValues[nIt,24],cEspecie+"I",1,@axTextos9)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"I")
			Endif
	
			If !Empty(aValues[nIt,4]) // Modo de falha
				QK8->QK8_CHAVE1	:= aValues[nIt,24]
	 			axTextos2 := GeraText(nIt,nTamLin,"B")
				QO_GrvTxt(aValues[nIt,24],cEspecie+"B",1,@axTextos2)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"B")
			Endif
	
			If !Empty(aValues[nIt,5]) // Efeito da falha
				QK8->QK8_CHAVE1	:= aValues[nIt,24]
	 			axTextos3 := GeraText(nIt,nTamLin,"C")
				QO_GrvTxt(aValues[nIt,24],cEspecie+"C",1,@axTextos3)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"C")
			Endif
			
			If !Empty(aValues[nIt,8]) // Causa/Mecanismo Potencial da Falha
				QK8->QK8_CHAVE1	:= aValues[nIt,24]
	 			axTextos4 := GeraText(nIt,nTamLin,"D")
				QO_GrvTxt(aValues[nIt,24],cEspecie+"D",1,@axTextos4) 
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"D")
			Endif
			
			If !Empty(aValues[nIt,10]) // Controles atuais do projeto prevencao
				QK8->QK8_CHAVE1	:= aValues[nIt,24]
	 			axTextos5 := GeraText(nIt,8,"E")
				QO_GrvTxt(aValues[nIt,24],cEspecie+"E",1,@axTextos5)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"E")
			Endif
	
			If !Empty(aValues[nIt,22]) // Controles atuais do projeto deteccao
				QK8->QK8_CHAVE1	:= aValues[nIt,24]
	 			axTextos8 := GeraText(nIt,8,"H")
				QO_GrvTxt(aValues[nIt,24],cEspecie+"H",1,@axTextos8)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"H")
			Endif
			
						
			If !Empty(aValues[nIt,27]) // Causa
				QK8->QK8_CHAVE1	:= aValues[nIt,24]
	 			axTextos10 := GeraText(nIt,8,"J")
				QO_GrvTxt(aValues[nIt,24],cEspecie+"J",1,@axTextos10)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"J")
			Endif
			
			If !Empty(aValues[nIt,28]) // Modo de Falha
				QK8->QK8_CHAVE1	:= aValues[nIt,24]
	 			axTextos11 := GeraText(nIt,8,"K")
				QO_GrvTxt(aValues[nIt,24],cEspecie+"K",1,@axTextos11)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"K")
			Endif
			
			
			If !Empty(aValues[nIt,13])
				QK8->QK8_CHAVE1	:= aValues[nIt,24]
	 			axTextos6 := GeraText(nIt,nTamLin,"F")
				QO_GrvTxt(aValues[nIt,24],cEspecie+"F",1,@axTextos6)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"F")				
			Endif
	
			If !Empty(aValues[nIt,16]) 
				QK8->QK8_CHAVE1	:= aValues[nIt,24]
	 			axTextos7 := GeraText(nIt,nTamLin,"G")
				QO_GrvTxt(aValues[nIt,24],cEspecie+"G",1,@axTextos7)//aki
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"G")				
			Endif			
		Else
			QK8->QK8_SEVER 	:= aValues[nIt,05]
			QK8->QK8_CLASS 	:= aValues[nIt,06]
			QK8->QK8_OCORR 	:= aValues[nIt,08]
			QK8->QK8_DETEC 	:= aValues[nIt,10]
			QK8->QK8_NPR   	:= aValues[nIt,11]
			QK8->QK8_RESP	:= aValues[nIt,13]
			QK8->QK8_PRAZO 	:= aValues[nIt,14]
			QK8->QK8_RSEVER	:= aValues[nIt,16]
			QK8->QK8_ROCORR	:= aValues[nIt,17]
			QK8->QK8_RDETEC	:= aValues[nIt,18]
			QK8->QK8_RNPR	:= aValues[nIt,19]
			QK8->QK8_SEQ	:= aValues[nIt,20]
			QK8->QK8_CODRES	:= aValues[nIt,22]

			If !Empty(aValues[nIt,2]) // Funcao / Requisitos
				QK8->QK8_CHAVE1	:= aValues[nIt,23]
	 			axTextos1 := GeraText(nIt,nTamLin,"A")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"A",1,@axTextos1) 	//QPPXFUN
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"A")
			Endif
	
			If !Empty(aValues[nIt,3]) // Modo de falha
				QK8->QK8_CHAVE1	:= aValues[nIt,23]
	 			axTextos2 := GeraText(nIt,nTamLin,"B")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"B",1,@axTextos2)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"B")
			Endif
	
			If !Empty(aValues[nIt,4]) // Efeito da falha
				QK8->QK8_CHAVE1	:= aValues[nIt,23]
	 			axTextos3 := GeraText(nIt,nTamLin,"C")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"C",1,@axTextos3)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"C")
			Endif
			
			If !Empty(aValues[nIt,7]) // Causa/Mecanismo Potencial da Falha
				QK8->QK8_CHAVE1	:= aValues[nIt,23]
	 			axTextos4 := GeraText(nIt,nTamLin,"D")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"D",1,@axTextos4) 
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"D")
			Endif
			
			If !Empty(aValues[nIt,9]) // Controles atuais do projeto prevencao
				QK8->QK8_CHAVE1	:= aValues[nIt,23]
	 			axTextos5 := GeraText(nIt,8,"E")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"E",1,@axTextos5)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"E")
			Endif
	
			If !Empty(aValues[nIt,21]) // Controles atuais do projeto deteccao
				QK8->QK8_CHAVE1	:= aValues[nIt,23]
	 			axTextos8 := GeraText(nIt,8,"H")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"H",1,@axTextos8)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"H")
			Endif
	
			If !Empty(aValues[nIt,12])
				QK8->QK8_CHAVE1	:= aValues[nIt,23]
	 			axTextos6 := GeraText(nIt,nTamLin,"F")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"F",1,@axTextos6)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"F")
			Endif
	
			If !Empty(aValues[nIt,15]) 
				QK8->QK8_CHAVE1	:= aValues[nIt,23]
	 			axTextos7 := GeraText(nIt,nTamLin,"G")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"G",1,@axTextos7)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"G")
			Endif
		Endif
		MsUnlock()
		FKCOMMIT()
    Else
 		If DbSeek(xFilial("QK8")+ M->QK7_PECA + M->QK7_REV + StrZero(nIt,TamSX3("QK8_SEQ")[1]))
 			If !Empty(QK8->QK8_CHAVE1)
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"A")    //QPPXFUN
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"B")
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"C")
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"D")
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"E")
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"F")
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"G")
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"H")
				If lFMEA4a
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"I")		
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"J")				
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"K")
				Endif
			Endif

			DbSelectArea("QK8")	
			RecLock("QK8",.F.)
			DbDelete()
			MsUnLock()
			FKCOMMIT()
		Else
			DbSetOrder(4)
			If DbSeek( xFilial("QK8")+ M->QK7_PECA + M->QK7_REV + aValues[nIt,nItFMEA] )
	 			If !Empty(QK8->QK8_CHAVE1)
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"A")    //QPPXFUN
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"B")
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"C")
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"D")
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"E")
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"F")
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"G")
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"H")
					If lFMEA4a
						QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"I")
						QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"J")
						QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"K")
					Endif
				Endif
	
				DbSelectArea("QK8")	
				RecLock("QK8",.F.)
				DbDelete()
				MsUnLock()
				FKCOMMIT()
			EndIf
			DbSetOrder(1)
		Endif
	Endif

Next nIt

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Evito lixo na  base pois a estruturação desta tabela esta comprometida.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
DbSelectArea("QK8")
DbSetOrder(1)
DbGoTop()
If DbSeek(xFilial("QK8")+ M->QK7_PECA + M->QK7_REV )
	While !Eof() .and. ;
		M->QK7_PECA + M->QK7_REV == QK8->QK8_PECA + QK8->QK8_REV
		If aScan(aValues, { |x| x[nItFMEA] == QK8->QK8_SEQ }) <= 0
			RecLock("QK8",.F.)
			DbDelete()
			MsUnLock()
        EndIf
		QK8->(DbSkip())
	EndDo
EndIf

End Transaction
				
Return lGraOk

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GeraText  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 05.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Transformacao do campo memo para gravacao no QKO           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GeraText(ExpN1,ExpN2,ExpC1)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero do Item  									  ³±±
±±³          ³ ExpN2 = Tamanho da linha 								  ³±±
±±³          ³ ExpC1 = Tipo a ser gerado     							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA130                                                    ³±±
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
		Case cTipo == "A" ; nLocal := 2
		Case cTipo == "B" ; nLocal := 4
		Case cTipo == "C" ; nLocal := 5
		Case cTipo == "D" ; nLocal := 8		
		Case cTipo == "E" ; nLocal := 10
		Case cTipo == "F" ; nLocal := 13
		Case cTipo == "G" ; nLocal := 16
		Case cTipo == "H" ; nLocal := 22
		Case cTipo == "J" ; nLocal := 27
		Case cTipo == "K" ; nLocal := 28
	Endcase
Else
	Do Case
		Case cTipo == "A" ; nLocal := 2
		Case cTipo == "B" ; nLocal := 3
		Case cTipo == "C" ; nLocal := 4
		Case cTipo == "D" ; nLocal := 7		
		Case cTipo == "E" ; nLocal := 9
		Case cTipo == "F" ; nLocal := 12
		Case cTipo == "G" ; nLocal := 15
		Case cTipo == "H" ; nLocal := 21
	Endcase
Endif      

If cTipo == "I"
	nLocal := 3
Endif
			
nLinTotal  := MlCount( aValues[nIt,nLocal] , nTamLin)

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
±±³Funcao    ³QPP130REMO³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 05.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclui Item                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP130REMO(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Linha que esta posicionado						  ³±±
±±³          ³ ExpN2 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP130REMO(nx,nOpc)
Local ny
Local nTamAr := 22

If lFMEA4a
	nTamAr := 23
Endif

If nOpc == 3 .or. nOpc == 4

	If aValues[nx,Len(aValues[nx])]
		aPanels[nx]:SetColor(CLR_WHITE,CLR_HGRAY)
		For ny := 1 To nTamAr
			If aOGets[nx,ny] <> Nil
				aOGets[nx,ny]:SetColor(CLR_WHITE,CLR_HGRAY)
				aOGets[nx,ny]:lReadOnly := .T.
			Endif
		Next ny
		aValues[nx,Len(aValues[nx])] := .F.
    Else
		aPanels[nx]:SetColor(CLR_BLACK,CLR_WHITE)
		For ny := 1 To nTamAr
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
±±³Funcao    ³ A130Dele ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 05.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Exclusao                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A130Dele(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A130Dele()

Local cEspecie := "QPPA130"

DbSelectArea("QK8")
DbSetOrder(1)
	
If DbSeek(xFilial("QK8") + QK7->QK7_PECA + QK7->QK7_REV)

	Do While !Eof() .and. ;
		QK7->QK7_PECA + QK7->QK7_REV == QK8_PECA + QK8_REV
		
		If !Empty(QK8->QK8_CHAVE1)
			QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"A")    //QPPXFUN
			QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"B")    //QPPXFUN
			QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"C")    //QPPXFUN
			QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"D")    //QPPXFUN
			QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"E")    //QPPXFUN
			QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"F")    //QPPXFUN
			QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"G")    //QPPXFUN
			If lFMEA4a
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"I")    //QPPXFUN
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"J")    //QPPXFUN			
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"K")    //QPPXFUN	
			Endif
		EndIf		 
		
		DbSelectArea("QK8")
		RecLock("QK8",.F.)
		DbDelete()
		MsUnLock()
		FKCOMMIT()
		DbSkip()
		
	Enddo

Endif

DbSelectArea("QK7")

RecLock("QK7",.F.)
DbDelete()
MsUnLock()
FKCOMMIT()				
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CalcNpr  ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 05.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula o NPR                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CalcNpr(Exp1N)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Linha do array em que esta posicionado             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CalcNPR(nx,u)

Local cPos
Local lRetorno := .T.
Local nNPRMAX	:= GetMv("MV_NPRMAX")

If Empty(u:cText)
	Return .T.
EndIf

If !(Alltrim(u:cText)$"  1 2 3 4 5 6 7 8 9 10")
	lRetorno := .F.
Endif
          
cPos := Right(u:Cargo,2)

If lFMEA4a    // FMEA 4ª EDIÇÂO   
	If lRetorno
		If cPos$"06_09_11"
			aValues[nx,12] := Str(Val(aValues[nx, 6])*Val(aValues[nx, 9])*Val(aValues[nx, 11]),4)
			If Val(aValues[nx,12]) > nNPRMAX
				MessageDlg(STR0028 +aValues[nx,12]+ STR0029,,2) //"O NPR Calculado de "###" esta acima do limite !"
			Endif
		Elseif cPos$"18_19_20"
			aValues[nx,20] := Str(Val(aValues[nx,17])*Val(aValues[nx,18])*Val(aValues[nx,19]),4)
			If Val(aValues[nx,20]) > nNPRMAX
				MessageDlg(STR0028 +aValues[nx,20]+ STR0029,,2) //"O NPR Calculado de "###" esta acima do limite !"
			Endif
		Endif
		aPanels[nx]:Refresh()
	Endif
Else
	If lRetorno
		If cPos$"05_08_10"
			aValues[nx,11] := Str(Val(aValues[nx, 5])*Val(aValues[nx, 8])*Val(aValues[nx, 10]),4)
			If Val(aValues[nx,11]) > nNPRMAX
				MessageDlg(STR0028 +aValues[nx,11]+ STR0029,,2) //"O NPR Calculado de "###" esta acima do limite !"
			Endif
		Elseif cPos$"16_17_18"
			aValues[nx,19] := Str(Val(aValues[nx,16])*Val(aValues[nx,17])*Val(aValues[nx,18]),4)
			If Val(aValues[nx,19]) > nNPRMAX
				MessageDlg(STR0028 +aValues[nx,19]+ STR0029,,2) //"O NPR Calculado de "###" esta acima do limite !"
			Endif
		Endif
		aPanels[nx]:Refresh()
	Endif
Endif
Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP130APRO³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 05.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Aprova / Limpa                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP130APRO(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP130APRO(nOpc)

Local lRet := .T.

If nOpc == 3 .or. nOpc == 4
	DbSelectArea("QAA")
	DbSetOrder(6)
	If Dbseek(Upper(cUserName))
		If ExistBlock("QP130APR")
			lRet := ExecBlock("QP130APR",.F.,.F.)
			If !lRet
				Return lRet
			Endif
		EndIf
		If nOpc == 4
				M->QK7_DATA 	:= Iif(Empty(M->QK7_DATA), dDataBase, CtoD(" / / "))
				M->QK7_APRPOR	:= Iif(Empty(M->QK7_APRPOR),cUserName, Space(40))		
		Else
			M->QK7_DATA 	:= Iif(Empty(M->QK7_DATA), dDataBase, CtoD(" / / "))
			M->QK7_APRPOR	:= Iif(Empty(M->QK7_APRPOR),cUserName, Space(40))
		Endif	
	Else
		messagedlg(STR0039) //O usuário logado não está cadastrado no cadastro de usuários do módulo, portanto não poderá ser o aprovador
	Endif
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³BuscaSXB  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 05.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualizacao de descricao com retorno da consulta           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ BuscaSXB(u,nx,oGet,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do Get  									  ³±±
±±³          ³ ExpN1 = Linha do Array 									  ³±±
±±³          ³ ExpO2 = Objeto do Get 								      ³±±
±±³          ³ ExpN2 = Opcao QKK ou QAA									  ³±±
±±³          ³ ExpO2 = Obejeto BITMAP do campo Class					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function BuscaSXB(u,nx,oGet,nOpc,oBmp)

Local lReturn := .T.
Local lSBOPE  := If(GetMv("MV_QDSBOPE",.F.,1) == 1,.T.,.F.)//Define se o simbolo da operacao será atribuido automaticamente
// ao campo classificacao da severidade se ele nao for definido. 1=SIM 2=NAO 
Local nCont      := 0   

If nOpc == 1
	If !Empty(u:cText)
		QKK->(DbSetOrder(2))
		If (QKK->(DbSeek(xFilial()+M->QK7_PECA+M->QK7_REV+u:cText)))
			aValues[nx,2] := QK8->QK8_SEVER
			If lSBOPE     
				If lFMEA4a
					aValues[nx,7] := QKK->QKK_SBOPE
					avalues[nx,2] := QKK->QKK_DESC
					oBmp:SetBmp(aValues[nx,7])
				Else
					aValues[nx,6] := QKK->QKK_SBOPE
					avalues[nx,2] := QKK->QKK_DESC
					oBmp:SetBmp(aValues[nx,6])
				Endif
				oBmp:Refresh()
			Endif
			oGet:lReadOnly := .T.
		Else
			lReturn := .F.
		Endif
	Else
		oGet:lReadOnly := .F.
	Endif
Elseif nOpc == 2
	If !Empty(u:cText)
		QAA->(DbSetOrder(1))
		If (QAA->(DbSeek(cFilAnt+u:cText)))
			If lFMEA4a
				aValues[nx,14]	:= QAA->QAA_NOME
			Else
				aValues[nx,13]	:= QAA->QAA_NOME
			Endif
			oGet:lReadOnly	:= .T.
		Else
			lReturn := .F.
		Endif
	Else
		oGet:lReadOnly := .F.
	Endif
//Endif
//Verifica o campo de ID da rotina quando esta na Quarta Edição.
Elseif nOpc == 3 .and. !Empty(aValues[nx,26])        
	QKM->(dbSetOrder(2))   //FILIAL+ PECA+ REVISAOINVERTIDA +ITEM
	If QKM->(dbseek(xFilial("QKM")+M->QK7_PECA+Inverte(M->QK7_REV)))
		While !QKM->(EOF()) .And. QKM->(QKM_FILIAL+QKM_PECA+QKM_REVINV) == xFilial("QKM")+M->QK7_PECA+Inverte(M->QK7_REV)
			If QKM->QKM_NOPE == aValues[NX][1] .And. QKM->QKM_NCAR == aValues[NX][26]
   		 		lReturn := .T.
   		 		nCont++
   			EndIf
   			QKM->(dbSkip())
   		EndDo           
		If nCont <= 0
			MsgAlert(STR0047)//"Não existe amarração para esta peça X Funçao X Categoria no cadastro de Plano de controle"
			lReturn := .F.
		EndIf
	Else   		
		If nCont <= 0
			MsgAlert(STR0047)//"Não existe amarração para esta peça X Funçao X Categoria no cadastro de Plano de controle"
			lReturn := .F.
		Endif
	Endif	
Endif                 

Return lReturn


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AtuaCpo  ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 22/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o campo com Zeros a Esquerda                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AtuaCpo(Exp1N)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Linha do array em que esta posicionado             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AtuaCpo(nx)

Local lRetorno := .T.
Local nCont
Local nTam	   := TamSX3("QK8_SEQ")[1]     
Local nItFMEA  := 20

If lFMEA4a
	nItFMEA  := 21
Endif

If !Empty(aValues[nx,nItFMEA])
	If nTam == 5
		aValues[nx,nItFMEA] := StrZero(Val(aValues[nx, nItFMEA]),5)
	Else
		aValues[nx,nItFMEA] := StrZero(Val(aValues[nx, nItFMEA]),3)
	Endif

	For nCont := 1 To Len(aValues)
		If aValues[nx,nItFMEA] == aValues[nCont,nItFMEA] .and. nx <> nCont .and. ;
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
±±³Funcao    ³ ProxDez  ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 22/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Acha a Proxima dezena para seguencia (que ainda nao existe ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ProxDez(Exp1N)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Valor inicial                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ProxDez(nSeed)

Local nRetorno
Local nCont
Local lLoop := .T.
Local nItFMEA := 20

If lFMEA4a
	nItFMEA := 21	
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
