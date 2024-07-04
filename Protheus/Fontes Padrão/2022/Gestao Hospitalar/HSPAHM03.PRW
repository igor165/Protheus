#INCLUDE "HSPAHM03.ch"
#INCLUDE "protheus.CH"
#INCLUDE "TopConn.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM03  บ Autor ณ Jose Orfeu         บ Data ณ  15/03/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็๕es de tratamento e montagem de browse (GetDados)      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ฑฑบParametros obsoletos aHPesq e aCPesq 21/12/2006                        บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_GDPesqu(aHPesq, aCPesq, oGDPesq, oDlgUse, nPosUse, lAlinhaH, nIndIni, lFiltra, cFiltro)
 Local aArea   := getArea()
 Local nCpoF   := 1, aIPesq := {}
 Local nPosIni := 11, oDlgP, oCpoP, nCpoS := "XX", oChvP, cChvP := ""
 Local cPict   := "@!", cAliasOld := Alias()

 Default lAlinhaH := .F.

 Default nIndIni  := 1

 Default lFiltra  := .F.
 Default cFiltro  := ""

 oDlgP   := IIF(oDlgUse <> Nil, oDlgUse, oDlgP)
 nPosIni := IIF(nPosUse <> Nil, nPosUse, nPosIni)

 DbSelectArea("SX3")
 DbSetOrder(2) // X3_CAMPO

 For nCpoF := 1 To Len(oGDPesq:aHeader)
	If !(oGDPesq:aHeader[nCpoF][8] $ "NM") .And. oGDPesq:aHeader[nCpoF][3] # "@BMP"
		If nCpoS == "XX"
			nCpoS := StrZero(nCpoF, 2)
		EndIf

		If FunName() == "HSPAHM38"// .AND. oGDPesq <> "oGCZ"
			aAdd(aIPesq, StrZero(nCpoF, 2) + "=" + oGDPesq:aHeader[nCpoF][1])
		Else
			If DbSeek(oGDPesq:aHeader[nCpoF][2])
				aAdd(aIPesq, StrZero(nCpoF, 2) + "=" + SX3->X3_DESCRIC)
			Else
				aAdd(aIPesq, StrZero(nCpoF, 2) + "=" + oGDPesq:aHeader[nCpoF][1])
			EndIf
		EndIf
	Endif
 Next

 DbSetOrder(1)
 DbSelectArea(cAliasOld)

 FS_PreP(@cChvP, @cPict, oGDPesq, Val(nCpoS))

 If oDlgUse == Nil
  DEFINE MSDIALOG oDlgP TITLE OemToAnsi(STR0002) From 5, 14 To 11, 76 Of oMainWnd //"Pesquisar"
 EndIf

 @ nPosIni, 004 MsComboBox oCpoP Var nCpoS Color CLR_BLACK Size 100, 010 Items aIPesq On Change(FS_PreP(@cChvP, @cPict, oGDPesq, Val(nCpoS), oChvP)) Of oDlgP Pixel
 oCpoP:nAt := nIndIni

 If lAlinhaH

  @ nPosIni, 105 MSGet oChvP Var cChvP Picture cPict Size 100, 010 Of oDlgP Pixel Color CLR_BLACK

  oBtn1 := tButton():New(nPosIni, 205, STR0002, oDlgP, {|| IIF(FS_EfeP(cChvP, Val(nCpoS), oGDPesq, cPict, lFiltra, cFiltro), oDlgP:End(), .F.)}, 030, 012,,,, .T.)    //"Pesquisar"
  If oDlgUse == Nil
   oBtn2 := tButton():New(nPosIni, 236, STR0004, oDlgP, {|| oDlgP:End()}, 030, 012,,,, .T.)    //"Cancelar"
  EndIf

 Else

  @ nPosIni + 013, 004 MSGet oChvP Var cChvP Picture cPict Size 200, 010 Of oDlgP Pixel Color CLR_BLACK

  oBtn1 := tButton():New(nPosIni, 109, STR0002, oDlgP, {|| IIF(FS_EfeP(cChvP, Val(nCpoS), oGDPesq, cPict, lFiltra), oDlgP:End(), .F.)}, 030, 012,,,, .T.)    //"Pesquisar"
  If oDlgUse == Nil
   oBtn2 := tButton():New(nPosIni, 139, STR0004, oDlgP, {|| oDlgP:End()}, 030, 012,,,, .T.)    //"Cancelar"
  EndIf

 EndIf

If (cFiltro == " GA7_PERSOL = '1'")
 	FS_EfeP("_", Val(nCpoS), oGDPesq, cPict, lFiltra, cFiltro)
EndIF

 If oDlgUse == Nil
  ACTIVATE MSDIALOG oDlgP CENTERED
 EndIf

 RestArea(aArea)
Return(Nil)

Static Function FS_PreP(cChvP, cPict, oGDPesq, nCSel, oChvP)

 cPict := oGDPesq:aHeader[nCSel][3]
 If Empty(AllTRIM(cPicT))
  cPict := "@!"
 EndIf

 If oGDPesq:aHeader[nCSel][8] == "C"
  cChvP := Space(oGDPesq:aHeader[nCSel][4])
 ElseIf oGDPesq:aHeader[nCSel][8] == "N"
  cChvP := 0
 ElseIf oGDPesq:aHeader[nCSel][8] == "D"
  cChvP := dDataBase
 Else
  cChvP := Space(Len(oGDPesq:aHeader[nCSel][4]))
 EndIf

 If oChvP # Nil
  oChvP:Refresh()
 EndIf
