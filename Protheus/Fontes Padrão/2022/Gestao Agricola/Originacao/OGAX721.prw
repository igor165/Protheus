#INCLUDE "OGAX721.CH"
#INCLUDE "protheus.CH"

//------------------------------------------------------------------
/*/{Protheus.doc} OGAX721

Fonte Genérico para tratar preço de faturamento do contrato

@author Rafael Völtz
@since 05/03/2018
@version 1.0
/*/


/*/{Protheus.doc} OGAX721FAT
//Função responsável por retornar o valor base do contrato de algodão ou grão 
@author rafael.voltz
@since 05/03/2018
@param cFilCtr, characters, Filial do contrato
@param cCodCtr, characters, Código do contrato
@param cPrevEnt, characters, Número da previsão de entrega
@param nRecDXI, numeric, Recno da DXI
@param nPeso, numeric, Peso do contrato de grão
@param dDataVenc, date, data de vencimento da previsão fin
@return aRet, Retorna o valor base do contrato, o tipo do preço 1 - Fixo, 2 - A Fixar, e a Origem do Preço - FIX: Fixação; IDX: Índice; CTR: Vlr Base do Contrato
/*/
Function OGAX721FAT(cFilCtr, cCodCtr, cPrevEnt, cRegraFis, nRecDXI, nPeso, nPrecoBase, cCodClient, cCodLoja, cFormCalc, nQtdConsum, nQtdUsTot, dDataVenc, aFixUsada)
 	Local aArea  	 	as array
	Local aRet          as array
	Local nValor 	 	as numeric
	Local cTpPrc        as char  
	Local cOrigPrc      as char    
	Local aFixCalc      as array	 
	
	//valores padrão da função
	Default cFilCtr    := ""
	Default cCodCtr    := "" 
	Default cPrevEnt   := ""
	Default cRegraFis  := ""
	Default nRecDXI    := 0
	Default nPeso      := 0
	Default nPrecoBase := 0
	Default cCodClient := ""
	Default cCodLoja   := ""	
	Default cFormCalc  := "F" //F-Faturamento / R-Recebimento
	Default nQtdConsum := 0 //Quantidade já usada - quebra de valor
    Default nQtdUsTot  := 0 //Quantidade já usada para todas as cadências
    Default aFixUsada  := {}
		
	aArea  	   := GetArea()
	aRet       := {}
	aFixCalc   := {}
	nValor 	   := 0		
	cTpPrc     := "2" //A Fixar  
	cOrigPrc   := ""
	cTipo      := ""
	 
	If Select("NJR") = 0
       DbSelectArea("NJR")
    EndIf
    
    If Select("NK0") = 0
       DbSelectArea("NK0")
    EndIf
    
	NJR->(dbSetOrder(1))
	NK0->(dbSetOrder(1))	
	
	/* ---- POSICIONA CONTRATO ---- */
	If NJR->(DbSeek(cFilCtr + cCodCtr)) 
	
		/* ---- ASSUME VALOR DA FIXAÇÃO ---- */
		If !empty(nRecDXI) //se trata de algodao
		 	dbSelectArea("DXI")
			DXI->(dbGoTo(nRecDXI))
			If !empty(DXI->DXI_ITEMFX)
			 	nValor   := DXI->DXI_VLBASE
			 	cTpPrc   := "1"
			 	cOrigPrc := "FIX" 	 
			 	cTipo    := DXI->DXI_CLACOM	
			EndIf
		Else
			nValor := VlrFixGrao(cFilCtr, cCodCtr, cPrevEnt, cRegraFis, nPeso, @cTpPrc, @cOrigPrc, @aFixCalc, nPrecoBase, cCodClient, cCodLoja, cFormCalc, @nQtdConsum, nQtdUsTot, @aFixUsada)			 			 
		EndIf
		
		/* ---- ASSUME VALOR CONTRATO (IDX OU NJR_VLRBAS) ---- */
		If nValor == 0
			
			nValor := GetVlrCtr(cFilCtr, cCodCtr, cPrevEnt, @cOrigPrc, nPrecoBase, cCodClient, cCodLoja, cTipo, dDataVenc)
			aadd(aFixCalc, {IIF("IDX" $ cOrigPrc, "3", "2"), nValor, nPeso, "", ""})
				
		EndIf
		
	EndIf
	
	aAdd(aRet,{nValor, cTpPrc, cOrigPrc, aFixCalc})
	
	RestArea(aArea)
 
