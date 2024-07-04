#INCLUDE "QPPA010.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE _CRLF CHR(13)+CHR(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA010  ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 23.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cadastro de Pecas                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA010(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPPAP                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Robson Ramiro³01/10/01³      ³ Alteracao no conceito de LIE/LSE       ³±±
±±³ Robson Ramiro³19/02/02³VERSAO³ Retirada dos ajustes 609 x 710         ³±±
±±³              ³        ³      ³ Retirada da funcao QPPA010LSE          ³±±
±±³ Robson Ramiro³16/07/02³      ³ Reorganizacao por ordem de Caracterist.³±±
±±³ Robson Ramiro³06/08/02³XMETA ³ Funcao para validacao do numero PPAP   ³±±
±±³              ³        ³      ³ Funcao para visualizacao de arquivos   ³±±
±±³              ³        ³      ³ Campo para conf. do bitmap usado       ³±±
±±³              ³        ³      ³ Rotina para manipulacao do PPAP        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()

Local aRotina := {}

aRotina := {{ OemToAnsi(STR0001), "AxPesqui"  ,	0, 1,,.F.},; //"Pesquisar"
			{ OemToAnsi(STR0002), "PPA010Visu",	0, 2},; //"Visualizar"
			{ OemToAnsi(STR0003), "PPA010Incl",	0, 3},; //"Incluir"
			{ OemToAnsi(STR0004), "PPA010Alte",	0, 4},; //"Alterar"
			{ OemToAnsi(STR0005), "PPA010Excl",	0, 5},; //"Excluir"
			{ OemToAnsi(STR0029), "PPA010Mani",	0, 6},; //"Manipula"
			{ OemToAnsi(STR0010), "PPA010Lege",	0, 7,,.F.},;	//"Legenda"
			{ OemToAnsi(STR0067), "QPPR040(.T.,QK1->QK1_PECA+QK1_REV)", 0, 8},;	//"Imp Eq Mult"
			{ OemToAnsi(STR0079), "MsDocument", 0 , 4}} //"Conhecimento"

Return aRotina

Function QPPA010

Local aCores := {	{ '!(QK1->QK1_STATUS $ "1234")' ,'BR_BRANCO'		},;//Sem situacao
					{ 'QK1->QK1_STATUS == "1"' 		,'BR_VERDE'		},;//PPAP aberto
					{ 'QK1->QK1_STATUS == "2"' 		,'BR_VERMELHO'	},;	//PPAP fechado
					{ 'QK1->QK1_STATUS == "3"' 		,'BR_CINZA'		},;	//Revisao Nao Vigente
					{ 'QK1->QK1_STATUS == "4"' 		,'BR_PRETO' 	}}	//PPAP rejeitado

Private nEdicao := Val(GetMv("MV_QPPAPED",.T.,"3"))// Indica a Edicao do PPAP default 3 Edicao
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro	:= OemToAnsi(STR0006) //"Cadastro de Pecas"											
Private lInteg		:= .F.
Private lDelCaract := .F. //Valida se permite deleção da caracteristica 

Private aRotina := MenuDef()

DbSelectArea("QK1")
DbSetOrder(1)

mBrowse( 6, 1, 22, 75,"QK1",,,,,,aCores)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA010Visu  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³23.07.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Visualizacao de Pecas Incluidas                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA010Visu(ExpC1,ExpN1,ExpN2)                           ³±±
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
Function PPA010Visu(cAlias,nReg,nOpc)
Local oDlg		:= NIL
Local aButtons	:= {}
Local oPanel1
Local oPanel2
Local oEnch
Local aObjects  	:= {}
Local aSize   	:= MsAdvSize(.T.)
Local aInfo     	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }  
Local aPosObj   	:= {}

Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL
Private	cPathCli 	:= Alltrim(GetMV("MV_PPATCLI"))

DbSelectArea(cAlias)

RegToMemory("QK1",.F.)

AAdd( aObjects, { 100, 60, .T., .T. } ) // Dados da Enchoice 
AAdd( aObjects, { 100, 40, .T., .T. } ) // Getdados 
aPosObj:= MsObjSize( aInfo, aObjects, .T. ,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) ;  //"Cadastro de Peças"
						FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL

oPanel1:= tPanel():New(000,000,,oDlg,,,,,,100,aPosObj[1,3])
oPanel2:= tPanel():New(000,000,,oDlg,,,,,,100,aPosObj[2,3]/2)

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnch := MsmGet():New( "QK1", nReg, nOpc,,,,,aPosObj[1], , , , , ,oPanel1, ,.F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PP10Ahead("QK2")
nUsado	:= Len(aHeader)
PP10Acols(nOpc)

If nEdicao == 3
	aButtons := { 	{"BMPINCLUIR",	{ || QPPA010BMP(nOpc) },	OemToAnsi(STR0011), OemToAnsi(STR0061)},; 	//"Escolha a Caracteristica"###"Caract."
					{"PROJETPMS",	{ || QPPA010DOC() },		OemToAnsi(STR0015),	OemToAnsi(STR0062)},; 	//"Visualiza Arquivo"###"Visuali"
					{"BMPUSER",		{ || QPPR040(.T.,QK1->QK1_PECA+QK1_REV) },		OemToAnsi(STR0068), OemToAnsi(STR0067)}} //"Eq. Multifuncional"###"Imp Eq Mult"
Else	
	aButtons := { 	{"BMPINCLUIR",	{ || QPPA010BMP(nOpc) },	OemToAnsi(STR0011), OemToAnsi(STR0061)},; 	//"Escolha a Caracteristica"###"Caract."
					{"PROJETPMS",	{ || QPPA010DOC() },		OemToAnsi(STR0015),	OemToAnsi(STR0062)},;
					{"RELATORIO", 	{ || QPP140COND(nOpc) },	OemToAnsi(STR0080), OemToAnsi(STR0081)},;	//"Condicoes de Teste"###"Con Tst"
					{"BMPUSER",		{ || QPPR040(.T.,QK1->QK1_PECA+QK1_REV) },		OemToAnsi(STR0068), OemToAnsi(STR0067)}} //"Eq. Multifuncional"###"Imp Eq Mult"					
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet := MSGetDados():New(90,03,190,332, nOpc,"AllwaysTrue","AllwaysTrue","+QK2_ITEM",.T.,,,,,,,,,oPanel2)

oEnch:oBox:Align   := CONTROL_ALIGN_ALLCLIENT
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT   

dbselectarea('QK1') 		// posicionamento para funcionar a opção imprimir (frame)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}, ,aButtons) 

If File(cPathCli + AllTrim(M->QK1_DOC))
	fErase(cPathCli + AllTrim(M->QK1_DOC))
Endif

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA010Incl  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³23.07.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Inclusao de Pecas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA010Incl(ExpC1,ExpN1,ExpN2)                           ³±±
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
Function PPA010Incl(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local lOk 		:= .F.
Local aButtons	:= {}
Local nTamGet	:= QPPTAMGET("QK2_ITEM",1)
Local oPanel1
Local oPanel2
Local oEnch
Local aObjects  	:= {}
Local aSize   	:= MsAdvSize(.T.)
Local aInfo     	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }  
Local aPosObj   	:= {}

Private aCols      := {}
Private aHeader    := {}
Private cPathCli   := Alltrim(GetMV("MV_PPATCLI"))
Private lDelCaract := .F. //Valida se permite deleção da caracteristica 
Private nUsado     := 0
Private oGet       := NIL

DbSelectArea(cAlias)

RegToMemory("QK1",.T.)	

AAdd( aObjects, { 100, 60, .T., .T. } ) // Dados da Enchoice 
AAdd( aObjects, { 100, 40, .T., .T. } ) // Getdados 
aPosObj:= MsObjSize( aInfo, aObjects, .T. ,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) ;  //"Cadastro de Peças"
						FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL

oPanel1:= tPanel():New(000,000,,oDlg,,,,,,100,aPosObj[1,3])
oPanel2:= tPanel():New(000,000,,oDlg,,,,,,100,aPosObj[2,3]/2)

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnch := MsmGet():New( "QK1", nReg, nOpc,,,,,aPosObj[1], , 3, , , ,oPanel1, ,.F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PP10Ahead("QK2")
nUsado	:= Len(aHeader)
PP10Acols(nOpc)
                                       
DbSelectArea("QK2")						

If nEdicao == 3
	aButtons := { 	{"BMPINCLUIR",	{ || QPPA010BMP(nOpc) },	OemToAnsi(STR0011), OemToAnsi(STR0061)},; 	//"Escolha a Caracteristica"###"Caract."
					{"PROJETPMS",	{ || QPPA010DOC() },		OemToAnsi(STR0015), OemToAnsi(STR0062)},; 	//"Visualiza Arquivo"###"Visuali"
					{"NOTE",	{ || QPPA010DUP() },		OemToAnsi(STR0075), OemToAnsi(STR0076)}}   //"Duplicar Caracteristicas"###"Duplica"
Else	
	aButtons := { 	{"BMPINCLUIR",	{ || QPPA010BMP(nOpc) },	OemToAnsi(STR0011), OemToAnsi(STR0061)},; 	//"Escolha a Caracteristica"###"Caract."
					{"PROJETPMS",	{ || QPPA010DOC() },		OemToAnsi(STR0015), OemToAnsi(STR0062)},; 	//"Visualiza Arquivo"###"Visuali"
					{"RELATORIO", 	{ || QPP140COND(nOpc) },	OemToAnsi(STR0080), OemToAnsi(STR0081)},;	//"Condicoes de Teste"###"Con Tst"
					{"NOTE",	{ || QPPA010DUP() },		OemToAnsi(STR0075), OemToAnsi(STR0076)}}   //"Duplicar Caracteristicas"###"Duplica"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet    := MSGetDados():New(137,03,300,675, nOpc,"PP10LinOk","PP10TudOk","+QK2_ITEM",.T.,,,,nTamGet,,,,,oPanel2)

oEnch:oBox:Align   := CONTROL_ALIGN_ALLCLIENT
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP10TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, ,aButtons) 

If lOk
	A010Grav(nOpc)
Endif

If File(cPathCli + AllTrim(M->QK1_DOC))
	fErase(cPathCli + AllTrim(M->QK1_DOC))
Endif

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA010Alte  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³24.07.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Alteracao de Pecas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA010Alte(ExpC1,ExpN1,ExpN2)                           ³±±
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
Function PPA010Alte(cAlias,nReg,nOpc)

Local aButtons := {}
Local aSize    := MsAdvSize(.T.)
Local aInfo    :={aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3}
Local aObjects := {}
Local aPosObj  := {}
Local cTpProA  := ""
Local lOk      := .F.
Local nTamGet  := QPPTAMGET("QK2_ITEM",1)
Local oDlg     := NIL
Local oEnch    := NIL
Local oPanel1  := NIL
Local oPanel2  := NIL

Private aCols      := {}
Private aHeader    := {}
Private cPathCli   := Alltrim(GetMV("MV_PPATCLI"))
Private lDelCaract := .F. //Valida se permite deleção da caracteristica 
Private nUsado     := 0
Private oGet       := NIL

If !QPPVldAlt(QK1->QK1_PECA,QK1->QK1_REV)
	Return
Endif

If cAlias == "QK1"
	dbSelectArea("QKL")
	QKL->(DbSetOrder(1))
	If QKL->(DBSeek(xFilial("QKL")+QK1->QK1_PECA+QK1->QK1_REV))
		While QKL->(!EOF()) .AND. QKL->(QKL_FILIAL+QKL_PECA+QKL_REV) == xFilial("QKL")+QK1->(QK1_PECA+QK1->QK1_REV)
			IF nReg > 0 
				IF QKL->QKL_TPPRO > cTpProA
					If !Empty(AllTrim(cTpProA))
						//#Atenção
						//#Peça se encontra bloqueado pois já existe para a mesma peça/revisão uma outra fase de produção.	
						Help(NIL, NIL, STR0084, NIL, STR0088, 1, 0, NIL, NIL, NIL, NIL, NIL, {""}) 
						PPA010Visu(cAlias,nReg,2)
						Return()
					EndIf
				EndIf
			EndIf
			cTpProA := QKL->QKL_TPPRO
			nReg ++
			QKL->(DbSkip())
		ENDDO
	EndIf
EndIf

If QK1->QK1_STATUS <> "1"
	Alert(STR0030) //"Somente um processo em aberto pode ser alterado !"
	Return
Endif

RegToMemory("QK1",.F.)

AAdd( aObjects, { 100, 60, .T., .T. } ) // Dados da Enchoice 
AAdd( aObjects, { 100, 40, .T., .T. } ) // Getdados 
aPosObj:= MsObjSize( aInfo, aObjects, .T. ,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) ;  //"Cadastro de Peças"
						FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL

oPanel1:= tPanel():New(000,000,,oDlg,,,,,,100,aPosObj[1,3])
oPanel2:= tPanel():New(000,000,,oDlg,,,,,,100,aPosObj[2,3]/2)

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnch := MsmGet():New( "QK1", nReg, nOpc,,,,,aPosObj[1], , , , , ,oPanel1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PP10Ahead("QK2")
nUsado	:= Len(aHeader)
PP10Acols(nOpc)                                     
DbSelectArea("QK2")

If nEdicao == 3
	aButtons := { 	{"BMPINCLUIR",	{ || QPPA010BMP(nOpc) },	OemToAnsi(STR0011), OemToAnsi(STR0061)},; 	//"Escolha a Caracteristica"###"Caract."
					{"PROJETPMS",	{ || QPPA010DOC() },		OemToAnsi(STR0015), OemToAnsi(STR0062)},; 	//"Visualiza Arquivo"###"Visuali"
					{"NOTE",	{ || QPPA010DUP() },		OemToAnsi(STR0075), OemToAnsi(STR0076)}}   //"Duplica Caracteristicas"###"Duplica"
Else	
	aButtons := { 	{"BMPINCLUIR",	{ || QPPA010BMP(nOpc) },	OemToAnsi(STR0011), OemToAnsi(STR0061)},; 	//"Escolha a Caracteristica"###"Caract."
					{"PROJETPMS",	{ || QPPA010DOC() },		OemToAnsi(STR0015), OemToAnsi(STR0062)},; 	//"Visualiza Arquivo"###"Visuali"
					{"RELATORIO", 	{ || QPP140COND(nOpc) },	OemToAnsi(STR0080), OemToAnsi(STR0081)},;	//"Condicoes de Teste"###"Con Tst"
					{"NOTE",	{ || QPPA010DUP() },		OemToAnsi(STR0075), OemToAnsi(STR0076)}}   //"Duplica Caracteristicas"###"Duplica"
EndIf
				
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet := MSGetDados():New(137,03,300,675, nOpc,"PP10LinOk","PP10TudOk","+QK2_ITEM",.T.,,,,nTamGet,,,,,oPanel2) 

oEnch:oBox:Align        := CONTROL_ALIGN_ALLCLIENT
oGet:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT
oGet:oBrowse:blDblClick := {|| fQPA010Edt(oGet)} // Valida se Permite ou não a edição da Linha
oGet:oBrowse:bAdd       := {|| fQPA010Inc(oGet)} // Valida se Permite ou não a inclusão de Linhas
oGet:oBrowse:bDelete    := {|| fQPA010Del(oGet)} // Valida se Permite ou não a deleção das Linhas

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP10TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, ,aButtons) 

If lOk
	A010Grav(nOpc)
Endif

If File(cPathCli + AllTrim(M->QK1_DOC))
	fErase(cPathCli + AllTrim(M->QK1_DOC))
Endif

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA010Excl  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³24.07.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Exclusao de Pecas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA010Excl(ExpC1,ExpN1,ExpN2)                                ³±±
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
Function PPA010Excl(cAlias,nReg,nOpc)
Local oDlg		:= NIL
Local aButtons	:= {}
Local lOk		:= .F.
Local oPanel1
Local oPanel2
Local oEnch
Local aObjects  	:= {}
Local aSize   	:= MsAdvSize(.T.)
Local aInfo     	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }  
Local aPosObj   	:= {}

