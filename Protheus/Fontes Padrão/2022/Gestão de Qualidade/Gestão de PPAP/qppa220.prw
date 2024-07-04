#INCLUDE "QPPA220.CH"
#INCLUDE "PROTHEUS.CH"
                                                                                    
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA220  ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 13.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Certificado de Submissao de Peca de Producao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA220(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PPAP                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Robson Ramiro³22.07.02³XMeta ³ Criacao do campo aplicacao, inclusao   ³±±
±±³              ³        ³      ³ de rotina para observacoes             ³±±
±±³              ³        ³      ³ Inclusao de campo para cod. do resp.   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()

Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui"  , 	0, 1,,.F.},;//"Pesquisar"
					{ OemToAnsi(STR0002), "PPA220Visu", 	0, 2},;		//"Visualizar"
					{ OemToAnsi(STR0003), "PPA220Incl", 	0, 3},;		//"Incluir"
					{ OemToAnsi(STR0004), "PPA220Alte", 	0, 4},;		//"Alterar"
					{ OemToAnsi(STR0005), "PPA220Excl", 	0, 5},;		//"Excluir"
					{ OemToAnsi(STR0062), "QPPR220(.T.)", 	0, 6,,.T.},;//"Imprimir"
					{ OemToAnsi(STR0065), "QPPR011(.T.)", 	0, 7,,.T.} }//"Imp Niv Sub"

Return aRotina
Function QPPA220()

Private nEdicao := Val(GetMv("MV_QPPAPED",.T.,"3"))// Indica a Edicao do PPAP default 3 Edicao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private cCadastro	:= OemToAnsi(STR0006)  //"Certificado de Submissao de Peca de Producao"
Private cChave		:= ""
Private cDesAud	:= ""
Private aRotina := MenuDef()

DbSelectArea("QKI")
DbSetOrder(1)

mBrowse( 6, 1, 22, 75,"QKI",,,,,,)

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA220Visu  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³13.08.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Visualizacao                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA220Visu(ExpC1,ExpN1,ExpN2)                           ³±±
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

Function PPA220Visu(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local aCposVis		:= {}
Local aButtons		:= {}
Local oSize
Local aButtonPE := {}
Local nI 

Private oGet		:= NIL
Private lSUBDIM 	:= .F.
Private lSUBMAT 	:= .F.
Private lSUBAPA 	:= .F.
Private lFLNT1A		:= .F.
Private lFLNT1B		:= .F.
Private lFLNT1C		:= .F.
Private lFCLIA		:= .F.
Private lFCLIB		:= .F.
Private lFCLIC		:= .F.
Private lFLNT2A		:= .F.
Private lFLNT2B		:= .F.
Private lFLNT2C		:= .F.
Private lFLRZSUA 	:= .F.
Private lFLRZSUB 	:= .F.
Private lFLRZSUC 	:= .F.
Private lFLRZSUD 	:= .F.
Private lFLRZSUE 	:= .F.
Private lFLRZSUF 	:= .F.
Private lFLRZSUG 	:= .F.
Private lFLRZSUH 	:= .F.
Private lFLRZSUI 	:= .F.
Private lFLRZSUJ 	:= .F.
Private lFLNISU1	:= .F.
Private lFLNISU2	:= .F.
Private lFLNISU3	:= .F.
Private lFLNISU4	:= .F.
Private lFLNISU5	:= .F.
Private lRESDIM		:= .F.
Private lRESMAT		:= .F.
Private lRESAPA		:= .F.
Private lRESEST		:= .F.
Private lREQUISA	:= .F.
Private lREQUISB	:= .F.
Private lDISCLI1	:= .F.
Private lDISCLI2	:= .F.
Private lDISCLI3	:= .F.
Private lAPRFUN1	:= .F.
Private lAPRFUN2	:= .F.
Private oGetE
aCposVis := {	"QKI_PECA"	, "QKI_REV"		, "QKI_ITSEG"	, ;
				"QKI_ADENG"	, "QKI_DTADEN"	, "QKI_PEDCOM"	, ;
				"QKI_PESO"	, "QKI_DISMED"	, "QKI_ALDMEN"	, ;
				"QKI_DTDIME", "QKI_APLIC" 	, "QKI_AUXVER"	}
				
aButtons := {	{"BMPVISUAL",	{ || QPPR220() }, 			OemToAnsi(STR0007), OemToAnsi(STR0063) },; 	//"Visualizar/Imprimir"###"Vis/Prn"
				{"RELATORIO", 	{ || QPP220OBSE(nOpc) },	OemToAnsi(STR0060), OemToAnsi(STR0064) }} 		//"Observacoes"###"Obs"

If ExistBlock("QP220BUT")              
    aButtonPE := ExecBlock("QP220BUT",.F., .F., {nOpc})
    If ValType(aButtonPE) == "A"
      For nI = 1 To Len(aButtonPE)
        aAdd( aButtons, aButtonPE[nI] )
      next nI
    endif
EndIf   


DbSelectArea(cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New()

oSize:AddObject( "ENCHOICE"     ,  100, 30, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "FORMULARIO"   ,  100, 70, .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) +' - VISUALIZAÇÂO' ;  //"Certificado de Submissao de Peca de Producao"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

RegToMemory("QKI")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a Enchoice                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetE:=MsMGet():New( "QKI", nReg, nOpc,,,,aCposVis,;
						 {oSize:GetDimension("ENCHOICE","LININI"),;
						  oSize:GetDimension("ENCHOICE","COLINI"),;
						  oSize:GetDimension("ENCHOICE","LINEND"),;
						  oSize:GetDimension("ENCHOICE","COLEND")};
						,,,,,,oDlg,,.T.,,,,,,,.T.)
If nEdicao = 3
	QPP220TELA(nOpc, oDlg, oSize)
Else 
	QPP221TELA(nOpc, oDlg, oSize)
EndIf
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}, , aButtons)

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA220Incl  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³13.08.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Inclusao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA220Incl(ExpC1,ExpN1,ExpN2)                           ³±±
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

