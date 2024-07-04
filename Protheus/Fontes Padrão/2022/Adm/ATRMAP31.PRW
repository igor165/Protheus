#INCLUDE "PROTHEUS.ch"
#INCLUDE "ATRMAP31.ch"
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | ATRMAP31		     | AUTOR | microsiga    | DATA | 30/05/2008 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | 										                        |//
//|           | 												                |//
//|           | Funcao de impressao                                             |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////    
	Function ATRMAP31(lEnd,wnrel,cString)
	
		//CABECALHO
		CabMap31 (lEnd,wnrel,cString)
		
		
		//DADOS
		DadosMp31 (lEnd,wnrel,cString)		

		If aReturn[5] == 1
		   Set Printer TO
		   dbCommitAll()
		   Ourspool(wnrel)
		EndIf
		
		Ms_Flush()		
	
	Return

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | ATRMAP31		     | AUTOR | microsiga    | DATA | 30/05/2008 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | 										                        |//
//|           | 												                |//
//|           | Funcao de impressao do cabecalho                                |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
	
	
	Function CabMap31 (lEnd,wnrel,cString)
	
	//+--------------------
	//| Declaracao de variaveis
	//+--------------------
	Local cTraco1	:= "-"
	Local cTraco2	:= "|" 	
	Local nLi 		:= 0
	Local aCol		:= {}
 		   
	//+--------------------
	//| Coluna de impressao
	//+--------------------
	aAdd( aCol, 001 ) //DESCRICAO
	aAdd( aCol, 030 ) //VALOR DE REALIZACAO
	aAdd( aCol, 050 ) //ANO AQUIS
	aAdd( aCol, 056 ) //VALOR DE AQUIS
	aAdd( aCol, 076 ) //VALOR DE AQUIS REAVALIADO
	aAdd( aCol, 096 ) //VL AMORTIZAÇÕES PRATICADAS
	aAdd( aCol, 116 ) //VALIAS CONT SINAL
	aAdd( aCol, 124 ) //VALIAS CONT VALOR
	aAdd( aCol, 137 ) //VALIAS NAO TRIBUTADAS
	aAdd( aCol, 157 ) //AMORTIZACOES EFEITO FISCAIS
	aAdd( aCol, 177 ) //COEF
	aAdd( aCol, 182 ) //VL LIQ ACTUALIZADO
	aAdd( aCol, 202 ) //VALIAS FIS SINAL
	aAdd( aCol, 208 ) //VALIAS FIS VALOR
    

	//+--------------------
	//| TRACO SUPERIOR
	//+--------------------  
	For nLi := 1 to Limite 
		@ Li, nLi  PSay cTraco1
	Next nLi	
	Li++
	
	//+--------------------
	//| CABECALHO 
	//+--------------------
	@ Li,001  PSay cTraco2   
	@ Li,029  PSay STR0001 //"M A P A  D A S   M A I S - V A L I A S   E   M E N O S - V A  L I A S   F I S C A I S"
	@ Li,147  PSay cTraco2
	@ Li,149  PSay STR0002 //"  NATUREZA DOS BENS   "
	@ Li,173  PSay cTraco2
	@ Li,220  PSay cTraco2
	li++
	
	@ Li,001  PSay cTraco2   
	@ Li,147  PSay cTraco2
	nLi := 0
	For nLi := 1 to 24
		@ Li,148  PSay cTraco1
	NEXT nLi		
	@ Li,173  PSay cTraco2
	@ Li,220  PSay cTraco2
	Li++	
    
	dBSelectArea("SM0")
	DBSETORDER(1)
	DBSEEK(cEmpAnt+cFilAnt)
		
	@ Li,001  PSay cTraco2
	@ Li,002  PSay STR0003 //"FIRMA : "
	@ Li,010  PSay ALLTRIM(SM0->M0_NOMECOM)
	@ Li,116  PSay STR0004 //"EXERCICIO DE : "
	@ Li,134  PSay MV_PAR02	
	@ Li,147  PSay cTraco2    
	IF MV_PAR05 == 1 .OR. MV_PAR05 == 4
		@ Li,148  PSay STR0005     //" IMOBILIZADO CORPOREO "
	ELSE
		@ Li,148  PSay "                      "    		
	ENDIF
	@ Li,173  PSay cTraco2    
	@ Li,220  PSay cTraco2    
	LI++
	
	@ Li,001  PSay cTraco2
	@ Li,147  PSay cTraco2    
	IF MV_PAR05 == 2 .OR. MV_PAR05 == 4
		@ Li,148  PSay STR0006     //" IMOBILIZADO INCORPOREO"
	ELSE 
		@ Li,148  PSay "                       "    	
	ENDIF	
	@ Li,173  PSay cTraco2    
	@ Li,175  PSay STR0007    	 //"                  M O D E L O "
	@ Li,220  PSay cTraco2    
	LI++
	
	@ Li,001  PSay cTraco2                                                            
	@ Li,090  PSay STR0008 //"N INDETIFICACAO FISCAL :"
	@ Li,116  PSay SUBSTR(SM0->M0_CGC,1,9) PICTURE "@E 999999999" 
	@ Li,147  PSay cTraco2    
	IF MV_PAR05 == 3 .OR. MV_PAR05 == 4	
		@ Li,148  PSay STR0009     //" IMOBILIZADO FINANCEIRO"
	ELSE 
		@ Li,148  PSay "                       "    	
	ENDIF	
	@ Li,173  PSay cTraco2    
	@ Li,175  PSay STR0010    	 //"                     3 1 "
	@ Li,220  PSay cTraco2    
	LI++
	//+--------------------
	//| TRACO INFERIOR
	//+--------------------
	nLi := 0
	For nLi := 1 to limite
		@ Li, nLi  PSay cTraco1
	Next nLi	
	Li++
	
	//+--------------------
	//| CABECALHO DAS COLUNAS
	//+--------------------  
	For nLi := 1 to limite 
		@ Li, nLi  PSay cTraco1
	Next nLi	
	Li++	
	
	
	//+--------------------
	//| LINHA 1 COLUNA
	//+--------------------
                                                     
	@ Li,aCol[1]  PSay STR0011	 //"|        DESCRICAO           "
	@ Li,aCol[2]  PSay STR0012 //"|     VALOR DE      "
	@ Li,aCol[3]  PSay STR0013 //"| ANO "
	@ Li,aCol[4]  PSay STR0014 //"|    VALOR DE       "
	@ Li,aCol[5]  PSay STR0015 //"|   VL DE AQUIS     "
	@ Li,aCol[6]  PSay STR0016 //"|  AMORTIZACOES     "
	@ Li,aCol[7]  PSay STR0017 //"|     MAIS-VALIAS    "
	@ Li,aCol[9]  PSay STR0018 //"|    MAIS-VALIAS    "
	@ Li,aCol[10] PSay STR0019 //"|   AMORTIZACOES   "
	@ Li,aCol[11] PSay STR0020 //"|COEF"
	@ Li,aCol[12] PSay STR0021 //"|      VL LIQD      "
	@ Li,aCol[13] PSay STR0022 //"|   VALIAS FISCAL |"
	Li++	

	//+--------------------
	//| LINHA 2 COLUNA
	//+--------------------
                                                     
	@ Li,aCol[1]  PSay STR0023 //"|                            "
	@ Li,aCol[2]  PSay STR0024 //"|    REALIZACAO     "
	@ Li,aCol[3]  PSay STR0025 //"|AQUIS"
	@ Li,aCol[4]  PSay STR0026 //"|     AQUIS         "
	@ Li,aCol[5]  PSay STR0027 //"|   REAVALIADO      "
	@ Li,aCol[6]  PSay STR0028 //"|   PRATICADAS      "
	@ Li,aCol[7]  PSay STR0029 //"| SINAL "
	@ Li,aCol[8]  PSay STR0030 //"|    VALOR   "
	@ Li,aCol[9]  PSay STR0031 //"|  CONTABILISTICAS  "
	@ Li,aCol[10] PSay STR0032 //"|   EFEITO FISCAL   "
	@ Li,aCol[11] PSay STR0033 //"|MOED"
	@ Li,aCol[12] PSay STR0034 //"|     ATUALIZADO    "
	@ Li,aCol[13] PSay STR0035 //"|SINAL"
	@ Li,aCol[14] PSay STR0036 //"|   VALOR   |"
    LI++


	//+--------------------
	//| TRACO INFERIOR
	//+--------------------
	nLi := 0
	For nLi := 1 to limite
		@ Li, nLi  PSay cTraco1
	Next nLi	
	Li++
	
	
	

    Return


