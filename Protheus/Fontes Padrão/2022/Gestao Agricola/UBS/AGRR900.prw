#Include 'Protheus.ch'
#Include 'AGRR900.ch'

/*
############################################################################
# Função   : AGRR900                                                       #
# Descrição: Relatório das Ordens de Carregamento                          #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 16/07/2015                                                    #  
############################################################################
*/
Function AGRR900()

	Local cDesc1 := STR0001
	Local cDesc2 := STR0002
	Local cDesc3 := STR0003
	Local cPerg  := AGRGRUPSX1("AGRR900")	
	Private nLi		 := 80
	Private limite   := 189
	Private tamanho  := "G"
	Private nomeprog := 'AGRR900'
	Private nTipo    := 18
	Private aReturn  := {STR0017,1,STR0018,1,2,1,"",1}
	Private nLastKey := 0
	Private m_pag    := 1
	Private wnrel    := "AGRR900"
	Private cString	 := "NPG"
	Private titulo   := cDesc3
	Private Cabec1   := " "+STR0019
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
	RptStatus({|| AGRRPROC900(Cabec1,Cabec2,Titulo)},Titulo)
Return()

/*
############################################################################
# Função   : AGRRPROC900                                                   #
# Descrição: Processo e imprime o relatório das Ordens de Carregamento     #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 16/07/2015                                                    #  
############################################################################
*/
Static Function AGRRPROC900(Cabec1,Cabec2,Titulo)
	Local aArea   := GetArea(),vVetOrdem := {}
	Local cUnid01 := MV_PAR07
	Local cUnid02 := MV_PAR08
	Local nY  := 0
	Local nTotG1,nTotG2,nTotO1,nTotO2,nTotC1,nTotC2
	
	Private cAlias1 := GetNextAlias()     // Retorna o próximo Alias disponível
	Private cAlias2 := GetNextAlias()     // Retorna o próximo Alias disponível

	Store 0 To nTotG1,nTotG2
	
	If !AGRLISTAOK("SA1",MV_PAR03)
		Return
	EndIf

