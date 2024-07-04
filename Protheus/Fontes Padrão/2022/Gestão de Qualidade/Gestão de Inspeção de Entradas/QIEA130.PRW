#INCLUDE "QIEA130.CH"
#INCLUDE "PROTHEUS.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIEA130  ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 09/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Skip-Teste por Grupo            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Vera        ³14/04/99³------³ Inclusao da Loja do Fornecedor           ³±±
±±³Antonio     ³24/01/99³------³ Aumento das caixas de texto para         ³±±
±±³            ³        ³      ³ tratamento de Fornec. de ate 20 caract.  ³±±
±±³            ³        ³      ³ e alguns ajustes de vari veis.           ³±±
±±³Marcelo     ³25/04/00³------³ Incluido o quinto parametro como 3 no    ³±±
±±³Marcelo     ³25/04/00³------³ array aRotina.                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0004),"AxPesqui"  , 0 , 1,,.F.},;  	// "Pesquisar"
					{OemToAnsi(STR0005),"QIE130Visu"  , 0 , 2},; // "Visualizar"
					{OemToAnsi(STR0006),"QIE130Incl"  , 0 , 3},; // "Incluir"
					{OemToAnsi(STR0007),"QIE130Alte"  , 0 , 6},; // "Alterar"
					{OemToAnsi(STR0008),"QIE130Del"  , 0 , 5 , 3} } // "Excluir"

Return aRotina

Function QIEA130
Private aCRA := { OemToAnsi(STR0001), OemToAnsi(STR0002), OemToAnsi(STR0003) }  //"Confirma" ### "Redigita" ### "Abandona"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0009)  //"Skip-Teste por Grupo"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//³    6 - Nao permite inclusao na getdados                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"QEI")

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QIE130Visu³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 09/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao Skip-Teste Grupo  -  Incl./Alter.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIE130Visu(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION QIE130Visu(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local cRevi		:= 0
Local oGet_1	:= NIL
Local oGet_2	:= NIL
Local oGet_3   := NIL
Local oBox

Private cIE130For := Space(TamSX3("QEI_FORNEC")[1])
Private cIE130Gru := Space(TamSX3("QEI_GRUPO")[1])
Private cIE130LjF := Space(TamSX3("QEI_LOJFOR")[1])
Private aHeader	:= {}
Private aCols 		:= {}
Private aEnsaios	:= {}
Private nUsado		:= 0

Private nPosEns	:= 0
Private nPosSkT	:= 0
Private nPosSkI 	:= 0
Private oGet		:= NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX2")  // Posiciona pq. rotinas internas utilizam inf. do SX2
dbSeek("QEI")

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0009) ;
					FROM 150,3 TO 388,613 OF oMainWnd PIXEL	// "Skip-Teste Grupo"

@ 000,000 SCROLLBOX oBox SIZE 0,0 OF oDlg

cIE130For := QEI->QEI_FORNEC
cIE130LjF := QEI->QEI_LOJFOR
cIE130Gru := QEI->QEI_GRUPO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets do Fornecedor                         				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 5,03 SAY TitSX3("QEI_FORNEC")[1] SIZE 56,07 OF oBox PIXEL  
@ 3,61 MSGET oGet_1 VAR cIE130For PICTURE PesqPict("SA2","A2_COD") ;
						WHEN .F. ;			
						SIZE 66,10 OF oBox PIXEL  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets da Loja                               				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 5,131 SAY TitSX3("QEI_LOJFOR")[1] SIZE 56, 7 OF oBox PIXEL 
@ 3,189 MSGET oGet_2 VAR cIE130LjF PICTURE PesqPict("SA5","A5_LOJA") ;
						WHEN .F. ;
					   SIZE 15,10 OF oBox PIXEL						
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets da Grupo                              				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 20, 3 SAY   TitSX3("QEI_GRUPO")[1] SIZE 56,7 OF oBox PIXEL		//"Grupo"
@ 18,61 MSGET oGet_3 VAR cIE130Gru PICTURE PesqPict("QE3","QE3_GRUPO") ;
								WHEN .F. ;								
								SIZE 66,10 OF oBox PIXEL
@ 20,131 SAY QIEXDeGr(cIE130Gru) SIZE 130,7 OF oBox PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader e aCols a ser utilizado na getdados      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Q130FGet(cRevi,nOpc,oDlg)

oGet:= MSGetDados():New(50,2,190,312,nOpc ,"AllwaysTrue","AllwaysTrue","",.F.)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGet:Refresh()
	
ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}),;
								AlignObject(oDlg,{oBox,oGet:oBrowse},1,,{75}))
	
