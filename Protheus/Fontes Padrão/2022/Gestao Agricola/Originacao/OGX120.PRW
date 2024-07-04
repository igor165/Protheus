#INCLUDE "OGX120.ch"
#Include 'Protheus.ch'

/**{Protheus.doc} OGX120
Validação na Baixa de Títulos a pagar
Gerar titulos de comissao para a corretora
@param: 	Nil
@author: 	José Leite de Barros Neto
@since: 	15/07/2013
@Uso: 		SIGAFIN - Financeiro
**/
//Programa Original: ARMXPE16.PRW
Function OGX120()
	If FindFunction("OGXUTOG") //Encontra a função
		If OGXUTOG()
			If FindFunction("OGX120A")
				OGX120A()
		   Endif
		Endif 
	EndIf
	
Return( Nil )	


//-------------------------------------------------------------------
/*/{Protheus.doc} OGX120DTPR
Função responsável por consumir as datas de vencimentos das previsões 
financeiras e registrar na N9K.
@author  rafael.voltz
@since   11/05/2018
@version version
@param cFilOrig, char, Filial de Origem 
       cCodCtr,  char, Código do contrato
	   cRomaneio,  char, Código do Romaneio
	   cItemRom,   char, Item do Romaneio
	   cPrevEnt,   char, Previsão de Entrega
	   cRegraFis,  char, Regra Fiscal
	   nQtdRom,    numeric, Quantidade do Romaneio,
	   nValor,     numeric, Valor
/*/
//-------------------------------------------------------------------
Function OGX120DTPR(cFilOrig, cCodCtr, cRomaneio, cItemRom, cPrevEnt, cRegraFis, nQtdRom, nValFix, lAFixar, lEmbarque, dDataBL, cCodIne, cPedEmb, lComissao)	
	Local cAliasQry   := GetNextAlias()	
	Local aAtuSld     := {}
	Local aN9K        := {}
	Local nX          := 0	
	Local nQtdUtizda  := 0
	Local aAreaN9J    := N9J->(GetArea())
	Local aAreaN9K    := N9K->(GetArea())
	Local aAreaNN7    := NN7->(GetArea())	
	Local aRetPagDat  := {} //datas de pagamento
	Local aLstDate    := {} //datas da N9K
	Local nPos        := 0
	Local nVlrFinN9K  := 0 //valor financeiro da quebra
	Local lFatEvt     := .f.
	Local cSql        := ""
	Local nQtdTTRom   := nQtdRom
	Local lExport     := .F.
	Local lAchou      := .F.
	Local nSomaPct    := 0
	Local nY          := 0
	Local nPct        := 0

	Default	cFilOrig  := ""
	Default cRomaneio := ""
	Default cItemRom  := ""
	Default cRegraFis := ""
	Default cCodCtr   := ""
	Default cPrevEnt  := ""	
	Default nQtdRom   := 0	
	Default lEmbarque := .F.
	Default dDataBL   := NIL
	Default cCodIne   := ""
	Default cPedEmb   := ""
	Default lComissao := .F.
		

	//Se for Mercado Externo / Moeda Estrangeira deve gerar uma N9K para cada condição de pagamento
	//consumindo o saldo proporcionalmente as duas condições
	lExport := 'S' = GetDataSql("SELECT 'S' RES FROM " + RetSqlname("NJR") + " NJR " + ;
								" WHERE NJR_CODCTR = '" + cCodCtr + "' " + ;
								" AND D_E_L_E_T_ = ' ' " + ;
								" AND NJR_TIPMER = '2' " + ;
								" AND NJR_MOEDA <> '1' " )

        cSql := "SELECT N9J.N9J_FILIAL, " + ;
			"  N9J.N9J_CODCTR, " + ;
			"  N9J.N9J_ITEMPE N9J_ITEMPE,  " + ;
            "  N9J.N9J_ITEMRF N9J_ITEMRF,  " + ;
            "  N9J.N9J_SEQ    SEQ_RELAC,  " + ;
			"  N9J.N9J_SEQPF  SEQ_PREVISAO, " + ;			   
			"  N9J.N9J_SEQCP  SEQ_CONDPGTO, " + ;
			"  N9J.N9J_VENCIM VENCIMENTO, " + ; 
			"  N9J.N9J_QTDE   N9J_QUANT, " + ; 
			"  N9J.N9J_SLDQTD N9J_SALDO, " + ;
			"  NN7.NN7_QTDE   NN7_QUANT, " + ;
			"  NN7.NN7_VALOR, " + ;
			"  NN7.NN7_SLDQTD NN7_SALDO, " + ;		   
			"  NN7.NN7_FILORG FIL_ORIGEM, " + ;
			"  NN7.NN7_PARCEL PARCELA, " + ;
			"  NN7.NN7_VLCOMP NN7_VLCOMP, " + ;			   
			"  N84.N84_REFCTR REFCTR, " + ;
			"  N84.N84_ANTPOS ANTPOS, " + ;
			"  N84.N84_NRDIAS NUMDIAS, " + ;
			"  N84.N84_TIPVCT TIPVCT, " + ;
			"  N84.N84_DIAMES DIAMES, " + ;
			"  N84.N84_TIPVAL, " + ;
			"  N84.N84_QTDE, " + ;
			"  N84.N84_PCT " + ;
			"  FROM " + RetSqlName("N9J") + " N9J " + ;
			"INNER JOIN " + RetSqlName("NN7") + " NN7 ON " + ;
			   " NN7_FILIAL = N9J_FILIAL AND " + ;
			   " NN7_CODCTR = N9J_CODCTR AND "  + ;
			   " NN7_ITEM   = N9J_SEQPF AND  " + ;
			   " NN7.D_E_L_E_T_ = N9J.D_E_L_E_T_ " + ;
			"INNER JOIN " + RetSqlName("N84") + " N84 ON " + ;
			   " N84_FILIAL = N9J_FILIAL AND " + ;
			   " N84_CODCTR = N9J_CODCTR AND " + ;
			   " N84_SEQUEN = N9J_SEQCP AND  " + ;
			   " N84.D_E_L_E_T_ = N9J.D_E_L_E_T_ " 

	IF lExport .AND. lEmbarque .AND. !empty(dDataBL)			
        cSql += "INNER JOIN " + RetSqlName("N9K") + " N9K ON " + ;
                " N9K_FILIAL = '" + fwxFilial("N9K") + "' AND " + ;
                " N9K_CODCTR = N9J_CODCTR AND " + ; 
                " N9K_ITEMPE   = N9J_ITEMPE AND " + ; 
                " N9K_ITEMRF   = N9J_ITEMRF AND " + ; 
                " N9K_SEQCP   = N9J_SEQCP AND " + ; 
                " N9K_SEQPF   = N9J_SEQPF AND " + ; 
                " N9K_SEQN9J   = N9J_SEQ AND " + ; 
                " N9K.D_E_L_E_T_ = N9J.D_E_L_E_T_ "
	EndIf

	cSql += " WHERE N9J_FILIAL  = '" + fwxFilial("N9J") + "' " + ;
	        " AND N9J_CODCTR  = '" + cCodCtr + "' " + ;
	        " AND N9J_ITEMPE  = '" + cPrevEnt + "' " + ;
	        " AND N9J_ITEMRF  = '" + cRegraFis + "' " + ;
	        " AND N9J_SLDQTD  > 0 "

	IF (lExport) .AND. (lEmbarque) .AND. (!empty(dDataBL))
	   If  !(lComissao) 
	   	   cSql += " AND N9K_CODINE = ''" + ;
	           " AND N9K_CODINV = ''" + ;
			   " AND N9K_PEDEMB = ''"
		Else
	   	   cSql += " AND N9K_CODINE = '" + cCodIne + "' " + ;
			       " AND N9K_PEDEMB = '" + cPedEmb + "' "
		EndIf
	EndIf      
	cSql += " AND N9J.D_E_L_E_T_ = ' ' "  + ;
	        " ORDER BY N9J_VENCIM "

    cAliasQry := GetSqlAll(cSql)
	nSomaPct := 0
	While (cAliasQry)->(!Eof()) .AND. nQtdRom > 0
		
	   If lExport
          //Encontrar o percentual correspondente ao total do contrato
          nQtdCtr := GetDataSql("SELECT NJR_QTDCTR " + ;
                                " FROM " + RetSqlname("NJR") + " NJR " + ;
					            " WHERE NJR_CODCTR = '" + cCodCtr + "' " + ;
					            " AND D_E_L_E_T_ = ' ' " )

		  If  (cAliasQry)->N84_TIPVAL = "2"  //SE TIPO FOR PERCENTUAL
		        nPct :=  (cAliasQry)->N84_PCT / 100
	      Else
		        nPct := (cAliasQry)->N84_QTDE / nQtdCtr
	      EndIf
	      nSomaPct += nPct

	      nQtdParcRom := nQtdTTRom * nPct 
              nQtdUtizda  := nQtdParcRom
	   Else  // CONTRATOS MERCADO INTERNO
	      If (cAliasQry)->N9J_SALDO <= nQtdRom 
	          nQtdUtizda := (cAliasQry)->N9J_SALDO //consumirá todo o saldo
	      Else 
	          nQtdUtizda := nQtdRom 
	      EndIf
       	   EndIf	
		
		nVlrFinN9K := Round((((cAliasQry)->NN7_VALOR / (cAliasQry)->NN7_QUANT) * nQtdUtizda) ,TamSx3("NN7_VALOR")[2]) //monta o valor financeiro
		
		IF lExport .AND. lEmbarque .AND. !empty(dDataBL)
		   aDataVcto  := GetDtVcto(cAliasQry,cFilOrig, cRomaneio, nQtdUtizda, nVlrFinN9K, lEmbarque, dDataBL ) 
		Else
		   aDataVcto  := GetDtVcto(cAliasQry,cFilOrig, cRomaneio, nQtdUtizda, nVlrFinN9K) 		
		EndIf
		
		aadd(aLstDate,  aDataVcto[1])
		aAdd(aN9K,	  {(cAliasQry)->SEQ_PREVISAO, (cAliasQry)->PARCELA, aDataVcto[1], nQtdUtizda, (cAliasQry)->N9J_FILIAL, (cAliasQry)->SEQ_CONDPGTO, (cAliasQry)->SEQ_RELAC, aDataVcto[3], nVlrFinN9K })							
		aAdd(aAtuSld, {xFilial("N9J") + cCodCtr + cPrevEnt + cRegraFis + (cAliasQry)->SEQ_CONDPGTO + (cAliasQry)->SEQ_PREVISAO + (cAliasQry)->SEQ_RELAC , xFilial("NN7") + cCodCtr + (cAliasQry)->SEQ_PREVISAO} )									
		nQtdRom    -= nQtdUtizda	
		nX := Len(aN9K)	

		//verifica e coloca as datas para consumo usado o (cAliasQry)->VENCIMENTO pois ele contem a data correta da cotação
		if stod(aDataVcto[2]) <= dDatabase .OR. ( lExport .AND. lEmbarque .AND. !empty(dDataBL) )		   
			if (nPos := aScan(aRetPagDat,{|x| x[1] == aDataVcto[2] })) > 0
				aRetPagDat[nPos][2] += nQtdUtizda	
				iF lExport .AND. lEmbarque .AND. !empty(dDataBL)
				   For nY := 1 to Len(aRetPagDat) -1
				       aRetPagDat[nY][3] := nSomaPct
				   Next nY
				EndIf
			else
			    IF lExport .AND. lEmbarque .AND. !empty(dDataBL)
				    //Quando a funcao e chamada pelo EEC para calcular a distrubuição dos valores
					aAdd(aRetPagDat, {aDataVcto[2], nQtdUtizda, nSomaPct,  nPct  } )
				   For nY := 1 to Len(aRetPagDat) -1
				       aRetPagDat[nY][3] := nSomaPct
				   Next nY
				Else
				   //aAdd(aRetPagDat[ len(aRetPagDat) ], nQtdUtizda  )
                   aAdd(aRetPagDat, {aDataVcto[2], nQtdUtizda, nSomaPct,  nPct  } )
				EndIf
			EndIf
		endif
		
		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

	If lExport .AND. lEmbarque .AND. !empty(dDataBL)  .AND. (lComissao)
	   FWFreeObj(aAtuSld)
	   FWFreeObj(aN9K)
	   RestArea(aAreaN9J)
	   RestArea(aAreaN9K)
	   RestArea(aAreaNN7)	
       Return {aLstDate,aRetPagDat}
	EndIf

	dbSelectArea("NN7")
	dbSelectArea("N9J")
	dbselectArea("N9K")
	dbselectArea("N84")
	NN7->(DbSetOrder(1))	
	N9J->(DbSetOrder(1))	
	N9K->(DbSetOrder(1))
	N84->(DbSetOrder(1))

	nX := 0
	For nX := 1 to Len(aN9K)		
		//INDICE 1
		//N9K_FILIAL+N9K_CODROM+N9K_ITEROM+N9K_FILORI+N9K_CODCTR+N9K_ITEMPE+N9K_ITEMRF+N9K_SEQCP+N9K_SEQPF+N9K_SEQN9J                                                     
		lAchou := N9K->(DbSeek(xFilial("N9K")+cRomaneio+cItemRom+aN9K[nX,5]+cCodCtr+cPrevEnt+cRegraFis+aN9K[nX,6]+aN9K[nX,8]+aN9K[nX,7]))

		RecLock("N9K", !(lAchou) )
		    If !(lAchou)  //Inclui novo registro
		    	N9K->N9K_FILIAL := xFilial("N9K")
		    	N9K->N9K_CODROM := cRomaneio
		    	N9K->N9K_ITEROM := cItemRom 
		    	N9K->N9K_FILORI := aN9K[nX,5]
		    	N9K->N9K_CODCTR := cCodCtr
		    	N9K->N9K_ITEMPE := cPrevEnt
		    	N9K->N9K_ITEMRF := cRegraFis
		    	N9K->N9K_SEQCP  := aN9K[nX,6]
		    	N9K->N9K_SEQPF  := aN9K[nX,8] //previsão financeira vigente
		    	N9K->N9K_SEQN9J := aN9K[nX,7]

			    //new campos
			    N9K->N9K_ORIGPF := aN9K[nX,1] //Previsão Financeira Original
			    N9K->N9K_VLRFIX := aN9K[nX,4] * nValFix //valor consumido da fixação 
			    N9K->N9K_FIXADO := iif(lAFixar,"1","2") //2=Fixo , 1= Afixar
		    EndIf	
		    
			N9K->N9K_DTVENC := stod(aN9K[nX,3])
			N9K->N9K_QTDVNC := aN9K[nX,4]			
			N9K->N9K_VALOR  := 0 //hj não grava nenhum valor, pois temos que descontar os impostos retidos	

			iF lExport .AND. lEmbarque .AND. !empty(dDataBL) 
				N9K->N9K_CODINE  := cCodIne
				N9K->N9K_PREEMB  := cPedEmb
				N9K->N9K_DTVNEX  := dDataBL
			EndIf

		N9K->(MsUnlock())
		
		If !lAchou
		    //update na previsão original
		    IF N9J->(DbSeek(aAtuSld[nX, 1]))
		    	RecLock("N9J", .F.)
		    	// Atualiza o saldo somente quando não é evento. Evento é feito na função da quebra
                if aN9K[nX,8] == aN9K[nX,1] //Seq Original NN7(N9K_ORIGPF) - Nova Seq NN7(N9K_SEQ
                    N9J->N9J_SLDQTD -= aN9K[nX,4]		    	
                EndIf
		    	N9J->(MsUnlock())
		    EndIf
		    
	        IF N84->(DbSeek(aN9K[nX,5]+cCodCtr+aN9K[nX,6]))
	        	RecLock("N84", .F.)
		    	N84->N84_QTDVNC += aN9K[nX,4]
		    	N84->(MsUnlock())
	        Endif
	        	    
		    IF NN7->(DbSeek(aAtuSld[nX, 2]))
                //Quando condição de pagamento é por evento, devemos realizar os tratamentos extras na tabela de preco
		    	if aN9K[nX,8] <> aN9K[nX,1] //Seq Original NN7(N9K_ORIGPF) - Nova Seq NN7(N9K_SEQPF)
		    		lFatEvt         := .t.		    		
		    	Else
                    RecLock("NN7", .F.)
		    	    NN7->NN7_SLDQTD -= aN9K[nX,4] //baixa apenas a quantidade. O saldo é baixado depois que é gerado o título. Quando Evento a Baixa acontece na quebra
                    NN7->(MsUnlock())
                endif		    	
		    EndIf
		EndIf	
	Next nX 	
	N9K->(dbCloseArea())	    

	//refaz os calculos da previsao
	if lFatEvt
		OGX018(xFilial("NJR"), cCodCtr, .F.) //refaz as previsões
	endif

	FWFreeObj(aAtuSld)
	FWFreeObj(aN9K)
	RestArea(aAreaN9J)
	RestArea(aAreaN9K)
	RestArea(aAreaNN7)	

