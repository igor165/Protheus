#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA590.CH"   

Static aProdSC	        := {}  //Array com produtos a fazer solicitacao de compras
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOJA590   ºAutor  ³Vendas Clientes     º Data ³  05/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Contem funcoes da Venda com reserva sem estoque            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaloja		                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
                                                                                   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LA590VlEtqºAutor  ³  Vendas Clientes   º Data ³  05/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida produtos sem estoque permitindo fazer reserva		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA2 - Array com as informacoes do Listbox                 º±±
±±º          ³        ExpA2[1] - True ou False (para o ListBox)           º±±
±±º          ³        ExpA2[2] - Codigo da Loja                           º±±
±±º          ³        ExpA2[3] - Nome da Loja                             º±±
±±º          ³        ExpA2[4] - Codigo do Produto                        º±±
±±º          ³        ExpA2[5] - Array com a qtd em Estoque               º±±
±±º          ³        			    [1]-Local                             º±±
±±º          ³                      [2]-Qtde Estoque                      º±±
±±º          ³        ExpA2[6] - Quantidade a Reservar                    º±±
±±º          ³        ExpA2[7] - Texto para ser mostrado no ListBox       º±±
±±º          ³        ExpA2[8] - Numero do item na aCols                  º±±
±±º          ³        ExpA2[9] - Armazem                                  º±±
±±º          ³                                                            º±±
±±º          ³ExpN3 - Numero da linha do listbox em que o usuario esta    º±±
±±º          ³        posicionado.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL1 - Logico. Se .T. - Faz a reserva sem estoque          º±±
±±º          ³                Se .F. - Nao faz a reserva sem estoque      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja/FrontLoja	                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 										         
Function LA590VlEtq(aEstoque, nLinha) 

Local lRet 	   		:= .F.																				 // Retorno da funcao
Local aSalIni   	:= {}        																		 // Array com produto a fazer execauto dos saldos iniciais
Local cStartPath    := GetSrvProfString("Startpath","")													 // Startpath
Local cFilBk		:= cFilAnt																			 // Backup da Falial
Local cFilEnt 		:= Iif(Len(aEstoque[nLinha]) >= 10 .AND. !Empty(aEstoque[nLinha][10]), aEstoque[nLinha][10] , cFilAnt ) // Filial desejada para reserva

Default aEstoque 	:= {}       	// Arraay de estoque
Default nLinha		:= 0        	// Numero da linha 

PRIVATE lMsErroAuto	:= .F.			//Determina se houve algum tipo de erro durante a execucao do ExecAuto

If  (Type("lAutoExec") == "U")
 	lAutoExec   := .F.
EndIf 	
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o produto existe fisicamente na tabela de estoque  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					  
If Len(aEstoque) > 0 .AND. (nLinha > 0) .AND. ValType(aEstoque[nLinha][5]) == "A"
	cFilAnt := cFilEnt //Seleciono a Filial desejada para reserva
	
	DbSelectArea("SB2")
	DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL
	If !(DbSeek(xFilial("SB2")+aEstoque[nLinha][4]+aEstoque[nLinha][5][1][1],.T.))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para o produto que nao existe fisicamente no SB2, e para³
		//³nao parar o processo no ato da geracao da venda, entao  ³
		//³sera criado um registro "zerado" no SB2                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  lAutoExec .OR. MsgYesNo(STR0001) //"Faltam informacoes deste produto. Deseja gerar Saldo Inicial para este produto com valor zerado automaticamente?"
			Aadd(aSalIni,{"B9_FILIAL"  	,xFilial("SB9")  				,Nil })		//01 - Filial do sistema
			Aadd(aSalIni,{"B9_COD"    	,aEstoque[nLinha][4]			,Nil })		//02 - Codigo do produto
			Aadd(aSalIni,{"B9_LOCAL" 	,aEstoque[nLinha][5][1][1]		,Nil })		//01 - Local do produto
			Aadd(aSalIni,{"B9_QINI"    	,0								,Nil })		//02 - Quantidade Inicial
			
			MSExecAuto({|x,y| MATA220(x,y)},aSalIni,3)	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se houveram erros durante a execucao da rotina automatica.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lMsErroAuto
				DisarmTransaction()               
				If  lAutoExec
					ConOut(MostraErro(cStartPath))
				Else	
					MostraErro()
				EndIf
			Else
				lRet := .T.			
			Endif	
	   	Endif
	EndIf	                	
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametro de verificacao se ira ser a solicitacao de compra³
	//³automatica ou nao (se ira fazer a pergunta)                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SuperGetMv("MV_LJGERSC",,1) == 3    
   		If  lAutoExec .OR. MsgYesNo(STR0002) //"Saldo insuficiente em estoque. Deseja gerar uma solicitacao de compras ao gerar o orcamento?"
    		lRet := .T.	             
    	Else
    		lRet := .F.	
   		Endif
	
   	ElseIf SuperGetMv("MV_LJGERSC",,1) == 4 
   		//Caso 4 Permite vender sem estoque e não gera solicitacao de compras
   		//neste caso a empresa assume o risco de trabalhar com estoque negativo
   	  	lRet := .T.	
   	Else
   	 	MsgAlert(STR0003)//"Saldo insuficiente em estoque. Sera gerada uma solicitação de compras ao gerar o orcamento."	
   		lRet := .T.
   	EndIf	                	
	 											 					
	cFilAnt := cFilBk 											 				
Endif						

