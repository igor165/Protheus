#include "QIPA160.CH"
#include "PROTHEUS.CH"
#Define USADO Chr(0)+Chr(0)+Chr(1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Qipa160  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 07/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa Atualizacao dos C¢digos das Amostras              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigaqip                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo       ³25/04/00³------³ Incluido o quinto parametro como 3 no  ³±±
±±³Marcelo       ³25/04/00³------³ array aRotina.                         ³±±
±±³Paulo Emidio  ³17/07/00³------³ Definicao da descricao "Tam.Lote" como ³±±
±±³              ³        ³      ³ STR0017                                ³±±
±±³Eduardo S.    ³20/01/03³061871³ Acerto para verificar corretamente a   ³±±
±±³              ³        ³      ³ atualizacao do tamanho das amostras.   ³±±
±±³Eduardo S.    ³24/02/03³------³ Incluido o ponto de entrada "QP220J25".³±±
±±³Cleber Souza  ³07/06/03³------³ Incluido o ponto de entrada "QP160J01".³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()

Local aRotina := {	{OemToAnsi(STR0001),"AxPesqui"	,0	, 1,,.F.},;//"Pesquisar"
						{OemToAnsi(STR0002),"Qip160Visu",0	, 2  },; //"Visualizar"
						{OemToAnsi(STR0003),"Qip160Incl",0 , 3   },; //"Incluir"
						{OemToAnsi(STR0004),"Qip160Alte",0 , 4   },; //"Alterar"
						{OemToAnsi(STR0005),"Qip160Dele",0 , 5,3 },; //"Excluir"
						{OemToAnsi(STR0006),"A160Amost" ,0 , 4 } }	 //"Tam.Amostra"

Return aRotina

Function QIPA160()
PRIVATE cCadastro:=OemToAnsi(STR0007)	//"Plano de Amostragem"
Private lEspRet := .F.

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
//³    6 - Altera determinados campos sem incluir novos Regs     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina := MenuDef()

QA6->(dbSetOrder(2))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse(6,1,22,75,"QA6")
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Qip160Visu³ Autor ³ Marcelo Pimentel      ³ Data ³ 21/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa atualizacao C¢digo de Amostras - Visualizacao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Qip160Visu(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qip160Visu(cAlias,nReg,nOpcx)

Local oDlg
Local oGet
Local oBox
Local nCnt
Local nOpca			:= 0  
Local nOrdem		:= QA6->(IndexOrd())
Local cSeek			:= ""
Local cWhile		:= ""
Local aNoFields		:= {}

Private cPlanoAmos  := QA6_PLANO
Private cIP160Nivel := QA6_NIVEL
Private nLotInf
Private nLotSup
Private nLotAmo
Private cIP160Desc 	:= ""
Private cDescPlano	:= Tabela("QI", cPlanoAmos, .F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCols 		:= {}
Private aHeader[0]
Private nUsado 		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no arquivo Plano de Amostragem p/ mostrar a descri‡Æo.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QQB->(dbSetOrder(2))

If QQB->(dbSeek(xFilial("QQB")+cPlanoAmos+cIP160Nivel))
	cIP160Desc := QQB->QQB_DESCRI
EndIf

cWhile  	:= Alltrim(RetSIX(cAlias,"2",.T.,{"STR(QA6_LOTSUP,8)"}))
cSeek 		:= Alltrim(RetSIX(cAlias,"2",.T.,{"STR(QA6_LOTSUP,8)"}))                        
aNoFields   := {"QA6_PLANO","QA6_DPLANO","QA6_NIVEL"}

FillGetDados(	nOpcx,; 								// numero correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
               	cAlias,;       							// area a ser utilizada;
               	2,;      								// nOrdem - ordem correspondente a chave de índice para preencher o  acols;
               	Iif((nOpcx == 3),'',&cSeek),;  			// chave utilizada no posicionamento da área para preencher o acols; 
               	{|| &cWhile},; 	// bloco contendo a expressão a ser comparada com cSeekKey na condição  do While. 
               	{|| .T.},;  							// uSeekFor
               	aNoFields,;  						 	// aNoFields - array contendo os campos que não estarao no aHeader;
               	,;  									// aYesFields - array contendo somente os campos que estarao no aHeader;
               	.F.,;      								// se verdadeiro, exibe apenas os campos de usuário;
                '',;      								// cQuery - query a ser executada para preencher o acols;
               	,;    				   					// bloco contendo funcao especifica para preencher o aCols; 
               	Iif((nOpcx == 3),.T.,.F.),;  			// lEmpty 
               	,; 										// aHeaderAux
               	,; 		   								// aColsAux
               	,; 										// bAfterCols
               	,; 										// bBeforeCols
               	,; 										// bAfterHeader
               	'') 									// cAliasQry

nUsado := Len(aHeader)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a posicao dos campos no aHeader p/ posterior consistencia   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLotInf := Ascan(aHeader,{|x| x[2] == "QA6_LOTINF"})
nLotSup := Ascan(aHeader,{|x| x[2] == "QA6_LOTSUP"})
nLotAmo := Ascan(aHeader,{|x| x[2] == "QA6_CODAMO"})

nOpca	:= 0
DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0007) From 150,1 To 451,601 OF oMainWnd PIXEL		//"Plano de Amostragem"

@ 000,000 SCROLLBOX oBox SIZE 0,0 OF oDlg

@ 4,4  SAY OemToAnsi(STR0019) SIZE 50,7 OF oBox PIXEL		//"Plano Amostr."
@ 4,40 SAY cPlanoAmos + " - " + Tabela("QI", cPlanoAmos, .F.) SIZE  180,10 OF oBox PIXEL

@ 19,4  SAY OemToAnsi(STR0008) SIZE 50,7 OF oBox PIXEL		//"Tipo de Plano"
@ 19,40 SAY cIP160Nivel+" - "+ShowDescr(cPlanoAmos,cIP160Nivel) SIZE  180,10 OF oBox PIXEL

oGet:= MSGetDados():New(48,5,143,296,nOpcx,"AllwaysTrue","AllwaysTrue")
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nopca:=1,oDlg:End()},{||oDlg:End()}),;
					AlignObject(oDlg,{oBox,oGet:oBrowse},1,,{70}))
