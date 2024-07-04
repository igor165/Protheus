#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"            
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.ch"
#INCLUDE "pmswmt110.ch"
#DEFINE LINHAS 999

#DEFINE _EOL chr(13) + chr(10)

/* --------------------------------------------------------------------------------------
WStruct		stCabSC1
Autor		Wilson Possani de Godoi
Data		27/06/2011
Descricao	Cabecalho da tabela SC1 (Solicitacao de Compras)
-------------------------------------------------------------------------------------- */
WSStruct stCabSC1
	WSData cCodComp as String
	WSData cEMPRESA as String
	WSData cFil		 as String
	WSData cFilEnt	 as String
	WSData cNum		 as String OPTIONAL
	WSData cSolic	 as String	 
	WSData cUnidReq as String OPTIONAL
	WSData dEmissao as String
	WSData cC1_MOEDA   	As String OPTIONAL	
EndWSStruct

/* --------------------------------------------------------------------------------------
WStruct		stCorpoSC1
Autor		Wilson Possani de Godoi
Data		27/06/2011
Descricao	Corpo da tabela SC1 (Solicitacao de Compras)
-------------------------------------------------------------------------------------- */
WSStruct stCorSC1
	WSData cAFG_PROJETO	As String OPTIONAL
	WSData cAFG_TAREFA	As String OPTIONAL
	WSData cC1_ALI_WT		As String OPTIONAL	
	WSData cC1_CC			As String OPTIONAL
	WSData cC1_CLVL		As String OPTIONAL
	WSData cC1_CONTA		As String OPTIONAL
	WSData cC1_DATPRF		As String
	WSData cC1_DESCRI		As String
	WSData cC1_ITEM		As String				
	WSData cC1_ITEMCTA	As String OPTIONAL
	WSData cC1_LOCAL		As String
	WSData cC1_OBS			As String OPTIONAL
	WSData cC1_PRODUTO	As String 
	WSData cC1_REC_WT		As String OPTIONAL	
	WSData cC1_SEGUM		As String OPTIONAL
	WSData cC1_TPOP   	As String OPTIONAL
	WSData cC1_UM			As String
	WSData nC1_QTSEGUM	As Float  OPTIONAL
	WSData nC1_QUANT		As Float
	WSData nC1_VUNIT		As Float
   WSData sRatCTSC1		as array of aRatCTSC1 OPTIONAL
   WsData sProjSC1		as Array of aProjSC1 OPTIONAL
EndWSStruct

/* --------------------------------------------------------------------------------------
WStruct		stSolicitacao
Autor		Wilson Possani de Godoi
Data		27/06/2011
Descricao	Solicitacao Solicitação de Compra
-------------------------------------------------------------------------------------- */
WSStruct stSC1Solicitacao
	WSData sCab			as stCabSC1
	WSData sCor			as array of stCorSC1
EndWSStruct

/* --------------------------------------------------------------------------------------
WStruct		stCabSC1
Autor		Adilson Soeiro de Oliveira
Data		29/03/2010
Descricao	Cabecalho da tabela SC1 (Solicitação de Compra)
-------------------------------------------------------------------------------------- */
WSStruct stC1Del
	WSData cEMPRESA	as String
	WSData cFil			as String
	WsData cID			as String
EndWSStruct

/* --------------------------------------------------------------------------------------
WStruct     aRatCTSC1
Autor       Roney de Oliveira
Data        26/12/2012
Descricao   Campos da tabela SCX (Rateio de centro de custo)
-------------------------------------------------------------------------------------- */
WSStruct aRatCTSC1
   WSData CX_PERC    AS Float  OPTIONAL
   WSData CX_CC      AS STRING OPTIONAL
   WSData CX_CONTA   AS STRING OPTIONAL
   WSData CX_ITEMCTA AS STRING OPTIONAL
   WSData CX_CLVL    AS STRING OPTIONAL
EndWSStruct  

/* --------------------------------------------------------------------------------------
WStruct     aRatCTBPC
Autor       
Data        19/12/2012
Descricao   Campos da tabela AFG (Rateio de projeto/Tarefa)
-------------------------------------------------------------------------------------- */
WsStruct aProjSC1
    WSData cAFG_PROJETO As String
    WSData cAFG_TAREFA  As String
    WSData nAFG_QUANT   As Float
EndWsStruct

/* --------------------------------------------------------------------------------------
WebService	WSMAT110
Autor		Wilson Possani de Godoi
Data		27/06/2011
Descricao	Web Service MATA110 - Solicit.ao de Compras integrado do TOTVS Obras e Projetos
-------------------------------------------------------------------------------------- */
WSService WSMAT110 Description STR0001//"MATA110 - Solicitacao de Compras integrado do TOTVS Obras e Projetos"
    //Declaração de variaveis
	WSData sSolicitacao	as stSC1Solicitacao
	WSData cId		  		as String
	WSData cRet				as String
	WSData SC1Exclui		as stC1Del

	//Declaracaoo de metodos
	WSMethod Inclui			description STR0002//"Inclui uma solicitação de Compras" 
	WSMethod Alterar 			description STR0003//"Altera uma solicitação de Compras"	 
	WSMethod Exclui			description STR0004//"Exclui uma solicitação de Compras" 
ENDWSSERVICE