dbSelectArea(cAlias)
dbGoto(nReg)

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QIE130Incl³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 09/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao Skip-Teste Grupo  -  Incl./Alter.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIE130Incl(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIE130Incl(cAlias,nReg,nOpc)

Local nI			:= 0
Local cRevi		:= ""
Local lGravaOk := .F.
Local oDlg		:= NIL
Local oGet_1 	:= NIL
Local oGet_2 	:= NIL
Local oGet_3 	:= NIL
Local oBox

Private cIE130For := Space(TamSX3("QEI_FORNEC")[1])
Private cIE130LjF := Space(TamSX3("QEI_LOJFOR")[1])
Private cIE130Gru := Space(TamSX3("QEI_GRUPO")[1])
Private nPosEns	:= 0
Private nPosSkT	:= 0
Private nPosSkI 	:= 0
Private nUsado		:= 0
Private aHeader	:= {}
Private aCols		:= {}
Private oGet		:= NIL
Private aEnsaios	:= {}

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0009) ;
				FROM 150,3 TO 388,613 OF oMainWnd PIXEL	// "Skip-Teste Grupo"

@ 000,000 SCROLLBOX oBox SIZE 0,0 OF oDlg

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets do Fornecedor                         				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 5,03 SAY TitSX3("QEI_FORNEC")[1] SIZE 56,07 OF oBox PIXEL  
@ 3,61 MSGET oGet_1 VAR cIE130For PICTURE PesqPict("SA2","A2_COD") ;
						F3 "QFO" ;
						VALID	ExistCpo("SA2",cIE130For) ;
						SIZE 58,10 OF oBox PIXEL  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets da Loja                               				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 5,131 SAY TitSX3("QEI_LOJFOR")[1] SIZE 56, 7 OF oBox PIXEL 
@ 3,189 MSGET oGet_2 VAR cIE130LjF PICTURE PesqPict("SA5","A5_LOJA") ;
						  VALID ExistCpo("SA2",cIE130For+cIE130LjF) ;
						  SIZE 15,10 OF oBox PIXEL
@ 5,208 SAY QIEXDeFo(cIE130For,cIE130LjF,2) SIZE 80,7 OF oBox PIXEL 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets da Grupo                              				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 20, 3 SAY   TitSX3("QEI_GRUPO")[1] SIZE 56,7 OF oBox PIXEL		//"Grupo"
@ 18,61 MSGET oGet_3 VAR cIE130Gru PICTURE PesqPict("QE3","QE3_GRUPO") F3 "QE3";
								VALID ExistCpo("QE3",cIE130Gru) .And. ;
								ExistCpo2("QEA",cIE130Gru,,STR0010);	//"Grupo n„o tem Produtos associados"
								.And. A130aCols(@cRevi,nOpc,oDlg) .And. oGet:oBrowse:Refresh() ;
								SIZE 58,10 OF oBox PIXEL
@ 20,131 SAY QIEXDeGr(cIE130Gru) SIZE 130,7 OF oBox PIXEL


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O parƒmetro nOpc que corresponde ao aRotina[3][4] ‚ alterado ³
//³  para 6, indicando 'alteracao.  Isto ‚ necess rio para nÆo'  ³
//³  permitir a inclusÆo de linhas na GetDados                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
aRotina[3][4] := 6 // {OemToAnsi(STR0006),"QIE130Incl"  , 0 , 6}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader e aCols a ser utilizado na getdados      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Q130FGet(cRevi,nOpc,oDlg)

