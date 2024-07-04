#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJC130.CH"
#INCLUDE "DEFMOVCAIXA.CH"

Static oSaldFinal
Static oTrocoSaida
Static oTotCre
Static oTotDeb
Static oTroco
Static lLjcFid	:= SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt() 			//Indica se a recarga de cartao fidelidade esta ativa
Static cTxtRecCel	:= "RECARGA DE CELULAR"

//------------------------------------------------------------------
/*/{Protheus.doc} LOJC130()
Resumo de Caixa 2.0
@type Functoin

@author Marcos Iurato Junior
@since 09/09/2019
@version P12.1.25

@return nil, nil, retorno nil
/*/
//------------------------------------------------------------------
Function LOJC130()
Local oDlg											// Objeto
Local oFnt											// Fonte
Local oFnt2											// Fonte 2
Local oGroup										// Grupo de impressao
Local lMV_LJTROCO   := SuperGetMv("MV_LJTROCO") 	// Determina se utiliza troco para diferentes formas de Pagamento												
Local nTrocoSaida 									// Somatoria dos trocos de saida						
Local aCaixa										// Array com os valores do caixa
Local nTroco                                 		// Valor da entrada de troco
Local nTotCredito                            		// Total de creditos
Local nTotDebito                             		// Total de debitos
Local nSaldFinal                             		// Saldo final do Caixa
Local nEstac                                 		// Valor referente ao estacionamento (restaurante)
Local nGorjeta                               		// Valor referente a gorjeta (restaurante)
Local nVlrCred  	:= 0                         	// Valor do credito utilizado na compensacao da NCC
Local nDevDin										// Valor total das devoluções a dinheiro
Local oMovVen										// Movimento da venda
Local oMovSan										// Movimento
Local aDadosVen 	:= {{"","","",""}} 
Local aDadosSan 	:= {{"","","",""}}				// Arrays - 1)Descricao 2)Valor 3)Qtde Finalizações
Local aSinal  		:= { "+", "+", "+", "+",;		// Array com as sinais realizados
						 "+", "+", "+", "+", ;
						 "+", "+" }	
Local aDDown  		:= Array( 16 )  	 			// Contem o 2o. nivel das opcoes: Cartao de Credito, Vales, Convenio, Financiado, Cartao de Debito e Devolucao , Estorno
Local aContFina 	:= { 0 , 0 , 0 , 0 , ;
                    	 0 , 0 , 0 , 0 , ;
						 0 , 0 , 0 , 0 }   			// Contadores utilizados nos tipos de finalizações
Local aLacAnalitico := {}							// Array com todos os lancamentos processados gerados de valores
Local lSomaCred 	:= .T.             				// Controla se considera o credito de venda, valor da NCC gerada e o utilizado na compensacao da NCC, no totalizador
Local lUsaNMov  	:= .F.							// Verifica se foi criado MV_PAR09
Local aSize1 		:= MsAdvSize()					// Tamanho da tela
Local aObjects		:= {}
Local aInfo         := {}
Local aPosObj       := {}
Local _oDataDe
Local dDataDe   	:= date() 
Local _oGetDatDe
Local _oDataAte
Local _oGetDatAte
Local dDataAte   	:= date() 
Local _oFont  		:= TFont():New("Courier New",,016,,.F.,,,,,.F.,.F.)
Local oOk 			:= LoadBitmap( GetResources(), "LBOK")	// Botão 01
Local oNo 			:= LoadBitmap( GetResources(), "LBNO")	// Botão 02
Local aBkWBrowse1   := {}
Local oOkCx 		:= LoadBitmap( GetResources(), "LBOK")	// Botão 01
Local oNoCx 		:= LoadBitmap( GetResources(), "LBNO")	// Botão 02
Local aBkWBrowCx    := {}
Local oWBrowseCx	:= Nil										
Local aWBrowseCx 	:= {}
Local oWBrowseFil	:= Nil										
Local aWBrowseFil 	:= {}
Local aVerifVenda	:= {{"","","","", ""}}
Local oMovVenLan
Local aAnalitLanc	:= {{"","","","","","","","" }}
Local aDetSangria	:= {}
Local aRecCelular	:= {}
Local aEstRec		:= Array(P_MAXDEFINE)
Local oAllBranch
Local oAllCashier
Local oConsCredi
Local lAllBranch	:= .F.
Local lAllCashier	:= .F.

// Protege rotina para que seja usada apenas pelos módulos: 12=SIGALOJA, 23=Front Loja, 51=Gestão Hospitalar, 5=Faturamento
If !AmIIn(12,23,51,5)
	Return(NIL)
EndIf

AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo       := { aSize1[ 1 ], aSize1[ 2 ], aSize1[ 3 ], aSize1[ 4 ], 0, 0 }
aPosObj     := MsObjSize( aInfo, aObjects)

LJMsgRun(STR0062,,{||FindCash(@aWBrowseFil,@aWBrowseCx)}) // Aguarde...abrindo a tela de consulta

If Len(aWBrowseFil) <> 0 .And. Len(aWBrowseCx) <> 0

	// Resumo de Caixa
	DEFINE MSDIALOG oDlg FROM 0.1,0.1 TO aSize1[6],aSize1[5] TITLE STR0001 PIXEL OF oMainWnd  
	
	// Largura x Altura
	DEFINE FONT oFnt	NAME "TIMES NEW ROMAN" SIZE C(14),C(18) BOLD  
	DEFINE FONT oFnt2	NAME "Arial" BOLD

	@ C(001), C(004) TO C(349), C(137) LABEL "" OF oDlg  PIXEL
	
	//Data de
	@ C(006), C(007) SAY _oDataDe     	PROMPT STR0035 SIZE C(080), C(010) OF oDlg FONT _oFont  COLORS 0, 16777215  PIXEL
	@ C(017), C(007) MSGET _oGetDatDe 	VAR dDataDe 		 SIZE C(060), C(010) OF oDlg   COLORS 0, 16777215  PIXEL
	
	//Data ate
	@ C(006), C(073) SAY _oDataAte     	PROMPT STR0036 SIZE C(080), C(010) OF oDlg FONT _oFont  COLORS 0, 16777215  PIXEL
	@ C(017), C(073) MSGET _oGetDatAte 	VAR dDataAte 		 SIZE C(060), C(010) OF oDlg   COLORS 0, 16777215  PIXEL Valid ValDate(dDataDe,dDataAte)
	
	aBkWBrowse1 := aClone(aWBrowseFil)
	@ C(035),C(009) LISTBOX oWBrowseFil Fields HEADER "", STR0037, STR0038 SIZE C(125), C(100) OF oDlg PIXEL ColSizes 30,30,30 // Código ### Filial
	oWBrowseFil:SetArray(aWBrowseFil)
	oWBrowseFil:bLine := {||{;
	If(	aWBrowseFil[oWBrowseFil:nAT,1],oOk,oNo),;
		aWBrowseFil[oWBrowseFil:nAT,2],;
		aWBrowseFil[oWBrowseFil:nAT,3],;		
		}}
	    
	oWBrowseFil:bLDblClick := {|| aWBrowseFil[oWBrowseFil:nAt,1] := !aWBrowseFil[oWBrowseFil:nAt,1],;
	oWBrowseFil:DrawSelect()}
	
	@ C(138),C(009) CHECKBOX oAllBranch VAR lAllBranch PROMPT STR0056 SIZE C(80), C(8) PIXEL OF oDlg; //"Selecionar todas as filiais"
	ON CHANGE {|| aEval(aWBrowseFil,{|x| x[1]:= lAllBranch }),oWBrowseFil:Refresh() }

	//----------------
	
	aBkWBrowCx := aClone(aWBrowseCx)
	
	@ C(151),C(009) LISTBOX oWBrowseCx Fields HEADER "",STR0039, STR0040 SIZE C(125), C(120) OF oDlg PIXEL ColSizes 30,30,30 //Caixa ### Descrição
	oWBrowseCx:SetArray(aWBrowseCx)
	oWBrowseCx:bLine := {||{;
	If(	aWBrowseCx[oWBrowseCx:nAT,1],oOkCx,oNoCx),;
		aWBrowseCx[oWBrowseCx:nAT,2],;
		aWBrowseCx[oWBrowseCx:nAT,3],;		
		}}
	    
	oWBrowseCx:bLDblClick := {|| aWBrowseCx[oWBrowseCx:nAt,1] := !aWBrowseCx[oWBrowseCx:nAt,1],;
	oWBrowseCx:DrawSelect()}
	
	@ C(274),C(009) CHECKBOX oAllCashier VAR lAllCashier PROMPT STR0057 SIZE C(80), C(8) PIXEL OF oDlg; //"Selecionar todos os caixas"
	ON CHANGE {|| aEval(aWBrowseCx,{|x| x[1]:= lAllCashier }),oWBrowseCx:Refresh() }

	@ C(284),C(009) CHECKBOX oConsCredi VAR lSomaCred PROMPT STR0085 SIZE C(110), C(8) PIXEL OF oDlg //"Cons. cred. venda no total"
	oConsCredi:cToolTip := STR0086 //"Indica se deve somar o crédito de venda no totalizador de crédito"

	//----------------
	// Processar
	@ C(30.0), C(004) 	BUTTON STR0055 SIZE C(80),C(15) FONT oDlg:oFont ACTION 	LJMsgRun(STR0028,,{||LjC130Proces(	dDataDe	,	dDataAte	,	aWBrowseFil		,	aWBrowseCx	,;
																														@lMV_LJTROCO,	@aDDown		,	@aContFina 		, 	@nVlrCred	,;
																														@lSomaCred  , 	@lUsaNmov 	,	@aLacAnalitico	, 	@nTrocoSaida,;
							    																						@nTroco		, 	@nTotCredito, 	@nTotDebito		, 	@nSaldFinal	,;
							    																						@nEstac		, 	@nGorjeta	, 	@aDadosVen		, 	@aSinal		,;
							    																						@aDadosSan	,	@oMovVen	,	@oMovSan		,	@aDetSangria,;
							    																						@oMovVenDet	, 	@oMovVenLan,	@aAnalitLanc	,	@aVerifVenda,;
																														@aRecCelular,	@nDevDin	,	@aEstRec )})
	//----------------
	// Creditos(Vendas)
	@ C(012), C(145) LISTBOX oMovVen FIELDS  HEADER STR0041, STR0042, STR0043 SIZE C(280), C(140) OF oDlg PIXEL ColSizes 60,5,10 //Finalizadora ### Valor total ### Qtd.Docs
		@ C(002), C(141) GROUP oGroup TO C(160), C(430) LABEL  STR0002  OF oDlg PIXEL  
		oGroup:SetFont(oFnt2)
	
		oMovVen:SetArray(aDadosVen)
		oMovVen:bLine := {|| { aDadosVen[oMovVen:nAt][1],aDadosVen[oMovVen:nAt][2],aDadosVen[oMovVen:nAt][3] }}
	
		oMovVen:bLDblClick := {|| VenDet(oMovVen,aDDown,@aVerifVenda,@oMovVenDet,@aAnalitLanc,@oMovVenLan,aLacAnalitico)}
		oMovVen:Refresh()
	
	//----------------
	// Detalhes do Credito (Vendas)
	@ C(170), C(145) LISTBOX oMovVenDet FIELDS  HEADER STR0044, STR0042, STR0043 SIZE C(280), C(122) OF oDlg PIXEL ColSizes 30,60,10 //Forma de Pgto ### Valor Total ### Qtd.Docs
		@ C(160), C(141) GROUP oGroup TO C(295), C(430) LABEL STR0045 OF oDlg PIXEL  //Detalhes dos Créditos (Vendas)
		oGroup:SetFont(oFnt2)
		oMovVenDet:SetArray(aVerifVenda)
		oMovVenDet:bLine := {|| { aVerifVenda[oMovVenDet:nAt][1],aVerifVenda[oMovVenDet:nAt][2],aVerifVenda[oMovVenDet:nAt][4] }}
		oMovVenDet:Refresh()
	
	//----------------
	// Debito (Sangria)
	@ C(012), C(440) LISTBOX oMovSan FIELDS  HEADER STR0041, STR0042, STR0046 SIZE C(290), C(140) OF oDlg PIXEL ColSizes 30,60,10 //Finalizadora ### Valor total ### Saldo
		@ C(002), C(435) GROUP oGroup TO C(160), C(735) LABEL  STR0003  OF oDlg PIXEL  
		oGroup:SetFont(oFnt2)
		oMovSan:SetArray(aDadosSan)
		oMovSan:bLine := {|| { aDadosSan[oMovSan:nAt][1],aDadosSan[oMovSan:nAt][2],aDadosSan[oMovSan:nAt][4]}}
		oMovSan:bLDblClick := {|| SangDet(oMovSan,aDetSangria,@oMovVenLan,@aAnalitLanc)}
		oMovSan:Refresh()

	// Lançamento Analitico
	// Orçamento ### Operador ### Data ### Valor ### Forma ### Adminis\Banco ### Autoriz.\Ag. ### NSU\Conta
	@ C(170), C(440) LISTBOX oMovVenLan FIELDS  HEADER STR0047, STR0048, STR0049, STR0050, STR0051, STR0052, STR0053, STR0054 SIZE C(290), C(122) OF oDlg PIXEL ColSizes 30,60,10 
			
		@ C(160), C(435) GROUP oGroup TO C(295), C(735) LABEL STR0060 OF oDlg PIXEL  //Lançamentos Analítico
		oGroup:SetFont(oFnt2)
	
		oMovVenLan:SetArray(aAnalitLanc)
		oMovVenLan:bLine := {|| { 	aAnalitLanc[oMovVenLan:nAt][1],aAnalitLanc[oMovVenLan:nAt][2],aAnalitLanc[oMovVenLan:nAt][3],;
									aAnalitLanc[oMovVenLan:nAt][4],aAnalitLanc[oMovVenLan:nAt][5],aAnalitLanc[oMovVenLan:nAt][6],;
									aAnalitLanc[oMovVenLan:nAt][7],aAnalitLanc[oMovVenLan:nAt][8]}}
		oMovVenLan:Refresh()

	//----------------
    //Imprimir
	@ C(32.0), C(004) BUTTON STR0016 SIZE C(80),C(15) FONT oDlg:oFont ;
			  ACTION LJ130imp(	lMV_LJTROCO	,nTrocoSaida, aCaixa		,nTroco		,;
								nTotCredito	,nTotDebito	, nSaldFinal 	,aDadosVen	,;
								aDadosSan	,dDataDe	, dDataAte		,aWBrowseFil,;
								aWBrowseCx	, aDDown	) OF oDlg 		// Botão de Imprimir
	
	//----------------
	//Total de Credito
	@ C(300), C(141) GROUP oGroup TO C(325), C(430) LABEL STR0012 OF oDlg PIXEL  
	oGroup:SetFont(oFnt2)
	@ C(313), C(159) SAY oTotCre PROMPT nTotCredito SIZE C(80), C(10) OF oDlg;
		PIXEL RIGHT FONT oFnt COLOR CLR_HRED PICTURE "@E 999,999,999.99"
	
	// Total de Debitos
	@ C(300), C(435) GROUP oGroup TO C(325), C(735) LABEL STR0014 OF oDlg PIXEL
	oGroup:SetFont(oFnt2)
	@ C(313), C(449) SAY oTotDeb PROMPT nTotDebito SIZE C(80), C(10) OF oDlg;
		PIXEL RIGHT FONT oFnt COLOR CLR_HRED PICTURE "@E 999,999,999.99"
	
	// Saldo Inicial
	@ C(325), C(141) GROUP oGroup TO C(349), C(430) LABEL STR0004 OF oDlg PIXEL  
	oGroup:SetFont(oFnt2)
	@ C(337), C(159) SAY oTroco VAR nTroco SIZE C(80), C(10) OF oDlg PIXEL RIGHT FONT oFnt;
		COLOR CLR_HRED PICTURE "@E 999,999,999.99"
	
	If lMV_LJTROCO	
		// Troco Saida
		@ C(325), C(435) GROUP oGroup TO C(349), C(735)  LABEL STR0080 OF oDlg PIXEL //"Troco Saida"
		oGroup:SetFont(oFnt2)
		@ C(337), C(449)  SAY oTrocoSaida PROMPT nTrocoSaida SIZE C(80), C(10) OF oDlg;
		PIXEL RIGHT FONT oFnt COLOR CLR_HRED PICTURE "@E 999,999,999.99"

		// Saldo Final
		@ C(348), C(435) GROUP oGroup TO C(370), C(735) LABEL STR0015 OF oDlg PIXEL // "Saldo Final"
		oGroup:SetFont(oFnt2)
		@ C(358), C(449) SAY oSaldFinal PROMPT nSaldFinal SIZE C(80), C(10) OF oDlg;
		PIXEL RIGHT FONT oFnt COLOR CLR_HRED PICTURE "@E 999,999,999.99"
	Else
		// Saldo Final
		@ C(325), C(435) GROUP oGroup TO C(349), C(735) LABEL STR0015 OF oDlg PIXEL // "Saldo Final"
		oGroup:SetFont(oFnt2)
		@ C(337), C(449) SAY oSaldFinal PROMPT nSaldFinal SIZE C(80), C(10) OF oDlg;
		PIXEL RIGHT FONT oFnt COLOR CLR_HRED PICTURE "@E 999,999,999.99"
	Endif

	ACTIVATE MSDIALOG oDlg 



Else
	MsgStop(STR0059)  //Não existem empresas ou caixas associados ao seu usuário. Por favor, procure o administrador do sistema para regularizar.
EndIf

DbSelectArea("SL1")
DbSetOrder(1)

Return(NIL)

