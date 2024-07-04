#INCLUDE "TOTVS.CH"
#INCLUDE "DROVDLNK.CH
#INCLUDE "FRTDEF.CH"

//Armazena parametros da venda 
Static aParamVL 	:= {}
Static nNumPBM		:= 0
Static lCanTelMeC	:= .F.
Static lValidSitef	:= .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} LjUsaPBM
Verifica se o ambiente está configurado para uso do "PBM".

@author  	Alberto Deviciente
@since   	04/05/2022
@version 	P12.1.27

@return 	Lógico, Indica se a funcionalidade "PBM Funcional Card" está ativa.
/*/
//-------------------------------------------------------------------
Function LjUsaPBM()
Local lRet 	:= .F.

//Para o SIGALOJA (Venda Assistida) sem o Template de Drogaria, apenas o "PBM Funcional Card" foi implementado, mediante configuração do parâmetro MV_LJPBM.
//Os demais PBMs somente são utilizados em ambiente com Template de Drogaria.
If ExistTemplate("DROVLGet") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()) .Or. ; //Verifica se está utilizando o Template de Drogaria.
	(SuperGetMV("MV_LJPBM",,"0") == "1" .And. nModulo == 12) //Verifica se está habilitado o parâmetro que ativa o "PBM Funcional Card" no SIGALOJA (Sem Template de Drogaria).
	lRet := .T.
EndIf

Return lRet
//---------------------------------------------------------------------------------
/*/{Protheus.doc} LjDROVLGet
Solicita que o usuario digite o Numero da Autorização. A seguir chama a
funcao LjDroVLCar() que faz o "Carregamento" dos dados de venda com os dados
da cotação do VidaLink referente a este numero de autorizacao

@type 	 Function
@author  Alberto Deviciente
@since 	 01/06/2022
@version 12.1.27

@obs	Uso no Template de Drogarias

@param nOpPbm, Numérico, Número de referência do PBM a ser executado.

