// Rotina que contem funções Relacionadas ao Processo de Trocas //

#include 'protheus.ch'
#include 'parmtype.ch'

user function OGA300XFUN()
  /*/  
   -------------------------------------------------------------------------------------------------------------------------- 
   fOG300ABAR1,FOG300ABAR2,FOG300BAR3 -> Utilizadas na emissão da NF, para utilizar taxa de converção
   do trocas ( Utilizado na Altura do PE M460PRC ) do MATA461
  --------------------------------------------------------------------------------------------------------------------------
  /*/
  	
return

/** {Protheus.doc} fOG300Bar1
Rotina para Calculo da Conversão utilizando a
Taxa de moeda especifica do Acordo de Trocas

@param:		-   Preço de Venda
-	Preço Unitario
@Retorno: 	-	Array com 2 posicoes
-	Array[1]	-> Preço de    Venda Convertido pela Txa do Acordo Trocas
-	Array[2]	-> Preço 	Unitario Convertido pela Txa do Acordo Trocas
@author: 	-	Equipe AgroIndustria
@since: 	-	10/08/2016
@Uso: 		-	SIGAARM - Originação de Grãos
*/
Function fOG300Bar1(nPrcVndaPV, nPrcUnitPV)

	Local nPrcVnda		 := 0
	Local nPrcUnit		 := 0
	

	If Type("lOGNFTRC") == "L" .and.  lOGNFTRC == .t. // Indica que é um processo do Trocas

		/*  Vars Private que Vem do Agra900 // 
		nTRCTotMER    		// Total das Mercadorias Pela NF
		nOgTxTroca 			// Txa Utilizada no Acordo de Trocas
		nTrcTotDoc			// total das Mercadorias Pelo PV
		cDocUltIt  			// identifica o Ultimo item Do Docto SC6->(C6_PEDIDO + C6_ITEM)
		*/
		nPrcVnda	:= fOG300Bar2( nPrcVndaPV )
		nPrcUnit	:= nPrcUnitPV
		 IF .not. nPrcUnit = nPrcUnitPV   		// Vr. de Tabela diferende do Valor de Venda Calcula a  Conversão do Vr.de tabela
		    nPrcUnit := fOG300Bar2( nPrcUnitPV )
		 EndIF 	
	Else // Mesmo não sendo de troca tenho q converter pois estou utilizando o PE, para o padrao devo tirar fora
		nPrcVen	:= xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase,8)
		nPrUnit	:= xMoeda(nPrUnit,SC5->C5_MOEDA,1,dDataBase,8)
	EndIF

return ( {nPrcVnda, nPrcUnit } )


/** {Protheus.doc} fOG300Bar2
Rotina para Calculo da Conversão utilizando a
Taxa de moeda especifica do Acordo de Trocas

@param:		-   Vr. a Converter
@Retorno: 	-	Valor Contertido na  Moeda de BArter
@author: 	-	Equipe AgroIndustria
@since: 	-	10/08/2016
@Uso: 		-	SIGAARM - Originação de Grãos
*/

sTatic Function fOG300Bar2( nPrcVenda ) 

	Local nC6Qtdven	 := SC6->C6_QTDVEN
	Local nC6VALOR	 := SC6->C6_VALOR
	Local nTotItem   := 0
	

	/*  Vars Private que Vem do Agra900 // 
	nTRCTotMER    		// Total das Mercadorias Pela NF
	nOgTxTroca 			// Txa Utilizada no Acordo de Trocas
	nTrcTotDoc			// total das Mercadorias Pelo PV
	cDocUltIt  			// identifica o Ultimo item Do Docto SC6->(C6_PEDIDO + C6_ITEM)
	*/


	//----Variavel Private Agra900 -----

		nTotItem:= A410ARRED(xMoeda(nC6VALOR,SC5->C5_MOEDA,1,ddatabase,8,nOgTxTroca) ,'D2_TOTAL')

		nPrcVenda	:=  a410arred(nTotItem / nC6Qtdven, 'D2_PRCVEN')

		nPrcVenda 	:=  fOG300Bar3(nPrcVenda , nOgTxTroca,.F. )

		nTotItem   	:= A410ARRED( nPrcVenda * SC9->C9_QTDLIB, 'D2_TOTAL') 	//Total Calc. do Item

		IF SC6->(C6_NUM + C6_ITEM ) == cDocUltIt 			// É o Ultimo item do Faturamento da Troca
			IF ! ( nTRCTotMER +  nTotItem ) = nTrcTotDoc	// Indica que o Total da NF. em Moeda 1, NAO Bate com o 
				// Total de Moeda 1 encontrado pelo total dos itens que compoe a NF x pela taxa do trocas
				// Ex total Doc (Baseando em um PV) = 256,24 * Taxa Troca = 66,436 = (256,24 * 66,436 = 17023,56)
				// Tenho que ter o total da NF. exatamente Igual para garantir a Taxa do Trocas 
				//Ajustando o Arredondamento
				nMenorVrUn := 1/VAL('1'+STRZERO(0,TamSx3('C6_PRCVEN')[2]))	// Menor unidade a Adicionar no Vr. Unitario
				IF ( nTRCTotMER +  nTotItem ) > nTrcTotDoc    				// Indica que o Total Calc. na NF. está maior entao tenho q diminuir o Vr. unitario
					nMenorVrUN *= (-1 ) 	//Tenho q Subtrair
				EndIF
				While ! ( nTRCTotMER +  nTotItem ) = nTrcTotDoc
					nPrcVenda += nMenorVrUN
					nTotItem   	:= A410ARRED( nPrcVenda * SC9->C9_QTDLIB, 'D2_TOTAL') 	
				EndDO

				nPrcVenda 	:=  fOG300Bar3(nPrcVenda , nOgTxTroca,.T. )

			EndIF
		ELSE
			nTRCTotMER  += nTotItem
		EndIF
	

