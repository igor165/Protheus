#INCLUDE "QIEA090.CH"
#INCLUDE "PROTHEUS.CH"


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIEA090  ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 05/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Skip-Teste Individual           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function MenuDef()

Local aRotina:= { 	{OemToAnsi(STR0004),"AxPesqui"		, 0 , 1,,.F.},;  // "Pesquisar"
					{OemToAnsi(STR0005),"A090Visual"	, 0 , 2},;  // "Visualizar"
					{OemToAnsi(STR0006),"A090Incl"		, 0 , 3},;  // "Incluir"
					{OemToAnsi(STR0007),"A090Alte"		, 0 , 6},;  // "Alterar"
					{OemToAnsi(STR0008),"QIE090Del"	, 0 , 5 , 3} }  // "Excluir"

Return aRotina

Function QIEA090
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCRA := { OemToAnsi(STR0001), OemToAnsi(STR0002), OemToAnsi(STR0003) }  //"Confirma" ### "Redigita" ### "Abandona"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0009)  //"Skip-Teste Individual"

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

Private aRotina:= MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"QEH")

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A090Visual³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 05/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao Skip-Teste Individual              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A090Visual(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function a090Visual(cAlias,nReg,nOpc)

Local cRevi			:= ""
Local oDlg			:= NIL
Local oGet_1		:= NIL
Local oGet_2		:= NIL
Local oGet_3		:= NIL
Local oBox
Local aSize         :={}
Local aObjects      :={}
Local aInfo         :={}
Local aPosObj       :={} 
Local cWhile  		:= '' 
Local cSeek 		:= '' 


Private cIE090For := Space(TamSX3("QEH_FORNEC")[1])
Private cIE090LjF := Space(TamSX3("QEH_LOJFOR")[1])
Private cIE090Pro := Space(TamSX3("QEH_PRODUT")[1])
Private aHeader   := {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL
Private nPosEns   := 0
Private nPosSkT	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos do Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QEH")  // Posiciona pq. rotinas internas utilizam inf. do SX2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FillGetDados(	nOpc,; 							// numero correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
               	"QEH",;       					// area a ser utilizada;
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
               	
nUsado	:= Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda as posicoes dos campos p/ posterior consistˆncia      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosEns := aScan(aHeader, { |x| AllTrim(x[2]) == 'QEH_ENSAIO' } )
nPosSkT := aScan(aHeader, { |x| AllTrim(x[2]) == 'QEH_SKPTES' } )

oSize := FwDefSize():New()

oSize:AddObject( "LINHA1"    ,  100, 30, .T.,.F.) // Totalmente dimensionavel
oSize:AddObject( "GETDADOS" ,  100, 70, .T.,.T.) // Totalmente dimensionavel
          
oSize:aMargins := { 3, 3, 0, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0009) ; // "Skip-Teste Individual"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

@ oSize:GetDimension('LINHA1','LININI'),oSize:GetDimension('LINHA1','LININI') SCROLLBOX oBox SIZE oSize:GetDimension('LINHA1','YSIZE'),oSize:GetDimension('LINHA1','XSIZE') OF oDlg

cIE090For := QEH->QEH_FORNEC
cIE090LjF := QEH->QEH_LOJFOR
cIE090Pro := QEH->QEH_PRODUT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets do Fornecedor                         				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 5,03 SAY TitSX3("QEH_FORNEC")[1] SIZE 56,07 OF oBox PIXEL  
@ 3,61 MSGET oGet_1 VAR cIE090For PICTURE PesqPict("SA5","A5_FORNECE") ;
						WHEN .F. ;			
						SIZE 66,10 OF oBox PIXEL  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets da Loja                               				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 5,131 SAY TitSX3("QEH_LOJFOR")[1] SIZE 56, 7 OF oBox PIXEL
@ 3,189 MSGET oGet_2 VAR cIE090LjF PICTURE PesqPict("SA5","A5_LOJA") ;
						WHEN .F. ;
					   SIZE 15,10 OF oBox PIXEL
@ 5,208 SAY QIEXDeFo(cIE090For,cIE090LjF,2) SIZE 80,7 OF oBox PIXEL 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets do Produto                            				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 20, 3 SAY TitSX3("QEH_PRODUT")[1] SIZE 56, 7 OF oBox PIXEL  
@ 18,61 MSGET oGet_3 VAR cIE090Pro PICTURE PesqPict("SA5","A5_PRODUTO") ;
						WHEN .F. ;
					   SIZE 125,10 OF oBox PIXEL
@ 20,191 SAY QIEXDePr(cIE090Pro) SIZE 130,7 OF oBox PIXEL	

A090GrGD(@cRevi,nOpc,oDlg)

oGet:= MSGetDados():New(oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
						 oSize:GetDimension("GETDADOS","LINEND")+3,oSize:GetDimension("GETDADOS","COLEND"),;
						 nOpc,"AllwaysTrue","AllwaysTrue","",.F.)
oGet:Refresh()

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}),;
								AlignObject(oDlg,{oBox,oGet:oBrowse},1,,{75}))

