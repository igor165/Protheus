#Include "OFIOR250.CH"
#Include "Protheus.ch"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ FS_OR250 ≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 03/01/02 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Continua carregando o OFIOR250, pois nao estava compilando ≥±±
±±≥          ≥ na versao 609 devido ao numero alto de variaveis e vetores ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Atualizacao: PIS/COFINS da Desp. Acess. esta sendo somado no Depto de  ≥±±
±±≥             Origem, apos 21/05/04, 25/05/04 e 26/05/04.               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function FS_OR250()
Local cChave   := ""
Local cSF2Soma := ""
Local lDuplic  := .f. 
Local lEntrada := .f.
Local nCofins  := nCofDesp := nPisDesp := nVPisDesp := nVCofDesp := nVlrDev := nPisDev := nCofDev := nImpDev := nPisOOpe := nCofOOpe := 0
Local cDpto    := "   "
Local ii       := 0
Local cPrefBAL := GetNewPar("MV_PREFBAL","BAL")
Local cPrefOFI := GetNewPar("MV_PREFOFI","OFI")
Local cPrefVEI := GetNewPar("MV_PREFVEI","VEI")
Local cPBcoCXA := GetNewPar("MV_BCOCXA","   ")

///////////////////////////////////
//   O U T R A S   V E N D A S   //
///////////////////////////////////
If FunName() == "OFIOR250"
	IncProc(STR0098)//Selecionando Outras Operacoes...
	IncProc(STR0098)//Selecionando Outras Operacoes...
	IncProc(STR0098)//Selecionando Outras Operacoes...		
EndIf

cAliasSF2 := GetNextAlias()
BeginSql Alias cAliasSF2
	SELECT SF2.*, VS1.VS1_NUMORC , VV0.VV0_NUMTRA
	FROM %Table:SF2% SF2 
	LEFT OUTER JOIN  %Table:VS1% VS1
		ON (SF2.F2_DOC = VS1.VS1_NUMNFI 
		AND SF2.F2_SERIE = VS1.VS1_SERNFI
		AND VS1.VS1_FILIAL = %xFilial:VS1%
		AND SF2.D_E_L_E_T_ = VS1.D_E_L_E_T_)
	LEFT OUTER JOIN %Table:VV0% VV0
		ON (SF2.F2_DOC = VV0.VV0_NUMNFI 
		AND SF2.F2_SERIE = VV0.VV0_SERNFI
		AND VV0.VV0_FILIAL = %xFilial:VV0%
		AND SF2.D_E_L_E_T_ = VV0.D_E_L_E_T_)
	WHERE SF2.F2_FILIAL = %xFilial:SF2% 
		AND SF2.%NotDel%
		AND VS1.%NotDel%
		AND VV0.%NotDel%
		AND SF2.F2_EMISSAO >= %Exp:MV_PAR01%
		AND SF2.F2_EMISSAO <= %Exp:MV_PAR02%
		AND (SF2.F2_TIPO = 'N' OR SF2.F2_TIPO = 'C')
EndSql
If FunName() == "OFIOR250"
	IncProc(STR0099)//Totalizando Outras Operacoes...
	IncProc(STR0099)//Totalizando Outras Operacoes...
	IncProc(STR0099)//Totalizando Outras Operacoes...
