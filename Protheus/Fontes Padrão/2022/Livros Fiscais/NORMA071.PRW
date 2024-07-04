#Include "Protheus.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³NORMA071  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 07.06.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³DIF-PAPEL IMUNE - Instrucao Normativa 71                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NORMA071()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Perguntas                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("INI071",.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tabela de Importacao de Estoques                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GeraTemp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa LayOut de Estoque                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Proc_1()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Proc_1    ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 07.12.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa LayOut de Estoques                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Proc_1()

Local cFilIni   := mv_par01       // Filial de ?
Local cFilFim   := mv_par02       // Filial Ate ?     
Local nRegEmp   := SM0->(RecNo())
Local aEmpresa	:= {}
Local cIndSF3	:= ""
Local cIndSB1	:= ""
Local cFiltro	:= ""
Local aStruSF3  := SF3->(dbStruct()) 
Local aStruSB1  := SB1->(dbStruct()) 
Local nEmpresa 	:= 1
Local nX		:= 0
Local aProd     :={}
Local cCHVSF3   :="" 
Local cAliasSB1 :="SB1"
Local cCodProd	:= ""
Local cCodTab	:= ""
Local nQuant	:= 0
Local nPeso  	:= 0
Local cTipoPD	:= ""
Local lAglut	:= ( MV_PAR06 == 1 )								// Define se aglutina registros no grupo de perguntas INI071 
Local nFor		:= 0

Private cAliasSF3	:= ""
Private lQuery		:= .F.
Private cCNPJEmp	:= ""
Private cINI071A	:= GetNewPar("MV_INI71","")	//Campos do B5 - Tipo Produto e Codigo da Tabela Papel/Publicacoes
Private cTrimest	:= RetChar(mv_par03,.T.,.F.,.F.,.T.,.F.,5,.F.) //Trimestre ?

