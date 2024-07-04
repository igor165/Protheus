// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 06     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "OFIOR290.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_VALSX5T3 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 14/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ FUNCAO QUE VALIDA A PERGUNTE NO SX5                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FS_VALSX5T3

Local ni:=0

aChave01 := {} //zera vetor de Parametros Chave 01
aChave02 := {} //zera vetor de Parametros Chave 02
aChave03 := {} //zera vetor de Parametros Chave 03
aChave04 := {} //zera vetor de Parametros Chave 04
aChave05 := {} //zera vetor de Parametros Chave 05
aChave06 := {} //zera vetor de Parametros Chave 06
aChave07 := {} //zera vetor de Parametros Chave 07

cSX5existe := "SIM"
DbSelectArea( "SX5" )
DbSetOrder(1)

If cSX5existe == "SIM"
	cChave := Alltrim(MV_PAR06)
	For ni:=1 to len(cChave)
		nPos := aScan(aChave02,{|x| x[1] == substr(cChave,ni,6)})
		If nPos == 0
			nPos := aScan(aChave03,{|x| x[1] == substr(cChave,ni,6)})
			If nPos == 0
				nPos := aScan(aChave04,{|x| x[1] == substr(cChave,ni,6)})
				If nPos == 0
					nPos := aScan(aChave05,{|x| x[1] == substr(cChave,ni,6)})
					If nPos == 0
						nPos := aScan(aChave06,{|x| x[1] == substr(cChave,ni,6)})
						If nPos == 0
							nPos := aScan(aChave07,{|x| x[1] == substr(cChave,ni,6)})
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		If nPos <> 0
			cSX5existe := "NAO"
		EndIf
		If DbSeek( xFilial("SX5") + "T3" + substr(cChave,ni,6) , .f. ) .and. cSX5existe == "SIM"
			aAdd(aChave01,{substr(cChave,ni,6)})
			ni := ni + 6
		Else
			cSX5existe := "NAO"
			ni := len(cChave) + 1
		EndIf
	Next
EndIf
If cSX5existe == "SIM"
	cChave := Alltrim(MV_PAR07)
	For ni:=1 to len(cChave)
		nPos := aScan(aChave01,{|x| x[1] == substr(cChave,ni,6)})
		If nPos == 0
			nPos := aScan(aChave03,{|x| x[1] == substr(cChave,ni,6)})
			If nPos == 0
				nPos := aScan(aChave04,{|x| x[1] == substr(cChave,ni,6)})
				If nPos == 0
					nPos := aScan(aChave05,{|x| x[1] == substr(cChave,ni,6)})
					If nPos == 0
						nPos := aScan(aChave06,{|x| x[1] == substr(cChave,ni,6)})
						If nPos == 0
							nPos := aScan(aChave07,{|x| x[1] == substr(cChave,ni,6)})
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		If nPos <> 0
			cSX5existe := "NAO"
		EndIf
		If DbSeek( xFilial("SX5") + "T3" + substr(cChave,ni,6) , .f. ) .and. cSX5existe == "SIM"
			aAdd(aChave02,{substr(cChave,ni,6)})
			ni := ni + 6
		Else
			cSX5existe := "NAO"
			ni := len(cChave) + 1
		EndIf
	Next
EndIf
If cSX5existe == "SIM"
	cChave := Alltrim(MV_PAR08)
	For ni:=1 to len(cChave)
		nPos := aScan(aChave01,{|x| x[1] == substr(cChave,ni,6)})
		If nPos == 0
			nPos := aScan(aChave02,{|x| x[1] == substr(cChave,ni,6)})
			If nPos == 0
				nPos := aScan(aChave04,{|x| x[1] == substr(cChave,ni,6)})
				If nPos == 0
					nPos := aScan(aChave05,{|x| x[1] == substr(cChave,ni,6)})
					If nPos == 0
						nPos := aScan(aChave06,{|x| x[1] == substr(cChave,ni,6)})
						If nPos == 0
							nPos := aScan(aChave07,{|x| x[1] == substr(cChave,ni,6)})
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		If nPos <> 0
			cSX5existe := "NAO"
		EndIf
		If DbSeek( xFilial("SX5") + "T3" + substr(cChave,ni,6) , .f. ) .and. cSX5existe == "SIM"
			aAdd(aChave03,{substr(cChave,ni,6)})
			ni := ni + 6
		Else
			cSX5existe := "NAO"
			ni := len(cChave) + 1
		EndIf
	Next