@return Nil, Nulo
/*/
//---------------------------------------------------------------------------------
Function LjDROVLGet( nOpPbm )
Local oNumAutori																				// Objeto do Numero de Autorizacao
Local oNumConv																					// Objeto do Numero do Convenio
Local oNumCartao																				// Objeto do Numero do Cartao do Convenio
Local oDlg																						// Objeto da Caixa de Dialogo
Local oLbx          																			// Objeto do Grid
Local oTotVenda     																			// Objeto do Total da Venda
Local oGetCodCli																				// Objeto de exibicao do cCliCodLoj 
Local oNomeCli																					// Objeto de exibicao do Nome do Cliente
Local aKey		  := {}																			// Armazena SetKeys
Local aCab     	  := {STR0037, STR0038, STR0039, STR0040, STR0041, STR0042}						// Cabecalho do grid    {"Item","Codigo Barra","Produto","Qtd.Autor.","Qtd. a Comprar","Preço" }
Local aLin     	  := { { "", "" , "" , 0, 0, 0, 0 } }											// Linha vazia para o grid
Local aTam    	  := {15,60,80,25,25,25}														// Dimensoes de cada campo do grid
Local nTotVenda   := 0																			// Valor total da venda
Local _cNumAutori := Space(12)																	// Numero da autorizacao
Local _cNumConv   := Space(06)																	// Numero do convenio
Local _cNumCartao := Space(18)																	// Numero do cartao do convenio
Local _cNumAutAnt := Space(12)																	// Numero da autorizacao anterior
Local cCliCodLoj  := ""																			// CodigoCliente - CodigoLoja
Local cNomeCli	  := ""																			// Nome do cliente
Local aListaConv  := {'000026 - Projeto Faz Bem Teste ','000009 - Equilibre Saúde       ','000016 - Takeda - Sempre Saude ','000022 - Lilly Melhor para Voce'}

// Objetos de pre-autorizacao PharmaLink - PBM 540
Local oCPF         	// Campo 502 do CLISITEF
Local oCRM			// Campo 1023 do CLISITEF
Local oUF			// Campo 1024 do CLISITEF

// Variaveis de pre-autorizacao PharmaLink - PBM 540
Local _cCPF     	:= Space(14) 		// Campo 502 do CLISITEF
Local _cCRM			:= Space(10)		// Campo 1023 do CLISITEF
Local _cUF			:= Space(02)		// Campo 1024 do CLISITEF
Local aVidalinkD	:= {}
Local aVidalinkC 	:= {}
Local lSigaLoja		:= nModulo == 12	// Se utiliza o modulo Venda Assistida
Local bGrvVend		:= Nil				//Bloco de codigo que será executado 
Local aRetPbm		:= {}				//Retorno das informacoes gravadas do PBM Funcional Card
Local lDrGScrExMC	:= NIL
Local nRow			:= 0
Local aDados		:= {}
Local cCliCodigo	:= ""
Local cCliLoja		:= ""

DEFAULT nOpPbm 	  	:= 1				// Identifica o PBM

If lSigaLoja
	If Len(aParamVL) = 0
		LjDROVLPSet()
		aParamVL[1][VLP_AVLC] := {}
		aParamVL[1][VLP_AVLD] := {}
	EndIf
	aParamVL[1][VLP_CCLIEN]	:= M->LQ_CLIENTE
	aParamVL[1][VLP_CLOJAC]	:= M->LQ_LOJA
	aParamVL[1][VLP_LCXABE]	:= LjCxAberto(.T.,xNumCaixa())
	
	aRetPbm := LJGDadosVL()
	aParamVL[1][VLP_NVIDAL] := IIf(Len(aRetPbm) > 2 .And. Len(aRetPbm[1]) > 0, aRetPbm[3], 1)

	aParamVL[1][VLP_AVLC] := aSize(aParamVL[1][VLP_AVLC],0)
	aParamVL[1][VLP_AVLD] := aSize(aParamVL[1][VLP_AVLD],0)
EndIf

If nOpPbm <> 540
	cCliCodLoj	:= aParamVL[1][VLP_CCLIEN] + " - " + aParamVL[1][VLP_CLOJAC]
	cNomeCli	:= Subst(Posicione("SA1",1,xFilial("SA1") + aParamVL[1][VLP_CCLIEN] + aParamVL[1][VLP_CLOJAC],"A1_NOME"),1,30)
Endif

IIf(nOpPbm == 540, (oTEF := LJTEFAbre()), Nil) //Se nOpPbm == 540, prepara o objeto TEF e carrega as variáveis necessárias

nNumPbm		:= nOpPbm	//nNumPBM é uma variavel estatica

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
	ExecTemplate( "DROLCS", .F., .F. )
EndIf

If nOpPbm <> 540 .AND. !aParamVL[1][VLP_LCXABE]
	MsgStop(OemToAnsi(STR0007), OemToAnsi(STR0002)) // O Caixa não está aberto. Não será possível alterar o cliente
	Return(NIL)
EndIf

If nOpPbm <> 540 .AND. aParamVL[1][VLP_NVIDAL] == 2 	// Jah Gravado VidaLink
	MsgStop(STR0014 + CHR(10) + "Para utilizar novamente saia da rotina de venda e abra novamente.", STR0002) // "Nesta venda ja foi utilizado um orçamento da PBM."### "Para utilizar novamente saia da rotina de venda e abra novamente." ### "Atenção"
	Return(NIL)
EndIf

aKey := FRTSetKey()    // Cancela temporariamente as SetKey's do Fechamento da Venda

DEFINE MSDIALOG oDlg TITLE STR0003 FROM 0,0 TO 400,650 PIXEL      // Carregamento de Cotação da VidaLink
	
	//Determina a posição da linha onde será criado o browse
	nRow := IIf(nOpPbm <> 540, 055, 085)
 	oLbx:=TwBrowse():New(nRow,010,310,100,,aCab,aTam,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)  // coordenadas lin.ini, pos.ini, largura, altura
	 	
	oLbx:lColDrag	:= .T.
	oLbx:nFreeze	:= 1
	oLbx:bLDblClick :={ || LjDROVLEQtd(@aLin, @aParamVL[1][VLP_AVLD], oLbx, @nTotVenda, @oTotVenda  ) }
	oLbx:SetArray(aLin)
	oLbx:bLine		:= { || { Transform( aLin[oLbx:nAt][1], '') , Transform( aLin[oLbx:nAt][2], '') , Transform( aLin[oLbx:nAt][3], ''), Transform( aLin[oLbx:nAt][4], '@E 999,999,999.99'), Transform( aLin[oLbx:nAt][5], '@E 999,999,999.99'), Transform( aLin[oLbx:nAt][6], '@E 999,999,999.99'), Transform( aLin[oLbx:nAt][7], '@E 999,999,999.99')  } }
	oLbx:Refresh()
	
	//VidaLink so precisa do numero de autorizacao
	If nOpPbm	== 1
		@ 05,010 SAY STR0004 OF oDlg PIXEL
		@ 05,100 GET oNumAutori VAR _cNumAutori  VALID LjDroVLCar( 	@_cNumAutori, @_cNumAutAnt	, @aLin						, @aParamVL[1][VLP_AVLD]	,; 
																	@nTotVenda	, @oTotVenda	, @oLbx						, nNumPbm					,;
																	""			, ""			, aParamVL[1][VLP_CCLIEN]	, @aParamVL[1][VLP_CLOJAC] 	) SIZE 50,7 PIXEL PICTURE "999999999999"
	Else
	
		If nOpPbm == 540
		/*	TODO PBM PHARMASYSTEM
			@ 005,010 SAY "CPF Titular: " OF oDlg PIXEL
			@ 005,040 GET oCPF VAR _cCPF   SIZE 50,7 PIXEL PICTURE "99999999999"

			@ 020,010 SAY "CRM: " OF oDlg PIXEL
			@ 020,040 GET oCRM VAR _cCRM  PIXEL PICTURE "9999999999"
			
			@ 020,170 SAY "UF CRM: " OF oDlg PIXEL
			@ 020,200 GET oUF VAR _cUF   PIXEL PICTURE "@!"					
		*/
		//PharmaSystem tem que informar o cartao do convenio ou o CPF do cliente
		ElseIf nOpPbm	== 541  //544

			@ 005,010 SAY STR0004 OF oDlg PIXEL
			@ 005,100 GET oNumAutori VAR _cNumAutori   SIZE 50,7 PIXEL PICTURE "999999999999"
				
			@ 005,170 SAY "Convenio : " OF oDlg PIXEL

  			_cNumConv	:= aListaConv[1]

		  	oNumConv := TComboBox():New(005,200,{|u|if(PCount()>0,_cNumConv:=u,_cNumConv)},; 
		    aListaConv,090,007,oDlg,,{||_cNumConv := Substr(_cNumConv,1,6)}; 
		    ,,,,.T.,,,,,,,,,'_cNumConv')  
			
			@ 020,170 SAY "Cartao : " OF oDlg PIXEL
			@ 020,200 GET oNumCartao VAR _cNumCartao   PIXEL PICTURE "999999999999999999"
		
		ElseIf	nOpPbm == 560 		
			@ 005,010 SAY STR0004 OF oDlg PIXEL
			@ 005,100 GET oNumAutori VAR _cNumAutori   SIZE 50,7 PIXEL PICTURE "999999999999"
			
			@ 005,170 SAY "Cartao : " OF oDlg PIXEL
			@ 005,200 GET oNumCartao VAR _cNumCartao   PIXEL PICTURE "999999999999999999"				
		        
		Endif


		IIf( nOpPbm<>540, (aDados:=aParamVL[1][VLP_AVLD],cCliCodigo:=aParamVL[1][VLP_CCLIEN],cCliLoja:=aParamVL[1][VLP_CLOJAC]) , (aDados:=aVidalinkD,cCliCodigo:=aVidalinkC,cCliLoja:=Nil) )

		@ 175,240 BUTTON "Pesquisar" SIZE 39,12 OF oDlg PIXEL ACTION ( LjDroVLCar( 	@_cNumAutori, @_cNumAutAnt	, @aLin			, @aDados	,; 
																					@nTotVenda	, @oTotVenda	, @oLbx			, nNumPbm	,; 
																					_cNumConv	,_cNumCartao	, cCliCodigo	, cCliLoja	,;
																					_cCPF  		, _cCRM			, _cUF ), IIF(nOpPbm<>540,aParamVL[1][VLP_AVLD]:=aDados,aVidalinkD:=aDados))
		
	Endif

 	If nOpPbm <> 540
		@ 020,010 SAY STR0008 OF oDlg PIXEL
		@ 020,100 GET oTotVenda VAR nTotVenda  When .F. SIZE  50,7 PIXEL PICTURE "@E 999,999,999.99"

 
		@ 035,070 SAY STR0011
		@ 035,100 GET oGetCodCli VAR cCliCodLoj  When .F. SIZE  50,7 PIXEL PICTURE "@!"
		@ 035,150 GET oNomeCli   VAR cNomeCli    When .F. SIZE 120,7 PIXEL PICTURE "@!"
		
		/*
		Conforme encontrado na internet bloqueado a troca de cliente, pois essa operação 
		se torna proibida. 
		Com isso é necessário usar o mesmo cliente da venda na pesquisa da PBM
		https://www.funcionalcorp.com.br/com/atendimento-ao-cliente-no-pdv/
		*/
		 
		/*
		If !lSigaLoja
			@ 035,010 BUTTON STR0043 SIZE 50,15 OF oDlg PIXEL ACTION ( LjDROVLACli(@aParamVL[1][VLP_CCLIEN], @aParamVL[1][VLP_CLOJAC], @cCliCodLoj, @oGetCodCli, @cNomeCli, @oNomeCli ) ) // STR0043 "Altera Cliente"
		EndIf
		*/	
	Else
		/*
		TODO PBM PHARMASYSTEM

		@ 050,010 SAY STR0008 OF oDlg PIXEL
		@ 050,100 GET oTotVenda VAR nTotVenda  When .F. SIZE  50,7 PIXEL PICTURE "@E 999,999,999.99"
			
		@ 065,070 SAY STR0011
		@ 065,100 GET oGetCodCli VAR cCliCodLoj  When .F. SIZE  50,7 PIXEL PICTURE "@!"
		@ 065,150 GET oNomeCli   VAR cNomeCli    When .F. SIZE 120,7 PIXEL PICTURE "@!"
		@ 065,010 BUTTON STR0043 SIZE 50,15 OF oDlg PIXEL ACTION ( LjDROVLACli(@aParamVL[1][VLP_CCLIEN], @aParamVL[1][VLP_CLOJAC], @cCliCodLoj, @oGetCodCli, @cNomeCli, @oNomeCli ) ) // STR0043 "Altera Cliente"
		@ 175,130 BUTTON STR0044 SIZE 39,12 OF oDlg PIXEL ACTION If( LjDROVLConf({"",""}, aVidalinkD, @nTotVenda, nTotVenda, @oTotVenda, "000001", "01"),oDlg:End(),oDlg:End()) // STR0044 "Confirma"
		*/
	Endif		
		 						
	If nOpPbm == 540
		/*
		//TODO PBM PHARMASYSTEM

		@ 175,130 BUTTON STR0044 SIZE 39,12 OF oDlg PIXEL ACTION If( LjDROVLConf({"",""}, aVidalinkD, @nTotVenda, nTotVenda, @oTotVenda, "000001", "01"),oDlg:End(),oDlg:End()) // STR0044 "Confirma"
		*/
	Else
						 
		If lSigaLoja
			bGrvVend := {|| LJMsgRun("Adicionando itens ao orçamento...",,{|| DroAddProd(@aParamVL[1][VLP_AVLD][2]) }),oDlg:End()}
		Else

			bGrvVend := {|| ;
						FR271HCarrega(oDlg					, Nil						, @aParamVL[1][27]			, @aParamVL[1][145]	,;
									 @aParamVL[1][1]		, @aParamVL[1][2]			, @aParamVL[1][3]			, @aParamVL[1][4]	,;
									 @aParamVL[1][157]		, @aParamVL[1][45] 			, @aParamVL[1][7]			, @aParamVL[1][8]	,;
									 @aParamVL[1][9]		, @aParamVL[1][10]			, @aParamVL[1][11]			, @aParamVL[1][14]	,;
									 @aParamVL[1][5]		, @aParamVL[1][13]			, @aParamVL[1][150]			, @aParamVL[1][29]	,;
									 @aParamVL[1][33]		, @aParamVL[1][61] 			, @aParamVL[1][151]			, @aParamVL[1][15]	,;
									 @aParamVL[1][34]		, @aParamVL[1][35] 			, @aParamVL[1][37]			, @aParamVL[1][38]	,;
									 @aParamVL[1][12]		, @aParamVL[1][17] 			, @aParamVL[1][44]			, @aParamVL[1][28]	,;
									 @aParamVL[1][30]		, @aParamVL[1][31]	 		, @aParamVL[1][32]			, @aParamVL[1][36]	,;
									 @aParamVL[1][39]		, @aParamVL[1][52] 			, @aParamVL[1][53]			, @aParamVL[1][54]	,;
									 @aParamVL[1][55]		, @aParamVL[1][59] 			, @aParamVL[1][60]			, @aParamVL[1][62]	,;
									 @aParamVL[1][158]		, @aParamVL[1][63] 			, @aParamVL[1][152]			, @aParamVL[1][153]	,;
									 Nil					, @aParamVL[1][65] 			, @aParamVL[1][66]			, @aParamVL[1][66]	,;
									 @aParamVL[1][69]		, @aParamVL[1][70] 			, @aParamVL[1][71]			, @aParamVL[1][74]	,;
									 @aParamVL[1][75]		, @aParamVL[1][76] 			, @aParamVL[1][77]			, @aParamVL[1][78]	,;
									 @aParamVL[1][79]		, @aParamVL[1][80] 			, @aParamVL[1][81]			, @aParamVL[1][82]	,;
									 @aParamVL[1][83]		, @aParamVL[1][84] 			, @aParamVL[1][85]			, @aParamVL[1][86]	,;
									 @aParamVL[1][VLP_AVLD]	, @aParamVL[1][VLP_AVLC]	, @aParamVL[1][VLP_NVIDAL]	, @aParamVL[1][90]	,;
									 @aParamVL[1][91]		, @aParamVL[1][92] 			, @aParamVL[1][93] 			, @aParamVL[1][94]	,;
									 @aParamVL[1][91]		, @aParamVL[1][96] 			, @aParamVL[1][97]			, @aParamVL[1][98]	,;
									 @aParamVL[1][99]		, @aParamVL[1][100]			, @aParamVL[1][101]			, @aParamVL[1][102]	,;
									 @aParamVL[1][103]		, @aParamVL[1][104]			, @aParamVL[1][105]			, @aParamVL[1][106]	,;
									 @aParamVL[1][107]		, @aParamVL[1][16] 			, Nil			   			, @aParamVL[1][111]	,;
									 @aParamVL[1][112]		, @aParamVL[1][113]			, @aParamVL[1][114]			, @aParamVL[1][115]	,;
									 @aParamVL[1][118]		, @aParamVL[1][26]	 		, @aParamVL[1][51]			, @aParamVL[1][67]	,;
									 @aParamVL[1][139]		, @aParamVL[1][155]			, Nil						, Nil				,;
									 @aParamVL[1][144]		, @aParamVL[1][143]			, @aParamVL[1][142]			, Nil				,;
									 @aParamVL[1][147]		, @aParamVL[1][49]			, @aParamVL[1][50]			, Nil				,;
									 @aParamVL[1][6]		, @aParamVL[1][141]			, @aParamVL[1][159]			, Nil				,;
									 Nil),oDlg:End()}
		EndIf
		
		@ 175,130 BUTTON STR0044 SIZE 39,12 OF oDlg PIXEL ACTION; // STR0044 "Confirma"
		 			If( LjDROVLConf(@aParamVL[1][VLP_AVLC]	, @aParamVL[1][VLP_AVLD], @aParamVL[1][VLP_NVIDAL],;
		 			 				@nTotVenda				, @oTotVenda			, @aParamVL[1][VLP_CCLIEN],;
		 			 				@aParamVL[1][VLP_CLOJAC] ),;
		 			 				Eval(bGrvVend), oDlg:End() )
	Endif
	
    @ 175,180 BUTTON "Sair" SIZE 39,12 OF oDlg PIXEL ACTION If( !lValidSitef .And. LjDROVLCanc( @aParamVL[1][VLP_AVLC], @aParamVL[1][VLP_AVLD], @aParamVL[1][VLP_NVIDAL], @nTotVenda, @oTotVenda ) ,  oDlg:End() , )
    
    IIf(nOpPbm<>540,oNumAutori:SetFocus(),oCPF:SetFocus()) //Define onde será o foco inicial do GET
		
	ACTIVATE DIALOG oDlg CENTERED
	
	//Significa que a tela de produtos controlados foi cancelada e com isso deve cancelar tudo
	lDrGScrExMC := LjDrGScrExMC()
	If lDrGScrExMC
		LjDROVLCanc( @aParamVL[1][VLP_AVLC], @aParamVL[1][VLP_AVLD], @aParamVL[1][VLP_NVIDAL], @nTotVenda, NIL , .T.)
		LjDrSScrExMC( .F. )
	EndIf
	
	FRTSetKey(aKey) // Restaura as SetKey's do Fechamento da Venda
	
	If nOpPbm <> 540
		FRT271aVL({aParamVL[1][VLP_AVLD], aParamVL[1][VLP_AVLC], aParamVL[1][VLP_NVIDAL]})
	Endif	
	
	If nOpPbm <> 540 .AND. aParamVL[1][VLP_NVIDAL] == 1  // Gravar VidaLink
		/*
		If !lSigaLoja 
			FR271HCarrega(   oDlg					, Nil						, @aParamVL[1][27]			, @aParamVL[1][145]	,;
							 @aParamVL[1][1]		, @aParamVL[1][2]			, @aParamVL[1][3]			, @aParamVL[1][4]	,;
							 @aParamVL[1][157]		, @aParamVL[1][45] 			, @aParamVL[1][7]			, @aParamVL[1][8]	,;
							 @aParamVL[1][9]		, @aParamVL[1][10]			, @aParamVL[1][11]			, @aParamVL[1][14]	,;
							 @aParamVL[1][5]		, @aParamVL[1][13]			, @aParamVL[1][150]			, @aParamVL[1][29]	,;
							 @aParamVL[1][33]		, @aParamVL[1][61] 			, @aParamVL[1][151]			, @aParamVL[1][15]	,;
							 @aParamVL[1][34]		, @aParamVL[1][35] 			, @aParamVL[1][37]			, @aParamVL[1][38]	,;
							 @aParamVL[1][12]		, @aParamVL[1][17] 			, @aParamVL[1][44]			, @aParamVL[1][28]	,;
							 @aParamVL[1][30]		, @aParamVL[1][31]	 		, @aParamVL[1][32]			, @aParamVL[1][36]	,;
							 @aParamVL[1][39]		, @aParamVL[1][52] 			, @aParamVL[1][53]			, @aParamVL[1][54]	,;
							 @aParamVL[1][55]		, @aParamVL[1][59] 			, @aParamVL[1][60]			, @aParamVL[1][62]	,;
							 @aParamVL[1][158]		, @aParamVL[1][63] 			, @aParamVL[1][152]			, @aParamVL[1][153]	,;
							 Nil					, @aParamVL[1][65] 			, @aParamVL[1][66]			, @aParamVL[1][66]	,;
							 @aParamVL[1][69]		, @aParamVL[1][70] 			, @aParamVL[1][71]			, @aParamVL[1][74]	,;
							 @aParamVL[1][75]		, @aParamVL[1][76] 			, @aParamVL[1][77]			, @aParamVL[1][78]	,;
							 @aParamVL[1][79]		, @aParamVL[1][80] 			, @aParamVL[1][81]			, @aParamVL[1][82]	,;
							 @aParamVL[1][83]		, @aParamVL[1][84] 			, @aParamVL[1][85]			, @aParamVL[1][86]	,;
							 @aParamVL[1][VLP_AVLD]	, @aParamVL[1][VLP_AVLC]	, @aParamVL[1][VLP_NVIDAL]	, @aParamVL[1][90]	,;
							 @aParamVL[1][91]		, @aParamVL[1][92] 			, @aParamVL[1][93] 			, @aParamVL[1][94]	,;
							 @aParamVL[1][91]		, @aParamVL[1][96] 			, @aParamVL[1][97]			, @aParamVL[1][98]	,;
							 @aParamVL[1][99]		, @aParamVL[1][100]			, @aParamVL[1][101]			, @aParamVL[1][102]	,;
							 @aParamVL[1][103]		, @aParamVL[1][104]			, @aParamVL[1][105]			, @aParamVL[1][106]	,;
							 @aParamVL[1][107]		, @aParamVL[1][16] 			, Nil			   			, @aParamVL[1][111]	,;
							 @aParamVL[1][112]		, @aParamVL[1][113]			, @aParamVL[1][114]			, @aParamVL[1][115]	,;
							 @aParamVL[1][118]		, @aParamVL[1][26]	 		, @aParamVL[1][51]			, @aParamVL[1][67]	,;
							 @aParamVL[1][139]		, @aParamVL[1][155]			, Nil						, Nil				,;
							 @aParamVL[1][144]		, @aParamVL[1][143]			, @aParamVL[1][142]			, Nil				,;
							 @aParamVL[1][147]		, @aParamVL[1][49]			, @aParamVL[1][50]			, Nil				,;
							 @aParamVL[1][6]		, @aParamVL[1][141]			, @aParamVL[1][159]			, Nil				,;
							 Nil)	
		EndIf
		*/
	EndIf
