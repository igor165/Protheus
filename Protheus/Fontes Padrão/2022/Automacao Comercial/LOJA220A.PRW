#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA220A.CH"

#DEFINE _PICTURE	13
#DEFINE _FORMATEF	"CC;CD"     //Formas de pagamento que utilizam operação TEF para validação

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o   ³ LojA220	³ Autor ³ Vendas Clientes       ³ Data ³ 12/1997  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o³ Vendas - Venda Super R pida.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ Loja220()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja Windows                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Loja220()
Local aArea			:= GetArea() // Grava Area Atual
Local lLjECF00		:= ExistBlock("LJECF00")
Local lRet			:= .T.
Local nMoedaCor		:= 1
Local cLock 		:= cUserName+cEstacao
Local aCores		:= {{"!Empty(L1_DOC) .AND. L1_STATUS='T'",		"BR_BRANCO"},;
						{"!Empty(L1_DOC)",							"BR_VERMELHO"},;
						{"Empty(L1_DOC) .AND. dDataBase<=L1_DTLIM",	"BR_VERDE"},;
						{"Empty(L1_DOC) .AND. dDataBase>L1_DTLIM",	"BR_PRETO"}}
Local lIsMDI 		:= Iif(ExistFunc("LjIsMDI"),LjIsMDI(),SetMDIChild(0)) //Verifica se acessou via SIGAMDI

// Protege rotina para que seja usada apenas no SIGALOJA / Front Loja
If !AmIIn(12,23,72)
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o controle via LockByName para evitar que um usuário acesse       ³
//³ 2 vezes uma rotina que use os periféricos de automação, evitando assim³
//³ a concorrência dos mesmos.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIsMDI .AND. !LockByName( cLock )
	Return NIL
Endif

Private dDataCN     := dDataBase
Private aPgtos 		:= {}
Private cConfCli	:= SuperGetMv("MV_CONFCLI")
Private aIcms		:= {}
Private lTroca 		:= .F.
Private lTefOk 		:= .F.
Private nacRetIcms  := 0  								// Variavel Para Acumulo de Icms Retido
Private cNivelSup	:= cNivel
Private aTefDados 	:= {} 	  							// TEF
Private cNumCupFis 	:= Space(TamSx3("L1_DOC")[1])
Private nTxJuros 	:= 0
Private _TAMCPROD	:= Max(TamSx3("B1_COD")[1],TamSx3("B1_CODBAR")[1])			// Considera-la como um DEFINE
Private oPgtos, oBtnOk, oBtnCan, oBtnVen, oBtnCli, oBar
Private lVlrFSD		:= .T.	  // Indica se o valor do frete sera lancado no total da venda (Por default sempre serah)
Private nVlrFSD		:= 0
Private nVlrTxDesc 	:= 0
Private npValISS    := 0

/*
Utilizacao do "Pergunte" e criacao das variaveis private(cArquivo, cLote), com a finalidade de serem utilizadas nas
funcoes do financeiro ( Movimento Bancario-Transferencias).
*/
Pergunte("AFI100",.F.)
Private cArquivo := Space(01)
Private cLote    := Space(01)

//HOMOLOGACAO: Criar a array aReceb utiliza por toda a rotina TEF
Private aReceb 	:= {{Ctod("  /  /  "),0,Space(15),CriaVar("L4_ADMINIS"),CriaVar("L4_NUMCART"),;
CriaVar("L4_AGENCIA"),CriaVar("L4_CONTA"),CriaVar("L4_RG"),CriaVar("L4_TELEFON"),.F.,nMoedaCor,;
CriaVar("L4_MESACTA"),CriaVar("L4_ANOACTA"),CriaVar("L4_TIPOCHQ"),CriaVar("L4_CGC"),CriaVar("L4_NOMECLI"),;
CriaVar("L4_SERCHQ"),CriaVar("L4_COMP")}}

Private cRegISS	   := "N"       // controla se ocorreu registro de itens de serviço - "N" nenhum item,
								// "S" - so itens de servico, "T" - um ou mais itens de ICMS

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  ****** Descric„o do ARRAY aRECEB	 *******   ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Dimensoes  ³ Descric„o						   ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
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
//³      12   ³ Mes abertura da Conta              ³
//³      13   ³ Ano abertura da Conta              ³
//³      14   ³ Tipo de Cheque (Fis/Jur)           ³
//³      15   ³ CGC/CPF                            ³
//³      16   ³ Nome do Cliente                    ³
//³      17   ³ Série do Cheque                    ³
//³      18   ³ Compensacao do Cheque              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA"
	/////////////////////////////////////////////////////////////////////////////////
	//O array aDadosJur armazena os resultados do calculo dos juros, sendo que o   //
	//mesmo eh valorizado na funcao Lj010RecVB, que se encontra no Loja010c.prw    //
	//Descricao do Array                                                           //
	//aDadosJur[1] => Total do acrescimo                                           //
	//aDadosJur[2] => Valor Liquido da Venda                                       //
	//aDadosJur[3] => Valor Base da Venda                                          //
	//aDadosJur[4] => Valor total dos impostos                                     //
	//aDadosJur[5] => Total de desconto                                            //
	//aDadosJur[6] => Valor anterior do imposto                                    //
	//aDadosJur[7] => Taxa de juros			                                       //
	//aDadosJur[8] => Percentual de desconto                                       //
	/////////////////////////////////////////////////////////////////////////////////
	Private aDadosJur := {0,0,0,0,0,0,0,0,0}
	Private cTipo        := "N"
	PRIVATE lLancPad10 := lLancPad20 := .F.
	PRIVATE nHdlPrv    := 1, cLoteFat := "", nTotal := 0
	PRIVATE lGeraLanc, lDigita, lJunta
	Private lValTot   := SuperGetMv("MV_VALTOTA")  //Verifica se valida ou nao o total da fatura
	Private aHeader   := {}
	Private aCols     := {}
	Private aDescontos   := {}
	Private aImps := {}
	
	SetKey(VK_F12,{|| Lj220Ativa()})
	
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
	
	If lLancPad10 .OR. lLancPad20
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Posiciona numero do lote para lancamentos do fatur. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SX5")
		DbSeek(cFilial+"09FAT")
		
		cLoteFat:=If(Found(),Trim(X5Descri()),"FAT ")
		nHdlPrv :=HeadProva(cLoteFat,"LOJA220",Subs(cUserName,1,6),@cArquivo)
	Endif
	
	If nHdlPrv <= 0
		HELP(" ",1,"HDLNAOGERA")
		Return( .T. )
	Endif
endif

// Venda R pida
Private cCadastro 	 := STR0001
Private lVendaRapida := .T.
// Pesq. / Atendimento
Private aRotina		:= MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ e Verifica se o Caixa e de Cupom Fiscal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lGaveta := !Empty(LjGetStation("GAVETA"))
Private cNumPdv := Space(10)
Private aTabelas:= {{"1",0},;
{"2",0},;
{"3",0},;
{"4",0},;
{"5",0},;
{"6",0},;
{"7",0},;
{"8",0},;
{"9",0} }

Private oDlgRapid
Private cCndPgt 	:= ''

//HOMOLOGACAO: Controle de Cupom Fiscal cancelado devido a problemas com o TEF
Private lCancelado 	:= .F.

If lFiscal
	
	If lLjECF00
		LjMsgRun(STR0115,,{|| ExecBlock("LJECF00",.F.,.F.),CLR_HRED } ) // Aguarde, verificando a impressora fiscal...
	Else
		LjMsgRun(STR0115,,{|| aIcms:=LjSetAliq(),CLR_HRED } ) // Aguarde, verificando a impressora fiscal...
	EndIf
	
EndIf

mBrowse(6, 1, 22, 75, "SL1",,,,,,aCores)

RestArea(aArea) // Restaura a Area Anterior

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para Lancamento Contabil, se gerado arquivo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if cPaisLoc <> "BRA"
	If lLancPad10 .OR. lLancPad20
		RodaProva(nHdlPrv,nTotal)
	Endif
	If !lGeraLanc
		lLancPad10:=.F.
		lLancPad20:=.F.
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para Lancamento Contabil, se gerado arquivo    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLancPad10.OR.lLancPad20
		cA100Incl(cArquivo,nHdlPrv,3,cLoteFat,lDigita,lJunta)
	endif
	Set Key VK_F12 To
Endif

Return lRet  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef	³ Autor ³ Vendas Clientes       ³ Data ³12/12/06  ³±±
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

Local aRotina:= {		{ STR0002, "AxPesqui", 0, 1 , , .F.},;		// "Pesq."
						{ STR0003, "lj220Ate", 0, 3 , , .T.},;		// "Atendimento"
						{ STR0142, "LJ220Leg", 0, 8 , , .T.} }		// "Legenda"

							
							
