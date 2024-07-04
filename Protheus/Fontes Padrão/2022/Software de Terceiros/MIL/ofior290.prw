#Include "Protheus.ch"
#Include "Fileio.ch"
#Include "OFIOR290.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOR290 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 14/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Performance de Pecas & Acessorios                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR290()

Local cDesc1     := STR0001
Local cDesc2     := ""
Local cDesc3     := ""
Local cAlias     := "VEC"


Private nLin := 1
Private aReturn  := { STR0052, 1,STR0053, 2, 2, 1, "",1 }
Private cTamanho := "P"          // P/M/G
Private Limite   := 80           // 80/132/220
Private aOrdem   := {}           // Ordem do Relatorio
Private cTitulo  := STR0001
Private cNomProg := "OFIOR290"
Private cNomeRel := "OFIOR290"
Private nLastKey := 0
Private cPerg    := "OFR290"
Private cChave , cSX5existe , ni := 0 , nPos := 0 , nPos1 := 0
Private aChave01 := {} //vetor de Parametros " Chave 01 "
Private aChave02 := {} //vetor de Parametros " Chave 02 "
Private aChave03 := {} //vetor de Parametros " Chave 03 "
Private aChave04 := {} //vetor de Parametros " Chave 04 "
Private aChave05 := {} //vetor de Parametros " Chave 05 "
Private aChave06 := {} //vetor de Parametros " Chave 06 "
Private aChave07 := {} //vetor de Parametros " Chave 07 "

cNomeRel         := SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)

If nLastKey == 27
	Return
EndIf

ValidPerg(cPerg)

PERGUNTE("OFR290",.t.)

SetDefault(aReturn,cAlias)
RptStatus( { |lEnd| ImpOR290(@lEnd,cNomeRel,cAlias) } , cTitulo )

If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpOR290  ºAutor  ³Andre Luis Almeida  º Data ³  14/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Performance de Pecas & Acessorios                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ImpOR290(lEnd,wNRel,cAlias)

Local ni:=0, i:=0

Private cTitulo , cabec1 , cabec2 , nomeprog , tamanho , nCaracter , cCabTot , cMudou , cTipo , cDCli , cIcm , dDatEst , dDatOri , cSomou
Private nLin := 1 , nCont := 0 , nCof := 0 , nPis := 0 , nIcm := 0 , nTotCom := 0 , nTotCpR := 0 , nTotCpO := 0 , nTotCpE := 0 , nTotVei := 0 , nTotPas := 0
Private nPvalvda := 0 , nPvalicm := 0 , nPvalpis := 0 , nPvalcof := 0 , nPcustot := 0
Private aNumPec := {} //vetor de Pecas
Private aItePec := {} //vetor de Pecas
Private aTotPec := {} //vetor do Total de Pecas
Private aGrpPec := {} //vetor de Grupos de Pecas
Private aNumAce := {} //vetor de Acessorios
Private aIteAce := {} //vetor de Acessorios
Private aTotAce := {} //vetor de Total de Acessorios
Private aNumLub := {} //vetor de Lubrificantes
Private aIteLub := {} //vetor de Lubrificantes
Private aTotLub := {} //vetor de Total de Lubrificantes
Private aNumBPc := {} //vetor de Pecas Balcao (FISICA)
Private aIteBPc := {} //vetor de Pecas Balcao (FISICA)
Private aTotBPc := {} //vetor de Total de Pecas Balcao (FISICA)
Private aTotPBO := {} //vetor de Total Balcao/Oficina
Private aGrpCpR := {} //vetor de Grupos de Compras (Rede & Terceiros)
Private aNumCpR := {} //vetor de Compras (Rede & Terceiros)
Private aIteCpR := {} //vetor de Compras (Rede & Terceiros)
Private aNumCpO := {} //vetor de Compras (Outras)
Private aIteCpO := {} //vetor de Compras (Outras)
Private aNumCpE := {} //vetor de Compras (Especiais)
Private aIteCpE := {} //vetor de Compras (Especiais)
Private aNumVei := {} //vetor de Veiculos 0km vendidos no periodo
Private aNumEst := {} //vetor de Estoques
Private aGrpEst := {} //vetor de Grupos de Estoques
Private aNumTransf := {} //vetor de Transferencias
Private aGrpTransf := {} //vetor de Grupos de Transferencias
Private aTotOri := {} //vetor de Total de Pecas/Acessorios Originais
Private aTotNOri := {} //vetor de Total de Pecas/Acessorios Originais
Private aPecOri := {} //vetor de Pecas/Acessorios Originais
Private aPecNOri := {} //vetor de Pecas/Acessorios Nao Originais
Private cEstoque:= "NAO"
Private cbTxt   := Space(10)
Private cbCont  := 0
Private cString := "VEC"
Private Li      := 80
Private m_Pag   := 1
Private cAliasVEC := "SQLVEC"
Private cAliasSBM := "SQLSBM"
Private cAliasVE4 := "SQLVE4"
Private cAliasSB1 := "SQLSB1"
Private cAliasSF2 := "SQLSF2"
Private cAliasSD2 := "SQLSD2"
Private cAliasSF4 := "SQLSF4"
Private cAliasSA1 := "SQLSA1"
Private cAliasVO2 := "SQLVO2"
Private cAliasVO3 := "SQLVO3"
Private cAliasSB2 := "SQLSB2"
Private cAliasSD1 := "SQLSD1"
Private cAliasSA2 := "SQLSA2"
Private cAliasVV0 := "SQLVV0"
Private cAliasVV1 := "SQLVV1"
Private cAliasSF1 := "SQLSF1"
Private cAliasVOO := "SQLVOO"
Private cAliasVOI := "SQLVOI"
Private cQuery    := ""

Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer

cTitulo   := IIf(!Empty(MV_PAR01),STR0001 + " - "+ STR0047 + Transform(MV_PAR01,"@D") + STR0048 + Transform(MV_PAR02,"@D"),STR0001)
cabec1    := ""
cabec2    := ""
nomeprog  := "OFIOR290"
tamanho   := "P"
nCaracter := 15
cCabTot   := STR0002

If MV_PAR13==2 .and. MSGYESNO( STR0035 + Transform(MV_PAR14,"@D") + STR0036 + Transform(MV_PAR16,"@D") + STR0037 )
	cEstoque := "SIM"
Else
	MV_PAR13 := 1
EndIf

cChave := Alltrim(MV_PAR06)
For ni:=1 to len(cChave)
	aAdd(aChave01,{substr(cChave,ni,6)})
	ni := ni + 6
Next
cChave := Alltrim(MV_PAR07)
For ni:=1 to len(cChave)
	aAdd(aChave02,{substr(cChave,ni,6)})
	ni := ni + 6
Next
cChave := Alltrim(MV_PAR08)
For ni:=1 to len(cChave)
	aAdd(aChave03,{substr(cChave,ni,6)})
	ni := ni + 6
Next
cChave := Alltrim(MV_PAR09)
For ni:=1 to len(cChave)
	aAdd(aChave04,{substr(cChave,ni,6)})
	ni := ni + 6
Next
cChave := Alltrim(MV_PAR10)
For ni:=1 to len(cChave)
	aAdd(aChave05,{substr(cChave,ni,6)})
	ni := ni + 6
Next
cChave := Alltrim(MV_PAR11)
For ni:=1 to len(cChave)
	aAdd(aChave06,{substr(cChave,ni,6)})
	ni := ni + 6
Next
cChave := Alltrim(MV_PAR12)
For ni:=1 to len(cChave)
	aAdd(aChave07,{substr(cChave,ni,6)})
	ni := ni + 6
Next

nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1

//   V E N D A S
aTotal  := {} //zera vetor de Totais
aAdd(aTotal,{ 0 , 0 })
aNumPec := {} //zera vetor de Pecas
aItePec := {} //zera vetor de Pecas
aTotPec := {} //zera vetor Total de Pecas (Interna, Externa e Acessorios)
aGrpPec := {} //zera vetor Grupos de Pecas Oficina
aNumAce := {} //zera vetor de Acessorios
aTotAce := {} //zera vetor Total de Acessorios
aNumLub := {} //zera vetor de Lubrificantes
aIteLub := {} //zera vetor de Lubrificantes
aTotLub := {} //zera vetor Total de Lubrificantes
aNumPen := {} //zera vetor de Vendas Pendentes
aItePen := {} //zera vetor de Itens de Vendas Pendentes
aTotPen := {} //zera vetor Total de Vendas Pendentes
aNumBPc := {} //zera vetor de Pecas Balcao (FISICA)
aIteBPc := {} //zera vetor de Pecas Balcao (FISICA)
aTotBPc := {} //zera vetor Total de Pecas Balcao (FISICA)
aTotPBO := {} //zera vetor Total Balcao/Oficina

//   C O M P R A S
aGrpCpR := {} //zera vetor de Grupos Compras Rede & Terceiros
aNumCpR := {} //zera vetor de Compras Rede & Terceiros
aIteCpR := {} //zera vetor de Compras Rede & Terceiros
aNumCpO := {} //zera vetor de Compras Outras
aIteCpO := {} //zera vetor de Compras Outras
aNumCpE := {} //zera vetor de Compras Especiais
aIteCpE := {} //zera vetor de Compras Especiais

// E S T O Q U E S    P E C / A C E / O U T
aNumEst := {} //zera vetor de Estoques
aGrpEst := {} //zera vetor de Grupos de Estoques
aTotOri := {} //zera vetor de Totais de Pecas/Acessorios Originais
aTotNOri := {} //zera vetor de Totais de Pecas/Acessorios Originais
aPecOri := {} //zera vetor de Pecas/Acessorios Originais
aPecNOri := {} //zera vetor de Pecas/Acessorios Nao Originais

// T R A N S F E R E N C I A S
aNumTransf := {} //zera vetor de Transferencias
aGrpTransf := {} //zera vetor de Grupos de Transferencias

nCont := 0
SetRegua(13)
IncRegua()

