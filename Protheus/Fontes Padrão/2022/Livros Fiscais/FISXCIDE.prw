#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISxCide
    (Componentização da função MaFisCIDE - 
    Calculo da Contribuições de Intervenção no Domínio Econômico (CIDE))    
    
	@author Renato Rezende
    @since 17/02/2020
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
    cExecuta-> String vinda da pilha do MATXFIS
    /*/
Function FISxCide(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cExecuta)
Local lTribGen 		:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_CIDE)
Local nPosTgCIDE 	:= 0

DEFAULT cExecuta := "BSE|ALQ|VLR"

If !lTribGen
	//zero ao trocar natureza/tes/vlmerc e outros que impactam
	IF cExecuta == "BSE|ALQ|VLR"
		aNfItem[nItem][IT_ALQCIDE]:=0
		aNfItem[nItem][IT_BASECID]:=0
		aNfItem[nItem][IT_VALCIDE]:=0
		//se tiver pauta no item dou preferencia a pauta,coforme DT TVNADZ_DT_Calculo_do_CIDE_por_Pauta
		If aNfItem[nItem][IT_VLRCID] == 0
			aNfItem[nItem][IT_ALQCIDE] := aInfNat[20]
		EndIF
	ENDIF

	//aInfNat[19] == "S" .And. .And. aNfCab[NF_RECCIDE] == "1"
	IF aNfCab[NF_OPERNF] == "E"

		If aInfNat[19] == "S" .And. aNfCab[NF_RECCIDE] == "1" .AND. aNfItem[nItem][IT_ALQCIDE] > 0 .AND. aNfItem[nItem][IT_BASECID] == 0
			// a BC da CIDE passa a ser montada com a referência IT_VALMERC
			aNfItem[nItem][IT_BASECID] := (aNfItem[nItem][IT_VALMERC] * ( Iif(!Empty(aInfNat[21]),aInfNat[21]/100,1)))
			//calculo a base se tiver aliquota, pois pode ser considerado como PAUTA
			//Adiciona o valor do Imposto de renda na base de cálculo da CIDE
			If xFisGrossIR(nItem, aNFItem, aNfCab, "CIDE") //Verifica se deverá considerar GrossUp do IRRF na Base da Cide
				aNfItem[nItem][IT_BASECID]	:= aNfItem[nItem][IT_BASECID] / ( 1 - ( aNfItem[nItem][IT_ALIQIRR] / 100 ) )
				If aNfCab[NF_GROSSIR] == "3"
					aNfItem[nItem][IT_BASECID]	:= aNfItem[nItem][IT_BASECID] / ( 1 - ( aNfItem[nItem][IT_ALIQISS] / 100 ) )
				EndIf
			EndIf
		EndIf

		//se for valor, ele já efetua o mafisalt
		IF "BSE" $ cExecuta .OR. "ALQ" $ cExecuta
			//quando não houver aliquota, calculo como pauta.
			If aNfItem[nItem][IT_VLRCID] > 0 .AND. aNfItem[nItem][IT_ALQCIDE] == 0
				aNfItem[nItem][IT_BASECID] := 0
				aNfItem[nItem][IT_ALQCIDE] := 0
				aNfItem[nItem][IT_VALCIDE] := aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_VLRCID]
			Else
				aNfItem[nItem][IT_VALCIDE] := aNfItem[nItem][IT_BASECID] * (aNfItem[nItem][IT_ALQCIDE]/100)
			Endif
		EndIf
	EndIf
Else

	IF (nPosTgCIDE := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_CIDE})) >0  
	
		aNfItem[nItem][IT_ALQCIDE]:= aNfItem[nItem][IT_TRIBGEN][nPosTgCIDE][TG_IT_ALIQUOTA]
		aNfItem[nItem][IT_BASECID]:= aNfItem[nItem][IT_TRIBGEN][nPosTgCIDE][TG_IT_BASE]
		aNfItem[nItem][IT_VALCIDE]:= aNfItem[nItem][IT_TRIBGEN][nPosTgCIDE][TG_IT_VALOR]
	Endif
	

EndIf

/*/{Protheus.doc} CIDEConvRf
	(Função responsavel por converter alteração de referencia legado em referencia do configurador)
	
	@author Rafael Oliveira
    @since 23/11/2020
    @version 12.1.27

	@param:	
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado	
	ccampo -> Campo que esta sendo alterado	

	/*/
Function CIDEConvRf(aNfItem,nItem,ccampo)
 Local cCampoConv := ""

	IF cCampo == "IT_VALCIDE"
		cCampoConv := "TG_IT_VALOR"		
	Elseif cCampo == "IT_BASECID"	
		cCampoConv := "TG_IT_BASE"				
	Elseif cCampo == "IT_ALQCIDE"
		cCampoConv := "TG_IT_ALIQUOTA"				
	Endif
	

Return cCampoConv

