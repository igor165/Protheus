#INCLUDE "QIEC050.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE  X3_RESERV_I "”€" //NAO ALTERA ORDEM / ALTERA TAMANHO

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QIEC050   ³ Autor ³ Cleber L. Souza       ³ data ³22/05/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta: Situacao Proxima Entrada                   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIE													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³STR 	     ³ Ultimo utilizado -> STR0026                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³ 										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MenuDef()

Local aRotina := {{OemToAnsi(STR0001),"AxPesqui" ,0,1},; //"Pesquisar"
				{OemToAnsi(STR0002),"Q050Cons" ,0,2}}  //"Consulta"
				
Return aRotina

Function QIEC050()  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do Browse  										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0003)  //"Situacao da Proxima Entrada"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ 1 - Nome a aparecer no cabecalho                             ³
//³ 2 - Nome da Rotina associada                                 ³
//³ 3 - Usado pela rotina                                        ³
//³ 4 - Tipo de Transa‡„o a ser efetuada                         ³
//³    1) Pesquisa e Posiciona em um Banco de Dados              ³
//³    2) Consulta as proximas entradas                          ³   
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef()

dbSelectArea("SA5") 
mBrowse(06,01,22,75,"SA5") 

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q050Cons  ³ Autor ³Cleber L. Souza        ³ Data ³19/05/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Tela de Consulta ultimas Entradas.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias do arquivo									  ³±±
±±³			 ³ EXPN1 = Numero do registro 								  ³±±
±±³			 ³ EXPN2 = Opcao selecionada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEC050													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q050Cons(cAlias,nReg,nOpc)
Local oDlg       
Local oDocEnt
Local nOpcA      := 0
Local aAreaAnt   := GetArea()
Local aCords	:= FWGetDialogSize( oMainWnd )
Local oSize     := nil

Private oMsg1 	  := NIL
Private oMsg2 	  := NIL
Private oMsg3 	  := NIL
Private oMsg4 	  := NIL
Private cMsg1 	  := ""
Private cMsg2 	  := ""
Private cMsg3 	  := ""    
Private cMsg4 	  := ""    
Private oGetEnt
Private lDocEnt   := .T.
Private aTela     := {}
Private aGets     := {}                                           
Private aHeader   := {}
Private aCols     := {}
Private N         := 1
Private nUsado    := 0   
Private nPosDat  
Private nPosLot  
Private nPosIns  
Private nPosLau  
Private nPosNF   
Private nPosAli
Private nPosRec
Private cDocEnt   := Space(TamSX3("QEK_DOCENT")[1]) 
Private aButtons  := {}        
Private aCpoEnc   := {} 
Private aNoFields := {}

Pergunte("QEC050",.F.)               

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos a serem visualizados na Enchoice						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aCpoEnc,'A5_FORNECE')
Aadd(aCpoEnc,'A5_LOJA')
Aadd(aCpoEnc,'A5_NOMEFOR')
Aadd(aCpoEnc,'A5_PRODUTO')
Aadd(aCpoEnc,'A5_NOMPROD')
Aadd(aCpoEnc,'A5_VALRIAI')      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao para mudanca do numero de entradas.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aButtons,{"PARAMETROS",{||Pergunte("QEC050",.T.),C050ConsEnt(M->A5_FORNECE,M->A5_LOJA,M->A5_PRODUTO,@cMsg1,@cMsg2,@cMsg3,@oMsg1,@oMsg2,@oMsg3,cDocEnt,@oGetEnt,@oMsg4,@cMsg4)},OemToAnsi(STR0025)}) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria as variaveis para carregar campos da enchoice  		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("SA5",.F.,.T.)            

