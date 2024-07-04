#INCLUDE "OGX018.CH"
#INCLUDE "protheus.CH"
#INCLUDE "fwmvcdef.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#DEFINE _CRLF CHR(13)+CHR(10)

/*
PREVISÃO FINANCEIRA
Gerar registros na NN7 seguindo os seguintes parâmetros:
 1 - Cadastro de condições de pagamento
    a) Percentual: a soma dos percentuas deve ser igual a 100%
    b) Quantidade: a soma das quantidade deve ser igual a quantidade total do contrato
        
    c) intervalo de valores para os campos da NN7
    	i. 		ANTPOS: 1=Anterior;2=Posterior
    	ii.		REFCTR: 1=Data Faturamento; 2=Data BL; 3=Data Take Up; 4=Chegada no destino;
                        5=Início cadência; 6=Fim cadência; 7=Data Negociada
    	iii.	REFPRF: 1=Início cadència; 2=Fim cadência; 3=Data Max Take Up; 4=Data Lim. Fixação
    	iv.		TIPVCT: 1=Absoluto; 2=Próximo dia útil; 3=XX dias mês subsequente
    	v.		TIPVAL: 1=Quantidade; 2=Percentual
 
 2 - Cada Previsão de entrega pode ter 1 ou mais Regras fiscais
 3 - Cada regra fiscal tem um take-up vinculado

 4 - Para gerar as previsões financeiras, deve-se inserir um registro em:
     (n)Previsão de entregas X (n)Regra Fiscal X (n)Condição de Pagamento
*/

/** {Protheus.doc} OGX018
Gera a previsão financeira do contrato de acordo com os critérios de condição de pagamento
@param:     cFilCtr   - Filial do contrato
            cContrato - Código do contrato
            lMdlContrato - Indica se deve utilizar o Modelo do contrato (FwModelActive) 
@return:    Nenhum retorno é esperado
@author:    Marcelo Ferrari
@since:     24/07/2017
@Uso:       OGC290 - Contrato de Venda
*/
Function OGX018(cFilCtr, cContrato, lRegerarPF, oModel)
	Local aAreas       := GetArea()
    Local lRet 		   := .T.	
    Local aSaveRows    := Nil
    
    
    Default lRegerarPF := .T.  
    Default oModel     := nil
    
	Private _aDados    := Nil
    Private _cMsgErro  := ""
    Private _nOperation := nil

    //Caso o Model tenha vindo vazio, posiciona no registro do contrato
    if lRegerarPF
	   
        If ValType(oModel) == "O" // Se for o model do contrato ativo
           _nOperation := oModel:GetOperation()
           If !(_nOperation == MODEL_OPERATION_INSERT .OR. _nOperation == MODEL_OPERATION_UPDATE) // Se a operação for diferente de insert ou update
               Help( , ,"Aviso", , "Para gerar a previsão financeira o contrato deve estar no modo de Inserção ou Atualização.", 1, 0)
               Return .F.
           EndIf
        Else
           Help( , ,"Aviso", , "Modelo inválido para gerar previsão financeira.", 1, 0)
           Return .F.
        EndIf        
        
	    aSaveRows	:= FwSaveRows(oModel)

        If !fVldRegraF(cFilCtr, cContrato, oModel)            
            Return .F.
        EndIf 
	
	    Processa({|| OGX018PRC(oModel)},  "Gerando Previsão Financeira." )	   
	  
	    FwRestRows(aSaveRows)
	else
        If !fVldRegraF(cFilCtr, cContrato, oModel)            
            Return .F.
        EndIf 

        Processa({|| OGX018UPD(cFilCtr, cContrato)},  "Atualizando Valores da Previsão Financeira." )
    endif
        
    RestArea(aAreas)
    
    if !empty(_cMsgErro) //teve algum erro no processo
    	lRet := .f. 
    endif
    
Return lRet


/** {Protheus.doc} fCargaDados
//Inicializa o processo, faz a gravação do Modelo e tratamento de erro
@Param:    NIL
@REturn     lRet  -> Indica status de processamento
@author:    Marcelo Ferrari
@since:     19/03/2017
@Uso:       OGCX018/OGA290
*/
Function OGX018PRC(oModel)
    Local lRet   := .T.
    Local oModelNJR := oModel:GetModel("NJRUNICO")

    lRet := fCargaDados(oModel)

    If !Empty( _aDados ) .AND. lRet       
   
            //Insere os dados da previsão financeira na tabela NN7
            fGravaPrev(oModel)
            
            //valida a gravação dos campos
            if OGX700ERRO(oModel) //trata erros executados no modelo no momento do processamento    
            	_cMsgErro +=  _CRLF + "Erro ao gravar dados da previsão financeira."
            	return .f.
            endif      
     EndIf

    If !empty(_cMsgErro)    		    
        oModel:GetModel():SetErrorMessage( oModelNJR:GetId(), , oModelNJR:GetId(), "", "", "Um erro no processamento não permitiu a gravação dos dados." + _CRLF + _cMsgErro, "", "") //"Ajuda"#"Não existe Componente com Saldo para apropriação. Verificar as fixações do componente."										        
        lRet := .f.
    Endif

Return lRet

