// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 21     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "protheus.ch"
#INCLUDE "ofior690.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOR690 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 27/08/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Vendas: Veiculos / Pecas e Servicos                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR690

Private cAlias   := "SD2"
Private nLin     := 1
Private aPag     := 1
Private cTitulo  := STR0001 //Vendas"
Private cCabec1  := ""
Private cCabec2  := ""
Private cDesc1   := Alltrim(cTitulo)
Private cDesc2   := ""
Private cDesc3   := ""
Private aReturn  := { STR0002, 1,STR0003, 2, 2, 1, "",1 } //Zebrado # Administracao
Private cTamanho := "P"           // P/M/G
Private Limite   := 80          // 80/132/220
Private cNomProg := "OFIOR690"
Private cNomeRel := "OFIOR690"
Private nLastKey := 0
Private nCaracter:= 15
Private cPerg    := "OFR690"
/*
MV_PAR01 = FILIAL Inicial    C  2  G
MV_PAR02 = FILIAL Inicial    C  2  G
MV_PAR03 = Data Inicial      D  8  G
MV_PAR04 = Data Final        D  8  G
MV_PAR05 = Vendedor Inic     C  6  G
MV_PAR06 = Vendedor Final    C  6  G
MV_PAR07 = Tipo de Relatorio N  1  C ( 1-Resumido / 2-Sintetico / 3-Analitico )
MV_PAR08 = Deduz Devolucao   N  1  C ( 1-Sim / 2-Nao )
*/
DbSelectArea("SD2")
ValidPerg()
set printer to &cNomeRel
set printer on
set device to printer

cNomeRel := SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
if nlastkey == 27
	return
Endif
PERGUNTE(cPerg,.f.)
cTitulo := Alltrim(cTitulo)+" "
If MV_PAR09 == 2
	cTitulo += STR0007  //Veiculos
ElseIf MV_PAR09 == 3
	cTitulo += STR0004  //Pecas e Servicos
ElseIf MV_PAR09 == 4
	cTitulo += STR0043  // Pecas 
ElseIf MV_PAR09 == 5
	cTitulo += STR0044  // Servicos
EndIf
SetDefault(aReturn,cAlias)
RptStatus({|lEnd| FS_IMP690(@lEnd,cNomeRel,cAlias)},cTitulo)

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_IMP690 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 27/08/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Vendas: Veiculos / Pecas e Servicos                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMP690(lEnd,wNRel,cAlias)

Local cont
Local cFiliais:= ""
Local aVetImp := {}
Local aVetOfi := {}
Local lPula   := .f.
Local cDesc   := ""
Local cTipo   := ""
Local cObserv := ""
Local cDescSrv:= ""
Local cQuery  := ""
Local cQAlF2D2:= "SQLSF2SD2"
Local cQAlSD1 := "SQLSD1"
Local ni      := 0
Local nX      := 0
Local cX      := ""
Local cTp     := ""
Local cTpDesc := ""
Local nPos    := 0
Local cGrupVEI:= left(GetNewPar("MV_GRUVEI","VEI")+space(4),4)
Local cPrefVEI:= left(GetNewPar("MV_PREFVEI","VEI")+space(3),3)
Local cPrefBAL:= left(GetNewPar("MV_PREFBAL","BAL")+space(3),3)
Local cPrefOFI:= left(GetNewPar("MV_PREFOFI","OFI")+space(3),3)
Local aFilCont := {}
Local nCntFil
Local nVlrDev := 0
Local oSqlHlp := DMS_SqlHelper():New()
M_PAG         := 1
nLin          := 80
aPag          := 1
Aadd(aVetImp,{"1"+space(2)+space(6)+space(3)+space(12)+space(8),STR0008,"","",0,1}) //Total Geral
aFilAtu   := FWArrFilAtu()
aSM0    := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
cBkpFil := cFilAnt
For cont := 1 to len(aSM0)     
	cFilAnt := aSM0[cont]
	if aSM0[cont] < MV_PAR01 .or. aSM0[cont] > MV_PAR02
		loop
	endif
	aAdd(aFilCont,aSM0[cont])
	aSM0Desc := FWArrFilAtu(cEmpAnt,cFilAnt) 
	Aadd(aVetImp,{"2"+aSM0[cont]+space(6)+space(3)+space(12)+space(8), STR0009 ,aSM0[cont],aSM0Desc[7],0,3}) //Filial:
	if Len(cFiliais) >= 50
		if !(Right(cFiliais,3)=="...")
			cFiliais +="...."
		endif
	else
		cFiliais += aSM0[cont]+","
	endif
	cX := aSM0[cont]