oGet:= MSGetDados():New(50, 2, 240, 350, nOpc, "AllwaysTrue", "AllwaysTrue", "", .T.,,,,,,,, "QE130VlDel")
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(;
	oDlg, {|| IIf(lGravaOk:=QI130TdOk(), oDlg:End(),)},;
	{||oDlg:End(),lGrava:=.F. } ),;
	AlignObject(oDlg,{oBox,oGet:oBrowse},1,,{75});
	)

aRotina[3][4] := 3 

If lGravaOk
	Begin Transaction
		lGravaOk := A130GrvST()
		nReg := QEI->(Recno())  // Torno o novo como atual.
		If !lGravaOK
			Help(" ",1,"A010NAOGRV")
		Else
			//Processa Gatilhos
			EvalTrigger()
		EndIf
	End Transaction
EndIf

dbSelectArea(cAlias)
dbGoto(nReg)

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³QIE130Alte³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 09/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Programa de atualizacao Skip-Teste Grupo  -  Incl./Alter.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIE130Alte(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIE130Alte(cAlias,nReg,nOpc)

Local cRevi		:= ""
Local lGravaOk := .F.
Local oDlg		:= NIL
Local oGet_1 	:= NIL
Local oGet_2 	:= NIL
Local oGet_3 	:= NIL
Local oBox

Private cIE130For := Space(TamSX3("QEI_FORNEC")[1])
Private cIE130LjF := Space(TamSX3("QEI_LOJFOR")[1])
Private cIE130Gru := Space(TamSX3("QEI_GRUPO")[1])
Private nPosEns	:= 0
Private nPosSkT	:= 0
Private nPosSkI 	:= 0
Private nUsado		:= 0
Private aHeader	:= {}
Private aCols		:= {}
Private oGet		:= NIL
Private aEnsaios	:= {}

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0009) ;
				FROM 150,3 TO 388,613 OF oMainWnd PIXEL	// "Skip-Teste Grupo"

@ 000,000 SCROLLBOX oBox SIZE 0,0 OF oDlg

cIE130For := QEI->QEI_FORNEC
cIE130LjF := QEI->QEI_LOJFOR
cIE130Gru := QEI->QEI_GRUPO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets do Fornecedor                         				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 5,03 SAY TitSX3("QEI_FORNEC")[1] SIZE 56,07 OF oBox PIXEL  
@ 3,61 MSGET oGet_1 VAR cIE130For PICTURE PesqPict("SA2","A2_COD") ;
					WHEN .F. ;			
					SIZE 66,10 OF oBox PIXEL  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets da Loja                               				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 5,131 SAY TitSX3("QEI_LOJFOR")[1] SIZE 56, 7 OF oBox PIXEL 
@ 3,189 MSGET oGet_2 VAR cIE130LjF PICTURE PesqPict("SA5","A5_LOJA") ;
					WHEN .F. ;
				   SIZE 15,10 OF oBox PIXEL						
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets da Grupo                              				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 20, 3 SAY   TitSX3("QEI_GRUPO")[1] SIZE 56,7 OF oBox PIXEL		//"Grupo"
@ 18,61 MSGET oGet_3 VAR cIE130Gru PICTURE PesqPict("QE3","QE3_GRUPO") ;
							WHEN .F. ;								
							SIZE 66,10 OF oBox PIXEL
@ 20,131 SAY QIEXDeGr(cIE130Gru) SIZE 130,7 OF oBox PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader e aCols a ser utilizado na getdados      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Q130FGet(cRevi,nOpc,oDlg)

oGet:= MSGetDados():New(50,2,190,312,nOpc,"AllwaysTrue","AllwaysTrue","",.T.,,,,,,,,"QE130VlDel")
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,;
				{|| IIf(lGravaOk:=QI130TdOk(), oDlg:End(),)},{||lGrava:=.F., oDlg:End()} ),;
				AlignObject(oDlg,{oBox,oGet:oBrowse},1,,{75}))

If lGravaOk
	Begin Transaction
		lGravaOk := A130GrvST()
		nReg := QEI->(Recno())  // Torno o novo como atual.
		If !lGravaOK
			Help(" ",1,"A010NAOGRV")
		Else
			//Processa Gatilhos
			EvalTrigger()
		EndIf
	End Transaction
