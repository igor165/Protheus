#include "totvs.ch"
#Include "OFIOR290.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_VDAPEN   ³ Autor ³ Andre Luis Almeida    ³ Data ³ 14/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ VENDAS  PENDENTES				                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VDAPEN()

Local ni:=0
Local aSM0     := {}

If Select(cAliasVO3) > 0
	( cAliasVO3 )->( DbCloseArea() )
EndIf
cQuery := "SELECT VO3.VO3_DATFEC, VO3.VO3_DATCAN, VO3.VO3_NOSNUM, VO3.VO3_GRUITE, VO3.VO3_CODITE, VO3.VO3_VALPEC, VO3.VO3_QTDREQ, VO3.VO3_FATPAR, VO3.VO3_LOJA, VO3.VO3_NUMNFI, VO3.VO3_SERNFI "
cQuery += "FROM "+RetSqlName( "VO3" ) + " VO3 "
cQuery += "WHERE "
cQuery += "VO3.VO3_FILIAL='"+ xFilial("VO3")+ "' AND "
cQuery += "VO3.VO3_DATFEC='        ' AND "
cQuery += "VO3.VO3_DATCAN='        ' AND "
cQuery += "VO3.D_E_L_E_T_=' ' ORDER BY VO3.VO3_DATFEC, VO3.VO3_TIPTEM"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVO3, .T., .T. )