EndIf
While !((cAliasSF2)->(Eof()))
	nCofins := nCof
	
	///////////////////////////////////
	//V A L O R E S   E N T R A D A S//
	///////////////////////////////////
	
	If MV_PAR07 == 1
		If (cAliasSF2)->(F2_PREFORI) == cPrefOFI
			cChave := (cAliasSF2)->(F2_DOC)+space(TamSx3("F2_DOC")[1]-Len(AllTrim((cAliasSF2)->(F2_DOC))))
		ElseIf (cAliasSF2)->(F2_PREFORI) == cPrefBAL
			cChave := "OR" + (cAliasSF2)->(VS1_NUMORC)
			cPrefSE1 := (cAliasSF2)->(F2_PREFORI)
			cDuplSE1 := (cAliasSF2)->(F2_DUPL)
			cAliasSE1 := GetNextAlias()
			BeginSql Alias cAliasSE1
				SELECT COUNT(SE1.R_E_C_N_O_) NRO
				FROM %Table:SE1% SE1
				WHERE SE1.E1_FILIAL = %xFilial:SE1% 
				AND SE1.%NotDel%
				AND SE1.E1_PREFORI = %Exp:cPrefSE1%
				AND SE1.E1_NUM = %Exp:cDuplSE1%
				AND SE1.E1_TIPO = 'CD'
			EndSql
		   if (cAliasSE1)->(NRO) > 0
			   cChave := "CD"+(cAliasSF2)->(VS1_NUMORC)
		   endif
			(cAliasSE1)->(DBCloseArea())
		Else // (cAliasSF2)->(F2_PREFORI) == cPrefVEI
			cChave := (cAliasSF2)->(VV0_NUMTRA)
		EndIf
		lEntrada := .f.
		cAliasVS9 := GetNextAlias()
		BeginSql Alias cAliasVS9
			SELECT *
			FROM %Table:VS9% VS9 
			WHERE VS9.VS9_FILIAL = %xFilial:VS9% 
			AND VS9.%NotDel%
			AND LTRIM(RTRIM(VS9.VS9_NUMIDE)) = %Exp:cChave%
			AND VS9.VS9_ENTRAD = 'S'
			AND VS9.VS9_PORTAD = %Exp:cPBcoCXA% 
			AND VS9.VS9_TIPPAG <> 'DP'
		EndSql
		While !( (cAliasVS9)->(Eof()) ) 
			lEntrada := .t.
			aTotEnt[1,1] += (cAliasVS9)->(VS9_VALPAG)
			nPos := 0
			nPos := aScan(aGrpEnt,{|x| x[1] == (cAliasVS9)->(VS9_TIPOPE) })
			If nPos # 0
				aGrpEnt[nPos,3] += (cAliasVS9)->(VS9_VALPAG)
			EndIf
			nPos := 0
			nPos := aScan(aNumEnt,{|x| x[1]+x[2] == (cAliasVS9)->(VS9_TIPOPE) + (cAliasVS9)->(VS9_TIPPAG) })
			If nPos == 0
				DbSelectArea( "VSA" )
				DbSetOrder(1)
				DbSeek( xFilial("VSA") + (cAliasVS9)->(VS9_TIPPAG ))
				aAdd(aNumEnt,{ (cAliasVS9)->(VS9_TIPOPE) , (cAliasVS9)->(VS9_TIPPAG) , VSA->VSA_DESPAG , (cAliasVS9)->(VS9_VALPAG) })
			Else
				aNumEnt[nPos,4] += (cAliasVS9)->(VS9_VALPAG)
			EndIf
			nPos := 0
			nPos := aScan(aEntrad,{|x| x[1] == (cAliasVS9)->(VS9_TIPPAG )})
			If nPos == 0
				DbSelectArea( "VSA" )
				DbSetOrder(1)
				DbSeek( xFilial("VSA") + (cAliasVS9)->(VS9_TIPPAG ))
				aAdd(aEntrad,{ (cAliasVS9)->(VS9_TIPPAG) , VSA->VSA_DESPAG , (cAliasVS9)->(VS9_VALPAG) })
			Else
				aEntrad[nPos,3] += (cAliasVS9)->(VS9_VALPAG)
			EndIf
			(cAliasVS9)->(Dbskip())
		EndDo
		(cAliasVS9)->(DBCloseArea())
      //
		If !(lEntrada) .and. left(cChave,2) == "CD"
			cChave := "OR" + substr(cChave,3,8)
			cAliasVS9 := GetNextAlias()
			BeginSql Alias cAliasVS9
				SELECT *
				FROM %Table:VS9% VS9 
				WHERE VS9.VS9_FILIAL = %xFilial:VS9% 
				AND VS9.%NotDel%
				AND LTRIM(RTRIM(VS9.VS9_NUMIDE)) = %Exp:cChave%
				AND VS9.VS9_ENTRAD = 'S'
				AND VS9.VS9_PORTAD = %Exp:cPBcoCXA% 
				AND VS9.VS9_TIPPAG <> 'DP'
			EndSql
			While !( (cAliasVS9)->(Eof()) )
				aTotEnt[1,1] += (cAliasVS9)->(VS9_VALPAG)
				nPos := 0
				nPos := aScan(aGrpEnt,{|x| x[1] == (cAliasVS9)->(VS9_TIPOPE) })
				If nPos # 0
					aGrpEnt[nPos,3] += (cAliasVS9)->(VS9_VALPAG)
				EndIf
				nPos := 0
				nPos := aScan(aNumEnt,{|x| x[1]+x[2] == (cAliasVS9)->(VS9_TIPOPE) + (cAliasVS9)->(VS9_TIPPAG) })
				If nPos == 0
					DbSelectArea( "VSA" )
					DbSetOrder(1)
					DbSeek( xFilial("VSA") + (cAliasVS9)->(VS9_TIPPAG ))
					aAdd(aNumEnt,{ (cAliasVS9)->(VS9_TIPOPE) , (cAliasVS9)->(VS9_TIPPAG) , VSA->VSA_DESPAG , (cAliasVS9)->(VS9_VALPAG) })
				Else
					aNumEnt[nPos,4] += (cAliasVS9)->(VS9_VALPAG)
				EndIf
				nPos := 0
				nPos := aScan(aEntrad,{|x| x[1] == (cAliasVS9)->(VS9_TIPPAG )})
				If nPos == 0
					DbSelectArea( "VSA" )
					DbSetOrder(1)
					DbSeek( xFilial("VSA") + (cAliasVS9)->(VS9_TIPPAG ))
					aAdd(aEntrad,{ (cAliasVS9)->(VS9_TIPPAG) , VSA->VSA_DESPAG , (cAliasVS9)->(VS9_VALPAG) })
				Else
					aEntrad[nPos,3] += (cAliasVS9)->(VS9_VALPAG)
				EndIf
				(cAliasVS9)->(Dbskip())
			EndDo
			// 
			(cAliasVS9)->(DBCloseArea())
	      //
		EndIf
	EndIf
	
	///////////////////////////////////
	// D E S P E S A S   A C E S S . //
	///////////////////////////////////
	nVPisDesp := 0
	nVCofDesp := 0
	lDuplic := .f.
	cSQLF2D := (cAliasSF2)->(F2_DOC)
	cSQLF2S := 	(cAliasSF2)->(F2_SERIE)
	cAliasSD2 := GetNextAlias()
	BeginSql Alias cAliasSD2
		SELECT SUM(D2_VALIMP5) VAL1 ,SUM(D2_VALIMP6) VAL2
		FROM %Table:SD2% SD2 INNER JOIN
		%Table:SF4% SF4 ON SD2.D2_TES = SF4.F4_CODIGO
		WHERE SD2.D2_FILIAL = %xFilial:SD2% 
		AND SF4.F4_FILIAL = %xFilial:SF4% 
		AND SD2.%NotDel%
		AND SF4.%NotDel%		
		AND SD2.D2_DOC = %Exp:cSQLF2D%
		AND SD2.D2_SERIE = %Exp:cSQLF2S%
		AND SF4.F4_DUPLIC = 'S'
	EndSql
	nVCofDesp += (cAliasSD2)->(VAL1)
	nVPisDesp += (cAliasSD2)->(VAL2)
	(cAliasSD2)->(DBCloseArea())


	cVenSF2 := (cAliasSF2)->(F2_VEND1)
	cAliasVAI := GetNextAlias()
	BeginSql Alias cAliasVAI
		SELECT VAI.VAI_CC
		FROM %Table:VAI% VAI
		WHERE VAI.VAI_FILIAL = %xFilial:VAI% 
		AND VAI.%NotDel%
		AND VAI.VAI_CODVEN = %Exp:cVenSF2%
	EndSql
  

	If lDuplic
		
		aDesAce[1,2] += ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO ))		// Despesa
		aDesAce[1,3] += nVPisDesp				// PIS
		aDesAce[1,4] += nVCofDesp				// COFINS
		aTotal[1,1] += ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO ))  		// Despesa
		aTotal[1,5] += nVPisDesp				// PIS
		aTotal[1,6] += nVCofDesp				// COFINS
		
		If MV_PAR06 # 1
			
			aTotCon[1,1] += ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO) )	// Despesa
			aTotCon[1,5] += nVPisDesp			// PIS
			aTotCon[1,6] += nVCofDesp			// COFINS
			nPos := 0
			nPos := aScan(aGrpPag,{|x| x[1] == (cAliasSF2)->(F2_COND) })
			If nPos == 0
				DbSelectArea( "SE4" )
				DbSetOrder(1)
				DbSeek( xFilial("SE4") + (cAliasSF2)->(F2_COND ))
				// Manoel - 21/03/2005 - Inserir aqui, levantamento do Prazo medio
				aAdd(aGrpPag,{ (cAliasSF2)->(F2_COND) , SE4->E4_DESCRI , ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO )) , (nVPisDesp+nVCofDesp) , 0 , 0 , nVPisDesp , nVCofDesp , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,0})
			Else
				aGrpPag[nPos,3] += ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO) )
				aGrpPag[nPos,4] += (nVPisDesp+nVCofDesp)
				aGrpPag[nPos,7] += nVPisDesp
				aGrpPag[nPos,8] += nVCofDesp
			EndIf
			
			nPos := 0
			If MV_PAR06 # 3
				nPos := aScan(aTotPag,{|x| x[1]+x[2] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+(cAliasSF2)->(F2_VEND1) })
			Else
				nPos := aScan(aTotPag,{|x| x[1]+x[2] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) })
			EndIf
			If nPos == 0 .or. MV_PAR06 == 4
				If MV_PAR06 # 3
					DbSelectArea( "SA3" )
					DbSetOrder(1)
					DbSeek( xFilial("SA3") + (cAliasSF2)->(F2_VEND1) )
					// Manoel - 21/03/2005 - Inserir aqui, levantamento do Prazo medio
					aAdd(aTotPag,{ (cAliasSF2)->(F2_COND) , If(lDuplic,"E","I")+(cAliasSF2)->(F2_VEND1) , left(SA3->A3_NOME,17) , ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO) ) , (nVPisDesp+nVCofDesp) , 0 , 0 , nVPisDesp , nVCofDesp , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })
					
					nPos3 := 0
					nPos3 := aScan(aCCVend,{|x| x[1]+x[2] == If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) + (cAliasSF2)->(F2_VEND1) })
					If nPos3 == 0
						DbSelectArea( "CTT" )
						DbSetOrder(1)
						DbSeek( xFilial("CTT") + (cAliasVAI)->(VAI_CC) )
						// Manoel - 21/03/2005 - Inserir aqui, levantamento do Prazo medio
						aAdd(aCCVend,{ If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , (cAliasSF2)->(F2_VEND1) , left(SA3->A3_NOME,17) , ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO) ) , (nVPisDesp+nVCofDesp) , 0 , 0 , nVPisDesp , nVCofDesp , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , If(lDuplic,"Ext ","Int ")+left(CTT->CTT_DESC01,21),0,0,0})
					Else
						aCCVend[nPos3,4] += ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO) )
						aCCVend[nPos3,5] += (nVPisDesp+nVCofDesp)
						aCCVend[nPos3,8] += nVPisDesp
						aCCVend[nPos3,9] += nVCofDesp
					EndIf
					nPos3 := 0
					nPos3 := aScan(aTotCCV,{|x| x[1] == If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) })
					If nPos3 == 0
						// Manoel - 21/03/2005 - Inserir aqui, levantamento do Prazo medio
						aAdd(aTotCCV,{ If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO) ) , (nVPisDesp+nVCofDesp) , 0 , 0 , nVPisDesp , nVCofDesp , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })
					Else
						aTotCCV[nPos3,2] += ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO ))
						aTotCCV[nPos3,3] += (nVPisDesp+nVCofDesp)
						aTotCCV[nPos3,6] += nVPisDesp
						aTotCCV[nPos3,7] += nVCofDesp
					EndIf
				Else
					DbSelectArea( "CTT" )
					DbSetOrder(1)
					DbSeek( xFilial("CTT") + (cAliasVAI)->(VAI_CC) )
					// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
					aAdd(aTotPag,{ (cAliasSF2)->(F2_COND) , If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , left(CTT->CTT_DESC01,14) , ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO) ) , (nVPisDesp+nVCofDesp) , 0 , 0 , nVPisDesp , nVCofDesp , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })
				EndIf
			Else
				aTotPag[nPos,4] += ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO ))
				aTotPag[nPos,5] += (nVPisDesp+nVCofDesp)
				aTotPag[nPos,8] += nVPisDesp
				aTotPag[nPos,9] += nVCofDesp
			EndIf
			// Andre Luis Almeida - 15/03/2004 - Mostrar DESPESA no Resumo p/Cond.Pagto.
			nPos := 0
			If (cAliasSF2)->(F2_PREFORI) == cPrefOFI
				If (cAliasSF2)->(F2_BASEISS) > 0
					nPos := aScan(aPecSrvOfi,{|x| x[1]+x[2]+x[4] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) + If(lDuplic,"Ext ","Int ")+left(STR0063,18) })
					If nPos == 0
						aAdd(aPecSrvOfi,{ (cAliasSF2)->(F2_COND) , If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) , ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO) ) , If(lDuplic,"Ext ","Int ")+left(STR0063,18) })
					Else
						aPecSrvOfi[nPos,3] += ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO) )
					EndIf
					nPos := 0
					nPos := aScan(aConPagNF,{|x| x[1]+x[2]+x[3]+x[4]+x[7] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) + (cAliasSF2)->(F2_DOC) + (cAliasSF2)->(F2_SERIE) + If(lDuplic,"Ext ","Int ")+left(STR0063,18) })
					If nPos == 0
						DbSelectArea( "SA1" )
						DbSetOrder(1)
						DbSeek( xFilial("SA1") + (cAliasSF2)->(F2_CLIENTE) + (cAliasSF2)->(F2_LOJA) )
						aAdd(aConPagNF,{ (cAliasSF2)->(F2_COND) , If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) , (cAliasSF2)->(F2_DOC) , (cAliasSF2)->(F2_SERIE) , left(SA1->A1_NOME,10) , ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO) ) , If(lDuplic,"Ext ","Int ")+left(STR0063,18) })
					Else
						aConPagNF[nPos,6] += ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO ))
					EndIf
				Else
					nPos := aScan(aPecSrvOfi,{|x| x[1]+x[2]+x[4] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) + If(lDuplic,"Ext ","Int ")+left(STR0064,18) })
					If nPos == 0
						aAdd(aPecSrvOfi,{ (cAliasSF2)->(F2_COND) , If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) , ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO )) , If(lDuplic,"Ext ","Int ")+left(STR0064,18) })
					Else
						aPecSrvOfi[nPos,3] += ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO) )
					EndIf
					nPos := 0
					nPos := aScan(aConPagNF,{|x| x[1]+x[2]+x[3]+x[4]+x[7] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) + (cAliasSF2)->(F2_DOC) + (cAliasSF2)->(F2_SERIE) + If(lDuplic,"Ext ","Int ")+left(STR0064,18) })
					If nPos == 0
						DbSelectArea( "SA1" )
						DbSetOrder(1)
						DbSeek( xFilial("SA1") + (cAliasSF2)->(F2_CLIENTE) + (cAliasSF2)->(F2_LOJA ))
						aAdd(aConPagNF,{ (cAliasSF2)->(F2_COND) , If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) , (cAliasSF2)->(F2_DOC) , (cAliasSF2)->(F2_SERIE) , left(SA1->A1_NOME,10) , ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO) ) , If(lDuplic,"Ext ","Int ")+left(STR0064,18) })
					Else
						aConPagNF[nPos,6] += ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO) )
					EndIf
				EndIf
			ElseIf (cAliasSF2)->(F2_PREFORI) == cPrefBAL
				nPos := aScan(aPecSrvOfi,{|x| x[1]+x[2]+x[4] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) + If(lDuplic,"Ext ","Int ")+left(STR0065,18) })
				If nPos == 0
					aAdd(aPecSrvOfi,{ (cAliasSF2)->(F2_COND) , If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) , ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO) ) , If(lDuplic,"Ext ","Int ")+left(STR0065,18) })
				Else
					aPecSrvOfi[nPos,3] += ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO ))
				EndIf
				nPos := aScan(aConPagNF,{|x| x[1]+x[2]+x[3]+x[4]+x[7] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) + (cAliasSF2)->(F2_DOC) + (cAliasSF2)->(F2_SERIE) + If(lDuplic,"Ext ","Int ")+left(STR0065,18) })
				If nPos == 0
					DbSelectArea( "SA1" )
					DbSetOrder(1)
					DbSeek( xFilial("SA1") + (cAliasSF2)->(F2_CLIENTE) + (cAliasSF2)->(F2_LOJA) )
					aAdd(aConPagNF,{ (cAliasSF2)->(F2_COND) , If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) , (cAliasSF2)->(F2_DOC) , (cAliasSF2)->(F2_SERIE) , left(SA1->A1_NOME,10) , ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO) ) , If(lDuplic,"Ext ","Int ")+left(STR0065,18) })
				Else
					aConPagNF[nPos,6] += ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO ))
				EndIf
			Else
				nPos := aScan(aConPagNF,{|x| x[1]+x[2]+x[3]+x[4]+x[7] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) + (cAliasSF2)->(F2_DOC) + (cAliasSF2)->(F2_SERIE) + "1" })
				If nPos == 0
					DbSelectArea( "SA1" )
					DbSetOrder(1)
					DbSeek( xFilial("SA1") + (cAliasSF2)->(F2_CLIENTE) + (cAliasSF2)->(F2_LOJA) )
					aAdd(aConPagNF,{ (cAliasSF2)->(F2_COND) , If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) , (cAliasSF2)->(F2_DOC) , (cAliasSF2)->(F2_SERIE) , left(SA1->A1_NOME,10) , ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO )) , "1" })
				Else
					aConPagNF[nPos,6] += ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO ))
				EndIf
			EndIf
		EndIf
		Do Case
			Case (cAliasSF2)->(F2_PREFORI) == cPrefVEI //  V E I C U L O S
				aDesAce[2,2] += ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO) )	// Despesa
				aDesAce[2,3] += nVPisDesp			// PIS
				aDesAce[2,4] += nVCofDesp	 		// COFINS
				
			Case (cAliasSF2)->(F2_PREFORI) == cPrefBAL //  B A L C A O
				aDesAce[3,2] += ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO) )	// Despesa
				aDesAce[3,3] += nVPisDesp			// PIS
				aDesAce[3,4] += nVCofDesp			// COFINS
				
			Case (cAliasSF2)->(F2_PREFORI) == cPrefOFI //  O F I C I N A
				aDesAce[4,2] += ( (cAliasSF2)->(F2_DESPESA) + (cAliasSF2)->(F2_FRETE) + (cAliasSF2)->(F2_SEGURO ))	// Despesa
				aDesAce[4,3] += nVPisDesp			// PIS
				aDesAce[4,4] += nVCofDesp			// COFINS
		EndCase
	EndIf
	If !Empty((cAliasSF2)->(VV0_NUMTRA))
		(cAliasSF2)->(Dbskip())
		(cAliasVAI)->(DBCloseArea())
		loop
	EndIf

   cNFSF2 := (cAliasSF2)->(F2_DOC)
   cSerSF2 := (cAliasSF2)->(F2_SERIE )
	cAliasVSC := GetNextAlias()
	nConta := 0
	BeginSql Alias cAliasVSC
		SELECT COUNT(VSC.R_E_C_N_O_) NRO
		FROM %Table:VSC% VSC
		WHERE VSC.VSC_FILIAL = %xFilial:VSC% 
		AND VSC.%NotDel%
		AND VSC.VSC_NUMNFI = %Exp:cNFSF2%
		AND VSC.VSC_SERNFI = %Exp:cSerSF2%
	EndSql
	nConta := (cAliasVSC)->(NRO)
	(cAliasVSC)->(DBCloseArea())
	If nConta > 0 
		(cAliasSF2)->(Dbskip())
		(cAliasVAI)->(DBCloseArea())
		loop
	EndIf

	cAliasSD2 := GetNextAlias()
	nConta := 0
	BeginSql Alias cAliasSD2
		SELECT COUNT(SD2.R_E_C_N_O_) NRO
		FROM %Table:SD2% SD2 INNER JOIN %Table:VEC% VEC
		ON (SD2.D2_DOC = VEC.VEC_NUMNFI
			AND SD2.D2_SERIE = VEC.VEC_SERNFI)
		WHERE SD2.D2_FILIAL = %xFilial:SD2% 
			AND VEC.VEC_FILIAL = %xFilial:VEC% 
			AND SD2.%NotDel%
			AND VEC.%NotDel%			
			AND SD2.D2_DOC = %Exp:cNFSF2%
			AND SD2.D2_SERIE = %Exp:cSerSF2%
			AND SD2.D2_VALISS = 0
	EndSql
	nConta := (cAliasSD2)->(NRO)
	(cAliasSD2)->(DBCloseArea())
	If nConta > 0 
		(cAliasSF2)->(Dbskip())
		(cAliasVAI)->(DBCloseArea())
		loop
	EndIf

	cSF2Soma := "nao"
	cSQLF2D := (cAliasSF2)->(F2_DOC)
	cSQLF2S := 	(cAliasSF2)->(F2_SERIE)
	cAliasSD2 := GetNextAlias()
	BeginSql Alias cAliasSD2
		SELECT SD2.D2_TOTAL,SD2.D2_CUSTO1,SD2.D2_NFORI,SD2.D2_SERIORI,SD2.D2_VALISS,SD2.D2_BASEISS,SF4.F4_PISCRED,SF4.F4_ATUATF
		FROM %Table:SD2% SD2 INNER JOIN
		%Table:SF4% SF4 ON SD2.D2_TES = SF4.F4_CODIGO
		WHERE SD2.D2_FILIAL = %xFilial:SD2% 
		AND SF4.F4_FILIAL = %xFilial:SF4% 
		AND SD2.%NotDel%
		AND SF4.%NotDel%		
		AND SD2.D2_DOC = %Exp:cSQLF2D%
		AND SD2.D2_SERIE = %Exp:cSQLF2S%
		AND SF4.F4_DUPLIC = 'S'
	EndSql
	While !((cAliasSD2)->(Eof())) 
		If Alltrim((cAliasSD2)->(F4_ATUATF)) == "S"    //  A T I V O   I M O B I L I Z A D O
			aTotAtiMob[1,3] += (cAliasSD2)->(D2_TOTAL)
			aTotAtiMob[1,8] += (cAliasSD2)->(D2_CUSTO1)
			aTotAtiMob[3,3] += (cAliasSD2)->(D2_TOTAL)
			aTotAtiMob[3,8] += (cAliasSD2)->(D2_CUSTO1)
			aAdd(aNumAtiMob,{ "O" , STR0057 , (cAliasSD2)->(D2_TOTAL) , 0 , 0 , 0 , 0 , (cAliasSD2)->(D2_CUSTO1) })
		Else
			If (cAliasSD2)->(F4_PISCRED) == "2"
				nPisOOpe := nPis
				nCofOOpe := nCofins
			Else
				nPisOOpe := 0
				nCofOOpe := 0
			EndIf
			If (cAliasSF2)->(F2_TIPO) == "C" .and. (cAliasSF2)->(F2_PREFORI) == cPrefVEI
				DbSelectArea("VV0")
				DbSetOrder(4)
				DbSeek( xFilial("VV0") + (cAliasSD2)->(D2_NFORI) + (cAliasSD2)->(D2_SERIORI ))
				DbSelectArea( "VVA" )
				DbSetOrder(1)
				DbSeek( xFilial("VVA") + VV0->VV0_NUMTRA )
				DbSelectArea( "VV1" )
				DbSetOrder(2)
				DbSeek( xFilial("VV1") + VVA->VVA_CHASSI )
				DbSelectArea("VV2")
				DbSetOrder(1)
				DbSeek(xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )
				nPos := 0
				If ( MV_PAR05 == 1 .or. ( MV_PAR05 == 2 .and. MV_PAR04 # 3 .and. MV_PAR04 # 4 ))
					nPos := aScan(aNumVei,{|x| x[1] + x[2] + x[3] == Alltrim(VV1->VV1_PROVEI) + Alltrim(VV0->VV0_TIPFAT) + VV2->VV2_DESMOD })
				Else
					DbSelectArea( "SA1" )
					DbSetOrder(1)
					DbSeek( xFilial("SA1") + VV1->VV1_PROATU + VV1->VV1_LJPATU )
					cCliente := VV1->VV1_PROATU + " " + left(SA1->A1_NOME,15)
					nPos := aScan(aNumVei,{|x| x[1] + x[2] + x[3] == Alltrim(VV1->VV1_PROVEI) + Alltrim(VV0->VV0_TIPFAT) + cCliente })
				EndIf
				If nPos == 0
					If ( MV_PAR05 == 1 .or. ( MV_PAR05 == 2 .and. MV_PAR04 # 3 .and. MV_PAR04 # 4 ))
						aAdd(aNumVei,{ Alltrim(VV1->VV1_PROVEI) , Alltrim(VV0->VV0_TIPFAT) , VV2->VV2_DESMOD , (cAliasSD2)->(D2_TOTAL) , If(cSF2Soma=="nao",(cAliasSF2)->(F2_VALICM),0) + ((cAliasSD2)->(D2_TOTAL) * nPisOOpe) + ((cAliasSD2)->(D2_TOTAL) * nCofOOpe) , If(cSF2Soma=="nao",(cAliasSF2)->(F2_VALICM),0) , ((cAliasSD2)->(D2_TOTAL) * nPisOOpe) , ((cAliasSD2)->(D2_TOTAL) * nCofOOpe) , (cAliasSD2)->(D2_CUSTO1) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 , VV1->VV1_MODVEI , 0 , 0 , 0 })
					Else
						aAdd(aNumVei,{ Alltrim(VV1->VV1_PROVEI) , Alltrim(VV0->VV0_TIPFAT) , cCliente , (cAliasSD2)->(D2_TOTAL) , If(cSF2Soma=="nao",(cAliasSF2)->(F2_VALICM),0) + ((cAliasSD2)->(D2_TOTAL) * nPisOOpe) + ((cAliasSD2)->(D2_TOTAL) * nCofOOpe) , If(cSF2Soma=="nao",(cAliasSF2)->(F2_VALICM),0) , ((cAliasSD2)->(D2_TOTAL) * nPisOOpe) , ((cAliasSD2)->(D2_TOTAL) * nCofOOpe) , (cAliasSD2)->(D2_CUSTO1) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 , VV1->VV1_MODVEI , 0 , 0 , 0 })
					EndIf
				Else
					aNumVei[nPos,4] += (cAliasSD2)->(D2_TOTAL)
					aNumVei[nPos,5] += If(cSF2Soma=="nao",(cAliasSF2)->(F2_VALICM),0) + ((cAliasSD2)->(D2_TOTAL) * nPisOOpe) + ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
					aNumVei[nPos,6] += If(cSF2Soma=="nao",(cAliasSF2)->(F2_VALICM),0)
					aNumVei[nPos,7] += ((cAliasSD2)->(D2_TOTAL) * nPisOOpe)
					aNumVei[nPos,8] += ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
					aNumVei[nPos,9] += (cAliasSD2)->(D2_CUSTO1)
					aNumVei[nPos,18]++
				EndIf
				nPos := 0
				nPos := aScan(aGrpVei,{|x| x[1] + x[2] == Alltrim(VV1->VV1_PROVEI) + Alltrim(VV0->VV0_TIPFAT) })
				If nPos == 0
					aAdd(aGrpVei,{ Alltrim(VV1->VV1_PROVEI) , Alltrim(VV0->VV0_TIPFAT) , (cAliasSD2)->(D2_TOTAL) , If(cSF2Soma=="nao",(cAliasSF2)->(F2_VALICM),0) + ((cAliasSD2)->(D2_TOTAL) * nPisOOpe) + ((cAliasSD2)->(D2_TOTAL) * nCofOOpe) , If(cSF2Soma=="nao",(cAliasSF2)->(F2_VALICM),0) , ((cAliasSD2)->(D2_TOTAL) * nPisOOpe) , ((cAliasSD2)->(D2_TOTAL) * nCofOOpe) , (cAliasSD2)->(D2_CUSTO1) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 , 0 , 0 , 0 })
				Else
					aGrpVei[nPos,3] += (cAliasSD2)->(D2_TOTAL)
					aGrpVei[nPos,4] += If(cSF2Soma=="nao",(cAliasSF2)->(F2_VALICM),0) + ((cAliasSD2)->(D2_TOTAL) * nPisOOpe) + ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
					aGrpVei[nPos,5] += If(cSF2Soma=="nao",(cAliasSF2)->(F2_VALICM),0)
					aGrpVei[nPos,6] += ((cAliasSD2)->(D2_TOTAL) * nPisOOpe)
					aGrpVei[nPos,7] += ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
					aGrpVei[nPos,8] += (cAliasSD2)->(D2_CUSTO1)
					aGrpVei[nPos,17]++
				EndIf
				aTotVei[1,1] += (cAliasSD2)->(D2_TOTAL)
				aTotVei[1,2] += If(cSF2Soma=="nao",(cAliasSF2)->(F2_VALICM),0) + ((cAliasSD2)->(D2_TOTAL) * nPisOOpe) + ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
				aTotVei[1,3] += If(cSF2Soma=="nao",(cAliasSF2)->(F2_VALICM),0)
				aTotVei[1,4] += ((cAliasSD2)->(D2_TOTAL) * nPisOOpe)
				aTotVei[1,5] += ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
				aTotVei[1,6] += (cAliasSD2)->(D2_CUSTO1)
				aTotal[1,1]  += (cAliasSD2)->(D2_TOTAL)
				aTotal[1,2]  += If(cSF2Soma=="nao",(cAliasSF2)->(F2_VALICM),0) + ((cAliasSD2)->(D2_TOTAL) * nPisOOpe) + ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
				aTotal[1,3]  += If(cSF2Soma=="nao",(cAliasSF2)->(F2_VALICM),0)
				aTotal[1,5]  += ((cAliasSD2)->(D2_TOTAL) * nPisOOpe)
				aTotal[1,6]  += ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
				aTotal[1,7]  += (cAliasSD2)->(D2_CUSTO1)
			EndIf
			If cSF2Soma == "nao"
				cSF2Soma := "sim"
				If (cAliasSF2)->(F2_TIPO) # "C" .or. (cAliasSF2)->(F2_PREFORI) # cPrefVEI
					aTotOOpe[1,2] += if((cAliasSF2)->(F2_VALISS)>0,(cAliasSF2)->(F2_VALISS),((cAliasSF2)->(F2_VALICM) + (cAliasSF2)->(F2_VALISS)))
					aTotOOpe[1,3] += if((cAliasSF2)->(F2_VALISS)>0,0,(cAliasSF2)->(F2_VALICM))
					aTotOOpe[1,4] += (cAliasSF2)->(F2_VALISS)
				EndIf
				If MV_PAR06 # 1
					nPos := 0
					nPos := aScan(aGrpPag,{|x| x[1] == (cAliasSF2)->(F2_COND )})
					If nPos == 0
						DbSelectArea( "SE4" )
						DbSetOrder(1)
						DbSeek( xFilial("SE4") + (cAliasSF2)->(F2_COND ))
						// Manoel - 21/03/2005 - Inserir aqui, levantamento do Prazo medio
						aAdd(aGrpPag,{ (cAliasSF2)	->(F2_COND) , SE4->E4_DESCRI , 0 , ((cAliasSF2)->(F2_VALICM) + (cAliasSF2)->(F2_VALISS)) , (cAliasSF2)->(F2_VALICM) , (cAliasSF2)->(F2_VALISS) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })
					Else
						aGrpPag[nPos,4] += ((cAliasSF2)->(F2_VALICM) + (cAliasSF2)->(F2_VALISS))
						aGrpPag[nPos,5] += (cAliasSF2)->(F2_VALICM)
						aGrpPag[nPos,6] += (cAliasSF2)->(F2_VALISS)
					EndIf
					nPos := 0
					If MV_PAR06 # 3
						nPos := aScan(aTotPag,{|x| x[1]+x[2] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+(cAliasSF2)->(F2_VEND1) })
					Else
						nPos := aScan(aTotPag,{|x| x[1]+x[2] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) })
					EndIf
					If nPos == 0 .or. MV_PAR06 == 4
						If MV_PAR06 # 3
							DbSelectArea( "SA3" )
							DbSetOrder(1)
							DbSeek( xFilial("SA3") + (cAliasSF2)->(F2_VEND1) )
							// Manoel - 21/03/2005 - Inserir aqui, levantamento do Prazo medio
							aAdd(aTotPag,{ (cAliasSF2)->(F2_COND) , If(lDuplic,"E","I")+(cAliasSF2)->(F2_VEND1) , left(SA3->A3_NOME,17) , 0 , ((cAliasSF2)->(F2_VALICM) + (cAliasSF2)->(F2_VALISS)) , (cAliasSF2)->(F2_VALICM) , (cAliasSF2)->(F2_VALISS) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })
							
							nPos3 := 0
							nPos3 := aScan(aCCVend,{|x| x[1]+x[2] == If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) + (cAliasSF2)->(F2_VEND1 )})
							If nPos3 == 0
								DbSelectArea( "CTT" )
								DbSetOrder(1)
								DbSeek( xFilial("CTT") + (cAliasVAI)->(VAI_CC) )
								// Manoel - 21/03/2005 - Inserir aqui, levantamento do Prazo medio
								aAdd(aCCVend,{ If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , (cAliasSF2)->(F2_VEND1) , left(SA3->A3_NOME,17) , 0 , ((cAliasSF2)->(F2_VALICM) + (cAliasSF2)->(F2_VALISS)) , (cAliasSF2)->(F2_VALICM) , (cAliasSF2)->(F2_VALISS) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , If(lDuplic,"Ext ","Int ")+left(CTT->CTT_DESC01,21),0,0,0})
							Else
								aCCVend[nPos3,5]  += ((cAliasSF2)->(F2_VALICM) + (cAliasSF2)->(F2_VALISS))
								aCCVend[nPos3,6]  += (cAliasSF2)->(F2_VALICM)
								aCCVend[nPos3,7]  += (cAliasSF2)->(F2_VALISS)
							EndIf
							nPos3 := 0
							nPos3 := aScan(aTotCCV,{|x| x[1] == If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) })
							If nPos3 == 0
								// Manoel - 22/03/2005 - Inserir aqui, levantamento do Prazo medio
								aAdd(aTotCCV,{ If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , 0 , ((cAliasSF2)->(F2_VALICM) + (cAliasSF2)->(F2_VALISS)) , (cAliasSF2)->(F2_VALICM) , (cAliasSF2)->(F2_VALISS) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })
								//
							Else
								aTotCCV[nPos3,3]  += ((cAliasSF2)->(F2_VALICM) + (cAliasSF2)->(F2_VALISS))
								aTotCCV[nPos3,4]  += (cAliasSF2)->(F2_VALICM)
								aTotCCV[nPos3,5]  += (cAliasSF2)->(F2_VALISS)
							EndIf
						Else
							DbSelectArea( "CTT" )
							DbSetOrder(1)
							DbSeek( xFilial("CTT") + (cAliasVAI)->(VAI_CC) )
							// Manoel - 21/03/2005 - Inserir aqui, levantamento do Prazo medio
							aAdd(aTotPag,{ (cAliasSF2)->(F2_COND) , If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , left(CTT->CTT_DESC01,14) , 0 , ((cAliasSF2)->(F2_VALICM) + (cAliasSF2)->(F2_VALISS)) , (cAliasSF2)->(F2_VALICM) , (cAliasSF2)->(F2_VALISS) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })
						EndIf
					Else
						aTotPag[nPos,5]  += ((cAliasSF2)->(F2_VALICM) + (cAliasSF2)->(F2_VALISS))
						aTotPag[nPos,6]  += (cAliasSF2)->(F2_VALICM)
						aTotPag[nPos,7]  += (cAliasSF2)->(F2_VALISS)
					EndIf
					
				EndIf
				If (cAliasSF2)->(F2_TIPO) # "C" .or. (cAliasSF2)->(F2_PREFORI) # cPrefVEI
					If (cAliasSD2)->(D2_VALISS) > 0	//  S E R V I C O S
						aOOpeSrv[1,2]  += (cAliasSF2)->(F2_VALISS)
						aOOpeSrv[1,4]  += (cAliasSF2)->(F2_VALISS)
					Else					// O U T R O S
						aOOpeOut[1,2]  += ((cAliasSF2)->(F2_VALICM) + (cAliasSF2)->(F2_VALISS))
						aOOpeOut[1,3]  += (cAliasSF2)->(F2_VALICM)
					EndIf
				EndIf
			EndIf
			
			If (cAliasSF2)->(F2_TIPO) # "C" .or. (cAliasSF2)->(F2_PREFORI) # cPrefVEI
				aTotOOpe[1,2] += ((cAliasSD2)->(D2_TOTAL) * nPisOOpe) + ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
				aTotOOpe[1,5] += ((cAliasSD2)->(D2_TOTAL) * nPisOOpe)
				aTotOOpe[1,6] += ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
			EndIf
			If MV_PAR06 # 1
				nPos := 0
				nPos := aScan(aGrpPag,{|x| x[1] == (cAliasSF2)->(F2_COND )})
				If nPos > 0
					aGrpPag[nPos,4] += ((cAliasSD2)->(D2_TOTAL) * nPisOOpe) + ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
					aGrpPag[nPos,7] += ((cAliasSD2)->(D2_TOTAL) * nPisOOpe)
					aGrpPag[nPos,8] += ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
				EndIf
				nPos := 0
				If MV_PAR06 # 3
					nPos := aScan(aTotPag,{|x| x[1]+x[2] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+(cAliasSF2)->(F2_VEND1) })
				Else
					nPos := aScan(aTotPag,{|x| x[1]+x[2] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) })
				EndIf
				If nPos > 0
					aTotPag[nPos,5] += ((cAliasSD2)->(D2_TOTAL) * nPisOOpe) + ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
					aTotPag[nPos,8] += ((cAliasSD2)->(D2_TOTAL) * nPisOOpe)
					aTotPag[nPos,9] += ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
					If MV_PAR06 # 3
						nPos3 := 0
						nPos3 := aScan(aCCVend,{|x| x[1]+x[2] == If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) + (cAliasSF2)->(F2_VEND1 )})
						If nPos3 > 0
							aCCVend[nPos3,5]  += ((cAliasSD2)->(D2_TOTAL) * nPisOOpe) + ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
							aCCVend[nPos3,8]  += ((cAliasSD2)->(D2_TOTAL) * nPisOOpe)
							aCCVend[nPos3,9]  += ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
						EndIf
						nPos3 := 0
						nPos3 := aScan(aTotCCV,{|x| x[1] == If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) })
						If nPos3 > 0
							aTotCCV[nPos3,3]  += ((cAliasSD2)->(D2_TOTAL) * nPisOOpe) + ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
							aTotCCV[nPos3,6]  += ((cAliasSD2)->(D2_TOTAL) * nPisOOpe)
							aTotCCV[nPos3,7]  += ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
						EndIf
					EndIf
				EndIf
			EndIf
			If (cAliasSF2)->(F2_TIPO) # "C" .or. (cAliasSF2)->(F2_PREFORI) # cPrefVEI
				If (cAliasSD2)->(D2_VALISS) > 0	//  S E R V I C O S
					aOOpeSrv[1,2]  += ((cAliasSD2)->(D2_TOTAL) * nPisOOpe) + ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
					aOOpeSrv[1,5]  += ((cAliasSD2)->(D2_TOTAL) * nPisOOpe)
					aOOpeSrv[1,6]  += ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
				Else					// O U T R O S
					aOOpeOut[1,2]  += ((cAliasSD2)->(D2_TOTAL) * nPisOOpe) + ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
					aOOpeOut[1,5]  += ((cAliasSD2)->(D2_TOTAL) * nPisOOpe)
					aOOpeOut[1,6]  += ((cAliasSD2)->(D2_TOTAL) * nCofOOpe)
				EndIf
			EndIf
			
			nPos := 0
			If (cAliasSF2)->(F2_PREFORI) == cPrefOFI
				
				If (cAliasSD2)->(D2_BASEISS) > 0
					nPos := aScan(aPecSrvOfi,{|x| x[1]+x[2]+x[4] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) + If(lDuplic,"Ext ","Int ")+left(STR0063,18) })
					If nPos == 0
						aAdd(aPecSrvOfi,{ (cAliasSF2)->(F2_COND) , If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) , (cAliasSD2)->(D2_TOTAL) , If(lDuplic,"Ext ","Int ")+left(STR0063,18) })
					Else
						aPecSrvOfi[nPos,3] += (cAliasSD2)->(D2_TOTAL)
					EndIf
					nPos := 0
					nPos := aScan(aConPagNF,{|x| x[1]+x[2]+x[3]+x[4]+x[7] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) + (cAliasSF2)->(F2_DOC) + (cAliasSF2)->(F2_SERIE) + If(lDuplic,"Ext ","Int ")+left(STR0063,18) })
					If nPos == 0
						DbSelectArea( "SA1" )
						DbSetOrder(1)
						DbSeek( xFilial("SA1") + (cAliasSF2)->(F2_CLIENTE) + (cAliasSF2)->(F2_LOJA ))
						aAdd(aConPagNF,{ (cAliasSF2)->(F2_COND) , If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) , (cAliasSF2)->(F2_DOC) , (cAliasSF2)->(F2_SERIE) , left(SA1->A1_NOME,10) , (cAliasSD2)->(D2_TOTAL) , If(lDuplic,"Ext ","Int ")+left(STR0063,18) })
					Else
						aConPagNF[nPos,6] += (cAliasSD2)->(D2_TOTAL)
					EndIf
				Else
					nPos := aScan(aPecSrvOfi,{|x| x[1]+x[2]+x[4] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) + If(lDuplic,"Ext ","Int ")+left(STR0064,18) })
					If nPos == 0
						aAdd(aPecSrvOfi,{ (cAliasSF2)->(F2_COND) , If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) , (cAliasSD2)->(D2_TOTAL) , If(lDuplic,"Ext ","Int ")+left(STR0064,18) })
					Else
						aPecSrvOfi[nPos,3] += (cAliasSD2)->(D2_TOTAL)
					EndIf
					nPos := 0
					nPos := aScan(aConPagNF,{|x| x[1]+x[2]+x[3]+x[4]+x[7] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) + (cAliasSF2)->(F2_DOC) + (cAliasSF2)->(F2_SERIE) + If(lDuplic,"Ext ","Int ")+left(STR0064,18) })
					If nPos == 0
						DbSelectArea( "SA1" )
						DbSetOrder(1)
						DbSeek( xFilial("SA1") + (cAliasSF2)->(F2_CLIENTE) + (cAliasSF2)->(F2_LOJA ))
						aAdd(aConPagNF,{ (cAliasSF2)->(F2_COND) , If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) , (cAliasSF2)->(F2_DOC) , (cAliasSF2)->(F2_SERIE) , left(SA1->A1_NOME,10) , (cAliasSD2)->(D2_TOTAL) , If(lDuplic,"Ext ","Int ")+left(STR0064,18) })
					Else
						aConPagNF[nPos,6] += (cAliasSD2)->(D2_TOTAL)
					EndIf
				EndIf
				
			ElseIf (cAliasSF2)->(F2_PREFORI) == cPrefBAL
				
				nPos := aScan(aPecSrvOfi,{|x| x[1]+x[2]+x[4] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) + If(lDuplic,"Ext ","Int ")+left(STR0065,18) })
				If nPos == 0
					aAdd(aPecSrvOfi,{ (cAliasSF2)->(F2_COND) , If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) , (cAliasSD2)->(D2_TOTAL) , If(lDuplic,"Ext ","Int ")+left(STR0065,18) })
				Else
					aPecSrvOfi[nPos,3] += (cAliasSD2)->(D2_TOTAL)
				EndIf
				nPos := aScan(aConPagNF,{|x| x[1]+x[2]+x[3]+x[4]+x[7] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) + (cAliasSF2)->(F2_DOC) + (cAliasSF2)->(F2_SERIE) + If(lDuplic,"Ext ","Int ")+left(STR0065,18) })
				If nPos == 0
					DbSelectArea( "SA1" )
					DbSetOrder(1)
					DbSeek( xFilial("SA1") + (cAliasSF2)->(F2_CLIENTE) + (cAliasSF2)->(F2_LOJA ))
					aAdd(aConPagNF,{ (cAliasSF2)->(F2_COND) , If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) , (cAliasSF2)->(F2_DOC ), (cAliasSF2)->(F2_SERIE) , left(SA1->A1_NOME,10) , (cAliasSD2)->(D2_TOTAL) , If(lDuplic,"Ext ","Int ")+left(STR0065,18) })
				Else
					aConPagNF[nPos,6] += (cAliasSD2)->(D2_TOTAL)
				EndIf
				
			Else
				
				nPos := aScan(aConPagNF,{|x| x[1]+x[2]+x[3]+x[4]+x[7] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) + (cAliasSF2)->(F2_DOC) + (cAliasSF2)->(F2_SERIE) + "1" })
				If nPos == 0
					DbSelectArea( "SA1" )
					DbSetOrder(1)
					DbSeek( xFilial("SA1") + (cAliasSF2)->(F2_CLIENTE) + (cAliasSF2)->(F2_LOJA ))
					aAdd(aConPagNF,{ (cAliasSF2)->(F2_COND) , If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasSF2)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) , (cAliasSF2)->(F2_DOC) , (cAliasSF2)->(F2_SERIE) , left(SA1->A1_NOME,10) , (cAliasSD2)->(D2_TOTAL) , "1" })
				Else
					aConPagNF[nPos,6] += (cAliasSD2)->(D2_TOTAL)
				EndIf
				
			EndIf
			
			If (cAliasSF2)->(F2_TIPO) # "C" .or. (cAliasSF2)->(F2_PREFORI) # cPrefVEI
				aTotOOpe[1,1]  += (cAliasSD2)->(D2_TOTAL)
				aTotOOpe[1,7]  += (cAliasSD2)->(D2_CUSTO1)
			EndIf
			
			If MV_PAR06 # 1
				
				nPos := 0
				nPos := aScan(aGrpPag,{|x| x[1] == (cAliasSF2)->(F2_COND )})
				If nPos == 0
					DbSelectArea( "SE4" )
					DbSetOrder(1)
					DbSeek( xFilial("SE4") + (cAliasSF2)->(F2_COND ))
					// Manoel - 21/03/2005 - Inserir aqui, levantamento do Prazo medio
					aAdd(aGrpPag,{ (cAliasSF2)->(F2_COND) , SE4->E4_DESCRI , (cAliasSD2)->(D2_TOTAL) , 0 , 0 , 0 , 0 , 0 , (cAliasSD2)->(D2_CUSTO1) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })
				Else
					aGrpPag[nPos,3] += (cAliasSD2)->(D2_TOTAL)
					aGrpPag[nPos,9] += (cAliasSD2)->(D2_CUSTO1)
				EndIf
				
				nPos := 0
				
				If MV_PAR06 # 3
					nPos := aScan(aTotPag,{|x| x[1]+x[2] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+(cAliasSF2)->(F2_VEND1) })
				Else
					nPos := aScan(aTotPag,{|x| x[1]+x[2] == (cAliasSF2)->(F2_COND) + If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) })
				EndIf
				
				If nPos == 0 .or. MV_PAR06 == 4
					If MV_PAR06 # 3
						DbSelectArea( "SA3" )
						DbSetOrder(1)
						DbSeek( xFilial("SA3") + (cAliasSF2)->(F2_VEND1) )
						// Manoel - 21/03/2005 - Inserir aqui, levantamento do Prazo medio
						aAdd(aTotPag,{ (cAliasSF2)->(F2_COND) , If(lDuplic,"E","I")+(cAliasSF2)->(F2_VEND1) , left(SA3->A3_NOME,17) , (cAliasSD2)->(D2_TOTAL) , 0 , 0 , 0 , 0 , 0 , (cAliasSD2)->(D2_CUSTO1) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })
						nPos3 := 0
						nPos3 := aScan(aCCVend,{|x| x[1]+x[2] == If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) + (cAliasSF2)->(F2_VEND1 )})
						If nPos3 == 0
							DbSelectArea( "CTT" )
							DbSetOrder(1)
							DbSeek( xFilial("CTT") + (cAliasVAI)->(VAI_CC) )
							// Manoel - 21/03/2005 - Inserir aqui, levantamento do Prazo medio
							aAdd(aCCVend,{ If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , (cAliasSF2)->(F2_VEND1) , left(SA3->A3_NOME,17) , (cAliasSD2)->(D2_TOTAL) , 0 , 0 , 0 , 0 , 0 , (cAliasSD2)->(D2_CUSTO1) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , If(lDuplic,"Ext ","Int ")+left(CTT->CTT_DESC01,21),0,0,0})
						Else
							aCCVend[nPos3,4]  += (cAliasSD2)->(D2_TOTAL)
							aCCVend[nPos3,10] += (cAliasSD2)->(D2_CUSTO1)
						EndIf
						nPos3 := 0
						nPos3 := aScan(aTotCCV,{|x| x[1] == If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) })
						If nPos3 == 0
							// Manoel - 21/03/2005 - Inserir aqui, levantamento do Prazo medio
							aAdd(aTotCCV,{ If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , (cAliasSD2)->(D2_TOTAL) , 0 , 0 , 0 , 0 , 0 , (cAliasSD2)->(D2_CUSTO1) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })
						Else
							aTotCCV[nPos3,2]  += (cAliasSD2)->(D2_TOTAL)
							aTotCCV[nPos3,8]  += (cAliasSD2)->(D2_CUSTO1)
						EndIf
					Else
						DbSelectArea( "CTT" )
						DbSetOrder(1)
						DbSeek( xFilial("CTT") + (cAliasVAI)->(VAI_CC) )
						// Manoel - 21/03/2005 - Inserir aqui, levantamento do Prazo medio
						aAdd(aTotPag,{ (cAliasSF2)->(F2_COND) , If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , left(CTT->CTT_DESC01,14) , (cAliasSD2)->(D2_TOTAL) , 0 , 0 , 0 , 0 , 0 , (cAliasSD2)->(D2_CUSTO1) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })
					EndIf
				Else
					aTotPag[nPos,4]  += (cAliasSD2)->(D2_TOTAL)
					aTotPag[nPos,10] += (cAliasSD2)->(D2_CUSTO1)
				EndIf
				
			EndIf
			
			If (cAliasSF2)->(F2_TIPO) # "C" .or. (cAliasSF2)->(F2_PREFORI) # cPrefVEI
				If (cAliasSD2)->(D2_VALISS) > 0	//  S E R V I C O S
					aOOpeSrv[1,1]  += (cAliasSD2)->(D2_TOTAL)
					aOOpeSrv[1,7]  += (cAliasSD2)->(D2_CUSTO1)
				Else					// O U T R O S
					aOOpeOut[1,1]  += (cAliasSD2)->(D2_TOTAL)
					aOOpeOut[1,7]  += (cAliasSD2)->(D2_CUSTO1)
				EndIf
			EndIf
			
		EndIf
		(cAliasSD2)->(Dbskip())
	EndDo
	(cAliasSD2)->(DBCloseArea())
	(cAliasVAI)->(DBCloseArea())
	(cAliasSF2)->(Dbskip())
