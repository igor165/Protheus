#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"            
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.ch"
#INCLUDE "pmswmt410.ch"
#DEFINE _EOL chr(13) + chr(10)

/* --------------------------------------------------------------------------------------
WStruct		stCabSC5
Autor		Edvin Markstein Zimmermann
Data		25/03/2010
Descricao	Cabecalho da tabela SC5 (Pedido de Venda)
			//SC5 - PEDIDOS DE VENDA
			//SC6 - ITENS DO PEDIDO DE VENDA
-------------------------------------------------------------------------------------- */
WSStruct stCabSC5
	WSData C5_FILIAL	as String
	WSData C5_CLIENTE	as String
	WSData C5_LOJACLI	as String
	WSData C5_TIPOCLI	as String
	WSData C5_TIPO		as String
	WSData C5_CONDPAG	as String
	WSData C5_EMPRESA	as String
	WsData C5_MUNPRES	as String OPTIONAL
	WsData C5_ESTPRES	as String OPTIONAL
EndWSStruct

/* --------------------------------------------------------------------------------------
WStruct		stCorpoSC6
mas Autor		Edvin Markstein Zimmermann
Data		25/03/2010
Descricao	Corpo da tabela SC6 (Itens do pedido de venda)
-------------------------------------------------------------------------------------- */
WSStruct ctCorSC6
	WSData C6_ITEM			as String 
	WSData C6_PRODUTO		as String 
	WSData C6_QTDVEN		as Float  
	WSData C6_PRCVEN		as Float  
	WSData C6_TES			as String OPTIONAL
	WSData C6_PROJPMS		as String OPTIONAL
	WsData C6_EDTPMS		as String OPTIONAL
	WSData C6_TASKPMS		as String OPTIONAL
	WSData C6_CC			as String OPTIONAL
	WSData sRatCTBPV		as array of arRatCTBPV OPTIONAL
EndWSStruct

/* --------------------------------------------------------------------------------------
WStruct	    arRatCTBPV
Autor	    Hilton vinhola do Nascimento
Data		29/03/2010
Descricao	Campos da tabela AGG (Rateio de centro de custo)
-------------------------------------------------------------------------------------- */
WSStruct arRatCTBPV
		WSData AGG_PERC    AS FLOAT OPTIONAL
		WSData AGG_CC      AS STRING OPTIONAL
		WSData AGG_CONTA   AS STRING OPTIONAL
		WSData AGG_ITEMCTA AS STRING OPTIONAL
		WSData AGG_CLVL    AS STRING OPTIONAL
EndWSStruct  

/* --------------------------------------------------------------------------------------
WStruct	    arAdtPV
Autor	    Hilton vinhola do Nascimento
Data		29/03/2010
Descricao	Campos da tabela FIE (ADIANTAMENTO)
-------------------------------------------------------------------------------------- */
WSStruct arAdtPV  
	   	WSData FIE_PREFIX  as string OPTIONAL
	  	WSData FIE_NUM     as string OPTIONAL
	  	WSData FIE_PARCEL  as string OPTIONAL
     	WSData FIE_TIPO    as string OPTIONAL
	   	WSData FIE_VALOR   as float  OPTIONAL
EndWSStruct           
                               
 
/* --------------------------------------------------------------------------------------
WStruct		stPedidoVenda
Autor		Edvin Markstein Zimmermann
Data		25/03/2010
Descricao	Pedido de venda
-------------------------------------------------------------------------------------- */
WSStruct stPedidoVenda
	WSData sCab			as stCabSC5
	WSData sCor			as array of ctCorSC6
    WSData sAdtPV	    as array of arAdtPV OPTIONAL
EndWSStruct

/* --------------------------------------------------------------------------------------
WStruct	 stEXCLUISC5
Autor		Adilson Soeiro de Oliveira
Data		17/05/2010
Descricao	Estrutura para exclusao do pedido de venda
-------------------------------------------------------------------------------------- */
WSStruct stEXCLUISC5

	WSData cC5_CODFIL	as String
	WsData cC5_CODID	as String
	WSData cC5_EMPRESA	as String
EndWSStruct


/* --------------------------------------------------------------------------------------
WebService	WSMATA410
Autor		Edvin Markstein Zimmermann
Data		24/03/2010
Descricao	Web Service WSMATA410 - Pedido de venda
 -------------------------------------------------------------------------------------- */ 
WSService WSMATA410 Description STR0001 //"WSMATA410 - Pedido de venda integrado do TOTVS Obras e Projetos"
    
    //Declaração de variaveis
	WSData sPedidoVenda	as stPedidoVenda
	WSData cId			as String
	WSData cRet			as String
	WSData sSC5Exclui	as stEXCLUISC5 
	WSData NUM_PEDIDO	as STRING

	//Declaracaoo de metodos
	WSMethod Inclui			description STR0002 //"Inclui um pedido de venda" 
	WSMethod Alterar 		description STR0003 // "Alterar um pedido de venda"
	WSMethod Exclui			description STR0004 // "Exclui um pedido de venda"
ENDWSSERVICE
           

/*--------------------------------------------------------------------------------------
WSMethod	Inclui
Autor		Edvin Markstein Zimmermann
Data		20/03/2010
Descricao	Inclui um pedido de venda
Retorno		.t.
--------------------------------------------------------------------------------------*/
WSMethod Inclui WSReceive sPedidoVenda WSSEND cRet WSSERVICE WSMATA410
Local aCabec		:= {}
Local aItens		:= {}
Local nI,nJ			:= 0
Local nSize			:= 0
Local oCabe			:= nil
Local oCorpo		:= nil
Local aErro			:= {}
Local nZ			:= 0
Local cErro			:= ""

local AAdtPV        :={}
local ARATCTBPV     :={}
Local nFim          := 0

// Controle de Filial PROTHEUS - 13/05/2010 - Multi Filiais
// Controle de Filial PROTHEUS - 23/11/2010 - cEmpOOO/cFilOOO - Multi Empresas/Filiais
Local aArea			:= {}
Local cEmpOOO		:= ""
Local cFilOOO		:= ""
Local lEMPFil		:= .F.