EndIf

dbSelectArea(cAlias)
dbGoto(nReg)

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³QIE130Del ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 09/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Programa de atualiza‡Æo Skip-Teste Grupo  -  Incl./Alter.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIE130Del(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIE130Del(cAlias,nReg,nOpc)

Local cRevi		:= ""
Local oDlg		:= NIL
Local oGet_1	:= NIL
Local oGet_2	:= NIL
Local oGet_3	:= NIL
Local lDeleta  := .T.
Local oBox

Private cIE130For := Space(TamSX3("QEI_FORNEC")[1])
Private cIE130LjF := Space(TamSX3("QEI_LOJFOR")[1])
Private cIE130Gru := Space(TamSX3("QEI_GRUPO")[1])
Private aHeader 	:= {}
Private aCols		:= {}
Private nUsado		:= 0
Private oGet		:= NIL
Private cCod		:= ""
Private cChvQEZ	:= ""
Private aEnsaios	:= {}
Private nPosEns	:= 0
Private nPosSkT	:= 0
Private nPosSkI	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX2")  // Posiciona pq. rotinas internas utilizam inf. do SX2
dbSeek("QEI")

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0009) FROM 150,3 TO 388,613 OF oMainWnd PIXEL	// "Skip-Teste Grupo"

@ 000,000 SCROLLBOX oBox SIZE 0,0 OF oDlg

cIE130For := QEI->QEI_FORNEC
cIE130LjF := QEI->QEI_LOJFOR
cIE130Gru := QEI->QEI_GRUPO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets do Fornecedor                         				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 5,03 SAY TitSX3("QEI_FORNEC")[1] SIZE 56,07 OF oBox PIXEL  
@ 3,61 MSGET oGet_1 VAR cIE130For PICTURE PesqPict("SA2","A2_COD") ;
					WHEN .F. ;			
					SIZE 66,10 OF oBox PIXEL  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets da Loja                               			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 5,131 SAY TitSX3("QEI_LOJFOR")[1] SIZE 56, 7 OF oBox PIXEL 
@ 3,189 MSGET oGet_2 VAR cIE130LjF PICTURE PesqPict("SA5","A5_LOJA") ;
					WHEN .F. ;
				   SIZE 15,10 OF oBox PIXEL						
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets da Grupo                              			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 20, 3 SAY   TitSX3("QEI_GRUPO")[1] SIZE 56,7 OF oBox PIXEL		//"Grupo"
@ 18,61 MSGET oGet_3 VAR cIE130Gru PICTURE PesqPict("QE3","QE3_GRUPO") ;
							WHEN .F. ;								
							SIZE 66,10 OF oBox PIXEL
@ 20,131 SAY QIEXDeGr(cIE130Gru) SIZE 130,7 OF oBox PIXEL
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader e aCols a ser utilizado na getdados      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Q130FGet(cRevi,nOpc,oDlg)

oGet:= MSGetDados():New(50,2,190,312,nOpc,"AllwaysTrue","AllwaysTrue","",.F.)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,;
					{||oDlg:End(),lDeleta:=.T.},	{||oDlg:End(),lDeleta:=.F.} ),;
				AlignObject(oDlg,{oBox,oGet:oBrowse},1,,{75}))

