// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 13     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#Include "Protheus.ch"
#Include "OFIOC270.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOC270 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 21/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta/Impressao do Orcamento                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC270()
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nTam      := 0
Private cTitulo := STR0001
Private cTipOrc := ""
Private aTipOrc := {STR0006,STR0007,STR0008,STR0009,STR0010}
Private cFase   := STR0002
Private aFase   := {STR0002,STR0003,STR0004,STR0005}
Private aCond   := {}
Private dDtI := dDataBase
Private dDtF := dDataBase
Private cCli := space(TamSX3("A1_COD")[1])
Private cLoj := space(TamSX3("A1_LOJA")[1])
Private cNom := space(TamSX3("A1_NOME")[1])
Private cVen := space(TamSX3("VAI_CODVEN")[1])
Private cVend:= space(TamSX3("A3_NOME")[1])
Private aOC270Orc := {}
Private lTem := .f.
Private nQtd := 0
Private nOpca := 4
Private nQtdTot := nQtdOrc := nQtdPed := nQtdNFs := 0
Private nVlrTot := nVlrOrc := nVlrPed := nVlrNFs := 0
DbSelectArea("VAI")
DbSetOrder(4)
DbSeek(xFilial("VAI")+__cUserID)
cVen := VAI->VAI_CODVEN
FS_VAL("VEN")

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 51 , .T. , .F. } ) // Topo
aAdd( aObjects, { 0 , 60 , .T. , .T. } ) // ListBox 1
aAdd( aObjects, { 0 , 40 , .T. , .T. } ) // ListBox 2
aAdd( aObjects, { 0 , 22 , .T. , .F. } ) // Totais
aPos := MsObjSize( aInfo, aObjects )

DbSelectArea("VS1")
DbClearFilter()
// 14 - Codigo do Modulo Oficina
// 41 - Codigo do Modulo Pecas
If nModulo == 14
	cTipOrc := STR0009
Else
	cTipOrc := STR0006
EndIf
Processa( {|| FS_Filtro(1) } )

DEFINE MSDIALOG oOC270Orc FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE cTitulo OF oMainWnd PIXEL

@ aPos[1,1]+000,aPos[1,2]+000 TO aPos[1,3],aPos[1,2]+300 LABEL "" OF oOC270Orc PIXEL
@ aPos[1,1]+004,aPos[1,2]+003 SAY (STR0011+":") SIZE 40,08 OF oOC270Orc PIXEL COLOR CLR_BLUE
@ aPos[1,1]+004,aPos[1,2]+033 MSCOMBOBOX oTipoOrc VAR cTipOrc SIZE 75,10 ITEMS aTipOrc OF oOC270Orc PIXEL COLOR CLR_BLUE
@ aPos[1,1]+004,aPos[1,2]+113 SAY (STR0012+":") SIZE 40,08 OF oOC270Orc PIXEL COLOR CLR_BLUE
@ aPos[1,1]+004,aPos[1,2]+130 MSCOMBOBOX oFase VAR cFase SIZE 42,10 ITEMS aFase OF oOC270Orc PIXEL COLOR CLR_BLUE
@ aPos[1,1]+015,aPos[1,2]+003 SAY (STR0013+":") SIZE 40,08 OF oOC270Orc PIXEL COLOR CLR_BLUE
@ aPos[1,1]+015,aPos[1,2]+033 MSGET oDtI VAR dDtI PICTURE "@D" SIZE 40,08 OF oOC270Orc PIXEL COLOR CLR_BLUE
@ aPos[1,1]+015,aPos[1,2]+074 SAY STR0014 SIZE 20,08 OF oOC270Orc PIXEL COLOR CLR_BLUE
@ aPos[1,1]+015,aPos[1,2]+083 MSGET oDtF VAR dDtF PICTURE "@D" VALID (dDtF >= dDtI) SIZE 40,08 OF oOC270Orc PIXEL COLOR CLR_BLUE
@ aPos[1,1]+026,aPos[1,2]+003 SAY (STR0015+":") SIZE 40,08 OF oOC270Orc PIXEL COLOR CLR_BLUE
@ aPos[1,1]+026,aPos[1,2]+033 MSGET oCli VAR cCli PICTURE PesqPict("SA1","A1_COD") F3 "SA1" VALID FS_VAL("CLI") SIZE 20,08 OF oOC270Orc PIXEL COLOR CLR_BLUE
@ aPos[1,1]+026,aPos[1,2]+065 MSGET oLoj VAR cLoj PICTURE PesqPict("SA1","A1_LOJA") VALID FS_VAL("LOJ") SIZE 10,08 OF oOC270Orc PIXEL COLOR CLR_BLUE
@ aPos[1,1]+026,aPos[1,2]+093 SAY cNom SIZE 200,08 OF oOC270Orc PIXEL COLOR CLR_BLUE
@ aPos[1,1]+037,aPos[1,2]+003 SAY (STR0016+":") SIZE 40,08 OF oOC270Orc PIXEL COLOR CLR_BLUE
@ aPos[1,1]+037,aPos[1,2]+033 MSGET oVen VAR cVen PICTURE PesqPict("VAI","VAI_CODVEN") F3 "SA3" VALID FS_VAL("VEN") SIZE 20,08 OF oOC270Orc PIXEL COLOR CLR_BLUE
@ aPos[1,1]+037,aPos[1,2]+070 SAY cVend SIZE 200,08 OF oOC270Orc PIXEL COLOR CLR_BLUE

