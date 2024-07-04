#INCLUDE "QPPA230.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA230  ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 14.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Sumario e APQP                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA230(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PPAP                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Robson Ramiro³06/09/02³xMETA ³ Troca da QA_CVKEY por GetSXENum        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := { 	{ OemToAnsi(STR0001),"AxPesqui"  , 	0, 1,,.F.},; 	//"Pesquisar"
					{ OemToAnsi(STR0002),"PPA230Visu", 	0, 2},; 		//"Visualizar"
					{ OemToAnsi(STR0003),"PPA230Incl", 	0, 3},; 		//"Incluir"
					{ OemToAnsi(STR0004),"PPA230Alte", 	0, 4},; 		//"Alterar"
					{ OemToAnsi(STR0005),"PPA230Excl", 	0, 5},; 		//"Excluir"
					{ OemToAnsi(STR0047),"QPPR230(.T.)", 	0, 6,,.T.} }//"Imprimir"

Return aRotina

Function QPPA230()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0006) //"Sumario e APQP"

Private aRotina := MenuDef()

DbSelectArea("QKJ")
DbSetOrder(1)

mBrowse( 6, 1, 22, 75,"QKJ",,,,,,)

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA230Visu  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³14.09.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Visualizacao                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA230Visu(ExpC1,ExpN1,ExpN2)                           ³±±
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

Function PPA230Visu(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local oPanel		:= NIL
Local aButtons		:= {}
Local oPECA
Local oREV
Local oDATA
Local oCliente, cCliente
Local oDescricao, cDescricao
Local oPlManuf
Local oPanel1
Local oPanel2
Local oSize

Private oGet := NIL
Private aItems, cChoice
				
aButtons := { 	{"RELATORIO", 	{ || QPP230PLAN(nOpc) },	OemToAnsi(STR0007), OemToAnsi(STR0048) },; //"Plano de Acao"###"Pln Acao"
				{"BMPVISUAL",	{ || QPPR230() },			OemToAnsi(STR0008), OemToAnsi(STR0049) }} 	//"Visualizar/Imprimir"###"Vis/Prn"

DbSelectArea(cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New( .F. )

oSize:AddObject( "CIMA"  ,  100,  40, .T., .F., .T. ) // Nao dimensiona Y 
oSize:AddObject( "BAIXO",  100, 100, .T., .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) ;  //"Sumario e APQP"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

SetDlg(oDlg)						
RegToMemory("QKJ")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona Panel                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel1:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[1,3])
oPanel2:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[2,3])

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

aItems 	:= {STR0009, STR0010,"        "} //"1 - SIM "###"2 - NAO*"
cChoice	:= Iif(!Empty(M->QKJ_APRPLN),Iif(M->QKJ_APRPLN == "1",aItems[1],aItems[2]),aItems[3])

@ oSize:aPosObj[1,1],003 SAY OemToAnsi(STR0011) SIZE 040,010 COLOR CLR_HBLUE OF oPanel1 PIXEL //"No. Peca"
@ oSize:aPosObj[1,1],035 MSGET oPECA VAR M->QKJ_PECA ReadOnly F3 "QPP" SIZE 130,005 OF oPanel1 PIXEL

@ oSize:aPosObj[1,1],176 SAY OemToAnsi(STR0012) SIZE 040,010 COLOR CLR_HBLUE OF oPanel1 PIXEL //"Revisao"
@ oSize:aPosObj[1,1],202 MSGET oREV VAR M->QKJ_REV SIZE 003,005 OF oPanel1 PIXEL WHEN .F. 

PPA230Vld(nOpc,@cDescricao,@cCliente)

@ oSize:aPosObj[1,1],226 SAY OemToAnsi(STR0013) SIZE 016,010 OF oPanel1 PIXEL //"Data"
@ oSize:aPosObj[1,1],246 MSGET oDATA VAR M->QKJ_DATA SIZE 033,005 OF oPanel1 PIXEL WHEN .F.

@ oSize:aPosObj[1,1]+13,003 SAY OemToAnsi(STR0014) SIZE 040,010 OF oPanel1 PIXEL //"Descricao"
@ oSize:aPosObj[1,1]+13,035 MSGET oDescricao VAR cDescricao SIZE 245,005 OF oPanel1 PIXEL WHEN .F.

@ oSize:aPosObj[1,1]+27,003 SAY OemToAnsi(STR0015) SIZE 040,010 OF oPanel1 PIXEL //"Cliente"
@ oSize:aPosObj[1,1]+27,035 MSGET oCliente VAR cCliente SIZE 130,005 OF oPanel1 PIXEL WHEN .F.

@ oSize:aPosObj[1,1]+27,165 SAY OemToAnsi(STR0050) SIZE 040,010 OF oPanel1 PIXEL //"Plano Manuf."
@ oSize:aPosObj[1,1]+27,200 MSGET oPlManuf VAR M->QKJ_PMANUF SIZE 80,005 OF oPanel1 PIXEL WHEN .F.

@ 055,003 MSPANEL oPanel PROMPT "" COLOR CLR_WHITE,CLR_BLACK SIZE 327,010 OF oPanel2
@ 003,080 SAY OemToAnsi(STR0016) COLOR CLR_WHITE SIZE 200,010 OF oPanel PIXEL //"APROVACAO DO PLANEJAMENTO DA QUALIDADE DO PRODUTO"
					
QPP230TELA(nOpc,oPanel2)
                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}, , aButtons) CENTERED

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA230Incl  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³14.09.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Inclusao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA230Incl(ExpC1,ExpN1,ExpN2)                           ³±±
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

