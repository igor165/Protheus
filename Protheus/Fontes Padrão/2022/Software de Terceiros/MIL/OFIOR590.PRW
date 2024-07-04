#Include "Protheus.ch"
#Include "OFIOR590.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ OFIOR590 บ Autor ณ Andre Luis Almeida บ Data ณ  15/12/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descric  ณ Relacao de OS por Qtde/Status/Cliente/Produtivo            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOR590()
Local lRet := .f.
Private dDIni := ctod("01/"+strzero(month(dDataBase),2)+"/"+strzero(year(dDataBase),4))
Private dDFin := dDataBase
Private cCCl1 := space(6)
Private cLCl1 := space(2)
Private cCCl2 := "999999"
Private cLCl2 := "99"
Private cProd := space(6)
Private cStat := STR0003
Private aStat := { STR0003 , STR0004 , STR0005 , STR0006 , STR0007 }
Private cPor1 := STR0002
Private aPor1 := { STR0002 , STR0008 , STR0009 }
Private cPor2 := " "
Private aPor2 := { " " , STR0010 , STR0008 , STR0009 }
Private lP    := .f.
Private lDat  := .t.
Private cDtas := STR0011
Private aDtas := { STR0011 , STR0012 }
Private cPla1 := space(8)
Private cPla2 := "ZZZ9999"
Private aValSer := {}
DEFINE MSDIALOG oRELOSs FROM 000,000 TO 012,49 TITLE STR0001 OF oMainWnd
	@ 010,010 SAY (STR0013+":") SIZE 40,08 OF oRELOSs PIXEL COLOR CLR_BLUE
  	@ 009,045 MSCOMBOBOX oDtas VAR cDtas ITEMS aDtas VALID ( .t. .or. If(cDtas==STR0011,lDat:=.t.,lDat:=.f.)) SIZE 48,08 OF oRELOSs PIXEL
	@ 010,094 SAY (STR0019) SIZE 40,08 OF oRELOSs PIXEL COLOR CLR_BLUE
  	@ 009,102 MSGET oDIni VAR dDIni PICTURE "@D" SIZE 35,08 OF oRELOSs PIXEL COLOR CLR_BLACK
	@ 010,139 SAY (STR0020) SIZE 40,08 OF oRELOSs PIXEL COLOR CLR_BLUE
  	@ 009,150 MSGET oDFin VAR dDFin PICTURE "@D" SIZE 35,08 OF oRELOSs PIXEL COLOR CLR_BLACK
	@ 020,010 SAY (STR0014+":") SIZE 40,08 OF oRELOSs PIXEL COLOR CLR_BLUE
  	@ 019,045 MSCOMBOBOX oStat VAR cStat ITEMS aStat SIZE 45,08 OF oRELOSs PIXEL
	@ 030,010 SAY (STR0008+": "+STR0019) SIZE 40,08 OF oRELOSs PIXEL COLOR CLR_BLUE
  	@ 029,045 MSGET oCCl1 VAR cCCl1 PICTURE "999999" F3 "SA1" SIZE 35,08 OF oRELOSs PIXEL COLOR CLR_BLACK
  	@ 029,080 MSGET oLCl1 VAR cLCl1 PICTURE "99" SIZE 15,08 OF oRELOSs PIXEL COLOR CLR_BLACK
	@ 030,098 SAY (STR0020) SIZE 40,08 OF oRELOSs PIXEL COLOR CLR_BLUE
  	@ 029,110 MSGET oCCl2 VAR cCCl2 PICTURE "999999" F3 "SA1" SIZE 35,08 OF oRELOSs PIXEL COLOR CLR_BLACK
  	@ 029,145 MSGET oLCl2 VAR cLCl2 PICTURE "99" SIZE 15,08 OF oRELOSs PIXEL COLOR CLR_BLACK
	@ 040,010 SAY (STR0009+":") SIZE 40,08 OF oRELOSs PIXEL COLOR CLR_BLUE
  	@ 039,045 MSGET oProd VAR cProd PICTURE "999999" F3 "VAI" SIZE 35,08 OF oRELOSs PIXEL COLOR CLR_BLACK
	@ 050,010 SAY (STR0017+": "+STR0019) SIZE 40,08 OF oRELOSs PIXEL COLOR CLR_BLUE
  	@ 049,045 MSGET oPla1 VAR cPla1 PICTURE "@R XXX-9999" SIZE 35,08 OF oRELOSs PIXEL COLOR CLR_BLACK
	@ 050,083 SAY (STR0020) SIZE 40,08 OF oRELOSs PIXEL COLOR CLR_BLUE
  	@ 049,096 MSGET oPla2 VAR cPla2 PICTURE "@R XXX-9999" SIZE 35,08 OF oRELOSs PIXEL COLOR CLR_BLACK
	@ 060,010 SAY (STR0018+":") SIZE 40,08 OF oRELOSs PIXEL COLOR CLR_BLUE
  	@ 059,045 MSCOMBOBOX oPor1 VAR cPor1 ITEMS aPor1 ON CHANGE (oPor2:Disable(),FS_QUEBRAPOR()) VALID (oPor2:SetFocus()) SIZE 45,08 OF oRELOSs PIXEL 
	@ 060,091 SAY "+" SIZE 40,08 OF oRELOSs PIXEL COLOR CLR_BLUE
  	@ 059,096 MSCOMBOBOX oPor2 VAR cPor2 ITEMS aPor2 SIZE 45,08 OF oRELOSs PIXEL
	DEFINE SBUTTON FROM 074,050 TYPE 1 ACTION (lRet:=.t.,oRELOSs:End()) ENABLE OF oRELOSs
	DEFINE SBUTTON FROM 074,115 TYPE 2 ACTION (oRELOSs:End()) ENABLE OF oRELOSs
  	@ 003,003 TO 088,191 LABEL "" OF oRELOSs PIXEL // Caixa