Local cNatureza		:= " "
Local cTesPar 		:= ""
Local oAdtPV    	:= nil // Adiantamento é por pedido
Local oRatCTBPV	    := nil // Rateio é por item do pedido
Local nColigada:=0
Local lTOpxTin:=.F.
Local cCusto:=''
Local cCodCli:=''
Local cCodLoja:=''
PRIVATE lMsErroAuto := .F.
Private cCliente	:= ""
Private cLoja		:= ""
Private cCepe		:= ""
Private cEnde		:= ""
Private cBairroe	:= ""
Private cMune		:= ""
Private cEste		:= ""

//UTILIZANDO VARIÁVEL PARA MELHOR VISUALIZAÇÃO DO CÓDIGO
oCabe	    := ::sPedidoVenda:sCab
oCorpo   	:= ::sPedidoVenda:sCor
oAdtPV		:= ::sPedidoVenda:sAdtPV


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

If Empty(oCabe:C5_EMPRESA) .or. Empty(oCabe:C5_FILIAL)
	SetSoapFault( "WSMATA410",STR0005 +  STR0006)//"Pedido de Venda nao incluso.Codigo da Empresa/Filial nao informado (vazio)."
	return .F.
Endif    

If Type("cFilAnt") =="U" //retirou o preparein do ini
	If FindFunction("PmsW40Fil")
		cFilOOO := (oCabe:C5_FILIAL) 
		cEmpOOO :=	(oCabe:C5_EMPRESA) 
		lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
	Else //está sem o preparein, e nao vai conseguir setar a filial.
		SetSoapFault( "WSMATA410",STR0035)//"Não foi possível completar esta ação. É necessária uma atualização dos WebServices de integração TOP x Protheus. Entre com contato com o Suporte Totvs."
		return .F.
	Endif
Else
	cFilOOO := Padr(Alltrim(oCabe:C5_FILIAL)  ,Len(cFilAnt) )
	cEmpOOO := Padr(Alltrim(oCabe:C5_EMPRESA) ,Len(cEmpAnt) )
	lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
Endif

If !lEMPFil
	SetSoapFault( "WSMATA410",STR0005+  STR0007)//"Pedido de Venda nao incluso.Codigo da Empresa/Filial inexistente ou não autorizada."
	return .F.
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento de variavel apos ter definido o ambiente       ³
//³                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aArea		:= GetArea()
cNatureza	:= GetMv("MV_SLMNTPV" ,.F. ," ")
cTesPar 	:= GetMv("MV_SLMTS"   ,.F. ,"" )
nColigada:=GetNewPar('MV_RMCOLIG',0)
lTopxTin:=Iif(FindFunction('IntTopTin'),IntTopTin(nColigada),.F.)
IF ExistBlock(cNatureza)
	cNatureza := ExecBlock(cNatureza,.F.,.F.,{oCabe,oCorpo})
EndIf

If ValType(cNatureza) != "C"
	cNatureza := ""
	ConOut(STR0008)//"Conteudo do parametro MV_SLMNTPV invalido"
Endif



// **********************
// *******@@@@@**********
// ******@@**@@@*********
// **********@@**********
// *********@@@**********
// ********@@@***********
// *******@@@@@@*********
// **********************


If lTopxTin // indica que o cliente usa integração do Tin e TOP ao mesmo tempo
	cCodCli:=IsTopxTin("SA1",(oCabe:C5_CLIENTE))
	cCodLoja	:=SubStr(cCodCli,TamSX3("E1_CLIENTE")[1]+1,TamSX3("E1_LOJA")[1])
	cCodCli:=SubStr(cCodCli,1,TamSX3("E1_CLIENTE")[1])
Else
	cCodCli	:= padR(oCabe:C5_CLIENTE, TamSX3("C5_CLIENTE")[1])
	cCodLoja	:= padR(oCabe:C5_LOJACLI, TamSX3("C5_LOJACLI")[1])
Endif

//CRIANDO CABECALHO

AADD(aCabec, {"C5_FILIAL"	, xFilial("SC5")	, Nil})
AADD(aCabec, {"C5_TIPO"		, oCabe:C5_TIPO		, Nil})
AADD(aCabec, {"C5_CLIENTE"	, cCodCli			, Nil})
AADD(aCabec, {"C5_LOJACLI"	, cCodLoja			, Nil})
AADD(aCabec, {"C5_TIPOCLI"	, oCabe:C5_TIPOCLI	, Nil})
AADD(aCabec, {"C5_CONDPAG"	, oCabe:C5_CONDPAG	, Nil})
If !Empty(oCabe:C5_MUNPRES)
	AADD(aCabec, {"C5_MUNPRES"	, oCabe:C5_MUNPRES	, Nil})
EndIf
If !Empty(oCabe:C5_ESTPRES)
	AADD(aCabec, {"C5_ESTPRES"	, oCabe:C5_ESTPRES	, Nil})
EndIf
AADD(aCabec, {"C5_NATUREZ"	, cNATUREZA			, Nil})
AADD(aCabec, {"C5_ORIGEM"	, "PMSWMT410"			, Nil})

//CRIANDO CORPO (SUB - ITENS DO ORCAMENTO TELEVENDAS)

nSize := len( oCorpo )

For nI := 1 to nSize
	
	aItensTemp := {}
	aadd( aItensTemp ,{"C6_ITEM"	, PadL( Alltrim(oCorpo[nI]:C6_ITEM), TamSX3("C6_ITEM")[1] ,"0" )	,Nil } )
	aadd( aItensTemp ,{"C6_PRODUTO"	, oCorpo[nI]:C6_PRODUTO	,Nil } )
	aadd( aItensTemp ,{"C6_QTDVEN"	, oCorpo[nI]:C6_QTDVEN	,Nil } )
	aadd( aItensTemp ,{"C6_PRCVEN"	, oCorpo[nI]:C6_PRCVEN	,Nil } )
	cCusto:=oCorpo[nI]:C6_CC
 	If lTopxTin
       	cCusto:=IsTopxTin("CTT",(cCusto))
		cCusto:=SubStr(cCusto,TAMSX3('CTT_FILIAL')[1]+1,TAMSX3("CTT_CUSTO")[1]) 
   	Endif	
	aadd( aItensTemp ,{"C6_CC"		, cCusto		,Nil } )
	If !Empty(oCorpo[nI]:C6_PROJPMS)
		aadd( aItensTemp, {"C6_PROJPMS"	, oCorpo[nI]:C6_PROJPMS	,Nil } )
	EndIf
	If !Empty(oCorpo[nI]:C6_EDTPMS)
		aadd( aItensTemp, {"C6_EDTPMS"	, oCorpo[nI]:C6_EDTPMS	,Nil } )
	EndIf
	If !Empty(oCorpo[nI]:C6_TASKPMS)
		aadd( aItensTemp, {"C6_TASKPMS"	, oCorpo[nI]:C6_TASKPMS	,Nil } )
	EndIf

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial()+oCorpo[nI]:C6_PRODUTO )
	// Caso a TES não tenha sido informada, assume a TES do parametro MV_SLMTS
	aadd( aItensTemp , {"C6_TES"		, iIf(Empty(oCorpo[nI]:C6_TES) ,iIf(Empty(SB1->B1_TS) ,cTesPar ,SB1->B1_TS),oCorpo[nI]:C6_TES), Nil } )
	aAdd(aItens, aClone(aItensTemp))