//------------------------------------------------------------------
/*/{Protheus.doc} MovimCaixa()
Carrega array com valores totais do caixa em uma data
@type function

@author Marcos Iurato Junior
@since 09/09/2019
@version P12.1.25

@param cCaixa, carácter, Numero do caixa
@param dDataMovto, data, Data do movimento
@param lMV_LJTROCO, lógico, Determina se utiliza troco p/ diferentes formas
@param aDDown, array, Array com o segundo nivel das opcoes
@param aContFina, array, Array utilizado nos tipos de finalizadores 
@param nVlrCred, array, Valor do credito utilizado na compensacao do NCC
@param lSomaCred, lógico, Verifica se considera o credito da venda no totalizador de credito
@param lUsaNmov, lógico, Verifica se foi criado MV_PAR09
@param aLacAnalitico, array, Array com os laçamentos analiticos
@param cRetFil, carácter, Filiais selecionadas
@param cRetCx, carácter, Caixas selecionados
@param dDataDe, data, Data de
@param dDataAte, data, Data até
@param aDetSangria, array, Detalhamento da sangria
@param aRecCelular, array, detalhamento das recargasa de celular.
@param nDevDin, numérico, Valor total de devoluções a dinheiro
@param aEstRec, array, valor dos estornos de recebimentos
@return, array, Caixas envolvidos na operação
/*/
//------------------------------------------------------------------
Static Function MovimCaixa( cCaixa			, dDataMovto, lMV_LJTROCO	, aDDown	,;
					 		aContFina		, nVlrCred  , lSomaCred		, lUsaNmov	,;
					 		aLacAnalitico	, cRetFil 	, cRetCx		, dDataDe	,;
							dDataAte		,aDetSangria, aRecCelular	, nDevDin	,;
							aEstRec )

Local nPos  		:= 0								// Posicao no array
Local bTab			:= {|| }							// Codeblock para alinhar os valores a direita
Local nI, nJ  		:= 0								// Variavel para auxiliar o FOR
Local aCaixa    	:= Array( P_MAXDEFINE )				// Array com os valores do caixa
Local aValForma 	:= {}								// Array que armazena os subitens dos itens do ListBox de Vendas
Local nSe5Valor 	:= 0								// Variavel que soma com o E5_VALOR
Local nForma		:= 0								// Numero da forma de pagamento: 1) Cartao de Credito, 2) Vales, 3) Convenio
Local lUsaParam  	:= Empty(cCaixa)					// Valida se a variavel veio preenchida
Local aEstorno          								// array contendo os estornos.
Local lNivel     	:= .F.								// Verifica se explode nivel
Local aAux		 	:= {} 								// Array auxiliar com os valores por cada tipo de pagamento
Local cAlias     	:= Alias()							// Variavel que guarda o alias que esta aberto
Local nDinheiro  	:= 0								// Valor recebido em dinheiro   
Local aAuxRecebs    := {}								// Array auxiliar com o numero e parcela do SE5
Local aDetReceb		:= {}								// Array contem os detalhes dos titulos Recebido no Venda Assistida
Local cPgtoAux		:= ""								// Variavel auxiliar para montar a descricao do pagamento.
Local cForPagto		:= ""								// Variavel auxiliar para a distribuicao das formas de pagto.
Local nBkValCred	:= 0								// Armazena o Valor do Credito que foi utilizado na venda
Local aAreaSD1      := nil                      		// Area de Trabalho do SD1
Local lE5_Estor     := .F.                      		// Lancamento E5 Estornado?
Local lDevDinhei    := .F.                      		// Lancamento E5 Dinheiro Devolvido ao cliente?
Local cEmpAtual		:= FWCompany()          			// FWCompany("SM0") - Codigo da Empresa corrente
Local nTamanhoFil	:= FWSizeFilial()					// Retorna o tamanho do campo filial
Local cPicture		:= PesqPict("SL1","L1_VLRTOT",18)	//Picture do campo L1_VLRTOT
Local cQuery											// Variavel que ira armazenar a query
Local nCountSL2		:= 1
Local lFidVenda		:= .F.
Local lContinua		:= .F.
Local cNameOper		:= ""
Local nRc 			:= 1
Local nRt 			:= 1
Local lSangDin   	:= SuperGetMV("MV_LJ350MV",,2) == 1	//Habilitada opcao de sangria somente para dinheiro
Local nVlrAbtPCC	:= 0
Local nVlrISS		:= 0
Local nVImpostos 	:= 0
Local lRestauran	:= SuperGetMV("MV_LJREST", , .F.) .And. SL1->(FieldPos("L1_ESTACIO")) > 0  .And. SL1->(FieldPos("L1_SERVICO")) > 0  //Caso seja utilizado o sistema de Gestão de Restaurantes
Local nVlrEstaci	:= 0
Local nVlrServic 	:= 0
Local nVlrCarFid	:= 0
Local lMvDescIss 	:= SuperGetMV("MV_DESCISS", , .F.)
Local lMvLJRECIS 	:= SuperGetMV("MV_LJRECIS", , .F.)
Local lL1RECISS 	:= SL1->(FieldPos("L1_RECISS")) > 0
Local nVlrPagDig	:= 0
Local nVlrPagPIX	:= 0
Local lL1VLRPGDG 	:= SL1->(FieldPos( "L1_VLRPGDG" )) > 0 .AND. SL1->(FieldPos( "L1_VLRPGPX" )) > 0
Local lMvLjTroco	:= SuperGetMV("MV_LJTROCO",,.F.)
Local nSE5Troco		:= 0 					// Guarda Valor do Troco 
Local nValDev		:= 0					// Valor das Devoluções Baixadas
Local cMV_LJPGTRO 	:= AllTrim(SuperGetMV("MV_LJPGTRO",,IIf( cPaisLoc <> "BRA","", "R$")))  // Formas de pagamentos que geram troco na venda
Local cE5TIPO		:= ""					// Guarda o conteúdo do campo SE5->E5_TIPO

DEFAULT cRetFil		  := ""
DEFAULT cRetCx		  := ""
DEFAULT aDDown        := Array(15)
DEFAULT nVlrCred      := 0
DEFAULT lSomaCred     := .F.
DEFAULT dDataMovto    := dDataBase
DEFAULT aLacAnalitico := {}
DEFAULT lUsaNMov	  := .F.
Default aRecCelular   := {}
Default nDevDin		  := 0
Default aEstRec		  := Array(P_MAXDEFINE)

If Type("aContFina") <> "A"
	aContFina:= {0,0,0,0,0,0,0,0,0,0,0,0,0} 	// Contadores utilizados nos tipos de finalizacoes
EndIf

//Espacos para alinhar o valor a direita.
bTab := { |x| Space( 30 - Len(x) ) }

//Inicializa vetor que armazena os subitens dos itens do ListBox de Vendas
If Len(aDDown) > 0
	aValForma	:= Array( Len(aDDown) )
Else
	aValForma	:= Array(8)
Endif
		
For nI := 1 to Len( aDDown )
	aDDown[nI]    := {}
	aValForma[nI] := {}
Next nI	

For nI := 1 to Len( aCaixa )
	aCaixa[nI] := 0
Next nI

For nI := 1 to Len( aEstRec )
	aEstRec[nI] := 0
Next nI


cCaixa := SubStr( cCaixa, 1, 3 )

//Leitura do SE5 para considerar: Sangria, Troco e Movimentaçõe bancárias.                                            ³
cQuery := "SELECT SE5.E5_DATA 	, SE5.E5_VALOR  , SE5.E5_BANCO , SE5.E5_AGENCIA, "
cQuery +=       " SE5.E5_CONTA	, SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA, "
cQuery +=       " SE5.E5_TIPO 	, SE5.E5_TIPODOC, SE5.E5_CLIFOR, SE5.E5_LOJA, "
cQuery +=       " SE5.E5_SEQ  	, SE5.E5_VENCTO , SE5.E5_MOEDA , SE5.E5_RECPAG, "
cQuery +=       " SE5.E5_MOTBX	, SE5.E5_FILIAL , SE5.E5_FILORIG, SE5.E5_NATUREZ, "
cQuery +=       " SE5.E5_SITUACA, SE5.E5_ORIGEM	, SE5.E5_HISTOR, SE5.E5_FORMAPG "

	If lMvLjTroco 
	cQuery += "		,E5.E5_VALOR E5_VLRTRC"
	EndIF

	cQuery += " FROM " + RetSQLName("SE5") + " SE5"

	If lMvLjTroco 
		cQuery += " LEFT JOIN "
		cQuery += RetSQLName("SE5") + " E5"
		cQuery += "	ON SE5.D_E_L_E_T_ = E5.D_E_L_E_T_"
		cQuery +=   " AND SE5.E5_FILIAL = E5.E5_FILIAL"
		cQuery +=   " AND SE5.E5_BANCO = E5.E5_BANCO"
		cQuery +=   " AND SE5.E5_AGENCIA = E5.E5_AGENCIA"
		cQuery +=   " AND SE5.E5_CONTA = E5.E5_CONTA"
		cQuery +=   " AND SE5.E5_PREFIXO = E5.E5_PREFIXO"
		cQuery +=   " AND SE5.E5_NUMERO = E5.E5_NUMERO"
		cQuery +=   " AND SE5.E5_PARCELA = E5.E5_PARCELA"
		cQuery +=   " AND SE5.E5_CLIFOR = E5.E5_CLIFOR"
		cQuery +=   " AND SE5.E5_LOJA = E5.E5_LOJA"
		cQuery +=   " AND SE5.E5_SEQ = E5.E5_SEQ"
		cQuery +=   " AND E5.E5_TIPODOC = 'VL'"
		cQuery +=   " AND E5.E5_MOEDA = 'TC'"
		cQuery +=   " AND E5.E5_RECPAG = 'P'"
		cQuery +=   " AND E5.E5_PREFIXO <> '" + Space( TamSx3("E5_PREFIXO")[1] ) + "'"  //Tratamento para pegar troco só da venda
		cQuery +=   " AND E5.E5_NUMERO <> '" + Space( TamSx3("E5_NUMERO")[1] ) + "'"    //Tratamento para pegar troco só da venda
	EndIF
		
	cQuery += " WHERE (SE5.E5_FILORIG IN(" + cRetFil + ")"
	cQuery +=       " OR (SE5.E5_MSFIL IN(" + cRetFil + ")"								// Recebimento em NCC
	cQuery +=       " AND SE5.E5_FILORIG <> SE5.E5_MSFIL AND SE5.E5_TIPO = 'NCC'))"		// Gerada em outra Filial
	cQuery +=       " AND SE5.E5_DATA BETWEEN '" + DToS(dDataDe) + "' AND '" + DToS(dDataAte) + "'"
	cQuery +=       " AND SE5.E5_BANCO IN(" + cRetCx + ")"
	cQuery +=       " AND ( SE5.E5_SITUACA <> 'C' OR SE5.E5_ORIGEM = 'LOJXREC ')"
	cQuery +=       " AND SE5.E5_MOEDA <> 'ES'"
	cQuery +=       " AND SE5.E5_TIPODOC NOT IN ('LJ','DC','JR','MT','CM','D2','J2','M2','C2','V2','CP','TL')"
	cQuery +=       " AND SE5.D_E_L_E_T_ = ' ' "
	cQuery +=       " AND NOT (SE5.E5_ORIGEM = 'LOJXREC '  AND SE5.E5_MOEDA = 'TC') "

MemoWrite("LOJC030_SE5.SQL",cQuery)
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'SE5TMP', .F., .T.)
TCSetField("SE5TMP", "E5_DATA", "D")
TCSetField("SE5TMP", "E5_VENCTO", "D")

