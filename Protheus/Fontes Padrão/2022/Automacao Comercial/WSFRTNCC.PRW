#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "WSFRTNCC.CH"
      
WSSTRUCT WSRetAberto
	WSDATA Seleciona	AS Boolean
	WSDATA Saldo		AS Float
	WSDATA NumTitulo	AS String
	WSDATA DataNCC   	AS Date			
	WSDATA NumRecno		AS Integer
	WSDATA Saldo2		AS Float
	WSDATA MvMoeda     	AS String
	WSDATA Moeda     	AS Integer
	WSDATA Prefixo     	AS String
	WSDATA Parcela		AS String
	WSDATA Tipo     	AS String
ENDWSSTRUCT

WSSTRUCT WSNCCItens
	WSDATA Seleciona	AS Boolean
	WSDATA Saldo		AS Float
	WSDATA NumTitulo	AS String
	WSDATA DataNCC   	AS Date			
	WSDATA NumRecno		AS Integer
	WSDATA Saldo2		AS Float
	WSDATA MvMoeda     	AS String
	WSDATA Moeda     	AS Integer
	WSDATA Prefixo     	AS String
	WSDATA Parcela		AS String
	WSDATA Tipo     	AS String
ENDWSSTRUCT

WSSTRUCT WSBanco
	WSDATA Codigo     	AS String
	WSDATA Moeda     	AS Integer
ENDWSSTRUCT 

WSSTRUCT WSNCCArray
	WSDATA VerArray AS ARRAY OF WSNCCItens
ENDWSSTRUCT

WSSTRUCT WSRecnoSE1
	WSDATA RecnoSE1 AS Integer OPTIONAL
ENDWSSTRUCT

WSSTRUCT WSSE1Array
	WSDATA RecArray AS ARRAY OF WSRecnoSE1 OPTIONAL
ENDWSSTRUCT  

WSSTRUCT WSVlrReceb
	WSDATA VlrReceb AS Float OPTIONAL
	WSDATA VlrMulta AS Float OPTIONAL
	WSDATA VlrJuros AS Float OPTIONAL	
	WSDATA VlrDesco AS Float OPTIONAL	
	WSDATA PosRgSE1	AS Float OPTIONAL		
ENDWSSTRUCT

WSSTRUCT WSReceb
	WSDATA RecArray AS ARRAY OF WSVlrReceb OPTIONAL
ENDWSSTRUCT 

WSSERVICE FRTNCC DESCRIPTION STR0001				//"Serviço de pesquisa de NCC em aberto"
	WSDATA aNCCAbert	  AS ARRAY OF WSRetAberto
	WSDATA cCliente		  AS String
	WSDATA cLojaCli		  AS String
	WSDATA cEnvelopes	  AS String OPTIONAL
	WSDATA cEmpPDV	  	  AS String OPTIONAL
	WSDATA cFilPDV	  	  AS String OPTIONAL
	WSDATA lMvLjPdvPa	  AS Boolean OPTIONAL
	WSDATA dDataValid	  AS Date OPTIONAL
	WSDATA lImport		  AS Boolean OPTIONAL
	WSDATA cNumOrc	  	  AS String OPTIONAL

	WSMETHOD FRTGETNCC		DESCRIPTION STR0002		//"Retornar as NCCs em aberto pelo cliente"

ENDWSSERVICE

WSSERVICE BAIXANCC DESCRIPTION  STR0003				//"Serviço de baixa da NCC" 

	WSDATA aNCCItens	AS WSNCCArray
	WSDATA nNccUsada 	AS Float
	WSDATA nNccGerada 	AS Float
	WSDATA cL1Doc 		AS String
	WSDATA cL1Serie 	AS String
	WSDATA cL1Oper 		AS String
	WSDATA dL1EmisNf	AS Date
	WSDATA cL1Cliente	AS String
	WSDATA cL1Loja		AS String
	WSDATA nL1Credit	AS Float
	WSDATA cSerEst		AS String
	WSDATA nNccGerRet	AS Float
	WSDATA cEmpPDV	    AS String  OPTIONAL
	WSDATA cFilPDV	  	AS String  OPTIONAL
	WSDATA lMvLjPdvPa	AS Boolean OPTIONAL 
	WSDATA aRecnoSE1    AS WSSE1Array OPTIONAL 
	WSDATA aVlrReceb    AS WSReceb OPTIONAL  
	WSDATA aBanco	  	AS ARRAY OF WSBanco OPTIONAL	
	WSDATA cL1Orc 		AS String  OPTIONAL
	
	WSMETHOD FRTGETSA6 DESCRIPTION "Metodo para realizar a consulta das informações do cadastro de Banco"		

	WSMETHOD FRTBXNCC DESCRIPTION "Metodo para realizar a baixa da NCC"
	
ENDWSSERVICE

WSSERVICE DELNCC DESCRIPTION  "Serviço de delecao da NCC" 

	WSDATA cBxFilial	AS String
	WSDATA cBxDoc		AS String
	WSDATA cBxSerie		AS String
	WSDATA cBxCliente	AS String
	WSDATA cBxLoja		AS String
	WSDATA NADA 		AS Boolean
	WSDATA cEmpPDV	  	AS String OPTIONAL
	WSDATA cFilPDV	  	AS String OPTIONAL
	WSDATA lMvLjPdvPa	AS Boolean OPTIONAL
	
	WSMETHOD FRTDELNCC DESCRIPTION "Metodo para realizar a delecao da NCC"
ENDWSSERVICE     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³FRTGETNCC ³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa de NCCs em aberto                      			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Cliente da venda     							  ³±±
±±³          ³ ExpC2 - Loja da venda        							  ³±±
±±³          ³ ExpC3 - String com os codigos dos envelopes SIGAPHOTO	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - NCC em aberto						              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD FRTGETNCC WSRECEIVE cCliente , cLojaCli , cEnvelopes, cEmpPDV,;
							 cFilPDV  , lMvLjPdvPa , dDataValid, lImport, cNumOrc WSSEND aNCCAbert WSSERVICE FRTNCC

Local aRet							//Retorno de funcao
Local nX	:= 0					//Controle de For

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao 
LjPreparaWs(::cEmpPDV,::cFilPDV)

aRet := FrtNCCLoad(	::cCliente,	::cLojaCli, ::cEnvelopes, ::dDataValid, ::lImport , ::cNumOrc )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna as NCCs em aberto para o cliente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aRet) > 0
	For nX := 1 To Len(aRet)    
		AAdd( ::aNCCAbert, WSClassNew("WSRetAberto") )	
		::aNCCAbert[nX]:Seleciona 	:= aRet[nX][1]
		::aNCCAbert[nX]:Saldo     	:= aRet[nX][2]
		::aNCCAbert[nX]:NumTitulo	:= aRet[nX][3]
		::aNCCAbert[nX]:DataNCC   	:= aRet[nX][4]
		::aNCCAbert[nX]:NumRecno  	:= aRet[nX][5]
		::aNCCAbert[nX]:Saldo2     	:= aRet[nX][6]
		::aNCCAbert[nX]:MvMoeda   	:= aRet[nX][7]
		::aNCCAbert[nX]:Moeda  		:= aRet[nX][8]
		::aNCCAbert[nX]:Prefixo 	:= aRet[nX][9]
		::aNCCAbert[nX]:Parcela 	:= aRet[nX][10]
		::aNCCAbert[nX]:Tipo      	:= aRet[nX][11]
	Next nX
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³FRTGETSA6 ³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna  a Moeda para Geração da NCC conforme Banco		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Código doBanco a     							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Código do Banco e Moeda				              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD FRTGETSA6 WSRECEIVE cL1Oper WSSEND aBanco WSSERVICE BAIXANCC 