/*{Protheus.doc} OGX018UPD
Atualiza os valores das previsões financeiras e regra fiscal
@author jean.schulze
@since 07/06/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilCtr, characters, descricao
@param cCodCtr, characters, descricao
@type function
1*/
Function OGX018UPD(cFilCtr, cContrato)
	Local nValorTot := 0
	Local aAreaN9A  := GetArea("N9A")
	Local aAreaNN7  := GetArea("NN7")
	Local aAreaN9J  := GetArea("N9J")
    Local aAreaNJR  := GetArea("NJR")
	Local aNN7Updat := {}	
	Local nPos      := 0
	Local nCount    := 0	
	Local nVlrConsu := 0
	Local nMoedaRec  := 1 
    Local nQtdDiasF  := 0
    Local cTipoMerc  := ""
    Local cOperMORec := ""    
    Local nMoedaCtr  := 1	
	Local nQtdEvent  := 0				
    Local nMoedaBase := 1
    Local nDiasBase  := 0
    Local nQtdDiasR  := 0
    Local nQtdUsTot  := 0    
    Local nX         := 0    
    Local cAliasQry2 := GetNextAlias()
    Local cAliasN9J  := GetNextAlias()    
	Local nStatus    := 0
	Local lDelete    := .T.
    Local cOrder     := ""
    Local lExistND1  := TableInDic("ND1")    
    Local nTotValor  := 0
				
	DbSelectArea("NJR")	
	NJR->(dbSetOrder(1))
    if NJR->(dbSeek(cFilCtr+cContrato)) //temos cadências
	    nMoedaRec  := NJR->NJR_MOEDAF
        nQtdDiasR  := NJR->NJR_DIASF  
        nMoedaFat  := NJR->NJR_MOEDAR
	    nQtdDiasF  := NJR->NJR_DIASR         
	    cTipoMerc  := NJR->NJR_TIPMER
	    nMoedaCtr  := NJR->NJR_MOEDA
	    cUmPrec    := NJR->NJR_UMPRC
	    cUmProd    := NJR->NJR_UM1PRO
	    cCodPro    := NJR->NJR_CODPRO
	    cCodNgc    := NJR->NJR_CODNGC
	    cVersao    := NJR->NJR_VERSAO 
        cOperMORec := NJR->NJR_OPERAC
    endif
    //Quando a referência é pagamento, deve considerar a moeda de pagamento.
    If cOperMORec == "2"
        nMoedaBase := nMoedaRec
        nDiasBase  := nQtdDiasR
    Else    
        nMoedaBase := nMoedaFat
        nDiasBase  := nQtdDiasF
    EndIf

    If FieldPos("N9J_TIPEVE") > 0
        cOrder := "%ORDER BY N9J.N9J_TIPEVE, N9J.N9J_VENCIM%" //primeiro as por evento, para consumir as fixações
    Else
        cOrder := "%ORDER BY N9J.N9J_VENCIM%"
    EndIf		    
		    
	//Lista as Previsão de entrega
	DbSelectArea("NNY")	
	NNY->(dbSetOrder(1))
    if NNY->(dbSeek(cFilCtr+cContrato)) //temos cadências
    	while !Eof() .And. alltrim(NNY->(NNY_FILIAL+NNY_CODCTR)) == alltrim(cFilCtr+cContrato)
    		
    		//busca as regras fiscais
    		DbSelectArea("N9A")	
			N9A->(dbSetOrder(1))
		    if N9A->(dbSeek(cFilCtr+cContrato+NNY->NNY_ITEM)) //temos regras fiscais
		    	while !Eof() .And. alltrim(N9A->(N9A_FILIAL+N9A_CODCTR+N9A_ITEM)) == alltrim(cFilCtr+cContrato+NNY->NNY_ITEM)
		    		
		    		nValorTot  := 0
		    		aLstRegra  := {} //reset
		    		aVlrRegFis := {}
		    		cCodClient := ""
					cCodLoja   := ""
		    		cTes       := N9A->N9A_TES
		    		cNatuFin   := N9A->N9A_NATURE
		    		cTipoCli   := N9A->N9A_TIPCLI
		    		cFilOrg    := N9A->N9A_FILORG	
		    		cCodCad    := NNY->NNY_ITEM
		    		cCodRegFis := N9A->N9A_SEQPRI	    		
		    	
		    		//verifica o cliente 
		    		DbSelectArea("NJ0")
					NJ0->(DbSetOrder(1))
					If NJ0->(DbSeek(xFilial("NJ0")+N9A->N9A_CODENT+N9A->N9A_LOJENT))
						if NJR->NJR_TIPO == "1" //Compras - fornecedor
							cCodClient     := NJ0->NJ0_CODFOR
							cCodLoja       := NJ0->NJ0_LOJFOR				
						else //vendas - cliente
							cCodClient     := NJ0->NJ0_CODCLI
							cCodLoja       := NJ0->NJ0_LOJCLI				
						endif
					EndIf                    
					
					nQtdEvent := 0
                    nCount    := 0                    

		    		//busca as quebras da regra fiscal
                    BeginSQL Alias cAliasN9J
                        SELECT N9J_FILIAL,
                               N9J_CODCTR,
                               N9J_ITEMPE,
                               N9J_ITEMRF,
                               N9J_VENCIM,
                               N9J_QTDE,
                               N9J_PERCEN,
                               N9J_QTDE,
                               N9J_SLDQTD,
                               N9J_QTDEVT,
                               N9J_VLFCON,
                               R_E_C_N_O_
                          FROM %table:N9J% N9J
                         WHERE N9J.N9J_FILIAL = %Exp:cFilCtr%
                           AND N9J.N9J_CODCTR = %Exp:cContrato%
                           AND N9J.N9J_ITEMPE = %Exp:cCodCad%
                           AND N9J.N9J_ITEMRF = %Exp:cCodRegFis%
                           AND N9J.%notDel%
                           %Exp:cOrder%                        
                    EndSQL
		    		
                    (cAliasN9J)->(dbGoTop())
				    While (cAliasN9J)->(!Eof())                    
                        nCount++
                        //temos que criar um array
                        OGX018STRG(@aLstRegra, (cAliasN9J)->R_E_C_N_O_, stod((cAliasN9J)->N9J_VENCIM), (cAliasN9J)->N9J_QTDE, (cAliasN9J)->N9J_PERCEN, (cAliasN9J)->N9J_QTDE - (cAliasN9J)->N9J_SLDQTD, nMoedaCtr, 0 /* QTDEVENTO */, (cAliasN9J)->N9J_VLFCON)
                        
                        //guarda a quantidade a fixar
                        nQtdEvent := (cAliasN9J)->N9J_QTDEVT
                        (cAliasN9J)->(dbskip())
                    EndDo

                    (cAliasN9J)->(dbCloseArea())
                    
                    //realiza os updates de valor, para incluir conforme a quantidade
                    aVlrRegFis := OGX018UVLR(@aLstRegra, cFilCtr, cContrato, cCodCad, cCodRegFis, cCodClient, cCodLoja, cTes, cNatuFin, cFilOrg, cCodNgc, cVersao, cTipoMerc, nMoedaBase, nDiasBase, cUmPrec, cUmProd, cCodPro, nMoedaCtr, cTipoCli, nQtdEvent, , @nQtdUsTot)
                    
                    //ele retorna o valor de cada n9j

                    //Limpar os registros da tabela ND1 para não ficar lixo
                    //Apenas na primeira iteração
                    If lDelete .and. lExistND1
                        nStatus := TCSqlExec("DELETE FROM " + RetSqlName("ND1") + " " + ;
                                            "WHERE ND1_FILIAL = '" + N9J->N9J_FILIAL + "' " + ;
                                            "AND ND1_CODCTR = '" + cContrato + "' " )
                        lDelete := .F.
                    EndIf

                    for nCount := 1 to len(aLstRegra)                         
                        //gravamos as n9j
                        N9J->(dbgoto(aLstRegra[nCount][1]))
                        
                        If lExistND1 
                            ND1->(dbSetOrder(2))
                        EndIf

                        //verifica o posicionamento
                        if !N9J->(EOF()) .and. N9J->(RECNO()) == aLstRegra[nCount][1]
                            RecLock('N9J',.f.)
                                N9J->N9J_VALOR  := aLstRegra[nCount][3]
                                N9J->N9J_DTATUA := dDataBase
                                N9J->N9J_VLRFIX := aLstRegra[nCount][9] 
                            N9J->(MsUnLock())                            

                            If lExistND1
								For nX := 1 To len(aLstRegra[nCount][15])                                                                
									BeginSql Alias cAliasQry2
										SELECT MAX(ND1_SEQ) SEQ
											FROM %table:ND1% ND1
											WHERE ND1.ND1_FILIAL = %Exp: N9J->N9J_FILIAL%                                             
											AND ND1.ND1_CODCTR   = %Exp: N9J->N9J_CODCTR%
											AND ND1.ND1_ITEMPE   = %Exp: N9J->N9J_ITEMPE%
											AND ND1.ND1_ITEMRF   = %Exp: N9J->N9J_ITEMRF%
											AND ND1.ND1_SEQCP    = %Exp: N9J->N9J_SEQCP %
											AND ND1.ND1_SEQPF    = %Exp: N9J->N9J_SEQPF %
											AND ND1.ND1_SEQN9J   = %Exp: N9J->N9J_SEQ%
											AND ND1.%notDel%   
									EndSQL                                
                                
									If (cAliasQry2)->(!Eof())
										cSeqND1 := SOMA1((cAliasQry2)->SEQ)
									Else
										cSeqND1 := strzero(1, TamSX3( "ND1_SEQ" )[1] ) 
									EndIf
                                
									RecLock('ND1',.T.)
										ND1->ND1_FILIAL := N9J->N9J_FILIAL
										ND1->ND1_CODCTR := N9J->N9J_CODCTR
										ND1->ND1_ITEMPE := N9J->N9J_ITEMPE
										ND1->ND1_ITEMRF := N9J->N9J_ITEMRF
										ND1->ND1_SEQCP  := N9J->N9J_SEQCP 
										ND1->ND1_SEQPF  := N9J->N9J_SEQPF 
										ND1->ND1_SEQN9J := N9J->N9J_SEQ
										ND1->ND1_SEQ    := cSeqND1
										ND1->ND1_ITEMFX := aLstRegra[nCount][15][nX][01]
										ND1->ND1_MOEDA  := aLstRegra[nCount][15][nX][02] //[02]Moeda
										ND1->ND1_VLTAXA := aLstRegra[nCount][15][nX][03] //[03]taxa
										ND1->ND1_DTTAX  := aLstRegra[nCount][15][nX][04] //[04]dt COTACAO
										ND1->ND1_VLUFIX := aLstRegra[nCount][15][nX][05] //[05]vlr fixado
										ND1->ND1_VLUFAT := aLstRegra[nCount][15][nX][06] //[06]vlr faturado										
										ND1->ND1_QTDE   := aLstRegra[nCount][15][nX][08] //[08]qtde
										ND1->ND1_DTVCTO := aLstRegra[nCount][15][nX][09] //[09]dt vencimento                                            
										ND1->ND1_TIPPRC := aLstRegra[nCount][15][nX][11] //[11]Tipo de preço (1 - Fix, 2 - Ctr, 3 - Idx)
									ND1->(MsUnLock())                                   

									(cAliasQry2)->(dbCloseArea())                                
								Next nX
                           EndIf 

						   //monta o array de update da NN7
                            if (nPos :=  aScan(aNN7Updat, { |x| Alltrim(x[1]) == N9J->N9J_SEQPF  }) ) > 0
                                aNN7Updat[nPos][2] += N9J->N9J_VALOR 
                            else	
                                aAdd(aNN7Updat, {N9J->N9J_SEQPF, N9J->N9J_VALOR, aLstRegra[nCount][7], aLstRegra[nCount][8]  } )
                            endif
                        //verifica a necessidade de criar um transaction	
                        endif
                        
                    next nCount
                    
                    //devemos atualizar a regra fiscal
                    RecLock('N9A',.f.)
                        N9A->N9A_TIPMER := NJR->NJR_TIPMER
                        N9A->N9A_VLR2MO := aVlrRegFis[1] / N9A->N9A_QUANT //valor unitário da fixação
                        N9A->N9A_VLT2MO := aVlrRegFis[1] //valor total fixação                        
                        N9A->N9A_VLUFPR := aVlrRegFis[2] / N9A->N9A_QUANT //valor unitario faturamento
                        N9A->N9A_VLTFPR := aVlrRegFis[2]  //valor total faturamento                        
                        if nMoedaCtr > 1 .and. cTipoMerc == "1" //somente contratos em outra moeda tem cotação
                            N9A->N9A_VLRTAX := aVlrRegFis[3] / N9A->N9A_QUANT //cotação média do contrato   
                        else
                            N9A->N9A_VLRTAX := 0 //reset
                        endif		
                    N9A->(MsUnLock())											    
				    				    
		    		N9A->(dbskip())		    		
		    	enddo		    	
		    endif
		    
		    NNY->(dbskip())		    
    	enddo    	
    endif
    
    //Refaz as NN7
	DbSelectArea("NN7")	
	NN7->(dbSetOrder(1))
	for nCount := 1 to len(aNN7Updat)
		if NN7->(dbSeek(cFilCtr+cContrato+aNN7Updat[nCount][1])) 	    	 
             //verifica o valor já consumido
	    	 nVlrConsu := NN7->NN7_VALOR - NN7->NN7_VLSALD
	    	 RecLock('NN7',.f.)    
	    	    if nMoedaCtr > 1 .and. cTipoMerc == "1" //somente contratos em outra moeda tem cotação        
	    	    	NN7->NN7_VLRTAX := aNN7Updat[nCount][4]
	    	    else
	    	    	NN7->NN7_VLRTAX := 0
               	endif
               	NN7->NN7_VALOR  := aNN7Updat[nCount][2]
                nTotValor       += aNN7Updat[nCount][2]
                If NN7->NN7_TIPEVE == '2'
                    NN7->NN7_VLSALD := NN7->NN7_VALOR - nVlrConsu
                    if NN7->NN7_VLSALD < 0
                        NN7->NN7_VLSALD := 0
                    endif
                Endif
	    	 	if NN7->NN7_STSTIT <> "1" //diferente de incluir
	    	 		NN7->NN7_STSTIT := "2" //atualizar 
	    	 	endif
	    	 		
	    	 NN7->(MsUnLock())
	    endif	
	next nCount

    NJR->(dbSetOrder(1))
    if NJR->(dbSeek(cFilCtr+cContrato)) //temos cadências
        RecLock("NJR", .F.)
            NJR->NJR_VLRTOT := nTotValor
        NJR->(MsUnLock())
    EndIf

    /*Quando não for faturamento */
    If !ISINCALLSTACK("OGA250C")        
        /*calcula preço demonstrativo e despesas*/
        OGX070CDEM(cFilCtr, cContrato, .T. /*CALC GFE*/)	
    EndIf

    RestArea(aAreaN9A)
    RestArea(aAreaNN7)
    RestArea(aAreaN9J)
    RestArea(aAreaNJR)
	