/*--------------------------------------------------------------------------------------
WSMethod	Inclui
Autor		Wilson Possani de Godoi
Data		27/06/2011
Descricao	Inclui uma solicitacao de Compras
Retorno		.t.
--------------------------------------------------------------------------------------*/
WSMethod Inclui WSReceive sSolicitacao WSSEND cRet WSSERVICE WSMAT110
	Local aCabec		:= {}
	Local aItens		:= {}
	Local aItPrjTmp	:= {}
	Local aItPrj		:= {}
	Local lAuto			:= nil
   Local nI,nJ     := 0
	Local nSize			:= 0
	Local oCabe			:= nil
	Local oCorpo		:= nil
	Local aErro			:= {}
	Local nZ				:= 0
	Local cErro			:= ""
	Local nPos			:= 0
	Local cRetorno 	:= ""
	Local aItensRat    := {} // Rateio é por item da Solicitação
	Local ORatCTSC1    := Nil
	Local ORatPJSC1    := Nil
	Local nColigada:=0
    Local lTOpxTin:=.F.
	Local cCusto:=''
	// Controle de Filial PROTHEUS - 13/05/2010 - Multi Filiais
	// Controle de Filial PROTHEUS - 23/11/2010 - cEmpOOO/cFilOOO - Multi Empresas/Filiais
	Local aArea				:= {}
	Local cFilOOO			:= ""
	Local cEmpOOO			:= ""
	Local lEMPFil			:= .F.
	Local nFim  		   := 0
	Local n110Moeda		:= 0

	PRIVATE lMsErroAuto 	:= .F.  
	Private cCliente		:= ""
	Private cLoja			:= ""
	Private cCepe			:= ""
	Private cEnde			:= ""
	Private cBairroe		:= ""
	Private cMune			:= ""
	Private cEste			:= ""
	Private cNumSCWS		:= ""
	
  
	//UTILIZANDO VARIÁVEL PARA MELHOR VISUALIZAÇÃO DO CÓDIGO
	oCabe		:= ::sSolicitacao:sCab
	oCorpo	:= ::sSolicitacao:sCor

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

    If Empty(oCabe:cEMPRESA) .or. Empty(oCabe:cFIL)
		SetSoapFault( "WSMAT110",STR0005 + STR0022 )// "Solicitacao de Compras nao inclusa.Codigo da Empresa/Filial nao informado (vazio)."
		return .F.
	Endif    

	If Type("cFilAnt") =="U" //retirou o preparein do ini
		If FindFunction("PmsW40Fil")
			cFilOOO := (oCabe:cFIL) 
			cEmpOOO :=	(oCabe:cEMPRESA) 
			lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
		Else //está sem o preparein, e nao vai conseguir setar a filial.
			SetSoapFault( "WSMATA110",STR0037)//"Não foi possível completar esta ação. É necessária uma atualização dos WebServices de integração TOP x Protheus. Entre com contato com o Suporte Totvs."                                                                                                                                                                                                                                                                                                                                                           
			return .F.
		Endif
	Else
		cFilOOO := Padr(Alltrim(oCabe:cFIL)     ,Len(cFilAnt) ) // tamanho da tabela TamSX3("C1_FILIAL")[1]
		cEmpOOO := Padr(Alltrim(oCabe:cEMPRESA) ,Len(cEmpAnt) )                    
		
	 	lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
	 Endif

    If !lEMPFil
		SetSoapFault( "WSMAT110",STR0005 + STR0006 + " " + cEmpOOO + "/" + cFilOOO)//"Solicitacao de Compras nao inclusa. Codigo da Empresa/Filial inexistente ou não autorizada
		return .F.
    Endif
  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento de variavel apos ter definido o ambiente       ³
	//³                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArea	:= GetArea()
	nColigada:=GetNewPar('MV_RMCOLIG',0)
	lTopxTin:=Iif(FindFunction('IntTopTin'),IntTopTin(nColigada),.F.)
	If len( oCorpo ) > LINHAS
		cMSG := STR0007 + " " + CvalToChar(LINHAS) + " " +  STR0008 // "Limite de Itens por solicitação é de " , itens
		ConOut( cMSG )
		SetSoapFault( "WSMAT110",STR0009 + " " + cMSG )//"Solicitacao de Compras cancelada."
		return .F.
	EndIf   
	
   	
	// **********************
	// *******@@@@@**********
	// ******@@**@@@*********
	// **********@@**********
	// *********@@@**********
	// ********@@@***********
	// *******@@@@@@*********
	// **********************

	//CRIANDO CABECALHO
  
	Aadd(aCabec,{"C1_EMISSAO"    ,CtoD(oCabe:dEmissao)    ,Nil })                    //01 - Database do sistema
	Aadd(aCabec,{"C1_SOLICIT"    ,oCabe:cSolic            ,Nil })                    //02 - Solicitante
	
	If ValType(oCabe:cC1_MOEDA) <> "U"					
  	  	n110Moeda := INTSPMOEDA(oCabe:cC1_MOEDA)
	  	If n110Moeda > 0
	  		aAdd( aCabec , {"C1_MOEDA"		, n110Moeda	, Nil } )
	   	Else
	  		SetSoapFault( "WSMATA110", "Moeda: " + oCabe:cC1_MOEDA + " não encontrada" ) 
			Return .F.
	  	Endif
	Endif
	
	//CRIANDO CORPO (SUB - ITENS DO ORCAMENTO TELEVENDAS)  
	
	nSize := len( oCorpo )
	for nI := 1 to nSize
     ORatPJSC1 := oCorpo[nI]:sProjSC1	
		cItem := PadL( Alltrim(oCorpo[nI]:cC1_ITEM), TamSX3("C1_ITEM")[1] ,"0" ) 
		aItensTemp := {}   
		aadd( aItensTemp , {"C1_FILIAL"     , xFilial("SC1")           , NIL } )
		aadd( aItensTemp , {"C1_ITEM" 		, cItem							, Nil } )
		aadd( aItensTemp , {"C1_PRODUTO" 	, oCorpo[nI]:cC1_PRODUTO	, Nil } )
		aadd( aItensTemp , {"C1_UM"  	  		, oCorpo[nI]:cC1_UM			, Nil } )
		aadd( aItensTemp , {"C1_QUANT" 		, Round(oCorpo[nI]:nC1_QUANT, tamSX3("C1_QUANT")[2] )	, Nil } )
		Aadd( aItensTemp , {"C1_SOLICIT"    ,oCabe:cSolic            ,Nil })
		/* 
		18/05/2012 luis.gustavo@totvs.com.br
		Alteração para adequar o calculo automatico da C1_QUANT em funcao da C1_QTSEGUM 
		quando existe no Protheus a C1_SEGUM com o fator de conversao cadastrado
		para o produto.		
		*/
		//aadd( aItensTemp , {"C1_SEGUM" 		, oCorpo[nI]:cC1_SEGUM		, Nil } )
		//aadd( aItensTemp , {"C1_QTSEGUM" 	, oCorpo[nI]:nC1_QTSEGUM	, Nil } )	
		aadd( aItensTemp , {"C1_DATPRF" 		, CtoD(oCorpo[nI]:cC1_DATPRF), Nil } )
		aadd( aItensTemp , {"C1_LOCAL" 		, oCorpo[nI]:cC1_LOCAL		, Nil } )
		aadd( aItensTemp , {"C1_EMISSAO" 	, CtoD(oCabe:dEmissao) 	   , Nil } )
		aadd( aItensTemp , {"C1_DESCRI" 		, oCorpo[nI]:cC1_DESCRI		, Nil } )
		aadd( aItensTemp , {"C1_FILENT"     , xFilial("SC1")           , NIL } )
		aadd( aItensTemp , {"C1_OBS" 		, oCorpo[nI]:cC1_OBS  		, Nil } )
		
		If Len(oCorpo[nI]:sRatCTSC1) = 0
			IF lTopxTin
				cCusto:=IsTopxTin("CTT",(oCorpo[nI]:cC1_CC))
				cCusto:=SubStr(cCusto,TAMSX3('CTT_FILIAL')[1]+1,TAMSX3("CTT_CUSTO")[1])   
				aadd( aItensTemp , {"C1_CC"   		, cCusto			, Nil } )
    		Else
    			aadd( aItensTemp , {"C1_CC"   		, oCorpo[nI]:cC1_CC			, Nil } )
        	Endif
        	aadd( aItensTemp , {"C1_CONTA"      , oCorpo[nI]:cC1_CONTA      , Nil } )
        	aadd( aItensTemp , {"C1_ITEMCTA"    , oCorpo[nI]:cC1_ITEMCTA    , Nil } ) 
    	EndIf
		
		If !Empty(oCorpo[nI]:cC1_TPOP)
		   aadd( aItensTemp , {"C1_TPOP" 		, oCorpo[nI]:cC1_TPOP		, Nil } )
		EndIf
		aadd( aItensTemp , {"C1_CLVL" 		, oCorpo[nI]:cC1_CLVL		, Nil } )
		aadd( aItensTemp , {"C1_VUNIT" 		, oCorpo[nI]:nC1_VUNIT		, Nil } )
		aadd( aItensTemp , {"C1_ALI_WT" 		, oCorpo[nI]:cC1_ALI_WT		, Nil } )
		aadd( aItensTemp , {"C1_REC_WT" 		, oCorpo[nI]:cC1_REC_WT		, Nil } ) 
		aadd( aItensTemp , {"C1_ORIGEM" 		, 'MATA110'						, Nil } ) 		
		aadd( aItensTemp , {"AFG_PROJETO" 	, oCorpo[nI]:cAFG_PROJETO	, Nil } )
		aadd( aItensTemp , {"AFG_TAREFA" 	, oCorpo[nI]:cAFG_TAREFA 	, Nil } )		
		aAdd(aItens, aClone(aItensTemp))             
		
		// Se for informada nova estrutura de rateio por projeto
     nSizePJ    := Len(ORatPJSC1)     
     If nSizePJ > 0
        For nJ := 1 to nSizePJ
           If !Empty(ORatPJSC1[nJ]:cAFG_PROJETO) .And. !Empty(ORatPJSC1[nJ]:cAFG_TAREFA)
              aItPrjTmp := {}
              aadd( aItPrjTmp ,{"AFG_PROJET"      , ORatPJSC1[nJ]:cAFG_PROJETO   , Nil } )
              aadd( aItPrjTmp ,{"AFG_REVISA"      , StrZero(1,TamSX3("AFG_REVISA")[1]), Nil } )
              aadd( aItPrjTmp ,{"AFG_TAREFA"      , ORatPJSC1[nJ]:cAFG_TAREFA    , Nil } )
              aadd( aItPrjTmp ,{"AFG_NUMSC"       , ""                                , Nil } )
              aadd( aItPrjTmp ,{"AFG_ITEMSC"      , cItem                         , Nil } )
              aadd( aItPrjTmp ,{"AFG_COD"         , oCorpo[nI]:cC1_PRODUTO    , Nil } )
              aadd( aItPrjTmp ,{"AFG_QUANT"       , ORatPJSC1[nJ]:nAFG_QUANT      , Nil } ) 
              aAdd(aItPrj ,aClone(aItPrjTmp))
           EndIF            
        Next nJ     
     Else
        // Projetos e Tarefa de onde originou a Solicitação de Compras
        If !Empty(oCorpo[nI]:cAFG_PROJETO) .And. !Empty(oCorpo[nI]:cAFG_TAREFA)
           aItPrjTmp := {}   		
           aadd( aItPrjTmp ,{"AFG_PROJET" 	, oCorpo[nI]:cAFG_PROJETO	, Nil } )
           aadd( aItPrjTmp ,{"AFG_REVISA" 	, StrZero(1,TamSX3("AFG_REVISA")[1]), Nil } )
           aadd( aItPrjTmp ,{"AFG_TAREFA" 	, oCorpo[nI]:cAFG_TAREFA 	, Nil } )
           aadd( aItPrjTmp ,{"AFG_NUMSC" 		, ""					  			, Nil } )
           aadd( aItPrjTmp ,{"AFG_ITEMSC" 	, cItem						 	, Nil } )
           aadd( aItPrjTmp ,{"AFG_COD" 			, oCorpo[nI]:cC1_PRODUTO 	, Nil } )
           aadd( aItPrjTmp ,{"AFG_QUANT" 		, oCorpo[nI]:nC1_QUANT	 	, Nil } )
           aAdd(aItPrj ,aClone(aItPrjTmp))
        EndIf
     EndIF
       		
     If Len(aItPrjTmp) = 0 		
   	  SetSoapFault("WSMAT110", STR0040) //"Projeto e Tarefa são obrigatórios"
        return .F.
     EndIf   	
		
		// Verifica por item se Produto não foi informado
		If Empty(oCorpo[nI]:cC1_PRODUTO)
			SetSoapFault( "WSMAT110",STR0010 + " "  + Alltrim(str(nI)) + " " + STR0011)//"Item:" , " Solicitacao de Compras nao inclusa. Codigo do Produto nao informado (vazio)."
			return .F.
		Endif   

		//Verifica por item se Quantidade não foi Informada	
		If Empty(oCorpo[nI]:nC1_QUANT)
			SetSoapFault( "WSMAT110",STR0010 + " "  + Alltrim(str(nI)) + " " + STR0012)// Item: " Solicitacao de Compras nao inclusa. Quantidade nao Informada (vazio)."
			return .F.
		Endif 
	next
	
   //CRIANDO RATEIO PARA OS ITENS DO PC
   // ESTRUTURA
   // aRatCTBPC[X][1] --> numero do item
   // aRatCTBPC[X][2] --> array contendo a estrutura do rateio da SCX                                                                 
   nSize := len( oCorpo )
   for nI := 1 to nsize
       ORatCTSC1   := oCorpo[nI]:sRatCTSC1
       nSizeRat    := Len(ORatCTSC1)
       If nSizeRat <= 0
           Exit
       EndIf
       cItem := PadL( Alltrim(oCorpo[nI]:cC1_ITEM), TamSX3("C1_ITEM")[1] ,"0" )
       nItensRat   := 0
       
       aADD(aItensRat,Array(2))                       
       aItensRat[nI][1] := cItem
       aItensRat[nI][2] := {}
            
       For nJ := 1 to nSizeRat
           aItensTemp := {}
           nItensRat++
            cCusto:=ORatCTSC1[nJ]:CX_CC
            If lTopxTin
            	cCusto:=IsTopxTin("CTT",(cCusto))
				cCusto:=SubStr(cCusto,TAMSX3('CTT_FILIAL')[1]+1,TAMSX3("CTT_CUSTO")[1]) 
			Endif  	
           // realiza validacoes de centro de custo
           If(!PMSVldCC(cCusto, Ctod(oCabe:dEmissao), "WSMATA110"))                 
               return .F.
           EndIf
            
           aadd( aItensTemp , {"CX_FILIAL"     , xFilial("SCX"),                                                  Nil } ) 
           aadd( aItensTemp , {"CX_SOLICIT"     , "",                                                             Nil } ) // NÃO PRECISA, POIS QUEM TRATA É A A120RATPC() 
           aadd( aItensTemp , {"CX_ITEMSOL"     , cItem,                                                          Nil } ) 
           aadd( aItensTemp , {"CX_ITEM"       , STRZERO(nItensRat,2),                                            Nil } ) // LINHA DO RATEIO
           aadd( aItensTemp , {"CX_PERC"       , ORatCTSC1[nJ]:CX_PERC,                                           Nil } ) // PERCENTUAL
           aadd( aItensTemp , {"CX_CC"         , cCusto,                                             Nil } ) // CENTRO DE CUSTO
           aadd( aItensTemp , {"CX_CONTA"      , iIf(ORatCTSC1[nJ]:CX_CONTA == Nil,"",ORatCTSC1[nJ]:CX_CONTA),     Nil } ) // CONTA CONTABIL
           aadd( aItensTemp , {"CX_ITEMCTA"    , iIf(ORatCTSC1[nJ]:CX_ITEMCTA == Nil,"",ORatCTSC1[nJ]:CX_ITEMCTA), Nil } ) // ITEM CONTABIL
           aadd( aItensTemp , {"CX_CLVL"       , iIf(ORatCTSC1[nJ]:CX_CLVL == Nil,"",ORatCTSC1[nJ]:CX_CLVL),       Nil } ) // CLASSE DE VALOR
           aAdd(aItensRat[nI][2], aClone(aItensTemp))      
       Next nJ        
   next nI

	If Empty(oCabe:dEmissao)
		SetSoapFault( "WSMAT110",STR0013)//"Solicitacao de Compras nao inclusa. Data nao informada (vazio)."
		return .F.
	Endif 
	
	If !AFG->(FieldPos("AFG_VIAINT")) > 0 
		SetSoapFault( "WSMAT110",STR0039)//"Para executar este processo é necessário aplicar o update de base UPDPMS com data igual ou superior a 19/12/2011."  
		return .F.
	Endif

   BeginTran()

	// ponto de entrada inserido para controlar dados especificos do cliente
	If ExistBlock("PWSMT110")
		aRetPe := ExecBlock("PWSMT110",.F.,.F.,{aCabec,aItens,aItensRat,aItPrj})
		If ValType(aRetPe) == "A" .And. Len(aRetPe) >0
			If ValType(aRetPe[1]) == "A"
				aCabec := aClone(aRetPe[1])
			EndIf
			If ValType(aRetPe[2]) == "A" 
				aItens := aClone(aRetPe[2])
			EndIf
			If ValType(aRetPe[3]) == "A" 
				aItensRat := aClone(aRetPe[3])
			EndIf
			If ValType(aRetPe[4]) == "A" 
				aItPrj := aClone(aRetPe[4])
			EndIf
		EndIf
	EndIf
	If !Empty(aCabec) .And. !Empty(aItens)
		conOut(STR0014 + "(" + TIME() + ")")//"EXECUTANDO FUNCAO DE GRAVACAO AUTOMATICA MATA110...
		MSExecAuto({|a,b,c,z| MATA110(a,b,c,,,z)},aCabec,aItens,3,aItensRat)
	else
		return .F.
	endif  
	
	//VERIFICANDO SE HOUVE ERRO AO FECHAR O PEDIDO
	If lMsErroAuto
		DisarmTransaction()

		conOut(STR0015)//" *** ATENCAO *** "
		conOut(STR0016 + DtoC(Date()) + " - " + time())//"     ERRO AO EFETUAR SOLICITACAO - DATA: "
		conOut(STR0017)//"++++++++++ SOLICITACAO DO ERRO ++++++++++"
		conOut(MemoRead(NomeAutoLog()))
		
		//LISTANDO DETALHES DO ERRO
		aErro := GetAutoGRLog()
		For nZ := 1 To Len(aErro)
			cErro += aErro[nZ] + Chr(13)+Chr(10)
		Next nZ
		conOut(cErro)
		conOut("---------------------------------------")  
		
		//LISTANDO DETALHES DO WS
		cErro:= STR0018 //"Verifique !, "       
		nFim:=10
		For nZ := 2 TO nFim
		   If ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) <> ""
  				cErro+= ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) + " "
  			Else            
  				nZ:=10
			Endif
		Next nZ
		SetSoapFault("WSMAT110",STR0018 + CRLF + MemoRead(NomeAutoLog()) )
		return .F.
	Else
		conOut("MATA110" + " " + STR0019 + "(" + TIME() + ")")//EXECUTADO!		
	EndIf
    
	If empty(cNumSCWS)
		cRetorno := GetNumSC1(oCorpo[1]:cC1_ITEM, oCorpo[1]:cC1_PRODUTO, oCorpo[1]:nC1_QUANT, oCorpo[1]:cC1_DATPRF, oCorpo[1]:cC1_LOCAL)
		conOut(STR0036 + cRetorno + ' (MAX)')//"Codigo Solic de Compras :"
	Else
		cRetorno := cNumSCWS 
		conOut(STR0036 + cRetorno + ' (cNumSCWS)')//"Codigo Solic de Compras :"
	EndIf

	If empty(cRetorno)
		SetSoapFault("WSMAT110",STR0020)//"Solicitacao incluida, mas impossivel retornar o codigo. Veja mais detalhes no TotvsConsole.log."
		return .F.
	endIf

	// Gera a amarracao com o projeto
	For nI := 1 to len(aItPrj)
		If (nPos:= aScan(aItPrj[nI],{|x| x[1] == "AFG_NUMSC"}))>0
			aItPrj[nI,nPos,2] := cRetorno 
		EndIf

		If (nPos:= aScan(aItPrj[nI],{|x| x[1] == "AFG_IDPROT"}))>0
			aItPrj[nI,nPos,2] := cRetorno 
		EndIf
	Next nI

	pmsWsSC("3" ,aItPrj)

	EndTran()

   RestArea(aArea)		
   ::cRet := "SC;"+cRetorno

   MsUnlockAll()
