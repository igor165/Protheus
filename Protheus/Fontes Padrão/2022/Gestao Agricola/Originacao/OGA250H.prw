#include 'protheus.ch'
#include 'parmtype.ch'

/*{Protheus.doc} OG250HGVRF
Grava a tabela de Remessa Formação de Lote (N9I)

@author francisco.nunes
@since 25/04/2018
@param cCodRom, character, Código do romaneio
@type function
*/
Function OG250HGVRF(cCodRom)

	Local aAreaNJM := NJM->(GetArea())
	Local aAreaN8K := N8K->(GetArea())
	Local aAreaSD2 := SD2->(GetArea())
	Local nTpCtrIE := ""
	Local cSeqN9I  := ""
	Local cSeqInic := ""
	Local aStruct  := {}
	Local nPos	   := 0
	Local lAlgodao := AGRTPALGOD(NJJ->NJJ_CODPRO) 
	Local nQtde    := 0
	
	DbSelectArea("N9I")
	aStruct := N9I->(dBStruct())
	
	If (nPos := aScan(aStruct, {|x| AllTrim(x[1]) == "N9I_ITEFLO" })) > 0
		cSeqInic := StrZero(1, aStruct[nPos][3])
	EndIf
	
	DbSelectArea("N8K")
	N8K->(DbSetOrder(2)) // N8K_FILIAL+N8K_CODROM+N8K_ITEROM
	If N8K->(DbSeek(FWxFilial("NJM")+cCodRom))
		While !N8K->(Eof()) .AND. N8K->(N8K_FILIAL+N8K_CODROM) == FWxFilial("NJM")+cCodRom
			
			DbSelectArea("NJM")
			NJM->(DbSetOrder(1)) // NJM_FILIAL+NJM_CODROM+NJM_ITEROM
			If !NJM->(DbSeek(N8K->(N8K_FILIAL+N8K_CODROM+N8K_ITEROM)))
				Return .F.
			EndIf
			
			nTpCtrIE := Posicione("N7Q",1,FWxFilial("N7Q")+NJM->NJM_CODINE,"N7Q_TPCTR") // 1=Venda;2=Armazenagem
			
			DbSelectArea("SD2")
			SD2->(DbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			If !SD2->(DbSeek(FWxFilial("SD2")+N8K->N8K_DOC+N8K->N8K_SERIE+N8K->N8K_CLIFOR+N8K->N8K_LOJA+N8K->N8K_PRODUT+N8K->N8K_ITEDOC))
				Return .F.
			EndIf
												
			cAliasQry := GetNextAlias()
			cQry := " SELECT N9I.N9I_ITEFLO "
			cQry += "   FROM " + RetSqlName("N9I") + " N9I "
			cQry += "  WHERE N9I.N9I_FILIAL = '"+ FWxFilial("N9I") +"' "   
			cQry += "    AND N9I.N9I_DOC    = '"+ N8K->N8K_DOC +"' "   
			cQry += "    AND N9I.N9I_SERIE  = '"+ N8K->N8K_SERIE +"' "
			cQry += "    AND N9I.N9I_CLIFOR = '"+ N8K->N8K_CLIFOR +"' "
			cQry += "    AND N9I.N9I_LOJA   = '"+ N8K->N8K_LOJA +"' "
			cQry += "    AND N9I.N9I_ITEDOC = '"+ N8K->N8K_ITEDOC +"' "
			cQry += "    AND N9I.N9I_ITEFLO IN (SELECT MAX(N9I2.N9I_ITEFLO) "
			cQry += "	                     	  FROM " + RetSqlName("N9I") + " N9I2 "
			cQry += "							 WHERE N9I2.N9I_FILIAL = N9I.N9I_FILIAL "   
			cQry += "    						   AND N9I2.N9I_DOC    = N9I.N9I_DOC "   
			cQry += "    						   AND N9I2.N9I_SERIE  = N9I.N9I_SERIE "
			cQry += "   						   AND N9I2.N9I_CLIFOR = N9I.N9I_CLIFOR "
			cQry += "    						   AND N9I2.N9I_LOJA   = N9I.N9I_LOJA "
			cQry += "    						   AND N9I2.N9I_ITEDOC = N9I.N9I_ITEDOC "
			cQry += "		                  	   AND N9I2.D_E_L_E_T_ = '' ) "				
			cQry := ChangeQuery(cQry)	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.F.,.T.)
			
			dbSelectArea(cAliasQry)
			(cAliasQry)->(DbGoTop())
			
			If !(cAliasQry)->(Eof())
				cSeqN9I := Soma1((cAliasQry)->N9I_ITEFLO)
			Else
				cSeqN9I := cSeqInic
			EndIf
			(cAliasQry)->(dbCloseArea())
			
			// Informar o contrato, cadência e regra fiscal de venda na N9I
			IF nTpCtrIE == '1' 
				
				cAliasQry2 := GetNextAlias()
				
				IF lAlgodao //Venda
					cQuery := " SELECT N9D2.N9D_CODCTR AS CODCTR, N9D2.N9D_ITEETG AS ITEETG, N9D2.N9D_ITEREF AS ITEREF, SUM(N9D.N9D_PESFIM) AS QUANT "                                                                          
					cQuery += " FROM " + RetSqlName('N9D')+ " N9D "
					
					cQuery += " INNER JOIN " + RetSqlName("N9D") + " N9D2 ON N9D2.N9D_FILIAL = N9D.N9D_FILIAL AND N9D2.N9D_SAFRA = N9D.N9D_SAFRA AND N9D2.N9D_FARDO = N9D.N9D_FARDO "
					cQuery += " AND N9D2.N9D_FILORG = '" + NJM->NJM_FILORG + "' AND N9D2.N9D_CODINE = '" + NJM->NJM_CODINE  + "' "
					cQuery += " AND N9D2.N9D_TIPMOV = '04' AND N9D2.N9D_STATUS = '2' AND N9D2.D_E_L_E_T_ = '' "
					
					cQuery += " WHERE N9D.D_E_L_E_T_ = '' "
					cQuery += "   AND N9D.N9D_FILORG = '" + NJM->NJM_FILIAL  + "' "
					cQuery += "   AND N9D.N9D_CODROM = '" + NJM->NJM_CODROM  + "' "
					cQuery += "   AND N9D.N9D_CODCTR = '" + NJM->NJM_CODCTR  + "' "
					cQuery += "   AND N9D.N9D_ITEETG = '" + NJM->NJM_ITEM    + "' "
					cQuery += "   AND N9D.N9D_ITEREF = '" + NJM->NJM_SEQPRI  + "' "			
					cQuery += "   AND N9D.N9D_TIPMOV = '07' " 
					cQuery += "   AND N9D.N9D_STATUS = '2' "
					
					cQuery += " GROUP BY N9D2.N9D_CODCTR, N9D2.N9D_ITEETG, N9D2.N9D_ITEREF "
				Else
				  cQuery := " SELECT N7S_CODCTR AS CODCTR, N7S_ITEM AS ITEETG, N7S_SEQPRI AS ITEREF, (N7S_QTDVIN - N7S_QTDREM) AS QUANT " 
				  cQuery += " FROM " + RetSqlName('N9E')+ " N9E "
				  cQuery += " INNER JOIN " + RetSqlName('N7S')+ " N7S ON N7S.D_E_L_E_T_ = ' ' AND N7S.N7S_FILIAL = N9E.N9E_FILIE AND N7S.N7S_CODINE = N9E.N9E_CODINE "
				  cQuery += "   AND N7S.N7S_FILORG = '" + NJM->NJM_FILIAL  + "' "
				  cQuery += " WHERE N9E.N9E_FILIAL = '" + NJM->NJM_FILIAL  + "' "
			      cQuery += "   AND N9E.N9E_CODROM = '" + NJM->NJM_CODROM  + "' "
				  cQuery += "   AND N9E.D_E_L_E_T_ = ' '"
				EndIf
				
				cQuery := ChangeQuery(cQuery)						
				DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry2,.T.,.T.)
		
				nSaldo := SD2->D2_QUANT
				
				DbSelectArea(cAliasQry2)  
				(cAliasQry2)->(DbGoTop())
				If (cAliasQry2)->(!Eof())
					While (cAliasQry2)->(!Eof()) .And. nSaldo > 0
					
						nQtde  := IIF(nSaldo < (cAliasQry2)->QUANT, nSaldo, (cAliasQry2)->QUANT  )
						nSaldo -= nQtde 
						
						//Cria registro N9I - Venda
						If nQtde > 0
						 	InsN9I(cSeqN9I, nTpCtrIE, nQtde )
						 	
						 	// SE FOR REMESSA PARA FORMAÇÃO LOTE COM IE DE VENDA
							If !lAlgodao // GRÃOS
								// Atualiza a quantidade remetida das entregas da IE
								If !ConsRemIE(1, NJM->NJM_FILORG, NJM->NJM_CODINE, nQtde, .T., (cAliasQry2)->CODCTR, (cAliasQry2)->ITEETG, (cAliasQry2)->ITEREF)
									Return .F.
								EndIf
							EndIf
							
							cSeqN9I := Soma1(cSeqN9I)
						EndIf
						 
						(cAliasQry2)->(DbSkip())
					EndDo
				EndIf
				(cAliasQry2)->(dbCloseArea())
			Else //Cria registro N9I - Armazenagem
				 InsN9I(cSeqN9I, nTpCtrIE,SD2->D2_QUANT)
			EndIf
			
			N8K->(DbSkip())
		EndDo			
	EndIf	
	
	RestArea(aAreaNJM)
	RestArea(aAreaN8K)
	RestArea(aAreaSD2)
	
