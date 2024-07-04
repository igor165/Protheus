#Include "Protheus.ch"
#Include "OFIOR580.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ OFIOR580 บ Autor ณ Andre Luis Almeida บ Data ณ  15/12/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descric  ณ Faturamento de OS por Cliente/Veiculo                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOR580()
Private dDIni := ctod("01/"+strzero(month(dDataBase),2)+"/"+strzero(year(dDataBase),4))
Private dDFin := dDataBase
Private cCCl1 := space(6)
Private cLCl1 := space(2)
Private cCCl2 := "999999"
Private cLCl2 := "99"
Private cStat := STR0006
Private aStat := { STR0006 , STR0007 , STR0003 }
Private lDat  := .t.
Private cDtas := STR0011
Private aDtas := { STR0011 , STR0012 }
Private cPla1 := space(8)
Private cPla2 := "ZZZ9999"
Private aValSer := {}
FS_Imprime()

return

Static Function FS_Imprime()
Private cDesc1	 := STR0001
Private cDesc2	 := ""
Private cDesc3	 := ""
Private cAlias	 := "VO1"
Private nLin 	 := 1
Private aReturn := { STR0004, 1,STR0005, 2, 2, 1, "",1 }
Private tamanho := "M"          // P/M/G
Private Limite  := 132          // 80/132/220
Private nCaracter := 15
Private aOrdem  := {}           // Ordem do Relatorio
Private cTitulo := STR0001
Private cabec1  := ""
Private cabec2  := ""
Private nomeprog:= "OFIOR580"
Private nLastKey:= 0
Private cPerg   := "OFR580"
Private M_PAG   := 1

ValidPerg()
pergunte(cPerg,.F.)


nomeprog := SetPrint(cAlias,nomeprog,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,tamanho)

If nLastKey == 27
	Return
EndIf
if MV_PAR01 == 1
	cDtas := STR0011
	lDat:=.t.
else
	cDtas := STR0012
	lDat:=.f.
endif
dDIni := MV_PAR02
dDFin := MV_PAR03

if MV_PAR04 == 1
	cStat := STR0006
elseif  MV_PAR04 == 2
	cStat := STR0007
else
	cStat := STR0003
endif

cCCl1 := MV_PAR05
cLCl1 := MV_PAR06
cCCl2 := MV_PAR07
cLCl2 := MV_PAR08
cPla1 := MV_PAR09
cPla2 := MV_PAR10

SetDefault(aReturn,cAlias)
RptStatus( { |lEnd| FS_ImpOR580(@lEnd,nomeprog,cAlias) } , cTitulo )
If aReturn[5] == 1
	OurSpool( nomeprog )
EndIf
Return

Static Function FS_ImpOR580()
Local cCond := ".f."
Local lImp  := .f.
Local nTip  := 0
Local cPos  := ""
Local aTot  := {}
Local nPos  := 0
Local ni    := 0
Local nj    := 0
Local aOSs  := {}
Local cPla  := ""
Local nVlrCPc := 0
Local nVlrPec := 0
Local nVlrCSr := 0
Local nVlrSer := 0

Set Printer to &nomeprog
Set Printer On
Set Device  to Printer

Aadd(aTot,{ "1" , STR0018 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , .t. } )
If lDat
	cCond := "dDIni <= VO1->VO1_DATABE .and. dDFin >= VO1->VO1_DATABE"
Else
	cCond := "dDIni <= VO1->VO1_DATABE"