Function PPA220Incl(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local lOk 			:= .F.
Local aCposVis		:= {}
Local aButtons		:= {}
Local oSize  
Local aButtonPE := {}
Local nI 

Private oGet		:= NIL
Private lSUBDIM 	:= .F.
Private lSUBMAT 	:= .F.
Private lSUBAPA 	:= .F.
Private lFLNT1A		:= .F.
Private lFLNT1B		:= .F.    
Private lFLNT1C		:= .F.    
Private lFCLIA		:= .F.
Private lFCLIB		:= .F.
Private lFCLIC		:= .F.
Private lFLNT2A		:= .F.
Private lFLNT2B		:= .F.
Private lFLNT2C		:= .F.
Private lFLRZSUA 	:= .F.
Private lFLRZSUB 	:= .F.
Private lFLRZSUC 	:= .F.
Private lFLRZSUD 	:= .F.
Private lFLRZSUE 	:= .F.
Private lFLRZSUF 	:= .F.
Private lFLRZSUG 	:= .F.
Private lFLRZSUH 	:= .F.
Private lFLRZSUI 	:= .F.
Private lFLRZSUJ 	:= .F.
Private lFLNISU1	:= .F.
Private lFLNISU2	:= .F.
Private lFLNISU3	:= .F.
Private lFLNISU4	:= .F.
Private lFLNISU5	:= .F.
Private lRESDIM		:= .F.
Private lRESMAT		:= .F.
Private lRESAPA		:= .F.
Private lRESEST		:= .F.
Private lREQUISA	:= .F.
Private lREQUISB	:= .F.
Private lDISCLI1	:= .F.
Private lDISCLI2	:= .F.
Private lDISCLI3	:= .F.
Private lAPRFUN1	:= .F.
Private lAPRFUN2	:= .F.

Private dDataTR

aCposVis := {	"QKI_PECA"	, "QKI_REV"		, "QKI_ITSEG"	, ;
				"QKI_ADENG"	, "QKI_DTADEN"	, "QKI_PEDCOM"	, ;
				"QKI_PESO"	, "QKI_DISMED"	, "QKI_ALDMEN"	, ;
				"QKI_DTDIME", "QKI_APLIC"	, "QKI_AUXVER"	}
				
aButtons := { {"RELATORIO", { || QPP220OBSE(nOpc) }, OemToAnsi(STR0060), OemToAnsi(STR0064) }} //"Observacoes"###"Obs"				
If ExistBlock("QP220BUT")              
    aButtonPE := ExecBlock("QP220BUT",.F., .F., {nOpc})
    If ValType(aButtonPE) == "A"
      For nI = 1 To Len(aButtonPE)
        aAdd( aButtons, aButtonPE[nI] )
      next nI
    endif
EndIf		

DbSelectArea(cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New()

oSize:AddObject( "ENCHOICE"     ,  100, 30, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "FORMULARIO"   ,  100, 70, .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) +' - INCLUSÂO' ;  //"Certificado de Submissao de Peca de Producao"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
					
RegToMemory("QKI",.T.)
M->QKI_FILIAL := xFilial("QKI")
M->QKI_FILMAT := cFilAnt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a Enchoice                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetE:=MsMGet():New( "QKI", nReg, nOpc,,,,aCposVis,;
						 {oSize:GetDimension("ENCHOICE","LININI"),;
						  oSize:GetDimension("ENCHOICE","COLINI"),;
						  oSize:GetDimension("ENCHOICE","LINEND"),;
						  oSize:GetDimension("ENCHOICE","COLEND")};
						,,,,,,oDlg,,.T.,,,,,,,.T.)
If nEdicao = 3
	QPP220TELA(nOpc, oDlg, oSize)
Else 
	QPP221TELA(nOpc, oDlg, oSize)
EndIf
                      
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP220TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, ,aButtons )

If lOk
	PPA220Grav(nOpc)
Endif

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA220Alte  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³16.08.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Alteracao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA220Alte(ExpC1,ExpN1,ExpN2)                           ³±±
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

Function PPA220Alte(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local lOk 			:= .F.
Local aCposVis		:= {}
Local aButtons		:= {}
Local oSize
Local aButtonPE := {}
Local nI 

Private oGet		:= NIL
Private lSUBDIM 	:= .F.
Private lSUBMAT 	:= .F.
Private lSUBAPA 	:= .F.
Private lFLNT1A		:= .F.
Private lFLNT1B		:= .F.
Private lFLNT1C		:= .F.
Private lFCLIA		:= .F.
Private lFCLIB		:= .F.
Private lFCLIC		:= .F.
Private lFLNT2A		:= .F.
Private lFLNT2B		:= .F.
Private lFLNT2C		:= .F.
Private lFLRZSUA 	:= .F.
Private lFLRZSUB 	:= .F.
Private lFLRZSUC 	:= .F.
Private lFLRZSUD 	:= .F.
Private lFLRZSUE 	:= .F.
Private lFLRZSUF 	:= .F.
Private lFLRZSUG 	:= .F.
Private lFLRZSUH 	:= .F.
Private lFLRZSUI 	:= .F.
Private lFLRZSUJ 	:= .F.
Private lFLNISU1	:= .F.
Private lFLNISU2	:= .F.
Private lFLNISU3	:= .F.
Private lFLNISU4	:= .F.
Private lFLNISU5	:= .F.
Private lRESDIM		:= .F.
Private lRESMAT		:= .F.
Private lRESAPA		:= .F.
Private lRESEST		:= .F.
Private lREQUISA	:= .F.
Private lREQUISB	:= .F.
Private lDISCLI1	:= .F.
Private lDISCLI2	:= .F.
Private lDISCLI3	:= .F.
Private lAPRFUN1	:= .F.
Private lAPRFUN2	:= .F.

aCposVis := {	"QKI_PECA"	, "QKI_REV"		, "QKI_ITSEG"	, ;
				"QKI_ADENG"	, "QKI_DTADEN"	, "QKI_PEDCOM"	, ;
				"QKI_PESO"	, "QKI_DISMED"	, "QKI_ALDMEN"	, ;
				"QKI_DTDIME", "QKI_APLIC"	, "QKI_AUXVER"	}

aCposAlt := {	"QKI_ITSEG"	, ;
				"QKI_ADENG"	, "QKI_DTADEN"	, "QKI_PEDCOM"	, ;
				"QKI_PESO"	, "QKI_DISMED"	, "QKI_ALDMEN"	, ;
				"QKI_DTDIME", "QKI_APLIC"	, "QKI_AUXVER"	}
				
aButtons := { {"RELATORIO", { || QPP220OBSE(nOpc) }, OemToAnsi(STR0060), OemToAnsi(STR0064) }} 	//"Observacoes"###"Obs"
				
If !Q220VldAlt()
	Return
Endif

If ExistBlock("QP220BUT")              
    aButtonPE := ExecBlock("QP220BUT",.F., .F., {nOpc})
    If ValType(aButtonPE) == "A"
      For nI = 1 To Len(aButtonPE)
        aAdd( aButtons, aButtonPE[nI] )
      next nI
    endif
EndIf

DbSelectArea(cAlias)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New()

oSize:AddObject( "ENCHOICE"     ,  100, 30, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "FORMULARIO"   ,  100, 70, .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) +' - ALTERAÇÂO' ;  //"Certificado de Submissao de Peca de Producao"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

RegToMemory("QKI")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a Enchoice                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetE:=MsMGet():New( "QKI", nReg, nOpc,,,,aCposVis,;
						 {oSize:GetDimension("ENCHOICE","LININI"),;
						  oSize:GetDimension("ENCHOICE","COLINI"),;
						  oSize:GetDimension("ENCHOICE","LINEND"),;
						  oSize:GetDimension("ENCHOICE","COLEND")};
						,,,,,,oDlg,,.T.,,,,,,,.T.)
If nEdicao = 3
	QPP220TELA(nOpc, oDlg, oSize)
Else 
	QPP221TELA(nOpc, oDlg, oSize)
EndIf
                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP220TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, ,aButtons )

If lOk
	PPA220Grav(nOpc)
Endif

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA220Excl  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³17.08.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Exclusao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA220Excl(ExpC1,ExpN1,ExpN2)                           ³±±
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

Function PPA220Excl(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local aCposVis		:= {}
Local aButtons		:= {}
Local oSize
Local aButtonPE := {}
Local nI 

Private oGet		:= NIL
Private lSUBDIM 	:= .F.
Private lSUBMAT 	:= .F.
Private lSUBAPA 	:= .F.
Private lFLNT1A		:= .F.
Private lFLNT1B		:= .F.
Private lFLNT1C		:= .F.
Private lFCLIA		:= .F.
Private lFCLIB		:= .F.
Private lFCLIC		:= .F.
Private lFLNT2A		:= .F.
Private lFLNT2B		:= .F.
Private lFLNT2C		:= .F.
Private lFLRZSUA 	:= .F.
Private lFLRZSUB 	:= .F.
Private lFLRZSUC 	:= .F.
Private lFLRZSUD 	:= .F.
Private lFLRZSUE 	:= .F.
Private lFLRZSUF 	:= .F.
Private lFLRZSUG 	:= .F.
Private lFLRZSUH 	:= .F.
Private lFLRZSUI 	:= .F.
Private lFLRZSUJ 	:= .F.
Private lFLNISU1	:= .F.
Private lFLNISU2	:= .F.
Private lFLNISU3	:= .F.
Private lFLNISU4	:= .F.
Private lFLNISU5	:= .F.
Private lRESDIM		:= .F.
Private lRESMAT		:= .F.
Private lRESAPA		:= .F.
Private lRESEST		:= .F.
Private lREQUISA	:= .F.
Private lREQUISB	:= .F.
Private lDISCLI1	:= .F.
Private lDISCLI2	:= .F.
Private lDISCLI3	:= .F.
Private lAPRFUN1	:= .F.
Private lAPRFUN2	:= .F.

aCposVis := {	"QKI_PECA"	, "QKI_REV"		, "QKI_ITSEG"	, ;
				"QKI_ADENG"	, "QKI_DTADEN"	, "QKI_PEDCOM"	, ;
				"QKI_PESO"	, "QKI_DISMED"	, "QKI_ALDMEN"	, ;
				"QKI_DTDIME", "QKI_APLIC"	, "QKI_AUXVER"	}
				
aButtons := {	{"BMPVISUAL",	{ || QPPR220() }, 			OemToAnsi(STR0007), OemToAnsi(STR0063) },; 	//"Visualizar/Imprimir"###"Vis/Prn"
				{"RELATORIO", 	{ || QPP220OBSE(nOpc) },	OemToAnsi(STR0060), OemToAnsi(STR0064) }} 		//"Observacoes"###"Obs"

If ExistBlock("QP220BUT")              
    aButtonPE := ExecBlock("QP220BUT",.F., .F., {nOpc})
    If ValType(aButtonPE) == "A"
      For nI = 1 To Len(aButtonPE)
        aAdd( aButtons, aButtonPE[nI] )
      next nI
    endif
EndIf   
                         
DbSelectArea(cAlias)

IF !Q220VldExc()
	return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New()

oSize:AddObject( "ENCHOICE"     ,  100, 30, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "FORMULARIO"   ,  100, 70, .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) +' - EXCLUSÂO' ;  //"Certificado de Submissao de Peca de Producao"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

RegToMemory("QKI")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a Enchoice                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetE:=MsMGet():New( "QKI", nReg, nOpc,,,,aCposVis,;
						 {oSize:GetDimension("ENCHOICE","LININI"),;
						  oSize:GetDimension("ENCHOICE","COLINI"),;
						  oSize:GetDimension("ENCHOICE","LINEND"),;
						  oSize:GetDimension("ENCHOICE","COLEND")};
						,,,,,,oDlg,,.T.,,,,,,,.T.)
If nEdicao = 3
	QPP220TELA(nOpc, oDlg, oSize)
Else 
	QPP221TELA(nOpc, oDlg, oSize)
EndIf
                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| A220Dele(),oDlg:End()},{||oDlg:End()}, , aButtons)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP220TELA³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 13.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para informacoes do ScrollBox                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP220TELA(ExpN1, ExpO1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±³          ³ ExpO1 = Dialog       									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA220                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP220TELA(nOpc, oDlg, oSize)

Local oScrollBox 	:= NIL
Local oCkSUBDIM, oCkSUBMAT, oCkSUBAPA, oCOMPRA, oOUTRO1
Local oCkFLNT1A, oCkFLNT1B, oCkFLNT1C, oCkFLNT2A, oCkFLNT2B, OCKFLNT2C
Local oCkFLRZSUA, oCkFLRZSUB,oCkFLRZSUC, oCkFLRZSUD, oCkFLRZSUE
Local oCkFLRZSUF, oCkFLRZSUG,oCkFLRZSUH, oCkFLRZSUI, oCkFLRZSUJ
Local oCkFLNISU1, oCkFLNISU2, oCkFLNISU3, oCkFLNISU4, oCkFLNISU5
Local oCkRESDIM, oCkRESMAT, oCkRESAPA, oCkRESEST
Local oCkREQUISA, oCkREQUISB, oMOLDE
Local oTXPROD, oCOMENT, oNOMAPR, oCARAPR, oTELAPR, oDTAPR
Local oCkDISCLI1, oCkDISCLI2, oCkDISCLI3, oOUTRO2
Local oCkAPRFUN1, oCKAPRFUN2
Local oREPCLI, oDTRCLI
Local oMat
Local aObjects1	:= {}
Local aObjects2	:= {}
Local aSizeAut  := MsAdvSize( .F. )    // Array para redimensionamento da tela

DEFINE FONT oFont NAME "Arial" SIZE 5,15                                                   

If nOpc <> 3
	QPP220CHEC()
Endif

oScrollBox := TScrollBox():New(oDlg,126,0,aSizeAut[4]-150,aSizeAut[3],.T.,.T.,.T.)   
//oScrollBox := TScrollBox():New(oDlg,oSize:GetDimension("FORMULARIO","LININI"),;
//									 oSize:GetDimension("FORMULARIO","COLINI"),;
//									 oSize:GetDimension("FORMULARIO","YSIZE"),;
//									 oSize:GetDimension("FORMULARIO","XSIZE"),.T.,.T.,.T.)   

@ 001,110 SAY OemToAnsi(STR0008) SIZE 100,010 COLOR CLR_RED OF oScrollBox PIXEL; //"INFORMACOES DA SUBMISSAO"
														FONT oFont

@ 015,016 CHECKBOX oCkSUBDIM VAR lSUBDIM SIZE 008,008 OF oScrollBox PIXEL
@ 015,025 SAY OemToAnsi(STR0009) SIZE 044,010 OF oScrollBox PIXEL; //"Dimensional"
														FONT oFont

@ 015,125 CHECKBOX oCkSUBMAT VAR lSUBMAT SIZE 008,008 OF oScrollBox PIXEL
@ 015,134 SAY OemToAnsi(STR0010) SIZE 076,010 OF oScrollBox PIXEL; //"Materiais/Funcional"
														FONT oFont
                                                                                 
@ 015,253 CHECKBOX oCkSUBAPA VAR lSUBAPA SIZE 008,008 OF oScrollBox PIXEL
@ 015,262 SAY OemToAnsi(STR0011) SIZE 036,010 OF oScrollBox PIXEL; //"Aparencia"
														FONT oFont
														
@ 030,003 SAY OemToAnsi(STR0012) SIZE 116,010 OF oScrollBox PIXEL FONT oFont //"Comprador/Codigo do Comprador"
@ 030,120 MSGET oCOMPRA VAR M->QKI_COMPRA PICTURE PesqPict("QKI", "QKI_COMPRA");
		   VALID CheckSX3("QKI_COMPRA",M->QKI_COMPRA) SIZE 160,005 OF oScrollBox PIXEL FONT oFont

@ 035,003 SAY REPLICATE(OemToAnsi("_"),150) SIZE 310,007 OF oScrollBox PIXEL FONT oFont

@ 060,003 SAY OemToAnsi(STR0013) SIZE 116,010 OF oScrollBox PIXEL FONT oFont //"Nota :"
@ 060,030 SAY OemToAnsi(STR0014) SIZE 228,010 OF oScrollBox PIXEL FONT oFont //"Esta peca contem alguma substancia restrita ou reportavel"

@ 050,265 SAY OemToAnsi(STR0015) SIZE 012,010 COLOR CLR_RED OF oScrollBox PIXEL FONT oFont //"Sim"
@ 050,280 SAY OemToAnsi(STR0016) SIZE 012,010 COLOR CLR_RED OF oScrollBox PIXEL FONT oFont //"Nao"
@ 050,295 SAY OemToAnsi(STR0083) SIZE 012,010 COLOR CLR_RED OF oScrollBox PIXEL FONT oFont //"N/A"

@ 060,267 CHECKBOX oCkFLNT1A VAR lFLNT1A	SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif( lFLNT1A,( lFLNT1B := .F.,oCkFLNT1B:Refresh(),lFLNT1C := .F.,oCkFLNT1C:Refresh() ), )

@ 060,282 CHECKBOX oCkFLNT1B VAR lFLNT1B	SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif( lFLNT1B,( lFLNT1A := .F.,oCkFLNT1A:Refresh(),lFLNT1C := .F.,oCkFLNT1C:Refresh() ), )
			 	 
@ 060,297 CHECKBOX oCkFLNT1C VAR lFLNT1C	SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif( lFLNT1C,( lFLNT1A := .F.,oCkFLNT1A:Refresh(),lFLNT1B := .F.,oCkFLNT1B:Refresh() ), )

@ 075,030 SAY OemToAnsi(STR0017) SIZE 228,010 OF oScrollBox PIXEL FONT oFont //"As pecas plasticas sao identificadas com os codigos adequados de marcacao ISO"

@ 075,267 CHECKBOX oCkFLNT2A VAR lFLNT2A	SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif( lFLNT2A,( lFLNT2B := .F.,oCkFLNT2B:Refresh(),lFLNT2C := .F.,oCkFLNT2C:Refresh() ), )

@ 075,282 CHECKBOX oCkFLNT2B VAR lFLNT2B	SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif( lFLNT2B,( lFLNT2A := .F.,oCkFLNT2A:Refresh(),lFLNT2C := .F.,oCkFLNT2C:Refresh() ), )
			 	 
@ 075,297 CHECKBOX oCkFLNT2C VAR lFLNT2C	SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif( lFLNT2C,( lFLNT2A := .F.,oCkFLNT2A:Refresh(),lFLNT2B := .F.,oCkFLNT2B:Refresh() ), )

@ 080,003 SAY REPLICATE(OemToAnsi("_"),150) SIZE 310,007 OF oScrollBox PIXEL FONT oFont

@ 095,110 SAY OemToAnsi(STR0018) SIZE 100,010 COLOR CLR_RED OF oScrollBox PIXEL; //"RAZAO PARA SUBMISSAO"
														FONT oFont

@ 110,003 CHECKBOX oCkFLRZSUA VAR lFLRZSUA SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLRZSUA,QPP220Opt1(aObjects1,1), )
       