Return(ARotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Lj220ate ³ Autor ³ Vendas Clientes       ³ Data ³ 11/1997  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Antendimento da Super R pida.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja Windows                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj220Ate(cAlias, nReg, nOpcx)

Local nSaveSx8 		:= GetSx8Len() // Variavel para controle do semaforo (deve ficar antes da criavar do L1_NUM)
Local aArea      	:= GetArea() // Grava a Area Atual
Local lContinua	 	:= .T.
Local lRet       	:= .F.
Local cCaixa	 	:= xNumCaixa()
Local cOrcam	 	:= CriaVar("L1_NUM", .T.)
Local dData      	:= dDataBase
Local cHora      	:= Time()
Local cNumSX8	 	:= cOrcam
Local cProduto	 	:= Space(_TAMCPROD)
Local cLocal	 	:= Space(2)
Local cDescrProd 	:= Space(23)
Local cSimbMoeda 	:= Alltrim(SuperGetMv("MV_SIMB1"))

Local cMensagem	 	:=	STR0076 + Chr(13)+Chr(10) + ;  	//"F4 - Tabela Preços"
                    	STR0004 + Chr(13)+Chr(10) + ;  	//"F5 - Conf. Itens"
	                    STR0005 + Chr(13)+Chr(10) + ;  	//"F6 - Desc. no Item"
						STR0006 + Chr(13)+Chr(10) + ;  	//"F7 - Consulta TEF"
						STR0007 + Chr(13)+Chr(10) + ;  	//"F8 - Altera Quant."
						STR0008 + Chr(13)+Chr(10) + ;  	//"F9 - Exclui Item"
						STR0009 + Chr(13)+Chr(10) + ;  	//"F11 - Cliente"
						STR0010      				   	//"F12 - Vendedor"	

Local cTmpProd  	:= Space(_TAMCPROD)
Local nVlrUnit   	:= 0.00
Local nVlrIpi    	:= 0.00
Local nQuant	 	:= 1.00
Local nTmpQuant  	:= 1.00
Local nDescItem  	:= 0.00
Local nVlrTot	 	:= 0.00
Local nPreco	 	:= 0.00
Local nVlrTotItem	:= 0.00
Local nAltura	 	:= 30
Local nItem 	 	:= 0
Local nPerDesItem	:= 0
Local cFotoImp   	:= "FISCAL1"
Local nPassos	 	:= 1
Local nRecNo	 	:= 0
Local nOrd		 	:= 0
Local nRet 		 	:= 0
Local cBuffer

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vari veis para objetos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oCaixa
Local oOrcam
Local oData
Local oHora
Local oFotoProd
Local oProduto
Local oDescrProd
Local oMensagem
Local oQuant
Local oDescItem
Local oVlrTot
Local oVlrUnit
Local oFotoImpre
Local oVlrTotItem
Local oTmpProd
Local oTmpQuant
Local oPerDesItem
Local oX, nX
Local oSimb1
Local oSimb2
Local oSimb3
Local cPorta		:= LjGetStation("PORTIF")
Local cImpressora	:= LJGetStation("IMPFISC")
Local oUp_Foto
Local lTeclouF4 	:= .F.
Local lTeclouF5 	:= .F.
Local lTeclouF6 	:= .F.
Local lTeclouF7 	:= .F.
Local lTeclouF8 	:= .F.
Local lTeclouF9 	:= .F.
Local lTeclouF11	:= .F.
Local lTeclouF12	:= .F.
Local aTabConv  	:= {}
Local oFnt
Local oFnt1
Local oFnt2
Local oFnt3
Local oFnt4
Local oFnt5
Local oFnt6
Local oFnt7
Local lLj22001 		:= ExistBlock("LJ22001") // RA - Sysplus - Leandro
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variav.Log de Orcamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nHandle  		:= 0
Local cLjArq  		:= Space(8)
Local lLog1    		:= Subs(LJGetProfile("LOGERRO"),1,1) == "S"	// Tem Log de Erro
Local aCRec    		:= {}
Local i        		:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Var. Multi-moeda (Loc.) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oCbx,cMoeda
Local nPosDot
Local lEditavel 	:= SuperGetMv("MV_L1TXMOE")
Local lTrcMoeda 	:= SuperGetMv("MV_TRCMOED")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida a série ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! LjVldSerie()
	Return (.F.)
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe redução Z pendente      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFiscal
	cBuffer := Space(5)
	nRet := IFStatus( nHdlECF, '8', cBuffer )
	If nRet == 10
		MsgStop(STR0128)
		Return (.F.)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o parâmetro MV_ULMES (data do ultimo fechamento de estoque) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If dDataBase <= If(FindFunction("MVUlmes"),MVUlmes(),SuperGetMv("MV_ULMES"))
	Help(" ",1,"MV_ULMES")
	Return ( .F. )
EndIf

Private lLogRecupera	:= .F.					// Indica se o log de recuperacao foi criado na venda atuall
Private nDescLog    	:= 0
Private aCloaCols   	:= {}
Private aColsItem   	:= {}
Private cLoteCtl    	:= CriaVar("L2_LOTECTL")
Private cNLote      	:= CriaVar("L2_NLOTE")
Private cLocaliz    	:= CriaVar("L2_LOCALIZ")
Private cNSerie     	:= CriaVar("L2_NSERIE")
Private cBConta     	:= CriaVar("L2_BCONTA")

Private aItensTela  	:= {}
Private aItensVenda 	:= {}
Private aItensExc   	:= {}
Private lQuant      	:= .F.
Private lUsaFoto    	:= SuperGetMv("MV_USAFOTO")
Private lEditaList  	:= .F.
Private lGravou     	:= .F.
Private lDescItem   	:= .F.
Private lTabela     	:= .T.
Private lFinaliza   	:= .F.
Private cPictL2Q
Private cItemFita   	:= ""
Private cTabPad     	:= If(SuperGetMv("MV_TABPAD") $ "1ş2ş3ş4ş5ş6ş7ş8ş9",SuperGetMv("MV_TABPAD"),"1")
Private nCheck      	:= If(lFiscal,1,2)
Private lCheck      	:= .F.
Private aContas     	:= {}   //Telesp Celular
Private oListFita
Private nPosItem    	:= 1
Private nPosQuant   	:= 2
Private nPosProd    	:= 3
Private nPosVlrTot  	:= 4
Private nPosDescr   	:= 5
Private nPosDesc    	:= 6
Private nPosPerDes  	:= 7
Private nPosVlrUni  	:= 8
Private nPosLocal   	:= 9
Private nPosTes	    	:= 10
Private nPosUM 	    	:= 11
Private nPosTipo    	:= 12
Private nPosIcms    	:= 13
Private nPosIpi	    	:= 14
Private nPosIss	    	:= 15
Private nPosCF 	    	:= 16
Private nPosTabela  	:= 17
Private nPosBsIcms  	:= 18
Private nPosPrcTab  	:= 19
Private nPosBsIpi   	:= 20
Private nPosBsIss   	:= 21

Private nPosLoteCtl 	:= 24
Private nPosNLote   	:= 25
Private nPosLocaliz 	:= 26
Private nPosnSerie  	:= 27
Private nPosBConta  	:= 28
Private nPosVlRat   	:= 29
Private nPosSubTrib 	:= 30
Private nPosBRSubTrib   := 31

Private cNumNota    	:= Space(TamSx3("L1_DOC")[1])
Private cSerie      	:= Space(TamSx3("L1_SERIE")[1])
Private lCliente    	:= .T.
Private lExclui     	:= .T.
Private lVendedor   	:= .T.
Private nCheques    	:= 0
Private nFinanciado 	:= 0
Private nConvenio   	:= 0
Private nDinheiro   	:= 0
Private nTroco      	:= 0
Private nVales      	:= 0
Private nValorDebi  	:= 0
Private nOutros     	:= 0
Private nCartao     	:= 0
Private nValorBase  	:= 0
Private nTotalDesc  	:= 0
Private nTotalAcrs  	:= 0
Private nTotalPerD  	:= 0
Private nParcelas   	:= 1
Private nCartDebito 	:= 0
Private cCondicao   	:= ""
Private cFormaPg    	:= ""
Private nEntrada    	:= 0
Private aParcelas   	:= {}
Private nPago       	:= 0
Private nJuros      	:= 0
Private nPercent    	:= 0
Private nDesconto   	:= 0
Private lDescCond   	:= .F.
Private cGaranch    	:= ""
Private aTefDados   	:= {}
Private aParcTef    	:= {}
Private nOrdProd    	:= 0
Private nOrdQtd	    	:= 0
Private cOrcamen    	:= cOrcam
Private cCartao     	:= Space(3)
Private cSimbCheq   	:= AllTrim(MVCHEQUE)
Private cInfProBal		:= ""
Private cCliente
Private cLojaCli
Private nDecimais

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribuicao de variveis que serao utilizadas no Roteiro ³
//³ de calculo dos impostos para os paises do MercoSul...  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCalcImpV		:= SuperGetMv("MV_GERIMPV")
Private nMoedaCor		:= 1
Private aMoeda			:=	{}
Private oTaxaMoeda,nTaxaMoeda := Criavar("M2_MOEDA1")
If cPaisLoc <> "BRA"
	Private aImpVarSF2 := {}, aImpVarSD2 := {0,0,0,0,0,{},''}
	Private aImpCusto := {}, aImpVarDup := {}
	Private nValTotIV := 0, nValBaseIV := 0
	Private nImpsItDis:= 0              //Valor do imposto discriminado por item
	Private lCredFisc := .F.           //Identifica se o tipo de documento a ser emitido eh Credito Fiscal - El Salvador
	If cPaisLoc == "SAL"
	    Private cRegFisc  := Space(TamSX3("LU_REGFISC")[1])
	    Private cNomeRF   := Space(TamSX3("LU_NOME")[1])    
	    Private cEnderRF  := Space(TamSX3("LU_END")[1])    
	    Private cTelefRF  := Space(TamSX3("LU_TEL")[1])
	    Private cAtivRF   := Space(TamSX3("LU_ATIVIDA")[1])		
	EndIf	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se houver problemas na tentativa de pegar um novo numero para o Telemarketing³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SL1->(DBSetOrder(1))
While .T.
		
	If ! SL1->(DbSeek(xFilial("SL1")+cOrcam))
		Exit
	Endif
	While (GetSX8Len() > nSaveSx8)
		ConfirmSx8()
	End
	cOrcam := GetSxENum("SL1","L1_NUM")
	
End
cNumSX8	 := cOrcam
cOrcamen := cOrcam

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ ******  Descric„o do ARRAY aParcelas  ******** ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Dimensoes  ³ Descric„o                         ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³   1        ³ Data de Pagamento                 ³
³   2        ³ Valor                             ³
³   3        ³ Forma de Pgto (R$,CC)             ³
³   4        ³ Administradora                    ³
³   5        ³ Numero do Cartao / Cheque         ³
³   6        ³ Agencia - Cheque                  ³
³   7        ³ Conta - Cheque                    ³
³   8        ³ Rg - Cheque                       ³
³   9        ³ Telefone - Cheque                 ³
³  10        ³ Cheque de Terceiros               ³
³  11        ³ Moeda                             ³
³  12        ³ Compensacao                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

If ! CheckPaper() .OR. ! CheckIFData()
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define cliente com o padrao do parametro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("LjCliPad")
	cTmpCli  := ExecBlock("LjCliPad",.F.,.F.,)
	cCliente := Substr(cTmpCli,1,TamSx3("A1_COD")[1])
	cLojacli := Substr(cTmpCli,7,2)
Else
	cCliente := PadR(SuperGetMv("MV_CLIPAD"),TamSx3("A1_COD")[1])
	cLojacli := PadR(SuperGetMv("MV_LOJAPAD"),2)
EndIf
Private cCliAnt  := ""
Private cLojAnt  := ""

DbSelectArea("SA1")
DBSetOrder(1)
If !DbSeek(xFilial("SA1")+cCliente+cLojacli)
	CriaCliPad()
Elseif cPaisLoc == "ARG"
   cSerie  := Lj010SerArg()    		
ElseIf cPaisLoc == "SAL"   
   lCredFisc  := SA1->A1_TIPO $ "1|4"	
EndIf

DbSelectArea("SX3")
nOrd	:= IndexOrd()
nRecNo:= RecNo()

DBSetOrder(2)
DbSeek("L2_PROD",.T.)
nOrdProd:= SX3->X3_ORDEM
DbSeek("L2_QUANT",.T.)
nOrdQtd:= SX3->X3_ORDEM

DBSetOrder(nOrd)
dbGoTo(nRecNo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o Vendedor como o padrao definido no parametro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cVendLoja 	:= If( Len(SuperGetMv("MV_VENDPAD")) <= 6,SuperGetMv( "MV_VENDPAD" )+Space(6-Len(SuperGetMv("MV_VENDPAD"))),Space(6))
DbSelectArea("SA3")
DBSetOrder(1)
If !DbSeek(xFilial("SA3")+cVendLoja)
	ljCriaCli("vend")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega array com as moedas ativas para o Combo.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA"
	For nX	:=	1	To MoedFin()
		If(!(Empty(SuperGetMv("MV_MOEDA"+Ltrim(STR(nX))))))
			LjCriaSimb(nX)
			AAdd(aMoeda,SuperGetMv("MV_MOEDA"+Ltrim(Str(nX))))
		Else
			Exit
		Endif
	Next nX
	
	If SL1->L1_MOEDA <> 0 .AND.  SL1->L1_MOEDA <= Len(aMoeda)
		nTaxaMoeda		:=	SL1->L1_TXMOEDA
		cMoeda	    :=	aMoeda[SL1->L1_MOEDA]
	ElseIf SL1->L1_MOEDA == 0
		nTaxaMoeda		:=	1
		cMoeda	    :=	aMoeda[1]
	Else
		Help(" ",1,"NoMoeda")
	Endif
EndIf
  
If lLj22001
	ExecBlock("LJ22001",.F.,.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama funcao para ver se ‚ caixa, se est  aberto, etc... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lContinua := Lj220ChkVenda()

If lContinua
	
	DEFINE MSDIALOG oDlgRapid FROM 1,1 TO 453,637 TITLE cCadastro PIXEL OF GetWndDefault()
	
	
	oDlgRapid:bGotFocus := { || lEditaList  := .F. }
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Defini‡ao de fontes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	nPosDot := At(".",PesqPict("SL1","L1_DESCONT",_PICTURE,nMoedaCor))
	If nPosDot == 0
		nDecimais := 0
	Else
		nDecimais := Rat("9",PesqPict("SL1","L1_DESCONT",_PICTURE,nMoedaCor)) - nPosDot
	EndIf
	
	DEFINE FONT oFnt  NAME "TIMES NEW ROMAN" SIZE 19,34 	BOLD   //Largura x Altura
	DEFINE FONT oFnt1 NAME "TIMES NEW ROMAN" SIZE 9,18 		BOLD
	DEFINE FONT oFnt2 NAME "TIMES NEW ROMAN" SIZE 11.5,22 	BOLD
	DEFINE FONT oFnt3 NAME "MS SANS SERIF" 					BOLD
	DEFINE FONT oFnt4 NAME "COURIER NEW" 	 SIZE 5,0 
	DEFINE FONT oFnt5 NAME "MS SANS SERIF" 	 SIZE 6,15
	DEFINE FONT oFnt6 NAME "TIMES NEW ROMAN" SIZE 7,18		BOLD
	DEFINE FONT oFnt7 NAME "COURIER NEW" 	 SIZE 7,14
	
	DEFINE TIMER oTimer INTERVAL 10000 ACTION ChgHora(oHora,@cHora) OF oMainWnd
	
	@	15 , 01 TO  42,260 OF oDlgRapid PIXEL

	@	21 , 03 TO  40, 66 LABEL STR0080 OF oDlgRapid PIXEL // Caixa
	@	21 , 67 TO  40,130 LABEL STR0081 OF oDlgRapid PIXEL // Documento
	@	21 ,131 TO  40,194 LABEL STR0082 OF oDlgRapid PIXEL // Data
	@	21 ,195 TO  40,258 LABEL STR0083 OF oDlgRapid PIXEL // Hora
	@	43 , 01 TO  65, 61 LABEL STR0084 OF oDlgRapid PIXEL // Quantidade
	@	43 , 63 TO  65,153 LABEL STR0085 OF oDlgRapid PIXEL // C¢digo do Produto
	@	67 , 01 TO 145,153 LABEL STR0086 OF oDlgRapid PIXEL // Produto
	@	72 , 03 TO  89, 96 LABEL STR0087 OF oDlgRapid PIXEL // C¢digo
	@	90 , 03 TO 107,151 LABEL STR0088 OF oDlgRapid PIXEL // Descri‡Æo
	@  108 , 03 TO 125,151 LABEL STR0089 OF oDlgRapid PIXEL // Quantidade x Pre‡o
	@  126 , 03 TO 143, 95 LABEL STR0090 OF oDlgRapid PIXEL // Total Item

	@ 146 , If(lUsaFoto,80,01) TO 217,154 LABEL STR0092 ;
			OF oDlgRapid PIXEL 								// Mensagens 
	
	@ 180,157 TO 200,315 LABEL STR0093 OF oDlgRapid PIXEL 	// Total parcial
	@ 043,156 SAY STR0094 SIZE 20,08   OF oDlgRapid PIXEL 	// Ticket
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Status sobre o caixa, or‡amento, data, etc... ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 27, 05 SAY oCaixa VAR cCaixa SIZE 60,10 OF oDlgRapid PIXEL PICTURE;
	"@!" CENTER FONT oFnt2 COLOR CLR_BLUE
	
	@ 27, 69 SAY oOrcam VAR cOrcam SIZE 60,10 OF oDlgRapid PIXEL PICTURE;
	"@!" CENTER FONT oFnt2 COLOR CLR_BLUE
	
	@ 27,133 SAY oData  VAR dData  SIZE 60,10 OF oDlgRapid PIXEL PICTURE;
	"@!" CENTER FONT oFnt2 COLOR CLR_BLUE
	
	@ 27,197 SAY oHora  VAR cHora  SIZE 60,10 OF oDlgRapid PIXEL PICTURE;
	"@!" CENTER FONT oFnt2 COLOR CLR_BLUE
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Get para a Quantidade ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX3")
	DBSetOrder(2)
	If DbSeek("L2_QUANT")
		cPictL2Q := X3_PICTURE
	Else
		cPictL2Q:="@E 999.99"
	Endif
	@ 50, 05 MSGET oTmpQuant VAR nTmpQuant SIZE 52,10 OF oDlgRapid PIXEL;
	PICTURE cPictL2Q ;
	VALID (lRet := .T.)
	
	If (nOrdProd < nOrdQtd)
		oTmpQuant:Disable()
	Else
		oTmpQuant:Enable()
		oTmpQuant:Refresh()
		lQuant:= .T.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ¡tems de venda do cupom. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 133,166 LISTBOX oListFita VAR cItemFita SIZE 143,10 OF oDlgRapid PIXEL;
	ITEMS aItensTela COLOR CLR_HBLUE, CLR_WHITE
	
	oListFita:SetFont(oFnt4)
	oListFita:bGotFocus := { || If(!lEditaList,SetFocus(oTmpProd:hWnd),) }
	oListFita:bLostFocus:= { || lEditaList := .F.,oTmpProd:Refresh() }
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Get do produto ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 50, 67 MSGET oTmpProd  VAR cTmpProd SIZE 74,10 OF oDlgRapid PIXEL;
	PICTURE PesqPict("SB1","B1_COD",_TAMCPROD,nMoedaCor) F3 "SL2" 

	
	oTmpProd:SetConvKey( aTabConv )
	oDlgRapid:bGotFocus :={|| SetFocus(oTmpProd:hWnd) }
	
	aCRec := LjRecLog(cOrcam) 		// Log de Recuperacao
	If Len(aCRec[1]) >= 1
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Incrementa os Itens de Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For i := 1 to Len(aCRec)
			AcumulaItem(aCRec[i][nPosLoteCtl],aCRec[i][nPosLocaliz],aCRec[i][nPosNLote],;
			aCRec[i][nPosNSerie],aCRec[i][nPosBConta],aCRec[i][nPosProd],;
			aCRec[i][nPosQuant],aCRec[i][nPosDesc],aCRec[i][nPosVlrUni],@nVlrTot,;
			@nVlrTotItem,@nAltura,aCRec[i][nPosDescr],@nItem,aCRec[i][nPosPerDes],;
			aCRec[i][nPosVlrUni],aCRec[i][nPosLocal],@nPassos,@nVlrIpi)
		Next
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Informa‡äes sobre o produto atual ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 77 , 04 SAY oProduto  VAR cProduto SIZE 91,10 OF oDlgRapid PIXEL;
	PICTURE PesqPict("SB1","B1_COD",_TAMCPROD) CENTER FONT oFnt1 COLOR CLR_BLUE
	
	@ 95 , 05 SAY oDescrProd  VAR cDescrProd	SIZE 120,10 OF oDlgRapid PIXEL;
	CENTER FONT oFnt2 COLOR CLR_BLUE
	
	@ 113, 05 SAY oQuant 	  VAR nQuant		SIZE 48,10 OF oDlgRapid PIXEL;
	PICTURE cPictL2Q RIGHT FONT oFnt1 COLOR CLR_BLUE
	
	@ 113, 55 SAY oX VAR "X"                  SIZE 10,10 OF oDlgRapid PIXEL;
	FONT oFnt1 COLOR CLR_BLUE
	
	@ 113, 67 SAY oSimb1 VAR cSimbMoeda 		SIZE 15,10 OF oDlgRapid PIXEL;
	FONT oFnt6 COLOR CLR_BLUE
	
	@ 113, 79 SAY oVlrUnit VAR Transform(nVlrUnit,PesqPict("SL2","L2_VLRITEM",_PICTURE,nMoedaCor)) ;
	SIZE 66,10 OF oDlgRapid PIXEL RIGHT FONT oFnt1 COLOR CLR_BLUE
	
	@ 131, 05 SAY oSimb2 VAR cSimbMoeda SIZE 20,10 OF oDlgRapid PIXEL FONT oFnt1 COLOR CLR_BLUE
	
	@ 131, 20 SAY oVlrTotItem VAR Transform(nVlrTotItem,PesqPict("SL2","L2_VLRITEM",_PICTURE,nMoedaCor)) ;
	SIZE 70,10 OF oDlgRapid PIXEL RIGHT FONT oFnt2 COLOR CLR_BLUE

	@ 052,157 BITMAP oUp_Foto	RESOURCE "IMP_FISC" OF oDlgRapid PIXEL SIZE 157,100
	@ 147,157 BITMAP oFotoImpre RESOURCE cFotoImp  	OF oDlgRapid PIXEL SIZE 157,20
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Simbolo da Moeda    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 185,160 SAY oSimb3 VAR cSimbMoeda SIZE 20,10 OF oDlgRapid PIXEL;
	FONT oFnt1 COLOR CLR_BLUE
	
	If lUsaFoto
		@ 147 , 05 REPOSITORY oFotoProd SIZE 70,70 PIXEL OF oDlgRapid
		oFotoProd:SetColor(GetSysColor(15),GetSysColor(15))
		oFotoProd:lStretch := .T.
		oFotoProd:lVisible := .T.
		ShowBitMap(oFotoProd,"LOJAWIN")
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Moeda/Taxa          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc<>"BRA"
		@ 170,160 SAY STR0116 SIZE 22, 07 OF oDlgRapid PIXEL         //"Moeda"
		@ 168,183 COMBOBOX oCBX VAR cMoeda ITEMS aMoeda ON CHANGE (nTaxaMoeda := RecMoeda(dDataBase,oCBX:nAt),;
		nMoedaCor  := oCBX:nAt,;
		nDecimais  := MsDecimais(nMoedaCor),;
		cSimbMoeda := SuperGetMv("MV_SIMB"+Str(nMoedaCor,1)),;
		oSimb1:Refresh(),;		
		oSimb2:Refresh(),;				
		oSimb3:Refresh(),;						
		SetFocus(oTmpProd:hWnd)) ;
		VALID IIf(lTrcMoeda,If(nTaxaMoeda==0,(MsgAlert(STR0125),.F.),.T.),.T.) ;  //"A moeda escolhida nao possui taxa cadastrada"
		SIZE 50,50 WHEN lEditavel OF oDlgRapid PIXEL
		
		@ 170,237 SAY STR0117 SIZE 18, 07 OF oDlgRapid PIXEL         //"Taxa"
		@ 168,251 MSGET oTaxaMoeda VAR nTaxaMoeda  WHEN lEditavel;
		OF oDlgRapid Picture PesqPict("SL1","L1_TXMOEDA",11) PIXEL
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valor total a pagar ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 182,175 SAY oVlrTot VAR Transform(nVlrTot,PesqPict("SL1","L1_VLRTOT",_PICTURE,nMoedaCor)) ;
	SIZE 135,15 OF oDlgRapid PIXEL RIGHT FONT oFnt COLOR CLR_HRED
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mensagens para o usu rio ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 154,If(lUsaFoto,83,05) SAY oMensagem VAR cMensagem ;
			 				  SIZE 70,70 OF oDlgRapid PIXEL ; //70,55
					  	 	  FONT oFnt7 COLOR CLR_BLUE
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao das teclas especiais para encerar, conceder desconto	 ³
	//³ no item, Editar o listbox com os itens e digitacao da quantidade ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTabela
	   SetKey(VK_F4,{ || lTeclouF4 := .T.})
	EndIf   
	
	SetKey(VK_F5,{ |nKey| lTeclouF5 := .T. , If(lFinaliza,;
	(If(lLog1,(LjGrLog(@nHandle,cOrcam,@cLjArq,cImpressora,cPorta)),.T.) , ),),;
	If(lLog1,LjDelLog(nHandle,aCloaCols,aColsItem,cLjArq,Strzero(Val(cOrcam)-1,6),nDescLog,cCliente,cLojaCli),.T.) } )
	
	SetKey(VK_F6,{ || If(LjProfile( 11 ), (lTeclouF6:= .T.,If(!Empty(aItensVenda) .AND. lDescItem,;
	(L220DescItem(@nDescItem,@nVlrUnit,@nVlrTotItem,oVlrUnit,;
	oVlrTotItem,@nPerDesItem,oPerDesItem,aItensVenda[Len(aItensVenda)][2],oDescItem,;
	cDescrProd, @nAltura, @nVlrTot, oVlrTot, @nPassos, oDlgRapid, cTmpProd, oTmpProd),;
	),)),NIL) })
	
	if lUsaTef
		SetKey(VK_F7,{ || lTeclouF7:=.T.,LOJA010T( "C" ) })
	Endif
	
	SetKey(VK_F8,{ || lTeclouF8:=.T.,lQuant := .T. , Lj220Active(@oTmpQuant),;
	nVlrTotItem := 0, oVlrTotItem:Refresh(),;
	nVlrUnit 	:= 0, oVlrUnit:Refresh(),;
	nQuant 		:= 1, oQuant:Refresh() })
	
	If lExclui
		SetKey(VK_F9,{ || lTeclouF9 := .T.,(if(cPaisLoc<>"BRA" .AND. Len(aItensVenda)==0,;
		(lj220RollBackSx8( nSaveSx8 ),SetFocus(oTmpProd:hWnd)),.T.))})
	EndIf		
	
	If(lCliente ,SetKey(VK_F11,{ || lTeclouF11 := .T.,Lj220Cliente(oDlgRapid)}),NIL)
	If(lVendedor,SetKey(VK_F12,{ || lTeclouF12 := .T.}),NIL)
	SetKey(19, NIL)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cancelamento de Cupom fiscal Ctrl + E ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If(ExistBlock("LJ220KE"),SetKey(5,{|| ExecBlock("LJ220KE",.F.,.F.,)}),NIL)	// Ctrl + E
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cancelamento de Cupom fiscal Ctrl + F ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lFiscal
		SetKey(6,{ || lj140Exc('SL1',,2) })
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Sangria/Troco de caixa     Ctrl + G   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetKey(7,{ || fa100tran('SA6',,) })
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Final da definicao de teclas de atalho para ponto de entrada          ³
	//³solicitados pela Kodak                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	ACTIVATE MSDIALOG oDlgRapid ON INIT (L220ToolBar(@cCaixa,@cOrcam,@cNumSX8,@cProduto,@cDescrProd,@cTmpProd,;
	@nVlrUnit,@nQuant,@nTmpQuant,@nDescItem,@nVlrTot,@nPreco,;
	@nVlrTotItem,@nAltura,@nItem,@nPerDesItem,oCaixa,oOrcam,;
	oProduto,oDescrProd,oQuant,oVlrTot,oVlrUnit,oFotoImpre,oVlrTotItem,;
	oTmpProd,oTmpQuant,oDlgRapid,@cLocal,oX,oSimb1,oSimb2,oSimb3,;
	@nPassos,oFotoProd,nSaveSx8));
	VALID LjConfExit( nSaveSx8 ) ON MOVE oDlgRapid:Move(0.1,0.1,,,.T.)
	
EndIf

SetKey(VK_F4, NIL)
SetKey(VK_F5, NIL)
SetKey(VK_F6, NIL)
SetKey(VK_F7, NIL)
SetKey(VK_F8, NIL)
SetKey(VK_F9, NIL)
SetKey(VK_F10, NIL)
SetKey(VK_F11, NIL)
SetKey(VK_F12, NIL)
SetKey(1, NIL)
SetKey(2, NIL)
SetKey(3, NIL)
SetKey(4, NIL)
SetKey(5, NIL)
SetKey(6, NIL)
SetKey(7, NIL)
SetKey(15, NIL)
SetKey(19, NIL)
SetKey(24, NIL)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a Area anterior ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)

