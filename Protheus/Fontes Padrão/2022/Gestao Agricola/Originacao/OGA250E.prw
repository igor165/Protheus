#include 'protheus.ch'
#include 'parmtype.ch'

/** {Protheus.doc} OG250EMFR
Cria movto Fardos do tipo 07, com status 3, para ficar historico
no cancelamento da NF do romaneio

@return:	Nil
@author: 	vanilda.moggio 
@since: 	12/04/2018
@Uso: 		OGX165

*/
Function OG250EMFR(pcFilial, pcCodRom) 
	Local aFardos := {}
	Local aAux    := {}	
	Local aFrdSts := {}
	
	//Buscando as movimentações 
	DbSelectArea("N9D")
	N9D->(DbSetOrder(6))//N9D_FILIAL+N9D_CODROM+N9D_TIPMOV
	N9D->(DbGoTop())
	If N9D->(dbSeek( pcFilial+ pcCodRom + '07' ))
		While !N9D->(Eof()) .AND. pcFilial+ pcCodRom + '07' == N9D->N9D_FILIAL + N9D->N9D_CODROM + N9D->N9D_TIPMOV 
			
			If N9D->N9D_STATUS == "2" .AND. NJM->NJM_CODINE + NJM->NJM_CODCTR + NJM->NJM_SEQPRI == N9D->N9D_CODINE + N9D_CODCTR + N9D->N9D_ITEREF
			 
				aAux := {   {"N9D_FILIAL"	,pcFilial	     	},;
				 			 {"N9D_SAFRA"	,N9D->N9D_SAFRA		},;
							 {"N9D_FARDO"	,N9D->N9D_FARDO		},;
			 				 {"N9D_TIPMOV"	,N9D->N9D_TIPMOV	},;
			 				 {"N9D_PESINI"	,N9D->N9D_PESINI	},; //Peso dos fardos será alterado no rateio
			 				 {"N9D_PESFIM"	,N9D->N9D_PESFIM    },;
			 				 {"N9D_PESDIF"	,N9D->N9D_PESFIM - N9D->N9D_PESINI },;
			 				 {"N9D_STATUS"	, "3"               },;
			 				 {"N9D_DATA"    ,N9D->N9D_DATA     	},;
			 				 {"N9D_CODROM"	,pcCodRom       	},;
			 				 {"N9D_TIPOPE"	,"1"				} }	 				 
			   
			    AADD(aFardos, aAux)		    
			    AADD(aFrdSts, { N9D->N9D_FILIAL, N9D->N9D_SAFRA, N9D->N9D_FARDO })
			    
		    EndIf
		    N9D->(DbSkip())
		     	   		  
		EndDo	
	
		//retorna(2) status do fardo na DXI(DXI_STATUS)
		AGRXFNSF( 2 , "RomanCancNF", aFrdSts ) //romaneio cancelamento NF - NF excluida 
		
		aRet    := AGRMOVFARD(aFardos, 1  )	//Inclui movimentação para o fardo
	
	EndIf
	 	 				 
Return .T.