aAdd(aTotPec,{ 0 , 0 })  // Total de Pecas (Interna, Externa e Acessorios)
aAdd(aTotLub,{ 0 , 0 })  // Total de Lubrificantes
aAdd(aTotPen,{ 0 , 0 })  // Total de Vendas Pendentes
aAdd(aTotAce,{ 0 , 0 })  // Total de Acessorios
aAdd(aTotBPc,{ 0 , 0 })  // Total de Pecas Balcao (FISICA)
aAdd(aTotPBO,{ 0 , 0 })  // Total de Pecas Balcao/Oficina (BALCAO)
aAdd(aTotPBO,{ 0 , 0 })  // Total de Pecas Balcao/Oficina (OFICINA)
aAdd(aGrpPec,{ "A" , "01" , STR0003 , 0 , 0 })	// Grupo Pecas - Governo
aAdd(aGrpPec,{ "A" , "02" , STR0004 , 0 , 0 })	// Grupo Pecas - Frotistas
aAdd(aGrpPec,{ "A" , "03" , STR0005 , 0 , 0 })	// Grupo Pecas - Seguradoras
aAdd(aGrpPec,{ "A" , "04" , STR0006 , 0 , 0 })	// Grupo Pecas - Lj de Pecas
aAdd(aGrpPec,{ "A" , "05" , STR0007 , 0 , 0 })	// Grupo Pecas - Oficinas Independentes
aAdd(aGrpPec,{ "A" , "06" , STR0008 , 0 , 0 })	// Grupo Pecas - Rede (Concess. / Outros Distr.)
aAdd(aGrpPec,{ "O" , "07" , STR0009 , 0 , 0 })	// Grupo Pecas - Governo
aAdd(aGrpPec,{ "O" , "08" , STR0010 , 0 , 0 })	// Grupo Pecas - Frotistas
aAdd(aGrpPec,{ "O" , "09" , STR0011 , 0 , 0 })	// Grupo Pecas - Seguradoras
aAdd(aGrpPec,{ "O" , "10" , STR0012 , 0 , 0 })	// Grupo Pecas - Demais Clientes
aAdd(aGrpPec,{ "O" , "11" , STR0013 , 0 , 0 })	// Grupo Pecas - Garantia
aAdd(aGrpPec,{ "O" , "12" , STR0014 , 0 , 0 })	// Grupo Pecas - Consumo Interno
IncRegua()

DbSelectArea( "VEC" )

If Select(cAliasVEC) > 0
	( cAliasVEC )->( DbCloseArea() )
EndIf
cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName( "VEC" ) + " VEC "
cQuery += "WHERE "
cQuery += "VEC.VEC_FILIAL='"+ xFilial("VEC")+ "' AND "
If !Empty(MV_PAR01)
	cQuery += " VEC.VEC_DATVEN >= '"+Dtos(MV_PAR01)+"' AND "
EndIf
If !Empty(MV_PAR02)
	cQuery += " VEC.VEC_DATVEN <= '"+Dtos(MV_PAR02)+"' AND "
EndIf
cQuery += "VEC.D_E_L_E_T_=' ' ORDER BY VEC.VEC_DATVEN, VEC.VEC_GRUITE, VEC.VEC_CODITE"

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVEC, .T., .T. )

IncRegua()

