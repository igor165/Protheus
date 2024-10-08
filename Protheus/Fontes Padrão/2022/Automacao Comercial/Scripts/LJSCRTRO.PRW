#INCLUDE "PROTHEUS.CH" 
#INCLUDE 'parmtype.ch'

/*/
|| IMPORTANTE: Toda altera��o efetuada neste fonte DEVE OBRIGATORIAMENTE ser feita tamb�m no fonte LOJRTROCA.PRW
/*/

/*/{Protheus.doc} LJSCRTRO
Verifica a existencia do RDMake padr�o LOJRTROCA compilado no RPO, caso n�o exista envia para a LJRUNSCRTR para realizar a impress�o.
@type		Function
@author		JMM
@since1		23/12/2020
@version	12.1.27
@return 
/*/
Function LJSCRTRO(cNumCupom, lNFiscal, nHdlECF)

If ExistBlock("LOJRTROCA")
	U_LOJRTROCA(cNumCupom, lNFiscal, nHdlECF)
Else
    LJRUNSCRTR(cNumCupom, lNFiscal, nHdlECF)
EndIf

return

//-------------------------------------------------------------------
/*/{Protheus.doc} LJRUNSCRTR
Faz a impressao do cupom de vale troca

@param	cNumCupom - Numero do cupom
		lNFiscal - Documento fiscal 
@author  JMM
@version V12.1.25
@since   12/2019
@return  

@obs     
/*/
//-------------------------------------------------------------------

Static Function LJRUNSCRTR( cNumCupom, lNFiscal, nHdlECF)
Local aArea       		:= GetArea()              			// Salva a area corrente
Local aAreaSL2      	:= SL2->(GetArea())        			// Salva a area corrente
Local nX          		:= 0                      			// Contador
Local cCabecalho		:= ""								// Cabe�alho da impress�o
Local cRodape     		:= ""								// Rodape da impress�o
Local cDadosOrc			:= ""								// Dados da venda
Local cItem				:= ""								// Item da troca
Local cTexto      		:= ""								// Auxiliar para a gera��o do texto
Local lPOS		  		:= STFIsPOS() 						// Pos?
Local nLarCup	  		:= 0								// Largura do cupom
Local cCodBarra   		:= ""								// C�digo de barras para impressora n�o fiscal
Local lValTroca   		:= SuperGetMV( "MV_VLTROCA",,.F. )	// Imprime vale-troca
Local aImp				:= {}								// Dados para a impress�o
Local aSM0Data  		:= {} 								// Dados da empresa
Local aImpItens   		:= {}								// Produtos selecionados com vale troca (utilizado TOTVS PDV) 
Local lImprime			:= .F.								// Indica se ser� impresso
Local cBoldIni 			:= ""								//Inicia Texto em Negrito
Local cBoldFim 			:= ""								//finaliza texto em negrito
Local cCenterIni  		:= ""								//centralizado
Local cCenterFim  		:= ""								//centralizado
Local cGuiIni	  		:= ""								//ativa guilhotina
Local cGuiFim	  		:= ""								//finaliza guilhotina

Default nHdlECF   	:= -1									// Comunica��o com a DLL
Default lNfiscal  	:= .T.									// Se � uma empressora Fiscal ou N�o Fiscal
Default cNumCupom 	:= ""									// Numero do documento


If __FWLibVersion() > "20200101"
	aSM0Data := FWSM0Util():GetSM0Data(,,{"M0_NOMECOM","M0_CGC","M0_ENDCOB","M0_CIDCOB","M0_ESTCOB"}) // Dados da empresa
Else
	aSM0Data := {{"M0_NOMECOM",SM0->M0_NOMECOM},{"M0_CGC",SM0->M0_CGC},{"M0_ENDCOB",SM0->M0_ENDCOB},{"M0_CIDCOB",SM0->M0_CIDCOB},{"M0_ESTCOB",SM0->M0_ESTCOB}} // Dados da empresa
EndIf 

If lPOS
	nLarCup 	:= STFGetStation("LARGCOL")
	aImpItens 	:= STIGetCVTs()
	
Else 
	nLarCup	:= LJGetStation("LARGCOL")
EndIf

If lNFiscal
	cBoldIni 	:= "<b>"		//Inicia Texto em Negrito
	cBoldFim 	:= "</b>"		//finaliza texto em negrito
	cCenterIni  := "<ce>"		//centralizado
	cCenterFim  := "</ce>"		//centralizado
	cGuiIni	  	:= "<gui>"		//ativa guilhotina
	cGuiFim	  	:= "</gui>"		//finaliza guilhotina
EndIf 

