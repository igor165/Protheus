#INCLUDE "Protheus.ch"
#INCLUDE "OGX060.ch"

/*{Protheus.doc} OGX060
Informa o valor para o granel com Impostos. Retorna o array de valores, incluindo o valor do granel e a listagem de impostos. 
Para tratamento de erros é informado uma string de erros(Posição 2 do array).
@author jean.schulze
@since 07/03/2018
@version 1.0
@param cFilCtr, characters, descricao
@param cContrato, characters, descricao
@param cQtd, characters, descricao
@param cTes, characters, descricao
@param cNatuFin, characters, descricao
@param cFilFat, characters, descricao
@param cCodCad, characters, descricao
@param cCodRegFis, characters, descricao
@param cCodRoman, characters, descricao
@param lUpdtRegra, logical, descricao
@type function
@return {aVlrCalc, cErros}
   aVlrCalc: {Preço Cheio Fat,
			  Indica preço fixo ou provisório
			  fix/indice/base
			  Preço Cheio Fin
			  Array com impostos{{Desc. Imp, Desc. Imp, Quanti (peso), Alíquota, Compõe Preço, Vl. Unit. com impostos, Base de Calc. Total, Vl. Imp. Total, Pauta Fiscal}} 
			  Preço vazio
			  Tipo Algodão (usado qdo chamado OGX060 pelo algodão)
   			} 
	cErros: String com mensagem de erro
*/
function OGX060(cFilCtr, cContrato, cQtd, cTes, cNatuFin, cFilFat, cCodCad, cCodRegFis , cCodRoman, cItemRom, lUpdtRegra, cTipoCli, cCodClient, cCodLoja, nPrecoBase, nTipoCalc)
	Local aAreaNJR   := NJR->(GetArea())
	Local aAreaUso   := GetArea()
	Local aVlrBase   := {}
	Local aVlrCalc   := Array(9)
	Local cErros     := ""
	Local cCodNgc    := ""
	Local cVersao    := ""
	Local cUmProd    := ""
	Local cUmPrec    := ""
	Local cCodPro    := ""	
	Local nDecCompon := TamSx3('N7C_VLRCOM')[2] //casa decimais componentes	
	Local lBloqAFix  := .F.
	Local cTipAlg    := ""
	Local cTipoCtr   := ""
	Local cUfDest    := ""
 	Local cUfOrig    := ""
 	Local nMoedaCalc := 1 //moeda faturamento
 	Local nDias      := 0 //n dias para o ptax
 	Local nMoedaFat  := 1 //moeda de faturamento
 	Local nDiasPgto   := 0 //n dias para o ptax
 	Local nMoedaPgto  := 1 //moeda de pagamento
 	Local cTipoMerc  := "1" //Mercado Interno/externo
 	Local nFatorConv := 0 //usada para travar o cambio
	Local cOperMORec := ""
	Local aRetorno   := {}
	Local dDtCotacao := dDatabase
	Local aDatasCotac := {}
	Local nMoedaLc   := 1
	Local lRomAFix   := .t. //verifica se o romaneio é a fixar
	Local cTpPendenc := "" //sem pendencia
	Local nCount     := 0
	Local cTipFix    := ""

	Default cFilFat    := ""
	Default cCodCad    := ""
	Default lUpdtRegra := .f.
	Default cCodRoman  := ""
	Default cCodRegFis := ""
	Default cTipoCli   := ""
	Default nPrecoBase := 0
	Default nTipoCalc  := "F" //Faturamento(F) - Recebimento(R) 
	
	if empty(cQtd)
		RestArea(aAreaNJR)
		RestArea(aAreaUso)
		return {aVlrCalc, STR0001, nMoedaCalc, nFatorConv }
	endif

	//posiciona o dados do contrato
	DbSelectArea("NJR")	
    if NJR->(dbSeek(cFilCtr+cContrato)) 
    	
    	cCodNgc    := NJR->NJR_CODNGC
    	cVersao    := NJR->NJR_VERSAO
    	cUmProd    := NJR->NJR_UM1PRO 
    	cUmPrec    := NJR->NJR_UMPRC
    	cCodPro    := NJR->NJR_CODPRO
		cTipAlg    := NJR->NJR_TIPALG
    	cTipoCtr   := NJR->NJR_TIPO   //Compra/Venda/Armazenagem
    	nMoedaCalc := NJR->NJR_MOEDA  //moeda faturamento
    	cTipoMerc  := NJR->NJR_TIPMER //Mercado Interno/externo
		nMoedaLc   := NJR->NJR_MOEDA  
    	cTipFix    := NJR->NJR_TIPFIX
    	 
    	//verifica a data que deve realziar a cotação - consome as datas
		if cTipoCtr $ "1|2" //Compras e vendas
			
			//verifica se tem pagamento vinculado -> verificar operacao 
	    	if nTipoCalc == "F" //estamos faturando
	    			    		 		
	 			nDias      := NJR->NJR_DIASR //n dias para o ptax
	    		nMoedaFat  := NJR->NJR_MOEDAR //moeda de faturamento
	    		cOperMORec := NJR->NJR_OPERAC
	    		nDiasPgto  := NJR->NJR_DIASF //n dias para o ptax
	    		nMoedaPgto := NJR->NJR_MOEDAF //moeda de recebimento
		    	
		    	//trava de cambio
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
		return {aVlrCalc, STR0002, nMoedaCalc, nFatorConv }
	endif
	
	if cTipoCtr $ "1|2" //compra e venda 	
		//chama a função de verificação de valor
		aVlrBase := OGAX721FAT(cFilCtr,cContrato, cCodCad, cCodRegFis, 0, cQtd, nPrecoBase, cCodClient, cCodLoja, nTipoCalc )		
	else
		//chama a função de verificação de valor
		if cTipoCtr == "3" //compra e armazenagem -> entradas
	 		cUfDest := SUPERGETMV("MV_ESTADO", .f., "")
	 		cUfOrig := POSICIONE("SA2",1, xFilial("SA2") + cCodClient + cCodLoja, "A2_EST")
	 	else //saídas (compra e remessa a 3º)
	 		cUfDest := POSICIONE("SA1",1, xFilial("SA1") + cCodClient + cCodLoja, "A1_EST")
	 		cUfOrig := SUPERGETMV("MV_ESTADO", .f., "")
	 	endif
	 	
		aVlrBase := OGAX721REM(cFilCtr, cContrato, "", cUfOrig, cUfDest, cQtd)
		
	endif	
	
	//trata o retorno da função de preço do contrato
	if valtype(aVlrBase) <> "A"
		RestArea(aAreaNJR)
		RestArea(aAreaUso)
		return {aVlrCalc, STR0003, nMoedaCalc, nFatorConv }
	elseif empty(aVlrBase[1][1]) //sem preço criado
		RestArea(aAreaNJR)
		RestArea(aAreaUso)
		return {aVlrCalc, STR0004, nMoedaCalc, nFatorConv }
	elseif (cTipFix == "2" .and. aVlrBase[1][3] <> "FIX") .and. lBloqAFix .and.	!empty(cCodRoman)	
		RestArea(aAreaNJR)
		RestArea(aAreaUso)
		return {aVlrCalc, STR0005, nMoedaCalc, nFatorConv }
	endif
	
	//verifica se o romaneio é a fixar
	lRomAFix := (aVlrBase[1][2] = "2" .and. aVlrBase[1][3] <> "IDX-FIX") // .t. = A fixar, .f. = fixo
	
	//verifica a data que deve realziar a cotação - consome as datas
	if !empty(cCodRoman) //está faturando	
    	//Consome as datas de vencimento das previsões financeiras
    	aDatasCotac := OGX120DTPR(cFilFat, cContrato, cCodRoman, cItemRom, cCodCad, cCodRegFis, cQtd, Round(OGX700UMVL(aVlrBase[1][1],cUmPrec,cUmProd,cCodPro), nDecCompon), lRomAFix )	
    endif
	
	//verifica se temos o cambio travado
	if !empty(nFatorConv ) .and. nMoedaCalc <> 1 .and. cTipoMerc == "1"
		nMoedaCalc := 1 //moeda corrente
		aRetorno   := {nFatorConv, nMoedaCalc ,dDataBase, nFatorConv}	
	else 
		//verifica qual a cotação a ser utilizada
		if cOperMORec == "2" .AND. !empty(cCodRoman)  //busca o valor pelo pagamento
		    if valtype(aDatasCotac) == "A" .and. len(aDatasCotac[2]) > 0
		    	//vamos buscar o primeiro item - verificar a necessidade de realizar média ponderada
		    	dDtCotacao := stod(aDatasCotac[2][1][1]) //primeira data encontrada
                nDias      := nDiasPgto  //n dias para o ptax
                nMoedaFat  := nMoedaPgto
		    else //sem data de pagamento, vamos usar a moeda provisória	    		
	    		cTpPendenc := iif(lRomAFix, "3", "2")
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
			 			cTpPendenc := iif(lRomAFix, "3", "2")
			 		endif
			 	next nCount		
		 	elseif cOperMORec == "2" //busca o valor pelo pagamento
		 		//se for por data de pagamento
			 	//verifica as datas, se elas não estiver na lista ou data maior, cria o registro
			 	//lista as data de cotação
			 	if len(aDatasCotac[2]) == 0
			 		cTpPendenc := iif(lRomAFix, "3", "2") //usando a moeda provisória	
			 	else
				 	for nCount := 1 to len(aDatasCotac[2])
				 		if stod(aDatasCotac[2][nCount][1]) > dDataBase
				 			cTpPendenc := iif(lRomAFix, "3", "2")
				 		endif
				 	next nCount
			 	endif
			 endif	
		endif 
		
		//verifica a moeda que vai ser utilizada
		aRetorno   := OGAX721MOE(1, nMoedaCalc, cTipoMerc, nDias, nMoedaFat, dDtCotacao )
	  	dDtCotacao := aRetorno[3]
	 	nMoedaCalc := aRetorno[2]
	 	nFatorConv := aRetorno[4]
	 			
	endif	
	
	//verifica se vamos criar a pendencia para o romaneio
	if !empty(cCodRoman) .and. empty(cTpPendenc) .and. lRomAFix
		cTpPendenc := "1"
	endif
	
	iF nMoedaLc > 1 .AND. cTipoMerc == "1"
		If nFatorConv == 0
			return {aVlrCalc, STR0006,  nMoedaCalc, nFatorConv}		
		Endif
	Endif 

	//apropria os valores -  tratado para futuras evoluções
	aVlrCalc[1] := Round(OGX700UMVL(aVlrBase[1][1],cUmPrec,cUmProd,cCodPro), nDecCompon) * aRetorno[1]
	aVlrCalc[2] := aVlrBase[1][2] //fixo ou provisorio
	aVlrCalc[3] := aVlrBase[1][3] //fix/indice/base
	aVlrCalc[4] := {}
	aVlrCalc[5] := aVlrCalc[1]
	aVlrCalc[6] := cTipAlg  //tipo	
	
	if empty(cFilFat) //não tem filial
		//manda pela filial do contrato
		cFilFat := cFilCtr
	endif

	if !empty(cCodRoman) //está faturando		
		aadd(aVlrBase[1][4], {"5", aVlrCalc[1],  cQtd, "",""})	
		fUpdApropFix(aVlrBase[1][4], cCodRoman, cItemRom, cFilCtr, cContrato, cCodCad, cCodRegFis, cQtd, lUpdtRegra, cFilFat, nMoedaFat, nFatorConv, dDtCotacao, cTpPendenc )
	endif

	RestArea(aAreaNJR)
	RestArea(aAreaUso)
