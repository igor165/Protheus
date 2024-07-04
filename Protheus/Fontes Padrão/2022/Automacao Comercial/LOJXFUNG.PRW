#INCLUDE "LOJXFUNG.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCBROWSE.CH"

Function LOJXFUNG ; Return  // "dummy" function - Internal Use
Static lCenVenda := SuperGetMv("MV_LJCNVDA",,.F.) // Indica se usa integracao com cenario de vendas

Static aLjxRelGer := {}			// Array Statico para impressão do Relatório Gerencial 
Static aLjxRelGar := {}			// Array Statico para impressão do Relatório Gerencial 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LjxSetRGer³ Autor ³ Venda Clientes        ³ Data ³26/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Seta valor do relatorio gerencial					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LjxSetRGer( aRelGer )						              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aRelGer - Array de relatorio gerencial					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil										    		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxSetRGer( aRelGer )

Default aRelGer := {}

aLjxRelGer := aRelGer

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LjxSetRGar³ Autor ³ Venda Clientes        ³ Data ³26/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Seta valor do relatorio garantia						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LjxSetRGar( aRelGar )						              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aRelGar - Array de relatorio garantia     				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil										    		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxSetRGar( aRelGar )  

Default aRelGar := {}

aLjxRelGar := aRelGar  	

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LjxGetRGer³ Autor ³ Venda Clientes        ³ Data ³26/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ retorna valor do relatorio gerencial					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LjxGetRGer()									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ aRelGer - Valor do relatorio de gerencial     		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxGetRGer()
Return aLjxRelGer

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LjxGetRGar³ Autor ³ Venda Clientes        ³ Data ³26/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ retorna valor do relatorio de garantia					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LjxGetRGar()									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ aRelGar - Valor do relatorio de garantia		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxGetRGar()
Return aLjxRelGar

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Lj7GarEst³ Autor ³ Venda Clientes        ³ Data ³17/11/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega variaveis estaticas para serem usadas			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Frt060Alt(ExpC1,ExpX2)						              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Posição											  ³±±
±±³          ³ ExpL2 - tem Sugestão de venda 							  ³±±
±±³          ³ ExpC3 - Codigo do produto								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ cSerie - Numero de série do produto			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7GarEst(aCpoGDa,lSugestao,cCodProd, nValorUni)

Local aArea			:= GetArea()																	// Posição Area atual
Local aRet       		:= {}                                                                      		// Array de retorno 
Local nCont      		:= 1                                                                        	// Contador 
Local nPosItem	 	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_ITEM"})][2]	    	// Posicao do Codigo do item
Local nPosProd	 	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]		// Posicao do codigo do produto
Local nPosEntr   		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_ENTREGA"})][2]		// Posicao Entrega
Local nPosVlItem 		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VLRITEM"})][2]    	// Posição do item na SLR                              
Local nPosGar   		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_GARANT"})][2]		// Posicao da Garantia 
Local nPosSer   		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_NSERIE"})][2]		// Posicao Numero de série 
Local naCols    		:= Len(aCols)                                                                 	// Ultima posição da aCols
Local nTamaRet   		:= 0                                                                           	// Tamanho Retorno 
Local aTmpCols   		:= Array( 1, Len(aHeader) + 1 )                                               	// aCols temp
Local nTamItem   		:= TamSx3("LR_ITEM")[1]															//tamanho LR_ITEM
Local nTamProd   		:= TamSx3("L2_PRODUTO")[1]                                                    	//tamanho LR_PRODUTO
Local cBkReadVar 		:= ReadVar()																   	//Backup da variavel __ReadVar
Local cSerie     		:= ""                                                                         	//Código de série
Local nPosValD		:= (Len(aHeader) + 1)
Local nPosNumSerie	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_NSERIE"	})   // Posicao do campo numero de serie 
Local _nPosMdVd     	:= aScan(aHeader,{|x| Alltrim(x[2]) == "LR_VDMOST" })	//Posicao do Codigo do Modo de Venda
Local aOcorrencias	:= {}															//Ocorrências encontradas quando o produto marcado com garantia não encontrar garantia

Local lGE 	:= LjUp104Ok()									// Validação do Conceito Garantia Estendida
Local lGESerie 	:= SuperGetMV("MV_LJSERGE", ,.T.)	// Habilita o Numero de Serie Para Garantia Estendida
Local nBck			:= 0 

Default aCpoGDa	  := {}
Default lSugestao := .F. 
Default cCodProd  := ""              
Default nValorUni := 0

//Valida os parametros obrigatorios para o conceito de garantia estendida.
If SuperGetMv("MV_LJFNGE",,.F.) .AND. ExistFunc("LjParamGar")
	If !LjParamGar()
		Return Nil
	EndIf	
EndIf

LjHeader("SB1", aCpoGDa, @aTmpCols,lSugestao)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Função que verifica e calcula preço da garantia estendida nas tabelas SL1 e SL0³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nPosProd > 0 .AND. lGE
	If !Empty(cCodProd)
		Lj7VeriGar(cCodProd, @aRet, ,nValorUni, @aOcorrencias)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria tela com opções de garantia estendida que estão cadastradas ³
//³na SL1 e SLI com TIPO "GE"                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aRet := Lj7GarTela(aRet,lSugestao,aOcorrencias)  		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona o número de série cadastrado na tabela SBF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Len(aRet) > 0

	LjAtuAcols(aRet,.T.)
	If lGESerie    // "X" String da Serie quando informada de forma invalida. lGESerie - Validação Para Habilitar o Numero de Serie para Garantia Estendida

		//Este refresh é necessário pois nao ocorre atualização de tela quando se esta dentro de valid de campo.
		//como a tela de serie de GE fica aguardando uma acao , a tela abaixo da acols fica visivel com valores errados.
		If Type("oGetVA") <> "U" 
			nBck := n
			oGetVA:ForceRefresh()
			n := nBck
		EndIf	 
	
    	cSerie := LjxGetGar()             								
	
		While !Lj7VlSeri(cSerie,cCodProd) .AND. cSerie <> "X"   // "X" String da Serie quando informada de forma invalida.
			MsgAlert(STR0007)//"Número de Série invalido!"
			cSerie := LjxGetGar()
		End
	Endif   
	   
Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando cSerie for "X" deleta o produto de Garantia pois o usuario não informou um número de série valido! ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cSerie == "X"  // "X" String da Serie quando informada de forma invalida.
    Lj7ValDel(, ,  , ,.T.)
    If n > 1
    	aCols [n-1][nPosGar]:= ""
    EndIf
    aCols [n][nPosValD]:= .T.
EndIf

If _nPosMdVd > 0
	aCols[n,_nPosMdVd]	:= "N"        // Colocado para evitar erros no tipo de peça que tem que ser normal        
EndIf

If Len(aCols)> Len(aColsDet)   // Garantia Estendida - Colocado para evitar erros qdo a linha do aCols for deletada
	aAdd( aColsDet, Array( Len(aHeaderDet)+1 ) )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o número de série na aCols para incluir na SL2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aCols) > 1 .AND. cSerie <> "X" .AND. lGESerie   	// "X" String da Serie quando informada de forma invalida - lGESerie - Validação Para Habilitar o Numero de Serie para Garantia Estendida			// "X" String da Serie quando informada de forma invalida. 
	If n > 1
		aCols [n-1][nPosSer] := cSerie             				// busca a Série do produto de venda que está uma posição acima do produto de garantia estendida
		If nPosNumSerie > 0
	   		aColsDet[n-1][nPosNumSerie] := cSerie         	  	
		EndIf
	EndIf
EndIf           

RestArea( aArea )

Return cSerie                                                                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj7VlSeri ³Autor  ³ Venda Clientes        ³ Data ³13/01/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida Serie do produto					    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj7VlSeri(ExpC1,ExpC2)						              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Numero de serie 									  ³±±
±±³          ³ ExpC2 - Codigo do produto								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ lValid - Se o numero de serie é valido 		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA701A													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj7VlSeri(cNSerie,cProd, nValorUni)

Local aAreaSBF  := {}        				//posição Atual
Local lValid  	:= .F.						//return .T. para validar