///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | ATRMAP31		     | AUTOR | microsiga    | DATA | 30/05/2008 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | 										                        |//
//|           | 												                |//
//|           | Funcao de impressao e processamento dos dados                   |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////



	Function DadosMp31 (lEnd,wnrel,cString)    

	//+--------------------
	//| Declaracao de variaveis
	//+--------------------
	Local cTraco2	:= "|" 	
	Local aCol		:= {}
    Local cQuery 	:= ""
    Local cRngFil  	:= ""
	Local nVLValias := 0
	Local nVlLiq    := 0
	Local nVlAmort  := 0
	Local nVlFis	:= 0
 	Local nVlCol12  := 0
 	
	Local nTotCol2  := 0
	Local nTotCol8	:= 0
 	Local nTotCol12 := 0
 		   
	//+--------------------
	//| Coluna de impressao
	//+--------------------
	aAdd( aCol, 001 ) //DESCRICAO
	aAdd( aCol, 030 ) //VALOR DE REALIZACAO
	aAdd( aCol, 050 ) //ANO AQUIS
	aAdd( aCol, 056 ) //VALOR DE AQUIS
	aAdd( aCol, 076 ) //VALOR DE AQUIS REAVALIADO
	aAdd( aCol, 096 ) //VL AMORTIZAÇÕES PRATICADAS
	aAdd( aCol, 116 ) //VALIAS CONT SINAL
	aAdd( aCol, 124 ) //VALIAS CONT VALOR
	aAdd( aCol, 137 ) //VALIAS NAO TRIBUTADAS
	aAdd( aCol, 157 ) //AMORTIZACOES EFEITO FISCAIS
	aAdd( aCol, 177 ) //COEF
	aAdd( aCol, 182 ) //VL LIQ ACTUALIZADO
	aAdd( aCol, 202 ) //VALIAS FIS SINAL
	aAdd( aCol, 208 ) //VALIAS FIS VALOR

  
    MakeSqlExpr("ATRMAP")
                         
    cRngFil := MV_PAR01
    
    IF MV_PAR05 == 1  
	    
	    #IFDEF TOP
		    If TcSrvType() <> "AS/400"
		    	cQuery	:= "SELECT N1_FILIAL, N1_CBASE, N1_ITEM, N1_AQUISIC, N1_DESCRIC, N3_FILIAL, N3_CBASE, "
		    	cQuery	+= " N3_ITEM, N3_TIPO, N3_VORIG1, N3_VRDACM1, N3_VRCDA1, N3_TXDEPR1, N3_AMPLIA1, N3_VRCACM1, N4_FILIAL, N4_CBASE, 
   			    cQuery	+= "N4_ITEM, N4_TIPO, N4_OCORR, N4_MOTIVO, N4_VENDA " 
				cQuery	+= " FROM " + RetSqlName("SN1")+","+ RetSqlName("SN3")+ "," + RetSqlName("SN4")

				IF EMPTY(cRngFil) .OR. cRngFil == NIL
						cQuery	+= " WHERE N1_FILIAL = '" + cFilAnt + "'"
				ELSE 
						cQuery	+= " WHERE "+cRngFil				
				ENDIF		
				cQuery	+= " AND N1_PATRIM = 'N'"

				IF ! EMPTY(cRngFil) .OR. cRngFil == NIL
					cRngFil := STRTRAN (cRngFil, "N1_FILIAL","N3_FILIAL")
		 		ENDIF	
				
				IF EMPTY(cRngFil) .OR. cRngFil == NIL
						cQuery	+= " AND N3_FILIAL = '" + cFilAnt + "'"
				ELSE 
						cQuery	+= " AND "+cRngFil				
				ENDIF		

				cQuery	+= " AND N3_CBASE = N1_CBASE"				
				cQuery	+= " AND N3_ITEM  = N1_ITEM"				
				cQuery	+= " AND N3_TIPO  = '02'"

				
				IF ! EMPTY(cRngFil) .OR. cRngFil == NIL
					cRngFil := STRTRAN (cRngFil, "N1_FILIAL","N4_FILIAL")
		 		ENDIF	
				
				IF EMPTY(cRngFil) .OR. cRngFil == NIL
						cQuery	+= " AND N4_FILIAL = '" + cFilAnt + "'"
				ELSE 
						cQuery	+= " AND "+cRngFil				
				ENDIF						


				cQuery	+= " AND N4_CBASE = N1_CBASE"				
				cQuery	+= " AND N4_ITEM  = N1_ITEM"				
				cQuery	+= " AND N4_MOTIVO = '01'"
				
				cQuery := ChangeQuery(cQuery)
				
				If ( Select ( "TMPN1" ) <> 0 )
					dbSelectArea ( "TMPN1" )
					dbCloseArea ()
				Endif
			
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPN1",.T.,.F.)
				
				dbSelectArea("TMPN1")
				
				WHILE 	TMPN1->(!EOF())
	
					@ li, aCol[001]   PSay cTraco2
					@ li, aCol[001]+1 PSay SUBSTR(TMPN1->N1_DESCRIC,1,28)
					@ li, aCol[002]   PSay cTraco2
					@ li, aCol[002]+1 PSay TMPN1->N4_VENDA PICTURE "@E 999,999.99"
					@ li, aCol[003]   PSay cTraco2
					@ li, aCol[003]+1 PSay SUBSTR(TMPN1->N1_AQUISIC,1,4) 
					@ li, aCol[004]   PSay cTraco2
					@ li, aCol[004]+1 PSay TMPN1->N3_VORIG1 PICTURE "@E 999,999.99"					
 					@ li, aCol[005]   PSay cTraco2
					@ li, aCol[005]+1 PSay TMPN1->N3_VORIG1 PICTURE "@E 999,999.99"					
 					@ li, aCol[006]   PSay cTraco2
					@ li, aCol[006]+1 PSay TMPN1->N3_VRDACM1 PICTURE "@E 999,999.99"										
 					@ li, aCol[007]   PSay cTraco2
 					
 					nVLValias := (TMPN1->N3_VORIG1 + TMPN1->N3_AMPLIA1 + TMPN1->N3_VRCACM1) - TMPN1->N4_VENDA
 					nVlLiq    := TMPN1->N3_VORIG1 + TMPN1->N3_AMPLIA1 + TMPN1->N3_VRCACM1
 					nVlAmort  := TMPN1->N3_VORIG1 * TMPN1->N3_TXDEPR1
 					nVlCol12  := (TMPN1->N3_VORIG1 - nVlLiq - nVlAmort) * TMPN1->N3_TXDEPR1	
 					
 					IF nVLValias > 0 
						@ li, aCol[007]+1 PSay "+"										
                    ELSE
						@ li, aCol[007]+1 PSay "-"										
					ENDIF
 					@ li, aCol[008]   PSay cTraco2
					@ li, aCol[008]+1 PSay ABS(nVLValias) PICTURE "@E 999,999.99"
 					@ li, aCol[009]   PSay cTraco2
					@ li, aCol[009]+1 PSay ABS(nVlLiq) PICTURE "@E 999,999.99"
 					@ li, aCol[010]   PSay cTraco2
					@ li, aCol[010]+1 PSay nVlAmort  PICTURE "@E 999,999.99"
 					@ li, aCol[011]   PSay cTraco2
					@ li, aCol[011]+1 PSay ROUND(TMPN1->N3_TXDEPR1,2) PICTURE "@E 9.99" 
					@ li, aCol[012]   PSay cTraco2
					@ li, aCol[012]+1 PSay ABS(nVlCol12) PICTURE "@E 999,999.99"

					nVlFis	:=	N4_VENDA - nVlCol12			
					
					@ li, aCol[013]   PSay cTraco2
 					IF nVlFis > 0 
						@ li, aCol[013]+1 PSay "+"										
                    ELSE
						@ li, aCol[013]+1 PSay "-"										
					ENDIF

					@ li, aCol[014]	  PSay cTraco2					
					@ li, aCol[014]+1 PSay ABS(nVlFis) PICTURE "@E 999,999.99"					
					@ li, 220		  PSay cTraco2					
                    Li++
                    
                   	nTotCol2  += TMPN1->N4_VENDA
					nTotCol8  += nVLValias
				 	nTotCol12 += nVlFis
                    
                    
                    
					//+--------------------
					//| TOTAL OU TRANSPORTE
					//+--------------------		            
					If Li > 55 
			            TotGerMp31 (Li,nTotCol2,nTotCol8,nTotCol12)
	                    Li := 0         
				   		CabMap31 (lEnd,wnrel,cString)
                    EndIf
                    
                    
                   
                    TMPN1->(dbskip())
                    
                    // ZERO AS VARIAVEIS PARA NÃO CARREGAR SUJEIRA 
                    nVLValias := 0
					nVlLiq    := 0
					nVlAmort  := 0
					nVlFis	  := 0
				 	nVlCol12  := 0
                    
                Enddo
                
                //+--------------------
				//| TOTAL OU TRANSPORTE
				//+--------------------
	       		TotGerMp31 (Li,nTotCol2,nTotCol8,nTotCol12)
				
		    ENDIF
		#ENDIF
		
	ELSEIF MV_PAR05 == 2  
	
		#IFDEF TOP
		    If TcSrvType() <> "AS/400"
		    	cQuery	:= "SELECT N1_FILIAL, N1_CBASE, N1_ITEM, N1_AQUISIC, N1_DESCRIC, N3_FILIAL, N3_CBASE, "
		    	cQuery	+= " N3_ITEM, N3_TIPO, N3_VORIG1, N3_VRDACM1, N3_VRCDA1, N3_TXDEPR1, N3_AMPLIA1, N3_VRCACM1, N4_FILIAL, N4_CBASE, 
   			    cQuery	+= "N4_ITEM, N4_TIPO, N4_OCORR, N4_MOTIVO, N4_VENDA " 
				cQuery	+= " FROM " + RetSqlName("SN1")+","+ RetSqlName("SN3")+ "," + RetSqlName("SN4")

				IF EMPTY(cRngFil) .OR. cRngFil == NIL
						cQuery	+= " WHERE N1_FILIAL = '" + cFilAnt + "'"
				ELSE 
						cQuery	+= " WHERE "+cRngFil				
				ENDIF		
				cQuery	+= " AND N1_PATRIM = 'A'"

				IF ! EMPTY(cRngFil) .OR. cRngFil == NIL
					cRngFil := STRTRAN (cRngFil, "N1_FILIAL","N3_FILIAL")
		 		ENDIF	
				
				IF EMPTY(cRngFil) .OR. cRngFil == NIL
						cQuery	+= " AND N3_FILIAL = '" + cFilAnt + "'"
				ELSE 
						cQuery	+= " AND "+cRngFil				
				ENDIF		

				cQuery	+= " AND N3_CBASE = N1_CBASE"				
				cQuery	+= " AND N3_ITEM  = N1_ITEM"				
				cQuery	+= " AND N3_TIPO  = '02'"

				
				IF ! EMPTY(cRngFil) .OR. cRngFil == NIL
					cRngFil := STRTRAN (cRngFil, "N1_FILIAL","N4_FILIAL")
		 		ENDIF	
				
				IF EMPTY(cRngFil) .OR. cRngFil == NIL
						cQuery	+= " AND N4_FILIAL = '" + cFilAnt + "'"
				ELSE 
						cQuery	+= " AND "+cRngFil				
				ENDIF						


				cQuery	+= " AND N4_CBASE = N1_CBASE"				
				cQuery	+= " AND N4_ITEM  = N1_ITEM"				
				cQuery	+= " AND N4_MOTIVO = '01'"
				
				cQuery := ChangeQuery(cQuery)
				
				If ( Select ( "TMPN1" ) <> 0 )
					dbSelectArea ( "TMPN1" )
					dbCloseArea ()
				Endif
			
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPN1",.T.,.F.)
				
				dbSelectArea("TMPN1")
				
				WHILE 	TMPN1->(!EOF())
	
					@ li, aCol[001]   PSay cTraco2
					@ li, aCol[001]+1 PSay SUBSTR(TMPN1->N1_DESCRIC,1,28)
					@ li, aCol[002]   PSay cTraco2
					@ li, aCol[002]+1 PSay TMPN1->N4_VENDA PICTURE "@E 999,999.99"
					@ li, aCol[003]   PSay cTraco2
					@ li, aCol[003]+1 PSay SUBSTR(TMPN1->N1_AQUISIC,1,4) 
					@ li, aCol[004]   PSay cTraco2
					@ li, aCol[004]+1 PSay TMPN1->N3_VORIG1 PICTURE "@E 999,999.99"					
 					@ li, aCol[005]   PSay cTraco2
					@ li, aCol[005]+1 PSay TMPN1->N3_VORIG1 PICTURE "@E 999,999.99"					
 					@ li, aCol[006]   PSay cTraco2
					@ li, aCol[006]+1 PSay TMPN1->N3_VRDACM1 PICTURE "@E 999,999.99"										
 					@ li, aCol[007]   PSay cTraco2
 					
 					nVLValias := (TMPN1->N3_VORIG1 + TMPN1->N3_AMPLIA1 + TMPN1->N3_VRCACM1) - TMPN1->N4_VENDA
 					nVlLiq    := TMPN1->N3_VORIG1 + TMPN1->N3_AMPLIA1 + TMPN1->N3_VRCACM1
 					nVlAmort  := TMPN1->N3_VORIG1 * TMPN1->N3_TXDEPR1
 					nVlCol12  := (TMPN1->N3_VORIG1 - nVlLiq - nVlAmort) * TMPN1->N3_TXDEPR1	
 					
 					IF nVLValias > 0 
						@ li, aCol[007]+1 PSay "+"										
                    ELSE
						@ li, aCol[007]+1 PSay "-"										
					ENDIF
 					@ li, aCol[008]   PSay cTraco2
					@ li, aCol[008]+1 PSay ABS(nVLValias) PICTURE "@E 999,999.99"
 					@ li, aCol[009]   PSay cTraco2
					@ li, aCol[009]+1 PSay ABS(nVlLiq) PICTURE "@E 999,999.99"
 					@ li, aCol[010]   PSay cTraco2
					@ li, aCol[010]+1 PSay nVlAmort  PICTURE "@E 999,999.99"
 					@ li, aCol[011]   PSay cTraco2
					@ li, aCol[011]+1 PSay ROUND(TMPN1->N3_TXDEPR1,2) PICTURE "@E 9.99" 
					@ li, aCol[012]   PSay cTraco2
					@ li, aCol[012]+1 PSay ABS(nVlCol12) PICTURE "@E 999,999.99"

					nVlFis	:=	N4_VENDA - nVlCol12			
					
					@ li, aCol[013]   PSay cTraco2
 					IF nVlFis > 0 
						@ li, aCol[013]+1 PSay "+"										
                    ELSE
						@ li, aCol[013]+1 PSay "-"										
					ENDIF

					@ li, aCol[014]	  PSay cTraco2					
					@ li, aCol[014]+1 PSay ABS(nVlFis) PICTURE "@E 999,999.99"					
					@ li, 220		  PSay cTraco2					
                    Li++
                    
                   	nTotCol2  += TMPN1->N4_VENDA
					nTotCol8  += nVLValias
				 	nTotCol12 += nVlFis
                    

					//+--------------------
					//| TOTAL OU TRANSPORTE
					//+--------------------		            
					If Li > 55 
			            TotGerMp31 (Li,nTotCol2,nTotCol8,nTotCol12)
	                    Li := 0         
				   		CabMap31 (lEnd,wnrel,cString)
                    EndIf



                    TMPN1->(dbskip())
                    
                    // ZERO AS VARIAVEIS PARA NÃO CARREGAR SUJEIRA 
                    nVLValias := 0
					nVlLiq    := 0
					nVlAmort  := 0
					nVlFis	  := 0
				 	nVlCol12  := 0
                    
                Enddo
                
                //+--------------------
				//| TOTAL OU TRANSPORTE
				//+--------------------
       			TotGerMp31 (Li,nTotCol2,nTotCol8,nTotCol12)
				
		    ENDIF
		#ENDIF
		
	ELSEIF MV_PAR05 == 3  
	
		#IFDEF TOP
		    If TcSrvType() <> "AS/400"
		    	cQuery	:= "SELECT N1_FILIAL, N1_CBASE, N1_ITEM, N1_AQUISIC, N1_DESCRIC, N3_FILIAL, N3_CBASE, "
		    	cQuery	+= " N3_ITEM, N3_TIPO, N3_VORIG1, N3_VRDACM1, N3_VRCDA1, N3_TXDEPR1, N3_AMPLIA1, N3_VRCACM1, N4_FILIAL, N4_CBASE, 
   			    cQuery	+= "N4_ITEM, N4_TIPO, N4_OCORR, N4_MOTIVO, N4_VENDA " 
				cQuery	+= " FROM " + RetSqlName("SN1")+","+ RetSqlName("SN3")+ "," + RetSqlName("SN4")

				IF EMPTY(cRngFil) .OR. cRngFil == NIL
						cQuery	+= " WHERE N1_FILIAL = '" + cFilAnt + "'"
				ELSE 
						cQuery	+= " WHERE "+cRngFil				
				ENDIF		
				cQuery	+= " AND N1_PATRIM <> 'N'"
				cQuery	+= " AND N1_PATRIM <> 'A'"

				IF ! EMPTY(cRngFil) .OR. cRngFil == NIL
					cRngFil := STRTRAN (cRngFil, "N1_FILIAL","N3_FILIAL")
		 		ENDIF	
				
				IF EMPTY(cRngFil) .OR. cRngFil == NIL
						cQuery	+= " AND N3_FILIAL = '" + cFilAnt + "'"
				ELSE 
						cQuery	+= " AND "+cRngFil				
				ENDIF		

				cQuery	+= " AND N3_CBASE = N1_CBASE"				
				cQuery	+= " AND N3_ITEM  = N1_ITEM"				
				cQuery	+= " AND N3_TIPO  = '02'"

				
				IF ! EMPTY(cRngFil) .OR. cRngFil == NIL
					cRngFil := STRTRAN (cRngFil, "N1_FILIAL","N4_FILIAL")
		 		ENDIF	
				
				IF EMPTY(cRngFil) .OR. cRngFil == NIL
						cQuery	+= " AND N4_FILIAL = '" + cFilAnt + "'"
				ELSE 
						cQuery	+= " AND "+cRngFil				
				ENDIF						


				cQuery	+= " AND N4_CBASE = N1_CBASE"				
				cQuery	+= " AND N4_ITEM  = N1_ITEM"				
				cQuery	+= " AND N4_MOTIVO = '01'"
				
				cQuery := ChangeQuery(cQuery)
				
				If ( Select ( "TMPN1" ) <> 0 )
					dbSelectArea ( "TMPN1" )
					dbCloseArea ()
				Endif
			
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPN1",.T.,.F.)
				
				dbSelectArea("TMPN1")
				
				WHILE 	TMPN1->(!EOF())
	
					@ li, aCol[001]   PSay cTraco2
					@ li, aCol[001]+1 PSay SUBSTR(TMPN1->N1_DESCRIC,1,28)
					@ li, aCol[002]   PSay cTraco2
					@ li, aCol[002]+1 PSay TMPN1->N4_VENDA PICTURE "@E 999,999.99"
					@ li, aCol[003]   PSay cTraco2
					@ li, aCol[003]+1 PSay SUBSTR(TMPN1->N1_AQUISIC,1,4) 
					@ li, aCol[004]   PSay cTraco2
					@ li, aCol[004]+1 PSay TMPN1->N3_VORIG1 PICTURE "@E 999,999.99"					
 					@ li, aCol[005]   PSay cTraco2
					@ li, aCol[005]+1 PSay TMPN1->N3_VORIG1 PICTURE "@E 999,999.99"					
 					@ li, aCol[006]   PSay cTraco2
					@ li, aCol[006]+1 PSay TMPN1->N3_VRDACM1 PICTURE "@E 999,999.99"										
 					@ li, aCol[007]   PSay cTraco2
 					
 					nVLValias := (TMPN1->N3_VORIG1 + TMPN1->N3_AMPLIA1 + TMPN1->N3_VRCACM1) - TMPN1->N4_VENDA
 					nVlLiq    := TMPN1->N3_VORIG1 + TMPN1->N3_AMPLIA1 + TMPN1->N3_VRCACM1
 					nVlAmort  := TMPN1->N3_VORIG1 * TMPN1->N3_TXDEPR1
 					nVlCol12  := (TMPN1->N3_VORIG1 - nVlLiq - nVlAmort) * TMPN1->N3_TXDEPR1	
 					
 					IF nVLValias > 0 
						@ li, aCol[007]+1 PSay "+"										
                    ELSE
						@ li, aCol[007]+1 PSay "-"										
					ENDIF
 					@ li, aCol[008]   PSay cTraco2
					@ li, aCol[008]+1 PSay ABS(nVLValias) PICTURE "@E 999,999.99"
 					@ li, aCol[009]   PSay cTraco2
					@ li, aCol[009]+1 PSay ABS(nVlLiq) PICTURE "@E 999,999.99"
 					@ li, aCol[010]   PSay cTraco2
					@ li, aCol[010]+1 PSay nVlAmort  PICTURE "@E 999,999.99"
 					@ li, aCol[011]   PSay cTraco2
					@ li, aCol[011]+1 PSay ROUND(TMPN1->N3_TXDEPR1,2) PICTURE "@E 9.99" 
					@ li, aCol[012]   PSay cTraco2
					@ li, aCol[012]+1 PSay ABS(nVlCol12) PICTURE "@E 999,999.99"

					nVlFis	:=	N4_VENDA - nVlCol12			
					
					@ li, aCol[013]   PSay cTraco2
 					IF nVlFis > 0 
						@ li, aCol[013]+1 PSay "+"										
                    ELSE
						@ li, aCol[013]+1 PSay "-"										
					ENDIF

					@ li, aCol[014]	  PSay cTraco2					
					@ li, aCol[014]+1 PSay ABS(nVlFis) PICTURE "@E 999,999.99"					
					@ li, 220		  PSay cTraco2					
                    Li++
                    
                   	nTotCol2  += TMPN1->N4_VENDA
					nTotCol8  += nVLValias
				 	nTotCol12 += nVlFis
				 	
				 	
					//+--------------------
					//| TOTAL OU TRANSPORTE
					//+--------------------		            
					If Li > 55 
			            TotGerMp31 (Li,nTotCol2,nTotCol8,nTotCol12)
	                    Li := 0         
				   		CabMap31 (lEnd,wnrel,cString)
                    EndIf
                    
                    TMPN1->(dbskip())
                    
                    // ZERO AS VARIAVEIS PARA NÃO CARREGAR SUJEIRA 
                    nVLValias := 0
					nVlLiq    := 0
					nVlAmort  := 0
					nVlFis	  := 0
				 	nVlCol12  := 0
                    
                Enddo
                
                //+--------------------
				//| TOTAL OU TRANSPORTE
				//+--------------------
       			TotGerMp31 (Li,nTotCol2,nTotCol8,nTotCol12)

				
		    ENDIF
		#ENDIF	
		
	ELSE

		#IFDEF TOP
		    If TcSrvType() <> "AS/400"
		    	cQuery	:= "SELECT N1_FILIAL, N1_CBASE, N1_ITEM, N1_AQUISIC, N1_DESCRIC, N3_FILIAL, N3_CBASE, "
		    	cQuery	+= " N3_ITEM, N3_TIPO, N3_VORIG1, N3_VRDACM1, N3_VRCDA1, N3_TXDEPR1, N3_AMPLIA1, N3_VRCACM1, N4_FILIAL, N4_CBASE, 
   			    cQuery	+= "N4_ITEM, N4_TIPO, N4_OCORR, N4_MOTIVO, N4_VENDA " 
				cQuery	+= " FROM " + RetSqlName("SN1")+","+ RetSqlName("SN3")+ "," + RetSqlName("SN4")

				IF EMPTY(cRngFil) .OR. cRngFil == NIL
						cQuery	+= " WHERE N1_FILIAL = '" + cFilAnt + "'"
				ELSE 
						cQuery	+= " WHERE "+cRngFil				
				ENDIF		

				IF ! EMPTY(cRngFil) .OR. cRngFil == NIL
					cRngFil := STRTRAN (cRngFil, "N1_FILIAL","N3_FILIAL")
		 		ENDIF	
				
				IF EMPTY(cRngFil) .OR. cRngFil == NIL
						cQuery	+= " AND N3_FILIAL = '" + cFilAnt + "'"
				ELSE 
						cQuery	+= " AND "+cRngFil				
				ENDIF		

				cQuery	+= " AND N3_CBASE = N1_CBASE"				
				cQuery	+= " AND N3_ITEM  = N1_ITEM"				
				cQuery	+= " AND N3_TIPO  = '02'"

				
				IF ! EMPTY(cRngFil) .OR. cRngFil == NIL
					cRngFil := STRTRAN (cRngFil, "N1_FILIAL","N4_FILIAL")
		 		ENDIF	
				
				IF EMPTY(cRngFil) .OR. cRngFil == NIL
						cQuery	+= " AND N4_FILIAL = '" + cFilAnt + "'"
				ELSE 
						cQuery	+= " AND "+cRngFil				
				ENDIF						


				cQuery	+= " AND N4_CBASE = N1_CBASE"				
				cQuery	+= " AND N4_ITEM  = N1_ITEM"				
				cQuery	+= " AND N4_MOTIVO = '01'"
				
				cQuery := ChangeQuery(cQuery)
				
				If ( Select ( "TMPN1" ) <> 0 )
					dbSelectArea ( "TMPN1" )
					dbCloseArea ()
				Endif
			
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPN1",.T.,.F.)
				
				dbSelectArea("TMPN1")
				
				WHILE 	TMPN1->(!EOF())
	
					@ li, aCol[001]   PSay cTraco2
					@ li, aCol[001]+1 PSay SUBSTR(TMPN1->N1_DESCRIC,1,28)
					@ li, aCol[002]   PSay cTraco2
					@ li, aCol[002]+1 PSay TMPN1->N4_VENDA PICTURE "@E 999,999.99"
					@ li, aCol[003]   PSay cTraco2
					@ li, aCol[003]+1 PSay SUBSTR(TMPN1->N1_AQUISIC,1,4) 
					@ li, aCol[004]   PSay cTraco2
					@ li, aCol[004]+1 PSay TMPN1->N3_VORIG1 PICTURE "@E 999,999.99"					
 					@ li, aCol[005]   PSay cTraco2
					@ li, aCol[005]+1 PSay TMPN1->N3_VORIG1 PICTURE "@E 999,999.99"					
 					@ li, aCol[006]   PSay cTraco2
					@ li, aCol[006]+1 PSay TMPN1->N3_VRDACM1 PICTURE "@E 999,999.99"										
 					@ li, aCol[007]   PSay cTraco2
 					
 					nVLValias := (TMPN1->N3_VORIG1 + TMPN1->N3_AMPLIA1 + TMPN1->N3_VRCACM1) - TMPN1->N4_VENDA
 					nVlLiq    := TMPN1->N3_VORIG1 + TMPN1->N3_AMPLIA1 + TMPN1->N3_VRCACM1
 					nVlAmort  := TMPN1->N3_VORIG1 * TMPN1->N3_TXDEPR1
 					nVlCol12  := (TMPN1->N3_VORIG1 - nVlLiq - nVlAmort) * TMPN1->N3_TXDEPR1	
 					
 					IF nVLValias > 0 
						@ li, aCol[007]+1 PSay "+"										
                    ELSE
						@ li, aCol[007]+1 PSay "-"										
					ENDIF
 					@ li, aCol[008]   PSay cTraco2
					@ li, aCol[008]+1 PSay ABS(nVLValias) PICTURE "@E 999,999.99"
 					@ li, aCol[009]   PSay cTraco2
					@ li, aCol[009]+1 PSay ABS(nVlLiq) PICTURE "@E 999,999.99"
 					@ li, aCol[010]   PSay cTraco2
					@ li, aCol[010]+1 PSay nVlAmort  PICTURE "@E 999,999.99"
 					@ li, aCol[011]   PSay cTraco2
					@ li, aCol[011]+1 PSay ROUND(TMPN1->N3_TXDEPR1,2) PICTURE "@E 9.99" 
					@ li, aCol[012]   PSay cTraco2
					@ li, aCol[012]+1 PSay ABS(nVlCol12) PICTURE "@E 999,999.99"

					nVlFis	:=	N4_VENDA - nVlCol12			
					
					@ li, aCol[013]   PSay cTraco2
 					IF nVlFis > 0 
						@ li, aCol[013]+1 PSay "+"										
                    ELSE
						@ li, aCol[013]+1 PSay "-"										
					ENDIF

					@ li, aCol[014]	  PSay cTraco2					
					@ li, aCol[014]+1 PSay ABS(nVlFis) PICTURE "@E 999,999.99"					
					@ li, 220		  PSay cTraco2					
                    Li++
                    
                   	nTotCol2  += TMPN1->N4_VENDA
					nTotCol8  += nVLValias
				 	nTotCol12 += nVlFis
                    

					//+--------------------
					//| TOTAL OU TRANSPORTE
					//+--------------------		            
					If Li > 55 
			            TotGerMp31 (Li,nTotCol2,nTotCol8,nTotCol12)
	                    Li := 0         
				   		CabMap31 (lEnd,wnrel,cString)
                    EndIf


                    TMPN1->(dbskip())
                    
                    // ZERO AS VARIAVEIS PARA NÃO CARREGAR SUJEIRA 
                    nVLValias := 0
					nVlLiq    := 0
					nVlAmort  := 0
					nVlFis	  := 0
				 	nVlCol12  := 0
                    
                Enddo
                
                //+--------------------
				//| TOTAL OU TRANSPORTE
				//+--------------------
       			TotGerMp31 (Li,nTotCol2,nTotCol8,nTotCol12)
				
		    ENDIF
		#ENDIF	

	ENDIF
	
	
	Return