Return(.T.)


Static Function FS_EfeP(cChvP, nCSel, oGDPesq, cPict, lFiltra, cCond)
 Local aArea   := getArea()
 Local nPosV := 0, lRet := .T.
 Local aCPesq := aClone(oGDPesq:aCols)
 Local cSql   := "", nI := 0, cCpos := ""
 Local AAux   := {}, nContAux := 0
 Local aCVirtual := {}, aArqCond := {}

 Private cFiltro    := cCond
 Private __aFnBfPsq := {cChvP, oGDPesq}

 Default lFiltra := .F.
 Default cFiltro := ""

 If Type("__cFnBfPsq") <> "U"
  &(__cFnBfPsq)
 EndIf

 If !lFiltra
 If ValType(cChvP) # "D"
  cChvP := AllTrim(cChvP)
 EndIf

 If ValType(cChvP) == "D"
  aSort(aCPesq ,,, {| X, Y | DTOS(X[nCSel]) < DTOS(Y[nCSel])})
  nPosV  := aScan(aCPesq , {| aVet | DTOS(aVet[nCSel]) == DTOS(cChvP) })
 Else
  aSort(aCPesq,,, {| X, Y | X[nCSel] < Y[nCSel]})
  nPosV  := aScan(aCPesq, {| aVet | Upper(SubStr(aVet[nCSel], 1, Len(cChvP))) == Upper(cChvP)})
 EndIf
 Else
  cAlias := Substr(oGDPesq:aHeader[1,2],1,at("_",oGDPesq:aHeader[1,2])-1)

  cSql  := " Select "
  cFrom := " From "+RetSqlName(Substr(oGDPesq:aHeader[1,2],1,at("_",oGDPesq:aHeader[1,2])-1))+" "+Substr(oGDPesq:aHeader[1,2],1,at("_",oGDPesq:aHeader[1,2])-1)

  For nI := 1 to Len(oGDPesq:aHeader)
   DbSelectArea("SX3")
   DbSetOrder(2)
   If DbSeek(oGDPesq:aHeader[nI, 2])

    If SX3->X3_TIPO # "M" .And. SX3->X3_CONTEXT == "V" .And. !Empty(SX3->X3_RELACAO) .And. FS_IsJoin(SX3->X3_RELACAO)
     aAdd(aCVirtual, {SX3->X3_CAMPO, STRTRAN(STRTRAN(UPPER(SX3->X3_RELACAO), " ", ""), "'", '"'), SX3->X3_ORDEM})
    Else
     cCpos += IIF(nI == 1,"",", " ) + oGDPesq:aHeader[nI, 2]
    EndIf

   EndIf
  Next nI

	 HS_ArqCond(cAlias, @aArqCond, aCVirtual, .T.)

 	For nI := 1 To Len(aArqCond)
 		If !Empty(aArqCond[nI, 1]) .And. !Empty(aArqCond[nI, 3])
  		cFrom += " " + aArqCond[nI, 1] + " ON " + aArqCond[nI, 3] + " "
 		EndIf

 		If !Empty(aArqCond[nI, 2])
 			cCpos += ", " + aArqCond[nI, 2] + " " + aArqCond[nI, 4]
 		EndIf
 	Next

  cSql += cCpos
  cSql += cFrom

  cSql += " Where "+cAlias+"."+cAlias+"_FILIAL = '"+xFilial(cAlias)+"' AND "+cAlias+".D_E_L_E_T_ <> '*' "

  cCpo := IIF(aScan(aArqCond, {|aVet| oGDPesq:aHeader[nCSel, 2] == aVet[4] }) > 0, aArqCond[aScan(aArqCond, {|aVet|    oGDPesq:aHeader[nCSel, 2] == aVet[4] }),2],cAlias+"."+oGDPesq:aHeader[nCSel, 2])
	 If ValType(cChvP) == "D"
   cSql += " AND "+cCpo+" >= '"+cChvP+"' "
  Else
   cSql += " AND "+cCpo+" Like '%"+RTrim(cChvP)+"%' "
  EndIf

  If !(Empty(cFiltro))
   cSql += " AND "+cFiltro
  EndIf

  cSql += " Order By "+oGDPesq:aHeader[nCSel, 2]+" asc "

  TCQuery cSql New Alias "TMPPESQ"

  DbSelectArea("TMPPESQ")
  DbGoTop()
  aCPesq := {}

  While TMPPESQ->(!Eof())
   aAux := {}
   For nI := 1 to Len(oGDPesq:aHeader)
    aAdd(aAux,&("TMPPESQ->"+oGDPesq:aHeader[nI, 2]))
   Next nI
   aAdd(aAux,.F.)
   aAdd(aCPesq, aAux)
   nPosV := 1
   DbSkip()
  EndDo
  DbSelectArea("TMPPESQ")
  DbCloseArea()

 EndIf

 If nPosV > 0
  oGDPesq:SetArray(aCPesq)
  oGDPesq:oBrowse:nAt := nPosV
  oGDPesq:oBrowse:Refresh()
  oGDPesq:oBrowse:SetFocus()
  If Type("__cFunPesq") <> "U"
    &(__cFunPesq)
  EndIf
 Else
  HS_MsgInf(STR0003, STR0001, STR0002)  //"Registro nใo encontrado"###"Aten็ใo"###"Pesquisar"
  lRet := .F.
 EndIf

 RestArea(aArea)
