#INCLUDE "QPPA210.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA210  ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 10.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Aprovacao de Aparencia                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA210(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPPAP                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Robson Ramiro³25.06.02³ META ³ Inclusao de Campo memo e melhorias     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui"  , 	0, 1,,.F.},;//"Pesquisar"
					{ OemToAnsi(STR0002), "PPA210Visu", 	0, 2},; 	 //"Visualizar"
					{ OemToAnsi(STR0003), "PPA210Incl", 	0, 3},; 	 //"Incluir"
					{ OemToAnsi(STR0004), "PPA210Alte", 	0, 4},; 	 //"Alterar"
					{ OemToAnsi(STR0005), "PPA210Excl", 	0, 5},; 	 //"Excluir"
					{ OemToAnsi(STR0009), "QPPR210(.T.)", 	0, 6,,.T.} }//"Imprimir"

Return aRotina

Function QPPA210
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro 	:= OemToAnsi(STR0006) //"Aprovacao de Aparencia"
Private cEspecie	:= "QPPA210 "
Private nTamLin		:= 75
Private cAVAP1		:= ""
Private nEdicao     := Val(GetMv("MV_QPPAPED",.T.,"3"))// Indica a Edicao do PPAP default 3 Edicao
Private aRotina := MenuDef()

DbSelectArea("QK3")    
DbSetOrder(1)

