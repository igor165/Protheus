#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"            
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.ch"
#INCLUDE "pmswmt120.ch"
#DEFINE _EOL chr(13) + chr(10)  

/* --------------------------------------------------------------------------------------
WStruct		stCabSC7
Autor		Edvin Markstein Zimmermann
Data		29/03/2010
Descricao	Cabecalho da tabela SC7 (Pedido de Compra)
-------------------------------------------------------------------------------------- */
WSStruct stCabSC7

	WSData C7_FILIAL	as String
	WSData C7_EMISSAO	as STRING
	WSData C7_FORNECE	as String
	WSData C7_LOJA		as String
	WSData C7_COND		as String
	WSData C7_EMPRESA	as String
	WSData C7_MOEDA	As String OPTIONAL

EndWSStruct

/* --------------------------------------------------------------------------------------
WStruct	    aRatCTBPC
Autor	    Hilton vinhola do Nascimento
Data		29/03/2010
Descricao	Campos da tabela SCH (Rateio de centro de custo)
-------------------------------------------------------------------------------------- */
WSStruct aRatCTBPC
		WSData CH_PERC    AS Float  OPTIONAL
		WSData CH_CC      AS STRING OPTIONAL
		WSData CH_CONTA   AS STRING OPTIONAL
		WSData CH_ITEMCTA AS STRING OPTIONAL
		WSData CH_CLVL    AS STRING OPTIONAL
EndWSStruct  

/* --------------------------------------------------------------------------------------
WStruct		stCorpoSC7
Autor		Edvin Markstein Zimmermann
Data		24/03/2010
Descricao	Corpo da tabela SC7 (Pedido de Compra)
-------------------------------------------------------------------------------------- */
WSStruct stCorSC7
	WSData C7_ITEM	  		As String
	WSData C7_PRODUTO		As String
	WSData C7_QUANT  		As Float
	WSData C7_PRECO  		As Float
	WSData C7_CC      	   As String OPTIONAL
	WSData C7_SOLICIT		As String OPTIONAL 
	WSData C7_OBS			As String OPTIONAL
	WSData AJ7_PROJET   	As String OPTIONAL
	WSData AJ7_TAREFA		As String OPTIONAL
	WSData sRatCTBPC    	as array of aRatCTBPC OPTIONAL
	WsData sProjAJ7      as Array of aProjAJ7 OPTIONAL
EndWSStruct
               
/* --------------------------------------------------------------------------------------
WStruct	   aAdtPC
Autor	    Hilton vinhola do Nascimento
Data		29/03/2010
Descricao	Campos da tabela SCH (Rateio de centro de custo)
-------------------------------------------------------------------------------------- */
WSStruct aAdtPC
	   	WSData FIE_PREFIX  as string OPTIONAL
	  		WSData FIE_NUM     as string OPTIONAL
	  		WSData FIE_PARCEL  as string OPTIONAL
     		WSData FIE_TIPO    as string OPTIONAL
	   	WSData FIE_VALOR   as float OPTIONAL
EndWSStruct    

/* --------------------------------------------------------------------------------------
WStruct     aProjAJ7
Autor       
Data        27/12/2012
Descricao   Campos da tabela AJ7 (Rateio de projeto/Tarefa)
-------------------------------------------------------------------------------------- */
WsStruct aProjAJ7
    WSData cAJ7_PROJET As String
    WSData cAJ7_TAREFA  As String
    WSData nAJ7_QUANT   As Float
EndWsStruct       
         

/* --------------------------------------------------------------------------------------
WStruct		stPedidoCompra
Autor		Edvin Markstein Zimmermann
Data		24/03/2010
Descricao	Pedido de Compra
-------------------------------------------------------------------------------------- */
WSStruct stPedidoCompra
	WSData sCab		 as stCabSC7
	WSData sCor		 as array of stCorSC7    
	WSData sAdtPC	 as array of aAdtPC OPTIONAL
EndWSStruct

/* --------------------------------------------------------------------------------------
WStruct		stCabSC7
Autor		Edvin Markstein Zimmermann
Data		29/03/2010
Descricao	Cabecalho da tabela SC7 (Pedido de Compra)
-------------------------------------------------------------------------------------- */
WSStruct stEXCLUISC7

	WSData cC7_CODFIL		as String
	WsData cC7_CODID		as String
	WSData cC7_EMPRESA	as String

EndWSStruct


/* --------------------------------------------------------------------------------------
WebService	WSMATA120
Autor	    Hilton Vinhola do Nascimento
Data		24/03/2010
Descricao	Web Service MATA120 - Pedido de compra
-------------------------------------------------------------------------------------- */
WSService WSMATA120 Description STR0001//"MATA120 - Pedido de compra integrado do TOTVS Obras e Projetos"
    
    //Declaração de variaveis
	 WSData sPedidoCompra	as stPedidoCompra
	 WSData cId				as String
	 WSData cRet				as String
	 WSData sSC7Exclui		as stEXCLUISC7 
    WSDATA NUM_PEDIDO       AS STRING
  
    //Declaracaoo de metodos
  
  	 WSMethod Inclui		description STR0002//"Inclui um pedido de compra" 
	 WSMethod Exclui		description STR0003//"Exclui um pedido de compra" 
	 WSMethod Alterar    	description STR0004//"Altera um pedido de compra" 

ENDWSSERVICE