Next nI

// VINCULANDO ADTOS PARA O PV
// OS TITULOS DO TIPO PA JÁ DEVEM EXISTIR NA BASE
// aAdtPV[x] --> array contendo os dados do título de PA a ser vinculado

nSize := len( oAdtPV )
for nI := 1 to nSize
	aItensTemp := {}
	aadd( aItensTemp , {"FIE_FILIAL" 	,xFilial("FIE")       	  			               					,Nil })
	aadd( aItensTemp , {"FIE_CART" 		,"R"								                				,Nil }) // CARTEIRA PAGAR
	aadd( aItensTemp , {"FIE_PEDIDO" 	,""                													,Nil }) // NÃO PRECISA, POIS QUEM TRATA É A A120ADIANTAMENTO()
	aadd( aItensTemp , {"FIE_PREFIX" 	,PadR( Alltrim(oAdtPV[nI]:FIE_PREFIX),	TamSX3("FIE_PREFIX")[1])	,Nil })
	aadd( aItensTemp , {"FIE_NUM" 	    ,PadR( Alltrim(oAdtPV[nI]:FIE_NUM),		TamSX3("FIE_NUM")   [1])	,Nil })
	aadd( aItensTemp , {"FIE_PARCEL" 	,PadR( Alltrim(oAdtPV[nI]:FIE_PARCEL),	TamSX3("FIE_PARCEL")[1])	,Nil })
	aadd( aItensTemp , {"FIE_TIPO" 		,PadR( Alltrim(oAdtPV[nI]:FIE_TIPO	),	TamSX3("FIE_TIPO")  [1])	,Nil })
	aadd( aItensTemp , {"FIE_CLIENT" 	,cCodCli						    								,Nil })
	aadd( aItensTemp , {"FIE_LOJA" 		,cCodLoja		    												,Nil })
	aadd( aItensTemp , {"FIE_VALOR" 	,oAdtPV[nI]:FIE_VALOR												,Nil }) // VALOR DO PA QUE ESTÁ VINCULADO AO PEDIDO
	aAdd(aAdtPV, aClone(aItensTemp))
next nI

//CRIANDO RATEIO PARA OS ITENS DO PV
// ESTRUTURA
// aRatCTBPV[X][1] --> número do item
// aRatCTBPV[X][2] --> array contendo a estrutura do rateio da AGG
nSize := len( oCorpo )
for nI := 1 to nsize
	oRatCTBPV	:= oCorpo[nI]:sRatCTBPV
	nSizeRat 	:= Len(oRatCTBPV)
	If nSizeRat <= 0
		Exit
	EndIf
	cItem 		:= PadL( Alltrim(oCorpo[nI]:C6_ITEM), TamSX3("C6_ITEM")[1] ,"0" )
	nItensRat	:= 0
	
	aADD(aRatCTBPV,Array(2))
	aRatCTBPV[nI][1] := cItem
	aRatCTBPV[nI][2] := {}
	
	For nJ := 1 to nSizeRat
		aItensTemp := {}
		nItensRat++
		cCusto:=oRatCTBPV[nJ]:AGG_CC
 		If lTopxTin
       		cCusto:=IsTopxTin("CTT",(cCusto))
			cCusto:=SubStr(cCusto,TAMSX3('CTT_FILIAL')[1]+1,TAMSX3("CTT_CUSTO")[1]) 
   		Endif	
		aadd( aItensTemp , {"AGG_FILIAL" 	, xFilial("AGG")   			, Nil } )
		aadd( aItensTemp , {"AGG_PEDIDO" 	, ""            			, Nil } )
		aadd( aItensTemp , {"AGG_FORNECE" 	, cCodCli					, Nil } )
		aadd( aItensTemp , {"AGG_LOJA" 		, cCodLoja					, Nil } )
		aadd( aItensTemp , {"AGG_ITEMPD"	, cItem         			, Nil } )
		aadd( aItensTemp , {"AGG_ITEM" 		, STRZERO(nItensRat,2)		, Nil } ) // LINHA DO RATEIO
		aadd( aItensTemp , {"AGG_PERC" 		, oRatCTBPV[nJ]:AGG_PERC	, Nil } ) // PERCENTUAL
		aadd( aItensTemp , {"AGG_CC"	    , cCusto						, Nil } ) // CENTRO DE CUSTO
		aadd( aItensTemp , {"AGG_CONTA"		, oRatCTBPV[nJ]:AGG_CONTA	, Nil } ) // CONTA CONTABIL
		aadd( aItensTemp , {"AGG_ITEMCT"	, oRatCTBPV[nJ]:AGG_ITEMCTA	, Nil } ) // ITEM CONTABIL
		aadd( aItensTemp , {"AGG_CLVL"		, oRatCTBPV[nJ]:AGG_CLVL	, Nil } ) // CLASSE DE VALOR
		aAdd(aRatCTBPV[nI][2], aClone(aItensTemp))
	Next nJ
next nI

conOut(STR0009 + "(" + TIME() + ")")//"EXECUTANDO FUNCAO DE GRAVACAO AUTOMATICA MATA410...

MsExecAuto({|a,b,c,d,e,f| Mata410(a,b,c,d,,,,e,f)},aCabec,aItens,3,.F.,aRatCTBPV,aAdtPV)