Local lRet	:= .F.					//Retorno da Funcao 
Local nMoeda:= 0					//Moeda Utilizada

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao 
LjPreparaWs(::cEmpPDV,::cFilPDV)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procura o Banco conforme parametro      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA6->(DbSetOrder(1))
If cPaisLoc != "BRA"
	lRet 	:= .T. 
	If SA6->(DbSeek(xFilial("SA6") + cL1Oper + ".NCC" ))
		nMoeda  := Max(SA6->A6_MOEDA,1)	 
	Else
		nMoeda 	:= 1                	
	Endif
Else
	lRet 	:= .T. 
	nMoeda 	:= 1               

Endif 			

Aadd(::aBanco,WsClassNew("WSBanco"))				
::aBanco[1]:Codigo	:= cL1Oper
::aBanco[1]:Moeda	:= nMoeda

Return lRet 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FrtNCCLoad³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicia operacao para gravacao do LOG.           			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FrtNCCLoad(ExpC1,ExpC2)							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Cliente da venda     							  ³±±
±±³          ³ ExpC2 - Loja da venda        							  ³±±
±±³          ³ ExpC3 - String com o codigo dos envelopes SIGAPHOTO		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - NCCs do cliente  					              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FrtNCCLoad(cCliente, cLojaCli, cEnvelopes, dDataValid,lImport,cNumOrc)

Local nSaldoNCC   := 0									// Saldo da NCC
Local aNCCItens	  := {}									// Retorno
Local nMoedaCor	  := 1									// Moeda Corrente
Local nDecimais   := MsDecimais(nMoedaCor)				// Casas decimais que esta trabalhando o sistema
Local aCodEnvel   := {}                      			// Array com os codigos dos envelopes
Local lMvLjPhoto  := SuperGetMv("MV_LJPHOTO", ,.F.)    // Define se esta ativo o SIGAPHOTO
Local nCont       := 1									// Contador do For
Local lVldNCC     := .F.								// Indica se valida vencimento da NCC
Local bValBlock   := Nil								// Bloco para validacao de vencimento da NCC
Local cQuery  	  := ""
Local cAliasSE1   := "SE1"
Local lAchouSE1   := .F.
Local cFilSE1     := xFilial("SE1")
Local aAuxIN  	  := StrToArray(AllTrim(MV_CRNEG), ",")
Local cMVCRNegIN  := ""
Local nTamTIPO	  := TamSx3("E1_TIPO")[1]
Local bWhile 	  := {|| .F. }
Local lQuery 	  := .F.
Local lLjNCCOr	:= SuperGetMv("MV_LJNCCOR", Nil, .F.)  //verifica se a NCC sera mantida no orcamento (F4)

DEFAULT cEnvelopes  := ""                      			// String com os codigos dos envelopes SIGAPHOTO   
DEFAULT dDataValid  := cToD("  /  /  ")					// Data para verificar validade da NCC
DEFAULT lImport		:= .F.

aEval(aAuxIN, { |x| cMVCRNegIN += "'"+PadR(x,nTamTIPO)+"'," })
cMVCRNegIN := Left( cMVCRNegIN, Len(cMVCRNegIN)-1 )
If Empty(cMVCRNegIN)
	cMVCRNegIN := "' '"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Alimenta variavel de validacao da validade na NCC³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
lVldNCC  := SuperGetMV("MV_LJVLNCC",,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³SIGAPHOTO - Carregando o array com os codigos dos envelopes.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMvLjPhoto
	aCodEnvel := &(cEnvelopes)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa as NCCs em aberto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SE1")
DbSetOrder(8) //E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_STATUS, E1_VENCREA

#IFDEF TOP
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificar se eh AS/400, pois a coluna R_E_C_N_O_ nao existe em AS/400³
	//³dessa forma a condicao sera a do codebase.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( TcSrvType()<>"AS/400" )
		lQuery := .T.
		cAliasSE1 := "NCCFILSE1"
		
		cQuery := "SELECT E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_TIPO, E1_STATUS, SE1.R_E_C_N_O_ RECSE1"
		cQuery += " FROM " + RetSQLName("SE1") + " SE1 "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o parametro estiver habilitado retonar somente as NCC's definidas ³
		//³no orcamento na retaguarda , se for venda avulsa (sem orcamento)     ³
		//³trara as NCC's dos cliente                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lLjNCCOr .AND. lImport
			cQuery += " INNER JOIN " + RetSQLName("MDK") + " MDK ON  MDK.MDK_NUMREC = SE1.R_E_C_N_O_ AND MDK.D_E_L_E_T_ = ' ' "
			cQuery += " INNER JOIN " + RetSQLName("MDJ") + " MDJ ON MDJ.MDJ_FILIAL = MDK.MDK_FILIAL AND MDJ.D_E_L_E_T_ = ' ' "
			cQuery += " AND MDJ.MDJ_NUMORC = MDK.MDK_NUMORC "
			cQuery += "  AND MDJ.MDJ_SITUA = 'OR' AND MDJ.MDJ_NUMORC = '" + Alltrim(cNumOrc) +  "' "
		EndIf
		cQuery += " WHERE E1_FILIAL  = '"+cFilSE1+"'"
		cQuery += " AND E1_CLIENTE = '"+cCliente+"'"
		cQuery += " AND E1_LOJA    = '"+cLojaCli+"'"
		cQuery += " AND E1_STATUS  = 'A'" //A=Em Aberto
		If Len(aAuxIN) > 1
			cQuery += "   AND E1_TIPO IN ("+cMVCRNegIN+")"	
		Else
			cQuery += "   AND E1_TIPO = "+cMVCRNegIN
		EndIf
		cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE1,.F.,.F.)
		
		lAchouSE1 := (cAliasSE1)->( !EoF() )
		
		bWhile 	  := {|| !(cAliasSE1)->(EOF()) }
	Else
#ENDIF
		lAchouSE1 := DbSeek(cFilSE1 + cCliente + cLojaCli + "A")
		bWhile 	  := {|| !(cAliasSE1)->(EOF()) .AND. (cAliasSE1)->E1_FILIAL == cFilSE1 .AND. (cAliasSE1)->E1_CLIENTE == cCliente .AND. (cAliasSE1)->E1_LOJA == cLojaCli .AND. (cAliasSE1)->E1_STATUS == "A" }
#IFDEF TOP
	Endif
#ENDIF