@ aPos[1,1]+005,aPos[1,2]+210 BUTTON oFiltrar  PROMPT STR0017 OF oOC270Orc SIZE 65,10 PIXEL ACTION ( Processa( {|| FS_Filtro(2) } ) )
@ aPos[1,1]+015,aPos[1,2]+210 SAY (If(nQtd>0,Transform(nQtd,"@E 999,999")+" "+STR0024,"")) SIZE 120,08 OF oOC270Orc PIXEL COLOR CLR_RED
@ aPos[1,1]+010,aPos[1,4]-080 BUTTON oConsult  PROMPT STR0019 OF oOC270Orc SIZE 65,10 PIXEL ACTION FS_VERORC(aOC270Orc[oOrcLx:nAt,1]) WHEN lTem

@ aPos[1,1]+030,aPos[1,4]-080 BUTTON oImprimir PROMPT STR0020 OF oOC270Orc SIZE 65,10 PIXEL ACTION FS_IMPORC(aOC270Orc[oOrcLx:nAt,1]) WHEN lTem

@ aPos[2,1],aPos[2,2] LISTBOX oOrcLx FIELDS HEADER STR0003,STR0011,STR0013,STR0015,STR0016,STR0004,STR0022,STR0023 COLSIZES 30,15,20,75,35,22,58,33 SIZE aPos[2,4]-2,aPos[2,3]-aPos[2,1] OF oOC270Orc PIXEL
oOrcLx:SetArray(aOC270Orc)
oOrcLx:bLine := { || {	aOC270Orc[oOrcLx:nAt,1],;
aOC270Orc[oOrcLx:nAt,2],;
aOC270Orc[oOrcLx:nAt,3],;
aOC270Orc[oOrcLx:nAt,4],;
aOC270Orc[oOrcLx:nAt,5],;
aOC270Orc[oOrcLx:nAt,6],;
aOC270Orc[oOrcLx:nAt,7],;
FG_AlinVlrs(Transform(aOC270Orc[oOrcLx:nAt,8],"@E 999,999,999.99"))}}

