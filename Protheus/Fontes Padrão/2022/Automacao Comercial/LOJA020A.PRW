#INCLUDE "LOJA020A.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"              
                                    
#DEFINE Confirma 1
#DEFINE Abandona 2
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LOJA020  ³ Autor ³ Vendas Clientes		³ Data ³ 15/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa utilizado para efetuar troca e devolucao de Merca-³±±
±±³          ³ dorias no Windows                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LOJA020()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Loja020()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea        	:= GetArea()
Local cLock 		:= cUserName+cEstacao


Local aCores		:= { {'!Empty(L1_DOC) .AND.  Empty(L1_DOCPED) .AND.L1_STATUS="T"',	"BR_BRANCO"  },;
						 {'!Empty(L1_DOC) .AND.  Empty(L1_DOCPED) .AND.L1_STATUS="D"',	"BR_MARRON"  },;
						 {'!Empty(L1_DOC) .AND.  Empty(L1_DOCPED) .AND.L1_STATUS<>"D"',	"BR_VERMELHO"},;
				 		 { 'Empty(L1_DOC) .AND.  Empty(L1_DOCPED) .AND.L1_STATUS<>"D"',	"BR_VERDE"   },;
				 		 { 'Empty(L1_DOC) .AND. !Empty(L1_DOCPED) .AND.L1_STATUS<>"D"',	"BR_AZUL"    }}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso seja Brasil direciona para rotina de Troca Loja720³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cPaisLoc == "BRA"
	If !(Ls_GetId() == 2100003279 .AND. dDatabase <= CTOD("30/04/2009") ) 
		Loja720()
		Return(.T.)
	EndIf	
Endif


// Protege rotina para que seja usada apenas no SIGALOJA / Front Loja
If ! AmIIn(12) .AND. ! AmIIn (23) .AND. ! AmIIn (72)
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o controle via LockByName para evitar que um usuário acesse       ³
//³ 2 vezes uma rotina que use os periféricos de automação, evitando assim³
//³ a concorrência dos mesmos.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SetMDIChild( 0 ) .AND. !LockByName( cLock )
	Return Nil
Endif

Private cConfCli	:= SuperGetMV("MV_CONFCLI")
Private lSayWin    	:= .T.
Private lEntry 	   	:= (ExistBlock("LJ010FIN"))
Private lLoja020   	:= (ExistBlock("LOJA020"))
Private cCadastro  	:= STR0001 						// Troca de Mercadorias
Private cHistCh    	:= " "                 			//Utilizando em ponto de Entrada
Private cSenhaAnt  	:= cSenha
Private cNivelSup  	:= cNivel
Private cNivelSup2 	:= cNivel
Private lTroca 	   	:= .F.
Private lDevoluca  	:= .F.
Private lCnd	   	:= .F.
Private lFirst 	   	:= .F.
Private lTrocLoja  	:= .F.
Private lCombo     	:= .T.
Private cFormPro   	:= "S"  						// MUDOU
Private cScriptTro 	:= SuperGetMV("MV_SCRTROC")  	//FE
Private lGrade     	:= .F. 							//Nao ha grade para troca
Private lGradProd  	:= .F.
Private lPrecoBal  	:= .F.
Private aFrete     	:= { 0, 0, 0 } 					// Contem os valores do frete, seguro e despesa, respectivamente.
Private aRetencoes 	:= {}                			// Contem os valores de PIS/COFINS/CSLL (retencoes)
Private nVlrFSD    	:= 0	  						//Valor do Frete + Seguro + Desp.Acessorias
Private lVlrFSD	   	:= .T. 							// Indica se o valor do frete sera lancado no total da venda (Por default sempre serah) - Utilizada na venda balcao
Private nMoedaCor  	:= 1
Private nMoedaTR 	:= 1
Private nDecimais  	:= MsDecimais(nMoedaTr)


// Variaveis para o Acols

Private nPosUnit	:= 0
Private nPosTotal	:= 0
Private nPosValDes	:= 0
Private nPosDesc	:= 0
Private nPosTes		:= 0
Private nPosValIcm	:= 0
Private nPosValIPI	:= 0
Private nPosValIss	:= 0
Private nPosProd	:= 0       
Private nPosCProd	:= 0		// Posicao do produto na GETDADOS. Utilizada na chamada da consulta do LOTE (SB8)
Private nPosDescri	:= 0
Private nPosTabela	:= 0
Private nPosQuant	:= 0
Private nPosBsIcms	:= 0
Private nPosLocal	:= 0
Private nPosItem	:= 0
Private nPosUm		:= 0
Private nPosPrcTab	:= 0
Private nPco		:= 0  		//Por causa da concomitancia
Private nPosDscPro  := 0
Private nPosBrICMS  := 0 		//Base do Icms Solidario
Private nPosIcmsRet := 0 		//Valor do Icms Solidario

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Impressora fiscal e/ou compatibilizacao com Loja010³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cNumPdv	    := Space(10)
Private aIcms	    := {}
Private lGaveta     := !Empty(LjGetStation("GAVETA"))
Private cConcomit   := "N" //Por causa da concomitancia
Private lUsaCmc7    := !Empty(LjGetStation("CMC7"))
Private lVendaRapida:=.F. //Por causa da concomitancia
Private cCartao     := Space(3)
Private cOrcamen    := ""
Private lSrvCns     := .F.

Private aTabelas    := {{"1",0},;
						{"2",0},;
						{"3",0},;
						{"4",0},;
						{"5",0},;
						{"6",0},;
						{"7",0},;
						{"8",0},;
						{"9",0} }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Objetos TEF      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nValorBase	:= 0
Private nEntrada	:= 0
Private aTefDados	:= {}
Private aParcTef	:= {}
Private aTefMult	:= {}
Private cGaranch	:= ""
Private aCartaoMH 	:= {}
Private cCalcImpV  	:= SuperGetMV("MV_GERIMPV")

If ! cPaisLoc == "BRA"
	Private aDescontos := {}
	Private aImpVarSF2 := {}
	Private aImpVarSD2 := {0,0,0,0,0,{}}
	Private aImpCusto  := {}
	Private aImpVarDup := {}
	Private nValTotIV  := 0
	Private nValBaseIV := 0
	PRIVATE lLancPad10 := lLancPad20 := .F.
	PRIVATE nHdlPrv    := 1, cLoteFat := "", nTotal := 0
	PRIVATE cEspecie   := Criavar("L2_SERIE")
	PRIVATE cTipo      := "N"

	cEspecie  := "NF"
	
	lDigita   := .F.
	lJunta    := .F.
	lGeraLanc := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³UTILIZADO NA VENDA BALCAO CONCOMITANTE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lVendConc	:= If(!lFiscal,.F.,GetNewPar("MV_LJVBCC",.F.))	//Indica se o cliente utiliza a Vda Balcao Concomitante
Private nItensImp	:= 0												//Quantidade de itens impressos no ECF para Venda Concomitante
Private cNumCupFis 	:= Space(TamSx3("L1_DOC")[1])						//Número do Cupom Fiscal

If lFiscal
	
	LjMsgRun("Aguarde, checando a impressora fiscal !!",,{|| aIcms := LjSetAliq(),;
	CLR_HRED } )
	
EndIf


