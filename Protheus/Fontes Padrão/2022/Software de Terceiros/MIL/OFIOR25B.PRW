#Include "OFIOR250.CH"
#Include "Protheus.ch" 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_OR25B ³ Autor ³ Andre Luis Almeida    ³ Data ³ 10/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carregando VETOR de Vendas de Veiculos                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_OR25B()

Local cGruVei  := left(GetNewPar("MV_GRUVEI","VEI")+space(4),4)
Local lDuplic  := .t.
Local nVPrzMd1 := nVPrzMd2 := nVdescon := 0
Local na := nk := 1
//Local cCALPCNE := GetNewPar("MV_CALPCNE","S")

	///////////////////////////////////
	//    V  E  I  C  U  L  O  S     //
	///////////////////////////////////

If FunName() == "OFIOR250"
	IncProc(STR0110)//Selecionando Veiculos...
	IncProc(STR0110)//Selecionando Veiculos...
	IncProc(STR0110)//Selecionando Veiculos...
EndIf
                            
cAliasVV0 := GetNextAlias()
BeginSql Alias cAliasVV0
	SELECT VV0.VV0_TIPFAT , VV0.VV0_NUMNFI , VV0.VV0_SERNFI , VV0.VV0_DATMOV , VVA.* ,
			 SD2.D2_TOTAL , SD2.D2_TIPO , SD2.D2_VALICM , SD2.D2_VALIMP5 , SD2.D2_VALIMP6 , SD2.D2_CUSTO1 , 
			 SF4.F4_PISCRED , SF4.F4_CREDICM , SF4.F4_ATUATF , SF2.F2_VALBRUT , SF2.F2_BASEISS , SF2.F2_PREFIXO ,
			 SF2.F2_DUPL , SF2.F2_EMISSAO , SF2.F2_VEND1 , SF2.F2_COND , SF2.F2_CLIENTE , SF2.F2_LOJA
	FROM %Table:VV0% VV0 , %Table:VVA% VVA , %Table:SB1% SB1 , %Table:SD2% SD2 , %Table:SF4% SF4 , %Table:SF2% SF2 
	WHERE VV0.VV0_FILIAL = %xFilial:VV0% 
	AND VVA.VVA_FILIAL = %xFilial:VVA% 
	AND SB1.B1_FILIAL = %xFilial:SB1% 
	AND SD2.D2_FILIAL = %xFilial:SD2% 
	AND SF4.F4_FILIAL = %xFilial:SF4% 
	AND SF2.F2_FILIAL = %xFilial:SF2% 
	AND VV0.%NotDel%
	AND VVA.%NotDel%
	AND SB1.%NotDel%
	AND SD2.%NotDel%
	AND SF4.%NotDel%
	AND SF2.%NotDel%
	AND VV0.VV0_DATMOV >= %Exp:MV_PAR01%
	AND VV0.VV0_DATMOV <= %Exp:MV_PAR02%
	AND VV0.VV0_OPEMOV = '0'
	AND VV0.VV0_SITNFI <> '0'
   AND VV0.VV0_NUMTRA = VVA.VVA_NUMTRA
   AND SB1.B1_GRUPO = %Exp:cGruVei%
   AND SB1.B1_CODITE = VVA.VVA_CHAINT
   AND SD2.D2_DOC = VV0.VV0_NUMNFI
   AND SD2.D2_SERIE = VV0.VV0_SERNFI
   AND SD2.D2_CLIENTE = VV0.VV0_CODCLI
   AND SD2.D2_LOJA = VV0.VV0_LOJA
   AND SD2.D2_COD = SB1.B1_COD
   AND SD2.D2_TES = SF4.F4_CODIGO
   AND SF4.F4_DUPLIC <> 'N'
   AND VV0.VV0_NUMNFI = SF2.F2_DOC
   AND VV0.VV0_SERNFI = SF2.F2_SERIE
EndSql
aAdd(aTotVei,{ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0, 0}) 
If FunName() == "OFIOR250"
	IncProc(STR0111)//Totalizando Veiculos...
	IncProc(STR0111)//Totalizando Veiculos...
	IncProc(STR0111)//Totalizando Veiculos...
EndIf
While !((cAliasVV0)->(Eof()))
	// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
	na := ( ((cAliasVV0)->(F2_VALBRUT)-(cAliasVV0)->(F2_BASEISS)) / (cAliasVV0)->(F2_VALBRUT) )
  	nk := ( (cAliasVV0)->(D2_TOTAL) / ( (cAliasVV0)->(F2_VALBRUT) - (cAliasVV0)->(F2_BASEISS) ) )
	nVprzmd1 := 0
	nVprzmd2 := 0
	// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
    nVdescon := 0

	cPrefSE1 := (cAliasVV0)->(F2_PREFIXO)
	cDuplSE1 := (cAliasVV0)->(F2_DUPL)
	cAliasSE1 := GetNextAlias()
	BeginSql Alias cAliasSE1
		SELECT SE1.E1_VALOR, SE1.E1_VENCTO, SE1.E1_TIPO
		FROM %Table:SE1% SE1
		WHERE SE1.E1_FILIAL = %xFilial:SE1% 
		AND SE1.%NotDel%
		AND SE1.E1_PREFIXO = %Exp:cPrefSE1%
		AND SE1.E1_NUM = %Exp:cDuplSE1%
	EndSql
	While !((cAliasSE1)->(Eof()))
		nVprzmd1 += ( ( nk * ( (cAliasSE1)->(E1_VALOR) * na ) ) * ( stod((cAliasSE1)->(E1_VENCTO)) - stod((cAliasVV0)->(F2_EMISSAO)) ) ) 
		nVprzmd2 += ( nk * ( (cAliasSE1)->(E1_VALOR) * na )  )
		If Alltrim((cAliasSE1)->(E1_TIPO)) == "CD" // CDCI - sem prazo medio
			nVprzmd1 := 0
		EndIf
		(cAliasSE1)->(Dbskip())
	EndDo         
	(cAliasSE1)->(DBCloseArea())

	cVenSF2 := (cAliasVV0)->(F2_VEND1)
	cAliasVAI := GetNextAlias()
	BeginSql Alias cAliasVAI
		SELECT VAI.VAI_CC
		FROM %Table:VAI% VAI
		WHERE VAI.VAI_FILIAL = %xFilial:VAI% 
		AND VAI.%NotDel%
		AND VAI.VAI_CODVEN = %Exp:cVenSF2%
	EndSql
	
	If (cAliasVV0)->(VV0_TIPFAT) # "2"

		If Empty((cAliasVV0)->(VV0_NUMNFI)) .or. (cAliasVV0)->(D2_TIPO) # "N"
			(cAliasVV0)->(Dbskip())
			(cAliasVAI)->(DbCloseArea())			
			Loop
		EndIf  
   
  	   DbSelectArea( "VV1" )
	   DbSetOrder(1)
	   DbSeek( xFilial("VV1") + (cAliasVV0)->(VVA_CHAINT) )    
       
   	nVtotimp := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_TOTIMP) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_TMFIMP) , xmoeda((cAliasVV0)->(VVA_TOTIMP),1,MV_PAR03,DDataBase)))
      if VV1->VV1_ESTVEI == "1"   
	       nVpisven := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_PISVEN) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_PMFVEN) , xmoeda((cAliasVV0)->(VVA_PISVEN),1,MV_PAR03,DDataBase)))
     	    nVcofven := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_COFVEN) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_CMFVEN) , xmoeda((cAliasVV0)->(VVA_COFVEN),1,MV_PAR03,DDataBase)))
