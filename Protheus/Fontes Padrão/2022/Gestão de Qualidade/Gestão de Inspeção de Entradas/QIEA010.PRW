#Include "FOLDER.CH"   
#Include "QIEA010.CH"
#Include "TOTVS.CH"  
     
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QIEA010	³ Autor ³ Paulo Emidio de Barros³ Data ³30/11/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualizacao das Especificacoes de Produtos			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ STR		 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±                       
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 			   		  ³±±                 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Paulo Emidio³04/06/02³MELHOR³Inclusao da verificacao do Laudo da Entra-³±±
±±³			   ³		³	   ³da para Entradas Free-Pass.				  ³±±
±±³Cleber Souza³14/05/03³064155³Sugere o numero da proxima Revisao no     ³±±
±±³			   ³		³	   ³gatilho do Produto.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()
Local aRotAdic := {}
Private aRotina  := {}

aRotina := {{STR0001  ,"AxPesqui",   0, 1,,.F.},;      //"Pesquisar"     
				 {STR0002 ,"Q010AtuEsp", 0, 2},;   //"Visualizar"  
				 {STR0003 ,"Q010AtuEsp", 0, 3},;   //"Incluir"    
				 {STR0004 ,"Q010AtuEsp", 0, 4, 2},;//"Alterar"  
				 {STR0005 ,"Q010AtuEsp", 0, 5, 1},;//"Excluir"  
 				 {STR0038 ,"Q010BLOQ",   0, 5   },;//"Bloqueio"    
				 {STR0039 ,"Q010LegOp",  0, 5,,.F.},;//"Legenda"   
                 {STR0043 ,"MsDocument", 0, 4   }} //"Conhecimento"                               

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada - Adiciona rotinas ao aRotina       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QE010ROT")
	aRotAdic := ExecBlock("QE010ROT", .F., .F.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf


Return aRotina

Function QIEA010()

Private lOrdLab  := .F.
Private aSitEsp  := {}  
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
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0006) //"Especificacao de Produtos"  
Private lDuplDoc  := .T. 
Private lQE010DUP := ExistBlock("QE010DUP")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Consistencia da situacao da Rev. da Especif.º
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QIE010Led()
               
Aadd(aSitEsp,{"QE6->QE6_SITREV=='0' .OR.QE6->QE6_SITREV==' '","BR_VERDE"})  //Revisão Disponivel
Aadd(aSitEsp,{"QE6->QE6_SITREV=='1'","BR_VERMELHO"})    //Revisão Bloqueada
Aadd(aSitEsp,{"QE6->QE6_SITREV=='2'","BR_AMARELO"})     //Revisão Pendente

dbSelectArea("QE1")
dbSelectArea("QE6")


mBrowse(06,01,22,75,"QE6",,,,,,aSitEsp)

Return(NIL)
                                                                                       		
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Q010AtuEsp³ Autor ³Paulo Emidio de Barros ³ Data ³03/12/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualizacao das Especificacoes do Produto				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ q010AtuEsp()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias do arquivo									  ³±±
±±³			 ³ EXPN1 = Numero do registro 								  ³±±
±±³			 ³ EXPN2 = Opcao selecionada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQIE (Inspecao de Entradas)					 		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q010AtuEsp(cAlias,nReg,nOpc)
Local oDlg                     
Local oFolder 
Local aTitulos  := {}
Local aPaginas  := {}
Local nX
Local lTemMed   := .F.
Local cEspecie  := "QIEA010 "   
Local aTextos   := {}
Local cChave    := ""
Local nTamLin   := TamSX3("QA2_TEXTO")[1]
Local nLinCol   := 0
Local lDeleta   := If(nOpc==2 .Or. nOpc==5,.F.,.T.)  
Local nOpcA     := 0
Local lQE010VAL := ExistBlock("QE010VAL") 
Local lRetVal   := .T.
Local nHRes     := oMainWnd:nClientWidth //--Resolucao horizontal do monitor
Local oSize
   
Private oGetEns        
Private oGetNco
Private aTela      := {}
Private aGets      := {}
Private aHeader    := {}
Private aCols      := {} 
Private nUsado     := 0
Private N          := 1
Private aHeadEns   := {}
Private aColsEns   := {}
Private nUsadEns   := 0
Private aHeadNco   := {}
Private aColsNco   := {}
Private nUsadNco   := 0
Private oTexto    
Private cTexto     := " "
Private aEnsaios   := {}                   
Private lPlaAmoEns := .T. //Indica a edicao do campo Ensaio, quando houver associacao de Plano de Amostragem por Ensaio.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ define as variaveis utilizadas nos Ensaios					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nPosEns    := 0
Private nPosDEn    := 0
Private nPosUM     := 0
Private nPosDUM    := 0
Private nPosNom    := 0
Private nPosAFI    := 0
Private nPosAFS    := 0
Private nPosLIC    := 0
Private nPosLSC    := 0
Private nPosNiv    := 0
Private nPosDesNiv := 0
Private nPosTip    := 0
Private nPosLab    := 0
Private nPosDLab   := 0
Private nPosSeq    := 0
Private nPosMin    := 0
Private nPosDoc    := 0
Private nPosDocRev := 0
Private nPosTxt    := 0
Private nPosFor    := 0
Private nPosNC     := 0
Private nPosDNC    := 0
Private nPosCla    := 0
Private nPosDCl    := 0 
Private nPosProd   := 0 
Private nPosPRevi  := 0 
Private nPosPlAm   := 0 
Private nPosDPlA   := 0 
Private nPosAliWT  := 0
Private nPosRecWT  := 0 
Private nPosEnD    := 0 
Private nPosAmIn   := 0 
Private nEnsAtu    := 1
Private nFldAtu    := 0
Private nPsAmIIn   := 0
Private aButtons   := {}
Private cMsG       := OemToAnsi(STR0020) //"Selecione a Pasta (ENSAIOS)" 
Private oEncEsp
Private cEnsAtu    := CriaVar("QE7_ENSAIO")
Private cEnsaio    := CriaVar("QE7_ENSAIO")

//Define as coordenadas da Tela
Private aSize		:= {}
Private aObjects  	:= {}
Private aInfo		:= {} 
Private aPosObj		:= {}     
Private lFlatMode   := FlatMode()  
Private nFat		:= 1

aSize  := MsAdvSize(.T.)

SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+QE6->QE6_PRODUT))
	If RetFldProd(SB1->B1_COD,"B1_TIPOCQ") == "Q"
		If (TamSx3("QEK_NTFISC")[1]+TamSx3("QEK_SERINF")[1]+TamSx3("QEK_ITEMNF")[1] > TamSx3("QEL_NISERI")[1] .OR.;
		    TamSx3("QEK_NTFISC")[1]+TamSx3("QEK_SERINF")[1]+TamSx3("QEK_ITEMNF")[1] > TamSx3("QER_NISERI")[1] .OR.;
			TamSx3("D1_DOC")[1]+TamSx3("D1_SERIE")[1]+ TamSx3("D1_ITEM")[1] > TamSx3("QER_NISERI")[1] .OR.;
		 	TamSx3("D1_DOC")[1]+TamSx3("D1_SERIE")[1]+ TamSx3("D1_ITEM")[1] > TamSx3("QEL_NISERI")[1]) .AND. nOpc <> 2
			Help(" ",1,"QIENISERI")
			Return Nil
		EndIf
    EndIf
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada com a Validacao do usuario - Permite Acesso .T. ou .F.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQE010VAL
	lRetVal := ExecBlock("QE010VAL", .F., .F.,{nOpc, QE6->QE6_PRODUT, QE6->QE6_REVI})
    // Permite Acesso
	If !lRetVal 
		Return(NIL)
	EndIf
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Produto/Revisao possui Entradas cadastradas    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 4 .Or. nOpc == 5
	lTemMed := A010MePR(QE6->QE6_PRODUT,QE6->QE6_REVI)
	If nOpc == 5 .And. lTemMed 
		Return(NIL)
	Else
		If lTemMed
			nOpc := 2
		EndIf        
	EndIf
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche as opcoes do Folder											  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aTitulos,OemToAnsi(STR0007)) //"Ensaios"
Aadd(aTitulos,OemToAnsi(STR0008)) //"Nao-conformidades"
Aadd(aTitulos,OemToAnsi(STR0009)) //"Texto do Produto"
Aadd(aPaginas,"ENSAIOS")
Aadd(aPaginas,"NAO-CONFORMIDADES")
Aadd(aPaginas,"TEXTO DO PRODUTO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria as variaveis para edicao na enchoice								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("QE6",If(nOpc==3,.T.,.F.),.T.)            


cWhile  := Alltrim(RetSIX("QE7","1",.T.,{"QE7_ENSAIO"}))
cSeek 	:= RetSIX("QE6","3",.T.)

FillGetDados(	nOpc,; 							// numero correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
               	"QE7",;       					// area a ser utilizada;
               	1,;      						// nOrdem - ordem correspondente a chave de índice para preencher o  acols;
               	Iif((nOpc == 3),"",&cSeek),;  	// chave utilizada no posicionamento da área para preencher o acols; 
               	{|| &cWhile},; 					// bloco contendo a expressão a ser comparada com cSeekKey na condição  do While. 
               	{|| .T.},;  					// uSeekFor
               	,;  						 	// aNoFields - array contendo os campos que não estarao no aHeader;
               	,;  							// aYesFields - array contendo somente os campos que estarao no aHeader;
               	.F.,;      						// se verdadeiro, exibe apenas os campos de usuário;
                '',;      						// cQuery - query a ser executada para preencher o acols;
               	,;    				   			// bloco contendo funcao especifica para preencher o aCols; 
               	Iif((nOpc == 3),.T.,.F.),;  	// lEmpty 
               	,; 								// aHeaderAux
               	,; 		   						// aColsAux
               	,; 								// bAfterCols
               	,; 								// bBeforeCols
               	,; 								// bAfterHeader
               	'') 							// cAliasQry

//Salva a posicao do LSC
nPosLSC  := Ascan(aHeader,{|x|AllTrim(x[2])=="QE7_LSC"   })

//Acrescenta um posicao no ultimo elemento
AADD(aHeader,{})                 		
aIns(aHeader , nPosLSC+1)

If !Empty(GetSx3Cache("QE8_TEXTO","X3_CAMPO"))
	aHeader[nPosLSC+1] := Q010GetSX3("QE8_TEXTO")
EndIf	

For nX := 1 To Len(aCols)
	AADD(aCols[nX],{}) 
	aIns(aCols[nX], nPosLSC+1)
	aCols[nX][nPosLSC+1] := CriaVar(aHeader[nPosLSC+1,2],.T.) 
Next

aHeadEns := AClone(aHeader)
aColsEns := AClone(aCols) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda as posicoes das variaveis dos Ensaios no aCols					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosEns    := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_ENSAIO"})
nPosDEn    := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_DESENS"})
nPosUM     := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_UNIMED"})
nPosNom    := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_NOMINA"})
nPosAFI    := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_AFI"   })
nPosAFS    := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_AFS"   })
nPosLIC    := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_LIC"   })
nPosNiv    := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_NIVEL" })
nPosDesNiv := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_DESNIV"})
nPosTip    := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_TIPO"  })
nPosLab    := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_LABOR" })
nPosSeq    := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_SEQLAB"})
nPosMin    := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_MINMAX"})
nPosDoc    := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_METODO"})
nPosDocRev := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_REVDOC"})
nPosFor    := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_FORMUL"})
nPosTxt    := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE8_TEXTO" })   
nPsAmIIn   := Ascan(aHeadEns,{|x|Alltrim(x[2])=="QE7_AM_INS"})
nPosDUM    := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_DUNMED"})
nPosDLab   := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_DESLAB"})
nPosProd   := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_PRODUT"}) 
nPosPRevi  := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_REVI"})
nPosPlAm   := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_PLAMO"})
nPosDPlA   := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_DESPLA"})
nPosEnD    := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_ENSDES"})
nPosAmIn   := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_AM_INS"})
nPosAliWT  := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_ALI_WT"})
nPosRecWT  := Ascan(aHeadEns,{|x|AllTrim(x[2])=="QE7_REC_WT"})  

nUsadEns  := Len(aHeadEns)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aHeader das nao-conformidades associadas aos ensaios			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
aHeader := {}
aCols   := {}

FillGetDados(	nOpc,; 							// numero correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
               	"QE9",;       					// area a ser utilizada;
               	1,;      						// nOrdem - ordem correspondente a chave de índice para preencher o  acols;
               	,;  							// chave utilizada no posicionamento da área para preencher o acols; 
               	,; 						// bloco contendo a expressão a ser comparada com cSeekKey na condição  do While. 
               	{|| .T.},;  					// uSeekFor
               	,;  						 	// aNoFields - array contendo os campos que não estarao no aHeader;
               	,;  							// aYesFields - array contendo somente os campos que estarao no aHeader;
               	.F.,;      						// se verdadeiro, exibe apenas os campos de usuário;
                '',;      						// cQuery - query a ser executada para preencher o acols;
               	,;    				   			// bloco contendo funcao especifica para preencher o aCols; 
               	.T.,;  						// lEmpty 
               	,; 								// aHeaderAux
               	,; 		   						// aColsAux
               	,; 								// bAfterCols
               	,; 								// bBeforeCols
               	,; 								// bAfterHeader
               	) 							// cAliasQry

aHeadNco := AClone(aHeader)
aColsNco := {} 

nUsadNco := Len(aHeadNco)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva as posicoes dos campos referentes as nao-conformidades no aCols     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosNC  := Ascan(aHeadNco,{|x|Alltrim(x[2])=="QE9_NAOCON"})
nPosDNC := Ascan(aHeadNco,{|x|Alltrim(x[2])=="QE9_DESNCO"})
nPosCla := Ascan(aHeadNco,{|x|Alltrim(x[2])=="QE9_CLASSE"})
nPosDCl := Ascan(aHeadNco,{|x|Alltrim(x[2])=="QE9_DESCLA"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta e preenche o aCols com os ensaios relacionados					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3
	Q010FilEns(M->QE6_PRODUT,M->QE6_REVI)
Else
	Q010FilEns(QE6->QE6_PRODUT,QE6->QE6_REVI)
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera o Texto da Revisao do Produto 									  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc # 3
	cChave := QE6->QE6_CHAVE
	cTexto := QA_RecTxt(cChave,cEspecie,00,nTamLin,"QA2",aTextos)
EndIf	

nFat := 1 // Valor Default
If lFlatMode
	AAdd( aObjects, { 100,40,.T.,.T. } )
	If (nHRes >= 776 .AND. nHRes <= 800) // Resolucao 800x600
		AAdd( aObjects, { 100,60,.T.,.T. } )
		nFat := 0.92
	Else
		AAdd( aObjects, { 100,60,.T.,.T. } )
		nFat := 0.95
	EndIf	
Else                                       
	AAdd( aObjects, { 100,30,.T.,.T. } )
	AAdd( aObjects, { 100,70,.T.,.T. } )
EndIf

aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4], 0, 0 }
aPosObj:= MsObjSize( aInfo, aObjects, .T. )

oSize := FwDefSize():New(.T.)

oSize:AddObject("CABECALHO",100,50,.T.,.T.)
oSize:AddObject("GETDADOS",100,50,.T.,.T.)

oSize:lProp := .T.
oSize:aMargins := {3,3,3,3}

oSize:Process()

DEFINE MSDIALOG oDlg TITLE cCadastro From oSize:aWindSize[1],oSize:aWindSize[2] To oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd Pixel

oEncEsp := MsMGet():New(cAlias,nReg,nOpc,,,,,{oSize:GetDimension("CABECALHO","LININI"), oSize:GetDimension("CABECALHO","COLINI"), oSize:GetDimension("CABECALHO","LINEND"), oSize:GetDimension("CABECALHO","COLEND")},,,,"Q010EncTok(nOpc)" ,,oDlg,,.T.,,,,,,,.T.)

Aadd(aButtons,{"BMPVISUAL",{||If(nFldAtu==1,QDOView(,aCols[N,nPosDoc],QA_UltRvDc(aCols[N,nPosDoc],dDataBase,.f.,.f.)),MsgStop(cMsg))},STR0019,STR0027}) //"Visualizar conteudo do Documento..."###"Vis.Doct"

//Montagem do folder: nao-conformidades e texto do produto
oFolder := TFolder():New(oSize:GetDimension("GETDADOS","LININI"), oSize:GetDimension("GETDADOS","COLINI"),aTitulos,aPaginas,oDlg,,,, .T., .F.,oSize:GetDimension("GETDADOS","XSIZE"),oSize:GetDimension("GETDADOS","YSIZE"))
Aeval(oFolder:aDialogs,{|x|x := oDlg:oFont})

For nX := 1 to Len(oFolder:aDialogs)
   DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[nX]
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 3 - Edita o Texto do Produto 									  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 001,002 GET oTexto VAR cTexto MEMO NO VSCROLL SIZE oSize:GetDimension("GETDADOS","XSIZE")-6,oSize:GetDimension("GETDADOS","YSIZE")-20 OF oFolder:aDialogs[3] Pixel
oTexto:lReadOnly := If(nOpc==3.Or.nOpc==4,.F.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 2 - Monta a Getdados das nao-conformidades 						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := aClone(aHeadNco)
aCols   := aClone(aColsNco[nEnsAtu]) 
nUsado  := Len(aHeader)                                                       
N       := 1
oGetNco := MSGetDados():New(oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
	oSize:GetDimension("GETDADOS","LINEND"),oSize:GetDimension("GETDADOS","COLEND"),nOpc,"Q010NcoLOk", "Q010NcoTOk",,lDeleta,,,,,,,,,oFolder:aDialogs[2])
oGetNco:oBrowse:lDisablePaint := .T.
oGetNco:oBrowse:bDelOk        := {||If(lTemMed,If(aCols[oGetNco:oBrowse:nAt,Len(aCols[oGetNco:oBrowse:nAt])],;
	(aCols[oGetNco:oBrowse:nAt,Len(aCols[oGetNco:oBrowse:nAt])]:=.F.,oGetNco:oBrowse:Refresh()),NIL),NIL)}	
oGetNco:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 1 - Monta a Getdados dos Ensaios									  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := aClone(aHeadEns)
aCols   := aClone(aColsEns) 
nUsado  := Len(aHeader)                          
N       := 1 
oGetEns := MSGetDados():New(oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
	oSize:GetDimension("GETDADOS","LINEND")-20,oSize:GetDimension("GETDADOS","COLEND"), nOpc,"Q010EnsLOk","Q010EnsTOk","+QE7_SEQLAB",lDeleta,,,,999,,,,,oFolder:aDialogs[1])		

oGetEns:oBrowse:lDisablePaint := .T.           
oGetEns:oBrowse:bChange       := {||nEnsAtu := oGetEns:oBrowse:nAt,cEnsAtu := aCols[nEnsAtu,1],Q010AtuNco(),lPlaAmoEns := If(A010MovPAE(.F.),.F.,.T.)}
oGetEns:oBrowse:bDelOk        := {||If(lTemMed,If(aCols[oGetEns:oBrowse:nAt,Len(aCols[oGetEns:oBrowse:nAt])],;
	(aCols[oGetEns:oBrowse:nAt,Len(aCols[oGetEns:oBrowse:nAt])]:=.F.,oGetEns:oBrowse:Refresh()),NIL),Q010DelNco()),;
	If(A010MovPAE(),If(aCols[oGetEns:oBrowse:nAt,Len(aCols[oGetEns:oBrowse:nAt])],(aCols[oGetEns:oBrowse:nAt,Len(aCols[oGetEns:oBrowse:nAt])]:=.F.,;
	oGetEns:oBrowse:Refresh(),Q010DelNco(.F.)),NIL),NIL)}	
oGetEns:oBrowse:bEditCol:= {|| oGetEns:oBrowse:nAt := QE010OrdLab(),oGetEns:oBrowse:Refresh()}							   
oGetEns:oBrowse:Align := CONTROL_ALIGN_TOP    

oFolder:bSetOption := {|nAt|Q010SetEsp(nFldAtu := nAt,oFolder:nOption)}                               
oFolder:SetOption(1)                        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada criado para inclusao de botoes auxiliares na enchoicebar  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("Q010BUT")
	aButtons := ExecBlock("Q010BUT",.F.,.F., {nOpc,aButtons})
EndIf

If (nOpc == 3 .Or. nOpc == 4 )              
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,If(Q010EncTok(nOpc).And.;
		If(nFldAtu==1,oGetEns:TudoOk(),If(nFldAtu==2,oGetNco:TudoOk(),.T.)),;
		If(!Obrigatorio(aGets,aTela),nOpcA:=0,oDlg:End()),nOpcA:=0)},{||(oDlg:End(),nOpcA:=0)},,aButtons);
		VALID Q010SetEsp(nFldAtu,nFldAtu) .And. Q010EnsTOk(.F.)
