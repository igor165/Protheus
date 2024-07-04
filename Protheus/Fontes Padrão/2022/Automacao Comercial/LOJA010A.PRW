#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "LOJA010A.CH"

// DEFINE's e Statics utilizados na Lj010SetPict
#DEFINE _14DESCONT	1
#DEFINE _16DESCONT	2
#DEFINE _14ENTRADA	3
#DEFINE _14FINANC	4
#DEFINE _15TXMOEDA	5
#DEFINE _14VALMERC	6
#DEFINE _16VALMERC	7
#DEFINE _12VLRLIQ	8
#DEFINE _12VLRTOT	9
#DEFINE _14VLRTOT	10
#DEFINE _16VLRTOT	11
Static aPictures

// Statics Utilizados na SetButton
Static bBut15 := {|| Nil}, bBut24 := {|| Nil}
Static aMoeda
Static nRecnoFilt := 0
Static lPosFilt   := .F.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Loja010  ³ Autor ³ Vendas Clientes       ³ Data ³   1996   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Vendas - Balc„o                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Loja010()
Local lFilSl1        := SuperGetMv("MV_FILTSL1") //Filtra o SL1 ou Nao
Local cArquivo  //Localizacoes 17/05/2000
Local cLock 		 := cUserName+cEstacao
Local aQuery := {}
Local aCores := { {"(!Empty(L1_DOC) .Or. !Empty(L1_DOCPED)) .And. L1_STATUS='T'"							,"BR_BRANCO"},;
				  {"!Empty(L1_DOC) .Or. !Empty(L1_DOCPED)"													,"BR_VERMELHO"},;
				  {"Empty(L1_DOC) .And.  Empty(L1_DOCPED) .And. Empty(L1_RESERVA).And.dDataBase<=L1_DTLIM"	,"BR_VERDE"},;
				  {"Empty(L1_DOC) .And.  Empty(L1_DOCPED) .And.!Empty(L1_RESERVA).And.dDataBase<=L1_DTLIM"	,"BR_AMARELO"},;
				  {"Empty(L1_DOC) .And.  Empty(L1_DOCPED) .And. Empty(L1_RESERVA).And.dDataBase>L1_DTLIM"	,"BR_PRETO"}}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Caso seja Brasil direciona para Venda Assistida,Especialmente para este 			³
//³determinado hardlock e ate a data determinada  e' possivel utilizar o Venda Balcao	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "BRA"
	If !(Ls_GetId() == 2100003279 .AND. dDatabase <= CTOD("30/04/2009") ) 
		Loja701()
		Return(.T.)
	EndIf	
Endif


// Protege rotina para que seja usada apenas no SIGALOJA / Front Loja
If !AmIIn(12,23,72) 
	Return(.F.)
EndIf

// Verifica a existencia da funcao alterada mos programas 
if !findfunction("FRTPegaIT")
	MsgStop(STR0100) // A função FRTPegaIT não foi encontrada no repositório, é necessário atualizar o patch, comunique o administrador do sistema...
	Return(.F.)
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o controle via LockByName para evitar que um usuário acesse       ³
//³ 2 vezes uma rotina que use os periféricos de automação, evitando assim³
//³ a concorrência dos mesmos.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SetMDIChild( 0 ) .And. !LockByName( cLock )
	Return Nil
Endif

If Type("nCredito") == "U"
	Private nCredito := 0
EndIf
Private cConfCli		:= GetMv("MV_CONFCLI")
Private lSayWin		:= .T.
Private cSenhaAnt
Private lVendaRapida := .F.
Private cCadastro 	:= OemtoAnsi(STR0001)		// Venda Balc„o
Private lRetorno		:= .T.
Private cNivelSup 	:= cNivel
Private cNivelSup2	:= cNivel
Private lTroca 		:= .F.
Private lCombo 		:= .T.
Private cSerie		:= Space(TamSx3("L1_SERIE")[1])
Private cNumNota	:= Space(TamSx3("L1_DOC")[1])
Private lSrvCns     := .F.
Private lLogRecupera	:= .F.					// Indica se o log de recuperacao foi criado na venda atuall
Private aRotina		:= {}
Private lDiaFixo	:= .F.                      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³UTILIZADO NA VENDA BALCAO CONCOMITANTE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lVendConc	:= Iif(!lFiscal,.F.,GetNewPar("MV_LJVBCC",.F.))	//Indica se o cliente utiliza a Vda Balcao Concomitante
Private nItensImp	:= 0											//Quantidade de itens impressos no ECF para Venda Concomitante
Private cNumCupFis 	:= Space(TamSx3("L1_DOC")[1])					//Número do Cupom Fiscal
Private npValISS    := 0

// Servidor de Consultas cheque.pre.com
lSrvCns := LjGetStation("LG_INTCNS")
If lSrvCns
	If Empty(LjGetStation("LG_DIRORI"))
		HELP(" ",1,"SRVCNSI")
		Return( .T. )
	Endif
	If Empty(LjGetStation("LG_DIRDES"))
		HELP(" ",1,"SRVCNSO")
		Return( .T. )
	Endif
	If Empty(LjGetStation("LG_DIREXEC"))
		HELP(" ",1,"SRVCNSE")
		Return( .T. )
	Endif
	If Empty(LjGetStation("LG_REDECNS"))
		HELP(" ",1,"SRVRDE")
		Return( .T. )
	Endif
	If Empty(LjGetStation("LG_LOJACNS"))
		HELP(" ",1,"SRVLJA")
		Return( .T. )
	Endif
	If Empty(LjGetStation("LG_CTRCNS"))
		HELP(" ",1,"SRVCTR")
		Return( .T. )
	Endif
Endif

