#Include "OFIOR250.CH"
#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_OR25D ³ Autor ³ Andre Luis Almeida    ³ Data ³ 10/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carregando VETOR de Vendas de Servicos                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_OR25D()

Local cCliVSC := cLojVSC := cVenVSC := cCPgVSC := ""
Local lDuplic := .f.
// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo Medio
Local nVprzmd1 := nVprzmd2 := 0
// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
Local	nSdescon := 0
If FunName() == "OFIOR250"
	IncProc(STR0116)//Selecionando Servicos...
	IncProc(STR0116)//Selecionando Servicos...
	IncProc(STR0116)//Selecionando Servicos...
EndIf
///////////////////////////////////
//    S  E  R  V  I  C  O  S     //
///////////////////////////////////
cAliasVSC := GetNextAlias()
BeginSql Alias cAliasVSC
	SELECT VSC.* , VOI.VOI_SITTPO 
	FROM %Table:VSC% VSC , %Table:VOI% VOI 
	WHERE VSC.VSC_FILIAL = %xFilial:VSC% 
	AND VOI.VOI_FILIAL = %xFilial:VOI% 
	AND VSC.%NotDel%
	AND VOI.%NotDel%
	AND VSC.VSC_DATVEN >= %Exp:MV_PAR01%
	AND VSC.VSC_DATVEN <= %Exp:MV_PAR02%
	AND VSC.VSC_TIPTEM = VOI.VOI_TIPTEM
EndSql
aAdd(aTotSrv,{ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0, 0, 0, 0 }) 
If FunName() == "OFIOR250"
	IncProc(STR0117)//Totalizando Servicos...
	IncProc(STR0117)//Totalizando Servicos...
	IncProc(STR0117)//Totalizando Servicos...
