#INCLUDE "PROTHEUS.CH" 
   
FUNCTION RegCaixa(dDtIni,dDtFim,nRBMensal,lMensal,lProcFil,cFilIni,cFilFin,nRBServ,nRBST,nRBLoc,nRBServRet,nRBMesExp)  
                               	
Local cAliasSE5	:= "SE5"
Local cAliasSE1	:= "SE1"
Local cAliasSD2 := "SD2" 
Local cAliasSF2 := "SF2"   
Local cAliasSF4	:= "SF4"
Local cAliasSB1 := "SB1" 
Local cAliasSFT := "SFT" 
Local cIndex    := ""
Local cFiltro   := ""             
Local lTop 		:= .F.       
Local cCNAE		:= ""      
Local aRBAcMan	:= ""
Local aAreaSm0	:= SM0->(GetArea())                               
Local cTesAtvMob:= GetNewPar("MV_TESATMB","")
Local nTotalRB 	:= 0		//Total da Receita Bruta
Local nDedTelCom:= 0
Local nValBrut	:= 0
Local nValIss	:= 0
Local lSe1MsFil	:=	SE1->(FieldPos("E1_MSFIL")) > 0
Local lSe5MsFil	:=	SE5->(FieldPos("E5_MSFIL")) > 0
Local nVlRetIss	:= 0
Local nValST	:= 0
Local nValLoc	:= 0    
Local cLocacao	:= GetNewPar("MV_LOCACAO","")
Local lUnidNeg 	:= Iif( FindFunction("FWCodFil") , FWSizeFilial() > 2, .F. ) // Verifica se utiliza Gestão Corporativa
Local cFilSe5	:= xFilial("SE5")
Local cFilSe1	:= xFilial("SE1")      
Local lNRastDSD	:= SuperGetMV("MV_NRASDSD",.T.,.F.) //Parametro que permite ao usuario utilizar o desdobramento da maneira anterior ao implementado com o rastremaento.
Local cBxSql	:= SuperGetMV("MV_MTBXF6",.T.,.F.)  
Local nPercBaix := 1             
Local nRBMensal	:= 0
Local nRBServ	:= 0
Local nRBServRet:= 0
Local nRBST		:= 0 
Local nRBLoc	:= 0 
Local nX := 0                                          
Default lProcFil:= .F.
Default cFilIni	:= ""
Default cFilFin	:= ""
Default nRBMesExp := 0

dBSelectArea("SE5")
(dbSetOrder(1)) 
dBSelectArea("SD2")
(dbSetOrder(3))                
dBSelectArea("SFT")
(dbSetOrder(1))
dBSelectArea("SF4")
(dbSetOrder(1))
dBSelectArea("SB1")
(dbSetOrder(1)) 

ProcRegua(LastRec())

If lUnidNeg
	cFilSe5	:= SM0->M0_CODFIL
	cFilSe1 := SM0->M0_CODFIL
Else
	cFilSe5	:= xFilial("SE5")
	cFilSe1 := xFilial("SE1")
Endif