@ aPos[3,1],aPos[3,2] LISTBOX oCondLx FIELDS HEADER STR0041,STR0025,STR0026,STR0027,STR0028 COLSIZES 70,80,80,80,80 SIZE aPos[3,4]-2,aPos[3,3]-aPos[3,1] OF oOC270Orc PIXEL
oCondLx:SetArray(aCond)
oCondLx:bLine := { || {	aCond[oCondLx:nAt,1],;
FG_AlinVlrs(Transform(aCond[oCondLx:nAt,2],"@E 999,999,999.99"))+Transform((aCond[oCondLx:nAt,2]/aCond[1,2])*100,"@E 9999")+"%" ,;
FG_AlinVlrs(Transform(aCond[oCondLx:nAt,3],"@E 999,999,999.99"))+Transform((aCond[oCondLx:nAt,3]/aCond[oCondLx:nAt,2])*100,"@E 9999")+"%" ,;
FG_AlinVlrs(Transform(aCond[oCondLx:nAt,4],"@E 999,999,999.99"))+Transform((aCond[oCondLx:nAt,4]/aCond[oCondLx:nAt,2])*100,"@E 9999")+"%" ,;
FG_AlinVlrs(Transform(aCond[oCondLx:nAt,5],"@E 999,999,999.99"))+Transform((aCond[oCondLx:nAt,5]/aCond[oCondLx:nAt,2])*100,"@E 9999")+"%" }}

nTam := ( aPos[4,4] / 8 )

@ aPos[4,1]+008,aPos[4,2]+(nTam*0)+003 MSGET oQtdTot VAR nQtdTot PICTURE "@E 999,999" SIZE nTam-4,08 OF oOC270Orc PIXEL COLOR CLR_BLUE WHEN .f.
@ aPos[4,1]+008,aPos[4,2]+(nTam*1)+000 MSGET oVlrTot VAR nVlrTot PICTURE "@E 999,999.99" SIZE nTam-2,08 OF oOC270Orc PIXEL COLOR CLR_BLUE WHEN .f.

@ aPos[4,1]+008,aPos[4,2]+(nTam*2)+003 MSGET oQtdOrc VAR nQtdOrc PICTURE "@E 999,999" SIZE nTam-4,08 OF oOC270Orc PIXEL COLOR CLR_BLUE WHEN .f.
@ aPos[4,1]+008,aPos[4,2]+(nTam*3)+000 MSGET oVlrOrc VAR nVlrOrc PICTURE "@E 999,999.99" SIZE nTam-2,08 OF oOC270Orc PIXEL COLOR CLR_BLUE WHEN .f.

@ aPos[4,1]+008,aPos[4,2]+(nTam*4)+003 MSGET oQtdPed VAR nQtdPed PICTURE "@E 999,999" SIZE nTam-4,08 OF oOC270Orc PIXEL COLOR CLR_BLUE WHEN .f.
@ aPos[4,1]+008,aPos[4,2]+(nTam*5)+000 MSGET oVlrPed VAR nVlrPed PICTURE "@E 999,999.99" SIZE nTam-2,08 OF oOC270Orc PIXEL COLOR CLR_BLUE WHEN .f.

@ aPos[4,1]+008,aPos[4,2]+(nTam*6)+003 MSGET oQtdNFs VAR nQtdNFs PICTURE "@E 999,999" SIZE nTam-4,08 OF oOC270Orc PIXEL COLOR CLR_BLUE WHEN .f.
@ aPos[4,1]+008,aPos[4,2]+(nTam*7)+000 MSGET oVlrNFs VAR nVlrNFs PICTURE "@E 999,999.99" SIZE nTam-4,08 OF oOC270Orc PIXEL COLOR CLR_BLUE WHEN .f.

@ aPos[4,1]+000,aPos[4,2]+(nTam*0) TO aPos[4,3],aPos[4,2]+(nTam*2) LABEL (" "+STR0025+" ") OF oOC270Orc PIXEL
@ aPos[4,1]+000,aPos[4,2]+(nTam*2) TO aPos[4,3],aPos[4,2]+(nTam*4) LABEL (" "+STR0026+" ") OF oOC270Orc PIXEL
@ aPos[4,1]+000,aPos[4,2]+(nTam*4) TO aPos[4,3],aPos[4,2]+(nTam*6) LABEL (" "+STR0027+" ") OF oOC270Orc PIXEL
@ aPos[4,1]+000,aPos[4,2]+(nTam*6) TO aPos[4,3],aPos[4,2]+(nTam*8) LABEL (" "+STR0028+" ") OF oOC270Orc PIXEL