Return .T.

/** {Protheus.doc} OG250HTRIE
Gravação da tabela M9I
@return:	Nil
@author: 	tamyris.g
@since: 	25/05/2018
@param		nTpCtrIE, char, Tipo Romaneio
@param		nQtdFis , num , Quantidade fiscal
@Uso: 		OGA250 
*/
Static Function InsN9I(cSeqN9I, nTpCtrIE, nQtdFis)
	
	If RecLock("N9I", .T.)
		N9I->N9I_FILIAL := FWxFilial("N9I")
		N9I->N9I_DOC 	:= N8K->N8K_DOC
		N9I->N9I_SERIE  := N8K->N8K_SERIE
		N9I->N9I_CLIFOR := N8K->N8K_CLIFOR
		N9I->N9I_LOJA   := N8K->N8K_LOJA
		N9I->N9I_ITEDOC := N8K->N8K_ITEDOC
		N9I->N9I_CODROM := N8K->N8K_CODROM
		N9I->N9I_ITEFLO := cSeqN9I
		N9I->N9I_ITEROM := N8K->N8K_ITEROM
		N9I->N9I_CODPRO := N8K->N8K_PRODUT
		N9I->N9I_TPPROD := N8K->N8K_TPPROD
		N9I->N9I_LOTCTL := SD2->D2_LOTECTL
		N9I->N9I_NUMLOT := SD2->D2_NUMLOTE
		N9I->N9I_DTVALI := SD2->D2_DTVALID
		N9I->N9I_LOCAL  := NJM->NJM_LOCAL
		N9I->N9I_DEPALF := Posicione("NJ0",1,FWxFilial("NJ0")+NJM->NJM_CODENT+NJM->NJM_LOJENT,"NJ0_DEPALF")
		N9I->N9I_CODENT := NJM->NJM_CODENT
		N9I->N9I_LOJENT := NJM->NJM_LOJENT
		N9I->N9I_QTDFIS := nQtdFis
		N9I->N9I_DOCEMI := SD2->D2_EMISSAO							
		N9I->N9I_QTDSLR := N9I->N9I_QTDFIS
		N9I->N9I_INDSLD := IIf(nTpCtrIE == "2","0","1") // 0=Saldo; 1=Vinculado IE;2=Vinculado Contêiner
		N9I->N9I_INDRET := "0" // 0=Saldo; 1=Vinculado Retorno
		N9I->N9I_FILORG := NJM->NJM_FILORG
		N9I->N9I_CODINR := NJM->NJM_CODINE			
		N9I->N9I_DESINR := Posicione("N7Q", 1 , xFilial("N7Q")+NJM->NJM_CODINE,"N7Q_DESINE")	
		N9I->N9I_CTRREM := NJM->NJM_CODCTR
		N9I->N9I_ETGREM := NJM->NJM_ITEM
		N9I->N9I_REFREM := NJM->NJM_SEQPRI
		N9I->N9I_CODINE := IIf(nTpCtrIE == "1",NJM->NJM_CODINE,"")		
		N9I->N9I_DESINE := IIf(nTpCtrIE == "1",Posicione("N7Q", 1 , xFilial("N7Q")+NJM->NJM_CODINE,"N7Q_DESINE"), "")					
		If nTpCtrIE == '1'
			N9I->N9I_CODCTR := (cAliasQry2)->CODCTR
			N9I->N9I_ITEM   := (cAliasQry2)->ITEETG
			N9I->N9I_SEQPRI := (cAliasQry2)->ITEREF
		EndIF
						
		N9I->(MsUnlock())
	EndIf
			