/** {Protheus.doc} OG250EAQIE
Atualiza a quantidade instruída da IE na N7S / N7Q

Saída Venda Simples (romaneio)
Saída Remessa Venda Futura (romaneio)
Saída Venda Op. Triangular (romaneio)
Saída formação de lote (romaneio)
Chegada da formação de lote (chegada romaneio)
Na aprovação da certificação (instrução).

@return:	Nil
@author: 	francisco.nunes / vanilda.moggio
@since: 	13/04/2018
@param 		cTipMov, Char, tipo do movimento do fardo(N9D) 07-romaneio
@param		cFilEnt, char, Filial da IE / Romaneio
@param		cCodEnt, char, Código da IE / Romaneio
@Uso: 		OGA250 / OGA250C / OGA710 

*/
Function OG250EAQIE(cTipMov, cFilEnt, cCodEnt, lReabrir)	
	Local cQry 	    := ""
	Local cAliasQry := ""
	Local nPesBru   := 0
	Local nPesLiq   := 0
	
	Default lReabrir := .F. 
	
	If cTipMov == "07" //romaneio
		dbSelectArea( "NJM" )
		NJM->(DbSetOrder(1)) 
		If NJM->(DbSeek(cFilEnt + cCodEnt)) .AND. NJM->NJM_SUBTIP == "41" 
			//romaneio de subtipo 41-VENDA EXPORTAÇÃO não atualiza IE e regras fiscais
			//pois na certificação ja foi atualizada e o peso do romaneio é conforme peso da certificação que deve ser igual da IE
			Return .T.
		EndIf
	EndIf
	
	cAliasQry := GetNextAlias()
	cQry := " SELECT N9D2.N9D_FILIAL, "
	cQry += "		 N9D2.N9D_FILORG, "
	cQry += "		 N9D2.N9D_CODINE, "
	cQry += "        N9D2.N9D_BLOCO, "
	cQry += "		 N9D2.N9D_CODCTR AS IE_CODCTR, "  //CONTRATO DA IE
	cQry += "        N9D2.N9D_ITEETG AS IE_ITEETG, "
	cQry += "        N9D2.N9D_ITEREF AS IE_ITEREF, "
	cQry += "		 SUM(N9D.N9D_PESDIF) AS PSDIF,"
	cQry += "        N83.N83_QUANT AS QTDFRDIE, "
	cQry += "        N83.N83_PSBRUT AS PSBRUIE, "
	cQry += "        N83.N83_PSLIQU AS PSLIQIE, "
	cQry += "		 DXI.MEDBRUT_DXIDISP, "
	cQry += "		 DXI.MEDLIQU_DXIDISP, "
	cQry += "		 DXI2.QTD_DXIIE, "
	cQry += "		 DXI2.PSBRUT_DXIIE, "
	cQry += "		 DXI2.PSLIQU_DXIIE "		
	cQry += " FROM " + RetSqlName("N9D") + " N9D "
	cQry += " INNER JOIN " + RetSqlName("N9D") + " N9D2 ON N9D2.N9D_FILIAL = N9D.N9D_FILIAL AND N9D2.N9D_SAFRA = N9D.N9D_SAFRA "
	cQry += " AND N9D2.N9D_FARDO = N9D.N9D_FARDO AND N9D2.N9D_TIPMOV = '04' AND N9D2.N9D_STATUS = '2' AND N9D2.D_E_L_E_T_ = '' "		
	cQry += " INNER JOIN " + RetSqlName("N83") + " N83 ON N83.N83_FILIAL = N9D2.N9D_FILORG AND N83.N83_CODINE = N9D2.N9D_CODINE " 
	cQry += " AND N83.N83_CODCTR = N9D2.N9D_CODCTR AND N83.N83_ITEM = N9D2.N9D_ITEETG AND N83.N83_ITEREF = N9D2.N9D_ITEREF "
	cQry += " AND N83.N83_FILORG = N9D2.N9D_FILIAL AND N83.N83_BLOCO = N9D2.N9D_BLOCO AND N83.N83_SAFRA = N9D2.N9D_SAFRA AND N83.D_E_L_E_T_ = '' "
		
	// Busca a média do peso bruto e peso líquido dos fardos do bloco que estão disponiveis, sem IE vinculada (DXI.MEDBRUT_DXIDISP e DXI.MEDLIQU_DXIDISP)
	cQry += " LEFT OUTER JOIN (SELECT AVG(CASE WHEN DXI_PESCER > 0 THEN DXI_PESCER + DXI_PSTARA WHEN DXI_PESSAI > 0 THEN DXI_PESSAI + DXI_PSTARA WHEN DXI_PSESTO > 0 THEN DXI_PSESTO + DXI_PSTARA ELSE DXI_PSLIQU + DXI_PSTARA END)  AS MEDBRUT_DXIDISP, " 
	cQry += " 	AVG(CASE WHEN DXI_PESCER > 0 THEN DXI_PESCER WHEN DXI_PESSAI > 0 THEN DXI_PESSAI WHEN DXI_PSESTO > 0 THEN DXI_PSESTO ELSE DXI_PSLIQU END ) AS MEDLIQU_DXIDISP,  "
	cQry += " 	DXI_FILIAL, DXI_SAFRA, DXI_BLOCO, DXI.D_E_L_E_T_, N9D.N9D_CODCTR, N9D.N9D_ITEETG, N9D.N9D_ITEREF "
	cQry += " 	FROM " + RetSqlName("DXI") + " DXI "
	cQry += " INNER JOIN " + RetSqlName("N9D") + " N9D ON N9D_FILIAL = DXI_FILIAL AND N9D_SAFRA = DXI_SAFRA AND N9D_FARDO = DXI_ETIQ AND N9D_TIPMOV = '02' AND N9D.D_E_L_E_T_ = '' "
	cQry += " 	WHERE DXI.D_E_L_E_T_ = '' AND DXI_CODINE = '' " //para buscar media dos fardos que ainda estão disponiveis, sem IE
	cQry += " 	GROUP BY DXI_FILIAL, DXI_SAFRA, DXI_BLOCO, DXI.D_E_L_E_T_, N9D.N9D_CODCTR, N9D.N9D_ITEETG, N9D.N9D_ITEREF) "
	cQry += " 	DXI ON DXI.D_E_L_E_T_ = '' AND DXI.DXI_FILIAL = N9D.N9D_FILIAL AND DXI.DXI_SAFRA  = N9D.N9D_SAFRA AND DXI.DXI_BLOCO  = N9D.N9D_BLOCO "
	cQry += " 	AND DXI.N9D_CODCTR = N9D2.N9D_CODCTR AND DXI.N9D_ITEETG = N9D2.N9D_ITEETG AND DXI.N9D_ITEREF = N9D2.N9D_ITEREF "
	
	// Busca a qtd fardos e a soma do peso atual dos fardos na DXI com a IE para o bloco da IE(DXI2.QTD_DXIIE, DXI2.PSBRUT_DXIIE, DXI2.PSLIQU_DXIIE)
	cQry += " LEFT OUTER JOIN (SELECT COUNT(DXI_ETIQ) AS QTD_DXIIE, SUM(CASE WHEN DXI_PESCER > 0 THEN DXI_PESCER + DXI_PSTARA WHEN DXI_PESSAI > 0 THEN DXI_PESSAI + DXI_PSTARA WHEN DXI_PSESTO > 0 THEN DXI_PSESTO + DXI_PSTARA ELSE DXI_PSLIQU + DXI_PSTARA END)  AS PSBRUT_DXIIE, "  
	cQry += " 	SUM(CASE WHEN DXI_PESCER > 0 THEN DXI_PESCER WHEN DXI_PESSAI > 0 THEN DXI_PESSAI WHEN DXI_PSESTO > 0 THEN DXI_PSESTO ELSE DXI_PSLIQU END) AS PSLIQU_DXIIE, " 
	cQry += " 	DXI_FILIAL, DXI_SAFRA, DXI_BLOCO, DXI_CODINE, DXI.D_E_L_E_T_, N9D.N9D_CODCTR, N9D.N9D_ITEETG, N9D.N9D_ITEREF "           
	cQry += " 	FROM " + RetSqlName("DXI") + " DXI "
	cQry += " INNER JOIN " + RetSqlName("N9D") + " N9D ON N9D_FILIAL = DXI_FILIAL AND N9D_SAFRA = DXI_SAFRA AND N9D_FARDO = DXI_ETIQ AND N9D_TIPMOV = '02' AND N9D.D_E_L_E_T_ = '' "
	cQry += " 	GROUP BY DXI_FILIAL, DXI_SAFRA, DXI_BLOCO, DXI_CODINE, DXI.D_E_L_E_T_, N9D.N9D_CODCTR, N9D.N9D_ITEETG, N9D.N9D_ITEREF) "
	cQry += " 	DXI2 ON DXI2.D_E_L_E_T_ = '' AND DXI2.DXI_CODINE = N9D2.N9D_CODINE AND DXI2.DXI_FILIAL = N9D2.N9D_FILIAL AND DXI2.DXI_SAFRA  = N9D2.N9D_SAFRA "
	cQry += " 	AND DXI2.DXI_BLOCO  = N9D2.N9D_BLOCO AND DXI2.N9D_CODCTR = N9D2.N9D_CODCTR AND DXI2.N9D_ITEETG = N9D2.N9D_ITEETG AND DXI2.N9D_ITEREF = N9D2.N9D_ITEREF " 
			
	cQry += " WHERE N9D.N9D_FILORG = '" + cFilEnt + "' "
	
	If cTipMov == '05'
		cQry += "   AND N9D.N9D_CODINE = '" + cCodEnt + "'"
	Else 	
		cQry += "   AND N9D.N9D_CODROM = '" + cCodEnt + "'"
	EndIf 	 
	
	cQry += "   AND N9D.N9D_TIPMOV = '" + cTipMov + "' "
	cQry += "   AND N9D.N9D_STATUS = '2' "
	cQry += "   AND N9D.D_E_L_E_T_ = '' "
	cQry += " GROUP BY N9D2.N9D_FILIAL, "
	cQry += "	       N9D2.N9D_FILORG, "
	cQry += "	       N9D2.N9D_CODINE, "
	cQry += "          N9D2.N9D_BLOCO, "
	cQry += "	       N9D2.N9D_CODCTR, " //CONTRATO DA IE
	cQry += "	       N9D2.N9D_ITEETG, " 
	cQry += "	       N9D2.N9D_ITEREF, "
	cQry += "	       N83.N83_QUANT, "
	cQry += " 	       N83.N83_PSBRUT, "
	cQry += " 	       N83.N83_PSLIQU, "
	cQry += "		   DXI.MEDBRUT_DXIDISP, "
	cQry += "		   DXI.MEDLIQU_DXIDISP, "
	cQry += "		   DXI2.QTD_DXIIE, "
	cQry += "		   DXI2.PSBRUT_DXIIE, "
	cQry += "		   DXI2.PSLIQU_DXIIE "	 
	cQry += " ORDER BY N9D2.N9D_FILORG, "
	cQry += "	       N9D2.N9D_CODINE, "
	cQry += "	       N9D2.N9D_CODCTR, "
	cQry += "	       N9D2.N9D_ITEETG, "
	cQry += "	       N9D2.N9D_ITEREF  "
	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->(!Eof())
	   While (cAliasQry)->(!Eof())	
	   			    
		    nPesLiq := (cAliasQry)->PSLIQU_DXIIE + Round((cAliasQry)->MEDLIQU_DXIDISP * ((cAliasQry)->QTDFRDIE - (cAliasQry)->QTD_DXIIE), 2)
		    nPesBru := (cAliasQry)->PSBRUT_DXIIE + Round((cAliasQry)->MEDBRUT_DXIDISP * ((cAliasQry)->QTDFRDIE - (cAliasQry)->QTD_DXIIE), 2)
		    		    		
			DbSelectArea("N7Q")			
			N7Q->(DbSetOrder(1)) //N7Q_FILIAL+N7Q_CODINE
			If N7Q->(DbSeek((cAliasQry)->N9D_FILORG+(cAliasQry)->N9D_CODINE))
				If RecLock("N7Q", .F.)
				   // Considerar valor que já esta instruido + ganho peso - valor media do bloco + valor real dos fardos 
				   // por bloco (+ tara (bruto))
				   If lReabrir				   		
				   		N7Q->N7Q_TOTLIQ := N7Q->N7Q_TOTLIQ - (cAliasQry)->PSDIF
				   		N7Q->N7Q_TOTBRU := N7Q->N7Q_TOTBRU - (cAliasQry)->PSDIF
				   Else				   		
				   		N7Q->N7Q_TOTLIQ := N7Q->N7Q_TOTLIQ - (cAliasQry)->PSLIQIE + nPesLiq
				   		N7Q->N7Q_TOTBRU := N7Q->N7Q_TOTBRU - (cAliasQry)->PSBRUIE + nPesBru
				   EndIf
				   				
				   N7Q->(MsUnlock())
				EndIf					
			EndIf
			
			DbSelectArea("N7S")				
			N7S->(DbSetOrder(1)) //N7S_FILIAL+N7S_CODINE+N7S_CODCTR+N7S_ITEM+N7S_SEQPRI
			If N7S->(DbSeek((cAliasQry)->N9D_FILORG+(cAliasQry)->N9D_CODINE+(cAliasQry)->IE_CODCTR+(cAliasQry)->IE_ITEETG+(cAliasQry)->IE_ITEREF))
				If RecLock("N7S", .F.)
				   // Considerar valor que já esta instruido + ganho peso - valor media do bloco + valor real dos fardos 
				   // por bloco
				   If lReabrir					  
					  N7S->N7S_QTDVIN := N7S->N7S_QTDVIN - (cAliasQry)->PSDIF
				   Else					  
					  N7S->N7S_QTDVIN := N7S->N7S_QTDVIN - (cAliasQry)->PSLIQIE + nPesLiq		
				   EndIf
				   N7S->(MsUnlock())																									
				EndIf										
			EndIf	
			
			DbSelectArea("N83")				
			N83->(DbSetOrder(3)) //N83_FILIAL+N83_CODINE+N83_CODCTR+N83_ITEM+N83_ITEREF+N83_FILORG+N83_BLOCO
			If N83->(DbSeek( (cAliasQry)->N9D_FILORG+(cAliasQry)->N9D_CODINE+(cAliasQry)->IE_CODCTR+(cAliasQry)->IE_ITEETG+(cAliasQry)->IE_ITEREF+(cAliasQry)->N9D_FILIAL+(cAliasQry)->N9D_BLOCO ))
				If RecLock("N83", .F.)	
				   // Considerar valor que já esta instruido + ganho peso - valor media do bloco + valor real dos fardos 
				   // por bloco (+ tara (bruto))
				   If lReabrir 				   		
						N83->N83_PSLIQU := N83->N83_PSLIQU - (cAliasQry)->PSDIF
						N83->N83_PSBRUT := N83->N83_PSBRUT - (cAliasQry)->PSDIF
				   Else					    
						N83->N83_PSLIQU := N83->N83_PSLIQU - (cAliasQry)->PSLIQIE + nPesLiq
						N83->N83_PSBRUT := N83->N83_PSBRUT - (cAliasQry)->PSBRUIE + nPesBru
				   EndIf				
				   N83->(MsUnlock())
				EndIf					
			EndIf				
			
			// QUANDO REMESSA FORMAÇÃO DE LOTE COM IE DE VENDA, O CONTRATO NO FARDO(N9D) DE MOVIMENTO '07' É O CONTRATO DE REMESSA PARA DEPOSITO E OS CONTRATOS NA IE SÃO CONTRATOS DE VENDA
			// NO SELECT ALEM DO CONTRATO DO MOVIMENTO TRAZ O CONTRATO DA IE EM QUE O FARDO ESTA VINCULADO E O QUAL FOI RESERVADO, 
			// E ASSIM USA SEMPRE O CONTRATO DA IE PARA ATUALIZAR A N9A
			DbSelectArea("N9A")				
			N9A->(DbSetOrder(1)) // FILIAL+CODCTR+ITEM+SEQPRI			
			If N9A->(DbSeek((cAliasQry)->N9D_FILORG+(cAliasQry)->IE_CODCTR+(cAliasQry)->IE_ITEETG+(cAliasQry)->IE_ITEREF))
				If RecLock("N9A",.F.)
					// Considerar valor que já esta instruido + ganho peso - valor media do bloco + valor real dos fardos 
				    // por bloco
				    If lReabrir				    									
						N9A->N9A_QTDINS := N9A->N9A_QTDINS - (cAliasQry)->PSDIF
				    Else					   								
						N9A->N9A_QTDINS := N9A->N9A_QTDINS - (cAliasQry)->PSLIQIE + nPesLiq					 
					EndIf
					
					N9A->N9A_SDOINS := IIf(N9A->N9A_QTDTKP > N9A->N9A_QUANT,N9A->N9A_QTDTKP,N9A->N9A_QUANT) - N9A->N9A_QTDINS
					N9A->(MsUnlock())	
				EndIf	
			EndIf	
			
			(cAliasQry)->(DbSkip())
												
		EndDo
		
		(cAliasQry)->(DbCloseArea())
	EndIf

