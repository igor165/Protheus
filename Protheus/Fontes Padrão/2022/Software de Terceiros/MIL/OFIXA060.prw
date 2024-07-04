#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFIXA060.CH"

#define STR0004 "Meses para Classificação"
#define STR0005 "Popularidade para Class. A"
#define STR0006 "Popularidade para Class. B"
#define STR0007 "Popularidade para Class. C"
#define STR0008 "Deseja processar a classificação de todo o cadastro de peças?"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFIXA060   | Autor | Luis Delorme          | Data | 19/08/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Programa de Levantamento DIA Peças                           |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXA060()
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002
Local cDesc3  := STR0003
Local nOpc := 0
Local aSay := {}
Local aButton := {} 

Local cPerg 	:= "OXA060"

Private cTitulo := STR0010
Private cNomRel := "OFIXA060"

//
// AADD(aRegs,{'Data Reunião Comitê'      ,,,'MV_CH1','D',08,0,,'G',''          ,'MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{'Informe a data de reunião do Comitê.'},{'Informe a data de reunião do Comitê.'},{'Informe a data de reunião do Comitê.'}})
// AADD(aRegs,{'Limite Inferior'          ,,,'MV_CH2','N',05,2,,'G','Positivo()','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@E 99.99',{"Informe o percentual de limite inferior","para analise das diferenças."},{"Informe o percentual de limite inferior","para analise das diferenças."},{"Informe o percentual de limite inferior","para analise das diferenças."}})
// AADD(aRegs,{'Limite Superior'          ,,,'MV_CH3','N',05,2,,'G','Positivo()','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@E 99.99',{"Informe o percentual de limite superior","para analise das diferenças."},{"Informe o percentual de limite superior","para analise das diferenças."},{"Informe o percentual de limite superior","para analise das diferenças."}})
// AADD(aRegs,{'Classif. A - Popularidade',,,'MV_CH4','N',04,0,,'G','Positivo()','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@E 9,999',{"Popularidade para classificação dos ","itens A."},{"Popularidade para classificação dos ","itens A."},{"Popularidade para classificação dos ","itens A."}})
// AADD(aRegs,{'Classif. A2 - Custo'      ,,,'MV_CH6','N',14,2,,'G','Positivo()','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@E 99,999,999,999.99',{"Informe valor máximo de custo para sub-classificação 2.","Peças com custo acima do valor informado","será sub-classificado como 1."},{"Informe valor máximo de custo para sub-classificação 2.","Peças com custo acima do valor informado","será sub-classificado como 1."},{"Informe valor máximo de custo para sub-classificação 2.","Peças com custo acima do valor informado","será sub-classificado como 1."}})
// AADD(aRegs,{'Classif. A3 - Custo'      ,,,'MV_CH7','N',14,2,,'G','Positivo()','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@E 99,999,999,999.99',{"Informe valor máximo de custo para sub-classificação 3."},{"Informe valor máximo de custo para sub-classificação 3."},{"Informe valor máximo de custo para sub-classificação 3."}})
// AADD(aRegs,{'Classif. B - Popularidade',,,'MV_CH8','N',03,0,,'G','Positivo()','MV_PAR08','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@E 9,999',{"Popularidade para classificação dos ","itens B."},{"Popularidade para classificação dos ","itens B."},{"Popularidade para classificação dos ","itens B."}})
// AADD(aRegs,{'Classif. B2 - Custo'      ,,,'MV_CHA','N',14,2,,'G','Positivo()','MV_PAR10','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@E 99,999,999,999.99',{"Informe valor máximo de custo para sub-classificação 2.","Peças com custo acima do valor informado","será sub-classificado como 1."},{"Informe valor máximo de custo para sub-classificação 2.","Peças com custo acima do valor informado","será sub-classificado como 1."},{"Informe valor máximo de custo para sub-classificação 2.","Peças com custo acima do valor informado","será sub-classificado como 1."}})
// AADD(aRegs,{'Classif. B3 - Custo'      ,,,'MV_CHB','N',14,2,,'G','Positivo()','MV_PAR11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@E 99,999,999,999.99',{"Informe valor máximo de custo para sub-classificação 3."},{"Informe valor máximo de custo para sub-classificação 3."},{"Informe valor máximo de custo para sub-classificação 3."}})
// AADD(aRegs,{'Classif. C - Popularidade',,,'MV_CHC','N',03,0,,'G','Positivo()','MV_PAR12','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@E 9,999',{"Popularidade para classificação dos ","itens C."},{"Popularidade para classificação dos ","itens C."},{"Popularidade para classificação dos ","itens C."}})
// AADD(aRegs,{'Classif. C2 - Custo'      ,,,'MV_CHE','N',14,2,,'G','Positivo()','MV_PAR14','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@E 99,999,999,999.99',{"Informe valor máximo de custo para sub-classificação 2.","Peças com custo acima do valor informado","será sub-classificado como 1."},{"Informe valor máximo de custo para sub-classificação 2.","Peças com custo acima do valor informado","será sub-classificado como 1."},{"Informe valor máximo de custo para sub-classificação 2.","Peças com custo acima do valor informado","será sub-classificado como 1."}})
// AADD(aRegs,{'Classif. C3 - Custo'      ,,,'MV_CHF','N',14,2,,'G','Positivo()','MV_PAR15','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@E 99,999,999,999.99',{"Informe valor máximo de custo para sub-classificação 3."},{"Informe valor máximo de custo para sub-classificação 3."},{"Informe valor máximo de custo para sub-classificação 3."}})
//
Pergunte(cPerg,.f. )
//
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
//
aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
//
FormBatch( cTitulo, aSay, aButton )
//
If nOpc <> 1
	Return