ACTIVATE MSDIALOG oOC270Orc ON INIT EnchoiceBar(oOC270Orc,{ || oOC270Orc:End() }, { || oOC270Orc:End() },,)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  FS_VAL  ³ Autor ³ Andre Luis Almeida    ³ Data ³ 21/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacaoes da Tela                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VAL(cT)
Local lRet := .f.
If cT # "VEN"
	cNom := space(TamSX3("A1_NOME")[1])
	If cT == "CLI" .and. Empty(cCli)
		cLoj := space(TamSX3("A1_LOJA")[1])
		lRet := .t.
	EndIf
	If !Empty(Alltrim(cCli+cLoj))
		DbSelectArea("SA1")
		DbSetOrder(1)
		If DbSeek( xFilial("SA1") + cCli + If(cT#"CLI",cLoj,"") )
			lRet := .t.
			cLoj := SA1->A1_LOJA
			cNom := SA1->A1_NOME
		EndIf
	Else
		lRet := .t.
	EndIf
Else
	cVend := space(TamSX3("A3_NOME")[1])
	If !Empty(Alltrim(cVen))
		DbSelectArea("SA3")
		DbSetOrder(1)
		If DbSeek( xFilial("SA3") + cVen )
			cVend := SA3->A3_NOME
			lRet  := .t.
		EndIf
	Else
		lRet := .t.
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_Filtro³ Autor ³ Andre Luis Almeida    ³ Data ³ 21/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtro da Tela                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_Filtro(nX)
Local cPos1 := ""
Local cPos2 := ""
Local ni    := 0
Local nVlr  := 0
Local lFase := .t.
Local cQuery := ""
Local cQAlVS1:= "SQLVS1"
Local cNF   := ""
Local lBlock:= ExistBlock("OFC270")
aOC270Orc := {}
aCond:= {}
Aadd(aCond,{ Upper(STR0025) , 0 , 0 , 0 , 0 , "  " } )
Aadd(aCond,{ "   "+Upper(STR0029) , 0 , 0 , 0 , 0 , "AA" } )
Aadd(aCond,{ "   "+Upper(STR0030) , 0 , 0 , 0 , 0 , "PA" } )
Aadd(aCond,{ "   "+Upper(STR0031) , 0 , 0 , 0 , 0 , "SA" } )
nQtd := 0
lTem := .t.
nQtdTot := nQtdOrc := nQtdPed := nQtdNFs := 0
nVlrTot := nVlrOrc := nVlrPed := nVlrNFs := 0
cQuery := "SELECT * FROM "+RetSqlName("VS1")+" VS1 WHERE VS1.VS1_FILIAL='"+xFilial("VS1")+"' AND "
cQuery += "VS1.VS1_DATORC>='"+dtos(dDtI)+"' AND VS1.VS1_DATORC<='"+dtos(dDtF)+"' AND "
If cTipOrc # STR0010
	If cTipOrc == STR0009
		cQuery += "VS1.VS1_TIPORC='2' AND "
	Else
		cQuery += "VS1.VS1_TIPORC='1' AND "
		If cTipOrc == STR0007
			cQuery += "VS1.VS1_NOROUT='1' AND "
		ElseIf cTipOrc == STR0008
			cQuery += "VS1.VS1_NOROUT='2' AND "
		EndIf
	EndIf
EndIf
If !Empty(cCli+cLoj)
	cQuery += "VS1.VS1_CLIFAT='"+cCli+"' AND VS1.VS1_LOJA='"+cLoj+"' AND "
EndIf
If !Empty(cVen)
	cQuery += "VS1.VS1_CODVEN='"+cVen+"' AND "
EndIf
cQuery += "VS1.D_E_L_E_T_=' '"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVS1, .F., .T. )
Do While !( cQAlVS1 )->( Eof() )
	cNF := ""
	If lBlock
		cNF := ExecBlock("OFC270",.f.,.f.,{( cQAlVS1 )->( VS1_NUMORC )})
	EndIf
	If Empty(cNF) .and. !Empty( ( cQAlVS1 )->( VS1_NUMNFI ) + FGX_UFSNF((cQAlVS1)->(VS1_SERNFI)) )
		cNF := ( cQAlVS1 )->( VS1_NUMNFI ) +"-"+ FGX_UFSNF((cQAlVS1)->(VS1_SERNFI))
	EndIf
	nVlr := ( cQAlVS1 )->( VS1_VTOTNF )
	lFase := .t.
	If !Empty( cNF )
		If cFase # STR0002 .and. cFase # STR0005
			lFase := .f.
		Else
			ni := 5
			nQtdNFs++
			nVlrNFs += nVlr
		EndIf
	ElseIf !Empty( ( cQAlVS1 )->( VS1_NUMPED ) ) .and. Empty( cNF )
		If cFase # STR0002 .and. cFase # STR0004
			lFase := .f.
		Else
			ni := 4
			nQtdPed++
			nVlrPed += nVlr
		EndIf
	ElseIf Empty( cNF ) .and. Empty( ( cQAlVS1 )->( VS1_NUMPED ) )
		If cFase # STR0002 .and. cFase # STR0003
			lFase := .f.
		Else
			ni := 3
			nQtdOrc++
			nVlrOrc += nVlr
		EndIf
	EndIf
	If lFase
		nQtdTot++
		nVlrTot += nVlr
		FS_COND(( cQAlVS1 )->( VS1_FORPAG ),ni,nVlr)
		If cPos1 # ( cQAlVS1 )->( VS1_CLIFAT ) + ( cQAlVS1 )->( VS1_LOJA )
			cPos1 := ( cQAlVS1 )->( VS1_CLIFAT ) + ( cQAlVS1 )->( VS1_LOJA )
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + cPos1 )
		EndIf
		If cPos2 # ( cQAlVS1 )->( VS1_CODVEN )
			cPos2 := ( cQAlVS1 )->( VS1_CODVEN )
			DbSelectArea("SA3")
			DbSetOrder(1)
			DbSeek( xFilial("SA3") + cPos2 )
		EndIf
		Aadd(aOC270Orc,{ ( cQAlVS1 )->( VS1_NUMORC ) , If(( cQAlVS1 )->( VS1_TIPORC )<>"2",upper(left(STR0032,3)),upper(left(STR0033,3))) , Transform(stod(( cQAlVS1 )->( VS1_DATORC )),"@D") , ( cQAlVS1 )->( VS1_CLIFAT )+"-"+( cQAlVS1 )->( VS1_LOJA )+" "+left(SA1->A1_NOME,20) , ( cQAlVS1 )->( VS1_CODVEN )+" "+left(SA3->A3_NOME,10) , ( cQAlVS1 )->( VS1_NUMPED ) , cNF , nVlr } )
	EndIf
	( cQAlVS1 )->( DbSkip() )