While !(cAliasVEC)->(Eof())
	
	If (nCont==350 .or. nCont==700 .or. nCont==1100 .or. nCont==1600 .or. nCont==2500)
		IncRegua()
	EndIf
	nCont ++
	If Select(cAliasSBM) > 0
		( cAliasSBM )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SBM.BM_CODMAR, SBM.BM_TIPGRU, SBM.BM_DESC, SBM.BM_PROORI "
	cQuery += "FROM "+RetSqlName( "SBM" ) + " SBM "
	cQuery += "WHERE "
	cQuery += "SBM.BM_FILIAL='"+ xFilial("SBM")+ "' AND SBM.BM_GRUPO='"+(cAliasVEC)->VEC_GRUITE+"' AND "
	cQuery += "SBM.D_E_L_E_T_=' ' ORDER BY SBM.BM_GRUPO"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSBM, .T., .T. )
	
	If Select(cAliasVE4) > 0
		( cAliasVE4 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT VE4.VE4_CDOPSA, VE4.VE4_CODFOR, VE4.VE4_LOJFOR, VE4.VE4_CDOPEN "
	cQuery += "FROM "+RetSqlName( "VE4" ) + " VE4 "
	cQuery += "WHERE "
	cQuery += "VE4.VE4_FILIAL='"+ xFilial("VE4")+ "' AND VE4.VE4_PREFAB='"+(cAliasSBM)->BM_CODMAR+"' AND "
	cQuery += "VE4.D_E_L_E_T_=' ' ORDER BY VE4.VE4_PREFAB"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVE4, .T., .T. )
	
	If Select(cAliasSB1) > 0
		( cAliasSB1 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SB1.B1_GRUPO, SB1.B1_COD, SB1.B1_ORIGEM, SB1.B1_LOCPAD "
	cQuery += "FROM "+RetSqlName( "SB1" ) + " SB1 "
	cQuery += "WHERE "
	cQuery += "SB1.B1_FILIAL='"+ xFilial("SB1")+ "' AND SB1.B1_GRUPO='"+(cAliasVEC)->VEC_GRUITE+"' AND SB1.B1_CODITE='"+(cAliasVEC)->VEC_CODITE+"' AND "
	cQuery += "SB1.D_E_L_E_T_=' ' ORDER BY SB1.B1_GRUPO, SB1.B1_CODITE"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSB1, .T., .T. )
	
	If Select(cAliasSF2) > 0
		( cAliasSF2 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_PREFIXO "
	cQuery += "FROM "+RetSqlName( "SF2" ) + " SF2 "
	cQuery += "WHERE "
	cQuery += "SF2.F2_FILIAL='"+ xFilial("SF2")+ "' AND SF2.F2_DOC='"+(cAliasVEC)->VEC_NUMNFI+"' AND SF2.F2_SERIE='"+(cAliasVEC)->VEC_SERNFI+"' AND "
	cQuery += "SF2.D_E_L_E_T_=' ' ORDER BY SF2.F2_DOC, SF2.F2_SERIE"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSF2, .T., .T. )
	
	If Select(cAliasSD2) > 0
		( cAliasSD2 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SD2.D2_TES, SD2.D2_EMISSAO, SD2.D2_GRUPO, SD2.D2_COD, SD2.D2_CF, SD2.D2_TOTAL "
	cQuery += "FROM "+RetSqlName( "SD2" ) + " SD2 "
	cQuery += "WHERE "
	cQuery += "SD2.D2_FILIAL='"+ xFilial("SD2")+ "' AND SD2.D2_DOC='"+(cAliasSF2)->F2_DOC+"' AND SD2.D2_SERIE='"+(cAliasSF2)->F2_SERIE+"' AND SD2.D2_CLIENTE='"+(cAliasSF2)->F2_CLIENTE+"' AND SD2.D2_LOJA='"+(cAliasSF2)->F2_LOJA+"' AND SD2.D2_COD='"+(cAliasSB1)->B1_COD+"' AND "
	cQuery += "SD2.D_E_L_E_T_=' ' ORDER BY SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSD2, .T., .T. )
	
	If Select(cAliasSF4) > 0
		( cAliasSF4 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SF4.F4_DUPLIC, SF4.F4_ESTOQUE, SF4.F4_OPEMOV, SF4.F4_PISCRED, SF4.F4_PISCOF "
	cQuery += "FROM "+RetSqlName( "SF4" ) + " SF4 "
	cQuery += "WHERE "
	cQuery += "SF4.F4_FILIAL='"+ xFilial("SF4")+ "' AND SF4.F4_CODIGO='"+(cAliasSD2)->D2_TES+"' AND "
	cQuery += "SF4.D_E_L_E_T_=' ' ORDER BY SF4.F4_CODIGO"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSF4, .T., .T. )
	
	
	if (cAliasVEC)->VEC_TIPTEM # "I"
		If (cAliasSF4)->F4_DUPLIC # "S" .or. (cAliasSF4)->F4_ESTOQUE # "S"
			DbSelectArea(cAliasVEC)
			Dbskip()
			loop
		EndIf
	Endif
	If ( (!Empty(MV_PAR01) .and. (Stod((cAliasVEC)->VEC_DATVEN) < MV_PAR01)) .Or. (  (cAliasVE4)->(Found()) .And. (cAliasSD2)->D2_TES == FG_TABTRIB((cAliasVE4)->VE4_CDOPSA,(cAliasSB1)->B1_ORIGEM) ) )
		DbSelectArea(cAliasVEC)
		Dbskip()
		loop
	EndIf
	
	If Select(cAliasSA1) > 0
		( cAliasSA1 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SA1.A1_NOME, SA1.A1_CGC, SA1.A1_SATIV1 "
	cQuery += "FROM "+RetSqlName( "SA1" ) + " SA1 "
	cQuery += "WHERE "
	cQuery += "SA1.A1_FILIAL='"+ xFilial("SA1")+ "' AND SA1.A1_COD='"+(cAliasSF2)->F2_CLIENTE+"' AND SA1.A1_LOJA='"+(cAliasSF2)->F2_LOJA+"' AND "
	cQuery += "SA1.D_E_L_E_T_=' ' ORDER BY SA1.A1_COD, SA1.A1_LOJA"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSA1, .T., .T. )
	
	nPvalvda := IIf( MV_PAR03 == 1 , (cAliasVEC)->VEC_VALVDA , IIf( MV_PAR03 == 2 , (cAliasVEC)->VEC_VMFVDA , xmoeda((cAliasVEC)->VEC_VALVDA,1,MV_PAR03,DDataBase)))
	nPvalicm := IIf( MV_PAR03 == 1 , (cAliasVEC)->VEC_VALICM , IIf( MV_PAR03 == 2 , (cAliasVEC)->VEC_VMFICM , xmoeda((cAliasVEC)->VEC_VALICM,1,MV_PAR03,DDataBase)))
	nPvalpis := IIf( MV_PAR03 == 1 , (cAliasVEC)->VEC_VALPIS , IIf( MV_PAR03 == 2 , (cAliasVEC)->VEC_VMFPIS , xmoeda((cAliasVEC)->VEC_VALPIS,1,MV_PAR03,DDataBase)))
	nPvalcof := IIf( MV_PAR03 == 1 , (cAliasVEC)->VEC_VALCOF , IIf( MV_PAR03 == 2 , (cAliasVEC)->VEC_VMFCOF , xmoeda((cAliasVEC)->VEC_VALCOF,1,MV_PAR03,DDataBase)))
	nPvalvda := ( nPvalvda - ( nPvalicm + nPvalpis + nPvalcof ) )
	nPcustot := IIf( MV_PAR03 == 1 , (cAliasVEC)->VEC_CUSTOT , IIf( MV_PAR03 == 2 , (cAliasVEC)->VEC_CMFTOT , xmoeda((cAliasVEC)->VEC_CUSTOT,1,MV_PAR03,DDataBase)))
	
	
	///////////////////////
	//    ACESSORIOS     //
	///////////////////////
	
	If Alltrim((cAliasSBM)->BM_TIPGRU) $ "8|9" // ACESSORIOS ORIGINAIS E NAO ORIGINAIS
		
		nPos :=0
		If MV_PAR05 == 1
			nPos  := aScan(aNumAce,{|x| x[1] == (cAliasVEC)->VEC_GRUITE })
		Else
			nPos  := aScan(aNumAce,{|x| x[1] == (cAliasSF2)->F2_CLIENTE })
		EndIf
		If nPos == 0
			If MV_PAR05 == 1
				aAdd(aNumAce,{ (cAliasVEC)->VEC_GRUITE , (cAliasSBM)->BM_DESC , nPvalvda , nPcustot })
			Else
				aAdd(aNumAce,{ (cAliasSF2)->F2_CLIENTE , (cAliasSA1)->A1_NOME , nPvalvda , nPcustot })
			EndIf
		Else
			aNumAce[nPos,3] += nPvalvda
			aNumAce[nPos,4] += nPcustot
		EndIf
		if mv_par05 == 2
			nPos1 := aScan(aIteAce,{|x| x[1] + x[2] + x[3] == (cAliasSF2)->F2_CLIENTE + (cAliasVEC)->VEC_NUMNFI + (cAliasVEC)->VEC_SERNFI })
			if nPos1 == 0
				aAdd(aIteAce,{ (cAliasSF2)->F2_CLIENTE , (cAliasVEC)->VEC_NUMNFI , (cAliasVEC)->VEC_SERNFI , nPvalvda , nPcustot})
			Else
				aIteAce[nPos1,4] += nPvalvda
				aIteAce[nPos1,5] += nPcustot
			Endif
		Endif
		aTotAce[1,1] += nPvalvda
		aTotAce[1,2] += nPcustot
		aTotPec[1,1] += nPvalvda
		aTotPec[1,2] += nPcustot
		aTotal[1,1]  += nPvalvda
		aTotal[1,2]  += nPcustot
		
		///////////////////////
		//   OUTRAS VENDAS   //
		///////////////////////
		
	ElseIf alltrim((cAliasSBM)->BM_TIPGRU) $ "2|3|A"    //LUB/PNEU/MOTOR/
		nPos :=0
		If MV_PAR05 == 1
			nPos  := aScan(aNumLub,{|x| x[1] == (cAliasVEC)->VEC_GRUITE })
		Else
			nPos  := aScan(aNumLub,{|x| x[1] == (cAliasSF2)->F2_CLIENTE })
		EndIf
		If nPos == 0
			If MV_PAR05 == 1
				aAdd(aNumLub,{ (cAliasVEC)->VEC_GRUITE , (cAliasSBM)->BM_DESC , nPvalvda , nPcustot })
			Else
				aAdd(aNumLub,{ (cAliasSF2)->F2_CLIENTE , (cAliasSA1)->A1_NOME , nPvalvda , nPcustot })
			EndIf
		Else
			aNumLub[nPos,3] += nPvalvda
			aNumLub[nPos,4] += nPcustot
		EndIf
		if mv_par05 == 2
			nPos1 := aScan(aIteLub,{|x| x[1] + x[2] + x[3] == (cAliasSF2)->F2_CLIENTE + (cAliasVEC)->VEC_NUMNFI + (cAliasVEC)->VEC_SERNFI })
			if nPos1 == 0
				aAdd(aIteLub,{ (cAliasSF2)->F2_CLIENTE , (cAliasVEC)->VEC_NUMNFI , (cAliasVEC)->VEC_SERNFI , nPvalvda , nPcustot})
			Else
				aIteLub[nPos1,4] += nPvalvda
				aIteLub[nPos1,5] += nPcustot
			Endif
		Endif
		aTotLub[1,1] += nPvalvda
		aTotLub[1,2] += nPcustot
		aTotal[1,1]  += nPvalvda
		aTotal[1,2]  += nPcustot
		
	Else
		
		///////////////////////
		//  ATACADO/EXTERNA  //
		///////////////////////
		
		If (cAliasVEC)->VEC_BALOFI == "B"
			
			cSomou := "N"
			
			If (Len(Alltrim((cAliasSA1)->A1_CGC)) == 14) //  -->   Juridica
				
				nPos := 0
				nPos := aScan(aChave01,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Governo
				If nPos > 0
					cSomou := "S"
					aGrpPec[1,4] += nPvalvda
					aGrpPec[1,5] += nPcustot
					aTotPBO[1,1] += nPvalvda
					aTotPBO[1,2] += nPcustot
					aTotPec[1,1] += nPvalvda
					aTotPec[1,2] += nPcustot
					aTotal[1,1]  += nPvalvda
					aTotal[1,2]  += nPcustot
					If MV_PAR05 == 1
						nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "A" + "01" + (cAliasVEC)->VEC_GRUITE })
					Else
						nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "A" + "01" + (cAliasSF2)->F2_CLIENTE })
					EndIf
					If nPos == 0
						If MV_PAR05 == 1
							aAdd(aNumPec,{ "A" , "01" , (cAliasVEC)->VEC_GRUITE , (cAliasSBM)->BM_DESC , nPvalvda , nPcustot })
						Else
							aAdd(aNumPec,{ "A" , "01" , (cAliasSF2)->F2_CLIENTE , (cAliasSA1)->A1_NOME , nPvalvda , nPcustot })
						EndIf
					Else
						aNumPec[nPos,5] += nPvalvda
						aNumPec[nPos,6] += nPcustot
					EndIf
					if mv_par04 == 3
						if mv_par20 == "01"
							nPos1 := aScan(aItePec,{|x| x[1] + x[2] + x[3] + x[4] + x[5] == "A" + "01" + (cAliasSF2)->F2_CLIENTE + (cAliasVEC)->VEC_NUMNFI + (cAliasVEC)->VEC_SERNFI })
							if nPos1 == 0
								aAdd(aItePec,{ "A" , "01" , (cAliasSF2)->F2_CLIENTE , (cAliasVEC)->VEC_NUMNFI , (cAliasVEC)->VEC_SERNFI , nPvalvda , nPcustot })
							Else
								aItePec[nPos1,6] += nPvalvda
								aItePec[nPos1,7] += nPcustot
							Endif
						Endif
					Endif
				EndIf
				
				nPos := 0
				nPos := aScan(aChave02,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Frotistas
				If nPos > 0
					cSomou := "S"
					aGrpPec[2,4] += nPvalvda
					aGrpPec[2,5] += nPcustot
					aTotPBO[1,1] += nPvalvda
					aTotPBO[1,2] += nPcustot
					aTotPec[1,1] += nPvalvda
					aTotPec[1,2] += nPcustot
					aTotal[1,1]  += nPvalvda
					aTotal[1,2]  += nPcustot
					If MV_PAR05 == 1
						nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "A" + "02" + (cAliasVEC)->VEC_GRUITE })
					Else
						nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "A" + "02" + (cAliasSF2)->F2_CLIENTE })
					EndIf
					If nPos == 0
						If MV_PAR05 == 1
							aAdd(aNumPec,{ "A" , "02" , (cAliasVEC)->VEC_GRUITE , (cAliasSBM)->BM_DESC , nPvalvda , nPcustot })
						Else
							aAdd(aNumPec,{ "A" , "02" , (cAliasSF2)->F2_CLIENTE , (cAliasSA1)->A1_NOME , nPvalvda , nPcustot })
						EndIf
					Else
						aNumPec[nPos,5] += nPvalvda
						aNumPec[nPos,6] += nPcustot
					EndIf
					if mv_par04 == 3
						if mv_par20 == "02"
							nPos1 := aScan(aItePec,{|x| x[1] + x[2] + x[3] + x[4] + x[5] == "A" + "02" + (cAliasSF2)->F2_CLIENTE + (cAliasVEC)->VEC_NUMNFI + (cAliasVEC)->VEC_SERNFI })
							if nPos1 == 0
								aAdd(aItePec,{ "A" , "02" , (cAliasSF2)->F2_CLIENTE , (cAliasVEC)->VEC_NUMNFI , (cAliasVEC)->VEC_SERNFI , nPvalvda , nPcustot })
							Else
								aItePec[nPos1,6] += nPvalvda
								aItePec[nPos1,7] += nPcustot
							Endif
						Endif
					Endif
				EndIf
				
				nPos := 0
				nPos := aScan(aChave03,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Seguradoras
				If nPos > 0
					cSomou := "S"
					aGrpPec[3,4] += nPvalvda
					aGrpPec[3,5] += nPcustot
					aTotPBO[1,1] += nPvalvda
					aTotPBO[1,2] += nPcustot
					aTotPec[1,1] += nPvalvda
					aTotPec[1,2] += nPcustot
					aTotal[1,1]  += nPvalvda
					aTotal[1,2]  += nPcustot
					If MV_PAR05 == 1
						nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "A" + "03" + (cAliasVEC)->VEC_GRUITE })
					Else
						nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "A" + "03" + (cAliasSF2)->F2_CLIENTE })
					EndIf
					If nPos == 0
						If MV_PAR05 == 1
							aAdd(aNumPec,{ "A" , "03" , (cAliasVEC)->VEC_GRUITE , (cAliasSBM)->BM_DESC , nPvalvda , nPcustot })
						Else
							aAdd(aNumPec,{ "A" , "03" , (cAliasSF2)->F2_CLIENTE , (cAliasSA1)->A1_NOME , nPvalvda , nPcustot })
						EndIf
					Else
						aNumPec[nPos,5] += nPvalvda
						aNumPec[nPos,6] += nPcustot
					EndIf
					if mv_par04 == 3
						if mv_par20 == "03"
							nPos1 := aScan(aItePec,{|x| x[1] + x[2] + x[3] + x[4] + x[5] == "A" + "03" + (cAliasSF2)->F2_CLIENTE + (cAliasVEC)->VEC_NUMNFI + (cAliasVEC)->VEC_SERNFI })
							if nPos1 == 0
								aAdd(aItePec,{ "A" , "03" , (cAliasSF2)->F2_CLIENTE , (cAliasVEC)->VEC_NUMNFI , (cAliasVEC)->VEC_SERNFI , nPvalvda , nPcustot })
							Else
								aItePec[nPos1,6] += nPvalvda
								aItePec[nPos1,7] += nPcustot
							Endif
						Endif
					Endif
				EndIf
				
			EndIf
			
			nPos := 0
			nPos := aScan(aChave04,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) // Lojas de Pecas
			If nPos > 0
				cSomou := "S"
				aGrpPec[4,4] += nPvalvda
				aGrpPec[4,5] += nPcustot
				aTotPBO[1,1] += nPvalvda
				aTotPBO[1,2] += nPcustot
				aTotPec[1,1] += nPvalvda
				aTotPec[1,2] += nPcustot
				aTotal[1,1]  += nPvalvda
				aTotal[1,2]  += nPcustot
				If MV_PAR05 == 1
					nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "A" + "04" + (cAliasVEC)->VEC_GRUITE })
				Else
					nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "A" + "04" + (cAliasSF2)->F2_CLIENTE })
				EndIf
				If nPos == 0
					If MV_PAR05 == 1
						aAdd(aNumPec,{ "A" , "04" , (cAliasVEC)->VEC_GRUITE , (cAliasSBM)->BM_DESC , nPvalvda , nPcustot })
					Else
						aAdd(aNumPec,{ "A" , "04" , (cAliasSF2)->F2_CLIENTE , (cAliasSA1)->A1_NOME , nPvalvda , nPcustot })
					EndIf
				Else
					aNumPec[nPos,5] += nPvalvda
					aNumPec[nPos,6] += nPcustot
				EndIf
				if mv_par04 == 3
					if mv_par20 == "04"
						nPos1 := aScan(aItePec,{|x| x[1] + x[2] + x[3] + x[4] + x[5] == "A" + "04" + (cAliasSF2)->F2_CLIENTE + (cAliasVEC)->VEC_NUMNFI + (cAliasVEC)->VEC_SERNFI })
						if nPos1 == 0
							aAdd(aItePec,{ "A" , "04" , (cAliasSF2)->F2_CLIENTE , (cAliasVEC)->VEC_NUMNFI , (cAliasVEC)->VEC_SERNFI , nPvalvda , nPcustot })
						Else
							aItePec[nPos1,6] += nPvalvda
							aItePec[nPos1,7] += nPcustot
						Endif
					Endif
				Endif
			EndIf
			
			nPos := 0
			nPos := aScan(aChave05,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) // Oficinas Independentes
			If nPos > 0
				cSomou := "S"
				aGrpPec[5,4] += nPvalvda
				aGrpPec[5,5] += nPcustot
				aTotPBO[1,1] += nPvalvda
				aTotPBO[1,2] += nPcustot
				aTotPec[1,1] += nPvalvda
				aTotPec[1,2] += nPcustot
				aTotal[1,1]  += nPvalvda
				aTotal[1,2]  += nPcustot
				If MV_PAR05 == 1
					nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "A" + "05" + (cAliasVEC)->VEC_GRUITE })
				Else
					nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "A" + "05" + (cAliasSF2)->F2_CLIENTE })
				EndIf
				If nPos == 0
					If MV_PAR05 == 1
						aAdd(aNumPec,{ "A" , "05" , (cAliasVEC)->VEC_GRUITE , (cAliasSBM)->BM_DESC , nPvalvda , nPcustot })
					Else
						aAdd(aNumPec,{ "A" , "05" , (cAliasSF2)->F2_CLIENTE , (cAliasSA1)->A1_NOME , nPvalvda , nPcustot })
					EndIf
				Else
					aNumPec[nPos,5] += nPvalvda
					aNumPec[nPos,6] += nPcustot
				EndIf
				if mv_par04 == 3
					if mv_par20 == "05"
						nPos1 := aScan(aItePec,{|x| x[1] + x[2] + x[3] + x[4] + x[5] == "A" + "05" + (cAliasSF2)->F2_CLIENTE + (cAliasVEC)->VEC_NUMNFI + (cAliasVEC)->VEC_SERNFI })
						if nPos1 == 0
							aAdd(aItePec,{ "A" , "05" , (cAliasSF2)->F2_CLIENTE , (cAliasVEC)->VEC_NUMNFI , (cAliasVEC)->VEC_SERNFI , nPvalvda , nPcustot })
						Else
							aItePec[nPos1,6] += nPvalvda
							aItePec[nPos1,7] += nPcustot
						Endif
					Endif
				Endif
			EndIf
			
			nPos := 0
			nPos := aScan(aChave06,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Rede (Outros Distr./Concess.)
			If nPos > 0
				cSomou := "S"
				aGrpPec[6,4] += nPvalvda
				aGrpPec[6,5] += nPcustot
				aTotPBO[1,1] += nPvalvda
				aTotPBO[1,2] += nPcustot
				aTotPec[1,1] += nPvalvda
				aTotPec[1,2] += nPcustot
				aTotal[1,1]  += nPvalvda
				aTotal[1,2]  += nPcustot
				If MV_PAR05 == 1
					nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "A" + "06" + (cAliasVEC)->VEC_GRUITE })
				Else
					nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "A" + "06" + (cAliasSF2)->F2_CLIENTE })
				EndIf
				If nPos == 0
					If MV_PAR05 == 1
						aAdd(aNumPec,{ "A" , "06" , (cAliasVEC)->VEC_GRUITE , (cAliasSBM)->BM_DESC , nPvalvda , nPcustot })
					Else
						aAdd(aNumPec,{ "A" , "06" , (cAliasSF2)->F2_CLIENTE , (cAliasSA1)->A1_NOME , nPvalvda , nPcustot })
					EndIf
				Else
					aNumPec[nPos,5] += nPvalvda
					aNumPec[nPos,6] += nPcustot
				EndIf
				if mv_par04 == 3
					if mv_par20 == "06"
						nPos1 := aScan(aItePec,{|x| x[1] + x[2] + x[3] + x[4] + x[5] == "A" + "06" + (cAliasSF2)->F2_CLIENTE + (cAliasVEC)->VEC_NUMNFI + (cAliasVEC)->VEC_SERNFI })
						if nPos1 == 0
							aAdd(aItePec,{ "A" , "06" , (cAliasSF2)->F2_CLIENTE , (cAliasVEC)->VEC_NUMNFI , (cAliasVEC)->VEC_SERNFI , nPvalvda , nPcustot })
						Else
							aItePec[nPos1,6] += nPvalvda
							aItePec[nPos1,7] += nPcustot
						Endif
					Endif
				EndIf
			Endif
			If cSomou == "N"
				
				If MV_PAR05 == 1
					nPos  := aScan(aNumBPc,{|x| x[1] == (cAliasVEC)->VEC_GRUITE })
				Else
					nPos  := aScan(aNumBPc,{|x| x[1] == (cAliasSF2)->F2_CLIENTE })
				EndIf
				If nPos == 0
					If MV_PAR05 == 1
						aAdd(aNumBPc,{ (cAliasVEC)->VEC_GRUITE , (cAliasSBM)->BM_DESC , nPvalvda , nPcustot })
					Else
						aAdd(aNumBPc,{ (cAliasSF2)->F2_CLIENTE , (cAliasSA1)->A1_NOME , nPvalvda , nPcustot })
					EndIf
				Else
					aNumBPc[nPos,3] += nPvalvda
					aNumBPc[nPos,4] += nPcustot
				EndIf
				If MV_PAR05 == 2
					nPos1 := aScan(aIteBPc,{|x| x[1] + x[2] + x[3] == (cAliasSF2)->F2_CLIENTE + (cAliasVEC)->VEC_NUMNFI + (cAliasVEC)->VEC_SERNFI })
					if nPos1 == 0
						aAdd(aIteBPc,{ (cAliasSF2)->F2_CLIENTE , (cAliasVEC)->VEC_NUMNFI , (cAliasVEC)->VEC_SERNFI , nPvalvda , nPcustot })
					Else
						aIteBPc[nPos1,4] += nPvalvda
						aIteBPc[nPos1,5] += nPcustot
					Endif
				EndIf
				aTotPBO[1,1] += nPvalvda
				aTotPBO[1,2] += nPcustot
				aTotBPc[1,1] += nPvalvda
				aTotBPc[1,2] += nPcustot
				aTotPec[1,1] += nPvalvda
				aTotPec[1,2] += nPcustot
				aTotal[1,1]  += nPvalvda
				aTotal[1,2]  += nPcustot
				
			EndIf
			
			///////////////////////
			//  OFICINA/INTERNA  //
			///////////////////////
			
		Else //If (cAliasVEC)->VEC_BALOFI == "O"
			
			DbSelectArea("VOI")
			DbSetOrder(1)
			DbSeek(xFilial("VOI")+(cAliasVEC)->VEC_TIPTEM)
			
			If VOI->VOI_SITTPO $ "2/4"
				aGrpPec[11,4] += nPvalvda
				aGrpPec[11,5] += nPcustot
				aTotPBO[2,1] += nPvalvda
				aTotPBO[2,2] += nPcustot
				aTotPec[1,1] += nPvalvda
				aTotPec[1,2] += nPcustot
				aTotal[1,1]  += nPvalvda
				aTotal[1,2]  += nPcustot
				If MV_PAR05 == 1
					nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "O" + "11" + (cAliasVEC)->VEC_GRUITE })
				Else
					nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "O" + "11" + (cAliasSF2)->F2_CLIENTE })
				EndIf
				If nPos == 0
					If MV_PAR05 == 1
						aAdd(aNumPec,{ "O" , "11" , (cAliasVEC)->VEC_GRUITE , (cAliasSBM)->BM_DESC , nPvalvda , nPcustot })
					Else
						aAdd(aNumPec,{ "O" , "11" , (cAliasSF2)->F2_CLIENTE , (cAliasSA1)->A1_NOME , nPvalvda , nPcustot })
					EndIf
				Else
					aNumPec[nPos,5] += nPvalvda
					aNumPec[nPos,6] += nPcustot
				EndIf
				if mv_par04 == 3
					if mv_par20 == "11"
						nPos1 := aScan(aItePec,{|x| x[1] + x[2] + x[3] + x[4] + x[5] == "O" + "11" + (cAliasSF2)->F2_CLIENTE + (cAliasVEC)->VEC_NUMNFI + (cAliasVEC)->VEC_SERNFI })
						if nPos1 == 0
							aAdd(aItePec,{ "A" , "11" , (cAliasSF2)->F2_CLIENTE , (cAliasVEC)->VEC_NUMNFI , (cAliasVEC)->VEC_SERNFI , nPvalvda , nPcustot })
						Else
							aItePec[nPos1,6] += nPvalvda
							aItePec[nPos1,7] += nPcustot
						Endif
					Endif
				Endif
				
				
			ElseIf VOI->VOI_SITTPO == "3"
				
				aGrpPec[12,4] += nPcustot // nPvalvda
				aGrpPec[12,5] += nPcustot
				aTotPBO[2,1] += nPcustot // nPvalvda
				aTotPBO[2,2] += nPcustot
				aTotPec[1,1] += nPcustot // nPvalvda
				aTotPec[1,2] += nPcustot
				aTotal[1,1]  += nPcustot // nPvalvda
				aTotal[1,2]  += nPcustot
				If MV_PAR05 == 1
					nPos := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "O" + "12" + (cAliasVEC)->VEC_GRUITE })
				Else
					cAlias__ := alias()
					DbSelectArea("VO1")
					VO1->(DbSetorder(1))
					VO1->(DbSeek(xFilial("VO1")+(cAliasVEC)->VEC_NUMOSV))
					DbSelectArea( "SA1" )
					DbSetOrder(1)
					DbSeek( xFilial("SA1") + VO1->VO1_PROVEI + VO1->VO1_LOJPRO)
					nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "O" + "12" + VO1->VO1_PROVEI })
					dbSelectArea(cAlias__)
				EndIf
				If nPos == 0
					If MV_PAR05 == 1
						aAdd(aNumPec,{ "O" , "12" , (cAliasVEC)->VEC_GRUITE , (cAliasSBM)->BM_DESC , nPcustot , nPcustot })
					Else
						aAdd(aNumPec,{ "O" , "12" , VO1->VO1_PROVEI , (cAliasSA1)->A1_NOME , nPcustot , nPcustot })
					EndIf
				Else
					aNumPec[nPos,5] += nPcustot // nPvalvda
					aNumPec[nPos,6] += nPcustot
				EndIf
				if mv_par04 == 3
					if mv_par20 == "12"
						nPos1 := aScan(aItePec,{|x| x[1] + x[2] + x[3] + x[4] + x[5] == "O" + "12" + VO1->VO1_PROVEI + (cAliasVEC)->VEC_NUMNFI + (cAliasVEC)->VEC_SERNFI })
						if nPos1 == 0
							aAdd(aItePec,{ "A" , "12" , VO1->VO1_PROVEI , (cAliasVEC)->VEC_NUMNFI , (cAliasVEC)->VEC_SERNFI , nPvalvda , nPcustot })
						Else
							aItePec[nPos1,6] += nPvalvda
							aItePec[nPos1,7] += nPcustot
						Endif
					Endif
				Endif
				
			Else
				
				cDCli := "S"
				nPos := 0
				nPos := aScan(aChave01,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Governo
				If nPos > 0
					cDCli := "N"
					aGrpPec[7,4] += nPvalvda
					aGrpPec[7,5] += nPcustot
					aTotPBO[2,1] += nPvalvda
					aTotPBO[2,2] += nPcustot
					aTotPec[1,1] += nPvalvda
					aTotPec[1,2] += nPcustot
					aTotal[1,1]  += nPvalvda
					aTotal[1,2]  += nPcustot
					If MV_PAR05 == 1
						nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "O" + "07" + (cAliasVEC)->VEC_GRUITE })
					Else
						nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "O" + "07" + (cAliasSF2)->F2_CLIENTE })
					EndIf
					If nPos == 0
						If MV_PAR05 == 1
							aAdd(aNumPec,{ "O" , "07" , (cAliasVEC)->VEC_GRUITE , (cAliasSBM)->BM_DESC , nPvalvda , nPcustot })
						Else
							aAdd(aNumPec,{ "O" , "07" , (cAliasSF2)->F2_CLIENTE , (cAliasSA1)->A1_NOME , nPvalvda , nPcustot })
						EndIf
					Else
						aNumPec[nPos,5] += nPvalvda
						aNumPec[nPos,6] += nPcustot
					EndIf
					if mv_par04 == 3
						if mv_par20 == "07"
							nPos1 := aScan(aItePec,{|x| x[1] + x[2] + x[3] + x[4] + x[5] == "O" + "07" + (cAliasSF2)->F2_CLIENTE + (cAliasVEC)->VEC_NUMNFI + (cAliasVEC)->VEC_SERNFI })
							if nPos1 == 0
								aAdd(aItePec,{ "A" , "07" , (cAliasSF2)->F2_CLIENTE , (cAliasVEC)->VEC_NUMNFI , (cAliasVEC)->VEC_SERNFI , nPvalvda , nPcustot })
							Else
								aItePec[nPos1,6] += nPvalvda
								aItePec[nPos1,7] += nPcustot
							Endif
						Endif
					EndIf
				Endif
				nPos := 0
				nPos := aScan(aChave02,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Frotistas
				If nPos > 0
					cDCli := "N"
					aGrpPec[8,4] += nPvalvda
					aGrpPec[8,5] += nPcustot
					aTotPBO[2,1] += nPvalvda
					aTotPBO[2,2] += nPcustot
					aTotPec[1,1] += nPvalvda
					aTotPec[1,2] += nPcustot
					aTotal[1,1]  += nPvalvda
					aTotal[1,2]  += nPcustot
					If MV_PAR05 == 1
						nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "O" + "08" + (cAliasVEC)->VEC_GRUITE })
					Else
						nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "O" + "08" + (cAliasSF2)->F2_CLIENTE })
					EndIf
					If nPos == 0
						If MV_PAR05 == 1
							aAdd(aNumPec,{ "O" , "08" , (cAliasVEC)->VEC_GRUITE , (cAliasSBM)->BM_DESC , nPvalvda , nPcustot })
						Else
							aAdd(aNumPec,{ "O" , "08" , (cAliasSF2)->F2_CLIENTE , (cAliasSA1)->A1_NOME , nPvalvda , nPcustot })
						EndIf
					Else
						aNumPec[nPos,5] += nPvalvda
						aNumPec[nPos,6] += nPcustot
					EndIf
					if mv_par04 == 3
						if mv_par20 == "08"
							nPos1 := aScan(aItePec,{|x| x[1] + x[2] + x[3] + x[4] + x[5] == "O" + "08" + (cAliasSF2)->F2_CLIENTE + (cAliasVEC)->VEC_NUMNFI + (cAliasVEC)->VEC_SERNFI })
							if nPos1 == 0
								aAdd(aItePec,{ "A" , "08" , (cAliasSF2)->F2_CLIENTE , (cAliasVEC)->VEC_NUMNFI , (cAliasVEC)->VEC_SERNFI , nPvalvda , nPcustot })
							Else
								aItePec[nPos1,6] += nPvalvda
								aItePec[nPos1,7] += nPcustot
							Endif
						Endif
					Endif
				EndIf
				
				nPos := 0
				nPos := aScan(aChave03,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Seguradoras
				If nPos > 0
					cDCli := "N"
					aGrpPec[9,4] += nPvalvda
					aGrpPec[9,5] += nPcustot
					aTotPBO[2,1] += nPvalvda
					aTotPBO[2,2] += nPcustot
					aTotPec[1,1] += nPvalvda
					aTotPec[1,2] += nPcustot
					aTotal[1,1]  += nPvalvda
					aTotal[1,2]  += nPcustot
					If MV_PAR05 == 1
						nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "O" + "09" + (cAliasVEC)->VEC_GRUITE })
					Else
						nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "O" + "09" + (cAliasSF2)->F2_CLIENTE })
					EndIf
					If nPos == 0
						If MV_PAR05 == 1
							aAdd(aNumPec,{ "O" , "09" , (cAliasVEC)->VEC_GRUITE , (cAliasSBM)->BM_DESC , nPvalvda , nPcustot })
						Else
							aAdd(aNumPec,{ "O" , "09" , (cAliasSF2)->F2_CLIENTE , (cAliasSA1)->A1_NOME , nPvalvda , nPcustot })
						EndIf
					Else
						aNumPec[nPos,5] += nPvalvda
						aNumPec[nPos,6] += nPcustot
					EndIf
					if mv_par04 == 3
						if mv_par20 == "09"
							nPos1 := aScan(aItePec,{|x| x[1] + x[2] + x[3] + x[4] + x[5] == "O" + "09" + (cAliasSF2)->F2_CLIENTE + (cAliasVEC)->VEC_NUMNFI + (cAliasVEC)->VEC_SERNFI })
							if nPos1 == 0
								aAdd(aItePec,{ "A" , "09" , (cAliasSF2)->F2_CLIENTE , (cAliasVEC)->VEC_NUMNFI , (cAliasVEC)->VEC_SERNFI , nPvalvda , nPcustot })
							Else
								aItePec[nPos1,6] += nPvalvda
								aItePec[nPos1,7] += nPcustot
							Endif
						Endif
					Endif
				EndIf
				
				If cDCli == "S"
					aGrpPec[10,4] += nPvalvda
					aGrpPec[10,5] += nPcustot
					aTotPBO[2,1] += nPvalvda
					aTotPBO[2,2] += nPcustot
					aTotPec[1,1] += nPvalvda
					aTotPec[1,2] += nPcustot
					aTotal[1,1]  += nPvalvda
					aTotal[1,2]  += nPcustot
					If MV_PAR05 == 1
						nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "O" + "10" + (cAliasVEC)->VEC_GRUITE })
					Else
						nPos  := aScan(aNumPec,{|x| x[1] + x[2] + x[3] == "O" + "10" + (cAliasSF2)->F2_CLIENTE })
					EndIf
					If nPos == 0
						If MV_PAR05 == 1
							aAdd(aNumPec,{ "O" , "10" , (cAliasVEC)->VEC_GRUITE , (cAliasSBM)->BM_DESC , nPvalvda , nPcustot })
						Else
							aAdd(aNumPec,{ "O" , "10" , (cAliasSF2)->F2_CLIENTE , (cAliasSA1)->A1_NOME , nPvalvda , nPcustot })
						EndIf
					Else
						aNumPec[nPos,5] += nPvalvda
						aNumPec[nPos,6] += nPcustot
					EndIf
					if mv_par04 == 3
						if mv_par20 == "10"
							nPos1 := aScan(aItePec,{|x| x[1] + x[2] + x[3] + x[4] + x[5] == "O" + "10" + (cAliasSF2)->F2_CLIENTE + (cAliasVEC)->VEC_NUMNFI + (cAliasVEC)->VEC_SERNFI })
							if nPos1 == 0
								aAdd(aItePec,{ "A" , "10" , (cAliasSF2)->F2_CLIENTE , (cAliasVEC)->VEC_NUMNFI , (cAliasVEC)->VEC_SERNFI , nPvalvda , nPcustot })
							Else
								aItePec[nPos1,6] += nPvalvda
								aItePec[nPos1,7] += nPcustot
							Endif
						Endif
					Endif
				EndIf
			EndIf
			
		EndIf
		
	EndIf
	
	DbSelectArea(cAliasVEC)
	Dbskip()
	