Return lContinua

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AcumulaIte³ Autor ³ Vendas Clientes       ³ Data ³ 03/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Adiciona em um array os produtos vendidos.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ ExpC1 - Produto atual.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 - .T.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja - Venda Super-RApida.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AcumulaItem(cLoteCtl,   cNLote,   cLocaliz,    cNSerie,;
					 cBConta,    cProduto, nQuant,      nDescItem,;
					 nPreco,     nVlrTot,  nVlrTotItem, nAltura,;
					 cDescrProd, nItem,    nPerDesItem, nVlrUnit,;
				 	 cLocal,     nPassos,  nVlrIpi)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para armazenar caracteristicas do produto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cTes         := ""
Local cUM          := ""
Local cTipo        := ""
Local cCF          := ""
Local nIcms        := 0
Local nIpi         := 0
Local nIss         := 0
Local nBsIcms      := 0
Local iRet         := 0
Local cB1_Ts
Local cUnit
Local cDesconto
Local cSituacao    := ""
Local cQuant
Local lLj220Reg    := ExistBlock("LJ220REG")
Local lLj220Fis    := ExistBlock("LJ220FIS") // Telesp Celular
Local lConfirmaFis := .T. //Telesp Celular
Local aTam
Local nTamInt
Local nTamDec
Local nPICMRET
Local cGRTRIB
Local nItensT      := 0
Local lValProd5    := ExistBlock("VALPROD5")
Local lLog4        := Subs(LJGetProfile("LOGERRO"),4,1) == "S" // Tem Log de Recuperacao
Local cRetorno     := ' '
Local cTotIt       := ""
Local cProdCod     := ""
Local cTesPE       := If( ExistBlock( "LJ220TS" ), ExecBlock( "LJ220TS" , .F., .F., {cProduto}), "" )
Local aExcecao     := {}
Local nMargem      := 0
Local nVlIcmRet    := 0
Local nVlUniIcmRet := 0
Local nArredImp	   := 2
Local lL220TabPad  := ExistBlock( "L220TABPAD" )
Local cUnidMed     := " "
Local aIcmsSol     :=  {} //array que armazenara o ICMS Solidario
Local nVlBrIcmsRet :=  0 //variavel que armazenara a base do ICMS Solidario


Default nDescItem  := 0

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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Incrementa um item para a venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nItem ++

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valor total da venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nPICMRET := SB1->B1_PICMRET
cGRTRIB  := SB1->B1_GRTRIB

//Pega o valor do desconto para dar desconto no item nas impressoras
//fiscais que tem de passar o vlor do desconto junto com a impressão do item.
If lFiscal .AND. lValProd5
	nDescItem := ExecBlock("VALPROD5",.F.,.F.,{cProduto,Round(( nPreco* nQuant ),2)})
	If Upper( ValType( nDescItem ) ) <> "N"
		nDescItem := 0
	EndIf	
EndIf

// Posiciona o arquivo de produtos para o retorno correto da função LJICMSSol.	
SB1->(DBSetOrder(1))
SB1->(DbSeek(xFilial("SB1") + cProduto))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o produto possui a margem de lucro, guardo o valor do imposto retido.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SA1->A1_TIPO $ SuperGetMv("MV_TPSOLCF") .AND. SF4->F4_INCSOL <> "N"                       
    aIcmsSol     :=  LjIcmsSol( ((nPreco-nDescItem)*nQuant), nQuant, nPreco-nDescItem)
    nVlBrIcmsRet :=  aIcmsSol[1]
	nVlIcmRet    := aIcmsSol[2]
	nacRetICMS   += nVlIcmRet
	nVlUniIcmRet := nVlIcmRet/nQuant
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valor total do item ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVlrTotItem := Round(( nPreco * nQuant ),2) + If(cPaisLoc <> "BRA",nImpsItDis,0)
cTotIt := Str(Round(( (nPreco+nVlUniIcmRet) * nQuant ),2)+If(cPaisLoc <> "BRA",nImpsItDis,0),TamSx3("L2_VLRITEM")[1],nDecimais)
If lLj220fis
	lConfirmaFis:=ExecBlock("LJ220FIS",.F.,.F.,{cProduto})
Endif

If lFiscal .AND. lConfirmaFis
	
	If nItem == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³se exitir cupom aberto, faz o cancelamento e abre um novo.          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		iRet := IFStatus( nHdlECF, '5', @cRetorno )
		If iRet = 7
			MsgInfo(STR0126) //Foi detectado um problema e o cupom fiscal atual ser  cancelado.
			iRet := IFCancCup( nHdlECF )
			If L010AskImp(.F.,iRet)
				nItem --
				Return (.F.)
			EndIf
			Inkey(8)   // dá um tempo para a impressora fazer a impressao do cancelamento
		Else
			If L010AskImp(.F.,iRet)
				nItem --
				Return (.F.)
			EndIf
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Abre um novo cupom e pega o número                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		iRet := IFAbreCup( nHdlECF )
		If L010AskImp(.F.,iRet)
			nItem --
			Return (.F.)
		EndIf
		cNumCupFis := Space(10)
		iRet := IFPegCupom( nHdlECF, @cNumCupFis )
		If L010AskImp(.F.,iRet)
			nItem --
			Return (.F.)
		EndIf
		cNumCupFis := StrZero(Val(cNumCupFis),TamSx3("L1_NUMCFIS")[1],0)
	Endif
	DbSelectArea("SB1")
	DBSetOrder(1)
	DbSeek(xFilial("SB1") + cProduto)
	
	DbSelectArea("SB0")
	DBSetOrder(1)
	DbSeek(xFilial("SB0")+ cProduto)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada que solicita ao usuario, o tes de saida para a venda, caso³
	//³o usuario necessite fazer controle de TES de saida por regiao              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( cTesPE )
		cB1_Ts := RetFldProd(SB1->B1_COD,"B1_TS")
	Else
		cB1_Ts := cTesPE
	EndIf
	
	If Empty(cB1_Ts)
		cB1_Ts:=SuperGetMv("MV_TESSAI")
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rotina de excessao fiscal                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aExcecao := ExcecFis( SB1->B1_GRTRIB, SA1->A1_GRPTRIB )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula a Margem de Lucro                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nMargem := If( Empty( SB1->B1_GRTRIB ), SB1->B1_PICMRET, aExcecao[3] )
	
	DbSelectArea("SF4")
	SF4->( DBSetOrder(1) )
	SF4->( DbSeek( xFilial("SF4") + cB1_Ts ) )
	// Ponto de Entrada Exclusivo para Edson de Pernambuco nao deve ser
	// liberada a utilizacao para as demais pessoas
	IF SF4->F4_ISS == "S" .AND. ( ( ( SA1->A1_RECISS <> "1" ) .OR.( Iif(FindFunction('lj7RecISS'),Lj7recIss(),SA1->A1_RECISS == "1" .AND. GetNewPar("MV_DESCISS", .F.)))))
		cSituacao := 'S' + AllTrim (Str( If(SB1->B1_ALIQISS>0,SB1->B1_ALIQISS,SuperGetMv("MV_ALIQISS")),5,2 ))
	ELSE
		If lLj220Reg
			cSituacao := ExecBlock("LJ220REG",.F.,.F.)
		ElseIf nMargem > 0 .AND. SF4->F4_MKPSOL<>"1" .And. SA1->A1_TIPO $ SuperGetMv("MV_TPSOLCF")
			cSituacao := "F"    // Substituicao tributaria (Icms Solidario)
		ElseIf SF4->F4_BASEICM > 0 .AND. SF4->F4_BASEICM < 100
			// com reducao de Icms na Base
			cSituacao := 'T' + AllTrim(Str( SB0->B0_ALIQRED,5,2 ))
		Elseif SF4->F4_LFICM == "I"
			cSituacao := "I"                 // Isento
		Elseif SF4->F4_LFICM == "N"
			cSituacao := "N"                 // N„o sujeito a ICMS
		Endif
	Endif
	
	
	DbSelectArea("SB1")
	
	cProdCod := cProduto
	If SuperGetMv("MV_CODBAR") == "S" .AND. !Empty(SB1->B1_CODBAR)
		cProduto := Substr(SB1->B1_CODBAR,1,13)
	Endif
	
	cQuant   := AllTrim(Str(nQuant,TamSX3("L2_QUANT")[1],TamSX3("L2_QUANT")[2]))
	cUnit    := AllTrim(Str(nVlrUnit+nVlrIpi+nVlUniIcmRet,TamSx3("L2_VRUNIT")[1],TamSx3("L2_VRUNIT")[2]))
	cUnidMed := SB1->B1_UM
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ NÆo contempla a verifica‡Æo de Acr‚scimo porque nesse  ³
	//³ momento nÆo se sabe qual ‚ a Condi‡Æo de Pgto. 		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDesconto := AllTrim(Str(nDescItem,14,2))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a impressao do registro do item                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	iRet := IFRegItem( nHdlECF, cProduto, SB1->B1_DESC, cQuant, cUnit, cDesconto, cSituacao,cTotIt, cUnidMed)
	If L010AskImp(.F.,iRet)
		nItem --
		Return (.F.)
	EndIf           
		
	If Substr(cSituacao,1,1) == "S"
		// controla se ocorreu registro de itens de serviço - "N" nenhum item,
		// "S" - so itens de servico, "T" - um ou mais itens de ICMS
		cRegISS	   := "S"                  
	Else
		cRegISS	   := "T"                  
	EndIf
	cProduto := cProdCod
	
