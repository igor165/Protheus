#INCLUDE "QIEA332.CH"
#INCLUDE "PROTHEUS.CH"
#Include "Colors.ch" 
#include "font.ch

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QIEA332   ³ Autor ³ Cleber L. Souza       ³ data ³19/05/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Plano de Amostragem Produto x Clientes x Ensaios.    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIE													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³STR 	     ³ Ultimo utilizado ->  STR0007                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³ 										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := {{OemToAnsi(STR0001),"AxPesqui"    ,0,1,,.F.},; //"Pesquisar"
				   {OemToAnsi(STR0002),"Q332AtPlAm"  ,0,2},;      //"Visualizar"
				   {OemToAnsi(STR0003),"Q332AtPlAm"  ,0,3},;      //"Incluir"
				   {OemToAnsi(STR0004),"Q332AtPlAm"  ,0,6},;      //"Alterar"
				   {OemToAnsi(STR0005),"Q332AtPlAm"  ,0,5,3},;    //"Excluir"
				   {OemToAnsi(STR0009),"Q332DUPLI"   ,0,5}}       //"Duplicar"
				 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada - Adiciona rotinas ao aRotina       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("Q332MENU")
	aRotAdic := ExecBlock("Q332MENU", .F., .F.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

Function QIEA332()  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do Browse  										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0006) //"Plano de Amostragem por Ensaios"         
Private Inclui := .F.
Private Altera := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ 1 - Nome a aparecer no cabecalho                             ³
//³ 2 - Nome da Rotina associada                                 ³
//³ 3 - Usado pela rotina                                        ³
//³ 4 - Tipo de Transa‡„o a ser efetuada                         ³
//³    1) Pesquisa e Posiciona em um Banco de Dados              ³
//³    2) Simplesmente Mostra os Campos                          ³
//³    3) Inclui registros no Bancos de Dados                    ³
//³    4) Altera o registro corrente                             ³
//³    5) Remove o registro corrente do Banco de Dados           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef()

dbSelectArea("QF6") 
mBrowse(06,01,22,75,"QF6") 

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q332AtPlAm³ Autor ³Cleber L. Souza        ³ Data ³19/05/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualizacao do Plano de Amostragens vinculados a Clientes  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q332AtPlAm(EXPC1,EXPN1,EXPN2)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias do arquivo									  ³±±
±±³			 ³ EXPN1 = Numero do registro 								  ³±±
±±³			 ³ EXPN2 = Opcao selecionada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA332													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q332AtPlAm(cAlias,nReg,nOpc)
Local oDlg
Local nOpcA    := 0
Local aAreaAnt := GetArea()
Local lQ332QF6 := ExistBlock("Q332QF6")
Local aCpoQF6  := {}
Local nSavRot  := 0
Local nIniCol  := 0
Local lDelete  := If(nOpc==2 .Or. nOpc==5,.F.,.T.)
Local oEnchoice

Private aTela    := {}
Private aGets    := {}                                           
Private aHeader  := {}
Private aCols    := {}
Private N        := 1
Private aColsAux := {}
Private nUsado   := 0                     
Private oGetPAE  

Private cProduto   := ""   
Private cRevi      := ""
Private lPlano     := .F. //Indica se o campo Plano de Amostragem sera editado
Private lNivel     := .F. //Indica se o campo Nivel do Plano sera editado
Private lNQA       := .T. //Indica se o campo NQA sera editado
Private lPA        := .F. //Indica se o campo Probabilidade de Aceitacao sera editado
Private lTipAmo    := .T. //Indica se o campo Tipo do Plano de Amostragem sera editado
Private lDesPlaTxt := .F. //Indica se o campo Descricao do Plano sera editado

Private cEnsRev    := "ß" //Obsoleto, apenas para compatibilizar a consulta SXB Q78
Private nPosLab    := 0
Private nPosSeq    := 0
Private nPosEns    := 0
Private nPosTPA    := 0
Private nPosPla    := 0
Private nPosNiv    := 0
Private nPosNQA    := 0
Private nPosNonEns := 0
Private nPosDescri := 0

Private aButtons := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos a serem editados na Enchoice							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCpoEnc  := {} 

//Define as coordenadas da Tela
Private aSize	 := {}

aSize	:= MsAdvSize(,.F.,400)

Aadd(aCpoEnc,'QF6_CLIENT')
Aadd(aCpoEnc,'QF6_LOJCLI')
Aadd(aCpoEnc,'QF6_DESCLI')
Aadd(aCpoEnc,'QF6_PRODUT')
Aadd(aCpoEnc,'QF6_REVI')
Aadd(aCpoEnc,'QF6_DESPRO')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para inclusao de novos campos na Enchoice   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQ332QF6
	aCpoQF6 := ExecBlock("Q332QF6",.F.,.F.)
	Aeval(aCpoQF6,{|x|Aadd(aCpoEnc,AllTrim(x))})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria as variaveis para edicao na enchoice					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("QF6",If(nOpc==3,.T.,.F.),.T.)            

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o aHeader e aCols para edicao do Plano de Amostragem    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Q332FilCol(cAlias,.T.)
                                                              
nPosLab    := Ascan(aHeader,{|x|AllTrim(x[2])=="QE7_LABOR"})
nPosSeq    := Ascan(aHeader,{|x|AllTrim(x[2])=="QE7_SEQLAB"})                            
nPosEns    := Ascan(aHeader,{|x|AllTrim(x[2])=="QF6_ENSAIO"})
nPosTPA    := Ascan(aHeader,{|x|AllTrim(x[2])=="QF6_TIPAMO"})
nPosPla    := Ascan(aHeader,{|x|AllTrim(x[2])=="QF6_PLAMO"})
nPosNiv    := Ascan(aHeader,{|x|AllTrim(x[2])=="QF6_NIVEL"})
nPosNQA    := Ascan(aHeader,{|x|AllTrim(x[2])=="QF6_NQA"})
nPosNonEns := Ascan(aHeader,{|x|AllTrim(x[2])=="QF6_DESENS"})
nPosDescri := Ascan(aHeader,{|x|AllTrim(x[2])=="QF6_DESCRI"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe algum Plano associado a Entrada, antes da ³
//³ Alteracao ou Exclusao.										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc==4) .Or. (nOpc==5)
	For nIniCol := 1 to Len(aCols)
		QF5->(dbSetOrder(3))
		If QF5->(MsSeek(xFilial('QF5')+M->QF6_CLIENT+M->QF6_LOJCLI+M->QF6_PRODUT+M->QF6_REVI+aCols[nIniCol,nPosEns]+"B")) .Or.;
			QF5->(MsSeek(xFilial('QF5')+M->QF6_CLIENT+M->QF6_LOJCLI+M->QF6_PRODUT+M->QF6_REVI+aCols[nIniCol,nPosEns]+"D"))
	    	Help(" ",1,"Q332EXIENS",,,1) //"Existe(m) Entrada(s) dadastrada(s), com Plano(s) definido(s) nesta Revisao"
		    Return(NIL)
		EndIf    	
	Next nIniCol
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a opcao do aRotina Inclusao							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3
	nSavRot     := aRotina[3,4] //Inclusao
	aRotina[3,4]:= 6	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia a Validacao dos Ensaios validos quando nao for inclusao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc # 3
	Q332IniEsp()
EndIf
                                            
//Ordena o aCols por Laboratorio+Sequencia
aSort(aCols,,,{|x,y| x[nPosLab]+x[nPosSeq]<y[nPosLab]+y[nPosSeq]})
                
Aadd(aButtons,{"BMPINCLUIR",{||Q332AtuPla()},OemToAnsi(STR0007),OemToAnsi(STR0008)}) //"Atualizacao Automatica do Plano de Amostragem..."###"Atual.PA"

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7],000 To aSize[6],aSize[5] OF oMainWnd Pixel	  	

oEnchoice := Msmget():New(cAlias,nReg,nOpc,,,,aCpoEnc,{016,002.7,072,306.6},,3,,,,,,)
oEnchoice:oBox:Align := CONTROL_ALIGN_TOP

oGetPAE := MSGetDados():New(075,003,140,306.5,nOpc,"Q332LinOk","Q332TudOk","",lDelete,,,.F.,,,,,If(lDelete,"Q332VlDel",),oDlg)
oGetPAE:oBrowse:bChange := {||lDesPlaTxt:= If(!Empty(aCols[oGetPAE:oBrowse:nAt,nPosTPA]) .And. aCols[oGetPAE:oBrowse:nAt,nPosTPA] == "4",.T.,.F.)}
oGetPAE:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGetPAE:aInfo[nPosLab,5]:='V' //forca o modo de visualizacao do Laboratorio
oGetPAE:aInfo[nPosSeq,5]:='V' //forca o modo de visualizacao da Sequencia do Laboratorio

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{||nOpcA :=1,If(oGetPAE:TudoOk(),;
	If(!Obrigatorio(aGets,aTela),nOpcA := 0,oDlg:End()),nOpcA:=0)},{||oDlg:End()},,aButtons) ,;
									AlignObject(oDlg,{oEnchoice:oBox,oGetPAE:oBrowse},1,,{102}))