EndDo
(cAliasSF2)->(DBCloseArea())

///////////////////////////////////
//      D E V O L U C O E S      //
///////////////////////////////////
If FunName() == "OFIOR250"
	IncProc(STR0100)//Selecionando Devolucoes...
	IncProc(STR0100)//Selecionando Devolucoes...
	IncProc(STR0100)//Selecionando Devolucoes...
EndIf

cAliasSD1 := GetNextAlias()
BeginSql Alias cAliasSD1
	SELECT SD1.* , SF4.F4_PISCRED, SF4.F4_PISCOF, SF4.F4_CREDICM 
	FROM  %Table:SD1% SD1 INNER JOIN
	       %Table:SF1% SF1 ON  
	       ( SF1.F1_DOC = SD1.D1_DOC AND 
	       SF1.F1_SERIE = SD1.D1_SERIE AND 
	       SF1.F1_FORNECE  = SD1.D1_FORNECE AND
	       SF1.F1_LOJA = SD1.D1_LOJA ) INNER JOIN
		       %Table:SF4% SF4 ON 
		       SD1.D1_TES = SF4.F4_CODIGO
	WHERE SD1.D1_FILIAL = %xFilial:SD1% 
	AND SF4.F4_FILIAL = %xFilial:SF4%
	AND SF1.F1_FILIAL = %xFilial:SF1%
	AND SD1.%NotDel%
	AND SF4.%NotDel%		
	AND SF1.%NotDel%
	AND SF1.F1_TIPO = 'D'
	AND SF4.F4_ESTOQUE = 'S'
	AND SF1.F1_DTDIGIT >= %Exp:MV_PAR01%
	AND SF1.F1_DTDIGIT <= %Exp:MV_PAR02%
EndSql
If FunName() == "OFIOR250"
	IncProc(STR0101)//Totalizando Devolucoes...
	IncProc(STR0101)//Totalizando Devolucoes...
	IncProc(STR0101)//Totalizando Devolucoes...