EndIf

//Para o Chile o valor e base do imposto por item nao eh arredondado de acordo com os 
//decimais da moeda(MV_CENT=0), ou seja, deve considerar duas casas decimais. Somente 
//no total dos impostos faz o arredondamento									
If cPaisLoc == "CHI" .AND. nMoedaCor == 1
   nArredImp  := TamSX3("L2_VALIMP1")[2]
   nVlrTot += Round(NoRound((nPreco * nQuant)+nImpsItDis,nArredImp+1),nArredImp)
Else
   nVlrTot += Round(( (nPreco +nVlUniIcmRet)* nQuant ),nDecimais) + If(cPaisLoc <> "BRA",nImpsItDis,0)
EndIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona no Array o Cabecalho s¢ na primeira chamada da funcao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nAltura == 30
	Aadd( aItensTela, STR0011 )  //"              ITENS DE VENDA               "
	Aadd( aItensTela,"" )
	Aadd( aItensTela, STR0012) // Item  Quantidade C¢digo Prod. Total Item
	Aadd( aItensTela, STR0013) // Descri‡„o 							 Vendedor
	Aadd( aItensTela,"" )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Item Quant 	 C¢digo			  Total Item	  Descricao 		³
//³ XXX XX.XXX,XX XXXXXXXXXXXXXXX XXX.XXX,XX XXXXXXXXXXXXXXX		³
//³ 1234567890123456789012345678901234567890123456789012345678901 ³
//³			 1 		  2			3			 4 		  5			6	³
//³			 10		  20			30 		 40		  50			60 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTam:=TamSx3("L2_QUANT")
nTamInt:=aTam[1]
nTamDec:=aTam[2]
Aadd( aItensTela, Str( nItem,3) + "  " + Str(nQuant,nTamInt,nTamDec) + " " + cProduto +;
" " + Transform(nVlrTotItem,PesqPict("SL2","L2_VLRITEM")) )
Aadd( aItensTela, cDescrProd + Space(31-Len(cDescrProd)) + cVendLoja  )
nItensT:=Len(aItensTela)
oListFita:SetItems( aItensTela )
oListFita:GoBottom()
OListFita:Refresh()

//Coloca o desconto na tela para as impressoras fiscais que precisam de
//passar o desconto junto com a impressão do item
If lValProd5 .AND. (nDescItem > 0) .AND. lFiscal .AND. lConfirmaFis
	nPerDesItem  := (nDescItem * 100)/nVlrTotItem
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza total da venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrTot -= ( nDescItem )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza total unit rio ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrUnit := nVlrUnit - ( nDescItem / nQuant )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza total do item ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrTotItem := nVlrTotItem - nDescItem
	
	// Total Parcial Anterior -->
	// Desconto Item:
	// Valor liquido -->
	
	Aadd( aItensTela, STR0029 + Transform((nVlrTotItem + nDescItem),PesqPict("SL2","L2_VLRITEM")))
	Aadd( aItensTela, STR0030 + Str(nPerDesItem) + "%")
	Aadd( aItensTela, STR0031 + Transform(nVlrTotItem,PesqPict("SL2","L2_VLRITEM")))
	
	oListFita:SetItems( aItensTela )
	oListFita:GoBottom()
	oListFita:Refresh()
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no Produto para pegar sua caracteristicas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SB1")
SB1->(DBSetOrder(1))
SB1->(DbSeek( xFilial("SB1") + cProduto ))
If Empty( cTesPE )
	cTes := If(!Empty(RetFldProd(SB1->B1_COD,"B1_TS")), RetFldProd(SB1->B1_COD,"B1_TS"), SuperGetMv("MV_TESSAI"))
Else
	cTes := cTesPE
EndIf

cUM   := SB1->B1_UM
cTipo := SB1->B1_TIPO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona do TES do produto. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SF4")
SF4->(DBSetOrder(1))
SF4->(DbSeek( xFilial("SF4") + cTes ))
cCF := SF4->F4_CF

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Estrutura aItensVenda	³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³nPosItem       --> 1   ³
³nPosQuant      --> 2   ³
³nPosProd       --> 3   ³
³nPosVlrTot     --> 4   ³
³nPosDescr      --> 5   ³
³nPosDesc       --> 6   ³
³nPosPerDes     --> 7   ³
³nPosVlrUni     --> 8   ³
³nPosLocal      --> 9   ³
³nPosTes        --> 10  ³
³nPosUM         --> 11  ³
³nPosTipo       --> 12  ³
³nPosIcms       --> 13  ³
³nPosIpi        --> 14  ³
³nPosIss        --> 15  ³
³nPosCF         --> 16  ³
³nPosTabela     --> 17  ³
³nPosBsIcms     --> 18  ³
³nPosPrcTab     --> 19  ³
³nPosBsIpi      --> 20  ³
³nPosBsIss      --> 21  ³
³Situcao Tributo -> 22  ³
³nPosVend     ----> 23  ³
³cLoteCtl     ----> 24  ³
³cNlote       ----> 25  ³
³cLocaliz     ----> 26  ³
³cNserie      ----> 27  ³
³cBConta      ----> 28  ³
³nPosVlRat    ----> 29  ³
³nPosSubTrib  ----> 30  ³
|nPosBRSubTrib ---> 31  | 
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

//cSituacao:= Substr(cSituacao,1,1) + StrZero(nElemen,2)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array para acumular os itens para os calculos e grava‡oes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aItensVenda, { nItem, nQuant, Substr(cProduto,1,_TAMCPROD), nVlrTotItem, cDescrProd,;
nDescItem, nPerDesItem, nVlrUnit, cLocal, cTes, cUm, cTipo,;
nIcms, nIpi, nIss, cCF, If(lL220TabPad,ExecBlock("L220TABPAD",.F.,.F.,{Substr(cProduto,1,_TAMCPROD)}),cTabPad), nBsIcms, nVlrUnit, nBsIcms, nBsIcms, cSituacao, cVendLoja,;
cLoteCtl, cNLote, cLocaliz, cNSerie, cBConta, 0, nVlIcmRet, nVlBrIcmsRet  })

If LJ220AbISS()
	npValISS += LJ220VlISS(Len(aItensVenda))
EndIf

Aadd(aItensExc,{nItem,nItem,""})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa a tecla F6 para concessao de desconto no item ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lDescItem := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa a exclusao do item ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lExclui	 := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define que a venda ja pode ser fechada. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lFinaliza := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna a area anterior ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//RestArea(aArea)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria Log para Recuperacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLog4
	LjGrLogR(cOrcamen,aItensVenda,Len(aItensVenda))
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³L220ToolBa³ Autor ³ Vendas Clientes       ³ Data ³ 17/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra a Toolbar na tela de venda rapida.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³loja220                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function L220ToolBar(cCaixa,cOrcam,cNumSX8,cProduto,cDescrProd,;
cTmpProd,nVlrUnit,nQuant,nTmpQuant,nDescItem,nVlrTot,nPreco,;
nVlrTotItem,nAltura,nItem,nPerDesItem,oCaixa,oOrcam,oProduto,;
oDescrProd,oQuant,oVlrTot,oVlrUnit,oFotoImpre,oVlrTotItem,;
oTmpProd,oTmpQuant,oDlgRapid,cLocal,oX,oSimb1,oSimb2,oSimb3,;
nPassos,oFotoProd,nSaveSx8)

Local aButtons  := {}
Local aLJ220BU1 := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os botoes para a toolBar, o último parametro define a variável resumida para vis. MDI   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aButtons, {"POSCLI" 	, {|| Lj220Cliente(oDlgRapid)} 	, STR0060 , STR0139 })	// Escolhe Cliente...(F11)
AAdd(aButtons, {"SIMULACAO" , {|| fa100tran('SA6',,)    } 	, STR0123 , STR0140 })  // Sangria/Refor‡o de caixa...Ctrl+G

If lFiscal
	AAdd(aButtons,{ "EXCLUIR"  , {|| lj140Exc('SL1 ',,2) } , STR0122 , STR0141 }) 	// Cancelamento do cupom...Ctrl + F
EndIf 

If ExistBlock("LJ220BU1")
	aLJ220BU1 := ExecBlock( "LJ220BU1" )
	AAdd(aButtons,{ aLJ220BU1[1], aLJ220BU1[2], aLJ220BU1[3], Left(aLJ220BU1[3],8) })
EndIf

EnchoiceBar(oDlgRapid,{||MsgInfo(STR0061,STR0016)},{||If(LjConfExit( nSaveSx8 ),oDlgRapid:End(),.F.)},,aButtons)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj220ChkVe³ Autor ³ Vendas Clientes       ³ Data ³ 09/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica diversas atributos para liberar o acesso a venda   ³±±
±±³          ³para o caixa que esta tentando entrar na rotina de venda	  ³±±
±±³          ³R pida.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Exl1 - True ou False                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³loja220                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj220ChkVenda(lChkCXAber)
Local lRet := .T.
Local lAchouSX5  := .F.
Local lAchouSA6  := .T.
Default lChkCXAber := .T.			// Usado pelo Front Loja (Nao checar o CX, pois eh feito posteriormente)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for administrador nao deixa fazer a venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If __cUserID == "000000"
	
	// O administrador n„o poder  efetuar vendas. Utilize a op‡„o"
	// Senhas/Caixas no Menu Miscelƒnea para incluir um Caixa. Caso"
	// j  exista um cadastrado, re-entre no sistema com a senha de Caixa
	MsgInfo(STR0064 + STR0065 + STR0066)
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A ocorrencia 25 (ACS), verifica se o usu rio ³
//³ poder  ou n„o efetuar um Atendimento.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If !ChkPsw(25)
		lRet := .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usuario esta cadastrado como caixa. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	DbSelectArea( "SX5" )
	SX5->(DbSeek( xFilial("SX5") + "23" ))
	While SX5->(!Eof()) .AND. xFilial("SX5") == SX5->X5_FILIAL .AND.;
		SX5->X5_TABELA == "23"
		If Upper(Trim(X5Descri())) == Upper(Trim(cUserName))
			lAchouSx5 := .T.
			Exit
		EndIf
		SX5->( DBSkip() )
	End
EndIf
If lAchouSx5 .AND. lRet
	DbSelectArea( "SA6" )
	If !(SA6->(DbSeek( xFilial("SA6") + SubStr( SX5->X5_CHAVE, 1, 3 ) ) ) )
		lAchouSa6 := .F.
	EndIf
EndIf
If !lAchouSx5 .AND. lRet
	Help( " ", 1, "NOCAIXASX5" )
	lRet := .F.
EndIf
If !lAchouSA6 .AND. lRet
	Help( " ", 1, "NOCAIXASA6" )
	lRet := .F.
EndIf

If lChkCXAber.AND. lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Caixa esta Aberto. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ljCxAberto() .AND. lRet
		lRet := .F.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjConfExit³ Autor ³ Vendas Clientes       ³ Data ³ 11/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida a saida da rotina de venda.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³True ou False                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³loja220                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjConfExit( nSaveSx8 )
Local lRet			:= .T.

//Checando se a tela ja foi fechada
If oListFita == NIL
	Return .T.
Endif

// Deseja sair da rotina de Venda?
if CheckPaper(.F.)
	lRet := MsgYesNo(STR0067, STR0016)
else
	lRet := .T.
Endif

//Venda em andamento, a rotina n„o pode ser abandonada neste momento
If lFiscal .AND. Len(aItensVenda) > 0
	MsgStop(STR0078+STR0079) // Venda em andamento, a rotina n„o pode ser abandonada neste momento
	Return .F.
Endif

If lRet
	If __lSX8
		While (GetSX8Len() > nSaveSx8)
			RollBackSx8()
		End
	EndIf
	If cPaisLoc <> "BRA"
		aImps       := {}
		aImpVarSF2  := {}
		aImpVarSD2  := {0,0,0,0,0,{},''}
		aImpCusto   := {}
		aImpVarDup  := {}
		aCols       := {}
		aImpsTmp    := {}
		nValTotIV   := 0
		nValBaseIV  := 0
		nMoedaCor   := 1
		nDecimais   := MsDecimais(nMoedaCor)
		nImpsItDis  := 0
	Endif
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj220Din  ³ Autor ³ Vendas Clientes       ³ Data ³ 26/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela de negociacao de parcelas                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja220                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj220Din( aItens      ,nTotal    ,oFntFecha   ,nEntrada    ,;
				   nFinanciado ,oDlgFecha ,lNegociada  ,nVlrTot     ,;
				   lAltValor   ,aDadosPag ,nLinParc    ,lValidParc  ,;
				   lConfirma   )

Local n, i, nValAteP, nI, nPosParc := 0
Local nValAnt
Local oDlgLojaPag
Local oValor
Local oComboAdm
Local oComboPag
Local oComboMoed
Local oCheckPag
Local cComboAdm
Local cComboPag
Local cComboAnt
Local lSintVisu	   := If(SL4->(FieldPos("L4_FORMAID"))>0,.T.,.F.) 							//Indica se a interface utilizará a forma de visualização sintetizada ou a antiga, evitando problemas com a metodologia anterior
Local nLinha	   := If(lSintVisu .AND. Type("oPgtosAna")=="O",oPgtosAna:nAt,oPgtos:nAt) 	//Verifica a posição no aPgtos, pois provém de 2 objetos <>'s										
Local aMatriz	   := {}
Local aAdm_Back    := {}
Local aAdm		   := {}
Local aMultMoeda   := {}
Local lCheckPag    := .F.
Local dDataForm    := aPgtos[nLinha,1]
Local nValor	   := aPgtos[nLinha,2]
Local nParcAtu     := nLinha
Local lRet		   := .F.
Local nValAtu	   := nValor 											// Guarda o valor atual da parcela
Local nTam1        := 0
Local nTam2        := 0
Local nCol		   := 0
Local cMoedaTit    := ""
Local aTmpPgtos    := {}
Local lAParc       := LjProfile(9) 										// Verifica permissao de acesso do caixa Alterar dados da parcela
Local lDinheiro    := .F.
Local nPosMoeda1   := 0
Local lExpres      := (nTxJuros==0 .OR. cPaisLoc=="BRA" .OR. (nTxJuros>0 .AND. FunName(0)=="FRTA010"))
Local lParcelas    := .F. 												//Var de confirmacao de alteracao das parcelas
Local cFormas      := ""
Local cTipoVenda   := If(FunName()=="LOJA220","2","1")
Local lTefMult 	   := GetNewPar("MV_TEFMULT",.F.)			   			// Identifica se o cliente utiliza múltiplas transações TEF
Local cDigCart 	   := "" , oDigCart										// Dígitos do Cartão
Local lHabDig	   := If(lTefMult .AND. FunName()=="FRTA010",.T.,.F.)  // Identifica se solicita digitos do cartao
Local nLinDig      := 0					   								// Linha onde se começa as mudanças de posição por parâmetros					
Local nJanDig      := 0					   								// Aumento o tamanho da Dialog se for utilizar o TEF
Local nFor		   := 0													// Controle de laço	para atualização das datas de vecto
Local cCond		   := SE4->E4_CODIGO									// Codigo da condicao para recalculo
Local aDatas	   := {}                                                // Array com próximas condições de pagamento
Local cFormAtu	   := ""												// Guarda a forma de pagamento para recalculo das datas
Local cDigAtu	   := ""												// Guarda o digito para recalculo das datas
Local lUsaTroco    := (GetNewPar("MV_LJTROCO",.F.) .AND.  SL1->(FieldPos("L1_TROCO1"))>0  .AND. cPaisLoc == "BRA" .AND. lVendaRapida .AND. cTipoVenda <> "2")  // Determina se usa troco para diversas formas de pagamento
Local nPosPagto    := 0
Local nTmpValor    := 0                                                 // Valor da venda para calculo das parcelas