EndDo
( cQAlVS1 )->( dbCloseArea() )
If len(aOC270Orc) == 0
	lTem := .f.
	Aadd(aOC270Orc,{ " " , " " , " " , " " , " " , " " , " " , 0 } )
Else
	nQtd := len(aOC270Orc)
	aSort(aOC270Orc,1,,{|x,y| x[1] > y[1] })
	aSort(aCond,1,,{|x,y| x[6]+x[1] < y[6]+y[1] })
EndIf
If nX # 1
	oOrcLx:nAt := 1
	oOrcLx:SetArray(aOC270Orc)
	oOrcLx:bLine := { || {	aOC270Orc[oOrcLx:nAt,1],;
	aOC270Orc[oOrcLx:nAt,2],;
	aOC270Orc[oOrcLx:nAt,3],;
	aOC270Orc[oOrcLx:nAt,4],;
	aOC270Orc[oOrcLx:nAt,5],;
	aOC270Orc[oOrcLx:nAt,6],;
	aOC270Orc[oOrcLx:nAt,7],;
	FG_AlinVlrs(Transform(aOC270Orc[oOrcLx:nAt,8],"@E 999,999,999.99"))}}
	oOrcLx:Refresh()
	oCondLx:nAt := 1
	oCondLx:SetArray(aCond)
	oCondLx:bLine := { || {	aCond[oCondLx:nAt,1],;
	FG_AlinVlrs(Transform(aCond[oCondLx:nAt,2],"@E 999,999,999.99"))+Transform((aCond[oCondLx:nAt,2]/aCond[1,2])*100,"@E 9999")+"%" ,;
	FG_AlinVlrs(Transform(aCond[oCondLx:nAt,3],"@E 999,999,999.99"))+Transform((aCond[oCondLx:nAt,3]/aCond[oCondLx:nAt,2])*100,"@E 9999")+"%" ,;
	FG_AlinVlrs(Transform(aCond[oCondLx:nAt,4],"@E 999,999,999.99"))+Transform((aCond[oCondLx:nAt,4]/aCond[oCondLx:nAt,2])*100,"@E 9999")+"%" ,;
	FG_AlinVlrs(Transform(aCond[oCondLx:nAt,5],"@E 999,999,999.99"))+Transform((aCond[oCondLx:nAt,5]/aCond[oCondLx:nAt,2])*100,"@E 9999")+"%" }}
	oCondLx:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_IMPORC ³ Autor ³ Andre Luis Almeida    ³ Data ³ 21/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao do Orcamento                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPORC(cNumOrc)