Return Nil
                      
//---------------------------------------------------------------------------------
/*/{Protheus.doc} LjDROVLCar
Carrega a cotacao criada no Host VidaLink no array aVidaLinkD para inico da
operacao de venda no FrontLoja, referente ao numero de autorizacao digitado

@type 	 Function
@author  Alberto Deviciente
@since 	 01/06/2022
@version 12.1.27

@obs	Uso no Template de Drogarias

@param _cNumAutori, Caracter, Número da Autorização PBM
@param _cNumAutAnt, Caracter, Número da Autorização PBM digitada Anteriormente
@param aLin, Array, Array com a lista de produtos PBM retornado
@param aVidaLinkD, Array, Array com dados do PBM
@param nTotVenda, Numérico, Total da Venda
@param oTotVenda, Objeto, Objeto Total da venda
@param oLbx, Objeto, Objeto List do grid
@param nNumPbm, Numérico, Número PBM
@param _cNumConv, Caracter, Número do Convênio
@param _cNumCartao, Caracter, Número do Cartão
@param _cCliente, Caracter, Código do Cliente
@param _cLoja, Caracter, Loja do Cliente
@param cCPF, Caracter, CPF do Cliente
@param cNumCRM, Caracter, Número do CRM
@param cUFCRM, Caracter, UF do CRM

@return lRet, Lógico
/*/
//---------------------------------------------------------------------------------
Function LjDROVLCar(_cNumAutori	, _cNumAutAnt	, aLin			, aVidaLinkD	, ;
					nTotVenda	, oTotVenda		, oLbx			, nNumPbm		, ;	 
					_cNumConv	,_cNumCartao	, _cCliente		, _cLoja		, ;
					cCPF 		, cNumCRM		, cUFCRM )

