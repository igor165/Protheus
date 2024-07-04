// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 0      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "VEIVC100.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVC100 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 26/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Avaliacao de Veiculos                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVC100(cPAREmp,aPAREmp,dPARDtI,dPARDtF,cPARMar,cPARGru,cPARMod,cPARPer)
Local lDClik    := .f.
Local aFWArrFilAtu := FWArrFilAtu()
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Private lImprimir := .t.
Private lMarcar := .f.
Private aVetEmp := {}
Private aEmpr   := {} // Empresas Consolidadas
Private cEmpr   := "" // Nome da Empresa
Private aAVei   := {} // Avaliacao de Veiculos
Private aVlrs   := {} // Valores Avaliacao
Private aPerc   := {}
Private cPerc   := "A"
Private nPerc   := 1
Private cLinhas := "ABCDEFGHIJKL"
Private dDatIni := (dDataBase+1)-(day(dDataBase))
Private dDatFin := dDataBase
Private cPerg   := "VVC100"
Private nPerg   := 0
Private nQtdVda := 0
Private cCodMar := space(3)
Private cGruVei := space(30)
Private cModVei := space(30)
Default cPAREmp := ""
Default aPAREmp := aEmpr
Default dPARDtI := dDatIni
Default dPARDtF := dDatFin
Default cPARMar := cCodMar
Default cPARGru := cGruVei
Default cPARMod := cModVei
Default cPARPer := cPerc
aEmpr := aPAREmp
If !Empty(cPAREmp)
	cEmpr := STR0001
	aEmpr := FS_FILIAIS() // Levantamento das Filiais
	If len(aEmpr) == 0
		MsgAlert(STR0003,STR0002)
		Return
	EndIf
Else
	aAdd(aEmpr,{ cFilAnt , aFWArrFilAtu[SM0_FILIAL] })
EndIf
If len(aEmpr) == 1 .and. (aEmpr[1,1]==cFilAnt)
	cEmpr := " - "+Alltrim(FWFilialName())+" ( "+cFilAnt+" )"
EndIf
dDatIni := dPARDtI
dDatFin := dPARDtF
cCodMar := cPARMar
cGruVei := cPARGru
cModVei := cPARMod
cPerc   := cPARPer

aInfo := { aSizeHalf[ 1 ] , aSizeHalf[ 2 ] , aSizeHalf[ 3 ] , aSizeHalf[ 4 ] , 3 , 3 } // Tamanho total da tela
aAdd( aObjects, { 0 ,  21 , .T. , .F. } ) // Topo
aAdd( aObjects, { 0 , 100 , .T. , .T. } ) // ListBox 
aAdd( aObjects, { 0 ,  13 , .T. , .F. } ) // Rodape
aPos := MsObjSize( aInfo, aObjects )

