#INCLUDE "Protheus.ch"
#INCLUDE "OGX050.ch"

/*{Protheus.doc} OGX050
Informa o valor para o fardo com Impostos. Retorna o array de fardos, incluindo o valor do fardo e a listagem de impostos. 
Para tratamento de erros é informado uma string de erros(Posição 2 do array).
{{RECNO Fardo, Valor C/ Impostos, {Cod Imposto, Nome Imposto, Valor, Aliquota, Usado no Preço} },Erros}
@author jean.schulze
@since 07/03/2018
@version 1.0
@param cFilCtr, characters, descricao
@param cContrato, characters, descricao
@param aFardos, array, Somente Recno do Fardo
@param cTes, characters, descricao
@param cNatuFin, characters, descricao
@type function
@Return {aFardos, cErros, aGrpFar}	
	aFardos: {RECNO DXI, 
	          Vl. Fat, 
			  Peso, 	
			  Vlr Agio/Desagio
			  }
	cErros
	aGrpFar: {Filial Origem,
			  Tipo Algodão,
              Preço Vazio,
			  Peso,
			  Array com os fardos{RECNO DXI}			  
			}	
*/
function OGX050(cFilCtr, cContrato, aFardos, cTes, cNatuFin, cCodCad, cCodRegFis , cFilRoman, cCodRoman, cItemRom, lUpdtRegra, cTipoCli, cCodClient, cCodLoja, nPrecoBase, nTipoCalc, nCotaReceb   )
	Local aAreaNJR   := NJR->(GetArea())
	Local aAreaUso   := GetArea()
	Local aFarCalc   := {}
	Local nA         := 0
	Local aGrpFar    := {}
	Local nPos       := 0
	Local cErros     := ""
	Local cUmPrec    := ""
    Local cUmProd    := ""
    Local cCodPro    := ""
	Local nDecCompon := TamSx3('N7C_VLRCOM')[2] //casa decimais componentes	
	Local lBloqAFix  := .F.
	Local aQtdConsum := {}
	Local cTipoCtr   := ""
	Local cUfDest    := ""
 	Local cUfOrig    := ""
 	Local nValorBase := {}
 	Local nMoedaCalc := 1 //moeda faturamento
 	Local nDias      := 0 //n dias para o ptax
 	Local nMoedaFat  := 1 //moeda de faturamento
 	Local nDiasPgto  := 0 //n dias para o ptax
 	Local nMoedaPgto := 1 //moeda de faturamento
 	Local cTipoMerc  := "1" //Mercado Interno/externo
 	Local nFatorConv := 0 
 	Local nFatorMoed := 1
 	Local cOperMORec := ""
 	Local aRetorno   := {}
 	Local dDtCotacao := dDatabase
 	Local nQtdTotal  := 0
 	Local aDatasCotac:= {}
 	Local nMoedaLc   := 1
 	Local lAFixar    := .f.
 	Local cTpPendenc := "" 
 	Local nCount     := 0 	
 	Local nPesoBase  := 0    
	
	Default lUpdtRegra := .f. //se trata-se de uma simulação
	Default cCodRoman  := ""
	Default cCodRegFis := ""
	Default cCodCad    := ""
	Default cFilRoman  := ""
	Default cTipoCli   := ""
	Default nPrecoBase := 0
	Default cCodClient := ""
	Default cCodLoja   := ""
	Default nTipoCalc  := "F" //Faturamento(F) - Recebimento(R) 
	Default nCotaReceb := 0
	
	if len(aFardos) == 0
		RestArea(aAreaNJR)
		RestArea(aAreaUso)
		return {aFardos, STR0001, aGrpFar, nMoedaCalc, nFatorConv }
	endif
	
	//dados do contrato
	DbSelectArea("NJR")	
    if NJR->(dbSeek(cFilCtr+cContrato))     	    	
    	cUmProd    := NJR->NJR_UM1PRO 
    	cUmPrec    := NJR->NJR_UMPRC
    	cCodPro    := NJR->NJR_CODPRO    	
    	cTipoCtr   := NJR->NJR_TIPO   //Compra/Venda/Armazenagem
    	nMoedaCalc := NJR->NJR_MOEDA  //moeda faturamento
    	cTipoMerc  := NJR->NJR_TIPMER //Mercado Interno/externo
    	nMoedaLc   := NJR->NJR_MOEDA  

    	//verifica a data que deve realziar a cotação - consome as datas
		if cTipoCtr $ "1|2" //Compras e vendas
			
			//verifica se tem pagamento vinculado -> verificar operacao 
	    	if nTipoCalc == "F" //estamos faturando
	    			    		 		
	 			nDias      := NJR->NJR_DIASR //n dias para o ptax
	    		nMoedaFat  := NJR->NJR_MOEDAR //moeda de faturamento
	    		cOperMORec := NJR->NJR_OPERAC
	    		nDiasPgto  := NJR->NJR_DIASF //n dias para o ptax
	    		nMoedaPgto := NJR->NJR_MOEDAF //moeda de faturamento
	    		
	    		if nMoedaCalc <> 1 .and. cTipoMerc == "1" //moeda estrangeira e mercado interno
    		    	DbSelectArea("N9A")
			    	N9A->(DbSetorder(1))
			    	if N9A->(dbSeek(cFilCtr+cContrato+cCodCad+cCodRegFis))
			    	 	if !empty(N9A->N9A_TRVTAX )
			    	 		nFatorConv := N9A->N9A_TRVTAX
			    	 	endif		    		
			    	endif			    	
		    	endif
		    		
		    else //calculo de previsões -  recebimento
		    	nDias      := 0 //n dias para o ptax
		    	nMoedaFat  := NJR->NJR_MOEDA //moeda de faturamento
		    	cOperMORec := "1"
		    	
		    	if nMoedaCalc <> 1 .and. cTipoMerc == "1" //moeda estrangeira e mercado interno
		    		if nCotaReceb > 0
		    			nFatorConv := nCotaReceb
		    		endif
		    	endif
	 		endif
	 		
		else //armazenagem
			nDias      := 0 //n dias para o ptax
			nMoedaFat  := NJR->NJR_MOEDA //moeda de faturamento
			cOperMORec := "1"
		endif 
 		
    	if NJR->NJR_CHKFIX == "2" //Não permite com saldo a fixar
    		lBloqAFix := .t. //bloqueia a expedição sem fixação.
    	endif
    	
    else
    	RestArea(aAreaNJR)
		RestArea(aAreaUso)
		return {aFardos, STR0002, aGrpFar, nMoedaCalc, nFatorConv }
	endif
	
	//verifica a data que deve realziar a cotação - consome as datas
	if !empty(cCodRoman) //está faturando	
    	//busca a quantidade total dos fardos
		for nA := 1 to len(aFardos)
			nQtdTotal += aFardos[nA][3] // quantidade
			
			//verifica se é à fixar
			if aFardos[nA][2] <> "1"  
				lAFixar := .t.
			endif
						
		next nA 
		
    	//Consome as datas de vencimento das previsões financeiras
    	aDatasCotac := OGX120DTPR(cFilCtr, cContrato, cCodRoman, cItemRom, cCodCad, cCodRegFis, nQtdTotal, 0, lAFixar)	
    endif
	
	if !empty(nFatorConv ) .and. nMoedaCalc <> 1 .and. cTipoMerc == "1"
		nMoedaCalc := 1 //moeda corrente
		nFatorMoed := nFatorConv
		dDtCotacao := dDataBase
	else 
		//verifica qual a cotação a ser utilizada
		if cOperMORec == "2" //busca o valor pelo pagamento
		    if valtype(aDatasCotac) == "A" .and. len(aDatasCotac[2]) > 0
		    	//vamos buscar o primeiro item - verificar a necessidade de realizar média ponderada
		    	dDtCotacao := stod(aDatasCotac[2][1][1]) //primeira data encontrada
                nDias      := nDiasPgto  //n dias para o ptax
	    		nMoedaFat  := nMoedaPgto //moeda de faturamento		    
		    endif
		endif
		
		//verfiica pendencia de cotação
		if !empty(cCodRoman) .and. cTipoCtr $ "1|2" .and.  nMoedaCalc <> 1 .and. cTipoMerc == "1"
		 	 		 
		 	if cOperMORec == "1" //busca o valor pelo faturamento
		 		//se for por data de faturamento
			 	//verifica a lista de datas de pagamento
			 	//se for diferente da data atual, grava o lance
			 	for nCount := 1 to len(aDatasCotac[1])
			 		if stod(aDatasCotac[1][nCount]) <> dDataBase
			 			cTpPendenc := iif(lAFixar, "3", "2")
			 		endif
			 	next nCount		
		 	elseif cOperMORec == "2" //busca o valor pelo pagamento
		 		//se for por data de pagamento
			 	//verifica as datas, se elas não estiver na lista ou data maior, cria o registro
			 	//lista as data de cotação
			 	if len(aDatasCotac[2]) == 0
			 		cTpPendenc := iif(lAFixar, "3", "2") //usando a moeda provisória	
			 	else
				 	for nCount := 1 to len(aDatasCotac[2])
				 		if stod(aDatasCotac[2][nCount][1]) > dDataBase
				 			cTpPendenc := iif(lAFixar, "3", "2")
				 		endif
				 	next nCount
			 	endif
			 endif	
			 
		endif 
				
		aRetorno := OGAX721MOE(nFatorMoed, nMoedaCalc, cTipoMerc, nDias, nMoedaFat, dDtCotacao )
		nFatorMoed := aRetorno[1]
		dDtCotacao := aRetorno[3]
		nMoedaCalc := aRetorno[2]
		nFatorConv := aRetorno[4]
	endif
	
	If nMoedaLc > 1 .AND. cTipoMerc == "1"
		If nFatorConv == 0
			return {aFardos, STR0003, aGrpFar, nMoedaCalc, nFatorConv}
		Endif
	Endif
	
	//verifica se vamos criar a pendencia para o romaneio
	if !empty(cCodRoman) .and. cTipoCtr $ "1|2" .and. empty(cTpPendenc) .and. lAFixar
		cTpPendenc := "1"
	endif
	
	if cTipoCtr $ "1|2" //compra e venda 	
		DbSelectArea("DXI")	
		//verifica se existe algum fardo sem preço ou preço afixar -  array próprio
		for nA := 1 to len(aFardos)
			DXI->(DbGoTo(aFardos[nA][1]))
			if (( empty(DXI->DXI_VLBASE) .or. (!empty(cCodRoman) .and. DXI->DXI_TIPPRE <> "1" /*Fixo*/) ) .and.  (nPos := aScan(aFarCalc,{|x| allTrim(x) == alltrim(DXI->DXI_BLOCO) })) > 0)  ;  //não esá na lista de tipos para recalculo
				.or. IsInCallStack("OGC020APR")
                aAdd(aFarCalc, DXI->DXI_BLOCO ) //ou monta o mesmo esquema de blocos...
			endif		 
		next nA 
				
		//se tiver aplica o ágio e deságio somente para eles
		if len(aFarCalc) > 0
			Processa({|| OGX016(cFilCtr, cContrato, aFarCalc, nPrecoBase, cCodClient, cCodLoja), "Processando Ágio e Deságio"}) // sempre devemos recalcular todos os fardos daquele bloco - média HVI
		endif	
		
		//obtem os valores -  agora todos em estarão com preço
		for nA := 1 to len(aFardos)
			if len(aFardos[nA]) <= 3 //só deve informar os dados de recno, valor e quantidade
				DXI->(DbGoTo(aFardos[nA][1]))
				
				nValorFard := Round(OGX700UMVL(DXI->DXI_VLCAGD,cUmPrec,cUmProd,cCodPro),nDecCompon) * nFatorMoed //convertendo a unidade de medida
				nPesoBase  := if(len(aFardos[nA]) > 2, aFardos[nA][3], DXI->DXI_PSESTO ) 			
				
				if (empty(DXI->DXI_VLBASE) .or. DXI->DXI_TIPPRE <> "1" /* + bolsa não indice*/ ) .and. !empty(cCodRoman) .and. lBloqAFix  //não possui valor base e está tentando faturar 
					//não permitir passar sem preço
					cErros += "O fardo de etiqueta " + DXI->DXI_ETIQ + " não possui valor calculado." + CHR(13)+CHR(10) //ou monta o mesmo esquema de blocos...
				else
					///separa os itens por tipo e valor
					if (nPos := aScan(aGrpFar,{|x| allTrim(x[1])+allTrim(x[2])+allTrim(str(x[3])) == alltrim(DXI->DXI_FILIAL)+alltrim(DXI->DXI_CLACOM)+alltrim(str(nValorFard)) })) > 0
						aGrpFar[nPos][4] += nPesoBase
						aAdd(aGrpFar[nPos][5], aFardos[nA][1])
					else
						aAdd(aGrpFar, {DXI->DXI_FILIAL,DXI->DXI_CLACOM,nValorFard,nPesoBase, {aFardos[nA][1] }})
					endif	
						
					//monta o consumo de preço - N8D
					if !empty(cCodRoman) .and. !empty(DXI->DXI_ITEMFX) //se for faturamentob e preço fixo
						if (nPos := aScan(aQtdConsum,{|x| allTrim(x[1])+allTrim(x[2]) == alltrim(DXI->DXI_ITEMFX)+alltrim(DXI->DXI_ORDENT) })) > 0
							aQtdConsum[nPos][3] += nPesoBase
						else
							aaDD(aQtdConsum, {DXI->DXI_ITEMFX, DXI->DXI_ORDENT,nPesoBase})
						endif					
					endif
					
				endif
								
				//atribui o valor base
				if len(aFardos[nA]) == 1
					aAdd(aFardos[nA], nValorFard ) //valor faturado
					aAdd(aFardos[nA], DXI->DXI_PSESTO ) //valor com ágio e deságio
				elseif len(aFardos[nA]) == 2 //quando informa mais de um dado
					aFardos[nA][2] :=  nValorFard //valor faturado
					aAdd(aFardos[nA], DXI->DXI_PSESTO ) //valor com ágio e deságio
				else //3 itens informados
					aFardos[nA][2] :=  nValorFard //valor faturado
				endif
								
				aAdd(aFardos[nA], nValorFard ) //valor com ágio e deságio								
			else
				RestArea(aAreaNJR)
				RestArea(aAreaUso)
				return {aFardos, STR0004, aGrpFar, nMoedaCalc, nFatorConv }	
			endif
			
		next nA 	
	else //contratos de remessa - valores através da pauta
		
		if cTipoCtr == "3" //compra e armazenagem -> entradas
	 		cUfDest := SUPERGETMV("MV_ESTADO", .f., "")
	 		cUfOrig := POSICIONE("SA2",1, xFilial("SA2") + cCodClient + cCodLoja, "A2_EST")
	 	else //saídas (compra e remessa a 3º)
	 		cUfDest := POSICIONE("SA1",1, xFilial("SA1") + cCodClient + cCodLoja, "A1_EST")
	 		cUfOrig := SUPERGETMV("MV_ESTADO", .f., "")
	 	endif
		
		//agrupa os fardos por tipo para calculo de valores
		for nA := 1 to len(aFardos)
			if len(aFardos[nA]) <= 3 //só deve informar os dados de recno, valor e quantidade
				
				DXI->(DbGoTo(aFardos[nA][1]))
				
				//atribui o valor base
				if len(aFardos[nA]) == 1
					aAdd(aFardos[nA], 0 ) //valor faturado
					aAdd(aFardos[nA], DXI->DXI_PSESTO ) //valor com ágio e deságio
				elseif len(aFardos[nA]) == 2 //quando informa mais de um dado
					aFardos[nA][2] :=  0 //valor faturado
					aAdd(aFardos[nA], DXI->DXI_PSESTO ) //valor com ágio e deságio
				else //3 itens informados
					aFardos[nA][2] :=  0 //valor faturado
				endif
				
				aAdd(aFardos[nA], 0 ) //valor com ágio e deságio								
				
				///separa os itens por tipo e valor
				if (nPos := aScan(aGrpFar,{|x| allTrim(x[1])+allTrim(x[2]) == alltrim(DXI->DXI_FILIAL)+alltrim(DXI->DXI_CLACOM) })) == 0
					aAdd(aGrpFar, {DXI->DXI_FILIAL,DXI->DXI_CLACOM, 0, aFardos[nA][3], {}})
				else
					aGrpFar[nPos][4] += aFardos[nA][3]
				endif
								
			else
				RestArea(aAreaNJR)
				RestArea(aAreaUso)
				return {aFardos, STR0004, aGrpFar, nMoedaCalc, nFatorConv }	
			endif
		next nA 	
		
		//calcula os valores para cadastro de itens
		for nA := 1 to len(aGrpFar)

			nValorBase := OGAX721REM(cFilCtr, cContrato, aGrpFar[nA][2], cUfOrig, cUfDest) 
			
			if valtype(nValorBase) <> "A"
				cErros += STR0005 + aGrpFar[nA][2] +"." + CHR(13)+CHR(10)
			elseif  empty(nValorBase[1][1])
				cErros += STR0006 + aGrpFar[nA][2] + STR0007 + CHR(13)+CHR(10) //ou monta o mesmo esquema de blocos...
			else //calcula/ apropria o valor
				aGrpFar[nA][3] := Round(OGX700UMVL(nValorBase[1][1],cUmPrec,cUmProd,cCodPro),nDecCompon) * nMoedaFat //convertendo a unidade de medida
			endif
							
		next nA 
		
		//atribui os devidos valores	
		for nA := 1 to len(aFardos)					
			if (nPos := aScan(aGrpFar,{|x| allTrim(x[1])+allTrim(x[2]) == alltrim(DXI->DXI_FILIAL)+alltrim(DXI->DXI_CLACOM) })) > 0
				aFardos[nA][2] := aGrpFar[nPos][3]
				aFardos[nA][4] := aGrpFar[nPos][3]				
			endif						
		next nA 		
	endif
		
	if !empty(cErros) //ocorreu erro ao calcular algum valor do fardo - agio deságio não foi aplicado
		RestArea(aAreaNJR)
		RestArea(aAreaUso)
		return {aFardos, cErros, aGrpFar, nMoedaCalc, nFatorConv}
	endif
	
	if !empty(cCodRoman)
		fUpdApropFix(aQtdConsum, aFardos, cFilCtr, cContrato, cCodCad, cCodRegFis, lUpdtRegra, cFilRoman, cCodRoman, cItemRom, nMoedaFat, nFatorConv, dDtCotacao, cTpPendenc )				
	EndIf
	
	RestArea(aAreaNJR)
	RestArea(aAreaUso)
		    