Return .T.

/** {Protheus.doc} OG250HTRIE
Atualiza data de chegada tabela relacionada remessa formação de lote x IE

@return:	Nil
@author: 	vanilda.moggio
@since: 	24/04/2018
@param		cFilRom, char, Filial do Romaneio
@param		cCodRom, char, Código do Romaneio
@param      dtCheg, date , data de chegada do romaneio
@Uso: 		OGA250 
*/
Function OG250HTRIE(cFilRom, cCodRom, dtCheg)

	DbSelectArea("N9I")				
	N9I->(DbSetOrder(2)) // N9I_FILIAL+N9I_CODROM+N9I_ITEROM
	If N9I->(DbSeek(cFilRom+cCodRom))
	    While !N9I->(Eof()) .AND. N9I->(N9I_FILIAL+N9I_CODROM) == cFilRom+cCodRom															
			If RecLock("N9I", .F.)
	           N9I->N9I_DATCHE :=  dtCheg
	           
	           N9I->(MsUnlock())
			EndIf
						
			N9I->(DbSkip())			
		EndDo	
	EndIf	
	
	N9I->(dbCloseArea())	
Return .T.

/** {Protheus.doc} OG250HCN9I
ELIMINA RELACIONAMENTO REMESSA X IE (N91)

@param: 	cFilRom, character, Filial do Romaneio
@param: 	cCodRom, character, Código do Romaneio
@param: 	cItRom, character, Item da comercialização do Romaneio
@return:	Nil
@author: 	Vanilda.moggio
@since: 	20/04/2018
@Uso: 		SIGAAGR 
*/
Function OG250HCN9I(cFilRom, cCodRom, cItRom)

 
	nTpCtrIE := Posicione("N7Q",1, NJM->NJM_FILORG+NJM->NJM_CODINE,"N7Q_TPCTR") // 1=Venda;2=Armazenagem
	
	DbSelectArea("N9I")				
	N9I->(DbSetOrder(2)) //FILIAL+CODROM+ITEM
	N9I->(DbSeek(cFilRom+cCodRom+cItRom))
	While !N9I->(Eof()) .AND. N9I->(N9I_FILIAL+N9I_CODROM+N9I_ITEROM) == cFilRom+cCodRom+cItRom															
		If RecLock('N9I',.F.)
			N9I->(dbDelete())
			N9I->(MsUnlock())
		EndIf
		
		// SE FOR REMESSA PARA FORMAÇÃO LOTE COM IE DE VENDA
		If !AGRTPALGOD(NJM->NJM_CODPRO) .And. nTpCtrIE = '1'  
			// Atualiza a quantidade remetida das entregas da IE
			If !ConsRemIE(1, NJM->NJM_FILORG, NJM->NJM_CODINE, N9I->N9I_QTDFIS, .F.,N9I->N9I_CODCTR,N9I->N9I_ITEM,N9I->N9I_SEQPRI)
				Return .F.
			EndIf
		EndIf
	
		N9I->(DbSkip())		
	EndDo			
	
	N9I->(dbCloseArea())
	
	
							
	