/*--------------------------------------------------------------------------------------
WSMethod	Inclui
Autor    	Hilton Vinhola do Nascimento
Data		20/03/2010
Descricao	Inclui um pedido de compra
Retorno		.t.
--------------------------------------------------------------------------------------*/
WSMethod Inclui WSReceive sPedidoCompra WSSEND cRet WSSERVICE WSMATA120
   Local aCabec     := {}
   Local aItens     := {}
   Local lAuto      := nil
   Local nI,nJ      := 0
   Local nSize      := 0
   Local oCabe      := nil
   Local oCorpo     := nil
   Local aErro      := {}
   Local nZ         := 0
   Local cErro      := ""
   Local aItPrjTmp  := {}
   Local aItPrj     := {}
   Local cRetorno   := ""
   Local cNomeU     := ""
   Local cUser      := "Recebe o codigo do usuario"
   Local cFil_C7    := ""
   Local aAdtPC     := {} // Adiantamento é por pedido
   Local aRatCTBPC  := {} // Rateio é por item do pedido
   Local ORatPJAJ7  := Nil
    
	// Controle de Filial PROTHEUS - 13/05/2010 - Multi Filiais
	// Controle de Filial PROTHEUS - 23/11/2010 - cEmpOOO/cFilOOO - Multi Empresas/Filiais
	Local aArea		:= {}
	Local cEmpOOO	:= ""
	Local cFilOOO	:= ""
	Local lEMPFil	:= .F.
	Local nFim     := 0 
	Local nColigada:=0
    Local lTOpxTin:=.F.
	Local cCusto:=''
	Local cFornece:=''
	Local cLojaF:=''
	Local n120Moeda := 0
	Local n120TxMoe := 0
	
	PRIVATE lMsErroAuto 	:= .F.  
	Private cCliente		:= ""
	Private cLoja			:= ""
	Private cCepe			:= ""
	Private cEnde			:= ""
	Private cBairroe		:= ""
	Private cMune			:= ""
	Private cEste			:= ""
	Private cNumPCWS		:= ""

	//UTILIZANDO VARIÁVEL PARA MELHOR VISUALIZAÇÃO DO CÓDIGO
	oCabe				:= ::sPedidoCompra:sCab
	oCorpo			:= ::sPedidoCompra:sCor
	oAdtPC			:= ::sPedidoCompra:sAdtPC	                                       

	// **********************
	// *********@@@**********
	// ********@@@@**********
	// *******@**@@**********
	// **********@@**********
	// **********@@**********
	// **********@@**********
	// **********************
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicionamento da Empresa/Filial                          ³
	//³                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   If Empty(oCabe:C7_EMPRESA) .or. Empty(oCabe:C7_FILIAL)
      SetSoapFault( "WSMATA120",STR0005 +  STR0006)//"Pedido de Compra nao incluso.Codigo da Empresa/Filial nao informado (vazio).
      return .F.
   Endif    

   If Type("cFilAnt") =="U" //retirou o preparein do ini
		If FindFunction("PmsW40Fil")
			cFilOOO := (oCabe:C7_FILIAL) 
			cEmpOOO :=	(oCabe:C7_EMPRESA) 
			lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
		Else //está sem o preparein, e nao vai conseguir setar a filial.
			SetSoapFault( "WSMATA120",STR0028)//"Não foi possível completar esta ação. É necessária uma atualização dos WebServices de integração TOP x Protheus. Entre com contato com o Suporte Totvs."                                                                                                                                                                                                                                                                                                                                                           
			return .F.
		Endif
	Else
	   cFilOOO := Padr(Alltrim(oCabe:C7_FILIAL) ,Len(cFilAnt) )
	   cEmpOOO := Padr(Alltrim(oCabe:C7_EMPRESA),Len(cEmpAnt) )
	
	   lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
	Endif

   If !lEMPFil
      SetSoapFault( "WSMATA120",STR0005 +  STR0007)//"Pedido de Compra nao incluso.Codigo da Empresa/Filial inexistente ou não autorizada."
      return .F.
   Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento de variavel apos ter definido o ambiente       ³
	//³                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArea		:= GetArea()
	nColigada:=GetNewPar('MV_RMCOLIG',0)
	lTopxTin:=Iif(FindFunction('IntTopTin'),IntTopTin(nColigada),.F.)
   // Define o codigo do login do usuario atraves do "nome do usuario" (MV_SLMCOM)
   cNomeU		:= GETMV("MV_SLMCOMP" ,.F. ,"")
   cUSERNAME	:= cNomeU
   cUSER		:= RetCodUsr()

	// **********************
	// *******@@@@@**********
	// ******@@**@@@*********
	// **********@@**********
	// *********@@@**********
	// ********@@@***********
	// *******@@@@@@*********
	// **********************

	// corrige o tamanho do campo
	If lTopxTin // indica que o cliente usa integração do Tin e TOP ao mesmo tempo
		cFornece:=IsTopxTin("SA2",(oCabe:C7_FORNECE))
		cLojaf	:=SubStr(cFornece,TamSX3("E2_FORNECE")[1]+1,TamSX3("E2_LOJA")[1])
		cFornece:=SubStr(cFornece,1,TamSX3("E2_FORNECE")[1])
	Else
		cFornece := padR(oCabe:C7_FORNECE,TamSX3("C7_FORNECE")[1])
		//Correção do problema gerado com o objeto oCabe 
		cLojaf :=padR(oCabe:C7_LOJA	,TamSX3("C7_LOJA")[1])
	Endif
	
	If ExistBlock("PWSMT12F")
		aRetPe := ExecBlock("PWSMT12F",.F.,.F.,{cFornece,cLojaf})
		If ValType(aRetPe) == "A" 
			If !aRetPe[1]
				SetSoapFault("WSMATA120",aRetPe[2])
				Return .F.
			Endif
		EndIf
	EndIf
	
	//CRIANDO CABECALHO
   cFil_C7 	:= xFilial("SC7")  
       
	// Verifica se a condição de pagamento foi informada no parâmetro MV_SLMCOND
	If Empty(oCabe:C7_COND)
		oCabe:C7_COND := GETMV("MV_SLMCOND", .F., "")
	EndIf

	// Verifica se foi informado
	If Empty(oCabe:C7_COND)
		SetSoapFault( "WSMATA120", STR0005 + " " + STR0008 )// "Pedido de Compra nao incluso.Condição de Pagamento nao informada (vazio)."
		return .F.
	Endif  

	AADD(aCabec,{"C7_FILIAL"		, cFil_C7									, Nil})
	AADD(aCabec,{"C7_EMISSAO"		, Ctod(oCabe:C7_EMISSAO)					, Nil})
	AADD(aCabec,{"C7_FORNECE"		, cFornece							, Nil})
	AADD(aCabec,{"C7_LOJA"			, cLojaf			     	, Nil})
	AADD(aCabec,{"C7_COND"			, oCabe:C7_COND						     	, Nil})
	AADD(aCabec,{"C7_NUM"			, ""					   					, Nil})
 	AADD(aCabec,{"C7_CONTATO"		, space(1) 									, Nil})
	AADD(aCabec,{"C7_FILENT"		, cFil_C7				  					, Nil})
	AADD(aCabec,{"C7_ORIGEM"		, "WSMATA12"								, Nil})
	
	If ValType(oCabe:C7_MOEDA) <> "U"					
  	  	n120Moeda := INTSPMOEDA(oCabe:C7_MOEDA)
	  	If n120Moeda > 0
	  		aAdd( aCabec , {"C7_MOEDA"		, n120Moeda	, Nil } )
	  		
	  		If n120Moeda > 1
	  			n120TxMoe := Posicione("SM2",1,dDataBase,"SM2->M2_MOEDA"+AllTrim(Str(n120Moeda)))
	  		Else
	  			n120TxMoe := 1
	  		Endif
	  		
	  		If n120TxMoe > 0
	  			aAdd( aCabec , {"C7_TXMOEDA"	, n120TxMoe	, Nil } )
			Else
	  			SetSoapFault( "WSMATA120", "Taxa Moeda não informada") 
				Return .F.
			Endif
	  	Else
	  		SetSoapFault( "WSMATA120", "Moeda: " + oCabe:C7_MOEDA + " não encontrada" ) 
			Return .F.
	  	Endif
	Endif
	
	//CRIANDO CORPO (SUB - ITENS DO ORCAMENTO TELEVENDAS)
	nSize := len( oCorpo )
	for nI := 1 to nSize
     
		aItensTemp := {}
		aadd( aItensTemp , {"C7_ITEM" 		, PadL( Alltrim(oCorpo[nI]:C7_ITEM), TamSX3("C7_ITEM")[1] ,"0" )	, Nil } )
		aadd( aItensTemp , {"C7_PRODUTO" 	, oCorpo[nI]:C7_PRODUTO	        	, Nil } )
		aadd( aItensTemp , {"C7_QUANT" 		, oCorpo[nI]:C7_QUANT		     	, Nil } )
		aadd( aItensTemp , {"C7_PRECO" 		, oCorpo[nI]:C7_PRECO		     	, Nil } )
		
		If !Empty(cUser)
			aadd( aItensTemp , {"C7_USER" 		, cUser						    , Nil } )
	  	EndIf
	  	
	  	//Nome do solicitante
	  	If !Empty(oCorpo[nI]:C7_SOLICIT)
  			aadd( aItensTemp , {"C7_SOLICIT" 		, oCorpo[nI]:C7_SOLICIT  , Nil } )
  		Endif
	  	
	  	aadd( aItensTemp , {"C7_ORIGEM"		, "WSMATA12"					, Nil } )
	  	
	  	If !Empty(oCorpo[nI]:C7_OBS)
	  		aadd( aItensTemp , {"C7_OBS" 		, oCorpo[nI]:C7_OBS  , Nil } )
	  	Endif
		
		oRatCTBPC	:= oCorpo[nI]:sRatCTBPC
   		nSizeRat 	:= Len(oRatCTBPC)
   		If nSizeRat <= 0
   			cCusto := oCorpo[nI]:C7_CC
   			If !Empty(cCusto)
	   			If lTopxTin
	            	cCusto := IsTopxTin("CTT",cCusto)
					cCusto := SubStr(cCusto,TAMSX3('CTT_FILIAL')[1]+1,TAMSX3("CTT_CUSTO")[1]) 
	   			Endif
	   			
				aAdd( aItensTemp , {"C7_CC" ,cCusto , Nil } )
	   			
	   			// valida o centro de custo enviado
	   			If(!PMSVldCC(cCusto, Ctod(oCabe:C7_EMISSAO), "WSMATA120"))   				
					return .F.
				EndIf
			Endif
		Else
		   	cItem 		:= PadL( Alltrim(oCorpo[nI]:C7_ITEM), TamSX3("C7_ITEM")[1] ,"0" ) 
   			nItensRat	:= 0
   			
   			aADD(aRatCTBPC,Array(2))                       
			aRatCTBPC[Len(aRatCTBPC)][1] := cItem 
			aRatCTBPC[Len(aRatCTBPC)][2] := {}
					 	
			For nJ := 1 to nSizeRat
							
				aItRatCC := {}
				nItensRat++
				
				cCusto	:= oRatCTBPC[nJ]:CH_CC
				
				If lTopxTin
	            	cCusto := IsTopxTin("CTT",(cCusto))
					cCusto := SubStr(cCusto,TAMSX3('CTT_FILIAL')[1]+1,TAMSX3("CTT_CUSTO")[1]) 
				Endif
				
				// realiza validacoes de centro de custo
				If(!PMSVldCC(cCusto, Ctod(oCabe:C7_EMISSAO), "WSMATA120"))   				
					return .F.
				EndIf
				
				aadd( aItRatCC , {"CH_FILIAL" 	, xFilial("SCH")   					, Nil } ) 
				aadd( aItRatCC , {"CH_ITEMPD"		, cItem         					, Nil } ) 
				aadd( aItRatCC , {"CH_ITEM" 		, PadL(nItensRat, TamSx3("CH_ITEM")[1], "0")	, Nil } ) // LINHA DO RATEIO
				aadd( aItRatCC , {"CH_PERC" 		, oRatCTBPC[nJ]:CH_PERC		     	, Nil } ) // PERCENTUAL
				aadd( aItRatCC , {"CH_CC"	    	, cCusto				, Nil } ) // CENTRO DE CUSTO
				aadd( aItRatCC , {"CH_CONTA"		, oRatCTBPC[nJ]:CH_CONTA			, Nil } ) // CONTA CONTABIL
				aadd( aItRatCC , {"CH_ITEMCTA"	, oRatCTBPC[nJ]:CH_ITEMCTA			, Nil } ) // ITEM CONTABIL
				aadd( aItRatCC , {"CH_CLVL"		, oRatCTBPC[nJ]:CH_CLVL				, Nil } ) // CLASSE DE VALOR
				aAdd(aRatCTBPC[Len(aRatCTBPC)][2], aClone(aItRatCC))	 	
			Next nJ
   		EndIf
	  	  
     // Roney de Oliveira - 27/12/2012
     ORatPJAJ7	:= oCorpo[nI]:sProjAJ7  
     nSizePJ    := Len(ORatPJAJ7)
     If nSizePJ > 0
        For nJ := 1 to nSizePJ
           If !Empty(ORatPJAJ7[nJ]:cAJ7_PROJET) .And. !Empty(ORatPJAJ7[nJ]:cAJ7_TAREFA)
            aItPrjTmp := {}
            aadd( aItPrjTmp , {"AJ7_PROJET"     , ORatPJAJ7[nJ]:cAJ7_PROJET         , Nil } )
            aadd( aItPrjTmp , {"AJ7_REVISA"     , StrZero(1,TamSX3("AJ7_REVISA")[1]), Nil } )
            aadd( aItPrjTmp , {"AJ7_TAREFA"     , ORatPJAJ7[nJ]:cAJ7_TAREFA         , Nil } )
            aadd( aItPrjTmp , {"AJ7_COD"        , oCorpo[nI]:C7_PRODUTO             , Nil } )
            aadd( aItPrjTmp , {"AJ7_QUANT"      , ORatPJAJ7[nJ]:nAJ7_QUANT          , Nil } )
            aadd( aItPrjTmp , {"AJ7_NUMPC"      , ""                                , Nil } )
            aadd( aItPrjTmp , {"AJ7_ITEMPC"     , PadL( Alltrim(oCorpo[nI]:C7_ITEM) , TamSX3("C7_ITEM")[1] ,"0" )    , Nil } )
            aadd( aItPrjTmp , {"AJ7_IDPROT"     , ""                                , Nil } )
            aAdd(aItPrj ,aClone(aItPrjTmp))
              
           EndIF
        Next nJ
     Else
        // Projetos e Tarefa de onde originou a Solicitação de Compras
        If !Empty(oCorpo[nI]:AJ7_PROJET) .And. !Empty(oCorpo[nI]:AJ7_TAREFA)
            aItPrjTmp := {}
            aadd( aItPrjTmp , {"AJ7_PROJET"     , oCorpo[nI]:AJ7_PROJET             , Nil } )
            aadd( aItPrjTmp , {"AJ7_REVISA"     , StrZero(1,TamSX3("AJ7_REVISA")[1]), Nil } )
            aadd( aItPrjTmp , {"AJ7_TAREFA"     , oCorpo[nI]:AJ7_TAREFA             , Nil } )
            aadd( aItPrjTmp , {"AJ7_COD"        , oCorpo[nI]:C7_PRODUTO             , Nil } )
            aadd( aItPrjTmp , {"AJ7_QUANT"      , oCorpo[nI]:C7_QUANT               , Nil } )
            aadd( aItPrjTmp , {"AJ7_NUMPC"      , ""                                , Nil } )
            aadd( aItPrjTmp , {"AJ7_ITEMPC"     , PadL( Alltrim(oCorpo[nI]:C7_ITEM), TamSX3("C7_ITEM")[1] ,"0" )    , Nil } )
            aadd( aItPrjTmp , {"AJ7_IDPROT"     , ""                                , Nil } )
            aAdd(aItPrj ,aClone(aItPrjTmp))
        EndIf
     EndIF
            
     If Len(aItPrj) = 0
       SetSoapFault( "WSMATA120", STR0009 + " "  + ALLTRIM(STR(nI)) + " " + STR0005 + STR0029) //"Projeto e/ou Tarefa não informado(s)."                  
        return .F.
     EndIf

		// Verifica se foi informado Preco
		If Empty(oCorpo[nI]:C7_PRECO)
			SetSoapFault( "WSMATA120",STR0009 + " "  + ALLTRIM(STR(nI)) + " " + STR0005 + STR0010)//"Item: " Pedido de Compra nao incluso. Preco nao informada (vazio)."
			return .F.
		Endif		
		
		// Verifica se foi informado Produto.
		If Empty(oCorpo[nI]:C7_PRODUTO)
			SetSoapFault( "WSMATA120",STR0009 + " "  + ALLTRIM(STR(nI)) + " " +  STR0005+  STR0011)//"Item: "" Pedido de Compra nao incluso.Produto nao informada (vazio)."
			return .F.
		Endif		
				
		// Verifica se foi informado Quantidade.
		If Empty(oCorpo[nI]:C7_QUANT)
			SetSoapFault( "WSMATA120",STR0009 + " "  + ALLTRIM(STR(nI)) + " " + STR0005 +  STR0012)//"Item: "" Pedido de Compra nao incluso.Quantidade nao informada (vazio)."
			return .F.
		Endif		
		
		aAdd(aItens,aItensTemp)
		
	next nI

	// VINCULANDO ADTOS PARA O PC
	// OS TITULOS DO TIPO PA JÁ DEVEM EXISTIR NA BASE
	// aAdtPC[x] --> array contendo os dados do título de PA a ser vinculado

	nSize := len( oAdtPC )
	for nI := 1 to nsize

		aItensTemp := {}
		aadd( aItensTemp , {"FIE_FILIAL" 	, xFilial("FIE")   					                				, Nil } )
		aadd( aItensTemp , {"FIE_CART" 		, "P"               				                				, Nil } ) // CARTEIRA PAGAR
		aadd( aItensTemp , {"FIE_PEDIDO" 	, ""                												, Nil } ) // NÃO PRECISA, POIS QUEM TRATA É A A120ADIANTAMENTO()
		aadd( aItensTemp , {"FIE_PREFIX" 	, PadR( Alltrim(oAdtPC[nI]:FIE_PREFIX),TamSX3("FIE_PREFIX")[1])	, Nil } )
		aadd( aItensTemp , {"FIE_NUM" 	    , PadR( Alltrim(oAdtPC[nI]:FIE_NUM),	TamSX3("FIE_NUM")   [1])	, Nil } )
		aadd( aItensTemp , {"FIE_PARCEL" 	, PadR( Alltrim(oAdtPC[nI]:FIE_PARCEL),TamSX3("FIE_PARCEL")[1])	, Nil } )
		aadd( aItensTemp , {"FIE_TIPO" 		, PadR( Alltrim(oAdtPC[nI]:FIE_TIPO	),	TamSX3("FIE_TIPO")  [1])	, Nil } )
	   	aadd( aItensTemp , {"FIE_FORNEC" 	, cFornece	, Nil } )
		aadd( aItensTemp , {"FIE_LOJA" 		, cLojaf	, Nil } )
		aadd( aItensTemp , {"FIE_VALOR" 	, oAdtPC[nI]:FIE_VALOR												, Nil } ) // VALOR DO PA QUE ESTÁ VINCULADO AO PEDIDO

		aAdd(aAdtPC, aClone(aItensTemp))

	next nI
    
	// Verifica se foi informado Data de Emissão
	If Empty(oCabe:C7_COND)
		SetSoapFault( "WSMATA120",STR0005 +  STR0008)//"Pedido de Compra nao incluso.Condicao de Pagamento nao informada (vazio)."
		return .F.
	Endif      
                                               
	// Verifica se foi informado Data de Emissão
	If Empty(Ctod(oCabe:C7_EMISSAO))
		SetSoapFault( "WSMATA120",STR0005 + STR0014 )//"Pedido de Compra nao incluso.Data de Emissao nao informada (vazio)."
		return .F.
	Endif

	// Verifica se foi informado Fornecedor
	If Empty(cFornece) .OR. Empty(cLojaf)
		SetSoapFault( "WSMATA120",STR0005 +  STR0015)//"Pedido de Compra nao incluso.Fornecedor nao informado (vazio)."
		return .F.
	Endif  
	BeginTran()

	// ponto de entrada inserido para controlar dados especificos do cliente
	If ExistBlock("PWSMT120")
		aRetPe := ExecBlock("PWSMT120",.F.,.F.,{aCabec,aItens,aRatCTBPC,aAdtPC})
		If ValType(aRetPe) == "A" .And. Len(aRetPe) == 4 .And.;
			 ValType(aRetPe[1]) == "A" .And. ValType(aRetPe[2]) == "A" .And.;
			 ValType(aRetPe[3]) == "A" .And. ValType(aRetPe[4]) == "A" 
			aCabec := aClone(aRetPe[1])
			aItens := aClone(aRetPe[2])
			aRatCTBPC := aClone(aRetPe[3])
			aAdtPC := aClone(aRetPe[4])
		EndIf
	EndIf

	conOut( STR0013 + "(" + TIME() + ")")//"EXECUTANDO FUNCAO DE GRAVACAO AUTOMATICA MATA120...
	MsExecAuto({|v,x,y,z,a,b,c| MATA120(v,x,y,z,a,b,c)},1,aCabec,aItens,3,.F.,aRatCTBPC,aAdtPC)
   
	If lMsErroAuto
		DisarmTransaction()

		conOut(STR0016)//" *** ATENCAO *** "
		conOut(+ " " + STR0017 + DtoC(Date()) + " - " + time())//"ERRO AO EFETUAR SOLICITACAO - DATA: "
		conOut(STR0018)//"++++++++++ SOLICITACAO DO ERRO ++++++++++"
		conOut(MemoRead(NomeAutoLog()))

		//LISTANDO DETALHES DO ERRO
		aErro := GetAutoGRLog()
		For nZ := 1 To Len(aErro)
			cErro += aErro[nZ] + Chr(13)+Chr(10)
		Next nZ
		conOut(cErro)
		conOut("---------------------------------------") 
		
		//LISTANDO DETALHES DO WS
		cErro:= STR0019 //"Verifique !, "       
		nFim:=10
		For nZ := 2 TO nFim
		   If ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) <> ""
  				cErro+= ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) + " "
  			Else            
  				nZ:=10
			Endif
		Next nZ
		SetSoapFault("WSMATA120",STR0019 + CRLF + MemoRead(NomeAutoLog()) )
		return .F.
	Else                                             
		conOut("MATA120" + " " +STR0020 + "(" + TIME() + ")" )       // EXECUTADO!				  
	EndIf

	If empty(cNumPCWS)
		cRetorno := GetNumSC7(cFilOOO, oCorpo[1]:C7_PRODUTO, oCorpo[1]:C7_QUANT, oCorpo[1]:C7_PRECO, oCabe:C7_FORNECE, oCabe:C7_LOJA, oCabe:C7_COND ,oCabe:C7_EMISSAO)
		conOut( STR0033+ " "  + cNumPCWS + ' (MAX)')//"Codigo Pedido de Compras :"
	Else
		cRetorno := cNumPCWS
		conOut( STR0033+ " "  + cNumPCWS + ' (cNumPCWS)')//"Codigo Pedido de Compras :"
	EndIf
	
	::cRet := cRetorno
	
	if empty(cRetorno)
		SetSoapFault("WSMATA120",STR0021)//"Pedido de compra incluido, mas impossivel retornar o codigo. Veja mais detalhes no error.log."
		return .F.
	endIf

	//
	// Gera a amarracao com o projeto
	//
	For nI := 1 to len(aItPrj)
		If (nPos:= aScan(aItPrj[nI],{|x| x[1] == "AJ7_NUMPC"}))>0
			aItPrj[nI,nPos,2] := cRetorno 
		EndIf

		If (nPos:= aScan(aItPrj[nI],{|x| x[1] == "AJ7_IDPROT"}))>0
			aItPrj[nI,nPos,2] := cRetorno 
		EndIf
	Next nI
	
	PMSWs120("3" ,aItPrj )

	EndTran()

   RestArea(aArea)		
   ::cRet := "PC;"+cRetorno 