Return .T.

/*--------------------------------------------------------------------------------------
WSMethod	Alterar
Autor    	Wilson Possani de Godoi
Data		27/06/2011
Descricao   ALTERA uma Solicitação de compra
Retorno		.t.
--------------------------------------------------------------------------------------*/
WSMethod Alterar WSReceive sSolicitacao WSSEND cRet WSSERVICE WSMAT110

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
   Local cFil_C1	:= ""
   Local cItem		:= ""
   Local nFim     := 0
   Local ORatCTSC1    := Nil
   Local ORatPJSC1    := Nil
   Local aItensRat    := {} // Rateio é por item da Solicitação	
   Local nColigada:=0
   Local lTOpxTin:=.F.
   Local cCusto:=''
	// Controle de Filial PROTHEUS - 13/05/2010 - Multi Filiais
	// Controle de Filial PROTHEUS - 23/11/2010 - cEmpOOO/cFilOOO - Multi Empresas/Filiais
	Local aArea			:= {}
	Local cEmpOOO		:= ""
	Local cFilOOO		:= ""
	Local lEMPFil		:= .F.

	PRIVATE lMsErroAuto := .F.  
	Private cCliente:= ""
	Private cLoja	:= ""
	Private cCepe	:= ""
	Private cEnde	:= ""
	Private cBairroe:= ""
	Private cMune	:= ""
	Private cEste	:= ""
   Private C1_NUM  := ""
	//UTILIZANDO VARIÁVEL PARA MELHOR VISUALIZAÇÃO DO CÓDIGO
	oCabe			:= ::sSolicitacao:sCab
	oCorpo		:= ::sSolicitacao:sCor
                                           

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

	If Type("cFilAnt") =="U" //retirou o preparein do ini
		If FindFunction("PmsW40Fil")
			cFilOOO := (oCabe:cFil) 
			cEmpOOO :=	(oCabe:cEmpresa) 
			lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
		Else //está sem o preparein, e nao vai conseguir setar a filial.
			SetSoapFault( "WSMATA110",STR0037)//"Não foi possível completar esta ação. É necessária uma atualização dos WebServices de integração TOP x Protheus. Entre com contato com o Suporte Totvs."                                                                                                                                                                                                                                                                                                                                                           
			return .F.
		Endif
	Else
		cFilOOO := Padr(Alltrim(oCabe:cFil) 	,Len(cFilAnt) )
		cEmpOOO := Padr(Alltrim(oCabe:cEmpresa),Len(cEmpAnt) )
	
		lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
	Endif

    If !lEMPFil
		SetSoapFault( "WSMAT110",STR0005 + STR0006 )//"Solicitacao de Compra nao incluso.Codigo da Empresa/Filial inexistente ou não autorizada.
		return .F.
    Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento de variavel apos ter definido o ambiente       ³
	//³                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArea		:= GetArea()
	nColigada:=GetNewPar('MV_RMCOLIG',0)
	lTopxtin:=Iif(FindFunction('IntTopTin'),IntTopTin(nColigada),.F.)
    // Define o codigo do login do usuario atraves do "nome do usuario" (MV_SLMCOM)
	cNomeU		:= GETMV("MV_SLMCOMP" ,.F. ,"")
   cUSERNAME	:= cNomeU
   cUSER			:= RetCodUsr()


	// **********************
	// *******@@@@@**********
	// ******@@**@@@*********
	// **********@@**********
	// *********@@@**********
	// ********@@@***********
	// *******@@@@@@*********
	// **********************
    
  	dbselectArea("SC1")
	SC1->(DBSetOrder(1)) 
 	IF !SC1->(DbSeek(xFilial("SC1")+ALLTRIM(oCabe:cNum)))
    	SetSoapFault("WSMAT110",STR0023 + " " +cEmpAnt+"|"+cFilAnt+"|"+xFilial("SC1")+"|"+ALLTRIM(oCabe:cNum))//"Codigo de Solicitacao de compra nao encontrado: "
	   return .F.
	endIf 
	
	//CRIANDO CABECALHO
   cFil 	:= xFilial("SC1") 
	
	Aadd(aCabec,{"C1_EMISSAO"    ,CtoD(oCabe:dEmissao)    ,Nil })                    //01 - Database do sistema
	Aadd(aCabec,{"C1_SOLICIT"    ,oCabe:cSolic            ,Nil })                    //02 - Solicitante
 	AADD(aCabec,{"C1_FILIAL" 	, cFil          , Nil})  
	If "SC;" == SubStr(oCabe:cNum,1,3)
		AADD(aCabec,{"C1_NUM" 		, SubStr(oCabe:cNum,4,TamSX3("C1_NUM")[1])	 , Nil})
	Else
		AADD(aCabec,{"C1_NUM" 		, PADR(oCabe:cNum	,TamSX3("C1_NUM")[1]) , Nil}) 
	Endif

	//CRIANDO CORPO (SUB - ITENS DO ORCAMENTO TELEVENDAS)
	nSize := len( oCorpo )
                                    
	SC1->(dbSetOrder(1))
	for nI := 1 to nSize
     ORatPJSC1 := oCorpo[nI]:sProjSC1
		cItem := PadL( Alltrim(oCorpo[nI]:cC1_ITEM), TamSX3("C1_ITEM")[1] ,"0" ) 

		SC1->(MsSeek(cFil + oCabe:cNum + cItem ))
		aItensTemp := {}                         
		aadd( aItensTemp , {"C1_FILIAL"     , xFilial("SC1")           , NIL } )
		aadd( aItensTemp , {"C1_ITEM" 		, cItem 							, Nil } )
		aadd( aItensTemp , {"C1_PRODUTO" 	, oCorpo[nI]:cC1_PRODUTO	, Nil } )
		aadd( aItensTemp , {"C1_UM"  	  		, oCorpo[nI]:cC1_UM			, Nil } )
		aadd( aItensTemp , {"C1_QUANT" 		, Round(oCorpo[nI]:nC1_QUANT, tamSX3("C1_QUANT")[2] )	, Nil } )
		/* 
		18/05/2012 luis.gustavo@totvs.com.br
		Alteração para adequar o calculo automatico da C1_QUANT em funcao da C1_QTSEGUM 
		quando existe no Protheus a C1_SEGUM com o fator de conversao cadastrado
		para o produto.		
		*/
		//aadd( aItensTemp , {"C1_SEGUM" 		, oCorpo[nI]:cC1_SEGUM		, Nil } )
		//aadd( aItensTemp , {"C1_QTSEGUM" 	, oCorpo[nI]:nC1_QTSEGUM	, Nil } )
		aadd( aItensTemp , {"C1_DATPRF" 		, CtoD(oCorpo[nI]:cC1_DATPRF), Nil } )
		aadd( aItensTemp , {"C1_LOCAL" 		, oCorpo[nI]:cC1_LOCAL		, Nil } )
		aadd( aItensTemp , {"C1_EMISSAO" 	, CtoD(oCabe:dEmissao) 	   , Nil } )
		aadd( aItensTemp , {"C1_DESCRI" 		, oCorpo[nI]:cC1_DESCRI		, Nil } )
		aadd( aItensTemp , {"C1_FILENT"     , xFilial("SC1")           , NIL } )
		aadd( aItensTemp , {"C1_OBS" 		, oCorpo[nI]:cC1_OBS  		, Nil } )
		
		If Len(oCorpo[nI]:sRatCTSC1) = 0
			IF lTopxTin
				cCusto:=IsTopxTin("CTT",(oCorpo[nI]:cC1_CC))
				cCusto:=SubStr(cCusto,TAMSX3('CTT_FILIAL')[1]+1,TAMSX3("CTT_CUSTO")[1])  
  			    aadd( aItensTemp , {"C1_CC"   		, cCusto			, Nil } )
    		Else		  
		  		aadd( aItensTemp , {"C1_CC"   		, oCorpo[nI]:cC1_CC			, Nil } )
		  	Endif
		EndIF
		
		aadd( aItensTemp , {"C1_CONTA" 		, oCorpo[nI]:cC1_CONTA		, Nil } )
		aadd( aItensTemp , {"C1_ITEMCTA" 	, oCorpo[nI]:cC1_ITEMCTA	, Nil } ) 
		If !Empty(oCorpo[nI]:cC1_TPOP)
		   aadd( aItensTemp , {"C1_TPOP" 		, oCorpo[nI]:cC1_TPOP		, Nil } )
		EndIf
		aadd( aItensTemp , {"C1_CLVL" 		, oCorpo[nI]:cC1_CLVL		, Nil } )
		aadd( aItensTemp , {"C1_VUNIT" 		, oCorpo[nI]:nC1_VUNIT		, Nil } )
		aadd( aItensTemp , {"C1_ALI_WT" 		, oCorpo[nI]:cC1_ALI_WT		, Nil } )
		aadd( aItensTemp , {"C1_REC_WT" 		, oCorpo[nI]:cC1_REC_WT		, Nil } ) 
		aadd( aItensTemp , {"C1_ORIGEM" 		, 'MATA110'						, Nil } ) 		
		aadd( aItensTemp , {"AFG_PROJETO" 	, oCorpo[nI]:cAFG_PROJETO	, Nil } )
		aadd( aItensTemp , {"AFG_TAREFA" 	, oCorpo[nI]:cAFG_TAREFA 	, Nil } )		
		aAdd(aItens, aClone(aItensTemp))
	
        // Se for informada nova estrutura de rateio por projeto
     nSizePJ    := Len(ORatPJSC1)     
     If nSizePJ > 0
        For nJ := 1 to nSizePJ
           If !Empty(ORatPJSC1[nJ]:cAFG_PROJETO) .And. !Empty(ORatPJSC1[nJ]:cAFG_TAREFA)
              aItPrjTmp := {}
              aadd( aItPrjTmp ,{"AFG_PROJET"   , ORatPJSC1[nJ]:cAFG_PROJETO   , Nil } )
              aadd( aItPrjTmp ,{"AFG_REVISA"   , StrZero(1,TamSX3("AFG_REVISA")[1]), Nil } )
              aadd( aItPrjTmp ,{"AFG_TAREFA"   , ORatPJSC1[nJ]:cAFG_TAREFA    , Nil } )
              aadd( aItPrjTmp ,{"AFG_NUMSC"    , ""                                , Nil } )
              aadd( aItPrjTmp ,{"AFG_ITEMSC"   , cItem                         , Nil } )
              aadd( aItPrjTmp ,{"AFG_COD"      , oCorpo[nI]:cC1_PRODUTO    , Nil } )
              aadd( aItPrjTmp ,{"AFG_QUANT"    , ORatPJSC1[nJ]:nAFG_QUANT      , Nil } ) 
              aadd( aItPrjTmp , {"AFG_IDPROT"  , ""                                , Nil } )
              aAdd(aItPrj ,aClone(aItPrjTmp))
           EndIF            
        Next nJ     
     Else
        // Projetos e Tarefa de onde originou a Solicitação de Compras
        If !Empty(oCorpo[nI]:cAFG_PROJETO) .And. !Empty(oCorpo[nI]:cAFG_TAREFA)
           aItPrjTmp := {}          
           aadd( aItPrjTmp ,{"AFG_PROJET"   , oCorpo[nI]:cAFG_PROJETO   , Nil } )
           aadd( aItPrjTmp ,{"AFG_REVISA"   , StrZero(1,TamSX3("AFG_REVISA")[1]), Nil } )
           aadd( aItPrjTmp ,{"AFG_TAREFA"   , oCorpo[nI]:cAFG_TAREFA    , Nil } )
           aadd( aItPrjTmp ,{"AFG_NUMSC"    , ""                                , Nil } )
           aadd( aItPrjTmp ,{"AFG_ITEMSC"   , cItem                         , Nil } )
           aadd( aItPrjTmp ,{"AFG_COD"      , oCorpo[nI]:cC1_PRODUTO    , Nil } )
           aadd( aItPrjTmp ,{"AFG_QUANT"    , oCorpo[nI]:nC1_QUANT      , Nil } )
           aadd( aItPrjTmp , {"AFG_IDPROT"  , ""                                , Nil } )
           aAdd(aItPrj ,aClone(aItPrjTmp))
        EndIf
     EndIF
            
     If Len(aItPrj) = 0         
       SetSoapFault( "WSMAT110",STR0040) //""Projeto e Tarefa são obrigatórios"
        return .F.
     EndIf 
		
		/****************************************************** 
       20/12/2012 roney.oliveira@totvs.com.br
       Centro de Custo não mais será obrigatório.     
     ******************************************************/
     /*
		// Verifica se foi informado Centro de Custo
		If Empty(oCorpo[nI]:cC1_CC)
			SetSoapFault( "WSMAT110",STR0010 + " "  + ALLTRIM(STR(nI)) + " " + STR0005 + STR0024 )//Item: " Solicitacao de Compra nao incluso.Centro de Custo nao informada (vazio).
			return .F.
		Endif    
     */

		// Verifica se foi informado Preco
		If Empty(oCorpo[nI]:nC1_VUNIT)
			SetSoapFault( "WSMAT110",STR0010 + " "  + ALLTRIM(STR(nI)) + " " + STR0005 + " " + STR0025 )//"Item: "" Solicitacao de Compra nao incluso.Preco nao informada (vazio).
			return .F.
		Endif		
		
		// Verifica se foi informado Produto.
		If Empty(oCorpo[nI]:cC1_PRODUTO)
			SetSoapFault( "WSMAT110",STR0010 + " "  + ALLTRIM(STR(nI)) + " " + STR0005 + STR0026 )//"Item: "" Solicitacao de Compra nao incluso.Produto nao informada (vazio).
			return .F.
		Endif		
				
		// Verifica se foi informado Quantidade.
		If Empty(oCorpo[nI]:nC1_QUANT)
			SetSoapFault( "WSMAT110",STR0010 + " " +  ALLTRIM(STR(nI)) + " " + STR0005 +  STR0027)//"Item: "" Solicitacao de Compra nao incluso.Quantidade nao informada (vazio)."
			return .F.
		Endif	
				                                               
		// Verifica se foi informado Data de Emissão
		If Empty(Ctod(oCabe:dEmissao))
			SetSoapFault( "WSMAT110",STR0005 + " " + STR0028 )//"Solicitacao de Compra nao incluso.Data de Emissao nao informada (vazio)."
			return .F.
		Endif	
		
	next nI
	
   //CRIANDO RATEIO PARA OS ITENS DO PC
   // ESTRUTURA
   // aRatCTBPC[X][1] --> numero do item
   // aRatCTBPC[X][2] --> array contendo a estrutura do rateio da SCX                                                                 
   nSize := len( oCorpo )
   for nI := 1 to nsize
       ORatCTSC1   := oCorpo[nI]:sRatCTSC1
       nSizeRat    := Len(ORatCTSC1)
       If nSizeRat <= 0
           Exit
       EndIf
       cItem := PadL( Alltrim(oCorpo[nI]:cC1_ITEM), TamSX3("C1_ITEM")[1] ,"0" )
       nItensRat   := 0
        
       aADD(aItensRat,Array(2))                       
       aItensRat[nI][1] := cItem
       aItensRat[nI][2] := {}
            
       For nJ := 1 to nSizeRat
           aItensTemp := {}
           nItensRat++
           cCusto:=ORatCTSC1[nJ]:CX_CC
        	 If lTopxTin
            	cCusto:=IsTopxTin("CTT",(cCusto))
				cCusto:=SubStr(cCusto,TAMSX3('CTT_FILIAL')[1]+1,TAMSX3("CTT_CUSTO")[1]) 
			Endif  	
           // realiza validacoes de centro de custo
           If(!PMSVldCC(cCusto, Ctod(oCabe:dEmissao), "WSMATA110"))                 
               return .F.
           EndIf
            
           aadd( aItensTemp , {"CX_FILIAL"     , xFilial("SCX"),                                                  Nil } ) 
           aadd( aItensTemp , {"CX_SOLICIT"     , "",                                                             Nil } ) // NÃO PRECISA, POIS QUEM TRATA É A A120RATPC() 
           aadd( aItensTemp , {"CX_ITEMSOL"     , cItem,                                                          Nil } ) 
           aadd( aItensTemp , {"CX_ITEM"       , STRZERO(nItensRat,2),                                            Nil } ) // LINHA DO RATEIO
           aadd( aItensTemp , {"CX_PERC"       , ORatCTSC1[nJ]:CX_PERC,                                           Nil } ) // PERCENTUAL
           aadd( aItensTemp , {"CX_CC"         , cCusto,					                                          Nil } ) // CENTRO DE CUSTO
           aadd( aItensTemp , {"CX_CONTA"      , iIf(ORatCTSC1[nJ]:CX_CONTA == Nil,"",ORatCTSC1[nJ]:CX_CONTA),     Nil } ) // CONTA CONTABIL
           aadd( aItensTemp , {"CX_ITEMCTA"    , iIf(ORatCTSC1[nJ]:CX_ITEMCTA == Nil,"",ORatCTSC1[nJ]:CX_ITEMCTA), Nil } ) // ITEM CONTABIL
           aadd( aItensTemp , {"CX_CLVL"       , iIf(ORatCTSC1[nJ]:CX_CLVL == Nil,"",ORatCTSC1[nJ]:CX_CLVL),       Nil } ) // CLASSE DE VALOR
           aAdd(aItensRat[nI][2], aClone(aItensTemp))      
       Next nJ        
   next nI

	CONOUT(STR0014 + "(" + TIME() + ")")//"EXECUTANDO FUNCAO DE GRAVACAO AUTOMATICA MATA110... 
   MSExecAuto({|a,b,c,z| MATA110(a,b,c,,,z)},aCabec,aItens,4,aItensRat)
	
	//VERIFICANDO SE HOUVE ERRO AO FECHAR O PEDIDO

	If lMsErroAuto
		CONOUT(STR0015)//" *** ATENCAO *** "
		conout(STR0019 + " " +  DtoC(Date()) + " - " + time())//"     ERRO AO EFETUAR SOLICITACAO - DATA: "
		CONOUT(STR0017)//"++++++++++ SOLICITACAO DO ERRO ++++++++++"
		conout(MemoRead(NomeAutoLog()))

		//LISTANDO DETALHES DO ERRO
		aErro := GetAutoGRLog()
		For nZ := 1 To Len(aErro)
			cErro += aErro[nZ] + Chr(13)+Chr(10)
		Next nZ
		conout(cErro)
		CONOUT("---------------------------------------")   
		
		//LISTANDO DETALHES DO WS
		cErro:= STR0018 //"Verifique !, "       
		nFim:=10
		For nZ := 2 TO nFim
		   If ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) <> ""
  				cErro+= ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) + " "
  			Else            
  				nZ:=10
			Endif
		Next nZ
		SetSoapFault("WSMAT110",STR0018 + CRLF + MemoRead(NomeAutoLog()) )
		return .F.
	Else
		conout("MATA110" + " " + STR0019 +  "(" + TIME() + ")")// EXECUTADO! 
	EndIf
	

	cRetorno 	:= oCabe:cNum
	
	//
	// Gera a amarracao com o projeto
	//
	For nI := 1 to len(aItPrj)
		If (nPos:= aScan(aItPrj[nI],{|x| x[1] == "AFG_NUMSC"}))>0
			aItPrj[nI,nPos,2] := cRetorno 
		EndIf

	Next nI
	
	PMSWsSC("4" ,aItPrj )    
	
	::cRet := STR0029 + " "  +"SC;"+oCabe:cNum + " " +  STR0030 //"Solicitacao de Compra " "Alterada com sucesso."
	
