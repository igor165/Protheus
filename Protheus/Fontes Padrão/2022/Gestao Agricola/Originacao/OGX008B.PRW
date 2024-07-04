#INCLUDE "Protheus.ch"
#INCLUDE "OGX008.ch"


/*/{Protheus.doc} OGX008BGFR()
Função que agrupa os fardos de algodão por tipo, lote e preço para quebrar os itens do pedido
@type  Function
@author claudineia.reinert
@since 10/04/2018
@version 1.0
@param  cTipProc, Number, processo que chama esta função(1 - Romaneio, 2 - Instr. Embarque, 3 - Romaneio Exportação)
@param  cFilorg , Caracter, Filial
@param  cCodigo , Caracter, codigo conforme tipo do processo
@param  cItem, Caracter, Para cTipProc igual a 1 recebe o item da NJM
@param lExced, Logical, .T. - cTipProc=1 Excedente da Remessa por Venda Futura, .F. - Não tem excedente
@param lContLot, Logical, .T. - controla por lote, .F. - não controla por lote
@param cTes, Caracter, Numero da TES
@return aItens, Array, Itens por tipo, lote e preço
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=287072658
/*/
Function OGX008BGFR(cTipProc, cFilorg, cCodigo, cItem, lExced, lContLot, cTes)
	Local cAliasQry := ''
	Local cQuery 	:= ''
	Local cQuery2 	:= ''
	Local aItens 	:= {}
	Local nPos 		:= 0
	Local cLote		:= ''
	Local nQtdBloco := 0
	Local cAviso    := ''
	Local cDco      := ''
	Local cSeqDCo   := ''
	Local cTpAvis   := ''

	Default lContLot := .T. //padrão/default sempre controla/quebra lote, pois query faz a quebra por tipo, preço e lote
	Default lExced 	 := .F. //somente venda futura
	Default cTes	 := ''

	If TableInDic('N9D') //se tabela N9D existe

		If cTipProc = 1 .OR. cTipProc = 3 //romaneio interno / romaneio exportação

			//Não controla/quebra por lote se a TES da Remessa não atualiza estoque.
			If !Empty(cTes) .And. Posicione('SF4',1,FWxFilial('SF4')+cTes,'F4_ESTOQUE') $ 'N'                                                
				lContLot := .F.  //não vai quebrar por lote
			EndIf

			//NO ROMANEIO OS ITENS DO PEDIDO SÃO GERADO POR NJM, PORTANTO SELECT BUSCA DADOS REFERENTE AO ITEM DO ROMANEIO			
			cAliasQry := GetNextAlias()
			cQuery := " SELECT DXI_CLACOM AS TIPO, N9D_LOTECT AS LOTE, COUNT(N9D_FARDO) AS QTDFARDOS, "

			If cTipProc = 1 
				cQuery += " N9D_VLRUNI AS PRECO, N9D_TAVISO, "
			Else
				cQuery += " DXI_VLCAGD AS PRECO, "  //exportação irá usar o preco do agio/desagio
			EndIf

			If lExced
				cQuery += " SUM(N9D_PESEXC) AS PESOBRU, "
				cQuery += " SUM(N9D_PESEXC) AS PESOLIQ "
			Else
				cQuery += " SUM(N9D_PESFIM - N9D_PESEXC + DXI_PSTARA) AS PESOBRU, "
				cQuery += " SUM(N9D_PESFIM - N9D_PESEXC) AS PESOLIQ "
			EndIf

			If cTipProc = 3
				cQuery += " , NJM_NUMAVI, NJM_NUMDCO, NJM_SEQDCO "
			EndIf

			cQuery += " FROM " + RetSqlName('N9D')+ " N9D "
			cQuery += " INNER JOIN " + RetSqlName('DXI')+ " DXI ON DXI.D_E_L_E_T_ = '' AND DXI_FILIAL = N9D_FILIAL AND DXI_ETIQ = N9D_FARDO AND DXI_SAFRA = N9D_SAFRA "
			cQuery += " INNER JOIN " + RetSqlName('NJM')+ " NJM ON NJM.D_E_L_E_T_ = '' AND NJM_FILIAL = N9D_FILORG AND  NJM_CODROM = N9D_CODROM AND NJM_ITEROM = N9D_ITEROM "
			
			cQuery += " WHERE N9D.D_E_L_E_T_ = '' "
			cQuery += " AND N9D_FILORG = '" + cFilorg + "' AND N9D_CODROM = '" + cCodigo + "' "
			cQuery += " AND N9D_TIPMOV = '07' AND N9D_STATUS = '2'  "
			
			If cTipProc = 1 //romaneio mercado interno quebra pelo item do romaneio, pois SC6 é quebrada por NJM
				cQuery += " AND N9D_ITEROM = '"+cItem+"' "
			EndIf
			

			If cTipProc = 1 .and. lExced //somente venda futura
				cQuery += " AND N9D_PESEXC > 0 "
			EndIf			
			
			cQuery += " GROUP BY DXI_CLACOM, N9D_LOTECT, 

			If cTipProc = 1 //romaneio interno
				cQuery += "  N9D_TAVISO, N9D_VLRUNI "
			Else
				cQuery += " DXI_VLCAGD "
			EndIf

			If cTipProc = 3
				cQuery += " , NJM_NUMAVI, NJM_NUMDCO, NJM_SEQDCO "
			EndIf
			
			cQuery := ChangeQuery(cQuery)
			If select("cAliasQry") <> 0
				cAliasQry->( dbCloseArea() )
			EndIf
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)

			DbSelectArea( cAliasQry )  
			(cAliasQry)->( dbGoTop() )
			While .Not. (cAliasQry)->( Eof() )			
	                          
				cLote   := IIf(lContLot, (cAliasQry)->LOTE, '') //aqui define se realmente deve controlar/quebrar por lote conforme valor lContLot
				cAviso  := IIf(cTipProc == 3, (cAliasQry)->NJM_NUMAVI, (cAliasQry)->N9D_TAVISO )
				cDco    := IIf(cTipProc == 3, (cAliasQry)->NJM_NUMDCO, '')
				cSeqDCo := IIf(cTipProc == 3, (cAliasQry)->NJM_SEQDCO, '')
				cTpAvis := ""

				nPos := AScan(aItens, {|x| Alltrim(x[1])+Alltrim(x[2])+Alltrim(STR(x[3]))+Alltrim(x[7])+Alltrim(x[8])+Alltrim(x[9]) == Alltrim((cAliasQry)->TIPO) + Alltrim(cLote) + Alltrim(STR((cAliasQry)->PRECO)) + Alltrim(cAviso) + Alltrim(cDco) + Alltrim(cSeqDCo)})
				If nPos = 0				    			    
					aAdd(aItens, { 	(cAliasQry)->TIPO ,; 
									 cLote ,; 
									(cAliasQry)->PRECO ,; 
									(cAliasQry)->QTDFARDOS ,;							
									(cAliasQry)->PESOBRU ,;
									(cAliasQry)->PESOLIQ ,;
									 cAviso,; //código do Aviso PEPERO
									 cDco,; //código do DCO PEPERO
									 cSeqDCo,; //Sequencial do DCO PEPERO
									 cTpAvis } ) //Tipo do algodão do aviso PEPERO
				Else
					aItens[nPos][4] += (cAliasQry)->QTDFARDOS //qtd fardos
					aItens[nPos][5] += (cAliasQry)->PESOBRU //peso bruto
					aItens[nPos][6] += (cAliasQry)->PESOLIQ //peso liquido
				EndIf

				(cAliasQry)->( dbSkip() )
			EndDo 
			(cAliasQry)->( dbCloseArea() )

		ElseIf cTipProc = 2 //INSTRUÇÃO DE EMBARQUE(OGA710) CRIAÇÃO OU AJUSTE PROCESSO DE EXPORTAÇÃO VIA MENU OGA710
		//PODE TER TODOS OS FARDOS VINCULADOS A IE(DXI_CODINE) OU, SE DIGITADO QTD BLOCO MANUAL PODE NÃO TER TODOS OS FARDOS VINCULADOS

			//PRIMEIRO, BUSCA FARDOS JA VINCULADOS NA IE(DXI_CODINE) E QUEBRA OS ITENS POR TIPO, LOTE E PREÇO(AGIO/DESAGIO)
			cAliasQry := GetNextAlias() 
			cQuery := "          SELECT DXI_CLACOM AS TIPO, "
			cQuery += "                 N9D_LOTECT AS LOTE, "
			cQuery += "                 DXI_VLCAGD AS PRECO, "
			cQuery += "                 COUNT(N9D_FARDO) AS QTDFARDOS, "
			cQuery += "                 SUM(CASE WHEN DXI_PESCER > 0 THEN DXI_PESCER + DXI_PSTARA WHEN DXI_PESSAI > 0 THEN DXI_PESSAI + DXI_PSTARA WHEN DXI_PSESTO > 0 THEN DXI_PSESTO + DXI_PSTARA ELSE DXI_PSLIQU + DXI_PSTARA END) AS PESOBRU, "
			cQuery += "                 SUM(CASE WHEN DXI_PESCER > 0 THEN DXI_PESCER WHEN DXI_PESSAI > 0 THEN DXI_PESSAI WHEN DXI_PSESTO > 0 THEN DXI_PSESTO ELSE DXI_PSLIQU END) AS PESOLIQ, "
			cQuery += "                 NLN_NUMAVI, NLN_NUMDCO, NLN_SEQDCO "
			cQuery += "            FROM " + RetSqlName('N9D')+ " N9D "
			cQuery += "      INNER JOIN " + RetSqlName('DXI')+ " DXI ON DXI.D_E_L_E_T_ = '' "
			cQuery += "             AND DXI_FILIAL = N9D_FILIAL "
			cQuery += "             AND DXI_ETIQ = N9D_FARDO "
			cQuery += "             AND DXI_SAFRA = N9D_SAFRA "
			cQuery += "             AND DXI_BLOCO = N9D_BLOCO "
			cQuery += "             AND DXI_CODINE = N9D_CODINE "			
			cQuery += " LEFT OUTER JOIN (SELECT NLN_NUMAVI, NLN_NUMDCO, NLN_SEQDCO, NLN_FILIAL, NLN_CODINE, NLN_CODCTR,NLN_ITEMPE,NLN_ITEMRF "
			cQuery += "                    FROM " + RetSqlName("NLN") + " NLN "
            cQuery += "                    WHERE NLN.D_E_L_E_T_ = '' "
			cQuery += "                GROUP BY NLN_NUMAVI, NLN_NUMDCO, NLN_SEQDCO, NLN_FILIAL, NLN_CODINE, NLN_CODCTR,NLN_ITEMPE,NLN_ITEMRF) NLN "
			cQuery += "              ON NLN.NLN_FILIAL = '" + FWxFilial("N7S") + "' AND NLN.NLN_CODINE = N9D.N9D_CODINE "
	        cQuery += "              AND NLN.NLN_CODCTR = N9D.N9D_CODCTR AND NLN.NLN_ITEMPE = N9D.N9D_ITEETG AND NLN.NLN_ITEMRF = N9D.N9D_ITEREF "	        
			cQuery += "           WHERE N9D.D_E_L_E_T_ = '' "
			cQuery += "             AND N9D_FILIAL = '"+cFilorg+"' "
			cQuery += "             AND N9D_FILORG = '"+FWxFilial('N7Q')+"' "
			cQuery += "             AND N9D_CODINE = '"+cCodigo+"' "
			cQuery += "             AND N9D_TIPMOV = '04' "
			cQuery += "             AND N9D_STATUS = '2' "
			cQuery += "        GROUP BY DXI_CLACOM,N9D_LOTECT,DXI_VLCAGD, NLN_NUMAVI, NLN_NUMDCO, NLN_SEQDCO "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			 
			(cAliasQry)->(DbGoTop())
			While !(cAliasQry)->(Eof())
				cLote   := IIF(lContLot, (cAliasQry)->LOTE, '') //aqui define se realmente deve controlar/quebrar por lote conforme valor lContLot
				cAviso  := (cAliasQry)->NLN_NUMAVI
				cDco    := (cAliasQry)->NLN_NUMDCO
				cSeqDCo := (cAliasQry)->NLN_SEQDCO
				cTpAvis := ""

				nPos := AScan(aItens, {|x| Alltrim(x[1])+Alltrim(x[2])+Alltrim(STR(x[3]))+Alltrim(x[7])+Alltrim(x[8])+Alltrim(x[9]) == Alltrim((cAliasQry)->TIPO) + Alltrim(cLote) + Alltrim(STR((cAliasQry)->PRECO)) + Alltrim(cAviso) + Alltrim(cDco) + Alltrim(cSeqDCo)})
				If nPos = 0
					AADD(aItens,{(cAliasQry)->TIPO ,; //tipo do algodão
					              cLote ,; //lote
					              (cAliasQry)->PRECO ,; //preço = valor unitario do fardo
					              (cAliasQry)->QTDFARDOS,; //qtd fardos
					              (cAliasQry)->PESOBRU ,; //peso bruto
					              (cAliasQry)->PESOLIQ ,; //peso liquido
								  cAviso,; //código do Aviso PEPERO
								  cDco,; //código do DCO PEPERO
								  cSeqDCo,; //Sequencial do DCO PEPERO
								  cTpAvis; //Tipo do algodão do aviso PEPERO
					            })
				Else
					aItens[nPos][4] += (cAliasQry)->QTDFARDOS //qtd fardos
					aItens[nPos][5] += (cAliasQry)->PESOBRU //peso bruto
					aItens[nPos][6] += (cAliasQry)->PESOLIQ //peso liquido
				EndIf										
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())

			//SEGUNDO, VERIFICA OS BLOCOS COM QTD DIGITADA MANUAL(N83_FRDMAR=2) E QTD FARDOS DESTE BLOCO JA VINCULADOS A IE(DXI_CODINE)
			cAliasQry := GetNextAlias() 
			cQuery := "          SELECT N83.N83_BLOCO AS BLOCO, SUM(N83.N83_QUANT) AS QTD_N83, QTD_DXIIE "
			cQuery += "            FROM " + RetSqlName('N83')+ " N83 "
			cQuery += " LEFT OUTER JOIN (SELECT DXI_FILIAL,DXI_CODINE, DXI_BLOCO,COUNT(DXI_ETIQ) AS QTD_DXIIE "
			cQuery += "            FROM " + RetSqlName('DXI')
			cQuery += "           WHERE D_E_L_E_T_ = '' "
			cQuery += "        GROUP BY DXI_FILIAL,DXI_CODINE,DXI_BLOCO ) "
			cQuery += "                 DXI ON DXI.DXI_FILIAL = N83.N83_FILORG AND DXI.DXI_CODINE = N83.N83_CODINE AND DXI.DXI_BLOCO = N83.N83_BLOCO "
			cQuery += "           WHERE N83.D_E_L_E_T_ = '' "
			cQuery += "             AND N83.N83_FILIAL = '"+FWxFilial('N83')+"' "
			cQuery += "             AND N83.N83_CODINE = '"+cCodigo+"' "
			cQuery += "             AND N83.N83_FILORG = '"+cFilorg+"' "
			cQuery += "             AND N83.N83_FRDMAR='2' "
			cQuery += "        GROUP BY N83.N83_BLOCO, QTD_DXIIE "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			 
			(cAliasQry)->(DbGoTop())
			While !(cAliasQry)->(Eof())
				If (cAliasQry)->QTD_N83 > (cAliasQry)->QTD_DXIIE //SE AINDA FALTA FARDOS DO BLOCO PARA SEREM VINCULADOS NA IE
					nQtdBloco := (cAliasQry)->QTD_N83 - (cAliasQry)->QTD_DXIIE //armazena qtd falta vincular no bloco

					//TERCEIRO, SE BLOCO DIGITADO MANUAL E NEM TODOS OS FARDOS PARA A QTD DO BLOCO FORAM VINCULADOS NA IE
					//BUSCA QTD DISPONIVEL(SEM IE NA DXI_CODINE) E VINCULA CONFORME QTD DO BLOCO QUE FALTA VINCULAR
					cAliasQry2 := GetNextAlias() 
					cQuery2 := "          SELECT DXI.DXI_CLACOM AS TIPO, N9D.N9D_LOTECT AS LOTE, COUNT(DXI.DXI_ETIQ) AS QTDFARDOS, "
					cQuery2 += "                 AVG(CASE WHEN DXI_PESCER > 0 THEN DXI_PESCER + DXI_PSTARA WHEN DXI_PESSAI > 0 THEN DXI_PESSAI + DXI_PSTARA WHEN DXI_PSESTO > 0 THEN DXI_PSESTO + DXI_PSTARA ELSE DXI_PSLIQU + DXI_PSTARA END)  AS MED_PESOBRU, "  
					cQuery2 += "                 AVG(CASE WHEN DXI_PESCER > 0 THEN DXI_PESCER WHEN DXI_PESSAI > 0 THEN DXI_PESSAI WHEN DXI_PSESTO > 0 THEN DXI_PSESTO ELSE DXI_PSLIQU END ) AS MED_PESOLIQ, " 
					cQuery2 += "                 DXI.DXI_VLCAGD AS PRECO, "
					cQuery2 += "                 NLN.NLN_NUMAVI, NLN.NLN_NUMDCO, NLN.NLN_SEQDCO "
					cQuery2 += "            FROM " + RetSqlName('N7S')+ " N7SA "
					cQuery2 += "      INNER JOIN " + RetSqlName('N9D')+ " N9D ON "
					cQuery2 += "                 N9D.D_E_L_E_T_ = '' AND N9D.N9D_FILIAL = '"+cFilorg+"' AND N9D.N9D_CODCTR = N7SA.N7S_CODCTR AND N9D.N9D_ITEETG = N7SA.N7S_ITEM AND N9D.N9D_ITEREF = N7SA.N7S_SEQPRI "
					cQuery2 += "             AND N9D.N9D_TIPMOV = '02' AND N9D.N9D_STATUS = '2' AND N9D.N9D_BLOCO = '"+(cAliasQry)->BLOCO+"' "
					cQuery2 += "      INNER JOIN " + RetSqlName('DXI')+ " DXI ON "
					cQuery2 += "                 DXI.D_E_L_E_T_ = '' AND DXI.DXI_FILIAL = N9D.N9D_FILIAL AND DXI.DXI_ETIQ = N9D.N9D_FARDO AND DXI.DXI_SAFRA = N9D.N9D_SAFRA " 
					cQuery2 += "             AND DXI.DXI_BLOCO = N9D.N9D_BLOCO AND DXI_CODINE = '' "
					cQuery2 += " LEFT JOIN " + RetSqlName("NLN") + " NLN ON NLN.NLN_FILIAL = N7S2.N7S_FILIAL AND NLN.NLN_CODINE = N7S2.N7S_CODINE "
					cQuery2 += "   AND NLN.NLN_CODCTR = N7S2.N7S_CODCTR AND NLN.NLN_ITEMPE = N7S2.N7S_ITEM AND NLN.NLN_ITEMRF = N7S2.N7S_SEQPRI "
					cQuery2 += "   AND NLN.D_E_L_E_T_ = '' "
					cQuery2 += " LEFT OUTER JOIN (SELECT N7S_CODINE, N7S_FILIAL, N7S_CODCTR, N7S_ITEM, N7S_SEQPRI "
                    cQuery2 += "                    FROM " + RetSqlName('N7S') 
			        cQuery2 += "                GROUP BY N7S_CODINE, N7S_FILIAL, N7S_CODCTR, N7S_ITEM, N7S_SEQPRI ) N7SB "
			        cQuery2 += "              ON N7SB.N7S_CODINE = N9D_CODINE AND N7SB.N7S_FILIAL = '" + FWxFilial("N7S") + "' AND N7SB.N7S_CODCTR = N9D_CODCTR AND N7SB.N7S_ITEM = N9D_ITEETG AND N7SB.N7S_SEQPRI = N9D_ITEREF "
					cQuery2 += "           WHERE N7SA.N7S_FILIAL = '"+FWxFilial('N7S')+"' AND N7SA.N7S_CODINE='"+cCodigo+"'  AND N7SA.D_E_L_E_T_ = '' " 
					cQuery2 += "        GROUP BY DXI.DXI_CLACOM, N9D.N9D_LOTECT,DXI.DXI_VLCAGD, NLN.NLN_NUMAVI, NLN.NLN_NUMDCO, NLN.NLN_SEQDCO "
					cQuery2 := ChangeQuery(cQuery2)
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery2),cAliasQry2, .F., .T.) 

					(cAliasQry2)->(DbGoTop())
					While !(cAliasQry2)->(Eof()) .and. nQtdBloco > 0 //SO PODE VINCULAR O QUE FALTA
						cLote   := IIF(lContLot, (cAliasQry2)->LOTE, '') //aqui define se realmente deve controlar/quebrar por lote conforme valor lContLot
						cAviso  := (cAliasQry2)->NLN_NUMAVI
						cDco    := (cAliasQry2)->NLN_NUMDCO
						cSeqDCo := (cAliasQry2)->NLN_SEQDCO
						cTpAvis := ""

						nPos := AScan(aItens, {|x| Alltrim(x[1])+Alltrim(x[2])+Alltrim(STR(x[3]))+Alltrim(x[7])+Alltrim(x[8])+Alltrim(x[9]) == Alltrim((cAliasQry2)->TIPO) + Alltrim(cLote) + Alltrim(STR((cAliasQry2)->PRECO)) + Alltrim(cAviso) + Alltrim(cDco) + Alltrim(cSeqDCo)})
						If nPos = 0
							AADD(aItens,{(cAliasQry2)->TIPO ,; //tipo do algodão
							             cLote ,; //lote
							             (cAliasQry2)->PRECO ,; //preço = valor unitario do fardo
							             0 ,; //qtd fardos
							             0 ,; //peso bruto
							             0 ,; //peso liquido
							             cAviso,; //código do Aviso PEPERO
							             cDco,; //código do DCO PEPERO
							             cSeqDCo,; //Sequencial do DCO PEPERO
							             cTpAvis; //Tipo do algodão do aviso PEPERO
							            })
							nPos := LEN(aItens)
						EndIf
						
						//define qual qtd vincular no aItens
						If nQtdBloco <= (cAliasQry2)->QTDFARDOS
							aItens[nPos][4] += nQtdBloco //qtd fardos
							aItens[nPos][5] += ROUND((nQtdBloco * (cAliasQry2)->MED_PESOBRU), TamSX3('DXI_PSBRUT')[2]) //peso bruto
							aItens[nPos][6] += ROUND((nQtdBloco * (cAliasQry2)->MED_PESOLIQ), TamSX3('DXI_PSLIQU')[2]) //peso liquido
							nQtdBloco := 0
						Else
							aItens[nPos][4] += (cAliasQry2)->QTDFARDOS //qtd fardos
							aItens[nPos][5] += ROUND(((cAliasQry2)->QTDFARDOS * (cAliasQry2)->MED_PESOBRU), TamSX3('DXI_PSBRUT')[2]) //peso bruto
							aItens[nPos][6] += ROUND(((cAliasQry2)->QTDFARDOS * (cAliasQry2)->MED_PESOLIQ), TamSX3('DXI_PSLIQU')[2]) //peso liquido
							nQtdBloco -= (cAliasQry2)->QTDFARDOS
						EndIf

						(cAliasQry2)->(DbSkip())
					EndDo
					(cAliasQry2)->(DbCloseArea())

				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		EndIf
	EndIf

Return aItens