EndIf
DbSelectArea("VO1")
DbSetOrder(5)
DbSeek( xFilial("VO1") + dtos(dDIni) , .t. )
SetRegua(RecCount()-RecNo())
While !Eof() .and. VO1->VO1_FILIAL == xFilial("VO1") .and. &cCond
	IncRegua()
	DbSelectArea("VV1")
	DbSetOrder(1)
	DbSeek(xFilial("VV1")+VO1->VO1_CHAINT)
	If ( Alltrim(cPla1) > Alltrim(VV1->VV1_PLAVEI) ) .or. ( Alltrim(cPla2) < Alltrim(VV1->VV1_PLAVEI) )
		DbSelectArea("VO1")
		DbSkip()
		Loop
	EndIf
	nVlrCPc := 0
	nVlrPec := 0
	nVlrCSr := 0
	nVlrSer := 0
	cPla := Transform(VV1->VV1_PLAVEI,"@R XXX-9999")
	aOSs := {}
	DbSelectArea("VO2")
	DbSetOrder(1)
	If DbSeek( xFilial("VO2") + VO1->VO1_NUMOSV )
		While !Eof() .and. VO2->VO2_FILIAL == xFilial("VO2") .and. VO2->VO2_NUMOSV == VO1->VO1_NUMOSV
			lImp := .f.
			DbSelectArea("VO3")
			DbSetOrder(1)
			DbSeek( xFilial("VO3") + VO2->VO2_NOSNUM )
			While !Eof() .and. VO3->VO3_FILIAL == xFilial("VO3") .and. VO3->VO3_NOSNUM == VO2->VO2_NOSNUM
				If !Empty(VO3->VO3_DATCAN)
					DbSelectArea("VO3")
					DbSkip()
					Loop
				EndIf
				If !Empty(VO3->VO3_FATPAR)
					If ( cCCl1+cLCl1 > VO3->VO3_FATPAR+VO3->VO3_LOJA ) .or. ( cCCl2+cLCl2 < VO3->VO3_FATPAR+VO3->VO3_LOJA )
						DbSelectArea("VO3")
						DbSkip()
						Loop
					EndIf
				Else
					If ( cCCl1+cLCl1 > VO1->VO1_PROVEI+VO1->VO1_LOJPRO ) .or. ( cCCl2+cLCl2 < VO1->VO1_PROVEI+VO1->VO1_LOJPRO )
						DbSelectArea("VO3")
						DbSkip()
						Loop
					EndIf
				EndIf
				lImp := .f.
				nVlrCPc := 0
				nVlrPec := If(VO2->VO2_DEVOLU=="0",-1,1) * ( VO3->VO3_VALPEC * VO3->VO3_QTDREQ )
				DbSelectArea("VZ1")
				DbSetOrder(3)
				If DbSeek( xFilial("VZ1") + VO1->VO1_NUMOSV + VO3->VO3_TIPTEM + "P" + VO3->VO3_GRUITE + VO3->VO3_CODITE )
					If VZ1->VZ1_VALDES > 0
						nVlrPec := If(VO2->VO2_DEVOLU=="0",-1,1) * ( ( VO3->VO3_VALPEC * VO3->VO3_QTDREQ ) - VZ1->VZ1_VALDES )
					ElseIf VZ1->VZ1_VALBRU > 0
						nVlrPec := If(VO2->VO2_DEVOLU=="0",-1,1) * VZ1->VZ1_VALBRU
					EndIf
				EndIf
				If cStat == STR0006
					If !Empty(VO3->VO3_DATFEC) .and. ( ( dDIni <= VO3->VO3_DATFEC .and. dDFin >= VO3->VO3_DATFEC ) .or. lDat )
						lImp := .t.
						DbSelectArea("VEC")
						DbSetOrder(5)
						If DbSeek( xFilial("VEC") + VO1->VO1_NUMOSV + VO3->VO3_TIPTEM + VO3->VO3_GRUITE + VO3->VO3_CODITE )
							DbSelectArea("VOI")
							DbSetOrder(1)
							DbSeek( xFilial("VOI") + VO3->VO3_TIPTEM )
							If VOI->VOI_SITTPO == "3"
								nVlrPec := ( VEC->VEC_CUSTOT / VEC->VEC_QTDITE ) * VO3->VO3_QTDREQ * If(VO2->VO2_DEVOLU=="0",-1,1)
							Else
								nVlrPec := ( VEC->VEC_VALVDA / VEC->VEC_QTDITE ) * VO3->VO3_QTDREQ * If(VO2->VO2_DEVOLU=="0",-1,1)
							EndIf
						EndIf
					EndIf
				ElseIf cStat == STR0007
					If Empty(VO3->VO3_DATFEC)
						If !Empty(VO3->VO3_DATDIS) .and. ( ( dDIni <= VO3->VO3_DATDIS .and. dDFin >= VO3->VO3_DATDIS ) .or. lDat )
							lImp := .t.
						EndIf
					EndIf
				ElseIf cStat == STR0003
					If !Empty(VO3->VO3_DATFEC) .and. ( ( dDIni <= VO3->VO3_DATFEC .and. dDFin >= VO3->VO3_DATFEC ) .or. lDat )
						lImp := .t.
						DbSelectArea("VEC")
						DbSetOrder(5)
						If DbSeek( xFilial("VEC") + VO1->VO1_NUMOSV + VO3->VO3_TIPTEM + VO3->VO3_GRUITE + VO3->VO3_CODITE )
							DbSelectArea("VOI")
							DbSetOrder(1)
							DbSeek( xFilial("VOI") + VO3->VO3_TIPTEM )
							If VOI->VOI_SITTPO == "3"
								nVlrPec := ( VEC->VEC_CUSTOT / VEC->VEC_QTDITE ) * VO3->VO3_QTDREQ * If(VO2->VO2_DEVOLU=="0",-1,1)
							Else
								nVlrPec := ( VEC->VEC_VALVDA / VEC->VEC_QTDITE ) * VO3->VO3_QTDREQ * If(VO2->VO2_DEVOLU=="0",-1,1)
							EndIf
						EndIf
					ElseIf !Empty(VO3->VO3_DATDIS) .and. ( ( dDIni <= VO3->VO3_DATDIS .and. dDFin >= VO3->VO3_DATDIS ) .or. lDat )
						lImp := .t.
					EndIf
				EndIf
				If ( ( cStat == STR0007 .or. cStat == STR0003 ) .and. !lImp .and. dDFin >= VO1->VO1_DATABE )
					If Empty(VO3->VO3_DATFEC) .and. Empty(VO3->VO3_DATDIS)
						lImp := .t.
					EndIf
				EndIf
				If lImp
					nPos := aScan(aOSs,{|x| x[1]+x[2] == VO1->VO1_NUMOSV + VO3->VO3_TIPTEM })
					If nPos == 0
						Aadd(aOSs,{ VO1->VO1_NUMOSV , VO3->VO3_TIPTEM , If(!Empty(VO3->VO3_FATPAR),VO3->VO3_FATPAR+VO3->VO3_LOJA,VO1->VO1_PROVEI+VO1->VO1_LOJPRO) , nVlrCPc , nVlrPec , 0 , 0 } )
					Else
						aOSs[nPos,4] += nVlrCPc
						aOSs[nPos,5] += nVlrPec
					EndIf
				EndIf
				DbSelectArea("VO3")
				DbSkip()
			EndDo
			DbSelectArea("VO4")
			DbSetOrder(1)
			DbSeek( xFilial("VO4") + VO2->VO2_NOSNUM )
			While !Eof() .and. VO4->VO4_FILIAL == xFilial("VO4") .and. VO4->VO4_NOSNUM == VO2->VO2_NOSNUM
				If !Empty(VO4->VO4_DATCAN)
					DbSelectArea("VO4")
					DbSkip()
					Loop
				EndIf
				If !Empty(VO4->VO4_FATPAR)
					If ( cCCl1+cLCl1 > VO4->VO4_FATPAR+VO4->VO4_LOJA ) .or. ( cCCl2+cLCl2 < VO4->VO4_FATPAR+VO4->VO4_LOJA )
						DbSelectArea("VO4")
						DbSkip()
						Loop
					EndIf
				Else
					If ( cCCl1+cLCl1 > VO1->VO1_PROVEI+VO1->VO1_LOJPRO ) .or. ( cCCl2+cLCl2 < VO1->VO1_PROVEI+VO1->VO1_LOJPRO )
						DbSelectArea("VO4")
						DbSkip()
						Loop
					EndIf
				EndIf
				DbSelectArea("VO6")
				DbSetOrder(2)
				DbSeek( xFilial("VO6") + VV1->VV1_CODMAR + VO4->VO4_CODSER )
				DbSelectArea("VOK")
				DbSetOrder(1)
				DbSeek( xFilial("VOK") + VO4->VO4_TIPSER )
				DbSelectArea("VOI")
				DbSetOrder(1)
				DbSeek( xFilial("VOI") + VO4->VO4_TIPTEM )
				lImp := .f.
				aValSer := {}
				If !Empty(VO4->VO4_DATFEC)
					DbSelectArea("VSC")
					DbSetOrder(1)
					If DbSeek( xFilial("VSC") + VO1->VO1_NUMOSV + VO4->VO4_TIPTEM + VO4->VO4_CODSER )
						While !Eof() .and. VSC->VSC_FILIAL == xFilial("VSC") .and. ( ( VSC->VSC_NUMOSV + VSC->VSC_TIPTEM + VSC->VSC_CODSER ) == ( VO1->VO1_NUMOSV + VO4->VO4_TIPTEM + VO4->VO4_CODSER ) )
							aValSer := {}
							aValSer := FG_CALVLSER( aValSer , VO4->VO4_TIPTEM+VO4->VO4_TIPSER+VO4->VO4_CODSER , "F" )
							If strzero(VO4->(RecNo()),9) == VSC->VSC_RECVO4
								Exit
							EndIf
							DbSelectArea("VSC")
							DbSkip()
						EndDo
					Else
						aValSer := FG_CALVLSER( aValSer , VO4->VO4_TIPTEM+VO4->VO4_TIPSER+VO4->VO4_CODSER , "A" )
					EndIf
				Else
					aValSer := FG_CALVLSER( aValSer , VO4->VO4_TIPTEM+VO4->VO4_TIPSER+VO4->VO4_CODSER , "A" )
				EndIf
				If VOI->VOI_SITTPO == "3"
					//						If aValSer[6]  // se nao foi somado soma
					aValSer[1] := ( ( aValSer[2] / 100 ) * FG_ValHor(VO4->VO4_TIPTEM,VO1->VO1_DATABE) )
					//						EndIf
				EndIf
				DbSelectArea("VZ1")
				DbSetOrder(4)
				If DbSeek( xFilial("VZ1") + VO1->VO1_NUMOSV + VO4->VO4_TIPTEM + "S" + VO4->VO4_GRUSER + VO4->VO4_CODSER )
					If VZ1->VZ1_VALDES > 0
						aValSer[1] -= VZ1->VZ1_VALDES
					ElseIf VZ1->VZ1_VALBRU > 0
						aValSer[1] := VZ1->VZ1_VALBRU
					EndIf
				EndIf
				If !aValSer[6]  // Nao soma se ja foi somado anteriormente
					aValSer[1] := 0
				EndIf
				If !( VOK->VOK_INCMOB == "0" .and. VOK->VOK_TIPHOR == "2" )
					nVlrCSr := 0
					nVlrSer := aValSer[1]
				Else
					If aValSer[1] > 0
						nVlrCSr := aValSer[1]
					Else
						nVlrCSr := ( ( VO4->VO4_TEMPAD * VO4->VO4_VALHOR ) / 100 )
					EndIf
					nVlrSer := 0
				EndIf
				If cStat == STR0006
					If !Empty(VO4->VO4_DATFEC) .and. ( ( dDIni <= VO4->VO4_DATFEC .and. dDFin >= VO4->VO4_DATFEC ) .or. lDat )
						lImp := .t.
					EndIf
				ElseIf cStat == STR0007
					If Empty(VO4->VO4_DATFEC)
						If !Empty(VO4->VO4_DATDIS) .and. ( ( dDIni <= VO4->VO4_DATDIS .and. dDFin >= VO4->VO4_DATDIS ) .or. lDat )
							lImp := .t.
						EndIf
					EndIf
				ElseIf cStat == STR0003
					If !Empty(VO4->VO4_DATFEC) .and. ( ( dDIni <= VO4->VO4_DATFEC .and. dDFin >= VO4->VO4_DATFEC ) .or. lDat )
						lImp := .t.
					ElseIf !Empty(VO4->VO4_DATDIS) .and. ( ( dDIni <= VO4->VO4_DATDIS .and. dDFin >= VO4->VO4_DATDIS ) .or. lDat )
						lImp := .t.
					EndIf
				EndIf
				If ( ( cStat == STR0007 .or. cStat == STR0003 ) .and. !lImp .and. dDFin >= VO1->VO1_DATABE )
					If Empty(VO4->VO4_DATFEC) .and. Empty(VO4->VO4_DATDIS)
						lImp := .t.
					EndIf
				EndIf
				If lImp
					nPos := aScan(aOSs,{|x| x[1]+x[2] == VO1->VO1_NUMOSV + VO4->VO4_TIPTEM })
					If nPos == 0
						Aadd(aOSs,{ VO1->VO1_NUMOSV , VO4->VO4_TIPTEM , If(!Empty(VO4->VO4_FATPAR),VO4->VO4_FATPAR+VO4->VO4_LOJA,VO1->VO1_PROVEI+VO1->VO1_LOJPRO) , 0 , 0 , nVlrCSr , nVlrSer } )
					Else
						aOSs[nPos,6] += nVlrCSr
						aOSs[nPos,7] += nVlrSer
					EndIf
				EndIf
				DbSelectArea("VO4")
				DbSkip()
			EndDo
			DbSelectArea("VO2")
			DbSkip()
		EndDo
	Else
		If ( cCCl1+cLCl1 > VO1->VO1_PROVEI+VO1->VO1_LOJPRO ) .or. ( cCCl2+cLCl2 < VO1->VO1_PROVEI+VO1->VO1_LOJPRO )
			DbSelectArea("VO1")
			DbSkip()
			Loop
		EndIf
		If dDFin >= VO1->VO1_DATABE
			nVlrCPc := 0
			nVlrPec := 0
			nVlrCSr := 0
			nVlrSer := 0
			nPos := aScan(aOSs,{|x| x[1]+x[2] == VO1->VO1_NUMOSV + "!" })
			If nPos == 0
				Aadd(aOSs,{ VO1->VO1_NUMOSV , "!" , VO1->VO1_PROVEI+VO1->VO1_LOJPRO , 0 , 0 , 0 , 0 } )
			EndIf
		EndIf
	EndIf
	For nTip := 1 to len(aOSs)
		nVlrCPc := aOSs[nTip,4]
		nVlrPec := aOSs[nTip,5]
		nVlrCSr := aOSs[nTip,6]
		nVlrSer := aOSs[nTip,7]
		nPCli := 1
		nPVei := 1
		aTot[1,6] += nVlrCPc
		aTot[1,7] += nVlrPec
		aTot[1,8] += nVlrCSr
		aTot[1,9] += nVlrSer
		cPos := aOSs[nTip,3]
		nPos := 0
		nPos := aScan(aTot,{|x| x[1] == "2"+cPos })
		If nPos == 0
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + cPos )
			Aadd(aTot,{ "2"+cPos , substr(cPos,1,6)+"-"+substr(cPos,7,2)+" "+left(SA1->A1_NOME,40) , 0 , 0 , 0 , nVlrCPc , nVlrPec , nVlrCSr , nVlrSer , .t. } )
			aTot[1,3]++
			nPCli := len(aTot)
		Else
			nPCli := nPos
			aTot[nPos,6] += nVlrCPc
			aTot[nPos,7] += nVlrPec
			aTot[nPos,8] += nVlrCSr
			aTot[nPos,9] += nVlrSer
		EndIf
		cPos := "2"+aOSs[nTip,3]+cPla
		nPos := 0
		nPos := aScan(aTot,{|x| x[1] == cPos })
		If nPos == 0
			Aadd(aTot,{ cPos , space(3)+STR0017+": "+cPla , 0 , 0 , 0 , nVlrCPc , nVlrPec , nVlrCSr , nVlrSer , .t. } )
			aTot[1,4]++
			aTot[nPCli,4]++
			nPVei := len(aTot)
		Else
			nPVei := nPos
			aTot[nPos,6] += nVlrCPc
			aTot[nPos,7] += nVlrPec
			aTot[nPos,8] += nVlrCSr
			aTot[nPos,9] += nVlrSer
		EndIf
		cPos := "2"+aOSs[nTip,3]+cPla+aOSs[nTip,1]
		nPos := 0
		nPos := aScan(aTot,{|x| x[1] == cPos })
		If nPos == 0
			Aadd(aTot,{ cPos , space(6)+STR0022+aOSs[nTip,1] , 0 , 0 , 0 , nVlrCPc , nVlrPec , nVlrCSr , nVlrSer , .f. } )
			aTot[1,5]++
			aTot[nPCli,5]++
			aTot[nPVei,5]++
		Else
			aTot[nPos,6] += nVlrCPc
			aTot[nPos,7] += nVlrPec
			aTot[nPos,8] += nVlrCSr
			aTot[nPos,9] += nVlrSer
		EndIf
	Next
	DbSelectArea("VO1")
	DbSkip()
