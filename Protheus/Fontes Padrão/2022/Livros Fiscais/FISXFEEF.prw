#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISXFEEF
    Componentiza��o da fun��o MaFisFEEF
    Fundo Estadual de Equil�brio Fiscal � FEEF
        
	@author Rafael Oliveira
    @since 06/04/2020
    @version 12.1.27
    
    @Autor da un��o original 
	Simone dos Santos Oliveira # 22/02/2017

	@param:
	aNfCab -> Array com dados do cabe�alho da nota
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado
	aPos   -> Array com dados de FieldPos de campos
	aInfNat	-> Array com dados da narutureza
	aPE		-> Array com dados dos pontos de entrada
	aSX6	-> Array com dados Parametros
	aDic	-> Array com dados Aliasindic
	aFunc	-> Array com dados Findfunction	
*/

Function FISXFEEF(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc)
local nVlrBaseIs    := 0
local nIsenFEEF	    := 0
local nVlrBase	    := 0
local nDifVlr	    := 0
local nRedFEEF	    := 0
local nVlrBaseST    := 0
local nDifVlrST	    := 0
local nRedSTFEEF    := 0

local nICMSDif	    := 0
local nICMCDif	    := 0
local nDifVlrDif    := 0
local nDifFEEF	    := 0
local nVlrBaseCr    := 0
local nCrPreFEEF    := 0
local nReduzICMS    := 0
local nRedBaST	    := 0
local nValIcIsen    := 0
local nAliqFEEF	    := 0
local nBaseCompl    := 0
local nValoCompl    := 0
local nVlrMerc	    := 0
local nPercRdICM    := 0
local nBaseICCmp    := 0
local nAliqICCmp    := 0
local nValoICCmp    := 0
Local lDevCompra    := aNfCab[NF_TIPONF] == "D" .And. aNfCab[NF_OPERNF] == "S" .And. aNFCab[NF_CLIFOR] == "F" .And. !Empty(aNFItem[nItem][IT_RECORI])
Local nAliqRed      := 0
Local lTribGen 		:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_FEEF)
Local nPosTgFEEF 	:= 0