return {aFardos, cErros, aGrpFar, nMoedaCalc, nFatorConv }

/*{Protheus.doc} OGX050CTRF
Retorna a lista de recnos dos fardos do contrato
@author jean.schulze
@since 23/03/2018
@version 1.0
@return ${return}, ${return_description}
@param cTipMov, characters, descricao
@param cFilOrig, characters, descricao
@param cContrato, characters, descricao
@param cCodCad, characters, descricao
@param cRegraFis, characters, descricao
@type function
*/
function OGX050CTRF(cTipMov, cFilOrig, cContrato, cCodCad, cRegraFis, cFiltroExt, aFieldExt )
	
	Local aRecnos    := {}
	Local cFiltro    := ""
	Local aDadosFar  := {}
	Local nA         := 0
	
	Private cAliasDXI  := GetNextAlias()

	Default cCodCad    := ""
	Default cFiltroExt := ""
	Default aFieldExt  := {}
	
	cFiltro += " AND N9D.N9D_FILORG = '"+cFilOrig+"'"
	cFiltro += " AND N9D.N9D_TIPMOV = '"+cTipMov+"'"
	cFiltro += " AND N9D.N9D_STATUS = '2'" //ativo
	cFiltro += " AND N9D.N9D_CODCTR = '"+cContrato+"'"
	
	if !empty(cCodCad)
		cFiltro += " AND N9D.N9D_ITEETG = '"+cCodCad+"'"
	endif
	
	if !empty(cRegraFis)
		cFiltro += " AND N9D.N9D_ITEREF = '"+cRegraFis+"'"
	endif
	
	if !empty(cFiltroExt)
		 cFiltro += " AND ("+cFiltroExt+")"
	endif
		
	cFiltro := "%" + cFiltro + "%" 	
	
	cFields := "DXI.R_E_C_N_O_ as DXI_RECNO"
	
	if len(aFieldExt) > 0
		for nA := 1 to len(aFieldExt)
			cFields += ", " + aFieldExt[nA]
		next nA
	endif
		
	cFields := "%"+cFields+"%"
		
	BeginSql Alias cAliasDXI

		SELECT  %exp:cFields%
	  	  FROM %Table:DXI% DXI
	  	INNER JOIN %Table:N9D% N9D  ON N9D.N9D_FILIAL = DXI.DXI_FILIAL
		                           AND N9D.N9D_SAFRA  = DXI.DXI_SAFRA 
		                           AND N9D.N9D_FARDO  = DXI.DXI_ETIQ
		                           AND N9D.D_E_L_E_T_ = DXI.D_E_L_E_T_
		WHERE DXI.%notDel%
		  %exp:cFiltro%
		 	  
    EndSQL
	
	DbselectArea( cAliasDXI )
	DbGoTop()
	while ( cAliasDXI )->( !Eof() )
	 	
	 	aDadosFar := {}
	 	
	 	aadd(aDadosFar, (cAliasDXI)->DXI_RECNO)
	 	
	 	for nA := 1 to len(aFieldExt)
			aadd(aDadosFar, &("(cAliasDXI)->"+aFieldExt[nA] ))
		next nA
	 	
	 	aAdd(aRecnos, aDadosFar)  
	 	
		( cAliasDXI )->( dbSkip() )
	EndDo
	
	( cAliasDXI )->( dbCloseArea() )
	