return .t.

/** {Protheus.doc} fCargaDados
Carrega os dados do modelo no array _aDados 
@Param:    NIL
@REturn     lRet  -> Indica status de processamento
@author:    Marcelo Ferrari
@since:     19/03/2017
@Uso:       OGCX018/OGA290
*/
Static Function fCargaDados(oModel)
    Local aArea     := GetArea()
    Local oModelNJR := oModel:GetModel( "NJRUNICO" )
    Local oModelNNY := oModel:GetModel( "NNYUNICO" )
    Local oModelN9A := oModel:GetModel( "N9AUNICO" )
    Local lRet      := .T.
    Local nNNY      := 0
    Local nN9A      := 0
    Local nTotValor := 0
    Local nQtdUsTot := 0

    _aDados    := {} //reset variavel de dados
    
    For nNNY := 1 to oModelNNY:Length()
        
        oModelNNY:GoLine( nNNY )
        
        if !(oModelNNY:isDeleted())
        	        	
	        For nN9A := 1 to oModelN9A:Length()
	            oModelN9A:GoLine( nN9A )
	            
	            If !oModelN9A:isDeleted()
		            nTotValor += fAddDados(oModel, @nQtdUsTot)
		        EndIf
	        Next nN9A
        
        EndIf
        
    Next nNNY

	//total do contrato
    oModelNJR:SetValue('NJR_VLRTOT', nTotValor)

    RestArea(aArea)

Return lRet


/** {Protheus.doc} fAddDados
     Carrega os dados da N84 (Condicao de Pagamento) no array da previsão financeira
@Param:    cFilia -> Filial
            cCodCtr -> Código do contrato 
            @nItem -> (Referência) de nItem que é a sequência da NN7

@REturn     lRet  -> Indica status de processamento
@author:    Marcelo Ferrari
@since:     24/07/2017
@Uso:       OGC290 - Contrato de Venda
*/
Static Function fAddDados(oModel, nQtdUsTot)
    Local oModelNJR  := oModel:GetModel( "NJRUNICO" )
    Local oModelNNY  := oModel:GetModel( "NNYUNICO" )
    Local oModelN9A  := oModel:GetModel( "N9AUNICO" )
    Local oModelN84  := oModel:GetModel( "N84UNICO" )	
    Local oModelN9J  := oModel:GetModel( "N9JUNICO" )
    Local nLine      := 0
    Local cCodCtr    := oModelNJR:GetValue("NJR_CODCTR")
    Local cCodPrvEnt := oModelNNY:GetValue("NNY_ITEM")
    Local cCodRegFis := oModelN9A:GetValue("N9A_SEQPRI")
    Local cFilOrg    := oModelN9A:GetValue("N9A_FILORG")
    Local nMoeda     := oModelNJR:GetValue("NJR_MOEDA")
    Local cTes       := oModelN9A:GetValue("N9A_TES")
    Local cNatuFin   := oModelN9A:GetValue("N9A_NATURE")
    Local cTipoMerc  := oModelNJR:GetValue("NJR_TIPMER")
    Local nMoedaFat  := oModelNJR:GetValue("NJR_MOEDAR") 
    Local nMoedaRec  := oModelNJR:GetValue("NJR_MOEDAF") 
    Local nQtdDiasF  := oModelNJR:GetValue("NJR_DIASR")
    Local nQtdDiasR  := oModelNJR:GetValue("NJR_DIASF")
    Local cUmPrec    := oModelNJR:GetValue("NJR_UMPRC")
    Local cUmProd    := oModelNJR:GetValue("NJR_UM1PRO") 
    Local cCodPro    := oModelNJR:GetValue("NJR_CODPRO")
    Local cCodNgc    := oModelNJR:GetValue("NJR_CODNGC")
    Local cVersao    := oModelNJR:GetValue("NJR_VERSAO") 
    Local cTipoCli   := oModelN9A:GetValue("N9A_TIPCLI")
    Local cOperMORec := oModelNJR:GetValue("NJR_OPERAC")
    Local nMoedaBase := 1
    Local cCodClient := ""
    Local cCodLoja   := ""  
	Local cNatureza  := ""
    Local aLstRegra  := {}
    Local nSaldoCons := 0
    Local nTotRegra  := 0
    Local nCountPag  := 0
    Local nQtdAplic  := 0
    Local nQtdEvtTot := 0
	Local cCodBco    := ""
	Local cCodAge    := ""
	Local cDiVAge    := ""
	Local cCodCta    := ""
	Local cDiVCta    := ""	
	Local nScan      := 0 
	Local aRetSM0    := {}    

    Default nQtdUsTot := 0 //qtd de todas as cadencias
    
    //Quando a referência é pagamento, deve considerar a moeda de pagamento.
    If cOperMORec == "2"
        nMoedaBase := nMoedaRec
        nDiasBase  := nQtdDiasR
    Else    
        nMoedaBase := nMoedaFat
        nDiasBase  := nQtdDiasF
    EndIf

    DbSelectArea("NJ0")
	NJ0->(DbSetOrder(1))
	If NJ0->(DbSeek(xFilial("NJ0")+oModelN9A:GetValue("N9A_CODENT")+oModelN9A:GetValue("N9A_LOJENT")))
		if oModelNJR:GetValue("NJR_TIPO") == "1" //Compras - fornecedor
			cCodClient     := NJ0->NJ0_CODFOR
			cCodLoja       := NJ0->NJ0_LOJFOR				
		else //vendas - cliente
			cCodClient     := NJ0->NJ0_CODCLI
			cCodLoja       := NJ0->NJ0_LOJCLI				
		endif

		aRetSM0 := FWLoadSM0()
		nScan := aScan(aRetSM0, { |x| Alltrim(x[2]) == cFilOrg  })
		If nScan > 0

			cAliasQry := GetNextAlias()
			cQry :=    " SELECT NJ0.NJ0_CODENT "
			cQry +=    " FROM " + RetSQLName("NJ0") + " NJ0 "
			cQry +=    " WHERE NJ0.NJ0_FILIAL    = '" + FwXFilial("NJ0") + "' "
			cQry +=    "   AND NJ0.NJ0_CGC       = '" + aRetSM0[nScan][18] + "'"
			cQry +=    "   AND NJ0.D_E_L_E_T_    = ' ' "
			cQry := ChangeQuery( cQry ) 
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
			(cAliasQry)->( dbGoTop() )      
			If (cAliasQry)->( !Eof() )        
				dbSelectArea("NN0")
				dbSetOrder(1) //NN0_FILIAL+NN0_CODENT+NN0_ITEM
				If dbSeek(FwXFilial("NN0")+(cAliasQry)->NJ0_CODENT)
					cCodBco := NN0->NN0_CODBCO
					cCodAge := NN0->NN0_CODAGE
					cDiVAge := NN0->NN0_DVAGE
					cCodCta := NN0->NN0_CODCTA
					cDiVCta := NN0->NN0_DVCTA
				EndIf
			EndIf
			(cAliasQry)->(dbCloseArea())

		EndIf
	EndIf	

	
	cNatureza := oModelN9A:GetValue("N9A_NATURE")	

    For nLine := 1 to oModelN84:Length()
        
        oModelN84:GoLine(nLine)
        
        if !(oModelN84:isDeleted())
	    
	        If empty(_cMsgErro)
	        	//reset
	        	nQtdVincul := 0
	        	//nQtdEvento := 0
	        	nVlrEvento := 0
	        	 
	        	//Calcula a data de vencimento
	        	dDtVenc := fGetVecto( oModel )
	        	
		        If empty(_cMsgErro)
		            
		            //verificar se existe quantidade vinculada
		            oModelN9J:GoLine(1) //seleciona a primeira linha
	                if oModelN9J:SeekLine( { {"N9J_ITEMPE", cCodPrvEnt  }, {"N9J_ITEMRF", cCodRegFis } , {"N9J_SEQCP", oModelN84:GetValue("N84_SEQUEN") }  } )
	                	nQtdVincul := oModelN9J:GetValue("N9J_QTDE") - oModelN9J:GetValue("N9J_SLDQTD")	//com quantidade por evento
	                	//nQtdEvento := oModelN9J:GetValue("N9J_QTDEVT")
	                	nVlrEvento := oModelN9J:GetValue("N9J_VLFCON")
	                	nQtdEvtTot += oModelN9J:GetValue("N9J_QTDEVT")
	                endif

		            //Calcula o valor da parcela
		            aVlrDados := fGetQtdPag(oModel, @nQtdAplic, nQtdVincul ) //Valor/Quantidade/Porcentagem
		            
		            nSaldoCons += aVlrDados[4]	           
		            
		            //arrendonda o valor da parcela
		         	If empty(_cMsgErro)
	        	            		                
		                //adiciona dados ao array de quebra
		                OGX018STRG(@aLstRegra, oModelN84:GetValue("N84_SEQUEN"), dDtVenc, aVlrDados[2],  aVlrDados[3], nQtdVincul, nMoeda, 0/*nQtdEvento*/, nVlrEvento)
		                
		            EndIf
		           
		         Endif
	        Endif
	        
        endif
           
    Next nLine

    //verifica se existe diferença entre as condições de pagamento
    if nSaldoCons > 0
    	nCountPag := len(aLstRegra)
    	//busca os array de forma invertida
    	while nSaldoCons > 0 .and. nCountPag > 0
    		nLstSaldo := aLstRegra[nCountPag][5] - aLstRegra[nCountPag][6]
    		if nLstSaldo > 0 //tem saldo para abater
	    	   //abate saldo
	    	   if nSaldoCons > nLstSaldo  //não tem quantidade para atender o lance
	    	   	  nSaldoCons := nSaldoCons - nLstSaldo
	    	   else
	    	   	  nLstSaldo  := nSaldoCons
	    	   	  nSaldoCons := 0
	    	   endif	
	    	   
	    	   //recalcula valor e porcentagem
	    	   aLstRegra[nCountPag][5] := aLstRegra[nCountPag][5]  - nLstSaldo	//corrige a quantidade
	    	  	    	    		
    		endif	
    		
    		//diminui o contador
	    	nCountPag -= 1 	  
    	enddo
    endif

    if nSaldoCons > 0
       _cMsgErro +=  "Existe saldo já emitido não aplicado a previsão de pagamento."
    endif

    //APLICA OS IMPOSTOS NAS PREVISÕES FINANCEIRAS
    aVlrRegFis := OGX018UVLR(@aLstRegra, FwXFilial("NJR"), cCodCtr, cCodPrvEnt, cCodRegFis, cCodClient, cCodLoja, cTes, cNatuFin, cFilOrg, cCodNgc, cVersao, cTipoMerc, nMoedaBase, nDiasBase, cUmPrec, cUmProd, cCodPro, nMoeda, cTipoCli, nQtdEvtTot, , @nQtdUsTot)
   
    //seta os novos valores na regra fical
    oModelN9A:SetValue("N9A_VLR2MO", aVlrRegFis[1] / oModelN9A:GetValue("N9A_QUANT")) //valor unitário da fixação
    oModelN9A:SetValue("N9A_VLT2MO", aVlrRegFis[1]) //valor total fixação    
    oModelN9A:SetValue("N9A_VLUFPR", aVlrRegFis[2] / oModelN9A:GetValue("N9A_QUANT")) //valor unitario faturamento
    oModelN9A:SetValue("N9A_VLTFPR", aVlrRegFis[2] ) //valor total faturamento    
  
    if oModelNJR:GetValue("NJR_MOEDA") > 1 .and. oModelNJR:GetValue("NJR_TIPMER") == "1" // 
    	oModelN9A:SetValue("N9A_VLRTAX", aVlrRegFis[3] / oModelN9A:GetValue("N9A_QUANT")) //cotação média do contrato   
    else
    	oModelN9A:SetValue("N9A_VLRTAX", 0)
    endif
   
    //grava os dados corretamente
    //adiciona dados ao array de quebra
    for nCountPag := 1 to len(aLstRegra)

    	//só pega a turma de quantidade maior que 0
    	if aLstRegra[nCountPag][5] > 0
    		aAdd(_aDados, { FwXFilial("NN7"), ;         //[01]
                            cCodCtr, ;                  //[02]
                            cCodPrvEnt, ;               //[03]
                            cCodRegFis, ;               //[04]
                            aLstRegra[nCountPag][1], ;  //[05]
                            aLstRegra[nCountPag][2], ;  //[06]
                            aLstRegra[nCountPag][3], ;  //[07]
                            cFilOrg, ;                  //[08]
                            aLstRegra[nCountPag][7], ;  //[09]
                            aLstRegra[nCountPag][8], ;  //[10]
                            dDataBase,  ;               //[11]
                            aLstRegra[nCountPag][4], ;  //[12]
                            aLstRegra[nCountPag][5], ;  //[13]
                            aLstRegra[nCountPag][6], ;  //[14] qtd vinculada
                            aLstRegra[nCountPag][9], ;  //[15]
                            aLstRegra[nCountPag][11], ; //[16] qtd evento
                            aLstRegra[nCountPag][12], ; //[17]
                            aLstRegra[nCountPag][13], ; //[18]
                            cNatureza,;                 //[19]
                            aLstRegra[nCountPag][15] ,; //[20]
                            cCodBco					 ,; //[21]
                            cCodAge					 ,; //[22]
                            cDiVAge					 ,; //[23]
                            cCodCta					 ,; //[24]
                            cDiVCta					 }) //[25]
		endif
    	
    	//acumula o valor para retornar e realizar o saldo
		nTotRegra += aLstRegra[nCountPag][3]     
		           
    next nCountPag

