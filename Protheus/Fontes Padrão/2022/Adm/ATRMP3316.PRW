#INCLUDE "PROTHEUS.ch"
#INCLUDE "ATRMP3316.ch"
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | ATRMP3316		     | AUTOR | microsiga    | DATA | 30/05/2008 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | 										                        |//
//|           | 												                |//
//|           | Funcao de impressao                                             |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////    
	Function ATRMP3316(lEnd,wnrel,cString)
   
   		//CABECALHO       
	 	CaB3316 (lEnd,wnrel,cString)
	 	
	 	//DADOS
		DADOS3316 (lEnd,wnrel,cString)		
		
		
		If aReturn[5] == 1
		   Set Printer TO
		   dbCommitAll()
		   Ourspool(wnrel)
		EndIf
	
		Ms_Flush()	 	
	 	

	RETURN


///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | CaB3316  		     | AUTOR | microsiga    | DATA | 30/05/2008 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | 										                        |//
//|           | 												                |//
//|           | Funcao de impressao  DO CABECALHO                               |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////

	
	Function CaB3316 (lEnd,wnrel,cString)
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
	@ Li,052  PSay STR0004 //"ELEMENTOS DO ACTIVO IMOBILIZADO CORPOREO REAVALIADOS AO ABRIGO DO DECRETO-LEI N 264/ 92. DE 24 DE NOVEMBRO "
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
	@ Li,052  PSay STR0007 //"                                 METEDO DAS QUOTAS DEGRESSIVAS "
	@ Li,160  PSay cTraco2  
	@ Li,203  PSay cTraco2  
	@ Li,205  PSay cTraco2  
	@ Li,208  PSay STR0008   //"M O D E L O"
	@ Li,220  PSay cTraco2  
	Li++
	@ Li,001  PSay cTraco2   
	@ Li,004  PSay STR0009 //"PERIODO DE TRIBUTACAO"
	@ Li,026  PSay STR0010 //" DE "
	@ Li,030  PSay MV_PAR03
	@ Li,039  PSay STR0011 //" A "
	@ Li,042  PSay MV_PAR04
	@ Li,050  PSay cTraco2                                                                                    
	@ Li,052  PSay STR0012 //"              (a)_________________________________________________________________________"
	@ Li,160  PSay cTraco2  
	@ Li,181  PSay STR0013   //"CODIGO CAE "
	@ Li,197  PSay SM0->M0_CNAE  PICTURE "99999"  
	@ Li,203  PSay cTraco2  
	@ Li,205  PSay cTraco2  
	@ Li,208  PSay STR0014   //"   33.16"
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
                                                     
	@ Li,001  PSay STR0015	 //"|CODIGO DE ACORDO "
	@ Li,019  PSay STR0016 //"|          DESCRICAO           "
	@ Li,050  PSay STR0017 //"|      DATA      "
	@ Li,067  PSay STR0018 //"|             VALORES DO ACTIVO IMOBILIZADO              "
	@ Li,124  PSay STR0019 //"|                 REINTEGRACOES ACTUALIZADAS                  "
	@ Li,186  PSay STR0020 //"|   ACTIVO  "
	@ Li,198  PSay STR0021 //"| REINTEGRACOES "
	@ Li,214  PSay STR0022 //"|TAXAS"
	@ Li,220  PSay "|"	
	Li++	


	//+--------------------
	//| LINHA 2 COLUNAS
	//+--------------------

	@ Li,001  PSay STR0023 //"|COM A TABELA ANE "
	@ Li,019  PSay STR0024 //"|                              "
	@ Li,050  PSay STR0025 //"|AQUIS"
	@ Li,056  PSay STR0026 //"|  INICIO  "
	@ Li,067  PSay STR0027 //"|   DE AQUISICAO   "
	@ Li,086  PSay STR0028 //"|    REAVALIADO    "
	@ Li,105  PSay STR0029 //"|  DE REAVALIACAO  "
	@ Li,124  PSay STR0030 //"|       DE         "
	@ Li,143  PSay STR0031 //"|      DO EXERCICIO      "
	@ Li,168  PSay STR0032 //"|                 "
	@ Li,186  PSay STR0033 //"|IMOBILIZADO"
	@ Li,198  PSay STR0034 //"| SOBRE O VALOR "
	@ Li,214  PSay STR0035 //"|PERDI"
	@ Li,220  PSay "|"
    LI++

	//+--------------------
	//| LINHA 3 COLUNAS
	//+--------------------

	@ Li,001  PSay STR0036 //"|XA AO DEC. REG.  "
	@ Li,019  PSay STR0024 //"|                              "
	@ Li,050  PSay STR0037 //"|     "
	@ Li,056  PSay STR0038 //"|UTILIZACAO"
	@ Li,067  PSay STR0039 //"|   OU PRODUCAO    "
	@ Li,086  PSay STR0040 //"|                  "
	@ Li,105  PSay STR0041 //"|       NAO        "
	@ Li,124  PSay STR0042 //"|   EXERCICIOS     "
	@ Li,143  PSay STR0043 //"| TAXAS "
	@ Li,151  PSay STR0044 //"|    VALORES     "
	@ Li,168  PSay STR0045 //"|  ACUMULADAS     "
	@ Li,186  PSay STR0046 //"| (VALORES  "
	@ Li,198  PSay STR0047 //"|  DE AQUISICAO "
	@ Li,214  PSay STR0048 //"| DAS "
	@ Li,220  PSay "|"
    LI++

	//+--------------------
	//| LINHA 4 COLUNAS
	//+--------------------
    
    @ Li,001  PSay STR0049 //"|N 2/90 DE 12/01  "
	@ Li,019  PSay STR0024 //"|                              "
	@ Li,050  PSay STR0050 //"| ANO "
	@ Li,056  PSay STR0051 //"| MES "
	@ Li,062  PSay STR0052 //"| ANO"
	@ Li,067  PSay STR0040 //"|                  "
	@ Li,086  PSay STR0040 //"|                  "
	@ Li,105  PSay STR0053 //"|   REINTEGRADO    "
	@ Li,124  PSay STR0054 //"|   ANTERIORES     "
	@ Li,143  PSay STR0055 //"|       "
	@ Li,151  PSay STR0056 //"|                "
	@ Li,168  PSay STR0032 //"|                 "
	@ Li,186  PSay STR0057 //"|  LIQUIDOS)"
	@ Li,198  PSay STR0058 //"|NAO REINTEGRADO"
	@ Li,214  PSay STR0037 //"|     "
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
//| PROGRAMA  | DADOS3316		     | AUTOR | microsiga    | DATA | 30/05/2008 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | 										                        |//
//|           | 												                |//
//|           | Funcao de impressao E PROCESSAMENTOS DOS DADOS                  |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////

	
	FUNCTION DADOS3316 (lEnd,wnrel,cString) 
	
	   	//+--------------------
	//| Declaracao de variaveis
	//+--------------------
	Local cTraco1	:= "-"
	Local cTraco2	:= "|" 	
	Local nLi 		:= 0
    Local aCol 		:= {}
    Local aCol2 	:= {}
    
   	Local nTotCol6 	:= 0 
	Local nTotCol7  := 0
	Local nTotCol8  := 0
	Local nTotCol9  := 0 
	Local nTotCol11 := 0
	Local nTotCol12 := 0
	Local nTotCol13 := 0
	Local nTotCol14	:= 0			
    
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
	aAdd( aCol, 105 ) //8
	aAdd( aCol, 124 ) //9
	aAdd( aCol, 143 ) //10
	aAdd( aCol, 151 ) //11
	aAdd( aCol, 168 ) //12
	aAdd( aCol, 186 ) //13
	aAdd( aCol, 198 ) //14
	aAdd( aCol, 214 ) //15
	aAdd( aCol, 220 ) //16

	
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
	aAdd( aCol2, 106 ) //8
	aAdd( aCol2, 125 ) //9
	aAdd( aCol2, 144 ) //10
	aAdd( aCol2, 152 ) //11
	aAdd( aCol2, 169 ) //12
	aAdd( aCol2, 187 ) //13
	aAdd( aCol2, 199 ) //14
	aAdd( aCol2, 215 ) //15

	
    MakeSqlExpr("ATRMAP")
                         
    cRngFil := MV_PAR01
    
    #IFDEF TOP
	    If TcSrvType() <> "AS/400"
		   	cQuery	:= "SELECT N1_FILIAL, N1_CBASE, N1_ITEM, N1_AQUISIC, N1_DESCRIC, N1_PRZDEPR, N1_GRUPO, N3_FILIAL, N3_CBASE, "
		   	cQuery	+= " N3_ITEM, N3_TIPO, N3_VORIG1, N3_VRDACM1, N3_VRDBAL1, N3_DINDEPR, N3_VLACTXP, N3_VRCDA1, N3_TXDEPR1, N3_AMPLIA1, N3_VRCACM1, N4_FILIAL, N4_CBASE, "
   		    cQuery	+= "N4_ITEM, N4_TIPO, N4_OCORR, N4_MOTIVO, N4_VENDA, NG_TXDEPR1, N4_VLROC1, IE_INDICE, IE_EXERCIC" 
			cQuery	+= " FROM " + RetSqlName("SN1")+","+ RetSqlName("SN3")+ "," + RetSqlName("SN4")+ "," + RetSqlName("SNG")+ "," + RetSqlName("SIE")

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
			cQuery	+= " AND ( N3_TIPO  = '02'"				
			cQuery	+= "  OR ( N3_TIPO  >= '20'"				
			cQuery	+= " AND   N3_TIPO  <= '32' ))"				
  
				
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
            	
					@ Li, aCol[1]  PSay cTraco2
					@ Li,aCol2[1]+1 PSay SUBSTR(TMPN1->N1_GRUPO,1,1)+" | "+SUBSTR(TMPN1->N1_GRUPO,2,1)+" | "+SUBSTR(TMPN1->N1_GRUPO,3,1)+" | "+SUBSTR(TMPN1->N1_GRUPO,4,1)
					@ Li, aCol[2]  PSay cTraco2
					@ Li,aCol2[2]  PSay SuBSTR(TMPN1->N1_DESCRIC,1,30)
					@ Li, aCol[3]  PSay cTraco2
					@ Li,aCol2[3]  PSay SUBSTR(TMPN1->N1_AQUISIC,1,4)
					@ Li, aCol[4]  PSay cTraco2
					@ Li,aCol2[4]  PSay SUBSTR(TMPN1->N3_DINDEPR,5,2)
					@ Li, aCol[5]  PSay cTraco2
					@ Li,aCol2[5]  PSay SUBSTR(TMPN1->N3_DINDEPR,1,4)
					@ Li, aCol[6]  PSay cTraco2
					@ Li,aCol2[6]  PSay TMPN1->N3_VORIG1    PICTURE "@E 999,999.99"		
					@ Li, aCol[7]  PSay cTraco2
					@ Li,aCol2[7]  PSay TMPN1->N3_VORIG1		PICTURE "@E 999,999.99"
					@ Li, aCol[8]  PSay cTraco2
					@ Li,aCol2[8]  PSay TMPN1->N3_VORIG1 - N3_VRDACM1 PICTURE "@E 999,999.99"		
					@ Li, aCol[9]  PSay cTraco2
					@ Li,aCol2[9]   PSay TMPN1->N3_VORIG1		PICTURE "@E 999,999.99"	
					@ Li, aCol[10]  PSay cTraco2
					@ Li,aCol2[10]  PSay TMPN1->N1_PRZDEPR      PICTURE "@E 99.99"	 
					@ Li, aCol[11]  PSay cTraco2
					@ Li,aCol2[11]  PSay TMPN1->N3_VRDACM1	    PICTURE "@E 999,999.99"
					@ Li, aCol[12]  PSay cTraco2
					@ Li,aCol2[12]  PSay TMPN1->N3_VORIG1 + TMPN1->N3_VRDACM1 PICTURE "@E 999,999.99"
					@ Li, aCol[13]  PSay cTraco2
					@ Li,aCol2[13]  PSay (TMPN1->N3_VORIG1-(TMPN1->N3_VORIG1 + TMPN1->N3_VRDACM1))  PICTURE "@E 999,999.99"
					@ Li, aCol[14]  PSay cTraco2
					@ Li,aCol2[14]  PSay TMPN1->N3_VRDACM1 - TMPN1->IE_INDICE    PICTURE "@E 999,999.99"
					@ Li, aCol[15] PSay cTraco2
					@ Li,aCol2[15] PSay N3_VLACTXP  PICTURE "@E 99.99"
					@ Li, aCol[16] PSay cTraco2
					Li++	
					
					nTotCol6 	+= TMPN1->N3_VORIG1
					nTotCol7    += TMPN1->N3_VORIG1
					nTotCol8    += TMPN1->N3_VORIG1 - N3_VRDACM1
					nTotCol9    += TMPN1->N3_VORIG1 
					nTotCol11   += TMPN1->N3_VRDACM1
					nTotCol12   += TMPN1->N3_VORIG1 + TMPN1->N3_VRDACM1
					nTotCol13   += (TMPN1->N3_VORIG1-(TMPN1->N3_VORIG1 + TMPN1->N3_VRDACM1))
					nTotCol14	+= (TMPN1->N3_VRDACM1 - TMPN1->IE_INDICE) 																													
					
					If Li > 55 
					   	//+--------------------
						//| TRACO INFERIOR
						//+--------------------
						nLi := 0
						For nLi := 1 to limite
							@ Li, nLi  PSay cTraco1
						Next nLi	
						Li++
    		                
			   			@ Li, aCol[1]   PSay cTraco2
						@ Li,aCol2[2]   PSay STR0059		 //"TOTAL GERAL OU A TRASNPORTAR"
			   			@ Li, aCol[6]   PSay cTraco2
						@ Li,aCol2[6]   PSay nTotCol6 PICTURE "@E 999,999.99"		
			   			@ Li, aCol[7]   PSay cTraco2
						@ Li,aCol2[7]   PSay nTotCol7 PICTURE "@E 999,999.99"		
			   			@ Li, aCol[8]   PSay cTraco2
						@ Li,aCol2[8]   PSay nTotCol8 PICTURE "@E 999,999.99"		
			   			@ Li, aCol[9]   PSay cTraco2
						@ Li,aCol2[9]   PSay nTotCol9 PICTURE "@E 999,999.99"											
			   			@ Li, aCol[10]  PSay cTraco2    		
			   			@ Li, aCol[11]  PSay cTraco2
						@ Li,aCol2[11]  PSay nTotCol11 PICTURE "@E 999,999.99"		
			   			@ Li, aCol[12]  PSay cTraco2
						@ Li,aCol2[12]  PSay nTotCol12  PICTURE "@E 999,999.99"		
			   			@ Li, aCol[13]  PSay cTraco2
						@ Li,aCol2[13]  PSay nTotCol13 PICTURE "@E 999,999.99"		
			   			@ Li, aCol[14]  PSay cTraco2
						@ Li,aCol2[14]  PSay nTotCol14 PICTURE "@E 999,999.99" 		
			   			@ Li, aCol[15]  PSay cTraco2   			   			   			   			
			   			@ Li, aCol[16]  PSay cTraco2   			   			   			   			
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
										    
					Endif
					
            	
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
    		                
   			@ Li, aCol[1]   PSay cTraco2
			@ Li,aCol2[2]   PSay STR0059		 //"TOTAL GERAL OU A TRASNPORTAR"
   			@ Li, aCol[6]   PSay cTraco2
			@ Li,aCol2[6]   PSay nTotCol6 PICTURE "@E 999,999.99"		
   			@ Li, aCol[7]   PSay cTraco2
			@ Li,aCol2[7]   PSay nTotCol7 PICTURE "@E 999,999.99"		
   			@ Li, aCol[8]   PSay cTraco2
			@ Li,aCol2[8]   PSay nTotCol8 PICTURE "@E 999,999.99"		
   			@ Li, aCol[9]   PSay cTraco2
			@ Li,aCol2[9]   PSay nTotCol9 PICTURE "@E 999,999.99"											
   			@ Li, aCol[10]  PSay cTraco2    		
   			@ Li, aCol[11]  PSay cTraco2
			@ Li,aCol2[11]  PSay nTotCol11 PICTURE "@E 999,999.99"		
   			@ Li, aCol[12]  PSay cTraco2
			@ Li,aCol2[12]  PSay nTotCol12  PICTURE "@E 999,999.99"		
   			@ Li, aCol[13]  PSay cTraco2
			@ Li,aCol2[13]  PSay nTotCol13 PICTURE "@E 999,999.99"		
   			@ Li, aCol[14]  PSay cTraco2
			@ Li,aCol2[14]  PSay nTotCol14 PICTURE "@E 999,999.99" 		
   			@ Li, aCol[15]  PSay cTraco2   			   			   			   			
   			@ Li, aCol[16]  PSay cTraco2   			   			   			   			
            Li++
		   	//+--------------------
			//| TRACO INFERIOR
			//+--------------------
			nLi := 0
			For nLi := 1 to limite
				@ Li, nLi  PSay cTraco1
			Next nLi	
			Li++
   
         ENDIF
	#ENDIF
	
	
	
	
	RETURN

/*        10       20        30         40        50       60        70         80        90        100       110       120       130       140       150       160       170       180       190       200       210      220
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
|CODIGO DE ACORDO |          DESCRICAO           |      DATA      |             VALORES DO ACTIVO IMOBILIZADO              |                 REINTEGRACOES ACTUALIZADAS                  |   ACTIVO  | REINTEGRACOES |TAXAS|
|COM A TABELA ANE |                              |AQUIS|  INICIO  |   DE AQUISICAO   |    REAVALIADO    |  DE REAVALIACAO  |       DE         |      DO EXERCICIO      |                 |IMOBILIZADO| SOBRE O VALOR |PERDI|
|XA AO DEC. REG.  |                              |     |UTILIZACAO|   OU PRODUCAO    |                  |       NAO        |   EXERCICIOS     | TAXAS |    VALORES     |  ACUMULADAS     | (VALORES  |  DE AQUISICAO | DAS |
|N 2/90 DE 12/01  |                              | ANO | MES | ANO|                  |                  |   REINTEGRADO    |   ANTERIORES     |       |                |                 |  LIQUIDOS)|NAO REINTEGRADO|     |
*/	