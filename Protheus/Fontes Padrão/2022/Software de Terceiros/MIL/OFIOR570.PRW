// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»  
// º Versao º 03     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "OFIOR570.CH"
#Include "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOR570 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 15/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Demanda Oficina / Balcao                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR570()

Private cDesc1  := STR0001
Private cDesc2  := ""
Private cDesc3  := ""
Private tamanho := "M"
Private limite  := 132
Private ncaracter := 15
Private cString := "VES"
Private ctitulo := STR0002
Private cabec1  := ""
Private cabec2  := ""
Private aReturn := {STR0003,1,STR0004,1,2,1,"",1}
Private nomeprog:= "OFIOR570"
Private nLastKey:= 0
Private aItens  := {}
Private aAux    := {}
Private cPerg   := "OFR570"
Private lLevDem := .t.
Private dDtIni  := ( dDataBase - 31 )
Private dDtFin  := ( dDataBase - 1 )

DbSelectArea("VES")
DbSetOrder(2)
DbSeek( xFilial("VES") + dtos(dDtIni) , .t. )
While !Eof() .and. VES->VES_FILIAL == xFilial("VES") .and. VES->VES_DATDEM <= dDtFin
	lLevDem := .f.
	Exit
	DbSelectArea("VES")
	DbSkip()
EndDo
If lLevDem
	If MsgYesNo(STR0006,STR0005)
		OFIIA290()
	EndIf
	Return()
EndIf