Return nTotRegra


/*{Protheus.doc} OGX018UVLR
Busca o preço financeiro e de faturamento para parcelas de entrega
@author jean.schulze
@since 29/06/2018
@version 1.0
@return ${return}, ${return_description}
@param aLstRegras, array, descricao
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
Function OGX018UVLR(aLstRegras, cFilCtr, cContrato, cCodCad, cCodRegFis, cCodClient, cCodLoja, cTes, cNatuFin, cFilFat, cCodNgc, cVersao, cTipoMerc, nMoedaFat, nDias, cUmPrec, cUmProd, cCodPro, nMoedaCtr, cTipoCli, nQtdEvento, lFardoFat, nQtdUsTot)
	Local aAreaN9A   := GetArea("N9A")
	Local aAreaNNY   := GetArea("NNY")
	Local aAreaNJR   := GetArea("NJR")
	Local nX         := 1
	Local nY         := 1	
	Local nVlrFix    := 0
	Local nVlrFat    := 0	
	Local nCotacao   := 0
	Local nTotalN9A  := 0
	Local nQtdTotal  := 0//quantidade
	Local nVlrFatTot := 0   	
	Local nVlrFixTot := 0
	Local cFiltroExt := ""	
	Local nVlrBsFix  := 0
    Local nQtdConsFx := 0
	Local nDecCompon := TamSx3('N7C_VLRCOM')[2] //casa decimais componentes    
	Local aFixacoes  := {}
    Local aValPrev   := {}
    Local aValFix    := {}    
    Local aFixUsada  := {}
	
    Default lFardoFat := .F.
	Default nQtdUsTot := 0
    
	//verifica o comoditie
	if AGRTPALGOD(cCodPro)
		
		//valor das cotações
		for nX := 1 to Len(aLstRegras)
			if aLstRegras[nX][5] > 0
				//grava as cotações conforme as previsões financeiras
				aRetorno   := OGAX721MOE(1, nMoedaCtr, cTipoMerc, nDias, nMoedaFat, aLstRegras[nX][2] )
				
			 	aLstRegras[nX][7]  := aRetorno[2] //moeda  
				aLstRegras[nX][8]  := aRetorno[1]  //taxa
				aLstRegras[nX][10] := aRetorno[3] //data da cotação
				
				//média da cotação
				//nCotacao  += aRetorno[1] * aLstRegras[nX][5]  
				nTotalN9A += aLstRegras[nX][5] 
				
				//verifica os fardos emitidos?
                /*
				if aLstRegras[nX][11] > 0 //tem emissão por evento
					cFiltroExt := "DXI_FATURA < '2'"
				endif
                */
			endif
		next nX  	
		
				//Busca somente os fardos faturados
		If lFardoFat 
			cFiltroExt := "DXI_FATURA = '2'"
			//utiliza a média ponderada da cotação
			aFardos := OGX050CTRF("02", cFilCtr, cContrato, cCodCad, cCodRegFis, cFiltroExt ) //pega todos os fardos take-ups
			cFiltroExt := ""
		Else
			//utiliza a média ponderada da cotação
		 	aFardos := OGX050CTRF("02", cFilCtr, cContrato, cCodCad, cCodRegFis, cFiltroExt ) //pega todos os fardos take-ups
		Endif


		if len(aFardos) > 0 //temos fardos vinculados, podemos ter um preço previsto
									
			//busca o valor das quantidades					            
			aRetorno := OGX050(cFilCtr, cContrato, aFardos , cTes, cNatuFin, cCodCad, cCodRegFis, /*cFilRoman*/, /*cCodRoman*/, /*cItemRom*/,  /*lUpdtRegra*/, cTipoCli, cCodClient, cCodLoja, 0 /*nPrecoBase*/, "R", (nCotacao / nTotalN9A) )
				
			if empty(aRetorno[2])//não teve erros						
				//monta a média ponderada
				for nX := 1 to len(aRetorno[1])	
					nQtdTotal  += aRetorno[1][nX][3] //quantidade
					nVlrFatTot += aRetorno[1][nX][2] * aRetorno[1][nX][3] //quantidade					
					nVlrFixTot += aRetorno[1][nX][2] * aRetorno[1][nX][3] //quantidade					                    
                    nCotacao   += aRetorno[5] * aRetorno[1][nX][3]
				next nX								                
			endif						
									
			//completa com média final dos fardos...
			if nQtdTotal <  nTotalN9A
				nVlrFatTot := (nVlrFatTot / nQtdTotal) * ( nTotalN9A) 				
				nVlrFixTot := (nVlrFixTot / nQtdTotal) * ( nTotalN9A) 								
			endif
				
			//quebra por previsão de entrega
			nVlrFat   += nVlrFatTot			
			nVlrFix   += nVlrFixTot			
			
			//variavel de controle de saldo
			nUtilizar := nTotalN9A
			
			//atualiza as previsões financeiras
			for nX := 1 to Len(aLstRegras)
				if aLstRegras[nX][5] > 0
					if nUtilizar = aLstRegras[nX][5] // é o ultimo 						
						aLstRegras[nX][3]  := nVlrFatTot
                        aLstRegras[nX][9]  := nVlrFixTot
					else
						aLstRegras[nX][3]  := Round((nVlrFat / nTotalN9A) * aLstRegras[nX][5] ,TamSx3("NN7_VALOR")[2])
						aLstRegras[nX][9]  := Round((nVlrFix / nTotalN9A) * aLstRegras[nX][5] ,TamSx3("N9A_VLT2MO")[2])
						
						//control
						nUtilizar  -= aLstRegras[nX][5]  						
						nVlrFatTot -= aLstRegras[nX][3]
                        nVlrFixTot -= aLstRegras[nX][9]
					endif					
				endif
			next nX  
						
		else
			//precifica via granel 
			for nX := 1 to Len(aLstRegras)
				if aLstRegras[nX][5] > 0
					//retorna os valores 
					aVlrBase := OGAX721FAT(cFilCtr ,cContrato, cCodCad, cCodRegFis, 0 /*DXI RECNO*/, aLstRegras[nX][5], 0 /*nPrecoBase*/, cCodClient, cCodLoja, "R", @nQtdConsFx, nQtdUsTot, , @aFixUsada)	
					
					//add quantidade usada					
                    nQtdUsTot += aLstRegras[nX][5]
						
					//busca os impostos
					aValPrev := OGX060PREV(aVlrBase[1][1], aLstRegras[nX][2], "" , aLstRegras[nX][5],cFilCtr, cContrato, cCodCad, cCodRegFis, cCodClient, cCodLoja, cTes, cNatuFin, cFilFat, cCodNgc, cVersao, cTipoMerc, nMoedaFat, nDias, cUmPrec, cUmProd, cCodPro, nMoedaCtr, cTipoCli )
											
					aLstRegras[nX][3]  := aValPrev[1] * aLstRegras[nX][5] //atualiza os valores
					aLstRegras[nX][7]  := aValPrev[4] //moeda  
					aLstRegras[nX][8]  := aValPrev[3] //taxa
					aLstRegras[nX][9]  := aVlrBase[1][1] * aLstRegras[nX][5]
					aLstRegras[nX][10] := aValPrev[2]  //data da cotação					
							
					//monta a média das fixações/total da regra faturada/cotação
                    nVlrBsFix :=  Round(OGX700UMVL(aVlrBase[1][1],cUmPrec,cUmProd,cCodPro),nDecCompon) 
					nVlrFix   += nVlrBsFix * aLstRegras[nX][5]
					nVlrFat   += aValPrev[1] * aLstRegras[nX][5] 					
					nCotacao  += aValPrev[3] * aLstRegras[nX][5]  					
				endif		
			next nX
		endif 		
	else //granel		
		//quebra por previsão financeira
		for nX := 1 to Len(aLstRegras)
			if aLstRegras[nX][5] > 0 
				//retorna os valores 
				aVlrBase := OGAX721FAT(cFilCtr ,cContrato, cCodCad, cCodRegFis, 0 /*DXI RECNO*/, aLstRegras[nX][5], 0 /*nPrecoBase*/, cCodClient, cCodLoja, "R", @nQtdConsFx, nQtdUsTot, , @aFixUsada )	
				
				//add quantidade usada				
                nQtdUsTot += aLstRegras[nX][5] 
				
				//verifica se o valor da fixação deve ser alterado, pois temos vinculações por evento
				nValorBase := aVlrBase[1][1]

				//mensagem apresentada caso o valor base nao seja calculado devido falta de indice.
				If nValorBase == 0					
					If _nOperation != MODEL_OPERATION_INSERT 
                        _cMsgErro += STR0005 + STR0006 + AllTrim(posicione("NNY",1,cFilCtr+cContrato+cCodCad,"NNY_IDXCTF")) + " " + STR0007 + CHR(13) + CHR(10) //"Não foi possível calcular o valor Base ! Verifique em sua negociação se o indice XXX está atualizado corretamente.					
                    EndIf
				EndIf	
				
				//busca os impostos
				aValPrev := OGX060PREV(nValorBase, aLstRegras[nX][2], "" , aLstRegras[nX][5], cFilCtr, cContrato, cCodCad, cCodRegFis, cCodClient, cCodLoja, cTes, cNatuFin, cFilFat, cCodNgc, cVersao, cTipoMerc, nMoedaFat, nDias, cUmPrec, cUmProd, cCodPro, nMoedaCtr, cTipoCli )
										
				aLstRegras[nX][3]  := aValPrev[1] * aLstRegras[nX][5] //valor faturamento
				aLstRegras[nX][7]  := aValPrev[4] //moeda  
				aLstRegras[nX][8]  := aValPrev[3] //taxa
				aLstRegras[nX][9]  := aVlrBase[1][1] * aLstRegras[nX][5] //valor fixado
				aLstRegras[nX][10] := aValPrev[2] //data da cotação
						
				//monta a média das fixações/total da regra faturada/cotação
				nVlrBsFix := Round(OGX700UMVL(aVlrBase[1][1],cUmPrec,cUmProd,cCodPro),nDecCompon) 
				nVlrFix   += nVlrBsFix         * aLstRegras[nX][5]                
				nVlrFat   += aValPrev[1]    * aLstRegras[nX][5] 				
				nCotacao  += aValPrev[3]    * aLstRegras[nX][5]  								
                
                aFixacoes := {}
                
                For nY := 1 To Len(aVlrBase[1,4] )
            
                    aValFix := OGX060PREV(aVlrBase[1,4,nY,2] , aLstRegras[nX][2], "" , aVlrBase[1,4,nY, 3], cFilCtr, cContrato, cCodCad, cCodRegFis, cCodClient, cCodLoja, cTes, cNatuFin, cFilFat, cCodNgc, cVersao, cTipoMerc, nMoedaFat, nDias, cUmPrec, cUmProd, cCodPro, nMoedaCtr, cTipoCli )
            
                    nVlrBsFix  := Round(OGX700UMVL(aVlrBase[1,4,nY, 2],cUmPrec,cUmProd,cCodPro),nDecCompon) 
                    nVlrFixFix := nVlrBsFix 
                    nVlrFatFix := aValFix[1]                     

                    aAdd(aFixacoes, {aVlrBase[1,4,nY,4], ; //[01]Item fx
                                     aValFix[4],  ;        //[02]moeda
                                     aValFix[3],  ;        //[03]taxa
                                     aValFix[2],  ;        //[04]dt COTACAO
                                     nVlrFixFix,  ;        //[05]vlr fixado
                                     nVlrFatFix,  ;        //[06]vlr faturado
                                     0,           ;        //[07]vlr financeiro                                     
                                     aVlrBase[1,4,nY,3],;  //[08]qtde
                                     aLstRegras[nX][2],;   //[09]dt vencimento
                                     {}, ;                 //[10]Array com os impostos - NÃO UTILIZADO MAIS
                                     aVlrBase[1,4,nY,1],}) //[11]Tipo Preço (1 - fixo, 2 - base, 3 - idx)

                Next nY
        
                aLstRegras[nX][15] := aFixacoes

			endif			
		next nX	
		
	endif
	
	//rest area
	RestArea(aAreaN9A)
	RestArea(aAreaNNY)
	RestArea(aAreaNJR)
	