//Realiza a gravacao dos dados
If (nOpcA==1) .And. (nOpc#2)
	Q332GrvAll(nOpc,aCpoQF6)
EndIf                       

//Restaura a opcao do aRotina Inclusao
If nOpc == 3
	aRotina[3,4] := nSavRot
EndIf                       
      
RestArea(aAreaAnt)

Return(NIL)                    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q332FilCol³ Autor ³Cleber L. Souza        ³ Data ³19/05/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria o aHeader e aCols utilizado na edicao do Plano de Amos³±±
±±³			 ³ tragem.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q332FilCol(EXPN1,EXPL1)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias 											  ³±±
±±³			 ³ EXPL1 = Indica se o aHeader foi definido		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPA2 = Estrutura do aCols								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA332													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q332FilCol(cAlias,lHeader)
Local nIteCol  := 0
Local aAreaQF6 := QF6->(GetArea())
Local aAreaQE6 := QE6->(GetArea())
Local aAreaQE7 := QE7->(GetArea())
Local aAreaQE8 := QE8->(GetArea())
Local cKeyQF6  := ""
Local nCpo     := 0
Local nEns     := 0
Local nNiv     := 0
Local aCpoLab  := {"QE7_LABOR","QE7_SEQLAB"}
Local nX
Local aStrut

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a montagem do aHeader								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lHeader
	For nX := 1 to Len(aCpoLab)
		nUsado++
		Aadd(aHeader, Q332GetSX3(aCpoLab[nX], "V"))
	Next nX
	
	aStrut := FWFormStruct(3,cAlias)[3]
	For nX := 1 to Len(aStrut)
		If cNivel >= GetSx3Cache(aStrut[nX,1],"X3_NIVEL") .And. (Ascan(aCpoEnc,AllTrim(aStrut[nX,1]))==0)
			nUsado++
			Aadd(aHeader, Q332GetSX3(aStrut[nX,1]))
		EndIf 
	Next nX       
EndIf

nEns := Ascan(aHeader,{|x|AllTrim(x[2])=="QF6_ENSAIO"})
nNiv := Ascan(aHeader,{|x|AllTrim(x[2])=="QF6_NIVEL"})
N    := 1 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso a opcao seja diferente de Inclusao, preenche o aCols com³
//³ os Planos ja associados aos Ensaios.						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cKeyQF6 := M->QF6_CLIENT+M->QF6_LOJCLI+M->QF6_PRODUT+M->QF6_REVI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena os ensaios mensuraveis de acordo com a revisao	atual³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols := {}
QE7->(dbSetOrder(1))
QE7->(MsSeek(xFilial("QE7")+M->QF6_PRODUT+M->QF6_REVI))
While QE7->(!Eof()) .And. QE7->QE7_FILIAL == xFilial("QE7") .And.;  
	(QE7->QE7_PRODUT+QE7->QE7_REVI) == (M->QF6_PRODUT+M->QF6_REVI)
		
	cEnsRev+=QE7->QE7_ENSAIO+"ß"     
		
	Aadd(aCols,Array(nUsado+1))
		
	QF6->(dbSetOrder(1))
	QF6->(MsSeek(xFilial("QF6")+cKeyQF6+QE7->QE7_ENSAIO))
	For nCpo := 1 to Len(aHeader)
		If aHeader[nCpo,10] # "V"          
			If QF6->(!Eof())		
			    aCols[Len(aCols),nCpo] := QF6->(FieldGet(FieldPos(aHeader[nCpo,2])))
			Else                                                                    
				If AllTrim(aHeader[nCpo,2]) == "QF6_ENSAIO"
					aCols[Len(aCols),nCpo] := QE7->QE7_ENSAIO
				Else	
					aCols[Len(aCols),nCpo] := CriaVar(aHeader[nCpo,2])				    
				EndIf	
			EndIf    
		Else                                                                      
			If AllTrim(aHeader[nCpo,2]) == "QE7_LABOR"
				aCols[Len(aCols),nCpo] := QE7->QE7_LABOR
			ElseIf AllTrim(aHeader[nCpo,2]) == "QE7_SEQLAB"
				aCols[Len(aCols),nCpo] := QE7->QE7_SEQLAB
			ElseIf AllTrim(aHeader[nCpo,2]) == "QF6_DESENS"    
			    aCols[Len(aCols),nCpo] := Posicione("QE1",1,xFilial("QE1")+aCols[Len(aCols),nEns],"QE1_DESCPO")
			ElseIf AllTrim(aHeader[nCpo,2]) == "QF6_DESCRI"
				aCols[Len(aCols),nCpo] := Posicione("QQB",1,xFilial("QQB")+aCols[Len(aCols),nNiv],"QQB_DESCRI")
			Else
				aCols[Len(aCols),nCpo] := CriaVar(aHeader[nCpo,2])
			EndIf
		EndIf				    
	Next nCpo 		
	aCols[Len(aCols),nUsado+1] := .F.

	QE7->(dbSkip())	
	
EndDo	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena os ensaios textos de acordo com a revisao atual	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QE8->(dbSetOrder(1))
QE8->(MsSeek(xFilial("QE8")+M->QF6_PRODUT+M->QF6_REVI))
While QE8->(!Eof()) .And. QE8->QE8_FILIAL == xFilial("QE8") .And.;  
	(QE8->QE8_PRODUT+QE8->QE8_REVI) == (M->QF6_PRODUT+M->QF6_REVI)  
		
	cEnsRev+=QE8->QE8_ENSAIO+"ß"

	Aadd(aCols,Array(nUsado+1))
		
	QF6->(dbSetOrder(1))
	QF6->(MsSeek(xFilial("QF6")+cKeyQF6+QE8->QE8_ENSAIO))
	For nCpo := 1 to Len(aHeader)
		If aHeader[nCpo,10] # "V"                          
			If !QF6->(Eof())
		    	aCols[Len(aCols),nCpo] := QF6->(FieldGet(FieldPos(aHeader[nCpo,2])))
		    Else 
				If AllTrim(aHeader[nCpo,2]) == "QF6_ENSAIO"
					aCols[Len(aCols),nCpo] := QE8->QE8_ENSAIO
				Else	
					aCols[Len(aCols),nCpo] := CriaVar(aHeader[nCpo,2])				    
				EndIf	
		    EndIf	
		Else                                                                      
			If AllTrim(aHeader[nCpo,2]) == "QE7_LABOR"
				aCols[Len(aCols),nCpo] := QE8->QE8_LABOR
			ElseIf AllTrim(aHeader[nCpo,2]) == "QE7_SEQLAB"
				aCols[Len(aCols),nCpo] := QE8->QE8_SEQLAB
			ElseIf AllTrim(aHeader[nCpo,2]) == "QF6_DESENS"    
			    aCols[Len(aCols),nCpo] := Posicione("QE1",1,xFilial("QE1")+aCols[Len(aCols),nEns],"QE1_DESCPO")
			ElseIf AllTrim(aHeader[nCpo,2]) == "QF6_DESCRI"
				aCols[Len(aCols),nCpo] := Posicione("QQB",1,xFilial("QQB")+aCols[Len(aCols),nNiv],"QQB_DESCRI")
			Else
				aCols[Len(aCols),nCpo] := CriaVar(aHeader[nCpo,2])
			EndIf
		EndIf				    
	Next nCpo 		
	aCols[Len(aCols),nUsado+1] := .F.

	QE8->(dbSkip())	
		
EndDo	
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria uma dimensao vazia no aCols,caso nao haja especificacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aCols) == 0
	Aadd(aCols,Array(nUsado+1))
	For nIteCol = 1 To Len(aHeader)
		If aHeader[nIteCol,8] == "C"
			aCols[1,nIteCol] := Space(aHeader[nIteCol,4])
		ElseIf aHeader[nX,8] == "N"
			aCols[1,nIteCol] := 0
		ElseIf aHeader[nIteCol,8] == "D"
			aCols[1,nIteCol] := dDataBase
		ElseIf aHeader[nIteCol,8] == "M"
			aCols[1,nIteCol] := ""
		EndIf
    Next nIteCol
	aCols[1,nUsado+1] := .F.