Local I 		:= 0 	//Contador
Local _cCPF		:= ""	//CPF do Cliente
Local nValor	:= 0	//Valor do produto retornado pela Funcional Card
Local lContinua	:= .T.
Local lRet		:= .T.

Default cCPF 	:= ""
Default cNumCRM := ""
Default cUFCRM	:= ""

lValidSitef := .T.

// Se nao mudou o num. da autorização, não carrego dados novamente 
// para não perder alteracoes na quantidade efetuadas pelo usuario.
If Empty(_cNumAutori) .AND. Empty(_cNumAutAnt ) .AND. nNumPbm <> 540
	lValidSitef := .F.
	lContinua	:= .F.
	lRet := .T.
Endif

If lContinua
	_cCPF := IIf(Empty(cCPF), Posicione("SA1",1,xFilial("SA1") + _cCliente + _cLoja,"A1_CGC"), cCPF)
		
	aVidaLinkD := {}
				
	If nNumPbm <> 540
		If _cNumAutori == _cNumAutAnt
			lContinua := .F.
			lRet := .T.
		Else
			_cNumAutAnt := _cNumAutori
		EndIf
	Endif
EndIf

If lContinua

	aAdd(aVidaLinkD,{_cNumAutori, _cNumConv, _cNumCartao, _cCPF, nNumPbm, cNumCRM, cUFCRM })
	nTotVenda  := 0
	
	//Consulta Vidalink
	If nNumPbm == 1
		oTEF:Operacoes("VIDALINK_CONSULTA"		, aVidaLinkD)
	//Consulta PharmaSystem
	ElseIf nNumPbm == 541
		oTEF:Operacoes("PHARMASYSTEM_CONSULTA"	, aVidaLinkD)     
	ElseIf  nNumPbm == 540
		/*
		TODO PBM PHARMASYSTEM
		oTEF:Operacoes("PHARMASYSTEM_AUTORIZA"	, aVidaLinkD)
		*/
	//Consulta Funcional Card
	ElseIf nNumPbm == 560 
		oTEF:Operacoes("FUNCARD_CONSULTA"		, aVidaLinkD)
	Endif

	If oTEF:lTEFOk
		aAdd(aVidaLinkD, {} )
		aAdd(aVidaLinkD, 0  )  
		
		For I := 1 to oTEF:aRetVidaLink:nQtdeMed
			If oTef:nCodFuncao == 541 .OR. oTef:nCodFuncao == 540	//PharmaSystem
				
				aAdd(aVidaLinkD[VL_DETALHE], ;
				           { oTEF:aRetVidaLink:aItems[i]:nIndice    ,;
							 oTEF:aRetVidaLink:aItems[i]:cCodigo    ,;
							 oTEF:aRetVidaLink:aItems[i]:nQuantAut  ,;
							 oTEF:aRetVidaLink:aItems[i]:nValLiq	,; 	// nValConsum
							 oTEF:aRetVidaLink:aItems[i]:nValLiq	,;  // nPreco de Venda da Farmacia
							 oTEF:aRetVidaLink:aItems[i]:nQuantAut  ,;  // Quantidade sem alteracao 
							 oTEF:aRetVidaLink:aItems[i]:nValTot	,;	// Preco de venda VidaLink			 
							 0										,;	// Valor do Subusidio
		 					 oTEF:aRetVidaLink:aItems[i]:nValLiq 	})	// Valor pago a vista
	
				nTotVenda += oTEF:aRetVidaLink:aItems[i]:nQuantAut * oTEF:aRetVidaLink:aItems[i]:nValLiq

			ElseIf oTef:nCodFuncao == 560	//Funcional Card
				
				nValor := IIf(AllTrim(oTEF:aRetVidaLink:aItems[i]:cPrecoFun)=="0", oTEF:aRetVidaLink:aItems[i]:nValorFC, oTEF:aRetVidaLink:aItems[i]:nValorPrat)
				
				aAdd(aVidaLinkD[VL_DETALHE], ;
				           { oTEF:aRetVidaLink:aItems[i]:nIndice    ,;
							 oTEF:aRetVidaLink:aItems[i]:cCodigo    ,;
							 oTEF:aRetVidaLink:aItems[i]:nQuantAut  ,;
							 oTEF:aRetVidaLink:aItems[i]:nValConsum	,; 	// nValConsum
							 nValor	  								,;  // nPreco de Venda da Farmacia
							 oTEF:aRetVidaLink:aItems[i]:nQuantAut	,;  // Quantidade sem alteracao 
							 oTEF:aRetVidaLink:aItems[i]:nValTot	,;	// Preco de venda VidaLink			 
							 0										,;	// Valor do Subusidio
		 					 oTEF:aRetVidaLink:aItems[i]:nValConsum	})	// Valor pago a vista
	
				nTotVenda += oTEF:aRetVidaLink:aItems[i]:nQuantAut * oTEF:aRetVidaLink:aItems[i]:nValLiq
	
			Else		               
			
				aAdd(aVidaLinkD[VL_DETALHE], ;
				           { oTEF:aRetVidaLink:aItems[i]:nIndice     	,;
							 oTEF:aRetVidaLink:aItems[i]:cCodigo     	,;
							 oTEF:aRetVidaLink:aItems[i]:nQuantAut   	,;
							 oTEF:aRetVidaLink:aItems[i]:nPrecoRecomend	,; 	// nValConsum
							 oTEF:aRetVidaLink:aItems[i]:nValVendFarm  	,;  // nPreco de Venda da Farmacia
							 oTEF:aRetVidaLink:aItems[i]:nQuantAut     	,;  // Quantidade sem alteracao 
							 oTEF:aRetVidaLink:aItems[i]:nPrecoMax   	,;	// Preco de venda VidaLink			 
							 oTEF:aRetVidaLink:aItems[i]:nValSubsidio + oTEF:aRetVidaLink:aItems[i]:nValReembFarm	,;	// Valor do Subusidio
		 					 oTEF:aRetVidaLink:aItems[i]:nValConsum 	})	// Valor pago a vista
				 
				nTotVenda += oTEF:aRetVidaLink:aItems[i]:nQuantAut * oTEF:aRetVidaLink:aItems[i]:nValVendFarm
	
			Endif
		Next
		
		aVidaLinkD[VL_TOTVEND] := nTotVenda  	    
		aAdd(aVidaLinkD,oTef:cCupom)
		
		If Empty( aVidaLinkD[VL_DETALHE] )
			MsgStop(STR0005, STR0002)		//"Não encontrado nenhum item na cotação do PBM para este numero de autorização"
		EndIf
	Else
		MsgStop(STR0006, STR0002)			//"Não encontrada cotação no PBM para este numero de autorização"	
	EndIf
	
	LjDROVLMItem( @aLin, @nTotVenda, @oTotVenda, @oLbx, @aVidaLinkD )  // Mostra os Itens autorizados pelo VidaLink
EndIf

lValidSitef := .F.

Return lRet