lEdita := .T.

nOpca := 0   
QA6->(dbSetOrder(nOrdem))
dbSelectArea(cAlias)
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Qip160Incl³ Autor ³ Marcelo Pimentel      ³ Data ³ 21/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa Atualizacao C¢digo do Plano de Amostragem - Incl. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void Qip160Incl(ExpC1,ExpN1,ExpN2)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qip160Incl(cAlias,nReg,nOpcx)

Local oDlg
Local oGet
Local oBox
Local nCnt
Local nOpca			:= 0 
Local cPictPro 		:= '@!'
Local cSeek			:= ""
Local cWhile		:= ""
Local lGravaOk 		:= .T.
Local aAlter		:= {}
Local aNoFields		:= {}
Local nOrdem		:= QA6->(IndexOrd())

Private cPlanoAmos  := CriaVar("QA6_PLANO")
Private cIP160Nivel := CriaVar("QA6_NIVEL")
Private nLotInf
Private nLotSup
Private nLotAmo
Private cIP160Desc 	:= CriaVar("QQB_DESCRI") 
Private cPlanoDesc	:= CriaVar("QQB_DPLANO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCols 		:= {}
Private aHeader[0]
Private nUsado 		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no arquivo Plano de Amostragem p/ mostrar a descri‡Æo.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QQB->(dbSetOrder(2))

cWhile  	:= Alltrim(RetSIX(cAlias,"2",.T.,{"STR(QA6_LOTSUP,8)"}))
cSeek 		:= Alltrim(RetSIX(cAlias,"2",.T.,{"STR(QA6_LOTSUP,8)"}))                        
aNoFields   := {"QA6_PLANO","QA6_DPLANO","QA6_NIVEL"}

FillGetDados(	nOpcx,; 								// numero correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
               	cAlias,;       							// area a ser utilizada;
               	2,;      								// nOrdem - ordem correspondente a chave de índice para preencher o  acols;
               	Iif((nOpcx == 3),'',&cSeek),;  			// chave utilizada no posicionamento da área para preencher o acols; 
               	{|| &cWhile},; 	// bloco contendo a expressão a ser comparada com cSeekKey na condição  do While. 
               	{|| .T.},;  							// uSeekFor
               	aNoFields,;  						 	// aNoFields - array contendo os campos que não estarao no aHeader;
               	,;  									// aYesFields - array contendo somente os campos que estarao no aHeader;
               	.F.,;      								// se verdadeiro, exibe apenas os campos de usuário;
                '',;      								// cQuery - query a ser executada para preencher o acols;
               	,;    				   					// bloco contendo funcao especifica para preencher o aCols; 
               	Iif((nOpcx == 3),.T.,.F.),;  			// lEmpty 
               	,; 										// aHeaderAux
               	,; 		   								// aColsAux
               	,; 										// bAfterCols
               	,; 										// bBeforeCols
               	,; 										// bAfterHeader
               	'') 									// cAliasQry

nUsado := Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array com os campos que poderÆo ser alterados.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aAlter,"QA6_LOTSUP")
Aadd(aAlter,"QA6_CODAMO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna um array contendo os campos que podem ser alterados. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock( "QP220J25" )
   aAlter := ExecBlock( "QP220J25", .f., .f. )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a posicao dos campos no aHeader p/ posterior consistencia   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLotInf := Ascan(aHeader,{|x| x[2] == "QA6_LOTINF"})
nLotSup := Ascan(aHeader,{|x| x[2] == "QA6_LOTSUP"})
nLotAmo := Ascan(aHeader,{|x| x[2] == "QA6_CODAMO"})

nOpca 	:= 0
DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0007) From 150,1 To 451,601 OF oMainWnd PIXEL	//"Plano de Amostragem"

@ 000,000 SCROLLBOX oBox SIZE 0,0 OF oDlg

@ 4,4  SAY OemToAnsi(STR0019) SIZE 50,7 OF oBox PIXEL		//"Plano Amostr."
@ 3,50 MSGET cPlanoAmos PICTURE cPictPro VALID Iif(Empty(cIP160Nivel), .T., ExistChav("QA6",cPlanoAmos + cIP160Nivel,2)) .And.;
	ExistCpo("QQB",cPlanoAmos,2) F3 "QQB" SIZE 25,10 OF oBox PIXEL

//Mostrar a descri‡Æo do Plano de Amostragem
@ 4,90 SAY Tabela("QI", cPlanoAmos, .F.) SIZE 160,7 OF oBox PIXEL