EndIf 
            
RestArea(aAreaQF6)
RestArea(aAreaQE6)
RestArea(aAreaQE7)
RestArea(aAreaQE8)

Return(aCols)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q332GrvAll³ Autor ³Cleber L. Souza        ³ Data ³19/05/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria o aHeader e aCols utilizado na edicao do Plano de Amos³±±
±±³			 ³ tragem.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q332GrvAll(nOpc,aCpoQF6)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Opcao do aRotina									  ³±±
±±³			 ³ EXPA1 = Campos utilizados na Enchoice					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA332													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q332GrvAll(nOpc,aCpoQF6)   
Local nIteCol   := 0
Local nCpoQF6   := 0
Local lAddRec 
Local nPosDel   := 0        
Local cSeekQF6  := ""
Local lAtualiza
Local lQ332Grv := ExistBlock("Q332Grv")   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a manutencao nos registros do Plano de Amostragem por³
//³ Ensaios.													 ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nIteCol := 1 to Len(aCols)
	        
    If Empty(aCols[nIteCol,nPosEns]) .Or. Empty(aCols[nIteCol,nPosTPA])
    	lAtualiza := .F.
    Else	
        lAtualiza := .T.
    EndIf

	If lAtualiza	                    
	
	    If nOpc == 5
			cSeekQF6 := QF6->(QF6_CLIENT+QF6_LOJCLI+QF6_PRODUT+QF6_REVI+aCols[nIteCol,nPosEns])
	    Else
			cSeekQF6 := M->QF6_CLIENT+M->QF6_LOJCLI+M->QF6_PRODUT+M->QF6_REVI+aCols[nIteCol,nPosEns]
		EndIf	
			
		nPosDel := Len(aCols[nIteCol])
		lAddRec := .F.  
			
		If nOpc == 3
			lAddRec := .T.
		Else
			QF6->(dbSetorder(1))
			If QF6->(!dbSeek(xFilial("QF6")+cSeekQF6))
				lAddRec := .T.
		    EndIf
		EndIf

		If !(lAddRec .And. aCols[nIteCol,nPosDel])
			RecLock("QF6",lAddRec) 
		EndIf	                         
			
		If aCols[nIteCol,nPosDel] .Or. (nOpc == 5)
			If !lAddRec
				QF6->(dbDelete())
			EndIf
		Else
			//Grava os campos editados na enchoice
			QF6->QF6_FILIAL := xFilial("QF6")
			QF6->QF6_CLIENT := M->QF6_CLIENT
			QF6->QF6_LOJCLI := M->QF6_LOJCLI
			QF6->QF6_PRODUT := M->QF6_PRODUT
			QF6->QF6_REVI   := M->QF6_REVI  

			//Grava os campos definidos atraves do ponto de Entrada Q332QF6	
			If Len(aCpoQF6) > 0
				For nCpoQF6 := 1 to Len(aCpoQF6)
					FieldPut(FieldPos(AllTrim(aCpoQF6[nCpoQF6])),M->&(aCpoQF6[nCpoQF6]))
				Next nCpoQF6
			EndIf
				
			For nCpoQF6 := 1 to Len(aHeader)
				If aHeader[nCpoQF6,10] # "V"                                                 
					FieldPut(FieldPos(AllTrim(aHeader[nCpoQF6,2])),aCols[nIteCol,nCpoQF6])
				EndIf	
			Next nCpoQF6
					
		EndIf
		MsUnLock()
		
		//Atualiza QE7/QE8
		dbSelectArea("QE7")
		dbSetOrder(1)
		If dbSeek(xFilial("QE7")+QF6->QF6_PRODUT+QF6->QF6_REVI+QF6->QF6_ENSAIO)
			RecLock("QE7",.f.)
			QE7->QE7_PLAMO := QF6->QF6_PLAMO                          
		    MsUnlock()
		Else 
			dbSelectArea("QE8")
			dbSetOrder(1)
			If dbSeek(xFilial("QE8")+QF6->QF6_PRODUT+QF6->QF6_REVI+QF6->QF6_ENSAIO)
				RecLock("QE8",.f.)
				QE8->QE8_PLAMO := QF6->QF6_PLAMO                          
			    MsUnlock()
			EndIF
		EndIF	
			
	EndIf
		
Next nIteCol


If lQ332Grv
	ExecBlock("Q332Grv",.F.,.F., {aHeader, aCols, nOpc})
EndIF

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q332IniEsp³ Autor ³Cleber L. Souza        ³ Data ³19/05/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicia as validacoes dos Ensaios validos na revisao do pro-³±±
±±³ 		 ³ duto.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA332												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q332IniEsp()
Local lRetorno := .T.
                   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia a validacao dos ensaios, caso haja alteracao na revi- ³