@ 110,015 SAY OemToAnsi(STR0019) SIZE 068,010 OF oScrollBox PIXEL FONT oFont //"Submissao Inicial"

@ 125,003 CHECKBOX oCkFLRZSUB VAR lFLRZSUB SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLRZSUB,QPP220Opt1(aObjects1,2), )
       
@ 125,015 SAY OemToAnsi(STR0020) SIZE 096,010 OF oScrollBox PIXEL FONT oFont //"Alteracoes de Engenharia"

@ 140,003 CHECKBOX oCkFLRZSUC VAR lFLRZSUC SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLRZSUC,QPP220Opt1(aObjects1,3), )
       
@ 140,015 SAY OemToAnsi(STR0021) SIZE 240,010 OF oScrollBox PIXEL FONT oFont //"Ferramental: Transferencia, Reposicao, Reparo, ou Adicional"

@ 155,003 CHECKBOX oCkFLRZSUD VAR lFLRZSUD SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLRZSUD,QPP220Opt1(aObjects1,4), )
       
@ 155,015 SAY OemToAnsi(STR0022) SIZE 096,010 OF oScrollBox PIXEL FONT oFont //"Correcao de Discrepancia"

@ 170,003 CHECKBOX oCkFLRZSUE VAR lFLRZSUE SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLRZSUE,QPP220Opt1(aObjects1,5), )
       
@ 170,015 SAY OemToAnsi(STR0023) SIZE 148,010 OF oScrollBox PIXEL FONT oFont //"Ferramental Inativo por mais de 1 ano"

@ 185,003 CHECKBOX oCkFLRZSUF VAR lFLRZSUF SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLRZSUF,QPP220Opt1(aObjects1,6), )
       
@ 185,015 SAY OemToAnsi(STR0024) SIZE 180,010 OF oScrollBox PIXEL FONT oFont //"Alteracao de Material ou Construcao Opcional"

@ 200,003 CHECKBOX oCkFLRZSUG VAR lFLRZSUG SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLRZSUG,QPP220Opt1(aObjects1,7), )
       
@ 200,015 SAY OemToAnsi(STR0025) SIZE 188,010 OF oScrollBox PIXEL FONT oFont //"Alteracao do Subfornecedor ou Fonte do Material"

@ 215,003 CHECKBOX oCkFLRZSUH VAR lFLRZSUH SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLRZSUH,QPP220Opt1(aObjects1,8), )
       
@ 215,015 SAY OemToAnsi(STR0026) SIZE 172,010 OF oScrollBox PIXEL FONT oFont //"Alteracao do Processo de Fabricacao da Peca"

@ 230,003 CHECKBOX oCkFLRZSUI VAR lFLRZSUI SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLRZSUI,QPP220Opt1(aObjects1,9), )
       
@ 230,015 SAY OemToAnsi(STR0027) SIZE 144,010 OF oScrollBox PIXEL FONT oFont //"Pecas Produzidas em outra Localidade"

@ 245,003 CHECKBOX oCkFLRZSUJ VAR lFLRZSUJ SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLRZSUJ,(oOUTRO1:SetFocus(),QPP220Opt1(aObjects1,10)), )
       
@ 245,015 SAY OemToAnsi(STR0028) SIZE 088,010 OF oScrollBox PIXEL FONT oFont //"Outros - Especifique :"
@ 245,120 MSGET oOUTRO1 VAR M->QKI_OUTRO1 PICTURE PesqPict("QKI", "QKI_OUTRO1");
		   VALID CheckSX3("QKI_OUTRO1",M->QKI_OUTRO1) WHEN lFLRZSUJ;
		   SIZE 160,005 OF oScrollBox PIXEL FONT oFont

aObjects1 :=	{	oCkFLRZSUA, oCkFLRZSUB, oCkFLRZSUC, oCkFLRZSUD, oCkFLRZSUE,;
				oCkFLRZSUF, oCkFLRZSUG,oCkFLRZSUH, oCkFLRZSUI, oCkFLRZSUJ }

@ 250,003 SAY REPLICATE(OemToAnsi("_"),150) SIZE 310,007 OF oScrollBox PIXEL FONT oFont

@ 265,110 SAY OemToAnsi(STR0029) SIZE 160,010 COLOR CLR_RED OF oScrollBox PIXEL; //"NIVEL DE SUBMISSAO REQUERIDO (Marque um)"
														FONT oFont			 	 

@ 280,003 CHECKBOX oCkFLNISU1 VAR lFLNISU1 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLNISU1,QPP220Opt2(aObjects2,1), )
			 
@ 280,015 SAY OemToAnsi(STR0030) SIZE 280,010 OF oScrollBox PIXEL FONT oFont //"Nivel 1 - Certificado apenas(e para itens de aparencia designados, um Relatorio de Aprovacao de Aparencia) submetidos ao cliente."

@ 295,003 CHECKBOX oCkFLNISU2 VAR lFLNISU2 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLNISU2,QPP220Opt2(aObjects2,2), )
			 
@ 295,015 SAY OemToAnsi(STR0031) SIZE 280,010 OF oScrollBox PIXEL FONT oFont //"Nivel 2 - Certificado com amostras do produto e dados limitados de suporte submetidos ao cliente."

@ 310,003 CHECKBOX oCkFLNISU3 VAR lFLNISU3 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLNISU3,QPP220Opt2(aObjects2,3), )
			 
@ 310,015 SAY OemToAnsi(STR0032) SIZE 280,010 OF oScrollBox PIXEL FONT oFont //"Nivel 3 - Certificado com amostras do produto e todos os dados de suporte submetidos ao cliente."

@ 325,003 CHECKBOX oCkFLNISU4 VAR lFLNISU4 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLNISU4,QPP220Opt2(aObjects2,4), )
			 
@ 325,015 SAY OemToAnsi(STR0033) SIZE 280,010 OF oScrollBox PIXEL FONT oFont //"Nivel 4 - Certificado e outros requisitos conforme definido pelo cliente"

@ 340,003 CHECKBOX oCkFLNISU5 VAR lFLNISU5 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLNISU5,QPP220Opt2(aObjects2,5), )
			 
@ 340,015 SAY OemToAnsi(STR0034) SIZE 280,010 OF oScrollBox PIXEL FONT oFont //"Nivel 5 - Certificado com amostras do produto e todos os dados de suporte verificados na localidade de manufatura do fornecedor"

aObjects2 := { oCkFLNISU1, oCkFLNISU2, oCkFLNISU3, oCkFLNISU4, oCkFLNISU5 }

@ 345,003 SAY REPLICATE(OemToAnsi("_"),150) SIZE 310,007 OF oScrollBox PIXEL FONT oFont

@ 360,110 SAY OemToAnsi(STR0035) SIZE 100,010 COLOR CLR_RED OF oScrollBox PIXEL; //"RESULTADOS DA SUBMISSAO"
														FONT oFont			 	 

@ 375,003 SAY OemToAnsi(STR0036) SIZE 072,010 OF oScrollBox PIXEL FONT oFont //"Os resultados de :"

@ 375,080 CHECKBOX oCkRESDIM VAR lRESDIM SIZE 008,008 OF oScrollBox PIXEL
			 	 
@ 375,095 SAY OemToAnsi(STR0037) SIZE 084,010 OF oScrollBox PIXEL FONT oFont //"Medicoes Dimensionais"

@ 390,080 CHECKBOX oCkRESMAT VAR lRESMAT SIZE 008,008 OF oScrollBox PIXEL
			 	 
@ 390,095 SAY OemToAnsi(STR0038) SIZE 132,010 OF oScrollBox PIXEL FONT oFont //"Ensaios de Material e Funcionais"

@ 405,080 CHECKBOX oCkRESAPA VAR lRESAPA SIZE 008,008 OF oScrollBox PIXEL
			 	 
@ 405,095 SAY OemToAnsi(STR0039) SIZE 132,010 OF oScrollBox PIXEL FONT oFont //"Criterios de Aparencia"

@ 420,080 CHECKBOX oCkRESEST VAR lRESEST SIZE 008,008 OF oScrollBox PIXEL
			 	 
@ 420,095 SAY OemToAnsi(STR0040) SIZE 132,010 OF oScrollBox PIXEL FONT oFont //"Dados Estatisticos"

@ 435,003 SAY OemToAnsi(STR0041) SIZE 200,010 OF oScrollBox PIXEL FONT oFont //"Atendem a todos os requisitos do desenho e de especificacoes :"

@ 435,150 CHECKBOX oCkREQUISA VAR lREQUISA SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif( lREQUISA,( lREQUISB := .F.,oCkREQUISB:Refresh()), )

@ 435,185 CHECKBOX oCkREQUISB VAR lREQUISB SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif( lREQUISB,( lREQUISA := .F.,oCkREQUISA:Refresh()), )

@ 435,160 SAY OemToAnsi(STR0015) SIZE 200,010 OF oScrollBox PIXEL FONT oFont //"SIM"

@ 435,195 SAY OemToAnsi(STR0042) SIZE 150,010 OF oScrollBox PIXEL FONT oFont //"NAO     (Se 'Nao' - Explicacoes sao Necessarias)"

@ 450,003 SAY OemToAnsi(STR0043) SIZE 120,010 OF oScrollBox PIXEL FONT oFont //"Processo de Producao/Cavidade/Molde :"
      
@ 450,130 MSGET oMOLDE VAR M->QKI_MOLDE PICTURE PesqPict("QKI", "QKI_MOLDE");
		   VALID CheckSX3("QKI_MOLDE",M->QKI_MOLDE) SIZE 160,005 OF oScrollBox PIXEL FONT oFont


@ 455,003 SAY REPLICATE(OemToAnsi("_"),150) SIZE 310,007 OF oScrollBox PIXEL FONT oFont

@ 470,110 SAY OemToAnsi(STR0044) SIZE 040,010 COLOR CLR_RED OF oScrollBox PIXEL; //"DECLARACAO"
														FONT oFont			 	 

@ 485,003 SAY OemToAnsi(STR0045) SIZE 072,010 OF oScrollBox PIXEL FONT oFont //"Taxa de Producao :"

@ 485,080 MSGET oTXPROD VAR M->QKI_TXPROD PICTURE PesqPict("QKI", "QKI_TXPROD");
		   VALID CheckSX3("QKI_TXPROD",M->QKI_TXPROD) SIZE 040,005 OF oScrollBox PIXEL FONT oFont


@ 500,003 SAY OemToAnsi(STR0046) SIZE 108,100 OF oScrollBox PIXEL FONT oFont //"Explicacoes/Comentarios :"

cDesAud := MsMM(M->QKI_DESCHV,TamSx3("QKI_COMEN1")[1])
    @ 500,080 GET oCOMENT VAR cDesAud MEMO VALID CheckSX3("QKI_COMEN1",cDesAud); 
	WHEN VisualSX3("QKI_COMEN1")Size 240,060 Of oScrollBox NO VSCROLL Pixel FONT oFont

