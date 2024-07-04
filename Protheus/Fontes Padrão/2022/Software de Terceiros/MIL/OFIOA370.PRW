// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 06     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#Include "tbiconn.ch"
#Include "Protheus.ch"
#Include "OFIOA370.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao    ³ OFIOA370 | Autor ³  Andre Luis Almeida  ³ Data ³ 22/09/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Estoque Minimo e Seguranca OFICINA ( WORKFLOW -> SB1 )    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ WORKFLOW: OFIOA370({"COD.EMPRESA","FILIAL EMPRESA"}) - Todo dia 4:00hs³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA370(aEmpresa)
Local ni := 0
Local aSM0     := {}
Private cEmpr     := "  "
Private cFil      := "  "
Private cQuebra   := "INICIAL"
Private lRecVAN   := .f.
Private nRecVAN   := 0
Private nDemMin   := 0
Private nDemSeg   := 0
Private cMPercABC := ""
Private cSPercABC := ""
Private aTRB      := {}
Private aVAN      := {}
Private dDtAtual  := date()
Private dDtIniM   := dDtAtual
Private dDtIniS   := dDtAtual
Private dDtFimM   := dDtAtual
Private dDtFimS   := dDtAtual
Private dSemIni   := cTod("01/01/"+strzero(year(dDtAtual)))-dow(cTod("01/01/"+strzero(year(dDtAtual))))
Private lFazer    := .f.
Private lB1_ESTMIN:= .f.
If Type("cFOPENed") == "U"
	Set Deleted On
	Set Date British
	Set EPOCH to 1950
	__TTSInUse := .f.
	__TTSPush  := {}
	__cLogSiga := space(10)
	cEmpr := aEmpresa[1,1]
	cFil  := aEmpresa[1,2]
	FS_OPENARQ()
Else
	If !MsgYesNo(STR0002,STR0001)
		Return
	EndIf
	aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
	cEmpr := aSM0[1]
	cFil  := aSM0[2]
	lFazer := .t.
EndIf
If SB1->(FieldPos("B1_ESTMIN")) # 0
	lB1_ESTMIN := .t.
EndIf
//////////////////// Criando Vetor com VAN (Grupo/Cod.Item) ////////////////////
DbSelectArea("VAN")
DbSetOrder(1)
DbSeek( xFilial("VAN") )
While !Eof() .and. xFilial("VAN") == VAN->VAN_FILIAL
	aAdd(aVAN,{ VAN->VAN_GRUITE+VAN->VAN_CODITE , VAN->(Recno()) , VAN->VAN_MDEMAN , VAN->VAN_SDEMAN })
	If !lFazer
		If VAN->VAN_MDEMAN # "0"
			If	VAN->VAN_MTPPER == "1" // Diario
				lFazer := .t.
			ElseIf VAN->VAN_MTPPER == "2" .and. Dow(dDtAtual) == 7 // Semanal
				lFazer := .t.
			ElseIf VAN->VAN_MTPPER == "3" .and. day(dDtAtual) == 1 // Mensal
				lFazer := .t.
			EndIf
		EndIf
		If VAN->VAN_SDEMAN # "0"
			If	VAN->VAN_STPPER == "1" // Diario
				lFazer := .t.
			ElseIf VAN->VAN_STPPER == "2" .and. Dow(dDtAtual) == 7 // Semanal
				lFazer := .t.
			ElseIf VAN->VAN_STPPER == "3" .and. day(dDtAtual) == 1 // Mensal
				lFazer := .t.
			EndIf
		EndIf
	EndIf
	DbSelectArea("VAN")
	DbSkip()
EndDo