//VERIFICANDO SE HOUVE ERRO AO FEAGGAR O PEDIDO
If lMsErroAuto

	// Verifica se foi informado Tipo Pedido de Venda
	If Empty(oCabe:C5_TIPO)
		SetSoapFault( "WSMATA410"," " + STR0005 + STR0010)//" Pedido de Venda nao incluso. Tipo Pedido de Venda nao informada (vazio)."
		conOut("WSMATA410"," " + STR0005 +  STR0010)//" Pedido de Venda nao incluso.Tipo Pedido de Venda nao informada (vazio)."
		return .F.
	Endif    

	// Verifica se foi informado código do Cliente
	If (Empty(cCodCli) .OR. Empty(cCodLoja))
		SetSoapFault( "WSMATA410"," " + STR0005 +  STR0011) //" Pedido de Venda nao incluso.Cliente ou Loja nao informado (vazio)."
		conOut("WSMATA410"," " + STR0005 +  STR0011) //" Pedido de Venda nao incluso.Cliente ou Loja nao informado (vazio)."
		return .F.
	Else       
	   aArea:= GetArea()
		dbSelectArea("SA1")
	 	dbSetOrder(1)
		If !dbSeek(xFilial()+cCodCli+cCodLoja)
				SetSoapFault( "WSMATA410"," " + STR0005 +  STR0012)//" Pedido de Venda nao incluso.Cliente inexistente."
				ConOut("WSMATA410"," " + STR0005 +  STR0012)//" Pedido de Venda nao incluso.Cliente inexistente."
				RestArea(aArea)
				return .F.
		Endif           
		RestArea(aArea)
	Endif
	
	// Verifica se foi informado Cond.Pagto.
	If Empty(oCabe:C5_CONDPAG) 
		SetSoapFault( "WSMATA410"," " + STR0005 +  STR0013)//" Pedido de Venda nao incluso.Cond.Pagto nao informada (vazio)."
		ConOut("WSMATA410"," " + STR0005 +  STR0013)//" Pedido de Venda nao incluso.Cond.Pagto nao informada (vazio)."
		return .F.
	Else
	   aArea:= GetArea()
		dbSelectArea("SE4")
	 	dbSetOrder(1)
		If !dbSeek(xFilial()+oCabe:C5_CONDPAG)
			SetSoapFault( "WSMATA410"," " + STR0005 +  STR0014)//" Pedido de Venda nao incluso.Cond.Pagto inexistente."
			ConOut("WSMATA410"," " + STR0005 +  STR0014)//" Pedido de Venda nao incluso.Cond.Pagto inexistente."
			RestArea(aArea)
			return .F.
		Endif           
		RestArea(aArea)	
	Endif	                                                                    
		     
	// Verifica se foi informado Natureza.
	If Empty(cNATUREZA)
		SetSoapFault( "WSMATA410"," " + STR0005 + STR0015)//" Pedido de Venda nao incluso. Natureza nao informada (vazio)."
		ConOut("WSMATA410"," " + STR0005 + STR0015)//" Pedido de Venda nao incluso. Natureza nao informada (vazio)."
		return .F. 
	Else
	   aArea:= GetArea()
		dbSelectArea("SED")
	 	dbSetOrder(1)
		If !dbSeek(xFilial()+cNATUREZA)
			SetSoapFault( "WSMATA410"," " + STR0005 +  STR0016)//" Pedido de Venda nao incluso.Natureza inexistente"
			ConOut("WSMATA410"," " + STR0005 +  STR0016)//" Pedido de Venda nao incluso.Natureza inexistente"
			RestArea(aArea)
			return .F.
		Endif           
		RestArea(aArea)		
	Endif		
		
	conOut(STR0017)//" *** ATENCAO *** "
	conOut(STR0018 + " "  + DtoC(Date()) + " - " + time())//"     ERRO AO EFETUAR SOLICITACAO - DATA: "
	conOut(STR0019)//"++++++++++ SOLICITACAO DO ERRO ++++++++++"
	conOut(MemoRead(NomeAutoLog()))

	//LISTANDO DETALHES DO ERRO
	aErro := GetAutoGRLog()
	For nZ := 1 To Len(aErro)
		cErro += aErro[nZ] + CRLF
	Next nZ
	conOut(cErro)
	conOut("---------------------------------------")
	
	//LISTANDO DETALHES DO WS
	cErro:= STR0020 //"Verifique !, "       
	nFim:=10
	For nZ := 2 TO nFim
		 If ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) <> ""
  			 cErro+= ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) + " "
  		 Else            
  		  	 nZ:=10
		 Endif
	Next nZ
	SetSoapFault("WSMATA410",STR0020 + CRLF + MemoRead(NomeAutoLog()))	
	return .F.
Else
	conOut("MATA410" + " " + STR0021 + "(" + TIME() + ")")// EXECUTADO! 
EndIf


::cRet := GetNumSC5( xFilial("SC5"), cCodCli, cCodLoja)

If empty( ::cRet )
	conOut( STR0022 )//"Retorno vazio da funcao"
	conOut( STR0023 + xFilial("SC5"), STR0024 + oCabe:C5_CLIENTE, STR0025 + oCabe:C5_LOJACLI )//FILIAL, CLIENTE, LOJA
Endif

//
// Gera a amarracao com o projeto
// 

dbSelectArea("SC6")
SC6->(dbsetorder(1))
cKEY := xFilial("SC6")+::cRet

SC6->( DbSeek( cKEY ) )
While SC6->(!EOF()) .And. SC6->(C6_FILIAL+C6_NUM) == cKEY 
	RecLock("SC6",.F.)
		SC6->C6_PMSID:= C6_NUM
	MsUnlock() 
	SC6->(dbSkip())
EndDo 


conOut(STR0026)//"FINALIZANDO..."

RestArea(aArea)

Return .T.

/*--------------------------------------------------------------------------------------
WSMethod	Exclui
Autor		Edvin Markstein Zimmermann
Data		20/03/2010
Descricao	Exclui um pedido de venda
Retorno		.t.
--------------------------------------------------------------------------------------*/
WSMethod Exclui WSReceive sSC5Exclui WSSEND cRet WSSERVICE WSMATA410

Local aCabec		:= {}
Local aItens		:= {}
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

If Empty(::sSC5Exclui:cC5_EMPRESA) .Or. Empty(::sSC5Exclui:cC5_CODFIL)
	SetSoapFault( "WSMATA410",STR0027 + STR0006)//"Pedido de Venda nao excluido.Codigo da Empresa/Filial nao informado (vazio)." 
	return .F.