//          if cCALPCNE == "N"
//             if nVpisven < 0 
//                nVtotimp := nVtotimp + abs(nVpisven)
//                nVpisven := 0 
//             Endif   
//             if nVcofven < 0 
//                nVtotimp := nVtotimp + abs(nVcofven)
//                nVcofven := 0 
//             Endif   
//          Endif   
       Else
	      nVpisven := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_PISVEN) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_PMFVEN) , xmoeda((cAliasVV0)->(VVA_PISVEN),1,MV_PAR03,DDataBase)))
      	  nVcofven := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_COFVEN) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_CMFVEN) , xmoeda((cAliasVV0)->(VVA_COFVEN),1,MV_PAR03,DDataBase)))
       Endif
       
	   // Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
       // Renata - 23/05/06 - Campo de moeda forte inexistente para desconto, nao e tratado no VEIVM010
  	   nVdescon := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_VALDES) , xmoeda((cAliasVV0)->(VVA_VALDES),1,MV_PAR03,DDataBase))	
	   If (MV_PAR08 == 1)
	
		   nVfattot := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_FATTOT) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_FMFTOT) , xmoeda((cAliasVV0)->(VVA_FATTOT),1,MV_PAR03,DDataBase)))
		   If SF4->F4_CREDICM == "N"
			   nVicmven  := 0
			Else   
			   nVicmven := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_ICMVEN) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_IMFVEN) , xmoeda((cAliasVV0)->(VVA_ICMVEN),1,MV_PAR03,DDataBase)))
   		Endif 
         nVtotimp := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_TOTIMP) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_TMFIMP) , xmoeda((cAliasVV0)->(VVA_TOTIMP),1,MV_PAR03,DDataBase)))
	      nVpisven := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_PISVEN) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_PMFVEN) , xmoeda((cAliasVV0)->(VVA_PISVEN),1,MV_PAR03,DDataBase)))
	      nVcofven := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_COFVEN) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_CMFVEN) , xmoeda((cAliasVV0)->(VVA_COFVEN),1,MV_PAR03,DDataBase)))
			  
		   nVtotcus := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_TOTCUS) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_TMFCUS) , xmoeda((cAliasVV0)->(VVA_TOTCUS),1,MV_PAR03,DDataBase)))
		   nVjurest := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_JUREST) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_JMFEST) , xmoeda((cAliasVV0)->(VVA_JUREST),1,MV_PAR03,DDataBase)))
   	   nVtotcus := (nVtotcus - nVjurest)
		   nVlucbru := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_LUCBRU) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_LMFBRU) , xmoeda((cAliasVV0)->(VVA_LUCBRU),1,MV_PAR03,DDataBase)))

	   Else            
	
		   nVfattot := If( MV_PAR03 == 1 , (cAliasVV0)->(D2_TOTAL)  , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_FMFTOT) , xmoeda((cAliasVV0)->(VVA_FATTOT),1,MV_PAR03,DDataBase)))
		   If SF4->F4_CREDICM == "N"
			   nVicmven := 0
			Else   
		   	nVicmven := If( MV_PAR03 == 1 , (cAliasVV0)->(D2_VALICM) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_IMFVEN) , xmoeda((cAliasVV0)->(VVA_ICMVEN),1,MV_PAR03,DDataBase)))
		   Endif	    
		   ///////////
         nVtotimp := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_TOTIMP) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_TMFIMP) , xmoeda((cAliasVV0)->(VVA_TOTIMP),1,MV_PAR03,DDataBase)))
	      if SF4->F4_PISCRED == "2"

	         nVpisven := If( MV_PAR03 == 1 , (cAliasVV0)->(D2_VALIMP6)  , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_PMFVEN) , xmoeda((cAliasVV0)->(VVA_PISVEN),1,MV_PAR03,DDataBase)))
	         nVcofven := If( MV_PAR03 == 1 , (cAliasVV0)->(D2_VALIMP5)  , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_CMFVEN) , xmoeda((cAliasVV0)->(VVA_COFVEN),1,MV_PAR03,DDataBase)))

         Endif
         ///////////
		   nVtotcus := If( MV_PAR03 == 1 , (cAliasVV0)->(D2_CUSTO1) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_TMFCUS) , xmoeda((cAliasVV0)->(VVA_TOTCUS),1,MV_PAR03,DDataBase)))
		   nVjurest := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_JUREST) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_JMFEST) , xmoeda((cAliasVV0)->(VVA_JUREST),1,MV_PAR03,DDataBase)))
   	   nVlucbru := If( MV_PAR03 == 1 , ((cAliasVV0)->(D2_TOTAL)-((cAliasVV0)->(D2_CUSTO1)+nVtotimp)) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_LMFBRU) , xmoeda((cAliasVV0)->(VVA_LUCBRU),1,MV_PAR03,DDataBase)))
	   	   
	   EndIf
   	
	   nVtotdes := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_TOTDES) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_TMFDES) , xmoeda((cAliasVV0)->(VVA_TOTDES),1,MV_PAR03,DDataBase)))
   	nVcomvde := If( MV_PAR03 == 1 , ((cAliasVV0)->(VVA_COMVDE)+(cAliasVV0)->(VVA_COMGER)) , If( MV_PAR03 == 2 , ((cAliasVV0)->(VVA_CMFVDE)+(cAliasVV0)->(VVA_CMFGER)) , xmoeda(((cAliasVV0)->(VVA_COMVDE)+(cAliasVV0)->(VVA_COMGER)),1,MV_PAR03,DDataBase)))
	   nVluclq1 := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_LUCLQ1) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_LMFLQ1) , xmoeda((cAliasVV0)->(VVA_LUCLQ1),1,MV_PAR03,DDataBase)))
   	nVdesfix := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_DESFIX) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_DMFFIX) , xmoeda((cAliasVV0)->(VVA_DESFIX),1,MV_PAR03,DDataBase)))
	   nVdesadm := 0
   	nVluclq2 := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_LUCLQ2) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_LMFLQ2) , xmoeda((cAliasVV0)->(VVA_LUCLQ2),1,MV_PAR03,DDataBase)))

		If Alltrim(SF4->F4_ATUATF) == "S"    //  A T I V O   I M O B I L I Z A D O
		     
			aTotAtiMob[1,3] += nVfattot
			aTotAtiMob[1,4] += nVtotimp 
			aTotAtiMob[1,5] += nVicmven 
			aTotAtiMob[1,6] += nVpisven 
			aTotAtiMob[1,7] += nVcofven 
			aTotAtiMob[1,8] += nVtotcus 
			aTotAtiMob[2,3] += nVfattot
			aTotAtiMob[2,4] += nVtotimp 
			aTotAtiMob[2,5] += nVicmven 
			aTotAtiMob[2,6] += nVpisven 
			aTotAtiMob[2,7] += nVcofven 
			aTotAtiMob[2,8] += nVtotcus 
		
		 	DbSelectArea( "VV1" )
			DbSetOrder(1)
			DbSeek( xFilial("VV1") + (cAliasVV0)->(VVA_CHAINT) )    

			DbSelectArea("VV2") 
			DbSetOrder(1)
			DbSeek(xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )

//			aAdd(aNumAtiMob,{ "V" , VV2->VV2_DESMOD , nVfattot , 0 , 0 , 0 , 0 , nVtotcus }) 
			aAdd(aNumAtiMob,{ "V" , VV2->VV2_DESMOD , nVfattot , nVtotimp , nVicmven ,nVpisven , nVcofven , nVtotcus }) 
   	
	   Else

		 	DbSelectArea( "VV1" )
			DbSetOrder(1)
			DbSeek( xFilial("VV1") + (cAliasVV0)->(VVA_CHAINT) )    

			DbSelectArea("VV2") 
			DbSetOrder(1)
			DbSeek(xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )
	
		   nPos := 0
			If ( MV_PAR05 == 1 .or. ( MV_PAR05 == 2 .and. MV_PAR04 # 3 .and. MV_PAR04 # 4 ))
				nPos := aScan(aNumVei,{|x| x[1] + x[2] + x[3] == Alltrim(VV1->VV1_PROVEI) + Alltrim((cAliasVV0)->(VV0_TIPFAT)) + VV2->VV2_DESMOD })
			Else                                                          
	 		 	DbSelectArea( "SA1" )
				DbSetOrder(1)
				DbSeek( xFilial("SA1") + VV1->VV1_PROATU + VV1->VV1_LJPATU )
				cCliente := VV1->VV1_PROATU + " " + left(SA1->A1_NOME,15)
				nPos := aScan(aNumVei,{|x| x[1] + x[2] + x[3] == Alltrim(VV1->VV1_PROVEI) + Alltrim((cAliasVV0)->(VV0_TIPFAT)) + cCliente })
			EndIf	
	
			If nPos == 0
				If ( MV_PAR05 == 1 .or. ( MV_PAR05 == 2 .and. MV_PAR04 # 3 .and. MV_PAR04 # 4 ))
					// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
					aAdd(aNumVei,{ Alltrim(VV1->VV1_PROVEI) , Alltrim((cAliasVV0)->(VV0_TIPFAT)) , VV2->VV2_DESMOD , nVfattot , nVtotimp , nVicmven , nVpisven , nVcofven , nVtotcus , nVjurest , nVlucbru , nVtotdes , nVcomvde , nVluclq1 , nVdesfix , nVdesadm , nVluclq2 , 1,VV1->VV1_MODVEI, nVPrzMd1, nVPrzMd2, nVdescon }) 
				Else                                                          
					// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
					aAdd(aNumVei,{ Alltrim(VV1->VV1_PROVEI) , Alltrim((cAliasVV0)->(VV0_TIPFAT)) , cCliente , nVfattot , nVtotimp , nVicmven , nVpisven , nVcofven , nVtotcus , nVjurest , nVlucbru , nVtotdes , nVcomvde , nVluclq1 , nVdesfix , nVdesadm , nVluclq2 , 1,VV1->VV1_MODVEI, nVPrzMd1, nVPrzMd2, nVdescon }) 
				EndIf	                                            
				If Type("aAnaVei") == "A"
		 		 	DbSelectArea( "SA1" )
					DbSetOrder(1)
					DbSeek( xFilial("SA1") + VV1->VV1_PROATU + VV1->VV1_LJPATU )
					aadd(aAnaVei,{SM0->M0_CODIGO,SM0->M0_CODFIL,(cAliasVV0)->(VV0_NUMNFI),(cAliasVV0)->(VV0_SERNFI),"V"+If((cAliasVV0)->(VV0_TIPFAT)=="0","N",If((cAliasVV0)->(VV0_TIPFAT)=="1","U","F")),SA1->A1_COD+SA1->A1_LOJA+LEFT(SA1->A1_NREDUZ,20),"VEI",VV1->VV1_CHAINT,VV1->VV1_CHASSI,nVFatTot,nVTotImp,nVTotCus,stod((cAliasVV0)->(VV0_DATMOV))})
				Endif	
			Else
			 	aNumVei[nPos,4]  += nVfattot
		 		aNumVei[nPos,5]  += nVtotimp
			 	aNumVei[nPos,6]  += nVicmven
			 	aNumVei[nPos,7]  += nVpisven
			 	aNumVei[nPos,8]  += nVcofven
		 		aNumVei[nPos,9]  += nVtotcus
			 	aNumVei[nPos,10] += nVjurest
			 	aNumVei[nPos,11] += nVlucbru
			 	aNumVei[nPos,12] += nVtotdes
		 		aNumVei[nPos,13] += nVcomvde
			 	aNumVei[nPos,14] += nVluclq1
			 	aNumVei[nPos,15] += nVdesfix
			 	aNumVei[nPos,16] += nVdesadm
		 		aNumVei[nPos,17] += nVluclq2
				// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
		 		aNumVei[nPos,20] += nVPrzMd1
		 		aNumVei[nPos,21] += nVPrzMd2
				// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
			 	aNumVei[nPos,22] += nVDescon
			 	aNumVei[nPos,18]++ 
				If Type("aAnaVei") == "A"
		 		 	DbSelectArea( "SA1" )
					DbSetOrder(1)
					DbSeek( xFilial("SA1") + VV1->VV1_PROATU + VV1->VV1_LJPATU )
					aadd(aAnaVei,{SM0->M0_CODIGO,SM0->M0_CODFIL,(cAliasVV0)->(VV0_NUMNFI),(cAliasVV0)->(VV0_SERNFI),"V"+If((cAliasVV0)->(VV0_TIPFAT)=="0","N",If((cAliasVV0)->(VV0_TIPFAT)=="1","U","F")),SA1->A1_COD+SA1->A1_LOJA+LEFT(SA1->A1_NREDUZ,20),"VEI",VV1->VV1_CHAINT,VV1->VV1_CHASSI,nVFatTot,nVTotImp,nVTotCus,stod((cAliasVV0)->(VV0_DATMOV))})
				Endif	
			EndIf
	
		   nPos := 0
			nPos := aScan(aGrpVei,{|x| x[1] + x[2] == Alltrim(VV1->VV1_PROVEI) + Alltrim((cAliasVV0)->(VV0_TIPFAT)) })
			If nPos == 0
				// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
				aAdd(aGrpVei,{ Alltrim(VV1->VV1_PROVEI) , Alltrim((cAliasVV0)->(VV0_TIPFAT)) , nVfattot , nVtotimp , nVicmven , nVpisven , nVcofven , nVtotcus , nVjurest , nVlucbru , nVtotdes , nVcomvde , nVluclq1 , nVdesfix , nVdesadm , nVluclq2 , 1, nVPrzMd1, nVPrzMd2, nVdescon }) 
			Else
			 	aGrpVei[nPos,3]  += nVfattot
		 		aGrpVei[nPos,4]  += nVtotimp
			 	aGrpVei[nPos,5]  += nVicmven
			 	aGrpVei[nPos,6]  += nVpisven
			 	aGrpVei[nPos,7]  += nVcofven
		 		aGrpVei[nPos,8]  += nVtotcus
			 	aGrpVei[nPos,9]  += nVjurest
			 	aGrpVei[nPos,10] += nVlucbru
			 	aGrpVei[nPos,11] += nVtotdes
		 		aGrpVei[nPos,12] += nVcomvde
			 	aGrpVei[nPos,13] += nVluclq1
			 	aGrpVei[nPos,14] += nVdesfix
			 	aGrpVei[nPos,15] += nVdesadm
		 		aGrpVei[nPos,16] += nVluclq2
				// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
			 	aGrpVei[nPos,18] += nVPrzMd1
			 	aGrpVei[nPos,19] += nVPrzMd2
				// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
			 	aGrpVei[nPos,20] += nVdescon
			 	aGrpVei[nPos,17]++ 
			EndIf
		
		 	aTotVei[1,1]  += nVfattot
		 	aTotVei[1,2]  += nVtotimp
	 		aTotVei[1,3]  += nVicmven
		 	aTotVei[1,4]  += nVpisven
		 	aTotVei[1,5]  += nVcofven
	 		aTotVei[1,6]  += nVtotcus
		 	aTotVei[1,7]  += nVjurest
		 	aTotVei[1,8]  += nVlucbru
	 		aTotVei[1,9]  += nVtotdes
		 	aTotVei[1,10] += nVcomvde
		 	aTotVei[1,11] += nVluclq1
	 		aTotVei[1,12] += nVdesfix
		 	aTotVei[1,13] += nVdesadm
		 	aTotVei[1,14] += nVluclq2
			// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
		 	aTotVei[1,15] += nVPrzMd1
		 	aTotVei[1,16] += nVPrzMd2
			// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
		 	aTotVei[1,17] += nVdescon
	
			aTotal[1,1]  += nVfattot
		 	aTotal[1,2]  += nVtotimp
		 	aTotal[1,3]  += nVicmven
		 	aTotal[1,5]  += nVpisven
	 		aTotal[1,6]  += nVcofven
		 	aTotal[1,7]  += nVtotcus
		 	aTotal[1,8]  += nVjurest
	 		aTotal[1,9]  += nVlucbru
		 	aTotal[1,10] += nVtotdes
		 	aTotal[1,11] += nVcomvde
		 	aTotal[1,12] += nVluclq1
	 		aTotal[1,13] += nVdesfix
		 	aTotal[1,14] += nVdesadm
		 	aTotal[1,15] += nVluclq2
			// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
		 	aTotal[1,16] += nVPrzMd1
		 	aTotal[1,17] += nVPrzMd2
			// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
		 	aTotal[1,18] += nVdescon
	   	
			If MV_PAR06 # 1
	
			 	aTotCon[1,1]  += nVfattot
			 	aTotCon[1,2]  += nVtotimp
				aTotCon[1,3]  += nVicmven
			 	aTotCon[1,5]  += nVpisven
				aTotCon[1,6]  += nVcofven
				aTotCon[1,7]  += nVtotcus
				aTotCon[1,8]  += nVjurest
				aTotCon[1,9]  += nVlucbru
				aTotCon[1,10] += nVtotdes
				aTotCon[1,11] += nVcomvde
				aTotCon[1,12] += nVluclq1
				aTotCon[1,13] += nVdesfix
				aTotCon[1,14] += nVdesadm
				aTotCon[1,15] += nVluclq2
				// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
				aTotCon[1,16] += nVPrzMd1
				aTotCon[1,17] += nVPrzMd2
				// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
				aTotCon[1,18] += nVdescon
			
			   nPos := 0
				nPos := aScan(aConPagNF,{|x| x[1]+x[2]+x[3]+x[4]+x[7] == (cAliasVV0)->(F2_COND) + If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasVV0)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) + (cAliasVV0)->(VV0_NUMNFI) + (cAliasVV0)->(VV0_SERNFI) + "1" })
			   If nPos == 0                                                                                                           
					DbSelectArea( "SA1" )
					DbSetOrder(1)
					DbSeek( xFilial("SA1") + (cAliasVV0)->(F2_CLIENTE) + (cAliasVV0)->(F2_LOJA) )
					aAdd(aConPagNF,{ (cAliasVV0)->(F2_COND) , If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasVV0)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) , (cAliasVV0)->(VV0_NUMNFI) , (cAliasVV0)->(VV0_SERNFI) , left(SA1->A1_NOME,10) , nVfattot , "1" })
			  	Else
	   			aConPagNF[nPos,6] += nVfattot
				EndIf                    
			   nPos := 0
				nPos := aScan(aGrpPag,{|x| x[1] == (cAliasVV0)->(F2_COND) })
				If nPos == 0    
					DbSelectArea( "SE4" )
					DbSetOrder(1)
					DbSeek( xFilial("SE4") + (cAliasVV0)->(F2_COND) )
					// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
					aAdd(aGrpPag,{ (cAliasVV0)->(F2_COND) , SE4->E4_DESCRI , nVfattot , nVtotimp , nVicmven , 0 , nVpisven , nVcofven , nVtotcus , nVjurest , nVlucbru , nVtotdes , nVcomvde , nVluclq1 , nVdesfix , nVdesadm , nVluclq2, nVPrzMd1, nVPrzMd2, nVdescon }) 
				Else
				 	aGrpPag[nPos,3]  += nVfattot
				 	aGrpPag[nPos,4]  += nVtotimp
				 	aGrpPag[nPos,5]  += nVicmven
				 	aGrpPag[nPos,7]  += nVpisven
				 	aGrpPag[nPos,8]  += nVcofven
				 	aGrpPag[nPos,9]  += nVtotcus
				 	aGrpPag[nPos,10] += nVjurest
			 		aGrpPag[nPos,11] += nVlucbru
				 	aGrpPag[nPos,12] += nVtotdes
				 	aGrpPag[nPos,13] += nVcomvde
				 	aGrpPag[nPos,14] += nVluclq1
				 	aGrpPag[nPos,15] += nVdesfix
			 		aGrpPag[nPos,16] += nVdesadm
				 	aGrpPag[nPos,17] += nVluclq2
					// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
				 	aGrpPag[nPos,18] += nVPrzMd1
				 	aGrpPag[nPos,19] += nVPrzMd2
					// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
				 	aGrpPag[nPos,20] += nVdescon
				EndIf
			
				nPos := 0
				If MV_PAR06 # 3
					nPos := aScan(aTotPag,{|x| x[1]+x[2] == (cAliasVV0)->(F2_COND) + If(lDuplic,"E","I")+(cAliasVV0)->(F2_VEND1) })
				Else     
					nPos := aScan(aTotPag,{|x| x[1]+x[2] == (cAliasVV0)->(F2_COND) + If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) })	
				EndIf
	
				If nPos == 0 .or. MV_PAR06 == 4
					If MV_PAR06 # 3
						DbSelectArea( "SA3" )
						DbSetOrder(1)
						DbSeek( xFilial("SA3") + (cAliasVV0)->(F2_VEND1) )
						// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
						aAdd(aTotPag,{ (cAliasVV0)->(F2_COND) , If(lDuplic,"E","I")+(cAliasVV0)->(F2_VEND1) , left(SA3->A3_NOME,17) , nVfattot , nVtotimp , nVicmven , 0 , nVpisven , nVcofven , nVtotcus , nVjurest , nVlucbru , nVtotdes , nVcomvde , nVluclq1 , nVdesfix , nVdesadm , nVluclq2, nVPrzMd1, nVPrzMd2, nVdescon })      

						nPos3 := 0
						nPos3 := aScan(aCCVend,{|x| x[1]+x[2] == If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) + (cAliasVV0)->(F2_VEND1) })
						If nPos3 == 0
							DbSelectArea( "CTT" )
							DbSetOrder(1)
							DbSeek( xFilial("CTT") + (cAliasVAI)->(VAI_CC) )
							// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
							aAdd(aCCVend,{ If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , (cAliasVV0)->(F2_VEND1) , left(SA3->A3_NOME,17) , nVfattot , nVtotimp , nVicmven , 0 , nVpisven , nVcofven , nVtotcus , nVjurest , nVlucbru , nVtotdes , nVcomvde , nVluclq1 , nVdesfix , nVdesadm , nVluclq2 , If(lDuplic,"Ext ","Int ")+left(CTT->CTT_DESC01,21), nVPrzMd1, nVPrzMd2, nVdescon })
	               Else
						 	aCCVend[nPos3,4]  += nVfattot
					 		aCCVend[nPos3,5]  += nVtotimp
						 	aCCVend[nPos3,6]  += nVicmven
        				 	aCCVend[nPos3,7]  += 0
						 	aCCVend[nPos3,8]  += nVpisven
					 		aCCVend[nPos3,9]  += nVcofven
						 	aCCVend[nPos3,10] += nVtotcus
						 	aCCVend[nPos3,11] += nVjurest
				 			aCCVend[nPos3,12] += nVlucbru
					 		aCCVend[nPos3,13] += nVtotdes
						 	aCCVend[nPos3,14] += nVcomvde
						 	aCCVend[nPos3,15] += nVluclq1
					 		aCCVend[nPos3,16] += nVdesfix
					 		aCCVend[nPos3,17] += nVdesadm
						 	aCCVend[nPos3,18] += nVluclq2
							// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
						 	aCCVend[nPos3,20] += nVPrzMd1
						 	aCCVend[nPos3,21] += nVPrzMd2
							// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
						 	aCCVend[nPos3,22] += nVdescon
      	         EndIf
						nPos3 := 0
						nPos3 := aScan(aTotCCV,{|x| x[1] == If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) })
						If nPos3 == 0
							// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
							aAdd(aTotCCV,{ If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , nVfattot , nVtotimp , nVicmven , 0 , nVpisven , nVcofven , nVtotcus , nVjurest , nVlucbru , nVtotdes , nVcomvde , nVluclq1 , nVdesfix , nVdesadm , nVluclq2, nVPrzMd1, nVPrzMd2, nVdescon })
      	         Else
						 	aTotCCV[nPos3,2]  += nVfattot
					 		aTotCCV[nPos3,3]  += nVtotimp
						 	aTotCCV[nPos3,4]  += nVicmven
        			 		aTotCCV[nPos3,5]  += 0
						 	aTotCCV[nPos3,6]  += nVpisven
						 	aTotCCV[nPos3,7]  += nVcofven
						 	aTotCCV[nPos3,8]  += nVtotcus
						 	aTotCCV[nPos3,9]  += nVjurest
			 				aTotCCV[nPos3,10] += nVlucbru
				 			aTotCCV[nPos3,11] += nVtotdes
					 		aTotCCV[nPos3,12] += nVcomvde
						 	aTotCCV[nPos3,13] += nVluclq1
						 	aTotCCV[nPos3,14] += nVdesfix
					 		aTotCCV[nPos3,15] += nVdesadm
						 	aTotCCV[nPos3,16] += nVluclq2
							// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
						 	aTotCCV[nPos3,17] += nVPrzMd1
						 	aTotCCV[nPos3,18] += nVPrzMd2
							// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
						 	aTotCCV[nPos3,18] += nVdescon
            	   EndIf
					Else     
						DbSelectArea( "CTT" )
						DbSetOrder(1)
						DbSeek( xFilial("CTT") + (cAliasVAI)->(VAI_CC) )
						// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
						aAdd(aTotPag,{ (cAliasVV0)->(F2_COND) , If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , left(CTT->CTT_DESC01,14) , nVfattot , nVtotimp , nVicmven , 0 , nVpisven , nVcofven , nVtotcus , nVjurest , nVlucbru , nVtotdes , nVcomvde , nVluclq1 , nVdesfix , nVdesadm , nVluclq2, nVPrzMd1, nVPrzMd2, nVdescon })      
					EndIf
				Else                                                             
				 	aTotPag[nPos,4]  += nVfattot
				 	aTotPag[nPos,5]  += nVtotimp
				 	aTotPag[nPos,6]  += nVicmven
				 	aTotPag[nPos,8]  += nVpisven
				 	aTotPag[nPos,9]  += nVcofven
				 	aTotPag[nPos,10] += nVtotcus
				 	aTotPag[nPos,11] += nVjurest
				 	aTotPag[nPos,12] += nVlucbru
				 	aTotPag[nPos,13] += nVtotdes
				 	aTotPag[nPos,14] += nVcomvde
				 	aTotPag[nPos,15] += nVluclq1
				 	aTotPag[nPos,16] += nVdesfix
				 	aTotPag[nPos,17] += nVdesadm
			 		aTotPag[nPos,18] += nVluclq2
					// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
			 		aTotPag[nPos,19] += nVPrzMd1
			 		aTotPag[nPos,20] += nVPrzMd2
					// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
			 		aTotPag[nPos,21] += nVdescon
				EndIf
		      
			EndIf

		EndIf

	Else // VV0->VV0_TIPFAT == "2" -> Faturamento Direto

  	   DbSelectArea( "VV1" )
	   DbSetOrder(1)
	   DbSeek( xFilial("VV1") + (cAliasVV0)->(VVA_CHAINT) )    

      nVtotimp := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_TOTIMP) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_TMFIMP) , xmoeda((cAliasVV0)->(VVA_TOTIMP),1,MV_PAR03,DDataBase)))
	   if VV1->VV1_ESTVEI == "1"
	      nVpisven := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_PISVEN) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_PMFVEN) , xmoeda((cAliasVV0)->(VVA_PISVEN),1,MV_PAR03,DDataBase)))
	      nVcofven := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_COFVEN) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_CMFVEN) , xmoeda((cAliasVV0)->(VVA_COFVEN),1,MV_PAR03,DDataBase)))
