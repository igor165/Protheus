#Include "Protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GIASTRJ   ³ Autor ³ Sueli C. Santos       ³ Data ³ 04.08.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³GIASTRJ - Guia de Informacao e Apuracao do ICMS Mensal de   ³±±
±±³          ³Substituicao Tributaria do RJ								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD -> Data incial do periodo - mv_par01     			  ³±±
±±³          ³ExpD -> Data final do periodo - mv_par02                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GIASTRJ(dDtInicial, dDtFinal)
	Local aTrbs		:= {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera arquivos temporarios            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTrbs := GeraTemp()
	
	Processa({||ProGIAST(dDtInicial, dDtFinal)})


Return (aTrbs)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProGIAST   ³ Autor ³Sueli C. Santos        ³ Data ³ 04.08.08 ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro da GIAST-RJ                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProGIAST(dDtInicial, dDtFinal)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa Regitros                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	ProcPrinc(dDtInicial, dDtFinal)		//Registro Principal

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProGIAST   ³ Autor ³Sueli C. Santos        ³ Data ³ 04.08.08 ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processamento do Registro Principal                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcPrinc(dDtInicial, dDtFinal)
	Local cAliasSD1 	:= "SD1"
	Local cAliasSD2    	:= "SD2"
	Local cRessarST     := Getnewpar("MV_RESST","")
	Local cCombusST     := Getnewpar("MV_COMBST","")
	Local cTransfST     := Getnewpar("MV_TRANFST","")
	Local nVlrProd 		:= 0
	Local nVlrIPI       := 0
	Local nVlrDesp		:= 0
	Local nVlrIcms  	:= 0
	Local nBaseST  		:= 0
	Local nVlrST		:= 0
	Local nBaseProp  	:= 0
	Local nVlrDev       := 0
	Local nVlrRessarc   := 0
	Local nVlrComb      := 0
	Local cVencto       := ""
	Local nValorV       := 0
	Local nContRG1      := 0
	Local nContRG2      := 0
	Local nContRG3      := 0
	Local aTam:= TamSX3("A1_COD")
	Local cMvFornece    := Padr(GetMv("MV_RECEST"),aTam[1])
	Local lQuery		:= .F.
	Local cInscrEst     := ""
     
	#IFDEF TOP
		Local aStruSD2 	:=	{}  
		Local aStruSD1  := {}
		Local cQuery   	:=	""
		Local nX		:=	0
	#ELSE
		Local cInd		:=	""
		Local cChave	:=	""
		Local cFiltro	:=	""
		Local nRetInd	:=	0
	#ENDIF
	   	
	#IFDEF TOP    
    If TcSrvType()<>"AS/400"
		lQuery		:= .T.
		cAliasSD2	:= "SD2_GIAST"
		aStruSD2	:= SD2->(dbStruct())
		cQuery		:= "SELECT * "
		cQuery    	+= "FROM " + RetSqlName("SD2") + " "
		cQuery    	+= "WHERE D2_FILIAL = '" + xFilial("SD2") + "' AND "
		cQuery 		+= "D2_EMISSAO >= '" + Dtos(dDtInicial) + "' AND "				
		cQuery 		+= "D2_EMISSAO <= '" + Dtos(dDtFinal) + "' AND "	
		cQuery    	+= "D2_ICMSRET > 0  AND D2_TIPO NOT IN ('C','B','S') AND "
		cQuery    	+= "D_E_L_E_T_=' ' "
		cQuery 		:= ChangeQuery(cQuery)                       
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2)
		For nX := 1 To len(aStruSD2)
			If aStruSD2[nX][2] <> "C" .And. FieldPos(aStruSD2[nX][1])<>0
				TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
			EndIf
		Next nX

	Else
	#ENDIF
	    cIndex    := CriaTrab(NIL,.F.)
		cCondicao := 'D2_FILIAL == "' + xFilial("SD2") + '" .And. '
		cCondicao += 'DTOS(D2_EMISSAO) >= "' + Dtos(dDtInicial) + '" .And. '
		cCondicao += 'DTOS(D2_EMISSAO) <= "' + Dtos(dDtFinal) + '" .And. ' 
		cCondicao += 'D2_ICMSRET > 0 .And. ! D2_TIPO $ "C/B/S" '

	    IndRegua(cAliasSD2,cIndex,SD2->(IndexKey()),,cCondicao)
	    dbSelectArea(cAliasSD2)
	    ProcRegua(LastRec())
	    dbGoTop()
	#IFDEF TOP
		Endif    
	#ENDIF
	 
	Do While !((cAliasSD2)->(Eof()))   
		If (cAliasSD2)->D2_TIPO =='D'   		
	 		dbSelectArea("SA2") 
			SA2->(DbSetOrder(1))
			SA2->(DbSeek(xFilial("SA2")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
			cInscrEst := SA2->A2_INSCR
		Else		                                                                            
			dbSelectArea("SA1") 
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial("SA1")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
			cInscrEst := SA1->A1_INSCR
		EndIf
		
		dbSelectArea("SF2")        
		SF2->(dbSetOrder(1))
		SF2->(dbSeek(xFilial("SF2")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA,.T.))
		
		If SF2->F2_EST == 'RJ'      
			nVlrProd	+= (cAliasSD2)->D2_TOTAL
			nVlrIPI		+= (cAliasSD2)->D2_VALIPI		
			nVlrDesp 	+= SF2->F2_DESPESA+SF2->F2_SEGURO +SF2->F2_FRETE
			nBaseProp   += (cAliasSD2)->D2_BASEICM  
	 		nVlrIcms    += (cAliasSD2)->D2_VALICM
			nBaseST     += (cAliasSD2)->D2_BRICMS  
	 		nVlrST      += (cAliasSD2)->D2_ICMSRET 		  
	 		
	 		If (cAliasSD2)->D2_TIPO =='D'  	 			
	 			nContRG1 += 1
				dbSelectArea("RG1")
				RecLock("RG1",.T.)								
				RG1->NFISCAL	:= RetNf((cAliasSD2)->D2_DOC,8,"N")
				RG1->SERIE  	:= SerieNfId(cAliasSD2,2,"D2_SERIE")
				RG1->IE		:= cInscrEst
				RG1->EMISSAO	:= Dtos((cAliasSD2)->D2_EMISSAO)
				RG1->ICMSDEV	:= (cAliasSD2)->D2_ICMSRET
	         	RG1->CONTRG1  := nContRG1
		 		nVlrDev 		+= (cAliasSD2)->D2_ICMSRET
				MsUnlock()
			EndIf			
			                                                  
			If Alltrim((cAliasSD2)->D2_CF)$cRessarST   
				nContRG2 += 1
				dbSelectArea("RG2")
				RecLock("RG2",.T.)				
				RG2->NFISCAL	:= RetNf((cAliasSD2)->D2_DOC,8,"N")
				RG2->SERIE  	:= SerieNfId(cAliasSD2,2,"D2_SERIE")
				RG2->IE		:= cInscrEst
				RG2->EMISSAO	:= Dtos((cAliasSD2)->D2_EMISSAO)
				RG2->ICMSRES	:= (cAliasSD2)->D2_ICMSRET
				RG2->CONTRG2  += 1
	         	nVlrRessarc	+= (cAliasSD2)->D2_ICMSRET
				MsUnlock()
			EndIf
			
	 		nVlrComb 	+= Iif( Alltrim((cAliasSD2)->D2_CF)$cCombusST,(cAliasSD2)->D2_ICMSRET, 0) 
	
		EndIf
 		
		(cAliasSD2)->(dbSkip())
	Enddo                      
	        
	        
	#IFDEF TOP    
    If TcSrvType()<>"AS/400"
		lQuery		:= .T.
		cAliasSD1	:= "SD1_GIAST"
		aStruSD1	:= SD1->(dbStruct())
		cQuery		:= "SELECT D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_BRICMS, D1_ICMSRET, D1_CF "
		cQuery    	+= "FROM " + RetSqlName("SD1") + " "
		cQuery    	+= "WHERE D1_FILIAL = '" + xFilial("SD1") + "' AND "
		cQuery 		+= "D1_DTDIGIT >= '" + Dtos(dDtInicial) + "' AND "				
		cQuery 		+= "D1_DTDIGIT <= '" + Dtos(dDtFinal) + "' AND "	
		cQuery    	+= "D1_ICMSRET > 0  AND D1_TIPO NOT IN ('C','B','S') AND "
		cQuery    	+= "D_E_L_E_T_=' ' "
		cQuery 		:= ChangeQuery(cQuery)                       
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1)
		For nX := 1 To len(aStruSD1)
			If aStruSD1[nX][2] <> "C" .And. FieldPos(aStruSD1[nX][1])<>0
				TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
			EndIf
		Next nX

	Else
	#ENDIF
	    cIndex    := CriaTrab(NIL,.F.)
		cCondicao := 'D1_FILIAL == "' + xFilial("SD1") + '" .And. '
		cCondicao += 'DTOS(D1_DTDIGIT) >= "' + Dtos(dDtInicial) + '" .And. '
		cCondicao += 'DTOS(D1_DTDIGIT) <= "' + Dtos(dDtFinal) + '" .And. ' 
		cCondicao += 'D1_ICMSRET > 0 .And. ! D1_TIPO $ "C/B/S" '

	    IndRegua(cAliasSD1,cIndex,SD1->(IndexKey()),,cCondicao)
	    dbSelectArea(cAliasSD1)
	    ProcRegua(LastRec())
	    dbGoTop()
	#IFDEF TOP
	Endif    
	#ENDIF
	 
	Do While !((cAliasSD1)->(Eof())) 
	
		If Alltrim((cAliasSD1)->D1_CF)$cTransfST 
	
			dbSelectArea("SA2") 
			SA2->(DbSetOrder(1))
			SA2->(DbSeek(xFilial("SA2")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))

			dbSelectArea("SF1")        
			SF1->(dbSetOrder(1))
			SF1->(dbSeek(xFilial("SF1")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA,.T.))
			
			If SF1->F1_EST == 'RJ'      
		  		
				dbSelectArea("RG3")  
				IF !RG3->(dbSeek(Alltrim(SA2->A2_INSCR)))
					RecLock("RG3",.T.)
					RG3->IE		 	:= SA2->A2_INSCR 
					RG3->BASE		:= (cAliasSD1)->D1_BRICMS
					RG3->ICMSTR		:= (cAliasSD1)->D1_ICMSRET 
					RG3->CONTRG3    += 1
					nContRG3 		+= 1
				Else                 
					RecLock("RG3",.F.)
					RG3->BASE		+= (cAliasSD1)->D1_BRICMS
					RG3->ICMSTR		+= (cAliasSD1)->D1_ICMSRET					
				EndIf               
				MsUnlock()           
			EndIf
		Endif			
		(cAliasSD1)->(dbSkip())
	EndDo		                                          
	                  
	dbSelectArea("SE2")        
 	SE2->(dbSetOrder(6))
   	SE2->(dbSeek( xFilial("SE2")+ cMvFornece +"00"+"ICM", .T.))
   	            
   	Do While !(SE2->(Eof()))  
	   	If Substr(Dtos(SE2->E2_EMISSAO),1,6)== Substr(Dtos(dDtInicial),1,6) .And. ALLTRIM(SE2->E2_TIPO) == "TX"
   			cVencto  := Dtos(SE2->E2_VENCTO)
   			nValorV  := SE2->E2_SALDO
   		EndIf
   		SE2->(dbSkip())
   	EndDo
   		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processamento Registro RGP	            		                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       
	
	dbSelectArea("RGP")
	RecLock("RGP",.T.) 
	RGP->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
	RGP->VENCTO	 	:= cVencto
	RGP->VALORV	 	:= Iif(!Empty(cVencto),nValorV,0)
	RGP->VLRPROD   	:= nVlrProd
	RGP->VLRIPI   	:= nVlrIPI
	RGP->DESP       := nVlrDesp
	RGP->BASECALC  	:= nBaseProp
	RGP->ICMSPROP 	:= nVlrIcms	
	RGP->BASEST  	:= nBaseSt
	RGP->ICMSSUBST 	:= nVlrST   
	RGP->DEVOL	 	:= nVlrDev
	RGP->RESSARC 	:= nVlrRessarc
	RGP->COMBUST 	:= nVlrComb
	RGP->IMPDEV 	:= nVlrST - nVlrDev -  nVlrRessarc 
	RGP->CREDPER 	:= 0
	RGP->TOTALREC   := (nVlrST - nVlrDev -  nVlrRessarc ) + nVlrComb
	RGP->CIDADE     := SuperGetMv("MV_CIDADE")
	RGP->DATAP      := Dtos(dDataBase)  
	RGP->CONTRG1    := nContRG1
	RGP->CONTRG2    := nContRG2
	RGP->CONTRG3    := nContRG3
	MsUnlock()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho utilizada - SD1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lQuery
		RetIndex("SD2")	
		dbClearFilter()	
		Ferase(cIndex+OrdBagExt())
		
		RetIndex("SD1")	
		dbClearFilter()	
	Else
		dbSelectArea(cAliasSD1)
		dbSelectArea(cAliasSD2)
		dbCloseArea()

	Endif

Return Nil				

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraTemp   ³ Autor ³Sueli c. Santos        ³ Data ³ 04.04.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivos temporarios                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTemp()
	Local aStru		:= {}
	Local aTrbs		:= {}
	Local cArq		:= ""   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo P - registro Principal                                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aStru,{"PERIODOREF"	,"C",006,0})	//Periodo de Referencia - MMAAAA
	AADD(aStru,{"VENCTO"	    ,"C",008,0})	
	AADD(aStru,{"VALORV"    	,"N",015,2})	
	AADD(aStru,{"UF"		    ,"C",002,0})   	 
	AADD(aStru,{"VLRPROD"		,"N",015,2})   
	AADD(aStru,{"VLRIPI"		,"N",015,2})	
	AADD(aStru,{"DESP"			,"N",015,2})  	
	AADD(aStru,{"BASECALC"		,"N",015,2})  
	AADD(aStru,{"ICMSPROP"		,"N",015,2}) 
	AADD(aStru,{"BASEST"		,"N",015,2})
	AADD(aStru,{"ICMSSUBST"		,"N",015,2})	
	AADD(aStru,{"DEVOL"	    	,"N",015,2})
	AADD(aStru,{"RESSARC"		,"N",015,2})
	AADD(aStru,{"COMBUST"		,"N",015,2})
	AADD(aStru,{"IMPDEV"    	,"N",015,2})	
	AADD(aStru,{"CREDPER"   	,"N",015,2})	
	AADD(aStru,{"TOTALREC"  	,"N",015,2})	
	AADD(aStru,{"CIDADE"		,"C",030,0}) 
	AADD(aStru,{"DATAP"	    	,"C",008,2})	
	AADD(aStru,{"CONTRG1"    	,"N",004,0})	
	AADD(aStru,{"CONTRG2"    	,"N",004,0})		
	AADD(aStru,{"CONTRG3"    	,"N",004,0})	

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RGP")
	IndRegua("RGP",cArq,"PERIODOREF")
	AADD(aTrbs,{cArq,"RGP"})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Anexo I                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""  
	AADD(aStru,{"NFISCAL"		,"C",008,0})   	
	AADD(aStru,{"SERIE"     	,"C",003,0})   
	AADD(aStru,{"IE"       	    ,"C",014,0}) 
	AADD(aStru,{"EMISSAO"    	,"C",008,0}) 
	AADD(aStru,{"ICMSDEV"    	,"N",015,2})
	AADD(aStru,{"CONTRG1"     	,"N",004,0})

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RG1")                      	
	IndRegua("RG1",cArq,"NFISCAL")
	AADD(aTrbs,{cArq,"RG1"})
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Anexo II                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""  
	AADD(aStru,{"NFISCAL"		,"C",008,0})
	AADD(aStru,{"SERIE"  		,"C",003,0})
	AADD(aStru,{"IE"       		,"C",014,0})
	AADD(aStru,{"EMISSAO"    	,"C",008,0})
	AADD(aStru,{"ICMSRES"    	,"N",015,2})
	AADD(aStru,{"CONTRG2"     	,"N",004,0})

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RG2")                      	
	IndRegua("RG2",cArq,"NFISCAL")
	AADD(aTrbs,{cArq,"RG2"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Anexo III                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""       
	AADD(aStru,{"IE"       		,"C",014,0}) 	//Codigo CFOP - Verificar Tabela
	AADD(aStru,{"BASE"      	,"N",015,2}) 	//Base de Calculo
	AADD(aStru,{"ICMSTR"    	,"N",015,2})	//Insentas/Nao Tributadas
	AADD(aStru,{"CONTRG3"     	,"N",004,0})	//Outras

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RG3")                      	
	IndRegua("RG3",cArq,"IE")
	AADD(aTrbs,{cArq,"RG3"})

Return (aTrbs)

 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GIASTDEL    ºAutor  ³Sueli C. Santos     º Data ³ 04.08.2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta os arquivos temporarios processados                    º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GIARJST                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/         
Function GIASTDEL(aDelArqs)
	Local aAreaDel := GetArea()
	Local nI := 0
	
	For nI:= 1 To Len(aDelArqs)
		If File(aDelArqs[nI,1]+GetDBExtension())
			dbSelectArea(aDelArqs[ni,2])
			dbCloseArea()
			Ferase(aDelArqs[nI,1]+GetDBExtension())
			Ferase(aDelArqs[nI,1]+OrdBagExt())
		Endif	
	Next
	
	RestArea(aAreaDel)
	
Return
	
