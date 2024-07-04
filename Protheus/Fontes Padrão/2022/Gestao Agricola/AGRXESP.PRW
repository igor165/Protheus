#include 'protheus.ch'

Static __aTab1223 := {"N78","N7E","N7F","N7G","N7H","N7J","N7R","N84","N9A"} //tabelas fonte inova็ใo liberada na P12.1.23
Static __lLib1223 := Nil //__lLib1223 - prote็ใo fonte inova็ใo liberado na P12.1.23

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRX001  บAutor  ณ Ricardo Tomasi     บ Data ณ  12/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa para converter unidades de medida, baseado na ta- บฑฑ
ฑฑบ          ณ bela de Conversใo de Unidades de Medida do SIGAAGR.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRX001(pUMOrig, pUMDest, nValor, cProduto)
	Local aAreaAnt   := GetArea()
	Local nValConv   := 0
	Local nFatorConv := 0
	Local cUMOrig    := PadR(pUMOrig, TamSX3("NNX_UMORIG")[1], ' ')
	Local cUMDest    := PadR(pUMDest, TamSX3("NNX_UMDEST")[1], ' ')
	Default cProduto := ""

	__lLib1223 := AGRTABDIC(__aTab1223) //verifica se array de tabelas existe no dicionario de dados - para prote็ใo fonte P12.1.23

	dbSelectArea('NNX')
	dbSetOrder(1)
	If dbSeek(xFilial('NNX')+cUMOrig+cUMDest)
		
		If __lLib1223
			//verifica se foi informado o produto
			if valtype(cProduto) <> "U" .and. !empty(cProduto)
				dbSelectArea('N8E')
				dbSetOrder(1)
				If dbSeek(xFilial('N8E')+cUMOrig+cUMDest+cProduto)
					nFatorConv := N8E->N8E_FATOR
				else
					nFatorConv := NNX->NNX_FATOR
				endif
			else
				nFatorConv := NNX->NNX_FATOR
			endif
		Else
			nFatorConv := NNX->NNX_FATOR
		EndIf	
	
		Do Case
			Case NNX->NNX_OPERA == '/'
				nValConv := nValor / nFatorConv
			Case NNX->NNX_OPERA == '*'
				nValConv := nValor * nFatorConv
			OtherWise
				nValConv := nValor
		EndCase
		
	Else
		If dbSeek(xFilial('NNX')+cUMDest+cUMOrig)
			
			If __lLib1223
				//verifica se foi informado o produto
				if valtype(cProduto) <> "U" .and. !empty(cProduto)
					dbSelectArea('N8E')
					dbSetOrder(1)
					If dbSeek(xFilial('N8E')+cUMDest+cUMOrig+cProduto)
						nFatorConv := N8E->N8E_FATOR
					else
						nFatorConv := NNX->NNX_FATOR
					endif
				else
					nFatorConv := NNX->NNX_FATOR
				endif
			Else
				nFatorConv := NNX->NNX_FATOR
			EndIf	
			
			Do Case
				Case NNX->NNX_OPERA == '/'
					nValConv := nValor * nFatorConv
				Case NNX->NNX_OPERA == '*'
					nValConv := nValor / nFatorConv
				OtherWise
					nValConv := nValor
			EndCase 
		Else
			nValConv := nValor
		EndIf
	EndIf

	RestArea(aAreaAnt)
Return(nValConv)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRX003  บAutor  ณGilson Venturi      บ Data ณ  15/04/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para conversใo unidade de medida nos contratos de   บฑฑ
ฑฑบ          ณ compra e venda, alinhando com o que materiais trabalha     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function AGRX003(cProduto, cUmPreco, nVlrUnit, nArred )

	Local aAreaAtu	:= GetArea()
	Local cUnPro		:= ""
	Local nFator		:= 0
	Local nPreco		:= 0


	cUnPro	:= Posicione( "SB1", 1, xFilial( "SB1" ) + cProduto, "B1_UM" )
	nFator	:= AGRX001( cUmPreco, cUnPro , 1, cProduto )
	nPreco	:= Round( nVlrUnit / nFator , nArred )  // arredondar pelas decimais do campo

	RestArea(aAreaAtu)
Return(nPreco)