If !Empty(cINI071A) .And. (Substr(cINI071A,1,1)=="{" .And. Substr(cINI071A,Len(cINI071A),1)=="}") .And. mv_par05 <> "MA"
	#IFDEF TOP
		If lAglut
			For nFor := 1 to Len(aFilsCalc)
				If aFilsCalc[nFor][1]
					aAdd(aEmpresa,{ cEmpAnt, aFilsCalc[nFor][2]})
				EndIf
			Next
		EndIf
	#ELSE
		dbSelectArea("SM0")
		dbSeek(cEmpAnt+cFilIni,.T.)	
		While !Eof() .and. FWGrpCompany() == cEmpAnt .and. FWCodFil() <= cFilFim
			aAdd(aEmpresa,{FWGrpCompany(),FWCodFil()})
			dbSkip()
		EndDo
		SM0->(dbGoTo(nRegEmp))
		cFilAnt := FWCodFil()
	#ENDIF
	
	If Len(aEmpresa) == 0
       	aAdd(aEmpresa, { cEmpAnt, cFilAnt } )
	EndIf	
	aEmpresa := asort(aEmpresa,,,{|x,y| x[2] < y[2] })
	
	While nEmpresa <= Len(aEmpresa)
		dbSelectArea("SM0")
		If dbSeek(aEmpresa[nEmpresa,1]+aEmpresa[nEmpresa,2],.T.)
			cFilAnt  := FWCodFil()
			cCNPJEmp := aFisFill(aRetDig(SM0->M0_CGC,.F.),14)
			cCHVSF3  :=""
			#IFDEF TOP
				If TcSrvType() <> "AS/400"
					lQuery := .T.
					cQuery := ""
				Endif
			#ENDIF
			dbSelectArea("SF3")
			dbSetOrder(4)			
			If lQuery
			    cAliasSF3	:= "TopSF3"
				cQuery 		:= "SELECT F3_FILIAL,F3_NFISCAL,F3_SERIE,F3_ENTRADA,"
				cQuery 		+= "F3_CLIEFOR,F3_LOJA,F3_VALCONT,F3_DTCANC," 
				cQuery 		+= "F3_CFO,F3_TIPO "					
				cQuery 		+= "FROM "+RetSqlName("SF3")+" "
				cQuery 		+= "WHERE "
				cQuery 		+= "F3_FILIAL = '"+ xFilial("SF3")+"' AND "
				cQuery 		+= "F3_ENTRADA >= '"+DTOS(dDmainc)+"' AND "
				cQuery 		+= "F3_ENTRADA <= '"+DTOS(dDmaFin)+"' AND "
				cQuery 		+= "D_E_L_E_T_ = ' '"
				cQuery      += "ORDER BY "+SqlOrder(SF3->(IndexKey()))
				
				cQuery 		:= ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
			
				For nX := 1 To Len(aStruSF3)
					If aStruSF3[nX][2] <> "C" .and. FieldPos(aStruSF3[nX][1]) > 0
						TcSetField(cAliasSF3,aStruSF3[nX][1],aStruSF3[nX][2],aStruSF3[nX][3],aStruSF3[nX][4])
					EndIf
				Next
			Else    

				cAliasSF3	:= "SF3"
				cIndSF3		:= CriaTrab(NIL,.F.)
				cFiltro		:= "SF3->F3_FILIAL=='"+xFilial("SF3")+"' .And. DTOS(SF3->F3_ENTRADA)>='"+DTOS(dDmainc)+"' .And. DTOS(SF3->F3_ENTRADA)<='"+DTOS(dDmaFin)+"'"
				IndRegua(cAliasSF3,cIndSF3,SF3->(IndexKey()),,cFiltro)
			Endif		

			dbSelectArea(cAliasSF3)
			dbGoTop()
			While !Eof()
                //So processa se o registro do SF3 nao for referente a mesma nota
                If cCHVSF3<>(cAliasSF3)->F3_FILIAL+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE
	                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Processa Entradas e Saidas            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Left((cAliasSF3)->F3_CFO,1) < "5"
						Proc_E(@aProd)
					Else
						Proc_S(@aProd)
					Endif
                EndIf

				//Guardar chave para nao processar mais de uma vez a mesma nota fiscal qdo gerar mais de um registro no SF3
                  cCHVSF3 := (cAliasSF3)->F3_FILIAL+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE                
                  
				dbSelectArea(cAliasSF3)
				dbSkip()
			EndDo
			
			If lQuery
				dbSelectArea(cAliasSF3)
				dbCloseArea()
			Else
				RetIndex("SF3")
				dbClearFilter()
				Ferase(cIndSF3+OrdBagExt())  
	        EndIF
			If FWModeAccess("SF3",3)=="C"
				Exit
			Endif		
			  // Pegar os produtos DIF que nao tiveram movimentação no periodo mas que possuem estoque
			  
				If lQuery
	                cAliasSB1	:= "TopSB1"
					cQuery 		:= "SELECT B1_COD,B1_LOCPAD,B1_PESO "
					cQuery 		+= "FROM "+RetSqlName("SB1")+" "
					cQuery 		+= "WHERE "
					cQuery 		+= "B1_FILIAL = '"+ xFilial("SB1")+"' AND "
					cQuery 		+= "B1_COD NOT IN (SELECT D1_COD FROM "+RetSqlName("SD1")+" "
					cQuery 		+= "WHERE "
					cQuery 		+= "D1_EMISSAO >= '"+DTOS(dDmainc)+"' AND "
					cQuery 		+= "D1_EMISSAO <= '"+DTOS(dDmaFin)+"' AND D_E_L_E_T_ = ' ' "
					cQuery 		+= "UNION "
					cQuery 		+= "SELECT D2_COD "
					cQuery 		+= "FROM "+RetSqlName("SD2")+" "				
					cQuery 		+= "WHERE "
					cQuery 		+= "D2_EMISSAO >= '"+DTOS(dDmainc)+"' AND "
					cQuery 		+= "D2_EMISSAO <= '"+DTOS(dDmaFin)+"' AND D_E_L_E_T_ = ' ') AND "				
					cQuery 		+= "D_E_L_E_T_ = ' '"
					cQuery      += "ORDER BY "+SqlOrder(SB1->(IndexKey()))
					
					cQuery 		:= ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB1,.T.,.T.)
				
					For nX := 1 To Len(aStruSB1)
						If aStruSB1[nX][2] <> "C" .and. FieldPos(aStruSB1[nX][1]) > 0
							TcSetField(cAliasSB1,aStruSB1[nX][1],aStruSB1[nX][2],aStruSB1[nX][3],aStruSB1[nX][4])
						EndIf
					Next

				Else
			
					cAliasSB1	:= "SB1"
					cIndSB1		:= CriaTrab(NIL,.F.)
					cFiltro		:= "SB1->B1_FILIAL=='"+xFilial("SB1")+"'"
					IndRegua(cAliasSB1,cIndSB1,SB1->(IndexKey()),,cFiltro)
		    	EndIf
			    	
				dbSelectArea(cAliasSB1)  			
				dbGoTop()
				While !Eof()			
				If SB1->(dbSeek(xFilial("SB1")+(cAliasSB1)->B1_COD))			
					SB5->(dbSetOrder(1))
	    	       	SB5->(dbSeek(xFilial("SB5")+(cAliasSB1)->B1_COD))
	   				aRetDif := &cINI071A
	   				If Len(aRetDif) == 2
						cTipoPD		:= Alltrim(aRetDif[1])
						cCodTab		:= IIf(cTipoPD == "S","00000",StrZero(Val(aRetDif[2]),5))
						cCodProd	:= (cAliasSB1)->B1_COD
						cLocal		:= (cAliasSB1)->B1_LOCPAD
						nPeso       := (cAliasSB1)->B1_PESO
	                    lConvert    := .F.
	                            
		   				If cTipoPD $ "P/L"	//P-Papel  L-Livros
			  					    //Se não for TOP pego apenas os produtos que não existem no array aProd que são os que tiveram movimentação e que são DIF
			  					    //Se for TOP já traz os produtos corretos e não preciso varrer o array aProd
				  					If !lQuery 
									   If !Ascan(aProd,(cAliasSB1)->B1_COD)==0
									      Exit
									   EndIf
									EndIf   
	  					
			   			    If cTipoPD == "P"  // Papel tem que calcular a quantidade em Kilograma
						        If nPeso <> 0 
						       	   lConvert    := .T.
						       	EndIf
						    EndIf   
	   					
			   				EstReg(cTipoPD,"",cCNPJEmp,cTrimest,cCodTab,cCodProd,,cLocal,lConvert,nPeso,@aProd)
						EndIf	
					EndIf	
				EndIf
				dbSelectArea(cAliasSB1)
				dbSkip()
			EndDo	
			
			nEmpresa++
			If lQuery
				dbSelectArea(cAliasSB1)
				dbCloseArea()
			Else
				RetIndex("SB1")
				dbClearFilter()
				Ferase(cIndSB1+OrdBagExt())  
	        EndIF
		Endif		
	EndDo
	SM0->(dbGoTo(nRegEmp))
	cFilAnt := FWCodFil()
