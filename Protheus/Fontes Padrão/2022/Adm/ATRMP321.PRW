#INCLUDE "PROTHEUS.ch"
#INCLUDE "ATRMP321.ch"
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | ATRMP321		     | AUTOR | microsiga    | DATA | 30/05/2008 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | 										                        |//
//|           | 												                |//
//|           | Funcao de impressao                                             |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////    
	Function ATRMP321(lEnd,wnrel,cString)

	    // Cria cabecalho do relatorio
		CbMap321(lEnd,wnrel,cString)
		
		// processa e imprime os dados 
		DadosMp321(lEnd,wnrel,cString)		
	
    	If aReturn[5] == 1
		   Set Printer TO
		   dbCommitAll()
		   Ourspool(wnrel)
		EndIf
	
		Ms_Flush()	
			
		
    Return
    
    Function  CbMap321(lEnd,wnrel,cString) // cria o cabecalho
    
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
	@ Li,052  PSay STR0002 //"                   M A P A   D E   R E I N T E G R A C O E S   E   A M O R T I Z A C O E S "
	@ Li,160  PSay cTraco2  
	@ Li,161  PSay STR0003   //"NUMERO DE INDETIFICACAO FISCAL "
	@ Li,192  PSay SUBSTR(SM0->M0_CGC,1,9) PICTURE "@E 999999999"  
	@ Li,203  PSay cTraco2  
	@ Li,205  PSay cTraco2  
	@ Li,220  PSay cTraco2  
	Li++
	
	@ Li,001  PSay cTraco2   
	@ Li,050  PSay cTraco2
	@ Li,052  PSay STR0004 //"                    E L E M E N T O S   D O   A C T I V O   N A O   R E A V A L I A D O S "
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
	@ Li,208  PSay STR0013   //"   32.1"
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
                                                     
	@ Li,001  PSay STR0014	 //"|CODIGO DE ACORDO "
	@ Li,019  PSay STR0015 //"|          DESCRICAO           "
	@ Li,050  PSay STR0016 //"|      DATA      "
	@ Li,067  PSay STR0017 //"|   VALOR DE AQUISICAO    "
	@ Li,093  PSay STR0018 //"|NUMERO DE "
	@ Li,104  PSay STR0019 //"|        REINTEGRACOES E AMORTIZACOES              "
	@ Li,155  PSay STR0020 //"|    TAXAS      "
	@ Li,171  PSay STR0021 //"|      MAIS-VALIAS       "
	@ Li,196  PSay STR0022 //"|   REINTEGRACOES E     "
	@ Li,220  PSay "|"	
	Li++	

	@ Li,001  PSay STR0023 //"|COM A TABELA ANE "
	@ Li,019  PSay STR0024 //"|                              "
	@ Li,050  PSay STR0025 //"|AQUIS"
	@ Li,056  PSay STR0026 //"|  INICIO  "
	@ Li,067  PSay STR0027 //"|     CONTABILISTICO      "
	@ Li,093  PSay STR0028 //"| ANOS DE  "
	@ Li,104  PSay STR0029 //"| EXERCICIOS "
	@ Li,117  PSay STR0030 //"|   DO EXERCICIO     "
	@ Li,138  PSay STR0031 //"|  ACUMULADAS    "
	@ Li,155 PSay STR0032 //"|   PERDIDAS    "
	@ Li,171 PSay STR0033 //"|     NAO TRIBUTADAS     "
	@ Li,196 PSay STR0034 //"|    AMORTIZACOES       "
	@ Li,220 PSay "|"
    LI++


	@ Li,001  PSay STR0035 //"|XA AO DEC. REG.  "
	@ Li,019  PSay STR0024 //"|                              "
	@ Li,050  PSay STR0036 //"|     "
	@ Li,056  PSay STR0037 //"|UTILIZACAO"
	@ Li,067  PSay STR0038 //"|       NA FALTA        "
	@ Li,093  PSay STR0039 //"|UTILIDADE "
	@ Li,104  PSay STR0040 //"| ANTERIORES "
	@ Li,117  PSay STR0041 //"|--------------------"
	@ Li,138  PSay STR0042 //"|                "
	@ Li,155 PSay STR0043 //"|  ACUMULADAS   "
	@ Li,171 PSay STR0044 //"|                        "
	@ Li,196 PSay STR0045 //"|     NAO ACEITES       "
	@ Li,220 PSay "|"
    LI++
    
    @ Li,001  PSay STR0046 //"|N 2/90 DE 12/01  "
	@ Li,019  PSay STR0024 //"|                              "
	@ Li,050  PSay STR0047 //"| ANO "
	@ Li,056  PSay STR0048 //"| MES "
	@ Li,062  PSay STR0049 //"| ANO"
	@ Li,067  PSay STR0050 //"|         DAQUELES        "
	@ Li,093  PSay STR0051 //"| ESPERADA "
	@ Li,104  PSay STR0052 //"|            "
	@ Li,117  PSay STR0053 //"|TAXAS"
	@ Li,123  PSay STR0054 //"|  VALORES     "
	@ Li,138  PSay STR0042 //"|                "
	@ Li,155  PSay STR0055 //"|               "
	@ Li,171  PSay STR0056 //"|  ANO  "
	@ Li,179  PSay STR0057 //"|    MONTANTE    "
	@ Li,196  PSay STR0058 //"|                       "
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
    
    
    Function DadosMp321 (lEnd,wnrel,cString) // processa e imprime os dados

   	//+--------------------
	//| Declaracao de variaveis
	//+--------------------
	Local cTraco1	:= "-"
	Local cTraco2	:= "|" 	
	Local nLi 		:= 0
	Local aCol		:= {}
	Local aCol2		:= {}
	Local cRngFil   := ""
    
	Local nTotCol6  := 0
	Local nTotCol8  := 0
	Local nTotCol10 := 0
	Local nTotCol11 := 0
	Local nTotCol15 := 0 
	Local nUtilEps  := 0
	Local nMValias 	:= 0
	Local nMValFis 	:= 0

	//+--------------------
	//| Coluna de impressao DO DADOS
	//+--------------------
	aAdd( aCol2, 001 ) //1
	aAdd( aCol2, 019 ) //2
	aAdd( aCol2, 050 ) //3
	aAdd( aCol2, 056 ) //4
	aAdd( aCol2, 062 ) //5
	aAdd( aCol2, 067 ) //6
	aAdd( aCol2, 093 ) //7
	aAdd( aCol2, 104 ) //8
	aAdd( aCol2, 117 ) //9
	aAdd( aCol2, 123 ) //10
	aAdd( aCol2, 138 ) //11
	aAdd( aCol2, 155 ) //12
	aAdd( aCol2, 171 ) //13
	aAdd( aCol2, 179 ) //14
	aAdd( aCol2, 196 ) //15

	//+--------------------
	//| Coluna de impressao DO DADOS
	//+--------------------
	aAdd( aCol, 002 ) //1
	aAdd( aCol, 020 ) //2
	aAdd( aCol, 051 ) //3
	aAdd( aCol, 057 ) //4
	aAdd( aCol, 063 ) //5
	aAdd( aCol, 068 ) //6
	aAdd( aCol, 094 ) //7
	aAdd( aCol, 105 ) //8
	aAdd( aCol, 118 ) //9
	aAdd( aCol, 124 ) //10
	aAdd( aCol, 139 ) //11
	aAdd( aCol, 156 ) //12
	aAdd( aCol, 172 ) //13
	aAdd( aCol, 180 ) //14
	aAdd( aCol, 197 ) //15
    
    
    MakeSqlExpr("ATRMAP")
                         
    cRngFil := MV_PAR01
    
    #IFDEF TOP
		    If TcSrvType() <> "AS/400"
		    	cQuery	:= "SELECT N1_FILIAL, N1_CBASE, N1_ITEM, N1_AQUISIC, N1_DESCRIC, N1_PRZDEPR, N1_GRUPO, N3_FILIAL, N3_CBASE, "
		    	cQuery	+= " N3_ITEM, N3_TIPO, N3_VORIG1, N3_VRDACM1, N3_VRDBAL1, N3_DINDEPR, N3_DTBAIXA,N3_VRCDA1, N3_TXDEPR1, N3_AMPLIA1, N3_VRCACM1, N4_FILIAL, N4_CBASE, "
   			    cQuery	+= "N4_ITEM, N4_TIPO, N4_OCORR, N4_MOTIVO, N4_VENDA, N4_VLROC1, IE_INDICE, IE_EXERCIC" 
				cQuery	+= " FROM " + RetSqlName("SN1") + "," + RetSqlName("SN3") + "," + RetSqlName("SN4") + "," + RetSqlName("SIE") + "," + RetSqlName("SNG")

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
				cQuery	+= " AND N3_TIPO  != '02'"

				
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
					cRngFil := STRTRAN (cRngFil, "N1_FILIAL","IE_FILIAL")
		 		ENDIF	
				
				IF EMPTY(cRngFil) .OR. cRngFil == NIL
						cQuery	+= " AND IE_FILIAL = '" + xFilial("SIE") + "'"
				ELSE 
						cQuery	+= " AND "+cRngFil				
				ENDIF						
				
				cQuery	+= " AND IE_EXERCIC  = '"+MV_PAR02+"'"
				
				IF ! EMPTY(cRngFil) .OR. cRngFil == NIL
					cRngFil := STRTRAN (cRngFil, "N1_FILIAL","NG_FILIAL")
		 		ENDIF	
				
				IF EMPTY(cRngFil) .OR. cRngFil == NIL
						cQuery	+= " AND NG_FILIAL = '" + xFilial("SNG") + "'"
				ELSE 
						cQuery	+= " AND "+cRngFil				
				ENDIF						

				
				
				
				cQuery := ChangeQuery(cQuery)
				
				If ( Select ( "TMPN1" ) <> 0 )
					dbSelectArea ( "TMPN1" )
					dbCloseArea ()
				Endif
			
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPN1",.T.,.F.)
				
				dbSelectArea("TMPN1")
				
				WHILE 	TMPN1->(!EOF())
	                
		            nUtilEps := TMPN1->N1_PRZDEPR / 12 
		            
		            If nUtilEps < 0
			            nUtilEps := 0
	                Endif
	                
                	nMValias 	:= ((TMPN1->N3_VORIG1 - TMPN1->N3_VRDACM1)-TMPN1->N4_VLROC1)
					nMValFis 	:= ((TMPN1->N3_VORIG1 - TMPN1->N3_VRDACM1)-TMPN1->N4_VLROC1)*IE_INDICE
	                
                
	                
					@ Li,aCol2[1]    PSay cTraco2
					@ Li, aCol[1]+1	 PSay SUBSTR(TMPN1->N1_GRUPO,1,1)+" | "+SUBSTR(TMPN1->N1_GRUPO,2,1)+" | "+SUBSTR(TMPN1->N1_GRUPO,3,1)+" | "+SUBSTR(TMPN1->N1_GRUPO,4,1)
					@ Li,aCol2[2]    PSay cTraco2
					@ Li, aCol[2]  	 PSay SuBSTR(TMPN1->N1_DESCRIC,1,30)
					@ Li,aCol2[3]    PSay cTraco2
					@ Li, aCol[3]  	 PSay SUBSTR(TMPN1->N1_AQUISIC,1,4)
					@ Li,aCol2[4]    PSay cTraco2
					@ Li, aCol[4]    PSay SUBSTR(TMPN1->N3_DINDEPR,5,2)
					@ Li,aCol2[5]    PSay cTraco2                                     
					@ Li, aCol[5]  	 PSay SUBSTR(TMPN1->N3_DINDEPR,1,4)
					@ Li,aCol2[6]    PSay cTraco2
					@ Li, aCol[6]  	 PSay TMPN1->N3_VORIG1    PICTURE "@E 999,999,999,999.99"
					@ Li,aCol2[7]    PSay cTraco2
					@ Li, aCol[7]  	 PSay nUtilEps  
					@ Li,aCol2[8]    PSay cTraco2
					@ Li, aCol[8]  	 PSay TMPN1->N3_VRDACM1   PICTURE "@E 9,999,999.99"
					@ Li,aCol2[9]    PSay cTraco2
					@ Li, aCol[9]    PSay TMPN1->N3_TXDEPR1   PICTURE "@E 99.99"
					@ Li,aCol2[10]   PSay cTraco2
					@ Li, aCol[10] 	 PSay TMPN1->N3_VRDBAL1   PICTURE "@E 999,999,999.99"
					@ Li,aCol2[11]   PSay cTraco2
					@ Li, aCol[11]   PSay (TMPN1->N3_VRDACM1 + TMPN1->N3_VRDBAL1)   PICTURE "@E 999,999,999.99"
					@ Li,aCol2[12]   PSay cTraco2
					@ Li, aCol[12]	 PSay SN3->N3_VLACTXP   PICTURE "@E 999,999.99"
					@ Li,aCol2[13]   PSay cTraco2
					@ Li, aCol[13]	 PSay SUBSTR(TMPN1->N1_AQUISIC,1,4)
					@ Li,aCol2[14]   PSay cTraco2
					@ Li, aCol[14]	 PSay TMPN1->N4_VLROC1 - nMValFis PICTURE "@E 999,999,999.99"
					@ Li,aCol2[15]   PSay cTraco2
					@ Li, aCol[15]	 PSay ((TMPN1->N4_VLROC1 - nMValFis)*TMPN1->N3_TXDEPR1) PICTURE "@E 999,999,999.99"
					@ Li,220  		 PSay cTraco2
				    Li++
				    
				    nTotCol6  += TMPN1->N3_VORIG1
			        nTotCol8  += TMPN1->N3_VRDACM1
			        nTotCol10 += TMPN1->N3_VRDBAL1
			        nTotCol11 += (TMPN1->N3_VRDACM1 + TMPN1->N3_VRDBAL1) 
			        nTotCol15 += ((TMPN1->N4_VLROC1 - nMValFis)*TMPN1->N3_TXDEPR1)
					nUtilEps := 0
					
					IF Li > 55 
					    
						//+--------------------
						//| TRACO RODAPE
						//+--------------------
						nLi := 0
						For nLi := 1 to limite
							@ Li, nLi  PSay cTraco1
						Next nLi	
						Li++
					
					
						@ Li, aCol2[1]  PSay cTraco2				
						@ Li,  aCol[2]  PSay STR0059 //"TOTAL GERAL OU A TRANSPORTAR"
						@ Li, aCol2[6]  PSay cTraco2				
						@ Li,  aCol[6]  PSay nTotCol6  	PICTURE "@E 999,999,999,999.99"
						@ Li, aCol2[7]  PSay cTraco2								
						@ Li, aCol2[8]  PSay cTraco2								
						@ Li,  aCol[8]  PSay nTotCol8 	PICTURE "@E 999,999.99"
						@ Li, aCol2[9]  PSay cTraco2								
						@ Li, aCol2[10] PSay cTraco2								
						@ Li,  aCol[10] PSay nTotCol10 	PICTURE "@E 99,999,999.99"
						@ Li, aCol2[11] PSay cTraco2								
						@ Li,  aCol[11] PSay nTotCol11 	PICTURE "@E 999,999,999.99"
						@ Li, aCol2[12] PSay cTraco2								
						@ Li, aCol2[15] PSay cTraco2								
						@ Li,  aCol[15] PSay nTotCol15  PICTURE "@E 999,999,999.99"
						Li++
						
						//+--------------------
						//| TRACO RODAPE
						//+--------------------
						nLi := 0
						For nLi := 1 to limite
							@ Li, nLi  PSay cTraco1
						Next nLi	
						Li++
						
						Li := 0
						CbMap321(lEnd,wnrel,cString)
					Endif
			        
				TMPN1->(DBSKIP())
				Enddo
				//+--------------------
				//| TRACO RODAPE
				//+--------------------
				nLi := 0
				For nLi := 1 to limite
					@ Li, nLi  PSay cTraco1
				Next nLi	
				Li++				

				@ Li, aCol2[1]  PSay cTraco2				
				@ Li,  aCol[2]  PSay STR0059 //"TOTAL GERAL OU A TRANSPORTAR"
				@ Li, aCol2[6]  PSay cTraco2				
				@ Li,  aCol[6]  PSay nTotCol6  	PICTURE "@E 999,999,999,999.99"
				@ Li, aCol2[7]  PSay cTraco2								
				@ Li, aCol2[8]  PSay cTraco2								
				@ Li,  aCol[8]  PSay nTotCol8 	PICTURE "@E 999,999.99"
				@ Li, aCol2[9]  PSay cTraco2								
				@ Li, aCol2[10] PSay cTraco2								
				@ Li,  aCol[10] PSay nTotCol10 	PICTURE "@E 99,999,999.99"
				@ Li, aCol2[11] PSay cTraco2								
				@ Li,  aCol[11] PSay nTotCol11 	PICTURE "@E 999,999,999.99"
				@ Li, aCol2[12] PSay cTraco2								
				@ Li, aCol2[15] PSay cTraco2								
				@ Li,  aCol[15] PSay nTotCol15  PICTURE "@E 999,999,999.99"
				Li++
				
				//+--------------------
				//| TRACO RODAPE
				//+--------------------
				nLi := 0
				For nLi := 1 to limite
					@ Li, nLi  PSay cTraco1
				Next nLi	
				Li++
				
		    ENDIF
	#ENDIF
    
	
	Return


/*        10       20        30         40        50       60        70         80        90        100       110       120       130       140       150       160       170       180       190       200       210      220
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
|CODIGO DE ACORDO |          DESCRICAO           |      DATA      |   VALOR DE AQUISICAO    |NUMERO DE |        REINTEGRACOES E AMORTIZACOES              |    TAXAS      |      MAIS-VALIAS       |   REINTEGRACOES E     |
|COM A TABELA ANE |                              |AQUIS|  INICIO  |     CONTABILISTICO      | ANOS DE  | EXERCICIOS |   DO EXERCICIO     |  ACUMULADAS    |   PERDIDAS    |     NAO TRIBUTADAS     |    AMORTIZACOES       |
|XA AO DEC. REG.  |                              |     |UTILIZACAO| 	    NA FALTA        |UTILIDADE | ANTERIORES |--------------------|                |  ACUMULADAS   |                        |     NAO ACEITES       |
|N 2/90 DE 12/01  |                              | ANO | MES | ANO|         DAQUELES        | ESPERADA |            |TAXAS|  VALORES     |                |               |  ANO  |    MONTANTE    |                       |
*/	