//---------------------------------------------------------------------------------
/*/{Protheus.doc} LjDROVLMItem
Mostra os Itens (produto, qtd, preco, etc) autorizados pelo VidaLink.

@type 	 Function
@author  Alberto Deviciente
@since 	 01/06/2022
@version 12.1.27

@obs	Uso no Template de Drogarias

@param aLin, Array, Array com a lista de produtos PBM retornado
@param nTotVenda, Numérico, Total da Venda
@param oTotVenda, Objeto, Objeto Total da venda
@param oLbx, Objeto, Objeto List do grid
@param aVidaLinkD, Array, Array com dados do PBM

@return lRet, Lógico
/*/
//---------------------------------------------------------------------------------
Function LjDROVLMItem( aLin, nTotVenda, oTotVenda, oLbx, aVidaLinkD )
Local _nI 			:= 0						// Contador
Local nBarras 		:= TamSX3("BI_CODBAR")[1]	// Dimensao do codigo de barras
Local cCodBarras 	:= ""					 	// Codigo de barras
Local lSigaLoja		:= nModulo == 12			// Se utiliza o modulo Venda Assistida
Local cTabelaProd	:= "SBI"					// Tabela para consulta do produto
Local cCamDescProd	:= "BI_DESC" 				// Campo para consultado do pruduto
Local nVlSubsidio	:= 0						//Valor do Subsidio

If lSigaLoja
	cTabelaProd 	:= "SB1"
	cCamDescProd 	:= "B1_DESC"
	nBarras			:= TamSX3("B1_CODBAR")[1]
EndIf

If Len( aVidaLinkD ) == 4 
	aLin := {}
	
	LjGrvLog( "PBM_FUNCIONAL_CARD", "Itens a ser exibido - aVidaLinkD", aVidaLinkD )
	
	For _nI := 1 to Len( aVidaLinkD[VL_DETALHE] )
		cCodBarras := PadR( aVidaLinkD[VL_DETALHE, _nI , VL_EAN ], nBarras )  
		cDescProd := Posicione(cTabelaProd,5,xFilial(cTabelaProd)+ cCodBarras  ,cCamDescProd)	//Com o codigo de barra (EAN) pego a descricao do Produto
		cDescProd := If(Empty(cDescProd) , STR0016, cDescProd ) //"Não encontrado produto com este código"

		nVlSubsidio := IIf(oTef:nCodFuncao == 902 .And. (aVidaLinkD[VL_DETALHE,_nI,VL_PRVENDA ] - aVidaLinkD[VL_DETALHE,_nI,VL_SUBSIDI] <=0) , 0 , aVidaLinkD[VL_DETALHE,_nI,VL_SUBSIDI] )
		
		aAdd(aLin , {	aVidaLinkD[VL_DETALHE,_nI,VL_NDXPROD]	,;  																					// Indice
  					    aVidaLinkD[VL_DETALHE,_nI,VL_EAN  ]		,;   		  																			// Cod Barra
  					    cDescProd            					,; 	  																					// Desc. Produto
  					    aVidaLinkD[VL_DETALHE,_nI,VL_QUANTID ]	,;   		  																			// Quantidade Autorizada
  					    aVidaLinkD[VL_DETALHE,_nI,VL_QUANTID ]	,;				 																		// Quantidade Compra
						aVidaLinkD[VL_DETALHE,_nI,VL_QUANTID ] * (aVidaLinkD[VL_DETALHE,_nI,VL_PRVENDA ] - nVlSubsidio) ,; 	// Preco de venda
						aVidaLinkD[VL_DETALHE,_nI,VL_QUANTID ] * (aVidaLinkD[VL_DETALHE,_nI,VL_PRVENDA ] - nVlSubsidio) } )	// Valor a pagar
	Next
	
	LjGrvLog( "PBM_FUNCIONAL_CARD", "Montagem da linha de cada produto - aLin", aLin )

	If Len(aLin) == 0
		aLin := { { "", "" , "" , 0, 0, 0, 0 } } // Linha vazia para o grid
	EndIf
	If oLbx <> Nil
		oLbx:SetArray(aLin)
		oLbx:bLine		:= { || { Transform( aLin[oLbx:nAt][1], '') , Transform( aLin[oLbx:nAt][2], '') , Transform( aLin[oLbx:nAt][3], ''), Transform( aLin[oLbx:nAt][4], '@E 999,999,999.99'), Transform( aLin[oLbx:nAt][5], '@E 999,999,999.99'), Transform( aLin[oLbx:nAt][6], '@E 999,999,999.99'), Transform( aLin[oLbx:nAt][7], '@E 999,999,999.99')  } }
		oLbx:Refresh()
		nTotVenda := aVidaLinkD[VL_TOTVEND]

		oTotVenda:Refresh()
	Endif	
EndIf
Return .T.

//---------------------------------------------------------------------------------
/*/{Protheus.doc} LjDROVLACli
Altera o cliente

@type 	 Function
@author  Alberto Deviciente
@since 	 01/06/2022
@version 12.1.27

@obs	Uso no Template de Drogarias

@param cCodCli, Caractere, Código do Cliente
@param cLojCli, Caractere, Loja do Cliente
@param cCliCodLoj, Caractere, Código do Cliente + Loja do Cliente
@param oGetCodCli, Objeto, Objeto Get do Código do Cliente
@param cNomeCli, Caractere, Nome do Cliente
@param oNomeCli, Objeto, Objeto Get do Nome do Cliente

@return Nil, Nulo
/*/
//---------------------------------------------------------------------------------
/*
TODO PBM PHARMASYSTEM
Function LjDROVLACli(cCodCli, cLojCli, cCliCodLoj, oGetCodCli, cNomeCli, oNomeCli)

FR271EAltCli( Nil		   				, @cCodCli		   			, @cLojCli		   			, @aParamVL[1][VLP_LOCIOS]	,;
			  @aParamVL[1][VLP_LRECEB]	, @aParamVL[1][VLP_LCXABE]	, @aParamVL[1][VLP_ACRDCL]	, @aParamVL[1][VLP_CCODCO]	,;
 			  @aParamVL[1][VLP_CLOJAC]	, @aParamVL[1][VLP_CNUMCA] 	, @aParamVL[1][VLP_UCLITP]	, @aParamVL[1][VLP_UPRODT]	,;
			  @aParamVL[1][VLP_AITENS]	, Nil		   				, Nil						, @aParamVL[1][VLP_CTIPOC]	,;
 			  Nil						, Nil			  			, Nil						, Nil 						)
 			 
cCliCodLoj	:= StrZero(Val(cCodCli), 6, 0) + " - " + cLojCli
cNomeCli	:= Subst(Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"A1_NOME"),1,30)

oGetCodCli:Refresh()
oNomeCli:Refresh()

Return Nil
*/

//---------------------------------------------------------------------------------
/*/{Protheus.doc} LjDROVLEQtd
Tela para editar a quantidade a ser Vendida por item Quantidade pode variar de 
zero ate qtd liberada pelo PBM.

@type 	 Function
@author  Alberto Deviciente
@since 	 01/06/2022
@version 12.1.27

@obs	Uso no Template de Drogarias

@param aLin, Array, Array com a lista de produtos PBM retornado
@param aVidaLinkD, Array, Array com dados do PBM
@param oLbx, Objeto, Objeto List do grid
@param nTotVenda, Numérico, Total da Venda
@param oTotVenda, Objeto, Objeto Total da venda

@return Nil, Nulo
/*/
//---------------------------------------------------------------------------------
Function LjDROVLEQtd(aLin, aVidaLinkD, oLbx, nTotVenda, oTotVenda)
Local nQtdeComp := aLin[oLbx:nAt][ 5 ]	// Quantidade a comprar
Local nQtdeSug  := aLin[oLbx:nAt][ 4 ]	// Quantidade sugerida
Local oDlgqtd                           // Objeto da tela de dialogo

DEFINE MSDIALOG oDlgqtd FROM  69,70 TO 160,331 TITLE "Quantidade a comprar" PIXEL
	@ 1, 02 TO 24, 128 OF oDlgqtd	PIXEL
	@ 7, 68 MSGET nQtdeComp Picture "@E 9999999.99" VALID IIF(nQtdeComp <= nQtdeSug .AND. nQtdeComp >= 0, .T.,  (Alert("A quantidade a comprar deve ser menor ou igual a quantidade autorizada."), .F.)) SIZE 54, 10 OF oDlgqtd PIXEL
	@ 8, 09 SAY "Quantidade a comprar"  SIZE 54, 7 OF oDlgqtd PIXEL
	DEFINE SBUTTON FROM 29, 71 TYPE 1 ENABLE ACTION (IIf( nQtdeComp <= nQtdeSug .And. nQtdeComp >= 0 , (aLin[oLbx:nAt][ 5 ]:=nQtdeComp,  If(!Empty(aVidaLinkD) , aVidaLinkD[VL_DETALHE, oLbx:nAt, VL_QUANTID ] :=nQtdeComp, ) , LjDROVLTot( @nTotVenda, @oTotVenda, @aVidaLinkD, @oLbx ) , oDlgqtd:End()), )) OF oDlgqtd
	DEFINE SBUTTON FROM 29, 99 TYPE 2 ENABLE ACTION ( oDlgqtd:End() ) OF oDlgqtd
ACTIVATE MSDIALOG oDlgqtd CENTERED

Return Nil