While !(cAliasVO3)->(Eof())
	nCof := GetMV("MV_TXCOFIN")
	nPis := GetMV("MV_TXPIS")
	cIcm := GetMV("MV_ESTICM")
	cIcm := Alltrim(cIcm)
	aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
	cBkpFil := SM0->(Recno())     
	dbSelectArea("SM0")
	dbSetOrder(1)
	dbSeek(aSM0[1]+aSM0[2])
	For ni:= 1 to len(cIcm)
		If Substr(cIcm,ni,2) == SM0->M0_ESTENT
			nIcm := Val(Substr(cIcm,ni+2,2))
			ni := len(cIcm)
		EndIf
		ni := ni + 3
	Next
	SM0->(DbGoto(cBkpFil))
	If Select(cAliasVO2) > 0
		( cAliasVO2 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT VO2.VO2_DEVOLU, VO2.VO2_DATREQ "
	cQuery += "FROM "+RetSqlName( "VO2" ) + " VO2 "
	cQuery += "WHERE "
	cQuery += "VO2.VO2_FILIAL='"+ xFilial("VO2")+ "' AND "
	cQuery += "VO2.VO2_NOSNUM='"+(cAliasVO3)->VO3_NOSNUM+"' AND "
	cQuery += "VO2.D_E_L_E_T_=' ' ORDER BY VO2.VO2_NOSNUM"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVO2, .T., .T. )
	
	If (cAliasVO2)->VO2_DATREQ > DTOS(MV_PAR02)    // Despresa o registro se a data da requisicao for maior que a data final do parametro.
		DbSelectArea(cAliasVO3)
		Dbskip()
		loop
	EndIf
	
	If Select(cAliasSB1) > 0
		( cAliasSB1 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SB1.B1_COD, SB1.B1_LOCPAD "
	cQuery += "FROM "+RetSqlName( "SB1" ) + " SB1 "
	cQuery += "WHERE "
	cQuery += "SB1.B1_FILIAL='"+ xFilial("SB1")+ "' AND "
	cQuery += "SB1.B1_GRUPO='"+(cAliasVO3)->VO3_GRUITE+"' AND SB1.B1_CODITE='"+(cAliasVO3)->VO3_CODITE+"' AND "
	cQuery += "SB1.D_E_L_E_T_=' ' ORDER BY SB1.B1_GRUPO, SB1.B1_CODITE"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSB1, .T., .T. )
	
	If Select(cAliasSB2) > 0
		( cAliasSB2 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SB2.B2_COD, SB2.B2_CM1, SB2.B2_LOCAL "
	cQuery += "FROM "+RetSqlName( "SB2" ) + " SB2 "
	cQuery += "WHERE "
	cQuery += "SB2.B2_FILIAL='"+ xFilial("SB2")+ "' AND "
	cQuery += "SB2.B2_COD='"+(cAliasSB1)->B1_COD+"' AND SB2.B2_LOCAL='"+(cAliasSB1)->B1_LOCPAD+"' AND "
	cQuery += "SB2.D_E_L_E_T_=' ' ORDER BY SB2.B2_COD, SB2.B2_LOCAL"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSB2, .T., .T. )
	
	nPvalvda := ((cAliasVO3)->VO3_VALPEC - ((nPis + nCof + nIcm)/100) * (cAliasVO3)->VO3_VALPEC)
	nPvalvda := ( nPvalvda * (cAliasVO3)->VO3_QTDREQ )
	nPvalcus := (cAliasSB2)->B2_CM1
	nPvalvda := If((cAliasVO2)->VO2_DEVOLU == "0",((-1)*(nPvalvda)),nPvalvda)
	if (cAliasVO2)->VO2_DEVOLU == "0"
		nPvalcus := ((-1)*(nPvalcus))
	Endif
	If MV_PAR05 == 1
		nPos  := aScan(aNumPen,{|x| x[1] == (cAliasVO3)->VO3_GRUITE })
	Else
		nPos  := aScan(aNumPen,{|x| x[1] == (cAliasVO3)->VO3_FATPAR })
	EndIf
	If nPos == 0
		If MV_PAR05 == 1
			//         DbSelectArea( "SBM" )
			//         DbSetOrder(1)
			//         DbSeek( xFilial("SBM") + (cAliasVO3)->VO3_GRUITE )
			
			If Select(cAliasSBM) > 0
				( cAliasSBM )->( DbCloseArea() )
			EndIf
			cQuery := "SELECT SBM.BM_CODMAR, SBM.BM_TIPGRU, SBM.BM_DESC, SBM.BM_PROORI "
			cQuery += "FROM "+RetSqlName( "SBM" ) + " SBM "
			cQuery += "WHERE "
			cQuery += "SBM.BM_FILIAL='"+ xFilial("SBM")+ "' AND "
			cQuery += "SBM.BM_GRUPO='"+(cAliasVO3)->VO3_GRUITE+"' AND "
			cQuery += "SBM.D_E_L_E_T_=' ' ORDER BY SBM.BM_GRUPO"
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSBM, .T., .T. )
			
			aAdd(aNumPen,{ (cAliasVO3)->VO3_GRUITE , (cAliasSBM)->BM_DESC , nPvalvda , nPvalcus })
		Else
			//         DbSelectArea( "SA1" )
			//         DbSetOrder(1)
			//         DbSeek( xFilial("SA1") + (cAliasVO3)->VO3_FATPAR + (cAliasVO3)->VO3_LOJA )
			
			If Select(cAliasSA1) > 0
				( cAliasSA1 )->( DbCloseArea() )
			EndIf
			cQuery := "SELECT SA1.A1_NOME, SA1.A1_CGC, SA1.A1_SATIV1 "
			cQuery += "FROM "+RetSqlName( "SA1" ) + " SA1 "
			cQuery += "WHERE "
			cQuery += "SA1.A1_FILIAL='"+ xFilial("SA1")+ "' AND "
			cQuery += "SA1.A1_COD='"+(cAliasVO3)->VO3_FATPAR+"' AND SA1.A1_LOJA='"+(cAliasVO3)->VO3_LOJA+"' AND "
			cQuery += "SA1.D_E_L_E_T_=' ' ORDER BY SA1.A1_COD, SA1.A1_LOJA"
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSA1, .T., .T. )
			
			aAdd(aNumPen,{ (cAliasVO3)->VO3_FATPAR , (cAliasSA1)->A1_NOME , nPvalvda , nPvalcus})
			
		EndIf
	Else
		aNumPen[nPos,3] += nPvalvda
		aNumPen[nPos,4] += nPvalcus
	EndIf
	If MV_PAR05 == 2
		nPos1 := aScan(aItePen,{|x| x[1] + x[2] + x[3] == (cAliasVO3)->VO3_FATPAR + (cAliasVO3)->VO3_NUMNFI + (cAliasVO3)->VO3_SERNFI })
		if nPos1 == 0
			aAdd(aItePen,{ (cAliasVO3)->VO3_FATPAR , (cAliasVO3)->VO3_NUMNFI , (cAliasVO3)->VO3_SERNFI , nPvalvda , nPvalcus})
		Else
			aItePen[nPos1,4] += nPvalvda
			aItePen[nPos1,5] += nPvalcus
		Endif
	Endif
	aTotPen[1,1] += nPvalvda
	aTotPen[1,2] += nPvalcus
	DbSelectArea(cAliasVO3)
	Dbskip()
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_COMPRA   ³ Autor ³ Andre Luis Almeida    ³ Data ³ 14/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ COMPRAS       					                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_COMPRA()