@ 19,4  SAY OemToAnsi(STR0008) SIZE 50,7 OF oBox PIXEL		//"Tipo de Plano"
@ 18,50 MSGET cIP160Nivel PICTURE cPictPro VALID ExistChav("QA6",cPlanoAmos + cIP160Nivel,2) .And. ;
	ExistCpo("QQB",cPlanoAmos + cIP160Nivel,2) SIZE 25,10 OF oBox PIXEL

//Mostrar a descri‡Æo do Tipo de Plano
@ 19,90 SAY ShowDescr(cPlanoAmos,cIP160Nivel) SIZE 160,7 OF oBox PIXEL

oGet := MSGetDados():New(52,5,143,296,nOpcx,"Qip160lOk","Qip160TOk","",.T.,aAlter)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{||nopca:=1,If(oGet:TudoOk(),oDlg:End(),nOpca:=0)},{||oDlg:End()}),;
			 					AlignObject(oDlg,{oBox,oGet:oBrowse},1,,{70}))

If nOpcA == 1
	Begin Transaction
		lGravaOk := A160Grava(cAlias,cIP160Nivel,cPlanoAmos)
		If !lGravaOk
			Help(" ",1,"A010NAOGRV")
		Else
			//Processa Gatilhos
			EvalTrigger()
		EndIf
	End Transaction
Endif
dbSelectArea("QA6")
dbSetOrder(nOrdem)
dbGoBottom()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Qip160Alte³ Autor ³ Marcelo Pimentel      ³ Data ³ 21/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa atualizacao Informativos s/ Produtos - Alteracao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void Qip160Alte(ExpC1,ExpN1,ExpN2)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada no menu                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ qipA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qip160Alte(cAlias,nReg,nOpcx)

Local oDlg
Local oGet
Local oBox
Local cSeek			:= ""
Local cWhile		:= ""
Local nOpca    		:= 0
Local nOrdem		:= QA6->(IndexOrd())
Local lGravaOk 		:= .T.
Local aAlter   		:= {}  
Local aNoFields		:= {}

Private cPlanoAmos  := QA6_PLANO
Private cIP160Nivel := QA6_NIVEL
Private cIP160Desc  := ""
Private cPlanoDesc  := ""
Private nLotInf     := 0
Private nLotSup     := 0
Private nLotAmo     := 0
Private nCnt        := 1
Private nOpc		:= 3
Private nUsado		:= 0
Private aCols		:= {}
Private aHeader[0]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe algum dado no arquivo                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
If RecCount() == 0
	Return .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Norma podera ser alterada						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !QPVerNorma(QA6->QA6_PLANO)
	Return(NIL)
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array com os campos que poderÆo ser alterados.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aAlter,"QA6_LOTSUP")
Aadd(aAlter,"QA6_CODAMO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna um array contendo os campos que podem ser alterados. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock( "QP220J25" )
   aAlter := ExecBlock( "QP220J25", .f., .f. )
Endif
         
cWhile  	:= Alltrim(RetSIX(cAlias,"2",.T.,{"STR(QA6_LOTSUP,8)"}))
cSeek 		:= Alltrim(RetSIX(cAlias,"2",.T.,{"STR(QA6_LOTSUP,8)"}))                        
aNoFields   := {"QA6_PLANO","QA6_DPLANO","QA6_NIVEL"}

FillGetDados(	nOpcx,; 								// numero correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
               	cAlias,;       							// area a ser utilizada;
               	2,;      								// nOrdem - ordem correspondente a chave de índice para preencher o  acols;
               	Iif((nOpcx == 3),'',&cSeek),;  			// chave utilizada no posicionamento da área para preencher o acols; 
               	{|| &cWhile},; 	// bloco contendo a expressão a ser comparada com cSeekKey na condição  do While. 
               	{|| .T.},;  							// uSeekFor
               	aNoFields,;  						 	// aNoFields - array contendo os campos que não estarao no aHeader;
               	,;  									// aYesFields - array contendo somente os campos que estarao no aHeader;
               	.F.,;      								// se verdadeiro, exibe apenas os campos de usuário;
                '',;      								// cQuery - query a ser executada para preencher o acols;
               	,;    				   					// bloco contendo funcao especifica para preencher o aCols; 
               	Iif((nOpcx == 3),.T.,.F.),;  			// lEmpty 
               	,; 										// aHeaderAux
               	,; 		   								// aColsAux
               	,; 										// bAfterCols
               	,; 										// bBeforeCols
               	,; 										// bAfterHeader
               	'') 									// cAliasQry
               	
nUsado := Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a posicao dos campos no aHeader p/ posterior consistencia   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLotInf := Ascan(aHeader,{|x| x[2] == "QA6_LOTINF"})
nLotSup := Ascan(aHeader,{|x| x[2] == "QA6_LOTSUP"})
nLotAmo := Ascan(aHeader,{|x| x[2] == "QA6_CODAMO"})

nOpca 		:= 0
DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0007) From 150,1 To 451,601 OF oMainWnd PIXEL		//"Plano de Amostragem"

@ 000,000 SCROLLBOX oBox SIZE 0,0 OF oDlg

@ 4,4  SAY OemToAnsi(STR0019) SIZE 50,7 OF oBox PIXEL		//"Plano Amostr."
@ 4,40 SAY cPlanoAmos + " - " + Tabela("QI", cPlanoAmos, .F.) SIZE  180,10 OF oBox PIXEL