Return aRet

/*{Protheus.doc} OGAX721REM
Retorna preços para contratos de depósito de 3º
@author jean.schulze
@since 24/04/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilCtr, characters, descricao
@param cCodCtr, characters, descricao
@param cTipo, characters, descricao
@param cUfOrig, characters, descricao
@param cUfDest, characters, descricao
@param nPeso, numeric, descricao
@type function
*/
Function OGAX721REM(cFilCtr as char, cCodCtr as char, cTipo as char, cUfOrig as char, cUfDest as char, nPeso as numeric)
	Local aFixCalc := {}
	Local cOrigPrc := ""
	Local aRet     := {}
	Local nValor   := 0
	//chama as funções de preco - por indice ou por valor base
	If NJR->(DbSeek(cFilCtr + cCodCtr ))		
	
		/* ---- ASSUME VALOR DO ÍNDICE DO CONTRATO ---- */
		If !Empty(NJR->NJR_CODIDX)
			
			cOrigPrc := "IDX"
			nValor := GetVlrIdx(NJR->NJR_CODIDX, cCodCtr, NJR->NJR_CODPRO, cTipo, NJR->NJR_CODSAF, cUfOrig, cUfDest)
			
			//tabela, quando usado este tipo de indice não busca valores no valor base.
			if nValor == 0 .and. POSICIONE("NK0", 1, FwxFilial("NK0") + NJR->NJR_CODIDX , "NK0_TPCOTA") == "T" 
				aAdd(aRet,{nValor, "2", cOrigPrc, aFixCalc})	
				return aRet //volta 0 mesmo, validação da função
			endif
			
		EndIf		
				
		/* ---- ASSUME VALOR BASE DO CONTRATO ---- */
		If nValor == 0
			cOrigPrc := "CTR"
			nValor := NJR->NJR_VLRBAS
		EndIf
		
	endif
	
	aadd(aFixCalc, {IIF(cOrigPrc $ "IDX", "3", "2"), nValor, nPeso, "", ""})
	aAdd(aRet,{nValor, "2", cOrigPrc, aFixCalc})	

return aRet