Processa( {|| FS_LEVANT(0) } )
DbSelectArea("VE1")
DbSelectArea("VVR")
DbSelectArea("VV2")
DEFINE MSDIALOG oAvaVei FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0005+cEmpr) PIXEL OF oMainWnd   //Avaliacao de Veiculos
@ aPos[1,1]+000,aPos[1,2]+000 TO aPos[1,1]+021,aPos[1,4]-2 LABEL STR0006 OF oAvaVei PIXEL  //Filtrar
@ aPos[1,1]+008,aPos[1,2]+006 SAY STR0007 SIZE 30,08 OF oAvaVei PIXEL COLOR CLR_BLUE //Periodo:
@ aPos[1,1]+007,aPos[1,2]+027 MSGET oDatIni VAR dDatIni PICTURE "@D" VALID(( dDatIni <= dDataBase ).and.FS_REFRIMP(.F.)) SIZE 40,06 OF oAvaVei PIXEL COLOR CLR_BLUE
@ aPos[1,1]+008,aPos[1,2]+071 SAY STR0008 SIZE 10,08 OF oAvaVei PIXEL COLOR CLR_BLUE  //a
@ aPos[1,1]+007,aPos[1,2]+075 MSGET oDatFin VAR dDatFin PICTURE "@D" VALID(( dDatIni <= dDatFin .and. dDatFin <= dDataBase ).and.FS_REFRIMP(.F.)) SIZE 40,06 OF oAvaVei PIXEL COLOR CLR_BLUE
@ aPos[1,1]+008,aPos[1,2]+121 SAY STR0009 SIZE 25,06 OF oAvaVei PIXEL COLOR CLR_BLUE  //Marca:
@ aPos[1,1]+007,aPos[1,2]+138 MSGET oCodMar VAR cCodMar F3 "VE1" VALID(FS_REFRIMP(.F.)) SIZE 20,06 OF oAvaVei PIXEL COLOR CLR_BLUE
@ aPos[1,1]+008,aPos[1,2]+169 SAY STR0010 SIZE 25,06 OF oAvaVei PIXEL COLOR CLR_BLUE  //Grupo:
@ aPos[1,1]+007,aPos[1,2]+186 MSGET oGruVei VAR cGruVei F3 "VVR" VALID(FS_REFRIMP(.F.)) SIZE 65,06 OF oAvaVei PIXEL COLOR CLR_BLUE
@ aPos[1,1]+008,aPos[1,2]+253 SAY STR0011 SIZE 25,06 OF oAvaVei PIXEL COLOR CLR_BLUE  //Modelo:
@ aPos[1,1]+007,aPos[1,2]+272 MSGET oModVei VAR cModVei F3 "VV2" VALID(FS_REFRIMP(.F.)) SIZE 68,06 OF oAvaVei PIXEL COLOR CLR_BLUE
@ aPos[1,1]+007,aPos[1,2]+343 BUTTON oOk PROMPT STR0012 OF oAvaVei SIZE 20,09 PIXEL ACTION Processa( {|| FS_LEVANT(1) } )  //Ok
@ aPos[3,1]+004,aPos[3,2]+007 SAY STR0013 SIZE 50,06 OF oAvaVei PIXEL COLOR CLR_BLUE  //Linha base para %:
@ aPos[3,1]+003,aPos[3,2]+057 MSCOMBOBOX oAvaComb VAR cPerc ITEMS aPerc VALID Processa( {|| FS_LEVANT(3) } ) SIZE 080,06 OF oAvaVei PIXEL COLOR CLR_BLUE
@ aPos[3,1]+004,aPos[3,2]+175 SAY (STR0014 +Transform(nQtdVda,"@E 9999,999")) SIZE 70,06 OF oAvaVei PIXEL COLOR CLR_BLUE   //Qtd.Vendas:
@ aPos[3,1]+003,aPos[3,4]-100 BUTTON oImpr PROMPT STR0015 OF oAvaVei SIZE 45,10 PIXEL ACTION FS_IMPRIMIR() WHEN lImprimir   //Imprimir"
@ aPos[1,1]+007,aPos[1,4]-050 BUTTON oEmpr PROMPT UPPER(STR0016) OF oAvaVei SIZE 45,10 PIXEL ACTION (lDClik:=.t.,oAvaVei:End())  //Filiais
@ aPos[2,1]+000,aPos[2,2]+000 LISTBOX oLbVlr FIELDS HEADER (STR0017),(STR0018),(STR0019),(STR0020) COLSIZES 060,210,060,030 SIZE aPos[2,4]-4,aPos[2,3]-aPos[2,1] OF oAvaVei PIXEL ON DBLCLICK FS_LEVANT(2)    //Linha # Descricao  # Valor  # Percentual Linha
oLbVlr:SetArray(aVlrs)
oLbVlr:bLine := { || {IIf(len(aVlrs[oLbVlr:nAt,3])==1,space(18)," ")+aVlrs[oLbVlr:nAt,3],aVlrs[oLbVlr:nAt,1],IIf(aVlrs[oLbVlr:nAt,4],FG_AlinVlrs(Transform(aVlrs[oLbVlr:nAt,2],"@EZ 999,999,999,999.99")),space(10)+ STR0023),IIf(aVlrs[oLbVlr:nAt,4].and.!Empty(aVlrs[oLbVlr:nAt,1]),FG_AlinVlrs(Transform((aVlrs[oLbVlr:nAt,2]/aVlrs[nPerc,2])*100,"@E 99999")+"%")+" "+IIf(ascan(aPerc,aVlrs[oLbVlr:nAt,3])==nPerc,"<<",""),"")}} //"Invalido
@ aPos[3,1]+003,aPos[3,4]-050 BUTTON oSair PROMPT STR0021 OF oAvaVei SIZE 45,10 PIXEL ACTION oAvaVei:End() //<<<  S A I R  >>>
@ aPos[3,1]+003,aPos[3,4]-175 BUTTON oSX1 PROMPT STR0022 OF oAvaVei SIZE 70,10 PIXEL ACTION IIf(FS_MANSX1(),(lDClik:=.t.,oAvaVei:End()),.t.)     //Parametros para Calculo
ACTIVATE MSDIALOG oAvaVei CENTER
If lDClik
	VEIVC100(cEmpr,aEmpr,dDatIni,dDatFin,cCodMar,cGruVei,cModVei,cPerc)
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_LEVANT ³ Autor ³  Andre Luis Almeida   ³ Data ³ 26/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levantamento dos Valores                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVANT(nx)
Local cQuery  := ""
Local cQAlias := "SQLVV9"
Local cQAlAux := "SQLVVG"
Local cUltDat := ""
Local nPos    := 0
Local ni      := 0
Local nEmpr   := 0
Local aAux    := aClone(aVlrs)
Local cAux1   := ""
Local cAux2   := ""
Local cTraCpa := ""
Local nTotal  := 0
Local nTotImp := 0
Local nTotFre := 0
Local nTotCus := 0
Local lRebate := (VV0->(FieldPos("VV0_REBATE"))<>0)
Local cFilSALVA:= cFilAnt
Local cPerg   := left("VVC100"+space(20),len(SX1->X1_GRUPO))
If nx == 2
	PERGUNTE(cPerg,.t.)