Endif
//#############################################################################
//# Chama a rotina de exportação                                              #
//#############################################################################
RptStatus( {|lEnd| RunProc(@lEnd)}, STR0011,STR0012, .T. )
//
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | RunProc    | Autor | Luis Delorme          | Data | 16/08/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Calcula indices DIA PECAS                                    |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function RunProc(lEnd)
//

// 
if !MsgYesNo(STR0008)
	return .f.
endif

// Verifica se ja existe registro criado, e se houver, pergunta se deseja reprocessar ...
If !OXA060REPROC()
	Return .f.
EndIf
//

Private nPerConfig := GetNewPar("MV_MILXXXX" , 3 )

OXA060PROC()

MsgInfo(STR0009)

Return

Static Function OXA060REPROC()

	Local cSQL
	Local nRecVQU

	cSQL := "SELECT R_E_C_N_O_ RECNOVQU FROM " + RetSQLName("VQU") + " VQU WHERE VQU_FILIAL = '" + xFilial("VQU") + "' AND VQU_DATA = '" + DtoS(MV_PAR01) + "' AND D_E_L_E_T_ = ' '"
	nRecVQU := FM_SQL(cSQL)
	If nRecVQU == 0
		Return .t.
	EndIf

	If !MsgNoYes("Já existe levantamento para a data de reunião informada. Deseja excluir e reprocessar o levantamento ?")
		Return .f.
	EndIf

	Begin Transaction

	VQU->(dbGoTo(nRecVQU))

	dbSelectArea("VQV")
	VQV->(dbSetOrder(1))
	VQV->(dbSeek(xFilial("VQV") + VQU->VQU_CODIGO))
	While !VQV->(Eof()) .and. VQV->VQV_FILIAL == xFilial("VQV") .and. VQV->VQV_CODIGO == VQU->VQU_CODIGO
		RecLock("VQV",.F.,.T.)
		dbDelete()
		MsUnlock()
		VQV->(dbSkip())
	End

	dbSelectArea("VQU")
	RecLock("VQU",.F.,.T.)
	dbDelete()
	MsUnlock()

	End Transaction

Return .t.


Static Function OXA060PROC()

Local cQuery
Local cAliasProc := "TPROC"
Local cBkpFilAnt := cFilAnt
Local cAnoAtual, cMesAtual
Local cAnoPer1, cMesPer1
Local cAnoPer2, cMesPer2
Local cAnoIni, cMesIni
Local dDataIni := Date()
Local dDataFim := Date()
Local oFilial := DMS_FilialHelper():New()
Local nCont
Local nPopularidade
Local cQueryDemanda := ""
Local oSQLHelper := DMS_SQLHelper():New()
Local oPecaDia := DMS_PecaDia():New()
Local nPos

//dDataIni := dDataFim := CtoD("30/03/2016")
//dDataIni := dDataFim := CtoD("30/04/2016")
//Alert("Fixando data para " + DtoC(dDataIni))