return {aVlrCalc, cErros, nMoedaCalc, nFatorConv}

/*{Protheus.doc} OGX060PREV
Calcula determinada fixação para preços faturado e financeiro.
@author jean.schulze
@since 28/06/2018
@version 1.0
@return ${return}, ${return_description}
@param nValor, numeric, descricao
@param dDtBasCalc, date, descricao
@param cFilCtr, characters, descricao
@param cContrato, characters, descricao
@param cCodCad, characters, descricao
@param cCodRegFis, characters, descricao
@param cCodClient, characters, descricao
@param cCodLoja, characters, descricao
@param cTes, characters, descricao
@param cNatuFin, characters, descricao
@param cFilFat, characters, descricao
@param cCodNgc, characters, descricao
@param cVersao, characters, descricao
@param cTipoMerc, characters, descricao
@param nMoedaFat, numeric, descricao
@param nDias, numeric, descricao
@param cUmPrec, characters, descricao
@param cUmProd, characters, descricao
@param cCodPro, characters, descricao
@param nMoedaCtr, numeric, descricao
@param cTipoCli, characters, descricao
@type function
*/
Function OGX060PREV(nValor, dDtBasCalc, cTipoAlgod, nQtdPeso, cFilCtr, cContrato, cCodCad, cCodRegFis, cCodClient, cCodLoja, cTes, cNatuFin, cFilFat, cCodNgc, cVersao, cTipoMerc, nMoedaFat, nDias, cUmPrec, cUmProd, cCodPro, nMoedaCtr, cTipoCli )
    Local nFatorConv := 1
    Local aRetorno   := {} 	
	Local nDecCompon := TamSx3('N7C_VLRCOM')[2] //casa decimais componentes
	
	//verifica a moeda que vai ser utilizada
	aRetorno   := OGAX721MOE(1, nMoedaCtr, cTipoMerc, nDias, nMoedaFat, dDtBasCalc )
 	nMoedaCalc := aRetorno[2]
 	dDtBasCalc := aRetorno[3]
 	nFatorConv := aRetorno[4]  
			
	//apropria os valores -  tratado para futuras evoluções
	nValor := Round(OGX700UMVL(nValor,cUmPrec,cUmProd,cCodPro), nDecCompon) * aRetorno[1]
					
	if empty(cFilFat) //não tem filial
		//manda pela filial do contrato
		cFilFat := cFilCtr
	endif
		