Default cNSerie := ""
Default cProd   := ""
Default nValorUni := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ(¿
//³Consulta se número de série digitado existe na tabela SBF. ³
//³Se não existir retorna a tela de seleção de nº de série    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ(Ù

aAreaSBF  := SBF->(GetArea())

DbSelectArea("SBF")
DbSetOrder(4) 					   			//Filial + Produto + Numero de serie
If DbSeek(xFilial("SBF")+ cProd + cNSerie)
	While !EOF() .AND. (SBF->BF_FILIAL == xFilial("SBF")) .AND. (SBF->BF_PRODUTO == cProd)
		If cNSerie == SBF->BF_NUMSERI
			lValid := .T.
		ElseIf !Empty(cNSerie)
			lValid := .T.
		EndIf
	DbSkip()
	End
EndIf

RestArea(aAreaSBF)

Return lValid

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7VeriGar  ºAutor  ³Vendas CRM          º Data ³  03/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula preço dos produtos por categoria                  	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpcao: C1 - Pesquisa de produtos na Categoria de Produtos.  º±±
±±º          ³ 		   A2 - Pesquisa de produtos de Garantia estendida.     º±±
±±º          ³ 		   L3 - Atualiza Preço dos produtos de Garantia.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA701A                                                     	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7VeriGar(cProd, aRet,lItem, nValorUni, aOcorrencias)
                                                                   
Local cNome        	:= ""						   				// Descrição do produto
Local aAreaSB1     	:= {}						   				// Posição atual
Local nRisco       	:= 0                            			// Risco do produto %
Local nVlrProd     	:= 0                            			// Vlr do produto de Venda
Local nPrcIten     	:= SB1->B1_PERGART						// Percentual de Risco do item com Garantia
Local nTotal       	:= 0                             			// Valor total do produto de Garantia estendida
Local nPosQuant		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_QUANT"})][2]		// Posicao da Quantidade
Local cMvLjTGar 	:= SuperGetMV("MV_LJTPGAR", ,"GE")			// Define se é tipo GE
Local cMvLjTSf	:= SuperGetMV("MV_LJTPSF",,"SF")			// Define se é tipo SF
Local cPicture      := PesqPict("SLR","LR_VLRITEM")   		// Picture 
Local nVlr			:= 0										// Valor percentual do Produto
Local lMvGarFP		:= SuperGetMV("MV_LJGarFP", ,.F.)	    // Define o conceito do preço da Garantia Estendida
Local cFilSB1		:= xFilial("SB1")                        		// Filial SB1
Local cTabPrc		:= ""											// Tabela de preço utilizada
Local nValor		:= 0                                     		// Valor da Garantia
Local lAchou		:= .F.                                   		// Produto Garantia com Preço

Default cProd	   := ""
Default lItem      := .F.
Default aRet       := {}
Default aOcorrencias := {}				// 01=Vigência fora do prazo, 02=Não é permitido preencher produto e grupo ao mesmo tempo

aAreaSb1 := SB1->(GetArea())  

DbSelectArea("SB0")
SB0->(DbSetOrder(1))		//B0_FILIAL+B0_COD
If  !lMvGarFP  			//Se a garantia não é por faixa de preço
	SB0->(DbSeek(xFilial("SB0")+ cProd))
	DbSelectArea("SB1")
	SB1->(DbSetOrder(2))		//B1_FILIAL+B1_TIPO+B1_COD
	If SB1->(DbSeek(xFilial("SB1")+ cMvLjTGar))	//Garantia Estendida
		While !SB1->(EOF()) .AND. (xFilial("SB1") == SB1->B1_FILIAL) .AND. (SB1->B1_TIPO == cMvLjTGar)	
			cNome       := SB1->B1_DESC
			cCod        := SB1->B1_COD
			nVlr        := SB1->B1_PERGART
            
			If lCenVenda
				cTabPrc	 := LjXETabPre(M->LQ_CLIENTE,M->LQ_LOJA)
				nVlrProd := MaTabPrVen(	cTabPrc, cProd	,	aCols[n][nPosQuant],	M->LQ_CLIENTE,;
										M->LQ_LOJA,  nMoedaCor, 	/*dDataVld*/,	/*nTipo*/,/*lExec*/)							
			Else
				nVlrProd    := &("SB0->B0_PRV" + AllTrim(Str(Val(Lj7DefTab()))))
			EndIf
			
			nRisco      := a410arred(nVlrProd+(nVlrProd * nPrcIten /100),"L2_VRUNIT")						
			nTotal      := a410arred(nRisco*nVlr/100+(nVlrProd*nPrcIten/100),"L2_VRUNIT")
			AAdd(aRet, {.F.,cCod,cNome, TRANSFORM(nTotal, cPicture), cMvLjTGar})								
			SB1->(DbSkip())
		End
	ElseIf SB1->(DbSeek(xFilial("SB1")+ cMvLjTSf)) //Servico Financeiro
		aAreaSb1 := SB1->(GetArea())  
	
		SB1->(DbSetorder(1)) //B1_FILIAL + B1_COD
			
		If SB1->(DbSeek(cFilSB1 + cProd))  
			cB1_GRUPO := SB1->B1_GRUPO
		EndIf
		
		LjGarVl("",cProd, nValorUni, cB1_GRUPO, @nValor, @lAchou, @aRet, @aOcorrencias)	
	EndIf
Else    			//Garantia por Faixa de Preço        
	aAreaSb1 := SB1->(GetArea())  
	
	SB1->(DbSetorder(1)) //B1_FILIAL + B1_COD
	
	If SB1->(DbSeek(cFilSB1 + cProd))  
		cB1_GRUPO := SB1->B1_GRUPO
	EndIf
		
	LjGarVl("",cProd, nValorUni, cB1_GRUPO, @nValor, @lAchou, @aRet, @aOcorrencias)
EndIf

RestArea(aAreaSB1)																						

Return .T.  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7ImpVlr	  ºAutor  ³Vendas CRM          º Data ³  03/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula preço dos produtos de Venda Tela	                  	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpcao: C1 - Pesquisa de produtos na Categoria de Produtos.  º±±
±±º          ³ 		   A2 - Pesquisa de produtos de Garantia estendida.     º±±
±±º          ³ 		   L3 - Atualiza Preço dos produtos de Garantia.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA701A                                                     	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7ImpVlr(cProd, aRet,lItem, cCliente, cLoja, nMoeda)

Local cTabPrecos    := LjXETabPre(cCliente,cLoja)				// Parametro da tabela de preco padrao
Local cNumTab		:= ""        								//Captura a tabela de preço
Local aAreaSB1     	:= {}						   				// Posição atual
Local aAreaSB0     	:= {}						   				// Posição atual
Local nRisco       	:= 0                            			// Risco do produto %
Local nLinha		:= Len(aCols)                   				// Ultima linha da aCols 
Local nPosQuant		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_QUANT"})][2]		// Posicao da Quantidade
Local nVlrProd     	:= 0                            			// Vlr do produto de Venda
Local nPrcIten     	:= SB1->B1_PERGART						// Percentual de Risco do item com Garantia
Local nTotal       	:= 0                             			// Valor total do produto de Garantia estendida
Local cMvLjTGar 	:= SuperGetMV("MV_LJTPGAR", ,"GE")			// Define se é tipo GE
Local nVlr			:= 0										// Valor percentual do Produto
Local lMvGarFP		:= SuperGetMV("MV_LJGARFP", ,.F.)   	// Define o conceito do preço da Garantia Estendida
Local lAchou		:= .F.                                   		// Produto Garantia com Preço
Local lTemField		:= .F.

Default cProd	   := ""
Default lItem      := .F.
Default aRet       := {}       
DEFAULT cCliente   := ""
DEFAULT cLoja	   := ""
DEFAULT nMoeda	   := 0

aAreaSb1 := SB1->(GetArea())
aAreaSb0 := SB0->(GetArea())   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o produto for tipo GE posiciona o ponteiro no produto de venda para pegar o³
//³preço para os produtos garantia estendida...	 								 	³       						
//³pega o Vlr do produto de venda(nLInha -1)para calcular o Vlr da garantia  	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If 	SB1->B1_TIPO == cMvLjTGar
	
	If	!lMvGarFP
		nVlr:= SB1->B1_PERGART
 																										
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		If SB1->(DbSeek(xFilial("SB1")+ aCols[nLinha-1][2]))
			nPrcIten    := SB1->B1_PERGART

			If lCenVenda
				cNumTab	 := LjXETabPre(M->LQ_CLIENTE,M->LQ_LOJA)
				nVlrProd := MaTabPrVen(	cNumTab, aCols[nLinha-1][2]	, aCols[nLinha-1][nPosQuant],	M->LQ_CLIENTE,;
										M->LQ_LOJA,  nMoedaCor, 	/*dDataVld*/,	/*nTipo*/,/*lExec*/)							
			Else
				DbSelectArea("SB0")
				SB0->(DbSetOrder(1))
				If SB0->(DbSeek(xFilial("SB0")+ aCols[nLinha-1][2]))
					cNumTab		:= AllTrim(Str(Val(Lj7DefTab())))
					lTemField	:= IIf(SB0->(FieldPos("B0_PRV"+cNumTab)) > 0 , .T.,.F.)
					If lTemField
						nVlrProd    := &("SB0->B0_PRV"+cNumTab)
					Else
						nVlrProd    := SB0->B0_PRV1
					EndIf
				EndIf	
			EndIf
			nRisco      := a410arred(nVlrProd+(nVlrProd * nPrcIten /100),"L2_VRUNIT")						
			nTotal      := a410arred(nRisco*nVlr/100+(nVlrProd*nPrcIten/100),"L2_VRUNIT")
		EndIf 
	Else 

		
		If lCenVenda //Cenário de Vendas eh outra regra para valor uni[tario
			
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+ aCols[nLinha-1][2]))
				nVlrProd := MaTabPrVen(	cTabPrecos,		aCols[nLinha-1][2],		1,				cCliente,; 
							cLoja,  		nMoeda, 	/*dDataVld*/,	/*nTipo*/,;
							/*lExec*/)
			EndIf	
		Else  
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+ aCols[nLinha-1][2]))
				DbSelectArea("SB0")
				SB0->(DbSetOrder(1))
				If SB0->(DbSeek(xFilial("SB0")+ aCols[nLinha-1][2]))
					cNumTab		:= AllTrim(Str(Val(Lj7DefTab())))
					lTemField	:= IIf(SB0->(FieldPos("B0_PRV"+cNumTab)) > 0 , .T.,.F.)
					If lTemField
						nVlrProd    := &("SB0->B0_PRV"+cNumTab)
					Else
						nVlrProd    := SB0->B0_PRV1
					EndIf
				EndIf	
			EndIf
		EndIf
																	
		LjGarVl(cProd,SB1->B1_COD, nVlrProd, SB1->B1_GRUPO, @nTotal, @lAchou) 	
	EndIf
EndIf

RestArea(aAreaSB1)	
RestArea(aAreaSB0)

Return nTotal
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |Lj7GarTela  ºAutor  ³Vendas CRM          º Data ³  20/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe tela dos produtos que tem Garantia estendida          	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aProds: array com  produtos de garantia estendida            º±±
±±º          ³ lSugestao: Logico que define se tem Garantia estendida       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Retorna um array com os produtos selecionados              	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA701                                                     	º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Lj7GarTela(aProds, lSugestao, aOcorrencias)

Local oDlg       := Nil 												// Objeto de Tela 
Local olstResul  := Nil													// Objeto de Tela 
Local aHeaders   := {"", STR0001, STR0002,STR0003,STR0024}     	        // ##"Codigo" ##"Descrição" ## "Preço" ###"Tipo"
Local aTamHead   := {20,60,120,30}										// Definição e tamanho 
Local oOK        := LoadBitmap(GetResources(),"LBOK")					// Botões de seleção 
Local oNO        := LoadBitmap(GetResources(),"LBNO")					// Botões de seleção
Local obtnInser  := Nil 												// Objeto de Tela 
Local aRetorno   := {}													// Array de Retorno 
Local cMvLjTSf   := SuperGetMV("MV_LJTPSF",,"SF")	// Define se é tipo SF
Local lVigencia	:= MBF->(ColumnPos("MBF_DTFIM")) > 0	// Verifica se existe o campo MBF_DTFIM					
Local cMsg 		:= ""										// Mensagem Principal
Local cMsg1		:= ""										// Mensagem 1
Local cMsg2		:= ""										// Mensagem 2
Local cMsg3		:= ""										// Mensagem 3