aNoFields := {"QEK_FILIAL","QEK_TIPONF","QEK_FORNEC","QEK_LOJFOR",;
			  "QEK_DESFOR","QEK_PRODUT","QEK_DESPRO","QEK_REVI"  ,;
			  "QEK_ENTINV","QEK_LOCORI","QEK_LOTINV","QEK_HRENTR",;
			  "QEK_UNIMED","QEK_DUNMED","QEK_UNIAMO","QEK_TAMLOT",;
			  "QEK_TAMAMO","QEK_LOTORI","QEK_DIASAT","QEK_PEDIDO",;
			  "QEK_ITEMPC","QEK_REMITO","QEK_DOCENT","QEK_SERINF",;
			  "QEK_DTNFIS","QEK_ITEMNF","QEK_TIPDOC","QEK_NUMSEQ",;
			  "QEK_CERFOR","QEK_TES"   ,"QEK_FILMAT","QEK_SOLIC" ,;
			  "QEK_NOMSOL","QEK_PRECO" ,"QEK_VERIFI","QEK_NNC"   ,;
			  "QEK_PLAMO1","QEK_TAMA11","QEK_ACEI11","QEK_REJE11",;
			  "QEK_TAMA12","QEK_ACEI12","QEK_REJE12","QEK_PLAMO2",;
			  "QEK_TAMA21","QEK_ACEI21","QEK_REJE21","QEK_TAMA22",;
			  "QEK_ACEI22","QEK_REJE22","QEK_CERQUA","QEK_OPCION",;
			  "QEK_GRUPO" ,"QEK_DTCAEN","QEK_CODENT","QEK_SKLDOC",;
			  "QEK_IDENTE","QEK_IDEINV","QEK_RIAI"  ,"QEK_VARIAI",;
			  "QEK_ALTESP","QEK_CHAVE" ,"QEK_MOVEST","QEK_NNCINV",;
			  "QEK_DATALU","QEK_HORALU","QEK_RESPLU","QEK_CHAVE1",;
			  "QEK_SITENT","QEK_ORIGEM","QEK_IMPORT"}

FillGetDados(nOpc,"QEK",1     ,       ,            ,         ,aNoFields,          ,        ,      ,        ,       ,          ,        ,          ,           ,{|| IncHead()},)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicionamento dos Campos na aCols.                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosDat := Ascan(aHeader,{|x|AllTrim(x[2])=="QEK_DTENTR"})
nPosLot := Ascan(aHeader,{|x|AllTrim(x[2])=="QEK_LOTE"})                            
nPosIns := Ascan(aHeader,{|x|AllTrim(x[2])=="QEK_INSCER"})
nPosLau := Ascan(aHeader,{|x|AllTrim(x[2])=="QEK_LAUDO"})
nPosNF  := Ascan(aHeader,{|x|AllTrim(x[2])=="QEK_NTFISC"})
nPosAli := Ascan(aHeader,{|x|AllTrim(x[2])=="QEK_ALI_WT"})
nPosRec := Ascan(aHeader,{|x|AllTrim(x[2])=="QEK_REC_WT"})

aCols := {}
Aadd(aCols,Array(Len(aHeader)+1))   
aCols[Len(aCols),nUsado+1] := .F.
aCols[Len(aCols),nPosDat] := CTOD("  /  /  ")
aCols[Len(aCols),nPosLot] := ""
aCols[Len(aCols),nPosIns] := ""
aCols[Len(aCols),nPosLau] := ""
aCols[Len(aCols),nPosNF]  := ""  

nUsado := Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Skip-Lote esta definido por Documento de Entrada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lDocEnt := c050RIAI(M->A5_FORNECE,M->A5_LOJA,M->A5_PRODUTO)    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra as Entradas conforme parametro						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lDocEnt
    C050ConsEnt(M->A5_FORNECE,M->A5_LOJA,M->A5_PRODUTO,@cMsg1,@cMsg2,@cMsg3,@oMsg1,;
					@oMsg2,@oMsg3,"",@oGetEnt,@oMsg4,@cMsg4)
Else
    cMsg1 := STR0004 //"Informe o valor do Doc. de Entrada."
EndIf   
  