Next
cFilAnt := cBkpFil 
If len(aVetImp)>2
	aVetImp[1,2] := STR0010 	//Total:"
	aVetImp[1,3] := STR0011 	//Filiais"
	aVetImp[1,4] := left(cFiliais,len(cFiliais)-1)
	cCabec1 := STR0012 +left(cFiliais,len(cFiliais)-1) //FILIAIS
	cCabec2 := STR0013 +" "+Transform(MV_PAR03,"@D")+ STR0015 +Transform(MV_PAR04,"@D")+" - "+ STR0016 +": "+MV_PAR05+ STR0015 +MV_PAR06+IIF(MV_PAR08==1," - "+STR0017,"") //PERIDO A VENDENDO A DEWDUZ DEVOLUCAO
Else
	cCabec1 := STR0014+" "+cX+" - "+Transform(MV_PAR03,"@D")+ STR0015 +Transform(MV_PAR04,"@D")
	cCabec2 := STR0016 +": "+MV_PAR05+ STR0015 +MV_PAR06+IIF(MV_PAR08==1," - "+STR0017,"") //FILIAL A VENDEDOR A DEDUZ DEVOLUCAO
EndIf
cFilAntAnt := cFilAnt

for nCntFil := 1 to Len(aFilCont)
	if aFilCont[nCntFil] < MV_PAR01 .or. aFilCont[nCntFil] > MV_PAR02
		loop
	endif
	cFilAnt := aFilCont[nCntFil]
	cQuery := "    SELECT SF2.F2_FILIAL , SF2.F2_PREFORI , SF2.F2_DOC , SF2.F2_SERIE , SF2."+ FGX_MILSNF("SF2", 3, "F2_SERIE") +" , SF2.F2_VEND1 , SF2.F2_CLIENTE , SF2.F2_LOJA , SD2.D2_TOTAL ,SD2.D2_COD, SF4.F4_ISS , SA3.A3_NOME , SA1.A1_NOME , SB1.B1_GRUPO , SB1.B1_CODITE , SB1.B1_DESC "
	cQuery += "      FROM " + oSqlHlp:NoLock('SD2')
	cQuery += "      JOIN " + oSqlHlp:NoLock('SF2') + " ON SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.D_E_L_E_T_ = ' ' "
	If MV_PAR09 == 1 		// Todos
		cQuery += "AND SF2.F2_PREFORI IN ('"+cPrefVEI+"','"+cPrefBAL+"','"+cPrefOFI+"') "
	ElseIf MV_PAR09 == 2 	// Veiculos 
		cQuery += "AND SF2.F2_PREFORI='"+cPrefVEI+"' "
	ElseIf MV_PAR09 == 3 .or. MV_PAR09 == 4 .or.  MV_PAR09 == 5	// Pecas e Servicos
		cQuery += "AND SF2.F2_PREFORI IN ('"+cPrefBAL+"','"+cPrefOFI+"') "
	EndIf
	cQuery += "      JOIN "+ oSqlHlp:NoLock('SF4')+" ON SF4.F4_FILIAL = '" + xFilial('SF4') + "' AND SF4.F4_CODIGO  = SD2.D2_TES     AND SF4.F4_OPEMOV  = '05' AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "      JOIN "+ oSqlHlp:NoLock('SBM')+" ON SBM.BM_FILIAL = '" + xFilial('SBM') + "' AND SBM.BM_GRUPO   = SD2.D2_GRUPO   AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += "      JOIN "+ oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' AND SB1.B1_COD     = SD2.D2_COD     AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "      JOIN "+ oSqlHlp:NoLock('SA1')+" ON SA1.A1_FILIAL = '" + xFilial('SA1') + "' AND SA1.A1_COD     = SF2.F2_CLIENTE AND SA1.A1_LOJA    = SF2.F2_LOJA AND SA1.D_E_L_E_T_=' ' "
	cQuery += " LEFT JOIN "+ oSqlHlp:NoLock('SA3')+" ON SA3.A3_FILIAL = '" + xFilial('SA3') + "' AND SA3.A3_COD     = SF2.F2_VEND1   AND SA3.D_E_L_E_T_ = ' ' " 
	cQuery += " LEFT JOIN "+ oSqlHlp:NoLock('VE1')+" ON VE1.VE1_FILIAL= '" + xFilial('VE1') + "' AND VE1.VE1_CODMAR = SBM.BM_CODMAR  AND VE1.D_E_L_E_T_ = ' ' "
	cQuery += "     WHERE 1=1 "
	cQuery += " AND SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND SD2.D2_EMISSAO >= '" + dtos(MV_PAR03) + "' AND SD2.D2_EMISSAO <= '" + dtos(MV_PAR04) + "' "

	if !Empty(MV_PAR05) .AND. !Empty(MV_PAR06)
		cQuery += " AND SF2.F2_VEND1 >= '" + MV_PAR05 + "' AND SF2.F2_VEND1 <= '" + MV_PAR06 + "' "
	EndIf

	if !Empty(mv_par10)
		cQuery += " AND EXISTS ( SELECT ACV.ACV_CATEGO "
		cQuery +=             " FROM " + oSqlHlp:NoLock('ACV')
		cQuery +=             " WHERE ACV.ACV_FILIAL = '" + xFilial('ACV') + "' "
		cQuery +=               " AND ACV.ACV_CATEGO = '" + MV_PAR10 + "' "
		cQuery +=               " AND SD2.D2_COD = ACV.ACV_CODPRO "
		cQuery +=               " AND ACV.D_E_L_E_T_ = ' ' ) "
	Endif

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlF2D2, .F., .T. )
	DBSelectArea("SB1")
	DBSetOrder(1)
	DBSelectArea("SBM")
	DBSetOrder(1)
	Do While !( cQAlF2D2 )->( Eof() )
		DBSelectArea("SB1")
		DBSeek(xFilial("SB1") + ( cQAlF2D2 )->( D2_COD ) )
		if !Empty(MV_PAR11) .and. SB1->B1_GRUPO < MV_PAR11
			( cQAlF2D2 )->( DBSkip() )
			loop
		endif
		if !Empty(MV_PAR12) .and. SB1->B1_GRUPO > MV_PAR12
			( cQAlF2D2 )->( DBSkip() )
			loop
		endif
		if MV_PAR09 == 4 .or.  MV_PAR09 == 5
			DBSelectArea("SBM")
			DBSeek(xFilial("SBM") + SB1->B1_GRUPO)
			if MV_PAR09 == 4
				if Alltrim(SBM->BM_TIPGRU) $ '4.7'
					( cQAlF2D2 )->( DBSkip() )
					loop
				endif
			else
				if Alltrim(SBM->BM_TIPGRU) != '4'
					( cQAlF2D2 )->( DBSkip() )
					loop
				endif
			endif
		endif
		// TOTAL GERAL //
		aVetImp[1,5] += ( cQAlF2D2 )->( D2_TOTAL )
		// TOTAL FILIAL //
		nPos := aScan(aVetImp, {|x| x[1] == "2"+( cQAlF2D2 )->( F2_FILIAL )+space(6)+space(3)+space(12)+space(8) })
		If nPos > 0
			aVetImp[nPos,5] += ( cQAlF2D2 )->( D2_TOTAL )
		EndIf
		If MV_PAR07 >= 2 // 2-Sintetico / 3-Analitico
			// TOTAL VENDEDOR //
			nPos := aScan(aVetImp, {|x| x[1] == "2"+( cQAlF2D2 )->( F2_FILIAL )+( cQAlF2D2 )->( F2_VEND1 )+space(3)+space(12)+space(8) })
			If nPos <= 0
				Aadd(aVetImp,{"2"+( cQAlF2D2 )->( F2_FILIAL )+( cQAlF2D2 )->( F2_VEND1 )+space(3)+space(12)+space(8),"Vendedor:",( cQAlF2D2 )->( F2_VEND1 ),( cQAlF2D2 )->( A3_NOME ),( cQAlF2D2 )->( D2_TOTAL ),5})
			Else
				aVetImp[nPos,5] += ( cQAlF2D2 )->( D2_TOTAL )
			EndIf
			// TOTAL BALCAO / OFICINA //
			nPos := aScan(aVetImp, {|x| x[1] == "2"+( cQAlF2D2 )->( F2_FILIAL )+( cQAlF2D2 )->( F2_VEND1 )+( cQAlF2D2 )->( F2_PREFORI )+space(12)+space(8) })
			If nPos <= 0
				If ( cQAlF2D2 )->( F2_PREFORI ) == cPrefBAL
					cTpDesc := STR0018 	//BALCAO (PECAS)"
				ElseIf ( cQAlF2D2 )->( F2_PREFORI ) == cPrefOFI
					cTpDesc := STR0019 	//OFICINA (PECAS/SERVICOS)"
				Else
					cTpDesc := STR0020 	//VEICULOS"
				EndIf
				Aadd(aVetImp,{"2"+( cQAlF2D2 )->( F2_FILIAL )+( cQAlF2D2 )->( F2_VEND1 )+( cQAlF2D2 )->( F2_PREFORI )+space(12)+space(8),cTpDesc,"","",( cQAlF2D2 )->( D2_TOTAL ),7})
				If ( cQAlF2D2 )->( F2_PREFORI ) == cPrefOFI // Totalizar OFICINA (PECAS/SERVICOS)
					Aadd(aVetOfi,{"2"+( cQAlF2D2 )->( F2_FILIAL )+( cQAlF2D2 )->( F2_VEND1 )+( cQAlF2D2 )->( F2_PREFORI )+"X1",STR0022,"","",If(( cQAlF2D2 )->( F4_ISS )=="N",( cQAlF2D2 )->( D2_TOTAL ),0)})   //"- PECAS"
					Aadd(aVetOfi,{"2"+( cQAlF2D2 )->( F2_FILIAL )+( cQAlF2D2 )->( F2_VEND1 )+( cQAlF2D2 )->( F2_PREFORI )+"X2",STR0021,"","",If(( cQAlF2D2 )->( F4_ISS )=="N",0,( cQAlF2D2 )->( D2_TOTAL ))}) //"- SERVICOS"
				EndIf
			Else
				aVetImp[nPos,5] += ( cQAlF2D2 )->( D2_TOTAL )
				If ( cQAlF2D2 )->( F2_PREFORI ) == cPrefOFI // Totalizar OFICINA (PECAS/SERVICOS)
					nX := aScan(aVetOfi, {|x| x[1] == "2"+( cQAlF2D2 )->( F2_FILIAL )+( cQAlF2D2 )->( F2_VEND1 )+( cQAlF2D2 )->( F2_PREFORI )+If(( cQAlF2D2 )->( F4_ISS )=="N","X1","X2") })
					If nX > 0
						aVetOfi[nX,5] += ( cQAlF2D2 )->( D2_TOTAL )
					EndIf
				EndIf
			EndIf
			If MV_PAR07 == 3 // 3-Analitico
				// TOTAL NF //
				nPos := aScan(aVetImp, {|x| x[1] == "2"+( cQAlF2D2 )->( F2_FILIAL )+( cQAlF2D2 )->( F2_VEND1 )+( cQAlF2D2 )->( F2_PREFORI )+( cQAlF2D2 )->( F2_DOC )+( cQAlF2D2 )->( F2_SERIE )+space(8) })
				If nPos <= 0
					Aadd(aVetImp,{"2"+( cQAlF2D2 )->( F2_FILIAL )+( cQAlF2D2 )->( F2_VEND1 )+( cQAlF2D2 )->( F2_PREFORI )+( cQAlF2D2 )->( F2_DOC )+( cQAlF2D2 )->( F2_SERIE )+space(8),"NF:",( cQAlF2D2 )->( F2_DOC )+"-"+( cQAlF2D2 )->&( FGX_MILSNF("SF2", 3, "F2_SERIE") )+" "+( cQAlF2D2 )->( F2_PREFORI ),( cQAlF2D2 )->( F2_CLIENTE )+"-"+( cQAlF2D2 )->( F2_LOJA )+" "+( cQAlF2D2 )->( A1_NOME ),( cQAlF2D2 )->( D2_TOTAL ),9})
				Else
					aVetImp[nPos,5] += ( cQAlF2D2 )->( D2_TOTAL )
				EndIf
				If ( cQAlF2D2 )->( F2_PREFORI ) == cPrefOFI
					If ( cQAlF2D2 )->( F4_ISS ) == "N"
						cTp := "1"
						cTpDesc := STR0023  //Pecas
					Else
						cTp := "2"
						cTpDesc := STR0024 //Servicos
					EndIf
					// TOTAL PECAS/SERVICOS //
					nPos := aScan(aVetImp, {|x| x[1] == "2"+( cQAlF2D2 )->( F2_FILIAL )+( cQAlF2D2 )->( F2_VEND1 )+( cQAlF2D2 )->( F2_PREFORI )+( cQAlF2D2 )->( F2_DOC )+( cQAlF2D2 )->( F2_SERIE )+cTp+space(7) })
					If nPos <= 0
						Aadd(aVetImp,{"2"+( cQAlF2D2 )->( F2_FILIAL )+( cQAlF2D2 )->( F2_VEND1 )+( cQAlF2D2 )->( F2_PREFORI )+( cQAlF2D2 )->( F2_DOC )+( cQAlF2D2 )->( F2_SERIE )+cTp+space(7),cTpDesc,"","",( cQAlF2D2 )->( D2_TOTAL ),11})
					Else
						aVetImp[nPos,5] += ( cQAlF2D2 )->( D2_TOTAL )
					EndIf
				EndIf
				// ITENS //
				Aadd(aVetImp,{"2"+( cQAlF2D2 )->( F2_FILIAL )+( cQAlF2D2 )->( F2_VEND1 )+( cQAlF2D2 )->( F2_PREFORI )+( cQAlF2D2 )->( F2_DOC )+( cQAlF2D2 )->( F2_SERIE )+cTp+( cQAlF2D2 )->( B1_GRUPO )+( cQAlF2D2 )->( B1_CODITE ),( cQAlF2D2 )->( B1_GRUPO ),( cQAlF2D2 )->( B1_CODITE ),( cQAlF2D2 )->( B1_DESC ),( cQAlF2D2 )->( D2_TOTAL ),13})
			EndIf
		EndIf
		( cQAlF2D2 )->( DbSkip() )
	EndDo
	( cQAlF2D2 )->( dbCloseArea() )
	If MV_PAR08 == 1
		// DEVOLUCOES //
		cQuery := "SELECT SF1.F1_FILIAL , SD1.D1_NFORI , SD1.D1_SERIORI, SD1."+ FGX_MILSNF("SD1", 3, "D1_SERIORI") +" , SD1.D1_TOTAL , SD1.D1_VALIPI , SD1.D1_ICMSRET , SD1.D1_DESPESA , SD1.D1_SEGURO , SD1.D1_VALFRE , SD1.D1_VALDESC , SB1.B1_GRUPO , SB1.B1_CODITE , SB1.B1_DESC FROM "+RetSqlName("SD1")+" SD1 , "+RetSqlName("SF1")+" SF1 , "+RetSqlName("SF4")+" SF4 , "+RetSqlName("SB1")+" SB1 "
	    if !Empty(mv_par10)
			cQuery += " , "+RetSqlName("ACV")+" ACV "
		Endif	
		cQuery += "WHERE "
		cQuery += "SF1.F1_TIPO='D' AND SF1.F1_FILIAL=SD1.D1_FILIAL AND SF1.F1_DOC=SD1.D1_DOC AND SF1.F1_SERIE=SD1.D1_SERIE AND  SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SD1.D1_TES=SF4.F4_CODIGO AND SF4.F4_DUPLIC='S' AND SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SD1.D1_COD=SB1.B1_COD AND "
		If MV_PAR09 # 1 // Todos
			If MV_PAR09 == 2 // Veiculos
				cQuery += "SB1.B1_GRUPO='"+cGrupVEI+"' AND "
			Else // Pecas e Servicos
				cQuery += "SB1.B1_GRUPO<>'"+cGrupVEI+"' AND "  
				if !Empty(MV_PAR11) 
					cQuery += "SB1.B1_GRUPO>='"+MV_PAR11+"' AND "  
				Endif
				if !Empty(MV_PAR12)
					cQuery += "SB1.B1_GRUPO<='"+MV_PAR12+"' AND "  
				Endif
			Endif
		EndIf
	    if !Empty(mv_par10)
			cQuery += "ACV.ACV_FILIAL = '"+xFilial("ACV")+"' AND SD1.D1_COD = ACV.ACV_CODPRO AND ACV.ACV_CATEGO = '"+MV_PAR10+"' AND "
		Endif
		cQuery += "SF1.F1_FILIAL = '"+xFilial("SF1")+"' AND SF4.F4_ESTOQUE='S' AND SF4.F4_OPEMOV='09' AND SF1.F1_DTDIGIT>='"+dtos(MV_PAR03)+"' AND SF1.F1_DTDIGIT<='"+dtos(MV_PAR04)+"' AND SD1.D_E_L_E_T_=' ' AND SF1.D_E_L_E_T_=' ' AND SF4.D_E_L_E_T_=' ' AND SB1.D_E_L_E_T_=' '"
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSD1, .F., .T. )
		while !( (cQAlSD1)->(eof()) )
			nVlrDev := (-1) * ( ( (cQAlSD1)->(D1_TOTAL) + (cQAlSD1)->(D1_VALIPI) + (cQAlSD1)->(D1_ICMSRET) + (cQAlSD1)->(D1_DESPESA) + (cQAlSD1)->(D1_SEGURO) + (cQAlSD1)->(D1_VALFRE) ) - (cQAlSD1)->(D1_VALDESC) )
			// TOTAL GERAL //
			aVetImp[1,5] += nVlrDev
			// TOTAL FILIAL //
			nPos := aScan(aVetImp, {|x| x[1] == "2"+( cQAlSD1 )->( F1_FILIAL )+space(6)+space(3)+space(12)+space(8) })
			If nPos > 0
				aVetImp[nPos,5] += nVlrDev
			EndIf
			If MV_PAR07 >= 2 // 2-Sintetico / 3-Analitico
				cQuery := "SELECT SF2.F2_PREFORI , SF2.F2_DOC , SF2.F2_SERIE , SF2."+ FGX_MILSNF("SF2", 3, "F2_SERIE") +" , SF2.F2_VEND1 , SF2.F2_CLIENTE , SF2.F2_LOJA , SA3.A3_NOME , SA1.A1_NOME FROM "+RetSqlName("SF2")+" SF2 , "+RetSqlName("SA3")+" SA3 , "+RetSqlName("SA1")+" SA1 WHERE "
				If MV_PAR09 == 1 // Todos
					cQuery += "SF2.F2_PREFORI IN ('"+cPrefVEI+"','"+cPrefBAL+"','"+cPrefOFI+"') AND "
				ElseIf MV_PAR09 == 2 // Veiculos
					cQuery += "SF2.F2_PREFORI='"+cPrefVEI+"' AND "
				Else // Pecas e Servicos
					cQuery += "SF2.F2_PREFORI IN ('"+cPrefBAL+"','"+cPrefOFI+"') AND "
				EndIf
				cQuery += "SF2.F2_FILIAL='"+( cQAlSD1 )->( F1_FILIAL )+"' AND SF2.F2_DOC='"+( cQAlSD1 )->( D1_NFORI )+"' AND SF2.F2_SERIE='"+( cQAlSD1 )->( D1_SERIORI )+"' AND  SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SF2.F2_CLIENTE=SA1.A1_COD AND SF2.F2_LOJA=SA1.A1_LOJA AND "
				cQuery += "SF2.F2_VEND1>='"+MV_PAR05+"' AND SF2.F2_VEND1<='"+MV_PAR06+"' AND SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SF2.F2_VEND1=SA3.A3_COD AND SF2.D_E_L_E_T_=' ' AND SA3.D_E_L_E_T_=' ' AND SA1.D_E_L_E_T_=' ' "
				
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlF2D2, .F., .T. )
				If !( cQAlF2D2 )->( Eof() )
					cVend  := ( cQAlF2D2 )->( F2_VEND1 )
					cNVend := ( cQAlF2D2 )->( A3_NOME )
					cPref  := ( cQAlF2D2 )->( F2_PREFORI )
					cClient:= ( cQAlF2D2 )->( F2_CLIENTE )+"-"+( cQAlF2D2 )->( F2_LOJA )+" "+( cQAlF2D2 )->( A1_NOME )
				Else
					cVend  := "______"
					cNVend := ""
					cPref  := "XXX"
					cClient:= ""
				EndIf
				(cQAlF2D2)->(DBCloseArea())
				// TOTAL VENDEDOR //
				nPos := aScan(aVetImp, {|x| x[1] == "2"+( cQAlSD1 )->( F1_FILIAL )+cVend+space(3)+space(12)+space(8) })
				If nPos <= 0
					Aadd(aVetImp,{"2"+( cQAlSD1 )->( F1_FILIAL )+cVend+space(3)+space(12)+space(8),STR0016 +":",cVend,cNVend,nVlrDev,5}) //Vendedor:
				Else
					aVetImp[nPos,5] += nVlrDev
				EndIf
				// TOTAL BALCAO / OFICINA //
				nPos := aScan(aVetImp, {|x| x[1] == "2"+( cQAlSD1 )->( F1_FILIAL )+cVend+cPref+space(12)+space(8) })
				If nPos <= 0
					If cPref == cPrefBAL
						cTpDesc := STR0018 //BALCAO (PECAS)"
					ElseIf cPref == cPrefOFI
						cTpDesc := STR0019 //OFICINA (PECAS/SERVICOS)"
					ElseIf cPref == cPrefVEI
						cTpDesc := STR0020 //VEICULOS"
					Else
						cTpDesc := "XXX"+" - "+STR0045
					EndIf
					Aadd(aVetImp,{"2"+( cQAlSD1 )->( F1_FILIAL )+cVend+cPref+space(12)+space(8),cTpDesc,"","",nVlrDev,7})
				Else
					aVetImp[nPos,5] += nVlrDev
				EndIf
				If cPref == cPrefOFI
					nX := aScan(aVetOfi, {|x| x[1] == "2"+( cQAlSD1 )->( F1_FILIAL )+cVend+cPref+"X1" })
					If nX <= 0
						Aadd(aVetOfi,{"2"+( cQAlSD1 )->( F1_FILIAL )+cVend+cPref+"X1",STR0022,"","",nVlrDev})	//"- PECAS
						Aadd(aVetOfi,{"2"+( cQAlSD1 )->( F1_FILIAL )+cVend+cPref+"X2",STR0021,"","",0})			//"- SERVICOS
					Else
						aVetOfi[nX,5] += nVlrDev
					EndIf
				EndIf
				If MV_PAR07 == 3 // 3-Analitico
					// TOTAL NF //
					nPos := aScan(aVetImp, {|x| x[1] == "2"+( cQAlSD1 )->( F1_FILIAL )+cVend+cPref+( cQAlSD1 )->( D1_NFORI )+( cQAlSD1 )->( D1_SERIORI )+space(8) })
					If nPos <= 0
						Aadd(aVetImp,{"2"+( cQAlSD1 )->( F1_FILIAL )+cVend+cPref+( cQAlSD1 )->( D1_NFORI )+( cQAlSD1 )->( D1_SERIORI )+space(8),"NF:",( cQAlSD1 )->( D1_NFORI )+"-"+( cQAlSD1 )->&( FGX_MILSNF("SD1", 3, "D1_SERIORI") ) +" "+cPref,cClient,nVlrDev,9})
					Else
						aVetImp[nPos,5] += nVlrDev
					EndIf
					If cPref == cPrefOFI
						cTp := "1"
						cTpDesc := STR0023 //Pecas
						// TOTAL PECAS //
						nPos := aScan(aVetImp, {|x| x[1] == "2"+( cQAlSD1 )->( F1_FILIAL )+cVend+cPref+( cQAlSD1 )->( D1_NFORI )+( cQAlSD1 )->( D1_SERIORI )+cTp+space(7) })
						If nPos <= 0
							Aadd(aVetImp,{"2"+( cQAlSD1 )->( F1_FILIAL )+cVend+cPref+( cQAlSD1 )->( D1_NFORI )+( cQAlSD1 )->( D1_SERIORI )+cTp+space(7),cTpDesc,"","",nVlrDev,11})
						Else
							aVetImp[nPos,5] += nVlrDev
						EndIf
					EndIf
					// ITENS //
					Aadd(aVetImp,{"2"+( cQAlSD1 )->( F1_FILIAL )+cVend+cPref+( cQAlSD1 )->( D1_NFORI )+( cQAlSD1 )->( D1_SERIORI )+cTp+( cQAlSD1 )->( B1_GRUPO )+( cQAlSD1 )->( B1_CODITE ),( cQAlSD1 )->( B1_GRUPO ),( cQAlSD1 )->( B1_CODITE ),( cQAlSD1 )->( B1_DESC ),nVlrDev,13})
				EndIf
			EndIf
			(cQAlSD1)->(Dbskip())
		EndDo
		(cQAlSD1)->(DBCloseArea())
	EndIf