@ 19,4  SAY OemToAnsi(STR0008) SIZE 50,7 OF oBox PIXEL		//"Tipo de Plano"
@ 19,50 SAY cIP160Nivel+ " - " + ShowDescr(cPlanoAmos,cIP160Nivel) SIZE 180,10 OF oBox PIXEL
oGet:= MSGetDados():New(48,5,143,296,nOpcx,"Qip160lOk","Qip160TOk","",.T.,aAlter)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{||nopca:=1,If(oGet:TudoOk(),oDlg:End(),nOpca:=0)},{||oDlg:End()}),;
					AlignObject(oDlg,{oBox,oGet:oBrowse},1,,{70}))

If nOpcA == 1
	Begin Transaction
		lGravaOk :=A160Grava(cAlias,cIP160Nivel,cPlanoAmos)
		If !lGravaOK
			Help(" ",1,"A010NAOGRV")
		Else
			//Processa Gatilhos
			EvalTrigger()
		EndIf
	End Transaction
Endif

QA6->(dbSetOrder(nOrdem))
dbSelectArea(cAlias)

Return nOpca
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Qip160Dele³ Autor ³ Marcelo Pimentel      ³ Data ³ 21/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa atualizacao Informativo sobre Produtos - Delecao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Qip160Dele(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ qipA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qip160Dele(cAlias,nReg,nOpcx)

Local oDlg
Local oGet
Local oBox
Local cSeek			:= ""
Local cWhile		:= ""
Local nOpca    		:= 0
Local nOrdem		:= QA6->(IndexOrd())
Local lEspec 		:= .T.
Local aNoFields		:= {}

Private cPlanoAmos  := QA6_PLANO
Private cIP160Nivel := QA6_NIVEL
Private cIP160Desc  := ""
Private cPlanoDesc  := ""
Private nLotInf     := 0
Private nLotSup     := 0
Private nLotAmo     := 0
Private nCnt        := 1
Private nOpc		:= 3
Private nUsado		:= 0
Private aCols		:= {}
Private aHeader[0]

lEspec := Iif(cPlanoAmos$"NB5426ßNB5429ßQS9000",.F.,.T.)

cWhile  	:= Alltrim(RetSIX(cAlias,"2",.T.,{"STR(QA6_LOTSUP,8)"}))
cSeek 		:= Alltrim(RetSIX(cAlias,"2",.T.,{"STR(QA6_LOTSUP,8)"}))                        
aNoFields   := {"QA6_PLANO", "QA6_DPLANO", "QA6_NIVEL"}

FillGetDados(	nOpcx,; 								// numero correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
               	cAlias,;       							// area a ser utilizada;
               	2,;      								// nOrdem - ordem correspondente a chave de índice para preencher o  acols;
               	Iif((nOpcx == 3),'',&cSeek),;  			// chave utilizada no posicionamento da área para preencher o acols; 
               	{|| &cWhile},; 	// bloco contendo a expressão a ser comparada com cSeekKey na condição  do While. 
               	{|| .T.},;  							// uSeekFor
               	aNoFields,;  						 	// aNoFields - array contendo os campos que não estarao no aHeader;
               	,;  									// aYesFields - array contendo somente os campos que estarao no aHeader;
               	.F.,;      								// se verdadeiro, exibe apenas os campos de usuário;
                '',;      								// cQuery - query a ser executada para preencher o acols;
               	,;    				   					// bloco contendo funcao especifica para preencher o aCols; 
               	Iif((nOpcx == 3),.T.,.F.),;  			// lEmpty 
               	,; 										// aHeaderAux
               	,; 		   								// aColsAux
               	,; 										// bAfterCols
               	,; 										// bBeforeCols
               	,; 										// bAfterHeader
               	'') 									// cAliasQry
               	
nUsado := Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Norma podera ser excluida						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !QPVerNorma(QA6->QA6_PLANO)
	Return(NIL)
EndIf	

nOpca := 0
DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0007) From 150,1 To 451,601 OF oMainWnd PIXEL	//"Plano de Amostragem"

@ 000,000 SCROLLBOX oBox SIZE 0,0 OF oDlg

@ 4,4  SAY OemToAnsi(STR0019) SIZE 50,7 OF oBox PIXEL		//"Plano Amostr."
@ 4,40 SAY cPlanoAmos + " - " + Tabela("QI", cPlanoAmos, .F.) SIZE  180,10 OF oBox PIXEL

@ 19,4  SAY OemToAnsi(STR0008) SIZE 50,7 OF oBox PIXEL		//"Tipo de Plano"
@ 19,50 SAY cIP160Nivel + " - " + ShowDescr(cPlanoAmos,cIP160Nivel) SIZE  180,10 OF oBox PIXEL

oGet := MSGetDados():New(48,5,143,296,nOpcx,"AllwaysTrue","AllwaysTrue")
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{||nopca:=1,oDlg:End()},{||oDlg:End()}),;
								AlignObject(oDlg,{oBox,oGet:oBrowse},1,,{70}))
