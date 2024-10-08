#include 'protheus.ch'

Static __aTab1223 := {"N78","N7E","N7F","N7G","N7H","N7J","N7R","N84","N9A"} //tabelas fonte inova��o liberada na P12.1.23
Static __lLib1223 := Nil //__lLib1223 - prote��o fonte inova��o liberado na P12.1.23

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGRX001  �Autor  � Ricardo Tomasi     � Data �  12/07/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     � Programa para converter unidades de medida, baseado na ta- ���
���          � bela de Convers�o de Unidades de Medida do SIGAAGR.        ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AGRX001(pUMOrig, pUMDest, nValor, cProduto)
	Local aAreaAnt   := GetArea()
	Local nValConv   := 0
	Local nFatorConv := 0
	Local cUMOrig    := PadR(pUMOrig, TamSX3("NNX_UMORIG")[1], ' ')
	Local cUMDest    := PadR(pUMDest, TamSX3("NNX_UMDEST")[1], ' ')
	Default cProduto := ""

	__lLib1223 := AGRTABDIC(__aTab1223) //verifica se array de tabelas existe no dicionario de dados - para prote��o fonte P12.1.23

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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGRX003  �Autor  �Gilson Venturi      � Data �  15/04/2015 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o para convers�o unidade de medida nos contratos de   ���
���          � compra e venda, alinhando com o que materiais trabalha     ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