/*              1         2         3         4         5         6         7         8         9         0         1         2         3        4         5        6         7        8         9
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
 Ordem     Data           Contr.    Nome do Cliente                   Inscrição             Descrição do Poduto                         Lote               Localização         Quantidade      Un.    Cat.   Pen.
 XXXXXX    XX/XX/XXXX	  XXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXX    XXXXXXXXXXXXXXX     9.999.999,99    XXX    XX     XX                                                                             
 123456                   123456	123456789012345678901234567890    123456789012345678    1234567890123456789012345678901234567890    123456789012345    123456789012345
                                                                                                                                          
                                                                                                                       99,999,999,999.99    XXX			   99,999,999,999.99    XXX
*/

	If MV_PAR05 = 1
		cTFrete := "C" //CIF 
	ElseIf MV_PAR05 = 2
		cTFrete := "F" //FOB   
	ElseIf MV_PAR05 = 3
		cTFrete := "T" //Por Conta Terc. 
	ElseIf MV_PAR05 = 4
		cTFrete := "S" //Sem Frete
	EndIf
	
	aSeparaC := {}
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

	aSeparaT := {}
 	//***CULTIVARES a serem listados
	nY 		 := 0
	cCultiv := ""
	If !Empty(MV_PAR04)
		aSeparaT := Separa(MV_PAR04,';')
		For nY := 1 To Len(aSeparaT)
			If Len(aSeparaT) = 1
				cCultiv += "'"+Alltrim(aSeparaT[nY])+"'"
			ElseIf nY = Len(aSeparaT)
				cCultiv += "'"+Alltrim(aSeparaT[nY])+"'"
			Else
				cCultiv += "'"+Alltrim(aSeparaT[nY])+"',"
			EndIf
		Next nY
		cCultiv := Strtran(cCultiv,'"','')	
	EndIf
	
	aSeparaV := {}
 	//***VENDEDORES a serem listados
	nY 		  := 0
	cVendedor := ""
	If !Empty(MV_PAR06)
		aSeparaV := Separa(MV_PAR06,';')
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
	cQuery := ChangeQuery(cQuery)
	//-- VERIFICA SE EXISTE - SE SIM APAGA TABELA TEMP
	If Select(cAlias1) <> 0
		(cAlias1)->(dbCloseArea())
	EndIf
	//-- DEFINE UM ARQUIVO DE DADOS COMO UMA AREA DE TRABALHO DISPONIVEL NA APLICACAO
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias1,.T.,.T.)

	While (cAlias1)->(!Eof()) .And. (cAlias1)->NPG_FILIAL = xFilial("NPG")	
		
		If NPG->NPG_STATUS <> "3" 

			cQuery2 := " SELECT DISTINCT NPH.NPH_FILIAL, NPH.NPH_CODAC, NPH.NPH_NUMCP, NPH.NPH_CATEG, NPH.NPH_ORDEMC, NPH.NPH_CODPRO, NPH.NPH_ITEM, NPH.NPH_PENE, ADA.ADA_TPFRET "
			cQuery2 +=   " FROM "+ RetSqlName("NPH") + " NPH "
			cQuery2 +=   " LEFT JOIN "+ RetSqlName("ADA") + " ADA ON ADA.ADA_FILIAL = '" + xFilial( 'ADA' ) + "'"   
			cQuery2 +=                                         " AND ADA.D_E_L_E_T_ = '' " 
			cQuery2 +=                                         " AND ADA.ADA_NUMCTR = NPH.NPH_NUMCP "
			If !Empty(MV_PAR06) 	//Vendedor
				cQuery2 += " AND ADA.ADA_VEND1   IN (" + cVendedor + ")"	
			EndIf			
			cQuery2 +=  " WHERE NPH.NPH_FILIAL  = '" + xFilial( 'NPH' ) + "'"  
			cQuery2 +=    " AND NPH.D_E_L_E_T_ = '' " 
			cQuery2 +=    " AND NPH.NPH_CODAC  = '" + (cAlias1)->NPG_CODIGO + "'"
			If !Empty(MV_PAR04) 	//Variedade/Cultivares
				cQuery2 += " AND NPH.NPH_CTVAR   IN (" + cCultiv + ")"	
			EndIf
			cQuery2 := ChangeQuery(cQuery2)
			//-- VERIFICA SE EXISTE - SE SIM APAGA TABELA TEMP
			If Select(cAlias2) <> 0
				(cAlias2)->(dbCloseArea())
			EndIf
			//-- DEFINE UM ARQUIVO DE DADOS COMO UMA AREA DE TRABALHO DISPONIVEL NA APLICACAO
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery2),cAlias2,.T.,.T.)
			dbgotop()
			
			If !Empty((cAlias2)->NPH_NUMCP)
				If (cAlias2)->ADA_TPFRET = cTFrete 	
						Store 0 To nTotC1,nTotC2
						Store 0 To nTotO1,nTotO2
						While !Eof() .And. (cAlias2)->NPH_FILIAL = xFilial("NPH") .And. (cAlias2)->NPH_CODAC = (cAlias1)->NPG_CODIGO
							lPrimC := .f.
							If !Empty((cAlias2)->NPH_ORDEMC) .And. AGRIFDBSEEK("NPM",(cAlias2)->NPH_ORDEMC+(cAlias2)->NPH_CODAC,1,.f.) .And. NPM->NPM_STATUS <> "5" .And. AGRIFDBSEEK("NPN",(cAlias2)->NPH_ORDEMC,1,.f.)
								If Ascan(vVetOrdem,{|x| x = (cAlias2)->NPH_ORDEMC}) = 0
									Aadd(vVetOrdem,(cAlias2)->NPH_ORDEMC)
									While !Eof() .And. NPN->NPN_FILIAL = Xfilial("NPN") .And. NPN->NPN_ORDEMC = (cAlias2)->NPH_ORDEMC 
										If !Empty(NPN->NPN_QUANT)
											AGRSOMALINHA()
											If !lPrimC
												AGRIFDBSEEK("SA1",NPG->NPG_CLIORI,1,.f.)
												@nLi,000 PSay NPN->NPN_ORDEMC       		Picture "@!"
												@nLi,010 Psay NPM->NPM_DATA 				Picture "99/99/9999"
												@nLi,026 PSay (cAlias2)->NPH_NUMCP  		Picture "@!"
												@nLi,036 PSay SubStr(SA1->A1_NOME,1,30)
												@nLi,070 PSay SA1->A1_INSCR         		Picture "@!"
												lPrimC := .T.
											EndIf

											AGRIFDBSEEK("SB1",NPN->NPN_CODPRO,1,.f.)
											@nLi,092 PSay SubStr(SB1->B1_DESC,1,27)
											@nLi,136 PSay NPN->NPN_LOTE         			Picture "@!"
											@nLi,155 PSay NPN->NPN_LOCALI       			Picture "@!"
											@nLi,175 PSay Transform(NPN->NPN_QUANT,'@E 99,999,999.99')
											@nLi,191 PSay SB1->B1_UM            			Picture "@!"
											@nLi,198 PSay (cAlias2)->NPH_CATEG 				Picture "@!"
											@nLi,205 PSay (cAlias2)->NPH_PENE      			Picture "@!"
									
										    //TOTAL 1
											If cUnid01 = SB1->B1_UM	
												nTotO1 += NPN->NPN_QUANT
											Else
												If AGRIFDBSEEK("NNX",SB1->B1_UM+cUnid01,1,.F.)
										    		nTotO1 += AGRX001(SB1->B1_UM,cUnid01,NPN->NPN_QUANT, SB1->B1_COD)
												Else 	 
													AGRHELPNC(STR0023+ Alltrim(SB1->B1_UM) + "/" + Alltrim(cUnid01) +STR0024,STR0025) //"A unidade de medida origem "###" não está cadastrada!"###"É necessário cadastrar o fator de conversão para esta unidade de medida."
													Return
												EndIf 								
											EndIf 	
											
											//TOTAL 2
	 										If cUnid02 = SB1->B1_UM	
												nTotO2 += NPN->NPN_QUANT
											Else
												If AGRIFDBSEEK("NNX",SB1->B1_UM+cUnid02,1,.F.)
										    		nTotO2 += AGRX001(SB1->B1_UM,cUnid02,NPN->NPN_QUANT, SB1->B1_COD)
												Else 	 
													AGRHELPNC(STR0023+ Alltrim(SB1->B1_UM) + "/" + Alltrim(cUnid02) +STR0024,STR0025) //"A unidade de medida origem "###" não está cadastrada!"###"É necessário cadastrar o fator de conversão para esta unidade de medida."
													Return
												EndIf 								
											EndIf 	
																	
										EndIf
										NPN->(dbSkip())
									EndDo
								EndIf
							EndIf
								
							If !Empty(nTotO1)
								If !Empty(MV_PAR07) .Or. !Empty(MV_PAR08)
									AGRSOMALINHA()
									AGRSOMALINHA()
									@nLi,001 PSay STR0020+" "+vVetOrdem[Len(vVetOrdem)]
									If !Empty(MV_PAR07)
										@nLi,119 PSay Transform(nTotO1,'@E 99,999,999,999.99')
										@nLi,140 PSay MV_PAR07 Picture "@!"
									EndIf
									If !Empty(MV_PAR08)
										@nLi,155 PSay Transform(nTotO2,'@E 99,999,999,999.99')
										@nLi,176 PSay MV_PAR08 Picture "@!"
									EndIf
								EndIf
								nTotC1 += nTotO1
								nTotC2 += nTotO2
							EndIf
							nTotO1 := 0
							AGRDBSELSKIP(cAlias2)
						EndDo
						
						/*If !Empty(nTotC1)
							If !Empty(MV_PAR07) .Or. !Empty(MV_PAR08)
								AGRSOMALINHA()
								@nLi,001 PSay STR0021
								If !Empty(MV_PAR07)
									@nLi,119 PSay Transform(nTotC1,'@E 99,999,999,999.99')
									@nLi,140 PSay MV_PAR07 Picture "@!"
								EndIf
								If !Empty(MV_PAR08)
									@nLi,155 PSay Transform(nTotC2,'@E 99,999,999,999.99')
									@nLi,176 PSay MV_PAR08 Picture "@!"
								EndIf
								AGRSOMALINHA()
							EndIf
							nTotG1 += nTotC1
							nTotG2 += nTotC2
							//Store 0 To nTotG1,nTotG2
						EndIf
						*/
					EndIf
				EndIf
			EndIf
		(cAlias1)->(dbSkip())  
		
	EndDo
	If !Empty(nTotG1)
		If !Empty(MV_PAR07) .Or. !Empty(MV_PAR08)
			AGRSOMALINHA()
			@nLi,001 PSay STR0022
			If !Empty(MV_PAR07)
				@nLi,119 PSay Transform(nTotG1,'@E 99,999,999,999.99')
				@nLi,140 PSay MV_PAR07 Picture "@!"
			EndIf
			If !Empty(MV_PAR08)
				@nLi,155 PSay Transform(nTotG2,'@E 99,999,999,999.99')
				@nLi,176 PSay MV_PAR08 Picture "@!"
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