nTotCom := 0
nTotCpR := 0
nTotCpO := 0
nTotCpE := 0
aAdd(aGrpCpR,{ "1" , STR0008 , 0 }) // Compras - Rede (Outros Distrib/Concessionarios)
aAdd(aGrpCpR,{ "2" , STR0006 , 0 }) // Compras - Lojas de Pecas
aAdd(aGrpCpR,{ "3" , STR0024 , 0 }) // Compras - Fabricantes


//DbSelectArea("SD1")
//DbSetOrder(6)
//DbSeek( xFilial("SD1") + DTOS(MV_PAR01) , .t. )

If Select(cAliasSD1) > 0
	( cAliasSD1 )->( DbCloseArea() )
EndIf
cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName( "SD1" ) + " SD1 "
cQuery += "WHERE "
cQuery += "SD1.D1_FILIAL='"+ xFilial("SD1")+ "' AND "
cQuery += "SD1.D1_DTDIGIT>='"+DTOS(MV_PAR01)+"' AND SD1.D1_DTDIGIT<='"+DTOS(MV_PAR02)+"' AND "
cQuery += "SD1.D_E_L_E_T_=' ' ORDER BY SD1.D1_DTDIGIT, SD1.D1_NUMSEQ"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSD1, .T., .T. )

SetRegua( ( cAliasSD1 )->(RecCount()) )