If lAchouSE1
	
	While Eval(bWhile)
	
		If (cAliasSE1)->E1_TIPO $ MV_CRNEG   
			
			#IFDEF TOP
				If lQuery
					SE1->(DbGoTo((cAliasSE1)->RECSE1))
				EndIf
			#ENDIF
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³	Verifica se usa validade na NCC. Se usar Valida	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
			bValBlock := IIf(lVldNCC, {||SE1->E1_VENCREA >= dDataValid}, {||.T.} ) 
			If Eval(bValBlock)			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³SIGAPHOTO - Insere o valor de credito do consumidor caso o valor do SE1,³
				//³seja referente ao sinal de um envelope que estava no aCols.             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lMvLjPhoto
					If !Empty(SE1->E1_ENVELO)
						For nCont := 1 To Len(aCodEnvel)     
					   		If AllTrim(aCodEnvel[nCont]) == AllTrim(SE1->E1_ENVELO)
	
							    //Adiciona item no aNCCItens
								If FindFunction("LjNCCItens")
									LjNCCItens(@aNCCItens, Nil, nMoedaCor , nDecimais )
								EndIf	
					        EndIf
					    Next nCont    
						(cAliasSE1)->(dbSkip())
						Loop
					EndIf						
				EndIf
	
			    //Adiciona item no aNCCItens
				If FindFunction("LjNCCItens")			
					LjNCCItens(@aNCCItens, Nil)    
					// Se estiver utilizando NCC automatica, marca como selecionada no Array
					If lLjNCCOr .AND. lImport .AND. Len(aNCCItens) > 0
						aNCCItens[ Len(aNCCItens)][1] := .T.
					EndIf
				EndIf	  
				
			Endif
		EndIf
		(cAliasSE1)->(DbSkip())
		Loop
	End
EndIf

#IFDEF TOP
	If lQuery
		(cAliasSE1)->( dbCloseArea() )
		dbSelectArea("SE1")
	EndIf
#ENDIF


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordena aNCCitens³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aNCCItens) > 0
	aNCCItens := aSort(aNCCItens,,,{|x,y| x[4]<y[4]})
EndIf

Return aNCCItens

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³FRTBXNCC  ³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a baixa das NCCs selecionadas           			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - NCCs da venda        							  ³±±
±±³          ³ ExpN2 - NCC a baixar         							  ³±±
±±³          ³ ExpN3 - NCC a gerar          							  ³±±
±±³          ³ ExpC4 - Doc da venda         							  ³±±
±±³          ³ ExpC5 - Serie da venda       							  ³±±
±±³          ³ ExpC6 - Operador da venda    							  ³±±
±±³          ³ ExpD7 - Data de emissao      							  ³±±
±±³          ³ ExpC8 - Cliente da venda     							  ³±±
±±³          ³ ExpC9 - Loja da venda        							  ³±±
±±³          ³ ExpN10 - Credito utilizado    							  ³±±
±±³          ³ ExpC11 - Serie a gerar        							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T.                   						              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD FRTBXNCC WSRECEIVE aNCCItens	,	nNccUsada	,	nNccGerada	,	cL1Doc 		,;
							cL1Serie 	,	cL1Oper		,	dL1EmisNf	,	cL1Cliente	,;
							cL1Loja		,	nL1Credit	,	cSerEst		, 	cEmpPDV		,; 
							cFilPDV		,   lMvLjPdvPa	,	aRecnoSE1	,	aVlrReceb 	 ,;
							cL1Orc  WSSEND nNccGerRet WSSERVICE BAIXANCC

Local aVerOk	:= {}								//NCC selecionadas
Local nX		:= 0								//Contador de For
Local cDocCred	:= ""								//Documento credito
Local nRecnoSE1	:= 0								//Recno do SE1
Local lRet		:= .T.								//Retorno da funcao
Local nValorGer	:= 0								//Valor gerado  
Local aRcnSE1	:= {} 
Local aVlrRcb	:= {}
Local lBxNcc	:= .F.
Local lLjNCCOr	:= .F.  //verifica se a NCC sera mantida no orcamento (F4)
Local aAreaSl1 	:= {}

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao 
LjPreparaWs(::cEmpPDV,::cFilPDV)

Private lMsErroAuto := .F. 							//Tratamento de erro de rotina automatica
Private lMsHelpAuto := .T.							//Tratamento para erro