Else
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||nOpcA:=2,oDlg:End()},,aButtons) 
EndIf	  

If nOpcA == 1       

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Armazena os Ensaios utilizados na revisao atual da Especificacao		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aEnsaios := {}
	For nLinCol := 1 to Len(aColsEns)
		Aadd(aEnsaios,{aColsEns[nLinCol,nPosEns],aColsEns[nLinCol,Len(aColsEns[nLinCol])]})			
	Next nLinCol		

	If nOpc == 3 .Or. nOpc == 4         
	
		//Grava a Especificacao do Produto
		Q010GrvEsp(nOpc,.F.)

		//Atualiza o Plano de Amostragem por Ensaios
		MsgRun(STR0017,STR0018,{||QComMovPAE(M->QE6_PRODUT,M->QE6_REVI,aEnsaios,,1)}) //"Atualizando o Plano de Amostragem por Ensaios..." ### "Aguarde"
		
	ElseIf nOpc == 5 .And. !lTemMed
		Q010DelEsp(nOpc,M->QE6_PRODUT,M->QE6_REVI)	
	                  
		//Atualiza o Plano de Amostragem por Ensaios
		MsgRun(STR0017,STR0018,{||QComMovPAE(M->QE6_PRODUT,M->QE6_REVI,aEnsaios,.T.,2)}) //"Atualizando o Plano de Amostragem por Ensaios..." ### "Aguarde"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada utilizado pela JNJ						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lQE010DUP
		ExecBlock("QE010DUP",.F.,.F.,{nOpc,aColsEns,aColsNco,cTexto,M->QE6_PRODUT,M->QE6_REVI}) 
	EndIf

EndIf

Return(NIL)                                                  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Q010SetEsp³ Autor ³Paulo Emidio de Barros ³ Data ³03/12/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a validacao na troca dos folders					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q010SetEsp(EXPN1,EXPN2)								  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Posicao do Folder selecionado					  ³±±
±±³			 ³ EXPN2 = Posicao do ultimo Folder selecionado				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T.														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q010SetEsp(nGot,nLost)
Local lRetorno := .T.

If nLost # NIL
	If nLost == 1
		aColsEns := aClone(aCols)
		oGetEns:oBrowse:lDisablePaint := .T.
		
		//Atualiza o aCols das Nao-conformidades
		Q010AtuNco()
		
	ElseIf nLost == 2
       aColsNco[nEnsAtu] := aClone(aCols)
	   oGetNco:oBrowse:lDisablePaint := .T.

	ElseIf nLost == 3
		oTexto:Hide()
	EndIf        
EndIf

If nGot # NIL
	If nGot == 1
		aHeader := aClone(aHeadEns)
		aCols   := aClone(aColsEns)
		nUsado  := Len(aHeader)
		N       := 1
		oGetEns:oBrowse:lDisablePaint := .F.
        oGetEns:oBrowse:Refresh()
	ElseIf nGot == 2
		aHeader := aClone(aHeadNco)
		aCols   := aClone(aColsNco[nEnsAtu])
		nUsado  := Len(aHeader)
	 	N       := 1
		oGetNco:oBrowse:lDisablePaint := .F.
		oGetNco:oBrowse:Refresh()          
	ElseIf nGot == 3
		oTexto:Show()
		oTexto:Refresh()
	EndIf        
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Q010FilEns³ Autor ³Paulo Emidio de Barros ³ Data ³03/12/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche o aCols com os Ensaios correspondentes			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q010FilEns(EXPC1,EXPC2)								  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Produto								  ³±±
±±³			 ³ EXPC1 = Revisao do Produto								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQIE (Inspecao de Entradas)					 		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q010FilEns(cProduto,cRevi)
Local nRegEns 	:= 0
Local nCntFor 	:= 0
Local nDec    	:= 0
Local nPos    	:= 0
Local nPos1    	:= 0
Local nX 		:= 0
Local aHeadBkp 	:= aClone(aHeader)
Local aColsBkp 	:= aClone(aCols)
Local cWhileQE8 := ""
Local cSeekQE8 	:= "" 
Local cLIE 		:= "" 
Local cLSE 		:= "" 

aHeader := {}
aCols 	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche o aCols com os Ensaios mensuraveis					 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCntFor := 1 to Len(aColsEns)  
	aColsEns[nCntFor,nPosDEn] := A010DEns(aColsEns[nCntFor,nPosEns])
	aColsEns[nCntFor,nPosDLab] := If(!Empty(aColsEns[nCntFor,nPosLab]),	PadR(Tabela("Q2",aColsEns[nCntFor,nPosLab]),TamSX3("QE7_DESLAB")[1]),Space(TamSX3("QE7_DESLAB")[1]))
	aColsEns[nCntFor,nPosDUM] := QA_DESUM(aColsEns[nCntFor,nPosUM],.F.)
	aColsEns[nCntFor,nPosDesNiv] := If(!Empty(aColsEns[nCntFor,nPosNiv]),	PadR(Tabela("Q6",aColsEns[nCntFor,nPosNiv]),TamSX3("QE7_DESNIV")[1]),Space(TamSX3("QE7_DESNIV")[1]))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula os valores dos afastamentos AFI e AFS					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLIE := Posicione("QE7",1,xFilial("QE7")+cProduto+cRevi+aColsEns[nCntFor,nPosEns],"QE7_LIE")
	cLSE := QE7->QE7_LSE
	
	If At(":",AllTrim(aColsEns[nCntFor,nPosNom])) > 0
		If aColsEns[nCntFor,nPosMin] $ "1ß2" //Controla Minimo/Maximo ou so Minimo
			aColsEns[nCntFor,nPosAFI] 	:= cLIE
		EndIf
		
		If aColsEns[nCntFor,nPosMin] $ "1ß3" //Controla Minimo/Maximo ou so Maximo
			aColsEns[nCntFor,nPosAFS]  	:= cLSE
		EndIf
	ElseIf At("i",AllTrim(aColsEns[nCntFor,nPosMin])) > 0
		If aColsEns[nCntFor,nPosMin] $ "1ß2" //Controla Minimo e Maximo ou somente Minimo
			aColsEns[nCntFor,nPosAFI]   := qCalPol({cLIE,aColsEns[nCntFor,nPosMin]},2,aColsEns[nCntFor,nPosAFI])
		EndIf
		
		If aColsEns[nCntFor,nPosMin] $ "1ß3" //Controla Minimo e Maximo ou somente maximo
			aColsEns[nCntFor,nPosAFS]   := qCalpol({cLSE,aColsEns[nCntFor,nPosMin]},2,aColsEns[nCntFor,nPosAFS])
		EndIf
	Else
		If cPaisLoc <> "MEX"
			nDec := If("," $ AllTrim(aColsEns[nCntFor,nPosNom]),Len(AllTrim(aColsEns[nCntFor,nPosNom]))-At(",",AllTrim(aColsEns[nCntFor,nPosNom])),0)
		Else
			nDec := If("." $ AllTrim(aColsEns[nCntFor,nPosNom]),Len(AllTrim(aColsEns[nCntFor,nPosNom]))-At(".",AllTrim(aColsEns[nCntFor,nPosNom])),0)  
		Endif	
		
		If aColsEns[nCntFor,nPosMin] $ "1ß2"  //Controla Minimo e Maximo ou somente Minimo
			aColsEns[nCntFor,nPosAFI] := Str(SuperVal(cLIE)-SuperVal(aColsEns[nCntFor,nPosNom]),TamSx3("QE7_AFI")[1],nDec)
			If cPaisLoc <> "MEX"
				aColsEns[nCntFor,nPosAFI] := StrTran(aColsEns[nCntFor,nPosAFI],".",",")
			Endif	
		EndIf
		
		If aColsEns[nCntFor,nPosMin] $ "1ß3"  //Controla Minimo e Maximo ou somente maximo
			aColsEns[nCntFor,nPosAFS] := Str(SuperVal(cLSE)-SuperVal(aColsEns[nCntFor,nPosNom]),TamSx3("QE7_AFS")[1],nDec)
			If cPaisLoc <> "MEX"
				aColsEns[nCntFor,nPosAFS] := StrTran(aColsEns[nCntFor,nPosAFS],".",",")
			Endif	
		EndIf
	EndIf

Next
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche o aCols com os Ensaios do tipo Texto					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cWhileQE8  := Alltrim(RetSIX("QE8","1",.T.,{"QE8_ENSAIO"}))
cSeekQE8   := RetSIX("QE6","3",.T.)

FillGetDados(	4,; 							// numero correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
               	"QE8",;       					// area a ser utilizada;
               	1,;      						// nOrdem - ordem correspondente a chave de índice para preencher o  acols;
               	&cSeekQE8,;  	// chave utilizada no posicionamento da área para preencher o acols; 
               	{|| &cWhileQE8},; 					// bloco contendo a expressão a ser comparada com cSeekKey na condição  do While. 
               	{|| .T.},;  					// uSeekFor
               	,;  						 	// aNoFields - array contendo os campos que não estarao no aHeader;
               	,;  							// aYesFields - array contendo somente os campos que estarao no aHeader;
               	.F.,;      						// se verdadeiro, exibe apenas os campos de usuário;
                '',;      						// cQuery - query a ser executada para preencher o acols;
               	,;    				   			// bloco contendo funcao especifica para preencher o aCols; 
                .F.,;  	// lEmpty 
               	,; 								// aHeaderAux
               	,; 		   						// aColsAux
               	,; 								// bAfterCols
               	,; 								// bBeforeCols
               	,; 								// bAfterHeader
               	'') 							// cAliasQry