//³ sao do produto a serem associados os planos de amostragem.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(M->QF6_PRODUT) .And. !Empty(M->QF6_REVI)

	If (cProduto # M->QF6_PRODUT) .Or. (cRevi # M->QF6_REVI)  
	                                                             
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exibe o aCols vazio, caso a revisao do produto seja alterada ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oGetPAE # NIL
			oGetPAE:oBrowse:lDisablePaint := .T.
			aCols := aClone(aColsAux)
			N     := 1
			oGetPAE:oBrowse:lDisablePaint := .F.
		EndIf
					
		//Armazena a Revisao alterada
		cProduto := M->QF6_PRODUT
		cRevi    := M->QF6_REVI     
			
	EndIf                                                      
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q332VldPAE³ Autor ³Cleber L. Souza        ³ Data ³19/05/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza as validacoes do Plano de Amostragem por Ensaios   ³±±
±±³ 		 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA332												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q332VldPAE()
Local lRetorno := .T.
Local aAreaAnt := GetArea()
Local aAreaSA7 := SA7->(GetArea())
If !Empty(M->QF6_CLIENT) .And. !Empty(M->QF6_LOJCLI) .And. !Empty(M->QF6_PRODUT)
	SA7->(dbSetOrder(1))
	If SA7->(!dbSeek(xFilial("SA7")+M->QF6_CLIENT+M->QF6_LOJCLI+M->QF6_PRODUT))
		Help(" ",1,"Q332NOCLI",,,1)  //Nao existem amarracao Cliente x Produto na tabela SA7.
		lRetorno := .F.
	Else
		If !Empty(M->QF6_REVI)
			QF6->(dbSetOrder(1))
			If QF6->(dbSeek(xFilial("QF6")+M->QF6_CLIENT+M->QF6_LOJCLI+M->QF6_PRODUT+M->QF6_REVI))
				Help("",1,"Q332JAPLAN") //Ja existe Plano associado ao Cliente e (Produto + Revisao)
				lRetorno := .F.
			EndIf
		EndIf
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prenche o aCols de acordo com o Cliente x Produto+Revisao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Inclui .And. lRetorno

	Q332FilCol("QF6",.F.)
	oGetPAE:oBrowse:Refresh(.T.)               
	
EndIf

RestArea(aAreaAnt)
RestArea(aAreaSA7)

Return(lRetorno)       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q332VldEns³ Autor ³Paulo Emidio de Barros ³ Data ³03/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a validacao do Ensaio digitado.					  ³±±
±±³ 		 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA332												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q332VldEns()
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q332VldTPA³ Autor ³Cleber L. Souza        ³ Data ³19/05/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a validacao do Tipo do Plano de Amostragem selecio-³±±
±±³ 		 ³ nado.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA332													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q332VldTPA()
Local cCarta   := " "

If lTipAmo                                        

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o Tipo da Carta associada ao Ensaio com a NBR5429	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (M->QF6_TIPAMO == "5") //NBR5429
		If !Empty(aCols[N,nPosEns])
			cCarta := QA_CartEns(aCols[N,nPosEns])
			If Alltrim(cCarta)$("TXT/U/P")	
				Help(" ",1,"Q332CARINV",,,1)
				Return(.F.)
			EndIf	
		EndIf	
	EndIf

	//Zera os campos referentes ao Plano utilizado
	aCols[N,nPosPla]   := Space(TamSX3("QF6_PLAMO")[1])
	aCols[N,nPosNiv]   := Space(TamSX3("QF6_NIVEL")[1])
	aCols[N,nPosNQA]   := Space(TamSX3("QF6_NQA")[1])
	aCols[N,nPosDescri]:= Space(TamSX3("QF6_DESCRI")[1])
	
	If (M->QF6_TIPAMO == "1") //NBR5426
		lPlano     := If(lPlano,lPlano,.T.)
		lNivel     := If(lNivel,lNivel,.T.)
		lNQA       := If(lNQA,lNQA,.T.)      
		lDesPlaTxt := If(!lDesPlatxt,lDesPlaTxt,.F.)
		
	ElseIf (M->QF6_TIPAMO == "2") //QS9000 
		lPlano     := If(!lPlano,lPlano,.F.)
		lNivel     := If(!lNivel,lNivel,.F.)
		lNQA       := If(lNQA,lNQA,.T.)                          
		lDesPlaTxt := If(!lDesPlaTxt,lDesPlaTxt,.F.)
	
		aCols[N,nPosPla]    := "QS" //Sugere o Plano como QS9000 para a Tabela Zero Defeito
		aCols[N,nPosNiv]    := "01" //Nivel utilizado na QS9000
		aCols[N,nPosNQA]    := Space(TamSX3("QF6_NQA")[1])    
		aCols[N,nPosDescri] := Tabela("QI",QA_Plano(M->QF6_TIPAMO,.F.))
	
	ElseIf (M->QF6_TIPAMO == "3") //Interno
		lPlano     := If(!lPlano,lPlano,.F.)
		lNivel     := If(lNivel,lNivel,.T.)
		lNQA       := If(!lNQA,lNQA,.F.)  
		lDesPlaTxt := If(!lDesPlaTxt,lDesPlaTxt,.F.)

	ElseIf (M->QF6_TIPAMO == "4") //Texto	
		lPlano     := If(!lPlano,lPlano,.F.)
		lNivel     := If(!lNivel,lNivel,.F.)
		lNQA       := If(lNQA,lNQA,.T.)  
		lDesPlaTxt := If(lDesPlaTxt,lDesPlaTxt,.T.)
		
		aCols[N,nPosPla] := "TX" //Sugere a sigla no Plano TX para indicar o tipo Texto
		aCols[N,nPosNiv] := "01" //Sugere o Nivel utilizado no Plano do Tipo Texto
		    
	ElseIf (M->QF6_TIPAMO == "5") //NBR5429
		lPlano     := If(lPlano,lPlano,.T.)
		lNivel     := If(lNivel,lNivel,.T.)
		lNQA       := If(lNQA,lNQA,.T.)      
		lDesPlaTxt := If(!lDesPlatxt,lDesPlaTxt,.F.)
		
	EndIf	

EndIf

Return(.T.)    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q332VldPlA³ Autor ³Cleber L. Souza        ³ Data ³19/05/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a validacao do Plano de Amostragem selecionado.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA332													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q332VldPlA()
Local lRetorno := .T.
Local cPlaAmo  := " "                  
Local cSeekTab := " "                  

cPlaAmo  := &(ReadVar()) 
cSeekTab := If(M->QF6_TIPAMO=='5',"QJ","Q5")
lRetorno := ExistCpo("SX5",cSeekTab+cPlaAmo)

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q332VldNQA³ Autor ³ Cleber L. Souza       ³ Data ³19/05/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a validacao do NQA selecionado.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA332													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q332VldNQA()
Local lRetorno := .T.
Local cNivPla
Local cTabF3   := " "

cNivPla  := &(ReadVar()) 
cTabF3   := If(aCols[N,nPosTPA]=="5","Q0","Q1")
lRetorno := ExistCpo("SX5",cTabF3+cNivPla)

Return(lRetorno)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q332VldNiv³ Autor ³Cleber L. Souza        ³ Data ³19/05/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a validacao do Nivel do Plano de Amostragem.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA332													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q332VldNiv()
Local lRetorno  := .F.
Local cNiv      := &(ReadVar())      

QQB->(dbSetOrder(1))
If NaoVazio(cNiv) .And. ExistCpo("QQB")    
	lRetorno := .T.
EndIf
	
If lRetorno	
	If aCols[N,nPosTPA] == "3" //Plano Interno
		aCols[N,nPosPla] := "PI" //Plano de Amostragem Interno
		aCols[N,nPosNQA] := ("ESP"+cNiv) 
	EndIf

	If (aCols[N,nPosTPA] == "1") .Or. (aCols[N,nPosTPA] == "3") .Or. (aCols[N,nPosTPA] == "5") 
		QQB->(dbSetOrder(2))                         
		If QQB->(dbSeek(xFilial("QQB")+QA_Plano(M->QF6_TIPAMO)+cNiv))
			aCols[N,nPosDescri] := QQB->QQB_DESCRI 
		Else	                                  
			aCols[N,nPosDescri] := Space(TamSX3("QQB_DESCRI")[1])
		EndIf                     
	EndIf
EndIf

Return(lRetorno) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q332WhnEns³ Autor ³Paulo Emidio de Barros ³ Data ³03/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o campo Ensaio sera editado na Alteracao dos   ³±±
±±³			 ³ Planos associados aos Ensaios.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA332													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q332WhnEns()  
Return(.F.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q332LinOK ³ Autor ³Cleber L. Souza        ³ Data ³19/05/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a validacao dos Ensaios digitados na Getdados	  ³±±
±±³ 		 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA332													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q332LinOk()
Local lRetorno   := .T.
Local nPosDel    := Len(aCols[N])
Local aPlanos    := {"01","02","03","S1","S2","S3","S4"}
Local nPosPlAm    := 0

If !aCols[N,nPosDel]

	If lRetorno 
		nPosPlAm := Ascan(aPlanos,{|x|x==aCols[N,nPosNiv]})
		If aCols[N,nPosTPA] == "1"
			If Empty(aCols[N,nPosPla]) .Or. Empty(aCols[N,nPosNiv]) .Or.;
				Empty(aCols[N,nPosNQA]) .Or. (nPosPlAm == 0) .Or. (SubStr(aCols[N,nPosNQA],1,3) == "ESP")
				lRetorno := .F.
		    EndIf      

		ElseIf aCols[N,nPosTPA] == "2"    
			If Empty(aCols[N,nPosNQA]) .Or. (SubStr(aCols[N,nPosNQA],1,3) == "ESP")			
				lRetorno := .F.
			EndIf	

		ElseIf aCols[N,nPosTPA] == "3"
			If Empty(aCols[N,nPosNiv]) .Or. Empty(aCols[N,nPosNQA]) .Or. (SubStr(aCols[N,nPosNQA],1,3) # "ESP")			
				lRetorno := .F.
			EndIf	
		ElseIf aCols[N,nPosTPA] == "4"
			If !(aCols[N,nPosPla]=='TX' .And. aCols[N,nPosNiv]=='01' .And.;
				!Empty(aCols[N,nPosNQA]) .And. !Empty(aCols[N,nPosDescri]))
				lRetorno := .F.			
            EndIf
		EndIf
	EndIf
	
EndIf

If !lRetorno
    Help("",1,"Q332NAOPLA") // Nao foram informados os dados referentes ao Plano de Amostragem selecionado.
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q332TudOK ³ Autor ³Cleber L. Souza        ³ Data ³19/05/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a validacao dos Ensaios digitados apos a confirma- ³±±
±±³ 		 ³ cao na GetDados.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA332												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q332TudOk()
Local lRetorno   := .T.
Local nPosDel    := 0
Local nLinCol    := 0
Local aPlanos    := {"01","02","03","S1","S2","S3","S4"}
Local nPosPlAm    := 0

For nLinCol := 1 to Len(aCols)

	nPosDel := Len(aCols[nLinCol])
	
	If !aCols[nLinCol,nPosDel]
	
		nPosPlAm := Ascan(aPlanos,{|x|x==aCols[nLinCol,nPosNiv]})
	
		If aCols[nLinCol,nPosTPA] == "1"
			If Empty(aCols[nLinCol,nPosPla]) .Or. Empty(aCols[nLinCol,nPosNiv]) .Or.;
				Empty(aCols[nLinCol,nPosNQA]) .Or. (nPosPlAm == 0) .Or. (SubStr(aCols[nLinCol,nPosNQA],1,3) == "ESP")
				lRetorno := .F.
				Exit
		    EndIf

		ElseIf aCols[nLinCol,nPosTPA] == "2" 
			If Empty(aCols[nLinCol,nPosNQA]) .Or. (SubStr(aCols[nLinCol,nPosNQA],1,3) == "ESP")
				lRetorno := .F.
				Exit
			EndIf	

		ElseIf aCols[nLinCol,nPosTPA] == "3" 
			If Empty(aCols[nLinCol,nPosNiv]) .Or. Empty(aCols[nLinCol,nPosNQA]) .Or. (SubStr(aCols[nLinCol,nPosNQA],1,3) # "ESP")			
				lRetorno := .F.  
				Exit
			EndIf	
			
		ElseIf aCols[nLinCol,nPosTPA] == "4"
			If !(aCols[nLinCol,nPosPla]=='TX' .And. aCols[nLinCol,nPosNiv]=='01' .And.;
				!Empty(aCols[nLinCol,nPosNQA]) .And. !Empty(aCols[nLinCol,nPosDescri]))
				lRetorno := .F.
				Exit			
            EndIf

		EndIf  
	EndIf
Next nLinCol          

If !lRetorno 
	Help("",1,"Q332NAOPLA") // Nao foram informados os dados referentes ao Plano de Amostragem selecionado.
EndIf

Return(lRetorno)          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q332AtuPla³ Autor ³Cleber L. Souza        ³ Data ³19/05/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza os demais ensaios com o Plano de Amostragem suge- ³±±
±±³ 		 ³ rido na linha corrente da GetDados                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA332												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Static Function Q332AtuPla()
Local nLinCol
Local aAreaQE6 := QE6->(GetArea())
Local aAreaQE7 := QE7->(GetArea())
Local aAreaQE8 := QE8->(GetArea())
Local cCarta   := ""
           
//Verifica se a Especificacao do Produto esta preenchida           
If Empty(M->QF6_PRODUT) .Or. Empty(M->QF6_REVI)          
	Help(" ",1,"Q332NOREVI",,,1) //"Nao foi informado a Especificacao do Produto"
	Return(NIL)
EndIf

If !Empty(aCols[oGetPAE:oBrowse:nAt,nPosEns]) .And.;  //Ensaio
	!Empty(aCols[oGetPAE:oBrowse:nAt,nPosTPA]) .And.; //Tipo 
	!Empty(aCols[oGetPAE:oBrowse:nAt,nPosPla]) .And.; //Plano de Amostragem
	!Empty(aCols[oGetPAE:oBrowse:nAt,nPosNiv]) .And.; //Nivel 
	!Empty(aCols[oGetPAE:oBrowse:nAt,nPosNQA])        //NQA

	For nLinCol := 1 to Len(aCols)
		If nLinCol # oGetPAE:oBrowse:nAt
			cCarta := QA_CartEns(aCols[nLinCol,nPosEns]) 
		
			If aCols[oGetPAE:oBrowse:nAt,nPosTPA]#"5" .or. !(Alltrim(cCarta)$("TXT/U/P"))	
				If Empty(aCols[nLinCol,nPosTPA]) .Or.; //Tipo 
					Empty(aCols[nLinCol,nPosPla]) .Or.; //Plano de Amostragem
					Empty(aCols[nLinCol,nPosNiv]) .Or.; //Nivel 	
					Empty(aCols[nLinCol,nPosNQA])        //NQA
					aCols[nLinCol,nPosTPA]    := aCols[oGetPAE:oBrowse:nAt,nPosTPA]
					aCols[nLinCol,nPosPla]    := aCols[oGetPAE:oBrowse:nAt,nPosPla]
					aCols[nLinCol,nPosNiv]    := aCols[oGetPAE:oBrowse:nAt,nPosNiv]
					aCols[nLinCol,nPosNQA]    := aCols[oGetPAE:oBrowse:nAt,nPosNQA]
					aCols[nLinCol,nPosDescri] := aCols[oGetPAE:oBrowse:nAt,nPosDescri]
				EndIf	
			EndIf
		EndIF	
	Next nLinCol
	
	//Atualiza o browse
	oGetPAE:oBrowse:Refresh()
	
EndIf	
           
RestArea(aAreaQE6)
RestArea(aAreaQE7)
RestArea(aAreaQE8)

Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q332VlDel ³ Autor ³Cleber L. Souza        ³ Data ³19/05/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se linha pode ser deletada.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q332VlDel()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA332                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q332VlDel()

Local lRet:= .T.

If Empty(Acols[n,nPosTPA]) .And. Empty(Acols[n,nPosPla]) .And. ;
	Empty(Acols[n,nPosNiv]) .And. Empty(Acols[n,nPosNQA])
	lRet:= .F.
EndIf

Return lRet
              
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Q332TpAmo ³ Autor ³ Marcos Cesar          ³ Data ³01.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o codigo da norma escolhida pelo usuario.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpC1 := Q332TpAmo()                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1 = O codigo da Norma.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Q332TpAmo()
Local cNorma  := QA_Plano(aCols[N,nPosTPA],.F.)
Return(cNorma) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q332DUPLI   ³ Autor ³ Cleber Souza          ³ data ³13/05/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de Duplicação do Plano de Amostragem.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIE													  ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function Q332DUPLI() 
Local oTempTable := NIL
Local oDlg         
Local oCodPro
Local oFont1
Local oFont2
Local oGroup1  
Local oGroup2
Local oGroup3 
Local oCodCli
Local oLoja
Local aStru      := {}
Local aCpos      := {}
Local nOpcA      := 0

Private oMark
Private oGetOri
Private oDesPro 
Private oNomCli 
Private oRevi         

Private cDesPro  := Space(TamSX3("B1_DESC")[1])  
Private cNomCli  := Space(TamSX3("A1_NOME")[1])     
Private cCodPro  := Space(TamSX3("B1_COD")[1])
Private cRevi    := Space(2)
Private cCodCli  := Space(TamSX3("A1_COD")[1])
Private cLoja    := Space(TamSX3("A1_LOJA")[1])
Private nUsado   := 0                     

Private aHeadOr  := {}
Private aColsOr  := {}
Private lInverte := .F.
Private cMarca    

Q332DFilCol("QF6",.T.) 
Q332DMonTRB(@aStru,@aCpos,@oTempTable,.T.)
cMarca   := GetMark(,"TRB","TB_OK")
           
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0010) From 120,000 To 660,600 OF oMainWnd Pixel  //"Duplicação do Plano de Amostragem"	  	
DEFINE FONT oFont1 NAME "Arial" SIZE 0,-11 BOLD
DEFINE FONT oFont2 NAME "Arial" SIZE 0,-11 
 
@ 045,003 GROUP oGroup1 TO 090,298	LABEL "" OF oDlg PIXEL  
oGroup1:oFont:= oFont1

@ 098,003 GROUP oGroup2 TO 148,298	LABEL OemToAnsi(STR0011) OF oDlg PIXEL  //"Plano de Amostragem Origem"
oGroup2:oFont:= oFont1

@ 166,003 GROUP oGroup3 TO 268,298	LABEL OemToAnsi(STR0012) OF oDlg PIXEL //"Fornecedores Relacionados ao Produto" 
oGroup3:oFont:= oFont1

@ 038,008 SAY   OemToAnsi(STR0013) Of oDlg PIXEL FONT oFont2  //"Produto "
@ 038,145 SAY   OemToAnsi(STR0014) Of oDlg PIXEL FONT oFont2  //"Revisao "
@ 051,008 SAY   OemToAnsi(STR0015) Of oDlg PIXEL FONT oFont2  //"Desc Prod "
@ 064,008 SAY   OemToAnsi(STR0016) Of oDlg PIXEL FONT oFont2  //"Cliente "
@ 064,145 SAY   OemToAnsi(STR0017) Of oDlg PIXEL FONT oFont2  //"Loja "
@ 077,008 SAY   OemToAnsi(STR0018) Of oDlg PIXEL FONT oFont2  //"Nome "

@ 037,040 MSGET oCodPro    VAR cCodPro SIZE 080,8 PIXEL Of oDlg F3 "QE6" Valid ExistCpo("QE6",cCodPro) .and. Q332DVPAE()
@ 037,168 MSGET oRevi      VAR cRevi   SIZE 020,8 PIXEL Of oDlg Valid ExistCpo("QE6",cCodPro+cRevi,3) .and. Q332DVPAE()  
@ 050,040 MSGET oDesPro    VAR cDesPro SIZE 220,8 PIXEL Of oDlg WHEN .F.
@ 063,040 MSGET oCodCli    VAR cCodCli SIZE 050,8 PIXEL Of oDlg F3 "CLI" Valid ExistCpo("SA1",cCodCli) .and. Q332DVPAE() 
@ 063,168 MSGET oLoja      VAR cLoja   SIZE 020,8 PIXEL Of oDlg Valid ExistCpo("SA1",cCodCli+cLoja) .and. Q332DVPAE() 
@ 078,040 MSGET oNomCli    VAR cNomCli SIZE 220,8 PIXEL Of oDlg WHEN .F.

oGetOri := MsNewGetDados():New(104,006,144,294,0,"AllwaysTrue()","AllwaysTrue()","",,,,,,,oDlg,aHeadOr,aColsOr)

oMark := MsSelect():New("TRB","TB_OK",,acpos,lInverte,cMarca,{172,006,264,294})
oMark:oBrowse:lCanAllMark:=.T.
oMark:oBrowse:lHasMark	 :=.T.
oMark:oBrowse:bAllMark	:= {| | Q332DMarkAll(cMarca,oDlg)}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||IIF(Q332DTudOk(),(nOpcA:=1,oDlg:End()),nOpcA:=0)},{||nOpcA:=0,oDlg:End()}) CENTERED 

If nOpcA == 1
	Q332DGrvAll()
EndIf	

Set Filter to
oTempTable:Delete()

Return(NIL) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q332DFilCol³ Autor ³Cleber Souza           ³ Data ³13/05/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria o aHeader e aCols utilizado na edicao do Plano de Amos³±±
±±³			 ³ tragem.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q332DFilCol(EXPN1,EXPL1)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias 											  ³±±
±±³			 ³ EXPL1 = Indica se o aHeader foi definido		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPA2 = Estrutura do aCols								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA331													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q332DFilCol(cAlias,lHeader)
Local nIteCol  := 0
Local aAreaQF6 := QF6->(GetArea())
Local aAreaQE6 := QE6->(GetArea())
Local aAreaQE7 := QE7->(GetArea())
Local aAreaQE8 := QE8->(GetArea())
Local cKeyQF6  := ""
Local nCpo     := 0
Local nEns     := 0
Local nNiv     := 0    
Local nCli     := 0    
Local nLoj     := 0     
Local nPro     := 0
Local aCpoLab  := {"QE7_LABOR","QE7_SEQLAB"}
Local nX
Local aStrut

//limpa aCols dos resultados anteriores.
aColsOr := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a montagem do aHeadOr								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lHeader
	For nX := 1 to Len(aCpoLab)
		nUsado++
		Aadd(aHeadOr, Q332GetSX3(aCpoLab[nX], "V"))
	Next nX
	
	aStrut := FWFormStruct(3,cAlias)[3]
	For nX := 1 to Len(aStrut)
		If cNivel >= GetSx3Cache(aStrut[nX,1],"X3_NIVEL")
			nUsado++
			Aadd(aHeadOr, Q332GetSX3(aStrut[nX,1]))
		EndIf 
	Next nX      
EndIf

nEns := Ascan(aHeadOr,{|x|AllTrim(x[2])=="QF6_ENSAIO"})
nNiv := Ascan(aHeadOr,{|x|AllTrim(x[2])=="QF6_NIVEL"}) 
nCli := Ascan(aHeadOr,{|x|AllTrim(x[2])=="QF6_CLIENT"}) 
nLoj := Ascan(aHeadOr,{|x|AllTrim(x[2])=="QF6_LOJCLI"}) 
nPro := Ascan(aHeadOr,{|x|AllTrim(x[2])=="QF6_PRODUT"})
nTPA := Ascan(aHeadOr,{|x|AllTrim(x[2])=="QF4_TIPAMO"})
N    := 1 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso a opcao seja diferente de Inclusao, preenche o aColsOr com ³
//³ os Planos ja associados aos Ensaios.			     			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cKeyQF6 := cCodCli+cLoja+cCodPro+cRevi

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena os ensaios mensuraveis de acordo com a revisao	atual³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QE7->(dbSetOrder(1))
QE7->(MsSeek(xFilial("QE7")+cCodPro+cRevi))
While QE7->(!Eof()) .And. QE7->QE7_FILIAL == xFilial("QE7") .And.;  
	(QE7->QE7_PRODUT+QE7->QE7_REVI) == (cCodPro+cRevi)
		
	Aadd(aColsOr,Array(nUsado+1))
	QF6->(dbSetOrder(1))
	QF6->(MsSeek(xFilial("QF6")+cKeyQF6+QE7->QE7_ENSAIO))
	For nCpo := 1 to Len(aHeadOr)
		If aHeadOr[nCpo,10] # "V"          
			If QF6->(!Eof())		
			    aColsOr[Len(aColsOr),nCpo] := QF6->(FieldGet(FieldPos(aHeadOr[nCpo,2])))
			Else                                                                    
				If AllTrim(aHeadOr[nCpo,2]) == "QF6_ENSAIO"
					aColsOr[Len(aColsOr),nCpo] := QE7->QE7_ENSAIO
				Else	
					aColsOr[Len(aColsOr),nCpo] := CriaVar(aHeadOr[nCpo,2])				    
				EndIf	
			EndIf    
		Else                                                                      
			If AllTrim(aHeadOr[nCpo,2]) == "QE7_LABOR"
				aColsOr[Len(aColsOr),nCpo] := QE7->QE7_LABOR
			ElseIf AllTrim(aHeadOr[nCpo,2]) == "QE7_SEQLAB"
				aColsOr[Len(aColsOr),nCpo] := QE7->QE7_SEQLAB
			ElseIf AllTrim(aHeadOr[nCpo,2]) == "QF6_DESENS"    
			    aColsOr[Len(aColsOr),nCpo] := Posicione("QE1",1,xFilial("QE1")+aColsOr[Len(aColsOr),nEns],"QE1_DESCPO")
   			ElseIf AllTrim(aHeadOr[nCpo,2]) == "QF6_DESCRI"
				aCols[Len(aColsOr),nCpo] := Posicione("QQB",2,xFilial("QQB")+QA_Plano(aColsOr[Len(aColsOr),nTPA]+aColsOr[Len(aColsOr),nNiv]),"QQB_DESCRI")
			ElseIf AllTrim(aHeadOr[nCpo,2]) == "QF6_DESCLI"
				aColsOr[Len(aColsOr),nCpo] := Posicione("SA1",1,xFilial("SA1")+aColsOr[Len(aColsOr),nCli]+aColsOr[Len(aColsOr),nLoj],"A1_NOME")
			ElseIf AllTrim(aHeadOr[nCpo,2]) == "QF6_DESPRO"
				aColsOr[Len(aColsOr),nCpo] := Posicione("SB1",1,xFilial("SB1")+aColsOr[Len(aColsOr),nPro],"B1_DESC")
			Else
				aColsOr[Len(aColsOr),nCpo] := CriaVar(aHeadOr[nCpo,2])
			EndIf
		EndIf				    
	Next nCpo 		
	aColsOr[Len(aColsOr),nUsado+1] := .F.

	QE7->(dbSkip())	
	
EndDo
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena os ensaios textos de acordo com a revisao atual	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QE8->(dbSetOrder(1))
QE8->(MsSeek(xFilial("QE8")+cCodPro+cRevi))
While QE8->(!Eof()) .And. QE8->QE8_FILIAL == xFilial("QE8") .And.;  
	(QE8->QE8_PRODUT+QE8->QE8_REVI) == (cCodPro+cRevi)  
		
	Aadd(aColsOr,Array(nUsado+1))
	QF6->(dbSetOrder(1))
	QF6->(MsSeek(xFilial("QF6")+cKeyQF6+QE8->QE8_ENSAIO))
	For nCpo := 1 to Len(aHeadOr)
		If aHeadOr[nCpo,10] # "V"                          
			If !QF6->(Eof())
		    	aColsOr[Len(aColsOr),nCpo] := QF6->(FieldGet(FieldPos(aHeadOr[nCpo,2])))
		    Else 
				If AllTrim(aHeadOr[nCpo,2]) == "QF6_ENSAIO"
					aColsOr[Len(aColsOr),nCpo] := QE8->QE8_ENSAIO
				Else	
					aColsOr[Len(aColsOr),nCpo] := CriaVar(aHeadOr[nCpo,2])				    
				EndIf	
		    EndIf	
		Else                                                                      
			If AllTrim(aHeadOr[nCpo,2]) == "QE7_LABOR"
				aColsOr[Len(aColsOr),nCpo] := QE8->QE8_LABOR
			ElseIf AllTrim(aHeadOr[nCpo,2]) == "QE7_SEQLAB"
				aColsOr[Len(aColsOr),nCpo] := QE8->QE8_SEQLAB
			ElseIf AllTrim(aHeadOr[nCpo,2]) == "QF6_DESENS"    
			    aColsOr[Len(aColsOr),nCpo] := Posicione("QE1",1,xFilial("QE1")+aColsOr[Len(aColsOr),nEns],"QE1_DESCPO")
			ElseIf AllTrim(aHeadOr[nCpo,2]) == "QF6_DESCRI"
				aCols[Len(aCols),nCpo] := Posicione("QQB",2,xFilial("QQB")+QA_Plano(aColsOr[Len(aColsOr),nTPA]+aColsOr[Len(aColsOr),nNiv]),"QQB_DESCRI")
			ElseIf AllTrim(aHeadOr[nCpo,2]) == "QF6_DESCLI"
				aColsOr[Len(aColsOr),nCpo] := Posicione("SA1",1,xFilial("SA1")+aColsOr[Len(aColsOr),nCli]+aColsOr[Len(aColsOr),nLoj],"A1_NOME")
			ElseIf AllTrim(aHeadOr[nCpo,2]) == "QF6_DESPRO"
				aColsOr[Len(aColsOr),nCpo] := Posicione("SB1",1,xFilial("SB1")+aColsOr[Len(aColsOr),nPro],"B1_DESC")
			Else
				aColsOr[Len(aColsOr),nCpo] := CriaVar(aHeadOr[nCpo,2])
			EndIf
		EndIf				    
	Next nCpo 		
	aColsOr[Len(aColsOr),nUsado+1] := .F.

	QE8->(dbSkip())	
		
EndDo	
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria uma dimensao vazia no aColsOr,caso nao haja especificacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aColsOr) == 0
	Aadd(aColsOr,Array(nUsado+1))
	For nIteCol = 1 To Len(aHeadOr)
		If aHeadOr[nIteCol,8] == "C"
			aColsOr[1,nIteCol] := Space(aHeadOr[nIteCol,4])
		ElseIf aHeadOr[nIteCol,8] == "N"
			aColsOr[1,nIteCol] := 0
		ElseIf aHeadOr[nIteCol,8] == "D"
			aColsOr[1,nIteCol] := dDataBase
		ElseIf aHeadOr[nIteCol,8] == "M"
			aColsOr[1,nIteCol] := ""
		EndIf
    Next nIteCol
	aColsOr[1,nUsado+1] := .F.