If !Empty( Iif( lUnidNeg, FWFilial("SE5") , xFilial("SE5") ) )
		cWhere 	:= "SE5.E5_FILIAL = '"  + xFilial("SE5") + "' AND "
	Else
		If lSe5MsFil
			cWhere 	:= "SE5.E5_MSFIL = '" + Iif(lUnidNeg, cFilSe5, cFilAnt) + "' AND "					
		Else	
			cWhere 	:= "SE5.E5_FILORIG = '" + Iif(lUnidNeg, cFilSe5, cFilAnt) + "' AND "	
		Endif	
	EndIf   		
		
	If !Empty( Iif( lUnidNeg, FWFilial("SE1") , xFilial("SE1") ) )
		cWhere 	+= "SE1.E1_FILIAL = '"  + xFilial("SE1") + "' AND "
	Else
		If lSe1MsFil
			cWhere 	+= "SE1.E1_MSFIL = '" + Iif(lUnidNeg, cFilSe1, cFilAnt) + "' AND "					
		Else	
			cWhere 	+= "SE1.E1_FILORIG = '" + Iif(lUnidNeg, cFilSe1, cFilAnt) + "' AND "	
		Endif	
	EndIf   
							
	If  !lNRastDSD //Tratamento para desdobramento
		cWhere	+= "((SE1.E1_DESDOBR = '1' AND SE1.E1_BAIXA <>'' AND SE1.E1_SITUACA <> '') OR SE1.E1_DESDOBR <> '1') AND "
	Endif     
	//Exclui os titulos que possuem estorno
	cWhere	 	+= "SE5.E5_SEQ NOT IN "
	cWhere 		+= "(SELECT SE5AUX.E5_SEQ FROM "+RetSqlName("SE5")+" SE5AUX WHERE "
	cWhere		+= 		" SE5AUX.E5_FILIAL = SE5.E5_FILIAL AND "
	cWhere		+= 		" SE5AUX.E5_PREFIXO = SE5.E5_PREFIXO AND "
	cWhere		+= 		" SE5AUX.E5_NUMERO = SE5.E5_NUMERO AND  "
	cWhere		+= 		" SE5AUX.E5_PARCELA = SE5.E5_PARCELA AND " 
	cWhere		+= 		" SE5AUX.E5_TIPO = SE5.E5_TIPO AND " 
	cWhere		+= 		" SE5AUX.E5_CLIFOR = SE5.E5_CLIFOR AND " 
	cWhere		+= 		" SE5AUX.E5_LOJA = SE5.E5_LOJA AND "     
	cWhere		+= 		" SE5AUX.E5_TIPODOC = 'ES' AND "
	cWhere		+= 		" SE5AUX.D_E_L_E_T_ = '' "
	cWhere 		+= ") AND "
	
	cTipoTit		:=	""
	cTipoTit		:=	MVTAXA + "|" + MVABATIM + "|" + MV_CRNEG + "|" + MVPROVIS   // Titulos de Impostos
	cWhere 		+= "SE5.E5_TIPO NOT IN " + FormatIn(cTipoTit,If("|"$cTipoTit,"|",","))  + " AND " 
	
	cWhere		+= " ((SE5.E5_MOTBX <> 'FAT' AND SE5.E5_TIPO <> 'RA') OR (SE5.E5_MOTBX = 'CMP' AND SE5.E5_TIPODOC = 'CP' AND SE5.E5_TIPO = 'NF')) AND "	
		
	cBxCanc		:= "('LIQ'"
	
	If !Empty(cBxSql)
			cBxCanc += "," + cBxSql
	EndIf
	cBxCanc		+= ")"   
   	cWhere		+= "SE5.E5_MOTBX NOT IN " + cBxCanc + " AND "
	cWhere		+= "SE5.E5_SITUACA <> 'C' AND "		
	cWhere	 	+= "SE5.E5_RECPAG = 'R' "		//Somente titulos a receber (tabela SE1).
	cWhere		:= "%"+cWhere+"%"

#IFDEF TOP
If TcSrvType()<>"AS/400" 
	lTop   := .T.
	lQuery 		:= .T.       
	cAliasSE5 := GetNextAlias()
	BeginSql Alias cAliasSE5
		
		COLUMN E5_DATA AS DATE  
		COLUMN E1_EMISSAO AS DATE
		
		SELECT 	SE5.E5_FILIAL, 
			SE5.E5_PREFIXO, 
			SE5.E5_NUMERO, 
			SE5.E5_PARCELA, 
			SE5.E5_TIPO,
			SE5.E5_CLIFOR, 
			SE5.E5_LOJA, 
			SE5.E5_TIPODOC, 
			SE5.E5_MOTBX, 
			SE5.E5_DATA,
			SE5.E5_VALOR,  
			SE5.E5_DOCUMEN ,
			SE1.E1_VALOR , 
			SE1.E1_SERIE , 
			SE1.E1_DESDOBR , 
			SE1.E1_EMISSAO ,  
			SE1.E1_PEDIDO  
		FROM 
			%TABLE:SE5% SE5, %TABLE:SE1% SE1 
		WHERE 
			SE5.E5_PREFIXO = SE1.E1_PREFIXO 
			AND SE5.E5_NUMERO = SE1.E1_NUM 
			AND SE5.E5_PARCELA = SE1.E1_PARCELA 
			AND SE5.E5_TIPO = SE1.E1_TIPO 
			AND SE5.E5_CLIFOR = SE1.E1_CLIENTE 
			AND SE5.E5_LOJA = SE1.E1_LOJA   
			AND ( SE5.E5_DATA >= %EXP:DTOS(dDtIni)% 
   			AND SE5.E5_DATA <= %EXP:DTOS(dDtFim)% ) 
		    AND %EXP:cWhere%   
		    AND SE5.%NOTDEL% 
	        AND SE1.%NOTDEL% 
		ORDER BY E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA
	EndSql
	DbSelectArea (cAliasSE5)
     (cAliasSE5)->(DbGoTop())        