Return .T.

/** {Protheus.doc} OG250EATMF
Atualiza peso dos movimentos do fardo

@param:     cFilRom, character, Filial do Romaneio
@param:     cCodRom, character, Código do Romaneio
@param: 	lAtuc, logical, .T. - Atualizar o romaneio; .F. - Reabrir o romaneio
@param: 	cTpMov, character, Tipo de Movimento do Fardo (07 - Romaneio, 08 - Em trânsito)
@return:	Nil
@author: 	felipe.mendes
@since: 	14/03/2018
@Uso: 		OGA250 - Romaneio

*/
Function OG250EATMF(lAtuc, cTpMov, cFilRom, cCodRom, dDatChe)
	Local aDados       := {}
	Local aRfie		   := {}
	Local aChave	   := {}
	Local aFardos	   := {}
	Local nPesoF       := 0
	Local nPesoI       := 0
	Local cStatusBusca := IIf(lAtuc,"1","2") // 1=Previsto;2=Ativo;3=Inativo
	Local aFrdSts	   := {}
	
	Default	dDatChe := dDatabase
	
	If cTpMov == "08" // Em trânsito
		cStatusBusca := "2"
	EndIf
	
	//Buscando as movimentações 
	DbSelectArea("N9D")
	N9D->(DbSetOrder(6))// N9D_FILORG+N9D_CODROM+N9D_TIPMOV	
	If N9D->(DbSeek(cFilRom+cCodRom+cTpMov))
		While !N9D->(Eof()) .AND. cFilRom+cCodRom+cTpMov+cStatusBusca == N9D->N9D_FILIAL+N9D->N9D_CODROM+N9D->N9D_TIPMOV+N9D->N9D_STATUS
			
			DbSelectArea("DXI") 
			DXI->(DbSetorder(1))
			If  DXI->(DbSeek(N9D->N9D_FILORG+N9D->N9D_SAFRA+N9D->N9D_FARDO))			    			    			    					 
				//Usar o peso certificado, ou peso saida ou peso liquido
				IF DXI->DXI_PESCER > 0 
				   nPesoF := DXI->DXI_PESCER 
				ElseIf (DXI->DXI_PESSAI > 0 .AND. cTpMov == "07") .OR. (DXI->DXI_PESCHE > 0 .AND. cTpMov == "08")
				   nPesoF := IIf(cTpMov == "07", DXI->DXI_PESSAI, DXI->DXI_PESCHE)
				Else   
				   nPesoF := DXI->DXI_PSLIQU
				EndIF 				
				
				nPesoI := IIf(DXI->DXI_PSESTO > 0, DXI->DXI_PSESTO, DXI->DXI_PSLIQU)
				
				// Monta array com campos para alteração na N9D
				aDados := {}
				
				If cTpMov == "07" // Romaneio
					Aadd(aDados, {"N9D_PESINI", nPesoI})
				EndIf 
				
				Aadd(aDados, {"N9D_PESFIM", nPesoF})
				Aadd(aDados, {"N9D_PESDIF", nPesoF - nPesoI})
						  
				If cTpMov == "07" // Romaneio
					Aadd(aDados, {"N9D_STATUS", IIf(lAtuc,"2","1")})
					aRfie := OG250EGRF(fwxfilial("N7S"), N9D->N9D_FILORG, N9D->N9D_CODINE, N9D->N9D_SAFRA, N9D->N9D_FARDO )	
					If Len(aRfie) > 0 
						Aadd(aDados, {"N9D_TAVISO", ""})
					EndIf				
				EndIf
				
				If cTpMov == "08" // Em trânsito
					Aadd(aDados, {"N9D_DATA", dDatChe})
					AADD(aFrdSts, { N9D->N9D_FILIAL, N9D->N9D_SAFRA, N9D->N9D_FARDO })
				EndIf	
				
				aChave := {{N9D->N9D_FILIAL},{N9D->N9D_SAFRA},{N9D->N9D_FARDO},{N9D->N9D_IDMOV}} 
				
				Aadd(aFardos, {aDados, aChave})				
			EndIf
			N9D->(DbSkip())	 	   		  
		EndDo
		
		If cTpMov == "08" .AND. Len(aFrdSts) > 0 // Em trânsito -- esta sendo atualizado data de chegada no romaneio (lExecAgoClas)
			//incluir(1) status do fardo na DXI(DXI_STATUS)
			AGRXFNSF( 1 , "RomanRemChe", aFrdSts ) //romaneio remessa - chegada transito
		EndIf
		
		//Chamada da função que atualiza os fardos na N9D
		aRet := AGRMOVFARD( , 2, 1, , aFardos)
		
	EndIf	
											