ACTIVATE MSDIALOG oRELOSs CENTER 
If lRet
   FS_Imprime()
EndIf
Return  

Static Function FS_QUEBRAPOR()
	cPor2 := " "
	aPor2 := {}
	If cPor1 == STR0002
		aPor2 := { " " , STR0010 , STR0008 , STR0009 }
	ElseIf cPor1 == STR0008
		aPor2 := { " " , STR0002 , STR0010 , STR0009 }
	ElseIf cPor1 == STR0009
		aPor2 := { " " , STR0002 , STR0010 , STR0008 }
	EndIf        
	@ 059,096 MSCOMBOBOX oPor2 VAR cPor2 ITEMS aPor2 SIZE 45,08 OF oRELOSs PIXEL
   oPor2:SetFocus()
   oPor2:Refresh()
Return

Static Function FS_Imprime()   
Private cDesc1	 := STR0001
Private cDesc2	 := ""                
Private cDesc3	 := ""
Private cAlias	 := "VO1"                        
Private nLin 	 := 1
Private aReturn := { STR0022, 1,STR0023, 2, 2, 1, "",1 }
Private tamanho := "P"          // P/M/G
Private Limite  := 80          // 80/132/220
Private nCaracter := 18
Private aOrdem  := {}           // Ordem do Relatorio
Private cTitulo := STR0001
Private cabec1  := ""
Private cabec2  := ""
Private nomeprog:= "OFIOR590"
Private nLastKey:= 0                       
Private cPerg   := nil
Private M_PAG   := 1
If cPor2 == STR0010
	lP      := .t.
	tamanho := "M"
	Limite  := 132
	nCaracter := 15
EndIf
nomeprog := SetPrint(cAlias,nomeprog,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,tamanho)
If nLastKey == 27
	Return
EndIf     
SetDefault(aReturn,cAlias)
RptStatus( { |lEnd| FS_ImpOR590(@lEnd,nomeprog,cAlias) } , cTitulo )
If aReturn[5] == 1
   OurSpool( nomeprog )
EndIf
Return

