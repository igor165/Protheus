#Include 'Protheus.ch'
#Include 'AGRR890.ch'

/*
############################################################################
# Função   : AGRR890                                                       #
# Descrição: Relatório das Autorização de Carregamento                     #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 16/07/2015                                                    #  
############################################################################
*/
Function AGRR890()
	Local cDesc1 := STR0001
	Local cDesc2 := STR0002
	Local cDesc3 := STR0003
	Local cPerg  := AGRGRUPSX1("AGRR890")	
	Private m_pag    := 1
	Private nLi      := 80
	Private limite   := 230
	Private tamanho  := "G"
	Private nomeprog := 'AGRR890'
	Private nTipo    := 18
	Private aReturn  := {STR0021,1,STR0022,1,2,1,"",1}
	Private nLastKey := 0
	Private wnrel    := "AGRR890"
	Private cString	 := "NPG"
	Private titulo   := cDesc3
	Private Cabec1   := STR0023
					 /* "Código   Data            Contrato      Nome do Cliente                     Inscrição               Motorista                           Produto                             Cat.   Pen.	    Quantidade             Un."
	                     XXXXXX   XX/XX/XXXX      XXXXXX        XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX      XXXXXXXXXXXXXXXXXX	    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX	    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX	    XX     XXXX	    99,999,999,999.99      XX */
	Private Cabec2   := ""
	
	Pergunte(cPerg,.f.)

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,Tamanho,,.t.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return
	Endif
	nTipo := If(aReturn[4]==1,15,18)
	RptStatus({|| AGRRPROC890(Cabec1,Cabec2,Titulo)},Titulo)
	
Return()

/*
############################################################################
# Função   : AGRRPROC890                                                   #
# Descrição: Processo e imprime o relatório das Ordens de Carregamento     #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 16/07/2015                                                    #  
############################################################################
*/
Static Function AGRRPROC890(Cabec1,Cabec2,Titulo)
	Local aArea 	:= GetArea()
	Local aMatProd 	:= {}
	Local aSeparaC, aSeparaM, aSeparaP, aSeparaT, aSeparaV	:= {}
	Local cUnid01 	:= MV_PAR09
	Local cUnid02 	:= MV_PAR10
	Local nTotG1,nTotG2,nTotC1,nTotC2
	Local nY		:= 0
	
	Private cAlias1 := GetNextAlias()     // Retorna o próximo Alias disponível
	Private cAlias2 := GetNextAlias()     // Retorna o próximo Alias disponível

	Store 0 To nTotG1,nTotG2

	If !AGRLISTAOK("SA1",MV_PAR03)
		Return
	EndIf