Return(lRet)
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LA590ProSC  ºAutor³Vendas Clientes     º Data ³  05/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega Array aProdSC com os Itens da reserva a gerar       º±± 
±±º          ³solicitacao de compras									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ExpC1 := LA590ProSC( ExpA1, ExpN1, ExpC2 ) 		          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1 - Array contendo                                      º±±
±±º          ³        [1] - Item do produto na aCols                      º±±
±±º          ³        [2] - Codigo do produto                             º±±
±±º          ³        [3] - Quantidade                                    º±±
±±º          ³        [4] - Array contendo                                º±±
±±º          ³              [1] - Local                                   º±±
±±º          ³              [2] - Quantidade em estoque                   º±±
±±º          ³        [5] - Armazem onde sera feita a reserva             º±±
±±º          ³ExpN1 - Numero da linha do laco em que o usuario esta    	  º±±
±±º          ³ExpC2 - Codigo da filial para ser efetuada a reserva        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nil											              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaloja                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LA590ProSC( aReserva, nX, cFilRes )

Local nPosEntr		:= 0	// Posicao do tipo de Entrega
Local nPosDatEnt    := 0	// Posicao da data de Entrega
Local nPosDescPr	:= 0	// Posicao da descricao do produto
Local cDescPr		:= ""	// Descricao do produto
Local nPosUmProd    := 0	// Posicao da unidade de medida do produto
Local cUmProd    	:= ""	// Unidade de medida do produto
Local nPosLocal		:= 0	// Posicao do armazem onde sera feita a reserva
Local nQtdSolCom	:= 0    // Quantidade que sera utilizada na solicitacao de compra
Local lAutoExec		:= IsBlind() //execucao sem tela
Local nLjDatSC		:= SuperGetMv("MV_LJDATSC",,0)//Quantidade de dias somado a database para entrega da solicitação de compras
Local lIntegDef		:= IsInCallStack("LOJI701") .Or. Lj701GtInD() // Venda Origem Integração  RafaelPessoa  
Local cLocRes		:= "" 	//Local da Reserva
Local nPosReserva	:= 0  	//Posicao do código da Reserva no Acols		
Local aItem			:= {}
Local nNumItem		:= FR271BPegaIT(aReserva[nX][1])	// Número do Item	

Default aReserva 	:= {}        // Array da reserva
Default nX			:= 0         // Numero da linha do laco
Default cFilRes		:= ""        // Filial da reserva

//CASO SEJA CHAMADO PELO ADAPTER DE RESERVA NÃO DEVE SER
//AVALIADO ESTE PROCESSO.
If IsInCallStack("LOJI704")
	CONOUT("LOJA590 - RETORNO ADAPTER LOJI704 - NAO É NECESSARIO GERAR SC NESSE PONTO")
	LjGrvLog("LOJA590","RETORNO ADAPTER LOJI704 - NAO GERAR SC NESSE NA RESERVA")
	Return Nil
Endif

//CASO O PROCESSO SEJA INTEGRAÇÃO LOJI701 - GERACAO DO ORCAMENTO
//E NECESSARIO REMONTAR O ARRAY COM OS DADOS DA RESERVA
If lIntegDef
	CONOUT("LOJA590 - CHAMADA LJ590SCIN - GERAÇÃO DE SC DE INTEGRACAO")
	LjGrvLog("LOJA590","CHAMADA LJ590SCIN - GERAÇÃO DE SC DE INTEGRACAO")
	
	LJ590SCIN(aReserva,nX,cFilRes)

	Return Nil
Endif
	

If lAutoExec .OR. Type("aHeader") == "U" //seiji
	cDescPr := POSICIONE("SB1", 1, xFilial("SB1") + aReserva[nX][2], "B1_DESC")
	cUmProd := POSICIONE("SB1", 1, xFilial("SB1") + aReserva[nX][2], "B1_UM")
Else
	nPosEntr	:= Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_ENTREGA"})	// Posicao do tipo de Entrega
	nPosDatEnt  := Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_FDTENTR"})	// Posicao da data de Entrega
	nPosDescPr	:= Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_DESCRI"})	// Posicao da descricao do produto
	nPosUmProd  := Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_UM"})		// Posicao da unidade de medida do produto
	cDescPr		:= aCols[nNumItem][nPosDescPr]									// Descrição do Produto
	cUmProd		:= aCols[nNumItem][nPosUmProd]									// Unidade de Medida do Produto	
EndIf