cCabecalho :=  PadC( 			AllTrim(aSM0Data[1,2]), nLarCup ) 	+ CHR(10) // -- Nome Fantasia
cCabecalho +=  PadC( "CNPJ: " + AllTrim(aSM0Data[2,2]), nLarCup ) 	+ CHR(10) // -- CNPJ
cCabecalho +=  PadC( 			AllTrim(aSM0Data[3,2]), nLarCup ) 	+ CHR(10) // -- Endere�o
cCabecalho +=  PadC( 			AllTrim(aSM0Data[4,2]) 				+ " - " + AllTrim(aSM0Data[5,2]), nLarCup) 	+ CHR(10)	+	CHR(10) // -- Cidade / Estado
cCabecalho +=  PadC(cCenterIni + "  C U P O M  D E  T R O C A " + cCenterFim, nLarCup)					+ CHR(10)	+	CHR(10)

cDadosOrc := CHR(10)
cDadosOrc += PadR(cBoldIni + "Or�amento         : " + cBoldFim + SL1->L1_NUM, nLarCup) 																		+ CHR(10)
cDadosOrc += PadR(cBoldIni + "Cliente           : " + cBoldFim + SL1->L1_CLIENTE + "/" + SL1->L1_LOJA, nLarCup) 												+ CHR(10) 
cDadosOrc += PadR(cBoldIni + "Nome do Cliente   : " + cBoldFim + Posicione("SA1",1,xFilial("SA1") + SL1->L1_CLIENTE + SL1->L1_LOJA,"SA1->A1_NOME"), nLarCup) 	+ CHR(10)
cDadosOrc += PadR(cBoldIni + "Vendedor          : " + cBoldFim + SL1->L1_VEND, nLarCup) 																		+ CHR(10)
cDadosOrc += PadR(cBoldIni + "Nome do Vendedor  : " + cBoldFim + Posicione("SA3",1,xFilial("SA3") + SL1->L1_VEND,"A3_NOME"), nLarCup) 						+ CHR(10)+CHR(10)

DbSelectArea("SL2")
SL2->(DbSetOrder())

If DbSeek(xFilial("SL2") + SL1->L1_NUM)
	While xFilial("SL1") + SL1->L1_NUM == xFilial("SL2") + SL2->L2_NUM
		
		If lPos 
			If !lValTroca .AND. aScan(aImpItens,SL2->L2_ITEM) == 0
				SL2->(DbSkip())
				Loop
			Else
				lImprime := .T.
			EndIf
		EndIf 

		If SL2->L2_VLTROCA == "1" .Or. lImprime
			
			For nX := 1 To SL2->L2_QUANT
				cTexto := cCabecalho + cDadosOrc

				cItem := PadR(cBoldIni + "Item   : " + cBoldFim + SL2->L2_ITEM	, nLarCup) + CHR(10)
				cItem += PadR(cBoldIni + "C�digo : " + cBoldFim + SL2->L2_PRODUTO	, nLarCup) + CHR(10)
				cItem += PadR(cBoldIni + "Produto: " + cBoldFim + SL2->L2_DESCRI	, nLarCup) + CHR(10)

				cTexto 		+= CHR(10) + cItem
				cTexto 		+= CHR(10)
				cCodBarra	:= Lj720CdBar(SL1->L1_DOC, SL1->L1_SERIE, SL2->L2_ITEM, Nil)[5]
				cRodape 	:= CHR(10) + CHR(10) + cCenterIni + " Apresente este cupom para efetuar a troca " + cCenterFim	// Rodap� da impress�o
				If lNFiscal
					cTexto 		+= cCenterIni + "<code128>" + cCodBarra + "</code128>" + cCodBarra + cCenterFim
					cTexto		+= cRodape + CHR(10) + CHR(10) + CHR(10) 
					AAdd(aImp,{cTexto,cCodBarra,cRodape})
				Else
					cRodape := cCodBarra + CHR(10) + CHR(10) + cRodape + CHR(10) + CHR(10) 
					AAdd(aImp,{cTexto,cCodBarra,cRodape})
				EndIf 

			Next nX
		EndIf
		SL2->(DbSkip())
	EndDo
	
	For nX := 1 To Len(aImp)
		If lNFiscal
			If lPOS
				STWPrintTextNotFiscal(aImp[nX,1] + cGuiIni + cGuiFim)
			Else
				INFTexto(aImp[nX,1] + cGuiIni + cGuiFim)
			EndIf
		Else
			If lPOS
				STFFireEvent(	ProcName(0)		,;		// Nome do processo
								"STPrntBarCode"	,;		// Nome do evento
								{	aImp[nX,1]	,;		// 01 - Cabecalho
									aImp[nX,2]	,; 		// 02 - Codigo de barras
									aImp[nX,3]	,;		// 03 - Rodape
								1				})		// 04 - Numero de vias
			Else
				IFCodBar( nHdlECF, aImp[nX,1],aImp[nX,2] , aImp[nX,3] ,1)
			EndIf		
		EndIf 
	Next

EndIf

RestArea( aAreaSL2 )
RestArea( aArea )

Return