EndDo

IncRegua()
OFIOR29D()	// Devolucoes
IncRegua()
FS_VDAPEN() // Vendas Pendentes
IncRegua()
FS_COMPRA() // Compras
IncRegua()
FS_VEICUL() // Passagem de Veiculos
FS_ESTOQU() // Levantamento de Estoque na data informada na pergunte


///////////////////////
//  ZERAR   VETORES  //
///////////////////////
If MV_PAR04 # 1
	For ni:=1 to 6
		If aScan(aNumPec,{|x| x[1] + x[2] == "A" + strzero(ni,2) }) == 0
			aAdd(aNumPec,{ "A" , strzero(ni,2) , "SO_PARA_ZERAR" , "" , 0 , 0 })
		EndIf
	Next
	For ni:=7 to 12
		If aScan(aNumPec,{|x| x[1] + x[2] == "O" + strzero(ni,2) }) == 0
			aAdd(aNumPec,{ "O" , strzero(ni,2) , "SO_PARA_ZERAR" , "" , 0 , 0 })
		EndIf
	Next
	For ni:=1 to 3
		If aScan(aNumCpR,{|x| x[1] == strzero(ni,1) }) == 0
			aAdd(aNumCpR,{ strzero(ni,1) , "SO_PARA_ZERAR" , "" , 0 })
		EndIf
	Next