If !Empty(cDescPr) .AND. !Empty(cUmProd) .AND. Len(aReserva) > 0 .AND. (nX > 0) .AND. ValType(aReserva[nX][4]) == "A"

	//Procuramos pelo Armazem, Lote, Sublote, Endereço e Numero de Serie que foi realizado a reservada
	nPosLocal := Ascan( aReserva[nX][4], {|x| x[1]+AllTrim(x[3])+AllTrim(x[4])+AllTrim(x[5])+AllTrim(x[6]) ==;
	 	aReserva[nX][5]+AllTrim(aReserva[nX][6][2])+AllTrim(aReserva[nX][6][1])+AllTrim(aReserva[nX][6][3])+AllTrim(aReserva[nX][6][4]) } ) 

	//Verificamos se a quantidade requisitada eh maior que a quantidade presente no armazem escolhido
	If nPosLocal > 0 .AND. aReserva[nX][3] > aReserva[nX][4][nPosLocal][2]
       
		// se a quantidade do armazem escolhido for negativo
		If aReserva[nX][4][nPosLocal][2] < 0
			nQtdSolCom := aReserva[nX][3]	//geramos a SC somente com a quantidade da venda
		Else
			//caso contrario, ele soh gera a SC com a diferenca do saldo disponivel
			nQtdSolCom := aReserva[nX][3] - aReserva[nX][4][nPosLocal][2]
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega Array aProdSC para gerar solicitacao de compras  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aProdSC, {	aReserva[nX][2]							  		,;	//01 - Codigo do Produto
						cDescPr											,;	//02 - Descricao do produto
						cUmProd											,;	//03 - Unidade de medida do produto
						aReserva[nX][4][nPosLocal][1]			 		,;	//04 - Armazen do produto
						nQtdSolCom										,;	//05 - Quantidade
						cFilRes		   							 		,;	//06 - Filial da reserva
						dDatabase + nLjDatSC							,;	//07 - Data da Entrega
						aReserva[nX][1]									})	//08 - Posicao do produto na aCols
		
		If (nPosEntr > 0) .AND. (nPosDatEnt > 0)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se esta usando entrega. Se estiver assume ³
			//³a database + dias do parametro MV_LJDATSC     	  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
			If  aCols[nNumItem][nPosEntr] == "3" .And. Type("bRefresh") <> "U" .And. nLjDatSC > 0
				aCols[nNumItem][nPosDatEnt] := dDatabase + nLjDatSC 
				Eval(bRefresh)
			EndIf
		EndIf

	EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LA590SetSCºAutor  ³  Vendas Clientes   º Data ³  05/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Seta o valor do parametro para o array aProdSC		      º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ ExpA1 - Array com produtos a fazer solicitacao de compras  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nil										                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja				                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 		
Function LA590SetSC(aSC)

Default aSC := {}  // Array com produtos a fazer solicitacao de compras

aProdSC := aClone(aSC)          

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LA590GtaSCºAutor  ³  Vendas Clientes   º Data ³  05/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o array aProdSC		      						  º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpA1 - Retorna array aProdSC   		                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja				                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function LA590GtaSC()

Return aProdSC        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LA590GerSCºAutor  ³  Vendas Clientes   º Data ³  05/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz solicitacao de compra para itens da reserva sem estoqueº±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nil							   		                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja				                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function LA590GerSC()  

Local lRet          := .T.
Local nX 			:= 1																//Contador do While, deve ser iniciado com 1
Local aSC1	        := {}  																//Array com as solicitacoes de compra a serem geradas
Local aCabSC1	    := {}  																//Array com cabecalho da solicitacao de compra
local aItSC1		:= {}																//Array com os itens da solicitacao de compra
Local aItOrig		:= {}																//Array com os valores da coluna Itens do aColsDet
Local nPosSolCom    := Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_SOLCOM"})		//Posicao do numero da solicitacao de compra gerado para reserva sem estoque
Local cMsgSC        := ""																//Mensagem para o usuario informando que gerou SC(Solicitacao de Compras)
Local nPos			:= 0																//Posicao do aCols que se refere ao elemento do array aProdSC
Local nI			:= 0																//Contador do For
Local aAuxProdSc	:= {}																//Array auxiliar para armazenar os itens validos do array aProdSC
Local bOrdem		:= {}																//bloco de codigo que contem a ordenacao a ser usada
Local nTamSC1It		:= TamSX3("C1_ITEM")[1]												//tamanho do campo C1_ITEM
Local cFilAntBkp	:= xFilial("SC1")													//backup da filial corrente, pois ao gerar o ExecAuto, setamos CFILANT manualmente
Local cFilAux		:= ""																//variavel auxiliar para armazenar a filial onde a solicitacao de compra sera gerada
Local cC1Aprov		:= IIf(SuperGetMv("MV_LJAPRSC",,.F.),"L","")						//indica se a solicitacao de compra sera criada como aprovada
Local nIt			:= 0																//numero do item a ser utilizado pelos itens da solicitacao de compra
Local cStartPath    := GetSrvProfString("Startpath","")
Local nPosAux		:= 0																//Posicao dos itens na Solicitacao de Compras
Local lIntegDef		:= IsInCallStack("LOJI701")  .Or. Lj701GtInD()                      // Venda Origem Integração RafaelPessoa
Local cCCustoPd		:= SuperGetMV("MV_LJSCCC",,"")		 								//Centro de Custo Padrao Para Geracao de Solicitacao de Compra 
Local aHeaderBKP 	:= {}
Local cNumSC1		:= ""																//Guarda o número da Solicitação de Compras

PRIVATE lMsErroAuto	:= .F.																//Determina se houve algum tipo de erro durante a execucao do ExecAuto

If  (Type("lAutoExec") == "U")
 	lAutoExec   := .F.
EndIf 	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ESTRUTURA DO VETOR aSC1 - Vetor de solicitacoes de compras   ³
//³	aSC1[n][1] - cabecalho utilizado no MSAutoExec              ³
//³	aSC1[n][2] - vetor com os itens utilizados no MSAutoExec    ³
//³	aSC1[n][3] - vetor com o valor da coluna Item do aCols      ³
//³	aSC1[n][4] - filial onde a solicitacao de compra sera gerada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificamos se alguma linha foi deletada, pois se foi, teremos|
//|que a excluir do array que vai gerar as solicitacoes de compra³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIntegDef
	LA590ProSC()
Endif


For nI := 1 to Len(aProdSC)
	//Busca no array aAuxProdSC itens iguais, considera sempre o ultimo pois o primeiro
	nPosAux := aScan( aAuxProdSC, {|x| x[8] == aProdSC[nI][8]} )
		
	If nPosAux > 0
		aDel(aAuxProdSC, nPosAux)
		aSize(aAuxProdSC, Len(aAuxProdSC)-1) 
	EndIf
	
	//buscamos no aCols, a linha que vai gerar a solicitacao de compra
	nPos := aScan( aCols, {|x| x[1] == aProdSC[nI][8]} )

	//se a linha do aCols nao foi deletada, adicionamos ao array de itens validos
	If nPos > 0 .AND. !Atail(aCols[nPos])
		Aadd(aAuxProdSC, aProdSC[nI])
	EndIf