// Pelo WorkFlow fazer somente se Diario/Semanal/Mensal e sempre se chamado pelo MNU //
If lFazer
	
	//////////////////// Atualizando aTRB com VAN ////////////////////
	DbSelectArea("VAN")
	DbSetOrder(1)
	DbSeek( xFilial("VAN") )
	While !Eof() .and. xFilial("VAN") == VAN->VAN_FILIAL
		If Empty(VAN->VAN_CODITE) // Por: Grupo
			cQuebra := "INICIAL"
			lRecVAN := .f.
			dDtIniM := dDtAtual + 1
			dDtIniS := dDtAtual + 1
			dDtFimM := dDtAtual + 1
			dDtFimS := dDtAtual + 1
			DbSelectArea("VES")
			DbSetOrder(1)
			DbSeek( xFilial("VES") + VAN->VAN_GRUITE )
			While !Eof() .and. xFilial("VES") == VES->VES_FILIAL .and. VES->VES_GRUITE == VAN->VAN_GRUITE
				If cQuebra # VES->VES_GRUITE+VES->VES_CODITE
					dDtIniM := dDtAtual + 1
					dDtIniS := dDtAtual + 1
					dDtFimM := dDtAtual + 1
					dDtFimS := dDtAtual + 1
					cQuebra := VES->VES_GRUITE+VES->VES_CODITE
					lRecVAN := .f.
					nPos := aScan(aVAN,{|x| x[1] == cQuebra })
					If nPos > 0
						lRecVAN := .t.
						nRecVAN := VAN->(Recno())
						DbSelectArea("VAN")
						DbGoTo(aVAN[nPos,2])
					EndIf
					If VAN->VAN_MDEMAN # "0"
						If VAN->VAN_MTPPER == "1" 		// Diario
							dDtIniM := ( dDtAtual - VAN->VAN_MPERIO )
							dDtFimM := ( dDtAtual - 1 )
						ElseIf VAN->VAN_MTPPER == "2" // Semanal
							dDtIniM := dSemIni + ((Int((dDtAtual-dSemIni)/7)-VAN->VAN_MPERIO)*7)
							dDtFimM := dSemIni + ((Int((dDtAtual-dSemIni)/7))*7)-1
						Else									// Mensal
							dDtIniM := cTod("01/"+strzero(month(dDtAtual-(30*VAN->VAN_MPERIO)),2)+"/"+substr(strzero(year(dDtAtual-(30*VAN->VAN_MPERIO)),4),3,2))
							dDtFimM := cTod("01/"+strzero(month(dDtAtual),2)+"/"+substr(strzero(year(dDtAtual),4),3,2))-1
						EndIf
					EndIf
					If VAN->VAN_SDEMAN # "0"
						If VAN->VAN_STPPER == "1"		// Diario
							dDtIniS := ( dDtAtual - VAN->VAN_SPERIO )
							dDtFimS := ( dDtAtual - 1 )
						ElseIf VAN->VAN_STPPER == "2" // Semanal
							dDtIniS := dSemIni + ((Int((dDtAtual-dSemIni)/7)-VAN->VAN_SPERIO)*7)
							dDtFimS := dSemIni + ((Int((dDtAtual-dSemIni)/7))*7)-1
						Else									// Mensal
							dDtIniS := cTod("01/"+strzero(month(dDtAtual-(30*VAN->VAN_SPERIO)),2)+"/"+substr(strzero(year(dDtAtual-(30*VAN->VAN_SPERIO)),4),3,2))
							dDtFimS := cTod("01/"+strzero(month(dDtAtual),2)+"/"+substr(strzero(year(dDtAtual),4),3,2))-1
						EndIf
					EndIf
					nDemMin := 0
					nDemSeg := 0
					/////////////////
					// Inclui aTRB //
					/////////////////
					aAdd(aTRB,{ 0 , IIf(VAN->VAN_MDEMAN=="0",.f.,.t.) , 0 , IIf(VAN->VAN_SDEMAN=="0",.f.,.t.) , 0 })
					//
				EndIf
				If VAN->VAN_MDEMAN # "0"
					If VES->VES_DATDEM >= dDtIniM .and. VES->VES_DATDEM <= dDtFimM .and. VES->VES_SEMANA <= "53"
						If VAN->VAN_MDEMAN == "1"		// Oficina
							nDemMin += VES->VES_DEMOFI
						ElseIf VAN->VAN_MDEMAN == "2"	// Balcao
							nDemMin += VES->VES_DEMBAL
						Else								// Oficina + Balcao
							nDemMin += ( VES->VES_DEMOFI + VES->VES_DEMBAL )
						EndIf
					EndIf
				EndIf
				If VAN->VAN_SDEMAN # "0"
					If VES->VES_DATDEM >= dDtIniS .and. VES->VES_DATDEM <= dDtFimS .and. VES->VES_SEMANA <= "53"
						If VAN->VAN_SDEMAN == "1"		// Oficina
							nDemSeg += VES->VES_DEMOFI
						ElseIf VAN->VAN_SDEMAN == "2"	// Balcao
							nDemSeg += VES->VES_DEMBAL
						Else								// Oficina + Balcao
							nDemSeg += ( VES->VES_DEMOFI + VES->VES_DEMBAL )
						EndIf
					EndIf
				EndIf
				DbSelectArea("VES")
				DbSkip()
				If cQuebra # VES->VES_GRUITE+VES->VES_CODITE
					DbSelectArea("SB1")
					DbSetOrder(7)
					DbSeek( xFilial("SB1") + cQuebra )
					aTRB[len(aTRB),1] := SB1->(Recno())
					DbSelectArea("SBL")
					DbSetOrder(1)
					DbSeek( xFilial("SBL") + SB1->B1_COD + strzero(year(dDtAtual),4) + strzero(month(dDtAtual),2) , .t. )
					If !Bof() .and. SBL->BL_PRODUTO # SB1->B1_COD
						DbSelectArea("SBL")
						DbSkip(-1)
					EndIf
					If (SBL->BL_ABCVEND+SBL->BL_ABCCUST) >= "AA" .and. (SBL->BL_ABCVEND+SBL->BL_ABCCUST) <= "CC"
						cMPercABC := "VAN->VAN_MPER"+SBL->BL_ABCVEND+SBL->BL_ABCCUST
						cSPercABC := "VAN->VAN_SPER"+SBL->BL_ABCVEND+SBL->BL_ABCCUST
					Else
						cMPercABC := "VAN->VAN_MPERCC"
						cSPercABC := "VAN->VAN_SPERCC"
					EndIf
					aTRB[len(aTRB),3] := ( ( nDemMin / VAN->VAN_MDIVID ) * ( &cMPercABC / 100 ) )
					aTRB[len(aTRB),5] := ( ( nDemSeg / VAN->VAN_SDIVID ) * ( &cSPercABC / 100 ) )
					If lRecVAN
						DbSelectArea("VAN")
						DbGoTo(nRecVAN)
					EndIf
				EndIf
				DbSelectArea("VES")
			EndDo
		EndIf
		DbSelectArea("VAN")
		DbSkip()
	EndDo
	
	
	//////////////////// Zerando SB1 ////////////////////
	DbSelectArea("SB1")
	DbSetOrder(7)
	DbSeek( xFilial("SB1") )
	While !Eof() .and. xFilial("SB1") == SB1->B1_FILIAL
		nPos := aScan(aVAN,{|x| x[1] == SB1->B1_GRUPO+SB1->B1_CODITE })
		If nPos > 0
			If aVAN[nPos,3] # "0" .or. aVAN[nPos,4] # "0"
				DbSelectArea("SB1")
				RecLock("SB1",.f.)
				If aVAN[nPos,3] # "0"
					If lB1_ESTMIN
						SB1->B1_ESTMIN := 0
					Else
						SB1->B1_EMIN := 0
					EndIf
				EndIf
				If aVAN[nPos,4] # "0"
					SB1->B1_ESTSEG := 0
				EndIf
				MsUnlock()
			EndIf
		Else
			nPos := aScan(aVAN,{|x| x[1] == SB1->B1_GRUPO + space(27) })
			If nPos > 0
				If aVAN[nPos,3] # "0" .or. aVAN[nPos,4] # "0"
					DbSelectArea("SB1")
					RecLock("SB1",.f.)
					If aVAN[nPos,3] # "0"
						If lB1_ESTMIN
							SB1->B1_ESTMIN := 0
						Else
							SB1->B1_EMIN := 0
						EndIf
					EndIf
					If aVAN[nPos,4] # "0"
						SB1->B1_ESTSEG := 0
					EndIf
					MsUnlock()
				EndIf
			Else
				DbSelectArea("SB1")
				RecLock("SB1",.f.)
				If lB1_ESTMIN
					SB1->B1_ESTMIN := 0
				Else
					SB1->B1_EMIN := 0
				EndIf
				SB1->B1_ESTSEG := 0
				MsUnlock()
			EndIf
		EndIf
		DbSelectArea("SB1")
		DbSkip()
	EndDo
	
	//////////////////// Atualizando SB1 com aTRB ////////////////////
	DbSelectArea("SB1")
	For ni := 1 to len(aTRB)
		If aTRB[ni,2] .or. aTRB[ni,4]
			If aTRB[ni,1] > 0
				SB1->(DbGoTo(aTRB[ni,1]))
				RecLock("SB1",.f.)
				If aTRB[ni,2]
					If lB1_ESTMIN
						SB1->B1_ESTMIN := aTRB[ni,3]
					Else
						SB1->B1_EMIN := aTRB[ni,3]
					EndIf
				EndIf
				If aTRB[ni,4]
					SB1->B1_ESTSEG := aTRB[ni,5]
				EndIf
				MsUnlock()
			EndIf
		EndIf
	Next
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_OPENARQ Autor ³ Andre Luis Almeida    ³ Data ³ 26/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Posicao das Vendas & Resultados - AUTOMATICO pelo WORKFLOW ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#IFDEF TOP
	
	Static Function FS_OPENARQ()
	
	Local cOpenArq:= "'SF2'," , nOpem:=0
	Local cStr:=""
	DBCloseAll()
	Prepare Environment Empresa cEmpr Filial cFil Tables 'SF2' Modulo "OFI"
	if (nHandle:= FT_FUse( "SIGAOFI.MNU" )) == -1
		Return
	endif
	FT_FGotop()
	While ! FT_FEof()
		cStr := FT_FReadLN()
		If Substr(cStr,31,1) == "T"
			For nOpem := 32 to 90 step 3
				If !Empty(Substr(cStr,nOpem,3)) .And. !( "." $ Substr(cStr,nOpem,3) );
					.And. At(Substr(cStr,nOpem,3),cOpenArq)==0 .And. At(Substr(cStr,nOpem,3),cFOPENed)==0;
					.And. SX2->(DbSeek(Substr(cStr,nOpem,3)))
					cOpenArq += "'"+Substr(cStr,nOpem,3)+"',"
					DbSelectArea(Substr(cStr,nOpem,3))
				EndIf
			Next
		EndIf
		FT_FSkip()
	End
	FT_FUse()
	Return
	
#ENDIF