Return .T.

/** {Protheus.doc} OG250EMF08
Cria o movimento dos fardos "08" (Em trânsito) 

@param:     cFilRom, character, Filial do romaneio
@param:     cCodRom, character, Código do romaneio
@param:     cLocal, character, Local do romaneio
@param:     nOpc, number, 1 - Inclusão
@return:	Nil
@author: 	felipe.mendes
@since: 	14/03/2018
@Uso: 		OGA250 - Romaneio
*/
Function OG250EMF08(cFilRom, cCodRom, cLocal)
	Local aDados   := {}
	Local aFardos  := {}
	Local nPesoIni := 0
	Local aFrdSts  := {}
		
	DbSelectArea("N9D")
	N9D->(DbSetOrder(6)) // N9D_FILORG+N9D_CODROM+N9D_TIPMOV
	If N9D->(DbSeek(cFilRom+cCodRom+"07"))
		While N9D->(!Eof()) .AND. N9D->(N9D_FILORG+N9D_CODROM+N9D_TIPMOV+N9D_STATUS) == cFilRom+cCodRom+"07"+"2"
			
			DbSelectArea("DXI")
			DXI->(DbSetorder(1)) // DXI_FILIAL+DXI_SAFRA+DXI_ETIQ
			If DXI->(DbSeek(N9D->N9D_FILIAL+N9D->N9D_SAFRA+N9D->N9D_FARDO))
				
				nPesoIni := IIf(DXI->DXI_PSESTO > 0, DXI->DXI_PSESTO, DXI->DXI_PSLIQU)
				
				aDados  := {{"N9D_FILIAL", N9D->N9D_FILIAL},;
							{"N9D_SAFRA" , N9D->N9D_SAFRA },;
							{"N9D_FARDO" , N9D->N9D_FARDO },;
							{"N9D_DATA"  , dDatabase      },;
							{"N9D_TIPMOV", "08"		      },;
							{"N9D_PESINI", nPesoIni 	  },; //Peso dos fardos será alterado no rateio
							{"N9D_PESFIM", 0 	    	  },;
		 				    {"N9D_PESDIF", nPesoIni       },;
		 				    {"N9D_LOCAL" , cLocal		  },;
		 				    {"N9D_FILORG", cFilRom		  },;
							{"N9D_STATUS", "2"            }}	
							
				AADD(aFardos, aDados)	
				
				AADD( aFrdSts, { N9D->N9D_FILIAL, N9D->N9D_SAFRA, N9D->N9D_FARDO } )
						
			EndIf
			
			N9D->(DbSkip())
		EndDo
		
		//incluir(1) status do fardo na DXI(DXI_STATUS)
		AGRXFNSF( 1 , "RomanRemTra", aFrdSts ) //romaneio remessa - em transito
		
		//Inclui movimentação para o fardo
		aRet := AGRMOVFARD(aFardos, 1)   
	
	EndIf
	