Next nI

//Restauramos o array aProdSC, mas agora com os itens validos
aProdSC := aClone(aAuxProdSC)

//Se aProdSC nao for vazio gera solicitacao de compras
If !Empty(aProdSC)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Organizamos o array aProdSC pelas filiais onde serao geradas as solicitacoes |
	//| de compra, pois com isso, criamos uma solicitacao de compra por Filial.		|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bOrdem := { |x,y| x[6] < y[6] }	//organizamos as filiais por ordem crescente
	ASort( aProdSC, Nil, Nil, bOrdem )
	
	While nX <= Len(aProdSC)

		cFilAux := aProdSC[nX][6]	//filial onde a solicitacao de compra sera criada
		cNumSC1	:= ""		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|Alimentamos o vetor com o cabecalho da solicitacao de compra|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aCabSC1,{"C1_EMISSAO"	, dDatabase					, Nil })	//01 - Database do sistema
		Aadd(aCabSC1,{"C1_SOLICIT"	, CriaVar('C1_SOLICIT',.T.)	, Nil })	//02 - Solicitante
		Aadd(aCabSC1,{"C1_FILENT"	, cFilAux					, Nil })	//03 - Filial de entrega 
		
		//para cada solicitacao de compra, resetamos o numero do item
		nIt := 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|Alimentamos o vetor com os itens da solicitacao de compra|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While nX <= Len(aProdSC) .AND. cFilAux == aProdSC[nX][6]
			nIt++	//a cada produto da solicitacao de compra, incrementamos o item(C1_ITEM)

			Aadd( aItSC1, {	{"C1_FILIAL"    ,cFilAux		 			,Nil },;	//01 - Filial onde sera gerada a solicitacao de compra
							{"C1_ITEM" 		,PadL(nIt,nTamSC1It,"0")	,Nil },;	//02 - Numero do item
							{"C1_PRODUTO" 	,aProdSC[nX][1] 			,Nil },;	//03 - Produto
							{"C1_UM"   		,aProdSC[nX][3]    			,Nil },;	//04 - Unidade de medida
							{"C1_QUANT"   	,aProdSC[nX][5]    			,Nil },;	//05 - Quantidade a ser feita SC
							{"C1_DATPRF"   	,DDATABASE 					,Nil },;	//06 - Database do sistema
							{"C1_LOCAL"   	,aProdSC[nX][4]    			,Nil },;	//07 - Armazen do produto
							{"C1_EMISSAO"   ,DDATABASE 					,Nil },;	//08 - Database do sistema
							{"C1_DESCRI"   	,aProdSC[nX][2]    			,Nil },;	//09 - Descricao do produto
							{"C1_QTDORIG"   ,aProdSC[nX][5] 			,Nil },;	//11 - Quantidade a ser feita SC
							{"C1_TIPO"   	,1 							,Nil },;	//12 - Tipo
							{"C1_APROV"   	,cC1Aprov					,Nil },;	//13 - Solicitacao de compra aprovada? "L" = Sim. "Vazio" = Nao
							{"C1_DATPRF" 	,aProdSC[nX][7]				,Nil },;	//14 - Database + Conteudo MV_LJDATSC
							{"C1_ORCAM" 	,M->LQ_NUM					,Nil },;	//15 - Numero do Orcamento
							{"C1_CC" 		,cCCustoPd					,Nil }})	//16 - Centro de Custo Padrao	

			//armazenamos o numero do Item no aCols, pois precisaremos dele para atualizar o campo LR_SOLCOM
			Aadd( aItOrig, FR271BPegaIT(aProdSC[nX][8]) )
			nX++
		EndDo

		//armazenamos a solicitacao de compra no array aSC1
		Aadd( aSC1, {aCabSC1, aItSC1, aItOrig, cFilAux} )

		//resetamos os vetores auxiliares
		aCabSC1 := {}
		aItSC1	:= {}
		aItOrig	:= {}
	EndDo	

	If Type("aHeader") <> "U"
		aHeaderBKP 	:= aClone(aHeader)
		aHeader := {}
	EndIf

    //Grava todas as solicitações de compra ou nada
    Begin Transaction

        //Criamos as Solicitacoes de Compra, via MSExecAuto
        For nX := 1 to Len(aSC1)

            //Setamos CFILANT, pois o MSExecAuto utiliza xFilial()
            CFILANT := aSC1[nX][4]

            MSExecAuto( {|x,y,z| MATA110(x,y,z)}, aSC1[nX][1], aSC1[nX][2], 3 )

            //Verifica se houveram erros durante a execucao da rotina automatica.
            If lMsErroAuto
                lRet := .F.
                DisarmTransaction()

                If lAutoExec
                    ConOut(MostraErro(cStartPath))
                Else	
                    MostraErro()
                EndIf

                Exit
            Else
				/*
					Neste ponto, é passado para inserção na tabela SC1, um registro por vez do array aSC1
					Após o retorno MSExecAuto, o registro posicionado é o que acabou ser gerado na Soliciatação de Compras (SC1).
				*/
				cNumSC1	:= SC1->C1_NUM	// Guarda número da SC para utilizar na atualização do aColsDet

                If nPosSolCom > 0	
                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³ Monta mensagem   ³
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
                    cMsgSC += STR0008 + aSC1[nX][4] + CHR(10)		//"Para a Filial: "

                    //"Foi gerada a Solicitação de Compras número: "	#" com os itens: "
                    cMsgSC += STR0004 + cNumSC1 + STR0005 + CHR(10)

                    For nI := 1 To Len( aSC1[nX][2] )
                        //buscamos a linha do aCols pelo numero do item, pois alimentamos o campo LR_SOLCOM
                        aColsDet[ aSC1[nX][3][nI] ][nPosSolCom] := cNumSC1

                        //"Produto: " + PRODUTO - DESCRICAO	#" Quantidade: " + QUANTIDADE
                        cMsgSC +=	STR0006 + AllTrim(aSC1[nX][2][nI][3][2]) + " - " + aSC1[nX][2][nI][9][2] +;
                                    STR0007 + CValToChar( aSC1[nX][2][nI][5][2] ) + CHR(10)
                    Next nI
                Endif

            Endif
        Next nX

    End Transaction

	If Len(aHeaderBKP) > 0
		aHeader := aClone(aHeaderBKP)
	EndIf

    If lRet

        //Mensagem ao usuario informando o numero e itens da SC gerada
        If !lAutoExec .And. !Empty(cMsgSC)
            LA590Msg( , cMsgSC)
        EndIf	

        //Limpa array com produtos a fazer Solicitacao de compras 		
        LA590SetSC()
    EndIf

	//restauramos CFILANT
	CFILANT := cFilAntBkp	
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LA590CncSCºAutor  ³Vendas Clientes     º Data ³  23/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua o Cancelamento da Solicitacao de Compra gerada      º±±
±±º          ³ atraves da rotina de Reservas.                   		  º±±  
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ ExpC1 - Numero orcamento com SC	                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±  
±±ºRetorno   ³ ExpL1 - Logico. Se .T. - Cancelou SC                       º±±
±±º          ³                 Se .F. - Nao Cancelou SC				      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaloja                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LA590CncSC(cNumOrcam,cFilSL1)