Static Function FS_ImpOR590()
	Local cCond := ".f."
	Local lImp  := .t.
	Local nTip  := 0 
	Local cTip  := ""
	Local cPos  := ""
	Local aTot  := {}
	Local aGrp  := {}
	Local cPro  := ""
	Local nPos  := 0
	Local ni    := 0
	Local nj    := 0
	Local aOSs  := {}
	Local aRes  := {}
	Local nRes  := 0
	Local cDat  := ""
	Local cPla  := ""
	Local nVlr  := 0
	Local nFun  := 0
		
	Set Printer to &nomeprog
	Set Printer On
	Set Device  to Printer   
	
	Aadd(aTot,{ " " , STR0026 , 0 , 0 } )
	If cStat == STR0004 .or. lDat
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
		nVlr := 0
		cPla := Transform(VV1->VV1_PLAVEI,"@R XXX-9999")
		aOSs := {}
		cPro := " "
		nFun := 0
		DbSelectArea("VO2")
		DbSetOrder(1)
		If DbSeek( xFilial("VO2") + VO1->VO1_NUMOSV )
			While !Eof() .and. VO2->VO2_FILIAL == xFilial("VO2") .and. VO2->VO2_NUMOSV == VO1->VO1_NUMOSV
				DbSelectArea("VO3")
				DbSetOrder(1)
				DbSeek( xFilial("VO3") + VO2->VO2_NOSNUM )
				While !Eof() .and. VO3->VO3_FILIAL == xFilial("VO3") .and. VO3->VO3_NOSNUM == VO2->VO2_NOSNUM
					cPro := VO3->VO3_PROREQ
					If !Empty(Alltrim(cProd)) .and. cProd # cPro
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
					lImp := .t.
					cTip := ""   
					nVlr := If(VO2->VO2_DEVOLU=="0",-1,1) * ( VO3->VO3_VALPEC * VO3->VO3_QTDREQ )
					DbSelectArea("VZ1") 
					DbSetOrder(3)
					If DbSeek( xFilial("VZ1") + VO1->VO1_NUMOSV + VO3->VO3_TIPTEM + "P" + VO3->VO3_GRUITE + VO3->VO3_CODITE )
						If VZ1->VZ1_VALDES > 0
							nVlr := If(VO2->VO2_DEVOLU=="0",-1,1) * ( ( VO3->VO3_VALPEC * VO3->VO3_QTDREQ ) - VZ1->VZ1_VALDES )
						ElseIf VZ1->VZ1_VALBRU > 0
							nVlr := If(VO2->VO2_DEVOLU=="0",-1,1) * VZ1->VZ1_VALBRU
						EndIf
					EndIf
					If cStat == STR0007
						If !Empty(VO3->VO3_DATCAN) .and. ( ( dDIni <= VO3->VO3_DATCAN .and. dDFin >= VO3->VO3_DATCAN ) .or. lDat )
							lImp := .f.
							cTip := "5"+STR0007
							cDat := dtos(If(lDat,VO1->VO1_DATABE,VO3->VO3_DATCAN))
						EndIf
					ElseIf cStat == STR0006
						If !Empty(VO3->VO3_DATCAN)
							DbSelectArea("VO3")
							DbSkip()
							Loop
						EndIf					
						If !Empty(VO3->VO3_DATFEC) .and. ( ( dDIni <= VO3->VO3_DATFEC .and. dDFin >= VO3->VO3_DATFEC ) .or. lDat )
							lImp := .f.
							cTip := "4"+STR0006
							cDat := dtos(If(lDat,VO1->VO1_DATABE,VO3->VO3_DATFEC))
							DbSelectArea("VEC")
							DbSetOrder(5)
							If DbSeek( xFilial("VEC") + VO1->VO1_NUMOSV + VO3->VO3_TIPTEM + VO3->VO3_GRUITE + VO3->VO3_CODITE )
								DbSelectArea("VOI")
								DbSetOrder(1)
								DbSeek( xFilial("VOI") + VO3->VO3_TIPTEM )
								If VOI->VOI_SITTPO == "3"
				               nVlr := ( VEC->VEC_CUSTOT / VEC->VEC_QTDITE ) * VO3->VO3_QTDREQ * If(VO2->VO2_DEVOLU=="0",-1,1)
				            Else
				               nVlr := ( VEC->VEC_VALVDA / VEC->VEC_QTDITE ) * VO3->VO3_QTDREQ * If(VO2->VO2_DEVOLU=="0",-1,1)
			   	         EndIf
							EndIf
						EndIf
					ElseIf cStat == STR0005
						If !Empty(VO3->VO3_DATCAN) .or. !Empty(VO3->VO3_DATFEC)
							DbSelectArea("VO3")
							DbSkip()
							Loop
						EndIf
						If !Empty(VO3->VO3_DATDIS) .and. ( ( dDIni <= VO3->VO3_DATDIS .and. dDFin >= VO3->VO3_DATDIS ) .or. lDat )
							lImp := .f.
							cTip := "3"+STR0005
							cDat := dtos(If(lDat,VO1->VO1_DATABE,VO3->VO3_DATDIS))
						EndIf
					ElseIf cStat == STR0004
						If !Empty(VO3->VO3_DATCAN) .or. !Empty(VO3->VO3_DATFEC) .or. !Empty(VO3->VO3_DATDIS)
							DbSelectArea("VO3")
							DbSkip()
							Loop
						EndIf
					ElseIf cStat == STR0003
						If !Empty(VO3->VO3_DATCAN) .and. ( ( dDIni <= VO3->VO3_DATCAN .and. dDFin >= VO3->VO3_DATCAN ) .or. lDat )
							lImp := .f.
							cTip := "5"+STR0007
							cDat := dtos(If(lDat,VO1->VO1_DATABE,VO3->VO3_DATCAN))
						ElseIf !Empty(VO3->VO3_DATFEC) .and. ( ( dDIni <= VO3->VO3_DATFEC .and. dDFin >= VO3->VO3_DATFEC ) .or. lDat )
							lImp := .f.
							cTip := "4"+STR0006
							cDat := dtos(If(lDat,VO1->VO1_DATABE,VO3->VO3_DATFEC))
							DbSelectArea("VEC")
							DbSetOrder(5)
							If DbSeek( xFilial("VEC") + VO1->VO1_NUMOSV + VO3->VO3_TIPTEM + VO3->VO3_GRUITE + VO3->VO3_CODITE )
								DbSelectArea("VOI")
								DbSetOrder(1)
								DbSeek( xFilial("VOI") + VO3->VO3_TIPTEM )
								If VOI->VOI_SITTPO == "3"
				               nVlr := ( VEC->VEC_CUSTOT / VEC->VEC_QTDITE ) * VO3->VO3_QTDREQ * If(VO2->VO2_DEVOLU=="0",-1,1)
				            Else
				               nVlr := ( VEC->VEC_VALVDA / VEC->VEC_QTDITE ) * VO3->VO3_QTDREQ * If(VO2->VO2_DEVOLU=="0",-1,1)
			   	         EndIf
							EndIf
						ElseIf !Empty(VO3->VO3_DATDIS) .and. ( ( dDIni <= VO3->VO3_DATDIS .and. dDFin >= VO3->VO3_DATDIS ) .or. lDat )
							lImp := .f.
							cTip := "3"+STR0005
							cDat := dtos(If(lDat,VO1->VO1_DATABE,VO3->VO3_DATDIS))
						EndIf
					EndIf
					If ( ( cStat == STR0004 .or. cStat == STR0003 ) .and. lImp .and. dDFin >= VO1->VO1_DATABE )
						cTip := "2"+STR0004
						cDat := dtos(VO1->VO1_DATABE)