Return .T.

/*--------------------------------------------------------------------------------------
WSMethod	Exclui
Autor		Edvin Markstein Zimmermann
Data		20/03/2010
Descricao	Exclui um pedido de compra
Retorno		.t.
--------------------------------------------------------------------------------------*/
//WSMethod Exclui WSReceive cId WSSEND cRet WSSERVICE WSMATA120
WSMethod Exclui WSReceive sSC7Exclui WSSEND cRet WSSERVICE WSMATA120

	Local aCabec		:= {}
	Local aItens		:= {}
	Local lAuto			:= nil
	Local aErro			:= {}
	Local nZ			:= 0
	Local cErro			:= ""
	Local aItPrjTmp		:= {}
	Local aItPrj		:= {}

	// Controle de Filial PROTHEUS - 13/05/2010 - Multi Filiais
	// Controle de Filial PROTHEUS - 23/11/2010 - cEmpOOO/cFilOOO - Multi Empresas/Filiais
	Local aArea			:= {}
	Local cEmpOOO		:= ""
	Local cFilOOO		:= ""
	Local lEMPFil		:= .F. 
	Local nFim        := 0

	PRIVATE lMsErroAuto := .F.  
	Private cCliente	:= ""
	Private cLoja		:= ""
	Private cCepe		:= ""
	Private cEnde		:= ""
	Private cBairroe	:= ""
	Private cMune		:= ""
	Private cEste		:= "" 
	
	// **********************
	// *********@@@**********
	// ********@@@@**********
	// *******@**@@**********
	// **********@@**********
	// **********@@**********
	// **********@@**********
	// **********************
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicionamento da Empresa/Filial                          ³
	//³                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    If Empty(::sSC7Exclui:cC7_EMPRESA) .Or. Empty(::sSC7Exclui:cC7_CODFIL)
		SetSoapFault( "WSMATA120",STR0022 +  STR0006)//"Pedido de Compra nao excluido.Codigo da Empresa/Filial nao informado (vazio)."
		return .F.
	Endif    

	If Type("cFilAnt") =="U" //retirou o preparein do ini
			If FindFunction("PmsW40Fil")
				cFilOOO := (::sSC7Exclui:cC7_CODFIL) 
				cEmpOOO :=	(::sSC7Exclui:cC7_EMPRESA) 
				lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
			Else //está sem o preparein, e nao vai conseguir setar a filial.
				SetSoapFault( "WSMATA120",STR0028)//"Não foi possível completar esta ação. É necessária uma atualização dos WebServices de integração TOP x Protheus. Entre com contato com o Suporte Totvs."                                                                                                                                                                                                                                                                                                                                                           
				return .F.
			Endif
	Else
		cFilOOO := Padr( Alltrim(::sSC7Exclui:cC7_CODFIL) ,Len(cFilAnt) )
		cEmpOOO := Padr( Alltrim(::sSC7Exclui:cC7_EMPRESA),Len(cEmpAnt) )
	
		lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
	Endif

    If !lEMPFil
		SetSoapFault( "WSMATA120",STR0022 +  STR0007 )//"Pedido de Compra nao excluido.Codigo da Empresa/Filial inexistente ou não autorizada"
		return .F.
    Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento de variavel apos ter definido o ambiente       ³
	//³                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArea		:= GetArea()
	
	// Define o codigo do login do usuario atraves do "nome do usuario" (MV_SLMCOM)
	cNomeU		:= GETMV("MV_SLMCOMP" ,.F. ,"")
    cUSERNAME	:= cNomeU
    cUSER		:= RetCodUsr()

	// **********************
	// *******@@@@@**********
	// ******@@**@@@*********
	// **********@@**********
	// *********@@@**********
	// ********@@@***********
	// *******@@@@@@*********
	// **********************

	cId := AllTrim( ::sSC7Exclui:cC7_CODID  )
	If "PC;" == SubStr(cId,1,3)
		cId:= SubStr(cId,4,TamSX3("C7_NUM")[1])
	Else
		cId := PADR( ::sSC7Exclui:cC7_CODID ,TamSX3("C7_NUM")[1] )
	Endif
	dbSelectArea("SC7")
	SC7->(dbSetOrder(1))
    If !SC7->(DbSeek(xFilial("SC7")+ cId))
		SetSoapFault("WSMATA120",STR0023)//"Codigo de pedido de compra nao encontrado."
		return .F.
	endIf		

	//CRIANDO CABECALHO
	AADD(aCabec,{"C7_NUM"	,cId		, Nil})

	DbSelectArea("AJ7")
	AJ7->(DbSetOrder(2)) //AJ7_FILIAL, AJ7_NUMPC, AJ7_ITEMPC, AJ7_PROJET, AJ7_REVISA, AJ7_TAREFA
	If AJ7->(DbSeek(xFilial("AJ7") + cId))
		While AJ7->(!EOF()) .And. AJ7->AJ7_NUMPC == cId
			aItPrjTmp := {}
			aadd( aItPrjTmp ,{"AJ7_NUMPC" 		, cId			 										, Nil } )
			aadd( aItPrjTmp ,{"AJ7_ITEMPC" 		, Padr(AJ7->AJ7_ITEMPC,TamSx3("AJ7_ITEMPC")[1])	, Nil } )
			aadd( aItPrjTmp ,{"AJ7_PROJET" 		, Padr(AJ7->AJ7_PROJET,TamSx3("AJ7_PROJET")[1])	, Nil } )
			aadd( aItPrjTmp ,{"AJ7_REVISA" 		, Padr(AJ7->AJ7_REVISA,TamSx3("AJ7_REVISA")[1])	, Nil } )
			aadd( aItPrjTmp ,{"AJ7_TAREFA" 		, Padr(AJ7->AJ7_TAREFA,TamSx3("AJ7_TAREFA")[1])	, Nil } )
			aAdd(aItPrj ,aClone(aItPrjTmp))
			AJ7->(DbSkip())
		Enddo
	Endif
	
	conOut(STR0024 + "(" + TIME() + ")") //"EXECUTANDO FUNCAO DE GRAVACAO AUTOMATICA MATA120...
    
	MsExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCabec,aItens,5)

	//VERIFICANDO SE HOUVE ERRO AO FECHAR O PEDIDO
	If lMsErroAuto

		conOut(STR0016)//" *** ATENCAO *** "
		conOut(STR0017 + " "  + DtoC(Date()) + " - " + time())//"     ERRO AO EFETUAR SOLICITACAO - DATA: "
		conOut(STR0018)//"++++++++++ SOLICITACAO DO ERRO ++++++++++"
		conOut(MemoRead(NomeAutoLog()))
		//LISTANDO DETALHES DO ERRO
		aErro := GetAutoGRLog()
		For nZ := 1 To Len(aErro)
			cErro += aErro[nZ] + Chr(13)+Chr(10)
		Next nZ
		conOut(cErro)
		conOut("---------------------------------------")
		
		//LISTANDO DETALHES DO WS
		cErro:= STR0019 //"Verifique !, "       
		nFim:=10
		For nZ := 2 TO nFim
		   If ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) <> ""
  				cErro+= ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) + " "
  			Else            
  				nZ:=10
			Endif
		Next nZ
		SetSoapFault("WSMATA120",STR0019 + CRLF + MemoRead(NomeAutoLog()) )
		return .F.
	Else
		conOut("MATA120"+ " " + STR0020 +  "(" + TIME() + ")")// EXECUTADO!
	EndIf

	// Exclui a associacao com o projeto
	pmsWs120("5" ,aItPrj )
	
	::cRet := STR0025 //"Pedido de compra excluido com sucesso."