Endif    


If Type("cFilAnt") =="U" //retirou o preparein do ini
	If FindFunction("PmsW40Fil")
		cFilOOO := (::sSC5Exclui:cC5_CODFIL) 
		cEmpOOO :=	(::sSC5Exclui:cC5_EMPRESA) 
		lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
	Else //está sem o preparein, e nao vai conseguir setar a filial.
		SetSoapFault( "WSMATA410",STR0035)//"Não foi possível completar esta ação. É necessária uma atualização dos WebServices de integração TOP x Protheus. Entre com contato com o Suporte Totvs."
		return .F.
	Endif
Else
	cFilOOO := Padr( Alltrim(::sSC5Exclui:cC5_CODFIL)  ,Len(cFilAnt) )
	cEmpOOO := Padr( Alltrim(::sSC5Exclui:cC5_EMPRESA) ,Len(cEmpAnt) )
	lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
Endif
If !lEMPFil
	SetSoapFault( "WSMATA410",STR0027 +  STR0007)//"Pedido de Venda nao excluido.Codigo da Empresa/Filial inexistente ou não autorizada."
	return .F.
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento de variavel apos ter definido o ambiente       ³
//³                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aArea		:= GetArea()


// **********************
// *******@@@@@**********
// ******@@**@@@*********
// **********@@**********
// *********@@@**********
// ********@@@***********
// *******@@@@@@*********
// **********************

cId := PADR( ::sSC5Exclui:cC5_CODID ,TamSX3("C5_NUM")[1]  )

dbSelectArea("SC5")
SC5->(dbSetOrder(1))
If !SC5->(DbSeek(xFilial("SC5")+ cId))
	SetSoapFault("WSMATA410",STR0028) //"Codigo de pedido de venda nao encontrado."
	return .F.
endIf

//CRIANDO CABECALHO
AADD(aCabec,{"C5_FILIAL" 	, xFilial("SC5")	, Nil})
AADD(aCabec,{"C5_NUM" 		, cId	, Nil})

conOut(STR0009 + "(" + TIME() + ")")//"EXECUTANDO FUNCAO DE GRAVACAO AUTOMATICA MATA410...

MsExecAuto({|a,b,c| MATA410(a,b,c) },aCabec,aItens,5)

//VERIFICANDO SE HOUVE ERRO AO FEAGGAR O PEDIDO
If lMsErroAuto
	
	conOut(STR0017)  //" *** ATENCAO *** "
	conOut(STR0018 + " "  + DtoC(Date()) + " - " + time())//"     ERRO AO EFETUAR SOLICITACAO - DATA: "
	conOut(STR0019)//"++++++++++ SOLICITACAO DO ERRO ++++++++++"
	conOut(MemoRead(NomeAutoLog()))

	//LISTANDO DETALHES DO ERRO
	aErro := GetAutoGRLog()
	For nZ := 1 To Len(aErro)
		cErro += aErro[nZ] + CRLF
	Next nZ
	conOut(cErro)
	conOut("---------------------------------------")    
	
	//LISTANDO DETALHES DO WS
	cErro:= STR0020 //"Verifique !, "       
	nFim:=10
	For nZ := 2 TO nFim
		 If ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) <> ""
  			 cErro+= ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) + " "
  		 Else            
  		  	 nZ:=10
		 Endif
	Next nZ
	SetSoapFault("WSMATA410",STR0020 + CRLF + MemoRead(NomeAutoLog()))
	return .F.
Else
	conOut("MATA410" + " " +  STR0021 + "(" + TIME() + ")")//EXECUTADO!
EndIf

::cRet := STR0029 //"Pedido de venda excluido com sucesso."

RestArea(aArea)

Return .T.

/* --------------------------------------------------------------------------------------
Funcao		GetNumSC5
Autor		Edvin Markstein Zimmermann
Data		26/03/2010
Descricao	Retorna ultimo codigo do SC5 de um determinado cliente
-------------------------------------------------------------------------------------- */
Function GetNumSC5(cCliFilial, cCodCli, cLojaCli)

Local cQuery := ""
Local cRet := ""

cQuery := "SELECT MAX(C5_NUM) C5_NUM "
cQuery += " FROM " + retSqlName("SC5")
cQuery += " WHERE C5_FILIAL = '" + xFilial("SC5",cCliFilial) +"' "
cQuery += " AND C5_CLIENTE = '" + cCodCli + "' "
cQuery += " AND C5_LOJACLI = '" + cLojaCli + "' "
cQuery += " AND D_E_L_E_T_ = ' ' "


If SELECT("WS_GETNUMSC5") > 0
	WS_GETNUMSC5->(dbCloseArea())
EndIf

dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), "WS_GETNUMSC5", .T., .T. )
dbSelectArea("WS_GETNUMSC5")
If WS_GETNUMSC5->(Eof())
	WS_GETNUMSC5->(dbCloseArea())
	cRet := STR0030 + " " //"Código NumSC5 não encontrado - pesquisa: "
	cRet += xFilial("SC5") + " - " + cCodCli + " - " + cLojaCli + "."
	conout(cRet)
	return ""
Endif

cRet := WS_GETNUMSC5->C5_NUM

WS_GETNUMSC5->(dbCloseArea())

Return cRet

/*--------------------------------------------------------------------------------------
WSMethod	Alterar
Autor    	Hilton Vinhola do Nascimento
Data		20/03/2010
Descricao   ALTERA um pedido de Venda
Retorno		.t.
--------------------------------------------------------------------------------------*/
WSMethod Alterar WSReceive sPedidoVenda,NUM_PEDIDO WSSEND cRet WSSERVICE WSMATA410

Local aCabec	:= {}
Local aItens	:= {}
Local nI,nJ		:= 0
Local nSize		:= 0
Local oCabe		:= nil
Local oCorpo	:= nil
Local aErro		:= {}
Local nZ		:= 0
Local cErro		:= ""
Local cRetorno 	:= ""
Local cNatureza	:= " "
Local cTesPar 	:= ""
Local aAdtPV	:= {} // Adiantamento é por pedido
Local aRatCTBPV	:= {} // Rateio é por item do pedido
Local cItem		:= ""

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
Local cCodCli:=''
Local cCodLoja:=''
PRIVATE lMsErroAuto := .F.
Private cCliente:= ""
Private cLoja	:= ""
Private cCepe	:= ""
Private cEnde	:= ""
Private cBairroe:= ""
Private cMune	:= ""
Private cEste	:= ""