While !SE5TMP->(EOF())

   // Tamanho do campo Filial maior que 2, esta configurado para Gestao de Empresas
	If nTamanhoFil > 2
		// Verifica se o registro da tabela SE5 e da empresa corrrente    			
		If Alltrim(Substr( SE5TMP->E5_FILORIG,1,Len(cEmpAtual) )) <> Alltrim(cEmpAtual)
           	DbSelectArea("SE5TMP") 
			SE5TMP->( DbSkip() )
			Loop                                                       				
		Endif		
		DbSelectArea("SE5TMP")
	Endif	
	
	//Verifica se tem cancelamento para este titulo.
	If AllTrim(SE5TMP->E5_ORIGEM) <> "LOJXREC" .And. TemBxCanc( SE5TMP->E5_PREFIXO + SE5TMP->E5_NUMERO + SE5TMP->E5_PARCELA + SE5TMP->E5_TIPO + SE5TMP->E5_CLIFOR + SE5TMP->E5_LOJA + SE5TMP->E5_SEQ )
		SE5TMP->(DbSkip())
		Loop
	EndIf

	// Considera os titulos em NCC que foram utilizados para baixar titulos 
	// na rotina de recebimento de titulos (LOJXREC), verificando se a      
	// moeda de baixa eh igual a "CR"                                       
    If !(AllTrim(SE5TMP->E5_TIPO) == "NCC" .AND. AllTrim( SE5TMP->E5_MOEDA) == "CR") .AND.;
		((AllTrim(SE5TMP->E5_TIPO) $ MV_CRNEG + "/PA") .OR. SE5TMP->E5_VENCTO > SE5TMP->E5_DATA)
		SE5TMP->(DbSkip())
		Loop
	Endif

	//Se o lançamento for referente a uma venda estornada ou Dinheiro Devolvido, então ignora o lançamento
	If SE5TMP->E5_TIPODOC $ "TR|DH" .and. !Empty(SE5TMP->E5_NUMERO) .and. !Empty(SE5TMP->E5_PREFIXO)
		
		aAreaSD1 := SD1->(GetArea())
		DbSelectArea("SD1")
		DbSetOrder(1)

		If SD1->(DbSeek(xFilial("SD1") + SE5TMP->E5_NUMERO + SE5TMP->E5_PREFIXO + SE5TMP->E5_CLIFOR + SE5TMP->E5_LOJA ))
			lE5_Estor := !Empty(SD1->D1_OPERADO)
			lDevDinhei:= AllTrim(SD1->D1_ORIGLAN) == "LO" //Origem LOJA
		Else
			lE5_Estor := .F.
			lDevDinhei:= .F.
		EndIf

		RestArea(aAreaSD1)

		DbSelectArea("SE5TMP")

		If lE5_Estor .Or. lDevDinhei
			SE5TMP->(DbSkip())
			Loop
		EndIf

	EndIf

	nSe5Valor := SE5TMP->E5_VALOR
	If lMvLjTroco
		nSE5Troco := SE5TMP->E5_VLRTRC
	EndIf	

	//Verifica se é uma Recarga de Celular.
	If cTxtRecCel $ UPPER(SE5TMP->E5_HISTOR)
		aCaixa[P_REC_CELULAR]	+= nSe5Valor
		aadd(aRecCelular, {SE5TMP->E5_DATA, SE5TMP->E5_VALOR, SE5TMP->E5_BANCO, SE5TMP->E5_AGENCIA, SE5TMP->E5_CONTA, SE5TMP->E5_PREFIXO, SE5TMP->E5_NUMERO, SE5TMP->E5_PARCELA,;
				SE5TMP->E5_TIPO, SE5TMP->E5_TIPODOC, SE5TMP->E5_CLIFOR, SE5TMP->E5_LOJA, SE5TMP->E5_SEQ, SE5TMP->E5_VENCTO, SE5TMP->E5_MOEDA, SE5TMP->E5_RECPAG, SE5TMP->E5_MOTBX, SE5TMP->E5_FILIAL,;
				SE5TMP->E5_FILORIG, SE5TMP->E5_SITUACA, SE5TMP->E5_NATUREZ,  SE5TMP->E5_ORIGEM, SE5TMP->E5_HISTOR})
	Endif

	//Considerar Entrada de Troco estornada, pois o Financeiro nao marca o campo E5_SITUACA como estornado. 
	If (SE5TMP->E5_TIPODOC == "TR" .OR. SE5TMP->E5_TIPODOC == "TE") .AND. SE5TMP->E5_MOEDA == "TC" .AND. SE5TMP->E5_RECPAG == "R"	// Saldo inicial
		aCaixa[P_TROCO] += nSe5Valor

	ElseIf	(SE5TMP->E5_TIPODOC == "VL" .AND. SE5TMP->E5_MOEDA <> "TC" ) .OR. Empty(SE5TMP->E5_TIPODOC) .OR.;
			SE5TMP->E5_TIPODOC == "BL" .OR. SE5TMP->E5_TIPODOC == "DH" .OR. (Alltrim(SE5TMP->E5_TIPO) == "NCC" .AND. Alltrim(SE5TMP->E5_MOEDA) == "CR" );
			.OR. (SE5TMP->E5_TIPODOC $ MVRECANT .AND. AllTrim(SE5TMP->E5_TIPO) $ MVRECANT) .OR.;
			(SE5TMP->E5_TIPODOC == "BA" .AND. SE5TMP->E5_MOEDA <> "TC"  .AND. SE5TMP->E5_MOTBX == "LOJ" .AND. !IsMoney(SE5TMP->E5_MOEDA));
			.OR. (AllTrim(SE5TMP->E5_ORIGEM) == "LOJXREC" .AND. SE5TMP->E5_TIPODOC == "ES" .AND. SE5TMP->E5_MOTBX == "LOJ") //Estorno de Recebimento de Titulo
		
		//Pagamento -> Tipo de doc VL com moeda diferente de TC e recebimentos de titulos com NCC.
		If SE5TMP->E5_RECPAG == "P"

			If AllTrim(SE5TMP->E5_ORIGEM) == "LOJXREC" .And. SE5TMP->E5_TIPODOC == "ES"
				aCaixa[P_ESTORNO_REC] += (nSe5Valor + nSE5Troco)
				nOpDeb := P_ESTORNO_REC				

				Do Case	
					Case IsMoney(RTrim(SE5TMP->E5_FORMAPG))
						aEstRec[P_VEND_DINHEIRO]		+=	nSe5Valor
						
					Case RTrim(SE5TMP->E5_FORMAPG) $ "C1,C2,C3,C4,C5,CH"
						aEstRec[P_VEND_CHEQUE]		+=	nSe5Valor
						
					Case RTrim(SE5TMP->E5_FORMAPG) == "CC"
						aEstRec[P_VEND_CARTAO]		+=	nSe5Valor			
						
					Case RTrim(SE5TMP->E5_FORMAPG) == "VA"
						aEstRec[P_VEND_VALE]			+=	nSe5Valor
						
					Case RTrim(SE5TMP->E5_FORMAPG) == "CO"
						aEstRec[P_VEND_CONVENIO]		+=	nSe5Valor
						
					Case RTrim(SE5TMP->E5_FORMAPG) == "FI"
						aEstRec[P_VEND_FINANCIADO]	+=	nSe5Valor
						
					Case RTrim(SE5TMP->E5_FORMAPG) == "CD"
						aEstRec[P_VEND_DEBAUTO]		+=	nSe5Valor
						
					Otherwise
						aEstRec[P_VEND_OUTROS]		+=	nSe5Valor			
				EndCase

			Else
				aCaixa[P_PAGAMENTOS] += nSe5Valor
			EndIf

		ElseIf SE5TMP->E5_RECPAG == "R" .AND. !(Alltrim(SE5TMP->E5_TIPO) $ "CH/R$/CC") .AND. !Empty(SE5TMP->E5_TIPODOC) 
			aCaixa[P_RECEBIMENTOS] 	+= nSe5Valor + nSE5Troco
			If aScan(aAuxRecebs, {|x| x == SE5TMP->E5_NUMERO + SE5TMP->E5_PARCELA}) == 0
				AAdd(aAuxRecebs, SE5TMP->E5_NUMERO + SE5TMP->E5_PARCELA)
				AAdd(aDetReceb, {SE5TMP->E5_NUMERO, SE5TMP->E5_PARCELA, (SE5TMP->E5_VALOR + nSE5Troco), SE5TMP->E5_DATA, SE5TMP->E5_BANCO, SE5TMP->E5_MOEDA, SE5TMP->E5_TIPO})
				aContFina[9] += 1
			EndIf

			//Distribui os recebimentos por forma de pagamento, para fazer o DDown na tela.
			If AllTrim( SE5TMP->E5_MOEDA ) <> ""
				cForPagto := SE5TMP->E5_MOEDA
				If cPaisLoc == "BRA" .AND. Val(cForPagto) == 1 
					cForPagto := "R$"
				EndIf
				cPgtoAux  := AllTrim(Tabela("06", cForPagto, .F.))
			Else
				cForPagto := "OU"
				cPgtoAux  := "OUTROS"
			Endif

			nPos := aScan(aDDown[8], {|x| x[5] == cForPagto})
			If nPos <> 0
				If lMvLjTroco .AND. SE5TMP->E5_MOEDA <> "R$"
					aDDown[8][nPos][2] += (SE5TMP->E5_VALOR + nSE5Troco)	//(campo renomeado no Result Set)
				Else	
					aDDown[8][nPos][2] += SE5TMP->E5_VALOR 
				EndIf	
				aDDown[8][nPos][3] := Transform(aDDown[8][nPos][2],cPicture)
				aDDown[8][nPos][4] := Str((Val(aDDown[8][nPos][4]) + 1),3)
			Else
				If lMvLjTroco .AND. Alltrim(SE5TMP->E5_MOEDA) <> "R$" .AND. Alltrim(SE5TMP->E5_MOEDA) $ cMV_LJPGTRO
					aAdd(aDDown[8], {nil, (SE5TMP->E5_VALOR + nSE5Troco), Transform(SE5TMP->E5_VALOR + nSE5Troco,cPicture), Str(1,3),cForPagto})
				Else	
					aAdd(aDDown[8], {nil, SE5TMP->E5_VALOR, Transform(SE5TMP->E5_VALOR,cPicture), Str(1,3),cForPagto})
				EndIf	
				nPos := len(aDDown[8])
			Endif
			aDDown[8][nPos][1] 	:= Alltrim(cPgtoAux)

		Endif

	ElseIf SE5TMP->E5_TIPODOC $ "SG/TR/TE" .AND. SE5TMP->E5_RECPAG == "P"
		If IsMoney(SE5TMP->E5_MOEDA)
			aCaixa[P_SANG_DINHEIRO]		+=	nSe5Valor
			Aadd(aDetSangria,{P_SANG_DINHEIRO,Alltrim(SE5TMP->E5_NATUREZ),SE5TMP->E5_DATA,SE5TMP->E5_VALOR,SE5TMP->E5_MOEDA,SE5TMP->E5_BANCO,SE5TMP->E5_AGENCIA,SE5TMP->E5_CONTA})
		ElseIf SE5TMP->E5_MOEDA $ "C1,C2,C3,C4,C5,CH"
			aCaixa[P_SANG_CHEQUE]		+=	nSe5Valor
			Aadd(aDetSangria,{P_SANG_CHEQUE,Alltrim(SE5TMP->E5_NATUREZ),SE5TMP->E5_DATA,SE5TMP->E5_VALOR,SE5TMP->E5_MOEDA,SE5TMP->E5_BANCO,SE5TMP->E5_AGENCIA,SE5TMP->E5_CONTA})
		ElseIf SE5TMP->E5_MOEDA == "CC"
			aCaixa[P_SANG_CARTAO]		+=	nSe5Valor			
			Aadd(aDetSangria,{P_SANG_CARTAO,Alltrim(SE5TMP->E5_NATUREZ),SE5TMP->E5_DATA,SE5TMP->E5_VALOR,SE5TMP->E5_MOEDA,SE5TMP->E5_BANCO,SE5TMP->E5_AGENCIA,SE5TMP->E5_CONTA})
		ElseIf SE5TMP->E5_MOEDA == "VA"
			aCaixa[P_SANG_VALE]			+=	nSe5Valor
			Aadd(aDetSangria,{P_SANG_VALE,Alltrim(SE5TMP->E5_NATUREZ),SE5TMP->E5_DATA,SE5TMP->E5_VALOR,SE5TMP->E5_MOEDA,SE5TMP->E5_BANCO,SE5TMP->E5_AGENCIA,SE5TMP->E5_CONTA})
		ElseIf SE5TMP->E5_MOEDA == "CO"
			aCaixa[P_SANG_CONVENIO]		+=	nSe5Valor
			Aadd(aDetSangria,{P_SANG_CONVENIO,Alltrim(SE5TMP->E5_NATUREZ),SE5TMP->E5_DATA,SE5TMP->E5_VALOR,SE5TMP->E5_MOEDA,SE5TMP->E5_BANCO,SE5TMP->E5_AGENCIA,SE5TMP->E5_CONTA})
		ElseIf SE5TMP->E5_MOEDA == "FI"
			aCaixa[P_SANG_FINANCIADO]	+=	nSe5Valor
			Aadd(aDetSangria,{P_SANG_FINANCIADO,Alltrim(SE5TMP->E5_NATUREZ),SE5TMP->E5_DATA,SE5TMP->E5_VALOR,SE5TMP->E5_MOEDA,SE5TMP->E5_BANCO,SE5TMP->E5_AGENCIA,SE5TMP->E5_CONTA})
		ElseIf SE5TMP->E5_MOEDA == "CD"
			aCaixa[P_SANG_DEBAUTO]		+=	nSe5Valor
			Aadd(aDetSangria,{P_SANG_DEBAUTO,Alltrim(SE5TMP->E5_NATUREZ),SE5TMP->E5_DATA,SE5TMP->E5_VALOR,SE5TMP->E5_MOEDA,SE5TMP->E5_BANCO,SE5TMP->E5_AGENCIA,SE5TMP->E5_CONTA})
		ElseIf SE5TMP->E5_MOEDA == "PD"
			aCaixa[P_SANG_PAGDIG]		+=	nSe5Valor
			Aadd(aDetSangria,{P_SANG_PAGDIG,Alltrim(SE5TMP->E5_NATUREZ),SE5TMP->E5_DATA,SE5TMP->E5_VALOR,SE5TMP->E5_MOEDA,SE5TMP->E5_BANCO,SE5TMP->E5_AGENCIA,SE5TMP->E5_CONTA})
		ElseIf SE5TMP->E5_MOEDA == "PX"
			aCaixa[P_SANG_PAGPIX]		+=	nSe5Valor
			Aadd(aDetSangria,{P_SANG_PAGPIX,Alltrim(SE5TMP->E5_NATUREZ),SE5TMP->E5_DATA,SE5TMP->E5_VALOR,SE5TMP->E5_MOEDA,SE5TMP->E5_BANCO,SE5TMP->E5_AGENCIA,SE5TMP->E5_CONTA})
		Else
			aCaixa[P_SANG_OUTROS]		+=	nSe5Valor
			Aadd(aDetSangria,{P_SANG_OUTROS,Alltrim(SE5TMP->E5_NATUREZ),SE5TMP->E5_DATA,SE5TMP->E5_VALOR,SE5TMP->E5_MOEDA,SE5TMP->E5_BANCO,SE5TMP->E5_AGENCIA,SE5TMP->E5_CONTA})
		Endif

	ElseIf SE5TMP->E5_TIPODOC $ "TR/TE"
		If SE5TMP->E5_RECPAG == "R"	.AND. SE5TMP->E5_MOEDA <> "TC"
			aCaixa[P_TRANSF_DESTINO] += nSe5Valor
		Endif

	//Carrega o valor do Troco Final 
	Elseif (SE5TMP->E5_TIPODOC == "VL" .AND. SE5TMP->E5_MOEDA == "TC" .AND. SE5TMP->E5_RECPAG == "P" .AND. lMV_LJTROCO )
		aCaixa[P_TROCO_SAIDA]	+=	nSe5Valor
	EndIf

	SE5TMP->(DbSkip())

End
SE5TMP->( dbCloseArea() )

DbSelectArea("SL2")
DbSetOrder(1)

cQuery := "SELECT SL1.L1_FILIAL ,SL1.L1_NUM    , SL1.L1_MOEDA  , SL1.L1_CONDPG , SL1.L1_FORMPG ,"  // Acrescido o campo par ser utilizado na busca do SE4 Abaixo
cQuery +=        "SL1.L1_OPERADO,SL1.L1_TXMOEDA, SL1.L1_DINHEIR, SL1.L1_CHEQUES, SL1.L1_CARTAO ,"
cQuery +=        "SL1.L1_VALES  , SL1.L1_CONVENI, SL1.L1_FINANC , SL1.L1_VLRDEBI," 
cQuery +=        "SL1.L1_CREDITO, SL1.L1_OUTROS , SL1.L1_VLRLIQ , SL1.L1_VALISS , SL1.L1_VLRTOT ,"

//Caso Seja Cartão Fidelidade e Versão 11.5, Adiciona o Campo SL1.L1_CartFid para que seja contabilizada as informações de vendas com Cartão Fidelidade
If lLjcFid
	cQuery +=   "SL1.L1_CLIENTE, SL1.L1_LOJA	, SL1.L1_EMISNF , SL1.L1_CARTFID"
Else
	cQuery +=   "SL1.L1_CLIENTE, SL1.L1_LOJA	, SL1.L1_EMISNF"
EndIf

cQuery += ", L1_ABTOPCC"

If lRestauran
	cQuery += ", L1_ESTACIO, L1_SERVICO"
EndIf

If lL1RECISS
	cQuery += ", L1_RECISS  "
Endif

If lL1VLRPGDG
    cQuery += ", L1_VLRPGDG, L1_VLRPGPX"
EndIf

cQuery += " FROM " + RetSQLName("SL1") + " SL1"
                                                  
cQuery += " WHERE SL1.L1_FILIAL IN(" + cRetFil + ")" 
cQuery += " AND SL1.L1_EMISNF BETWEEN '" + DToS(dDataDe) + "' AND '" + DToS(dDataAte) + "'"
cQuery += " AND SL1.L1_OPERADO IN(" + cRetCx + ")"
cQuery += " AND ((SL1.L1_TIPO = 'P' AND SL1.L1_DOCPED <> '' )  "
cQuery += " OR  (SL1.L1_TIPO = 'V' AND SL1.L1_DOC <> '' "

If lL1VLRPGDG 
	cQuery += " AND (SL1.L1_DINHEIR>0 OR SL1.L1_CHEQUES>0 OR SL1.L1_CARTAO>0 OR SL1.L1_VALES>0 OR SL1.L1_CONVENI>0 OR SL1.L1_FINANC>0 OR SL1.L1_VLRDEBI>0 OR SL1.L1_CREDITO>0 OR SL1.L1_OUTROS>0 OR SL1.L1_VLRPGDG>0 OR SL1.L1_VLRPGPX>0))) "
Else
	cQuery += " AND (SL1.L1_DINHEIR>0 OR SL1.L1_CHEQUES>0 OR SL1.L1_CARTAO>0 OR SL1.L1_VALES>0 OR SL1.L1_CONVENI>0 OR SL1.L1_FINANC>0 OR SL1.L1_VLRDEBI>0 OR SL1.L1_OUTROS>0 OR SL1.L1_CREDITO>0))) "
Endif

cQuery += " AND SL1.L1_ORCRES = ' ' "
cQuery += " AND SL1.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY SL1.L1_FILIAL "

MemoWrite("LOJC030_SL1.SQL",cQuery)

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'SL1TMP', .F., .T.)
aLacAnalitico := {}