EndIf


/////////////////////////////////////////////////
//                                             //
//                                             //
//      I   M   P   R   E   S   S   A   O      //
//                                             //
//                                             //
/////////////////////////////////////////////////

IncRegua()
nLin++
@ nLin++ , 00 psay Repl("*",80)
@ nLin++ , 00 psay STR0015 + cCabTot
@ nLin++ , 00 psay STR0016 + Transform(aTotal[1,1],"@E 999999,999.99") + "  " + Transform(aTotal[1,2],"@E 999999,999.99")
@ nLin++ , 00 psay Repl("*",80)
nLin++
@ nLin++ , 52 psay cCabTot
@ nLin++ , 01 psay STR0017 + Transform(aTotPec[1,1],"@E 999,999,999.99") + "  " + Transform(aTotPec[1,2],"@E 999999,999.99")
nLin++
If nLin >= 58
	nLin := 1
	nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
EndIf

///////////////////////
//  VENDAS  ATACADO  //
///////////////////////

@ nLin++ , 52 psay cCabTot
@ nLin++ , 04 psay STR0018 + Transform(aTotPBO[1,1],"@E 999,999,999.99") + "  " + Transform(aTotPBO[1,2],"@E 999999,999.99")
If MV_PAR04 >= 2
	aSort(aGrpPec,1,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3]})
	aSort(aNumPec,1,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3]})
	aSort(aItePec,1,,{|x,y| x[1]+x[2]+x[3]+x[4]+x[5] < y[1]+y[2]+y[3]+y[4]+y[5]})
	cMudou := "9"
	j := 1
	For ni:=1 to Len(aNumPec)
		If aNumPec[ni,1] == "A"
			If nLin >= 60
				nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
				nLin++
				@ nLin++ , 52 psay cCabTot
				nLin++
			EndIf
			If cMudou # aNumPec[ni,2]
				If nLin >= 58
					nLin := 1
					nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
					nLin++
					@ nLin++ , 52 psay cCabTot
					nLin++
				EndIf
				cMudou := aNumPec[ni,2]
				nLin++
				nPos := aScan(aGrpPec,{|x| x[1] + x[2] == "A" + cMudou })
				@ nLin++ , 07 psay Alltrim(aGrpPec[nPos,3]) + repl(".",44 - len(Alltrim(aGrpPec[nPos,3]))) + " " + Transform(aGrpPec[nPos,4],"@E 999999,999.99") + "  " + Transform(aGrpPec[nPos,5],"@E 999999,999.99")
			EndIf
			
			If ((MV_PAR04 == 3) .and. (aNumPec[ni,3] # "SO_PARA_ZERAR"))
				@ nLin++ , 10 psay aNumPec[ni,3] + Repl(" ",7-len(aNumPec[ni,3])) + left(aNumPec[ni,4],34) + Repl(" ",34-len(aNumPec[ni,4])) + " " + Transform(aNumPec[ni,5],"@E 999999,999.99") + "  " + Transform(aNumPec[ni,6],"@E 999999,999.99")
				if mv_par04 == 3
					for i := j to Len(aItePec)
						if aNumPec[ni,1]+aNumPec[ni,2]+aNumPec[ni,3] == aItePec[i,1]+aItePec[i,2]+aItePec[i,3]
							If nLin >= 60
								nLin := 1
								nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
								nLin++
								@ nLin++ , 52 psay cCabTot
								nLin++
							EndIf
							@ nLin++, 001 pSay space(20)+left(aItePec[i,4]+" - "+aItePec[i,5]+space(33),33)+" "+transform(aItePec[i,6],"@E 999,999.99")+"     "+transform(aItePec[i,7],"@E 999,999.99")
						Else
							j := i
							Exit
						Endif
					Next
				Endif
			EndIf
			
		EndIf
	Next
EndIf
nLin++

////////////////////////
// VENDA BALCAO PECAS //
////////////////////////

If MV_PAR04 >= 2
	If nLin >= 58
		nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
	EndIf
	@ nLin++ , 07 psay STR0019 + Transform(aTotBPc[1,1],"@E 999,999,999.99") + "  " + Transform(aTotBPc[1,2],"@E 999999,999.99")
	If MV_PAR04 == 3
		aSort(aNumBPc,1,,{|x,y| x[1] < y[1] })
		aSort(aIteBPc,1,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] })
		j := 1
		For ni:=1 to Len(aNumBPc)
			If nLin >= 60
				nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
				nLin++
				@ nLin++ , 52 psay cCabTot
				nLin++
			EndIf
			If ((!Empty(aNumBPc[ni,1])).and.(!Empty(aNumBPc[ni,2])).and.(aNumBPc[ni,3]#0).and.(aNumBPc[ni,4]#0))
				@ nLin++ , 10 psay aNumBPc[ni,1] + Repl(" ",7-len(aNumBPc[ni,1])) + left(aNumBPc[ni,2],34) + Repl(" ",34-len(aNumBPc[ni,2])) + " " + Transform(aNumBPc[ni,3],"@E 999999,999.99") + "  " + Transform(aNumBPc[ni,4],"@E 999999,999.99")
				if mv_par04 == 3
					if mv_par20 == "15"
						for i := j to Len(aIteBPc)
							if aNumBPc[ni,1] == aIteBPc[i,1]
								If nLin >= 60
									nLin := 1
									nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
									nLin++
									@ nLin++ , 52 psay cCabTot
									nLin++
								EndIf
								@ nLin++, 001 pSay space(20)+left(aIteBPc[i,2]+" - "+aIteBPc[i,3]+space(33),33)+" "+transform(aIteBPc[i,4],"@E 999,999.99")+"     "+transform(aIteBPc[i,5],"@E 999,999.99")
							Else
								j := i
								Exit
							Endif
						Next
					Endif
				Endif
			EndIf
		Next
	EndIf
	nLin++
EndIf


///////////////////////
//   VENDA OFICINA   //
///////////////////////

If nLin >= 58
	nLin := 1
	nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
EndIf
@ nLin++ , 52 psay cCabTot
@ nLin++ , 04 psay STR0020 + Transform(aTotPBO[2,1],"@E 999,999,999.99") + "  " + Transform(aTotPBO[2,2],"@E 999999,999.99")
If MV_PAR04 >= 2
	cMudou := "9"
	j := 1
	For ni:=1 to Len(aNumPec)
		If aNumPec[ni,1] == "O"
			If nLin >= 60
				nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
				nLin++
				@ nLin++ , 52 psay cCabTot
				nLin++
			EndIf
			If cMudou # aNumPec[ni,2]
				If nLin >= 58
					nLin := 1
					nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
					nLin++
					@ nLin++ , 52 psay cCabTot
					nLin++
				EndIf
				cMudou := aNumPec[ni,2]
				nLin++
				nPos := aScan(aGrpPec,{|x| x[1] + x[2] == "O" + cMudou })
				@ nLin++ , 07 psay Alltrim(aGrpPec[nPos,3]) + repl(".",44 - len(Alltrim(aGrpPec[nPos,3]))) + " " + Transform(aGrpPec[nPos,4],"@E 999999,999.99") + "  " + Transform(aGrpPec[nPos,5],"@E 999999,999.99")
			EndIf
			If ((MV_PAR04 == 3) .and. (aNumPec[ni,3] # "SO_PARA_ZERAR"))
				@ nLin++ , 10 psay aNumPec[ni,3] + Repl(" ",7-len(aNumPec[ni,3])) + left(aNumPec[ni,4],34) + Repl(" ",34-len(aNumPec[ni,4])) + " " + Transform(aNumPec[ni,5],"@E 999999,999.99") + "  " + Transform(aNumPec[ni,6],"@E 999999,999.99")
				if mv_par04 == 3
					for i := j to Len(aItePec)
						if aNumPec[ni,1]+aNumPec[ni,2]+aNumPec[ni,3] == aItePec[i,1]+aItePec[i,2]+aItePec[i,3]
							If nLin >= 60
								nLin := 1
								nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
								nLin++
								@ nLin++ , 52 psay cCabTot
								nLin++
							EndIf
							@ nLin++, 001 pSay space(20)+left(aItePec[i,4]+" - "+aItePec[i,5]+space(33),33)+" "+transform(aItePec[i,6],"@E 999,999.99")+"     "+transform(aItePec[i,7],"@E 999,999.99")
						Else
							j := i
							Exit
						Endif
					Next
				Endif
			EndIf
		EndIf
	Next
EndIf
nLin++

///////////////////////
// VENDAS ACESSORIOS //
///////////////////////

If nLin >= 58
	nLin := 1
	nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
EndIf
@ nLin++ , 52 psay cCabTot
@ nLin++ , 04 psay STR0021 + Transform(aTotAce[1,1],"@E 999,999,999.99") + "  " + Transform(aTotAce[1,2],"@E 999999,999.99")
If MV_PAR04 == 3
	aSort(aNumAce,1,,{|x,y| x[1] < y[1] })
	aSort(aIteAce,1,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] })
	j := 1
	For ni:=1 to Len(aNumAce)
		If nLin >= 60
			nLin := 1
			nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
			nLin++
			@ nLin++ , 52 psay cCabTot
			nLin++
		EndIf
		@ nLin++ , 10 psay aNumAce[ni,1] + Repl(" ",7-len(aNumAce[ni,1])) + left(aNumAce[ni,2],34) + Repl(" ",34-len(aNumAce[ni,2])) + " " + Transform(aNumAce[ni,3],"@E 999999,999.99") + "  " + Transform(aNumAce[ni,4],"@E 999999,999.99")
		if mv_par04 == 3
			if mv_par20 == "17"
				for i := j to Len(aIteAce)
					if aNumAce[ni,1] == aIteAce[i,1]
						@ nLin++, 001 pSay space(20)+left(aIteAce[i,2]+" - "+aIteAce[i,3]+space(33),33)+" "+transform(aIteAce[i,4],"@E 999,999.99")+"     "+transform(aIteAce[i,5],"@E 999,999.99")
						If nLin >= 60
							nLin := 1
							nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
							nLin++
							@ nLin++ , 52 psay cCabTot
							nLin++
						EndIf
					Else
						j := i
						Exit
					Endif
				Next
			Endif
		Endif
	Next
EndIf
nLin++

///////////////////////
//   OUTRAS VENDAS   //
///////////////////////

If nLin >= 58
	nLin := 1
	nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
EndIf
@ nLin++ , 52 psay cCabTot
@ nLin++ , 01 psay STR0022 + Transform(aTotLub[1,1],"@E 999,999,999.99") + "  " + Transform(aTotLub[1,2],"@E 999999,999.99")
If MV_PAR04 == 3
	aSort(aNumLub,1,,{|x,y| x[1] < y[1] })
	aSort(aIteLub,1,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] })
	j := 1
	For ni:=1 to Len(aNumLub)
		If nLin >= 60
			nLin := 1
			nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
			nLin++
			@ nLin++ , 52 psay cCabTot
			nLin++
		EndIf
		@ nLin++ , 10 psay aNumLub[ni,1] + Repl(" ",7-len(aNumLub[ni,1])) + left(aNumLub[ni,2],34) + Repl(" ",34-len(aNumLub[ni,2])) + " " + Transform(aNumLub[ni,3],"@E 999999,999.99") + "  " + Transform(aNumLub[ni,4],"@E 999999,999.99")
		if mv_par04 == 3
			if mv_par20 == "18"
				for i := j to Len(aIteLub)
					if aNumLub[ni,1] == aIteLub[i,1]
						If nLin >= 60
							nLin := 1
							nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
							nLin++
							@ nLin++ , 52 psay cCabTot
							nLin++
						EndIf
						@ nLin++, 001 pSay space(20)+left(aIteLub[i,2]+" - "+aIteLub[i,3]+space(33),33)+" "+transform(aIteLub[i,4],"@E 999,999.99")+"     "+transform(aIteLub[i,5],"@E 999,999.99")
					Else
						j := i
						Exit
					Endif
				Next
			Endif
		Endif
	Next