lLjNCCOr	:= SuperGetMv("MV_LJNCCOR", Nil, .F.)  //verifica se a NCC sera mantida no orcamento (F4)
aAreaSl1 	:= SL1->(GetArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recebe o aRcnSE1  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len( ::aRecnoSE1:RecArray )
	aAdd(aRcnSE1,::aRecnoSE1:RecArray[nX]:RecnoSE1)
Next nX	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recebe o aVlrRcb  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len( ::aVlrReceb:RecArray )                                                
	aAdd(aVlrRcb,{::aVlrReceb:RecArray[nX]:VlrReceb, ::aVlrReceb:RecArray[nX]:VlrMulta, ::aVlrReceb:RecArray[nX]:VlrJuros,;
	 			  ::aVlrReceb:RecArray[nX]:VlrDesco, ::aVlrReceb:RecArray[nX]:PosRgSE1})
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recebe o aNCCitens³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len( ::aNCCItens:VerArray )
	AAdd( aVerOk, Array( 11 ))
	aVerOk[nX][1] := ::aNCCItens:VerArray[nX]:Seleciona
	aVerOk[nX][2] := ::aNCCItens:VerArray[nX]:Saldo
	aVerOk[nX][3] := ::aNCCItens:VerArray[nX]:NumTitulo
	aVerOk[nX][4] := ::aNCCItens:VerArray[nX]:DataNCC
	aVerOk[nX][5] := ::aNCCItens:VerArray[nX]:NumRecno
	aVerOk[nX][6] := ::aNCCItens:VerArray[nX]:Saldo2
	aVerOk[nX][7] := ::aNCCItens:VerArray[nX]:MvMoeda
	aVerOk[nX][8] := ::aNCCItens:VerArray[nX]:Moeda
	aVerOk[nX][9] := ::aNCCItens:VerArray[nX]:Prefixo
	aVerOk[nX][10]:= ::aNCCItens:VerArray[nX]:Parcela
	aVerOk[nX][11]:= ::aNCCItens:VerArray[nX]:Tipo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se as NCC estao baixadas, se todas estiverem baixadas nao executa o restante da rotina³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aVerOk[nX][1] .AND. LjWsNccBx(aVerOk[nX][5])
		lBxNcc := .T.
		Exit
	EndIf		
Next nX	

If !lBxNcc
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclui tipo CR para as NCCs usadas na venda³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. Empty(aRcnSE1)
		lRet := 	FrtIncluiCR(	::cSerEst		,	@cDocCred		,	@nRecnoSE1	,	::cL1Doc	,;
									::cL1Serie		,	::cL1Cliente	,	::cL1Loja	,	::nL1Credit	,;
									::cL1Oper		, 	::nNccUsada		, 	::nNccGerada, 	aVerOk	 )
	
		If !lRet
			SetSoapFault("Erro FrtIncluiCR", "Erro FrtIncluiCR")	
		EndIf
	
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera nova NCC para o cliente, caso seja necessario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .AND. ::nNccGerada > 0
		lRet := 	FrtIncluiNCC( 	aVerOk		, 	::nNccUsada	, 	::nNccGerada 	, 	::cL1Doc		,;
									::cSerEst	,	::cL1Oper	,	::dL1EmisNf		,	::cL1Cliente	,;	
									::cL1Loja	,	@nValorGer	)
	
		::nNccGerRet := nValorGer
		
		If !lRet
			SetSoapFault("Erro FrtIncluiNCC", "Erro FrtIncluiNCC")	
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclui a compensacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		lRet :=	FrtInMovNCC(	aVerOk	,	nRecnoSE1,  cL1Oper, aRcnSE1, aVlrRcb  )
	EndIf
EndIf

If lRet .OR. lBxNcc
	If ValType(::cFilPDV) <> "C"
		::cFilPDV := cFilAnt	
	EndIf
		
	If lRet .AND. ValType(::cFilPDV) == "C"
		DbSelectArea("MDJ")
		//deleta MDJ que marca uso da NCC vinda do orcamento na retaguarda...
		If lLjNccOr
			If Empty(::cL1Orc) // Veio via job , a retaguarda estava off no momento da baixa pelo pdv
				dbSelectArea("SL1")
				SL1->(dbSetOrder(2))  // FILIAL+SERIE+DOC+PDV
				If SL1->(dbSeek(::cFilPDV + ::cL1Serie+::cL1Doc))
					::cL1Orc := SL1->L1_NUM
				EndIf
				RestArea(aAreaSL1)
			EndIf

			MDJ->(DbSetOrder(3)) 		//MDJ->MDJ_FILIAL + MDJ->MDJ_NUMORC
			If   MDJ->(DbSeek(::cFilPDV + ::cL1Orc))
				RecLock("MDJ",.F.)
				MDJ->(dbDelete())
				MsUnlock()
			EndIf
		EndIf

		//Esta busca eh necessario para marcar a MDJ gerada por tentativas de baixa na retaguarda
		MDJ->(DbSetOrder(1)) 		//MDJ->MDJ_FILIAL + MDJ->MDJ_DOC + MDJ->MDJ_SERIE + MDJ->MDJ_CLIENT + MDJ->MDJ_LOJA
		If MDJ->(DbSeek(::cFilPDV + ::cL1Doc + ::cL1Serie + ::cL1Cliente+ ::cL1Loja))
			RecLock("MDJ",.F.)
			REPLACE MDJ_SITUA WITH "OK"
			MDJ->(MsUnlock())
		EndIf

	EndIf
EndIf	

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³FrtIncluiN³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclui nova NCC para o cliente (Automatico pelo Fina040)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FrtIncluiNCC(ExpA1,ExpN2,ExpN3,ExpC4,ExpC5,ExpC6,ExpD7	  ³±±
±±³       	 ³ 				ExpC8,ExpC9)						          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - NCCs da venda        							  ³±±
±±³          ³ ExpN2 - NCC usada            							  ³±±
±±³          ³ ExpN3 - NCC a gerar          							  ³±±
±±³          ³ ExpC4 - Documento da venda   							  ³±±
±±³          ³ ExpC5 - Serie da nova NCC    							  ³±±
±±³          ³ ExpC6 - Operador             							  ³±±
±±³          ³ ExpD7 - Data de emissao      							  ³±±
±±³          ³ ExpC8 - Cliente da venda     							  ³±±
±±³          ³ ExpC9 - Loja da venda        							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpL1 - Se executou perfeitamente			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FrtIncluiNCC(	aNCCItens	,	nNccUsada	,	nNccGerada	,	cL1Doc		,;
					 			cSerEst 	, 	cL1Oper		,	dL1EmisNf	,	cL1Cliente	,;	
					 			cL1Loja		,	nValorGer, lIntegDef	)
Local nContaNCC		:= 0													//Contador de FOR
Local nValorNCC		:= 0													//Valor da NCC a gerar
Local cParcela 		:= PadR(SuperGetMV("MV_1DUP"), TamSX3("E1_PARCELA")[1] ) 			// Ajusta de acordo com o tamanho do E1_PARCELA
Local cMVNATNCC		:= AllTrim(&(SuperGetMV("MV_NATNCC")))
Local aVetor		:= {}													//Dados para a rotina automatica
Local lRet 			:= .T.													//Retorno da rotina automatica
Local nTPCompNCC    := SuperGetMV("MV_LJCPNCC",,1)			    			//Tratamento para compensacao de NCC 1 - INCLUSAO DE NOVO TITULO 2 - ALTERACAO DO SALDO 3 - BAIXA TOTAL DA NCC 4 - SALDO DA NCC COM TROCO
Local nX            := 0
Local nRndMoed1 	:= MsDecimais(1)										// Arredondamento para localizacoes
Local aLogRotAut    := {}
Local aDadosBanc	:= {}													//array com dados de ag e conta CADASTRADOS NA SA6
Local aAreas		:= {}

Default lIntegDef	:= IIF(type("SL1->L1_ORIGEM") == "C",SL1->L1_ORIGEM == "N",.F.)	//Venda Origem Integração

cPaisLoc			:= SuperGetMV("MV_PAISLOC", ,"BRA")						// atribuimos a variavel publica cPaisLoc o valor do parametro MV_PAISLOC, pois quando a funcao e executada em webservices, a variavel assume o valor padrao ("BRA")

//Redefinimos a variavel Private lMsErroAuto, pois se chamado de outro fonte, seu conteudo sera Nil
lMsErroAuto			:= .F.

If Empty(cL1Doc) 
	nTPCompNCC := 2
EndIf

If nTPCompNCC <> 2
	DbSelectArea("SE1")
	SE1->( DbSetOrder(1) )	//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	While SE1->(DbSeek(xFilial("SE1") + cSerEst + cL1Doc + cParcela + "NCC"))
		cParcela := CHR(ASC(cParcela)+1)
	End
		
	/**** Valor que deve ser baixado das NCC's ****/
	nValorNCC = nNccUsada - nNccGerada
	lAutoErrNoFile := .T.
	
	LjGrvLog(cL1Doc, " Indice da SE1 [E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO] + [" +;
	 			xFilial("SE1") + cSerEst + cL1Doc + cParcela + "NCC" + "]")
	
	LjGrvLog(cL1Doc, " Array da NCC ", aNCCItens)
	
	/****** Loop para reinserir que foram selecionadas na
	       venda porem ainda possuem saldo       *******/
	For nContaNCC := 1 to Len(aNCCItens)            
		/****** Verifica se a NCC foi selecionada para ser utilizada *****/
		If aNCCItens[nContaNCC][1] .AND. lRet	
			/****** Caso ja tenha atingido o valor a ser utilizado 
					as demais NCC's nao serao baixadas               ******/
			If nValorNCC == 0
				
				LjGrvLog(cL1Doc, " Valor de NCC igual a zero ")				
				aNCCItens[nContaNCC][1] := .F.
	
			/*se o Valor da NCC atual foi menor ou igual a que sera utilzado a 
			NCC sera completamente utilizada e nao gera nova NCC            */
			ElseIf nValorNCC >= aNCCItens[nContaNCC][2] .AND. !lIntegDef // pular esse If lIntegDef para integração Sempre cria NCC 
				LjGrvLog(cL1Doc, " Valor de NCC usado maior/igual que o valor  da NCC do banco")
				nValorNCC -= aNCCItens[nContaNCC][2] 
			Elseif (nTPCompNCC == 3  .OR.  nTPCompNCC == 4) .And. !lIntegDef // pular esse If lIntegDef para integração Sempre cria NCC 			
				nValor	:= Round(xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,1,dDataBase,nRndMoed1+1),nRndMoed1)
				LjGrvLog(cL1Doc, " NCC - nTPCompNCC com 3/4 ", nTPCompNCC)
				LjGrvLog(cL1Doc, " Saldo de NCC ", nValor)	
			Else
				LjGrvLog(cL1Doc, " Será gerado um novo SE1 ")

				If Empty(cMVNATNCC)
					Conout("Função FrtIncluiNCC - Preencha o parâmetro MV_NATNCC com uma natureza válida para que seja possível gerar o SE1")
					LjGrvLog(cL1Doc," Preencha o parâmetro MV_NATNCC com uma natureza válida para que seja possível gerar o SE1")
					lRet := .F.
				EndIf	
				
				If lRet
					nValorGer := aNCCItens[nContaNCC][2] - nValorNCC
		
					aAdd(aVetor,{"E1_PREFIXO"	,cSerEst											,Nil})
					aAdd(aVetor,{"E1_NUM"	  	,cL1Doc 											,Nil})
					aAdd(aVetor,{"E1_PARCELA" 	,cParcela											,Nil})
					aAdd(aVetor,{"E1_NATUREZ" 	,cMVNATNCC											,Nil})
					aAdd(aVetor,{"E1_TIPO" 		,"NCC"												,Nil})
					aAdd(aVetor,{"E1_EMISSAO"	,aNCCItens[nContaNCC][4]							,Nil})
					aAdd(aVetor,{"E1_VALOR"		,nValorGer											,Nil})
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se usar data de validade na NCC altera data de vencimento da NCC	   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SuperGetMV("MV_LJVLNCC",,.F.)
						aAdd(aVetor,{"E1_VENCTO"	,(dDataBase + SuperGetMV("MV_LJDTNCC",,0))					,Nil})
						aAdd(aVetor,{"E1_VENCREA"	,DataValida((dDataBase + SuperGetMV("MV_LJDTNCC",,0)),.T.)	,Nil})						
					Else
						aAdd(aVetor,{"E1_VENCTO"	,dL1EmisNf											,Nil})
						aAdd(aVetor,{"E1_VENCREA"	,DataValida(dL1EmisNf,.T.)							,Nil})	
					Endif
									
					aAdd(aVetor,{"E1_VENCORI"	,dL1EmisNf											,Nil})
					aAdd(aVetor,{"E1_SALDO"		,nValorGer											,Nil})
					aAdd(aVetor,{"E1_VLCRUZ"	,xMoeda(nValorGer,1,1,aNCCItens[nContaNCC][4])		,Nil})
					aAdd(aVetor,{"E1_CLIENTE"	,cL1Cliente											,Nil})
					aAdd(aVetor,{"E1_LOJA"		,cL1Loja											,Nil})
		
					If cPaisLoc <> "BRA"
						DbSelectArea("SA6")
						Aadd(aAreas, SA6->(GetArea()))
						SA6->(DbSetOrder(1))
						If SA6->(DbSeek( xFilial("SA6") + cL1Oper + "." + "NCC" ))
							aAdd(aVetor,{"E1_MOEDA"		,Max(SA6->A6_MOEDA,1)						,Nil })
						Else
							aAdd(aVetor,{"E1_MOEDA"		,1											,Nil })
						EndIf
		 			Else
						aAdd(aVetor,{"E1_MOEDA"		,1												,Nil })
					EndIf
		
					aAdd(aVetor,{"E1_STATUS"		,If(nValorGer > 0.01,"A","B")					,Nil })
					aAdd(aVetor,{"E1_ORIGEM"		,"FRTA010"										,Nil })
					aAdd(aVetor,{"E1_MULTNAT"		,"2"											,Nil })
					aAdd(aVetor,{"E1_FLUXO"			,"N"											,Nil })
					aAdd(aVetor,{"E1_BASCOM1"		,xMoeda(nValorGer,1,1,aNCCItens[nContaNCC][4])	,Nil })
		
					/***** Inclui via rotina automatica ****/
					LjGrvLog(cL1Doc, " Antes da Chamada do FINA040", aVetor)
					MSExecAuto({|x,y| Fina040(x,y)},aVetor,3)
					LjGrvLog(cL1Doc, " Depois da Chamada do FINA040 - Erro de ExecAuto?", lMsErroAuto)
		
					DbSelectArea("SE1")
					SE1->(DbSetOrder(2)) //E1+FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
					If SE1->(DbSeek(xFilial("SE1") + cL1Cliente + cL1Loja + cSerEst + cL1Doc + cParcela + "NCC"))
						LjGrvLog(cL1Doc, " Registro na SE1 - Registro Encontrado : " +; 
									xFilial("SE1") + cL1Cliente + cL1Loja + cSerEst + cL1Doc + cParcela + "NCC")
	
						LjGrvLog(cL1Doc, " RecLock SE1- alterando histórico")
						aDadosBanc := GetAdvFVal( "SA6", { "A6_AGENCIA", "A6_NUMCON" },xFilial("SA6")+cL1Oper, 1, { ".", "."} )		//³ Busca AG e conta cadastrados na SA6
						
						RecLock("SE1",.F.)
						
						REPLACE SE1->E1_HIST With 	xFilial("SE1") 				+ ;
													aNCCItens[nContaNCC][9] 	+ ;
													aNCCItens[nContaNCC][3] 	+ ;
													aNCCItens[nContaNCC][10] 	+ ;
													aNCCItens[nContaNCC][11]
						
						SE1->E1_PORTADO 	:= cL1Oper
						SE1->E1_AGEDEP 		:= aDadosBanc[1]
						SE1->(MsUnlock()) 				
						MsUnLock()
					Else
						LjGrvLog(cL1Doc, " Registro na SE1 - Registro NÃO Encontrado : " +; 
									xFilial("SE1") + cL1Cliente + cL1Loja + cSerEst + cL1Doc + cParcela + "NCC")
					EndIf	
		
					/**** Zera a Variavel de saldo restante da NCC para que as demais NCC nao sejam utilizadas ***/
					nValorNCC := 0
					
					/***** Apresenta mensagem de erro caso a rotina automatica nao seja executada. Desfaz a transacao ****/
					If lMsErroAuto
					    DisarmTransaction()  
	       				aLogRotAut := GetAutoGrLog()                                   
				    	If Len(aLogRotAut) > 0 .AND. ValType(aLogRotAut[1]) == "C"
							Conout("WSFRTNCC - Erro WS: " + aLogRotAut[1])
							LjGrvLog(cL1Doc, "WSFRTNCC - Erro WS: " + aLogRotAut[1] )			       
						EndIf
						lRet := .F.
					EndIf
				EndIf		
			EndIf
		EndIf
	
	Next nContaNCC 