EndIf
If cSX5existe == "SIM"
	cChave := Alltrim(MV_PAR09)
	For ni:=1 to len(cChave)
		nPos := aScan(aChave01,{|x| x[1] == substr(cChave,ni,6)})
		If nPos == 0
			nPos := aScan(aChave02,{|x| x[1] == substr(cChave,ni,6)})
			If nPos == 0
				nPos := aScan(aChave03,{|x| x[1] == substr(cChave,ni,6)})
				If nPos == 0
					nPos := aScan(aChave05,{|x| x[1] == substr(cChave,ni,6)})
					If nPos == 0
						nPos := aScan(aChave06,{|x| x[1] == substr(cChave,ni,6)})
						If nPos == 0
							nPos := aScan(aChave07,{|x| x[1] == substr(cChave,ni,6)})
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		If nPos <> 0
			cSX5existe := "NAO"
		EndIf
		If DbSeek( xFilial("SX5") + "T3" + substr(cChave,ni,6) , .f. ) .and. cSX5existe == "SIM"
			aAdd(aChave04,{substr(cChave,ni,6)})
			ni := ni + 6
		Else
			cSX5existe := "NAO"
			ni := len(cChave) + 1
		EndIf
	Next
EndIf
If cSX5existe == "SIM"
	cChave := Alltrim(MV_PAR10)
	For ni:=1 to len(cChave)
		nPos := aScan(aChave01,{|x| x[1] == substr(cChave,ni,6)})
		If nPos == 0
			nPos := aScan(aChave02,{|x| x[1] == substr(cChave,ni,6)})
			If nPos == 0
				nPos := aScan(aChave03,{|x| x[1] == substr(cChave,ni,6)})
				If nPos == 0
					nPos := aScan(aChave04,{|x| x[1] == substr(cChave,ni,6)})
					If nPos == 0
						nPos := aScan(aChave06,{|x| x[1] == substr(cChave,ni,6)})
						If nPos == 0
							nPos := aScan(aChave07,{|x| x[1] == substr(cChave,ni,6)})
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		If nPos <> 0
			cSX5existe := "NAO"
		EndIf
		If DbSeek( xFilial("SX5") + "T3" + substr(cChave,ni,6) , .f. ) .and. cSX5existe == "SIM"
			aAdd(aChave05,{substr(cChave,ni,6)})
			ni := ni + 6
		Else
			cSX5existe := "NAO"
			ni := len(cChave) + 1
		EndIf
	Next
EndIf
If cSX5existe == "SIM"
	cChave := Alltrim(MV_PAR11)
	For ni:=1 to len(cChave)
		nPos := aScan(aChave01,{|x| x[1] == substr(cChave,ni,6)})
		If nPos == 0
			nPos := aScan(aChave02,{|x| x[1] == substr(cChave,ni,6)})
			If nPos == 0
				nPos := aScan(aChave03,{|x| x[1] == substr(cChave,ni,6)})
				If nPos == 0
					nPos := aScan(aChave04,{|x| x[1] == substr(cChave,ni,6)})
					If nPos == 0
						nPos := aScan(aChave05,{|x| x[1] == substr(cChave,ni,6)})
						If nPos == 0
							nPos := aScan(aChave07,{|x| x[1] == substr(cChave,ni,6)})
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		If nPos <> 0
			cSX5existe := "NAO"
		EndIf
		If DbSeek( xFilial("SX5") + "T3" + substr(cChave,ni,6) , .f. ) .and. cSX5existe == "SIM"
			aAdd(aChave06,{substr(cChave,ni,6)})
			ni := ni + 6
		Else
			cSX5existe := "NAO"
			ni := len(cChave) + 1
		EndIf
	Next
EndIf
If cSX5existe == "SIM"
	cChave := Alltrim(MV_PAR12)
	For ni:=1 to len(cChave)
		nPos := aScan(aChave01,{|x| x[1] == substr(cChave,ni,6)})
		If nPos == 0
			nPos := aScan(aChave02,{|x| x[1] == substr(cChave,ni,6)})
			If nPos == 0
				nPos := aScan(aChave03,{|x| x[1] == substr(cChave,ni,6)})
				If nPos == 0
					nPos := aScan(aChave04,{|x| x[1] == substr(cChave,ni,6)})
					If nPos == 0
						nPos := aScan(aChave05,{|x| x[1] == substr(cChave,ni,6)})
						If nPos == 0
							nPos := aScan(aChave06,{|x| x[1] == substr(cChave,ni,6)})
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		If nPos <> 0
			cSX5existe := "NAO"
		EndIf
		If DbSeek( xFilial("SX5") + "T3" + substr(cChave,ni,6) , .f. ) .and. cSX5existe == "SIM"
			aAdd(aChave07,{substr(cChave,ni,6)})
			ni := ni + 6
		Else
			cSX5existe := "NAO"
			ni := len(cChave) + 1
		EndIf
	Next
EndIf
If cSX5existe == "NAO"
	Help(" ",1,"FALTASX5T3")
	Return .F.