Return {aLstDate,aRetPagDat}

/*{Protheus.doc} OGX120CANC
Realiza o estono do saldo nas tabelas de controle do fluxo financeiro
@type:      Function
@author:    filipe.olegini
@since:     11/05/2018
@version version
@param:     cFilOrig    -> Filial de Origem do registro
@param:     cCodCtr     -> Código do contrato
@param:     cRomaneio   -> Código do romaneio
@param:     cItemRom    -> Item do Romeneio - NJM
@param?     cPrevEnt    -> Previsao de Entrega
@param:     cRegraFis   -> Vinculo com a regra fiscal
@return:    nil -> Sem retorno
*/
Function OGX120CANC(cTipoCanc, cFilOrig, cCodCtr, cRomaneio, cItemRom, cPrevEnt, cRegraFis, nQtdRoman, nValorDevol, aTituloNCC)
    Local cQuery    := ""
    Local nQtdCanc  := 0
    Local nVlrCanc  := 0
    Local nVlrUnCan := nValorDevol / nQtdRoman
    Local lTitEvent := .f. 
    Local cAliasN9K := GetNextAlias()
    Local aAreaN9M  := N9M->(GetArea())
	Local aAreaN9K  := N9K->(GetArea())
	Local aAreaN9J  := N9J->(GetArea())
	Local aAreaNN7  := NN7->(GetArea())
	Local lFatEvt   := .f.
	
	Default aTituloNCC  := {}
	Default nQtdRoman   := {}
	Default nValorDevol := {}
	
	dbSelectArea('N9K')
	dbSelectArea('N9J')
	dbSelectArea('NN7')
	NN7->(DbSetOrder(1))
	N9J->(DbSetOrder(1))

    cQuery := "SELECT N9K_FILORI, N9K_SEQCP, N9K_SEQPF, N9K_SEQN9J, N9K_QTDVNC, N9K_VALOR, N9K_ORIGPF, N9K_VLRFIX, N9K_QTDEVL,  R_E_C_N_O_ AS RECNO, "
    cQuery +=  " N9K_FILTIT, N9K_PREFIX, N9K_NUM, N9K_PARCEL, N9K_TIPO " //campos para deleção da N9M 
    cQuery +=  " FROM " + RetSqlname("N9K")
    cQuery +=  " WHERE N9K_FILIAL = '" + FWxFilial('N9K') + "' "
    cQuery +=  "   AND N9K_CODROM = '" + cRomaneio + "' "
    cQuery +=  "   AND N9K_ITEROM = '" + cItemRom + "' "
    cQuery +=  "   AND N9K_FILORI = '" + cFilOrig + "' "
    cQuery +=  "   AND N9K_CODCTR = '" + cCodCtr + "' "
	cQuery +=  "   AND N9K_ITEMPE = '" + cPrevEnt + "' "
	cQuery +=  "   AND N9K_ITEMRF = '" + cRegraFis + "' "
	if cTipoCanc == "D" //devolução
		cQuery +=  "   AND N9K_QTDVNC - N9K_QTDEVL > 0 "
	endif
	cQuery +=  "   AND D_E_L_E_T_ = ' ' "
    cQuery := ChangeQuery(cQuery)
    
    If Select(cAliasN9K) <> 0
        (cAliasN9K)->(dbCloseArea())
    Endif	
	
    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasN9K,.T.,.T.)

    //Grava a chave[4] para vincular RAXNF devido a grid possibilitar selecionar RA e NF diferentes
    If (cAliasN9K)->(!EOF())
        While (cAliasN9K)->(!EOF()) 
			
			//verifica se é título por evento
			If (N9J->(DbSeek( (cAliasN9K)->N9K_FILORI + cCodCtr + cPrevEnt + cRegraFis + (cAliasN9K)->N9K_SEQCP + (cAliasN9K)->N9K_SEQPF )))
                lTitEvent := Iif(N9J->(ColumnPos('N9J_TIPEVE')) > 0 .AND. N9J->N9J_TIPEVE == "1", .T., .F.)     
            EndIf
									
			if cTipoCanc == "D" //devolução
				
				if nQtdRoman = 0 //sem dados para gravar
					(cAliasN9K)->(dbSkip())
					Loop //manda para o próximo registro
				endif
				
				//avalia a quantidade a ser devolvida
				if nQtdRoman > (cAliasN9K)->N9K_QTDVNC - (cAliasN9K)->N9K_QTDEVL
					nQtdCanc := (cAliasN9K)->N9K_QTDVNC - (cAliasN9K)->N9K_QTDEVL 
				else
					nQtdCanc := nQtdRoman
				endif	
				nQtdRoman -= nQtdCanc
				
				//verifica o valor para vincular do título
				nVlrCanc  := round(nVlrUnCan * nQtdCanc, TamSx3("NN7_VLDEVL")[2])
				
				if nValorDevol < nVlrCanc
					//usamos o que sobro
					nVlrCanc := nValorDevol
				endif				
			
				nValorDevol -= 	nVlrCanc
			else
				nQtdCanc := (cAliasN9K)->N9K_QTDVNC - (cAliasN9K)->N9K_QTDEVL
			endif            
			
            If (N9J->(DbSeek( (cAliasN9K)->N9K_FILORI + cCodCtr + cPrevEnt + cRegraFis + (cAliasN9K)->N9K_SEQCP + (cAliasN9K)->N9K_ORIGPF + (cAliasN9K)->N9K_SEQN9J )))
				//ajuste o consumo das N9J	
				RecLock('N9J', .F.)
					N9J->N9J_SLDQTD += nQtdCanc //(cAliasN9K)->N9K_QTDVNC	

                    If lTitEvent 
                        N9J->N9J_QTDE   += nQtdCanc
                        N9J->N9J_QTDEVT -= nQtdCanc
                    EndIf
           					
				N9J->(MsUnlock())
				
				IF N84->(DbSeek((cAliasN9K)->N9K_FILORI + cCodCtr + (cAliasN9K)->N9K_SEQCP))
			    	RecLock("N84", .F.)
					N84->N84_QTDVNC -= nQtdCanc			
					N84->(MsUnlock())
			    Endif

				If NN7->(DbSeek((cAliasN9K)->N9K_FILORI + cCodCtr + (cAliasN9K)->N9K_ORIGPF)) 						
					RecLock('NN7', .F.)
						NN7->NN7_SLDQTD += nQtdCanc	
                        
                        if lTitEvent //titulo por evento					        				        
					        NN7->NN7_QTDE   += nQtdCanc	                            
	                        NN7->NN7_STSTIT := "2" //atualiza para realizar a correção	                                        
                        endif

						if cTipoCanc == "D" .and. !lTitEvent //devolução
							NN7->NN7_VLDEVL  += nVlrCanc	
																																							
							//aumentar a quantidade de valor							
                            NN7->NN7_VLCOMP  += nVlrCanc	
                        	
                        	//verifica se a quantidade de RA vinculada já ultrapassou a quantidade da PR, quer dizer que não tinha quantidade suficiente para ter emitido documento
							if NN7->NN7_VLDEVL + NN7->NN7_VALOR > NN7->NN7_VLRAVI 
								//ajusta o saldo, o NN7_VLTEMI não precisa checar, pois nunca terá 100%, pois é devolução
								NN7->NN7_VLSALD	 += nVlrCanc
							endif
                        	
                        endif
                        
                        //tratamento para títulos gerados por evento -> Ajustar o título PAI
						lFatEvt := .t. //é por evento
						
					NN7->(MsUnlock())
				EndIf   
				
				//verifica a existencia de título gerado através de evento 
	            if lTitEvent
	            	//temos um título gerado através de evento
	            	fDeleteNN7(cFilOrig, cCodCtr, (cAliasN9K)->N9K_SEQPF, nQtdCanc, 0, cTipoCanc, nVlrCanc )
                    fDeleteN9J(N9J->N9J_FILIAL, cCodCtr, cPrevEnt, cRegraFis, (cAliasN9K)->N9K_SEQCP, (cAliasN9K)->N9K_SEQPF, nQtdCanc, cTipoCanc)
	            endif
	            	           
            	//vamos amarrar a nova nota de crédito
            	if cTipoCanc == "D" .and. len(aTituloNCC) > 0
            		//busca a parcela
            		cItemParc := Posicione("NN7",1,cFilOrig+cCodCtr+(cAliasN9K)->N9K_SEQPF,"NN7_PARCEL")
            		
            		//grava a relação do título
            		dbSelectArea("N9G")
	                dbSetOrder(1)  //N9G_FILIAL+N9G_CODCTR+N9G_ITEMPV+N9G_PARPV+N9G_NUM+N9G_PARTT+N9G_PREFIX+N9G_TIPO+N9G_TPOPER
	                If DbSeek(FwXfilial("N9G") + PadR(Alltrim(cCodCtr),TamSx3('N9G_CODCTR')[1] ) + (cAliasN9K)->N9K_SEQPF + cItemParc + aTituloNCC[3] + PadR(Alltrim(aTituloNCC[2]),TamSx3('N9G_PARTT')[1] ) + PadR(Alltrim(aTituloNCC[2]),TamSx3('N9G_PREFIX')[1] ) + PadR(Alltrim("NCC"),TamSx3('N9G_TIPO')[1] ) + PadR(Alltrim("RAxPV"),TamSx3('N9G_TPOPER')[1] ))  
	                    If RecLock("N9G", .F.)
	                        N9G->N9G_VALOR += nVlrCanc //aqui fará o incremento sozinho
	                        N9G->(MsUnLock())
	                    EndIf
	                Else
	                    If RecLock("N9G", .T.)
	                        N9G->N9G_FILIAL     := FwXfilial("N9G")
	                        N9G->N9G_CODCTR     := cCodCtr
	                        N9G->N9G_ITEMPV     := (cAliasN9K)->N9K_SEQPF
	                        N9G->N9G_PARPV      := cItemParc
	                        N9G->N9G_TIPO       := "NCC" //somente nota de credido cliente
	                        N9G->N9G_PREFIX     := aTituloNCC[2] //prefixo
	                        N9G->N9G_NUM        := aTituloNCC[3] //duplicada
	                        N9G->N9G_PARTT      := aTituloNCC[2] //no caso de nota de devolução a parela recebe o mesmo valor do prefixo - Regra do Compras
	                        N9G->N9G_FILTIT     := aTituloNCC[1] // filial de origem do compras...
	                        N9G->N9G_TPOPER     := "RAxPV"
	                        N9G->N9G_VALOR      := nVlrCanc //retorna o valor que foi devolvido.
	                        N9G->(MsUnlock())
	                    EndIf
	                EndIf 
	                
				endif			               
			EndIf
                        
            if cTipoCanc == "D" //devolução
            	            	
            	//depois de realizar o ajuste de saldo apaga o registro da N9K            
	            N9K->(dbGoTo((cAliasN9K)->RECNO))
	            RecLock('N9K', .F.)
				   N9K->N9K_QTDEVL += nQtdCanc	
				   N9K->N9K_VLRFIX -= ((cAliasN9K)->N9K_VLRFIX / ((cAliasN9K)->N9K_QTDVNC - (cAliasN9K)->N9K_QTDEVL) ) * nQtdCanc				   //valor das fixações diminuidas
				N9K->(MsUnlock())
				
            else
	            //deleta a N9M - relacionamento dos titulos
	            dbSelectArea("N9M")
	            dbSetOrder(1)
	            dbGoTop() //N9M_FILIAL + N9M_CODCTR + N9M_CODROM + N9M_ITEROM + N9M_FILTIT + N9M_PREFIX + N9M_NUM + N9M_PARCEL + N9M_TIPO
	            If dbSeek(FWxFilial("N9M") + cCodCtr + cRomaneio + cItemRom + (cAliasN9K)->(N9K_FILTIT + N9K_PREFIX + N9K_NUM + N9K_PARCEL + N9K_TIPO) )
	                While N9M->(!Eof()) .and. (FWxFilial("N9M") + cCodCtr + cRomaneio + cItemRom + (cAliasN9K)->(N9K_FILTIT + N9K_PREFIX + N9K_NUM + N9K_PARCEL + N9K_TIPO)) == (N9M->(N9M_FILIAL+N9M_CODCTR+N9M_CODROM+N9M_ITEROM+N9M_FILTIT+N9M_PREFIX+N9M_NUM+N9M_PARCEL+N9M_TIPO))					
						RecLock('N9M', .F.)
							N9M->(dbDelete())
						N9M->(MsUnlock()) 
						N9M->(dbSkip())
					EndDo
	            EndIf
	            
				//depois de realizar o ajuste de saldo apaga o registro da N9K            
	            N9K->(dbGoTo((cAliasN9K)->RECNO))
	            RecLock('N9K', .F.)
				   N9K->(dbDelete())
				N9K->(MsUnlock())
			endif
			
            (cAliasN9K)->(dbSkip())
        EndDo
    EndIf
    (cAliasN9K)->(dbCloseArea())

	//refaz os calculos da previsao
	if lFatEvt
		OGX018(FWxfilial("NJR"), cCodCtr, .F.) //refaz as previsões
	endif
    
    //chama a função que varre a NN7 toda e reajusta os titulos provisórios
    OGX018ATPR(FWxfilial("NJR"), cCodCtr, "OGA250")
    
    RestArea(aAreaN9M)
	RestArea(aAreaN9K)
	RestArea(aAreaN9J)
	RestArea(aAreaNN7)