EndIf 
            
RestArea(aAreaQF6)
RestArea(aAreaQE6)
RestArea(aAreaQE7)
RestArea(aAreaQE8)

Return()	

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Q332DMonTRB ³ Autor ³ Cleber Souza       ³ Data ³ 13/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta browse para a escolha dos Fornecedores - MarkBrowse  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q332DMonTRB()				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEM100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Q332DMonTRB(aStru,aCpos,oTempTable,lMonta)

If lMonta

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Arquivo de Trabalho                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd( aStru,{ "TB_OK"      , "C",02,0} )
	Aadd( aStru,{ "TB_CLIENTE" , "C",TamSX3("QF6_CLIENT")[1],0} )
	Aadd( aStru,{ "TB_LOJA"    , "C",TamSX3("QF6_LOJCLI")[1],0} )
	Aadd( aStru,{ "TB_DESCRI"  , "C",TamSX3("QF6_DESCLI")[1],0} )

	oTempTable := FWTemporaryTable():New( "TRB" )
	oTempTable:SetFields( aStru )
	oTempTable:AddIndex("indice1", {"TB_CLIENTE","TB_LOJA"} )
	oTempTable:Create()
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Redefinicao do acpos para utilizar no MarkBrow               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	acpos := { {"TB_OK"		 ,"",OemToAnsi("OK")},; 
		  	   {"TB_CLIENTE" ,"",OemToAnsi(STR0016)},; //"Cliente"	 
		  	   {"TB_LOJA"	 ,"",OemToAnsi(STR0017)},; //"Loja"
			   {"TB_DESCRI"	 ,"",OemToAnsi(STR0019)}}  //"Descricao"