//						nVlr := 0
					EndIf
					If !Empty(cTip)
						nPos := aScan(aOSs,{|x| x[1]+x[2]+x[6] == VO1->VO1_NUMOSV+left(cTip,1)+VO3->VO3_TIPTEM })
						If nPos == 0
							Aadd(aOSs,{ VO1->VO1_NUMOSV , left(cTip,1) , substr(cTip,2,15) , cPro , If(!Empty(VO3->VO3_FATPAR),VO3->VO3_FATPAR+VO3->VO3_LOJA,VO1->VO1_PROVEI+VO1->VO1_LOJPRO) , VO3->VO3_TIPTEM , cDat , nVlr } )
						Else
							aOSs[nPos,8] += nVlr
						EndIf
						nFun++
					EndIf
					DbSelectArea("VO3")
					DbSkip()
				EndDo 
				DbSelectArea("VO4")
				DbSetOrder(1)
				DbSeek( xFilial("VO4") + VO2->VO2_NOSNUM )
				While !Eof() .and. VO4->VO4_FILIAL == xFilial("VO4") .and. VO4->VO4_NOSNUM == VO2->VO2_NOSNUM
					cPro := VO4->VO4_CODPRO
					If !Empty(Alltrim(cProd)) .and. cProd # cPro
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
					lImp := .t.
					cTip := ""
					DbSelectArea("VO6")
					DbSetOrder(2)
					DbSeek( xFilial("VO6") + VV1->VV1_CODMAR + VO4->VO4_CODSER )
			      DbSelectArea("VOK")
		   	   DbSetOrder(1)
		      	DbSeek( xFilial("VOK") + VO4->VO4_TIPSER )
					DbSelectArea("VOI")
					DbSetOrder(1)
					DbSeek( xFilial("VOI") + VO4->VO4_TIPTEM )
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
						If aValSer[6]  // se nao foi somado soma
							aValSer[1] := ( ( aValSer[2] / 100 ) * FG_ValHor(VO4->VO4_TIPTEM,VO1->VO1_DATABE) )
						EndIf
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
					If aValSer[1] > 0
						nVlr := aValSer[1]
					Else
						If ( VOK->VOK_INCMOB == "0" .and. VOK->VOK_TIPHOR == "2" )