RestArea(aArea)		

Return .T.

/* --------------------------------------------------------------------------------------
Funcao		GetNumSC7
Autor		Edvin Markstein Zimmermann
Data		29/03/2010
Descricao	Retorna ultimo codigo do SC7 de um determinado cliente
-------------------------------------------------------------------------------------- */
Static Function GetNumSC7(cC7_FILIAL, cC7_PRODUTO, cC7_QUANT, cC7_PRECO, cC7_FORNECE, cC7_LOJA, cC7_COND ,cC7_EMISSAO)

	Local cQuery	:= ""
	Local cRet		:= ""
	Local nDecimaisQ:= tamSX3("C7_QUANT")[2]
	Local nDecimaisP:= tamSX3("C7_PRECO")[2]

	cQuery := "SELECT MAX(C7_NUM) C7_NUM "
	cQuery += " FROM " + retSqlName("SC7")
	cQuery += " WHERE C7_PRODUTO = " + valToSql(cC7_PRODUTO)
	cQuery += " AND C7_QUANT = "     + AllTrim( Str( Round(cC7_QUANT, nDecimaisQ ) ,19 ,nDecimaisQ) )
	cQuery += " AND C7_PRECO = "     + AllTrim( Str( Round(cC7_PRECO, nDecimaisP ) ,19 ,nDecimaisP) )
	cQuery += " AND C7_FORNECE = "   + valToSql(cC7_FORNECE)
	cQuery += " AND C7_LOJA = "      + valToSql(cC7_LOJA)
	cQuery += " AND C7_COND = "      + valToSql(cC7_COND)
	cQuery += " AND C7_EMISSAO = "   + valToSql(CtoD(cC7_EMISSAO))
	cQuery += " AND C7_FILIAL ="     + valToSql(cC7_FILIAL)
	cQuery += " AND D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )

	If SELECT("WS_GETNUMSC7") > 0
		WS_GETNUMSC7->(dbCloseArea())
	EndIf

	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), "WS_GETNUMSC7", .T., .T. )

	dbSelectArea("WS_GETNUMSC7")

	If WS_GETNUMSC7->(Eof())
		WS_GETNUMSC7->(dbCloseArea())
		cRet := STR0026 + " " //"Codigo NumSC7 nao encontrado - pesquisa: "
		cRet += cC7_FILIAL + " - "
		cRet += cC7_PRODUTO + " - "
		cRet += STR(cC7_QUANT) + " - "
		cRet += STR(cC7_PRECO) + " - "
		cRet += cC7_FORNECE + " - "
		cRet += cC7_LOJA + " - "
		cRet += cC7_COND + " - "
		cRet += cC7_EMISSAO
		conout(cRet)
		return ""
	Endif

	cRet := WS_GETNUMSC7->C7_NUM

	WS_GETNUMSC7->(dbCloseArea())
	
	conOut( STR0033+ " " + cRet)//"Codigo Pedido de Compras :"