If !lTribGen
	aNfItem[nItem][IT_BASFEEF]	:=	0
	aNfItem[nItem][IT_ALQFEEF]	:=	0
	aNfItem[nItem][IT_VALFEEF]	:=	0
	// Nova Regra # Verifico primeiro se h� configura��o na CFC com os devidos campos e caso n�o haja, busca o legado.
	// Se for utilizar nova regra pela CFC dever� preencher o campo Calc. FEEF ? (F4_FEEF) na TES para definir se c�lcula ou n�o. Caso a configura��o seja pelo legado (TES), o campo F4_FEEF poder� estar em branco.
	if aNfItem[nItem][IT_UFXPROD][UFP_ALFEEF] > 0 .and. aNFItem[nItem][IT_TS][TS_FEEF]== '1'  //Calcula FEEF = Sim
		nAliqFEEF:= aNfItem[nItem][IT_UFXPROD][UFP_ALFEEF]
	elseif (aNFItem[nItem][IT_TS][TS_ALQFEEF] > 0) .and. ( empty(aNFItem[nItem][IT_TS][TS_FEEF]) .or. aNFItem[nItem][IT_TS][TS_FEEF]== '1'  ) //legado
		nAliqFEEF:= aNFItem[nItem][IT_TS][TS_ALQFEEF]
	endif
	// Verifica se dever� calcular o FEEF, considerando configura��o da TES ou UF X UF (Tabela CFC)
	If nAliqFEEF > 0
		/* Redu��o de Base de C�lculo  */
		// Carrega a reducao da base do ICMS
		If ! empty(aNFitem[nItem,IT_EXCECAO]) .And. aNfItem[nItem,IT_EXCECAO,14] > 0
			nReduzICMS := aNfItem[nItem,IT_EXCECAO,14]
		Else
			nReduzICMS := aNFItem[nItem][IT_TS][TS_BASEICM]
		EndIf
		if nReduzICMS > 0 //Se a vari�vel possuir valor a redu��o foi carregada pela exce��o ou TES
			//Fa�o a convers�o do percentual de redu��o conforme esperado pelo c�lculo. Exemplo: Para termos 40% de redu��o, informamos 60. O valor esperado para o c�lculo nesse caso � 0,4.
			nReduzICMS := 1 - (nReduzICMS/100)
			//Converto a aliquota de ICMS conforme esperado pelo c�lculo de redu��o
			nAliqRed := aNfItem[nItem][IT_ALIQICM]/100
			//Base do ICMS
			nVlrBase := aNfItem[nItem][IT_BASEICM] + aNfItem[nItem][IT_LIVRO][LF_OUTRICM] + aNfItem[nItem][IT_LIVRO][LF_ISENICM]
			//Calcula a diferen�a entre o valor do ICMS original com o valor do ICMS com Redu��o
			//Esse c�lculo foi implementado a partir da issue https://jiraproducao.totvs.com.br/browse/DSERFIS1-15774, com respaldo na RESOLU��O SEFAZ N� 33 DE 30 DE MAR�O DE 2017 do estado do Rio de Janeiro
			nDifVlr := (nVlrBase * (1 - (nAliqRed * (1 - nReduzICMS))) / (1 - nAliqRed)) - nVlrBase
			//Valor FEEF - Redu��o Base de C�lculo
			nRedFEEF := nDifVlr * nAliqFEEF / 100
		endif
		/* Isen��o */
		If !(nReduzICMS > 0) // Caso n�o tenha redu��o, entro para fazer o c�lculo do isento
			nVlrBaseIs := aNfItem[nItem][IT_LIVRO][LF_ISENICM]
			if nVlrBaseIs > 0 
				//Verifico o valor que seria pago caso n�o houvesse isen��o
				nValIcIsen := nVlrBaseIs * aNfItem[nItem][IT_ALIQICM] / 100
				//Valor FEEF - Isen��o
				nIsenFEEF := nValIcIsen * nAliqFEEF / 100
			endif
		endif
		/* Redu��o de Base de C�lculo - ST  */
		// Carrega a reducao da base do ICMS ST
		nRedBaST	  := Iif(Len(aNFItem[nItem][IT_EXCECAO]) > 0 .And. aNFItem[nItem][IT_EXCECAO][26] > 0,aNFItem[nItem][IT_EXCECAO][26],aNFItem[nItem][IT_TS][TS_BSICMST])
		if nRedBaST > 0
			//Verifica se houve redu��o de ICMS ST
			nVlrBaseST := aNfItem[nItem][IT_BASESOL] + aNfItem[nItem][IT_LIVRO][LF_OUTRICM]
			//Calcula a diferen�a entre o valor do ICMS original e o valor do ICMS com redu��o
			nDifVlrST := (nVlrBaseST * aNfItem[nItem][IT_ALIQSOL] / 100) - aNfItem[nItem][IT_VALSOL]
			//Valor FEEF - Redu��o Base de C�lculo ST
			nRedSTFEEF := nDifVlrST * nAliqFEEF / 100
		endif
		/* Diferimento  */
		//Calcula a diferen�a entre o valor do ICMS sem Diferimento e o valor do ICMS D
		nDifVlrDif := aNfItem[nItem][IT_ICMSDIF]

		if nDifVlrDif > 0
			//Valor FEEF - Diferimento
			nDifFEEF := nDifVlrDif * nAliqFEEF / 100
		endif
		/* Credito Presumido  */
		//Valor da Base Cr�dito Presumido
		nVlrBaseCr := aNfItem[nItem][IT_LIVRO][LF_CRDPRES]
		if nVlrBaseCr > 0
			//Calcula o valor do FEEF
			nCrPreFEEF := nVlrBaseCr * nAliqFEEF / 100
		endif
		/* C�lculo do FEEF sobre o diferencial de al�quota com benef�cios */
		If aNfItem[nItem][IT_BSICARD] > 0 .and. aNfItem[nItem][IT_VLICARD] > 0
			nVlrMerc 	:=	aNfItem[nItem][IT_VALMERC] 								//Valor de Compra da Mercadoria				//O2
			nBaseICCmp	:=	aNfItem[nItem][IT_BSICARD]								//Base ICMS Complementar					//T2
			nAliqICCmp	:=	aNfItem[nItem][IT_ALIQCMP] - aNFItem[nItem,IT_ALIQICM]	//Aliquota ICMS Comp.						//U2
			nValoICCmp	:=	(nBaseICCmp * nAliqICCmp) / 100	 						//Valor do ICMS Comp. 						//V2
			nBaseCompl	:=	((nVlrMerc - nBaseICCmp) * nAliqICCmp) / 100			//Base FEEF									//W2
			nValoCompl	:=	(nBaseCompl * nAliqFEEF) / 100							//Valor FEEF								//Y2
		EndIf
	EndIf
	If lDevCompra .and. aPos[FP_D1_VALFEEF] .and. aPos[FP_D1_BASFEEF]
		SD1->(MsGoto(aNFItem[nItem][IT_RECORI]))
		If aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT
			nBaseCompl	:=	SD1->D1_BASFEEF	//Base FEEF		//W2
			nValoCompl	:=	SD1->D1_VALFEEF //Valor FEEF	//Y2
		EndIf
	EndIf
	/* Soma dos valores  */
	// Aliquota FEEF-RJ
	aNfItem[nItem][IT_ALQFEEF] := nAliqFEEF
	If !aSX6[MV_ESTADO] $ aSX6[MV_DESONRJ] .Or. nDifVlr > 0
		// Base FEEF-RJ
		aNfItem[nItem][IT_BASFEEF] := nVlrBaseIs + nDifVlr + nDifVlrST + nDifVlrDif + nVlrBaseCr + nBaseCompl
		// Valor FEEF-RJ
		aNfItem[nItem][IT_VALFEEF] := nIsenFEEF + nRedFEEF + nRedSTFEEF + nDifFEEF + nCrPreFEEF + nValoCompl
	Else
		// Aplica a Base Dupla da Resolu��o 13/2019 no valor fo FEEF
		// Base FEEF-RJ
		aNfItem[nItem][IT_BASFEEF] := ((nVlrBaseIs + nDifVlr + nDifVlrST + nDifVlrDif + nVlrBaseCr + nBaseCompl) / (1-(aNfItem[nItem][IT_ALIQICM] / 100)) )
		// Valor FEEF-RJ
		aNfItem[nItem][IT_VALFEEF] := ((nIsenFEEF + nRedFEEF + nRedSTFEEF + nDifFEEF + nCrPreFEEF + nValoCompl) / (1-(aNfItem[nItem][IT_ALIQICM] / 100)) )
	Endif