//Coordenadas da área total da Dialog
oSize:= FWDefSize():New()
oSize:AddObject("DOC",100,5,.T.,.T.)
oSize:AddObject("TEXT",100,25,.T.,.T.)
oSize:AddObject("ENCHOICE",100,25,.T.,.T.)
oSize:AddObject("MSGETDADOS",100,35,.T.,.T.)    
oSize:SetWindowSize(aCords)
oSize:lProp 	:= .T.      
oSize:aMargins := {5,5,5,5}
oSize:Process()

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0005) From oSize:aWindSize[1],oSize:aWindSize[2] To oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd Pixel //"Consulta Situação Próxima Entrega"

@ oSize:aPosObj[1,1],005 SAY OemToAnsi(FwX3Titulo("QEK_DOCENT")) COLOR CLR_BLACK SIZE 080,008 OF oDlg PIXEL     //"Lote Fornec"
@ oSize:aPosObj[1,1]+12,oSize:aPosObj[1,2] GET oDocEnt VAR cDocEnt PICTURE PesqPict("QEK","QEK_DOCENT") ;      //Campo Doc.Entrada
                                    SIZE 062,009 OF oDlg PIXEL ;
                                    Valid C050ConsEnt(M->A5_FORNECE,M->A5_LOJA,M->A5_PRODUTO,@cMsg1,@cMsg2,@cMsg3,@oMsg1,@oMsg2,@oMsg3,cDocEnt,@oGetEnt,@oMsg4,@cMsg4);
                                    When lDocEnt
@ oSize:aPosObj[2,1]+12, oSize:aPosObj[2,2]  TO  oSize:aPosObj[2,3],oSize:aPosObj[2,4] LABEL OemToAnsi(STR0006) 	OF oDlg PIXEL  //"Situacao da Prox. Entrada" 

oDocEnt:cSX1Hlp := "QEK_DOCENT"
// Ponto de Entrada para tratar as mensagens que serão exibidas no quadro de Situacao da Prox. Entrada
If ExistBlock( "QE050MSG" ) 
	ExecBlock( "QE050MSG", .f., .f.)
Endif     

//Descrição da Prox. Entrada
@ oSize:aPosObj[2,1]+10+12, oSize:aPosObj[2,2]+5 SAY oMsg1   VAR cMsg1   SIZE 205,07 OF oDlg PIXEL
@ oSize:aPosObj[2,1]+20+12, oSize:aPosObj[2,2]+5 SAY oMsg2   VAR cMsg2   SIZE 205,07 OF oDlg PIXEL
@ oSize:aPosObj[2,1]+30+12, oSize:aPosObj[2,2]+5 SAY oMsg3   VAR cMsg3   SIZE 205,07 OF oDlg PIXEL   
@ oSize:aPosObj[2,1]+40+12, oSize:aPosObj[2,2]+5 SAY oMsg4   VAR cMsg4   SIZE 205,07 OF oDlg PIXEL   

EnChoice(cAlias,nReg,nOpc,,,,aCpoEnc,{oSize:aPosObj[3,1], oSize:aPosObj[3,2] , oSize:aPosObj[3,3]-10 , oSize:aPosObj[3,4]},,3,,,,,,)                               

@ oSize:aPosObj[4,1]-10,005 SAY OemToAnsi(STR0007)	COLOR CLR_BLACK SIZE 065,008 OF oDlg PIXEL //"Ultimas Entradas :"

oGetEnt := MSGetDados():New( oSize:aPosObj[4,1], oSize:aPosObj[4,2] , oSize:aPosObj[4,3] , oSize:aPosObj[4,4],nOpc,"AllwaysTrue()","AllwaysTrue()","",.F.,,,.F.,,,,,,oDlg)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA :=1,If(oGetEnt:TudoOk(),;
	If(!Obrigatorio(aGets,aTela),nOpcA := 0,oDlg:End()),nOpcA:=0)},{||oDlg:End()},,aButtons) 

RestArea(aAreaAnt)