nomeprog := SetPrint(cString,nomeprog,cPerg,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
If nLastKey == 27
	Return
EndIf
PERGUNTE(cPerg,.f.)

SetDefault(aReturn,cString)
RptStatus( { |lEnd| FS_OFIOR570(@lEnd,nomeprog,cString) } , cTitulo )
If aReturn[5] == 1
	OurSpool( nomeprog )
EndIf
MS_Flush()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_OFIOR570³ Autor ³ Andre Luis Almeida   ³ Data ³ 15/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao da Demanda Oficina / Balcao                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OFIOR570()

Local nPos   := 0
Local ni     := 0
Local nVlr1  := 0
Local nVlr2  := 0
Local nTot1  := 0
Local nTot2  := 0
Local nQtdAtu:= 0
Local aItens := {}
Local nQtdDem := 0
Local nQtdNFs := 0
cTitulo += " ( "+Transform(dDtIni,"@D")+STR0007+Transform(dDtFin,"@D")+" )"

nLin  := 0
m_pag := 1
Set Printer to &nomeprog
Set Printer On
Set Device  to Printer
DbSelectArea("VES")
DbSetOrder(2)
DbSeek( xFilial("VES") + dtos(dDtIni) , .t. )
SetRegua( 27 )
nDia := 0
While !Eof() .and. VES->VES_FILIAL == xFilial("VES") .and. VES->VES_DATDEM <= dDtFin
	
	If nDia # day(VES->VES_DATDEM)
		nDia := day(VES->VES_DATDEM)
		IncRegua()
	EndIf
	
	If VES->VES_SEMANA == "88" .or. VES->VES_SEMANA == "99"
		DbSelectArea("VES")
		DbSkip()
		Loop
	EndIf
	
	If MV_PAR01 # 3
		If MV_PAR01 == 1 .and. VES->VES_DEMBAL == 0 // Balcao
			DbSelectArea("VES")
			DbSkip()
			Loop
		EndIf
		If MV_PAR01 == 2 .and. VES->VES_DEMOFI == 0 // Oficina
			DbSelectArea("VES")
			DbSkip()
			Loop
		EndIf
	EndIf
	
	nPos := aScan(aAux,{|x| x[1]+x[2] == VES->VES_GRUITE + VES->VES_CODITE })
	
	If nPos == 0
		
		DbSelectArea("SB1")
		DbSetOrder(7)
		DbSeek( xFilial("SB1") + VES->VES_GRUITE + VES->VES_CODITE )
		DbSelectArea("SB2")
		DbSetOrder(1)
		DbSeek( xFilial("SB2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") )
		DbSelectArea("SB5")
		DbSetOrder(1)
		DbSeek( xFilial("SB5") + SB1->B1_COD )
		
		nQtdAtu := SB2->B2_QATU
		nVlrCus := 0
		nVlrVda := 0
		
		nVlrCus := SB5->B5_PRV2
		If nVlrCus == 0
			DbSelectArea("SD1")
			DbSetOrder(7)
			DbSeek( xFilial("SD1") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") + dtos(dDataBase+1) , .t. )
			If !Bof()
				Skip(-1)
			EndIf
			While !Bof() .and. SD1->D1_FILIAL == xFilial("SD1") .and. SB1->B1_COD == SD1->D1_COD
				DbSelectArea("SF4")
				DbSetOrder(1)
				DbSeek( xFilial("SF4") + SD1->D1_TES )
				If SF4->F4_ESTOQUE == "S" .and. SF4->F4_DUPLIC == "S" .and. SF4->F4_OPEMOV == "01"
					nVlrCus := ( SD1->D1_CUSTO / SD1->D1_QUANT )
					Exit
				EndIf
				DbSelectArea("SD1")
				DbSkip(-1)
			EndDo
		EndIf
		
		nVlrVda := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1")
		If nVlrVda == 0
			DbSelectArea("SD2")
			DbSetOrder(6)
			DbSeek( xFilial("SD2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") + dtos(dDataBase+1) , .t. )
			If !Bof()
				Skip(-1)
			EndIf
			While !Bof() .and. SD2->D2_FILIAL == xFilial("SD2") .and. SB1->B1_COD == SD2->D2_COD
				DbSelectArea("SF4")
				DbSetOrder(1)
				DbSeek( xFilial("SF4") + SD2->D2_TES )
				If SF4->F4_ESTOQUE == "S" .and. SF4->F4_DUPLIC == "S" .and. SF4->F4_OPEMOV == "01"
					nVlrVda := SD2->D2_TOTAL / SD2->D2_QUANT
					Exit
				EndIf
				DbSelectArea("SD2")
				DbSkip(-1)
			EndDo
		EndIf
		
	Else
		
		nQtdAtu := aItens[nPos,6]
		nVlrVda := aItens[nPos,7]
		nVlrCus := aItens[nPos,8]
		
	EndIf
	
	nVlr11 := 0 // Demanda 11
	nVlr12 := 0 // Demanda 12
	If MV_PAR02 == 1 // Custo
		If nPos == 0
			nVlr11 += nVlrCus
			nVlr12 += nQtdAtu
		EndIf
	ElseIf MV_PAR02 == 2 // Venda
		If nPos == 0
			nVlr11 += nVlrVda
		EndIf
		If MV_PAR01 == 1 .or. MV_PAR01 == 3 // Balcao ou Todos
			nVlr12 += VES->VES_DEMBAL
		EndIf
		If MV_PAR01 == 2 .or. MV_PAR01 == 3 // Oficina ou Todos
			nVlr12 += VES->VES_DEMOFI
		EndIf
	ElseIf MV_PAR02 == 3 // Estoque
		If nPos == 0
			nVlr11 += 1
			nVlr12 += nQtdAtu
		EndIf
	ElseIf MV_PAR02 == 4 // Demanda
		If nPos == 0
			nVlr11 += 1
		EndIf
		If MV_PAR01 == 1 .or. MV_PAR01 == 3 // Balcao ou Todos
			nVlr12 += VES->VES_DEMBAL
		EndIf
		If MV_PAR01 == 2 .or. MV_PAR01 == 3 // Oficina ou Todos
			nVlr12 += VES->VES_DEMOFI
		EndIf
	EndIf
	
	nVlr21 := 0 // Demanda 21
	nVlr22 := 0 // Demanda 22
	If MV_PAR03 == 1 // Custo
		If nPos == 0
			nVlr21 += nVlrCus
			nVlr22 += nQtdAtu
		EndIf
	ElseIf MV_PAR03 == 2 // Venda
		If nPos == 0
			nVlr21 += nVlrVda
		EndIf
		If MV_PAR01 == 1 .or. MV_PAR01 == 3 // Balcao ou Todos
			nVlr22 += VES->VES_DEMBAL
		EndIf
		If MV_PAR01 == 2 .or. MV_PAR01 == 3 // Oficina ou Todos
			nVlr22 += VES->VES_DEMOFI
		EndIf
	ElseIf MV_PAR03 == 3 // Estoque
		If nPos == 0
			nVlr21 += 1
			nVlr22 += nQtdAtu
		EndIf
	ElseIf MV_PAR03 == 4 // Demanda
		If nPos == 0
			nVlr21 += 1
		EndIf
		If MV_PAR01 == 1 .or. MV_PAR01 == 3 // Balcao ou Todos
			nVlr22 += VES->VES_DEMBAL
		EndIf
		If MV_PAR01 == 2 .or. MV_PAR01 == 3 // Oficina ou Todos
			nVlr22 += VES->VES_DEMOFI
		EndIf
	EndIf
	
	nQtdDem := 0
	nQtdDem += If(MV_PAR01==1.or.MV_PAR01==3,VES->VES_DEMBAL,0)
	nQtdDem += If(MV_PAR01==2.or.MV_PAR01==3,VES->VES_DEMOFI,0)
	
	If nPos == 0
		aAdd(aAux,{ VES->VES_GRUITE , VES->VES_CODITE })
		aAdd(aItens,{ VES->VES_GRUITE +" "+ VES->VES_CODITE , SB1->B1_DESC , nVlr11 , nVlr12 , nVlr21 , nVlr22 , nQtdAtu , nVlrVda , nVlrCus , nQtdDem })
	Else
		aItens[nPos,3] += nVlr11
		aItens[nPos,4] += nVlr12
		aItens[nPos,5] += nVlr21
		aItens[nPos,6] += nVlr22
		aItens[nPos,10]+= nQtdDem
	EndIf
	
	DbSelectArea("VES")
	DbSkip()
EndDo

nTot1 := 0
nTot2 := 0
nVlr1 := 0
nVlr2 := 0
aAux  := {}
For ni := 1 to len(aItens)
	nVlr1 := ( aItens[ni,3] * aItens[ni,4] )
	nVlr2 := ( aItens[ni,5] * aItens[ni,6] )
	If nVlr1 > 0 .and. nVlr2 > 0
		aAdd(aAux,{ aItens[ni,1] , aItens[ni,2] , nVlr1 , nVlr2 , "  " , aItens[ni,7] , aItens[ni,8] , aItens[ni,9] , "" , "" , aItens[ni,10] })
		nTot1 += nVlr1
		nTot2 += nVlr2
	EndIf
Next
aItens := aClone(aAux)

nValor := 0
nVlr1  := 0
aSort(aItens,1,,{|x,y| x[3] > y[3] })
For ni := 1 to len(aItens)
	nValor += aItens[ni,3]
	nVlr1  := ( ( nValor / nTot1 ) * 100 )
	If MV_PAR04 >= nVlr1
		cTipo := "A"
	ElseIf ( MV_PAR04 + MV_PAR05 ) >= nVlr1
		cTipo := "B"
	Else
		cTipo := "C"
	EndIf
	aItens[ni,5] := cTipo+substr(aItens[ni,5],2,1)
	aItens[ni,9] := Transform(nVlr1,"@E 99999.9")
Next

nValor := 0
nVlr2  := 0
aSort(aItens,1,,{|x,y| x[4] > y[4] })
For ni := 1 to len(aItens)
	nValor += aItens[ni,4]
	nVlr2  := ( ( nValor / nTot2 ) * 100 )
	If MV_PAR04 >= nVlr2
		cTipo := "A"
	ElseIf ( MV_PAR04 + MV_PAR05 ) >= nVlr2
		cTipo := "B"
	Else
		cTipo := "C"
	EndIf
	aItens[ni,5] := substr(aItens[ni,5],1,1)+cTipo
	aItens[ni,10]:= Transform(nVlr2,"@E 99999.9")
Next

cabec1 := STR0008+" ("+space(3)+"1 - " + If(MV_PAR02==1,STR0009,If(MV_PAR02==2,STR0010,If(MV_PAR02==3,STR0011,STR0012)))
cabec1 += space(3) + "/" + space(3) + "2 - " + If(MV_PAR03==1,STR0009,If(MV_PAR03==2,STR0010,If(MV_PAR03==3,STR0011,STR0012)))+space(3)+")"
cabec2 := STR0013+"12"+STR0014+STR0015+"1"+STR0015+"2"

lImp := .f.
If Alltrim(MV_PAR06) == "*" .or. Empty(MV_PAR06)
	lImp := .t.
EndIf
nLin := 1
nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,ncaracter)+1
aSort(aItens,1,,{|x,y| x[9]+x[10] < y[9]+y[10] })
For ni := 1 to len(aItens)
	If lImp .or. aItens[ni,5] $ MV_PAR06
		If nLin >= 57
			nLin := 1
			nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,ncaracter)+1
		EndIf
		@ nLin++, 000 pSay aItens[ni,1] +" "+ aItens[ni,2] +" "+ aItens[ni,5] + Transform(aItens[ni,6],"@E 9999,999") + Transform(aItens[ni,11],"@E 9999,999") + Transform(aItens[ni,7],"@E 99999,999.99") + Transform(aItens[ni,8],"@E 99999,999.99") + Transform(aItens[ni,8]*aItens[ni,6],"@E 99999,999.99") + aItens[ni,9] + aItens[ni,10]
		If MV_PAR07 == 1
			nQtdNFs := 0
			DbSelectArea("SB1")
			DbSetOrder(7)
			DbSeek( xFilial("SB1") + substr(aItens[ni,1],1,4)+substr(aItens[ni,1],6,27) )
			DbSelectArea("SD1")
			DbSetOrder(7)
			DbSeek( xFilial("SD1") + SB1->B1_COD + "01" + dtos(dDataBase) , .t. )
			If !Bof()
				dbSkip(-1)
			EndIf
			While !Bof() .and. SD1->D1_FILIAL == xFilial("SD1") .and. SB1->B1_COD == SD1->D1_COD
				DbSelectArea("SF4")
				DbSetOrder(1)
				DbSeek( xFilial("SF4") + SD1->D1_TES )
				If SF4->F4_ESTOQUE == "S" .and. SF4->F4_DUPLIC == "S" .and. SF4->F4_OPEMOV == "01"
					DbSelectArea("SA2")
					DbSetOrder(1)
					DbSeek( xFilial("SA2") + SD1->D1_FORNECE + SD1->D1_LOJA )
					nQtdNFs++
					@ nLin++, 007 pSay Transform(SD1->D1_DTDIGIT,"@D") + Transform((((SD1->D1_TOTAL+SD1->D1_VALIPI+SD1->D1_ICMSRET+SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA)-SD1->D1_VALDESC)/SD1->D1_QUANT),"@E 99999,999.99") + Transform(SD1->D1_QUANT,"@E 999,999") + Transform((SD1->D1_PICM),"@E 9999") +"%  "+ subs(SA2->A2_NOME,1,25) +"  "+ SA2->A2_EST
					If nQtdNFs >= 3
						Exit
					EndIf
				EndIf
				DbSelectArea("SD1")
				DbSkip(-1)
			EndDo
			nLin++
		EndIf
	EndIf
Next

Eject
Set Printer to
Set Device  to Screen

Return