return {nVlrFix, nVlrFat, nCotacao} 

/*{Protheus.doc} OGX018STRG
Padroniza o valor do array de calculo
@author jean.schulze
@since 29/06/2018
@version 1.0
@return ${return}, ${return_description}
@param aLstRegras, array, descricao
@param cCodSeqCp, characters, descricao
@param dDtVenc, date, descricao
@param nQtdCalc, numeric, descricao
@param nPercCalc, numeric, descricao
@param nQtdVincul, numeric, descricao
@param nMoeda, numeric, descricao
@type function
*/
Function OGX018STRG(aLstRegra, cCodSeqCp, dDtVenc, nQtdCalc, nPercCalc, nQtdVincul, nMoeda, nQtdEvento, nVlrEvento)
	 
     aAdd(aLstRegra, {cCodSeqCp, ;                      //[01]
                     dDtVenc, ;                         //[02]
                     0, ;                               //[03]
                     nPercCalc, ;                       //[04]
                     nQtdCalc, ;                        //[05]
                     nQtdVincul, ;                      //[06]
                     nMoeda /*MoedaCalc*/ , ;           //[07]
                     1/*cotação*/, ;                    //[08]
                     0 /*Valor da Fixação*/,;           //[09]
                     dDataBase /*Data da Cotação*/, ;   //[10]
                     nQtdEvento /*Qtd uso Evento*/, ;   //[11]
                     nVlrEvento /*Vlr Evento*/, ;       //[12]
                     /*ctiponn7 -aregra*/,   ;          //[13]
                     {/*array com impostos*/},;         //[14]
                     {/*array com fixacoes*/}   } )     //[15]