Return(NIL)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³C050RIAI  ³ Autor ³Cleber L. Souza        ³ Data ³19/05/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se existe SkipLote e o tripo.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo Fornecedor								  ³±±
±±³			 ³ EXPN1 = Loja do Fornecedor 								  ³±±
±±³			 ³ EXPN2 = Codigo do Poduto 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T. - Existe Skip Lote 									  ³±±
±±³       	 ³ .F. - Nao existe Skip Lote 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEC050													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function c050RIAI(cFornec,cLjFornec,cProduto)
Local lRet     := .F.
Local aAreaAnt := GetArea()
Local aAreaQEF := QEF->(GetArea())

QEF->(dbSetOrder(1))
If QEF->(dbSeek(xFilial("QEF")+SA5->A5_SKPLOT))
	If QEF->QEF_UNSKLT == "L"
 	    lRet := .T.
	Else
		lRet := .F.
	EndIf
Else
    lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura as areas selecionadas								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaQEF)
RestArea(aAreaAnt)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³C050ConsEnt³ Autor ³Cleber L. Souza       ³ Data ³19/05/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Consulta Ultimas Entradas.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo Fornecedor								  ³±±
±±³			 ³ EXPC2 = Loja do Fornecedor 								  ³±±
±±³			 ³ EXPC3 = Codigo do Poduto 								  ³±±
±±³			 ³ EXPC4 = Mensagem 1       								  ³±±
±±³			 ³ EXPC5 = Mensagem 2       								  ³±±
±±³			 ³ EXPC6 = Mensagem 3       								  ³±±
±±³			 ³ EXPO7 = Objeto Mensagem 1								  ³±±
±±³			 ³ EXPO8 = Objeto Mensagem 1								  ³±±
±±³			 ³ EXPO9 = Objeto Mensagem 1								  ³±±
±±³			 ³ EXPC10 = Documento de Entrada        					  ³±±
±±³			 ³ EXPO11 = Objeto GetDados  								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T. - Existe Entradas									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEC050													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                   
Function C050ConsEnt(cCodFor,cLojFor,cProd,cMsg1,cMsg2,cMsg3,oMsg1,oMsg2,oMsg3,cDocEnt,oGetEnt,oMsg4,cMsg4)
Local lPrimDoc  := .t.
Local cAlias    := Alias()
Local nOldOrd   := IndexOrd()
Local nOrdSA5	:= SA5->(IndexOrd())
Local nOrdQEG   := QEG->(IndexOrd())
Local nOrdQEA   := QEA->(IndexOrd())
Local nOrdQEK   := QEK->(IndexOrd())

Local dDtTrab	:= dDataBase+1			//Define Data de Trabalho
Local nSklEnt	:= GetMv("MV_QSKLENT")	//"No. Entradas iniciais p/ aplicacao skip-lote"
Local nCntEnt	:= 0				    //Contador Entradas
Local nCntAte	:= 0					//Contador Entradas com Plano Atenuado
Local cGrupo	:= ""
Local aJustif	:= {}
Local nI		:= 0
Local cFatRep	:= ""  				    //Fator de reprova‡Æo
Local lRet		:= .T.
Local nVerifica := 1
Local cRevi		:= "00"
Local lAltEsp	:= .F.   
Local i      