If nOpcA == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui as amostras do Plano de Amostragem                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QA7")
	If lEspec
		dbSetOrder(3)
		If dbSeek(xFilial("QA7")+cPlanoAmos+"ESP"+cIP160Nivel+QA6->QA6_CODAMO)
			While !EOF().And.QA7_FILIAL+QA7_PLANO+QA7_NQA==xFilial("QA7")+cPlanoAmos+"ESP"+cIP160Nivel .And.;
				QA7_CODAMO == QA6->QA6_CODAMO
				RecLock("QA7",.F.)
				dbDelete()
				MsUnLock()
				dbSkip()
			EndDo
		EndIf
	Else
		dbSetOrder(2)
		If dbSeek(xFilial("QA7")+QA6->QA6_PLANO+QA6->QA6_CODAMO)
			While !EOF() .And. QA7_FILIAL+QA7_PLANO+QA7_CODAMO == xFilial("QA7")+QA6->QA6_PLANO+QA6->QA6_CODAMO .And. ;
					Subs(QA7_NQA,1,3) <> 'ESP'
				If cIP160Nivel $ 'QS/ZD'
					If Val(QA7->QA7_NQA) > 10
						dbSkip()
						Loop
					EndIf
				EndIf
				RecLock("QA7",.F.)
				dbDelete()
				MsUnLock()
				dbSkip()
			EndDo
		EndIf
		dbSetOrder(1)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cancela o Plano de Amostragem         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QA6")		//Plano de Amostragem
	dbSetOrder(2)
	If dbSeek(xFilial("QA6")+cPlanoAmos+cIP160Nivel)
		While !Eof() .And. xFilial("QA6") == QA6_FILIAL .And. cPlanoAmos == QA6_PLANO .And. cIP160Nivel == QA6_NIVEL
			RecLock("QA6",.F.)
			dbDelete()
			MsUnLock()
			dbSkip()
		EndDo
	EndIf
EndIf
dbSelectArea("QA6")
dbSetOrder(nOrdem)
dbGotop()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±³                   ROTINAS DE CRITICA DE CAMPOS                        ³±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Qip160lOk ³ Autor ³ Marcelo Pimentel      ³ Data ³ 21/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a linha digitada esta' Ok                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ qipA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qip160lOk(o)

Local lRet := .T.

If !(aCols[n,Len(aCols[n])])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se campos campos estÆo preenchidos.                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aCols[n,nUsado+1] .And. LastKey() != 5 .And. LastKey() != 27 .And.lRet
		If Empty(aCols[n,nLotInf]) .Or. Empty(aCols[n,nLotSup]) .Or.;
				Empty(aCols[n,nLotAmo])
			Help(" ",1,"QA_CPOOBR")
			lRet:=.F.
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica tamanho do lote informado.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aCols[n,nLotInf]) .And. !Empty(aCols[n,nLotSup])
		If aCols[n,nLotInf] >= aCols[n,nLotSup]
			MessageDlg(OemToAnsi(STR0009),OemToAnsi(STR0010),3)			//"Tamanho do Lote Superior menor ou igual ao Tamanho do Lote Inferior."###"Aten‡Æo"
			lRet:= .F.
		EndIf
		If n+1 <= Len(Acols)
			If aCols[n,nLotSup] >= aCols[n+1,nLotInf]
				MessageDlg(OemToAnsi(STR0018),OemToAnsi(STR0010),3)	//"Tamanho do Lote Superior maior ou igual ao proximo Tamanho do Lote Inferior." ### "Aten‡Æo"
				lRet := .f.
			EndIf
		EndIf
	EndIf
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Qip160TOk ³ Autor ³ Marcelo Pimentel      ³ Data ³ 20/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se toda a getdados esta' Ok                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ qipA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qip160TOk(o)
Local nI, lRet := .t.

For nI := 1 to Len(aCols)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se campos campos estao preenchidos.                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aCols[nI,nUsado+1] .And. LastKey() <> 5 .And. LastKey() <> 27
		If Empty(aCols[nI,nLotInf]) .Or. Empty(aCols[nI,nLotSup]) .Or.;
				Empty(aCols[nI,nLotAmo])
			Help(" ",1,"QA_CPOOBR")
			lRet:=.F.
			Exit
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica tamanho do lote informado.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nI <> 1
		If aCols[nI,nLotInf] <= aCols[nI-1,nLotSup]
			MessageDlg(OemToAnsi(STR0011),OemToAnsi(STR0010),3)	//"Tamanho do Lote Inferior maior ou igual ao Tamanho do Lote Superior anterior."###"Aten‡Æo"
			lRet := .f.
			Exit
		EndIf

		If nI+1 <= Len(Acols)
			If aCols[nI,nLotSup] >= aCols[nI+1,nLotInf]
				MessageDlg(OemToAnsi(STR0018),OemToAnsi(STR0010),3)	//"Tamanho do Lote Superior maior ou igual ao proximo Tamanho do Lote Inferior." ### "Aten‡Æo"
				lRet := .f.
				Exit
			EndIf
		EndIf
	EndIf
Next

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Qip160lOk2³ Autor ³ Marcelo Pimentel      ³ Data ³ 21/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a linha digitada esta' Ok                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ qipA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qip160lOk2(o)
Local lRet	:= .T.
Local nX		:=	0
Local cTipo := ''