mBrowse( 6, 1, 22, 75,"QK3",,,,,,)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA210Visu  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³10.08.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Visualizacao                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA210Visu(ExpC1,ExpN1,ExpN2)                           ³±±
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
Function PPA210Visu(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local aButtons	:= {}
Local oPanel1
Local oPanel2
Local oSize
Local oEnch

Private aHeader	:= {}
Private aCols	:= {}
Private nUsado	:=	0
Private oGet	:= NIL
Private aRazao  := {}
Private cOutros := ""

DbSelectArea(cAlias)

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
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ;  //"Aprovacao de Aparencia"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
				
RegToMemory("QK3")						

If !Empty(M->QK3_CHAVE)
	M->QK3_AVAP1 	:= QO_Rectxt(M->QK3_CHAVE,cEspecie,1, nTamLin,"QKO")
	M->QK3_AVAP1 	:= AllTrim(M->QK3_AVAP1)
	cAVAP1			:= M->QK3_AVAP1
Endif

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
oEnch:=MsMGet():New("QK3",nReg,nOpc,,,,,oSize:aPosObj[1],,,,,,oPanel1,,,,,,,,,)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PP210Ahead("QK4")

nUsado	:= Len(aHeader)

PP210Acols(nOpc)

aButtons := { {"BMPVISUAL", { || QPPR210() }, OemToAnsi(STR0008), OemToAnsi(STR0010) }} //"Visualizar/Imprimir"###"Vis/Prn"
If nEdicao == 4
	aAdd(aButtons ,{"AUTOM", { || QPP210RAZA(cAlias,nReg,nOpc,@cOutros)}, STR0013, STR0012})//"Razao p/submissao"###"Razao"                                         
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet := MSGetDados():New(90,03,190,332, nOpc,"AllwaysTrue","AllwaysTrue","+QK4_ITEM",.T.,,,,,,,,,oPanel2)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}, , aButtons) CENTERED

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA210Incl  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³23.07.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Inclusao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA210Incl(ExpC1,ExpN1,ExpN2)                           ³±±
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
Function PPA210Incl(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local lOk 		:= .F.
Local aButtons	:= {}
Local oPanel1
Local oPanel2
Local oSize
Local oEnch

Private aHeader	:= {}
Private aCols	:= {}
Private nUsado	:=	0
Private oGet	:= NIL
Private aRazao  := {}
Private cOutros := ""                                    
Private aCpos   := {}

DbSelectArea(cAlias)

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
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ;  //"Aprovacao de Aparencia"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
					
RegToMemory("QK3",.T.)						

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
oEnch:=MsMGet():New("QK3",nReg,nOpc, , , ,,oSize:aPosObj[1],,,,,,oPanel1,,,,,,,,,)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PP210Ahead("QK4")

nUsado	:= Len(aHeader)

PP210Acols(nOpc)

aButtons := { {"EDIT", { || QPP210APRO(nOpc) }, OemToAnsi(STR0007), OemToAnsi(STR0011)}} //"Aprovar/Limpar"###"Apro/Lim"
If nEdicao == 4
	aAdd(aButtons ,{"AUTOM", { || QPP210RAZA(cAlias,nReg,nOpc,@cOutros)}, STR0013, STR0012})//"Razao p/submissao"###"Razao"                                         
Endif

DbSelectArea("QK4")						

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet := MSGetDados():New(90,03,190,332, nOpc,"PP210LinOk","PP210TudOk","+QK4_ITEM",.T.,,,,,,,,,oPanel2)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP210TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

If lOk
	A210Grav(nOpc)
Endif

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA210Alte  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³10.08.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Alteracao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA210Alte(ExpC1,ExpN1,ExpN2)                           ³±±
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
Function PPA210Alte(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local lOk 		:= .F.
Local aCposAlt	:= {}
Local aButtons	:= {}
Local oPanel1
Local oPanel2
Local oSize
Local oEnch

Private aHeader	:= {}
Private aCols	:= {}
Private nUsado	:=	0
Private oGet	:= NIL
Private aRazao  := {}
Private cOutros := "" 

If !QPPVldAlt(QK3->QK3_PECA,QK3->QK3_REV,QK3->QK3_ASSFOR)
	Return
Endif

DbSelectArea(cAlias)

aCposAlt := {	"QK3_NIVALT", "QK3_NDESEN"	, "QK3_DTALTE"	,;
				"QK3_LOCALI", "QK3_COMPRA"	, "QK3_ASSFOR"	,;
				"QK3_TELFOR", "QK3_DTAFOR"	, "QK3_ASSCLI"	,;
				"QK3_DTACLI", "QK3_COMENT" 	, "QK3_RAZAO"	,;
				"QK3_AVAP1" }

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
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ;  //"Aprovacao de Aparencia"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
				
RegToMemory("QK3",.F.)

If !Empty(M->QK3_CHAVE)
	M->QK3_AVAP1 	:= QO_Rectxt(M->QK3_CHAVE,cEspecie,1, nTamLin,"QKO")
	M->QK3_AVAP1 	:= AllTrim(M->QK3_AVAP1)
	cAVAP1			:= M->QK3_AVAP1
Endif

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
oEnch:=MsMGet():New("QK3",nReg,nOpc,,,,,oSize:aPosObj[1],aCposAlt,,,,,oPanel1,,,,,,,,,)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PP210Ahead("QK4")

nUsado	:= Len(aHeader)

PP210Acols(nOpc)

DbSelectArea("QK4")						

aAdd(aButtons ,{"EDIT", { || QPP210APRO(nOpc)}, STR0007, STR0011}) //"Aprovar/Limpar"###"Apro/Lim"
If nEdicao == 4
	aAdd(aButtons ,{"AUTOM", { || QPP210RAZA(cAlias,nReg,nOpc,@cOutros)}, STR0013, STR0012})//"Razao p/submissao"###"Razao"                                         
Endif
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet := MSGetDados():New(90,03,190,332, nOpc,"PP210LinOk","PP210TudOk","+QK4_ITEM",.T.,,,,,,,,,oPanel2)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP210TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

If lOk
	A210Grav(nOpc)
Endif

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA210Excl  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³10.08.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Exclusao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA210Excl(ExpC1,ExpN1,ExpN2)                                ³±±
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
Function PPA210Excl(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local aButtons	:= {}
Local oPanel1
Local oPanel2
Local oSize
Local oEnch

Private aHeader	:= {}
Private aCols	:= {}
Private nUsado	:=	0
Private oGet	:= NIL
Private aRazao  := {}
Private cOutros := ""  

If !QPPVldExc(QK3->QK3_REV,QK3->QK3_ASSFOR)
	Return
Endif


DbSelectArea(cAlias)

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
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ;  //"Aprovacao de Aparencia"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
				
RegToMemory("QK3")						

If !Empty(M->QK3_CHAVE)
	M->QK3_AVAP1 	:= QO_Rectxt(M->QK3_CHAVE,cEspecie,1, nTamLin,"QKO")
	M->QK3_AVAP1 	:= AllTrim(M->QK3_AVAP1)
	cAVAP1			:= M->QK3_AVAP1
Endif

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
oEnch:=MsMGet():New("QK3",nReg,nOpc,,,,,oSize:aPosObj[1],,,,,,oPanel1,,,,,,,,,)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PP210Ahead("QK4")

nUsado	:= Len(aHeader)

PP210Acols(nOpc)

aButtons := { {"BMPVISUAL", { || QPPR210() }, OemToAnsi(STR0008), OemToAnsi(STR0010) }} //"Visualizar/Imprimir"###"Vis/Prn"
If nEdicao == 4
	aAdd(aButtons ,{"AUTOM", { || QPP210RAZA(cAlias,nReg,nOpc,@cOutros)}, STR0013, STR0012})//"Razao p/submissao"###"Razao"                                         
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet := MSGetDados():New(90,03,190,332, nOpc,"AllwaysTrue","AllwaysTrue","+QK4_ITEM",.T.,,,,,,,,,oPanel2)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| A210Dele(),oDlg:End()},{||oDlg:End()}, , aButtons)CENTERED

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³PP210Acols³ Autor ³ Robson Ramiro A. Olive³ Data ³ 10.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega vetor aCols para a GetDados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q010Acols()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA210                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PP210Acols(nOpc)
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
			aCols[1,nI] := CtoD(" / / ")
		ElseIf aHeader[nI,8] == "M"
			aCols[1,nI] := ""
		Else
			aCols[1,nI] := .F.
		EndIf
	Next nI

	nPos			:= aScan(aHeader,{ |x| AllTrim(x[2])== "QK4_ITEM" })
	aCols[1,nPos]	:= StrZero(1,Len(aCols[1,nPos]))
	
	aCols[1,nUsado+1] := .F.	

Else
	
	DbSelectArea("QK4")    
	DbSetOrder(1)
	DbSeek(xFilial()+QK3->QK3_PECA+QK3->QK3_REV)
	aArea := QK4->(GetArea())

	Do While QK4->(!Eof()) .and. xFilial() == QK3->QK3_FILIAL .and.;
	         QK4->QK4_PECA+QK4->QK4_REV == QK3->QK3_PECA+QK3->QK3_REV

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
±±³Funcao    ³PP210Ahead³ Autor ³ Robson Ramiro A. Olive³ Data ³ 10.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Ahead para aCols                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP210Ahead()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA210                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PP210Ahead(cAlias)

Local aStruAlias := FWFormStruct(3, cAlias)[3]
Local nX

aHeader := {}
nUsado 	:= 0

For nX := 1 To Len(aStruAlias)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ignora campos que nao devem aparecer na getdados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  nEdicao == 4
		If Upper(AllTrim(aStruAlias[nX,1])) == "QK4_PECA" 	.or. ;
			Upper(AllTrim(aStruAlias[nX,1])) == "QK4_REV"
		Loop
		EndIf
	Else
		If  Upper(AllTrim(aStruAlias[nX,1])) == "QK4_PECA" 	.or. ;
			Upper(AllTrim(aStruAlias[nX,1])) == "QK4_BMBAIX".or. ;
			Upper(AllTrim(aStruAlias[nX,1])) == "QK4_BMALTO".or. ;
			Upper(AllTrim(aStruAlias[nX,1])) == "QK4_REV"
			Loop
		Endif
	Endif
	
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
Next nX   

Return



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A210Grav ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 10.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Gravacao - Incl./Alter.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A210Grav(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA210                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A210Grav(nOpc)

Local nIt     
Local nCont
Local nNumItem
Local nPosDel 		:= Len(aHeader) + 1
Local nCpo
Local bCampo		:= { |nCPO| Field(nCPO) }
Local lGraOk 		:= .T.   	// Indica se todas as gravacoes obtiveram sucesso
Local cAtividade	:= "11 " 	// Definido no ID - QKZ
Local aAVAP1		:= {}  		// Array para converter o texto
Local nSaveSX8		:= GetSX8Len()

Begin Transaction

// Verifica se existe texto antes de criar chave
If Empty(M->QK3_CHAVE) .and. !Empty(M->QK3_AVAP1)
	M->QK3_CHAVE := GetSXENum("QK3", "QK3_CHAVE",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

Endif

DbSelectArea("QK3")
DbSetOrder(1)

If INCLUI
	RecLock("QK3",.T.)
Else
	RecLock("QK3",.F.)
Endif

For nCont := 1 To FCount()

	If "FILIAL"$Field(nCont)
		FieldPut(nCont,xFilial("QK3"))
	Else
		FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
	Endif

Next nCont

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos nao informados                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QK3->QK3_REVINV := Inverte(QK3->QK3_REV)

If !Empty(M->QK3_CHAVE)
	aAVAP1 := GeraText(nTamLin, AllTrim(M->QK3_AVAP1))
	QO_GrvTxt(M->QK3_CHAVE,cEspecie,1,@aAVAP1)
Endif

If !Empty(QK3->QK3_DTAFOR) .and. !Empty(QK3->QK3_ASSFOR)
	QPP_CRONO(QK3->QK3_PECA,QK3->QK3_REV,cAtividade) // QPPXFUN - Atualiza Cronograma
Endif

MsUnLock()
FKCOMMIT()

DbSelectArea("QK4")
DbSetOrder(1)

nNumItem := 1  // Contador para os Itens
	
For nIt := 1 To Len(aCols)

	If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

		If ALTERA
		
			If DbSeek(xFilial("QK4")+ M->QK3_PECA + M->QK3_REV + StrZero(nIt,2))
				RecLock("QK4",.F.)
			Else
				RecLock("QK4",.T.)
			Endif
		Else	                   
			RecLock("QK4",.T.)
		Endif
			
		For nCpo := 1 To Len(aHeader)
			If aHeader[nCpo, 10] <> "V"
				QK4->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
			EndIf
		Next nCpo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Campos Chave nao informados                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QK4->QK4_FILIAL	 := xFilial("QK4")
		QK4->QK4_PECA 	 := M->QK3_PECA
		QK4->QK4_REV 	 := M->QK3_REV
		QK4->QK4_REVINV	 := Inverte(QK3->QK3_REV)
                                                                              
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle de itens do acols                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QK4->QK4_ITEM := StrZero(nNumItem,2)

		nNumItem++

		MsUnlock()
		FKCOMMIT()
    Else
   		If DbSeek(xFilial("QK4")+ M->QK3_PECA + M->QK3_REV + StrZero(nIt,2))
			RecLock("QK4",.F.)
			DbDelete()
			MsUnlock()
			FKCOMMIT()
		Endif
	Endif

Next nIt

End Transaction
				
Return lGraOk


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A210Dele ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 10.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Exclusao                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A210Dele(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA210                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A210Dele()

DbSelectArea("QK4")
DbSetOrder(1)
	
If DbSeek(xFilial("QK4")+ QK3->QK3_PECA + QK3->QK3_REV)

	Do While !Eof() .and. ;
		QK3->QK3_PECA + QK3->QK3_REV == QK4_PECA + QK4_REV
		
		RecLock("QK4",.F.)
		DbDelete()
		MsUnLock()    
		FKCOMMIT()
		
		DbSkip()
		
	Enddo

Endif

DbSelectArea("QK3")

If !Empty(M->QK3_CHAVE)
	QO_DelTxt(M->QK3_CHAVE,cEspecie) //QPPXFUN
Endif

RecLock("QK3",.F.)
DbDelete()
MsUnLock()
FKCOMMIT()
				
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PP210TudOk³ Autor ³ Robson Ramiro A. Olive³ Data ³ 10.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para inclusao/alteracao geral                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP210TudOk                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Function PP210TudOk

Local lRetorno	:= .T.
Local nIt 		:= 0
Local nTot		:= 0
Local nPosDel  	:= Len(aHeader) + 1

For nIt := 1 To Len(aCols)
	If aCols[nIt, nPosDel]
		nTot ++
	Endif
Next nIt

If Empty(M->QK3_PECA) .or. Empty(M->QK3_REV) .or. nTot == Len(aCols)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
EndIf

If INCLUI
	If !ExistChav("QK3",M->QK3_PECA+M->QK3_REV)
		lRetorno := .F.
		Help(" ",1,"JAGRAVADO")  // Campo ja Existe
	Endif
	If !ExistCpo("QK1",M->QK3_PECA+M->QK3_REV)
		lRetorno := .F.
		Help(" ",1,"REGNOIS")  // Nao existe amarracao
	Endif
Endif

Return lRetorno

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PP210LinOk³ Autor ³ Robson Ramiro A. Olive³ Data ³ 10.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para linha                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP210LinOk                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Function PP210LinOk

Local lRetorno 	:= .F.
Local nPosDel 	:= Len(aHeader) + 1
Local nCpo

If !aCols[n, nPosDel]  // Verifica se o item foi deletado
	For nCpo := 2 To Len(aHeader) // Ignora o Item
		If !Empty(aCols[n, nCpo]) .and. ValType(aCols[n, nCpo]) <> "D"
			lRetorno := .T.
		Endif
	Next nCpo
Else
	lRetorno := .T.
Endif

If !lRetorno
	Help(" ",1,"QPPA210AO1")  // Ao menos 1 campo deve ser preenchido !
Endif

Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP210APRO³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 07.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Aprova                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP210APRO(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA210                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP210APRO(nOpc)
                                        
If nOpc == 3 .or. nOpc == 4
	DbSelectArea("QAA")
	DbSetOrder(6)
	If Dbseek(Upper(cUserName))
		M->QK3_DTAFOR  	:= Iif(Empty(M->QK3_DTAFOR), dDataBase, CtoD(" / / "))
		M->QK3_ASSFOR  	:= Iif(Empty(M->QK3_ASSFOR), cUserName, Space(40))
	Else
   		messagedlg(STR0034) //O usuário logado não está cadastrado no cadastro de usuários do módulo, portanto não poderá ser o aprovador
	Endif
Endif

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP210Raza  ³ Autor ³ Adalberto Mendes Neto ³ Data ³20/04/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Selecionar as Razoes de Submissao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA210Raza(ExpC1,ExpN1,ExpN2)                           ³±±
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
Function QPP210Raza(cAlias,nReg,nOpc,cOutros)

Local oDlg
Local oNumPc
Local oOutros
Local oRev
Local oDescrPc
Local oCliente
Local oScrollBox
Local oChk01
Local oChk02
Local oChk03
Local oChk04
Local oChk05
Local oChk06
Local oChk07
Local oChk08
Local oChk09
Local oChk10
Local oChk11
Local oChk12
Local oChk13
Local oChk14
Local oPanel1   
Local nOpca := 2
Local lOk			:= .F.
Local nLin 			:= 0
Local cChave		:= ""       
Local nI := 0                                                      
Local cRaz := ""

Private cK3NumPc   := CriaVar("QK3_PECA")   
Private cK3Rev	   := CriaVar("QK3_REV")
Private aObjetos := {}  
Private lChk01	 := .F.
Private lChk02   := .F.
Private lChk03	 := .F.
Private lChk04   := .F.
Private lChk05	 := .F.
Private lChk06   := .F.
Private lChk07	 := .F.
Private lChk08	 := .F.
Private lChk09	 := .F.
Private lChk10	 := .F.
Private lChk11	 := .F.
Private lChk12	 := .F.
Private lChk13	 := .F.
Private lChk14	 := .F.
Private cMensagem  := "Para marcar a opção de Razão para Submissão OUTROS, é obrigatório informar qual esta razão."
Private cMensagem2 := "Quando é desmarcada a opção de Razão para Submissão OUTROS, o texto da razão deve ser apagado."
Private cTitulo    := "Razão para Submissão"
Private lRetorno   := .T.

DbSelectArea("QK3")    
DbSetOrder(1)

If DbSeek(xFilial("QK3")+M->QK3_PECA+M->QK3_REV)
	cK3NumPc   	:= QK3->QK3_PECA
	cK3Rev		:= QK3->QK3_REV               
	Else
	cK3NumPc   	:= M->QK3_PECA
	cK3Rev		:= M->QK3_REV               
Endif

cChave := xFilial("QK3") + cK3NumPc + cK3Rev

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Tela	    										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM 000,000 TO 345,625 OF oMainWnd PIXEL

SetDlg(oDlg)

RegToMemory("QK3",(nOpc == 3))

DEFINE FONT oFnt NAME "Arial" SIZE 5,15 

@ 018,003 SAY OemToAnsi( STR0023 ) SIZE 040,010 COLOR CLR_HBLUE OF oDlg PIXEL      //Num. Peca
@ 018,035 MSGET oNumPc VAR cK3NumPc ReadOnly SIZE 130,005 OF oDlg PIXEL

If nOpc == 3
	oNumpc:lReadOnly := .T.
	cOutros  := CriaVar("QK3_OUTROS")
Endif

@ 018,173 SAY OemToAnsi( STR0024 ) SIZE 040,010 COLOR CLR_HBLUE OF oDlg PIXEL		  //Revisao
@ 018,199 MSGET oRev VAR cK3Rev SIZE 003,005 OF oDlg PIXEL

@ 038,003 MSPANEL oPanel1 PROMPT "" COLOR CLR_WHITE,CLR_BLACK SIZE 307,010 OF oDlg
@ 001,004 SAY OemToAnsi( STR0021 ) COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL		  //Sim
@ 001,015 SAY OemToAnsi( STR0022 ) COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL		  //Nao
@ 001,130 SAY OemToAnsi( STR0013 ) COLOR CLR_WHITE SIZE 085,010 OF oPanel1 PIXEL		  //Razoes

oScrollBox := TScrollBox():new(oDlg,053,003, 095,308,.T.,.T.,.T.)


@ 007,006 CHECKBOX oChk01 VAR lChk01	SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk01,( lChk02:=.F.,oChk02:Refresh()), )
@ 007,015 CHECKBOX oChk02 VAR lChk02	SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk02,( lChk01:=.F.,oChk01:Refresh()), )		
@ 007,026 SAY OemToAnsi( STR0014 ) SIZE 260,010 OF oScrollBox PIXEL FONT oFnt
@ 010,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL


@ 019,006 CHECKBOX oChk03 VAR lChk03 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk03,( lChk04:=.F.,oChk04:Refresh()), )
@ 019,015 CHECKBOX oChk04 VAR lChk04 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk04,( lChk03:=.F.,oChk03:Refresh()), )
@ 019,026 SAY OemToAnsi(STR0015) SIZE 260,010 OF oScrollBox PIXEL FONT oFnt
@ 021,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL


@ 030,006 CHECKBOX oChk05 VAR lChk05 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk05,( lChk06:=.F.,oChk06:Refresh()), )
@ 030,015 CHECKBOX oChk06 VAR lChk06 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk06,( lChk05:=.F.,oChk05:Refresh()), )
@ 030,026 SAY OemToAnsi(STR0016) SIZE 260,010 OF oScrollBox PIXEL FONT oFnt
@ 033,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL


@ 042,006 CHECKBOX oChk07 VAR lChk07 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk07,( lChk08:=.F.,oChk08:Refresh()), )                                                                                
@ 042,015 CHECKBOX oChk08 VAR lChk08 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk08,( lChk07:=.F.,oChk07:Refresh()), )   
@ 042,026 SAY OemToAnsi(STR0017) SIZE 260,010 OF oScrollBox PIXEL FONT oFnt
@ 045,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL


@ 054,006 CHECKBOX oChk09 VAR lChk09 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk09,( lChk10:=.F.,oChk10:Refresh()), )
@ 054,015 CHECKBOX oChk10 VAR lChk10 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk10,( lChk09:=.F.,oChk09:Refresh()), )	
@ 054,026 SAY OemToAnsi(STR0018) SIZE 260,010 OF oScrollBox PIXEL FONT oFnt 
@ 057,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL


@ 066,006 CHECKBOX oChk11 VAR lChk11 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk11,( lChk12:=.F.,oChk12:Refresh()), )
@ 066,015 CHECKBOX oChk12 VAR lChk12 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk12,( lChk11:=.F.,oChk11:Refresh()), )
@ 066,026 SAY OemToAnsi(STR0019) SIZE 260,010 OF oScrollBox PIXEL FONT oFnt 
@ 069,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL


@ 078,006 CHECKBOX oChk13 VAR lChk13 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk13,( lChk14:=.F.,oChk14:Refresh()), )
@ 078,015 CHECKBOX oChk14 VAR lChk14 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk14,( lChk13:=.F.,oChk13:Refresh()), )
@ 078,026 SAY OemToAnsi(STR0020) SIZE 260,010 OF oScrollBox PIXEL FONT oFnt   

@ 095,015 MSGET oOutros VAR cOutros  SIZE 280, 010 OF oScrollBox PIXEL

nLin := 95   

@ 002,003 TO nLin,025    	OF oScrollBox PIXEL // Coluna 1
@ 002,003 TO nLin,014.5  	OF oScrollBox PIXEL // Coluna 2
@ 002,003 TO nLin,296		OF oScrollBox PIXEL // Coluna 3

If nOpc == 2 .Or. nOpc == 5
	oNumPc:lReadOnly:= .T.
	oRev:lReadOnly:= .T.
	oChk01:lReadOnly:= .T.
	oChk02:lReadOnly:= .T.
	oChk03:lReadOnly:= .T.
	oChk04:lReadOnly:= .T.
	oChk05:lReadOnly:= .T.
	oChk06:lReadOnly:= .T.
	oChk07:lReadOnly:= .T.
	oChk08:lReadOnly:= .T.
	oChk09:lReadOnly:= .T.
	oChk10:lReadOnly:= .T.
	oChk11:lReadOnly:= .T.
	oChk12:lReadOnly:= .T.
	oChk13:lReadOnly:= .T.
	oChk14:lReadOnly:= .T.	
	oOutros:lReadOnly:= .T.
	SysRefresh()