//---------------------------------------------------------------------------------
/*/{Protheus.doc} LjDROVLTot
Recalcula o total da compra somando os itens.

@type 	 Function
@author  Alberto Deviciente
@since 	 01/06/2022
@version 12.1.27

@obs	Uso no Template de Drogarias

@param nTotVenda, Numérico, Total da Venda
@param oTotVenda, Objeto, Objeto Total da venda
@param aVidaLinkD, Array, Array com dados do PBM
@param oLbx, Objeto, Objeto List do grid

@return Nil, Nulo
/*/
//---------------------------------------------------------------------------------
Function LjDROVLTot( nTotVenda, oTotVenda, aVidaLinkD, oLbx )
Local _nI := 0 // Contador

nTotVenda := 0    

If Len(aVidaLinkD) >= 4
	If !Empty(aVidaLinkD[VL_DETALHE])
		For _nI := 1 to Len(aVidaLinkD[VL_DETALHE])
			nTotVenda += aVidaLinkD[VL_DETALHE, _nI, VL_QUANTID] * (aVidaLinkD[VL_DETALHE, _nI, VL_PRVENDA])
		Next
	Endif
Endif

oLbx:AARRAY[oLbx:nAt][6 ] 	:= aVidaLinkD[VL_DETALHE,oLbx:nAt,VL_QUANTID] *(aVidaLinkD[VL_DETALHE,oLbx:nAt,VL_PRVENDA] - aVidaLinkD[VL_DETALHE,oLbx:nAt,VL_SUBSIDI])
oLbx:AARRAY[oLbx:nAt][7 ] 	:= aVidaLinkD[VL_DETALHE,oLbx:nAt,VL_QUANTID] * aVidaLinkD[VL_DETALHE,oLbx:nAt,VL_PRVENDA]
aVidaLinkD[VL_TOTVEND]		:= nTotVenda  // Atualiza o totalizador do array aVidaLink tambem
oTotVenda:Refresh()
oLbx:Refresh()

Return Nil

//---------------------------------------------------------------------------------
/*/{Protheus.doc} LjDROVLConf
No Botão Ok Checa o conteudo da Array aVidaLinkD. Se for valido fecha tela
caso contrario continua na tela. Neste caso so sera possivel sair da tela
com o botão cancelar que configura a array aVidaLinkD como vazia.

@type 	 Function
@author  Alberto Deviciente
@since 	 01/06/2022
@version 12.1.27

@obs	Uso no Template de Drogarias

@param aVidaLinkC, Array, Array com dados do PBM
@param aVidaLinkD, Array, Array com dados do PBM
@param nVidaLink, Numérico, Variável de controle do PBM
@param nTotVenda, Numérico, Total da Venda
@param oTotVenda, Objeto, Objeto Total da venda
@param cCodCli, Caractere, Código do Cliente
@param cLojCli, Caractere, Loja do Cliente

@return lRet, Lógico
/*/
//---------------------------------------------------------------------------------
Function LjDROVLConf(	aVidaLinkC	,	aVidaLinkD	,	nVidaLink	,	nTotVenda	,;
						oTotVenda	,	cCodCli		,	cLojCli		)
Local lRet := .F.          	// Retorno da funcao  
Local _nI  := 0            	// Variavel para usa no for
Local aVdLnkDAux := {}     	// Array para auxiliar retorno dos dados
Local aVidalink  := {}     	// Array para enviar os dados para o Frontloja
																																// oTEF:aRetVidalink:cNumPreAut
nTotVenda := 0
If Len(aVidaLinkD) >= 4
	If !Empty(aVidaLinkD[VL_DETALHE])
		For _nI := 1 to Len(aVidaLinkD[VL_DETALHE])
			nTotVenda += aVidaLinkD[VL_DETALHE, _nI, VL_QUANTID ] * (aVidaLinkD[VL_DETALHE, _nI, VL_PRVENDA ])
		Next		

		aVidaLinkD[VL_TOTVEND] := nTotVenda  // Atualiza o totalizador do array aVidaLink tambem
		If oTotVenda <> Nil 
			oTotVenda:Refresh()
		Endif	  
		
		If nTotVenda > 0
			lRet := .T.
		Else
			MsgStop(STR0009,STR0002) // Nao existem itens de venda para este numero de Autorização
		EndIf
	EndIf
EndIf

If lRet
	IIf(Empty(cCodCli) .or. Empty(cLojCli) .or. !ExistCpo("SA1",cCodCli+cLojCli,1), (lRet:=.F.,MsgStop(STR0012,STR0002)), Nil) // Informe um codigo de Cliente e Loja Valido
Endif

If lRet
	If oTef:nCodFuncao <> 540 
		If oTef:nCodFuncao <> 560 //PBM Funcional Card
			lRet := MsgYesNo(STR0013,STR0002) //"Confirma a Finalização da Venda para esta Autorização do PBM ?" ### "Atenção"
		EndIf	
	Else
	/*
		TODO PBM PHARMASYSTEM
		lRet := .T.
		MsgAlert("Numero de Pre-Autorizacao Gerado: " + oTEF:aRetVidalink:cNumPreAut)		
	*/
	Endif		
EndIf

If lRet
	aVidaLinkC := {cCodCli, cLojCli }	// Atualiza aVidaLinkC (Cabecalho) com codigo do Cliente e Loja
EndIf

If lRet
	For _nI := 1 to Len(aVidaLinkD[VL_DETALHE])
		If aVidaLinkD[VL_DETALHE, _nI, VL_QUANTID ] * aVidaLinkD[VL_DETALHE, _nI, VL_PRVENDA ]	> 0
			aAdd( aVdLnkDAux , aVidaLinkD[VL_DETALHE, _nI] )
		EndIf
	Next      
	
	aVidaLinkD[VL_DETALHE] := aVdLnkDAux
EndIf

If lRet
	nVidaLink := 1
Else
	nVidaLink := 0
EndIf      

aVidalink := {aVidaLinkD,aVidaLinkC,nVidalink}

//FrontLoja
FRT271aVL(aVidalink)  

//Venda Assistida
If Len(aVidaLinkD) > 0
	aVidalink := {aVidaLinkD,aVidaLinkC,2} 
	LJ7DadosVL(aVidalink) 
Else
	LJ7DadosVL({1})
EndIf
	
Return lRet

//---------------------------------------------------------------------------------
/*/{Protheus.doc} LjDROVLCanc
No Botão cancela fecha o dialogo e retorna a array aVidaLinkD vazia
Caso aVidaLinkD não esteja vazia pede a confirmação do cliente, avisando
que a array ficara vazia.

@type 	 Function
@author  Alberto Deviciente
@since 	 01/06/2022
@version 12.1.27

@obs	Uso no Template de Drogarias

@param aVidaLinkC, Array, Array com dados do PBM
@param aVidaLinkD, Array, Array com dados do PBM
@param nVidaLink, Numérico, Variável de controle do PBM
@param nTotVenda, Numérico, Total da Venda
@param oTotVenda, Objeto, Objeto Total da venda
@param lCancela, Lógico, Determina se cancela direto sem perguntar

@return lRet, Lógico
/*/
//---------------------------------------------------------------------------------
Function LjDROVLCanc(	aVidaLinkC	,	aVidaLinkD	,	nVidaLink	,	nTotVenda	,;
 						oTotVenda	, 	lCancela	)
Local lRet := .T.	// Retorno da funcao
Local _nI  := 0		// Contador

Default lCancela := .F.

nTotVenda := 0        

If Len(aVidaLinkD) = 4
	If !Empty(aVidaLinkD[VL_DETALHE])
		For _nI := 1 To Len(aVidaLinkD[VL_DETALHE])
			nTotVenda += aVidaLinkD[VL_DETALHE, _nI, VL_QUANTID ] * (aVidaLinkD[VL_DETALHE, _nI, VL_PRVENDA ])
		Next
		
		If oTotVenda <> NIL
			oTotVenda:Refresh()
		EndIf

		If lCancela //Cancela direto sem perguntar
			lRet := .T.
		ElseIf nTotVenda > 0
			lRet := MsgYesNo(STR0010,STR0002) //Confirma o cancelamento do uso desta Autorização do VidaLink ?
		EndIf
	EndIf
EndIf

If lRet	   						// Confirmado o cancelamento do Uso do VidaLink
	aVidaLinkC			:= {}	// Zera array aVidaLinkC (Cabecalho)
	aVidaLinkD			:= {}	// Zera array aVidaLinkC (Detalhe)
	nVidaLink			:= 0	// Nao esta usando o Orcamento do VidaLink
EndIf

Return lRet