Else
	nValorGer := nNccGerada	 
EndIf

For nX := 1 to Len(aAreas)
	RestArea(aAreas[nX])
Next nX

Return lRet

//-------------------------------------------------------------------
/*/ {Protheus.doc} STDNCCOffline
Quando o cupom de NCC eh utilizado, sem acesso a retaguarda, o PDV nao consegue preencher todas as informacoes necessarias para
realizar a baixa da NCC. Esta funcao serve para preencher as informacoes que faltam no array usado para dar a baixa das NCCs utilizadas.

@param   	
@author  	Varejo
@version 	P11.8
@since   	17/01/2014
@return  	aNCCs = Array com as informacoes das NCCs utilizadas
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDNCCOffline( aNCCs )
Local aArea := GetArea()
Local nX    := 0

DbSelectArea("SE1")
SE1->(DbSetOrder()) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

For nX := 1 To Len( aNCCs )

	If DbSeek( xFilial("SE1")+aNCCs[nX,9]+aNCCs[nX,3]+"A"+"NCC" )
		
		aNCCs[nX,2] := SE1->E1_SALDO 
		aNCCs[nX,4] := SE1->E1_EMISSAO
		aNCCs[nX,5] := SE1->(Recno()) 
		aNCCs[nX,6] := SE1->E1_SALDO 
		aNCCs[nX,8] := SE1->E1_MOEDA
		
	EndIf

Next nX

RestArea( aArea )

Return aNCCs


//-------------------------------------------------------------------
/*/ {Protheus.doc} STWBOBxNCC
Realiza a baixa das NCCs selecionadas, dentro da retaguarda

