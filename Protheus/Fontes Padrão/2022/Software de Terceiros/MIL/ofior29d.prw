#Include "OFIOR290.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOR29D ³ Autor ³ Andre Luis Almeida    ³ Data ³ 04/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Performance de Pecas & Acessorios  -  DEVOLUCAO            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR29D
Local nValor := 0 , nPis := 0 , nCof := 0 , nAliqPis := 0 , nAliqCof := 0

//DbSelectArea( "SF1" )
//DbSetOrder(1)
//DbSeek( xFilial("SF1") )

If Select(cAliasSD1) > 0
	( cAliasSD1 )->( DbCloseArea() )
EndIf
cQuery := "SELECT SF1.F1_DTDIGIT, SF1.F1_TIPO, SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_FORNECE, SF1.F1_LOJA "
cQuery += "FROM "+RetSqlName( "SF1" ) + " SF1 "
cQuery += "WHERE "
cQuery += "SF1.F1_FILIAL='"+ xFilial("SF1")+ "' AND "
If !Empty(MV_PAR01)
	cQuery += "SF1.F1_DTDIGIT>='"+DTOS(MV_PAR01)+"' AND "
EndIf
If !Empty(MV_PAR02)
	cQuery += "SF1.F1_DTDIGIT<='"+DTOS(MV_PAR02)+"' AND "
EndIf
cQuery += "SF1.D_E_L_E_T_=' ' ORDER BY SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_TIPO"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSF1, .T., .T. )