//---------------------------------------------------------------------------------
/*/{Protheus.doc} LjDROVLVen
Após a conclusão da venda informa ao VidaLink os produto e quantidades vendidos atraves da array aVidaLinkD.
 Obs. As quantidades vendidas acima da autorização ou os produtos não autozados não serão 
 	  incluidos na array aVidaLinkD e não terão os seus preços sem os descontos do PBM.

@type 	 Function
@author  Alberto Deviciente
@since 	 01/06/2022
@version 12.1.27

@obs	Uso no Template de Drogarias

@param _nVidaLink, Numérico, Variável de controle do PBM
@param _aVidaLinkC, Array, Array com dados do PBM
@param _aVidaLinkD, Array, Array com dados do PBM
@param _cDoc, Caractere, Número do DOC

@return aRet, Array
/*/
//---------------------------------------------------------------------------------
Function LjDROVLVen(_nVidaLink,_aVidaLinkC,_aVidaLinkD,_cDoc)
Local aRet := {}					// Retorno da funcao

If _nVidaLink = 2  // Gravou VidaLink
	If nNumPbm == 1
		oTEF:Operacoes("VIDALINK_VENDA", _aVidaLinkD, , , _cDoc)			//VidaLink
	ElseIf nNumPbm = 541
		If Len(_aVidaLinkD) > 0
			oTEF:Operacoes("PHARMASYSTEM_VENDA", _aVidaLinkD, , , _cDoc)	//PharmaSystem	
		Endif
	ElseIf nNumPbm = 560 .Or. nNumPbm = 592
		If Len(_aVidaLinkD) > 0
			oTEF:Operacoes("FUNCARD_VENDA", _aVidaLinkD, , , _cDoc)			//Funcional Card	
		Endif
	Endif
EndIf

_aVidaLinkC := {}	// Zera array aVidaLinkC (Cabecalho)
_aVidaLinkD := {}	// Zera array aVidaLinkD (Detalhe)

aAdd(aRet, _nVidaLink)
aAdd(aRet, aClone(_aVidaLinkC) )
aAdd(aRet, _aVidaLinkD)

Return aRet

//---------------------------------------------------------------------------------
/*/{Protheus.doc} LjDROVLImp
Após a conclusão da venda imprime o comprovante de venda Vidalink no ECF como no exemplo abaixo:
     DEMONSTRATIVO PBM VIDALINK@No.Autorizacao.: 123456

     Obs. Se existir pagamento com TEF, a impressão do cupom VIDALINK se dará junto com o cupom TEF.

@type 	 Function
@author  Alberto Deviciente
@since 	 01/06/2022
@version 12.1.27

@obs	Uso no Template de Drogarias

@param _nVidaLink, Numérico, Variável de controle do PBM

@return aRet, Array
/*/
//---------------------------------------------------------------------------------
Function LjDROVLImp(_nVidaLink)
Local aRet := {}				// Retorno da Funcao

If _nVidaLink == 2  				// Gravou VidaLink, por isto imprimo cupom vidalink
	oTEF:ImpCupTef()
	_nVidaLink := 0				// Zera variavel após a impressão do cupom
EndIf 

aAdd(aRet,_nVidaLink)
Return aRet
 
//---------------------------------------------------------------------------------
/*/{Protheus.doc} LjDROVLPSet
Rotina usada para preencher o array aParamVL.

@type 	 Function
@author  Alberto Deviciente
@since 	 01/06/2022
@version 12.1.27

@obs	Uso no Template de Drogarias

@return .T., Lógico
/*/
//---------------------------------------------------------------------------------
Function LjDROVLPSet(	oHora			, cHora			, oDoc			, cDoc			,;
						oCupom		 	, cCupom		, nLastTotal	, nVlrTotal		,;
						nLastItem	 	, nTotItens		, nVlrBruto		, oDesconto		,;
						oTotItens	 	, oVlrTotal		, oFotoProd		, nMoedaCor		,;
						cSimbCor	 	, oTemp3		, oTemp4		, oTemp5		,;
						nTaxaMoeda	 	, oTaxaMoeda	, nMoedaCor		, cMoeda		,;
						oMoedaCor	 	, nVlrPercIT	, cCodProd		, cProduto		,;
						nTmpQuant	 	, nQuant		, cUnidade		, nVlrUnit		,;
						nVlrItem		, oProduto		, oQuant		, oUnidade		,;
						oVlrUnit	 	, oVlrItem		, lF7			, oPgtos		,;
						oPgtosSint	 	, aPgtos		, aPgtosSint	, cOrcam		,;
						cPDV		 	, lTefPendCS 	, aTefBKPCS		, oDlgFrt		,;
						cCliente	 	, cLojaCli		, cVendLoja		, lOcioso		,;
						lRecebe			, lLocked		, lCXAberto		, aTefDados		,;
						dDataCN			, nVlrFSD		, lDescIT		, nVlrDescTot	,;
						nValIPI			, aItens 		, nVlrMerc		, lEsc			,;
						aParcOrc	 	, cItemCOrc		, aParcOrcOld	, aKeyFimVenda	,;
						lAltVend	 	, lImpNewIT		, lFechaCup		, aTpAdmsTmp	,;
						cUsrSessionID	, cContrato		, aCrdCliente	, aContratos	,;
						aRecCrd			, aTEFPend		, aBckTEFMult	, cCodConv		,;
						cLojConv		, cNumCartConv	, uCliTPL		, uProdTPL		,;
						lDescTotal		, lDescSE4		, aVidaLinkD	, aVidaLinkc 	,;
						nVidaLink		, cCdPgtoOrc	, cCdDescOrc	, nValTPis		,;
						nValTCof		, nValTCsl		, lOrigOrcam	, lVerTEFPend	,;
						nTotDedIcms		, lImpOrc		, nVlrPercTot	, nVlrPercAcr	,;
						nVlrAcreTot		, nVlrDescCPg	, nVlrPercOri	, nQtdeItOri	,;
						nNumParcs		, aMoeda		, aSimbs		, cRecCart		,;
						cRecCPF			, cRecCont		, aImpsSL1		, aImpsSL2		,;
						aImpsProd		, aImpVarDup	, aTotVen		, nTotalAcrs	,;
						lRecalImp		, aCols			, aHeader 		, aDadosJur		,;
						aCProva			, aFormCtrl		, nTroco		, nTroco2 		,;
						lDescCond		, nDesconto		, aDadosCH		, lDiaFixo		,;
						aTefMult		, aTitulo		, lConfLJRec	, aTitImp		,;
						aParcelas		, oCodProd		, cItemCond		, lCondNegF5	,;
						nTxJuros		, nValorBase	, oMensagem		, oFntGet		,;
						cTipoCli		, lAbreCup		, lReserva		, aReserva  	,;
						oTimer			, lResume		, nValor 		, aRegTEF		,;
						lRecarEfet		, oOnOffLine	, nValIPIIT		, _aMult		,;
						_aMultCanc		, nVlrDescIT	, oFntMoeda		, lBscPrdON		,;
						oPDV			, aICMS			, lDescITReg)
						
	aParamVL := {} 
	
	aAdd(aParamVL, { 	oHora			, cHora			, oDoc			, cDoc			,;
						oCupom		 	, cCupom		, nLastTotal	, nVlrTotal		,;		
						nLastItem	 	, nTotItens		, nVlrBruto		, oDesconto		,;		
						oTotItens	 	, oVlrTotal		, oFotoProd		, nMoedaCor		,;		
						cSimbCor	 	, oTemp3		, oTemp4		, oTemp5		,;		
						nTaxaMoeda	 	, oTaxaMoeda	, nMoedaCor		, cMoeda		,;		
						oMoedaCor	 	, nVlrPercIT	, cCodProd		, cProduto		,;		
						nTmpQuant	 	, nQuant		, cUnidade		, nVlrUnit		,;		
						nVlrItem		, oProduto		, oQuant		, oUnidade		,;		
						oVlrUnit	 	, oVlrItem		, lF7			, oPgtos		,; 	
						oPgtosSint	 	, aPgtos		, aPgtosSint	, cOrcam		,;
						cPDV		 	, lTefPendCS 	, aTefBKPCS		, oDlgFrt		,;
						cCliente	 	, cLojaCli		, cVendLoja		, lOcioso		,;
						lRecebe			, lLocked		, lCXAberto		, aTefDados		,;
						dDataCN			, nVlrFSD		, lDescIT		, nVlrDescTot	,;
						nValIPI			, aItens 		, nVlrMerc		, lEsc			,;
						aParcOrc	 	, cItemCOrc		, aParcOrcOld	, aKeyFimVenda	,;
						lAltVend	 	, lImpNewIT		, lFechaCup		, aTpAdmsTmp	,;
						cUsrSessionID	, cContrato		, aCrdCliente	, aContratos	,;
						aRecCrd			, aTEFPend		, aBckTEFMult	, cCodConv		,;
						cLojConv		, cNumCartConv	, uCliTPL		, uProdTPL		,;
						lDescTotal		, lDescSE4		, aVidaLinkD	, aVidaLinkc 	,; 
						nVidaLink		, cCdPgtoOrc	, cCdDescOrc	, nValTPis		,; 
						nValTCof		, nValTCsl		, lOrigOrcam	, lVerTEFPend	,;
						nTotDedIcms		, lImpOrc		, nVlrPercTot	, nVlrPercAcr	,; 
						nVlrAcreTot		, nVlrDescCPg	, nVlrPercOri	, nQtdeItOri	,;
						nNumParcs		, aMoeda		, aSimbs		, cRecCart		,; 
						cRecCPF			, cRecCont		, aImpsSL1		, aImpsSL2		,; 
						aImpsProd		, aImpVarDup	, aTotVen		, nTotalAcrs	,;
						lRecalImp		, aCols			, aHeader 		, aDadosJur		,;
						aCProva			, aFormCtrl		, nTroco		, nTroco2 		,; 
						lDescCond		, nDesconto		, aDadosCH		, lDiaFixo		,;
						aTefMult		, aTitulo		, lConfLJRec	, aTitImp		,;
						aParcelas		, oCodProd		, cItemCond		, lCondNegF5	,;
						nTxJuros		, nValorBase	, oMensagem		, oFntGet		,;
						cTipoCli		, lAbreCup		, lReserva		, aReserva  	,;
						oTimer			, lResume		, nValor 		, aRegTEF		,;
						lRecarEfet		, oOnOffLine	, nValIPIIT		, _aMult		,;
						_aMultCanc		, nVlrDescIT	, oFntMoeda		, lBscPrdON		,;
						oPDV			, aICMS			, lDescITReg})
  						
