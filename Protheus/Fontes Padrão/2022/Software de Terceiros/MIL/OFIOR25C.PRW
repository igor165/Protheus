#Include "OFIOR250.CH"
#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_OR25C ³ Autor ³ Andre Luis Almeida    ³ Data ³ 10/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carregando VETOR de Vendas de Pecas                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_OR25C()
///////////////////////////////////
//         P  E  C  A  S         //
///////////////////////////////////
// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
aAdd(aGrpPBO,{ "B" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0, 0, 0, 0 }) 
aAdd(aGrpPBO,{ "O" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0, 0, 0, 0 }) 
aAdd(aTotOOpe,{ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0, 0, 0, 0 })   // Outras Operacoes - Total
aAdd(aOOpeSrv,{ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0, 0, 0, 0 })   // Outras Operacoes - Servicos
aAdd(aOOpeOut,{ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0, 0, 0, 0 })   // Outras Operacoes - Outros
aAdd(aTotPec,{ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0, 0, 0, 0 }) 
// Balcao //
cAliasVEC := GetNextAlias()
If FunName() == "OFIOR250"
	IncProc(STR0112)//Selecionando Pecas Balcao...
	IncProc(STR0112)//Selecionando Pecas Balcao...
	IncProc(STR0112)//Selecionando Pecas Balcao...
EndIf
BeginSql Alias cAliasVEC
	SELECT VEC.* , VS1.VS1_DEPTO , VS1.VS1_NOROUT , SF2.F2_VALBRUT , SF2.F2_BASEISS , SF2.F2_PREFIXO , SF2.F2_DUPL , 
			SF2.F2_EMISSAO , SF2.F2_VALICM , SF2.F2_VALISS , SF2.F2_VEND1 , SF2.F2_COND , SF2.F2_CLIENTE , SF2.F2_LOJA , 
			SF2.F2_DOC , SF2.F2_SERIE , SD2.D2_TOTAL , SD2.D2_VALIMP5 , SD2.D2_VALIMP6 , SD2.D2_QUANT , SD2.D2_VALICM , 
			SD2.D2_CUSTO1 , SD2.D2_CLIENTE , SD2.D2_LOJA , SD2.D2_VALISS , SF4.F4_DUPLIC , SF4.F4_PISCRED , 
			SF4.F4_PISCOF , SF4.F4_CREDICM , SF4.F4_ESTOQUE , SF4.F4_ATUATF
	FROM %Table:VEC% VEC , %Table:VS1% VS1 , %Table:SF2% SF2 , %Table:SD2% SD2 , %Table:SF4% SF4
	WHERE VEC.VEC_FILIAL = %xFilial:VEC% 
	AND VS1.VS1_FILIAL = %xFilial:VS1% 
	AND SF2.F2_FILIAL = %xFilial:SF2% 
	AND SD2.D2_FILIAL = %xFilial:SD2% 
	AND SF4.F4_FILIAL = %xFilial:SF4%
	AND VEC.%NotDel%
	AND VS1.%NotDel%
	AND SF2.%NotDel%
	AND SD2.%NotDel%
	AND SF4.%NotDel%
	AND VEC.VEC_DATVEN >= %Exp:MV_PAR01%
	AND VEC.VEC_DATVEN <= %Exp:MV_PAR02%
	AND VEC.VEC_BALOFI = 'B'
	AND VEC.VEC_NUMNFI = VS1.VS1_NUMNFI
	AND VEC.VEC_SERNFI = VS1.VS1_SERNFI
	AND VEC.VEC_NUMNFI = SF2.F2_DOC
	AND VEC.VEC_SERNFI = SF2.F2_SERIE
	AND VS1.VS1_CLIFAT = SF2.F2_CLIENTE
	AND VS1.VS1_LOJA = SF2.F2_LOJA
   AND SF2.F2_TIPO = 'N'
	AND VEC.VEC_NUMNFI = SD2.D2_DOC
	AND VEC.VEC_SERNFI = SD2.D2_SERIE
	AND VS1.VS1_CLIFAT = SD2.D2_CLIENTE
	AND VS1.VS1_LOJA = SD2.D2_LOJA
	AND VEC.VEC_PECINT = SD2.D2_COD
	AND SD2.D2_VALISS = 0
	AND SD2.D2_TES = SF4.F4_CODIGO
	AND SF4.F4_DUPLIC <> 'N'
	ORDER BY VEC.VEC_NUMNFI , VEC.VEC_SERNFI , VEC.VEC_GRUITE , VEC.VEC_CODITE
EndSql
If FunName() == "OFIOR250"
	IncProc(STR0114)//Totalizando Pecas Balcao...
	IncProc(STR0114)//Totalizando Pecas Balcao...
	IncProc(STR0114)//Totalizando Pecas Balcao...
EndIf
FS_OR25CSQL() // Balcao 
// Oficina //
If FunName() == "OFIOR250"
	IncProc(STR0113)//Selecionando Pecas Oficina...
	IncProc(STR0113)//Selecionando Pecas Oficina...
	IncProc(STR0113)//Selecionando Pecas Oficina...
EndIf
cAliasVEC := GetNextAlias()
BeginSql Alias cAliasVEC
	SELECT VEC.* , VOO.VOO_DEPTO , SF2.F2_VALBRUT , SF2.F2_BASEISS , SF2.F2_PREFIXO , SF2.F2_DUPL , 
			SF2.F2_EMISSAO , SF2.F2_VALICM , SF2.F2_VALISS , SF2.F2_VEND1 , SF2.F2_COND , SF2.F2_CLIENTE , SF2.F2_LOJA , 
			SF2.F2_DOC , SF2.F2_SERIE , SD2.D2_TOTAL , SD2.D2_VALIMP5 , SD2.D2_VALIMP6 , SD2.D2_QUANT , SD2.D2_VALICM , 
			SD2.D2_CUSTO1 , SD2.D2_CLIENTE , SD2.D2_LOJA , SD2.D2_VALISS , SF4.F4_DUPLIC , SF4.F4_PISCRED , 
			SF4.F4_PISCOF , SF4.F4_CREDICM , SF4.F4_ESTOQUE , SF4.F4_ATUATF 
	FROM %Table:VEC% VEC , %Table:VOO% VOO , %Table:SF2% SF2 , %Table:SD2% SD2 , %Table:SF4% SF4
	WHERE VEC.VEC_FILIAL = %xFilial:VEC% 
	AND VOO.VOO_FILIAL = %xFilial:VOO% 
	AND SF2.F2_FILIAL = %xFilial:SF2% 
	AND SD2.D2_FILIAL = %xFilial:SD2% 
	AND SF4.F4_FILIAL = %xFilial:SF4%
	AND VEC.%NotDel%
	AND VOO.%NotDel%
	AND SF2.%NotDel%
	AND SD2.%NotDel%
	AND SF4.%NotDel%
	AND VEC.VEC_DATVEN >= %Exp:MV_PAR01%
	AND VEC.VEC_DATVEN <= %Exp:MV_PAR02%
	AND VEC.VEC_BALOFI <> 'B'
	AND VEC.VEC_NUMNFI = VOO.VOO_NUMNFI
	AND VEC.VEC_SERNFI = VOO.VOO_SERNFI
	AND VEC.VEC_NUMNFI = SF2.F2_DOC
	AND VEC.VEC_SERNFI = SF2.F2_SERIE
	AND VOO.VOO_FATPAR = SF2.F2_CLIENTE
	AND VOO.VOO_LOJA = SF2.F2_LOJA
   AND SF2.F2_TIPO = 'N'
	AND VEC.VEC_NUMNFI = SD2.D2_DOC
	AND VEC.VEC_SERNFI = SD2.D2_SERIE
	AND VOO.VOO_FATPAR = SD2.D2_CLIENTE
	AND VOO.VOO_LOJA = SD2.D2_LOJA
	AND VEC.VEC_PECINT = SD2.D2_COD
	AND SD2.D2_TES = SF4.F4_CODIGO
	ORDER BY VEC.VEC_NUMNFI , VEC.VEC_SERNFI , VEC.VEC_GRUITE , VEC.VEC_CODITE
EndSql
If FunName() == "OFIOR250"
	IncProc(STR0115)//Totalizando Pecas Oficina...
	IncProc(STR0115)//Totalizando Pecas Oficina...
	IncProc(STR0115)//Totalizando Pecas Oficina...
EndIf
FS_OR25CSQL() // Oficina
Return

Static Function FS_OR25CSQL()
Local ii
Local	cDpto    := "   "
Local nContpis := nContcof := nContjur := nContbru := nContvar := nContcom := nContliq := nContfix := nContdep := nContfin := nCofins := 0
Local lDuplic  := .f.
// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
Local nVPrzMd1 := nVPrzMd2 := 0
Local na := nk := 1
// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
Local nPdescon := 0

Local aPulaVEC := {}
Local nRecVEC, cConfere
Local nAVECI := 1, nPulaVEC := 0

While !((cAliasVEC)->(Eof()))
	cConfere := ( (cAliasVEC)->(VEC_NUMNFI) + (cAliasVEC)->(VEC_SERNFI) + (cAliasVEC)->(VEC_GRUITE) + (cAliasVEC)->(VEC_CODITE) ) 
	nRecVEC := (cAliasVEC)->(RecNO())
	(cAliasVEC)->(DBSkip())
	if cConfere == ( (cAliasVEC)->(VEC_NUMNFI) + (cAliasVEC)->(VEC_SERNFI) + (cAliasVEC)->(VEC_GRUITE) + (cAliasVEC)->(VEC_CODITE) ) 
		aAdd(aPulaVEC,nRecVEC)
	endif
enddo
nPulaVEC := Len(aPulaVEC)
                              

(cAliasVEC)->(DBGoTop())