/*              1         2         3         4         5         6         7         8         9         0         1         2         3        4         5        6         7        8        9           0
012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
"Código   Data            Contrato    Nome do Cliente                     Inscrição                 Motorista                         Produto                              Cat.   Pen.	  Quantidade             Un."
 XXXXXX	  XX/XX/XXXX	  XXXXXX	  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX	  XXXXXXXXXXXXXXXXXX	    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX	  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX       XX	  XXXX	  99,999,999,999.99	  	 XX      
*/

	If MV_PAR06 = 1
		cTFrete := "C" //CIF 
	ElseIf MV_PAR06 = 2
		cTFrete := "F" //FOB   
	ElseIf MV_PAR06 = 3
		cTFrete := "T" //Por Conta Terc. 
	ElseIf MV_PAR06 = 4
		cTFrete := "S" //Sem Frete
	EndIf
	
	//***CLIENTES a serem listados
	cClientes := ""	
	If !Empty(MV_PAR03)
		aSeparaC := Separa(MV_PAR03,';')
		For nY := 1 To Len(aSeparaC)
			If Len(aSeparaC) = 1
				cClientes += "'"+Alltrim(aSeparaC[nY])+"'"
			ElseIf nY = Len(aSeparaC)
				cClientes += "'"+Alltrim(aSeparaC[nY])+"'"
			Else
				cClientes += "'"+Alltrim(aSeparaC[nY])+"',"
			EndIf
		Next nY
		cClientes := Strtran(cClientes,'"','')	
	EndIf
	
	//***MOTORISTAS a serem listados
	nY 		 := 0
	cMotoris := ""
	If !Empty(MV_PAR04)
		aSeparaM := Separa(MV_PAR04,';')
		For nY := 1 To Len(aSeparaM)
			If Len(aSeparaM) = 1
				cMotoris += "'"+Alltrim(aSeparaM[nY])+"'"
			ElseIf nY = Len(aSeparaC)
				cMotoris += "'"+Alltrim(aSeparaM[nY])+"'"
			Else
				cMotoris += "'"+Alltrim(aSeparaM[nY])+"',"
			EndIf
		Next nY
		cMotoris := Strtran(cMotoris,'"','')	
	EndIf
 	
 	//***PLACAS a serem listados
	nY 		 := 0
	cPlacas := ""
	If !Empty(MV_PAR05)
		aSeparaP := Separa(MV_PAR05,';')
		For nY := 1 To Len(aSeparaP)
			If Len(aSeparaP) = 1
				cPlacas += "'"+Alltrim(aSeparaP[nY])+"'"
			ElseIf nY = Len(aSeparaC)
				cPlacas += "'"+Alltrim(aSeparaP[nY])+"'"
			Else
				cPlacas += "'"+Alltrim(aSeparaP[nY])+"',"
			EndIf
		Next nY
		cPlacas := Strtran(cPlacas,'"','')	
	EndIf	

 	//***CULTIVARES a serem listados
	nY 		 := 0
	cCultiv := ""
	If !Empty(MV_PAR07)
		aSeparaT := Separa(MV_PAR07,';')
		For nY := 1 To Len(aSeparaT)
			If Len(aSeparaT) = 1
				cCultiv += "'"+Alltrim(aSeparaT[nY])+"'"
			ElseIf nY = Len(aSeparaC)
				cCultiv += "'"+Alltrim(aSeparaT[nY])+"'"
			Else
				cCultiv += "'"+Alltrim(aSeparaT[nY])+"',"
			EndIf
		Next nY
		cCultiv := Strtran(cCultiv,'"','')	
	EndIf

 	//***VENDEDORES a serem listados
	nY 		  := 0
	cVendedor := ""
	If !Empty(MV_PAR08)
		aSeparaV := Separa(MV_PAR08,';')
		For nY := 1 To Len(aSeparaV)
			If Len(aSeparaV) = 1
				cVendedor += "'"+Alltrim(aSeparaV[nY])+"'"
			ElseIf nY = Len(aSeparaC)
				cVendedor += "'"+Alltrim(aSeparaV[nY])+"'"
			Else
				cVendedor += "'"+Alltrim(aSeparaV[nY])+"',"
			EndIf
		Next nY
		cVendedor := Strtran(cVendedor,'"','')	
	EndIf

	cQuery := " SELECT NPG.*
	cQuery +=   " FROM "+ RetSqlName("NPG") + " NPG "	
	cQuery += "  WHERE NPG.NPG_FILIAL 	= '" + xFilial( 'NPG' ) + "'"	 
	cQuery +=    " AND NPG.D_E_L_E_T_ 	= '' "	 
	cQuery +=    " AND NPG.NPG_DTAUTO 	>= '" + Dtos(MV_PAR01) + "'"
	cQuery +=    " AND NPG.NPG_DTAUTO 	<= '" + Dtos(MV_PAR02) + "'"
	If !Empty(MV_PAR03) 	//Clientes
		cQuery +=    " AND NPG.NPG_CLIORI  	IN (" + cClientes + ")"
	EndIf
	If !Empty(MV_PAR04)		//Motorista
		cQuery +=    " AND NPG.NPG_MOTO		IN (" + cMotoris + ")"
	EndIf
	If !Empty(MV_PAR05)		//Placa
		cQuery +=    " AND NPG.NPG_PLACA 	IN (" + cPlacas	+ ")"
	EndIf
	cQuery += " ORDER BY NPG_CODIGO"
	cQuery := ChangeQuery(cQuery)
	//-- VERIFICA SE EXISTE - SE SIM APAGA TABELA TEMP
	If Select(cAlias1) <> 0
		(cAlias1)->(dbCloseArea())
	EndIf
	//-- DEFINE UM ARQUIVO DE DADOS COMO UMA AREA DE TRABALHO DISPONIVEL NA APLICACAO
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias1,.T.,.T.)
	
	Store 0 To nTotC1,nTotC2	
	While (cAlias1)->(!Eof()) .And. (cAlias1)->NPG_FILIAL = xFilial("NPG")
		lPrimC 	 := .f. 
		aMatProd := {}
		
		Store 0 To nTotC1,nTotC2
		
		If (cAlias1)->NPG_STATUS <> "3" 
			
			cQuery2 := " SELECT DISTINCT NPH.NPH_FILIAL, NPH.NPH_CODPRO, NPH.NPH_CODAC, NPH.NPH_NUMCP, NPH.NPH_CATEG, NPH.NPH_PENE, NPH.NPH_QUANT, ADA.ADA_TPFRET "
			cQuery2 +=   " FROM "+ RetSqlName("NPH") + " NPH "
			cQuery2 +=   " LEFT JOIN "+ RetSqlName("ADA") + " ADA ON ADA.ADA_FILIAL = '" + xFilial( 'ADA' ) + "'"   
			cQuery2 +=                                         " AND ADA.D_E_L_E_T_ = '' " 
			//cQuery2 +=                                         " AND ADA.ADA_TPFRET = '" + cTFrete + "'"
			cQuery2 +=                                         " AND ADA.ADA_NUMCTR = NPH.NPH_NUMCP "
			If !Empty(MV_PAR07) 	//Variedade/Cultivares
				cQuery2 += " AND ADA.ADA_VEND1  = IN (" + cVendedor + ")"	
			EndIf			
			cQuery2 +=  " WHERE NPH.NPH_FILIAL  = '" + xFilial( 'NPH' ) + "'"  
			cQuery2 +=    " AND NPH.D_E_L_E_T_ = '' " 
			cQuery2 +=    " AND NPH.NPH_CODAC  = '" + (cAlias1)->NPG_CODIGO + "'"
			If !Empty(MV_PAR07) 	//Variedade/Cultivares
				cQuery2 += " AND NPH.NPH_CTVAR  = IN (" + cCultiv + ")"	
			EndIf			
			cQuery2 := ChangeQuery(cQuery2)
			//-- VERIFICA SE EXISTE - SE SIM APAGA TABELA TEMP
			If Select(cAlias2) <> 0
				(cAlias2)->(dbCloseArea())
			EndIf
			//-- DEFINE UM ARQUIVO DE DADOS COMO UMA AREA DE TRABALHO DISPONIVEL NA APLICACAO
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery2),cAlias2,.T.,.T.)		
			
			If !Empty((cAlias2)->NPH_NUMCP)
				cNuMCP := (cAlias2)->NPH_NUMCP
				If (cAlias2)->ADA_TPFRET = cTFrete 
					While !Eof() .And. (cAlias2)->NPH_FILIAL = xFilial("NPH") .And. (cAlias2)->NPH_CODAC = (cAlias1)->NPG_CODIGO
						If !Empty((cAlias2)->NPH_QUANT)					
							AGRSOMALINHA()
							If !lPrimC
								AGRIFDBSEEK("SA1",(cAlias1)->NPG_CLIORI,1,.f.)
								@nLi,000 PSay (cAlias1)->NPG_CODIGO 			Picture "@!"
								@nLi,009 PSay STOD((cAlias1)->NPG_DTAUTO) 	 	Picture "99/99/9999"
								@nLi,025 PSay cNuMCP							Picture "@!"
								@nLi,039 PSay SubStr(SA1->A1_NOME,1,30)
								@nLi,075 PSay SA1->A1_INSCR  					Picture "@!"
								AGRIFDBSEEK("DA4",(cAlias1)->NPG_MOTO,1,.f.)
								@nLi,099 PSay SubStr(DA4->DA4_NOME,1,30)
							EndIf
							
							AGRIFDBSEEK("SB1",(cAlias2)->NPH_CODPRO,1,.f.)
							@nLi,135 PSay SubStr(SB1->B1_DESC,1,30)
							@nLi,171 PSay (cAlias2)->NPH_CATEG					Picture "@!"
							@nLi,178 PSay (cAlias2)->NPH_PENE 					Picture "@!"
							@nLi,186 PSay Transform((cAlias2)->NPH_QUANT,'@E 99,999,999.99')
							@nLi,209 PSay SB1->B1_UM							Picture "@!"
	
						 	//TOTAL 1
							If cUnid01 = SB1->B1_UM	
								nTotC1 += (cAlias2)->NPH_QUANT
							Else
								If AGRIFDBSEEK("NNX",SB1->B1_UM+cUnid01,1,.F.)
									nTotC1 += AGRX001(SB1->B1_UM,cUnid01,(cAlias2)->NPH_QUANT, SB1->B1_COD)
								Else 	 
									AGRHELPNC(STR0030+ Alltrim(SB1->B1_UM) + "/" + Alltrim(cUnid01) +STR0031,STR0032) //"A unidade de medida origem "###" não está cadastrada!"###"É necessário cadastrar o fator de conversão para esta unidade de medida."
									Return
								EndIf 								
							EndIf 	
											
							//TOTAL 2
	 						If cUnid02 = SB1->B1_UM	
								nTotC2 += (cAlias2)->NPH_QUANT
							Else
								If AGRIFDBSEEK("NNX",SB1->B1_UM+cUnid02,1,.F.)
							   		nTotC2 += AGRX001(SB1->B1_UM,cUnid02,(cAlias2)->NPH_QUANT, SB1->B1_COD)
								Else 	 
									AGRHELPNC(STR0030+ Alltrim(SB1->B1_UM) + "/" + Alltrim(cUnid02) +STR0031,STR0032) //"A unidade de medida origem "###" não está cadastrada!"###"É necessário cadastrar o fator de conversão para esta unidade de medida."
									Return
								EndIf 								
							EndIf
						Endif
						
						(cAlias2)->(dbSkip())
					EndDo
						
						AGRSOMALINHA()
						AGRSOMALINHA()
						If !Empty(MV_PAR09) .Or. !Empty(MV_PAR10)
							@nLi,004 PSay "Total da Autorização"+" "+(cAlias1)->NPG_CODIGO
							If !Empty(MV_PAR09)
								@nLi,119 PSay Transform(nTotC1,'@E 99,999,999,999.99')
								@nLi,140 PSay MV_PAR09 Picture "@!"
							EndIf
							If !Empty(MV_PAR10)
								@nLi,155 PSay Transform(nTotC2,'@E 99,999,999,999.99')
								@nLi,176 PSay MV_PAR10 Picture "@!"
							EndIf
							AGRSOMALINHA()
						EndIf
						nTotG1 += nTotC1
						nTotG2 += nTotC2
				Endif
			EndIf
		Endif
		(cAlias1)->(dbSkip())
	End
	If !Empty(nTotG1)
		If !Empty(MV_PAR09) .Or. !Empty(MV_PAR10)
			AGRSOMALINHA()
			@nLi,004 PSay "Total Geral"
			If !Empty(MV_PAR09)
				@nLi,119 PSay Transform(nTotG1,'@E 99,999,999,999.99')
				@nLi,140 PSay MV_PAR09 Picture "@!"
			EndIf
			If !Empty(MV_PAR10)
				@nLi,155 PSay Transform(nTotG2,'@E 99,999,999,999.99')
				@nLi,176 PSay MV_PAR10 Picture "@!"
			EndIf
		EndIf
	EndIf
	RestArea(aArea)

	SET DEVICE TO SCREEN
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	MS_FLUSH()
Return