Return .T.

/** {Protheus.doc} OG250DRN9I
Atualiza o consumo no retorno da formação de lote

@param:   cFilRom, character, Filial do Romaneio
@param:   cCodRom, character, Código do Romaneio
@param:   lAtuc, logical, .T. - Atualização; .F. - Reabrir
@return:  Nil
@author:  francisco.nunes
@since:   11/04/2018
@Uso: 	  SIGAAGR 
*/
Function OG250HRN9I(cFilRom, cCodRom, lAtuc)
	Local aAreaN9E := N9E->(GetArea())
	Local cIndSld  := ""
	Local nQtdRet  := 0	
	Local cChave   := ""
					
	DbSelectArea("N9E")
	N9E->(DbSetOrder(3)) // N9E_FILIAL+N9E_CODROM+N9E_ORIGEM
	If N9E->(DbSeek(cFilRom+cCodRom+"7"))
		While N9E->(!Eof()) .AND. N9E->(N9E_FILIAL+N9E_CODROM+N9E_ORIGEM) == cFilRom+cCodRom+"7"
			
			If Empty(N9E->N9E_CODINE)
				// 0 - Saldo
				cIndSld := "0" 
			Else
				// 1 - Vinculado a IE; 2 - Vinculado a container
				cIndSld := IIf(Posicione("N7Q",1,N9E->N9E_FILIE+N9E->N9E_CODINE,"N7Q_TPMERC") == "1", "1", "2")
			EndIf
			
			nQtdRet := N9E->N9E_QTDRET
			
			// Vinculado a container
			If cIndSld == "2" 
				cChave := cFilRom+N9E->N9E_DOC+N9E->N9E_SERIE+N9E->N9E_CLIFOR+N9E->N9E_LOJA+N9E->N9E_ITEDOC+"2"+N9E->N9E_FILIE+N9E->N9E_CODINE
				
				AtuRetN9I("2", cChave, @nQtdRet, lAtuc)
			EndIf
		
			// Vinculado a IE OU Vinculado a container e com saldo a retornar
			// Caso seja exportação (cIndSld == "2"), buscou o vinculo com o containers para consumir o saldo retornado (nQtdRet)
			// e não zerou o saldo, será feito a busca do vínculo com a IE com quant ant (estufagem antecipada)			
			If cIndSld == "1" .Or. (cIndSld == "2" .AND. nQtdRet > 0) 
				cChave	:= cFilRom+N9E->N9E_DOC+N9E->N9E_SERIE+N9E->N9E_CLIFOR+N9E->N9E_LOJA+N9E->N9E_ITEDOC+"1"+N9E->N9E_FILIE+N9E->N9E_CODINE
				
				AtuRetN9I("1", cChave, @nQtdRet, lAtuc)
			EndIf
			
			// Saldo						
			If cIndSld == "0"
				cChave	:= cFilRom+N9E->N9E_DOC+N9E->N9E_SERIE+N9E->N9E_CLIFOR+N9E->N9E_LOJA+N9E->N9E_ITEDOC+"0"
				
				AtuRetN9I("0", cChave, @nQtdRet, lAtuc)
			EndIf
										
			N9E->(DbSkip())			
		EndDo
	EndIf
	
	RestArea(aAreaN9E)
	
