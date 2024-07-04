#Include "OFIOM380.ch"
#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOM380 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 21/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Conferencia de Itens do Orcamento por Cod.Barra            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM380(cConfOrc)
Local OXvermelho
Local OXverde
Local lRet := .t.
Default cConfOrc := ""
Private overde   := LoadBitmap( GetResources(), "BR_verde")
Private overmelho:= LoadBitmap( GetResources(), "BR_vermelho")
Private nQtd := 1
Private cCod := space(27)
Private cGrp := space(4)
Private aOrc := {}
Private aIte := {}
Private lConBar := .f.
Private lMarcar := .f.
Private cCodCli := space(6)
Private cLojCli := space(2)
Private cNomCli := space(50)
Private nDias := 0

DbSelectArea("SX3")
DbSetOrder(2)
If DbSeek("VS3_CONBAR")
	lConBar := .t. 
EndIf 
If Empty(cConfOrc)
	FS_ORC(0)
	DEFINE MSDIALOG oOrc FROM 000,000 TO 032,070 TITLE (STR0001) OF oMainWnd
		@ 021,002 LISTBOX oLbOrc FIELDS HEADER OemToAnsi(""),;  //"Status"
															OemToAnsi(STR0018),;  //"Orcamento"
															OemToAnsi(STR0019),;  //"Data"
															OemToAnsi(STR0020);  //"Cliente"
		COLSIZES 10,35,35,90 SIZE 274,202 OF oOrc PIXEL ON DBLCLICK ( aOrc[oLbOrc:nAt,1] := !aOrc[oLbOrc:nAt,1] )
		oLbOrc:SetArray(aOrc)
		oLbOrc:bLine := { || {If(aOrc[oLbOrc:nAt,1],overde,overmelho),;
									aOrc[oLbOrc:nAt,2] ,;
									aOrc[oLbOrc:nAt,3] ,;
									aOrc[oLbOrc:nAt,4] }}
		DEFINE SBUTTON FROM 227,240 TYPE 1 ACTION (lRet:=.f.,oOrc:End()) ENABLE OF oOrc PIXEL
		DEFINE SBUTTON FROM 227,205 TYPE 2 ACTION oOrc:End() ENABLE OF oOrc PIXEL
		@ 001,002 TO 019,276 LABEL STR0017 OF oOrc PIXEL COLOR CLR_BLUE
		@ 008,007 SAY STR0021 SIZE 30,08 OF oOrc PIXEL COLOR CLR_BLUE //Dias:
		@ 007,020 MSGET oDias VAR nDias PICTURE "999" SIZE 20,08 OF oOrc PIXEL COLOR CLR_BLUE
		@ 008,045 SAY STR0015 SIZE 30,08 OF oOrc PIXEL COLOR CLR_BLUE
		@ 007,064 MSGET oCodCli VAR cCodCli F3 "SA1" VALID FS_CLIENTE() SIZE 40,08 OF oOrc PIXEL COLOR CLR_BLUE
		@ 007,104 MSGET oLojCli VAR cLojCli VALID FS_CLIENTE() SIZE 10,08 OF oOrc PIXEL COLOR CLR_BLUE
		@ 007,119 MSGET oNomCli VAR cNomCli SIZE 95,08 OF oOrc PIXEL COLOR CLR_BLUE WHEN .f.
		@ 007,219 BUTTON oOk PROMPT STR0016 OF oOrc SIZE 55,10 PIXEL ACTION FS_ORC(1)
		@ 021,003 CHECKBOX oMarcar VAR lMarcar PROMPT "" OF oOrc ON CLICK If( FS_TIKM() , .t. , ( lMarcar:=!lMarcar , oMarcar:Refresh() ) ) SIZE 10,10 PIXEL COLOR CLR_BLUE
	ACTIVATE MSDIALOG oOrc CENTER
	If !lRet
		If FS_PESQ()
			DEFINE MSDIALOG oConfBarra FROM 000,000 TO 032,070 TITLE (STR0001) OF oMainWnd
			@ 228,113 SAY STR0008 SIZE 50,08 OF oConfBarra PIXEL COLOR CLR_BLUE
			@ 227,142 MSGET oCod VAR cCod VALID If(!Empty(cCod),(FS_TIK(),.f.),.t.) SIZE 55,08 OF oConfBarra PIXEL COLOR CLR_BLUE
			@ 002,002 LISTBOX oLbIte FIELDS HEADER OemToAnsi(""),;  //"Status"
			OemToAnsi(STR0003),;  //"Grupo"
			OemToAnsi(STR0004),;  //"Cod.Item"
			OemToAnsi(STR0005),;  //"Descricao"
			OemToAnsi(STR0022),;  // "Locacao"
			OemToAnsi(STR0006);  //"Qtd.Conferencia"
			COLSIZES 10,18,60,70,45,45 SIZE 274,220 OF oConfBarra PIXEL
			oLbIte:SetArray(aIte)
			oLbIte:bLine := { || {If(aIte[oLbIte:nAt,1],overde,overmelho),;
										aIte[oLbIte:nAt,2] ,;
										aIte[oLbIte:nAt,3] ,;
										aIte[oLbIte:nAt,4] ,;
										aIte[oLbIte:nAt,9] ,;
										Transform(aIte[oLbIte:nAt,5],"@E 999,999.99") }}
			@ 227,220 BUTTON oSair PROMPT STR0013 OF oConfBarra SIZE 42,10 PIXEL ACTION If(FS_SAIR(),oCod:SetFocus(),oConfBarra:End())
			@ 228,023 SAY STR0007 SIZE 40,08 OF oConfBarra PIXEL COLOR CLR_BLUE
			@ 227,040 MSGET oQtd VAR nQtd VALID (nQtd>=0) PICTURE "@E 999,999,999.99" SIZE 50,08 OF oConfBarra PIXEL COLOR CLR_BLUE
			ACTIVATE MSDIALOG oConfBarra CENTER
			OFIOM380()
		EndIf
	EndIf