Private dDataEmis  := aPgtos[nLinha][1]								//Data de emissão da parcela
Private nParcAtual := aPgtos[nLinha][2] 							//Valor da parcela atual para utilizacao na funcao Lj010Fill

DEFAULT lAltValor  := .T.
DEFAULT aDadosPag  := {}
DEFAULT nLinParc   := 0

nLinha     := If(nLinParc > 0, nLinParc,nLinha)                   //Respeita a linha passada por parametro
dDataForm  := aPgtos[nLinha,1]
nValor	   := aPgtos[nLinha,2]
nParcAtu   := nLinha
nValAtu	   := nValor 											
dDataEmis  := aPgtos[nLinha][1]								
nParcAtual := aPgtos[nLinha][2] 								

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza a administradoras para cada forma ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to Len( aPgtos )
	Aadd( aAdm_Back, aPgtos[nI][4] )
Next nI

If IsMoney(aPgtos[nLinha,3])
	lDinheiro := .T.
	//Posicao do simbolo da moeda 1 para ser usada de forma generica para todas as moedas
	nPosMoeda1 := Ascan(aItens,{|aVal|AllTrim(aVal[2]) == AllTrim(SuperGetMv("MV_SIMB1"))})
EndIf

nPosParc := Ascan(aItens,{|aVal|AllTrim(aVal[2]) == AllTrim(aPgtos[nLinha,3])})

If !Empty(aPgtos)
	
	For n := 1 To Len(aItens)
		Aadd(aMatriz,aItens[n][1])
	Next n
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada para filtrar o array das formas de pagto. (combobox)³
	//³de acordo com as regras e politicas comerciais da empresa            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("LJ220FORMA")
		aMatriz := ExecBlock("LJ220FORMA",.F.,.F.,{aMatriz}) 
	Endif
		
	// Soma o Valor total at‚ a parcela inferiormente a clicada
	nValAteP := 0
	For i = 1 To nLinha-1
		nValAteP := nValAteP + Round(xMoeda(aPgtos[i][2],aPgtos[i][11],nMoedaCor,dDatabase,nDecimais+1,,nTaxaMoeda),nDecimais)
	Next i
	If lDinheiro .AND. nPosMoeda1 > 0
		cComboPag := aItens[nPosMoeda1,1]  //Para todas as moedas, mostra a descricao Dinheiro
	ElseIf nPosParc > 0
		cComboPag := aItens[nPosParc,1]
	endif
	cMoedaTit := SuperGetMv("MV_MOEDA"+Ltrim(Str(aPgtos[nLinha,11])))
	nValAnt	  := aPgtos[nLinha,2]
	cComboAnt := aPgtos[nLinha,3]
	dDataAnt  := aPgtos[nLinha,1]
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pr‚ carrega o array aAdm ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock ("LJ220ADM")
		aAdm := ExecBlock("LJ220ADM",.F.,.F.,) 
	Else
		DbSelectArea("SAE")
		DBSetOrder(1)
		DbSeek( xFilial("SAE") )
		aAdm := {}
		While !Eof() .AND. xFilial("SAE") == SAE->AE_FILIAL
			If Alltrim(SAE->AE_TIPO) == Alltrim(aPgtos[nParcAtu][3])
				Aadd( aAdm, SAE->AE_COD + " - " + SAE->AE_DESC )
			EndIf
			dbSkip()
		End
	EndIf
	
	//Caso nao exista nenhuma administradora financeira para a forma escolhida nao permite
	//a edicao da parcela.
	If !(IsMoney(cComboAnt) .OR. cComboAnt==cSimbCheq) .AND. Empty(aAdm)
		MsgStop(STR0131, STR0016)  //"Nao existe nenhuma administradora financeira cadastrada para a forma de pagamento escolhida."###"Atencao"
		Return(NIL)
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Administradora da forma atual ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cComboAdm := aAdm_Back[nParcAtu]
	
	// Verifica se o CheckBox "Utiliza nas próximas parcelas" vira marcado ou desmarcado
	lCheckPag := (AllTrim(aPgtos[nParcAtu][3]) $ SuperGetMv("MV_PRXPARC"))
	
	If Len(aMoeda) > 0  //Modificacao na tela para mostrar combo de Moedas(Localizacoes)
		nTam1  := 70
		nTam2  := 15
	EndIf
	
	aTmpPgtos := aClone(aPgtos)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o cliente utilizar multiplas transações TEF vou exibir os dígitos ou o ID Cartão³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lHabDig 
		If lSintVisu
		    cDigCart:= If(!Empty(aTmpPgtos[nParcAtu][12]),aTmpPgtos[nParcAtu][12],Space(TamSX3("L4_FORMAID")[1]))
		Else
		    cDigCart:= If(!Empty(aTmpPgtos[nParcAtu][12]),aTmpPgtos[nParcAtu][12],Space(04))
		EndIf			    
		nLinDig := 12
		nJanDig := 35
	EndIf

	DEFINE MSDIALOG oDlgLojaPag FROM  73,144 TO 275+nTam1+nJanDig,370 TITLE STR0077 OF oDlgFecha PIXEL // Parcelas

	@nCol,03 TO 90+nTam2+nLinDig,110 LABEL "" OF oDlgLojaPag PIXEL

	If cPaisLoc <> "BRA"

		dDataForm := aPgtos[nLinha,1]
		If Len(aPgtos[nLinha]) > 12
		   dDataEmis := aPgtos[nLinha,13]		   
        EndIf
		cFormas := cComboPag		
		If ExistBlock("LJ220VAL")
			cFormas := ExecBlock("LJ220VAL",.F.,.F.)
		EndIf

        //Conversao de valores
		@ 03,44 BUTTON STR0132 SIZE 60,12 ACTION (Lj010RetVConv(@cMoedaTit,@oComboMoed,@nValor,@oValor,aMoeda,@aMultMoeda,"FRONT",cTipoVenda)) OF oDlgLojaPag PIXEL 

		//Vencimento
		@ nCol+=15,06 	SAY STR0130 SIZE 30, 7 OF oDlgLojaPag PIXEL //Data
		@ nCol	  ,44 	MSGET dDataForm RIGHT Picture "99/99/99" SIZE 45,08 PIXEL OF oDlgLojaPag;
							VALID Lj010DtVcto(dDataEmis,dDataForm,cComboPag,oPgtos,@aPgtos);
							WHEN If(Alltrim(Upper(cComboPag)) $ Alltrim(Upper(cFormas)),.T.,.F.) 
		//Emissao
		@ nCol+=12, 06 	SAY STR0129 SIZE 21, 07 OF oDlgLojaPag PIXEL //Data contribuicao 
		@ nCol, 44 		MSGET dDataEmis RIGHT Picture "99/99/99" SIZE 45,08 PIXEL OF oDlgLojaPag;
							VALID Lj010DtEmis(dDataEmis,dDataForm,cComboPag,oPgtos,@aPgtos);
							WHEN If(Alltrim(Upper(cComboPag)) $ Alltrim(Upper(cFormas)),.T.,.F.) 
	Else
		@ nCol+=12, 06 	SAY STR0045 SIZE 16, 7 OF oDlgLojaPag PIXEL //Data
		@ nCol, 44 	MSGET dDataForm RIGHT Picture "99/99/99" SIZE 45,08 PIXEL When lAParc OF oDlgLojaPag Valid dDataForm >= dDataBase
	EndIf

	@ nCol+=15, 06 	SAY STR0046 SIZE 17, 7 OF oDlgLojaPag PIXEL //Valor
	@ ncol, 44	MSGET oValor VAR nValor RIGHT SIZE 55,08 Picture PesqPict("SL1","L1_VLRTOT");
				VALID(LjMsgVal(nValor,.F.) .AND. If(cPaisLoc == "BRA",((nValor+nValAteP)<=nTotal) .OR. ;
				     (lUsaTroco .AND. !lDinheiro),If(lValTot,Lj010ValP(nValor,nValAteP,nTotal,cMoedaTit),.T.))) ;
				PIXEL WHEN (lAParc .AND. lAltValor) OF oDlgLojaPag
	
	@ nCol+=15, 06 	SAY STR0071 SIZE 19, 7 OF oDlgLojaPag PIXEL // Forma

	If cPaisLoc == "BRA"
		@ nCol, 44 	MSCOMBOBOX oComboPag VAR cComboPag ITEMS aMatriz SIZE 61, 44 OF oDlgLojaPag PIXEL;
						WHEN lAParc;
						ON CHANGE (aAdm_Back[nParcAtu] := cComboAdm ,Lj010CbFor(oCheckPag,@lCheckPag,aMatriz,cComboPag,aItens))
	Else
		@ nCol, 044 MSCOMBOBOX oComboPag VAR cComboPag ITEMS aMatriz ;
			  			ON CHANGE (aAdm_Back[nParcAtu]:=cComboAdm);
						VALID Lj010CbFrm(cComboPag,oPgtos,@aPgtos,@dDataEmis,@dDataForm,aPgtos) ;
						OF oDlgLojaPag SIZE 61, 44 PIXEL
		@ nCol+=15,06 SAY STR0116 SIZE 22, 07 OF oDlgLojaPag PIXEL         //"Moeda"
		@ nCol,44 	MSCOMBOBOX oComboMoed VAR cMoedaTit ITEMS aMoeda SIZE 61, 44 OF oDlgLojaPag PIXEL
		nCol+=3		
	EndIf						
	
	@ nCol+=15, 06 	SAY STR0072 SIZE 36, 7 OF oDlgLojaPag PIXEL // Administradora
	@ nCol, 44 	MSCOMBOBOX oComboAdm VAR cComboAdm ITEMS aAdm SIZE 61, 44 OF oDlgLojaPag PIXEL;
					ON CHANGE aAdm_Back[nParcAtu] := cComboAdm

	If lHabDig
		If lSintVisu
			@ nCol+=15,06 SAY STR0146 PIXEL 							//"ID Cartão"
  		    @ nCol	  ,44 MSGET oDigCart VAR cDigCart SIZE 10,10 RIGHT PICTURE PesqPict("SL4","L4_FORMAID") OF oDlgLojaPag PIXEL ;
			   		      WHEN  L220WhenID( nLinha   ,cComboPag   ,@cDigCart   ,aItens   ,;
			   		                         .F.     ) ;
			   		      VALID L220ValiID(cComboPag,@cDigCart,aItens)
			oDigCart:cSx1Hlp:="L4_FORMAID"
		Else
			@ nCol+=15,06 SAY STR0145 PIXEL 							//"Dígitos Cartão"
		    @ nCol    ,44 MSGET oDigCart VAR cDigCart SIZE 10,10 RIGHT PICTURE "9999" OF oDlgLojaPag PIXEL
		EndIf
	EndIf

	//Utiliza nas pr¢ximas parcelas
	@ nCol+=15,06 CHECKBOX oCheckPag VAR lCheckPag PROMPT STR0073 SIZE 92,10 OF oDlgLojaPag PIXEL
	oCheckPag:oFont := oDlgLojaPag:oFont
			
	DEFINE SBUTTON FROM nCol+=18,48 TYPE 1 ACTION ;
	        (lConfirma  := .T.         ,;
			If(dDataForm >= dDataBase,;
				If(Lj010DtPag( cComboPag  ,nLinha     ,aItens   ,dDataForm  ,;
				                lCheckPag  ,lValidParc  ) .AND.;
				    Lj010DinV( @nValor   ,.T.    ,oDlgLojaPag  ,cComboPag  ,;
				               dDataForm )  ,;
					   		 (lParcelas := .T.)  ,;
					   		 (lParcelas := .F.) ) ,;
		    lParcelas := .F. )) ;
		    ENABLE OF oDlgLojaPag
	
	DEFINE SBUTTON FROM nCol,82 TYPE 2 ACTION ;
	        ( lConfirma  := .F. ,;
	          lParcelas  := .F. ,;
	          oDlgLojaPag:End() );
			ENABLE OF oDlgLojaPag
	
	//DINHEIRO
	ACTIVATE MSDIALOG oDlgLojaPag ON INIT (If(Len(aPgtos)>1,If(nParcAtu<>Len(aPgtos),If(Upper(cComboPag)==STR0074,oCheckPag:Disable(),),oCheckPag:Disable()),oCheckPag:Disable())) CENTERED

	//Chama novamente a validação do ID, caso o usuário não o informe
	If lHabDig .AND. lSintVisu 
		lParcelas := ( L220WhenID( nLinha    ,cComboPag   ,cDigCart   ,aItens   ,;
		                             .T.     ) .AND. ;
		                L220ValiID( cComboPag  ,cDigCart   ,aItens ) )
	EndIf

	If lParcelas
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada utilizado para nao aceitar a troca do tipo de uma    	 ³
		//³ determinada parcela seguindo as politicas e regras da empresa.			 |
		//³ Ex: 3x Financiado -> alterado 1a. parcela para dinheiro					 ³
		//³ 	Nao segue regra da empresa. 										 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock( "LJ220APARC" )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verificar antes de atualizar a variavel que contem a parcela selecionada se esta³
			//³no modo de visualizacao sintetizada ou normal.                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nParcela := If(lSintVisu .AND. Type("oPgtosAna")=="O",oPgtosAna:nAt,oPgtos:nAt)
			
			lRet := ExecBlock( "LJ220APARC", .F., .F., ;
								{ 	aPgtos, ;			//Array com todas as parcelas
									nParcela, ;			//Parcela atual
									dDataForm, ;		//Data da parcela
									nValor, ;			//Valor da parcela
									cComboPag, ;		//Tipo da parcela
									aMatriz, ;			//Array com todos os tipos de parcela
									cComboAdm, ;		//Administradora
									aAdm, ;				//Array com todas as administradoras
									lCheckPag } )		//Variavel 'Utiliza nas proximas parcelas'

			If !lRet
				Return
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o cliente utilizar multiplas transações TEF gravar o ID Cartão		     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lHabDig
			cFormAtu := aTmpPgtos[nParcAtu][3]
	   		For nFor := nParcAtu To Len(aPgtos)
				If cFormAtu == aTmpPgtos[nFor][3]
					aTmpPgtos[nFor][12]:=Alltrim(cDigCart)
				EndIf
			Next nFor
	   	EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recalcular datas de Vencimento para as próximas parcelas se houve alteração   ³
		//|quando escolhida uma forma de pagamento pré-cadastrada						 |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   	If !Empty(cCond) .AND. Len(aPgtos)>0 .AND. aTmpPgtos[nParcAtu][3] $ _FORMATEF .AND. aTmpPgtos[nParcAtu][1] <> dDataForm
	   		aDatas   := Condicao(nTotal,cCond,NIL,dDataForm,NIL,NIL,NIL,NIL)
			cFormAtu := aTmpPgtos[nParcAtu][3]
			cDigAtu  := aTmpPgtos[nParcAtu][12]
	   		For nFor := nParcAtu To Len(aPgtos)
				If Alltrim(cFormAtu) == Alltrim(aTmpPgtos[nFor][3]) .AND. Alltrim(cDigAtu) == Alltrim(aTmpPgtos[nFor][12])
					aTmpPgtos[nFor][1] := aDatas[nFor][1]
				EndIf
	   		Next nFor
	   	EndIf
        
		If lExpres
		   nTmpValor  := nVlrTot
		Else   
		   nTmpValor  := nVlrTot-aDadosJur[6]+aDadosJur[4]+aDadosJur[1]
		Endif   
		Lj010Fill( oComboPag   ,cComboPag ,aItens    ,dDataForm , ;
				   lCheckPag   ,nValor    ,@nEntrada ,NIL       ,;
				   @nFinanciado,NIL       ,cMoedaTit ,aTmpPgtos , ;
		           NIL         ,nTmpValor )
		
		If(cPaisLoc<>"BRA",If(Len(aPgtos[nLinha])>12,aPgtos[nLinha,13]:=dDataEmis,NIL),NIL)

        If Empty(aAdm_Back[nParcAtu])
           aAdm_Back[nParcAtu] := cComboAdm
        EndIf

		//Atualiza Administradora
		aPgtos[nParcAtu][4] := aAdm_Back[nParcAtu]

		//Atualiza identificação do Cartão
		If lHabDig
		   aPgtos[nParcAtu][12] := aTmpPgtos[nParcAtu][12]
		EndIf
		
		//Utiliza nas próximas parcelas, retirei a função LJ220ALL pois só era utilizada neste ponto do sistema
		If lCheckPag
	
			//Atualizando a forma de pagamento
			For nI := nParcAtu To Len( aAdm_Back )
				aAdm_Back[nI] := cComboAdm
			Next nI
			
			//Atualizando o aPgtos
			For nI := nParcAtu To Len(aPgtos)
				aPgtos[nI][4] := aAdm_Back[nI]
 			    aPgtos[nI][1] := aTmpPgtos[nI][1]			
				If lHabDig
				   aPgtos[nI][12] := aTmpPgtos[nI][12]
				EndIf
			Next nI

		EndIf

	EndIf