While !((cAliasVEC)->(Eof()))
	If (cAliasVEC)->(VEC_BALOFI) == "B"   
   	cDpto := (cAliasVEC)->(VS1_DEPTO)
		nPos := 1
   Else
   	cDpto := (cAliasVEC)->(VOO_DEPTO)
		nPos := 2
   EndIf
	DbSelectArea( "VOI" )
	DbSetOrder(1)
	DbSeek( xFilial("VOI") + (cAliasVEC)->(VEC_TIPTEM) , .f. )
	lDuplic := .t.
	If (cAliasVEC)->(F4_DUPLIC) == "N"
		lDuplic := .f.
		If VOI->VOI_SITTPO # "3"
			(cAliasVEC)->(	DbSkip())
			Loop
		EndIf
	EndIf
	nCofins := nCof
	// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
	na := ( ((cAliasVEC)->(F2_VALBRUT)-(cAliasVEC)->(F2_BASEISS)) / (cAliasVEC)->(F2_VALBRUT) )
  	nk := ( (cAliasVEC)->(D2_TOTAL) / ( (cAliasVEC)->(F2_VALBRUT) - (cAliasVEC)->(F2_BASEISS) ) )
	nVprzmd1 := nVprzmd2 := 0

	cPrefSE1 := (cAliasVEC)->(F2_PREFIXO)
	cDuplSE1 := (cAliasVEC)->(F2_DUPL)
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
		nVprzmd1 += ( ( nk * ( (cAliasSE1)->(E1_VALOR) * na ) ) * ( stod((cAliasSE1)->(E1_VENCTO)) - stod((cAliasVEC)->(F2_EMISSAO)) ) ) 
		nVprzmd2 += ( nk * ( (cAliasSE1)->(E1_VALOR) * na )  )
		If Alltrim((cAliasSE1)->(E1_TIPO)) == "CD" // CDCI - sem prazo medio
			nVprzmd1 := 0
		EndIf
		(cAliasSE1)->(Dbskip())
	EndDo         
	(cAliasSE1)->(DBCloseArea())
	
   If MV_PAR08 # 1
		nContjur += If( MV_PAR03 == 1 , (cAliasVEC)->(VEC_JUREST) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_JMFEST) , xmoeda((cAliasVEC)->(VEC_JUREST),1,MV_PAR03,DDataBase)))
		nContbru += If( MV_PAR03 == 1 , (cAliasVEC)->(VEC_LUCBRU) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_LMFBRU) , xmoeda((cAliasVEC)->(VEC_LUCBRU),1,MV_PAR03,DDataBase)))
		nContvar += If( MV_PAR03 == 1 , (cAliasVEC)->(VEC_DESVAR) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_DMFVAR) , xmoeda((cAliasVEC)->(VEC_DESVAR),1,MV_PAR03,DDataBase)))
		nContcom += If( MV_PAR03 == 1 , ((cAliasVEC)->(VEC_COMVEN)+(cAliasVEC)->(VEC_COMGER)) , If( MV_PAR03 == 2 , ((cAliasVEC)->(VEC_CMFVEN)+(cAliasVEC)->(VEC_CMFGER)) , xmoeda(((cAliasVEC)->(VEC_COMVEN)+(cAliasVEC)->(VEC_COMGER)),1,MV_PAR03,DDataBase)))
		nContliq += If( MV_PAR03 == 1 , (cAliasVEC)->(VEC_LUCLIQ) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_LMFLIQ) , xmoeda((cAliasVEC)->(VEC_LUCLIQ),1,MV_PAR03,DDataBase)))
		nContfix += If( MV_PAR03 == 1 , ((cAliasVEC)->(VEC_DESFIX)+(cAliasVEC)->(VEC_CUSFIX)) , If( MV_PAR03 == 2 , ((cAliasVEC)->(VEC_DMFFIX)+(cAliasVEC)->(VEC_CMFFIX)) , xmoeda(((cAliasVEC)->(VEC_DESFIX)+(cAliasVEC)->(VEC_CUSFIX)),1,MV_PAR03,DDataBase)))
		nContdep += If( MV_PAR03 == 1 , ((cAliasVEC)->(VEC_DESDEP)+(cAliasVEC)->(VEC_DESADM)) , If( MV_PAR03 == 2 , ((cAliasVEC)->(VEC_DMFDEP)+(cAliasVEC)->(VEC_DMFADM)) , xmoeda(((cAliasVEC)->(VEC_DESDEP)+(cAliasVEC)->(VEC_DESADM)),1,MV_PAR03,DDataBase)))
		nContfin += If( MV_PAR03 == 1 , (cAliasVEC)->(VEC_RESFIN) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_RMFFIN) , xmoeda((cAliasVEC)->(VEC_RESFIN),1,MV_PAR03,DDataBase)))
		if nAVECI <= nPulaVEC
			if aPulaVEC[nAVECI] ==	(cAliasVEC)->(RecNo())
				(cAliasVEC)->(	DbSkip())
				nAVECI++
				loop
			endif
		endif
		If (cAliasVEC)->(F4_PISCRED) == "2"     // Tributado
			If (cAliasVEC)->(F4_PISCOF) = "1" // Pis
				nContpis += (cAliasVEC)->(D2_VALIMP6)
			ElseIf (cAliasVEC)->(F4_PISCOF) = "2" // Cofins
				nContcof += (cAliasVEC)->(D2_VALIMP5)
			ElseIf (cAliasVEC)->(F4_PISCOF) = "3" // PIS/Cofins
				nContpis += (cAliasVEC)->(D2_VALIMP6)
				nContcof += (cAliasVEC)->(D2_VALIMP5)
			EndIf
      EndIf
		nPvalpis := nContpis
		nPvalcof := nContcof
		nPjurest := nContjur
		nPlucbru := nContbru
		nPdesvar := nContvar
		nPcomven := nContcom
		nPlucliq := nContliq
		nPdesfix := nContfix
		nPdesdep := nContdep
		nPresfin := nContfin
		nContpis := nContcof := nContjur := nContbru := nContvar := nContcom := nContliq := nContfix := nContdep := nContfin := 0
	Else
		nPvalpis := If( MV_PAR03 == 1 , (cAliasVEC)->(D2_VALIMP6) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_VMFPIS) , xmoeda((cAliasVEC)->(VEC_VALPIS),1,MV_PAR03,DDataBase)))
		nPvalcof := If( MV_PAR03 == 1 , (cAliasVEC)->(D2_VALIMP6) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_VMFCOF) , xmoeda((cAliasVEC)->(VEC_VALCOF),1,MV_PAR03,DDataBase)))
		nPjurest := If( MV_PAR03 == 1 , (cAliasVEC)->(VEC_JUREST) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_JMFEST) , xmoeda((cAliasVEC)->(VEC_JUREST),1,MV_PAR03,DDataBase)))
		nPlucbru := If( MV_PAR03 == 1 , (cAliasVEC)->(VEC_LUCBRU) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_LMFBRU) , xmoeda((cAliasVEC)->(VEC_LUCBRU),1,MV_PAR03,DDataBase)))
		nPdesvar := If( MV_PAR03 == 1 , (cAliasVEC)->(VEC_DESVAR) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_DMFVAR) , xmoeda((cAliasVEC)->(VEC_DESVAR),1,MV_PAR03,DDataBase)))
		nPcomven := If( MV_PAR03 == 1 , ((cAliasVEC)->(VEC_COMVEN)+(cAliasVEC)->(VEC_COMGER)) , If( MV_PAR03 == 2 , ((cAliasVEC)->(VEC_CMFVEN)+(cAliasVEC)->(VEC_CMFGER)) , xmoeda(((cAliasVEC)->(VEC_COMVEN)+(cAliasVEC)->(VEC_COMGER)),1,MV_PAR03,DDataBase)))
		nPlucliq := If( MV_PAR03 == 1 , (cAliasVEC)->(VEC_LUCLIQ) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_LMFLIQ) , xmoeda((cAliasVEC)->(VEC_LUCLIQ),1,MV_PAR03,DDataBase)))
		nPdesfix := If( MV_PAR03 == 1 , ((cAliasVEC)->(VEC_DESFIX)+(cAliasVEC)->(VEC_CUSFIX)) , If( MV_PAR03 == 2 , ((cAliasVEC)->(VEC_DMFFIX)+(cAliasVEC)->(VEC_CMFFIX)) , xmoeda(((cAliasVEC)->(VEC_DESFIX)+(cAliasVEC)->(VEC_CUSFIX)),1,MV_PAR03,DDataBase)))
		nPdesdep := If( MV_PAR03 == 1 , ((cAliasVEC)->(VEC_DESDEP)+(cAliasVEC)->(VEC_DESADM)) , If( MV_PAR03 == 2 , ((cAliasVEC)->(VEC_DMFDEP)+(cAliasVEC)->(VEC_DMFADM)) , xmoeda(((cAliasVEC)->(VEC_DESDEP)+(cAliasVEC)->(VEC_DESADM)),1,MV_PAR03,DDataBase)))
		nPresfin := If( MV_PAR03 == 1 , (cAliasVEC)->(VEC_RESFIN) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_RMFFIN) , xmoeda((cAliasVEC)->(VEC_RESFIN),1,MV_PAR03,DDataBase)))
	EndIf  

	If (MV_PAR08 == 1)

		nPvalvda := If( MV_PAR03 == 1 , (cAliasVEC)->(VEC_VALVDA) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_VMFVDA) , xmoeda((cAliasVEC)->(VEC_VALVDA),1,MV_PAR03,DDataBase)))
		nQtdVda  := (cAliasVEC)->(VEC_QTDITE)
		nPtotimp := If( MV_PAR03 == 1 , (cAliasVEC)->(VEC_TOTIMP) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_TMFIMP) , xmoeda((cAliasVEC)->(VEC_TOTIMP),1,MV_PAR03,DDataBase)))
	   If (cAliasVEC)->(F4_CREDICM) == "N"
			nPvalicm := 0    
		Else	
			nPvalicm := If( MV_PAR03 == 1 , (cAliasVEC)->(VEC_VALICM) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_VMFICM) , xmoeda((cAliasVEC)->(VEC_VALICM),1,MV_PAR03,DDataBase)))
		Endif	
		nPcustot := If( MV_PAR03 == 1 , (cAliasVEC)->(VEC_CUSMED) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_CMFMED) , xmoeda((cAliasVEC)->(VEC_CUSMED),1,MV_PAR03,DDataBase)))
		// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
		nPdescon := If( MV_PAR03 == 1 , (cAliasVEC)->(VEC_VALDES) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_VMFDES) , xmoeda((cAliasVEC)->(VEC_VALDES),1,MV_PAR03,DDataBase)))

   Else            

		If (cAliasVEC)->(VEC_BALOFI) == "B"

			nPvalvda := If( MV_PAR03 == 1 , (cAliasVEC)->(D2_TOTAL)   , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_VMFVDA) , xmoeda((cAliasVEC)->(D2_TOTAL),1,MV_PAR03,DDataBase)))
         nQtdVda  := If( MV_PAR03 == 1 , (cAliasVEC)->(D2_QUANT)   , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_QTDITE) , xmoeda((cAliasVEC)->(D2_QUANT),1,MV_PAR03,DDataBase)))
		   If (cAliasVEC)->(F4_CREDICM) == "N"
				nPvalicm := 0    
			Else	
				nPvalicm := If( MV_PAR03 == 1 , (cAliasVEC)->(D2_VALICM)  , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_VMFICM) , xmoeda((cAliasVEC)->(D2_VALICM),1,MV_PAR03,DDataBase)))
			Endif	
			nPtotimp := If( MV_PAR03 == 1 , ( nPvalpis + nPvalcof + nPvalicm ) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_TMFIMP) , xmoeda(( nPvalpis + nPvalcof + nPvalicm ),1,MV_PAR03,DDataBase)))
			nPcustot := If( MV_PAR03 == 1 , (cAliasVEC)->(D2_CUSTO1) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_CMFMED) , xmoeda((cAliasVEC)->(D2_CUSTO1),1,MV_PAR03,DDataBase)))
			// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
			nPdescon := If( MV_PAR03 == 1 , (cAliasVEC)->(VEC_VALDES) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_VMFDES) , xmoeda((cAliasVEC)->(VEC_VALDES),1,MV_PAR03,DDataBase)))

		Else // (cAliasVEC)->(VEC_BALOFI) == "O"

			nPvalvda := If( MV_PAR03 == 1 , (cAliasVEC)->(D2_TOTAL)  , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_VMFVDA) , xmoeda((cAliasVEC)->(D2_TOTAL),1,MV_PAR03,DDataBase)))
         nQtdVda  := If( MV_PAR03 == 1 , (cAliasVEC)->(D2_QUANT)   , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_QTDITE) , xmoeda((cAliasVEC)->(D2_QUANT),1,MV_PAR03,DDataBase)))
		   If (cAliasVEC)->(F4_CREDICM) == "N"
				nPvalicm := 0    
			Else	
				nPvalicm := If( MV_PAR03 == 1 , (cAliasVEC)->(D2_VALICM) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_VMFICM) , xmoeda((cAliasVEC)->(D2_VALICM),1,MV_PAR03,DDataBase)))
			Endif	
			nPtotimp := If( MV_PAR03 == 1 , ( nPvalpis + nPvalcof + nPvalicm ) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_TMFIMP) , xmoeda(( nPvalpis + nPvalcof + nPvalicm ),1,MV_PAR03,DDataBase)))
			nPcustot := If( MV_PAR03 == 1 , (cAliasVEC)->(D2_CUSTO1) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_CMFMED) , xmoeda((cAliasVEC)->(D2_CUSTO1),1,MV_PAR03,DDataBase)))
			// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
			nPdescon := If( MV_PAR03 == 1 , (cAliasVEC)->(VEC_VALDES) , If( MV_PAR03 == 2 , (cAliasVEC)->(VEC_VMFDES) , xmoeda((cAliasVEC)->(VEC_VALDES),1,MV_PAR03,DDataBase)))

		EndIf

   EndIf

