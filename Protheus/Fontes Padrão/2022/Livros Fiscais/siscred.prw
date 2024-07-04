#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSisCred   บAutor  ณMary C. Hergert     บ Data ณ 06/01/06    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera o arquivo temporario para processamento do SISCRED -   บฑฑ
ฑฑบ          ณSistema de Controle da Transferencia e Utilizacao de        บฑฑ
ฑฑบ          ณCreditos Acumulados - Parana                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFis                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SisCred(dDtInicial,dDtFinal,aWizard)                     

	Local aTRB	:= SisCredTMP()
	
	SisCredEx(dDtInicial,dDtFinal,aWizard)

Return aTRB

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSisCredEx   บAutor  ณMary C. Hergert     บ Data ณ 06/01/06    บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa os movimentos das filiais / periodo                  บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSisCred                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SisCredEx(dDtInicial,dDtFinal,aWizard)

	Local aAreaSM0	:= SM0->(GetArea())
	
	Local cProcFil	:= Alltrim(aWizard[01][01])
	Local cFilIni	:= Alltrim(aWizard[01][02])
	Local cFilFim	:= Alltrim(aWizard[01][03])
	Local cAliasSD2	:= "SD2"    
	Local cAliasSB1	:= "SB1"    
	Local cAliasSF4	:= "SF4"
	Local cCNPJ 	:= ""
	Local cIE	  	:= ""
	Local cCPF		:= ""
	Local cTipo		:= ""
	Local cChave	:= ""
	Local cMVSISDESP:= GetNewPar("MV_SISDESP","")
	Local cMVSISMEMO:= GetNewPar("MV_SISMEMO","")
	Local cMVSISCAD := GetNewPar("MV_SISCAD","")
	Local cMVSISCFED:= GetNewPar("MV_SISCFED","")
	Local cDespacho	:= ""
	Local cMemorando:= ""
	Local cNome		:= ""
	Local cMunic	:= ""
	Local cUF		:= ""
	Local cCADICMS 	:= ""

	Local lQuery	:= .F. 
	Local lMVEECFAT	:= GetNewPar("MV_EECFAT",.F.)	
	
	Local nValDif	:= 0
	Local nPosiCad 	:= 0           
	Local nItem	:= 0
	
	#IFDEF TOP
		Local aStruSD2	:= {}                                       
		Local aCamposSD2:= {}		            
		Local cCmpQry	:= ""
		Local nX		:= 0     
	#ELSE
		Local lProc		:= .T.
	#ENDIF
            
	// Quando nao for processamento de mais de uma filial
	If cProcFil <> "1" 
		cFilIni	:= cFilAnt
		cFilFim	:= cFilAnt
	Endif
	
	// Tabelas que serao processadas
	dbSelectArea("SA1")
	dbSelectArea("SA2")
	dbSelectArea("SB1")
	dbSelectArea("SF4")
	dbSelectArea("SF2")	
	
	SM0->(dbSeek(cEmpAnt+cFilIni,.T.))
	
	Do While !SM0->(Eof()) .And. SM0->M0_CODIGO + SM0->M0_CODFIL <= cEmpAnt + cFilFim

		cFilAnt := SM0->M0_CODFIL
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerificando o CAD/ICMS do contribuinteณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !Empty(cMVSISCAD)     
			nPosiCad := At(SM0->M0_CODIGO + "-" + SM0->M0_CODFIL + "-",cMVSISCAD) + 6
			cCADICMS := SubStr(cMVSISCAD,nPosiCad,10)
		Else
			cCADICMS := ""
		Endif
			
		dbSelectArea("SD2")
		dbSetOrder(3)		

		#IFDEF TOP                   
		
		    If TcSrvType()<>"AS/400"    
		    
		    //Seto as variaveis abaixo para nใo gerar error.log quando houver mais de uma Filial, FNC 00000027925/2014	  
			aStruSD2	:= {}                                       
			aCamposSD2  := {}		            
			cCmpQry   	:= ""
		    
	    	aAdd(aCamposSD2,{"D2_FILIAL","SD2"})
	   	    aAdd(aCamposSD2,{"D2_DOC","SD2"})
	   	    aAdd(aCamposSD2,{"D2_SERIE","SD2"})
	   	    If SerieNfId('SD2',3,'D2_SERIE') <> 'D2_SERIE'
	   	    	aAdd(aCamposSD2,{SerieNfId('SD2',3,'D2_SERIE'),"SD2"})
	   	    EndIf
	   	    aAdd(aCamposSD2,{"D2_CLIENTE","SD2"})
	   	    aAdd(aCamposSD2,{"D2_LOJA","SD2"})
	   	    aAdd(aCamposSD2,{"D2_COD","SD2"})
	   	    aAdd(aCamposSD2,{"D2_ITEM","SD2"})
	   	    aAdd(aCamposSD2,{"D2_EMISSAO","SD2"})
	   	    aAdd(aCamposSD2,{"D2_TES","SD2"})
	   	    aAdd(aCamposSD2,{"D2_TIPO","SD2"})
	   	    aAdd(aCamposSD2,{"D2_CF","SD2"})
	   	    aAdd(aCamposSD2,{"D2_PREEMB","SD2"})
	   	    aAdd(aCamposSD2,{"D2_TOTAL","SD2"})
	   	    aAdd(aCamposSD2,{"D2_BASEICM","SD2"})
	   	    aAdd(aCamposSD2,{"D2_CLASFIS","SD2"})
				 If !Empty(cMVSISDESP) .And. SD2->(FieldPos(cMVSISDESP)) > 0
					 aAdd(aCamposSD2,{cMVSISDESP,"SD2"})
				 Endif
				 If !Empty(cMVSISMEMO) .And. SD2->(FieldPos(cMVSISMEMO)) > 0
					 aAdd(aCamposSD2,{cMVSISMEMO,"SD2"})
				 Endif
		   	 aAdd(aCamposSD2,{"B1_POSIPI","SB1"})
		   	 aAdd(aCamposSD2,{"B1_DESC","SB1"})
		   	 aAdd(aCamposSD2,{"F4_ICMSDIF","SF4"})
		   	 aAdd(aCamposSD2,{"F4_BASEICM","SF4"})
		   	    
		   	 aStruSD2  := SD2->(SisCredStr(aCamposSD2,@cCmpQry))
				 cAliasSD2 := "SD2_SISCRED"                 
				 cAliasSB1 := "SD2_SISCRED"                 
				 cAliasSF4 := "SD2_SISCRED"                 
				 lQuery    := .T.		
	
				cQuery    := "SELECT "
				cQuery    += cCmpQry
				cQuery    += "FROM " + RetSqlName("SD2") + " SD2, "
				cQuery    += RetSqlName("SB1") + " SB1, "
				cQuery    += RetSqlName("SF4") + " SF4  "
				cQuery    += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
				cQuery    += "SD2.D2_EMISSAO >= '"+DTOS(dDtInicial)+"' AND "
				cQuery    += "SD2.D2_EMISSAO <= '"+DTOS(dDtFinal)+"' AND "
				cQuery    += "SD2.D_E_L_E_T_=' ' AND "
				cQuery    += "SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND "
				cQuery    += "SB1.B1_COD = SD2.D2_COD AND "                 
				cQuery    += "SB1.D_E_L_E_T_ <> '*' AND "
				cQuery    += "SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND "				
				cQuery    += "SF4.F4_CODIGO = SD2.D2_TES AND SF4.D_E_L_E_T_ <> '*'"
				cQuery    += "ORDER BY "+SqlOrder(SD2->(IndexKey()))
				
				cQuery    := ChangeQuery(cQuery)
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
				
				For nX := 1 To Len(aStruSD2)
					If ( aStruSD2[nX][2] <> "C" )
						TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
					EndIf
				Next nX
	
				dbSelectArea(cAliasSD2)	
			Else
	
		#ENDIF
			SD2->(dbSeek(xFilial("SD2")+Dtos(dDtInicial),.T.))
		#IFDEF TOP
			Endif    
		#ENDIF
		
		Do While !(cAliasSD2)->(Eof())

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณConforme legislacao disponivel atraves do link "http://www.sefanet.pr.gov.br/SEFADocumento/Arquivos/3200500068.pdf",ณ
			//ณ  item 8.2.3, NAO deve ser considerado NFs de Complemento de Preco.                                                 ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		    If (cAliasSD2)->D2_TIPO $ "C" .And. Left((cAliasSD2)->D2_CF,1) == '7'	//I-ICMS P-IPI C-Preco
			    (cAliasSD2)->(dbSkip())
			    Loop
		    Endif

			lProc := .T. 

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณInicializa os itens para utilizar a xMagValFis()ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If cChave <> (cAliasSD2)->D2_FILIAL+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA
				nItem 	:= 0
				cChave 	:= (cAliasSD2)->D2_FILIAL+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA
				SF2->(dbSetOrder(1))
				If !SF2->(dbSeek(xFilial("SF2")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
					lProc := .F.
				Endif
			Endif

			nItem++

			If !lQuery          

				If (cAliasSD2)->D2_EMISSAO > dDtFinal .Or. xFilial("SD2") <> (cAliasSD2)->D2_FILIAL
					Exit
				Endif
				
				// Tes
				(cAliasSF4)->(dbSetOrder(1))
				If ! (cAliasSF4)->(dbSeek(xFilial("SF4")+(cAliasSD2)->D2_TES))
					lProc := .F.
				Endif

				// Cadastro de Produtos
				(cAliasSB1)->(dbSetOrder(1))
				If ! (cAliasSB1)->(dbSeek(xFilial("SB1")+(cAliasSD2)->D2_COD))
					lProc := .F.
				Endif 
				                         
			Endif        
			
			If !lProc
				(cAliasSD2)->(dbSkip())
				Loop
			Endif		

			//verifica so o CFOP estแ contido nos cfops de exclusใo que se encontram no parโmetro MV_SISCFED
			If AllTrim((cAliasSD2)->D2_CF) $ AllTrim(cMVSISCFED)
				(cAliasSD2)->(dbSkip())
				Loop
			EndIf
							
			 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณTipo de Movimentoณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If Left((cAliasSD2)->D2_CF,1) == '7'  // Exportacao Direta
				cTipo := "1"
			ElseIf Alltrim((cAliasSD2)->D2_CF) $ "5501/5502/6501/6502" // Exportacao Indireta
				cTipo := "2"
			ElseIf (cAliasSF4)->F4_ICMSDIF $ "1/3/6" // ICMS Diferido / Dif de redu็ใo / Deduz NF e duplicata
				cTipo := "3"
			ElseIf SubStr((cAliasSD2)->D2_CLASFIS,2,2) == "50" // Suspensao
				cTipo := "4"
			ElseIf (cAliasSF4)->F4_BASEICM > 0 // Reducao na Base de Calculo
				cTipo := "5"
			Else   															// Nao faz parte de nenhuma das categorias
				(cAliasSD2)->(dbSkip())
				Loop
			Endif

			cCPF  := ""
			cCNPJ := "" 
			// Verificando Cliente/Fornecedor			
			If (cAliasSD2)->D2_TIPO $"DB"
				SA2->(dbSetOrder(1))
				SA2->(dbSeek(xFilial("SA2")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
				cNome	:= SA2->A2_NOME
				cMunic	:= SA2->A2_MUN
				cUF		:= SA2->A2_EST
				cIE	  	:= SA2->A2_INSCR
				Iif(SA2->A2_TIPO == "F" .And. cTipo == "3",cCPF := SA2->A2_CGC,cCNPJ := SA2->A2_CGC )
			Else
				SA1->(dbSetOrder(1))
				SA1->(dbSeek(xFilial("SA1")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
				cNome	:= SA1->A1_NOME
				cMunic	:= SA1->A1_MUN
				cUF		:= SA1->A1_EST
				cIE	  	:= SA1->A1_INSCR
				Iif(SA1->A1_PESSOA == "F" .And. cTipo == "3",cCPF := SA1->A1_CGC,cCNPJ := SA1->A1_CGC )
			Endif					 

			// Valor do ICMS Diferido por item
			nValDif := 0
			If cTipo == "3"    
				nValDif := xMagValFis(2,0,"SF2",nItem,"LF_ICMSDIF")
			Endif       
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณExportacao e equiparados                       ณ
			//ณCom integracao, processa as tabelas especificasณ
			//ณSem integracao, parametro                      ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			//Despacho (Exportacao e Equiparado)
			cDespacho 	:= ""
			cMemorando	:= ""
			If cTipo$"1/2" 
				If lMVEECFAT                                    
					EE9->(dbSetOrder(2))
					If EE9->(dbSeek(xFilial("EE9")+(cAliasSD2)->D2_PREEMB))
						If EE9->(FieldPos("EE9_NRSD")) > 0 .And. !Empty(EE9->EE9_NRSD)
							cDespacho := EE9->EE9_NRSD
						Else
							cDespacho := EE9->EE9_RE
						EndIf
					Endif
					EEC->(DbSetOrder(1))
					If Empty(cDespacho) .And. EEC->(dbSeek(xFilial("EEC")+(cAliasSD2)->D2_PREEMB))
						cDespacho := EEC->EEC_NRODUE
					Endif
				Else 
					CDL->(dbSeek(xFilial("CDL")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))			
					If Empty(CDL->CDL_NUMDE)
						If !Empty(cMVSISDESP) .And. (cAliasSD2)->(FieldPos(cMVSISDESP)) > 0
							cDespacho := (cAliasSD2)->(FieldGet(FieldPos(cMVSISDESP)))
						Endif  
					Else
						cDespacho := CDL->CDL_NUMDE
					Endif	
				Endif
			Endif     
			//Memorando (apenas no Equiparado)
			If cTipo == "2" 
				If lMVEECFAT
					EXL->(dbSetOrder(1))
					If EXL->(dbSeek(xFilial("EXL")+(cAliasSD2)->D2_PREEMB))					
						cMemorando := EXL->EXL_NROMEX
					Endif
				Else
					CDL->(dbSeek(xFilial("CDL")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))			
					If Empty(CDL->CDL_NRMEMO)
						If !Empty(cMVSISMEMO) .And. (cAliasSD2)->(FieldPos(cMVSISMEMO)) > 0
							cMemorando := (cAliasSD2)->(FieldGet(FieldPos(cMVSISMEMO)))
						Endif
					Else
						cMemorando := CDL->CDL_NRMEMO
					Endif	
				Endif
			Endif
			
			RecLock("SIS",.T.)			
			SIS->SIS_TIPO		:= cTipo
			SIS->SIS_CNPJ		:= SM0->M0_CGC
			SIS->SIS_CADICM		:= cCADICMS
			SIS->SIS_NUMERO		:= (cAliasSD2)->D2_DOC
			SIS->SIS_SERIE		:= &(cAliasSD2+'->'+SerieNfId('SD2',3,'D2_SERIE'))
			SIS->SIS_EMIS		:= (cAliasSD2)->D2_EMISSAO
			SIS->SIS_CFOP		:= (cAliasSD2)->D2_CF 
			SIS->SIS_CONT		:= xMagValFis(2,0,"SF2",nItem,"LF_VALCONT")  
			SIS->SIS_DIF		:= nValDif
			SIS->SIS_IND		:= Iif(cTipo == "4",(cAliasSD2)->D2_TOTAL,0)
			SIS->SIS_BASE		:= Iif(cTipo == "5",(cAliasSD2)->D2_BASEICM,0)
			SIS->SIS_DESP		:= Padr(Alltrim(cDespacho),11)
			SIS->SIS_MEMO		:= cMemorando
			SIS->SIS_NBM		:= Iif(cTipo == "5",Alltrim((cAliasSB1)->B1_POSIPI),"")
			SIS->SIS_DESCR		:= Iif(cTipo == "5",Alltrim((cAliasSB1)->B1_DESC),"")
			SIS->SIS_DEST		:= Iif(cTipo <> "1",cCNPJ,"")
			SIS->SIS_IEDEST		:= Iif(cTipo <> "1",cIE,"")
			SIS->SIS_CPF		:= cCPF
			SIS->SIS_NOME		:= cNome
			SIS->SIS_MUN		:= Iif(cTipo <> "1",cMunic,"")
			SIS->SIS_UF			:= cUF
			MsUnLock()			
			
			(cAliasSD2)->(dbSkip())
			
		Enddo

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExcluindo areas criadasณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		#IFDEF TOP
			DbSelectArea(cAliasSD2)
			(cAliasSD2)->(DbCloseArea())
		#ENDIF

		SM0->(dbSkip())
		
	Enddo

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRetornando area SM0ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	RestArea(aAreaSm0)
	cFilAnt	:= SM0->M0_CODFIL                   

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSisCredTmp  บAutor  ณMary C. Hergert     บ Data ณ  06/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria os arquivos temporarios                                  บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSisCred                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SisCredTmp()

	Local aStruSIS	:= {}	     
	
	Local cArqSIS	:= ""

	AADD(aStruSIS,{"SIS_TIPO",			"C",001,0})
	AADD(aStruSIS,{"SIS_CNPJ",			"C",014,0})
	AADD(aStruSIS,{"SIS_CADICM",		"C",010,0})
	AADD(aStruSIS,{"SIS_NUMERO",		"C",TamSX3("F2_DOC")[1],0})
	AADD(aStruSIS,{"SIS_SERIE",		"C",003,0})
	AADD(aStruSIS,{"SIS_EMIS",			"D",008,0})
	AADD(aStruSIS,{"SIS_CFOP",			"C",004,0})
	AADD(aStruSIS,{"SIS_CONT",			"N",014,2})
	AADD(aStruSIS,{"SIS_DIF",			"N",014,2})
	AADD(aStruSIS,{"SIS_IND",			"N",014,2})
	AADD(aStruSIS,{"SIS_BASE", 		"N",014,2})
	AADD(aStruSIS,{"SIS_DESP",			"C",011,0})
	AADD(aStruSIS,{"SIS_MEMO",			"C",020,0})
	AADD(aStruSIS,{"SIS_NBM",			"C",010,0})
	AADD(aStruSIS,{"SIS_DESCR",		"C",030,0})
	AADD(aStruSIS,{"SIS_DEST",			"C",014,0})
	AADD(aStruSIS,{"SIS_IEDEST",		"C",018,0})
	AADD(aStruSIS,{"SIS_CPF",			"C",018,0})
	AADD(aStruSIS,{"SIS_NOME",			"C",040,0})
	AADD(aStruSIS,{"SIS_MUN",			"C",015,0})
	AADD(aStruSIS,{"SIS_UF",			"C",002,0})
	//
	cArqSIS	:=	CriaTrab(aStruSIS)
	dbUseArea(.T.,__LocalDriver,cArqSIS,"SIS")
	IndRegua("SIS",cArqSIS,"SIS_CNPJ+SIS_CADICM+SIS_NUMERO+SIS_SERIE")
	
Return {cArqSIS,"SIS"}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSisCredDel  บAutor  ณMary C. Hergert     บ Data ณ  06/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDeleta os arquivos temporarios processados                    บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSisCred                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/         
Function SisCredDel(aDelArq)

	Local aAreaDel := GetArea()

	If File(aDelArq[01]+GetDBExtension())
		dbSelectArea(aDelArq[02])
		dbCloseArea()
		Ferase(aDelArq[01]+GetDBExtension())
		Ferase(aDelArq[01]+OrdBagExt())
	Endif	
	
	RestArea(aAreaDel)
	
Return
	
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSisCredStrบAutor  ณMary Hergert        บ Data ณ  06/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMontar um array apenas com os campos utilizados na query    บฑฑ
ฑฑบ          ณpara passagem na funcao TCSETFIELD                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaCampos: campos a serem tratados na query                   บฑฑ
ฑฑบ          ณcCmpQry: string contendo os campos para select na query     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSisCred                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
#IFDEF TOP
	Static Function SisCredStr(aCampos,cCmpQry)
		Local	aRet	:=	{}
		Local	nX		:=	0
		Local	aTamSx3	:=	{}
		Local aArea	:= GetArea()
		//
		For nX := 1 To Len(aCampos)
			dbSelectArea(aCampos[nX][02])		
			If(FieldPos(aCampos[nX][01])>0)
				aTamSx3 := TamSX3(aCampos[nX][01])
				aAdd (aRet,{aCampos[nX][01],aTamSx3[3],aTamSx3[1],aTamSx3[2]})
				//
				cCmpQry	+=	aCampos[nX][01]+", "
			EndIf
		Next(nX)
		//
		If(Len(cCmpQry)>0)
			cCmpQry	:=	" " + SubStr(cCmpQry,1,Len(cCmpQry)-2) + " "
		EndIf                             
		RestArea(aArea)
	Return(aRet)
#ENDIF	