Return nil

//-------------------------------------------------------------------
/*{Protheus.doc} GetDtVcto
Função responsável por retornar a data de vencimento para a N9K
@author  rafael.voltz
@since   12/06/2018
@version version
@param:     cAliasQry   -> Alias da Query
@param:     cFilOrig    -> Filial de Origem do registro
@param:     cRomaneio   -> Código do romaneio
@return:    cDataVcto   -> Data do vencimento
*/
//-------------------------------------------------------------------
Static Function GetDtVcto(cAliasQry, cFilOrig, cRomaneio, nQtdVinc, nVlrFinN9K, lEmbarque, dDataBL)
	
	Local cDataVcto := ""
	Local cDataOrig := ""
	Local dData     := nil
	Local cNewPrev  := (cAliasQry)->SEQ_PREVISAO //não muda para os tipos de pagamento diferente de evento
    Local cNewN9J   := (cAliasQry)->SEQ_RELAC 

	Default lEmbarque := .F.
	Default dDataBL   := NIL
	
	If (cAliasQry)->REFCTR == '1'     //data de faturamento			
		dData := dDataBase
	ElseIf (cAliasQry)->REFCTR == '2' .AND. lEmbarque .AND. !empty(dDataBL)    //data de BL	
	    dData := dDataBL

	ElseIf (cAliasQry)->REFCTR == '4' //data de chegada
		dData := Posicione("NJJ",1,xFilial("NJJ",cFilOrig)+cRomaneio,"NJJ_DATCHE")
	EndIf

	If dData != nil
		cAntPos := (cAliasQry)->ANTPOS
		nNrDias := (cAliasQry)->NUMDIAS
		cTipVct := (cAliasQry)->TIPVCT
		nDiaMes := (cAliasQry)->DIAMES
	
		dData := OGX18GtDtV(cAntPos, nNrDias, cTipVct, nDiaMes, dData)
		
		If ValType(dData) == "D"
			
			cDataVcto := dtos(dData)			
			//verificamos a necessidade de criar novo PR			
            OGX120BREAK((cAliasQry)->N9J_FILIAL, (cAliasQry)->N9J_CODCTR, (cAliasQry)->N9J_ITEMPE, (cAliasQry)->N9J_ITEMRF, (cAliasQry)->SEQ_CONDPGTO, (cAliasQry)->SEQ_PREVISAO, (cAliasQry)->SEQ_RELAC, nQtdVinc, stod(cDataVcto), @cNewN9J, @cNewPrev)
		Else
			cDataVcto := (cAliasQry)->VENCIMENTO		
		EndIf
		
	Else
		cDataVcto := (cAliasQry)->VENCIMENTO
	EndIf	
	
	cDataOrig := cDataVcto
	
	If stod(cDataVcto) <= dDataBase
		cDataVcto := dtos(dDataBase)
	EndIf