return aRecnos

/*{Protheus.doc} fUpdApropFix
Apropria os valores das Fixações e consome o preço.
@author jean.schulze
@since 29/03/2018
@version 1.0
@return ${return}, ${return_description}
@param aQtdConsum, array, descricao
@param aFardos, array, descricao
@param cFilCtr, characters, descricao
@param cContrato, characters, descricao
@param nMoedaCalc, number, Codigo da Moeda da Cotação
@param nFatorConv, number, Valor da Cotação
@param dDtCotacao, date, Data da Cotação
@type function
*/
Static function fUpdApropFix(aQtdConsum, aFardos, cFilCtr, cContrato, cCodCad, cCodRegFis, lUpdtRegra, cFilRoman, cCodRoman, cItemRom, nMoedaCalc, nFatorConv, dDtCotacao, cTpPendenc )
	Local nA        := 0
	Local nB        := 0
	Local cQtdTotal := 0
	Local nVlrTotal := 0
	Local cTipoCtr  := POSICIONE("NJR", 1,  cFilCtr + cContrato, "NJR_TIPO" ) 
	
	for nA := 1 to len(aQtdConsum)
		//debita da N8D
		IF (Select("N8D") == 0)
			DbSelectArea("N8D")
		endif
		N8D->(dbSetOrder(2))
		if N8D->(DbSeek(cFilCtr + cContrato + aQtdConsum[nA][1] + aQtdConsum[nA][2]))
			RecLock('N8D',.f.)
				N8D->N8D_QTDFAT += aQtdConsum[nA][3] //soma a quantidade
			N8D->(MsUnLock())				
		endif
		
		//utiliza a NN8
		IF (Select("NN8") == 0)
			DbSelectArea("NN8")
		endif
		NN8->(dbSetOrder(1))
		if NN8->(DbSeek(cFilCtr + cContrato + aQtdConsum[nA][1]))
			RecLock('NN8',.f.)
				NN8->NN8_QTDENT += aQtdConsum[nA][3] //soma a quantidade
			NN8->(MsUnLock())				
		endif
		
		//grava na tabela de preços para devolver no processo de cancelamento
		IF (Select("N8T") == 0)
			DbSelectArea("N8T")
		endif
	
		RecLock('N8T',.T.)
			N8T->N8T_FILIAL := FwXFilial("N8T") 
			N8T->N8T_CODROM := cCodRoman
			N8T->N8T_ITEROM := cItemRom
			N8T->N8T_FILCTR := cFilCtr
			N8T->N8T_CODCTR := cContrato
			N8T->N8T_CODCAD := cCodCad
			N8T->N8T_CODREG := cCodRegFis
			N8T->N8T_SEQVNC := SOMA1(alltrim(str(nA)))
			N8T->N8T_QTDVNC := aQtdConsum[nA][3]
			N8T->N8T_ITEMFX := aQtdConsum[nA][1]
			N8T->N8T_SEQFIX := aQtdConsum[nA][2]
			N8T->N8T_TIPPRC := "1" //fixo
			N8T->N8T_DATCOT := dDtCotacao
			N8T->N8T_MOECOT := nMoedaCalc
			N8T->N8T_TAXCOT := nFatorConv			
		N8T->(MsUnLock())	
		
	next nA
	
	for nB := 1 to len(aFardos)
		
		DXI->(DbGoTo(aFardos[nB][1]))
		
		N9D->(dbSetOrder(2))
		if N9D->(DbSeek(DXI->DXI_FILIAL+cFilRoman+DXI->DXI_SAFRA+DXI->DXI_ETIQ+"072"+cContrato+cCodCad+cCodRegFis)) //N9D_FILIAL+N9D_FILORG+N9D_SAFRA+N9D_FARDO+N9D_TIPMOV+N9D_STATUS+N9D_CODCTR+N9D_ITEETG+N9D_ITEREF 
			RecLock('N9D',.F.)
				N9D->N9D_VLRUNI := aFardos[nB][2] //informa o valor do fardo
				cQtdTotal       += N9D->N9D_PESFIM  //busca o peso conforme está no romaneio (ganho de peso)
			N9D->(MsUnLock())
		else
			cQtdTotal += aFardos[nB][3] //quantidade				
		endif

		nVlrTotal += aFardos[nB][2] * aFardos[nB][3]
		
		if cTipoCtr $ "1|2" //somente para compra e venda, se não não aparece na seleção de fardos.
			RecLock( "DXI", .F. )
			  	DXI->DXI_FATURA := "2" //faturado
			DXI->(MsUnLock())
		endif				
		
	next nB
	
	//cria a N8T com os valores
	RecLock('N8T',.T.)
			N8T->N8T_FILIAL := FwXFilial("N8T") 
			N8T->N8T_CODROM := cCodRoman
			N8T->N8T_ITEROM := cItemRom
			N8T->N8T_FILCTR := cFilCtr
			N8T->N8T_CODCTR := cContrato
			N8T->N8T_CODCAD := cCodCad
			N8T->N8T_CODREG := cCodRegFis
			N8T->N8T_SEQVNC := SOMA1(alltrim(str(nA)))
			N8T->N8T_QTDVNC := cQtdTotal
			N8T->N8T_TIPPRC := "5" //Preço
			N8T->N8T_VALOR  := nVlrTotal / cQtdTotal //ponderado
			N8T->N8T_DATCOT := dDtCotacao
			N8T->N8T_MOECOT := nMoedaCalc
			N8T->N8T_TAXCOT := nFatorConv			
	N8T->(MsUnLock())	
		
	//chama o esquema da regra fiscal
	if lUpdtRegra //vai atualiza a regra fical
		OGX055SLDR(cFilCtr, cContrato, cCodCad, cCodRegFis, cQtdTotal  )
	endif	

	//verifica a necessidade de criar pendencia
	if !empty(cTpPendenc)
		//funcao padrao para criar pendencia
		OGX060PEND(cCodRoman, cItemRom, cTpPendenc, cFilCtr, cContrato, cCodCad, cCodRegFis,)
	endif