Private aCols      := {}
Private aHeader    := {}
Private cPathCli   := Alltrim(GetMV("MV_PPATCLI"))
Private lDelCaract := .F. //Valida se permite deleção da caracteristica 
Private nUsado     := 0
Private oGet       := NIL

DbSelectArea(cAlias)

RegToMemory("QK1",.F.)

AAdd( aObjects, { 100, 60, .T., .T. } ) // Dados da Enchoice 
AAdd( aObjects, { 100, 40, .T., .T. } ) // Getdados 
aPosObj:= MsObjSize( aInfo, aObjects, .T. ,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) ;  //"Cadastro de Peças"
						FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL

oPanel1:= tPanel():New(000,000,,oDlg,,,,,,100,aPosObj[1,3])
oPanel2:= tPanel():New(000,000,,oDlg,,,,,,100,aPosObj[2,3]/2)

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnch := MsmGet():New( "QK1", nReg, nOpc,,,,,aPosObj[1], , , , , ,oPanel1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PP10Ahead("QK2")
nUsado	:= Len(aHeader)
PP10Acols(nOpc)

If nEdicao == 3
	aButtons := { 	{"BMPINCLUIR",	{ || QPPA010BMP(nOpc) },	OemToAnsi(STR0011), OemToAnsi(STR0061)},; 	//"Escolha a Caracteristica"###"Caract."
					{"PROJETPMS",	{ || QPPA010DOC() },		OemToAnsi(STR0015),	OemToAnsi(STR0062)},; 	//"Visualiza Arquivo"###"Visuali"
					{"BMPUSER",		{ || QPPR040(.T.,QK1->QK1_PECA+QK1_REV) },		OemToAnsi(STR0068), OemToAnsi(STR0067)}} //"Eq. Multifuncional"###"Imp Eq Mult"
Else	
	aButtons := { 	{"BMPINCLUIR",	{ || QPPA010BMP(nOpc) },	OemToAnsi(STR0011), OemToAnsi(STR0061)},; 	//"Escolha a Caracteristica"###"Caract."
					{"PROJETPMS",	{ || QPPA010DOC() },		OemToAnsi(STR0015),	OemToAnsi(STR0062)},; 	//"Visualiza Arquivo"###"Visuali"
					{"RELATORIO", 	{ || QPP140COND(nOpc) },	OemToAnsi(STR0080), OemToAnsi(STR0081)},;	//"Condicoes de Teste"###"Con Tst"
					{"BMPUSER",		{ || QPPR040(.T.,QK1->QK1_PECA+QK1_REV) },		OemToAnsi(STR0068), OemToAnsi(STR0067)}} //"Eq. Multifuncional"###"Imp Eq Mult"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet := MSGetDados():New(90,03,190,332, nOpc,"AllwaysTrue","PPA010Chec","+QK2_ITEM",.T.,,,,,,,,,oPanel2) 

oEnch:oBox:Align   := CONTROL_ALIGN_ALLCLIENT
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT


ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PPA010Chec(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, ,aButtons) CENTERED

If lOk
	A010Dele()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui a amarracao com os conhecimentos                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsDocument( Alias(), RecNo(), 2, , 3 ) 
Endif

If File(cPathCli + AllTrim(M->QK1_DOC))
	fErase(cPathCli + AllTrim(M->QK1_DOC))
Endif

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PP10Acols³ Autor ³ Robson Ramiro A. Olive³ Data ³ 23/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega vetor aCols para a GetDados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q010Acols()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PP10Acols(nOpc)
Local nI, nPos

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

	nPos			:= aScan(aHeader,{ |x| AllTrim(x[2])== "QK2_ITEM" })
	aCols[1,nPos]	:= StrZero(1,Len(aCols[1,nPos]))
	
	aCols[1,nUsado+1] := .F.	

Else
	
	DbSelectArea("QK2")
	DbSetOrder(1)
	DbSeek(xFilial()+QK1->QK1_PECA+QK1->QK1_REV)

		while QK2->(!Eof()) .and. xFilial() == QK1->QK1_FILIAL .and. QK2->QK2_PECA+QK2->QK2_REV == QK1->QK1_PECA+QK1->QK1_REV

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
±±³Funcao    ³ PP10Ahead³ Autor ³ Robson Ramiro A. Olive³ Data ³ 17/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Ahead para aCols                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP10Ahead()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PP10Ahead(cAlias)

Local aStruAlias := FWFormStruct(3, cAlias)[3]
Local nX

aHeader := {}
nUsado 	:= 0

For nX := 1 To Len(aStruAlias)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ignora campos que nao devem aparecer na getdados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If 	Upper(AllTrim(aStruAlias[nX,1])) == "QK2_PECA" .or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QK2_REV"
		Loop
	Endif

	If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL")
		nUsado++
 		aAdd(aHeader,{ Trim(QAGetX3Tit(aStruAlias[nX,1])), ;
 						GetSx3Cache(aStruAlias[nX,1], "X3_CAMPO"),   ;
 						GetSx3Cache(aStruAlias[nX,1], "X3_PICTURE"), ;
						GetSx3Cache(aStruAlias[nX,1], "X3_TAMANHO"), ;
						GetSx3Cache(aStruAlias[nX,1], "X3_DECIMAL"), ;
						GetSx3Cache(aStruAlias[nX,1], "X3_VALID"),   ;
						GetSx3Cache(aStruAlias[nX,1], "X3_USADO"),   ;
						GetSx3Cache(aStruAlias[nX,1], "X3_TIPO"),    ;
						GetSx3Cache(aStruAlias[nX,1], "X3_ARQUIVO"), ;
						GetSx3Cache(aStruAlias[nX,1], "X3_CONTEXT") })
	Endif
Next nX

Return



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A010Grav ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 24/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Gravacao das Pecas - Incl./Alter.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A010Grav(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A010Grav(nOpc)
Local nCpo       := 0
Local bCampo     := {|nCPO| Field(nCPO) }
Local cFilQKM    := xFilial("QKM")
Local lGraOk     := .T. // Indica se todas as gravacoes obtiveram sucesso
Local lOrdPeca   := GetMV("MV_QORDPEC",.T.,.F.)
Local nCont      := 0
Local nIt        := 0
Local nNumItem   := 1  // Contador para os Itens
Local nPosCodCar := aScan(aHeader, { |x| AllTrim(x[2]) == "QK2_CODCAR" })
Local nPosDel    := Len(aHeader) + 1
Local nPosDesc   := aScan(aHeader, { |x| AllTrim(x[2]) == "QK2_DESC" })
Local nPosItem   := aScan(aHeader, { |x| AllTrim(x[2]) == "QK2_ITEM" })

Begin Transaction

DbSelectArea("QK1")
DbSetOrder(1)

If INCLUI .and. !lInteg
	RecLock("QK1",.T.)
Else
	RecLock("QK1",.F.)
Endif

For nCont := 1 To FCount()

	If "FILIAL"$Field(nCont)
		FieldPut(nCont,xFilial("QK1"))
	Else
		FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
	Endif

Next nCont

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos nao informados                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                      
QK1->QK1_REVINV := Inverte(QK1->QK1_REV)

If INCLUI
	QK1->QK1_STATUS := "1"
Endif

MsUnLock()
FKCOMMIT()

DbSelectArea("QK2")
DbSetOrder(2)

If !lOrdPeca
	aCols := Asort(aCols,,,{|x,y| x[nPosCodCar] < y[nPosCodCar]}) // Ordena o aCols pela Operacao
Endif

For nIt := 1 To Len(aCols)

	If !aCols[nIt, nPosDel] .and. !Empty(aCols[nIt,nPosDesc])  // Verifica se o item foi deletado

		If ALTERA
		
			DbSetOrder(2)
			If DbSeek(xFilial("QK2")+ M->QK1_PECA + M->QK1_REV + aCols[nIt,nPosCodCar])
				RecLock("QK2",.F.)
			Else
				RecLock("QK2",.T.)
			Endif
			DbSetOrder(1)
		Else	                   
			RecLock("QK2",.T.)
		Endif
			
		For nCpo := 1 To Len(aHeader)
			If aHeader[nCpo, 10] <> "V"
				QK2->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
			EndIf
		Next nCpo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Campos Chave nao informados                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QK2->QK2_FILIAL	 := xFilial("QK2")
		QK2->QK2_PECA 	 := M->QK1_PECA
		QK2->QK2_REV 	 := M->QK1_REV
		QK2->QK2_REVINV	 := Inverte(QK1->QK1_REV)		
                                                                              
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle de itens do acols                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QK2->QK2_ITEM := StrZero(nNumItem,Len(aCols[1,nPosItem]))

		nNumItem++

		MsUnlock()
		FKCOMMIT()
    Else
    	DbSetOrder(2)
 		If DbSeek(xFilial("QK2")+ M->QK1_PECA + M->QK1_REV + aCols[nIt,nPosCodCar])

		    If !Empty(QK2->QK2_CHAVE)
    		    QO_DelTxt(QK2->QK2_CHAVE,"QPPA010 ")    //QPPXFUN
			EndIf
	
			RecLock("QK2",.F.)
			DbDelete()
		Endif
		DbSetOrder(1)
	Endif

Next nIt

//Deleção do registro da QKM - Itens Plano de Controle
If lDelCaract
	DbSelectArea("QKM")
	DbSetOrder(1)
	For nCont := 1 To Len(aCols)  //Percorre os registros da grid
		IF Atail(aCols[nCont])  //Valida se o registro esta marcado como deletado
			QKM->(DbSeek(cFilQKM+QK1->(QK1_PECA+QK1_REV)))
			While QKM->(!EOF()) .And.;
								QKM->QKM_FILIAL == cFilQKM .And.;
								QKM->QKM_PECA   == QK1->QK1_PECA .And.;
								QKM->QKM_REV    == QK1->QK1_REV

				IF QKM->QKM_NCAR == aCols[nCont][2]
					RecLock("QKM",.F.)
					QKM->(DbDelete())
					MsUnlock()
					FKCOMMIT()
				Endif
				QKM->(DbSkip())
			EndDo
		Endif
	Next
Endif

QKM->(DbCloseArea())

End Transaction
				
Return lGraOk


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A010Dele ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 24/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Exclusao de Pecas                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A010Dele(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A010Dele()

Local cEspecie  := "QPPA010 "   //Para gravacao de textos

DbSelectArea("QK2")
DbSetOrder(1)
	
If DbSeek(xFilial("QK2")+ QK1->QK1_PECA + QK1->QK1_REV)

	While !Eof() .and. ;
		QK1->QK1_PECA + QK1->QK1_REV == QK2_PECA + QK2_REV
		
	    If !Empty(QK2->QK2_CHAVE)
    	    QO_DelTxt(QK2->QK2_CHAVE,cEspecie)    //QPPXFUN
		EndIf
		
		RecLock("QK2",.F.)
		DbDelete()
		MsUnLock()
		FKCOMMIT()
		
		DbSkip()
		
	Enddo

Endif

DbSelectArea("QK1")

RecLock("QK1",.F.)
DbDelete()
MsUnLock()
FKCOMMIT()
				
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PP10LinOk ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 24.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP10LinOk                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function PP10LinOk

Local nPosDel		:= Len(aHeader) + 1
Local nPosDesc		:= aScan(aHeader, { |x| AllTrim(x[2]) == "QK2_DESC" 	})
Local nPosCODCAR	:= aScan(aHeader, { |x| AllTrim(x[2]) == "QK2_CODCAR" 	})
Local lRetorno		:= .T.
Local nCont			:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ verifica se a caracteristica foi preenchida          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Empty(aCols[n,nPosDesc]) .and. !aCols[n, nPosDel]
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
Endif

aEval( aCols, { |x| Iif(x[nPosDel] == .F. .and. x[nPosCODCAR] == aCols[n, nPosCODCAR], nCont++, nCont)})
If nCont > 1
	Help(" ", 1, "QPP110JAEX") // "Informacao ja cadastrada"
	aCols[n, nPosCODCAR] := ""
	lRetorno := .F.
Endif

Return lRetorno

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PP10TudOk ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 24.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para inclusao/alteracao geral                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP10TudOk                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Function PP10TudOk

Local lRetorno	:= .T.
Local nIt 		:= 0
Local nTot		:= 0
Local nPosDel  	:= Len(aHeader) + 1                      
Local nPosDesc 	:= aScan(aHeader, { |x| AllTrim(x[2]) == "QK2_DESC" })
Local aArea		:= {}
Local aAreaQK1	:= {}
Local cRevNew

For nIt := 1 To Len(aCols)
	If aCols[nIt, nPosDel] .or. Empty(aCols[nIt,nPosDesc])
		nTot ++
	Endif
	If !PP10LinOk()
		lRetorno := .F.
		Exit
	Endif
Next nIt

If Empty(M->QK1_PECA) .or. Empty(M->QK1_REV) .or. nTot == Len(aCols)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
Endif

If Empty(M->QK1_REVI) .and. !Empty(M->QK1_PRODUT)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
Endif

If M->QK1_LICPK  >= M->QK1_LSCPK 
	lRetorno := .F. 
	MsgAlert(STR0078)
EndIf

If INCLUI .and. !lInteg
	aArea := GetArea()

	DbSelectArea("QK1")
	aAreaQK1 := GetArea()
    
	QK1->(DbSetOrder(2)) // Pega o Numero para a proxima revisao
	If (QK1->(DbSeek(xFilial("QK1")+M->QK1_PECA)))
		cRevNew := Soma1(QK1->QK1_REV)
		
		If QK1->QK1_STATUS == "1" .or. !(QK1->QK1_STATUS $ "1234")
			Alert(STR0031) //"A revisao anterior esta aberta ou sem situacao, defina-a antes !"
			lRetorno := .F.
		Elseif cRevNew <> M->QK1_REV
			Alert(STR0032) //"A revisao informada esta fora de sequencia e sera alterada !"
			M->QK1_REV := cRevNew
			lRetorno := .F.
		Endif
	Endif	

	RestArea(aAreaQK1)
	RestArea(aArea)
Endif

Return lRetorno

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPPA010WhCodC ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 29.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ When do Campo QKK_CODCAR                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA010WhCodC()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QPPA010                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Function QPPA010WhCodC  

Local lRetorno		:= .T.
Local nPosCodCar	:= aScan(aHeader, { |x| AllTrim(x[2]) == "QK2_CODCAR" })

If !Empty(aCols[n, nPosCodCar]) .and. ALTERA
	lRetorno := .F.
EndIf

If lInteg
	lRetorno := .T.
Endif

Return lRetorno


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA010Lege ³ Autor ³ Robson Ramiro A.Olive³ Data ³ 29.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA010Lege

Local aLegenda := {	{'BR_VERDE'		,OemtoAnsi(STR0008)},;	// "PPAP Aberto"
					{'BR_VERMELHO'	,OemtoAnsi(STR0009)},;	// "PPAP Encerrado"
					{'BR_CINZA'		,OemtoAnsi(STR0016)},;	// "Revisao Nao Vigente"
					{'BR_PRETO'		,OemtoAnsi(STR0017)},;	// "PPAP Rejeitado"
					{'BR_BRANCO'		,OemtoAnsi(STR0007)}}	// "Sem Situacao"


BrwLegenda(cCadastro,STR0010,aLegenda) 	// "Legenda"

Return .T.
         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPPA010VL ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 22/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se Afastamento Superior ‚ maior que o Inferior 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QPPA010VL()

Local nPosTOL := aScan(aHeader,{|x| AllTrim(x[2]) == "QK2_TOL" })
Local nPosLIE := aScan(aHeader,{|x| AllTrim(x[2]) == "QK2_LIE" })

If 	SuperVal(aCols[n,nPosTOL]) + SuperVal(aCols[n,nPosLIE]) >;
	SuperVal(aCols[n,nPosTOL]) + SuperVal(M->QK2_LSE)
	
	Help(" ",1,"A010AFAMOR")  // Afastamento Inferior maior que Superior
	Return .F.
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPPA010BMP³ Autor ³ Robson Ramiro A Olivei³ Data ³ 19/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Escolhe o BMP que identifica a Caracteristica              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA010 / QPPA120 / QPPA130  							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QPPA010BMP(nOpc,nX,oBmp,aPanels,aValues,nTipo)

Local oDlg	 		:= Nil
Local oScrollBox	:= Nil
Local oBmp1,oBmp2,oBmp3,oBmp4,oBmp5,oBmp6,oBmp7,oBmp8,oBmp9,oBmp10
Local oBmp11,oBmp12,oBmp13,oBmp14,oBmp15,oBmp16,oBmp17,oBmp18,oBmp19,oBmp20
Local oBmp21,oBmp22,oBmp23,oBmp24,oBmp25,oBmp26,oBmp27,oBmp28,oBmp29,oBmp30
Local oBmp31,oBmp32,oBmp33,oBmp34,oBmp35,oBmp36,oBmp37,oBmp38,oBmp39,oBmp40
Local oBmp41,oBmp42
Local bBloco
Local nLin 
Local nCol
Local aBmp := {} 
Local aObjetos := {}
Local nI 
Local nY

Default nX := 0

If nX == 0 
	bBloco 	:= {|o| GravaBMP(o,nOpc)}
Else
	bBloco	:= {|o| GravaBMP2(o,nOpc,nX,oBmp,aPanels,aValues,nTipo)}
	n		:= nX
Endif 		

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0012+StrZero(n,Len(QK2->QK2_ITEM))); //"Simbolo da Caracteristica do Item "
						FROM 120,050 TO 258,385 OF oMainWnd PIXEL

oScrollBox := TScrollBox():New(oDlg,10,03,50,135,.T.,.F.,.T.)

DEFINE SBUTTON FROM 30,140 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
DEFINE SBUTTON FROM 45,140 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

@ 005,05 BITMAP oBmp1 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp1:SetBmp("note")
oBmp1:lAutoSize		:= .F.
oBmp1:cToolTip 		:= STR0013 //"Duplo Click para APAGAR !"
oBmp1:BlDblClick 	:= bBloco

@ 005,35 BITMAP oBmp2 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp2:SetBmp("A1")
oBmp2:lAutoSize		:= .F.
oBmp2:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp2:BlDblClick 	:= bBloco
oBmp2:lTransparent	:= .T.

@ 005,65 BITMAP oBmp3 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp3:SetBmp("A2")
oBmp3:lAutoSize		:= .F.
oBmp3:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp3:BlDblClick 	:= bBloco
oBmp3:lTransparent	:= .T.

@ 005,95 BITMAP oBmp4 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp4:SetBmp("A3")
oBmp4:lAutoSize		:= .F.
oBmp4:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp4:BlDblClick 	:= bBloco
oBmp4:lTransparent	:= .T.

@ 030,05 BITMAP oBmp5 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp5:SetBmp("A4")
oBmp5:lAutoSize		:= .F.
oBmp5:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp5:BlDblClick 	:= bBloco
oBmp5:lTransparent 	:= .T.

@ 030,35 BITMAP oBmp6 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp6:SetBmp("A5")
oBmp6:lAutoSize		:= .F.
oBmp6:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp6:BlDblClick 	:= bBloco
oBmp6:lTransparent 	:= .T.

@ 030,65 BITMAP oBmp7 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp7:SetBmp("A6")
oBmp7:lAutoSize		:= .F.
oBmp7:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp7:BlDblClick 	:= bBloco
oBmp7:lTransparent 	:= .T.

@ 030,95 BITMAP oBmp8 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp8:SetBmp("A7")
oBmp8:lAutoSize		:= .F.
oBmp8:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp8:BlDblClick 	:= bBloco
oBmp8:lTransparent 	:= .T.

@ 055,05 BITMAP oBmp9 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp9:SetBmp("A8")
oBmp9:lAutoSize		:= .F.
oBmp9:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp9:BlDblClick 	:= bBloco
oBmp9:lTransparent 	:= .T.

@ 055,35 BITMAP oBmp10 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp10:SetBmp("A9")
oBmp10:lAutoSize		:= .F.
oBmp10:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp10:BlDblClick 		:= bBloco
oBmp10:lTransparent 	:= .T.

@ 055,65 BITMAP oBmp11 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp11:SetBmp("B1")
oBmp11:lAutoSize		:= .F.
oBmp11:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp11:BlDblClick 		:= bBloco
oBmp11:lTransparent 	:= .T.

@ 055,95 BITMAP oBmp12 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp12:SetBmp("B2")
oBmp12:lAutoSize		:= .F.
oBmp12:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp12:BlDblClick 		:= bBloco
oBmp12:lTransparent 	:= .T.

@ 080,05 BITMAP oBmp13 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp13:SetBmp("B3")
oBmp13:lAutoSize		:= .F.
oBmp13:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp13:BlDblClick 		:= bBloco
oBmp13:lTransparent 	:= .T.

@ 080,35 BITMAP oBmp14 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp14:SetBmp("B4")
oBmp14:lAutoSize		:= .F.
oBmp14:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp14:BlDblClick 		:= bBloco
oBmp14:lTransparent 	:= .T.

@ 080,65 BITMAP oBmp15 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp15:SetBmp("B5")
oBmp15:lAutoSize		:= .F.
oBmp15:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp15:BlDblClick 		:= bBloco
oBmp15:lTransparent 	:= .T.

@ 080,95 BITMAP oBmp16 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp16:SetBmp("B6")
oBmp16:lAutoSize		:= .F.
oBmp16:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp16:BlDblClick 		:= bBloco
oBmp16:lTransparent 	:= .T.

@ 105,05 BITMAP oBmp17 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp17:SetBmp("B7")
oBmp17:lAutoSize		:= .F.
oBmp17:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp17:BlDblClick 		:= bBloco
oBmp17:lTransparent 	:= .T.

@ 105,35 BITMAP oBmp18 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp18:SetBmp("B9")
oBmp18:lAutoSize		:= .F.
oBmp18:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp18:BlDblClick 		:= bBloco
oBmp18:lTransparent 	:= .T.

@ 105,65 BITMAP oBmp19 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp19:SetBmp("C1")
oBmp19:lAutoSize		:= .F.
oBmp19:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp19:BlDblClick 		:= bBloco
oBmp19:lTransparent 	:= .T.

@ 105,95 BITMAP oBmp20 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp20:SetBmp("C2")
oBmp20:lAutoSize		:= .F.
oBmp20:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp20:BlDblClick 		:= bBloco
oBmp20:lTransparent 	:= .T.

@ 130,05 BITMAP oBmp21 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp21:SetBmp("C3")
oBmp21:lAutoSize		:= .F.
oBmp21:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp21:BlDblClick 		:= bBloco
oBmp21:lTransparent 	:= .T.

@ 130,35 BITMAP oBmp22 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp22:SetBmp("C5")
oBmp22:lAutoSize		:= .F.
oBmp22:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp22:BlDblClick 		:= bBloco
oBmp22:lTransparent 	:= .T.

@ 130,65 BITMAP oBmp23 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp23:SetBmp("C6")
oBmp23:lAutoSize		:= .F.
oBmp23:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp23:BlDblClick 		:= bBloco
oBmp23:lTransparent 	:= .T.

@ 130,95 BITMAP oBmp24 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp24:SetBmp("D1")
oBmp24:lAutoSize		:= .F.
oBmp24:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp24:BlDblClick 		:= bBloco
oBmp24:lTransparent 	:= .T.

@ 155,05 BITMAP oBmp25 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp25:SetBmp("D2")
oBmp25:lAutoSize		:= .F.
oBmp25:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp25:BlDblClick 		:= bBloco
oBmp25:lTransparent 	:= .T.

@ 155,35 BITMAP oBmp26 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp26:SetBmp("D3")
oBmp26:lAutoSize		:= .F.
oBmp26:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp26:BlDblClick 		:= bBloco
oBmp26:lTransparent 	:= .T.

@ 155,65 BITMAP oBmp27 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp27:SetBmp("D4")
oBmp27:lAutoSize		:= .F.
oBmp27:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp27:BlDblClick 		:= bBloco
oBmp27:lTransparent 	:= .T.

@ 155,95 BITMAP oBmp28 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp28:SetBmp("D5")
oBmp28:lAutoSize		:= .F.
oBmp28:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp28:BlDblClick 		:= bBloco
oBmp28:lTransparent 	:= .T.

@ 180,05 BITMAP oBmp29 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp29:SetBmp("D6")
oBmp29:lAutoSize		:= .F.
oBmp29:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp29:BlDblClick 		:= bBloco
oBmp29:lTransparent 	:= .T.

@ 180,35 BITMAP oBmp30 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp30:SetBmp("D8")
oBmp30:lAutoSize		:= .F.
oBmp30:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp30:BlDblClick 		:= bBloco
oBmp30:lTransparent 	:= .T.

@ 180,65 BITMAP oBmp31 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp31:SetBmp("D9")
oBmp31:lAutoSize		:= .F.
oBmp31:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp31:BlDblClick 		:= bBloco
oBmp31:lTransparent 	:= .T.

@ 180,95 BITMAP oBmp32 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp32:SetBmp("E1")
oBmp32:lAutoSize		:= .F.
oBmp32:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp32:BlDblClick 		:= bBloco
oBmp32:lTransparent 	:= .T.

@ 205,05 BITMAP oBmp33 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp33:SetBmp("E2")
oBmp33:lAutoSize		:= .F.
oBmp33:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp33:BlDblClick 		:= bBloco
oBmp33:lTransparent 	:= .T.

@ 205,35 BITMAP oBmp34 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp34:SetBmp("E3")
oBmp34:lAutoSize		:= .F.
oBmp34:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp34:BlDblClick 		:= bBloco
oBmp34:lTransparent 	:= .T.

@ 205,65 BITMAP oBmp35 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp35:SetBmp("E4")
oBmp35:lAutoSize		:= .F.
oBmp35:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp35:BlDblClick 		:= bBloco
oBmp35:lTransparent 	:= .T.

@ 205,95 BITMAP oBmp36 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp36:SetBmp("E6")
oBmp36:lAutoSize		:= .F.
oBmp36:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp36:BlDblClick 		:= bBloco
oBmp36:lTransparent 	:= .T.

@ 230,05 BITMAP oBmp37 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp37:SetBmp("F9")
oBmp37:lAutoSize		:= .F.
oBmp37:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp37:BlDblClick 		:= bBloco
oBmp37:lTransparent 	:= .T.

@ 230,35 BITMAP oBmp38 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp38:SetBmp("G1")
oBmp38:lAutoSize		:= .F.
oBmp38:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp38:BlDblClick 		:= bBloco
oBmp38:lTransparent 	:= .T.

@ 230,65 BITMAP oBmp39 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp39:SetBmp("G2")
oBmp39:lAutoSize		:= .F.
oBmp39:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp39:BlDblClick 		:= bBloco
oBmp39:lTransparent 	:= .T.

@ 230,95 BITMAP oBmp40 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp40:SetBmp("G3")
oBmp40:lAutoSize		:= .F.
oBmp40:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp40:BlDblClick 		:= bBloco
oBmp40:lTransparent 	:= .T.

@ 255,05 BITMAP oBmp41 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp41:SetBmp("G4")
oBmp41:lAutoSize		:= .F.
oBmp41:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp41:BlDblClick 		:= bBloco
oBmp41:lTransparent 	:= .T.

@ 255,35 BITMAP oBmp42 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp42:SetBmp("G5")
oBmp42:lAutoSize		:= .F.
oBmp42:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
oBmp42:BlDblClick 		:= bBloco
oBmp42:lTransparent 	:= .T.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a existencia de Filtros na mBrowse                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ExistBlock("QPP10BMP"))
	aBmp := ExecBlock("QPP10BMP",.F.,.F.)
EndIf	

If Len(aBmp)>0
    
	//Seta variaveis de controle
	nLin := 255 
	nCol := 35
	nI   := 2
	
	For nY:=1 to Len(aBmp)  
		
		//Valida o nome do BitMap
	    If Len(aBmp[nY]) >2
	    	MsgAlert(STR0077 + Alltrim(aBmp[nY]))  //"O tamanho do nome do BitMap não pode ultrapassar a 2 caracteres. Favor corrigir o nome do BitMap "
	    	Exit
	    EndIF	
		
    	nI++
    	If nI>4
    		nCol := 5
    		nLin := nLin+25
    		nI   := 1
    	Else               
    		nCol := nCol+30
    	EndIf
    	AADD(aObjetos,"")
    	
    	@ nLin,nCol BITMAP aObjetos[nY] REPOSITORY &(aBmp[nY]) SIZE 030,030 OF oScrollBox NOBORDER PIXEL
		aObjetos[nY]:SetBmp(aBmp[nY])
		aObjetos[nY]:lAutoSize		:= .F.
		aObjetos[nY]:cToolTip 		:= STR0014 //"Duplo Click para Escolher"
		aObjetos[nY]:BlDblClick 	:= bBloco
		aObjetos[nY]:lTransparent 	:= .T.

    Next nY
    
EndIF


ACTIVATE MSDIALOG oDlg

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³GravaBMP  ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 19/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava o BMP que identifica a Caracteristica                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GravaBMP(ExpO1, ExpN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto Clickado                                    ³±±
±±³          ³ ExpN1 = Opcao do Menu                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GravaBMP(o,nOpc)

Local cLogo 	:= o:cResName
Local nPosSIMB	:= aScan(aHeader,{|x| AllTrim(x[2]) == "QK2_SIMB" })

If nOpc == 3 .or. nOpc == 4
	aCols[n,nPosSIMB] := Iif(Len(AllTrim(cLogo))>2,"  ",AllTrim(cLogo))
	oGet:oBrowse:Refresh()
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³PPA010VLD ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 01/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o No. do PPAP no fornecedor                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA010VLD(Void)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PPA010VLD

Local lRetorno	:= .T.
Local aArea		:= GetArea()

If !Empty(M->QK1_PPAP)
	DbSelectArea("QK1")
	DbSetOrder(4)
	If DbSeek(xFilial("QK1")+M->QK1_PPAP)
		Help(" ",1,"PPAPEXIST")  // Numero do PPAP ja existe, deseja mante-lo ?
	Endif
Endif

RestArea(aArea)

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPPA010DOC³ Autor ³ Robson Ramiro A Olivei³ Data ³ 02/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza documento associado ao processo.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA010DOC(Void)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QPPA010DOC

Local cPathSrv := Alltrim(GetMV("MV_PPATSRV"))

If Right(cPathSrv,1) # "\"
	cPathSrv += "\"
Endif

If Right(cPathCli,1) # "\"
	cPathCli += "\"
Endif

If !Empty(M->QK1_DOC)
	CpyS2T(cPathSrv + AllTrim(M->QK1_DOC),cPathCli,.T.)
	QA_OPENARQ(cPathCli + AllTrim(M->QK1_DOC))
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³PPA010Mani³ Autor ³ Robson Ramiro A Olivei³ Data ³ 02/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Manipula o Status do PPAP                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA010Mani(Void)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PPA010Mani

Local oDlg
Local oGroup
Local oPeca, oRev
Local oComboBox
Local aItens
Local oJUST, oJUSTA
Local oSTAT
Local lOk := .F.
Local cSTAT
Local oBmp, oBmp2
Local aCores
Local cREV
Local aArea := GetArea()

Private cJUST, cChoice

cREV := QK1->QK1_REV

DbSelectArea("QK1")
DbSetOrder(2)
DbSeek(xFilial() + QK1->QK1_PECA)

If cREV <> QK1->QK1_REV
	Alert(STR0033) //"Somente a Ultima revisao pode ser manipulada !"
	RestArea(aArea)
	Return
Endif

RestArea(aArea)

RegToMemory("QK1",.F.)

aItens := { 	STR0018, STR0019, STR0020 ,; 	//"1 - PPAP Aberto"###"2 - PPAP Encerrado"###"3 - Revisao Nao Vigente"
				STR0021, STR0022 } 				//"4 - PPAP Rejeitado"###" - Sem Situacao"

aCores := { "BR_VERDE", "BR_VERMELHO", "BR_CINZA", "BR_PRETO",	"BR_BRANCO" }

cJUST := Space(34)

Do Case
	Case M->QK1_STATUS == "1"
		cChoice := aItens[1]
	Case M->QK1_STATUS == "2"
		cChoice := aItens[2]
	Case M->QK1_STATUS == "3"
		cChoice := aItens[3]
	Case M->QK1_STATUS == "4"
		cChoice := aItens[4]
	OtherWise
		cChoice := aItens[5]
Endcase

cSTAT := cChoice
		
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0023) ; //"Manipulacao do PPAP"
						FROM 120,000 TO 360,665 OF oMainWnd PIXEL

@ 018,002 GROUP oGroup TO 105,330 LABEL OemToAnsi(STR0024) COLOR CLR_BLUE OF oDlg PIXEL //"STATUS"

@ 036,005 SAY OemToAnsi(STR0025) SIZE 040,010 OF oDlg PIXEL //"No. Peca"
@ 036,037 MSGET oPECA VAR M->QK1_PECA SIZE 130,005 OF oDlg PIXEL WHEN .F.

@ 036,175 SAY OemToAnsi(STR0026) SIZE 040,010 OF oDlg PIXEL //"Revisao"
@ 036,201 MSGET oREV VAR M->QK1_REV SIZE 003,005 OF oDlg PIXEL WHEN .F.

@ 054,005 SAY OemToAnsi(STR0024) SIZE 040,010 OF oDlg PIXEL //"Status"
@ 054,037 COMBOBOX oComboBox VAR cChoice ITEMS aItens SIZE 070,015 OF oDlg PIXEL
@ 055,110 BITMAP oBmp REPOSITORY SIZE 030,030 OF oDlg NOBORDER PIXEL

oComboBox:bChange := {|| (oBmp:SetBmp(aCores[oComboBox:nAt]),oBmp:Refresh())}

oBmp:SetBmp(aCores[oComboBox:nAt])

@ 054,175 SAY OemToAnsi(STR0027) SIZE 040,010 OF oDlg PIXEL //"Atual"
@ 054,201 MSGET oSTAT VAR cSTAT SIZE 070,005 OF oDlg PIXEL WHEN .F.
@ 055,274 BITMAP oBmp2 REPOSITORY SIZE 030,030 OF oDlg NOBORDER PIXEL

oBmp2:SetBmp(aCores[oComboBox:nAt])

@ 072,005 SAY OemToAnsi(STR0028) SIZE 040,010 OF oDlg PIXEL //"Motivo"
@ 072,037 MSGET oJUST VAR cJUST VALID (!Empty(cJUST));
 			SIZE 160,005 OF oDlg PIXEL

@ 090,005 SAY OemToAnsi(STR0027) SIZE 040,010 OF oDlg PIXEL //"Atual"
@ 090,037 MSGET oJUSTA VAR M->QK1_JUST SIZE 160,005 OF oDlg PIXEL WHEN .F.

oDlg:lEscClose := .F.

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| Iif(!Empty(cJUST), (lOk := .T. ,oDlg:End()),)},{||oDlg:End()},,) CENTERED