return aLstRegra

/** {Protheus.doc} OGX18GtDtV
Retorna a data de vencimento para uma determinada parcela da previsão financeira conforme parâmetros

@param:     cAlias
@return:    dData -> Data do retorno por referência
            lRet  -> Indica se houve erro no processo. Passar por referência
@author:    Marcelo Ferrari
@since:     24/07/2017
@Uso:       OGC290 - Contrato de Venda
*/	
Function OGX18GtDtV( cAntPos, nNrDias, cTipVct, nDiaMes, dData )
        		
	//mover data pra anterior/posterior
    If cAntPos == "1"  //Anterior
    	dData := DaySub(dData, nNrDias)
    Else
    	dData := DaySum(dData, nNrDias)
    EndIf
    
    //Tipo de Vencimento: Se for tipo 1 não recalcula
    If cTipVct == "2"    //Prox. dia útil
    	dData := DataValida(dData, .T.)    //Verifica data válida no sistema ( [ dData], [ lTipo] ) --> dData
    ElseIf cTipVct == "3"    //xx dia do mês subsequente
        dData   := LastDate( dData )  // dLastDate -> Retorna a Data do ùltimo dia do mes da data passada
        dData   := DaySum(dData, 1)   // Primeiro dia do mês subsequente
        nUltDia := Val(day2Str( LastDate(dData) ))   // day2str -> Retorna o dia do mês em DD
        nMes    := Val(Month2Str( dData )) // String MM  onde dData podera ser uma Data, um valor numérico ou um caracter nuérico
        nAno    := Val(Year2Str(dData))
       
        //O dia informado na regra é maior que 28|29/fev ou maior que 30/abr,jun,set,nov então muda para o ultimo dia do respectivo mês
        If nDiaMes > nUltDia  
            nDiaMes := nUltDia
        EndIf

        //compõe a nova data
        dData := CTOD( StrZero(nDiaMes, 2) + "/" + StrZero(nMes, 2) + "/" + StrZero(nAno, 4) )
    EndIf

    If ValType(dData) <> "D"
    	_cMsgErro += "Não foi possível calcular a data prevista."
    EndIf	

Return dData

/** {Protheus.doc} fGetVecto
Retorna a data de vencimento para uma determinada parcela da previsão financeira conforme parâmetros
@param:     cAlias
@return:    dData -> Data do retorno por referência
            lRet  -> Indica se houve erro no processo. Passar por referência
@author:    Marcelo Ferrari
@since:     24/07/2017
@Uso:       OGC290 - Contrato de Venda
*/	
Static Function fGetVecto( oModel )
	Local oModelN9A := oModel:GetModel( "N9AUNICO" ) 
	Local oModelN84 := oModel:GetModel( "N84UNICO" ) 
	Local oModelNNY := oModel:GetModel( "NNYUNICO" ) 
    Local cAntPos   := oModelN84:GetValue("N84_ANTPOS")
    Local nNrDias   := oModelN84:GetValue("N84_NRDIAS")
    Local cRefCtr   := oModelN84:GetValue("N84_REFCTR")
    Local cRefPrf   := oModelN84:GetValue("N84_REFPRF")
    Local cTipVct   := oModelN84:GetValue("N84_TIPVCT")
    Local nDiaMes   := oModelN84:GetValue("N84_DIAMES")
    Local cData     := ""
    Local cTipoD    := ""
    local dData     := Nil
    
    If Empty(cRefCtr) .and. Empty(cRefPrf)
     	cData := dDatabase 
     	Return dData
    EndIf
    
    //Parâmetro de referência do contrato
    If cRefCtr == "1"     /* Data Faturamento  */
        cTipoD := "Data Faturamento"

    ElseIf cRefCtr == "2"     /* Data Board Load - BL  */
       cTipoD := "Dada do BL"

    ElseIf cRefCtr == "3"         // <-- data do take-up
       cData := fGetDtTkUp(oModelN9A:GetValue("N9A_TAKEUP"))
       cTipoD := "Data Take Up"

    ElseIf cRefCtr == "4"         // <-- data da chegada
    	cTipoD := "Chegada no destino"
    	
    ElseIf cRefCtr == "5"
       cData  := oModelN9A:GetValue("N9A_DATINI")  // <-- data início cadência
       cTipoD := "Data Início da cadência"

    ElseIf cRefCtr == "6"
       cData  := oModelN9A:GetValue("N9A_DATFIM")  // <-- Substituir pela data fim cadência
       cTipoD := "Data final da cadência"

    ElseIf cRefCtr == "7"
       cData := oModelN84:GetValue("N84_DTFIXA")  //utiliza data fixa da cond pagto do contrato
       cTipoD := "Data negociada"

    EndIf
    
    //Se não retornou a data pelo campo REFCTR
    If Empty(cData) //Buscar informações conforme REFPRF
        If cRefPrf == "1"
           cData  := oModelN9A:GetValue("N9A_DATINI")
           cTipoD := "Data Início da cadência"

        ElseIf cRefPrf == "2"
            cData  := oModelN9A:GetValue("N9A_DATFIM")
            cTipoD := "Data final da cadência"

        ElseIf cRefPrf == "3"
            cData  := oModelN9A:GetValue("N9A_DTLTKP")
            cTipoD := "Data Limite do take up"

        ElseIf cRefPrf == "4"
            cData  := oModelNNY:GetValue("NNY_DTLFIX")
            cTipoD := "Data limite da fixação"

        EndIf
    EndIf
    
    If Empty(cData)  //Erro para encontrar a database
        _cMsgErro += "Data base para processamento não encontrada: [" + cTipoD + "]"
        Return dData
    EndIf
 
    If  !(ValType(cData) == "D")
        dData := STOD(cData)
    Else
        dData := cData
    EndIf

    If cRefCtr == "7"  //utiliza data fixa da cond pagto do contrato
	Return dData
    EndIf
    
    dData := OGX18GtDtV( cAntPos, nNrDias, cTipVct, nDiaMes, dData )  
    
Return dData

/** {Protheus.doc} GetValor
Retorna a data de vencimento para uma determinada parcela da previsão financeira conforme parâmetros
@param:     dData -> Data de referência - recebe por referência
            lRet  -> Controlo - Recebe por referência. .T.: Processamento OK

@return:    dData -> Data do retorno por referência
@author:    Marcelo Ferrari
@since:     21/03/2018
@Uso:       OGC290 - Contrato de Venda
*/	
Static Function fGetQtdPag( oModel, nQtdAplic, nQtdVincul)
	Local oModelN9A  := oModel:GetModel( "N9AUNICO" ) 
	Local oModelN84  := oModel:GetModel( "N84UNICO" ) 
	Local oModelNJR  := oModel:GetModel( "NJRUNICO" ) 
    Local nQTdTkpN9A := oModelN9A:GetValue("N9A_QUANT")
    Local cTipVal    := oModelN84:GetValue("N84_TIPVAL")
    Local nQtde      := oModelN84:GetValue("N84_QTDE")
    Local nPct       := oModelN84:GetValue("N84_PCT")
    Local nVlrContr  := oModelNJR:GetValue("NJR_QTDCTR")
    Local nPctRFxCtr := 0
    Local nQtdSobra  := 0
    Local nPerctReg  := 0
    
    If cTipVal = "1"  //Quantidade
        //Quando tipo de valor for 1 então deve converter o valor da parcela em % do contrato
        nPctRFxCtr := nQtde / nVlrContr
        nPerctReg  := nPctRFxCtr * 100
    Elseif cTipVal = "2"     //Percentual
        nPerctReg := nPct  
    EndIf
          
    //monta a quantidade utilizada pela regra
    nQtdReg    := (nPerctReg / 100) * nQTdTkpN9A 
    
    //verifica se a quantidade é maior que os saldos, ajuste de arendondamento
    if nQtdReg > (nQTdTkpN9A - nQtdAplic)
    	nQtdReg := nQTdTkpN9A - nQtdAplic 
    endif
    
    //atualizamos aqui para feixca
    nQtdAplic += nQtdReg
    
    //verifica se a qtd vinculada é maior que a quantidade da nova prev
    if nQtdVincul > nQtdReg
    	
    	//monta a sobre
    	nQtdSobra  := nQtdVincul - nQtdReg 
    	
    	//refaz os calculos com os novos valores 
     	nQtdReg   := nQtdVincul //arruma a quantidade para a quantidade correta.    	
     	nPerctReg := fCalVlrQtd(nQtdReg, nQTdTkpN9A, nPerctReg )
    endif 	