Default cDocEnt := CriaVar("QEK_DOCENT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a Situacao do Produto x Fornecedor					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QEG->(dbSetOrder(1))
QEG->(dbSeek(xFilial("QEG")+SA5->A5_SITU))
If QEG->QEG_CATEG == "4" //Situacao nao recebe
	cMsg1 := STR0008 //"Situacao do Produto X Fornecedor tem Categoria Nao Recebe" 
	cMsg2 := STR0009 //" tem Categoria Nao Recebe"
	cMsg3 := ""
	cMsg4 := ""
	lRet  := .F.
EndIf

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Identifica o Fator Reprovado								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFatRep := Fator("3",.T.) //Reprovado Total           
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as condicoes para a Inspecao/Certificacao da Entrada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nCntEnt	:= 0	//Contador Entradas
	nCntAte	:= 0	//Contador Entradas com Plano Atenuado
	cGrupo	:= " "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Identifica o Grupo de Produtos								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QEA->(dbSetOrder(2))
	QEA->(dbSeek(xFilial("QEA")+cProd))
	QEA->(dbSetOrder(1))
	cGrupo := QEA->QEA_GRUPO
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Assume a Inspecao como padrao								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVerifica := 1	 //Inspecionar
	cVerifica := " "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o vetor utilizado para as Justificativas				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aJustif := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a Data de Validade do RIAI							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SA5->A5_VALRIAI) .And. dDtTrab > SA5->A5_VALRIAI
		cMsg1 := STR0010 //"Data de Validade do RIAI esta expirada."
		cMsg2 := ""
		cMsg3 := ""
		cMsg4 := ""
		lRet  := .F.
	EndIf
	
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Obtem a Revisao vigente do Produto							 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cRevi := QA_UltRevEsp(cProd,dDtTrab,.F.,,"QIE")
		If Empty(cRevi)
			cMsg1 := STR0011 //"Produto nao tem revisao vigente."
			cMsg2 := ""
			cMsg3 := ""
			cMsg4 := ""
			lRet	:= .F.
		EndIf		
	EndIf
	