Local nX 			:= 0					//Variavel auxiliar
Local aCab			:= {}					//Cabecalho da Solicitacao de compras
Local aItem			:= {}					//Itens da solicitacao de compras 
Local lRet			:= .F.					//Variavel de Retorno da Funcao
Local aCancSC		:= {}             		//Solicitacao de compra ja canceladas
Local nPosNumSC   	:= 0	// Posicao da solicitacao de compra
Local nPosFil   	:= 0	// Posicao da FILIAL de Reserva
Local cFilBkp		:= ""                   // Utilizada para guardar o BKP da filial
Local cMsgSC		:= ""						//Mensagem para Solicitação de Compra
Local aProduto	:= {}						//Variável para leitura de itens excluídos
Local nI 			:= 0					//Variavel auxiliar

Default cNumOrcam	:= ""					//numero do orcamento
Default cFilSL1		:= cFilAnt

PRIVATE lMsErroAuto	:= .F.					//Determina se houve algum tipo de erro durante a execucao do ExecAuto

If  (Type("lAutoExec") == "U")
 	lAutoExec   := .F.
EndIf 	

If !(lAutoExec .OR. Type("aHeader") == "U") 
	nPosNumSC   	:= aScan(aHeader,{|x| Alltrim(Upper(x[2]))=="L2_SOLCOM"})
	nPosFil   	:= aScan(aHeader,{|x| Alltrim(Upper(x[2]))=="L2_FILRES"})
EndIf

If nPosNumSC > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Varre o aCols para cancelar as solicitacaoes de compras  ³    
	//³pois em uma venda pode existir itens com SC diferentes   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len( aCols ) 
		If !Empty(aCols[nX][nPosNumSC]) .AND. aScan(aCancSC,{|x| x[1]==aCols[nX][nPosNumSC]}) == 0 
			If !Empty(aCols[nX][nPosFil])  	//Se tiver utiliza a filial do aCols 
				cFilSL1 := aCols[nX][nPosFil]
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Limpa o campo C1_ORCAM para permitir a exclusao      ³
			//³da Solicitação de Compra quando deletado um orçamento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SC1")
			DbSetOrder(1) //C1_FILIAL+C1_NUM+C1_ITEM
			If DbSeek(cFilSL1+aCols[nX][nPosNumSC])
				While !Eof() .AND. (SC1->C1_FILIAL == cFilSL1) .AND. (SC1->C1_NUM == aCols[nX][nPosNumSC])
					aAdd(aProduto,{ SC1->C1_PRODUTO, SC1->C1_DESCRI, SC1->C1_QUANT })
					RecLock('SC1',.F.)  
					REPLACE C1_ORCAM WITH ""
					MsUnLock()
					DbSkip()
				End
				
				cFilBkp := cFilAnt  // Troca a Filial pois a rotina automatica nao encontra
			    cFilAnt := cFilSL1 	// a exclusao em outra filial e nao exclui o pedido de compras
			    
				AADD(aCab ,{"C1_NUM"	,aCols[nX][nPosNumSC] ,Nil})
				AADD(aItem,{{"C1_NUM"	,aCols[nX][nPosNumSC] ,Nil}})
				
				MSExecAuto({|x,y,z| MATA110(x,y,z)},aCab,aItem,5)		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se houveram erros durante a execucao da rotina automatica.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lMsErroAuto
					DisarmTransaction()
					MostraErro()
				Else	
					cMsgSC += STR0008 + cFilSL1 + CHR(10)						//"Para a Filial: "
					cMsgSC += STR0009 + aCols[nX][nPosNumSC] + STR0005 + CHR(10)		//"Foi excluída a Solicitação de Compras número: "	#" com os itens: "
					//"Produto: " + PRODUTO - DESCRICAO	#" Quantidade: " + QUANTIDADE
					For nI := 1 to Len(aProduto)
						cMsgSC +=	STR0006 + AllTrim(aProduto[nI][1]) + " - " + aProduto[nI][2] +;
									STR0007 + CValToChar( aProduto[nI][3] ) + CHR(10)
					Next
					lRet := .T.
				Endif 
				      
				AADD(aCancSC,{aCols[nX][nPosNumSC]})
				aCab	:= {}
				aItem	:= {}
				aProduto := {} 
				
				If  !( lAutoExec )
					//Mensagem ao usuario informando o numero e itens da SC excluída
					LA590Msg(,cMsgSC)
				EndIf
				cMsgSC := ""
				
				cFilAnt := cFilBkp   // Volta o BKP da filial
			Endif
		Endif
	Next nX