EndDo
DbSelectArea("VS1")
DbSetOrder(8)
DbSeek( xFilial("VS1") + dtos(dDIni) , .t. )
SetRegua(RecCount()-RecNo())
While !Eof() .and. VS1->VS1_FILIAL == xFilial("VS1") .and. dDIni <= VS1->VS1_DATORC .and. dDFin >= VS1->VS1_DATORC
	IncRegua()
	If VS1->VS1_NOROUT # "2"
		DbSelectArea("VS1")
		DbSkip()
		Loop
	EndIf
	If ( cCCl1+cLCl1 > VS1->VS1_CLIFAT+VS1->VS1_LOJA ) .or. ( cCCl2+cLCl2 < VS1->VS1_CLIFAT+VS1->VS1_LOJA )
		DbSelectArea("VS1")
		DbSkip()
		Loop
	EndIf
	If cStat # STR0003
		If cStat == STR0006 .and. Empty(VS1->VS1_NUMNFI)
			DbSelectArea("VS1")
			DbSkip()
			Loop
		ElseIf cStat == STR0007 .and. !Empty(VS1->VS1_NUMNFI)
			DbSelectArea("VS1")
			DbSkip()
			Loop
		EndIf
	EndIf
	DbSelectArea("VV1")
	DbSetOrder(1)
	DbSeek(xFilial("VV1")+VS1->VS1_CHAINT)
	If ( Alltrim(cPla1) > Alltrim(VV1->VV1_PLAVEI) ) .or. ( Alltrim(cPla2) < Alltrim(VV1->VV1_PLAVEI) )
		DbSelectArea("VS1")
		DbSkip()
		Loop
	EndIf
	cPla := Transform(VV1->VV1_PLAVEI,"@R XXX-9999")
	nVlrCPc := 0
	DbSelectArea("VS3")
	DbSetOrder(1)
	DbSeek( xFilial("VS3") + VS1->VS1_NUMORC )
	While !Eof() .and. VS3->VS3_FILIAL == xFilial("VS3") .and. VS3->VS3_NUMORC == VS1->VS1_NUMORC
		DbSelectArea("SF4")
		DbSetOrder(1)
		DbSeek( xFilial("SF4") + VS3->VS3_CODTES )
		If SF4->F4_ESTOQUE == "S" .and. SF4->F4_ICM == "N" .and. SF4->F4_CREDICM == "N" .and. SF4->F4_DUPLIC == "N"
			nVlrCPc += VS3->VS3_VALTOT
		EndIf
		DbSelectArea("VS3")
		DbSkip()
	EndDo
	If nVlrCPc > 0
		nPCli := 1
		nPVei := 1
		aTot[1,6] += nVlrCPc
		cPos := VS1->VS1_CLIFAT+VS1->VS1_LOJA
		nPos := 0
		nPos := aScan(aTot,{|x| x[1] == "2"+cPos })
		If nPos == 0
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + cPos )
			Aadd(aTot,{ "2"+cPos , substr(cPos,1,6)+"-"+substr(cPos,7,2)+" "+left(SA1->A1_NOME,40) , 0 , 0 , 0 , nVlrCPc , 0 , 0 , 0 , .t. } )
			aTot[1,3]++
			nPCli := len(aTot)
		Else
			nPCli := nPos
			aTot[nPos,6] += nVlrCPc
		EndIf
		cPos := "2"+VS1->VS1_CLIFAT+VS1->VS1_LOJA+cPla
		nPos := 0
		nPos := aScan(aTot,{|x| x[1] == cPos })
		If nPos == 0
			Aadd(aTot,{ cPos , space(3)+STR0017+": "+cPla , 0 , 0 , 0 , nVlrCPc , 0 , 0 , 0 , .t. } )
			aTot[1,4]++
			aTot[nPCli,4]++
			nPVei := len(aTot)
		Else
			nPVei := nPos
			aTot[nPos,6] += nVlrCPc
		EndIf
		cPos := "2"+VS1->VS1_CLIFAT+VS1->VS1_LOJA+cPla+VS1->VS1_NUMORC
		nPos := 0
		nPos := aScan(aTot,{|x| x[1] == cPos })
		If nPos == 0
			Aadd(aTot,{ cPos , space(6)+STR0023+VS1->VS1_NUMORC , 0 , 0 , 0 , nVlrCPc , 0 , 0 , 0 , .f. } )
			aTot[1,5]++
			aTot[nPCli,5]++
			aTot[nPVei,5]++
		Else
			aTot[nPos,6] += nVlrCPc
		EndIf
	EndIf
	DbSelectArea("VS1")
	DbSkip()