Return(lRet)

// Parametro aJoin Ex.:
// aAdd(aJoin, {RetSqlName("SB1") + " SB1", "SB1.B1_DESC" , "SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD = GD5.GD5_CODDES", "GD5_DDESPE"})
//              Arquivo e Alias           , Campo origem  , Condi็ใo de relacionamento entre os arquivos                                                       , Campo destino

Function HS_BDados(cAlias, aHDados, aCDados, nUDados, nOrd, lFilial, cCond, lStatus, cCpoLeg, cLstCpo, cElimina, cCpoNao, cStaReg, cCpoMar, cMarDef, lLstCpo, aLeg, lEliSql, lOrderBy, cCposGrpBy, cGroupBy, aCposIni, aJoin, aCposCalc, cOrderBy, aCposVis, aCposAlt, cCpoFilial, aCposFim, lGetMemo)

Local aCpos := {{"T", "GFR"}}
Local aArea := GetArea()/*HS_SavArea({{Alias(), 0, 0}})*/, nCol := 0, nTotItens := 0, cCampo := "", nForCpos := 0, aVCposOld := {}, nCposOld := 0
Local cSql := "", cCposSql := "", cCondSql := "", nFor := 0
Local nACond := 0, aArqCond := IIF(aJoin == Nil, {}, aJoin), cArqLst := RetSqlName(cAlias) + " " + cAlias
Local nQtdLinMax := IIf(nUDados <> Nil, nUDados, 0), nPosDef := 0
Local nOperLog   := 0
Local aOperLog   := {".and.", ".anD.", ".aNd.", ".aND.", ".And.", ".AnD.", ".ANd.", ".AND.", ".OR.", ".Or.", ".oR.", ".or.", ".not.", ".noT.", ".nOt.", ".nOT.", ".Not.", ".NoT.", ".NOt.", ".NOT." }
Local lGFR := .T.	
Local aCVirtual := {}
Local nFPos 	:= 0

Private lDuplSra	:= .F.

Default aLeg       := {{".T.", "BR_AZUL"}}
Default aCposCalc  := {}
Default lEliSql    := .T.
Default lOrderBy   := .T.
Default lLstCpo    := .F.
Default cStaReg    := "BR_VERDE"
Default cMarDef    := "'LBNO'"
Default aCposVis   := {}
Default aCposAlt   := {}
Default lFilial    := .T.
Default lGetMemo   := .F.
nUDados := 0

// Para garantir valor l๓gico ao campo lFilial
lFilial := IIF(ValType(lFilial) <> "L", .T., lFilial)

// Para garantir valor l๓gico ao campo lStatus
lStatus := IIF(ValType(lStatus) <> "L", .F., lStatus)

// Para garantir o valor caracter ao campo cStaReg
cStaReg := IIF(ValType(cStaReg) <> "C", "BR_VERDE", cStaReg)

//Salva valor das variaveis de memoria para restaurar no final
DbSelectArea("SX3")
DbSetOrder(1) // X3_ARQUIVO + X3_ORDEM
DbSeek(cAlias)
While SX3->X3_ARQUIVO == cAlias .and. !SX3->(Eof())
 	If ValType("M->" + SX3->X3_CAMPO ) <> "U"
		aAdd(aVCposOld, {"M->" + SX3->X3_CAMPO , &("M->" + SX3->X3_CAMPO) })
	EndIf
	SX3->(DbSkip())
End

cLstCpo := IIF(cLstCpo == Nil, "", cLstCpo)

If lStatus
	nUDados++
	aAdd(aHDados, FS_Sx3Defs(.T., "HSP_STAREG", 1, "'BR_VERMELHO'"))
EndIf

If cCpoLeg # Nil
	DbSetOrder(2)
	If DbSeek(PadR(AllTrim(cCpoLeg), 10))
		nUDados++
		aAdd(aHDados, FS_Sx3Defs(.T., PadR(AllTrim(cCpoLeg), 10), SX3->X3_TAMANHO))
	EndIf
EndIf

DbSelectArea("SX3")
If cCpoMar # Nil
	If ValType(cCpoMar) == "A"
		For nFor := 1 To Len (cCpoMar)
			DbSetOrder(2) // X3_CAMPO
			If DbSeek(PadR(AllTrim(cCpoMar[nFor]), 10))
				nUDados++
				aAdd(aHDados, FS_Sx3Defs(.T., PadR(AllTrim(cCpoMar[nFor]), 10), 1))
			EndIf
		Next nFor
	Else
		DbSetOrder(2)
		If DbSeek(PadR(AllTrim(cCpoMar), 10))
			nUDados++
			aAdd(aHDados, FS_Sx3Defs(.T., PadR(AllTrim(cCpoMar), 10), 1))
		EndIf
	EndIf
EndIf

If aCposIni # Nil
	For nForCpos := 1 To Len(aCposIni)
		DbSetOrder(2)
		If DbSeek(PadR(AllTrim(aCposIni[nForCpos]), 10))
			nUDados++
			aAdd(aHDados, FS_Sx3Defs(.F., PadR(AllTrim(aCposIni[nForCpos]), 10),,,, aCposVis, aCposAlt))
		EndIf
	Next
EndIf