Endif

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LA590Msg	ºAutor  ³  Vendas Clientes   º Data ³  05/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe mensagem em tela  									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ ExpC1 - Cabecalho da mensagem	                          º±±
±±º			 ³ ExpC2 - Texto da mensagem                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nil								                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja				                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 										         
Function LA590Msg(cCabec, cTexto)  

Local oFont		:= Nil				//Objeto para fonte apresentada na tela
Local oDlg		:= Nil				//Objeto para apresentacao da tela
Local oMemo		:= Nil				//Objeto para texto apresentada na tela

DEFAULT cTexto	:= ""				//Cabecalho da Mensagem
DEFAULT cTexto	:= ""				//Texto da Mensagem

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta tela com as informacoes dos parametros p exibicao  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oFont NAME "ARIAL" SIZE 6,16
DEFINE MSDIALOG oDlg TITLE cCabec From 3,0 to 340,417 PIXEL
@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
oMemo:oFont:=oFont
DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL   
ACTIVATE MSDIALOG oDlg CENTER
		
Return(Nil)		


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LA590CncVAºAutor  ³Vendas Clientes     º Data ³  23/05/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua o Cancelamento da Solicitacao de Compra gerada      º±±
±±º          ³ atraves da rotina de Reservas, vinda do LOJA701       		  º±±  
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ ExpC1 - Numero orcamento com SC	                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±  
±±ºRetorno   ³ ExpL1 - Logico. Se .T. - Cancelou SC                       º±±
±±º          ³                 Se .F. - Nao Cancelou SC				      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaloja                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LA590CncVA(cNumOrcam,cFilSL1,cNumSolic,cFilSolic,aColsTmp,nPosProd,nPosQuant, lDelSC0)

Local nX			:= 0			// Contador 
Local lRet			:= .F.			// Variavel de Retorno da Funcao
Local cFilBkp		:= ""           // Utilizada para guardar o BKP da filial
Local cMsgSC		:= ""			// Mensagem para Solicitação de Compra
Local aProduto		:= {}			// Variável para leitura de itens excluídos
Local aCabSC 		:= {}			// Cabeçalho da Solicitação de Compras que será passado a rotina de exclusão
Local aItensSC 		:= {}			// Dados dos itens da Solicitação de Compras que serão parassados  a rotina de exclusão
Local lDeletado		:= .F.			// Verifica se o item da aCols está deletado
Local cSolicitan	:= ""			// Guarda a informação do campo SC1->C1_SOLICIT
Local aHeaderBKP 	:= {}			// Guarda o Backup do array aHeader

Default cFilSL1		:= cFilAnt		// Filial anterior
Default cNumSolic	:= ""			// Numero da Solicitação gravada, vinda do loja701
Default cFilSolic	:= ""			// Filial da Solicitação gravada, vinda do loja701 (opcional)
default aColsTmp	:= {}			// Recebe o aCols - Usado para proteção do Robô
Default nPosProd	:= 0			// Posicao do Codigo do produto
Default nPosQuant	:= 0			// Posicao da Quantidade
Default lDelSC0		:= .F.			// Apaga todas as Solicitações sw Comprasm pois todas as reserrvas foram canceladas

PRIVATE lMsErroAuto	:= .F.			//Determina se houve algum tipo de erro durante a execucao do ExecAuto

If  (Type("lAutoExec") == "U")
 	lAutoExec   := .F.
EndIf 	