dDtReun := MV_PAR01
nLimInf := MV_PAR02
nLimSup := MV_PAR03
nPopA   := MV_PAR04
nCusA2  := MV_PAR05
nCusA3  := MV_PAR06
nPopB   := MV_PAR07
nCusB2  := MV_PAR08
nCusB3  := MV_PAR09
nPopC   := MV_PAR10
nCusC2  := MV_PAR11
nCusC3  := MV_PAR12

cAnoAtual := StrZero(Year(dDataIni),4)
cMesAtual := StrZero(Month(dDataIni),2)

dDataIni := MonthSub(dDataIni,1)

dAuxData := MonthSub(dDataIni,nPerConfig)
cAnoPer1 := StrZero(Year(dAuxData),4)
cMesPer1 := StrZero(Month(dAuxData),2)

dAuxData := MonthSub(dDataIni,6)
cAnoPer2 := StrZero(Year(dAuxData),4)
cMesPer2 := StrZero(Month(dAuxData),2)

//dAuxData := MonthSub(dDataIni,11)
cAnoIni := StrZero(Year(dAuxData),4)
cMesIni := StrZero(Month(dAuxData),2)

aFilProc := oFilial:GetAllFilGrupoEmpresa()

nAuxAno := Year(dDataIni)
nAuxMes := Month(dDataIni)
For nCont := 0 to 11
	cQueryDemanda += ", SUM(CASE WHEN VB8_ANO = '" + StrZero(nAuxAno,4) + "' AND VB8_MES = '" + StrZero(nAuxMes,2) + "' THEN VB8.VB8_VDAB + VB8.VB8_VDAO ELSE 0 END) DEM_" + StrZero(nCont+1,2)
	If nAuxMes == 1 
		nAuxMes := 12
		nAuxAno--
	Else
		nAuxMes--
	EndIf
Next nCont
cAnoIni := StrZero(nAuxAno,4)
cMesIni	:= StrZero(nAuxMes,2)

For nCont := 1 to Len(aFilProc)
	cFilAnt := aFilProc[nCont]
	