Else

	Help(" ",1,"SemDados")

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se alterou o valor para considera como cond negociada ³
//³ para efeito do recalculo no caso de desconto.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nValAtu <> nValor
	lNegociada := .T.
Else
	lNegociada := .F.
EndIf

nPosPagto  := Ascan(aItens,{|x| ALLTRIM(UPPER(x[1])) == ALLTRIM(UPPER(cComboPag))})

AADD(aDadosPag, dDataForm)
AADD(aDadosPag, nValor   )
If nPosPagto > 0
   AADD(aDadosPag, aItens[nPosPagto][2] )
Else 
   AADD(aDadosPag, SuperGetMv("MV_SIMB1") )
EndIf   
AADD(aDadosPag, cComboAdm)
AADD(aDadosPag, cDigCart) 

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj020ValAdm |     ³ Aline Correa do Vale  ³ Data ³ 25/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se foram digitadas as adm. p/ tipos CC/CO/VA/etc. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja220                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj020ValAdm()

Local i
For i := 1 to Len(aPgtos)
	If !IsMoney(aPgtos[i][3]) .AND. aPgtos[i][3] <> cSimbCheq .AND. ;
		Empty(aPgtos[i][4])
		// Escolha a Administradora Financeira
		MsgInfo(STR0075)
		Return(.F.)
	EndIf
Next
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj220Clien³ Autor ³ Vendas Clientes       ³ Data ³ 17.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chama o Cadastro de clientes e retorna o mesmo.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SigaLoja                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj220Cliente(oDlgRapid, lActDesact)
Local lRet := .T.
Local oDlgClie
Local cTmpCli
Local oCliTmp
Local cCliTmp := cCliente
Local cLojTmp := cLojaCli
Local oLojTmp
Local oButton2,oButton3
Local lj220Cli := ExistBlock("LJ220CLI")

Default lActDesact := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a venda já foi iniciada, nao permite a alteração do cliente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aItensVenda)
	Return .T.
Endif

// Este ponto de entrada substitui a tela de digitacao de Cliente
If ExistBlock("L220SCLI")
	aCliente := ExecBlock("L220SCLI",.F.,.F.,{cCliente,cLojaCli})
	// Retornar um array diferente de duas posicoes nao altera o cliente corrente
	If Len(aCliente) == 2
		cCliente := aCliente[1]
		cLojaCli  := aCliente[2]
	EndIf
Else
	
	If !Empty(cCliente)
		cCliTmp := cCliente
	Else
		If ExistBlock("LjCliPad")
			cTmpCli := ExecBlock("LjCliPad",.F.,.F.,)
			cCliTmp := Substr(cTmpCli,1,TamSx3("A1_COD")[1])
		Else
			cCliTmp := PadR(SuperGetMv("MV_CLIPAD"),TamSx3("A1_COD")[1])
		EndIf
	EndIf
	SA1->(DbSeek(xFilial("SA1")+cCliente+cLojacli))
	
	// Clientes
	
	DEFINE MSDIALOG oDlgClie FROM  47,130 TO 170,450 TITLE STR0069 PIXEL Of oDlgRapid
	
	@ 6, 04 BITMAP RESOURCE "CUSTOMER" OF oDlgClie PIXEL SIZE 32,32 ADJUST When .F. NOBORDER
	
	// Digite o cliente e loja
	@ 5, 040 TO 39, 155 LABEL STR0070 OF oDlgClie  PIXEL
	
	@ 20, 45 MSGET oCliTmp VAR cCliTmp SIZE 80,10 PIXEL;
	OF oDlgClie F3 "SA1" VALID lj010Clien(cCliTmp,cLojTmp,@cCliAnt,@cLojAnt,oLojTmp,"C",oDlgClie)
	
	@ 20, 130 MSGET oLojTmp VAR cLojTmp SIZE 20,10 PIXEL;
	OF oDlgClie VALID lj010Clien(cCliTmp,cLojTmp,@cCliAnt,@cLojAnt,oLojTmp,"L",oDlgClie)

    If cPaisLoc == "SAL"	  
	   @ 047,012 BUTTON STR0137 SIZE 30,14 ACTION Lj010RegFisc(cCliTmp,cLojTmp,oDlgClie) OF oDlgClie PIXEL  //"Reg.Fiscal"			   
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botoes para confirmacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE SBUTTON FROM 47, 65 oButton2 TYPE 1 ENABLE OF oDlgClie ;
	ACTION (lRet := .T.,oDlgClie:End()) PIXEL
	
	DEFINE SBUTTON FROM 47, 100 oButton3 TYPE 2 ENABLE OF oDlgClie ;
	ACTION (lRet := .F.,oDlgClie:End()) PIXEL
	
	ACTIVATE MSDIALOG oDlgClie CENTERED
	
	If lRet
		cCliente := cCliTmp
		cLojaCli  := cLojTmp
		
		If (cConfCli == "S")
			cTabPad:= If(Empty(SA1->A1_TABELA),SuperGetMv("MV_TABPAD"),SA1->A1_TABELA)
		Else
			cTabPad:= If(SuperGetMv("MV_TABPAD") $ "1ş2ş3ş4ş5ş6ş7ş8ş9",SuperGetMv("MV_TABPAD"),"1")
		EndIf
	EndIf
	
	If lj220cli
		Execblock("LJ220CLI",.F.,.F.)
	Endif
	
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Lj220Prod³ Autor ³ Vendas Clientes       ³ Data ³ 03/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida e Carrega as caracteristicas do produto.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 - Tudo Ok com o produto ou n„o.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja Windows                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj220Prod( oProduto, cProduto, nPreco, cDescrProd, nVlrUnit,;
oDescrProd, oVlrUnit, cTmpProd, oTmpProd, nQuant, oQuant, nVlrTotItem,;
oVlrTotItem, oFotoProd, cLocal,oDlgRapid,nDescItem,;
cLoteCtl,cNlote,cLocaliz,cNserie,cBConta,nVlrIpi)

Local lRet			:= .T.
Local aArea 		:= GetArea()
Local nI 			:= 0
Local cTes			:= ""
Local nElemFiscal	:= 0
Local nAliquota		:= 0
Local nBaseIpi		:= 0
Local lLocal		:= ExistBlock("LJ220LOC")
Local lValProd3		:= ExistBlock("VALPROD3")
Local aRetValProd3	:= {}
Local cTelesp		:=cTmpProd
Local nl     	 	:= 0
Local nTQuant 	 	:= 0
Local lTrcMoeda  	:= SuperGetMv("MV_TRCMOED")
Local nMoedaPrv  	:= 1
Local nVlrImpos     := 0
Local aRetCp     	:= {}
Local lLJSemPr 	    := SuperGetMv("MV_LJSEMPR")
Local lL220TabPad   := ExistBlock( "L220TABPAD" )
Local cTabPadBk     := ""

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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz a validacao do numero do cupom fiscal. Verifica se o numero jah existe ³
//³na base (para o caso de zerar a numeracao do ECF)                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aItensVenda) .AND. lFiscal 
	cNumCupFis := Space(10)
	iRet := IFPegCupom( nHdlECF, @cNumCupFis )
	If cPaisLoc == "BRA"
	   cSerie  := LjGetStation("SERIE")
	EndIf   
	SF2->(DBSetOrder(1))	// Filial + doc + serie + cliente + loja
	cNumCupFis := PadR( StrZero(Val(cNumCupFis)+1,Len(cNumCupFis)) , TamSx3("L1_NUMCFIS")[1] )	
	If SF2->(DbSeek(xFilial("SF2")+ cNumCupFis +cSerie))
		//"Atenção"# "O cupom fiscal "#" cSerie + " já existe na base de dados. Efetue a alteração no número de série no cadastro de estações. "#"Ok"
		Aviso(STR0133,STR0134 + StrZero(Val(cNumCupFis)+1,TamSx3("L1_NUMCFIS")[1],0) + " " + cSerie + STR0134, {STR0136} )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializado a variavel do codigo so produto para que qdo houver o refresh da tela não execute³
		//³a funcao 2x                                                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	cTmpProd   := Space(_TAMCPROD)
		Return(.F.)
	Endif
Endif

nVlrIpi := 0

If Localiza( cTmpProd )
	// "Este produto exige procedimentos de venda n„o dispon¡veis na Venda R pida. Utilize a Venda Balc„o."
	MsgStop(  STR0120  )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializado a variavel do codigo so produto para que qdo houver o refresh da tela não execute³
	//³a funcao 2x     te.                                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTmpProd   := Space(_TAMCPROD)
	Return( .F. )
EndIf

cQuant := nQuant
lRet := LJSB1SLK(@cTmpProd,@cQuant)
If lRet
	if ! nQuant == cQuant
		lQuant := .T.
		nQuant := cQuant
	EndIF
	lDescItem  := .T.
	cDescrProd := Capital(Substr(SB1->B1_DESC,1,23))
	cLocal	   := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
Else
	cDescrProd := Space(23)
	cProduto   := Space(_TAMCPROD)
	cTmpProd   := Space(_TAMCPROD)
	nPreco	  := 0.00
	nVlrUnit   := 0.00
	nVlrTotItem:= 0.00
	If lUsaFoto
		ShowBitMap(oFotoProd,"LOJAWIN")
	EndIf
	// Produto n„o Cadastrado
	MsgRun(STR0014,STR0016,{|| inkey(1)})
	oTmpProd:SetFocus()
	cTmpProd  := Space(_TAMCPROD)
	lDescItem := .F.
EndIf

If lLocal
	cLocal:=ExecBlock("LJ220LOC",.F.,.F.)
Endif