Default aProds := {}
Default lSugestao	:= .F.
Default aOcorrencias := {}				// 01=Vigência fora do prazo, 02=Não é permitido preencher produto e grupo ao mesmo tempo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o array com informações para o Grid ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aProds)> 0

	DEFINE MSDIALOG oDlg TITLE STR0018 FROM 178,181 TO 361,760 PIXEL //"Escolha Serviço Financeiro ou Garantia Estendida"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria Grid de Resultado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	olstResul := TCBrowse():New( 10,10,275,60, ,aHeaders,aTamHead,;
				oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
	olstResul:SetArray(aProds)
	olstResul:bLine := {||{ IIf(aProds[olstResul:nAt,01],oOk,oNo),aProds[olstResul:nAt,02],aProds[olstResul:nAt,03], ;					
					aProds[olstResul:nAt,04],IIF(aProds[olstResul:nAt,05]==cMvLjTSf,STR0019,STR0020)  } } //#"Serviço" ##"Garantia"
	olstResul:bLDblClick := {|| aProds[olstResul:nAt][1] :=  !aProds[olstResul:nAt][1],IIf(aProds[olstResul:nAt][1],LjVldBr(@aProds,olstResul:nAt),),;
								aProds[olstResul:nAt][1] := LjVlGAdm(aProds,olstResul:nAt),olstResul:DrawSelect(),olstResul:Refresh() }
	obtnInser  := TButton():New( 77,215, STR0005,oDlg,{|| aRetorno :=LjRetGAR(aProds), oDlg:End() },; //"Ok"
	37,12,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg CENTERED
ElseIf !lSugestao
	cMsg1 := STR0021	//"Não existe Serviço Financeiro ou Garantia Estendida para esse produto!"
	cMsg2 := STR0026	//"No Cadastro de Garantia por Faixa de Preço (LOJA980), as vigências estão fora do prazo. Favor verificar os campos Dt Ini Vigen (MBF_DTINI) e Dt Fim Vigen (MBF_DTFIM)."
	cMsg3 := STR0028	//"No Cadastro de Garantia por Faixa de Preço (LOJA980), o produto (MBF_PRODPR) e o grupo (MBF_GRUPO) não podem ser cadastrados ao mesmo tempo. Utilize um desses campos citados para preenchimento."
	If lVigencia
		cMsg := ""
		cMsg := cMsg + cMsg1
		If Ascan( aOcorrencias, "01" ) > 0	//Vigência fora do prazo. Verificar período de vigência em MBF_DTINI e MBF_DTFIM
			cMsg := cMsg + CHR(13)+CHR(10)+CHR(13)+CHR(10) + cMsg2
		EndIf
		If Ascan( aOcorrencias, "02" ) > 0 //Verificar produto MBF_PRODPR e grupo MBF_GRUPO que não podem os dois ao mesmo tempo. 
			cMsg := cMsg + CHR(13)+CHR(10)+CHR(13)+CHR(10) + cMsg3
		EndIf
		MsgAlert(cMsg)
	Else
		MsgAlert(cMsg1)
	EndIf 	
EndIf

obtnInser  := Nil
olstResul  := Nil
oDlg       := Nil

Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjRetGar    ºAutor  ³Vendas CRM          º Data ³  20/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta produtos pela Categoria monta Grid                  	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpcao: 1 - Pesquisa de produtos na Categoria                º±±
±±º          ³ 		                                        			    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA701                                                     	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function  LjRetGAR(aGrid)

Local aCodProd := {}                           	// Array de produtos do retorno
Local nTam     := Len(aGrid)                  	// Tamanho do Grid 
Local nCont    := 1                            	// Contador
Local nCodProdu := 2                				// Posição do produto no array de Garantia estendida  

Default aGrid  := {}

For nCont := 1 To nTam
	
	If aGrid[nCont][1]
		AADD(aCodProd, {aGrid[nCont][nCodProdu],1})
	EndIf
	
Next nCont

Return aCodProd

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjVldBr     ºAutor  ³Vendas CRM          º Data ³  08/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida que será selecionado apenas um produto de garantia     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ 1- Array com produtos de garantia estendida                  º±±
±±º          ³ 2- contador de validação                            			º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA701                                                     	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function  LjVldBr(aPrd,ols)

Local aCodProd := {}						//array com os produtos de Garantia estendida 
Local nTam     := 0			       		//tamanho maximo do array 
Local nCont    := 1                    	//contador 
Local nCodProdu:= 2                    	//posição do produto no array
Local lSFinanc := AliasIndic("MG8") .AND. SuperGetMV("MV_LJCSF",,.F.)	//Valida implementação do servico financeiro
Local cMvLjTSF := SuperGetMV("MV_LJTPSF",,"SF")	//Tipo Servico Financeiro

Default aPrd   := {}
Default ols    := Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Coloca .F. em todos produtos do array para selecionar somente um³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nTam := Len(aprd)

//Garantia Estendida permite selecionar apenas 1 registro
If aPrd[ols][5] == "GE"
	For nCont:=1 To nTam
		If aPrd[nCont][5] == "GE" 
			Aprd[nCont][1] := .F.
		EndIf
	Next nCont
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Marca como .T. a opção selecionada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aPrd[ols][1]:= .T.
	AADD(aCodProd, {aPrd[ols][nCodProdu],1})
ElseIf lSFinanc .AND. RTrim(aPrd[ols][5]) == RTrim(cMvLjTSF) 
	//Valida se possui cadastro de servico financeiro vigente
	MG8->(dbSetOrder(2))
	
	If MG8->(dbSeek(xFilial("MG8") + Padr(aPrd[ols][nCodProdu], TamSx3("MG8_PRDSB1")[1]))) .AND.; 
		(dDataBase >= MG8->MG8_INIVIG .AND. dDataBase <= MG8->MG8_FIMVIG)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Marca como .T. a opção selecionada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aPrd[ols][1]:= .T.
		AADD(aCodProd, {aPrd[ols][nCodProdu],1})
	Else
		MsgAlert(STR0025) //#"Produto Serviço deve possuir cadastro vigente em Serviços Financeiros"
		aPrd[ols][1]:= .F.
	EndIf	
EndIf



Return aCodProd

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjGarVl     ºAutor  ³Vendas CRM          º Data ³  08/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o valor/lista da Garantia                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ C1- Produto de Garantia								        	º±±
±±º          ³ C2- Produto vendido			                          		º±±       
±±º          ³ N3- Valor do item na tabela SB0                       		º±±  
±±º          ³ C4- Grupo do produto vendido 		                    		º±±  
±±º          ³ N5- Valor da Garantia					                  	º±±    
±±º          ³ L6  Valor de Garantia Localizado?                    		º±±
±±º          ³ A7  Lista de garantia estendida oferecidos              	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA701                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjGarVl(	cPrdGarSf,	cProd	, 	nVlrProd, 	cGrupo,;
					nValor, 	lAchou	,   aRet	 , aOcorrencias)   
							 	
Local aArea := GetArea()             	//WorkArea Ativa
Local aAreaMBF2 := MBF->(GetArea())  	//WorkArea MBF
Local aAreaMBL := MBL->(GetArea())   	//WorkArea MBL
Local cFilMBF := xFilial("MBF")      	//Filial MBF
Local cFiltro := ""                  	//Filtro xBase
Local cAlias := "MBL"                	//Alias da Tabela
Local cFilMBL := xFilial("MBL")      	//Filial MBL
Local lQuery := .F.                  	//Query SQL?
local cVazio := ""                   		//Campo Vazio Query
Local cCodigo := ""                  	//MBF_CODIGO
Local cProdVazio := Space(Tamsx3("MBF_PRODPR")[1]) //Produto Vazio para Busca
Local cGrupVazio := Space(Tamsx3("MBF_GRUPO")[1])  //Grupo Vazio para Busca  
Local cPicture	:= PesqPict("SLR","LR_VLRITEM")
Local aAreaSB1		:= SB1->(GetArea())  	//WorkArea do produto
Local cFilSB1		:= xFilial("SB1")    		//Compartilhamento do produto
Local cGarantia		:= ""               	//Produto Garantia 
Local lVigencia		:= MBF->(ColumnPos("MBF_DTFIM")) > 0	// Verifica se existe o campo MBF_DTFIM					
Local cMvLjTGar	:= SuperGetMV("MV_LJTPGAR",,"GE") 	// Define se é tipo GE 
Local cMvLjTSf	:= SuperGetMV("MV_LJTPSF",,"SF")	// Define se é tipo SF 

Default cPrdGarSf  		:= ""  
Default aRet			:= {}
Default cProd			:= ""   	// Produto 
Default nVlrProd		:= 0  		// Valor do Produto
Default cGrupo			:= "" 	// Grupo
Default nValor			:= 0  	// Valor
Default lAchou			:= .F.	// Produto Garantia com Preço
Default aOcorrencias		:= {}	// 01=Vigência fora do prazo, 02=Não é permitido preencher produto e grupo ao mesmo tempo

#IFDEF TOP  
	If TcSrvType() <> "AS/400"				
		lQuery := .T.	 
		cAlias := "MBLTMP"  
	EndIf	
#ENDIF


If Empty(cPrdGarSf)

	SB1->(DbSetorder(1)) //B1_FILIAL + B1_COD
	MBF->(DbSetOrder(4)) //MBF_PRODPR + MBF_GRUPO 
	 
	If MBF->(DbSeek(cFilMBF + cProd + cGrupVazio ) ) //Produto com garantia ou Serviço Financeiro encontrado
	
		While MBF->(!Eof() .AND. MBF_FILIAL + MBF_PRODPR ==  cFilMBF + cProd .AND. Empty(MBF_GRUPO))
		
			If lVigencia .And. ( dDataBase < MBF->MBF_DTINI .Or. dDataBase > MBF->MBF_DTFIM )
				If Ascan( aOcorrencias, "01" ) = 0				
					aAdd(aOcorrencias,"01")		//Marcar que encontrou data de vigência não preenchida
				EndIf
				MBF->(DbSkip())
				Loop
			Endif
		   
			lAchou			:= .F.	
			aAreaMBL := MBL->(GetArea()) 
		 				
		 	//Inicialmente realiza a busca por produto + Grupo   - cProd
		  				
			If !lQuery 
				
				cFiltro :=  	"MBL_FILIAL =  '" + cFilMBL + "' .AND. "+;
								"MBL_CODIGO = '" + MBF->MBF_CODIGO  + "' .AND.  "+;
								"MBL_VLINI <= " + AllTrim(Str(nVlrProd, TamSx3("MBL_VLINI")[1], TamSx3("MBL_VLINI")[2])) + " .AND. "+;
							   	"MBL_VLFIM >= " + AllTrim(Str(nVlrProd, TamSx3("MBL_VLFIM")[1], TamSx3("MBL_VLFIM")[2]))
				
				(cAlias)->(dbSetFilter({|| &cFiltro},cFiltro)) 
				(cAlias)->(dbGoTop()) 
		
		   Else                  
		   
				BeginSql Alias "MBLTMP"    
				
					SELECT MBL_VALOR			
						FROM  %table:MBL% MBL							 
					WHERE MBL.%notDel%				
						AND MBL_VLINI <= %exp:nVlrProd% 				
						AND MBL_VLFIM >= %exp:nVlrProd%	 
						AND MBL_FILIAL = %xFilial:MBL%  
						AND MBL_CODIGO = %exp:MBF->MBF_CODIGO%
				EndSql  
		   
		   EndIf   
		   
			If (cAlias)->(!Eof()) .AND. SB1->(DbSeek(cFilSB1 + MBF->MBF_PRDGAR)) .AND. SB1->B1_TIPO $ AllTrim(cMvLjTGar+"|"+cMvLjTSf)
		   		lAchou := .T. 
		   		nValor := (cAlias)->MBL_VALOR 
		    	AAdd(aRet, {.F., SB1->B1_COD, SB1->B1_DESC, TRANSFORM(nValor, cPicture), SB1->B1_TIPO}) 	
			EndIf
			
		   If lQuery  
		   	(cAlias)->(DbCloseArea())
		   Else
		   	(cAlias)->(dbClearFilter()) 
		   EndIf 
			
		 	MBF->(DbSkip(1))
		 	RestArea(aAreaMBL) 
		End
		 	 	 		   	
	ElseIf MBF->(DbSeek(cFilMBF + cProd + "" ) )		//Verifico se o produto E o grupo foi preenchido na MBF
		If !Empty(MBF->MBF_GRUPO) .AND. Ascan( aOcorrencias, "02" ) = 0
			aAdd(aOcorrencias,"02")		//Marcar que encontrou produto e grupo preenchidos
		EndIf	 	 	 		   	
	EndIf    
	
	MBF->(DbSetOrder(5)) // MBF_GRUPO  + MBF_PRODPR 
	//Agora realiza a busca por grupo
	If MBF->(DbSeek(cFilMBF +  cGrupo + cProdVazio ) ) //produto com garantia encontrada   
	
		While MBF->(!Eof() .AND. MBF_FILIAL + MBF_GRUPO ==  cFilMBF + cGrupo .AND. Empty(MBF_PRODPR))
		
			If lVigencia .And. ( dDataBase < MBF->MBF_DTINI .Or. dDataBase > MBF->MBF_DTFIM )
				If Ascan( aOcorrencias, "01" ) = 0				
					aAdd(aOcorrencias,"01")		//Marcar que encontrou data de vigência não preenchida
				EndIf
				MBF->(DbSkip())
				Loop
			Endif
			
			If aScan(aRet, { |p| RTrim(p[2]) == Rtrim(MBF->MBF_PRDGAR) })  == 0 //NAO EXISTE O PRODUTO 
			   
				lAchou			:= .F.	
			 				
			 	//Inicialmente realiza a busca por produto + Grupo   - cProd
			  				
				If !lQuery 
						
					aAreaMBL := MBL->(GetArea()) 				
					
					cFiltro :=  	"MBL_FILIAL =  '" + cFilMBL + "' .AND. "+;
									"MBL_CODIGO = '" + MBF->MBF_CODIGO  + "' .AND.  "+;
									"MBL_VLINI <= " + AllTrim(Str(nVlrProd, TamSx3("MBL_VLINI")[1], TamSx3("MBL_VLINI")[2])) + " .AND. "+;
								  	"MBL_VLFIM >= " + AllTrim(Str(nVlrProd, TamSx3("MBL_VLFIM")[1], TamSx3("MBL_VLFIM")[2]))
					
					(cAlias)->(dbSetFilter({|| &cFiltro},cFiltro)) 
					(cAlias)->(dbGoTop()) 
			
			   Else                  
			   
					BeginSql Alias "MBLTMP"    
					
						SELECT MBL_VALOR			
							FROM  %table:MBL% MBL							 
						WHERE %notDel%
							AND MBL_VLINI <= %exp:nVlrProd% 				
							AND MBL_VLFIM  >= %exp:nVlrProd%	 
							AND %xFilial:MBL% = MBL_FILIAL  
							AND MBL_CODIGO = %exp:MBF->MBF_CODIGO%
					EndSql  
			   
			   EndIf   
			   
				If (cAlias)->(!Eof()) .AND. SB1->(DbSeek(cFilSB1 + MBF->MBF_PRDGAR)) 
					lAchou := .T. 
					nValor := (cAlias)->MBL_VALOR 
					AAdd(aRet, {.F.,SB1->B1_COD,SB1->B1_DESC, TRANSFORM(nValor, cPicture), SB1->B1_TIPO}) 	
				EndIf  
				   
				If lQuery  
					(cAlias)->(DbCloseArea())
				Else
					(cAlias)->(dbClearFilter())  
					RestArea(aAreaMBL)  
				EndIf 
	 	   		
			EndIf 	
		
		 	MBF->(DbSkip(1))
		 	 
		End
		 	 	 	   	
	EndIf  

Else 
	//Busca diretamente pelo produto Garantia
	MBF->(DbSetOrder(1)) //MBF_FILIAL + MBF_PRDGAR + MBF_PRODPR + MBF_GRUPO        

	If MBF->(DbSeek(cFilMBF + cPrdGarSf ) ) //produto com garantia encontrada   
	 	//Inicialmente realiza a busca por produto + Grupo   - cProd
  		 		
			
		If MBF->(DbSeek(cFilMBF + cPrdGarSf + cProd + cGrupVazio));
				      .AND. Iif( lVigencia , dDataBase <= MBF->MBF_DTFIM , .T. ) 			 		   		          

			If !lQuery   
			
				aAreaMBL := MBL->(GetArea()) 
				cFiltro :=  	"MBL_FILIAL =  '" + cFilMBL + "' .AND. "+;
								"MBL_CODIGO = '" + MBF->MBF_CODIGO  + "' .AND.  "+;
								"MBL_VLINI <= " + AllTrim(Str(nVlrProd, TamSx3("MBL_VLINI")[1], TamSx3("MBL_VLINI")[2])) + " .AND. "+;
							   	"MBL_VLFIM >= " + AllTrim(Str(nVlrProd, TamSx3("MBL_VLFIM")[1], TamSx3("MBL_VLFIM")[2]))
				
				(cAlias)->(dbSetFilter({|| &cFiltro},cFiltro)) 
				(cAlias)->(dbGoTop()) 
		
		   Else                  
		   
				BeginSql Alias "MBLTMP"    
				
					SELECT MBL_VALOR			
						FROM  %table:MBL% MBL							 
					WHERE MBL.%notDel%				
						AND MBL_VLINI <= %exp:nVlrProd% 				
						AND MBL_VLFIM  >= %exp:nVlrProd%	 
						AND MBL_FILIAL = %xFilial:MBL%  
						AND MBL_CODIGO = %exp:MBF->MBF_CODIGO%
				EndSql  
		   
		   EndIf   
		   
			If (cAlias)->(!Eof())  
				nValor := (cAlias)->MBL_VALOR   
				lAchou := .T.
			EndIf  
			   
			If lQuery  
				(cAlias)->(DbCloseArea())
			Else
				(cAlias)->(dbClearFilter())   
				RestArea(aAreaMBL) 
			EndIf 
			        	    	    
	    EndIf 
	    
	    If !lAchou .AND. MBF->(DbSeek(cFilMBF + cPrdGarSf + cProdVazio + cGrupo));
		      .AND. Iif( lVigencia , dDataBase <= MBF->MBF_DTFIM , .T. ) 			 		   	    
		    		          			
			If !lQuery 
			   
				aAreaMBL := MBL->(GetArea()) 			
				cFiltro :=  	"MBL_FILIAL =  '" + cFilMBL + "' .AND. "+;
								"MBL_CODIGO = '" + MBF->MBF_CODIGO  + "' .AND.  "+;
								"MBL_VLINI <= " + AllTrim(Str(nVlrProd, TamSx3("MBL_VLINI")[1], TamSx3("MBL_VLINI")[2])) + " .AND. "+;
							   	"MBL_VLFIM >= " + AllTrim(Str(nVlrProd, TamSx3("MBL_VLFIM")[1], TamSx3("MBL_VLFIM")[2]))
				
				(cAlias)->(dbSetFilter({|| &cFiltro},cFiltro)) 
				(cAlias)->(dbGoTop()) 
		
		   Else                  
		   
				BeginSql Alias "MBLTMP"    
				
					SELECT MBL_VALOR			
						FROM  %table:MBL% MBL							 
					WHERE MBL.%notDel%				
						AND MBL_VLINI <= %exp:nVlrProd% 				
						AND MBL_VLFIM  >= %exp:nVlrProd%	 
						AND MBL_FILIAL = %xFilial:MBL%   
						AND MBL_CODIGO = %exp:MBF->MBF_CODIGO%
				EndSql  
		   
		   EndIf   
		   
			If (cAlias)->(!Eof())  
				nValor := (cAlias)->MBL_VALOR   
				lAchou := .T.
			EndIf  
			   
			If lQuery  
				(cAlias)->(DbCloseArea())
			Else
				(cAlias)->(dbClearFilter())    
				RestArea(aAreaMBL) 
			EndIf 			        	    
	    
	    EndIf
	
	EndIf


EndIf

//Ordernar do maior para o menor valor 
ASORT(aRet,,,{ | x,y | x[4] > y[4] } )

RestArea(aAreaMBF2)  
RestArea(aAreaSB1)
RestArea(aArea)
Return     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ7GrvMFI ºAutor  ³Vendas Clientes     º Data ³  24/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a gravacao na tabela de vendas com garantia ou       º±±
±±º          | servicos financeiros										  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³void LJ7GrvMFI(       )                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aRecSL2 - Recno da SL2                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ7GrvMFI(nOpc,aGarMfi,cNumNota,cSerie,lSFinanc,cPrefSFA,cTitSFA )

Local aAreaSl2 := SL2->(GetArea())  	//Salva posicao atual da tabela
Local aAreaSF1 := SF1->(GetArea())  	//Salva posicao atual da tabela
Local aAreaSD1 := SD1->(GetArea())  	//Salva posicao atual da tabela
Local cCodInt  := ''                 	//Codigo do produto interno
Local lItGarant:= .F.                	//Identifica o item de garantia
Local nDiasFor := 0                  	//Dias de garantia estendida/fornecedor
Local nCtGar   :=0                   		//Custo da garantia
Local cDescProd:= ''                 	//Descrição do produto 
Local cNSerie  := ''                 		//Numero de Serie do produto
Local cFornecedor := ''              	//Forncedor vinculado na administradora financeira
Local cLojaForn   := ''              	//Loja forncedor vinculado na administradora financeira
Local cMvLjTGar		    := SuperGetMV("MV_LJTPGAR",,"GE")  // Tipo da Garantia estendida cadastrado no produto.  
Local cCodigo     := '' // codgio sequencial mfi
Local lFinanceiro := .F.            		//Define se gera financeiro
Local aFinDel:= {} // Array com os titulos provisorios que devem ser deletados.
Local nI:=1         //contador

Default nOpc    :=  0                	//Define se inclui ou alterar os registros na MFI
Default aGarMfi := {,,,,0}          	//Array quando e feita uma devolucao/troca
Default cNumNota:= ""                   // Numero do documento
Default cSerie  := ""                   // Numero de serie do documento
Default lSFinanc:= .F.                  // Tratamenta para gravacao de servico financeiro na tabela MFI	
Default cPrefSFA	:= ""					// Prefixo do título Serviço Financeiro Avulso, vindo da SE1
Default cTitSFA	:= ""					// Título Serviço Financeiro Avulso, vindo da SE1
 
If AliasIndic("MFI")
	
	//Verificar cCodigo aqui
	cCodigo:= GETSXENUM("MFI","MFI_CODIGO","",1)
	If Empty(cCodigo)
		MsgAlert(STR0027)		//"Favor cadastrar o contador MFI na tabela SXE."
		LjGrvLog("LOJXFUNG",STR0027)	//"Favor cadastrar o contador MFI na tabela SXE."
	Else					
		//Caso a tabela ainda nao foi criada no banco.
		DbSelectArea("MFI")
		MFI->(DbSetOrder(1))		//MFI_FILIAL+MFI_FILORI+MFI_NUM+MFI_PRODUT+MFI_ITEM    				
		//Venda Assistida
		If nOpc == 3  .AND. ( !EMPTY(SL2->L2_DOC) .OR. !EMPTY(cNumNota)) .AND. !lSFinanc
			//Efetua a gravacao na tabela de Controle de Garantia
			SL2->(DbSetOrder(1)	)	
			SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM) )
			While SL2->(!EOF()) .AND.  SL2->L2_FILIAL + SL2->L2_NUM == xFilial( "SL2" ) + SL1->L1_NUM
				//Verifica se o produto eh do tipo garantia	
				SB1->(DbSetOrder(1))
				If SB1->(DbSeek(xFilial("SB1")+SL2->L2_PRODUTO))
					lItGarant := Iif(SB1->B1_TIPO == cMvLjTGar,.T.,.F.) 
				EndIf   
				
				If !lItGarant .AND. !Empty(SL2->L2_GARANT)		
					// Busca o preco de custo da garantia na tabela de faixa de preco 
					nCtGar:= LjCtGarant(SL2->L2_GARANT,SL2->L2_PRODUTO,SL2->L2_VRUNIT,SB1->B1_GRUPO)				  				 			
					cNSerie:= SL2->L2_NSERIE 
					cDescProd:= SB1->B1_DESC
					// Busca codigo interno do produto garantia   			
					SB0->(DbSetOrder(1))
					If SB0->(DbSeek(xFilial("SB0")+ SL2->L2_PRODUTO))
						cCodInt := SB0->B0_CODINTG
					EndIf			
				EndIf 
				
				If lItGarant			
					// Busca o fornecedor vinculado a adm financeira
					SA2->(DbSetOrder(8))  //A2_FILIAL+A2_CODADM
					If SA2->(dbSeek(xFilial("SA2")+SB1->B1_ADMIN) )
						cFornecedor := SA2->A2_COD
						cLojaForn   := SA2->A2_LOJA
					EndIf
					nDiasFor+= 0  
				Else	
					nDiasFor+= SL2->L2_VLGAPRO
				EndIf
					
				If !EMPTY(SL2->L2_GARANT) .OR. lItGarant
	
					MFI->(DbSetOrder(5))		//MFI_FILIAL+MFI_CODIGO
					While MFI->(DbSeek(xFilial("MFI")+cCodigo))
						If __lSX8
							ConfirmSx8()
						Endif	
						cCodigo:= GETSXENUM("MFI","MFI_CODIGO","",1)
					EndDo
												  	
					LjGrvLog("Lj7GrvMfi","Gravando registro MFI - Código "+ cCodigo)
					RecLock("MFI",.T.) 
					REPLACE MFI->MFI_FILIAL		WITH xFilial("MFI")
					REPLACE MFI->MFI_CODIGO		WITH cCodigo
					REPLACE MFI->MFI_NUM			WITH SL2->L2_NUM 
					REPLACE MFI->MFI_ITEM		WITH SL2->L2_ITEM
					REPLACE MFI->MFI_PRODUT		WITH SL2->L2_PRODUTO
					REPLACE MFI->MFI_DESCRI		WITH SL2->L2_DESCRI
					REPLACE MFI->MFI_QUANT		WITH SL2->L2_QUANT
					REPLACE MFI->MFI_VRUNIT		WITH SL2->L2_VRUNIT
					REPLACE MFI->MFI_VLRITE		WITH SL2->L2_VLRITEM
					REPLACE MFI->MFI_VALALT		WITH SL2->L2_VLRITEM
					REPLACE MFI->MFI_GARANT		WITH SL2->L2_GARANT
					If TamSX3("MFI_COND")[3] = "C"  //Vejo se o campo MFI_COND é caracter.
						REPLACE MFI->MFI_COND		WITH Str(SL1->L1_COND)
					Else
						REPLACE MFI->MFI_COND		WITH SL1->L1_COND
					EndIf
					REPLACE MFI->MFI_CLIENT		WITH SL1->L1_CLIENTE
					REPLACE MFI->MFI_LOJA		WITH SL1->L1_LOJA
					REPLACE MFI->MFI_VEND		WITH SL1->L1_VEND 
					REPLACE MFI->MFI_SITGAR		WITH Iif(!Empty(SL2->L2_GARANT),'','04' ) // Grava como pendente
					REPLACE MFI->MFI_NUMLOT		WITH Replicate('',TamSx3('MFI_NUMLOT')[1])
					REPLACE MFI->MFI_NSERIE		WITH cNSerie
					REPLACE MFI->MFI_DOC			WITH Iif(Empty(cNumNota),SL2->L2_DOC  ,cNumNota)
					SerieNfId("MFI",1,"MFI_SERIE",dDataBase,LjEspecieNF(),Iif(Empty(cSerie)  ,SL2->L2_SERIE,cSerie  ))
					REPLACE MFI->MFI_EMISSA		WITH dDataBase
					REPLACE MFI->MFI_DTVIGE		WITH Iif(Empty(SL2->L2_GARANT),dDataBase+nDiasFor+1,dDataBase )
					REPLACE MFI->MFI_FIMVIG		WITH Iif(Empty(SL2->L2_GARANT),SL2->L2_VLGAPRO+dDataBase+1,SL2->L2_VLGAPRO+dDataBase)
					REPLACE MFI->MFI_DIAGAR		WITH SL2->L2_VLGAPRO  			
					REPLACE MFI->MFI_FILORI		WITH cFilant			
					REPLACE MFI->MFI_ADMIN		WITH SB1->B1_ADMIN
					REPLACE MFI->MFI_CUSTO		WITH Iif(Empty(SL2->L2_GARANT),nCtGar*SL2->L2_QUANT,0 )			
					REPLACE MFI->MFI_CODINT		WITH cCodInt
					REPLACE MFI->MFI_FORNEC		WITH Iif(Empty(SL2->L2_GARANT),cFornecedor,'' )			
					REPLACE MFI->MFI_LJFORN		WITH Iif(Empty(SL2->L2_GARANT),cLojaForn,'' )			
					REPLACE MFI->MFI_DESCPR		WITH Iif(Empty(SL2->L2_GARANT),cDescProd,'' )			
					REPLACE MFI->MFI_ORIGEM		WITH "GE"
					
					MsUnlock()
					If __lSX8
						ConfirmSx8()
					Endif
												
					//Soma os valores dos produtos garantia para gerar o financeiro
					If lItGarant
		            	lFinanceiro:= .T. 
					EndIf
					nDiasFor:= Iif(lItGarant,0,nDiasFor)
				EndIf
					
				SL2->(DbSkip())
			EndDo 
		ElseIf nOpc == 4 
		    //Devolucao	               	    
			MFI->(DbSetOrder(2))   //MFI_FILIAL+MFI_FILORI+MFI_DOC+MFI_SERIE+MFI_ITEM 				
			For nI:=1 To Len(aGarMfi)
				If Len(aGarMfi[nI])>=2  //Se L2_DOC não estava preenchido, por vir de SF avulso, mudo o Order da MFI para 1.
					If aGarMfi[nI][2] = 1
						MFI->(DbSetOrder(1))   //MFI_FILIAL+MFI_FILORI+MFI_NUM+MFI_PRODUT+MFI_ITEM 				
					Elseif aGarMfi[nI][2] = 2
						MFI->(DbSetOrder(2))   //MFI_FILIAL+MFI_FILORI+MFI_DOC+MFI_SERIE+MFI_ITEM 				
					EndIf
					MFI->(DbGotop())
				EndIf			
				If MFI->(DbSeek( aGarMfi[nI][1] ))    	
			    	//Verifica se a garantia estendida ja foi enviada para a administradora financeira pela numeracao do lote.
					If EMPTY(MFI->MFI_NUMLOT)
						Aadd(aFinDel,{MFI->MFI_FILORI,MFI->MFI_PREFIX,MFI->MFI_TITULO,MFI->MFI_PARCEL,MFI->MFI_TIPO,MFI->MFI_FORNEC,MFI->MFI_LJFORN} )								
					  	//Efetua a gravacao como cancelamento OK.
		               	RecLock("MFI",.F.)
		               	REPLACE MFI->MFI_SITGAR		WITH "06"
		               	MsUnlock()																								
					Else							
					  	//Efetua a gravacao como cancelamento pendente.
		               	RecLock("MFI",.F.)
		               	REPLACE MFI->MFI_SITGAR		WITH '08' 
		               	REPLACE MFI->MFI_NUMLOT		WITH Space(TamSx3("MFI_NUMLOT")[1]) 
		               	MsUnlock()								
					EndIf							
			        
				EndIf
	
		    Next nI
			
			If !Empty(aFinDel)
				//Deleta os titulos provisórios que ainda nao foram enviados para a administradora financeira
				Lj870HDelFin(aFinDel)
			EndIf 
		ElseIf lSFinanc
			IncMfiSF(cPrefSFA,cTitSFA)	
		EndIf		
		
		//Gerar Financeiro 
		If lFinanceiro
			LjGrvLog("Lj7GrvMfi","Entrando no GeraFin")
			GeraFin(SL1->L1_NUM )
			LjGrvLog("Lj7GrvMfi","Saindo do GeraFin")
		EndIf
	EndIf
