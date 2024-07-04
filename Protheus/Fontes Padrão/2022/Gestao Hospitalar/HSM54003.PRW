#include "protheus.ch" 
#include "topconn.ch"
#include "HSM54003.CH"

Static oGAgdMes  := Nil
Static __cSql    := Nil
Static __aIteSol := {}
Static dDtIni    := CToD(" ")
Static dDtFin    := CToD(" ")
Static __lChkEsp := .T.
Static __lChkCrm := .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHsm54Fol  บAutor  ณMicrosiga           บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSM54Fol(nStatus, aTit, aPag)

Local aPMemo   := IIf(nStatus == 2, aTit, Nil)
Local aHAgdMes := {}, aCAgdMes := {}
Local cSql     := ""
Local cAlias   := Alias()
Local vRetFol  := Nil
Local oPParam  := Nil
Local oBtnFil  := Nil
Local oDTIni   := Nil
Local oDTFin   := Nil
Local oChkCrm  := Nil
Local oChkEsp  := Nil 
Local lVld		:= .T.

/* 0-LIBERADO  1-OCUPADO  2-BLOQUEADO  3-ATENDIDO  4-OCUPADO BLIQUEADO  5-CONFIRMADO  6-RETORNO  */
If     nStatus == 1
	aAdd(aTit, STR0001 + " x &" + STR0002) //"Profissional x &Capacidade"
	
	aAdd(aPag, STR0001 + " x " + STR0002) //"Profissional x Capacidade"
	
	vRetFol := {aClone(aTit), aClone(aPag)}
	