EndIF

If !lMonta
	dbSelectArea("TRB")
	dbGoTop()
	While TRB->(!EOF())
		RecLock("TRB",.F.)
		dbDelete()
		MsUnlock()
		TRB->(dbSkip())
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta arquivo temporario dos Fornecedores                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA7->(dbSetOrder(2))
SA7->(dbSeek(xFilial("SA7")+cCodPro))
While !SA7->(Eof()) .And. SA7->A7_FILIAL == xFilial("SA7");
		.And. SA7->A7_PRODUTO == cCodPro
	
	dbSelectArea("QF6")
	dbSetOrder(1)
	If !dbSeek(xFilial("QF6")+SA7->A7_CLIENTE+SA7->A7_LOJA+cCodPro+cRevi)
		RecLock("TRB",.T.)
		TRB->TB_CLIENTE	:= SA7->A7_CLIENTE
		TRB->TB_LOJA 	:= SA7->A7_LOJA
		TRB->TB_DESCRI  := Posicione("SA1",1,xFilial("SA7")+SA7->A7_CLIENTE+SA7->A7_LOJA,"A1_NOME")
		MsUnlock()    
    EndIF
    
	SA7->(dbSkip())
EndDo

dbSelectArea("TRB")
dbGoTop()

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q332DVPAE³ Autor ³Cleber Souza           ³ Data ³13/05/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza as validacoes do Plano de Amostragem por Ensaios   ³±±
±±³ 		 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEM010												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q332DVPAE()
Local lRetorno := .T.
Local aAreaAnt := GetArea()
Local aAreaSA7 := SA7->(GetArea()) 