While !SL1TMP->(EOF())
	lFidVenda 	:= .F. 	
	lContinua	:= .F.	
	nCountSL2	:= 1	
    // Tamanho do campo Filial maior que 2, esta configurado para Gestao de Empresas
	If nTamanhoFil > 2
		// Verifica se o registro da tabela SL1 e da empresa corrrente    					
		If Alltrim(Substr( SL1TMP->L1_Filial,1,Len(cEmpAtual) )) <> Alltrim(cEmpAtual)
           	DbSelectArea("SL1TMP") 
			SL1TMP->(DbSkip())                                                                        
			Loop
		Endif			
	Endif
	
	DbSelectArea( "SL2" )
	If DbSeek( xFilial("SL2") + SL1TMP->L1_NUM )
		While !EOF() .AND. (xFilial("SL2") == SL1TMP->L1_FILIAL) .AND. (SL1TMP->L1_NUM == SL2->L2_NUM) .AND. !(lContinua)
			If nCountSL2 >= 2
				lContinua := .T.
			Else
				// Tem fidelidade
				If Alltrim(SL2->L2_PRODUTO) == Alltrim(SuperGetMv("MV_LJPFID",,"" ))
					lFidVenda := .T.
					lContinua := .T.
				EndIf
			EndIf
			nCountSL2++
			DbSkip()
			Loop
		End
	EndIf
	
	DbSelectArea( "SL1TMP" )

	aAux := { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }

	If !lFidVenda
        nDinheiro 	:= SL1TMP->L1_DINHEIR
        nVlrAbtPCC	:= SL1TMP->L1_ABTOPCC
        nVlrEstaci 	:= Iif( lRestauran, SL1TMP->L1_ESTACIO, 0 )
        nVlrServic 	:= Iif( lRestauran, SL1TMP->L1_SERVICO, 0 )
        nVlrCarFid 	:= Iif( lLjcFid	  , SL1TMP->L1_CARTFID, 0 )
        nVlrPagDig 	:= Iif( lL1VLRPGDG, SL1TMP->L1_VLRPGDG, 0 )
		nVlrPagPIX 	:= Iif( lL1VLRPGDG, SL1TMP->L1_VLRPGPX, 0 )

		// Verifica se esta usando a nova configuracao para confirmar se o cliente recolhera o iss.
		If lMvDescIss
			If lMvLJRECIS .AND. lL1RECISS
				lCliRecIss := SL1TMP->L1_RECISS == "1"
			Else
				lCliRecIss := Posicione("SA1",1,xFilial("SA1")+SL1TMP->L1_CLIENTE+SL1TMP->L1_LOJA,"SA1->A1_RECISS") == "1"
			EndIf
			If lCliRecIss
				nVlrISS  := SL1TMP->L1_VALISS
			Else
				nVlrISS  := 0
			EndIf
		EndIf

		nVImpostos	:= nVlrAbtPCC + nVlrISS

		If nVlrAbtPCC > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o valor de pagamentos for zero (abatimento de PIS/COFINS/CSLL    ³
			//³no valor total da venda) é somado o valor do abatimento no dinheiro.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (nDinheiro + SL1TMP->(L1_CHEQUES + L1_CARTAO + L1_VALES + L1_CONVENI + L1_FINANC + L1_VLRDEBI + L1_CREDITO + L1_OUTROS) ) == 0
				nDinheiro += nVlrAbtPCC
			EndIf
		EndIf
	
		aAux[01] := nDinheiro			//01-Dinheiro
		aAux[02] := SL1TMP->L1_CHEQUES	//02-Cheque
		aAux[03] := SL1TMP->L1_CARTAO	//03-Cartão de Crédito
		aAux[04] := SL1TMP->L1_VALES  	//04-Vale
		aAux[05] := SL1TMP->L1_CONVENI	//05-Convênio
		aAux[06] := SL1TMP->L1_FINANC 	//06-Financiado
		aAux[07] := SL1TMP->L1_VLRDEBI	//07-Cartão de Débito
		aAux[08] := SL1TMP->L1_CREDITO	//08-Crédito (NCC)
		aAux[09] := SL1TMP->L1_OUTROS 	//09-Outros
		aAux[10] := nVImpostos			//10-Impostos
		aAux[11] := nVlrEstaci			//11-Estacionamento
		aAux[12] := nVlrServic			//12-Serviço
		aAux[13] := nVlrCarFid			//13-Cartão Fidelidade
		aAux[14] := nVlrPagDig 			//14-Pagamento Digital
		aAux[15] := nVlrPagPIX 			//14-Pagamento em PIX
		
		aCaixa[P_VEND_DINHEIRO]		+= aAux[01]
		aCaixa[P_VEND_CHEQUE]		+= aAux[02]
		aCaixa[P_VEND_CARTAO]		+= aAux[03]
		aCaixa[P_VEND_VALE]			+= aAux[04]
		aCaixa[P_VEND_CONVENIO]		+= aAux[05]
		aCaixa[P_VEND_FINANCIADO]	+= aAux[06]
		aCaixa[P_VEND_DEBAUTO]		+= aAux[07]
		aCaixa[P_VEND_CREDITO]		+= aAux[08]
		aCaixa[P_VEND_OUTROS]		+= aAux[09]
		aCaixa[P_SANG_IMPOSTOS]		+= aAux[10]
		aCaixa[P_VEND_ESTACIO]		+= aAux[11]
		aCaixa[P_VEND_SERVICO]		+= aAux[12]
		aCaixa[P_VEND_CARTFID]		+= aAux[13]
		aCaixa[P_VEND_PAGDIG]		+= aAux[14]
		aCaixa[P_VEND_PAGPIX]		+= aAux[15]

		//Se lSomaCred igual a .F. deve adicionar na variavel nVlrCred para que
		//seja subtraida do totalizador de credito, uma vez que nao soma o credito
		//de venda no totalizador 
		If !lSomaCred
	        nVlrCred += aAux[8]
		Endif
		
		lNivel := .F.
	Else
		aCaixa[P_REC_CARTFID]	+= SL1TMP->L1_VLRTOT
	EndIf
	
	//Soh busca a administradora para as formas que podem ter administradora relacionada.
	//L1_CARTAO, L1_VALES, L1_CONVENI, L1_FINANC, L1_VLRDEBI                             
	If (	aAux[03] <> 0 .OR. aAux[04] <> 0 .OR. aAux[05] <> 0 .OR. aAux[06] <> 0 .OR. ;
			aAux[07] <> 0 .OR. aAux[02] <> 0 .OR. aAux[09] <> 0 .OR. aAux[01] <> 0 .OR. ;
			aAux[10] <> 0 .OR. aAux[08] <> 0 .OR. aAux[13] <> 0 .OR. aAux[14] <> 0 .OR. ;
			aAux[15] <> 0 ) .OR. lFidVenda // Foi adicionada mais esta linha em função da inclusao de contadores
		
		lNivel 		:= .T.
		nBkValCred	:= aAux[8]  //Guarda o Valor do credito utilizado na venda caso houver
		
		DbSelectArea("SL4")
		DbSetOrder(1)

		SL4->( DbSeek(  SL1TMP->L1_FILIAL + SL1TMP->L1_NUM ) )  // Busca pela filial do select e não por xfilial corrente

		aAux := {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}

		While SL4->( ! EoF() .AND. L4_NUM == SL1TMP->L1_NUM .AND. L4_FILIAL == SL1TMP->L1_FILIAL ) .AND. Empty(SL4->L4_ORIGEM)  
			
			//Atribui a numeracao de acordo com a forma registrada no SL4
			cNameOper := (Alltrim(SL1TMP->L1_OPERADO)) + " - " + (Alltrim(Posicione("SA6",1,xFilial("SL4") + Alltrim(SL1TMP->L1_OPERADO), "A6_NOME")))
			
			Do Case			    
				Case lFidVenda
					nForma := 0							
					aContFina[11] += 1
					aAdd(aLacAnalitico, {P_REC_CARTFID,;
										 RTrim( SL4->L4_FORMA ),;
										 SL4->L4_NUM,;
										 cNameOper,;						// Operador do Caixa (C01)
										 SL4->L4_DATA,;
										 SL4->L4_VALOR,;
										 SL4->L4_ADMINIS,;
										 SL4->L4_AGENCIA,;
										 SL4->L4_CONTA,;
										 SL4->L4_FORMPG})
			
					cPgtoAux := ""
					nPos := aScan(aDDown[11], {|x| x[5] == SL4->L4_FORMA})
					cPgtoAux  := AllTrim(Tabela("06", SL4->L4_FORMA, .F.))
					
					If nPos <> 0
						aDDown[11][nPos][2] += SL4->L4_VALOR
						aDDown[11][nPos][3] := Transform(aDDown[11][nPos][2],cPicture)
						aDDown[11][nPos][4] := Str((Val(aDDown[11][nPos][4]) + 1),3)
					Else
						aAdd(aDDown[11], {nil, SL4->L4_VALOR, Transform(SL4->L4_VALOR,cPicture), Str(1,3),SL4->L4_FORMA})
						nPos := len(aDDown[11])
					Endif
					aDDown[11][nPos][1] 	:= Alltrim(cPgtoAux)
				
				Case RTrim( SL4->L4_FORMA ) == "CC"						// Cartao de credito: 1a. opcao do array aDDown/aValForma
					nForma := 1
        			aContFina[1] += 1		               				// Acumulando contador de cartão de crédito
					aAdd(aLacAnalitico,{P_VEND_CARTAO,; 				// Tipo da Venda Conforme Define
										RTrim( SL4->L4_FORMA ),;		// Forma 
										SL4->L4_NUM,; 					// Numero do Orcmento
										cNameOper,;						// Operador do Caixa (C01)
										SL4->L4_DATA,;					// Data do orcamento
										SL4->L4_VALOR,;					// Valor do orcamento
										SL4->L4_ADMINIS,;				// Administradora
										SL4->L4_AUTORIZ,;				// Autorização
										SL4->L4_NSUTEF,;				// NSU 
										SL4->L4_FORMPG})				// Forma de Pagamento
				Case RTrim( SL4->L4_FORMA ) == "VA"						// Vales: 2a. opcao do array aDDown/aValForma
					nForma := 2	  
					aContFina[2] += 1									// Acumulando contador de vales                
					aAdd(aLacAnalitico, {P_VEND_VALE,;
										 RTrim( SL4->L4_FORMA),;
										 SL4->L4_NUM,;
										 cNameOper,;
										 SL4->L4_DATA,;
										 SL4->L4_VALOR,;
										 SL4->L4_ADMINIS,;
										 SL4->L4_AGENCIA,;
										 SL4->L4_CONTA,;
										 SL4->L4_FORMPG})
				Case RTrim( SL4->L4_FORMA ) == "CO"						// Convenio: 3a. opcao do array aDDown/aValForma
					nForma := 3					
					aContFina[3] += 1 			   						// Acumulando contador de convenios
					aAdd(aLacAnalitico, {P_VEND_CONVENIO,;
										 RTrim( SL4->L4_FORMA),;
										 SL4->L4_NUM,;
										 cNameOper,;
										 SL4->L4_DATA,;
										 SL4->L4_VALOR,;
										 SL4->L4_ADMINIS,;
										 SL4->L4_AGENCIA,;
										 SL4->L4_CONTA,;
										 SL4->L4_FORMPG})
				Case RTrim( SL4->L4_FORMA ) == "FI"						// Financiado: 4a. opcao do array aDDown/aValForma
					nForma := 4	  										// Acumulando contador de Financiado
					aContFina[4] += 1 								
					aAdd(aLacAnalitico, {P_VEND_FINANCIADO,;
										 RTrim( SL4->L4_FORMA),;
										 SL4->L4_NUM,;
										 cNameOper,;
										 SL4->L4_DATA,;
										 SL4->L4_VALOR,;
										 SL4->L4_ADMINIS,;
										 SL4->L4_AGENCIA,;
										 SL4->L4_CONTA,;
										 SL4->L4_FORMPG})
				Case RTrim( SL4->L4_FORMA ) == "CD"						// Cartao de Debito: 5a. array opcao do aDDown/aValForma
					nForma := 5	  
					aContFina[5] += 1               					// Acumulando contador de cartão de debito
					aAdd(aLacAnalitico, {P_VEND_DEBAUTO,;
										RTrim( SL4->L4_FORMA ),;
										SL4->L4_NUM,;
										cNameOper,;
										SL4->L4_DATA,;
										SL4->L4_VALOR,;
										SL4->L4_ADMINIS,;
										SL4->L4_AUTORIZ,;
										SL4->L4_NSUTEF,;
										SL4->L4_FORMPG})
				Case RTrim( SL4->L4_FORMA ) == "CH"						// Cheque
					nForma := 0	
					aContFina[6] += 1 									// Acumulando contador de cheques
					aAdd(aLacAnalitico, {P_VEND_CHEQUE,;
										RTrim( SL4->L4_FORMA ),;
										SL4->L4_NUM,;
										cNameOper,;
										SL4->L4_DATA,;
										SL4->L4_VALOR,;
										SL4->L4_ADMINIS,;
										SL4->L4_AGENCIA,;
										SL4->L4_CONTA,;
										SL4->L4_FORMPG})
				Case RTrim( SL4->L4_FORMA ) == "CR"						// Credito
					nForma := 0	
					aAdd(aLacAnalitico, {P_VEND_CREDITO,;
										RTrim( SL4->L4_FORMA ),;
										SL4->L4_NUM,;
										cNameOper,;
										SL4->L4_DATA,;
										SL4->L4_VALOR,;
										SL4->L4_ADMINIS,;
										SL4->L4_AGENCIA,;
										SL4->L4_CONTA,;
										SL4->L4_FORMPG})
				Case RTrim( SL4->L4_FORMA ) == "R$"						// Dinheiro
					nForma := 0							
					aAdd(aLacAnalitico, {P_VEND_DINHEIRO,;
										RTrim( SL4->L4_FORMA ),;
										SL4->L4_NUM,;
										cNameOper,;
										SL4->L4_DATA,;
										SL4->L4_VALOR,;
										SL4->L4_ADMINIS,;
										SL4->L4_AGENCIA,;
										SL4->L4_CONTA,;
										SL4->L4_FORMPG})
				Case lLjcFid .AND. RTrim( SL4->L4_FORMA ) == "FID"		// Fidelidade
					nForma := 9							
					aContFina[10] += 1 									// Acumulando contador Cartao fidelidade
					aAdd(aLacAnalitico, {P_VEND_CARTFID,;
										RTrim( SL4->L4_FORMA ),;
										SL4->L4_NUM,;
										cNameOper,;
										SL4->L4_DATA,;
										SL4->L4_VALOR,;
										SL4->L4_ADMINIS,;
										SL4->L4_AGENCIA,;
										SL4->L4_CONTA,;
										SL4->L4_FORMPG})
				Case RTrim( SL4->L4_FORMA ) == "PD"		                // Pagamento Digital
					nForma := 12							
					aContFina[12] += 1 									// Acumulando contador Pagamento Digital
					aAdd(aLacAnalitico, {P_VEND_PAGDIG,;
										RTrim( SL4->L4_FORMA ),;
										SL4->L4_NUM,;
										cNameOper,;
										SL4->L4_DATA,;
										SL4->L4_VALOR,;
										SL4->L4_ADMINIS,;
										SL4->L4_AGENCIA,;
										SL4->L4_CONTA,;
										SL4->L4_FORMPG})
				Case RTrim( SL4->L4_FORMA ) == "PX"		                // Pagamento com PIX
					nForma := 13							
					aContFina[13] += 1 									// Acumulando contador Pagamento PIX
					aAdd(aLacAnalitico, {P_VEND_PAGPIX,;
										RTrim( SL4->L4_FORMA ),;
										SL4->L4_NUM,;
										cNameOper,;
										SL4->L4_DATA,;
										SL4->L4_VALOR,;
										SL4->L4_ADMINIS,;
										SL4->L4_AGENCIA,;
										SL4->L4_CONTA,;
										SL4->L4_FORMPG})
				OtherWise       										// Nao eh nenhuma das foram de pagamento que tem administradora
					nForma := 0	
					aContFina[7] += 1									// Acumulando contador de outras condições
					aAdd(aLacAnalitico, {P_VEND_OUTROS,;
										RTrim( SL4->L4_FORMA ),;
										SL4->L4_NUM,;
										cNameOper,;
										SL4->L4_DATA,;
										SL4->L4_VALOR,;
										SL4->L4_ADMINIS,;
										SL4->L4_AGENCIA,;
										SL4->L4_CONTA,;
										SL4->L4_FORMPG})
			EndCase            

			//Se pertence a alguma forma de pagamento relacionada a administradora
			If nForma <> 0
				//Seleciona o codigo da administradora
				cCodAdm  := Left( SL4->L4_ADMINIS, 3 )

				SAE->( DbSetOrder( 1 ) )
				If SAE->( DbSeek( xFilial( "SAE" ) + cCodAdm ) )

			    	cAdmCart := RTrim( Left( SAE->AE_DESC, 30 ) )

					nPos := aScan( aAux[ nForma ], { |x| x[1] == cCodAdm } )
				
					If nPos <> 0
						aAux[nForma,nPos,3] += SL4->L4_VALOR
						aAux[nForma,nPos,4] += 1
					Else
						AAdd( aAux[ nForma ], { cCodAdm, cAdmCart, SL4->L4_VALOR, 1 } )
					EndIf			                      
				EndIf
            EndIf

	        SL4->( dbSkip() )

		End 
		
		//Verifica se existe alguma Venda paga parte dela com uma
		//NCC , pois nao existe nenhum registro de NCC no SL4  
		If nBkValCred <> 0
			aContFina[8] += 1
			AAdd( aAux[7], { "001",  STR0029 , nBkValCred, 1 } ) //"Venda"
			aAdd(aLacAnalitico,{P_VEND_CREDITO,;
								RTrim(SL1TMP->L1_FORMPG),;
								SL1TMP->L1_NUM,;
								cNameOper,;
								StoD(SL1TMP->L1_EMISNF),;
								nBkValCred,;
								""        ,;
								""		  ,;
								""		  ,;
							   	""})
		Endif

	//Verifica se existe vendas com NCC
	ElseIf aAux[8] <> 0
		aAux 	:= {{},{},{},{},{},{},{}}
		lNivel 	:= .T.
		aContFina[8] += 1
		AAdd( aAux[7], { "001",  STR0029 , SL1TMP->L1_CREDITO, 1 } ) //"Venda"
		aAdd(aLacAnalitico, {P_VEND_CREDITO,;
							RTrim( SL1TMP->L1_FORMPG),;
							SL1TMP->L1_NUM,;
							cNameOper,;
							StoD(SL1TMP->L1_EMISNF),;
							nBkValCred,;
							""        ,;
							""		  ,;
							""		  ,;
							""})

	Endif
	  
	If lNivel
		IncAvalForma(@aAux, @aValForma)
	EndIf

	DbSelectArea( "SL1TMP" )
	dbSkip()
End
			
If len(aDetReceb) > 0   				//Significa que houve Recebimento de titulo(s)
	For nRt := 1 to len(aDetReceb)
	cNameOper := (Alltrim(aDetReceb[nRt][5])) + " - " + (Alltrim(Posicione("SA6",1,xFilial("SA6") + Alltrim(aDetReceb[nRt][5]), "A6_NOME")))
	aAdd(aLacAnalitico, {P_RECEBIMENTOS,;
		RTrim( aDetReceb[nRt][6] ),;	// Forma de pagto (R$)
		aDetReceb[nRt][1],;				// Numero do Titulo
		cNameOper,;						// Código e Nome do Operador (C02 - Caixa)
		aDetReceb[nRt][4],; 			// Data
		aDetReceb[nRt][3],;				// Valor
		"",;
		aDetReceb[nRt][2],;				// Parcela do titulo,;
		"",;
		""})
	Next nRt	
Endif

If len(aRecCelular) > 0					//Significa que houve recarga de Celular.
	For nRc := 1 to len(aRecCelular)
	cNameOper := (Alltrim(aRecCelular[nRc][3])) + " - " + (Alltrim(Posicione("SA6",1,xFilial("SL4") + Alltrim(aRecCelular[nRc][3]), "A6_NOME")))
	aAdd(aLacAnalitico, {P_REC_CELULAR,;
		RTrim( aRecCelular[nRc][9] ),;   // Forma de pagto (R$)
		aRecCelular[nRc][7],;			 // Numero do Titulo
		cNameOper,;						 // Código e Nome do Operador (C02 - Caixa)
		aRecCelular[nRc][1],;			 // Data
		aRecCelular[nRc][2],;			 // Valor
		"",;
		"",;
		"",;
		""})
	Next nRc	
Endif

SL1TMP->( dbCloseArea() )

//Tratamento NCC
cQuery := "SELECT SUM(SE1.E1_SALDO) SUM_SALDO, Count(*) QTDE"
cQuery += " FROM " + RetSQLName("SE1") + " SE1"
cQuery += " WHERE SE1.E1_FILORIG IN(" + cRetFil + ")"
cQuery += " AND SE1.E1_EMISSAO BETWEEN '" + DToS(dDataDe) + "' AND '" + DToS(dDataAte) + "'"
cQuery += " AND SE1.E1_PORTADO IN(" + cRetCx + ")"
cQuery += " AND SE1.E1_SALDO > 0"
cQuery += " AND SE1.E1_TIPO = '"+MV_CRNEG+"'"
cQuery += " AND SE1.D_E_L_E_T_ = ' '"

MemoWrite("LOJC030_SE1.SQL",cQuery)

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'SE1TMP', .F., .T.)

If !SE1TMP->( EOF() ) .AND. SE1TMP->SUM_SALDO > 0
	aCaixa[P_VEND_CREDITO] += SE1TMP->SUM_SALDO
	If !lSomaCred
        nVlrCred += SE1TMP->SUM_SALDO
	Endif			

	//Adiciona o saldo das NCCs na visualizacao dos Creditos de Vendas
	aAux         := {{},{},{},{},{},{},{}}
	aContFina[8] += SE1TMP->QTDE
	AAdd( aAux[7], { "002",  STR0030 , SE1TMP->SUM_SALDO, SE1TMP->QTDE} ) //"NCC"
	IncAvalForma(@aAux, @aValForma)		