EndIf	
RestArea(aAreaSL2)
RestArea(aAreaSF1)
RestArea(aAreaSD1)
Return()
 

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraFin   ºAutor  ³Vendas Clientes     º Data ³  24/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera titulo provisorios no financeiro para os produtos      º±±
±±º          | garantia.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³void GeraFin(nValFin)                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³nValFin - valor do titulo no financeiro                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraFin(cNumOrc,cNaturez,cPrefixo)

Local aAreaSE2:= SE2->(GetArea())              	// Salva alias da tabela
Local cNum    := ""									// Numero seguencial do titulo a pagar provisorio 
Local cParcela:= SuperGetMv("MV_1DUP",,"") 		// Parcela do titulo a pagar provisorio 
Local cTipo   := "PRE"							// Tipo do titulo a pagar provisorio 
Local cFornece:= '' 									// Fornecedor para o titulo a pagar provisorio 
Local cLojaF  := '' 									// Loja Fornecedor para o titulo a pagar provisorio  
Local aArray  := {} 									// Array para ExecAuto
Local nValTit := 0 									// Valor do titulo a pagar provisório
Local cAdmFin := ''									// administradora financeira
Local nRecMFI := 0  									// Recno da tabela MFI
Local cMvLjTSF := SuperGetMV("MV_LJTPSF",,"SF")	//Tipo Servico Financeiro
Local nPosic	:= 0									//Recno do MFI, utilizado no Serviço Financeiro