Function PPA230Incl(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local oPanel		:= NIL
Local lOk 			:= .F.
Local aButtons		:= {}
Local oPECA
Local oREV
Local oDATA
Local oCliente, cCliente
Local oDescricao, cDescricao
Local oPlManuf
Local oPanel1
Local oPanel2
Local oSize

Private aItems, cChoice
Private oGet := NIL
				
aButtons := { {"RELATORIO", { || QPP230PLAN(nOpc) }, OemToAnsi(STR0007), OemToAnsi(STR0048) }} //"Plano de Acao"###"Pln Acao"

aItems 	:= {STR0009, STR0010,"        "} //"1 - SIM "###"2 - NAO*"
cChoice	:= aItems[1]

DbSelectArea(cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New( .F. )

oSize:AddObject( "CIMA"  ,  100,  40, .T., .F., .T. ) // Nao dimensiona Y 
oSize:AddObject( "BAIXO",  100, 100, .T., .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) ;  //"Sumario e APQP"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
						
SetDlg(oDlg)
RegToMemory("QKJ",.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona Panel                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel1:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[1,3])
oPanel2:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[2,3])

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

@ oSize:aPosObj[1,1],003 SAY OemToAnsi(STR0011) SIZE 040,010 COLOR CLR_HBLUE OF oPanel1 PIXEL //"No. Peca"
@ oSize:aPosObj[1,1],035 MSGET oPECA VAR M->QKJ_PECA F3 "QPP" SIZE 130,005 PICTURE PesqPict("QKJ", "QKJ_PECA");
			OF oPanel1 PIXEL

@ oSize:aPosObj[1,1],176 SAY OemToAnsi(STR0012) SIZE 040,010 COLOR CLR_HBLUE OF oPanel1 PIXEL //"Revisao"
@ oSize:aPosObj[1,1],202 MSGET oREV VAR M->QKJ_REV SIZE 003,005 PICTURE PesqPict("QKJ", "QKJ_PECA") ;
			OF oPanel1 PIXEL VALID PPA230Vld(nOpc,@cDescricao,@cCliente)

@ oSize:aPosObj[1,1],226 SAY OemToAnsi(STR0013) SIZE 016,010 OF oPanel1 PIXEL //"Data"
@ oSize:aPosObj[1,1],246 MSGET oDATA VAR M->QKJ_DATA SIZE 033,005 OF oPanel1 PIXEL

@ oSize:aPosObj[1,1]+13,003 SAY OemToAnsi(STR0014) SIZE 040,010 OF oPanel1 PIXEL //"Descricao"
@ oSize:aPosObj[1,1]+13,035 MSGET oDescricao VAR cDescricao SIZE 245,005 OF oPanel1 PIXEL WHEN .F.

@ oSize:aPosObj[1,1]+27,003 SAY OemToAnsi(STR0015) SIZE 040,010 OF oPanel1 PIXEL //"Cliente"
@ oSize:aPosObj[1,1]+27,035 MSGET oCliente VAR cCliente SIZE 130,005 OF oPanel1 PIXEL WHEN .F.

@ oSize:aPosObj[1,1]+27,165 SAY OemToAnsi(STR0050) SIZE 040,010 OF oPanel1 PIXEL //"Plano Manuf."
@ oSize:aPosObj[1,1]+27,200 MSGET oPlManuf VAR M->QKJ_PMANUF SIZE 80,005 OF oPanel1 PIXEL

@ 055,003 MSPANEL oPanel PROMPT "" COLOR CLR_WHITE,CLR_BLACK SIZE 327,010 OF oPanel2
@ 003,080 SAY OemToAnsi(STR0016) COLOR CLR_WHITE SIZE 200,010 OF oPanel PIXEL //"APROVACAO DO PLANEJAMENTO DA QUALIDADE DO PRODUTO"
						
QPP230TELA(nOpc,oPanel2)
                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP230TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, ,aButtons ) CENTERED

If lOk
	PPA230Grav(nOpc)
Endif

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA230Alte  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³14.09.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Alteracao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA230Alte(ExpC1,ExpN1,ExpN2)                           ³±±
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

Function PPA230Alte(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local oPanel		:= NIL
Local lOk 			:= .F.
Local aButtons		:= {}
Local oPECA
Local oREV
Local oDATA
Local oCliente, cCliente
Local oDescricao, cDescricao
Local oPlManuf
Local oPanel1
Local oPanel2
Local oSize

Private aItems, cChoice
Private oGet := NIL
				
aButtons := { {"RELATORIO", { || QPP230PLAN(nOpc) }, OemToAnsi(STR0007), OemToAnsi(STR0048) }} //"Plano de Acao"###"Pln Acao"

If !QPPVldAlt(QKJ->QKJ_PECA,QKJ->QKJ_REV)
	Return
Endif

DbSelectArea(cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New( .F. )

oSize:AddObject( "CIMA"  ,  100,  40, .T., .F., .T. ) // Nao dimensiona Y 
oSize:AddObject( "BAIXO",  100, 100, .T., .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) ;  //"Sumario e APQP"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
						
SetDlg(oDlg)
RegToMemory("QKJ")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona Panel                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel1:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[1,3])
oPanel2:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[2,3])

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

aItems 	:= {STR0009, STR0010,"        "} //"1 - SIM "###"2 - NAO*"
cChoice	:= Iif(!Empty(M->QKJ_APRPLN),Iif(M->QKJ_APRPLN == "1",aItems[1],aItems[2]),aItems[3])

@ oSize:aPosObj[1,1],003 SAY OemToAnsi(STR0011) SIZE 040,010 COLOR CLR_HBLUE OF oPanel1 PIXEL //"No. Peca"
@ oSize:aPosObj[1,1],035 MSGET oPECA VAR M->QKJ_PECA ReadOnly F3 "QPP" SIZE 130,005 OF oPanel1 PIXEL