@ 565,003 SAY OemToAnsi(STR0047) SIZE 024,010 OF oScrollBox PIXEL FONT oFont //"Nome :"

@ 565,045 MSGET oMAT VAR M->QKI_MAT PICTURE PesqPict("QKI", "QKI_MAT");
			VALID CheckSX3("QKI_MAT",M->QKI_MAT) .and. ;
			(M->QKI_NOMAPR := Posicione("QAA",1,M->QKI_FILMAT+M->QKI_MAT,"QAA_NOME"),.T.) .and. ;
			(oNOMAPR:Refresh(),.T.) SIZE 040,005 ;
			ReadOnly F3 ConSX3("QKI_MAT") OF oScrollBox PIXEL FONT oFont

If nOpc == 3
	oMat:lReadOnly := .F.
Endif
If nOpc == 4 
	If Empty(M->QKI_MAT)
		oMat:lReadOnly			:= .F.
	Else
		DbSelectArea("QAA")
		DbSetOrder(1)
		If DbSeek(xFilial("QAA")+QKI->QKI_MAT) .and. UPPER(QAA->QAA_LOGIN) == UPPER(cUserName)
			oMat:lReadOnly			:= .F.
		Endif	
	Endif
Endif

@ 565,095 MSGET oNOMAPR VAR M->QKI_NOMAPR PICTURE PesqPict("QKI", "QKI_NOMAPR");
			VALID CheckSX3("QKI_NOMAPR",M->QKI_NOMAPR) WHEN Empty(M->QKI_MAT);
			SIZE 160,005 OF oScrollBox PIXEL FONT oFont

@ 590,003 SAY OemToAnsi(STR0048) SIZE 028,010 OF oScrollBox PIXEL FONT oFont //"Cargo :"

@ 590,045 MSGET oCARAPR VAR M->QKI_CARAPR PICTURE PesqPict("QKI", "QKI_CARAPR");
		   VALID CheckSX3("QKI_CARAPR",M->QKI_CARAPR) SIZE 160,005 OF oScrollBox PIXEL FONT oFont

@ 615,003 SAY OemToAnsi(STR0049) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"Telefone :"

@ 615,045 MSGET oTELAPR VAR M->QKI_TELAPR PICTURE PesqPict("QKI", "QKI_TELAPR");
		   VALID CheckSX3("QKI_TELAPR",M->QKI_TELAPR) SIZE 080,005 OF oScrollBox PIXEL FONT oFont
                                                                                      
@ 615,130 SAY OemToAnsi(STR0050) SIZE 028,010 OF oScrollBox PIXEL FONT oFont //"Data :"

@ 615,165 MSGET oDTAPR VAR M->QKI_DTAPR SIZE 040,005 OF oScrollBox PIXEL FONT oFont

@ 620,003 SAY REPLICATE(OemToAnsi("_"),150) SIZE 310,007 OF oScrollBox PIXEL FONT oFont

@ 630,100 SAY OemToAnsi(STR0051) SIZE 160,010 COLOR CLR_RED OF oScrollBox PIXEL; //"PARA USO DO CLIENTE APENAS (SE APLICAVEL)"
														FONT oFont

@ 650,003 SAY OemToAnsi(STR0052) SIZE 100,010 OF oScrollBox PIXEL FONT oFont //"Disposicao do Certificado da Peca :"

@ 650,115 CHECKBOX oCkDISCLI1 VAR lDISCLI1 SIZE 008,008 OF oScrollBox PIXEL;
			ON CLICK Iif( lDISCLI1,( lDISCLI2 := .F. , lDISCLI3 := .F.,; 
			oCkDISCLI1:Refresh(),oCkDISCLI2:Refresh(),oCkDISCLI3:Refresh()), )
			 	 
@ 650,125 SAY OemToAnsi(STR0053) SIZE 030,010 OF oScrollBox PIXEL FONT oFont //"Aprovado"

@ 665,115 CHECKBOX oCkDISCLI2 VAR lDISCLI2 SIZE 008,008 OF oScrollBox PIXEL;
			ON CLICK Iif( lDISCLI2,( lDISCLI1 := .F. , lDISCLI3 := .F.,; 
			oCkDISCLI1:Refresh(),oCkDISCLI2:Refresh(),oCkDISCLI3:Refresh()), )

			 	 
@ 665,125 SAY OemToAnsi(STR0054) SIZE 030,010 OF oScrollBox PIXEL FONT oFont //"Rejeitado"

@ 680,115 CHECKBOX oCkDISCLI3 VAR lDISCLI3 SIZE 008,008 OF oScrollBox PIXEL;
			ON CLICK Iif( lDISCLI3,( lDISCLI1 := .F. , lDISCLI2 := .F.,; 
			oOUTRO2:SetFocus(),oCkDISCLI1:Refresh(),oCkDISCLI2:Refresh(),oCkDISCLI3:Refresh()), )
						 	 
@ 680,125 SAY OemToAnsi(STR0055) SIZE 020,010 OF oScrollBox PIXEL FONT oFont //"Outros"

@ 680,160 MSGET oOUTRO2 VAR M->QKI_OUTRO2 PICTURE PesqPict("QKI", "QKI_OUTRO2");
		   VALID CheckSX3("QKI_OUTRO2",M->QKI_OUTRO2) WHEN lDISCLI3;
		   SIZE 160,005 OF oScrollBox PIXEL FONT oFont

@ 710,003 SAY OemToAnsi(STR0056) SIZE 100,010 OF oScrollBox PIXEL FONT oFont //"Aprovacao Funcional da Peca :"

@ 710,115 CHECKBOX oCkAPRFUN1 VAR lAPRFUN1 SIZE 008,008 OF oScrollBox PIXEL;
			ON CLICK Iif( lAPRFUN1,( lAPRFUN2 := .F. , oCkAPRFUN2:Refresh()), )
			 	 
@ 710,125 SAY OemToAnsi(STR0053) SIZE 030,010 OF oScrollBox PIXEL FONT oFont //"Aprovado"

@ 725,115 CHECKBOX oCkAPRFUN2 VAR lAPRFUN2 SIZE 008,008 OF oScrollBox PIXEL;
			ON CLICK Iif( lAPRFUN2,( lAPRFUN1 := .F. , oCkAPRFUN1:Refresh()), )
			 	 
@ 725,125 SAY OemToAnsi(STR0057) SIZE 038,010 OF oScrollBox PIXEL FONT oFont //"Dispensado"

@ 740,003 SAY OemToAnsi(STR0050) SIZE 028,010 OF oScrollBox PIXEL FONT oFont //"Data :"

@ 740,035 MSGET oDTRCLI VAR M->QKI_DTRCLI SIZE 040,005 OF oScrollBox PIXEL FONT oFont

@ 755,003 SAY OemToAnsi(STR0058) SIZE 092,010 OF oScrollBox PIXEL FONT oFont //"Representante Cliente :"

@ 755,095 MSGET oREPCLI VAR M->QKI_REPCLI PICTURE PesqPict("QKI", "QKI_REPCLI");
		   VALID CheckSX3("QKI_REPCLI",M->QKI_REPCLI) SIZE 160,005 OF oScrollBox PIXEL FONT oFont

@ 770,003 SAY REPLICATE(OemToAnsi("_"),150) SIZE 280,007 OF oScrollBox PIXEL FONT oFont

@ 780,003 SAY OemToAnsi(STR0059) SIZE 088,010 OF oScrollBox PIXEL FONT oFont //"Julho 1999  CFG-1001"


If nOpc == 2 .or. nOpc == 5
	oCkSUBDIM:lReadOnly		:= .T.
	oCkSUBMAT:lReadOnly		:= .T.
	oCkSUBAPA:lReadOnly		:= .T.
	oCOMPRA:lReadOnly		:= .T.
	oOUTRO1:lReadOnly		:= .T.
	oCkFLNT1A:lReadOnly		:= .T.
	oCkFLNT1B:lReadOnly		:= .T.
	oCkFLNT1C:lReadOnly		:= .T.
	oCkFLNT2A:lReadOnly		:= .T.
	oCkFLNT2B:lReadOnly		:= .T.
	oCkFLNT2C:lReadOnly		:= .T.
	oCkFLRZSUA:lReadOnly	:= .T.
	oCkFLRZSUB:lReadOnly	:= .T.
	oCkFLRZSUC:lReadOnly	:= .T.
	oCkFLRZSUD:lReadOnly	:= .T.
    oCkFLRZSUE:lReadOnly	:= .T.
    oCkFLRZSUF:lReadOnly	:= .T.
    oCkFLRZSUG:lReadOnly	:= .T.
    oCkFLRZSUH:lReadOnly	:= .T.
    oCkFLRZSUI:lReadOnly	:= .T.
    oCkFLRZSUJ:lReadOnly	:= .T.
    oCkFLNISU1:lReadOnly	:= .T.
    oCkFLNISU2:lReadOnly	:= .T.
    oCkFLNISU3:lReadOnly	:= .T.
    oCkFLNISU4:lReadOnly	:= .T.
    oCkFLNISU5:lReadOnly	:= .T.
    oCkRESDIM:lReadOnly		:= .T.
    oCkRESMAT:lReadOnly		:= .T.
    oCkRESAPA:lReadOnly		:= .T.
    oCkRESEST:lReadOnly		:= .T.
    oCkREQUISA:lReadOnly	:= .T.
    oCkREQUISB:lReadOnly	:= .T.
    oMOLDE:lReadOnly		:= .T.
    oTXPROD:lReadOnly		:= .T.
    oCOMENT:lReadOnly		:= .T.
    oNOMAPR:lReadOnly		:= .T.
    oCARAPR:lReadOnly		:= .T.
    oTELAPR:lReadOnly		:= .T.
    oDTAPR:lReadOnly		:= .T.
    oCkDISCLI1:lReadOnly	:= .T.
    oCkDISCLI2:lReadOnly	:= .T.
    oCkDISCLI3:lReadOnly	:= .T.
    oOUTRO2:lReadOnly		:= .T.
    oCkAPRFUN1:lReadOnly	:= .T.
    oCKAPRFUN2:lReadOnly	:= .T.
    oREPCLI:lReadOnly		:= .T.
    oDTRCLI:lReadOnly		:= .T.
	oMat:lReadOnly			:= .T.
	SysRefresh()