EndIf
SE1TMP->( dbCloseArea() )

//Monta array de subitens para o ListBox de vendas a partir do array de valores por administradora e forma de pagamento.                
For nJ := 1 to Len( aValForma ) 

	If nJ > Len(aDDown)
		AAdd(aDDown,{})
	EndIf 

	For nI := 1 to Len( aValForma[ nJ ] )
		AAdd( aDDown[ nJ ], { 	Alltrim(aValForma[ nJ, nI, 2 ]),;
		                      	aValForma[ nJ, nI, 3 ],;
								Transform( aValForma[ nJ, nI, 3 ], cPicture ),;
		                      	Str(aValForma[ nJ, nI, 4 ] ,3),;
		                      	""} )

	Next nI
	
Next nJ

aEstorno := LJ130EST(lUsaParam, dDataMovto, cCaixa, cRetFil, cRetCx, dDataDe,dDataAte)

If ValType(aEstorno) == "A" .and. Len(aDDown) > 8
	nJ := 1
	For nJ := 1 to Len (aEstorno)
		AAdd(aDDown[ 9 ] , aClone(aEstorno[ nJ ]))
	Next nJ
	aCaixa[P_ESTORNO] := 0
	aCaixa[P_QTD_ESTORNO] := 0 
	aEval( aEstorno, {|x| aCaixa[P_ESTORNO] += x[2] } )
	aEval( aEstorno, {|x| aCaixa[P_QTD_ESTORNO] += x[3] } )
Endif   

//Busca por devoluções em dinheiro
cQuery := "  SELECT D1.D1_TOTAL, D1.D1_ICMSRET, D1_NFORI, D1_SERIORI, D1_ITEMORI, D1_FORNECE, D1_LOJA, D1_COD, E5.E5_TIPO, D1_SERIE, D1_DOC"
cQuery += " FROM " + RetSQLName("SD1") + " D1"

cQuery += " LEFT JOIN " + RetSQLName("SE5") + " E5"
cQuery +=   " ON E5.E5_FILORIG = D1.D1_FILIAL"
cQuery +=       " AND E5.E5_PREFIXO = D1.D1_SERIE"
cQuery +=       " AND E5.E5_NUMERO = D1.D1_DOC"
cQuery +=       " AND E5.E5_CLIFOR = D1.D1_FORNECE"
cQuery +=       " AND E5.E5_LOJA = D1.D1_LOJA"
cQuery +=       " AND E5.E5_TIPO = 'R$ '"
cQuery +=       " AND E5.E5_BANCO IN (" + cRetCx + ")"
cQuery +=       " AND E5.E5_RECPAG = 'P'"
cQuery +=       " AND E5.D_E_L_E_T_ = ' '"

cQuery += " WHERE D1.D1_FILIAL IN (" + cRetFil + ")"
cQuery +=       " AND D1.D1_EMISSAO BETWEEN '" + DToS(dDataDe) + "' AND '" + DToS(dDataAte) + "'"
cQuery +=       " AND D1.D1_TIPO = 'D'"
cQuery +=       " AND D1.D1_ORIGLAN = 'LO'"
cQuery +=       " AND D1.D1_NUMCQ IN (" + cRetCx + ")"
cQuery +=       " AND D1.D1_OPERADO = '" + Space( TamSx3("D1_OPERADO")[1] ) + "'"
cQuery +=       " AND D1.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'SD1TMP', .F., .T.)

While !SD1TMP->( EOF() )
	cE5TIPO := ""
	DbSelectArea("SD2")
	SD2->(DbSetOrder(3))	//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

	If SD2->(DbSeek(xFilial("SD2")+("SD1TMP")->D1_NFORI+("SD1TMP")->D1_SERIORI+("SD1TMP")->D1_FORNECE+("SD1TMP")->D1_LOJA+("SD1TMP")->D1_COD+("SD1TMP")->D1_ITEMORI))
		DbSelectArea("SE1")
		SE1->(DbSetOrder(2))	//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM  +E1_PARCELA+E1_TIPO

		If SE1->(DbSeek(xFilial("SE1")+SD1TMP->D1_FORNECE+SD1TMP->D1_LOJA+SD1TMP->D1_SERIE+SD1TMP->D1_DOC))
			// Verifica se o Título foi Baixado
			DbSelectArea("SE5")
			SE5->(DbSetOrder(7))	//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ

			If SE5->(DbSeek(xFilial("SE5")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA))
				cE5TIPO		:= SE5->E5_TIPO	
				nValDev		:= SD2->(D2_VALDEV+D2_ICMSRET)
				aCaixa[P_DEVBAIXA] += SD1TMP->D1_TOTAL+SD1TMP->D1_ICMSRET 
			EndIf				
		EndIf		
	EndIf

	If SD1TMP->D1_ICMSRET > 0
		aCaixa[P_DEVOLUCAO] += SD1TMP->D1_TOTAL  + SD1TMP->D1_ICMSRET
		If IsMoney(cE5TIPO)
			nDevDin				+= SD1TMP->D1_TOTAL  + SD1TMP->D1_ICMSRET
		EndIf
	Else
		aCaixa[P_DEVOLUCAO] += SD1TMP->D1_TOTAL
		If IsMoney(cE5TIPO)
			nDevDin				+= SD1TMP->D1_TOTAL 
		EndIf
	EndIf
	SD1TMP->( dbSkip() )
EndDo

SD1TMP->( dbCloseArea() )

//Se sangria utilizando apenas dinheiro estiver habilitada ( MV_LJ350MV == 1 ), adiciona os valores para o array de sangria
//Tratamento necessario para evitar divergencia no Resumo de Caixa
If lSangDin

	cQuery := "SELECT SUM(LT_VLRDIG) VALOR, LT_FORMPG"  
	cQuery += " FROM " + RetSQLName("SLT")
	cQuery += " WHERE LT_FILIAL IN(" + cRetFil + ")" 
	cQuery += " AND LT_DTMOV BETWEEN '" + DToS(dDataDe) + "' AND '" + DToS(dDataAte) + "'"
	cQuery += " AND LT_OPERADO IN(" + cRetCx + ")"			
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY LT_FORMPG"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), "SLTTMP", .F., .T.)
	
	//Alimenta array de sangrias diferentes de dinheiro
	While SLTTMP->(!EOF())
		If SLTTMP->VALOR > 0						
			Do Case
				Case RTrim(SLTTMP->LT_FORMPG) == "CH"
					aCaixa[P_SANG_CHEQUE] += SLTTMP->VALOR
				Case RTrim(SLTTMP->LT_FORMPG) == "CC"
					aCaixa[P_SANG_CARTAO] += SLTTMP->VALOR
				Case RTrim(SLTTMP->LT_FORMPG) == "VA"
					aCaixa[P_SANG_VALE] += SLTTMP->VALOR
				Case RTrim(SLTTMP->LT_FORMPG) == "CO"
					aCaixa[P_SANG_CONVENIO] += SLTTMP->VALOR
				Case RTrim(SLTTMP->LT_FORMPG) == "FI"
					aCaixa[P_SANG_FINANCIADO] += SLTTMP->VALOR
				Case RTrim(SLTTMP->LT_FORMPG) == "CD"
					aCaixa[P_SANG_DEBAUTO] += SLTTMP->VALOR
				Case RTrim(SLTTMP->LT_FORMPG) == "OU"
					aCaixa[P_SANG_OUTROS] += SLTTMP->VALOR
				Case RTrim(SLTTMP->LT_FORMPG) == "CR"
					aCaixa[P_SANG_OUTROS] += SLTTMP->VALOR
				Case RTrim(SLTTMP->LT_FORMPG) == "PD"
					aCaixa[P_SANG_PAGDIG] += SLTTMP->VALOR
				Case RTrim(SLTTMP->LT_FORMPG) == "PX"
					aCaixa[P_SANG_PAGPIX] += SLTTMP->VALOR
				Otherwise	
					aCaixa[P_SANG_OUTROS] += SLTTMP->VALOR
			EndCase
		EndIf
		
		SLTTMP->(dbSkip())
	EndDo
	
	SLTTMP->(dbCloseArea())			
	
EndIf

DbSelectArea( cAlias )

Return aCaixa
//------------------------------------------------------------------
/*/{Protheus.doc} Lj130Dados()
Função que alimenta totalizadores por referência e vetores de Dados
aDadosVen e aDadosSan a partir de aCaixa recebido como parametro.
@type function

@author Marcos Iurato Junior
@since 09/09/2019
@version P12.1.25

@param aCaixa, array, Array com os valores do caixa                     
@param nOpcao, numérico, Define qual elemento do ListBox recebeu o DbClick 
@param nDados, numérico, Define qual ListBox recebeu o DbClick             
@param nTrocoSaida, numérico, Somatoria dos trocos de saida                     
@param nTroco, numérico, Valor da entrada de troco                         
@param nTotCredito, numérico, Valor total de credito                            
@param nTotDebito, numérico, Valor total de debito                             
@param nSaldFinal, numérico, Saldo final do caixa                              
@param nEstac, numérico, Valor referente ao estacionamento (restaurante)   
@param nGorjeta, numérico, Valor referente a gorjeta (restaurante)          
@param aDadosVen, array, Array com os dados das vendas                    
@param aSinal, array, Array com os sinais realizados                   
@param aDDown, array, Array com o segundo nivel das opcoes             
@param aContFina, array, Array utilizado nos tipos de finalizadores  	  
@param aDadosSan, array, Array com os dados da sangria      			  
@param nVlrCred, numérico, Valor do credito utilizado na compensacao do NCC 
@param aRecCelular, array, Valor das recargas de celular
@param nDevDin, numérico, Valor total de devoluções a dinheiro
@param aEstRec, array, valor dos estornos de recebimentos

@return Nil, nil, retorna nil
/*/
//------------------------------------------------------------------
Static Function Lj130Dados(	aCaixa		, nOpcao		, nDados		, nTrocoSaida,;
							nTroco		, nTotCredito	, nTotDebito	, nSaldFinal,;
							nEstac 		, nGorjeta		, aDadosVen		, aSinal	,;
							aDDown		, aContFina		, aDadosSan     , nVlrCred	,;
							aRecCelular	, nDevDin		, aEstRec )

Local aCaixaStr := {}     					                    //Array auxiliar de aCaixa com o s valores da venda
Local nI        := 0 											//variavel de LOOP
Local bTab                                                      //Bloco para definir espacos
Local cOpcao    := ""                                           //Opcao que foi selecionada com DblClick no ListBox
Local cOpcaoVen := ""	                                        //Opcao que foi selecionada com DblClick no ListBox
Local nX		:= 0
Local nPosAd	:= 0
Local nPosaTotF	:= 0
Local aTotForms:= {}
Local nValTotDIN:= 0
Local nValTotCH	:= 0
Local nValTotCC	:= 0
Local nValTotVA	:= 0
Local nValTotCO	:= 0
Local nValTotFI	:= 0
Local nValTotCD	:= 0
Local nValTotOTS:= 0
Local nEstDin   := 0
Local nValPagDig:= 0
Local nValPagPIX:= 0
Local lCxJaFech	:= .F.	// Guarda se já foi efetuado alguma sangria no movimento

nTrocoSaida := aCaixa[P_TROCO_SAIDA]
                  
bTab      := { |x| Space( 30 - Len(x) ) }
nTroco    := aCaixa[P_TROCO]			// Saldo Inicial
nEstac	  := aCaixa[P_VEND_ESTACIO]
nGorjeta  := aCaixa[P_VEND_SERVICO]
nEstDin   := aCaixa[P_ESTORNO]

If nOpcao == NIL
	nOpcao    := 0
EndIf

If nOpcao <> 0                     
	If nDados = 1 
		cOpcao := aDadosVen[ nOpcao, 1 ]
	Else
		cOpcaoVen := aDadosSan[ nOpcao, 1 ]        
	EndIf
Else
	cOpcao := ""
	cOpcaoVen := ""	
EndIf	

aDadosSan := {} 
aDadosVen := {}       

// Cria vetor com os valores em string para formar a unica coluna
For nI := 1 to Len( aCaixa )
	AAdd( aCaixaStr, Transform( aCaixa[ nI ], "@E 9,999,999.99" ) )
Next nI

For nX := 1 To 3
	If nX == 1
		nPosAd := 8
	ElseIf nX == 2
		nPosAd := 11
	Else
		nPosAd := 7
	EndIf
	
	For nI := 1 To Len(aDDown[nPosAd])
		nPosaTotF := Ascan(aTotForms,{|x| Alltrim(x[1]) == IIF(nPosAd <> 7 .And. (aDDown[nPosAd][nI][5] != "CR" ) ,Alltrim(aDDown[nPosAd][nI][5]),"PCC")})
		If !(aDDown[nPosAd][nI][1] == "NCC")
			If nPosaTotF > 0
				aTotForms[nPosaTotF][2] += aDDown[nPosAd][nI][2]
			Else
				Aadd(aTotForms,{IIF(nPosAd <> 7 .And. (aDDown[nPosAd][nI][5] != "CR" ) ,aDDown[nPosAd][nI][5],"PCC"),aDDown[nPosAd][nI][2]})	//PCC = Outros Créditos
			EndIf
		EndIf
	Next nI
Next nX

If (nPosaTotF := Ascan(aTotForms,{|x| Alltrim(x[1]) == "R$"})) > 0
	nValTotDIN := aTotForms[nPosaTotF][2]
EndIf

If (nPosaTotF := Ascan(aTotForms,{|x| Alltrim(x[1]) == "CH"})) > 0
	nValTotCH := aTotForms[nPosaTotF][2]
EndIf

If (nPosaTotF := Ascan(aTotForms,{|x| Alltrim(x[1]) == "CC"})) > 0
	nValTotCC := aTotForms[nPosaTotF][2]
EndIf

If (nPosaTotF := Ascan(aTotForms,{|x| Alltrim(x[1]) == "VA"})) > 0
	nValTotVA := aTotForms[nPosaTotF][2]
EndIf

If (nPosaTotF := Ascan(aTotForms,{|x| Alltrim(x[1]) == "CO"})) > 0
	nValTotCO := aTotForms[nPosaTotF][2]
EndIf

If (nPosaTotF := Ascan(aTotForms,{|x| Alltrim(x[1]) == "FI"})) > 0
	nValTotFI := aTotForms[nPosaTotF][2]
EndIf

If (nPosaTotF := Ascan(aTotForms,{|x| Alltrim(x[1]) == "CD"})) > 0
	nValTotCD := aTotForms[nPosaTotF][2]
EndIf

If (nPosaTotF := Ascan(aTotForms,{|x| Alltrim(x[1]) == "PCC"})) > 0
	nValTotOTS := aTotForms[nPosaTotF][2]	
EndIf

If (nPosaTotF := Ascan(aTotForms,{|x| Alltrim(x[1]) == "PCD"})) > 0
	nValTotOTS += aTotForms[nPosaTotF][2]
EndIf

If (nPosaTotF := Ascan(aTotForms,{|x| Alltrim(x[1]) == "PD"})) > 0
	nValPagDig += aTotForms[nPosaTotF][2]
EndIf

If (nPosaTotF := Ascan(aTotForms,{|x| Alltrim(x[1]) == "PX"})) > 0
	nValPagPIX += aTotForms[nPosaTotF][2]
EndIf