Else
#ENDIF
	cIndex    := CriaTrab(NIL,.F.)
	cFiltro := "E5_FILIAL=='"+xFilial("SE5")+"'.And."
	cFiltro += "Dtos(E5_DATA)>='" + Dtos(dDtIni) + "'.And."
	cFiltro += "Dtos(E5_DATA)<='" + Dtos(dDtFim) + "'.And."
	cFiltro += %EXP:cWhere% 
IndRegua(cAliasSE5,cIndex,SE5->(IndexKey()),,cFiltro)
nIndex := RetIndex("SE5")
dbSelectArea("SE5")   
       
#IFNDEF TOP
		dbSetIndex(cIndex+OrdBagExt())
#ENDIF
		
dbSetOrder(nIndex+1)
dbSelectArea(cAliasSE5)
ProcRegua(LastRec())
dbGoTop()
	    
#IFDEF TOP
	Endif    
#ENDIF 

If !lProcFil
	cFilIni := cFilAnt
	cFilFin := cFilAnt
Endif

cCNAE := SM0->M0_CNAE
dbSelectArea("SM0")
SM0->(dbSeek(cEmpAnt+cFilIni,.T.))
Do While !SM0->(Eof()).And. FWGrpCompany() + FWCodFil() <= cEmpAnt + cFilFin
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando estiver processando mais de uma filial, somente farao³
	//³parte do calculo da receita bruta as empresas com mesmo ramo³
	//³de atividade (CNAE).                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	If SM0->M0_CNAE <> cCNAE
		SM0->(dbSkip())
		Loop
	Endif 
	cFilAnt	:=	FWCodFil()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Receita Bruta Acumulada informada manualmente     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(GetNewPar("MV_RBACMAN",""))
		aRBAcMan := &(GetNewPar("MV_RBACMAN",{0,0}))
		For nX := 1 to Len(aRBAcMan)    
			nTotalRB+= aRBAcMan[nX,2]
		Next
	Endif
	
	If lTop
		cAliasSE5	:= cAliasSE5
		cAliasSE1	:= cAliasSE5				 				 
	EndIf       
	
	While (cAliasSE5)->(!Eof())   
		IF !lTop  
			//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO INDICE 1                                                                                                                                                                                                              
			(cAliasSE1)->(MsSeek(xFilial("SE1")+(cAliasSE5)->E5_PREFIXO+(cAliasSE5)->E5_NUMERO+(cAliasSE5)->E5_PARCELA+(cAliasSE5)->E5_TIPO))      
		ENDIF	 
		
	    dBSelectArea("SF2")
		(dbSetOrder(1))			
		IF (SF2->(MsSeek(xFilial("SF2")+(cAliasSE5)->E5_NUMERO+(cAliasSE1)->E1_SERIE+(cAliasSE5)->E5_CLIFOR+(cAliasSE5)->E5_LOJA)))
			#IFDEF TOP   
				If TcSrvType()<>"AS/400"
				   lTop   := .T.
					cAliasSF2 := GetNextAlias()
					BeginSql Alias cAliasSF2
						COLUMN F2_EMISSAO AS DATE
					SELECT 
						SD2.D2_CF, 
						SF4.F4_CODIGO, 
						SF4.F4_INCSOL, 
						SF4.F4_SITTRIB, 
						SF2.F2_EMISSAO, 
						SD2.D2_GRUPO, 
						SF2.F2_RECISS, 
						SF2.F2_VALFAT,
						SD2.D2_VALBRUT, 
						SD2.D2_BASEISS, 
						SD2.D2_ICMSRET,
						SF2.F2_EST   
					FROM 
					    %TABLE:SF2% SF2            
					    LEFT JOIN %TABLE:SD2% SD2 ON(SD2.D2_FILIAL = %XFILIAL:SD2% AND SF2.F2_DOC=SD2.D2_DOC AND SF2.F2_SERIE=SD2.D2_SERIE AND SF2.F2_CLIENTE=SD2.D2_CLIENTE AND SF2.F2_LOJA=SD2.D2_LOJA AND SD2.D_E_L_E_T_=' ') 
					    LEFT JOIN %TABLE:SFT% SFT ON(SFT.FT_FILIAL = %XFILIAL:SFT% AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND SD2.D2_CLIENTE=SFT.FT_CLIEFOR AND SD2.D2_LOJA=SFT.FT_LOJA AND SD2.D2_ITEM=SFT.FT_ITEM AND SFT.D_E_L_E_T_=' ')
					    LEFT JOIN %TABLE:SB1% SB1 ON(SB1.B1_FILIAL = %XFILIAL:SB1% AND SD2.D2_COD=SB1.B1_COD AND SB1.D_E_L_E_T_=' ')
					    LEFT JOIN %TABLE:SF4% SF4 ON(SF4.F4_FILIAL = %XFILIAL:SF4% AND SD2.D2_TES=SF4.F4_CODIGO AND SF4.D_E_L_E_T_=' ') 
					    WHERE
							SF2.F2_FILIAL=%XFILIAL:SF2%
							AND SF2.F2_CLIENTE =%Exp:(cAliasSE5)->E5_CLIFOR%
							AND SF2.F2_LOJA = %Exp:(cAliasSE5)->E5_LOJA%
							AND SF2.F2_DOC = %Exp:(cAliasSE5)->E5_NUMERO%
							AND SF2.F2_SERIE = %Exp:(cAliasSE1)->E1_SERIE%
							AND F2_TIPO IN('N','L','C','P') 
							AND SF2.D_E_L_E_T_=' '
					Order BY 1 
					EndSql
					dbSelectArea(cAliasSF2) 
				Else
					#ENDIF
   					dbSelectArea(cAliasSF2)
					cIndex	:=	CriaTrab(NIL,.F.)
					cFiltro	:=	"F2_FILIAL='"+xFilial("SF2")+"' AND F2_CLIENTE='"+(cAliasSE5)->E5_CLIFOR+"' AND F2_LOJA='"+(cAliasSE5)->E5_LOJA+"'AND F2_DOC='"+(cAliasSE5)->E5_NUMERO+"'AND F2_SERIE='"+(cAliasSE1)->E1_SERIE+"'AND F2_TIPO IN ('N','L','C','P')"	
					IndRegua(cAliasSF2,cIndSF2,IndexKey(),,cFiltro)
					(cAliasSF2)->(DbgoTop())
					
					nIndex := RetIndex("SF2")
					dbSelectArea("SF2")   		
					#IFNDEF TOP
						dbSetIndex(cIndex+OrdBagExt())
					#ENDIF
		
					dbSetOrder(nIndex+1)
					dbSelectArea(cAliasSF2)
					ProcRegua(LastRec())
					dbGoTop()
					
			#IFDEF TOP
				Endif    
			#ENDIF 	  
			
			If lTop
				cAliasSD2	:= cAliasSF2
				cAliasSF2	:= cAliasSF2
				cAliasSF4	:= cAliasSF2
				cAliasSB1	:= cAliasSF2
				cAliasSFT	:= cAliasSF2				 				 
			EndIf                         
			
			(cAliasSF2)->(DbGoTop ())
			While (cAliasSF2)->(!Eof())
				  //Verifica o percentual do titulo que foi baixado, pois vai pegar os valores de acordo com o perc baixado.
				  nPercBaix:= (((cAliasSE5)->E5_VALOR*100)/(cAliasSF2)->F2_VALFAT)/100	
				  nDedTelCom 	:= 0
	              nValBrut		:= 0
				  nValIss		:= 0
				  nVlRetIss		:= 0
				  nValICM		:= 0
				  nValST		:= 0
				  nValLoc		:= 0
				
				  IF !lTop  
			         //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM INDICE 3                                                                                                     
					 (cAliasSD2)->(MsSeek(xFilial("SD2")+(cAliasSF2)->F2_DOC+(cAliasSF2)->F2_SERIE+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA))
							
					 //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO INDICE 1                                                                                                                                                                                                                            
					 (cAliasSFT)->(MsSeek(xFilial("SFT")+IIF(substr((cAliasSD2)->D2_CF,1,1)<"5","E","S")+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_ITEM+(cAliasSD2)->D2_COD))
						       
					 //F4_FILIAL+F4_CODIGO INDICE 1                                                                                                                                           
					(cAliasSF4)->(MsSeek(xFilial("SF4")+(cAliasSD2)->D2_TES))
							                   		     
					 //B1_FILIAL+B1_COD INDICE 1                                                                                                                                             
					 (cAliasSB1)->(MsSeek(xFilial("SB1")+ (cAliasSD2)->D2_COD))           
				  ENDIF	 
	             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				 //³Receita Bruta ³
				 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !(cAliasSF2)->F4_CODIGO $ cTesAtvMob
						//Verifico se o valor de ISS foi Retido pelo Cliente, pois o valor nao deve ser apurado
						If (cAliasSF2)->F2_RECISS == "1"
							nVlRetIss	:=	(cAliasSD2)->D2_BASEISS * nPercBaix
						Else
							nValIss		:=	(cAliasSD2)->D2_BASEISS * nPercBaix
						Endif
						
						If (cAliasSD2)->D2_ICMSRET > 0 //ICMS-ST não é uma receita
							If !(cAliasSF4)->F4_INCSOL$"A,N,D"
								If ALLTRIM((cAliasSF4)->F4_SITTRIB)$"10/30/60/70"
									nValST		:= ((cAliasSD2)->D2_VALBRUT - (cAliasSD2)->D2_ICMSRET) * nPercBaix
								EndIf
								nValBrut 	:= ((cAliasSD2)->D2_VALBRUT - (cAliasSD2)->D2_ICMSRET) * nPercBaix
							Else
								If ALLTRIM((cAliasSF4)->F4_SITTRIB)$"10/30/60/70"
									nValST		:= (cAliasSD2)->D2_VALBRUT * nPercBaix
								EndIf
								nValBrut 	:= (cAliasSD2)->D2_VALBRUT * nPercBaix
							EndIf
						Else
							If ALLTRIM((cAliasSF4)->F4_SITTRIB)$"10/30/60/70"
								nValST		:= (cAliasSD2)->D2_VALBRUT * nPercBaix
							EndIf
							
							If (cAliasSD2)->D2_GRUPO $ cLocacao
								nValLoc 	:= (cAliasSD2)->D2_VALBRUT * nPercBaix
							Endif
							nValBrut 	:= (cAliasSD2)->D2_VALBRUT * nPercBaix
						EndIf
					EndIf	
													
					nTotalRB 		+= nValBrut  			// Acumulado
					nRBServ 		+= nValIss				// Acumulado Servico
					nRBServRet		+= nVlRetIss			// Acumulado Servico Retido
					nRBST			+= nValST				// Acumulado ST
					nRBLoc			+= nValLoc				// Acumulado Locacao
					nRBMensal 		+= nValBrut
					//Operação com o exterior
					If (cAliasSF2)->F2_EST=="EX"
						nRBMesExp 	+= nValBrut 	// Mensal exportacao					
					Endif		
					
				(cAliasSF2)->(dbSkip())
			Enddo
			(cAliasSF2)->(DbCloseArea())
		Else
			nRBMensal+= (cAliasSE5)->E5_VALOR
		EndIf
		(cAliasSE5)->(dbSkip())
	EndDo
	SM0->(dbSkip())
Enddo    
RestArea(aAreaSm0)
cFilAnt	:=	FWCodFil()
Return(nTotalRB)  		    			 	