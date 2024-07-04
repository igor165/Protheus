#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.ch"
#INCLUDE "pmswmt105.ch"
#DEFINE LINHAS 999

#DEFINE _EOL chr(13) + chr(10)

/* --------------------------------------------------------------------------------------
WStruct		stCabSCP
Autor		Edvin Markstein Zimmermann
Data		24/03/2010
Descricao	Cabecalho da tabela SCP (Solicitacao Armazem)
-------------------------------------------------------------------------------------- */
WSStruct stCabSCP
	WSData cFil		 as String
	WSData cCod		 as String
	WSData dData	 as Date
	WSData cSolic	 as String
	WSData cEMPRESA as String
EndWSStruct

/* --------------------------------------------------------------------------------------
WStruct		stCorpoSCP
Autor		Edvin Markstein Zimmermann
Data		24/03/2010
Descricao	Corpo da tabela SCP (Solicitacao Armazem)
-------------------------------------------------------------------------------------- */
WSStruct stCorSCP
	WSData cCP_ITEM		As String
	WSData cCP_PRODUTO	As String
	WSData cCP_UM			As String
	WSData nCP_QUANT		As Float
	WSData cCP_SEGUM		As String
	WSData nCP_QTSEGUM	As Float
	WSData cCP_DATPRF		As String
	WSData cCP_LOCAL		As String
	WSData cCP_OBS			As String
	WSData cCP_OP			As String
	WSData cCP_CC			As String   OPTIONAL
	WSData cCP_CONTA		As String OPTIONAL
	WSData cCP_DESCRI		As String
	WSData cCP_SEQRC		As String
	WSData cCP_ITEMCTA	As String OPTIONAL
	WSData cCP_CLVL		As String OPTIONAL
	WSData cAFH_PROJETO	As String OPTIONAL
	WSData cAFH_TAREFA	As String OPTIONAL
	WSData nCP_SALBLQ		As Float
	WSData cCP_ALI_WT		As String
	WSData cCP_REC_WT		As String
	WsData sProjSCP			As Array of aProjSCP OPTIONAL
	WSData sRatCTSCP		As array of aRatCTCP OPTIONAL
EndWSStruct


/* --------------------------------------------------------------------------------------
WStruct		stSolicitacao
Autor		Edvin Markstein Zimmermann
Data		24/03/2010
Descricao	Solicitacao Armazem
-------------------------------------------------------------------------------------- */
WSStruct stSolicitacao
	WSData sCab			as stCabSCP
	WSData sCor			as array of stCorSCP
EndWSStruct

/* --------------------------------------------------------------------------------------
WStruct		stCabSC7
Autor		Adilson Soeiro de Oliveira
Data		29/03/2010
Descricao	Cabecalho da tabela SC7 (Pedido de Compra)
-------------------------------------------------------------------------------------- */
WSStruct stCPDel
	WSData cFil			as String
	WsData cID			as String
	WSData cEMPRESA	as String
EndWSStruct

/* --------------------------------------------------------------------------------------
WStruct		aProjSCP
Autor		Roney de Oliveira
Data		26/12/2012
Descricao	Campos da tabela AFH (Rateio de projeto/Tarefa)
-------------------------------------------------------------------------------------- */
WsStruct aProjSCP
	WSData cAFH_PROJETO	As String
	WSData cAFH_TAREFA	As String
	WSData nAFH_QUANT	As Float
EndWsStruct

/* --------------------------------------------------------------------------------------
WStruct		aRatCTCP
Autor		Mateus Gustavo de Freitas e Silva
Data		19/06/2013
Descricao	Campos da tabela SGS (Rateio de centro de custo)
-------------------------------------------------------------------------------------- */
WSStruct aRatCTCP
	WSData GS_PERC		AS Float  OPTIONAL
   WSData GS_CC       	AS String OPTIONAL
	WSData GS_CONTA		AS String
	WSData GS_ITEMCTA	AS String
	WSData GS_CLVL		AS String
EndWSStruct