Endif


Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP221TELA³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 24.11.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para informacoes do ScrollBox 4 Edicao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP221TELA(ExpN1, ExpO1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±³          ³ ExpO1 = Dialog       									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA220                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP221TELA(nOpc, oDlg, oSize)

Local oScrollBox 	:= NIL
Local oCkSUBDIM, oCkSUBMAT, oCkSUBAPA, oCOMPRA, oOUTRO1
Local oCkFLNT1A, oCkFLNT1B, oCkFLNT1C, oCkFLNT2A, oCkFLNT2B, oCkFLNT2C, oCkCLIA, oCkCLIB, oCkCLIC               
Local oCkFLRZSUA, oCkFLRZSUB,oCkFLRZSUC, oCkFLRZSUD, oCkFLRZSUE
Local oCkFLRZSUF, oCkFLRZSUG,oCkFLRZSUH, oCkFLRZSUI, oCkFLRZSUJ
Local oCkFLNISU1, oCkFLNISU2, oCkFLNISU3, oCkFLNISU4, oCkFLNISU5
Local oCkRESDIM, oCkRESMAT, oCkRESAPA, oCkRESEST
Local oCkREQUISA, oCkREQUISB, oMOLDE
Local oTXPROD, oCOMENT, oNOMAPR, oCARAPR, oTELAPR, oDTAPR
Local oCkDISCLI1, oCkDISCLI2, oCkDISCLI3, oOUTRO2
Local oCkAPRFUN1, oCKAPRFUN2
Local oREPCLI, oDTRCLI
Local oMat
Local aObjects1	:= {}
Local aObjects2	:= {}
Local lin     	:= 0
Local aSizeAut  := MsAdvSize( .F. )    // Array para redimensionamento da tela

DEFINE FONT oFont NAME "Arial" SIZE 5,15

If nOpc <> 3
	QPP220CHEC()
Endif

oScrollBox := TScrollBox():New(oDlg,126,0,aSizeAut[4]-150,aSizeAut[3],.T.,.T.,.T.)   
//oScrollBox := TScrollBox():New(oDlg,oSize:GetDimension("FORMULARIO","LININI"),;
//									 oSize:GetDimension("FORMULARIO","COLINI"),;
//									 oSize:GetDimension("FORMULARIO","XSIZE"),;
//									 oSize:GetDimension("FORMULARIO","YSIZE"),.T.,.T.,.T.)   

@ lin,110 SAY OemToAnsi(STR0008) SIZE 80,010 COLOR CLR_RED OF oScrollBox PIXEL; //"INFORMACOES DA SUBMISSAO"
														FONT oFont
lin += 14

@ lin,016 CHECKBOX oCkSUBDIM VAR lSUBDIM SIZE 008,008 OF oScrollBox PIXEL
@ lin,025 SAY OemToAnsi(STR0009) SIZE 044,010 OF oScrollBox PIXEL; //"Dimensional"
														FONT oFont

@ lin,125 CHECKBOX oCkSUBMAT VAR lSUBMAT SIZE 008,008 OF oScrollBox PIXEL
@ lin,134 SAY OemToAnsi(STR0010) SIZE 076,010 OF oScrollBox PIXEL; //"Materiais/Funcional"
														FONT oFont
                                                                                 
@ lin,253 CHECKBOX oCkSUBAPA VAR lSUBAPA SIZE 008,008 OF oScrollBox PIXEL
@ lin,262 SAY OemToAnsi(STR0011) SIZE 036,010 OF oScrollBox PIXEL; //"Aparencia"
														FONT oFont
lin += 15
														
@ lin,003 SAY OemToAnsi(STR0012) SIZE 116,010 OF oScrollBox PIXEL FONT oFont //"Comprador/Codigo do Comprador"
@ lin,120 MSGET oCOMPRA VAR M->QKI_COMPRA PICTURE PesqPict("QKI", "QKI_COMPRA");
		   VALID CheckSX3("QKI_COMPRA",M->QKI_COMPRA) SIZE 160,005 OF oScrollBox PIXEL FONT oFont

lin += 5
@ lin,003 SAY REPLICATE(OemToAnsi("_"),150) SIZE 310,007 OF oScrollBox PIXEL FONT oFont

lin += 15
@ lin,110 SAY OemToAnsi(STR0066) SIZE 100,010 COLOR CLR_RED OF oScrollBox PIXEL; //"RELATORIO MATERIAIS"
														FONT oFont
lin += 10
@ lin,265 SAY OemToAnsi(STR0015) SIZE 012,010 COLOR CLR_RED OF oScrollBox PIXEL FONT oFont //"Sim"
@ lin,280 SAY OemToAnsi(STR0016) SIZE 012,010 COLOR CLR_RED OF oScrollBox PIXEL FONT oFont //"Nao"
@ lin,295 SAY OemToAnsi(STR0083) SIZE 012,010 COLOR CLR_RED OF oScrollBox PIXEL FONT oFont //"N/A"

lin += 10
@ lin,030 SAY OemToAnsi(STR0014) SIZE 228,010 OF oScrollBox PIXEL FONT oFont //"Esta peca contem alguma substancia restrita ou reportavel"


@ lin,267 CHECKBOX oCkFLNT1A VAR lFLNT1A	SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif( lFLNT1A,( lFLNT1B := .F.,oCkFLNT1B:Refresh(),lFLNT1C := .F.,oCkFLNT1C:Refresh() ), )

@ lin,282 CHECKBOX oCkFLNT1B VAR lFLNT1B	SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif( lFLNT1B,( lFLNT1A := .F.,oCkFLNT1A:Refresh(),lFLNT1C := .F.,oCkFLNT1C:Refresh() ), )
			 	 
@ lin,297 CHECKBOX oCkFLNT1C VAR lFLNT1C	SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif( lFLNT1C,( lFLNT1A := .F.,oCkFLNT1A:Refresh(),lFLNT1B := .F.,oCkFLNT1B:Refresh() ), )

lin += 15
@ lin,030 SAY OemToAnsi(STR0067) SIZE 228,010 OF oScrollBox PIXEL FONT oFont //"Submetido por IMDS ou por formato do cliente "

lin += 10
@ lin,030 SAY OemToAnsi(STR0068) SIZE 025,010 OF oScrollBox PIXEL FONT oFont //"Identificador"

@ lin,160 SAY OemToAnsi(STR0069) SIZE 015,010 OF oScrollBox PIXEL FONT oFont //"Versao"

@ lin,210 SAY OemToAnsi(STR0070) SIZE 060,010 OF oScrollBox PIXEL FONT oFont //"Data Submissao"

lin += 7
@ lin,030 MSGET oIMDSID VAR M->QKI_IMDSID PICTURE PesqPict("QKI", "QKI_IMDSID");
		   VALID CheckSX3("QKI_IMDSID",M->QKI_IMDSID) SIZE 120,005 OF oScrollBox PIXEL FONT oFont 
		   
@ lin,160 MSGET oIMDSVE VAR M->QKI_IMDSVE PICTURE PesqPict("QKI", "QKI_IMDSVE");
		   VALID CheckSX3("QKI_IMDSVE",M->QKI_IMDSVE) SIZE 030,005 OF oScrollBox PIXEL FONT oFont   
		   
@ lin,210 MSGET oIMDSDT VAR M->QKI_IMDSDT PICTURE PesqPict("QKI", "QKI_IMDSDT");
		   VALID CheckSX3("QKI_IMDSDT",M->QKI_IMDSDT) SIZE 060,005 OF oScrollBox PIXEL FONT oFont


lin += 15
@ lin,030 SAY OemToAnsi(STR0017) SIZE 228,010 OF oScrollBox PIXEL FONT oFont //"As pecas plasticas sao identificadas com os codigos adequados de marcacao ISO"

@ lin,267 CHECKBOX oCkFLNT2A VAR lFLNT2A	SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif( lFLNT2A,( lFLNT2B := .F.,oCkFLNT2B:Refresh(),lFLNT2C := .F.,oCkFLNT2C:Refresh() ), )

@ lin,282 CHECKBOX oCkFLNT2B VAR lFLNT2B	SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif( lFLNT2B,( lFLNT2A := .F.,oCkFLNT2A:Refresh(),lFLNT2C := .F.,oCkFLNT2C:Refresh() ), )
			 	 
@ lin,297 CHECKBOX oCkFLNT2C VAR lFLNT2C	SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif( lFLNT2C,( lFLNT2A := .F.,oCkFLNT2A:Refresh(),lFLNT2B := .F.,oCkFLNT2B:Refresh() ), )

lin += 5
@ lin,003 SAY REPLICATE(OemToAnsi("_"),150) SIZE 310,007 OF oScrollBox PIXEL FONT oFont

lin += 15
@ lin,110 SAY OemToAnsi(STR0018) SIZE 100,010 COLOR CLR_RED OF oScrollBox PIXEL; //"RAZAO PARA SUBMISSAO"
														FONT oFont
lin += 5
@ lin,003 CHECKBOX oCkFLRZSUA VAR lFLRZSUA SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLRZSUA,QPP220Opt1(aObjects1,1), )
       
@ lin,015 SAY OemToAnsi(STR0019) SIZE 068,010 OF oScrollBox PIXEL FONT oFont //"Submissao Inicial"

lin += 15

@ lin,003 CHECKBOX oCkFLRZSUB VAR lFLRZSUB SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLRZSUB,QPP220Opt1(aObjects1,2), )
       
@ lin,015 SAY OemToAnsi(STR0020) SIZE 096,010 OF oScrollBox PIXEL FONT oFont //"Alteracoes de Engenharia"

lin += 15
@ lin,003 CHECKBOX oCkFLRZSUC VAR lFLRZSUC SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLRZSUC,QPP220Opt1(aObjects1,3), )
       
@ lin,015 SAY OemToAnsi(STR0021) SIZE 240,010 OF oScrollBox PIXEL FONT oFont //"Ferramental: Transferencia, Reposicao, Reparo, ou Adicional"

lin += 15
@ lin,003 CHECKBOX oCkFLRZSUD VAR lFLRZSUD SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLRZSUD,QPP220Opt1(aObjects1,4), )
       
@ lin,015 SAY OemToAnsi(STR0022) SIZE 096,010 OF oScrollBox PIXEL FONT oFont //"Correcao de Discrepancia"

lin += 15
@ lin,003 CHECKBOX oCkFLRZSUE VAR lFLRZSUE SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLRZSUE,QPP220Opt1(aObjects1,5), )
       
@ lin,015 SAY OemToAnsi(STR0023) SIZE 148,010 OF oScrollBox PIXEL FONT oFont //"Ferramental Inativo por mais de 1 ano"

lin += 15
@ lin,003 CHECKBOX oCkFLRZSUF VAR lFLRZSUF SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLRZSUF,QPP220Opt1(aObjects1,6), )
       
@ lin,015 SAY OemToAnsi(STR0024) SIZE 180,010 OF oScrollBox PIXEL FONT oFont //"Alteracao de Material ou Construcao Opcional"

lin += 15
@ lin,003 CHECKBOX oCkFLRZSUG VAR lFLRZSUG SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLRZSUG,QPP220Opt1(aObjects1,7), )
       
@ lin,015 SAY OemToAnsi(STR0025) SIZE 188,010 OF oScrollBox PIXEL FONT oFont //"Alteracao do Subfornecedor ou Fonte do Material"

lin += 15
@ lin,003 CHECKBOX oCkFLRZSUH VAR lFLRZSUH SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLRZSUH,QPP220Opt1(aObjects1,8), )
       
@ lin,015 SAY OemToAnsi(STR0026) SIZE 172,010 OF oScrollBox PIXEL FONT oFont //"Alteracao do Processo de Fabricacao da Peca"

lin += 15
@ lin,003 CHECKBOX oCkFLRZSUI VAR lFLRZSUI SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLRZSUI,QPP220Opt1(aObjects1,9), )
       
@ lin,015 SAY OemToAnsi(STR0027) SIZE 144,010 OF oScrollBox PIXEL FONT oFont //"Pecas Produzidas em outra Localidade"

lin += 15
@ lin,003 CHECKBOX oCkFLRZSUJ VAR lFLRZSUJ SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLRZSUJ,(oOUTRO1:SetFocus(),QPP220Opt1(aObjects1,10)), )
       
@ lin,015 SAY OemToAnsi(STR0028) SIZE 088,010 OF oScrollBox PIXEL FONT oFont //"Outros - Especifique :"
@ lin,120 MSGET oOUTRO1 VAR M->QKI_OUTRO1 PICTURE PesqPict("QKI", "QKI_OUTRO1");
		   VALID CheckSX3("QKI_OUTRO1",M->QKI_OUTRO1) WHEN lFLRZSUJ;
		   SIZE 160,005 OF oScrollBox PIXEL FONT oFont

aObjects1 :=	{	oCkFLRZSUA, oCkFLRZSUB, oCkFLRZSUC, oCkFLRZSUD, oCkFLRZSUE,;
				oCkFLRZSUF, oCkFLRZSUG,oCkFLRZSUH, oCkFLRZSUI, oCkFLRZSUJ }

lin += 5           
@ lin,003 SAY REPLICATE(OemToAnsi("_"),150) SIZE 280,007 OF oScrollBox PIXEL FONT oFont

lin += 15
@ lin,110 SAY OemToAnsi(STR0029) SIZE 160,010 COLOR CLR_RED OF oScrollBox PIXEL; //"NIVEL DE SUBMISSAO REQUERIDO (Marque um)"
														FONT oFont			 	 

lin += 15
@ lin,003 CHECKBOX oCkFLNISU1 VAR lFLNISU1 SIZE 008,008 OF oScrollBox PIXEL;
	 	 ON CLICK Iif(lFLNISU1,QPP220Opt2(aObjects2,1), )
			 	   