If lDeleta
	Begin Transaction
		dbSelectArea(cAlias)
		cCod := cIE130For+cIE130LjF+cIE130Gru
		dbSetOrder(1)
		dbSeek(xFilial("QEI")+cCod)
		While !Eof() .And. xFilial("QEI") == QEI_FILIAL .And. ;
			cCod == QEI_FORNEC+QEI_LOJFOR+QEI_GRUPO
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta o registro                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock(cAlias,.F.,.T.)
			dbDelete()
			MsUnLock()
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta o Controle Skip-Teste por Grupo                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QEO->(dbSetOrder(1))
			If QEO->(dbSeek( xFilial("QEO")+cCod+QEI->QEI_ENSAIO ))
				RecLock("QEO", .F.)
				QEO->(dbDelete())
				MsUnLock()
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta o Historico Skip-Teste do Ensaio                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cChvQEZ := QEI->QEI_FORNEC+QEI->QEI_LOJFOR+QEI->QEI_GRUPO+QEI->QEI_ENSAIO
			QEZ->(dbSetOrder(2))
			QEZ->(dbSeek(xFilial("QEZ")+cChvQEZ))
			While QEZ->QEZ_FILIAL+QEZ->QEZ_FORNEC+QEZ->QEZ_LOJFOR+QEZ->QEZ_GRUPO+;
				QEZ->QEZ_ENSAIO == xFilial("QEZ")+cChvQEZ .And. !QEZ->(Eof())
				RecLock("QEZ", .F.)
				QEZ->(dbDelete())
				MsUnLock()
				QEZ->(dbSkip())
			Enddo
			QEZ->(dbSetOrder(1))
			dbSelectArea("QEI")
			dbSkip()
		EndDo	
	End Transaction
EndIf

dbSelectArea(cAlias)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A130GrvST ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 10/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os Skip-Testes por Grupo                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A130GrvST()

Local nx ,ny , nMaxArray := Len(aCols)
Local cChvQEZ
Local nOrdSA2 := SA2->(IndexOrd())
Local nOrdQE3 := QE3->(IndexOrd())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Revalido os dados                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA2->(dbSetOrder(1))
If !SA2->(dbSeek(xFilial("SA2")+cIE130For+cIE130LjF))
	SA2->(dbSetOrder(nOrdSA2))
	Return .F.
EndIf
SA2->(dbSetOrder(nOrdSA2))

QE3->(dbSetOrder(1))
If !QE3->(dbSeek(xFilial("QE3")+cIE130Gru))
	QE3->(dbSetOrder(nOrdQE3))
	Return .F.
EndIf
QE3->(dbSetOrder(nOrdQE3))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o arquivo QEI                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QEI")
QEI->(dbSetOrder(1))

For nX := 1 to nMaxArray
	dbSelectArea("QEI")
	If !Acols[nX][nUsado+1]	.And. ;// Nao esta deletado
			!Empty(aCols[nX][nPosSkT]) // Skip-Teste nao vazio
		If dbSeek(xFilial("QEI")+cIE130For+cIe130LjF+cIE130Gru+aCols[nX][nPosEns])
			RecLock("QEI",.F.)   // Lock
		Else
			RecLock("QEI",.T.)   // Append
			QEI->QEI_FILIAL := xFilial("QEI")
			QEI->QEI_FORNEC := cIE130For
			QEI->QEI_LOJFOR := cIE130LjF
			QEI->QEI_GRUPO  := cIE130Gru
			QEI->QEI_ENSAIO := aCols[nX][nPosEns]
		Endif

		For ny := 1 to Len(aHeader)
			If aHeader[ny][10] <> "V"
				cVar := alltrim(aHeader[ny][2])
				Replace &cVar. With aCols[nx][ny]
			Endif
		Next ny
		MsUnLock()
	Else	// Se cancelou ou alterou para zero
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cancela o Skip-Teste do Ensaio        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If dbSeek(xFilial("QEI")+cIE130For+cIE130LjF+cIE130Gru+aCols[nX][nPosEns])
			RecLock("QEI",.F.)
			dbDelete()
			MsUnLock()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta o Controle Skip-Teste por Grupo                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QEO->(dbSetOrder(1))
			If QEO->(dbSeek(xFilial("QEO")+cIE130For+cIe130LjF+cIE130Gru+aCols[nX][nPosEns]))
				RecLock("QEO", .F.)
				QEO->(dbDelete())
				MsUnLock()
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta o Historico Skip-Teste do Ensaio                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cChvQEZ := QEI->QEI_FORNEC+QEI->QEI_LOJFOR+QEI->QEI_GRUPO+QEI->QEI_ENSAIO
			QEZ->(dbSetOrder(2))
			QEZ->(dbSeek(xFilial("QEZ")+cChvQEZ))
			While QEZ->QEZ_FILIAL+QEZ->QEZ_FORNEC+QEZ->QEZ_LOJFOR+QEZ->QEZ_GRUPO+;
					QEZ->QEZ_ENSAIO == xFilial("QEZ")+cChvQEZ .And. !QEZ->(Eof())
				RecLock("QEZ", .F.)
				QEZ->(dbDelete())
				MsUnLock()
				QEZ->(dbSkip())
			Enddo
			QEZ->(dbSetOrder(1))
		EndIf
	EndIf