Local nAviso := 0
Private cTitulo   := STR0034
Private cDesc1    := cTitulo
Private cDesc2    := ""
Private cDesc3    := ""
Private cAlias    := "SD2"
Private aReturn   := {STR0035,1,STR0036,2,2,1,"",1}
Private nLin      := 0
Private cTamanho  := "M" // P/M/G
Private Limite    := 132 // 80/132/220
Private cNomeRel  := "OFIOC270"
Private nLastKey  := 0
Private nCaracter := 15
Private cabec1    := STR0013+": "+Transform(dDtI,"@D")+" "+STR0014+" "+ Transform(dDtF,"@D")+"  "+STR0011+": "+cTipOrc+"  "+STR0012+": "+cFase
Private cabec2    := ""
Private lAbortPrint := .f.
Private cbTxt    := Space(10)
Private cbCont   := 0
Private cString  := "VS1"
Private Li       := 132
Private m_Pag    := 1
Private cPerg    := nil
If !Empty(cCli+cLoj)
	cabec2 += STR0015+": "+cCli+" - "+cLoj+"  "
EndIf
If !Empty(cVen)
	cabec2 += STR0016+": "+cVen
EndIf
If !Empty(cNumOrc)
	nAviso := AVISO(STR0037,STR0038,{STR0039,STR0040})
	If nAviso == 1
		DbSelectArea("VS1")
		DbSetOrder(1)
		If DbSeek( xFilial("VS1") + cNumOrc )
			If ExistBlock("ORCAMTO") // Executa RdMake de Impressao do Orcamento
				ExecBlock("ORCAMTO",.f.,.f.,{VS1->VS1_NUMORC})
			EndIf
		EndIf
	ElseIf nAviso == 2
		cNomeRel := SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
		If nLastKey == 27
			Return
		EndIf
		SetDefault(aReturn,cAlias)
		RptStatus( { |lEnd| FS_RELATORIO(@lEnd,cNomeRel,cAlias) } , cTitulo )
		If aReturn[5] == 1
			OurSpool( cNomeRel )
			MS_FLUSH()
		EndIf
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_IMPORC ³ Autor ³ Andre Luis Almeida    ³ Data ³ 21/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Condicoes de Pagamentos                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_COND(cForPag,ni,nVlr)
Local nPos := 0
DbSelectArea("SE4")
DbSetOrder(1)
DbSeek( xFilial("SE4") + cForPag )
nPos := aScan(aCond, {|x| left(x[1],9) == space(6)+cForPag })
If nPos == 0
	Aadd(aCond,{ space(6)+cForPag+" - "+SE4->E4_DESCRI , 0 , 0 , 0 , 0 , If(!Empty(cForPag),If(Alltrim(SE4->E4_COND)=="0","AX","PX"),"SX") } )
	nPos := len(aCond)
