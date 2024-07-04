// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 3      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#Include "OFIRMF01.CH"
		
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFIRMF01   | Autor | Thiago                | Data | 01/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Relatorio de controle de garantia - Massey Ferguson          |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIRMF01()

Local aButton := {}
Local aSay := {}
Local cDesc1 := STR0001
Private cNomRel := "OFIRMF01"
Private cTitulo := STR0001
Private aIntCab := {} // Cabeçalhos da função FGX_VISINT
Private cPerg   := "OFMF01"
Private aIntIte := {} // Itens da função FGX_VISINT
Private cAliasVG8 := "SQLVG8"
aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)


CriaSX1()
aAdd( aSay, cDesc1 ) // Um para cada cDescN
nOpc := 0
aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )

//
FormBatch( cTitulo, aSay, aButton )
Pergunte(cPerg,.f.)

RptStatus( {|lEnd| GeraRel(@lEnd)},"",STR0002)
//

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | GeraRel    | Autor | Thiago                | Data | 01/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Gera relatorio.									            |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function GeraRel()

aAdd(aIntCab,{STR0003,"C",28,"@!"})					//01 - Nro R.O.s
aAdd(aIntCab,{STR0004,"C",30,"@!"})					//02 - Data NF
aAdd(aIntCab,{STR0005,"C",34,"@!"})					//03 - Numero NF
aAdd(aIntCab,{STR0035,"C",3,"@!"})					//04 - Serie NF
aAdd(aIntCab,{STR0006,"C",40,"@!"})					//05 - Descricao Filial
aAdd(aIntCab,{STR0007,"N",60,"@E 9,999,999.99"})	//06 - Valor TOTAL
aAdd(aIntCab,{STR0008,"N",50,"@E 999,999.99"})		//07 - Peças + Adicional Peças
aAdd(aIntCab,{STR0009,"N",50,"@E 999,999.99"})		//08 - Mão de Obra (Serviço)
aAdd(aIntCab,{STR0010,"C",40,"@!"})					//09 - Dta NF Credito
aAdd(aIntCab,{STR0011,"C",40,"@!"})					//10 - Nro NF Credito
aAdd(aIntCab,{STR0036,"C",3,"@!"})					//11 - Serie NF Crd
aAdd(aIntCab,{STR0012,"N",50,"@E 999,999.99"})		//12 - Peças NF Credito
aAdd(aIntCab,{STR0013,"N",50,"@E 999,999.99"})		//13 - Ad Peças NF Cred
aAdd(aIntCab,{STR0014,"N",50,"@E 999,999.99"})		//14 - M.O. NF Cred
aAdd(aIntCab,{STR0015,"N",50,"@E 999,999.99"})		//15 - S. Terc. NF Cred
aAdd(aIntCab,{STR0016,"N",50,"@E 99,999.99"})		//16 - Desloc. NF Cred (KM SOCORRO)
aAdd(aIntCab,{STR0017,"N",50,"@E 999,999.99"})		//17 - Total NF Cred
aAdd(aIntCab,{STR0018,"N",50,"@E 999,999.99"})		//18 - Peças Variação
aAdd(aIntCab,{STR0019,"N",50,"@E 999,999.99"})		//19 - AD Peças Variação
aAdd(aIntCab,{STR0020,"N",50,"@E 999,999.99"})		//20 - M.O. Variação
aAdd(aIntCab,{STR0021,"N",50,"@E 99,999.99"})		//21 - S. Terc. Variação
aAdd(aIntCab,{STR0022,"N",50,"@E 999,999.99"})		//22 - Desloc. Variação
aAdd(aIntCab,{STR0023,"N",50,"@E 999,999.99"})		//23 - Total Variação
aAdd(aIntCab,{STR0024,"N",50,"@E 999,999.99"})		//24 - Saldo em aberto Variação

cQuery := "SELECT VGG.VGG_NUMRO,VG8.VG8_DATNFI,VG8.VG8_SERNFI,VG8.VG8_DATCRE,VG8.VG8_NFCRED,VG8.VG8_SERNFC,VG8.VG8_VALITE,VG8.VG8_NUMNFI,"
cQuery += "VG8.VG8_VALSER,VGG.VGG_VLPECC,VGG.VGG_VRAPCC,VGG.VGG_VLMOCC,VGG.VGG_VRSETC,VGG.VGG_VKMCAC,VG8.VG8_VLRAPC,VGG.VGG_VLMOCC,VGG.VGG_VRSETC,"
cQuery += "VG8.VG8_VLRSET,VG8.VG8_VLKMCA "
cQuery += "FROM "
cQuery += RetSqlName( "VG8" ) + " VG8 "
cQuery += "INNER JOIN "+RetSQLName("VGG")+" VGG ON  VGG.VGG_FILIAL  = '"+xFilial("VGG")+"' AND VGG.VGG_NUMOSV = VG8.VG8_NUMOSV AND VGG.VGG_NUMRO >= '"+mv_par03+"' AND VGG.VGG_NUMRO <= '"+mv_par04+"' AND VGG.D_E_L_E_T_=' ' "
cQuery += "WHERE "
cQuery += "VG8.VG8_FILIAL='"+ xFilial("VG8")+ "' AND VG8.VG8_ABEGAR >= '"+dtos(mv_par01)+"' AND VG8.VG8_ABEGAR <= '"+dtos(mv_par02)+"' AND "
cQuery += "VG8.D_E_L_E_T_=' '"

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVG8, .T., .T. )