Next nx

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A130WhST ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 10/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define a clausula WHEN para o campo Skip-Teste             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A130WhST()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A130WhST()
Local lRetu := .t.
Local nPos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se j  definiu o skip-teste individual      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := aScan(aEnsaios, { |x| x[1] == aCols[n][nPosEns] })
If nPos < 1
	Help(" ",1,"A130GRUVAZ")	// "Grupo de Produtos nao tem ensaios em comum"
	lRetu := .F.
Else	
	If aEnsaios[nPos][3] <> 0 
		MsgInfo(OemToAnsi(STR0011),OemToAnsi(STR0009)) // "O Skip-Teste referente a ensaio est  definido como individual."  "Skip-Teste por Grupo"
		lRetu := .F.
	EndIf
EndIf

Return(lRetu)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A130Acols³ Autor ³ Marcelo/Vera          ³ Data ³ 16/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega vetor aCols para a GetDados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A130Acols(ExpC1,ExpN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Revisao do Produto                                  ³±±
±±³          ³ ExpN1: Opcao selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A130Acols(cRevi,nOpc,oDlg)
Local n
Local nI := 0   
Local nX

nUsado := Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda as posicoes dos campos p/ posterior consistencia      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosEns := aScan(aHeader, { |x| alltrim(x[2]) == 'QEI_ENSAIO' })
nPosSkT := aScan(aHeader, { |x| alltrim(x[2]) == 'QEI_SKPTES' })
nPosAli := aScan(aHeader, { |x| alltrim(x[2]) == 'QEI_ALI_WT' })
nPosRec := aScan(aHeader, { |x| alltrim(x[2]) == 'QEI_REC_WT' })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona os Ensaios comuns dos Produtos deste Grupo         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEnsaios:={}

QEA->(dbSetOrder(1))
If QEA->(dbSeek(xFilial("QEA")+cIE130Gru))
	While QEA->QEA_FILIAL+QEA->QEA_GRUPO == xFilial("QEA")+cIE130Gru .And. !QEA->(Eof())
		// Identifica os ensaios mensuraveis
		If QE7->(dbSeek(xFilial("QE7")+QEA->QEA_PRODUT))
			While QE7->QE7_FILIAL+QE7->QE7_PRODUT == ;
				xFilial("QE7")+QEA->QEA_PRODUT .And. !QE7->(Eof())
				nPos := Ascan(aEnsaios, { |x| x[1] == QE7->QE7_ENSAIO })
				If nPos == 0
					Aadd(aEnsaios, { QE7->QE7_ENSAIO, 1, 0 })	// Ensaio, ocorr. e S.T. Indiv.
					nPos := Len(aEnsaios)
				Else
					aEnsaios[nPos][2]++
				EndIf
				QEH->(dbSetOrder(1))
				If QEH->(dbSeek( xFilial("QEH")+cIE130For+cIE130LjF+QEA->QEA_PRODUT+QE7->QE7_ENSAIO))
					aEnsaios[nPos][3] := QEH->QEH_SKPTES
				EndIf
				QE7->(dbSkip())
			EndDo
		EndIf

		// Identifica os ensaios texto
		QE8->(dbSetOrder(1))
		If QE8->(dbSeek(xFilial("QE8")+QEA->QEA_PRODUT))
			While QE8->QE8_FILIAL+QE8->QE8_PRODUT == ;
				xFilial("QE8")+QEA->QEA_PRODUT .And. !QE8->(Eof())
				nPos := Ascan(aEnsaios, { |x| x[1] == QE8->QE8_ENSAIO })
				If nPos == 0
					Aadd(aEnsaios, { QE8->QE8_ENSAIO, 1, 0 })	// Ensaio, ocorr. e S.T. Indiv.
					nPos := Len(aEnsaios)
				Else
					aEnsaios[nPos][2]++
				EndIf
				QEH->(dbSetOrder(1))
				If QEH->(dbSeek( xFilial("QEH")+cIE130For+cIE130LjF+QEA->QEA_PRODUT+QE8->QE8_ENSAIO))
					aEnsaios[nPos][3] := QEH->QEH_SKPTES
				EndIf
				QE8->(dbSkip())
			EndDo
		EndIf
		QEA->(dbSkip())
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o aCols                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta vetor aCols com os Ensaios comuns do Grupo              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to Len(aEnsaios)
	aadd(aCols,Array(nUsado+1))	// Cria novo elemento no acols
	nCnt := Len(aCols)
	// Alimenta o aCols
	aCols[nCnt][ascan(aHeader,{|x| alltrim(x[2])=='QEI_ENSAIO'})] := aEnsaios[nI][1]
	aCols[nCnt][ascan(aHeader,{|x| alltrim(x[2])=='QEI_DESENS'})] := QIEXDeEn(aEnsaios[nI][1])
	aCols[nCnt][ascan(aHeader,{|x| alltrim(x[2])=='QEI_SKPIND'})] := aEnsaios[nI][3]

	QEI->(dbSetOrder(1))
	If QEI->(dbSeek(xFilial("QEI")+cIE130For+cIE130LjF+cIE130Gru+aEnsaios[nI][1]))
		aCols[nCnt][nPosSkT] := QEI->QEI_SKPTES
	Else
		aCols[nCnt][nPosSkT] := 0
	EndIf
	If nPosAli > 0 .and. nPosRec > 0
	aCols[Len(aCols),nPosAli] := "QEI"
		If IsHeadRec(aHeader[nPosRec,2])
			aCols[Len(aCols),nPosRec] := QEI->(RecNo())
		EndIf
	Endif
	aCols[nCnt][nUsado+1] := .F.
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ordena Ensaios de acordo com o campo Ensaio                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols := asort(aCols,,, { | x,y | x[nPosEns] < y[nPosEns] } )

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QE130VlDel³ Autor ³ Eduardo de Souza      ³ Data ³ 21/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se linha pode ser deletada.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QE130VlDel()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QE130VlDel()

Local lRet:= .T.

If Acols[n,nPosSkT] == 0
	lRet:= .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q130FGet  ³ Autor ³ Rafael S. Bernardi    ³ Data ³ 30/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o aHeader e aCols usando FillGetDados                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q130FGet(cRevi,nOpc,oDlg)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q130FGet(cRevi,nOpc,oDlg)

If nOpc != 3
	FillGetDados(nOpc,"QEI",1      ,       ,           ,         ,         ,          ,        ,       ,{|| A130aCols(@cRevi,nOpc,@oDlg)},       ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols                         ,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
Else
	FillGetDados(nOpc,"QEI",1     ,      ,             ,         ,         ,          ,        ,       ,                                 ,  .T.  ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile   ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty                 ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
EndIf

dbSelectArea("SX3")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} QI130TdOk
Função de validação de linha
@author marco.guimaraes
@since 15/09/14
@return lRet
/*/
//-------------------------------------------------------------------
Function QI130TdOk()
Local lRet := .T.
Local nSkpTeste := aScan(aHeader, { |x| alltrim(x[2]) == 'QEI_SKPTES' })
Local nEnsaio := aScan(aHeader, { |x| alltrim(x[2]) == 'QEI_ENSAIO' })
Local cMsgErro := "" 
Local i:= 0

For i := 1 To Len(aCols)
	If aCols[i, nSkpTeste] < 1
		cMsgErro += "<br>" + aCols[i, nEnsaio] 
	EndIf
Next

If !Empty(cMsgErro) 
	lRet := .F.
	Help("", 1, "QI130SKTT",, STR0012 + cMsgErro, 4, 1) // Valor inválido do Skip-Teste para o(os) ensaio(os):
EndIf

Return lRet