ElseIf nStatus == 2
	aAdd(aHAgdMes, {STR0001, "cNomProf", "@!"    , 40, 0, "", "", "C", "", "V", 0, "", ""})//"Profissional"
	aAdd(aHAgdMes, {STR0003, "cNomEspc", "@!"    , 40, 0, "", "", "C", "", "V", 0, "", ""})//"Especialidade"
	aAdd(aHAgdMes, {STR0004, "qTotDisp", "999999", 06, 0, "", "", "N", "", "V", 0, "", ""})//"Qtd.Disponibilidade"
	aAdd(aHAgdMes, {STR0005, "hTotDisp", "999:99", 06, 0, "", "", "C", "", "V", 0, "", ""})//"Hrs.Disponibilidade"
	aAdd(aHAgdMes, {STR0006, "qTotLibe", "999999", 06, 0, "", "", "N", "", "V", 0, "", ""})//"Qtd.Liberado"
	aAdd(aHAgdMes, {STR0007, "hTotLibe", "999:99", 06, 0, "", "", "C", "", "V", 0, "", ""})//"Hrs.Liberado"
	aAdd(aHAgdMes, {STR0008, "qTotOcup", "999999", 06, 0, "", "", "N", "", "V", 0, "", ""})//"Qtd.Ocupado"
	aAdd(aHAgdMes, {STR0009, "hTotOcup", "999:99", 06, 0, "", "", "C", "", "V", 0, "", ""})//"Hrs.Ocupado"
	aAdd(aHAgdMes, {STR0010, "qTotBloq", "999999", 06, 0, "", "", "N", "", "V", 0, "", ""})//"Qtd.Bloqueado"
	aAdd(aHAgdMes, {STR0011, "hTotBloq", "999:99", 06, 0, "", "", "C", "", "V", 0, "", ""})//"Hrs.Bloqueado"
	aAdd(aHAgdMes, {STR0012, "qTotAten", "999999", 06, 0, "", "", "N", "", "V", 0, "", ""})//"Qtd.Atendido"
	aAdd(aHAgdMes, {STR0013, "hTotAten", "999:99", 06, 0, "", "", "C", "", "V", 0, "", ""})//"Hrs.Atendido"
	aAdd(aHAgdMes, {STR0014, "qTotCanc", "999999", 06, 0, "", "", "N", "", "V", 0, "", ""})//"Qtd.Cancelado"
	aAdd(aHAgdMes, {STR0015, "hTotCanc", "999:99", 06, 0, "", "", "C", "", "V", 0, "", ""})//"Hrs.Cancelado"
	aAdd(aHAgdMes, {STR0016, "qTotTrnf", "999999", 06, 0, "", "", "N", "", "V", 0, "", ""})//"Qtd.Transferido"
	aAdd(aHAgdMes, {STR0017, "hTotTrnf", "999:99", 06, 0, "", "", "C", "", "V", 0, "", ""})//"Hrs.Transferido"
	//aAdd(aHAgdMes, {STR0018, "qTotProd", "999999", 06, 0, "", "", "N", "", "V", 0, "", ""})//"Qtd.Produtividade"
	//aAdd(aHAgdMes, {STR0019, "hTotProd", "999:99", 06, 0, "", "", "C", "", "V", 0, "", ""})//"Hrs.Produtividade"
	aAdd(aHAgdMes, {STR0031 + " (%)"/*STR0018*/, "qTotProd", "@E 99.99", 06, 0, "", "", "N", "", "V", 0, "", ""})//"Produtividade"
	//aAdd(aHAgdMes, {STR0019, "hTotProd", "999:99", 06, 0, "", "", "C", "", "V", 0, "", ""})//"Hrs.Produtividade"	
	
	__cSql := Nil
	
	dDtIni := FirstDay(oCalend:dDiaAtu)
	dDtFin := LastDay(oCalend:dDiaAtu)
	
	oPParam	:=	tPanel():New(0, 0,, oFolder:aDialogs[Len(oFolder:aDialogs)],,,,,, 200, 20)
	oPParam:Align := CONTROL_ALIGN_TOP
	
	@ 005, 005 SAY OemToAnsi(STR0020) OF oPParam PIXEL //"Data Inicial"
	@ 003, 040 MSGet oDTIni Var dDtIni Picture "@D" Of oPParam Pixel
	
	@ 005, 100 SAY OemToAnsi(STR0021) OF oPParam PIXEL //"Data Final"
	@ 003, 135 MSGet oDTFin Var dDtFin Picture "@D" Of oPParam Pixel
	
	oChkCrm := TCheckBox():New(005, 190, STR0001, {| lChk | IIf(PCount() > 0, __lChkCrm := lChk, __lChkCrm)}, oPParam, 100, 210,, {|| FSChkBox(oChkCrm, @__lChkCrm, oChkEsp, @__lChkEsp)},,,,,, .T.,,,) //"Profissional" 
	
	oChkEsp := TCheckBox():New(005, 225, STR0003, {| lChk | IIf(PCount() > 0, __lChkEsp := lChk, __lChkEsp)}, oPParam, 100, 210,, {|| FSChkBox(oChkCrm, @__lChkCrm, oChkEsp, @__lChkEsp)},,,,,, .T.,,,) //'Especialidade'
	
	oBtnFil := tButton():New(003, 280, "Ok", oPParam, {|| MsgRun(STR0022,, {|| FSMntProd(dDtIni, dDtFin, __lChkCrm, __lChkEsp)})},,,,,, .T.) //"Aguarde, processando informa็๕es"
	
	oGAgdMes := MsNewGetDados():New(aPMemo[1][1], aPMemo[1][2], aPMemo[1][3], aPMemo[1][4], 0,,,,,,,,,, oFolder:aDialogs[Len(oFolder:aDialogs)], aHAgdMes, aCAgdMes)
	oGAgdMes:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
ElseIf StrZero(nStatus, 1) $ "3/4"
	dDtIni := FirstDay(oCalend:dDiaAtu)
	dDtFin := LastDay(oCalend:dDiaAtu)
	
	FSMntProd(FirstDay(oCalend:dDiaAtu), LastDay(oCalend:dDiaAtu))
	
EndIf