EndDo

aSort(aTot,1,,{|x,y| x[1] < y[1] })

nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
/*	nLin++
@ nLin++ , 40 psay STR0021
@ nLin++ , 41 psay left(Alltrim(STR0013)+repl(".",14),14)+": "+cDtas+" "+STR0019+" "+Transform(dDIni,"@D")+" "+STR0020+" "+Transform(dDFin,"@D")
@ nLin++ , 41 psay left(Alltrim(STR0014)+repl(".",14),14)+": "+cStat
@ nLin++ , 41 psay left(Alltrim(STR0015)+repl(".",14),14)+": "+STR0019+" "+cCCl1+"-"+cLCl1+" "+STR0020+" "+cCCl2+"-"+cLCl2
@ nLin++ , 41 psay left(Alltrim(STR0017)+repl(".",14),14)+": "+STR0019+" "+Transform(cPla1,"@R XXX-9999") +" "+STR0020+" "+ Transform(cPla2,"@R XXX-9999")
@ nLin++ , 40 psay repl("-",len(STR0021))
*/	nLin++
@ nLin++ , 00 psay repl("-",39)+" "+left(STR0008+repl("-",21),21)+" "+left(STR0009+repl("-",69),69)
@ nLin++ , 00 psay left(STR0002+space(39),39)+" "+left(STR0010+space(21),21)+" "+left(STR0016+space(69),69)
@ nLin++ , 00 psay repl("-",39)+" "+repl("-",21)+" "+repl("-",69)
For ni := 1 to len(aTot)
	If nLin >= 55
		nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
		nLin++
		@ nLin++ , 00 psay repl("-",39)+" "+left(STR0008+repl("-",21),21)+" "+left(STR0009+repl("-",69),69)
		@ nLin++ , 00 psay left(STR0002+space(39),39)+" "+left(STR0010+space(21),21)+" "+left(STR0016+space(69),69)
		@ nLin++ , 00 psay repl("-",39)+" "+repl("-",21)+" "+repl("-",69)
		nLin++
	EndIf
	If aTot[ni,10]
		nLin++
	EndIf
	@ nLin++ , 00 psay left(aTot[ni,2]+space(40),40)+If(aTot[ni,3]>0,Transform(aTot[ni,3],"@E 999,999"),space(7))+If(aTot[ni,4]>0,Transform(aTot[ni,4],"@E 999,999"),space(7))+If(aTot[ni,5]>0,Transform(aTot[ni,5],"@E 999,999"),space(7))+Transform(aTot[ni,6],"@E 999,999,999.99")+Transform(aTot[ni,7],"@E 999,999,999.99")+Transform(aTot[ni,8],"@E 999,999,999.99")+Transform(aTot[ni,9],"@E 999,999,999.99")+Transform(aTot[ni,7]+aTot[ni,9],"@E 999,999,999.99")
