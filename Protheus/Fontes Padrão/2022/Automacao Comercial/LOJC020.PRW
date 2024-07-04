#INCLUDE "LOJC020.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCBROWSE.CH"

Static cNomArq 		:= "TRB"	//Nome da Tabela
Static oTabTemp		:= Nil		//Objeto tabela temporaria 
Static lLGPD 		:= Iif(ExistFunc("LjPDUse"),LjPDUse(),.F.) //Verifica se a funcionalidade de Dados Protegidos está sendo utilizada no sistema.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LOjc020  ³ Autor ³ Wagner Xavier         ³ Data ³ 06.06.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta de Vendas por Vendedor                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Gustavo      ³06/10/00³xxxxxx³Alteracao em totalizacao da consulta,   ³±±
±±³              ³        ³      ³e remodelagem.                          ³±±
±±³ Edilson      ³17/10/02³060512³Removida a declaracao da variavel       ³±±
±±³              ³        ³      ³L1_TXMOEDA e declarado o campo L1_VLRTOT³±±
±±³Fernando  	 ³13/12/06³9.12  ³Bops115311 Alterado a array aRotina para³±±
±±³              ³        |      ³ criação do menu funcional              ³±±
±±³Danilo Calil  ³24.04.07³123219³Alterado o tamanho da PesqPict dos campo³±±
±±³              ³        ³      ³L2_VLRUNIT, L1_VLRTOT.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LojC020()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa	     ³
//³ ----------- Elementos contidos por dimensao ------------	 ³
//³ 1. Nome a aparecer no cabecalho							     ³
//³ 2. Nome da Rotina associada 								 ³
//³ 3. Usado pela rotina										 ³
//³ 4. Tipo de Transa‡„o a ser efetuada						     ³
//³		1 - Pesquisa e Posiciona em um Banco de Dados		     ³
//³		2 - Consulta Vendas do Vendedor no periodo			     |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Pesquisar / Visualizar
Private aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabe‡alho da tela de atualiza‡”es 				     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Consulta de Vendas por Vendedor
Private cCadastro := STR0003

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE 								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"SA3" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
msUnlockAll( )   

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef	³ Autor ³ Fernando Amorim       ³ Data ³13/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef() 