next
cFilAnt := cFilAntAnt
///////////////////////////////////////////////////////////////////////////////
asort(aVetImp,,,{|x,y| x[1] < y[1] })
nLin := Cabec(cTitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter)+1
For ni := 1 to len(aVetImp)
	If nLin >= 58
		nLin := Cabec(cTitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter)+1
	EndIf
	nPos := aVetImp[ni,6]
	If nPos <= IIF(MV_PAR07==3,8,IIF(MV_PAR07==2,6,4))
		nLin++
	EndIf
	@ nLin++, nPos pSay left(Alltrim(aVetImp[ni,2])+" "+Alltrim(aVetImp[ni,3])+" "+Alltrim(aVetImp[ni,4])+space(65),65-nPos)+transform(aVetImp[ni,5],"@E 9999,999,999.99")
	If nPos == 7
		nX := aScan(aVetOfi, {|x| x[1] == left(aVetImp[ni,1],12)+"X1" })
		If nX > 0 .and. nX < len(aVetOfi)
			@ nLin++, nPos pSay left(Alltrim(aVetOfi[nX,2])+space(65),65-nPos)+transform(aVetOfi[nX,5],"@E 9999,999,999.99")
			nX++
			@ nLin++, nPos pSay left(Alltrim(aVetOfi[nX,2])+space(65),65-nPos)+transform(aVetOfi[nX,5],"@E 9999,999,999.99")
		EndIf
	EndIf
Next
Set Printer to
Set device to Screen
MS_FLUSH()
If aReturn[5] == 1
	OurSpool(cNomeRel)
EndIf
Return

Static Function ValidPerg()

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))


aAdd(aRegs,{cPerg,"09",STR0032,"","","mv_ch9","N", 01,0,0,"C","","mv_par09",STR0034,"","","","",STR0007,"","","","",STR0039,"","","","",STR0043,"","","","",STR0044,"","","","","",""})
aAdd(aRegs,{cPerg,"10",STR0040,"","","mv_cha","C", 06,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","ACV1",""})  
aAdd(aRegs,{cPerg,"11",STR0041,"","","mv_chb","C", 04,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","",""})  
aAdd(aRegs,{cPerg,"12",STR0042,"","","mv_chc","C", 04,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","",""})  

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