EndIf
aCond[1,2]  += nVlr
aCond[1,ni] += nVlr
If !Empty(cForPag)
	If Alltrim(SE4->E4_COND) == "0"
		aCond[2,2]  += nVlr
		aCond[2,ni] += nVlr
	Else
		aCond[3,2]  += nVlr
		aCond[3,ni] += nVlr
	EndIf
Else
	aCond[4,2]  += nVlr
	aCond[4,ni] += nVlr
EndIf
aCond[nPos,2]  += nVlr
aCond[nPos,ni] += nVlr
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_RELATORIO³ Autor ³ Andre Luis Almeida  ³ Data ³ 21/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio dos Orcamentos                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_RELATORIO()
Local nTot1 := 0
Local nTot2 := 0
Local nTot3 := 0
Local nTot4 := 0
Local ni := 0
Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer
nLin := cabec(ctitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1
@ nLin++,02 psay STR0042
nLin++
For ni := 1 to Len(aOC270Orc)
	If nLin >= 58
		nLin := cabec(ctitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1
		@ nLin++,02 psay STR0042
		nLin++
	EndIf
	@ nLin++,02 psay aOC270Orc[ni,1]+" "+aOC270Orc[ni,2]+" "+aOC270Orc[ni,3]+" "+aOC270Orc[ni,4]+" "+aOC270Orc[ni,5]+" "+aOC270Orc[ni,6]+" "+left(aOC270Orc[ni,7]+space(28),28)+" "+Transform(aOC270Orc[ni,8],"@E 999,999,999.99")
	nTot1 += aOC270Orc[ni,8]
	If !Empty(aOC270Orc[ni,7]) // NF
		nTot4 += aOC270Orc[ni,8]
	ElseIf !Empty(aOC270Orc[ni,6]) // Pedidos
		nTot3 += aOC270Orc[ni,8]
	Else // Orcamentos
		nTot2 += aOC270Orc[ni,8]
	EndIf
Next
If nLin > 43
	nLin := cabec(ctitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1
EndIf
nLin++
@ nLin++,04 psay STR0043
nLin++
@ nLin++,08 psay left(STR0041+space(35),35)+STR0044
nLin++
For ni := 1 to Len(aCond)
	If nLin >= 58
		nLin := cabec(ctitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1
		@ nLin++,04 psay STR0045
		nLin++
		@ nLin++,08 psay left(STR0041+space(35),35)+STR0044
		nLin++
	EndIf
	@ nLin++,08 psay left(aCond[ni,1]+space(30),30)+Transform(aCond[ni,2],"@E 999,999,999.99")+Transform((aCond[ni,2]/aCond[1,2])*100,"@E 9999")+"%"+Transform(aCond[ni,3],"@E 999,999,999.99")+Transform((aCond[ni,3]/aCond[ni,2])*100,"@E 9999")+"%"+Transform(aCond[ni,4],"@E 999,999,999.99")+Transform((aCond[ni,4]/aCond[ni,2])*100,"@E 9999")+"%"+Transform(aCond[ni,5],"@E 999,999,999.99")+Transform((aCond[ni,5]/aCond[ni,2])*100,"@E 9999")+"%"
Next
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VERORC ³ Autor ³ Andre Luis Almeida    ³ Data ³ 21/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ver Orcamento                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERORC(cSeek)
cCadastro := STR0003 // Orcamento
DbSelectArea("VS1")
DbSetOrder(1)
If DbSeek( xFilial("VS1") + cSeek )
	OFIC170( VS1->VS1_FILIAL , VS1->VS1_NUMORC )
EndIf
Return()