/*/{Protheus.doc} GetVlrIdx
//TODO Retorna o valor base conforme o indice passado por parâmetro
@author author
@since 05/03/2018
@version version
@param cIdx, characters, Código do índice
@param cCodCtr, characters, Código do contrato
@return nValor, Valor cálculo conforme índice passado por parâmetro.
@example
(examples)
@see (links_or_references)
/*/
Static Function GetVlrIdx(cIdx as char, cCodCtr as char, cCodPro as char, cTipo as char, cSafra as char, cUfOrig as char, cUfDest as char, cPrevEnt as char, dDataVenc as date)
	
	Local nVrIndice as numeric	
	Local aAreaNJR  as array
	Local aAreaNK0  as array
	Local cAliasN7C as char
	Local cUM1PRO   as char

    Default cPrevEnt  := ""
	Default dDataVenc := dDataBase

	aAreaNJR := GetArea('NJR')
	aAreaNK0 := GetArea('NK0')	

	cUM1PRO   := ""
	nVrIndice := 0
	cAliasN7C := GetNextAlias()	

	//procura o valor do indice no momento da geração do reg. de negócio.
	//se vier o cprevent em branco ele não usa pra consulta
    BeginSql Alias cAliasN7C
                    
        SELECT 
            N7C_CODNGC, N7C_VLRIDX, N7C_MOEDCO
        FROM 
            %table:N7C% N7C
        WHERE 			
            N7C.N7C_CODNGC = %Exp:NJR->NJR_CODNGC%  AND	
            N7C.N7C_VERSAO = %Exp:NJR->NJR_VERSAO%  AND
            N7C.N7C_BOLSA = %Exp:NJR->NJR_BOLSA%  AND			
            N7C.N7C_CODCAD = %Exp:cPrevEnt% AND	
            N7C.%NotDel%							
    EndSql
 
	If !Empty((cAliasN7C)->N7C_VLRIDX )
		nVrIndice  := (cAliasN7C)->N7C_VLRIDX 

		If NK0->(DbSeek(xFilial("NK0") + cIdx ))
			cUM1PRO := NK0->NK0_UM1PRO
		EndIF
	Else
		If NK0->(DbSeek(xFilial("NK0") + cIdx ))
			cUM1PRO := NK0->NK0_UM1PRO
			nVrIndice:= AgrGetInd( NK0->NK0_INDICE,NK0->NK0_TPCOTA, dDataBase, cCodPro, cTipo, cSafra, cUfOrig, cUfDest )
		EndIF
    EndIf	


	If NJR->(dbSeek(xFilial("NJR")+cCodCtr)) //verifica se o indíce está na mesma um do negócio 			 
		nVrIndice := OGX700UMVL(nVrIndice, cUM1PRO, NJR->NJR_UMPRC , NJR->NJR_CODPRO)	

		//Se a Moeda não for real, convertemos.
		If (cAliasN7C)->N7C_MOEDCO <> 1 .AND. NJR->NJR_MOEDA == 1
			nVrIndice := OGAX721MOE(nVrIndice, (cAliasN7C)->N7C_MOEDCO, NJR->NJR_TIPMER, NJR->NJR_DIASR, (cAliasN7C)->N7C_MOEDCO, dDataVenc)[1]			
		EndIf	
	EndIf	

    (cAliasN7C)->(DbCloseArea())

	RestArea(aAreaNJR)	
	RestArea(aAreaNK0)

Return nVrIndice