Return .T.

/** {Protheus.doc} OG250EDMFT
Deleta o movimento dos fardos "08" (Em trânsito) 

@param:     cFilRom, character, Filial do romaneio
@param:     cCodRom, character, Código do romaneio
@param:     nOpc, number, 1 - Inclusão
@return:	Nil
@author: 	francisc.nunes
@since: 	27/04/2018
@Uso: 		OGA250 - Romaneio
*/
Function OG250EDMFT(cFilRom, cCodRom)
	Local aFardos := {}
	Local aChave  := {}	
	Local aFrdSts := {}

	DbSelectArea("N9D")
	N9D->(DbSetOrder(6)) // N9D_FILORG+N9D_CODROM+N9D_TIPMOV
	If N9D->(DbSeek(cFilRom+cCodRom+"08"))
		While N9D->(!Eof()) .AND. N9D->(N9D_FILORG+N9D_CODROM+N9D_TIPMOV+N9D_STATUS) == cFilRom+cCodRom+"08"+"2"
			
			If NJM->NJM_CODINE + NJM->NJM_CODCTR + NJM->NJM_SEQPRI == N9D->N9D_CODINE + N9D_CODCTR + N9D->N9D_ITEREF
				aChave := {{N9D->N9D_FILIAL}, {N9D->N9D_SAFRA}, {N9D->N9D_FARDO}, {N9D->N9D_IDMOV}}
				
				Aadd(aFardos, aChave)
				
				AADD(aFrdSts, { N9D->N9D_FILIAL, N9D->N9D_SAFRA, N9D->N9D_FARDO })
				
			EndIf
			N9D->(DbSkip())
		EndDo
		
		//Retorna(2) status do fardo na DXI(DXI_STATUS)
		AGRXFNSF( 2 , "RomanRemTra", aFrdSts ) //romaneio remessa - em transito
		
		//Deleta movimentação dos fardos
		aRet := AGRMOVFARD(,3,1,,,aFardos) 
		
	EndIf