EndIf
aAdd(aTotDev,{ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })   // Devolucoes - Total
while !( (cAliasSD1)->(eof()) )
	nVlrDev := ( ( (cAliasSD1)->(D1_TOTAL) + (cAliasSD1)->(D1_VALIPI) + (cAliasSD1)->(D1_ICMSRET) + (cAliasSD1)->(D1_DESPESA) + (cAliasSD1)->(D1_SEGURO) + (cAliasSD1)->(D1_VALFRE) ) - (cAliasSD1)->(D1_VALDESC) )
	nQtdDev := (cAliasSD1)->(D1_QUANT)
	nPisDev := 0
	nCofDev := 0
	If (cAliasSD1)->(F4_PISCRED) == "1"
		Do Case
			Case (cAliasSD1)->(F4_PISCOF) == "1"
				nPisDev := (cAliasSD1)->(D1_VALIMP6)
			Case (cAliasSD1)->(F4_PISCOF) == "2"
				nCofDev := (cAliasSD1)->(D1_VALIMP5)
			Case (cAliasSD1)->(F4_PISCOF) == "3"
				nPisDev := (cAliasSD1)->(D1_VALIMP6)
				nCofDev := (cAliasSD1)->(D1_VALIMP5)
		EndCase
	Endif
	If (cAliasSD1)->(F4_CREDICM) == "N"
		nImpDev := (cAliasSD1)->(D1_VALISS) + nPisDev + nCofDev
	Else
		nImpDev := (cAliasSD1)->(D1_VALICM) + (cAliasSD1)->(D1_VALISS) + nPisDev + nCofDev
	Endif
	aTotDev[1,1] += nVlrDev
	aTotDev[1,2] += nImpDev
	aTotDev[1,3] += (cAliasSD1)->(D1_VALICM)
	aTotDev[1,4] += (cAliasSD1)->(D1_VALISS)
	aTotDev[1,5] += nPisDev
	aTotDev[1,6] += nCofDev
	aTotDev[1,7] += (cAliasSD1)->(D1_CUSTO)
	aTotDev[1,8] += nVlrDev - ( nImpDev + (cAliasSD1)->(D1_CUSTO ))
	DbSelectArea("SF2")
	DbSetOrder(1)
	DbSeek(xFilial("SF2") + (cAliasSD1)->(D1_NFORI) + (cAliasSD1)->(D1_SERIORI) , .f. )
	////////// TXT com Clientes/Itens //////////
	If MV_PAR09 == 1 .and. Alltrim(SF2->F2_PREFORI) $ (cPrefBAL+"/"+cPrefOFI) // Devolucao
	   If SF2->F2_PREFORI == cPrefOFI // OFICINA
			DbSelectArea( "VO3" )
			DbSetOrder(5)
			DbSeek( xFilial("VO3") + (cAliasSD1)->(D1_NFORI) + (cAliasSD1)->(D1_SERIORI) , .f. )
			DbSelectArea( "VOI" )
			DbSetOrder(1)
			DbSeek( xFilial("VOI") + VO3->VO3_TIPTEM , .f. )
		Endif	
		If FunName() == "OFIOR250"
			nMes := aScan(aTXTMes,{|x| x[1] == strzero(month(SF2->F2_EMISSAO),2)+strzero(year(SF2->F2_EMISSAO),4) })
		EndIf
	   If SF2->F2_PREFORI == cPrefOFI // OFICINA
			nTXTVda -= nVlrDev
			nTXTLuc -= nVlrDev - ( nImpDev + (cAliasSD1)->(D1_CUSTO) )
			If VOI->VOI_SITTPO != "2" // se nao for garantia
				If ValType(nTXTVdaNG) == "U"
					nTXTVdaNG := 0
				Endif	
				If ValType(nTXTLucNG) == "U"
					nTXTLucNG := 0
				Endif	
				If ValType(nVlrDev) == "U"
					nVlrDev := 0
				Endif	
				nTXTVdaNG -= nVlrDev
				nTXTLucNG -= nVlrDev - ( nImpDev + (cAliasSD1)->(D1_CUSTO ))
 				cTipGar  := "N"
 			Else	
 				cTipGar  := "S" 							
 			Endif	
		Else
			cTipGar  := "N"
			nTXTVda -= nVlrDev
			nTXTLuc -= nVlrDev - ( nImpDev + (cAliasSD1)->(D1_CUSTO ))
			nTXTVda -= nVlrDev
			nTXTLuc -= nVlrDev - ( nImpDev + (cAliasSD1)->(D1_CUSTO ))
		Endif	
		nTXTAux1 := aScan(aTXTCli,{|x| x[1] == SF2->F2_CLIENTE + SF2->F2_LOJA})
		If nTXTAux1 == 0
			aAdd(aTXTCli,{ SF2->F2_CLIENTE + SF2->F2_LOJA , (-1) * ( nVlrDev ) , space(12) , (-1) * ( nVlrDev - ( nImpDev + (cAliasSD1)->(D1_CUSTO) ) ) , space(12) , len(aTXTCli)+1,VOI->VOI_SITTPO })
			If FunName() == "OFIOR250"
					aAdd(aTXTCliA,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,VOI->VOI_SITTPO})
					aAdd(aTXTCliNG,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,VOI->VOI_SITTPO})
				nTXTAux1 := len(aTXTCli)
			EndIf
		Else
			aTXTCli[nTXTAux1,2] -= nVlrDev
			aTXTCli[nTXTAux1,4] -= nVlrDev - ( nImpDev + (cAliasSD1)->(D1_CUSTO ))
		EndIf
		If FunName() == "OFIOR250"
			If nMes > 0
				If VOI->VOI_SITTPO != "2" // se nao for garantia
				   If Len(aTXTCliA) < nTXTAux1
				      nCont := Len(aTXTCliA) + 1
				      for ii := nCont to nTXTAux1
							aAdd(aTXTCliA,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
				      Next
				   Endif
					aTXTCliA[aTXTCli[nTXTAux1,6],nMes] -= nVlrDev
					aTXTCliA[aTXTCli[nTXTAux1,6],nMes+1] -= nVlrDev - ( nImpDev + (cAliasSD1)->(D1_CUSTO ))
				Else	
				   If Len(aTXTCliNG) < nTXTAux1
				      nCont := Len(aTXTCliNG) + 1
				      for ii := nCont to nTXTAux1
							aAdd(aTXTCliNG,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
				      Next
				   Endif
					aTXTCliNG[aTXTCli[nTXTAux1,6],nMes] -= nVlrDev
					aTXTCliNG[aTXTCli[nTXTAux1,6],nMes+1] -= nVlrDev - ( nImpDev + (cAliasSD1)->(D1_CUSTO ))
				EndIf
			EndIf
		EndIf
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1") + (cAliasSD1)->(D1_COD ))
		nTXTAux1 := aScan(aTXTIte,{|x| x[1] == SB1->B1_GRUPO + SB1->B1_CODITE })
		If nTXTAux1 == 0
			aAdd(aTXTIte,{ SB1->B1_GRUPO + SB1->B1_CODITE , (-1) * ( nVlrDev ) , space(12) , (-1) * ( nVlrDev - ( nImpDev + (cAliasSD1)->(D1_CUSTO) ) ) , space(12) , len(aTXTIte)+1 , VOI->VOI_SITTPO,nQtdDev})
			If FunName() == "OFIOR250"
				aAdd(aTXTIteA,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
				aAdd(aTXTIteNG,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
				nTXTAux1 := len(aTXTIte)
			EndIf
		Else
			aTXTIte[nTXTAux1,2] -= nVlrDev
			aTXTIte[nTXTAux1,4] -= nVlrDev - ( nImpDev + (cAliasSD1)->(D1_CUSTO ))
			aTXTIte[nTXTAux1,8] -= nQtdDev
		EndIf
		If FunName() == "OFIOR250"
			If nMes > 0
				If VOI->VOI_SITTPO != "2" // se nao for garantia
				   If Len(aTXTIteA) < nTXTAux1
				      nCont := Len(aTXTIteA) + 1
				      for ii := nCont to nTXTAux1
							aAdd(aTXTIteA,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
				      Next
				   Endif
					aTXTIteA[aTXTIte[nTXTAux1,6],nMes] -= nVlrDev
					aTXTIteA[aTXTIte[nTXTAux1,6],nMes+1] -= nVlrDev - ( nImpDev + (cAliasSD1)->(D1_CUSTO ))
				Else	
				   If Len(aTXTIteNG) < nTXTAux1
				      nCont := Len(aTXTIteNG) + 1
				      for ii := nCont to nTXTAux1
							aAdd(aTXTIteNG,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
				      Next
				   Endif
					aTXTIteNG[aTXTIte[nTXTAux1,6],nMes] -= nVlrDev
					aTXTIteNG[aTXTIte[nTXTAux1,6],nMes+1] -= nVlrDev - ( nImpDev + (cAliasSD1)->(D1_CUSTO ))
				EndIf
			EndIf
		EndIf
	EndIf
	////////////////////////////////////////////
	cSeekDev := "00"+(cAliasSD1)->(D1_GRUPO)
	cDpto := "   "
	If SF2->F2_PREFORI == cPrefVEI // VEICULOS
		DbSelectArea( "VV0" )
		DbSetOrder(4)
		DbSeek( xFilial("VV0") + (cAliasSD1)->(D1_NFORI) + (cAliasSD1)->(D1_SERIORI) , .f. )
		DbSelectArea( "VVA" )
		DbSetOrder(1)
		DbSeek( xFilial("VVA") + VV0->VV0_NUMTRA , .f. )
		DbSelectArea( "VV1" )
		DbSetOrder(1)
		DbSeek( xFilial("VV1") + VVA->VVA_CHAINT , .f. )
		Do Case
			Case Alltrim(VV1->VV1_PROVEI) + Alltrim(VV0->VV0_TIPFAT) == "10"
				cSeekDev := "01" // Nac.Novos
			Case Alltrim(VV1->VV1_PROVEI) + Alltrim(VV0->VV0_TIPFAT) == "11"
				cSeekDev := "02" // Nac.Usados
			Case Alltrim(VV1->VV1_PROVEI) + Alltrim(VV0->VV0_TIPFAT) == "20"
				cSeekDev := "03" // Imp.Novos
			Case Alltrim(VV1->VV1_PROVEI) + Alltrim(VV0->VV0_TIPFAT) == "21"
				cSeekDev := "04" // Imp.Usados
		EndCase
		DbSelectArea("VV2")
		DbSetOrder(1)
		DbSeek(xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )
		cSeekDev += VV2->VV2_DESMOD
	ElseIf SF2->F2_PREFORI == cPrefBAL // BALCAO
		cSeekDev := "10"+(cAliasSD1)->(D1_GRUPO)
		DbSelectArea( "VS1" )
		DbSetOrder(3)
		DbSeek( xFilial("VS1") + SF2->F2_DOC + SF2->F2_SERIE )
		cDpto := VS1->VS1_DEPTO
	ElseIf SF2->F2_PREFORI == cPrefOFI // OFICINA
		DbSelectArea( "VO3" )
		DbSetOrder(5)
		DbSeek( xFilial("VO3") + (cAliasSD1)->(D1_NFORI) + (cAliasSD1)->(D1_SERIORI) , .f. )
		DbSelectArea( "VOI" )
		DbSetOrder(1)
		DbSeek( xFilial("VOI") + VO3->VO3_TIPTEM , .f. )
		cSeekDev := "2"+VOI->VOI_SITTPO+(cAliasSD1)->(D1_GRUPO)
		DbSelectArea( "VOO" )
		DbSetOrder(4)
		DbSeek( xFilial("VOO") + (cAliasSD1)->(D1_NFORI) + (cAliasSD1)->(D1_SERIORI) , .f. )
		cDpto := VOO->VOO_DEPTO
	EndIf
	nPos := aScan(aNumDev,{|x| x[10]+x[12] == cSeekDev + cDpto })
	If nPos == 0
		DbSelectArea( "SBM" )
		DbSetOrder(1)
		DbSeek( xFilial("SBM") + (cAliasSD1)->(D1_GRUPO) , .f. )
		vD1ResEc := (cAliasSD1)->(D1_TOTAL)+(cAliasSD1)->(D1_VALIPI)+(cAliasSD1)->(D1_ICMSRET)+(cAliasSD1)->(D1_DESPESA)+(cAliasSD1)->(D1_VALFRE)+(cAliasSD1)->(D1_SEGURO)-(cAliasSD1)->(D1_CUSTO)
		if (cAliasSD1)->(F4_CREDICM)=="S"
			vD1ResEc -= (cAliasSD1)->(D1_VALICM)
		endif
		if (cAliasSD1)->(F4_PISCRED)=="1"
			vD1ResEc -= ((cAliasSD1)->(D1_VALIMP5)-(cAliasSD1)->(D1_VALIMP6))
		endif
		aAdd(aNumDev,{ (cAliasSD1)->(D1_GRUPO) , left(SBM->BM_DESC,16) , nVlrDev , nImpDev , (cAliasSD1)->(D1_VALICM) , (cAliasSD1)->(D1_VALISS) , nPisDev , nCofDev , (cAliasSD1)->(D1_CUSTO) , cSeekDev , nVlrDev - ( nImpDev + (cAliasSD1)->(D1_CUSTO) ) , cDpto , vD1ResEc })
		If Type("aAnaDev") == "A"
			DbSelectArea( "SA1" )
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + (cAliasSD1)->(D1_FORNECE) + (cAliasSD1)->(D1_LOJA) )
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek( xFilial("SB1") + (cAliasSD1)->(D1_COD ))
			aadd(aAnaDev,{SM0->M0_CODIGO,SM0->M0_CODFIL,(cAliasSD1)->(D1_DOC),(cAliasSD1)->(D1_SERIE),"DV",SA1->A1_COD+SA1->A1_LOJA+LEFT(SA1->A1_NREDUZ,20),SB1->B1_GRUPO,SB1->B1_CODITE,SB1->B1_DESC,nVlrDev, nImpDev,(cAliasSD1)->(D1_CUSTO),stod((cAliasSD1)->(D1_DTDIGIT))})
			DbSelectArea("SF2")
			DbSetOrder(1)
			DbSeek(xFilial("SF2")+(cAliasSD1)->(D1_NFORI)+(cAliasSD1)->(D1_SERIORI)+(cAliasSD1)->(D1_FORNECE)+(cAliasSD1)->(D1_LOJA))
			DbSelectArea("SD2")
			DbSetOrder(2)
			DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+(cAliasSD1)->(D1_FORNECE)+(cAliasSD1)->(D1_LOJA)+(cAliasSD1)->(D1_COD) )
			Do Case
				Case SF2->F2_PREFORI == cPrefBAL
					aadd(aAnaPec,{SM0->M0_CODIGO,SM0->M0_CODFIL,SF2->F2_DOC,SF2->F2_SERIE,"PB",SA1->A1_COD+SA1->A1_LOJA+LEFT(SA1->A1_NREDUZ,20),SB1->B1_GRUPO,SB1->B1_CODITE,SB1->B1_DESC,nVlrDev*(-1), nImpDev*(-1),(cAliasSD1)->(D1_CUSTO)*(-1),stod((cAliasSD1)->(D1_DTDIGIT)),(cAliasSD1)->(D1_QUANT)})
				Case SF2->F2_PREFORI == cPrefOFI
					aadd(aAnaPec,{SM0->M0_CODIGO,SM0->M0_CODFIL,SF2->F2_DOC,SF2->F2_SERIE,"PO",SA1->A1_COD+SA1->A1_LOJA+LEFT(SA1->A1_NREDUZ,20),SB1->B1_GRUPO,SB1->B1_CODITE,SB1->B1_DESC,nVlrDev*(-1), nImpDev*(-1),(cAliasSD1)->(D1_CUSTO)*(-1),stod((cAliasSD1)->(D1_DTDIGIT)),(cAliasSD1)->(D1_QUANT)})
				Case SF2->F2_PREFORI == cPrefVEI
					aadd(aAnaVei,{SM0->M0_CODIGO,SM0->M0_CODFIL,SF2->F2_DOC,SF2->F2_SERIE,"V"+If(VV0->VV0_TIPFAT=="0","N",If(VV0->VV0_TIPFAT=="1","U","F")),SA1->A1_COD+SA1->A1_LOJA+LEFT(SA1->A1_NREDUZ,20),"VEI",VV1->VV1_CHAINT,VV1->VV1_CHASSI,nVlrDev*(-1), nImpDev*(-1),(cAliasSD1)->(D1_CUSTO)*(-1),stod((cAliasSD1)->(D1_DTDIGIT))})
			EndCase
		Endif
	Else
		aNumDev[nPos,3] += nVlrDev
		aNumDev[nPos,4] += nImpDev
		aNumDev[nPos,5] += (cAliasSD1)->(D1_VALICM)
		aNumDev[nPos,6] += (cAliasSD1)->(D1_VALISS)
		aNumDev[nPos,7] += nPisDev
		aNumDev[nPos,8] += nCofDev
		aNumDev[nPos,9] += (cAliasSD1)->(D1_CUSTO)
		aNumDev[nPos,11]+= nVlrDev - ( nImpDev + (cAliasSD1)->(D1_CUSTO ))
		aNumDev[nPos,13]+= vD1ResEc
		If Type("aAnaDev") == "A"
			DbSelectArea( "SA1" )
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + (cAliasSD1)->(D1_FORNECE) + (cAliasSD1)->(D1_LOJA ))
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek( xFilial("SB1") + (cAliasSD1)->(D1_COD ))
			aadd(aAnaDev,{SM0->M0_CODIGO,SM0->M0_CODFIL,(cAliasSD1)->(D1_DOC),(cAliasSD1)->(D1_SERIE),"DV",SA1->A1_COD+SA1->A1_LOJA+LEFT(SA1->A1_NREDUZ,20),SB1->B1_GRUPO,SB1->B1_CODITE,SB1->B1_DESC,nVlrDev, nImpDev,(cAliasSD1)->(D1_CUSTO),stod((cAliasSD1)->(D1_DTDIGIT))})
			DbSelectArea("SF2")
			DbSetOrder(1)
			DbSeek(xFilial("SF2")+(cAliasSD1)->(D1_NFORI)+(cAliasSD1)->(D1_SERIORI)+(cAliasSD1)->(D1_FORNECE)+(cAliasSD1)->(D1_LOJA))
			DbSelectArea("SD2")
			DbSetOrder(2)
			DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+(cAliasSD1)->(D1_FORNECE)+(cAliasSD1)->(D1_LOJA)+(cAliasSD1)->(D1_COD))
			Do Case
				Case SF2->F2_PREFORI == cPrefBAL
					aadd(aAnaPec,{SM0->M0_CODIGO,SM0->M0_CODFIL,(cAliasSD1)->(D1_DOC),(cAliasSD1)->(D1_SERIE),"PB",SA1->A1_COD+SA1->A1_LOJA+LEFT(SA1->A1_NREDUZ,20),SB1->B1_GRUPO,SB1->B1_CODITE,SB1->B1_DESC,nVlrDev*(-1), nImpDev*(-1),(cAliasSD1)->(D1_CUSTO)*(-1),stod((cAliasSD1)->(D1_DTDIGIT)),(cAliasSD1)->(D1_QUANT)})
				Case SF2->F2_PREFORI == cPrefOFI
					aadd(aAnaPec,{SM0->M0_CODIGO,SM0->M0_CODFIL,(cAliasSD1)->(D1_DOC),(cAliasSD1)->(D1_SERIE),"PO",SA1->A1_COD+SA1->A1_LOJA+LEFT(SA1->A1_NREDUZ,20),SB1->B1_GRUPO,SB1->B1_CODITE,SB1->B1_DESC,nVlrDev*(-1), nImpDev*(-1),(cAliasSD1)->(D1_CUSTO)*(-1),stod((cAliasSD1)->(D1_DTDIGIT)),(cAliasSD1)->(D1_QUANT)})
				Case SF2->F2_PREFORI == cPrefVEI
					aadd(aAnaVei,{SM0->M0_CODIGO,SM0->M0_CODFIL,(cAliasSD1)->(D1_DOC),(cAliasSD1)->(D1_SERIE),"V"+If(VV0->VV0_TIPFAT=="0","N",If(VV0->VV0_TIPFAT=="1","U","F")),SA1->A1_COD+SA1->A1_LOJA+LEFT(SA1->A1_NREDUZ,20),"VEI",VV1->VV1_CHAINT,VV1->VV1_CHASSI,nVlrDev*(-1), nImpDev*(-1),(cAliasSD1)->(D1_CUSTO)*(-1),stod((cAliasSD1)->(D1_DTDIGIT))})
			EndCase
		Endif
	EndIf
	(cAliasSD1)->(Dbskip())
EndDo
(cAliasSD1)->(DBCloseArea())
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ FS_OR25A ≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 03/01/02 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Impressao: Posicao das Vendas & Resultados                 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function FS_OR25AV() // Veiculos
Local ni
///////////////////////////////////
//    V  E  I  C  U  L  O  S     //
///////////////////////////////////
cString := Transform(aTotVei[1,1],"@E 999,999,999.99") ;	// Venda Total
+ Transform(aTotVei[1,2],"@E 99999,999.99") ;				// Impostos
+ Transform(aTotVei[1,3],"@E 99999,999.99") ;				// ICMS
+ space(11) ;
+ Transform(aTotVei[1,4],"@E 9999,999.99") ;				// PIS
+ Transform(aTotVei[1,5],"@E 9999,999.99") ;   				// Cofins
+ Transform(aTotVei[1,6],"@E 99,999,999.99") ;				// Custo Veic
+ Transform(aTotVei[1,8],"@E 99,999,999.99") + Transform(((aTotVei[1,8]/aTotVei[1,1])*100),"@E 9999.9") ;// Lucro Bruto
+ Transform(aTotVei[1,7],"@E 99,999,999.99") ;				// Juro Estq
+ Transform(aTotVei[1,9],"@E 99,999,999.99") ;				// Desp Var
+ Transform(aTotVei[1,10],"@E 99,999,999.99");				// Comissoes
+ Transform(aTotVei[1,11],"@E 99,999,999.99");				// Lucro Liq
+ Transform(aTotVei[1,12]+aTotVei[1,13],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
+ Transform(aTotVei[1,14],"@E 99,999,999.99") ;				// Resultado Final
+ Transform(aTotVei[1,15]/aTotVei[1,16],"@E 999,999,999.9") ; // Prz Medio
+ Transform((aTotVei[1,17]/aTotVei[1,1])*100,"@E 9999.9")	// % Desc
// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
//								+ Transform(aTotVei[1,12],"@E 99,999,999.99") ;// Cst/Dsp Fix
//								+ Transform(aTotVei[1,13],"@E 99,999,999.99") ;// Dsp Dep/Adm
//								+ Transform(aTotVei[1,14],"@E 99,999,999.99")  // Resultado Final
If FunName() == "OFIOR250"
	nLin++
	@ nLin++ , 00 psay STR0008 + cCabVei
	@ nLin++ , 00 psay STR0009 + FS_ImpR250(cString)
Else
	nLin+= 3
	fwrite(outputfile," "+CHR(13)+CHR(10))
	fwrite(outputfile,STR0008 + cCabVei+CHR(13)+CHR(10))
	cString += CHR(13)+CHR(10)
	fwrite(outputfile,STR0009 + FS_ImpR250(cString))
EndIf
If MV_PAR04 >= 2
	aSort(aNumVei,1,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3]})
	cMudou  := "9"
	cMudou2 := "9"
	For ni:=1 to Len(aNumVei)
		If nLin >= 60
			If FunName() == "OFIOR250"
				nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
				nLin++
				@ nLin++ , 27 psay cCabVei
				nLin++
			Else
				nLin := 4
				fwrite(outputfile," "+CHR(13)+CHR(10)+CHR(12))
				fwrite(outputfile,cTitulo+CHR(13)+CHR(10))            
				fwrite(outputfile,STR0102 +" "+cEmpr+"   "+STR0103+" "+cFil+space(10)+STR0104+str(nPagina++,4)+CHR(13)+CHR(10))
				fwrite(outputfile,STR0105 +" \AP5\RELATO\_R250_"+cFil+".##r"+CHR(13)+CHR(10)) //Empresa: # Filial: # Folha: # Arquivo:
				fwrite(outputfile," "+CHR(13)+CHR(10))
				fwrite(outputfile,space(27)+cCabVei+CHR(13)+CHR(10))
				fwrite(outputfile," "+CHR(13)+CHR(10))
			EndIf
		EndIf
		If cMudou # aNumVei[ni,1] .or. cMudou2 # aNumVei[ni,2]
			cTipo := STR0014
			Do Case
				Case aNumVei[ni,1] == "1" .and. aNumVei[ni,2] == "0"  	// Nacional Novo
					cTipo := STR0010
				Case aNumVei[ni,1] == "1" .and. aNumVei[ni,2] == "1" 	// Nacional Usado
					cTipo := STR0011
				Case aNumVei[ni,1] == "2" .and. aNumVei[ni,2] == "0" 	// Importado Novo
					cTipo := STR0012
				Case aNumVei[ni,1] == "2" .and. aNumVei[ni,2] == "1"	// Importado Usado
					cTipo := STR0013
				Case aNumVei[ni,1] == "8" .and. aNumVei[ni,2] == "8"	// Faturamento Direto
					cTipo := STR0062
			EndCase
			cMudou  := aNumVei[ni,1]
			cMudou2 := aNumVei[ni,2]
			nPos := aScan(aGrpVei,{|x| x[1] + x[2] == cMudou + cMudou2 })
			cString := Transform(aGrpVei[nPos,3],"@E 999,999,999.99") ;	// Venda Total
			+ Transform(aGrpVei[nPos,4],"@E 99999,999.99") ;			// Impostos
			+ Transform(aGrpVei[nPos,5],"@E 99999,999.99") ;			// ICMS
			+ space(11) ;
			+ Transform(aGrpVei[nPos,6],"@E 9999,999.99") ;				// PIS
			+ Transform(aGrpVei[nPos,7],"@E 9999,999.99") ;				// Cofins
			+ Transform(aGrpVei[nPos,8],"@E 99,999,999.99") ;			// Custos
			+ Transform(aGrpVei[nPos,10],"@E 99,999,999.99") + Transform(((aGrpVei[nPos,10]/aGrpVei[nPos,3])*100),"@E 9999.9") ; // Lucro Bruto
			+ Transform(aGrpVei[nPos,9],"@E 99,999,999.99") ;			// Juro Estoque
			+ Transform(aGrpVei[nPos,11],"@E 99,999,999.99") ;			// Desp Var
			+ Transform(aGrpVei[nPos,12],"@E 99,999,999.99") ;			// Comissoes
			+ Transform(aGrpVei[nPos,13],"@E 99,999,999.99") ;			// Lucro Liq
			+ Transform(aGrpVei[nPos,14]+aGrpVei[nPos,15],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
			+ Transform(aGrpVei[nPos,16],"@E 99,999,999.99") ;			// Resultado Final
			+ Transform(aGrpVei[nPos,18]/aGrpVei[nPos,19],"@E 999,999,999.9")	;// Prz Medio
			+ Transform((aGrpVei[nPos,20]/aGrpVei[nPos,3])*100,"@E 9999.9")	// % Desc
			// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
			//										+ Transform(aGrpVei[nPos,14],"@E 99,999,999.99") ;// Cst/Dsp Fix
			//										+ Transform(aGrpVei[nPos,15],"@E 99,999,999.99") ;// Dsp Dep/Adm
			//										+ Transform(aGrpVei[nPos,16],"@E 99,999,999.99")  // Resultado Final
			If FunName() == "OFIOR250"
				nLin++
				@ nLin++ , 01 psay cTipo + Transform(aGrpVei[nPos,17],"@E 9999") + FS_ImpR250(cString)
			Else
				nLin+= 2
				fwrite(outputfile," "+CHR(13)+CHR(10))
				cString += CHR(13)+CHR(10)
				fwrite(outputfile," "+ cTipo + Transform(aGrpVei[nPos,17],"@E 9999") + FS_ImpR250(cString))
			EndIf
		EndIf
		If MV_PAR04 >= 3
			If aNumVei[ni,18] > 0
				cString :=  Transform(aNumVei[ni,4],"@E 999,999,999.99") ;	// Venda Total
				+ Transform(aNumVei[ni,5],"@E 99999,999.99") ;				// Impostos
				+ Transform(aNumVei[ni,6],"@E 99999,999.99") ;				// ICMS
				+ space(11) ;
				+ Transform(aNumVei[ni,7],"@E 9999,999.99") ;	   			// PIS
				+ Transform(aNumVei[ni,8],"@E 9999,999.99") ;				// Cofins
				+ Transform(aNumVei[ni,9],"@E 99,999,999.99") ;				// Custos
				+ Transform(aNumVei[ni,11],"@E 99,999,999.99") + Transform(((aNumVei[ni,11]/aNumVei[ni,4])*100),"@E 9999.9") ; // Lucro Bruto
				+ Transform(aNumVei[ni,10],"@E 99,999,999.99") ;			// Juro Estoque
				+ Transform(aNumVei[ni,12],"@E 99,999,999.99") ; 			// Desp Var
				+ Transform(aNumVei[ni,13],"@E 99,999,999.99") ; 			// Comissoes
				+ Transform(aNumVei[ni,14],"@E 99,999,999.99") ;			// Lucro Liq
				+ Transform(aNumVei[ni,15]+aNumVei[ni,16],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
				+ Transform(aNumVei[ni,17],"@E 99,999,999.99") ;			// Resultado Final
				+ Transform(aNumVei[ni,20]/aNumVei[ni,21],"@E 999,999,999.9")	;// Prz Medio
				+ Transform((aNumVei[ni,22]/aNumVei[ni,4])*100,"@E 9999.9")	// % Desc
				// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
				//										+ Transform(aNumVei[ni,15],"@E 99,999,999.99") ;// Cst/Dsp Fix
				//										+ Transform(aNumVei[ni,16],"@E 99,999,999.99") ;// Dsp Dep/Adm
				//										+ Transform(aNumVei[ni,17],"@E 99,999,999.99")  // Resultado Final
				If FunName() == "OFIOR250"
					@ nLin++ , 00 psay "    " + left(aNumVei[ni,3],18) + Transform(aNumVei[ni,18],"@E 9999") + FS_ImpR250(cString)
				Else
					nLin++
					cString += CHR(13)+CHR(10)
					fwrite(outputfile,"    " + left(aNumVei[ni,3],18) + Transform(aNumVei[ni,18],"@E 9999") + FS_ImpR250(cString))
				EndIf
			Else
				If FunName() == "OFIOR250"
					@ nLin++ , 00 psay STR0076 + Transform(aNumVei[ni,4],"@E 9999,999,999.99") 	// Venda Total: Faturamento Direto
				Else
					nLin++
					fwrite(outputfile,STR0076 + Transform(aNumVei[ni,4],"@E 9999,999,999.99")+CHR(13)+CHR(10))
				EndIf
			EndIf
		EndIf
	Next
EndIf
If FunName() == "OFIOR250"
	nLin++
	@ nLin++ , 00 psay Repl("-",220)
Else
	nLin+= 2
	fwrite(outputfile," "+CHR(13)+CHR(10))
	fwrite(outputfile,Repl("-",220)+CHR(13)+CHR(10))
EndIf
Return

Function FS_OR25AP() // Pecas
Local cDpto := "???"
Local cImpDpto := "", ni
///////////////////////////////////
//        P  E  C  A  S          //
///////////////////////////////////
cString := Transform(aTotPec[1,1],"@E 999999,999.99");	// Venda Total //Manoel
+ Transform(aTotPec[1,2],"@E 99999,999.99") ;				// Impostos
+ Transform(aTotPec[1,3],"@E 99999,999.99") ;				// ICMS
+ space(11) ;
+ Transform(aTotPec[1,4],"@E 9999,999.99") ;				// PIS
+ Transform(aTotPec[1,5],"@E 9999,999.99") ;   				// Cofins
+ Transform(aTotPec[1,6],"@E 99,999,999.99") ;				// C.M.V.
+ Transform(aTotPec[1,8],"@E 99,999,999.99") + Transform(((aTotPec[1,8]/aTotPec[1,1])*100),"@E 9999.9") ;// Lucro Bruto
+ Transform(aTotPec[1,7],"@E 99,999,999.99") ;				// Juro Estoque
+ Transform(aTotPec[1,9],"@E 99,999,999.99") ;				// Desp Var
+ Transform(aTotPec[1,10],"@E 99,999,999.99");				// Comissoes
+ Transform(aTotPec[1,11],"@E 99,999,999.99");				// Lucro Liq
+ Transform(aTotPec[1,12]+aTotPec[1,13],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
+ Transform(aTotPec[1,14],"@E 99,999,999.99") ;				// Resultado Final
+ Transform(aTotPec[1,15]/aTotPec[1,16],"@E 999,999,999.9")	;// Prz Medio
+ Transform((aTotPec[1,17]/aTotPec[1,1])*100,"@E 9999.9")	// % Desc
// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
//										+ Transform(aTotPec[1,12],"@E 99,999,999.99") ;// Cst/Dsp Fix
//										+ Transform(aTotPec[1,13],"@E 99,999,999.99") ;// Dsp Dep/Adm
//										+ Transform(aTotPec[1,14],"@E 99,999,999.99")  // Resultado Final
If FunName() == "OFIOR250"
	nLin++
	@ nLin++ , 00 psay STR0015 + cCabPec
	@ nLin++ , 00 psay STR0016 + FS_ImpR250(cString)
Else
	nLin+= 3
	fwrite(outputfile," "+CHR(13)+CHR(10))
	fwrite(outputfile,STR0015 + cCabPec+CHR(13)+CHR(10))
	cString += CHR(13)+CHR(10)
	fwrite(outputfile,STR0016 +FS_ImpR250(cString))
EndIf
If MV_PAR04 >= 2
	aSort(aNumPec,1,,{|x,y| x[1]+x[18]+x[19]+x[2] < y[1]+y[18]+y[19]+y[2]})
	cMudou := "9"
	cMudou2:= "9"
	For ni:=1 to Len(aNumPec)
		If nLin >= 60
			If FunName() == "OFIOR250"
				nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
				nLin++
				@ nLin++ , 27 psay cCabPec
				nLin++
			Else
				nLin := 4
				fwrite(outputfile," "+CHR(13)+CHR(10)+CHR(12))
				fwrite(outputfile,cTitulo+CHR(13)+CHR(10))    //Empresa: # Filial: # Folha:
				fwrite(outputfile,STR0102 +" "+cEmpr+"   "+ STR0103 +" "+cFil+space(10)+ STR0104 +str(nPagina++,4)+CHR(13)+CHR(10))
				fwrite(outputfile,STR0105 +" \AP5\RELATO\_R250_"+cFil+".##r"+CHR(13)+CHR(10))
				fwrite(outputfile," "+CHR(13)+CHR(10))
				fwrite(outputfile,space(27)+cCabPec+CHR(13)+CHR(10))
				fwrite(outputfile," "+CHR(13)+CHR(10))
			EndIf
		EndIf
		If cMudou # aNumPec[ni,1]
			If aGrpPBO[1,2] > 0 .and. aNumPec[ni,1] == "B"
				nPos := 1
				cString := Transform(aGrpPBO[nPos,2],"@E 999999,999.99");	//Venda Total
				+ Transform(aGrpPBO[nPos,3],"@E 99999,999.99") ;			// Impostos
				+ Transform(aGrpPBO[nPos,4],"@E 99999,999.99") ;			// ICMS
				+ space(11) ;
				+ Transform(aGrpPBO[nPos,5],"@E 9999,999.99") ;				// PIS
				+ Transform(aGrpPBO[nPos,6],"@E 9999,999.99") ;				// Cofins
				+ Transform(aGrpPBO[nPos,7],"@E 99,999,999.99") ;			// C.M.V.
				+ Transform(aGrpPBO[nPos,9],"@E 99,999,999.99") + Transform(((aGrpPBO[nPos,9]/aGrpPBO[nPos,2])*100),"@E 9999.9") ;// Lucro Bruto
				+ Transform(aGrpPBO[nPos,8],"@E 99,999,999.99") ;			// Juro Estoque
				+ Transform(aGrpPBO[nPos,10],"@E 99,999,999.99");			// Desp Var
				+ Transform(aGrpPBO[nPos,11],"@E 99,999,999.99");			// Comissoes
				+ Transform(aGrpPBO[nPos,12],"@E 99,999,999.99");			// Lucro Liq
				+ Transform(aGrpPBO[nPos,13]+aGrpPBO[nPos,14],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
				+ Transform(aGrpPBO[nPos,15],"@E 99,999,999.99") ;			// Resultado Final
				+ Transform(aGrpPBO[nPos,16]/aGrpPBO[nPos,17],"@E 999,999,999.9") ;	// Prz Medio
				+ Transform((aGrpPBO[nPos,18]/aGrpPBO[nPos,2])*100,"@E 9999.9")	// % Desc
				// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
				//					  								+ Transform(aGrpPBO[nPos,13],"@E 99,999,999.99") ;// Cst/Dsp Fix
				//					  								+ Transform(aGrpPBO[nPos,14],"@E 99,999,999.99") ;// Dsp Dep/Adm
				//					  								+ Transform(aGrpPBO[nPos,15],"@E 99,999,999.99")  // Resultado Final
				If FunName() == "OFIOR250"
					nLin++
					@ nLin++ , 00 psay STR0017 + FS_ImpR250(cString)
				Else
					nLin+= 2
					fwrite(outputfile," "+CHR(13)+CHR(10))
					cString += CHR(13)+CHR(10)
					fwrite(outputfile,STR0017 + FS_ImpR250(cString))
				EndIf
			EndIf
			If aGrpPBO[2,2] > 0 .and. aNumPec[ni,1] == "O"
				nPos := 2
				cString := Transform(aGrpPBO[nPos,2],"@E 999999,999.99");	//Venda Total
				+ Transform(aGrpPBO[nPos,3],"@E 99999,999.99") ;			// Impostos
				+ Transform(aGrpPBO[nPos,4],"@E 99999,999.99") ;			// ICMS
				+ space(11) ;
				+ Transform(aGrpPBO[nPos,5],"@E 9999,999.99") ;				// PIS
				+ Transform(aGrpPBO[nPos,6],"@E 9999,999.99") ;				// Cofins
				+ Transform(aGrpPBO[nPos,7],"@E 99,999,999.99") ;			// C.M.V.
				+ Transform(aGrpPBO[nPos,9],"@E 99,999,999.99") + Transform(((aGrpPBO[nPos,9]/aGrpPBO[nPos,2])*100),"@E 9999.9") ;// Lucro Bruto
				+ Transform(aGrpPBO[nPos,8],"@E 99,999,999.99") ;			// Juro Estoque
				+ Transform(aGrpPBO[nPos,10],"@E 99,999,999.99");			// Desp Var
				+ Transform(aGrpPBO[nPos,11],"@E 99,999,999.99");			// Comissoes
				+ Transform(aGrpPBO[nPos,12],"@E 99,999,999.99");			// Lucro Liq
				+ Transform(aGrpPBO[nPos,13]+aGrpPBO[nPos,14],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
				+ Transform(aGrpPBO[nPos,15],"@E 99,999,999.99") ;			// Resultado Final
				+ Transform(aGrpPBO[nPos,16]/aGrpPBO[nPos,17],"@E 999,999,999.9") ;	// Prz Medio
				+ Transform((aGrpPBO[nPos,18]/aGrpPBO[nPos,2])*100,"@E 9999.9")	// % Desc
				// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
				//					  								+ Transform(aGrpPBO[nPos,13],"@E 99,999,999.99") ;// Cst/Dsp Fix
				//					  								+ Transform(aGrpPBO[nPos,14],"@E 99,999,999.99") ;// Dsp Dep/Adm
				//					  								+ Transform(aGrpPBO[nPos,15],"@E 99,999,999.99")  // Resultado Final
				If FunName() == "OFIOR250"
					nLin++
					@ nLin++ , 00 psay STR0018 + FS_ImpR250(cString)
				Else
					nLin+= 2
					fwrite(outputfile," "+CHR(13)+CHR(10))
					cString += CHR(13)+CHR(10)
					fwrite(outputfile,STR0018 + FS_ImpR250(cString))
				EndIf
			EndIf
			cMudou := aNumPec[ni,1]
		EndIf
		If cMudou2 # aNumPec[ni,18] .and. aNumPec[ni,18] # "9"
			cMudou2 := aNumPec[ni,18]
			cDpto := "???"
			Do Case
				Case cMudou2 == "1"
					cTipo := STR0019
				Case cMudou2 == "2"
					cTipo := STR0020
				Case cMudou2 == "3"
					cTipo := STR0021
				Case cMudou2 == "4"
					cTipo := STR0022
			EndCase
			nPos := aScan(aGrpPec,{|x| x[16] == cMudou2 })
			if nPos # 0
				cString := Transform(aGrpPec[nPos,2],"@E 999,999,999.99");		// Venda Total
				+ Transform(aGrpPec[nPos,3],"@E 99999,999.99") ;				// Impostos
				+ Transform(aGrpPec[nPos,4],"@E 99999,999.99") ;   				// ICMS
				+ space(11) ;
				+ Transform(aGrpPec[nPos,5],"@E 9999,999.99") ;			   		// PIS
				+ Transform(aGrpPec[nPos,6],"@E 9999,999.99") ;					// Cofins
				+ Transform(aGrpPec[nPos,7],"@E 99,999,999.99");   				// C.M.V.
				+ Transform(aGrpPec[nPos,9],"@E 99,999,999.99") + Transform(((aGrpPec[nPos,9]/aGrpPec[nPos,2])*100),"@E 9999.9");//Lucro Bruto
				+ Transform(aGrpPec[nPos,8],"@E 99,999,999.99");				// Juro Estoque
				+ Transform(aGrpPec[nPos,10],"@E 99,999,999.99");				// Desp Var
				+ Transform(aGrpPec[nPos,11],"@E 99,999,999.99");				// Comissoes
				+ Transform(aGrpPec[nPos,12],"@E 99,999,999.99");				// Lucro Liq
				+ Transform(aGrpPec[nPos,13]+aGrpPec[nPos,14],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
				+ Transform(aGrpPec[nPos,15],"@E 99,999,999.99") ;				// Resultado Final
				+ Transform(aGrpPec[nPos,17]/aGrpPec[nPos,18],"@E 999,999,999.9") ;	// Prz Medio
				+ Transform((aGrpPec[nPos,19]/aGrpPec[nPos,2])*100,"@E 9999.9")	// % Desc
				// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
				//					  								+ Transform(aGrpPec[nPos,13],"@E 99,999,999.99") ;// Cst/Dsp Fix
				//					  								+ Transform(aGrpPec[nPos,14],"@E 99,999,999.99") ;// Dsp Dep/Adm
				//					  								+ Transform(aGrpPec[nPos,15],"@E 99,999,999.99")  // Resultado Final
			Else
				cString := ""
			EndIf
			If FunName() == "OFIOR250"
				nLin++
				@ nLin++ , 00 psay "  " + cTipo + FS_ImpR250(cString)
			Else
				nLin+= 2
				fwrite(outputfile," "+CHR(13)+CHR(10))
				cString += CHR(13)+CHR(10)
				fwrite(outputfile,"  " + cTipo + FS_ImpR250(cString))
			EndIf
		EndIf
		If MV_PAR04 >= 2
			If cDpto # aNumPec[ni,19]
				cDpto := aNumPec[ni,19]
				nPos := aScan(aDpto,{|x| x[1]+x[17]+x[18] == cDpto+aNumPec[ni,1]+aNumPec[ni,18] })
				If nPos > 0
					If aNumPec[ni,1] == "B"
						If MV_PAR04 >= 3 .or. Empty(aDpto[nPos,1])
							nLin++
						EndIf
						cImpDpto := " " + If(!Empty(aDpto[nPos,1]),aDpto[nPos,1],"---") + " " + left(If(left(aDpto[nPos,16],3)#"...",aDpto[nPos,16],"")+repl(".",21),21)
					Else
						cImpDpto := "  " + If(!Empty(aDpto[nPos,1]),aDpto[nPos,1],"---") + " " + left(If(left(aDpto[nPos,16],3)#"...",aDpto[nPos,16],"")+repl(".",20),20)
					EndIf
					cString := Transform(aDpto[nPos,2],"@E 999,999,999.99") ;	// Venda Total
					+ Transform(aDpto[nPos,3],"@E 99999,999.99") ;	// Impostos
					+ Transform(aDpto[nPos,4],"@E 99999,999.99") ;	// ICMS
					+ space(11) ;
					+ Transform(aDpto[nPos,5],"@E 9999,999.99") ;	// PIS
					+ Transform(aDpto[nPos,6],"@E 9999,999.99") ;	// Cofins
					+ Transform(aDpto[nPos,7],"@E 99,999,999.99"); // C.M.V.
					+ Transform(aDpto[nPos,9],"@E 99,999,999.99") + Transform(((aDpto[nPos,9]/aDpto[nPos,2])*100),"@E 9999.9");//Lucro Bruto
					+ Transform(aDpto[nPos,8],"@E 99,999,999.99");	// Juro Estoque
					+ Transform(aDpto[nPos,10],"@E 99,999,999.99");// Desp Var
					+ Transform(aDpto[nPos,11],"@E 99,999,999.99");// Comissoes
					+ Transform(aDpto[nPos,12],"@E 99,999,999.99");// Lucro Liq
					+ Transform(aDpto[nPos,13]+aDpto[nPos,14],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
					+ Transform(aDpto[nPos,15],"@E 99,999,999.99") ;// Resultado Final
					+ Transform(aDpto[nPos,19]/aDpto[nPos,20],"@E 999,999,999.9")	;// Prz Medio
					+ Transform((aDpto[nPos,21]/aDpto[nPos,2])*100,"@E 9999.9")	// % Desc
					// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
					//				  								+ Transform(aDpto[nPos,13],"@E 99,999,999.99") ;// Cst/Dsp Fix
					//				  								+ Transform(aDpto[nPos,14],"@E 99,999,999.99") ;// Dsp Dep/Adm
					//				  								+ Transform(aDpto[nPos,15],"@E 99,999,999.99")  // Resultado Final
					If FunName() == "OFIOR250"
						@ nLin++ , 00 psay cImpDpto + FS_ImpR250(cString)
					Else
						nLin++
						fwrite(outputfile," "+CHR(13)+CHR(10))
						cString += CHR(13)+CHR(10)
						fwrite(outputfile, cImpDpto + FS_ImpR250(cString))
					EndIf
				EndIf
			EndIf
		EndIf
		If (MV_PAR04 >= 3 .and. ((!Empty(alltrim(aNumPec[ni,2]))) .and. (!Empty(alltrim(aNumPec[ni,3]))) .and. (aNumPec[ni,4] # 0)))
			If ( aNumPec[ni,1]+aNumPec[ni,2] # "BDEV" )
				cString := Transform(aNumPec[ni,4],"@E 999,999,999.99") ;	// Venda Total
				+ Transform(aNumPec[ni,5],"@E 99999,999.99") ;	// Impostos
				+ Transform(aNumPec[ni,6],"@E 99999,999.99") ;	// ICMS
				+ space(11) ;
				+ Transform(aNumPec[ni,7],"@E 9999,999.99") ;		// PIS
				+ Transform(aNumPec[ni,8],"@E 9999,999.99") ;		// Cofins
				+ Transform(aNumPec[ni,9],"@E 99,999,999.99") ;	// C.M.V.
				+ Transform(aNumPec[ni,11],"@E 99,999,999.99")	 + Transform(((aNumPec[ni,11]/aNumPec[ni,4])*100),"@E 9999.9");//Lucro Bruto
				+ Transform(aNumPec[ni,10],"@E 99,999,999.99");	// Juro Estoque
				+ Transform(aNumPec[ni,12],"@E 99,999,999.99");	// Desp Var
				+ Transform(aNumPec[ni,13],"@E 99,999,999.99");	// Comissoes
				+ Transform(aNumPec[ni,14],"@E 99,999,999.99");	// Lucro Liq
				+ Transform(aNumPec[ni,15]+aNumPec[ni,16],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
				+ Transform(aNumPec[ni,17],"@E 99,999,999.99") ;// Resultado Final
				+ Transform(aNumPec[ni,20]/aNumPec[ni,21],"@E 999,999,999.9")	; // Prz Medio
				+ Transform((aNumPec[ni,22]/aNumPec[ni,4])*100,"@E 9999.9")	// % Desc
				// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
				//				  										+ Transform(aNumPec[ni,15],"@E 99,999,999.99") ;// Cst/Dsp Fix
				//				  										+ Transform(aNumPec[ni,16],"@E 99,999,999.99") ;// Dsp Dep/Adm
				//				  										+ Transform(aNumPec[ni,17],"@E 99,999,999.99")  // Resultado Final
				If FunName() == "OFIOR250"
					@ nLin++ , 00 psay "    " + aNumPec[ni,2] + " " + left(aNumPec[ni,3],If(MV_PAR05==1,17,15)) + FS_ImpR250(cString)
				Else
					nLin++
					cString += CHR(13)+CHR(10)
					fwrite(outputfile,"    " + aNumPec[ni,2] + " " + left(aNumPec[ni,3],If(MV_PAR05==1,17,15)) + FS_ImpR250(cString))
				EndIf
			EndIf
		EndIf
	Next
EndIf
If FunName() == "OFIOR250"
	nLin++
	@ nLin++ , 00 psay Repl("-",220)
Else
	nLin+= 2
	fwrite(outputfile," "+CHR(13)+CHR(10))
	fwrite(outputfile,Repl("-",220)+CHR(13)+CHR(10))
EndIf
Return

Function FS_OR25AS // Servicos
Local cDpto := "???"
Local cImpDpto := "", ni
///////////////////////////////////
//    S  E  R  V  I  C  O  S     //
///////////////////////////////////
cString := Transform(aTotSrv[1,1],"@E 999999,999.99"); // Venda Total
+ Transform(aTotSrv[1,2],"@E 99999,999.99");	// Impostos
+ space(12) ;
+ Transform(aTotSrv[1,3],"@E 9999,999.99") ;	// ISS
+ Transform(aTotSrv[1,4],"@E 9999,999.99") ;	// PIS
+ Transform(aTotSrv[1,5],"@E 9999,999.99") ;	// Cofins
+ Transform(aTotSrv[1,6],"@E 99,999,999.99");	// Custo Srv
+ Transform(aTotSrv[1,7],"@E 99,999,999.99") + Transform(((aTotSrv[1,7]/aTotSrv[1,1])*100),"@E 9999.9");// Lucro Bruto
+ space(13) ;
+ Transform(aTotSrv[1,8],"@E 99,999,999.99");	// Desp Var
+ Transform(aTotSrv[1,9],"@E 99,999,999.99");	// Comissoes
+ Transform(aTotSrv[1,10],"@E 99,999,999.99");// Lucro Liq
+ Transform(aTotSrv[1,11]+aTotSrv[1,12],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
+ Transform(aTotSrv[1,13],"@E 99,999,999.99") ;// Resultado Final
+ Transform(aTotSrv[1,14]/aTotSrv[1,15],"@E 999,999,999.9") ;  // Prz Medio
+ Transform((aTotSrv[1,16]/aTotSrv[1,1])*100,"@E 9999.9")  // % Desc
// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
//									+ Transform(aTotSrv[1,11],"@E 99,999,999.99") ;// Cst/Dsp Fix
//									+ Transform(aTotSrv[1,12],"@E 99,999,999.99") ;// Dsp Dep/Adm
//									+ Transform(aTotSrv[1,13],"@E 99,999,999.99")  // Resultado Final
If FunName() == "OFIOR250"
	nLin++
	@ nLin++ , 00 psay STR0023 + cCabSrv
	@ nLin++ , 00 psay STR0024 + FS_ImpR250(cString)
Else
	nLin+= 3
	fwrite(outputfile," "+CHR(13)+CHR(10))
	fwrite(outputfile,STR0023 + cCabSrv+CHR(13)+CHR(10))
	cString += CHR(13)+CHR(10)
	fwrite(outputfile,STR0024 + FS_ImpR250(cString))
EndIf
If MV_PAR04 >= 2
	aSort(aNumSrv,1,,{|x,y| x[1]+x[17]+x[2] < y[1]+y[17]+y[2]})
	cMudou := "9"
	For ni:=1 to Len(aNumSrv)
		If nLin >= 60
			If FunName() == "OFIOR250"
				nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
				nLin++
				@ nLin++ , 27 psay cCabSrv
				nLin++
			Else
				nLin := 4
				fwrite(outputfile," "+CHR(13)+CHR(10)+CHR(12))
				fwrite(outputfile,cTitulo+CHR(13)+CHR(10))
				fwrite(outputfile,STR0102 +" "+cEmpr+"   "+STR0103+" "+cFil+space(10)+ STR0104 +str(nPagina++,4)+CHR(13)+CHR(10))
				fwrite(outputfile,STR0105 +" \AP5\RELATO\_R250_"+cFil+".##r"+CHR(13)+CHR(10))  //Empresa: # Filial: # Folha: # Arquivo:
				fwrite(outputfile," "+CHR(13)+CHR(10))
				fwrite(outputfile,space(27)+cCabSrv+CHR(13)+CHR(10))
				fwrite(outputfile," "+CHR(13)+CHR(10))
			EndIf
		EndIf
		If cMudou # aNumSrv[ni,1]
			cDpto := "???"
			Do Case
				Case aNumSrv[ni,1] == "1"
					cTipo := STR0019
				Case aNumSrv[ni,1] == "2"
					cTipo := STR0020
				Case aNumSrv[ni,1] == "3"
					cTipo := STR0021
				Case aNumSrv[ni,1] == "4"
					cTipo := STR0022
			EndCase
			cMudou := aNumSrv[ni,1]
			nPos := aScan(aGrpSrv,{|x| x[1] == cMudou })
			cString := Transform(aGrpSrv[nPos,2],"@E 999,999,999.99"); // Venda Total
			+ Transform(aGrpSrv[nPos,3],"@E 99999,999.99");	// Impostos
			+ space(12);
			+ Transform(aGrpSrv[nPos,4],"@E 9999,999.99");	// ISS
			+ Transform(aGrpSrv[nPos,5],"@E 9999,999.99");	// PIS
			+ Transform(aGrpSrv[nPos,6],"@E 9999,999.99");	// Cofins
			+ Transform(aGrpSrv[nPos,7],"@E 99,999,999.99");	// Custo Srv
			+ Transform(aGrpSrv[nPos,8],"@E 99,999,999.99") + Transform(((aGrpSrv[nPos,8]/aGrpSrv[nPos,2])*100),"@E 9999.9") ;//Lucro Bruto
			+ space(13);
			+ Transform(aGrpSrv[nPos,9],"@E 99,999,999.99");	// Desp Var
			+ Transform(aGrpSrv[nPos,10],"@E 99,999,999.99");// Comissoes
			+ Transform(aGrpSrv[nPos,11],"@E 99,999,999.99");// Lucro Liq
			+ Transform(aGrpSrv[nPos,12]+aGrpSrv[nPos,13],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
			+ Transform(aGrpSrv[nPos,14],"@E 99,999,999.99") ;// Resultado Final
			+ Transform(aGrpSrv[nPos,15]/aGrpSrv[nPos,16],"@E 999,999,999.9") ; // Prz Medio
			+ Transform((aGrpSrv[nPos,17]/aGrpSrv[nPos,2])*100,"@E 9999.9") // % Desc
			// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
			//												+ Transform(aGrpSrv[nPos,12],"@E 99,999,999.99") ;// Cst/Dsp Fix
			//												+ Transform(aGrpSrv[nPos,13],"@E 99,999,999.99") ;// Dsp Dep/Adm
			//												+ Transform(aGrpSrv[nPos,14],"@E 99,999,999.99")  // Resultado Final
			If FunName() == "OFIOR250"
				nLin++
				@ nLin++ , 00 psay "  " + cTipo + FS_ImpR250(cString)
			Else
				nLin+= 2
				fwrite(outputfile," "+CHR(13)+CHR(10))
				cString += CHR(13)+CHR(10)
				fwrite(outputfile,"  " + cTipo + FS_ImpR250(cString))
			EndIf
		EndIf
		If MV_PAR04 >= 2
			If cDpto # aNumSrv[ni,17]
				cDpto := aNumSrv[ni,17]
				nPos := aScan(aDpto,{|x| x[1]+x[17]+x[18] == cDpto+"S"+aNumSrv[ni,1] })
				cImpDpto := "  " + If(!Empty(aDpto[nPos,1]),aDpto[nPos,1],"---") + " " + left(If(left(aDpto[nPos,16],3)#"...",aDpto[nPos,16],"")+repl(".",20),20)
				cString := Transform(aDpto[nPos,2],"@E 999,999,999.99") ;	// Venda Total
				+ Transform(aDpto[nPos,3],"@E 99999,999.99") ;	// Impostos
				+ space(12) ;
				+ Transform(aDpto[nPos,4],"@E 9999,999.99") ;	// ISS
				+ Transform(aDpto[nPos,5],"@E 9999,999.99") ;	// PIS
				+ Transform(aDpto[nPos,6],"@E 9999,999.99") ;	// Cofins
				+ Transform(aDpto[nPos,7],"@E 99,999,999.99"); // C.M.V.
				+ Transform(aDpto[nPos,8],"@E 99,999,999.99") + Transform(((aDpto[nPos,8]/aDpto[nPos,2])*100),"@E 9999.9");//Lucro Bruto
				+ space(13) ;
				+ Transform(aDpto[nPos,9],"@E 99,999,999.99"); // Desp Var
				+ Transform(aDpto[nPos,10],"@E 99,999,999.99");// Comissoes
				+ Transform(aDpto[nPos,11],"@E 99,999,999.99");// Lucro Liq
				+ Transform(aDpto[nPos,12]+aDpto[nPos,13],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
				+ Transform(aDpto[nPos,14],"@E 99,999,999.99") ;// Resultado Final
				+ Transform(aDpto[nPos,19]/aDpto[nPos,20],"@E 999,999,999.9")	; // Prz Medio
				+ Transform((aDpto[nPos,21]/aDpto[nPos,2])*100,"@E 9999.9")	// % Desc
				// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
				//				  								+ Transform(aDpto[nPos,12],"@E 99,999,999.99") ;// Cst/Dsp Fix
				//				  								+ Transform(aDpto[nPos,13],"@E 99,999,999.99") ;// Dsp Dep/Adm
				//				  								+ Transform(aDpto[nPos,14],"@E 99,999,999.99")  // Resultado Final
				If FunName() == "OFIOR250"
					@ nLin++ , 00 psay cImpDpto + FS_ImpR250(cString)
				Else
					nLin++
					fwrite(outputfile," "+CHR(13)+CHR(10))
					cString += CHR(13)+CHR(10)
					fwrite(outputfile, cImpDpto + FS_ImpR250(cString))
				EndIf
			EndIf
		EndIf
		If MV_PAR04 >= 3
			cString := Transform(aNumSrv[ni,4],"@E 999,999,999.99") ;	// Venda Total
			+ Transform(aNumSrv[ni,5],"@E 99999,999.99") ;	// Impostos
			+ space(12);
			+ Transform(aNumSrv[ni,6],"@E 9999,999.99");		// ISS
			+ Transform(aNumSrv[ni,7],"@E 9999,999.99");		// PIS
			+ Transform(aNumSrv[ni,8],"@E 9999,999.99");		// Cofins
			+ Transform(aNumSrv[ni,9],"@E 99,999,999.99");	// Custo Srv
			+ Transform(aNumSrv[ni,10],"@E 99,999,999.99")	+ Transform(((aNumSrv[ni,10]/aNumSrv[ni,4])*100),"@E 9999.9");//Lucro Bruto
			+ space(13);
			+ Transform(aNumSrv[ni,11],"@E 99,999,999.99");	// Desp Var
			+ Transform(aNumSrv[ni,12],"@E 99,999,999.99");	// Comissoes
			+ Transform(aNumSrv[ni,13],"@E 99,999,999.99");	// Lucro Liq
			+ Transform(aNumSrv[ni,14]+aNumSrv[ni,15],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
			+ Transform(aNumSrv[ni,16],"@E 99,999,999.99") ;// Resultado Final
			+ Transform(aNumSrv[ni,18]/aNumSrv[ni,19],"@E 999,999,999.9")	; // Prz Medio
			+ Transform((aNumSrv[ni,20]/aNumSrv[ni,4])*100,"@E 9999.9")	// % Desc
			// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
			//				  								+ Transform(aNumSrv[ni,14],"@E 99,999,999.99") ;// Cst/Dsp Fix
			//				  								+ Transform(aNumSrv[ni,15],"@E 99,999,999.99") ;// Dsp Dep/Adm
			//				  								+ Transform(aNumSrv[ni,16],"@E 99,999,999.99")  // Resultado Final
			If FunName() == "OFIOR250"
				@ nLin++ , 00 psay "    " + aNumSrv[ni,2] + " " + left(aNumSrv[ni,3],If(MV_PAR05==1,18,15)) + FS_ImpR250(cString)
			Else
				nLin++
				cString += CHR(13)+CHR(10)
				fwrite(outputfile,"    " + aNumSrv[ni,2] + " " + left(aNumSrv[ni,3],If(MV_PAR05==1,18,15)) + FS_ImpR250(cString))
			EndIf
		EndIf
	Next
EndIf
Return

Function FS_OR25AA() // Despesas Acessorias
///////////////////////////////////
// D E S P E S A S   A C E S S . //
///////////////////////////////////
If nLin >= 50
	If FunName() == "OFIOR250"
		nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
	Else
		nLin := 2
		fwrite(outputfile," "+CHR(13)+CHR(10)+CHR(12))
		fwrite(outputfile,cTitulo+CHR(13)+CHR(10))
		fwrite(outputfile,STR0102 +" "+cEmpr+"   "+ STR0103 +" "+cFil+space(10)+ STR0104 +str(nPagina++,4)+CHR(13)+CHR(10))
		fwrite(outputfile,STR0105 +" \AP5\RELATO\_R250_"+cFil+".##r"+CHR(13)+CHR(10))
	EndIf
EndIf
If FunName() == "OFIOR250"
	nLin++
	@ nLin++ , 00 psay Repl("-",220)
	nLin++
	@ nLin++ , 00 psay STR0042 + STR0044
	@ nLin++ , 00 psay STR0043 + Transform(aDesAce[1,2],"@E 99,999,999.99") + space(35) + Transform(aDesAce[1,3],"@E 9999,999.99") + Transform(aDesAce[1,4],"@E 9999,999.99")
	nLin++
Else
	nLin+= 6
	fwrite(outputfile," "+CHR(13)+CHR(10))
	fwrite(outputfile,Repl("-",220)+CHR(13)+CHR(10))
	fwrite(outputfile," "+CHR(13)+CHR(10))
	fwrite(outputfile,STR0042 + STR0044+CHR(13)+CHR(10))
	fwrite(outputfile,STR0043 + Transform(aDesAce[1,2],"@E 99,999,999.99") + space(35) + Transform(aDesAce[1,3],"@E 9999,999.99") + Transform(aDesAce[1,4],"@E 9999,999.99")+CHR(13)+CHR(10))
	fwrite(outputfile," "+CHR(13)+CHR(10))
EndIf
If MV_PAR04 >= 2
	If FunName() == "OFIOR250"
		@ nLin++ , 04 psay aDesAce[2,1] + Transform(aDesAce[2,2],"@E 999,999,999.99") + space(35) + Transform(aDesAce[2,3],"@E 9999,999.99") + Transform(aDesAce[2,4],"@E 9999,999.99")
		@ nLin++ , 04 psay aDesAce[3,1] + Transform(aDesAce[3,2],"@E 999,999,999.99") + space(35) + Transform(aDesAce[3,3],"@E 9999,999.99") + Transform(aDesAce[3,4],"@E 9999,999.99")
		@ nLin++ , 04 psay aDesAce[4,1] + Transform(aDesAce[4,2],"@E 999,999,999.99") + space(35) + Transform(aDesAce[4,3],"@E 9999,999.99") + Transform(aDesAce[4,4],"@E 9999,999.99")
		nLin++
	Else
		nLin+= 4
		fwrite(outputfile,space(4)+aDesAce[2,1] + Transform(aDesAce[2,2],"@E 999,999,999.99") + space(35) + Transform(aDesAce[2,3],"@E 9999,999.99") + Transform(aDesAce[2,4],"@E 9999,999.99")+CHR(13)+CHR(10))
		fwrite(outputfile,space(4)+aDesAce[3,1] + Transform(aDesAce[3,2],"@E 999,999,999.99") + space(35) + Transform(aDesAce[3,3],"@E 9999,999.99") + Transform(aDesAce[3,4],"@E 9999,999.99")+CHR(13)+CHR(10))
		fwrite(outputfile,space(4)+aDesAce[4,1] + Transform(aDesAce[4,2],"@E 999,999,999.99") + space(35) + Transform(aDesAce[4,3],"@E 9999,999.99") + Transform(aDesAce[4,4],"@E 9999,999.99")+CHR(13)+CHR(10))
		fwrite(outputfile," "+CHR(13)+CHR(10))
	EndIf
EndIf
Return

Function FS_OR25AO() // Outras Vendas
///////////////////////////////////
//  O U T R A S     V E N D A S  //
///////////////////////////////////
If nLin >= 58
	If FunName() == "OFIOR250"
		nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
	Else
		nLin := 2
		fwrite(outputfile," "+CHR(13)+CHR(10)+CHR(12))
		fwrite(outputfile,cTitulo+CHR(13)+CHR(10))
		fwrite(outputfile,STR0102 +" "+cEmpr+"   "+ STR0103 +" "+cFil+space(10)+ STR0104 +str(nPagina++,4)+CHR(13)+CHR(10))
		fwrite(outputfile,STR0105 +" \AP5\RELATO\_R250_"+cFil+".##r"+CHR(13)+CHR(10))
	EndIf
EndIf
cString := Transform(aTotOOpe[1,1],"@E 999999,999.99");//Venda Total
+ Transform(aTotOOpe[1,2],"@E 99999,999.99");		// Impostos
+ Transform(aTotOOpe[1,3],"@E 99999,999.99");		// ICMS
+ Transform(aTotOOpe[1,4],"@E 9999,999.99");		// ISS
+ Transform(aTotOOpe[1,5],"@E 9999,999.99");		// PIS
+ Transform(aTotOOpe[1,6],"@E 9999,999.99");		// Cofins
+ Transform(aTotOOpe[1,7],"@E 99,999,999.99");	// Custos
+ Transform(aTotOOpe[1,9],"@E 99,999,999.99") + Transform(((aTotOOpe[1,9]/aTotOOpe[1,1])*100),"@E 9999.9");//Lucro Bruto
+ Transform(aTotOOpe[1,8],"@E 99,999,999.99");	// Juro Estoque
+ Transform(aTotOOpe[1,10],"@E 99,999,999.99");	// Desp Var
+ Transform(aTotOOpe[1,11],"@E 99,999,999.99");	// Comissoes
+ Transform(aTotOOpe[1,12],"@E 99,999,999.99");	// Lucro Liq
+ Transform(aTotOOpe[1,13]+aTotOOpe[1,14],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
+ Transform(aTotOOpe[1,15],"@E 99,999,999.99") ;// Resultado Final
+ Transform(aTotOOpe[1,16]/aTotOOpe[1,17],"@E 999,999,999.9")	; // Prz Medio
+ Transform((aTotOOpe[1,18]/aTotOOpe[1,1])*100,"@E 9999.9")	// % Desc
// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
If FunName() == "OFIOR250"
	@ nLin++ , 00 psay Repl("-",220)
	nLin++
	@ nLin++ , 00 psay STR0035 + cCabTot
	@ nLin++ , 00 psay STR0036 + FS_ImpR250(cString)
Else
	nLin+= 4
	fwrite(outputfile,Repl("-",220)+CHR(13)+CHR(10))
	fwrite(outputfile," "+CHR(13)+CHR(10))
	fwrite(outputfile,STR0035 + cCabTot+CHR(13)+CHR(10))
	cString += CHR(13)+CHR(10)
	fwrite(outputfile,STR0036 + FS_ImpR250(cString))
EndIf
If MV_PAR04 >= 2
	nLucBru := aOOpeSrv[1,01]-aOOpeSrv[1,02]-aOOpeSrv[1,07]
	nLucLiq := nLucBru-aOOpeSrv[1,08]-aOOpeSrv[1,10]-aOOpeSrv[1,11]
	nResFin := nLucLiq-aOOpeSrv[1,13]-aOOpeSrv[1,14]
	cString := Transform(aOOpeSrv[1,1],"@E 999,999,999.99");//Venda Total
	+ Transform(aOOpeSrv[1,2],"@E 99999,999.99");		// Impostos
	+ Transform(aOOpeSrv[1,3],"@E 99999,999.99");		// ICMS
	+ Transform(aOOpeSrv[1,4],"@E 9999,999.99");		// ISS
	+ Transform(aOOpeSrv[1,5],"@E 9999,999.99");		// PIS
	+ Transform(aOOpeSrv[1,6],"@E 9999,999.99");		// Cofins
	+ Transform(aOOpeSrv[1,7],"@E 99,999,999.99");	// Custos
	+ Transform(nLucBru,"@E 99,999,999.99") + Transform(((nLucBru/aOOpeSrv[1,1])*100),"@E 9999.9");//Lucro Bruto
	+ Transform(aOOpeSrv[1,8],"@E 99,999,999.99");	// Juro Estoque
	+ Transform(aOOpeSrv[1,10],"@E 99,999,999.99");	// Desp Var
	+ Transform(aOOpeSrv[1,11],"@E 99,999,999.99");	// Comissoes
	+ Transform(nLucLiq,"@E 99,999,999.99");	// Lucro Liq
	+ Transform(aOOpeSrv[1,13]+aOOpeSrv[1,14],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
	+ Transform(nResFin,"@E 99,999,999.99") ;// Resultado Final
	+ Transform(aOOpeSrv[1,16]/aOOpeSrv[1,17],"@E 999,999,999.9")	; // Prz Medio
	+ Transform((aOOpeSrv[1,18]/aOOpeSrv[1,1])*100,"@E 9999.9")	// % Desc
	// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
	If FunName() == "OFIOR250"
		nLin++
		@ nLin++ , 04 psay STR0037 + FS_ImpR250(cString)
	Else
		nLin+= 3
		fwrite(outputfile," "+CHR(13)+CHR(10))
		cString += CHR(13)+CHR(10)
		fwrite(outputfile,space(4)+STR0037 + FS_ImpR250(cString))
   EndIf
	cString := Transform(aOOpeOut[1,1],"@E 999,999,999.99");//Venda Total
	+ Transform(aOOpeOut[1,2],"@E 99999,999.99");		// Impostos
	+ Transform(aOOpeOut[1,3],"@E 99999,999.99");		// ICMS
	+ Transform(aOOpeOut[1,4],"@E 9999,999.99");		// ISS
	+ Transform(aOOpeOut[1,5],"@E 9999,999.99");		// PIS
	+ Transform(aOOpeOut[1,6],"@E 9999,999.99");		// Cofins
	+ Transform(aOOpeOut[1,7],"@E 99,999,999.99");	// Custos
	+ Transform(aOOpeOut[1,9],"@E 99,999,999.99") + Transform(((aOOpeOut[1,9]/aOOpeOut[1,1])*100),"@E 9999.9");//Lucro Bruto
	+ Transform(aOOpeOut[1,8],"@E 99,999,999.99");	// Juro Estoque
	+ Transform(aOOpeOut[1,10],"@E 99,999,999.99");	// Desp Var
	+ Transform(aOOpeOut[1,11],"@E 99,999,999.99");	// Comissoes
	+ Transform(aOOpeOut[1,12],"@E 99,999,999.99");	// Lucro Liq
	+ Transform(aOOpeOut[1,13]+aOOpeOut[1,14],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
	+ Transform(aOOpeOut[1,15],"@E 99,999,999.99") ;// Resultado Final
	+ Transform(aOOpeOut[1,16]/aOOpeOut[1,17],"@E 999,999,999.9")	;// Prz Medio
	+ Transform((aOOpeOut[1,18]/aOOpeOut[1,1])*100,"@E 9999.9")	// % Desc
	// Manoel - 15/03/2005 - Inserir aqui, levantamento do Prazo medio
	If FunName() == "OFIOR250"
		@ nLin++ , 04 psay STR0038 + FS_ImpR250(cString)
	Else
		cString += CHR(13)+CHR(10)
		fwrite(outputfile,space(4)+STR0038 + FS_ImpR250(cString))
	EndIf
EndIf
If FunName() == "OFIOR250"
	nLin++
	@ nLin++ , 00 psay Repl("-",220)
Else
	nLin+= 2
	fwrite(outputfile," "+CHR(13)+CHR(10))
	fwrite(outputfile,Repl("-",220)+CHR(13)+CHR(10))
EndIf
Return

Function FS_OR25AM() // Ativo Imobilizado
Local ni
///////////////////////////////////
//  A T I V O   I M O B I L I Z. //
///////////////////////////////////
aSort(aNumAtiMob,1,,{|x,y| x[1]+x[2] < y[1]+y[2]})
If nLin >= 58
	If FunName() == "OFIOR250"
		nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
	Else
		nLin := 2
		fwrite(outputfile," "+CHR(13)+CHR(10)+CHR(12))
		fwrite(outputfile,cTitulo+CHR(13)+CHR(10))
		fwrite(outputfile,STR0102 +" "+cEmpr+"   "+ STR0103 +" "+cFil+space(10)+ STR0104 +str(nPagina++,4)+CHR(13)+CHR(10))
		fwrite(outputfile,STR0105 +" \AP5\RELATO\_R250_"+cFil+".##r"+CHR(13)+CHR(10))
	EndIf
EndIf
If FunName() == "OFIOR250"
	nLin++
	@ nLin++ , 00 psay STR0046 + STR0048
	@ nLin++ , 00 psay STR0047 + Transform(aTotAtiMob[1,3],"@E 99,999,999.99") + Transform(aTotAtiMob[1,4],"@E 99999,999.99") + Transform(aTotAtiMob[1,5],"@E 99999,999.99") + space(11) + Transform(aTotAtiMob[1,6],"@E 9999,999.99") + Transform(aTotAtiMob[1,7],"@E 9999,999.99") + Transform(aTotAtiMob[1,8],"@E 99,999,999.99")
Else
	nLin+= 3
	fwrite(outputfile," "+CHR(13)+CHR(10))
	fwrite(outputfile,STR0046 + STR0048+CHR(13)+CHR(10))
	fwrite(outputfile,STR0047 + Transform(aTotAtiMob[1,3],"@E 99,999,999.99") + Transform(aTotAtiMob[1,4],"@E 99999,999.99") + Transform(aTotAtiMob[1,5],"@E 99999,999.99") + space(11) + Transform(aTotAtiMob[1,6],"@E 9999,999.99") + Transform(aTotAtiMob[1,7],"@E 9999,999.99") + Transform(aTotAtiMob[1,8],"@E 99,999,999.99")+CHR(13)+CHR(10))
EndIf
If MV_PAR04 >= 2
	If Len(aNumAtiMob) > 0
		If FunName() == "OFIOR250"
			nLin++
		Else
			nLin++
			fwrite(outputfile," "+CHR(13)+CHR(10))
		EndIf
	EndIf
	For ni:=1 to Len(aNumAtiMob)
		If nLin >= 58
			If FunName() == "OFIOR250"
				nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
				nLin++
				@ nLin++ , 27 psay STR0048
				nLin++
			Else
				nLin := 4
				fwrite(outputfile," "+CHR(13)+CHR(10)+CHR(12))
				fwrite(outputfile,cTitulo+CHR(13)+CHR(10))
				fwrite(outputfile,STR0102 +" "+cEmpr+"   "+ STR0103 +" "+cFil+space(10)+ STR0104 +str(nPagina++,4)+CHR(13)+CHR(10))
				fwrite(outputfile,STR0105 +" \AP5\RELATO\_R250_"+cFil+".##r"+CHR(13)+CHR(10))
				fwrite(outputfile," "+CHR(13)+CHR(10))
				fwrite(outputfile,space(27)+STR0048+CHR(13)+CHR(10))
				fwrite(outputfile," "+CHR(13)+CHR(10))
			EndIf
		EndIf
		If cMudou # aNumAtiMob[ni,1]
			cMudou := aNumAtiMob[ni,1]
			nPos := aScan(aTotAtiMob,{|x| x[1] == cMudou })
			If MV_PAR04 >= 3
				If FunName() == "OFIOR250"
					nLin++
				Else
					nLin++
					fwrite(outputfile," "+CHR(13)+CHR(10))
				EndIf
			EndIf
			If	nPos > 0
				If FunName() == "OFIOR250"
					@ nLin++ , 05 psay aTotAtiMob[nPos,2] + Transform(aTotAtiMob[nPos,3],"@E 99,999,999.99") + Transform(aTotAtiMob[nPos,4],"@E 99999,999.99") + Transform(aTotAtiMob[nPos,5],"@E 99999,999.99") + space(11) + Transform(aTotAtiMob[nPos,6],"@E 9999,999.99") + Transform(aTotAtiMob[nPos,7],"@E 9999,999.99") + Transform(aTotAtiMob[nPos,8],"@E 99,999,999.99")
				Else
					nLin++
					fwrite(outputfile,space(5)+aTotAtiMob[nPos,2] + Transform(aTotAtiMob[nPos,3],"@E 99,999,999.99") + Transform(aTotAtiMob[nPos,4],"@E 99999,999.99") + Transform(aTotAtiMob[nPos,5],"@E 99999,999.99") + space(11) + Transform(aTotAtiMob[nPos,6],"@E 9999,999.99") + Transform(aTotAtiMob[nPos,7],"@E 9999,999.99") + Transform(aTotAtiMob[nPos,8],"@E 99,999,999.99")+CHR(13)+CHR(10))
				EndIf
			EndIf
		EndIf
		If MV_PAR04 >= 3
			If FunName() == "OFIOR250"
				@ nLin++ , 08 psay left(aNumAtiMob[ni,2],19) + Transform(aNumAtiMob[ni,3],"@E 99,999,999.99") + Transform(aNumAtiMob[ni,4],"@E 99999,999.99") + Transform(aNumAtiMob[ni,5],"@E 99999,999.99") + space(11) + Transform(aNumAtiMob[ni,6],"@E 9999,999.99") + Transform(aNumAtiMob[ni,7],"@E 9999,999.99") + Transform(aNumAtiMob[ni,8],"@E 99,999,999.99")
			Else
				nLin++
				fwrite(outputfile,space(8)+left(aNumAtiMob[ni,2],19) + Transform(aNumAtiMob[ni,3],"@E 99,999,999.99") + Transform(aNumAtiMob[ni,4],"@E 99999,999.99") + Transform(aNumAtiMob[ni,5],"@E 99999,999.99") + space(11) + Transform(aNumAtiMob[ni,6],"@E 9999,999.99") + Transform(aNumAtiMob[ni,7],"@E 9999,999.99") + Transform(aNumAtiMob[ni,8],"@E 99,999,999.99")+CHR(13)+CHR(10))
			EndIf
		EndIf
	Next
EndIf
If FunName() == "OFIOR250"
	nLin++
	@ nLin++ , 00 psay Repl("-",220)
Else
	nLin+= 2
	fwrite(outputfile," "+CHR(13)+CHR(10))
	fwrite(outputfile,Repl("-",220)+CHR(13)+CHR(10))
EndIf
Return

Function FS_OR25AD() // Devolucoes
Local ni
///////////////////////////////////
//      D E V O L U C O E S      //
///////////////////////////////////
aSort(aNumDev,1,,{|x,y| left(x[10],1)+x[12]+x[10]+x[2] < left(y[10],1)+y[12]+y[10]+y[2]})
If nLin >= 58
	If FunName() == "OFIOR250"
		nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
	Else
		nLin := 2
		fwrite(outputfile," "+CHR(13)+CHR(10)+CHR(12))
		fwrite(outputfile,cTitulo+CHR(13)+CHR(10))
	   	fwrite(outputfile,STR0102 +" "+cEmpr+"   "+ STR0103 +" "+cFil+space(10)+ STR0104 +str(nPagina++,4)+CHR(13)+CHR(10))
		fwrite(outputfile,STR0105 +" \AP5\RELATO\_R250_"+cFil+".##r"+CHR(13)+CHR(10))
	EndIf
EndIf
If FunName() == "OFIOR250"
	nLin++
	@ nLin++ , 00 psay STR0039 + STR0041
	@ nLin++ , 00 psay STR0040 + Transform(aTotDev[1,1],"@E 99,999,999.99") + Transform(aTotDev[1,2],"@E 99999,999.99") + Transform(aTotDev[1,3],"@E 99999,999.99") + Transform(aTotDev[1,4],"@E 9999,999.99") + Transform(aTotDev[1,5],"@E 9999,999.99") + Transform(aTotDev[1,6],"@E 9999,999.99") + Transform(aTotDev[1,7],"@E 99,999,999.99") + Transform(aTotDev[1,8],"@E 99,999,999.99") + Transform(((aTotDev[1,8]/aTotDev[1,1])*100),"@E 9999.9")
Else
	nLin+= 3
	fwrite(outputfile," "+CHR(13)+CHR(10))
	fwrite(outputfile,STR0039 + STR0041 +CHR(13)+CHR(10))
	fwrite(outputfile,STR0040 + Transform(aTotDev[1,1],"@E 99,999,999.99") + Transform(aTotDev[1,2],"@E 99999,999.99") + Transform(aTotDev[1,3],"@E 99999,999.99") + Transform(aTotDev[1,4],"@E 9999,999.99") + Transform(aTotDev[1,5],"@E 9999,999.99") + Transform(aTotDev[1,6],"@E 9999,999.99") + Transform(aTotDev[1,7],"@E 99,999,999.99") + Transform(aTotDev[1,8],"@E 99,999,999.99") + Transform(((aTotDev[1,8]/aTotDev[1,1])*100),"@E 9999.9")+CHR(13)+CHR(10))
EndIf
If MV_PAR04 >= 3
	If FunName() == "OFIOR250"
		nLin++
	Else
		nLin++
		fwrite(outputfile," "+CHR(13)+CHR(10))
	EndIf
	For ni:=1 to Len(aNumDev)
		If nLin >= 58
			If FunName() == "OFIOR250"
				nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
				nLin++
				@ nLin++ , 27 psay STR0041
				nLin++
			Else
				nLin := 4
				fwrite(outputfile," "+CHR(13)+CHR(10)+CHR(12))
				fwrite(outputfile,cTitulo+CHR(13)+CHR(10))
				fwrite(outputfile,STR0102 +" "+cEmpr+"   "+ STR0103 +" "+cFil+space(10)+ STR0104 +str(nPagina++,4)+CHR(13)+CHR(10))
				fwrite(outputfile,STR0105 +" \AP5\RELATO\_R250_"+cFil+".##r"+CHR(13)+CHR(10))
				fwrite(outputfile," "+CHR(13)+CHR(10))
				fwrite(outputfile,space(27)+STR0041+CHR(13)+CHR(10))
				fwrite(outputfile," "+CHR(13)+CHR(10))
			EndIf
		EndIf
		cSeekDev := ""
		Do Case
			Case left(aNumDev[ni,10],2) == "00"
				cSeekDev := STR0066
			Case left(aNumDev[ni,10],2) == "01"
				cSeekDev := STR0067
			Case left(aNumDev[ni,10],2) == "02"
				cSeekDev := STR0068
			Case left(aNumDev[ni,10],2) == "03"
				cSeekDev := STR0069
			Case left(aNumDev[ni,10],2) == "04"
				cSeekDev := STR0070
			Case left(aNumDev[ni,10],2) == "10"
				cSeekDev := STR0071
			Case left(aNumDev[ni,10],2) == "21"
				cSeekDev := STR0072
			Case left(aNumDev[ni,10],2) == "22"
				cSeekDev := STR0073
			Case left(aNumDev[ni,10],2) == "23"
				cSeekDev := STR0074
			Case left(aNumDev[ni,10],2) == "24"
				cSeekDev := STR0075
		EndCase
		If FunName() == "OFIOR250"
			@ nLin++ , 00 psay left(cSeekDev+If(!Empty(aNumDev[ni,12]),aNumDev[ni,12],"---")+" "+Alltrim(aNumDev[ni,1])+" "+aNumDev[ni,2]+space(25),25)+Transform(aNumDev[ni,3],"@E 999,999,999.99")+Transform(aNumDev[ni,4],"@E 99999,999.99")+Transform(aNumDev[ni,5],"@E 99999,999.99")+Transform(aNumDev[ni,6],"@E 9999,999.99")+Transform(aNumDev[ni,7],"@E 9999,999.99")+Transform(aNumDev[ni,8],"@E 9999,999.99")+Transform(aNumDev[ni,9],"@E 99,999,999.99")+Transform(aNumDev[ni,11],"@E 99,999,999.99")+Transform(((aNumDev[ni,11]/aNumDev[ni,3])*100),"@E 9999.9")
		Else
			nLin++
			fwrite(outputfile,left(cSeekDev+If(!Empty(aNumDev[ni,12]),aNumDev[ni,12],"---")+" "+Alltrim(aNumDev[ni,1])+" "+aNumDev[ni,2]+space(25),25)+Transform(aNumDev[ni,3],"@E 999,999,999.99")+Transform(aNumDev[ni,4],"@E 99999,999.99")+Transform(aNumDev[ni,5],"@E 99999,999.99")+Transform(aNumDev[ni,6],"@E 9999,999.99")+Transform(aNumDev[ni,7],"@E 9999,999.99")+Transform(aNumDev[ni,8],"@E 9999,999.99")+Transform(aNumDev[ni,9],"@E 99,999,999.99")+Transform(aNumDev[ni,11],"@E 99,999,999.99")+Transform(((aNumDev[ni,11]/aNumDev[ni,3])*100),"@E 9999.9")+CHR(13)+CHR(10))
		EndIf
	Next
EndIf
If FunName() == "OFIOR250"
	nLin++
	@ nLin++ , 00 psay Repl("*",220)
Else
	nLin+= 2
	fwrite(outputfile," "+CHR(13)+CHR(10))
	fwrite(outputfile,Repl("*",220)+CHR(13)+CHR(10))
EndIf
Return

Function FS_OR25AE() // Entradas
Local ni
///////////////////////////////////
//V A L O R E S   E N T R A D A S//
///////////////////////////////////
If nLin >= 55
	If FunName() == "OFIOR250"
		nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
	Else
		nLin := 2
		fwrite(outputfile," "+CHR(13)+CHR(10)+CHR(12))
		fwrite(outputfile,cTitulo+CHR(13)+CHR(10))
		fwrite(outputfile,STR0102 +" "+cEmpr+"   "+STR0103+" "+cFil+space(10)+STR0104+str(nPagina++,4)+CHR(13)+CHR(10))
		fwrite(outputfile,STR0105 +" \AP5\RELATO\_R250_"+cFil+".##r"+CHR(13)+CHR(10)) //Empresa: # Filial: # Folha: # Arquivo:
   	EndIf
EndIf
If FunName() == "OFIOR250"
	nLin++
	nLin++
	@ nLin++ , 00 psay STR0032
	nLin++
	@ nLin++ , 40 psay STR0033
	@ nLin++ , 00 psay STR0034 + Transform(aTotEnt[1,1],"@E 99,999,999.99")
Else
	nLin+= 6
	fwrite(outputfile," "+CHR(13)+CHR(10))
	fwrite(outputfile," "+CHR(13)+CHR(10))
	fwrite(outputfile,STR0032+CHR(13)+CHR(10))
	fwrite(outputfile," "+CHR(13)+CHR(10))
	fwrite(outputfile,space(40)+STR0033+CHR(13)+CHR(10))
	fwrite(outputfile,STR0034 + Transform(aTotEnt[1,1],"@E 99,999,999.99")+CHR(13)+CHR(10))
EndIf
aSort(aNumEnt,1,,{|x,y| x[1]+x[2] < y[1]+y[2]})
aSort(aEntrad,1,,{|x,y| x[1] < y[1]})
If MV_PAR04 >= 3
	For ni:=1 to Len(aEntrad)
		If nLin >= 60
			If FunName() == "OFIOR250"
				nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
				nLin++
				@ nLin++ , 40 psay STR0033
				nLin++
			Else
				nLin := 4
				fwrite(outputfile," "+CHR(13)+CHR(10)+CHR(12))
				fwrite(outputfile,cTitulo+CHR(13)+CHR(10))
				fwrite(outputfile,STR0102 +" "+cEmpr+"   "+STR0103+" "+cFil+space(10)+STR0104+str(nPagina++,4)+CHR(13)+CHR(10))
				fwrite(outputfile,STR0105 +" \AP5\RELATO\_R250_"+cFil+".##r"+CHR(13)+CHR(10)) //Empresa: # Filial: # Folha: # Arquivo:
				fwrite(outputfile," "+CHR(13)+CHR(10))
				fwrite(outputfile,space(40)+STR0033+CHR(13)+CHR(10))
				fwrite(outputfile," "+CHR(13)+CHR(10))
			EndIf
		EndIf
		If !Empty(alltrim(aEntrad[ni,1]))
			If FunName() == "OFIOR250"
				@ nLin++ , 04 psay aEntrad[ni,1] + "  " + aEntrad[ni,2] + "  " + Transform(aEntrad[ni,3],"@E 99,999,999.99")
			Else
				nLin++
				fwrite(outputfile,space(4)+aEntrad[ni,1] + "  " + aEntrad[ni,2] + "  " + Transform(aEntrad[ni,3],"@E 99,999,999.99")+CHR(13)+CHR(10))
			EndIf
		EndIf
	Next
EndIf
cMudou := "9"
For ni:=1 to Len(aNumEnt)
	If nLin >= 60
		If FunName() == "OFIOR250"
			nLin := 1
			nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
			nLin++
			@ nLin++ , 40 psay STR0033
			nLin++
		Else
			nLin := 4
			fwrite(outputfile," "+CHR(13)+CHR(10)+CHR(12))
			fwrite(outputfile,cTitulo+CHR(13)+CHR(10))
			fwrite(outputfile,STR0102 +" "+cEmpr+"   "+STR0103+" "+cFil+space(10)+STR0104+str(nPagina++,4)+CHR(13)+CHR(10))
			fwrite(outputfile,STR0105 +" \AP5\RELATO\_R250_"+cFil+".##r"+CHR(13)+CHR(10)) //Empresa: # Filial: # Folha: # Arquivo:
			fwrite(outputfile," "+CHR(13)+CHR(10))
			fwrite(outputfile,space(40)+STR0033+CHR(13)+CHR(10))
			fwrite(outputfile," "+CHR(13)+CHR(10))
		EndIf
	EndIf
	If cMudou # aNumEnt[ni,1]
		cMudou := aNumEnt[ni,1]
		nPos := aScan(aGrpEnt,{|x| x[1] == cMudou })
		If MV_PAR04 >= 3
			If FunName() == "OFIOR250"
				nLin++
			Else
				nLin++
				fwrite(outputfile," "+CHR(13)+CHR(10))
			EndIf
		EndIf
		If	nPos > 0
			If FunName() == "OFIOR250"
				@ nLin++ , 02 psay aGrpEnt[nPos,2] + " " + Transform(aGrpEnt[nPos,3],"@E 99,999,999.99")
			Else
				nLin++
				fwrite(outputfile,space(2)+aGrpEnt[nPos,2] + " " + Transform(aGrpEnt[nPos,3],"@E 99,999,999.99")+CHR(13)+CHR(10))
			EndIf
		EndIf
	EndIf
	If (MV_PAR04 >= 3 .and. !Empty(alltrim(aNumEnt[ni,2])))
		If FunName() == "OFIOR250"
			@ nLin++ , 04 psay aNumEnt[ni,2] + "  " + left(aNumEnt[ni,3],30) + "  " + Transform(aNumEnt[ni,4],"@E 99,999,999.99")
		Else
			nLin++
			fwrite(outputfile,space(4)+aNumEnt[ni,2] + "  " + left(aNumEnt[ni,3],30) + "  " + Transform(aNumEnt[ni,4],"@E 99,999,999.99")+CHR(13)+CHR(10))
		EndIf
	EndIf
Next
If FunName() == "OFIOR250"
	nLin++
	@ nLin++ , 00 psay Repl("*",220)
Else
	nLin+= 2
	fwrite(outputfile," "+CHR(13)+CHR(10))
	fwrite(outputfile,Repl("*",220)+CHR(13)+CHR(10))
EndIf
Return

Function FS_OR25AC() // Condicao de Pagamento
Local nVlrExt := nVlrInt := 0, ni
///////////////////////////////////
// C O N D.  P A G A M E N T O S //
///////////////////////////////////
If FunName() == "OFIOR250"
	nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
Else
	nLin := 2
	fwrite(outputfile," "+CHR(13)+CHR(10)+CHR(12))
	fwrite(outputfile,cTitulo+CHR(13)+CHR(10))
	fwrite(outputfile,STR0102 +" "+cEmpr+"   "+STR0103+" "+cFil+space(10)+STR0104+str(nPagina++,4)+CHR(13)+CHR(10))
	fwrite(outputfile,STR0105 +" \AP5\RELATO\_R250_"+cFil+".##r"+CHR(13)+CHR(10)) //Empresa: # Filial: # Folha: # Arquivo:
EndIf
If MV_PAR06 == 2 .or. MV_PAR06 == 3
	cString := Transform(aTotCon[1,1],"@E 99,999,999.99");//Venda Total
	+ Transform(aTotCon[1,2],"@E 99999,999.99");	// Impostos
	+ Transform(aTotCon[1,3],"@E 99999,999.99");	// ICMS
	+ Transform(aTotCon[1,4],"@E 9999,999.99");	// ISS
	+ Transform(aTotCon[1,5],"@E 9999,999.99");	// PIS
	+ Transform(aTotCon[1,6],"@E 9999,999.99");	// Cofins
	+ Transform(aTotCon[1,7],"@E 99,999,999.99");	// Custos
	+ Transform(aTotCon[1,9],"@E 99,999,999.99")+ Transform(((aTotCon[1,9]/aTotCon[1,1])*100),"@E 9999.9");//Lucro Bruto
	+ Transform(aTotCon[1,8],"@E 99,999,999.99");	// Juro Estoque
	+ Transform(aTotCon[1,10],"@E 99,999,999.99");// Desp Var
	+ Transform(aTotCon[1,11],"@E 99,999,999.99");// Comissoes
	+ Transform(aTotCon[1,12],"@E 99,999,999.99");// Lucro Liq
	+ Transform(aTotCon[1,13]+aTotCon[1,14],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
	+ Transform(aTotCon[1,15],"@E 99,999,999.99") ;// Resultado Final
	+ Transform(aTotCon[1,16]/aTotCon[1,17],"@E 999,999,999.9") ; // Prz Medio
	+ Transform((aTotCon[1,18]/aTotCon[1,1])*100,"@E 9999.9")	// % Desc
	If FunName() == "OFIOR250"
		nLin+=2
		@ nLin++ , 62 psay STR0025
		nLin+=2
		@ nLin++ , 00 psay STR0026 + cCabTot
		@ nLin++ , 00 psay STR0027 + FS_ImpR250(cString)
	Else
		nLin+= 7
		fwrite(outputfile," "+CHR(13)+CHR(10))
		fwrite(outputfile," "+CHR(13)+CHR(10))
		fwrite(outputfile,space(62)+STR0025+CHR(13)+CHR(10))
		fwrite(outputfile," "+CHR(13)+CHR(10))
		fwrite(outputfile," "+CHR(13)+CHR(10))
		fwrite(outputfile,STR0026 + cCabTot+CHR(13)+CHR(10))
		cString += CHR(13)+CHR(10)
		fwrite(outputfile,STR0027 + FS_ImpR250(cString))
	EndIf
	aSort(aTotPag,1,,{|x,y| x[1]+x[2] < y[1]+y[2]})
	aSort(aConPagNF,1,,{|x,y| x[1]+x[2]+x[7]+x[3] < y[1]+y[2]+y[7]+y[3]})
	cMudou := "9"
	cMudou2:= "9"
	For ni:=1 to Len(aConPagNF)
		If Left(aConPagNF[ni,2],1) == "E" // Externa
			nVlrExt += aConPagNF[ni,6]
		Else // Interna
			nVlrInt += aConPagNF[ni,6]
		EndIf
		If nLin >= 60
			If FunName() == "OFIOR250"
				nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
				nLin++
				@ nLin++ , 27 psay cCabTot
				nLin++
			Else
				nLin := 4
				fwrite(outputfile," "+CHR(13)+CHR(10)+CHR(12))
				fwrite(outputfile,cTitulo+CHR(13)+CHR(10))
				fwrite(outputfile,STR0102 +" "+cEmpr+"   "+STR0103+" "+cFil+space(10)+STR0104+str(nPagina++,4)+CHR(13)+CHR(10))
				fwrite(outputfile,STR0105 +" \AP5\RELATO\_R250_"+cFil+".##r"+CHR(13)+CHR(10)) //Empresa: # Filial: # Folha: # Arquivo:
				fwrite(outputfile," "+CHR(13)+CHR(10))
				fwrite(outputfile,space(27)+cCabTot+CHR(13)+CHR(10))
				fwrite(outputfile," "+CHR(13)+CHR(10))
			EndIf
		EndIf
		If cMudou # aConPagNF[ni,1]
			cMudou := aConPagNF[ni,1]
			cMudou2:= "9"
			cMudou3:= "1"
			nPos := aScan(aGrpPag,{|x| x[1] == cMudou })
			If MV_PAR04 >= 3
				nLin++
				If FunName() # "OFIOR250"
					fwrite(outputfile," "+CHR(13)+CHR(10))
				EndIf
			EndIf
			If Empty(aGrpPag[nPos,1])
				cGrpPag := STR0028
			Else
				cGrpPag := aGrpPag[nPos,1] + " - "
				If(len(aGrpPag[nPos,2])>=20)
					cGrpPag := cGrpPag + left(aGrpPag[nPos,2],20)
				Else
					cGrpPag := cGrpPag + aGrpPag[nPos,2] + Repl(" ",(20-len(aGrpPag[nPos,2])))
				EndIf
			EndIf
			cString := Transform(aGrpPag[nPos,3],"@E 99,999,999.99");//Venda Total
			+ Transform(aGrpPag[nPos,4],"@E 99999,999.99");	// Impostos
			+ Transform(aGrpPag[nPos,5],"@E 99999,999.99");	// ICMS
			+ Transform(aGrpPag[nPos,6],"@E 9999,999.99");	// ISS
			+ Transform(aGrpPag[nPos,7],"@E 9999,999.99");	// PIS
			+ Transform(aGrpPag[nPos,8],"@E 9999,999.99");	// Cofins
			+ Transform(aGrpPag[nPos,9],"@E 99,999,999.99");	// Custos
			+ Transform(aGrpPag[nPos,11],"@E 99,999,999.99") + Transform(((aGrpPag[nPos,11]/aGrpPag[nPos,3])*100),"@E 9999.9");//Lucro Bruto
			+ Transform(aGrpPag[nPos,10],"@E 99,999,999.99");// Juro Estoque
			+ Transform(aGrpPag[nPos,12],"@E 99,999,999.99");// Desp Var
			+ Transform(aGrpPag[nPos,13],"@E 99,999,999.99");// Comissoes
			+ Transform(aGrpPag[nPos,14],"@E 99,999,999.99");// Lucro Liq
			+ Transform(aGrpPag[nPos,15]+aGrpPag[nPos,16],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
			+ Transform(aGrpPag[nPos,17],"@E 99,999,999.99") ;// Resultado Final
			+ Transform(aGrpPag[nPos,18]/aGrpPag[nPos,19],"@E 999,999,999.9") ; // Prz Medio
			+ Transform((aGrpPag[nPos,20]/aGrpPag[nPos,3])*100,"@E 9999.9")	// % Desc
			If FunName() == "OFIOR250"
				nLin++
				@ nLin++ , 00 psay cGrpPag + " " + FS_ImpR250(cString)
			Else
				nLin+= 2
				fwrite(outputfile," "+CHR(13)+CHR(10))
				cString += CHR(13)+CHR(10)
				fwrite(outputfile,cGrpPag + " " + FS_ImpR250(cString))
			EndIf
		EndIf
		If MV_PAR04 >= 2
			If cMudou2 # aConPagNF[ni,2]
				cMudou2:= aConPagNF[ni,2]
				cMudou3:= "1"
				nPos := aScan(aTotPag,{|x| x[1] + x[2] == cMudou + cMudou2 })
				If MV_PAR04 >= 3
					nLin++
					If FunName() # "OFIOR250"
						fwrite(outputfile," "+CHR(13)+CHR(10))
					EndIf
				EndIf
				cString := Transform(aTotPag[nPos,4],"@E 99,999,999.99");	// Venda Total
				+ Transform(aTotPag[nPos,5],"@E 99999,999.99") ;	// Impostos
				+ Transform(aTotPag[nPos,6],"@E 99999,999.99") ;	// ICMS
				+ Transform(aTotPag[nPos,7],"@E 9999,999.99") ;	// ISS
				+ Transform(aTotPag[nPos,8],"@E 9999,999.99") ;	// PIS
				+ Transform(aTotPag[nPos,9],"@E 9999,999.99") ;	// Cofins
				+ Transform(aTotPag[nPos,10],"@E 99,999,999.99");// Custos
				+ Transform(aTotPag[nPos,12],"@E 99,999,999.99") + Transform(((aTotPag[nPos,12]/aTotPag[nPos,4])*100),"@E 9999.9");//Lucro Bruto
				+ Transform(aTotPag[nPos,11],"@E 99,999,999.99");// Juro Estoque
				+ Transform(aTotPag[nPos,13],"@E 99,999,999.99");// Desp Var
				+ Transform(aTotPag[nPos,14],"@E 99,999,999.99");// Comissoes
				+ Transform(aTotPag[nPos,15],"@E 99,999,999.99");// Lucro Liq
				+ Transform(aTotPag[nPos,16]+aTotPag[nPos,17],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
				+ Transform(aTotPag[nPos,18],"@E 99,999,999.99") ;// Resultado Final
				+ Transform(aTotPag[nPos,19]/aTotPag[nPos,20],"@E 999,999,999.9") ; // Prz Medio
				+ Transform((aTotPag[nPos,21]/aTotPag[nPos,4])*100,"@E 9999.9")	// % Desc
				If FunName() == "OFIOR250"
					@ nLin++ , 00 psay "  " + substr(aTotPag[nPos,2],2) + " " + aTotPag[nPos,3] + " "  + FS_ImpR250(cString)
				Else
					nLin++
					cString += CHR(13)+CHR(10)
					fwrite(outputfile,"  " + substr(aTotPag[nPos,2],2) + " " + aTotPag[nPos,3] + " " + FS_ImpR250(cString))
				EndIf
				If MV_PAR04 >= 3
					nLin++
					If FunName() # "OFIOR250"
						fwrite(outputfile," "+CHR(13)+CHR(10))
					EndIf
				EndIf
				cPulou := "JA"
			EndIf
			If nLin >= 59
				If FunName() == "OFIOR250"
					nLin := 1
					nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
					nLin++
					@ nLin++ , 27 psay cCabTot
					nLin++
				Else
					nLin := 4
					fwrite(outputfile," "+CHR(13)+CHR(10)+CHR(12))
					fwrite(outputfile,cTitulo+CHR(13)+CHR(10))
					fwrite(outputfile,STR0102 +" "+cEmpr+"   "+STR0103+" "+cFil+space(10)+STR0104+str(nPagina++,4)+CHR(13)+CHR(10))
					fwrite(outputfile,STR0105 +" \AP5\RELATO\_R250_"+cFil+".##r"+CHR(13)+CHR(10)) //Empresa: # Filial: # Folha: # Arquivo:
					fwrite(outputfile," "+CHR(13)+CHR(10))
					fwrite(outputfile,space(27)+cCabTot+CHR(13)+CHR(10))
					fwrite(outputfile," "+CHR(13)+CHR(10))
				EndIf
			EndIf
		EndIf
		If MV_PAR04 >= 3
			If cMudou3 # aConPagNF[ni,7]
				cMudou3 := aConPagNF[ni,7]
				nPos := aScan(aPecSrvOfi,{|x| x[1]+x[2]+x[4] == cMudou + cMudou2 + cMudou3 })
				If nPos > 0
					If cPulou # "JA"
						nLin++
						If FunName() # "OFIOR250"
							fwrite(outputfile," "+CHR(13)+CHR(10))
						EndIf
					EndIf
					cPulou := "NAO"
					If FunName() == "OFIOR250"
						@ nLin++ , 00 psay " " + aPecSrvOfi[nPos,4] + "    " + Transform(aPecSrvOfi[nPos,3],"@E 99,999,999.99")
					Else
						nLin++
						fwrite(outputfile," " + aPecSrvOfi[nPos,4] + "    " + Transform(aPecSrvOfi[nPos,3],"@E 99,999,999.99")+CHR(13)+CHR(10))
					EndIf
				Endif
			EndIf
			cPulou := "NAO"
			If FunName() == "OFIOR250"
				@ nLin++ , 00 psay "  " + aConPagNF[ni,3] + "-" + aConPagNF[ni,4] + " " + aConPagNF[ni,5] + " " + Transform(aConPagNF[ni,6],"@E 99,999,999.99")
			Else
				nLin++
				fwrite(outputfile,"  " + aConPagNF[ni,3] + "-" + aConPagNF[ni,4] + " " + aConPagNF[ni,5] + " " + Transform(aConPagNF[ni,6],"@E 99,999,999.99")+CHR(13)+CHR(10))
			EndIf
		EndIf
	Next
	
ElseIf MV_PAR06 == 4
	
	///////////////////////////////////
	// C.C U S T O   V E N D E D O R //
	///////////////////////////////////
	cString := Transform(aTotCon[1,1],"@E 99,999,999.99");//Venda Total
	+ Transform(aTotCon[1,2],"@E 99999,999.99");	// Impostos
	+ Transform(aTotCon[1,3],"@E 99999,999.99");	// ICMS
	+ Transform(aTotCon[1,4],"@E 9999,999.99");	// ISS
	+ Transform(aTotCon[1,5],"@E 9999,999.99");	// Pis
	+ Transform(aTotCon[1,6],"@E 9999,999.99");	// Cofins
	+ Transform(aTotCon[1,7],"@E 99,999,999.99");// Custos
	+ Transform(aTotCon[1,9],"@E 99,999,999.99") + Transform(((aTotCon[1,9]/aTotCon[1,1])*100),"@E 9999.9");	// Lucro Bruto
	+ Transform(aTotCon[1,8],"@E 99,999,999.99");// Juro Estoque
	+ Transform(aTotCon[1,10],"@E 99,999,999.99");// Desp Var
	+ Transform(aTotCon[1,11],"@E 99,999,999.99");// Comissoes
	+ Transform(aTotCon[1,12],"@E 99,999,999.99");// Lucro Liq
	+ Transform(aTotCon[1,13]+aTotCon[1,14],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
	+ Transform(aTotCon[1,15],"@E 99,999,999.99") ;// Resultado Final
	+ Transform(aTotCon[1,16]/aTotCon[1,17],"@E 999,999,999.9") ; // Prz Medio
	+ Transform((aTotCon[1,18]/aTotCon[1,1])*100,"@E 9999.9")	// % Desc
	If FunName() == "OFIOR250"
		nLin+=2
		@ nLin++ , 62 psay STR0059
		nLin+=2
		@ nLin++ , 00 psay STR0060 + cCabTot
		@ nLin++ , 00 psay STR0061 + FS_ImpR250(cString)
	Else
		nLin+= 7
		fwrite(outputfile," "+CHR(13)+CHR(10))
		fwrite(outputfile," "+CHR(13)+CHR(10))
		fwrite(outputfile,space(62)+STR0059+CHR(13)+CHR(10))
		fwrite(outputfile," "+CHR(13)+CHR(10))
		fwrite(outputfile," "+CHR(13)+CHR(10))
		fwrite(outputfile,STR0060 + cCabTot+CHR(13)+CHR(10))
		cString += CHR(13)+CHR(10)
		fwrite(outputfile,STR0061 + FS_ImpR250(cString))
	EndIf
	aSort(aCCVend,1,,{|x,y| x[19]+x[2] < y[19]+y[2]})
	cMudou := "9"
	For ni:=1 to Len(aCCVend)
		If ( ( aCCVend[ni,4] + aCCVend[ni,5] + aCCVend[ni,6] + aCCVend[ni,7] + aCCVend[ni,8] + aCCVend[ni,9] + aCCVend[ni,10] ) > 0 )
			If nLin >= 60
				If FunName() == "OFIOR250"
					nLin := 1
					nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
					nLin++
					@ nLin++ , 27 psay cCabTot
					nLin++
				Else
					nLin := 4
					fwrite(outputfile," "+CHR(13)+CHR(10)+CHR(12))
					fwrite(outputfile,cTitulo+CHR(13)+CHR(10))
					fwrite(outputfile,STR0102 +" "+cEmpr+"   "+STR0103+" "+cFil+space(10)+STR0104+str(nPagina++,4)+CHR(13)+CHR(10))
					fwrite(outputfile,STR0105 +" \AP5\RELATO\_R250_"+cFil+".##r"+CHR(13)+CHR(10)) //Empresa: # Filial: # Folha: # Arquivo:
					fwrite(outputfile," "+CHR(13)+CHR(10))
					fwrite(outputfile,space(27)+cCabTot+CHR(13)+CHR(10))
					fwrite(outputfile," "+CHR(13)+CHR(10))
				EndIf
			EndIf
			If cMudou # aCCVend[ni,19]
				cMudou := aCCVend[ni,19]
				nPos := aScan(aTotCCV,{|x| x[1] == aCCVend[ni,1] })
				cString := Transform(aTotCCV[nPos,2],"@E 99,999,999.99");//Venda Total
				+ Transform(aTotCCV[nPos,3],"@E 99999,999.99");	// Impostos
				+ Transform(aTotCCV[nPos,4],"@E 99999,999.99");	// ICMS
				+ Transform(aTotCCV[nPos,5],"@E 9999,999.99");	// ISS
				+ Transform(aTotCCV[nPos,6],"@E 9999,999.99");	// PIS
				+ Transform(aTotCCV[nPos,7],"@E 9999,999.99");	// Cofins
				+ Transform(aTotCCV[nPos,8],"@E 99,999,999.99");// Custos
				+ Transform(aTotCCV[nPos,10],"@E 99,999,999.99") + Transform(((aTotCCV[nPos,10]/aTotCCV[nPos,2])*100),"@E 9999.9");//Lucro Bruto
				+ Transform(aTotCCV[nPos,9],"@E 99,999,999.99");// Juro Estoque
				+ Transform(aTotCCV[nPos,11],"@E 99,999,999.99");// Desp Var
				+ Transform(aTotCCV[nPos,12],"@E 99,999,999.99");// Comissoes
				+ Transform(aTotCCV[nPos,13],"@E 99,999,999.99");// Lucro Liq
				+ Transform(aTotCCV[nPos,14]+aTotCCV[nPos,15],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
				+ Transform(aTotCCV[nPos,16],"@E 99,999,999.99") ;// Resultado Final
				+ Transform(aTotCCV[nPos,17]/aTotCCV[nPos,18],"@E 999,999,999.9") ; // Prz Medio
				+ Transform((aTotCCV[nPos,19]/aTotCCV[nPos,2])*100,"@E 9999.9")	// % Desc
				If FunName() == "OFIOR250"
					nLin++
					@ nLin++ , 00 psay aCCVend[ni,19] + "  " + FS_ImpR250(cString)
					nLin++
				Else
					nLin+= 3
					fwrite(outputfile," "+CHR(13)+CHR(10))
					cString += CHR(13)+CHR(10)
					fwrite(outputfile,aCCVend[ni,19] + "  " + FS_ImpR250(cString))
					fwrite(outputfile," "+CHR(13)+CHR(10))
				EndIf
			EndIf
			cString := Transform(aCCVend[ni,4],"@E 99,999,999.99");	// Venda Total
			+ Transform(aCCVend[ni,5],"@E 99999,999.99");	// Impostos
			+ Transform(aCCVend[ni,6],"@E 99999,999.99");	// ICMS
			+ Transform(aCCVend[ni,7],"@E 9999,999.99");		// ISS
			+ Transform(aCCVend[ni,8],"@E 9999,999.99");		// PIS
			+ Transform(aCCVend[ni,9],"@E 9999,999.99");		// Cofins
			+ Transform(aCCVend[ni,10],"@E 99,999,999.99");	// Custos
			+ Transform(aCCVend[ni,12],"@E 99,999,999.99") + Transform(((aCCVend[ni,12]/aCCVend[ni,4])*100),"@E 9999.9");//Lucro Bruto
			+ Transform(aCCVend[ni,11],"@E 99,999,999.99");	// Juro Estoque
			+ Transform(aCCVend[ni,13],"@E 99,999,999.99");	// Desp Var
			+ Transform(aCCVend[ni,14],"@E 99,999,999.99");	// Comissoes
			+ Transform(aCCVend[ni,15],"@E 99,999,999.99");	// Lucro Liq
			+ Transform(aCCVend[ni,16]+aCCVend[ni,17],"@E 99,999,999.99") ;// Cst/Dsp Fix + Dsp Dep/Adm
			+ Transform(aCCVend[ni,18],"@E 99,999,999.99") ;// Resultado Final
			+ Transform(aCCVend[ni,20]/aCCVend[ni,21],"@E 999,999,999.9") ; // Prz Medio
			+ Transform((aCCVend[ni,22]/aCCVend[ni,4])*100,"@E 9999.9")	// % Desc
			If FunName() == "OFIOR250"
				@ nLin++ , 00 psay "  " + aCCVend[ni,2] + " " + aCCVend[ni,3] + " "  + FS_ImpR250(cString)
			Else
				nLin++
				cString += CHR(13)+CHR(10)
				fwrite(outputfile,"  " + aCCVend[ni,2] + " " + aCCVend[ni,3] + " " + FS_ImpR250(cString))
			EndIf
			If Left(aCCVend[ni,1],1) == "E" // Externa
				nVlrExt += aCCVend[ni,4]
			Else // Interna
				nVlrInt += aCCVend[ni,4]
			EndIf
		EndIf
	Next
	
EndIf

If FunName() == "OFIOR250"
	nLin++
	@ nLin++ , 00 psay STR0106 +Transform(nVlrExt,"@E 999,999,999.99") //Ext - Total Externas      
	nLin++
	@ nLin++ , 00 psay STR0107 +Transform(nVlrInt,"@E 999,999,999.99") //Int - Total Internas      
	nLin++
	@ nLin++ , 00 psay Repl("*",220)
Else
	nLin+= 6
	fwrite(outputfile," "+CHR(13)+CHR(10))
	fwrite(outputfile,STR0108 +Transform(nVlrExt,"@E 999,999,999.99")+CHR(13)+CHR(10)) // Ext - Total Externas     
	fwrite(outputfile," "+CHR(13)+CHR(10))
	fwrite(outputfile,STR0109 +Transform(nVlrInt,"@E 999,999,999.99")+CHR(13)+CHR(10)) // Int - Total Internas     
	fwrite(outputfile," "+CHR(13)+CHR(10))
	fwrite(outputfile,Repl("*",220)+CHR(13)+CHR(10))
EndIf

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funá∆o    ≥OA110OK     ≥ Autor ≥  Ednilson           ≥ Data ≥ 24/10/01 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriá∆o ≥ Funcao para o TudoOk                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function FS_VALR250(cPar01,cPar02)
Local lRet := .t.
If cPar01 > cPar02
	Help(" ",1,"DATA2MOATU")
	lRet := .f.
EndIf
Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funá∆o    ≥Fs_ImpR250  ≥ Autor ≥  Manoel             ≥ Data ≥ 07/04/05 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriá∆o ≥ Faz a Disposicao das colunas do relatorio                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function Fs_ImpR250(cPar)
Local iDisp
cParStr := cPar
cParDisp := Alltrim(Upper(Mv_Par10))//"AHIGBCDEFJKLNOP"
// Vetor que determina a posicao das colunas na STRING Total
aVetDisp  := {"A001,014","B015,012","C027,012","D039,011","E050,011","F061,011","G072,013","H085,013","I098,006","J104,013","K117,013","L130,013","M143,013","N156,013","O169,013","P182,013","Q195,007"}
cRet := ""
For iDisp := 1 To Len(cParDisp)
	nPos   := aScan(aVetDisp,{|x| Subs(x,1,1) == Subs(cParDisp,iDisp,1)})
	nPosic := Subs(aVetDisp[nPos],2,7)
	cRet += &("Subs(cParStr,"+nPosic+")")
Next
If FunName() # "OFIOR250"
	cRet := cRet +CHR(13)+CHR(10)
endif
Return(cRet)