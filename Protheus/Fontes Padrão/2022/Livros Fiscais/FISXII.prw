#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISXII
    (Componentização da função MaFisII -
    Calcula PIS/COFINS Importação conforme fórmula IN SRF 572/05)

	@author Rafael Oliveira
    @since 11/05/2020
    @version 12.1.27

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
    cCampo  -> String vinda da pilha do MATXFIS
/*/

/*
FISXII  - Cleber Stenio Santos - 23.03.2009
Calcula PIS/COFINS Importação conforme fórmula IN SRF 572/05
*/
Function FISXII(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc,cCampo)
Local nBsICMFic := 0 //Base ICMS Ficticio para calculo do PIS/COFINS
Local nVlICMFic := 0 //ICMS Ficticio para calculo do PIS/COFINS
Local nIN572x   := 0 //Fórmula x para o cálculo da IN572 considerando IPI Percentual
Local nAliqII   := 0 //Aliquota Imposto Importacao
Local nAliqIPI  := 0 //Aliquota IPI
Local nAliqPIS  := 0 //Aliquota PIS
Local nAliqCOF  := 0 //Aliquota Cofins
Local nAliqICM  := 0 //Aliquota ICMS
Local nBsPISImp := 0 //Base PIS Importacao
Local nBsCOFImp := 0 //Base COFINS Importacao
Local nVlPISImp := 0 //Valor PIS Importacao
Local nVlCOFImp := 0 //Valor COFINS Importacao
Local nVlAduan  := 0 //Valor Aduaneiro
Local nIN572y   := 0 //Fórmula y para o cálculo da IN572 considerando IPI Pauta
Local nIN572w   := 0 //Fórmula w para o cálculo da IN572 considerando IPI Pauta
Local nIN572s   := 0 // Formula de Calculo de Importação de servico
Local nAliqICMNF:= 0 //Aliquota original do ICMS da NF
Local cImpServ	:= "N"
Local nValMaj   := 0
Local nDifVal   := 0
Local nRedPis   := 0
Local nRedCof   := 0
Local nPosTrGII := 0
Local lTribGen := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_II)

DEFAULT cCampo := ""