If !Empty(cCodCli) .And. !Empty(cLoja)
	cNomCli := Posicione("SA1",1,xFilial("SA1")+cCodCli+cLoja,"A1_NOME")
	oNomCli:Refresh()
EndIf

If !Empty(cCodPro) 
	cDesPro := Posicione("SB1",1,xFilial("SB1")+cCodPro,"B1_DESC")
	oDesPro:Refresh()
	cRevi   := QA_UltRevEsp(cCodPro,dDataBase,.F.,,"QIE")
	oRevi:Refresh()
EndIf

If !Empty(cCodCli) .And. !Empty(cLoja) .And. !Empty(cCodPro)

	SA7->(dbSetOrder(1))
	If SA7->(!dbSeek(xFilial("SA7")+cCodCli+cLoja+cCodPro))
		Help(" ",1,"Q110NOCli")  //Existem campos obrigatórios que não foram preenchidos.
		lRetorno := .F.
	Else	
		If !Empty(cRevi)
			QF6->(dbSetOrder(1))
			If QF6->(!dbSeek(xFilial("QF6")+cCodCli+cLoja+cCodPro+cRevi))
				 Help(" ",1,"Q110NOPLA") //Existem campos obrigatórios que não foram preenchidos.
		         lRetorno := .F.
		    EndIf
		EndIf
	EndIf

	If lRetorno
		
		//Monta aCols com os dados do Plano de Amostragem
		Q332DFilCol("QF6",.F.)
		oGetOri:aCols := aColsOr
		oGetOri:oBrowse:Refresh(.T.)  
				
		//Monta tabela de Fornecedores (temporario)
		Q332DMonTRB(,,,.F.)
		oMark:oBrowse:SetFocus()
		oMark:oBrowse:Refresh(.T.)
		
    EndIF