Return .T.

/** {Protheus.doc} OG250EAIR
Atualiza o Item do Romaneio na N9D
@return:	.T. OU .F.
@author: 	janaina.duarte
@since: 	23/06/2018
@Uso: 		OGA250D
*/
Function OG250EAIR(cFilRom, cCodRom, cCodine, nIteRom, cCodCtr, cIteEtg, cIteRef)	
	Local cQry 	    := ""
	Local cAliasQry := ""
	
	cAliasQry := GetNextAlias()
	cQry := " SELECT N9D.N9D_FILIAL, "
	cQry += "		 N9D.N9D_SAFRA, "
	cQry += "		 N9D.N9D_FARDO, "
	cQry += "		 N9D.N9D_IDMOV  "
	cQry += " FROM " + RetSqlName("N9D") + " N9D "
	cQry += " WHERE N9D.N9D_FILORG = '" + cFilRom + "' "
	cQry += "   AND N9D.N9D_CODROM = '" + cCodRom + "' "
	cQry += "   AND N9D.N9D_CODINE = '" + cCodine + "' "
	cQry += "   AND N9D.N9D_CODCTR = '" + cCodCtr + "' "
	cQry += "   AND N9D.N9D_ITEETG = '" + cIteEtg + "' "
	cQry += "   AND N9D.N9D_ITEREF = '" + cIteRef + "' "
	cQry += "   AND N9D.N9D_TIPMOV = '07' " 	 
	cQry += "   AND N9D.N9D_STATUS = '2' "
	cQry += "   AND N9D.D_E_L_E_T_ = '' "
	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->(!Eof())
	   While (cAliasQry)->(!Eof())	
	   			    
			DbSelectArea("N9D")			
			N9D->(DbSetOrder(1)) //N9D_FILIAL+N9D_SAFRA+N9D_FARDO+N9D_IDMOV
			If N9D->(DbSeek((cAliasQry)->N9D_FILIAL+(cAliasQry)->N9D_SAFRA+(cAliasQry)->N9D_FARDO+(cAliasQry)->N9D_IDMOV))
				If RecLock("N9D", .F.)
				   N9D->N9D_ITEROM := cValToChar(STRZERO(nIteRom,TamSX3( "NJM_ITEROM" )[1]))  //cValToChar(nIteRom)
				   N9D->(MsUnlock())
				EndIf					
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		
		(cAliasQry)->(DbCloseArea())
	EndIf