@ lin,015 SAY OemToAnsi(STR0030) SIZE 280,010 OF oScrollBox PIXEL FONT oFont //"Nivel 1 - Certificado apenas(e para itens de aparencia designados, um Relatorio de Aprovacao de Aparencia) submetidos ao cliente."

lin += 15
@ lin,003 CHECKBOX oCkFLNISU2 VAR lFLNISU2 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLNISU2,QPP220Opt2(aObjects2,2), )
			 	   
@ lin,015 SAY OemToAnsi(STR0031) SIZE 280,010 OF oScrollBox PIXEL FONT oFont //"Nivel 2 - Certificado com amostras do produto e dados limitados de suporte submetidos ao cliente."

lin += 15
@ lin,003 CHECKBOX oCkFLNISU3 VAR lFLNISU3 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLNISU3,QPP220Opt2(aObjects2,3), )
			 	   
@ lin,015 SAY OemToAnsi(STR0032) SIZE 280,010 OF oScrollBox PIXEL FONT oFont //"Nivel 3 - Certificado com amostras do produto e todos os dados de suporte submetidos ao cliente."

lin += 15
@ lin,003 CHECKBOX oCkFLNISU4 VAR lFLNISU4 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLNISU4,QPP220Opt2(aObjects2,4), )
			 	   
@ lin,015 SAY OemToAnsi(STR0033) SIZE 280,010 OF oScrollBox PIXEL FONT oFont //"Nivel 4 - Certificado e outros requisitos conforme definido pelo cliente"

lin += 15
@ lin,003 CHECKBOX oCkFLNISU5 VAR lFLNISU5 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif(lFLNISU5,QPP220Opt2(aObjects2,5), )
			 	   
@ lin,015 SAY OemToAnsi(STR0034) SIZE 280,010 OF oScrollBox PIXEL FONT oFont //"Nivel 5 - Certificado com amostras do produto e todos os dados de suporte verificados na localidade de manufatura do fornecedor"

aObjects2 := { oCkFLNISU1, oCkFLNISU2, oCkFLNISU3, oCkFLNISU4, oCkFLNISU5 }

lin += 5
@ lin,003 SAY REPLICATE(OemToAnsi("_"),150) SIZE 280,007 OF oScrollBox PIXEL FONT oFont

lin += 15
@ lin,110 SAY OemToAnsi(STR0035) SIZE 100,010 COLOR CLR_RED OF oScrollBox PIXEL; //"RESULTADOS DA SUBMISSAO"
														FONT oFont			 	 
lin += 15
@ lin,003 SAY OemToAnsi(STR0036) SIZE 072,010 OF oScrollBox PIXEL FONT oFont //"Os resultados de :"

@ lin,080 CHECKBOX oCkRESDIM VAR lRESDIM SIZE 008,008 OF oScrollBox PIXEL
			 	 
@ lin,095 SAY OemToAnsi(STR0037) SIZE 084,010 OF oScrollBox PIXEL FONT oFont //"Medicoes Dimensionais"

lin += 15
@ lin,080 CHECKBOX oCkRESMAT VAR lRESMAT SIZE 008,008 OF oScrollBox PIXEL
			 	 
@ lin,095 SAY OemToAnsi(STR0038) SIZE 132,010 OF oScrollBox PIXEL FONT oFont //"Ensaios de Material e Funcionais"

lin += 15
@ lin,080 CHECKBOX oCkRESAPA VAR lRESAPA SIZE 008,008 OF oScrollBox PIXEL
			 	 
@ lin,095 SAY OemToAnsi(STR0039) SIZE 132,010 OF oScrollBox PIXEL FONT oFont //"Criterios de Aparencia"

lin += 15
@ lin,080 CHECKBOX oCkRESEST VAR lRESEST SIZE 008,008 OF oScrollBox PIXEL
			 	 
@ lin,095 SAY OemToAnsi(STR0040) SIZE 132,010 OF oScrollBox PIXEL FONT oFont //"Dados Estatisticos"

lin += 15          
@ lin,003 SAY OemToAnsi(STR0041) SIZE 180,010 OF oScrollBox PIXEL FONT oFont //"Atendem a todos os requisitos do desenho e de especificacoes :"



@ lin,150 CHECKBOX oCkREQUISA VAR lREQUISA SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif( lREQUISA,( lREQUISB := .F.,oCkREQUISB:Refresh()), )

@ lin,160 SAY OemToAnsi(STR0015) SIZE 100,200 OF oScrollBox PIXEL FONT oFont //"SIM"

@ lin,180 CHECKBOX oCkREQUISB VAR lREQUISB SIZE 008,008 OF oScrollBox PIXEL;
  			 	 ON CLICK Iif( lREQUISB,( lREQUISA := .F.,oCkREQUISA:Refresh()), )

@ lin,190 SAY OemToAnsi(STR0042) SIZE 150,150 OF oScrollBox PIXEL FONT oFont //"NAO     (Se 'Nao' - Explicacoes sao Necessarias)"

lin += 15
@ lin,003 SAY OemToAnsi(STR0043) SIZE 120,010 OF oScrollBox PIXEL FONT oFont //"Processo de Producao/Cavidade/Molde :"

@ lin,130 MSGET oMOLDE VAR M->QKI_MOLDE PICTURE PesqPict("QKI", "QKI_MOLDE");
  		   VALID CheckSX3("QKI_MOLDE",M->QKI_MOLDE) SIZE 160,005 OF oScrollBox PIXEL FONT oFont

lin += 5
@ lin,003 SAY REPLICATE(OemToAnsi("_"),150) SIZE 310,007 OF oScrollBox PIXEL FONT oFont

lin += 15
@ lin,110 SAY OemToAnsi(STR0044) SIZE 040,010 COLOR CLR_RED OF oScrollBox PIXEL; //"DECLARACAO"
														FONT oFont			 	 

lin += 15
@ lin,003 SAY OemToAnsi(STR0045) SIZE 072,010 OF oScrollBox PIXEL FONT oFont //"Taxa de Producao :"

@ lin,080 MSGET oTXPROD VAR M->QKI_TXPROD PICTURE PesqPict("QKI", "QKI_TXPROD");
		   VALID CheckSX3("QKI_TXPROD",M->QKI_TXPROD) SIZE 040,005 OF oScrollBox PIXEL FONT oFont

@ lin,195 SAY OemToAnsi(STR0075) SIZE 060,010 OF oScrollBox PIXEL FONT oFont //"Tempo"

@ lin,210 MSGET oTMPROD VAR M->QKI_TMPROD PICTURE PesqPict("QKI", "QKI_TMPROD");
		   VALID CheckSX3("QKI_TMPROD",M->QKI_TMPROD) SIZE 040,005 OF oScrollBox PIXEL FONT oFont 

lin += 15
@ lin,003 SAY OemToAnsi(STR0046) SIZE 108,100 OF oScrollBox PIXEL FONT oFont //"Explicacoes/Comentarios :"

cDesAud := MsMM(M->QKI_DESCHV,TamSx3("QKI_COMEN1")[1])
    @ lin,080 GET oCOMENT VAR cDesAud MEMO VALID CheckSX3("QKI_COMEN1",cDesAud); 
	WHEN VisualSX3("QKI_COMEN1")Size 240,060 Of oScrollBox NO VSCROLL Pixel FONT oFont

lin += 65
@ lin,003 SAY OemToAnsi(STR0047) SIZE 024,010 OF oScrollBox PIXEL FONT oFont //"Nome :"

@ lin,025 MSGET oMAT VAR M->QKI_MAT PICTURE PesqPict("QKI", "QKI_MAT");
			VALID CheckSX3("QKI_MAT",M->QKI_MAT) .and. ;
			(M->QKI_NOMAPR := Posicione("QAA",1,M->QKI_FILMAT+M->QKI_MAT,"QAA_NOME"),.T.) .and. ;
			(oNOMAPR:Refresh(),.T.) SIZE 040,005 ;
			ReadOnly F3 ConSX3("QKI_MAT") OF oScrollBox PIXEL FONT oFont

If nOpc == 3
	oMat:lReadOnly := .F.
Endif

If nOpc == 4 
	If Empty(M->QKI_MAT)
		oMat:lReadOnly			:= .F.
	Else
		DbSelectArea("QAA")
		DbSetOrder(1)
		If DbSeek(xFilial("QAA")+QKI->QKI_MAT) .and. UPPER(QAA->QAA_LOGIN) == UPPER(cUserName)
			oMat:lReadOnly			:= .F.
		Endif	
	Endif
Endif
@ lin,075 MSGET oNOMAPR VAR M->QKI_NOMAPR PICTURE PesqPict("QKI", "QKI_NOMAPR");
			VALID CheckSX3("QKI_NOMAPR",M->QKI_NOMAPR) WHEN Empty(M->QKI_MAT);
			SIZE 160,005 OF oScrollBox PIXEL FONT oFont

lin += 25

@ lin,003 SAY OemToAnsi(STR0050) SIZE 028,010 OF oScrollBox PIXEL FONT oFont //"Data :"

@ lin,025 MSGET oDTAPR VAR M->QKI_DTAPR SIZE 040,005 OF oScrollBox PIXEL FONT oFont

@ lin,075 SAY OemToAnsi(STR0049) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"Telefone :"

@ lin,105 MSGET oTELAPR VAR M->QKI_TELAPR PICTURE PesqPict("QKI", "QKI_TELAPR");
		   VALID CheckSX3("QKI_TELAPR",M->QKI_TELAPR) SIZE 080,005 OF oScrollBox PIXEL FONT oFont

@ lin,195 SAY OemToAnsi(STR0074) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"Fax :"

@ lin,215 MSGET oFAXAPR VAR M->QKI_FAXAPR PICTURE PesqPict("QKI", "QKI_FAXAPR");
		   VALID CheckSX3("QKI_FAXAPR",M->QKI_FAXAPR) SIZE 080,005 OF oScrollBox PIXEL FONT oFont

lin += 25
@ lin,003 SAY OemToAnsi(STR0048) SIZE 028,010 OF oScrollBox PIXEL FONT oFont //"Cargo :"

@ lin,025 MSGET oCARAPR VAR M->QKI_CARAPR PICTURE PesqPict("QKI", "QKI_CARAPR");
		   VALID CheckSX3("QKI_CARAPR",M->QKI_CARAPR) SIZE 190,005 OF oScrollBox PIXEL FONT oFont

lin += 25
@ lin,003 SAY OemToAnsi(STR0073) SIZE 040,010 OF oScrollBox PIXEL FONT oFont //"E-Mail :"

@ lin,025 MSGET oEMAAPR VAR M->QKI_EMAAPR PICTURE PesqPict("QKI", "QKI_EMAAPR");
		   VALID CheckSX3("QKI_EMAAPR",M->QKI_EMAAPR) SIZE 230,005 OF oScrollBox PIXEL FONT oFont

lin += 25
@ lin,003 SAY OemToAnsi(STR0072) SIZE 228,010 OF oScrollBox PIXEL FONT oFont //"Cada ferramenta do cliente foi corretamente etiquetada e numerada"

@ lin,170 SAY OemToAnsi(STR0015) SIZE 012,010 COLOR CLR_RED OF oScrollBox PIXEL FONT oFont //"Sim"
@ lin,215 SAY OemToAnsi(STR0016) SIZE 012,010 COLOR CLR_RED OF oScrollBox PIXEL FONT oFont //"Nao"
@ lin,260 SAY OemToAnsi(STR0083) SIZE 012,010 COLOR CLR_RED OF oScrollBox PIXEL FONT oFont //"N/A"

@ lin,185 CHECKBOX oCkCLIA VAR lFCLIA	SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif( lFCLIA,( lFCLIB := .F.,oCkCLIB:Refresh(),lFCLIC := .F.,oCkCLIC:Refresh() ), )

@ lin,230 CHECKBOX oCkCLIB VAR lFCLIB	SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif( lFCLIB,( lFCLIA := .F.,oCkCLIA:Refresh(),lFCLIC := .F.,oCkCLIC:Refresh() ), )
			 	 