@param   	
@author  	Varejo
@version 	P11.8
@since   	05/03/2013
@return  	lRet - Retorna se realizou a baixa
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWBOBxNCC( aNCCs     , nValorUsado, nNccGerada, cL1Doc   ,;
				     cSerEst   , cL1Serie   , cL1Oper   , dL1EmisNf,; 
				     cL1Cliente, cL1Loja    , nL1Credit , lOffline  )

Local nValorGer		:= 0   // Valor gerado (Compatibilidade)
Local cDocCred		:= ""  // Documento credito
Local nRecnoSE1		:= 0   // Recno do SE1
Local lRet          := .T. // Retorno da funcao

If lOffline

	aNCCs := STDNCCOffline( aNCCs )

EndIf

LjGrvLog( "L1_NUM: " + cL1Doc, "Baixa NCC RET", /*xVar*/ ) //Grava Log =====================================================================
/*
	Gera nova NCC para o cliente, caso seja necessario
*/
LjGrvLog( "L1_NUM: " + cL1Doc, "NCC gerada RET", nNccGerada ) //Grava Log =====================================================================

If nNccGerada < 0
	
	lRet := STBNCCInc( aNCCs  , nValorUsado, Abs(nNccGerada), cL1Doc	,;
                       cSerEst, cL1Oper	   , dL1EmisNf      , cL1Cliente,;	
                       cL1Loja, @nValorGer )
	LjGrvLog( "L1_NUM: " + cL1Doc, "Conseguiu dar baixa na NCC RET", lRet ) //Grava Log =====================================================================                      
		
EndIf

/*
	Inclui tipo CR para as NCCs usadas na venda
*/

If lRet

	lRet := FrtIncluiCR( cSerEst , cDocCred	  ,	@nRecnoSE1	, cL1Doc	,;
                         cL1Serie, cL1Cliente ,	cL1Loja     , nL1Credit	,;
                         cL1Oper , nValorUsado, nNccGerada  , aNCCs )
                                         
	LjGrvLog( "L1_NUM: " + cL1Doc, "Inclui compesação RET", lRet ) //Grava Log =====================================================================             
                         
EndIf

/*
	Inclui a compensacao
*/

If lRet

	lRet :=	FrtInMovNCC( aNCCs, nRecnoSE1, cL1Oper )
	LjGrvLog( "L1_NUM: " + cL1Doc, "Inclui movimentos na SE5 RET", lRet ) //Grava Log =====================================================================
EndIf 

Return lRet					

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FrtIncluiC³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclui a compensacao das NCCs (Automatico pelo Fina040)	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FrtIncluiCR(ExpC1,ExpC2,ExpN3,ExpC4,ExpC5,ExpC6,ExpC7	  ³±±
±±³       	 ³ 				ExpC8,ExpC9)						          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Serie para o CR      							  ³±±
±±³          ³ ExpN2 - Documento            							  ³±±
±±³          ³ ExpN3 - Recno do SE1         							  ³±±
±±³          ³ ExpC4 - Documento do SL1     							  ³±±
±±³          ³ ExpC5 - Serie da venda       							  ³±±
±±³          ³ ExpC6 - Cliente da venda     							  ³±±
±±³          ³ ExpD7 - Loja da venda        							  ³±±
±±³          ³ ExpC8 - Credito a gerar      							  ³±±
±±³          ³ ExpC9 - Operador             							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpL1 - Se executou perfeitamente			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FrtIncluiCR(	cSerEst		,	cDocCred	,	nRecnoSE1	,	cL1Doc		,;
								cL1Serie	,	cL1Cliente	,	cL1Loja		,	nL1Credit	,;
								cL1Oper, nNccUsada	, 	nNccGerada	, aVerOk )
 

Local cNatureza 	:= ""							  //Natureza
Local cAgenciaCx    := ""							  //Agencia a gerar
Local nTamA6_AGENCIA:= TamSX3("A6_AGENCIA")[1]		  //Tamanho do campo
Local nRndMoed1 	:= MsDecimais(1)				  //MsDecimais
Local nMoedaCor		:= 1 							  //MoedaCor
Local aVetor		:= {}							  //Dados para a rotina automatica
Local lRet			:= .T.							  //Retorno  
Local nTPCompNCC    := SuperGetMV("MV_LJCPNCC",,1)	  //Tratamento para compensacao de NCC 1 - INCLUSAO DE NOVO TITULO 2 - ALTERACAO DO SALDO 3 - BAIXA TOTAL DA NCC 4 - SALDO DA NCC COM TROCO
Local nX            := 0                              // Auxiliar para o For
Local nI            := 0                              // Auxiliar para adicao no array   
Local c1DUP 		:= PadR(SuperGetMV("MV_1DUP"), TamSX3("E1_PARCELA")[1] ) 			// Ajusta de acordo com o tamanho do E1_PARCELA
Local cMemoLog		:= ""
Local aDadosBanc	:= {}							//array com dados de ag e conta CADASTRADOS NA SA6	

Default cL1Serie 	:= ""							  //Serie
Default cDocCred	:= ""							  //Documento
Default nRecnoSE1	:= 0							  //Recno no SE1
Default nNccUsada   := 0                              //Valor Inicial da NCC usada
Default nNccGerada  := 0                              //Valor utilizado da NCC
Default aVerOk      := {}                             //Array com as NCC
cPaisLoc			:= SuperGetMV("MV_PAISLOC", ,"BRA") // atribuimos a variavel publica cPaisLoc o valor do parametro MV_PAISLOC, pois quando a funcao e executada em webservices, a variavel assume o valor padrao ("BRA")
c1DUP := PadR( c1DUP, TamSX3("E1_PARCELA")[1] )

If nTPCompNCC == 2
	nL1Credit := nNccUsada  - nNccGerada
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa a variavel³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lMsErroAuto := .F. 
aDadosBanc := GetAdvFVal( "SA6", { "A6_AGENCIA", "A6_NUMCON" },xFilial("SA6")+cL1Oper, 1, { ".", "."} )		//³ Busca AG e conta cadastrados na SA6
cAgenciaCx :=aDadosBanc[1] 

DbSelectArea("SE1")
DbSetOrder(1)
While SE1->(DbSeek(xFilial("SE1") + cSerEst + cL1Doc + c1DUP + "CR" ))
	c1DUP := CHR(ASC(c1DUP)+1)
End

//Antes pegava a natureza do SX5, agora segue o padrao do financeiro e pega do parametro  
cNatureza := &(SuperGetMV("MV_NATCRED"))
If Empty(cNatureza)
	cNatureza := "CREDITO"
EndIf 

LjIncSED(@cNatureza) // Verifica se existe a natureza 