PRIVATE aRotina := MenuDef() 
Private npValISS    := 0
Private lpTPAbISS   := ( GetNewPar("MV_TPABISS", "1") == "2" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A ocorrencia 31 (ACS), verifica se o usu rio poder  ou n„o   ³
//³ efetuar uma Troca.														  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ChkPsw( 31 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endere‡a a fun‡„o de BROWSE	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea( "SL1" )
	DbSetorder( 2 )
	cCadastro:=cCadastro
	mBrowse( 6, 1,22,75,"SL1",,,,,, aCores )
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsUnlockAll( )
DbSelectArea( "SL1" )
DbSetorder( 1 )
DbSelectArea( "SL2" )
DbSetorder( 1 )

RestArea(aArea)
Return( Nil )    


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef   ³ Autor ³ Vendas Clientes		³ Data ³08/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef() 
Local aRotina:= {	{ STR0071 , "AxPesqui"   , 0 , 1 , , .F.},;	// Pesquisar    
					{ STR0072 , "LJ040Con"   , 0 , 2 , , .T.},;	//Visualizar
					{ STR0073 , "lj020Troca" , 0 , 4 , , .T.},;	// Troca da Loja 
					{ STR0074 , "lj020TrocL" , 0 , 3 , , .T.},;	// Outra Loja
					{ STR0081 , "Lj020Leg"   , 0 , 8 , , .T.}}		// Legenda



Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ lj020Troc³ Autor ³ Vendas Clientes		³ Data ³ 18.11.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Troca de Mercadorias / Devolu‡„o da Loja       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ lj020Troca                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
         
*/
Function lj020Troca()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local aCols_1
Local aHeader_1
Local nI			:= 0 
Local nX 			:= 0
Local nC 			:= 0
Local nE           	:= 0
Local cAliasAtu		:= ""
Local nTotTroca		:= 0
Local nBicms		:= 0
Local nVlrIcms 		:= 0
Local lRet			:= .T.
Local oBtn1
Local oBtn2
Local nDelet		:=0
Local lOkTroca 		:= .T.
Local cNumAnt  		:= Space(TamSx3("L1_DOC")[1])
Local cSerAnt 		:= Space(TamSx3("L1_SERIE")[1])
Local cDatAnt 		:= CtoD("")
Local cFilAux 		:= ""
Local cPdvAnt       := ""
Local aColsDev 		:= {}
Local nPos 			:= 0
Local cL1_Doc		:= Space(TamSx3("L1_DOC")[1])
Local cL1_Serie		:= Space(TamSx3("L1_SERIE")[1])
Local lContinua     := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis de Comissao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nBaseComis   	:= 0                     //Valor Base para Comissao do vendedor.
Local nDecs       	:= MsDecimais( 1 )

Local cPrefixo 		:= ""
Local oMoedaTr
Local cMoedaTr		:= ""
Local oTaxaTr
Local cPictTr		:= ""
Local aEditCpos   	:= {}
Local aImposto    	:= {}
Local nVlrTroca 	:= 0
Local aColsPed 		:= {}
Local nPosFilRes 	:= 0
Local nPosOrcRes 	:= 0
Local nPosItem		:= 0
Local nPosProduto	:= 0
Local nPosReserva	:= 0
Local cReserva      := ""
Local cFormDev      := ""
Local cValidCol		:= ".T."

Private nCredito 	:= 0
Private oDlg1
Private lExistNota	:= .F.
Private aPosicoes[0]
Private aHeader[0]
Private aCampos[0]
Private nRegOri 	:= SL1->(RecNo())
Private cCliEntrega := ""
Private cLojEntrega := ""


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis private inicializadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oCliente 
Private oLoja 
Private oDesc 
Private oGet 
Private oMerc 
Private oTroc  
Private oTItens  
Private oBmp
Private cNumNota	:= Space(TamSx3("L1_DOC")[1])
Private cSerie 		:= Space(TamSx3("L1_SERIE")[1])
Private cDatEmi     := CtoD("")
Private cNumPdv		:= Space(TamSx3("L1_DOC")[1])
Private cOrcAnt     := SL1->L1_NUM               
Private cLoja		:= SuperGetMV("MV_LOJAPAD")
Private cCliente	:= SuperGetMV("MV_CLIPAD")
Private cCliAnt		:= ""
Private cLojAnt		:= ""
Private cComprou	:= "S"
Private cDescCli	:= ""
Private nDescont	:= 0
Private nTroc		:= 0
Private nMerc		:= 0
Private nTItens     := 0
Private nRegAnt		:= ""
Private nOpc		:= 4
Private nLinGetdados:= 15
Private nTabela		:= Int(Val(SuperGetMV( "MV_TABPAD" ) ) )
Private lOk 		:= .T.
Private cSerieDev 	:= Space(TamSx3("L1_SERIE")[1])
Private cNumTroc	:= Space(TamSx3("F1_DOC")[1])
Private nUsado 		:= 0
Private cNum_troca	:= Space(TamSx3("F1_DOC")[1])
Private cSerie_tro	:= Space(TamSx3("L1_SERIE")[1])
Private lComprou	:=.T.
Private cx3Valid    := ""		// usado na MSGETDADOS
Private nTaxaMoeda  := Criavar("M2_MOEDA1")
Private nMoedaTr 	:= 1

If cPaisLoc <> "BRA"
   Private aImpVarSF1 := {}
   Private aImpVarSD1 := {0,0,0,0,0,{}}
   Private cNFiscal   
   Private aLivroF    := {}
   Private aPosImps   := {}  
   Private nTaxaTr
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a variavel do frete                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFrete     := { 0, 0, 0 } 		// Contem os valores do frete, seguro e despesa, respectivamente.
aRetencoes := {}    		    // Contem os valores do frete, seguro e despesa, respectivamente.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o caixa esta aberto, senao nao deixa fazer a troca ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ljCxAberto()
	Return
EndIf

lTrocLoja:=.T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Existe o Paramentro de Tes de TROCA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTesTroca:=SuperGetMV("MV_TESTROCA")
If cTesTroca == NIL
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o Tes 132 Como Troca ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	PutMv( "MV_TESTROCA" , "132" )
	
	cTesTroca := "132"
	
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader com os campos da troca  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("Sx2")
DbSeek("SL2")
DbSelectArea("Sx3")
DbSeek( "SL2" )
While !Eof() .AND. (X3_ARQUIVO == "SL2")
	IF (X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .AND. Alltrim(X3_CAMPO)<>"L2_NUM") .OR. Alltrim(X3_CAMPO) == "L2_ITEM"
		nUsado++ 
		&('M->'+Alltrim(X3_CAMPO)):=(" SL2->"+X3_CAMPO)
		cx3Valid:=x3_Valid
		If Alltrim(X3_CAMPO) == "L2_QUANT"
			cX3Valid:="VQuant()"
		Endif
		If (cPaisLoc <> "BRA") .AND. (Alltrim(X3_CAMPO) == "L2_TES")
			cX3Valid := "ValTES()"
		ElseIf (cPaisLoc <> "BRA") .AND. (Alltrim(X3_CAMPO) == "L2_PRODUTO")
			cX3Valid := "Lj020ValProd()"		
		Endif
		Aadd(aHeader,{ TRIM(X3Titulo()), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL, cX3Valid,;
		X3_USADO, X3_TIPO, X3_ARQUIVO } )
		Aadd( aCampos, X3_CAMPO )
		//Armazena as posicoes dos campos de impostos(bas e e valor) para posterior gravacao na fatura de compras
		If cPaisLoc <> "BRA" .AND. (Substr(X3_CAMPO,4,6) == "BASIMP" .OR. Substr(X3_CAMPO,4,6) == "VALIMP")
		   Aadd(aPosImps,{X3_CAMPO,nUsado})
		EndIf
	End
	DbSkip()
End

Private aCOLS[1][nUsado+1], aQtde := {}
Private aFirst[1][nUsado+1]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as Posicoes dos Campos no aHeader	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lj020Pos()
lj010Pos()

nUsado:=0
DbSelectArea("SX3")
DbSeek( "SL2" )
While !Eof() .AND. X3_ARQUIVO == "SL2"
	If (x3Uso(X3_USADO) .AND. cNivel >= X3_NIVEL .AND.	Alltrim(X3_CAMPO)<>"L2_NUM") .OR. Alltrim(X3_CAMPO) == "L2_ITEM"
		nUsado++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Array de 1 elemento ³
		//³ vazio. Se inclus„o. 		³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If X3_TIPO == "C"
			aCOLS[1][nUsado] := SPACE(X3_TAMANHO)
		ElseIf X3_TIPO == "N"
			aCOLS[1][nUsado] := 0
		ElseIf X3_TIPO == "D"
			aCOLS[1][nUsado] := dDataBase
		Else
			aCOLS[1][nUsado] := .F.
		EndIf
	EndIf
	DbSkip()
End
aCOLS[1][nUsado+1] := .F.

DEFINE MSDIALOG oDlg1 FROM 15,2 TO 320,565 TITLE cCadastro PIXEL //495
lCnd:=.F.
@ 17,001 TO 40,277 LABEL STR0001 OF oDlg1 PIXEL // Troca de Mercadorias
If File("Bombe.bmp")
	@	0.4,25 BITMAP oBmp FILE "BombE.bmp" OF oDlg1 NOBORDER SIZE 20,20
	oBmp:lStretch:=.T.
EndIf

@ 24,003 SAY STR0004 OF oDlg1 PIXEL                // Cliente
@ 24,126 SAY "-"     OF oDlg1 PIXEL
@ 24,156 SAY STR0005 OF oDlg1 PIXEL                // Nome
@110,002 TO  132,277 LABEL STR0006 OF oDlg1 PIXEL  // Totais
@118,010 SAY STR0007 OF oDlg1 PIXEL                // Mercadorias :
@118,113 SAY STR0008 OF oDlg1 PIXEL                // Troca :
@118,200 SAY STR0076 SIZE 40, 8 OF oDlg1 PIXEL     // Total de Itens :

@ 24,030 MSGET oCliente VAR cCliente  SIZE  90, 8	OF oDlg1 PIXEL Picture "@!" Valid LjCreCli(cCliente, cLoja, @cCliAnt, @cLojAnt, oDlg1, , .T.) .AND. Lj020Desc(@cDescCli,oDesc,cCliente,cLoja) .AND. If(ExistBlock("LJ020CLI"),ExecBlock("LJ020CLI",.F.,.F.),.T.)
@ 24,130 MSGET oLoja 	VAR cLoja	  SIZE  8, 8	OF oDlg1 PIXEL Picture "@!" Valid LjCreCli(cCliente, cLoja, @cCliAnt, @cLojAnt, oDlg1, , .T.) .AND. Lj020Desc(@cDescCli,oDesc,cCliente,cLoja)
@ 24,175 MSGET oDesc 	VAR cDescCli  SIZE 99, 8  OF oDlg1 PIXEL When .F. Picture "@!"
@117,047 MSGET oMerc VAR nMerc Picture PesqPict("SL1","L1_VALMERC") SIZE 60,8 OF  oDlg1 PIXEL When .F. RIGHT
@117,133 MSGET oTroc VAR nTroc Picture PesqPict("SL1","L1_VALBRUT") SIZE 60,8 OF oDlg1 PIXEL When .F. RIGHT
@117,237 MSGET oTItens VAR nTItens Picture "@E 99999" SIZE 20, 8 OF oDlg1 PIXEL When .F. RIGHT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Moeda/Taxa          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA"
    aEditCpos:= {"L2_QUANT","L2_TES"}
	nMoedaTr := If(SL1->L1_MOEDA <> 0,SL1->L1_MOEDA,1)
	cMoedaTr := Eval( MemVarBlock( "MV_MOEDA" + STR( nMoedaTr, 1 ) ) )
	nTaxaMoeda  := SL1->L1_TXMOEDA			
	nTaxaTr  := SL1->L1_TXMOEDA
	cPictTr  := PesqPict("SL1","L1_TXMOEDA",15)
	@ 135,010 SAY	STR0079	SIZE 22,07	OF oDlg1	PIXEL 			//"Moneda"
	@ 135,047 MSGET	oMoedaTr VAR cMoedaTr 	SIZE 60,08	OF oDlg1 PIXEL WHEN .F.
	@ 135,113 SAY 	STR0080 SIZE 18,07	OF oDlg1 PIXEL 			//"Tasa"
	@ 135,133 MSGET	oTaxaTr VAR nTaxaTr 		SIZE 60,08	OF oDlg1 PIXEL WHEN .F.	Picture cPictTr
Else
   aEditCpos     := {"L2_QUANT"}
EndIf
oGet:= MSGetDados():New(44,1,109,278,nOpc,"Lj020EvaLi","Lj020TudOk","",.T.,aEditCpos,,,Len(aCols))
                                    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Na Deleção do item deverá somar o valor do ICMS Solidario se tiver ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet:oBrowse:bDelete := { || aCols[n,Len(Acols[n])] := !aCols[n,Len(Acols[n])],oGet:LinhaOk(),;
                             oGet:oBrowse:Refresh(.F.),Lj020Evali(),;
                             If( Len(aRetencoes)>0, aRetencoes[n,Len(aRetencoes[n])] := ! aRetencoes[n,Len(aRetencoes[n])], .T.) ,;
                             nMerc+=If(aCols[n,Len(Acols[n])],-1,1)*(aCols[n,nPosTotal]+;
                             If(LJ020ICMSSol(aCols[n,nPosTes])[1],aCols[n,nPosIcmsRet],0) +aCols[n,nPosValIPI]),;
                             nTroc:=(nMerc-LJ020SumRet()-(aFrete[1]+aFrete[2]+aFrete[3])),;
                             oMerc:Refresh(), oTroc:Refresh() }

If cPaisLoc == "BRA"
	cValidCol	:=	"oGet:LinhaOk(), nMerc := 0, "+;
					"aEval(aCols, { |x| nMerc += If(x[Len(x)],0,x[nPosTotal]) }),"+;
					"nTroc:=(nMerc-LJ020SumRet()-(aFrete[1]+aFrete[2]+aFrete[3])),"+;
					"oMerc:Refresh(), oTroc:Refresh(), .T."
Else
	cValidCol    := "Lj020ValProd(),oGet:LinhaOk(),.T."
EndIf

oGet:cFieldOk := cValidCol

DEFINE SBUTTON oBtn1 FROM 135,213 TYPE 1 ACTION (If(T020Troca(@nBicms,@nVlrIcms,@ntotTroca,aCols),A020Fim(oDlg1),)) ENABLE OF oDlg1
DEFINE SBUTTON oBtn2 FROM 135,246 TYPE 2 ACTION (lTroca:=.F., lDevoluca:=.F., oDlg1:End()) ENABLE OF oDlg1

ACTIVATE MSDIALOG oDlg1 ON INIT (LChoiceBar(oDlg1),lOkTroca := A020WTroca(@cNum_Troca,@cSerie_Tro),LjCreCli(cCliente, cLoja, @cCliAnt, @cLojAnt, oDlg1,,.T.)) ;
CENTER

//Se for uma Troca
If lTroca
	If Empty(aCols)
		Help(" ",1,"TODOTROCAD")
		Return .T.
	EndIf
	
	If Empty(aCols[1][nPosProd])
		Help(" ",1,"SEMTROCA")
		Return .T.
	EndIf
	
	For nI:=1 to Len(aCols)
		If (aCols[nI][nUsado+1])
			nDelet++
		EndIf
	Next nI
	
	If nDelet == Len(aCols)
		Help(" ",1,"SEMTROCA")
		Return .T.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Copia o aCols para um de trabalho	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols_1	:=Aclone(aCols)
	aHeader_1:=Aclone(aHeader)
	
	For nI:=1 to Len(aCols_1)
		If !(aCols_1[nI][nUsado+1])		 // Se nao estiver Deletado
			If cPaisLoc == "BRA"
				If ( nPosTotal > 0 .AND. nPosValIpi > 0 )
					nCredito+=aCols[nI][nPosTotal] + aCols[nI][nPosValIpi]
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Considerar todos os impostos que incidem no Total da Nota ³
				//³ baseando se na Roteiro Amarracao Tes X Impostos.          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nCredito+=aCols[nI][nPosTotal]
				cTesImp := aCols[nI][nPosTes]
				aImposto := DefImposto( cTesImp )
				For nC := 1 To Len(aImposto)
					cImposto := aImposto[nC][2]
					For nE := 1 To Len(aHeader)
						If Subs(aHeader[nE][2],4,7) == cImposto .AND. aImposto[nC][3] == "1"  //Determina se imposto incide ou nao na nota
							nCredito += aCols[nI][nE]
						EndIf
					Next nE
				Next nC
			EndIf
		EndIf
	Next nI
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A ocorrencia 25 (ACS), verifica se o usu rio poder  ou n„o 	³
	//³ efetuar um Atendimento. (Para Criar um orcamento novo de troca³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ChkPsw( 25 )
		cAliasAtu:=Alias()
		DbSelectArea("SL1")
		DbSeek( xFilial() )
		DbSelectArea(cAliasAtu)
		Return .T.
	EndIf
	
	cNumAnt := cNumNota
	cSerAnt := cSerie
	cDatAnt := cDatEmi
	cPdvAnt := cNumPdv
	If lj010ate("SL1",,3,,cCliente,cLoja,SL1->L1_VEND)
		nVlrTroca := If(cPaisLoc=="BRA",SL1->L1_VLRLIQ,SL1->L1_VLRTOT)
		
		If !lOk
			cAliasAtu:=Alias()
			DbSelectArea("SL1")
			DbSeek( cFilial )
			DbSelectArea(cAliasAtu)
			Return
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a Rotina de Devolu‡„o ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lj020Devol(aCols_1,aHeader_1,nBicms,nVlrIcms,cNumAnt,cSerAnt,cDatAnt,nVlrTroca,cPdvAnt,nDecs)
  		
      If cPaisLoc <> "BRA"  		
         lj020GeraLF()
      EndIf   
	Else
		Help(" ",1,"NAOTROCADO")
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no 1 registro do SL1	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasAtu:=Alias()
	DbSelectArea("SL1")
	DbSeek( cFilial )
	DbSelectArea(cAliasAtu)
Else
	If lDevoluca
		  
		lContinua := .T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o parâmetro MV_DEVNCC estiver configurado para nao gerar nota         ³
		//³ de credito verifica se existem titulos em cobranca (E1_PORTADOR <>" "  e ³
		//³ E1_PORTADO <> IsCaixaLoja()). Se existir nao deixa efetuar a devolucao.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SuperGetMV("MV_DEVNCC") $ "14"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pega o numero do documento ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SL1->L1_TIPO == "P"
				cL1_Doc		:= SL1->L1_DOCPED
				cL1_Serie	:= SL1->L1_SERPED
			Else
				cL1_Doc		:= SL1->L1_DOC
				cL1_Serie	:= SL1->L1_SERIE
			Endif
		Endif
		    
		If lContinua 
		
			If SL1->L1_TIPO == "P" 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Faz o tratamento quando eh pedido. Verifica as filiais onde foram³
				//³gerados os orcamentos                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aColsPed := {}
				If SL1->L1_TIPO == "P"
					nPosFilRes 	:= aScan(aHeader, {|x| Alltrim(Upper(x[2])) == "L2_FILRES" } )
					nPosOrcRes	:= aScan(aHeader, {|x| Alltrim(Upper(x[2])) == "L2_ORCRES" } )
					If nPosFilRes > 0
						For nI := 1 to Len( aCols )
							// Faz o tratamento se nao estiver deletado
							If !aCols[nI][Len(aCols[nI])]
								nPos := aScan( aColsPed, { |x| x[1]+x[2] == aCols[nI][nPosFilRes]+aCols[nI][nPosOrcRes] } )
								If nPos == 0
									aAdd( aColsPed, { aCols[nI][nPosFilRes], aCols[nI][nPosOrcRes], {} } )
								Endif							
								nPos := If( nPos==0, nPos:=Len(aColsPed), nPos )
								aAdd( aColsPed[nPos][3], aClone(aCols[nI]) )
							Endif
						Next nI
					Endif
				Endif
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Chama a função para gravacao do financeiro  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cNumTroc  := SL1->L1_DOCPED
				cSerieDev := SL1->L1_SERPED
				If GetValDev(nTroc,cNumTroc,cSerieDev)
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Salva as posicoes dos ponteiros no SL1 e SL2 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			        nRegSL1 := SL1->(Recno())
			        nRegSL2 := SL2->(Recno())
			        
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Ajusta as variaveis para pegar os dados da aCols ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nPosItem	:= aScan(aHeader, {|x| Alltrim(Upper(x[2])) == "L2_ITEM" } )
					nPosProduto	:= aScan(aHeader, {|x| Alltrim(Upper(x[2])) == "L2_PRODUTO" } )
					nPosReserva	:= aScan(aHeader, {|x| Alltrim(Upper(x[2])) == "L2_RESERVA" } )
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Marca os itens do L2 do orcamento "pai" como "DEVOLVIDOS" (L2_STATUS = "D")              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SL2")
					DbSetorder(1) 	// filial + num + item + produto
					For nI := 1 to Len( aCols )
						If !aCols[nI][Len(aCols[nI])]
							If DbSeek(xFilial("SL2")+SL1->L1_NUM+aCols[nI][nPosItem]+aCols[nI][nPosProduto])
								RecLock("SL2",.F.)
								REPLACE SL2->L2_STATUS WITH "D"
								MsUnlock()
							Endif
					    Endif
					Next nI
							
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Marca os itens do L2 dos orcamentos "filhos" como sendo " A TROCAR " (L2_STATUS = "T")   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SL1")
					DbSetorder(1)	// filial + num
					
					DbSelectArea("SL2")
					DbSetorder(1) 	// filial + num + item + produto
					For nI := 1 to Len( aColsPed )
					    // Verifica se o orcamento jah foi faturado			    
						DbSelectArea("SL1")
						If DbSeek( aColsPed[nI][1]+aColsPed[nI][2] )
						
							// Monta um array auxiliar com os dados do orcamento para localizar o
							// produto, que esta sendo devolvido, no orcamento que foi gerado atraves de um pedido
							DbSelectArea("SL2")
							DbSetorder(1)	// filial + num + item + produto
							DbSeek( aColsPed[nI][1]+aColsPed[nI][2] )
							While !Eof() .AND. aColsPed[nI][1]+aColsPed[nI][2] == SL2->L2_FILIAL+SL2->L2_NUM
								aAdd( aColsDev, { SL2->L2_FILIAL, SL2->L2_NUM, SL2->L2_PRODUTO, SL2->L2_RESERVA, SL2->(Recno()) } )
								DbSkip()
							End
						
							// Orcamento em aberto
							If !Empty(SL1->L1_DOC)
								// Faz a gravacao do L1_STATUS
								RecLock("SL1",.F.)
								REPLACE SL1->L1_STATUS WITH "D"
								MsUnlock()
								         
								// Faz a gravacao do L2_STATUS
								For nX := 1 to Len( aColsPed[nI][3] )						
									nPos := aScan( aColsDev, { |x| x[3]+x[4] == aColsPed[nI][3][nX][nPosProduto]+aColsPed[nI][3][nX][nPosReserva] } )
									If nPos > 0
										DbSelectArea("SL2")
										dbGoTo( aColsDev[nPos][5] )
										RecLock("SL2",.F.)
										REPLACE SL2->L2_STATUS WITH "T"
										MsUnlock()
									Endif
								Next nX	
							Else	// Apaga o orcamento e cancela as reservas.
								// Faz a gravacao do L2_STATUS
								For nX := 1 to Len( aColsPed[nI][3] )
									nPos := aScan( aColsDev, { |x| x[3]+x[4] == aColsPed[nI][3][nX][nPosProduto]+aColsPed[nI][3][nX][nPosReserva] } )
									If nPos > 0
										DbSelectArea("SL2")
										dbGoTo( aColsDev[nPos][5] )
										If !Empty(SL2->L2_RESERVA)
											cReserva := SL2->L2_RESERVA
											RecLock( "SL2", .F. )
											REPLACE SL2->L2_RESERVA WITH Space(TamSX3("L2_RESERVA")[1])
											MsUnlock()
											FkCommit()
										
											LJ7CancRes( {{cReserva, Space(6), SL2->L2_PRODUTO,;
											              SL2->L2_LOCAL, SL2->L2_FILIAL }} )
										Endif
									Endif
								Next nX	
							
								DbSelectArea("SL1")
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Altera o valor de cFilAnt para gerar a reserva na filial correta        ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								cFilAux := cFilAnt
								cFilAnt := SL1->L1_FILIAL
							
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Chama a funcao de exclusao do orcamento ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								Lj140ExcOrc()
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Volta o valor original de cFilAnt                                       ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								cFilAnt := cFilAux
							Endif
						Endif
											
					Next nI
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Restaura as posicoes dos ponteiros do SL1 e SL2    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			        SL1->(dbGoTo(nRegSL1))
			        SL2->(dbGoTo(nRegSL2))
			        
				Endif
	
	        Else
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Recalculo da comissao para troca/devolu‡ao           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cSerie	:= If(lExistNota,cSerie,Space(TamSx3("L1_SERIE")[1]))
				cNumNota := If(lExistNota,cNumNota,Space(TamSx3("L1_DOC")[1]))
				cDatEmi := If(lExistNota,cDatEmi,CtoD(""))
				cNumPdv	:= If(lExistNota,cNumPdv,Space(TamSx3("L1_DOC")[1]))
				cNumAnt := cNumNota
				cSerAnt := cSerie
				cDatAnt := cDatEmi
				cPdvAnt := cNumPdv
				
				DbSelectArea("SL1")
				DbGoto(nRegOri)
						
				If lRet
				
					// Nao chama a GetValDev quando for orcamento gerado atraves de um pedido
					If Empty(SL1->L1_FILRES) .AND. Empty(SL1->L1_ORCRES)
						lRet := GetValDev(nTroc,cNumAnt,cSerAnt,@cFormDev)
					Else
						Reclock("SL1",.F.)
						REPLACE SL1->L1_STATUS WITH " "
						SL1->(MsUnlock())
					Endif
					
					If lRet
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Copia o aCols para um de trabalho  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aCols_1	 :=Aclone(aCols)
						aHeader_1:=Aclone(aHeader)
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Chama a Rotina de Devolu‡„o				³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lj020Devol(aCols_1,aHeader_1,nBicms,nVlrIcms,cNumAnt,cSerAnt,cDatAnt,nVlrTroca,cPdvAnt,nDecs)
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Recalculo da comissao para troca/devolu‡ao           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Alltrim(cFormDev) $ MVCHEQUE + "/" + SuperGetMV("MV_SIMB"+Alltrim(Str(nMoedaTr)))
							LJ020RecComis(cSerie,cNumNota,cNumPdv,cPrefixo,@nBaseComis,nDecs)
						EndIf
	
						// Atualiza dados do cliente
			
						If ! SuperGetMV( "MV_CLIPAD" )+ SuperGetMV( "MV_LOJAPAD" ) == SA1->A1_COD+SA1->A1_LOJA
				          	//Atualiza saldo de duplicatas apos efetuar devolucao
				          	AtuSalDup("-",SE1->E1_SALDO,SE1->E1_MOEDA,SE1->E1_TIPO,If(SE1->E1_MOEDA==nMoedaCor,nTaxaMoeda,0),SE1->E1_EMISSAO)
							Reclock( "SA1" ,.F.)
				          	REPLACE SA1->A1_VACUM WITH SA1->A1_VACUM - nTroc
							SA1->(MsUnlock())
						EndIf						
						
			            If cPaisLoc <> "BRA"  		
			               lj020GeraLF()
			            EndIf   
					EndIf
				Endif
			Endif		
		Endif
	Endif
Endif

lTroca	   := .F.
lDevoluca  := .F.
lCnd	   := .F.
lFirst	   := .F.
lTrocLoja  := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no 1 registro do SL1	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasAtu:=Alias()
DbSelectArea("SL1")
DbSeek( cFilial )
DbSelectArea(cAliasAtu)

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ lj020Troc³ Autor ³ Vendas Clientes		³ Data ³ 18.11.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Troca de Mercadorias / Devolu‡„o do Cliente	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ lj020Trocl                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj020Trocl()
Local aCols_1
Local aHeader_1
Local nI			:= 0
Local cAliasAtu    	:= ""
Local nTotTroca		:= 0
Local nBicms		:= 0
Local nVlrIcms 		:= 0
Local lRet			:= .T.
Local cNumAnt   	:= Space(TamSx3("L1_DOC")[1])
Local cSerAnt 		:= Space(TamSx3("L1_SERIE")[1])
Local cDatAnt 		:= CtoD("")
Local cPdvAnt 		:= ""
Local oBtn1
Local oBtn2
Local nDelet		:= 0
Local nVlrTot		:= 0
Local nDescLoj    	:= 0
Local cMoedaTr    	:= ""
Local oTaxaTr 
Local oCbx 
Local cPictTr    	:= ""
Local aImposto 		:= {}
Local cx3Valid		:= ""	
Local nX			:= 0 
Local nC           	:= 0
Local nE           	:= 0
Local nVlrTroca		:= 0
Local cFormDev		:= ""
Local nDecs			:= MsDecimais( 1 )

Private oDlg1
Private lExistNota	:= .F.
Private aPosicoes[0]
Private aHeader[0]
Private aCampos[0]
Private nRegOri    	:= SL1->(RecNo())
Private oCliente
Private oLoja 
Private oDesc
Private oGet
Private oMerc 
Private oTroc 
Private oTItens  
Private oBmp
Private cNumNota	:= Space(TamSx3("L1_DOC")[1])
Private cSerie 		:= Space(TamSx3("L1_SERIE")[1])
Private cDatEmi    	:= CtoD("")
Private cNumPdv		:= Space(TamSx3("L1_DOC")[1])
Private cLoja		:= SuperGetMV("MV_LOJAPAD")
Private cCliente	:= SuperGetMV("MV_CLIPAD")
Private cCliAnt     := ""
Private cLojAnt     := ""
Private cComprou	:= "N"
Private cDescCli	:= ""
Private nDescont	:= 0
Private nTroc		:= 0
Private nMerc		:= 0
Private nTItens     := 0
Private nRegAnt		:= ""
Private nOpc		:= 4
Private nLinGetdados:= 15
Private nTabela		:= Int(Val(SuperGetMV( "MV_TABPAD" ) ) )
Private lOk 		:= .T.
Private cSerieDev 	:= Space(TamSx3("L1_SERIE")[1])
Private cNumTroc	:= Space(TamSx3("F1_DOC")[1])
Private nUsado 		:= 0
Private cNum_troca	:= Space(TamSx3("F1_DOC")[1])
Private cSerie_tro	:= Space(TamSx3("L1_SERIE")[1])
Private lComprou	:=.T.
Private nTaxaMoeda  := Criavar("M2_MOEDA1")
Private cCliEntrega := ""
Private cLojEntrega := ""
If cPaisLoc <> "BRA"
   PRIVATE aImpVarSF1 := {}
   Private aImpVarSD1 := {0,0,0,0,0,{}}
   Private cNFiscal   
   Private aLivroF    := {}
   PRIVATE nMoedaTr   := 1
   PRIVATE nTaxaTr
   Private aMoeda := {}
   PRIVATE aPosImps   := {}	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega array com as moedas ativas para o Combo.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX	:=	1	To 5
		If(!(Empty(SuperGetMV("MV_MOEDA"+Ltrim(STR(nX))))))
			AAdd(aMoeda,SuperGetMV("MV_MOEDA"+Ltrim(STR(nX))))
		Else
			Exit
		Endif
	Next nX
	
	If SL1->L1_MOEDA <> 0 .AND. SL1->L1_MOEDA <= Len(aMoeda)
	   nTaxaTr	 :=	SL1->L1_TXMOEDA
	   cMoedaTr	:=	aMoeda[SL1->L1_MOEDA]
	ElseIf SL1->L1_MOEDA == 0
	   nTaxaTr	  :=	1
	   cMoedaTr	:=	aMoeda[1]
	Else
	   Help(" ",1,"NoMoeda")
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a variavel do frete                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFrete     := { 0, 0, 0 } 		// Contem os valores do frete, seguro e despesa, respectivamente.
aRetencoes := {} 		        // Contem os valores do frete, seguro e despesa, respectivamente.

Private nCredito	:= 0

If ExistBlock('LJ020F11')
	SetKey(122,{ ||ExecBlock('LJ020F11', .F., .F.)})   // F11
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o caixa esta aberto, senao nao deixa fazer a troca ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ljCxAberto()
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Existe o Paramentro de Tes de TROCA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTesTroca:=SuperGetMV("MV_TESTROCA")
If cTesTroca == NIL
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o Tes 132 Como Troca ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	PutMv( "MV_TESTROCA" , "132" )
	
	cTesTroca := "132"
	
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader com os campos da troca  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("Sx2")
DbSeek("SL2")
DbSelectArea("Sx3")
DbSeek( "SL2" )
While !Eof() .AND. (X3_ARQUIVO == "SL2")
	IF (X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .AND. Alltrim(X3_CAMPO)<>"L2_NUM") .OR. Alltrim(X3_CAMPO) == "L2_ITEM"
		nUsado++
		cX3Valid := X3_VALID
		If (cPaisLoc <> "BRA") .AND. (Alltrim(X3_CAMPO) == "L2_TES")
			cX3Valid := "ValTES()"
		ElseIf (cPaisLoc <> "BRA") .AND. (Alltrim(X3_CAMPO) == "L2_PRODUTO")
			cX3Valid := "Lj020ValProd()"		
		Endif				
		Aadd(aHeader,{ TRIM(X3Titulo()), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL, If(Alltrim(X3_CAMPO)=="L2_LOCALIZ","LJ020VLOC( .F.,.T.)",cX3Valid),;
		X3_USADO, X3_TIPO, X3_ARQUIVO } )
		Aadd( aCampos, X3_CAMPO )
		//Armazena as posicoes dos campos de impostos(bas e e valor) para posterior gravacao na fatura de compras
		If cPaisLoc <> "BRA" .AND. (Substr(X3_CAMPO,4,6) == "BASIMP" .OR. Substr(X3_CAMPO,4,6) == "VALIMP")
		   Aadd(aPosImps,{X3_CAMPO,nUsado})
		EndIf		
	End
	DbSkip()
End

Private aCOLS[1][nUsado+1]
Private aFirst[1][nUsado+1]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as Posicoes dos Campos no aHeader	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lj020Pos()
lj010Pos()

nUsado:=0
DbSelectArea("SX3")
DbSeek( "SL2" )
While !Eof() .AND. X3_ARQUIVO == "SL2"
	If (x3Uso(X3_USADO) .AND. cNivel >= X3_NIVEL .AND.	Alltrim(X3_CAMPO)<>"L2_NUM") .OR. Alltrim(X3_CAMPO) == "L2_ITEM"
		nUsado++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Array de 1 elemento ³
		//³ vazio. Se inclus„o. 		³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If X3_TIPO == "C"
			aCOLS[1][nUsado] := SPACE(X3_TAMANHO)
		ElseIf X3_TIPO == "N"
			aCOLS[1][nUsado] := 0
		ElseIf X3_TIPO == "D"
			aCOLS[1][nUsado] := dDataBase
		Else
			aCOLS[1][nUsado] := .F.
		EndIf
	EndIf
	DbSkip()
End
aCOLS[1][nUsado+1] := .F.

DEFINE MSDIALOG oDlg1 FROM 15,2 TO 320,565 TITLE cCadastro PIXEL
lCnd:=.F.
@ 17,001 TO 40,277 LABEL STR0001 OF oDlg1 PIXEL    // Troca de Mercadorias
If File("Bombe.Bmp")
	@	0.4,25 BITMAP oBmp FILE "BombE.bmp" OF oDlg1 NOBORDER SIZE 20,20
	oBmp:lStretch:=.T.
Endif

@ 24,003 SAY	STR0004 OF oDlg1 PIXEL                        // Cliente
@ 24,126 SAY	"-"     OF oDlg1 PIXEL
@ 24,156 SAY	STR0005 OF oDlg1 PIXEL                        // Nome
@110,002 TO 132,277 LABEL STR0006 OF oDlg1 PIXEL  // Totais
@118,010 SAY STR0007 OF oDlg1 PIXEL               // Mercadorias :
@118,113 SAY STR0008 OF oDlg1 PIXEL               // Troca :
@118,200 SAY STR0076 SIZE 40, 8 OF oDlg1 PIXEL    // Total de Itens :

@ 24,030 MSGET oCliente VAR cCliente  SIZE  90, 8	OF oDlg1 PIXEL F3 "SA1"  Picture "@!" Valid LjCreCli(cCliente, cLoja, @cCliAnt, @cLojAnt, oDlg1, , .T.) .AND. Lj020Desc(@cDescCli,oDesc,cCliente,cLoja) .AND. If(ExistBlock("LJ020CLI"),ExecBlock("LJ020CLI",.F.,.F.),.T.)
@ 24,130 MSGET oLoja 	VAR cLoja	  SIZE	8, 8	OF oDlg1 PIXEL           Picture "@!" Valid LjCreCli(cCliente, cLoja, @cCliAnt, @cLojAnt, oDlg1, , .T.) .AND. Lj020Desc(@cDescCli,oDesc,cCliente,cLoja)
@ 24,175 MSGET oDesc 	VAR cDescCli  SIZE 99, 8  OF oDlg1 PIXEL When .F. Picture "@!"
@117,047 MSGET oMerc VAR nMerc Picture PesqPict("SL1","L1_VALMERC") SIZE 60,8 OF  oDlg1 PIXEL When .F. RIGHT
@117,133 MSGET oTroc VAR nTroc Picture PesqPict("SL1","L1_VALBRUT") SIZE 60,8 OF oDlg1 PIXEL When .F. RIGHT
@117,237 MSGET oTItens VAR nTItens Picture "@E 99999" SIZE 20, 8 OF oDlg1 PIXEL When .F. RIGHT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Moeda/Taxa          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA"
	nMoedaTr := If(SL1->L1_MOEDA <> 0,SL1->L1_MOEDA,1)
	cMoedaTr := Eval( MemVarBlock( "MV_MOEDA" + STR( nMoedaTr, 1 ) ) )
	nTaxaMoeda	:=	SL1->L1_TXMOEDA	
	nTaxaTr  := SL1->L1_TXMOEDA
	cPictTr  := PesqPict("SL1","L1_TXMOEDA",15)

	@ 135,010 SAY STR0079 SIZE 22,07	OF oDlg1	PIXEL 			//"Moneda"
	@ 135,047 COMBOBOX oCBX 	VAR cMoedaTr ITEMS aMoeda ON CHANGE (nTaxaTr:=RecMoeda(dDataBase,oCBX:nAt),nMoedaTr:=oCBX:nAt,oGet:oBrowse:SetFocus() ) SIZE 60,08 OF oDlg1 PIXEL
	@ 135,113 SAY STR0080		SIZE 18,07	OF oDlg1 PIXEL 			//"Tasa"
	@ 135,133 MSGET	oTaxaTr 	VAR nTaxaTr 		SIZE 60,08	OF oDlg1 PIXEL WHEN .F.	Picture cPictTr
EndIf

oGet:= MSGetDados():New(44,1,109,278,nOpc,"Lj020EvaLi","Lj020TudOk","",.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacao igual a troca da loja, para atualizar o rodape da janela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet:oBrowse:bDelete := { || aCols[n,Len(Acols[n])] := !aCols[n,Len(Acols[n])],;
								oGet:LinhaOk(),;
                             	oGet:oBrowse:Refresh(.F.),;
                             	Lj020Evali(),;
                             	If( Len(aRetencoes)>0, aRetencoes[n,Len(aRetencoes[n])] := ! aRetencoes[n,Len(aRetencoes[n])], .T.) ,;
                             	nMerc+=If(aCols[n,Len(Acols[n])],-1,1)*aCols[n,nPosTotal],;
                             	nTroc:=(nMerc-LJ020SumRet()-(aFrete[1]+aFrete[2]+aFrete[3])),;
                             	oMerc:Refresh(), oTroc:Refresh() }
If cPaisloc == "BRA"
	oGet:cFieldOk	:= "Lj020CTot(),.T."
Else
	oGet:oBrowse:bDrawSelect := {|| aImposto := RoteiroCalc(@nVlrTot,@nDescLoj,"D") }  //Calculo de impostos variaveis
	oGet:cFieldOk            := "Lj020ValProd(),Lj020CTot(),.T."
EndIf

DEFINE SBUTTON oBtn1 FROM 135,213 TYPE 1 ACTION (If(Lj020VLoc(.T.),If(T020Troca(@nBicms,@nVlrIcms,@ntotTroca,aCols,@cNumAnt,@cSerAnt,@cDatAnt,@cPdvAnt),A020Fim(oDlg1),),(oGet:oBrowse:SetFocus(),.F.))) ENABLE OF oDlg1

// Abandona a Troca ?
DEFINE SBUTTON oBtn2 FROM 135,246 TYPE 2 ACTION (If(LojaOK(STR0009),(lTroca:=.F., lDevoluca:=.F.,;
A020Fim(oDlg1)),)) ENABLE OF oDlg1

oCliente:SetFocus()
ACTIVATE MSDIALOG oDlg1 ON INIT (LChoiceBar(oDlg1),A020WTroca(@cNum_Troca,@cSerie_Tro)) CENTER

SetKey(122,)

//Se for uma Troca
If lTroca
	If Empty(aCols)
		Help(" ",1,"TODOTROCAD")
		Return .T.
	EndIf
	
	If Empty(aCols[1][nPosProd])
		Help(" ",1,"SEMTROCA")
		Return .T.
	EndIf
	
	For nI := 1 to Len(aCols)
		If (aCols[nI][nUsado+1])
			nDelet++
		EndIf
	Next nI
	
	If nDelet == Len(aCols)
		Help(" ",1,"SEMTROCA")
		Return .T.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Copia o aCols para um de trabalho	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols_1	:=Aclone(aCols)
	aHeader_1:=Aclone(aHeader)
	
	For nI := 1 to Len(aCols_1)
		If !(aCols_1[nI][nUsado+1])		 // Se nao estiver Deletado
			If cPaisLoc == "BRA"
				If ( nPosTotal > 0 .AND. nPosValIpi > 0 )
					nCredito+=aCols[nI][nPosTotal] + aCols[nI][nPosValIpi]
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Considerar todos os impostos que incidem no Total da Nota ³
				//³ baseando se na Roteiro Amarracao Tes X Impostos.          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nCredito+=aCols[nI][nPosTotal]
				cTesImp := aCols[nI][nPosTes]
				aImposto := DefImposto( cTesImp )
				For nC := 1 To Len(aImposto)
					cImposto := aImposto[nC][2]
					For nE := 1 To Len(aHeader)
						If Subs(aHeader[nE][2],4,7) == cImposto .AND. aImposto[nC][3] == "1"  //Determina se imposto incide ou nao na nota
							nCredito += aCols[nI][nE]
						EndIf
					Next nE
				Next nC
			EndIf
		EndIf
	Next nI
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A ocorrencia 25 (ACS), verifica se o usu rio poder  ou n„o 	³
	//³ efetuar um Atendimento. (Para Criar um orcamento novo de troca³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ChkPsw( 25 )
		cAliasAtu:=Alias()
		DbSelectArea("SL1")
		DbSeek( xFilial() )
		DbSelectArea(cAliasAtu)
		Return .T.
	EndIf
	If lj010ate("SL1",,3,,cCliente,cLoja)
		nVlrTroca := If(cPaisLoc=="BRA",SL1->L1_VLRLIQ,SL1->L1_VLRTOT)
		If !lOk
			cAliasAtu:=Alias()
			DbSelectArea("SL1")
			DbSeek( cFilial )
			DbSelectArea(cAliasAtu)
			Return
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a Rotina de Devolu‡„o ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lj020Devol(aCols_1,aHeader_1,nBicms,nVlrIcms,cNumAnt,cSerAnt,cDatAnt,nVlrTroca,cPdvAnt,nDecs)
	Else
		Help(" ",1,"NAOTROCADO")
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no 1 registro do SL1	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasAtu:=Alias()
	DbSelectArea("SL1")
	DbSeek( cFilial )
	DbSelectArea(cAliasAtu)
Else
	If lDevoluca
		DbSelectArea("SL1")
		DbGoto(nRegOri)
		
		If lRet			
			If GetValDev(nTroc,cNumAnt,cSerAnt,@cFormDev)				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Copia o aCols para um de trabalho	³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCols_1  :=Aclone(aCols)
				aHeader_1:=Aclone(aHeader)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Chama a Rotina de Devolu‡„o	            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lj020Devol(aCols_1,aHeader_1,nBicms,nVlrIcms,cNumAnt,cSerAnt,cDatAnt,nVlrTroca,cPdvAnt,nDecs)
			EndIf
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no 1 registro do SL1  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasAtu:=Alias()
DbSelectArea("SL1")
DbSeek( cFilial )
DbSelectArea(cAliasAtu)

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³T020Troca ³ Autor ³ Vendas Clientes		³ Data ³ 04.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Trata Devolucao ou Troca                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function T020Troca( nBicms  ,nVlrIcms  ,nTroc   ,aCols  ,;
                    cNumAnt ,cSerAnt   ,cDatAnt ,cPdvAnt )
Local oDlgChoice
Local oBtnTroc
Local oBtnDevol
Local lnTotal := .T.
Local nI
Local nTotDev
Local nDifVenda
Local oNotDev
Local oSerDev
Local oBtnDev
Local oSucCli
Local oNfCli
Local lRet		:= .T.
Local aNfOri 	:= {}
Local cSucCli	:= Space(04)
Local cNFCli 	:= Space(TamSX3("F1_DOC")[1])
Local lL20VlTro := ExistBlock("L20VLTRO")
Local aBotoes 	:= {.T.,.T.}
Local lTemProd	:= .F.

If Empty(aCols[1][nPosProd])
	Help(" ",1,"SEMTROCA")
	lTroca	:=.F.
	lDevoluca:=.F.
	Return(lRet)
EndIf

lTemProd	:= .F.
For nI := 1 to Len(aCols)  // branco.
	if !aCols[nI][nUsado+1] .AND. Empty(aCols[nI][nPosProd])
		HELP(" ",1,"A010VAZ")
		Return .F.
	endif
	If cPaisLoc <> "BRA" .AND. !aCols[nI][nUsado+1]
	    If aCols[nI][nPosTES] > "500"
	       HELP(" ",1,"TESINV")	
	       Return .F.	       
	    EndIf
	EndIf
	If !aCols[nI][Len(aCols[nI])]
		lTemProd := .T.
	Endif
Next nI
     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao permite continuar se nao foi selecionado nenhum produto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTemProd
	Help(" ",1,"SEMTROCA")
	lTroca	:=.F.
	lDevoluca:=.F.
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para validar os botões que aparecerão no diálogo da Troca ou Devolução ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lL20VlTro
	aBotoes := ExecBlock("L20VLTRO",.F.,.F.)
Endif

lj020Total()

If cPaisLoc=="BRA"
	lj020ICMS(@nBicms,@nVlrIcms,nTroc)
EndIf
lTroca	 :=.F.
lDevoluca:=.F.

aNfOri := If(ExistBlock("LJ020ORI"),Execblock("LJ020ORI",.F.,.F.,{PROCNAME(3)}),NIL)
If aNfOri <> NIL
	If Len(aNfOri) >= 1 .AND. aNfOri[1] <> Nil
		cNumAnt := aNfOri[1]
	EndIf
	If Len(aNfOri) >= 2 .AND. aNfOri[2] <> Nil
		cSerAnt := aNfOri[2]
	EndIf
	If Len(aNfOri) >= 4 .AND. aNfOri[4] <> Nil
		cDatAnt := aNfOri[4]
	EndIf
	If Len(aNfOri) >= 5 .AND. aNfOri[5] <> Nil
		cPdvAnt := aNfOri[5]
	EndIf	
	If Len(aNfOri) >= 3 .AND. ! aNfOri[3]
		Return .F.
	EndIf
Endif
// Escolha a Opera‡„o
DEFINE MSDIALOG oDlgChoice TITLE STR0010;
From 10,30 To 17,68 OF GetWndDefault()

@ 0,1 TO 35,148 OF oDlgChoice PIXEL

// &Trocar...
@ 1,3 BUTTON oBtnTroc PROMPT STR0011 SIZE 40,18;
ACTION (lTroca := .T.,oDlgChoice:End()) OF oDlgChoice
IF SuperGetMV("MV_TROCAD") .OR. !aBotoes[1] .OR. ( SL1->L1_TIPO == "P" .OR. !Empty(SL1->L1_ORCRES) );
	 .OR. (LjAnalisaLeg(4)[1] .AND. SuperGetMV("MV_LJPGCC"))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Desabilita o botao de troca se for pedido. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBtnTroc:disable() 
Endif

// &Devolver...
@ 1,14 BUTTON oBtnDevol PROMPT STR0012 SIZE 40,18;
ACTION (lDevoluca := .T.,oDlgChoice:End()) OF oDlgChoice
If !aBotoes[2]
	oBtnDevol:Disable()
Endif

// &Abandonar.
@ 1,25 BUTTON oBtnCancel PROMPT STR0013 SIZE 40,18;
ACTION (lDevoluca := .F.,lTroca:= .F.,oDlgChoice:End()) OF oDlgChoice

ACTIVATE MSDIALOG oDlgChoice CENTERED

If lTroca .OR. lDevoluca
	IF !Empty(cScriptTro)
		If cFormPro == "N"
			// Nota\Serie
			If cPaisLoc == "BRA"
				lRet := .F.
				DEFINE MSDIALOG oDlg TITLE STR0014 From 10,20 To 15,50 OF oMainWnd
				@ 1,2 TO 21,117 LABEL STR0014 OF oDlg PIXEL
				
				// Nota
				@ 8.5, 12 Say STR0015 OF oDlg PIXEL SIZE 20,7
				@ 8.5, 26 MSGET oNotDev VAR cNumTroc Pict REPLICATE("9",TamSx3("F1_DOC")[1]) SIZE 25,7 OF oDlg VALID !Empty(cNumTroc) PIXEL  RIGHT
				
				// Serie
				@ 8.5, 63 Say STR0016 OF oDlg PIXEL  SIZE 20,7
				@ 8.5, 79 MSGET oSerDev VAR cSerieDev Pict "@!" SIZE 5,7 OF oDlg VALID !Empty(cSerieDev) PIXEL  RIGHT
				
				DEFINE SBUTTON oBtnDev FROM 24,80 TYPE 1 ACTION If(!Empty(cNumTroc).AND.!Empty(cSerieDev),;
					(lRet:=!(Lj020VerNF(cNumTroc,cSerieDev)),oDlg:End()), ) ENABLE OF oDlg
				ACTIVATE MSDIALOG oDlg CENTERED
			Else
				lRet := .F.
				DEFINE MSDIALOG oDlg TITLE STR0014 From 10,30 To 16,63 OF oMainWnd
				@ 0.8,0.9 TO 24,122 LABEL STR0014 OF oDlg PIXEL  //"Fact\Serie "
				@ 8.5, 5 Say STR0015 OF oDlg PIXEL  //Nota
				If cPaisLoc == "ARG"
				   @ 8.5, 25 MSGET oSucCli VAR cSucCli   Pict "9999"     Valid Lj020ZeraGet(@cSucCli) SIZE 15,8 OF oDlg  PIXEL  RIGHT
				@ 8.5, 42 MSGET oNFCli  VAR cNFCli    Picture "99999999" Valid Lj020ZeraGet(@cNFCli) .AND. Lj020ActVar(@cNumTroc,cSucCli,cNFCli) SIZE 30,8 OF oDlg  PIXEL  RIGHT
				Else   
				   @ 8.5, 25 MSGET oNFCli  VAR cNFCli    Pict REPLICATE("9",TamSx3("F1_DOC")[1]) Valid Lj020ZeraGet(@cNFCli) .AND. Lj020ActVar(@cNumTroc,cSucCli,cNFCli) SIZE 40,8 OF oDlg  PIXEL  RIGHT				
				EndIf
				@ 8.5, 75 Say STR0016 OF oDlg PIXEL  // Serie				
				@ 8.5,92 MSGET oSerDev VAR cSerieDev Pict "@!" SIZE 8,8 OF oDlg  PIXEL  RIGHT
				DEFINE SBUTTON oBtnDev FROM 26,80 TYPE 1 ACTION (lRet:=.T., oDlg:End()) ENABLE OF oDlg
				ACTIVATE MSDIALOG oDlg CENTERED
			EndIf
		Endif
	Endif
Endif
// teste para arrendondamento do IPI no total da troca  13/04/98
For nI := 1 to Len(aCols)
	If lTrocLoja
		If aCols[ni][nPosQuant] <> aQtde[ni]
			lnTotal := .F.
		EndIf
	EndIf
Next nI
If !lnTotal
	SL2->(DbSetorder(1))
	SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
	nTotDev := 0
	While  SL2->( !Eof() ) .AND. SL2->(L2_FILIAL+L2_NUM) == SL1->(L1_FILIAL+L1_NUM)
		If SL2->L2_STATUS == "D"
			nTotDev += SL2->L2_VLRITEM + SL2->L2_VALIPI
		EndIf
		SL2->( DbSkip() )
	End
	nDifVenda := SL1->L1_VLRTOT - nTotDev
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj020Devol³ Autor ³ Vendas Clientes		³ Data ³ 04.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua todas as devolucoes                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³1 - Acols com os Dados da devolucao                         ³±±
±±³          ³2 - AHeader com os Campos da devolucao                      ³±±
±±³          ³3 - Indica se a nota ja existe ou se e uma nova             ³±±
±±³          ³4 - Serie da nota se existir                                ³±±
±±³          ³5 - Numero da nota se existir                               ³±±
±±³          ³6 - Base do Icms da nota                                    ³±±
±±³          ³7 - Valor do Icms da Nota                                   ³±±
±±³          ³8 - Valor da troca (saida das mercadorias)                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj020Devol(	aCols_1,	aHeader_1,		nBicms,		nVlrIcms,;
						cNumant,	cSerAnt,		cDatAnt,	nVlrTroca,;
						cPdvAnt,	nDecs)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Defini‡„o de vari veis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nT 		 	:= 0
Local nX 		 	:= 0
Local nI			:= 0
Local nItem 	 	:= 0
Local nItens 	 	:= 0
Local cTabela
Local cTes
Local cLocal
Local cProduto
Local cDescri
Local nVlrItem
Local nDesc
Local nValDesc
Local nDescPro   	:= 0
Local nPrcTab    	:= 0
Local nDevoluc   	:= 0
Local nValDevol  	:= 0
Local cUM
Local cCF
Local cItem
Local cL2Num
Local nQuant
Local nVunit
Local nValIcms 		:= 0
Local nValIss  		:= 0
Local nValIpi  		:= 0
Local nBaseIcm 		:= 0
Local nRegistro
Local cOrcNum
Local cNSerie
Local cLotectl
Local cNLOTE
Local cLocaliz
Local nF1ValMerc 	:= 0
LocaL nF1ValBrut 	:= 0
Local nF1Baseicm 	:= 0 
Local nF1Valicm  	:= 0 
Local nF1Valipi  	:= 0 
Local nMaxItens		:= 0
Local nVlrTotFrt 	:= 0
Local nCountFrt		:= 0
Local aDespFrete	:= Array(Len(aCols),3)
Local nVlrFrete 	:= 0
Local nVlrSeguro	:= 0
Local nVlrDespesa	:= 0
Local nFrete 		:= 0
Local nSeguro 		:= 0
Local nDespesa 		:= 0
Local nPosTES		:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_TES" } )
Local nPosVlrItem	:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_VLRITEM" } )
Local nPerPis       := 0
Local nPerCofins    := 0
Local nPerCSLL      := 0
Local nAliqPs2      := 0
Local nAliqCf2      := 0
Local nJurosSL1     := 0   
Local cProxnum 		:= ""
Local cMV_TPNRNFS	:= LjTpNrNFS()			// Retorno do parametro MV_TPNRNFS, utilizado pela Sx5NumNota() de onde serah controlado o numero da NF  1=SX5  2=SXE/SXF  3=SD9

Default nVlrTroca:= 0
If cPaisLoc <> "CHI"
	nMaxItens := SuperGetMV("MV_SER"+cSerieDev,.F.,SuperGetMV("MV_NUMITEN"))
Else
	nMaxItens := SuperGetMV("MV_NUMITEN")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a variavel aDespFrete               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to Len(aDespFrete)
	aFill( aDespFrete[nI], 0 )
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se Retornar falso a escolha nao foi completada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cFormPro == "S" .AND. Empty(cNumTroc) .AND. Empty(cSerieDev)
	If !lj020Nota(Padr(SuperGetMV("MV_LJNFTRO"),3))
		lOk:=.F.
		Return
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a  Compra foi feita na mesma Loja ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSerAnt := Padr(cSerAnt,TamSx3("L2_SERIE")[1])
DbSelectArea("SL1")
DbSetorder(2)
DbSeek(xFilial("SL1")+cSerAnt+cNumAnt+cPdvAnt)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta o valor da troca                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTroc -= (aFrete[1]+aFrete[2]+aFrete[3])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta o valor do Pis/Cofins/CSLL para troca  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTroc -= LJ020SumRet()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz o rateio do frete, seguro e desp.acessórias pelos itens vendidos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( aFrete[1] + aFrete[2] + aFrete[3] ) > 0
	nVlrTotFrt 	:= 0
	nCountFrt	:= 0
	For nI := 1 to Len(aCols_1)
		If !(aCols_1[nI][Len(aCols_1[nI])])
			If Posicione("SF4",1,xFilial("SF4")+aCols_1[nI][nPosTES],"SF4->F4_ISS") <> "S"
				nVlrTotFrt += aCols_1[nI][nPosVlrItem]
				nCountFrt ++
			Endif
		Endif
	Next nI
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz o rateio ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	For nI := 1 to Len(aCols_1)
		If !(aCols_1[nI][Len(aCols_1[nI])])
			If Posicione("SF4",1,xFilial("SF4")+aCols_1[nI][nPosTES],"SF4->F4_ISS") <> "S"
				nPerTotal := aCols_1[nI][nPosVlrItem] / nVlrTotFrt
				If cPaisLoc == "BRA"
					aDespFrete[nI][1] := NoRound(nPerTotal * aFrete[1],2)
					aDespFrete[nI][2] := NoRound(nPerTotal * aFrete[2],2)
					aDespFrete[nI][3] := NoRound(nPerTotal * aFrete[3],2)
				Else                                                          
					aDespFrete[nI][1] := Round(nPerTotal * aFrete[1],nDecimais)
					aDespFrete[nI][2] := Round(nPerTotal * aFrete[2],nDecimais)
					aDespFrete[nI][3] := Round(nPerTotal * aFrete[3],nDecimais)
				EndIf
			Endif
		Endif
	Next nI
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o arredondamento dos valores do frete, seguro e desp.acessorias ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrFrete 	:= 0
	nVlrSeguro	:= 0
	nVlrDespesa	:= 0
	
	aEval(aDespFrete, {|x| (nVlrFrete+=x[1], nVlrSeguro+=x[2], nVlrDespesa+=x[3]) })
	
	nFrete 		:= Mod((aFrete[1] - nVlrFrete), nCountFrt)
	nSeguro 	:= Mod((aFrete[2] - nVlrSeguro), nCountFrt)
	nDespesa 	:= Mod((aFrete[3] - nVlrDespesa), nCountFrt)
	
	aDespFrete[Len(aDespFrete)][1] += nFrete
	aDespFrete[Len(aDespFrete)][2] += nSeguro
	aDespFrete[Len(aDespFrete)][3] += nDespesa
Endif

cOrcNum:=SL1->L1_NUM
If lExistNota
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso a origem desta devolucao seja uma transacao TEF desfeita sem cancelamento ³
	//³ do cupom fiscal, volta o status como " " (VERMELHO) finalizando o processo.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Alltrim(SL1->L1_STATUS) == "T"
		RecLock("SL1", .F.)
		REPLACE SL1->L1_STATUS WITH " "
		SL1->(MsUnLock())
	EndIf
	For nT := 1 to Len(aCols_1)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega os Itens  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lj020Itens(	aCols_1		, aHeader_1	, nT		, @cTabela	,;
					@cTes		, @cLocal	, @cProduto	, @cDescri	,;
					@nVlrItem	, @nDesc	, @nValDesc	, @cUM		,;
					@cCF		, @cItem	, @nQuant	, @nVunit	,;
					@nValIcms	, @nValIss	, @nValIpi	, @nBaseIcm	,;
					@CNSerie	, @cLotectl	, @cNLote	, @cLocaliz	,;
					@nDescPro	, @nPrcTab)
		nItem++
		If !(aCols_1[nT][nUsado+1])	  // Se nao estiver Deletado
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se ha valor de frete para informar na base de calculo ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF4->(DbSetorder(1))
			SF4->(DbSeek(xFilial("SF4")+cTes))
			If (aDespFrete[nT][1] + aDespFrete[nT][2] + aDespFrete[nT][3]) > 0 .AND. SF4->F4_ICM == "S"
				nBaseIcm := nVlrItem
				If SF4->F4_INCIDE == "S"
					nBaseIcm += nValIpi
				EndIf
				nBaseIcm += aDespFrete[nT][1] + aDespFrete[nT][2] + aDespFrete[nT][3]
				nBaseIcm *= If(SF4->F4_BASEICM > 0, SF4->F4_BASEICM/100, 1)
				nValIcms := NoRound( nBaseIcm * AliqIcms("N","S",SA1->A1_TIPO,"I") / 100, 2 )
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faz o processamento da entrada                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SL2")
			SL2->( DbSetorder(1) )
			cOrcNum	 := Padr( cOrcNum, TAMSX3("L2_NUM")[1])
			cItem    := Padr( cItem, TAMSX3("L2_ITEM")[1])
			cProduto := Padr( cProduto, TAMSX3("L2_PRODUTO")[1])
			If SL2->( DbSeek( xFilial() + cOrcNum + cItem + cProduto) )
				nRegistro := SL2->( Recno() )
				cL2Num    := SL2->L2_NUM
				If aCols_1[nT][nPosQuant] == SL2->L2_QUANT
					dbGoto(nRegistro)
					Reclock("SL2")
					REPLACE SL2->L2_STATUS WITH "D"
					MsUnlock()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Chama fun‡„o de grava‡„o das entradas ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nItens++
					IF nItens > nMaxItens
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se eh para fazer o controle do numero da nota pelo SD9 (qdo ³
						//³ cMV_TPNRNFS for igual a "3"                                          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
						If cMV_TPNRNFS == "3"
							cNumTroc := MA461NumNf( .T., cSerieDev )
						Else						
							While !LJ020Nota(cSerieDev)		// Pega o proximo numero de nota livre
							End
						Endif
						nItens     := 1
						nF1ValMerc := 0
						nF1ValBrut := 0
						nF1Baseicm := 0
						nF1Valicm  := 0
						nF1Valipi  := 0
					Endif
					If cPaisLoc <> "BRA"
						nF1ValMerc +=  nVunit*nQuant
						nF1ValBrut +=  (nPrcTab * nQuant) - nValDesc
					Else
						nJurosSL1 := If(lTrocLoja, SL1->L1_JUROS, 0 )
						nF1ValMerc += ( nPrcTab + Round((((nPrcTab-(SL2->L2_VALDESC+SL2->L2_DESCPRO))*nJurosSL1)/100),nDecs) ) * nQuant
						nF1ValBrut += ( (nPrcTab + Round((((nPrcTab-(SL2->L2_VALDESC+SL2->L2_DESCPRO))*nJurosSL1)/100),nDecs) ) * nQuant ) - nValDesc
					Endif                               
					nF1Baseicm +=  nBaseIcm
					nF1Valicm  +=  nValIcms
					nF1Valipi  +=  nValIpi
		 
					cProxnum := ""
								
					lj020Entra(	aCols_1				, nT				, nItem		, cTabela			,;
								cTes				, cLocal			, cProduto	, cDescri			,;
								nVlrItem			, nDesc				, nValDesc	, cUM				,;
								cCF					, @cItem			, nQuant	, nVunit			,;
								nValIcms			, nValIss			, nValIpi	, nBaseIcm			,;
								nBicms				, nVlrIcms			, @nItens	, @nF1ValMerc		,;
								@nF1ValBrut			, @nF1Baseicm		, @nF1Valicm, @nF1Valipi		,;
								@cNSerie			, @cLotectl			, @cNLote	, @cLocaliz			,;
								nMaxItens       	, nDescPro			, nPrctab	, SL2->L2_DOC		,;
								SL2->L2_SERIE    	, cDatAnt			, nVlrTroca	, aDespFrete[nT][1]	,;
								aDespFrete[nT][2]	, aDespFrete[nT][3], cProxnum	)
					
					nDevoluc  := aCols[nT][nPosQuant]
					nValDevol := aCols[nT][nPosTotal]
					
				Else
					If cPaisLoc == "BRA"
						nDevoluc  := aCols[nT][nPosQuant]
						nValDevol := aCols[nT][nPosTotal]
						     
						// Pega a porcentagem do PIS/COFINS/CSLL antiga.
						If FieldPos("L2_VALPIS") > 0 .AND. FieldPos("L2_VALCOFI") > 0 .AND. FieldPos("L2_VALCSLL") > 0
							nPerPis    := ( ( L2_VALPIS / L2_VLRITEM ) * 100 )
							nPerCofins := ( ( L2_VALCOFI / L2_VLRITEM ) * 100 )
							nPerCSLL   := ( ( L2_VALCSLL / L2_VLRITEM ) * 100 )
						EndIf
						
						dbGoto(nRegistro)
						RecLock("SL2",.F.)
						REPLACE SL2->L2_QUANT   WITH L2_QUANT   - aCols[nT][nPosQuant]
						REPLACE SL2->L2_VLRITEM WITH L2_VLRITEM - aCols[nT][nPosTotal]
						REPLACE SL2->L2_VRUNIT  WITH SL2->L2_VLRITEM / SL2->L2_QUANT
						REPLACE SL2->L2_VALDESC WITH L2_VALDESC - aCols[nT][nPosValDes]
						REPLACE SL2->L2_VALICM  WITH L2_VALICM  - aCols[nT][nPosValIcm]
						REPLACE SL2->L2_VALIPI  WITH L2_VALIPI  - aCols[nT][nPosValIPI]
						REPLACE SL2->L2_VALISS  WITH L2_VALISS  - aCols[nT][nPosValIss]
						REPLACE SL2->L2_BASEICM WITH L2_BASEICM - aCols[nT][nPosBsIcms]
						
						// Atualiza o valor do PIS/COFINS/CSLL
						If FieldPos("L2_VALPIS") > 0 .AND. FieldPos("L2_VALCOFI") > 0 .AND. FieldPos("L2_VALCSLL") > 0
							REPLACE SL2->L2_VALPIS  WITH ( ( L2_VLRITEM * nPerPis ) / 100 )
							REPLACE SL2->L2_VALCOFI WITH ( ( L2_VLRITEM * nPerCofins ) / 100 )
							REPLACE SL2->L2_VALCSLL WITH ( ( L2_VLRITEM * nPerCSLL ) / 100 )
						EndIf

						//Grava valores para Apuracao de PIS/COFINS
						If FieldPos( "L2_VALPS2"  ) > 0 .AND. FieldPos( "L2_VALCF2"  ) > 0 .AND. ;
						   FieldPos( "L2_BASEPS2" ) > 0 .AND. FieldPos( "L2_BASEPS2" ) > 0 .AND. ;
						   FieldPos( "L2_ALIQPS2" ) > 0 .AND. FieldPos( "L2_ALIQCF2" ) > 0

							nAliqPs2 := L2_ALIQPS2
							nAliqCf2 := L2_ALIQCF2

							REPLACE SL2->L2_BASEPS2 WITH L2_VLRITEM
							REPLACE SL2->L2_VALPS2  WITH ( ( L2_BASEPS2 * L2_ALIQPS2 ) / 100 )

							REPLACE SL2->L2_BASECF2 WITH L2_VLRITEM
							REPLACE SL2->L2_VALCF2  WITH ( ( L2_BASECF2 * L2_ALIQCF2 ) / 100 )

						EndIf
						
						SL2->( dbCommit() )
						MsUnlock()
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Grava novo registro com os dados da devolu‡„o ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RecLock("SL2",.T.)
						REPLACE SL2->L2_FILIAL		WITH xFilial()
						REPLACE SL2->L2_NUM			WITH cL2Num
						REPLACE SL2->L2_PRODUTO		WITH cProduto
						REPLACE SL2->L2_DESCRI		WITH cDescri
						REPLACE SL2->L2_LOCAL		WITH cLocal
						REPLACE SL2->L2_UM			WITH cUM
						REPLACE SL2->L2_TES			WITH cTes
						REPLACE SL2->L2_CF			WITH cCF
						REPLACE SL2->L2_VENDIDO		WITH "S"
						REPLACE SL2->L2_DOC			WITH cNumNota
						REPLACE SL2->L2_SERIE		WITH cSerie
						REPLACE SL2->L2_TABELA		WITH cTabela
						REPLACE SL2->L2_STATUS		WITH "D"
						REPLACE SL2->L2_EMISSAO		WITH dDataBase
						REPLACE SL2->L2_QUANT		WITH nQuant
						REPLACE SL2->L2_VLRITEM		WITH nVlrItem
						REPLACE SL2->L2_VRUNIT		WITH nVunit
						REPLACE SL2->L2_VALDESC		WITH nValDesc
						REPLACE SL2->L2_DESC		WITH nDesc
						REPLACE SL2->L2_VALICM		WITH nValIcms
						REPLACE SL2->L2_VALIPI		WITH nValIPI
						REPLACE SL2->L2_VALISS		WITH nValIss
						REPLACE SL2->L2_BASEICM		WITH nBaseIcm
						REPLACE SL2->L2_PDV			WITH cNumPdv
						REPLACE SL2->L2_ITEM		WITH cItem
						
						// Atualiza o valor do PIS/COFINS/CSLL
						If FieldPos("L2_VALPIS") > 0 .AND. FieldPos("L2_VALCOFI") > 0 .AND. FieldPos("L2_VALCSLL") > 0
							REPLACE SL2->L2_VALPIS  WITH ( ( L2_VLRITEM * nPerPis ) / 100 )
							REPLACE SL2->L2_VALCOFI WITH ( ( L2_VLRITEM * nPerCofins ) / 100 )
							REPLACE SL2->L2_VALCSLL WITH ( ( L2_VLRITEM * nPerCSLL ) / 100 )
						EndIf

						//Grava valores para Apuracao de PIS/COFINS
						If FieldPos( "L2_VALPS2"  ) > 0 .AND. FieldPos( "L2_VALCF2"  ) > 0 .AND. ;
						   FieldPos( "L2_BASEPS2" ) > 0 .AND. FieldPos( "L2_BASEPS2" ) > 0 .AND. ;
						   FieldPos( "L2_ALIQPS2" ) > 0 .AND. FieldPos( "L2_ALIQCF2" ) > 0

							REPLACE SL2->L2_BASEPS2 WITH L2_VLRITEM
							REPLACE SL2->L2_ALIQPS2 WITH nAliqPs2
							REPLACE SL2->L2_VALPS2  WITH ( ( L2_BASEPS2 * L2_ALIQPS2 ) / 100 )

							REPLACE SL2->L2_BASECF2 WITH L2_VLRITEM
							REPLACE SL2->L2_ALIQCF2 WITH nAliqCf2
							REPLACE SL2->L2_VALCF2  WITH ( ( L2_BASECF2 * L2_ALIQCF2 ) / 100 )

						EndIf

						If FieldPos( "L2_ITEMSD1" ) > 0
							cProxnum := ProxNum()
							REPLACE SL2->L2_ITEMSD1 WITH cProxnum
						EndIf
						

						SL2->( dbCommit() )
						MsUnlock()
					Else
						nDevoluc  := aCols[nT][nPosQuant]
						nValDevol := aCols[nT][nPosTotal]
						dbGoto(nRegistro)
						
						RecLock("SL2",.F.)
							REPLACE SL2->L2_QUANT   	WITH L2_QUANT   - aCols[nT][nPosQuant]
							REPLACE SL2->L2_VLRITEM 	WITH L2_VLRITEM - aCols[nT][nPosTotal]
							REPLACE SL2->L2_VRUNIT  	WITH SL2->L2_VLRITEM / SL2->L2_QUANT
							REPLACE SL2->L2_VALDESC 	WITH L2_VALDESC - aCols[nT][nPosValDes]
							REPLACE SL2->L2_DESC	 	WITH L2_DESC	  - aCols[nT][nPosDesc]
							
							Lj020GrImp( cTes, nT, 'SL2', '-' ) //Grava Impostos ( valor e base )
						SL2->( dbCommit() )
						MsUnlock()
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Grava novo registro com os dados da devolu‡„o ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RecLock("SL2",.T.)
						REPLACE SL2->L2_FILIAL		WITH xFilial()
						REPLACE SL2->L2_NUM			WITH cL2Num
						REPLACE SL2->L2_PRODUTO		WITH cProduto
						REPLACE SL2->L2_DESCRI		WITH cDescri
						REPLACE SL2->L2_LOCAL		WITH cLocal
						REPLACE SL2->L2_UM			WITH cUM
						REPLACE SL2->L2_TES			WITH cTes
						REPLACE SL2->L2_CF			WITH cCF
						REPLACE SL2->L2_VENDIDO		WITH "S"
						REPLACE SL2->L2_DOC			WITH cNumNota
						REPLACE SL2->L2_SERIE		WITH cSerie
						REPLACE SL2->L2_TABELA		WITH cTabela
						REPLACE SL2->L2_STATUS		WITH "D"
						REPLACE SL2->L2_EMISSAO		WITH dDataBase
						REPLACE SL2->L2_QUANT		WITH nQuant
						REPLACE SL2->L2_VLRITEM		WITH nVlrItem
						REPLACE SL2->L2_VRUNIT		WITH nVunit
						REPLACE SL2->L2_VALDESC		WITH nValDesc
						REPLACE SL2->L2_DESC		WITH nDesc
						REPLACE SL2->L2_PDV			WITH cNumPdv
						
						Lj020GrImp( cTes, nT, 'SL2', '=' ) //Grava Impostos ( valor e base )
						SL2->( dbCommit() )
						MsUnlock()
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Chama fun‡„o de grava‡„o das entradas ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					nItens++
					IF nItens > nMaxItens
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se eh para fazer o controle do numero da nota pelo SD9 (qdo ³
						//³ cMV_TPNRNFS for igual a "3"                                          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
						If cMV_TPNRNFS == "3"
							cNumTroc := MA461NumNf( .T., cSerieDev )
						Else				
							While !LJ020Nota(cSerieDev)
							End
						Endif
						nItens     := 1
						nF1ValMerc := 0
						nF1ValBrut := 0
						nF1Baseicm := 0
						nF1Valicm  := 0
						nF1Valipi  := 0
					Endif
					nF1ValMerc	+= (nPrcTab *nQuant)
					nF1ValBrut 	+= (nPrcTab * nQuant) - nValDesc
					nF1Baseicm 	+= nBaseIcm
					nF1Valicm  	+= nValIcms
					nF1Valipi  	+= nValIpi             
					
					lj020Entra(	aCols_1				, nT				, nItem		, cTabela			,;
								cTes				, cLocal			, cProduto	, cDescri			,;
								nVlrItem			, nDesc				, nValDesc	, cUM	 			,;
								cCF					, @cItem			, nQuant	, nVunit 			,;
								nValIcms			, nValIss			, nValIpi	, nBaseIcm			,;
								nBicms				, nVlrIcms			, @nItens	, @nF1ValMerc		,;
								@nF1ValBrut			, @nF1Baseicm		, @nF1Valicm, @nF1Valipi		,;
								@cNSerie			, @cLotectl			, @cNLote	, @cLocaliz			,;
								nMaxItens			, nDescPro			, nPrctab	, cNumAnt			,;
								cSerAnt				, cDatAnt			, nVlrTroca	, aDespFrete[nT][1]	,;
								aDespFrete[nT][2]	,aDespFrete[nT][3]	, cProxnum)
				EndIf
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza o registro do arquivo SD2            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nDevoluc <> 0
					DbSelectArea( "SD2" )
					SD2->( DbSetorder(3) )
					If SD2->( DbSeek( xFilial( "SD2" ) + SL2->L2_DOC + SL2->L2_SERIE + SL1->L1_CLIENTE + SL1->L1_LOJA + cProduto + cItem ) )
						RecLock( "SD2", .F. )
						REPLACE SD2->D2_QTDEDEV WITH SD2->D2_QTDEDEV + nDevoluc
						REPLACE SD2->D2_VALDEV  WITH SD2->D2_VALDEV + nValDevol
						SD2->( MSUnlock() )
					EndIf
				EndIf

			EndIf
			
			nDevoluc  := 0
			nValDevol := 0
		EndIf
	Next nT
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Registro de entrada	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len( aCols_1 )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica os Itens deletados na aCols. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !ATAIL( aCols_1[ nX ] )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega o Itens ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lj020Itens(	aCols_1		, aHeader_1	, nX		, @cTabela	,;
						@cTes		, @cLocal	, @cProduto	, @cDescri	,;
						@nVlrItem	, @nDesc	, @nValDesc	, @cUM		,;
						@cCF		, @cItem	, @nQuant	, @nVunit	,;
						@nValIcms	, @nValIss	, @nValIpi	, @nBaseIcm	,;
						@cNSerie	, @cLotectl	, @cNLote	, @cLocaliz	,;
						@nDescPro	, @nPrcTab)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se ha valor de frete para informar na base de calculo ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (aDespFrete[nX][1] + aDespFrete[nX][2] + aDespFrete[nX][3]) > 0
				nBaseIcm := nVlrItem
				SF4->(DbSeek(xFilial("SF4")+cTes))
				If SF4->F4_INCIDE == "S"
					nBaseIcm += nValIpi
				EndIf
				nBaseIcm += aDespFrete[nX][1] + aDespFrete[nX][2] + aDespFrete[nX][3]
				nBaseIcm *= If(SF4->F4_BASEICM > 0, SF4->F4_BASEICM/100, 1)
				nValIcms := NoRound( nBaseIcm * AliqIcms("N","S",SA1->A1_TIPO,"I") / 100, 2 )
			Endif
			
			nItem++
			nItens++
			IF nItens > nMaxItens
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se eh para fazer o controle do numero da nota pelo SD9 (qdo ³
				//³ cMV_TPNRNFS for igual a "3"                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
				If cMV_TPNRNFS == "3"
					cNumTroc := MA461NumNf( .T., cSerieDev )
				Else
					While !LJ020Nota(cSerieDev)
					End
				Endif
				nItens     := 1
				nF1ValMerc := 0
				nF1ValBrut := 0
				nF1Baseicm := 0
				nF1Valicm  := 0
				nF1Valipi  := 0
			Endif
			If cPaisLoc <> "BRA"
				nF1ValMerc +=  nVunit*nQuant
			Else
				nF1ValMerc +=  nPrcTab*nQuant
			Endif
			nF1ValBrut	+= (nPrcTab * nQuant)- nValDesc
			nF1Baseicm 	+=nBaseIcm
			nF1Valicm  	+=nValIcms
			nF1Valipi  	+= nValIpi
			                       
			cProxnum := ""
			
			lj020Entra(	aCols_1				, nX				, nItem			, cTabela			,;
						cTes				, cLocal			, cProduto		, cDescri			,;
						nVlrItem			, nDesc				, nValDesc		, cUM				,;
						cCF					, cItem				, nQuant		, nVunit			,;
		   				nValIcms			, nValIss			, nValIpi		, nBaseIcm			,;
						nBicms				, nVlrIcms			, @nItens		, @nF1ValMerc		,;
						@nF1ValBrut			, @nF1Baseicm		, @nF1Valicm	, @nF1Valipi		,;
						@cNSerie			, @cLotectl			, @cNLote		, @cLocaliz			,;
						nMaxItens			, nDescPro			, nPrctab		, cNumAnt			,;
						cSerAnt				, cDatAnt			, nVlrTroca		, aDespFrete[nX][1]	,;
						aDespFrete[nX][2]	, aDespFrete[nX][3]	, cProxnum )
		Endif
	Next nX 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama a rotina de impressao da nota fiscal. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cScriptTro) .AND. cPaisLoc <> "ARG"  //FE
	If cFormPro == "S"
		Lj020Imp()	//MUDOU
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada da troca devolucao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lloja020
	ExecBlock("LOJA020",.F.,.F.,{nTroc})  //MUDOU
EndIf
Return( Nil )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj020Nota ³ Autor ³ Vendas Clientes		³ Data ³ 14.01.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Achoice para numero e serie da nota fiscal                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA020                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Data     ³ Bops ³Programa³  Motivo da Alteracao    		   	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 14.07.05 ³ 83762³Henry   ³Implementacao do parametro "MV_LJNRNFS" de  ³±±
±±³          ³      ³        ³modo a tratar a numeracao e a possibilidade ³±±
±±³          ³      ³        ³de utilizacao do ponto de entrada CHGX5FIL  ³±±
±±³          ³      ³        ³conforme os processos semelhantes ao fatura ³±±
±±³          ³      ³        ³mento                                       ³±±
±±³ 18/03/06 ³094211|Geronimo³substituido MsRUnlock() por MsUnlock(), pois³±±
±±³          ³      |        ³ele eh incompativel c/ controle de transacao³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj020Nota(cMvSerieTr)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vari veis Locais ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local aSerNf    := {}                

Local cCadastro := "Notas"
Local cVarQ     := "  "

Local lDone     := .F.
Local lAbandona := .F.
Local lInterno  := .T.

Local nOpcA 	 := 0
Local nSaveSx8 	 := GetSx8Len()
Local nCntErro	 := 0

Local oQual
Local oDlg

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ\¿
//³Parametro MV_LJAVANC, definia na função NxtSX5Nota()- MATXFUNA.PRX, se possivel ³
//³alterar o numero da Nota sugerida.                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ\Ù

Local lAvanca   := SuperGetMV("MV_LJAVANC")
Local cMV_TPNRNFS:= LjTpNrNFS()			// Retorno do parametro MV_TPNRNFS, utilizado pela Sx5NumNota() de onde serah controlado o numero da NF  1=SX5  2=SXE/SXF  3=SD9
Local cFilSx5   	:= If(FindFunction("LjFilSX5"),LjFilSX5(),xFilial("SX5"))  // Retorna Filial SX5 

PRIVATE lSX5Troca := .F.
PRIVATE aSerNFTrc[0]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz um tratamento diferenciado para o controle de NF pelo SD9 quando ³
//³ o parametro MV_TPNRNFS for igual a "3"                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cMV_TPNRNFS == "3"
	If Empty( cMvSerieTr )
		If !Sx5NumNota( Nil, cMV_TPNRNFS )
			Return .F.
		Else
			Return .T.
		Endif
	Else
		Return .T.
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o Parƒmetro MV_LJNFTRO estiver vazio, Desenha  ³
//³ a Telinha para escolha do Nota/Serie			    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cMvSerieTr)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso o Numero de Serie/Nota for autom tico ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SuperGetMV("MV_LJNFSXE")
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz o tratamento de pegar o numero da nota L via semaforo ou via    ³
		//³ SX5 (tabela 1)                                                           ³
		//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
		//³ Foi feito dessa forma devido as alteracoes feitas para o cliente Cepar   ³
		//³ de Joinville e para nao alterar o que ja temos em campo ja que estamos   ³
		//³ terminando o desenvolvimento da versao 7.10                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		cSerieDev	:= cMvSerieTr

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a serie estiver em branco abre a tela para a escolha do usuario³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If !Sx5NumNota(,SuperGetMV("MV_LJNRNFS",.F.,"2"))
		   Return .F.
		Endif
		cSerieDev   :=cSerie
		cNumTroc	:= NxtSx5Nota( cSerieDev,,'2',lAvanca )
        cNumTroc    := PadR( StrZero(Val(cNumTroc),Len(cNumTroc)) , TamSx3("F1_DOC")[1] )    
		If ! LjValNota(cSerieDev,cNumTroc) // Varifica se jah existe a nota
			Return .F.
		Endif
		While (GetSX8Len() > nSaveSx8 )
			ConfirmSX8()
		End
	
	Else
	
		vNumero := SPACE(TamSx3("F1_DOC")[1])
		
		DbSelectArea("SX5")
		While !lAbandona .AND. DbSeek( cFilSx5+"01",.F. ) .AND. !lDone
			
			lInterno := .T.
			While cFilial+"01" == X5_FILIAL+X5_TABELA .AND. !lAbandona
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se a S‚rie for CPF, n„o mostra no aChoice, pois ‚ utilizada ³
				//³ internamente para emissao de Cupom Fiscal.	   			    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (Alltrim(SX5->X5_CHAVE) == "CPF") .OR.;
					(Alltrim(SX5->X5_CHAVE) == "CP")
					DbSkip()
				Else
					If !MsRLock()
						lInterno    := .F.
						lDone   	:= .F.
						aSerNF  	:= {}
						If (++nCntErro > 10)
							lAbandona := .T.
						EndIf
					Endif
					
					If !lAbandona
						If !(ValType(aSerNF) == "A")
							aSerNF := {}
						EndIf
						
						lDone := .T.
						If cPaisLoc == "BRA"
							AADD( aSerNF,{ Padr( X5_CHAVE, 3 ), StrZero( Val( X5Descri() ), 6 ) } )
						Else
							AADD( aSerNF,{ Padr( X5_CHAVE, 3 ), StrZero( Val( X5Descri() ),12 ) } )
						EndIf
						DbSkip()
					EndIf
				EndIf
			End
		End
		
		If (Len(aSerNF) == 0) .OR. lAbandona
			MsUnLock()
			Help(" ",1,"A460FLOCK")
			Return(.F.)
		Endif
		
		nOpcA := 0
		While nOpcA <> 1
			DEFINE MSDIALOG oDlg TITLE cCadastro From 10,30 To 19,68 OF oMainWnd
			// Serie
			@ .5,.80 LISTBOX oQual VAR cVarQ Fields HEADER STR0016,cCadastro SIZE 130,42 ON DBLCLICK (aSerNF:=LjSx5Troca(oQual:nAt,aSerNF),oQual:Refresh()) NOSCROLL
			oQual:SetArray(aSerNF)
			oQual:bLine := { || {aSerNf[oQual:nAT,1],aSerNf[oQual:nAT,2]}}
			
			DEFINE SBUTTON FROM 51,109	TYPE 1 ACTION ;
			(If(LJ010ANF(oQual,aSernf,@cSerieDev,@cNumTroc),(	nOpcA := 1,	oDlg:End()),)) ENABLE OF oDlg
			
			ACTIVATE MSDIALOG oDlg
		End
		
		If !lSX5Troca
			vNumero := cNumTroc
		Endif
	
		DbSelectArea("SX5")	
		If DbSeek( cFilSx5+"01"+cSerieDev,.F. )
			MsRLock()
            SX5->X5_DESCRI  := PadR( StrZero(Val(cNumTroc)+1,Len(cNumNota)) , TamSx3("F1_DOC")[1] )     // Era: StrZero(Val(cNumTroc)+1,TamSx3("F1_DOC")[1])
			SX5->X5_DESCSPA := PadR( StrZero(Val(cNumTroc)+1,Len(cNumNota)) , TamSx3("F1_DOC")[1] )     // Era: StrZero(Val(cNumTroc)+1,TamSx3("F1_DOC")[1])
			SX5->X5_DESCENG := PadR( StrZero(Val(cNumTroc)+1,Len(cNumNota)) , TamSx3("F1_DOC")[1] )     // Era: StrZero(Val(cNumTroc)+1,TamSx3("F1_DOC")[1])
			MsUnLock()
		Else
			MsUnLock()
			Return(.F.)
		EndIf

	EndIf

Else

	DbSelectArea("SX5")
	DbSeek(cFilSx5+"01"+cMvSerieTr)
	If Eof()
		HELP(" ",1,"ERROSERIE")
		Return .F.
	EndIf
		
	cSerieDev	:= cMvSerieTr
	cNumTroc	:= NxtSx5Nota( cSerieDev )
    cNumTroc    := PadR( StrZero(Val(cNumTroc),Len(cNumTroc)) , TamSx3("F1_DOC")[1] )   
Endif

Return .T.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A020Limp()³ Autor ³ Vendas Clientes		³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Limpa os campos da Tela de Troca                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LojA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A020Limp(lZeraGet)
If lTrocLoja
	Help(" ",1,"NAOLIMPA" )
	Return .T.
Endif

If lZeraGet == Nil
	lZeraGet:=.F.
Endif
If lZeraGet
	If LojaOk(STR0017)       //Confirma Limpeza?
		//Zerar Acols
		nUsado:=0
		aCols:=aClone(aFirst)
		DbSelectArea("SX3")
		DbSeek( "SL2" )
		While !Eof() .AND. X3_ARQUIVO == "SL2"
			If (x3Uso(X3_USADO) .AND. cNivel >= X3_NIVEL .AND.	Alltrim(X3_CAMPO)<>"L2_NUM") .OR. Alltrim(X3_CAMPO) == "L2_ITEM"
				nUsado++
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta Array de 1 elemento ³
				//³ vazio. Se inclus„o. 		³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If X3_TIPO == "C"
					aCOLS[1][nUsado] := SPACE(X3_TAMANHO)
				ElseIf X3_TIPO == "N"
					aCOLS[1][nUsado] := 0
				ElseIf X3_TIPO == "D"
					aCOLS[1][nUsado] := dDataBase
				Else
					aCOLS[1][nUsado] := .F.
				EndIf
			EndIf
			DbSkip()
		End
		aCOLS[1][nUsado+1] := .F.
	Else
		Return .T.
	Endif
Endif
nTroc   :=0
nMerc   :=0
nTItens :=0
cLoja   := SuperGetMV("MV_LOJAPAD")
cCliente:= SuperGetMV("MV_CLIPAD")
DbSelectArea("SA1")
DbSeek(xFilial("SA1")+cCliente+cLoja)
cDescCli:=SA1->A1_Nome
oTroc:Refresh()
oMerc:Refresh()
oTItens:Refresh()
oCliente:Refresh()
oLoja:Refresh()
oDesc:Refresh()
oGet:ForceRefresh()
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ lj020Pos ³ Autor ³ Vendas Clientes		³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seta posicao dos campos                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LojA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function lj020Pos()

nPosUnit   := Ascan(aCampos,"L2_VRUNIT")
nPosTotal  := Ascan(aCampos,"L2_VLRITEM")
nPosValDes := Ascan(aCampos,"L2_VALDESC")
nPosDesc   := Ascan(aCampos,"L2_DESC   ")
nPosTes	   := Ascan(aCampos,"L2_TES")
nPosValIcm := Ascan(aCampos,"L2_VALICM")
nPosValIPI := Ascan(aCampos,"L2_VALIPI")
nPosValIss := Ascan(aCampos,"L2_VALISS")
nPosProd   := Ascan(aCampos,"L2_PRODUTO") 
nPosCProd  := Ascan(aCampos,"L2_PRODUTO")
nPosDescri := Ascan(aCampos,"L2_DESCRI")
nPosTabela := Ascan(aCampos,"L2_TABELA")
nPosQuant  := Ascan(aCampos,"L2_QUANT")
nPosBsIcms := Ascan(aCampos,"L2_BASEICM")
nPosLocal  := Ascan(aCampos,"L2_LOCAL")
nPosItem   := Ascan(aCampos,"L2_ITEM")
nPosUm	   := Ascan(aCampos,"L2_UM")
nPosPrcTab := Ascan(aCampos,"L2_PRCTAB")
nPosDscPro := Ascan(aCampos,"L2_DESCPRO")
nPco       := nPosPrcTab
nPosBrIcms := Ascan(aCampos,"L2_BRICMS")
nPosIcmsRet:= Ascan(aCampos,"L2_ICMSRET")

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LchoiceBar³ Autor ³ Vendas Clientes		³ Data ³27.01.97  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra a EnchoiceBar na tela                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Tmka010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LChoiceBar(oDlg1)
Local lLJ020BU1 := ExistBlock( "LJ020BU1" )
Local lLJ020BU2 := ExistBlock( "LJ020BU2" )
Local aRetB1
Local aRetB2
Local aButtons := {}

AAdd(aButtons, {"S4WB004N"    , {||A020Limp(.T.)} , STR0018 , STR0092 }) //"Limpa a tela" 	- "Limpa"
If Procname(3) == "LJ020TROCA"
   AAdd(aButtons, {"DBG06"    , {||Lj020Hist()}   , STR0019 , STR0093 }) //"Historico"    	- "Histor."
EndIf
AAdd(aButtons, {"SIMULACAO"   , {||Lj020Situac()} , STR0020 , STR0094 }) //"Situacao"     	- "Situac."
AAdd(aButtons, {"DBG09"       , {||Lj020Car()} 	  , STR0021 , STR0095 }) //"Caracteristica" - "Caract."
AAdd(aButtons, {"CARGA"       , {||Lj020Frete()}  , STR0087 , STR0087 }) //"Frete"          - "Frete"

If cPaisLoc == "BRA"
	AAdd(aButtons, {"RELATORIO"   , {||Lj020Reten()} 	   , STR0097 }) //"Retenções"
EndIf

If lLJ020BU1
	aRetB1 := ExecBlock( "LJ020BU1" )
	AAdd(aButtons, { aRetB1[ 1 ], aRetB1[ 2 ], aRetB1[ 3 ] , Left(aRetB1[ 3 ],8) } ) // Botão Genérico 1
EndIf

If lLJ020BU2
	aRetB2 := ExecBlock( "LJ020BU2" )
	AAdd(aButtons, { aRetB2[ 1 ], aRetB2[ 2 ], aRetB2[ 3 ] , Left(aRetB2[ 3 ],8) } ) // Botão Genérico 2
EndIf

EnchoiceBar(oDlg1,{|| A020Fimx(oDlg1) },{||oDlg1:End()},,aButtons)
Return nil



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj020Hist ³ Autor ³ Vendas Clientes		³ Data ³ 28.07.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Hist¢rico - ‚ possivel escolher um pedido e fazer a troca  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj020Hist()
Local oLbx
Local oLbx1
Local cIndex1
Local cIndex2
Local cKey
Local cCodPed
Local cFiltro
Local oHist
Local nHist
Local nCompl
Local aItems:={}

If Empty( cCliente )
	Help(" ",1,"SEM DADOS" )
	Return .T.
Endif

DbSelectArea( "SL1" )
DbSetorder(6)
If !DbSeek(xFilial("SL1")+cCliente+cLoja)
	Help(" ",1,"SEM DADOS" )
	Return .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Indice Condicional para a selecao dos pedidos do cliente selecionado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIndex1 := CriaTrab(Nil,.F.)
DbSelectArea("SL1")
DbSetorder(6)
DbGotop()
cFiltro:='L1_FILIAL == "'+xFilial("SL1")+'" .AND. L1_CLIENTE == "'+cCliente+'".AND. L1_LOJA == "'+cLoja+'"'
cKey	 := IndexKey()
IndRegua("SL1",cIndex1,cKey,,cFiltro,STR0022) // Selecionando Historico
DbGotop()

cCodPed:=SL1->L1_NUM

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra dados do Produto.												  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oHist FROM  48,171 TO 363,655 TITLE STR0019 PIXEL // Historico

// Ultimos Orcamentos\Vendas
// Orcamento Data Vendedor Operacao Valor
@	3,5 TO  136, 235 LABEL STR0024 OF oHist PIXEL
@	10,8 LISTBOX oLbx VAR nHist FIELDS SL1->L1_NUM,SL1->L1_EMISSAO,;
Lj020NomVen(),Lj020TpOpe(),Transform(SL1->L1_VLRLIQ,"@E 999,999,999.99");
HEADER STR0025,STR0026,STR0027,STR0028,STR0029;
ALIAS "SL1";
SIZE 225,60 OF oHist	PIXEL

oLbx:bChange := {||Lj020CargaP(oLbx,@cIndex2,oLbx1,@aItems)} // carrega os items do pedido
oLbx:Refresh()
oLbx:SetFocus(.T.)

// Produto Descri‡ao Quantidade
@ 75,8 LISTBOX oLbx1 VAR nCompl FIELDS SL2->L2_PRODUTO,Lj020NomPro(),Transform(SL2->L2_QUANT,"@E 99999.99");
HEADER STR0030,STR0031,STR0032;
ALIAS "SL2";
SIZE 225,60 OF oHist PIXEL

oLbx1:SetArray(aItems)
oLbx1:bLine:={||{aItems[oLbx1:nAt,1],;
aItems[oLbx1:nAt,2],;
aItems[oLbx1:nAt,3]}}

oLbx1:bLDblClick := {|| Lj020ProVisu(nil,oLbx1,1)}
oLbx1:Refresh()

DEFINE SBUTTON FROM 142,180 TYPE 1 ENABLE OF oHist ACTION (A020Btn1(@cNum_Troca,@cSerie_Tro),oHist:End())
DEFINE SBUTTON FROM 142,210 TYPE 2 ENABLE OF oHist ACTION (DbSetorder(1),oHist:End())

ACTIVATE MSDIALOG oHist CENTER

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta Arquivo Temporario e Restaura os Indices Ativos		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SL1")
Set Filter To
RetIndex("SL1")
DbSetorder(1)
If File(cIndex1+OrdBagExt())
	Ferase(cIndex1+OrdBagExt())
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj020SituaC ³ Autor ³ Vendas Clientes		³ Data ³ 23.03.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina para consultar a Situa‡„o Financeira do Cliente 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMKA010.PRW                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A020Btn1(cNum_Troca,cSerie_Tro)

If !lTrocLoja
	Help(" ",1,"NAOLOJA" )
	Return .T.
endif
cComprou:="S"
A020WTroca(@cNum_Troca,@cSerie_Tro)
DbSetorder(1)

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj020SituaC ³ Autor ³ Vendas Clientes		³ Data ³ 23.03.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina para consultar a Situa‡„o Financeira do Cliente 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMKA010.PRW                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj020SituaC()
Local nSaldoLC
Local nValItem
Local nLimCred
Local nMoeda
Local nSalPedL
Local nSalPed
Local nValAtraso  := 0
Local oDlg
Local nSalvEmp
Local cMCusto     := SuperGetMV("MV_MCUSTO")

PRIVATE aPos	  := {  8,  4, 11, 74 }
PRIVATE lFiltra   := .F.
PRIVATE cCadastro := STR0033 // Consulta Posi‡„o Clientes
PRIVATE wnrel     := "FINC010"



DbSelectArea("SA1")           // Posiciona cliente
DbSeek(xFilial("SA1")+cCliente+cLoja)

DbSelectArea("SM2")           // Posiciona moeda da data base
DbSeek(dDataBase,.T.)

cMCusto :=  If(SA1->A1_MOEDALC > 0, Alltrim(STR(SA1->A1_MOEDALC)), cMCusto)
nMoeda	:= If(SC5->C5_MOEDA < 2,1,SC5->C5_MOEDA)
nLimCred := xMoeda(SA1->A1_LC,Val(cMCusto),1,dDatabase)
nValItem := xMoeda((SC6->C6_PRCVEN * SC9->C9_QTDLIB),nMoeda,1,dDataBase)
nSalPedL := xMoeda(SA1->A1_SALPEDL,Val(cMCusto),1,dDataBase)
nSaldoLC := nLimCred - SA1->A1_SALDUP - nSalPedL
nSalPed	 := xMoeda(SA1->A1_SALPED,Val(cMCusto),1,dDataBase) + xMoeda(SA1->A1_SALPEDB,Val(cMCusto),1,dDataBase) - nValItem
nSalPed	 := If( nSalped < 0 , 0 , nSalPed )

nValAtraso := 0
nSalvEmp   := SM0->(Recno())
IF xFilial("SA1") == Space(FWGETTAMFILIAL) .AND. xFilial("SE1") <> Space(FWGETTAMFILIAL)
	// Pega o atraso de todas as filiais
	
	DbSelectArea("SM0")
	DbSeek(cEmpAnt)
	While !Eof() .AND. M0_CODIGO == cEmpAnt
		nValAtraso += AcumulaAtraso(FWGETCODFILIAL)
		DbSkip()
	End
Else
	nValAtraso := AcumulaAtraso(cFilAnt)
Endif
SM0->(dbGoto(nSalvEmp))

cDescri := Substr(SA1->A1_NOME,1,35)

// Consulta da Situa‡„o Financeira
DEFINE MSDIALOG oDlg FROM	125,3 TO 420,608 TITLE STR0034 PIXEL

@ 037, 005 TO 107, 135 LABEL "" OF oDlg  PIXEL
@ 037, 139 TO 107, 295 LABEL "" OF oDlg  PIXEL
@ 003, 004 TO 030, 295 LABEL "" OF oDlg  PIXEL

DEFINE SBUTTON FROM 117, 262 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

//@ 118, 011 BUTTON "Consulta"  SIZE 34, 11 FONT oDlg:oFont ACTION (Lj020Con() ) OF oDlg PIXEL

@ 017, 011 SAY STR0035 SIZE 23, 7 OF oDlg PIXEL // Cliente :
@ 017, 040 SAY cDescri						SIZE 96, 7 OF oDlg PIXEL

@ 017, 172 SAY STR0036 SIZE 21, 7 OF oDlg PIXEL // Risco :
@ 017, 201 SAY SA1->A1_RISCO				SIZE 11, 7 OF oDlg PIXEL

@ 044, 012 SAY STR0037 SIZE 53, 7 OF oDlg PIXEL // Limite de Credito :
@ 044, 071 SAY nLimCred 					SIZE 59, 7 OF oDlg PIXEL
@ 044, 145 SAY STR0038 SIZE 61, 7 OF oDlg PIXEL // Titulos Protestados :
@ 044, 212 SAY SA1->A1_TITPROT			SIZE 18, 7 OF oDlg PIXEL
@ 044, 240 SAY STR0039                 SIZE 11, 7 OF oDlg PIXEL // Em
@ 044, 259 SAY SA1->A1_DTULTIT			SIZE 30, 7 OF oDlg PIXEL

@ 053, 012 SAY STR0040 SIZE 53, 7 OF oDlg PIXEL // Saldo Duplicatas :
@ 053, 071 SAY SA1->A1_SALDUP 			SIZE 59, 7 OF oDlg PIXEL
@ 053, 145 SAY STR0041                 SIZE 62, 7 OF oDlg PIXEL // Cheques Devolvidos :
@ 053, 212 SAY SA1->A1_CHQDEVO			SIZE 18, 7 OF oDlg PIXEL
@ 053, 240 SAY STR0039					   SIZE 10, 7 OF oDlg PIXEL // Em
@ 053, 259 SAY SA1->A1_DTULCHQ			SIZE 30, 7 OF oDlg PIXEL

@ 062, 012 SAY STR0042                 SIZE 53, 7 OF oDlg PIXEL // Pedidos Liberados :
@ 062, 071 SAY nSalPedl 					SIZE 59, 7 OF oDlg PIXEL
@ 062, 145 SAY STR0043                 SIZE 53, 7 OF oDlg PIXEL // Maior Compra :
@ 062, 212 SAY SA1->A1_MCOMPRA			SIZE 59, 7 OF oDlg PIXEL

@ 071, 012 SAY STR0044 SIZE 53, 7 OF oDlg PIXEL // Saldo Lim.Credito :
@ 071, 071 SAY nSaldoLc 					SIZE 59, 7 OF oDlg PIXEL
@ 071, 145 SAY STR0045 SIZE 53, 7 OF oDlg PIXEL // Maior Duplicata :
@ 071, 212 SAY SA1->A1_MAIDUPL			SIZE 59, 7 OF oDlg PIXEL

@ 079, 012 SAY STR0046 SIZE 53, 7 OF oDlg PIXEL // Item Pedido Atual :
@ 079, 071 SAY nValItem 					SIZE 59, 7 OF oDlg PIXEL
@ 079, 212 SAY SA1->A1_METR				SIZE 18, 7 OF oDlg PIXEL
@ 079, 239 SAY STR0047 SIZE 25, 7 OF oDlg PIXEL // dias
@ 079, 145 SAY STR0048 SIZE 53, 7 OF oDlg PIXEL // M‚dia Atrasos :

@ 087, 012 SAY STR0049                 SIZE 53, 7 OF oDlg PIXEL // Saldo de Pedidos :
@ 087, 071 SAY nSalPed						SIZE 59, 7 OF oDlg PIXEL
@ 087, 145 SAY STR0050 SIZE 60, 7 OF oDlg PIXEL // Vencto.Lim.Cr‚dito :
@ 087, 207 SAY SA1->A1_VENCLC 			SIZE 30, 7 OF oDlg PIXEL

@ 096, 012 SAY STR0051                 SIZE 53, 7 OF oDlg PIXEL // Atraso Atual :
@ 096, 071 SAY nValAtraso					SIZE 59, 7 OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg
Return( Nil )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj020Car  ³ Autor ³ Vendas Clientes		³ Data ³ 13.11.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega Caracteristicas                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigatmk                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj020Car()
Local cProduto
Local cObs
Local oEstoque
Local oObs
Local nPosProd := aPosicoes[9][2]
Local nPedVen  := 0
Local nEmp	   := 0
Local nSalPedi := 0 
Local nReserva := 0
Local nStok2   := 0


cProduto:=aCols[n][nPosProd]

If Empty( cProduto )
	Help(" ",1,"SEM DADOS" )
	Return .T.
Endif

DbSelectArea( "SB1" )
DbSeek( xFilial("SB1") + cProduto )

DbSelectArea( "SB2" )
DbSetorder(1)
DbSeek( xFilial("SB2") + cProduto)

DbSelectArea( "SB0" )
DbSetorder(1)
DbSeek( xFilial("SB0") + cProduto )

DbSelectArea( "SB9" )
DbSeek( xFilial("SB9") + cProduto )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra dados do Produto.												  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Caracteristicas
DEFINE MSDIALOG oEstoque FROM  23,181 TO 325,523 TITLE STR0021 PIXEL

// Dados
@	8,2 TO	41, 169 OF oEstoque PIXEL
@ 51,2  TO	88, 169 OF oEstoque PIXEL
@ 98,2  TO 136,169  OF oEstoque   PIXEL

@ 2,2 	SAY STR0052 SIZE 56, 7 OF oEstoque PIXEL // Dados do Produto:
@ 16,4	SAY STR0053 SIZE 21, 7 OF oEstoque PIXEL // C¢digo
@ 15, 32 MSGET SB1->B1_COD		  SIZE 49, 9 OF oEstoque PIXEL When .F.

@ 16,  82 SAY STR0054 SIZE  25, 7 OF oEstoque PIXEL  // Unidade
@ 15, 103 MSGET SB1->B1_UM 		SIZE  8, 9 OF oEstoque PIXEL When .F.

@ 16, 127 SAY STR0055 SIZE  18, 7 OF oEstoque PIXEL // Grupo
@ 15, 143 MSGET SB1->B1_GRUPO 	SIZE  8, 9 OF oEstoque PIXEL When .F.

@ 30,  4	 SAY STR0031 SIZE  32, 7 OF oEstoque PIXEL // Descri‡„o
@ 29, 32  MSGET SB1->B1_DESC		SIZE 130, 9 OF oEstoque PIXEL When .F.

@ 40, 335 TO 40, 335 OF oEstoque PIXEL


@ 46, 3 SAY STR0056 SIZE  100, 7 OF oEstoque PIXEL // Estoque:
// Saldo
@ 57, 4	SAY STR0057 SIZE 33, 7 OF oEstoque PIXEL // Ped. Abertos
@ 57, 89 SAY STR0058 SIZE 30, 7 OF oEstoque PIXEL // Empenho
@ 67, 4	SAY STR0059 SIZE 30, 7 OF oEstoque PIXEL // a Entrar
@ 67, 89 SAY STR0060 SIZE 30, 7 OF oEstoque PIXEL // Reservado
@ 77, 4	SAY STR0061 SIZE 30, 7 OF oEstoque PIXEL // Atual

DbSelectArea( "SB2" )
nStok2  :=(SB2->B2_QATU)
nPedVen :=B2_QPedVen
nEmp	  :=B2_QEmp
nSalPedi:=B2_SalPedi
nReserva:=B2_Reserva

@ 56, 42  MSGET  nPedVen  Picture "@E 999999.9" SIZE 40, 9 OF oEstoque PIXEL When .F. RIGHT
@ 56, 124 MSGET  nEmp	  Picture "@E 999999.9" SIZE 40, 9 OF oEstoque PIXEL When .F. RIGHT
@ 66, 42  MSGET  nSalPedi Picture "@E 999999.9" SIZE 40, 9 OF oEstoque PIXEL When .F. RIGHT
@ 66, 124 MSGET  nReserva Picture "@E 999999.9" SIZE 40, 9 OF oEstoque PIXEL When .F. RIGHT
@ 76, 42  MSGET  nStok2   Picture "@E 999999.9" SIZE 40, 9 OF oEstoque PIXEL When .F. RIGHT

// Precos
@ 92,3 SAY STR0062 SIZE 53, 7 OF oEstoque PIXEL   // Pre‡os de Venda:
@ 105,6 SAY "1 -"  SIZE 11, 7 OF oEstoque PIXEL
@ 115,6 SAY "2 -"  SIZE 11, 7 OF oEstoque PIXEL
@ 125,6 SAY "3 -"  SIZE 11, 7 OF oEstoque PIXEL

@ 103, 18 MSGET SB0->B0_PRV1 Picture "@E 9,999,999.99" SIZE 49, 9 OF oEstoque PIXEL When .F.
@ 113, 18 MSGET SB0->B0_PRV2 Picture "@E 9,999,999.99" SIZE 49, 9 OF oEstoque PIXEL When .F.
@ 123, 18 MSGET SB0->B0_PRV3 Picture "@E 9,999,999.99" SIZE 49, 9 OF oEstoque PIXEL When .F.

//Carrego as caracterististicas do produto
cObs := MSMM(SB1->B1_CODOBS,TamSx3("B1_OBS")[1])
@	103, 70 GET oObs VAR cObs OF oEstoque MEMO size 95,29  PIXEL READONLY

DEFINE SBUTTON FROM 137,139 TYPE 1	ACTION (nOpca := 1,oEstoque:End()/*,oGet:ForceRefresh(),oGet:oBrowse:Refresh(.F.),oGet:oBrowse:SetFocus()*/) ENABLE OF oEstoque

ACTIVATE MSDIALOG oEstoque CENTER

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj020con	³ Autor ³ Vendas Clientes		³ Data ³ 26.06.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina para consultar dados da Situa‡„o Financeira Cliente ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMK010A.PRW                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj020con()
Local nRegSC9 := SC9->(Recno())
Local nOrdSC9 := SC9->(IndexOrd())
Local nRegSC5 := SC5->(Recno())
Local nOrdSC5 := SC5->(IndexOrd())
Local nRegSC6 := SC6->(Recno())
Local nOrdSC6 := SC6->(IndexOrd())
Local nRegSM2 := SM2->(Recno())
Local nOrdSM2 := SM2->(IndexOrd())
Local nRegSF4 := SF4->(Recno())
Local nOrdSF4 := SF4->(IndexOrd())
Local nRegSB2 := SB2->(Recno())
Local nOrdSB2 := SB2->(IndexOrd())
Local nRegSA1 := SA1->(Recno())
Local nOrdSA1 := SA1->(IndexOrd())

Private nPula := 200 		 //Variaveis usada no FINC010
Private nTotal1 := 0, nTotal2 :=0, nTotal3a := 0,;
nTotal3b:= 0, nTotal3c:= 0
Private aTotRec1	:= {0,0}
Private aTotRec2	:= {0,0}
Private aTotPed	:= {0,0,0,0}
Private aTotFat	:= {0,0}
Private cArqRec1	:= ""
Private cArqRec2	:= ""
Private cArqPed	:= ""
Private cArqFat	:= ""
DbSelectArea("SA1")

Pergunte("FIC010",.T.)
// fun‡„o do FINC010.PRW
//Fc010Con()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade dos dados                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("SA1")
DbSetorder(nOrdSA1)
Go nRegSA1

DbSelectArea("SC5")
DbSetorder(nOrdSC5)
Go nRegSC5

DbSelectArea("SC6")
DbSetorder(nOrdSC6)
Go nRegSC6

DbSelectArea("SM2")
DbSetorder(nOrdSM2)
Go nRegSM2

DbSelectArea("SF4")
DbSetorder(nOrdSF4)
Go nRegSF4

DbSelectArea("SB2")
DbSetorder(nOrdSB2)
Go nRegSB2

DbSelectArea("SC9")
DbSetorder(nOrdSC9)
Go nRegSC9

Return( Nil )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj020NomVen³ Autor ³Vendas Clientes		 ³ Data ³25/11/97  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Busca o nome do vendedor na tabela                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Loja020                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj020NomVen()
Local cDesc
Local cAliasOld

cAliasOld := Alias()
DbSelectArea("SA3")
DbSetorder(1)
cDesc := ""
If DbSeek(xFilial("SA3")+SL1->L1_VEND)
	cDesc := SA3->A3_NOME
Endif
DbSelectArea(cAliasOld)
Return cDesc

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj020TpOpe ³ Autor ³Vendas Clientes		 ³ Data ³25/11/97  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Busca o tipo de operacao realizada no pedido selecionado     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Loja020                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj020TpOpe()
Local cDesc

cDesc := ""
If !Empty(Alltrim(SL1->L1_DOC))
	cDesc := STR0063   // Faturamento
Else
	cDesc := STR0064   // Or‡amento
Endif
Return cDesc

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj020CargaP³ Autor ³ Vendas Clientes		 ³ Data ³ 25/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega os items gravados em cada pedido selecionado         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigatmk                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj020CargaP( oLbx  ,cIndex  ,oLbx1  ,aItems )
Local cCodPed

// Pego o codigo do pedido
cCodPed := Eval(oLbx:bLine)[1]
aItems  := {}
DbSelectArea("SL2")
DbSetorder(1)
DbSeek(xFilial("SL2")+cCodPed)
While ! Eof() .AND. (L2_FILIAL+L2_NUM == xFilial("SL2")+cCodPed)
	Aadd(aItems,{SL2->L2_PRODUTO,Lj020NomPro(),Transform(SL2->L2_QUANT,"@E 99999.99")})
	DbSkip()
End

oLbx1:SetArray(aItems)
oLbx1:bLine:={||{aItems[oLbx1:nAt,1],;
aItems[oLbx1:nAt,2],;
aItems[oLbx1:nAt,3]}}
oLbx1:Refresh()
oLbx:SetFocus()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj020NomPro³ Autor ³Vendas Clientes		 ³ Data ³25/11/97  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Busca o nome do produto na tabela                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Loja020                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj020NomPro()
Local cDesc
Local cAliasOld

cAliasOld := Alias()
DbSelectArea("SB1")
DbSetorder(1)
cDesc := ""
If DbSeek(xFilial("SB1")+SL2->L2_PRODUTO)
	cDesc := SB1->B1_DESC
Endif
DbSelectArea(cAliasOld)
Return cDesc

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj020ProVisu  ³ Autor ³ Vendas Clientes		³ Data ³ 13/08/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exibe a tela de visualiza‡Æo de produto                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigatmk                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj020ProVisu( aCompl  ,oLbx  ,nPos )
Local nHist		 := 0
Local bCampo	 := ""
Local cAlias	 := Alias()
Local cCodProd   := ""                                     

Private cCadastro:= STR0066  // Cadastro de Produtos
Private aTELA[0][0],aGETS[0]

DbSelectArea("SB1")
DbSetorder(1)
If aCompl <> NIL
	nHist:=oLbx:nAt
	DbSeek(xFilial("SB1")+aCompl[oLbx:nAt][nPos])
Else
	cCodProd := Eval(oLbx:bLine)[nPos]
	DbSeek(xFilial("SB1")+cCodProd)
Endif
INCLUI := .F.
if found()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a entrada de dados do arquivo 								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bCampo := {|nCPO| Field(nCPO) }
	
	AxVisual("SB1",RECNO(),2)
	
	DbSelectArea(cAlias)
	Return .T.
Endif

Return .F.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AcumulaAtraso³ Autor ³ Vendas Clientes	³ Data ³ 27.12.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Somar os titulos em atraso da filial                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMKA010.PRW                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AcumulaAtraso(cFilNew)
Local cSalvFil   := cFilAnt
Local nValAtraso := 0
Local cAlias 	 := Alias()

cFilAnt := cFilNew

DbSelectArea("SE1")
DbSetorder(8)
DbSeek(xFilial("SE1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI+"A")
While !Eof() .AND. SE1->E1_FILIAL == xFilial("SE1") .AND. ;
	E1_CLIENTE+E1_LOJA == SC5->C5_CLIENTE+SC5->C5_LOJACLI .AND. SE1->E1_STATUS == "A"
	If dDataBase > SE1->E1_VENCREA
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso o t¡tulo seja de qualquer natureza credora (-) o saldo  ³
		//³ deve ser abatido. Os t¡tulos tipo RA (Receb.Antecipado),	  ³
		//³ NCC (Nota de Cr‚dito) e PR (Provis¢rio) n„o precisam de 	  ³
		//³ tratamento especial. Bops 00323-A									  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE1->E1_TIPO $ MVABATIM
			nValAtraso += xMoeda( SE1->E1_SALDO , SE1->E1_MOEDA , 1 )
		ElseIF ! SE1->E1_TIPO $ MVRECANT+"/"+MVPROVIS+"/"+MV_CRNEG
			nValAtraso -= xMoeda( SE1->E1_SALDO , SE1->E1_MOEDA , 1 )
		Endif
	Endif
	DbSkip()
End
DbSetorder(1)

cFilAnt := cSalvFIl
DbSelectArea(cAlias)

Return (nValAtraso)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A020Form     ³ Autor ³ Vendas Clientes	³ Data ³ 27.12.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checar se o formulario da nota e proprio                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Loja020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A020Form()
Local lRetorno 	:= .T.	//Retorno da funcao
Local lFormPro	:= .T. //Retorno do Ponto de Entrada

If Empty( cScriptTro )
	Return lRetorno
Endif

If ExistBlock( "LJ020FORM" )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para a utilizacao do formulario proprio para a nota fiscal ou nao.³
	//³Sem a necessidade da apresentacao da tela com a pergunta.                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lFormPro := ExecBlock( "LJ020FORM", .F., .F. )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida o retorno do Ponto de Entrada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Valtype( lFormPro ) == "L"
		If lFormPro
			cFormPro := "S"
		Else
			cFormPro := "N"
		EndIf
	EndIf	
Else
	// Formul rio pr¢prio para a Nota Fiscal de Entrada ?
	If LojaOk( STR0067 )
		cFormPro := "S"
	Else
		cFormPro := "N"
	EndIf
EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj020Imp  ³ Autor ³ Vendas Clientes	 	³ Data ³ 28/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a impressora esta ativa e pergunta se imprime  ³±±
±±³          ³ a nota fiscal de entrada.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LojA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function lj020Imp()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pergunta se imprime a nota fiscal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Imp. Nota Entrada?
If ! SuperGetMV("MV_PERGNOT") .OR. LojaOk(STR0068)
	Lojr110(cNumTroc,cSerieDev)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Lj020ZeraGet³ Autor ³ Vendas Clientes	³ Data ³ 19/11/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Agrega ceros a la izquierda de la variable que se ingresa  ³±±
±±³          ³ Como parametro. Para ser usada en las entradas de ciertos  ³±±
±±³          ³ campos, con la funcion Valid.Formato de Argentina          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Lj020ZeraGet( @cCaptura )                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj020ZeraGet( cCaptura )
If !Empty(cCaptura)
	cCaptura:=StrZero(Val(cCaptura),Len(cCaptura))
Endif                                                   

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Lj020ActVar ³ Autor ³ Vendas Clientes	³ Data ³ 12/11/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Actualiza variables usadas en objetos.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  A100ActVar(@cActual,cPrim,cSec)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj020ActVar( cActual  ,cPrim  ,cSec )

If cPaisLoc == "ARG"
   cActual:=cPrim+cSec
Else
   cActual:=cSec
EndIf   
   
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj020Evali³ Autor ³ Vendas Clientes	    ³ Data ³ 04.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de Linha Ok da Troca                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj020Evali(o)
Local lRet	:= .T.
Local nDecs := MsDecimais(If(Type("nMoedaTr")=="N",nMoedaTr,1))

//Disponibiliza itens no acols
If !lTrocLoja
	lRet:=.T.
endif

If aCols[n][nPosQuant] = 0
	aCols[n][nPosQuant] := 1
EndIf

// verifica a quantidade devolvida para troca da loja
If lTrocLoja .AND. aCols[n][nPosQuant] > aQtde[n]
	Help(" ",1,"LJ020QUANT")
	aCols[n][nPosQuant] := aQtde[n]
	M->L2_QUANT := aQtde[n] 
	Return .F.
EndIf

If Empty(aCols[n][nPosProd]) .AND. !aCols[n][nUsado+1]
	Help(" ",1,"A010VAZ")
	Return .F.
Endif       

DbSelectArea("SE4")
DbSetorder(1)
If DbSeek(xFilial("SE4")+SL1->L1_CONDPG)
	If (SE4->E4_DESCFIN > 0) .AND. (SL1->L1_DESCNF == 0)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se houver descto. financeiro, ele deve ser tambem  ³
		//³ descontado no valor de cada item (aCols)           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    aCOLS[n][nPosTotal]	:= aCOLS[n][nPosPrcTab] * aCOLS[n][nPosQUANT]  //Usa preco de tabela para iniciar o calculo
	    aCOLS[n][nPosTotal]	:= Round( aCOLS[n][nPosTotal]  - (aCOLS[n][nPosTotal] * (SE4->E4_DESCFIN / 100) ) ,nDecs)
	    aCOLS[n][nPosUnit]	:= Round( aCOLS[n][nPosTotal]  / aCOLS[n][nPosQUANT] ,nDecs)

		//Atualiza a tela do browse ...
		oGet:oBrowse:Refresh()
	Endif
Endif

// Verifica se preencheu a localizacao do produto
If lRet
	lRet := Lj020VLoc()
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj020Desc ³ Autor ³ Vendas Clientes	    ³ Data ³ 04.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizacao da descricao do cliente                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj020Desc( cDescCli  ,oDesc  ,cCLiente  ,cLoja )
DbSelectArea("SA1")
DbSetorder(1)
If DbSeek(xFilial("SA1")+cCliente+cLoja)
	cDescCli :=SA1->A1_NOME
Else
	cDescCli := PADR(STR0075,Len(SA1->A1_NOME))
Endif

oDesc:Refresh()

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj020VerNFºAutor  ³Vendas Clientes	 º Data ³  16/11/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se jah existe a nota fiscal de entrada cadastrada  º±±
±±º          ³na base.                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj020VerNF( cNota,cSerie )
Local lFound
Local nTamF1_DOC := TamSX3("F1_DOC")[1]     // Tamanho do campo F1_DOC                  

cNota            := PadR(cNota,nTamF1_DOC)  

SF1->(DbSetorder(1))
lFound := SF1->(DbSeek(xFilial("SF1")+cNota+cSerie))

If lFound
	MsgStop(STR0077)  // "Nota Fiscal e Série já existem na base de dados. Entre com outra série para validar o lanÇamento."
Endif

Return lFound

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Lj020VLoc³ Autor ³ Vendas Clientes	    ³ Data ³ 21.12.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Nao permitir finalizar a troca se a localizacao de algum	  ³±±
±±³          ³ produto nao estiver preenchida.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ EXPL1 - Indica se deve ou nao verificar se todos os itens  ³±±
±±³          ³         que sao controlados por localizacao estao com a    ³±±
±±³          ³         mesma preenchida. .F. (nao verif.) e' o padrao	  ³±±
±±³          ³ EXPL2 - Indica se esta validando apos o enter do campo	  ³±±
±±³          ³         localiza da MsGetDados()                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj020VLoc( lTodos, lColuna )
Local lRet 		// .T. (Padrao) se todos os produtos tiverem localizacao
Local nCol      // Coluna do MSGetDados
Local nLin      // Linha  do MSGetDados
Local cProduto
Local cLocaliz

lRet    := .T.
lTodos  := If( lTodos  == NIL, .F., lTodos )
lColuna := If( lColuna == NIL, .F., lColuna)

If lTodos
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica em todos os produtos que forem controlados por localizacao se a    ³
	//³ localizacao foi deixada em branco. Caso afirmativo, da mensagem e nao deixa ³
	//³ prosseguir.                                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nLin := 1 to Len( aCols )
		
		For nCol := 1 to Len( aHeader )
			If LTrim( aHeader[nCol][2] ) == "L2_PRODUTO"
				cProduto := aCols[n][nCol]
			ElseIf LTrim( aHeader[nCol][2] ) == "L2_LOCALIZ"
				cLocaliz := aCols[n][nCol]
			EndIf
		Next nCol
		
		If Localiza( cProduto ) .AND. Empty( cLocaliz )
			MsgStop( STR0078 + cProduto )
			lRet := .F.
			Exit
		EndIf
		
	Next nLin
	
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica apenas no produto atual, se for controlado por localizacao, se a   ³
	//³ localizacao foi deixada em branco. Caso afirmativo, da mensagem e nao deixa ³
	//³ prosseguir.                                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCol := 1 to Len( aHeader )
		If LTrim( aHeader[nCol][2] ) == "L2_PRODUTO"
			cProduto := aCols[n][nCol]
		ElseIf LTrim( aHeader[nCol][2] ) == "L2_LOCALIZ"
			cLocaliz := aCols[n][nCol]
		EndIf
	Next nCol
	
	If Localiza( cProduto ) .AND. Empty( If( lColuna, M->L2_LOCALIZ, cLocaliz ) )
		MsgStop( STR0078 + cProduto )
		lRet := .F.
	EndIf
EndIf

Return( lRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Lj020CTot³ Autor ³ Vendas Clientes	    ³ Data ³ 21.12.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula valor total e valor total das mercadorias da rotina³±±
±±³          ³ de troca da loja e outra loja.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj020CTot()
Local nI
Local nC
Local nE

nMerc   := 0
nTroc   := 0
nTItens := 0
nDescont:= 0
For nI := 1 to Len(aCols)
	If !(aCols[nI][nUsado+1])		 // Se nao estiver Deletado
		nTItens ++
		nDescont += aCols[nI][nPosValDes]
		If cPaisLoc == "BRA"
			If ( nPosTotal > 0 .AND. nPosValIpi > 0 )
				nMerc+=aCols[nI][nPosTotal]+aCols[nI][nPosValIpi]
				nTroc+=aCols[nI][nPosTotal]+aCols[nI][nPosValIpi]
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Considerar todos os impostos que incidem no Total da Nota ³
			//³ baseando se na Roteiro Amarracao Tes X Impostos.          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMerc+=aCols[nI][nPosTotal]
			nTroc+=aCols[nI][nPosTotal]
			cTesImp := aCols[nI][nPosTes]
			aImposto := DefImposto( cTesImp )
			For nC := 1 To Len(aImposto)
				cImposto := aImposto[nC][2]
				For nE := 1 To Len(aHeader)
					If Subs(aHeader[nE][2],4,7) == cImposto .AND. aImposto[nC][3] == "1"  //Determina se imposto incide ou nao na nota
						nTroc += aCols[nI][nE]
					EndIf
				Next nE
			Next nC
		EndIf
	EndIf
Next nI
oTroc:Refresh()
oMerc:Refresh()
oTItens:Refresh()

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj020GeraLF ³ Autor ³ Vendas Clientes	      ³ Data ³ 04.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava os registros de Livros Fiscais de devolucao(Loc.)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA020                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj020GeraLF()
Local nC
Local nI
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o Arquivo de Livros Fiscais "SF3"  c/Base  na  nova   ³
//³ estrutura de gera‡Æo de Livro "aLivroF"p/Clientes que utili-³
//³ zam a Amarra‡ao TesXImpostos e F¢rmula/Rotina de Apura‡ao   ³
//³ do Livro "F4_LIVRO" (Internacionaliza‡„o).                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nC := 2 To Len( aLivroF )
   RecLock( "SF3",.T. )
   For nI := 1 To Len( aLivroF[1] )
      SF3->( FieldPut(FieldPos(aLivroF[1,nI]),aLivroF[nC,nI]) )
   Next nI
   REPLACE SF3->F3_FILIAL  WITH xFilial("SF3")
   REPLACE SF3->F3_NFISCAL WITH cNFiscal
   REPLACE SF3->F3_SERIE   WITH cSerie
   REPLACE SF3->F3_CLIEFOR WITH SF1->F1_FORNECE
   REPLACE SF3->F3_LOJA    WITH SF1->F1_LOJA
   REPLACE SF3->F3_TIPO    WITH "D"
   REPLACE SF3->F3_ESPECIE WITH "NCC"	
   REPLACE SF3->F3_TIPOMOV WITH "V"   
   MsUnLock()
Next nC		

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³VQuant    ³ Autor ³ Vendas Clientes	    ³ Data ³ 10/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Gatilhos do Campo Quantidade (L2_QUANT)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VQuant()
Local aImposto   := {}
Local nY         := 0
Local nPosBase
Local nPosValImp
Local nVlrUni    := aCols[N][nPosUnit]

If aCols[n][nPosQuant] > aQtde[n] .OR. M->L2_QUANT > aQtde[n]
	aCols[n][nPosQuant] := aQtde[n]
	M->L2_QUANT := aQtde[n]
	Help(" ",1,"LJ020QUANT")
EndIf
If lExistNota
	M->L2_PRCTAB  := aCols[n][nPosPrcTab]
	M->L2_DESC	  := aCols[n][nPosDesc]
	M->L2_VALDESC := Round((M->L2_PRCTAB * M->l2_QUANT)*(M->L2_DESC/100),2)
	M->L2_VRUNIT  := NoRound(nVlrUni-(nVlrUni*M->L2_DESC/100),2)
	M->L2_VLRITEM := NoRound(nVlrUni*M->L2_QUANT,2)-(M->L2_VALDESC)
	aCols[n][nPosValDes]:= M->L2_VALDESC
	aCols[n][nPosUnit]  := M->L2_VRUNIT
	aCols[n][nPosTotal] := M->L2_VLRITEM
	If cPaisLoc == "BRA"
		M->L2_VALIPI :=lj010IPI(M->L2_PRCTAB,M->l2_QUANT,M->L2_DESC,0,M->L2_TES,n,M->L2_PRODUTO,M->L2_VALFRE,M->L2_SEGURO,M->L2_DESPESA)
		aCols[n][nPosValIPI] := M->L2_VALIPI
		M->L2_VALICM :=LJ010ICMS(n,,M->L2_VLRITEM,,M->L2_VALIPI)
		aCols[n][nPosValIcm] := M->L2_VALICM
		M->L2_VALISS :=LJ010ISS(M->L2_VLRITEM,,,,)
		aCols[n][nPosValIss] := M->L2_VALISS
		M->L2_BASEICM := M->L2_VLRITEM
		aCols[n][nPosBsIcms] := M->L2_VLRITEM
	Else
		Lj020CTot()
		aImposto   := RoteiroCalc(nMerc,,"D")
		For nY := 1 To Len(aImposto[n][6])
			nPosBase  := Ascan(aCampos,aImposto[n][6][nY][7])
			nPosValImp:= Ascan(aCampos,aImposto[n][6][nY][6])
			&("M->"+(aImposto[n][6][nY][7])) := aImposto[n][6][nY][3]
			aCols[n][nPosBase]  := &("M->"+(aImposto[n][6][nY][7]))                //Base do Imposto
			&("M->"+(aImposto[n][6][nY][6])) := Round(aImposto[n][6][nY][4],MsDecimais(nMoedaTr))
			aCols[n][nPosValImp]:= &("M->"+(aImposto[n][6][nY][6]))                //Valor do Imposto
		Next
		Lj020CTot()
	Endif
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ValTES    ³ Autor ³ Vendas Clientes	    ³ Data ³ 21/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Gatilhos do Campo TES (L2_TES)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ValTES()
Local aImposto  := {}
Local nPosCF    := Ascan(aHeader,{|x|Alltrim(x[2])=="L2_CF"})
Local lRet      := .T.

SF4->(DbSetorder(1))
If M->L2_TES < "500" .AND. SF4->(DbSeek(xFilial("SF4")+M->L2_TES))

   aCols[n][nPosTES]:= M->L2_TES

   aImpVarSD1 := {aCols[n][nPosQuant],aCols[n][nPosUnit],aCols[n][nPosQuant]*aCols[n][nPosUnit],0,0,{}}
   aImposto   := CalcImpDev(nMerc)
   If SF4->(DbSeek(xFilial("SF4")+M->L2_TES))
      aCols[n][nPosCF]  := SF4->F4_CF
      M->L2_CF           := aCols[n][nPosCF]   
   EndIf
   Lj020CTot()   
Else
   lRet := .F.      
EndIf

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³Lj020ValPr³ Autor ³ Vendas Clientes	    ³ Data ³ 09/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Gatilhos do Campo Produto (L2_PRODUTO)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj020ValProd()
Local aAreaAtu   := GetArea()
Local lRet	     := .F.
Local nPosDesc   := Ascan(aHeader,{|x|Subs(x[2],1,9)=="L2_DESCRI"})
Local nPosTes    := Ascan(aHeader,{|x|Subs(x[2],1,6)=="L2_TES"})
Local nPosCFO    := Ascan(aHeader,{|x|Subs(x[2],1,5)=="L2_CF"})
Local nPosProd   := Ascan(aHeader,{|x|Subs(x[2],1,10)=="L2_PRODUTO"})
Local cCodProd   := If(ReadVar()=="M->L2_PRODUTO",&(ReadVar()),aCols[n][nPosProd])
Local cTes       := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !(FindFunction("SIGACUS_V") .AND. SIGACUS_V() >= 20050512)
    Final("Atualizar SIGACUS.PRW !!!")
Endif
IF !(FindFunction("SIGACUSA_V") .AND. SIGACUSA_V() >= 20050512)
    Final("Atualizar SIGACUSA.PRX !!!")
Endif
IF !(FindFunction("SIGACUSB_V") .AND. SIGACUSB_V() >= 20050512)
    Final("Atualizar SIGACUSB.PRX !!!")
Endif

SB1->(DbSetorder(1))
If SB1->(DbSeek(xFilial("SB1")+cCodProd))
	//Indica que existe o produto cadastrado no arquivo SB1...
	lRet := .T.
					
	If nPosDesc > 0
		aCols[n][nPosDesc] := SB1->B1_DESC
	EndIf
				 
	SF4->(DbSetorder(1))
	If SF4->(DbSeek(xFiliaL("SF4")+If(!Empty(RetFldProd(SB1->B1_COD,"B1_TS")),RetFldProd(SB1->B1_COD,"B1_TS"),SuperGetMV("MV_TESSAI")))) .AND. (nPosTes > 0)
	    If !Empty(SF4->F4_TESDV)
		   cTes := SF4->F4_TESDV
	    Else
		   cTes := SuperGetMV("MV_TESTROC")
		EndIf
		SF4->(DbSeek(xFiliaL("SF4")+cTes))		
		aCols[n][nPosTes] := SF4->F4_CODIGO
		M->L2_TES := aCols[n][nPosTes]		
	EndIf
	
	If (nPosCFO > 0) .AND. (nPosTes > 0)
		aCols[n][nPosCFO] := SF4->F4_CF
		M->L2_CFO := SF4->F4_CF
	EndIf
		                  
	//Restaura a areA original...
	RestArea(aAreaAtu)
	
	If Type("oBtOk") == "O"
		SetKey(15,oBtOk:bAction)
	EndIf
		
	If Type("oBtCan") == "O"
		SetKey(24,oBtCan:bAction)
	EndIf
		                      
	//Atualiza os dados...
	oGet:oBrowse:Refresh()

EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj020Leg  ºAutor  ³Vendas Clientes	 º Data ³  18/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Legenda da MBrowse da tela de troca / devolucoes            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Loja020                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj020Leg()
Local aLegenda := { {"BR_MARROM",	STR0086 },;		//"Devoluções pendentes"
					{"BR_VERMELHO",	STR0083 },;		//"Vendas efetuadas"
					{"BR_VERDE",	STR0082 },;		//"Orçamentos em aberto"
					{"BR_AZUL",		STR0084 },;		//"Pedidos encerrados"
					{"BR_BRANCO",	STR0096 }}		//"Transação TEF desfeita"
BrwLegenda(STR0085,STR0081,aLegenda)	//	"Orçamentos" | "Legenda"
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOJA020A  ºAutor  ³Vendas Clientes	 º Data ³  26/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se serah incluido o valor do frete + seguro +      º±±
±±º          ³despesas na nota de devolucao                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA020                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj020Frete()
Local nVlrFrete		:= aFrete[1]
Local nVlrDespesa	:= aFrete[2]
Local nVlrSeguro	:= aFrete[3]
Local lConfirma		:= .F.
Local oDlgFrete
Local oVlrFrete
Local oVlrDespesa
Local oVlrSeguro

DEFINE MSDIALOG oDlgFrete FROM  23,80 TO 105,582 TITLE STR0090 PIXEL // "Dados do Frete"

@ 003,004 TO 023,245 LABEL STR0091 OF oDlgFrete  PIXEL	// "Valores"

@ 010,010 SAY STR0087 OF oDlgFrete PIXEL	// "Frete"
@ 009,044 MSGET oVlrFrete VAR nVlrFrete Picture "@E 99,999,999.99" SIZE 40,8 OF oDlgFrete PIXEL

@ 010,090 SAY STR0088 OF oDlgFrete PIXEL	// "Seguro"
@ 009,123 MSGET oVlrSeguro VAR nVlrSeguro Picture "@E 99,999,999.99" SIZE 40,8 OF oDlgFrete PIXEL

@ 010,170 SAY STR0089 SIZE 30,10 OF oDlgFrete PIXEL	// "Despesas"
@ 009,200 MSGET oVlrDespesa VAR nVlrDespesa Picture "@E 99,999,999.99" SIZE 40,8 OF oDlgFrete PIXEL 
oVlrDespesa:cSx1Hlp:="NVLRDESPES"

DEFINE SBUTTON FROM 025,185 TYPE 1 ACTION ( lConfirma := .T., oDlgFrete:End() ) ENABLE OF oDlgFrete
DEFINE SBUTTON FROM 025,220 TYPE 2 ACTION ( oDlgFrete:End() ) ENABLE OF oDlgFrete

ACTIVATE MSDIALOG oDlgFrete CENTERED

If lConfirma
	// Primeiro retira os valores que jah havia sido informados
	nCredito -= (aFrete[1] + aFrete[2] + aFrete[3])
	nTroc -= (aFrete[1] + aFrete[2] + aFrete[3])
	                                                
	// Alimenta o array com os valores informados
	aFrete := { nVlrFrete, nVlrSeguro, nVlrDespesa }
	
	// Ajusta o valore dos credito
	nCredito += (aFrete[1] + aFrete[2] + aFrete[3])
	nTroc += (aFrete[1] + aFrete[2] + aFrete[3])
	
	// Atualiza as variaveis na tela
	oTroc:Refresh()
Endif	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ020RetenºAutor  ³Vendas Clientes	 º Data ³ 27/05/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se serah retirado o valor do PIS - COFINS - CSLL   º±±
±±º          ³do credito do cliente.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA020                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj020Reten()
Local nVlrPis  		:= LJ020SumRet(1)
Local nVlrCSLL  	:= LJ020SumRet(2)
Local nVlrCofins	:= LJ020SumRet(3)
Local nVlrISS       := LJ020SumRet(4)
Local oDlgRet
Local oVlrPis
Local oVlrCSLL
Local oVlrCofins
Local oVlrISS

DEFINE MSDIALOG oDlgRet FROM  23,80 TO 135,420 TITLE STR0098 PIXEL // "Dados de Retencao (PIS/COFINS/CSLL)"

@ 003,004 TO 038,167 LABEL STR0091 OF oDlgRet  PIXEL //"Valores"

@ 010,010 SAY STR0099 OF oDlgRet PIXEL	//"Vlr. PIS"
@ 009,044 MSGET oVlrPis VAR nVlrPis WHEN .F. Picture "@E 99,999,999.99" SIZE 40,8 OF oDlgRet PIXEL

@ 010,090 SAY STR0100 OF oDlgRet PIXEL	//"Vlr. COFINS"
@ 009,123 MSGET oVlrCofins VAR nVlrCofins WHEN .F. Picture "@E 99,999,999.99" SIZE 40,8 OF oDlgRet PIXEL

@ 024,010 SAY STR0101 SIZE 30,10 OF oDlgRet PIXEL	//"Vlr. CSLL"
@ 023,044 MSGET oVlrCSLL VAR nVlrCSLL WHEN .F. Picture "@E 99,999,999.99" SIZE 40,8 OF oDlgRet PIXEL

@ 024,090 SAY STR0103 OF oDlgRet PIXEL	//"Vlr. ISS"
@ 023,123 MSGET oVlrISS VAR nVlrISS WHEN .F. Picture "@E 99,999,999.99" SIZE 40,8 OF oDlgRet PIXEL

DEFINE SBUTTON FROM 042,140 TYPE 1 ACTION ( oDlgRet:End() ) ENABLE OF oDlgRet

ACTIVATE MSDIALOG oDlgRet CENTERED

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ020RecCoºAutor  ³Vendas Clientes	 º Data ³ 29/04/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Recalculo das comissoes.                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA020                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ020RecComis( cSerie     ,cNumNota  ,cNumPdv  ,cPrefixo  ,;
                               nBaseComis ,nDecs     )
Local aArea   := GetArea()
Local aAreaL1 := SL1->(GetArea())

cNumNota := PadR( StrZero(Val(cNumNota),Len(cNumNota)) , TamSx3("L1_DOC")[1] )

DbSelectArea("SL1")
DbSetorder(2) 
If DbSeek(xFilial("SL1")+cSerie+cNumNota+cNumPdv)
	If Substr(SL1->L1_CONFVEN,11,1) <> "N" // Posicao do Parametro de Geracao de Comissao
		cPrefixo := LJPREFIXO()
		DbSelectArea("SE3")
		DbSetorder(1)
		If DbSeek(xFilial("SE3") + cPrefixo + SL1->L1_DOC)
			While (!Eof()) .AND. (!Empty(SL1->L1_VEND)) .AND. (cPrefixo + SL1->L1_DOC == E3_PREFIXO + E3_NUM)
				
				If !Empty( E3_DATA )
					Help( " ",1,"A140COMIS")
					DbSkip()
					Loop
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Faco a soma dos valores totais dos produtos que nao foram devolvidos³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aEval(aCols,{ |ExpA1| nBaseComis += If( aTail( ExpA1 ),ExpA1[ nPosTotal ],0 ) } )
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza‡„o de Comiss”es								     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("SE3",.F.,.T.)
				If nBaseComis == 0
					DbDelete( )
				Else    
					REPLACE SE3->E3_BASE  WITH nBaseComis
					REPLACE SE3->E3_COMIS WITH Round( ( nBaseComis * SE3->E3_PORC ) / 100 ,nDecs)
				EndIf
				MsUnlock()
				DbSkip()
			End
		EndIf
	EndIf
EndIf

RestArea( aAreaL1 )
RestArea( aArea )

Return Nil