Return {0, nQtdReg, nPerctReg, nQtdSobra}


/*{Protheus.doc} fCalVlrQtd
Gera os valores conforme quantidade
@author jean.schulze
@since 05/06/2018
@version 1.0
@return ${return}, ${return_description}
@param nQtdParcel, numeric, descricao
@param nQtdTotal, numeric, descricao
@param nPerctReg, numeric, descricao
@type function
*/
Static Function fCalVlrQtd(nQtdParcel, nQtdTotal, nPerctReg )
    	
    nPctCtr    := nQtdParcel / nQtdTotal
    nPerctReg  := nPctCtr * 100
    
return nPerctReg

/*{Protheus.doc} fGravaPrev
   Adiciona nova parcela no modelo ou na tabela 
@type function
@param  oModelNN7 - Recebe o submodelo da NN7 para inclusão dos dados
        _aDados - Array contendo os dados que serão gravados
@Return Boolean
@author Marcelo Ferrari
@since 19/03/2018
@version undefined
*/
Static Function fGravaPrev(oModel)
    Local nLinNN7
    Local nDelNN7
    Local nCountN9J  := 1
    Local oModelNJR  := oModel:GetModel( "NJRUNICO" ) 
    Local oModelN9J  := oModel:GetModel( "N9JUNICO" ) 
    Local oModelND1  := oModel:GetModel( "ND1UNICO" )     
    Local oModelNN7  := oModel:GetModel( "NN7UNICO" )
    Local cTipoMerc  := oModelNJR:GetValue("NJR_TIPMER")    
	Local nIt 		 := 0
    Local nQtdSeq    := 0
    Local cSeqUsada  := ""
    Local cNN7_ITEM  := ""
    Local nX         := 0 
    Local nY         := 0    
    Local nQtdVinc   := 0   
    Local lExistND1  := TableInDic("ND1")
	
	Local aFieldsSub := oModelNN7:GetStruct():GetFields() // Estrutura de campos do submodelo
    Local aFieldsN9J := oModelN9J:GetStruct():GetFields()
    Local nItemN9J   := 0

	//Habilita a inclusão de linhas
	oModelNN7:SetNoInsertLine(.F.)
    oModelNN7:SetNoDeleteLine(.F.)
  
	//Limpa os valores dos campos para receber novos dados
	For nLinNN7 := 1 To oModelNN7:Length()
		oModelNN7:GoLine(nLinNN7)
        //Se a linha estiver deletada
        If oModelNN7:IsDeleted()
            //ativo ela novamente
            oModelNN7:UnDeleteLine()
        EndIf

        If oModelNN7:GetValue("NN7_TIPEVE") == '1' //EVENTO
            cSeqUsada += oModelNN7:GetValue("NN7_ITEM") + "|"
            loop
        EndIf
		For nIt := 1 to Len(aFieldsSub)
			// Condição adicionada devido a falha do metodo ClearField em limpar campos do tipo BT - Botão, o qual ocasiona erro ao model
			If "NN7_STSLEG" $ aFieldsSub[nIt][3]
				oModelNN7:LoadValue("NN7_STSLEG", "BR_VERDE") // Valor padrão da legenda
			ElseIf !(aFieldsSub[nIt][3] $ "NN7_PARCEL|NN7_ITEM|NN7_VLTEMI|NN7_VLTNCO|NN7_VLRAVI|NN7_VLDEVL|NN7_TIPEVE" )
				oModelNN7:ClearField( aFieldsSub[nIt][3] )
			EndIf
		Next nIt
	Next nLinNN7  
	
	//Vou para a linha
	oModelNN7:GoLine(1) 
    
    nLinNN7 := 0
    
	If Len(_aDados) > 0
        oModelN9J:DelAllLine()
		For nX := 1 To Len(_aDados)
            nLinNN7++

			cTipo := "1" //*1=Previsao			
			
			//verifico se existe outra linhas com as regras de agrupamento
			If !oModelNN7:SeekLine( { {"NN7_DTVENC", _aDados[nX][6]  }, {"NN7_FILORG", _aDados[nX][8] }, {"NN7_TIPEVE", "2"} , {"NN7_TIPO", cTipo} } )                
                
   				/* Verifica para não criar uma sequencia onde já exista um Evento */
                cNN7_ITEM := StrZero(nX, 3)
                While cNN7_ITEM $ cSeqUsada
                    cNN7_ITEM := soma1(cNN7_ITEM)
                    nLinNN7   := val(cNN7_ITEM)
                EndDo                    

                //Se o numero da linha de prev. for maior do que o total de linhas no grid.
				If nLinNN7 > oModelNN7:Length()	
					//adiciono uma nova linha		       
					oModelNN7:AddLine()			

					//atualizo os campos sequenciais
					oModelNN7:SetValue("NN7_ITEM",   StrZero(oModelNN7:Length(), 3))
					oModelNN7:SetValue("NN7_PARCEL", Soma1(alltrim(StrZero(oModelNN7:Length()-1,TamSX3("NN7_PARCEL")[1]))))									                
                Endif
				
                //defino a linha que está na grid                
                oModelNN7:GoLine(nLinNN7)								

                If _aDados[nX][16] > 0 //qtd evento
                    nQtdVinc := _aDados[nX][16]
                Else
                    nQtdVinc := _aDados[nX][14] //vinculada
                EndIf
                
                If cTipoMerc == "1" .and. (_aDados[nX][13] -  nQtdVinc) == 0
                    _aDados[nX][9] := 1
                EndIF
                
				oModelNN7:SetValue("NN7_ITEM",   StrZero(nLinNN7,TamSX3("NN7_ITEM")[1]))
                oModelNN7:SetValue("NN7_PARCEL", StrZero(nLinNN7,TamSX3("NN7_PARCEL")[1]))	
                oModelNN7:SetValue("NN7_DTVENC", _aDados[nX][6] )               
				oModelNN7:SetValue("NN7_FILORG", _aDados[nX][8] )             				
				oModelNN7:SetValue("NN7_QTDE",   _aDados[nX][13] -  nQtdVinc )
				oModelNN7:SetValue("NN7_SLDQTD", _aDados[nX][13] -  nQtdVinc  )
				oModelNN7:SetValue("NN7_STSTIT", "1" ) //incluir
				oModelNN7:SetValue("NN7_TIPO"  , cTipo )  //previsao
				oModelNN7:SetValue("NN7_MOEDA",  _aDados[nX][9])
				oModelNN7:SetValue("NN7_VALOR" , _aDados[nX][7])
				oModelNN7:SetValue("NN7_VLSALD", _aDados[nX][7] - oModelNN7:GetValue("NN7_VLTEMI") )				
				oModelNN7:SetValue("NN7_TIPEVE", "2" ) //tipo 2 - não é evento
				oModelNN7:SetValue("NN7_NATURE", _aDados[nX][19] )
				oModelNN7:SetValue("NN7_CODBCO", _aDados[nX][21] )
				oModelNN7:SetValue("NN7_CODAGE", _aDados[nX][22] )
				oModelNN7:SetValue("NN7_DVAGE" , _aDados[nX][23] )
				oModelNN7:SetValue("NN7_CODCTA", _aDados[nX][24] )
				oModelNN7:SetValue("NN7_DVCTA" , _aDados[nX][25] )
				If oModelNN7:HasField("NN7_DESMOE")
                    oModelNN7:SetValue("NN7_DESMOE",  Iif( .NOT. Empty(_aDados[nX][9]), AgrMvSimb(_aDados[nX][9]), ''))
                EndIf
						
				If oModelNJR:GetValue("NJR_MOEDA") > 1 .and. oModelNJR:GetValue("NJR_TIPMER") == "1" // 
						oModelNN7:SetValue("NN7_VLRTAX", _aDados[nX][10])
				Else
						oModelNN7:SetValue("NN7_VLRTAX", 0)
				EndIf 
			Else
				//Se ele acha uma linha igual a condição, ele soma os valores.				
                oModelNN7:SetValue("NN7_MOEDA",  _aDados[nX][9] )
				oModelNN7:SetValue("NN7_DTVENC", _aDados[nX][6] ) 
				oModelNN7:SetValue("NN7_VALOR" , oModelNN7:GetValue("NN7_VALOR")  + _aDados[nX][7] )
				//oModelNN7:SetValue("NN7_VLSALD", oModelNN7:GetValue("NN7_VLSALD") + _aDados[nX][7] ) //tem trigger que adiciona valor
				oModelNN7:SetValue("NN7_QTDE"  , oModelNN7:GetValue("NN7_QTDE")   + _aDados[nX][13] - _aDados[nX][16] )
				oModelNN7:SetValue("NN7_SLDQTD", oModelNN7:GetValue("NN7_SLDQTD") + _aDados[nX][13] - _aDados[nX][16] )
				oModelNN7:SetValue("NN7_STSTIT", "1" ) //atualizar
				
				If oModelNJR:GetValue("NJR_MOEDA") > 1 .and. oModelNJR:GetValue("NJR_TIPMER") == "1" // 
					oModelNN7:SetValue("NN7_VLRTAX", _aDados[nX][10])
				Else
					oModelNN7:SetValue("NN7_VLRTAX", 0)
				EndIf
			EndIf
                                     
            //verifica se a linha o item que pode ser atualizado
            if oModelN9J:Length() >= nCountN9J
            	oModelN9J:GoLine( nCountN9J )
            	//Se a linha estiver deletada
                If oModelN9J:IsDeleted()
                    oModelN9J:UnDeleteLine()
                EndIf	
            else // nova linha
            	oModelN9J:AddLine()
            endif

            /* limpa valores estrutura dos campos da tabela NJ9*/
            For nItemN9J := 1 to Len(aFieldsN9J)
                oModelN9J:ClearField(aFieldsN9J[nItemN9J][3] )    
            Next nItemN9J

            oModelN9J:SetValue("N9J_SEQ"   , StrZero(nCountN9J, 3))
            oModelN9J:SetValue("N9J_ITEMPE", _aDados[nX][3] )
            oModelN9J:SetValue("N9J_ITEMRF", _aDados[nX][4] )
            oModelN9J:SetValue("N9J_SEQCP" , _aDados[nX][5] )
            oModelN9J:SetValue("N9J_SEQPF" , oModelNN7:GetValue("NN7_ITEM") )
            oModelN9J:SetValue("N9J_VALOR" , _aDados[nX][7] )
            oModelN9J:SetValue("N9J_VENCIM", _aDados[nX][6] )
            oModelN9J:SetValue("N9J_DTATUA", _aDados[nX][11] )
            oModelN9J:SetValue("N9J_PERCEN", _aDados[nX][12] )
            oModelN9J:SetValue("N9J_QTDE"  , _aDados[nX][13] )
            oModelN9J:SetValue("N9J_SLDQTD", _aDados[nX][13] - _aDados[nX][14] )
            oModelN9J:SetValue("N9J_VLRFIX", _aDados[nX][15] )
            oModelN9J:SetValue("N9J_QTDEVT", _aDados[nX][16] )  
            oModelN9J:SetValue("N9J_VLFCON", _aDados[nX][17] )           
            If oModelN9J:HasField("N9J_TIPEVE")
                oModelN9J:SetValue("N9J_TIPEVE", "2" )           //NÃO É EVENTO
            EndIf
            
            If lExistND1            
				nCountND1 := 1
				For nY := 1 To Len(_aDados[nX][20])                
					//verifica o item que pode ser atualizado
					if oModelND1:Length() >= nCountND1
						oModelND1:GoLine( nCountND1 )
						If oModelND1:IsDeleted()
							oModelND1:UnDeleteLine()
						EndIf	
					else
						oModelND1:AddLine()
					endif

					fLimpaLinha(oModelND1)                
					oModelND1:SetValue("ND1_SEQ"   ,  StrZero(nCountND1, 3))
					oModelND1:SetValue("ND1_ITEMFX",  _aDados[nX][20][nY][01] )
					oModelND1:SetValue("ND1_VLUFIX",  _aDados[nX][20][nY][05] )
					oModelND1:SetValue("ND1_VLUFAT" , _aDados[nX][20][nY][06] )										
					oModelND1:SetValue("ND1_VLTAXA",  _aDados[nX][20][nY][03] )
					oModelND1:SetValue("ND1_MOEDA",   _aDados[nX][20][nY][02] )
					oModelND1:SetValue("ND1_QTDE",    _aDados[nX][20][nY][08] )
					oModelND1:SetValue("ND1_DTVCTO",  _aDados[nX][20][nY][09] )
					oModelND1:SetValue("ND1_DTTAX",   _aDados[nX][20][nY][04] )
					oModelND1:SetValue("ND1_TIPPRC",  _aDados[nX][20][nY][11] )

					nCountND1++
				Next nY
            EndIf

            nCountN9J++
		Next nX
	EndIf      	
	
	//Caso existir linhas sem valor, ele deleta.
    
	For nDelNN7 := 1 To oModelNN7:Length()
	
		//vou pra linha
		oModelNN7:GoLine(nDelNN7)
		//se a data de vencimento estive vazia
		If Empty(oModelNN7:GetValue('NN7_DTVENC'))
			//deleto a linha
			oModelNN7:DeleteLine()				
		Else
            //atualizo os campos sequenciais
              nQtdSeq++
            oModelNN7:SetValue("NN7_ITEM",   StrZero(nQtdSeq,TamSX3("NN7_ITEM")[1]))
            oModelNN7:SetValue("NN7_PARCEL", StrZero(nQtdSeq,TamSX3("NN7_PARCEL")[1]))	
        EndIf

	Next nDelNN7    

    /*calcula preço demonstrativo e despesas*/
	OGX070CDEM( , , .T. /*CALC GFE*/, oModel)	

    oModelNN7:SetNoInsertLine(.T.)
    oModelNN7:SetNoDeleteLine(.T.)