Else
	If lConBar
		DbSelectArea("VS3")
		DbSetOrder(2)
		If DbSeek(xFilial("VS3")+cConfOrc)
			Do While !Eof() .and. VS3->VS3_FILIAL == xFilial("VS3") .and. VS3->VS3_NUMORC == cConfOrc .and. lRet
				lRet := If(VS3->VS3_CONBAR=="0",.f.,.t.)
				DbSkip()
			EndDo
		EndIf
	EndIf
EndIf
Return(lRet)

Static Function FS_CLIENTE()
Local lRet := .f.
cNomCli := space(50)
If Empty(cCodCli)
	cLojCli := space(2)
	lRet := .t.
Else
	DbSelectArea("SA1")
	DbSetOrder(1)
	If DbSeek(xFilial("SA1")+cCodCli+Alltrim(cLojCli))
		cLojCli := SA1->A1_LOJA
		cNomCli := SA1->A1_NOME
		lRet := .t.
	EndIf
EndIf
oNomCli:Refresh()
Return(lRet)

Static Function FS_ORC(nt)
	Local cSeekSA1 := "Inicial"
	aOrc := {}
	DbSelectArea("VS1")
	DbSetOrder(3)
	If DbSeek(xFilial("VS1"))
		Do While !Eof() .and. VS1->VS1_FILIAL == xFilial("VS1") .and. Empty(VS1->VS1_NUMNFI+VS1->VS1_SERNFI)
			If VS1->VS1_DATVAL >= dDataBase .and. VS1->VS1_DATORC >= ( dDataBase - nDias )
				If Empty(cCodCli+cLojCli) .or. (cCodCli+cLojCli == VS1->VS1_CLIFAT+VS1->VS1_LOJA )
					If cSeekSA1 # VS1->VS1_CLIFAT+VS1->VS1_LOJA
						cSeekSA1 := VS1->VS1_CLIFAT+VS1->VS1_LOJA
						DbSelectArea("SA1")
						DbSetOrder(1)
						DbSeek(xFilial("SA1")+VS1->VS1_CLIFAT+VS1->VS1_LOJA)
						DbSelectArea("VS1")
					EndIf
					Aadd(aOrc,{.f.,VS1->VS1_NUMORC,Transform(VS1->VS1_DATORC,"@D"),VS1->VS1_CLIFAT+"-"+VS1->VS1_LOJA+" "+SA1->A1_NOME})
				EndIf
			EndIf
			DbSkip()
		EndDo
	EndIf
	If len(aOrc) == 0
		Aadd(aOrc,{.f.,"","",""})
	EndIf
	aSort(aOrc,1,,{|x,y| x[2] > y[2] })
	If nt # 0
		oLbOrc:SetArray(aOrc)
		oLbOrc:bLine := { || {If(aOrc[oLbOrc:nAt,1],overde,overmelho),;
									aOrc[oLbOrc:nAt,2] ,;
									aOrc[oLbOrc:nAt,3] ,;
									aOrc[oLbOrc:nAt,4] }}
		oLbOrc:SetFocus()
		oLbOrc:Refresh()
	EndIf
	lMarcar := .f.
Return