cTipo := aCols[n,nPosTipo]
If !(aCols[n,Len(aCols[n])])	//Verifica se nÆo est  deletado.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se campos campos estÆo preenchidos.                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(aCols[n,nPosNoAce]).And.Empty(aCols[n,nPosNoAce]).And.;
			(Empty(aCols[n,nPosNoAmo]).And. ( nPosNoFor > 0 .And. Empty(aCols[n,nPosNoFor] )))
		Help(" ",1,"QA_CPOOBR")
		lRet:=.F.
	EndIf
	
	If lRet
		For nX := 1 To Len(aCols)
			If nX # n .And. !(aCols[nX,Len(aCols[nX])])//Verifica se nÆo est  deletado.
				If cTipo == aCols[nX,nPosTipo]
					Help(" ",1,"JAGRAVADO")
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nX
		If aCols[n,nPosNoRej] <= aCols[n,nPosNoAce]
			MessageDlg(OemToAnsi(STR0013),OemToAnsi(STR0010),3)	//"Rejeite Normal Inferior ou Igual a Aceite Normal."###"Aten‡Æo"
			lRet:= .F.
		Else
			If aCols[n,nPosNoAmo] <= aCols[n,nPosNoRej] .And. ;
					!Empty(aCols[n,nPosNoAmo]) .And. ( nPosNoFor > 0 .And. !Empty(aCols[n,nPosNoFor]) )
				MessageDlg(OemToAnsi(STR0014),OemToAnsi(STR0010),3)			//"Tam.Lote Amostra Normal Inferior ou Igual a Rejeite Normal."###"Aten‡Æo"
				lRet:= .F.
			ElseIf !Empty(aCols[n,nPosSeAce]) .And. !Empty(aCols[n,nPosSeRej])
				If aCols[n,nPosSeRej] <= aCols[n,nPosSeAce]
					MessageDlg(OemToAnsi(STR0015),OemToAnsi(STR0010),3)		//"Rejeite Severo Inferior ou Igual a Aceite Severo."###"Aten‡Æo"
					lRet:= .F.
				Else
					If aCols[n,nPosSeAmo] <= aCols[n,nPosSeRej] .And. ;
							!Empty(aCols[n,nPosSeAmo]) .And. ( nPosSeFor > 0 .And. !Empty(aCols[n,nPosSeFor]) )
						MessageDlg(OemToAnsi(STR0016),OemToAnsi(STR0010),3)	//"Tam.Lote Amostra Severo Inferior ou Igual a Rejeite Severo."###"Aten‡Æo"
						lRet:= .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A160TudOk2³ Autor ³ Marcelo Pimentel      ³ Data ³ 20/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se toda a getdados esta' Ok                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ qipA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A160TudOk2(o)
Local nI, lRet := .t.
Local lQP160J01 :=	ExistBlock("QP160J01")   

If lQP160J01 
	lRet := ExecBlock("QP160J01",.f.,.f.,{aCols,aHeader})
EndIf

If lRet
	For	nI := 1 to Len(aCols)
		If !Qip160lOk2(o)
			lRet := .f.
			Exit
		EndIf
	Next     
EndIf                        

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A160Grava ³ Autor ³ Marcelo Pimentel      ³ Data ³ 21/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava as informacoes dos C¢digo das Amostras               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ qipA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A160Grava(cAlias,cNiv,cPlano)

Local nx,ny,nMaxArray:=Len(aCols)