Do While !( cAliasSD1 )->(Eof())
	IncRegua()
	If !((cAliasSD1)->D1_TIPO $ "N/C")
		DbSelectArea(cAliasSD1)
		DbSkip()
		Loop
	EndIf
	If (cAliasSD1)->D1_LOCAL # "01"
		DbSelectArea(cAliasSD1)
		DbSkip()
		Loop
	EndIf
	
	//	DbSelectArea("SF4")
	//	DbSetOrder(1)
	//	DbSeek(xFilial("SF4") + (cAliasSD1)->D1_TES )
	
	If Select(cAliasSF4) > 0
		( cAliasSF4 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SF4.F4_DUPLIC, SF4.F4_ESTOQUE, SF4.F4_OPEMOV, SF4.F4_PISCRED, SF4.F4_PISCOF "
	cQuery += "FROM "+RetSqlName( "SF4" ) + " SF4 "
	cQuery += "WHERE "
	cQuery += "SF4.F4_FILIAL='"+ xFilial("SF4")+ "' AND "
	cQuery += "SF4.F4_CODIGO='"+(cAliasSD1)->D1_TES+"' AND "
	cQuery += "SF4.D_E_L_E_T_=' ' ORDER BY SF4.F4_CODIGO"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSF4, .T., .T. )
	
	If (cAliasSF4)->F4_ESTOQUE # "S" .or. !((cAliasSF4)->F4_OPEMOV $ "01/08")
		DbSelectArea(cAliasSD1)
		DbSkip()
		Loop
	EndIf
	
	/*   DbSelectArea( "SBM" )
	DbSetOrder(1)
	DbSeek( xFilial("SBM") + (cAliasSD1)->D1_GRUPO )
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek( xFilial("SB1") + (cAliasSD1)->D1_COD )
	DbSelectArea( "SA2" )
	DbSetOrder(1)
	DbSeek( xFilial("SA2") + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA )
	*/
	If Select(cAliasSBM) > 0
		( cAliasSBM )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SBM.BM_CODMAR, SBM.BM_TIPGRU, SBM.BM_DESC, SBM.BM_PROORI "
	cQuery += "FROM "+RetSqlName( "SBM" ) + " SBM "
	cQuery += "WHERE "
	cQuery += "SBM.BM_FILIAL='"+ xFilial("SBM")+ "' AND SBM.BM_GRUPO='"+(cAliasSD1)->D1_GRUPO+"' AND "
	cQuery += "SBM.D_E_L_E_T_=' ' ORDER BY SBM.BM_GRUPO"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSBM, .T., .T. )
	
	If Select(cAliasSB1) > 0
		( cAliasSB1 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SB1.B1_GRUPO, SB1.B1_COD, SB1.B1_ORIGEM, SB1.B1_LOCPAD "
	cQuery += "FROM "+RetSqlName( "SB1" ) + " SB1 "
	cQuery += "WHERE "
	cQuery += "SB1.B1_FILIAL='"+ xFilial("SB1")+ "' AND SB1.B1_COD='"+(cAliasSD1)->D1_COD+"' AND "
	cQuery += "SB1.D_E_L_E_T_=' ' ORDER BY SB1.B1_COD"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSB1, .T., .T. )
	
	If Select(cAliasSA2) > 0
		( cAliasSA2 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SA2.A2_NOME, SA2.A2_SATIV1 "
	cQuery += "FROM "+RetSqlName( "SA2" ) + " SA2 "
	cQuery += "WHERE "
	cQuery += "SA2.A2_FILIAL='"+ xFilial("SA2")+ "' AND SA2.A2_COD='"+(cAliasSD1)->D1_FORNECE+"' AND SA2.A2_LOJA='"+(cAliasSD1)->D1_LOJA+"' AND "
	cQuery += "SA2.D_E_L_E_T_=' ' ORDER BY SA2.A2_COD, SA2.A2_LOJA"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSA2, .T., .T. )
	
	///////////////////////
	//  OUTRAS  COMPRAS  //
	///////////////////////
	
	If str(val((cAliasSBM)->BM_TIPGRU),2) $ " 2| 3| 9|10"
		nPos := 0
		If MV_PAR05 == 1
			nPos  := aScan(aNumCpO,{|x| x[1] == (cAliasSD1)->D1_GRUPO })
		Else
			nPos  := aScan(aNumCpO,{|x| x[1] == (cAliasSD1)->D1_FORNECE })
		EndIf
		If nPos == 0
			If MV_PAR05 == 1
				aAdd(aNumCpO,{ (cAliasSD1)->D1_GRUPO , (cAliasSBM)->BM_DESC , (cAliasSD1)->D1_CUSTO})
			Else
				aAdd(aNumCpO,{ (cAliasSD1)->D1_FORNECE , (cAliasSA2)->A2_NOME , (cAliasSD1)->D1_CUSTO })
			EndIf
		Else
			aNumCpO[nPos,3] += (cAliasSD1)->D1_CUSTO
		EndIf
		
		If MV_PAR05 == 2
			nPos1 := aScan(aIteCpO,{|x| x[1] + x[2] + x[3] == (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE })
			if nPos1 == 0
				aAdd(aIteCpO,{ (cAliasSD1)->D1_FORNECE , (cAliasSD1)->D1_DOC , (cAliasSD1)->D1_SERIE , (cAliasSD1)->D1_CUSTO })
			Else
				aIteCpO[nPos1,4] += (cAliasSD1)->D1_CUSTO
			Endif
		EndIf
		nTotCom += (cAliasSD1)->D1_CUSTO
		nTotCpO += (cAliasSD1)->D1_CUSTO
		
	Else
		
		///////////////////////
		// REDE & ACESSORIOS //
		///////////////////////
		
		//		DbSelectArea("VE4")
		//		DbSetOrder(1)
		//		DbSeek( xFilial("VE4") + (cAliasSBM)->BM_CODMAR )
		
		If Select(cAliasVE4) > 0
			( cAliasVE4 )->( DbCloseArea() )
		EndIf
		cQuery := "SELECT VE4.VE4_CDOPSA, VE4.VE4_CODFOR, VE4.VE4_LOJFOR, VE4.VE4_CDOPEN "
		cQuery += "FROM "+RetSqlName( "VE4" ) + " VE4 "
		cQuery += "WHERE "
		cQuery += "VE4.VE4_FILIAL='"+ xFilial("VE4")+ "' AND VE4.VE4_PREFAB='"+(cAliasSBM)->BM_CODMAR+"' AND "
		cQuery += "VE4.D_E_L_E_T_=' ' ORDER BY VE4.VE4_PREFAB"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVE4, .T., .T. )
		
		cDCli := "S"
		If Alltrim((cAliasSBM)->BM_TIPGRU) # "8" .Or. (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA == (cAliasVE4)->VE4_CODFOR + (cAliasVE4)->VE4_LOJFOR
			nPos := 0
			nPos := aScan(aChave06,{|x| x[1] == (cAliasSA2)->A2_SATIV1 }) //Rede (Outros Distrib/Concessionarios)
			If nPos > 0
				cDCli := "N"
				nTotCom += (cAliasSD1)->D1_CUSTO
				nTotCpR += (cAliasSD1)->D1_CUSTO
				aGrpCpR[1,3] += (cAliasSD1)->D1_CUSTO
				If MV_PAR05 == 1
					nPos  := aScan(aNumCpR,{|x| x[1] + x[2] == "1" + (cAliasSD1)->D1_GRUPO })
				Else
					nPos  := aScan(aNumCpR,{|x| x[1] + x[2] == "1" + (cAliasSD1)->D1_FORNECE })
				Endif
				If nPos == 0
					If MV_PAR05 == 1
						aAdd(aNumCpR,{ "1" , (cAliasSD1)->D1_GRUPO , (cAliasSBM)->BM_DESC , (cAliasSD1)->D1_CUSTO })
					Else
						aAdd(aNumCpR,{ "1" , (cAliasSD1)->D1_FORNECE , (cAliasSA2)->A2_NOME , (cAliasSD1)->D1_CUSTO })
					EndIf
				Else
					aNumCpR[nPos,4] += (cAliasSD1)->D1_CUSTO
				EndIf
				If MV_PAR05 == 2
					nPos1 := aScan(aIteCpR,{|x| x[1] + x[2] + x[3] + x[4] == "1" + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE })
					if nPos1 == 0
						aAdd(aIteCpR,{ "1" , (cAliasSD1)->D1_FORNECE , (cAliasSD1)->D1_DOC , (cAliasSD1)->D1_SERIE , (cAliasSD1)->D1_CUSTO })
					Else
						aIteCpR[nPos1,5] += (cAliasSD1)->D1_CUSTO
					Endif
				Endif
			EndIf
			nPos := 0
			nPos := aScan(aChave04,{|x| x[1] == (cAliasSA2)->A2_SATIV1 }) //Lojas de Pecas
			If nPos > 0
				cDCli := "N"
				nTotCom += (cAliasSD1)->D1_CUSTO
				nTotCpR += (cAliasSD1)->D1_CUSTO
				aGrpCpR[2,3] += (cAliasSD1)->D1_CUSTO
				If MV_PAR05 == 1
					nPos := aScan(aNumCpR,{|x| x[1] + x[2] == "2" + (cAliasSD1)->D1_GRUPO })
				Else
					nPos := aScan(aNumCpR,{|x| x[1] + x[2] == "2" + (cAliasSD1)->D1_FORNECE })
				EndIf
				If nPos == 0
					If MV_PAR05 == 1
						aAdd(aNumCpR,{ "2" , (cAliasSD1)->D1_GRUPO , (cAliasSBM)->BM_DESC , (cAliasSD1)->D1_CUSTO })
					Else
						aAdd(aNumCpR,{ "2" , (cAliasSD1)->D1_FORNECE , (cAliasSA2)->A2_NOME , (cAliasSD1)->D1_CUSTO})
					EndIf
				Else
					aNumCpR[nPos,4] += (cAliasSD1)->D1_CUSTO
				EndIf
				If MV_PAR05 == 2
					nPos1 := aScan(aIteCpR,{|x| x[1] + x[2] + x[3] + x[4] == "2" + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE })
					if nPos1 == 0
						aAdd(aIteCpR,{ "2" , (cAliasSD1)->D1_FORNECE , (cAliasSD1)->D1_DOC , (cAliasSD1)->D1_SERIE , (cAliasSD1)->D1_CUSTO })
					Else
						aIteCpR[nPos1,5] += (cAliasSD1)->D1_CUSTO
					Endif
				Endif
			EndIf
			nPos := 0
			nPos := aScan(aChave07,{|x| x[1] == (cAliasSA2)->A2_SATIV1 }) //Fabricantes
			If nPos > 0
				cDCli := "N"
				nTotCom += (cAliasSD1)->D1_CUSTO
				nTotCpR += (cAliasSD1)->D1_CUSTO
				aGrpCpR[3,3] += (cAliasSD1)->D1_CUSTO
				If MV_PAR05 == 1
					nPos := aScan(aNumCpR,{|x| x[1] + x[2] == "3" + (cAliasSD1)->D1_GRUPO })
				Else
					nPos := aScan(aNumCpR,{|x| x[1] + x[2] == "3" + (cAliasSD1)->D1_FORNECE })
				EndIf
				If nPos == 0
					If MV_PAR05 == 1
						aAdd(aNumCpR,{ "3" , (cAliasSD1)->D1_GRUPO , (cAliasSBM)->BM_DESC , (cAliasSD1)->D1_CUSTO })
					Else
						aAdd(aNumCpR,{ "3" , (cAliasSD1)->D1_FORNECE , (cAliasSA2)->A2_NOME , (cAliasSD1)->D1_CUSTO })
					EndIf
				Else
					aNumCpR[nPos,4] += (cAliasSD1)->D1_CUSTO
				EndIf
				If MV_PAR05 == 2
					nPos1 := aScan(aIteCpR,{|x| x[1] + x[2] + x[3] + x[4] == "3" + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE })
					if nPos1 == 0
						aAdd(aIteCpR,{ "3" , (cAliasSD1)->D1_FORNECE , (cAliasSD1)->D1_DOC , (cAliasSD1)->D1_SERIE , (cAliasSD1)->D1_CUSTO })
					Else
						aIteCpR[nPos1,5] += (cAliasSD1)->D1_CUSTO
					Endif
				EndIf
			EndIf
		EndIf
		
		///////////////////////
		//COMPRAS ESPECIFICAS//
		///////////////////////
		
		If cDCli == "S" .and. (cAliasSD1)->D1_GRUPO # "VEI "
			nTotCom += (cAliasSD1)->D1_CUSTO
			nTotCpE += (cAliasSD1)->D1_CUSTO
			nPos := 0
			If MV_PAR05 == 1
				nPos := aScan(aNumCpE,{|x| x[1] == (cAliasSD1)->D1_GRUPO })
			Else
				nPos := aScan(aNumCpE,{|x| x[1] == (cAliasSD1)->D1_FORNECE })
			EndIf
			If nPos == 0
				If MV_PAR05 == 1
					aAdd(aNumCpE,{ (cAliasSD1)->D1_GRUPO , (cAliasSBM)->BM_DESC , (cAliasSD1)->D1_CUSTO })
				Else
					aAdd(aNumCpE,{ (cAliasSD1)->D1_FORNECE , (cAliasSA2)->A2_NOME , (cAliasSD1)->D1_CUSTO })
				EndIf
			Else
				aNumCpE[nPos,3] += (cAliasSD1)->D1_CUSTO
			EndIf
			If MV_PAR05 == 2
				nPos1 := aScan(aIteCpE,{|x| x[1] + x[2] + x[3] == (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE })
				if nPos1 == 0
					aAdd(aIteCpE,{ (cAliasSD1)->D1_FORNECE , (cAliasSD1)->D1_DOC , (cAliasSD1)->D1_SERIE , (cAliasSD1)->D1_CUSTO })
				Else
					aIteCpE[nPos1,4] += (cAliasSD1)->D1_CUSTO
				Endif
			Endif
		EndIf
		
		
	EndIf
	DbSelectArea(cAliasSD1)
	Dbskip()
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_VEICUL   ³ Autor ³ Andre Luis Almeida    ³ Data ³ 14/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ PASSAGEM VEICULOS				                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FS_VEICUL()

nTotPas := 0
If MV_PAR16 == 1 // por Data de Abertura
	nTotPas := FG_CALTEM(,MV_PAR01,"F",MV_PAR02,,"G",   ,,"A")
Else // por Data de Fechamento
	nTotPas := FG_CALTEM(,MV_PAR01,"F",MV_PAR02,,"G",   ,,"F")
EndIf

///////////////////////
// VENDAS   VEICULOS //
///////////////////////
nTotVei := 0

cQuery := "SELECT DISTINCT VV0.VV0_DATMOV, VV0.VV0_NUMTRA "
cQuery += "FROM " + RetSqlName( "VV0" ) + " VV0 "
cQuery += "INNER JOIN " + RetSqlName( "VVA" ) + " VVA ON VVA_NUMTRA = VV0_NUMTRA "
cQuery += "INNER JOIN " + RetSqlName( "SF4" ) + " SF4 ON VVA_CODTES = F4_CODIGO "
cQuery += "WHERE "
cQuery += "VV0.VV0_FILIAL='" + xFilial("VV0") + "' AND "  
cQuery += "VVA.VVA_FILIAL='" + xFilial("VVA") + "' AND "
cQuery += "SF4.F4_FILIAL= '" + xFilial("SF4") + "' AND "
cQuery += "SF4.F4_OPEMOV = '05' AND "
If !Empty(MV_PAR01)
	cQuery += "VV0.VV0_DATMOV >= '" + Dtos(MV_PAR01) + "' AND "
EndIf
If !Empty(MV_PAR02)
	cQuery += "VV0.VV0_DATMOV <= '" + Dtos(MV_PAR02) +"' AND "
EndIf
cQuery += "VV0.VV0_SITNFI='1' AND "
cQuery += "VV0.D_E_L_E_T_=' ' AND "
cQuery += "VVA.D_E_L_E_T_=' ' AND "
cQuery += "SF4.D_E_L_E_T_=' ' ORDER BY VV0.VV0_DATMOV"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVV0, .T., .T. )