Return {cDataVcto, cDataOrig, cNewPrev }

/*/{Protheus.doc} fDeleteNN7
//TODO Descrição auto-gerada.
@author jean.schulze
@since 03/07/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilCtr, characters, descricao
@param cCodCtr, characters, descricao
@param cItemNN7, characters, descricao
@param nQtdAbat, numeric, descricao
@param nValorAbat, numeric, descricao
@type function
/*/
static function fDeleteNN7(cFilCtr, cCodCtr, cItemNN7, nQtdAbat, nValorAbat, cTipoCan, nVlrCanc)
	Local lRet := .f.
	
	DbSelectArea("NN7")	
	NN7->(dbSetOrder(1))
	NN7->(dbGoTop())
	if 	NN7->(dbSeek(cFilCtr+cCodCtr+cItemNN7))
		RecLock('NN7',.f.)
			if cTipoCan == "D"
				NN7->NN7_VLDEVL  += nVlrCanc	
				NN7->NN7_QTDE    -= nQtdAbat
				NN7->NN7_VALOR   -= nVlrCanc				
				NN7->NN7_STSTIT  = "2"
			else
				//verifica se devemos deletar
				if NN7->NN7_QTDE - nQtdAbat <= 0
					//verifica se tem algum valor compensado --- 
					NN7->NN7_STSTIT = "3"
				else //somente update 
					NN7->NN7_QTDE  -= nQtdAbat
					NN7->NN7_STSTIT = "2"
				endif	
			endif
		NN7->(MsUnLock())
		lRet := .t.
	endif
	