While !(cAliasSF1)->(Eof())
	
	//	If (!Empty(MV_PAR01) .and. ((cAliasSF1)->F1_DTDIGIT < MV_PAR01)) .or. (!Empty(MV_PAR02) .and. ((cAliasSF1)->F1_DTDIGIT > MV_PAR02))
	//		DbSelectArea("SF1")
	//		Dbskip()
	//		loop
	//	EndIf
	
	If (cAliasSF1)->F1_TIPO == "D"
		//		DbSelectArea( "SD1" )
		//		DbSetOrder(1)
		//		DbSeek( xFilial("SD1") + (cAliasSF1)->F1_DOC + (cAliasSF1)->F1_SERIE + (cAliasSF1)->F1_FORNECE + (cAliasSF1)->F1_LOJA )
		
		If Select(cAliasSD1) > 0
			( cAliasSD1 )->( DbCloseArea() )
		EndIf
		cQuery := "SELECT * "
		cQuery += "FROM "+RetSqlName( "SD1" ) + " SD1 "
		cQuery += "WHERE "
		cQuery += "SD1.D1_FILIAL='"+ xFilial("SD1")+ "' AND "
		cQuery += "SD1.D1_DOC='"+(cAliasSF1)->F1_DOC+"' AND SD1.D1_SERIE='"+(cAliasSF1)->F1_SERIE+"' AND SD1.D1_FORNECE='"+(cAliasSF1)->F1_FORNECE+"' AND SD1.D1_LOJA='"+(cAliasSF1)->F1_LOJA+"' AND "
		cQuery += "SD1.D_E_L_E_T_=' ' ORDER BY SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_COD, SD1.D1_ITEM"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSD1, .T., .T. )
		
		While !(cAliasSD1)->(Eof())
			
			//		 	DbSelectArea( "SF4" )
			//			DbSetOrder(1)
			//			DbSeek( xFilial("SF4") + (cAliasSD1)->D1_TES )
			
			If Select(cAliasSF4) > 0
				( cAliasSF4 )->( DbCloseArea() )
			EndIf
			cQuery := "SELECT SF4.F4_DUPLIC, SF4.F4_ESTOQUE, SF4.F4_OPEMOV, SF4.F4_PISCRED, SF4.F4_PISCOF "
			cQuery += "FROM "+RetSqlName( "SF4" ) + " SF4 "
			cQuery += "WHERE "
			cQuery += "SF4.F4_FILIAL='"+ xFilial("SF4")+ "' AND "
			cQuery += "SF4.F4_CODIGO='"+(cAliasSD1)->D1_TES+"' AND "
			cQuery += "SF4.D_E_L_E_T_=' ' ORDER BY SF4.F4_CODIGO"
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSF4, .T., .T. )
			
			If (cAliasSF4)->F4_ESTOQUE == "S"
				
				/*				nValor := ( ( (cAliasSD1)->D1_TOTAL + (cAliasSD1)->D1_VALIPI + (cAliasSD1)->D1_ICMSRET + (cAliasSD1)->D1_DESPESA + (cAliasSD1)->D1_SEGURO + (cAliasSD1)->D1_VALFRE ) - (cAliasSD1)->D1_VALDESC )
				nPis := 0
				nCof := 0
				If (cAliasSF4)->F4_PISCRED == "1"
				If (cAliasSF1)->F1_DTDIGIT <= "20021130"
				nAliqPis := 0.0065
				Else
				nAliqPis := 0.0165
				EndIf
				If (cAliasSF1)->F1_DTDIGIT <= "20040131"
				nAliqCof := 0.03
				Else
				nAliqCof := 0.076
				EndIf
				If (cAliasSF4)->F4_PISCOF == "1"
				nPis := round( nValor * nAliqPis ,2)
				nCof := 0
				ElseIf (cAliasSF4)->F4_PISCOF == "2"
				nPis := 0
				nCof := round( nValor * nAliqCof ,2)
				ElseIf (cAliasSF4)->F4_PISCOF == "3"
				nPis := round( nValor * nAliqPis ,2)
				nCof := round( nValor * nAliqCof ,2)
				EndIf
				EndIf
				*/
				
				nValor := ( ( (cAliasSD1)->D1_TOTAL + (cAliasSD1)->D1_VALIPI + (cAliasSD1)->D1_ICMSRET + (cAliasSD1)->D1_DESPESA + (cAliasSD1)->D1_SEGURO + (cAliasSD1)->D1_VALFRE ) - (cAliasSD1)->D1_VALDESC )
				nPis := 0
				nCof := 0
				If (cAliasSF4)->F4_PISCRED == "1"
					
					nAliqCof := ( (cAliasSD1)->D1_ALQIMP5 / 100 )
					nAliqPis := ( (cAliasSD1)->D1_ALQIMP6 / 100 )
					
					If (cAliasSF4)->F4_PISCOF == "1"
						nPis := round( nValor * nAliqPis ,2)
						nCof := 0
					ElseIf (cAliasSF4)->F4_PISCOF == "2"
						nPis := 0
						nCof := round( nValor * nAliqCof ,2)
					ElseIf (cAliasSF4)->F4_PISCOF == "3"
						nPis := round( nValor * nAliqPis ,2)
						nCof := round( nValor * nAliqCof ,2)
					EndIf
				EndIf
				
				nPvalvda := nValor - ( nPis + nCof + (cAliasSD1)->D1_VALICM )
				nPcustot := (cAliasSD1)->D1_CUSTO
				nPvalvda := ( nPvalvda * (-1) )
				nPcustot := ( nPcustot * (-1) )
				
				//		   	DbSelectArea( "SBM" )
				//   			DbSetOrder(1)
				//	   		DbSeek( xFilial("SBM") + (cAliasSD1)->D1_GRUPO , .f. )
				//			 	DbSelectArea( "SF2" )
				//				DbSetOrder(1)
				//				DbSeek( xFilial("SF2") + (cAliasSD1)->D1_NFORI + (cAliasSD1)->D1_SERIORI , .f. )
				//			   DbSelectArea( "SA1" )
				//			   DbSetOrder(1)
				//			   DbSeek( xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA )
				
				If Select(cAliasSBM) > 0
					( cAliasSBM )->( DbCloseArea() )
				EndIf
				cQuery := "SELECT SBM.BM_CODMAR, SBM.BM_TIPGRU, SBM.BM_DESC, SBM.BM_PROORI "
				cQuery += "FROM "+RetSqlName( "SBM" ) + " SBM "
				cQuery += "WHERE "
				cQuery += "SBM.BM_FILIAL='"+ xFilial("SBM")+ "' AND "
				cQuery += "SBM.BM_GRUPO='"+(cAliasSD1)->D1_GRUPO+"' AND "
				cQuery += "SBM.D_E_L_E_T_=' ' ORDER BY SBM.BM_GRUPO"
				dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSBM, .T., .T. )
				
				If Select(cAliasSF2) > 0
					( cAliasSF2 )->( DbCloseArea() )
				EndIf
				cQuery := "SELECT SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_PREFIXO "
				cQuery += "FROM "+RetSqlName( "SF2" ) + " SF2 "
				cQuery += "WHERE "
				cQuery += "SF2.F2_FILIAL='"+ xFilial("SF2")+ "' AND SF2.F2_DOC='"+(cAliasSD1)->D1_NFORI+"' AND SF2.F2_SERIE='"+(cAliasSD1)->D1_SERIORI+"' AND "
				cQuery += "SF2.D_E_L_E_T_=' ' ORDER BY SF2.F2_DOC, SF2.F2_SERIE"
				dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSF2, .T., .T. )
				
				If Select(cAliasSA1) > 0
					( cAliasSA1 )->( DbCloseArea() )
				EndIf
				cQuery := "SELECT SA1.A1_NOME, SA1.A1_CGC, SA1.A1_SATIV1 "
				cQuery += "FROM "+RetSqlName( "SA1" ) + " SA1 "
				cQuery += "WHERE "
				cQuery += "SA1.A1_FILIAL='"+ xFilial("SA1")+ "' AND SA1.A1_COD='"+(cAliasSF2)->F2_CLIENTE+"' AND SA1.A1_LOJA='"+(cAliasSF2)->F2_LOJA+"' AND "
				cQuery += "SA1.D_E_L_E_T_=' ' ORDER BY SA1.A1_COD, SA1.A1_LOJA"
				dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSA1, .T., .T. )
				
				///////////////////////
				//    ACESSORIOS     //
				///////////////////////
				
				If (Alltrim((cAliasSBM)->BM_TIPGRU) == "8")
					nPos := 0
					nPos := aScan(aNumAce,{|x| x[1] == "DEV    " })
					If nPos == 0
						aAdd(aNumAce,{ "DEV    " , STR0051 , nPvalvda , nPcustot })
					Else
						aNumAce[nPos,3] += nPvalvda
						aNumAce[nPos,4] += nPcustot
					EndIf
					aTotAce[1,1] += nPvalvda
					aTotAce[1,2] += nPcustot
					aTotPec[1,1] += nPvalvda
					aTotPec[1,2] += nPcustot
					aTotal[1,1]  += nPvalvda
					aTotal[1,2]  += nPcustot
					
					///////////////////////
					//   OUTRAS VENDAS   //
					///////////////////////
					