return .t.

/*{Protheus.doc} OGX050CANC
Cancelamento de uso de fixação
@author jean.schulze
@since 25/04/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilCtr, characters, descricao
@param cCodRoman, characters, descricao
@param cItemRom, characters, descricao
@param cContrato, characters, descricao
@param cCodCad, characters, descricao
@param cCodReg, characters, descricao
@param cQtd, characters, descricao
@param lUpdtRegra, logical, descricao
@param aFardos, array, descricao
@param cFilRoman, char, descricao
@type function
*/
Function OGX050CANC(cTipoCanc,cFilCtr, cCodRoman, cItemRom, cContrato, cCodCad, cCodReg, nQtd, lUpdtRegra, aFardos, cFilRoman )
	Local cTipoCtr := POSICIONE("NJR", 1,  cFilCtr + cContrato, "NJR_TIPO" ) 
	Local nA       := 0
	
	DbSelectArea("N8T")
	N8T->(DbSetOrder( 1 ))
	N8T->(DbGoTop())
	
	If N8T->(dbSeek( FWxFilial( "N8T" ) + cCodRoman + cItemRom + cFilCtr+ cContrato + cCodCad + cCodReg ))

		While !N8T->( EoF() ) .And. N8T->( N8T_FILIAL + N8T_CODROM + N8T_FILCTR + N8T_CODCTR + N8T_CODCAD + N8T_CODREG   ) == FWxFilial( "N8T" ) + cCodRoman + cFilCtr+ cContrato + cCodCad + cCodReg 
			
			If N8T->N8T_TIPPRC == "1" //fixação
				If (Select("N8D") == 0)
					DbSelectArea("N8D")
				EndIf 
				
				N8D->(DbSetOrder(2))
				If N8D->(DbSeek(cFilCtr + cContrato + N8T->N8T_ITEMFX + N8T->N8T_SEQFIX))
					If !empty(N8D->N8D_ITEMFX)
						RecLock('N8D',.f.)
							N8D->N8D_QTDFAT -= N8T->N8T_QTDVNC //diminui a quantidade
						N8D->(MsUnLock())				
					EndIf
				EndIf
				
				//utiliza a NN8
				If (Select("NN8") == 0)
					DbSelectArea("NN8")
				EndIf
				
				NN8->(DbSetOrder(1))
				If NN8->(DbSeek(cFilCtr + cContrato + N8T->N8T_ITEMFX))
					If !empty(NN8->NN8_ITEMFX)
						RecLock('NN8',.f.)
							NN8->NN8_QTDENT -= N8T->N8T_QTDVNC //diminui a quantidade
						NN8->(MsUnLock())				
					EndIf
				EndIf
			Endif
			
			If RecLock( "N8T", .f. )
				N8T->(DbDelete())
				MsUnLock()
			EndIf
			
			N8T->(DBSkip())
				
		EndDo
	EndIf
	
	for nA := 1 to len(aFardos)
		
		DXI->(DbGoTo(aFardos[nA][1]))
		
		N9D->(dbSetOrder(2))
		if N9D->(DbSeek(DXI->DXI_FILIAL+FWxFilial("NJJ")+DXI->DXI_SAFRA+DXI->DXI_ETIQ+"072")) //N9D_FILIAL+N9D_FILORG+N9D_SAFRA+N9D_FARDO+N9D_TIPMOV+N9D_STATUS+N9D_CODCTR+N9D_ITEETG+N9D_ITEREF 
			RecLock('N9D',.F.)
				N9D->N9D_VLRUNI := 0 //informa o valor do fardo
			N9D->(MsUnLock())				
		endif
		
		if cTipoCtr $ "1|2" //somente para compra e venda, se não não aparece na seleção de fardos.
			RecLock( "DXI", .F. )
			  	DXI->DXI_FATURA := "1" //a faturar
			DXI->(MsUnLock())
		endif				
		
	next nA
	
	if lUpdtRegra //vai atualiza a regra fical
		OGX055SLDR(cFilCtr, cContrato, cCodCad, cCodReg, (nQtd * -1)  )
	endif
	
	//remove a pendencia se houver
	If !Empty(cCodRoman) .AND. !Empty(cItemRom)
		OGX060RPEN(cCodRoman, cItemRom, nQtd)
	endif
	
    //chama a função de remover a tabela N9K
    If !Empty(cCodRoman) .AND. !Empty(cItemRom)
        OGX120CANC(cTipoCanc, cFilCtr, cContrato, cCodRoman, cItemRom, cCodCad, cCodReg, nQtd ,0, {})
    EndIf
Return .t.