If Type("cProcDoPln") # "U" .AND. Type("M->GM8_CODPRO") # "U"
	lVld := (M->GM8_CODPRO == IIF(Empty(cProcDoPln),M->GM8_CODPRO,cProcDoPln)) 	
EndIf


DbSelectArea(cAlias)
Return({vRetFol, lVld})


Function M54SelProc(cCargo, CurrentNodeId, aItens, cProcUrg)
Local nPosDes  := 0
Local cNroPri  := ""
Local cCodPro  := ""
Local lRet     := .F.
Local nItens   := 0
Local nPNode   := 0
Local nPPrio   := 0
Local cTpPrSb1 := SuperGetMV("MV_TPPRSB1",, "")  
Local dVigIni	:= CTOD("")
Local dVigFin	:= CTOD("")
Local cPlanPar	:= SuperGetMV("MV_PLANPAR", NIL, "")

Default cProcUrg := "" //Caso seja procedimento de urgencia possibilita o agendamento

// aItens --- Estrutura
//{StrZero(nCurNodeId, Len(oTreeOrc:CurrentNodeId)), 01
//QRYORC->GT9_NUMFAT,                               02
//GFR->GFR_CDESPE,                                  03
//QRYORC->GTJ_PRIORI,                               04
//QRYORC->GTJ_PRODUT,                               05
//QRYORC->GTJ_STATUS,                               06
//GA7->GA7_DESC,                                    07
//QRYORC->GTJ_ITEM,                                 08
//QRYORC->GTJ_GERSOL,                               09
//QRYORC->CK_QTDVEN}                                10
//0=Pendente;1=Realizado;2=Cancelado;3=Agendado
If SubStr(cCargo, 1, 4) == "PROC"
	M->GM8_NUMORC := Space(TamSx3("GM8_NUMORC")[1])
	M->GM8_ITEORC := Space(TamSx3("GM8_ITEORC")[1])
	If !Empty(cProcUrg)
		M->GM8_CODPRO := cProcUrg
        If AllTrim(GA7->GA7_CODPRO) == AllTrim(cProcUrg)
			HS_SEEKRET('GA7', 'M->GM8_CODPRO', 1, .F., {'GM8_DESPRO','GM8_DURACA'}, {'GA7_DESC','GA7_TEMPRO'})
        EndIf
		Return(.T.)
	EndIf		
	nPNode := aScan(aItens, {| aNodes | aNodes[1] == CurrentNodeId})
	nPPrio := aScan(aItens, {| aNodes | aNodes[6] == "0" .And. aNodes[4] < aItens[nPNode][4]})
	lRet   := .F. 
	dVigIni := STOD(aItens[1, 11])
	dVigFin := STOD(aItens[1, 12])
	
	If !Empty(dVigFin) .AND. (dVigFin < dDataBase)
		HS_MsgInf(STR0023, STR0024, STR0025) //"O prazo de vig๊ncia do tratamento expirou!" ### "Aten็ใo" ### "Agendamento Ambulatorial"
		Return(.F.)
	EndIf	
	
	If  lRet := (aItens[nPNode][6] == "0" .And. (nPPrio == 0 .OR. SuperGetMV("MV_AGDPRI",, .F.) )) // 0=Pendente e nใo encontrou itens com prioridade inferior ao procedimento selecionado
		M->GM8_CODPRO := aItens[nPNode][5]
		DbSelectArea("GA7")
		DbSetOrder(1)
		If DbSeek(xFilial("GA7") + PADR(aItens[nPNode][5], TAMSX3("GA7_CODPRO")[1])) .AND. Type("cGbjCodEsp") # "U"
			cGbjCodEsp := GA7->GA7_CODESP
			HS_SEEKRET('GA7', 'M->GM8_CODPRO', 1, .F., {'GM8_DESPRO','GM8_DURACA'}, {'GA7_DESC','GA7_TEMPRO'})
			If Empty(StrTran(M->GM8_DURACA, ":", "")) .AND. !Empty(StrTran(GA7->GA7_TEMPRO, ":", ""))
				M->GM8_DURACA := GA7->GA7_TEMPRO
			EndIf
		EndIf
		//oGO4:aCols    := {}
		//oGetGEB:aCols := {}
		
		For nItens := 1 To Len(aItens)
			//If nItens <> nPNode .And. aItens[nPNode][04] == aItens[nItens][04]
			If nItens <> nPNode .And. aItens[nPNode][04] == aItens[nItens][04] .and. aItens[nItens][06] == "0" //Pendente
				If HS_IniPadr("SB1", 1, aItens[nItens][5], "B1_TIPO",, .F.) == PadR(AllTrim(cTpPrSb1), Len(SB1->B1_TIPO))
					If (nPosDes := aScan(oGO4:aCols, {| aVet | !aVet[Len(oGO4:aHeader)+1] .And. Empty(aVet[nGO4_CodPro])})) == 0
						oGO4:AddLine(.F., .F.)
						oGO4:lNewLine := .F.
						nPosDes := Len(oGO4:aCols)
					EndIf
					
					oGO4:nAt := nPosDes
					
					oGO4:aCols[Len(oGO4:aCols)][nGo4_CodPro] := aItens[nItens][05]
					oGO4:aCols[Len(oGO4:aCols)][nGo4_DesPro] := aItens[nItens][07]
					oGO4:aCols[Len(oGO4:aCols)][nGo4_NumOrc] := aItens[nItens][02]
					oGO4:aCols[Len(oGO4:aCols)][nGo4_IteOrc] := aItens[nItens][08]
					oGO4:oBrowse:Refresh()
					
				Else
					If (nPosDes := aScan(oGetGEB:aCols, {| aVet | !aVet[Len(oGetGEB:aHeader)+1] .And. Empty(aVet[nGebCodMat])})) == 0
						oGetGEB:AddLine(.F., .F.)
						oGetGEB:lNewLine := .F.
						nPosDes := Len(oGetGEB:aCols)
					EndIf
					
					oGetGEB:nAt := nPosDes
					
					oGetGEB:aCols[nPosDes][nGebCodMat] := aItens[nItens][05]
					oGetGEB:aCols[nPosDes][nGebDescMa] := aItens[nItens][07]
					oGetGEB:aCols[nPosDes][nGebQtdMat] += aItens[nItens][10]
					oGetGEB:aCols[nPosDes][nGebNumOrc] += aItens[nItens][02]
					oGetGEB:aCols[nPosDes][nGebIteOrc] += aItens[nItens][08]
					
					If aItens[nItens][9] == "1" // 1-Solicita no agendamento
						
						aAdd(__aIteSol, {nItens, aItens[nItens][5]})
						
					EndIf
					oGetGEB:oBrowse:Refresh()
				EndIf
				
			ElseIf nItens == nPNode
				M->GM8_NUMORC := aItens[nItens][02]
				M->GM8_ITEORC := aItens[nItens][08]
				If !Empty(M->GM8_NUMORC) .AND. !Empty(cPlanPar)
					DbSelectArea("GT9")
					DbSetOrder(1)
					Dbseek(xFilial("GT9") + aItens[nItens][02])
					If GT9->GT9_COBRAN == "1" .AND. M->GM8_CODPLA <> cPlanPar
						M->GM8_CODPLA := cPlanPar						
						M->GM8_DESPLA := HS_IniPadr("GCM", 02, cPlanPar, "GCM_DESPLA",, .F.)
					EndIf
				EndIf
				
			EndIf
		Next
		
	ElseIf aItens[nPNode][6] == "0" .And. nPPrio  > 0 // 0=Pendente e encontrou itens com prioridade inferior ao procedimento selecionado
		HS_MsgInf(STR0026 + " [" + AllTrim(aItens[nPPrio][5]) + "-" + AllTrim(aItens[nPPrio][7]) + "] " + STR0027, STR0024, STR0025) //"Selecione o procedimento" ### "porque tem prioridade maior que o procedimento selecionado" ### "Aten็ใo" ### "Agendamento Ambulatorial"
	ElseIf aItens[nPNode][6] == "1" // 1=Realizado
		HS_MsgInf(STR0028, STR0024, STR0025)//"Procedimento ja foi realizado" ### "Aten็ใo" ### "Agendamento Ambulatorial"
		
	ElseIf aItens[nPNode][6] == "2" // 2=Cancelado
		HS_MsgInf(STR0029, STR0024, STR0025) //"Procedimento cancelado" ### "Aten็ใo" ### "Agendamento Ambulatorial"
		
	ElseIf aItens[nPNode][6] == "3" // 3=Agendado
		HS_MsgInf(STR0030, STR0024, STR0025) //"Procedimento ja foi agendado" ### "Aten็ใo" ### "Agendamento Ambulatorial"
		
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM54  บAutor  ณMicrosiga           บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSA54Sol()
Local nIteSol    := 0
Local cGaiSolici := Space(Len(GAI->GAI_SOLICI))