@ oSize:aPosObj[1,1],176 SAY OemToAnsi(STR0012) SIZE 040,010 COLOR CLR_HBLUE OF oPanel1 PIXEL //"Revisao"
@ oSize:aPosObj[1,1],202 MSGET oREV VAR M->QKJ_REV SIZE 003,005 OF oPanel1 PIXEL WHEN .F. 

PPA230Vld(nOpc,@cDescricao,@cCliente)

@ oSize:aPosObj[1,1],226 SAY OemToAnsi(STR0013) SIZE 016,010 OF oPanel1 PIXEL //"Data"
@ oSize:aPosObj[1,1],246 MSGET oDATA VAR M->QKJ_DATA SIZE 033,005 OF oPanel1 PIXEL

@ oSize:aPosObj[1,1]+13,003 SAY OemToAnsi(STR0014) SIZE 040,010 OF oPanel1 PIXEL //"Descricao"
@ oSize:aPosObj[1,1]+13,035 MSGET oDescricao VAR cDescricao SIZE 245,005 OF oPanel1 PIXEL WHEN .F.

@ oSize:aPosObj[1,1]+27,003 SAY OemToAnsi(STR0015) SIZE 040,010 OF oPanel1 PIXEL //"Cliente"
@ oSize:aPosObj[1,1]+27,035 MSGET oCliente VAR cCliente SIZE 130,005 OF oPanel1 PIXEL WHEN .F.

@ oSize:aPosObj[1,1]+27,165 SAY OemToAnsi(STR0050) SIZE 040,010 OF oPanel1 PIXEL //"Plano Manuf."
@ oSize:aPosObj[1,1]+27,200 MSGET oPlManuf VAR M->QKJ_PMANUF SIZE 80,005 OF oPanel1 PIXEL

@ 055,003 MSPANEL oPanel PROMPT "" COLOR CLR_WHITE,CLR_BLACK SIZE 327,010 OF oPanel2
@ 003,080 SAY OemToAnsi(STR0016) COLOR CLR_WHITE SIZE 200,010 OF oPanel PIXEL //"APROVACAO DO PLANEJAMENTO DA QUALIDADE DO PRODUTO"
						
QPP230TELA(nOpc,oPanel2)
                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP230TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, ,aButtons ) CENTERED

If lOk
	PPA230Grav(nOpc)
Endif

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA230Excl  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³14.09.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Exclusao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA230Excl(ExpC1,ExpN1,ExpN2)                           ³±±
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

Function PPA230Excl(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local oPanel		:= NIL
Local aButtons		:= {}
Local oPECA
Local oREV
Local oDATA
Local oCliente, cCliente
Local oDescricao, cDescricao
Local oPlManuf
Local oPanel1
Local oPanel2
Local oSize

Private aItems, cChoice
Private oGet := NIL
				
aButtons := { 	{"RELATORIO", 	{ || QPP230PLAN(nOpc) },	OemToAnsi(STR0007), OemToAnsi(STR0048) },; //"Plano de Acao"###"Pln Acao"
				{"BMPVISUAL",	{ || QPPR230() },			OemToAnsi(STR0008), OemToAnsi(STR0049) }} 	//"Visualizar/Imprimir"###"Vis/Prn"

DbSelectArea(cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New( .F. )

oSize:AddObject( "CIMA"  ,  100,  40, .T., .F., .T. ) // Nao dimensiona Y 
oSize:AddObject( "BAIXO",  100, 100, .T., .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) ;  //"Sumario e APQP"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
						
SetDlg(oDlg)
RegToMemory("QKJ")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona Panel                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel1:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[1,3])
oPanel2:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[2,3])

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

aItems 	:= {STR0009, STR0010,"        "} //"1 - SIM "###"2 - NAO*"
cChoice	:= Iif(!Empty(M->QKJ_APRPLN),Iif(M->QKJ_APRPLN == "1",aItems[1],aItems[2]),aItems[3])

@ oSize:aPosObj[1,1],003 SAY OemToAnsi(STR0011) SIZE 040,010 COLOR CLR_HBLUE OF oPanel1 PIXEL //"No. Peca"
@ oSize:aPosObj[1,1],035 MSGET oPECA VAR M->QKJ_PECA ReadOnly F3 "QPP" SIZE 130,005 OF oPanel1 PIXEL WHEN .F.

@ oSize:aPosObj[1,1],176 SAY OemToAnsi(STR0012) SIZE 040,010 COLOR CLR_HBLUE OF oPanel1 PIXEL //"Revisao"
@ oSize:aPosObj[1,1],202 MSGET oREV VAR M->QKJ_REV SIZE 003,005 OF oPanel1 PIXEL WHEN .F. 

PPA230Vld(nOpc,@cDescricao,@cCliente)

@ oSize:aPosObj[1,1],226 SAY OemToAnsi(STR0013) SIZE 016,010 OF oPanel1 PIXEL //"Data"
@ oSize:aPosObj[1,1],246 MSGET oDATA VAR M->QKJ_DATA SIZE 033,005 OF oPanel1 PIXEL WHEN .F.

@ oSize:aPosObj[1,1]+13,003 SAY OemToAnsi(STR0014) SIZE 040,010 OF oPanel1 PIXEL //"Descricao"
@ oSize:aPosObj[1,1]+13,035 MSGET oDescricao VAR cDescricao SIZE 245,005 OF oPanel1 PIXEL WHEN .F.