EndIf
		
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Proc_E    ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 07.12.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Entradas                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Proc_E(aProd)

Local aArea		:= GetArea()
Local lIntegra  := If(GetMV("MV_EASY")=="S",.T.,.F.)
Local cCNPJ		:= ""
Local cCodTab	:= ""
Local cCodProd	:= ""
Local nQuant	:= 0 
Local nPeso     := 0
Local cTipoPD	:= ""
Local cLocal	:= ""
Local cINI071B	:= GetNewPar("MV_INI71B","")	//Cfops de Entradas por Transferencias
Local cINI071R	:= GetNewPar("MV_INI71R","")	//Cfops que devem ser Considerados como Outras

If (cAliasSF3)->F3_TIPO$"BD"
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
	cCNPJ := aFisFill(aRetDig(SA1->A1_CGC,.F.),14)
Else 
	SA2->(dbSetOrder(1))
    SA2->(dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
    cCNPJ := aFisFill(aRetDig(SA2->A2_CGC,.F.),14)
EndIf 
				
cCNPJ := If(lIntegra,cCNPJEmp,cCNPJ)
					
If	Len(cCNPJ) >= 14 .And. Empty((cAliasSF3)->F3_DTCANC)	.And. ;
	(mv_par05 <> "FP" .Or. (mv_par05 == "FP" .And. Alltrim((cAliasSF3)->F3_CFO) == "1201" .Or. Alltrim((cAliasSF3)->F3_CFO) == "2201"))
	
	dbSelectArea("SF1")			
	dbSetOrder(1) 
	dbSeek(xFilial("SF1")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)
	
	dbSelectArea("SWN")
	dbSetOrder(2)	
	dbSeek(xFilial("SWN")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)

	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSeek(xFilial("SD1")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)
	
	While !Eof() .And. xFilial("SD1") == SD1->D1_FILIAL .And. ;
	 	SD1->D1_DOC == (cAliasSF3)->F3_NFISCAL .And. SD1->D1_SERIE == (cAliasSF3)->F3_SERIE .And. ; 
		SD1->D1_FORNECE == (cAliasSF3)->F3_CLIEFOR .And. SD1->D1_LOJA == (cAliasSF3)->F3_LOJA .And. SD1->D1_TIPO $ "NDB"
								
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Entradas por Importacao               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lIntegra .And. SF1->F1_IMPORT == "S"
			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES))	   
			If SF4->F4_ESTOQUE == "S"
				SWN->(dbSetOrder(1))
           		SWN->(dbSeek(xFilial("SWN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_TEC))
           		While SWN->(!Eof()) .And. ;
           			SWN->WN_FILIAL+SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_TEC == xFilial("SWN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_TEC
					SB1->(dbSetOrder(1))
					If SB1->(dbSeek(xFilial("SB1")+SWN->WN_PRODUTO))
						SB5->(dbSetOrder(1))
	    	       		SB5->(dbSeek(xFilial("SB5")+SWN->WN_PRODUTO))
		   				aRetDif := &cINI071A
		   				If Len(aRetDif) == 2
							cTipoPD		:= Alltrim(aRetDif[1])
							cCodTab		:= IIf(cTipoPD == "S","00000",StrZero(Val(aRetDif[2]),5))
							cCodProd	:= SWN->WN_PRODUTO
							cLocal		:= SD1->D1_LOCAL
							nPeso       := SB1->B1_PESO
                            lConvert    := .F.
                            
			   				 If cTipoPD == "P"	//Papel
			   				 
			   				   // Papel tem que calcular a quantidade em Kilograma
			   				     If nPeso <> 0
			   				        nQuant  := SWN->WN_QUANT * nPeso
			   				        lConvert := .T.
						         Else
						            nQuant := SWN->WN_QUANT
						         Endif
						         
						       	EstReg(cTipoPD,"EI",cCNPJEmp,cTrimest,cCodTab,cCodProd,nQuant,cLocal,lConvert,nPeso,@aProd)
        	       	   	 EndIf
        	       	   	 
            	      Endif
           		Endif
               	   	SWN->(dbSkip())
				   EndDo
         EndIf	
		Else
           	SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES))
           	If SF4->F4_ESTOQUE == "S"
				SB1->(dbSetOrder(1))
				If SB1->(dbSeek(xFilial("SB1")+SD1->D1_COD))
					SB5->(dbSetOrder(1))
    	       		SB5->(dbSeek(xFilial("SB5")+SD1->D1_COD))				
					aRetDif := &cINI071A
					If Len(aRetDif) == 2
						cTipoPD		:= Alltrim(aRetDif[1])
						cCodTab		:= If(cTipoPD == "S","00000",StrZero(Val(aRetDif[2]),5))
						cCodProd	:= SD1->D1_COD
						cLocal		:= SD1->D1_LOCAL 
						nPeso       := SB1->B1_PESO
						lConvert    := .F.

		   				If cTipoPD $ "P/L"	//P-Papel  L-Livros
	   						Do Case
	   							Case AllTrim(SD1->D1_CF) $ cINI071R	//Outras
	   								cTpMov := "EO"			
	   							Case AllTrim(SD1->D1_CF) $ cINI071B	//Transferencia
		   							cTpMov := "ET"
								Case SD1->D1_TIPO == "D"	//Devolucao
		   							cTpMov := "ED"
								Case SD1->D1_TIPO $ " N"	//Normal
		   							cTpMov := "EN"
								Case SD1->D1_TIPO == "B"	//Terceiros
		   							cTpMov := "E3"
		   						Otherwise
		   							cTpMov := "EO"			//Outras
		   					EndCase  
		   					
				   			    If cTipoPD == "P"  // Papel tem que calcular a quantidade em Kilograma
							        If nPeso <> 0 
							       	  nQuant      := SD1->D1_QUANT * nPeso
							       	  lConvert    := .T.
							       	Else
							       	  nQuant      := SD1->D1_QUANT
							       	EndIf  
							    Else
							      nQuant := SD1->D1_QUANT
							    EndIf   
		   					
		   						EstReg(cTipoPD,cTpMov,cCNPJEmp,cTrimest,cCodTab,cCodProd,nQuant,cLocal,lConvert,nPeso,@aProd)
						   EndIf	
			      EndIf			
			  	EndIf
			   EndIf	
		EndIf
		dbSelectArea("SD1")							
		dbSkip()
	EndDo
EndIf 
RestArea(aArea)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Proc_S    ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 07.12.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Saidas                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Proc_S(aProd)

Local aArea		:= GetArea()
Local cCNPJ		:= ""
Local cCodProd	:= ""
Local cCodTab	:= ""
Local nQuant	:= 0
Local nPeso  	:= 0
Local cTipoPD	:= ""
Local cINI071C	:= GetNewPar("MV_INI71C","")	//Cfops de Saidas por Transferencias
Local cINI071R	:= GetNewPar("MV_INI71R","")	//Cfops que devem ser Considerados como Outras
Local cINI71F4	:= GetNewPar("MV_IN71F4","")	

If (cAliasSF3)->F3_TIPO$"BD"
   	SA2->(dbSetOrder(1))
    SA2->(dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))	
    cCNPJ := aFisFill(aRetDig(SA2->A2_CGC,.F.),14)
Else 
	SA1->(dbSetOrder(1))
    SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
    cCNPJ := aFisFill(aRetDig(SA1->A1_CGC,.F.),14)
EndIf

If Len(cCNPJ) >= 11 .And. Empty((cAliasSF3)->F3_DTCANC)          
	dbSelectArea("SD2")
	dbSetOrder(3)			
	dbSeek(xFilial("SD2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA) 

	While !Eof() .And. xFilial("SD2") == SD2->D2_FILIAL .And. ;
		SD2->D2_DOC == (cAliasSF3)->F3_NFISCAL .And. SD2->D2_SERIE == (cAliasSF3)->F3_SERIE .And. ;
		SD2->D2_CLIENTE == (cAliasSF3)->F3_CLIEFOR .And. SD2->D2_LOJA == (cAliasSF3)->F3_LOJA .And. SD2->D2_TIPO $ "NDB"
							
		SF4->(dbSetOrder(1))
		SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))	   
		If SF4->F4_ESTOQUE == "S" .OR. (!Empty(cINI71F4) .AND. SF4->(FieldPos(cINI71F4))>0 .AND. SF4->(FieldGet(FieldPos(cINI71F4)))=="1")
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+SD2->D2_COD))
				SB5->(dbSetOrder(1))
           		SB5->(dbSeek(xFilial("SB5")+SD2->D2_COD))
				aRetDif := &cINI071A
				If Len(aRetDif) == 2
					cTipoPD		:= Alltrim(aRetDif[1])
					cCodTab		:= IIf(cTipoPD == "S","00000",StrZero(Val(aRetDif[2]),5))
					cCodProd	:= SD2->D2_COD
					cLocal		:= SD2->D2_LOCAL
					nPeso       := SB1->B1_PESO
                    lConvert    := .F.
                    
                  
					If cTipoPD $ "P/L"	//P-Papel  L-Livros
						Do Case
							Case AllTrim(SD2->D2_CF) $ cINI071R	//Outras
	   							cTpMov := "SO"			
							Case AllTrim(SD2->D2_CF) $ cINI071C	//Transferencia
								cTpMov := "ST"
							Case SD2->D2_TIPO == "D"	//Devolucao
								cTpMov := "SD"
							Case SD2->D2_TIPO $ " N"	//Normal
								cTpMov := "SN"
							Case SD2->D2_TIPO == "B"	//Terceiros
								cTpMov := "E3"
							Otherwise
								cTpMov := "SO"			//Outras
						EndCase
						
	                        If cTipoPD == "P"  // Papel tem que calcular a quantidade em Kilograma
						        If nPeso <> 0 
						       	  nQuant      := SD2->D2_QUANT * nPeso
						       	  lConvert    := .T.
						       	Else
						       	  nQuant      := SD2->D2_QUANT
						       	EndIf  
						    Else
						      nQuant := SD2->D2_QUANT
						    EndIf   
						
						EstReg(cTipoPD,cTpMov,cCNPJEmp,cTrimest,cCodTab,cCodProd,nQuant,cLocal,lConvert,nPeso,@aProd)
					Endif	
			    EndIf			
		    EndIf
		EndIf	
		dbSelectArea("SD2")			
		dbSkip()
	EndDo