Local aRotina:= { 		{ STR0001 ,"AxPesqui", 0 , 1 , , .F.},;	//Pesquisar
						{ STR0002 ,"lj020Vis", 0 , 2 , , .T.} }   //Visualizar
													
Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ lj020Vis ³ Autor ³ Wagner Xavier         ³ Data ³ 07.06.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Vendas por Vendedor.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ lj020Vis(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function lj020Vis( cAlias,nReg,nOpcx )
Local dDataC020:=CtoD("  /  /  ")
Local dDataA020:=CtoD("  /  /  ")
Local oDlg, oDlg1, ni :=1, oCol, oBrw, aBrowse := {}
Local oNomeVend := Nil
Local nAlias	:= 0

Private nTotal	:=0,nCredito := 0,nTotVend := 0, aCampos := {}

nOpca := 0
// Periodo
DEFINE MSDIALOG oDlg1 FROM  36,1 TO 172,288 TITLE OemToAnsi(STR0004) PIXEL

@  0, 4 TO 51, 139 OF oDlg1  PIXEL
@  9, 8 SAY STR0005 SIZE 35, 8 OF oDlg1 PIXEL // Data Inicial
@ 24, 8 SAY STR0006 SIZE 35, 8 OF oDlg1 PIXEL // Data Final
@ 10,48 MSGET dDataC020 Valid !Empty( dDataC020 )	SIZE 41, 7 OF oDlg1 PIXEL
@ 25,48 MSGET dDataA020 Valid dDataA020>=dDataC020 SIZE 41, 7 OF oDlg1 PIXEL

DEFINE SBUTTON FROM 09,100 TYPE 1 ACTION (nOpca := 1,;
									Iif(lj020Ins(dDataC020,dDataA020),;
									oDlg1:End(),nOpca:=0)) ENABLE OF oDlg1
DEFINE SBUTTON FROM 25,100 TYPE 2 ACTION oDlg1:End() ENABLE OF oDlg1
ACTIVATE MSDIALOG oDlg1 CENTERED
If nOpca == 0
	Return
Endif
dbSelectArea(cNomArq)
(cNomArq)->(dbGoTop())
nAlias := Select(cNomArq)
If (cNomArq)->(RecCount()) > 0

	// Produto - Prod / Descricao - Desc / Quantidade - Quant
	// Preco Unitario - Preco

	aBrowse := { { STR0007,"PROD"	,"@X"				,30 },;
					{   STR0009,"DESCRI","@X"				,70 },;
					{   STR0011,"QUANT"	,"999999.99"	,45 },;
					{   STR0013,"PRECO"	,PesqPict("SL2","L2_VLRITEM"),63 } }

		nOpca := 0
		// Consulta a vendedores
		DEFINE MSDIALOG oDlg FROM 22,1 TO 400,526 TITLE STR0015 PIXEL

		@  0, 4 TO  34, 224 OF oDlg PIXEL
		@141, 4 TO 187, 224 OF oDlg PIXEL

		// C¢digo:
		@ 8, 9	 SAY OemtoAnsi(STR0016)  SIZE 26, 8 OF oDlg PIXEL
		@ 7, 39  MSGET SA3->A3_COD	WHEN .F. SIZE 29, 8 OF oDlg PIXEL
		@ 7, 95  MSGET oNomeVend VAR SA3->A3_NOME WHEN .F. SIZE 124, 8 OF oDlg PIXEL
		If lLGPD .And. LjPDCmpPrt("LQ_NOMVEND")
			LjPDOfuscar(oNomeVend, "LQ_NOMVEND")
		EndIf
		@ 21, 9  SAY OemtoAnsi(STR0017) SIZE 26, 8 OF oDlg PIXEL // Per¡odo
		@ 21, 86  SAY "a" SIZE 4, 8 OF oDlg PIXEL
		@ 21, 39  MSGET dDataC020 WHEN .F. SIZE 41, 8 OF oDlg PIXEL
		@ 21, 95  MSGET dDataA020 WHEN .F. SIZE 41, 8 OF oDlg PIXEL
		@148.5, 9 SAY OemtoAnsi(STR0018) SIZE 88, 8 OF oDlg PIXEL // Total de Mercadorias :
		@147.5, 168 MSGET nTotal PICTURE PesqPict("SL2","L2_VLRITEM",13) WHEN .F. SIZE 53, 8 OF oDlg PIXEL
		@160, 9   SAY OemtoAnsi(STR0019) SIZE 88, 8 OF oDlg PIXEL // Total de Credito 
		@160, 168 MSGET nCredito PICTURE PesqPict("SL1","L1_VLRTOT",13) WHEN .F. SIZE 53, 8 OF oDlg PIXEL			 
		@172, 9   SAY OemToAnsi(STR0020) SIZE 88, 8 OF oDlg PIXEL // Total de Vendas
		@172, 168 MSGET nTotVend PICTURE PesqPict("SL1","L1_VLRTOT",13) WHEN .F. SIZE 53, 8 OF oDlg PIXEL			 			 

	@ 39, 4 COLUMN BROWSE oBrw SIZE 220,100.1  PIXEL OF oDlg
	For ni := 1 To Len(aCampos)
		If ni>=3
			DEFINE COLUMN oCol DATA FieldWBlock(aBrowse[ni][2],nAlias) ;
				HEADER OemToAnsi(aBrowse[ni][1]) PICTURE aBrowse[ni][3] ;
				SIZE aBrowse[ni][4] 
		Else
			DEFINE COLUMN oCol DATA FieldWBlock(aBrowse[ni][2],nAlias) ;
				HEADER OemToAnsi(aBrowse[ni][1]) PICTURE aBrowse[ni][3] ;
				SIZE aBrowse[ni][4] 
		EndIf
		oBrw:ADDCOLUMN(oCol)
	Next ni
	DEFINE SBUTTON FROM 1.5,230 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
	DEFINE SBUTTON FROM 17,230 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED
Else
	Help("",1,"LJ020NOREC")

EndIf

dbSelectArea(cNomArq)
(cNomArq)->(DbCloseArea())

//Elimina arquivos de trabalho
If oTabTemp <> NIL
	oTabTemp:Delete()
	oTabTemp := NIL
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura integridade dos dados.															³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "SL2" )
dbSetOrder( 1 )		//L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ lj020Ins ³ Autor ³ Alice Yaeko Yamamoto  ³ Data ³ 06.06.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria Arquivo Temporario e Insere dados no arq.temporario   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³                         ATUALIZACOES SOFRIDAS                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³           Motivo da Alteracao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Magh Moura  ³23/08/05³085751³Tamanho dos Campos para o array aCampos   ³±±
±±³            ³        ³      ³idem ao tamanho definido no SX3 e nao     ³±±
±±³            ³        ³      ³mais tamanhos fixos.                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function lj020Ins(dDataC020,dDataA020)
Local nIndex    := 0 
Local nTotalPar := 0
Local cIndex    := ""
Local cChave    := ""
Local cNum      := "" 

//Localizacoes
Local nMoeda    := 1
Local aTesImpInf
Local nDecs 	:= MsDecimais(1)
Local nImposto
Local nI
Local nValItem  := 0
Local cNumAnt 	:= ""

If Empty(dDataC020) .Or. Empty(dDataA020)
	Return .F.
Endif

aCampos:={	{"PROD" 	,"C"	,TamSx3("L2_PRODUTO")[1], TamSx3("L2_PRODUTO")[2] },;
			{"DESCRI" 	,"C"	,TamSx3("L2_DESCRI")[1],  TamSx3("L2_DESCRI")[2]  },;
			{"QUANT"	,"N"	,TamSx3("L2_QUANT")[1],   TamSx3("L2_QUANT")[2]   },;
			{"PRECO"	,"N"	,TamSx3("L2_VLRITEM")[1], TamSx3("L2_VLRITEM")[2] }}
			