Else
	PERGUNTE(cPerg,.f.)
EndIf
nPerg := 0
DbSelectArea("SX1")
DbSetOrder(1)
DbSeek(cPerg)
Do While !Eof() .and. cPerg == SX1->X1_GRUPO
	nPerg++
	DbSkip()
EndDo
For ni := 1 to nPerg
	cAux1 := Alltrim(UPPER(&("MV_PAR"+strzero(ni,2))))
	cAux2 := ""
	For nPos := 1 to len(cAux1)
		If substr(cAux1,nPos,1) # " "
			cAux2 += substr(cAux1,nPos,1)
		EndIf
	Next
	&("cConta"+strzero(ni,2)) := cAux2
Next
aVlrs := {}
If nx < 2
	nQtdVda := 0
	Aadd(aVlrs,{ STR0024 , 0 , "A" , .t. }) // Total das Vendas de Veiculos - 1
	Aadd(aVlrs,{ STR0029+" ( C + D + E )" , 0 , "B" , .t. }) // Impostos ( C + D + E )- 2
	Aadd(aVlrs,{ STR0030 , 0 , "C" , .t. }) //   - ICMS - 3
	Aadd(aVlrs,{ STR0031 , 0 , "D" , .t. }) //   - PIS - 4
	Aadd(aVlrs,{ STR0032 , 0 , "E" , .t. }) //   - COFINS - 5
	Aadd(aVlrs,{ STR0033 , 0 , "F" , .t. }) // Custos - 6
	Aadd(aVlrs,{ STR0034+" ( H + I )" , 0 , "G" , .t. }) // Fretes ( H + I ) - 7
	Aadd(aVlrs,{ STR0035 , 0 , "H" , .t. }) //   - Compra - 8
	Aadd(aVlrs,{ STR0036 , 0 , "I" , .t. }) //   - Entre Lojas - 9
	Aadd(aVlrs,{ STR0037 , 0 , "J" , .t. }) // Rebate Financeiro - 10
	Aadd(aVlrs,{ STR0038 , 0 , "K" , .t. }) // Juros de Estoque - 11
	Aadd(aVlrs,{ STR0039+" ( A - ( B + F ) )" , 0 , "L" , .t. }) // Lucro Bruto ( A - ( B + F ) ) - 12
	For nEmpr := 1 to len(aEmpr)
		cFilAnt := aEmpr[nEmpr,1]
		cQuery := "SELECT VV9.VV9_NUMATE , VV0.VV0_VALMOV , VV0.VV0_DATMOV , VVA.VVA_VCAVEI , VVA.VVA_VALFRE , "
		cQuery += "VVA.VVA_ICMVEN , VVA.VVA_PISVEN , VVA.VVA_COFVEN , VVA.VVA_JUREST , VVA.VVA_CHAINT "
		If lRebate
			cQuery += ", VV0.VV0_REBATE "
		EndIf
		cQuery += "FROM "+RetSqlName("VV9")+" VV9 , "+RetSqlName("VV0")+" VV0 , "+RetSqlName("VVA")+" VVA WHERE "
		cQuery += "VV9.VV9_FILIAL='"+xFilial("VV9")+"' AND VV9.VV9_STATUS IN ('F','T') AND VV9.D_E_L_E_T_=' ' AND "
		cQuery += "VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV0.VV0_NUMTRA=VV9.VV9_NUMATE AND VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND VV0.D_E_L_E_T_=' ' AND "
		cQuery += "VVA.VVA_FILIAL='"+xFilial("VVA")+"' AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' "
		If !Empty(cCodMar)
			cQuery += "AND VV0.VV0_CODMAR='"+cCodMar+"' "
		EndIf
		If !Empty(cGruVei)
			cQuery += "AND VV0.VV0_GRUMOD='"+cGruVei+"' "
		EndIf
		If !Empty(cModVei)
			cQuery += "AND VV0.VV0_MODVEI='"+cModVei+"' "
		EndIf
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
		Do While !( cQAlias )->( Eof() )
			
			nTotal := ( cQAlias )->( VV0_VALMOV )

			aVlrs[1,2]  += nTotal
			// Impostos	//
			nTotImp := ( cQAlias )->( VVA_ICMVEN ) + ( cQAlias )->( VVA_PISVEN ) + ( cQAlias )->( VVA_COFVEN )
			aVlrs[2,2]  += nTotImp // Total Impostos
			aVlrs[3,2]  += ( cQAlias )->( VVA_ICMVEN ) // ICMS
			aVlrs[4,2]  += ( cQAlias )->( VVA_PISVEN ) // PIS
			aVlrs[5,2]  += ( cQAlias )->( VVA_COFVEN ) // COFINS
			
			cUltDat := ""
			cTraCpa := ""
			nTotCus := 0
			nTotFre := 0
			cQuery := "SELECT VVG.VVG_VCNVEI , VVG.VVG_VALFRE , VVF.VVF_DATMOV , VVF.VVF_TRACPA FROM "+RetSqlName("VVG")+" VVG , "+RetSqlName("VVF")+" VVF WHERE "
			cQuery += "VVG.VVG_FILIAL='"+xFilial("VVG")+"' AND VVG.VVG_CHAINT='"+( cQAlias )->( VVA_CHAINT )+"' AND VVG.D_E_L_E_T_=' ' AND "
			cQuery += "VVF.VVF_FILIAL='"+xFilial("VVF")+"' AND VVG.VVG_TRACPA=VVF.VVF_TRACPA AND VVF.VVF_DATMOV<='"+( cQAlias )->( VV0_DATMOV )+"' AND VVF.VVF_OPEMOV='0' AND VVF.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
			Do While !( cQAlAux )->( Eof() )
				If cUltDat < ( cQAlAux )->( VVF_DATMOV )
					cUltDat := ( cQAlAux )->( VVF_DATMOV )
					cTraCpa := ( cQAlAux )->( VVF_TRACPA )
					nTotCus := ( cQAlAux )->( VVG_VCNVEI )
					nTotFre := ( cQAlAux )->( VVG_VALFRE )
				EndIf
				( cQAlAux )->( DbSkip() )
			EndDo
			( cQAlAux )->( dbCloseArea() )
			aVlrs[6,2] += nTotCus // Custo
			aVlrs[7,2] += nTotFre // Total Fretes
			aVlrs[8,2] += nTotFre // Frete Compra
			If !Empty(cTraCpa)
				nTotFre := 0
				cQuery  := "SELECT SUM(VVD.VVD_VALOR) VLR FROM "+RetSqlName("VVD")+" VVD WHERE VVD.VVD_FILIAL='"+xFilial("VVD")+"' AND "
				cQuery  += "VVD.VVD_TRACPA='"+cTraCpa+"' AND VVD.VVD_CHAINT='"+( cQAlias )->( VVA_CHAINT )+"' AND VVD.VVD_TIPTIT='TRF' AND VVD.D_E_L_E_T_=' ' "
				nTotFre := FM_SQL(cQuery)
				aVlrs[7,2] += nTotFre // Total Fretes
				aVlrs[9,2] += nTotFre // Frete entre Lojas
			EndIf
			If lRebate
				aVlrs[10,2] += ( cQAlias )->( VV0_REBATE ) // Rebate
			EndIf
			aVlrs[11,2] += ( cQAlias )->( VVA_JUREST ) // Juros de Estoque
			aVlrs[12,2] += nTotal - ( nTotImp + nTotCus ) // LucroBruto
			nQtdVda++
			( cQAlias )->( DbSkip() )
		EndDo
		( cQAlias )->( dbCloseArea() )
	Next