return {nValor, dDtBasCalc, nFatorConv, nMoedaCalc}

/*{Protheus.doc} fUpdApropFix
Apropria Fixações e Consome Saldos
@author jean.schulze
@since 29/03/2018
@version 1.0
@return ${return}, ${return_description}
@param aQtdConsum, array, descricao
@param cFilCtr, characters, descricao
@param cContrato, characters, descricao
@param cCodRoman, characters, descricao
@param nMoedaCalc, number, Codigo da Moeda da Cotação
@param nFatorConv, number, Valor da Cotação
@param dDtCotacao, date, Data da Cotação
@type function
*/
Static function fUpdApropFix(aQtdConsum, cCodRoman, cItemRom, cFilCtr, cContrato, cCodCad, cCodRegFis, cQtd, lUpdtRegra, cFilFat, nMoedaCalc, nFatorConv, dDtCotacao, cTpPendenc )
	Local nA      := 0

	for nA := 1 to len(aQtdConsum)
				
		if aQtdConsum[nA][1] == "1" //fixacao
			IF (Select("N8D") == 0)
				DbSelectArea("N8D")
			endif
			N8D->(dbSetOrder(2))
			if N8D->(DbSeek(cFilCtr + cContrato + aQtdConsum[nA][4] + aQtdConsum[nA][5]))
				RecLock('N8D',.f.)
					N8D->N8D_QTDFAT += aQtdConsum[nA][3] //soma a quantidade
				N8D->(MsUnLock())				
			endif
			
			//utiliza a NN8
			IF (Select("NN8") == 0)
				DbSelectArea("NN8")
			endif
			NN8->(dbSetOrder(1))
			if NN8->(DbSeek(cFilCtr + cContrato + aQtdConsum[nA][4]))
				RecLock('NN8',.f.)
					NN8->NN8_QTDENT += aQtdConsum[nA][3] //soma a quantidade
				NN8->(MsUnLock())				
			endif
			
			//verifica a necessidade de usar a NNC
			//vamos montar a NNC com os valores e depois a mareta para atualizar os campos dos docs fiscais?
			//NNC_FILIAL+NNC_CODCTR+NNC_ITEMFX+NNC_CODROM+NNC_ITEROM  
			                                                                                                                                                                                                  
		endif
		
		//grava na tabela de preços
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
			N8T->N8T_TIPPRC := aQtdConsum[nA][1]
			N8T->N8T_VALOR  := aQtdConsum[nA][2]
			N8T->N8T_QTDVNC := aQtdConsum[nA][3]
			N8T->N8T_ITEMFX := aQtdConsum[nA][4]
			N8T->N8T_SEQFIX := aQtdConsum[nA][5]
			N8T->N8T_DATCOT := dDtCotacao
			N8T->N8T_MOECOT := nMoedaCalc
			N8T->N8T_TAXCOT := nFatorConv 
		N8T->(MsUnLock())				
											
	next nA
	
	if lUpdtRegra //vai atualiza a regra fical
		OGX055SLDR(cFilCtr, cContrato, cCodCad, cCodRegFis, cQtd  )
	endif
	
	//verifica a necessidade de criar pendencia
	if !empty(cTpPendenc)
		//funcao padrao para criar pendencia
		OGX060PEND(cCodRoman, cItemRom, cTpPendenc, cFilCtr, cContrato, cCodCad, cCodRegFis)
	endif
	