///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | ATRMAP31		     | AUTOR | microsiga    | DATA | 30/05/2008 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | 										                        |//
//|           | 												                |//
//|           | Funcao de impressao  do tota geral ou trasnporte                |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////    


	
	Function TotGerMp31 (Li,nTot2,nTot8,nTot12)
	//+--------------------
	//| Declaracao de variaveis
	//+--------------------
	Local cTraco1	:= "-"
	Local cTraco2	:= "|" 	
	Local nLi 		:= 0
	Local aCol		:= {}

	//+--------------------
	//| Coluna de impressao
	//+--------------------
	aAdd( aCol, 001 ) //DESCRICAO
	aAdd( aCol, 030 ) //VALOR DE REALIZACAO
	aAdd( aCol, 050 ) //ANO AQUIS
	aAdd( aCol, 056 ) //VALOR DE AQUIS
	aAdd( aCol, 076 ) //VALOR DE AQUIS REAVALIADO
	aAdd( aCol, 096 ) //VL AMORTIZAÇÕES PRATICADAS
	aAdd( aCol, 116 ) //VALIAS CONT SINAL
	aAdd( aCol, 124 ) //VALIAS CONT VALOR
	aAdd( aCol, 137 ) //VALIAS NAO TRIBUTADAS
	aAdd( aCol, 157 ) //AMORTIZACOES EFEITO FISCAIS
	aAdd( aCol, 177 ) //COEF
	aAdd( aCol, 182 ) //VL LIQ ACTUALIZADO
	aAdd( aCol, 202 ) //VALIAS FIS SINAL
	aAdd( aCol, 208 ) //VALIAS FIS VALOR

    //+--------------------
    //| TOTAL OU TRANSPORTE
    //+--------------------
    nLi := 0
    For nLi := 1 to limite
		@ Li, nLi  PSay cTraco1
	Next nLi	
	Li++
					
	@ li, aCol[001]	  PSay cTraco2 					                
	@ li, aCol[001]+1 PSay STR0037                 //"TOTAL GERAL OU A TRANSPORTAR"
	@ li, aCol[002]	  PSay cTraco2					                
	@ li, aCol[002]+1 PSay ABS(nTot2) PICTURE "@E 999,999.99"                
	@ li, aCol[003]	  PSay cTraco2                
	@ li, aCol[006]+1 PSay STR0038                				 //"SINAL / SALDO"
	@ li, aCol[008]	  PSay cTraco2
	@ li, aCol[008]+1 PSay ABS(nTot8) PICTURE "@E 999,999.99"                				
	@ li, aCol[009]	  PSay cTraco2
	@ li, aCol[012]+1 PSay STR0038                				 //"SINAL / SALDO"
	@ li, aCol[014]	  PSay cTraco2
	@ li, aCol[014]+1 PSay ABS(nTot12) PICTURE "@E 999,999.99"                				
	@ li, 220   	  PSay cTraco2
	LI++
		
	//+--------------------
	//| TOTAL OU TRANSPORTE
	//+--------------------
	nLi := 0
	For nLi := 1 to limite
		@ Li, nLi  PSay cTraco1
	Next nLi	
	Li++
	     
	Return (Li)
	