EndIf

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza as consistencias iniciais para a Inspecao da Entrada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lAltEsp	 := .F.	//Indica 1a. Entrada apos alter. especif.
	A200CoIn(cCodFor,cLojFor,cProd,cRevi,dDtTrab,"LOTE_SIMULADO",;
		@aJustif,@nVerifica,@lAltEsp)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a Situacao e Categoria de Skip-Lote				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QEG")
	If QEG_CATEG == "1" .Or. QEG_CATEG == "2"
		If Len(aJustif) == 0	//Se houver Justif. p/ inspecao, nem verif. skip-lote

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplicacao da M\NBR5426 no Skip-Lote 						 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QEK")
			dbSetOrder(2)
			dbSeek(xFilial("QEK")+cCodFor+cLojFor+cProd)
			If GetMv("MV_QNBR542") == "S"
			   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica as ultimas 5 entradas com Plano Atenuado			 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				While QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT == ;
						xFilial("QEK")+cCodFor+cLojFor+cProd .And. !Eof()
				
					If QEK->QEK_TIPONF $ "DB" //Nao considera Beneficiamento e Devolucao
						QEK->(dbSkip())
						Loop
					EndIf	
					nCntEnt := nCntEnt + 1
					
				   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ realiza a pesquisa das 5 ultimas Entradas com Plano de Amos- ³
					//³ tragem Atenuada por Ensaio.									 ³ 
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					QF5->(dbSetOrder(1))
					If QF5->(dbSeek(xFilial("QF5")+QEK->QEK_CHAVE))                
						While QF5->(!Eof()) .And. QF5->QF5_CHAVE == QEK->QEK_CHAVE
							QF4->(dbSetorder(1))
							If QF4->(dbSeek(xFilial("QF4")+QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+QEK->QEK_REVI+QF5->QF5_ENSAIO))
								If SubStr(QF4->QF4_PLAMO,1,1) == "A"
									nCntAte++
									Exit
								EndIf
							EndIf	
							QF5->(dbSkip())
						EndDo
					EndIf            
					QEK->(dbSkip())
				EndDo
				
				If nCntEnt >= 5 .And. nCntAte == 5
				   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica o Skip-Lote da Entrada								 ³ 
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				 	nVerifica := QieSkipLote(cCodFor,cLojFor,cProd,cGrupo,dDtTrab,"LOTE_SIMULADO",cDocEnt,@aJustif)						
						
				Else
					Aadd(aJustif,OemToAnsi(STR0012)) //"Nao ha historico de 5 Entradas consecutivas" //"Nao ha historico de 5 Entradas consecutivas"
					Aadd(aJustif,OemToAnsi(STR0013)) //"com Plano Atenuado, para aplicacao Skip-Lote." //"com Plano Atenuado, para aplicacao Skip-Lote."
					Aadd(aJustif,OemToAnsi(STR0014)) //"A Entrada devera ser inspecionada." //"A Entrada devera ser inspecionada."
				EndIf
			Else
				If nSklEnt > 1
					dbSelectArea("QEK")
					While QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT == ;
							xFilial("QEK")+cCodFor+cLojFor+cProd .And. !Eof()
	  					If QEK->QEK_TIPONF $ "DB" //Nao considera Beneficiamento e Devolucao
							QEK->(dbSkip())
							Loop
						EndIf	

						nCntEnt := nCntEnt + 1
						If nCntEnt >= nSklEnt
							Exit
						EndIf
						QEK->(dbSkip())
					EndDo
					If nCntEnt >= nSklEnt
					   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica o Skip-Lote da Entrada								 ³ 
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					 	nVerifica := QieSkipLote(cCodFor,cLojFor,cProd,cGrupo,dDtTrab,"LOTE_SIMULADO",cDocEnt,@aJustif)						
					 	
					Else
						Aadd(aJustif,OemToAnsi(STR0015)) //"Nao ha o numero de Entradas iniciais " //"Nao ha o numero de Entradas iniciais "
						Aadd(aJustif,OemToAnsi(STR0016)) //"necessario para a aplicacao Skip-Lote." //"necessario para a aplicacao Skip-Lote."
						Aadd(aJustif,OemToAnsi(STR0014)) //"A Entrada devera ser inspecionada." //"A Entrada devera ser inspecionada."
					EndIf
				Else
				   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica o Skip-Lote da Entrada								 ³ 
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				 	nVerifica := QieSkipLote(cCodFor,cLojFor,cProd,cGrupo,dDtTrab,"LOTE_SIMULADO",cDocEnt,@aJustif)						
				 	
				EndIf
			EndIf
			
			dbSelectArea("QEK")
			dbSetOrder(1)
		EndIf
	EndIf
	
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o Skip-Teste										 ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nVerifica <> 1	//se for p/ Inspecionar, nem precisa verif. o skip-teste
	
	   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a 1a. Ocorr. do Doc por Fornecedor x Grupo          ³ 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lPrimDoc := .T.	 //1a. ocorrencia do Doc. Entrada p/ o fornecedor
		
		If !Empty(cDocEnt)
			//Verifica se ha' skip-teste definido por grupo
			dbSelectArea("QEI")
			dbSetOrder(1)
			If dbSeek(xFilial("QEI")+cCodFor+cLojFor+cGrupo)
				
				dbSelectArea("QEK")
				dbSetOrder(4)
				dbSeek(xFilial("QEK")+cDocEnt+cCodFor+cLojFor)
				
				While QEK->QEK_FILIAL+QEK->QEK_DOCENT+QEK->QEK_FORNEC+QEK->QEK_LOJFOR == ;
						xFilial("QEK")+cDocEnt+cCodFor+cLojFor .And. !QEK->(Eof())
					If QEK->QEK_TIPONF $ "DB" //Nao considera Beneficiamento e Devolucao
						QEK->(dbSkip())
						Loop
					EndIf	
			
					If QEK->QEK_GRUPO == cGrupo
						lPrimDoc := .F.
						Exit
					EndIf
					dbSkip()
				EndDo
				dbSetOrder(1)
			EndIf
		EndIf
		
		aEnsInsp := {}
		aEnsInsp := A200SkTe(cCodFor,cLojFor,cProd,lPrimDoc,cFatRep,@cRevi,lAltEsp)
		
	   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a Entrada atual pode ser certificada, caso haja  ³ 
		//³ definicao de Skip-Teste.									 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If GetMv("MV_QCERENT") == "N"
			For nI := 1 To Len(aEnsInsp)
				If aEnsInsp[nI,2] == 1
					nVerifica := 1
				EndIf
			Next nI
		EndIf
	EndIf
	
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Status para a proxima Entrada								 ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aJustif) == 0
		cMsg1 := Iif(nVerifica == 1,OemToAnsi(STR0017),; //"Entrada devera ser inspecionada." 
			OemToAnsi(STR0018))	   //"Entrada podera ser certificada." 
		cMsg2 := ""
		cMsg3 := ""
		cMsg4 := ""
	Else
		For i := Len(aJustif) to 4
			Aadd(aJustif,"")
		Next
		cMsg1 := aJustif[1]
		cMsg2 := aJustif[2]
		cMsg3 := aJustif[3]
		cMsg4 := aJustif[4]
	EndIf