return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} OGX120RACP
Retorna valor total utilizado (compensado) de uma RA para um contrato.
@author  rafael.voltz
@since   10/07/2018
@version version
/*/
//-------------------------------------------------------------------
Function OGX120RACP(cFilOrg, cContrato, cNum, cParcela, cPrefix, cTipo)
 	Local cAliasN9M     := GetNextAlias()
 	Local cQuery        := ""
	Local nRAComp       := 0

	cQuery := "SELECT ISNULL(SUM(N9M.N9M_VALCOM),0) SOMA"                     
	cQuery +=  " FROM " + RetSqlname("N9M") + " N9M "			
	cQuery += " INNER JOIN " +  RetSqlname("N9K") + " N9K ON "				
	cQuery += " N9K_CODCTR = N9M_CODCTR "
	cQuery += " AND N9M_FILIAL = N9K_FILIAL "
	cQuery += " AND N9K_NUM = N9M_NUM "
	cQuery += " AND N9K_PREFIX = N9M_PREFIX "
	cQuery += " AND N9K_PARCEL = N9M_PARCEL "
	cQuery += " AND N9K.D_E_L_E_T_ = N9M.D_E_L_E_T_ "		
	cQuery += " WHERE N9M.D_E_L_E_T_ = '' "
	cQuery += " AND N9M_FILIAL  = '" + xFilial("N9M") + "'" 
	cQuery += " AND N9M_NUMC     = '" + cNum      + "'"   
	cQuery += " AND N9M_PARCEC   = '" + cParcela  + "'"   
	cQuery += " AND N9M_PREFIC   = '" + cPrefix   + "'"   
	cQuery += " AND N9M_TIPOC    = '" + cTipo     + "'"   
	cQuery += " AND N9M_FILTIC   = '" + cFilOrg   + "'"   							
	cQuery += " AND N9M_CODCTR   = '" + cContrato + "'"										

	cQuery := ChangeQuery( cQuery )	

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasN9M,.T.,.T.)

	nRAComp := (cAliasN9M)->SOMA 	

	(cAliasN9M)->(dbCloseArea())	

Return nRAComp

//-------------------------------------------------------------------
/*/{Protheus.doc} OGX120RAVC
Retorna valor vinculado a uma RA e contrato.
@author  rafael.voltz
@since   10/07/2018
@version version
/*/
//-------------------------------------------------------------------
Function OGX120RAVC(cFilOrg, cContrato, cNum, cParcela, cPrefix, cTipo, cItemPrv)
 	Local cAliasN9G     := GetNextAlias()
 	Local cQuery        := ""
	Local nVincRA       := 0

	//Busco o valor vinculado por Previsão
	cQuery := "SELECT SUM(N9G_VALOR) RASOMA "                     
	cQuery +=  " FROM " + RetSqlname("N9G") + " N9G "			
	cQuery += " WHERE N9G.D_E_L_E_T_ = '' "
	cQuery += " AND N9G_FILIAL   = '" + xFilial("N9G") + "'" 
	cQuery += " AND N9G_CODCTR   = '" + cContrato + "'"				
	//cQuery += " AND N9G_ITEMPV   = '" + cItemPrv  + "'" 
	cQuery += " AND N9G_NUM      = '" + cNum      + "'"   
	cQuery += " AND N9G_PARTT    = '" + cParcela  + "'"   
	cQuery += " AND N9G_PREFIX   = '" + cPrefix   + "'"   
	cQuery += " AND N9G_TIPO     = '" + cTipo     + "'"   
	cQuery += " AND N9G_FILTIT   = '" + cFilOrg   + "'"   

	cQuery := ChangeQuery( cQuery )

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasN9G,.T.,.T.)	

	nVincRA := (cAliasN9G)->RASOMA

	(cAliasN9G)->(dbCloseArea())	

Return nVincRA


//-------------------------------------------------------------------
/*/{Protheus.doc} OGX120BREAK
Função de Quebra da N9J
***************************  A T E N Ç Ã O **************************
*************** APÓS A QUEBRA A FUNÇÃO CHAMADORA DEVE *************** 
*************** EXECUTAR O OGX018 PARA RECÁLCULO DAS  *************** 
*************** PREVISÕES FINANCEIRAS                 *************** 
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Function OGX120BREAK(cFilCtr, cCodCtr, cItemPE, cItemRF, cSeqCP, cSeqPF, cSeq, nVolume, dDtVcto, cNewSeqN9J, cNewSeqNN7)
 Local lRet       := .T.
 Local nPercent   := ""
 Local nTaxa      := ""  
 Local cFilOrg    := ""
 Local cNaturez   := ""
 Local cContob    := ""
 Local nMoeda     := 1
 Local nRecnoN9J  := 0 
 Local aAreaN9J   := N9J->(GetArea())
 Local aAreaNN7   := NN7->(GetArea())
 Local cAliasN9J  := N9J->(GetNextAlias()) 
 
 N9J->(dbSetOrder(1))
 NN7->(dbSetOrder(1))
 If N9J->(dbSeek(cFilCtr + cCodCtr + cItemPE + cItemRF + cSeqCP + cSeqPF + cSeq))        
    If nVolume > N9J->N9J_QTDE
        lRet := .F.
    Else    
        
        nPercent := N9J->N9J_PERCEN                
        
        /* ATUALIZA DADOS DA NN7 ATUAL */
        If NN7->(dbSeek(cFilCtr + cCodCtr + cSeqPF ))
            cFilOrg  := NN7->NN7_FILORG
            cNaturez := NN7->NN7_NATURE
            cContob  := NN7->NN7_CONTOB
            nMoeda   := NN7->NN7_MOEDA 
            nTaxa    := NN7->NN7_VLRTAX         

            If RecLock("NN7", .F.)
                NN7->NN7_QTDE   -= nVolume
                NN7->NN7_SLDQTD -= nVolume
                NN7->NN7_STSTIT := "2"                
                NN7->(MsUnLock())
            EndIf
        EndIf 

        /* ATUALIZA DADOS DA N9J ATUAL */
        If Reclock("N9J", .F.)
            N9J->N9J_QTDEVT += nVolume
            N9J->N9J_QTDE   -= nVolume
            N9J->N9J_SLDQTD -= nVolume

            N9J->(MsUnLock())
        EndIf   

        /* VERIFICO SE JÁ EXISTE N9J OU NN7 PARA A DATA EM QUESTÃO */
		If N9J->(ColumnPos('N9J_TIPEVE')) > 0 //na versao 23 este campo não existe
			
			BeginSql Alias cAliasN9J
				SELECT R_E_C_N_O_ RECNO, N9J_SEQPF
				FROM %table:N9J% N9J 
				WHERE N9J.N9J_FILIAL = %Exp:cFilCtr%
				AND N9J.N9J_CODCTR = %Exp:cCodCtr%
				AND N9J.N9J_ITEMPE = %Exp:cItemPE%
				AND N9J.N9J_ITEMRF = %Exp:cItemRF%
				AND N9J.N9J_SEQCP  = %Exp:cSeqCP%               
				AND N9J.N9J_VENCIM = %Exp:dDtVcto%     
				AND N9J.N9J_TIPEVE = "1" //Evento          
				AND N9J.%notDel%
			EndSql

			if (cAliasN9J)->(!Eof())
				nRecnoN9J  := (cAliasN9J)->RECNO
				cNewSeqNN7 := (cAliasN9J)->N9J_SEQPF
			endif
			
			(cAliasN9J)->(dbCloseArea())
			
			/* CASO JÁ EXISTA N9J, INCREMENTO VOLUMES NA N9J E NN7. VALORES SÃO ATUALIZADOS NO OGX018 */
			If !Empty(nRecnoN9J)
				N9J->(dbGoTo(nRecnoN9J))            
				
				cNewSeqN9J := N9J->N9J_SEQ                
				
				If RecLock("N9J",.F.) 
					N9J->N9J_QTDE += nVolume                                                
					N9J->(MsUnLock())
				EndIf            
				
				If NN7->(DbSeek(cFilCtr + cCodCtr +  cNewSeqNN7))                
					If RecLock("NN7",.F.) 
						NN7->NN7_QTDE += nVolume                
						NN7->(MsUnLock())
					EndIf
				EndIf
				
			Else            
				/* CRIA NOVA N9J E NN7 */
				cNewSeqN9J := fGetSeqN9J(cFilCtr, cCodCtr, cItemPE, cItemRF, cSeqCP, cSeqPF)
				cNewSeqNN7 := fGetSeqNN7(cFilCtr, cCodCtr)
				cNewParc   := StrZero( val(cNewSeqNN7), TamSX3( "NN7_PARCEL" )[1] )
				
				If RecLock("N9J",.T.) 
					N9J->N9J_FILIAL := cFilCtr
					N9J->N9J_CODCTR := cCodCtr
					N9J->N9J_ITEMPE := cItemPE
					N9J->N9J_ITEMRF := cItemRF
					N9J->N9J_SEQCP  := cSeqCP
					N9J->N9J_SEQPF  := cNewSeqNN7
					N9J->N9J_SEQ    := cNewSeqN9J
					N9J->N9J_VALOR  := 0            //valor será recálculado pela OGX018
					N9J->N9J_VENCIM := dDtVcto
					N9J->N9J_DTATUA := dDatabase
					N9J->N9J_PERCEN := nPercent
					N9J->N9J_QTDE   := nVolume
					N9J->N9J_VLRTAX := nTaxa
					N9J->N9J_SLDQTD := 0                          
					N9J->N9J_VLRFIX := 0            //valor será recálculado pela OGX018  
					N9J->N9J_VLFCON := 0            //valor será recálculado pela OGX018
					N9J->N9J_QTDEVT := 0            //Não utilizado, pois novo registro já é um evento.
					N9J->N9J_TIPEVE := "1" //Evento
					N9J->(MsUnLock())
				EndIf

				If RecLock("NN7",.T.) 
					NN7->NN7_FILIAL := cFilCtr 
					NN7->NN7_CODCTR := cCodCtr 
					NN7->NN7_ITEM   := cNewSeqNN7
					NN7->NN7_PARCEL := cNewParc
					NN7->NN7_DTVENC := dDtVcto
					NN7->NN7_FILORG := cFilOrg            
					NN7->NN7_STSTIT := "0"          //por evento nao deve atualizar SE1, somente após confirmar romaneio
					NN7->NN7_MOEDA  := nMoeda
					NN7->NN7_VLRTAX := nTaxa                
					NN7->NN7_VALOR  := 0            //valor é feito depois
					NN7->NN7_QTDE   := nVolume                
					NN7->NN7_TIPEVE := "1" //Evento	                 
					NN7->NN7_NATURE := cNaturez
					NN7->(MsUnLock())
				EndIf
			EndIf
		EndIf
    EndIf
 EndIf

 RestArea(aAreaN9J)
 RestArea(aAreaNN7)