Static Function FS_PESQ() // Pesquisa Itens do Orcamento
Local nPos := 0
Local ni   := 0
Local lRet := .f.
aIte := {}
For ni := 1 to len(aOrc)
	If aOrc[ni,1]
		lRet := .t.
		DbSelectArea("VS3")
		DbSetOrder(2)
		If DbSeek(xFilial("VS3")+aOrc[ni,2])
			Do While !Eof() .and. VS3->VS3_FILIAL == xFilial("VS3") .and. VS3->VS3_NUMORC == aOrc[ni,2]
				nPos := aScan(aIte,{|x| x[2]+x[3] == VS3->VS3_GRUITE+VS3->VS3_CODITE })
				If nPos == 0
					DbSelectArea("SB1")
					DbSetOrder(7)
					DbSeek( xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE)
					DbSelectArea("SB5")
					DbSetOrder(1)
					DbSeek( xFilial("SB5")+SB1->B1_COD)
					DbSelectArea("VS3")
					Aadd(aIte,{If(lConBar,If(VS3->VS3_CONBAR=="0",.f.,.t.),.f.),VS3->VS3_GRUITE,VS3->VS3_CODITE,SB1->B1_DESC,If(lConBar,If(If(VS3->VS3_CONBAR=="0",.f.,.t.),VS3->VS3_QTDITE,0),0),VS3->VS3_QTDITE,SB1->B1_CODBAR,SB1->B1_COD,SB5->B5_LOCALIZ})
				Else
					aIte[nPos,5] += If(lConBar,If(If(VS3->VS3_CONBAR=="0",.f.,.t.),VS3->VS3_QTDITE,0),0)
					aIte[nPos,6] += VS3->VS3_QTDITE
				EndIf
				DbSkip()
			EndDo
		EndIf
	EndIf
Next
If len(aIte) == 0
	Aadd(aIte,{.f.,"","","",0,0,"","",""})
Else
	aSort(aIte,1,,{|x,y| x[2]+x[3] < y[2]+y[3] })
EndIf
Return(lRet)

Static Function FS_TIK()
Local nPos := 0
Local ni   := 0
Local lAtu := .f.
If !Empty(cCod)
	nPos := aScan(aIte,{|x| x[7] == left(cCod,15) })
	If nPos == 0
		cGrp := ""
		For ni := 1 to len(aIte)
			If left(cCod,27) == aIte[ni,3]
				If Empty(cGrp)
					cGrp := aIte[ni,2]
					FG_POSSB1("cCod","SB1->B1_COD","cGrp")
				Else
					FG_POSSB1("cCod","SB1->B1_COD")
					Exit
				EndIf
			EndIf
		Next
		nPos := aScan(aIte,{|x| x[8] == left(cCod,15) })
	EndIf     
	If nPos > 0
		oLbIte:nAt := nPos
		lAtu := aIte[nPos,1]
		aIte[nPos,1] := .f.
		If nQtd > 0
			aIte[nPos,5] += nQtd
			If aIte[nPos,5] == aIte[nPos,6]
				aIte[nPos,1] := .t.
			EndIf
		Else
			aIte[nPos,5] := 0
		EndIf
		If lConBar .and. ( lAtu # aIte[nPos,1] )
			For ni := 1 to len(aOrc)
				If aOrc[ni,1]
					DbSelectArea("VS3")
					DbSetOrder(2)
					If DbSeek(xFilial("VS3")+aOrc[ni,2]+aIte[nPos,2]+aIte[nPos,3])
						DbSelectArea("VS3")
						RecLock("VS3",.F.)
							VS3->VS3_CONBAR := If(aIte[nPos,1],"1","0")
						MsUnlock()
					EndIf
				EndIf
			Next
		EndIf
	Else
		MsgAlert(STR0012,STR0009)
	EndIf
	cCod:=space(27)
	oLbIte:SetArray(aIte)
	oLbIte:bLine := { || {If(aIte[oLbIte:nAt,1],overde,overmelho),;
								aIte[oLbIte:nAt,2] ,;
								aIte[oLbIte:nAt,3] ,;
								aIte[oLbIte:nAt,4] ,;
								aIte[oLbIte:nAt,9] ,;
								Transform(aIte[oLbIte:nAt,5],"@E 999,999.99") }}
	oLbIte:SetFocus()
	oLbIte:Refresh()
EndIf
nQtd := 1
oQtd:Refresh()
oCod:SetFocus()
Return()

Static Function FS_SAIR()
Local lRet := .f.
Local ni := 0
For ni := 1 to len(aIte)
	If !Empty(aIte[ni,3]) .and. !aIte[ni,1]
		If MsgYesNo(STR0014,STR0009)
			lRet := .t.
		EndIf
		Exit
	EndIf
Next
Return(lRet)

Static Function FS_TIKM()
Local ni := 0
For ni := 1 to Len(aOrc)
	If lMarcar
		aOrc[ni,1] := .t.
	Else
		aOrc[ni,1] := .f.
	EndIf
Next                
oLbOrc:Refresh()
oLbOrc:SetFocus()
Return(.t.)