/* --------------------------------------------------------------------------------------
WebService	WSMATA105
Autor		Edvin Markstein Zimmermann
Data		24/03/2010
Descricao	Web Service MATA105 - Solicit.ao Armazem integrado do TOTVS Obras e Projetos
-------------------------------------------------------------------------------------- */
WSService WSMATA105 Description STR0001//"MATA105 - Solicit.ao Armazem integrado do TOTVS Obras e Projetos"

    //Declaração de variaveis
	WSData sSolicitacao	as stSolicitacao
	WSData cId		  		as String
	WSData cRet				as String
	WSData sCPExclui		as stCPDel

	//Declaracaoo de metodos
	WSMethod Inclui			description STR0002//"Inclui uma solicitação de armazem"
	WSMethod Exclui			description STR0003//"Exclui uma solicitação de armazem"

ENDWSSERVICE

/*--------------------------------------------------------------------------------------
WSMethod	Inclui
Autor		Edvin Markstein Zimmermann
Data		20/03/2010
Descricao	Inclui uma solicitacao de armazem
Retorno		.t.
--------------------------------------------------------------------------------------*/
WSMethod Inclui WSReceive sSolicitacao WSSEND cRet WSSERVICE WSMATA105
	Local aCabec		:= {}
	Local aItens		:= {}
	Local aItPrjTmp		:= {}
	Local aItPrj		:= {}
	Local aRetPe		:= {}
	Local lAuto			:= nil
	Local nI, nJ			:= 0
	Local nSize			:= 0
	Local oCabe			:= nil
	Local oCorpo		:= nil
	Local aErro			:= {}
	Local nZ			:= 0
	Local cErro			:= ""
	Local nPos			:= 0
	Local cRetorno 		:= ""
	Local oRatCTCP		:= Nil
	Local nSizeCT		:= 0
	Local nItensRat		:= 1
	Local cItem			:= ""

	// Controle de Filial PROTHEUS - 13/05/2010 - Multi Filiais
	// Controle de Filial PROTHEUS - 23/11/2010 - cEmpOOO/cFilOOO - Multi Empresas/Filiais
	Local aArea				:= {}
	Local cFilOOO			:= ""
	Local cEmpOOO			:= ""
	Local lEMPFil			:= .F.
	Local nFim  		   := 0
	Local ORatPJSCP    := Nil
	Local nColigada:=	0
    Local lTOpxTin:=.F.
	Local cCusto:=''
	Local aItensRat    := {} // Rateio é por item da Solicitação
	Local nCpQuant := 0  //Quantidade Informada para solicitação
	Local nQuantInf := 0 //Quantidades informadas no rateio do Projeto
	
	PRIVATE lMsErroAuto 	:= .F.
	Private cCliente		:= ""
	Private cLoja			:= ""
	Private cCepe			:= ""
	Private cEnde			:= ""
	Private cBairroe		:= ""
	Private cMune			:= ""
	Private cEste			:= ""
	Private cNumSAWS		:= ""

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
		SetSoapFault( "WSMATA105",STR0004 +  STR0005)//Solicitacao de armazem nao inclusa.Codigo da Empresa/Filial nao informado (vazio)
		return .F.
	Endif


	If Type("cFilAnt") =="U" //retirou o preparein do ini
		If FindFunction("PmsW40Fil")
			cFilOOO := (oCabe:cFIL)
			cEmpOOO :=	(oCabe:cEMPRESA)
			lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
		Else //está sem o preparein, e nao vai conseguir setar a filial.
			SetSoapFault( "WSMATA105",STR0030)//Não foi possível completar esta ação. É necessária uma atualização dos WebServices de integração TOP x Protheus. Entre com contato com o Suporte Totvs."
			return .F.
		Endif
	Else
		cFilOOO := Padr(Alltrim(oCabe:cFIL)     ,Len(cFilAnt) ) // tamanho da tabela TamSX3("CP_FILIAL")[1]
		cEmpOOO := Padr(Alltrim(oCabe:cEMPRESA) ,Len(cEmpAnt) )

		lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
	Endif

    If !lEMPFil
		SetSoapFault( "WSMATA105",STR0004 +  STR0006)//Solicitacao de armazem nao inclusa.Codigo da Empresa/Filial inexistente ou não autorizada.
		return .F.
    Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento de variavel apos ter definido o ambiente       ³
	//³                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nColigada:=GetNewPar('MV_RMCOLIG',0)
	lTopxTin:=Iif(FindFunction('IntTopTin'),IntTopTin(nColigada),.F.)
	aArea	:= GetArea()

	If len( oCorpo ) > LINHAS
		cMSG := STR0007 + CvalToChar(LINHAS) + STR0008  //"Limite de Itens por solicitação é de ", " Itens "
		ConOut( cMSG )
		SetSoapFault( "WSMATA105",STR0009 + cMSG ) //"Solicitacao de armazem cancelada. "
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
	AADD(aCabec,{"CP_ITEM" 		, ""			    , Nil})
	AADD(aCabec,{"CP_PRODUTO" 	, ""			    , Nil})
	AADD(aCabec,{"CP_UM"  		, ""			    , Nil})
	AADD(aCabec,{"CP_QUANT" 	, ""			    , Nil})
	AADD(aCabec,{"CP_SEGUM" 	, ""			    , Nil})
	AADD(aCabec,{"CP_QTSEGUM" 	, ""			    , Nil})
	AADD(aCabec,{"CP_DATPRF" 	, ""			    , Nil})
	AADD(aCabec,{"CP_LOCAL" 	, ""			    , Nil})
	AADD(aCabec,{"CP_OBS" 		, ""			    , Nil})
	AADD(aCabec,{"CP_OP"   		, ""			    , Nil})
	AADD(aCabec,{"CP_CC"   		, ""			    , Nil})
	AADD(aCabec,{"CP_CONTA" 	, ""			    , Nil})
	AADD(aCabec,{"CP_DESCRI" 	, ""			    , Nil})
	AADD(aCabec,{"CP_SEQRC" 	, ""			    , Nil})
	AADD(aCabec,{"CP_ITEMCTA" 	, ""			    , Nil})
	AADD(aCabec,{"CP_CLVL" 		, ""			    , Nil})
	AADD(aCabec,{"CP_SALBLQ" 	, ""			    , Nil})
	AADD(aCabec,{"CP_ALI_WT" 	, ""			    , Nil})
	AADD(aCabec,{"CP_REC_WT" 	, ""			    , Nil})
	AADD(aCabec,{"CP_SOLICIT" 	, oCabe:cSolic	    , Nil})


	//CRIANDO CORPO (SUB - ITENS DO ORCAMENTO TELEVENDAS)
	nSize := len( oCorpo )
	for nI := 1 to nSize
	   ORatPJSCP := oCorpo[nI]:sProjSCP
		aItensTemp := {}
		aadd( aItensTemp , {"CP_ITEM" 		, oCorpo[nI]:cCP_ITEM									, Nil } )
		aadd( aItensTemp , {"CP_PRODUTO" 	, oCorpo[nI]:cCP_PRODUTO								, Nil } )
		aadd( aItensTemp , {"CP_UM"  		, oCorpo[nI]:cCP_UM										, Nil } )
		aadd( aItensTemp , {"CP_QUANT" 		, Round(oCorpo[nI]:nCP_QUANT, tamSX3("CP_QUANT")[2] )	, Nil } )
		aadd( aItensTemp , {"CP_SEGUM" 		, oCorpo[nI]:cCP_SEGUM									, Nil } )
		aadd( aItensTemp , {"CP_QTSEGUM" 	, oCorpo[nI]:nCP_QTSEGUM								, Nil } )
		aadd( aItensTemp , {"CP_DATPRF" 	, CtoD(oCorpo[nI]:cCP_DATPRF)							, Nil } )
		aadd( aItensTemp , {"CP_LOCAL" 		, oCorpo[nI]:cCP_LOCAL									, Nil } )
		aadd( aItensTemp , {"CP_OBS" 		, oCorpo[nI]:cCP_OBS   									, Nil } )
		aadd( aItensTemp , {"CP_OP"   		, oCorpo[nI]:cCP_OP 									, Nil } )
		//Verifica se houve rateio de CC
		If Len(oCorpo[nI]:sRatCTSCP) == 0
			IF lTopxTin//integraçaõ tin x top procedure ligada
				cCusto:=IsTopxTin("CTT",(oCorpo[nI]:cCP_CC))
				cCusto:=SubStr(cCusto,TAMSX3('CTT_FILIAL')[1]+1,TAMSX3("CTT_CUSTO")[1])
				aadd( aItensTemp , {"CP_CC"   		, cCusto		, Nil } )
			Else
				aadd( aItensTemp , {"CP_CC"   		, oCorpo[nI]:cCP_CC			, Nil } )
			Endif

			aadd( aItensTemp , {"CP_CONTA" 		, oCorpo[nI]:cCP_CONTA		, Nil } )
			aadd( aItensTemp , {"CP_ITEMCTA" 	, oCorpo[nI]:cCP_ITEMCTA	, Nil } )
			aadd( aItensTemp , {"CP_CLVL" 		, oCorpo[nI]:cCP_CLVL		, Nil } )

			// realiza validacoes de centro de custo
			If !PMSVldCC(cCusto, oCabe:dData, "WSMATA105")
				return .F.
			EndIf
		Else
		   aadd( aItensTemp , {"CP_RATEIO", "1", Nil } )
		EndIf

		aadd( aItensTemp , {"CP_DESCRI" 	, oCorpo[nI]:cCP_DESCRI		, Nil } )
		aadd( aItensTemp , {"CP_SEQRC" 		, oCorpo[nI]:cCP_SEQRC		, Nil } )
		aadd( aItensTemp , {"CP_SALBLQ" 	, oCorpo[nI]:nCP_SALBLQ		, Nil } )
		aadd( aItensTemp , {"CP_ALI_WT" 	, oCorpo[nI]:cCP_ALI_WT		, Nil } )
		aadd( aItensTemp , {"CP_REC_WT" 	, oCorpo[nI]:cCP_REC_WT		, Nil } )
		aadd( aItensTemp , {"AFH_PROJETO" 	, oCorpo[nI]:cAFH_PROJETO	, Nil } )
		aadd( aItensTemp , {"AFH_TAREFA" 	, oCorpo[nI]:cAFH_TAREFA 	, Nil } )
		aAdd(aItens, aClone(aItensTemp))

		//Roney de Oliveira - 26/12/2012
		// Se for informada nova estrutura de rateio por projeto
		nSizePJ := Len(ORatPJSCP)
		nCpQuant := oCorpo[nI]:nCP_QUANT
		nQuantInf := 0
		If nSizePJ > 0
			For nJ := 1 to nSizePJ
				If !Empty(ORatPJSCP[nJ]:cAFH_PROJETO) .And. !Empty(ORatPJSCP[nJ]:cAFH_TAREFA)
					aItPrjTmp := {}
					aadd(aItPrjTmp, {"AFH_PROJET", ORatPJSCP[nJ]:cAFH_PROJETO,         Nil})
					aadd(aItPrjTmp, {"AFH_REVISA", StrZero(1,TamSX3("AFH_REVISA")[1]), Nil})
					aadd(aItPrjTmp, {"AFH_TAREFA", ORatPJSCP[nJ]:cAFH_TAREFA,          Nil})
					aadd(aItPrjTmp, {"AFH_NUMSA",  "",                                 Nil})
					aadd(aItPrjTmp, {"AFH_ITEMSA", oCorpo[nI]:cCP_ITEM,                Nil})
					aadd(aItPrjTmp, {"AFH_COD",    oCorpo[nI]:cCP_PRODUTO,             Nil})
					aadd(aItPrjTmp, {"AFH_QUANT",  ORatPJSCP[nJ]:nAFH_QUANT,           Nil})
					aAdd(aItPrj, aClone(aItPrjTmp))
					nQuantInf += ORatPJSCP[nJ]:nAFH_QUANT
				EndIF
			Next nJ
		Else
			// Projetos e Tarefa de onde originou a Solicitação de Compras
			If !Empty(oCorpo[nI]:cAFH_PROJETO) .And. !Empty(oCorpo[nI]:cAFH_TAREFA)
				aItPrjTmp := {}
				aadd(aItPrjTmp, {"AFH_PROJET", oCorpo[nI]:cAFH_PROJETO,            Nil})
				aadd(aItPrjTmp, {"AFH_REVISA", StrZero(1,TamSX3("AFH_REVISA")[1]), Nil})
				aadd(aItPrjTmp, {"AFH_TAREFA", oCorpo[nI]:cAFH_TAREFA,             Nil})
				aadd(aItPrjTmp, {"AFH_NUMSA",  "",                                 Nil})
				aadd(aItPrjTmp, {"AFH_ITEMSA", oCorpo[nI]:cCP_ITEM,                Nil})
				aadd(aItPrjTmp, {"AFH_COD",    oCorpo[nI]:cCP_PRODUTO,             Nil})
				aadd(aItPrjTmp, {"AFH_QUANT",  oCorpo[nI]:nCP_QUANT,               Nil})
				aAdd(aItPrj, aClone(aItPrjTmp))
				nQuantInf := oCorpo[nI]:nCP_QUANT
			EndIf
		EndIF
		
		//Valida Quantidades informadas na SA e para rateio Projeto
		If nCpQuant <> nQuantInf			
			cMSG := STR0033 + CvalToChar(nCpQuant) + STR0034 + CvalToChar(nQuantInf)  //"Quantidade Informada na SA " , " diferente da informada para rateio do Projeto "
			ConOut( cMSG )
			SetSoapFault( "WSMATA105",STR0009 + cMSG ) //"Solicitacao de armazem cancelada. "
			return .F.
		EndIf

		// Mateus Gustavo de Freitas e Silva - 19/06/2013
		// Se for informada nova estrutura de rateio por centro de custo
		cItem := PadL(Alltrim(oCorpo[nI]:cCP_ITEM), TamSX3("CP_ITEM")[1], "0")
		oRatCTCP := oCorpo[nI]:sRatCTSCP
		nSizeCT := Len(oRatCTCP)
		
		If nSizeCT > 0
			nItensRat   := 0
	       aADD(aItensRat,Array(2))                       
	       aItensRat[nI][1] := cItem
	       aItensRat[nI][2] := {}		
	       	
			For nJ := 1 to nSizeCT
				aItensTemp := {}
				nItensRat++
				cCusto := oRatCTCP[nJ]:GS_CC				

				If lTopxTin
					cCusto := IsTopxTin("CTT",(cCusto))
					cCusto := SubStr(cCusto, TamSX3('CTT_FILIAL')[1] + 1, TamSX3("CTT_CUSTO")[1])
				EndIf
				
				// realiza validacoes de centro de custo
				If !PMSVldCC(cCusto, oCabe:dData, "WSMATA110")				
					return .F.
				EndIf				

				aadd(aItensTemp, {"GS_FILIAL",  xFilial("SGS"),                                                   Nil})
				aadd(aItensTemp, {"GS_SOLICIT", "",                                                               Nil})
				aadd(aItensTemp, {"GS_ITEMSOL", cItem,                                                            Nil})
				aadd(aItensTemp, {"GS_ITEM",    StrZero(nItensRat, 2),                                            Nil})
				aadd(aItensTemp, {"GS_PERC",    oRatCTCP[nJ]:GS_PERC,                                             Nil})
				aadd(aItensTemp, {"GS_CC",      cCusto,                                                           Nil})
				aadd(aItensTemp, {"GS_CONTA",   iIf(oRatCTCP[nJ]:GS_CONTA == Nil, "", oRatCTCP[nJ]:GS_CONTA),     Nil})
				aadd(aItensTemp, {"GS_ITEMCTA", iIf(oRatCTCP[nJ]:GS_ITEMCTA == Nil, "", oRatCTCP[nJ]:GS_ITEMCTA), Nil})
				aadd(aItensTemp, {"GS_CLVL",    iIf(oRatCTCP[nJ]:GS_CLVL == Nil, "", oRatCTCP[nJ]:GS_CLVL),       Nil})
				aAdd(aItensRat[nI][2], aClone(aItensTemp))
			Next nSizeCT
		EndIf

		If Len(aItPrj) = 0
			SetSoapFault( "WSMATA105", STR0010 + Alltrim(str(nI)) + STR0004 + STR0032) //"Projeto e/ou Tarefa não informado(s)."
			return .F.
		EndIf

		// Verifica por item se Produto não foi informado
		If Empty(oCorpo[nI]:cCP_PRODUTO)
			SetSoapFault( "WSMATA105",STR0010 + Alltrim(str(nI)) + STR0004 + STR0011)//"Item: ", " Solicitacao de armazem nao inclusa.Codigo da Produto nao informado (vazio).
			return .F.
		Endif

		//Verifica por item se Quantidade não foi Informada
		If Empty(oCorpo[nI]:nCP_QUANT)
			SetSoapFault( "WSMATA105",STR0010 + Alltrim(str(nI)) + STR0004 +  STR0012)//"Item: ", " Solicitacao de armazem nao inclusa.Quantidade nao Informada (vazio).
			return .F.
		Endif

	next

	If Empty(oCabe:dData)
		SetSoapFault( "WSMATA105",STR0004 + STR0013)//  " Solicitacao de armazem nao inclusa.Data nao informada (vazio)."
		return .F.
	Endif
	
	// ponto de entrada inserido para controlar dados especificos do cliente
	If ExistBlock("PWSMT105")
		aRetPe := ExecBlock("PWSMT105",.F.,.F.,{aCabec,aItens})
		If ValType(aRetPe) == "A" .And. Len(aRetPe) >0
			If ValType(aRetPe[1]) == "A"
				aCabec := aClone(aRetPe[1])
			EndIf
			If ValType(aRetPe[2]) == "A" 
				aItens := aClone(aRetPe[2])
			EndIf
		EndIf
	EndIf
	
	BeginTran()

	//EXECUTANDO FUNCAO DE GRAVACAO AUTOMATICA
	conOut(STR0014 + "(" + TIME() + ")")
	MsExecAuto({|a,b,c,d| MATA105(a,b,c,d) },aCabec,aItens,3,aItensRat)

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
		SetSoapFault("WSMATA105",STR0018 + CRLF + MemoRead(NomeAutoLog()) )
		return .F.
	Else
		conOut("MATA105" + " " + STR0019 +  "(" + TIME() + ")")//" EXECUTADO!"
	EndIf

	If empty(cNumSAWS)
		cRetorno := GetNumSCP(oCorpo[1]:cCP_ITEM, oCorpo[1]:cCP_PRODUTO, oCorpo[1]:nCP_QUANT, oCorpo[1]:cCP_DATPRF, oCorpo[1]:cCP_LOCAL)
		conOut(STR0029 + " "  + cNumSAWS + ' (MAX)')//"Codigo Solic Armazem :"
	Else
		cRetorno := cNumSAWS
		conOut(STR0029 + " "  + cNumSAWS + ' (cNumSAWS)')//"Codigo Solic Armazem :"
	EndIf

	If empty(cRetorno)
		SetSoapFault("WSMATA105",STR0020)//"Solicitacao incluida, mas impossivel retornar o codigo. Veja mais detalhes no TotvsConsole.log."
		return .F.
	endIf

	//
	// Gera a amarracao com o projeto
	//
	For nI := 1 to len(aItPrj)
		If (nPos:= aScan(aItPrj[nI],{|x| x[1] == "AFH_NUMSA"}))>0
			aItPrj[nI,nPos,2] := cRetorno
		EndIf
	Next nI

	pmsWsSA("3" ,aItPrj )

	EndTran()