Private lMsErroAuto := .F.                     		// Para Executar ExecAuto           

Default cNaturez:= SuperGetMv("MV_LJNATRE",,"")		// Prefixo do titulo a pagar provisorio 
Default cPrefixo:= SuperGetMv("MV_LJPRGAR",,"") 	// Prefixo do titulo a pagar provisorio 

MFI->(DbSetOrder(4))	//MFI_FILIAL+MFI_FILORI+MFI_NUM+MFI_ADMIN
If MFI->(DbSeek(xFilial('MFI')+cFilAnt+cNumOrc,.T.) )

	While MFI->(!EOF()) .AND. MFI->MFI_FILORI == cFilAnt .AND. MFI->MFI_NUM == cNumOrc	 
		If  !EMPTY(MFI->MFI_GARANT)	//Quando é produto comum ligado a uma garantia, NÃO GERA FINANCEIRO. Somente produto garantia ou SF.
			MFI->(DbSkip())
			cAdmFin := MFI->MFI_ADMIN		
			Loop
		EndIf
			
		nValTit += MFI->MFI_VLRITE
		cAdmFin := MFI->MFI_ADMIN
		//Busca administradora financeira cadastrada como fornecedor.
		If Empty(cFornece)
			DbSelectArea("SA2")
			DbSetOrder(8)			//A2_FILIAL+A2_CODADM
			If dbSeek(xFilial("SA2")+MFI->MFI_ADMIN)
				cFornece := SA2->A2_COD
				cLojaF   := SA2->A2_LOJA
			Endif
		EndIf		
		
		nPosic := MFI->(Recno()) 
		MFI->(DbSkip())  
		
		If (MFI->(EOF())) .OR. (MFI->MFI_ADMIN <> cAdmFin) .OR. (cPrefixo = cMvLjTSF)
			//Se for Serviços Financeiros, não posso juntar o valor de todos os serviços financeiros
			//em um título, pois no fechamento (LOJA870E) eu preciso fechar por cada produto SF. 
			DBSelectArea("SE2")		//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			DbSetOrder(1)
			Dbseek( xFilial("SE2") + cPrefixo + Replicate("Z", TamSX3("E2_NUM")[1]), .T. )
			DbSkip(-1) 
			If SubStr(SE2->E2_NUM, 1, 1) == "0"                                    
				 cNum := StrZero(Val(SE2->E2_NUM) + 1 ,Len(AllTrim(SE2->E2_NUM)))
			Else
			 	cNum := StrZero(Val(SE2->E2_NUM) + 1 ,Len(AllTrim(SE2->E2_NUM)))
			EndIf
		 
			aArray := { { "E2_PREFIXO"  ,cPrefixo           , NIL },;
			            { "E2_NUM"      , cNum              , NIL },;
			            { "E2_PARCELA"  , cParcela          , NIL },;
			            { "E2_TIPO"     , cTipo             , NIL },;
			            { "E2_NATUREZ"  , cNaturez          , NIL },;
			            { "E2_FORNECE"  , cFornece          , NIL },;
			            { "E2_LOJA"     , cLojaF            , NIL },;
			            { "E2_EMISSAO"  , dDataBase			, NIL },;
			            { "E2_VENCTO"   , LastDay(dDataBase), NIL },;
			            { "E2_VALOR"    , nValTit   		, NIL },;
			            { "E2_FLUXO"    , "S"   		    , NIL }}			 
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faz a inclusao do contas a pagar via ExecAuto ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			LjGrvLog("GeraFin","Gerando Financeiro na tabela SE2, código " + cPrefixo + "/" + cNum)
			MSExecAuto({|x,y,z| Fina050(x,y,z)},aArray,,3)
			 	 
			If lMsErroAuto
			    MostraErro()
			Else
				nRecMFI:= MFI->(Recno())
				If (cPrefixo = cMvLjTSF)		//Se for Serviços Financeiros
					MFI->(DbGoto(nPosic))
					If !MFI->(BOF()) .AND. !MFI->(EOF())
						RecLock("MFI",.F.)
						MFI->MFI_PREFIX:= cPrefixo
						MFI->MFI_TITULO:= cNum
						MFI->MFI_PARCEL:= cParcela					 
						MFI->MFI_TIPO  := cTipo
						MsUnlock()
					EndIf
				Else 						//Se for Garantia Estendida
					MFI->(DbSetOrder(4))  //MFI_FILIAL+MFI_FILORI+MFI_NUM+MFI_ADMIN
					If MFI->(DbSeek(xFilial("MFI")+cFilAnt+SL1->L1_NUM+cAdmFin))
						While MFI->(!EOF()) .AND. MFI->MFI_FILIAL + MFI->MFI_FILORI +MFI->MFI_NUM == xFilial("MFI")+cFilAnt+SL1->L1_NUM
					    	If EMPTY(MFI->MFI_GARANT) .AND. MFI->MFI_ADMIN == cAdmFin
								RecLock("MFI",.F.)
								MFI->MFI_PREFIX:= cPrefixo
								MFI->MFI_TITULO:= cNum
								MFI->MFI_PARCEL:= cParcela					 
								MFI->MFI_TIPO  := cTipo
								MsUnlock()
							EndIf	
							MFI->(DbSkip())
						EndDo
					EndIf
				EndIf
				MFI->(DbGoTo(nRecMFI))
			Endif
			
			cAdmFin := ''
			aArray  := {}
			nValTit := 0
			cFornece:= ''
		EndIf	
		
	EndDo	