EndIf
 
If ValType(oMsg1) == "O"
   oMsg1:Refresh()
EndIF   
If ValType(oMsg2) == "O"
   oMsg2:Refresh()
EndIF   
If ValType(oMsg3) == "O"
   oMsg3:Refresh()
EndIF   
If ValType(oMsg4) == "O"
   oMsg4:Refresh()
EndIF   
       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche o aCols com as Entradas selecionadas				 ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
c050UlEnt(M->A5_FORNECE,M->A5_LOJA,M->A5_PRODUTO,oGetEnt,,@oMsg1,@oMsg2,@oMsg3,@oMsg4,@cMsg1,@cMsg2,@cMsg3,@cMsg4)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura as areas 											 ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA5->(nOrdSA5)
QEG->(nOrdQEG)
QEA->(nOrdQEA)
QEK->(nOrdQEK)
dbSelectArea(cAlias)
dbSetOrder(nOldOrd)

Return(lRet) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³C050UlEnt  ³ Autor ³Cleber L. Souza       ³ Data ³19/05/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Preenche acols com as  Ultimas Entradas.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1  = Codigo Fornecedor								  ³±±
±±³			 ³ EXPC2  = Loja do Fornecedor 								  ³±±
±±³			 ³ EXPC3  = Codigo do Poduto 								  ³±±
±±³			 ³ EXPO4  = Objeto GetDados   								  ³±±
±±³			 ³ EXPC6  = Numero do Documento       			     		  ³±±
±±³			 ³ EXPO7  = Objeto Mensagem 1								  ³±±
±±³			 ³ EXPO8  = Objeto Mensagem 1								  ³±±
±±³			 ³ EXPO9  = Objeto Mensagem 1								  ³±±
±±³			 ³ EXPC10 = Mensagem 1                  					  ³±±
±±³			 ³ EXPC11 = Mensagem 2       								  ³±±
±±³			 ³ EXPC12 = Mensagem 3       								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL                  									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEC050													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function c050UlEnt(cCodFor,cLojFor,cProd,oGetEnt,cDoc,oMsg1,oMsg2,oMsg3,oMsg4,cMsg1,cMsg2,cMsg3,cMsg4)
Local nOrdQEK  := QEK->(IndexOrd())
Local nOrdQEL  := QEL->(IndexOrd())
Local cAlias   := Alias()
Local nOldOrd  := IndexOrd()
Local nX

aCols   := {}                                                      
cDocEnt := If(cDoc==NIL,cDocEnt,cDoc)    