/*/{Protheus.doc} VlrFixGrao
//TODO Descrição auto-gerada.
@author author
@since 05/03/2018
@version version
@param cIdx, characters, Código do índice
@param cCodCtr, characters, Código do contrato
@param cPrevEnt, char, Número da previsão de entrega
@param nPeso, numeric, Peso
@param cTpPrc, char, Tipo de preço A - Aberto F - Fechado
@return nValor, Valor cálculo conforme índice passado por parâmetro. 
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function VlrFixGrao(cFilCtr as char, cCodCtr as char, cPrevEnt as char, cRegraFis as char, nPeso as numeric, cTpPrc as char, cOrigPrc as char, aFixCalc as array, nPrecoBase as numeric, cCodClient as char, cCodLoja as char, cFormCalc as char, nQtdConsFx as numeric, nQtdUsTot as numeric, aFixUsada as array )
	Local nValor 	as numeric
	Local cAliasQry as char
	Local nSaldo    as numeric
	Local nTot      as numeric
	Local nVlrCtr   as numeric
	Local cQuery    as char
    Local lAchouN8D as logical
    Local cAliasNN8 as char    
    Local nQtdFix   as numeric
    Local nQtdDisp  as numeric
	Local nX        as numeric
	Local nQtdUsada as numeric
	
	Default cPrevEnt := ""
    Default nQtdUsTot := 0
	Default aFixUsada := {}

    lAchouN8D := .F.
	
	nValor 	  := 0
	nTot      := 0
	nSaldo    := nPeso
	cAliasQry := GetNextAlias()
        cAliasNN8 := GetNextAlias()
	cOrigPrc  := "FIX"
	
	cQuery := "SELECT N8D.N8D_ORDEM,"
	cQuery += 		" N8D.N8D_ITEMFX,"
	cQuery += 		" N8D.N8D_SEQVNC,"
	cQuery += 		" N8D.N8D_QTDVNC,"
	cQuery += 		" N8D.N8D_QTDFAT,"	
	cQuery += 		" N8D.N8D_VALOR"
	cQuery +=  " FROM "+ RetSqlName("N8D") + " N8D "
	
	If !Empty(cPrevEnt)
		cQuery += " INNER JOIN "+ RetSqlName("NN8") + " NN8  "
		cQuery += 		  " ON NN8.NN8_FILIAL = N8D.N8D_FILIAL AND NN8.NN8_CODCTR = N8D.N8D_CODCTR AND NN8.NN8_ITEMFX = N8D.N8D_ITEMFX AND NN8.D_E_L_E_T_ = ' '"
		cQuery += 		  " AND NN8.NN8_CODCAD = '" + cPrevEnt + "'"
	EndIf
	
	cQuery += " WHERE N8D.N8D_FILIAL = '" + cFilCtr +"'"
	cQuery +=  " AND N8D.N8D_CODCTR  = '" + cCodCtr +"'"
	
	if cFormCalc == "F" //está faturando -  algodão não executa esse trecho
		cQuery +=  " AND N8D.N8D_QTDVNC  >  N8D.N8D_QTDFAT"
	endif
	
	If !Empty(cRegraFis)
		cQuery +=  " AND N8D.N8D_REGRA  = '" + cRegraFis +"'"	
	endif
		
	cQuery +=  " AND N8D.D_E_L_E_T_  = ' ' " 
	cQuery +=  " ORDER BY N8D.N8D_ORDEM "
	
	cQuery	:=	ChangeQuery( cQuery )
	dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry)

	(cAliasQry)->(DbGoTop())
	While (cAliasQry)->(!Eof())
		
		lAchouN8D := .T.

        If nSaldo > 0 
			nQtdFix   := iif(cFormCalc == "F", ((cAliasQry)->N8D_QTDVNC  - (cAliasQry)->N8D_QTDFAT), (cAliasQry)->N8D_QTDVNC ) 
			/* controle de saldo de fixações já utilizadas */
            If cFormCalc == "R"   
                nQtdUsada := 0
                For nX := 1 TO LEN(aFixUsada)
                    If aFixUsada[nx,1] == (cAliasQry)->N8D_ITEMFX
                        nQtdUsada += aFixUsada[nx,2] 
                    EndIf
                Next nX

                nQtdFix -= nQtdUsada
            EndIf
			
			//tem quantidade fixada para utilizar
			if nQtdFix > 0		
				If nSaldo >= nQtdFix 
					nTot += nQtdFix   * (cAliasQry)-> N8D_VALOR
					aAdd(aFixCalc,  {"1", (cAliasQry)-> N8D_VALOR, nQtdFix  , (cAliasQry)->N8D_ITEMFX, (cAliasQry)->N8D_SEQVNC })
                    aAdd(aFixUsada, {(cAliasQry)->N8D_ITEMFX, nQtdFix, (cAliasQry)-> N8D_VALOR})
					nSaldo -= nQtdFix					
				Else
					nTot += nSaldo * (cAliasQry)-> N8D_VALOR
					aadd(aFixCalc, {"1", (cAliasQry)-> N8D_VALOR, nSaldo, (cAliasQry)->N8D_ITEMFX, (cAliasQry)->N8D_SEQVNC})
                    aAdd(aFixUsada, {(cAliasQry)->N8D_ITEMFX, nSaldo, (cAliasQry)-> N8D_VALOR})
					nSaldo := 0
				EndIf
			endif
		Else
			exit
		EndIf
				
		(cAliasQry)->(DbSkip())
	EndDo
	
	(cAliasQry)->(DbCloseArea())

    If !lAchouN8D .and. AGRTPALGOD(NJR->NJR_CODPRO)
    	cAliasNN8 := GetNextAlias()
        BeginSql Alias cAliasNN8
            SELECT NN8_ITEMFX, NN8_QTDFIX - NN8_QTDRES QTDDISP, NN8_VLRUNI
              FROM %table:NN8% NN8
             WHERE NN8_FILIAL = %xFilial:NN8%
               AND NN8_CODCTR = %Exp:cCodCtr%
               AND NN8_TIPOFX = '1' //preço
               AND NN8_QTDFIX - NN8_QTDRES > 0
               AND %NotDel%
        EndSql   

        (cAliasNN8)->(DbGoTop())
        While (cAliasNN8)->(!Eof())
            //tem saldo para diminuir
            If nSaldo > 0							
                nQtdDisp := (cAliasNN8)->QTDDISP
                if nQtdUsTot > 0 .and.  cFormCalc == "R" //usada para as previsões			
                    if nQtdDisp >= nQtdUsTot
                        nQtdDisp   -= nQtdUsTot
                        nQtdUsTot := 0				
                    else 
                        nQtdUsTot -= nQtdDisp
                        nQtdDisp   := 0
                    endif
                endif

                If nQtdDisp > 0
                    
                    If nSaldo >= nQtdDisp 
                        nTot += nQtdDisp   * (cAliasNN8)-> NN8_VLRUNI
                        aadd(aFixCalc, {"1", (cAliasNN8)-> NN8_VLRUNI, nQtdDisp  , (cAliasNN8)->NN8_ITEMFX,  })
                        nSaldo -= nQtdDisp
                    Else
                        nTot += nSaldo * (cAliasNN8)-> NN8_VLRUNI
                        aadd(aFixCalc, {"1", (cAliasNN8)-> NN8_VLRUNI, nSaldo, (cAliasNN8)->NN8_ITEMFX,})
                        nSaldo := 0
                    EndIf

                EndIf
            Else 
                exit
            EndIf	

            (cAliasNN8)->(DbSkip())
        EndDo

        (cAliasNN8)->(DbCloseArea())
    EndIf
	
	/* ---- Quantidade é maior que a previsão de entrega, considera valor do contrato ---- */
	If nTot > 0
		If nSaldo > 0
			/* Não possui toda a quantidade fixada*/
			cTpPrc := "2" //A Fixar  
					
			nVlrCtr := GetVlrCtr(cFilCtr, cCodCtr, cPrevEnt, @cOrigPrc, nPrecoBase, cCodClient, cCodLoja, "" /*Tipo*/ )
			
			aadd(aFixCalc, {IIF(cOrigPrc $ "IDX", "3", "2"), nVlrCtr, nSaldo, "", ""})
					
			if nVlrCtr > 0   
				nTot += nSaldo * nVlrCtr
			else  //se o valor estiver zerado (não tem valor base ou índice), desconsiderar o peso referente ao valor zero para não afetar o valor final do preço.
				nPeso -= nSaldo      
			endif
		Else
			/* Possui toda a quantidade fixada*/
			cTpPrc    := "1" //Fixo			
		EndIf
	EndIf
	
	If nTot > 0 .And. nPeso > 0
		nValor := nTot / nPeso
	EndIf	    
	