dbSelectArea(cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o arquivo QA6        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to nMaxArray
	If !Acols[nX,Len(aHeader)+1]		//Nao esta deletado
		QA6->(dbSetOrder(2))

		If dbSeek(xFilial("QA6")+cPlano+cNiv+Str(aCols[nX,nLotSup],8))
			RecLock("QA6",.F.)	//Lock
		Else
			RecLock("QA6",.T.)	//Append
			QA6->QA6_FILIAL:= xFilial("QA6")
			QA6->QA6_PLANO := cPlano
			QA6->QA6_NIVEL := cNiv
		EndIf
		
		For ny := 1 to Len(aHeader)
			If aHeader[ny,10] # "V"
				cVar := Trim(aHeader[ny,2])
				Replace &cVar. With aCols[nx,ny]
			EndIf
		Next ny
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cancela o C¢digo da Amostra           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QA6->(dbSetOrder(2))

		If dbSeek(xFilial("QA6")+cPlano+cNiv+Str(aCols[nX,nLotSup],8))
			RecLock("QA6",.F.)
			dbDelete()
			MsUnLock()
		EndIf
	EndIf
Next nX
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ShowDescr ³ Autor ³ Marcelo Pimentel      ³ Data ³ 08/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a descricao do Produto                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaQip                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ShowDescr(cPlano,cNiv)
If !Empty(cNiv)
	QQB->(dbSetOrder(2))
	If QQB->(dbSeek(xFilial("QQB")+cPlano+cNiv))
		cIP160Desc :=QQB->QQB_DESCRI
	EndIf
EndIf
Return cIP160Desc
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A160Amost ³ Autor ³ Marcelo Pimentel      ³ Data ³ 21/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa atualizacao Tamanho das amostras.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A160Amost(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A160Amost(cAlias,nReg,nOpcx)
Local oDlg
Local oGet
Local nCnt			:= 1
Local nOpca			:= 0
Local lGravaOk		:= .T.
Local lEspec		:= .F.
Local lInclui		:= .f.
Local nRecNc		:= 0
Local cNQA			:= '100  /1000 /15   /150  /25   /250  /40   /400  /65   /650  '	//Excessoes para Zero Defeito
Local lMens			:= .F.
Local cNomArq		:= ''
Local cInd			:= ''
Local cFiltro		:= ''
Local lMostraMens	:= .F.
Local cNivelNQA		:= ''
Local cCabec		:= ''
Local nX            := 0
Local oBox                 
Local cSeek			:= ""
Local cWhile		:= ""
Local aNoFields		:= {}

Private cPlanoAmos  := QA6_PLANO
Private cIP160Nivel := QA6_NIVEL
Private nPosNoAce	:= 0
Private nPosNoRej	:= 0
Private nPosNoAmo	:= 0
Private nPosSeAce	:= 0
Private nPosSeRej	:= 0
Private nPosSeAmo	:= 0
Private nPosNoFor	:= 0
Private nPosSeFor	:= 0
Private nPosTipo	:= 0 
Private aHeader[0]
Private nOpc		:= 3
Private nUsado		:= 0

cNivelNQA	:= "ESP"+cIP160Nivel

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Registro posicionado est  na Tabela NBR ou ESPECÖFICO.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lEspec :=IF(cPlanoAmos$"NB5426ßNB5429ßQS9000",.F.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se os tamanhos das Amostradas referentes a Norma po-³
//³ derao ser alterados								 			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !QPVerNorma(QA6->QA6_PLANO)
	Return(NIL)
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe algum dado no arquivo                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QA7")
cWhile  	:= 	Alltrim(RetSIX("QA7",Iif(lEspec,"3","4"),.T.,Iif(lEspec,{"QA7_SEQUE"},{"QA7_NQA"})))/*+ Iif(lEspec,".AND. QA7_CODAMO == QA6->QA6_CODAMO",".AND. Subs(QA7_NQA,1,3) <> 'ESP'")  */
cSeek 		:= 	Iif(lEspec,;
				"xFilial('QA7')+cPlanoAmos+'ESP'+cIP160Nivel+QA6->QA6_CODAMO",;
				"xFilial('QA7')+QA6->QA6_PLANO+QA6->QA6_CODAMO")                        
aNoFields   := {"QA7_DPLANO", "QA7_NQA"   , "QA7_CODAMO",  "QA7_AT_ACE",;
				"QA7_AT_REJ", "QA7_AT_AMO", "QA7_QS_AMO"}

QA7->(dbSetOrder(Iif(lEspec,3,4)))
If dbSeek(cSeek)
   If &cWhile 
		lInclui := .T.
   EndIf 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe Plano de Amostragem ja cadastrado no Plano de Amostragem ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('QQH')
cNomArq := CriaTrab('',.F.)
cInd    := 'QQH_FILIAL+QQH_PLANO+QQH_NQA'
cFiltro := 'QQH_FILIAL=="'+xFilial("QQH")+'".And.QQH_NQA=="'+cNivelNQA+'" .And. QQH_PLANO == "' + cPlanoAmos + '"'
IndRegua('QQH',cNomArq, cInd,, cFiltro, 'Selecionando Registros...')
cInd := RetIndex('QQH')

dbSetOrder(cInd + 1)
dbGotop()
While !Eof()
	If QQH_NQA == cNivelNQA
		lMostraMens	:= .T.   
		nOpcx := 2
		Exit
	EndIf
	dbSkip()
EndDo

RetIndex('QQH')
Set Filter to
If File(cNomArq += OrdBagExt())
	fErase(cNomArq)
EndIf

If lMostraMens
	MsgAlert(STR0029,STR0010) // "Este plano de amostragem já está sendo utilizado na especificação de produtos, não poderá ser alterado."###"Atenção"
EndIf
		
FillGetDados(	nOpcx,; 								// numero correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
               	"QA7",;       							// area a ser utilizada;
               	Iif(lEspec,3,4),;      								// nOrdem - ordem correspondente a chave de índice para preencher o  acols;
               	Iif((nOpcx == 3),'',&cSeek),;  			// chave utilizada no posicionamento da área para preencher o acols; 
               	{|| &cWhile},; 	// bloco contendo a expressão a ser comparada com cSeekKey na condição  do While. 
               	{|| .T.},;  							// uSeekFor
               	aNoFields,;  						 	// aNoFields - array contendo os campos que não estarao no aHeader;
               	,;  									// aYesFields - array contendo somente os campos que estarao no aHeader;
               	.F.,;      								// se verdadeiro, exibe apenas os campos de usuário;
                '',;      								// cQuery - query a ser executada para preencher o acols;
               	,;    				   					// bloco contendo funcao especifica para preencher o aCols; 
               	Iif((nOpcx == 3),.T.,.F.),;  			// lEmpty 
               	,; 										// aHeaderAux
               	,; 		   								// aColsAux
               	,; 										// bAfterCols
               	,; 										// bBeforeCols
               	,; 										// bAfterHeader
               	'') 									// cAliasQry
               	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define vetor aCols para a getdados                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lInclui	// Def. vetor com 1 elemento, para a inclusao
	nCnt := 1
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a posicao dos campos no aHeader p/ posterior consistencia   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosTipo := AsCan(aHeader,{|x| AllTrim(x[2]) == "QA7_SEQUE"})
nPosNoAce:= AsCan(aHeader,{|x| AllTrim(x[2]) == "QA7_NO_ACE"})
nPosNoRej:= AsCan(aHeader,{|x| AllTrim(x[2]) == "QA7_NO_REJ"})
nPosNoAmo:= AsCan(aHeader,{|x| AllTrim(x[2]) == "QA7_NO_AMO"})
nPosNoFor:= AsCan(aHeader,{|x| AllTrim(x[2]) == "QA7_NO_FOR"})

nPosSeAce:= AsCan(aHeader,{|x| AllTrim(x[2]) == "QA7_SE_ACE"})
nPosSeRej:= AsCan(aHeader,{|x| AllTrim(x[2]) == "QA7_SE_REJ"})
nPosSeAmo:= AsCan(aHeader,{|x| AllTrim(x[2]) == "QA7_SE_AMO"})
nPosSeFor:= AsCan(aHeader,{|x| AllTrim(x[2]) == "QA7_SE_FOR"})

nUsado := Len(aHeader)

nOpca	:= 0
DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0012) From 150,1 To 416,601 OF oMainWnd PIXEL		//"Tamanho das Amostras"

@ 000,000 SCROLLBOX oBox SIZE 0,0 OF oDlg

@ 4,4  SAY TitSX3("QA7_CODAMO")[1] + " : "+ QA6->QA6_CODAMO SIZE 50,7 OF oBox PIXEL
@ 4,55	SAY TitSX3("QA6_LOTINF")[1] + " : "+ AllTrim(Str(QA6->QA6_LOTINF)) SIZE 80,7 OF oBox PIXEL
@ 4,110	SAY TitSX3("QA6_LOTSUP")[1] + " : "+ AllTrim(Str(QA6->QA6_LOTSUP)) SIZE 80,7 OF oBox PIXEL

If lEspec
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obs.:13§ parƒmetro serve para limitar o nr. de registros na GetDados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGet:= MSGetDados():New(33,5,127,296,nOpcx,"Qip160lOk2","AllWaysTrue","",.T.,,,,5)
Else
	oGet:= MSGetDados():New(33,5,127,296,2,"AllWaysTrue","AllWaysTrue","",.T.)
EndIf
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,Iif(A160TudOk2(),oDlg:End(),nOpca:=0)},{||oDlg:End()}),;
								AlignObject(oDlg,{oBox,oGet:oBrowse},1,,{30}))

