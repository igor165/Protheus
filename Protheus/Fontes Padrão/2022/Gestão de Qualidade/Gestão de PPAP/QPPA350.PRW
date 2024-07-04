#INCLUDE "QPPA350.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA350  ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 22.10.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ VDA - Folha de Capa                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA350(void)                                              ³±±
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

Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui"  , 0, 1,,.F.},; 	//"Pesquisar"
					{ OemToAnsi(STR0002), "PPA350Roti", 0, 2},;		 	//"Visualizar"
					{ OemToAnsi(STR0003), "PPA350Roti", 0, 3},;		 	//"Incluir"
					{ OemToAnsi(STR0004), "PPA350Roti", 0, 4},;		 	//"Alterar"
					{ OemToAnsi(STR0005), "PPA350Roti", 0, 5},;		 	//"Excluir"
					{ OemToAnsi(STR0006), "QPPR350(.T.)",0, 6,,.T.} }	//"Imprimir"

Return aRotina

Function QPPA350()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0007) //"VDA - Folha de Capa"

Private aRotina := MenuDef()

DbSelectArea("QL1")
DbSetOrder(1)

mBrowse( 6, 1, 22, 75,"QL1",,,,,,)

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA350Roti  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³22.10.03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Visualizacao                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA350Visu(ExpC1,ExpN1,ExpN2)                           ³±±
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

Function PPA350Roti(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local lOk 			:= .F.
Local aCposVis		:= {}
Local aButtons		:= {}
Local oPanel1
Local oPanel2
Local oSize
Local oEnch

Private lVDAAMO	:= .F.
Private lAMOINI	:= .F.
Private lAMOPOS	:= .F.
Private lPCNOVA	:= .F.
Private lALTPRO	:= .F.
Private lPOSPRO	:= .F.
Private lALPROC	:= .F.
Private lINTPRO	:= .F.
Private lSUBNOV	:= .F.
Private lPRODAE	:= .F.
Private lPLPROD	:= .F.
Private lFMEARE	:= .F.
Private lRELDEM	:= .F.

Private lTSTFUN	:= .F.
Private cTSTFUN	:= ""
Private lTSTMED	:= .F.
Private cTSTMED	:= ""
Private lTSTMAT	:= .F.
Private cTSTMAT	:= ""
Private lTSTRES	:= .F.
Private cTSTRES	:= ""
Private lCOMCAP	:= .F.
Private cCOMCAP	:= ""
Private lDIAGRA	:= .F.
Private cDIAGRA	:= ""
Private lCOMCPT	:= .F.
Private cCOMCPT	:= ""
Private lLISINS	:= .F.
Private cLISINS	:= ""
Private lFOLHEG	:= .F.
Private cFOLHEG	:= ""          
Private lTATO	:= .F.
Private cTATO	:= ""
Private lACUSTI	:= .F.
Private cACUSTI	:= ""
Private lCHEIRO	:= .F.
Private cCHEIRO	:= ""
Private lGERAL	:= .F.
Private cGERAL	:= ""
Private lCERTIF	:= .F.
Private cCERTIF	:= ""
Private lLIBCON	:= .F.
Private cLIBCON	:= ""
Private lMATCOM	:= .F.
Private cMATCOM	:= ""
Private lOUTROS	:= .F.
Private cOUTROS	:= ""

Private aItems := {STR0008, STR0009, STR0010, " "} //"1.Liberado"###"2.Liberado Com Restricoes"###"3.Reprovado"

If nOpc == 2 .or. nOpc == 5
	aButtons := {{"BMPVISUAL",	{ || QPPR350() }, OemToAnsi(STR0011), OemToAnsi(STR0055) }} //"Visualizar/Imprimir"###"Vis/Prn"
Endif

If nOpc == 3 .or. nOpc == 4
	aButtons := {{"EDIT", { || QPP350APRO() }, OemToAnsi(STR0012), OemToAnsi(STR0056) }} //"Aprovar/Limpar"###"Apr/Des"
Endif

aCposVis := { 	"QL1_PECA",		"QL1_REV", 		"QL1_NURELF",	"QL1_VERELF",; 
				"QL1_STATUF", 	"QL1_NPEDDT", 	"QL1_NDTNFI",	"QL1_QTDFOR",;
				"QL1_NUMCAR", 	"QL1_PESO",		"QL1_IDCLI",	"QL1_NURELC",;
				"QL1_VERELC", 	"QL1_STATUC",	"QL1_DENCLI",	"QL1_NDTENT",;
				"QL1_LOCALD",	"QL1_APROVA",	"QL1_DTAPRO",	"QL1_OBSFOR" }

If nOpc == 4
	If !QPPVldAlt(QL1->QL1_PECA,QL1->QL1_REV,QL1->QL1_APROVA)
		Return
	Endif
Endif

If nOpc == 5
	If !QPPVldExc(QL1->QL1_REV,QL1->QL1_APROVA)
		Return
	Endif
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
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0013);  //"VDA Folha de Capa"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
									
