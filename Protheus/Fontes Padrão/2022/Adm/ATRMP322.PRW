#INCLUDE "PROTHEUS.ch"
#INCLUDE "ATRMP322.ch"
	///////////////////////////////////////////////////////////////////////////////////
	//+-----------------------------------------------------------------------------+//
	//| PROGRAMA  | ATRMAP31		     | AUTOR | microsiga    | DATA | 30/05/2008 |//
	//+-----------------------------------------------------------------------------+//
	//| DESCRICAO | 										                        |//
	//|           | 												                |//
	//|           | Funcao de impressao                                             |//
	//+-----------------------------------------------------------------------------+//
	///////////////////////////////////////////////////////////////////////////////////    
	Function ATRMP322(lEnd,wnrel,cString)
	
		//Cabecalho
		CbMap322 (lEnd,wnrel,cString)
		
		//Dados
		DadosMp322 (lEnd,wnrel,cString)		
		
		
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
	//|           | Funcao de impressao do cabecalho				                |//
	//+-----------------------------------------------------------------------------+//
	///////////////////////////////////////////////////////////////////////////////////
	
	Function CbMap322 (lEnd,wnrel,cString)
		//+--------------------
		//| Declaracao de variaveis
		//+--------------------
		Local cTraco1	:= "-"
		Local cTraco2	:= "|" 	
		Local nLi 		:= 0

		//+--------------------
		//| TRACO SUPERIOR
		//+--------------------  
		For nLi := 1 to 50 
			@ Li, nLi  PSay cTraco1
		Next nLi	
	
		nLi := 0
		For nLi := 160 to 203 
			@ Li, nLi  PSay cTraco1
		Next nLi	
	
		nLi := 0
		For nLi := 205 to 220 
			@ Li, nLi  PSay cTraco1
		Next nLi	
		Li++


		dBSelectArea("SM0")
		DBSETORDER(1)
		DBSEEK(cEmpAnt+cFilAnt)

	
		//+--------------------
		//| CABECALHO 
		//+--------------------
		@ Li,001  PSay cTraco2
		@ Li,004  PSay STR0001 //"FIRMA : "
		@ Li,013  PSay ALLTRIM(SM0->M0_NOMECOM)
		@ Li,050  PSay cTraco2
		@ Li,052  PSay STR0002 //"                            M A P A   D E   R E I N T E G R A C O E S   "
		@ Li,160  PSay cTraco2  
		@ Li,161  PSay STR0003   //"NUMERO DE INDETIFICACAO FISCAL "
		@ Li,192  PSay SUBSTR(SM0->M0_CGC,1,9) PICTURE "@E 999999999"   
		@ Li,203  PSay cTraco2  
		@ Li,205  PSay cTraco2  
		@ Li,220  PSay cTraco2  
		Li++
	
		@ Li,001  PSay cTraco2   
		@ Li,050  PSay cTraco2
		@ Li,052  PSay STR0004 //"                    M E T O D O   D A S  Q U O T A S  D E G R E S S I V A S "
		@ Li,160  PSay cTraco2  
		@ Li,161  PSay STR0005   //"ACTIVIDADE PRINCIPAL "
		@ Li,203  PSay cTraco2  
		@ Li,205  PSay cTraco2  
		@ Li,220  PSay cTraco2  
		Li++
		@ Li,001  PSay cTraco2   
		@ Li,031  PSay STR0006 //"EXERCICIO DE "
		@ Li,046  PSay MV_PAR02
		@ Li,050  PSay cTraco2
		@ Li,160  PSay cTraco2  
		@ Li,203  PSay cTraco2  
		@ Li,205  PSay cTraco2  
		@ Li,208  PSay STR0007   //"M O D E L O"
		@ Li,220  PSay cTraco2  
		Li++
		@ Li,001  PSay cTraco2   
		@ Li,004  PSay STR0008 //"PERIODO DE TRIBUTACAO"
		@ Li,026  PSay STR0009 //" DE "
		@ Li,030  PSay MV_PAR03
		@ Li,039  PSay STR0010 //" A "
		@ Li,042  PSay MV_PAR04
		@ Li,050  PSay cTraco2                                                                                    
		@ Li,052  PSay STR0011 //"              (a)_________________________________________________________________________"
		@ Li,160  PSay cTraco2  
		@ Li,181  PSay STR0012   //"CODIGO CAE "
		@ Li,197  PSay SM0->M0_CNAE  PICTURE "99999"
		@ Li,203  PSay cTraco2  
		@ Li,205  PSay cTraco2  
		@ Li,208  PSay STR0013   //"   32.2"
		@ Li,220  PSay cTraco2  
		Li++

		//+--------------------
		//| TRACO INFERIOR
		//+--------------------
		nLi := 0
		For nLi := 1 to 50
			@ Li, nLi  PSay cTraco1
		Next nLi	
 		
		nLi := 0
		For nLi := 160 to 203
			@ Li, nLi  PSay cTraco1
		Next nLi
	
		nLi := 0
		For nLi := 205 to 220
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
		//| LINHA 1 COLUNAS
		//+--------------------
	                                                     
		@ Li,001  PSay STR0014	 //"|CODIGO DE ACORDO "
		@ Li,019  PSay STR0015 //"|          DESCRICAO           "
		@ Li,050  PSay STR0016 //"|      DATA      "
		@ Li,067  PSay STR0017 //"|ACTIVO IMOBILIZADO"
		@ Li,086  PSay STR0018 //"|    VALOR      "
		@ Li,102  PSay STR0019 //"|REINTEGRACOES DO EXERCICIO"
		@ Li,130  PSay STR0020 //"| REINTEGRA-"
		@ Li,143  PSay STR0021 //"|  ACTIVO   "
		@ Li,155  PSay STR0022 //"|    TAXAS      "
		@ Li,171  PSay STR0023 //"|      MAIS-VALIAS       "
		@ Li,196  PSay STR0024 //"|   REINTEGRACOES E     "
		@ Li,220  PSay "|"	
		Li++	
	
		//+--------------------
		//| LINHA 2 COLUNAS
		//+--------------------
	
		@ Li,001  PSay STR0025 //"|COM A TABELA ANE "
		@ Li,019  PSay STR0026 //"|                              "
		@ Li,050  PSay STR0027 //"|AQUIS"
		@ Li,056  PSay STR0028 //"|  INICIO  "
		@ Li,067  PSay STR0029 //"|VALOR DE AQUISICAO"
		@ Li,086  PSay STR0030 //"|     NAO       "
		@ Li,102  PSay STR0031 //"|    TAXAS     "
		@ Li,117  PSay STR0032 //"|           "
		@ Li,130  PSay STR0033 //"|   COES    "
		@ Li,143  PSay STR0034 //"|IMOBILIZADO"
		@ Li,155 PSay STR0035 //"|   PERDIDAS    "
		@ Li,171 PSay STR0036 //"|     NAO TRIBUTADAS     "
		@ Li,196 PSay STR0037 //"|    AMORTIZACOES       "
		@ Li,220 PSay "|"
	    LI++
	
		//+--------------------
		//| LINHA 3 COLUNAS
		//+--------------------
	
		@ Li,001  PSay STR0038 //"|XA AO DEC. REG.  "
		@ Li,019  PSay STR0026 //"|                              "
		@ Li,050  PSay STR0039 //"|     "
		@ Li,056  PSay STR0040 //"|UTILIZACAO"
		@ Li,067  PSay STR0041 //"|  OU DE PRODUCAO  "
		@ Li,086  PSay STR0042 //"|  REINTEGRADO  "
		@ Li,102  PSay STR0043 //"|DECRETO "
		@ Li,111  PSay STR0044 //"|CORRI"
		@ Li,117  PSay STR0045 //"|  VALORES  "
		@ Li,130  PSay STR0046 //"|ACUMULADAS "
		@ Li,143  PSay STR0047 //"| (VALORES  "
		@ Li,155 PSay STR0048 //"|  ACUMULADAS   "
		@ Li,171 PSay STR0049 //"|                        "
		@ Li,196 PSay STR0050 //"|     NAO ACEITES       "
		@ Li,220 PSay "|"
	    LI++
	
		//+--------------------
		//| LINHA 4 COLUNAS
		//+--------------------
	    
	    @ Li,001  PSay STR0051 //"|N 2/90 DE 12/01  "
  		@ Li,019  PSay STR0026 //"|                              "
		@ Li,050  PSay STR0052 //"| ANO "
		@ Li,056  PSay STR0053 //"| MES "
		@ Li,062  PSay STR0054 //"| ANO"
		@ Li,067  PSay STR0055 //"|                  "
		@ Li,086  PSay STR0056 //"|               "
		@ Li,102  PSay STR0057 //"|  REG.  "
		@ Li,111  PSay STR0058 //"|GIDAS"
		@ Li,117  PSay STR0032 //"|           "
		@ Li,130  PSay STR0032 //"|           "
		@ Li,143  PSay STR0059 //"| LIQUIDOS) "
		@ Li,155  PSay STR0056 //"|               "
		@ Li,171  PSay STR0060 //"|  ANO  "
		@ Li,179  PSay STR0061 //"|    MONTANTE    "
		@ Li,196  PSay STR0062 //"|                       "
		@ Li,220  PSay "|"
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
	//|           | Funcao de processamento e impressao dos dados                   |//
	//+-----------------------------------------------------------------------------+//
	///////////////////////////////////////////////////////////////////////////////////
	
	
	Function DadosMp322 (lEnd,wnrel,cString)
    
	   	//+--------------------
		//| Declaracao de variaveis
		//+--------------------
		Local cTraco1	:= "-"
		Local cTraco2	:= "|" 	
		Local nLi 		:= 0	
    	Local aCol      := {}
    	Local aCol2		:= {}

		Local nTotCol6  := 0
		Local nTotCol7  := 0
		Local nTotCol10 := 0
		Local nTotCol11 := 0
		Local nTotCol12 := 0 
		Local nTotCol16 := 0    	
		
		Local nMValFis 	:= 0
		
		//+--------------------
		//| Coluna de traco
		//+--------------------
		aAdd( aCol, 001 ) //1
		aAdd( aCol, 019 ) //2
		aAdd( aCol, 050 ) //3
		aAdd( aCol, 056 ) //4
		aAdd( aCol, 062 ) //5
		aAdd( aCol, 067 ) //6
		aAdd( aCol, 086 ) //7
		aAdd( aCol, 102 ) //8
		aAdd( aCol, 111 ) //9
		aAdd( aCol, 117 ) //10
		aAdd( aCol, 130 ) //11
		aAdd( aCol, 143 ) //12
		aAdd( aCol, 155 ) //13
		aAdd( aCol, 171 ) //14
		aAdd( aCol, 179 ) //15
		aAdd( aCol, 196 ) //16
		aAdd( aCol, 220 ) //17

		
		//+--------------------
		//| Coluna de impressao DOs DADOS
		//+--------------------

		aAdd( aCol2, 002 ) //1
		aAdd( aCol2, 020 ) //2
		aAdd( aCol2, 051 ) //3
		aAdd( aCol2, 057 ) //4
		aAdd( aCol2, 063 ) //5
		aAdd( aCol2, 068 ) //6
		aAdd( aCol2, 087 ) //7
		aAdd( aCol2, 103 ) //8
		aAdd( aCol2, 112 ) //9
		aAdd( aCol2, 118 ) //10
		aAdd( aCol2, 131 ) //11
		aAdd( aCol2, 144 ) //12
		aAdd( aCol2, 156 ) //13
		aAdd( aCol2, 172 ) //14
		aAdd( aCol2, 180 ) //15
		aAdd( aCol2, 197 ) //16
		
	    MakeSqlExpr("ATRMAP")
                         
	    cRngFil := MV_PAR01
    
	    #IFDEF TOP
		    If TcSrvType() <> "AS/400"
		    	cQuery	:= "SELECT N1_FILIAL, N1_CBASE, N1_ITEM, N1_AQUISIC, N1_DESCRIC, N1_PRZDEPR, N1_GRUPO, N3_FILIAL, N3_CBASE, "
		    	cQuery	+= " N3_ITEM, N3_TIPO, N3_VORIG1, N3_VRDACM1, N3_VRDBAL1, N3_DINDEPR, N3_VLACTXP, N3_VRCDA1, N3_TXDEPR1, N3_AMPLIA1, N3_VRCACM1, N4_FILIAL, N4_CBASE, "
   			    cQuery	+= "N4_ITEM, N4_TIPO, N4_OCORR, N4_MOTIVO, N4_VENDA, NG_TXDEPR1, N4_VLROC1, IE_INDICE, IE_EXERCIC " 
				cQuery	+= " FROM " + RetSqlName("SN1")+","+ RetSqlName("SN3")+ "," + RetSqlName("SN4")+ "," + RetSqlName("SNG")+ "," + RetSqlName("SIE")

				IF EMPTY(cRngFil) .OR. cRngFil == NIL
						cQuery	+= " WHERE N1_FILIAL = '" + xFilial("SN1") + "'"
				ELSE 
						cQuery	+= " WHERE "+cRngFil				
				ENDIF		
				
				IF ! EMPTY(cRngFil) .OR. cRngFil == NIL
					cRngFil := STRTRAN (cRngFil, "N1_FILIAL","N3_FILIAL")
		 		ENDIF	
				
				IF EMPTY(cRngFil) .OR. cRngFil == NIL
						cQuery	+= " AND N3_FILIAL = '" + xFilial("SN3") + "'"
				ELSE 
						cQuery	+= " AND "+cRngFil				
				ENDIF		

				cQuery	+= " AND N3_CBASE = N1_CBASE"				
				cQuery	+= " AND N3_ITEM  = N1_ITEM"				

				
				IF ! EMPTY(cRngFil) .OR. cRngFil == NIL
					cRngFil := STRTRAN (cRngFil, "N1_FILIAL","N4_FILIAL")
		 		ENDIF	
				
				IF EMPTY(cRngFil) .OR. cRngFil == NIL
						cQuery	+= " AND N4_FILIAL = '" + xFilial("SN4") + "'"
				ELSE 
						cQuery	+= " AND "+cRngFil				
				ENDIF						


				cQuery	+= " AND N4_CBASE = N1_CBASE"				
				cQuery	+= " AND N4_ITEM  = N1_ITEM"				
				cQuery	+= " AND N4_MOTIVO = '01'"
				
				IF ! EMPTY(cRngFil) .OR. cRngFil == NIL
					cRngFil := STRTRAN (cRngFil, "N1_FILIAL","NG_FILIAL")
		 		ENDIF	
				
				IF EMPTY(cRngFil) .OR. cRngFil == NIL
						cQuery	+= " AND N4_FILIAL = '" + xFilial("SNG") + "'"
				ELSE 
						cQuery	+= " AND "+cRngFil				
				ENDIF						
				
				cQuery	+= " AND NG_GRUPO = N1_GRUPO"				
				
				IF ! EMPTY(cRngFil) .OR. cRngFil == NIL
					cRngFil := STRTRAN (cRngFil, "N1_FILIAL","IE_FILIAL")
		 		ENDIF	
				
				IF EMPTY(cRngFil) .OR. cRngFil == NIL
						cQuery	+= " AND IE_FILIAL = '" + xFilial("SIE") + "'"
				ELSE 
						cQuery	+= " AND "+cRngFil				
				ENDIF						
				
				cQuery	+= " AND IE_EXERCIC  = '"+MV_PAR02+"'"

				
				cQuery := ChangeQuery(cQuery)
				
				If ( Select ( "TMPN1" ) <> 0 )
					dbSelectArea ( "TMPN1" )
					dbCloseArea ()
				Endif
			
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPN1",.T.,.F.)
				
				dbSelectArea("TMPN1")
				
				WHILE 	TMPN1->(!EOF())
				
					nMValFis 	:= ((TMPN1->N3_VORIG1 - TMPN1->N3_VRDACM1)-TMPN1->N4_VLROC1)*IE_INDICE
		
					@ Li, aCol[1]   PSay cTraco2
					@ Li,aCol2[1]+1 PSay SUBSTR(TMPN1->N1_GRUPO,1,1)+" | "+SUBSTR(TMPN1->N1_GRUPO,2,1)+" | "+SUBSTR(TMPN1->N1_GRUPO,3,1)+" | "+SUBSTR(TMPN1->N1_GRUPO,4,1)		
					@ Li, aCol[2]   PSay cTraco2
					@ Li,aCol2[2]   PSay SuBSTR(TMPN1->N1_DESCRIC,1,30)
					@ Li, aCol[3]   PSay cTraco2
					@ Li,aCol2[3]   PSay SUBSTR(TMPN1->N1_AQUISIC,1,4)
					@ Li, aCol[4]   PSay cTraco2
					@ Li,aCol2[4]   PSay SUBSTR(TMPN1->N3_DINDEPR,5,2)
					@ Li, aCol[5]   PSay cTraco2
					@ Li,aCol2[5]   PSay SUBSTR(TMPN1->N3_DINDEPR,1,4)
					@ Li, aCol[6]   PSay cTraco2
					@ Li,aCol2[6]   PSay TMPN1->N3_VORIG1       PICTURE "@E 999,999.99"		
					@ Li, aCol[7]   PSay cTraco2
					@ Li,aCol2[7]   PSay TMPN1->N3_VORIG1		PICTURE "@E 999,999.99"
					@ Li, aCol[8]   PSay cTraco2
					@ Li,aCol2[8]   PSay TMPN1->NG_TXDEPR1      PICTURE "@E 99.99"
					@ Li, aCol[9]   PSay cTraco2
					@ Li,aCol2[9]   PSay TMPN1->N1_PRZDEPR      PICTURE "@E 99.99"		
					@ Li, aCol[10]  PSay cTraco2
					@ Li,aCol2[10]  PSay TMPN1->N3_VRDACM1	    PICTURE "@E 999,999.99"	
					@ Li, aCol[11]  PSay cTraco2
					@ Li,aCol2[11]  PSay TMPN1->N3_VRDACM1		PICTURE "@E 999,999.99"
					@ Li, aCol[12]  PSay cTraco2
					@ Li,aCol2[12]  PSay ROUND(TMPN1->N3_VORIG1 + TMPN1->N3_VRDACM1,2)     PICTURE "@E 999,999.99"
					@ Li, aCol[13]  PSay cTraco2
					@ Li,aCol2[13]  PSay TMPN1->N3_VLACTXP		PICTURE "@E 99.99" 
					@ Li, aCol[14]  PSay cTraco2
					@ Li,aCol2[14]  PSay MV_PAR02
					@ Li, aCol[15]  PSay cTraco2
					@ Li,aCol2[15]  PSay ((TMPN1->N4_VLROC1 - nMValFis)*TMPN1->N3_TXDEPR1) PICTURE "@E 999,999.99"
					@ Li, aCol[16]  PSay cTraco2
					@ Li,aCol2[16]  PSay ((((TMPN1->N4_VLROC1 - nMValFis)*TMPN1->N3_TXDEPR1)*TMPN1->N3_VRDACM1)/ TMPN1->N3_VORIG1) PICTURE "@E 999,999.99"
					@ Li, aCol[17]  PSay cTraco2
					Li++
					
					nTotCol6  +=  TMPN1->N3_VORIG1
					nTotCol7  +=  TMPN1->N3_VORIG1
					nTotCol10 +=  TMPN1->N3_VRDACM1
					nTotCol11 +=  TMPN1->N3_VRDACM1
					nTotCol12 +=  TMPN1->N3_VORIG1 + TMPN1->N3_VRDACM1
					nTotCol16 +=  ((((TMPN1->N4_VLROC1 - nMValFis)*TMPN1->N3_TXDEPR1)*TMPN1->N3_VRDACM1)/ TMPN1->N3_VORIG1)
					
					If Li > 55 
						//+--------------------
						//| TRACO INFERIOR
						//+--------------------
						nLi := 0
						For nLi := 1 to limite
							@ Li, nLi  PSay cTraco1
						Next nLi	
						Li++                
		
		                @ Li, aCol[1]  PSay cTraco2
				        @ Li,aCol2[2]  PSay STR0063         //"TOTAL GERAL OU A TRANSPORTAR"
		                @ Li, aCol[6]  PSay cTraco2
		                @ Li,aCol2[6]  PSay nTotCol6 PICTURE "@E 999,999.99"
	        	        @ Li, aCol[7]  PSay cTraco2
    		            @ Li,aCol2[7]  PSay nTotCol7 PICTURE "@E 999,999.99"
		                @ Li, aCol[8]  PSay cTraco2
		                @ Li, aCol[10] PSay cTraco2
						@ Li,aCol2[10] PSay nTotCol10 PICTURE "@E 999,999.99"               
		                @ Li, aCol[11] PSay cTraco2
		   				@ Li,aCol2[11] PSay nTotCol11 PICTURE "@E 999,999.99"               
		   				@ Li, aCol[12] PSay cTraco2
		   				@ Li,aCol2[12] PSay nTotCol12 PICTURE "@E 999,999.99"       
		                @ Li, aCol[13] PSay cTraco2
		                @ Li, aCol[16] PSay cTraco2
		  				@ Li,aCol2[16] PSay nTotCol16 PICTURE "@E 999,999.99"       
		                @ Li, aCol[17] PSay cTraco2  				
		                Li++
                
        		    	//+--------------------
						//| TRACO INFERIOR
						//+--------------------
						nLi := 0
						For nLi := 1 to limite
							@ Li, nLi  PSay cTraco1
						Next nLi	
						Li++
						
						Li := 0
						CbMap322 (lEnd,wnrel,cString)
						
					Endif
					
					nMValFis 	:= 0
					
					TMPN1->(DBSKIP())
                ENDDO

				//+--------------------
				//| TRACO INFERIOR
				//+--------------------
				nLi := 0
				For nLi := 1 to limite
					@ Li, nLi  PSay cTraco1
				Next nLi	
				Li++                

                @ Li, aCol[1]  PSay cTraco2
		        @ Li,aCol2[2]  PSay STR0063         //"TOTAL GERAL OU A TRANSPORTAR"
                @ Li, aCol[6]  PSay cTraco2
                @ Li,aCol2[6]  PSay nTotCol6 PICTURE "@E 999,999.99"
                @ Li, aCol[7]  PSay cTraco2
                @ Li,aCol2[7]  PSay nTotCol7 PICTURE "@E 999,999.99"
                @ Li, aCol[8]  PSay cTraco2
                @ Li, aCol[10] PSay cTraco2
				@ Li,aCol2[10] PSay nTotCol10 PICTURE "@E 999,999.99"               
                @ Li, aCol[11] PSay cTraco2
   				@ Li,aCol2[11] PSay nTotCol11 PICTURE "@E 999,999.99"               
   				@ Li, aCol[12] PSay cTraco2
   				@ Li,aCol2[12] PSay nTotCol12 PICTURE "@E 999,999.99"       
                @ Li, aCol[13] PSay cTraco2
                @ Li, aCol[16] PSay cTraco2
  				@ Li,aCol2[16] PSay nTotCol16 PICTURE "@E 999,999.99"       
                @ Li, aCol[17] PSay cTraco2  				
                Li++
                
            	//+--------------------
				//| TRACO INFERIOR
				//+--------------------
				nLi := 0
				For nLi := 1 to limite
					@ Li, nLi  PSay cTraco1
				Next nLi	
				Li++
                
	        Endif
	    #ENDIF

	Return

/*        10       20        30         40        50       60        70         80        90        100       110       120       130       140       150       160       170       180       190       200       210      220
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
|CODIGO DE ACORDO |          DESCRICAO           |      DATA      |ACTIVO IMOBILIZADO|    VALOR      |REINTEGRACOES DO EXERCICIO | REINTEGRA- |  ACTIVO   |    TAXAS      |      MAIS-VALIAS       |   REINTEGRACOES E     |
|COM A TABELA ANE |                              |AQUIS|  INICIO  |VALOR DE AQUISICAO|     NAO       |      TAXAS   |            |   COES     |IMOBILIZADO|   PERDIDAS    |     NAO TRIBUTADAS     |    AMORTIZACOES       |
|XA AO DEC. REG.  |                              |     |UTILIZACAO|  OU DE PRODUCAO  |  REINTEGRADO  |DECRETO |CORRI|  VALORES   |ACUMULADAS  | (VALORES  |  ACUMULADAS   |                        |     NAO ACEITES       |
|N 2/90 DE 12/01  |                              | ANO | MES | ANO|                  |               |  REG.  |GIDAS|            |            | LIQUIDOS) |               |  ANO  |    MONTANTE    |                       |
*/	