If lOk
	RecLock("QK1",.F.)
	QK1->QK1_STATUS 	:= Substr(cChoice,1,1)
	QK1->QK1_JUST		:= cUserName+"-"+cJUST
	MsUnlock()
	FKCOMMIT()
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³PPA010Chec³ Autor ³ Robson Ramiro A Olivei³ Data ³ 17/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida se existem relacionamentos                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA010Chec(Void)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PPA010Chec

Local aSolucao := {{STR0090}}
Local lReturn  := .T.

DbSelectArea("QKK")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0034) //"Operacoes"
Endif

DbSelectArea("QKL")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0040) //"Plano de Controle"
Endif

DbSelectArea("QKG")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0035) //"Cronograma"
Endif

DbSelectArea("QK5")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0036) //"FMEA de Projeto"
Endif

DbSelectArea("QK7")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0037) //"FMEA de Processo"
Endif

DbSelectArea("QKF")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0038) //"Viabilidade"
Endif

DbSelectArea("QKN")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0039) //"Diagrama de Fluxo"
Endif

DbSelectArea("QM4")
DbSetOrder(3)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0041) //"R&R"
Endif

DbSelectArea("QK9")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0042) //"Capabilidade"
Endif

DbSelectArea("QKB")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0043) //"Ensaio Dimensional"
Endif              