While !(cAliasVV0)->(Eof())
	
	If Select(cAliasVV1) > 0
		( cAliasVV1 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT VV1.VV1_CODMAR, VV1.VV1_ESTVEI, VV1.VV1_MODVEI "
	cQuery += "FROM "+RetSqlName( "VV1" ) + " VV1 "
	cQuery += "WHERE "
	cQuery += "VV1.VV1_FILIAL='"+ xFilial("VV1")+ "' AND VV1.VV1_NUMTRA='"+(cAliasVV0)->VV0_NUMTRA+"' AND "
	cQuery += "VV1.D_E_L_E_T_=' ' ORDER BY VV1.VV1_NUMTRA"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVV1, .T., .T. )
	
	If (cAliasVV1)->VV1_CODMAR != MV_PAR17
		DbSelectArea(cAliasVV0)
		Dbskip()
		loop
	EndIf
	If (cAliasVV1)->VV1_ESTVEI == "0"
		nTotVei++
		nPos := 0
		nPos := aScan(aNumVei,{|x| x[1] == (cAliasVV1)->VV1_CODMAR + " " + (cAliasVV1)->VV1_MODVEI })
		If nPos == 0
			aAdd(aNumVei,{ (cAliasVV1)->VV1_CODMAR + " " + (cAliasVV1)->VV1_MODVEI , 1 })
		Else
			aNumVei[nPos,2]++
		EndIf
	EndIF
	DbSelectArea(cAliasVV0)
	Dbskip()
EndDo

Return