Return cRet

/*--------------------------------------------------------------------------------------
WSMethod	Alterar
Autor    	Hilton Vinhola do Nascimento
Data		20/03/2010
Descricao   ALTERA um pedido de compra
Retorno		.t.
--------------------------------------------------------------------------------------*/
WSMethod Alterar WSReceive sPedidoCompra,NUM_PEDIDO WSSEND cRet WSSERVICE WSMATA120

   Local aCabec	:= {}
   Local aItens	:= {}
   Local lAuto		:= nil
   Local nI,nJ		:= 0
   Local nSize		:= {}
   Local oCabe		:= nil
   Local oCorpo	:= nil
   Local aErro		:= {}
   Local nZ		:= 0
   Local cErro		:= ""
   Local aItPrjTmp	:= {}
   Local aItPrj	:= {}
   Local cRetorno 	:= ""
   Local cNomeU	:= ""
   Local cUser		:= "Recebe o codigo do usuario"
   Local cFil_C7	:= ""
   Local aAdtPC	:= {} // Adiantamento é por pedido
   Local aRatCTBPC	:= {} // Rateio é por item do pedido
   Local cItem		:= ""
   Local nFim     := 0
   Local cId:=""
   // Controle de Filial PROTHEUS - 13/05/2010 - Multi Filiais
   // Controle de Filial PROTHEUS - 23/11/2010 - cEmpOOO/cFilOOO - Multi Empresas/Filiais
   Local aArea			:= {}
   Local cEmpOOO		:= ""
   Local cFilOOO		:= ""
   Local lEMPFil		:= .F.
   Local ORatPJAJ7  := Nil	
	Local nColigada:=0
    Local lTOpxTin:=.F.
	Local cCusto:=''
	Local cFornece:=''
	Local cLojaf:=''
   PRIVATE lMsErroAuto := .F.  
   Private cCliente:= ""
   Private cLoja	:= ""
   Private cCepe	:= ""
   Private cEnde	:= ""
   Private cBairroe:= ""
   Private cMune	:= ""
   Private cEste	:= ""
   Private C7_NUM  := ""
   //UTILIZANDO VARIÁVEL PARA MELHOR VISUALIZAÇÃO DO CÓDIGO
   oCabe			:= ::sPedidoCompra:sCab
   oCorpo			:= ::sPedidoCompra:sCor
   oAdtPC			:= ::sPedidoCompra:sAdtPC
                                           
   // **********************
   // *********@@@**********
   // ********@@@@**********
   // *******@**@@**********
   // **********@@**********
   // **********@@**********
   // **********@@**********
   // **********************
	
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Posicionamento da Empresa/Filial                          ³
   //³                                                          ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   If Empty(oCabe:C7_EMPRESA) .or. Empty(oCabe:C7_FILIAL)
      SetSoapFault( "WSMATA120",STR0005 +  STR0006)//"Pedido de Compra nao incluso.Codigo da Empresa/Filial nao informado (vazio).
      return .F.
   Endif    

   If Type("cFilAnt") =="U" //retirou o preparein do ini
			If FindFunction("PmsW40Fil")
				cFilOOO := (oCabe:C7_FILIAL) 
				cEmpOOO :=	(oCabe:C7_EMPRESA) 
				lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
			Else //está sem o preparein, e nao vai conseguir setar a filial.
				SetSoapFault( "WSMATA120",STR0028)//"Não foi possível completar esta ação. É necessária uma atualização dos WebServices de integração TOP x Protheus. Entre com contato com o Suporte Totvs."
				return .F.
			Endif
	Else
	   cFilOOO := Padr(Alltrim(oCabe:C7_FILIAL) ,Len(cFilAnt) )
	   cEmpOOO := Padr(Alltrim(oCabe:C7_EMPRESA),Len(cEmpAnt) )
	
	   lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
	Endif

   If !lEMPFil
      SetSoapFault( "WSMATA120",STR0005 +  STR0007)//"Pedido de Compra nao incluso.Codigo da Empresa/Filial inexistente ou não autorizada."
      return .F.
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Tratamento de variavel apos ter definido o ambiente       ³
   //³                                                          ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aArea		:= GetArea()
	nColigada:=GetNewPar('MV_RMCOLIG',0)
	lTopxTin:=Iif(FindFunction('IntTopTin'),IntTopTin(nColigada),.F.)
   // Define o codigo do login do usuario atraves do "nome do usuario" (MV_SLMCOM)
   cNomeU		:= GETMV("MV_SLMCOMP" ,.F. ,"")
   cUSERNAME	:= cNomeU
   cUSER		:= RetCodUsr()
   cId:=AllTrim(::NUM_PEDIDO)
	
   If "PC;" == SubStr(cId,1,3)
      cId:= SubStr(cId,4,TamSX3("C7_NUM")[1])
   Else
      cId:=PADR( Alltrim(::NUM_PEDIDO), TamSX3("C7_NUM")[1] )
   Endif

   // **********************
   // *******@@@@@**********
   // ******@@**@@@*********
   // **********@@**********
   // *********@@@**********
   // ********@@@***********
   // *******@@@@@@*********
   // **********************
    
   dbselectArea("SC7")
   SC7->(DBSetOrder(1)) 
   
   IF !SC7->(DbSeek(xFilial("SC7")+cId))
      SetSoapFault("WSMATA120",STR0023 + " " +cEmpAnt+"|"+cFilAnt+"|"+xFilial("SC7")+"|"+cId)//"Codigo de pedido de compra nao encontrado: "
      return .F.
   endIf 


	If lTopxTin // indica que o cliente usa integração do Tin e TOP ao mesmo tempo
		cFornece:=IsTopxTin("SA2",(oCabe:C7_FORNECE))
		cLojaf	:=SubStr(cFornece,TamSX3("E2_FORNECE")[1]+1,TamSX3("E2_LOJA")[1])
		cFornece:=SubStr(cFornece,1,TamSX3("E2_FORNECE")[1])
	Else	
		cFornece := padR(oCabe:C7_FORNECE,TamSX3("C7_FORNECE")[1])
		cLojaf:=padR(oCabe:C7_LOJA,TamSX3("C7_LOJA")[1])
	Endif
	//CRIANDO CABECALHO
   cFil_C7 	:= xFilial("SC7")  
     
	AADD(aCabec,{"C7_FILIAL"		, cFil_C7									, Nil})
   	AADD(aCabec,{"C7_EMISSAO"		, Ctod(oCabe:C7_EMISSAO)					, Nil})
	AADD(aCabec,{"C7_FORNECE"		, cFornece							, Nil})
	AADD(aCabec,{"C7_LOJA"			, cLojaf					     	, Nil})
	AADD(aCabec,{"C7_COND"			, oCabe:C7_COND						     	, Nil})
	AADD(aCabec,{"C7_NUM"			, cId								, Nil})
 	AADD(aCabec,{"C7_CONTATO"		, space(1) /*/oCabe:C7_CONTATO/*/			, Nil})
	AADD(aCabec,{"C7_FILENT"		, cFil_C7				  					, Nil})

	//CRIANDO CORPO (SUB - ITENS DO ORCAMENTO TELEVENDAS)
	nSize := len( oCorpo )
                                    
   SC7->(dbSetOrder(1))
   For nI := 1 to nSize
     
     cItem := PadL( Alltrim(oCorpo[nI]:C7_ITEM), TamSX3("C7_ITEM")[1] ,"0" ) 

     SC7->(MsSeek(cFil_C7 + cId+ cItem ))
     aItensTemp := {}
     aadd( aItensTemp , {"C7_ITEM" 		, cItem							, Nil } )
     aadd( aItensTemp , {"C7_PRODUTO" 	, oCorpo[nI]:C7_PRODUTO	  			, Nil } )
     aadd( aItensTemp , {"C7_QUANT" 		, oCorpo[nI]:C7_QUANT		   		, Nil } )
     aadd( aItensTemp , {"C7_PRECO" 		, oCorpo[nI]:C7_PRECO		   		, Nil } )
     If !Empty(cUser)
        aadd( aItensTemp , {"C7_USER" 	, cUser						     	, Nil } )
     EndIf
	 cCusto:=oCorpo[nI]:C7_CC
	if lTopxTin
      	cCusto:=IsTopxTin("CTT",(cCusto))
		cCusto:=SubStr(cCusto,TAMSX3('CTT_FILIAL')[1]+1,TAMSX3("CTT_CUSTO")[1]) 
	Endif
  	aadd( aItensTemp , {"C7_CC" 		,cCusto					, Nil } )
	aadd( aItensTemp , {"C7_REC_WT   " 	, SC7->(RECNO())               	    , Nil } )
	
	oRatCTBPC	:= oCorpo[nI]:sRatCTBPC
	nSizeRat 	:= Len(oRatCTBPC)
	If nSizeRat <= 0
		cCusto := oCorpo[nI]:C7_CC
		
		If !Empty(cCusto)
   			If lTopxTin
            	cCusto := IsTopxTin("CTT",cCusto)
				cCusto := SubStr(cCusto,TAMSX3('CTT_FILIAL')[1]+1,TAMSX3("CTT_CUSTO")[1]) 
   			Endif
   			
			aAdd( aItensTemp , {"C7_CC" ,cCusto , Nil } )
   			
   			// valida o centro de custo enviado
   			If(!PMSVldCC(cCusto, Ctod(oCabe:C7_EMISSAO), "WSMATA120"))   				
				return .F.
			EndIf
		Endif
	Else
	   	cItem 		:= PadL( Alltrim(oCorpo[nI]:C7_ITEM), TamSX3("C7_ITEM")[1] ,"0" ) 
		nItensRat	:= 0
		
		aADD(aRatCTBPC,Array(2))                       
		aRatCTBPC[Len(aRatCTBPC)][1] := cItem 
		aRatCTBPC[Len(aRatCTBPC)][2] := {}
				 	
		For nJ := 1 to nSizeRat
						
			aItRatCC := {}
			nItensRat++
			
			cCusto	:= oRatCTBPC[nJ]:CH_CC
			
			If lTopxTin
            	cCusto := IsTopxTin("CTT",(cCusto))
				cCusto := SubStr(cCusto,TAMSX3('CTT_FILIAL')[1]+1,TAMSX3("CTT_CUSTO")[1]) 
			Endif
			
			// realiza validacoes de centro de custo
			If(!PMSVldCC(cCusto, Ctod(oCabe:C7_EMISSAO), "WSMATA120"))   				
				return .F.
			EndIf
			
			aadd( aItRatCC , {"CH_FILIAL" 	, xFilial("SCH")   					, Nil } ) 
			aadd( aItRatCC , {"CH_ITEMPD"		, cItem         					, Nil } ) 
			aadd( aItRatCC , {"CH_ITEM" 		, PadL(nItensRat, TamSx3("CH_ITEM")[1], "0")	, Nil } ) // LINHA DO RATEIO
			aadd( aItRatCC , {"CH_PERC" 		, oRatCTBPC[nJ]:CH_PERC		     	, Nil } ) // PERCENTUAL
			aadd( aItRatCC , {"CH_CC"	    	, cCusto				, Nil } ) // CENTRO DE CUSTO
			aadd( aItRatCC , {"CH_CONTA"		, oRatCTBPC[nJ]:CH_CONTA			, Nil } ) // CONTA CONTABIL
			aadd( aItRatCC , {"CH_ITEMCTA"	, oRatCTBPC[nJ]:CH_ITEMCTA			, Nil } ) // ITEM CONTABIL
			aadd( aItRatCC , {"CH_CLVL"		, oRatCTBPC[nJ]:CH_CLVL				, Nil } ) // CLASSE DE VALOR
			aAdd(aRatCTBPC[Len(aRatCTBPC)][2], aClone(aItRatCC))	 	
		Next nJ
	EndIf
		
     // Roney de Oliveira - 27/12/2012
     ORatPJAJ7 := oCorpo[nI]:sProjAJ7 
     nSizePJ    := Len(ORatPJAJ7)     
     If nSizePJ > 0
        For nJ := 1 to nSizePJ
           If !Empty(ORatPJAJ7[nJ]:cAJ7_PROJET) .And. !Empty(ORatPJAJ7[nJ]:cAJ7_TAREFA)              
              aItPrjTmp := {}
              aadd( aItPrjTmp , {"AJ7_PROJET"     , ORatPJAJ7[nJ]:cAJ7_PROJET         , Nil } )
              aadd( aItPrjTmp , {"AJ7_REVISA"     , StrZero(1,TamSX3("AJ7_REVISA")[1]), Nil } )
              aadd( aItPrjTmp , {"AJ7_TAREFA"     , ORatPJAJ7[nJ]:cAJ7_TAREFA         , Nil } )
              aadd( aItPrjTmp , {"AJ7_COD"        , oCorpo[nI]:C7_PRODUTO             , Nil } )
              aadd( aItPrjTmp , {"AJ7_QUANT"      , ORatPJAJ7[nJ]:nAJ7_QUANT          , Nil } )
              aadd( aItPrjTmp , {"AJ7_NUMPC"      , ""                                , Nil } )
              aadd( aItPrjTmp , {"AJ7_ITEMPC"     , PadL( Alltrim(oCorpo[nI]:C7_ITEM) , TamSX3("C7_ITEM")[1] ,"0" )    , Nil } )
              aadd( aItPrjTmp , {"AJ7_IDPROT"     , ""                                , Nil } )
              aAdd(aItPrj ,aClone(aItPrjTmp))              
           EndIF            
        Next nJ     
     Else
        // Projetos e Tarefa de onde originou a Solicitação de Compras
        If !Empty(oCorpo[nI]:AJ7_PROJET) .And. !Empty(oCorpo[nI]:AJ7_TAREFA)  
           aItPrjTmp := {}
           aadd( aItPrjTmp , {"AJ7_PROJET"     , oCorpo[nI]:AJ7_PROJET             , Nil } )
           aadd( aItPrjTmp , {"AJ7_REVISA"     , StrZero(1,TamSX3("AJ7_REVISA")[1]), Nil } )
           aadd( aItPrjTmp , {"AJ7_TAREFA"     , oCorpo[nI]:AJ7_TAREFA             , Nil } )
           aadd( aItPrjTmp , {"AJ7_COD"        , oCorpo[nI]:C7_PRODUTO             , Nil } )
           aadd( aItPrjTmp , {"AJ7_QUANT"      , oCorpo[nI]:C7_QUANT               , Nil } )
           aadd( aItPrjTmp , {"AJ7_NUMPC"      , ""                                , Nil } )
           aadd( aItPrjTmp , {"AJ7_ITEMPC"     , PadL( Alltrim(oCorpo[nI]:C7_ITEM), TamSX3("C7_ITEM")[1] ,"0" )    , Nil } )
           aadd( aItPrjTmp , {"AJ7_IDPROT"     , ""                                , Nil } )
           aAdd(aItPrj ,aClone(aItPrjTmp))
        EndIf
     EndIF
            
     If Len(aItPrj) = 0         
       SetSoapFault( "WSMAT110",STR0029) //"Projeto e/ou Tarefa não informado(s)."                  
       return .F.
     EndIf		
	
     // Verifica se foi informado Centro de Custo
     If Empty(oCorpo[nI]:C7_CC)
        SetSoapFault( "WSMATA120",STR0009 + " "  + ALLTRIM(STR(nI)) + " " + STR0005 +  STR0027)//"Item: " Pedido de Compra nao incluso.Centro de Custo nao informada (vazio)."
			return .F.
     Endif    

		// Verifica se foi informado Preco
		If Empty(oCorpo[nI]:C7_PRECO)
			SetSoapFault( "WSMATA120",STR0009 + " "  + ALLTRIM(STR(nI)) +" " +  STR0005 +  STR0010)//"Item: " Pedido de Compra nao incluso.Preco nao informada (vazio)."
			return .F.
		Endif		
		
		// Verifica se foi informado Produto.
		If Empty(oCorpo[nI]:C7_PRODUTO)
			SetSoapFault( "WSMATA120",STR0009 + " " +  ALLTRIM(STR(nI)) + " " + STR0005 +  STR0011)//"Item: " Pedido de Compra nao incluso.Produto nao informada (vazio)."
			return .F.
		Endif		
				
		// Verifica se foi informado Quantidade.
		If Empty(oCorpo[nI]:C7_QUANT)
			SetSoapFault( "WSMATA120",STR0009 + " "  + ALLTRIM(STR(nI)) + " " + STR0005 +  STR0012)//"Item:  Pedido de Compra nao incluso.Quantidade nao informada (vazio)."
			return .F.
		Endif		
		
		aAdd(aItens, aClone(aItensTemp))
		
	next nI

	// VINCULANDO ADTOS PARA O PC
	// OS TITULOS DO TIPO PA JÁ DEVEM EXISTIR NA BASE
	// aAdtPC[x] --> array contendo os dados do título de PA a ser vinculado

	nSize := len( oAdtPC )
	for nI := 1 to nsize	
		aItensTemp := {}
		aadd( aItensTemp , {"FIE_FILIAL" 	, cFil_C7       					                				, Nil } )
		aadd( aItensTemp , {"FIE_CART" 		, "P"								                				, Nil } ) // CARTEIRA PAGAR
		aadd( aItensTemp , {"FIE_PEDIDO" 	, ""                												, Nil } ) // NÃO PRECISA, POIS QUEM TRATA É A A120ADIANTAMENTO()
		aadd( aItensTemp , {"FIE_PREFIX" 	, PadR( Alltrim(oAdtPC[nI]:FIE_PREFIX),	TamSX3("FIE_PREFIX")[1])	, Nil } )
		aadd( aItensTemp , {"FIE_NUM" 	    , PadR( Alltrim(oAdtPC[nI]:FIE_NUM),	TamSX3("FIE_NUM")   [1])	, Nil } )
		aadd( aItensTemp , {"FIE_PARCEL" 	, PadR( Alltrim(oAdtPC[nI]:FIE_PARCEL),	TamSX3("FIE_PARCEL")[1])	, Nil } )
		aadd( aItensTemp , {"FIE_TIPO" 		, PadR( Alltrim(oAdtPC[nI]:FIE_TIPO	),	TamSX3("FIE_TIPO")  [1])	, Nil } )
		aadd( aItensTemp , {"FIE_FORNEC" 	, cFornece															, Nil } )
		aadd( aItensTemp , {"FIE_LOJA" 		, cLojaf															, Nil } )
		aadd( aItensTemp , {"FIE_VALOR" 	, oAdtPC[nI]:FIE_VALOR												, Nil } ) // VALOR DO PA QUE ESTÁ VINCULADO AO PEDIDO

		aAdd(aAdtPC, aClone(aItensTemp))

	next nI

	CONOUT(STR0024 + "(" + TIME() + ")")//"EXECUTANDO FUNCAO DE GRAVACAO AUTOMATICA MATA120...
  
	MsExecAuto({|v,x,y,z,a,b,c| MATA120(v,x,y,z,a,b,c)},1,aCabec,aItens,4,.F.,aRatCTBPC,aAdtPC)
 
	// Verifica se foi informado Data de Emissão
	If Empty(oCabe:C7_COND)
		SetSoapFault( "WSMATA120",STR0005 + STR0008 )//"Pedido de Compra nao incluso.Condicao de Pagamento nao informada (vazio)."
		return .F.
	Endif      
                                               
	// Verifica se foi informado Data de Emissão
	If Empty(Ctod(oCabe:C7_EMISSAO))
		SetSoapFault( "WSMATA120",STR0005+  STR0014)//"Pedido de Compra nao incluso.Data de Emissao nao informada (vazio)."
		return .F.
	Endif

	// Verifica se foi informado Fornecedor
	If Empty(oCabe:C7_FORNECE) .OR. Empty(oCabe:C7_LOJA)
		SetSoapFault( "WSMATA120",STR0005 +  STR0015)//"Pedido de Compra nao incluso.Fornecedor nao informado (vazio)."
		return .F.
	Endif  
	
	//VERIFICANDO SE HOUVE ERRO AO FECHAR O PEDIDO

	If lMsErroAuto
		CONOUT(STR0016)//" *** ATENCAO *** "
		conout(STR0017 + " " + DtoC(Date()) + " - " + time())//"     ERRO AO EFETUAR SOLICITACAO - DATA: " 
		CONOUT(STR0018)//"++++++++++ SOLICITACAO DO ERRO ++++++++++"
		conout(MemoRead(NomeAutoLog()))

		//LISTANDO DETALHES DO ERRO
		aErro := GetAutoGRLog()
		For nZ := 1 To Len(aErro)
			cErro += aErro[nZ] + Chr(13)+Chr(10)
		Next nZ
		conout(cErro)
		CONOUT("---------------------------------------")   
		
		//LISTANDO DETALHES DO WS
		cErro:= STR0019 //"Verifique !, "       
		nFim:=10
		For nZ := 2 TO nFim
		   If ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) <> ""
  				cErro+= ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) + " "
  			Else            
  				nZ:=10
			Endif
		Next nZ
		SetSoapFault("WSMATA120",STR0019 + CRLF + MemoRead(NomeAutoLog()))
		return .F.
	Else
		conout("MATA120" + " " + STR0020 +  "(" + TIME() + ")")//EXECUTADO! 
	EndIf
	
	::cRet 		:= cId
	cRetorno 	:= ::cRet

	//
	// Gera a amarracao com o projeto
	//
	For nI := 1 to len(aItPrj)
		If (nPos:= aScan(aItPrj[nI],{|x| x[1] == "AJ7_NUMPC"}))>0
			aItPrj[nI,nPos,2] := cRetorno 
		EndIf

		If (nPos:= aScan(aItPrj[nI],{|x| x[1] == "AJ7_IDPROT"}))>0
			aItPrj[nI,nPos,2] := cRetorno 
		EndIf

	Next nI
	
	PMSWs120("3" ,aItPrj )

   RestArea(aArea)		
   ::cRet 		:= "PC;"+cId