DbSelectArea("QKD")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0044) //"Ensaio Material"
Endif

DbSelectArea("QKC")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0060) //"Ensaio Desempenho"
Endif

DbSelectArea("QK3")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0045) //"Aprovacao de Aparencia"
Endif

DbSelectArea("QKI")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0046) //"Certificado de Submissao"
Endif

DbSelectArea("QKJ")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0047) //"Sumario e APQP"
Endif

DbSelectArea("QKH")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0048) //"Aprovacao Interina"
Endif

DbSelectArea("QKQ")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0049) //"CheckList A1"
Endif

DbSelectArea("QKR")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0050) //"CheckList A2"
Endif

DbSelectArea("QKS")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0051) //"CheckList A3"
Endif

DbSelectArea("QKT")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0052) //"CheckList A4"
Endif

DbSelectArea("QKU")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0053) //"CheckList A5"
Endif

DbSelectArea("QKV")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0054) //"CheckList A6"
Endif

DbSelectArea("QKW")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0055) //"CheckList A7"
Endif

DbSelectArea("QKX")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0056) //"CheckList A8"
Endif

DbSelectArea("QL0")
DbSetOrder(1)
If DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)
	aAdd(aSolucao,_CRLF+"-> "+STR0063) //"PSA"
Endif

QL1->(DbSetOrder(1))
QL2->(DbSetOrder(1))