RegToMemory("QL1",(nOpc == 3))

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
oEnch:=MsMGet():New("QL1",nReg,nOpc, , , ,aCposVis,oSize:aPosObj[1],,,,,,oPanel1,,,,,,,,,)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

QPP350TELA(nOpc, oPanel2)
                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP350TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, ,aButtons ) CENTERED 

If lOk .and. (nOpc == 3 .or. nOpc == 4)
	PPA350Grav(nOpc)
Endif

If nOpc == 5 .and. lOk
	A350Dele()
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP350TELA³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 22.10.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para informacoes do ScrollBox                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP350TELA(ExpN1, ExpO1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±³          ³ ExpO1 = Dialog       									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP350TELA(nOpc,oDlg)

Local oScrollBox 	:= NIL
Local oPanel		:= NIL
Local oGroup1, oGroup2, oGroup3
Local oVDAAMO, oAMOINI, oAMOPOS, oPCNOVA, oALTPRO, oPOSPRO, oALPROC
Local oINTPRO, oSUBNOV, oPRODAE, oPLPROD, oFMEARE, oRELDEM
Local oTSTFUN, oTSTMED, oTSTMAT, oTSTRES, oCOMCAP, oDIAGRA, oCOMCPT, oLISINS
Local oFOLHEG, oTATO, oACUSTI, oCHEIRO, oGERAL, oCERTIF, oLIBCON, oMATCOM, oOUTROS

Local oCbTSTFUN, oCbTSTMED, oCbTSTMAT, oCbTSTRES, oCbCOMCAP, oCbDIAGRA, oCbCOMCPT, oCbLISINS
Local oCbFOLHEG, oCbTATO, oCbACUSTI, oCbCHEIRO, oCbGERAL, oCbCERTIF, oCbLIBCON, oCbMATCOM, oCbOUTROS
Local oNOMEC, oDEPTOC, oFONEC, oDTAPCL, oOBSCLI, oNLIDES, oRETNFI

DEFINE FONT oFont NAME "Arial" SIZE 7,15

If nOpc <> 3
	QPP350CHEC()
Endif

@ 058,003 MSPANEL oPanel PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE 390,012 OF oDlg
@ 004,150 SAY OemToAnsi(STR0014) COLOR CLR_WHITE SIZE 065,010 OF oPanel PIXEL //"SUBMISSAO E ANEXOS"

oScrollBox := TScrollBox():New(oDlg,70,03,130,390,.T.,.F.,.T.)
oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

@ 002,002 GROUP oGroup1 TO 055,378 LABEL OemToAnsi(STR0015) COLOR CLR_RED OF oScrollBox PIXEL //"SUBMISSAO"

@ 015,010 CHECKBOX oVDAAMO VAR lVDAAMO SIZE 008,008 OF oScrollBox PIXEL
@ 015,020 SAY OemToAnsi(STR0016) SIZE 080,010 OF oScrollBox PIXEL  //"Rel. VDA Amostra Inicial"

@ 015,100 CHECKBOX oAMOINI VAR lAMOINI SIZE 008,008 OF oScrollBox PIXEL
@ 015,110 SAY OemToAnsi(STR0017) SIZE 080,010 OF oScrollBox PIXEL  //"Amostra Inicial"

@ 015,200 CHECKBOX oAMOPOS VAR lAMOPOS SIZE 008,008 OF oScrollBox PIXEL
@ 015,210 SAY OemToAnsi(STR0018) SIZE 080,010 OF oScrollBox PIXEL  //"Amostra Posterior"

@ 015,300 CHECKBOX oPCNOVA VAR lPCNOVA SIZE 008,008 OF oScrollBox PIXEL
@ 015,310 SAY OemToAnsi(STR0019) SIZE 080,010 OF oScrollBox PIXEL  //"Peca Nova"

@ 025,010 CHECKBOX oALTPRO VAR lALTPRO SIZE 008,008 OF oScrollBox PIXEL
@ 025,020 SAY OemToAnsi(STR0020) SIZE 080,010 OF oScrollBox PIXEL  //"Alteracao de Produto"

@ 025,100 CHECKBOX oPOSPRO VAR lPOSPRO SIZE 008,008 OF oScrollBox PIXEL
@ 025,110 SAY OemToAnsi(STR0021) SIZE 080,010 OF oScrollBox PIXEL  //"Postergacao da Producao"

@ 025,200 CHECKBOX oALPROC VAR lALPROC SIZE 008,008 OF oScrollBox PIXEL
@ 025,210 SAY OemToAnsi(STR0022) SIZE 080,010 OF oScrollBox PIXEL  //"Alt. Processo producao"

@ 025,300 CHECKBOX oINTPRO VAR lINTPRO SIZE 008,008 OF oScrollBox PIXEL
@ 025,310 SAY OemToAnsi(STR0023) SIZE 080,010 OF oScrollBox PIXEL  //"Int. Maior de Producao"

@ 035,010 CHECKBOX oSUBNOV VAR lSUBNOV SIZE 008,008 OF oScrollBox PIXEL
@ 035,020 SAY OemToAnsi(STR0024) SIZE 080,010 OF oScrollBox PIXEL  //"Subfornecedor Novo"

@ 035,100 CHECKBOX oPRODAE VAR lPRODAE SIZE 008,008 OF oScrollBox PIXEL
@ 035,110 SAY OemToAnsi(STR0025) SIZE 080,010 OF oScrollBox PIXEL  //"Produto com DAE"

@ 035,200 CHECKBOX oPLPROD VAR lPLPROD SIZE 008,008 OF oScrollBox PIXEL
@ 035,210 SAY OemToAnsi(STR0026) SIZE 080,010 OF oScrollBox PIXEL  //"Elab. Plano Prod./Inspecao"

@ 035,300 CHECKBOX oFMEARE VAR lFMEARE SIZE 008,008 OF oScrollBox PIXEL
@ 035,310 SAY OemToAnsi(STR0027) SIZE 080,010 OF oScrollBox PIXEL  //"FMEA Realizado"

@ 045,010 CHECKBOX oRELDEM VAR lRELDEM SIZE 008,008 OF oScrollBox PIXEL
@ 045,020 SAY OemToAnsi(STR0028) SIZE 080,010 OF oScrollBox PIXEL  //"Relatorio Demais Amostras"

@ 065,002 GROUP oGroup2 TO 210,378 LABEL OemToAnsi(STR0029) COLOR CLR_RED OF oScrollBox PIXEL //"ANEXOS"

@ 080,010 CHECKBOX oTSTFUN VAR lTSTFUN SIZE 008,008 OF oScrollBox PIXEL
@ 080,020 SAY OemToAnsi(STR0030) SIZE 080,010 OF oScrollBox PIXEL  //"Teste de Funcao"
@ 080,100 COMBOBOX oCbTSTFUN VAR cTSTFUN ITEMS aItems SIZE 085,010 OF oScrollBox PIXEL FONT oFont

@ 080,200 CHECKBOX oTSTMED VAR lTSTMED SIZE 008,008 OF oScrollBox PIXEL
@ 080,210 SAY OemToAnsi(STR0031) SIZE 080,010 OF oScrollBox PIXEL  //"Teste de Medicao"
@ 080,290 COMBOBOX oCbTSTMED VAR cTSTMED ITEMS aItems SIZE 085,010 OF oScrollBox PIXEL FONT oFont

@ 095,010 CHECKBOX oTSTMAT VAR lTSTMAT SIZE 008,008 OF oScrollBox PIXEL
@ 095,020 SAY OemToAnsi(STR0032) SIZE 080,010 OF oScrollBox PIXEL  //"Teste de Material"
@ 095,100 COMBOBOX oCbTSTMAT VAR cTSTMAT ITEMS aItems SIZE 085,010 OF oScrollBox PIXEL FONT oFont

@ 095,200 CHECKBOX oTSTRES VAR lTSTRES SIZE 008,008 OF oScrollBox PIXEL
@ 095,210 SAY OemToAnsi(STR0033) SIZE 080,010 OF oScrollBox PIXEL  //"Teste de Resistencia"
@ 095,290 COMBOBOX oCbTSTRES VAR cTSTRES ITEMS aItems SIZE 085,010 OF oScrollBox PIXEL FONT oFont

@ 110,010 CHECKBOX oCOMCAP VAR lCOMCAP SIZE 008,008 OF oScrollBox PIXEL
@ 110,020 SAY OemToAnsi(STR0034) SIZE 080,010 OF oScrollBox PIXEL  //"Comp. Capabilidade Processo"
@ 110,100 COMBOBOX oCbCOMCAP VAR cCOMCAP ITEMS aItems SIZE 085,010 OF oScrollBox PIXEL FONT oFont

@ 110,200 CHECKBOX oDIAGRA VAR lDIAGRA SIZE 008,008 OF oScrollBox PIXEL
@ 110,210 SAY OemToAnsi(STR0035) SIZE 080,010 OF oScrollBox PIXEL  //"Diag. Decurso Processo"
@ 110,290 COMBOBOX oCbDIAGRA VAR cDIAGRA ITEMS aItems SIZE 085,010 OF oScrollBox PIXEL FONT oFont

@ 125,010 CHECKBOX oCOMCPT VAR lCOMCPT SIZE 008,008 OF oScrollBox PIXEL
@ 125,020 SAY OemToAnsi(STR0036) SIZE 080,010 OF oScrollBox PIXEL  //"Comp. Capabilidade Instrumento"
@ 125,100 COMBOBOX oCbCOMCPT VAR cCOMCPT ITEMS aItems SIZE 085,010 OF oScrollBox PIXEL FONT oFont

@ 125,200 CHECKBOX oLISINS VAR lLISINS SIZE 008,008 OF oScrollBox PIXEL
@ 125,210 SAY OemToAnsi(STR0037) SIZE 080,010 OF oScrollBox PIXEL  //"Lista Instr. Testes"
@ 125,290 COMBOBOX oCbLISINS VAR cLISINS ITEMS aItems SIZE 085,010 OF oScrollBox PIXEL FONT oFont

@ 140,010 CHECKBOX oFOLHEG VAR lFOLHEG SIZE 008,008 OF oScrollBox PIXEL
@ 140,020 SAY OemToAnsi(STR0038) SIZE 080,010 OF oScrollBox PIXEL  //"Folha EG Seguranca de Dados"
@ 140,100 COMBOBOX oCbFOLHEG VAR cFOLHEG ITEMS aItems SIZE 085,010 OF oScrollBox PIXEL FONT oFont

@ 140,200 CHECKBOX oTATO VAR lTATO SIZE 008,008 OF oScrollBox PIXEL
@ 140,210 SAY OemToAnsi(STR0039) SIZE 080,010 OF oScrollBox PIXEL  //"Tato"
@ 140,290 COMBOBOX oCbTATO VAR cTATO ITEMS aItems SIZE 085,010 OF oScrollBox PIXEL FONT oFont

@ 155,010 CHECKBOX oACUSTI VAR lACUSTI SIZE 008,008 OF oScrollBox PIXEL
@ 155,020 SAY OemToAnsi(STR0040) SIZE 080,010 OF oScrollBox PIXEL  //"Acustica"
@ 155,100 COMBOBOX oCbACUSTI VAR cACUSTI ITEMS aItems SIZE 085,010 OF oScrollBox PIXEL FONT oFont

@ 155,200 CHECKBOX oCHEIRO VAR lCHEIRO SIZE 008,008 OF oScrollBox PIXEL
@ 155,210 SAY OemToAnsi(STR0041) SIZE 080,010 OF oScrollBox PIXEL  //"Cheiro"
@ 155,290 COMBOBOX oCbCHEIRO VAR cCHEIRO ITEMS aItems SIZE 085,010 OF oScrollBox PIXEL FONT oFont

@ 170,010 CHECKBOX oGERAL VAR lGERAL SIZE 008,008 OF oScrollBox PIXEL
@ 170,020 SAY OemToAnsi(STR0042) SIZE 080,010 OF oScrollBox PIXEL  //"Aspecto Geral"
@ 170,100 COMBOBOX oCbGERAL VAR cGERAL ITEMS aItems SIZE 085,010 OF oScrollBox PIXEL FONT oFont

@ 170,200 CHECKBOX oCERTIF VAR lCERTIF SIZE 008,008 OF oScrollBox PIXEL
@ 170,210 SAY OemToAnsi(STR0043) SIZE 080,010 OF oScrollBox PIXEL  //"Certificados"
@ 170,290 COMBOBOX oCbCERTIF VAR cCERTIF ITEMS aItems SIZE 085,010 OF oScrollBox PIXEL FONT oFont

@ 185,010 CHECKBOX oLIBCON VAR lLIBCON SIZE 008,008 OF oScrollBox PIXEL
@ 185,020 SAY OemToAnsi(STR0044) SIZE 080,010 OF oScrollBox PIXEL  //"Liberacao de Construcao"
@ 185,100 COMBOBOX oCbLIBCON VAR cLIBCON ITEMS aItems SIZE 085,010 OF oScrollBox PIXEL FONT oFont

@ 185,200 CHECKBOX oMATCOM VAR lMATCOM SIZE 008,008 OF oScrollBox PIXEL
@ 185,210 SAY OemToAnsi(STR0045) SIZE 080,010 OF oScrollBox PIXEL  //"Mat. Comp. Pc Adquirida"
@ 185,290 COMBOBOX oCbMATCOM VAR cMATCOM ITEMS aItems SIZE 085,010 OF oScrollBox PIXEL FONT oFont

@ 200,010 CHECKBOX oOUTROS VAR lOUTROS SIZE 008,008 OF oScrollBox PIXEL
@ 200,020 SAY OemToAnsi(STR0046) SIZE 080,010 OF oScrollBox PIXEL  //"Outros"
@ 200,100 COMBOBOX oCbOUTROS VAR cOUTROS ITEMS aItems SIZE 085,010 OF oScrollBox PIXEL FONT oFont

@ 220,002 GROUP oGroup3 TO 290,378 LABEL OemToAnsi(STR0047) COLOR CLR_RED OF oScrollBox PIXEL //"APROVACAO DO CLIENTE"

@ 230,010 SAY OemToAnsi(STR0048) SIZE 040,015 OF oScrollBox PIXEL FONT oFont //"Nome"

@ 230,060 MSGET oNOMEC VAR M->QL1_NOMEC PICTURE PesqPict("QL1", "QL1_NOMEC");
			SIZE 080,005 OF oScrollBox PIXEL FONT oFont

@ 230,160 SAY OemToAnsi(STR0049) SIZE 060,015 OF oScrollBox PIXEL FONT oFont //"Departamento"

@ 230,220 MSGET oDEPTOC VAR M->QL1_DEPTOC PICTURE PesqPict("QL1", "QL1_DEPTOC");
			SIZE 080,005 OF oScrollBox PIXEL FONT oFont


@ 245,010 SAY OemToAnsi(STR0050) SIZE 040,015 OF oScrollBox PIXEL FONT oFont //"Tel/Fax/Email"

@ 245,060 MSGET oFONEC VAR M->QL1_FONEC PICTURE PesqPict("QL1", "QL1_FONEC");
			SIZE 080,005 OF oScrollBox PIXEL FONT oFont

@ 245,160 SAY OemToAnsi(STR0051) SIZE 060,015 OF oScrollBox PIXEL FONT oFont //"Data"

@ 245,220 MSGET oDTAPCL VAR M->QL1_DTAPCL PICTURE PesqPict("QL1", "QL1_DTAPCL");
			SIZE 060,005 OF oScrollBox PIXEL FONT oFont

@ 260,010 SAY OemToAnsi(STR0052) SIZE 050,015 OF oScrollBox PIXEL FONT oFont //"Observacao"
@ 260,060 MSGET oOBSCLI VAR M->QL1_OBSCLI SIZE 315, 005 OF oScrollBox PIXEL

@ 275,010 SAY OemToAnsi(STR0053) SIZE 060,015 OF oScrollBox PIXEL FONT oFont //"No. Licenca Desvio"

@ 275,070 MSGET oNLIDES VAR M->QL1_NLIDES PICTURE PesqPict("QL1", "QL1_NLIDES");
			SIZE 060,005 OF oScrollBox PIXEL FONT oFont

@ 275,220 SAY OemToAnsi(STR0054) SIZE 080,015 OF oScrollBox PIXEL FONT oFont //"Se retorno, No./Data NF"

@ 275,300 MSGET oRETNFI VAR M->QL1_RETNFI PICTURE PesqPict("QL1", "QL1_RETNFI");
			SIZE 060,005 OF oScrollBox PIXEL FONT oFont

@ 295,000 SAY OemToAnsi("") SIZE 010,005 OF oScrollBox PIXEL FONT oFont

If nOpc == 2 .or. nOpc == 5
	oVDAAMO:lReadOnly 	:= .T.
	oAMOINI:lReadOnly 	:= .T.
	oAMOPOS:lReadOnly 	:= .T.
	oPCNOVA:lReadOnly 	:= .T.
	oALTPRO:lReadOnly 	:= .T.
	oPOSPRO:lReadOnly 	:= .T.
	oALPROC:lReadOnly 	:= .T.
	oINTPRO:lReadOnly 	:= .T.
	oSUBNOV:lReadOnly 	:= .T.
	oPRODAE:lReadOnly 	:= .T.
	oPLPROD:lReadOnly 	:= .T.
	oFMEARE:lReadOnly 	:= .T.
	oRELDEM:lReadOnly 	:= .T.
	oTSTFUN:lReadOnly 	:= .T.
	oTSTMED:lReadOnly 	:= .T.
	oTSTMAT:lReadOnly 	:= .T.
	oTSTRES:lReadOnly 	:= .T.
	oCOMCAP:lReadOnly 	:= .T.
	oDIAGRA:lReadOnly 	:= .T.
	oCOMCPT:lReadOnly 	:= .T.
	oLISINS:lReadOnly 	:= .T.
	oFOLHEG:lReadOnly 	:= .T.
	oTATO:lReadOnly 	:= .T.
	oACUSTI:lReadOnly 	:= .T.
	oCHEIRO:lReadOnly 	:= .T.
	oGERAL:lReadOnly 	:= .T.
	oCERTIF:lReadOnly 	:= .T.
	oLIBCON:lReadOnly 	:= .T.
	oMATCOM:lReadOnly 	:= .T.
	oOUTROS:lReadOnly 	:= .T.
	oCbTSTFUN:lReadOnly 	:= .T.
	oCbTSTMED:lReadOnly 	:= .T.
	oCbTSTMAT:lReadOnly 	:= .T.
	oCbTSTRES:lReadOnly 	:= .T.
	oCbCOMCAP:lReadOnly 	:= .T.
	oCbDIAGRA:lReadOnly 	:= .T.
	oCbCOMCPT:lReadOnly 	:= .T.
	oCbLISINS:lReadOnly 	:= .T.
	oCbFOLHEG:lReadOnly 	:= .T.
	oCbTATO:lReadOnly 		:= .T.
	oCbACUSTI:lReadOnly 	:= .T.
	oCbCHEIRO:lReadOnly 	:= .T.
	oCbGERAL:lReadOnly 		:= .T.
	oCbCERTIF:lReadOnly 	:= .T.
	oCbLIBCON:lReadOnly 	:= .T.
	oCbMATCOM:lReadOnly 	:= .T.
	oCbOUTROS:lReadOnly 	:= .T.
	oNOMEC:lReadOnly 		:= .T.
	oDEPTOC:lReadOnly 		:= .T.
	oFONEC:lReadOnly 		:= .T.
	oDTAPCL:lReadOnly 		:= .T.
	oOBSCLI:lReadOnly 		:= .T.
	oNLIDES:lReadOnly 		:= .T.
	oRETNFI:lReadOnly 		:= .T.
Endif

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA350Grav³ Autor ³ Robson Ramiro A Olivei³ Data ³ 22/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Gravacao - Incl./Alter.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA350Grav(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA350Grav(nOpc)

Local nCont
Local bCampo		:= { |nCPO| Field(nCPO) }
Local lGraOk		:= .T.

DbSelectArea("QL1")
	
Begin Transaction

If ALTERA
	RecLock("QL1",.F.)
Else	                   
	RecLock("QL1",.T.)
Endif

For nCont := 1 To FCount()
	If "FILIAL"$Field(nCont)
		FieldPut(nCont,xFilial("QL1"))
	Else
		FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
	Endif
Next nCont

QL1->QL1_REVINV	:= Inverte(M->QL1_REV)

QL1->QL1_VDAAMO := Iif(lVDAAMO, "1", "0")
QL1->QL1_AMOINI := Iif(lAMOINI, "1", "0")
QL1->QL1_AMOPOS := Iif(lAMOPOS, "1", "0")
QL1->QL1_PCNOVA := Iif(lPCNOVA, "1", "0")
QL1->QL1_ALTPRO := Iif(lALTPRO, "1", "0")
QL1->QL1_POSPRO := Iif(lPOSPRO, "1", "0")
QL1->QL1_ALPROC := Iif(lALPROC, "1", "0")
QL1->QL1_INTPRO := Iif(lINTPRO, "1", "0")
QL1->QL1_SUBNOV := Iif(lSUBNOV, "1", "0")
QL1->QL1_PRODAE := Iif(lPRODAE, "1", "0")
QL1->QL1_PLPROD := Iif(lPLPROD, "1", "0")
QL1->QL1_FMEARE := Iif(lFMEARE, "1", "0")
QL1->QL1_RELDEM := Iif(lRELDEM, "1", "0")

QL1->QL1_TSTFUN	:= Iif(lTSTFUN, "1", "0") + Left(cTSTFUN,1)
QL1->QL1_TSTMED	:= Iif(lTSTMED, "1", "0") + Left(cTSTMED,1)
QL1->QL1_TSTMAT	:= Iif(lTSTMAT, "1", "0") + Left(cTSTMAT,1)
QL1->QL1_TSTRES	:= Iif(lTSTRES, "1", "0") + Left(cTSTRES,1)
QL1->QL1_COMCAP	:= Iif(lCOMCAP, "1", "0") + Left(cCOMCAP,1)
QL1->QL1_DIAGRA	:= Iif(lDIAGRA, "1", "0") + Left(cDIAGRA,1)
QL1->QL1_COMCPT	:= Iif(lCOMCPT, "1", "0") + Left(cCOMCPT,1)
QL1->QL1_LISINS	:= Iif(lLISINS, "1", "0") + Left(cLISINS,1)
QL1->QL1_FOLHEG	:= Iif(lFOLHEG, "1", "0") + Left(cFOLHEG,1)
QL1->QL1_TATO	:= Iif(lTATO, "1", "0") + Left(cTATO,1)
QL1->QL1_ACUSTI	:= Iif(lACUSTI, "1", "0") + Left(cACUSTI,1)
QL1->QL1_CHEIRO	:= Iif(lCHEIRO, "1", "0") + Left(cCHEIRO,1)
QL1->QL1_GERAL	:= Iif(lGERAL, "1", "0") + Left(cGERAL,1)
QL1->QL1_CERTIF	:= Iif(lCERTIF, "1", "0") + Left(cCERTIF,1)
QL1->QL1_LIBCON	:= Iif(lLIBCON, "1", "0") + Left(cLIBCON,1)
QL1->QL1_MATCOM	:= Iif(lMATCOM, "1", "0") + Left(cMATCOM,1)
QL1->QL1_OUTROS	:= Iif(lOUTROS, "1", "0") + Left(cOUTROS,1)

MsUnLock()
	
End Transaction
				
Return lGraOk

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PP350TudOk ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 22.10.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para inclusao/alteracao geral                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP350TudOk                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QPPA350                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PP350TudOk

Local lRetorno	:= .T.

If Empty(M->QL1_PECA) .or. Empty(M->QL1_REV)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
Endif

If INCLUI
	If !ExistChav("QL1",M->QL1_PECA+M->QL1_REV)
		lRetorno := .F.
		Help(" ",1,"JAGRAVADO")  // Campo ja Existe
	Endif
	If !ExistCpo("QK1",M->QL1_PECA+M->QL1_REV)
		lRetorno := .F.
		Help(" ",1,"REGNOIS")  // Nao existe amarracao
	Endif
Endif

Return lRetorno


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A350Dele ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 22/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fucao para exclusao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A350Dele()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A350Dele()

DbSelectArea("QL1")

Begin Transaction

RecLock("QL1",.F.)
DbDelete()
MsUnLock()

End Transaction

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP350CHEC³ Autor ³ Robson Ramiro A Olivei³ Data ³ 22/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fucao para checagem das variaveis                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP350CHEC()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP350CHEC

lVDAAMO := (QL1->QL1_VDAAMO == "1")
lAMOINI := (QL1->QL1_AMOINI == "1")
lAMOPOS := (QL1->QL1_AMOPOS == "1")
lPCNOVA := (QL1->QL1_PCNOVA == "1")
lALTPRO := (QL1->QL1_ALTPRO == "1")
lPOSPRO := (QL1->QL1_POSPRO == "1")
lALPROC := (QL1->QL1_ALPROC == "1")
lINTPRO := (QL1->QL1_INTPRO == "1")
lSUBNOV := (QL1->QL1_SUBNOV == "1")
lPRODAE := (QL1->QL1_PRODAE == "1")
lPLPROD := (QL1->QL1_PLPROD == "1")
lFMEARE := (QL1->QL1_FMEARE == "1")
lRELDEM := (QL1->QL1_RELDEM == "1")

lTSTFUN := (Left(QL1->QL1_TSTFUN,1) == "1"); 	cTSTFUN	:= aItems[Iif(Val(Right(QL1->QL1_TSTFUN,1))=0,4,Val(Right(QL1->QL1_TSTFUN,1)))]
lTSTMED := (Left(QL1->QL1_TSTMED,1) == "1"); 	cTSTMED := aItems[Iif(Val(Right(QL1->QL1_TSTMED,1))=0,4,Val(Right(QL1->QL1_TSTMED,1)))]
lTSTMAT := (Left(QL1->QL1_TSTMAT,1) == "1"); 	cTSTMAT := aItems[Iif(Val(Right(QL1->QL1_TSTMAT,1))=0,4,Val(Right(QL1->QL1_TSTMAT,1)))]
lTSTRES := (Left(QL1->QL1_TSTRES,1) == "1"); 	cTSTRES := aItems[Iif(Val(Right(QL1->QL1_TSTRES,1))=0,4,Val(Right(QL1->QL1_TSTRES,1)))]
lCOMCAP := (Left(QL1->QL1_COMCAP,1) == "1"); 	cCOMCAP := aItems[Iif(Val(Right(QL1->QL1_COMCAP,1))=0,4,Val(Right(QL1->QL1_COMCAP,1)))]
lDIAGRA := (Left(QL1->QL1_DIAGRA,1) == "1"); 	cDIAGRA := aItems[Iif(Val(Right(QL1->QL1_DIAGRA,1))=0,4,Val(Right(QL1->QL1_DIAGRA,1)))]
lCOMCPT := (Left(QL1->QL1_COMCPT,1) == "1"); 	cCOMCPT := aItems[Iif(Val(Right(QL1->QL1_COMCPT,1))=0,4,Val(Right(QL1->QL1_COMCPT,1)))]
lLISINS := (Left(QL1->QL1_LISINS,1) == "1"); 	cLISINS := aItems[Iif(Val(Right(QL1->QL1_LISINS,1))=0,4,Val(Right(QL1->QL1_LISINS,1)))]
lFOLHEG := (Left(QL1->QL1_FOLHEG,1) == "1"); 	cFOLHEG := aItems[Iif(Val(Right(QL1->QL1_FOLHEG,1))=0,4,Val(Right(QL1->QL1_FOLHEG,1)))]
lTATO	:= (Left(QL1->QL1_TATO,1) == "1"); 	cTATO 	:= aItems[Iif(Val(Right(QL1->QL1_TATO,1))=0,4,Val(Right(QL1->QL1_TATO,1)))]
lACUSTI	:= (Left(QL1->QL1_ACUSTI,1) == "1"); 	cACUSTI := aItems[Iif(Val(Right(QL1->QL1_ACUSTI,1))=0,4,Val(Right(QL1->QL1_ACUSTI,1)))]
lCHEIRO	:= (Left(QL1->QL1_CHEIRO,1) == "1");	cCHEIRO := aItems[Iif(Val(Right(QL1->QL1_CHEIRO,1))=0,4,Val(Right(QL1->QL1_CHEIRO,1)))]
lGERAL	:= (Left(QL1->QL1_GERAL,1) == "1"); 	cGERAL 	:= aItems[Iif(Val(Right(QL1->QL1_GERAL,1))=0,4,Val(Right(QL1->QL1_GERAL,1)))]
lCERTIF	:= (Left(QL1->QL1_CERTIF,1) == "1");	cCERTIF := aItems[Iif(Val(Right(QL1->QL1_CERTIF,1))=0,4,Val(Right(QL1->QL1_CERTIF,1)))]
lLIBCON	:= (Left(QL1->QL1_LIBCON,1) == "1"); 	cLIBCON := aItems[Iif(Val(Right(QL1->QL1_LIBCON,1))=0,4,Val(Right(QL1->QL1_LIBCON,1)))]
lMATCOM	:= (Left(QL1->QL1_MATCOM,1) == "1"); 	cMATCOM := aItems[Iif(Val(Right(QL1->QL1_MATCOM,1))=0,4,Val(Right(QL1->QL1_MATCOM,1)))]
lOUTROS	:= (Left(QL1->QL1_OUTROS,1) == "1"); 	cOUTROS := aItems[Iif(Val(Right(QL1->QL1_OUTROS,1))=0,4,Val(Right(QL1->QL1_OUTROS,1)))]

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP350APRO³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 22.10.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Aprova VDA Folha de Capa                   				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP350APRO(Void)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP350APRO()
DbSelectArea("QAA")
DbSetOrder(6)
If Dbseek(Upper(cUserName))
	M->QL1_DTAPRO	:= Iif(Empty(M->QL1_DTAPRO), dDataBase, CtoD(" / / "))
	M->QL1_APROVA	:= Iif(Empty(M->QL1_APROVA), cUserName, Space(15))    
Else
	messagedlg(STR0057) //"O usuário logado não está cadastrado no cadastro de usuários do módulo, portanto não poderá ser o aprovador"
Endif

Return .T.