@ oSize:aPosObj[1,1]+27,003 SAY OemToAnsi(STR0015) SIZE 040,010 OF oPanel1 PIXEL //"Cliente"
@ oSize:aPosObj[1,1]+27,035 MSGET oCliente VAR cCliente SIZE 130,005 OF oPanel1 PIXEL WHEN .F.

@ oSize:aPosObj[1,1]+27,165 SAY OemToAnsi(STR0050) SIZE 040,010 OF oPanel1 PIXEL //"Plano Manuf."
@ oSize:aPosObj[1,1]+27,200 MSGET oPlManuf VAR M->QKJ_PMANUF SIZE 80,005 OF oPanel1 PIXEL WHEN .F.

@ 055,003 MSPANEL oPanel PROMPT "" COLOR CLR_WHITE,CLR_BLACK SIZE 327,010 OF oPanel2
@ 003,080 SAY OemToAnsi(STR0016) COLOR CLR_WHITE SIZE 200,010 OF oPanel PIXEL //"APROVACAO DO PLANEJAMENTO DA QUALIDADE DO PRODUTO"
						
QPP230TELA(nOpc,oDlg)
                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| A230Dele(),oDlg:End()},{||oDlg:End()}, , aButtons) CENTERED

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP230TELA³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 14.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para informacoes do ScrollBox                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP230TELA(ExpN1, ExpO1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±³          ³ ExpO1 = Dialog       									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA230                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP230TELA(nOpc,oDlg)

Local oScrollBox 	:= NIL
Local oGroup1, oGroup2, oGroup3, oGroup4, oGroup5, oGroup6, oGroup7
Local oQTREQ, oQTACE, oQTPEN
Local oDTAPPL
Local oQTDIAM, oQTDICA, oQTDIAC, oQTDIPE
Local oQTVIAM, oQTVICA, oQTVIAC, oQTVIPE
Local oQTLAAM, oQTLACA, oQTLAAC, oQTLAPE
Local oQTDEAM, oQTDECA, oQTDEAC, oQTDEPE
Local oQTMERE, oQTMEAC, oQTMEPE
Local oQTMORE, oQTMOAC, oQTMOPE
Local oQTFORE, oQTFOAC, oQTFOPE
Local oQTIVRE, oQTIVAC, oQTIVPE
Local oQTTERE, oQTTEAC, oQTTEPE
Local oMEMB1, oMEMB2, oMEMB3, oMEMB4, oMEMB5, oMEMB6
Local oDTME1, oDTME2, oDTME3, oDTME4, oDTME5, oDTME6
Local oComboBox

DEFINE FONT oFont NAME "Arial" SIZE 5,15

oScrollBox := TScrollBox():New(oDlg,,,,,.T.,.T.,.T.)
oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT 

@ 002,002 GROUP oGroup1 TO 040,317 LABEL OemToAnsi(STR0017) COLOR CLR_RED OF oScrollBox PIXEL //"1 - ESTUDO PRELIMINAR DA CAPABILIDADE DO PROCESSO"

@ 008,220 SAY OemToAnsi(STR0018) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"QUANTIDADE"


@ 017,170 SAY OemToAnsi(STR0019) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"REQUERIDA"

@ 017,220 SAY OemToAnsi(STR0020) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"ACEITAVEL"
                                                                  
@ 017,270 SAY OemToAnsi(STR0021) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"PENDENTE*"
														

@ 025,005 SAY OemToAnsi(STR0022) SIZE 128,010 OF oScrollBox PIXEL; //"Ppk - Caracteristicas Especiais"
														FONT oFont

@ 025,170 MSGET oQTREQ VAR M->QKJ_QTREQ VALID CheckSX3("QKJ_QTREQ",M->QKJ_QTREQ) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 025,220 MSGET oQTACE VAR M->QKJ_QTACE VALID CheckSX3("QKJ_QTACE",M->QKJ_QTACE) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 025,270 MSGET oQTPEN VAR M->QKJ_QTPEN VALID CheckSX3("QKJ_QTPEN",M->QKJ_QTPEN) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont


@ 050,002 GROUP oGroup2 TO 075,317 LABEL OemToAnsi(STR0023) COLOR CLR_RED OF oScrollBox PIXEL //"2 - APROVACAO DO PLANO DE CONTROLE SE REQUERIDO"


@ 060,005 SAY OemToAnsi(STR0024) SIZE 032,010 OF oScrollBox PIXEL; //"Aprovado"
														FONT oFont
														
@ 060,040 COMBOBOX oComboBox VAR cChoice ITEMS aItems SIZE 035,005 OF oScrollBox PIXEL FONT oFont

@ 060,085 SAY OemToAnsi(STR0025) SIZE 072,010 OF oScrollBox PIXEL; //"Data da Aprovacao"
														FONT oFont

@ 060,160 MSGET oDTAPPL VAR M->QKJ_DTAPPL VALID CheckSX3("QKJ_DTAPPL",M->QKJ_DTAPPL) ;
											SIZE 48,005 OF oScrollBox PIXEL FONT oFont


@ 085,002 GROUP oGroup3 TO 160,317 LABEL OemToAnsi(STR0026) COLOR CLR_RED OF oScrollBox PIXEL //"3 - CATEGORIA DAS CARAC. DA AMOSTRA INICIAL DA PRODUCAO"

@ 095,190 SAY OemToAnsi(STR0018) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"QUANTIDADE"


@ 105,120 SAY OemToAnsi(STR0027) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"AMOSTRAS"

@ 105,170 SAY OemToAnsi(STR0028) SIZE 048,010 OF oScrollBox PIXEL FONT oFont //"CARAC/AMOST"

@ 105,220 SAY OemToAnsi(STR0020) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"ACEITAVEL"
                                                                  
@ 105,270 SAY OemToAnsi(STR0021) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"PENDENTE*"


@ 115,005 SAY OemToAnsi(STR0029) SIZE 128,010 OF oScrollBox PIXEL FONT oFont //"Dimensional"

@ 115,120 MSGET oQTDIAM VAR M->QKJ_QTDIAM VALID CheckSX3("QKJ_QTDIAM",M->QKJ_QTDIAM) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 115,170 MSGET oQTDICA VAR M->QKJ_QTDICA VALID CheckSX3("QKJ_QTDICA",M->QKJ_QTDICA) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 115,220 MSGET oQTDIAC VAR M->QKJ_QTDIAC VALID CheckSX3("QKJ_QTDIAC",M->QKJ_QTDIAC) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 115,270 MSGET oQTDIPE VAR M->QKJ_QTDIPE VALID CheckSX3("QKJ_QTDIPE",M->QKJ_QTDIPE) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 125,005 SAY OemToAnsi(STR0030) SIZE 024,010 OF oScrollBox PIXEL FONT oFont //"Visual"

@ 125,120 MSGET oQTVIAM VAR M->QKJ_QTVIAM VALID CheckSX3("QKJ_QTVIAM",M->QKJ_QTVIAM) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 125,170 MSGET oQTVICA VAR M->QKJ_QTVICA VALID CheckSX3("QKJ_QTVICA",M->QKJ_QTVICA) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 125,220 MSGET oQTVIAC VAR M->QKJ_QTVIAC VALID CheckSX3("QKJ_QTVIAC",M->QKJ_QTVIAC) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 125,270 MSGET oQTVIPE VAR M->QKJ_QTVIPE VALID CheckSX3("QKJ_QTVIPE",M->QKJ_QTVIPE) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont


@ 135,005 SAY OemToAnsi(STR0031) SIZE 044,010 OF oScrollBox PIXEL FONT oFont //"Laboratorio"

@ 135,120 MSGET oQTLAAM VAR M->QKJ_QTLAAM VALID CheckSX3("QKJ_QTLAAM",M->QKJ_QTLAAM) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 135,170 MSGET oQTLACA VAR M->QKJ_QTLACA VALID CheckSX3("QKJ_QTLACA",M->QKJ_QTLACA) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 135,220 MSGET oQTLAAC VAR M->QKJ_QTLAAC VALID CheckSX3("QKJ_QTLAAC",M->QKJ_QTLAAC) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 135,270 MSGET oQTLAPE VAR M->QKJ_QTLAPE VALID CheckSX3("QKJ_QTLAPE",M->QKJ_QTLAPE) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont


@ 145,005 SAY OemToAnsi(STR0032) SIZE 044,010 OF oScrollBox PIXEL FONT oFont //"Desempenho"

@ 145,120 MSGET oQTDEAM VAR M->QKJ_QTDEAM VALID CheckSX3("QKJ_QTDEAM",M->QKJ_QTDEAM) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 145,170 MSGET oQTDECA VAR M->QKJ_QTDECA VALID CheckSX3("QKJ_QTDECA",M->QKJ_QTDECA) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 145,220 MSGET oQTDEAC VAR M->QKJ_QTDEAC VALID CheckSX3("QKJ_QTDEAC",M->QKJ_QTDEAC) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 145,270 MSGET oQTDEPE VAR M->QKJ_QTDEPE VALID CheckSX3("QKJ_QTDEPE",M->QKJ_QTDEPE) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont


@ 170,002 GROUP oGroup4 TO 215,317 LABEL OemToAnsi(STR0033) COLOR CLR_RED OF oScrollBox PIXEL //"4 - ANALISE DO SISTEMA DE MEDICAO DE DISPOSITIVO E INSTRUMENTOS"


@ 180,220 SAY OemToAnsi(STR0018) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"QUANTIDADE"


@ 190,170 SAY OemToAnsi(STR0019) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"REQUERIDA"

@ 190,220 SAY OemToAnsi(STR0020) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"ACEITAVEL"
                                                                  
@ 190,270 SAY OemToAnsi(STR0021) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"PENDENTE*"
														

@ 200,005 SAY OemToAnsi(STR0034) SIZE 128,010 OF oScrollBox PIXEL; //"Caracteristica Especial"
														FONT oFont

@ 200,170 MSGET oQTMERE VAR M->QKJ_QTMERE VALID CheckSX3("QKJ_QTMERE",M->QKJ_QTMERE) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 200,220 MSGET oQTMEAC VAR M->QKJ_QTMEAC VALID CheckSX3("QKJ_QTMEAC",M->QKJ_QTMEAC) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 200,270 MSGET oQTMEPE VAR M->QKJ_QTMEPE VALID CheckSX3("QKJ_QTMEPE",M->QKJ_QTMEPE) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont



@ 225,002 GROUP oGroup5 TO 290,317 LABEL OemToAnsi(STR0035) COLOR CLR_RED OF oScrollBox PIXEL //"5 - MONITORAMENTO DO PROCESSO"


@ 235,220 SAY OemToAnsi(STR0018) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"QUANTIDADE"


@ 245,170 SAY OemToAnsi(STR0019) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"REQUERIDA"

@ 245,220 SAY OemToAnsi(STR0020) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"ACEITAVEL"
                                                                  
@ 245,270 SAY OemToAnsi(STR0021) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"PENDENTE*"
														

@ 255,005 SAY OemToAnsi(STR0036) SIZE 128,010 OF oScrollBox PIXEL; //"Instrucoes de Monitoramento"
														FONT oFont

@ 255,170 MSGET oQTMORE VAR M->QKJ_QTMORE VALID CheckSX3("QKJ_QTMORE",M->QKJ_QTMORE) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 255,220 MSGET oQTMOAC VAR M->QKJ_QTMOAC VALID CheckSX3("QKJ_QTMOAC",M->QKJ_QTMOAC) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 255,270 MSGET oQTMOPE VAR M->QKJ_QTMOPE VALID CheckSX3("QKJ_QTMOPE",M->QKJ_QTMOPE) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont


@ 265,005 SAY OemToAnsi(STR0037) SIZE 128,010 OF oScrollBox PIXEL; //"Folhas de Processo"
														FONT oFont

@ 265,170 MSGET oQTFORE VAR M->QKJ_QTFORE VALID CheckSX3("QKJ_QTFORE",M->QKJ_QTFORE) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 265,220 MSGET oQTFOAC VAR M->QKJ_QTFOAC VALID CheckSX3("QKJ_QTFOAC",M->QKJ_QTFOAC) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 265,270 MSGET oQTFOPE VAR M->QKJ_QTFOPE VALID CheckSX3("QKJ_QTFOPE",M->QKJ_QTFOPE) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 275,005 SAY OemToAnsi(STR0038) SIZE 128,010 OF oScrollBox PIXEL; //"Instrucoes Visuais"
														FONT oFont

@ 275,170 MSGET oQTIVRE VAR M->QKJ_QTIVRE VALID CheckSX3("QKJ_QTIVRE",M->QKJ_QTIVRE) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 275,220 MSGET oQTIVAC VAR M->QKJ_QTIVAC VALID CheckSX3("QKJ_QTIVAC",M->QKJ_QTIVAC) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 275,270 MSGET oQTIVPE VAR M->QKJ_QTIVPE VALID CheckSX3("QKJ_QTIVPE",M->QKJ_QTIVPE) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont


@ 300,002 GROUP oGroup6 TO 355,317 LABEL OemToAnsi(STR0039) COLOR CLR_RED OF oScrollBox PIXEL //"6 - EMBALAGEM / EXPEDICAO"


@ 310,220 SAY OemToAnsi(STR0018) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"QUANTIDADE"


@ 320,170 SAY OemToAnsi(STR0019) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"REQUERIDA"

@ 320,220 SAY OemToAnsi(STR0020) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"ACEITAVEL"
                                                                  
@ 320,270 SAY OemToAnsi(STR0021) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"PENDENTE*"
														

@ 330,005 SAY OemToAnsi(STR0040) SIZE 128,010 OF oScrollBox PIXEL; //"Aprovacao da Embalagem"
														FONT oFont

@ 330,170 MSGET oQTEMRE VAR M->QKJ_QTEMRE VALID CheckSX3("QKJ_QTEMRE",M->QKJ_QTEMRE) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 330,220 MSGET oQTEMAC VAR M->QKJ_QTEMAC VALID CheckSX3("QKJ_QTEMAC",M->QKJ_QTEMAC) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 330,270 MSGET oQTEMPE VAR M->QKJ_QTEMPE VALID CheckSX3("QKJ_QTEMPE",M->QKJ_QTEMPE) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont


@ 340,005 SAY OemToAnsi(STR0041) SIZE 128,010 OF oScrollBox PIXEL; //"Teste de Entrega"
														FONT oFont

@ 340,170 MSGET oQTTERE VAR M->QKJ_QTTERE VALID CheckSX3("QKJ_QTTERE",M->QKJ_QTTERE) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 340,220 MSGET oQTTEAC VAR M->QKJ_QTTEAC VALID CheckSX3("QKJ_QTTEAC",M->QKJ_QTTEAC) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont

@ 340,270 MSGET oQTTEPE VAR M->QKJ_QTTEPE VALID CheckSX3("QKJ_QTTEPE",M->QKJ_QTTEPE) ;
											SIZE 40,005 OF oScrollBox PIXEL FONT oFont


@ 365,002 GROUP oGroup7 TO 440,317 LABEL OemToAnsi(STR0042) COLOR CLR_RED OF oScrollBox PIXEL //"7 - APROVACAO"


@ 375,005 SAY OemToAnsi(STR0043) SIZE 088,010 OF oScrollBox PIXEL; //"Membro da Equipe/Cargo"
														FONT oFont

@ 375,090 MSGET oMEMB1 VAR M->QKJ_MEMB1 VALID CheckSX3("QKJ_MEMB1",M->QKJ_MEMB1) ;
			PICTURE "@!S30" SIZE 120,005 OF oScrollBox PIXEL FONT oFont

@ 375,220 SAY OemToAnsi(STR0013) SIZE 016,010 OF oScrollBox PIXEL; //"Data"
														FONT oFont

@ 375,250 MSGET oDTME1 VAR M->QKJ_DTME1 VALID CheckSX3("QKJ_DTME1",M->QKJ_DTME1) ;
											SIZE 48,005 OF oScrollBox PIXEL FONT oFont

@ 385,005 SAY OemToAnsi(STR0043) SIZE 088,010 OF oScrollBox PIXEL; //"Membro da Equipe/Cargo"
														FONT oFont

@ 385,090 MSGET oMEMB2 VAR M->QKJ_MEMB2 VALID CheckSX3("QKJ_MEMB2",M->QKJ_MEMB2) ;
			PICTURE "@!S30" SIZE 120,005 OF oScrollBox PIXEL FONT oFont

@ 385,220 SAY OemToAnsi(STR0013) SIZE 016,010 OF oScrollBox PIXEL; //"Data"
														FONT oFont

@ 385,250 MSGET oDTME2 VAR M->QKJ_DTME2 VALID CheckSX3("QKJ_DTME2",M->QKJ_DTME2) ;
											SIZE 48,005 OF oScrollBox PIXEL FONT oFont


@ 395,005 SAY OemToAnsi(STR0043) SIZE 088,010 OF oScrollBox PIXEL; //"Membro da Equipe/Cargo"
														FONT oFont

@ 395,090 MSGET oMEMB3 VAR M->QKJ_MEMB3 VALID CheckSX3("QKJ_MEMB3",M->QKJ_MEMB3) ;
			PICTURE "@!S30" SIZE 120,005 OF oScrollBox PIXEL FONT oFont

@ 395,220 SAY OemToAnsi(STR0013) SIZE 016,010 OF oScrollBox PIXEL; //"Data"
														FONT oFont

@ 395,250 MSGET oDTME3 VAR M->QKJ_DTME3 VALID CheckSX3("QKJ_DTME3",M->QKJ_DTME3) ;
											SIZE 48,005 OF oScrollBox PIXEL FONT oFont


@ 405,005 SAY OemToAnsi(STR0043) SIZE 088,010 OF oScrollBox PIXEL; //"Membro da Equipe/Cargo"
														FONT oFont

@ 405,090 MSGET oMEMB4 VAR M->QKJ_MEMB4 VALID CheckSX3("QKJ_MEMB4",M->QKJ_MEMB4) ;
			PICTURE "@!S30" SIZE 120,005 OF oScrollBox PIXEL FONT oFont

@ 405,220 SAY OemToAnsi(STR0013) SIZE 016,010 OF oScrollBox PIXEL; //"Data"
														FONT oFont

@ 405,250 MSGET oDTME4 VAR M->QKJ_DTME4 VALID CheckSX3("QKJ_DTME4",M->QKJ_DTME4) ;
											SIZE 48,005 OF oScrollBox PIXEL FONT oFont

@ 415,005 SAY OemToAnsi(STR0043) SIZE 088,010 OF oScrollBox PIXEL; //"Membro da Equipe/Cargo"
														FONT oFont

@ 415,090 MSGET oMEMB5 VAR M->QKJ_MEMB5 VALID CheckSX3("QKJ_MEMB5",M->QKJ_MEMB5) ;
			PICTURE "@!S30" SIZE 120,005 OF oScrollBox PIXEL FONT oFont

@ 415,220 SAY OemToAnsi(STR0013) SIZE 016,010 OF oScrollBox PIXEL; //"Data"
														FONT oFont

@ 415,250 MSGET oDTME5 VAR M->QKJ_DTME5 VALID CheckSX3("QKJ_DTME5",M->QKJ_DTME5) ;
											SIZE 48,005 OF oScrollBox PIXEL FONT oFont

@ 425,005 SAY OemToAnsi(STR0043) SIZE 088,010 OF oScrollBox PIXEL; //"Membro da Equipe/Cargo"
														FONT oFont

@ 425,090 MSGET oMEMB6 VAR M->QKJ_MEMB6 VALID CheckSX3("QKJ_MEMB6",M->QKJ_MEMB6) ;
			PICTURE "@!S30" SIZE 120,005 OF oScrollBox PIXEL FONT oFont

@ 425,220 SAY OemToAnsi(STR0013) SIZE 016,010 OF oScrollBox PIXEL; //"Data"
														FONT oFont

@ 425,250 MSGET oDTME6 VAR M->QKJ_DTME6 VALID CheckSX3("QKJ_DTME6",M->QKJ_DTME6) ;
											SIZE 48,005 OF oScrollBox PIXEL FONT oFont

@ 450,005 SAY OemToAnsi(STR0046) SIZE 212,010 OF oScrollBox PIXEL; //"*Requer um plano de acao para acompanhar o progresso"
														FONT oFont
If nOpc <> 3 .and. nOpc <> 4
	oQTREQ:lReadOnly 	:= .T.
	oQTACE:lReadOnly 	:= .T.
	oQTPEN:lReadOnly 	:= .T.
	oDTAPPL:lReadOnly 	:= .T.
	oQTDIAM:lReadOnly 	:= .T.
	oQTDICA:lReadOnly 	:= .T.
	oQTDIAC:lReadOnly 	:= .T.
	oQTDIPE:lReadOnly 	:= .T.
	oQTVIAM:lReadOnly 	:= .T.
	oQTVICA:lReadOnly 	:= .T.
	oQTVIAC:lReadOnly 	:= .T.
	oQTVIPE:lReadOnly 	:= .T.
	oQTLAAM:lReadOnly 	:= .T.
	oQTLACA:lReadOnly 	:= .T.
	oQTLAAC:lReadOnly 	:= .T.
	oQTLAPE:lReadOnly 	:= .T.
	oQTDEAM:lReadOnly 	:= .T.
	oQTDECA:lReadOnly 	:= .T.
	oQTDEAC:lReadOnly 	:= .T.
	oQTDEPE:lReadOnly 	:= .T.
	oQTMERE:lReadOnly 	:= .T.
	oQTMEAC:lReadOnly 	:= .T.
	oQTMEPE:lReadOnly 	:= .T.
	oQTMORE:lReadOnly 	:= .T.
	oQTMOAC:lReadOnly 	:= .T.
	oQTMOPE:lReadOnly 	:= .T.
	oQTFORE:lReadOnly 	:= .T.
	oQTFOAC:lReadOnly 	:= .T.
	oQTFOPE:lReadOnly 	:= .T.
	oQTIVRE:lReadOnly 	:= .T.
	oQTIVAC:lReadOnly 	:= .T.
	oQTIVPE:lReadOnly 	:= .T.
	oQTTERE:lReadOnly 	:= .T.
	oQTTEAC:lReadOnly 	:= .T.
	oQTTEPE:lReadOnly 	:= .T.
	oMEMB1:lReadOnly 	:= .T.
	oMEMB2:lReadOnly 	:= .T.
	oMEMB3:lReadOnly 	:= .T.
	oMEMB4:lReadOnly 	:= .T.
	oMEMB5:lReadOnly 	:= .T.
	oMEMB6:lReadOnly 	:= .T.
	oDTME1:lReadOnly 	:= .T.
	oDTME2:lReadOnly 	:= .T.
	oDTME3:lReadOnly 	:= .T.
	oDTME4:lReadOnly 	:= .T.
	oDTME5:lReadOnly 	:= .T.
	oDTME6:lReadOnly 	:= .T.
	oComboBox:lReadOnly := .T.
Endif

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA230Grav³ Autor ³ Robson Ramiro A Olivei³ Data ³ 14/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Gravacao - Incl./Alter.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA230Grav(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA230                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA230Grav(nOpc)

Local nCont
Local bCampo		:= { |nCPO| Field(nCPO) }
Local lGraOk		:= .T.
Local cAtividade	:= "13 " // Definido no ID - QKZ

DbSelectArea("QKJ")
	
Begin Transaction

If ALTERA
	RecLock("QKJ",.F.)
Else	                   
	RecLock("QKJ",.T.)
Endif

For nCont := 1 To FCount()
	If "FILIAL"$Field(nCont)
		FieldPut(nCont,xFilial("QKJ"))
	Else
		FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
	Endif
Next nCont

QKJ->QKJ_REVINV := Inverte(M->QKJ_REV)
QKJ->QKJ_APRPLN := Iif(Empty(cChoice)," ",Iif(cChoice == STR0009,"1", "2")) //"1 - SIM"

MsUnLock()
	
End Transaction

If !Empty(QKJ->QKJ_MEMB1) .and. !Empty(QKJ->QKJ_DTME1)
	QPP_CRONO(QKJ->QKJ_PECA,QKJ->QKJ_REV,cAtividade) // QPPXFUN - Atualiza Cronograma
Endif
				
Return lGraOk

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PP230TudOk ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 16.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para inclusao/alteracao geral                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP230TudOk                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QPPA230                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PP230TudOk

Local lRetorno	:= .T.

If Empty(M->QKJ_PECA) .or. Empty(M->QKJ_REV)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
Endif

Return lRetorno


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A230Dele ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 14/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fucao para exclusao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A230Dele()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA230                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A230Dele()

Local cEspecie := "QPPA230 "

DbSelectArea("QKJ")

Begin Transaction

If !Empty(QKJ->QKJ_CHAVE)
	QO_DelTxt(QKJ->QKJ_CHAVE,cEspecie)    //QPPXFUN
EndIf		 

RecLock("QKJ",.F.)
DbDelete()
MsUnLock()

DbSelectArea("QKJ")
		
End Transaction

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PPA230VLD³ Autor ³ Robson Ramiro A Olivei³ Data ³ 14/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para validacao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA230VLD(ExpN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Numero da opcao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA230                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA230Vld(nOpc, cDescricao, cCliente)

Local lRetorno  := .T.

DbSelectArea("QKJ")
DbSetOrder(1)

If nOpc == 3
	If DbSeek(xFilial("QKJ") + M->QKJ_PECA + M->QKJ_REV) 
		lRetorno := .F.	
		Help("", 1, "Q140PCEXIS")	// "Numero de Revisao ja cadastrada para esta Peca "
	Endif
Else
	lRetorno := .T.
Endif

If lRetorno
	DbSelectArea("QK1") 
	DbSetOrder(1) 

	If DbSeek(xFilial("QK1") + M->QKJ_PECA + M->QKJ_REV)
		cDescricao := QK1->QK1_DESC
		DbSelectArea("SA1") 
		DbSetOrder(1)

		If DbSeek(xFilial("SA1") + QK1->QK1_CODCLI + QK1->QK1_LOJCLI)
			cCliente := SA1->A1_NOME
	 	Endif	
	Else
		lRetorno := .F.	
		Help("", 1, "Q140RVPCNC")	// "Revisao para esta Peca nao existe"
	EndIf
Endif

DbSelectArea("QKJ")

Return lRetorno


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP230PLAN³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 18.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastra plano de acoes                  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP230PLAN(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA230                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP230PLAN(nOpc)

Local cChave  	:= "", cCabec := ""
Local cTitulo   := OemToAnsi(STR0044) //"Plano de Acoes"
Local nTamLin 	:= 75
Local cEspecie  := "QPPA230 "   //Para gravacao de textos
Local lEdit		:= .F.
Local cInf		:= ""
Local nSaveSX8	:= GetSX8Len()

If nOpc == 3 .or. nOpc == 4
	lEdit := .T.
Endif

axTextos	:= {} 	//Vetor que contem os textos dos Produtos
cCabec      := OemToAnsi(STR0044) //"Plano de Acoes"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera/obtem a chave de ligacao com o texto da Peca/Rv     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Empty(M->QKJ_CHAVE)
	cChave := GetSXENum("QKJ", "QKJ_CHAVE",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

	M->QKJ_CHAVE 	:= cChave
Else
	cChave := M->QKJ_CHAVE
EndIf
                                              
cInf := AllTrim(M->QKJ_PECA) + STR0045 + M->QKJ_REV //"  Revisao  "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Digita o plano de acao                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If QO_TEXTO(cChave,cEspecie,nTamlin,cTitulo,cInf, @axtextos,1,cCabec,lEdit)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Texto do plano no QKO						         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QO_GrvTxt(cChave,cEspecie,1,@axTextos) 	//QPPXFUN
Endif

DbSelectArea("QKJ")
DbSetOrder(1)

Return .T.