If QL1->(DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV)) .or. QL2->(DbSeek(xFilial() + M->QK1_PECA + M->QK1_REV))
	aAdd(aSolucao,_CRLF+"-> "+STR0064) //"VDA"
Endif

If Len(aSolucao) > 1
	//#Atenção
	//#Esta peça possui movimentações que impedem a exclusão desta característica.
	//#Gere uma nova revisão da peça ou desvincule a característica deste(s) cadastro(s): 
	Help(NIL, NIL, STR0084, NIL, STR0058, 1, 0, NIL, NIL, NIL, NIL, NIL, aSolucao) 

	lReturn := .F.
	
Endif

Return lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³GravaBMP2 ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 20/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava o BMP que identifica a Caracteristica                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GravaBMP2(ExpO1, ExpN1, ExpN2, ExpO2)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto Clickado                                    ³±±
±±³          ³ ExpN1 = Opcao do Menu                                      ³±±
±±³          ³ ExpN2 = Linha do Painel                                    ³±±
±±³          ³ ExpO2 = Objeto exibido                                     ³±±
±±³          ³ ExpA1 = Array com Objetos                                  ³±±
±±³          ³ ExpA2 = Array com Valores                                  ³±±
±±³          ³ ExpN3 = Valor de identificacao dos FMEAs                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA120/QPPA130/QPPA010								      ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Robson Ramiro³27/01/04³      ³ Acerto de warnings, funcao alterada    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function GravaBMP2(o,nOpc,nX,oBmp,aPanels,aValues,nTipo)

