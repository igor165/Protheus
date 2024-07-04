#INCLUDE "PROTHEUS.ch"
#INCLUDE "ATRMP3318.ch"
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | ATRMP3318		     | AUTOR | microsiga    | DATA | 30/05/2008 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | 										                        |//
//|           | 												                |//
//|           | Funcao de impressao                                             |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////    
	Function ATRMP3318(lEnd,wnrel,cString)
	
		//Cabecalho
		Cab3318 (lEnd,wnrel,cString)	 
	    
		//DADOS
		DADOS3318 (lEnd,wnrel,cString)

		If aReturn[5] == 1
		   Set Printer TO
		   dbCommitAll()
		   Ourspool(wnrel)
		EndIf
	
		Ms_Flush()

		 
	
	Return
	
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | Cab3318	   		     | AUTOR | microsiga    | DATA | 30/05/2008 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | 										                        |//
//|           | 												                |//
//|           | Funcao de CABECALHO                                             |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////   	
	
	
	Function Cab3318 (lEnd,wnrel,cString)
	
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
	@ Li,052  PSay STR0004 //"ELEMENTOS DO ACTIVO IMOBILIZADO CORPOREO REAVALIADOS AO ABRIGO DO DECRETO-LEI N 31/ 98. DE 11 DE FEVEREIRO "
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
	@ Li,052  PSay STR0007 //"                       NAO TOTALMENTE REINTEGRADOS - NA DATA A QUE SE REPORTA A REAVALIACAO "
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
	@ Li,208  PSay STR0014   //"   33.18"
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
	@ Li,050  PSay STR0017 //"|    ANO     "
	@ Li,063  PSay STR0018 //"|         VALORES DO ACTIVO IMOBILIZADO         "
	@ Li,111  PSay STR0019 //"|               "
	@ Li,127  PSay STR0020 //"|   REINTEGRACOES ACTUALIZADAS  "
	@ Li,159  PSay STR0021 //"|   ACTIVO  "
	@ Li,171  PSay STR0022 //"|              "
	@ Li,186  PSay STR0023	 //"|           "
	@ Li,198  PSay STR0024	 //"| REINTEGRACOES "
	@ Li,214  PSay STR0025	 //"|TAXAS"
	@ Li,220  PSay STR0026	 //"|"
	Li++	


	//+--------------------
	//| LINHA 2 COLUNAS
	//+--------------------

	@ Li,001  PSay STR0027 //"|COM A TABELA ANE "
	@ Li,019  PSay STR0028 //"|                              "
	@ Li,050  PSay STR0029 //"|AQUIS"
	@ Li,056  PSay STR0030 //"|INICIO"
	@ Li,063  PSay STR0031 //"| DE AQUISICAO  "
	@ Li,079  PSay STR0032 //"|DEC-LEI 430/78 "
	@ Li,095  PSay STR0019 //"|               "
	@ Li,111  PSay STR0033 //"|NUMERO DE ANOS "
	@ Li,127  PSay STR0034 //"|    DO EXERCICIO   "
	@ Li,147  PSay STR0023 //"|           "
	@ Li,159  PSay STR0035 //"|IMOBILIZADO"
	@ Li,171  PSay STR0036 //"| MAIS-VALIAS  "
	@ Li,186  PSay STR0037 //"|  REINTE-  "
	@ Li,198  PSay STR0038 //"| SOBRE O VALOR "
	@ Li,214  PSay STR0039			 //"|PERDI"
	@ Li,220  PSay "|"	
    LI++

	//+--------------------
	//| LINHA 3 COLUNAS
	//+--------------------

	@ Li,001  PSay STR0040 //"|XA AO DEC. REG.  "
	@ Li,019  PSay STR0028 //"|                              "
	@ Li,050  PSay STR0041 //"| CAO "
	@ Li,056  PSay STR0042 //"|UTILI-"
	@ Li,063  PSay STR0043 //"| PRODUCAO OU   "
	@ Li,079  PSay STR0044 //"|DEC-LEI 24/82  "
	@ Li,095  PSay STR0019 //"|               "
	@ Li,111  PSay STR0045 //"| DE UTILIDADE  "
	@ Li,127  PSay STR0025 //"|TAXAS"
	@ Li,133  PSay STR0046 //"|   VALORES   "
	@ Li,147  PSay STR0047 //"|ACUMULADAS "
	@ Li,159  PSay STR0048 //"| (VALORES  "
	@ Li,171  PSay STR0049 //"|     NAO      "
	@ Li,186  PSay STR0050 //"|  GRACOES  "
	@ Li,198  PSay STR0051 //"|  DE AQUISICAO "
	@ Li,214  PSay STR0052 //"| DAS "
	@ Li,220  PSay STR0026	 //"|"
    LI++


	//+--------------------
	//| LINHA 4 COLUNAS
	//+--------------------
    
    @ Li,001  PSay STR0053 //"|N 2/90 DE 12/01  "
	@ Li,019  PSay STR0028 //"|                              "
	@ Li,050  PSay STR0054 //"|     "
	@ Li,056  PSay STR0055 //"|ZACAO "
	@ Li,063  PSay STR0056 //"|   OUTROS      "
	@ Li,079  PSay STR0057 //"|DEC-LEI 219/82 "
	@ Li,095  PSay STR0019 //"|               "
	@ Li,111  PSay STR0058 //"|   ESPERADA    "
	@ Li,127  PSay STR0054 //"|     "
	@ Li,133  PSay STR0059 //"|             "
	@ Li,147  PSay STR0023 //"|           "
	@ Li,159  PSay STR0060 //"| LIQUIDOS) "
	@ Li,171  PSay STR0061 //"|  TRIBUTADAS  "
	@ Li,186  PSay STR0062 //"|    NAO    "
	@ Li,198  PSay STR0063 //"|NAO REINTEGRADO"
	@ Li,214  PSay STR0054 //"|     "
	@ Li,220  PSay STR0026	 //"|"
    LI++


	//+--------------------
	//| LINHA 5 COLUNAS
	//+--------------------
    
    @ Li,001  PSay STR0064 //"|                 "
	@ Li,019  PSay STR0028 //"|                              "
	@ Li,050  PSay STR0054 //"|     "
	@ Li,056  PSay STR0065 //"|      "
	@ Li,063  PSay STR0066 //"|   VALORES     "
	@ Li,079  PSay STR0067 //"|DEC-LEI 143/84 "
	@ Li,095  PSay STR0019 //"|               "
	@ Li,111  PSay STR0019 //"|               "
	@ Li,127  PSay STR0054 //"|     "
	@ Li,133  PSay STR0059 //"|             "
	@ Li,147  PSay STR0023 //"|           "
	@ Li,159  PSay STR0023 //"|           "
	@ Li,171  PSay STR0022 //"|              "
	@ Li,186  PSay STR0068 //"|  ACEITES  "
	@ Li,198  PSay STR0019 //"|               "
	@ Li,214  PSay STR0054 //"|     "
	@ Li,220  PSay "|"	
    LI++

	//+--------------------
	//| LINHA 6 COLUNAS
	//+--------------------
    
    @ Li,001  PSay STR0064 //"|                 "
	@ Li,019  PSay STR0028 //"|                              "
	@ Li,050  PSay STR0054 //"|     "
	@ Li,056  PSay STR0065 //"|      "
	@ Li,063  PSay STR0069 //"|CONTABILISTICOS"
	@ Li,079  PSay STR0070 //"|DEC-LEI 399G/84"
	@ Li,095  PSay STR0019 //"|               "
	@ Li,111  PSay STR0019 //"|               "
	@ Li,127  PSay STR0054 //"|     "
	@ Li,133  PSay STR0059 //"|             "
	@ Li,147  PSay STR0023 //"|           "
	@ Li,159  PSay STR0023 //"|           "
	@ Li,171  PSay STR0022 //"|              "
	@ Li,186  PSay STR0023 //"|           "
	@ Li,198  PSay STR0019 //"|               "
	@ Li,214  PSay STR0054 //"|     "
	@ Li,220  PSay "|"	
    LI++


	//+--------------------
	//| LINHA 7 COLUNAS
	//+--------------------
    
    @ Li,001  PSay STR0064 //"|                 "
	@ Li,019  PSay STR0028 //"|                              "
	@ Li,050  PSay STR0054 //"|     "
	@ Li,056  PSay STR0065 //"|      "
	@ Li,063  PSay STR0071 //"|LEI N 126/77 OU"
	@ Li,079  PSay STR0072 //"|DEC-LEI 278/85 "
	@ Li,095  PSay STR0073 //"|DEC-LEI N 31/98"
	@ Li,111  PSay STR0019 //"|               "
	@ Li,127  PSay STR0054 //"|     "
	@ Li,133  PSay STR0059 //"|             "
	@ Li,147  PSay STR0023 //"|           "
	@ Li,159  PSay STR0023 //"|           "
	@ Li,171  PSay STR0022 //"|              "
	@ Li,186  PSay STR0023 //"|           "
	@ Li,198  PSay STR0019 //"|               "
	@ Li,214  PSay STR0054 //"|     "
	@ Li,220  PSay "|"	
    LI++


	//+--------------------
	//| LINHA 8 COLUNAS
	//+--------------------
    
    @ Li,001  PSay STR0064 //"|                 "
	@ Li,019  PSay STR0028 //"|                              "
	@ Li,050  PSay STR0054 //"|     "
	@ Li,056  PSay STR0065 //"|      "
	@ Li,063  PSay STR0074 //"| PORT. N 20258 "
	@ Li,079  PSay STR0075 //"|DEC-LEI 118B/86"
	@ Li,095  PSay STR0019 //"|               "
	@ Li,111  PSay STR0019 //"|               "
	@ Li,127  PSay STR0054 //"|     "
	@ Li,133  PSay STR0059 //"|             "
	@ Li,147  PSay STR0023 //"|           "
	@ Li,159  PSay STR0023 //"|           "
	@ Li,171  PSay STR0022 //"|              "
	@ Li,186  PSay STR0023 //"|           "
	@ Li,198  PSay STR0019 //"|               "
	@ Li,214  PSay STR0054 //"|     "
	@ Li,220  PSay "|"	
    LI++
    
   	//+--------------------
	//| LINHA 9 COLUNAS
	//+--------------------
    
    @ Li,001  PSay STR0064 //"|                 "
	@ Li,019  PSay STR0028 //"|                              "
	@ Li,050  PSay STR0054 //"|     "
	@ Li,056  PSay STR0065 //"|      "
	@ Li,063  PSay STR0019 //"|               "
	@ Li,079  PSay STR0076 //"|DEC-LEI 111/88 "
	@ Li,095  PSay STR0019 //"|               "
	@ Li,111  PSay STR0019 //"|               "
	@ Li,127  PSay STR0054 //"|     "
	@ Li,133  PSay STR0059 //"|             "
	@ Li,147  PSay STR0023 //"|           "
	@ Li,159  PSay STR0023 //"|           "
	@ Li,171  PSay STR0022 //"|              "
	@ Li,186  PSay STR0023 //"|           "
	@ Li,198  PSay STR0019 //"|               "
	@ Li,214  PSay STR0054 //"|     "
	@ Li,220  PSay "|"	
    LI++
    
  	//+--------------------
	//| LINHA 10 COLUNAS
	//+--------------------
    
    @ Li,001  PSay STR0064 //"|                 "
	@ Li,019  PSay STR0028 //"|                              "
	@ Li,050  PSay STR0054 //"|     "
	@ Li,056  PSay STR0065 //"|      "
	@ Li,063  PSay STR0019 //"|               "
	@ Li,079  PSay STR0077 //"|DEC-LEI 49/91  "
	@ Li,095  PSay STR0019 //"|               "
	@ Li,111  PSay STR0019 //"|               "
	@ Li,127  PSay STR0054 //"|     "
	@ Li,133  PSay STR0059 //"|             "
	@ Li,147  PSay STR0023 //"|           "
	@ Li,159  PSay STR0023 //"|           "
	@ Li,171  PSay STR0022 //"|              "
	@ Li,186  PSay STR0023 //"|           "
	@ Li,198  PSay STR0019 //"|               "
	@ Li,214  PSay STR0054 //"|     "
	@ Li,220  PSay "|"	
    LI++


  	//+--------------------
	//| LINHA 11 COLUNAS
	//+--------------------
    
    @ Li,001  PSay STR0064 //"|                 "
	@ Li,019  PSay STR0028 //"|                              "
	@ Li,050  PSay STR0054 //"|     "
	@ Li,056  PSay STR0065 //"|      "
	@ Li,063  PSay STR0019 //"|               "
	@ Li,079  PSay STR0078 //"|DEC-LEI 264/92 "
	@ Li,095  PSay STR0019 //"|               "
	@ Li,111  PSay STR0019 //"|               "
	@ Li,127  PSay STR0054 //"|     "
	@ Li,133  PSay STR0059 //"|             "
	@ Li,147  PSay STR0023 //"|           "
	@ Li,159  PSay STR0023 //"|           "
	@ Li,171  PSay STR0022 //"|              "
	@ Li,186  PSay STR0023 //"|           "
	@ Li,198  PSay STR0019 //"|               "
	@ Li,214  PSay STR0054 //"|     "
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
//| PROGRAMA  | DADOS3318		     | AUTOR | microsiga    | DATA | 30/05/2008 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | 										                        |//
//|           | 												                |//
//|           | Funcao de PROCESSAMENTO E IMPRESSAO DOS DADOS                   |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////   		


	Function DADOS3318 (lEnd,wnrel,cString)	 

	//+--------------------
	//| Declaracao de variaveis
	//+--------------------
	Local cTraco1	:= "-"
	Local cTraco2	:= "|" 	
	Local nLi 		:= 0	
	Local aCol		:= {}
	Local aCol2		:= {}
	Local nUtilEps  := 0			
	
	Local nTotCol5  := 0
	Local nTotCol6  := 0
	Local nTotCol7  := 0
	Local nTotCol10 := 0
	Local nTotCol11 := 0
	Local nTotCol12 := 0
	Local nTotCol13 := 0										
	Local nTotCol14 := 0										
	Local nTotCol15 := 0
	
	
	//+--------------------
	//| Coluna de traco
	//+--------------------
	aAdd( aCol, 001 ) //1
	aAdd( aCol, 019 ) //2
	aAdd( aCol, 050 ) //3
	aAdd( aCol, 056 ) //4
	aAdd( aCol, 063 ) //5
	aAdd( aCol, 079 ) //6
	aAdd( aCol, 095 ) //7
	aAdd( aCol, 111 ) //8
	aAdd( aCol, 127 ) //9
	aAdd( aCol, 133 ) //10
	aAdd( aCol, 147 ) //11
	aAdd( aCol, 159 ) //12
	aAdd( aCol, 171 ) //13
	aAdd( aCol, 186 ) //14
	aAdd( aCol, 198 ) //15
	aAdd( aCol, 214 ) //16
	aAdd( aCol, 220 ) //17

	
	//+--------------------
	//| Coluna de impressao DOs DADOS
	//+--------------------
	aAdd( aCol2, 002 ) //1
	aAdd( aCol2, 020 ) //2
	aAdd( aCol2, 051 ) //3
	aAdd( aCol2, 057 ) //4
	aAdd( aCol2, 064 ) //5
	aAdd( aCol2, 080 ) //6
	aAdd( aCol2, 096 ) //7
	aAdd( aCol2, 112 ) //8
	aAdd( aCol2, 128 ) //9
	aAdd( aCol2, 134 ) //10
	aAdd( aCol2, 148 ) //11
	aAdd( aCol2, 160 ) //12
	aAdd( aCol2, 172 ) //13
	aAdd( aCol2, 187 ) //14
	aAdd( aCol2, 199 ) //15
	aAdd( aCol2, 215 ) //16
		
    MakeSqlExpr("ATRMAP")
                        
    cRngFil := MV_PAR01
    
    #IFDEF TOP
	    If TcSrvType() <> "AS/400"
	    	cQuery	:= "SELECT N1_FILIAL, N1_CBASE, N1_ITEM, N1_AQUISIC, N1_DESCRIC, N1_PRZDEPR, N1_GRUPO, N3_FILIAL, N3_CBASE, "
	    	cQuery	+= " N3_ITEM, N3_TIPO, N3_VORIG1, N3_VRDACM1, N3_VRDBAL1, N3_DINDEPR, N3_VLACTXP, N3_VRCDA1, N3_TXDEPR1, N3_AMPLIA1, N3_VRCACM1, N4_FILIAL, N4_CBASE, "
		    cQuery	+= "N4_ITEM, N4_TIPO, N4_OCORR, N4_MOTIVO, N4_VENDA, NG_TXDEPR1, N4_VLROC1, IE_INDICE, IE_EXERCIC " 
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
    		cQuery	+= " AND N3_TIPO  = '32'"
				
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
		
					nMValFis 	:= ((TMPN1->N3_VORIG1 - TMPN1->N3_VRDACM1)-TMPN1->N4_VLROC1)*IE_INDICE
					nUtilEps 	:= TMPN1->N1_PRZDEPR / 12
			
					@ Li, aCol[1]  PSay cTraco2
					@ Li,aCol2[1]+1 PSay SUBSTR(TMPN1->N1_GRUPO,1,1)+" | "+SUBSTR(TMPN1->N1_GRUPO,2,1)+" | "+SUBSTR(TMPN1->N1_GRUPO,3,1)+" | "+SUBSTR(TMPN1->N1_GRUPO,4,1)		
					@ Li, aCol[2]  PSay cTraco2
					@ Li,aCol2[2]  PSay SuBSTR(TMPN1->N1_DESCRIC,1,30)
					@ Li, aCol[3]  PSay cTraco2
					@ Li,aCol2[3]  PSay SUBSTR(TMPN1->N1_AQUISIC,1,4)
					@ Li, aCol[4]  PSay cTraco2
					@ Li,aCol2[4]  PSay SUBSTR(TMPN1->N3_DINDEPR,1,4)
					@ Li, aCol[5]  PSay cTraco2
					@ Li,aCol2[5]  PSay TMPN1->N3_VORIG1     PICTURE "@E 999,999.99"
					@ Li, aCol[6]  PSay cTraco2
					@ Li,aCol2[6]  PSay TMPN1->N3_VORIG1     PICTURE "@E 999,999.99"		
					@ Li, aCol[7]  PSay cTraco2
					@ Li,aCol2[7]  PSay TMPN1->N3_VORIG1	 PICTURE "@E 999,999.99"
					@ Li, aCol[8]  PSay cTraco2
					@ Li,aCol2[8]  PSay nUtilEps      		 PICTURE  "@E      999"		
					@ Li, aCol[9]  PSay cTraco2
					@ Li,aCol2[9]  PSay TMPN1->N3_TXDEPR1    PICTURE "@E 99.99"		
					@ Li, aCol[10] PSay cTraco2
					@ Li,aCol2[10] PSay TMPN1->N3_VRDBAL1	 PICTURE "@E 99,999.99"	
					@ Li, aCol[11] PSay cTraco2
					@ Li,aCol2[11] PSay TMPN1->N3_VRDACM1	 PICTURE "@E 99,999.99"
					@ Li, aCol[12] PSay cTraco2
					@ Li,aCol2[12] PSay TMPN1->N3_VORIG1 - TMPN1->N3_VRDACM1  PICTURE "@E 99,999.99"
					@ Li, aCol[13] PSay cTraco2
					@ Li,aCol2[13] PSay (TMPN1->N3_VORIG1 - (TMPN1->N3_VORIG1 - TMPN1->N3_VRDACM1)) PICTURE "@E 999,999.99"  
					@ Li, aCol[14] PSay cTraco2
					@ Li,aCol2[14] PSay (nMValFis * TMPN1->N3_TXDEPR1) PICTURE "@E 999,999.99"
					@ Li, aCol[15] PSay cTraco2
					@ Li,aCol2[15] PSay (TMPN1->N3_VRDBAL1 - TMPN1->N3_VORIG1)  PICTURE "@E 999,999,999.99"
					@ Li, aCol[16] PSay cTraco2
					@ Li,aCol2[16] PSay N3_VLACTXP           PICTURE "@E 99.99"
					@ Li, aCol[17] PSay cTraco2
					Li++
					
					nTotCol5  += TMPN1->N3_VORIG1
					nTotCol6  += TMPN1->N3_VORIG1
					nTotCol7  += TMPN1->N3_VORIG1					
					nTotCol10 += TMPN1->N3_VRDBAL1					
					nTotCol11 += TMPN1->N3_VRDACM1					
					nTotCol12 += TMPN1->N3_VORIG1 - TMPN1->N3_VRDACM1										
					nTotCol13 += (TMPN1->N3_VORIG1 - (TMPN1->N3_VORIG1 - TMPN1->N3_VRDACM1))										
					nTotCol14 += (nMValFis * TMPN1->N3_TXDEPR1)										
					nTotCol15 += (TMPN1->N3_VRDBAL1 - TMPN1->N3_VORIG1)										
					
					If Li > 55
					        //+--------------------
							//| TRACO RODAPE
							//+--------------------
							nLi := 0
							For nLi := 1 to limite
								@ Li, nLi  PSay cTraco1
							Next nLi	
							Li++
	        
	        
	        
				       		@ Li, aCol[1]   PSay cTraco2
							@ Li,aCol2[2]   PSay STR0079		 //"TOTAL GERAL OU A TRANSPORTAR"
				       		@ Li, aCol[5]   PSay cTraco2 
							@ Li,aCol2[5]   PSay nTotCol5 PICTURE "@E 999,999,999.99" 					
				       		@ Li, aCol[6]   PSay cTraco2
							@ Li,aCol2[6]   PSay nTotCol6 PICTURE "@E 999,999,999.99" 	
				       		@ Li, aCol[7]   PSay cTraco2
							@ Li,aCol2[7]   PSay nTotCol7 PICTURE "@E 999,999,999.99" 				
				       		@ Li, aCol[8]   PSay cTraco2
				       		@ Li, aCol[10]  PSay cTraco2
							@ Li,aCol2[10]  PSay nTotCol10 PICTURE "@E 999,999,999.99" 	
				       		@ Li, aCol[11]  PSay cTraco2
							@ Li,aCol2[11]  PSay nTotCol11 PICTURE "@E 999,999,999.99" 		        
				       		@ Li, aCol[12]  PSay cTraco2
							@ Li,aCol2[12]  PSay nTotCol12 PICTURE "@E 999,999,999.99" 		        	        
				       		@ Li, aCol[13]  PSay cTraco2
							@ Li,aCol2[13]  PSay nTotCol13 PICTURE "@E 999,999,999.99" 		        			
				       		@ Li, aCol[14]  PSay cTraco2
							@ Li,aCol2[14]  PSay nTotCol14 PICTURE "@E 999,999,999.99" 		        			
				       		@ Li, aCol[15]  PSay cTraco2
							@ Li,aCol2[15]  PSay nTotCol15 PICTURE "@E 999,999,999.99"	 	        			
				       		@ Li, aCol[16]  PSay cTraco2	        
				       		@ Li, aCol[17]  PSay cTraco2       						       		
				       		Li++
	    
						    //+--------------------
							//| TRACO RODAPE
							//+--------------------
							nLi := 0
							For nLi := 1 to limite
								@ Li, nLi  PSay cTraco1
							Next nLi	
							Li++					
					
				
					Endif
					
		
					nUtilEps := 0			
		
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
			@ Li,aCol2[2]   PSay STR0079		 //"TOTAL GERAL OU A TRANSPORTAR"
       		@ Li, aCol[5]   PSay cTraco2 
			@ Li,aCol2[5]   PSay nTotCol5  PICTURE "@E 999,999,999.99" 					
       		@ Li, aCol[6]   PSay cTraco2
			@ Li,aCol2[6]   PSay nTotCol6  PICTURE "@E 999,999,999.99" 	
       		@ Li, aCol[7]   PSay cTraco2
			@ Li,aCol2[7]   PSay nTotCol7  PICTURE "@E 99,999,999.99" 				
       		@ Li, aCol[8]   PSay cTraco2
       		@ Li, aCol[10]  PSay cTraco2
			@ Li,aCol2[10]  PSay nTotCol10 PICTURE "@E 9,999,999.99" 	
       		@ Li, aCol[11]  PSay cTraco2
			@ Li,aCol2[11]  PSay nTotCol11 PICTURE "@E 9,999,999.99" 		        
       		@ Li, aCol[12]  PSay cTraco2
			@ Li,aCol2[12]  PSay nTotCol12 PICTURE "@E 999,999.99" 		        	        
       		@ Li, aCol[13]  PSay cTraco2
			@ Li,aCol2[13]  PSay nTotCol13 PICTURE "@E 999,999.99" 		        			
       		@ Li, aCol[14]  PSay cTraco2
			@ Li,aCol2[14]  PSay nTotCol14 PICTURE "@E 999,999.99" 		        			
       		@ Li, aCol[15]  PSay cTraco2
			@ Li,aCol2[15]  PSay nTotCol15 PICTURE "@E 999,999.99"	 	        			
       		@ Li, aCol[16]  PSay cTraco2	        
       		@ Li, aCol[17]  PSay cTraco2       		
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
|CODIGO DE ACORDO |          DESCRICAO           |    ANO     |         VALORES DO ACTIVO IMOBILIZADO         |               |   REINTEGRACOES ACTUALIZADAS  |   ACTIVO  |              |           | REINTEGRACOES |TAXAS|
|COM A TABELA ANE |                              |AQUIS|INICIO| DE AQUISICAO  |DEC-LEI 430/78 |               |NUMERO DE ANOS |    DO EXERCICIO   |           |IMOBILIZADO| MAIS-VALIAS  |  REINTE-  | SOBRE O VALOR |PERDI|
|XA AO DEC. REG.  |                              | CAO |UTILI-| PRODUCAO OU   |DEC-LEI 24/82  |               | DE UTILIDADE  |TAXAS|   VALORES   |ACUMULADAS | (VALORES  |     NAO      |  GRACOES  |  DE AQUISICAO | DAS |
|N 2/90 DE 12/01  |                              |     |ZACAO |   OUTROS      |DEC-LEI 219/82 |               |   ESPERADA    |     |             |           | LIQUIDOS) |  TRIBUTADAS  |    NAO    |NAO REINTEGRADO|     |
|                 |                              |     |      |   VALORES     |DEC-LEI 143/84 |               |               |     |             |           |           |              |  ACEITES  |               |     |
|                 |                              |     |      |CONTABILISTICOS|DEC-LEI 399G/84|               |               |     |             |           |           |              |           |               |     |
|                 |                              |     |      |LEI N 126/77 OU|DEC-LEI 278/85 |DEC-LEI N 31/98|               |     |             |           |           |              |           |               |     |
|                 |                              |     |      | PORT. N 20258 |DEC-LEI 118B/86|               |               |     |             |           |           |              |           |               |     |
|                 |                              |     |      |               |DEC-LEI 111/88 |               |               |     |             |           |           |              |           |               |     |
|                 |                              |     |      |               |DEC-LEI 49/91  |               |               |     |             |           |           |              |           |               |     |
|                 |                              |     |      |               |DEC-LEI 264/92 |               |               |     |             |           |           |              |           |               |     |
*/
                                                                                   