aadd(aDadosSan,{ Padr( STR0005, 62 ),aCaixaStr[P_SANG_DINHEIRO  ], aCaixa[P_SANG_DINHEIRO  	], Transform( ( (aCaixa[P_VEND_DINHEIRO] + nValTotDIN + aCaixa[P_TROCO] - nTrocoSaida - nDevDin - nEstDin ) - aEstRec[P_VEND_DINHEIRO  	] - aCaixa[P_SANG_DINHEIRO  ]), "@E 9,999,999.99" ) }) //"Dinheiro"
aadd(aDadosSan,{ Padr( STR0068, 56 ),aCaixaStr[P_SANG_DEBAUTO   ], aCaixa[P_SANG_DEBAUTO   	], Transform( ( (aCaixa[P_VEND_DEBAUTO] + nValTotCD )	- aEstRec[P_VEND_DEBAUTO  	] - aCaixa[P_SANG_DEBAUTO  	]), "@E 9,999,999.99" ) }) 	//"Cartöes de Débito"
aadd(aDadosSan,{ Padr( STR0007, 55 ),aCaixaStr[P_SANG_CARTAO    ], aCaixa[P_SANG_CARTAO    	], Transform( ( (aCaixa[P_VEND_CARTAO] + nValTotCC )	- aEstRec[P_VEND_CARTAO  	] - aCaixa[P_SANG_CARTAO  	]), "@E 9,999,999.99" ) }) 	//"Cartöes de Crédito"
aadd(aDadosSan,{ Padr( STR0006, 60 ),aCaixaStr[P_SANG_CHEQUE    ], aCaixa[P_SANG_CHEQUE    	], Transform( ( (aCaixa[P_VEND_CHEQUE] + nValTotCH )	- aEstRec[P_VEND_CHEQUE  	] - aCaixa[P_SANG_CHEQUE  	]), "@E 9,999,999.99" ) }) 	//"Cheques"
aadd(aDadosSan,{ Padr( STR0010, 60 ),aCaixaStr[P_SANG_FINANCIADO], aCaixa[P_SANG_FINANCIADO	], Transform( ( (aCaixa[P_VEND_FINANCIADO] + nValTotFI )- aEstRec[P_VEND_FINANCIADO	] - aCaixa[P_SANG_FINANCIADO	]), "@E 9,999,999.99" ) })//"Financiado"
aadd(aDadosSan,{ Padr( STR0081, 55 ),aCaixaStr[P_SANG_VALE      ], aCaixa[P_SANG_VALE      	], Transform( ( (aCaixa[P_VEND_VALE] + nValTotVA )		- aEstRec[P_VEND_VALE  		] - aCaixa[P_SANG_VALE  		]), "@E 9,999,999.99" ) }) 		//"Vales/Despesas"
aadd(aDadosSan,{ Padr( STR0008, 59 ),aCaixaStr[P_SANG_CONVENIO  ], aCaixa[P_SANG_CONVENIO  	], Transform( ( (aCaixa[P_VEND_CONVENIO] + nValTotCO )	- aEstRec[P_VEND_CONVENIO 	] - aCaixa[P_SANG_CONVENIO 	]), "@E 9,999,999.99" ) }) 	//"Convênios"
aadd(aDadosSan,{ Padr( STR0082, 63 ),aCaixaStr[P_SANG_OUTROS    ], aCaixa[P_SANG_OUTROS    	], Transform( ( (aCaixa[P_VEND_OUTROS] + nValTotOTS )	- aEstRec[P_VEND_OUTROS  	] - aCaixa[P_SANG_OUTROS  	]), "@E 9,999,999.99" ) }) 	//"Outros (incluindo Crédito Venda)"
aadd(aDadosSan,{ Padr( STR0022, 58 ),aCaixaStr[P_PAGAMENTOS     ], aCaixa[P_PAGAMENTOS     	], "" }) 	//"Pagamentos"
aadd(aDadosSan,{ Padr( STR0023, 57 ),aCaixaStr[P_TRANSF_ORIGEM  ], aCaixa[P_TRANSF_ORIGEM  	], "" }) 	//"Transferências"
aadd(aDadosSan,{ Padr( STR0013, 59 ),aCaixaStr[P_DEVOLUCAO      ], aCaixa[P_DEVOLUCAO      	], "" }) 	//"Devoluçöes"
aadd(aDadosSan,{ Padr( STR0032, 62 ),aCaixaStr[P_ESTORNO		], aCaixa[P_ESTORNO			], "" }) 	//"Estorno"
AAdd(aDadosSan,{ Padr( STR0027, 52 ),aCaixaStr[P_SANG_IMPOSTOS  ], aCaixa[P_SANG_IMPOSTOS	], "" })	//"Retenção de Impostos"
AAdd(aDadosSan,{ Padr( STR0079, 52 ),aCaixaStr[P_ESTORNO_REC	], aCaixa[P_ESTORNO_REC		], "" })	//"Recebimentos Estornados"

If SL1->(ColumnPos("L1_VLRPGDG")) > 0 //Verifica se existe o campo onde é gravado o valor da venda paga em Pagamento Digital
    aadd(aDadosSan,{ Padr( STR0083, 55 ),aCaixaStr[P_SANG_PAGDIG    ], aCaixa[P_SANG_PAGDIG    	], Transform( ( (aCaixa[P_VEND_PAGDIG] + nValPagDig )- aCaixa[P_SANG_PAGDIG  	]), "@E 9,999,999.99" ) }) 	//"Pagamento Digital"
EndIf

If SL1->(ColumnPos("L1_VLRPGPX")) > 0 //Verifica se existe o campo onde é gravado o valor da venda paga em Pagamento Digital
    aadd(aDadosSan,{ Padr( STR0084, 55 ),aCaixaStr[P_SANG_PAGPIX    ], aCaixa[P_SANG_PAGPIX    	], Transform( ( (aCaixa[P_VEND_PAGPIX] + nValPagPIX )- aCaixa[P_SANG_PAGPIX  	]), "@E 9,999,999.99" ) }) 	//"Pagamento PIX"
EndIf

lCxJaFech := 	aCaixa[P_SANG_DINHEIRO	] > 0 .OR. aCaixa[P_SANG_CHEQUE    ] > 0 .OR.;
				aCaixa[P_SANG_CARTAO  	] > 0 .OR. aCaixa[P_SANG_VALE      ] > 0 .OR.;
				aCaixa[P_SANG_CONVENIO	] > 0 .OR. aCaixa[P_SANG_FINANCIADO] > 0 .OR.;
				aCaixa[P_SANG_DEBAUTO 	] > 0 .OR. aCaixa[P_PAGAMENTOS     ] > 0 .OR.;
				aCaixa[P_TRANSF_ORIGEM	] > 0 .OR. aCaixa[P_SANG_OUTROS    ] > 0 .OR.; 
				aCaixa[P_SANG_IMPOSTOS  ] > 0 .OR. aCaixa[P_ESTORNO	       ] > 0 .OR.;
				aCaixa[P_ESTORNO_REC	] > 0 .OR.aCaixa[P_SANG_PAGDIG     ] > 0 .OR.;
				aCaixa[P_SANG_PAGPIX	] > 0 

nTotDebito := 	aCaixa[P_SANG_DINHEIRO	] + aCaixa[P_SANG_CHEQUE    ] + ;
				aCaixa[P_SANG_CARTAO  	] + aCaixa[P_SANG_VALE      ] + ;
				aCaixa[P_SANG_CONVENIO	] + aCaixa[P_SANG_FINANCIADO] + ;
				aCaixa[P_SANG_DEBAUTO 	] + aCaixa[P_PAGAMENTOS     ] + ;
				aCaixa[P_TRANSF_ORIGEM	] + aCaixa[P_DEVOLUCAO      ] + ;
				aCaixa[P_SANG_OUTROS  	] + aCaixa[P_SANG_IMPOSTOS  ] + ;
				aCaixa[P_ESTORNO	    ] + aCaixa[P_ESTORNO_REC	] + ;
				aCaixa[P_SANG_PAGDIG	] + aCaixa[P_SANG_PAGPIX	] - ;
				IIf(lCxJaFech, aCaixa[P_DEVBAIXA], 0)

aadd(aDadosVen,{Padr( STR0005, 63 ),RTrim(aCaixaStr[P_VEND_DINHEIRO])	,Alltrim(Space(05)), aCaixa[P_VEND_DINHEIRO] })					//"Dinheiro"
aadd(aDadosVen,{Padr( STR0068, 57 ),RTrim(aCaixaStr[P_VEND_DEBAUTO])	,Alltrim(Str(aContFina[5],10)), aCaixa[P_VEND_DEBAUTO]   }) 	//"Cartão de debito"
aadd(aDadosVen,{Padr( STR0007, 55 ),RTrim(aCaixaStr[P_VEND_CARTAO])		,Alltrim(Str(aContFina[1],10)), aCaixa[P_VEND_CARTAO]   }) 		//"Cartão de Credito"
aadd(aDadosVen,{Padr( STR0006, 60 ),RTrim(aCaixaStr[P_VEND_CHEQUE])		,Alltrim(Str(aContFina[6],10)), aCaixa[P_VEND_CHEQUE]   }) 		//"Cheques"
aadd(aDadosVen,{Padr( STR0010, 60 ),RTrim(aCaixaStr[P_VEND_FINANCIADO])	,Alltrim(Str(aContFina[4],10)), aCaixa[P_VEND_FINANCIADO]   })	//"Financiado"
aadd(aDadosVen,{Padr( STR0063, 57 ),RTrim(aCaixaStr[P_VEND_CREDITO])	,Alltrim(Str(aContFina[8],10)), aCaixa[P_VEND_CREDITO]   }) 	//"Credito Vendas"
aadd(aDadosVen,{Padr( STR0009, 58 ),RTrim(aCaixaStr[P_VEND_VALE])		,Alltrim(Str(aContFina[2],10)), aCaixa[P_VEND_VALE]   }) 		//"Vales"
aadd(aDadosVen,{Padr( STR0008, 60 ),RTrim(aCaixaStr[P_VEND_CONVENIO])	,Alltrim(Str(aContFina[3],10)), aCaixa[P_VEND_CONVENIO]   }) 	//"Convenio"
aadd(aDadosVen,{Padr( STR0011, 65 ),RTrim(aCaixaStr[P_VEND_OUTROS])		,Alltrim(Str(aContFina[7],10)), aCaixa[P_VEND_OUTROS]   }) 		//"Outros"
aadd(aDadosVen,{Padr( STR0024, 55 ),RTrim(aCaixaStr[P_RECEBIMENTOS])	,Alltrim(Str(aContFina[9],10)), aCaixa[P_RECEBIMENTOS]}) 		//"Recebimentos"
aadd(aDadosVen,{Padr( STR0064, 60 ),RTrim(aCaixaStr[P_REC_CARTFID])		,Alltrim(Str(aContFina[11],10)), aCaixa[P_REC_CARTFID]})		//"Recargas Fidelidade"
aadd(aDadosVen,{Padr( STR0065, 60 ),RTrim(aCaixaStr[P_VEND_CARTFID])	,Alltrim(Str(aContFina[10],10)), aCaixa[P_VEND_CARTFID]})		//"(-) Vendas Com Fidelidade
aadd(aDadosVen,{Padr( STR0066, 60 ),RTrim(aCaixaStr[P_REC_CELULAR])		,Alltrim(Str(aContFina[10],10)), aCaixa[P_REC_CELULAR]}) 		//"Recarga de Celular
aadd(aDadosVen,{Padr( STR0023, 59 ),RTrim(aCaixaStr[P_TRANSF_DESTINO])	,Alltrim(Space(05)), aCaixa[P_TRANSF_DESTINO]}) 				//"Transferências"

If SL1->(ColumnPos("L1_VLRPGDG")) > 0 //Verifica se existe o campo onde é gravado o valor da venda paga em Pagamento Digital
    aadd(aDadosVen,{Padr( STR0083 , 57 ),RTrim(aCaixaStr[P_VEND_PAGDIG])	    ,Alltrim(Str(aContFina[12],10)), aCaixa[P_VEND_PAGDIG]   }) 	//"Pagamento Digital"
EndIf

If SL1->(ColumnPos("L1_VLRPGPX")) > 0 //Verifica se existe o campo onde é gravado o valor da venda paga em Pagamento Digital
    aadd(aDadosVen,{Padr( STR0084 , 57 ),RTrim(aCaixaStr[P_VEND_PAGPIX])	    ,Alltrim(Str(aContFina[13],10)), aCaixa[P_VEND_PAGPIX]   }) 	//"Pagamento PIX"
EndIf

nTotCredito :=	aCaixa[P_VEND_DINHEIRO 	] + aCaixa[P_VEND_CHEQUE    ] + ;
				aCaixa[P_VEND_CARTAO   	] + aCaixa[P_VEND_VALE      ] + ;
				aCaixa[P_VEND_CONVENIO 	] + aCaixa[P_VEND_FINANCIADO] + ;
				aCaixa[P_VEND_DEBAUTO  	] + aCaixa[P_VEND_CREDITO   ] + ;
				aCaixa[P_VEND_OUTROS   	] + aCaixa[P_TRANSF_DESTINO ] + ;
				aCaixa[P_RECEBIMENTOS  	] /*- aCaixa[P_VEND_CARTFID ]*/ - ;
				nVlrCred                 + aCaixa[P_SANG_IMPOSTOS	] + ;
				aCaixa[P_REC_CARTFID	] + aCaixa[P_REC_CELULAR	] + ;
				aCaixa[P_VEND_PAGDIG	] + aCaixa[P_VEND_PAGPIX	]

nSaldFinal := nTroco + nTotCredito - nTotDebito - nTrocoSaida

Return(NIL)

//------------------------------------------------------------------
/*/{Protheus.doc} IncAvalFor()
Função para ajustar o Nivel 
@type function

@author Marcos Iurato Junior
@since 09/09/2019
@version P12.1.25

@param aAux, array, Auxiliar
@param aValForma, array, Valor da forma de pagamento

@return lógico
/*/
//------------------------------------------------------------------
Static Function IncAvalForma(aAux, aValForma)
Local nI 	:= 0 // variavel de loop
Local nJ 	:= 0 // variavel de loop
Local nPos	:= 0 // Variavel auxiliar
    
For nI := 1 To Len(aAux)
	If nI > Len(aValForma)
		AAdd(aValForma,{})		
	EndIf
	If Len(aAux[nI])>0
		For nJ := 1 To Len(aAux[nI])
			nPos := aScan( aValForma[nI], { |x| x[1] == aAux[nI][nJ][1] } )
			If nPos<>0
				aValForma[nI,nPos,3] += aAux[nI][nJ][3]
				aValForma[nI,nPos,4] += aAux[nI][nJ][4]
			Else
				AAdd( aValForma[nI], AClone(aAux[nI][nJ]) )
			EndIf						
		Next nJ
	EndIf
Next nI
	
Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} LJ130EST()
Obtem o Numerario ao qual foi efetuado o Estorno.
@type function

@author Marcos Iurato Junior
@since 09/09/2019
@version P12.1.25

@param lUsaParam, lógico, Usa parametro
@param dDataMovto, data, Data de movimento
@param cCaixa, carácter, Código do caixa
@param cRetFil, carácter, Retorna as filiais
@param cRetCx, carácter, Retorna os caixas 
@param dDataDe, data, Data de
@param dDataAte, data, Data até


@return, array,  Contendo informações das formas de pagamento, valor e quantidade de docs
/*/
//------------------------------------------------------------------
Static Function LJ130EST(lUsaParam, dDataMovto, cCaixa, cRetFil, cRetCx, dDataDe, dDataAte)

    Local aArea       := GetArea()       
    Local cFormaDescr := ""
    Local cAliasTmp	  := GetNextAlias()

    Private aEstorno  := {}
    Private _cSql	  := ""   

    Default cRetFil	 := ""
    Default cRetCx	 := ""
    Default dDataDe	 := CtoD("  /  /  ")
    Default dDataAte := CtoD("  /  /  ")

    // Query para as formas diferentes de cheques
    _cSql:=    "SELECT SL4.L4_FORMA, SL4.L4_ADMINIS,  SUM(L4_VALOR) AS L4_VALOR , COUNT(*) AS L4_QUANT  FROM " +;
                RetSQLName("SL1") + " SL1 , " + RetSQLName("SL4") + " SL4 "
    _cSql+=  	" WHERE SL4.L4_FILIAL IN(" + cRetFil + ")" +;
                " AND SL1.L1_EMISSAO BETWEEN '" + DToS(dDataDe) + "' AND '" + DToS(dDataAte) + "'" +;
                " AND SL4.L4_OPERAES IN(" + cRetCx + ")"

    _cSql:= _cSql + " AND SL4.L4_ESTORN = 'S' "+;
                    " AND SL1.L1_STATUES <> ' ' "+;
                    " AND SL1.L1_FILIAL = SL4.L4_FILIAL AND SL1.L1_NUM = SL4.L4_NUM "+;
                    " AND SL1.D_E_L_E_T_  = ' ' AND SL4.D_E_L_E_T_  = ' ' "

    _cSql:=_cSql+" AND L4_FORMA <> 'CH'  "+;
                    " GROUP BY L4_FORMA, L4_ADMINIS ORDER BY L4_FORMA, L4_ADMINIS"
        
    cQuery := ChangeQuery(_cSql)
    dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .F., .T.)

    While !(cAliasTmp)->( Eof() )
        
        SX5->(DbSetOrder(1))
        SX5->(DbSeek(xFilial("SX5")+'24'+ (cAliasTmp)->L4_FORMA))
        cFormaDescr := SX5->X5_DESCRI
            
        aAdd(aEstorno ,{"   " + substr(cFormaDescr,1,13) + " " + substr((cAliasTmp)->L4_ADMINIS,5,19) + Transform((cAliasTmp)->L4_VALOR, "@e 99,999.99" ), (cAliasTmp)->L4_VALOR , (cAliasTmp)->L4_QUANT } )

        (cAliasTmp)->( DbSkip() )
    Enddo 
    (cAliasTmp)->( dbCloseArea() )

    _cSql:=  "SELECT SL4.L4_FORMA, SUM(L4_VALOR) AS L4_VALOR , COUNT(*) AS L4_QUANT  FROM " +;
                RetSQLName("SL1") + " SL1 , " + RetSQLName("SL4") + " SL4 "
    _cSql+=  "  WHERE SL4.L4_FILIAL IN(" + cRetFil + ")" +;
            " AND SL1.L1_EMISSAO BETWEEN '" + DToS(dDataDe) + "' AND '" + DToS(dDataAte) + "'" +;
            " AND SL4.L4_OPERAES IN(" + cRetCx + ")"		

    _cSql:=_cSql+" AND SL4.L4_ESTORN ='S' "+;
                " AND  SL1.L1_STATUES <> ' ' " +;
                " AND SL1.L1_FILIAL = SL4.L4_FILIAL AND SL1.L1_NUM = SL4.L4_NUM "+;
                " AND SL1.D_E_l_E_T_  = ' ' AND SL4.D_E_l_E_T_ = ' ' "

    _cSql:=_cSql+" AND L4_FORMA = 'CH'  "+;
                " GROUP BY L4_FORMA ORDER BY L4_FORMA"
        
    cQuery := ChangeQuery(_cSql)
    dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .F., .T.)

    While !(cAliasTmp)->( Eof() )
        SX5->(DbSetOrder(1))
        SX5->(DbSeek(xFilial("SX5")+'24'+ (cAliasTmp)->L4_FORMA))
        cFormaDescr := SX5->X5_DESCRI
            
        aAdd(aEstorno ,{"   " + substr(cFormaDescr,1,30) + Transform((cAliasTmp)->L4_VALOR, "@e 99,999.99" ), (cAliasTmp)->L4_VALOR , (cAliasTmp)->L4_QUANT } )

        (cAliasTmp)->( DbSkip() )
    Enddo
    (cAliasTmp)->( dbCloseArea() )

    RestArea(aArea)

Return aEstorno

//------------------------------------------------------------------
/*/{Protheus.doc} ValDate()
Valida a data de digitação
@type function

@author Marcos Iurato Junior
@since 09/09/2019
@version P12.1.25