Local cLogo := o:cResName

aValues[nx,5+nTipo] := Iif(Len(AllTrim(cLogo))>2,"  ",AllTrim(cLogo))
If ValType(aPanels)=="O"
	aPanels:Refresh()
Else
	aPanels[nx]:Refresh()
EndIf	

oBmp:SetBmp(Iif(Len(AllTrim(cLogo))>2,"note",AllTrim(cLogo)))
oBmp:Refresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³PPA010QIP ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 27/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz integracao com o QIP                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA010QIP(Void)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PPA010QIP

Local cPict
Local nRec
Local nCont

If Pergunte("PPA010",.T.)
	
	If !ExistCpo("QP6",mv_par01+mv_par02,2) .or. !ExistChav("QK1",mv_par03,1)
		Return .F.
	Endif

	DbSelectArea("QL4")
	DbSetOrder(1)
	If DbSeek(xFilial()+mv_par03+mv_par04+mv_par01+mv_par02)
		Help(" ", 1, "QPP110JAEX") // "Informacao ja cadastrada"
		Return .F.
	Endif

	Begin Transaction

	DbSelectArea("QP6")
	DbSetOrder(1)
	If DbSeek(xFilial()+mv_par01+Inverte(mv_par02))
		DbSelectArea("QK1")
		RecLock("QK1",.T.)
		QK1->QK1_FILIAL	:= xFilial()
		QK1->QK1_PECA 	:= mv_par03
		QK1->QK1_REV	:= mv_par04
		QK1->QK1_REVINV	:= Inverte(mv_par04)
		QK1->QK1_DTREVI	:= dDataBase
		QK1->QK1_DESC	:= QP6->QP6_DESCPO
		QK1->QK1_DTRDES	:= QP6->QP6_DTDES
		QK1->QK1_REVDES	:= QP6->QP6_RVDES
		QK1->QK1_PRODUT	:= QP6->QP6_PRODUT
		QK1->QK1_REVI	:= QP6->QP6_REVI
		QK1->QK1_STATUS	:= "1"
		MsUnlock()
		FKCOMMIT()
		
		nRec 	:= Recno()
		nCont	:= 0
		
		DbSelectArea("QP7")
		DbSetOrder(1)
		DbSeek(xFilial()+mv_par01+mv_par02)
		
		While !Eof() .and. QP7->QP7_FILIAL == xFilial() .and. QP7->QP7_PRODUT == QP6->QP6_PRODUT;
						.and. QP7->QP7_REVI == QP6->QP6_REVI
			
			cPict := QA_PICT("QP7_NOMINA",QP7->QP7_NOMINA)
			nCont++
			DbSelectArea("QK2")
			
			RecLock("QK2",.T.)
			QK2->QK2_FILIAL	:= xFilial()
			QK2->QK2_PECA 	:= mv_par03
			QK2->QK2_REV	:= mv_par04
			QK2->QK2_REVINV	:= Inverte(mv_par04)
			QK2->QK2_ITEM	:= StrZero(nCont,Len(QK2->QK2_ITEM))
			QK2->QK2_CODCAR	:= StrZero(nCont*10,Len(QK2->QK2_CODCAR))
			QK2->QK2_DESC	:= QP7->QP7_ENSAIO + " - " + Posicione("QP1",1,xFilial()+QP7->QP7_ENSAIO,"QP1_DESCPO")
			QK2->QK2_TOL	:= QP7->QP7_NOMINA
			QK2->QK2_LIE	:= Transform(SuperVal(QP7->QP7_LIE) - SuperVal(QP7->QP7_NOMINA), cPict)
			QK2->QK2_LSE	:= Transform(SuperVal(QP7->QP7_LSE) - SuperVal(QP7->QP7_NOMINA), cPict)
			QK2->QK2_UM		:= QP7->QP7_UNIMED
			MsUnlock()
			FKCOMMIT()
			
			DbSelectArea("QP7")
			DbSkip()
			
		Enddo
		
		DbSelectArea("QQK")
		DbSetOrder(1)
		DbSeek(xFilial()+mv_par01+mv_par02)
		
		nCont := 0
		
		While !Eof() .and. QQK->QQK_FILIAL == xFilial() .and. QQK->QQK_PRODUT+QQK->QQK_REVIPR == mv_par01+mv_par02
			nCont++
			DbSelectArea("QKK")
			
			RecLock("QKK",.T.)
			QKK->QKK_FILIAL	:= xFilial()
			QKK->QKK_PECA 	:= mv_par03
			QKK->QKK_REV	:= mv_par04
			QKK->QKK_REVINV	:= Inverte(mv_par04)
			QKK->QKK_ITEM	:= StrZero(nCont,Len(QKK->QKK_ITEM))
			QKK->QKK_NOPE	:= StrZero(nCont*10,Len(QKK->QKK_NOPE))
			QKK->QKK_DESC	:= AllTrim(QQK->QQK_RECURS)+"-"+QQK->QQK_DESCRI
			MsUnlock()
			FKCOMMIT()
			DbSelectArea("QQK")
			DbSkip()
		Enddo
		
		DbSelectArea("QL4")
		RecLock("QL4",.T.)
		QL4->QL4_FILIAL	:= xFilial()
		QL4->QL4_PECA 	:= mv_par03
		QL4->QL4_REV	:= mv_par04
		QL4->QL4_PRODUT	:= mv_par01
		QL4->QL4_REVI	:= mv_par02
		QL4->QL4_DATA	:= dDataBase
		QL4->QL4_ORIGEM	:= "QIP->PPAP"
		MsUnlock()
        FKCOMMIT()
	Endif

	DbCommitAll()
		
	End Transaction
	
	ALTERA 	:= .T.
	lInteg	:= .T.
	PPA010Alte("QK1",nRec,4)
	lInteg	:= .F.
	ALTERA 	:= .F.
Endif

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ PPAP2QIP ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 03/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera informacoes no QIP                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPAP2QIP(Void)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ PPAP/QIP													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PPAP2QIP

Local cPict
Local nCont
Local cCod  
Local aArea := {}

If Pergunte("PP2QIP",.T.)

	If !ExistChav("QP6",mv_par03+mv_par04,2) .or. !ExistCpo("QK1",mv_par01+mv_par02,1)
		Return .F.
	Endif

	DbSelectArea("QL4")
	DbSetOrder(1)
	If DbSeek(xFilial()+mv_par01+mv_par02+mv_par03+mv_par04)
		Help(" ", 1, "QPP110JAEX") // "Informacao ja cadastrada"
		Return .F.
	Endif

	Begin Transaction

	DbSelectArea("QK1")
	DbSetOrder(1)
	If DbSeek(xFilial()+mv_par01+mv_par02)

		DbSelectArea("SB1")
		DbSetOrder(1)
		If !DbSeek(xFilial("SB1")+mv_par03)
			RecLock("SB1",.T.)
			SB1->B1_FILIAL	:= xFilial("SB1")
			SB1->B1_COD   	:= mv_par03
			SB1->B1_DESC  	:= AllTrim(QK1->QK1_DESC)
			SB1->B1_LOCPAD	:= "01"	//asssume o local padrao
//			SB1->B1_TIPO	   Tipo do Produto
//			SB1->B1_UM		   Unidade de Medida 
			MsUnLock()
			FKCOMMIT()
			If RetArqProd(mv_par03)
				aArea := GetArea()
				RecLock("SBZ",.T.)
				SBZ->BZ_FILIAL := xFilial("SBZ")
				SBZ->BZ_COD    := mv_par03
				SBZ->BZ_LOCPAD := "01"
				MsUnlock()
				FKCOMMIT()
				RestArea(aArea)
			Endif
		Endif
		
		DbSelectArea("QP6")
		RecLock("QP6",.T.)
		QP6->QP6_FILIAL	:= xFilial("QP6")
		QP6->QP6_PRODUT	:= mv_par03
		QP6->QP6_REVI	:= mv_par04
		QP6->QP6_REVINV	:= Inverte(mv_par04)
		QP6->QP6_DESCPO	:= QK1->QK1_DESC
		QP6->QP6_DTDES 	:= QK1->QK1_DTRDES
		QP6->QP6_RVDES 	:= QK1->QK1_REVDES
		QP6->QP6_CADR	:= Subs(cUserName,1,8)
		QP6->QP6_DTCAD	:= dDataBase
		QP6->QP6_DTINI	:= dDataBase
		QP6->QP6_SITPRD	:= "C"
		QP6->QP6_TMPLIM	:= 1
		QP6->QP6_CODREC	:= QPPSG2(mv_par03)
		QP6->QP6_SITREV	:= "0"