ElseIf nOpc == 4
	oNumPc:lReadOnly:= .T.
	oRev:lReadOnly:= .T.
	SysRefresh()
EndIf


ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca := 1,cOutros := Alltrim(oOutros:cText),oDlg:End()},{|| nOpca := 2,oDlg:End()}) CENTERED

If nOpca == 1
	If !lChk01
		aAdd(aRazao,"N")
	Else
	    aAdd(aRazao,"S")
	Endif
	
	If !lChk03
		aAdd(aRazao,"N")
	Else
	    aAdd(aRazao,"S")
	Endif

	If !lChk05
		aAdd(aRazao,"N")
	Else
	    aAdd(aRazao,"S")
	Endif
	
	If !lChk07
		aAdd(aRazao,"N")
	Else
	    aAdd(aRazao,"S")
	Endif
	
	If !lChk09
		aAdd(aRazao,"N")
	Else
	    aAdd(aRazao,"S")
	Endif    
	
	If !lChk11
		aAdd(aRazao,"N")
	Else
	    aAdd(aRazao,"S")
	Endif
	
	If !lChk13
		aAdd(aRazao,"N")
	Else
	    aAdd(aRazao,"S")
	Endif                                                              
	
	If !lChk13 	.And. !Empty(cOUTROS)
		MsgInfo(cMensagem2,cTitulo)
		lRetorno:= .F.		
	Endif
	
	If lChk13 	.And. Empty(cOutros) 
	    MsgInfo(cMensagem,cTitulo)
		lRetorno:= .F.		
	Endif
		
Endif

Return (lRetorno)