If !lTribGen

	If aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_CLIFOR] =="F" .And. aNFCab[NF_TPCLIFOR] =="X" .And. Substr(aNfItem[nItem][IT_CF],1,1)=="3" .And. aNFItem[nItem][IT_TS][TS_INTBSIC]$"123"
		IF !Empty(aNfItem[nItem][IT_CODISS]) .And. (aNFItem[nItem][IT_TS][TS_ICM]=="N") .And. (aNFItem[nItem][IT_TS][TS_LFICM] == "N") .And. (aNFItem[nItem][IT_TS][TS_IPI]=="N") .And. (aNFItem[nItem][IT_TS][TS_LFIPI]=="N")  .And. (aNFItem[nItem][IT_TS][TS_ISS] == "S")
			cImpServ := "S"
		EndIf

	//Redução de Pis
	//Produto
	nRedPis := IIf( aNfItem[nItem][IT_PRD][SB_REDPIS] > 0 , aNfItem[nItem][IT_PRD][SB_REDPIS] , nRedPis )
	//Tes. Caso não tenha mantém da variável nRedPis já preenchida anteriormente
	nRedPis :=  IIf( aNFItem[nItem][IT_TS][TS_BASEPIS] > 0 , aNFItem[nItem][IT_TS][TS_BASEPIS] , nRedPis )
	//Exceção Fiscal. Caso não tenha mantém da variável nRedPis já preenchida anteriormente
	nRedPis :=  IIf( !Empty(aNFitem[nItem][IT_EXCECAO]) .And. aNfItem[nItem,IT_EXCECAO,18] > 0 , aNfItem[nItem,IT_EXCECAO,18] , nRedPis )

	nRedPis  := IIf( nRedPis == 0, 1, (1 - (nRedPis/100)) )

	//Redução de Cofins
	//Produto
	nRedCof := IIf( aNfItem[nItem][IT_PRD][SB_REDCOF] > 0 , aNfItem[nItem][IT_PRD][SB_REDCOF] , nRedCof )
	//Tes. Caso não tenha mantém da variável nRedCof já preenchida anteriormente
	nRedCof :=  IIf( aNFItem[nItem][IT_TS][TS_BASECOF] > 0 , aNFItem[nItem][IT_TS][TS_BASECOF] , nRedCof )
	//Exceção Fiscal. Caso não tenha mantém da variável nRedCof já preenchida anteriormente
	nRedCof :=  IIf( !Empty(aNFitem[nItem][IT_EXCECAO]) .And. aNfItem[nItem,IT_EXCECAO,19] > 0 , aNfItem[nItem,IT_EXCECAO,19] , nRedCof )

	nRedCof  := IIf( nRedCof == 0, 1, (1 - (nRedCof/100)) )

		nAliqII   := aNfItem[nItem][IT_ALIQII]/100
		nAliqIPI  := aNFitem[nItem][IT_ALIQIPI]/100

		If aNFItem[nItem][IT_TS][TS_PISCOF] == "1"
			nAliqPIS  := aNFitem[nItem][IT_ALIQPS2]/100
		ElseIf aNFItem[nItem][IT_TS][TS_PISCOF] == "2"
			nAliqCOF  := aNFitem[nItem][IT_ALIQCF2]/100
		ElseIf aNFItem[nItem][IT_TS][TS_PISCOF] == "3"
			nAliqPIS  := aNFitem[nItem][IT_ALIQPS2]/100
			nAliqCOF  := aNFitem[nItem][IT_ALIQCF2]/100
		EndIf

		nAliqICMNF	:= aNFitem[nItem][IT_ALIQICM]/100 							//Salvo para usar no recalculo do ICMS

		IF aSX6[MV_EIC0064]// Define que o valor aduaneiro informado em notas de importação esteja sem o Valor do II
		// Desta forma não preciso tirar o II do val Merc, uma vez que já foi informado sem o II na NF de importação
		nVlAduan    := aNfItem[nItem][IT_VALMERC]
		Else
		//Desta forma retira o II do Val Merc pois ele informou junto
		nVlAduan    := aNfItem[nItem][IT_VALMERC] - aNfItem[nItem][IT_VALII]    //Valor da Mercadoria - Valor do II
		EndIf

		nVlAduan	+= Iif(aNFItem[nItem][IT_TS][TS_DESPPIS] <> "2" .And. aNFItem[nItem][IT_TS][TS_DESPCOF] <> "2", aNfItem[nItem][IT_DESPESA]+aNfItem[nItem][IT_SEGURO]+aNfItem[nItem][IT_FRETE]+aNfItem[nItem][IT_AFRMIMP], 0 )

		//Se Reducao na base de ICMS (aNFItem[nItem][IT_TS][TS_BASEICM]>0)
		//Aliquota ICMS * Aliquota de reducao TES
		//Aplicar a redução na aliquota e calcular PIS/COFINS com a aliquota reduzida
		nAliqICM := IIf( aNFItem[nItem][IT_TS][TS_BASEICM] > 0 , ((aNFitem[nItem][IT_ALIQICM] * aNFItem[nItem][IT_TS][TS_BASEICM]) / 100) / 100 , aNFitem[nItem][IT_ALIQICM] / 100 )

		If !Empty(aNFItem[nItem][IT_EXCECAO]) .And. aNFItem[nItem][IT_EXCECAO][14] > 0
			nAliqICM := ((aNFitem[nItem][IT_ALIQICM] * aNfItem[nItem,IT_EXCECAO,14]) / 100) / 100 //Reducao na base de ICMS
		EndIf

		nAliqICM := Round(nAliqICM*100,2)/100

		//Se não tiver IPI Pauta mas tiver Valor IPI calculado faço o cálculo considerando IPI Percentual
		If Empty(aNfItem[nItem][IT_PAUTIPI]) .And. !Empty(aNfItem[nItem][IT_VALIPI])
			//Fórmula x para o cálculo da IN572 considerando IPI Percentual

			nIN572x :=(1+nAliqICM * (nAliqII+nAliqIPI * (1+nAliqII))) / ((1-nAliqPIS-nAliqCOF)*(1-nAliqICM)) //Não é mais utilizado no cálculo de PIS/Cofins Importaçção, conforme a lei 12.865 de 09/10/2013.

			//Se tiver valor da COFINS já calculado conforme as regras já existentes para a COFINS e
			//Tiver que calcular COFINS Importação eu cálculo considerando o valor da COFINS
			If !Empty(aNfItem[nItem][IT_VALCF2]) .And. aNFItem[nItem][IT_TS][TS_INTBSIC]$"23"
				//Valor do COFINS Importação
				nVlCOFImp:= nAliqCOF * (nVlAduan)
			EndIf
			//Se tiver valor do PIS já calculado conforme as regras já existentes para o PIS e
			//Tiver que calcular PIS Importação eu cálculo considerando o valor de PIS
			If !Empty(aNfItem[nItem][IT_VALPS2]) .And. aNFItem[nItem][IT_TS][TS_INTBSIC]$"13"
				//Valor do PIS Importação
				nVlPISImp:= nAliqPIS * (nVlAduan)
			EndIf
		Else //Se houver IPI Pauta ou Não tiver IPI faço o cálculo considerando IPI Pauta
			//Fórmula y para o cálculo da IN572 considerando IPI Pauta
			nIN572y :=(1+nAliqICM * nAliqII)/((1-nAliqPIS-nAliqCOF)*(1-nAliqICM)) //Não é mais utilizado no cálculo de PIS/Cofins Importaçção, conforme a lei 12.865 de 09/10/2013.
			//Fórmula w para o cálculo da IN572 considerando IPI Pauta
			nIN572w :=(nAliqICM * aNfItem[nItem][IT_PAUTIPI]) / ((1-nAliqPIS-nAliqCOF)*(1-nAliqICM)) //Não é mais utilizado no cálculo de PIS/Cofins Importaçção, conforme a lei 12.865 de 09/10/2013.
			//Se tiver valor da COFINS já calculado conforme as regras já existentes para a COFINS e
			//Tiver que calcular COFINS Importação eu cálculo considerando o valor da COFINS
			If !Empty(aNfItem[nItem][IT_VALCF2]) .And. aNFItem[nItem][IT_TS][TS_INTBSIC]$"23"
				//Valor do COFINS Importação
				nVlCOFImp:= nAliqCOF * (nVlAduan*aNfItem[nItem][IT_QUANT])
			EndIf
			//Se tiver valor do PIS já calculado conforme as regras já existentes para o PIS e
			//Tiver que calcular PIS Importação eu cálculo considerando o valor de PIS
			If !Empty(aNfItem[nItem][IT_VALPS2]) .And. aNFItem[nItem][IT_TS][TS_INTBSIC]$"13"
				//Valor do PIS Importação
				nVlPISImp:= nAliqPIS * (nVlAduan*aNfItem[nItem][IT_QUANT])
			EndIf
		EndIf

		//Base de cálculo ICMS Fictício = (Valor Aduaneiro+imposto importação+IPI)/(1-%ICMS)
		nBsICMFic:= ((nVlAduan+aNfItem[nItem][IT_VALII]) + aNfItem[nItem][IT_VALIPI])/(1-nAliqICM)
		//Valor do ICMS Fictício = Base de cálculo do ICMS * %ICMS
		nVlICMFic:= nBsICMFic * nAliqICM

		If cImpServ == "N"
			//Conforme a lei 12.865 de 09/10/2013, a base de Calculo de PIS/Cofins será comporta apenas no Valor Aduaneiro
			//Base de Cálculo COFINS Importação
			nBsCOFImp := nVlAduan
			nBsCOFImp *= nRedCof
			//Se o IPI compor a base do PIS/COFINS/IR e PIS importação, será agregado ao valor do IPI na base de calculo se o valor do IPI estiver como "calcula = sim" e o Livro Fiscal de IPI estiver diferente de "Tributado" e "Não"
			if aNFItem[nItem][IT_TS][TS_IPIPC]$"1" .AND. aNFItem[nItem][IT_TS][TS_INTBSIC]$"23" .AND. aNFItem[nItem][IT_TS][TS_IPI]$"S" .AND. !aNFItem[nItem][IT_TS][TS_LFIPI]$ "TN"
				nBsCOFImp += aNfItem[nItem][IT_VALIPI]
			endIf

			//Base de Cálculo PIS Importação
			nBsPISImp := nVlAduan
			nBsPISImp *= nRedPis
			//Se o IPI compor a base do PIS/COFINS/IR e COFINS importação, será agregado ao valor do IPI na base de calculo se o valor do IPI estiver como "calcula = sim" e o Livro Fiscal de IPI estiver diferente de "Tributado" e "Não"
			if aNFItem[nItem][IT_TS][TS_IPIPC]$"1" .AND. aNFItem[nItem][IT_TS][TS_INTBSIC]$"13" .AND. aNFItem[nItem][IT_TS][TS_IPI]$"S" .AND. !aNFItem[nItem][IT_TS][TS_LFIPI]$ "TN"
				nBsPISImp += aNfItem[nItem][IT_VALIPI]
			endIf
		Else
			/* Formula para calculo de Pis Cofins Importaçãp de Serviço
			V = o valor pago, creditado, entregue, empregado ou remetido para o exterior, antes da retenção do imposto de renda
			C = alíquota da Contribuição para o Pis/Pasep-Importação
			D = alíquota da Cofins-Importação
			F = alíquota do Imposto sobre Serviços de qualquer Natureza
			Cofins Importação = D*V*Z
			Pis Importação	  = C*V*Z
			Z = (1+F)/(1-C-D)
			Base de Cálculo COFINS/PIS Importação Serviço */

			//Inclui o valor do Imposto de Renda na base de cálculo do PIS e COFINS Importação
			IF xFisGrossIR(nItem, aNFItem, aNfCab, "PISCOFIMP") //Verifica se deverá considerar GrossUp do IRRF na base do PIS e COFINS Importação
				nBsICMFic	:= nBsICMFic / ( 1 - ( aNfItem[nItem][IT_ALIQIRR] / 100 ) )
			EndIF
			nIN572s :=(1+(aNfItem[nItem][IT_ALIQISS]/100))/((1-nAliqPIS-nAliqCOF))
			nBsCOFImp := nBsICMFic * nIN572s
			nBsCOFImp *= nRedCof
			nBsPISImp := nBsICMFic * nIN572s
			nBsPISImp *= nRedPis
		EndIf
		//Atualiza Valores
		If !(cCampo $ 'IT_VALCF2|IT_VALPS2') .And. (!Empty(aNfItem[nItem][IT_VALCF2]) .Or. aNFItem[nItem][IT_TS][TS_CSTCOF] $"73") .And. aNFItem[nItem][IT_TS][TS_INTBSIC]$"23"
			aNfItem[nItem][IT_BASECF2] := nBsCOFImp

			//Nessa situacao, atualizo valor da contribuicao
			/* Se o campo do valor do COFINS majorado (IT_VALCMAJ) for alterado, obtenho o valor original
			do cálculo (nValMaj) e somo a diferença entre o valor digitado e o valor obtido (nDifVal) no
			valor do COFINS importacao (nVlCOFImp) */

			If AllTrim(cCampo) == "IT_VALCMAJ"
				nValMaj := (aNfItem[nItem][IT_BASECF2] * (aNFItem[nItem][IT_TS][TS_ALQCMAJ]/100))
				nDifVal := aNfItem[nItem][IT_VALCMAJ] - nValMaj

				nVlCOFImp	:=	((nBsCOFImp * nAliqCOF) + nDifVal)
			Else
				nVlCOFImp	:=	nBsCOFImp * nAliqCOF
			Endif

			aNfItem[nItem][IT_VALCF2]  := nVlCOFImp

			MaItArred(nItem, { "IT_BASECF2","IT_VALCF2" } )   // Ajusta os arredondamentos do item
		EndIf

		If !(cCampo $ 'IT_VALCF2|IT_VALPS2') .And. (!Empty(aNfItem[nItem][IT_VALPS2]) .Or. aNFItem[nItem][IT_TS][TS_CSTCOF] $"73") .And. aNFItem[nItem][IT_TS][TS_INTBSIC]$"13"
			aNfItem[nItem][IT_BASEPS2] := nBsPISImp

			//Nessa situacao, atualizo valor da contribuicao
			nVlPISImp	:=	nBsPISImp * nAliqPIS

			aNfItem[nItem][IT_VALPS2]  := nVlPISImp

			MaItArred(nItem, { "IT_BASEPS2","IT_VALPS2" } )   // Ajusta os arredondamentos do item
		EndIf

		If aNFItem[nItem][IT_TS][TS_ALQCMAJ] > 0 .And. cCampo <> "IT_VALCMAJ"
			aNfItem[nItem][IT_VALCMAJ] := aNfItem[nItem][IT_BASECF2] * (aNFItem[nItem][IT_TS][TS_ALQCMAJ]/100)
		EndIf

		If aNFItem[nItem][IT_TS][TS_ALQPMAJ] > 0
			aNfItem[nItem][IT_VALPMAJ] := aNfItem[nItem][IT_BASEPS2] * (aNFItem[nItem][IT_TS][TS_ALQPMAJ]/100)
		EndIf

		MaFisBSICM(nItem,,,,cCampo)
		If (aNFItem[nItem][IT_TS][TS_AGRPIS] == "P" .Or. aNFItem[nItem][IT_TS][TS_AGRPIS] == "C") .And. aSX6[MV_REDIMPO]
			aNfItem[nItem][IT_BASEICM]:= aNfItem[nItem][IT_BASEICM]/(1-nAliqICM)
		Else
			aNfItem[nItem][IT_BASEICM]:= aNfItem[nItem][IT_BASEICM]/(1-nAliqICMNF)
		Endif

		If cCampo <> "IT_VALICM"
			MaFisVICMS(nItem) //Recalcula o valor do ICMS
		Else
			MaFisVICMS(nItem, .T.) //Caso haja alteração manual do valor de ICMS, esse valor será levado em consideração.
		EndIf

		//Necessário processar a base de ICMS ST e valor de ICMS ST para que seja calculado considerando os valores atualizados de ICMS
		//e PIS COFINS împortação que foram calculados acima, pois o ICMS ST deverá considerar estes valores atualizados.
		MaFisBSSol(nItem, cCampo)
		MaFisVSol(nItem, cCampo)
	EndIf
Else

	If (nPosTrGII := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_II})) > 0 

		aNfItem[nItem][IT_ALIQII] 	:= aNfItem[nItem][IT_TRIBGEN][nPosTrGII][TG_IT_ALIQUOTA]
		aNfItem[nItem][IT_VALII] 	:= aNfItem[nItem][IT_TRIBGEN][nPosTrGII][TG_IT_VALOR]

	EndIf

EndIf

Return

/*/{Protheus.doc} IIConvRf
	(Função responsavel por converter alteração de referencia legado em referencia do configurador)
	
	@author Erich Buttner
    @since 02/12/2020
    @version 12.1.27

	@param:	
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado	
	ccampo -> Campo que esta sendo alterado	

	/*/
Function IIConvRf(aNfItem,nItem,ccampo)
 Local cCampoConv := ""

	IF cCampo == "IT_VALII"
		cCampoConv := "TG_IT_VALOR"		
	Elseif cCampo == "IT_ALIQII"
		cCampoConv := "TG_IT_ALIQUOTA"				
	Endif
	

Return cCampoConv