Return nValor

/*/{Protheus.doc} GetVlrCtr
//TODO Descrição auto-gerada.
@author author
@since 05/03/2018
@version version
@param cFilCtr, characters, Filial do contrato
@param cCodCtr, characters, Código do contrato
@param cPrevEnt, characters, Número da previsão de entrega 
@return nValor, Valor base do contrato
@example
(examples)
@see (links_or_references)
/*/
Static Function GetVlrCtr(cFilCtr as char, cCodCtr as char, cPrevEnt as char, cOrigPrc as char, nPrecoBase as numeric, cCodClient as char, cCodLoja as char, cTipo as char, dDataVenc as date)
 
 	Local nValor        as numeric  
 	Local cAliasQry 	as char 
 	Local cAliasN7M 	as char 
 	Local cAliasN7C 	as char
 	Local cUfDest       as char
 	Local cUfOrig       as char   	
 	
 	Local aCompN7M      := {} 	
 	Local nDecCompon    := TamSx3('N7C_VLRCOM')[2]	
  		
 	nValor     := 0
 	
	/* ---- ASSUME VALOR DO ÍNDICE DA CADÊNCIA ---- */ 	
	If !Empty(cPrevEnt)
		cAliasQry  := GetNextAlias()
		BeginSql Alias cAliasQry
			
			SELECT NNY.NNY_IDXNEG
			  FROM %table:NNY% NNY
			 WHERE NNY.NNY_FILIAL = %Exp:cFilCtr%
			   AND NNY.NNY_CODCTR = %Exp:cCodCtr% 
			   AND NNY.NNY_ITEM   = %Exp:cPrevEnt%
			   AND NNY.%NotDel%
			   
		EndSql
		
		(cAliasQry)->(DbGoTop())
		
		If (cAliasQry)->(!Eof())
			 If !Empty((cAliasQry)->NNY_IDXNEG)
			 	cOrigPrc := "IDX"
			 	
			 	if NJR->NJR_TIPO $ "1|3" //compra e armazenagem -> entradas
			 		cUfDest := SUPERGETMV("MV_ESTADO", .f., "")
			 		cUfOrig := POSICIONE("SA2",1, xFilial("SA2") + cCodClient + cCodLoja, "A2_EST")
			 	else //saídas (compra e remessa a 3º)
			 		cUfDest := POSICIONE("SA1",1,xFilial("SA1") + cCodClient + cCodLoja, "A1_EST")
			 		cUfOrig := SUPERGETMV("MV_ESTADO", .f., "")
			 	endif
			 	
			 	nValor := GetVlrIdx((cAliasQry)->NNY_IDXNEG, cCodCtr, NJR->NJR_CODPRO, cTipo , NJR->NJR_CODSAF, cUfOrig, cUfDest , cPrevEnt, dDataVenc)
			 	
			 	/**********Verifica se temos algum componente fixado para diminuir basis do calculo***********/
		 		//busca os calculos para gerar através da N7M... verificar o consumo de saldo
		 		//busca todos os N7M com valor e coloca num array
	 		 	cAliasN7M  := GetNextAlias()
		 		BeginSql Alias cAliasN7M
					
					SELECT *
					  FROM %table:N7M% N7M
					 WHERE N7M.N7M_FILIAL = %Exp:cFilCtr%
					   AND N7M.N7M_CODCTR = %Exp:cCodCtr% 
					   AND N7M.N7M_CODCAD = %Exp:cPrevEnt%
                       AND N7M.N7M_QTDSLD > 0
					   AND N7M.%NotDel%
					   
				EndSql
				
				(cAliasN7M)->(DbGoTop())
				
				While (cAliasN7M)->(!Eof())
					aadd(aCompN7M, {(cAliasN7M)->N7M_CODCOM, (cAliasN7M)->N7M_VALOR , (cAliasN7M)->N7M_UMCOM, (cAliasN7M)->N7M_MOEDA, (cAliasN7M)->N7M_TXMOED  })
					(cAliasN7M)->(dbSkip())
				EndDo

				(cAliasN7M)->(DbCloseArea())

				//tem componente(basis) fixado
				if len(aCompN7M) > 0
				
					cOrigPrc := "IDX+FIX"
					
					//posiciona no componente de preço faturamento para requerer sua formula
					cAliasN7C  := GetNextAlias()
					BeginSql Alias cAliasN7C
					
						SELECT N7C_CODCOM
						  FROM %table:N7C% N7C
						 WHERE N7C.N7C_FILIAL = %Exp:cFilCtr%
						   AND N7C.N7C_CODNGC = %Exp:NJR->NJR_CODNGC% 
						   AND N7C.N7C_VERSAO = %Exp:NJR->NJR_VERSAO% 
						   AND N7C.N7C_CODCAD = %Exp:cPrevEnt%
						   AND N7C.N7C_BOLSA  = "" //remove tudo que é bolsa - duplicidade de preco
						   AND N7C.N7C_TPPREC = "2" //preço negociado
						   AND N7C.%NotDel%
						   
					EndSql
					
					(cAliasN7C)->(DbGoTop())
					
					If (cAliasN7C)->(!Eof())
						
						//efetua os calculos no valor base(indice)
						DbselectArea( "N75" )
						DbSetOrder( 1 )
						DbGoTop()
						If dbSeek( xFilial( "N75" ) +  (cAliasN7C)->N7C_CODCOM )
							While !N75->( EoF() ) .And. N75->( N75_FILIAL + N75_CODCOM ) == xFilial( "N75" ) + (cAliasN7C)->N7C_CODCOM 
								
								//seekline
								nPos := aScan(aCompN7M,{|x| x[1] == N75->(N75_CODCOP)  }) //localiza o fardo dentro do array de agrupamento
								
								if nPos > 0
																	
									//vamos colocar na unidade de medida do negócio
									nValorComp := Round(OGX700UMVL(aCompN7M[nPos][2],aCompN7M[nPos][3],NJR->NJR_UMPRC, NJR->NJR_CODPRO ) ,nDecCompon )					
													
									//vamos aplicar a cotação
									if NJR->NJR_MOEDA <> aCompN7M[nPos][4]
										if aCompN7M[nPos][4] > 1 //moeda corrente
											nValorComp := Round(nValorComp * aCompN7M[nPos][5],nDecCompon )											
										else
											nValorComp := Round(nValorComp / aCompN7M[nPos][5] ,nDecCompon ) //retornamos na cotacao
										endif
									endif
															
									nValor  += iif(N75->( N75_OPERAC) == "1", 1, -1) * nValorComp //fazer tratamento de unidade de medida
								
								endif					
									
								N75->( dbSkip() )
								
							Enddo
							
						Endif							
						
					EndIf
					(cAliasN7C)->(dbCloseArea())
											
				endif		 		
			 		
			 	
			 	
			 EndIf			 	
		EndIf
		
		(cAliasQry)->(DbCloseArea())
	EndIf
 
	If nValor == 0
		if nPrecoBase > 0 // preço de simulação
			nValor := nPrecoBase 
			cOrigPrc := "CTR" 	
		else
			
			/* ---- ASSUME VALOR DO ÍNDICE DO CONTRATO ---- */
			If !Empty(NJR->NJR_CODIDX)
				cOrigPrc := "IDX"
				
				if NJR->NJR_TIPO $ "1|3" //compra e armazenagem -> entradas
			 		cUfDest := SUPERGETMV("MV_ESTADO", .f., "")
			 		cUfOrig := POSICIONE("SA2",1, xFilial("SA2") + cCodClient + cCodLoja, "A2_EST")
			 	else //saídas (compra e remessa a 3º)
			 		cUfDest := POSICIONE("SA1",1, xFilial("SA1") + cCodClient + cCodLoja, "A1_EST")
			 		cUfOrig := SUPERGETMV("MV_ESTADO", .f., "")
			 	endif
				
				nValor := GetVlrIdx(NJR->NJR_CODIDX, cCodCtr, NJR->NJR_CODPRO, cTipo , NJR->NJR_CODSAF, cUfOrig, cUfDest)
			EndIf		
					
			/* ---- ASSUME VALOR BASE DO CONTRATO ---- */
			If nValor == 0
				cOrigPrc := "CTR"
				nValor := NJR->NJR_VLRBAS
			EndIf
			
		endif
	endif	