@param dDataDe, data, Data de 
@param dDataAte, data, Data até

@return, lógico, Verifica a integridade das datas imputadas
/*/
//------------------------------------------------------------------
Static Function ValDate(dDataDe,dDataAte)
Local lRet := .T.

IF dDataAte < dDataDe
	lRet := .F.
	Alert(STR0069) //Atenção! A DATA FINAL não pode ser inferior a DATA INICIAL
Endif

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} C()
Funcao responsavel por manter o Layout independente da resolucao 
horizontal do Monitor do Usuario.

@author Norbert/Ernani/Mansano
@since 10/05/2005
@version P11

@param nTam, numérico, Tamanho representando a resolução da tela

@return, numérico, Tamanho representando a resolução da tela
/*/
//------------------------------------------------------------------
Static Function C(nTam)                                                         
Local nWRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     

If nWRes < 700							// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
	nTam *= 0.4                                                                
ElseIf nWRes > 701 .and. nWRes < 899	// Resolucao 800x600                
	nTam *= 0.5                                                                  
ElseIf nWRes > 900 .and. nWRes < 1200   // Resolucao 1024x768
	nTam *= 0.68                                                              
ElseIf nWRes > 1201 .and. nWRes < 1320	// 
	nTam *= 0.8                                                               
ElseIf nWRes > 1321 .and. nWRes < 1500	// Resolucao 1366x768 
	nTam *= 0.8                                                               	
ElseIf nWRes > 1850 					// Resolucao 1920x1080 
	nTam *= 1.2                                                               	
Else
	nTam *= 1
EndIf                                                                         
                                                                                
Return Int(nTam)                                                                

//------------------------------------------------------------------
/*/{Protheus.doc} LJC130Proces()
Efetua o processamento das informações.
@type function

@author Marcos Iurato Junior
@since 09/09/2019
@version P12.1.25

@param dDataDe, data, Data de
@param dDataAte, data, Data até
@param aFiliais, data, Filiais selecionadas
@param aCaixas, array, Caixas selecionados
@param lmv_ljtroco, logico, Verifica se o parametro MV_LJTROCO esta ativo
@param aDDown, array, Controla o Drill Down
@param aContFina, array, Controle financeiro 
@param nVlrCred, numerico, Valor do Crédito
@param lSomaCred, logico, Se soma o credito ou não
@param lUsaNmov, logico, Se usa ou não movimentação
@param aLacAnalitico, array, Contém os lançamentos analíticos
@param nTrocoSaida, numérico, Troco saída
@param nTroco, numérico, Valor do Troco
@param nTotCredito, numérico, Valor total de credito
@param nTotDebito, numérico, Valor total de débito
@param nSaldFinal, numérico Valor do saldo final
@param nEstac, numérico,  Valor do estacionamento
@param nGorjeta, numérico, Valor da gorjeta
@param aDadosVen, array, Dados da venda
@param aSinal, array, Sinal
@param aDadosSan, array, Dados da Sangria
@param aDetSangria, array, Detalhamento da sangria
@param oMovSan, objeto, Movimento da sangria
@param oMovVenDet, objeto, Movimento do detalhamento da venda
@param oMovVenLan, objeto, Movimento dos lançamentos das vendas 
@param aAnalitLanc, array, Lançamento analitico
@param aVerifVenda, array, Verificação da venda
@param aRecCelular, array, Recarga de celular
@param nDevDin, numérico, Valor total de devoluções a dinheiro
@param aEstRec, array, valor dos estornos de recebimentos

@return Nil, nil, Retorno nil
/*/
//------------------------------------------------------------------
Static Function LjC130Proces(	dDataDe	,	dDataAte	,	aFiliais		,	aCaixas	,;
							lMV_LJTROCO	,	aDDown		,	aContFina 		, 	nVlrCred	,;
							lSomaCred  	, 	lUsaNmov 	,	aLacAnalitico	, 	nTrocoSaida	,;
						    nTroco		, 	nTotCredito	, 	nTotDebito		, 	nSaldFinal	,;
						    nEstac		, 	nGorjeta	, 	aDadosVen		, 	aSinal		,;
						    aDadosSan	, 	oMovVen		,	oMovSan			,	aDetSangria	,;
						    oMovVenDet	, 	oMovVenLan	, 	aAnalitLanc		,	aVerifVenda ,;
							aRecCelular	,	nDevDin		,	aEstRec	)

Local nX 			:= 1
Local cRetFil		:= ""
Local cRetCx		:= ""
Local cCaixa 	 	:= "   "                                           
Local dDataMovto 	:= dDataBase										

Default aLacAnalitico := {}
Default aRecCelular	  := {}

aDetSangria := {}

aVerifVenda	:= {{"","","","",""}}
aAnalitLanc	:= {{"","","","","","","","" }}

nDevDin  := 0		//O processo de cálculo de devoluções deverá ser iniciado aqui, após clicar no botão "Processar", evitando cálculos incorretos ao clicar a partir da segunda vez.
nVlrCred := 0

oMovVenDet:SetArray(aVerifVenda)
oMovVenDet:bLine := {|| { aVerifVenda[oMovVenDet:nAt][1],aVerifVenda[oMovVenDet:nAt][2],aVerifVenda[oMovVenDet:nAt][4] }}
oMovVenDet:Refresh()

oMovVenLan:SetArray(aAnalitLanc)
oMovVenLan:bLine := {|| { 	aAnalitLanc[oMovVenLan:nAt][1],aAnalitLanc[oMovVenLan:nAt][2],aAnalitLanc[oMovVenLan:nAt][3],;
							aAnalitLanc[oMovVenLan:nAt][4],aAnalitLanc[oMovVenLan:nAt][5],aAnalitLanc[oMovVenLan:nAt][6],;
							aAnalitLanc[oMovVenLan:nAt][7],aAnalitLanc[oMovVenLan:nAt][8]}}
oMovVenLan:Refresh()

For nX := 1 To Len(aFiliais)
	If aFiliais[nX][1]
		cRetFil += "'" + Alltrim(aFiliais[nX][2]) + "'" + ","
	EndIf
Next nX

cRetFil := SubStr(cRetFil, 1 , Len(cRetFil)-1)

For nX := 1 To Len(aCaixas)
	If aCaixas[nX][1]
		cRetCx += "'" + Alltrim(aCaixas[nX][2]) + "'" + ","
	EndIf
Next nX

cRetCx := SubStr(cRetCx, 1 , Len(cRetCx)-1)

If !Empty(cRetFil) .AND. !Empty(cRetCx)

	aCaixa := MovimCaixa( cCaixa	 	, dDataMovto	, lMV_LJTROCO	, @aDDown 	,;
						  @aContFina 	, @nVlrCred		, lSomaCred		, lUsaNmov 	,;
						  @aLacAnalitico, cRetFil 		, cRetCx		, dDataDe	,;
						  dDataAte		, @aDetSangria	, @aRecCelular	, @nDevDin	, @aEstRec )

	// Alimenta Totalizadores / Arrays aDados...
	Lj130Dados(	aCaixa	, NIL			, Nil			, @nTrocoSaida	,;
			    @nTroco	, @nTotCredito	, @nTotDebito	, @nSaldFinal	,;
			    @nEstac	, @nGorjeta		, @aDadosVen	, @aSinal		,;
			    @aDDown	, @aContFina	, @aDadosSan	, nVlrCred		,;
				@aRecCelular, @nDevDin	, @aEstRec )

	oMovVen:SetArray(aDadosVen)
	oMovVen:bLine := {|| { aDadosVen[oMovVen:nAt][1],aDadosVen[oMovVen:nAt][2],aDadosVen[oMovVen:nAt][3] }}
	oMovVen:Refresh()

	oMovSan:SetArray(aDadosSan)
	oMovSan:bLine := {|| { aDadosSan[oMovSan:nAt][1],aDadosSan[oMovSan:nAt][2],aDadosSan[oMovSan:nAt][4]}}
	oMovSan:Refresh()

Else
	MsgStop(STR0067) //Não foram seleciondas Filiais e Caixas para o processamento
EndIf

LjGrvLog("", "LOJC130 -> Função LjC130Proces finalizada")

Return NIL

//------------------------------------------------------------------
/*/{Protheus.doc} VenDet()
Efetua o processamento dos detalhes do Resumo
@type function

@author Marcos Iurato Junior
@since 09/09/2019
@version P12.1.25

@param oMovVen, objeto, Contem informações ref. ao movimento de devenda
@param aDDown, array, Array contendo o drill down 
@param aVerifVenda, array, Array contendo as vendas verificadas
@param oMovVenDet, objeto, Contem informações ref. ao movimento de detalhado de venda
@param aAnalitLanc, array, Contem os lançamentos analiticos a serem apresentados
@param oMovVenLan, objeto, Contem informações ref. ao movimento de devenda
@param aLacAnalitico, array, Contem os lançamentos analiticos a serem apresentados

@return Nil
/*/
//------------------------------------------------------------------
Static Function VenDet(oMovVen,aDDown,aVerifVenda,oMovVenDet,aAnalitLanc,oMovVenLan,aLacAnalitico)

Default aDDown		:= {}
Default aVerifVenda := {}

aVerifVenda 	:= {}

If oMovVen:NAT = 1  		//P_VEND_DINHEIRO 
    //Nada
ElseIF oMovVen:NAT = 2  
	aVerifVenda := aDDown[5] //P_VEND_DEBAUTO
ElseIF oMovVen:NAT = 3  
	aVerifVenda := aDDown[1] //P_VEND_CARTAO
ElseIF oMovVen:NAT = 4  
	aVerifVenda := aDDown[6] //P_VEND_CHEQUE
ElseIF oMovVen:NAT = 5  
	aVerifVenda := aDDown[4] //P_VEND_FINANCIADO	
ElseIF oMovVen:NAT = 6  
	aVerifVenda := aDDown[7] //P_VEND_CREDITO
ElseIF oMovVen:NAT = 7  
	aVerifVenda := aDDown[2] //P_VEND_VALE
ElseIF oMovVen:NAT = 8  
	aVerifVenda := aDDown[3] //P_VEND_CONVENIO
ElseIF oMovVen:NAT = 9  
	aVerifVenda := aDDown[10] //P_VEND_OUTROS	
ElseIF oMovVen:NAT = 10 
	aVerifVenda := aDDown[8] //P_RECEBIMENTOS 
ElseIF oMovVen:NAT = 11 
	aVerifVenda := aDDown[11] //P_VEND_CARTFID
ElseIF oMovVen:NAT = 12 
	aVerifVenda := aDDown[9] //P_VEND_CARTFID
ElseIF oMovVen:NAT = 13 
	//P_REC_CELULAR	
ElseIF oMovVen:NAT = 14 
	// nada aVerifVenda := aDDown[14]
ElseIF oMovVen:NAT = 15
	aVerifVenda := aDDown[12] //P_VEND_PAGDIG
ElseIF oMovVen:NAT = 16
	aVerifVenda := aDDown[13] //P_VEND_PAGPIX
EndIf

oMovVenDet:SetArray(aVerifVenda)
oMovVenDet:bLine := {|| { aVerifVenda[oMovVenDet:nAt][1],aVerifVenda[oMovVenDet:nAt][3],aVerifVenda[oMovVenDet:nAt][4] }} 
oMovVenDet:Refresh()

LacAnalitico( aLacAnalitico, aAnalitLanc, oMovVen )

oMovVenLan:SetArray(aAnalitLanc)
oMovVenLan:bLine := {|| { 	aAnalitLanc[oMovVenLan:nAt][1],aAnalitLanc[oMovVenLan:nAt][2],aAnalitLanc[oMovVenLan:nAt][3],;
							aAnalitLanc[oMovVenLan:nAt][4],aAnalitLanc[oMovVenLan:nAt][5],aAnalitLanc[oMovVenLan:nAt][6],;
							aAnalitLanc[oMovVenLan:nAt][7],aAnalitLanc[oMovVenLan:nAt][8]}}
oMovVenLan:Refresh()
  
Return NIL

//------------------------------------------------------------------
/*/{Protheus.doc} LacAnalitico()
Efetua o processamento dos Lançamentos Analiticos do Resumo
@type function

@author Marcos Iurato Junior
@since 09/09/2019
@version P12.1.25

@param aLacAnalitico, array, Contem os lançamentos analiticos a serem apresentados
@param aAnalitLanc, array, Contem os lançamentos analiticos a serem apresentados
@param oMovVen, objeto, Contem informações ref. ao movimento de devenda

@return, 
/*/
//------------------------------------------------------------------
Static Function LacAnalitico( aLacAnalitico, aAnalitLanc, oMovVen )

Local nContador := 1				  				//Controle de loop	   
Local aLacBkp	:= aClone(aLacAnalitico)			//Backup do array aLacAnalitico
Local cPicture	:= PesqPict("SL1","L1_VLRTOT",18)	//Picture do campo L1_VLRTOT
Local lContinua := .F.
                                       	
aAnalitLanc	:= {}

If Len(aLacAnalitico) > 0 
    // Filtra os registros do Array - Conforme posicionamento do Cursos na ListBox de Venda.
	aLacBkp := aSort(aLacBkp,,,{|x,y| x[1] < y[1] }) // Organiza o Array pela primeira coluna
	For nContador := 1 to Len(aLacAnalitico)
        lContinua := .F.
		IF oMovVen:NAT = 1  .and. aLacBkp[nContador][1] = P_VEND_DINHEIRO 	    //Movimentação de Dinheiro
            lContinua := .T.

	    ElseIF oMovVen:NAT = 2  .and. aLacBkp[nContador][1] = P_VEND_DEBAUTO    //Movimentação Cartão de Débito
            lContinua := .T.

	    ElseIF oMovVen:NAT = 3  .and. aLacBkp[nContador][1] = P_VEND_CARTAO     //Movimentação Cartão de Credito 
            lContinua := .T.

	    ElseIF oMovVen:NAT = 4  .and. aLacBkp[nContador][1] =  P_VEND_CHEQUE    //Movimentação de Cheque
            lContinua := .T.

	    ElseIF oMovVen:NAT = 5  .and. aLacBkp[nContador][1] = P_VEND_FINANCIADO //Movimentação Financiado
            lContinua := .T.
	    
		ElseIF oMovVen:NAT = 6  .and. aLacBkp[nContador][1] =  P_VEND_CREDITO   //Movimentação de Credito
            lContinua := .T.
	    
		ElseIF oMovVen:NAT = 7  .and. aLacBkp[nContador][1] = P_VEND_VALE		//Movimentação de Vale
            lContinua := .T.

	    ElseIF oMovVen:NAT = 8  .and. aLacBkp[nContador][1] = P_VEND_CONVENIO	//Movimentação Convenio
            lContinua := .T.

	    ElseIF oMovVen:NAT = 9  .and. aLacBkp[nContador][1] = P_VEND_OUTROS   	//Movimentação Outros
            lContinua := .T.

	   ElseIF oMovVen:NAT = 10 .and. aLacBkp[nContador][1] = P_RECEBIMENTOS	    //Movimentação de Impostos
            lContinua := .T.
	    
		ElseIF oMovVen:NAT = 11 .and. aLacBkp[nContador][1] = P_VEND_CARTFID	//Movimentação Fidelidade
            lContinua := .T.
	   
	    ElseIF oMovVen:NAT = 12 .and. aLacBkp[nContador][1] = P_REC_CARTFID	    //Movimentação Cartão Pré Pago
            lContinua := .T.
	    
		ElseIF oMovVen:NAT = 13 .and. aLacBkp[nContador][1] = P_REC_CELULAR     //Movimentação de Recarga Celular
            lContinua := .T.

	    ElseIF oMovVen:NAT = 15 .and. aLacBkp[nContador][1] = P_VEND_PAGDIG     //Movimentação de Pagamento Digital
            lContinua := .T.
		ElseIF oMovVen:NAT = 16 .and. aLacBkp[nContador][1] = P_VEND_PAGPIX     //Movimentação de Pagamento PIX
            lContinua := .T.
		EndIf

        If lContinua
            // Alimenta o array com as informações detalhadas para exibir no LISTBOX
			aAdd(aAnalitLanc, {aLacBkp[nContador][3],; 						// Numero do orçamento
							  aLacBkp[nContador][4],; 						// Operador 
							  aLacBkp[nContador][5],; 						// Data da Venda 
							  Transform( aLacBkp[nContador][6],cPicture),;	// Valor da Venda
							  aLacBkp[nContador][2],; 						// Forma de Pagamento
							  aLacBkp[nContador][7],; 						// Administradora / Banco
							  aLacBkp[nContador][8],; 						// Agencia
							  aLacBkp[nContador][9],; 						// Conta
							  ,.F.})
        EndIf
	Next
Endif

Return

//------------------------------------------------------------------
/*/{Protheus.doc} SangDet()
Efetua o detalhamento da Sangria
@type function

@author Marcos Iurato Junior
@since 09/09/2019
@version P12.1.25

@param oMovSan, objeto, Contem informações ref. ao movimento de sangria
@param aDetSangria, array, Detalhamento da Sangria
@param oMovVenLan, objeto, Contem informações ref. ao lançamento analitico
@param aAnalitLanc, array, Contem os lançamentos analiticos a serem apresentados

@return Nil, nil, Retorno nil
/*/
//------------------------------------------------------------------
Static Function SangDet(oMovSan,aDetSangria,oMovVenLan,aAnalitLanc)

Local cPicture  	:= PesqPict("SL1","L1_VLRTOT",18)
Local aLacSang		:= aClone(aDetSangria)			
Local nX        	:= 1
Local lContinua 	:= .F.
Local cNameOper		:= ""								// Operador do caixa

aAnalitLanc := {}