EndIf
While !((cAliasVSC)->(Eof()))
	DBSelectArea("VO4")
	DBGoto(VAL((cAliasVSC)->(VSC_RECVO4)))
	DbSelectArea( "SF2" )
	DbSetOrder(1)
	nVprzmd1 := nVprzmd2 := 0
	lDuplic := .t.
	If !DbSeek( xFilial("SF2") + (cAliasVSC)->(VSC_NUMNFI) + (cAliasVSC)->(VSC_SERNFI) )
		If (cAliasVSC)->(VOI_SITTPO) # "3"
			(cAliasVSC)->(Dbskip())
			loop
		Else
			lDuplic := .f.
			nSvalser:= VO4->VO4_VALINT
			DbSelectArea( "VO2" )
			DbSetOrder(2)
			DbSeek( xFilial("VO2") + VO4->VO4_NOSNUM )
		   cCliVSC := VO4->VO4_FATPAR
		   cLojVSC := VO4->VO4_LOJA
		   cVenVSC := VO2->VO2_FUNREQ
		   cCPgVSC := "___"
		EndIf
	Else
   	If SF2->F2_TIPO # "N"
			(cAliasVSC)->(Dbskip())
			loop
   	EndIf
   	If (cAliasVSC)->(VOI_SITTPO) # "3"
		   nSvalser:= If( MV_PAR03 == 1 , (cAliasVSC)->(VSC_VALSER) , If( MV_PAR03 == 2 , (cAliasVSC)->(VSC_VMFSER) , xmoeda((cAliasVSC)->(VSC_VALSER),1,MV_PAR03,DDataBase)))
		Else
			lDuplic := .f.
			nSvalser:= VO4->VO4_VALINT
      EndIf
	   cCliVSC := SF2->F2_CLIENTE
   	cLojVSC := SF2->F2_LOJA
	   cVenVSC := SF2->F2_VEND1
	   cCPgVSC := SF2->F2_COND
		// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
		na := ( SF2->F2_BASEISS / SF2->F2_VALBRUT )
		nk := ( (cAliasVSC)->(VSC_VALSER) / SF2->F2_BASEISS )

		cPrefSE1 := SF2->F2_PREFIXO
		cDuplSE1 := SF2->F2_DUPL
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
			nVprzmd1 += ( ( nk * ( (cAliasSE1)->(E1_VALOR) * na ) ) * ( stod((cAliasSE1)->(E1_VENCTO)) - SF2->F2_EMISSAO ) ) 
			nVprzmd2 += ( nk * ( (cAliasSE1)->(E1_VALOR) * na )  )
			If Alltrim((cAliasSE1)->(E1_TIPO)) == "CD" // CDCI - sem prazo medio
				nVprzmd1 := 0
			EndIf
			(cAliasSE1)->(Dbskip())
		EndDo         
		(cAliasSE1)->(DBCloseArea())
	
	EndIf
	nSvaliss := If( MV_PAR03 == 1 , (cAliasVSC)->(VSC_VALISS) , If( MV_PAR03 == 2 , (cAliasVSC)->(VSC_VMFISS) , xmoeda((cAliasVSC)->(VSC_VALISS),1,MV_PAR03,DDataBase)))
   nSvalpis := If( MV_PAR03 == 1 , (cAliasVSC)->(VSC_VALPIS) , If( MV_PAR03 == 2 , (cAliasVSC)->(VSC_VMFPIS) , xmoeda((cAliasVSC)->(VSC_VALPIS),1,MV_PAR03,DDataBase)))
  	nSvalcof := If( MV_PAR03 == 1 , (cAliasVSC)->(VSC_VALCOF) , If( MV_PAR03 == 2 , (cAliasVSC)->(VSC_VMFCOF) , xmoeda((cAliasVSC)->(VSC_VALCOF),1,MV_PAR03,DDataBase)))
   nStotimp := If( MV_PAR03 == 1 , (cAliasVSC)->(VSC_TOTIMP) , If( MV_PAR03 == 2 , (cAliasVSC)->(VSC_TMFIMP) , xmoeda((cAliasVSC)->(VSC_TOTIMP),1,MV_PAR03,DDataBase)))
   nScusser := If( MV_PAR03 == 1 , (cAliasVSC)->(VSC_CUSSER) , If( MV_PAR03 == 2 , (cAliasVSC)->(VSC_CMFSER) , xmoeda((cAliasVSC)->(VSC_CUSSER),1,MV_PAR03,DDataBase)))
   nSlucbru := If( MV_PAR03 == 1 , (cAliasVSC)->(VSC_LUCBRU) , If( MV_PAR03 == 2 , (cAliasVSC)->(VSC_LMFBRU) , xmoeda((cAliasVSC)->(VSC_LUCBRU),1,MV_PAR03,DDataBase)))
   nSdesvar := If( MV_PAR03 == 1 , (cAliasVSC)->(VSC_DESVAR) , If( MV_PAR03 == 2 , (cAliasVSC)->(VSC_DMFVAR) , xmoeda((cAliasVSC)->(VSC_DESVAR),1,MV_PAR03,DDataBase)))
   nScomven := If( MV_PAR03 == 1 , ((cAliasVSC)->(VSC_COMVEN)+(cAliasVSC)->(VSC_COMGER)) , If( MV_PAR03 == 2 , ((cAliasVSC)->(VSC_CMFVEN)+(cAliasVSC)->(VSC_CMFGER)) , xmoeda(((cAliasVSC)->(VSC_COMVEN)+(cAliasVSC)->(VSC_COMGER)),1,MV_PAR03,DDataBase)))
   nSlucliq := If( MV_PAR03 == 1 , (cAliasVSC)->(VSC_LUCLIQ) , If( MV_PAR03 == 2 , (cAliasVSC)->(VSC_LMFLIQ) , xmoeda((cAliasVSC)->(VSC_LUCLIQ),1,MV_PAR03,DDataBase)))
   nSdesfix := If( MV_PAR03 == 1 , ((cAliasVSC)->(VSC_DESFIX)+(cAliasVSC)->(VSC_CUSFIX)) , If( MV_PAR03 == 2 , ((cAliasVSC)->(VSC_DMFFIX)+(cAliasVSC)->(VSC_CMFFIX)) , xmoeda(((cAliasVSC)->(VSC_DESFIX)+(cAliasVSC)->(VSC_CUSFIX)),1,MV_PAR03,DDataBase)))
   nSdesadm := If( MV_PAR03 == 1 , ((cAliasVSC)->(VSC_DESADM)+(cAliasVSC)->(VSC_DESDEP)) , If( MV_PAR03 == 2 , ((cAliasVSC)->(VSC_DMFADM)+(cAliasVSC)->(VSC_DMFDEP)) , xmoeda(((cAliasVSC)->(VSC_DESADM)+(cAliasVSC)->(VSC_DESDEP)),1,MV_PAR03,DDataBase)))
   nSresfin := If( MV_PAR03 == 1 , (cAliasVSC)->(VSC_RESFIN) , If( MV_PAR03 == 2 , (cAliasVSC)->(VSC_RMFFIN) , xmoeda((cAliasVSC)->(VSC_RESFIN),1,MV_PAR03,DDataBase)))
   nSdescon := If( MV_PAR03 == 1 , (cAliasVSC)->(VSC_VALDES) , If( MV_PAR03 == 2 , (cAliasVSC)->(VSC_VMFDES) , xmoeda((cAliasVSC)->(VSC_VALDES),1,MV_PAR03,DDataBase)))
	If !Empty(Alltrim((cAliasVSC)->(VSC_NUMNFI)+(cAliasVSC)->(VSC_SERNFI)))
		DbSelectArea( "VOO" )
		DbSetOrder(4)
		DbSeek( xFilial("VOO") + (cAliasVSC)->(VSC_NUMNFI) + (cAliasVSC)->(VSC_SERNFI) )
	Else
		DbSelectArea( "VOO" )
		DbSetOrder(1)
		DbSeek( xFilial("VOO") + (cAliasVSC)->(VSC_NUMOSV) + (cAliasVSC)->(VSC_TIPTEM) )
	EndIf
	nPos := 0
	nPos := aScan(aDpto,{|x| x[1]+x[17]+x[18] == VOO->VOO_DEPTO+"S"+(cAliasVSC)->(VOI_SITTPO) })
	If nPos == 0
		DbSelectArea( "VAP" )
		DbSetOrder(1)
		DbSeek( xFilial("VAP") + VOO->VOO_DEPTO )
		// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
		aAdd(aDpto,{ VOO->VOO_DEPTO , nSvalser , nStotimp , nSvaliss , nSvalpis , nSvalcof , nScusser , nSlucbru , nSdesvar , nScomven , nSlucliq , nSdesfix , nSdesadm , nSresfin , 0 , left(Alltrim(VAP->VAP_DESDEP)+repl(".",21),21) , "S" , (cAliasVSC)->(VOI_SITTPO), nVPrzMd1, nVPrzMd2, nSdescon })
	Else
	 	aDpto[nPos,2]  += nSvalser
	 	aDpto[nPos,3]  += nStotimp
	 	aDpto[nPos,4]  += nSvaliss
	 	aDpto[nPos,5]  += nSvalpis
	 	aDpto[nPos,6]  += nSvalcof
	 	aDpto[nPos,7]  += nScusser
 		aDpto[nPos,8]  += nSlucbru
	 	aDpto[nPos,9]  += nSdesvar
	 	aDpto[nPos,10] += nScomven
	 	aDpto[nPos,11] += nSlucliq
	 	aDpto[nPos,12] += nSdesfix
	 	aDpto[nPos,13] += nSdesadm
	 	aDpto[nPos,14] += nSresfin
		// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
	 	aDpto[nPos,19] += nVPrzMd1
	 	aDpto[nPos,20] += nVPrzMd2
		// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
	 	aDpto[nPos,21] += nSdescon
	EndIf
   nPos := 0
	If ( MV_PAR05 == 1 .or. ( MV_PAR05 == 2 .and. MV_PAR04 # 3 .and. MV_PAR04 # 4 ))
		If MV_PAR04 == 4 // Por SECAO
			nPos := aScan(aNumSrv,{|x| x[1] + x[2] + x[17] == (cAliasVSC)->(VOI_SITTPO) + VO4->VO4_CODSEC + VOO->VOO_DEPTO })
		Else // Por Grupo
			nPos := aScan(aNumSrv,{|x| x[1] + x[2] + x[17] == (cAliasVSC)->(VOI_SITTPO) + (cAliasVSC)->(VSC_TIPSER) + VOO->VOO_DEPTO })
		EndIf
	Else                                                          
		nPos := aScan(aNumSrv,{|x| x[1] + x[2] + x[17] == (cAliasVSC)->(VOI_SITTPO) + cCliVSC + VOO->VOO_DEPTO })
	EndIf	
	If nPos == 0
		If ( MV_PAR05 == 1 .or. ( MV_PAR05 == 2 .and. MV_PAR04 # 3 .and. MV_PAR04 # 4 ))
			If MV_PAR04 == 4 // Por SECAO
			 	DbSelectArea( "VOD" )
				DbSetOrder(1)
				DbSeek( xFilial("VOD") + VO4->VO4_CODSEC , .f. )
				aAdd(aNumSrv,{ (cAliasVSC)->(VOI_SITTPO) , VO4->VO4_CODSEC , VOD->VOD_DESSEC , nSvalser , nStotimp , nSvaliss , nSvalpis , nSvalcof , nScusser , nSlucbru , nSdesvar , nScomven , nSlucliq , nSdesfix , nSdesadm , nSresfin , VOO->VOO_DEPTO, nVPrzMd1, nVPrzMd2, nSdescon }) 
			Else // Por Grupo
			 	DbSelectArea( "VOK" )
				DbSetOrder(1)
				DbSeek( xFilial("VOK") + (cAliasVSC)->(VSC_TIPSER) , .f. )
				// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
				aAdd(aNumSrv,{ (cAliasVSC)->(VOI_SITTPO) , (cAliasVSC)->(VSC_TIPSER) , VOK->VOK_DESSER , nSvalser , nStotimp , nSvaliss , nSvalpis , nSvalcof , nScusser , nSlucbru , nSdesvar , nScomven , nSlucliq , nSdesfix , nSdesadm , nSresfin , VOO->VOO_DEPTO, nVPrzMd1, nVPrzMd2, nSdescon }) 
			EndIf
			If Type("aAnaSrv") == "A" .and. (cAliasVSC)->(VOI_SITTPO) != "3" // So leva se nao for Tipo Interno
	 		 	DbSelectArea( "SA1" )
				DbSetOrder(1)
				DbSeek( xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA )
				aadd(aAnaSrv,{SM0->M0_CODIGO,SM0->M0_CODFIL,SF2->F2_DOC,SF2->F2_SERIE,"SV",SA1->A1_COD+SA1->A1_LOJA+LEFT(SA1->A1_NREDUZ,20),(cAliasVSC)->(VSC_TIPSER) , VOK->VOK_DESSER ,VOK->VOK_DESSER,nSValSer,nSTotImp,nSCusSer,SF2->F2_EMISSAO})
			Endif	
		Else                                                          
	 	 	DbSelectArea( "SA1" )
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + cCliVSC + cLojVSC , .f. )
			// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
			aAdd(aNumSrv,{ (cAliasVSC)->(VOI_SITTPO) , cCliVSC , left(SA1->A1_NOME,20) , nSvalser , nStotimp , nSvaliss , nSvalpis , nSvalcof , nScusser , nSlucbru , nSdesvar , nScomven , nSlucliq , nSdesfix , nSdesadm , nSresfin , VOO->VOO_DEPTO, nVPrzMd1, nVPrzMd2, nSdescon }) 
			If Type("aAnaSrv") == "A" .and. (cAliasVSC)->(VOI_SITTPO) != "3" // So leva se nao for Tipo Interno
				aadd(aAnaSrv,{SM0->M0_CODIGO,SM0->M0_CODFIL,SF2->F2_DOC,SF2->F2_SERIE,"SV",SA1->A1_COD+SA1->A1_LOJA+LEFT(SA1->A1_NREDUZ,20),(cAliasVSC)->(VSC_TIPSER) , VOK->VOK_DESSER ,VOK->VOK_DESSER,nSValSer,nSTotImp,nSCusSer,SF2->F2_EMISSAO})
			Endif	
		EndIf	
	Else
	 	aNumSrv[nPos,4]  += nSvalser 
	 	aNumSrv[nPos,5]  += nStotimp
	 	aNumSrv[nPos,6]  += nSvaliss
	 	aNumSrv[nPos,7]  += nSvalpis
	 	aNumSrv[nPos,8]  += nSvalcof
	 	aNumSrv[nPos,9]  += nScusser
	 	aNumSrv[nPos,10] += nSlucbru
	 	aNumSrv[nPos,11] += nSdesvar
	 	aNumSrv[nPos,12] += nScomven 
	 	aNumSrv[nPos,13] += nSlucliq 
	 	aNumSrv[nPos,14] += nSdesfix
	 	aNumSrv[nPos,15] += nSdesadm
	 	aNumSrv[nPos,16] += nSresfin 
		// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
	 	aNumSrv[nPos,18] += nVPrzMd1
	 	aNumSrv[nPos,19] += nVPrzMd2
		// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
	 	aNumSrv[nPos,20] += nSdescon
		If ( MV_PAR05 == 1 .or. ( MV_PAR05 == 2 .and. MV_PAR04 # 3 .and. MV_PAR04 # 4 ))
			If Type("aAnaSrv") == "A" .and. (cAliasVSC)->(VOI_SITTPO) != "3" // So leva se nao for Tipo Interno
	 		 	DbSelectArea( "SA1" )
				DbSetOrder(1)
				DbSeek( xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA )
				aadd(aAnaSrv,{SM0->M0_CODIGO,SM0->M0_CODFIL,SF2->F2_DOC,SF2->F2_SERIE,"SV",SA1->A1_COD+SA1->A1_LOJA+LEFT(SA1->A1_NREDUZ,20),(cAliasVSC)->(VSC_TIPSER) , VOK->VOK_DESSER ,VOK->VOK_DESSER,nSValSer,nSTotImp,nSCusSer,SF2->F2_EMISSAO})
			Endif	
		Else                                                          
	 	 	DbSelectArea( "SA1" )
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + cCliVSC + cLojVSC , .f. )
			If Type("aAnaSrv") == "A" .and. (cAliasVSC)->(VOI_SITTPO) != "3" // So leva se nao for Tipo Interno
				aadd(aAnaSrv,{SM0->M0_CODIGO,SM0->M0_CODFIL,SF2->F2_DOC,SF2->F2_SERIE,"SV",SA1->A1_COD+SA1->A1_LOJA+LEFT(SA1->A1_NREDUZ,20),(cAliasVSC)->(VSC_TIPSER) , VOK->VOK_DESSER , VOK->VOK_DESSER ,nSValSer,nSTotImp,nSCusSer,SF2->F2_EMISSAO})
			Endif	
		Endif
	EndIf
   nPos := 0
	nPos := aScan(aGrpSrv,{|x| x[1] == (cAliasVSC)->(VOI_SITTPO) })
	If nPos == 0
		// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
		aAdd(aGrpSrv,{ (cAliasVSC)->(VOI_SITTPO) , nSvalser , nStotimp , nSvaliss , nSvalpis , nSvalcof , nScusser , nSlucbru , nSdesvar , nScomven , nSlucliq , nSdesfix , nSdesadm , nSresfin, nVPrzMd1, nVPrzMd2, nSdescon }) 
	Else
	 	aGrpSrv[nPos,2]  += nSvalser
	 	aGrpSrv[nPos,3]  += nStotimp
	 	aGrpSrv[nPos,4]  += nSvaliss
	 	aGrpSrv[nPos,5]  += nSvalpis
	 	aGrpSrv[nPos,6]  += nSvalcof
	 	aGrpSrv[nPos,7]  += nScusser
	 	aGrpSrv[nPos,8]  += nSlucbru
	 	aGrpSrv[nPos,9]  += nSdesvar
	 	aGrpSrv[nPos,10] += nScomven 
	 	aGrpSrv[nPos,11] += nSlucliq 
	 	aGrpSrv[nPos,12] += nSdesfix
	 	aGrpSrv[nPos,13] += nSdesadm
	 	aGrpSrv[nPos,14] += nSresfin 
		// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
	 	aGrpSrv[nPos,15] += nVPrzMd1
	 	aGrpSrv[nPos,16] += nVPrzMd2
		// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
	 	aGrpSrv[nPos,17] += nSdescon
	EndIf
	If (cAliasVSC)->(VOI_SITTPO) # "3"
	 	aTotSrv[1,1]  += nSvalser
	 	aTotSrv[1,2]  += nStotimp
	 	aTotSrv[1,3]  += nSvaliss
	 	aTotSrv[1,4]  += nSvalpis
		aTotSrv[1,5]  += nSvalcof
		aTotSrv[1,6]  += nScusser
		aTotSrv[1,7]  += nSlucbru
		aTotSrv[1,8]  += nSdesvar
		aTotSrv[1,9]  += nScomven
		aTotSrv[1,10] += nSlucliq
		aTotSrv[1,11] += nSdesfix
		aTotSrv[1,12] += nSdesadm
		aTotSrv[1,13] += nSresfin
		// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
		aTotSrv[1,14] += nVPrzMd1
		aTotSrv[1,15] += nVPrzMd2
		// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
	 	aTotSrv[1,16] += nSdescon
	 	aTotal[1,1]  += nSvalser
	 	aTotal[1,2]  += nStotimp
	 	aTotal[1,4]  += nSvaliss
	 	aTotal[1,5]  += nSvalpis
		aTotal[1,6]  += nSvalcof
		aTotal[1,7]  += nScusser
		aTotal[1,9]  += nSlucbru
		aTotal[1,10] += nSdesvar
		aTotal[1,11] += nScomven
		aTotal[1,12] += nSlucliq
		aTotal[1,13] += nSdesfix
		aTotal[1,14] += nSdesadm
		aTotal[1,15] += nSresfin
		// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
		aTotal[1,16] += nVPrzMd1
		aTotal[1,17] += nVPrzMd2
		// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
	 	aTotal[1,18] += nSdescon
	Endif
	If MV_PAR06 # 1
	 	aTotCon[1,1]  += nSvalser
	 	aTotCon[1,2]  += nStotimp
	 	aTotCon[1,4]  += nSvaliss
	 	aTotCon[1,5]  += nSvalpis
		aTotCon[1,6]  += nSvalcof
		aTotCon[1,7]  += nScusser
		aTotCon[1,9]  += nSlucbru
		aTotCon[1,10] += nSdesvar
		aTotCon[1,11] += nScomven
		aTotCon[1,12] += nSlucliq
		aTotCon[1,13] += nSdesfix
		aTotCon[1,14] += nSdesadm
		aTotCon[1,15] += nSresfin
		// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
		aTotCon[1,16] += nVPrzMd1
		aTotCon[1,17] += nVPrzMd2
		// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
	 	aTotCon[1,18] += nSdescon
   	nPos := 0
		nPos := aScan(aGrpPag,{|x| x[1] == cCPgVSC })
		If nPos == 0    
			DbSelectArea( "SE4" )
			DbSetOrder(1)
			DbSeek( xFilial("SE4") + cCPgVSC )
			// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
			aAdd(aGrpPag,{ cCPgVSC , If(!empty(SE4->E4_DESCRI),SE4->E4_DESCRI,STR0028) , nSvalser , nStotimp , 0 , nSvaliss , nSvalpis , nSvalcof , nScusser , 0 , nSlucbru , nSdesvar , nScomven , nSlucliq , nSdesfix , nSdesadm , nSresfin , nVPrzMd1 , nVPrzMd2, nSdescon }) 
		Else
		 	aGrpPag[nPos,3]  += nSvalser
	 		aGrpPag[nPos,4]  += nStotimp 
 			aGrpPag[nPos,6]  += nSvaliss
	 		aGrpPag[nPos,7]  += nSvalpis
	 		aGrpPag[nPos,8]  += nSvalcof
		 	aGrpPag[nPos,9]  += nScusser
		 	aGrpPag[nPos,11] += nSlucbru
 			aGrpPag[nPos,12] += nSdesvar
		 	aGrpPag[nPos,13] += nScomven
		 	aGrpPag[nPos,14] += nSlucliq
		 	aGrpPag[nPos,15] += nSdesfix
 			aGrpPag[nPos,16] += nSdesadm
	 		aGrpPag[nPos,17] += nSresfin
			// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
			aGrpPag[nPos,18] += nVPrzMd1
			aGrpPag[nPos,19] += nVPrzMd2
			// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
		 	aGrpPag[nPos,20] += nSdescon
		EndIf
		cAliasVAI := GetNextAlias()
		BeginSql Alias cAliasVAI
			SELECT VAI.VAI_CC
			FROM %Table:VAI% VAI
			WHERE VAI.VAI_FILIAL = %xFilial:VAI% 
			AND VAI.%NotDel%
			AND VAI.VAI_CODVEN = %Exp:cVenVSC%
		EndSql
  		nPos := 0
		If MV_PAR06 # 3
			nPos := aScan(aTotPag,{|x| x[1]+x[2] == cCPgVSC + If(lDuplic,"E","I")+cVenVSC })
		Else     
			nPos := aScan(aTotPag,{|x| x[1]+x[2] == cCPgVSC + If(lDuplic,"E","I")+(cAliasVAI)->( VAI_CC )})				
		EndIf
		If nPos == 0 .or. MV_PAR06 == 4
			If MV_PAR06 # 3
				DbSelectArea( "SA3" )
				DbSetOrder(1)
				DbSeek( xFilial("SA3") + cVenVSC )
				// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
				aAdd(aTotPag,{ cCPgVSC , If(lDuplic,"E","I")+cVenVSC , left(SA3->A3_NOME,17) , nSvalser , nStotimp , 0 , nSvaliss , nSvalpis , nSvalcof , nScusser , 0 , nSlucbru , nSdesvar , nScomven , nSlucliq , nSdesfix , nSdesadm , nSresfin, nVPrzMd1, nVPrzMd2, nSdescon }) 
				nPos3 := 0
				nPos3 := aScan(aCCVend,{|x| x[1]+x[2] == If(lDuplic,"E","I")+(cAliasVAI)->( VAI_CC )+ cVenVSC })
				If nPos3 == 0            
					DbSelectArea( "CTT" )
					DbSetOrder(1)
					DbSeek( xFilial("CTT") + (cAliasVAI)->( VAI_CC ))
					// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
					aAdd(aCCVend,{ If(lDuplic,"E","I")+(cAliasVAI)->( VAI_CC ) , cVenVSC , left(SA3->A3_NOME,17) , nSvalser , nStotimp , 0 , nSvaliss , nSvalpis , nSvalcof , nScusser , 0 , nSlucbru , nSdesvar , nScomven , nSlucliq , nSdesfix , nSdesadm , nSresfin , If(lDuplic,"Ext ","Int ")+left(CTT->CTT_DESC01,21), nVPrzMd1, nVPrzMd2, nSdescon })
				Else           
				 	aCCVend[nPos3,4]  += nSvalser
		 			aCCVend[nPos3,5]  += nStotimp
     			 	aCCVend[nPos3,7]  += nSvaliss
				 	aCCVend[nPos3,8]  += nSvalpis
				 	aCCVend[nPos3,9]  += nSvalcof
				 	aCCVend[nPos3,10] += nScusser
	 				aCCVend[nPos3,12] += nSlucbru
			 		aCCVend[nPos3,13] += nSdesvar
				 	aCCVend[nPos3,14] += nScomven
				 	aCCVend[nPos3,15] += nSlucliq
				 	aCCVend[nPos3,16] += nSdesfix
		 			aCCVend[nPos3,17] += nSdesadm
			 		aCCVend[nPos3,18] += nSresfin
					// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
			 		aCCVend[nPos3,20] += nVPrzMd1
			 		aCCVend[nPos3,21] += nVPrzMd2
					// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
				 	aCCVend[nPos3,22] += nSdescon
				EndIf
				nPos3 := 0
				nPos3 := aScan(aTotCCV,{|x| x[1] == If(lDuplic,"E","I")+(cAliasVAI)->( VAI_CC ) })
				If nPos3 == 0
					// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
					aAdd(aTotCCV,{ If(lDuplic,"E","I")+(cAliasVAI)->( VAI_CC ) , nSvalser , nStotimp , 0 , nSvaliss , nSvalpis , nSvalcof , nScusser , 0 , nSlucbru , nSdesvar , nScomven , nSlucliq , nSdesfix , nSdesadm , nSresfin, nVPrzMd1, nVPrzMd2, nSdescon }) 
            Else           
				 	aTotCCV[nPos3,2]  += nSvalser
					aTotCCV[nPos3,3]  += nStotimp
     			 	aTotCCV[nPos3,5]  += nSvaliss
				 	aTotCCV[nPos3,6]  += nSvalpis
				 	aTotCCV[nPos3,7]  += nSvalcof
				 	aTotCCV[nPos3,8]  += nScusser
		 			aTotCCV[nPos3,10] += nSlucbru
					aTotCCV[nPos3,11] += nSdesvar
				 	aTotCCV[nPos3,12] += nScomven
				 	aTotCCV[nPos3,13] += nSlucliq
				 	aTotCCV[nPos3,14] += nSdesfix
					aTotCCV[nPos3,15] += nSdesadm
				 	aTotCCV[nPos3,16] += nSresfin
					// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
				 	aTotCCV[nPos3,17] += nVPrzMd1
				 	aTotCCV[nPos3,18] += nVPrzMd2
					// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
				 	aTotCCV[nPos3,19] += nSdescon
  	   		EndIf
			Else     
				DbSelectArea( "CTT" )
				DbSetOrder(1)
				DbSeek( xFilial("CTT") + (cAliasVAI)->( VAI_CC ) )
				// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
				aAdd(aTotPag,{ cCPgVSC , If(lDuplic,"E","I")+(cAliasVAI)->( VAI_CC ) , left(CTT->CTT_DESC01,14) , nSvalser , nStotimp , 0 , nSvaliss , nSvalpis , nSvalcof , nScusser , 0 , nSlucbru , nSdesvar , nScomven , nSlucliq , nSdesfix , nSdesadm , nSresfin, nVPrzMd1, nVPrzMd2, nSdescon }) 
			EndIf
		Else
		 	aTotPag[nPos,4]  += nSvalser
		 	aTotPag[nPos,5]  += nStotimp
		 	aTotPag[nPos,7]  += nSvaliss
		 	aTotPag[nPos,8]  += nSvalpis
		 	aTotPag[nPos,9]  += nSvalcof
	 		aTotPag[nPos,10] += nScusser
		 	aTotPag[nPos,12] += nSlucbru
		 	aTotPag[nPos,13] += nSdesvar
	 		aTotPag[nPos,14] += nScomven
		 	aTotPag[nPos,15] += nSlucliq
		 	aTotPag[nPos,16] += nSdesfix
		 	aTotPag[nPos,17] += nSdesadm
	 		aTotPag[nPos,18] += nSresfin
			// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
	 		aTotPag[nPos,19] += nVPrzMd1
	 		aTotPag[nPos,20] += nVPrzMd2
			// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
		 	aTotPag[nPos,21] += nSdescon
		EndIf
	   nPos := 0 
		nPos := aScan(aPecSrvOfi,{|x| x[1]+x[2]+x[4] == cCPgVSC + If(lDuplic,"E","I")+If(MV_PAR06#3,cVenVSC,(cAliasVAI)->( VAI_CC )) + If(lDuplic,"Ext ","Int ")+left(STR0063,18) })
		If nPos == 0
			DbSelectArea( "SA1" )
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + cCliVSC + cLojVSC )
   		aAdd(aPecSrvOfi,{ cCPgVSC , If(lDuplic,"E","I")+If(MV_PAR06#3,cVenVSC,(cAliasVAI)->( VAI_CC )) , nSvalser , If(lDuplic,"Ext ","Int ")+left(STR0063,18) })
		Else
   		aPecSrvOfi[nPos,3] += nSvalser
		EndIf			
	   nPos := 0
		nPos := aScan(aConPagNF,{|x| x[1]+x[2]+x[3]+x[4]+x[7] == cCPgVSC + If(lDuplic,"E","I")+If(MV_PAR06#3,cVenVSC,(cAliasVAI)->( VAI_CC )) + (cAliasVSC)->(VSC_NUMNFI) + (cAliasVSC)->(VSC_SERNFI) + If(lDuplic,"Ext ","Int ")+left(STR0063,18) })
   	If nPos == 0
			DbSelectArea( "SA1" )
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + cCliVSC + cLojVSC )
			aAdd(aConPagNF,{ cCPgVSC , If(lDuplic,"E","I")+If(MV_PAR06#3,cVenVSC,(cAliasVAI)->( VAI_CC )) , (cAliasVSC)->(VSC_NUMNFI) , (cAliasVSC)->(VSC_SERNFI) , left(SA1->A1_NOME,10) , nSvalser , If(lDuplic,"Ext ","Int ")+left(STR0063,18) })
		Else
   		aConPagNF[nPos,6] += nSvalser
		EndIf                    
		(cAliasVAI)->(DBCloseArea())
	EndIf
	(cAliasVSC)->(Dbskip())
EndDo
(cAliasVSC)->(DBCloseArea())
Return