Else
	Return .T.
EndIf
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³OA110OK     ³ Autor ³  Ednilson           ³ Data ³ 24/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Funcao para o TudoOk                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALR290(cPar01,cPar02)
Local lRet := .t.
If cPar01 > cPar02
	Help(" ",1,"DATA2MOATU")
	lRet := .f.
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GRPPA  ºAutor  ³Fabio               º Data ³  05/10/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava PPA                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRPPA( aEGoverno   , aEFrotis    , aESeg    , aELjPeca , aEOfiInd , aERede    , aECliBal ,;
aIGoverno   , aIFrotis    , aISeg    , aIDmCli  , aIGarant , aIConInt  , aIAcess  , aIOutVen ,;
aMTTGeral	  , nMRede    , nMLjPeca , nMFabric , nMTTRdTer , nMOutCom   , nMComEsp ,;
nOVeiVen    , nOVeiOfi  )

Local aItens:={}

Private lMsErroAuto := .f. , lMsHelpAuto := .t.

If MsgYesNo(OemToAnsi(STR0050),OemToAnsi(STR0049))
	
	If Pergunte("OFR291")
		
		Begin Transaction
		
		aItens := {}
		aAdd( aItens , { { "VIF_CODMAR" , MV_PAR17         , NIL  } ,;
		{ "VIF_MESANO" , MV_PAR18+MV_PAR19, NIL  } ,;
		{ "VIF_DATEST" , dDataBase        , NIL  } ,;
		{ "VIF_MODALI" , "1"              , NIL  } ,;
		{ "VIF_GOVEVL" , aEGoverno[4]     , NIL  } ,;
		{ "VIF_GOVECV" , aEGoverno[5]     , NIL  } ,;
		{ "VIF_FROTVL" , aEFrotis[4]      , NIL  } ,;
		{ "VIF_FROTCV" , aEFrotis[5]      , NIL  } ,;
		{ "VIF_SEGUVL" , aESeg[4]         , NIL  } ,;
		{ "VIF_SEGUCV" , aESeg[5]         , NIL  } ,;
		{ "VIF_LPECVL" , aELjPeca[4]      , NIL  } ,;
		{ "VIF_LPECCV" , aELjPeca[5]      , NIL  } ,;
		{ "VIF_OFINVL" , aEOfiInd[4]      , NIL  } ,;
		{ "VIF_OFINCV" , aEOfiInd[5]      , NIL  } ,;
		{ "VIF_REDEVL" , aERede[4]        , NIL  } ,;
		{ "VIF_REDECV" , aERede[5]        , NIL  } ,;
		{ "VIF_CBALVL" , aECliBal[1]      , NIL  } ,;
		{ "VIF_CBALCV" , aECliBal[2]      , NIL  } } )
		
		DbSelectArea("VIF")
		DbSetOrder(1)
		DbSeek( xFilial("VIF") + VV1->VV1_CODMAR + Dtos(dDataBase) + "1" )
		
		MSExecAuto( {|x,y| FG_ROTAUTO(x,y)} , aItens , If(VIF->(Found()),4,3) )
		
		If lMsErroAuto
			DisarmTransaction()
			Break
		EndIf
		
		aItens := {}
		aAdd( aItens , { { "VIF_CODMAR" , MV_PAR17         , NIL  } ,;
		{ "VIF_MESANO" , MV_PAR18+MV_PAR19, NIL  } ,;
		{ "VIF_DATEST" , dDataBase        , NIL  } ,;
		{ "VIF_MODALI" , "2"              , NIL  } ,;
		{ "VIF_GOVEVL" , aIGoverno[4]     , NIL  } ,;
		{ "VIF_GOVECV" , aIGoverno[5]     , NIL  } ,;
		{ "VIF_FROTVL" , aIFrotis[4]      , NIL  } ,;
		{ "VIF_FROTCV" , aIFrotis[5]      , NIL  } ,;
		{ "VIF_SEGUVL" , aISeg[4]         , NIL  } ,;
		{ "VIF_SEGUCV" , aISeg[5]         , NIL  } ,;
		{ "VIF_DECLVL" , aIDmCli[4]       , NIL  } ,;
		{ "VIF_DECLCV" , aIDmCli[5]       , NIL  } ,;
		{ "VIF_GARAVL" , aIGarant[4]      , NIL  } ,;
		{ "VIF_GARACV" , aIGarant[5]      , NIL  } ,;
		{ "VIF_COINVL" , aIConInt[4]      , NIL  } ,;
		{ "VIF_COINCV" , aIConInt[5]      , NIL  } ,;
		{ "VIF_ACESVL" , aIAcess[1]       , NIL  } ,;
		{ "VIF_ACESCV" , aIAcess[2]       , NIL  } ,;
		{ "VIF_OUVEVL" , aIOutVen[1]      , NIL  } ,;
		{ "VIF_OUVECV" , aIOutVen[2]      , NIL  } } )
		
		DbSelectArea("VIF")
		DbSetOrder(1)
		DbSeek( xFilial("VIF") + VV1->VV1_CODMAR + Dtos(dDataBase) + "2" )
		
		MSExecAuto( {|x,y| FG_ROTAUTO(x,y)} , aItens , If(VIF->(Found()),4,3) )
		
		If lMsErroAuto
			DisarmTransaction()
			Break
		EndIf
		
		aItens := {}
		aAdd( aItens , { { "VIF_CODMAR" , MV_PAR17         , NIL  } ,;
		{ "VIF_MESANO" , MV_PAR18+MV_PAR19, NIL  } ,;
		{ "VIF_DATEST" , dDataBase        , NIL  } ,;
		{ "VIF_MODALI" , "3"              , NIL  } ,;
		{ "VIF_TTGEVL" , aMTTGeral[1]     , NIL  } ,;
		{ "VIF_TTGECV" , aMTTGeral[2]     , NIL  } ,;
		{ "VIF_MREDEO" , nMRede           , NIL  } ,;
		{ "VIF_LJPECA" , nMLjPeca         , NIL  } ,;
		{ "VIF_FABRIC" , nMFabric         , NIL  } ,;
		{ "VIF_TRETER" , nMTTRdTer        , NIL  } ,;
		{ "VIF_OUTCOM" , nMOutCom         , NIL  } ,;
		{ "VIF_COMESP" , nMComEsp         , NIL  } ,;
		{ "VIF_GERENT" , MV_PAR01         , NIL  } ,;
		{ "VIF_ADMOUT" , MV_PAR02         , NIL  } ,;
		{ "VIF_BALVAR" , MV_PAR03         , NIL  } ,;
		{ "VIF_BALOFI" , MV_PAR04         , NIL  } ,;
		{ "VIF_VENATA" , MV_PAR05         , NIL  } ,;
		{ "VIF_VENACE" , MV_PAR06         , NIL  } } )
		
		DbSelectArea("VIF")
		DbSetOrder(1)
		DbSeek( xFilial("VIF") + VV1->VV1_CODMAR + Dtos(dDataBase) + "3" )
		
		MSExecAuto( {|x,y| FG_ROTAUTO(x,y)} , aItens , If(VIF->(Found()),4,3) )
		
		If lMsErroAuto
			DisarmTransaction()
			Break
		EndIf
		
		aItens := {}
		aAdd( aItens , { { "VIF_CODMAR" , MV_PAR17                       , NIL } ,;
		{ "VIF_MESANO" , MV_PAR18+MV_PAR19              , NIL } ,;
		{ "VIF_DATEST" , dDataBase                      , NIL } ,;
		{ "VIF_MODALI" , "4"                            , NIL } ,;
		{ "VIF_VENACE" , nOVeiVen                       , NIL } ,;
		{ "VIF_VEIOFI" , nTotPas                        , NIL } ,;
		{ "VIF_VEIVEN" , nOVeiOfi                       , NIL } ,;
		{ "VIF_TPECAC" , If(Len(aGrpEst)==0,0,aGrpEst[1,4]), NIL } ,;
		{ "VIF_TOUTRO" , aTotNOri[1,2]                  , NIL } ,;
		{ "VIF_EPECAC" , aGrpTransf[1,3]-aGrpTransf[3,3], NIL } ,;
		{ "VIF_EOUTRO" , aGrpTransf[3,3]                , NIL } ,;
		{ "VIF_SPECAC" , aGrpTransf[1,4]-aGrpTransf[3,4], NIL } ,;
		{ "VIF_SOUTRO" , aGrpTransf[3,4]                , NIL } ,;
		{ "VIF_QTDORI" , If(Len(aGrpEst)==0,0,aGrpEst[1,3]), NIL } ,;
		{ "VIF_NOMRES" , MV_PAR07                       , NIL } } )
		
		DbSelectArea("VIF")
		DbSetOrder(1)
		DbSeek( xFilial("VIF") + VV1->VV1_CODMAR + Dtos(dDataBase) + "4" )
		
		MSExecAuto( {|x,y| FG_ROTAUTO(x,y)} , aItens , If(VIF->(Found()),4,3) )
		
		If lMsErroAuto
			DisarmTransaction()
			Break
		EndIf
		
		End Transaction
		
		If lMsErroAuto
			MostraErro()
		EndIf
		
	EndIf
	
EndIf

lMsErroAuto := .t.
lMsHelpAuto := .f.

Return
