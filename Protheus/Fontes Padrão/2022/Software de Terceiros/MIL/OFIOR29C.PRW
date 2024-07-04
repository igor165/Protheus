#Include "OFIOR290.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_ESTOQU   ³ Autor ³ Andre Luis Almeida    ³ Data ³ 14/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ ESTOQUE PEC/ACE/OUT				                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION FS_ESTOQU()

aAdd(aTotOri,{ 0 , 0 })
aAdd(aTotNOri,{ 0 , 0 })
If MV_PAR13 == 2 .and. cEstoque == "SIM"
	//   DbSelectArea( "SB2" )
	//   DbSetOrder(1)
	//   DbSeek( xFilial("SB2") )
	
	If Select(cAliasSB2) > 0
		( cAliasSB2 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SB2.B2_COD, SB2.B2_CM1, SB2.B2_LOCAL "
	cQuery += "FROM "+RetSqlName( "SB2" ) + " SB2 "
	cQuery += "WHERE "
	cQuery += "SB2.B2_FILIAL='"+ xFilial("SB2")+ "' AND "
	cQuery += "SB2.D_E_L_E_T_=' ' ORDER BY SB2.B2_COD, SB2.B2_LOCAL"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSB2, .T., .T. )
	
	dDatEst := MV_PAR14
	dDatOri := MV_PAR14
	aAdd(aGrpEst,{ "A" , STR0033 + "(" + Transform(dDatEst,"@D") + ")............ " , 0 , 0 })
	aAdd(aGrpEst,{ "O" , STR0034 + "(" + Transform(dDatEst,"@D") + ")........................ " , 0 , 0 })
	aAdd(aTotOri,{ 0 , 0 })
	aAdd(aTotNOri,{ 0 , 0 })
	While !(cAliasSB2)->(Eof())
		
		//      DbSelectArea( "SB1" )
		//      DbSetOrder(1)
		//      DbSeek( xFilial("SB1") + (cAliasSB2)->B2_COD , .f. )
		//      DbSelectArea( "SBM" )
		//      DbSetOrder(1)
		//      DbSeek( xFilial("SBM") + SB1->B1_GRUPO , .f. )
		
		If Select(cAliasSB1) > 0
			( cAliasSB1 )->( DbCloseArea() )
		EndIf
		cQuery := "SELECT SB1.B1_COD, SB1.B1_LOCPAD, SB1.B1_GRUPO, SB1.B1_CODITE, SB1.B1_ORIGEM "
		cQuery += "FROM "+RetSqlName( "SB1" ) + " SB1 "
		cQuery += "WHERE "
		cQuery += "SB1.B1_FILIAL='"+ xFilial("SB1")+ "' AND "
		cQuery += "SB1.B1_COD='"+(cAliasSB2)->B2_COD+"' AND "
		cQuery += "SB1.D_E_L_E_T_=' ' ORDER BY SB1.B1_COD"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSB1, .T., .T. )
		
		If Select(cAliasSBM) > 0
			( cAliasSBM )->( DbCloseArea() )
		EndIf
		cQuery := "SELECT SBM.BM_CODMAR, SBM.BM_TIPGRU, SBM.BM_DESC, SBM.BM_PROORI "
		cQuery += "FROM "+RetSqlName( "SBM" ) + " SBM "
		cQuery += "WHERE "
		cQuery += "SBM.BM_FILIAL='"+ xFilial("SBM")+ "' AND "
		cQuery += "SBM.BM_GRUPO='"+(cAliasSB1)->B1_GRUPO+"' AND "
		cQuery += "SBM.D_E_L_E_T_=' ' ORDER BY SBM.BM_GRUPO"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSBM, .T., .T. )
		
		If (str(val((cAliasSBM)->BM_TIPGRU),2) $ " 4| 7| 0")
			DbSelectArea(cAliasSB2)
			Dbskip()
			loop
		EndIf
		If (cAliasSBM)->BM_PROORI == "1"
			//////////thiago//////////////////////////
			//         nQtdEst := CalcEst((cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,dDatOri)[1]
			//         nValEst := (nQtdEst * FG_VALPEC(,"MV_PAR15",(cAliasSB1)->B1_GRUPO,(cAliasSB1)->B1_CODITE,,.F.,.T.)) // ????
			nQtdEst := CalcEst((cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,dDatEst)[1]
			nValEst := CalcEst((cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,dDatEst)[2]
			aTotOri[1,1] += nQtdEst
			aTotOri[1,2] += nValEst
			nPos := 0
			nPos := aScan(aPecOri,{|x| x[1] == (cAliasSB1)->B1_GRUPO + " " + (cAliasSBM)->BM_DESC })
			If nPos == 0
				aAdd(aPecOri,{ (cAliasSB1)->B1_GRUPO + " " + (cAliasSBM)->BM_DESC , nQtdEst , nValEst })
			Else
				aPecOri[nPos,2] += nQtdEst
				aPecOri[nPos,3] += nValEst
			EndIf
		Else
			/////////////////////thiago//////////////////////////////
			//         nQtdEst := CalcEst((cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,dDatOri)[1]
			//         nValEst := (nQtdEst * FG_VALPEC(,"MV_PAR15",(cAliasSB1)->B1_GRUPO,(cAliasSB1)->B1_CODITE,,.F.,.T.))
			nQtdEst := CalcEst((cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,dDatEst)[1]
			nValEst := CalcEst((cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,dDatEst)[2]
			aTotNOri[1,1] += nQtdEst
			aTotNOri[1,2] += nValEst
			nPos := 0
			nPos := aScan(aPecNOri,{|x| x[1] == (cAliasSB1)->B1_GRUPO + " " + (cAliasSBM)->BM_DESC })
			If nPos == 0
				aAdd(aPecNOri,{ (cAliasSB1)->B1_GRUPO + " " + (cAliasSBM)->BM_DESC , nQtdEst , nValEst })
			Else
				aPecNOri[nPos,2] += nQtdEst
				aPecNOri[nPos,3] += nValEst
			EndIf
		EndIf
		If str(val((cAliasSBM)->BM_TIPGRU),2) $ " 2| 3| 9|10"
			///////////////////////////////////thiago//////////////////////////////////////////////
			//         nQtdEst := CalcEst((cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,dDatEst)[1]
			//         nValEst := (nQtdEst * FG_VALPEC(,"MV_PAR15",(cAliasSB1)->B1_GRUPO,(cAliasSB1)->B1_CODITE,,.F.,.T.))
			nQtdEst := CalcEst((cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,dDatEst)[1]
			nValEst := CalcEst((cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,dDatEst)[2]
			aGrpEst[2,3] += nQtdEst
			aGrpEst[2,4] += nValEst
			nPos := 0
			nPos := aScan(aNumEst,{|x| x[1] == "O" + (cAliasSB1)->B1_GRUPO + " " + (cAliasSBM)->BM_DESC })
			If nPos == 0
				aAdd(aNumEst,{ "O" + (cAliasSB1)->B1_GRUPO + " " + (cAliasSBM)->BM_DESC , nQtdEst , nValEst })
			Else
				aNumEst[nPos,2] += nQtdEst
				aNumEst[nPos,3] += nValEst
			EndIf
		Else
			
			/*
			// 1a FORMA - USANDO A FG_VALPEC - funcao que usa sempre o B1_LOCAL, ou seja, LOCAL 01
			nSavRecB2 := (cAliasSB2)->(RECNO())
			nQtdEst := CalcEst((cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,dDatEst)[1]
			nValEst := (nQtdEst * FG_VALPEC(,"MV_PAR15",(cAliasSB1)->B1_GRUPO,(cAliasSB1)->B1_CODITE,,.F.,.T.))
			(cAliasSB2)->(dbgoto(nSavRecB2))
			*/
			/////////////////thiago///////////////////////////////////
			nQtdEst := CalcEst((cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,dDatEst)[1]
			nValEst := CalcEst((cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,dDatEst)[2]
			//       nQtdEst := CalcEst((cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,dDatEst)[1]
			//         nValEst := (nQtdEst * FG_VALPEC(,"MV_PAR15",(cAliasSB1)->B1_GRUPO,(cAliasSB1)->B1_CODITE,,.F.,.T.))
			aGrpEst[1,3] += nQtdEst
			aGrpEst[1,4] += nValEst
			nPos := 0
			nPos := aScan(aNumEst,{|x| x[1] == "A" + (cAliasSB1)->B1_GRUPO + " " + (cAliasSBM)->BM_DESC })
			If nPos == 0
				aAdd(aNumEst,{ "A" + (cAliasSB1)->B1_GRUPO + " " + (cAliasSBM)->BM_DESC , nQtdEst , nValEst })
			Else
				aNumEst[nPos,2] += nQtdEst
				aNumEst[nPos,3] += nValEst
			EndIf
		EndIf
		DbSelectArea(cAliasSB2)
		Dbskip()
	EndDo
EndIf

aAdd(aGrpTransf,{ "TOT" , "" , 0 , 0 })
aAdd(aGrpTransf,{ "ACE" , STR0042 , 0 , 0 })
aAdd(aGrpTransf,{ "OUT" , STR0043 , 0 , 0 })

///////////////////////
// TRANSF.  ENTRADAS //
///////////////////////
//DbSelectArea( "SD1" )
//DbSetOrder(6)
//DbSeek( xFilial("SD1") + Dtos(MV_PAR01) , .t. )

If Select(cAliasSD1) > 0
	( cAliasSD1 )->( DbCloseArea() )
EndIf
cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName( "SD1" ) + " SD1 "
cQuery += "WHERE "
cQuery += "SD1.D1_FILIAL='"+ xFilial("SD1")+ "' AND "
If !Empty(MV_PAR01)
	cQuery += "SD1.D1_DTDIGIT>='"+DTOS(MV_PAR01)+"' AND "
EndIf
If !Empty(MV_PAR02)
	cQuery += "SD1.D1_DTDIGIT<='"+DTOS(MV_PAR02)+"' AND "
EndIf
cQuery += "SD1.D_E_L_E_T_=' ' ORDER BY SD1.D1_DTDIGIT, SD1.D1_NUMSEQ"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSD1, .T., .T. )

While !(cAliasSD1)->(Eof())
	
	If Select(cAliasSBM) > 0
		( cAliasSBM )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SBM.BM_CODMAR, SBM.BM_TIPGRU, SBM.BM_DESC, SBM.BM_PROORI "
	cQuery += "FROM "+RetSqlName( "SBM" ) + " SBM "
	cQuery += "WHERE "
	cQuery += "SBM.BM_FILIAL='"+ xFilial("SBM")+ "' AND "
	cQuery += "SBM.BM_GRUPO='"+(cAliasSD1)->D1_GRUPO+"' AND "
	cQuery += "SBM.D_E_L_E_T_=' ' ORDER BY SBM.BM_GRUPO"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSBM, .T., .T. )
	
	If Select(cAliasVE4) > 0
		( cAliasVE4 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT VE4.VE4_CDOPSA, VE4.VE4_CODFOR, VE4.VE4_LOJFOR, VE4.VE4_CDOPEN "
	cQuery += "FROM "+RetSqlName( "VE4" ) + " VE4 "
	cQuery += "WHERE "
	cQuery += "VE4.VE4_FILIAL='"+ xFilial("VE4")+ "' AND VE4.VE4_PREFAB='"+(cAliasSBM)->BM_CODMAR+"' AND "
	cQuery += "VE4.D_E_L_E_T_=' ' ORDER BY VE4.VE4_PREFAB"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVE4, .T., .T. )
	
	If Select(cAliasSB1) > 0
		( cAliasSB1 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SB1.B1_COD, SB1.B1_LOCPAD, SB1.B1_GRUPO, SB1.B1_CODITE, SB1.B1_ORIGEM "
	cQuery += "FROM "+RetSqlName( "SB1" ) + " SB1 "
	cQuery += "WHERE "
	cQuery += "SB1.B1_FILIAL='"+ xFilial("SB1")+ "' AND "
	cQuery += "SB1.B1_COD='"+(cAliasSD1)->D1_COD+"' AND "
	cQuery += "SB1.D_E_L_E_T_=' ' ORDER BY SB1.B1_COD"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSB1, .T., .T. )
	
	If ( !((cAliasSD1)->D1_CF $ "122 |222 ") .Or. ( (cAliasVE4)->VE4_PREFAB == (cAliasSBM)->BM_CODMAR .And. (cAliasSD1)->D1_TES == FG_TABTRIB((cAliasVE4)->VE4_CDOPEN,(cAliasSB1)->B1_ORIGEM) ) )
		DbSelectArea(cAliasSD1)
		Dbskip()
		loop
	EndIf
	If str(val((cAliasSBM)->BM_TIPGRU),2) $ " 2| 3| 9|10"
		nPos := 0
		nPos := aScan(aNumTransf,{|x| x[1] + x[2] == "ACE" + (cAliasSD1)->D1_GRUPO })
		If nPos == 0
			aAdd(aNumTransf,{ "ACE" , (cAliasSD1)->D1_GRUPO , (cAliasSBM)->BM_DESC , (cAliasSD1)->D1_CUSTO , 0 })
		Else
			aNumTransf[nPos,4] += (cAliasSD1)->D1_CUSTO
		EndIf
		aGrpTransf[1,3] += (cAliasSD1)->D1_CUSTO
		aGrpTransf[2,3] += (cAliasSD1)->D1_CUSTO
	Else
		nPos := 0
		nPos := aScan(aNumTransf,{|x| x[1] + x[2] == "OUT" + (cAliasSD1)->D1_GRUPO })
		If nPos == 0
			aAdd(aNumTransf,{ "OUT" , (cAliasSD1)->D1_GRUPO , (cAliasSBM)->BM_DESC , (cAliasSD1)->D1_CUSTO , 0 })
		Else
			aNumTransf[nPos,4] += (cAliasSD1)->D1_CUSTO
		EndIf
		aGrpTransf[1,3] += (cAliasSD1)->D1_CUSTO
		aGrpTransf[3,3] += (cAliasSD1)->D1_CUSTO
	EndIf
	DbSelectArea(cAliasSD1)
	Dbskip()
EndDo

///////////////////////
//  TRANSF.  SAIDAS  //
///////////////////////

//DbSelectArea( "SD2" )
//DbSetOrder(5)
//DbSeek( xFilial("SD2") + Dtos(MV_PAR01) , .t. )

If Select(cAliasSD2) > 0
	( cAliasSD2 )->( DbCloseArea() )
EndIf
cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName( "SD2" ) + " SD2 "
cQuery += "WHERE "
cQuery += "SD2.D2_FILIAL='"+ xFilial("SD2")+ "' AND "
If !Empty(MV_PAR01)
	cQuery += "SD2.D2_EMISSAO>='"+DTOS(MV_PAR01)+"' AND "
EndIf
If !Empty(MV_PAR02)
	cQuery += "SD2.D2_EMISSAO<='"+DTOS(MV_PAR02)+"' AND "
EndIf
cQuery += "SD2.D_E_L_E_T_=' ' ORDER BY SD2.D2_EMISSAO, SD2.D2_NUMSEQ"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSD2, .T., .T. )

While !(cAliasSD2)->(Eof())
	
	If Select(cAliasSBM) > 0
		( cAliasSBM )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SBM.BM_CODMAR, SBM.BM_TIPGRU, SBM.BM_DESC, SBM.BM_PROORI "
	cQuery += "FROM "+RetSqlName( "SBM" ) + " SBM "
	cQuery += "WHERE "
	cQuery += "SBM.BM_FILIAL='"+ xFilial("SBM")+ "' AND "
	cQuery += "SBM.BM_GRUPO='"+(cAliasSD2)->D2_GRUPO+"' AND "
	cQuery += "SBM.D_E_L_E_T_=' ' ORDER BY SBM.BM_GRUPO"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSBM, .T., .T. )
	
	If Select(cAliasVE4) > 0
		( cAliasVE4 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT VE4.VE4_CDOPSA, VE4.VE4_CODFOR, VE4.VE4_LOJFOR, VE4.VE4_CDOPEN "
	cQuery += "FROM "+RetSqlName( "VE4" ) + " VE4 "
	cQuery += "WHERE "
	cQuery += "VE4.VE4_FILIAL='"+ xFilial("VE4")+ "' AND VE4.VE4_PREFAB='"+(cAliasSBM)->BM_CODMAR+"' AND "
	cQuery += "VE4.D_E_L_E_T_=' ' ORDER BY VE4.VE4_PREFAB"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVE4, .T., .T. )
	
	If Select(cAliasSB1) > 0
		( cAliasSB1 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SB1.B1_COD, SB1.B1_LOCPAD, SB1.B1_GRUPO, SB1.B1_CODITE, SB1.B1_ORIGEM "
	cQuery += "FROM "+RetSqlName( "SB1" ) + " SB1 "
	cQuery += "WHERE "
	cQuery += "SB1.B1_FILIAL='"+ xFilial("SB1")+ "' AND "
	cQuery += "SB1.B1_COD='"+(cAliasSD2)->D2_COD+"' AND "
	cQuery += "SB1.D_E_L_E_T_=' ' ORDER BY SB1.B1_COD"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSB1, .T., .T. )
	
	If ( !((cAliasSD2)->D2_CF $ "522 |622 ") .Or. ( (cAliasVE4)->VE4_PREFAB == (cAliasSBM)->BM_CODMAR .And. (cAliasSD2)->D2_TES == FG_TABTRIB((cAliasVE4)->VE4_CDOPSA,(cAliasSB1)->B1_ORIGEM) ) )
		DbSelectArea(cAliasSD2)
		Dbskip()
		loop
	EndIf
	If str(val((cAliasSBM)->BM_TIPGRU),2) $ " 2| 3| 9|10"
		nPos := 0
		nPos := aScan(aNumTransf,{|x| x[1] + x[2] == "ACE" + (cAliasSD2)->D2_GRUPO })
		If nPos == 0
			aAdd(aNumTransf,{ "ACE" , (cAliasSD2)->D2_GRUPO , (cAliasSBM)->BM_DESC , 0 , (cAliasSD2)->D2_TOTAL })
		Else
			aNumTransf[nPos,5] += (cAliasSD2)->D2_TOTAL
		EndIf
		aGrpTransf[1,4] += (cAliasSD2)->D2_TOTAL
		aGrpTransf[2,4] += (cAliasSD2)->D2_TOTAL
	Else
		nPos := 0
		nPos := aScan(aNumTransf,{|x| x[1] + x[2] == "OUT" + (cAliasSD2)->D2_GRUPO })
		If nPos == 0
			aAdd(aNumTransf,{ "OUT" , (cAliasSD2)->D2_GRUPO , (cAliasSBM)->BM_DESC , 0 , (cAliasSD2)->D2_TOTAL })
		Else
			aNumTransf[nPos,5] += (cAliasSD2)->D2_TOTAL
		EndIf
		aGrpTransf[1,4] += (cAliasSD2)->D2_TOTAL
		aGrpTransf[3,4] += (cAliasSD2)->D2_TOTAL
	EndIf
	DbSelectArea(cAliasSD2)
	DbSkip()
EndDo

return