If !INCLUI .AND. (Len(aCols)>=1 .AND. !Empty(Alltrim(aCols[1,nPosEns])))
	nRegEns := Len(aColsEns)
	nUsadEns  := Len(aHeadEns)               
	For nCntFor := 1 To Len(aCols)
    	If (Len(aColsEns)>=1 .AND. !Empty(Alltrim(aColsEns[1,nPosEns]))) 
			Aadd(aColsEns,Array(nUsadEns+1))
		Else
		    nRegEns  := 0
	    EndIf
	    For nX := 1 To nUsadEns-2
			aColsEns[nRegEns+nCntFor,nX] := CriaVar(aHeadEns[nX,2],.T.)
		Next
	    For nX := 1 To Len(aHeader)
			If AllTrim(aHeader[nX,2]) == "QE8_DESENS"
				nPos := Ascan(aHeader,{|x|AllTrim(x[2])=="QE8_ENSAIO"})
				aColsEns[nRegEns+nCntFor,nPosDEn] := A010DEns(aCols[nCntFor,nPos])
			ElseIf AllTrim(aHeader[nX,2]) == "QE8_DESLAB"
				nPos := Ascan(aHeader,{|x|AllTrim(x[2])=="QE8_LABOR"})
				aColsEns[nRegEns+nCntFor,nPosDLab] := If(!Empty(aCols[nCntFor,nPos]),;
					Tabela("Q2",aCols[nCntFor,nPos]),Space(TamSX3("QE8_DESLAB")[1]))
			ElseIf AllTrim(aHeader[nX,2]) == "QE8_DESNIV"
				nPos := Ascan(aHeader,{|x|AllTrim(x[2])=="QE8_NIVEL"})
				aColsEns[nRegEns+nCntFor,nPosDesNiv] := If(!Empty(aCols[nCntFor,nPos]),;
					Tabela("Q6",aCols[nCntFor,nPos]),Space(TamSX3("QE8_DESNIV")[1]))
			ElseIf AllTrim(aHeader[nX,2]) == "QE8_TEXTO"
				aColsEns[nRegEns+nCntFor,nPosTxt] := aCols[nCntFor,nX]
			Else
				nPos  := Ascan(aHeadEns,{|x|AllTrim(x[2])==AllTrim("QE7"+Right(aHeader[nX,2],Len(aHeader[nX,2])-3))})
				If nPos > 0
					aColsEns[nRegEns+nCntFor,nPos] := aCols[nCntFor,nX]
				EndIf
			EndIf				
		Next nCntFor
		aColsEns[nRegEns+nCntFor,nUsadEns+1] := .F.
	Next
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria uma nova posicao caso o aColsEns esteja vazio				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aColsEns) == 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Preenche uma linha do aCols vazia para a nao-conformidade    	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Q010FilNco(cProduto,cRevi,)

Else 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ordena os Ensaios por Laboratorio+Sequencia do Laboratorio				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsEns := aSort(aColsEns,,,{|x,y|x[nPosLab]+x[nPosSeq]<y[nPosLab]+y[nPosSeq]})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Preenche as nao-conformidades relacionadas aos ensaios definidos		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aeval(aColsEns,{|x,y|Q010FilNco(cProduto,cRevi,aColsEns[y,nPosEns])})
	
EndIf	

aHeader := aClone(aHeadBkp)
aCols   := aClone(aColsBkp)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Q010FilNco³ Autor ³Paulo Emidio de Barros ³ Data ³03/12/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche o aCols com as nao-conformidades corresopondentes ³±±
±±³			 ³ ao Ensaio.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q010FilNco(EXPC1,EXPC2,EXPC3)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Produto								  ³±±
±±³			 ³ EXPC2 = Revisao do Produto								  ³±±
±±³			 ³ EXPC3 = Codigo do Ensaio									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQIE (Inspecao de Entradas)					 		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q010FilNco(cProduto,cRevi,cEnsaio)
Local aAreaAnt := GetArea()
Local aColsAux := {}
Local nX       := 0

Default cEnsaio := CriaVar("QE1_ENSAIO",.F.)
                      
dbSelectArea("QE9")
dbSetOrder(1)
If dbSeek(xFilial("QE9")+cProduto+cRevi+cEnsaio)
    
	While !Eof() .And. QE9_FILIAL == xFilial("QE9") .And.;
		(QE9_PRODUT+QE9_REVI+QE9_ENSAIO) == (cProduto+cRevi+cEnsaio)

	    Aadd(aColsAux,Array(Len(aHeadNco)+1))
		For nX := 1 To Len(aHeadNco)                
			If IsHeadRec(aHeadNco[nX,2])
				aColsAux[Len(aColsAux),nX] := QE9->(RecNo())
		    ElseIf AllTrim(aHeadNco[nX,2]) == "QE9_ALI_WT"
		    	aColsAux[Len(aColsAux),nX] := "QE9"	
	  		ElseIf (aHeadNco[nX,10] # "V")
			    aColsAux[Len(aColsAux),nX] := &(FieldName(FieldPos(AllTrim(aHeadNco[nX,2]))))
	  		Else
	  		    aColsAux[Len(aColsAux),nX] := CriaVar(AllTrim(aHeadNco[nX,2]))
	  		EndIf
	  		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Preenche a descricao da classe e da descricao da nao-conformidade		  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim(aHeadNco[nX,2]) == "QE9_DESNCO"
				aColsAux[Len(aColsAux),nX] := A020DNCo(QE9->QE9_NAOCON)
			ElseIf AllTrim(aHeadNco[nX,2]) == "QE9_DESCLA"
				aColsAux[Len(aColsAux),nX] := A040DCla(QE9->QE9_CLASSE)
			EndIf
	  		
	    Next
	    aColsAux[Len(aColsAux),nUsadNco+1] := .F.

		dbSkip()	
	EndDo		
	
Else                                       
	Aadd(aColsAux,Array(Len(aHeadNco)+1))

	For nX := 1 to Len(aHeadNco)      
	    If AllTrim(aHeadNco[nX,2]) == "QE9_ALI_WT"
	    	aColsAux[1,nX] := "QE9"	
	    ElseIf aHeadNco[nX,8] == "C"
			aColsAux[1,nX] := Space(aHeadNco[nX,4])
	   	ElseIf aHeadNco[nX,8] == "N"
	       	aColsAux[1,nX] := 0
	    ElseIf aHeadNco[nX,8] == "D"
	        aColsAux[1,nX] := dDataBase
	   	ElseIf aHeadEns[nX,8] == "M"
	        aColsAux[1,nX] := ""
	    Else
	   	    aColsAux[1,nX] := .F.
		EndIf
	Next nX

	aColsAux[1,nUsadNco+1] := .F. 
EndIf

Aadd(aColsNco,aClone(aColsAux))

RestArea(aAreaAnt)
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Q010EnslOk³Revisao³ Paulo Emidio de Barros³ Data ³03/12/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a linha digitada esta' Ok - Getdados dos Ensaios³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPO1 = Objeto a ser verificado. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                 
Function Q010EnsLOk(o)
Local lRetorno := .T. 
Local cCarta   := ""
Local cVar     := ""
Local cProcura := aCols[N,nPosEns]
Local cVerFam  := GetMv("MV_QINTQMT")   

If Len(aCols)==1 .and. Empty(aCols[1,1]) .and. lQE010DUP
	Return(.T.)
EndIF

If !aCols[N,Len(aCols[N])]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se campo Ensaio esta' preenchido                   	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aCols[N,nUsado+1] .And. lRetorno
		If Empty(aCols[N,nPosEns])
			Help(" ",1,"Q_010ENSA")
			lRetorno := .F.
		EndIf
	EndIf      
	
	If lRetorno
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Ensaio ja' existe                 				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nAchou := Ascan(aCols,{|x|x[nPosEns]==cProcura .And. !(x[Len(aCols[n])])})
		If nAchou > 0 .And. nAchou # N
			Help(" ",1,"A010EXIENP")
			lRetorno := .F.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Ensaio esta' cadastrado           				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno
		If !Empty(aCols[N,nPosEns])
			If ! ExistCpo("QE1",aCols[N,nPosEns])
				lRetorno := .F.
			EndIf
		EndIf
	EndIf

	If lRetorno
		QE1->(dbSetOrder(1))
		QE1->(dbSeek(xFilial("QE1")+aCols[N,nPosEns]))
		cCarta := QE1->QE1_CARTA
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Laboratorio esta' preenchido                  	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. ( Empty(aCols[N,nPosEns]) .Or. Empty(aCols[N,nPosLab]) .Or.;
		Empty(aCols[N,nPosSeq]) )
		Help(" ",1,"Q_010LABO")
		lRetorno := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Laboratorio esta' cadastrado                  	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno
		If ! Empty(aCols[N,nPosEns]) .And. !Empty(aCols[N,nPosLab])
			If !ExistCpo("SX5",'Q2'+aCols[N,nPosLab])
				lRetorno := .F.
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a UM esta' cadastrada               				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno
		If ! Empty(aCols[N,nPosEns]) .And. cCarta # 'TXT'
			If Empty(aCols[N,nPosUM])
				Help(" ",1,"Q_010UNIM")
				lRetorno := .F.
			Else
				If !ExistCpo("SAH",aCols[N,nPosUM])
					lRetorno := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Controla Min/Max foi preenchido   				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno
		If ! Empty(aCols[N,nPosEns]) .and. cCarta # 'TXT'
			If Empty(aCols[N,nPosMin])
				Help(" ",1,"Q_010MIMA")
				lRetorno := .F.
			EndIf
		EndIf
	EndIf

	If lRetorno
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Nominal e' um numero valido           			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aCols[N,nPosEns]) .And. cCarta # 'TXT'
			If Empty(aCols[N,nPosNom])
				Help(" ",1,"Q_010NOMI")
				lRetorno := .F.
			Else
				cVar := aCols[N,nPosNom]
				If cCarta == "TMP"
					If !A010VTempo(@cVar)
						HELP(" ",1,"QA_NUMINV")
						lRetorno := .F.
					EndIf
				Else
					If !QA_VerNum2(@cVar)
						HELP(" ",1,"A010LSCINV")
						lRetorno := .F.
					EndIf
				EndIf
				aCols[N,nPosNom] := cVar
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Verifica se campo AFS esta' preenchido                      	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. !Empty(aCols[N,nPosEns]) .And. cCarta # 'TXT' .And.;
 		aCols[N,nPosMin] $ "1.3" 
		If Empty(aCols[N,nPosAFS])
			Help(" ",1,"Q_010VAFS")
			lRetorno := .F.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se campo AFI esta' preenchido                      	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. !Empty(aCols[N,nPosEns]) .And. cCarta # 'TXT' .And.;
		aCols[N,nPosMin] $ "1.2" 
		If Empty(aCols[N,nPosAFI])
			Help(" ",1,"Q_010VAFI")
 			lRetorno := .F.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o LIC e' menor ou igual ao LSC      				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. !Empty(aCols[N,nPosEns]) .And. cCarta # 'TXT' .And.;
		aCols[N,nPosMin] == "1" 
		If SuperVal(aCols[N,nPosLIC]) > SuperVal(aCols[N,nPosLSC]) 
			HELP(" ",1,"A010LSCINV")
			lRetorno := .F.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Texto esta' cadastrado            				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno
		If !Empty(aCols[N,nPosEns]) .And. cCarta == 'TXT'
			If Empty(aCols[N,nPosTxt])
				Help(" ",1,"Q_010TEXT")
				lRetorno := .F.
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Familia do Instrumento esta' cadastrada       	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. cVerFam == "S"
		If !Empty(aCols[N,nPosEns]) .And. !Empty(aCols[N,nPosTip])
			If !ExistCpo("QM1",aCols[N,nPosTip])
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a formatacao das Pictures dos campos: AFI, AFS,  ³
	//³ LIC e LSC, estao iguais ao Valor Nominal.					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno
		If QE1->QE1_CARTA <> "TXT"
			If !qVrfCalPol(aCols[N,nPosNom],,.F.)
				Help(" ",,1,"QA010INVLD","Valor invalido no campo "+" NOM",1) //"Valor invalido no campo "
				lRetorno := .F.
			EndIf         

			If !qVrfCalPol(aCols[N,nPosAFI],,.F.)
				Help(" ",,1,"QA010INVLD","Valor invalido no campo "+" AFI",1) //"Valor invalido no campo "
				lRetorno := .F.
			EndIf         
		      
			If !qVrfCalPol(aCols[N,nPosAFS],,.F.)
				Help(" ",,1,"QA010INVLD","Valor invalido no campo "+" AFS",1) //"Valor invalido no campo "
				lRetorno := .F.
		    EndIf
    
	    	If !qVrfCalPol(aCols[N,nPosLIC],,.F.)
				Help(" ",,1,"QA010INVLD","Valor invalido no campo "+" LIC",1) //"Valor invalido no campo "
				lRetorno := .F.
	    	EndIf
	                            
		    If !qVrfCalPol(aCols[N,nPosLSC],,.F.)
				Help(" ",,1,"QA010INVLD","Valor invalido no campo "+" LSC",1) //"Valor invalido no campo "
				lRetorno := .F.
			EndIf
		EndIf	
	EndIf	
	
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Q010EnsTOk³Revisao³ Paulo Emidio de Barros³ Data ³03/12/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se toda a getdados esta' Ok - Getdados dos Ensaios ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³EXPL1 = Indica se a Critica de dados sera realizada no aCols³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q010EnsTOk(laCols)
Local nX       := 0 
Local lRetorno := .T. 
Local cCarta   := ""
Local cVar     := ""
Local cVerFam  := GetMv("MV_QINTQMT")
Local aSavCols := {}
Local lEnsCalc := .f.
Local nQtdEns  := 0         
Local lVazio   := .F.
Local lTmAmIn  := .F.
Local lTipo    := .F.



If ValType(laCols) == "O" .Or. ValType(laCols) == "U"
	laCols := .T.     	 
EndIf

If !laCols
    aSavCols := aClone(aCols)                 
    aCols    := aClone(aColsEns)
EndIf

If Len(aCols)==1 .and. Empty(aCols[1,1]) .and. lQE010DUP
	Return(.T.)
EndIF
    
For nX := 1 to Len(aCols)
	If !aCols[nX,Len(aCols[nX])]
		lVazio:= .T.
	Endif
Next nX

If !(lVazio)
	Help(" ",1,"QA_CPOOBR")
	lRetorno := .F.  