@ lin,275 CHECKBOX oCkCLIC VAR lFCLIC	SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK Iif( lFCLIC,( lFCLIA := .F.,oCkCLIA:Refresh(),lFCLIB := .F.,oCkCLIB:Refresh() ), )
                                                                                      
lin += 5
@ lin,003 SAY REPLICATE(OemToAnsi("_"),150) SIZE 310,007 OF oScrollBox PIXEL FONT oFont

lin += 10
@ lin,100 SAY OemToAnsi(STR0051) SIZE 160,010 COLOR CLR_RED OF oScrollBox PIXEL; //"PARA USO DO CLIENTE APENAS (SE APLICAVEL)"
														FONT oFont

lin += 20
@ lin,003 SAY OemToAnsi(STR0052) SIZE 100,010 OF oScrollBox PIXEL FONT oFont //"Disposicao do Certificado da Peca :"

@ lin,115 CHECKBOX oCkDISCLI1 VAR lDISCLI1 SIZE 008,008 OF oScrollBox PIXEL;
			ON CLICK Iif( lDISCLI1,( lDISCLI2 := .F. , lDISCLI3 := .F.,; 
			oCkDISCLI1:Refresh(),oCkDISCLI2:Refresh(),oCkDISCLI3:Refresh()), )
			 	 
@ lin,125 SAY OemToAnsi(STR0053) SIZE 030,010 OF oScrollBox PIXEL FONT oFont //"Aprovado"

lin += 15
@ lin,115 CHECKBOX oCkDISCLI2 VAR lDISCLI2 SIZE 008,008 OF oScrollBox PIXEL;
			ON CLICK Iif( lDISCLI2,( lDISCLI1 := .F. , lDISCLI3 := .F.,; 
			oCkDISCLI1:Refresh(),oCkDISCLI2:Refresh(),oCkDISCLI3:Refresh()), )

@ lin,125 SAY OemToAnsi(STR0054) SIZE 030,010 OF oScrollBox PIXEL FONT oFont //"Rejeitado"

lin += 15
@ lin,115 CHECKBOX oCkDISCLI3 VAR lDISCLI3 SIZE 008,008 OF oScrollBox PIXEL;
			ON CLICK Iif( lDISCLI3,( lDISCLI1 := .F. , lDISCLI2 := .F.,; 
			oOUTRO2:SetFocus(),oCkDISCLI1:Refresh(),oCkDISCLI2:Refresh(),oCkDISCLI3:Refresh()), )
						 	 
@ lin,125 SAY OemToAnsi(STR0055) SIZE 020,010 OF oScrollBox PIXEL FONT oFont //"Outros"

@ lin,160 MSGET oOUTRO2 VAR M->QKI_OUTRO2 PICTURE PesqPict("QKI", "QKI_OUTRO2");
		   VALID CheckSX3("QKI_OUTRO2",M->QKI_OUTRO2) WHEN lDISCLI3;
		   SIZE 160,005 OF oScrollBox PIXEL FONT oFont
lin += 15
@ lin,003 SAY OemToAnsi(STR0050) SIZE 028,010 OF oScrollBox PIXEL FONT oFont //"Data :"

@ lin,035 MSGET oDTRCLI VAR M->QKI_DTRCLI SIZE 040,005 OF oScrollBox PIXEL FONT oFont

lin += 15
@ lin,003 SAY OemToAnsi(STR0058) SIZE 092,010 OF oScrollBox PIXEL FONT oFont //"Representante Cliente :"

@ lin,095 MSGET oREPCLI VAR M->QKI_REPCLI PICTURE PesqPict("QKI", "QKI_REPCLI");
		   VALID CheckSX3("QKI_REPCLI",M->QKI_REPCLI) SIZE 160,005 OF oScrollBox PIXEL FONT oFont

lin += 15
@ lin,003 SAY REPLICATE(OemToAnsi("_"),150) SIZE 310,007 OF oScrollBox PIXEL FONT oFont

lin += 10
@ lin,003 SAY OemToAnsi(STR0071) SIZE 088,010 OF oScrollBox PIXEL FONT oFont //"Marco 2006  CFG-1001"


If nOpc == 2 .or. nOpc == 5
	oCkSUBDIM:lReadOnly		:= .T.
	oCkSUBMAT:lReadOnly		:= .T.
	oCkSUBAPA:lReadOnly		:= .T.
	oCOMPRA:lReadOnly		:= .T.
	oOUTRO1:lReadOnly		:= .T.
	oCkFLNT1A:lReadOnly		:= .T.
	oCkFLNT1B:lReadOnly		:= .T. 
	oCkFLNT1C:lReadOnly		:= .T. 
	oCkCLIA:lReadOnly		:= .T.
	oCkCLIB:lReadOnly		:= .T.
	oCkCLIC:lReadOnly		:= .T.
	oCkFLNT2A:lReadOnly		:= .T.
	oCkFLNT2B:lReadOnly		:= .T.
	oCkFLNT2C:lReadOnly		:= .T.
	oCkFLRZSUA:lReadOnly	:= .T.
	oCkFLRZSUB:lReadOnly	:= .T.
	oCkFLRZSUC:lReadOnly	:= .T.
	oCkFLRZSUD:lReadOnly	:= .T.
    oCkFLRZSUE:lReadOnly	:= .T.
    oCkFLRZSUF:lReadOnly	:= .T.
    oCkFLRZSUG:lReadOnly	:= .T.
    oCkFLRZSUH:lReadOnly	:= .T.
    oCkFLRZSUI:lReadOnly	:= .T.
    oCkFLRZSUJ:lReadOnly	:= .T.
    oCkFLNISU1:lReadOnly	:= .T.
    oCkFLNISU2:lReadOnly	:= .T.
    oCkFLNISU3:lReadOnly	:= .T.
    oCkFLNISU4:lReadOnly	:= .T.
    oCkFLNISU5:lReadOnly	:= .T.
    oCkRESDIM:lReadOnly		:= .T.
    oCkRESMAT:lReadOnly		:= .T.
    oCkRESAPA:lReadOnly		:= .T.
    oCkRESEST:lReadOnly		:= .T.
    oCkREQUISA:lReadOnly	:= .T.
    oCkREQUISB:lReadOnly	:= .T.
    oMOLDE:lReadOnly		:= .T.
    oTXPROD:lReadOnly		:= .T.
    oCOMENT:lReadOnly		:= .T.
    oNOMAPR:lReadOnly		:= .T.
    oCARAPR:lReadOnly		:= .T.
    oTELAPR:lReadOnly		:= .T.
    oDTAPR:lReadOnly		:= .T.
    oCkDISCLI1:lReadOnly	:= .T.
    oCkDISCLI2:lReadOnly	:= .T.
    oCkDISCLI3:lReadOnly	:= .T.
    oOUTRO2:lReadOnly		:= .T.
    oREPCLI:lReadOnly		:= .T.
    oDTRCLI:lReadOnly		:= .T.
	oMat:lReadOnly			:= .T.
	oIMDSID:lReadOnly		:= .T.
	oIMDSVE:lReadOnly		:= .T.
	oIMDSDT:lReadOnly		:= .T.
	oTMPROD:lReadOnly		:= .T. 
	oFAXAPR:lReadOnly		:= .T.
	oEMAAPR:lReadOnly		:= .T.	
	SysRefresh()
Endif


Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP220Chec³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 13.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza conteudo das Variaveis                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP220Chec()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA220                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP220Chec()

lSUBDIM := Iif(M->QKI_SUBDIM == "1",.T.,.F.)
lSUBMAT := Iif(M->QKI_SUBMAT == "1",.T.,.F.)
lSUBAPA := Iif(M->QKI_SUBAPA == "1",.T.,.F.)

If nEdicao == 4
	lFCLIA := Iif(M->QKI_FERCLI == "1",.T.,.F.)
	lFCLIB := Iif(M->QKI_FERCLI == "2",.T.,.F.)
	lFCLIC := Iif(M->QKI_FERCLI == "3",.T.,.F.)
EndIf

lFLNT1A := Iif(M->QKI_FLNT1 == "1",.T.,.F.)
lFLNT1B	:= Iif(M->QKI_FLNT1 == "2",.T.,.F.)
lFLNT1C	:= Iif(M->QKI_FLNT1 == "3",.T.,.F.)

lFLNT2A := Iif(M->QKI_FLNT2 == "1",.T.,.F.)
lFLNT2B := Iif(M->QKI_FLNT2 == "2",.T.,.F.)
lFLNT2C := Iif(M->QKI_FLNT2 == "3",.T.,.F.)

If !Empty(M->QKI_FLRZSU)
	If "A" $ M->QKI_FLRZSU
		lFLRZSUA := .T.
	EndIf		
	IF "B" $ M->QKI_FLRZSU
		lFLRZSUB := .T.
	EndIF
    If"C" $ M->QKI_FLRZSU
		lFLRZSUC := .T.
	EndIf	
	If "D" $ M->QKI_FLRZSU
		lFLRZSUD := .T.
	EndIf
	If "E" $ M->QKI_FLRZSU
		lFLRZSUE := .T.
	EndIf
	If "F" $ M->QKI_FLRZSU
		lFLRZSUF := .T.
	EndIf
	If "G" $ M->QKI_FLRZSU
		lFLRZSUG := .T.
	EndIf
	If "H" $ M->QKI_FLRZSU
		lFLRZSUH := .T.
	EndIf
	If "I" $ M->QKI_FLRZSU
		lFLRZSUI := .T.
	EndIf
	If "J" $ M->QKI_FLRZSU
		lFLRZSUJ := .T.
	EndIf
Endif


If !Empty(M->QKI_FLNISU)
	Do Case
		Case M->QKI_FLNISU == "1"
			lFLNISU1 := .T.
		Case M->QKI_FLNISU == "2"
			lFLNISU2 := .T.
		Case M->QKI_FLNISU == "3"
			lFLNISU3 := .T.
		Case M->QKI_FLNISU == "4"
			lFLNISU4 := .T.
		Case M->QKI_FLNISU == "5"
			lFLNISU5 := .T.
	Endcase
Endif

lRESDIM := Iif(M->QKI_RESDIM == "1",.T.,.F.)
lRESMAT := Iif(M->QKI_RESMAT == "1",.T.,.F.)
lRESAPA := Iif(M->QKI_RESAPA == "1",.T.,.F.)
lRESEST := Iif(M->QKI_RESEST == "1",.T.,.F.)

lREQUISA := Iif(M->QKI_REQUIS == "1",.T.,.F.)
lREQUISB := Iif(M->QKI_REQUIS == "2",.T.,.F.)

lDISCLI1 := Iif(M->QKI_DISCLI == "1",.T.,.F.)
lDISCLI2 := Iif(M->QKI_DISCLI == "2",.T.,.F.)
lDISCLI3 := Iif(M->QKI_DISCLI == "3",.T.,.F.)