//				ElseIf str(val((cAliasSBM)->BM_TIPGRU),2) $ " 2| 3| 9|10"
				ElseIf alltrim( (cAliasSBM)->BM_TIPGRU ) $ "2|3|A"
					nPos := 0
					nPos := aScan(aNumLub,{|x| x[1] == "DEV    " })
					If nPos == 0
						aAdd(aNumLub,{ "DEV    " , STR0051 , nPvalvda , nPcustot })
					Else
						aNumLub[nPos,3] += nPvalvda
						aNumLub[nPos,4] += nPcustot
					EndIf
					aTotLub[1,1] += nPvalvda
					aTotLub[1,2] += nPcustot
					aTotal[1,1]  += nPvalvda
					aTotal[1,2]  += nPcustot
				Else
					
					///////////////////////
					//  ATACADO/EXTERNA  //
					///////////////////////
					
					If (cAliasSF2)->F2_PREFIXO == "BAL"
						cSomou := "N"
						If (Len(Alltrim((cAliasSA1)->A1_CGC)) == 14) //  -->   Juridica
							nPos := 0
							nPos := aScan(aChave01,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Governo
							If nPos > 0
								cSomou := "S"
								aGrpPec[1,4] += nPvalvda
								aGrpPec[1,5] += nPcustot
								aTotPBO[1,1] += nPvalvda
								aTotPBO[1,2] += nPcustot
								aTotPec[1,1] += nPvalvda
								aTotPec[1,2] += nPcustot
								aTotal[1,1]  += nPvalvda
								aTotal[1,2]  += nPcustot
								nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "A" + "01" + "DEV    " })
								If nPos == 0
									aAdd(aNumPec,{ "A" , "01" , "DEV    " , STR0051 , nPvalvda , nPcustot })
								Else
									aNumPec[nPos,5] += nPvalvda
									aNumPec[nPos,6] += nPcustot
								EndIf
							EndIf
							nPos := 0
							nPos := aScan(aChave02,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Frotistas
							If nPos > 0
								cSomou := "S"
								aGrpPec[2,4] += nPvalvda
								aGrpPec[2,5] += nPcustot
								aTotPBO[1,1] += nPvalvda
								aTotPBO[1,2] += nPcustot
								aTotPec[1,1] += nPvalvda
								aTotPec[1,2] += nPcustot
								aTotal[1,1]  += nPvalvda
								aTotal[1,2]  += nPcustot
								nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "A" + "02" + "DEV    " })
								If nPos == 0
									aAdd(aNumPec,{ "A" , "02" , "DEV    " , STR0051 , nPvalvda , nPcustot })
								Else
									aNumPec[nPos,5] += nPvalvda
									aNumPec[nPos,6] += nPcustot
								EndIf
							EndIf
							nPos := 0
							nPos := aScan(aChave03,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Seguradoras
							If nPos > 0
								cSomou := "S"
								aGrpPec[3,4] += nPvalvda
								aGrpPec[3,5] += nPcustot
								aTotPBO[1,1] += nPvalvda
								aTotPBO[1,2] += nPcustot
								aTotPec[1,1] += nPvalvda
								aTotPec[1,2] += nPcustot
								aTotal[1,1]  += nPvalvda
								aTotal[1,2]  += nPcustot
								nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "A" + "03" + "DEV    " })
								If nPos == 0
									aAdd(aNumPec,{ "A" , "03" , "DEV    " , STR0051 , nPvalvda , nPcustot })
								Else
									aNumPec[nPos,5] += nPvalvda
									aNumPec[nPos,6] += nPcustot
								EndIf
							EndIf
						EndIf
						nPos := 0
						nPos := aScan(aChave04,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) // Lojas de Pecas
						If nPos > 0
							cSomou := "S"
							aGrpPec[4,4] += nPvalvda
							aGrpPec[4,5] += nPcustot
							aTotPBO[1,1] += nPvalvda
							aTotPBO[1,2] += nPcustot
							aTotPec[1,1] += nPvalvda
							aTotPec[1,2] += nPcustot
							aTotal[1,1]  += nPvalvda
							aTotal[1,2]  += nPcustot
							nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "A" + "04" + "DEV    " })
							If nPos == 0
								aAdd(aNumPec,{ "A" , "04" , "DEV    " , STR0051 , nPvalvda , nPcustot })
							Else
								aNumPec[nPos,5] += nPvalvda
								aNumPec[nPos,6] += nPcustot
							EndIf
						EndIf
						nPos := 0
						nPos := aScan(aChave05,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) // Oficinas Independentes
						If nPos > 0
							cSomou := "S"
							aGrpPec[5,4] += nPvalvda
							aGrpPec[5,5] += nPcustot
							aTotPBO[1,1] += nPvalvda
							aTotPBO[1,2] += nPcustot
							aTotPec[1,1] += nPvalvda
							aTotPec[1,2] += nPcustot
							aTotal[1,1]  += nPvalvda
							aTotal[1,2]  += nPcustot
							nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "A" + "05" + "DEV    " })
							If nPos == 0
								aAdd(aNumPec,{ "A" , "05" , "DEV    " , STR0051 , nPvalvda , nPcustot })
							Else
								aNumPec[nPos,5] += nPvalvda
								aNumPec[nPos,6] += nPcustot
							EndIf
						EndIf
						nPos := 0
						nPos := aScan(aChave06,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Rede (Outros Distr./Concess.)
						If nPos > 0
							cSomou := "S"
							aGrpPec[6,4] += nPvalvda
							aGrpPec[6,5] += nPcustot
							aTotPBO[1,1] += nPvalvda
							aTotPBO[1,2] += nPcustot
							aTotPec[1,1] += nPvalvda
							aTotPec[1,2] += nPcustot
							aTotal[1,1]  += nPvalvda
							aTotal[1,2]  += nPcustot
							nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "A" + "06" + "DEV    " })
							If nPos == 0
								aAdd(aNumPec,{ "A" , "06" , "DEV    " , STR0051 , nPvalvda , nPcustot })
							Else
								aNumPec[nPos,5] += nPvalvda
								aNumPec[nPos,6] += nPcustot
							EndIf
						Endif
						If cSomou == "N"
							nPos  := aScan(aNumBPc,{|x| x[1] == "DEV    " })
							If nPos == 0
								aAdd(aNumBPc,{ "DEV    " , STR0051 , nPvalvda , nPcustot })
							Else
								aNumBPc[nPos,3] += nPvalvda
								aNumBPc[nPos,4] += nPcustot
							EndIf
							aTotPBO[1,1] += nPvalvda
							aTotPBO[1,2] += nPcustot
							aTotBPc[1,1] += nPvalvda
							aTotBPc[1,2] += nPcustot
							aTotPec[1,1] += nPvalvda
							aTotPec[1,2] += nPcustot
							aTotal[1,1]  += nPvalvda
							aTotal[1,2]  += nPcustot
						EndIf
						
						///////////////////////
						//  OFICINA/INTERNA  //
						///////////////////////
						
					ElseIf (cAliasSF2)->F2_PREFIXO == "OFI"
						//					 	DbSelectArea("VOO")
						//						DbSetOrder(4)
						//						DbSeek( xFilial("VOO") + (cAliasSF2)->F2_DOC + (cAliasSF2)->F2_SERIE )
						//					 	DbSelectArea("VOI")
						//						DbSetOrder(1)
						//						DbSeek( xFilial("VOI") + VOO->VOO_TIPTEM )
						
						If Select(cAliasVOO) > 0
							( cAliasVOO )->( DbCloseArea() )
						EndIf
						cQuery := "SELECT VOO.VOO_TIPTEM "
						cQuery += "FROM "+RetSqlName( "VOO" ) + " VOO "
						cQuery += "WHERE "
						cQuery += "VOO.VOO_FILIAL='"+ xFilial("VOO")+ "' AND "
						cQuery += "VOO.VOO_NUMNFI='"+(cAliasSF2)->F2_DOC+"' AND VOO.VOO_SERNFI='"+(cAliasSF2)->F2_SERIE+"' AND "
						cQuery += "VOO.D_E_L_E_T_=' ' ORDER BY VOO.VOO_NUMNFI, VOO.VOO_SERNFI"
						dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVOO, .T., .T. )
						
						If Select(cAliasVOI) > 0
							( cAliasVOI )->( DbCloseArea() )
						EndIf
						cQuery := "SELECT VOI.VOI_SITTPO "
						cQuery += "FROM "+RetSqlName( "VOI" ) + " VOI "
						cQuery += "WHERE "
						cQuery += "VOI.VOI_FILIAL='"+ xFilial("VOI")+ "' AND "
						cQuery += "VOI.VOI_TIPTEM='"+(cAliasVOO)->VOO_TIPTEM+"' AND "
						cQuery += "VOI.D_E_L_E_T_=' ' ORDER BY VOI.VOI_TIPTEM"
						dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVOI, .T., .T. )
						
						If (cAliasVOI)->VOI_SITTPO $ "2/4"
							aGrpPec[11,4] += nPvalvda
							aGrpPec[11,5] += nPcustot
							aTotPBO[2,1] += nPvalvda
							aTotPBO[2,2] += nPcustot
							aTotPec[1,1] += nPvalvda
							aTotPec[1,2] += nPcustot
							aTotal[1,1]  += nPvalvda
							aTotal[1,2]  += nPcustot
							nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "O" + "11" + "DEV    " })
							If nPos == 0
								aAdd(aNumPec,{ "O" , "11" , "DEV    " , STR0051 , nPvalvda , nPcustot })
							Else
								aNumPec[nPos,5] += nPvalvda
								aNumPec[nPos,6] += nPcustot
							EndIf
							
						ElseIf (cAliasVOI)->VOI_SITTPO == "3"
							aGrpPec[12,4] += nPcustot // nPvalvda
							aGrpPec[12,5] += nPcustot
							aTotPBO[2,1] += nPcustot // nPvalvda
							aTotPBO[2,2] += nPcustot
							aTotPec[1,1] += nPcustot // nPvalvda
							aTotPec[1,2] += nPcustot
							aTotal[1,1]  += nPcustot // nPvalvda
							aTotal[1,2]  += nPcustot
							nPos := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "O" + "12" + "DEV    " })
							If nPos == 0
								aAdd(aNumPec,{ "O" , "12" , "DEV    " , STR0051 , nPcustot , nPcustot })
							Else
								aNumPec[nPos,5] += nPcustot // nPvalvda
								aNumPec[nPos,6] += nPcustot
							EndIf
							
						Else
							
							cDCli := "S"
							nPos := 0
							nPos := aScan(aChave01,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Governo
							If nPos > 0
								cDCli := "N"
								aGrpPec[7,4] += nPvalvda
								aGrpPec[7,5] += nPcustot
								aTotPBO[2,1] += nPvalvda
								aTotPBO[2,2] += nPcustot
								aTotPec[1,1] += nPvalvda
								aTotPec[1,2] += nPcustot
								aTotal[1,1]  += nPvalvda
								aTotal[1,2]  += nPcustot
								nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "O" + "07" + "DEV    " })
								If nPos == 0
									aAdd(aNumPec,{ "O" , "07" , "DEV    " , STR0051 , nPvalvda , nPcustot })
								Else
									aNumPec[nPos,5] += nPvalvda
									aNumPec[nPos,6] += nPcustot
								EndIf
							Endif
							nPos := 0
							nPos := aScan(aChave02,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Frotistas
							If nPos > 0
								cDCli := "N"
								aGrpPec[8,4] += nPvalvda
								aGrpPec[8,5] += nPcustot
								aTotPBO[2,1] += nPvalvda
								aTotPBO[2,2] += nPcustot
								aTotPec[1,1] += nPvalvda
								aTotPec[1,2] += nPcustot
								aTotal[1,1]  += nPvalvda
								aTotal[1,2]  += nPcustot
								nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "O" + "08" + "DEV    " })
								If nPos == 0
									aAdd(aNumPec,{ "O" , "08" , "DEV    " , STR0051 , nPvalvda , nPcustot })
								Else
									aNumPec[nPos,5] += nPvalvda
									aNumPec[nPos,6] += nPcustot
								EndIf
							EndIf
							nPos := 0
							nPos := aScan(aChave03,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Seguradoras
							If nPos > 0
								cDCli := "N"
								aGrpPec[9,4] += nPvalvda
								aGrpPec[9,5] += nPcustot
								aTotPBO[2,1] += nPvalvda
								aTotPBO[2,2] += nPcustot
								aTotPec[1,1] += nPvalvda
								aTotPec[1,2] += nPcustot
								aTotal[1,1]  += nPvalvda
								aTotal[1,2]  += nPcustot
								nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "O" + "09" + "DEV    " })
								If nPos == 0
									aAdd(aNumPec,{ "O" , "09" , "DEV    " , STR0051 , nPvalvda , nPcustot })
								Else
									aNumPec[nPos,5] += nPvalvda
									aNumPec[nPos,6] += nPcustot
								EndIf
							EndIf
							If cDCli == "S"
								aGrpPec[10,4] += nPvalvda
								aGrpPec[10,5] += nPcustot
								aTotPBO[2,1] += nPvalvda
								aTotPBO[2,2] += nPcustot
								aTotPec[1,1] += nPvalvda
								aTotPec[1,2] += nPcustot
								aTotal[1,1]  += nPvalvda
								aTotal[1,2]  += nPcustot
								nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "O" + "10" + "DEV    " })
								If nPos == 0
									aAdd(aNumPec,{ "O" , "10" , "DEV    " , STR0051 , nPvalvda , nPcustot })
								Else
									aNumPec[nPos,5] += nPvalvda
									aNumPec[nPos,6] += nPcustot
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			DbSelectArea(cAliasSD1)
			Dbskip()
		EndDo
	EndIf
	DbSelectArea(cAliasSF1)
	Dbskip()
EndDo

Return