RestArea(aArea)		
	
Return .T.

/*--------------------------------------------------------------------------------------
WSMethod	Exclui
Autor		Wilson Possani de Godoi
Data		27/06/2011
Descricao	Exclui uma solicitacao de Compras
Retorno		.t.
--------------------------------------------------------------------------------------*/
WSMethod Exclui WSReceive SC1Exclui WSSEND cRet WSSERVICE WSMAT110

	Local aCabec		:= {}
	Local aItens		:= {}
	Local aItensTemp	:= {}
	Local aItPrjTmp		:= {}
	Local aItPrj		:= {}
	Local lAuto			:= nil
	Local aErro			:= {}
	Local nZ			:= 0
	Local cErro			:= ""

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

    If Empty(::SC1Exclui:cEMPRESA) .Or. Empty(::SC1Exclui:cFil)
		SetSoapFault( "WSMAT110",STR0021 + STR0022 )// "Solicitacao de Compras nao excluida.Codigo da Empresa/Filial nao informado (vazio)."
		return .F.
	Endif    

	If Type("cFilAnt") =="U" //retirou o preparein do ini
		If FindFunction("PmsW40Fil")
			cFilOOO := (::SC1Exclui:cFil) 
			cEmpOOO :=	(::SC1Exclui:cEMPRESA) 
			lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
		Else //está sem o preparein, e nao vai conseguir setar a filial.
			SetSoapFault( "WSMATA110",STR0037)//"Não foi possível completar esta ação. É necessária uma atualização dos WebServices de integração TOP x Protheus. Entre com contato com o Suporte Totvs."                                                                                                                                                                                                                                                                                                                                                           
			return .F.
		Endif
	Else
		cFilOOO := Padr( Alltrim(::SC1Exclui:cFil)     ,Len(cFilAnt) ) // tamanho da tabela TamSX3("C1_FILIAL")[1]
		cEmpOOO := Padr( Alltrim(::SC1Exclui:cEMPRESA) ,Len(cEmpAnt) )
	
		lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
	Endif
    If !lEMPFil
		SetSoapFault( "WSMAT110",STR0021 + STR0006)//"Solicitacao de Compras nao excluida. Codigo da Empresa/Filial inexistente ou não autorizada."
		return .F.
    Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento de variavel apos ter definido o ambiente       ³
	//³                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArea	:= GetArea()
	

	//VALIDACAO DO CODIGO
	 cId	:=  Alltrim(::SC1Exclui:cID)

    conOut( cId, len(cId) )
	If "SC;" == SubStr(cId,1,3)
		cId:= SubStr(cId,4,TamSX3("C1_NUM")[1])
	Else
		cId	:= PADR( Alltrim(::SC1Exclui:cID), TamSX3("C1_NUM")[1] )
	Endif

	// **********************
	// *******@@@@@**********
	// ******@@**@@@*********
	// **********@@**********
	// *********@@@**********
	// ********@@@***********
	// *******@@@@@@*********
	// **********************

	dbSelectArea("SC1")
	dbSetOrder(1)
    If !dbSeek(xFilial("SC1")+ cId)
      cErro:=""
		ConOut(STR0023)//"Codigo Solicitacao de Compras nao encontrado."
		cErro:= STR0023 + " " + "SC"+cId  //"Codigo Solicitacao de Compras nao encontrado."
		SetSoapFault("WSMAT110",cErro)
		return .F.
	endIf		


	//CRIANDO CABECALHO                                 
	AADD(aCabec,{"C1_FILIAL" 	, cFilAnt       , Nil})  
	AADD(aCabec,{"C1_NUM" 		, cId			    , Nil})  

	//CARREGANDO CORPO (SUB - ITENS DO ORCAMENTO TELEVENDAS)
	While (SC1->(!Eof() .And. SC1->C1_FILIAL+SC1->C1_NUM == cFilAnt+cId))
		aItensTemp := {}
		aadd( aItensTemp , {"C1_FILIAL" 		, SC1->C1_FILIAL	, Nil } )		
		aadd( aItensTemp , {"C1_ITEM" 		, SC1->C1_ITEM		, Nil } )
		aAdd(aItens, aClone(aItensTemp))
		
		aItPrjTmp := {}
		aadd( aItPrjTmp ,{"AFG_FILIAL" 		, SC1->C1_FILIAL	, Nil } )
		aadd( aItPrjTmp ,{"AFG_NUMSC" 		, cId			 	 	, Nil } )
		aadd( aItPrjTmp ,{"AFG_ITEMSC" 		, SC1->C1_ITEM	 	, Nil } )
		aAdd(aItPrj ,aClone(aItPrjTmp))
		
		SC1->(DbSkip())	
	End


	conOut(STR0031 + " "  + "(" + TIME() + ")")//"EXECUTANDO FUNCAO DE EXCLUSAO AUTOMATICA MATA110...

	dbSeek(xFilial("SC1") + cId)
	MsExecAuto({|a,b,c| MATA110(a,b,c) },aCabec,aItens,5) 

	//VERIFICANDO SE HOUVE ERRO AO FECHAR O PEDIDO
	If lMsErroAuto

		conOut(STR0015)//" *** ATENCAO *** "
		conOut(STR0016 + " " + DtoC(Date()) + " - " + time())//"     ERRO AO EFETUAR SOLICITACAO - DATA: " 
		conOut(STR0017)//"++++++++++ SOLICITACAO DO ERRO ++++++++++"
		conOut(MemoRead(NomeAutoLog()))
		
		//LISTANDO DETALHES DO ERRO
		aErro := GetAutoGRLog()
		cErro:=""
		For nZ := 1 To Len(aErro)
			cErro += aErro[nZ] + Chr(13)+Chr(10)
		Next nZ
		conOut(cErro)
		conOut("---------------------------------------")
		
		//LISTANDO DETALHES DO WS
		cErro:=STR0018 //"Verifique !, "       
		nFim:=10
		For nZ := 2 TO nFim
		   If ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) <> ""
  				cErro+= ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) + " "
  			Else            
  				nZ:=10
			Endif
		Next nZ
		SetSoapFault("WSMAT110",STR0018 + CRLF + MemoRead(NomeAutoLog()) )
		return .F.
	Else
		conOut("MATA110" + " " + STR0019 +  "(" + TIME() + ")")//EXECUTADO! 
	EndIf

	// Exclui a associacao com o projeto
	pmsWsSC("5" ,aItPrj )

	::cRet := STR0029 + " "  +"SC;"+cId + " " + STR0032//"Solicitacao de Compra " , " Excluida com sucesso."