Endif

RestArea(aArea)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³EstReg    ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 07.12.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Importacao de Estoques                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function EstReg(cTipoPD,cTpMov,cCNPJEmp,cTrimest,cCodTab,cCodProd,nQuant,cLocal,lConvert,nPeso,aProd)

Local aArea		:= GetArea()
Local aSaldo	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava Registro Tipo 0 - Dados do Estoque de Papel         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipoPD == "P"	//Papel
	dbSelectArea("EST")
	dbSetOrder(1)
	If !dbSeek("0"+cCodTab)
		aSaldo := Sld3(cCodProd,cLocal)
        //Se o Saldo for zero e não for nenhuma movimentação não deve entrar
		If Int(aSaldo[1])==0 .And. Int(aSaldo[2])==0 .And. cTpMov==""
			Return ()
		EndIf	
		RecLock("EST",.T.)
		EST->TPREG		:= "0"			//Tipo de Registro
		EST->CNPJ		:= cCNPJEmp		//CNPJ do Estabelecimento
		EST->TRIMESTRE	:= cTrimest		//Trimestre/Ano de Referencia
		EST->CODIGO		:= cCodTab		//Codigo do Papel
	    
	    If lConvert // Converte em Kilograma  
		  EST->SLD3ANT	:= aSaldo[1] *	nPeso //Saldo Anterior
		  EST->SLD3FIM	:= aSaldo[2] * nPeso //Saldo Final
		Else
		  EST->SLD3ANT	:= aSaldo[1]  //Saldo Anterior
		  EST->SLD3FIM	:= aSaldo[2]  //Saldo Final
		EndIf
		
		Aadd(aProd,cCodProd)//Adiciono o Produto no Array para futura verificacao
		
	Else
		RecLock("EST",.F.)
		//Se o Tipo de Papel já existir e o Código do Produto for diferente, o Saldo do mesmo deve ser acumulado.
		If Ascan(aProd,cCodProd)==0
			aSaldo := Sld3(cCodProd,cLocal)  
			
			If lConvert // Converte em Kilograma  
			  EST->SLD3ANT	+= aSaldo[1] *	nPeso //Saldo Anterior
			  EST->SLD3FIM	+= aSaldo[2] * nPeso //Saldo Final
			Else
			  EST->SLD3ANT	+= aSaldo[1]  //Saldo Anterior
			  EST->SLD3FIM	+= aSaldo[2]  //Saldo Final
			EndIf
				
			Aadd(aProd,cCodProd)//Adiciono o Produto no Array para futura verificacao  
		EndIf
		
	Endif
	EST->ENT		+= IIf(cTpMov=="EN",nQuant,0)	//EN=Entrada Normal
	EST->ENTIMP		+= IIf(cTpMov=="EI",nQuant,0)	//EI=Entrada Importacao
	EST->ENTTRA		+= IIf(cTpMov=="ET",nQuant,0)	//ET=Entrada Transferencia
	EST->ENTDEV		+= IIf(cTpMov=="ED",nQuant,0)	//ED=Entrada Devolucao
	EST->ENTOUT		+= IIf(cTpMov=="EO",nQuant,0)	//EO=Entrada Outras
	EST->SAI		+= 0							//Saidas Impressao Propria
	EST->SAI3		+= IIf(cTpMov=="S3",nQuant,0)	//SN=Saidas Impressao em Terceiros
	EST->SAITRA		+= IIf(cTpMov=="ST",nQuant,0)	//SN=Saidas Transferencias
	EST->SAIDEV		+= IIf(cTpMov=="SD",nQuant,0)	//SN=Saidas Devolucoes
	EST->SAIVEN		+= IIf(cTpMov=="SN",nQuant,0)	//SN=Saidas Vendas
	EST->SAIOUT		+= IIf(cTpMov=="SO",nQuant,0)	//SN=Saidas Outras
	MsUnlock()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava Registro Tipo 2 - Dados do Estoque de Livros        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipoPD == "L"	//Livros
	dbSelectArea("EST")
	dbSetOrder(1)
	If !dbSeek("2"+cCodTab)
		aSaldo := Sld3(cCodProd,cLocal)
		//Se o Saldo for zero e não for nenhuma movimentação não deve entrar
		If (Int(aSaldo[1])==0 .And. Int(aSaldo[2])==0 .And. cTpMov=="")
			Return ()
		EndIf	
		RecLock("EST",.T.)
		EST->TPREG		:= "2"				//Tipo de Registro
		EST->CNPJ		:= cCNPJEmp			//CNPJ do Estabelecimento
		EST->TRIMESTRE	:= cTrimest			//Trimestre/Ano de Referencia
		EST->CODIGO		:= cCodTab			//Codigo da Publicacao
		EST->SLD3ANT	:= Int(aSaldo[1])	//Saldo Anterior
		EST->SLD3FIM	:= Int(aSaldo[2])	//Saldo Final
     
		Aadd(aProd,cCodProd)//Adiciono o Produto no Array para futura verificacao
	Else
		RecLock("EST",.F.)	
		
			//Se o Tipo de Publicacao já existir e o Código do Produto for diferente, o Saldo do mesmo deve ser acumulado.
		If Ascan(aProd,cCodProd)==0
			aSaldo := Sld3(cCodProd,cLocal)  
			
			  EST->SLD3ANT	+= Int(aSaldo[1])  //Saldo Anterior
			  EST->SLD3FIM	+= Int(aSaldo[2])  //Saldo Final
				
			Aadd(aProd,cCodProd) //Adiciono o Produto no Array para futura verificacao 
		EndIf
		
	
	Endif
	EST->ENT		+= IIf(cTpMov=="EN",Int(nQuant),0)	//EN=Entrada Impressao Propria
	EST->ENT3		+= IIf(cTpMov=="E3",Int(nQuant),0)	//E3=Entrada Impressao em Terceiros
	EST->ENTTRA		+= IIf(cTpMov=="ET",Int(nQuant),0)	//ET=Entrada Transferencia
	EST->ENTDEV		+= IIf(cTpMov=="ED",Int(nQuant),0)	//ED=Entrada Devolucao
	EST->ENTOUT		+= IIf(cTpMov=="EO",Int(nQuant),0)	//EO=Entrada Outras
	EST->SAIVEN		+= IIf(cTpMov=="SN",Int(nQuant),0)	//SN=Saidas Vendas
	EST->SAITRA		+= IIf(cTpMov=="ST",Int(nQuant),0)	//SN=Saidas Transferencias
	EST->SAIDEV		+= IIf(cTpMov=="SD",Int(nQuant),0)	//SN=Saidas Devolucao
	EST->SAIOUT		+= IIf(cTpMov=="SO",Int(nQuant),0)	//SN=Saidas Outras
	MsUnlock()