EndIf
nLin++
IncRegua()

///////////////////////
// VENDAS  PENDENTES //
///////////////////////
If nLin >= 58
	nLin := 1
	nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
	nLin++
EndIf
@ nLin++ , 52 psay cCabTot
@ nLin++ , 01 psay STR0023 + Transform(aTotPen[1,1],"@E 999,999,999.99") + "  " + Transform(aTotPen[1,2],"@E 999999,999.99")
If MV_PAR04 == 3
	aSort(aNumPen,1,,{|x,y| x[1] < y[1]})
	aSort(aItePen,1,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3]})
	j := 1
	For ni:=1 to Len(aNumPen)
		If nLin >= 60
			nLin := 1
			nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
			nLin++
			@ nLin++ , 52 psay cCabTot
			nLin++
		EndIf
		if aNumPen[ni,3] <> 0 .and. aNumPen[ni,4] <> 0
			@ nLin++ , 10 psay aNumPen[ni,1] + Repl(" ",7-len(aNumPen[ni,1])) + left(aNumPen[ni,2],34) + Repl(" ",34-len(aNumPen[ni,2])) + " " + Transform(aNumPen[ni,3],"@E 999999,999.99") + "  " + Transform(aNumPen[ni,4],"@E 999999,999.99")
			if mv_par04 == 3
				if mv_par20 == "19"
					for i := j to Len(aItePen)
						if aNumPen[ni,1] == aItePen[i,1]
							If nLin >= 60
								nLin := 1
								nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
								nLin++
								@ nLin++ , 52 psay cCabTot
								nLin++
							EndIf
							@ nLin++, 001 pSay space(20)+left(aItePen[i,2]+" - "+aItePen[i,3]+space(33),33)+" "+transform(aItePen[i,4],"@E 999,999.99")+"     "+transform(aItePen[i,5],"@E 999,999.99")
						Else
							j := i
							Exit
						Endif
					Next
				Endif
			Endif
		Endif
	Next