lAPRFUN1 := Iif(M->QKI_APRFUN == "1",.T.,.F.)
lAPRFUN2 := Iif(M->QKI_APRFUN == "2",.T.,.F.)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP220Opt1³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 14.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Controla opcoes da razao para submissao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP220Opt1(ExpA1, ExpN1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array contendo os objetos do check                 ³±±
±±³          ³ ExpN1 = Numero da variavel                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA220                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP220Opt1(aObjects1,nCheck)

//Local nCont
                
//lFLRZSUA := .F.
//lFLRZSUB := .F.; lFLRZSUC := .F.; lFLRZSUD := .F. 
//lFLRZSUE := .F.; lFLRZSUF := .F.; lFLRZSUG := .F. 
//lFLRZSUH := .F.; lFLRZSUI := .F.; lFLRZSUJ := .F. 

Do Case
	Case nCheck == 1 
		lFLRZSUA := .T.
	Case nCheck == 2
		lFLRZSUB := .T.
	Case nCheck == 3
		lFLRZSUC := .T.
	Case nCheck == 4
		lFLRZSUD := .T.
	Case nCheck == 5 
		lFLRZSUE := .T.
	Case nCheck == 6 
		lFLRZSUF := .T. 
	Case nCheck == 7 
		lFLRZSUG := .T. 
	Case nCheck == 8
		lFLRZSUH := .T.
	Case nCheck == 9 
		lFLRZSUI := .T. 
	Case nCheck == 10
		lFLRZSUJ := .T.
Endcase	

//For nCont := 1 To Len(aObjects1)
//	aObjects1[nCont]:Refresh()
//Next nCont                                                           

SysRefresh()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP220Opt2³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 14.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Controla opcoes do nivel de submissao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP220Opt2(ExpA1, ExpN1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array contendo os objetos do check                 ³±±
±±³          ³ ExpN1 = Numero da variavel                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA220                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP220Opt2(aObjects2,nCheck)

Local nCont

lFLNISU1 := .F. ; lFLNISU2 := .F.; lFLNISU3 := .F.
lFLNISU4 := .F. ; lFLNISU5 := .F.

Do Case
	Case nCheck == 1 
		lFLNISU1 := .T.
	Case nCheck == 2
		lFLNISU2 := .T.
	Case nCheck == 3
		lFLNISU3 := .T.
	Case nCheck == 4
		lFLNISU4 := .T.
	Case nCheck == 5 
		lFLNISU5 := .T.
Endcase	

For nCont := 1 To Len(aObjects2)
	aObjects2[nCont]:Refresh()
Next nCont

SysRefresh()

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA220Grav³ Autor ³ Robson Ramiro A Olivei³ Data ³ 16/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Gravacao do Certificado - Incl./Alter.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA220Grav(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA220                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA220Grav(nOpc)

Local nCont
Local bCampo		:= { |nCPO| Field(nCPO) }
Local lGraOk		:= .T.
Local cAtividade	:= "12 " // Definido no ID - QKZ
Local nSaveSX8		:= GetSX8Len()
Local cFLRZSU		:= ""
DbSelectArea("QKI")

Begin Transaction

If ALTERA
	RecLock("QKI",.F.)
Else	                   
	RecLock("QKI",.T.)
Endif

For nCont := 1 To FCount()
	If "FILIAL"$Field(nCont)
		FieldPut(nCont,xFilial("QKI"))
    Else
		FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
	Endif
Next nCont

QKI->QKI_FILIAL := xFilial("QKI")  
QKI->QKI_REVINV	:= Inverte(M->QKI_REV)

If Empty(cChave)
	cChave := GetSXENum("QKI", "QKI_CHAVE",,3)
	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End
	QKI->QKI_CHAVE	:= cChave
Endif

QKI->QKI_FILMAT := cFilAnt
QKI->QKI_SUBDIM := Iif(lSUBDIM ,"1","2")
QKI->QKI_SUBMAT := Iif(lSUBMAT ,"1","2")     
QKI->QKI_SUBAPA := Iif(lSUBAPA ,"1","2")
QKI->QKI_FLNT1  := Iif(lFLNT1A ,"1",Iif(lFLNT1B,"2",Iif(lFLNT1C,"3"," ")))
If nEdicao == 4
	QKI->QKI_FERCLI  := Iif(lFCLIA ,"1",Iif(lFCLIB,"2",Iif(lFCLIC,"3"," ")))
EndIf
QKI->QKI_FLNT2  := Iif(lFLNT2A ,"1",Iif(lFLNT2B,"2",Iif(lFLNT2C,"3"," ")))  


if lFLRZSUA
	cFLRZSU	:= cFLRZSU + "A"
EndIf
if lFLRZSUB
	cFLRZSU	:= cFLRZSU + "B"
EndIF
IF lFLRZSUC
	cFLRZSU	:= cFLRZSU + "C"
EndIF
IF lFLRZSUD
	cFLRZSU	:= cFLRZSU + "D"
EndIF
IF lFLRZSUE
	cFLRZSU	:= cFLRZSU + "E"
EndIF
IF lFLRZSUF
	cFLRZSU	:= cFLRZSU + "F"
EndIF
IF lFLRZSUG
	cFLRZSU	:= cFLRZSU + "G"
EndIF
IF lFLRZSUH
	cFLRZSU	:= cFLRZSU + "H"
EndIF
IF lFLRZSUI
	cFLRZSU	:= cFLRZSU + "I"
EndIF
IF lFLRZSUJ
	cFLRZSU	:= cFLRZSU + "J"
EndIF  

if !lFLRZSUA .AND. !lFLRZSUB .AND. !lFLRZSUC .AND. !lFLRZSUD .AND. !lFLRZSUE .AND. ; 
   !lFLRZSUF .AND. !lFLRZSUG .AND. !lFLRZSUH .AND. !lFLRZSUI .AND. !lFLRZSUJ
	lGraOk := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios	
EndIF  

QKI->QKI_FLRZSU := cFLRZSU

QKI->QKI_OUTRO1 := Iif(lFLRZSUJ,M->QKI_OUTRO1,Space(40))

Do Case
	Case lFLNISU1
		QKI->QKI_FLNISU := "1"
	Case lFLNISU2
		QKI->QKI_FLNISU := "2"
	Case lFLNISU3
		QKI->QKI_FLNISU := "3"
	Case lFLNISU4
		QKI->QKI_FLNISU := "4"
	Case lFLNISU5
		QKI->QKI_FLNISU := "5"
	OtherWise
		QKI->QKI_FLNISU := " "
Endcase

QKI->QKI_RESDIM := Iif(lRESDIM,"1","2")
QKI->QKI_RESMAT := Iif(lRESMAT,"1","2")
QKI->QKI_RESAPA := Iif(lRESAPA,"1","2")
QKI->QKI_RESEST := Iif(lRESEST,"1","2")

QKI->QKI_REQUIS := Iif (lREQUISA,"1",Iif(lREQUISB,"2"," "))

QKI->QKI_DISCLI := Iif (lDISCLI1,"1",Iif(lDISCLI2,"2",Iif(lDISCLI3,"3"," ")))

QKI->QKI_OUTRO2 := Iif(lDISCLI3,M->QKI_OUTRO2,Space(40))

QKI->QKI_APRFUN := Iif (lAPRFUN1,"1",Iif(lAPRFUN2,"2"," "))

MsUnLock()
FkCommit()

MsMM(,TamSX3("QKI_COMEN1")[1],,cDesAud,1,,,"QKI","QKI_DESCHV")              
	
End Transaction

If !Empty(QKI->QKI_DTAPR) .and. !Empty(QKI->QKI_NOMAPR)
	QPP_CRONO(QKI->QKI_PECA,QKI->QKI_REV,cAtividade) // QPPXFUN - Atualiza Cronograma
Endif
				
Return lGraOk

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PP220TudOk ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 16.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para inclusao/alteracao geral                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP220TudOk                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QPPA220                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PP220TudOk

Local lRetorno	:= .T.

If Empty(M->QKI_PECA) .or. Empty(M->QKI_REV)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
Endif

If INCLUI
	If !ExistChav("QKI",M->QKI_PECA+M->QKI_REV)
		lRetorno := .F.
		Help(" ",1,"JAGRAVADO")  // Campo ja Existe
	Endif
	If !ExistCpo("QK1",M->QKI_PECA+M->QKI_REV)
		lRetorno := .F.
		Help(" ",1,"REGNOIS")  // Nao existe amarracao
	Endif
Endif

Return lRetorno


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A220Dele ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 17/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fucao para exclusao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A220Dele()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA220                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A220Dele()

DbSelectArea("QKI")

Begin Transaction

RecLock("QKI",.F.)
DbDelete()
MsUnLock()
		
End Transaction

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPP220OBSE³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 19.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastra Observacoes                        				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPP220OBSE(ExpN1)                               			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA220													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP220OBSE(nOpc)

Local cCabec := ""
Local cTitulo 	:= OemToAnsi(STR0060) //"Observacoes"
Local nTamLin 	:= TamSX3("QKO_TEXTO")[1]
Local cEspecie 	:= "QPPA220 "   //Para gravacao de textos
Local lEdit		:= .F.
Local cInf		:= ""
Local nSaveSX8	:= GetSX8Len()

If nOpc == 3 .or. nOpc == 4
	lEdit := .T.
Endif

axTextos	:= {} 	//Vetor que contem os textos dos Produtos
cCabec		:= OemToAnsi(STR0061) //"Texto da Observacao"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera/obtem a chave de ligacao com o texto da Peca/Rv     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(M->QKI_CHAVE)
	cChave := GetSXENum("QKI", "QKI_CHAVE",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

	M->QKI_CHAVE := cChave
Else
	cChave := M->QKI_CHAVE
Endif
                                              
cInf := AllTrim(M->QKI_PECA) + "  " + M->QKI_REV

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Digita a Observacao da Peca    							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If QO_TEXTO(cChave,cEspecie,nTamlin,cTitulo,cInf, @axtextos,1,cCabec,lEdit)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Texto da Peca no QKO							     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QO_GrvTxt(cChave,cEspecie,1,@axTextos) 	//QPPXFUN
Endif

DbSelectArea("QKI")
DbSetOrder(1)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QPPA220   ºAutor  ³Renata Cavalcante   º Data ³  08/01/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação para permitir ou não a alteração                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Validação para permitir ou não a alteração                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Q220VldAlt()

Local aArea 	:= {}
Local lReturn	:= .T.

aArea 	:= GetArea()

DbSelectArea("QK1")
DbSetOrder(1)
DbSeek(xFilial("QK1")+ QKI->QKI_PECA + QKI->QKI_REV)

If QK1->QK1_STATUS <> "1"
	Alert(STR0001) //"O processo deve estar em aberto para ser alterado !"
	lReturn := .F.
Endif

If !Empty(QKI->QKI_MAT)  
	DbSelectArea("QAA")
	DbSetOrder(1)
	If DbSeek(xFilial("QAA")+QKI->QKI_MAT) .and. UPPER(QAA->QAA_LOGIN) <> UPPER(cUserName)
		If QA_SitFolh()
			messagedlg(STR0076) //"O usuário logado não é o declarante, para alteração deverá estar logado com o usuário declarante"
			lReturn:= .F. 
		Else
			DbSelectArea("QAA")
			DbSetOrder(6)
			If DbSeek(UPPER(Subs(cUsuario,7,15))) 
				messagedlg(STR0077) //"O usuário logado não é o declarante, mas esse usuário está inativo,será permitida a alteração por outro usuário"
				lReturn:= .T.
			Else
				messagedlg(STR0078)//"O usuário logado não está cadastrado no cadastro de usuários do módulo")
			    lReturn:= .F.
			Endif
		Endif
	Endif
	
Endif

RestArea(aArea)   
Return(lReturn)                                          


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QPPA220   ºAutor  ³Microsiga           º Data ³  08/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação para permitir ou não a Exclusão                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Validação para permitir ou não a Exclusão                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q220VldExc(cRev,cAprov)

Local aArea 	:= {}
Local lReturn	:= .T.

aArea 	:= GetArea()

DbSelectArea("QK1")
DbSetOrder(1)
DbSeek(xFilial("QK1")+ QKI->QKI_PECA + QKI->QKI_REV)


If !Empty(QKI->QKI_MAT)  
	DbSelectArea("QAA")
	DbSetOrder(1)
	If DbSeek(xFilial("QAA")+QKI->QKI_MAT) .and. UPPER(QAA->QAA_LOGIN) <> UPPER(cUserName)
		If QA_SitFolh()
			messagedlg(STR0079) //"O usuário logado não é o declarante, para exclusão deverá estar logado com o usuário declarante"
			lReturn:= .F. 
		Else
			DbSelectArea("QAA")
			DbSetOrder(6)
			If DbSeek(UPPER(Subs(cUsuario,7,15))) 
				messagedlg(STR0080) //"O usuário logado não é o declarante, mas esse usuário está inativo,será permitida a exclusão por outro usuário"
				lReturn:= .T.
			Else
				messagedlg(STR0078)//"O usuário logado não está cadastrado no cadastro de usuários do módulo")
			    lReturn:= .F.
			Endif
		Endif
	Endif
	
Endif

RestArea(aArea)

Return lReturn