If Len(__aIteSol) > 0
	
	M->GAI_SOLICI := HS_VSxeNum("GAI", "M->GAI_SOLICI", 1)
	ConfirmSx8()
	
	cGaiSolici    := M->GAI_SOLICI
	
	DbSelectArea("GAI")
	DbSetOrder(1)
	RecLock("GAI", .T.)
	GAI->GAI_FILIAL := xFilial("GAI")
	GAI->GAI_SOLICI := M->GAI_SOLICI
	GAI->GAI_ALMORI := cGcsArmFar
	GAI->GAI_REQUIS := "1" // 1-Paciente
	GAI->GAI_ALMSOL := cGcsArmSet
	GAI->GAI_NOMPAC := M->GM8_NOMPAC
	GAI->GAI_CODLOC := cLctCodLoc
	GAI->GAI_DATSOL := dDataBase
	GAI->GAI_HORSOL := Time()
	GAI->GAI_FLGATE := "0"
	GAI->GAI_URGENC := "0"
	GAI->GAI_CODAGE := M->GM8_CODAGE
	GAI->GAI_LOGARQ := HS_LogArq()
	MsUnLock()
	
	DbSelectArea("GAJ")
	DbSetOrder(1)
	For nIteSol := 1 To Len(__aIteSol)
		RecLock("GAJ", .T.)
		GAJ->GAJ_FILIAL := xFilial("GAJ")
		GAJ->GAJ_SOLICI := M->GAI_SOLICI
		GAJ->GAJ_ITESOL := StrZero(nIteSol, Len(GAJ->GAJ_ITESOL))
		GAJ->GAJ_PROSOL := oGetGEB:aCols[__aIteSol[nIteSol, 1], nGebCodMat]
		GAJ->GAJ_QTDSOL := __aIteSol[nIteSol, 2]
		GAJ->GAJ_LOGARQ := HS_LogArq()
		MsUnLock()
	Next
	
	__aIteSol := {}
	