//          if cCALPCNE == "N"
//             if nVpisven < 0 
//                nVpisven := 0 
//             Endif   
//             if nVcofven < 0 
//                nVcofven := 0 
//             Endif   
//          Endif   
       Else
	      nVpisven := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_PISVEN) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_PMFVEN) , xmoeda((cAliasVV0)->(VVA_PISVEN),1,MV_PAR03,DDataBase)))
	      nVcofven := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_COFVEN) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_CMFVEN) , xmoeda((cAliasVV0)->(VVA_COFVEN),1,MV_PAR03,DDataBase)))
       Endif   
		// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
      // Renata - 23/05/06 - Campo de moeda forte inexistente para desconto, nao e tratado no VEIVM010
	   nVdescon := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_VALDES) , xmoeda((cAliasVV0)->(VVA_VALDES),1,MV_PAR03,DDataBase))
		If ( MV_PAR08 == 1 .or. Empty((cAliasVV0)->(VV0_NUMNFI)) )
	
		   nVfattot := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_FATTOT) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_FMFTOT) , xmoeda((cAliasVV0)->(VVA_FATTOT),1,MV_PAR03,DDataBase)))
		   If SF4->F4_CREDICM == "N"
			   nVicmven := 0
			Else   
			   nVicmven := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_ICMVEN) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_IMFVEN) , xmoeda((cAliasVV0)->(VVA_ICMVEN),1,MV_PAR03,DDataBase)))
			Endif   
		   nVtotcus := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_TOTCUS) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_TMFCUS) , xmoeda((cAliasVV0)->(VVA_TOTCUS),1,MV_PAR03,DDataBase)))
		   nVjurest := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_JUREST) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_JMFEST) , xmoeda((cAliasVV0)->(VVA_JUREST),1,MV_PAR03,DDataBase)))
	   	nVtotcus := (nVtotcus - nVjurest)
		   nVlucbru := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_LUCBRU) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_LMFBRU) , xmoeda((cAliasVV0)->(VVA_LUCBRU),1,MV_PAR03,DDataBase)))

	   Else            
	
		   nVfattot := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_FATTOT) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_FMFTOT) , xmoeda((cAliasVV0)->(VVA_FATTOT),1,MV_PAR03,DDataBase)))
		   If SF4->F4_CREDICM == "N"
			   nVicmven := 0         
			Else   
			   nVicmven := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_ICMVEN) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_IMFVEN) , xmoeda((cAliasVV0)->(VVA_ICMVEN),1,MV_PAR03,DDataBase)))
			Endif   
		   nVtotcus := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_TOTCUS) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_TMFCUS) , xmoeda((cAliasVV0)->(VVA_TOTCUS),1,MV_PAR03,DDataBase)))
		   nVjurest := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_JUREST) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_JMFEST) , xmoeda((cAliasVV0)->(VVA_JUREST),1,MV_PAR03,DDataBase)))
	   	nVtotcus := (nVtotcus - nVjurest)
		   nVlucbru := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_LUCBRU) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_LMFBRU) , xmoeda((cAliasVV0)->(VVA_LUCBRU),1,MV_PAR03,DDataBase)))

	   EndIf
   	
	   nVtotdes := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_TOTDES) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_TMFDES) , xmoeda((cAliasVV0)->(VVA_TOTDES),1,MV_PAR03,DDataBase)))
   	nVcomvde := If( MV_PAR03 == 1 , ((cAliasVV0)->(VVA_COMVDE)+(cAliasVV0)->(VVA_COMGER)) , If( MV_PAR03 == 2 , ((cAliasVV0)->(VVA_CMFVDE)+(cAliasVV0)->(VVA_CMFGER)) , xmoeda(((cAliasVV0)->(VVA_COMVDE)+(cAliasVV0)->(VVA_COMGER)),1,MV_PAR03,DDataBase)))
	   nVluclq1 := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_LUCLQ1) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_LMFLQ1) , xmoeda((cAliasVV0)->(VVA_LUCLQ1),1,MV_PAR03,DDataBase)))
   	nVdesfix := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_DESFIX) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_DMFFIX) , xmoeda((cAliasVV0)->(VVA_DESFIX),1,MV_PAR03,DDataBase)))
	   nVdesadm := 0
   	nVluclq2 := If( MV_PAR03 == 1 , (cAliasVV0)->(VVA_LUCLQ2) , If( MV_PAR03 == 2 , (cAliasVV0)->(VVA_LMFLQ2) , xmoeda((cAliasVV0)->(VVA_LUCLQ2),1,MV_PAR03,DDataBase)))

	 	DbSelectArea( "VV1" )
		DbSetOrder(1)
		DbSeek( xFilial("VV1") + (cAliasVV0)->(VVA_CHAINT) )    

		DbSelectArea("VV2") 
		DbSetOrder(1)
		DbSeek(xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )
	
	   nPos := 0
		If ( MV_PAR05 == 1 .or. ( MV_PAR05 == 2 .and. MV_PAR04 # 3 .and. MV_PAR04 # 4 ))
			nPos := aScan(aNumVei,{|x| x[1] + x[2] + x[3] == "88" + VV2->VV2_DESMOD })
		Else                                                          
 		 	DbSelectArea( "SA1" )
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + VV1->VV1_PROATU + VV1->VV1_LJPATU )
			cCliente := VV1->VV1_PROATU + " " + left(SA1->A1_NOME,15)
			nPos := aScan(aNumVei,{|x| x[1] + x[2] + x[3] == "88" + cCliente })
		EndIf	
	
		If nPos == 0
			If ( MV_PAR05 == 1 .or. ( MV_PAR05 == 2 .and. MV_PAR04 # 3 .and. MV_PAR04 # 4 ))
				// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
				aAdd(aNumVei,{ "8" , "8" , VV2->VV2_DESMOD , nVfattot , nVtotimp , nVicmven , nVpisven , nVcofven , nVtotcus , nVjurest , nVlucbru , nVtotdes , nVcomvde , nVluclq1 , nVdesfix , nVdesadm , nVluclq2 , 1 , VV1->VV1_MODVEI, nVPrzMd1, nVPrzMd2, nVdescon }) 
			Else                                                          
				// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
				aAdd(aNumVei,{ "8" , "8" , cCliente , nVfattot , nVtotimp , nVicmven , nVpisven , nVcofven , nVtotcus , nVjurest , nVlucbru , nVtotdes , nVcomvde , nVluclq1 , nVdesfix , nVdesadm , nVluclq2 , 1 , VV1->VV1_MODVEI, nVPrzMd1, nVPrzMd2, nVdescon }) 
				If Type("aAnaVei") == "A"
		 		 	DbSelectArea( "SA1" )
					DbSetOrder(1)
					DbSeek( xFilial("SA1") + VV1->VV1_PROATU + VV1->VV1_LJPATU )
					aadd(aAnaVei,{SM0->M0_CODIGO,SM0->M0_CODFIL,(cAliasVV0)->(VV0_NUMNFI),(cAliasVV0)->(VV0_SERNFI),"V"+If((cAliasVV0)->(VV0_TIPFAT)=="0","N",If((cAliasVV0)->(VV0_TIPFAT)=="1","U","F")),SA1->A1_COD+SA1->A1_LOJA+LEFT(SA1->A1_NREDUZ,20),"VEI",VV1->VV1_CHAINT,VV1->VV1_CHASSI,nVFatTot,nVTotImp,nVTotCus,stod((cAliasVV0)->(VV0_DATMOV))})
				Endif	
			EndIf	
		Else
		 	aNumVei[nPos,4]  += nVfattot
	 		aNumVei[nPos,5]  += nVtotimp
		 	aNumVei[nPos,6]  += nVicmven
		 	aNumVei[nPos,7]  += nVpisven
		 	aNumVei[nPos,8]  += nVcofven
	 		aNumVei[nPos,9]  += nVtotcus
		 	aNumVei[nPos,10] += nVjurest
		 	aNumVei[nPos,11] += nVlucbru
		 	aNumVei[nPos,12] += nVtotdes
	 		aNumVei[nPos,13] += nVcomvde
		 	aNumVei[nPos,14] += nVluclq1
		 	aNumVei[nPos,15] += nVdesfix
		 	aNumVei[nPos,16] += nVdesadm
	 		aNumVei[nPos,17] += nVluclq2
			// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
	 		aNumVei[nPos,20] += nVPrzMd1
	 		aNumVei[nPos,21] += nVPrzMd2
			// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
	 		aNumVei[nPos,22] += nVdescon
		 	aNumVei[nPos,18]++ 
			If Type("aAnaVei") == "A"
	 		 	DbSelectArea( "SA1" )
				DbSetOrder(1)
				DbSeek( xFilial("SA1") + VV1->VV1_PROATU + VV1->VV1_LJPATU )
				aadd(aAnaVei,{SM0->M0_CODIGO,SM0->M0_CODFIL,(cAliasVV0)->(VV0_NUMNFI),(cAliasVV0)->(VV0_SERNFI),"V"+If((cAliasVV0)->(VV0_TIPFAT)=="0","N",If((cAliasVV0)->(VV0_TIPFAT)=="1","U","F")),SA1->A1_COD+SA1->A1_LOJA+LEFT(SA1->A1_NREDUZ,20),"VEI",VV1->VV1_CHAINT,VV1->VV1_CHASSI,nVFatTot,nVTotImp,nVTotCus,stod((cAliasVV0)->(VV0_DATMOV))})
			Endif	
		EndIf

	   nPos := 0
		nPos := aScan(aNumVei,{|x| x[1] + x[2] + x[3] == "88" + space(30) })
		If nPos == 0
			// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
			aAdd(aNumVei,{ "8" , "8" , space(30) , (cAliasVV0)->(VVA_VALVDA) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , VV1->VV1_MODVEI , 0 , 0, 0 })
		Else
		 	aNumVei[nPos,4]  += (cAliasVV0)->(VVA_VALVDA)
		EndIf
	   nPos := 0
		If ( MV_PAR05 == 1 .or. ( MV_PAR05 == 2 .and. MV_PAR04 # 3 .and. MV_PAR04 # 4 ))
			nPos := aScan(aNumVei,{|x| x[1] + x[2] + x[3] == "88" + VV2->VV2_DESMOD + "X" })
		Else                                                          
			cCliente := VV1->VV1_PROATU + " " + left(SA1->A1_NOME,15)
			nPos := aScan(aNumVei,{|x| x[1] + x[2] + x[3] == "88" + cCliente + "X" })
		EndIf
		If nPos == 0
			If ( MV_PAR05 == 1 .or. ( MV_PAR05 == 2 .and. MV_PAR04 # 3 .and. MV_PAR04 # 4 ))
				// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
				aAdd(aNumVei,{ "8" , "8" , VV2->VV2_DESMOD + "X" , (cAliasVV0)->(VVA_VALVDA) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , VV1->VV1_MODVEI , 0 , 0, 0})
			Else                                                          
				// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
				aAdd(aNumVei,{ "8" , "8" , cCliente + "X" , (cAliasVV0)->(VVA_VALVDA) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , VV1->VV1_MODVEI , 0 , 0, 0})
			EndIf
		Else
		 	aNumVei[nPos,4]  += (cAliasVV0)->(VVA_VALVDA)
		EndIf

	   nPos := 0
		nPos := aScan(aGrpVei,{|x| x[1] + x[2] == "88" })
		If nPos == 0
			// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
			aAdd(aGrpVei,{ "8" , "8" , nVfattot , nVtotimp , nVicmven , nVpisven , nVcofven , nVtotcus , nVjurest , nVlucbru , nVtotdes , nVcomvde , nVluclq1 , nVdesfix , nVdesadm , nVluclq2 , 1 , nVPrzMd1, nVPrzMd2, nVdescon }) 
		Else
		 	aGrpVei[nPos,3]  += nVfattot
			aGrpVei[nPos,4]  += nVtotimp
		 	aGrpVei[nPos,5]  += nVicmven
		 	aGrpVei[nPos,6]  += nVpisven
		 	aGrpVei[nPos,7]  += nVcofven
			aGrpVei[nPos,8]  += nVtotcus
		 	aGrpVei[nPos,9]  += nVjurest
		 	aGrpVei[nPos,10] += nVlucbru
		 	aGrpVei[nPos,11] += nVtotdes
			aGrpVei[nPos,12] += nVcomvde
		 	aGrpVei[nPos,13] += nVluclq1
		 	aGrpVei[nPos,14] += nVdesfix
		 	aGrpVei[nPos,15] += nVdesadm
			aGrpVei[nPos,16] += nVluclq2
			// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
			aGrpVei[nPos,18] += nVPrzMd1
			aGrpVei[nPos,19] += nVPrzMd2
			// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
			aGrpVei[nPos,20] += nVdescon
		 	aGrpVei[nPos,17]++ 
		EndIf
	EndIf
	(cAliasVAI)->(DbCloseArea())			
	(cAliasVV0)->(Dbskip())
EndDo

(cAliasVV0)->(DBCloseArea())

Return