//		QP6->QP6_TIPO      Tipo do Produto
//		QP6->QP6_UNMED1	   Unidade de medida
//		QP6->QP6_UNAMO     Unidade de medida
		MsUnlock()
        FKCOMMIT()
		DbSelectArea("QK2")
		DbSetOrder(1)
		DbSeek(xFilial()+mv_par01+mv_par02)

		nCont := 0

		While !Eof() .and. QK2->QK2_FILIAL == xFilial() .and. QK2->QK2_PECA+QK2->QK2_REV == mv_par01+mv_par02
			
			nCont++

			cPict := QA_PICT("QK2_TOL",QK2->QK2_TOL)
			DbSelectArea("QP7")
			
			RecLock("QP7",.T.)
			QP7->QP7_FILIAL	:= xFilial("QP7")
			QP7->QP7_PRODUT	:= mv_par03
			QP7->QP7_REVI	:= mv_par04
			QP7->QP7_NOMINA	:= AllTrim(QK2->QK2_TOL)
			QP7->QP7_LIE	:= AllTrim(Transform(SuperVal(QK2->QK2_TOL) + SuperVal(QK2->QK2_LIE), cPict))
			QP7->QP7_LSE	:= AllTrim(Transform(SuperVal(QK2->QK2_TOL) + SuperVal(QK2->QK2_LSE), cPict))
			QP7->QP7_UNIMED	:= QK2->QK2_UM
			QP7->QP7_MINMAX	:= "1"
			QP7->QP7_ENSAIO	:= "PPAP"+StrZero(nCont,Len(QP7->QP7_ENSAIO)-4)
			QP7->QP7_STATUS	:= "P"	// Inserido P somente para evitar quebra de IR
//			QP7->QP7_TIPO	   Tipo
//			QP7->QP7_CODREC    Codigo do Roteiro
//			QP7->QP7_LABOR	   Tabela Especifica
//			QP7->QP7_SEQLAB	   Sequencial do laboratorio
			MsUnlock()
			FKCOMMIT()
			DbSelectArea("QK2")
			DbSkip()
			
		Enddo

		DbSelectArea("QKK")
		DbSetOrder(1)
		DbSeek(xFilial()+mv_par01+mv_par02)

		cCod := StrZero(1,Len(QQK->QQK_OPERAC))

		While !Eof() .and. QKK->QKK_FILIAL == xFilial() .and. QKK->QKK_PECA+QKK->QKK_REV == mv_par01+mv_par02

			DbSelectArea("QQK")
			RecLock("QQK",.T.)
			QQK->QQK_FILIAL	:= xFilial("QQK")
			QQK->QQK_PRODUT	:= mv_par03
			QQK->QQK_REVIPR	:= mv_par04
			QQK->QQK_OPERAC	:= cCod
			QQK->QQK_DESCRI	:= QKK->QKK_DESC
			QQK->QQK_TEMPAD	:= 1
			QQK->QQK_OPE_OB	:= "S"
			QQK->QQK_SEQ_OB	:= "S"
			QQK->QQK_LAU_OB	:= "S"
//			QQK->QQK_RECURS	   Integra com SH1
			MsUnlock()
            FKCOMMIT()
			cCod := Soma1(QQK->QQK_OPERAC)
						
			DbSelectArea("QKK")
			DbSkip()
		Enddo
		
		DbSelectArea("QL4")
		RecLock("QL4",.T.)
		QL4->QL4_FILIAL	:= xFilial()
		QL4->QL4_PECA 	:= mv_par01
		QL4->QL4_REV	:= mv_par02
		QL4->QL4_PRODUT	:= mv_par03
		QL4->QL4_REVI	:= mv_par04
		QL4->QL4_DATA	:= dDataBase
		QL4->QL4_ORIGEM	:= "PPAP->QIP"
		MsUnlock()
		FKCOMMIT()
	Endif

	DbCommitAll()
		
	End Transaction

Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ QPPSG2   ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 23/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Checa se existe roteiro no SG2                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPSG2(ExpC1)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Produto      									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ PPAP/QIP													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QPPSG2(cProdut)

Local cRetorno := "01"

SG2->(DbSetOrder(1))
If SG2->(DbSeek(xFilial("SG2")+cProdut))
	While SG2->(!Eof()) .and. SG2->G2_PRODUTO == cProdut .and. xFilial("SG2") == SG2->G2_FILIAL
		cRetorno := Soma1(SG2->G2_CODIGO)
		SG2->(DbSkip())
	Enddo
Endif