If Len(aLacSang) > 0 
    // Filtra os registros do Array - Conforme posicionamento do Cursos na ListBox de Venda.
	aLacSang := aSort(aLacSang,,,{|x,y| x[1] < y[1] }) 						// Ordganiza o Array pela primeira coluna
	For nX := 1 to Len(aLacSang)
        
        lContinua := .F.

		IF oMovSan:NAT = 1  .and. aLacSang[nX][1] = P_SANG_DINHEIRO         //Movimentação de dinheiro
            lContinua := .T.

	    ElseIF oMovSan:NAT = 2  .and. aLacSang[nX][1] = P_SANG_DEBAUTO		//Movimentação de Debito Automatico
            lContinua := .T.

	    ElseIF oMovSan:NAT = 3  .and. aLacSang[nX][1] = P_SANG_CARTAO		//Movimentação de Cartão de Credito
            lContinua := .T.

	    ElseIF oMovSan:NAT = 4  .and. aLacSang[nX][1] = P_SANG_CHEQUE	    //Movimentação de Cheques
            lContinua := .T.

	    ElseIF oMovSan:NAT = 5  .and. aLacSang[nX][1] = P_SANG_FINANCIADO	//Movimentação de Finaciado
            lContinua := .T.

	    ElseIF oMovSan:NAT = 6  .and. aLacSang[nX][1] = P_SANG_VALE 		//Movimentação de Vale
            lContinua := .T.

	    ElseIF oMovSan:NAT = 7  .and. aLacSang[nX][1] = P_SANG_CONVENIO     //Movimentação de Convenio
            lContinua := .T.

	    ElseIF oMovSan:NAT = 8  .and. aLacSang[nX][1] = P_SANG_OUTROS		//Movimentação de Outros
            lContinua := .T.

	    ElseIF oMovSan:NAT = 15  .and. aLacSang[nX][1] = P_SANG_PAGDIG		//Movimentação de Pagamento Digital
            lContinua := .T.
		ElseIF oMovSan:NAT = 16  .and. aLacSang[nX][1] = P_SANG_PAGPIX		//Movimentação de Pagamento PIX
            lContinua := .T.
		EndIf

		cNameOper := (Alltrim(aLacSang[nX][6])) + " - " + (Alltrim(Posicione("SA6",1,xFilial("SL4") + Alltrim(aLacSang[nX][6]), "A6_NOME")))

        If lContinua
            // Alimenta o array com as informações detalhadas para exibir no LISTBOX
            aAdd(aAnalitLanc, { aLacSang[nX][2]	,; 		                // Numero da Venda 
								cNameOper		,;						// Operador
                                aLacSang[nX][3]	,; 						// Data da Venda 
                                Transform( aLacSang[nX][4],cPicture),; 	// Valor da Venda
                                aLacSang[nX][5]	,; 						// Forma de Pagamento
                                aLacSang[nX][6]	,; 						// Administradora / Banco
                                aLacSang[nX][7]	,; 						// Agencia
                                aLacSang[nX][8]	,; 						// Conta
                                .F. })
        EndIf

	Next
Endif

oMovVenLan:SetArray(aAnalitLanc)
oMovVenLan:bLine := {|| { 	aAnalitLanc[oMovVenLan:nAt][1],aAnalitLanc[oMovVenLan:nAt][2],aAnalitLanc[oMovVenLan:nAt][3],;
							aAnalitLanc[oMovVenLan:nAt][4],aAnalitLanc[oMovVenLan:nAt][5],aAnalitLanc[oMovVenLan:nAt][6],;
							aAnalitLanc[oMovVenLan:nAt][7],aAnalitLanc[oMovVenLan:nAt][8]}}

oMovVenLan:Refresh()

Return NIL

//------------------------------------------------------------------
/*/{Protheus.doc} FindCash()
Verifica todos os caixas que estão configurados com o usuario
logado como superior
@type function

@author Marcos Iurato Junior
@since 09/09/2019
@version P12.1.25

@param aWBrowseFil, array, Array contendo as filiais selecionadas
@param aWBrowseCx, array, Array contendo os caixas selecionados

@return Nil, Nulo
/*/
//------------------------------------------------------------------
Static Function FindCash(aWBrowseFil,aWBrowseCx)

Local nX				:= 0
Local lAdminis			:= .F.
Local aAreaSLF 			:= SLF->( GetArea() )
Local lTemAcesso		:= .F.
Local nY 				:= 0
Local cEmpAtual			:= FWGrpCompany()
Local aAreaSM0			:= SM0->(GetArea())
Local aUsersSub			:= {}
Local aInfoUser 		:= {}
Local cCodFil			:= ""
Local aFiliais 			:= {}
Local aCaixas 			:= {}
Local cCodCaixa 		:= ""
Local cLogin 			:= ""
Local cQuery			:= ""
Local cAlias			:= GetNextAlias()

Default aWBrowseFil		:= {}
Default aWBrowseCx		:= {}

// Carrega as filiais que o usuário logado tem acesso
aFiliais  := FWEmpLoad( .F. )

// Verifica se o usuário é Administrador
lAdminis := FWISAdmin(__cUserID)

// Retorna os usuários que são subordinados a este usuário.
aUsersSub := FWSFSupUsers(__cUserID)

//Reestrutura o array de subordinados, adicionando o login do usuario
For nX := 1 To Len(aUsersSub)
	//Retorna os dados do usuário
	/* Retorno FWSFLoadUser
    [n][1]: Id da tabela de usuários
    [n][2]: Id do usuário
    [n][3]: Login do usuário
    [n][4]: Nome do usuário
    [n][5]: E-mail do usuário */
	aInfoUser 	  := FWSFLoadUser(aUsersSub[nX])
	cLogin 		  := Upper(aInfoUser[3])
	aUsersSub[nX] := { aUsersSub[nX], cLogin }
Next nX

cQuery := "SELECT X5_FILIAL "
cQuery += "     , X5_CHAVE "
cQuery += "     , X5_DESCRI "
cQuery += "  FROM " + RetSqlName("SX5")
cQuery += " WHERE X5_TABELA = '23'"
cQuery += "   AND D_E_L_E_T_ <> '*'"

DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

While !(cAlias)->( Eof() )
	Aadd(aCaixas,{(cAlias)->X5_FILIAL, "23", (cAlias)->X5_CHAVE, (cAlias)->X5_DESCRI})
	(cAlias)->( DbSkip() )
EndDo

(cAlias)->( DbCloseArea() )

DbSelectArea("SLF")
SLF->(DbSetOrder(1)) //LF_FILIAL+LF_COD

For nX := 1 To Len(aFiliais)
	If cEmpAtual == aFiliais[nX][1] //Considera apenas as filiais da empresa corrente
		cCodFil := aFiliais[nX][3]
		If Ascan(aWBrowseFil,{|x| AllTrim(x[2]) == Alltrim(cCodFil)}) == 0
			Aadd(aWBrowseFil,{.F.,AllTrim(cCodFil), AllTrim(aFiliais[nX][4])})
		EndIf

		For nY := 1 To Len(aCaixas)
			If Empty(aCaixas[nY][1]) .OR. AllTrim(aCaixas[nY][1]) == AllTrim(cCodFil)
				lTemAcesso 	:= .F.
				cCodCaixa 	:= aCaixas[nY][3]
				cLogin 		:= Upper(aCaixas[nY][4])

				If lAdminis .Or. Ascan(aUsersSub,{|x| UPPER(AllTrim(x[2])) == AllTrim(cLogin)}) > 0 .Or. UPPER(Alltrim(cUserName)) == Alltrim(cLogin)
					If SLF->(DBSeek(FWxFilial("SLF",cCodFil) + cCodCaixa))
						lTemAcesso := .T.
					EndIf
				EndIf

				If lTemAcesso
					If Ascan(aWBrowseCx,{|x| UPPER(AllTrim(x[2])) == UPPER(AllTrim(cCodCaixa))}) == 0
						Aadd(aWBrowseCx,{.F.,AllTrim(cCodCaixa), AllTrim(cLogin)})
					EndIf
				EndIf
			EndIf
		Next nY

	EndIf
Next nX

//Ordena os caixa em ordem alfabética
aSort(aWBrowseCx,,,{|x,y| x[2] < y[2] })

If Len(aWBrowseFil) == 1
	aWBrowseFil[1][1] := .T.
EndIf

If Len(aWBrowseCx) == 1
	aWBrowseCx[1][1] := .T.
EndIf

RestArea(aAreaSM0)
RestArea(aAreaSLF)

Return

//------------------------------------------------------------------
/*/{Protheus.doc} LJ130imp()
Impressao do Fechamento do Caixa
@type function

@author Marcos Iurato Junior
@since 09/09/2019
@version P12.1.25

@param  lmv_ljtroco, lógico, Veridica se o parametro MV_LJTROCO esta ativo
@param  nTrocoSaida, numérico, Valor do troco de saida                         
@param  aCaixa, array, Array com os valores do caixa                   
@param  nTroco,	numérico, Valor do saldo inicial                          
@param  nTotCredito, numérico, Valor com o total de credito                    
@param  nTotDebito, numérico, Valor com o total de debito          			
@param  nSaldFinal, numérico, Valor do saldo final                            
@param  aDadosVen, array, Array com os dados da venda                     
@param  aDadosSan, array, Array com os dados da sangria
@param  dDataDe, data, Data de
@param  dDataAte, data, Data até
@param  aWBrowseFil, array, Array contendo o browse das filiais
@param  aWBrowseCx, array, Array contendo o browse dos caixas
@param  aDDown, array, Array contendo o drill down 

@return Nil, Nil
/*/
//------------------------------------------------------------------
Static Function Lj130imp( lMV_LJTROCO	,nTrocoSaida	,aCaixa			,nTroco			,;
						  nTotCredito	,nTotDebito		,nSaldFinal		,aDadosVen		,;
						  aDadosSan		,dDataDe		,dDataAte		,aWBrowseFil	,;
						  aWBrowseCx	,aDDown )

Local nColFim	:= 0													//Coluna final
Local nColIni	:= 0                                               		//Coluna inicial
Local nLin		:= 0                                                    //Controle de linha
Local nI		:= 0													//Variavel auxiliar de loop	
Local lAberto	:= .F.                                             		//Variavel auxiliar
Local cPicture	:= ""                                                  	//Picture do campo L1_VLRTOT
Local oPrint														   	//Objeto de impressora
Local oFont															   	//Objeto de fonte
Local cTextoCx	:= ""
Local cTextoFil	:= ""
Local nX		:= 0
Local nContWhile:= 0
Local nContExce	:= 0
Local nPos		:= 0

If ExistBlock("LJ130001") // Verifica a existência do Ponto de Entrada LJ130001 que substitiu a impressão padrão
	ExecBlock( "LJ130001", .F., .F., { nTrocoSaida, aCaixa, nTroco, nTotCredito,;
									   nTotDebito, nSaldFinal, aDadosVen, dDataDe,;
									    dDataAte, aWBrowseCx, aWBrowseFil, aDDown,;
										aDadosSan} )
Else

	For nX := 1 To Len(aWBrowseCx)
		If aWBrowseCx[nX][1]
			If nContWhile < 10
				cTextoCx += " " + Alltrim(aWBrowseCx[nX][2]) + ","
				nContWhile++
			Else
				nContExce++
			EndIf
		EndIf
	Next nX

	If nContExce > 0
		cTextoCx := cTextoCx + "...mais " + Alltrim(Str(nContExce)) + " caixa(s) selecionado(s)..."
	Else
		cTextoCx := Subs(cTextoCx,1,Len(cTextoCx)-1)
	EndIf

	nContWhile 	:= 0
	nContExce 	:= 0

	For nX := 1 To Len(aWBrowseFil)
		If aWBrowseFil[nX][1]
			If nContWhile < 6
				cTextoFil += " " + Alltrim(aWBrowseFil[nX][2]) + ","
				nContWhile++
			Else
				nContExce++
			EndIf
		EndIf
	Next nX

	If nContExce > 0
		cTextoFil := cTextoFil + "...mais " + Alltrim(Str(nContExce)) + " filial(is) selecionada(s)..."
	Else
		cTextoFil := Subs(cTextoFil,1,Len(cTextoFil)-1)
	EndIf

	oFont  := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)

	oPrint := TMSPrinter():New( STR0017 ) 	//Fechamento de Caixa

	If !oPrint:IsPrinterActive()
		oPrint:Setup()						// Escolhe a impressora
	Endif

	If !oPrint:IsPrinterActive()
		// "Resumo de Caixa" , "Não foi possível imprimir o Resumo de Caixa, pois não há nenhuma impressora conectada."
		Aviso(STR0001, STR0026, {"Ok"})
		Return(NIL)
	EndIf
	oPrint:SetPortrait()

	nColIni  := 50		// Coluna inicial                      
	nColFim  := 1750	// Coluna final
	nSalto   := 40		// Salto de uma linha a outra

	cPicture := PesqPict("SL1","L1_VLRTOT",13)

	// Inicia a impressao da pagina
	oPrint:StartPage()

	// Imprime o cabecalho
	oPrint:Say( 110, 100, PadC( Upper(STR0017), 65 ), oFont )

	oPrint:Line( 150, nColIni, 150, nColFim )

	oPrint:Say( 170, 100, STR0035 + PadR(DToC(dDataDe),20) + " "  + STR0036 + DToC(dDataAte))		// "Data de:" ### "Data ate:"
	oPrint:Say( 210, 100, STR0033 + cTextoCx)	// Caixa(s)
	oPrint:Say( 250, 100, STR0034 + cTextoFil)  // Filial(ais)

	oPrint:Line( 300, nColIni, 300, nColFim )
	oPrint:Say( 320, 100, STR0018 + Transform( nTroco, cPicture ) ) //"Saldo Inicial .................................."

	If lMV_LJTROCO
		oPrint:Line( 300, nColIni, 300, nColFim )
		oPrint:Say( 360, 100, STR0031 + Transform( nTrocoSaida , cPicture ) ) //"Troco Saída   .................................."	
	Endif              

	// Imprime os dados de venda
	oPrint:Line( 400, nColIni, 400, nColFim )
	oPrint:Say( 420, 100, STR0019 + Transform( nTotCredito, cPicture ) ) //"C R E D I T O S / V E N D A S .................."

	nLin := 470

	For nI :=1 to len(aDadosVen)
		lAberto := (Left(aDadosVen[nI][1],1)=="-" .AND. aDadosVen[nI][2] <> 0)
		oPrint:Say( nLin, 100, padr(Left(UPPER(aDadosVen[nI][1]),32)+" "+SubStr(aDadosVen[nI][1],Len(aDadosVen[nI][1])-5,6)+" ",48,IIf(lAberto,"",".")) + IIf(lAberto, "", Transform(aDadosVen[nI][4], cPicture)))
		nLin += nSalto
		If nI == 1  	//P_VEND_DINHEIRO 
			//Nada
		ElseIF nI == 2  //P_VEND_DEBAUTO
			nPos := 5
		ElseIF nI == 3  //P_VEND_CARTAO
			nPos := 1
		ElseIF nI == 4  //P_VEND_CHEQUE
			nPos := 6
		ElseIF nI == 5  //P_VEND_FINANCIADO
			nPos := 4
		ElseIF nI == 6  //P_VEND_CREDITO
			nPos := 7
		ElseIF nI == 7  //P_VEND_VALE
			nPos := 2
		ElseIF nI == 8  //P_VEND_CONVENIO
			nPos := 3
		ElseIF nI == 9  //P_VEND_OUTROS
			nPos := 10
		//ElseIF nI == 10 //P_SANG_IMPOSTOS
			//Nada
		ElseIF nI == 10 //P_RECEBIMENTOS
			nPos := 8
		ElseIF nI == 12 //P_VEND_CARTFID
			nPos := 9
		ElseIF nI == 13 //P_REC_CELULAR
			nPos := 11		
		ElseIF nI == 14 //P_TRANSF_DESTINO
			nPos := 14
		ElseIF nI == 15 //P_VEND_PAGDIG
			nPos := 15
		ElseIf nI == 16 //P_VEND_PAGPIX
			nPos := 16
		EndIf

		If nI <> 1 .AND. nI <> 11
			For nX := 1 To Len(aDDown[nPos])
				oPrint:Say( nLin, 199, padr(Left(LOWER(aDDown[nPos][nX][1]),32)+" "+" ",42,".") + IIf(lAberto, "", Transform(aDDown[nPos][nX][2], cPicture)))		
				nLin += nSalto
			Next nX
		EndIf
	Next nI      

	// Imprime os dados de Sangria
	nLin += nSalto
	oPrint:Line( nLin, nColIni, nLin, nColFim )
	nLin += nSalto
	oPrint:Say( nLin, 100, STR0020 + Transform( nTotDebito, cPicture ) ) //"D E B I T O S / S A N G R I A S ................"
	nLin += (nSalto + 10)

	For nI :=1 to len(aDadosSan)
		oPrint:Say( nLin, 100, padr(Left(aDadosSan[nI][1],23)+" "+;
		Space(06)+" ",48,".")+Transform(aDadosSan[nI][3], cPicture)+"  "+"("+Alltrim(aDadosSan[nI][4])+")")
		nLin += nSalto
	Next nI

	nLin += nSalto
	oPrint:Line( nLin, nColIni, nLin, nColFim )
	nLin += nSalto
	oPrint:Say( nLin, 100, STR0021 + Transform( nSaldFinal, cPicture ) ) //"Saldo Final ...................................."
	nLin += (nSalto + 10)

	// Monta a borda de fora pois neste momento sabemos qual a linha final
	oPrint:Line( 100, nColIni, 100, nColFim )
	oPrint:Line( nLin, nColIni, nLin, nColFim )
	oPrint:Line( 100, nColIni, nLin, nColIni )
	oPrint:Line( 100, nColFim, nLin, nColFim )

	oPrint:EndPage()

	oPrint:Preview()

EndIf

Return(NIL)