EndIf
Return(cGaiSolici)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM54  บAutor  ณMicrosiga           บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FSMntProd(dDtIni, dDtFin, lCrm, lEsp)
Local aCAgdMes  := {}
Local cAliasOld := Alias()
Local cSql      := ""
Local cGrpBy    := ""

Default lCrm := .T.
Default lEsp := .T.

If lCrm
	cGrpBy += "GM8.GM8_CODCRM"	//cGrpBy += "GM8.GM8_CODCRM, SRA.RA_NOME"
EndIf

If lEsp
	cGrpBy += IIf(!Empty(cGrpBy), ", ", "") + "GFR.GFR_CDESPE, GFR.GFR_DSESPE"
EndIf

cSql := "SELECT " + cGrpBy + ", " + ;
		"COUNT(*) qTotDisp, " + ;
		"SUM(Round(Cast(SubString(GM6.GM6_INTMAR, 1, 2) As Float) + " + ;
		"(Cast(SubString(GM6.GM6_INTMAR, 4, 2) As Float) / 60), 2)) hTotDisp, " + ;
		"SUM(CASE WHEN GM8.GM8_STATUS =  '0' THEN 1 ELSE 0 END) qTotLibe, " + ;
		"SUM(CASE WHEN GM8.GM8_STATUS =  '0' " + ;
		"THEN (Round(Cast(SubString(GM6.GM6_INTMAR, 1, 2) As Float) + " + ;
		"(Cast(SubString(GM6.GM6_INTMAR, 4, 2) As Float) / 60), 2)) " + ;
		"ELSE 0 END) hTotLibe, " + ;
		"SUM(CASE WHEN GM8.GM8_STATUS IN ('1', '5', '6') THEN 1 ELSE 0 END) qTotOcup, " + ;
		"SUM(CASE WHEN GM8.GM8_STATUS IN ('1', '5', '6') " + ;
		"THEN (Round(Cast(SubString(GM6.GM6_INTMAR, 1, 2) As Float) + " + ;
		"(Cast(SubString(GM6.GM6_INTMAR, 4, 2) As Float) / 60), 2)) " + ;
		"ELSE 0 END) hTotOcup, " + ;
		"SUM(CASE WHEN GM8.GM8_STATUS IN ('2', '4') THEN 1 ELSE 0 END) qTotBloq, " + ;
		"SUM(CASE WHEN GM8.GM8_STATUS IN ('2', '4') " + ;
		"THEN (Round(Cast(SubString(GM6.GM6_INTMAR, 1, 2) As Float) + " + ;
		"(Cast(SubString(GM6.GM6_INTMAR, 4, 2) As Float) / 60), 2)) " + ;
		"ELSE 0 END) hTotBloq, " + ;
		"SUM(CASE WHEN GM8.GM8_STATUS =  '3' THEN 1 ELSE 0 END) qTotAten, " + ;
		"SUM(CASE WHEN GM8.GM8_STATUS =  '3' " + ;
		"THEN (Round(Cast(SubString(GM6.GM6_INTMAR, 1, 2) As Float) + " + ;
		"(Cast(SubString(GM6.GM6_INTMAR, 4, 2) As Float) / 60), 2)) " + ;
		"ELSE 0 END) hTotAten " + ;
		"FROM " + RetSqlName("GM8") + " GM8 " + ; // 		//"JOIN " + RetSqlName("SRA") + " SRA ON SRA.D_E_L_E_T_ <> '*' AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.RA_CODIGO  = GM8.GM8_CODCRM " + ;
		"JOIN " + RetSqlName("GM6") + " GM6 ON GM6.D_E_L_E_T_ <> '*' AND GM6.GM6_FILIAL = '" + xFilial("GM6") + "' AND GM6.GM6_CODDIS = GM8.GM8_CODDIS " + ;
		"JOIN " + RetSqlName("GBJ") + " GBJ ON GBJ.D_E_L_E_T_ <> '*' AND GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ.GBJ_CRM    = GM8.GM8_CODCRM " + ;
		"LEFT JOIN " + RetSqlName("GA7") + " GA7 ON GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.GA7_CODPRO = GM8.GM8_CODPRO " + ;
		"JOIN " + RetSqlName("GFR") + " GFR ON GFR.D_E_L_E_T_ <> '*' AND GFR.GFR_FILIAL = '" + xFilial("GFR") + "' AND GFR.GFR_CDESPE = (CASE WHEN GA7.GA7_CODESP = '  ' OR GA7.GA7_CODESP IS NULL THEN GBJ.GBJ_ESPEC1 ELSE GA7.GA7_CODESP END) " + ;
		"WHERE GM8.D_E_L_E_T_ <> '*' AND GM8.GM8_DATAGE BETWEEN '" + DToS(dDtIni) + "' AND '" + DToS(dDtFin) + "' " + ;
		IIf(!Empty(M->GM8_CODPRO), "AND GM8.GM8_CODPRO IN ('" + Space(Len(M->GM8_CODPRO)) + "', '" + M->GM8_CODPRO + "')", "") + " " + ;
		"GROUP BY " + cGrpBy