aAdd(aVetor,{"E1_PREFIXO"	,cSerEst													,Nil})	
aAdd(aVetor,{"E1_NUM"		,cL1Doc  													,Nil})
aAdd(aVetor,{"E1_PARCELA"	,c1DUP														,Nil})
aAdd(aVetor,{"E1_TIPO"		,"CR"														,Nil})
aAdd(aVetor,{"E1_NATUREZ"	,cNatureza													,Nil})
aAdd(aVetor,{"E1_CLIENTE"	,cL1Cliente													,Nil})
aAdd(aVetor,{"E1_LOJA"		,cL1Loja													,Nil})
aAdd(aVetor,{"E1_EMISSAO"	,dDataBase													,Nil})
aAdd(aVetor,{"E1_VENCTO"	,dDataBase													,Nil})
aAdd(aVetor,{"E1_VENCREA"	,DataValida(dDataBase)										,Nil})
aAdd(aVetor,{"E1_MOEDA"		,nMoedaCor													,Nil})
aAdd(aVetor,{"E1_ORIGEM"	,"FRTA010"													,Nil})
aAdd(aVetor,{"E1_VALOR"		,nL1Credit  												,Nil})
aAdd(aVetor,{"E1_NUMNOTA"	,cL1Doc														,Nil})
aAdd(aVetor,{"E1_SERIE"		,cL1Serie													,Nil})
aAdd(aVetor,{"E1_STATUS"	,"A"														,Nil})
Aadd(aVetor,{"E1_SALDO"		,nL1Credit   												,Nil})
Aadd(aVetor,{"E1_FILORIG"	,cFilAnt													,Nil})
Aadd(aVetor,{"E1_VLCRUZ"	,Round(xMoeda(nL1Credit,nMoedaCor,1,dDataBase),nRndMoed1)	,Nil})
Aadd(aVetor,{"E1_BASCOM1"	,Round(xMoeda(nL1Credit,nMoedaCor,1,dDataBase),nRndMoed1)	,Nil})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa inclusao via rotina automatica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MSExecAuto({|x,y| Fina040(x,y)},aVetor,3) 

If lMsErroAuto
    DisarmTransaction()
	lRet:= .F.
	cMemoLog :=MemoRead(NomeAutoLog())	// Pega detalhes do erro da execauto
	LjGrvLog(cL1Doc,"Detalhes do problema na inclusao do CR",cMemoLog)
Else
	LjGrvLog(cL1Doc,"CR Incluido com sucesso")
	nRecnoSE1 := SE1->(Recno())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Armazena dados do CR gerado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDocCred := SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_LOJA
	
	SE1->(DbSetOrder(2)) //E1+FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If SE1->(DbSeek(xFilial("SE1") + cL1Cliente + cL1Loja + cSerEst + cL1Doc + c1DUP + "CR"))
	
		RecLock('SE1',.F.)
		SE1->E1_PORTADO := cL1Oper
		SE1->E1_AGEDEP := cAgenciaCx
		SE1->(MsUnlock())
	Endif 	
	
	
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FrtInMovNC³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclui movimentos no SE5 (automaticamente pelo MaIntBxCR)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FrtInMovNCC(ExpC1,ExpC2)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - NCCs utilizadas      							  ³±±
±±³          ³ ExpN2 - Recno do SE1 gerado  							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil                         		      		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FrtInMovNCC( aNccItens,	nRecnoSE1, cL1Oper, aRecnoSE1, aVlrReceb )

Local nX           				//Contador de For
Local aSE1Cps		:= {}		//SE1 a compensar
Local aSE1			:= {}		//Compensacao a gerar
Local aForSE1		:= {}		//Recnos que devem ser alterados
Local lRet          := .F. 
Local bGravaMoeda               
Local lFrtAtuaSE1	:= ExistFunc("FrtAtuaSE1")
Local aDadosBanc	:= {}		//array com dados de ag e conta CADASTRADOS NA SA6

DEFAULT aRecnoSE1 := {}
DEFAULT aVlrReceb := {}

For nX := 1 to Len(aNccItens)
	If aNccItens[nX][1]     
		Aadd( aSE1	 , aNccItens[nX][5] )    				
		Aadd( aForSE1, aNccItens[nX][5] ) 	   				
	EndIf
Next nX                         
                     
// Atualiza E1_MULTA, E1_JUROS e E1_DESCONT                             
If lFrtAtuaSE1 	// Se retornar falso nem entra no For
	For nX:=1 to Len(aVlrReceb)        
		If aVlrReceb[nX][2]>0 .OR. aVlrReceb[nX][3]>0 .OR. aVlrReceb[nX][4]>0
			FrtAtuaSE1(aVlrReceb, nX)
		Endif	
	Next nX	
Endif	

Aadd( aSE1Cps, nRecnoSE1 )    				
Aadd( aForSE1, nRecnoSE1 )    				

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza automaticamente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aRecnoSE1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o bloco de codigo que sera' utilizado para gravar o campo     ³
	//³ E5_MOEDA na compensacao das NCCs                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bGravaMoeda := { || (RecLock("SE5",.F.),SE5->E5_MOEDA := "CR",MsUnlock()) } 
	lRet := MaIntBxCR( 3, aRecnoSE1, Nil, aSE1     , Nil, Nil, bGravaMoeda, Nil, Nil, Nil, Nil, Nil,, )
Else
	lRet := MaIntBxCR( 3, aSE1Cps, Nil, aSE1)
EndIf                               

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava o Banco, Agencia e Conta no SE5, pois a funcao³
//³MaIntBxCr nao grava                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aForSE1)

	DbSelectArea("SE1")
	DbGoTo(aForSE1[nX])
    DbSelectArea("SE5")
	DbSetOrder(7)

	If DbSeek(xFilial("SE5") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA)
		While !EOF() .AND. xFilial("SE5") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA == ;
							SE5->E5_FILIAL + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + SE5->E5_CLIFOR + SE5->E5_LOJA
			SE5->(DbSkip())
			Loop

		End
		SE5->(DbSkip(-1))
		RecLock("SE5",.F.)
		aDadosBanc := GetAdvFVal( "SA6", { "A6_AGENCIA", "A6_NUMCON" },xFilial("SA6")+cL1Oper, 1, { ".", "."} )		//³ Busca AG e conta cadastrados na SA6
		Replace SE5->E5_BANCO 	With cL1Oper
		Replace SE5->E5_AGENCIA	With aDadosBanc[1]
		Replace SE5->E5_CONTA	With aDadosBanc[2]
 		MsUnLock()
	EndIf

Next nX

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³FRTDELNCC ³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Estorna as NCCs geradas                         			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial da venda      							  ³±±
±±³          ³ ExpC2 - Documento            							  ³±±
±±³          ³ ExpC3 - Serie                							  ³±±
±±³          ³ ExpC4 - Cliente              							  ³±±
±±³          ³ ExpC5 - Loja                 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T.                   						              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

WSMETHOD FRTDELNCC WSRECEIVE cBxFilial	,	cBxDoc	,	cBxSerie	,	cBxCliente,;
							 cBxLoja    , cEmpPDV   , cFilPDV       , 	lMvLjPdvPa	;
							 WSSEND NADA WSSERVICE DELNCC

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao LjPreparaWs
If !Empty(::cEmpPdv) .And. !Empty(::cFilPdv)
	LjPreparaWs(::cEmpPDV,::cFilPDV)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza rotina para estornar a NCC³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FrtNCCExc( 	::cBxFilial	,  ::cBxDoc	 ,  ::cBxSerie  ,  ::cBxCliente  ,;
			::cBxLoja 	)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FrtNCCExc ³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama a rotina Fina330 para estornar NCCs e compensacao    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FrtNCCExc(ExpC1,ExpC2,ExpC3,ExpC4,ExpC6)					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial da venda      							  ³±±