If nOpcA == 1 .And. lEspec
	Begin Transaction
		If !lMostraMens
			lGravaOk :=A160GrvAm(cAlias,cIP160Nivel,cPlanoAmos)
			If !lGravaOK
				Help(" ",1,"A010NAOGRV")
			Else
				//Processa Gatilhos
				EvalTrigger()
			EndIf
		EndIf
	End Transaction
Endif

dbSelectArea(cAlias)
Return nOpca

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A160GrvAm ³ Autor ³ Marcelo Pimentel      ³ Data ³ 21/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava as informacoes do Tamanho das Amostras               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A160GrvAm(cAlias,cNiv,cPlano)
Local nx,ny,nMaxArray:=Len(aCols)
Local nSeq := 0

dbSelectArea("QA7")
dbSetOrder(3)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o arquivo QA7        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to nMaxArray
	If !Acols[nX,Len(aHeader)+1]		//Nao esta deletado
		If dbSeek(xFilial("QA7")+cPlano+"ESP"+cNiv+QA6->QA6_CODAMO+aCols[nX,nPosTipo])
			RecLock("QA7",.F.)	//Look
		Else
			RecLock("QA7",.T.)	//Append
			QA7->QA7_FILIAL	:= xFilial("QA7")
			QA7->QA7_PLANO  := cPlano
			QA7->QA7_NQA 	:= "ESP"+cNiv
			QA7->QA7_CODAMO	:= QA6->QA6_CODAMO
			QA7->QA7_SEQUE	:= aCols[nX,nPosTipo]
		EndIf
		For ny := 1 to Len(aHeader)
			If aHeader[ny,10] # "V"
				cVar := Trim(aHeader[ny,2])
				Replace &cVar. With aCols[nx,ny]
			EndIf
		Next ny
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cancela o C¢digo da Amostra           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If dbSeek(xFilial("QA7")+cPlano+"ESP"+cNiv+QA6->QA6_CODAMO+aCols[nX,nPosTipo])
			RecLock("QA7",.F.)
			dbDelete()
			MsUnLock()
		EndIf
	EndIf
Next nX
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A160WhAlt³ Autor ³ Marcelo Pimentel      ³ Data ³ 22/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define a clausula WHEN na altera‡„o.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A160WhAlt() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA160													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A160WhAlt()
Local lRet := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ NÆo deixa alterar o Lote Superior, ir  deixar       ³
//³ alterar se for inclusÆo de novo registro.        	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Altera
	If n <= nCnt
		lRet := .F.
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A160ChkF  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 08/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se dever  ser informado o lote da amostra ou  a   ³±±
±±³          ³ Formula.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaQip                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A160ChkF(cConteudo)
Local lRet:=.T.,nPosF:= &("nPos"+cConteudo)
Local aTamLot := {STR0017}//"Tam.Lote"

lRet:=Iif((	cConteudo =="NOAMO" .And. Empty(aCols[n,nPosNoFor])) .Or.;
	(	cConteudo =="NOFOR" .And. Empty(aCols[n,nPosNoAmo])) .Or.;
	( cConteudo =="SEAMO" .And. Empty(aCols[n,nPosSeFor])) .Or.;
	( cConteudo =="SEFOR" .And. Empty(aCols[n,nPosSeAmo])),.T.,.F.)

If lRet .And. cConteudo $ "NOFOR/SEFOR"
	aCols[n,nPosF] := QAFORMULA(aTamLot,aCols[n,nPosF])
	lRet := .F.
EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A160Seq   ³ Autor ³ Marcelo Pimentel      ³ Data ³ 08/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Informa a sequˆncia do lote inferior.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaQip                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A160Seq()
Return(Iif(Len(aCols)>1,aCols[n-1,nLotSup]+1,1))      