cSql := ChangeQuery(cSql)

If !Empty(__cSql) .And. cSql == __cSql
	Return(Nil)
	
Else
	__cSql := cSql
	
EndIf

TCQuery cSql New Alias "GM8TMP"

While !Eof()
	cSql := "SELECT COUNT(*) qAgdCanc, " + ;
	"SUM(Round(Cast(SubString(GM6.GM6_INTMAR, 1, 2) As Float) + " + ;
	"(Cast(SubString(GM6.GM6_INTMAR, 4, 2) As Float) / 60), 2)) hAgdCanc " + ;
	"FROM " + RetSqlName("GM9") + " GM9 " + ;
	"JOIN " + RetSqlName("GM6") + " GM6 ON GM6.D_E_L_E_T_ <> '*' AND GM6.GM6_FILIAL = '" + xFilial("GM6") + "' AND GM6.GM6_CODDIS = GM9.GM9_CODDIS " + ;
	"JOIN " + RetSqlName("GA7") + " GA7 ON GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.GA7_CODPRO = GM9.GM9_CODPRO " + ;
	"WHERE GM9.D_E_L_E_T_ <> '*' AND GM9.GM9_FILIAL = '" + xFilial("GM9") + "' AND " + ;
	IIf(lCrm, "GM9.GM9_CODCRM = '" + GM8TMP->GM8_CODCRM + "' AND ", "") + ;
	IIf(lEsp, "GA7.GA7_CODESP = '" + GM8TMP->GFR_CDESPE + "' AND ", "") + ;
	"GM9.GM9_DATAGE BETWEEN '" + DToS(dDtIni) + "' AND '" + DToS(dDtFin) + "'"
	
	cSql := ChangeQuery(cSql)
	
	TCQuery cSql New Alias "GM9TMP"
	
	cSql := "SELECT COUNT(*) qAgdTrnf, " + ;
	"SUM(Round(Cast(SubString(GM6.GM6_INTMAR, 1, 2) As Float) + " + ;
	"(Cast(SubString(GM6.GM6_INTMAR, 4, 2) As Float) / 60), 2)) hAgdTrnf " + ;
	"FROM " + RetSqlName("GMA") + " GMA " + ;
	"JOIN " + RetSqlName("GM6") + " GM6 ON GM6.D_E_L_E_T_ <> '*' AND GM6.GM6_FILIAL = '" + xFilial("GM6") + "' AND GM6.GM6_CODDIS = GMA.GMA_CODDIS " + ;
	"JOIN " + RetSqlName("GA7") + " GA7 ON GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.GA7_CODPRO = GMA.GMA_CODPRO " + ;
	"WHERE GMA.D_E_L_E_T_ <> '*' AND GMA.GMA_FILIAL = '" + xFilial("GMA") + "' AND " + ;
	IIf(lCrm, "GMA.GMA_CODCRM = '" + GM8TMP->GM8_CODCRM + "' AND ", "") + ;
	IIf(lEsp, "GA7.GA7_CODESP = '" + GM8TMP->GFR_CDESPE + "' AND ", "") + ;
	"GMA.GMA_DATAGE BETWEEN '" + DToS(dDtIni) + "' AND '" + DToS(dDtFin) + "'"
	
	cSql := ChangeQuery(cSql)
	
	TCQuery cSql New Alias "GMATMP"
	
	aAdd(aCAgdMes, {IIf(lCrm, HS_IniPadr("SRA", 11, GM8TMP->GM8_CODCRM, "RA_NOME"   ,, .F.), "Todos"), ; //aAdd(aCAgdMes, {IIf(lCrm, GM8TMP->RA_NOME, "Todos"), ;//HS_IniPadr("SRA", 11, GM8->GM8_CODCRM, "RA_NOME"   ,, .F.)
	IIf(lEsp, GM8TMP->GFR_DSESPE, "Todas"), ;
	GM8TMP->qTotDisp, ;
	StrZero(Int(GM8TMP->hTotDisp), 3) + ":" + StrZero((GM8TMP->hTotDisp - Int(GM8TMP->hTotDisp)) * 60, 2), ;
	GM8TMP->qTotLibe, ;
	StrZero(Int(GM8TMP->hTotLibe), 3) + ":" + StrZero((GM8TMP->hTotLibe - Int(GM8TMP->hTotLibe)) * 60, 2), ;
	GM8TMP->qTotOcup, ;
	StrZero(Int(GM8TMP->hTotOcup), 3) + ":" + StrZero((GM8TMP->hTotOcup - Int(GM8TMP->hTotOcup)) * 60, 2), ;
	GM8TMP->qTotBloq, ;
	StrZero(Int(GM8TMP->hTotBloq), 3) + ":" + StrZero((GM8TMP->hTotBloq - Int(GM8TMP->hTotBloq)) * 60, 2), ;
	GM8TMP->qTotAten, ;
	StrZero(Int(GM8TMP->hTotAten), 3) + ":" + StrZero((GM8TMP->hTotAten - Int(GM8TMP->hTotAten)) * 60, 2), ;
	GM9TMP->qAgdCanc, ;
	StrZero(Int(GM9TMP->hAgdCanc), 3) + ":" + StrZero((GM9TMP->hAgdCanc - Int(GM9TMP->hAgdCanc)) * 60, 2), ;
	GMATMP->qAgdTrnf, ;
	StrZero(Int(GMATMP->hAgdTrnf), 3) + ":" + StrZero((GMATMP->hAgdTrnf - Int(GMATMP->hAgdTrnf)) * 60, 2), ;
	(GM8TMP->qTotAten / GM8TMP->qTotDisp) * 100 , ; //GM8TMP->qTotOcup - GM8TMP->qTotAten, ;
	.F.})//"999:99",;	//StrZero(Int(GM8TMP->hTotOcup - GM8TMP->hTotAten), 3) + ":" + StrZero(((GM8TMP->hTotOcup - GM8TMP->hTotAten) - Int(GM8TMP->hTotOcup - GM8TMP->hTotAten)) * 60, 2), ;
	
	
	GM9TMP->(DBCloseArea())
	GMATMP->(DBCloseArea())
	
	DbSelectArea("GM8TMP")
	DBSkip()
End

DbCloseArea()

oGAgdMes:SetArray(aCAgdMes)
oGAgdMes:oBrowse:Refresh()

DbSelectArea(cAliasOld)

Return(Nil)
             

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFSChkBox  บAutor  ณMicrosiga           บ Data ณ  08/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FSChkBox(oCrm, lCrm, oEsp, lEsp)
 
 If !lCrm .And. !lEsp
  lCrm := .T.
 EndIf
 
 oCrm:Refresh()
 oEsp:Refresh()
 
Return(Nil)

User Function HSFUSVIG() 
Local aArea := GetArea()
Local dVigIni := CTOD("")   
Local dVigFim := CTOD("")
DbSelectArea("SCJ")
DbSetOrder(1)
If DBSeek(xFilial("SCJ") + ParamIxb[1]) .AND. HS_ExisDic({{"C", "CJ_DICLTRA"}},.F.)
	dVigIni := SCJ->CJ_DICLTRA
	dVigFim := SCJ->CJ_DFCLTRA
EndIf

RestArea(aArea)
Return({dVigIni, dVigFim})