EndIf
nLin++
@ nLin++ , 00 psay Repl("-",80)



///////////////////////
//      COMPRAS      //
///////////////////////
nLin := 1
nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
nLin++
@ nLin++ , 00 psay Repl("*",66)
@ nLin++ , 00 psay STR0025 + STR0027
@ nLin++ , 00 psay STR0026 + Transform(nTotCom,"@E 999999,999.99")
@ nLin++ , 00 psay Repl("*",66)
nLin++
@ nLin++ , 52 psay STR0027
@ nLin++ , 00 psay STR0028 + Transform(nTotCpR,"@E 999,999,999.99")
aSort(aNumCpR,1,,{|x,y| x[1]+x[2] < y[1]+y[2]})
aSort(aIteCpR,1,,{|x,y| x[1]+x[2]+x[3]+x[4] < y[1]+y[2]+y[3]+y[4]})
If MV_PAR04 >= 2
	cMudou := "9"
	j := 1
	For ni:=1 to Len(aNumCpR)
		If nLin >= 60
			nLin := 1
			nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
			@ nLin++ , 52 psay STR0027
		EndIf
		If cMudou # aNumCpR[ni,1]
			If nLin >= 58
				nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
				@ nLin++ , 52 psay STR0027
			EndIf
			cMudou := aNumCpR[ni,1]
			nLin++
			nPos := aScan(aGrpCpR,{|x| x[1] == cMudou })
			@ nLin++ , 07 psay Alltrim(aGrpCpR[nPos,2]) + repl(".",44 - len(Alltrim(aGrpCpR[nPos,2]))) + " " + Transform(aGrpCpR[nPos,3],"@E 999999,999.99")
		EndIf
		If ((MV_PAR04 == 3) .and. (aNumCpR[ni,2] # "SO_PARA_ZERAR"))
			@ nLin++ , 10 psay aNumCpR[ni,2] + Repl(" ",7-len(aNumCpR[ni,2])) + left(aNumCpR[ni,3],34) + Repl(" ",34-len(aNumCpR[ni,3])) + " " + Transform(aNumCpR[ni,4],"@E 999999,999.99")
			if mv_par20 == "21"
				if mv_par04 == 3
					for i := j to Len(aItePen)
						if aNumCpR[ni,1]+aNumCpR[ni,2] == aIteCpR[i,1]+aIteCpR[i,2]
							If nLin >= 60
								nLin := 1
								nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
								@ nLin++ , 52 psay STR0027
							EndIf
							@ nLin++, 001 pSay space(20)+left(aIteCpR[i,3]+" - "+aIteCpR[i,4]+space(33),33)+" "+transform(aIteCpR[i,5],"@E 999,999.99")+"     "+transform(aIteCpR[i,6],"@E 999,999.99")
						Else
							j := i
							Exit
						Endif
					Next
				Endif
			Endif
		EndIf
	Next
EndIf

///////////////////////
//  OUTRAS  COMPRAS  //
///////////////////////
nLin++
@ nLin++ , 52 psay STR0027
@ nLin++ , 00 psay STR0029 + Transform(nTotCpO,"@E 999,999,999.99")
aSort(aNumCpO,1,,{|x,y| x[1] < y[1]})
aSort(aIteCpO,1,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3]})
j := 1
For ni:=1 to Len(aNumCpO)
	If nLin >= 60
		nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
		@ nLin++ , 52 psay STR0027
	EndIf
	If MV_PAR04 == 3
		@ nLin++ , 10 psay aNumCpO[ni,1] + Repl(" ",7-len(aNumCpO[ni,1])) + left(aNumCpO[ni,2],34) + Repl(" ",34-len(aNumCpO[ni,2])) + " " + Transform(aNumCpO[ni,3],"@E 999999,999.99")
		if mv_par04 == 3
			if mv_par20 == "22"
				for i := j to Len(aIteCpO)
					if aNumCpO[ni,1] == aIteCpO[i,1]
						If nLin >= 60
							nLin := 1
							nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
							@ nLin++ , 52 psay STR0027
						EndIf
						@ nLin++, 001 pSay space(20)+left(aIteCpO[i,2]+" - "+aIteCpO[i,3]+space(33),33)+" "+transform(aIteCpO[i,4],"@E 999,999.99")+"     "+transform(aIteCpO[i,5],"@E 999,999.99")
					Else
						j := i
						Exit
					Endif
				Next
			Endif
		Endif
	EndIf
Next


///////////////////////
// COMPRAS ESPECIFIC //
///////////////////////
nLin++
@ nLin++ , 52 psay STR0027
@ nLin++ , 00 psay STR0030 + Transform(nTotCpE,"@E 999,999,999.99")
aSort(aNumCpE,1,,{|x,y| x[1] < y[1]})
aSort(aIteCpE,1,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3]})
J := 1
For ni:=1 to Len(aNumCpE)
	If nLin >= 60
		nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
		@ nLin++ , 52 psay STR0027
	EndIf
	If MV_PAR04 == 3
		@ nLin++ , 10 psay aNumCpE[ni,1] + Repl(" ",7-len(aNumCpE[ni,1])) + left(aNumCpE[ni,2],34) + Repl(" ",34-len(aNumCpE[ni,2])) + " " + Transform(aNumCpE[ni,3],"@E 999999,999.99")
		if mv_par04 == 3
			if mv_par20 == "23"
				for i := j to Len(aIteCpE)
					if aNumCpE[ni,1] == aIteCpE[i,1]
						If nLin >= 60
							nLin := 1
							nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
							@ nLin++ , 52 psay STR0027
						EndIf
						@ nLin++, 001 pSay space(20)+left(aIteCpE[i,2]+" - "+aIteCpE[i,3]+space(33),33)+" "+transform(aIteCpE[i,4],"@E 999,999.99")+"     "+transform(aIteCpE[i,5],"@E 999,999.99")
					Else
						j := i
						Exit
					Endif
				Next
			Endif
		Endif
	EndIf
Next
nLin++
@ nLin++ , 00 psay Repl("-",80)


///////////////////////
//      VEICULOS     //
///////////////////////
nLin := 1
nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
nLin++
@ nLin++ , 00 psay Repl("*",37)
@ nLin++ , 00 psay STR0038
@ nLin++ , 00 psay STR0039
@ nLin++ , 00 psay Repl("*",37)
nLin++
@ nLin++ , 00 psay STR0032 + Transform(nTotPas,"@E 999999")
nLin++
@ nLin++ , 00 psay STR0031 + Transform(nTotVei,"@E 999999")
If MV_PAR04 >= 2
	aSort(aNumVei,1,,{|x,y| x[1] < y[1]})
	For ni:=1 to len(aNumVei)
		If nLin >= 60
			nLin := 1
			nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
			nLin++
		EndIf
		@ nLin++ , 05 psay left(aNumVei[ni,1],25) + Transform(aNumVei[ni,2],"@E 999999")
	Next
EndIf
nLin++
@ nLin++ , 00 psay Repl("-",80)
nLin++


///////////////////////
//ESTOQUE PEC/ACE/OUT//
///////////////////////