Else

    IF (nPosTgFEEF := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_FEEF})) >0  
    
        aNfItem[nItem][IT_VALFEEF]:= aNfItem[nItem][IT_TRIBGEN][nPosTgFEEF][TG_IT_VALOR]
        aNfItem[nItem][IT_BASFEEF]:= aNfItem[nItem][IT_TRIBGEN][nPosTgFEEF][TG_IT_BASE]
        aNfItem[nItem][IT_ALQFEEF]:= aNfItem[nItem][IT_TRIBGEN][nPosTgFEEF][TG_IT_ALIQUOTA]

    Endif
EndIf

Return

/*/{Protheus.doc} FEEFConvRf
(Fun��o responsavel por converter altera��o de referencia legado em referencia do configurador)

@author Renato Rezende
@since 25/11/2020
@version 12.1.31

@param:	
aNFItem-> Array com dados item da nota
nItem  -> Item que esta sendo processado
ccampo -> Campo que esta sendo alterado	
/*/
Function FEEFConvRf(aNfItem,nItem,ccampo)
Local cCampoConv := ""

IF cCampo == "IT_VALFEEF"
    cCampoConv := "TG_IT_VALOR"
Elseif cCampo == "IT_BASFEEF"
    cCampoConv := "TG_IT_BASE"
Elseif cCampo == "IT_ALQFEEF"
    cCampoConv := "TG_IT_ALIQUOTA"
Endif

Return cCampoConv