Endif

RestArea(aArea)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Sld3      ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 07.12.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Calcula os Saldos do Trimestre Inicial e Final              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Sld3(cCodProd,cLocal)

Local aArea		:= GetArea()
Local aAreaSB2	:= SB2->(GetArea())
Local nSldIni	:= 0
Local nSldFim	:= 0

dbSelectArea("SB2")
dbSetOrder(1)
If dbSeek(xFilial("SB2")+cCodProd)
	While !Eof() .And. xFilial("SB2")+cCodProd == SB2->B2_FILIAL+SB2->B2_COD
		aSaldo	:= CalcEst(SB2->B2_COD,SB2->B2_LOCAL,dDmainc)
			nSldIni	+= aSaldo[1]
	
		aSaldo	:= CalcEst(SB2->B2_COD,SB2->B2_LOCAL,dDmaFin+1)
			nSldFim	+= aSaldo[1]		    
		dbSkip()
	Enddo
Else
	aSaldo	:= CalcEst(cCodProd,cLocal,dDmainc)
	  nSldIni	+= aSaldo[1]
		
	aSaldo	:= CalcEst(cCodProd,cLocal,dDmaFin+1)
	  nSldFim	+= aSaldo[1]		    
	    

Endif
RestArea(aAreaSB2)
RestArea(aArea)