Return .T.

/** {Protheus.doc} AtuRetN9I
Atualiza o consumo no retorno da formação de lote

@param:   cIndSld, character, Indicador de saldo (0 - Saldo; 1 - Vinculado a IE; 2 - Vinculado a container)
@param:   cChave, character,  Chave para buscar os registros da N9I
@param:   nQtdRet, number, Quantidade a retornar
@param:   lAtuc, logical, .T. - Atualização; .F. - Reabrir
@return:  Nil
@author:  francisco.nunes
@since:   05/06/2018
@Uso: 	  SIGAAGR 
*/
Static Function AtuRetN9I(cIndSld, cChave, nQtdRet, lAtuc)
	
	Local cCmpsN9I := ""
	
	If cIndSld == "0"
		cCmpsN9I := "N9I->(N9I_FILIAL+N9I_DOC+N9I_SERIE+N9I_CLIFOR+N9I_LOJA+N9I_ITEDOC+N9I_INDSLD)"
	Else
		cCmpsN9I := "N9I->(N9I_FILIAL+N9I_DOC+N9I_SERIE+N9I_CLIFOR+N9I_LOJA+N9I_ITEDOC+N9I_INDSLD+N9I_FILORG+N9I_CODINE)"
	EndIf	

	DbSelectArea("N9I")				
	N9I->(DbSetOrder(5)) // N9I_FILIAL+N9I_DOC+N9I_SERIE+N9I_CLIFOR+N9I_LOJA+N9I_ITEDOC+N9I_INDSLD+N9I_FILORG+N9I_CODINE+N9I_CONTNR+N9I_CODCTR+N9I_ITEM+N9I_SEQPRI
	N9I->(DbSeek(cChave))
	While !N9I->(Eof()) .AND. &(cCmpsN9I) == cChave .AND. nQtdRet > 0
						
		If lAtuc												
			If RecLock('N9I',.F.)
				N9I->N9I_INDRET := "1" // Vinculado a retorno
				N9I->N9I_QTDRET += IIf(nQtdRet < N9I->N9I_QTDSLR, nQtdRet, N9I->N9I_QTDSLR)
				N9I->N9I_QTDSLR := N9I->N9I_QTDFIS - N9I->N9I_QTDRET
				N9I->(MsUnlock())
			EndIf
		Else
			If RecLock('N9I',.F.)							
				N9I->N9I_QTDRET -= IIf(nQtdRet < N9I->N9I_QTDRET, nQtdRet, N9I->N9I_QTDRET)
				N9I->N9I_QTDSLR := N9I->N9I_QTDFIS - N9I->N9I_QTDRET
				N9I->N9I_INDRET := IIf(N9I->N9I_QTDRET > 0, "1", "0")
				N9I->(MsUnlock())
			EndIf
		EndIf
		
		nQtdRet -= 	N9I->N9I_QTDRET		
		N9I->(DbSkip())			
	EndDo				

Return .T.