EndIf		

RestArea(aAreaSE2)
	 	
Return()


/*  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjCtGarantºAutor  ³Vendas Clientes     º Data ³  24/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Armazena o custo da garantia estendida                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³void LjCtGarant	                                       	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³nValFin - valor do titulo no financeiro                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjCtGarant(cPrdGar,cProd,nVlrProd,cGrupo)
					 								 	
Local aArea := GetArea()             //WorkArea Ativa
Local aAreaMBF2 := MBF->(GetArea())  //WorkArea MBF
Local aAreaMBL := MBL->(GetArea())   //WorkArea MBL
Local cFilMBF := xFilial("MBF")      //Filial MBF
Local cFiltro := ""                  //Filtro xBase
Local cAlias := "MBL"                //Alias da Tabela
Local cFilMBL := xFilial("MBL")      //Filial MBL
Local lQuery := .F.                  //Query SQL?
local cVazio := ""                   //Campo Vazio Query
Local cCodigo := ""                  //MBF_CODIGO
Local cProdVazio := Space(Tamsx3("MBF_PRODPR")[1]) //Produto Vazio para Busca
Local cGrupVazio := Space(Tamsx3("MBF_GRUPO")[1])  //Grupo Zazio para Busca  
Local cGrupoPrd	  := Posicione("SB1", 1, xFilial("SB1") + cProd, "B1_GRUPO")
Local cPicture      := PesqPict("SLR","LR_VLRITEM")
Local aAreaSB1		:= SB1->(GetArea())  //WorkArea do produto
Local cFilSB1		:= xFilial("SB1")    //Compartilhamento do produto
Local cGarantia		:= ""                //Produto Garantia 
Local lVigencia		:= MBF->(ColumnPos("MBF_DTFIM")) > 0	// Verifica se existe o campo MBF_DTFIM					
Local nCtGara   :=0               // Custo da Garantia
Local lSeek		 := .F.

Default cPrdGar   		:= ""  	// Produto Garantia/Servico Financeiro
Default cProd			:= ""   // Produto da Venda 
Default nVlrProd		:= 0  	// Valor do Produto
Default cGrupo			:= ""   // Grupo

#IFDEF TOP  
	If TcSrvType() <> "AS/400"				
		lQuery := .T.	 
		cAlias := "MBLTMP"  
	EndIf	
#ENDIF

If Empty(cPrdGar)

	SB1->(DbSetorder(1)) //B1_FILIAL + B1_COD
   
	MBF->(DbSetOrder(4)) //MBF_PRODPR + MBF_GRUPO 
	 
	If MBF->(DbSeek(cFilMBF + cProd + cGrupVazio ) ) //produto com garantia encontrada   
	
		While MBF->(!Eof() .AND. MBF_FILIAL + MBF_PRODPR ==  cFilMBF + cProd .AND. Empty(MBF_GRUPO)) ;
		      .AND. Iif( lVigencia , dDataBase <= MBF->MBF_DTFIM , .T. ) 			 		   			
		   
			aAreaMBL := MBL->(GetArea()) 
		 				
		 	//Primeiramente realiza a busca por produto + Grupo   - cProd
		  				
			If !lQuery 
				
				cFiltro :=  "MBL_FILIAL =  '" + cFilMBL + "' .AND. "+;
								"MBL_CODIGO = '" + MBF->MBF_CODIGO  + "' .AND.  "+;
								"MBL_VLINI <= " + AllTrim(Str(nVlrProd, TamSx3("MBL_VLINI")[1], TamSx3("MBL_VLINI")[2])) + " .AND. "+;
							   "MBL_VLFIM >= " + AllTrim(Str(nVlrProd, TamSx3("MBL_VLFIM")[1], TamSx3("MBL_VLFIM")[2]))
				
				(cAlias)->(dbSetFilter({|| &cFiltro},cFiltro)) 
				(cAlias)->(dbGoTop()) 
		
		   Else                  
		   
				BeginSql Alias "MBLTMP"    
				
					SELECT MBL_CUSTO
						FROM  %table:MBL%
					WHERE %notDel%
						AND MBL_VLINI <= %exp:nVlrProd% 				
						AND MBL_VLFIM >= %exp:nVlrProd%	 
						AND MBL_FILIAL = %xFilial:MBL%
						AND MBL_CODIGO = %exp:MBF->MBF_CODIGO%
				EndSql  
		   
		   EndIf   
		   
		   If (cAlias)->(!Eof()) .AND. SB1->(DbSeek(cFilSB1 + MBF->MBF_PRDGAR)) 
		   		nCtGara:= (cAlias)->MBL_CUSTO 
		   EndIf  
		   
		   If lQuery  
		   	(cAlias)->(DbCloseArea())
		   Else
		   	(cAlias)->(dbClearFilter()) 
		   EndIf 
	
		 	MBF->(DbSkip(1))
		 	RestArea(aAreaMBL) 
		End
		 	 	 		   	
	EndIf    
		       
	MBF->(DbSetOrder(5)) // MBF_GRUPO  + MBF_PRODPR 
	//Agora realiza a busca por grupo
	If MBF->(DbSeek(cFilMBF +  cGrupo + cProdVazio ) ) //produto com garantia encontrada   
	
		While MBF->(!Eof() .AND. MBF_FILIAL + MBF_GRUPO ==  cFilMBF + cGrupo .AND. Empty(MBF_PRODPR)) ;
		      .AND. Iif( lVigencia , dDataBase <= MBF->MBF_DTFIM , .T. ) 			 		   		
			
			If nCtGara == 0
			   
			 				
			 	//Primeiramente realiza a busca por produto + Grupo   - cProd
			  				
				If !lQuery 
						
					aAreaMBL := MBL->(GetArea()) 				
					
					cFiltro :=  "MBL_FILIAL =  '" + cFilMBL + "' .AND. "+;
									"MBL_CODIGO = '" + MBF->MBF_CODIGO  + "' .AND.  "+;
									"MBL_VLINI <= " + AllTrim(Str(nVlrProd, TamSx3("MBL_VLINI")[1], TamSx3("MBL_VLINI")[2])) + " .AND. "+;
								   "MBL_VLFIM >= " + AllTrim(Str(nVlrProd, TamSx3("MBL_VLFIM")[1], TamSx3("MBL_VLFIM")[2]))
					
					(cAlias)->(dbSetFilter({|| &cFiltro},cFiltro)) 
					(cAlias)->(dbGoTop()) 
			
			   Else                  
			   
					BeginSql Alias "MBLTMP"    
					
						SELECT MBL_CUSTO		
							FROM  %table:MBL%
						WHERE %notDel%
							AND MBL_VLINI <= %exp:nVlrProd% 				
							AND MBL_VLFIM  >= %exp:nVlrProd%	 
							AND MBL_FILIAL = %xFilial:MBL%
							AND MBL_CODIGO = %exp:MBF->MBF_CODIGO%
					EndSql  
			   
			   EndIf   
			   
				If (cAlias)->(!Eof()) .AND. SB1->(DbSeek(cFilSB1 + MBF->MBF_PRDGAR)) 
					nCtGara:= (cAlias)->MBL_CUSTO
				EndIf  
				   
				If lQuery  
					(cAlias)->(DbCloseArea())
				Else
					(cAlias)->(dbClearFilter())  
					RestArea(aAreaMBL)  
				EndIf 
	 	   		
			EndIf 	
		
		 	MBF->(DbSkip(1))
		 	 
		End
		 	 	 	   	
	EndIf  

Else 
	//Busca diretamente pelo produto Garantia
	MBF->(DbSetOrder(1)) //MBF_FILIAL + MBF_PRDGAR + MBF_PRODPR + MBF_GRUPO        
	
	//Primeiramente realiza a busca por produto + Grupo   - cProd
	If MBF->(DbSeek(cFilMBF + cPrdGar + cProd)) .AND. (dDataBase >= MBF->MBF_DTINI .AND. dDataBase <= MBF->MBF_DTFIM)   
		lSeek := .T.
	Else
		MBF->(DbSetOrder(5)) //MBF_FILIAL + MBF_GRUPO + MBF_PRODPR
	
		//Procura vinculo do grupo
		If MBF->(DbSeek( cFilMBF + cGrupoPrd ) ) 
			While MBF->(!EOF()) .AND. MBF->(MBF_FILIAL + MBF_GRUPO) == cFilMBF + cGrupoPrd  
				If MBF->MBF_PRDGAR == cProd .AND. (dDataBase >= MBF->MBF_DTINI .AND. dDataBase <= MBF->MBF_DTFIM )				
					lSeek := .T.
					Exit
				EndIf
				
				MBF->(dbSkip())
			EndDo
		EndIf
	EndIf 	  		 											       			 		   		          
	
	//Se encontrou vinculo continua
	If lSeek
		If !lQuery   			
			aAreaMBL := MBL->(GetArea()) 
			
			cFiltro :=  "MBL_FILIAL =  '" + cFilMBL + "' .AND. "+;
						"MBL_CODIGO = '" + MBF->MBF_CODIGO  + "' .AND.  "+;
						"MBL_VLINI <= " + AllTrim(Str(nVlrProd, TamSx3("MBL_VLINI")[1], TamSx3("MBL_VLINI")[2])) + " .AND. "+;
					   "MBL_VLFIM >= " + AllTrim(Str(nVlrProd, TamSx3("MBL_VLFIM")[1], TamSx3("MBL_VLFIM")[2]))
				
			(cAlias)->(dbSetFilter({|| &cFiltro},cFiltro)) 
			(cAlias)->(dbGoTop()) 		
		Else                  		   
			BeginSql Alias "MBLTMP"    
			
				SELECT MBL_CUSTO			
					FROM  %table:MBL%
				WHERE %notDel%
					AND MBL_VLINI <= %exp:nVlrProd% 				
					AND MBL_VLFIM  >= %exp:nVlrProd%	 
					AND MBL_FILIAL = %xFilial:MBL%
					AND MBL_CODIGO = %exp:MBF->MBF_CODIGO%
			EndSql  		   
		EndIf   
		   
		If (cAlias)->(!Eof())  
			nCtGara:= (cAlias)->MBL_CUSTO
		EndIf  
			   
		If lQuery  
			(cAlias)->(DbCloseArea())
		Else
			(cAlias)->(dbClearFilter())   
			RestArea(aAreaMBL) 
		EndIf 			        	    	    
	EndIf 	   
EndIf
  

Return nCtGara			   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjParamGarºAutor  ³Vendas Clientes     º Data ³  24/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida os parametros obigatorios de garantia estendida      º±±
±±º          | antes da rotina de venda/ troca devolucao   				  	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³void LjCtGarant	                                       	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³nValFin - valor do titulo no financeiro                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   
Function LjParamGar()

Local lRet 		  := .T.                      			// Variavel de retorno logico
Local cMsg        := ''  						  			// Mensagem de retorno
Local cMvLJPRGAR  := SuperGetMv("MV_LJPRGAR",,"") 	// Valida se o Parametro esta preenchido 
Local cMvLJNATRE  := SuperGetMv("MV_LJNATRE",,"") 	// Valida se o Parametro esta preenchido

If Empty(cMvLJPRGAR) .OR. Empty(cMvLJNATRE) .OR. !SuperGetMv("MV_LJGARFP",,.F.)
   
	If Empty(cMvLJPRGAR)
		cMsg+= STR0008+CRLF	//"Obrigatório preencher o parametro MV_LJPRGAR para continuar. "
	EndIf                                                                           
	
   
	If Empty(cMvLJNATRE)
		cMsg+= STR0010+CRLF//"Obrigatório preencher o parametro MV_LJNATRE para continuar. "
	EndIf		
	
	If SuperGetMv("MV_LJFNGE",,.F.) .AND. !SuperGetMv("MV_LJGARFP",,.F.)
		cMsg+= STR0012+CRLF//"Obrigatório definir o conceito do preco para Garantia Estendida como Faixa de preço no parametro MV_LJGARFP."
	EndIf
	MsgInfo(cMsg,STR0011)//"Atenção"
	lRet:= .F.
Else          
    SED->(DbSetOrder(1))
    If !SED->( DbSeek(xFilial("SED")+ PadR(cMvLJNATRE,TamSx3("ED_CODIGO")[1]) ) )
		MsgInfo(STR0013,STR0011)//"Natureza informada no parametro MV_LJNATRE não existe."###"Atenção"
		lRet:= .F.
	EndIf	
EndIf


Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjVlGAdm  ºAutor  ³Vendas Clientes     º Data ³  24/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se o produto selecionado esta vinculado a uma Adm.   º±±
±±º          | Financeira, e valida se a Adm. Fin. esta vinculada a um    º±±
±±º          | Cliente e um Fornecedor                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aProds - Array de produtos garantia                         º±±
±±			  nPos - Posição do Array                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   
Static Function LjVlGAdm(aProds,nPos)

Local lRet		:= aProds[nPos][1] 
Local lContinua	:= ExistFunc("LJ7GrvMFI") .AND. aProds[nPos][1] .AND. AliasIndic("MFI")
Local aAreaSb1	:= SB1->(GetArea())
Local aAreaSa1	:= SA1->(GetArea())
Local aAreaSa2	:= SA2->(GetArea())
Local cMvLjTGar	:= SuperGetMV("MV_LJTPGAR",,"GE") 	// Define se é tipo GE 
Local cMvLjTSf	:= SuperGetMV("MV_LJTPSF",,"SF")	// Define se é tipo SF 

Default aProds := {}
Default nPos   := 0

If SuperGetMv("MV_LJFNGE",,.F.) .AND. lContinua .AND. aProds[nPos][5] == cMvLjTGar
	SB1->(DbSetOrder(1))		//B1_FILIAL+B1_COD
	SB1->( DbSeek(xFilial("SB1")+aProds[nPos][2]))
	If !Empty(SB1->B1_ADMIN)
		SA2->(DbSetOrder(8))		//A2_FILIAL+A2_CODADM
		If !SA2->( DbSeek(xFilial("SA2") + SubStr(SB1->B1_ADMIN,1,TamSX3("A1_COD")[1]) ) )
			Alert(STR0014+SB1->B1_ADMIN+STR0015)//"Administradora financeira (B1_ADMIN) " ###" não esta cadastrada a um Fornecedor."
			lContinua:= .F.
		Endif
		
		SA1->(DbSetOrder(1))		//A1_FILIAL+A1_COD+A1_LOJA
		If lContinua .AND. !SA1->( DbSeek( xFilial("SA1") + SubStr(SB1->B1_ADMIN,1,TamSX3("A1_COD")[1]) ) )
			Alert(STR0014+SB1->B1_ADMIN+STR0016)//"Administradora financeira (B1_ADMIN) "###" não esta cadastrada a um Cliente."
			lContinua:= .F.
		EndIf
		If !lContinua
			lRet:= !lRet
		EndIf
	Else
		Alert(STR0017)//"Administradora financeira (B1_ADMIN) não cadastrada ao produto garantia."
		lRet:= !lRet
	EndIf
	//Validação: se B1_TIPO = "GE", o B1_GARANT não pode ser Sim "1".
	If lRet .AND. SB1->B1_TIPO = cMvLjTGar .AND. SB1->B1_GARANT = "1"
		Alert(STR0029)	//"Este produto do tipo GE foi cadastrado de forma indevida. No Cadastro de Produtos (LOJA110), vá em alterar, e realize o ajuste."
		lRet := .F.
	EndIf
ElseIf lContinua .AND. aProds[nPos][5] == cMvLjTSf
	MG8->(DbSetOrder(2))			//MG8_FILIAL+MG8_PRDSB1
	MG8->( DbSeek(xFilial("MG8")+aProds[nPos][2]))
	
	SA2->(DbSetOrder(8))			//A2_FILIAL+A2_CODADM
	If !SA2->( DbSeek(xFilial("SA2") + SubStr(MG8->MG8_ADMIN,1,TamSX3("A2_COD")[1]) ) )
		Alert(STR0014+MG8->MG8_ADMIN+STR0015)//"Administradora financeira (B1_ADMIN) " ###" não esta cadastrada a um Fornecedor."
		lContinua:= .F.
	Endif
		
	SA1->(DbSetOrder(1))			//A1_FILIAL+A1_COD+A1_LOJA
	If lContinua .AND. !SA1->( DbSeek( xFilial("SA1") + SubStr(MG8->MG8_ADMIN,1,TamSX3("A1_COD")[1]) ) )
		Alert(STR0014+MG8->MG8_ADMIN+STR0016)//"Administradora financeira (B1_ADMIN) "###" não esta cadastrada a um Cliente."
		lContinua:= .F.
	EndIf
		
	If !lContinua
		lRet:= !lRet
	EndIf		
EndIf

RestArea(aAreaSb1)
RestArea(aAreaSa1)
RestArea(aAreaSa2)

Return lRet

      
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IncRegMfi ºAutor  ³Vendas Clientes     º Data ³  24/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a gravacao na tabela de vendas com garantia ou       º±±
±±º          | servicos financeiros										  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³void IncRegMfi(       )                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aRecSL2 - Recno da SL2                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IncMfiSF(cPrefSFA,cTitSFA)
Local cMvLjTSFin	    := SuperGetMV("MV_LJTPSF",,"SF")  // Tipo de Servico cadastrado no produto.  
Local cCodigo := ""                  //MFI_CODIGO
Local cFornecedor := ''              	//Forncedor vinculado na administradora financeira
Local cLojaForn   := ''              	//Loja forncedor vinculado na administradora financeira
Local cCodInt     := ''
local lFinanceiro := .F. // DEFINE SE GERA FINANCEIRO APOS A INCLUSAO DA MFI
Local nCusto:= 0 // custo do servico
Local nVlrUnit	:= 0 //Valor unitario do produto da venda
Local aPrdCober	:= {} //Informacoes do produto de cobertura

Default cPrefSFA	:= ""					// Prefixo do título Serviço Financeiro Avulso, vindo da SE1
Default cTitSFA	:= ""					// Título Serviço Financeiro Avulso, vindo da SE1

If AliasIndic("MFI") 
	//Caso a tabela ainda nao foi criada no banco.
	DbSelectArea("MFI")
	//Venda Assistida
	//Efetua a gravacao na tabela de Controle de Garantia
	SL2->(DbSetOrder(1)	)	
	SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM) )
	While SL2->(!EOF()) .AND.  SL2->L2_FILIAL + SL2->L2_NUM == xFilial( "SL2" ) + SL1->L1_NUM				
		//Verifica se o produto eh do tipo garantia	
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SL2->L2_PRODUTO))
		//Valida se o produto eh do tipo servico financeiro
		If SB1->B1_TIPO <> cMvLjTSFin
			aAdd(aPrdCober, {SL2->L2_ITEM,;
							 SL2->L2_PRODUTO,;							 
							 SL2->L2_VRUNIT})			
			SL2->(DbSkip())					
			Loop
		EndIf
		// Busca codigo interno do produto garantia   			
		SB0->(DbSetOrder(1))
		If SB0->(DbSeek(xFilial("SB0")+ SL2->L2_PRODUTO))
			cCodInt := SB0->B0_CODINTG
		EndIf		 
		MG8->(DbSetOrder(2))		
		If MG8->(DbSeek(xFilial("MG8")+SL2->L2_PRODUTO))

			// Busca o fornecedor vinculado a adm financeira
			SA2->(DbSetOrder(8))  //A2_FILIAL+A2_CODADM
			If SA2->(dbSeek(xFilial("SA2")+MG8->MG8_ADMIN) )
				cFornecedor := SA2->A2_COD
				cLojaForn   := SA2->A2_LOJA
			EndIf			
			cCodigo:= GETSXENUM("MFI","MFI_CODIGO","",1)
			MFI->(DbSetOrder(5))
			While MFI->(DbSeek(xFilial("MFI")+cCodigo))
				ConfirmSx8()
				cCodigo:= GETSXENUM("MFI","MFI_CODIGO","",1)
			EndDo  	
			
			//Busca o custo do servico
			nVlrUnit := 0
			
			nPos := aScan(aPrdCober, {|x| x[1] + x[2] == SL2->(L2_ITEMCOB + L2_PRDCOBE)})
			
			If nPos > 0
				nVlrUnit := aPrdCober[nPos, 3]
			EndIf
									
			nCusto:=Iif(MG8->MG8_TPXPRD == '1',LjSfVl(SL2->L2_PRODUTO,0,nVlrUnit,,.T.,SL2->L2_PRDCOBE),SB1->B1_CUSTD)  		
									
			RecLock("MFI",.T.) 
			REPLACE MFI->MFI_FILIAL		WITH xFilial("MFI")
			REPLACE MFI->MFI_CODIGO		WITH cCodigo
			REPLACE MFI->MFI_NUM			WITH SL2->L2_NUM 
			REPLACE MFI->MFI_ITEM		WITH SL2->L2_ITEM
			REPLACE MFI->MFI_PRODUT		WITH SL2->L2_PRODUTO
			REPLACE MFI->MFI_DESCRI		WITH SL2->L2_DESCRI
			REPLACE MFI->MFI_QUANT		WITH SL2->L2_QUANT
			REPLACE MFI->MFI_VRUNIT		WITH SL2->L2_VRUNIT
			REPLACE MFI->MFI_VLRITE		WITH SL2->L2_VLRITEM
			REPLACE MFI->MFI_VALALT		WITH SL2->L2_VLRITEM
			If TamSX3("MFI_COND")[3] = "C"  //Vejo se o campo MFI_COND é caracter.
				REPLACE MFI->MFI_COND		WITH Str(SL1->L1_COND)
			Else
				REPLACE MFI->MFI_COND		WITH SL1->L1_COND
			EndIf
			REPLACE MFI->MFI_CLIENT		WITH SL1->L1_CLIENTE
			REPLACE MFI->MFI_LOJA		WITH SL1->L1_LOJA
			REPLACE MFI->MFI_VEND		WITH SL2->L2_VEND 
			REPLACE MFI->MFI_SITGAR		WITH '04'
			REPLACE MFI->MFI_NUMLOT		WITH Replicate('',TamSx3('MFI_NUMLOT')[1])
			REPLACE MFI->MFI_NSERIE		WITH ''
			REPLACE MFI->MFI_DOC			WITH ''
			REPLACE MFI->MFI_SERIE		WITH ''
			REPLACE MFI->MFI_EMISSA		WITH dDataBase
			REPLACE MFI->MFI_DTVIGE		WITH dDataBase
			REPLACE MFI->MFI_FIMVIG		WITH MG8->MG8_FIMVIG
			REPLACE MFI->MFI_DIAGAR		WITH MG8->MG8_MESSF * 30  			
			REPLACE MFI->MFI_FILORI		WITH cFilAnt			
			REPLACE MFI->MFI_ADMIN		WITH MG8->MG8_ADMIN
			REPLACE MFI->MFI_CUSTO		WITH nCusto 
			REPLACE MFI->MFI_CODINT		WITH cCodInt
			REPLACE MFI->MFI_FORNEC		WITH cFornecedor			
			REPLACE MFI->MFI_LJFORN		WITH cLojaForn
			REPLACE MFI->MFI_ORIGEM		WITH "SF"
			If MFI->(ColumnPos("MFI_PRESFA")) > 0
				REPLACE MFI->MFI_PRESFA		WITH cPrefSFA
			EndIf
			If MFI->(ColumnPos("MFI_TITSFA")) > 0
				REPLACE MFI->MFI_TITSFA 		WITH cTitSFA
			EndIf
						
			MsUnlock()
			lFinanceiro:=.T.				
		EndIf				
		SL2->(DbSkip())
	EndDo 				

	If lFinanceiro
		GeraFin(SL1->L1_NUM,MG8->MG8_NATURE,MG8->MG8_PREFIX)
	EndIf
EndIf	    


Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJVldCliSfºAutor  ³Vendas Clientes     º Data ³  24/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a verificacao do cliente para a venda do produto     º±±
±±º          | servicos financeiros										  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJVldCliSf()

Local aArea:= GetArea()
Local lRet   := .F.  // variavel de controle 
Local xRet:= Nil // varial para validar as formulas digitadas no cadastro.
Local aFmSA1:={}     // array com as formulas cadastrada para o cliente.
Local aCpoAlt:= {}   // campos que podera ser alterados para o cliente
Local cMsgCpo:= ''   // mensagem campo
Local cMsgFor:= ''   // mensagem formula
Local nRecSa1:= SA1->(Recno())
Local nI:= 1
//Valida se os campos do cadastro de cliente estao preenchidos.
MG7->(DbSetOrder(1))
If MG7->(DbSeek(xFilial('MG7')+MG8->MG8_REGRA))
	While 	MG7->(!EOF()) .AND. MG8->MG8_REGRA == MG7->MG7_CODIGO
		If !Empty(MG7->MG7_CAMPO) 
			If Empty( &('SA1->'+MG7->MG7_CAMPO) )
				If Empty(MG7->MG7_MSGPD)
					SX3->(DbSetOrder(2))
					SX3->(DbSeek(MG7->MG7_CAMPO))
					cMsgCpo+= 'O campo '+Alltrim(X3Titulo())+" ("+Alltrim(MG7->MG7_CAMPO)+") não esta preenchido."+CRLF
					aAdd(aCpoAlt,MG7->MG7_CAMPO)
				Else
					cMsgCpo+= Alltrim(MG7->MG7_MSGPD)+CRLF
					aAdd(aCpoAlt,MG7->MG7_CAMPO)				
				EndIf	
			EndIf
		EndIf
		
		If !Empty(MG7->MG7_FORMUL)
			xRet:= &(Alltrim(MG7->MG7_FORMUL))
			If ValType(xRet) <> "L"
				If Empty(MG7->MG7_MSGPD)
					cMsgFor+="#Erro ao executar a formula# - Retorno deve ser LOGICO."+CRLF				
				Else
					cMsgFor+= Alltrim(MG7->MG7_MSGPD)+CRLF				
				EndIf	
			Else
				If !xRet		
					If Empty(MG7->MG7_MSGPD)
						cMsgFor+="#Erro ao executar a formula# "+CRLF				
					Else
						cMsgFor+= Alltrim(MG7->MG7_MSGPD)+CRLF				
					EndIf					
				EndIf
			EndIf
		EndIf
		MG7->(DbSkip())
	EndDo
	
	If !Empty(cMsgFor)
		If !MsgYesNo("Algumas fórmulas foram criticadas pelo Configurador de Regra de Cliente!"+CRLF+cMsgFor+CRLF+"Deseja continuar a venda?","Atenção")							
			lRet := .T.
		EndIf
	EndIf	
	
	If !lRet .AND. !Empty(cMsgCpo)	
		//Aviso("Atenção",cMsgCpo,{"Ok"},2,"Alguns campos foram criticados pelo Configurador de Regra de Cliente!")//"Atenção"##"Alguns campos foram criticados pelo Configurador de Regra de Cliente!"
		MsgInfo("Alguns campos foram criticados pelo Configurador de Regra de Cliente!"+CRLF+cMsgCpo,"Atenção")//
		AxAltera("SA1",nRecSa1,4,,aCpoAlt)		                               
		lRet:=.T.
	EndIf		
EndIf

RestArea(aArea)
Return lRet




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |Lj7GarTela  ºAutor  ³Vendas CRM          º Data ³  20/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe tela dos produtos que tem Garantia estendida          	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aProds: array com  produtos de garantia estendida            º±±
±±º          ³ lSugestao: Logico que define se tem Garantia estendida       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Retorna um array com os produtos selecionados              	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA701                                                     	º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Lj7SfTela(aProds)

Local oDlg       := Nil 														// Objeto de Tela 
Local olstResul  := Nil														// Objeto de Tela 
Local aHeaders   := {"", STR0001, STR0002,STR0003}            	        // ##"Codigo" ##"Descrição" ## "Preço"
Local aTamHead   := {20,60,100,30}                                         // Definição e tamanho 
Local oOK        := LoadBitmap(GetResources(),"LBOK")                    // Botões de seleção 
Local oNO        := LoadBitmap(GetResources(),"LBNO")						// Botões de seleção
Local obtnInser  := Nil 														// Objeto de Tela 
Local aRetorno   := {}														// Array de Retorno 
Local nRet:= 0 // preco de retorno
Local nI:=1      // contador        
Local lOk:= .F.  //valida botao
Default aProds := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o array com informações para o Grid ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aProds)> 0
	DEFINE MSDIALOG oDlg TITLE STR0023 FROM 178,181 TO 361,689 PIXEL //"Faixa de Preço - Serviço" 			
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria Grid de Resultado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	olstResul := TCBrowse():New( 10,10,230,60, ,aHeaders,aTamHead,;
	oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
	olstResul:SetArray(aProds)
	olstResul:bLine := {||{ If(aProds[olstResul:nAt,01],oOk,oNo),aProds[olstResul:nAt,02],aProds[olstResul:nAt,03],(aProds[olstResul:nAt,04])  } }
	olstResul:bLDblClick := {|| aProds[olstResul:nAt][1] :=  !aProds[olstResul:nAt][1],Iif(aProds[olstResul:nAt][1],LjVldBr(@aProds,olstResul:nAt),),;
								olstResul:DrawSelect(),olstResul:Refresh() }
	obtnInser  := TButton():New( 77,215, STR0005,oDlg,{|| lOk:= .T., oDlg:End() },; //"Ok"
	37,12,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg CENTERED
EndIf

obtnInser  := Nil
olstResul  := Nil
oDlg       := Nil
    
If Len(aProds) > 0 .AND. lOk
	For nI:=1 To Len(aProds)
		If aProds[nI][1]
			nRet:= Val(aProds[nI][4])
			Exit	
		EndIf
	Next nI	
EndIf

Return nRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjSfVl      ºAutor  ³Vendas CRM          º Data ³  08/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o valor/lista de servico financeiro                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ C1- Produto de Garantia					                	º±±
±±º          ³ C2- Produto vendido			                          		º±±       
±±º          ³ N3- Valor do item na tabela SB0                       		º±±  
±±º          ³ C4- Grupo do produto vendido 		                   		º±±  
±±º          ³ N5- Valor da Garantia					                  	º±±    
±±º          ³ L6  Valor de Garantia Localizado?                    		º±±
±±º          ³ A7  Lista de garantia estendida oferecidos               	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA701                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjSfVl(cProd, nVlrIni, nVlrFim, aRet, lCusto, cProdVend)   
							 	
Local aArea 		:= GetArea()             			//WorkArea Ativa
Local aAreaMBF2 	:= MBF->(GetArea())  				//WorkArea MBF
Local aAreaMBL 		:= MBL->(GetArea())  			 	//WorkArea MBL
Local cFilMBF 		:= xFilial("MBF")      				//Filial MBF
Local cFiltro 		:= ""              		    		//Filtro xBase
Local cAlias 		:= "MBL"              			  	//Alias da Tabela
Local cFilMBL 		:= xFilial("MBL")      				//Filial MBL
Local lQuery 		:= .F.              		    	//Query SQL?
Local lSeek			:= .F.								//Encontrou vinculo
local cVazio 		:= ""           	        		//Campo Vazio Query
Local cCodigo 		:= "" 			                 	//MBF_CODIGO
Local cGrupoPrd		:= Posicione("SB1", 1, xFilial("SB1") + cProdVend, "B1_GRUPO")
Local cPicture      := PesqPict("SLR","LR_VLRITEM")		//Picture do Valor Item
Local aAreaSB1		:= SB1->(GetArea())  				//WorkArea do produto
Local cFilSB1		:= xFilial("SB1")    				//Compartilhamento do produto
Local nRet          := 0 								//Retorna o custo da faixa de preco. 

Default aRet		:= {}
Default cProd		:= ""   	// Produto Servico Financeiro 
Default nVlrIni	:= 0  		// Valor do Produto
Default nVlrFim	:= 0  		// Valor       
Default lCusto    	:= .F.		// Custo ou Preco
Default cProdVend	:= ""   	// Produto da Venda

#IFDEF TOP  
	If TcSrvType() <> "AS/400"
		lQuery := .T.	 
		cAlias := "MBLTMP"  
	EndIf	
#ENDIF

SB1->(DbSetorder(1)) //B1_FILIAL + B1_COD  
MBF->(DbSetOrder(1)) //MBF_FILIAL+MBF_PRDGAR+MBF_PRODPR+MBF_GRUPO 

//Produto com serviço vinculado 
If MBF->(DbSeek( cFilMBF + cProd + cProdVend ) ) .AND. (dDataBase >= MBF->MBF_DTINI .AND. dDataBase <= MBF->MBF_DTFIM )  
	lSeek := .T.
Else
	MBF->(DbSetOrder(5)) //MBF_FILIAL + MBF_GRUPO + MBF_PRODPR
	
	//Procura vinculo do grupo
	If MBF->(DbSeek( cFilMBF + cGrupoPrd ) ) 
		While MBF->(!EOF()) .AND. MBF->(MBF_FILIAL + MBF_GRUPO) == cFilMBF + cGrupoPrd  
			If MBF->MBF_PRDGAR == cProd .AND. (dDataBase >= MBF->MBF_DTINI .AND. dDataBase <= MBF->MBF_DTFIM )				
				lSeek := .T.
				Exit
			EndIf
			
			MBF->(dbSkip())
		EndDo
	EndIf
EndIf
	
If lSeek			
	aAreaMBL := MBL->(GetArea()) 
	 	
	 //Inicialmente realiza a busca por produto + Grupo   - cProd
	If !lQuery 
			
		cFiltro :=  	"MBL_FILIAL = '" + cFilMBL + "' .AND. "+;
						"MBL_CODIGO = '" + MBF->MBF_CODIGO  + "' .AND.  "+;
						"MBL_VLINI <= " + AllTrim(Str(nVlrFim, TamSx3("MBL_VLINI")[1], TamSx3("MBL_VLINI")[2])) + " .AND. "+;
					   	"MBL_VLFIM >= " + AllTrim(Str(nVlrIni, TamSx3("MBL_VLFIM")[1], TamSx3("MBL_VLFIM")[2]))
			
		(cAlias)->(dbSetFilter({|| &cFiltro},cFiltro))
		(cAlias)->(dbGoTop())
			
	Else
	   		
		BeginSql Alias "MBLTMP"
			
			SELECT MBL_VALOR,MBL_CUSTO
				FROM  %table:MBL% MBL
			WHERE MBL.%notDel%
				AND MBL_VLINI <= %exp:nVlrFim%
				AND MBL_VLFIM >= %exp:nVlrIni%
				AND MBL_FILIAL = %xFilial:MBL%
				AND MBL_CODIGO = %exp:MBF->MBF_CODIGO%
		EndSql
			
		(cAlias)->(dbGoTop())
	EndIf
				 		   			   	 
	While (cAlias)->(!Eof())
		If !lCusto  
			AAdd(aRet, {.F.,SB1->B1_COD,SB1->B1_DESC, TRANSFORM((cAlias)->MBL_VALOR, cPicture)}) 	
			nRet := (cAlias)->MBL_VALOR
		Else
			nRet := (cAlias)->MBL_CUSTO		    					    
	    EndIf
	    		
	    (cAlias)->(DbSkip())
	EndDo								
				
	If lQuery  
		(cAlias)->(DbCloseArea())
	Else
		(cAlias)->(dbClearFilter()) 
	EndIf 
			
	RestArea(aAreaMBL) 	
EndIf

Return nRet