dbSelectArea(cAlias)
dbGoto(nReg)

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A090Incl  ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 05/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao Skip-Teste Individual              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A090Inclui(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A090Incl(cAlias,nReg,nOpc)

Local nI          := 0
Local cRevi			:= ""
Local lGravaOk		:= .F.
Local oGet_1		:= NIL
Local oGet_2		:= NIL
Local oGet_3		:= NIL
Local oDlg			:= NIL   
Local cWhile  		:= '' 
Local cSeek 		:= '' 
Local oBox
Local oSize

Private cIE090For := Space(TamSX3("QEH_FORNEC")[1])
Private cIE090LjF := Space(TamSX3("QEH_LOJFOR")[1])
Private cIE090Pro := Space(TamSX3("QEH_PRODUT")[1])
Private nPosEns	:= 0
Private nPosSkT	:= 0
Private aHeader   := {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL

FillGetDados(	nOpc,; 							// numero correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
               	"QEH",;       					// area a ser utilizada;
               	1,;      						// nOrdem - ordem correspondente a chave de índice para preencher o  acols;
               	&cSeek,;  	// chave utilizada no posicionamento da área para preencher o acols; 
               	{|| &cWhile},; 					// bloco contendo a expressão a ser comparada com cSeekKey na condição  do While. 
               	{|| .T.},;  					// uSeekFor
               	,;  						 	// aNoFields - array contendo os campos que não estarao no aHeader;
               	,;  							// aYesFields - array contendo somente os campos que estarao no aHeader;
               	.F.,;      						// se verdadeiro, exibe apenas os campos de usuário;
                '',;      						// cQuery - query a ser executada para preencher o acols;
               	,;    				   			// bloco contendo funcao especifica para preencher o aCols; 
               	.T.,;  	// lEmpty 
               	,; 								// aHeaderAux
               	,; 		   						// aColsAux
               	,; 								// bAfterCols
               	,; 								// bBeforeCols
               	,; 								// bAfterHeader
               	'') 							// cAliasQry

nUsado := Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda as posicoes dos campos p/ posterior consistˆncia      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosEns := aScan(aHeader, { |x| AllTrim(x[2]) == 'QEH_ENSAIO' } )
nPosSkT := aScan(aHeader, { |x| AllTrim(x[2]) == 'QEH_SKPTES' } )

oSize := FwDefSize():New()

oSize:AddObject( "LINHA1"    ,  100, 30, .T.,.F.) // Totalmente dimensionavel
oSize:AddObject( "GETDADOS" ,  100, 70, .T.,.T.) // Totalmente dimensionavel
      
oSize:aMargins := { 3, 3, 0, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0009) ; // "Skip-Teste Individual"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

@ oSize:GetDimension('LINHA1','LININI'),oSize:GetDimension('LINHA1','LININI') SCROLLBOX oBox SIZE oSize:GetDimension('LINHA1','YSIZE'),oSize:GetDimension('LINHA1','XSIZE') OF oDlg

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets do Fornecedor                         				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 5,03 SAY TitSX3("QEH_FORNEC")[1] SIZE 56,07 OF oBox PIXEL  
@ 3,61 MSGET oGet_1 VAR cIE090For PICTURE PesqPict("SA5","A5_FORNECE");
 						F3 "QFP"; 
 						VALID	a090GrGD(@cRevi,nOpc,oDlg).And. ExistCpo("SA2",cIE090For) ;
						SIZE 66,10 OF oBox PIXEL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets da Loja                               				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 5,131 SAY TitSX3("QEH_LOJFOR")[1] SIZE 56, 7 OF oBox PIXEL 
@ 3,189 MSGET oGet_2 VAR cIE090LjF PICTURE PesqPict("SA5","A5_LOJA") ;
						  VALID a090GrGD(@cRevi,nOpc,oDlg) .And. ExistCpo("SA2",cIE090For+cIE090LjF) ;
						  SIZE 15,10 OF oBox PIXEL
@ 5,208 SAY QIEXDeFo(cIE090For,cIE090LjF,2) SIZE 80,7 OF oBox PIXEL 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets do Produto                            				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 20, 3 SAY TitSX3("QEH_PRODUT")[1] SIZE 56, 7 OF oBox PIXEL  
@ 18,61 MSGET oGet_3 VAR cIE090Pro PICTURE PesqPict("SA5","A5_PRODUTO") ;
						  VALID a090GrGD(@cRevi,nOpc,oDlg);
						 .And. ExistCpo("SB1",cIE090Pro);
						 .And. ExistCpo2("SA5",cIE090For+cIE090LjF+cIE090Pro,,STR0014);
						 SIZE 125,10 OF oBox PIXEL
@ 20,191 SAY QIEXDePr(cIE090Pro) SIZE 130,7 OF oBox PIXEL		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O parƒmetro nOpc que corresponde ao aRotina[3][4] ‚ alterado ³
//³  para 6, indicando 'alteracao.  Isto ‚ necess rio para nÆo'  ³
//³  permitir a inclusÆo de linhas na GetDados                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
aRotina[3][4] := 6 // {OemToAnsi(STR0006),"A090Inclui"  , 0 , 6}  	

oGet:= MSGetDados():New(oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
						 oSize:GetDimension("GETDADOS","LINEND")+3,oSize:GetDimension("GETDADOS","COLEND"),;
						 nOpc ,"AllwaysTrue","AllwaysTrue","",.T.)

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,;
	{|| IIf(lGravaOk:=QI090TdOk(), oDlg:End(),)},;
	{||lGravaOk:=.F.,oDlg:End()} ),;
	AlignObject(oDlg,{oBox,oGet:oBrowse},1,,{75}))