±±³          ³ ExpC2 - Documento            							  ³±±
±±³          ³ ExpC3 - Serie                							  ³±±
±±³          ³ ExpC4 - Cliente              							  ³±±
±±³          ³ ExpC5 - Loja                 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil                         		      		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FrtNCCExc( cBxFilial,cBxDoc,cBxSerie,cBxCliente,cBxLoja )

Local cParcela 		:= SuperGetMV("MV_1DUP")
Local nTamL1Doc	    := TamSX3("L1_DOC")[1]			//Tamanho do campo
Local nTamE1Parc    := TamSX3("E1_PARCELA")[1]		//Tamanho do campo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona no SE1 antes de executar o FINA330 ,		  ³
//³Ajusta o tamanho dos campos L1_DOC e E1_PARCELA		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cBxDoc     	:= PadR( cBxDoc   , nTamL1Doc )
cParcela	:= PadR( cParcela , nTamE1Parc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona no SE1 antes de executar o FINA330³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SE1")
DbSetOrder(1)
If DbSeek(xFilial("SE1") + cBxSerie + cBxDoc + cParcela + 'CR ')
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fina330        ³
	//³ 5  - Estorno  ³
	//³.T.- Automatico³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Fina330(5,.T.)    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao para atualizar o SL4 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AtualSL4( cBxSerie, cBxDoc )

EndIf     

Return NIL    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³AtualSL4 	³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Faz a compensacao do valor da NCC no SL4 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AtualSL4(ExpC1,ExpC2)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Serie 			      							  ³±±
±±³          ³ ExpC2 - Documento            							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil                         		      		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AtualSL4( cBxSerie 	, cBxDoc  )

Local lRecLock	:= .T.				// Define se inclui ou altera um determinado registro na tabela
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³De Acordo com o  dados do  SL1  inclui  o valor da     ³
//³parcela da NCC na forma de pagamento do Orcamento (SL4)³
//³Isso porque o valor da parcela NCC nao esta no SL4.	  ³
//³obs:Somente para orcamentos originados na retaguarda   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SL1")
DbSetOrder(2)                       // L1_FILIAL + L1_SERIE + L1_DOC
If DbSeek( xFilial( "SL1" )+cBxSerie + cBxDoc) 
	DbSelectArea( "SL4" )
	DbSetOrder( 1 )					// L4_FILIAL + L4_NUM
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a venda foi paga somente por NCC,sera gerado    ³
	//³ou alteredo o registrono SL4 com a forma dinheiro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SL1->L1_CREDITO == SL1->L1_VLRTOT
		If SL4->(DbSeek( xFilial( "SL4" ) + SL1->L1_NUM))
			lRecLock	:= .F.
		EndIf                                              
		RecLock("SL4",lRecLock)
		REPLACE	L4_FILIAL 	WITH	xFilial("SL4")
		REPLACE	L4_NUM		WITH	SL1->L1_NUM
		REPLACE	L4_DATA 	WITH    SL1->L1_EMISSAO
		REPLACE	L4_VALOR	WITH	SL1->L1_VLRTOT
		REPLACE	L4_FORMA	WITH	SuperGetMV("MV_SIMB1",,"")
		MsUnLock()
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Soma o valor da NCC na primeira parcela do SL4³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SL4->(DbSeek( xFilial( "SL4" ) + SL1->L1_NUM))
			RecLock("SL4",.F.)
			REPLACE	L4_VALOR	WITH	SL4->L4_VALOR + SL1->L1_CREDITO
			MsUnLock()
		EndIf
	EndIf
EndIf

Return(NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LjWsNccBx	³ Autor ³ Venda Clientes        ³ Data ³09/05/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a NCC ja foi baixada na retaguarda			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjWsNccBx(nRecE1Ncc)
Local lRet	:= .F.

DbSelectArea("SE1")
DbGoto(nRecE1Ncc)
If Recno() = nRecE1Ncc
	If SE1->E1_SALDO = 0 .AND. AllTrim(SE1->E1_STATUS) == "B" .AND. AllTrim(SE1->E1_TIPO) == "NCC"
		lRet := .T.		
    EndIf
EndIf
Return(lRet)					

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/* {Protheus.doc} STWBxNCC
Realiza a baixa das NCCs selecionadas 

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	05/03/2013
@return  	
@obs     
@sample
*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

Function STBNCCInc(aNCCItens	,	nNccUsada	,	nNccGerada	,	cL1Doc		,;
					 			cSerEst 	, 	cL1Oper		,	dL1EmisNf	,	cL1Cliente	,;	
					 			cL1Loja		,	nValorGer)
Local lRet := .F.

Private lMsErroAuto := .F. 			//Tratamento de erro de rotina automatica (Compatibilidade)
Private lMsHelpAuto := .T.			//Tratamento para erro (Compatibilidade)

lRet := FrtIncluiNCC(	aNCCItens	,	nNccUsada	,	nNccGerada	,	cL1Doc		,;
					 			cSerEst 	, 	cL1Oper		,	dL1EmisNf	,	cL1Cliente	,;	
					 			cL1Loja		,	nValorGer	)

Return lRet

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/* {Protheus.doc} LjIncSED
Realiza a inclusão de naturezas caso a mesma nao exista 
@since   	15/08/2015
*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Static Function LjIncSED(cNatCr)

LOCAL aArray 	:= {}
Local cMvCred	:= ""

DbSelectArea("SED")
DbSetOrder(1)	//ED_FILIAL+ED_CODIGO
If !DbSeek(xFilial("SED")+cNatCr)
	// Se nao encontrou vai tentar buscar pelo parametro 
	cMvCred := &(SuperGetMV("MV_NATCRED"))
	DbSelectArea("SED")
	DbSetOrder(1)	//ED_FILIAL+ED_CODIGO
	
	If !DbSeek(xFilial("SED")+cMvCred)
		// Se nao encontrou tb no parametro cria essa natureza
		lMsErroAuto := .F.
		 
		aArray := { { "ED_CODIGO"  , cNatCr     , NIL },;
		            { "ED_DESCRIC" , cNatCr		, NIL },;
		            { "ED_CALCIFR" , "N"        , NIL },;
		            { "ED_CALCISS" , "N"        , NIL },;
		            { "ED_CALCINS" , "N"        , NIL },;
		            { "ED_CALCCSL" , "N"        , NIL },;
		            { "ED_CALCCOF" , "N"        , NIL },;
		            { "ED_CALCPIS" , "N"        , NIL },;
		            { "ED_DEDPIS"  , "2"        , NIL },;
		            { "ED_DEDCOF"  , "2"        , NIL } }
		 
		MsExecAuto( { |x,y| FINA010(x,y)} , aArray, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
		
		If lMsErroAuto
			LjGrvLog("", "Inclui movimentos na SE5 RET", lRet ) 
		    MostraErro()
		Endif
	Else
		cNatCr := cMvCred // Se encontrou no pamaretro gera com essa natureza
	EndIf	
EndIf

Return