Return .T.
                     


User Function NOTHING4; Return  // "dummy" function - Internal Use

//-------------------------------------------------------------------
/*/{Protheus.doc} PMSVldCC
	Funcao para validar códigos de centro de custos enviados pelas solicitacoes/pedidos.	
	
	@param	cCCusto Codigo do centro a ser validado
	@param	dDataEmissao Data de emissao da solicitacao ou pedido. Utilizar a funcao CtoD()	
	@param	cNomeWS Nome do WebService onde a validacao está sendo realizada		 
	@author	Luís Gustavo dias <luis.gustavo@totvs.com.br>
	@version	P11
	@since	18/10/2012
	@return	cResultado
/*/
//-------------------------------------------------------------------
Function PMSVldCC(cCCusto, dDataEmissao, cNomeWS)
	Local lRet := .T.

	If(!ValidaCusto(cCCusto,,,,.T.))
   	SetSoapFault( cNomeWS, STR0030+ " "  + cCCusto + " " + STR0031)//"Verifique! Centro de custo " - " é inválido ou é sintético." 
		lRet := .F.
	ElseIf (!ValidaBloq(cCCusto, dDataEmissao,"CTT"))
		SetSoapFault( cNomeWS, STR0030+ " "  + cCCusto + " " + STR0032 )//"Verifique! Centro de custo " - " está bloqueado."
		lRet := .F.
	EndIf	
Return lRet

/*/{Protheus.doc} INTSPMOEDA
	Função para retorno a moeda em que o pedido esta sendo gerado.	
	
	@param	cSimbMoeda Simbolo da moeda a ser pesquisado nos MV_SIMB?
	
	@author	Rodrigo Machado Pontes
	@version	P11
	@since	27/01/2016
	@return	nRet => Moeda
/*/

Function INTSPMOEDA(cSimbMoeda)

Local nRet	:= 0
Local nI	:= 0
Local cPar	:= ""

For nI := 1 To 5 //Pois temos 5 tipos de moedas (Padrão)
	cPar := "MV_SIMB" + AllTrim(Str(nI))
	
	If AllTrim(Upper(SuperGetMv(cPar))) == AllTrim(Upper(cSimbMoeda))
		nRet := nI
		Exit
	Endif
Next nI

Return nRet                                