//UTILIZANDO VARIÁVEL PARA MELHOR VISUALIZAÇÃO DO CÓDIGO
oCabe			:= ::sPedidoVenda:sCab
oCorpo			:= ::sPedidoVenda:sCor
oAdtPV			:= ::sPedidoVenda:sAdtPV

IF ExistBlock(cNatureza)
	cNatureza := ExecBlock(cNatureza,.F.,.F.,{oCabe,oCorpo})
EndIf

If ValType(cNatureza) != "C"
	cNatureza := ""
	conOut(STR0008)//"Conteudo do parametro MV_SLMNTPV invalido"
Endif

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

If Empty(oCabe:C5_EMPRESA) .or. Empty(oCabe:C5_FILIAL)
	SetSoapFault( "WSMATA410",STR0005 + STR0006)//"Pedido de Venda nao incluso. Codigo da Empresa/Filial nao informado (vazio)."
	return .F.
Endif    

If Type("cFilAnt") =="U" //retirou o preparein do ini
	If FindFunction("PmsW40Fil")
		cFilOOO := (oCabe:C5_FILIAL) 
		cEmpOOO :=	(oCabe:C5_EMPRESA) 
		lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
	Else //está sem o preparein, e nao vai conseguir setar a filial.
		SetSoapFault( "WSMATA410",STR0035)//"Não foi possível completar esta ação. É necessária uma atualização dos WebServices de integração TOP x Protheus. Entre com contato com o Suporte Totvs."
		return .F.
	Endif
Else
	cFilOOO := Padr(Alltrim(oCabe:C5_FILIAL)  ,Len(cFilAnt) )
	cEmpOOO := Padr(Alltrim(oCabe:C5_EMPRESA) ,Len(cEmpAnt) )
	lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
Endif

If !lEMPFil
	SetSoapFault( "WSMATA410",STR0005 + STR0007)//"Pedido de Venda nao incluso. Codigo da Empresa/Filial inexistente ou não autorizada."
	return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento de variavel apos ter definido o ambiente       ³
//³                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aArea		:= GetArea()
cNatureza	:= GetMv("MV_SLMNTPV" ,.F. ," ")
cTesPar 	:= GetMv("MV_SLMTS"   ,.F. ,"")
nColigada:=GetNewPar('MV_RMCOLIG',0)
lTopxTin:=Iif(FindFunction('IntTopTin'),IntTopTin(nColigada),.F.)


// **********************
// *******@@@@@**********
// ******@@**@@@*********
// **********@@**********
// *********@@@**********
// ********@@@***********
// *******@@@@@@*********
// **********************


dbselectArea("SC5")
SC5->(DBSetOrder(1))
IF !SC5->(DbSeek(xFilial("SC5")+ALLTRIM(::NUM_PEDIDO)))
	SetSoapFault("WSMATA410",STR0028 + " " + cEmpAnt+"|"+cFilAnt+"|"+xFilial("SC5")+"|"+ALLTRIM(::NUM_PEDIDO))//"Codigo de pedido de venda nao encontrado: "
	return .F.
EndIf

If lTopxTin // indica que o cliente usa integração do Tin e TOP ao mesmo tempo
	cCodCli:=IsTopxTin("SA1",(oCabe:C5_CLIENTE))
	cCodLoja	:=SubStr(cCodCli,TamSX3("E1_CLIENTE")[1]+1,TamSX3("E1_LOJA")[1])
	cCodCli:=SubStr(cCodCli,1,TamSX3("E1_CLIENTE")[1])
Else
	cCodCli	:= padR(oCabe:C5_CLIENTE, TamSX3("C5_CLIENTE")[1])
	cCodLoja	:= padR(oCabe:C5_LOJACLI, TamSX3("C5_LOJACLI")[1])
Endif
//CRIANDO CABECALHO

AADD(aCabec,{"C5_FILIAL"	, xFilial("SC5")  	, Nil})
AADD(aCabec,{"C5_TIPO" 		, oCabe:C5_TIPO	    , Nil})
AADD(aCabec,{"C5_CLIENTE" 	, cCodCli	, Nil})
AADD(aCabec,{"C5_LOJACLI" 	, cCodLoja	, Nil})
AADD(aCabec,{"C5_TIPOCLI" 	, oCabe:C5_TIPOCLI	, Nil})
AADD(aCabec,{"C5_CONDPAG"	, oCabe:C5_CONDPAG  , Nil})
AADD(aCabec,{"C5_NATUREZ"	, cNATUREZA			, Nil})
AADD(aCabec,{"C5_NUM"	   , ALLTRIM(::NUM_PEDIDO)	, Nil})

//CRIANDO CORPO (SUB - ITENS DO ORCAMENTO TELEVENDAS)

// Wilson o Pedido recebe todos os itens do Webservice
// Porem será preciso ler item a item e ver se existe, para
// alterar, quando não existir ele já inclui.
// quando não vier do Webservice, excluir no Protheus.

nSize := len( oCorpo )
SC6->(dbSetOrder(1))