/*
**************************  A T E N Ç Ã O **************************
*************** APÓS A QUEBRA,A FUNÇÃO CHAMADORA DEVE*************** 
*************** EXECUTAR O OGX018 PARA RECÁLCULO DAS *************** 
*************** PREVISÕES FINANCEIRAS                *************** 
*/

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetSeqN9J
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function fGetSeqN9J(cFilCtr, cCodCtr, cItemPE, cItemRF, cSeqCP, cSeqPF)
 Local cAliasN9J := GetNextAlias()
 Local cNewSeq   := ""

 BeginSql Alias cAliasN9J
    SELECT Max(N9J_SEQ) N9J_SEQ
      FROM %table:N9J% N9J
     WHERE N9J.N9J_FILIAL = %Exp:cFilCtr%
       AND N9J.N9J_CODCTR = %Exp:cCodCtr%
       AND N9J.N9J_ITEMPE = %Exp:cItemPE%
       AND N9J.N9J_ITEMRF = %Exp:cItemRF%
       AND N9J.N9J_SEQCP  = %Exp:cSeqCP%       
       AND N9J.%notDel%   
 EndSql

 if (cAliasN9J)->(!Eof())
    cNewSeq := (cAliasN9J)->N9J_SEQ
 EndIf
 
 (cAliasN9J)->(dbCloseArea())

 If Empty(cNewSeq)
    cNewSeq := StrZero( 1, TamSX3( "N9J_SEQ" )[1] )
 Else
    cNewSeq := soma1(cNewSeq)
 EndIf 