RestArea(aArea)		

Return .T.

/* --------------------------------------------------------------------------------------
Funcao		GetNumSC1
Autor		Wilson Possani de Godoi
Data		27/06/2011
Descricao	Retorna ultimo codigo do SC1 de um determinado cliente
-------------------------------------------------------------------------------------- */
Static Function GetNumSC1(cC1_ITEM, cC1_PRODUTO, nC1_QUANT, cC1_DATPRF, cC1_LOCAL)

	Local cQuery:= ""
	Local cRet	:= ""

   cQuery:= "SELECT MAX(C1_NUM) C1_NUM "
	cQuery += " FROM " + retSqlName("SC1")    
  	cQuery += " WHERE C1_FILIAL = '" + xFilial("SC1") + "' "
	cQuery += " AND D_E_L_E_T_ = ' ' "    
	
	cQuery := ChangeQuery( cQuery )
	
	If SELECT("WS_GETNUMSC1") > 0
		WS_GETNUMSC1->(dbCloseArea())
	EndIf

	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), "WS_GETNUMSC1", .T., .T. )

	dbSelectArea("WS_GETNUMSC1")

	If WS_GETNUMSC1->(Eof())
		WS_GETNUMSC1->(dbCloseArea())
		cRet := STR0033 //"Codigo NumSC nao encontrado - pesquisa: "
		cRet += cC1_ITEM    + " - "
		cRet += cC1_PRODUTO + " - "
		cRet += AllTrim(Str(nC1_QUANT,19,2)) + " - "
		cRet += cC1_DATPRF  + " - "
		cRet += cC1_LOCAL   + " - "
		cRet += "(" + STR0034 + " "  + cEmpAnt + ", "//Empresa "
		cRet += STR0035+ " "    + cFilAnt + ")"//"Filial "

		conout(cRet)
		return ""
	Endif

	cRet := WS_GETNUMSC1->C1_NUM
	conOut( STR0036 + cRet)//"Codigo Solic de Compras :"

	WS_GETNUMSC1->(dbCloseArea())

Return cRet

User Function NOTHING5; Return  // "dummy" function - Internal Use