oTabTemp := LjCrTmpTbl(cNomArq, aCampos)
dbSelectArea(cNomArq)
(cNomArq)->(dbGoTop())

While .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Localiza vendas no periodo inicial 												 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIndex:= CriaTrab(Nil,.F.)
	cChave:= "L2_FILIAL+L2_VEND+DTOS(L2_EMISSAO)"
	IndRegua("SL2",cIndex,cChave,,,"Selecionando Registros...")

	nIndex:= RetIndex("SL2")
	dbSelectArea( "SL2" )

	#IFNDEF TOP
		SL2->(dbSetIndex(cIndex+OrdBagExt()))
	#ENDIF
	SL2->(dbSetOrder(nIndex+1))

	If !(dbSeek( xFilial("SL2")+SA3->A3_COD ),.T. )
		Help( " ", 1, "SEMVENDA" )
		Exit
	EndIf

	SL1->( DBSetOrder( 1 ) )		//L1_FILIAL+L1_NUM 

	SL2->(dbSeek( xFilial("SL2")+SA3->A3_COD+DtoS(dDataC020), .T. ))
	
	cNum := SL2->L2_NUM
	
	While !Eof( ) .And. (SL2->L2_FILIAL == xFilial("SL2")) .And. (SL2->L2_VEND == SA3->A3_COD) .And. (SL2->L2_EMISSAO <= dDataA020) 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se e' uma venda, ou apenas ou or‡amento.            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SL2->L2_NUM <> cNumAnt
			SL1->( DbSeek( xFilial("SL1")+SL2->L2_NUM ) )
			cNumAnt := SL2->L2_NUM
		EndIf

		If SL2->L2_ENTREGA == '2' .And. Empty( SL1->L1_DOC )
			SL2->(dbSkip( ))
			Loop
		//Quando for Retira Posterior, Entrega ou Retira Posterior com Pedido
		//o cliente já pagou e gerou título no ato da compra
		//Nesse ponto eu desconsidero quando é emitido o doc, pra não gerar valor duplicado
		ElseIf SL2->L2_ENTREGA $ '1|3|4' .And. (!Empty( SL1->L1_DOC ) .Or. !(Empty(SL1->L1_ORCRES)))  
			SL2->(dbSkip( ))
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se houve devolucao 											  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (SL2->L2_STATUS == "D")
			nCredito += SL2->L2_VLRITEM + SL2->L2_VALIPI
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Localiza produto.														  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SB1->(DbSetOrder( 1 ))				//B1_FILIAL+B1_COD
		SB1->(DbSeek( xFilial("SB1")+SL2->L2_PRODUTO ))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula valor da venda em dolar.										³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea(cNomArq)
		RecLock(cNomArq,.T.)
		(cNomArq)->PROD :=SL2->L2_PRODUTO
		(cNomArq)->DESCRI :=SL2->L2_DESCRI
		(cNomArq)->QUANT:=SL2->L2_QUANT

		If cPaisLoc == "BRA"
			(cNomArq)->PRECO:=SL2->L2_VLRITEM + (SL2->L2_VALIPI / SL2->L2_QUANT)
			nTotal    += SL2->L2_VLRITEM + SL2->L2_VALIPI
			nTotalPar += SL2->L2_VLRITEM + SL2->L2_VALIPI
		Else
			nMoeda 		:= Max( SL1->L1_MOEDA, 1 )
			aTesImpInf 	:= TesImpInf( SL2->L2_TES )
			nImposto		:= 0      
			
			For nI := 1 To Len( aTesImpInf )
				cCampo 	 := Iif( aTesImpInf[nI][3] == "1", "SL2->L2_"+Substr( aTesImpInf[nI][2], 4 ), "0" )
				nImposto	+= Round(xMoeda(&cCampo,nMoeda,1,SL2->L2_EMISSAO,nDecs+1,SL1->L1_TXMOEDA),nDecs)
			Next nI
            
			nValItem            := Round(xMoeda(SL2->L2_VLRITEM,nMoeda,1,SL2->L2_EMISSAO,nDecs+1,SL1->L1_TXMOEDA),nDecs)
			(cNomArq)->PRECO	    := nValItem + nImposto                        
			nTotalPar  			+= cNomeArq->PRECO
			nTotal    			+= cNomeArq->PRECO
		EndIf
		
		dbSelectArea( "SL2" )
		dbSkip()             

		If cNum # SL2->L2_NUM 
			nTotalPar := 0						
			cNum      := SL2->L2_NUM				
		EndIf
	End                     
	dbSelectArea(cNomArq)
	Exit
End

nTotVend := nTotal - Abs(nCredito)

dbSelectArea("SL2")
Set Filter To
RetIndex("SL2")
Ferase (cIndex+OrdBagExt())

Return .T.