Return cNewSeq

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetSeqNN7
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function fGetSeqNN7(cFilCtr, cCodCtr)
 Local cAliasNN7 := GetNextAlias()
 Local cNewSeq   := ""

 BeginSql Alias cAliasNN7
    SELECT Max(NN7_ITEM) NN7_ITEM
      FROM %table:NN7% NN7
     WHERE NN7.NN7_FILIAL = %Exp:cFilCtr%
       AND NN7.NN7_CODCTR = %Exp:cCodCtr%       
       AND NN7.%notDel%   
 EndSql

 if (cAliasNN7)->(!Eof())
    cNewSeq := (cAliasNN7)->NN7_ITEM
 EndIf
 
 (cAliasNN7)->(dbCloseArea())

 If Empty(cNewSeq)
    cNewSeq := StrZero( 1, TamSX3( "NN7_ITEM" )[1] )
 Else
    cNewSeq := soma1(cNewSeq)
 EndIf 

Return cNewSeq

//-------------------------------------------------------------------
/*/{Protheus.doc} fDeleteN9J
Delete das N9J geradas por evento.
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function fDeleteN9J(cFilCtr, cCodCtr, cPrevEnt, cRegraFis, cSeqCP, cSeqPF, nQtdAbat, cTipoCan)
 
 Local aAreaN9J := N9J->(GetArea())
 
 N9J->(DbSetOrder(1))
 If N9J->(DbSeek(cFilial + cCodCtr + cPrevEnt + cRegraFis + cSeqCP + cSeqPF))
    RecLock("N9J", .F.)
    if N9J->N9J_QTDE - nQtdAbat <= 0 .AND. cTipoCan != 'D' //NÃO APAGAR QDO DEVOL.
        N9J->(dbDelete())
    Else        
        N9J->N9J_QTDE -= nQtdAbat
    EndIf
    N9J->(MsUnLock()) 
 EndIf

 RestArea(aAreaN9J) 

Return 