aRotina[3][4] := 3 // {OemToAnsi(STR0006),"A090Inclui"  , 0 , 3}  

If lGravaOk
	Begin Transaction
		lGravaOk := A090GrvSt()
		nReg := QEH->(Recno())  // Torno o novo como atual.
		If !lGravaOK 
			Help(" ",1,"A010NAOGRV")
		Else  
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
±±³Fun‡…o    ³a090Alte  ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 05/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao Skip-Teste Individual              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A090Altera(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function a090Alte(cAlias,nReg,nOpc)

Local cRevi		:= ""
Local lGravaOk	:= .F.
Local oGet_1		:= NIL
Local oGet_2		:= NIL
Local oGet_3		:= NIL
Local oDlg			:= NIL   
Local cWhile		:= '' 
Local cSeek 		:= '' 
Local oObx
Local oSize

Private cIE090For := Space(TamSX3("QEH_FORNEC")[1])
Private cIE090LjF := Space(TamSX3("QEH_LOJFOR")[1])
Private cIE090Pro := Space(TamSX3("QEH_PRODUT")[1])
Private nPosEns	:= 0
Private nPosSkT	:= 0
Private aHeader   := {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos do Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX2")  // Posiciona pq. rotinas internas utilizam inf. do SX2
dbSeek("QEH")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FillGetDados(	nOpc,; 							// numero correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
               	"QEH",;       					// area a ser utilizada;
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
               	
nUsado := Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda as posicoes dos campos p/ posterior consistˆncia      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosEns := aScan(aHeader, { |x| AllTrim(x[2]) == 'QEH_ENSAIO' } )
nPosSkT := aScan(aHeader, { |x| AllTrim(x[2]) == 'QEH_SKPTES' } )

oSize := FwDefSize():New()

oSize:AddObject( "LINHA1"    ,  100, 30, .T.,.F.) // Totalmente dimensionavel
oSize:AddObject( "GETDADOS" ,  100, 70, .T.,.T.) // Totalmente dimensionavel
     
oSize:aMargins := { 3, 3, 0, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0009) ; // "Skip-Teste Individual"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL						

@ oSize:GetDimension('LINHA1','LININI'),oSize:GetDimension('LINHA1','LININI') SCROLLBOX oBox SIZE oSize:GetDimension('LINHA1','YSIZE'),oSize:GetDimension('LINHA1','XSIZE') OF oDlg

cIE090For := QEH->QEH_FORNEC
cIE090LjF := QEH->QEH_LOJFOR
cIE090Pro := QEH->QEH_PRODUT
A090GrGD(@cRevi,nOpc,oDlg)	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets do Fornecedor                         				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 5,03 SAY TitSX3("QEH_FORNEC")[1] SIZE 56,07 OF oBox PIXEL  
@ 3,61 MSGET oGet_1 VAR cIE090For PICTURE PesqPict("SA5","A5_FORNECE") ;
						WHEN .F. ;			
						SIZE 66,10 OF oBox PIXEL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets da Loja                               				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 5,131 SAY TitSX3("QEH_LOJFOR")[1] SIZE 56, 7 OF oBox PIXEL 
@ 3,189 MSGET oGet_2 VAR cIE090LjF PICTURE PesqPict("SA5","A5_LOJA") ;
						WHEN .F. ;
					   SIZE 15,10 OF oBox PIXEL
@ 5,208 SAY QIEXDeFo(cIE090For,cIE090LjF,2) SIZE 80,7 OF oBox PIXEL 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets do Produto                            				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 20, 3 SAY TitSX3("QEH_PRODUT")[1] SIZE 56, 7 OF oBox PIXEL  
@ 18,61 MSGET oGet_3 VAR cIE090Pro PICTURE PesqPict("SA5","A5_PRODUTO") ;
						WHEN .F. ;
					   SIZE 125,10 OF oBox PIXEL
@ 20,191 SAY QIEXDePr(cIE090Pro) SIZE 130,7 OF oBox PIXEL	

oGet:= MSGetDados():New(oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
						 oSize:GetDimension("GETDADOS","LINEND")+3,oSize:GetDimension("GETDADOS","COLEND"),;
						 nOpc ,"AllwaysTrue","AllwaysTrue","",.T.,,,,,,,,"QE90VlDel")
	
ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,;
				{|| IIf(lGravaOk:=QI090TdOk(), oDlg:End(),)},;
				{||lGravaOk:=.F.,oDlg:End()} ),;
				AlignObject(oDlg,{oBox,oGet:oBrowse},1,,{75}))

If lGravaOk
	Begin Transaction
		lGravaOk := A090GrvSt()
		nReg := QEH->(Recno())  // Torno o novo como atual.
		If !lGravaOK 
			Help(" ",1,"A010NAOGRV")
		Else  
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
±±³Fun‡…o    ³QIE090DEL ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 05/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao Skip-Teste Individual              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIE090DEL(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIE090Del(cAlias,nReg,nOpc)

Local cRevi			:= ""
Local oDlg			:= NIL
Local oGet_1		:= NIL
Local oGet_2		:= NIL
Local oGet_3		:= NIL
Local lDeleta		:= .F.
Local cWhile		:= '' 
Local cSeek 		:= '' 
Local oBox
Local oSize

Private cIE090For := Space(TamSX3("QEH_FORNEC")[1])
Private cIE090LjF := Space(TamSX3("QEH_LOJFOR")[1])
Private cIE090Pro := Space(TamSX3("QEH_PRODUT")[1])
Private nPosEns	:= 0
Private nPosSkT	:= 0
Private aHeader   := {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL
Private cCod		:= ""
Private cChaveQEY := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos do Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX2")  // Posiciona pq. rotinas internas utilizam inf. do SX2
dbSeek("QEH")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FillGetDados(	nOpc,; 							// numero correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
               	"QEH",;       					// area a ser utilizada;
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
nUsado := Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda as posicoes dos campos p/ posterior consistˆncia      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosEns := aScan(aHeader, { |x| AllTrim(x[2]) == 'QEH_ENSAIO' } )
nPosSkT := aScan(aHeader, { |x| AllTrim(x[2]) == 'QEH_SKPTES' } )

oSize := FwDefSize():New()

oSize:AddObject( "LINHA1"    ,  100, 30, .T.,.F.) // Totalmente dimensionavel
oSize:AddObject( "GETDADOS" ,  100, 70, .T.,.T.) // Totalmente dimensionavel
  
oSize:aMargins := { 3, 3, 0, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0009) ; // "Skip-Teste Individual"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

@ oSize:GetDimension('LINHA1','LININI'),oSize:GetDimension('LINHA1','LININI') SCROLLBOX oBox SIZE oSize:GetDimension('LINHA1','YSIZE'),oSize:GetDimension('LINHA1','XSIZE') OF oDlg

cIE090For := QEH->QEH_FORNEC
cIE090LjF := QEH->QEH_LOJFOR
cIE090Pro := QEH->QEH_PRODUT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets do Fornecedor                         				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 5,03 SAY TitSX3("QEH_FORNEC")[1] SIZE 56,07 OF oBox PIXEL  
@ 3,61 MSGET oGet_1 VAR cIE090For PICTURE PesqPict("SA5","A5_FORNECE") ;
						WHEN .F. ;			
						SIZE 66,10 OF oBox PIXEL  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets da Loja                               				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 5,131 SAY TitSX3("QEH_LOJFOR")[1] SIZE 56, 7 OF oBox PIXEL 
@ 3,189 MSGET oGet_2 VAR cIE090LjF PICTURE PesqPict("SA5","A5_LOJA") ;
						WHEN .F. ;
					   SIZE 15,10 OF oBox PIXEL
@ 5,208 SAY QIEXDeFo(cIE090For,cIE090LjF,2) SIZE 80,7 OF oBox PIXEL 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets do Produto                            				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 20, 3 SAY TitSX3("QEH_PRODUT")[1] SIZE 56, 7 OF oBox PIXEL  
@ 18,61 MSGET oGet_3 VAR cIE090Pro PICTURE PesqPict("SA5","A5_PRODUTO") ;
						WHEN .F. ;
					   SIZE 125,10 OF oBox PIXEL
@ 20,191 SAY QIEXDePr(cIE090Pro) SIZE 130,7 OF oBox PIXEL	

A090GrGD(@cRevi,nOpc,oDlg)

oGet:= MSGetDados():New(oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
						 oSize:GetDimension("GETDADOS","LINEND")+3,oSize:GetDimension("GETDADOS","COLEND"),;
						 nOpc,"AllwaysTrue","AllwaysTrue","",.F.)

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,;
					{||oDlg:End(),lDeleta:=.T.},	{||oDlg:End(),lDeleta:=.F.} ),;
					AlignObject(oDlg,{oBox,oGet:oBrowse},1,,{75}))

If lDeleta
	Begin Transaction
		cCod  := QEH_FORNEC+QEH_LOJFOR+QEH_PRODUT
		dbSelectArea("QEH")
		dbSetOrder(1)
		dbSeek(xFilial("QEH")+cCod)
		While !Eof() .And. xFilial("QEH") == QEH_FILIAL .And.;
			cCod == QEH_FORNEC+QEH_LOJFOR+QEH_PRODUT
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta o registro                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(cAlias)   //QEH
			RecLock(cAlias,.F.,.T.)
			dbDelete()
			MsUnLock()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta o Controle Skip-Teste Individual                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QEN->(dbSetOrder(1))
			If QEN->(dbSeek( xFilial("QEN")+cCod+QEH->QEH_ENSAIO ))
				RecLock("QEN", .F.,.T.)
				QEN->(dbDelete())
				MsUnLock()
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta o Historico Skip-Teste do Ensaio                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cChaveQEY := QEH->QEH_FORNEC+QEH->QEH_LOJFOR+QEH->QEH_PRODUT+;
																				QEH->QEH_ENSAIO
			QEY->(dbSetOrder(2))
			QEY->(dbSeek(xFilial("QEY")+cChaveQEY))
			While QEY->QEY_FILIAL+QEY->QEY_FORNEC+QEY->QEY_LOJFOR+QEY->QEY_PRODUT+;
					QEY->QEY_ENSAIO == xFilial("QEY")+cChaveQEY .And. !QEY->(Eof())
				RecLock("QEY", .F.,.T.)
				QEY->(dbDelete())
				MsUnLock()
				QEY->(dbSkip())
			EndDo
			QEY->(dbSetOrder(1))
			dbSelectArea("QEH")				
			dbSkip()
		EndDo		
	End Transaction			
EndIf	

dbSelectArea(cAlias)

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A090GrGD ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 12/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega vetor aCols para a GetDados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A090GrGD(ExpC1,ExpN1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Revisao do Produto                                  ³±±
±±³          ³ ExpN1: Opcao selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A090GrGD(cRevi,nOpc,oDlg,nGet)
Local nOrdSA5 		:= SA5->(IndexOrd())  
Local nPosAliWT  	:= Ascan(aHeader,{|x|AllTrim(x[2])=="QEH_ALI_WT"})
Local nPosRecWT  	:= Ascan(aHeader,{|x|AllTrim(x[2])=="QEH_REC_WT"}) 
Local nCnt 			:= 0  
Local n 			:= 0
Local nX 			:= 0
Local lRetu 		:= .T.
Local lPass 		:= .T.
Local aColsAux 		:= {}

If !Empty(cIE090Pro) .And. !Empty(cIE090For) .And. !Empty(cIE090LjF)
    

	SA5->(dbSetOrder(2))
	lPass := SA5->(dbSeek(xFilial("SA5")+cIE090Pro+cIE090For+cIE090LjF))
	SA5->(dbSetOrder(nOrdSA5))

	If lPass
		//Inicializa o aCols
		aCols:={}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Identifica a revisao vigente do Produto                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cRevi := QA_UltRevEsp(cIE090Pro,,,,"QIE")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alimenta vetor aCols com os Ensaios associados ao Produto        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Identifica o Grupo do Produto, se houver
		QEA->(dbSetOrder(2))
		QEA->(dbSeek(xFilial("QEA")+cIE090Pro))
		QEA->(dbSetOrder(1))
		
		//Ensaios mensuraveis
		dbSelectArea("QE7")
		dbSetOrder(1)
		dbSeek( xFilial("QE7")+cIE090Pro+cRevi)
		While !Eof() .And. QE7_FILIAL+QE7_PRODUT+QE7_REVI == xFilial("QE7")+cIE090Pro+cRevi
			aadd(aCols,Array(nUsado+1))	// Cria novo elemento no acols
			nCnt := Len(aCols)
			//	Alimenta o aCols
			aCols[nCnt][ascan(aHeader,{|x| alltrim(x[2])=='QEH_ENSAIO'})] := QE7_ENSAIO
			aCols[nCnt][ascan(aHeader,{|x| alltrim(x[2])=='QEH_DESENS'})] := QIEXDeEn(QE7_ENSAIO)

			QEH->(dbSetOrder(1))
			If QEH->(dbSeek(xFilial("QEH")+cIE090For+cIE090LjF+cIE090Pro+QE7->QE7_ENSAIO))
				aCols[nCnt][nPosSkT] := QEH->QEH_SKPTES
			Else
				aCols[nCnt][nPosSkT] := 0
			EndIf
			QEI->(dbSetOrder(1))
			If QEI->(dbSeek( xFilial("QEI")+cIE090For+cIE090LjF+QEA->QEA_GRUPO+QE7->QE7_ENSAIO))
				aCols[nCnt][ascan(aHeader,{|x| alltrim(x[2])=='QEH_SKPGRU'})] := QEI->QEI_SKPTES
			Else
				aCols[nCnt][ascan(aHeader,{|x| alltrim(x[2])=='QEH_SKPGRU'})] := 0
			EndIf

	   		If nPosAliWT > 0 .AND. aCols[nCnt][nPosSkT] <> 0
				aCols[nCnt,nPosAliWT] := "QEH"
			EndIf

			If nPosRecWT > 0 .AND. aCols[nCnt][nPosSkT] <> 0
				aCols[Len(aCols),nPosRecWT] := QEH->(RecNo())
			EndIf
			
			aCOLS[nCnt][nUsado+1] := .F.
			dbSkip()
		Enddo

		// Ensaios Texto
		dbSelectArea("QE8")
		dbSetOrder(1)
		dbSeek( xFilial("QE8")+cIE090Pro+cRevi)
		While !Eof() .And. QE8_FILIAL+QE8_PRODUT+QE8_REVI == xFilial("QE8")+cIE090Pro+cRevi
			aadd(aCols,Array(nUsado+1))	// Cria novo elemento no acols
			nCnt := Len(aCols)
			// Alimenta o aCols
			aCols[nCnt][ascan(aHeader,{|x| alltrim(x[2])=='QEH_ENSAIO'})] := QE8_ENSAIO
			aCols[nCnt][ascan(aHeader,{|x| alltrim(x[2])=='QEH_DESENS'})] := QIEXDeEn(QE8_ENSAIO)

			QEH->(dbSetOrder(1))
			If QEH->(dbSeek(xFilial("QEH")+cIE090For+cIE090LjF+cIE090Pro+QE8->QE8_ENSAIO))
				aCols[nCnt][nPosSkT] := QEH->QEH_SKPTES
			Else
				aCols[nCnt][nPosSkT] := 0
			EndIf

			QEI->(dbSetOrder(1))
			If QEI->(dbSeek( xFilial("QEI")+cIE090For+cIE090LjF+QEA->QEA_GRUPO+QE8->QE8_ENSAIO))
				aCols[nCnt][ascan(aHeader,{|x| alltrim(x[2])=='QEH_SKPGRU'})] := QEI->QEI_SKPTES
			Else
				aCols[nCnt][ascan(aHeader,{|x| alltrim(x[2])=='QEH_SKPGRU'})] := 0
			EndIf 

	   		If nPosAliWT > 0 .AND. aCols[nCnt][nPosSkT] <> 0
				aCols[nCnt,nPosAliWT] := "QEH"
			EndIf
			
			If nPosRecWT > 0 .AND. aCols[nCnt][nPosSkT] <> 0
				aCols[Len(aCols),nPosRecWT] := QEH->(RecNo())
			EndIf

			aCols[nCnt][nUsado+1] := .F.
			dbSkip()
		Enddo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ordena Ensaios de acordo com o campo Ensaio                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCols := asort(aCols,,, { | x,y | x[nPosEns] < y[nPosEns] } )

		// Posiciona o arquivo de Skip-Teste Individual
		dbSelectArea("QEH")
		dbSetOrder(1)
		dbseek(xFilial()+cIE090For+cIE090LjF+cIE090Pro)
	EndIf
    
	If Len(aCols) == 0
		aCols := aClone(aColsAux)
	EndIf
EndIf

If nOpc == 3		//InclusÆo
	n:=Len(aCols)
	oGet:ForceRefresh()
EndIf

Return(lRetu)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A090GrvST ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 08/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os Skip-Testes Individuais                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A090GrvST()
Local nx ,ny , nMaxArray := Len(aCols)
Local cChvQEY

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o arquivo QEH                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to nMaxArray
	dbSelectArea("QEH")
	dbSetOrder(1)
	If !Acols[nX,nUsado+1]	.And. ;// Nao esta deletado
			!Empty(aCols[nX,nPosSkT]) .And. !Empty(cIE090For) .And. ;
			!Empty(cIE090Pro) .And. !Empty(cIE090LjF)	 // Skip-Teste nao vazio
		If dbSeek(xFilial("QEH")+cIE090For+cIE090LjF+cIE090Pro+aCols[nX][nPosEns])
			RecLock("QEH",.F.)   // Lock
		Else
			RecLock("QEH",.T.)   // Append
			QEH->QEH_FILIAL := xFilial("QEH")
			QEH->QEH_FORNEC := cIE090For
			QEH->QEH_LOJFOR := cIE090LjF
			QEH->QEH_PRODUT := cIE090Pro
			QEH->QEH_ENSAIO := aCols[nX][nPosEns]
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
		If dbSeek(xFilial("QEH")+cIE090For+cIE090LjF+cIE090Pro+aCols[nX][nPosEns])
			RecLock("QEH",.F.)
			dbDelete()
			MsUnLock()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta o Controle Skip-Teste Individual                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If QEN->(dbSeek(xFilial("QEN")+cIE090For+cIE090LjF+cIE090Pro+aCols[nX][nPosEns]))
				RecLock("QEN", .F.)
				QEN->(dbDelete())
				MsUnLock()
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta o Historico Skip-Teste do Ensaio                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cChvQEY := QEH->QEH_FORNEC+QEH->QEH_LOJFOR+QEH->QEH_PRODUT+QEH->QEH_ENSAIO
			QEY->(dbSetOrder(2))
			QEY->(dbSeek(xFilial("QEY")+cChvQEY))
			While QEY->QEY_FILIAL+QEY->QEY_FORNEC+QEY->QEY_LOJFOR+QEY->QEY_PRODUT+;
					QEY->QEY_ENSAIO == xFilial("QEY")+cChvQEY .And. !QEY->(Eof())
				RecLock("QEY", .F.)
				QEY->(dbDelete())
				MsUnLock()
				QEY->(dbSkip())
			Enddo
			QEY->(dbSetOrder(1))
		EndIf
	EndIf
Next nX

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A090WhST ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 09/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define a clausula WHEN para o campo Skip-Teste             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A090WhST()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A090WhST()
Local lRetu := .t.

If ReadVar() == "M->QEH_SKPTES"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se j  definiu o skip-teste por grupo       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QEA->(dbSetOrder(2))
	If QEA->(dbSeek(xFilial("QEA")+cIE090Pro))
		QEI->(dbSetOrder(1))
		If QEI->(dbSeek( xFilial("QEI")+cIE090For+cIE090LjF+QEA->QEA_GRUPO+aCols[n][nPosEns]))
			MsgInfo(OemToAnsi(STR0011),OemToAnsi(STR0012))	// "O Skip-Teste referente a ensaio est  definido por grupo."###"Aten‡„o"
			lRetu := .F.
		EndIf
	EndIf
	QEA->(dbSetOrder(1))
EndIf
Return(lRetu)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QE90VlDel ³ Autor ³ Eduardo de Souza      ³ Data ³ 21/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se linha pode ser deletada.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QE90VlDel()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QE90VlDel()

Local lRet:= .T.

If Acols[n,nPosSkT] == 0
	lRet:= .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QI090TdOk
Função de validação de linha
@author marco.guimaraes
@since 15/09/14
@return lRet
/*/
//-------------------------------------------------------------------
Function QI090TdOk()
Local lRet := .T.
Local nSkpTeste := aScan(aHeader, { |x| alltrim(x[2]) == 'QEH_SKPTES' })
Local nEnsaio := aScan(aHeader, { |x| alltrim(x[2]) == 'QEH_ENSAIO' })
Local cMsgErro := ""
Local i := 0

For i := 1 To Len(aCols)
	If aCols[i, nSkpTeste] < 1
		cMsgErro += "<br>" + aCols[i, nEnsaio] 
	EndIf
Next

If !Empty(cMsgErro) 
	Help("", 1, "QI090SKTT",, STR0013 + cMsgErro, 4, 1) // Valor inválido do Skip-Teste para o(os) ensaio(os):
EndIf

Return lRet