If MV_PAR13 == 2 .and. cEstoque == "SIM"
	If nLin >= 55
		nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
	EndIf
	nLin++
	@ nLin++ , 00 psay Repl("*",80)
	@ nLin++ , 00 psay STR0044
	@ nLin++ , 00 psay STR0045
	@ nLin++ , 00 psay Repl("*",80)
	If MV_PAR04 >= 2
		aSort(aNumEst,1,,{|x,y| x[1] < y[1]})
		For ni:=1 to len(aNumEst)
			If cMudou # substr(aNumEst[ni,1],1,1)
				If nLin >= 58
					nLin := 1
					nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
				EndIf
				cMudou := substr(aNumEst[ni,1],1,1)
				nLin++
				nPos := aScan(aGrpEst,{|x| x[1] == cMudou })
				@ nLin++ , 05 psay aGrpEst[nPos,2] + "    " + Transform(aGrpEst[nPos,3],"@R 9999999999") + "  " + Transform(aGrpEst[nPos,4],"@E 999999,999.99")
			EndIf
			If nLin >= 60
				nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
				nLin++
			EndIf
			@ nLin++ , 10 psay substr(aNumEst[ni,1],2,41) + "    " + Transform(aNumEst[ni,2],"@R 9999999999") + "  " + Transform(aNumEst[ni,3],"@E 999999,999.99")
		Next
	EndIf
	nLin++  // Originais
	@ nLin++ , 05 psay STR0046 + "(" + Transform(dDatOri,"@D") + ")...............     " + Transform(aTotOri[1,1],"@R 9999999999") + "  " + Transform(aTotOri[1,2],"@E 999999,999.99")
	If MV_PAR04 >= 2
		aSort(aPecOri,1,,{|x,y| x[1] < y[1]})
		For ni:=1 to len(aPecOri)
			If nLin >= 60
				nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
				nLin++
			EndIf
			@ nLin++ , 10 psay left(aPecOri[ni,1],39) + "     " + Transform(aPecOri[ni,2],"@R 9999999999")  + "  " + Transform(aPecOri[ni,3],"@E 999999,999.99")
		Next
	EndIf
	nLin++  // Nao Originais
	@ nLin++ , 05 psay STR0046 + "(" + Transform(dDatOri,"@D") + ")...............     " + Transform(aTotNOri[1,1],"@R 9999999999") + "  " + Transform(aTotNOri[1,2],"@E 999999,999.99")
	If MV_PAR04 >= 2
		aSort(aPecNOri,1,,{|x,y| x[1] < y[1]})
		For ni:=1 to len(aPecOri)
			If nLin >= 60
				nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
				nLin++
			EndIf
			@ nLin++ , 10 psay left(aPecNOri[ni,1],39) + "     " + Transform(aPecNOri[ni,2],"@R 9999999999")  + "  " + Transform(aPecNOri[ni,3],"@E 999999,999.99")
		Next
	EndIf
	nLin++
	@ nLin++ , 00 psay Repl("-",80)
	nLin++
EndIf
If nLin >= 55
	nLin := 1
	nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
	nLin++
EndIf

///////////////////////
// TRANSFERENCIA E/S //
///////////////////////
nLin++
@ nLin++ , 00 psay Repl("*",80)
@ nLin++ , 00 psay STR0040
@ nLin++ , 00 psay STR0041 + Transform(aGrpTransf[1,3],"@E 999999,999.99") + "  " + Transform(aGrpTransf[1,4],"@E 999999,999.99")
@ nLin++ , 00 psay Repl("*",80)
cMudou := "9"
If MV_PAR04 >= 2
	nLin++
	If len(aNumTransf) == 0
		@ nLin++ , 05 psay aGrpTransf[2,2] + "  " + Transform(aGrpTransf[2,3],"@E 999999,999.99") + "  " + Transform(aGrpTransf[2,4],"@E 999999,999.99")
		@ nLin++ , 05 psay aGrpTransf[3,2] + "  " + Transform(aGrpTransf[3,3],"@E 999999,999.99") + "  " + Transform(aGrpTransf[3,4],"@E 999999,999.99")
	Else
		aSort(aNumTransf,1,,{|x,y| x[1]+x[2] < y[1]+y[2]})
		For ni:=1 to len(aNumTransf)
			If nLin >= 60
				nLin := 1
				nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
				nLin++
			EndIf
			If cMudou # aNumTransf[ni,1]
				cMudou := aNumTransf[ni,1]
				nLin++
				nPos := aScan(aGrpTransf,{|x| x[1] == cMudou })
				@ nLin++ , 05 psay aGrpTransf[nPos,2] + "  " + Transform(aGrpTransf[nPos,3],"@E 999999,999.99") + "  " + Transform(aGrpTransf[nPos,4],"@E 999999,999.99")
			EndIf
			If MV_PAR04 == 3
				@ nLin++ , 10 psay aNumTransf[ni,2] + "  " + left(aNumTransf[ni,3],30) + "     " + Transform(aNumTransf[ni,4],"@E 999999,999.99") + "  " + Transform(aNumTransf[ni,5],"@E 999999,999.99")
			EndIf
		Next
	EndIf
EndIf
nLin++
@ nLin++ , 00 psay Repl("-",80)
nLin++
For ni:=nCont to 13
	IncRegua()
Next

FS_GRPPA( aGrpPec[1] , aGrpPec[2]   , aGrpPec[3]   , aGrpPec[4]   , aGrpPec[5] ,;
aGrpPec[6] , aTotBpc[1]   , aGrpPec[7]   , aGrpPec[8]   , aGrpPec[9] ,;
aGrpPec[10], aGrpPec[11]  , aGrpPec[12]  , aTotAce[1]   , aTotLub[1] ,;
aTotal[1]  , aGrpCpr[1,3] , aGrpCpr[2,3] , aGrpCpr[3,3] , nTotCpr    ,;
nTotCpo    , nTotCpE      , nTotPas      , nTotVei  )

DbSelectArea( "SX1" )
DbSetOrder(1)
If DbSeek( "OFR291", .t. )
	nLin++
	If nLin >= 58
		nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
	EndIf
	@ nLin++ , 00 psay STR0049
	nLin++
	While Alltrim(X1_GRUPO) == "OFR291" .and. !eof()
		nLin++
		If nLin >= 58
			nLin := 1
			nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
		EndIf
		@ nLin++ , 00 psay X1_PERGUNTE + " " + X1_CNT01
		DbSkip()
	EndDo
EndIf

Ms_Flush()

Set	Printer to
Set Device  to Screen

If Select(cAliasVEC) > 0
	( cAliasVEC )->( DbCloseArea() )
EndIf
If Select(cAliasSBM) > 0
	( cAliasSBM )->( DbCloseArea() )
EndIf
If Select(cAliasVE4) > 0
	( cAliasVE4 )->( DbCloseArea() )
EndIf
If Select(cAliasSB1) > 0
	( cAliasSB1 )->( DbCloseArea() )
EndIf
If Select(cAliasSF2) > 0
	( cAliasSF2 )->( DbCloseArea() )
EndIf
If Select(cAliasSD2) > 0
	( cAliasSD2 )->( DbCloseArea() )
EndIf
If Select(cAliasSF4) > 0
	( cAliasSF4 )->( DbCloseArea() )
EndIf
If Select(cAliasSA1) > 0
	( cAliasSA1 )->( DbCloseArea() )
EndIf
If Select(cAliasVO3) > 0
	( cAliasVO3 )->( DbCloseArea() )
EndIf
If Select(cAliasSB2) > 0
	( cAliasSB2 )->( DbCloseArea() )
EndIf
If Select(cAliasSD1) > 0
	( cAliasSD1 )->( DbCloseArea() )
EndIf
If Select(cAliasSA2) > 0
	( cAliasSA2 )->( DbCloseArea() )
EndIf
If Select(cAliasVV0) > 0
	( cAliasVV0 )->( DbCloseArea() )
EndIf
If Select(cAliasVV1) > 0
	( cAliasVV1 )->( DbCloseArea() )
EndIf
If Select(cAliasSF1) > 0
	( cAliasSF1 )->( DbCloseArea() )
EndIf
If Select(cAliasVOO) > 0
	( cAliasVOO )->( DbCloseArea() )
EndIf
If Select(cAliasVOI) > 0
	( cAliasVOI )->( DbCloseArea() )
EndIf        

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³VALIDPERG º Autor ³ Thiago		     º Data ³  30/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Verifica a existencia das perguntas criando-as caso seja   º±±
±±º          ³ necessario (caso nao existam).                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValidPerg(cPerg)

Local _sAlias := ""
Local aRegs := {}
Local i,j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))

aAdd(aRegs,{cPerg,"01",STR0062,"","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"02",STR0063,"","","mv_ch2","D",08,0,0,"G","FS_VALR290(MV_PAR01,MV_PAR02)","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"03",STR0064,"","","mv_ch3","N",01,0,0,"C","","mv_par03",STR0081,"","","","",STR0082,"","","","",STR0083,"","","","",STR0084,"","","","",STR0085,"","","","",""})
Aadd(aRegs,{cPerg,"04",STR0065,"","","mv_ch4","N",01,0,0,"C","","mv_par04",STR0086,"","","","",STR0087,"","","","",STR0088,"","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"05",STR0066,"","","mv_ch5","N",01,0,0,"C","","mv_par05",STR0089,"","","","",STR0090,"","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"06",STR0067,"","","mv_ch6","C",34,0,0,"G","FS_VALSX5T3()","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"07",STR0068,"","","mv_ch7","C",34,0,0,"G","FS_VALSX5T3()","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"08",STR0069,"","","mv_ch8","C",34,0,0,"G","FS_VALSX5T3()","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"09",STR0070,"","","mv_ch9","C",34,0,0,"G","FS_VALSX5T3()","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"10",STR0071,"","","mv_cha","C",34,0,0,"G","FS_VALSX5T3()","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"11",STR0072,"","","mv_chb","C",34,0,0,"G","FS_VALSX5T3()","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"12",STR0073,"","","mv_chc","C",34,0,0,"G","FS_VALSX5T3()","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"13",STR0074,"","","mv_chd","N",01,0,0,"C","","mv_par13",STR0091,"","","","",STR0092,"","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"14",STR0075,"","","mv_che","D",08,0,0,"G","","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"15",STR0076,"","","mv_chf","C",06,0,0,"G",'Vazio() .or. FG_SEEK("VEG","MV_PAR15",1,.F.)',"mv_par15","","","","","","","","","","","","","","","","","","","","","","","","","VEG",""})
Aadd(aRegs,{cPerg,"16",STR0077,"","","mv_chg","N",01,0,2,"C","","mv_par16",STR0093,"","","","",STR0094,"","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"17",STR0078,"","","mv_chh","C",03,0,0,"G",'EMPTY(MV_PAR17) .OR. FG_VALIDA(,"VE1TMV_PAR17*")',"mv_par17","","","","","","","","","","","","","","","","","","","","","","","","","VE1",""})
Aadd(aRegs,{cPerg,"18",STR0079,"","","mv_chi","C",02,0,0,"G","","mv_par18","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"19",STR0080,"","","mv_chj","C",02,0,0,"G","","mv_par19","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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

if Empty(_sAlias)
	_sAlias := alias()
Endif
dbSelectArea(_sAlias)

Return