Return .T.



/** {Protheus.doc} OG250EGRF
Guarda os registros das regras fiscai de venda da Ie

@author: vanilda.moggio
@since:  29/06/18
@Uso: 	 OGX008 - aO CONFIRMAR O ROMANEIO , Grava tabela de extencao gravar dados para posteriormente mostrar na emissao da nf 
@param   cRom, character, código do romaneio
@param    
@return: 
*/ 
Static Function OG250EGRF(cFilIE, cFilfar, cCodine, cSafra, cEtiq )
    Local cQry 	    := ""
	Local cAliasQry := ""
	Local aRegraIE := {}
	
	cAliasQry := GetNextAlias()
	cQry := " SELECT N9D2.N9D_CODCTR, "
	cQry += "		 N9D2.N9D_ITEETG, "
	cQry += "		 N9D2.N9D_ITEREF "
	cQry += " FROM " + RetSqlName("N9D") + " N9D2"
	cQry += " WHERE N9D2.N9D_FILIAL = '" + cFilfar + "' "
	cQry += "   AND N9D2.N9D_FILORG = '" + cFilIE + "' "
	cQry += "   AND N9D2.N9D_CODINE = '" + cCodine + "' "
	cQry += "   AND N9D2.N9D_SAFRA  = '" + cSafra  + "' "
	cQry += "   AND N9D2.N9D_FARDO = '"  + cEtiq   + "' "
	cQry += "   AND N9D2.N9D_TIPMOV = '04' " 	 
	cQry += "   AND N9D2.N9D_STATUS = '2' "
	cQry += "   AND N9D2.D_E_L_E_T_ = '' "
	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->(!Eof())
	   	Aadd(aRegraIE,(cAliasQry)->N9D_CODCTR)
	   	Aadd(aRegraIE,(cAliasQry)->N9D_ITEETG)
	   	Aadd(aRegraIE,(cAliasQry)->N9D_ITEREF)				
	EndIf									

return aRegraIE