return .t.


/*{Protheus.doc} OGX060CANC
Cancela Fixações e devolve Saldos
@author jefferson.schueroff
@since 04/04/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilCtr, characters, descricao
@param cContrato, characters, descricao
@param cCodRoman, characters, descricao
@param cFilRoman, characteres, descricao

*/
Function OGX060CANC(cTipoCanc, cFilCtr, cCodRoman, cItemRom, cContrato, cCodCad, cCodReg, nQtd, lUpdtRegra, cFilRoman, nValorDevol, aTituloNCC )
  	Local aListFix   := {}
  	Local nQtdRoman  := 0
  	Local nCount     := 1
  	Local nQtdDevol  := 0
  	Local nQtdUse    := 0
  	 
  	Default cCodRoman   := ""
	Default cContrato   := ""
	Default nValorDevol := 0
	Default aTituloNCC  := {}
	
	DbSelectArea("N8T")
	N8T->(DbSetOrder( 1 ))
	N8T->(DbGoTop())
	
	//verificar se é devol, se for, devolver os precos corretos proporcional- verificar o cancelamento da devolução
	if cTipoCanc == "D"
		If N8T->(dbSeek( FWxFilial( "N8T" ) + cCodRoman + cItemRom + cFilCtr+ cContrato + cCodCad + cCodReg ))																													
			While !N8T->( EoF() ) .And. N8T->( N8T_FILIAL + N8T_CODROM + N8T_ITEROM  + N8T_FILCTR + N8T_CODCTR + N8T_CODCAD + N8T_CODREG   ) == FWxFilial( "N8T" ) + cCodRoman + cItemRom + cFilCtr+ cContrato + cCodCad + cCodReg 
				//busca as fixações que são de preco
			    if N8T->N8T_TIPPRC == "1"
					aadd(aListFix, N8T->( RECNO() ))
				endif
										
				//verifica se tem fixação de prec
				if  N8T->N8T_TIPPRC  == "5"
					nQtdRoman := N8T->N8T_QTDVNC
				endif
								
				N8T->(DBSkip())
			EndDo
			
			
			//se tiver fixação + um tipo fazer ponderado o retorno
			for nCount := 1 to len(aListFix)
				N8T->(dbGoTo(aListFix[nCount]))
				if N8T->(RECNO()) == aListFix[nCount]
					
					//verifica o quanto debitar
					if nQtdRoman == N8T->(N8T_QTDVNC) //valor limpo
						nQtdDevol := nQtd
					else //Proporcional
						nQtdDevol := round(nQtd * (N8T->N8T_QTDVNC / nQtdRoman), TamSx3("N8T_QTDVNC")[2])
						//arrendondamentos
						if nQtdUse + nQtdDevol > nQtd  
							nQtdDevol := nQtd - nQtdUse
						endif
						if N8T->N8T_QTDVNC < nQtdDevol
							nQtdDevol := N8T->N8T_QTDVNC
						endif
						nQtdUse += nQtdDevol
					endif
					
					//realiza os debitos
					N8D->(DbSetOrder(2))
					If N8D->(DbSeek(cFilCtr + cContrato + N8T->N8T_ITEMFX + N8T->N8T_SEQFIX))
						If !empty(N8D->N8D_ITEMFX)
							RecLock('N8D',.f.)
								N8D->N8D_QTDFAT -= nQtdDevol //diminui a quantidade
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
								NN8->NN8_QTDENT -= nQtdDevol //diminui a quantidade
							NN8->(MsUnLock())				
						EndIf
					EndIf
					
					If RecLock( "N8T", .f. )
						N8T->N8T_QTDEVL += nQtdDevol //soma a quantidade devolvida
						N8T->(MsUnLock())
					EndIf
					
				endif
			next nCount
			
		endif	
	else
		If N8T->(dbSeek( FWxFilial( "N8T" ) + cCodRoman + cItemRom + cFilCtr+ cContrato + cCodCad + cCodReg ))	
			
			While !N8T->( EoF() ) .And. N8T->( N8T_FILIAL + N8T_CODROM + N8T_ITEROM  + N8T_FILCTR + N8T_CODCTR + N8T_CODCAD + N8T_CODREG   ) == FWxFilial( "N8T" ) + cCodRoman + cItemRom + cFilCtr+ cContrato + cCodCad + cCodReg 
	
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
				
				If RecLock( "N8T", .f. )
					N8T->(DbDelete())
					MsUnLock()
				EndIf
				
				N8T->(DBSkip())
					
			EndDo
		EndIf
	endif
	
	if lUpdtRegra //vai atualiza a regra fical
		OGX055SLDR(cFilCtr, cContrato, cCodCad, cCodReg, (nQtd * -1)  )
	endif	
	
	//remove a pendencia se houver
	If !Empty(cCodRoman) .AND. !Empty(cItemRom)
		OGX060RPEN(cCodRoman, cItemRom, nQtd)
	endif

    //chama a função de remover a tabela N9K
    If !Empty(cCodRoman) .AND. !Empty(cItemRom)
        OGX120CANC(cTipoCanc, cFilCtr, cContrato, cCodRoman, cItemRom, cCodCad, cCodReg, nQtd, nValorDevol, aTituloNCC )
    EndIf