////////// TXT com Clientes/Itens //////////
	If (cAliasVEC)->(VEC_BALOFI) == "B" .or. VOI->VOI_SITTPO # "3" // NAO CONSTAR INTERNOS
		If FunName() == "OFIOR250"
			nMes := aScan(aTXTMes,{|x| x[1] == strzero(month(stod((cAliasVEC)->(VEC_DATVEN))),2)+strzero(year(stod((cAliasVEC)->(VEC_DATVEN))),4) })
		EndIf
		nTXTVda += nPvalvda
		nTXTLuc += nPlucbru
		If VOI->VOI_SITTPO != "2" // se nao for garantia                               
			nTXTVdaNG += nPvalvda
			nTXTLucNG += nPlucbru
			cTipGar   := "N"
		Else	
			cTipGar   := "S"
		Endif	
		nTXTAux1 := aScan(aTXTCli,{|x| x[1] == (cAliasVEC)->(D2_CLIENTE) + (cAliasVEC)->(D2_LOJA)})
   	If nTXTAux1 == 0
			aAdd(aTXTCli,{ (cAliasVEC)->(D2_CLIENTE) + (cAliasVEC)->(D2_LOJA) , nPvalvda , space(12) , nPlucbru , space(12) , len(aTXTCli)+1, VOI->VOI_SITTPO }) 
			If FunName() == "OFIOR250"
				aAdd(aTXTCliA,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
				aAdd(aTXTCliNG,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
				nTXTAux1 := len(aTXTCli)
			EndIf
		Else
			aTXTCli[nTXTAux1,2] += nPvalvda
			aTXTCli[nTXTAux1,4] += nPlucbru
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
					aTXTCliA[aTXTCli[nTXTAux1,6],nMes] += nPvalvda
					aTXTCliA[aTXTCli[nTXTAux1,6],nMes+1] += nPlucbru
				Else
				   If Len(aTXTCliNG) < nTXTAux1
				      nCont := Len(aTXTCliNG) + 1
				      for ii := nCont to nTXTAux1
							aAdd(aTXTCliNG,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
				      Next
				   Endif
					aTXTCliNG[aTXTCli[nTXTAux1,6],nMes] += nPvalvda
					aTXTCliNG[aTXTCli[nTXTAux1,6],nMes+1] += nPlucbru
				Endif	
			EndIf
		EndIf
		nTXTAux1 := aScan(aTXTIte,{|x| x[1] == (cAliasVEC)->(VEC_GRUITE) + (cAliasVEC)->(VEC_CODITE)})
	   If nTXTAux1 == 0
			aAdd(aTXTIte,{ (cAliasVEC)->(VEC_GRUITE) + (cAliasVEC)->(VEC_CODITE) , nPvalvda , space(12) , nPlucbru , space(12) , len(aTXTIte)+1 , VOI->VOI_SITTPO,nQtdVda}) 
			If FunName() == "OFIOR250"
				aAdd(aTXTIteA,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
				aAdd(aTXTIteNG,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
				nTXTAux1 := len(aTXTIte)
			EndIf
		Else
			aTXTIte[nTXTAux1,2] += nPvalvda
			aTXTIte[nTXTAux1,4] += nPlucbru
			aTXTIte[nTXTAux1,8] += nQtdVda
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
					aTXTIteA[aTXTIte[nTXTAux1,6],nMes] += nPvalvda
					aTXTIteA[aTXTIte[nTXTAux1,6],nMes+1] += nPlucbru
				Else	
				   If Len(aTXTIteNG) < nTXTAux1
				      nCont := Len(aTXTIteNG) + 1
				      for ii := nCont to nTXTAux1
							aAdd(aTXTIteNG,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
				      Next
				   Endif
					aTXTIteNG[aTXTIte[nTXTAux1,6],nMes] += nPvalvda
					aTXTIteNG[aTXTIte[nTXTAux1,6],nMes+1] += nPlucbru
				EndIf
			EndIf
		EndIf
	EndIf
		 
	cVenSF2 := (cAliasVEC)->(F2_VEND1)
	cAliasVAI := GetNextAlias()
	BeginSql Alias cAliasVAI
		SELECT VAI.VAI_CC
		FROM %Table:VAI% VAI
		WHERE VAI.VAI_FILIAL = %xFilial:VAI% 
		AND VAI.%NotDel%
		AND VAI.VAI_CODVEN = %Exp:cVenSF2%
	EndSql


	If (cAliasVEC)->(VEC_BALOFI) == "B"      
	   If ( Alltrim((cAliasVEC)->(VS1_NOROUT)) == "2" .and. (cAliasVEC)->(D2_VALISS) > 0  )
		 	aTotOOpe[1,1] += nPvalvda
		 	aTotOOpe[1,2] += ((cAliasVEC)->(F2_VALICM) + (cAliasVEC)->(F2_VALISS) + nPvalpis + nPvalcof)
			aTotOOpe[1,3] += (cAliasVEC)->(F2_VALICM)
		 	aTotOOpe[1,4] += (cAliasVEC)->(F2_VALISS)
			aTotOOpe[1,5] += nPvalpis
			aTotOOpe[1,6] += nPvalcof
			aTotOOpe[1,7] += nPcustot      
			aTotOOpe[1,8] += nPjurest
			aTotOOpe[1,9] += nPlucbru
			aTotOOpe[1,10]+= nPdesvar
			aTotOOpe[1,11]+= nPcomven
			aTotOOpe[1,12]+= nPlucliq
			aTotOOpe[1,13]+= nPdesfix
			aTotOOpe[1,14]+= nPdesdep
			aTotOOpe[1,15]+= nPresfin
			// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
			aTotOOpe[1,16]+= nVPrzMd1
			aTotOOpe[1,17]+= nVPrzMd2
			// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
			aTotOOpe[1,18]+= nPdescon
		 	aOOpeSrv[1,1] += nPvalvda
		 	aOOpeSrv[1,2] += ((cAliasVEC)->(F2_VALICM) + (cAliasVEC)->(F2_VALISS) + nPvalpis + nPvalcof)
			aOOpeSrv[1,3] += (cAliasVEC)->(F2_VALICM)
		 	aOOpeSrv[1,4] += (cAliasVEC)->(F2_VALISS)
		 	aOOpeSrv[1,5] += nPvalpis
			aOOpeSrv[1,6] += nPvalcof
			aOOpeSrv[1,7] += nPcustot      
			aOOpeSrv[1,8] += nPjurest
			aOOpeSrv[1,9] += nPlucbru
			aOOpeSrv[1,10]+= nPdesvar
			aOOpeSrv[1,11]+= nPcomven
			aOOpeSrv[1,12]+= nPlucliq
			aOOpeSrv[1,13]+= nPdesfix
			aOOpeSrv[1,14]+= nPdesdep
			aOOpeSrv[1,15]+= nPresfin
			// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
			aOOpeSrv[1,16]+= nVPrzMd1
			aOOpeSrv[1,17]+= nVPrzMd1
			// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
			aOOpeSrv[1,18]+= nPdescon
			If MV_PAR06 # 1
		   	nPos2 := 0
				nPos2 := aScan(aGrpPag,{|x| x[1] == (cAliasVEC)->(F2_COND) })
				If nPos2 == 0    
					DbSelectArea( "SE4" )
					DbSetOrder(1)
					DbSeek( xFilial("SE4") + (cAliasVEC)->(F2_COND) )
					aAdd(aGrpPag,{ (cAliasVEC)->(F2_COND) , SE4->E4_DESCRI , nPvalvda , ((cAliasVEC)->(F2_VALICM) + (cAliasVEC)->(F2_VALISS) + nPvalpis + nPvalcof) , (cAliasVEC)->(F2_VALICM) , (cAliasVEC)->(F2_VALISS) , nPvalpis , nPvalcof , nPcustot , nPjurest , nPlucbru , nPdesvar , nPcomven , nPlucliq , nPdesfix , nPdesdep , nPresfin, nVPrzMd1, nVPrzMd2, nPdescon }) 
				Else
				 	aGrpPag[nPos2,3] += nPvalvda
				 	aGrpPag[nPos2,4] += ((cAliasVEC)->(F2_VALICM) + (cAliasVEC)->(F2_VALISS) + nPvalpis + nPvalcof)
				 	aGrpPag[nPos2,5] += (cAliasVEC)->(F2_VALICM)
			 		aGrpPag[nPos2,6] += (cAliasVEC)->(F2_VALISS)
				 	aGrpPag[nPos2,7] += nPvalpis
				 	aGrpPag[nPos2,8] += nPvalcof
					aGrpPag[nPos2,9] += nPcustot      
					aGrpPag[nPos2,10]+= nPjurest
					aGrpPag[nPos2,11]+= nPlucbru
					aGrpPag[nPos2,12]+= nPdesvar
					aGrpPag[nPos2,13]+= nPcomven
					aGrpPag[nPos2,14]+= nPlucliq
					aGrpPag[nPos2,15]+= nPdesfix
					aGrpPag[nPos2,16]+= nPdesdep
					aGrpPag[nPos2,17]+= nPresfin
					// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
					aGrpPag[nPos2,18]+= nVPrzMd1
					aGrpPag[nPos2,19]+= nVPrzMd2
					// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
					aGrpPag[nPos2,20]+= nPdescon
				EndIf
				nPos2 := 0
				If MV_PAR06 # 3
					nPos2 := aScan(aTotPag,{|x| x[1]+x[2] == (cAliasVEC)->(F2_COND) + If(lDuplic,"E","I")+(cAliasVEC)->(F2_VEND1) })
				Else     
					nPos2 := aScan(aTotPag,{|x| x[1]+x[2] == (cAliasVEC)->(F2_COND) + If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) })				
				EndIf
									
				If nPos2 == 0 .or. MV_PAR06 == 4
					If MV_PAR06 # 3
						DbSelectArea( "SA3" )
						DbSetOrder(1)
						DbSeek( xFilial("SA3") + (cAliasVEC)->(F2_VEND1) )
						// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
						aAdd(aTotPag,{ (cAliasVEC)->(F2_COND) , If(lDuplic,"E","I")+(cAliasVEC)->(F2_VEND1) , left(SA3->A3_NOME,17) , nPvalvda , ((cAliasVEC)->(F2_VALICM) + (nPvalvda * nPis) + (nPvalvda * nCofins)) , (cAliasVEC)->(F2_VALICM) , 0 , (nPvalvda * nPis) , (nPvalvda * nCofins) , nPcustot , nPjurest , nPlucbru , nPdesvar , nPcomven , nPlucliq , nPdesfix , nPdesdep , nPresfin, nVPrzMd1, nVPrzMd2, nPdescon })
	
						nPos3 := 0
						nPos3 := aScan(aCCVend,{|x| x[1]+x[2] == If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) + (cAliasVEC)->(F2_VEND1) })
						If nPos3 == 0
							DbSelectArea( "CTT" )
							DbSetOrder(1)
							DbSeek( xFilial("CTT") + (cAliasVAI)->(VAI_CC) )
							// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
							aAdd(aCCVend,{ If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , (cAliasVEC)->(F2_VEND1) , left(SA3->A3_NOME,17) , nPvalvda , ((cAliasVEC)->(F2_VALICM) + nPvalpis + nPvalcof) , (cAliasVEC)->(F2_VALICM) , 0 , nPvalpis , nPvalcof , nPcustot , nPjurest , nPlucbru , nPdesvar , nPcomven , nPlucliq , nPdesfix , nPdesdep , nPresfin , If(lDuplic,"Ext ","Int ")+left(CTT->CTT_DESC01,21), nVPrzMd1, nVPrzMd2, nPdescon })
	               Else
						 	aCCVend[nPos3,4]  += nPvalvda
					 		aCCVend[nPos3,5]  += ((cAliasVEC)->(F2_VALICM) + nPvalpis + nPvalcof)
						 	aCCVend[nPos3,6]  += (cAliasVEC)->(F2_VALICM)
						 	aCCVend[nPos3,8]  += nPvalpis
						 	aCCVend[nPos3,9]  += nPvalcof
						 	aCCVend[nPos3,10] += nPcustot
						 	aCCVend[nPos3,11] += nPjurest
				 			aCCVend[nPos3,12] += nPlucbru
					 		aCCVend[nPos3,13] += nPdesvar
						 	aCCVend[nPos3,14] += nPcomven
						 	aCCVend[nPos3,15] += nPlucliq
						 	aCCVend[nPos3,16] += nPdesfix
					 		aCCVend[nPos3,17] += nPdesdep
						 	aCCVend[nPos3,18] += nPresfin
							// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
						 	aCCVend[nPos3,20] += nVPrzMd1
						 	aCCVend[nPos3,21] += nVPrzMd2                                    
							// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
						 	aCCVend[nPos3,22] += nPdescon
	               EndIf
	
						nPos3 := 0
						nPos3 := aScan(aTotCCV,{|x| x[1] == If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) })
						If nPos3 == 0
							// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
							aAdd(aTotCCV,{ If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , nPvalvda , ((cAliasVEC)->(F2_VALICM) + nPvalpis + nPvalcof) , (cAliasVEC)->(F2_VALICM) , 0 , nPvalpis , nPvalcof , nPcustot , nPjurest , nPlucbru , nPdesvar , nPcomven , nPlucliq , nPdesfix , nPdesdep , nPresfin, nVPrzMd1, nVPrzMd2, nPdescon })
	               Else
						 	aTotCCV[nPos3,2]  += nPvalvda
					 		aTotCCV[nPos3,3]  += ((cAliasVEC)->(F2_VALICM) + (cAliasVEC)->(F2_VALISS) + nPvalpis + nPvalcof)
						 	aTotCCV[nPos3,4]  += (cAliasVEC)->(F2_VALICM)
						 	aTotCCV[nPos3,6]  += nPvalpis
						 	aTotCCV[nPos3,7]  += nPvalcof
						 	aTotCCV[nPos3,8]  += nPcustot
						 	aTotCCV[nPos3,9]  += nPjurest
				 			aTotCCV[nPos3,10] += nPlucbru
					 		aTotCCV[nPos3,11] += nPdesvar
						 	aTotCCV[nPos3,12] += nPcomven
						 	aTotCCV[nPos3,13] += nPlucliq
						 	aTotCCV[nPos3,14] += nPdesfix
					 		aTotCCV[nPos3,15] += nPdesdep
						 	aTotCCV[nPos3,16] += nPresfin
							// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
						 	aTotCCV[nPos3,17] += nVPrzMd1
						 	aTotCCV[nPos3,18] += nVPrzMd2
							// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
						 	aTotCCV[nPos3,19] += nPdescon
	               EndIf
	
					Else     
						DbSelectArea( "CTT" )
						DbSetOrder(1)
						DbSeek( xFilial("CTT") + (cAliasVAI)->(VAI_CC) )
						// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
						aAdd(aTotPag,{ (cAliasVEC)->(F2_COND) , If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , left(CTT->CTT_DESC01,14) , nPvalvda , ((cAliasVEC)->(F2_VALICM) + (cAliasVEC)->(F2_VALISS) + nPvalpis + nPvalcof) , (cAliasVEC)->(F2_VALICM) , (cAliasVEC)->(F2_VALISS) , nPvalpis , nPvalcof , nPcustot , nPjurest , nPlucbru , nPdesvar , nPcomven , nPlucliq , nPdesfix , nPdesdep , nPresfin, nVPrzMd1, nVPrzMd2, nPdescon })
					EndIf
				Else
				 	aTotPag[nPos2,4] += nPvalvda
				 	aTotPag[nPos2,5] += ((cAliasVEC)->(F2_VALICM) + (cAliasVEC)->(F2_VALISS) + nPvalpis + nPvalcof)
				 	aTotPag[nPos2,6] += (cAliasVEC)->(F2_VALICM)
				 	aTotPag[nPos2,7] += (cAliasVEC)->(F2_VALISS)
				 	aTotPag[nPos2,8] += nPvalpis
					aTotPag[nPos2,9] += nPvalcof
					aTotPag[nPos2,10]+= nPcustot      
					aTotPag[nPos2,11]+= nPjurest
					aTotPag[nPos2,12]+= nPlucbru
					aTotPag[nPos2,13]+= nPdesvar
					aTotPag[nPos2,14]+= nPcomven
					aTotPag[nPos2,15]+= nPlucliq
					aTotPag[nPos2,16]+= nPdesfix
					aTotPag[nPos2,17]+= nPdesdep
					aTotPag[nPos2,18]+= nPresfin
					// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
					aTotPag[nPos2,19]+= nVPrzMd1
					aTotPag[nPos2,20]+= nVPrzMd2
					// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
					aTotPag[nPos2,21]+= nPdescon
				EndIf
	
			EndIf
			(cAliasVEC)->(	DbSkip())
			(cAliasVAI)->(DBCloseArea())
			Loop
	   ElseIf ( Alltrim((cAliasVEC)->(VS1_NOROUT))=="2" )
		   If ((cAliasVEC)->(F4_DUPLIC)=="S" .and. (cAliasVEC)->(F4_ESTOQUE)=="N" .and. Alltrim((cAliasVEC)->(F4_ATUATF))#"S")
			 	aTotOOpe[1,1] += nPvalvda
			 	aTotOOpe[1,2] += ((cAliasVEC)->(D2_VALICM) + (nPvalpis) + (nPvalcof))
			   If (cAliasVEC)->(F4_CREDICM) != "N"
					aTotOOpe[1,3] += (cAliasVEC)->(D2_VALICM)
				Endif	
				aTotOOpe[1,5] += (nPvalpis)
				aTotOOpe[1,6] += (nPvalcof)
				aTotOOpe[1,7] += nPcustot      
				aTotOOpe[1,8] += nPjurest
				aTotOOpe[1,9] += nPlucbru
				aTotOOpe[1,10]+= nPdesvar
				aTotOOpe[1,11]+= nPcomven
				aTotOOpe[1,12]+= nPlucliq
				aTotOOpe[1,13]+= nPdesfix
				aTotOOpe[1,14]+= nPdesdep
				aTotOOpe[1,15]+= nPresfin
				// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
				aTotOOpe[1,16]+= nVPrzMd1
				aTotOOpe[1,17]+= nVPrzMd2
				// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
				aTotOOpe[1,18]+= nPdescon
			 	aOOpeOut[1,1] += nPvalvda
			   If (cAliasVEC)->(F4_CREDICM) != "N"
				 	aOOpeOut[1,2] += ((cAliasVEC)->(D2_VALICM) + (nPvalpis) + (nPvalcof))
				Else 	
				 	aOOpeOut[1,2] += ((nPvalpis) + (nPvalcof))
				 Endif	
			   If (cAliasVEC)->(F4_CREDICM) != "N"
					aOOpeOut[1,3] += (cAliasVEC)->(D2_VALICM)
				Endif	
			 	aOOpeOut[1,5] += (nPvalpis)
				aOOpeOut[1,6] += (nPvalcof)
				aOOpeOut[1,7] += nPcustot      
				aOOpeOut[1,8] += nPjurest
				aOOpeOut[1,9] += nPlucbru
				aOOpeOut[1,10]+= nPdesvar
				aOOpeOut[1,11]+= nPcomven
				aOOpeOut[1,12]+= nPlucliq
				aOOpeOut[1,13]+= nPdesfix
				aOOpeOut[1,14]+= nPdesdep
				aOOpeOut[1,15]+= nPresfin
				// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
				aOOpeOut[1,16]+= nVPrzMd1
				aOOpeOut[1,17]+= nVPrzMd2
				// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
				aOOpeOut[1,18]+= nPdescon
				If MV_PAR06 # 1
			   	nPos2 := 0
					nPos2 := aScan(aGrpPag,{|x| x[1] == (cAliasVEC)->(F2_COND) })
					If nPos2 == 0    
						DbSelectArea( "SE4" )
						DbSetOrder(1)
						DbSeek( xFilial("SE4") + (cAliasVEC)->(F2_COND) )
						// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
						aAdd(aGrpPag,{ (cAliasVEC)->(F2_COND) , SE4->E4_DESCRI , nPvalvda , ((cAliasVEC)->(F2_VALICM) + (nPvalpis) + (nPvalcof)) , (cAliasVEC)->(F2_VALICM) , 0 , (nPvalvda * nPis) , (nPvalvda * nCofins) , nPcustot , nPjurest , nPlucbru , nPdesvar , nPcomven , nPlucliq , nPdesfix , nPdesdep , nPresfin, nVPrzMd1, nVPrzMd2, nPdescon }) 
					Else
					 	aGrpPag[nPos2,3] += nPvalvda
				 		aGrpPag[nPos2,4] += ((cAliasVEC)->(F2_VALICM) + (nPvalpis) + (nPvalcof))
					 	aGrpPag[nPos2,5] += (cAliasVEC)->(F2_VALICM)
					 	aGrpPag[nPos2,7] += (nPvalpis)
					 	aGrpPag[nPos2,8] += (nPvalcof)
						aGrpPag[nPos2,9] += nPcustot      
						aGrpPag[nPos2,10]+= nPjurest
						aGrpPag[nPos2,11]+= nPlucbru
						aGrpPag[nPos2,12]+= nPdesvar
						aGrpPag[nPos2,13]+= nPcomven
						aGrpPag[nPos2,14]+= nPlucliq
						aGrpPag[nPos2,15]+= nPdesfix
						aGrpPag[nPos2,16]+= nPdesdep
						aGrpPag[nPos2,17]+= nPresfin
						// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
						aGrpPag[nPos2,18]+= nVPrzMd1
						aGrpPag[nPos2,19]+= nVPrzMd2
						// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
						aGrpPag[nPos2,20]+= nPdescon
					EndIf
					nPos2 := 0
					If MV_PAR06 # 3
						nPos2 := aScan(aTotPag,{|x| x[1]+x[2] == (cAliasVEC)->(F2_COND) + If(lDuplic,"E","I")+(cAliasVEC)->(F2_VEND1) })
					Else     
						nPos2 := aScan(aTotPag,{|x| x[1]+x[2] == (cAliasVEC)->(F2_COND) + If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) })				
					EndIf
					If nPos2 == 0 .or. MV_PAR06 == 4
						If MV_PAR06 # 3
							DbSelectArea( "SA3" )
							DbSetOrder(1)
							DbSeek( xFilial("SA3") + (cAliasVEC)->(F2_VEND1) )
							// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
							aAdd(aTotPag,{ (cAliasVEC)->(F2_COND) , If(lDuplic,"E","I")+(cAliasVEC)->(F2_VEND1) , left(SA3->A3_NOME,17) , nPvalvda , ((cAliasVEC)->(F2_VALICM) + (nPvalvda * nPis) + (nPvalvda * nCofins)) , (cAliasVEC)->(F2_VALICM) , 0 , (nPvalvda * nPis) , (nPvalvda * nCofins) , nPcustot , nPjurest , nPlucbru , nPdesvar , nPcomven , nPlucliq , nPdesfix , nPdesdep , nPresfin, nVPrzMd1, nVPrzMd2, nPdescon })
							nPos3 := 0
							nPos3 := aScan(aCCVend,{|x| x[1]+x[2] == If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) + (cAliasVEC)->(F2_VEND1) })
							If nPos3 == 0
								DbSelectArea( "CTT" )
								DbSetOrder(1)
								DbSeek( xFilial("CTT") + (cAliasVAI)->(VAI_CC) )
								// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
								aAdd(aCCVend,{ If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , (cAliasVEC)->(F2_VEND1) , left(SA3->A3_NOME,17) , nPvalvda , ((cAliasVEC)->(F2_VALICM) + (nPvalvda * nPis) + (nPvalvda * nCofins)) , (cAliasVEC)->(F2_VALICM) , 0 , (nPvalvda * nPis) , (nPvalvda * nCofins) , nPcustot , nPjurest , nPlucbru , nPdesvar , nPcomven , nPlucliq , nPdesfix , nPdesdep , nPresfin , If(lDuplic,"Ext ","Int ")+left(CTT->CTT_DESC01,21), nVPrzMd1, nVPrzMd2, nPDescon })
		               Else
							 	aCCVend[nPos3,4]  += nPvalvda
						 		aCCVend[nPos3,5]  += ((cAliasVEC)->(F2_VALICM) + (nPvalpis) + (nPvalcof))
							 	aCCVend[nPos3,6]  += (cAliasVEC)->(F2_VALICM)
							 	aCCVend[nPos3,8]  += (nPvalpis)
							 	aCCVend[nPos3,9]  += (nPvalcof)
							 	aCCVend[nPos3,10] += nPcustot
							 	aCCVend[nPos3,11] += nPjurest
					 			aCCVend[nPos3,12] += nPlucbru
						 		aCCVend[nPos3,13] += nPdesvar
							 	aCCVend[nPos3,14] += nPcomven
							 	aCCVend[nPos3,15] += nPlucliq
						 		aCCVend[nPos3,16] += nPdesfix
						 		aCCVend[nPos3,17] += nPdesdep
							 	aCCVend[nPos3,18] += nPresfin
								// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
							 	aCCVend[nPos3,20] += nVPrzMd1
							 	aCCVend[nPos3,21] += nVPrzMd2
								// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
							 	aCCVend[nPos3,22] += nPdescon
	         	      EndIf
							nPos3 := 0
							nPos3 := aScan(aTotCCV,{|x| x[1] == If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) })
							If nPos3 == 0
								// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
								aAdd(aTotCCV,{ If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , nPvalvda , ((cAliasVEC)->(F2_VALICM) + (nPvalpis) + (nPvalcof)) , (cAliasVEC)->(F2_VALICM) , 0 , (nPvalvda * nPis) , (nPvalvda * nCofins) , nPcustot , nPjurest , nPlucbru , nPdesvar , nPcomven , nPlucliq , nPdesfix , nPdesdep , nPresfin, nVPrzMd1, nVPrzMd2, nPdescon })
	            	   Else
							 	aTotCCV[nPos3,2]  += nPvalvda
					 			aTotCCV[nPos3,3]  += ((cAliasVEC)->(F2_VALICM) + (nPvalpis) + (nPvalcof))
							 	aTotCCV[nPos3,4]  += (cAliasVEC)->(F2_VALICM)
							 	aTotCCV[nPos3,6]  += (nPvalpis)
							 	aTotCCV[nPos3,7]  += (nPvalcof)
							 	aTotCCV[nPos3,8]  += nPcustot
							 	aTotCCV[nPos3,9]  += nPjurest
					 			aTotCCV[nPos3,10] += nPlucbru
						 		aTotCCV[nPos3,11] += nPdesvar
							 	aTotCCV[nPos3,12] += nPcomven
							 	aTotCCV[nPos3,13] += nPlucliq
							 	aTotCCV[nPos3,14] += nPdesfix
					 			aTotCCV[nPos3,15] += nPdesdep
						 		aTotCCV[nPos3,16] += nPresfin
								// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
						 		aTotCCV[nPos3,17] += nVPrzMd1
						 		aTotCCV[nPos3,18] += nVPrzMd2
								// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
						 		aTotCCV[nPos3,19] += nPdescon
		               EndIf
						Else     
							DbSelectArea( "CTT" )
							DbSetOrder(1)
							DbSeek( xFilial("CTT") + (cAliasVAI)->(VAI_CC) )
							// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
							aAdd(aTotPag,{ (cAliasVEC)->(F2_COND) , If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , left(CTT->CTT_DESC01,14) , nPvalvda , ((cAliasVEC)->(F2_VALICM) + (nPvalpis) + (nPvalcof)) , (cAliasVEC)->(F2_VALICM) , 0 , (nPvalvda * nPis) , (nPvalvda * nCofins) , nPcustot , nPjurest , nPlucbru , nPdesvar , nPcomven , nPlucliq , nPdesfix , nPdesdep , nPresfin, nVPrzMd1, nVPrzMd2, nPdescon })
						EndIf
					Else
					 	aTotPag[nPos2,4] += nPvalvda
					 	aTotPag[nPos2,5] += ((cAliasVEC)->(F2_VALICM) + (nPvalpis) + (nPvalcof))
					 	aTotPag[nPos2,6] += (cAliasVEC)->(F2_VALICM)
					 	aTotPag[nPos2,8] += (nPvalpis)
						aTotPag[nPos2,9] += (nPvalcof)
						aTotPag[nPos2,10]+= nPcustot      
						aTotPag[nPos2,11]+= nPjurest
						aTotPag[nPos2,12]+= nPlucbru
						aTotPag[nPos2,13]+= nPdesvar
						aTotPag[nPos2,14]+= nPcomven
						aTotPag[nPos2,15]+= nPlucliq
						aTotPag[nPos2,16]+= nPdesfix
						aTotPag[nPos2,17]+= nPdesdep
						aTotPag[nPos2,18]+= nPresfin
						// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
						aTotPag[nPos2,19]+= nVPrzMd1
						aTotPag[nPos2,20]+= nVPrzMd2
						// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
						aTotPag[nPos2,21]+= nPdescon
					EndIf
	         EndIf
				(cAliasVEC)->(	DbSkip())
				(cAliasVAI)->(DBCloseArea())
				Loop
			EndIf
		EndIf
   Endif
	If ((cAliasVEC)->(VEC_BALOFI) == "B" .and. Alltrim((cAliasVEC)->(F4_ATUATF)) == "S")    //  A T I V O   I M O B I L I Z A D O
		aTotAtiMob[1,3] += nPvalvda
		aTotAtiMob[1,8] += nPcustot 
		aTotAtiMob[3,3] += nPvalvda
		aTotAtiMob[3,8] += nPcustot
	 	DbSelectArea( "SBM" )
		DbSetOrder(1)
		DbSeek( xFilial("SBM") + (cAliasVEC)->(VEC_GRUITE) , .f. )
		aAdd(aNumAtiMob,{ "O" , (cAliasVEC)->(VEC_GRUITE) + " " + SBM->BM_DESC , nPvalvda , 0 , 0 , 0 , 0 , nPcustot }) 
   Else
		If VOI->VOI_SITTPO # "3"
			aGrpPBO[nPos,2]  += nPvalvda
			aGrpPBO[nPos,3]  += nPtotimp
			aGrpPBO[nPos,4]  += nPvalicm
			aGrpPBO[nPos,5]  += nPvalpis
			aGrpPBO[nPos,6]  += nPvalcof
			aGrpPBO[nPos,7]  += nPcustot
			aGrpPBO[nPos,8]  += nPjurest
			aGrpPBO[nPos,9]  += nPlucbru
			aGrpPBO[nPos,10] += nPdesvar
			aGrpPBO[nPos,11] += nPcomven
			aGrpPBO[nPos,12] += nPlucliq
			aGrpPBO[nPos,13] += nPdesfix
			aGrpPBO[nPos,14] += nPdesdep
			aGrpPBO[nPos,15] += nPresfin
			// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
			aGrpPBO[nPos,16] += nVPrzMd1
			aGrpPBO[nPos,17] += nVPrzMd2
			// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
			aGrpPBO[nPos,18] += nPdescon
		EndIf                                                                       
		If (cAliasVEC)->(VEC_BALOFI) == "O"
		   cGrupo := VOI->VOI_SITTPO
			nPos := 0
			nPos := aScan(aDpto,{|x| x[1]+x[17]+x[18] == cDpto+"O"+cGrupo })
			If nPos == 0
				DbSelectArea( "VAP" )
				DbSetOrder(1)
				DbSeek( xFilial("VAP") + cDpto )
				// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
				aAdd(aDpto,{ cDpto , nPvalvda , nPtotimp , nPvalicm , nPvalpis , nPvalcof , nPcustot , nPjurest , nPlucbru , nPdesvar , nPcomven , nPlucliq , nPdesfix , nPdesdep , nPresfin , left(Alltrim(VAP->VAP_DESDEP)+repl(".",21),21) , "O" , cGrupo, nVPrzMd1, nVPrzMd2, nPdescon })
			Else
			 	aDpto[nPos,2]  += nPvalvda
			 	aDpto[nPos,3]  += nPtotimp
			 	aDpto[nPos,4]  += nPvalicm
			 	aDpto[nPos,5]  += nPvalpis
			 	aDpto[nPos,6]  += nPvalcof
			 	aDpto[nPos,7]  += nPcustot
		 		aDpto[nPos,8]  += nPjurest
			 	aDpto[nPos,9]  += nPlucbru
			 	aDpto[nPos,10] += nPdesvar
			 	aDpto[nPos,11] += nPcomven
			 	aDpto[nPos,12] += nPlucliq
			 	aDpto[nPos,13] += nPdesfix
			 	aDpto[nPos,14] += nPdesdep
			 	aDpto[nPos,15] += nPresfin
				// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
			 	aDpto[nPos,19] += nVPrzMd1
			 	aDpto[nPos,20] += nVPrzMd2
				// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
			 	aDpto[nPos,21] += nPdescon
			EndIf
		Else
			cGrupo := "9"
			nPos := 0
			nPos := aScan(aDpto,{|x| x[1]+x[17]+x[18] == cDpto+"B"+cGrupo })
			If nPos == 0
				DbSelectArea( "VAP" )
				DbSetOrder(1)
				DbSeek( xFilial("VAP") + cDpto )
				// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
				aAdd(aDpto,{ cDpto , nPvalvda , nPtotimp , nPvalicm , nPvalpis , nPvalcof , nPcustot , nPjurest , nPlucbru , nPdesvar , nPcomven , nPlucliq , nPdesfix , nPdesdep , nPresfin , left(Alltrim(VAP->VAP_DESDEP)+repl(".",21),21) , "B" , cGrupo, nVPrzMd1, nVPrzMd2, nPdescon })
			Else
			 	aDpto[nPos,2]  += nPvalvda
			 	aDpto[nPos,3]  += nPtotimp
			 	aDpto[nPos,4]  += nPvalicm
			 	aDpto[nPos,5]  += nPvalpis
			 	aDpto[nPos,6]  += nPvalcof
			 	aDpto[nPos,7]  += nPcustot
		 		aDpto[nPos,8]  += nPjurest
			 	aDpto[nPos,9]  += nPlucbru
			 	aDpto[nPos,10] += nPdesvar
			 	aDpto[nPos,11] += nPcomven
			 	aDpto[nPos,12] += nPlucliq
			 	aDpto[nPos,13] += nPdesfix
			 	aDpto[nPos,14] += nPdesdep
			 	aDpto[nPos,15] += nPresfin
				// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
			 	aDpto[nPos,19] += nVPrzMd1
			 	aDpto[nPos,20] += nVPrzMd2
				// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
			 	aDpto[nPos,21] += nPdescon
			EndIf
		EndIf			
		nPos := 0
		If ( MV_PAR05 == 1 .or. ( MV_PAR05 == 2 .and. MV_PAR04 # 3 .and. MV_PAR04 # 4 ))
			nPos := aScan(aNumPec,{|x| x[1] + x[2] + x[18] + x[19] == (cAliasVEC)->(VEC_BALOFI) + (cAliasVEC)->(VEC_GRUITE) + cGrupo + cDpto })
		Else                                                          
			nPos := aScan(aNumPec,{|x| x[1] + x[2] + x[18] + x[19] == (cAliasVEC)->(VEC_BALOFI) + (cAliasVEC)->(F2_CLIENTE) + cGrupo + cDpto })
		EndIf	
		If nPos == 0
			If ( MV_PAR05 == 1 .or. ( MV_PAR05 == 2 .and. MV_PAR04 # 3 .and. MV_PAR04 # 4 ))
			 	DbSelectArea( "SBM" )
				DbSetOrder(1)
				DbSeek( xFilial("SBM") + (cAliasVEC)->(VEC_GRUITE) , .f. )
				// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
				aAdd(aNumPec,{ (cAliasVEC)->(VEC_BALOFI) , (cAliasVEC)->(VEC_GRUITE) , SBM->BM_DESC , nPvalvda , nPtotimp , nPvalicm , nPvalpis , nPvalcof , nPcustot , nPjurest , nPlucbru , nPdesvar , nPcomven , nPlucliq , nPdesfix , nPdesdep , nPresfin , cGrupo , cDpto, nVPrzMd1, nVPrzMd2, nPdescon  })
			Else                                                          
		 	 	DbSelectArea( "SA1" )
				DbSetOrder(1)
				DbSeek( xFilial("SA1") + (cAliasVEC)->(F2_CLIENTE) + (cAliasVEC)->(F2_LOJA) , .f. )
				// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
				aAdd(aNumPec,{ (cAliasVEC)->(VEC_BALOFI) , (cAliasVEC)->(F2_CLIENTE) , left(SA1->A1_NOME,20) , nPvalvda , nPtotimp , nPvalicm , nPvalpis , nPvalcof , nPcustot , nPjurest , nPlucbru , nPdesvar , nPcomven , nPlucliq , nPdesfix , nPdesdep , nPresfin , cGrupo , cDpto, nVPrzMd1, nVPrzMd2, nPdescon })
			EndIf	
			If Type("aAnaPec") == "A" .and. VOI->VOI_SITTPO != "3" // So leva se nao for Tipo Interno
	 		 	DbSelectArea( "SA1" )
				DbSetOrder(1)
				DbSeek( xFilial("SA1") + (cAliasVEC)->(F2_CLIENTE) + (cAliasVEC)->(F2_LOJA) )
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek( xFilial("SB1") + (cAliasVEC)->(VEC_PECINT) )
				aadd(aAnaPec,{SM0->M0_CODIGO,SM0->M0_CODFIL,(cAliasVEC)->(F2_DOC),(cAliasVEC)->(F2_SERIE),"P"+(cAliasVEC)->(VEC_BALOFI),SA1->A1_COD+SA1->A1_LOJA+LEFT(SA1->A1_NREDUZ,20),(cAliasVEC)->(VEC_GRUITE),(cAliasVEC)->(VEC_CODITE),SB1->B1_DESC,nPValVda,nPTotImp,nPCusTot,stod((cAliasVEC)->(F2_EMISSAO)),(cAliasVEC)->(VEC_QTDITE)})
			Endif	
		Else
		 	aNumPec[nPos,4]  += nPvalvda
		 	aNumPec[nPos,5]  += nPtotimp
		 	aNumPec[nPos,6]  += nPvalicm
		 	aNumPec[nPos,7]  += nPvalpis
		 	aNumPec[nPos,8]  += nPvalcof
		 	aNumPec[nPos,9]  += nPcustot
		 	aNumPec[nPos,10] += nPjurest
		 	aNumPec[nPos,11] += nPlucbru
		 	aNumPec[nPos,12] += nPdesvar
		 	aNumPec[nPos,13] += nPcomven
		 	aNumPec[nPos,14] += nPlucliq
		 	aNumPec[nPos,15] += nPdesfix
		 	aNumPec[nPos,16] += nPdesdep
		 	aNumPec[nPos,17] += nPresfin
			// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
		 	aNumPec[nPos,20] += nVPrzMd1
		 	aNumPec[nPos,21] += nVPrzMd2
			// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
		 	aNumPec[nPos,22] += nPdescon
			If Type("aAnaPec") == "A" .and. VOI->VOI_SITTPO != "3" // So leva se nao for Tipo Interno
	 		 	DbSelectArea( "SA1" )
				DbSetOrder(1)
				DbSeek( xFilial("SA1") + (cAliasVEC)->(F2_CLIENTE) + (cAliasVEC)->(F2_LOJA) )
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek( xFilial("SB1") + (cAliasVEC)->(VEC_PECINT ))
				aadd(aAnaPec,{SM0->M0_CODIGO,SM0->M0_CODFIL,(cAliasVEC)->(F2_DOC),(cAliasVEC)->(F2_SERIE),"P"+(cAliasVEC)->(VEC_BALOFI),SA1->A1_COD+SA1->A1_LOJA+LEFT(SA1->A1_NREDUZ,20),(cAliasVEC)->(VEC_GRUITE),(cAliasVEC)->(VEC_CODITE),SB1->B1_DESC,nPValVda,nPTotImp,nPCusTot,stod((cAliasVEC)->(F2_EMISSAO)),(cAliasVEC)->(VEC_QTDITE)})
			Endif	
		EndIf        
		nPos := 0
		nPos := aScan(aGrpPec,{|x| x[1]+x[16] == (cAliasVEC)->(VEC_BALOFI) + cGrupo })
		If nPos == 0
			// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
	 		aAdd(aGrpPec,{ (cAliasVEC)->(VEC_BALOFI) , nPvalvda , nPtotimp , nPvalicm , nPvalpis , nPvalcof , nPcustot , nPjurest , nPlucbru , nPdesvar , nPcomven , nPlucliq , nPdesfix , nPdesdep , nPresfin , cGrupo, nVPrzMd1, nVPrzMd2, nPdescon }) 
		Else
		 	aGrpPec[nPos,2]  += nPvalvda
		 	aGrpPec[nPos,3]  += nPtotimp
		 	aGrpPec[nPos,4]  += nPvalicm
		 	aGrpPec[nPos,5]  += nPvalpis
		 	aGrpPec[nPos,6]  += nPvalcof
		 	aGrpPec[nPos,7]  += nPcustot
		 	aGrpPec[nPos,8]  += nPjurest
		 	aGrpPec[nPos,9]  += nPlucbru
		 	aGrpPec[nPos,10] += nPdesvar
		 	aGrpPec[nPos,11] += nPcomven
		 	aGrpPec[nPos,12] += nPlucliq
		 	aGrpPec[nPos,13] += nPdesfix
		 	aGrpPec[nPos,14] += nPdesdep
		 	aGrpPec[nPos,15] += nPresfin
			// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
		 	aGrpPec[nPos,17] += nVPrzMd1
		 	aGrpPec[nPos,18] += nVPrzMd2
			// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
		 	aGrpPec[nPos,19] += nPdescon
		EndIf
		If VOI->VOI_SITTPO # "3"
			aTotPec[1,1]  += nPvalvda
		 	aTotPec[1,2]  += nPtotimp
		 	aTotPec[1,3]  += nPvalicm
		 	aTotPec[1,4]  += nPvalpis
			aTotPec[1,5]  += nPvalcof
			aTotPec[1,6]  += nPcustot
			aTotPec[1,7]  += nPjurest
			aTotPec[1,8]  += nPlucbru
			aTotPec[1,9]  += nPdesvar
			aTotPec[1,10] += nPcomven
			aTotPec[1,11] += nPlucliq
			aTotPec[1,12] += nPdesfix
			aTotPec[1,13] += nPdesdep
			aTotPec[1,14] += nPresfin
			// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
			aTotPec[1,15] += nVPrzMd1
			aTotPec[1,16] += nVPrzMd2
			// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
			aTotPec[1,17] += nPdescon
		 	aTotal[1,1]  += nPvalvda
		 	aTotal[1,2]  += nPtotimp
		 	aTotal[1,3]  += nPvalicm
		 	aTotal[1,5]  += nPvalpis
			aTotal[1,6]  += nPvalcof
			aTotal[1,7]  += nPcustot
			aTotal[1,8]  += nPjurest
			aTotal[1,9]  += nPlucbru
			aTotal[1,10] += nPdesvar
			aTotal[1,11] += nPcomven
			aTotal[1,12] += nPlucliq
			aTotal[1,13] += nPdesfix
			aTotal[1,14] += nPdesdep
			aTotal[1,15] += nPresfin
			// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
			aTotal[1,16] += nVPrzMd1
			aTotal[1,17] += nVPrzMd2
			// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
			aTotal[1,18] += nPdescon
		EndIf
		If MV_PAR06 # 1
			If VOI->VOI_SITTPO # "3"
			 	aTotCon[1,1]  += nPvalvda
			 	aTotCon[1,2]  += nPtotimp
			 	aTotCon[1,3]  += nPvalicm
			 	aTotCon[1,5]  += nPvalpis
				aTotCon[1,6]  += nPvalcof
				aTotCon[1,7]  += nPcustot
				aTotCon[1,8]  += nPjurest
				aTotCon[1,9]  += nPlucbru
				aTotCon[1,10] += nPdesvar
				aTotCon[1,11] += nPcomven
				aTotCon[1,12] += nPlucliq
				aTotCon[1,13] += nPdesfix
				aTotCon[1,14] += nPdesdep
				aTotCon[1,15] += nPresfin
				// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
				aTotCon[1,16] += nVPrzMd1
				aTotCon[1,17] += nVPrzMd2
				// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
				aTotCon[1,18] += nPdescon
			EndIf
		   nPos := 0 
		  	If (cAliasVEC)->(VEC_BALOFI) == "B"
				nPos := aScan(aPecSrvOfi,{|x| x[1]+x[2]+x[4] == (cAliasVEC)->(F2_COND) + If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasVEC)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) + If(lDuplic,"Ext ","Int ")+left(STR0065,18) })
				If nPos == 0
					DbSelectArea( "SA1" )
					DbSetOrder(1)
					DbSeek( xFilial("SA1") + (cAliasVEC)->(F2_CLIENTE) + (cAliasVEC)->(F2_LOJA))
		   		aAdd(aPecSrvOfi,{ (cAliasVEC)->(F2_COND) , If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasVEC)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) , nPvalvda , If(lDuplic,"Ext ","Int ")+left(STR0065,18) })
				Else
			   	aPecSrvOfi[nPos,3] += nPvalvda
				EndIf			
				nPos := aScan(aConPagNF,{|x| x[1]+x[2]+x[3]+x[4]+x[7] == (cAliasVEC)->(F2_COND) + If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasVEC)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) + (cAliasVEC)->(VEC_NUMNFI) + (cAliasVEC)->(VEC_SERNFI) + If(lDuplic,"Ext ","Int ")+left(STR0065,18) })
			Else // VEC->VEC_BALOFI == "O"
				nPos := aScan(aPecSrvOfi,{|x| x[1]+x[2]+x[4] == (cAliasVEC)->(F2_COND) + If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasVEC)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) + If(lDuplic,"Ext ","Int ")+left(STR0064,18) })
				If nPos == 0
					DbSelectArea( "SA1" )
					DbSetOrder(1)
					DbSeek( xFilial("SA1") + (cAliasVEC)->(F2_CLIENTE) + (cAliasVEC)->(F2_LOJA) )
		   		aAdd(aPecSrvOfi,{ (cAliasVEC)->(F2_COND) , If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasVEC)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) , nPvalvda , If(lDuplic,"Ext ","Int ")+left(STR0064,18) })
				Else
			   	aPecSrvOfi[nPos,3] += nPvalvda
				EndIf			
				nPos := aScan(aConPagNF,{|x| x[1]+x[2]+x[3]+x[4]+x[7] == (cAliasVEC)->(F2_COND) + If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasVEC)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) + (cAliasVEC)->(VEC_NUMNFI) + (cAliasVEC)->(VEC_SERNFI) + If(lDuplic,"Ext ","Int ")+left(STR0064,18) })
			EndIf
		   If nPos == 0
				DbSelectArea( "SA1" )
				DbSetOrder(1)
				DbSeek( xFilial("SA1") + (cAliasVEC)->(F2_CLIENTE) + (cAliasVEC)->(F2_LOJA) )
   			If (cAliasVEC)->(VEC_BALOFI) == "B"
					aAdd(aConPagNF,{ (cAliasVEC)->(F2_COND) , If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasVEC)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) , (cAliasVEC)->(VEC_NUMNFI) , (cAliasVEC)->(VEC_SERNFI) , left(SA1->A1_NOME,10) , nPvalvda , If(lDuplic,"Ext ","Int ")+left(STR0065,18) })
				Else // (cAliasVEC)->(VEC_BALOFI) == "O"
					aAdd(aConPagNF,{ (cAliasVEC)->(F2_COND) , If(lDuplic,"E","I")+If(MV_PAR06#3,(cAliasVEC)->(F2_VEND1),(cAliasVAI)->(VAI_CC)) , (cAliasVEC)->(VEC_NUMNFI) , (cAliasVEC)->(VEC_SERNFI) , left(SA1->A1_NOME,10) , nPvalvda , If(lDuplic,"Exp ","Int ")+left(STR0064,18) })
				EndIf
			Else
		   	aConPagNF[nPos,6] += nPvalvda
			EndIf                    
			nPos := 0
			nPos := aScan(aGrpPag,{|x| x[1] == (cAliasVEC)->(F2_COND) })
			If nPos == 0    
				DbSelectArea( "SE4" )
				DbSetOrder(1)
				DbSeek( xFilial("SE4") + (cAliasVEC)->(F2_COND) )
				// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
				aAdd(aGrpPag,{ (cAliasVEC)->(F2_COND) , SE4->E4_DESCRI , nPvalvda , nPtotimp , nPvalicm , 0 , nPvalpis , nPvalcof , nPcustot , nPjurest , nPlucbru , nPdesvar , nPcomven , nPlucliq , nPdesfix , nPdesdep , nPresfin, nVPrzMd1, nVPrzMd2, nPdescon }) 
			Else
			 	aGrpPag[nPos,3]  += nPvalvda
			 	aGrpPag[nPos,4]  += nPtotimp
			 	aGrpPag[nPos,5]  += nPvalicm
			 	aGrpPag[nPos,7]  += nPvalpis
			 	aGrpPag[nPos,8]  += nPvalcof
			 	aGrpPag[nPos,9]  += nPcustot
			 	aGrpPag[nPos,10] += nPjurest
			 	aGrpPag[nPos,11] += nPlucbru
			 	aGrpPag[nPos,12] += nPdesvar
			 	aGrpPag[nPos,13] += nPcomven
			 	aGrpPag[nPos,14] += nPlucliq
			 	aGrpPag[nPos,15] += nPdesfix
			 	aGrpPag[nPos,16] += nPdesdep
			 	aGrpPag[nPos,17] += nPresfin
				// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
			 	aGrpPag[nPos,18] += nVPrzMd1
			 	aGrpPag[nPos,19] += nVPrzMd2
				// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
			 	aGrpPag[nPos,20] += nPdescon
			EndIf
	   	nPos := 0
			If MV_PAR06 # 3
				nPos := aScan(aTotPag,{|x| x[1]+x[2] == (cAliasVEC)->(F2_COND) + If(lDuplic,"E","I")+(cAliasVEC)->(F2_VEND1) })
			Else     
				nPos := aScan(aTotPag,{|x| x[1]+x[2] == (cAliasVEC)->(F2_COND) + If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) })				
			EndIf
			If nPos == 0 .or. MV_PAR06 == 4
				If MV_PAR06 # 3
					DbSelectArea( "SA3" )
					DbSetOrder(1)
					DbSeek( xFilial("SA3") + (cAliasVEC)->(F2_VEND1) )
					// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
					aAdd(aTotPag,{ (cAliasVEC)->(F2_COND) , If(lDuplic,"E","I")+(cAliasVEC)->(F2_VEND1) , left(SA3->A3_NOME,17) , nPvalvda , nPtotimp , nPvalicm , 0 , nPvalpis , nPvalcof , nPcustot , nPjurest , nPlucbru , nPdesvar , nPcomven , nPlucliq , nPdesfix , nPdesdep , nPresfin, nVPrzMd1, nVPrzMd2, nPdescon }) 
					nPos3 := 0
					nPos3 := aScan(aCCVend,{|x| x[1]+x[2] == If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) + (cAliasVEC)->(F2_VEND1) })
					If nPos3 == 0
						DbSelectArea( "CTT" )
						DbSetOrder(1)
						DbSeek( xFilial("CTT") + (cAliasVAI)->(VAI_CC) )
						// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
						aAdd(aCCVend,{ If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , (cAliasVEC)->(F2_VEND1) , left(SA3->A3_NOME,17) , nPvalvda , nPtotimp , nPvalicm , 0 , nPvalpis , nPvalcof , nPcustot , nPjurest , nPlucbru , nPdesvar , nPcomven , nPlucliq , nPdesfix , nPdesdep , nPresfin , If(lDuplic,"Ext ","Int ")+left(CTT->CTT_DESC01,21), nVPrzMd1, nVPrzMd2, nPdescon }) 
               Else 
					 	aCCVend[nPos3,4]  += nPvalvda
				 		aCCVend[nPos3,5]  += nPtotimp
					 	aCCVend[nPos3,6]  += nPvalicm
					 	aCCVend[nPos3,8]  += nPvalpis
					 	aCCVend[nPos3,9]  += nPvalcof
					 	aCCVend[nPos3,10] += nPcustot
					 	aCCVend[nPos3,11] += nPjurest
			 			aCCVend[nPos3,12] += nPlucbru
				 		aCCVend[nPos3,13] += nPdesvar
					 	aCCVend[nPos3,14] += nPcomven
					 	aCCVend[nPos3,15] += nPlucliq
					 	aCCVend[nPos3,16] += nPdesfix
				 		aCCVend[nPos3,17] += nPdesdep
					 	aCCVend[nPos3,18] += nPresfin
						// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
					 	aCCVend[nPos3,20] += nVPrzMd1
					 	aCCVend[nPos3,21] += nVPrzMd2
						// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
					 	aCCVend[nPos3,21] += nPdescon
               EndIf
					nPos3 := 0
					nPos3 := aScan(aTotCCV,{|x| x[1] == If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) })
					If nPos3 == 0
						// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
						aAdd(aTotCCV,{ If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , nPvalvda , nPtotimp , nPvalicm , 0 , nPvalpis , nPvalcof , nPcustot , nPjurest , nPlucbru , nPdesvar , nPcomven , nPlucliq , nPdesfix , nPdesdep , nPresfin, nVPrzMd1, nVPrzMd2, nPdescon }) 
               Else 
					 	aTotCCV[nPos3,2]  += nPvalvda
				 		aTotCCV[nPos3,3]  += nPtotimp
					 	aTotCCV[nPos3,4]  += nPvalicm
					 	aTotCCV[nPos3,6]  += nPvalpis
					 	aTotCCV[nPos3,7]  += nPvalcof
					 	aTotCCV[nPos3,8]  += nPcustot
					 	aTotCCV[nPos3,9]  += nPjurest
			 			aTotCCV[nPos3,10] += nPlucbru
				 		aTotCCV[nPos3,11] += nPdesvar
					 	aTotCCV[nPos3,12] += nPcomven
					 	aTotCCV[nPos3,13] += nPlucliq
					 	aTotCCV[nPos3,14] += nPdesfix
				 		aTotCCV[nPos3,15] += nPdesdep
					 	aTotCCV[nPos3,16] += nPresfin
						// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
					 	aTotCCV[nPos3,17] += nVPrzMd1
					 	aTotCCV[nPos3,18] += nVPrzMd2
						// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
					 	aTotCCV[nPos3,19] += nPdescon
               EndIf
				Else     
					DbSelectArea( "CTT" )
					DbSetOrder(1)
					DbSeek( xFilial("CTT") + (cAliasVAI)->(VAI_CC) )
					// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
					aAdd(aTotPag,{ (cAliasVEC)->(F2_COND) , If(lDuplic,"E","I")+(cAliasVAI)->(VAI_CC) , left(CTT->CTT_DESC01,14) , nPvalvda , nPtotimp , nPvalicm , 0 , nPvalpis , nPvalcof , nPcustot , nPjurest , nPlucbru , nPdesvar , nPcomven , nPlucliq , nPdesfix , nPdesdep , nPresfin, nVPrzMd1, nVPrzMd2, nPdescon }) 
				EndIf
			Else
			 	aTotPag[nPos,4]  += nPvalvda
			 	aTotPag[nPos,5]  += nPtotimp
			 	aTotPag[nPos,6]  += nPvalicm
			 	aTotPag[nPos,8]  += nPvalpis
			 	aTotPag[nPos,9]  += nPvalcof
			 	aTotPag[nPos,10] += nPcustot
			 	aTotPag[nPos,11] += nPjurest
			 	aTotPag[nPos,12] += nPlucbru
			 	aTotPag[nPos,13] += nPdesvar
			 	aTotPag[nPos,14] += nPcomven
			 	aTotPag[nPos,15] += nPlucliq
			 	aTotPag[nPos,16] += nPdesfix
			 	aTotPag[nPos,17] += nPdesdep
			 	aTotPag[nPos,18] += nPresfin
				// Manoel - 14/03/2005 - Inserir aqui, levantamento do Prazo medio
			 	aTotPag[nPos,19] += nVPrzMd1
			 	aTotPag[nPos,20] += nVPrzMd2
				// Manoel - 18/05/2005 - Inserir aqui, levantamento do % De Desconto
			 	aTotPag[nPos,21] += nPdescon
			EndIf
		EndIf
	EndIf
	(cAliasVEC)->(	DbSkip())
	(cAliasVAI)->(DBCloseArea())
EndDo
(cAliasVEC)->(DBCloseArea())
Return