If lRet
	If !ExistBlock( "LJ220TS" )
		cTes := If(!Empty(RetFldProd(SB1->B1_COD,"B1_TS")),RetFldProd(SB1->B1_COD,"B1_TS"),SuperGetMv("MV_TESSAI"))
	Else
		cTes := ExecBlock( "LJ220TS" , .F., .F., {cTmpProd})
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa o TES no SF4 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SF4")
	DBSetOrder(1)
	If !DbSeek( XFilial("SF4") + cTes )
		// O Tipo de Entrada e Saida n„o esta cadastrado, entre em contato com o Administrador do Sistema
		// Aten‡Æo
		MsgStop(STR0015, STR0016)
		lRet := .F.
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso encontre o produto verifica o preco de venda do mesmo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTabPad := If(cTabPad$"1^2^3^4^5^6^7^8^9",cTabPad,"1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para atualizacao da tabela de preco desejada           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lL220TabPad      
	cTabPadBk := cTabPad
	cTabPad   := ExecBlock( "L220TABPAD", .F., .F., {SB1->B1_COD} )
EndIf

If lRet
	DbSelectArea("SB0")
	DBSetOrder(1)
	If !DbSeek( xFilial("SB0") + cTmpProd )   // Nao encontrou preco
		nPreco := 0.00
		If !lLJSemPr
			MsgStop( STR0127 ) // "Não é permitido vender um produto sem o preço de venda."
			lRet := .F.
		Else
  			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Nao permite vender produto sem preco nos estados AM, MG e SP³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If LjAnalisaLeg(2)[1]
			    LjMsgLeg(LjAnalisaLeg(2))
			    Help( " ", 1, "NOPRECO" )
			    lRet:=.F.
			Else
				lRet := .F.
			Endif
		Endif
		nVlrUnit := nPreco
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a tabela de preco padrao esta vazia, se esta ³
		//³ procura pelos outros precos caso estejam cadastrados.	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If &("SB0->B0_PRV" + cTabPad) == 0
			nPreco := 0.00
			If !lLJSemPr
				MsgStop( STR0127 ) // "Não é permitido vender um produto sem o preço de venda."
				lRet := .F.
			Else
	            If LjAnalisaLeg(2)[1]
				    LjMsgLeg(LjAnalisaLeg(2))
				    Help( " ", 1, "NOPRECO" )
				    lRet:=.F.
				Else
					lRet := .F.
				Endif
			Endif
		Else
			If &("SB0->B0_DATA" + cTabPad) >= dDataBase .OR. Empty(&("SB0->B0_DATA" + cTabPad))
				nPreco	:= &("SB0->B0_PRV"+cTabPad)
				If lTrcMoeda
					nMoedaPrv := If(SB0->&("B0_MOEDA" + cTabPad)==0,1,SB0->&("B0_MOEDA" + cTabPad))
					nVlrUnit  := Round(xMoeda(nPreco,nMoedaPrv,nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
					nPreco    := nVlrUnit
				Else
					nVlrUnit := nPreco
				EndIf
				lRet		:= .T.
			Else
				// Este pre‡o est  sem validade. Informe um supervisor para regularizar o pre‡o.
				// Aten‡Æo
				MsgStop(STR0019,STR0016)
				nPreco	:= 0.00
				nVlrUnit := nPreco
				lRet		:= .F.
			EndIf
		EndIf
	EndIf
	//Se a balanca trabalha por preco
	If SB1->B1_BALANCA == "1"
		cQuant:= NoRound( Val(cInfProBal) / 100 / nPreco,3)
		nQuant:= cQuant
	EndIf
EndIf

If ExistBlock("LJ220AltPrc")

	nPreco   := ExecBlock("LJ220AltPrc", .F., .F., { cTmpProd, nQuant, nPreco })
	nVlrUnit := nPreco

EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o B1_Tipo de Produto seja um Pagamento de Conta e ativada esta³
//³ funcao que efetua a leitura do codigo de Barras.                   ³
//³ Esta funcao esta dentro do LOJA22E.PRW                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SB1->B1_TIPO = "PC"
	cBConta:=Ler_Conta()
	if cBConta == ""
		RETURN(.F.)
	else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Armazema o valor da conta                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPreco := Val(Subs(cBConta,05,09)+'.'+Subs(cBConta,14,2))
		nVlrunit:= nPreco
	endif
Endif

If lValProd3
	aRetValProd3 := ExecBlock("VALPROD3",.F.,.F.,{cTelesp,nQuant})
	If Len(aRetValProd3) == 0
		lRet:=.F.
	ElseIf aRetValProd3[4]
		nPreco		 := aRetValProd3[1]
		nVlrunit 	 := nPreco
		AADD(aContas,{aRetValProd3[2],Len(aItensVenda)+1,nPreco}) // Telesp Celular
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe saldo em estoque para o produto se³
//³ nÆo for para funcionar com estoque negativo 		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTQuant := nQuant
If len(aItensVenda) > 0
	For nl:= 1 to len(aItensVenda)
		If cTmpProd == Substr(aItensVenda[nl][3],1,_TAMCPROD)
			nTQuant+=aItensVenda[nl][2]
		Endif
	Next nl
EndIf
If lRet 
	DbSelectArea("SF4")
	DbSeek(xFilial("SF4")+cTes)
	
	If SF4->F4_ESTOQUE == "S"
		DbSelectArea("SB2")
		DbSeek( xFilial("SB2") + cTmpProd + cLocal)                       

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifico se o produto está Disponivel ou Indisponivel no Estoque³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SldBlqSB2(cTmpProd,cLocal)
			If ( SuperGetMv("MV_ESTNEG") == "N" ) 
				DbSelectArea("SB2")
				If (Eof() .OR. SB2->B2_QATU < nTQuant)
					MsgInfo( AllTrim(cTmpProd) + " - " + AllTrim(cDescrProd ),STR0124)
					lRet := .F.
				EndIf
			EndIf
		Else     
			lRet := .F.	
		EndIf
	EndIf
		
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para calculo do IPI, ICMS e Substituicao Tri- ³
//³ butaria... 															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "BRA"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o produto tem IPI									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		If nPreco > 0
			If Upper(SF4->F4_IPI) == "S"  // Caso o produto tenha IPI calcula
				nBaseIpi:= nPreco * If(SF4->F4_BASEIPI > 0,SF4->F4_BASEIPI/100,1)
				nVlrIpi := ((nBaseIpi * SB1->B1_IPI) / 100)
				nPreco += nVlrIpi
			EndIf
		EndIf
	EndIf
	
	If lRet

		// Base Reduzida
		
		If SF4->F4_BASEICM > 0 .AND. SF4->F4_BASEICM < 100
			nAliquota := SB0->B0_ALIQRED
		EndIf
		
		If lFiscal
			If nAliquota > 0	 //Aliquota de Reducao de Icms
				nElemFiscal := 0
				For nI := 1 to Len(aIcms)
					If nAliquota = aIcms[nI][1]
						nElemFiscal := 1
						Exit
					EndIf
				Next nI
			EndIf
			
			DbSelectArea("SF4")
			DbSeek(xFilial("SF4")+cTes)
			
			If nElemFiscal == 0 .AND. SF4->F4_ICM == "S"
				
				//A al¡quota de Icms utilizada neste produto n„o est 
				//cadastrada na Impressora fiscal. utilize a op‡„o adiciona Aliquota
				//no menu Miscelƒnea, M¢dulo fiscal, para cadastr -la na Impressora.
				//a al¡quota n„o cadastrada ‚ :
				//Aten‡„o
				MsgStop(STR0020 +;
						STR0021 +;
						STR0022 +;
						STR0023 + Transform(If(SB0->B0_ALIQRED>0,SB0->B0_ALIQRED,nAliquota),"@E 99.99") + "%",;
						STR0016)
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			cProduto := cTmpProd
		EndIf
	EndIf
	
ElseIf cPaisLoc <> "BRA"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ C lculo de Impostos pelo Roteiro da Amarra‡Æo TesXImpostos. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCalcImpV == "S"
		
		SB1->( DBSetOrder(1) )
		SB1->( DbSeek( xFilial("SB1")+cTmpProd ) )
		
		cTes := If(!Empty(RetFldProd(SB1->B1_COD,"B1_TS")),RetFldProd(SB1->B1_COD,"B1_TS"),SuperGetMv("MV_TESSAI"))
		
		SF4->( DBSetOrder(1) )
		SF4->( DbSeek( xFilial("SF4")+cTes ) )
		If SF4->( ! Found() )
			//"O Tipo de Entrada e Saida nao esta cadastrado, entre em contato com o Administrador do Sistema"
			//"Atencao"
			MsgStop(STR0015, STR0016)
			lRet := .F.
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para Selecao da condicao de pagamento para seu ³
	//³possivel acrescimo no preco do produto                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("LJ220CP").AND.lRet
		aRetCp:=ExecBlock("LJ220CP",.F.,.F.,{cTmpProd,nQuant,nPreco})
		if Len(aRetCp)>0
			lRet          := aRetCp[1]
			nPreco        := aRetCp[2]
			nVlrunit 	 := nPreco
		EndIf
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ C lculo de Impostos pelo Roteiro da Amarra‡Æo TesXImpostos. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		Lj220ImpLoc(cTmpProd, lRet, @nQuant, @nPreco, @cProduto, @cQuant, nVlrTotItem,;
		nDescItem,cTes,@nVlrImpos,.T.,,nPreco)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso n„o passe em nenhuma validacao zera as veriaveis de status da tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRet
	cDescrProd := Space(23)
	cProduto   := Space(_TAMCPROD)
	cTmpProd   := Space(_TAMCPROD)
	nPreco	  := 0.00
	nVlrUnit   := 0.00
	nVlrTotItem:= 0.00
	
	If lUsaFoto
		ShowBitMap(oFotoProd,"LOJAWIN")
	EndIf
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso exista o ponto de entrada, retorno o backup do ponto atual         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lL220TabPad      
	cTabPad := cTabPadBk
EndIf

cTmpProd  := Space(_TAMCPROD)
oTmpProd  :Refresh()
oDescrProd:Refresh()
oProduto:Refresh()
oVlrUnit:Refresh()
oQuant:Refresh()
oVlrTotItem:Refresh()

RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³L220DescIt³ Autor ³ Vendas Clientes       ³ Data ³ 08/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Solicita a digita‡ao do desconto no item e o valida        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja Windows                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function L220DescItem(nDescItem,nVlrUnit,nVlrTotItem,oVlrUnit,;
oVlrTotItem,nPerDesItem,oPerDesItem,nQuant,oDescItem,;
cDescrProd, nAltura, nVlrTot, oVlrTot, nPassos,;
oDlgRapid, cTmpProd, oTmpProd)

Local oDlgDescItem
Local oButton2
Local oButton3
Local oTotalItem
Local oItem
Local oQuantAtu
Local oDescTmp
Local oDescPerTmp
Local nTotalItem	:= nVlrTotItem
Local nItem 		:= nVlrUnit
Local nQuantAtu		:= nQuant
Local nDescTmp 		:= 0.00
Local nDescPerTmp 	:= 0.00
Local lRet			:= .F.
Local nVlrTotAnt	:= nVlrTot
Local oFnt2
Local lLj220Pde		:= ExistBlock("LJ220PDE")
Local nRet
Local cRet			:= ' '
Local nDifer      	:= 0
Local nPAcolsVUni   := 0
Local nPAcolsVTot   := 0

If lLj220Pde
	If !ExecBlock("LJ220PDE",.F.,.F.)
		Return .F.
	Endif
Endif

if lFiscal
	nRet := IFStatus( nHdlECF, '7', @cRet )				// verifica se eh permitido desconto por item
	If nRet <> 0
		//Esta impressora nao permite desconto no item.
		//Utilize a opcao de Desconto no Total.
		msgInfo( STR0097 + STR0098 )
		Return .F.
	EndIf
Endif

DEFINE FONT oFnt2 NAME "TIMES NEW ROMAN" SIZE 11.5,22 BOLD

// Desconto no total do Item
DEFINE MSDIALOG oDlgDescItem FROM  47,130 TO 195,580 TITLE STR0024 PIXEL OF oDlgRapid
@ 6, 04 BITMAP RESOURCE "DISCOUNT" OF oDlgDescItem PIXEL SIZE 32,32 ADJUST When .F. NOBORDER
@ 04, 040 TO 28, 125 LABEL STR0025 OF oDlgDescItem	PIXEL // Valor/Percentual

@ 13, 45 MSGET oDescTmp VAR nDescTmp SIZE 40, 10 OF oDlgDescItem PICTURE PesqPict("SL2","L2_VALDESC")PIXEL ;
VALID LjMsgVal(nDescTmp,.T.) .AND. LJ010Nivel( 3, @nDescTmp, @oDescTmp );
WHEN IF( ExistBlock("LJDESCVR"), ExecBlock("LJDESCVR",.F.,.F.,{nDescPerTmp,nDescTmp,nVlrTot}), .T. )

@ 13, 90 MSGET oDescPerTmp VAR nDescPerTmp  SIZE 16, 10 OF oDlgDescItem PICTURE "@E 99.99" PIXEL;
VALID LjMsgVal(nDescPerTmp,.T.) .AND. LJ010Nivel( 4, @nDescPerTmp, @oDescPerTmp );
WHEN nDescTmp == 0 .AND. If( ExistBlock("LJDESCVR"), ExecBlock("LJDESCVR",.F.,.F.,{nDescPerTmp,nDescTmp,nVlrTot}), .T. )
oDescPerTmp:cSx1Hlp:="NDESCPERTM"

@ 04, 130 TO 28, 223 LABEL STR0026 OF oDlgDescItem	PIXEL // Pre‡o Unit rio

@ 10, 132 SAY oItem PROMPT nItem  OF oDlgDescItem SIZE 80, 10 PIXEL;
RIGHT COLOR CLR_HRED PICTURE PesqPict("SL2","L2_VALDESC") FONT oFnt2

@ 30, 040 TO 53, 125 LABEL STR0027 OF oDlgDescItem	PIXEL // Quantidade
@ 38, 042 SAY oQuantAtu PROMPT nQuantAtu  OF oDlgDescItem SIZE 80,10 PIXEL;
RIGHT COLOR CLR_BLUE PICTURE cPictL2Q FONT oFnt2

@ 30, 130 TO 53, 223 LABEL STR0028 OF oDlgDescItem	PIXEL // Total Item

@ 38, 132 SAY oTotalItem PROMPT nTotalItem	OF oDlgDescItem SIZE 80,10 PIXEL;
RIGHT COLOR CLR_BLUE PICTURE PesqPict("SL2","L2_VLRITEM",14)FONT oFnt2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botoes para confirmacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SBUTTON FROM 60, 145 oButton2 TYPE 1 ENABLE OF oDlgDescItem ;
ACTION (lRet:= .T.) PIXEL

DEFINE SBUTTON FROM 60, 180 oButton3 TYPE 2 ENABLE OF oDlgDescItem ;
ACTION (lRet := .F.,oDlgDescItem:End()) PIXEL

ACTIVATE MSDIALOG oDlgDescItem CENTERED

// MARISOL Lucas recibimento de parametro do oTmpProd para dar SetFocus
cTmpProd:= Space(_TAMCPROD)
oTmpProd:SetFocus()  //MARISOL LUCAS 09/08/99

If lRet .AND. nDescTmp > 0
	
	If lFiscal
		// Registra o desconto para o item
		nRet := IFRegItem( nHdlECF, '','','','',Str(nDescTmp,14,2), aItensVenda[Len(aItensVenda),22] )
		If L010AskImp(.F.,nRet)		
			nDescItem	:= 0.00
			nPerDesItem := 0.00
			nDescTmp    := 0.00
			Return (.F.)
		EndIf
	EndIf
	
	nDescItem	:= nDescTmp
	nPerDesItem := nDescPerTmp
	nVlrTotAnt	:= nVlrTot			// Valor Total Anterior
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza total da venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc == "BRA"
		nVlrTot -= ( nDescItem )
	Else
		nVlrTot -= nDifer
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza total unit rio ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrUnit := nVlrUnit - ( nDescItem /aItensVenda[Len(aItensVenda),nPosQuant])
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza total do item ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrTotItem := nTotalItem
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa refresh dos dados na tela ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oVlrUnit:Refresh()
	oVlrTot:Refresh()
	oVlrTotItem:Refresh()
	
	// Total Parcial Anterior -->
	// Desconto Item:
	// Valor liquido -->
	
	Aadd( aItensTela, STR0029 + Transform(nVlrTotAnt,PesqPict("SL2","L2_VLRITEM")))
	
	Aadd( aItensTela, STR0030 + Str(nDescPerTmp) + "%")
	
	Aadd( aItensTela, STR0031 + Transform(nVlrTotItem,PesqPict("SL2","L2_VLRITEM")))
	
	oListFita:SetItems( aItensTela )
	oListFita:GoBottom()
	oListFita:Refresh()
	
	aItensVenda[Len(aItensVenda),nPosVlrTot] := nVlrTotItem
	aItensVenda[Len(aItensVenda),nPosVlrUni] := nVlrUnit
	aItensVenda[Len(aItensVenda),nPosDesc]   := nDescItem
	aItensVenda[Len(aItensVenda),nPosPerDes] := nPerDesItem
	If cPaisLoc <> "BRA"
		nPAcolsVUni   := aScan( aHeader,{|x| Trim(x[2])=="L2_VRUNIT"})
		nPAcolsVTot   := aScan( aHeader,{|x| Trim(x[2])=="L2_VLRITEM"})		
		//Realiza o acerto do aCols
		aCols[Len(aCols)][nPAcolsVUni] := nVlrUnit
		aCols[Len(aCols)][nPAcolsVTot] := aItensVenda[Len(aItensVenda),nPosQuant] * nVlrUnit
	EndIf
EndIf

If lRet .AND. nDescTmp > 0
	lDescItem := .F.
EndIf

nDescItem	:= 0.00
nPerDesItem := 0.00

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj220Activ³ Autor ³ Vendas Clientes       ³ Data ³ 08/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ativa objetos na tela caso se tecla uma determinada tecla. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ ExpC1 - Tecla.                                             ³±±
±±³          ³ ExpU1 - Array com as vari veis locais para utilizacao 	  ³±±
±±³          ³ nas rotinas. ou o objeto para efetuar refresh.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja Windows                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj220Active(oTmpQuant)

oTmpQuant:Enable()
oTmpQuant:Refresh()
oTmpQuant:SetFocus()

oDlgRapid:bGotFocus := { || SetFocus(oTmpQuant:hWnd) }


Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ChgHora  ³ Autor ³ Vendas Clientes       ³ Data ³ 02/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Incrementa a Hora na Tela.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto da Hora                                     ³±±
±±³          ³ ExpC1 = Hora atual                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja Windows                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ChgHora(oHora,cHora)

cHora := Time()
oHora:Refresh()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj220Ativa³ Autor ³ Vendas Clientes       ³ Data ³ 22/03/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ativa tela de perguntas dos lancamentos contabeis          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := Lj220Ativa()                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Venda Rapida                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj220Ativa()

Local aArea	:=	GetArea()

Pergunte("LJA010",.T.)
lDigita   := (mv_par01==1)
lJunta    := (mv_par02==1)
lGeraLanc := (mv_par03==1)

RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Lj220ImpLoc³Autor ³Vendas Clientes     ³ Data ³  21/04/01   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Essa trecho de codigo foi retirado da funcao lj220Prod para ³±±
±±³          ³tbem ser utilizado quando se carrega uma venda rapida com   ³±±
±±³          ³um orcamento jah cadastrado.                                ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP5                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj220ImpLoc(cTmpProd, lRet, nQuant, nPreco, cProduto, cQuant,;
nVlrTotItem, nDescItem, cTes , nVlrImpos, lCriaaCols,;
nPosItemVenda,nPrecoTab)
Local nC
Local nPosCols := 0
Local nAliqImp := 0
Local aTesImpInf := {}
Local lImpTotal:= .F.
Local lCalcImp := .T.
Local lQuantidade := If(Type("lQuant")#"U",lQuant,.F.)

DEFAULT cTes 	   := Space(3)
DEFAULT nPrecoTab  := nPreco

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

nPosItemVenda := If(nPosItemVenda == NIL,0,nPosItemVenda)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ C lculo de Impostos pelo Roteiro da Amarra‡Æo TesXImpostos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cCalcImpV == "S"
		
	SB1->( DBSetOrder(1) )
	SB1->( DbSeek( xFilial("SB1")+cTmpProd ) )
	
	If Empty(cTes)
		cTes := If(!Empty(RetFldProd(SB1->B1_COD,"B1_TS")),Subs(RetFldProd(SB1->B1_COD,"B1_TS"),1,3),SuperGetMv("MV_TESSAI"))
	Endif
	
	SF4->( DBSetOrder(1) )
	SF4->( DbSeek( xFilial("SF4")+If(!Empty(RetFldProd(SB1->B1_COD,"B1_TS")),Subs(RetFldProd(SB1->B1_COD,"B1_TS"),1,3),cTes) ) )
	If SF4->( ! Found() )
		//"O Tipo de Entrada e Saida n„o esta cadastrado, entre em contato com o Administrador do Sistema"
		//"Aten‡„o"
		MsgStop(STR0015, STR0016)
		lRet := .F.
	EndIf
	
	If lRet
		If !lQuantidade
			nQuant := cQuant
		EndIf
		//Simular aCols
		If lCriaaCols
			Lj220SimaCols(SB1->B1_COD, nQuant, nPreco, SF4->F4_CODIGO)
			nPosItemVenda := If(nPosItemVenda==0,Len(aCols),nPosItemVenda)
		EndIf
		
		lImpTotal := .F.
		SFC->(DBSetOrder(1))
		SFC->(DbSeek(xFilial("SFC")+SF4->F4_CODIGO))
		While SFC->FC_FILIAL == xFilial("SFC") .AND. SFC->FC_TES == SF4->F4_CODIGO .AND. !lImpTotal
			If SFC->FC_CALCULO == "T"
				lImpTotal := .T.       //Ha um imposto que calcula sobre total
			EndIf
			SFC->(DbSkip())
		End
		
		If !lImpTotal
		    nValTotIV   := 0
			nVlrTotItem := ( nPreco * nQuant )
						
			aImpVarSD2[1] := nQuant
			aImpVarSD2[2] := nPreco
			aImpVarSD2[3] := nVlrTotItem
			aImpVarSD2[4] := 0.00
			aImpVarSD2[5] := 0.00
			aImpVarSD2[6] := {}
			If cPaisLoc == "COL"
				aImpVarSD2[7] := SA1->A1_CGC
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Disparar rotina para executar o RdMake do c lculo dos Impostos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CalcTesxIp( "S",nVlrTotItem,0,cTmpProd,nPosCols,nPosItemVenda,"RAPIDA",nDescItem,nTotalDesc)
			
			If lCriaaCols .OR. Len(aImps) < nPosItemVenda
				AADD(aImps, aClone(aImpVarSD2))
			Else
				aImps[nPosItemVenda] := aClone(aImpVarSD2)
			EndIf
			
			nVlrImpos := 0
			For nC := 1 To Len( aImpVarSD2[6] )
				If aImpVarSD2[6,nC,4] <> 0
					AAdd(aImpCusto,{aImpVarSD2[6,nC,1],aImpVarSD2[6,nC,2],;
					aImpVarSD2[6,nC,3],aImpVarSD2[6,nC,4],;
					aImpVarSD2[6,nC,5],aImpVarSD2[6,nC,11],;
					aImpVarSD2[6,nC,12]})
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula no "nPreco" os Impostos que Incidem no Total do   ³
					//³ Item...                                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SubStr(aImpVarSD2[6,nC,5],2,1 ) == "1"
						nVlrImpos += aImpVarSD2[6,nC,4]
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula em "nValorBase" os Impostos que Incidem no Valor  ³
					//³ Total Base da Duplicata...                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SubStr( aImpVarSD2[6,nC,5],1,1 ) == "1"
						AAdd(aImpVarDup,{aImpVarSD2[6,nC,1],aImpVarSD2[6,nC,4]})
					EndIf
				EndIf
			Next nC
			nImpsItDis   := nVlrImpos
			If cPaisLoc == "SAL"
			   lCalcImp    := SA1->A1_TIPO $ "1|2"   
			   aTesImpInf  := TesImpInf(SF4->F4_CODIGO)
			   //TES isento de imposto ou IVA 0%
			   If (Len(aTesImpInf) == 0 .OR. !lCalcImp .OR. Lj010ImpZero(aTesImpInf)) .AND.;
			      nPrecoTab > 0 
			      
                  SFB->(DBSetOrder(1))
                  If SFB->(DbSeek(xFilial("SFB")+"IVA"))
                     nAliqImp  := SFB->FB_ALIQ
                  EndIf
                  nPreco  := Round((nPreco/(1+(nAliqImp/100))),nDecimais)
			      nVlrTotItem := ( nPreco * nQuant )
			   EndIf
			EndIf			
		Else  //Calculo do imposto por total
		    nValTotIV   := 0
			nVlrTotItem := ( nPreco * nQuant )
			aImps := RoteiroCalc(nVlrTotItem,nDescItem)
			nVlrImpos := 0
			For nC := 1 To Len( aImps[nPosItemVenda][6] )
				If aImps[nPosItemVenda,6,nC,4] > 0.00
					If SubStr(aImps[nPosItemVenda,6,nC,5],2,1 ) == "1"
						nVlrImpos += aImps[nPosItemVenda,6,nC,4]
					EndIf
				EndIf
			Next nC
			nImpsItDis   := nVlrImpos
			nPreco 		-= nDescItem
		EndIf		
		If lCriaaCols
		   nValTotIV  += nVlrImpos
		EndIf   					
	EndIf
EndIf
cProduto := cTmpProd

Return( NIL )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Lj220SimaCols³Autor ³Vendas Clientes     ³ Data ³  17/10/01   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Simula o acols e aHeader para o calculo de impostos variaveis ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP5                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj220SimaCols(cProduto, nQuant, nPreco, cTes)

If Len(aHeader) == 0
	//Criar o aheader so com os campos necesarios para o calculo de impostos
	DbSelectArea("SX3")
	DBSetOrder(2)
	DbSeek("L2_PRODUTO")
	AADD(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
	x3_tamanho, x3_decimal, x3_valid,;
	x3_usado, x3_tipo, x3_arquivo, x3_context } )
	DbSeek("L2_TES")
	AADD(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
	x3_tamanho, x3_decimal, x3_valid,;
	x3_usado, x3_tipo, x3_arquivo, x3_context } )
	DbSeek("L2_CF")
	AADD(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
	x3_tamanho, x3_decimal, x3_valid,;
	x3_usado, x3_tipo, x3_arquivo, x3_context } )
	DbSeek("L2_QUANT")
	AADD(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
	x3_tamanho, x3_decimal, x3_valid,;
	x3_usado, x3_tipo, x3_arquivo, x3_context } )
	DbSeek("L2_VRUNIT")
	AADD(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
	x3_tamanho, x3_decimal, x3_valid,;
	x3_usado, x3_tipo, x3_arquivo, x3_context } )
	DbSeek("L2_VLRITEM")
	AADD(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
	x3_tamanho, x3_decimal, x3_valid,;
	x3_usado, x3_tipo, x3_arquivo, x3_context } )
	If DbSeek("L2_NIT")
		AADD(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
Endif

AAdd(aCols,Array(Len(aHeader)+1))
aCols[Len(aCols)][1]	:=	cProduto
aCols[Len(aCols)][2]	:=	cTes
aCols[Len(aCols)][3]	:=	SF4->F4_CF
aCols[Len(aCols)][4]	:=	nQuant
aCols[Len(aCols)][5]	:=	nPreco
aCols[Len(aCols)][6]	:=	nQuant * nPreco
If Len(aCols[Len(aCols)]) > 6
	aCols[Len(aCols)][7]	:=	""
EndIf
aCols[Len(aCols)][Len(aHeader)+1]	:=	.F.

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³lj220RollBºAutor  ³Vendas Clientes     º Data ³  09/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Utilizacao da funcao GetSx8Len para o controle do semaforo  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function lj220RollBackSx8( nSaveSx8 )

While (GetSx8Len() > nSaveSX8)
	RollBackSX8()
End

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LJ220Leg    ³Autor ³Vendas Clientes     ³ Data ³ 16/06/2004  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra a legenda dos orcamentos exibidos.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ220Leg
Local aLegenda := { {"BR_VERDE",	STR0138},;	// "Orçamentos em aberto"
					{"BR_VERMELHO",	STR0139},;	// "Vendas efetuadas"
					{"BR_PRETO",	STR0140},;	// "Orcamentos em aberto vencidos"
					{"BR_BRANCO",	STR0144} }	// "Transação TEF desfeita"
BrwLegenda(STR0143,STR0142,aLegenda)			// "Orcamentos", "Legenda"
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³L220WhenIDºAutora ³Vendas Clientes     º Data ³  11/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se é necessária a digitacao do digito de controle º±±
±±º          ³ de cartões                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpL1 = L220WhenID(ExpN2, ExpC3, ExpC4, ExpA5, ExpL6)      º±±
±±º			 ³ ExpL1 - Define se pode habilitar o ID do cartao            º±±
±±º			 ³ ExpN2 - linha corrente do array aPgtos            		  º±±
±±º			 ³ ExpC3 - Descricao da opcao selecionada em forma de pagto	  º±±
±±º			 ³ ExpC4 - Digito do cartao					  				  º±±
±±º			 ³ ExpA5 - Array com as formas de pagto e administradoras	  º±±
±±º			 ³ ExpL6 - Controla se a chamada desta funcao eh no When do   º±±
±±º			 ³ ID ou na confirmacao da modificacao. Se for o segundo caso,º±±
±±º			 ³ deve atualizar o aPgtos quando nao for TEF pois pode ter   º±±
±±º			 ³ selecionado a administradora financeira para as formas de  º±±
±±º			 ³ pagamento FI, VA etc.									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                           
Static Function L220WhenID( nLinha     ,cComboPag   ,cDigCart   ,aItens   ,;
                            lAtuPagtos )
Local lRet 		:= .F.
Local nPos 		:= Ascan(aItens,{|x| Alltrim(Upper(x[1]))==Alltrim(Upper(cComboPag))})

If nPos > 0
	If Alltrim(Upper(aItens[nPos][2]))$_FORMATEF
		If !Empty(aPgtos[nLinha][12])  	//Se o item já possui uma identificação não permitir alterar no oPgtos
		    cDigCart  := aPgtos[nLinha][12]
		    lRet := .F.
		Else
			lRet := .T.
		EndIf			    
	Else
		cDigCart := Space(TamSX3("L4_FORMAID")[1])
		lRet     := lAtuPagtos
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³L220ValiIDºAutora ³Vendas Clientes     º Data ³  11/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se o dígito informado é correto para o controle de  º±±
±±º          ³ múltiplos cartões                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                           
Static Function L220ValiID(cComboPag,cDigCart,aItens)
Local lRet 	 := .T.
Local nPos 	 := Ascan(aItens,{|x| Alltrim(Upper(x[1]))==Alltrim(Upper(cComboPag))})
Local cCond  := If(nPos>0,Alltrim(Upper(aItens[nPos][2])),Space(02))

If cCond $ _FORMATEF
	If Empty(cDigCart)
		MsgAlert(STR0147,STR0016) //"Informe o ID do Cartão para a operação TEF.","Atenção"
		lRet := .F.
	ElseIf Ascan( aPgtos, {|x| Alltrim(x[3])==cCond .AND. Alltrim(x[12])==Alltrim(cDigCart) } ) > 0 
		MsgAlert(STR0148,STR0016) //"Cartão já informado para a operação TEF, utilize uma nova identificação.","Atenção")
		lRet := .F.
	EndIf
EndIf

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Função    ³ LJ220AbISS  ³ Autor ³Vendas Clientes     ³ Data ³ 09/12/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descrição ³ Faz a verificação se o valor do ISS deve ser abatido no      ³±±
±±³           ³ valor total da venda.                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ220AbISS(cCondPgto, cFormaPg, nVlrTotISS)
Local lRet := LjxDAbISS(cCondPgto, cFormaPg, nVlrTotISS)
//ATENCAO!!!!
//As funções LJ220AbISS e LjxDAbISS faziam exatamente a mesma coisa, eram funções idênticas, por isso
//que é chamada a função LjxDAbISS aqui dentro.
//A ideia é futuramente, trocar todas as chamadas da função LJ220AbISS pela função LjxDAbISS, e assim
//possibilitar eliminar de vez a função LJ220AbISS quando ela não for chamada por mais nenhum lugar.
Return lRet

	
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Função    ³ LJ220VlISS  ³ Autor ³Vendas Clientes     ³ Data ³ 09/12/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descrição ³ Faz o cálculo do ISS e preenche o array de itens da venda.   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ220VlISS(nPos)
Local nAliqISS := 0
Local nBaseISS := 0
Local nReturn  := 0

Default nPos := 0

If nPos == 0

	aEval(aItensVenda, { |x,y| nReturn += LJ220VlISS(y) })

Else

	SB1->(DBSetOrder(1))
	SB1->(DbSeek(xFilial("SB1") + aItensVenda[nPos][03]))   //-- Produto
	
	SF4->(DBSetOrder(1))
	SF4->(DbSeek(xFilial("SF4") + aItensVenda[nPos][10]))   //-- TES
	
	If Upper(SF4->F4_ISS) == "S"
	
		nAliqISS := If( SB1->B1_ALIQISS > 0, SB1->B1_ALIQISS, SuperGetMv("MV_ALIQISS") )
		nBaseISS := aItensVenda[nPos][04]   //-- Valor Total Item
	
		aItensVenda[nPos][21] := nBaseISS	//-- Base de ISS
	
		nReturn := aItensVenda[nPos][15] := NoRound(( ( nBaseISS * nAliqISS ) / 100 ), 2)   //-- Valor do ISS
	
	EndIf

EndIf
	
Return nReturn