DbSetOrder(1)
DbSeek(cAlias)
While !Eof() .And. SX3->X3_ARQUIVO == cAlias
	If cLstCpo == "ALL" .Or. ;
		(X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_BROWSE == "S" .And. ;
		IIF(aCposIni == Nil, .T., aScan(aCposIni, SX3->X3_CAMPO) == 0) .And. ;
		IIF(cCpoLeg == Nil, .T., SX3->X3_CAMPO # PadR(AllTrim(cCpoLeg), 10)) .And. ;
		IIF(cCpoMar == Nil, .T., IIf(ValType(cCpoMar) == "C" , SX3->X3_CAMPO # PadR(AllTrim(cCpoMar), 10), aScan(cCpoMar,{|aVet| SX3->X3_CAMPO == PadR(AllTrim(cCpoMar[1]),10) }) == 0 )) .And. ;
		IIF(cCpoNao == Nil, .T., !(SX3->X3_CAMPO $ cCpoNao))) .And. !lLstCpo .Or. ;
		(IIF(!Empty(cLstCpo), SX3->X3_CAMPO $ cLstCpo, lLstCpo))

		nUDados++
		aAdd(aHDados, FS_Sx3Defs(.F., SX3->X3_CAMPO,,,, aCposVis, aCposAlt))

		If SX3->X3_TIPO # "M" .And. SX3->X3_CONTEXT == "V" .And. !Empty(SX3->X3_RELACAO) .And. FS_IsJoin(SX3->X3_RELACAO)
			aAdd(aCVirtual, {SX3->X3_CAMPO, STRTRAN(STRTRAN(UPPER(SX3->X3_RELACAO), " ", ""), "'", '"'), SX3->X3_ORDEM})
		EndIf
	EndIf

	If SX3->X3_CONTEXT # "V" .And. SX3->X3_TIPO # "M"
		cCposSql += IIF(!Empty(cCposSql), ", ", "") + cAlias + "." + AllTrim(SX3->X3_CAMPO)
	ElseIf SX3->X3_CONTEXT # "V" .And. SX3->X3_TIPO == "M"
		If lGetMemo := .T.
			cCposSql += IIF(!Empty(cCposSql), ", ", "") + cAlias + "." + AllTrim(SX3->X3_CAMPO) + ", " + cAlias + ".R_E_C_N_O_ "
		Else
			cCposSql += IIF(!Empty(cCposSql), ", ", "") + cAlias + ".R_E_C_N_O_ " + AllTrim(SX3->X3_CAMPO)
		EndIf
	EndIf

	DbSkip()
EndDo

If Len(aCposCalc) > 0
	For nForCpos := 1 To Len(aCposCalc)
		DbSetOrder(2)
		If DbSeek(PadR(AllTrim(aCposCalc[nForCpos, 1]), 10))
			nUDados++
			aAdd(aHDados, FS_Sx3Defs(.F., aCposCalc[nForCpos, 3],,, aCposCalc[nForCpos, 2]))
		EndIf
	Next
EndIf
If aCposFim # Nil
	For nForCpos := 1 To Len(aCposFim)
		DbSetOrder(2)
		If DbSeek(PadR(AllTrim(aCposFim[nForCpos]), 10))
			nUDados++
			aAdd(aHDados, FS_Sx3Defs(.F., PadR(AllTrim(aCposFim[nForCpos]), 10),,,, aCposVis, aCposAlt))
		EndIf
	Next
EndIf
lDuplSra := FS_VERDUPRA(aCVirtual)
If cCond # Nil
	HS_ArqCond(cAlias, @aArqCond, aCVirtual, lFilial, cCpoFilial)

	For nACond := 1 To Len(aArqCond)
		If !Empty(aArqCond[nACond, 1]) .And. !Empty(aArqCond[nACond, 3]) .AND. !("SRA" $ aArqCond[nACond, 1] .AND. lDuplSra)
			cArqLst += " " + aArqCond[nACond, 1] + " ON " + aArqCond[nACond, 3] + " "
		EndIf

		If !Empty(aArqCond[nACond, 2])
			cCposSql += ", " + IIf("SRA" $ aArqCond[nACond, 1] .AND. lDuplSra,"'" + Space(TamSx3(aArqCond[nACond, 4])[1]) + "' AS ",aArqCond[nACond, 2]) + " " + aArqCond[nACond, 4]
		EndIf
	Next

	// Monta Ramk para o restante dos bancos diferentes de DB2
	If !("DB2" $ TCGetDB()) .And. nQtdLinMax > 0
		If "ORACLE" $ TCGetDB()
			cSql := "SELECT " + IIF(cCposGrpBy # Nil, cCposGrpBy, cCposSql) + " FROM " + cArqLst + " " + ;
			"WHERE ROWNUM <= "  + AllTrim(Str(nQtdLinMax)) + " AND " + IIF(lFilial, cAlias + "." + PrefixoCpo(cAlias) + "_FILIAL = '" + xFilial(cAlias) + "' AND ", "") + cAlias + ".D_E_L_E_T_ <> '*'"

		Else
			cSql := "SELECT TOP " + AllTrim(Str(nQtdLinMax)) + " " + IIF(cCposGrpBy # Nil, cCposGrpBy, cCposSql) + " FROM " + cArqLst + " " + ;
			"WHERE " + IIF(lFilial, cAlias + "." + PrefixoCpo(cAlias) + "_FILIAL = '" + xFilial(cAlias) + "' AND ", "") + cAlias + ".D_E_L_E_T_ <> '*'"

		EndIf
	Else
		cSql := "SELECT " + IIF(cCposGrpBy # Nil, cCposGrpBy, cCposSql) + " FROM " + cArqLst + " " + ;
		"WHERE " + IIF(lFilial, cAlias + "." + PrefixoCpo(cAlias) + "_FILIAL = '" + xFilial(cAlias) + "' AND ", "") + cAlias + ".D_E_L_E_T_ <> '*'"
	EndIf
	If !Empty(cCond)
		cCondSql := cCond

		For nOperLog := 1 to len(aOperLog)
			cCondSql := StrTran(cCondSql, aOperLog[nOperLog], IIF(LEN(aOperLog[nOperLog]) == 4, " OR ", IIF(UPPER(SUBSTR( ;
			aOperLog[nOperLog],2,1)) == "A", " AND ", " NOT ")))
		Next nOperLog

		cCondSql := StrTran(cCondSql, "->", ".")
		cCondSql := StrTran(cCondSql, "==", "=")
		cCondSql := StrTran(cCondSql, "#", "<>")
		cSql += " AND (" + cCondSql + ")"
	EndIf

	If !Empty(cElimina) .And. lEliSql
		cCondSql := cElimina

		For nOperLog := 1 to len(aOperLog)
			cCondSql := StrTran(cCondSql, aOperLog[nOperLog], IIF(LEN(aOperLog[nOperLog]) == 4, " OR ", IIF(UPPER(SUBSTR( ;
			aOperLog[nOperLog],2,1)) == "A", " AND ", " NOT ")))
		Next nOperLog

		cCondSql := StrTran(cCondSql, "->", ".")
		cCondSql := StrTran(cCondSql, "==", "=")
		cCondSql := StrTran(cCondSql, "#", "<>")
		cSql += " AND NOT (" + cCondSql + ")"
	EndIf

	If cGroupBy # Nil
		cSql += " GROUP BY " + cGroupBy
	EndIf

	If lOrderBy
		If cOrderBy # Nil .And. !Empty(cOrderBy)
			cSql += " ORDER BY " + cOrderBy
		ElseIf !Empty(nOrd)		
			cSql += " ORDER BY " + SqlOrder((cAlias)->(IndexKey(nOrd)))
		EndIf
	EndIf

	// Monta Ramk para banco de dados DB2
	If "DB2" $ TCGetDB() .And. nQtdLinMax > 0
		cSql += " FETCH FIRST " + AllTrim(Str(nQtdLinMax)) + " ROWS ONLY"
	EndIf

	cSql := ChangeQuery(cSql)

	TCQuery cSql New Alias "TMP" + cAlias

	For nCol := 1 To Len(aHDados)
		If aHDados[nCol, 10] <> "V" .And. aHDados[nCol, 08] $ "D/N"
			TCSetField("TMP" + cAlias, aHDados[nCol, 02], aHDados[nCol, 08], aHDados[nCol, 04], aHDados[nCol, 05])
		EndIf
	Next

	If ValType(cMarDef) == "A"
		For nFor := 1 To Len(cMarDef)
			cMarDef[nFor] := StrTran(cMarDef[nFor], cAlias + "->", "TMP" + cAlias + "->")
		Next nFor
	Else
		cMarDef := StrTran(cMarDef, cAlias + "->", "TMP" + cAlias + "->")
	EndIf

	cAlias := "TMP" + cAlias
	DbSelectArea(cAlias)

	While !Eof()
		If cElimina # Nil .And. !lEliSql .And. &(cElimina)
			DbSkip()
			Loop
		EndIf

		aAdd(aCDados, Array(nUDados + 1))
		For nCol := 1 To nUDados
			nPosDef := 0
			If (nForCpos := aScan(aCposCalc, {| aVet | aVet[3] == aHDados[nCol, 2]})) > 0
				aCDados[Len(aCDados), nCol] := &(aCposCalc[nForCpos, 4])
			ElseIf IIf(ValType(cCpoMar) == "C", aHDados[nCol, 2] == PadR(AllTrim(cCpoMar), 10) , (nPosDef := aScan(cCpoMar,{|aVet| aHDados[nCol, 2] == PadR(AllTrim(aVet),10) })) <> 0 )
				aCDados[Len(aCDados), nCol] := IIf(nPosDef == 0, &(cMarDef), &(cMarDef[nPosDef]))
			ElseIf aHDados[nCol, 2] == PadR(AllTrim(cCpoLeg), 10)
				aCDados[Len(aCDados), nCol] := FS_LegBD(aLeg,cCond)
			ElseIf aHDados[nCol, 2] == "HSP_STAREG"
				aCDados[Len(aCDados), nCol] := cStaReg
			Else
				If aHDados[nCol, 10] # "V"
					nFPos := FieldPos(aHDados[nCol, 2])
					if nFPos > 0
						aCDados[Len(aCDados), nCol] := FieldGet(nFPos)
					endif
				Else
					aCDados[Len(aCDados), nCol] := FS_RPadrao(cAlias, aHDados[nCol], aArqCond)
				EndIf
				cCampo    := "M->" + aHDados[nCol, 2]
				&(cCampo) := aCDados[Len(aCDados), nCol]
			EndIf
		Next
		aCDados[Len(aCDados), nUDados + 1] := .F.
		nTotItens++

		DbSelectArea(cAlias)
		DbSkip()
	EndDo
EndIf

If Empty(aCDados)
	aAdd(aCDados, Array(nUDados + 1))
	For nCol := 1 To nUDados
		nPosDef := 0
		If (nForCpos := aScan(aCposCalc, {| aVet | aVet[3] == aHDados[nCol, 2]})) > 0
			aCDados[Len(aCDados), nCol] := &(aCposCalc[nForCpos, 4])
		ElseIf IIf(ValType(cCpoMar) == "C", aHDados[nCol, 2] == PadR(AllTrim(cCpoMar), 10) , (nPosDef := aScan(cCpoMar,{|aVet| aHDados[nCol, 2] == PadR(AllTrim(aVet),10) })) <> 0 )
			aCDados[Len(aCDados), nCol] := IIf(nPosDef == 0, &(cMarDef), &(cMarDef[nPosDef]))
		ElseIf aHDados[nCol, 2] == PadR(AllTrim(cCpoLeg), 10)
			aCDados[Len(aCDados), nCol] := FS_LegBD(aLeg,cCond)
		ElseIf aHDados[nCol, 2] == "HSP_STAREG"
			aCDados[Len(aCDados), nCol] := "BR_VERMELHO"
		Else
			aCDados[Len(aCDados), nCol] := FS_RPadrao(cAlias, aHDados[nCol], aArqCond)

			cCampo    := "M->" + aHDados[nCol, 2]
			&(cCampo) := aCDados[Len(aCDados), nCol]
		EndIf
	Next
	aCDados[Len(aCDados), nUDados + 1] := .F.
EndIf

If cCond # Nil
	DbSelectArea(cAlias)
	DbCloseArea()
EndIf

//HS_ResArea(aArea)
RestArea(aArea)
//DbSelectArea(aArea[1][1])

For nCposOld := 1 To Len(aVCposOld)
	&(aVCposOld[nCposOld, 1]) := aVCposOld[nCposOld, 2]
Next

Return(nTotItens)



Static Function FS_Sx3Defs(lBmpCpo, cNomCpo, nTamCpo, cRelaca, cTitulo, aCposVis, aCposAlt, cPictur)

 Local aRetSx3 := {}
 Local cX3_CBox := IIf(SubStr(SX3->X3_CBOX, 1, 1) == "#", &(AllTrim(SubStr(SX3->X3_CBOX, 2))), SX3->X3_CBOX)

 Default cRelaca  := ""
 Default cPictur  := "@BMP"
 Default aCposVis := {}
 Default aCposAlt := {}

 aRetSx3 := {IIF(lBmpCpo, " "    , TRIM(IIF(!Empty(cTitulo), cTitulo, X3Titulo()))), ;
             IIF(lBmpCpo, cNomCpo, IIF(!Empty(cNomCpo), cNomCpo, SX3->X3_CAMPO)),	;
             IIF(lBmpCpo, cPictur, SX3->X3_PICTURE ), ;
             IIF(lBmpCpo, nTamCpo, SX3->X3_TAMANHO ), ;
             IIF(lBmpCpo, 0      , SX3->X3_DECIMAL ), ;
             IIF(lBmpCpo, .F.    , SX3->X3_VALID   ), ;
             IIF(lBmpCpo, ""     , SX3->X3_USADO   ), ;
      		     IIF(lBmpCpo, "C"    , SX3->X3_TIPO    ), ;
             IIF(lBmpCpo, ""     , SX3->X3_F3      ), ;
   		        IIF(lBmpCpo, "V"    , SX3->X3_CONTEXT ), ;
             IIF(lBmpCpo, ""     , cX3_CBox        ), ;
   		        IIF(lBmpCpo, cRelaca, IIF(!Empty(cRelaca), cRelaca, SX3->X3_RELACAO)), ;
             IIF(lBmpCpo, ""     , SX3->X3_WHEN    ), ;
             IIF(lBmpCpo, "V"    , SX3->X3_VISUAL  ), ;
             IIF(lBmpCpo, ""     , SX3->X3_VLDUSER ), ;
             IIF(lBmpCpo, ""     , SX3->X3_PICTVAR ), ;
             IIF(lBmpCpo, ""     , X3Obrigat(SX3->X3_CAMPO))}

 If aScan(aCposVis, cNomCpo) > 0
  aRetSx3[14] := "V"
 ElseIf aScan(aCposAlt, cNomCpo) > 0
  aRetSx3[14] := "A"
 EndIf

Return(aRetSx3)

Static Function FS_RPadrao(cAlias, aCampo, aArqCond)

Local cRPadrao := "", nPosRet := 0

//ConOut("Campo [" + aCampo[2] + "] [" + AllTrim(aCampo[12]) + "]")

If "TMP" $ cAlias
	If aArqCond # Nil .And. (nPosRet := aScan(aArqCond, {| aVet | aVet[4] == aCampo[2]})) > 0 .And. Type(cAlias + "->" + aArqCond[nPosRet, 4]) <> "U" .AND. !(lDuplSra .AND. "SRA" $ aArqCond[nPosRet, 1])
		cRPadrao := &(cAlias + "->" + aArqCond[nPosRet, 4])
	Else
		If !Empty(aCampo[12])
			cRPadrao := &(StrTran(aCampo[12], SubStr(cAlias, 4, Len(cAlias) - 3) + "->", cAlias + "->"))
		Else
			cRPadrao := IIF(aCampo[8] == "N", 0, IIF(aCampo[8] == "D", CToD(""), Space(aCampo[4])))
		EndIf
	EndIf
ElseIf !Empty(aCampo[12])
	cRPadrao := &(aCampo[12])
Else
	cRPadrao := IIF(aCampo[8] == "N", 0, IIF(aCampo[8] == "D", CToD(""), Space(aCampo[4])))
EndIf


Return(cRPadrao)

Static Function FS_LegBD(aLeg,cCond)

 Local nLeg := 0, cCorLeg := "BR_CINZA"
 If cCond <> nil
  For nLeg := 1 To Len(aLeg)
   If &(aLeg[nLeg, 1])
    cCorLeg := aLeg[nLeg, 2]
   EndIf
  Next
 EndIf

Return(cCorLeg)

Function HS_ArqCond(cADes, aArqCond, aCVirtual, lFilial, cCpoFilial)
 Local nCVirtual  := 0
 Local nPStr      := 0
 Local cRStr      := ""
 Local cAOri      := ""
 Local cNOrd      := ""
 Local cPChv      := ""
 Local cIChv      := ""
 Local nIChv      := 0
 Local nPChv      := 0
 Local cRCpo      := ""
 Local cCond      := ""
 Local lCpoFilial := !Empty(cCpoFilial) .And. &(cADes)->(FieldPos(cCpoFilial)) > 0
 Local lArqExclus := .F.
 Local cPosChv	  := ""

  // Inclui o alias do arquivo principal no campo
 cCpoFilial := IIf(!Empty(cCpoFilial), cADes + "." + cCpoFilial, Nil)

 For nCVirtual := 1 To Len(aCVirtual)
  cRStr := aCVirtual[nCVirtual][2]

  //POSICIONE("GD4",1,xFilial("GD4")+GCZ->GCZ_REGGER+GCZ->GCZ_CODPLA,"GD4_MATRIC")
  If     "POSICIONE(" $ cRStr
   nPStr := At("POSICIONE(", cRStr) + 10

  //HS_IniPadr("GFV",1,GCZ->GCZ_CODPLA+GCZ->GCZ_SQCATP,"GFV_NOMCAT",,.F.)
  ElseIf "HS_INIPADR(" $ cRStr
   nPStr := At("HS_INIPADR(", cRStr) + 11

  //HS_X3RELAC("GCM", 2, "GD4_CODPLA", "GCM_DESPLA")
  ElseIf "HS_X3RELAC(" $ cRStr
   nPStr := At("HS_X3RELAC(", cRStr) + 11

  EndIf

  // Pega o Alias
  cRStr := SubStr(cRStr, nPStr + 1)
  cAOri := SubStr(cRStr, 1, (nPStr := At(",", cRStr)) - 2)

  // Pega o Indice
  cRStr := SubStr(cRStr, nPStr + 1)
  cNOrd := HS_CInd(Val(SubStr(cRStr, 1, (nPStr := At(",", cRStr)) - 1)))

  // Posiciona no dicionแrio de indices para pegar a chave de pesquisa e retirar o campo filial
  SIX->(DbSeek(cAOri + cNOrd))
  cIChv := StrTran(AllTrim(Upper(SIX->CHAVE)), " ", "")
  cIChv := SubStr(cIChv, At("+", cIChv) + 1)

  // Pega a chave para pesquisa
  If "HS_X3RELAC(" $ aCVirtual[nCVirtual][2]
   cRStr := SubStr(cRStr, nPStr + 2)
  Else
   cRStr := SubStr(cRStr, nPStr + 1)
  EndIf
  // Retira a fun็ใo xFilial()
  If "POSICIONE(" $ aCVirtual[nCVirtual][2]
   cRStr := SubStr(cRStr, At("+", cRStr) + 1)
  EndIf
  If "HS_X3RELAC(" $ aCVirtual[nCVirtual][2]
   cPChv := SubStr(cRStr, 1, (nPStr := At(",", cRStr)) - 2)
  Else
   cPChv := SubStr(cRStr, 1, (nPStr := At(",", cRStr)) - 1)
  EndIf

  cPChv := StrTran(cPChv, '"', "'")

  // Pega o campo que serแ retornado na query
  cRStr := SubStr(cRStr, nPStr + 2)
  cRCpo := SubStr(cRStr, 1, At('"', cRStr) - 1)

  // Acerta a chave do indice para montar a condi็ใo do join
  cIChv := cAOri + aCVirtual[nCVirtual][3] + "." + StrTran(cIChv, "+", " || " + cAOri + aCVirtual[nCVirtual][3] + ".")

  // Acerta a chave de pesquisa para montar a condi็ใo do join
  cPChv := StrTran(cPChv, cADes + "->", "")
  cPChv := StrTran(cPChv,        "M->", "")
  cPChv := cADes + "." + StrTran(cPChv, "+", " || " + cADes + ".")
  cPChv := StrTran(cPChv, cADes + ".'", "'")

  If (nIChv := HS_CntChr(cIChv, "|")) <> (nPChv := HS_CntChr(cPChv, "|"))
   //ConOut("Indice   [" + cIChv + "]")
   //ConOut("Pesquisa [" + cPChv + "]")

   nIChv := 1
   nPChv := ((nPChv + 2) / 2)

   cRStr := cIChv
   cIChv := ""
   While nIChv <= nPChv
    cIChv += IIf(!Empty(cIChv), " || ", "") + SubStr(cRStr, 1, At("||", cRStr)-2)
    nIChv++
    cRStr := SubStr(cRStr, At("||", cRStr)+3)
   End
   //ConOut("Indice   [" + cIChv + "]")
  EndIf

  lArqExclus := !Empty(xFilial(cAOri))

	If  At("|",cIChv) > 0
  		cPosChv := FS_TRATCND(cIChv,cPChv)
 	Else
		cPosChv := cIChv + " = " + cPChv
	EndIf
  cCond := IIF(lFilial .Or. (lCpoFilial .And. lArqExclus), cAOri + aCVirtual[nCVirtual][3] + "." + PrefixoCpo(cAOri) + "_FILIAL = " + IIf(lCpoFilial .And. !lFilial, cCpoFilial, "'" + xFilial(cAOri) + "'") + " AND ", "") + ;
           IIf(cAOri == "SRA", cAOri + aCVirtual[nCVirtual][3] + ".RA_CODIGO <> '" + Space(TamSx3("RA_CODIGO")[1]) + "' AND ", "") + ;
           cAOri + aCVirtual[nCVirtual][3] + ".D_E_L_E_T_ <> '*' AND " + cPosChv//;
           //cIChv + " = " + cPChv

  If aScan(aArqCond, {| aVet | Upper(aVet[4]) == Upper(aCVirtual[nCVirtual][1])}) == 0 .And. aScan(aArqCond, {| aVet | Right(Upper(aVet[1]), Len(cAOri + aCVirtual[nCVirtual][3])) == Upper(cAOri + aCVirtual[nCVirtual][3])}) == 0
   aAdd(aArqCond, {" LEFT JOIN " + RetSqlName(cAOri) + " " + cAOri + aCVirtual[nCVirtual][3], cAOri + aCVirtual[nCVirtual][3] + "." + cRCpo, cCond, aCVirtual[nCVirtual][1]})
  EndIf
 Next

Return(Nil)

Static Function FS_IsJoin(cX3Relacao)
 Local lRet     := .F.
 Local cX3Alias := ""

 cX3Relacao := StrTran(Upper(cX3Relacao), " ", "")

 If     "POSICIONE("  $ StrTran(Upper(SX3->X3_RELACAO), " ", "")
  lRet := .T.
  cX3Alias := SubStr(cX3Relacao, At("POSICIONE(", cX3Relacao) + 11, 3)

 ElseIf "HS_INIPADR(" $ StrTran(Upper(SX3->X3_RELACAO), " ", "")
  lRet := .T.
  cX3Alias := SubStr(cX3Relacao, At("HS_INIPADR(", cX3Relacao) + 12, 3)

 ElseIf "HS_X3RELAC(" $ StrTran(Upper(SX3->X3_RELACAO), " ", "")
  lRet := .T.
  cX3Alias := SubStr(cX3Relacao, At("HS_X3RELAC(", cX3Relacao) + 12, 3)

 EndIf

 // Caso a origem seja um dicionแrio nใo faz o join
 If lRet .And. cX3Alias <> "SX5" .And. (SubStr(cX3Alias, 1, 2) == "SX" .Or. cX3Alias == "SIX")
  lRet := .F.

 EndIf

Return(lRet)

Static Function FS_TRATCND(cIChv,cPChv)
Local cStrAux1	:= ""
Local cStrAux2	:= ""
Local cProx1	:= ""
Local cProx2	:= ""
Local cRetorno 	:= ""
Local nPos1		:= 0
Local nPosAux	:= 0
Local nPos2		:= 0
Local nTamTot	:= Len(cIChv)
Local nTamTot2	:= Len(cPChv)

While (nPos1 := At("|", cIChv)) > 0
	//Primeira String do relacionamento
	cStrAux1 	:= Substr(cIChv, 1 , nPos1 - 1 )
	If (nPosAux := At("|", Substr(cIChv, nPos1 + 2 , Len(cIChv)))) > 0
		nPosAux	:= nPosAux - 1
	Else
		nPosAux	:= Len(cIChv)
	EndIf
	cProx1		:= Substr(cIChv, nPos1 + 2 , nPosAux )
	If (nPosAux := At("|", Substr(cIChv, nPos1 + 2 , Len(cIChv)))) > 0
		cIChv := Substr(cIChv, nPos1 + 2 , nTamTot )
	Else
		cIChv := ""
	EndIf


	//Segunda String do relacionamento
	nPos2 := At("|", cPChv)
	cStrAux2 	:= Substr(cPChv, 1 , nPos2 - 1 )
	If (nPosAux := At("|", Substr(cPChv, nPos2 + 2 , Len(cPChv)))) > 0
		nPosAux	:= nPosAux - 1
	Else
		nPosAux	:= Len(cPChv)
	EndIf
	cProx2		:= Substr(cPChv, nPos2 + 2 , nPosAux )

	If (nPosAux := At("|", Substr(cPChv, nPos2 + 2 , Len(cPChv)))) > 0
		cPChv := Substr(cPChv, nPos2 + 2 , nTamTot2 )
	Else
		cPChv := ""
	EndIf


	//String de retorno
	If Empty(cRetorno)
		cRetorno += cStrAux1 + " = " + cStrAux2
	EndIf
	If !Empty(cProx1) .AND.  !Empty(cProx2)
		cRetorno += " AND " + cProx1 + " = "  + cProx2
	EndIf
End

Return(cRetorno)

// Verifica se existem dois ou mais campos virtuais para a tabela SRA
Static Function FS_VERDUPRA(aCpos)
Local nL	:= 0
Local nC	:= 0

If Len(aCpos) == 0
	Return(.F.)
EndIf

For nL := 1 To Len(aCpos)
	If "'SRA'" $ Upper(aCpos[nL, 2]) .OR. '"SRA"' $ Upper(aCpos[nL, 2])
		nC ++
	EndIf
Next nL

Return((nC > 1))