If ! cPaisLoc == "BRA"		
	Private cTipo        := "N"
	Private aDescontos   := {}
	Private cEspecie     := CriaVar("L2_SERIE")
	Private lExibeNF     := .T.
	Private lNFManual    := .F.  //Determina se a NF e manual ou normal	
	
	PRIVATE lLancPad10 := lLancPad20 := .F.
	PRIVATE nHdlPrv    := 1, cLoteFat := "", nTotal := 0
	PRIVATE lGeraLanc, lDigita, lJunta
	
	SetKey(VK_F12,{|| Lj010Ativa()})
	
	Pergunte("LJA010",.F.)
	
	lDigita   := (mv_par01==1)
	lJunta    := (mv_par02==1)
	lGeraLanc := (mv_par03==1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Credito de Estoque / Debito de C.M.V.               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lLancPad10:=VerPadrao("610")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Credito de Impuestos                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lLancPad20:=VerPadrao("620")
	
	If !lGeraLanc
		lLancPad10 := .F.
		lLancPad20 := .F.
	Endif
	
	If lLancPad10 .or. lLancPad20
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Posiciona numero do lote para lancamentos do fatur. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX5")
		dbSeek(cFilial+"09FAT")
		
		cLoteFat:=IIF(Found(),Trim(X5Descri()),"FAT ")
		nHdlPrv :=HeadProva(cLoteFat,"LOJA010",Subs(cUserName,1,6),@cArquivo)
	Endif
	
	If nHdlPrv <= 0
		HELP(" ",1,"HDLNAOGERA")
		Return( .T. )
	Endif
Endif

// Pesq. / Atendimento / Or‡amento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alteracoes especificas para o estado do Amazonas, por imposicao do SEFAZ-AM. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If LjAnalisaLeg(4)[1] .and. GetMv("MV_LJPGCC")
	aRotina	:= MenuDef()		
Else
	aRotina	:= MenuDef()	

EndIf

Private cNumPdv	:= Space(10)
Private aIcms		:= { }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Caixa e de Cupom Fiscal  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lGaveta := !empty(LjGetStation("GAVETA"))
Private cConcomit 		:= "N" // Utilizada no como pagar e recebimento direto.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Caixa usa o CMC7	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lUsaCmc7:= !empty(LjGetStation("CMC7"))
Private aTabelas:= {{"1",0},;
{"2",0},;
{"3",0},;
{"4",0},;
{"5",0},;
{"6",0},;
{"7",0},;
{"8",0},;
{"9",0} }

If cPaisLoc != "BRA"
	Private cCalcImpV  := GetMV("MV_GERIMPV")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Arrays para guardar todos os impostos variaves³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aImpVarSF2 := {}, aImpVarSD2 := {0,0,0,0,0,{}}
	Private aImpCusto := {}, aImpVarDup := {}
	Private nValTotIV := 0, nValBaseIV := 0	
EndIf

If lFiscal .and. cPaisLoc == "BRA"
	
	LjMsgRun(OemToAnsi(STR0075),,{|| aIcms := LjSetAliq(),CLR_HRED } ) // Aguarde, verificando a impressora fiscal...
	
EndIf

//Filtra o SL1 deixando aparecer no browse apenas os orcamentos em aberto
dbSelectArea("SL1")
If lFilSL1
	If ExistBlock("LJFILSL1")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza o Filtro                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao := ExecBlock("LJFILSL1")
		bFiltraBrw := {|| FilBrowse("SL1",@aQuery,@cCondicao) }
		Eval(bFiltraBrw)
		mBrowse( 6, 1,22,75,"SL1",,,,,,aCores )		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Encerra o filtro da tabela.                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		EndFilBrw("SL1",aQuery)		
	Else
		dbSetOrder(2)
		mBrowse( 6, 1,22,75,"SL1",,,,,,aCores,'FILTERSL1INI()','FILTERSL1FIM()')
	EndIf
Else
	mBrowse( 6, 1,22,75,"SL1",,,,,,aCores )
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para Lancamento Contabil, se gerado arquivo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if cPaisLoc <> "BRA"
	If lLancPad10 .or. lLancPad20
		RodaProva(nHdlPrv,nTotal)
	Endif
	If !lGeraLanc
		lLancPad10:=.F.
		lLancPad20:=.F.
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para Lancamento Contabil, se gerado arquivo    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLancPad10.or.lLancPad20
		cA100Incl(cArquivo,nHdlPrv,3,cLoteFat,lDigita,lJunta)
	endif
	Set Key VK_F12 To
Endif

Return( .T. )
                

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef	³ Autor ³ Fernando Amorim       ³ Data ³14/12/06  ³±±
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

Local aRotina:= {} 

If LjAnalisaLeg(4)[1] .and. GetMv("MV_LJPGCC")
	aRotina	:= {		{ STR0002 ,"Lj010Pesq", 0 , 1 , , .F. },;	//Pesquisa
						{ STR0003 ,"Lj010Vnd" , 0 , 3 , , .T. },;	//Atendimento
						{ STR0009 ,"Lj010Orc" , 0 , 4 , , .T. },;	//Orçamento
						{ STR0076 ,"LjFimVend", 0 , 2 , , .T. },;	//Finaliza Venda ( 2 - Somente visualizacao )
						{ STR0081 ,"Lj010Leg" , 0 , 8 , , .T. }}	//Legenda		 ( Foi referenciado 8, pois com 5 a mBrowse trata de maneira diferente o filtro )
Else
	aRotina	:= {		{ STR0002 ,"Lj010Pesq", 0 , 1 , , .F. },;	//Pesquisa
						{ STR0003 ,"lj010Vnd" , 0 , 3 , , .T. },;	//Atendimento
						{ STR0009 ,"lj010Orc" , 0 , 4 , , .T. },;	//Orçamento
						{ STR0076 ,"lj010Ate" , 0 , 6 , , .T. },; 	//Finaliza Venda
						{ STR0081 ,"lj010Leg" , 0 , 8 , , .T. }}	//Legenda		 ( Foi referenciado 6, pois com 5 a mBrowse trata de maneira diferente o filtro )
EndIf


				

							                                                     				
Return(ARotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ lj010Ate ³ Autor ³ Wagner Xavier         ³ Data ³   1996   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de inclusao de orcamentos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ lj010Ate(ExpC1,ExpN1,ExpN2,ExpC2,ExpC3)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±³          ³ ExpC2 = Cliente a ser utilizado na tela de venda           ³±±
±±³          ³ ExpC3 = Loja do cliente a ser utilizada na tela de venda   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010Ate(cAlias       ,nReg         ,nOpcx         ,lExit      ,;
                  cCliVenda    ,cLojVenda    ,cVendedor     )

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Strings Locais ³
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nSaveSx8 	 := GetSx8Len()					// Variavel para controle do semaforo (deve ficar antes da criavar do L1_NUM)
Local cCliente   := CriaVar("A1_COD",.F.)		// Cliente (tela)
Local cLoja 	 := CriaVar("A1_LOJA")			// Loja (tela)
Local cCliAnt	 := GetMv( "MV_CLIPAD" )		// Cliente padrao
Local cLojAnt	 := GetMv( "MV_LOJAPAD" )		// Loja padrao
Local cComboAnt2                                // Conteudo do combo anterior
Local cDescCond									// Descricao da Cond. Pagto
Local cCombo     := ""							// Conteudo do combo
Local cNumSX8									// usada no controle do semaforo
Local cVendLoja									// Vendedor da loja
Local cNumOrc	  := If( nOpcx==2 .Or. nOpcx==3, CriaVar("L1_NUM"), Space(TamSx3("L1_NUM")[1]) )  // Chama a criavar se for um novo atendimento ou se for troca
Local cNumOrcAnt := cNumOrc						// Nr. orcamento anterior
Local cForma	  := GetMv( "MV_FORMPAD")		// Forma de pagto padrao
Local cCondicao  := PADR(GetMv( "MV_CONDPAD"),3)	// Condicao de pagto padrao
local cPorta	  := LJGetStation("PORTIF")			// Porta ECF
Local cDesc 	  := ""								// Descricao
Local cValid										// Validacao a executar
Local cValidDt										// Validacao a executar
Local cValidcli										// Validacao do cliente
Local cTipoJuros := STR0005							// Simples
Local cNroPCli   := CriaVar("L1_NROPCLI")         	// cria a variavel nr ped. cliente
Local cFirstProd                                    // primeiro produto
Local cAdmFator  := ""                            	// Fator da administradora
Local cTmpCli     := ""								// variav. temporaria de cliente
Local bCampo										// conteudo do execblock
Local cNumCaixa		:= xNumCaixa()					// Cod. do caixa
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para o parametro MV_LJDTORC na funcao LJ010NUM        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cLJDTORC := "N"
Local lLJDTOrc := .F.

//ÚÄÄÄÄÄÄÄ¿
//³ Data  ³
//ÀÄÄÄÄÄÄÄÙ
Local dDtLim	  := dDataBase + GetMV("MV_DTLIMIT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ L¢gicos Locais ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lFirstProd   := .T.
Local lCheck3	   := .F.
Local lFirst	   := .T.
Local lAchouSx5	   := .F.
Local lAchouSa6	   := .T.
Local lInclui	   := .T.
Local lAltera	   := .F.
Local lFirstAlter  := .T.
Local lCalcEntrada := .F.
Local lFirstJur	   := .T.
Local lGravou	   := .T.
Local lMudouLin	   := .T.
Local lVazio	   := .T.
Local lUsaFoto 	   := GetMv("MV_USAFOTO")
Local lUsouFator   := .F.
Local lUnif001 	   := ExistBlock("Unif001")
Local lLjVen010    := ExistBlock("LjVen010")
Local lVend        := .T.
Local lOKTroc	   := .F.
Local lLjCliPad    := ExistBlock("LjCliPad")
Local lLjDesc      := ExistBlock("LjDesc")
Local lFocoVend    := GetMV("MV_FOCVEND")
Local lLjMod3	   := GetMV("MV_LJMOD3")
Local lLjMontP	   := .F.
Local uTempUnif
Local lEditavel    := GetMV("MV_L1TXMOE")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Arrays Locais ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aTitles	  := {}
Local aItens	  := {}
Local aCondicoes := {}
Local aParcelas  := {}
Local aPosEnchoice := {3,2,48,310}
Local aCpoEnchoice := {}
Local aMoedas      := {}
Local aTroco       := {0,0,0,0,0}
Local aQuery	:= {}
Local aDadosCli    := {}
Local aCores := {{"!Empty(L1_DOC)"													,"BR_VERMELHO"},;
				  {"Empty(L1_DOC).And. Empty(L1_RESERVA).And.dDataBase<=L1_DTLIM"	,"BR_VERDE"},;
				  {"Empty(L1_DOC).And.!Empty(L1_RESERVA).And.dDataBase<=L1_DTLIM"	,"BR_AMARELO"},;
				  {"Empty(L1_DOC).And. Empty(L1_RESERVA).And.dDataBase>L1_DTLIM"	,"BR_PRETO"}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Objetos locais ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oReceb

Local oDtLim
Local oDescont
Local oDescPer

Local oCombo
Local oFnt
Local oFnt1
Local oFnt2
Local oFnt3
Local oFnt4
Local oFnt5
Local oFnt6
Local oDesc
Local oVlrTot
Local oVlrItens
Local oVlrLiq
Local oVlrLiq1
Local oVlrLiq2
Local oNumParcelas
Local oEntrada
Local oFinanciado
Local oIntervalo
Local oTxJuros
Local oTxDescon
Local oCheck1
Local oCheck3
Local oValPag
Local oBtn1
Local oTipoJuros
Local oGetOrca
Local oNroPCli
Local oVlrTotVen
Local oTroco
Local oGroup1
Local oGroup2
Local oGroup
Local oCheckNFMan

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Num‚ricos Locais ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nCont, nCntFor
Local nLinIni		:= 0
Local nNivelDesc
Local nLiq			:= 0
Local nDescloj 	:= 0
Local nDescPer 	:= 0
Local nVlrTot		:= 0
Local nVlrItens	:= 0
Local nTipoJur  := 1
Local nCondicao	:= 1
Local nFinanciado:= 0
Local nTxDescon	:= 0
Local nTxDesc	:= 0
Local nParcelas	:= 1
Local nNumParcelas:= 1
Local nIntervalo:= 0
Local nEntrAnt 	:= 0
Local nEntrOrig	:= 0
Local nValPag	:= 0				// Valor Pago Pelo cliente
Local nTroco	:= 0				// Troco ao Cliente
Local nDifDesc 	:= 0
Local nFator	:= 0
Local nVlrIpi	:= 0
Local nIndex    := 0
Local nFldFVenda  := GetMV( "MV_FINALVD" )  // Busca folder padrao para opcao finaliza venda
Local nPosLojaRes := 0
Local cVldL1_DV   := ".T."
Local cVldL1_DP   := ".T."
Local cVldL1_Cl   := ".T."
Local cVldL1_Vd   := ".T."
Local cImpressora := LjGetStation("IMPFISC")
Local lLj010ChkT  := ExistTemplate("Lj010Chk") 
Local lLj010Chk   := ExistBlock("Lj010Chk")
Local cx3Valid    := ""
Local nX,nI,i     := 0
Local lFilSl1     := SuperGetMv("MV_FILTSL1") //Filtra o SL1 ou Nao
Local nTent       := 0
Local cMay
Local lLJ010Ate	  := ExistBlock("Lj010Ate")
Local cLabelDoc   := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Var. Log Orcamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nHandle		:= -1
Local cLjArq 		:= Space(8)
Local lLog1       	:= SubStr(LJGetProfile("LOGERRO"),1,1) == "S" // Tem Log de Erro
Local aCloaCols	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Var. Multi-moeda (Loc.) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oCbx,cMoeda 
Local nVlrImpos := 0
Local nVlrImpInc:= 0
Local oVlrImpos
Local lTrcMoeda := GetMV("MV_TRCMOED") 
Local nMoedaAnt := 0
Local nValorTr
Local bValCampo := {|| }
Local bValid    := {|| bValCampo := Lj010VldCpo() }
Local bGravOrc    := {|| lAtuOrc := .T.,IIf(oFolder:nOption == 1,Lj010Option(@aCondicoes,;
@cCombo,oEntrada,oNumParcelas,oFinanciado,@nValorBase,@cForma,@nEntrada,;
@nFinanciado,@nCondicao,@cCondicao,@nNumParcelas,oTxJuros,;
2,oFolder,@nLiq,cNumOrc,lInclui,lAltera,cComboAnt2,@nTxDescon,;
oTxDescon,nIntervalo,@nVlrLiq,@nVlrTot,@nDescLoj,oDescont,@oVlrLiq,@oVlrLiq1,;
@oVlrLiq2,@lUsouFator,@cTipoJuros,oTipoJuros,oReceb,oCheck3,@lCheck3,;
cAdmFator,@nVlrIpi,@oVlrTotVen,@oVlrtot,nDescPer,oCombo,@cCliente,@cLoja,;
nOpcx,aCpoEnchoice,cVendLoja,oVlrImpos,nTipoJur,@oGroup1,@oGroup2,;
oIntervalo,@aMoedas,@aTroco,@lAtuParc,lLjMod3,.T.,@cCliAntCP,@cLojAntCp,oDescPer,nVlrImpos),NIL)}//oFolder:SetOption(2)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Var. de Atualizacao da condicao de pagamento padrao³
//³do cliente                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cCliAntCp := cCliAnt
Local cLojAntCp := cLojAnt
Local lAtuParc  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Var. para dados do Frete³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local   aFreteField := {"L1_NUM",;
						"L1_CLIENTE",;
						"L1_ENDCOB",;
						"L1_ENDENT",;
						"L1_TPFRET",;
						"L1_BAIRROC",;
						"L1_CEPC",;
						"L1_MUNC",;
						"L1_ESTC",;
						"L1_BAIRROE",;
						"L1_CEPE",;
						"L1_MUNE",;
						"L1_ESTE",;
						"L1_FRETE",;
						"L1_SEGURO",;
						"L1_PLIQUI",;
						"L1_PBRUTO",;
						"L1_TRANSP",;
						"L1_ESPECIE",;
						"L1_VOLUME",;
						"L1_MARCA",;
						"L1_NUMERO",;
						"L1_PLACA",;
						"L1_UFPLACA",;
						"L1_DESPESA",;
						"L1_ESPECI1"}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Objeto que controla o usuario que autorizou o desconto. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oAutorDesc

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Controla a saída da janela no momento da FINALIZACAO da venda                                    ³
//³se der problema no item o sistema pergunta se o usuario deseja cancelar o cupom ou excluir o item³
//³ao cancelar a de orçamento não pode ser aberta                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lRetConc := .T.
              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Controla o valor do campo código do cliente, ou seja, toda vez    ³
//³que o campo código do cliente for alterado as variáveis de memória³
//³referente ao frete serão zeradas.                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cCliFrete:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe cupom aberto e tenta cancelar se não conseguir³
//³o caixa não poderá trabalhar com a impressora.                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("lVendConc") == "L" .And. lVendConc
	Lj010Canc(.F.)						//.T. - Pergunta antes .F. - Não pergunta se deseja cancelar
	nItensImp := 0						//Zero o número de itens impressos para inicio de cada atendimento
EndIf

lDiaFixo := .F.
If nOpcx == 4
	If SL1->(FieldPos("L1_DIAFIXO"))>0
		If SL1->L1_DIAFIXO <> ""
			If SL1->L1_DIAFIXO == "1"
				lDiaFixo := .T.
			Else
				lDiaFixo := .F.
			EndIf
		EndIf	
	EndIf
EndIF

lLogRecupera := .F.

If nOpcx == 4							// Finaliza Venda
	MsUnLockAll() 						// Libera os registros travados pelo SoftLock()
	If !SoftLock("SL1")
		Return (.F.)
	Endif
EndIf

Private cAutorDesc := ""

If ! LjVldSerie()
	Return (.F.)
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Var. Privadas   (Loc.) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nVlrLiq := 0
Private cCond   := "" 
Private nTaxaMoeda := Criavar("M2_MOEDA1")
Private dDataCN	:= dDataBase  // Data utilizada como referencia durante utilizacao da Condicao Negociada

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Var. de controle / Folder 2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private lAtuOrc := .F. //Var. atualizada quando é feito uma venda com orcamento (Ponto de entrada LJ010Run)
Private lAtuNcc := .F. //Var. atualizada quando é feito uma venda com orcamento (Chamada da NCC)
Private bComboChg := {|| }

//  GRADE INICIO
Private lGradProd := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³		 --------- VARIAVEIS CRIADAS PARA CONTROLE GRADE ---------		³
//³ lAlterou  := indica se o codigo do produto ja digitado foi alterado ³
//³ lMonta	  := indice se e' para montar o acols a partir do acolsgrade³
//³				  ou se e' para gravar o acolsgrade a partir do acols   ³
//³ lqtdven   := verifica se 'e digitacao da quantidade de venda ou da  ³
//³				  quantidade liberada									³
//³ nAux 	  := controla o numero de elementos da getdados principal	³
//³ cProdRef  := armazena o produto como referencia						³
//³ lGrade	  := indica se a Grade esta ativa ou nao					³
//³ aHeadGrade:= array que controla cabecalho da grade (conf.tabela col.³
//³ aColsGrade:= array que controla itens da grade (conf.tabela linhas) ³
//³ aHeadAux  := array auxiliar que armazena cabecalho do aheader princ.³
//³ aColsAux  := array auxiliar que armazena itens do acols principal	³
//³ aAltGr	  := array auxiliar que armazena elementos do aHeader que	³
//³				  podem ser alterados									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lAlterou	:= .F.,lMonta:=.T.,lQtdVen:=.T.,nAux:=0,cProdRef:=""
Private lGrade 		:= GetMV("MV_GRADE"),aHeadGrade:={},aColsGrade:={},aHeadAux:={},aDesclin:={}
Private aColsAux	:= {},aAltGr:={}
Private cMascara	:= GetMv("MV_MASCGRD")
Private nTamRef	 	:= Val(Substr(cMascara,1,2))
Private nTamLin	 	:= Val(Substr(cMascara,4,2))
Private nTamCol	 	:= Val(Substr(cMascara,7,2))
Private aListaProd 	:= {}
Private obtnTab,oBtnEst,oBtnAut,oBtOk,oBtCan,oBtnTef,oBtnTransp,oBtnReserva,oBtnConsRes
Private nDescAll    := 0
Private oNomeCli
Private oVend
Private oCliente
Private oLoja
Private oVlrAcrs
Private oVlrDesc
Private nVlrAcrs	:= 0
Private nVlrDesc	:= 0
Private nVlrTxDesc 	:= 0
Private nVlrFSD 	:= 0	  //Valor do Frete + Seguro + Desp.Acessorias
Private lVlrFSD		:= .T.	  // Indica se o valor do frete sera lancado no total da venda (Por default sempre serah)
Private nRetIcms	:= 0	  //Icms Solidario
Private nacRetIcms   := 0  // Variavel Para Acumulo de Icms Retido
Private lEntFin     := GetMv("MV_ENTFIN")   //Entrada do financiamento ‚ FI
Private lCarregouSL4:= .F.
Private lFirstaCols	:= .T.
Private lFirst1		:= .T.
Private lFirst2		:= .T.
Private lFirst3		:= .T.
Private lFirstOrc 	:= .T.
Private lPrecoBal   := .F.
Private lCancelChq  := .F.
Private lCompensa	:= .F.
Private lpTPAbISS   := ( GetNewPar("MV_TPABISS", "1") == "2" )
Private aAltDtBase  := {.F.,dDataBase}
Private nPCo	    :=0 	// Indica a posicao da tabela de preco no acols,
Private cCliEntrega := "" //Codigo do cliente entrega
Private cLojEntrega := "" //Codigo da loja entrega

// para que possamos usar como referencia na hora da
// concomitancia
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Strings Privates ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCartao	   := Space(3)
Private cDescrOutr := Space(14)
Private cOrcamen   := ""
Private cInfProBal := ""
Private cSimbCheq  := AllTrim(MVCHEQUE)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Numericos Privates ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nTabela
Private nFolder    := 1
Private nTxJuros   := 0

Private aPISCofCSL := {}   //-- Será montado a partir da função MaNFsCalRT (MATA461).

Private cBlCred	   := ""
Private nMoedaCor  := 1
Private lDetalhe   := .F.    
Private bDelProd   := {|| 	lj010Paint(oBmp,oDesc,@cDesc,@nVlrTot,@nVlrItens,@nVlrLiq,@nValorBase,@nLiq,;
							           @nDescloj,aPosicoes[2][2],@oVlrTot,@oVlrItens,oVlrLiq,oVlrLiq1,oVlrLiq2,oDescPer,;
							           @nDescPer,oDescont,@lMudouLin,@nLinIni,@cFirstProd,@lFirstProd,@lVazio,lUsaFoto,@nDifDesc,;
							           oVlrTotVen,@nVlrIpi)   }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para indicar se o valor do frete ira entrar no ³
//³ total da venda. Estah sendo chamado aqui para a inicializacao   ³
//³ da variavel lVlrFSD se for Finalizacao do orcamento             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == 4
	If ExistBlock("LJCOBFRT")
		nVlrFSD := SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA
		lRet := ExecBlock("LJCOBFRT",.F.,.F.,{ nVlrFSD, SL1->L1_TPFRET  } )
		If ValType(lRet) == "L"
			lVlrFSD := lRet
		Endif
	Endif
Endif

If __lPyme
	lGrade := .F.
EndIf

If cPaisLoc <> "BRA"
	Private lValTot  := GetMV("MV_VALTOTA")  //Verifica se valida ou nao o total da fatura com o que foi pago
	Private lCredFisc:= .F.                  //Identifica se o tipo de documento a ser emitido eh Credito Fiscal - El Salvador		
	Private aImps    := {}	
    Private aNumLay  := {}	                  //Contem o numero dos Lay-Aways que estao sendo finalizados - Loc.POR|EUA
	If lTroca
	   nMoedaCor   := nMoedaTr        
	   nTaxaMoeda  := nTxMoedaTr
	EndIf
	nValorTr := nCredito
	lExibeNF := .T.                 //MARISOL 03/09/99	
	cEspecie := "NF "	

	/////////////////////////////////////////////////////////////////////////////////
	//O array aDadosJur armazena os resultados do calculo dos juros ou desconto    //
	//financeiro sendo que o mesmo eh valorizado na funcao Lj010RecVB, que se      //
	//encontra no Loja010c.prw                                                     //
    /////////////////////////////////////////////////////////////////////////////////
	//Descricao do Array                                                           //
	//aDadosJur[1] => Total do acrescimo                                           //
	//aDadosJur[2] => Valor Liquido da Venda                                       //
	//aDadosJur[3] => Valor Base da Venda                                          //
	//aDadosJur[4] => Valor total dos impostos                                     //
	//aDadosJur[5] => Total de desconto                                            //
	//aDadosJur[6] => Valor anterior do imposto                                    //
	//aDadosJur[7] => Taxa de juros			                                       // 
	//aDadosJur[8] => Percentual de desconto                                       //	 
	//aDadosJur[9] => Valor do desconto financeiro                                 //	
	/////////////////////////////////////////////////////////////////////////////////
	Private aDadosJur := {0,0,0,0,0,0,0,0,0}	   	
	Private oLBBaixa //Objeto utilizado na rotina de troco localizada...	
	If cPaisLoc == "SAL"
       Private cRegFisc  := Space(TamSX3("LU_REGFISC")[1])
       Private cNomeRF   := Space(TamSX3("LU_NOME")[1])    
       Private cEnderRF  := Space(TamSX3("LU_END")[1])    
       Private cTelefRF  := Space(TamSX3("LU_TEL")[1])
       Private cAtivRF   := Space(TamSX3("LU_ATIVIDA")[1])	
    ElseIf cPaisLoc == "GUA"   
       Private cNumResol := Space(TamSX3("FQ_RESOLUC")[1])	       
    EndIf   	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Objetos Privates ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oGet
Private oBmp
Private oBmp1
Private oDlgLoja
Private oFolder
Private oPgtos
Private oEnchMod3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Objetos TEF      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nValorBase   := 0
Private nEntrada     := 0
Private aTefDados    := {}
Private aParcTef     := {}
Private cGaranch     := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Arrays Privates ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCpoAlter := {"L2_VRUNIT","L2_DESC","L2_VALDESC","L2_TES","L2_CF"}
Private aPgtos	  := {}
Private aPosicoes := {} // Private pois e usado no Valid SX3
Private aReceb 	:= {{Ctod("  /  /  "),0,Space(15),CriaVar("L4_ADMINIS"),CriaVar("L4_NUMCART"),;
CriaVar("L4_AGENCIA"),CriaVar("L4_CONTA"),CriaVar("L4_RG"),CriaVar("L4_TELEFON"),.F.,nMoedaCor,;
CriaVar("L4_MESACTA"),CriaVar("L4_ANOACTA"),CriaVar("L4_TIPOCHQ"),CriaVar("L4_CGC"),CriaVar("L4_NOMECLI"),;
CriaVar("L4_SERCHQ"),CriaVar("L4_COMP")}}

SetKey(122,{ ||LJENTRY()})   //F11

// Tratamento para uso da Template Function e da User Function
Do Case
	Case ExistTemplate("LJKEYF6") .And. ExistBlock("LJKEYF6")
		SetKey(VK_F6 ,{ || ( ExecTemplate("LJKEYF6" ,.F.,.F.), ExecBlock("LJKEYF6" ,.F.,.F.) ) })
	Case ExistTemplate("LJKEYF6") 
		SetKey(VK_F6 ,{ || ExecTemplate("LJKEYF6" ,.F.,.F.) })
	Case ExistBlock("LJKEYF6")
		SetKey(VK_F6 ,{ || ExecBlock("LJKEYF6" ,.F.,.F.)})
EndCase

If(ExistBlock("LJKEYF7") ,SetKey(VK_F7 ,{ || ExecBlock("LJKEYF7" ,.F.,.F.)}),NIL)
If(ExistBlock("LJKEYF8") ,SetKey(VK_F8 ,{ || ExecBlock("LJKEYF8" ,.F.,.F.)}),NIL)
If(ExistBlock("LJKEYF9") ,SetKey(VK_F9 ,{ || ExecBlock("LJKEYF9" ,.F.,.F.)}),NIL)
If(ExistBlock("LJKEYF10"),SetKey(VK_F10,{ || ExecBlock("LJKEYF10",.F.,.F.)}),NIL)

If lLJ010Ate
	nReg := ExecBlock("Lj010Ate",.F.,.F.,{nOpcx,nReg})
EndIf

If lFilSl1
	nRecnoFilt := SL1->( Recno() )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  ****** Descric„o do ARRAY aRECEB	 *******   ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ Dimensoes  ³ Descric„o						   ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ 	  1	  ³ Data de Pagamento				   ³
//³ 	  2	  ³ Valor							   ³
//³ 	  3	  ³ Forma de Pgto (R$,CC)			   ³
//³ 	  4	  ³ Administradora					   ³
//³ 	  5	  ³ Numero do Cartao / Cheque 		   ³
//³ 	  6	  ³ Agencia  - Cheque				   ³
//³ 	  7	  ³ Conta		  - Cheque			   ³
//³ 	  8	  ³ Rg			  - Cheque			   ³
//³ 	  9	  ³ Telefone - Cheque				   ³
//³ 	 10	  ³ Cheque de Terceiros 			   ³
//³ 	 11	  ³ Moeda                              ³
//*      12   ³ Mes abertura da Conta              ³
//*      13   ³ Ano abertura da Conta              ³
//*      14   ³ Tipo de Cheque (Fis/Jur)           ³
//*      15   ³ CGC/CPF                            ³
//*      16   ³ Nome do Cliente                    ³
//*      17   ³ Série do Cheque                    ³
//*      18   ³ Compensacao do Cheque              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSenhaAnt  := cSenha

npValISS   := 0
lSayWin	   := .T.
oBtnTab	   := Nil
oBtnEst	   := Nil
oBtnAut	   := Nil
oBtnConsRes:= Nil
oBtnReserva:= Nil
nTabela	   := Int(Val(GetMv( "MV_TABPAD" ) ) )
cTipoNota  := "V"
nOpcA 	   := 0
nCheck	   := GetMv("MV_LOJAOPI")
nFldFVenda := If( ! ( AllTrim( Str( nFldFVenda ) ) $ "123" ), 3, nFldFVenda )
lCheck3	   := .F.
cNumPdv	:= Space(10)
lLayAway   := IIf(Type("lLayAway")#"U",lLayAway,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for administrador nao deixa fazer a venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !IsCaixaLoja( cNumCaixa )
	
	// Este usuário não é um caixa e n„o poder  efetuar vendas. Utilize a op‡„o
	// Senhas/Caixas no Menu Miscelƒnea para incluir um Caixa. Caso
	// j  exista um cadastrado, re-entre no sistema com a senha de Caixa.
	MsgInfo(STR0006)
	dbSelectArea(cAlias)
	lExit := .F.	
	Return .F.
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o operador utilizar a rotina de finalização de venda e não tiver acesso    ³
//³ao Atendimento não teria problemas, pois outro usuário já efetuou tal operação³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == 4 .AND. nFldFVenda == 3
	If !ChkPsw( 30 )						//29 - Rotina de Pagamento 30 - Rotina de Recebimento
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura a integridade da janela ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea(cAlias)
		Return(.F.)
    EndIf
Else
	If !ChkPsw( 25 ) 						//25 - Rotina de Atendimento
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura a integridade da janela ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea(cAlias)
		Return(.F.)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verfica se usuario esta cadastrado como caixa. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "SX5" )
dbSeek( cFilial+"23" )
While !Eof() .and. cFilial==X5_FILIAL .and. X5_TABELA = "23"
	If Upper(Trim(X5Descri())) == Upper( Trim( cUserName ) )
		lAchouSx5 := .T.
		Exit
	EndIf
	dbSkip( )
End

If lAchouSx5
	dbSelectArea( "SA6" )
	If !( dbSeek( cFilial+SubStr(SX5->X5_CHAVE,1,3)))
		lAchouSa6 := .F.
	EndIf
EndIf

If !lAchouSx5
	Help( " ", 1, "NOCAIXASX5" )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao esta cadastrado como caixa, sai do programa ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lExit := .F.	
	dbSelectArea(cAlias)
	Return .F.
End

If !lAchouSA6
	Help( " ", 1, "NOCAIXASA6" )
	lExit := .F.	
	Return .F.
End

IF ! CheckPaper()
	lExit := .F.
	Return .F.
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a existencia de Cliente/Loja/Vendedor, Padrao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lLjCliPad
	cTmpCli  := ExecBlock("LjCliPad",.F.,.F.,)
	cCliente := Substr(cTmpCli,1,TamSx3("A1_COD")[1])
	cLoja    := Substr(cTmpCli,TamSx3("A1_COD")[1]+1,TamSx3("A1_LOJA")[1])
Else          
	// Se informou o cliente e a loja, utiliza na venda
	If cCliVenda # NIL .and. cLojVenda # NIL
		cCliente := cCliVenda
		cLoja	 := cLojVenda
	Else	// Caso contrario busca os dados padroes.
		cCliente := PadR(GetMv("MV_CLIPAD"),TamSx3("A1_COD")[1])
		cLoja 	:= PadR(GetMv("MV_LOJAPAD"),TamSx3("A1_LOJA")[1])
	EndIf		
EndIf
dbSelectArea("SA1")
dbSetOrder(1)
If ! dbSeek(xFilial("SA1")+cCliente+cLoja)
	ljCriaCli("clie")
Elseif cPaisLoc == "ARG"
   cSerie  := Lj010SerArg()    	
ElseIf cPaisLoc == "SAL"   
   lCredFisc  := SA1->A1_TIPO $ "1|4"   
EndIf

// Se o codigo do vendedor foi passado como parametro, carrega o mesmo para a tela de venda
If cVendedor # NIL
	cVendLoja := cVendedor
Else	
	cVendLoja := IIf(ExistBlock("LjVendPad"),ExecBlock("LjVendPad",.F.,.F.,),IIf(Len(GetMv("MV_VENDPAD"))<=6,GetMv("MV_VENDPAD")+Space(6-Len(GetMv("MV_VENDPAD"))),Space(6)))
EndIf
	
dbSelectArea("SA3")
dbSetOrder(1)
If !dbSeek(xFilial("SA3")+cVendLoja)
	ljCriaCli("vend")
EndIf

If lUnif001
	uTempUnif := ExecBlock("UNIF001",.F.,.F.)
	If ValType( uTempUnif ) == "L" .And. !uTempUnif
      Return( Nil )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria tabela com forma de pagamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aItens := {}
dbSelectArea( "SX5" )
dbSeek( cFilial+"24" )
While !Eof() .and. cFilial==X5_FILIAL .and. X5_TABELA = "24"
	dbSelectArea("SAE")
	dbSetOrder(1)
	dbSeek(xFilial("SAE"))
	If Alltrim(SX5->X5_CHAVE) == GetMv("MV_SIMB1") .Or. Alltrim(SX5->X5_CHAVE) == cSimbCheq
		Aadd(aItens,{Capital(Alltrim(X5Descri())),Alltrim(SX5->X5_CHAVE)})
	Else
		While xFilial("SAE") == SAE->AE_FILIAL .And. !Eof()
			If Alltrim(SX5->X5_CHAVE) == AllTrim(SAE->AE_TIPO)
				Aadd(aItens,{Capital(Alltrim(X5Descri())),Alltrim(SX5->X5_CHAVE)})
				Exit
			EndIf
			dbSkip()
		End
	EndIf
	dbSelectArea("SX5")
	dbSkip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTELA[0][0],aGETS[0],aHeader[0],nUsado:=0,aCampos:={}
Private nPosCProd := 0

DbSelectArea("Sx2")
DbSeek("SL2")
DbSelectArea("Sx3")
DbSetOrder(1)
DbSeek("SL2")
While !Eof() .And. (x3_arquivo == "SL2")

	If x3uso(X3_USADO) .And. cNivel >= x3_nivel .And. !(Alltrim(x3_campo)=="L2_NUM")
		
		nUsado++
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a venda for concomitante não permitir a alteração de nenhum dado na aCols após a |
		//|digitação do produto, pois já foi impresso										   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type("lVendConc") == "L" .And. lVendConc
			cx3Valid := "Lj010MsnVd()"
			If !Empty(Alltrim(X3_Valid))
				cx3Valid := cx3Valid + " .And. " + Alltrim(X3_Valid)
			EndIf
		Else
			cx3Valid := Alltrim(X3_Valid)
		EndIf			

		If Alltrim(X3_Campo) == "L2_QUANT"
			If Type("lVendConc") == "L" .And. lVendConc
				cx3Valid := "Empty(aCols[n][aPosicoes[ 9][2]]) .And. LJWQTD()"
			Else
				cX3Valid:="LJWQTD()"
			EndIf			
		Elseif Alltrim(X3_Campo) == "L2_VEND"
        	// Esta funcao devera contar qtos vendedores foram inclusos no orcamento, pois as tabelas sao restritas a 5
			cX3Valid:=Iif(Empty(cX3Valid),"LJContVend()",alltrim(cX3Valid)+" .And. LJContVend()") 
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a validacao para verificar se existe reserva para o item. Caso   ³
		//³ afirmativo nao permite a alteracao de nenhum campo, apenas permite   ³
		//³ deletar o item.                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty( cX3Valid )
			cX3Valid := "L010VldRes()"
		Else
			cX3Valid := Alltrim( cX3Valid ) + " .And. L010VldRes()"
		Endif	
		
		Aadd(aHeader,{Trim(X3Titulo()),;
			 x3_campo,;
			 x3_picture,;
			 Iif(x3_campo == "L2_PRODUTO",Max(TamSx3("B1_COD")[1],TamSx3("B1_CODBAR")[1]),x3_tamanho),;
	 		 x3_decimal,;
	 		 cx3valid,;
	 		 x3_usado,;
	 		 x3_tipo,;
	 		 x3_arquivo})

		Aadd( aCampos, x3_campo )

	EndIf
	dbSkip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Altera o x3_valid dos campos que não podem ser alterados depois³
//³que for efetuada uma reserva                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosLojaRes := aScan(aHeader,{|z| Alltrim(Upper(z[2]))=="L2_LOJARES" })
For nX := 1 to Len(aHeader)
	If ASCAN( aCpoAlter, ALLTRIM( UPPER( aHeader[nX][2] ) ) ) == 0                          // {|| MsgStop('Não é permitido alterar esse campo depois de efetuada a reserva em outra loja')}
		If !Empty(aHeader[nX][6])
			aHeader[nX][6] += ".And."
		Endif
		aHeader[nX][6] += "Iif(Empty(aCols[n,"+StrZero(nPosLojaRes,2,0)+"]),.T.,(MsgStop('Não seré permitida a alteração de um produto que já tenha reserva em outra loja.'),.F.))"
	Endif							
Next nX

nPosCProd := Ascan( aHeader,{ |x| Alltrim(x[2]) == "L2_PRODUTO" } )

dbSelectArea("Sx3")
dbSetOrder(2)
If dbSeek( "L1_DESCONT" )
	cVldL1_DV := IIf(!Empty(SX3->X3_VALID),AllTrim(SX3->X3_VALID),".T.")
EndIf
If dbSeek( "L1_DESCNF" )
	cVldL1_DP := IIf(!Empty(SX3->X3_VALID),AllTrim(SX3->X3_VALID),".T.")
EndIf
If dbSeek( "L1_CLIENTE" )
	cVldL1_Cl := IIf(!Empty(SX3->X3_VLDUSER),AllTrim(SX3->X3_VLDUSER),".T.")
EndIf
If dbSeek( "L1_VEND" )
	cVldL1_Vd := IIf(!Empty(SX3->X3_VLDUSER),AllTrim(SX3->X3_VLDUSER),".T.")
EndIf
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega nomes dos Folders  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// &Or‡amento / Como &Pagar / &Recebimentos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alteracoes especificas para o estado do Amazonas, por imposicao do SEFAZ-AM. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If LjAnalisaLeg(4)[1] .and. GetMv("MV_LJPGCC")
	aTitles := {OemToAnsi(STR0009),"",""}
Else
	aTitles := {OemToAnsi(STR0009),OemToAnsi(STR0010),OemToAnsi(STR0011)}
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega posicoes dos campos do Acols ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lj010pos()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega validacoes do cliente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "SX3" )
dbSetOrder( 2 )
dbSeek("L1_DESCONT")
nNivelDesc := X3_NIVEL
cValid	 := X3_VLDUSER
dbSeek("L1_DTLIM")
cValidDt := X3_VLDUSER
dbSeek( "L1_CLIENTE" )
cValidCli := X3_VLDUSER
dbSetOrder( 1 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega variaveis ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNumSX8 := cNumOrc

// Caso o SXE e o SXF estejam corrompidos cNumOrc estava se repetindo.
cMay := Alltrim(xFilial("SL1"))+cNumOrc
FreeUsedCode()
SL1->(dbSetOrder(1))
// Se dois orcamentos iniciam ao mesmo tempo a MayIUseCode impede que ambos utilizem o mesmo numero.
While SL1->(dbSeek(xFilial("SL1")+cNumOrc)) .Or. !MayIUseCode(cMay)
	if ++nTent > 20
		MsgStop(OemToAnsi(STR0071))
		exit
	Endif
	While (GetSX8Len() > nSaveSx8)
		ConfirmSx8()
	End
	cNumOrc    := CriaVar("L1_NUM")
	cNumOrcAnt := cNumOrc                      	
	cNumSX8    := cNumOrc
	FreeUsedCode()
	cMay := Alltrim(xFilial("SL1"))+cNumOrc
End

If nOpcx == 4 // Quarta Opcao no Menu = Finaliza Venda do Orcamento Corrente
	
	SL1->(dbGoto(nReg))
	cNumOrc := SL1->L1_NUM
	
	cCliAntCp := SL1->L1_CLIENTE
	cLojAntCp := SL1->L1_LOJA
	cCondicao := SL1->L1_CONDPG
	npValISS  := SL1->L1_VALISS

	If FieldPos( "L1_VALPIS" ) > 0 .And. FieldPos( "L1_VALCOFI" ) > 0 .And. FieldPos( "L1_VALCSLL" ) > 0
		LJPCCIni(SL1->L1_CLIENTE, SL1->L1_LOJA, SL1->L1_EMISSAO)
		LJPCCAlt("SL", { SL1->L1_VLRTOT, SL1->L1_VALPIS, SL1->L1_VALCOFI, SL1->L1_VALCSLL })
	EndIf
	
	lAtuParc  := .F.
	
	//
	// Verifica se escolheu um orcamento ja finalizado, se selecionou Finaliza Venda
	//
	If !Empty( SL1->L1_DOC ) .Or. !Empty( SL1->L1_DOCPED )
		Help(" ",1,"VENDIDO")
		Return .F.
	EndIf
	
	If ! Lj010DtLim( SL1->L1_DTLIM, SL1->L1_CLIENTE, SL1->L1_NUM )
		Return .F.
	EndIf

   If cPaisLoc == "ARG"
      SA1->(DbSetOrder(1))
      SA1->(DbSeek(xFilial("SA1")+cCliAntCP+cLojAntCP))
      cSerie  := Lj010SerArg()    	
   EndIf   
	
EndIf

// Variável para uso de NCC
// Substr(MV_USACRED,1,1) == "S" -> Gera NCC para troca por valor menor
//                           "N" -> Não gera NCC e não permite troca por valor menor
// Substr(MV_USACRED,2,1) == "N" -> Não utiliza NCC's em aberto como Credito
//                           "S" -> Exibe as NCC's em aberto para escolher quais usar

Private nNccGerada := 0
Private nNccUsada  := 0
Private aNccItens  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Matriz aCols ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCOLS[1][nUsado+1]
Private aColsBak := {}
Private lSaiuGetdad := .F.

lInclui := .T.
lFirst  := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Acols para inclusao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Lj010Det(cCliente,cNumOrc,.T.,.T.,@oVlrItens,@nVlrItens)

SETAPILHA()

nTabela	:= Int(Val(GetMv( "MV_TABPAD" ) ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega array com as moedas ativs para o Combo.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA"
	If (aMoeda == Nil)
		aMoeda := {}
		For nX	:=	1	To MoedFin()
			If(!(Empty(GetMv("MV_MOEDA"+Ltrim(STR(nX))))))
				LjCriaSimb(nX)
				AAdd(aMoeda,GetMv("MV_MOEDA"+Ltrim(STR(nX))))
			Else
				Exit
			Endif
		Next nX
	EndIf
	If SL1->L1_MOEDA <> 0 .And.  SL1->L1_MOEDA <= Len(aMoeda)
		nTaxaMoeda	:=	SL1->L1_TXMOEDA
		cMoeda		:=	aMoeda[SL1->L1_MOEDA]
	ElseIf SL1->L1_MOEDA == 0
		nTaxaMoeda	:=	1
		cMoeda		:=	aMoeda[1]
	Else
		Help(" ",1,"NoMoeda")
	Endif
EndIf

If SL1->L1_TIPOJUR == 0 .Or. SL1->L1_TIPOJUR == 1
	nTipoJur := 1
	cTipoJuros := OemToAnsi(STR0005) //Simples
Else
	nTipoJur := SL1->L1_TIPOJUR
	cTipoJuros := OemToAnsi(STR0093) //Serie Pgto.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao das Var. para dados do Frete³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI:= 1 to len(aFreteField)
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek(aFreteField[nI])
	If X3Uso(SX3->X3_USADO) .And. (cNivel >= SX3->X3_NIVEL)
		If Alltrim(aFreteField[nI]) == "L1_NUM"
			M->&(SX3->X3_CAMPO) := cNumOrc
		Else
			M->&(SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
		Endif
	Endif
Next nI
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³																 ³
//³						  ROTINA DE ATENDIMENTO 				 ³
//³																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lLjVen010
	lVend:=ExecBlock("ljVen010",.F.,.F.)
endif

Private nDecimais := MsDecimais(nMoedaCor)

//Inicializa as pictures
Lj010SetPict()

DEFINE MSDIALOG oDlgLoja FROM 80,1 TO 422,637 TITLE cCadastro PIXEL;
OF GetWndDefault()

DEFINE FONT oFnt  NAME "Arial" SIZE 15,20 BOLD
DEFINE FONT oFnt1 NAME "Arial" SIZE 10,15
DEFINE FONT oFnt2 NAME "Arial" SIZE 11,16
DEFINE FONT oFnt3 NAME "Arial" BOLD
DEFINE FONT oFnt4 NAME "Arial" SIZE 08,10
DEFINE FONT oFnt5 NAME "Arial" SIZE 10,15 BOLD
DEFINE FONT oFnt6 NAME "Arial" SIZE 10,10 BOLD
DEFINE FONT oFnt7 NAME "Arial" SIZE 05,09.5
                        
@ 15,01 FOLDER oFolder SIZE 317,157 OF oDlgLoja PROMPTS;
aTitles[1],aTitles[2],aTitles[3] PIXEL

For nCont:= 1 to Len(oFolder:aDialogs)
	oFolder:aDialogs[nCont]:oFont := oDlgLoja:oFont
Next

// Exibe o cliente no rodape da tela de venda.
LJ010ImpCli( cCliente, cLoja, 1 )

//***
// Definicao da tela de atendimento
//
If !lLjMod3
	
	// Or‡amento / Pedido
	@ 02,02  SAY OemToAnsi(STR0009) SIZE 30,08 OF oFolder:aDialogs[1] PIXEL;
	FONT oFnt3
	
	If !lFocoVend 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Deixar alterar numero do orcamento, porem com a correta atualizacao na tela do cpo Vlr.Total.    |
		//| Se alterado o numero do orcamento, atribuo .t. a lExit para ao finalizar nao retornar ao browse, |
		//| para onde estava retornando exceto quando alterava algum campo da acols.                         |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 10,02 MSGET oGetOrca VAR cNumOrc SIZE 20,08 OF oFolder:aDialogs[1] PIXEL 	ON CHANGE ( lExit := .T. )
		
	EndIf
	
	// Vendedor
	@ 02,38 SAY OemToAnsi(STR0013) 		 SIZE 35,08 OF oFolder:aDialogs[1] PIXEL;
	FONT oFnt3
	
	@ 10,38 MSGET oVend	  VAR cVendLoja SIZE 12,08 OF oFolder:aDialogs[1] PIXEL;
	F3 "SA3" Picture "@!" Valid lj010Vend(cVendLoja) .And. &(cVldL1_Vd) When lVend
	
	// Cliente
	@ 02,070 SAY OemToAnsi(STR0072)		 SIZE 35,08 OF oFolder:aDialogs[1] PIXEL;
	FONT oFnt3
	
	// Loja
	@ 02,145 SAY OemToAnsi(STR0073)		 SIZE 15,08 OF oFolder:aDialogs[1] PIXEL;
	FONT oFnt3
	
	@ 10, 70 MSGET oCliente VAR cCliente  SIZE 75, 8 OF oFolder:aDialogs[1] PIXEL;
	F3 "SA1" PICTURE "@!" VALID Lj010Clien(	@cCliente	, @cLoja	, @cCliAnt, @cLojAnt,;
											oLoja		, "C"		, oFolder:aDialogs[1] ) .AND.;
								IIF( cCliAntCP + cLojAntCP == cCliente + cLoja, .T., Lj010CondCli( 	@cCliAntCP	, @cLojAntCp	, @cCliente	, @cLoja,;
																										@lAtuParc	, @oCombo		, @cCombo	, @aCondicoes ) ) .AND.;
								&( cVldL1_Cl ) .AND.;
								IIF( cPaisLoc == "BRA", CalcIcmSol( @nLiq, cCliente, cLoja, oVlrLiq, @nValorBase, @nVlrLiq ), Lj010Imps( cCliente, cLoja, nVlrTot, cNumOrc, @aDadosCli ) ) .AND.;
								Lj010Paint( oBmp		, oDesc				, @cDesc		, @nVlrTot		,;
											@nVlrItens	, @nVlrLiq			, @nValorBase	, @nLiq			,;
											@nDescloj	, aPosicoes[2][2]	, @oVlrTot		, @oVlrItens	,;
											oVlrLiq		, oVlrLiq1			, oVlrLiq2		, oDescPer		,;
											@nDescPer	, oDescont			, @lMudouLin	, @nLinIni		,;
											@cFirstProd	, @lFirstProd		, @lVazio		, lUsaFoto		,;
											@nDifDesc	, oVlrTotVen		, @nVlrIpi )

	oCliente:bChange := {|| Lj010VlCli(@oCombo) }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama a funcao Lj010VlVen para trazer o vendedor padrao do cadastro do cliente ³
	//³ caso o parametro MV_CONFCLI esteja habilitado (igual a "S")                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oCliente:bLostFocus := {|| Lj010VlVen( cCliente, cLoja, @cVendLoja, @cCliFrete ), oVend:refresh() }
	
		
	@ 10,145 MSGET oLoja	  VAR cLoja 	 SIZE 09,08 OF oFolder:aDialogs[1] PIXEL;
	Valid lj010Clien(@cCliente,@cLoja,@cCliAnt,@cLojAnt,oLoja,"L",oFolder:aDialogs[1]);
	.And. IIf(cCliAntCP+cLojAntCP == cCliente+cLoja,.T.,Lj010CondCli(@cCliAntCP,@cLojAntCp,@cCliente,@cLoja,@lAtuParc,@oCombo,@cCombo,@aCondicoes ));
	.And. IIf(cPaisLoc == "BRA",CalcIcmSol(@nLiq,cCliente,cLoja,oVlrLiq,@nValorBase,@nVlrLiq),Lj010Imps(cCliente,cLoja,nVlrTot,cNumOrc,@aDadosCli)) Picture "@!"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama a funcao Lj010VlVen para trazer o vendedor padrao do cadastro do cliente ³
	//³ caso o parametro MV_CONFCLI esteja habilitado (igual a "S")                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oLoja:bLostFocus := {|| Lj010VlVen( cCliente, cLoja, @cVendLoja, @cCliFrete ), oVend:refresh() }
	
	// Validade
	@ 02,165 SAY OemToAnsi(STR0015)		 SIZE 35,08 OF oFolder:aDialogs[1] PIXEL;
	FONT oFnt3
	
	@ 10,165 MSGET oDtLim   VAR dDtLim	 SIZE 40,08 OF oFolder:aDialogs[1] PIXEL;
	Picture "99/99/99" Valid !Empty(dDtLim) .And. dDtlim >= dDataBase
	
	// Ped.Cliente
	@ 02,207 SAY OemToAnsi(STR0016) SIZE 100,08 OF oFolder:aDialogs[1] PIXEL;
	FONT oFnt3
	
	@ 10,207 MSGET oNroPCli VAR cNroPCli  SIZE 31,08 OF oFolder:aDialogs[1] PIXEL;
	Picture "@!"
	
	If cPaisLoc != "BRA" 
	   If GetMV("MV_SHWCPAG")
		  //Condi‡äes Cadastradas
		  @ 02,247 SAY OemToAnsi(STR0025) SIZE 80,08 OF oFolder:aDialogs[1] PIXEL;
		  FONT oFnt3
		
		  lCalcEntrada := .F.
		
		  Lj010CbPag(@aCondicoes)
		  //Simples
		  @ 10,247 MSCOMBOBOX oCombo VAR cCombo ITEMS aCondicoes SIZE 65,30;
		  OF oFolder:aDialogs[1] PIXEL
		
		  cCond = cCombo
	   ElseIf cPaisLoc == "SAL"	  
		   @ 007,250 BUTTON STR0106 SIZE 30,14 ACTION Lj010RegFisc(cCliente,cLoja,oDlgLoja) OF oFolder:aDialogs[1] PIXEL  //"Reg.Fiscal"			   		
	   ElseIf cPaisLoc == "GUA"
           @ 010, 248 CHECKBOX oCheckNFMan VAR lNFManual PROMPT OemToAnsi(STR0109);	 //"NF Manual?"		
           SIZE 60,08 OF oFolder:aDialogs[1] PIXEL WHEN !AtIsRotina("LOJA021") 	   		   
	   EndIf	   
	Endif
	// cCliAnt := cCliente
	// cLojAnt := cLoja
	
	M->L1_CLIENTE	:= cCliente
	M->L1_LOJA		:= cLoja

	oGet := MSGetDados():New(21,02,95,IIf(lUsaFoto,204,309),if(GetMv("MV_ACATIVO"),2,IIf(lInclui,3,4)),"lj010EvaLi","ljw10TudOk","",if(GetMv("MV_ACATIVO"),.F.,.T.),if(GetMv("MV_ACATIVO"),{},),,,GetMV("MV_LJNUMIT"),IIf(cPaisLoc <> "BRA",'AFieldEtOk("L")',Nil),,,"LJ010DEL",oFolder:aDialogs[1])
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria um array com os campos que irao aparecer na enchoice³
	//³e chama um ponto de entrada para o cliente customizar    ³
	//³campos de usuario.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lUsaFoto := .F.
	aCpoEnchoice := {"L1_NUM","L1_VEND","L1_CLIENTE","L1_LOJA","L1_DTLIM","L1_NROPCLI","L1_EMISSAO"}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alteracoes especificas para o estado do Amazonas, por imposicao do SEFAZ-AM. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If LjAnalisaLeg(4)[1] .and. GetMv("MV_LJPGCC")
		AAdd(aCpoEnchoice, "L1_NSO")
	EndIf
	If ExistTemplate("LJMod3")
		aCpoEnchoice := ExecTemplate("LJMod3",.F.,.F.,aCpoEnchoice)
	EndIf
	If ExistBlock("LJMod3")
		aCpoEnchoice := ExecBlock("LJMod3",.F.,.F.,aCpoEnchoice)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Alimenta as variaveis de memoria da enchoice, se o parametro³
	//³MV_LJMOD3 for igual a .T.                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RegToMemory( "SL1", .F. )
	dbSelectArea("SL1")

	M->L1_NUM := cNumOrc            
	cCliEntrega := M->L1_CLIENT
	cLojEntrega := M->L1_LOJENT
	
	bCampo := { |x| FieldName(x) }
	aSL1Default := { {"L1_NUM",cNumOrc,"cNumOrc"},;
	{"L1_VEND",cVendLoja,"cVendLoja"},;
	{"L1_CLIENTE",cCliente,"cCliente"},;
	{"L1_LOJA",cLoja,"cLoja"},;
	{"L1_NROPCLI",cNroPCli,"cNroPCli"},;
	{"L1_DTLIM",dDtLim,"dDtLim"},;	
	{"L1_EMISSAO",dDataBase,"dDataBase"} }
	If nOpcx == 4
		For nCntFor := 1 TO FCount()
			If ASCAN( aCpoEnchoice, EVAL( bCampo, nCntFor)) > 0
				M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
			Endif
		Next nCntFor
	Else
		For i:=1 to Len(aSL1Default)
			M->&(aSL1Default[i][1]) := aSL1Default[i][2]
		Next i
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a tela (mod.2) para o atendimento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oEnchMod3:= MsMGet():New("SL1", nReg, nOpcx,,,, aCpoEnchoice, aPosEnchoice, , 3,,,, oFolder:aDialogs[1],,.T.,,,,,,,,.T.)
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alteracoes especificas para o estado do Amazonas, por imposicao do SEFAZ-AM. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If LjAnalisaLeg(4)[1] .and. GetMv("MV_LJPGCC")
		oGet := MSGetDados():New(50,02,95,309,nOpcx,"lj010EvaLi","ljw10TudOk","",if(GetMv( "MV_ACATIVO" ),.F.,.T.),if(GetMv( "MV_ACATIVO"),{},),,,GetMV("MV_LJNUMIT"),IIf(cPaisLoc <> "BRA",'AFieldEtOk("L")',Nil),,,"LJ010DEL",oFolder:aDialogs[1])
	Else
		oGet := MSGetDados():New(50,02,95,309,if(GetMv("MV_ACATIVO"),2,IIf(lInclui,3,4)),"lj010EvaLi","ljw10TudOk","",if(GetMv("MV_ACATIVO"),.F.,.T.),if(GetMv("MV_ACATIVO"),{},),,,GetMV("MV_LJNUMIT"),IIf(cPaisLoc <> "BRA",'AFieldEtOk("L")',Nil),,,"LJ010DEL",oFolder:aDialogs[1])
	EndIf
Endif

If lLjMod3
	oGet:oBrowse:bGotFocus := {|| Lj010VarMod3(aSL1Default,@cNumOrc,@cVendLoja,@cCliente,@cLoja,@cNroPCli), Lj010Liq(@nVlrLiq,@nVlrTot,@nValorBase,@nLiq,oVlrLiq,;
	oVlrLiq1,oVlrLiq2,@nDescloj,oDescPer,@nDescPer,oVlrTotVen,oFolder:nOption,@nVlrImpos,oVlrImpos,@nVlrImpInc,@oVlrTot,oDescont,cNumOrc) }
Else
	oGet:oBrowse:bGotFocus := {|| Lj010Liq(@nVlrLiq,@nVlrTot,@nValorBase,@nLiq,oVlrLiq,;
	oVlrLiq1,oVlrLiq2,@nDescloj,oDescPer,@nDescPer,oVlrTotVen,oFolder:nOption,@nVlrImpos,oVlrImpos,@nVlrImpInc,@oVlrTot,oDescont,cNumOrc) }
Endif
oGet:oBrowse:bLostFocus := { || lj010TudOk(), Lj010Liq(@nVlrLiq,@nVlrTot,@nValorBase,@nLiq,oVlrLiq,;
oVlrLiq1,oVlrLiq2,@nDescloj,oDescPer,@nDescPer,oVlrTotVen,oFolder:nOption,@nVlrImpos,oVlrImpos,@nVlrImpInc,@oVlrTot,oDescont,cNumOrc)}

// Bloco utilizado para atualizar os dados na tela apos incluir o produto do requerimento
Private bReq := { || lj010Paint(oBmp,oDesc,@cDesc,@nVlrTot,@nVlrItens,@nVlrLiq,@nValorBase,@nLiq,;
@nDescloj,aPosicoes[2][2],@oVlrTot,@oVlrItens,oVlrLiq,oVlrLiq1,oVlrLiq2,oDescPer,;
@nDescPer,oDescont,@lMudouLin,@nLinIni,@cFirstProd,@lFirstProd,@lVazio,lUsaFoto,@nDifDesc,;
oVlrTotVen,@nVlrIpi) }

If cPaisLoc == "BRA"
	oGet:oBrowse:bDrawSelect := {|| if(lLjMod3,Lj010VarMod3(aSL1Default,@cNumOrc,@cVendLoja,@cCliente,@cLoja,@cNroPCli),), CalcIcmSol(@nLiq,cCliente,cLoja,;
	oVlrLiq,@nValorBase,@nVlrLiq), lj010Paint(oBmp,oDesc,@cDesc,@nVlrTot,@nVlrItens,;
	@nVlrLiq,@nValorBase,@nLiq,@nDescloj,aPosicoes[2][2],@oVlrTot,@oVlrItens,;
	oVlrLiq,oVlrLiq1,oVlrLiq2,oDescPer,@nDescPer,oDescont,@lMudouLin,;
	@nLinIni,@cFirstProd,@lFirstProd,@lVazio,lUsaFoto,@nDifDesc,;
	oVlrTotVen,@nVlrIpi)}
Else  // Localizacoes
	oGet:oBrowse:bDrawSelect := {|| If(lLjMod3,Lj010VarMod3(aSL1Default,@cNumOrc,@cVendLoja,;
	@cCliente,@cLoja,@cNroPCli),),lj010Paint(oBmp,oDesc,@cDesc,@nVlrTot,@nVlrItens,;
	@nVlrLiq,@nValorBase,@nLiq,@nDescLoj,aPosicoes[2][2],@oVlrTot,@oVlrItens,;
	oVlrLiq,oVlrLiq1,oVlrLiq2,oDescPer,@nDescPer,oDescont,@lMudouLin,;
	@nLinIni,@cFirstProd,@lFirstProd,@lVazio,lUsaFoto,@nDifDesc,oVlrTotVen,@nVlrIpi)}
EndIf

If LjAnalisaLeg(4)[1] .and. GetMV("MV_LJPGCC")
	M->L1_NSO := CRIAVAR("L1_NSO")
EndIf

//Total de Mercadorias
@ 96, 02 SAY OemToAnsi(STR0017)  SIZE 100,08 OF oFolder:aDialogs[1] PIXEL;
FONT oFnt3

@ 96,65 SAY oVlrTot VAR Transform(nVlrTot,aPictures[_12VLRTOT])  SIZE 80,08 OF oFolder:aDialogs[1] PIXEL;
RIGHT FONT oFnt2 COLOR CLR_HBLUE

//Total de Itens
@ 96,230 SAY OemToAnsi(STR0070) SIZE 50,08 OF oFolder:aDialogs[1] PIXEL;
FONT oFnt3

@ 96,278 SAY oVlrItens VAR nVlrItens SIZE 30,08 OF oFolder:aDialogs[1] PIXEL;
Picture "99999" RIGHT FONT oFnt2 COLOR CLR_HBLUE

If ExistBlock( "L010PERDES" )
	nDescPer := ExecBlock( "L010PERDES" , .F. , .F. )
EndIf

//Desconto no Total
@ 105, 02 SAY OemToAnsi(STR0018)	SIZE 100,08 OF oFolder:aDialogs[1] PIXEL;
FONT oFnt3
//Autorizado por:
@ 112, 02 SAY STR0103 Size 50,06 OF oFolder:aDialogs[1] PIXEL;
FONT oFnt7
@ 112, 35 SAY oAutorDesc PROMPT Left(cAutorDesc,15) Size 50,06 OF oFolder:aDialogs[1] PIXEL;
FONT oFnt7

@ 106, 61 MSGET oDescPer VAR nDescPer SIZE 20,08 OF oFolder:aDialogs[1] PIXEL;
RIGHT PICTURE "@E 99.99" VALID (If(nDescPer<0,MsgStop(STR0104),),.T.) .And. nDescPer >= 0 .And. Lj010Nivel(4,@nDescPer,@oDescPer) .And. &(cVldL1_DP) .And.; // Nao e permitido valor negativo nesse campo.
	SayWinSub(	@nVlrTot,@nVlrLiq,@nValorBase,@nLiq,;
				@nDescloj,aPosicoes[2][2],@oVlrTot,oVlrLiq,;
				oVlrLiq1,oVlrLiq2,oDescPer,@nDescPer,;
				oDescont,"DESCPER",@nDifDesc,oVlrTotVen,;
				@nVlrIpi,oFolder:nOption,NIL) .And.;
	ljw010Desc(@nVlrLiq,@nVlrTot,@nValorBase,@nLiq,oVlrLiq,oVlrLiq1,oVlrLiq2,@nDescloj,oDescPer,@nDescPer,;
		oDescont,nVlrImpInc,oAutorDesc,@cAutorDesc) .And.;
	Lj010Liq(@nVlrLiq,@nVlrTot,@nValorBase,@nLiq,oVlrLiq,oVlrLiq1,oVlrLiq2,@nDescloj,oDescPer,@nDescPer,;
		oVlrTotVen,oFolder:nOption,@nVlrImpos,oVlrImpos,@nVlrImpInc,@oVlrTot,oDescont,cNumOrc) .And.;
	If(lLjDesc,ExecBlock("LJDESC",.F.,.F.,{nDescPer,"P"}),.T.)

@ 108, 90 SAY "%" SIZE 05,08 OF oFolder:aDialogs[1] PIXEL FONT oFnt3

@ 106, 96 MSGET oDescont VAR nDescloj Picture aPictures[_16DESCONT] SIZE 45,08 OF oFolder:aDialogs[1] PIXEL;
RIGHT Valid (If(nDescLoj<0,MsgStop(STR0104),),.T.) .And. nDescloj >= 0 .And. Lj010Nivel(3,@nDescLoj,@oDescont) .And. &(cVldL1_DV) .And.; // Nao e permitido valor negativo nesse campo.
	SayWinSub(	@nVlrTot,@nVlrLiq,@nValorBase,@nLiq,;
				@nDescloj,aPosicoes[2][2],@oVlrTot,oVlrLiq,;
				oVlrLiq1,oVlrLiq2,oDescPer,@nDescPer,;
				oDescont,"DESCVAL",@nDifDesc,oVlrTotVen,;
				@nVlrIpi,NIL,NIL) .And.;
	lj010DescV(@nVlrTot,oDescont,@nDescloj,oDescPer,@nDescPer,cNumOrc,oVlrLiq,nVlrImpInc,oAutorDesc,@cAutorDesc,@nLiq) .And.;
	Lj010Liq(@nVlrLiq,@nVlrTot,@nValorBase,@nLiq,oVlrLiq,oVlrLiq1,oVlrLiq2,@nDescloj,oDescPer,@nDescPer,;
		oVlrTotVen,oFolder:nOption,@nVlrImpos,oVlrImpos,@nVlrImpInc,@oVlrTot,oDescont,cNumOrc).And.;
	If(lLjDesc,ExecBlock("LJDESC",.F.,.F.,{nDescloj,"V"}),.T.);
When nDescPer == 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Moeda/Taxa          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA"
    If lTroca
    	cMoeda := aMoeda[nMoedaCor]
    	nTaxaMoeda := nTxMoedaTr
    Endif
	@ 106,144 SAY OemtoAnsi(STR0077) SIZE 22, 07 OF oFolder:aDialogs[1] PIXEL         //"Moeda"
	@ 106,170 COMBOBOX oCBX VAR cMoeda ITEMS aMoeda ON CHANGE (nTaxaMoeda:=RecMoeda(dDataBase,oCBX:nAt),;
              nMoedaAnt := nMoedaCor,;
              nMoedaCor := oCBX:nAt ,;
	          nDecimais := MsDecimais(nMoedaCor),;
	          Lj010SetPict(),;
	          Iif(lTrcMoeda,Lj010TrcMoeda(nMoedaAnt,.T.),.T.),;
	          lDetalhe := .F.);	          
	          VALID Iif(lTrcMoeda,(RecMoeda(dDataBase,oCbx:nAt) > 0),.T.) WHEN !lTroca .And. lEditavel;
	          SIZE 50,50 OF oFolder:aDialogs[1] PIXEL
	@ 106,230 SAY OemtoAnsi(STR0078) SIZE 18, 07 OF oFolder:aDialogs[1] PIXEL         //"Tasa"
	@ 106,245 MSGET nTaxaMoeda OF oFolder:aDialogs[1] Picture aPictures[_15TXMOEDA] VALID !(lDetalhe := .F.);
	ON CHANGE Iif(lTrcMoeda,Lj010TrcMoeda(nMoedaAnt,.F.),.T.) WHEN !lTroca .And. lEditavel PIXEL
EndIf

//Vlr.L¡q.+IPI / Valor L¡quido
@ 117, 02 GROUP oGroup TO 135,144 LABEL if( nVlrIpi > 0 ,OemToAnsi(STR0019), OemToAnsi(STR0020));
OF oFolder:aDialogs[1] PIXEL
oGroup:SetFont(oFnt3)

@ 124,44 SAY oVlrLiq VAR if(cPaisLoc=="BRA",Transform(nLiq+If(lTroca,nCredito,0)-nNccGerada+nNccUsada-LJ010VlrFSD()-LJPCCRet()-npValISS,aPictures[_12VLRLIQ]),;
Transform(nVlrLiq,aPictures[_12VLRLIQ])) SIZE 99,10 OF oFolder:aDialogs[1] PIXEL RIGHT COLOR CLR_HRED FONT oFnt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o usuario utilize a foto define o objeto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUsaFoto
	@ 23,210 REPOSITORY oBmp SIZE 99,70 OF oFolder:aDialogs[1] PIXEL
	oBmp:SetColor(GetSysColor(15),GetSysColor(15))
	oBmp:lStretch := .T.
EndIf

//Descri‡ao do Produto
If cPaisLoc == "BRA"
	@ 107,148 GROUP oGroup TO 135,308 LABEL OemToAnsi(STR0021) OF oFolder:aDialogs[1] PIXEL
	oGroup:SetFont(oFnt3)
	
	@ 115,150 SAY oDesc VAR cDesc SIZE 155,15 OF oFolder:aDialogs[1] PIXEL;
	CENTER COLOR CLR_HBLUE FONT oFnt1
Else
	@ 118,148 GROUP oGroup TO 137,308 LABEL OemToAnsi(STR0021) OF oFolder:aDialogs[1] PIXEL
	oGroup:SetFont(oFnt3)
	
	@ 126,150 SAY oDesc VAR cDesc SIZE 130,10 OF oFolder:aDialogs[1] PIXEL;
	CENTER COLOR CLR_HBLUE FONT oFnt4
EndIf

If lFocoVend .and. !lLjMod3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Deixar alterar numero do orcamento, porem com a correta atualizacao na tela do cpo Vlr.Total.    |
	//| Se alterado o numero do orcamento, atribuo .t. a lExit para ao finalizar nao retornar ao browse, |
	//| para onde estava retornando exceto quando alterava algum campo da acols.                         |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 10,02 MSGET oGetOrca VAR cNumOrc SIZE 20,08 OF oFolder:aDialogs[1] PIXEL 	ON CHANGE ( lExit := .T. )
	
EndIf

If Valtype(oGetOrca)=='O'
	oGetOrca:Cargo  := cNumOrc
	oGetOrca:Picture  := PesqPict("SL1","L1_NUM")
	oGetOrca:bValid := {|| Lj010Num(cNumOrc,		cNumSX8,		@lInclui,		@lAltera,;
									@cCliente,		@cLoja,			@nDescloj,		@nVlrLiq,;
									@cVendLoja,		@dDtLim,		@nVlrTot,		@nEntrada,;
									@nFinanciado,	@nParcelas,		@nIntervalo,	oCliente,;
									oLoja,			oAutorDesc,		oDescont,		oVlrLiq,;
									oVlrLiq1,		oVlrLiq2,		oVend,			oVlrTot,;
									oDtLim,			@cCombo,		oCombo,			@cComboAnt2,;
									@cCondicao,		@cDescCond,		@lFirstAlter,	@aCondicoes,;
									oEntrada,		oNumParcelas,	oFinanciado,	@nValorBase,;
									@cForma,		@nCondicao,		@nNumParcelas,	oTxJuros,;
									oReceb,			@nCheck,		@lCheck3,		oCheck1,;
									oCheck3,		@oGetOrca,		@cNumOrcAnt,	@nVlrAcrs,;
									oVlrAcrs,		oNroPCli,		@cNroPCli,		@nFator,;
									@lUsouFator,	@cAdmFator,		@cTipoJuros,	oTipoJuros,;
									@nLiq,			@oVlrItens,		@nVlrItens,		@nDescPer,;
									@cDesc,			oDesc,			@lLjMontP,		@nTipoJur,;
									@cLJDTORC,		@lLJDTOrc,		@aMoedas,		@aTroco,;
									nOpcx,			@nTxDescon,		@cMoeda,		aMoeda) .AND. ; 
			SayWinSub(  @nVlrTot,@nVlrLiq,@nValorBase,@nLiq,;
						@nDescloj,aPosicoes[2][2],@oVlrTot,oVlrLiq,;
						oVlrLiq1,oVlrLiq2,oDescPer,@nDescPer,;
						oDescont,"DESCVAL",@nDifDesc,oVlrTotVen,;
						@nVlrIpi,NIL,nVlrImpos)  .AND. ;																		
			If(ExistTemplate("LJ10ORC"),ExecTemplate("LJ10ORC",.F.,.F.,cNumOrc),.T.) .And. ;  
			If(ExistBlock("LJ10ORC"),ExecBlock("LJ10ORC",.F.,.F.,cNumOrc),.T.)}
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 															 ³
//³ 							  FOLDER COMO PAGAR				 ³
//³ 															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Dados do Pagamento
@ 10,05 GROUP oGroup TO 100,104 LABEL OemToAnsi(STR0022) OF oFolder:aDialogs[2] PIXEL
oGroup:SetFont(oFnt3)

//Entrada
@ 18,08 SAY OemToAnsi(STR0052) 		 SIZE 30,08 OF oFolder:aDialogs[2] PIXEL
@ 24,27 SAY oEntrada  VAR Transform(nEntrada,aPictures[_14ENTRADA])  SIZE 70,10 OF oFolder:aDialogs[2] PIXEL;
RIGHT FONT oFnt2 COLOR CLR_HBLUE

//Financiado
@ 36,08 SAY OemToAnsi(STR0053) 			SIZE 30,08 OF oFolder:aDialogs[2] PIXEL
@ 42,17 SAY oFinanciado VAR Transform(nFinanciado,aPictures[_14FINANC]) SIZE 80,10 OF oFolder:aDialogs[2] PIXEL;
RIGHT FONT oFnt2 COLOR CLR_HBLUE

//Tx.Juros
@ 57,08 SAY OemToAnsi(STR0054) 		SIZE 30,08 OF oFolder:aDialogs[2] PIXEL
@ 57,37 SAY oTxJuros	  VAR nTxJuros SIZE 54,10 OF oFolder:aDialogs[2] PIXEL;
RIGHT Picture "@E 999.99" FONT oFnt2 COLOR CLR_HBLUE
@ 57,93 SAY OemToAnsi("%")           SIZE 05,08 OF oFolder:aDialogs[2] PIXEL;
FONT oFnt3 COLOR CLR_HBLUE

//Tx.Desconto
@ 67,08 SAY OemToAnsi(STR0055) 		 SIZE 31,08 OF oFolder:aDialogs[2] PIXEL
@ 67,40 SAY oTxDescon   VAR nTxDescon SIZE 51,08 OF oFolder:aDialogs[2] PIXEL;
RIGHT Picture "@E 999.99" FONT oFnt2 COLOR CLR_HBLUE
@ 67,93 SAY OemToAnsi("%")            SIZE 05,08 OF oFolder:aDialogs[2] PIXEL;
FONT oFnt3 COLOR CLR_HBLUE

//No. de Parcelas
@ 77,08 SAY OemToAnsi(STR0056) 			  SIZE 40,08 OF oFolder:aDialogs[2] PIXEL
@ 77,63 SAY oNumParcelas VAR nNumParcelas SIZE 35,08 OF oFolder:aDialogs[2] PIXEL;
RIGHT Picture "@E 99"  FONT oFnt2 COLOR CLR_HBLUE

//Intervalo
@ 87,08 SAY OemToAnsi(STR0057) 			SIZE 40,08 OF oFolder:aDialogs[2] PIXEL
@ 87,63 SAY oIntervalo	VAR nIntervalo SIZE 35,08 OF oFolder:aDialogs[2] PIXEL;
RIGHT Picture "@E 999" FONT oFnt2 COLOR CLR_HBLUE

//Condi‡oes Cadastradas
@ 106, 05 GROUP oGroup TO 133, 104 LABEL OemToAnsi(STR0025) OF oFolder:aDialogs[2] PIXEL
oGroup:SetFont(oFnt3)

lCalcEntrada := .F.

Lj010CbPag(@aCondicoes)
If ! Empty(cCondicao)
	If ( nIndex := ASCAN( aCondicoes,{ |x| SUBSTR( x, 1, 3) == cCondicao } ) ) > 0 
		cCombo := aCondicoes[nIndex]
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se eh para respeitar a condicao default do cadastro do cliente  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cConfCli == "S" .And. nOpcx != 4
	    If ( nPosCondPg := ASCAN( aCondicoes, {|x| SUBSTR( x, 1, 3) == SA1->A1_COND } ) ) > 0
	    	cCombo := aCondicoes[nPosCondPg]
	    Endif
	Endif
EndIf

//Simples
bComboChg := { || IIf(Lj010VldCombo(@cCombo    ,@cComboAnt2    ,@oCombo    ,aCondicoes   ),;
(lUsouFator:= .F.,Iif( nTipoJur == 1 ,cTipoJuros := STR0005,cTipoJuros := STR0093),;
oTipoJuros:Refresh(),Iif(Upper(AllTrim(Substr(cCombo,1,2))) != "CN",;
lj010box(@nEntrada    ,@nParcelas   ,@nIntervalo   ,@nValorBase   ,;
         oEntrada     ,oTxJuros     ,oNumParcelas  ,oIntervalo    ,;
         @aCondicoes  ,@nFinanciado ,@cForma       ,oFinanciado   ,;
         @lCalcEntrada,@nEntrAnt    ,@nEntrOrig    ,@aParcelas    ,;
         @cCombo      ,oCombo       ,@nNumParcelas ,@nLiq         ,;
         @oVlrLiq1    ,@oVlrLiq2    ,@lFirstJur    ,@nTipoJur     ,;
         @nCondicao   ,@cCondicao   ,@cComboAnt2   ,@nTxDescon    ,;
         oTxDescon    ,nDescLoj     ,nDescPer      ,oVlrImpos     ,;
         @cTipoJuros  ,oTipoJuros   ,oVlrTotVen    ),;
         IIf(LJ010JUROS(@nEntrada    ,@nParcelas    ,@nIntervalo    ,@nValorBase    ,;
		                oEntrada     ,oTxJuros       ,oNumParcelas   ,oIntervalo     ,;
		                @aCondicoes  ,@nFinanciado   ,@cForma        ,oFinanciado    ,;
		                @lCalcEntrada,@nEntrAnt      ,@nEntrOrig     ,@aParcelas     ,;
		                @cCombo      ,oCombo         ,@nNumParcelas  ,@nLiq          ,;
		                oVlrLiq      ,oVlrLiq1       ,oVlrLiq2       ,@lFirstJur     ,;
		                @nTipoJur    ,@cCondicao     ,oFnt2          ,@nVlrTot       ,;
		                nDescloj     ,oDescPer       ,nDescPer       ,@nVlrLiq       ,;
		                @nVlrAcrs    ,@nVlrDesc      ,@cTipoJuros    ,oVlrAcrs       ,;
		 			    oVlrDesc     ,oTipoJuros     ,@cComboAnt2    ,oVlrImpos      ),;
						.T.,(LjAtualComb(@cCombo   ,oCombo         ,@aCondicoes    ,@cCondicao     ,;
	                  					  cComboAnt2))))),)}

@ 118,07 MSCOMBOBOX oCombo VAR cCombo ITEMS aCondicoes SIZE 95,30;
OF oFolder:aDialogs[2] PIXEL ON CHANGE Eval(bComboChg);
WHEN (nLiq > 0 .and. lCombo)

// Se o valor da compra e igual a 0

cComboAnt2	:= cCombo

// Totais
@ 10,107 GROUP oGroup TO 75,199 LABEL OemToAnsi(STR0023) OF oFolder:aDialogs[2] PIXEL
oGroup:SetFont(oFnt3)

//Acr‚scimo
@ 17,110 SAY OemToAnsi(STR0058)	 SIZE 30,08 OF oFolder:aDialogs[2] PIXEL
If cPaisLoc == "BRA"
   @ 21,124 SAY oVlrAcrs VAR Transform(nVlrAcrs,aPictures[_14VLRTOT]) SIZE 70,10 OF oFolder:aDialogs[2] PIXEL;
   RIGHT FONT oFnt2 COLOR CLR_HBLUE

   //Descontos
   @ 32,110 SAY OemToAnsi(STR0059)   SIZE 30,08 OF oFolder:aDialogs[2] PIXEL
   @ 36,124 SAY oVlrDesc VAR Transform(nVlrDesc,aPictures[_14DESCONT]) SIZE 70,10 OF oFolder:aDialogs[2] PIXEL;
   RIGHT FONT oFnt2 COLOR CLR_HBLUE
   
   //Frete / Seguro / Desp.Acessorias
   @ 46,110 SAY OemToAnsi(STR0094)   SIZE 50,16 OF oFolder:aDialogs[2] PIXEL
   @ 50,124 SAY oVlrFrete VAR Transform(nVlrFSD,aPictures[_14DESCONT]) SIZE 70,10 OF oFolder:aDialogs[2] PIXEL;
   RIGHT FONT oFnt2 COLOR CLR_HBLUE

   //Mercadorias
   @ 64,110 SAY OemToAnsi(STR0060)  SIZE 30,08 OF oFolder:aDialogs[2] PIXEL
   @ 64,124 SAY oVlrTotVen VAR Transform(nVlrTot,aPictures[_12VLRTOT]) SIZE 70,10 OF oFolder:aDialogs[2] PIXEL;
   RIGHT FONT oFnt2 COLOR CLR_HBLUE

Else
   @ 17,124 SAY oVlrAcrs VAR Transform(nVlrAcrs,aPictures[_14VLRTOT]) SIZE 70,10 OF oFolder:aDialogs[2] PIXEL;
   RIGHT FONT oFnt1 COLOR CLR_HBLUE

   //Descontos
   @ 26,110 SAY OemToAnsi(STR0059)   SIZE 30,08 OF oFolder:aDialogs[2] PIXEL
   @ 26,124 SAY oVlrDesc VAR Transform(nVlrDesc,aPictures[_14DESCONT]) SIZE 70,10 OF oFolder:aDialogs[2] PIXEL;
   RIGHT FONT oFnt1 COLOR CLR_HBLUE
   
   //Frete / Seguro / Desp.Acessorias
   @ 36,110 SAY OemToAnsi(STR0094)   SIZE 50,16 OF oFolder:aDialogs[2] PIXEL
   @ 40,124 SAY oVlrFrete VAR Transform(nVlrFSD,aPictures[_14DESCONT]) SIZE 70,10 OF oFolder:aDialogs[2] PIXEL;
   RIGHT FONT oFnt1 COLOR CLR_HBLUE

   //Mercadorias
   @ 55,110 SAY OemToAnsi(STR0060)  SIZE 30,08 OF oFolder:aDialogs[2] PIXEL
   @ 55,124 SAY oVlrTotVen VAR if(lTroca,Transform(nVlrTot,aPictures[_14VALMERC]),;
   Transform(nLiq-(nVlrImpInc+aDadosJur[9]),aPictures[_14VALMERC])) SIZE 70,10 OF oFolder:aDialogs[2] PIXEL;
   RIGHT FONT oFnt1 COLOR CLR_HBLUE

   //Impostos Variaveis
   @ 66,110 SAY OemToAnsi(STR0087)  SIZE 30,10 OF oFolder:aDialogs[2] PIXEL
   @ 66,124 SAY oVlrImpos VAR Transform(If(nVlrAcrs>0.Or.aDadosJur[9]>0,aDadosJur[4],If(nLiq>0,nVlrImpos,0)),aPictures[_16VALMERC]) SIZE 70,10 OF oFolder:aDialogs[2] PIXEL;
   RIGHT FONT oFnt1 COLOR CLR_HBLUE
EndIf

// Tipo de C lculo
@  78,107 GROUP oGroup TO 100,199 LABEL OemToAnsi(STR0029) OF ofolder:adialogs[2] PIXEL
oGroup:SetFont(oFnt3)

@  88,108 SAY oTipoJuros VAR OemToAnsi(cTipoJuros) SIZE 85,10 OF;
oFolder:aDialogs[2] PIXEL CENTER FONT oFnt2 COLOR CLR_HBLUE

// Financiam. - Negocia‡Æo
@ 106,107 GROUP oGroup TO 133,199 LABEL OemToAnsi(STR0026) OF oFolder:aDialogs[2] PIXEL
oGroup:SetFont(oFnt3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Financiamento  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SBUTTON FROM 116,118 TYPE 18 ENABLE OF oFolder:aDialogs[2];
ACTION (IIf(lUsouFator,EVal(oCombo:bChange),.T.),;
Lj010Fator(oDlgLoja    ,@cCombo     ,@nNumParcelas   ,@nLiq   ,;
           @nEntrada   ,@nFinanciado,@cTipoJuros     ,oReceb  ,;
           oTipoJuros  ,@lUsouFator ,@oVlrLiq1       ,oEntrada,;
           oFinanciado ,oTxJuros    ,oNumParcelas    ,@nFator ,;
           @cAdmFator  ))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Bot„o para entrar na condi‡„o negociada. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SBUTTON FROM 116,156 TYPE 16 ENABLE OF oFolder:aDialogs[2];
ACTION IIf(LJ010JUROS(@nEntrada    ,@nParcelas   ,@nIntervalo   ,@nValorBase   ,;
					  oEntrada     ,oTxJuros     ,oNumParcelas   ,oIntervalo    ,;
					  @aCondicoes  ,@nFinanciado ,@cForma        ,oFinanciado  ,;
					  @lCalcEntrada,@nEntrAnt    ,@nEntrOrig     ,@aParcelas   ,;
					  @cCombo      ,oCombo       ,@nNumParcelas  ,@nLiq        ,;
					  oVlrLiq      ,oVlrLiq1     ,oVlrLiq2       ,@lFirstJur   ,;
					  @nTipoJur    ,@cCondicao   ,oFnt2          ,@nVlrTot     ,;
					  nDescloj     ,oDescPer     ,nDescPer       ,@nVlrLiq     ,;
					  @nVlrAcrs    ,@nVlrDesc    ,@cTipoJuros    ,oVlrAcrs    ,;
					  oVlrDesc     ,oTipoJuros   ,@cComboAnt2    ,oVlrImpos    ),;
					  (lUsouFator := .F.,nTxDescon:=0),)

// Parcelas
@ 06,202 SAY STR0024 SIZE 30,08 OF oFolder:aDialogs[2] PIXEL FONT oFnt3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ListBox com as parcelas a pagar ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Em um financiamento
// com fator n„o ser  permitida a altera‡„o da forma de pagamento.
// Para alterar, escolha outra Condi‡„o de Pagamento.
oPgtos := TCBrowse():New(1,25.3,107,86, , , ,oFolder:aDialogs[2], , , , ,;
{|nRow,nCol,nFlags| Lj010Din(@aItens     ,nVlrLiq   ,oFnt2        ,@nEntrada   ,;
							 @nFinanciado,oEntrada   ,oFinanciado  ,nLiq        ,;
							 lUsouFator  ,nTipoJur   ,@lLjMontP    ,aMoeda,;
							 @cCondicao     ),;
							 oTxJuros:Refresh(),oPgtos:Refresh(),oVlrLiq1:Refresh(),oVlrTotVen:Refresh(),;
							 oEntrada:Refresh(),oFinanciado:Refresh(),oVlrAcrs:Refresh(),oVlrDesc:Refresh() },;
							  , , , , , ,.T., , ,{||Lj010ValOk(nFinanciado,nEntrada)})

oPgtos:nClrBackFocus := GetSysColor( 13 )
oPgtos:nClrForeFocus := GetSysColor( 14 )
oPgtos:SetArray( aPgtos )

// Duplo click do mouse sobre a parcela para mudar forma
oPgtos:cToolTip := STR0033
oPgtos:nFreeze := 1

// Data / Valor / Forma de Pagamento
ADD COLUMN TO oPgtos HEADER iIf(cPaisLoc == "BRA",STR0034,STR0096) OEM DATA {|| aPgtos[oPgtos:nAt,1] }	ALIGN LEFT SIZE 35 PIXELS
ADD COLUMN TO oPgtos HEADER STR0035 OEM DATA {|| Transform(aPgtos[oPgtos:nAt,2],PesqPict("SL1","L1_VLRTOT",16,aPgtos[oPgtos:nAt,4]))} ALIGN LEFT SIZE 50  PIXELS
ADD COLUMN TO oPgtos HEADER STR0036 OEM DATA {|| aPgtos[oPgtos:nAt,3] } ALIGN LEFT SIZE 20	PIXELS
ADD COLUMN TO oPgtos HEADER STR0077 OEM DATA {|| aPgtos[oPgtos:nAt,4] } ALIGN LEFT SIZE 20	PIXELS     //Moeda
If cPaisLoc <> "BRA"
	ADD COLUMN TO oPgtos HEADER STR0095 OEM DATA {|| aPgtos[oPgtos:nAt,5] } ALIGN LEFT SIZE 20	PIXELS     //Emissao
EndIf

oFolder:bChange := {|x,y| (If(!lLjMod3,oNroPCli:SetFocus(),),;
lj010Receb(oFolder:nOption   ,oCombo     ,@cCombo      ,@aCondicoes   ,;
           oReceb            ,oEntrada   ,oNumParcelas ,oFinanciado   ,;
           @nValorBase       ,@cForma    ,@nEntrada    ,@nFinanciado  ,;
           oTxJuros          ,oIntervalo ,@nParcelas   ,@nIntervalo   ,;
           @lCalcEntrada     ,@nEntrAnt  ,@nEntrOrig   ,aParcelas     ,;
           @nNumParcelas     ,@nCondicao ,@cCondicao   ,@lCheck3      ,;
           oCheck3           ,@nLiq      ,oVlrLiq1     ,oVlrLiq2      ,;
           @lFirstJur        ,@nTipoJur  ,@cComboAnt2  ,@nTxDescon    ,;
           oTxDescon         ,@lUsouFator,@cAdmFator   ,oFolder       ,;
           nDescLoj          ,nDescPer   ,oVlrImpos    ,@cTipoJuros   ,;
           oTipoJuros        ,oVlrTotVen  ))}

oFolder:bSetOption := {|nNewOption| (If(!lLjMod3,oNroPCli:SetFocus(),oEnchMod3:SetFocus()),;
SayWinSub(@nVlrTot    ,@nVlrLiq        ,@nValorBase    ,@nLiq     ,;
          @nDescloj   ,aPosicoes[2][2] ,@oVlrTot       ,oVlrLiq   ,;
          oVlrLiq1    ,oVlrLiq2         ,oDescPer       ,@nDescPer ,;
          oDescont    ,"DESCVAL"        ,@nDifDesc      ,oVlrTotVen,;
          @nVlrIpi    ,oFolder:nOption  ,nVlrImpos      ),;
		  Lj010Option(@aCondicoes   ,@cCombo    ,oEntrada   ,oNumParcelas  ,;
		              oFinanciado   ,@nValorBase,@cForma    ,@nEntrada     ,;
					  @nFinanciado  ,@nCondicao ,@cCondicao ,@nNumParcelas ,;
					  oTxJuros      ,nNewOption  ,oFolder    ,@nLiq        ,;
					  cNumOrc       ,lInclui     ,lAltera    ,cComboAnt2   ,;
					  @nTxDescon    ,oTxDescon   ,nIntervalo ,@nVlrLiq     ,;
					  @nVlrTot      ,@nDescLoj   ,oDescont   ,@oVlrLiq     ,;
					  @oVlrLiq1     ,@oVlrLiq2   ,@lUsouFator,@cTipoJuros  ,;
					  oTipoJuros    ,oReceb      ,oCheck3    ,@lCheck3     ,;
					  cAdmFator     ,@nVlrIpi    ,@oVlrTotVen,@oVlrtot     ,;
					  nDescPer      ,oCombo      ,@cCliente   ,@cLoja      ,;
					  nOpcx         ,aCpoEnchoice,cVendLoja   ,oVlrImpos   ,;
					  nTipoJur      ,@oGroup1    ,@oGroup2    ,oIntervalo  ,;
					  @aMoedas      ,@aTroco     ,@lAtuParc   ,lLjMod3    ,;
					  .F.           ,@cCliAntCP  ,@cLojAntCp  ,oDescPer   ,;
					  nVlrImpos     ,.T.          ))}

//"Valor a Pagar + IPI"###"Valor a Pagar"
@ 106,202 GROUP oGroup1 TO 133,310 LABEL if(nVlrIpi > 0 ,OemToAnsi(STR0027), OemToAnsi(STR0028));
OF oFolder:aDialogs[2] PIXEL
oGroup:SetFont(oFnt3)

@ 117,207 SAY oVlrLiq1 VAR IIf(cPaisLoc=="BRA",Transform(nLiq+nVlrAcrs-nVlrTxDesc,aPictures[_12VLRTOT]),;
Transform(IIf(nVlrAcrs > 0 .OR. aDadosJur[9] > 0,nLiq+aDadosJur[4]+aDadosJur[1]+LJ010VlrFSD()-aDadosJur[9],;
nLiq+nVlrAcrs-nVlrTxDesc),aPictures[_12VLRTOT]));
SIZE 100,10 OF oFolder:aDialogs[2] PIXEL RIGHT COLOR CLR_HRED FONT oFnt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 													 ³
//³ 					 FOLDER RECEBIMENTOS 			 ³
//³ 													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// O botão de fechar venda foi colocado aqui para ser o primeiro objeto da pasta e receber o foco quando a mesma for acionada.

DEFINE SBUTTON oBtn1 FROM 87,272 TYPE 1 ENABLE OF oFolder:aDialogs[3];
ACTION ( iif( lLog1,(aCloaCols := Aclone(aCols),LjGrLog(@nHandle,cNumOrc,@cLjArq,cImpressora,cPorta)),.T.),;
iif( LJAvalCred( cCliente, cLoja, nVlrLiq, aReceb )[1] .And. Lj010GrLoj(cNumOrc,cCliente,cVendLoja,nVlrTot,@nDescloj,@nVlrLiq,;
dDtlim,nCondicao,nEntrada,nFinanciado,nTxDesc,nParcelas,;
nIntervalo,@nValorBase,cForma,cCondicao,nCheck,lCheck3,;
cLoja,oGet,.T.,@lInclui,lAltera,@aCondicoes,@cCombo,oEntrada,;
oNumParcelas,oFinanciado,@nNumParcelas,oTxJuros,cComboAnt2,@nTxDescon,;
oTxDescon,cNroPCli,nFator,lUsouFator,cAdmFator,@nDescPer,@nLiq,nTroco,cNumSx8,;
oGetOrca,aCpoEnchoice,lLjMontP,oVlrImpos,nTipoJur,oTipoJuros,@cTipoJuros,;
oCombo,oIntervalo,@cLJDTORC,@lLJDTOrc,@aMoedas,oVlrTotVen,cLjArq,aCloaCols,nHandle),;
(nOpca:=1,lGravou := .T.,oDlgLoja:End()),;
(nOpca:=3,lGravou := lAtuNcc := .F.)) , if(lLog1, LjDelLog(nHandle,aCloaCols,aCols,cLjArq,cNumOrc,nDescLoj,cCliente,cLoja),.T.))
oBtn1:cToolTip = STR0049 				// Fechar a Venda

oReceb := TCBrowse():New(.3,.8,303,73,,{OemToAnsi(STR0034),;
OemToAnsi(STR0035),OemToAnsi(STR0036),;
OemToAnsi(STR0022)},{50,80,100,150},oFolder:aDialogs[3],,,,,;
{|nRow,nCol,nFlags|Lj010DadPg(oReceb,oReceb:nAt,.T.,oCheck3,;
@lCheck3,@lUsouFator,cAdmFator,oFolder)}, , , , , , , .F., , , , , )

//Duplo click do mouse sobre a parcela para editar
oReceb:cToolTip := STR0033
oReceb:SetArray( aReceb )

oReceb:nFreeze := 1

ADD COLUMN TO oReceb HEADER STR0034 OEM DATA {|| aReceb[oReceb:nAt,1]}	ALIGN LEFT SIZE 40 PIXELS // Data
ADD COLUMN TO oReceb HEADER STR0035 OEM DATA {|| Transform(aReceb[oReceb:nAt,2],PesqPict("SL1","L1_VLRTOT",16,aReceb[oReceb:nAt,11]))} ALIGN LEFT SIZE 50 PIXELS // Valor
ADD COLUMN TO oReceb HEADER STR0036 OEM DATA {|| aReceb[oReceb:nAt,3]} ALIGN LEFT SIZE 60 PIXELS	// Formas de Pagamento
ADD COLUMN TO oReceb HEADER STR0043 OEM DATA {|| aReceb[oReceb:nAt,4]} ALIGN LEFT SIZE 60 PIXELS	// Administradora
ADD COLUMN TO oReceb HEADER STR0044 OEM DATA {|| aReceb[oReceb:nAt,5]} ALIGN LEFT SIZE 50 PIXELS	// N£mero do Cheque/Cart„o
ADD COLUMN TO oReceb HEADER STR0045 OEM DATA {|| aReceb[oReceb:nAt,6]} ALIGN LEFT SIZE 50 PIXELS	// "Agˆncia (Cheque)
ADD COLUMN TO oReceb HEADER STR0046 OEM DATA {|| aReceb[oReceb:nAt,7]} ALIGN LEFT SIZE 50 PIXELS	// Conta (Cheque)
If cPaisLoc == "BRA"
	ADD COLUMN TO oReceb HEADER STR0047 OEM DATA {|| aReceb[oReceb:nAt,8]} ALIGN LEFT SIZE 60 PIXELS	// RG do Cliente
Else
    cLabelDoc  := AllTrim(RetTitle("A1_RG"))+STR0107  //" do Cliente" 		
	ADD COLUMN TO oReceb HEADER cLabelDoc OEM DATA {|| aReceb[oReceb:nAt,8]} ALIGN LEFT SIZE 60 PIXELS	// RG do Cliente
EndIf
ADD COLUMN TO oReceb HEADER STR0048 OEM DATA {|| aReceb[oReceb:nAt,9]} ALIGN LEFT SIZE 50 PIXELS	// Telefone
ADD COLUMN TO oReceb HEADER STR0077 OEM DATA {|| aReceb[oReceb:nAt,11]} ALIGN LEFT SIZE 50 PIXELS	//Moeda
ADD COLUMN TO oReceb HEADER STR0088 OEM DATA {|| aReceb[oReceb:nAt,18]} ALIGN LEFT SIZE 40 PIXELS	//Compensacao
If lSrvCns  // Servidor de Consultas cheque-pre.com
	ADD COLUMN TO oReceb HEADER STR0081 OEM DATA {|| aReceb[oReceb:nAt,12]} ALIGN LEFT SIZE 50 PIXELS	//Mes abertura da Conta
	ADD COLUMN TO oReceb HEADER STR0082 OEM DATA {|| aReceb[oReceb:nAt,13]} ALIGN LEFT SIZE 50 PIXELS	//Ano Abertura Conta
	ADD COLUMN TO oReceb HEADER STR0083 OEM DATA {|| aReceb[oReceb:nAt,14]} ALIGN LEFT SIZE 50 PIXELS	//Tipo do Cheque
	ADD COLUMN TO oReceb HEADER STR0084 OEM DATA {|| aReceb[oReceb:nAt,15]} ALIGN LEFT SIZE 50 PIXELS	//Cgc do Emitente do Cheque
	ADD COLUMN TO oReceb HEADER STR0085 OEM DATA {|| aReceb[oReceb:nAt,16]} ALIGN LEFT SIZE 100 PIXELS	//Nome do Cliente
	ADD COLUMN TO oReceb HEADER STR0086 OEM DATA {|| aReceb[oReceb:nAt,17]} ALIGN LEFT SIZE 30 PIXELS	//Serie do Cheque
Endif

// C lculo de Troco
@ 80, 05 GROUP oGroup TO 133,110 LABEL OemToAnsi(STR0037) OF oFolder:aDialogs[3] PIXEL
oGroup:SetFont(oFnt3)

//Valor Pago
@  93, 08 SAY OemToAnsi(STR0061) OF oFolder:aDialogs[3] PIXEL
@  93, 47 MSGET oValPag VAR nValPag SIZE 60,08 OF oFolder:aDialogs[3] PIXEL;
RIGHT Picture aPictures[_16VLRTOT] Valid lj010Troco(nValPag,@nTroco,oTroco)
	
//Troco
@ 108, 08 SAY OemToAnsi(STR0062) SIZE 30,08 OF oFolder:aDialogs[3] PIXEL
@ 108, 13 SAY oTroco VAR Transform(nTroco,aPictures[_16VLRTOT])  SIZE 92,10;
OF oFolder:aDialogs[3] PIXEL RIGHT COLOR CLR_HBLUE FONT oFnt1

// Cria interface do troco localizado...
If cPaisLoc <> "BRA" .And. GetMV("MV_LJTRLOC")
	LjCalcTrc("BALCAO",,,oFolder,@aMoedas,@aTroco)
EndIf

// ImpressÆo
@ 80,115 GROUP oGroup TO 133,185 LABEL OemToAnsi(STR0038) OF oFolder:aDialogs[3] PIXEL
oGroup:SetFont(oFnt3)

// Cupom Fiscal / Nota Fiscal / Cupom de Venda / NÆo Imprimir
If lFiscal // Impressora Fiscal nao exibira a opcao Nao Imprimir
	If GetMv("MV_FISNOTA")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se eh usuario fiscal e utiliza o MV_FISNOTA ligado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nCheck := If( !(Str(nCheck,1,0)$"12"), 1, nCheck )
		@ 89,116 RADIO oCheck1 VAR nCheck 3D SIZE 60,10 PROMPT;
		OemToAnsi(STR0063), OemToAnsi(STR0064);
		OF oFolder:aDialogs[3] PIXEL ON CHANGE Lj010NFCup()
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando eh usuario fiscal e o MV_FISNOTA = .F.³
		//³nao obedece o MV_LOJAOPI                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nCheck := 1
		@ 89,116 RADIO oCheck1 VAR nCheck 3D SIZE 60,10 PROMPT;
		OemToAnsi(STR0063);
		OF oFolder:aDialogs[3] PIXEL ON CHANGE Lj010NFCup()
	EndIf
Else
	nCheck := If( Str(nCheck,1,0)$'234', nCheck, 2 )
	@ 89,116 RADIO oCheck1 VAR nCheck 3D SIZE 60,10 PROMPT;
	OemToAnsi(STR0063), IIf(cPaisLoc != "SAL",OemToAnsi(STR0064),OemToAnsi(STR0105)),;  ////"Cupom Fiscal"###"Nota Fiscal"###"Doc. Saida" 		
	IIf(cPaisLoc != "GUA",OemToAnsi(STR0065),OemToAnsi(STR0108)), OemToAnsi(STR0066);  //"Cupom de Venda"###"Ticket"###"Nao imprimir"
	OF oFolder:aDialogs[3] PIXEL ON CHANGE Lj010NFCup()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao para desabilitar o Botao RADIO ³
//³ Caso seja usu rio fiscal			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFiscal
	// Apesar de ser usuario de cupom fiscal tem opcao de imprimir NF
	oCheck1:Enable(1)
	If GetMv("MV_FISNOTA")
		oCheck1:Enable(2)
	Else
		oCheck1:Disable(2)
	EndIf
	oCheck1:Disable(3)
	oCheck1:Disable(4)
Else
	oCheck1:Disable(1)
	oCheck1:Enable(2)
	oCheck1:Enable(3)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Toda venda deve ser impressa. Caso ocorra ³
   //³ algum erro na impressao, deve anular a NF ³
   //³ e emitir outro doc. - Loc. Guatemala      ³   
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If cPaisLoc == "GUA"   
	   oCheck1:Disable(4)
	Else	
	   oCheck1:Enable(4)
	EndIf   
	oCheck1:Refresh()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pontos de Entrada 					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLj010ChkT
	nCheck:=ExecTemplate("Lj010Chk",.F.,.F.)
	oCheck1:Refresh()
Endif

If lLj010Chk
	nCheck:=ExecBlock("Lj010Chk",.F.,.F.)
	oCheck1:Refresh()
Endif

// Imprimir Cheques
@ 80,190 TO 103,255 OF oFolder:aDialogs[3] PIXEL
@ 89,195 CHECKBOX oCheck3 VAR lCheck3 PROMPT OemToAnsi(STR0080);	// Imprimir cheques
SIZE 50,08 OF oFolder:aDialogs[3] PIXEL FONT oFolder:aDialogs[3]:oFont

if !lUsaCH
	oCheck3:Disable()
endif

// Total a Pagar + IPI / Total a Pagar
@ 108,190 GROUP oGroup2 TO 133,310 LABEL if(nVlrIpi > 0,OemToAnsi(STR0039),OemToAnsi(STR0040));
OF oFolder:aDialogs[3] PIXEL
oGroup:SetFont(oFnt3)

// Valor Pago
@ 118,215 SAY oVlrLiq2 VAR IIf(cPaisLoc="BRA",Transform(nLiq+nVlrAcrs-nVlrTxDesc,aPictures[_12VLRLIQ]),;
Transform(IIf(nVlrAcrs > 0 .OR. aDadosJur[9] > 0,(nLiq-aDadosJur[6])+aDadosJur[4]+aDadosJur[1]-aDadosJur[9],nLiq),;
aPictures[_12VLRLIQ])) SIZE 90,10 OF oFolder:aDialogs[3] PIXEL RIGHT COLOR CLR_HRED FONT oFnt

If nOpcx == 4
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
	//³ Verifica o numero do orcamento. Na opcao Finaliza Venda, ao      |
	//³ gravar o orcamento nao eh necessario refazer as parcelas 	     |
	//| utilizando a condicao de pagamento padrao, portanto a lLjMontP   | 
	//| nao eh passada por referencia para manter-se com .F. 			 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRetConc := Lj010Num(	Space(TamSx3("L1_NUM")[1]),cNumSX8,		@lInclui,		@lAltera,;
							@cCliente,					@cLoja,			@nDescloj,		@nVlrLiq,;
							@cVendLoja,					@dDtLim,		@nVlrTot,		@nEntrada,;
							@nFinanciado,				@nParcelas,		@nIntervalo,	oCliente,;
							oLoja,						oAutorDesc,		oDescont,		oVlrLiq,;
							oVlrLiq1,					oVlrLiq2,		oVend,			oVlrTot,;
							oDtLim,						@cCombo,		oCombo,			@cComboAnt2,;
							@cCondicao,					@cDescCond,		@lFirstAlter,	@aCondicoes,;
							oEntrada,					oNumParcelas,	oFinanciado,	@nValorBase,;
							@cForma,					@nCondicao,		@nNumParcelas,	oTxJuros,;
							oReceb,						@nCheck,		@lCheck3,		oCheck1,;
							oCheck3,					@oGetOrca,		@cNumOrcAnt,	@nVlrAcrs,;
							oVlrAcrs,					oNroPCli,		@cNroPCli,		@nFator,;
							@lUsouFator,				@cAdmFator,		@cTipoJuros,	oTipoJuros,;
							@nLiq,						@oVlrItens,		@nVlrItens,		@nDescPer,;
							@cDesc,						oDesc,			lLjMontP,		@nTipoJur,;
							@cLJDTORC,					@lLJDTOrc,		@aMoedas,		@aTroco,;
							nOpcx,						@nTxDescon,		@cMoeda,		aMoeda)

	//Na Finalizacao da Venda mantenho o tipo de impressao default gravada no orcamento
	nCheck    := Val(Left(SL1->L1_IMPRIME,1))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o usuario que estiver finalizando a venda for fiscal e o MV_FISNOTA    ³
	//³ estiver desabilitado deve obrigatoriamente setar a opcao 1 (cupom fiscal) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lFiscal .AND. !GetMv("MV_FISNOTA")
    	nCheck := 1	//Impressao de cupom
	EndIf	  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica a opcao de impressao, para trocar, se necessario, a variavel  ³
	//³lFiscal para .T. se for impressao de nota fiscal para um usuario fiscal³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Lj010NFCup()
EndIF

cOrcamen		:= cNumOrc

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se estiver em modo flat configura lMaximized := Falso pq a venda     ³
//³ balcao nao usa redimensionamento automatico da tela.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FlatMode()
	oDlgLoja:lMaximized := .F.
	oDlgLoja:lCentered  := .F.
Endif

ACTIVATE DIALOG oDlgLoja ON INIT Iif(lRetConc,Eval({||(LchoicBar(nOpcx,cCliente,{||cNumOrc},;
{|| Eval(bValid),Eval(bValCampo),IF(lLog1,(aCloaCols := Aclone(aCols),LjGrLog(@nHandle,cNumOrc,@cLjArq,cImpressora,cPorta)),.T.),;
SetButtons(.F.),lAtuNcc := .T.,IIf(oFolder:nOption == 1,Eval(bGravOrc),oFolder:SetOption(oFolder:nOption)),; //Deshabilitar  os botoes de OK e cancelar
iif( Lj010GrLoj(cNumOrc,cCliente,cVendLoja,nVlrTot,nDescloj,nVlrLiq,;
dDtlim,nCondicao,nEntrada,nFinanciado,nTxDesc,nParcelas,;
nIntervalo,nValorBase,cForma,cCondicao,nCheck,lCheck3,;
cLoja,oGet,.F.,@lInclui,lAltera,@aCondicoes,@cCombo,oEntrada,;
oNumParcelas,oFinanciado,@nNumParcelas,oTxJuros,cComboAnt2,@nTxDescon,;
oTxDescon,cNroPCli,nFator,lUsouFator,cAdmFator,nDescPer,nLiq,nTroco,;
cNumSx8,oGetOrca,aCpoEnchoice,lLjMontP,oVlrImpos,nTipoJur,oTipoJuros,;
@cTipoJuros,oCombo,oIntervalo,@cLJDTORC,@lLJDTOrc,@aMoedas,oVlrTotVen,;
cLjArq,aCloaCols,nHandle),;
(nOpca:=1,lGravou := .T.),;
(nOpca:=3,lGravou := lAtuNcc := .F.)),;
SetButtons(.T.),;//Restaurar  os botoes de OK e cancelar
iif(lLog1, LjDelLog(nHandle,aCloaCols,aCols,cLjArq,cNumOrc,nDescLoj,cCliente,cLoja),.T.),oDlgLoja:End() },;
{|| If(lLog1,LjGrLog(@nHandle,cNumOrc,@cLjArq,cImpressora,cPorta),.T.),IIF(lLog1,LjDelLog(nHandle,aCloaCols,aCols,cLjArq,cNumOrc,nDescLoj,cCliente,cLoja),.T.),nOpca := 2,oDlgLoja:End()},;
{||nLiq+nVlrAcrs-nVlrTxDesc},{||nVlrAcrs},{||nVlrDesc},nDescPer),;
Iif(nOpcx = 4,(Eval(oGet:oBrowse:bLostFocus),oFolder:SetOption(nFldFVenda),if(ExistBlock("LJATV01") ,ExecBlock("LJATV01" ,.F.,.F.),NIL)), .T. ) ) }),oDlgLoja:End());
VALID Lj010Valid(@nOpca,@lGravou,lInclui,cNumOrc,lRetConc) ;
ON MOVE (oDlgLoja:Move(100,1,,,.T.))

//Solta o registro ref ao Softlock()
MsUnlockAll()

SETAPILHA()
SetKey(122,{|| NIL})
SetKey( 5,{|| NIL})
SetKey( 1,{|| NIL})
SetKey( 16,{|| NIL})
SetKEY( 15,{|| NIL})
SetKEY( 24,{|| NIL})
SetKEY( 19,{|| NIL})
SetKEY(VK_F6,{|| NIL})
SetKEY(VK_F7,{|| NIL})
SetKEY(VK_F8,{|| NIL})
SetKEY(VK_F9,{|| NIL})
SetKEY(VK_F10,{|| NIL})

lExit:=lGravou
If nOpca == 2 .Or. nOpca == 0
	lOkTroc := .F.
Else
	lOkTroc := .T.
EndIf

If __lSX8
	If lGravou
		If cNumSx8 == cNumOrc
			While (GetSX8Len() > nSaveSx8)
				ConfirmSX8()
			End
		Else
			While (GetSX8Len() > nSaveSx8)
				RollBackSx8()
			End
		EndIf
	Else
		While (GetSX8Len() > nSaveSx8)
			RollBackSx8()
		End
	EndIf
EndIf

If lFilSl1
	If ExistBlock("LJFLTSL1")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza o Filtro                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao := ExecBlock("LJFLTSL1")
		bFiltraBrw := {|| FilBrowse("SL1",@aQuery,@cCondicao) }
		Eval(bFiltraBrw)
		mBrowse( 6, 1,22,75,"SL1",,,,,,aCores )			

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Encerra o filtro da tabela.                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		EndFilBrw("SL1",aQuery)		
	Else
		dbSelectArea("SL1")
		dbSetOrder( 2 )
		dbGoTop()
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Redefinir a variavel lFiscal, pois qdo ela esta ativa e o      |
//|parametro MV_FISNOTA estiver como T, ao finalizar a venda com  |
//³uma Nota Fiscal a variavel lFiscal eh alterada para F		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetMV( "MV_FISNOTA" ) .and. ! lFiscal
	lFiscal:= LJProFile(3)
EndIf

// Redefine o valor da variavel de controle de layaway
lLayAway := .F.
lCompensa:= .F.

Return lOkTroc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AvaliaComi³ Autor ³ Adriano Sacomani      ³ Data ³07.07.99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica comissoes                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AvaliaComis()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function AvaliaComis(aVendedor,i,cProduto,cCliente,nValProduto)
Local nAliquota		:=0
Local cAlias		:=Alias()

Default nValProduto 	:= 0

dbSelectArea( "SA3" )
dbSetOrder(1)
dbSeek( xFilial("SA3") + aVendedor[i][1] )

dbSelectArea( "SB1" )
dbSeek( xFilial("SB1") + cProduto )
If !Empty(SB1->B1_COMIS)
	nAliquota := SB1->B1_COMIS
ElseIf !Empty(SA3->A3_COMIS)
	nAliquota := SA3->A3_COMIS
Else
	nAliquota := SA1->A1_COMIS
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona o percentual da comissao em um array para tirar a media das ³
//³ comissoes, porque a comissao pode ser calculada com base nos produtos³
//³ e no cadastro de vendedores                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aVendedor[i][9], (nAliquota * nValProduto)/100 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula a media das aliquotas                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aVendedor[i][2] := nAliquota

dbSelectArea(cAlias)
Return (nAliquota)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LJWQTD()  ³ Autor ³ Luis Marcelo Kotaki   ³ Data ³13/09/99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Obriga a quantidade ser maior que 0 (zero)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LJWQTD()
Local nValor := &(ReadVar())
Local lRet := .T.
iif(lGrade,A010QTDGRA(),.T.)
If nValor <= 0
	lRet := .F.
	MsgStop(STR0104)	// Nao e permitido valor negativo nesse campo.
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FilterSl1Ini³ Autor ³ Fabio Rogerio Pereira ³ Data ³ 01/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Filtro inicial da mbrowse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FilterSl1Ini()   
Local cRet   := xFilial("SL1") + Space(3) + Space(TamSx3("L1_DOC")[1]) + Space(10)

SL1->( dbSetOrder(2) )

If nRecnoFilt != 0 .And. nRecnoFilt != SL1->( Recno() ) .And. lPosFilt
	SL1->( MsGoto( nRecnoFilt ))
	lPosFilt := .F.	
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FilterSl1Fim³ Autor ³ Fabio Rogerio Pereira ³ Data ³ 01/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Filtro final da mbrowse                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FilterSl1Fim()
Local cRet   := xFilial("SL1") + Space(3) + Space(TamSx3("L1_DOC")[1]) + 'zzzzzzzzzz'

SL1->( dbSetOrder(2) )  

If nRecnoFilt != 0 .And. nRecnoFilt != SL1->( Recno() ) .And. lPosFilt
	SL1->( MsGoto( nRecnoFilt ))
	lPosFilt := .F.
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LJ010DEL   ³ Autor ³ Edney Soares de Souza ³ Data ³ 04/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do ponto de entrada executado ao se deletar no aCols ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LJ010DEL()
Local lRet 			:= .T.
Local aReserva 		:= {}
Local nPosReserva 	:= aScan(aHeader,{|z| Alltrim(Upper(z[2]))=="L2_RESERVA" })
Local nPosLojaRes 	:= aScan(aHeader,{|z| Alltrim(Upper(z[2]))=="L2_LOJARES" })
Local nPosProduto 	:= aScan(aHeader,{|z| Alltrim(Upper(z[2]))=="L2_PRODUTO" })
Local nPosLocal 	:= aScan(aHeader,{|z| Alltrim(Upper(z[2]))=="L2_LOCAL" })
Local nPosDescPro 	:= aScan(aHeader,{|x| Alltrim(Upper(x[2]))=="L2_DESCRI"})
Local lDeleted		:= aCols[n][Len(aHeader)+1]
Local cLojaLocal 	:= ""
Local cLojaReserva	:= ""
Local lLjPrdRes		:= ExistBlock("LJPRDRES") 
Local lLjPrdResT	:= ExistTemplate("LJPRDRES")
Local aLjPrdRes		:= {}  	// Retorno do P.E. LJPRDRES

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não deixar dat um recall no item já deletado e cancelado na impressora fiscal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("lVendConc") == "L" .And. lVendConc
	If lDeleted			//Se já estiver deletado não deixar efetuar a reversão pois o item já foi impresso
		Eval(bDelProd) // Eval(oGet:oBrowse:bDrawSelect)
		Return(.F.)	
	EndIf				
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega o codigo da loja local               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SLJ")
dbSetOrder(3)
If dbSeek(xFilial("SLJ")+SM0->M0_CODIGO+FWGETCODFILIAL)
	cLojaLocal := SLJ->LJ_CODIGO
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para tratamento do código e descricao do produto             ³
//³ Retorno a posicao da aCols que contem o codigo e a descricao do produto       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLjPrdResT
	aLjPrdRes := ExecTemplate("LJPRDRES",.F.,.F.,{nPosProduto,nPosDescPro} )
	If ValType(aLjPrdRes) == "A" .And. Len(aLjPrdRes) >= 2
		nPosProduto	:= aLjPrdRes[1]
		nPosDescPro	:= aLjPrdRes[2]
	Endif
Endif

If lLjPrdRes
	aLjPrdRes := ExecBlock("LJPRDRES",.F.,.F.,{nPosProduto,nPosDescPro} )
	If ValType(aLjPrdRes) == "A" .And. Len(aLjPrdRes) >= 2
		nPosProduto	:= aLjPrdRes[1]
		nPosDescPro	:= aLjPrdRes[2]
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se houver reserva, avisa o usuario e pergunta se e         ³
//³ou nao para cancelar a mesma                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lDeleted .And. !Empty(aCols[n][nPosReserva])
	If MsgYesNo(STR0090) //"Nao sera possivel deletar a linha sem cancelar a reserva. Deseja continuar ?"
		cLojaReserva := Iif(Empty(aCols[n][nPosLojaRes]),cLojaLocal,aCols[n][nPosLojaRes])
		aReserva := {{aCols[n][nPosReserva],cLojaReserva,aCols[n][nPosProduto],aCols[n][nPosLocal] }}
		LjMsgRun(STR0091,,{|| lRet := LjCancRes( aReserva )} ) //"Aguarde ... Cancelando a Reserva."
		If !lRet
			MsgStop(STR0092) //"Nao foi possivel cancelar a reserva."
			aCols[n][Len(aHeader)+1] := .F.
			lRet := .F.
		Else
			aCols[n][nPosReserva] := Space(TamSx3("L2_RESERVA")[1])
			aCols[n][nPosLojaRes] := Space(TamSx3("L2_LOJARES")[1])
			lRet := .T.
		Endif
	Else
		aCols[n][Len(aHeader)+1] := .F.
		lRet := .F.
	Endif
Endif

If ExistTemplate("L010DEL")
	lRet := ExecTemplate("L010DEL",.F.,.F.)
	if Valtype(lRet) != "L"
		lRet := .T.
	Endif
Endif

If ExistBlock("L010DEL")
	lRet := ExecBlock("L010DEL",.F.,.F.)
	if Valtype(lRet) != "L"
		lRet := .T.
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o item pode ser deletado, quando for concomitante, e envia o  ³
//³ comando de cancelamento para o ECF.                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. Type("lVendConc") == "L" .And. lVendConc
	If !lDeleted			//Verifica se o item não esta deletado.
		If !Empty(aCols[n][nPosProduto])
			If !Lj010CanIT()		// Envia o camando de cancelamento para o ECF.
				Return(.F.)
			EndIf	
		EndIf	
	EndIf				
EndIf

//Recalcular os impostos na exclusao de uma linha do aCols - Localizacoes
lDetalhe  := .F.  
oGet:oBrowse:DrawSelect()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se as inconsistencias acima for aprovadas, faco um refresh ³
//³dos valores da venda                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	Eval(bDelProd)
EndIf                    

oGet:oBrowse:Refresh(.F.)

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VerifCaixa³ Autor ³ Fernando Machima      ³ Data ³ 23/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se caixa existe(tratamento multi-moeda).O portador³±±
±±³          ³do titulo(caixa) e definido pela moeda                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := VerifCaixa(ExpN1,ExpC2,ExpC3,ExpC4)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Moeda do titulo                                    ³±±
±±³          ³ ExpC2 - Codigo do Caixa logado                             ³±±
±±³          ³ ExpC3 - Codigo da agencia do Caixa                         ³±±
±±³          ³ ExpC4 - Codigo da conta do Caixa                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VerifCaixa(nMoeda,cCodigo,cAgencia,cConta)

//retiramos o corpo dessa funcao, pois a funcao abaixo eh identica.
LjxDVerCx(nMoeda,cCodigo,cAgencia,cConta)	//LOJXFUND.PRW

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010Ativa³ Autor ³ Fernando Machima      ³ Data ³ 22/03/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ativa tela de perguntas dos lancamentos contabeis          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := Lj010Ativa()                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Venda Balcao                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj010Ativa()

Local aArea	:=	GetArea()

Pergunte("LJA010",.T.)
lDigita   := ( mv_par01==1)
lJunta    := ( mv_par02==1)
lGeraLanc := ( mv_par03==1)

RestArea(aArea)

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010RecIV³ Autor ³ Fernando Machima      ³ Data ³ 22/03/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava impostos variaveis (Localizacoes)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := Lj010RecIV(nPos,cCod,nImpostoFat,lGeraFat,lPrim   ³±±
±±³          ³ lMultiF,aImpsBas,aImpsVal)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Venda Balcao                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj010RecIV(nPos,cCod,nImpostoFat,lGeraFat,lPrim,lMultiF,aImpsBas,aImpsVal)
Local nCA       := 0
Local nRndFat   := MsDecimais(nMoedaCor)
Local cCampo    := ""
Local nPosBase  := 0
Local nPosVal   := 0
Local nCpo      := 0


SL1->(RecLock("SL1",.F.))
aImpVarSD2[1] := SL2->L2_QUANT
aImpVarSD2[2] := SL2->L2_VRUNIT
aImpVarSD2[3] := SL2->L2_VLRITEM
aImpVarSD2[4] := 0.00
aImpVarSD2[5] := 0.00
aImpVarSD2[6] := {}
nPosCols := 1
nPosRow  := nPos
SF4->(DbSetOrder(1))
SF4->( dbSeek(xFilial("SF4")+SL2->L2_TES) )
CalcTesxIp( "S", SL2->L2_VLRITEM, SL2->L2_VRUNIT,cCod,nPosCols,nPosRow,"BALCAO" )

For nCA := 1 To Len( aImpVarSD2[6] )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravar os Impostos gerados atrav‚s do Roteiro de c lculo da ³
	//³ Amarra‡Æo Tes X Impostos...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Subs(aImpVarSD2[6,nCA,7],3,7) == "_BASIMP"
		cCampo := "L2"+Subs(aImpVarSD2[6,nCA,7],3,8)
		If SL2->(FieldPos(cCampo)) > 0
			If lPrim   //Para o primeiro item inicializa o campo
				SL2->(FieldPut(FieldPos(cCampo),0))
			EndIf
			SL2->( FieldPut( FieldPos( cCampo ), Round(aImpVarSD2[6,nCA,3],nRndFat) ) )
		Endif
		
		cCampo := "L1"+Subs(aImpVarSD2[6,nCA,7],3,8)
		If SL1->(FieldPos(cCampo)) > 0
			If lGeraFat
				If !lPrim
					If ( nPosBase  := ASCAN( aImpsBas,{ |x| ALLTRIM( x[1] ) == cCampo } ) ) > 0
						aImpsBas[nPosBase][2] += Round(aImpVarSD2[6,nCA,3],nRndFat)
					Else
						Aadd(aImpsBas,{cCampo,Round(aImpVarSD2[6,nCA,3],nRndFat)})
					EndIf
				Else
					aImpsBas := {}
					Aadd(aImpsBas,{cCampo,Round(aImpVarSD2[6,nCA,3],nRndFat)})
					If !lMultiF    //Valida se trata de multi-fatura
						SL1->(FieldPut(FieldPos(cCampo),0))
					EndIf
				EndIf
			Else
				If lPrim
					SL1->(FieldPut(FieldPos(cCampo),0))
				EndIf
			EndIf
			SL1->( FieldPut( FieldPos( cCampo ), Round(&(cCampo)+aImpVarSD2[6,nCA,3],nRndFat) ) )
		Endif
		
		If lGeraFat
			cCampo := "D2"+Subs(aImpVarSD2[6,nCA,7],3,8)
			If SD2->(FieldPos(cCampo)) > 0
				SD2->( FieldPut( FieldPos( cCampo ), Round(aImpVarSD2[6,nCA,3],nRndFat) ) )
			Endif
			
			nCpo  := SD2->(FieldPos("D2_ALQIMP"+subs(aImpVarSD2[6,nCA,7],10,1)))
			If nCpo > 0
				SD2->(FieldPut(nCpo,aImpvarSD2[6,nCA,2])) //Valor Aliquota
			Endif
		EndIf
	EndIf
	
	If Subs(aImpVarSD2[6,nCA,6],3,7) == "_VALIMP"
		cCampo := "L2"+Subs(aImpVarSD2[6,nCA,6],3,8)
		If SL2->(FieldPos(cCampo)) > 0
			If lPrim   //Para o primeiro item inicializa o campo
				SL2->(FieldPut(FieldPos(cCampo),0))
			EndIf
			SL2->( FieldPut( FieldPos( cCampo ), Round(aImpVarSD2[6,nCA,4],nRndFat) ) )
		Endif
		
		cCampo := "L1"+Subs(aImpVarSD2[6,nCA,6],3,8)
		If SL1->(FieldPos(cCampo)) > 0
			If lGeraFat
				If !lPrim
					If ( nPosVal  := ASCAN( aImpsVal,{ |x| ALLTRIM(x[1]) == cCampo } ) ) > 0
						aImpsVal[ nPosVal ][2] += Round( aImpVarSD2[6][ nCA ][4], nRndFat )
					Else
						Aadd( aImpsVal,{ cCampo, Round( aImpVarSD2[6][ nCA ][4], nRndFat ) } )
					EndIf
				Else
					aImpsVal := {}
					Aadd( aImpsVal,{ cCampo, Round( aImpVarSD2[6][ nCA ][4],nRndFat)})
					If !lMultiF
						SL1->(FieldPut(FieldPos(cCampo),0))
					EndIf
				EndIf
			Else
				If lPrim
					SL1->(FieldPut(FieldPos(cCampo),0))
				EndIf
			EndIf
			SL1->( FieldPut( FieldPos( cCampo ), Round(&(cCampo)+aImpVarSD2[6,nCA,4],nRndFat) ) )
		Endif
		
		If lGeraFat
			cCampo := "D2"+Subs(aImpVarSD2[6,nCA,6],3,8)
			If SD2->(FieldPos(cCampo)) > 0
				If lPrim   //Para o primeiro item inicializa o campo
					SD2->(FieldPut(FieldPos(cCampo),0))
				EndIf
				SD2->( FieldPut( FieldPos( cCampo ), Round(aImpVarSD2[6,nCA,4],nRndFat) ) )
			Endif
		EndIf
		
		If Substr(aImpVarSD2[6,nCA,5],2,1) == "1"
			nImpostoFat   += aImpVarSD2[6,nCA,4]
		EndIf
	EndIf
Next nCA
SL1->(MsUnlock())
lPrim := .F.

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj010Vnd  ³ Autor ³Eduardo J. Zanardo     ³ Data ³ 25/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Controle da Saida do Programa de inclusao de orcamentos	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Vnd(cAlias,nReg,nOpcx)
Local lExit:=.T.

If SuperGetMV( "MV_FILTSL1" )
	nRecnoFilt := SL1->( Recno() )
EndIf

While lExit
	Lj010Ate(cAlias,nReg,nOpcx,@lExit)
	if !GetMV("MV_SEQATE")
		exit
	EndIf
End

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj010VarMod3³ Autor ³Marcos Alves           ³ Data ³ 02/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Redefine as variaveis com os dados selecionados na enchoice  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj010VarMod3(aSL1Default,cNumOrc,cVendLoja,cCliente,cLoja,cNroPCli)

cNumOrc  :=M->&(aSL1Default[1,1])
cVendLoja:=M->&(aSL1Default[2,1])
cCliente :=M->&(aSL1Default[3,1])
cLoja    :=M->&(aSL1Default[4,1])
cNroPCli :=M->&(aSL1Default[5,1])
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj010NFCup  ³ Autor ³Marcos Alves           ³ Data ³ 22/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Redefine a variavel lFiscal:=.F., qdo selecionado opcao de   ³±±
±±³          ³ impressao de Nota Fiscal                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj010NFCup()

if nCheck=1
	lFiscal:= LJProFile(3)
Else
	lFiscal:=.F.
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Lj010AvCred³ Autor ³Marcio Torresson     ³ Data ³ 22/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validar o Valor digitado e verificar o limite de Credito.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := Lj010AvCred()                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 := Logico, cliente tem ou nao credito para a compra  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Venda Balcao                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ010AvCred()

Local lCredito	:= .T.               //Retorna se cliente tem credito
Local cMsg      := ""                //Mensagem de bloqueio de credito
Local nValorCrd := 0                 //Valor a ser avaliado
Local cSimMoeda := GetMV("MV_SIMB1") //Simbolo da moeda 1

cBlCred  := ""                       //Controla motivo do bloqueio de credito

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a condicao de pagamento eh a vista. A analise de credito deve ser habilitada³
//³pelo parametro MV_CREDLJ e pela permissao do Caixa.                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Lj010AvCond(SE4->E4_COND) .AND. GetMv("MV_CREDLJ") <> "N" .AND. LJProfile(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao considera as formas de pagamento Cartao de Credito/Debito nem Dinheiro na analise   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                 
	nValorCrd := 0
	aEval(aPgtos, { |x| nValorCrd += iIf( At(AllTrim(x[03]), "CC;CD;" + cSimMoeda) == 0, x[02], 0 ) })

	If nValorCrd > 0                                  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetuar a avaliacao do Cr‚dito. Mesma regra do Faturamento.    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lCredito := MaAvalCred(SA1->A1_COD  ,SA1->A1_LOJA  ,nValorCrd  ,1   ,;
		                       .T.          ,@cBlCred       )
	Endif
Endif

If !Empty(cBlCred) 
	If cBlCred == "01"
		cMsg := OemToAnsi(STR0082)  //"01-Sem Limite de Crédito"
	ElseIf cBlCred == "04"
		cMsg := OemToAnsi(STR0083)  //"04-Limite de Cr‚dito Vencido"
	Else
		cMsg := OemToAnsi(STR0084)  //"99-Outros"
	Endif
	Help(" ",1,"A467LC",,cMsg,4,5)
Endif

Return( lCredito )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³LOJA010A  ³Autor  ³Bruno Sobieski      ³Fecha ³  05/28/01   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Inicializa um array com as pictures para nao ter que chamar³±±
±±³          ³  a pesqpict cada vez que se faz um refresh nos objetos .   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP5                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Lj010SetPict()

aPictures := Array(11)
aPictures[_14DESCONT] := PesqPict("SL1","L1_DESCONT",14,nMoedaCor)
aPictures[_16DESCONT] := PesqPict("SL1","L1_DESCONT",16,nMoedaCor)
aPictures[_14ENTRADA] := PesqPict("SL1","L1_ENTRADA",14,nMoedaCor)
aPictures[_14FINANC]  := PesqPict("SL1","L1_FINANC",14,nMoedaCor)
aPictures[_15TXMOEDA] := PesqPict("SL1","L1_TXMOEDA",15,nMoedaCor)
aPictures[_14VALMERC] := PesqPict("SL1","L1_VALMERC",14,nMoedaCor)
aPictures[_16VALMERC] := PesqPict("SL1","L1_VALMERC",16,nMoedaCor)
aPictures[_12VLRLIQ]  := PesqPict("SL1","L1_VLRLIQ",12,nMoedaCor)
aPictures[_12VLRTOT]  := PesqPict("SL1","L1_VLRTOT",12,nMoedaCor)
aPictures[_14VLRTOT]  := PesqPict("SL1","L1_VLRTOT",14,nMoedaCor)
aPictures[_16VLRTOT]  := PesqPict("SL1","L1_VLRTOT",16,nMoedaCor)

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SetButtons³ Autor ³ Bruno Sobieski        ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Habilita ou nao os bottoes da enchoice                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SetButtons(lOn)
DEFAULT lOn := .T.

//Se lOn TRUE vou habilitar os botoes (os valores que devem ter estao nas static bBut15 e bBut16
If lOn
	oBtOk:bAction	:=	bBut24
	oBtCan:bAction	:=	bBut15
	//Se lOn está em FALSE vou guardar o conteudo do Action dos botoes e anular eles
Else
	bBut24	:=	oBtOk:bAction
	bBut15	:=	oBtCan:bAction
	oBtOk:bAction	:=	{|| Nil}
	oBtCan:bAction	:=	{|| Nil}
EndIf
//Junto com os botoes habilito o CTRL-O e o CTRL+X
SetKey(15,oBtOk:bAction)
SetKey(24,oBtCan:bAction)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Lj010TrcMoeda³Autor  ³ Julio Cesar       ³ Data ³ 20/10/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Recalcula todo aCols, quando a alteracao na moeda corrente ³±±
±±³          ³ da venda.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Moeda anteriormente utilizada                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA010A                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Lj010TrcMoed(nMoedaAnt,lMoeda)

//Cria variaveis com as posicoes dos campos necessarios para a rotina de troca
//de moedas (Cod. Produto, Val. Unitario, Numero da Tabela, Preco de Tabela,
//Desconto e Quantidade).
Local nPProduto := Ascan(aHeader,{|x|Trim(x[2])=="L2_PRODUTO"})
Local nPVlrUnit := Ascan(aHeader,{|x|Trim(x[2])=="L2_VRUNIT"})
Local nPNumTab  := Ascan(aHeader,{|x|Trim(x[2])=="L2_TABELA"})
Local nPPrcTab  := Ascan(aHeader,{|x|Trim(x[2])=="L2_PRCTAB"})
Local nPDesc    := Ascan(aHeader,{|x|Trim(x[2])=="L2_DESC"})
Local nPTes     := Ascan(aHeader,{|x|Trim(x[2])=="L2_TES"})
Local nPQuant   := Ascan(aHeader,{|x|Trim(x[2])=="L2_QUANT"})
Local nLin:=0,nDesc:=0,nIndTab:="",nRegTab:=""
Local nIndSX3:=SX3->(IndexOrd()),nRegSX3:=SX3->(RecNo())
Local aAreaIni := GetArea()
Local cAlias:="",cCampo:=""
Local nMoedaPrv:=1,nLinAux:=n
Local nTxPad   := RecMoeda(dDatabase,nMoedaCor)

If IIf(lMoeda,nMoedaAnt <> nMoedaCor, nTaxaMoeda <> nTxPad) .And. !Empty(aCols[1][nPProduto])
	//Caso a taxa da moeda nao tenha sido informada os calculos nao poderao ser 
	//realizados, pois ocorrera erro na execucao dos gatilhos.
	If nTaxaMoeda <= 0
		//Nao ha cotacao para a moeda escolhida. A conversao da venda nao sera feita.
		MsgAlert(STR0089)
		Return Nil
	EndIf
	
	If !lGradProd
		cAlias := "SB0"
	Else
		cAlias := "SB4"
	EndIf

	dbSelectArea(cAlias)
	nIndTab := IndexOrd()
	nRegTab := RecNo()
	dbSetOrder(1)
				
	For nLin := 1 To Len(aCols)	
		If !Empty(aCols[nLin][nPProduto])
			//Valoria a variavel n com a posicao do aCols que esta sendo lida, para que 
			//a funcao RunTrigger funcione corretamente
			n := nLin
			
			//Armazena o desconto dado antes da conversao da moeda
			nDesc := aCols[nLin][nPDesc]                         
	
			dbSeek(xFilial(cAlias)+aCols[nLin][nPProduto])
			 
			cCampo := '"'+SubStr(cAlias,2,2)+"_MOEDA"+aCols[nLin][nPNumTab]+'"'   
			If FieldPos(&cCampo) > 0 
				nMoedaPrv := &(SubStr(cCampo,2,9))
			EndIf
	
			If (nMoedaCor <> nMoedaPrv) .and. (nTaxaMoeda > 0)
				//Calcula o novo valor unitario
				aCols[nLin][nPVlrUnit] := Round(xMoeda(&(SubStr(cAlias,2,2)+"_PRV"+aCols[nLin][nPNumTab]),;
				                             nMoedaPrv,nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),TamSx3("L2_VRUNIT")[2])
			Else 
				aCols[nLin][nPVlrUnit] := &(SubStr(cAlias,2,2)+"_PRV"+aCols[nLin][nPNumTab])		
			EndIf
			M->L2_VRUNIT := aCols[nLin][nPVlrUnit]
		 
				
			//Acerta o preco de tabela, para a moeda corrente
			aCols[nLin][nPPrcTab] := aCols[nLin][nPVlrUnit]
			M->L2_PRCTAB := aCols[nLin][nPPrcTab]
				                                                 
			If nDesc > 0
				//Caso exista desconto dispara o gatilho para acertar os valores
				SX3->(dbSetOrder(2))
				SX3->(dbSeek("L2_DESC"))
				IF ExistTrigger("L2_DESC") 
					M->L2_DESC := nDesc
					RunTrigger(2,n)
				EndIf
			Else
				//Dispara o gatilho da quantidade para acertar o valor da mercadoria
				SX3->(dbSetOrder(2))
				SX3->(dbSeek("L2_QUANT")) 
				IF ExistTrigger("L2_QUANT") 
					M->L2_QUANT  := aCols[nLin][nPQuant]
					RunTrigger(2,n)
				EndIf
			EndIf
			
			//Dispara o gatilho do TES para recalcular os impostos	
			SX3->(dbSetOrder(2))
			SX3->(dbSeek("L2_TES"))
			IF ExistTrigger("L2_TES") 
				M->L2_TES := aCols[nLin][nPTes] 
				RunTrigger(2,n)
			EndIf
		EndIf	
	Next nLin

    Lj010Imps()    
        
	//Retorna para o indice e registro originais do SX3
	SX3->(dbSetOrder(nIndSX3))
	SX3->(dbGoTo(nRegSX3))
	
	//Retorna para o indice e registro originais do SB0
	dbSetOrder(nIndTab)
	dbGoTo(nRegTab)
	                  
	//Retorna para a area ativa antes da execucao do rdmake          
	RestArea(aAreaIni)                                    
	      
	//Atualiza a posicao do aCols
	n := nLinAux
			
	//Atualiza o Browse
	oGet:oBrowse:Refresh()
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010Imps ³ Autor ³ Fernando Machima      ³ Data ³ 24/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula impostos variaveis (Localizacoes)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := Lj010Imps()                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Venda Balcao                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj010Imps(cCliente,cLoja,nVlrTot,cNumOrc,aDadosCli)
Local aArea := GetArea()
Local nH := 0
Local nC := 0
Local cCpoTrigger := ""
Local cVarGet := ReadVar()
Local aColsProd := {}
Local nPosPrcTab := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_PRCTAB"})
Local nPosVrUnit := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_VRUNIT"})
Local nSaveN	:=	n
Local lRet      := .T.

DEFAULT cCliente  := GetMV("MV_CLIPAD")
DEFAULT cLoja     := GetMV("MV_LOJAPAD")
DEFAULT aDadosCli := {}

If Len(aDadosCli) == 0
   aDadosCli  := {cCliente,cLoja}
   lRet       := .F.
Else
   lRet  := aDadosCli[1]+aDadosCli[2] != cCliente+cLoja 
EndIf  

//Somente executa as rotinas abaixo caso o cliente tenha sido alterado
If lRet .And. AllTrim(cVarGet) == "CLOJA"                              
    aDadosCli[1]  := cCliente
    aDadosCli[2]  := cLoja   
	
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+cCliente+cLoja))
	lCredFisc  := SA1->A1_TIPO $ "1|4"	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Zerar elementos do aCols correspondente a Impostos e Bases, quando  ³
	//³ altera-se Codigo de Cliente e Loja.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nH := 1 to Len(aHeader)
		
		If Substr(aHeader[nH][2],1,9) == "L2_VALIMP"
			For nC := 1	to Len(aCols)
				aCols[nC][nH] := 0.00
			Next nC
		Endif
		
		If Substr(aHeader[nH][2],1,9) == "L2_BASIMP"
			For nC := 1	to Len(aCols)
				aCols[nC][nH] := 0.00
			Next nC
		Endif
		
		If Substr(aHeader[nH][2],1,9) == "L2_ALQIMP"
			For nC := 1	to Len(aCols)
				aCols[nC][nH] := 0.00
			Next nC
		Endif
	Next nH
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processar Gatilhos para atualizar Precos e elementos do aCols.      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nC := 1 To Len(aCols)
		If ! Empty(aCols[nC][1])
			n	:=	nC
			AADD(aColsProd,aCols[nC][1])
			For nH := 1 To Len(aHeader)
				M->&(aHeader[nH][2]) := aCols[nC][nH]
			Next nH
			If ExistTrigger("L2_PRODUTO")
				RunTrigger(2,nC,,,"L2_PRODUTO")
			EndIf
			For nH := 1 To Len(aHeader)
				M->&(aHeader[nH][2]) := aCols[nC][nH]
			Next nH
			If ExistTrigger("L2_QUANT")
				RunTrigger(2,nC,,,"L2_QUANT")
			EndIf
			If nPosPrcTab > 0 .and. nPosVrUnit > 0
				aCols[nC][nPosPrcTab] := aCols[nC][nPosVrUnit]
			EndIf	
		EndIf
	Next nC
		
	For nC := 1 To Len(aColsProd)
		aCols[nC][1] := aColsProd[nC]
	Next nC
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza Valor da entrada para recompor aReceb e aPgtos             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nEntrada := nVlrLiq
EndIf
RestArea(aArea)
n	:=	nSaveN
lDetalhe := .F.
//Forcar o recalculo dos impostos variaveis pela chamada da funcao Lj010Liq
Eval(oGet:oBrowse:bGotFocus)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Lj010AvCond³ Autor ³Lucas                ³ Data ³ 15/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retornar se a Condicao de Pagto e `a vista.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := Lj010AvCond(ExpC1)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpC1 := Condicao de Pago do arquivo SE4 (E4_COND)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 := Logico                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Venda Balcao                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ010AvCond(cCondPagto)
LOCAL nDias := 0

cCondPagto := StrTran(cCondPagto,",","")
nDias := Val(cCondPagto)

Return( If(nDias == 0,.T.,.F.) )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VeriOrc   ºAutor  ³Edilson Mendes      º Data ³  02/07/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Permite que seja acionada pela clausula VALID coontida no   º±±
±±º          ³campo L1_NUM da tabela SX3, impedindo que seja alterado o   º±±
±±º          ³numero do orcamento quando o paramentro MV_LJMOD3 estiver   º±±
±±º          ³acionado.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VeriOrc( cNumOrc )

LOCAL lRetValue := .T.
LOCAL aArea     := GetArea()

IF GetMV("MV_LJMOD3")
	
	If cOrcamen != cNumOrc
	   lRetValue := .F.
	EndIf
	
EndIf

RestArea( aArea )

RETURN( lRetValue )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj010VlCliºAutor  ³Andre Veiga         º Data ³  09/07/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a checagem dos valores default do cliente quando o      º±±
±±º          ³mesmo for alterado                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Loja010a                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj010VlCli( oCombo )
Local nPosCondPg := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se eh para respeitar a condicao default do cadastro do cliente  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cConfCli == "S"
	If ( nPosCondPg := ASCAN( oCombo:aItems, {|x| Substr(x,1,3) == SA1->A1_COND } ) ) > 0
		oCombo:nAt := nPosCondPg
	Endif
Endif

RETURN( Nil )           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj010VlVenºAutor  ³Marcos R. Andrade   º Data ³  03/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Traz o codigo do vendedor default do cadastro do cliente   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj010VlVen( cCliAtu, cLojAtu, cVendLojAnt, cCliFrete )
Local aSaveArea 	:= GetArea()			// Variavel utilizada para salvar o ambiente de trabalho.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se parametro MV_CONFCLI eh igual a "S". Se afirmativo,      ³
//³ traz o codigo do vendedor default do cadastro do cliente             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cConfCli == "S"
	
	SA1->( 	dbSetOrder( 1 ) )
	If SA1->( MsSeek( xFilial( "SA1" ) + cCliAtu + cLojAtu ) )
		If !Empty(SA1->A1_VEND)
			cVendLojAnt := SA1->A1_VEND
		Endif
	Endif
	
Endif                                                               

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o valor do campo cliente foi alterado. Se foi alterado então ³
//³zera as variaveis de memoria referente ao frete                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCliAtu <> cCliFrete  
    cCliFrete     := cCliAtu
    M->L1_TRANSP  := Space( TamSx3("L1_TRANSP") [1] )
    M->L1_ENDCOB  := Space( TamSx3("L1_ENDCOB") [1] )
    M->L1_BAIRROC := Space( TamSx3("L1_BAIRROC")[1] )
    M->L1_MUNC    := Space( TamSx3("L1_MUNC")   [1] )
    M->L1_CEPC    := Space( TamSx3("L1_CEPC")   [1] )
    M->L1_ESTC    := Space( TamSx3("L1_ESTC")   [1] )
    M->L1_ENDENT  := Space( TamSx3("L1_ENDENT") [1] )
    M->L1_BAIRROE := Space( TamSx3("L1_BAIRROE")[1] )
    M->L1_MUNE    := Space( TamSx3("L1_MUNE")   [1] )
    M->L1_CEPE    := Space( TamSx3("L1_CEPE")   [1] )
    M->L1_ESTE    := Space( TamSx3("L1_ESTE")   [1] )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a area de trabalho                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aSaveArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ010CondCliºAutor³Fernando Salvatori  º Data ³  30/09/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz a atualizacao da condicao de pagamento padrao do       º±±
±±º          ³ cliente                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParam.    ³ ExpC1,ExpC2 - Cliente e Loja anterior                      º±±
±±º          ³ ExpC3,ExpC4 - Cliente e Loja atual                         º±±
±±º          ³ ExpL5       - Var que controla o recalculo da condicao de  º±±
±±º          ³               pagamento para evitar calculos desnecessariosº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA010A - VALID do Codigo e Loja do Cliente               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Lj010CondCli( cCliAnt, cLojAnt, cCliAtu, cLojAtu, lAtuParc, oCombo, cCombo, aCondicoes )
Local cCond     := ""			//Condicao de pagamento
Local cComboTmp := ""			//Codigo da condicao + descricao da condicao
Local nPosCond  := {} 		    //Posicao da condicao na combo
Local cCondPad  := SuperGetMV("MV_CONDPAD") //Condicao de pgto Padrao
Default cCliAnt := ""		    //Cliente anterior
Default cLojAnt := ""			//Loja anterior

If cCliAnt + cLojAnt == cCliAtu + cLojAtu
	Return .T.
EndIf

dbSelectArea( "SA1" )
dbSetOrder( 1 )
dbSeek( xFilial( "SA1" ) + cCliAtu + cLojAtu )

lAtuParc := .T.  //Atualiza parcelas

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o cliente for o mesmo da condição, nao permito o recalculo³
//³das parcelas                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( Found() ) .And. ( oCombo <> Nil ) .And. ( cConfCli == "S" )

	cCliAnt := cCliAtu
	cLojAnt := cLojAtu
	
	cCond := SA1->A1_COND
	If Empty( cCond )
		cCond := cCondPad
	EndIf
	cComboTmp :=	cCond + " - " + Substr(Posicione("SE4",1,xFilial("SE4")+cCond,"SE4->E4_DESCRI"),1,12)
	IF ( nPosCond  := ASCAN( aCondicoes, cCond ) ) > 0
		cCombo     := cComboTmp
		oCombo:nAt := nPosCond
		oCombo:Refresh()
	ENDIF
Endif              

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AvalCred  ³ Autor ³ Edilson Mendes        ³ Data ³ 14/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Avalia o Credito do Cliente e Exibe o motivo do Bloqueio    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AvalCred                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION LJAvalCred( cCliente, cLoja, nVlrLiq, aReceb )
LOCAL aRetValue := { .T., "" }
LOCAL cCli      := IIF( GetMV("MV_LJMOD3"), M->L1_CLIENTE, cCliente )
Local cLoj      := IIF( GetMV("MV_LJMOD3"), M->L1_LOJA, cLoja )
Local cMsg      := ""
Local nSaldup   := 0
Local nPos
Local cCredLj   := GetMV( "MV_CREDLJ" )
Local lUsaAnCred := .T., nValorCrd := 0
Local cSimMoeda := GetMV("MV_SIMB1")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ignorar a analise de credito para cliente "padrao"       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCliente+cLoja == GetMV("MV_CLIPAD")+GetMV("MV_LOJAPAD") .Or. Upper(cCredLj) == "N" .Or. cPaisLoc == "PAR"
	Return aRetValue
EndIF

If LJProfile(1)
	
	If ExistBlock( "LJANCRED" )
		lUsaAnCred := ExecBlock( "LJANCRED" , .F. , .F. , {cCliente, cLoja, nVlrLiq, aReceb } )
	EndIf
	
	If lUsaAnCred
                
		nValorCrd := 0
		aEval(aPgtos, { |x| nValorCrd += iIf( At(AllTrim(x[03]), "CC;CD;" + cSimMoeda) == 0, x[02], 0 ) })	
	
		If nValorCrd > 0 .AND. ( aRetValue[1] := MaAvalCred( cCli, cLoj, nValorCrd, 1, .F., @aRetValue[2] ) )

			dbSelectArea("SA1")
			SA1->( DBSetOrder(1) )
			SA1->( DBSeek( xFilial("SA1") + cCli + cLoj ) )

			//-- Só bloqueia o cliente se o saldo de duplicatas + valores pagos for maior que o limite
			//-- se a soma dos pagamentos for maior que zero (alguma forma de pgto que necessite de 
			//-- crédito).
			If ( SA1->A1_SALDUP + nValorCrd ) > SA1->A1_LC .AND. SA1->A1_RISCO != "A"
				aRetValue[1] := .F.
				aRetValue[2] := "01"
			EndIf

		EndIf
	                   
		If !Empty( aRetValue[2] )
			If aRetValue[2] == "01"
				cMsg := OemToAnsi( STR0082 )  //"01-Sem Limite de Crédito"
			ElseIf aRetValue[2] == "04"
				cMsg := OemToAnsi( STR0083 ) // "04-Limite de Cr‚dito Vencido"
			Else
				cMsg := OemToAnsi( STR0084 ) // "99-Outros"
			EndIf
			MsgStop( cMsg )
		EndIf
	EndIf
EndIf

Return ( aRetValue )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LJNSO     ³ Autor ³ Cesar Eduardo Valadao ³ Data ³11/12/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializador padrao do campo L1_NSO                       ³±±
±±³          ³ Especificos para o Amazonas, por imposicao do SEFAZ-AM     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJNSO
Local cRet := "000001"+Right(cEstacao,2)
Local nOrder := SL1->(IndexOrd())
Local nRecno := SL1->(Recno())
SL1->(dbSetOrder(10))
SL1->(dbSeek(xFilial("SL1")+cEstacao+"zzzzzz", .T.))
SL1->(dbSkip(-1))
If SL1->L1_ESTACAO == cEstacao
	cRet := Soma1(Left(SL1->L1_NSO,6))+Right(cEstacao,2)
EndIf
SL1->(dbSetOrder(nOrder))
SL1->(dbGoTo(nRecno))
Return(cRet)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao para validação da ComboBox³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Lj010VldCombo(cCombo,cComboAnt2,oCombo,aCondicoes)
Local cMsg  := ""

//Faz a consistencia da troca
If lTroca .And. Posicione( "SE4",1,xFilial( "SE4" )+SubStr(cCombo,1,3),"SE4->E4_DESCFIN" ) > 0
	cMsg := STR0097+AllTrim(Str(SE4->E4_DESCFIN))+"%."+Chr(13)+Chr(10)// "A condição selecionada possui um percentual de desconto financeiro de "
	cMsg += STR0098//"Para utilizar um percentual de desconto na tela de Troca, favor selecionar o campo de Percentual de Desconto no Total."

	MsgStop( cMsg ,STR0099)//"Atenção"
	
	cCombo := cComboAnt2

	oCombo:nAt := 0
	oCombo:Refresh()
	Return .F.
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJContVend   ºAutor³Solange Zanardi     º Data ³ 10/09/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica a qtde de vendedores utilizados em um único       º±±
±±º          ³ orçamento, pois o sistema estruturalmente e restriro a     º±±
±±º          ³ cinco vendedores.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA010A - VALID do Codigo do Vendedor                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LJContVend()
Local aVendDig  := {}  // Array com os vendedores digitados
Local nItens    := 0
Local cVend     := space(06)
Local nPVend    := Ascan(aHeader,{|x|Trim(x[2])=="L2_VEND"})
Local lRet	    := .T.

For nItens := 1 To Len(aCols)
	cVend  := aCols[nItens][nPVend]
	cVend  := iif(empty(cVend),M->L2_VEND,cVend)
    if !empty(cVend) .and. ascan(aVendDig,cVend) == 0
        aadd(aVendDig,cVend)
    endif
Next nItens

if len(aVendDig) > 5
   lRet := .F.
   if ExistBlock("LJCONVEN")
      lRet := ExecBlock("LJCONVEN",.F.,.F.)
      if valtype(lRet) != "L"
         MsgAlert(STR0102) // "O retorno do ponto de entrada deveria ser do tipo lógico, corrija a função..."
         lRet := .F.   
      endif
   endif
endif   

if !lRet
   MsgStop(STR0101) // "Você já atingiu o limite de cinco vendedores por operação..."
endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj010Pesq ºAutor  ³Fernando Salvatori  º Data ³ 12/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que faz a pesquisa de um registro.                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Lj010Pesq()
              
AxPesqui()      

If SuperGetMV( "MV_FILTSL1" )
	nRecnoFilt := SL1->( Recno() )
	lPosFilt   := .T.
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj010VldCpo()³ Autor ³ Julio Cesar        ³ Data ³ 02/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion que verifica cual es el get activo e vuelve la     ³±±
±±³          ³ validacion de lo mismo, para que sea ejecutada antes de la ³±±
±±³          ³ grabacion de los datos.                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010VldCpo()

Local cReadVar := AllTrim(Upper(ReadVar()))
Local nI       := 0
Local bValid   := {|| }

If !Empty(cReadVar)
	For nI := 1 To Len(oDlgLoja:aControls)
		If AllTrim(Upper(oDlgLoja:aControls[nI]:cReadVar))$cReadVar
			bValid := oDlgLoja:aControls[nI]:bValid
			Exit
		EndIf 
	Next nI
EndIf

Return(bValid)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj010PrCC ºAutora ³Solange Zanardi     º Data ³  02/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para impressão do item quando utilizada a Vda Conco- º±±
±±º          ³mitante MV_LJVBCC                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA - Venda Balcão Concomitante e GATILHO L2_PRODUTO   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010PrCC(cRet,cOrigem,nCont)
Local aArea			:= GetArea()
Local nIndSB0		:= 0
Local nIndSB1		:= 0
Local nIndSF4		:= 0
Local nIndSL1		:= 0
Local nIndSA1		:= 0
Local nRegSB0		:= 0
Local nRegSB1		:= 0
Local nRegSF4		:= 0
Local nRegSL1		:= 0
Local nRegSA1		:= 0
Local lImpOk		:= .F.
Local lRet			:= .F.
Local nPosProd  	:= aPosicoes[ 9][2]
Local nPosDescri  	:= aPosicoes[17][2]
Local nPosQuant 	:= aPosicoes[11][2]
Local nPosValIpi	:= aPosicoes[ 7][2]
Local nPosUnit  	:= aPosicoes[ 1][2]
Local nPosDesU  	:= aPosicoes[ 3][2]
Local nPosDesc  	:= aPosicoes[ 4][2]
Local nPosValIcm	:= aPosicoes[ 6][2]
Local nPosTes		:= aPosicoes[ 5][2]
Local nPosValIss	:= aPosicoes[ 8][2]
Local nPosTotIt 	:= aPosicoes[ 2][2]
Local cCodProd  	:= ""
Local cDescProd 	:= ""
Local cQuant		:= ""
Local cUnit	  		:= ""
Local cTotIt		:= "" 	
Local cDesconto 	:= ""
Local cElemen		:= ""
Local nPerRet		:= 0
Local lLj220Reg		:= ExistBlock("LJ220REG")
Local iRetorno  	:= 0
Local cRetorno		:= " "
Local nDesconto		:= 0
Local lRetEval		:= .T.
Local lRetDesc		:= .T.
Local lRetDescV		:= .T.
Local lEstPosit		:= .T.
Local nPosValDesc	:= aScan( aHeader, {|x| Alltrim(Upper(x[2])) == "L2_VALDESC" } )
Local nPosPerDesc	:= aScan( aHeader, {|x| Alltrim(Upper(x[2])) == "L2_DESC" } )
Local lValorOk		:= .T.
Local lLjRgItCC		:= ExistBlock("LJRGITCC")
Local aRetItem		:= {}
Local cUnidMed      := " "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Esta função é chamada através de gatilho e internamente             ³
//³na Finalização da Venda Balcão, portanto para controle interno      ³
//³do sistema mando o código do produto a ser impresso se não conseguir³
//³retorno tanto para o gatilho qto para a função o código em branco   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default cRet 		:= &(ReadVar())
Default cOrigem		:= "G"				//G(atilho) F(inalizacao)    
Default nCont		:= N

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetuar as validações do produto padrao antes da impressao           |
//| esta função chama o RDMake a ser utilizado para validções do cliente |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("lVendConc") == "L" .And. lVendConc
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controle de erros na impressao do cupom fiscal                      |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lImpOk		:= .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Utilizei o laço para ficar mais legível                             |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do While .T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida o Estoque do item                                            |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCols[nCont][nPosUnit] <= 0
			MsgAlert(STR0111) //"Produto sem preço de venda, não poderá ser registrado!"
			lValorOk := .F.
		    Exit
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validar o item e chamada para o ponto de entrada do cliente         |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRetEval := Lj010Evali()
		If !lRetEval
		    Exit
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida o Estoque do item                                            |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Lj010Estoq("P",@lEstPosit,.F.)
		If !lEstPosit
		    Exit
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Recalcular valores apos selecionar o item pois a qtde vem antes     |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nDesconto := lj010Quan()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se foi dado desconto e roda os gatilhos para recalculo da  |
		//³ linha                                                               |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		M->L2_PRODUTO 		:= cRet
		aCols[nCont][nPosProd] 	:= cRet
		If aCols[nCont][nPosPerDesc] > 0
			SX3->(dbSetOrder(2))
			SX3->(dbSeek(PadR("L2_DESC",10)))
			IF ExistTrigger(PadR("L2_DESC",10))
				M->L2_DESC := aCols[nCont][nPosPerDesc]
				RunTrigger(2,nCont)
			EndIf
		ElseIf aCols[nCont][nPosValDesc] > 0
			SX3->(dbSetOrder(2))
			SX3->(dbSeek(PadR("L2_VALDESC",10)))
			IF ExistTrigger(PadR("L2_VALDESC",10))
				M->L2_VALDESC := aCols[nCont][nPosValDesc]
				RunTrigger(2,nCont)
			EndIf
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se for o primeiro item a ser impresso efetuar as validações do ECF  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nItensImp == 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a data do sistema eh a mesma data da impressora fiscal. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !CheckIFData()
				Exit
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se exitir cupom aberto, faz o cancelamento e abre um novo.          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			iRet := IFStatus( nHdlECF, '5', @cRetorno )
			if iRet = 7
				iRet := IFCancCup( nHdlECF )
				If L010AskImp(.F.,iRet)
					Exit
				EndIf
				Inkey(8)   // dá um tempo para a impressora fazer a impressao do cancelamento
			Else
				If L010AskImp(.F.,iRet)
					Exit
				EndIf
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Abre o cupom fiscal                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			iRetorno := IFAbreCup(nHdlECF)
			If L010AskImp(.F.,iRetorno)
				Exit
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tenta pegar o n£mero do cupom       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cNumCupFis 	:= Space(6)
			iRetorno 	:= IFPegCupom( nHdlECF, @cNumCupFis)
			If L010AskImp(.F.,iRetorno)
				Exit
			EndIf
			cNumCupFis 	:= StrZero(Val(cNumCupFis),TamSx3("L1_NUMCFIS")[1],0)
			cNumNota 	:= cNumCupFis
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tenta pegar o n£mero do PDV         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cNumPdv  := Space(6)
			iRetorno := IFPegPDV(nHdlECF, @cNumPdv)
			If L010AskImp(.F.,iRetorno)
				Exit
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Para utilizar o conceito de cliente entrega  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SL1->(FieldPos( "L1_CLIENT" )) > 0 .And. SL1->(FieldPos( "L1_LOJENT" )) > 0
				If !Empty( SL1->L1_CLIENT) .And. !Empty( SL1->L1_LOJENT )
					DbSelectArea("SA1")
					nIndSA1:=IndexOrd()
					nRegSA1:=Recno()
					DbSetOrder(1)
					SA1->(MsSeek( xFilial( "SA1" ) + SL1->L1_CLIENT + SL1->L1_LOJENT) )
				EndIf
			EndIf
		EndIf
		
		DbSelectArea("SB1")
		nIndSB1:=IndexOrd()
		nRegSB1:=Recno()
		DbSetOrder(1)
		SB1->( MsSeek( xFilial("SB1") + aCols[nCont][nPosProd]) )
			
		DbSelectArea("SB0")
		nIndSB0:=IndexOrd()
		nRegSB0:=Recno()
		DbSetOrder(1)
		SB0->( MsSeek( xFilial("SB0") + aCols[nCont][nPosProd]) )
		
		DbSelectArea("SF4")
		nIndSF4:=IndexOrd()
		nRegSF4:=Recno()
		DbSetOrder(1)
		
		SF4->( MsSeek( xFilial("SF4") + aCols[nCont][nPosTes] ) )
		
		If lLj220Reg
			cElemen := ExecBlock("LJ220REG",.F.,.F.)
			
		ElseIf SF4->F4_ISS == "S" .AND. ( ( ( SA1->A1_RECISS == "1" .AND. GetNewPar("MV_DESCISS", .F.) ) .OR. ( SA1->A1_RECISS <> "1" ) ) )
			cElemen := 'S' + AllTrim (Str( Iif(SB1->B1_ALIQISS>0,SB1->B1_ALIQISS,GetMv("MV_ALIQISS")),5,2 ))
			
		ElseIf SB1->B1_PICMRET > 0 .And. SA1->A1_TIPO $ GetNewPar("MV_TPSOLCF","S,F")
			cElemen := "F"                   								//Substituicao tributaria (Icms Solidario)
			
		ElseIf SF4->F4_BASEICM > 0 .And. SF4->F4_BASEICM < 100
			cElemen := 'T' + Alltrim(Str( SB0->B0_ALIQRED,5,2 ))		  	//Com reducao de Icms na Base
			
		ElseIf SF4->F4_LFICM == "I"
			cElemen := "I"                   								//Isento
			
		ElseIf SF4->F4_LFICM == "N"
			cElemen := "N"                   								//N„o sujeito a ICMS
			
		Else
			nPerRet := lj010VerIcm(nCont)     								//Com ICMS
			cElemen	:= 'T' + Alltrim(Str(nPerRet,5,2))
		EndIf
		
		If GetMV("MV_CODBAR") == "S"  .And. !Empty(SB1->B1_CODBAR)
			cCodProd  := Substr(SB1->B1_CODBAR,1,13)
		Else
			cCodProd  := aCols[nCont][nPosProd]
		EndIF
		
		cQuant    := StrZero(aCols[nCont][nPosQuant],TamSX3("L2_QUANT")[1],TamSX3("L2_QUANT")[2])
		cUnit     := Str((aCols[nCont][nPosTotIt]+ aCols[nCont][nPosDesU]+aCols[nCont][nPosValIpi])/aCols[nCont][nPosQuant],TamSx3("L2_VRUNIT")[1],nDecimais)
		cTotIt    := Str((aCols[nCont][nPosTotIt]+ aCols[nCont][nPosDesU]+aCols[nCont][nPosValIpi]),TamSx3("L2_VLRITEM")[1],nDecimais)
		
		cDescProd := Posicione("SB1",1,	xFilial("SB1")+PadR(cCodProd,TamSx3("B1_COD")[1]),"SB1->B1_DESC")
		cUnidMed  := Posicione("SB1",1,	xFilial("SB1")+PadR(cCodProd,TamSx3("B1_COD")[1]),"SB1->B1_UM")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Segundo a legislacao o cliente quando estiver configurado como solidario³
		//³A1_TIPO = 'S' deverá sempre ser tributado, independente da configuracao ³
		//³do TES.                                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (SA1->A1_TIPO $ GetNewPar("MV_TPSOLCF","S,F") .Or. ( SA1->A1_TIPO == "S" )) .And. (SF4->F4_INCSOL != "N")
			aIcmsSol := LjIcmsSol(Val(cUnit)*aCols[nCont][nPosQuant],aCols[nCont][nPosQuant],Val(cUnit))
			cUnit    := Str(Val(cUnit) + (aIcmsSol[2]/Val(cQuant)),TamSx3("L2_VRUNIT")[1],TamSx3("L2_VRUNIT")[2])
			cTotIt   := Str(Val(cUnit) * Val(cQuant),TamSx3("L2_VLRITEM")[1],nDecimais)
		EndIf
		
		cDesconto := Str(aCols[nCont][nPosDesU],8,2)
		
		If lLjRgItCC
			aRetItem := ExecBlock("LJRGITCC",.F.,.F.,{cCodProd,cDescProd,cQuant,cUnit,cDesconto,cElemen,cTotIt})
			If ValType(aRetItem) == "A" .And. Len(aRetItem) >= 7
				cCodProd 	:= aRetItem[1]
				cDescProd	:= aRetItem[2]
				cQuant		:= aRetItem[3]
				cUnit		:= aRetItem[4]
				cDesconto	:= aRetItem[5]
				cElemen		:= aRetItem[6]
				cTotIt		:= aRetItem[7]
			Endif
		Endif
		
		iRetorno  := IFRegItem(nHdlECF,cCodProd,cDescProd,cQuant,cUnit,cDesconto,cElemen,cTotIt,cUnidMed)
		If L010AskImp(.F.,iRetorno)
			Exit
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄt¿
		//³Identifico que um item foi impresso para não ter que fazer todas as verificações da impressora novamente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄtÙ
		nItensImp++
		lImpOk := .T.
		Exit
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se não passou pelas validações necessárias para impressão³
	//³Limpo o item impedindo seu bloqueio ou impressão         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lRetEval .Or. !lEstPosit .Or. !lValorOk
		
		cRet 				:= Space(TamSx3("B1_COD")[1])
		M->L2_PRODUTO 		:= Space(TamSx3("B1_COD")[1])
		aCols[nCont][nPosProd]	:= Space(TamSx3("B1_COD")[1])
		M->L2_DESCRI 		:= Space(TamSx3("L2_DESCRI")[1])
		aCols[nCont][nPosDescri]:= Space(TamSx3("L2_DESCRI")[1])
		
		aCols[nCont][Len(aHeader)+1] := .T.
		Lj010Del()
		
	ElseIf !lImpOk
		
		cRet 				:= Space(TamSx3("B1_COD")[1])
		M->L2_PRODUTO 		:= Space(TamSx3("B1_COD")[1])
		aCols[nCont][nPosProd]	:= Space(TamSx3("B1_COD")[1])
		M->L2_DESCRI 		:= Space(TamSx3("L2_DESCRI")[1])
		aCols[nCont][nPosDescri]:= Space(TamSx3("L2_DESCRI")[1])
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a função foi chamada pela rotina de Finalizacao da Venda o sistema deverá tratar os retornos e perguntar se deseja   ³
		//³Cancelar o Cupom e Excluir o item, verificar os retornos para devidos tratamentos de retorno para MBrowse ou permanencia³
		//³na tela de vendas                                                                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cOrigem == "F"
			//"Atenção" - "Não foi possível registrar o item " ... " devido a problemas no ECF. Você deseja Cancelar o Cupom ou Excluir o Item ?" "Cancelar" "Excluir"
			If (2 == Aviso(STR0099,STR0112+Alltrim(Upper(cDescProd))+STR0113,{STR0114,STR0115} )) 
				aCols[nCont][Len(aHeader)+1] := .T.
				Lj010Del()
				cRet := PadR("@BOTEXC@",Space(TamSx3("B1_COD")[1]))
			Else
				iRet := IFCancCup( nHdlECF )
				If L010AskImp(.F.,iRet)
					MsgSTop(STR0116,STR0099) //"Não foi possível cancelar o Cupom Fiscal. Verifique possíveis problemas na Impressora." "Atenção"
				EndIf
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Foi chamado através do Gatilho, neste caso devo excluir o item e permanecer na Tela de Vendas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//"Não foi possível registrar o item "...+" devido a problemas no ECF. Este produto será excluído!!"
			MsgStop(STR0112+Alltrim(Upper(cDescProd))+STR0117)
			aCols[nCont][Len(aHeader)+1] := .T.
			Lj010Del()
		EndIf
	EndIf

EndIf

//Retornando as posições originais do arquivo
DbSelectArea("SA1")
If nIndSA1 > 0
	DbSetOrder(nIndSA1)
EndIf	
If nRegSA1 > 0
	GoTo(nRegSA1)
EndIF

DbSelectArea("SB1")
If nIndSB1 > 0
	DbSetOrder(nIndSB1)
EndIf	
If nRegSB1 > 0
	GoTo(nRegSB1)
EndIF

DbSelectArea("SB0")
If nIndSB0 > 0
	DbSetOrder(nIndSB0)
EndIf	
If nRegSB0 > 0
	GoTo(nRegSB0)
EndIF

DbSelectArea("SF4")
If nIndSF4 > 0
	DbSetOrder(nIndSF4)
EndIf	
If nRegSF4 > 0
	GoTo(nRegSF4)
EndIF

//Retornando à área original do arquivo
If Len(aArea)>0
	RestArea(aArea)
EndIf

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj010Canc ºAutora ³Solange Zanardi     º Data ³  02/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existe cupom fiscal aberto antes de iniciar a   º±±
±±º          ³operação de venda                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA - Venda Balcão Concomitante                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Canc(lPergunt)
Local lRet		 := .F.
Local lCancelou	 := .F.
Local cRetorno	 := " "
Local lCancela	 := .T.

Default	lPergunt := .F.

iRet := IFStatus( nHdlECF, '5', @cRetorno )
If iRet = 7
	If !lPergunt      	//Cancelo sem efetuar a pergunta
		//"Problemas com o ECF" - "Existe um Cupom Fiscal em aberto e será cancelado!" - "OK"
		Aviso(STR0118,STR0119,{STR0120})
	    lCancela := .T.
	Else				//Pergunto antes de cancelar
        //"Problemas com o ECF" - "Existe um Cupom Fiscal em aberto, deseja efetuar o cancelamento e abandonar a venda?" - "Sim" "Não"
		If 1 == Aviso(STR0118,STR0121,{STR0122,STR0123})
 		   lCancela := .T.
		Else 
 		   lCancela := .F.
		EndIf
	EndIf
	If lCancela
		iRet := IFCancCup( nHdlECF )
		If L010AskImp(.F.,iRet)
			lCancelou:=.F.
		Else
			lCancelou:=.T.
		EndIf
		Inkey(8)  									//Dá um tempo para a impressora fazer a impressao do cancelamento
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Todos os cancelamentos de cupom irão chamar esta função, portanto abrimos um PE para gravação de logs³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("L010CAN")
	ExecBlock("L010CAN",.F.,.F.,{lCancelou})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se foi efetuada a pergunta para o usuário devo tratar se a resposta foi sim ou nao para o programa que chamou³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPergunt
   lRet := lCancela
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj010CanITºAutora ³Solange Zanardi     º Data ³  04/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Possibilita o cancelamento do item ao pressionar a tecla    º±±
±±º          ³delete sobre o item do aCols                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA - Venda Balcão Concomitante                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010CanIT()
Local lRet 			:= .F.
Local aArea			:= GetArea()
Local nIndSB0		:= 0
Local nIndSB1		:= 0
Local nIndSF4		:= 0
Local nIndSL1		:= 0
Local nIndSA1		:= 0
Local nRegSB0		:= 0
Local nRegSB1		:= 0
Local nRegSF4		:= 0
Local nRegSL1		:= 0
Local nRegSA1		:= 0
Local cSup 			:= Space(15)
Local cQualItem 	:= ""
Local nCancItem		:= 0
Local nPosProd  	:= aPosicoes[ 9][2]
Local nPosQuant 	:= aPosicoes[11][2]
Local nPosDesU  	:= aPosicoes[ 3][2]
Local nPosTes		:= aPosicoes[ 5][2]
Local nPosTotIt 	:= aPosicoes[ 2][2]
Local nPosValIpi	:= aPosicoes[ 7][2]
Local cCodProd  	:= ""
Local cDescProd 	:= ""
Local cQuant		:= ""
Local cUnit	  		:= ""
Local cTotIt		:= "" 	
Local cDesconto 	:= ""
Local cElemen		:= ""
Local nPerRet		:= 0
Local lLj220Reg		:= ExistBlock("LJ220REG")
Local iRetorno  	:= 0
Local cRet			:= " "
Local nFor			:= 1
Local aSeqImp		:= {}            			
Local nItemCanc		:= 0
Local Z                    
Local nItemImpr		:= 0

If LJProfile(7, @cSup)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravando os dados impressos e não impressos no ECF para controle do item do Cancelamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nFor:=1 To Len(aCols)
		If !Empty(aCols[nFor][nPosProd])
			nItemImpr++
			Aadd(aSeqImp,{nFor,nItemImpr})
		Else
			Aadd(aSeqImp,{nFor,0})
		EndIf
	Next nFor
	
	nItemCanc := Ascan( aSeqImp, { |Z| Z[1] == N } )
	If aSeqImp[nItemCanc][2] == 0
		MsgAlert(STR0124) //"Este item não foi impresso para ser cancelado!"
		lRet := .T.
	Else
		nCancItem := aSeqImp[nItemCanc][2]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se é possivel cancelar todos ou só o ultimo item         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		iRetorno 	:= IfStatus(nHdlECF, "4", @cQualItem)
		If Upper(AllTrim(cQualItem))<>"TODOS"			//Posso cancelar qualquer item da impressora
			If nCancItem < Len(aSeqItem)
				MsgAlert(STR0125) //"Esta impressora só permite o cancelamento do último item, para cancelar o cupom fiscal, Cancele ou Salve o orçamento."
			EndIf
		EndIF
		
		iRetorno := IFStatus(nHdlECF, "9", @cRet) 		//Verifico o Status do ECF
		
		If iRetorno != 0
			lRet := .F.
		Else
			
			DbSelectArea("SB1")
			nIndSB1:=IndexOrd()
			nRegSB1:=Recno()
			DbSetOrder(1)
			SB1->( MsSeek( xFilial("SB1") + aCols[n][nPosProd]) )
			
			DbSelectArea("SB0")
			nIndSB0:=IndexOrd()
			nRegSB0:=Recno()
			DbSetOrder(1)
			SB0->( MsSeek( xFilial("SB0") + aCols[n][nPosProd]) )
			
			DbSelectArea("SF4")
			nIndSF4:=IndexOrd()
			nRegSF4:=Recno()
			DbSetOrder(1)
			SF4->( MsSeek( xFilial("SF4") + aCols[n][nPosTes] ) )
			
			If lLj220Reg
				cElemen := ExecBlock("LJ220REG",.F.,.F.)
				
			ElseIf SF4->F4_ISS == "S" .AND. ( ( ( SA1->A1_RECISS == "1" .AND. GetNewPar("MV_DESCISS", .F.) ) .OR. ( SA1->A1_RECISS <> "1" ) ) )
				cElemen := 'S' + AllTrim (Str( Iif(SB1->B1_ALIQISS>0,SB1->B1_ALIQISS,GetMv("MV_ALIQISS")),5,2 ))
				
			ElseIf SB1->B1_PICMRET > 0 .And. SA1->A1_TIPO $ GetNewPar("MV_TPSOLCF","S,F")
				cElemen := "F"                   							// Substituicao tributaria (Icms Solidario)
				
			ElseIf SF4->F4_BASEICM > 0 .And. SF4->F4_BASEICM < 100
				cElemen := 'T' + Alltrim(Str( SB0->B0_ALIQRED,5,2 ))		// com reducao de Icms na Base
				
			ElseIf SF4->F4_LFICM == "I"
				cElemen := "I"                   							// Isento
				
			ElseIf SF4->F4_LFICM == "N"
				cElemen := "N"                   							// N„o sujeito a ICMS
				
			Else
				nPerRet := lj010VerIcm(n) 	     							// Com ICMS
				cElemen	:= 'T' + Alltrim(Str(nPerRet,5,2))
			EndIf
			
			If GetMV("MV_CODBAR") == "S"  .And. !Empty(SB1->B1_CODBAR)
				cCodProd  := Substr(SB1->B1_CODBAR,1,13)
			Else
				cCodProd  := aCols[n][nPosProd]
			EndIF
			
			cDescProd := SB1->B1_DESC
			
			cQuant    := StrZero(aCols[n][nPosQuant],TamSX3("L2_QUANT")[1],TamSX3("L2_QUANT")[2])
			cUnit     := Str((aCols[n][nPosTotIt]+ aCols[n][nPosDesU]+aCols[n][nPosValIpi])/aCols[n][nPosQuant],TamSx3("L2_VRUNIT")[1],nDecimais)
			cTotIt    := Str((aCols[n][nPosTotIt]+ aCols[n][nPosDesU]+aCols[n][nPosValIpi]),TamSx3("L2_VLRITEM")[1],nDecimais)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Segundo a legislacao o cliente quando estiver configurado como solidario³
			//³A1_TIPO = 'S' deverá sempre ser tributado, independente da configuracao ³
			//³do TES.                                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (SA1->A1_TIPO $ GetNewPar("MV_TPSOLCF","S,F") .Or. ( SA1->A1_TIPO == "S" )) .And. (SF4->F4_INCSOL != "N")
				aIcmsSol := LjIcmsSol(Val(cUnit)*aCols[n][nPosQuant],aCols[n][nPosQuant],Val(cUnit))
				cUnit    := Str(Val(cUnit) + (aIcmsSol[2]/Val(cQuant)),TamSx3("L2_VRUNIT")[1],TamSx3("L2_VRUNIT")[2])
				cTotIt   := Str(Val(cUnit) * Val(cQuant),TamSx3("L2_VLRITEM")[1],nDecimais)
			EndIf
			
			cDesconto := Str(aCols[n][nPosDesU],8,2)
			
			iRetorno := IFCancItem(nHdlECF,Str(nCancItem,3),cCodProd,cDescProd,cQuant,cUnit,cDesconto,cElemen)
			If iRetorno == 0
				lRet := .T.
			Else
				lRet	:= .F.
			EndIf
			
			//Retornando as posições originais do arquivo
			DbSelectArea("SA1")
			If nIndSA1 > 0
				DbSetOrder(nIndSA1)
			EndIf
			If nRegSA1 > 0
				GoTo(nRegSA1)
			EndIF
			
			DbSelectArea("SB1")
			If nIndSB1 > 0
				DbSetOrder(nIndSB1)
			EndIf
			If nRegSB1 > 0
				GoTo(nRegSB1)
			EndIF
			
			DbSelectArea("SB0")
			If nIndSB0 > 0
				DbSetOrder(nIndSB0)
			EndIf
			If nRegSB0 > 0
				GoTo(nRegSB0)
			EndIF
			
			DbSelectArea("SF4")
			If nIndSF4 > 0
				DbSetOrder(nIndSF4)
			EndIf
			If nRegSF4 > 0
				GoTo(nRegSF4)
			EndIF
			
			//Retornando à área original do arquivo
			If Len(aArea)>0
				RestArea(aArea)
			EndIf
		EndIf
	EndIf
Else
	lRet:=.F.
	MsgAlert(STR0126) //"Usuário sem permissão para efetuar cancelamentos. Contate seu superior."
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj010GatVDºAutora ³Solange Zanardi     º Data ³  04/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tratamento para o valor do desconto na Venda Concomitante   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA - Venda Balcão Concomitante e GATILHO L2_PRODUTO   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010GatVD()
Local nPVlrUnit := Ascan(aHeader,{|x|Trim(x[2])=="L2_VRUNIT"})
Local nPVlrDesc := Ascan(aHeader,{|x|Trim(x[2])=="L2_VALDESC"})
Local nPosProd  := Ascan(aHeader,{|x|Trim(x[2])=="L2_PRODUTO"})
Local nValDesc	:= If( "L2_VALDESC"$ReadVar(),&(ReadVar()),aCols[n][nPVlrDesc] )

If Type("lVendConc") == "L" .And. lVendConc
	nValDesc := aCols[n][nPVlrDesc]
Else
	nValDesc :=	Iif(aCols[n][nPVlrUnit] == 0, 0, aCols[n][nPVlrDesc] )
EndIf
Return(nValDesc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj010GatPDºAutora ³Solange Zanardi     º Data ³  04/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tratamento do percentual do desconto na Venda Concomitante  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA - Venda Balcão Concomitante e GATILHO L2_PRODUTO   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010GatPD()
Local nPVlrUnit := Ascan(aHeader,{|x|Trim(x[2])=="L2_VRUNIT"})
Local nPVlrDesc := Ascan(aHeader,{|x|Trim(x[2])=="L2_VALDESC"})
Local nPQuant	:= Ascan(aHeader,{|x|Trim(x[2])=="L2_QUANT"})
Local nPPerDesc	:= Ascan(aHeader,{|x|Trim(x[2])=="L2_DESC"})
Local nPosProd	:= Ascan(aHeader,{|x|Trim(x[2])=="L2_PRODUTO"})
Local nPerDesc	:= If("L2_DESC"$Upper(ReadVar()),&(ReadVar()),aCols[n][nPPerDesc])
         
If Type("lVendConc") == "L" .And. lVendConc
	nPerDesc := aCols[n][nPPerDesc]
Else
	nPerDesc :=	Iif(aCols[n][nPVlrUnit] == 0 , 0 , NoRound((aCols[n][nPVlrDesc]*100)/(aCols[n][nPQuant]*aCols[n][nPVlrUnit]),2))
EndIf
Return(nPerDesc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj010MsnVdºAutora ³Solange Zanardi     º Data ³  04/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Mensagem para o operador qdo tenta alterar um item impresso º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA - Venda Balcão Valid SX3                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010MsnVd()
Local lRet := .T.
If !Empty(aCols[n][aPosicoes[ 9][2]])
	MsgAlert(STR0127) //"O item não pode ser alterado pois já foi registrado no Cupom Fiscal. Se necessário deve excluí-lo!"
	lRet := .F.	
EndIf	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³L010VldResºAutor  ³Andre Veiga         º Data ³  20/12/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se existe reserva para o item. Caso afirmativo nao   º±±
±±º          ³permite alterar nenhum campo                                º±±
±±º          ³Esta funcao esta sendo chamada do valid do campo na monta-  º±±
±±º          ³gem do aCols.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºOrigem    ³BOPS 90569                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Venda Balcao (LOJA010)                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function L010VldRes
Local lRet 			:= .T. 
Local nPosReserva 	:= aScan(aHeader,{|z| Alltrim(Upper(z[2]))=="L2_RESERVA" })
                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe reserva. Se existir nao permite alterar nenhum    ³
//³ campo.                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( aCols[ n ][ nPosReserva ] )
	MsgStop( STR0129 ) // "Não é possível alterar nenhuma informação do produto depois de efetuada a reserva."
	lRet := .F.	
Endif

Return lRet 