Return .T.


/*{Protheus.doc} fLimpaLinha
   Limpa os campos do registro corrente da NNF
@type function
@param  oModelNN7 - Recebe o submodelo da NN7 para inclusão dos dados
@Return Boolean
@author Marcelo Ferrari
@since 19/03/2018
@version undefined
*/
Static Function fLimpaLinha(oSubModel) 
    Local nIt 		 := 0
    Local aFieldsSub := oSubModel:GetStruct():GetFields() // Estrutura de campos do submodelo
    
    For nIt := 1 to Len(aFieldsSub)
        // Condição adicionada devido a falha do metodo ClearField em limpar campos do tipo BT - Botão, o qual ocasiona erro ao model
        If "NN7_STSLEG" $ aFieldsSub[nIt][3]
             oSubModel:LoadValue("NN7_STSLEG", "BR_VERDE") // Valor padrão da legenda
        ElseIf !(aFieldsSub[nIt][3] $ "NN7_PARCEL|NN7_ITEM" )
            oSubModel:ClearField( aFieldsSub[nIt][3] )
        EndIf
    Next nIt

Return .T.


/******************************************************************************
***********************FUNÇÕES DE TRATAMENTO DE DATA***************************
*******************************************************************************/

/** {Protheus.doc} GetDtTkUp
Retorna a data do take-up referente a regra fiscal vinculada
@param:     
@return:    dData (DATE) -> Data do Faturamento
@author:    Marcelo Ferrari
@since:     22/05/2018
@Uso:       OGX018
*/
Static Function fGetDtTkUp(cCodTkp )
    Local dData := Nil
    Local cData := ""

    cData := GetDataSql("SELECT DXP_DATTKP " + ;
                        " FROM " + RetSqlName("DXP") + " DXP " + ;
                        " WHERE DXP_FILIAL = '" + fwxFilial("DXP") + "' " + ;
                        " AND DXP_CODIGO = '" + cCodTkp + "' ")

    If !Empty(cData)
        dData := STOD(cData)
    EndIf

Return dData


/*/{Protheus.doc} fVldRegraF
    (long_description)
    @type  Static Function
    @author rafael.voltz
    @since 16/10/2019
    @version version
    @param param, param_type, param_descr
    @return lRet, boolean, Status da validação da regra fiscal
    @example
    (examples)
    @see (links_or_references)
    /*/
 Static Function fVldRegraF(cFilCtr, cCodCtr, oModel)
    Local cAliasQry as char 
    Local lRet      as logical
    Local nNNY      as numeric
    Local nN9A      as numeric
    Local oModelNNY as object
    Local oModelN9A as object            

    Default oModel := nil

    lret := .T.

    If ValType(oModel) == "O" // Se for o model do contrato ativo
        oModelNNY := oModel:GetModel( "NNYUNICO" )
        oModelN9A := oModel:GetModel( "N9AUNICO" )        

        For nNNY := 1 to oModelNNY:Length()
            
            oModelNNY:GoLine( nNNY )
            
            if !(oModelNNY:isDeleted())                            
                For nN9A := 1 to oModelN9A:Length()
                    oModelN9A:GoLine( nN9A )
                    if !(oModelN9A:isDeleted())   
                        If Empty(oModelN9A:GetValue( "N9A_FILORG" ))                        
                            lRet := .F.
                            exit
                        EndIf 
                    EndIf
                Next nN9A
            EndIf            
        Next nNNY        
    
    Else
        cAliasQry := GetNextAlias()

        BeginSQL Alias cAliasQry
            SELECT COUNT(N9A_FILIAL) QTD
              FROM %table:N9A% N9A
             WHERE N9A.N9A_FILIAL = %Exp:cFilCtr%
               AND N9A.N9A_CODCTR = %Exp:cCodCtr%
               AND (N9A.N9A_FILORG = '' OR N9A.N9A_FILORG IS NULL)
               AND N9A.%notDel%
        EndSql

        lRet := Iif( (cAliasQry)->QTD > 0, .F., .T.)

        (cAliasQry)->(dbCloseArea())
    EndIf

    If !lRet 
        Help( , ,STR0014, , STR0013 + ".", 1, 0) //##Aviso  ##A filial de origem não foi informada na regra fiscal
    EndIf 

Return lRet 