Return .t.


/*{Protheus.doc} OGX060PEND
//TODO Descrição auto-gerada.
@author jean.schulze
@since 22/08/2018
@version 1.0
@return ${return}, ${return_description}
@param cCodRom, characters, descricao
@param cItemRom, characters, descricao
@param cTipoPend, characters, descricao
@type function
*/
Function OGX060PEND(cCodRom, cItemRom, cTipoPend, cFilCtr, cCodCtr, cCodCad, cCodRegra, nValor)

	Local aAreaNC8 := NC8->(GetArea())
	Default nValor := 0

	If !Empty(cCodRom)
		dbSelectArea("NC8")
		dbSetOrder(1)
		If !dbSeek(FwXFilial("NC8")+cCodRom+cItemRom)
			If RecLock('NC8',.T.)
				NC8->NC8_FILIAL := FwXFilial("NC8") 
				NC8->NC8_CODROM := cCodRom
				NC8->NC8_ITEMRO := cItemRom
				NC8->NC8_PENDEN := cTipoPend
				NC8->NC8_FILCTR := cFilCtr
				NC8->NC8_CODCTR := cCodCtr
				NC8->NC8_CODCAD := cCodCad
				NC8->NC8_REGRA  := cCodRegra
				NC8->NC8_STATUS := "1"
				NC8->NC8_VALOR	:= nValor
				NC8->(MsUnLock())
			EndIf
		EndIf
	EndIf

	RestArea(aAreaNC8)

return .t.

/*{Protheus.doc} OGX060RPEN
//TODO Descrição auto-gerada.
@author jean.schulze
@since 22/08/2018
@version 1.0
@return ${return}, ${return_description}
@param cCodRom, characters, descricao
@param cItemRom, characters, descricao
@param nQtd, numeric, descricao
@type function
*/
Function OGX060RPEN(cCodRom, cItemRom, nQtd)

	DbSelectArea("NC8")
	NC8->(DbSetOrder( 1 ))
	NC8->(DbGoTop())
	
	//verificar se é devol, se for, devolver os precos corretos proporcional- verificar o cancelamento da devolução
	If NC8->(dbSeek( FWxFilial( "NC8" ) + cCodRom + cItemRom ))
	
		//verifica se a pendencia já foi resolvida, se foi faremos um movimento em contrário
		
		//remove a pendencia	
		RecLock('NC8',.f.)
			NC8->(dbDelete())
		NC8->(MsUnLock())	
	endif			
return .t.