Do While !( cAliasVG8 )->( Eof() )
	
	nTOTVAL  := (( cAliasVG8 )->VG8_VALITE+( cAliasVG8 )->VG8_VLRAPC)+( cAliasVG8 )->VG8_VALSER+( cAliasVG8 )->VG8_VLKMCA+( cAliasVG8 )->VG8_VLRSET
	nTOTNCRE := ( cAliasVG8 )->VGG_VLPECC+( cAliasVG8 )->VGG_VRAPCC+( cAliasVG8 )->VGG_VLMOCC+( cAliasVG8 )->VGG_VKMCAC+( cAliasVG8 )->VGG_VRSETC
	if !Empty(( cAliasVG8 )->VG8_NFCRED)
		nPecas   := ( cAliasVG8 )->VGG_VLPECC-( cAliasVG8 )->VG8_VALITE
		nADPecas := ( cAliasVG8 )->VGG_VRAPCC-( cAliasVG8 )->VG8_VLRAPC
		nMO      := ( cAliasVG8 )->VGG_VLMOCC-( cAliasVG8 )->VG8_VALSER
		nSTerc   := ( cAliasVG8 )->VGG_VRSETC-( cAliasVG8 )->VG8_VLRSET
		nDesloc	 := ( cAliasVG8 )->VGG_VKMCAC-( cAliasVG8 )->VG8_VLKMCA
		nTotal   := nTOTVAL - nTOTNCRE
	Else
		nPecas   := 0
		nADPecas := 0
		nMO      := 0
		nSTerc   := 0
		nDesloc	 := 0
		nTotal   := 0
	Endif
	if nTOTNCRE == 0
		nSalAber := nTOTVAL
	Else
		nSalAber := 0
	Endif
	if mv_par05 == 2
		if nSalAber == 0
			dbSelectArea(cAliasVG8)
			( cAliasVG8 )->(dbSkip())
			Loop
		Endif
	Endif
	if mv_par05 == 3
		if nSalAber <> 0
			dbSelectArea(cAliasVG8)
			( cAliasVG8 )->(dbSkip())
			Loop
		Endif
	Endif
	cDia    := strzero(day(stod(( cAliasVG8 )->VG8_DATNFI)),2)
	cMes    := strzero(month(stod(( cAliasVG8 )->VG8_DATNFI)),2)
	cAno    := strzero(year(stod(( cAliasVG8 )->VG8_DATNFI)),4)
	cDtaNF  := cDia+"/"+cMes+"/"+cAno
	if cDia == "00"
		cDtaNF := ""
	Endif
	
	cDia    := strzero(day(stod(( cAliasVG8 )->VG8_DATCRE)),2)
	cMes    := strzero(month(stod(( cAliasVG8 )->VG8_DATCRE)),2)
	cAno    := strzero(year(stod(( cAliasVG8 )->VG8_DATCRE)),4)
	cDtaCre := cDia+"/"+cMes+"/"+cAno
	if cDia == "00"
		cDtaCre := ""
	Endif
	
	aAdd(aIntIte,{( cAliasVG8 )->VGG_NUMRO,;
	cDtaNF,;
	( cAliasVG8 )->VG8_NUMNFI,;
	( cAliasVG8 )->VG8_SERNFI,;
	PADR(aSM0[7],7),;
	nTOTVAL,;
	(( cAliasVG8 )->VG8_VALITE+( cAliasVG8 )->VG8_VLRAPC),;
	( cAliasVG8 )->VG8_VALSER,;
	cDtaCre,;
	( cAliasVG8 )->VG8_NFCRED,;
	( cAliasVG8 )->VG8_SERNFC,;
	( cAliasVG8 )->VGG_VLPECC,;
	( cAliasVG8 )->VGG_VRAPCC,;
	( cAliasVG8 )->VGG_VLMOCC,;
	( cAliasVG8 )->VGG_VRSETC,;
	( cAliasVG8 )->VGG_VKMCAC,;
	nTOTNCRE,;
	nPecas,;
	nADPecas,;
	nMO,;
	nSTerc,;
	nDesloc,;
	nTotal,;
	nSalAber})
	
	
	dbSelectArea(cAliasVG8)
	( cAliasVG8 )->(dbSkip())
	
Enddo
( cAliasVG8 )->( dbCloseArea() )
if Len(aIntIte) == 0
	MsgInfo(STR0025)
	Return(.f.)
Endif

FGX_VISINT(cNomRel , cTitulo , aIntCab , aIntIte , .t. )

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | CriaSX1    | Autor |  Thiago		          | Data | 12/04/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Cria perguntes.									            |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function CriaSX1()
Local aSX1    := {}
Local aEstrut := {}
Local i       := 0
Local j       := 0
Local lSX1	  := .F.

if cPerg == ""
	return
endif

aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME" ,"X1_GRPSXG" ,"X1_HELP","X1_PICTURE"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aAdd a Pergunta                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// TODO
aAdd(aSX1,{cPerg,"01",STR0026,"","","MV_CH1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"02",STR0027,"","","MV_CH2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"03",STR0028,"","","MV_CH3","C",7,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","VG5",""	,"S","","",""})
aAdd(aSX1,{cPerg,"04",STR0029,"","","MV_CH4","C",7,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","VG5",""	,"S","","",""})
aAdd(aSX1,{cPerg,"05",STR0030,"","","MV_CH5","N",1,0,0,"C","","mv_par05",STR0031,"","","","",STR0032,"","","","",STR0033,"","","","","","","","","","","","","","",""	,"S","","","9"})

ProcRegua(Len(aSX1))

dbSelectArea("SX1")
dbSetOrder(1)
For i:= 1 To Len(aSX1)
	If !Empty(aSX1[i][1])
		If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
			IncProc(STR0034)
			lSX1 := .T.
			RecLock("SX1",.T.)
			For j:=1 To Len(aSX1[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
				EndIf
			Next j
			dbCommit()
			MsUnLock()
		EndIf
	EndIf
Next i

return