If !Empty(cNumSolic)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Varre o SC1 para cancelar as solicitacaoes de compras  ³    
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cFilSolic)  	//Se tiver utiliza a filial do aCols 
		cFilSL1 := cFilSolic
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa o campo C1_ORCAM para permitir a exclusao      ³
	//³da Solicitação de Compra quando deletado um orçamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	For nX = 1 to Len(aColsTmp)

		// Verifica se o item do array aColsTmp está deletado
		lDeletado := aCols[nX][Len(aColsTmp[nX])]   //Se deletado e Número da Solicitação de Compra preenchido

		If lDeletado .OR. lDelSC0
			DbSelectArea("SC1")
			DbSetOrder(1) 					//C1_FILIAL+C1_NUM+C1_ITEM
			If DbSeek(cFilSL1+cNumSolic)
				While !Eof() .AND. (SC1->C1_FILIAL == cFilSL1) .AND. (SC1->C1_NUM == cNumSolic)

					If !Empty(SC1->C1_ORCAM) .AND. (SC1->C1_PRODUTO == aColsTmp[nX][nPosProd] .AND. SC1->C1_QUANT ==  aColsTmp[nX][nPosQuant])
						If Empty(cSolicitan)
							// Guarda a informação do SC1->C1_SOLICIT, que será atribuida no array aCabSC
							cSolicitan := SC1->C1_SOLICIT
						EndIf

						// Limpa array aLinhaC1
						aLinhaC1 := {}

						// Adiciona dados do produto para exibir quais produtos foram excluídos da Solicitação
						aAdd(aProduto,{ SC1->C1_PRODUTO, SC1->C1_DESCRI, SC1->C1_QUANT })

						// Adiciona dados do item na linha
						aAdd(aLinhaC1,{"LINPOS"		, "C1_ITEM"    		, SC1->C1_ITEM	})
						aAdd(aLinhaC1,{"AUTDELETA"	, "S"				, Nil			})
						aadd(aLinhaC1,{"C1_PRODUTO"	, SC1->C1_PRODUTO	, Nil			})
						aadd(aLinhaC1,{"C1_QUANT" 	, SC1->C1_QUANT 	, Nil			})

						// Condição para excluir Solicitação de Compras, SC1->C1_ORCAM == ""
						RecLock('SC1',.F.)  
						SC1->C1_ORCAM := ""
						SC1->(MsUnLock())

						// Adiciona linha no array de itens que serão excluídos
						aadd(aItensSC, aLinhaC1)

						// Após atualizar Item do SC1 que será excluído, passa para o próximo item do aColsTmp
						Exit
					EndIf	
					SC1->(DbSkip())
				End
			EndIf
		EndIf	
	Next nX

	cFilBkp := cFilAnt  // Troca a Filial pois a rotina automatica nao encontra
	cFilAnt := cFilSL1 	// a exclusao em outra filial e nao exclui o pedido de compras

	If Type("aHeader") <> "U"
		aHeaderBKP 	:= aClone(aHeader)
		aHeader := {}
	EndIf

	// Alimenta array do Cabeçalho da Solicitação de Compras	
	aadd(aCabSC,{"C1_NUM" 		, cNumSolic	})
	aadd(aCabSC,{"C1_SOLICIT"	, cSolicitan})
	aadd(aCabSC,{"C1_EMISSAO"	, dDataBase	})

	// Se existir itens a ser excluído
	If Len(aItensSC) > 0
		MSExecAuto({|x,y| mata110(x,y,4)},aCabSC,aItensSC)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se houveram erros durante a execucao da rotina automatica.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lMsErroAuto
			DisarmTransaction()
			MostraErro()
		Else	
			cMsgSC += STR0008 + cFilSL1 + CHR(10)						//"Para a Filial: "
			cMsgSC += STR0009 + cNumSolic + STR0005 + CHR(10)		//"Foi excluída a Solicitação de Compras número: "	#" com os itens: "
					//"Produto: " + PRODUTO - DESCRICAO	#" Quantidade: " + QUANTIDADE
			For nX := 1 to Len(aProduto)
				cMsgSC +=	STR0006 + AllTrim(aProduto[nX][1]) + " - " + aProduto[nX][2] +;
							STR0007 + CValToChar( aProduto[nX][3] ) + CHR(10)
			Next
			lRet := .T.
		Endif 
						
		If  !( lAutoExec )
			//Mensagem ao usuario informando o numero e itens da SC excluída
			LA590Msg(,cMsgSC)
		EndIf

	EndIf

	If Len(aHeaderBKP) > 0
		aHeader := aClone(aHeaderBKP)
	EndIf

	cFilAnt := cFilBkp   // Volta o BKP da filial

Endif

Return lRet


/*
GERA SOLICITACAO DE COMPRA
PARA OS PROCESSOS DE INTEGRACAO

ALAN S. R. OLIVEIRA
20/10/18
*/
Static Function LJ590SCIN(aReserva,nX,cFilRes)


Local nSaldoArmaz:= 0  //Saldo do Armazém 
Local nLjDatSC	 := SuperGetMv("MV_LJDATSC",,0)//Quantidade de dias somado a database para entrega da solicitação de compras
Local nPosEntr	 := Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_ENTREGA"})	 // Posicao do tipo de Entrega
Local nPosDatEnt := Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_FDTENTR"})	 // Posicao da data de Entrega
Local nPosDescP	 := Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_DESCRI"})	 // Posicao da descricao do produto
Local nPosUmProd := Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_UM"})		 // Posicao da unidade de medida do produto
Local nPosReserva:= Ascan(aHeaderdet, {|x| AllTrim(Upper(x[2])) == "LR_RESERVA"})// Posicao da Reserva
Local nPosFilRes := Ascan(aHeaderdet, {|x| AllTrim(Upper(x[2])) == "LR_FILRES"})// Posicao da Reserva
Local cDescPr	 := ""
Local cUmProd 	 := ""
Local aItem 	 := {}
Local aSldEst    := {}
Local nX		 := 1

LjGrvLog("LJ590SCIN","TOTAL ACOLSDET:"+cValToChar(len(aColsDet)))