RestArea(aArea)
::cRet := "SA;"+cRetorno
Return .T.

/*--------------------------------------------------------------------------------------
WSMethod	Exclui
Autor		Edvin Markstein Zimmermann
Data		20/03/2010
Descricao	Exclui uma solicitacao de armazem
Retorno		.t.
--------------------------------------------------------------------------------------*/
WSMethod Exclui WSReceive sCPExclui WSSEND cRet WSSERVICE WSMATA105

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

    If Empty(::sCPExclui:cEMPRESA) .Or. Empty(::sCPExclui:cFil)
		SetSoapFault( "WSMATA105",STR0021 + STR0005 )//"Solicitacao Armazem nao excluida.Codigo da Empresa/Filial nao informado (vazio).
		return .F.
	Endif
	If Type("cFilAnt") =="U" //retirou o preparein do ini
		If FindFunction("PmsW40Fil")
			cFilOOO := (::sCPExclui:cFil)
			cEmpOOO :=	(::sCPExclui:cEMPRESA)
			lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
		Else //está sem o preparein, e nao vai conseguir setar a filial.
			SetSoapFault( "WSMATA105",STR0030)//"Não foi possível completar esta ação. É necessária uma atualização dos WebServices de integração TOP x Protheus. Entre com contato com o Suporte Totvs."
			return .F.
		Endif
	Else
		cFilOOO := Padr( Alltrim(::sCPExclui:cFil)     ,Len(cFilAnt) ) // tamanho da tabela TamSX3("CP_FILIAL")[1]
		cEmpOOO := Padr( Alltrim(::sCPExclui:cEMPRESA) ,Len(cEmpAnt) )

		lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
	Endif

    If !lEMPFil
		SetSoapFault( "WSMATA105", STR0021 + STR0006 )//"Solicitacao Armazem nao excluida.Codigo da Empresa/Filial inexistente ou não autorizada.
		return .F.
    Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento de variavel apos ter definido o ambiente       ³
	//³                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArea	:= GetArea()

	//VALIDACAO DO CODIGO
	 cId	:=  Alltrim(::sCPExclui:cID)

    conOut( cId, len(cId) )
	If "SA;" == SubStr(cId,1,3)
		cId:= SubStr(cId,4,TamSX3("CP_NUM")[1])
	Else
		cId	:= PADR( Alltrim(::sCPExclui:cID), TamSX3("CP_NUM")[1] )
	Endif

	// **********************
	// *******@@@@@**********
	// ******@@**@@@*********
	// **********@@**********
	// *********@@@**********
	// ********@@@***********
	// *******@@@@@@*********
	// **********************

	dbSelectArea("SCP")
	dbSetOrder(1)
    If !dbSeek(xFilial("SCP")+ cId)
      cErro:=""
		ConOut(STR0023 + " " + STR0022)//"Codigo Solicitacao Armazem nao encontrado."
		cErro:= STR0023 + " " +  cId + " " + STR0022//"Codigo Solicitacao Armazem nao encontrado."
		SetSoapFault("WSMATA105",cErro)
		return .F.
	endIf


	//CRIANDO CABECALHO
	AADD(aCabec,{"CP_NUM" 		, cId			    , Nil})
	AADD(aCabec,{"CP_ITEM" 		, ""			    , Nil})
	AADD(aCabec,{"CP_PRODUTO" 	, ""			    , Nil})
	AADD(aCabec,{"CP_UM"  		, ""			    , Nil})
	AADD(aCabec,{"CP_QUANT" 	, ""			    , Nil})
	AADD(aCabec,{"CP_SEGUM" 	, ""			    , Nil})
	AADD(aCabec,{"CP_QTSEGUM" 	, ""			    , Nil})
	AADD(aCabec,{"CP_DATPRF" 	, ""			    , Nil})
	AADD(aCabec,{"CP_LOCAL" 	, ""			    , Nil})
	AADD(aCabec,{"CP_OBS" 		, ""			    , Nil})
	AADD(aCabec,{"CP_OP"   		, ""			    , Nil})
	AADD(aCabec,{"CP_CC"   		, ""			    , Nil})
	AADD(aCabec,{"CP_CONTA" 	, ""			    , Nil})
	AADD(aCabec,{"CP_DESCRI" 	, ""			    , Nil})
	AADD(aCabec,{"CP_SEQRC" 	, ""			    , Nil})
	AADD(aCabec,{"CP_ITEMCTA" 	, ""			    , Nil})
	AADD(aCabec,{"CP_CLVL" 		, ""			    , Nil})
	AADD(aCabec,{"CP_PROJETO" 	, ""			    , Nil})
	AADD(aCabec,{"CP_SALBLQ" 	, ""			    , Nil})
	AADD(aCabec,{"CP_ALI_WT" 	, ""			    , Nil})
	AADD(aCabec,{"CP_REC_WT" 	, ""			    , Nil})

	//CARREGANDO CORPO (SUB - ITENS DO ORCAMENTO TELEVENDAS)
	While (SCP->(!Eof() .And. SCP->CP_NUM == cId))
		aItensTemp := {}
		aadd( aItensTemp , {"CP_ITEM" 		, SCP->CP_ITEM		, Nil } )
		aadd( aItensTemp , {"CP_PRODUTO" 	, SCP->CP_PRODUTO	, Nil } )
		aadd( aItensTemp , {"CP_UM"  		, SCP->CP_UM		, Nil } )
		aadd( aItensTemp , {"CP_QUANT" 		, SCP->CP_QUANT		, Nil } )
		aadd( aItensTemp , {"CP_SEGUM" 		, SCP->CP_SEGUM		, Nil } )
		aadd( aItensTemp , {"CP_QTSEGUM" 	, SCP->CP_QTSEGUM	, Nil } )
		aadd( aItensTemp , {"CP_DATPRF" 	, SCP->CP_DATPRF	, Nil } )
		aadd( aItensTemp , {"CP_LOCAL" 		, SCP->CP_LOCAL		, Nil } )
		aadd( aItensTemp , {"CP_OBS" 		, SCP->CP_OBS   	, Nil } )
		aadd( aItensTemp , {"CP_OP"   		, SCP->CP_OP 		, Nil } )
		aadd( aItensTemp , {"CP_CC"   		, SCP->CP_CC		, Nil } )
		aadd( aItensTemp , {"CP_CONTA" 		, SCP->CP_CONTA		, Nil } )
		aadd( aItensTemp , {"CP_DESCRI" 	, SCP->CP_DESCRI	, Nil } )
		aadd( aItensTemp , {"CP_SEQRC" 		, SCP->CP_SEQRC		, Nil } )
		aadd( aItensTemp , {"CP_ITEMCTA" 	, SCP->CP_ITEMCTA	, Nil } )
		aadd( aItensTemp , {"CP_CLVL" 		, SCP->CP_CLVL		, Nil } )
		aadd( aItensTemp , {"CP_SALBLQ" 	, SCP->CP_SALBLQ	, Nil } )
		aadd( aItensTemp , {"CP_ALI_WT" 	, "SCP"				, Nil } )
		aadd( aItensTemp , {"CP_REC_WT" 	, SCP->(Recno())	, Nil } )

		aAdd(aItens, aClone(aItensTemp))

		aItPrjTmp := {}
		aadd( aItPrjTmp ,{"AFH_NUMSA" 		, cId			 	, Nil } )
		aadd( aItPrjTmp ,{"AFH_ITEMSA" 		, SCP->CP_ITEM	 	, Nil } )
		aAdd(aItPrj ,aClone(aItPrjTmp))

		SCP->(DbSkip())
	End


	conOut(STR0024 + "(" + TIME() + ")")//"EXECUTANDO FUNCAO DE EXCLUSAO AUTOMATICA MATA105...

	dbSeek(xFilial("SCP") + cId)
	MsExecAuto({|a,b,c| MATA105(a,b,c) },aCabec,aItens,5)

	//VERIFICANDO SE HOUVE ERRO AO FECHAR O PEDIDO
	If lMsErroAuto

		conOut(STR0015)//" *** ATENCAO *** "
		conOut(STR0016 + DtoC(Date()) + " - " + time())//"     ERRO AO EFETUAR SOLICITACAO - DATA: "
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
		cErro:= STR0018 //"Verifique !, "
		nFim:=10
		For nZ := 2 TO nFim
		   If ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) <> ""
  				cErro+= ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) + " "
  			Else
  				nZ:=10
			Endif
		Next nZ
		SetSoapFault("WSMATA105",STR0018 + CRLF + MemoRead(NomeAutoLog()))
		return .F.
	Else
		conOut("MATA105"+ " " + STR0019 +"(" + TIME() + ")")//EXECUTADO!
	EndIf

	// Exclui a associacao com o projeto
	pmsWsSA("5" ,aItPrj )

	::cRet := STR0025 //"Solicitacao excluida com sucesso."