Return({nSldIni,nSldFim})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GeraTemp  ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 07.12.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivos temporarios                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTemp()

Local aCpo	:= {}
Local cArq	:= ""

If Select("EST")>0
	EST->(dbCloseArea())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tabela de Importacao de Estoques                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCpo	:= {}
cArq	:= ""
AADD(aCpo,{"TPREG"		,"C",001,0})	//Tipo de Registro
AADD(aCpo,{"CNPJ"		,"C",014,0})	//CNPJ do Estabelecimento
AADD(aCpo,{"TRIMESTRE"	,"C",005,0})	//Trimestre/Ano de referencia
AADD(aCpo,{"CODIGO"		,"C",005,0})	//Codigo do Papel/Publicacao
AADD(aCpo,{"SLD3ANT"	,"N",020,2})	//Saldo do Trimestre Anterior
AADD(aCpo,{"ENT"		,"N",020,2})	//Entrada-Aquisicao Mercado Interno
AADD(aCpo,{"ENT3"		,"N",020,2})	//Entrada-Impressao em Terceiros
AADD(aCpo,{"ENTIMP"		,"N",020,2})	//Entrada-Importacao
AADD(aCpo,{"ENTTRA"		,"N",020,2})	//Entrada-Transferencia
AADD(aCpo,{"ENTDEV"		,"N",020,2})	//Entrada-Devolucoes
AADD(aCpo,{"ENTOUT"		,"N",020,2})	//Entrada-Outras
AADD(aCpo,{"SAI"		,"N",020,2})	//Saidas-Impressao Propria
AADD(aCpo,{"SAI3"		,"N",020,2})	//Saidas-Impressao em Terceiros
AADD(aCpo,{"SAITRA"		,"N",020,2})	//Saidas-Transferencias
AADD(aCpo,{"SAIDEV"		,"N",020,2})	//Saidas-Devolucoes
AADD(aCpo,{"SAIVEN"		,"N",020,2})	//Saidas-Vendas
AADD(aCpo,{"SAIOUT"		,"N",020,2})	//Saidas-Outras
AADD(aCpo,{"SLD3FIM"	,"N",020,2})	//Saldo Final do Trimestre

cArq := CriaTrab(aCpo)
dbUseArea(.T.,__LocalDriver,cArq,"EST")
IndRegua("EST",cArq,"TPREG+CODIGO")

Return Nil