//							nVlr := ( ( VO4->VO4_TEMPAD * VO4->VO4_VALHOR ) / 100 )
							nVlr := 0
						EndIf
					EndIf
					If cStat == STR0007
						If !Empty(VO4->VO4_DATCAN) .and. ( ( dDIni <= VO4->VO4_DATCAN .and. dDFin >= VO4->VO4_DATCAN ) .or. lDat )
							lImp := .f.
							cTip := "5"+STR0007
							cDat := dtos(If(lDat,VO1->VO1_DATABE,VO4->VO4_DATCAN))
						EndIf
					ElseIf cStat == STR0006
						If !Empty(VO4->VO4_DATCAN)
							DbSelectArea("VO4")
							DbSkip()
							Loop
						EndIf
						If !Empty(VO4->VO4_DATFEC) .and. ( ( dDIni <= VO4->VO4_DATFEC .and. dDFin >= VO4->VO4_DATFEC ) .or. lDat )
							lImp := .f.
							cTip := "4"+STR0006
							cDat := dtos(If(lDat,VO1->VO1_DATABE,VO4->VO4_DATFEC))
						EndIf
					ElseIf cStat == STR0005
						If !Empty(VO4->VO4_DATCAN) .or. !Empty(VO4->VO4_DATFEC)
							DbSelectArea("VO4")
							DbSkip()
							Loop
						EndIf
						If !Empty(VO4->VO4_DATDIS) .and. ( ( dDIni <= VO4->VO4_DATDIS .and. dDFin >= VO4->VO4_DATDIS ) .or. lDat )
							lImp := .f.
							cTip := "3"+STR0005
							cDat := dtos(If(lDat,VO1->VO1_DATABE,VO4->VO4_DATDIS))
						EndIf
					ElseIf cStat == STR0004
						If !Empty(VO4->VO4_DATCAN) .or. !Empty(VO4->VO4_DATFEC) .or. !Empty(VO4->VO4_DATDIS)
							DbSelectArea("VO4")
							DbSkip()
							Loop
						EndIf
					ElseIf cStat == STR0003
						If !Empty(VO4->VO4_DATCAN) .and. ( ( dDIni <= VO4->VO4_DATCAN .and. dDFin >= VO4->VO4_DATCAN ) .or. lDat )
							lImp := .f.
							cTip := "5"+STR0007
							cDat := dtos(If(lDat,VO1->VO1_DATABE,VO4->VO4_DATCAN))
						ElseIf !Empty(VO4->VO4_DATFEC) .and. ( ( dDIni <= VO4->VO4_DATFEC .and. dDFin >= VO4->VO4_DATFEC ) .or. lDat )
							lImp := .f.
							cTip := "4"+STR0006
							cDat := dtos(If(lDat,VO1->VO1_DATABE,VO4->VO4_DATFEC))
						ElseIf !Empty(VO4->VO4_DATDIS) .and. ( ( dDIni <= VO4->VO4_DATDIS .and. dDFin >= VO4->VO4_DATDIS ) .or. lDat )
							lImp := .f.
							cTip := "3"+STR0005
							cDat := dtos(If(lDat,VO1->VO1_DATABE,VO4->VO4_DATDIS))
						EndIf
					EndIf
					If ( ( cStat == STR0004 .or. cStat == STR0003 ) .and. lImp .and. dDFin >= VO1->VO1_DATABE )
						cTip := "2"+STR0004
						cDat := dtos(VO1->VO1_DATABE)
					EndIf
					If !Empty(cTip)
						nPos := aScan(aOSs,{|x| x[1]+x[2]+x[6] == VO1->VO1_NUMOSV+left(cTip,1)+VO4->VO4_TIPTEM })
						If nPos == 0
							Aadd(aOSs,{ VO1->VO1_NUMOSV , left(cTip,1) , substr(cTip,2,15) , cPro , If(!Empty(VO4->VO4_FATPAR),VO4->VO4_FATPAR+VO4->VO4_LOJA,VO1->VO1_PROVEI+VO1->VO1_LOJPRO) , VO4->VO4_TIPTEM , cDat , nVlr } )
						Else
							aOSs[nPos,8] += nVlr
						EndIf
						nFun++
					EndIf
					DbSelectArea("VO4")
					DbSkip()
				EndDo 
				DbSelectArea("VO2")
				DbSkip()
			EndDo
			cSem := ""
		Else
			If ( cCCl1+cLCl1 > VO1->VO1_PROVEI+VO1->VO1_LOJPRO ) .or. ( cCCl2+cLCl2 < VO1->VO1_PROVEI+VO1->VO1_LOJPRO )
				DbSelectArea("VO1")
				DbSkip()
				Loop
			EndIf
			If !Empty(Alltrim(cProd)) .or. ( cStat # STR0003 .and. cStat # STR0004 )
				DbSelectArea("VO1")
				DbSkip()
				Loop
			EndIf
			If dDFin >= VO1->VO1_DATABE 
				If VO1->VO1_STATUS == "C"
					If cStat == STR0003
						cTip := "5"+STR0007
					Else
						DbSelectArea("VO1")
						DbSkip()
						Loop
					EndIf
            Else
					cTip := "2"+STR0004
				EndIf
				cSem := STR0027
				nPos := aScan(aOSs,{|x| x[1]+x[2]+x[6] == VO1->VO1_NUMOSV+left(cTip,1)+"!" })
				cDat := dtos(VO1->VO1_DATABE)
				nVlr := 0
				If nPos == 0
					Aadd(aOSs,{ VO1->VO1_NUMOSV , left(cTip,1) , substr(cTip,2,15) , cSem , VO1->VO1_PROVEI+VO1->VO1_LOJPRO , "!" , cDat , nVlr } )
				EndIf
				nFun++
			EndIf
		EndIf
		If nFun > 0
			nRes++
			nPos := aScan(aRes,{|x| x[1] == VO1->VO1_FUNABE })
			If nPos == 0
				DbSelectArea("VAI")
  	   		DbSetOrder(1)
	  			DbSeek( xFilial("VAI") + VO1->VO1_FUNABE )
				Aadd(aRes,{ VO1->VO1_FUNABE , left(VAI->VAI_NOMTEC,40) , 1 } )
			Else
				aRes[nPos,3]++
			EndIf
		EndIf
		For nTip := 1 to len(aOSs)
			nValTot := aOSs[nTip,8]
			aTot[1,3]++
			aTot[1,4] += nValTot
			nPos := 0
			cPos := " "
			If cPor1 == STR0002 // Status
				cPos := aOSs[nTip,2]
				nPos := aScan(aTot,{|x| x[1] == cPos })
				If nPos == 0
					Aadd(aTot,{ cPos , aOSs[nTip,3] , 1 , nValTot } )
				Else
					aTot[nPos,3]++
					aTot[nPos,4] += nValTot
				EndIf
			ElseIf cPor1 == STR0008 // Cliente
				cPos := aOSs[nTip,5]
				nPos := aScan(aTot,{|x| x[1] == cPos })
				If nPos == 0          
					DbSelectArea("SA1")
	   	   	DbSetOrder(1)
   		  		DbSeek( xFilial("SA1") + cPos )
					Aadd(aTot,{ cPos , substr(cPos,1,6)+"-"+substr(cPos,7,2)+" "+left(SA1->A1_NOME,40) , 1 , nValTot	} )
				Else
					aTot[nPos,3]++
					aTot[nPos,4] += nValTot
				EndIf
			ElseIf cPor1 == STR0009 // Produtivo
				cPos := If(Empty(cSem),cPro,cSem)
				nPos := aScan(aTot,{|x| x[1] == cPos })
				If nPos == 0          
					DbSelectArea("VAI")
	   	   	DbSetOrder(1)
   		  		DbSeek( xFilial("VAI") + cPos )
					Aadd(aTot,{ cPos , If(Empty(cSem),left(VAI->VAI_NOMTEC,40),cSem) , 1 , nValTot } )
				Else
					aTot[nPos,3]++
					aTot[nPos,4] += nValTot
				EndIf
			EndIf
			If cPor2 # " "
				nPos := 0
				If cPor2 == STR0002 // Status
					nPos := aScan(aGrp,{|x| x[1]+x[4] == cPos + aOSs[nTip,2] })
					If nPos == 0
						Aadd(aGrp,{ cPos , aOSs[nTip,3] , 1 , aOSs[nTip,2] , "" } )  
					Else
						aGrp[nPos,3]++
					EndIf
				ElseIf cPor2 == STR0008 // Cliente
					nPos := aScan(aGrp,{|x| x[1]+x[4] == cPos + aOSs[nTip,5] })
					If nPos == 0          
						DbSelectArea("SA1")
			   	   DbSetOrder(1)
  				  		DbSeek( xFilial("SA1") + aOSs[nTip,5] )
						Aadd(aGrp,{ cPos , substr(aOSs[nTip,5],1,6)+"-"+substr(aOSs[nTip,5],7,2)+" "+left(SA1->A1_NOME,40) , 1 , aOSs[nTip,5] , "" } )
					Else
						aGrp[nPos,3]++
					EndIf
				ElseIf cPor2 == STR0009 // Produtivo
					cPro := If(Empty(cSem),aOSs[nTip,4],cSem)
					nPos := aScan(aGrp,{|x| x[1]+x[4] == cPos + cPro })
					If nPos == 0
						DbSelectArea("VAI")
		   	   	DbSetOrder(1)
   			  		DbSeek( xFilial("VAI") + cPro )
						Aadd(aGrp,{ cPos , If(Empty(cSem),left(VAI->VAI_NOMTEC,40),cSem) , 1 , cPro , "" } )
					Else
						aGrp[nPos,3]++
					EndIf
				ElseIf cPor2 == STR0010 // OS
					DbSelectArea("SA1")
   		   	DbSetOrder(1)
  		  			DbSeek( xFilial("SA1") + aOSs[nTip,5] )
					nPos := aScan(aGrp,{|x| x[1]+x[4] == cPos + aOSs[nTip,1] })
					If nPos == 0
						Aadd(aGrp,{ cPos , aOSs[nTip,1]+" "+substr(aOSs[nTip,5],1,6)+"-"+substr(aOSs[nTip,5],7,2)+" "+left(SA1->A1_NOME,40)+space(6)+If(!Empty(aOSs[nTip,7]),substr(aOSs[nTip,7],7,2)+"/"+substr(aOSs[nTip,7],5,2)+"/"+substr(aOSs[nTip,7],3,2),space(8))+space(10)+cPla+Transform(nValTot,"@E 999,999,999,999.99") , 1 , aOSs[nTip,1] , aOSs[nTip,7] } )
					Else
						aGrp[nPos,3]++
					EndIf
				EndIf
			EndIf
		Next
		DbSelectArea("VO1")
		DbSkip()
	EndDo
	If cPor1 == STR0002
		aSort(aTot,1,,{|x,y| x[1] < y[1] })
	Else
		aSort(aTot,1,,{|x,y| strzero(99999999-x[3],8)+x[1] < strzero(99999999-y[3],8)+y[1] })
	EndIf 
	If cPor2 == STR0002
		aSort(aGrp,1,,{|x,y| x[1]+x[4]+strzero(99999999-x[3],8) < y[1]+y[4]+strzero(99999999-y[3],8) })
	Else
		aSort(aGrp,1,,{|x,y| x[1]+x[5]+strzero(99999999-x[3],8)+left(x[2],10) < y[1]+y[5]+strzero(99999999-y[3],8)+left(y[2],10) })
	EndIf

	If !Empty(cProd)
		DbSelectArea("VAI")
	  	DbSetOrder(1)
	 	DbSeek( xFilial("VAI") + cProd )
   EndIf

	nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1 
	nLin++
	@ nLin++ , If(lP,40,12) psay STR0021
	@ nLin++ , If(lP,41,13) psay left(Alltrim(STR0013)+repl(".",14),14)+": "+cDtas+" "+STR0019+" "+Transform(dDIni,"@D")+" "+STR0020+" "+Transform(dDFin,"@D")
	@ nLin++ , If(lP,41,13) psay left(Alltrim(STR0014)+repl(".",14),14)+": "+cStat
	@ nLin++ , If(lP,41,13) psay left(Alltrim(STR0008)+repl(".",14),14)+": "+STR0019+" "+cCCl1+"-"+cLCl1+" "+STR0020+" "+cCCl2+"-"+cLCl2
	@ nLin++ , If(lP,41,13) psay left(Alltrim(STR0009)+repl(".",14),14)+": "+If(!Empty(cProd),cProd+" "+left(VAI->VAI_NOMTEC,35),"")
	@ nLin++ , If(lP,41,13) psay left(Alltrim(STR0017)+repl(".",14),14)+": "+STR0019+" "+Transform(cPla1,"@R XXX-9999") +" "+STR0020+" "+ Transform(cPla2,"@R XXX-9999")
	@ nLin++ , If(lP,41,13) psay left(Alltrim(STR0018)+repl(".",14),14)+": "+Alltrim(cPor1)+If(!Empty(Alltrim(cPor2))," + "+Alltrim(cPor2),"")
	@ nLin++ , If(lP,40,12) psay repl("-",len(STR0021))
	nLin++
	@ nLin++ , 00 psay left(Alltrim(cPor1)+If(!Empty(Alltrim(cPor2))," + "+Alltrim(cPor2),"")+space(If(lP,68,60)),If(lP,68,60))+left(If(lP,left(STR0015+space(18),18)+STR0017,"")+space(If(lP,39,1)),If(lP,39,1))+left(If(lP,STR0016+space(If(lP,7,1)),space(If(lP,7,1))),If(lP,7,1))+STR0025

	If len(aGrp) == 0
		nLin++
	EndIf
	For ni := 1 to len(aTot)
		If nLin >= 55
	    	nLin := 1
			nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1   
	    	nLin++ 
		EndIf
		If len(aGrp) > 0
			nLin++
		EndIf
		If cPor1 == STR0009 .and. Empty(aTot[ni,2])		
			@ nLin++ , 00 psay left(Alltrim(STR0028)+space(If(lP,94,59)),If(lP,94,59))+If(lP,Transform(aTot[ni,4],"@E 999,999,999,999.99"),space(1))+Transform(aTot[ni,3],"@E 9999999,999")+Transform(((aTot[ni,3]/aTot[1,3])*100),"@E 99999.9")+" %"
		Else
			@ nLin++ , 00 psay left(Alltrim(aTot[ni,2])+space(If(lP,94,59)),If(lP,94,59))+If(lP,Transform(aTot[ni,4],"@E 999,999,999,999.99"),space(1))+Transform(aTot[ni,3],"@E 9999999,999")+Transform(((aTot[ni,3]/aTot[1,3])*100),"@E 99999.9")+" %"
		EndIf
		nPos := 0
		nPos := aScan(aGrp,{|x| x[1] == aTot[ni,1] })
		If nPos > 0
			For nj := nPos to len(aGrp)
				If aGrp[nj,1] # aTot[ni,1]
					Exit
				EndIf
				If nLin >= 57
		   	 	nLin := 1
					nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1   
		   	 	nLin++ 
				EndIf
				If cPor2 == STR0009 .and. Empty(aGrp[nj,2])		
					@ nLin++ , 03 psay left(Alltrim(STR0028)+space(If(lP,111,59)),If(lP,111,59))+Transform(aGrp[nj,3],"@E 99999,999")+Transform(((aGrp[nj,3]/aTot[1,3])*100),"@E 99999.9")+" %"
				Else
					@ nLin++ , 03 psay left(Alltrim(aGrp[nj,2])+space(If(lP,111,59)),If(lP,111,59))+Transform(aGrp[nj,3],"@E 99999,999")+Transform(((aGrp[nj,3]/aTot[1,3])*100),"@E 99999.9")+" %"
				EndIf
			Next
		EndIf
	Next
	If len(aRes) > 0
		aSort(aRes,1,,{|x,y| strzero(99999999-x[3],8)+x[2] < strzero(99999999-y[3],8)+y[2] })
  		nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1   
  		nLin++ 
		@ nLin++ , 00 psay left(STR0024+space(62),62)+STR0025
  		nLin++ 
		@ nLin++ , 00 psay left(STR0026+space(62),62)+Transform(nRes,"@E 99999,999")+Transform(((nRes/nRes)*100),"@E 99999.9")+" %"
		For ni := 1 to len(aRes)
			If nLin >= 55
		    	nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1   
	    		nLin++ 
			EndIf
			@ nLin++ , 00 psay left(aRes[ni,1]+" "+aRes[ni,2]+space(62),62)+Transform(aRes[ni,3],"@E 99999,999")+Transform(((aRes[ni,3]/nRes)*100),"@E 99999.9")+" %"
		Next
	EndIf

	Ms_Flush()
	Set Printer to
	Set Device  to Screen
	
Return