Else
	For ni := 1 to (len(aAux)-(nPerg+1))
		Aadd(aVlrs,{ aAux[ni,1] , aAux[ni,2] , aAux[ni,3] , aAux[ni,4] })
	Next
EndIf
Aadd(aVlrs,{ "" , 0 , "" , .t. })
DbSelectArea("SX1")
DbSetOrder(1)
For ni := 1 to nPerg
	DbSeek(cPerg+strzero(ni,2))
	cAux1 := Alltrim(SX1->X1_PERGUNT)
	If FS_VALCONTA( &("cConta"+strzero(ni,2)) )
		Aadd(aVlrs,{ &("cConta"+strzero(ni,2)) , &(FS_CONTA(&("cConta"+strzero(ni,2)))) , cAux1 , .t. })
	Else
		Aadd(aVlrs,{ &("cConta"+strzero(ni,2)) , 0 , cAux1 , .f. })
	EndIf
Next
If nx # 0
	FS_REFRIMP(.T.)
	If nx == 3 .and. Empty(Alltrim(cPerc))
		cPerc := aPerc[1]
	EndIf
	nPerc := ascan(aPerc,cPerc)
	oLbVlr:nAt := 1
	oLbVlr:SetArray(aVlrs)
	oLbVlr:bLine := { || {IIf(len(aVlrs[oLbVlr:nAt,3])==1,space(18)," ")+aVlrs[oLbVlr:nAt,3],aVlrs[oLbVlr:nAt,1],IIf(aVlrs[oLbVlr:nAt,4],FG_AlinVlrs(Transform(aVlrs[oLbVlr:nAt,2],"@EZ 999,999,999,999.99")),space(10)+ STR0023),IIf(aVlrs[oLbVlr:nAt,4].and.!Empty(aVlrs[oLbVlr:nAt,1]),FG_AlinVlrs(Transform((aVlrs[oLbVlr:nAt,2]/aVlrs[nPerc,2])*100,"@E 99999")+"%")+" "+IIf(ascan(aPerc,aVlrs[oLbVlr:nAt,3])==nPerc,"<<",""),"")}} // invalido
	oLbVlr:SetFocus()
	oLbVlr:Refresh()
