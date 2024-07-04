#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "WSFRTVP.CH"
 
User Function _PYPTXRK ; Return  // "dummy" function - Internal Use 

WSSTRUCT WSValePre
	WSDATA Codigo		AS String
	WSDATA Valor		AS Float
	WSDATA Produto   	AS String
	WSDATA Operacao     AS Float
ENDWSSTRUCT

WSSTRUCT WSVPreEst
	WSDATA cCodigo		AS String
	WSDATA cOperacao    AS String
ENDWSSTRUCT

WSSTRUCT WSValeArray
	WSDATA VerArray AS ARRAY OF WSVPreEst
ENDWSSTRUCT


WSSERVICE FRTValePre DESCRIPTION STR0001	//"Serviço de vales presentes"
	WSDATA ValePre		AS WSValePre
	WSDATA cCodigo		AS String
	WSDATA cDoc 		AS String
	WSDATA cVend 		AS String
	WSDATA cCaixa 		AS String
	WSDATA cOper 		AS String
	WSDATA dData		AS Date
	WSDATA cHora		AS String
	WSDATA cCliente		AS String         
	WSDATA cLoja		AS String
	WSDATA cEstacao		AS String
	WSDATA cPDV			AS String
	WSDATA cSerie		AS String
	WSDATA nValor		AS Float
	WSDATA cMessage		AS String
	WSDATA aVPreEst		AS WSValeArray
	WSDATA cEmpPdv   	  AS String     OPTIONAL
	WSDATA cFilPdv   	  AS String     OPTIONAL
	

	WSMETHOD VldVale	DESCRIPTION STR0002	//"Valida o vale presente solicitado"
	WSMETHOD UpdVenda	DESCRIPTION STR0003	//"Atualiza a situação dos vales presentes vendidos"
	WSMETHOD UpdRecebto	DESCRIPTION STR0004	//"Atualiza a situação dos vales presentes recebidos"
	WSMETHOD ValorVale	DESCRIPTION STR0005 //"Retorna o valor de face do vale presente"
	WSMETHOD VPEstorna 	DESCRIPTION STR0006 //"Estorna o Status do VP"
ENDWSSERVICE
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³VldVale   ³ Autor ³ Venda Clientes        ³ Data ³23/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o codigo do vale informado                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto vale presente                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpC1 - Mensagem de erro (ou branco quando OK)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD VldVale WSRECEIVE ValePre,cEmpPdv,cFilPdv WSSEND cMessage WSSERVICE FRTValePre

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao
LjPreparaWs(cEmpPdv,cFilPdv) 

::cMessage := LjVldVP( ::ValePre:Produto, ::ValePre:Codigo, ::ValePre:Valor, ::ValePre:Operacao )
	
