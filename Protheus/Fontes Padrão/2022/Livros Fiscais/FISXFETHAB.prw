#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FETHAB
    (Componentização da função MaFisFFF - Calculo do FETHAB)
    
    
	@author Rafael.soliveira
    @since 22/01/2020
    @version 12.1.25
    
	@param:
	aNfCab -> Array com dados do cabeçalho da nota
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado
	aPos   -> Array com dados de FieldPos de campos
	aInfNat	-> Array com dados da narutureza
	aPE		-> Array com dados dos pontos de entrada
	aSX6	-> Array com dados Parametros
	aDic	-> Array com dados Aliasindic
	aFunc	-> Array com dados Findfunction
	cPrUm	-> Primeira unidade de medida
	cSgUm	-> Segunda unidade de medida
    /*/
Function FISXFETHAB(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cPrUm, cSgUm)

    Local nIndUpf	:= aNfCab[NF_INDUFP]
    Local nAliq     := 0
    Local nQtdUm    := 0

	aNfItem[nItem][IT_BASEFET] := 0
	aNfItem[nItem][IT_ALIQFET] := 0
	aNfItem[nItem][IT_VALFET]  := 0
    
    //FETHAB - BASE / ALIQUOTA e VALOR
	If  (aPos[FP_B1_AFETHAB]  .And. aPos[FP_A2_RECFET]  .And. aPos[FP_A1_RECFET] .And. aPos[FP_F4_CALCFET] ) .AND. ;
		!(aNfCab[NF_CHKTRIBLEG] .And. ChkTribLeg(aNFItem, nItem, TRIB_ID_FETHAB))

		If aNfItem[nItem][IT_AFETHAB]  > 0  .And. !Empty(aNfItem[nItem][IT_TFETHAB]) .And. aNFItem[nItem][IT_TS][TS_CALCFET] == "1"
			nAliq	  := aNfItem[nItem][IT_AFETHAB]

			If aNfItem[nItem][IT_TFETHAB] $ "125"  // 1 - Soja, 2 - Algodao ou 5 - Milho
				
				If Alltrim(cPrUm) $ "TL|TON|TN"   // E obrigatorio que a primeira ou a segunda unidade de medida seja "TL" ou "TON"
					nQtdUm := aNfItem[nItem][IT_QUANT]
				ElseIf Alltrim(cSgUm) $ "TL|TON|TN"
					nQtdUm := ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2)
				EndIf
				 
				If nQtdUm > 0 
					aNfItem[nItem][IT_BASEFET] := Round((nIndUpf * nAliq /100),2)
					aNfItem[nItem][IT_ALIQFET] := nAliq
					aNfItem[nItem][IT_VALFET]  := Round(((nIndUpf * nAliq /100) * nQtdUm),2)				
				EndIf

				IF aNfCab[NF_RECFET] == "1"
					aNfItem[nItem][IT_VALFETR]	:= aNfItem[nItem][IT_VALFET]
				EndIF

				IF aNfItem[nItem][IT_TFETHAB] == "2"
				 	IF aPos[FP_F4_RFETALG] .AND. aNFItem[nItem][IT_TS][TS_RFETALG] == "2"// Algodão irá verificar retenção no cadastro de TES
						aNfItem[nItem][IT_VALFETR]:= 0 //Se no cadastro do TES estiver igual a SIM então não irá reter FETHAB, se estiver diferente irá considerar o padrão
					ElseIF aNfCab[NF_RECFET] == "1"
						aNfItem[nItem][IT_VALFETR]	:= aNfItem[nItem][IT_VALFET]
					EndIF

				EndIF

			ElseIf aNfItem[nItem][IT_TFETHAB] == "3" //  3 - Gado

				If Alltrim(cPrUm) $ "UN"  // E obrigatorio que a primeira ou a segunda unidade de medida seja "UN"
					nQtdUm := aNfItem[nItem][IT_QUANT]
				ElseIf Alltrim(cSgUm) $ "UN"
					nQtdUm := ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2)
				EndIf

				If nQtdUm > 0
					aNfItem[nItem][IT_BASEFET] := Round((nIndUpf * nAliq /100),2)
					aNfItem[nItem][IT_ALIQFET] := nAliq
					aNfItem[nItem][IT_VALFET]  := Round(((nIndUpf * nAliq /100) * nQtdUm),2)				
				EndIf

				IF aNfCab[NF_RECFET] == "1"
					aNfItem[nItem][IT_VALFETR]	:= aNfItem[nItem][IT_VALFET]
				EndIF

			ElseIf aNfItem[nItem][IT_TFETHAB] == "4" //Madeira

				If Alltrim(cPrUm) $ "M3"  // E obrigatorio que a primeira ou a segunda unidade de medida seja "M3"
					nQtdUm := aNfItem[nItem][IT_QUANT]
				ElseIf Alltrim(cSgUm) $ "M3"
					nQtdUm := ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2)
				EndIf

				If nQtdUm > 0
					aNfItem[nItem][IT_BASEFET] := Round((nIndUpf * nAliq /100),2)
					aNfItem[nItem][IT_ALIQFET] := nAliq
					aNfItem[nItem][IT_VALFET]  := Round(((nIndUpf * nAliq /100) * nQtdUm),2)				
				EndIf
				
				IF aNfCab[NF_RECFET] == "1"
					aNfItem[nItem][IT_VALFETR]	:= aNfItem[nItem][IT_VALFET]
				EndIF
			EndIf
		EndIf
	EndIf

Return