Return(cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPPA010DUP³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 21/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Duplica Caracteristica num array                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA010DUP(Void)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPPA010DUP()
Local nI:=0
Local cCarac := ""
Local nPos :=  aScan(aHeader, { |x| AllTrim(x[2]) == "QK2_CODCAR"	})  
Local nPosI:=  aScan(aHeader, { |x| AllTrim(x[2]) == "QK2_ITEM"	})
Local laDel:=.F.

Private aClon
Private nAux
Private nItem

If !PP10LinOk()
	return
EndIf

If ExistBlock("Q010DUPL")   // PE  para tratar a duplicacao das caracteristicas
	aClon := aClone(ExecBlock("Q010DUPL",.F.,.F.))
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se deixar a ultima linha em branco, exclui a mesma ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                               
	If Empty(aCols[Len(aCols),2]) .And. Len(aCols) > 1 .and. aCols[Len(aCols)][Len(aCols[1])] == .T.
		Adel( aCols, Len(aCols) )
		ASize( aCols, Len( aCols) - 1)
		laDel:=.T.
		oGet:oBrowse:Refresh()  
	EndIf
	
	If Len(aCols)==1 .and. Empty(aCols[1][nPos])   // Caso nao existam caracteristicas  nao executo a rotina
		MsgAlert(STR0073)	  //   "Cadastre as caracteristicas para poder duplica-las"
		Return
	EndIf

	aCols := Asort(aCols,,,{|x,y| x[nPos] < y[nPos]}) // Ordena o aCols pela Operacao
	oGet:oBrowse:Refresh() 

	aClon := aClone(aCols)       // Clono o array
	
	If Pergunte("QCAVID",.T.)   
		// Consistir de-ate	
		If ( aScan(aCols, { |x| AllTrim(x[nPos]) == AllTrim(mv_par01)}) == 0 .or. ;
		     aScan(aCols, { |x| AllTrim(x[nPos]) == AllTrim(mv_par02)}) == 0 )
		     MsgAlert(STR0074) // "Escolha  uma sequencia valida"  
		     return
		EndIf
		cCarac := mv_par01                    
		cCaracNew := mv_par03	
		// Pego o ultima sequencia de caracteristica
		if Alltrim(aCols[Len(aCols)][nPos]) >= AllTrim(cCaracNew)  .And. ;
		   aCols[Len(aCols)][Len(aCols[1])] <> .T.  // nao executo se a caracteristica for menor que a ultima cadastrada
			MsgAlert(STR0072)  // "A sequencia inicial, tem que ser maior que a ultima caracteristica cadastrada ..."
			Return													   
		EndIf
		nItem  := AScan( aCols, {|x| AllTrim(x[nPos]) == AllTrim(mv_par01) } )  // Posiciono na primeira Caracteristica a ser copiada
		// Varro o Array
		While cCarac <= mv_par02
		    nAux := Len(aClon)+1
			AAdd( aClon , QP010Temp(aHeader) )
			For nI := 1 to Len(aCols[1])
				Do Case
					Case nI == nPos
						aClon[nAux][nPos] := cCaracNew
					Case nI == nPosI 
						aClon[nAux][nPosI] := Soma1( aClon[Len(aClon)-1][nI], Len(aClon[Len(aClon)-1][nI]) )
					OtherWise
						aClon[nAux][nI] := aCols[nItem][nI]
				End Case			
			Next
			nItem++ 
			// Copio a linha da caracteristica para a caracteristica nova
			If nItem <= Len(aCols)
				If AllTrim(cCarac) <> AllTrim(aCols[nItem][nPos])
					cCarac := aCols[nItem][nPos]
					cCaracNew := Soma1( AllTrim(cCaracNew) , Len( AllTrim(cCaracNew) ) )
				EndIf 
			Else
				cCarac := mv_par03 // Forca a saida  do loop
			EndIf
		Enddo
	EndIf
	aCols:={}
	if laDel
		AAdd( aClon , QP010Temp(aHeader) ) // Quando uma linha nova foi deletada  
		aClon[Len(aClon)][nPosI] := Soma1( aClon[Len(aClon)-1][nPosI], Len(aClon[Len(aClon)-1][nPosI])) 
	EndIf
EndIf
aCols:=aClone(aClon)   // Copio o array para o Acols  
oGet:oBrowse:Refresh()  
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QP010TEMP ³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 21/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Duplica Caracteristica num array                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q010TEMP(aHeader)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP010Temp(aHeader)
Local aColsTmp := {}
Local nUsadTmp := 0
Local nX
nUsadTmp := Len(aHeader)+1          
//Monta o aCols em um array auxiliar                                                                   
aColsTmp := Array(nUsadTmp)    
nUsadTmp := 0
For nX := 1 To Len(aHeader)
            nUsadTmp++ 
            aColsTmp[nUsadTmp] := CriaVar(aHeader[nX,2],.T.)                                                    
Next nX
aColsTmp[nUsadTmp+1] := .F. 
Return(aColsTmp)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP140COND³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 24.11.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastra condicoes de Teste                     		      ³±±
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

Function QPP140COND(nOpc)

Local cCabec := ""
Local cTitulo   := OemToAnsi(STR0080) //"Condicoes de Teste"
Local nTamLin 	:= 80
Local nPosChave := aScan(aHeader,{ |x| AllTrim(x[2]) == "QK2_CHAVE" } )  
Local lEdit		:= .F.
Local cInf		:= ""
Local nSaveSX8	:= GetSX8Len()  
Local axTextos	:= {} 	//Vetor que contem os textos dos Produtos
Local cChave  	:= ""
Local cEspecie  := "QPPA010 "   //Para gravacao de textos

If Empty(AllTrim(M->QK1_PECA)) .AND. Empty(AllTrim(M->QK1_REV))
	Return .T.
EndIf 

If nOpc == 3 .or. nOpc == 4
	lEdit := .T.
Endif

cCabec      := OemToAnsi(STR0080) //"Condicoes de Teste"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera/obtem a chave de ligacao com o texto da Peca/Rv     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Empty(aCols[n,nPosChave])
	cChave := GetSXENum("QK2", "QK2_CHAVE",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

	aCols[n,nPosChave] := cChave
Else
	cChave := aCols[n,nPosChave]
EndIf
                                              
cInf := AllTrim(M->QK1_PECA) + " " + M->QK1_REV + STR0082 + StrZero(n,Len(QK2->QK2_ITEM)) //" Item - "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Digita os resultados dos Ensaios                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If QO_TEXTO(cChave,cEspecie,nTamlin,cTitulo,cInf, @axtextos,1,cCabec,lEdit)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Texto dos ensaios no QKO						     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QO_GrvTxt(cChave,cEspecie,1,@axTextos) 	//QPPXFUN
Endif

Return .T.

/*/{Protheus.doc} fQPA010Del
Função que apresentará mensagem ao cliente perguntando se gostaria de deletar a caracteristica do Plano de Controle
@type  Function
@author thiago.rover
@since 26/01/2022
@return Caso o cliente confirme a mensagem será excluido o registro da grid e retornado .T.
@return Caso o cliente confirme a mensagem não será excluido o registro da grid e retornado .F.
/*/
Function fQPA010Del(oGet)

Local aArea      := GetArea()
Local lRetorno   := .T.
Local nCont      := 0
Local nPosCodCar := aScan(aHeader, { |x| AllTrim(x[2]) == "QK2_CODCAR" })
Local nPosDel    := Len(aHeader) + 1

aEval( aCols, { |x| Iif(x[nPosDel] == .F. .and. x[nPosCODCAR] == aCols[n, nPosCODCAR], nCont++, nCont)})
If nCont > 1
	lRetorno             := .T.
	aCols[n, nPosCODCAR] := ""
	
Else

	IF (lRetorno := fValCaract(M->QK1_PECA,M->QK1_REV,aCols[n][2],5)) .And. (lRetorno := oGet:LACTIVE .AND. oGet:DELOK(2))
		IF !Atail(aCols[n])  .AND. !Empty(aCols[n, nPosCODCAR])
			IF lDelCaract .Or. MsgYesNo(STR0086,STR0084) //"Será excluido o Item do Plano de Controle, gostaria de prosseguir com a exclusão ?"//"Atenção"
				lDelCaract := .T.
			Else
				lRetorno := .F.		
			Endif
		Endif
	Endif

Endif

If lRetorno 
	Atail(aCols[n]) := ! Atail(aCols[n])
	oGet:ADDLASTEDIT(N)
	oGet:oBrowse:Refresh(.F.)
Endif

RestArea(aArea)	
Return lRetorno

/*/{Protheus.doc} fQPA010Inc
Função que valida a inclusão de uma nova linha e caso o registro da Peça esteja vinculado a algum processo, 
informa que deverá ser realizado uma revisão para incluir
@type  Function
@author thiago.rover
@since 07/02/2022
@return lRetorno - Caso valido retorna .T. permitindo criação de uma nova linha
@return lRetorno - Caso inválido retorna .F. não permitindo a criação de uma nova linha
/*/
Function fQPA010Inc(oGet)

Local aArea    := GetArea()
Local lRetorno := .F.

IF fValCaract(M->QK1_PECA,M->QK1_REV,"",3)
	oGet:LCHGFIELD := .F.
	lRetorno := oGet:ADDLINE() 
Endif	

RestArea(aArea)	

Return lRetorno

/*/{Protheus.doc} fQPA010Edt
Função que executa a validação da permição da edição da linha da grid de caracteristicas
@type  Function
@author thiago.rover
@since 15/02/2022
@return Caso exista vinculo de Peça, Revisão e Caracteristica em movimentações permite a alteração
@return Caso exista vinculo de Peça, Revisão e Caracteristica em movimentações não permite a alteração
/*/
Function fQPA010Edt(oGet)
	Local lRetorno   := .F.
	Local nCont      := 0
	Local nPosCodCar := aScan(aHeader, { |x| AllTrim(x[2]) == "QK2_CODCAR" })
	Local nPosDel    := Len(aHeader) + 1

	aEval( aCols, { |x| Iif(x[nPosDel] == .F. .and. x[nPosCODCAR] == aCols[n, nPosCODCAR], nCont++, nCont)})
	If nCont > 1
		lRetorno := .T.
	Else
		If Empty(aCols[n][2])
			lRetorno := IIF(fValCaract(M->QK1_PECA,M->QK1_REV,"",3),oGet:EditCell(),.F.)
		Else
			lRetorno := IIF(fValCaract(M->QK1_PECA,M->QK1_REV,aCols[n][2],4),oGet:EditCell(),.F.)
		EndIf
	Endif

Return lRetorno

/*/{Protheus.doc} fValCaract
Função que valida se existe cadastro de peça e caracteristicas nas tabelas do PPAP.
@type  Function
@author thiago.rover
@since 14/02/2022
@param  cPeca - Peça 
@param  cRev  - Revisão da Peça
@param  cCaract - Caracteristica da Peça
@param  nOpc - Modo de Operação escolhido pelo usuário 
@return lReturn Caso não exista vinculo da Peça, revisão e Caracteristica em movimentações retorna .T.
@return lReturn Caso exista vinculo da Peça, revisão e Caracteristica em movimentações retorna .F.
/*/
Function fValCaract(cPeca, cRev, cCaract, nOpc)

Local aArea     := GetArea()
Local aSolucao  :={{STR0090}} //#Gere uma nova revisão da peça ou desvincule a característica deste(s) cadastro(s): 
Local lReturn   := .T.

IF nOpc == 4 //Alteração
	//Itens Plano de Controle - Peça+Revisão+Caracteristica
	cQuery := " SELECT QKM_NCAR From "+ RetSqlName("QKM")+" QKM"
	cQuery += " WHERE QKM_FILIAL = '"+xFilial("QKM")+"'"
	cQuery += " AND QKM_PECA = '"+cPeca+"'"
	cQuery += " AND QKM_REV = '"+cRev+"'"
	If !Empty(cCaract)
		cQuery += " AND QKM_NCAR = '"+cCaract+"'"
	Endif
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery) 
								
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QKMTRB",.T.,.T.)

	IF QKMTRB->(!EOF())
		aAdd(aSolucao,_CRLF+"-> "+STR0091) //"Itens Plano de Controle"
	Endif
	QKMTRB->(DBCLOSEAREA())
Endif


DbSelectArea("QM4")
DbSetOrder(3)
If DbSeek(xFilial("QM4") + cPeca + cRev + cCaract)
	aAdd(aSolucao,_CRLF+"-> "+STR0041) //"R&R"
Endif

//Ensaio Dimensional - Peça+Revisão+Caracteristica
cQuery := " SELECT QKB_CARAC From "+ RetSqlName("QKB")+" QKB"
cQuery += " WHERE QKB_FILIAL = '"+xFilial("QKB")+"'"
cQuery += " AND QKB_PECA = '"+cPeca+"'"
cQuery += " AND QKB_REV = '"+cRev+"'"
If !Empty(cCaract)
	cQuery += " AND QKB_CARAC = '"+cCaract+"'"
Endif
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery) 
							
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QKBTRB",.T.,.T.)

IF QKBTRB->(!EOF())
	aAdd(aSolucao,_CRLF+"-> "+STR0043) //"Ensaio Dimensional"
Endif
QKBTRB->(DBCLOSEAREA())


//Ensaio Desempenho - Peça+Revisão+Caracteristica
cQuery := " SELECT QKC_CARAC From "+ RetSqlName("QKC")+" QKC"
cQuery += " WHERE QKC_FILIAL = '"+xFilial("QKC")+"'"
cQuery += " AND QKC_PECA = '"+cPeca+"'"
cQuery += " AND QKC_REV = '"+cRev+"'"
If !Empty(cCaract)
	cQuery += " AND QKC_CARAC = '"+cCaract+"'"
Endif
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery) 
							
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QKCTRB",.T.,.T.)

IF QKCTRB->(!EOF())
	aAdd(aSolucao,_CRLF+"-> "+STR0060) //"Ensaio Desempenho"
Endif
QKCTRB->(DBCLOSEAREA())


//Ensaio Material - Peça+Revisão+Caracteristica
cQuery := " SELECT QKD_CARAC From "+ RetSqlName("QKD")+" QKD"
cQuery += " WHERE QKD_FILIAL = '"+xFilial("QKD")+"'"
cQuery += " AND QKD_PECA = '"+cPeca+"'"
cQuery += " AND QKD_REV = '"+cRev+"'"
If !Empty(cCaract)
	cQuery += " AND QKD_CARAC = '"+cCaract+"'"
Endif
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery) 
							
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QKDTRB",.T.,.T.)

IF QKDTRB->(!EOF())
	aAdd(aSolucao,_CRLF+"-> "+STR0044) //"Ensaio Material"
Endif
QKDTRB->(DBCLOSEAREA())


//Capabilidade - Peça+Revisão+Caracteristica
DbSelectArea("QK9")
DbSetOrder(1)
If DbSeek(xFilial("QK9") + cPeca + cRev + cCaract)
	aAdd(aSolucao,_CRLF+"-> "+STR0042) //"Capabilidade"
Endif

If Len(aSolucao) > 1

	IF nOpc == 3 //Inclusão
		//#Atenção
		//#Esta peça possui movimentações que impedem a inclusão de uma nova característica nesta revisão.
		//#Gere uma nova revisão da peça ou desvincule a peça deste(s) cadastro(s):
		aSolucao[1] := STR0089
		Help(NIL, NIL, STR0084, NIL, STR0087, 1, 0, NIL, NIL, NIL, NIL, NIL, aSolucao) 

	Elseif nOpc == 4 //Alteração
	
		//#Atenção
		//#Esta peça possui movimentações que impedem a alteração desta característica.
		//#Gere uma nova revisão da peça ou desvincule a característica deste(s) cadastro(s): 
		Help(NIL, NIL, STR0084, NIL, STR0085, 1, 0, NIL, NIL, NIL, NIL, NIL, aSolucao) 

	Else
		//#Atenção
		//#Esta peça possui movimentações que impedem a exclusão desta característica.
		//#Gere uma nova revisão da peça ou desvincule a característica deste(s) cadastro(s): 
		Help(NIL, NIL, STR0084, NIL, STR0058, 1, 0, NIL, NIL, NIL, NIL, NIL, aSolucao) 
	Endif

	lReturn := .F.	

Endif

RestArea( aArea )

Return lReturn