//	cQuery := "SELECT VB8.VB8_FILIAL, VB8.VB8_PRODUT" +;
//				", SUM(VB8.VB8_HITSB + VB8.VB8_HITSO) POPULARIDADE" +;
//				", SUM(CASE WHEN VB8_ANO >= '" + cAnoPer1 + "' AND VB8_MES >= '" + cMesPer1 + "' THEN VB8.VB8_VDAB + VB8.VB8_VDAO ELSE 0 END) DEMANDA1" +;
//				", SUM(CASE WHEN VB8_ANO >= '" + cAnoPer2 + "' AND VB8_MES >= '" + cMesPer2 + "' THEN VB8.VB8_VDAB + VB8.VB8_VDAO ELSE 0 END) DEMANDA2" +;
//				", SUM(VB8.VB8_VDAB + VB8.VB8_VDAO) DEMANDA3" +;3
//				", SUM(CASE WHEN VB8_ANO >= '" + cAnoPer1 + "' AND VB8_MES >= '" + cMesPer1 + "' THEN VB8.VB8_VDPERB + VB8.VB8_VDPERO ELSE 0 END) VPERDIDA1" +;
//				", SUM(CASE WHEN VB8_ANO >= '" + cAnoPer2 + "' AND VB8_MES >= '" + cMesPer2 + "' THEN VB8.VB8_VDPERB + VB8.VB8_VDPERO ELSE 0 END) VPERDIDA2" +;
//				", SUM(VB8.VB8_VDPERB + VB8.VB8_VDPERO) VPERDIDA3" +;
//				cQueryDemanda +;
//				", B1.B1_GRUPO, B1.B1_CODITE " +;
//				", B2.B2_CM1 CUSTO" +;
//				" FROM " + RetSQLName("VB8") + " VB8 " +;
//						" JOIN " + RetSQLName("SB1") + " B1 ON B1.B1_FILIAL = '" + xFilial("SB1") + "' AND B1.B1_COD = VB8.VB8_PRODUT AND B1.D_E_L_E_T_ = ' ' " +;
//						" LEFT JOIN " + RetSQLName("SB2") + " B2 ON B2.B2_FILIAL = '" + xFilial("SB2") + "' AND B2.B2_COD = B1.B1_COD AND B2.B2_LOCAL = B1.B1_LOCPAD AND B2.D_E_L_E_T_ = ' ' "+;
//				" WHERE VB8.VB8_FILIAL = '" + xFilial("VB8") + "' " +;
//  					" AND ( ( VB8.VB8_ANO = '" + cAnoIni   + "' AND VB8.VB8_MES > '" + cMesIni   + "' ) " +;
//					        " OR " +;
//					       "( VB8.VB8_ANO = '" + cAnoAtual + "' AND VB8.VB8_MES < '" + cMesAtual + "' ))" +;
//					" AND VB8.D_E_L_E_T_ = ' '" +;
//				" GROUP BY  VB8.VB8_FILIAL, VB8.VB8_PRODUT, B1.B1_GRUPO, B1.B1_CODITE, B2.B2_CM1"
//				", SUM(VB8.VB8_HITSB + VB8.VB8_HITSO) POPULARIDADE" +;
	cQuery := ;
		"SELECT TMPVB8.* , TMPVENDA.VDAMESANT " +;
			", POPULARIDADE" +;
			", B1.B1_COD, B1.B1_GRUPO, B1.B1_CODITE " +;
			", B2.B2_LOCAL, B2.B2_CM1 CUSTO" +;
			", COALESCE(BZ.BZ_EMAX, B1.B1_EMAX) ESTQMAX" +;
			", (BZ.BZ_DIAESTS + COALESCE(BZ.BZ_PRZPED, B1.B1_PRZPED) + BZ.BZ_PE) INDICE" +;
			", 0 PEDCOMPRA" +;
			", B2_QATU ESTOQUE " +;
		" FROM " +;
			"( SELECT VB8.VB8_FILIAL, VB8.VB8_PRODUT" +;
				", SUM(CASE WHEN " + oSQLHelper:Concat( { "VB8.VB8_ANO" , "VB8.VB8_MES" }) + " >= '" + cAnoPer1 + cMesPer1 + "' THEN VB8.VB8_VDAB + VB8.VB8_VDAO ELSE 0 END) DEMANDA1" +;
				", SUM(CASE WHEN " + oSQLHelper:Concat( { "VB8.VB8_ANO" , "VB8.VB8_MES" }) + " >= '" + cAnoPer2 + cMesPer2 + "' THEN VB8.VB8_VDAB + VB8.VB8_VDAO ELSE 0 END) DEMANDA2" +;
				", SUM(VB8.VB8_VDAB + VB8.VB8_VDAO) DEMANDA3" +;
				", SUM(CASE WHEN " + oSQLHelper:Concat( { "VB8.VB8_ANO" , "VB8.VB8_MES" }) + " >= '" + cAnoPer1 + cMesPer1 + "' THEN VB8.VB8_VDPERB + VB8.VB8_VDPERO ELSE 0 END) VPERDIDA1" +;
				", SUM(CASE WHEN " + oSQLHelper:Concat( { "VB8.VB8_ANO" , "VB8.VB8_MES" }) + " >= '" + cAnoPer2 + cMesPer2 + "' THEN VB8.VB8_VDPERB + VB8.VB8_VDPERO ELSE 0 END) VPERDIDA2" +;
				", SUM(VB8.VB8_VDPERB + VB8.VB8_VDPERO) VPERDIDA3" +;
				cQueryDemanda +;
			" FROM " + RetSQLName("VB8") + " VB8 " +;
			" WHERE VB8.VB8_FILIAL = '" + xFilial("VB8") + "' " +;
				" AND " + oSQLHelper:Concat( { "VB8.VB8_ANO" , "VB8.VB8_MES" }) + " > '" + cAnoIni + cMesIni     + "' " +;
				" AND " + oSQLHelper:Concat( { "VB8.VB8_ANO" , "VB8.VB8_MES" }) + " < '" + cAnoAtual + cMesAtual + "' " +;
				" AND VB8.D_E_L_E_T_ = ' '" +;
			" GROUP BY VB8.VB8_FILIAL, VB8.VB8_PRODUT" +; // , B1.B1_GRUPO, B1.B1_CODITE, B2.B2_CM1, BZ.BZ_EMAX, B1.B1_EMAX " +;
			") TMPVB8 " +;
		" FULL JOIN " +;
			"( SELECT VB8.VB8_PRODUT , SUM(VB8.VB8_VDAB + VB8.VB8_VDAO) VDAMESANT " +;
			" FROM " + RetSQLName("VB8") + " VB8 " +;
			" WHERE VB8.VB8_FILIAL = '" + xFilial("VB8") + "' " +;
				" AND VB8.VB8_ANO = '" + Str(Year(dDataIni),4)   + "' AND VB8.VB8_MES = '" + StrZero(Month(dDataIni),2) + "' " +;
				" AND VB8.D_E_L_E_T_ = ' '" +;
			" GROUP BY VB8.VB8_PRODUT" +;
			") TMPVENDA ON TMPVENDA.VB8_PRODUT = TMPVB8.VB8_PRODUT " +;
		" JOIN " + RetSQLName("SB1") + " B1 ON B1.B1_FILIAL = '" + xFilial("SB1") + "' AND B1.B1_COD = COALESCE(TMPVB8.VB8_PRODUT,TMPVENDA.VB8_PRODUT) AND B1.D_E_L_E_T_ = ' ' " +;
		" JOIN " +;
			"( SELECT D2_COD, COUNT(" + oSQLHelper:Concat( { "D2.D2_COD" , "D2.D2_CLIENTE" , "D2.D2_LOJA" } ) + ") POPULARIDADE " +;
			" FROM " + RetSQLName("SD2") + " D2 " +;
				" JOIN " + RetSQLName("SF4") + " F4 ON F4.F4_FILIAL = '" + xFilial("SF4") + "' AND F4.F4_CODIGO = D2.D2_TES AND F4.F4_OPEMOV = '05' AND F4.F4_ESTOQUE = 'S' AND F4.D_E_L_E_T_ = ' '" +;
			" WHERE D2.D2_FILIAL = '" + xFilial("SD2") + "'" +;
				" AND D2.D2_EMISSAO >= '" + cAnoIni   + cMesIni   + "01'" +;
				" AND D2.D2_EMISSAO <= '" + cAnoAtual + cMesAtual + "31'" +;
				" AND D2.D_E_L_E_T_ = ' '" +;
			" GROUP BY D2.D2_COD" +;
			") TMPPOP ON B1_COD = D2_COD " +;
		" LEFT JOIN " + RetSQLName("SB2") + " B2 ON B2.B2_FILIAL = '" + xFilial("SB2") + "' AND B2.B2_COD = B1.B1_COD AND B2.D_E_L_E_T_ = ' ' "+;
		" LEFT JOIN " + RetSQLName("SBZ") + " BZ ON BZ.BZ_FILIAL = '" + xFilial("SBZ") + "' AND BZ.BZ_COD = B1.B1_COD AND BZ.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasProc, .F., .T. )
	
	If !(cAliasProc)->(Eof())

		RegToMemory("VQU",.t.)
		lPrimReg := .t.
		
		dbSelectArea("VQV")
		While !(cAliasProc)->(Eof())

			SB1->(DbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1")+(cAliasProc)->B1_COD))
			If (cAliasProc)->( B2_LOCAL ) <> FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
				(cAliasProc)->(dbSkip())
				Loop
			EndIf
					
			If lPrimReg // Primeiro registro... Gravar cabeca VQU
				dbSelectArea("VQU")
				RecLock("VQU",.T.)
				FG_GRAVAR("VQU")
				VQU->VQU_DATA   := dDtReun
				VQU->VQU_LIMINF := nLimInf
				VQU->VQU_LIMSUP := nLimSup
				ConfirmSX8()
				VQU->(MsUnLock())
				cCodVQU  := VQU->VQU_CODIGO
				cAuxFil  := xFilial("VQV")
				lPrimReg := .f.
			EndIf
		
			//nDemanda := Round( (cAliasProc)->POPULARIDADE / 12 , 0 ) 
			RecLock("VQV",.t.)
			VQV->VQV_FILIAL := cAuxFil     // Filial 
			VQV->VQV_CODIGO := cCodVQU  // Código
			VQV->VQV_GRUITE := (cAliasProc)->B1_GRUPO // Grupo Peça
			VQV->VQV_CODITE := (cAliasProc)->B1_CODITE// Código Peça
			VQV->VQV_PRODUT := (cAliasProc)->VB8_PRODUT// Produto
//			VQV->VQV_DESCRI := // Descrição
//			VQV->VQV_CLASSI := ""// Classific.
//			VQV->VQV_PEDFIR := 0// Pedido Firme
			VQV->VQV_PREVIS := 0// Previsão
			VQV->VQV_MEDIA1 := Round( (cAliasProc)->DEMANDA1 / nPerConfig , 0 ) // Média
			VQV->VQV_MEDIA2 := Round( (cAliasProc)->DEMANDA2 / 6 , 0 ) // Média 6 M.
			VQV->VQV_MEDIA3 := Round( (cAliasProc)->DEMANDA3 / 12 , 0 ) // Média 12 M.
			VQV->VQV_VPERD1 := (cAliasProc)->VPERDIDA1 // V.Perdida
			VQV->VQV_VPERD2 := (cAliasProc)->VPERDIDA2 // V.Perdida 6 M.
			VQV->VQV_VPERD3 := (cAliasProc)->VPERDIDA3 // V.Perdida 12 M.
			VQV->VQV_POPULA := (cAliasProc)->POPULARIDADE// Popularidade
			VQV->VQV_QZERO1 := 0 // Q.Zero
			VQV->VQV_QZERO2 := 0 // Q.Zero 6 M.
			VQV->VQV_QZERO3 := 0 // Q.Zero 12 M.
			
			nPopularidade := Round( (cAliasProc)->POPULARIDADE , 0 ) 
			Do Case
			Case nPopularidade > nPopA
				VQV->VQV_CLASSI := "A" + IIF( (cAliasProc)->CUSTO < nCusA3 , "3" , IIF( (cAliasProc)->CUSTO < nCusA2 , "2" , "1" ) )
				If (cAliasProc)->INDICE > 0 .and. (nPedFirme := ( (cAliasProc)->INDICE * VQV->VQV_MEDIA1 ) - ( (cAliasProc)->ESTOQUE + (cAliasProc)->PEDCOMPRA )) > 0 
					VQV->VQV_PEDFIR := nPedFirme
				EndIf 
			Case nPopularidade > nPopB
				VQV->VQV_CLASSI := "B" + IIF( (cAliasProc)->CUSTO < nCusB3 , "3" , IIF( (cAliasProc)->CUSTO < nCusB2 , "2" , "1" ) )
				If (cAliasProc)->ESTQMAX <> 0 .and. (cAliasProc)->ESTQMAX > (cAliasProc)->VDAMESANT
					VQV->VQV_PEDFIR := (cAliasProc)->ESTQMAX - (cAliasProc)->VDAMESANT
				EndIf
			Case nPopularidade > nPopC
				VQV->VQV_CLASSI := "C" + IIF( (cAliasProc)->CUSTO < nCusC3 , "3" , IIF( (cAliasProc)->CUSTO < nCusC2 , "2" , "1" ) )
			Otherwise
				VQV->VQV_CLASSI := "D"
			EndCase
			
			For nCont := 1 to 12
				&("VQV->VQV_DEMA" + StrZero(nCont,2)) := &( cAliasProc + "->DEM_" + StrZero(nCont,2)) 
			Next nCont
			
			VQV->(MsUnLock())
			(cAliasProc)->(dbSkip())
		End

	EndIf
	(cAliasProc)->(dbCloseArea())
	VQV->(dbGoTOp())
	
	dbSelectArea("VQU")
	
	nAuxRec := FM_SQL("SELECT R_E_C_N_O_ FROM " + RetSQLName("VQU") + " VQU WHERE VQU_FILIAL = '" + xFilial("VQU") + "' AND VQU_CODIGO <> '" + cCodVQU + "' AND D_E_L_E_T_ = ' ' ORDER BY VQU_DATA DESC")
	//cLastVQU := FM_SQL(oSQLHelper:TOPFunc(cQuery))
	
	If nAuxRec <> 0
		VQU->(dbGoTo(nAuxRec))
		cLastVQU := VQU->VQU_CODIGO
		cQuery := "UPDATE " + RetSQLName("VQV") + " TVQV " +;
			"SET TVQV.VQV_PREVAN = " +;
				"( SELECT CASE WHEN VQVANT.VQV_PREVIS > 0 THEN VQVANT.VQV_PREVIS ELSE VQVANT.VQV_MEDIA1 END" +;
				   " FROM " + RetSQLName("VQV") + " VQVANT" +;
				  " WHERE VQVANT.VQV_FILIAL = '" + xFilial("VQV") + "'" +;
				    " AND VQVANT.VQV_CODIGO = '" + cLastVQU + "'" +;
				    " AND VQVANT.VQV_PRODUT = TVQV.VQV_PRODUT" +;
				    " AND VQVANT.D_E_L_E_T_ = ' ' )" +;
			"WHERE TVQV.VQV_FILIAL = '" + xFilial("VQV") + "'" +;
			" AND TVQV.VQV_CODIGO = '" + cCodVQU + "'" +;
			" AND TVQV.VQV_PRODUT IN " +;
				"( SELECT VQV_PRODUT " +;
				" FROM " + RetSQLName("VQV") +;
				" WHERE VQV_FILIAL ='" + xFilial("VQV") + "'" +;
					" AND VQV_CODIGO = '" + cLastVQU + "'" +;
					" AND D_E_L_E_T_ = ' ' )" +;
			" AND TVQV.D_E_L_E_T_ = ' '"
		If (TCSQLExec(cQuery) < 0)
			Return MsgStop("TCSQLError() " + TCSQLError())
		EndIf
		
		cQuery := "UPDATE " + RetSQLName("VQV") + " TVQV " +;
			"SET TVQV.VQV_ERRO = ROUND((TVQV.VQV_MEDIA1 - TVQV.VQV_PREVAN) / TVQV.VQV_PREVAN * 100,0) " +;
			"WHERE TVQV.VQV_FILIAL = '" + xFilial("VQV") + "'" +;
			 " AND TVQV.VQV_CODIGO = '" + cCodVQU + "'" +;
			 " AND TVQV.VQV_PREVAN <> 0" +;
			 " AND TVQV.VQV_MEDIA1 <> 0" +;
			 " AND TVQV.D_E_L_E_T_ = ' '"
		If (TCSQLExec(cQuery) < 0)
			Return MsgStop("TCSQLError() " + TCSQLError())
		EndIf
		
	EndIf
	
	// Calcula quantidade de vezes que o estoque chegou a zero
	cQuery := ;
		"SELECT VQV.VQV_PRODUT , VQV.R_E_C_N_O_ VQVRECNO " +;
		 " FROM " + RetSQLName("VQV") + " VQV " +;
		" WHERE VQV_FILIAL = '" + xFilial("VQV") + "' " +;
		  " AND VQV.VQV_CODIGO = '" + cCodVQU + "'" +;
		  " AND VQV.VQV_CLASSI LIKE 'A%'" +;
		  " AND VQV.D_E_L_E_T_ = ' '" +;
		" ORDER BY VQV.VQV_CODIGO "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasProc, .F., .T. )
	While !(cAliasProc)->(Eof())
		//
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+(cAliasProc)->VQV_PRODUT))
		oPecaDia:cGruIte := SB1->B1_GRUPO
		oPecaDia:cCodIte := SB1->B1_CODITE
		oPecaDia:cCodB1  := SB1->B1_COD
		oPecaDia:cLocPadrao := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
		aEstqZero := oPecaDia:RetDiaEstqZero(StoD(cAnoIni + cMesIni + '01'), dDataFim)
		//
		If Len(aEstqZero) > 0
			VQV->(dbGoTo( (cAliasProc)->VQVRECNO ))
			RecLock("VQV",.f.)
			For nPos := 1 to Len(aEstqZero)
				cAuxPeriodo := Left(aEstqZero[nPos],6)
				Do Case
				Case cAuxPeriodo >= cAnoPer1 + cMesPer1
					VQV->VQV_QZERO1 += 1
				Case cAuxPeriodo >= cAnoPer2 + cMesPer2
					VQV->VQV_QZERO2 += 1
				Otherwise
					VQV->VQV_QZERO3 += 1
				EndCase
			Next nPos
			VQV->(MsUnLock())
		EndIf
		(cAliasProc)->(dbSkip())
	End
	(cAliasProc)->(dbCloseArea())
	dbSelectArea("VQU")

			
Next nCont

cFilAnt := cBkpFilAnt

dbSelectArea("SB1")

Return
//