For nX:=1 To Len(aColsDet)
	
	aSldEst := {}
	
	DbSelectArea("SC0")
	SC0->(DbSetOrder(1))
		
	If(SC0->(DbSeek(aColsDet[nX][nPosFilRes]+aColsDet[nX][nPosReserva]) ) )
	
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		If(!SB1->(DbSeek(xFilial("SB1")+SC0->C0_PRODUTO)))
			LjGrvLog("LJ590SCIN","NAO ACHOU O PRODUTO NA SB1:"+SC0->C0_PRODUTO )
			Loop		
		Endif
		
		If SB1->B1_RASTRO $ ("L/S")
			LjGrvLog("LJ590SCIN","BUSCANDO SALDO DE PRODUTO COM LOTE:"+SC0->C0_PRODUTO)
			aSldEst := SldPorLote(SC0->C0_PRODUTO,;
								  SC0->C0_LOCAL,;
								  SC0->C0_QTDORIG,;
								  0,;
								  SC0->C0_LOTECTL,;
								  SC0->C0_NUMLOTE,;
								  SC0->C0_LOCALIZ,;
								  SC0->C0_NUMSERI)
			If 	Len(aSldEst)							  
				nSaldoArmaz := aSldEst[Len(aSldEst)][5]
				LjGrvLog("LJ590SCIN","SALDO DE PRODUTO COM LOTE:"+SC0->C0_PRODUTO - cValtoChar(nSaldoArmaz))
			Else
				nSaldoArmaz := 0
			Endif 
		Else
			DbSelectArea("SB2")
			SB2->(DbSetOrder(1))
			If( SB2->(DbSeek(SC0->C0_FILIAL+SC0->C0_PRODUTO+SC0->C0_LOCAL)))
				nSaldoArmaz := SaldoSB2()
				LjGrvLog("LJ590SCIN","SALDO DE PRODUTO :"+SC0->C0_PRODUTO - cValtoChar(nSaldoArmaz))
			Endif
		Endif
	
		//CASO O SALDO DISPONIVEL NO ARMAZEM SEJA MAIOR QUE A RESERVA NAO SERA 
		//GERADO SOLICITACAO DE COMPRA.
		If nSaldoArmaz > SC0->C0_QTDORIG
			LjGrvLog("LJ590SCIN","SALDO DOPRODUTO :"+SC0->C0_PRODUTO+ " NO ARMAZEM: " + cValtoChar(nSaldoArmaz)+ " MAIOR QUE A RESERVA, NAO GERA SC")
			Loop			
		Endif
		cFilRes := SC0->C0_FILIAL
		
		aadd(aItem ,StrZero(nX,2))		//NÚMERO DO ITEM
		aadd(aItem ,SC0->C0_PRODUTO)	//CÓDIGO DO PRODUTO
		aadd(aItem ,SC0->C0_QTDORIG)	//QUANTIDADE
		aadd(aItem ,{{SC0->C0_LOCAL,;	//LOCAL	
					  nSaldoArmaz}})	//QUANTIDADE EM ESTOQUE
		aadd(aItem ,SC0->C0_LOCAL)		//LOCAL ONDE SERA FEITA A RESERVA
		aadd(aItem ,{SC0->C0_NUMLOTE,;	//SUBLOTE
				     SC0->C0_LOTECTL,;	//LOTE
				     SC0->C0_LOCALIZ,;	//ENDERECO
				     SC0->C0_NUMSERI})	//SERIE
		aadd(aReserva,aItem)
		aItem := {}
	Else
		LjGrvLog("LJ590SCIN","NAO LOCALIZOU A RESERVA DO PRODUTO NA SC0:"+aColsDet[nX][nPosReserva] )
	Endif
	
	If Len(aReserva) > 0
		//Procuramos pelo armazem que foi realizado a reservada
		nPosLocal := Ascan( aReserva[Len(aReserva)][4], {|x| x[1] == aReserva[Len(aReserva)][5]} )
		cLocRes	  := aReserva[Len(aReserva)][4][nPosLocal][1]
	 	cDescPr	  := aCols[VAL(aReserva[Len(aReserva)][1])][nPosDescP]
		cUmProd   := aCols[VAL(aReserva[Len(aReserva)][1])][nPosUmProd]
					
		// se a quantidade do armazem escolhido for negativo
		If aReserva[Len(aReserva)][4][nPosLocal][2] < 0
			nQtdSolCom := aReserva[Len(aReserva)][3]	//geramos a SC somente com a quantidade da venda
			LjGrvLog("LJ590SCIN","GERA SC COM QUANTIDADE: "+cValtoChar(nQtdSolCom))
		Else
			//caso contrario, ele soh gera a SC com a diferenca do saldo disponivel
			nQtdSolCom := aReserva[Len(aReserva)][3] - aReserva[Len(aReserva)][4][nPosLocal][2]
			LjGrvLog("LJ590SCIN","GERA SC COM QUANTIDADE: "+cValtoChar(nQtdSolCom))
		EndIf
	
		//gera a SC com a diferenca do saldo disponivel
		nQtdSolCom := aReserva[Len(aReserva)][3]
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega Array aProdSC para gerar solicitacao de compras  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ45gfvvvvddd
		Aadd(aProdSC, {	aReserva[Len(aReserva)][2]							  		,;	//01 - Codigo do Produto
						cDescPr											,;	//02 - Descricao do produto
						cUmProd											,;	//03 - Unidade de medida do produto
						cLocRes									 		,;	//04 - Armazen do produto
						nQtdSolCom										,;	//05 - Quantidade
						cFilRes		   							 		,;	//06 - Filial da reserva
						dDatabase + nLjDatSC							,;	//07 - Data da Entrega
						aReserva[Len(aReserva)][1]						})	//08 - Posicao do produto na aCols
				
		If (nPosEntr > 0) .AND. (nPosDatEnt > 0)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se esta usando entrega. Se estiver assume ³
			//³a database + dias do parametro MV_LJDATSC     	  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  aCols[VAL(aReserva[Len(aReserva)][1])][nPosEntr] == "3" .And. Type("bRefresh") <> "U" .And. nLjDatSC > 0
				aCols[VAL(aReserva[Len(aReserva)][1])][nPosDatEnt] := dDatabase + nLjDatSC 
				Eval(bRefresh)
			EndIf
		EndIf
	Endif
	aReserva := {}
Next nX

Return