EndIf

RestArea(aAreaSA7)
RestArea(aAreaAnt) 

Return(lRetorno)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q332GrvAll³ Autor ³Paulo Emidio de Barros ³ Data ³03/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria o aHeader e aCols utilizado na edicao do Plano de Amos³±±
±±³			 ³ tragem.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q332GrvAll(nOpc,aCpoQF6)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Opcao do aRotina									  ³±±
±±³			 ³ EXPA1 = Campos utilizados na Enchoice					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA331													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q332DGrvAll()   
Local nIteCol   := 0
Local nCpoQF6   := 0
Local aCols     := oGetOri:aCols
Local aHeader   := oGetOri:aHeader

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a manutencao nos registros do Plano de Amostragem por³
//³ Ensaios.													 ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
dbGoTop()
While TRB->(!EOF())
	If !Empty(TRB->TB_OK)
		For nIteCol := 1 to Len(aCols)

			RecLock("QF6",.T.)
			//Grava os campos editados na enchoice
			QF6->QF6_FILIAL := xFilial("QF6")
			QF6->QF6_CLIENT := TRB->TB_CLIENTE
			QF6->QF6_LOJCLI := TRB->TB_LOJA
			QF6->QF6_PRODUT := cCodPro
			QF6->QF6_REVI   := cRevi
			
			For nCpoQF6 := 1 to Len(aHeader)
				If aHeader[nCpoQF6,10] # "V" .and. !(Alltrim(aHeader[nCpoQF6,2]) $("QF6_CLIENTE,QF6_LOJCLI,QF6_PRODUT,QF6_REVI"))
					FieldPut(FieldPos(AllTrim(aHeader[nCpoQF6,2])),aCols[nIteCol,nCpoQF6])
				EndIf
			Next nCpoQF6
			
			MsUnLock()
		Next nIteCol
	EndIf
	TRB->(dbSkip())
EndDo

Return(NIL)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q332GrvAll³ Autor ³Paulo Emidio de Barros ³ Data ³03/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria o aHeader e aCols utilizado na edicao do Plano de Amos³±±
±±³			 ³ tragem.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q332GrvAll(nOpc,aCpoQF6)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Opcao do aRotina									  ³±±
±±³			 ³ EXPA1 = Campos utilizados na Enchoice					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA331													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q332DTudOk()

Local lRet := .T.

If Empty(cCodCli) .Or. Empty(cLoja) .Or. Empty(cCodPro)
	Help(" ",1,"Q110ORIG") //Existem campos obrigatórios que não foram preenchidos.
	lRet := .F.
EndIF           

Return(lRet) 

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M050MarkAll³ Autor ³Vera Lucia S. Simoes ³ Data ³ 08/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inverte os Ensaios Marcados/Desmarcados                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEM050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q332DMarkAll(cMarca,oDlg)
LOCAL nRecno:=Recno()
dbGotop()
Do While !Eof()
	RecLock("TRB",.F.)
	If Empty(TRB->TB_OK)
		TRB->TB_OK	:= cMarca
	Else
		TRB->TB_OK	:= "  "
	Endif
	MsUnlock()
	FKCOMMIT()
	dbSkip()
EndDo
dbGoto(nRecno)
Return(.T.)

//----------------------------------------------------------------------
/*/{Protheus.doc} Q332GetSX3 
Busca dados da SX3 
@author Gustavo Della Giustina
@since 12/04/2018
@version 1.0
@return aHeaderTmp
/*/
//---------------------------------------------------------------------- 
Static Function Q332GetSX3(cCampo, cContext)
Local aHeaderTmp := {}
aHeaderTmp:= {AllTrim(QAGetX3Tit(cCampo)),;
              GetSx3Cache(cCampo,'X3_CAMPO'),;
              GetSx3Cache(cCampo,'X3_PICTURE'),;
              GetSx3Cache(cCampo,'X3_TAMANHO'),;
              GetSx3Cache(cCampo,'X3_DECIMAL'),;
              GetSx3Cache(cCampo,'X3_VALID'),;              
              GetSx3Cache(cCampo,'X3_USADO'),;
              GetSx3Cache(cCampo,'X3_TIPO'),;
              GetSx3Cache(cCampo,'X3_ARQUIVO'),;
              IIF(Empty(cContext), GetSx3Cache(cCampo,'X3_CONTEXT'), cContext)}          
Return aHeaderTmp