Return(.T.)

//---------------------------------------------------------------------------------
/*/{Protheus.doc} LjDROVLPGet
Retornar o array aParamVL.

@type 	 Function
@author  Alberto Deviciente
@since 	 01/06/2022
@version 12.1.27

@obs	Uso no Template de Drogarias

@return aRet, Array
/*/
//---------------------------------------------------------------------------------
Function LjDROVLPGet()
Return aParamVL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LjDROVLPVal ³ Autor ³ Vendas CRM                            ³ Data ³13/10/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o valor do item da venda do VidaLink e maior ou menor,         ³±±
±±³          ³ para assumir o menor valor                                                 ³±±
±±³          ³ Recalcula o valor do desconto e percentual quando utiliza o valor do       ³±±
±±³          ³ do VidaLink                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Venda assistida e Front Loja com Template Drogarias                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LjDROVLPVal(aVidaLinkD , aVidaLinkc , nVidaLink , cCodProd   ,;
                     nVlrDescIT , nTmpQuant  , nVlrItem  , nVlrPercIT ,;
                     nVlrUnit   , aVidaLinkD , nNumItem  , uProdTPL   ,;
                     uCliTPL	, lImpOrc	 , cDoc		 , cSerie )
                            
Local aRetorno   := {}          									// Retorna  o Valor unitario e o Percentual de desconto
Local nQuant     := nTmpQuant  										// Quantidade a ser Vendida pela Vida link
Local nVlrPrVL   := aVidaLinkD[VL_DETALHE, nNumItem, VL_PRECO ]		// Valor do produto do Vida Link     
Local aRet	 	 := {}               								// Array com os retornos dos campos da funcao de Desconto do Template de Droagria

Local nVlrPrVdVl := aVidaLinkD[VL_DETALHE, nNumItem, VL_PRMAX ] 	// Bruto
Local nVdlkPrcV  := aVidaLinkD[VL_DETALHE, nNumItem, VL_PRVENDA ] 	// Liquido

Local nMoedaCor  := 1                                               // Moeda corrente
Local nDecimais  := MsDecimais(nMoedaCor)							// Numero de casas decimais
Local lVidaLink  := nVidaLink == 1

Default cDoc		:= ""
Default cSerie	:= ""
nVlrPercIT  := 0
nVlrDescIT  := 0
                     
aRet := ExecTemplate("FrtDescIT",.F.,.F.,{	cCodProd, nVlrPercIT, nVlrDescIT, nVlrItem,;
							uProdTPL, uCliTPL   , nQuant	, aParamVL[1][VLP_CCLIEN],;
							aParamVL[1][VLP_CLOJAC],lImpOrc , cDoc , cSerie , ;
							lVidaLink} )


nVlrPercIT  := aRet[1]
nVlrDescIT  := aRet[2] 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Acerta o preco Dos Intens pela quantidade liberada para a  ³ 
//³  Quantidade determinada pelo usuario                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVlrPrVdVl  := Round((nVlrPrVdVl) * nQuant,nDecimais)
nVlrPrVL    :=Round(nVlrPrVL ,nDecimais)

DbSelectArea("SBI")  
DbSetorder(1)    

If DbSeek(xFilial("SBI") + cCodProd )
	If Round((SBI->BI_PRV),nDecimais ) >= Round(nVdlkPrcV ,nDecimais)
   		nVlrDescIT := Round((SBI->BI_PRV)* nQuant  - (nVdlkPrcV * nQuant),nDecimais)
   		nVlrPercIT := Round((nVlrDescIT / (SBI->BI_PRV * nQuant) ) * 100 ,nDecimais) 
   		    	
		nVlrItem   := Round(nVdlkPrcV *nQuant,nDecimais)
   	Else    	    
   	    nVlrItem := Round((SBI->BI_PRV * nQuant) - nVlrDescIT,nDecimais)   	          
   	    MsgAlert(STR0015) //"Os Valores da Loja São menores que os do PBM."
	EndIf       
	
	nVlrUnit := SBI->BI_PRV                        		
EndIf
       
aRetorno := {nVlrItem,nVlrDescIT,nVlrPercIT,nVlrunit }  
Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} DroAddProd
Inseri produtos no venda assistida
@param 	 aProd		- Produtos selecionados do retorno do PBM
@author  Varejo
@version P11.80
@since   07/04/2017
@return  
/*/
//-------------------------------------------------------------------
Static Function DroAddProd(aProd)
Local nX 			:= 0	//Contador
Local nTotal		:= 0	//total pbm
Local nTotalProt	:= 0	//total protheus
Local lRet			:= .F.
Local nPosUni 		:= aScan( aHeader, {|x| Alltrim(Upper(x[2])) == "LR_VRUNIT"   } ) //Posicao do campo LR_VRUNIT

Default aProd 		:= {} 

LjGrvLog( "PBM_FUNCIONAL_CARD", "Inseri produtos na venda")

If Len(aProd) > 0
	For nX := 1 To Len(aProd)
	 	 lRet := Lj7LancItem(aProd[nX][VL_EAN],aProd[nX][VL_QUANTID],.T., aProd[nX][VL_PRVENDA]) //Inclui Item
		 If lRet
		 	aAdd(aProd[nX],n)
		 	LjGrvLog( "PBM_FUNCIONAL_CARD", "Produto inserido com sucesso - aProd[nX][VL_EAN] " + aProd[nX][VL_EAN], aProd[nX])
	    	nTotalProt += aCols[N][nPosUni] * aProd[nX][VL_QUANTID] //Acumula valor dos produtos do Protheus
	    	nTotal += aProd[nX][VL_PRVENDA] * aProd[nX][VL_QUANTID] //Acumula valor dos produtos do PBM Funcional Card
		 Else
		 	LjGrvLog( "PBM_FUNCIONAL_CARD", "Produto não inserido aProd[nX][VL_EAN] " , aProd[nX][VL_EAN])
		 EndIf
		 
	Next nX
	
	LjGrvLog( "PBM_FUNCIONAL_CARD", "Total de valores dos produtos no protheus - nTotalProt",nTotalProt)
	LjGrvLog( "PBM_FUNCIONAL_CARD", "Total de valores dos produtos no PBM - nTotal",nTotal)
	
	If nTotalProt < nTotal
		MsgAlert(Upper(STR0002) + " : " + STR0045) //"ATENÇÃO: O valor dos produtos do Protheus está menor que o valor do PBM Funcional Card, isto pode ocasionar divergência no valor a ser pago na finalização da venda."
	EndIf
EndIf	
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} LjDrGScrExMC
Retorna o valor da variável estática lCanTelMeC - se cancelou ou não 
a tela de medicamentos controlados
@author  julio.nery
@version P12.1.17
@since   01/02/2019
@return  lCanTelMeC
/*/
//-------------------------------------------------------------------
Function LjDrGScrExMC()
Return lCanTelMeC

//-------------------------------------------------------------------
/*/{Protheus.doc} LjDrSScrExMC
Seta o valor da variável estática lCanTelMeC - se cancelou ou não 
a tela de medicamentos controlados
@author  julio.nery
@version P12.1.17
@since   01/02/2019
@return  lCanTelMeC
/*/
//-------------------------------------------------------------------
Function LjDrSScrExMC( lSet )

lCanTelMeC := lSet

Return lCanTelMeC