RestArea(aArea)

Return .T.

/* --------------------------------------------------------------------------------------
Funcao		GetNumSCP
Autor		Edvin Markstein Zimmermann
Data		29/03/2010
Descricao	Retorna ultimo codigo do SCP de um determinado cliente
-------------------------------------------------------------------------------------- */
Static Function GetNumSCP(cCP_ITEM, cCP_PRODUTO, nCP_QUANT, cCP_DATPRF, cCP_LOCAL)

	Local cQuery:= ""
	Local cRet	:= ""
   cQuery:= "SELECT MAX(CP_NUM) CP_NUM "
	cQuery += " FROM " + retSqlName("SCP")
  	cQuery += " WHERE CP_FILIAL = '" + xFilial("SCP") + "' "
	cQuery += " AND D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )

	If SELECT("WS_GETNUMSCP") > 0
		WS_GETNUMSCP->(dbCloseArea())
	EndIf

	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), "WS_GETNUMSCP", .T., .T. )

	dbSelectArea("WS_GETNUMSCP")

	If WS_GETNUMSCP->(Eof())
		WS_GETNUMSCP->(dbCloseArea())
		cRet := STR0026 //"Codigo NumSCP nao encontrado - pesquisa: "
		cRet += cCP_ITEM    + " - "
		cRet += cCP_PRODUTO + " - "
		cRet += AllTrim(Str(nCP_QUANT,19,2)) + " - "
		cRet += cCP_DATPRF  + " - "
		cRet += cCP_LOCAL   + " - "
		cRet += "("+ STR0027 + " " + cEmpAnt + ", " // "Empresa "
		cRet += STR0028 + " " + cFilAnt + ")" //"Filial"

		conout(cRet)
		return ""
	Endif

	cRet := WS_GETNUMSCP->CP_NUM
	conOut( STR0029 + " "  + cRet)//"Codigo Solic Armazem :"

	WS_GETNUMSCP->(dbCloseArea())

Return cRet

User Function NOTHING1; Return  // "dummy" function - Internal Use