Return (.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³UpdVenda  ³ Autor ³ Venda Clientes        ³ Data ³18/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza os vales presentes vendidos            			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array com os codigos dos vales vendidos            ³±±
±±³          ³ ExpC1 - Numero do cupom fiscal da venda                    ³±±
±±³          ³ ExpC2 - Codigo do PDV                                      ³±±
±±³          ³ ExpC3 - Codigo do vendedor                                 ³±±
±±³          ³ ExpD1 - Data da venda                                      ³±±
±±³          ³ ExpC4 - Hora da venda                                      ³±±
±±³          ³ ExpC5 - Cliente da venda     							  ³±±
±±³          ³ ExpC6 - Loja da venda        							  ³±±
±±³          ³ ExpC7 - Estacao da venda                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T.                   						              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD UpdVenda WSRECEIVE cCodigo		, cVend		, cDoc		, cEstacao	,;
							cPDV	 	, dData		, cHora		, cCliente	,;
							cLoja 		, cSerie		,cEmpPdv		,cFilPdv WSSEND cMessage WSSERVICE FRTValePre

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao
LjPreparaWs(cEmpPdv,cFilPdv) 

LjGrVVP( ::cCodigo	, ::cVend, ::cDoc , ::cEstacao,;
		 ::cPDV		, ::dData, ::cHora, ::cCliente,;
		 ::cLoja 	, ::cSerie, ::cEmpPdv, ::cFilPdv)

::cMessage := ""

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³UpdRecebto³ Autor ³ Venda Clientes        ³ Data ³18/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza os vales presentes vendidos            			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array com os codigos dos vales vendidos            ³±±
±±³          ³ ExpC1 - Caixa que recebeu o cupom                          ³±±
±±³          ³ ExpC2 - Numero do cupom fiscal da venda                    ³±±
±±³          ³ ExpC3 - Estacao da venda                                   ³±±
±±³          ³ ExpC4 - Codigo do PDV                                      ³±±
±±³          ³ ExpD1 - Data da venda                                      ³±±
±±³          ³ ExpC5 - Hora da venda                                      ³±±
±±³          ³ ExpC6 - Cliente da venda     							  ³±±
±±³          ³ ExpC7 - Loja da venda        							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T.                   						              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD UpdRecebto WSRECEIVE 	cCodigo		, cCaixa	, cDoc		, cEstacao	,;
								cPDV		, dData		, cHora		, cCliente	,;
								cLoja		, cSerie ,cEmpPdv		,cFilPdv	WSSEND cMessage WSSERVICE FRTValePre

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao
LjPreparaWs(cEmpPdv,cFilPdv) 

LjGrRVlPre(	::cCodigo	, ::cCaixa, ::cDoc , ::cEstacao,;
			::cPDV		, ::dData , ::cHora, ::cCliente,;
			::cLoja 	, ::cSerie)

::cMessage := ""

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³VldVale   ³ Autor ³ Venda Clientes        ³ Data ³23/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o codigo do vale informado                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto vale presente                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpC1 - Mensagem de erro (ou branco quando OK)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD ValorVale WSRECEIVE ValePre,cEmpPdv		,cFilPdv WSSEND nValor WSSERVICE FRTValePre

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao
LjPreparaWs(cEmpPdv,cFilPdv) 

::nValor := LjVPValor( ::ValePre:Codigo )
	
Return (.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³VPEstorna ³ Autor ³ Venda Clientes        ³ Data ³10/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recebe o Array e chama a funcao para o estorno do VP.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array contendo o Codigo e o tipo de oper a executar³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD VPEstorna WSRECEIVE  aVPreEst,cEmpPdv ,cFilPdv WSSEND cMessage WSSERVICE FRTValePre

Local lRet		:= .T.
Local aVerOk    := {}
Local nX 		:= 0

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao
LjPreparaWs(cEmpPdv,cFilPdv) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recebe o aVpEst que contem os VPs a serem estornados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len( ::aVPreEst:VerArray )
	AAdd( aVerOk, Array(2))
	aVerOk[nX][1] := ::aVPreEst:VerArray[nX]:cCodigo
	aVerOk[nX][2] := ::aVPreEst:VerArray[nX]:cOperacao
Next nX	

lRet	:= LjVpAtiva(aVerOk)

If !lRet
	SetSoapFault("Erro LjVpAtiva", "Erro LjVpAtiva")	
EndIf

::cMessage := ""
	
Return (lRet)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LjVpAtiva ³ Autor ³ Vendas Clientes       ³ Data ³ 22/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina para voltar o status do Vale Presente                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³WSFRTVP                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LjVpAtiva( aVPreEst )

Local lRet			:= .F.	// Retorno Logico
Local nX 			:= 0	// Variavel de contador
Local nTamCod  		:= 0	// Tamanho do campo L1_SERIE
Local nValorVP		:= 0	// Valor do Vale Presente

LjGrvLog( , "LjVpAtiva | Rotina para voltar o status do Vale Presente  -> Inicio " , )

If AliasIndic("MDD") .AND. Len(aVPreEst) > 0

	nTamCod  	:= TamSX3("MDD_CODIGO")[1] 
	DbSelectArea("MDD")
	DbSetOrder(1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Altera o Status do Vale Presente , Caso aVPreEst[nX][2] == 1  ³
	//³ Vale foi vendido , caso 2 ele foi usado como forma de pgto    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aVPreEst)
		
		LjGrvLog( , "LjVpAtiva | Busca na MDD -> " + xFilial("MDD") + PadR(aVPreEst[nX][1],nTamCod) , )

		If DbSeek( xFilial("MDD")+ PadR(aVPreEst[nX][1],nTamCod) ) 
			LjGrvLog( , "LjVpAtiva | Vale presente encontrado: " + xFilial("MDD")+ PadR(aVPreEst[nX][1],nTamCod) , )

			RecLock( "MDD", .F. )
			REPLACE MDD->MDD_CAIXA	WITH ""
			REPLACE MDD->MDD_LOJAR	WITH ""
			REPLACE MDD->MDD_DOCR	WITH ""
			REPLACE MDD->MDD_SERIR	WITH ""
			REPLACE MDD->MDD_ESTR	WITH ""
			REPLACE MDD->MDD_PDVR	WITH ""
			REPLACE MDD->MDD_DATAR	WITH CTOD("  /  /  ")
			REPLACE MDD->MDD_HORAR	WITH ""
			REPLACE MDD->MDD_CLIR	WITH ""
			REPLACE MDD->MDD_LJCLIR	WITH ""
			REPLACE MDD->MDD_STATUS	WITH aVPreEst[nX][2]    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso seja VP status "1" (vendido) zera tambem os campos da venda ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aVPreEst[nX][2] == "1"
				REPLACE MDD->MDD_DOCV	WITH ""
				REPLACE MDD->MDD_PDVV	WITH ""
				REPLACE MDD->MDD_SERIV	WITH ""
				REPLACE MDD->MDD_ESTV	WITH ""
				REPLACE MDD->MDD_DATAV	WITH CTOD("  /  /  ")
				REPLACE MDD->MDD_HORAV	WITH ""				
				REPLACE MDD->MDD_CLIV	WITH ""
				REPLACE MDD->MDD_LJCLIV	WITH ""	  
				REPLACE MDD->MDD_VEND	WITH ""
				REPLACE MDD->MDD_SALDO	WITH 0
			EndIf
			MDD->( MsUnlock() )
			lRet := .T.
		Else
			LjGrvLog( , "LjVpAtiva | Vale presente não encontrado: " + xFilial("MDD")+ PadR(aVPreEst[nX][1],nTamCod) , )
		EndIf
	Next nX	
Endif

LjGrvLog( , "LjVpAtiva | Rotina para voltar o status do Vale Presente  -> Fim | lRet: " + cValToChar( lRet ), )

Return(lRet)