return ( nPrcVenda )



/** {Protheus.doc} fOG300Bar3
Função Auxiliar para Averiguar que o vr. de venda/unitario
encontrado na conversão; Se dividido pela taxa de conversão 
resulte no valor unitario do PV;

@param:		-   nPrcVenda	-	Preço de Venda
-	nOgTxTroca	-	Txa de Conversão
-   lUltimItem	-	Indica se é o ultimo Item do docto fiscal
@Retorno: 	-	Preço de Venda
@author: 	-	Equipe AgroIndustria
@since: 	-	10/08/2016
@Uso: 		-	SIGAARM - Originação de Grãos
*/
Static Function fOG300Bar3(nPrcVenda , nOgTxTroca, lUltimItem )
	Local nMenorVrUn	:= 0
	Local nTotitem		:= 0
	Local nPrcVndAux	:= 0

	nMenorVrUn := 1/VAL('1'+STRZERO(0,TamSx3('C6_PRCVEN')[2]))			// Menor unidade a Adicionar no Vr. Unitario

	IF ! a410arred(nPrcVenda / nOgTxTroca, 'C6_PRCVEN') = SC9->C9_PRCVEN .and. ! lUltimItem 	// Indica que o Vr. Unitario encontrado convertido para
		// a Moeda do PV não está correspondente ao do PV
		//Garanto q o Vr. unitario encontrato , qdo convertido para MOEDA do PV
		// Fique igual ao do PV
		IF a410arred(nPrcVenda / nOgTxTroca, 'C6_PRCVEN') > SC9->C9_PRCVEN  // Indica que o Vr. Unitario na Moeda do PV esta <  que o Vr. que está no PV
			nMenorVrUN *= (-1 ) 	//Tenho q Subtrair
		EndIF

		While ! A410ARRED( nPrcVenda / nOgTxTroca, 'C6_PRCVEN') = SC9->C9_PRCVEN
			nPrcVenda += nMenorVrUN
		EndDO

		IF nMenorVrUn > 0
			nMenorVrUN *= (-1 )
		Else
			nMenorVrUN *= ( 1 )
		EndIF

		nTotItem   	:= A410ARRED( nPrcVenda * SC9->C9_QTDLIB, 'D2_TOTAL') 	//Total Calc. do Item

		nPrcVndAux := nPrcVenda
		While (.t.)
			IF A410ARRED( nPrcVndAux * SC9->C9_QTDLIB, 'D2_TOTAL') == nTotItem .and.;
			A410ARRED( nPrcVndAux / nOgTxTroca, 'C6_PRCVEN') == SC9->C9_PRCVEN
				nPrcVenda := nPrcVndAux
				nPrcVndAux += nMenorVrUN
			Else
				Exit
			EndIF
		EndDO
	ElseIF lUltimItem // Quando é o Ultimo 
/*		nTotItem   	:= A410ARRED( nPrcVenda * SC9->C9_QTDLIB, 'D2_TOTAL') 	//Total Calc. do Item

		nPrcVndAux := nPrcVenda
		While (.t.)
			nPrcVndAux += nMenorVrUN
			IF !A410ARRED( nPrcVndAux * SC9->C9_QTDLIB, 'D2_TOTAL') == nTotItem
				Exit
			Else
				nPrcVenda := nPrcVndAux
			EndIF
		EndDO
		*/
	EndIF

Return( nPrcVenda )		