Else
	If len(aVlrs) > 0
		For ni := 1 to len(aVlrs)
			aAdd(aPerc,aVlrs[ni,3])
		Next
	EndIf
	nPerc := ascan(aPerc,cPerc)
EndIf
cFilAnt := cFilSALVA
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_REFRIMP³ Autor ³  Andre Luis Almeida   ³ Data ³ 26/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ WHEN do Botao Imprimir                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_REFRIMP(lTipo)
lImprimir := lTipo
oImpr:Refresh()
return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VALCONTA³ Autor ³  Andre Luis Almeida  ³ Data ³ 26/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao da Conta ( + - / * )                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALCONTA(cAux)
Local cValido := " "+cLinhas+"()+-*/.1234567890"
Local ni      := 0
Local lOk     := .t.
Local nParent := 0
Local lOperad := .f.
Local lLinhas := .f.
cAux := Alltrim(cAux)
If Len(cAux) > 0
	For ni := 1 to len(cAux)
		If !( substr(cAux,ni,1) $ cValido )
			lOk  := .f.
			Exit
		EndIf
		If lLinhas
			If ( substr(cAux,ni,1) $ cLinhas )
				lOk  := .f.
				Exit
			Else
				lLinhas := .f.
			EndIf
		Else
			If ( substr(cAux,ni,1) $ cLinhas )
				lLinhas := .t.
			EndIf
		EndIf
		If lOperad
			If ( substr(cAux,ni,1) $ "+-*/" )
				lOk  := .f.
				Exit
			Else
				lOperad := .f.
			EndIf
		Else
			If ( substr(cAux,ni,1) $ "+-*/" )
				lOperad := .t.
			EndIf
		EndIf
		If substr(cAux,ni,1) == "("
			nParent++
		ElseIf substr(cAux,ni,1) == ")"
			nParent--
		EndIf
	Next
	If lOk
		lOk := .f.
		For ni := 1 to len(cAux)
			If ( substr(cAux,ni,1) $ "+-*/" )
				lOk := .t.
				Exit
			EndIf
		Next
		If nParent # 0 .or. ( lOperad .and. !lLinhas )
			lOk  := .f.
		EndIf
	EndIf