dbSelectArea("QEK")
dbSetOrder(2)	
QEK->(dbSeek( xFilial("QEK")+cCodFor+cLojFor+cProd))
While !QEK->(Eof()) .and. QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT == xFilial("QEK")+cCodFor+cLojFor+cProd

	//Pesquisa o Laudo da Entrada	
	QEL->(dbSetOrder(3))
	QEL->(dbSeek(xFilial("QEL")+QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF+QEK->QEK_TIPONF+;
	DTOS(QEK->QEK_DTENTR)+QEK->QEK_LOTE+Space(TamSx3("QEL_LABOR")[1])))

		           
	If (lDocEnt .And. (QEK->QEK_DOCENT <> cDocEnt)) .Or. (QEK->QEK_TIPONF $ "DB")
       QEK->(dbSkip())
       Loop
    EndIF   
   	                 
	Aadd(aCols,Array(Len(aHeader)+1))   
    aCols[Len(aCols),nUsado+1] := .F.
	aCols[Len(aCols),nPosDat]  := QEK->QEK_DTENTR
	aCols[Len(aCols),nPosLot]  := QEK->QEK_LOTE
	aCols[Len(aCols),nPosIns]  := A200DICL(QEK->QEK_VERIFI,.f.)
	aCols[Len(aCols),nPosLau]  := IF(QEL->(Eof()),STR0026,QEL->QEL_LAUDO) //"N/A"
	aCols[Len(aCols),nPosNF]   := QEK->QEK_NTFISC //QEK->QEK_DOCENT
	aCols[Len(aCols),nPosAli]  := Alias()
	For nX := 1 To Len(aHeader)
		If IsHeadRec(aHeader[nX,2])
			aCols[Len(aCols),nPosRec] := QEK->(RecNo())
		EndIf
	Next nX

	QEK->(dbSkip())        
	
	If Len(aCols) >= If(mv_par01==0,5,mv_par01)
		Exit
	EndIf
	
EndDo

If Len(aCols) == 0 .and. lDocEnt 
   cMsg1 := STR0019  //"Documento não encontrado."
   cMsg2 := STR0020  //"Informe o Documento de Entrada Novamente."
   cMsg3 := ""
   cMsg4 := ""
   If ValType(oMsg1) == "O"
      oMsg1:Refresh()
   EndIF   
   If ValType(oMsg2) == "O"
      oMsg2:Refresh()
   EndIF   
   If ValType(oMsg3) == "O"
      oMsg3:Refresh()
   EndIF   
   If ValType(oMsg4) == "O"
      oMsg4:Refresh()
   EndIF   
EndIf

//Zera Valores da aCols se nao existirem entradas para o Fornecedor x Produto
If Len(aCols)==0
   Aadd(aCols,Array(Len(aHeader)+1))   
   aCols[Len(aCols),nUsado+1] := .F.
   aCols[Len(aCols),nPosDat] := CTOD("  /  /  ")
   aCols[Len(aCols),nPosLot] := ""
   aCols[Len(aCols),nPosIns] := ""
   aCols[Len(aCols),nPosLau] := ""
   aCols[Len(aCols),nPosNF]  := ""
EndIF
                      
If ValType(oGetEnt) == "O"
   oGetEnt:Refresh()
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura as areas											 ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QEK->(dbSetOrder(nOrdQEK))
QEL->(dbSetOrder(nOrdQEL))      	

dbSelectArea(cAlias)
dbSetOrder(nOldOrd)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³IncHead   ³ Autor ³Rafael S. Bernardi     ³ Data ³23/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Incluir alguns campos não usado no aHeader.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEC050													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IncHead()
Local aArea  := GetArea()
Local nOrdem := 0

If !Empty(GetSx3Cache("QEK_LAUDO","X3_CAMPO"))
	Aadd(aHeader,{AllTrim(QAGetX3Tit("QEK_LAUDO")),;
				  "QEK_LAUDO",;
				  GetSx3Cache("QEK_LAUDO","X3_PICTURE"),;
				  GetSx3Cache("QEK_LAUDO","X3_TAMANHO"),;
				  GetSx3Cache("QEK_LAUDO","X3_DECIMAL"),;
				  GetSx3Cache("QEK_LAUDO","X3_VALID"),;
				  GetSx3Cache("QEK_LAUDO","X3_USADO"),;
				  GetSx3Cache("QEK_LAUDO","X3_TIPO"),;
				  GetSx3Cache("QEK_LAUDO","X3_ARQUIVO"),;
				  GetSx3Cache("QEK_LAUDO","X3_CONTEXT")})
EndIf

dbSetOrder(nOrdem)
RestArea(aArea)

Return