Else
	For nX := 1 to Len(aCols)
	    lTipo := .F.
		If !aCols[nX,Len(aCols[nX])]
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se campo Ensaio esta' preenchido                   	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !aCols[nX,Len(aCols[nX])] .And. lRetorno
				If Empty(aCols[nX,nPosEns])
					Help(" ",1,"QA_CPOOBR",,"( "+OemToAnsi(STR0047)+" )",4)	//"Ensaio"
					lRetorno := .F.
					Exit
				EndIf
			EndIf      
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o Ensaio esta' cadastrado           				 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRetorno
				If !Empty(aCols[nX,nPosEns])
					If ! ExistCpo("QE1",aCols[nX,nPosEns])
						lRetorno := .F.
						Exit
					EndIf
				EndIf
			EndIf
		
			If lRetorno
				QE1->(dbSetOrder(1))
				QE1->(dbSeek(xFilial("QE1")+aCols[nX,nPosEns]))
				cCarta   := QE1->QE1_CARTA
				nQtdEns  := QE1->QE1_QTDE              
				lEnsCalc := IIF(QE1->QE1_TIPO=="1",.t.,.f.)  
			EndIf
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida os Ensaios Calculados.									 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRetorno  .and. QE1->QE1_TIPO == "1"
				lTipo :=.T.
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ignora o Campo Formula quando usado em outros modulos (Existem amarrações entre calculo pre-existentes)
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cForAux := " "    
			if nPosfor > 0 	
				cForAux := aCols[nX,nPosFor] 
			Endif
			
			If Empty(cForAux) .And. lTipo
					Help(" ",1,"QA_CPOOBR",,"( "+OemToAnsi(STR0048)+" )",4)	//"Ensaios Calculados"
					lRetorno := .F.
			Else
				lRetorno := QE010ValCalc(lRetorno,cForAux,lTipo,nPosEns,cCarta,nQtdEns)
			
			EndIf
				
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o Laboratorio esta' preenchido                  	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRetorno .And. ( Empty(aCols[nX,nPosEns]) .Or. Empty(aCols[nX,nPosLab]) .Or.;
				Empty(aCols[nX,nPosSeq]) )
				Help(" ",1,"QA_CPOOBR",,"( "+OemToAnsi(STR0049)+" )",4)	//"Laboratorio"
				lRetorno := .F.
				Exit
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o Laboratorio esta' cadastrado                  	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRetorno
				If ! Empty(aCols[nX,nPosEns]) .And. !Empty(aCols[nX,nPosLab])
					If !ExistCpo("SX5","Q2"+aCols[nX,nPosLab])
						lRetorno := .F.
						Exit
					EndIf
				EndIf
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a UM esta' cadastrada               				 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRetorno
				If ! Empty(aCols[nX,nPosEns]) .And. cCarta # 'TXT'
					If Empty(aCols[nX,nPosUM])
						Help(" ",1,"QA_CPOOBR",,"( "+OemToAnsi(STR0050)+" )",4)	//"Unidade"
						lRetorno := .F.
						Exit
					Else
						If !ExistCpo("SAH",aCols[nX,nPosUM])
							lRetorno := .F.
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o Controla Min/Max foi preenchido   				 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRetorno
				If ! Empty(aCols[nX,nPosEns]) .and. cCarta # "TXT"
					If Empty(aCols[nX,nPosMin])
						Help(" ",1,"QA_CPOOBR",,"( "+OemToAnsi(STR0051)+" )",4)	//"Min/Max"
						lRetorno := .F.
						Exit
					EndIf
				EndIf
			EndIf
		
			If lRetorno
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se o Nominal e' um numero valido           			 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(aCols[nX,nPosEns]) .And. cCarta # "TXT"
					If Empty(aCols[nX,nPosNom])
						Help(" ",1,"QA_CPOOBR",,"( "+OemToAnsi(STR0052)+" )",4)	//"Nominal"
						lRetorno := .F.
						Exit
					Else
						cVar := aCols[nX,nPosNom] 
						If cCarta == "TMP"
							If !A010VTempo(@cVar)
								HELP(" ",1,"QA_NUMINV")
								lRetorno := .F.
							EndIf
						Else
							If !QA_VerNum2(@cVar)
								HELP(" ",1,"A010LSCINV")
								lRetorno := .F.
								Exit
							EndIf
						EndIF
						aCols[nX,nPosNom] := cVar
					EndIf
				EndIf
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Verifica se campo AFS esta' preenchido                      	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRetorno .And. !Empty(aCols[nX,nPosEns]) .And. cCarta # 'TXT' .And.;
		 		aCols[nX,nPosMin] $ "1.3" 
				If Empty(aCols[nX,nPosAFS])
					Help(" ",1,"QA_CPOOBR",,"( "+OemToAnsi(STR0053)+" )",4)	//"AFS"
					lRetorno := .F.
					Exit
				EndIf
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se campo AFI esta' preenchido                      	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRetorno .And. !Empty(aCols[nX,nPosEns]) .And. cCarta # 'TXT' .And.;
				aCols[nX,nPosMin] $ "1.2" 
				If Empty(aCols[nX,nPosAFI])
					Help(" ",1,"QA_CPOOBR",,"( "+OemToAnsi(STR0054)+" )",4)	//"AFI"
		 			lRetorno := .F.
		 			Exit
				EndIf
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o LIC e' menor ou igual ao LSC      				 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRetorno .And. !Empty(aCols[nX,nPosEns]) .And. cCarta # 'TXT' .And.;
				aCols[nX,nPosMin] == "1" 
				If SuperVal(aCols[nX,nPosLIC]) > SuperVal(aCols[nX,nPosLSC]) 
					HELP(" ",1,"A010LSCINV")
					lRetorno := .F.
					Exit
				EndIf
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o Texto esta' cadastrado            				 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRetorno
				If !Empty(aCols[nX,nPosEns]) .And. cCarta == 'TXT'
					If Empty(aCols[nX,nPosTxt])
						Help(" ",1,"QA_CPOOBR",,"( "+OemToAnsi(STR0055)+" )",4)	//"Ensaio Texto"
						lRetorno := .F.
						Exit
					EndIf
				EndIf
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a Familia do Instrumento esta' cadastrada       	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRetorno .And. cVerFam == "S"
				If !Empty(aCols[nX,nPosEns]) .And. !Empty(aCols[nX,nPosTip])
					If !ExistCpo("QM1",aCols[nX,nPosTip])
						lRetorno := .F.
						Exit
					EndIf
				EndIf
			EndIf
			If Alltrim(aCols[nX,nPsAmIIn]) $ "2|3"
				lTmAmIn := .T.
			Endif
		EndIf
	Next nX
Endif	

If lRetorno 
	If lTmAmIn
		lRetorno := .T.
	Else
		MessageDlg(STR0044,,3)  //"A Especificacao devera ter no minino uma Inspecao ou uma Amostra e Inspecao"
		lRetorno := .F.	
	Endif
Endif	

If !laCols
    aCols := aClone(aSavCols)                 
EndIf

Return(lRetorno)
                   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Q010NcolOk³ Autor ³ Paulo Emidio de Barros³ Data ³ 15/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a validacao da linha digitada nas nao-conformidades³±±
±±³			 ³ associadas aos Ensaios.									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto a ser verificado. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q010NcoLOk(o)
Local lRetorno := .T.
Local cProcura := aCols[N,nPosEns]

If !(aCols[N,Len(aCols[N])])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se campo Nao Conformidade esta' preenchido         	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aCols[N,nUsado+1] .And. lRetorno             
		If Empty(aCols[N,nPosNC])          
			Help(" ",1,"QA_CPOOBR",,"( "+OemToAnsi(STR0056)+" )",4)	//Nao-Conformidade
			lRetorno := .F.
		EndIf
	EndIf
	If lRetorno
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a NC ja' existe                     	         	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nAchou := Ascan(aCols,{|x|x[nPosNC]==cProcura .And. !(x[Len(aCols[N])])})
		If nAchou > 0 .And. nAchou # N .And. !Empty(aCols[N,nPosCla])
			Help(" ",1,"A010EXINCE")
			lRetorno := .F.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a NC esta' cadastrada              					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno
		If ! Empty(aCols[N,nPosNC])
			If !ExistCpo("SAG",aCols[N,nPosNC])
				lRetorno := .F.
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Classe da NC esta' cadastrada     				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno
		If ! Empty(aCols[N,nPosNC]) .And. !Empty(aCols[N,nPosCla])
			If !ExistCpo("QEE",aCols[N,nPosCla])
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Q010NcoTOk³ Autor ³ Paulo Emidio de Barros³ Data ³ 15/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a validacao da linha digitada nas nao-conformidades³±±
±±³			 ³ associadas aos Ensaios.									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto a ser verificado. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q010NcoTOk(o)
Local lRetorno := .T.
Local nPosNco  := 0