Next

Ms_Flush()
Set Printer to
Set Device  to Screen

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณVALIDPERG บ Autor ณ Ricardo Farinelli  บ Data ณ  05/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidPerg

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)  
cPerg := left(cPerg+space(15),len(X1_GRUPO))

Aadd(aRegs,{cPerg,"01",STR0013,             "","","mv_ch1","N",1,0,0,"C","","mv_par01",STR0011,"","","","",STR0012,"","","","","",     "","","","","","","","","","","","","","",   ""}) //"Tipo Operacao     ?"###"Venda"###"Devolucao"###"Todas"
aAdd(aRegs,{cPerg,"02",STR0024,             "","","mv_ch2","D",8,0,0,"G","","mv_par02","",     "","","","","",     "","","","","",     "","","","","","","","","","","","","","",   ""}) //data inicial
aAdd(aRegs,{cPerg,"03",STR0025,             "","","mv_ch3","D",8,0,0,"G","","mv_par03","",     "","","","","",     "","","","","",     "","","","","","","","","","","","","","",   ""}) //data final
Aadd(aRegs,{cPerg,"04",STR0014,             "","","mv_ch4","N",1,0,0,"C","","mv_par04",STR0006,"","","","",STR0007,"","","","",STR0003,"","","","","","","","","","","","","","",   ""}) //"Tipo Operacao     ?"###"Venda"###"Devolucao"###"Todas"
Aadd(aRegs,{cPerg,"05",STR0015+":"+STR0019, "","","mv_ch5","C",6,0,0,"G","","mv_par05","",     "","","","","",     "","","","","",     "","","","","","","","","","","","","","SA1",""}) //"Proprietario      ?"
Aadd(aRegs,{cPerg,"06",STR0026+":"+STR0019, "","","mv_ch6","C",2,0,0,"G","","mv_par06","",     "","","","","",     "","","","","",     "","","","","","","","","","","","","","",   ""}) //"Loja              ?"
Aadd(aRegs,{cPerg,"07",STR0015+":"+STR0020, "","","mv_ch7","C",6,0,0,"G","","mv_par07","",     "","","","","",     "","","","","",     "","","","","","","","","","","","","","SA1",""}) //"Proprietario      ?"
Aadd(aRegs,{cPerg,"08",STR0026+":"+STR0020, "","","mv_ch8","C",2,0,0,"G","","mv_par08","",     "","","","","",     "","","","","",     "","","","","","","","","","","","","","",   ""}) //"Loja              ?"
Aadd(aRegs,{cPerg,"09",STR0017+":"+STR0019, "","","mv_ch9","C",7,0,0,"C","","mv_par09","",     "","","","","",     "","","","","",     "","","","","","","","","","","","","","",   ""}) //"Tipo Operacao     ?"###"Venda"###"Devolucao"###"Todas"
Aadd(aRegs,{cPerg,"10",STR0017+":"+STR0020, "","","mv_cha","C",7,0,0,"C","","mv_par10","",     "","","","","",     "","","","","",     "","","","","","","","","","","","","","",   ""}) //"Tipo Operacao     ?"###"Venda"###"Devolucao"###"Todas"

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)
Return