EndIf
Return(lOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CONTA  ³ Autor ³  Andre Luis Almeida  ³ Data ³ 26/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta resultado da Conta ( + - / * )                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CONTA(cAux)
Local nPos    := 0
Local ni      := 0
Local cValido := cLinhas
If Len(Alltrim(cAux)) > 0
	For ni := 1 to len(cValido)
		nPos := At(substr(cValido,ni,1),cAux)
		Do While nPos > 0
			If nPos > 0
				cAux := substr(cAux,1,nPos-1)+"aVlrs["+str(ni,3)+",2]"+substr(cAux,nPos+1)
			EndIf
			nPos := At(substr(cValido,ni,1),cAux)
		EndDo
	Next
Else
	cAux := '0'
EndIf
Return(cAux)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FILIAIS³ Autor ³  Andre Luis Almeida   ³ Data ³ 11/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Filiais                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILIAIS()
Local aVetAux      := {}
Local ni           := {}
Local aFilAtu      := FWArrFilAtu()
Local aSM0         := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt   := cFilAnt
Local nCont        := 0
Local aFWArrFilAtu := {}
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aFWArrFilAtu := FWArrFilAtu()
	ni := aScan(aEmpr,{|x| x[1] == cFilAnt })
	aAdd( aVetEmp, { (ni>0) , cFilAnt , aFWArrFilAtu[SM0_FILIAL] , FWFilialName() })
Next
cFilAnt := cBkpFilAnt
If Len(aVetEmp) > 1
	DEFINE MSDIALOG oDlgEmp FROM 05,01 TO 250,400 TITLE STR0016 PIXEL // Filiais
	@ 001,001 LISTBOX oLbEmp FIELDS HEADER "",STR0041,STR0042 COLSIZES 10,15,50 SIZE 165,120 OF oDlgEmp ON DBLCLICK (aVetEmp[oLbEmp:nAt,1]:=!aVetEmp[oLbEmp:nAt,1]) PIXEL
	oLbEmp:SetArray(aVetEmp)
	oLbEmp:bLine := { || {  IIf(aVetEmp[oLbEmp:nAt,1],oOk,oNo) ,;
	aVetEmp[oLbEmp:nAt,3],;
	aVetEmp[oLbEmp:nAt,4] }}
	DEFINE SBUTTON FROM 001,170 TYPE 1  ACTION (oDlgEmp:End()) ENABLE OF oDlgEmp
	@ 002, 002 CHECKBOX oMacTod VAR lMarcar PROMPT "" OF oDlgEmp ON CLICK IIf( FS_TIK(lMarcar ) , .t. , ( lMarcar:=!lMarcar , oDlgEmp:Refresh() ) ) 	SIZE 70,08 PIXEL COLOR CLR_BLUE
	ACTIVATE MSDIALOG oDlgEmp CENTER
EndIf
If len(aVetEmp) == 1
	aVetEmp[1,1] := .t.
EndIf
For ni := 1 to len(aVetEmp)
	If aVetEmp[ni,1]
		aAdd( aVetAux, { aVetEmp[ni,2] , aVetEmp[ni,3] })
		cEmpr += Alltrim(aVetEmp[ni,2])+", "
	EndIf
Next
If len(aVetAux) > 1
	cEmpr := substr(cEmpr,1,len(cEmpr)-2)
EndIf
Return(aVetAux)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIK    ³ Autor ³  Andre Luis Almeida  ³ Data ³ 26/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Marcar todas as Filiais                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK(lMarcar)
Local ni := 0
Default lMarcar := .f.
For ni := 1 to Len(aVetEmp)
	If lMarcar
		aVetEmp[ni,1] := .t.
	Else
		aVetEmp[ni,1] := .f.
	EndIf
Next
oLbEmp:SetFocus()
oLbEmp:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_IMPRIMIR³ Autor ³  Andre Luis Almeida  ³ Data ³ 26/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPRIMIR()
Local ni := 0
Private cDesc1 := ""
Private cDesc2 := ""
Private cDesc3 := ""
Private tamanho:= "M"
Private limite := 132
Private cString:= "VV9"
Private titulo := STR0005 +cEmpr //Avaliacao de Veiculos
Private cabec1 := STR0043 +": "+Transform(dDatIni,"@D")+ STR0044 +Transform(dDatFin,"@D")      //Periodo #  a  #
Private cabec2 := STR0045 +": "+cCodMar+"  "+ STR0046 +": "+cGruVei+"  "+ STR0047 +": "+cModVei   //Marca # Grupo # Modelo
Private aReturn:= {"",1,"",1,2,1,"",1}
Private nomeprog:= "VEIVC100"
Private nLastKey:= 0
nomeprog := SetPrint(cString,nomeprog,nil,titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
If nLastKey == 27
	Return
EndIf
SetDefault(aReturn,cString)
nLin  := 0
m_pag := 1
Set Printer to &nomeprog
Set Printer On
Set Device  to Printer
nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
For ni := 1 to len(aVlrs)
	If aVlrs[ni,4]
		If Empty(aVlrs[ni,1])
			nLin++
		Else
			If nLin >= 60
				nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
			EndIf
			@ nLin++, 00 PSAY left(Alltrim(aVlrs[ni,3])+"  >>  "+aVlrs[ni,1]+space(105),105)+Transform(aVlrs[ni,2],"@EZ 99,999,999,999.99")+" "+Transform((aVlrs[ni,2]/aVlrs[nPerc,2])*100,"@E 99999")+"%"+IIf(ni==nPerc," <<","")
		EndIf
	EndIf
Next
Set Printer to
Set Device to Screen
If aReturn[5] == 1
	OurSpool( nomeprog )
EndIf
MS_Flush()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_MANSX1 ³ Autor ³  Andre Luis Almeida  ³ Data ³ 26/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Manutencao no SX1 (contas)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MANSX1(cTp)
Local cPerg := left("VVC100"+space(20),len(SX1->X1_GRUPO))
Local lRet  := .f.
Local nx    := 0
Local cSeq  := "123456789ABCDEFGHIJKLMNOPQRSTUVXZW!@#$%^&:<>?/~.,"
nx := Aviso(STR0048,STR0049,{STR0050,STR0051,STR0052}) //Parametros de Calculos # Formulas para Calculo#Alterar#Incluir#xcluir
If nx == 1
	FS_LEVANT(2)
ElseIf nx >= 2
	lRet := .t.
	If nx == 2
		If MsgYesNo(STR0053 +" "+strzero(nPerg+1,2)+") ?",STR0002)  //Deseja Incluir um novo Parametro para Calculo (Resultado # atencao
			DbSelectArea("SX1")
			DbSetOrder(1)
			If !dbSeek(cPerg+strzero(nPerg+1,2))
				nPerg++
				RecLock("SX1",.t.)
				SX1->X1_GRUPO   := cPerg
				SX1->X1_ORDEM   := strzero(nPerg,2)
				SX1->X1_PERGUNT := STR0028+" "+strzero(nPerg,2) // Resultado
				SX1->X1_VARIAVL := "MV_CH"+IIf(nPerg>len(cSeq),"*",substr(cSeq,nPerg,1))
				SX1->X1_TIPO    := "C"
				SX1->X1_TAMANHO := 99
				SX1->X1_GSC     := "G"
				SX1->X1_VAR01   := "MV_PAR"+strzero(nPerg,2)
				MsUnlock()
			EndIf
			/////////////////////////////////////////
			// Muda Pergunte para nao dar problema //
			/////////////////////////////////////////
			cPerg := left("OFR250"+space(20),len(SX1->X1_GRUPO))
			PERGUNTE(cPerg,.f.)
			/////////////////////////////////////////
			// Volta Pergunte -> VVC100            //
			/////////////////////////////////////////
			cPerg := left("VVC100"+space(20),len(SX1->X1_GRUPO))
		EndIf
	ElseIf nx == 3
		DbSelectArea("SX1")
		DbSetOrder(1)
		If dbSeek(cPerg+strzero(nPerg,2))
			If MsgYesNo(STR0054 +Alltrim(SX1->X1_PERGUNT)+") ?",STR0002) // Deseja Excluir o ultimo Parametro de Calculo (# Atencao
				RecLock("SX1",.f.,.t.)
				DbDelete()
				MsUnlock()
			EndIf
		EndIf
	EndIf
EndIf
Return(lRet)