Return nValor

/*{Protheus.doc} OGAX721MOE
Tratamento para precificação em outras moedas
@author jean.schulze
@since 02/05/2018
@version 1.0
@return ${return}, ${return_description}
@param nValor, numeric, descricao
@param nMoedaCalc, numeric, descricao
@param nFatorConv, numeric, descricao
@param cTipoMerc, characters, descricao
@param nDias, numeric, descricao
@param cOperMORec, characters, descricao
@type function
*/
Function OGAX721MOE(nValor, nMoedaCalc, cTipoMerc, nDias, nMoedaFat, dDatBasCal )
	Local nFatorConv := 1
	Local cIndice    := ""
	Local cNomeMoed	 := ""
	Local cDataCota	 := ""
    Local nDecimal   := TamSx3('M2_MOEDA2')[2] //casa decimais componentes

	Default dDatBasCal := dDataBase
	
	if nMoedaCalc <> 1 .and. cTipoMerc <> "2" //moeda diferente de corrente e mercado interno
		//busca o nome da moeda
		cNomeMoed	 := POSICIONE("NJ7",1,xFilial("NJ7") + AllTrim(Str(nMoedaFat)), "NJ7_DESCRI")
		
    	If (dDatBasCal - nDias) > dDataBase			
        	cIndice    := POSICIONE("NJ7",1,xFilial("NJ7") + AllTrim(Str(nMoedaFat)), "NJ7_INDICE")                    
        	nFatorConv := getVlIndic(cIndice, dDatBasCal - nDias)		                
			If nFatorConv > 0
				nValor := nValor * nFatorConv
			Else
				nFatorConv := xMoeda(1, nMoedaFat, 1, dDatBasCal - nDias, nDecimal) //guardar a cotação utilizada
    			nValor     := xMoeda(nValor, nMoedaFat, 1, dDatBasCal - nDias, nDecimal)
			EndIf			
		Else
			nFatorConv := xMoeda(1, nMoedaFat, 1, dDatBasCal - nDias, nDecimal) //guardar a cotação utilizada
    		nValor     := xMoeda(nValor, nMoedaFat, 1, dDatBasCal - nDias, nDecimal)
		EndIf	

		dDatBasCal -= nDias   
		nMoedaCalc := 1 //Moeda do calculo é a moeda corrente
    elseif nMoedaCalc <> 1  //busca o cambio do dia
     	//busca o nome da moeda
		cNomeMoed	 := POSICIONE("NJ7",1,xFilial("NJ7") + AllTrim(Str(nMoedaCalc)), "NJ7_DESCRI")

		 If dDatBasCal > dDataBase
		 	cIndice   := POSICIONE("NJ7",1,xFilial("NJ7") + AllTrim(Str(nMoedaCalc)), "NJ7_INDICE")                    
        	nFatorConv := getVlIndic(cIndice, dDatBasCal)		                
		Else
			nFatorConv := xMoeda(1, nMoedaCalc, 1, dDatBasCal, nDecimal)
		EndIf
    endif

	//se nao encontrar cotação apresenta uma mensagem
	If nFatorConv == 0
		If cTipoMerc <> "2" .AND. nMoedaCalc <> 1 .AND. ISINCALLSTACK("OGX018") 
			cDataCota := DtoC(dDatBasCal - nDias)
            _cMsgErro += STR0002 + AllTrim(cNomeMoed) + STR0003 + AllTrim(cDataCota) + CHR(13) + CHR(10) //Não foi encontrada cotação para Moeda XXX na data XX/XX/XXXX            
		EndIf
	EndIf
	
return {nValor, nMoedaCalc, dDatBasCal, nFatorConv}

/*{Protheus.doc} getVlIndic
Retornar o valor do índice conforme o item do plano de vendas
@author rafael.voltz
@since 05/09/2018
@type function
*/
Static Function  getVlIndic(cIndice, dDataRef) 
	Local nValor     := 0
	Local aAreaNK0   := NK0->(GetArea()) 	
    
    nVrIndice := 0
	dbSelectArea("NK0")
	NK0->( dbSetOrder(1) )
	If NK0->(DbSeek(xFilial("NK0") + cIndice ))
		nValor := AgrGetInd( NK0->NK0_INDICE,NK0->NK0_TPCOTA, dDataRef)
	EndIF

	RestArea(aAreaNK0)

return nValor