For nPosNco := 1 to Len(aCols)

	If !(aCols[nPosNco,Len(aCols[nPosNco])])
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se campo Nao Conformidade esta' preenchido         	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !aCols[nPosNco,nUsado+1] .And. lRetorno
			If Empty(aCols[nPosNco,nPosNC])          
				Help(" ",1,"QA_CPOOBR",,"( "+OemToAnsi(STR0056)+" )",4)	//Nao-Conformidade
				lRetorno := .F.
			EndIf        
		EndIf
		
		If lRetorno
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a NC ja' existe                     	         	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nAchou := Ascan(aCols,{|x|x[nPosNC]==aCols[nPosNco,nPosEns] .And. !(x[Len(aCols[nPosNco])])})
			If (nAchou > 0) .And. (nAchou # nPosNco) .And. !Empty(aCols[nPosNco,nPosCla])
				Help(" ",1,"A010EXINCE")
				lRetorno := .F.
			EndIf
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a NC esta' cadastrada              					 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRetorno
			If ! Empty(aCols[nPosNco,nPosNC])
				If !ExistCpo("SAG",aCols[nPosNco,nPosNC])
					lRetorno := .F.
				EndIf
			EndIf
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a Classe da NC esta' cadastrada     				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRetorno
			If ! Empty(aCols[nPosNco,nPosNC]) .And. !Empty(aCols[nPosNco,nPosCla])
				If !ExistCpo("QEE",aCols[nPosNco,nPosCla])
					lRetorno := .F.
				EndIf
			EndIf
		EndIf
	EndIf                     
	
	If !lRetorno 
		Exit
	EndIf	
	
Next nPosNco

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Q010EncTok³Autor  ³ Paulo Emidio de Barros³ Data ³03/12/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao na confirmacao da EnchoiceBar					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q010EncTok(nOpc)
Local lRetorno := .T.
Local lTemEnt  := .F.
                         
If nOpc == 3.Or. nOpc == 4                        

	//Verifica se a chave esta duplicada
	If Inclui
		lRetorno := Qie010Chav()
	EndIf
	
	If lRetorno
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Fator Conversao Un. Medida 1 p/ Un. Amostragem 1		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(M->QE6_UNMED1) .And. M->QE6_UNMED1 # M->QE6_UNAMO1 .And.;
			(Empty(M->QE6_FATCO1) .Or. Empty(M->QE6_TIPCO1))
			Help( " ", 1, "Q_010FAOBR" )	//"Fator Conversao/Tipo Conversor sao Obrigatorios quando as Un Medida e Amostr. sao diferentes"
			lRetorno := .F.
		Endif
	EndIf
	
	If lRetorno
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Fator Conversao Un. Medida 2 p/ Un. Amostragem 2		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(M->QE6_UNMED2) .And. M->QE6_UNMED2 # M->QE6_UNAMO2 .And.;
			(Empty(M->QE6_FATCO2) .Or. Empty(M->QE6_TIPCO2))
			Help( " ", 1, "Q_010FAOBR" )	//"Fator Conversao/Tipo Conversor sao Obrigatorios quando as Un Medida e Amostr. sao diferentes"
			lRetorno := .F.
		Endif
	EndIf
	
	If lRetorno
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste Shelf-life se unidade for "Ano" 						 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If M->QE6_UNSHEL == "3" .And. M->QE6_SHLF > 99
			MessageDlg(OemToAnsi(STR0010),,1)	//"Shelf-Life n„o pode ser maior que 99 anos."
			lRetorno := .F.
		EndIf
	EndIf
	
	If lRetorno
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se Un. Medida 1 = Un. Amost. 1, limpa Fat. Conv. 1				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (M->QE6_UNMED1 == M->QE6_UNAMO1) .And. !Empty(M->QE6_FATCO1)
			M->QE6_FATCO1 := Space(Len(M->QE6_FATCO1))
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se Un. Medida 1 = Un. Amost. 1, limpa Tipo Conv. 1				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (M->QE6_UNMED1 == M->QE6_UNAMO1) .And. !Empty(M->QE6_TIPCO1)
			M->QE6_TIPCO1 := Space(Len(M->QE6_TIPCO1))
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se limpar Un. Medida 2, limpa Fat. Conv. 2 tambem 				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(M->QE6_UNMED2) .And. Empty(M->QE6_UNAMO2) .And. !Empty(M->QE6_FATCO2) .Or.;
			(M->QE6_UNMED2 == M->QE6_UNAMO2 .And. !Empty(M->QE6_FATCO2))
			M->QE6_FATCO2 := Space(Len(M->QE6_FATCO2))
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se limpar Un. Medida 2, limpa Tipo Conv. 2 tambem 				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(M->QE6_UNMED2) .And. Empty(M->QE6_UNAMO2) .And. !Empty(M->QE6_TIPCO2) .Or.;
			(M->QE6_UNMED2 == M->QE6_UNAMO2 .And. !Empty(M->QE6_TIPCO2))
			M->QE6_TIPCO2 := Space(Len(M->QE6_TIPCO2))
		EndIf
		
	EndIf
	
	If lRetorno
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste Fator de Conversão com o tipo de conversão.			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(M->QE6_TIPCO1) .And. SuperVal(M->QE6_FATCO1) == 0
			MessageDlg(OemToAnsi(STR0042),,1) 
			lRetorno := .F.
		EndIf
	EndIf
	
	
ElseIf nOpc == 5
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existem entradas cadastradas                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lTemEnt := A010MePR(M->QE6_PRODUT,M->QE6_REVI)
	If lTemEnt 
		lRetorno := .F.
	EndIf               
	
EndIf	

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Qie010Chav³ Autor ³ Wagner Xavier 		³ Data ³ 20/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da chave da Especificacao do Produto			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qie010Chav()
Local aAreaAnt := GetArea()
Local lRetorno := .T.

If !Empty(M->QE6_REVI) .And. !Empty(M->QE6_PRODUT)
	dbSelectArea("QE6")
	dbSetOrder(1)
	If dbSeek( xFilial("QE6")+M->QE6_PRODUT+Inverte(M->QE6_REVI))
		Help( " ", 1, "JAGRAVADO" )
		lRetorno := .F.
	Endif
EndIf                       
RestArea(aAreaAnt)
Return(lRetorno)                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010VIni ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 17.12.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o campo Data de Inicio de Vigencia 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_VALID do campo QE6_DTINI e B1_DTINI 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010VIni(cProduto,cRevi,dDtIni)
Local lRetorno := .T.
Local nRecQE6

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a Data Inicio Vigencia da revisao anterior			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Val(cRevi) > 0
	nRecQE6 := QE6->(Recno())
	QE6->(dbSetOrder(1))
	If !QE6->(dbSeek(xFilial("QE6")+cProduto+Inverte(cRevi)))
		QE6->(dbSeek(xFilial("QE6")+cProduto))
		While !QE6->(Eof()) .And. QE6->QE6_FILIAL+QE6->QE6_PRODUT == xFilial("QE6")+cProduto
			If QE6->QE6_REVI < cRevi
				Exit
			EndIf
			dbSkip()
		Enddo
	Else
		QE6->(dbskip())
	EndIf
	If !QE6->(Eof()) .And. QE6->QE6_FILIAL+QE6->QE6_PRODUT == xFilial("QE6")+cProduto
		If QE6->QE6_DTINI >= dDtini
			HELP(" ",1,"A010REVANT",,Dtoc(QE6->QE6_DTINI),2,1) // Rev. anterior e' valida a partir de
			lRetorno := .f.
		EndIf
	EndIf
	QE6->(dbGoto(nRecQE6))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ha' Entrada com data posterior                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno
	QEK->(dbSetOrder(3))
	QEK->(dbSeek(xFilial("QEK")+cProduto))  // Ultima Entrada do Produto
	If dDtIni <= QEK->QEK_DTENTR
		HELP(" ",1,"QPA010ENPO",,Dtoc(QEK->QEK_DTENTR),2,1)   // "J  existe Entrada com data posterior:"
		M->QE6_DTINI := QEK->QEK_DTENTR+1 // Sugere 1 dia depois
	EndIf
	QEK->(dbSetOrder(1))
EndIf
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010GaPr ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 19/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche dados do Produto a partir do SB1                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010GaPr(ExpN1)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 =  Opcao para atualizacao 							  ³±±
±±³			 ³ Onde:    1 - Descricao do Produto						  ³±±
±±³			 ³ 		    2 - Arquivo de Bitmap							  ³±±
±±³			 ³ 		 	3 - Tipo do Produto					   			  ³±±
±±³			 ³ 		 	4 - Unidade de Medida 1                           ³±±
±±³			 ³ 		 	5 - Unidade de Medida 2                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010 - E' cham. atraves gatilho a partir QE6_PRODUT     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A010GaPr(nOpc)
Local cRetorno := ""
Local aAreaAnt := GetArea()
Local aAreaSB1 := SB1->(GetArea())

SB1->(dbSetOrder(1))
If nOpc == 1 // Atualiza Descricao do Produto                    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se O produto nao existir no QE6 busca no SB1				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QE6->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+M->QE6_PRODUT))
		cRetorno := SB1->B1_DESC
	Else
		If !QE6->(dbSeek(xFilial("QE6")+M->QE6_PRODUT))
			cRetorno := M->QE6_DESCPO
		Else
			cRetorno := QE6->QE6_DESCPO
		EndIf
	EndIf
ElseIf nOpc == 2	
	If SB1->(dbSeek(xFilial("SB1")+M->QE6_PRODUT))
		cRetorno := SB1->B1_BITMAP
	Else
		cRetorno := M->QE6_BITMAP
   EndIf
ElseIf nOpc == 3	
	If SB1->(dbSeek(xFilial("SB1")+M->QE6_PRODUT))
		cRetorno := SB1->B1_TIPO
	Else
		cRetorno := M->QE6_TIPO
   EndIf
ElseIf nOpc == 4
	If SB1->(dbSeek(xFilial("SB1")+M->QE6_PRODUT))
		cRetorno := SB1->B1_UM
	Else
		cRetorno := M->QE6_UNMED1
   EndIf
ElseIf nOpc == 5	
	If SB1->(dbSeek(xFilial("SB1")+M->QE6_PRODUT))
		cRetorno := SB1->B1_SEGUM
	Else
		cRetorno := M->QE6_UNMED2
   EndIf                           
ElseIf nOpc == 6	
   cRetorno := QA_UltRevEsp(M->QE6_PRODUT,dDatabase,.F.,.T.,"QIE")
   If empty(cRetorno)
      cRetorno := "00"
   Else
      cRetorno := Soma1(cRetorno)   
 	  While .t.  //Verifica se esta sendo digitado por outro usuario
         If !FreeForUse("QE6",xFilial("QE6")+M->QE6_PRODUT+cRetorno)
            cRetorno := Soma1(cRetorno)    
         Else
            Exit
         EndIf
      EndDo
   EndIf   
EndIf                                                   

RestArea(aAreaSB1)
RestArea(aAreaAnt)

Return(cRetorno)
   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010DeRv ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 19/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche a descricao do Produto a partir da revisao		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010 - E' cham. atraves gatilho a partir QE6_REVI       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010DeRv()
Local cRetorno := M->QE6_DESCPO

QE6->(dbSetOrder(1))
If QE6->(dbseek(xFilial("QE6")+M->QE6_PRODUT+Inverte(M->QE6_REVI)))
	cRetorno := QE6->QE6_DESCPO
EndIf               

Return(cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Qie010VlPr³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 25/03/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Produto 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA010 - E' chamada no X3_VALID do cpo. QE6_PRODUT - SX3  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qie010VlPr()
Local lRetorno := .T.
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010VlEn ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 19/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Ensaio										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010 - E' cham. no X3_VALID do QE7_ENSAIO e QE8_ENSAIO  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010VlEn()
Local lRetorno := .T.
Local nI       := 0
Local cVar     := &(ReadVar()) // Conteudo da variavel do campo Ensaio

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se mudou o Ensaio (Alterou o campo ja' digitado)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aCols[N,nPosEns]) .And. !Empty(cVar) .and. aCols[N,nPosEns] # cVar .And.; 
	!Empty(aCols[N,nPosLab])
	Help(" ",1,"A010ALTCHA")   // Campo nao pode ser alterado
	lRetorno := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Ensaio esta' cadastrado           			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno
	aCols[N,nPosEns] := M->QE7_ENSAIO
	If !ExistCpo("QE1",aCols[N,nPosEns])
		lRetorno := .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Ensaio ja' existe                 			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno
	For nI := 1 To Len(aCols)
		If cVar == acols[nI,nPosEns] .And. nI # N .And. !aCols[nI,nUsado+1]
			Help(" ",1,"A010EXIENS")
			lRetorno := .F.
			Exit
		EndIf
	Next nI
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche a Descricao do Ensaio			        			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno
	aCols[N,nPosDEn] := A010DEns(aCols[N,nPosEns])
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche o Metodo											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno .And. Empty(aCols[N,nPosDoc])
	QE1->(dbSeek(xFilial("QE1")+aCols[N,nPosEns]))
	aCols[N,nPosDoc] := QE1->QE1_METODO
	If nPosAliWT > 0 .AND. QE1->QE1_CARTA == "TXT"
		aCols[N,nPosAliWT] := "QE8"
	Else
		aCols[N,nPosAliWT] := "QE7"
	EndIf
EndIf

//Armazena o codigo do Ensaio Atual
If lRetorno 
	cEnsAtu := cVar 
EndIf	

Return(lRetorno)
                
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010VlUm ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 19/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Unidade de Medida							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010 - E' chamada no X3_VALID do cpo. QE7_UNIMED - SX3  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010VlUm()
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Unidade Medida esta' cadastrada   			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[N,nPosUM] := M->QE7_UNIMED
If ! ExistCpo("SAH",aCols[N,nPosUM])
	lRetorno := .F.
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010VlTI ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 22/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Familia do Instrumento 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010 - E' chamada no X3_VALID do cpo. QE7_TIPO - SX3    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010VlTI()
Local lRetorno := .T.

If GetMv("MV_QINTQMT") == "S" // Se estiver integrado com o SIGAQMT
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Tipo Instrumento esta' cadastrado         	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[N,nPosTip] := M->QE7_TIPO
	If !ExistCpo("QM1",aCols[N,nPosTip])
		lRetorno := .F.
	EndIf
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010VlLa ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 22/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Laboratorio									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010 - E' chamada no X3_VALID do cpo. QE7_LABOR - SX3   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010VlLa()
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Laboratorio  esta' cadastrado         		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[N,nPosLab] := M->QE7_LABOR
If !ExistCpo("SX5","Q2"+aCols[N,nPosLab])
	lRetorno := .F.
EndIf

If lRetorno
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza a Descricao do Laboratorio			  	    		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[N,nPosLab+1] := Tabela("Q2",aCols[N,nPosLab])
	M->QE7_DESLAB := Tabela("Q2",aCols[N,nPosLab])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define a sequencia dos ensaios                 	    		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A010Seq()
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010VlNi ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 12/03/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Nivel (Caracteristica) 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010 - E' chamada no X3_VALID do cpo. QE7_NIVEL - SX3   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010VlNi()
Local lRetorno := .T. 
Local cVar     := &(ReadVar()) // Conteudo da variavel do campo Nivel

If !Empty(cVar)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Caracteristica esta' cadastrada       		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[N,nPosNiv] := M->QE7_NIVEL
	If !ExistCpo("SX5","Q6"+aCols[N,nPosNiv])
		lRetorno := .F.
	EndIf

	If lRetorno
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza a descricao da caracteristica						 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCols[N,nPosDesNiv] := Tabela("Q6",aCols[N,nPosNiv])
		M->QE7_DESNIV       := Tabela("Q6",aCols[N,nPosNiv])
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza a descricao da caractertistica						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[N,nPosDesNiv] := Space(TamSX3("QE7_DESNIV")[1])
	M->QE7_DESNIV       := Space(TamSX3("QE7_DESNIV")[1])
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010VlNo ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 24/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Nominal 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010 - E' chamada no X3_VALID do cpo. QE7_NOMINA - SX3  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010VlNo()
Local lRetorno := .T.
Local cVar     := M->QE7_NOMINA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o valor digitado e' um numero valido    		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Valtype(cVar) == "N"
	cVar := AllTrim(Str(cVar))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o valor digitado e' um numero valido    		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QE1->(dbSeek( xFilial("QE1")+aCols[N,nPosEns]))
If QE1->QE1_CARTA == "TMP"
	If !A010VTempo(@cVar)
		HELP(" ",1,"QA_NUMINV")
		lRetorno := .F.
	EndIf
Else
	If ! QA_VerNum2(@cVar)
		HELP(" ",1,"QA_NUMINV")
		lRetorno := .F.
	EndIf
	aCols[N,nPosNom] := cVar
	M->QE7_NOMINA    := cVar	
EndIf	

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010Seq  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 24/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo SEQLAB - informando a sequencia dos ensaios	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010Seq()
Local nX     := 0
Local cLabor := aCols[N,nPosLab]
Local lRetorno   := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Informa a sequencia dos ensaios                 			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aCols) # 1
	For nX := 1 To Len(aCols)
		If nX # N .And. !aCols[nX,Len(aCols[nX])]
			If cLabor == aCols[nX,nPosLab]
				aCols[n,nPosSeq] := SOMA1(aCols[nX,nPosSeq])
				lRetorno := .F.
			EndIf
			If lRetorno
				aCols[N,nPosSeq] := "01"
			EndIf
		EndIf
	Next nX
Else
	aCols[N,nPosSeq] := "01"
EndIf

Return(lRetorno)
                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010DEns ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 19.12.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a descricao do Ensaio 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010DEns(cCodEns)
QE1->(dbSeek(xFilial("QE1")+cCodEns)) // Ensaio posicionado na getdados
Return(QE1->QE1_DESCPO)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010MePR ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 13/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Indica se o Produto/Revisao possui Entradas cadastradas    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010MePR(ExpC1,ExpC2)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Produto											  ³±±
±±³			 ³ ExpC2 = Revisao											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010MePR(cProduto,cRevi,lLed,lMens)
Local lRetorno := .F.
Local aAreaAnt := GetArea()
Local aAreaQEK := QEK->(GetArea())
Local aFiliais := {}
Local nY       := 0
Local cFilQE6  := xFilial("QE6")

Default lLed	:= .F. 
Default lMens	:= .T.

If !Empty(xFilial("QEK"))
	aFiliais := QA_RetFilEmp(SM0->M0_CODIGO) //Retorna as Filiais associadas a Empresa Atual
Else 
	AADD(aFiliais,{Space(02),Space(02),Space(02),Space(02)})
EndIF                                                     

For nY:=1 to Len(aFiliais)  
    If alltrim(cFilQE6) $ aFiliais[nY,2] .or. Empty(cFilQE6) 
		dbSelectArea("QEK")
		dbSetOrder(3)
		If dbSeek(iif(FWModeAccess("QEK")=="E",aFiliais[nY,2],xFilial("QEK"))+cProduto)
			While (QEK->QEK_FILIAL+QEK->QEK_PRODUT) == (iif(FWModeAccess("QEK")=="E",aFiliais[nY,2],xFilial("QEK"))+cProduto) .And. !Eof()
				If QEK->QEK_REVI == cRevi
					If !lLed
						If lMens
							MessageDlg(OemToAnsi(STR0011)+" "+iif(FWModeAccess("QEK")=="E",aFiliais[nY,2],xFilial("QEK")),,2)	// "Existem Entradas cadastradas."
						Endif
			   	 		lRetorno := .T.
				  	Else
			   	 		lRetorno := .F.
		   	 		Endif 	 			
					Exit
				EndIf                          
			QEK->(dbSkip())
			Enddo
		Endif
		If lRetorno
			Exit
		EndIf	
   	EndIf
Next nY	

RestArea(aAreaQEK)
RestArea(aAreaAnt)         

Return(lRetorno)           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A010MovPAE³ Autor ³ Paulo Emidio de Barros³ Data ³ 05/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Indica se o Produto/Revisao possui entradas com Plano de   ³±±
±±³			 ³ Amostragem por Ensaios associados.						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010MovPAE(EXPL1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPL1 = Indica se o Help sera exibido					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010MovPAE(lHelp) 
Local lRetorno := .F.

lHelp := If(lHelp==NIL,.T.,lHelp)

QF5->(dbSetOrder(4))
QF5->(dbSeek(xFilial("QF5")+M->QE6_PRODUT+M->QE6_REVI+aCols[N,nPosEns]))
If QF5->(!Eof())
	If lHelp
		Help(" ",1,"Q010TEMPAE")
	EndIf	
	lRetorno := .T.	                  
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010Pict ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 10/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a funcao que monta a picture de um campo. 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010Pict(cCampo)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do Campo que tera' a picture a ser definida   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß		ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010Pict(cCampo)
Local cPict := ""
               										  
If (Alltrim(FunName()) <> "LERDA" .AND. Alltrim(FunName()) <> "EDAPP" )//Nao montar picture quando a chamada for da Consulta Generica (LERDA e EDAPP).
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o Tipo do Ensaio									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If At('i',aCols[n,nPosNom] ) == 0
		
		QE1->(dbSeek(xFilial("QE1")+aCols[N,nPosEns])) //Ensaio
		If QE1->QE1_CARTA == "TMP" //Tempo
			cPict := "@R 999:99"
		Else
			cPict := QA_PICT(cCampo,aCols[N,nPosNom])
	    EndIf
	
	Else
		cPict := '@N'+'%C'
	EndIF  
Endif	
Return(cPict)  



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010VlSeq³ Autor ³ Marcelo Pimentel      ³ Data ³ 24/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo SEQLAB - informando a sequencia dos ensaios	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010 - E' chamada no X3_VALID do cpo. QE7_SEQLAB - SX3  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A010VlSeq(cSeq)

lOrdLab:= .T.

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A010F3Nc  ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³11/08/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta consulta de NCs via SXB especifica                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Consulta especifica                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³QIEA010.PRX                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010F3NC()
Local lOkQe2   := .F.
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe NC associada ao ensaio - QE2 			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QE2->(dbSetOrder(1))
If QE2->(dbSeek( xFilial("QE2")+cEnsAtu))
	lOkQe2 := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ De acordo com os dados encontrados dispara uma consulta F3	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lOkQe2
    cEnsaio := cEnsAtu
	lRetorno := ConPad1(,,,"NC2",,,.F.)
Else
	lRetorno := ConPad1(,,,"SAG",,,.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso a consulta F3 tenha sido executada fora do SAG, posi-    ³
//³ ciona no SAG , pois o retorno da consulta ‚ o campo AG_NAOCON ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lOkQe2
	SAG->(dbSetOrder(1))
	SAG->(dbSeek( xFilial("SAG")+QE2->QE2_NAOCON ))
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QE010VlFc ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 14/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Fator de conversao - troca "." por ","        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QE010VlFc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1: Fator 1 ou 2                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEA010 - E' cham. no X3_VALID do QE6_FATCO1 e QE6_FATCO2  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QE010VlFc(nFator)
Local lRetorno := .T.
Local cVar     := &(readvar())		// Fator de Conversao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Fator de Conversao e' um numero valido 		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !QA_VerNum(@cVar)
	HELP(" ",1,"QA_NUMINV")
	lRetorno := .F.
EndIf
If nFator == 1	
	M->QE6_FATCO1 := cVar
Else
	M->QE6_FATCO2 := cVar
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010WhRv ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 25/03/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define a clausula When para a Revisao					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010WhRv()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010WhRv()
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao houver revisao disponivel, sugere "00"                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ReadVar() =="M->QE6_REVI"
	If Empty(M->QE6_REVI)
		M->QE6_REVI := "00"
	EndIf
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010WhVa ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 12/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define a clausula WHEN para campos de Ensaios Mensuraveis. ³±±
±±³			 ³ ( Carta # TXT )											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010WhVa()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010WhVa()
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a Carta do Ensaio								     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ReadVar() $ "M->QE7_UNIMEDßM->QE7_MINMAXßM->QE7_NOMINAßM->QE7_AFIßM->QE7_AFSßM->QE7_LICßM->QE7_LSC"
	QE1->(dbSetOrder(1))
	QE1->(dbSeek( xFilial("QE1")+aCols[N,nPosEns]))  
	If QE1->QE1_CARTA == 'TXT'
		lRetorno := .F.
	EndIf
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010WhLi ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 30/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define a clausula WHEN para campos dos Limites			  ³±±
±±³			 ³ ( LIE, LSE, LIC e LSC ) 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010WhLi()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010WhLi()
Local lRetorno := .T.
Local cVar     := ReadVar()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a Carta do Ensaio					        		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QE1->(dbSetOrder(1))
QE1->(dbSeek( xFilial("QE1")+aCols[N,nPosEns]))  
If QE1->QE1_CARTA == 'TXT'
	lRetorno := .F.
EndIf
If lRetorno
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Valor Nominal foi digitado 	        		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(aCols[N,nPosNom])	// Nominal
		HELP(" ",1,"A010NOMVAZ")
		lRetorno := .F.
	Else
		If cVar == "M->QE7_AFI" 
			If aCols[N,nPosMin] == "3"
				lRetorno := .f.
			EndIf
		ElseIf cVar == "M->QE7_AFS"
			If aCols[N,nPosMin] == "2"
				lRetorno := .f.
			EndIf
		EndIF
	EndIf
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010WhTx ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 12/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define a clausula WHEN para campos de Ensaios Texto.		  ³±±
±±³			 ³ ( Carta = TXT )											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010WhTx()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010WhTx()
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a Carta do Ensaio								  	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ReadVar()  == "M->QE8_TEXTO"
	QE1->(dbSetOrder(1))
	QE1->(dbSeek( xFilial("QE1") + aCols[n][nPosEns]))   
	If QE1->QE1_CARTA <> 'TXT'
		lRetorno := .F.
	EndIf
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010WhIn ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 13/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define a clausula WHEN para a Data Inicio Vigencia.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010WhIn()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010WhIn(lVerEnt)
Local lRetorno := .T.
Local lTemEnt  := .F.

If ReadVar() == "M->QE6_DTINI"
	If !Inclui .And. lVerEnt
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a Carta do Ensaio								  	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lTemEnt := A010MePR(M->QE6_PRODUT+M->QE6_REVI)

		If lTemEnt
			lRetorno := .F. // Nao permite alteracao na data inicio vigencia se tiver Entrada
		EndIf
	EndIf
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QE010WU1 ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 13/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define a clausula WHEN para Unidade Medida 1               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QE010WU1()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010 - X3_WHEN do QE6_UNMED1							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QE010WU1()
Local lRetorno := .T.
Local lTemMed  := .F.

If ReadVar() == "M->QE6_UNMED1"                                     
	If !Inclui
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Produto possui medicoes cadastradas			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lTemMed := A010MePR(M->QE6_PRODUT,M->QE6_REVI)
		If lTemMed
			lRetorno := .F. 
		EndIf
    EndIf
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QE010WU2 ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 13/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define a clausula WHEN para Unidade de Medida 2            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QE010WU2()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010 - X3_WHEN do QE6_UNMED2                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QE010WU2()
Local lRetorno := .T. 
Local lTemMed  := .F.

If ReadVar() == "M->QE6_UNMED2"
	If !Inclui
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Produto possui medicoes cadastradas			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lTemMed := A010MePR(M->QE6_PRODUT,M->QE6_REVI)
		If lTemMed
			lRetorno := .F. 
		EndIf
    EndIf
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QE010WU3 ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 13/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define a clausula WHEN para Unidade de Amostragem 1        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QE010WU3()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010 - X3_WHEN do QE6_UNAMO1                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QE010WU3()
Local lRetorno := .T.
Local lTemMed  := .F.

If ReadVar() == "M->QE6_UNAMO1"
	If !Inclui
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Produto possui medicoes cadastradas			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lTemMed := A010MePR(M->QE6_PRODUT,M->QE6_REVI)
		If lTemMed
			lRetorno := .F. 
		EndIf
    EndIf
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QE010WU4 ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 13/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define a clausula WHEN para Unidade de Amostragem 2        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QE010WU4()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010 - X3_WHEN do QE6_UNAMO2                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QE010WU4()
Local lRetorno := .T.
Local lTemMed  := .F.
If ReadVar() == "M->QE6_UNAMO2"
	If !Inclui
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Produto possui medicoes cadastradas			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lTemMed := A010MePR(M->QE6_PRODUT,M->QE6_REVI)
		If lTemMed
			lRetorno := .F. 
		EndIf
    EndIf
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010WFC1 ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 13/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Def. a clausula WHEN p/ Fator Conversao (UM1 - Un.Amostr 1)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010WFC1()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010WFC1()
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se as Unidades de Medida e Amostragem sao iguais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->QE6_UNMED1 == M->QE6_UNAMO1
	lRetorno := .F.
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010WFC2 ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 13/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Def. a clausula WHEN p/ Fator Conversao (UM2 - Un.Amostr 2)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010WFC2()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010WFC2()
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se as Unidades de Medida e Amostragem sao iguais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->QE6_UNMED2 == M->QE6_UNAMO2
	lRetorno := .F.
EndIf
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A010WhFQe    ³ Autor ³ Eduardo de Souza   ³ Data ³ 18/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a chamada da fun‡Æo do Cadastro de F¢rmulas.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaQie                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010WhFQe()
Local aEnsaio  := {}
Local nC 	   := 0 
Local cCartEns := QA_CartEns(aCols[N,nPosEns])

If !Empty(aCols[N,nPosEns]) .And. !aCols[N,nUsado+1] .And. !Empty(aCols[N,nPosLab])
	If	QE1->(dbSeek(xFilial("QE1")+aCols[N,nPosEns]))
		If QE1->QE1_TIPO # "2" .And. cCartEns $ "XBR/XBS/XMR/IND/HIS"
			For nC := 1 To Len(aCols)
				If nC # N
					If !aCols[nC,Len(aHeader)+1]
						If QE1->(dbSeek(xFilial("QE1")+aCols[nC,nPosEns]))
							cCartEns := QA_CartEns(aCols[nC,nPosEns])
							If cCartEns $ "XBR/XBS/XMR/IND/HIS" .And. aCols[N,nPosLab] == aCols[nC,nPosLab]
								Aadd(aEnsaio,QE1->QE1_ENSAIO)
							EndIf
						EndIf
					EndIf
				EndIf
			Next nC
			If Len(aEnsaio) > 0 
				aCols[N,nPosFor] := QAFORMULA(aEnsaio,aCols[N,nPosFor])
			EndIf
		EndIf
	EndIf
EndIf
Return(.F.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010VlNC ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 19/03/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Nao Conformidade 						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA210 - E' cham. no X3_VALID do QE9_NAOCON               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010VlNC()
Local lRetorno := .T.
Local cVar     := &(readvar()) 
Local nI       := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se mudou a NC (Alterou o campo ja' digitado)   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aCols[N,nPosNC]) .And. !Empty(cVar) .And. (aCols[N,nPosNC] # cVar)
	Help(" ",1,"A010ALTCHA")   //O campo nao pode ser alterado
	lRetorno := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a NC ja' existe                     		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno
	For nI := 1 to Len(aCols)
		If !aCols[nI,nUsado+1]
			If cVar == aCols[nI,nPosNC] .And. nI <> N // Se ja' existir este cod. NC
				Help(" ",1,"A020EXINCE")
				lRetorno := .F.
			EndIf
		EndIf
	Next nI
EndIf

If lRetorno
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a NC esta' cadastrada no SAG        		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! ExistCpo("SAG",cVar)
		aCols[N,nPosNC] := Space(TamSX3("QE9_NAOCON")[1])
		lRetorno := .F.
	EndIf
EndIf

If lRetorno
	QE2->(dbSetOrder(1))
	If QE2->(dbSeek(xFilial("QE2")+cEnsAtu))
		If !QE2->(dbSeek(xFilial("QE2")+cEnsAtu+cVar))
			Help(" ",1,"A210NCOENS")   // "NC nao associada ao Ensaio"
			lRetorno := .F.
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Sugere a Classe da NC		  				    		³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCols[N,nPosCla] := QE2->QE2_CLASSE
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sugere a Classe da NC		  				    		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno .And. Empty(aCols[N,nPosCla])
	SAG->(dbSetOrder(1))
	SAG->(dbSeek(xFilial("SAG")+cVar))
	aCols[N,nPosCla] := SAG->AG_CLASSE
EndIf                            

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche a Descricao da NC					    		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno
	aCols[N,nPosDNC] := A020DNCo(cVar)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche a Descricao da Classe				    		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno
	aCols[N,nPosDCl] := A040DCla(aCols[N,nPosCla])
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Q010DelEsp³ Autor ³Paulo Emidio de Barros ³ Data ³03/12/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a exclusao da especificacao do Produto e suas amar-³±±
±±³			 ³ racoes.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q010DelEsp(EXPC1,EXPC2)								  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Opcao do aRotina									  ³±±
±±³			 ³ EXPC1 = Codigo do Produto  								  ³±±
±±³			 ³ EXPC2 = Revisao do Produto								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q010DelEsp(nOpc,cCodigo,cRevi)
Local cChave    
Local cEspecie := "QIEA010 " 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada utilizado pela JNJ						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QE010J2")
	ExecBlock("QE010J2",.F.,.F.,{nOpc,cCodigo,cRevi}) 
EndIf

Begin Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclue os ensaios mensuraveis do produto				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QE7")
dbSetOrder(1)
dbSeek(xFilial("QE7")+cCodigo+cRevi)
While !Eof() .And. (QE7_FILIAL+QE7_PRODUT+QE7_REVI)==xFilial("QE7")+cCodigo+cRevi
	RecLock("QE7",.F.,.T.)
	dbDelete()
	MsUnLock()
	dbSkip()
EndDo
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclue os ensaios texto do produto						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QE8")
dbSetOrder(1)
dbSeek( xFilial("QE8")+cCodigo+cRevi)
While !Eof() .And. (QE8_FILIAL+QE8_PRODUT+QE8_REVI)==xFilial("QE8")+cCodigo+cRevi
	RecLock("QE8",.F.,.T.)
	dbDelete()
	MsUnLock()
	dbSkip()
EndDo
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclue as nao-conformidades associadas aos ensaios  	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QE9")
dbSetOrder(1)
dbSeek(xFilial("QE9")+cCodigo+cRevi)
While !Eof() .And. (QE9_FILIAL+QE9_PRODUT+QE9_REVI)==xFilial("QE9")+cCodigo+cRevi
	RecLock("QE9",.F.,.T.)
	dbDelete()
	MsUnLock()
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a exclusao da especificacao do produto			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QE6")
RecLock("QE6",.F.,.T.)
cChave := QE6->QE6_CHAVE
dbDelete()
MsUnLock()
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclue o texto do produto no QA2					 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QA_DelTxt(cChave,cEspecie)   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao haja outras revisoes, exclue as amarracoes  	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QE6->(dbSetOrder(1))
If QE6->(!dbSeek(xFilial("QE6")+cCodigo))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclue os informativos dos Produtos						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QEB")
	dbSetOrder(1)
	If dbSeek( xFilial("QEB")+cCodigo)
		RecLock("QEB",.F.,.T.)
		dbDelete()
		MsUnLock()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclue os topicos dos Informativos do Produto			³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QEC")
		dbSetOrder(1)
		dbSeek(xFilial("QEC")+cCodigo)
		While !Eof() .And. QEC_FILIAL+QEC_PRODUT == xFilial("QEC")+cCodigo
			RecLock("QEC",.F.,.T.)
			dbDelete()
			MsUnLock()

			If !Empty(QEC->QEC_CHAVE)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exclue os textos dos topicos							³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QA_DelTxt(QEC->QEC_CHAVE,"QIEA080 ") 
				dbSelectArea("QEC")
				
			EndIf
			dbSkip()
		Enddo
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclue a Amarracao Grupo x Produto 						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QEA->(dbSetOrder(2))
	QEA->(dbSeek(xFilial("QEA")+cCodigo))
	While QEA->(!Eof()) .And. (QEA->QEA_FILIAL+QEA->QEA_PRODUT) == (xFilial("QEA")+cCodigo)
		RecLock("QEA", .F.)
		QEA->(dbDelete())
		MsUnLock()
		QEA->(dbSkip())
	EndDo        
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclue os Indices da Qualidade do produto				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QEV")
	dbSetOrder(4)
	dbSeek(xFilial()+cCodigo)
	While !Eof() .And. (QEV_FILIAL+QEV_PRODUT) == (xFilial()+cCodigo)
		RecLock("QEV",.F.,.T.)
		dbDelete()
		MsUnLock()
		dbSkip()
	EndDo                       
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclue as ocorrencias do Laudo							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QEW")
	dbSetOrder(3)
	dbSeek( xFilial()+cCodigo)
	While !Eof() .And. (QEW_FILIAL+QEW_PRODUT) == (xFilial()+cCodigo)
		RecLock("QEW",.F.,.T.)
		dbDelete()
		MsUnLock()
		dbSkip()
	Enddo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclue os indices mensais referentes Produto x Fornecedor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QE0")
	dbSetOrder(3)
	dbSeek( xFilial()+cCodigo)
	While !Eof() .And. (QE0_FILIAL+QE0_PRODUT) == (xFilial()+cCodigo)
		RecLock("QE0",.F.,.t.)
		dbDelete()
		MsUnLock()
		dbSkip()
	Enddo

EndIf

End Transaction 

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Q010GrvEsp³ Autor ³Paulo Emidio de Barros ³ Data ³03/12/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a atualizacao das especificacoes dos Produtos e    ³±±
±±³			 ³ amarracoes.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q010GrvEsp(EXPN1)									  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q010GrvEsp(nOpc,lAuto,aENS,aNCO,cTXT)
Local cRastro    := ""                                         
Local nLinEns    := 0
Local nPosDelEns := 0                     
Local nPosDelNco := 0
Local nPosCpo 	 := 0
Local nDec    	 := 0
Local nLie    	 := 0
Local nLse    	 := 0    
Local lAtuEns
Local lAtuNco
Local cEspecie   := "QIEA010 "   
Local aTexto     := {}
Local aAreaQE6 
Local nLinNco
Local cVlrLIE    := ""
Local cVlrLSE    := ""     
Local aArea		 := {}
Local Nx
Local aStruct

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ponto de entrada acionado antes da gravacao das tabelas ³
//³ referentes a especificacao do produto.					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QE010ANT") 
	ExecBlock("QE010ANT",.F.,.F.)
EndIf

If !lAuto
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o SB1, caso nao exista o produto				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SB1->(dbSetOrder(1))
	If SB1->(!dbSeek(xFilial("SB1")+M->QE6_PRODUT))
		cRastro := If(GetMv("MV_RASTRO")=="S",GetMv("MV_QRASTRO"),"")
		
		RecLock("SB1",.T.)
		SB1->B1_FILIAL := xFilial("SB1")
		SB1->B1_COD    := M->QE6_PRODUT
		SB1->B1_TIPO   := M->QE6_TIPO
		SB1->B1_DESC   := Left(M->QE6_DESCPO,TamSX3("B1_DESC")[1])
		SB1->B1_UM     := M->QE6_UNMED1
		SB1->B1_LOCPAD := "01"
		SB1->B1_TIPOCQ := "Q"
		SB1->B1_DATREF := dDataBase
		SB1->B1_UREV   := dDataBase
		SB1->B1_RASTRO := cRastro
		SB1->B1_MRP    := "S"
		MsUnlock()
		
		If !RetArqProd(M->QE6_PRODUT)
			aArea := GetArea()
			RecLock("SBZ",.T.)
			SBZ->BZ_FILIAL := xFilial("SBZ")
			SBZ->BZ_COD    := M->QE6_PRODUT
			SBZ->BZ_LOCPAD := "01" 			
			SBZ->BZ_DATREF := dDataBase
			SBZ->BZ_TIPOCQ := "Q"
			SBZ->BZ_MRP    := "S"
			MsUnlock()
			RestArea(aArea)
		Endif
		
	Else
		//Verifica se a Unidade de medida foi alterada
		If SB1->B1_UM # M->QE6_UNMED1 .And. M->QE6_DTINI <= dDataBase
			RecLock("SB1",.F.)
			SB1->B1_UM := M->QE6_UNMED1
			MsUnLock()
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera a chave de ligacao									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  Empty(QE6->QE6_CHAVE)
		aAreaQE6 := QE6->(GetArea())
		cChave := QA_NewChave(,"QE6",2)
		RestArea(aAreaQE6)
	Else
		cChave := QE6->QE6_CHAVE
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava a especificacao do Produto						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QE6")
	RecLock("QE6",If(nOpc==3,.T.,.F.))

	aStruct := FWFormStruct(3,"QE6")[3] // Busca os campos usados (X3_USADO) da tabela
	For nX := 1 to Len(aStruct)
		If GetSx3Cache(aStruct[nX,1],"X3_CONTEXT") # "V"
			FieldPut(FieldPos(AllTrim(aStruct[nX,1])),&("M->"+aStruct[nX,1]))
		EndIf
	Next nX
	
	If (nOpc == 3 .OR. nOpc == 4)
		QE6->QE6_FILIAL := xFilial("QE6")
		QE6->QE6_REVINV := Inverte(QE6_REVI)
		QE6->QE6_DTCAD  := dDataBase
	EndIf

	If (nOpc == 3 .OR. nOpc == 4)
		If QE6_DTINI > dDataBase
			QE6->QE6_SITREV := "2"
		Else	
			QE6->QE6_SITREV := "0"
		Endif	
    Endif

	QE6->QE6_CHAVE := cChave
	MsUnLock()
	
Else
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza Arrays de Ensaio, Nao Conf. e cTexto			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsEns := aENS
	aColsNco := aNCO
	cTexto   := cTXT
	
EndIF
                        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada utilizado pela JNJ						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QE010J2") 
	ExecBlock("QE010J2",.F.,.F.,{nOpc,QE6->QE6_PRODUT,QE6->QE6_REVI})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava os ensaios referentes a especificacao do Produto	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin Transaction 

For nLinEns := 1 to Len(aColsEns)

    nPosDelEns := Len(aColsEns[nLinEns])
	lAtuEns    := .F.
	cVlrLIE    := ""
	cVlrLSE    := ""  
	nLie       := 0
	nLse       := 0
	                  	               
	QE1->(dbSetOrder(1))
	QE1->(dbseek(xFilial("QE1")+aColsEns[nLinEns,nPosEns]))
	If QE1->QE1_CARTA # "TXT"
		    
		dbSelectArea("QE7")
		dbSetOrder(1)
		If dbSeek(xFilial("QE7")+QE6->QE6_PRODUT+QE6->QE6_REVI+aColsEns[nLinEns,nPosEns])
			If aColsEns[nLinEns,nPosDelEns]
			    RecLock("QE7",.F.)
			    dbDelete()
			    MsUnLock()                                  
		    Else          
		    	RecLock("QE7",.F.)
		    	lAtuEns := .T.
		    EndIf
		Else 
		    If !aColsEns[nLinEns,nPosDelEns]
			   	RecLock("QE7",.T.)
				QE7->QE7_FILIAL := xFilial("QE7")
				QE7->QE7_PRODUT := QE6->QE6_PRODUT
				QE7->QE7_REVI   := QE6->QE6_REVI
			    lAtuEns := .T.
			EndIf   
		EndIf           

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza os campos referentes aos Ensaios				³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAtuEns
			For nPosCpo := 1 to Len(aHeadEns)
				If aHeadEns[nPosCpo,10] # "V"
					If AllTrim(aHeadEns[nPosCpo,2]) # "QE8_TEXTO"
					  
					  	FieldPut(FieldPos(AllTrim(aHeadEns[nPosCpo,2])),; 
							aColsEns[nLinEns,nPosCpo])
					EndIf
				EndIf
			Next nPosCpo
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula e grava os LIE e LSE							³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If At(":",AllTrim(QE7->QE7_NOMINA)) > 0 //Calculo do Tipo: TEMPO
				//Controla Minimo e Maximo ou somente Minimo
				If QE7_MINMAX $ "1.2" 
					cVlrLIE := CalcHora(aColsEns[nLinEns,nPosNom],aColsEns[nLinEns,nPosAFI],"I")
				EndIf
				//Controla Minimo e Maximo ou somente Maximo
				If QE7_MINMAX $ "1.3" 
					cVlrLSE := CalcHora(aColsEns[nLinEns,nPosNom],aColsEns[nLinEns,nPosAFS],"S")
				EndIF
			ElseIf At('i',AllTrim(QE7->QE7_NOMINA)) > 0 //Calculo em Polegadas
				//Controla Minimo e Maximo ou somente Minimo
				If QE7_MINMAX $ "1.2" 
			    	cVlrLIE := qCalPol({aColsEns[nLinEns,nPosNom],aColsEns[nLinEns,nPosAFI]},1,QE7->QE7_LIE)
				EndIf
				//Controla Minimo e Maximo ou somente Maximo
				If QE7_MINMAX $ "1.3" 
	    	    	cVlrLSE := qCalPol({aColsEns[nLinEns,nPosNom],aColsEns[nLinEns,nPosAFS]},1,QE7->QE7_LSE)	
	        	EndIf
			Else                                                                           
				//Controla Minimo e Maximo ou somente Minimo
				If QE7_MINMAX $ "1.2" 
					nLie    := SuperVal(aColsEns[nLinEns,nPosNom])+SuperVal(aColsEns[nLinEns,nPosAFI])
				EndIf
				//Controla Minimo e Maximo ou somente Maximo
				If QE7_MINMAX $ "1.3" 
					nLse    := SuperVal(aColsEns[nLinEns,nPosNom])+SuperVal(aColsEns[nLinEns,nPosAFS])
				EndIF
				
				If cPaisLoc <> "MEX"
					nDec    := If(","$AllTrim(QE7_NOMINA),Len(AllTrim(QE7_NOMINA))-At(",",AllTrim(QE7_NOMINA)),0)
		         	cVlrLIE := StrTran(Str(nLie,TamSX3("QE7_LIE")[1],nDec),".",",")
	    	    	cVlrLSE := StrTran(Str(nLse,TamSX3("QE7_LSE")[1],nDec),".",",")
	        	Else
					nDec    := If("."$AllTrim(QE7_NOMINA),Len(AllTrim(QE7_NOMINA))-At(".",AllTrim(QE7_NOMINA)),0)
		         	cVlrLIE := StrTran(Str(nLie,TamSX3("QE7_LIE")[1],nDec),",",".")
	    	    	cVlrLSE := StrTran(Str(nLse,TamSX3("QE7_LSE")[1],nDec),",",".")
	        	Endif	
			EndIf
       
			RecLock("QE7",.F.)
			QE7->QE7_LIE := cVlrLIE
			QE7->QE7_LSE := cVlrLSE
			MsUnLock()

		EndIf
	Else     
	        
		dbSelectArea("QE8")
		dbSetOrder(1)
		If dbSeek(xFilial("QE8")+QE6->QE6_PRODUT+QE6->QE6_REVI+aColsEns[nLinEns,nPosEns])
			If aColsEns[nLinEns,nPosDelEns]
			    RecLock("QE8",.F.)
			    dbDelete()
			    MsUnLock()
		    Else          
		    	RecLock("QE8",.F.)
		    	lAtuEns := .T.
		    EndIf
		Else 
			If !aColsEns[nLinEns,nPosDelEns]
			   	RecLock("QE8",.T.) 
			    QE8->QE8_FILIAL := xFilial("QE8")
				QE8->QE8_PRODUT := QE6->QE6_PRODUT
				QE8->QE8_REVI   := QE6->QE6_REVI
			    lAtuEns := .T.
		    EndIf
		EndIf
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza os campos referentes aos Ensaios				³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAtuEns
			For nPosCpo := 1 to Len(aHeadEns)
				If aHeadEns[nPosCpo,10] # "V"
					If !(AllTrim(aHeadEns[nPosCpo,2]) $ "QE7_UNIMEDßQE7_NOMINAßQE7_AFIßQE7_AFSßQE7_LICßQE7_LSCßQE7_MINMAXßQE7_FORMUL")
						FieldPut(FieldPos(AllTrim("QE8"+SubStr(aHeadEns[nPosCpo,2],4,7))),;
							aColsEns[nLinEns,nPosCpo])
					EndIf
				EndIf
			Next nPosCpo
			MsUnLock()
			
		EndIf
		
	EndIf               
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza as nao-conformidades							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QE9")
	dbSetOrder(1)
	For nLinNco := 1 to Len(aColsNco[nLinEns])
		
		nPosDelNco := Len(aColsNco[nLinEns,nLinNco])
		lAtuNco    := .F.
		
		If !Empty(aColsNco[nLinEns,nLinNco,nPosNC])		
			dbSeek(xFilial("QE9")+QE6->QE6_PRODUT+QE6->QE6_REVI+;
				aColsEns[nLinEns,nPosEns]+aColsNco[nLinEns,nLinNco,nPosNC])
			If !Eof()			
			
			    //Se a linha do Ensaio estiver excluida, as nao-conformidades associadas
			    //tambem serao excluidas
				If aColsEns[nLinEns,nPosDelEns]		                                            
					RecLock("QE9",.F.)
					dbDelete()
					MsUnLock()
			    EndIf
			
				//Verifica se a linha da nao-conformidade sera excluida                                             
				If aColsNco[nLinEns,nLinNco,nPosDelNco]
					RecLock("QE9",.F.)
					dbDelete()
					MsUnLock()
				Else
					RecLock("QE9",.F.)
					lAtuNco := .T.
				EndIf
				
		    Else
   				//Verifica se a linha da nao-conformidade esta marcada para exclusao
				If !aColsNco[nLinEns,nLinNco,nPosDelNco]
			    	RecLock("QE9",.T.)
			    	QE9->QE9_FILIAL := xFilial("QE9")
			    	QE9->QE9_PRODUT := QE6->QE6_PRODUT
			    	QE9->QE9_REVI   := QE6->QE6_REVI
			    	QE9->QE9_ENSAIO := aColsEns[nLinEns,nPosEns]
			    	lAtuNco := .T.
		    	EndIf
		    EndIf
	    EndIf
	                     
	    If lAtuNco
			For nPosCpo := 1 to Len(aHeadNco)
				If aHeadNco[nPosCpo,10] # "V"
					FieldPut(FieldPos(AllTrim(aHeadNco[nPosCpo,2])),;
						aColsNco[nLinEns,nLinNco,nPosCpo])
				EndIf
			Next nPosCpo
			MsUnLock()
	    EndIf

	Next nLinNco	

Next nLinEns

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o texto da Especificacao do Produto				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aTexto,{1,cTexto})                 
QA_GrvTxt(QE6->QE6_CHAVE,cEspecie,1,aTexto)    

End Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada utilizado pela JNJ						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QE010J1") 
	ExecBlock("QE010J1",.F.,.F.,{nOpc,QE6->QE6_PRODUT,QE6->QE6_REVI})
EndIf

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Q010DelNco³ Autor ³Paulo Emidio de Barros ³ Data ³03/12/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclue as nao-conformidades associadas ao ensaio, quando o ³±±
±±³			 ³ mesmo for marcado para exclusao.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q010DelNco(lDelEns)									  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPL1 = Marca/Desmarca as nao-conformidades associadas aos ³±±
±±³			 ³ 		   ensaios para exclusao.						   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL2 = .T.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q010DelNco(lDelEns)
Local nX
Default lDelEns := aCols[oGetEns:oBrowse:nAt,Len(aCols[oGetEns:oBrowse:nAt])]
                                  `
For nX := 1 to Len(aColsNco[nEnsAtu])
	aColsNco[nEnsAtu,nX,Len(aColsNco[nEnsAtu,nX])] := lDelEns
Next nX
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Q010AtuNco³ Autor ³Paulo Emidio de Barros ³ Data ³14/10/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza o aCols das Nao-conformidades associadas aos En-  ³±±
±±³			 ³ saios.					   								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q010AtuNco()											  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q010AtuNco()
Local nPosNco 

//Atualiza o aCols dos Ensaios
If Len(aCols) > Len(aColsEns)
	aColsEns := aClone(aCols)              
EndIf

For nPosNco := 1 to Len(aCols)	             
	//Atualiza o aCols das Nao-conformidades 
	If Len(aCols) > Len(aColsNco)	
		Q010FilNco(M->QE6_PRODUTO,M->QE6_REVI,)
	EndIf	
Next nPosNco

Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Q010VlAFI ³ Autor ³ Eduardo de Souza      ³ Data ³ 21/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Afastamento Inferior                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q010VlAFI()											  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q010VlAFI()

Local lRet:= .T.

If aCols[N,nPosMin] == "1" .And. !Empty(aCols[n,nPosAFS])
	If SuperVal(M->QE7_AFI) > SuperVal(aCols[n,nPosAFS])
		HELP(" ",1,"A010AFSINV") 
		lRet:= .F.
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Q010VlAFS ³ Autor ³ Eduardo de Souza      ³ Data ³ 21/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Afastamento Superior                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q010VlAFS()											  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q010VlAFS()

Local lRet:= .T.

If aCols[N,nPosMin] == "1" .And. !Empty(aCols[n,nPosAFI])
	If SuperVal(M->QE7_AFS) < SuperVal(aCols[n,nPosAFI])
		HELP(" ",1,"A010AFSINV") 
		lRet:= .F.
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Q010VlLIC ³ Autor ³ Eduardo de Souza      ³ Data ³ 21/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Limite Inferior de Controle                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q010VlLIC()											  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q010VlLIC()

Local lRet:= .T.

If aCols[N,nPosMin] == "1" .And. !Empty(aCols[n,nPosLSC])
	If SuperVal(M->QE7_LIC) > SuperVal(aCols[n,nPosLSC])
		HELP(" ",1,"A010LSCINV")
		lRet:= .F.
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Q010VlLSC ³ Autor ³ Eduardo de Souza      ³ Data ³ 21/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Limite Superior de Controle                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q010VlLSC()											  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q010VlLSC()

Local lRet:= .T.

If aCols[N,nPosMin] == "1" .And. !Empty(aCols[n,nPosLIC])
	If SuperVal(M->QE7_LSC) < SuperVal(aCols[n,nPosLIC])
		HELP(" ",1,"A010LSCINV")
		lRet:= .F.
	EndIf
EndIf

Return lRet 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QE010OrdLab³ Autor ³Eduardo de Souza      ³ Data ³ 28/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reordena o array de ensaios por sequencia de laboratorio   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QE010OrdLab()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEA010.PRW												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QE010OrdLab()
Local nPos01  := 0
Local nPos02  := 0
Local nCnt    := 0
Local cNxtPos := 0
Local nNewPos := 1

If lOrdLab

	If Len(Acols) > 1

		nPos01  := Ascan(aCols,{|x|x[nPosLab]+X[nPosSeq] == aCols[n,nPosLab]+aCols[n,nPosSeq]})
		cNxtPos := aCols[n,nPosLab]+aCols[n,nPosSeq]
		cSeq    := aCols[nPos01,nPosSeq]

		nPos02:= Ascan(aCols,{|x|x[nPosLab] == aCols[n,nPosLab]})
		
		If aCols[nPos01,nPosLab]+aCols[nPos01,nPosSeq] < aCols[nPos02,nPosLab]+aCols[nPos02,nPosSeq]
			nPos01:= nPos02
		EndIf

		For nCnt:= nPos01 To Len(aCols)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando o Laboratorio for diferente do atual encerra o ordem. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aCols[nCnt,nPosLab] <> aCols[n,nPosLab]
				Exit
			EndIf

			If !aCols[nCnt,Len(aHeader)+1]
		        If nCnt <> N
					aCols[nCnt,nPosSeq]:= Soma1(cSeq)
					cSeq:= aCols[nCnt,nPosSeq]
				EndIf								
			EndIf
		Next nCnt			
		aCols   := aSort(aCols,,, { | x,y | x[nPosLab]+x[nPosSeq] < y[nPosLab]+y[nPosSeq] })		
		nNewPos := Ascan(aCols,{|x|x[nPosLab]+X[nPosSeq] == cNxtPos})

	EndIf
	lOrdLab:= .F.
Else
	nNewPos := N
EndIf

Return(nNewPos)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q010LegOp ³ Autor ³Cleber L. Souza 		³ Data ³10/05/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define as Legendas utilizadas nas OPs				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q010Legend()										    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q010LegOp() 
Local aLegenda := {}

Aadd(aLegenda,{"BR_VERDE",   OemToAnsi(STR0034 )}) //"Revisão Disponivel"  
Aadd(aLegenda,{"BR_VERMELHO",OemToAnsi(STR0035)}) //"Revisão Bloqueada"  
Aadd(aLegenda,{"BR_AMARELO", OemToAnsi(STR0036)}) //"Revisão Pendente" 

BrwLegenda(cCadastro,OemToAnsi(STR0037),aLegenda) //"Status das Especificações"
Return(NIL)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                  
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q010BLOQ ³ Autor ³Cleber L. Souza 		³ Data ³10/05/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina que bloqueia a especificação evitando o uso.	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q010BLOQ()	    										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q010BLOQ()
           
Local cMsg
Local nRecQE6   := 0  
Local aArea     := QE6->(GetArea()) 
Local lLib      := .T.
Local cProduto 

If QE6->QE6_SITREV == "1"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Vericica se existem especificação vigente.					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRecQE6   := QE6->(Recno())	
	cProduto  := QE6->QE6_PRODUT
	cRev      := QE6->QE6_REVI
	 
    dbSelectArea("QE6")
    dbSetOrder(1)
    If dbSeek(xFilial("QE6")+cProduto+INVERTE(SOMA1(cRev)))
       IF QE6->QE6_DTINI <= dDataBase
       		lLib := .F.
       EndIF
    EndIF
	
	If lLib

		QE6->(dbGoTo(nRecQE6))
 		cMsg := STR0040+CHR(13)+CHR(10) //"Esta sendo realizado a Liberação da Especificação do Produto : "
		cMsg += STR0029 + QE6->QE6_PRODUT+CHR(13)+CHR(10) //"Produto : "
		cMsg += STR0030 + QE6->QE6_REVI+CHR(13)+CHR(10) //"Revisao : "
		cMsg += STR0031 + QE6->QE6_DESCPO+CHR(13)+CHR(10) //"Descrição : "
		cMsg += STR0041 //"Deseja confirmar a liberação dessa especificação ?"
	                     
		If MsgYesNo(OemToAnsi(cMsg),OemToAnsi(STR0033)) //"Atencao"	          
			dbSelectArea("QE6")
			RecLock("QE6",.f.)
			If QE6->QE6_DTINI > dDataBase 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se existem entradas cadastradas                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QE6->QE6_SITREV := "2"   //bLOQUEADO
			Else
				QE6->QE6_SITREV := "0"
			Endif                          
			MsUnlock()	
		EndIF 
	Else   
		QE6->(dbGoTo(nRecQE6))
		MsgAlert(STR0045,STR0046)//"A especificacao nao podera ser desbloqueada, pois existe especificacao com revisao superior em vigencia"##"Atencao"
    EndIF
Else
	cMsg := STR0028+CHR(13)+CHR(10) //"Esta sendo realizado o Bloqueio da Especificacäo do Produto : "  
	cMsg += STR0029 + QE6->QE6_PRODUT+CHR(13)+CHR(10) //"Produto : "
	cMsg += STR0030 + QE6->QE6_REVI+CHR(13)+CHR(10) //"Revisao : "
	cMsg += STR0031 + QE6->QE6_DESCPO+CHR(13)+CHR(10) //"Descrição : "
	cMsg += STR0032 //"Deseja confirmar o bloqueio dessa especificacäo ?" 
	
	If MsgYesNo(OemToAnsi(cMsg),OemToAnsi(STR0033)) //"Atencao"
		dbSelectArea("QE6")
		RecLock("QE6",.f.)
		QE6->QE6_SITREV := "1"
		MsUnlock()
	EndIf 
EndIF
If ExistBlock("Q010BGRV") 
	ExecBlock("Q010BGRV",.F.,.F.,{QE6->QE6_SITREV})
EndIf	         

RestArea(aArea)
	
Return(NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QIE010Led ºAutor  ³Leandro Sabino      º Data ³ 27/04/2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consistencia no Led do MBrowse da rotina de Especificacão deº±±
±±º          ³Produtos                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QIE010Led()                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIE010Led()
Local lTemEnt  := .F.

dbSelectArea("QE6")
dbSetOrder(1)

While !Eof()
	If QE6->QE6_SITREV <> '1'//Revisão Bloqueada	
		If QE6->QE6_DTINI <= dDataBase 
			If QE6->QE6_SITREV <> '0'      
				RecLock("QE6",.F.)
				QE6->QE6_SITREV := '0' //Revisao disponivel
				MsUnlock()
	 		EndIf 
	 	Else	  	
 	 		lTemEnt := A010MePR(QE6->QE6_PRODUT,QE6->QE6_REVI,.T.)
			If !lTemEnt 
	 	   		If QE6->QE6_SITREV <> '2' 
	 	   			RecLock("QE6",.F.)
					QE6->QE6_SITREV := '2'//Revisão Pendente
					MsUnlock()
     			EndIf
	 	   Endif
	 	Endif
	Endif
	dbSkip()
Enddo

Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QE010ValCalc   ºAutor  ³Iolanda Vilanova Data ³  01/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QE010ValCalc                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QE010ValCalc(lRetorno,cForAux,lTipo,nPosEns,cCarta,nQtdEns,lMsg)    
Local aEnsCal   := {}
Local cEnsAux	:= " "
Local cFormula	:= " " 
Local nCont1	:= 0
Local nCont2	:= 0
Local nCont3	:= 0
Local nCont4    := 0
Local nPar1		:= 0
Local nPar2		:= 0
Local nPosForm	:= 0 
Local nTamForm	:= TamSx3("QE7_FORMUL")[1]		// Tamanho do campo formula
Local nW		:= 0
Local nY		:= 0

Default cForAux  := " " 
Default lMsg     := .T.
Default lRetorno := .T.
Default lTipo	 := .T.
Default nPosEns	 := 0   
  
If lTipo

	If nTamForm >= Len(cForAux)
		cFormula := cForAux
				                      
		For nY := 1 to Len(cForAux)
			nPosForM   := At("#",cForAux)	
			QE1->(dbSetOrder(1))
			QE1->(dbSeek(xFilial("QE1")+SubStr(cForAux,nPosForm+1,8)))
			//Verificação do numero de cerquilhas esta certo
		
			cEnsAux := SubStr(cForAux,nPosForm,10)
			If Len(cEnsAux) > 0
				nCont1  := At("#",cEnsAux)
				cEnsAux := Stuff(cEnsAux,nCont1,1,"")
				nCont2  :=RAt("#",cEnsAux)
				If (nCont1 == 0 .OR. nCont2 == 0 .OR. nCont1 == nCont2)
					If lMsg		
						MsgAlert(STR0057)  //("A fórmula cadastrada está incorreta.")
					Endif
					Return .F.
				Endif
			Endif
	
			If Len (cEnsAux) > 0
				//Verificação se o numero de parenteses abertos é igual ao numero de parenteses fechados
				nCont3 := At("(",cFormula)
				If nCont3 > 0
					nPar1++
					cFormula := Stuff(cFormula,nCont3,1,"")
				Endif
				nCont4 := At(")",cFormula)
				If nCont4 > 0 
					nPar2++
					cFormula := Stuff(cFormula,nCont4,1,"")
				Endif 
				If nPar1 <> nPar2
					If lMsg
						MsgAlert(STR0057)  //"A fórmula cadastrada está incorreta."
					Endif
					Return .F.
				Endif
			Endif	
		
			Aadd(aEnsCal,{SubStr(cForAux,nPosForm+1,8),QE1->QE1_CARTA,QE1->QE1_QTDE})
			cForAux := Stuff(cForAux,1,nPosForM+10,Space(nPosForM+10))
			nY      := (nPosForM+10)
			nCont1 := nCont2 := nCont3 := nCont4
		Next nY
	
		For nY:=1 to Len(aEnsCal)
			lRetorno := .f.
	    	For nW:=1 to Len(aCols)
	    		If aCols[nW,nPosEns] == aEnsCal[nY,1] .and. !aCols[nW,Len(aCols[nW])]
	        		If cCarta <> aEnsCal[nY,2] .or. nQtdEns <> aEnsCal[nY,3]
						HELP(" ",1,"Q010ErrEns",,STR0025+CHR(13)+CHR(10)+STR0026+aCols[nW,nPosEns],1,30)  //"Tipo de Carta e/ou numero de medicoes incorretos no ensaio "
						lRetorno := .F.
						Exit
					Else
		       			lRetorno := .T.
	        	   		Exit
					EndIf		
	        	EndIf		
			Next nW
		Next nY 
	
		If !lRetorno
			//STR0060 ### "Fórmula"
			//STR0061 ### "Existem campos obrigatórios não preenchidos ou o ensaio usado na fórmula não pertence a esta especificação."
			//STR0062 ### "Verifique os campos obrigatórios e a fórmula e tente novamente."
			Help(NIL, NIL, STR0060, NIL, STR0061,1, 0, NIL, NIL, NIL, NIL, NIL, {STR0062})
		EndIF
	Else
		MsgAlert(STR0058 + cValToChar(nTamForm) + STR0059)	
		lRetorno := .F.
	Endif			    
Endif

Return lRetorno

//----------------------------------------------------------------------
/*/{Protheus.doc} Q010GetSX3 
Busca dados da SX3 
@author Brunno de Medeiros da Costa
@since 24/04/2018
@version 1.0
@return aHeaderTmp
/*/
//---------------------------------------------------------------------- 
Static Function Q010GetSX3(cCampo)
Local aHeaderTmp := {}
aHeaderTmp:= {QAGetX3Tit(cCampo),;
              GetSx3Cache(cCampo,'X3_CAMPO'),;
              GetSx3Cache(cCampo,'X3_PICTURE'),;
              GetSx3Cache(cCampo,'X3_TAMANHO'),;
              GetSx3Cache(cCampo,'X3_DECIMAL'),;
              GetSx3Cache(cCampo,'X3_VALID'),;              
              GetSx3Cache(cCampo,'X3_USADO'),;
              GetSx3Cache(cCampo,'X3_TIPO'),;
              GetSx3Cache(cCampo,'X3_ARQUIVO'),;
              GetSx3Cache(cCampo,'X3_CONTEXT') }
Return aHeaderTmp