For nI := 1 to nSize

	cItem := PadL( Alltrim(oCorpo[nI]:C6_ITEM), TamSX3("C6_ITEM")[1] ,"0" )

	SC6->(MsSeek(xFilial("SC6") + ALLTRIM(::NUM_PEDIDO) + cItem ) )
	aItensTemp := {}
	aadd( aItensTemp ,{"C6_ITEM"	,cItem					,Nil } )
	aadd( aItensTemp ,{"C6_PRODUTO"	,oCorpo[nI]:C6_PRODUTO	,Nil } )
	aadd( aItensTemp ,{"C6_QTDVEN"	,oCorpo[nI]:C6_QTDVEN 	,Nil } )
	aadd( aItensTemp ,{"C6_PRCVEN "	,oCorpo[nI]:C6_PRCVEN 	,Nil } )
	aadd( aItensTemp ,{"C6_PROJPMS"	,oCorpo[nI]:C6_PROJPMS	,Nil } )
	aadd( aItensTemp ,{"C6_TASKPMS"	,oCorpo[nI]:C6_TASKPMS	,Nil } )
	cCusto:=oCorpo[nI]:C6_CC
 	If lTopxTin
       	cCusto:=IsTopxTin("CTT",(cCusto))
		cCusto:=SubStr(cCusto,TAMSX3('CTT_FILIAL')[1]+1,TAMSX3("CTT_CUSTO")[1]) 
   	Endif	
	aadd( aItensTemp ,{"C6_CC"	    ,cCusto					,Nil } )
	aadd( aItensTemp ,{"C6_REC_WT" 	,SC6->(RECNO())			,Nil } )
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial()+oCorpo[nI]:C6_PRODUTO )
	// Caso a TES não tenha sido informada, assume a TES do parametro MV_SLMTS
	aadd( aItensTemp , {"C6_TES"	, iIf(Empty(oCorpo[nI]:C6_TES) ,iIf(Empty(SB1->B1_TS) ,cTesPar ,SB1->B1_TS),oCorpo[nI]:C6_TES), Nil } )
	aAdd(aItens, aClone(aItensTemp))
	
	// Verifica por item se Produto não foi informado
	If Empty(oCorpo[nI]:C6_PRODUTO)
		SetSoapFault( "WSMATA410",STR0034 + " "  + Alltrim(str(nI)) + " " + STR0031)//"Item: " Pedido de Venda nao alterado. Codigo do Produto nao informado (vazio)."
		return .F.
	Endif   

	//Verifica por item se Quantidade não foi Informada	
	If Empty(oCorpo[nI]:C6_QTDVEN)
		SetSoapFault( "WSMATA410",STR0034 + " "+ Alltrim(str(nI)) + " " + STR0032)//""Item:  Pedido de Venda nao alterado. Quantidade nao Informada (vazio)."
		return .F.
	Endif     
	
	//Verifica por item se Quantidade não foi Informada	
	If Empty(oCorpo[nI]:C6_PRCVEN)
		SetSoapFault( "WSMATA410",STR0034 + " " + Alltrim(str(nI)) + " " + STR0033)//""Item:  Pedido de Venda nao alterado. Preço de Venda nao Informado (vazio)."
		return .F.
	Endif
		
Next nI

// VINCULANDO ADTOS PARA O PV
// OS TITULOS DO TIPO PA JÁ DEVEM EXISTIR NA BASE
// aAdtPV[x] --> array contendo os dados do título de RA a ser vinculado

nSize := len( oAdtPV )
for nI := 1 to nSize
	aItensTemp := {}
	aadd( aItensTemp , {"FIE_FILIAL" 	, xFilial("FIE")       	  			               					, Nil } )
	aadd( aItensTemp , {"FIE_CART" 		, "R"								                				, Nil } ) // CARTEIRA PAGAR
	aadd( aItensTemp , {"FIE_PEDIDO" 	, ""                							   					, Nil } ) // NÃO PRECISA, POIS QUEM TRATA É A A120ADIANTAMENTO()
	aadd( aItensTemp , {"FIE_PREFIX" 	, PadR( Alltrim(oAdtPV[nI]:FIE_PREFIX),TamSX3("FIE_PREFIX")[1])	, Nil } )
	aadd( aItensTemp , {"FIE_NUM" 	    , PadR( Alltrim(oAdtPV[nI]:FIE_NUM),	TamSX3("FIE_NUM")   [1])	, Nil } )
	aadd( aItensTemp , {"FIE_PARCEL" 	, PadR( Alltrim(oAdtPV[nI]:FIE_PARCEL),TamSX3("FIE_PARCEL")[1])	, Nil } )
	aadd( aItensTemp , {"FIE_TIPO" 		, PadR( Alltrim(oAdtPV[nI]:FIE_TIPO	),	TamSX3("FIE_TIPO")  [1]) 	, Nil } )
	aadd( aItensTemp , {"FIE_CLIENT" 	, cCodCli						    								, Nil } )
	aadd( aItensTemp , {"FIE_LOJA" 		, cCodLoja		     												, Nil } )
	aadd( aItensTemp , {"FIE_VALOR" 	, oAdtPV[nI]:FIE_VALOR												, Nil } ) // VALOR DO PA QUE ESTÁ VINCULADO AO PEDIDO
	aAdd(aAdtPV, aClone(aItensTemp))
next nI

//CRIANDO RATEIO PARA OS ITENS DO PV
// ESTRUTURA
// aRatCTBPV[X][1] --> número do item
// aRatCTBPV[X][2] --> array contendo a estrutura do rateio da AGG
nSize := len( oCorpo )
for nI := 1 to nsize
	oRatCTBPV	:= oCorpo[nI]:sRatCTBPV
	nSizeRat 	:= Len(oRatCTBPV)
	If nSizeRat <= 0
		Exit
	EndIf
	cItem 		:= PadL( Alltrim(oCorpo[nI]:C6_ITEM), TamSX3("C6_ITEM")[1] ,"0" )
	nItensRat	:= 0
	
	aADD(aRatCTBPV,Array(2))
	aRatCTBPV[nI][1] := cItem
	aRatCTBPV[nI][2] := {}
	
	For nJ := 1 to nSizeRat
		aItensTemp := {}
		nItensRat++
		cCusto:=oRatCTBPV[nJ]:AGG_CC
 		If lTopxTin
       		cCusto:=IsTopxTin("CTT",(cCusto))
			cCusto:=SubStr(cCusto,TAMSX3('CTT_FILIAL')[1]+1,TAMSX3("CTT_CUSTO")[1]) 
   		Endif	
		aadd( aItensTemp , {"AGG_FILIAL" 	, xFilial("AGG")   					, Nil } )
		aadd( aItensTemp , {"AGG_PEDIDO" 	, ""            					, Nil } )
		aadd( aItensTemp , {"AGG_FORNECE" 	, cCodCli							, Nil } )
		aadd( aItensTemp , {"AGG_LOJA" 		, cCodLoja						   	, Nil } )
		aadd( aItensTemp , {"AGG_ITEMPD"	, cItem         						, Nil } )
		aadd( aItensTemp , {"AGG_ITEM" 		, STRZERO(nItensRat,2)				, Nil } ) // LINHA DO RATEIO
		aadd( aItensTemp , {"AGG_PERC" 		, oRatCTBPV[nJ]:AGG_PERC		   	, Nil } ) // PERCENTUAL
		aadd( aItensTemp , {"AGG_CC"	    , cCusto								, Nil } ) // CENTRO DE CUSTO
		aadd( aItensTemp , {"AGG_CONTA"		, oRatCTBPV[nJ]:AGG_CONTA			, Nil } ) // CONTA CONTABIL
		aadd( aItensTemp , {"AGG_ITEMCT"	, oRatCTBPV[nJ]:AGG_ITEMCTA				, Nil } ) // ITEM CONTABIL
		aadd( aItensTemp , {"AGG_CLVL"		, oRatCTBPV[nJ]:AGG_CLVL			, Nil } ) // CLASSE DE VALOR
		aAdd(aRatCTBPV[nI][2], aClone(aItensTemp))
	Next nJ
next nI

conOut(STR0009 + "(" + TIME() + ")")//"EXECUTANDO FUNCAO DE GRAVACAO AUTOMATICA MATA410...

MsExecAuto({|a,b,c,d,e,f| Mata410(a,b,c,d,,,,e,f)},aCabec,aItens,4,.F.,aRatCTBPV,aAdtPV)

//VERIFICANDO SE HOUVE ERRO AO PEGAR O PEDIDO

If lMsErroAuto

	// Verifica se foi informado Tipo Pedido de Venda
	If Empty(oCabe:C5_TIPO)
		SetSoapFault( "WSMATA410",STR0005 + STR0010)//" Pedido de Venda nao incluso. Tipo Pedido de Venda nao informada (vazio)."
		conOut("WSMATA410",STR0005 + STR0010)//" Pedido de Venda nao incluso. Tipo Pedido de Venda nao informada (vazio)."
		return .F.
	Endif    

	// Verifica se foi informado código do Cliente
	If (Empty(cCodCli) .OR. Empty(cCodLoja))
		SetSoapFault( "WSMATA410",STR0005 + STR0011) //" Pedido de Venda nao incluso. Cliente ou Loja nao informado (vazio).") 
		conOut("WSMATA410",STR0005 + STR0011) //" Pedido de Venda nao incluso. Cliente ou Loja nao informado (vazio).") 
		return .F.
	Else       
	   aArea:= GetArea()
		dbSelectArea("SA1")
	 	dbSetOrder(1)
		If !dbSeek(xFilial()+cCodCli+cCodLoja)
				SetSoapFault( "WSMATA410",STR0005 + STR0012 ) //" Pedido de Venda nao incluso. Cliente inexistente.")
				ConOut("WSMATA410",STR0005 + STR0012 ) //" Pedido de Venda nao incluso. Cliente inexistente.")
				RestArea(aArea)
				return .F.
		Endif           
		RestArea(aArea)
	Endif
	
	// Verifica se foi informado Cond.Pagto.
	If Empty(oCabe:C5_CONDPAG) 
		SetSoapFault( "WSMATA410",STR0005 + STR0013)//" Pedido de Venda nao incluso. Cond.Pagto nao informada (vazio)."
		ConOut("WSMATA410",STR0005 + STR0013)//" Pedido de Venda nao incluso. Cond.Pagto nao informada (vazio)."
		return .F.
	Else
	   aArea:= GetArea()
		dbSelectArea("SE4")
	 	dbSetOrder(1)
		If !dbSeek(xFilial()+oCabe:C5_CONDPAG)
			SetSoapFault( "WSMATA410",STR0005 + STR0013)//" Pedido de Venda nao incluso. Cond.Pagto inexistente."
			ConOut("WSMATA410",STR0005 + STR0013)//" Pedido de Venda nao incluso. Cond.Pagto inexistente."
			RestArea(aArea)
			return .F.
		Endif           
		RestArea(aArea)	
	Endif	                                                                    
		     
	// Verifica se foi informado Natureza.
	If Empty(cNATUREZA)
		SetSoapFault( "WSMATA410",STR0005 + STR0015)//" Pedido de Venda nao incluso. Natureza nao informada (vazio)."
		ConOut("WSMATA410",STR0005 + STR0015)//" Pedido de Venda nao incluso. Natureza nao informada (vazio)."
		return .F. 
	Else
	   aArea:= GetArea()
		dbSelectArea("SED")
	 	dbSetOrder(1)
		If !dbSeek(xFilial()+cNATUREZA)
			SetSoapFault( "WSMATA410",STR0005 + STR0016)//" Pedido de Venda nao incluso. Natureza inexistente
			ConOut("WSMATA410",STR0005 + STR0016)//" Pedido de Venda nao incluso. Natureza inexistente
			RestArea(aArea)
			return .F.
		Endif           
		RestArea(aArea)		
	Endif		

	conOut(STR0017)//" *** ATENCAO *** "
	conOut(STR0018 + " "  + DtoC(Date()) + " - " + time())//"     ERRO AO EFETUAR SOLICITACAO - DATA: "
	conOut(STR0019)//"++++++++++ SOLICITACAO DO ERRO ++++++++++"
	conOut(MemoRead(NomeAutoLog()))

	//LISTANDO DETALHES DO ERRO
	aErro := GetAutoGRLog()
	For nZ := 1 To Len(aErro)
		cErro += aErro[nZ] + CRLF
	Next nZ
	conOut(cErro)
	conOut("---------------------------------------")
	
	//LISTANDO DETALHES DO WS
	cErro:= STR0020 //"Verifique !, "       
	nFim:=10
	For nZ := 2 TO nFim
		 If ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) <> ""
  			 cErro+= ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) + " "
  		 Else            
  		  	 nZ:=10
		 Endif
	Next nZ
	SetSoapFault("WSMATA410",STR0020 + CRLF + MemoRead(NomeAutoLog()))
	return .F.
Else
	conOut("MATA410" + " " +  STR0021+ "(" + TIME() + ")")//EXECUTADO!
EndIf

::cRet 		:= ::NUM_PEDIDO
cRetorno 	:= ::cRet

//
// Gera a amarracao com o projeto
//
dbSelectArea("SC6")
SC6->(dbsetorder(1))
cKEY := xFilial("SC6")+ ::cRet

SC6->( DbSeek( cKEY ) )
While SC6->(!EOF()) .And. SC6->(C6_FILIAL+C6_NUM) == cKEY 
	RecLock("SC6",.F.)
		SC6->C6_PMSID:= C6_NUM
	MsUnlock() 
	SC6->(dbSkip())
EndDo 

conOut(STR0026) //"FINALIZANDO..."

RestArea(aArea)
	
Return .T.
