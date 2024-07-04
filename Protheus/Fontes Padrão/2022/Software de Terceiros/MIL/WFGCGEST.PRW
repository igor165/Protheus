#include "tbiconn.ch"
#INCLUDE "Protheus.ch"
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | WFGCGEST   | Autor |  Luis Delorme         | Data | 15/04/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Rotina de Workflow para Atualizacao de Base de Dados e afins |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
user Function WFGCGEST(aParaMIL)

Local cEmprMIL
Local cFilMIL
Local lWF
Local cAliasSQL := "SQLALIAS"
Local cQuery := ""
Local nni
Default aParaMIL := {"","",.F.}

cEmprMIL := aParaMIL[1]
cFilMIL := aParaMIL[2]
lWF := aParaMIL[3]

If lWF
	Prepare Environment Empresa cEmprMIL Filial cFilMIL Tables "SD2","SB1","SB5","SB2"
EndIf

//rpcsetenv

//#############################################################################
//# Deleta todas as entradas do periodo                                       #
//#############################################################################
If TCCanOpen(RetSqlName("VPK"))
	cString := "DELETE * FROM "+RetSqlName("VPK") + ;
	" WHERE VPK_DATMOV >= '" + DTOS(ddatabase - 40)	+ "'"
	TCSqlExec(cString)
EndIf	
//#############################################################################
//# Monta a query para obter informacoes de venda e custo de produtos         #
//#############################################################################
cQuery := "SELECT " +	"SUM(B2_QATU)              ESTOQUE_ATUAL, " 		// OK !
cQuery += 					"SUM(B2_CM1 * B2_QATU)     CUSTO_ESTOQUE, " 		// OK !
cQuery += 					"SUM(D2_QUANT)             QUANT_VENDIDA, " 		// OK !
cQuery += 					"SUM(D2_CUSTO1 * D2_QUANT) CUSTO_VENDIDO, " 		// OK !
cQuery += 					"SUM(D2_TOTAL)             VALOR_VENDIDO, " 		// TODO: ESSE CAMPO EH IGUAL AO PROXIMO
cQuery +=					"SUM(D2_PRUNIT * D2_QUANT) VALOR_LIQ_VENDIDO, " // TODO: ESSE CAMPO EH IGUAL AO ANTERIOR
cQuery += 					"D2_EMISSAO, B1_GRUPO, B5_CODCAI , D2_FILIAL "
cQuery += "FROM " +	RetSqlName("SD2")+" SD2, "
cQuery += 				RetSqlName("SB1")+" SB1, "
cQuery += 				RetSqlName("SB5")+" SB5, "
cQuery += 				RetSqlName("SB2")+" SB2, "
cQuery += 				RetSqlName("SF4")+" SF4 "
cQuery += "WHERE " + 	"D2_EMISSAO >= '" + DTOS(ddatabase - 40) + "' AND "
cQuery += 					"B1_COD = D2_COD AND "
cQuery += 					"B1_COD = B5_COD AND "
cQuery += 					"B1_GRUPO <> '"+Left(GetMv("Mv_GruVei"),Len(SB1->B1_GRUPO))+"' AND "
//-----------------------------------------------------------
// Luis Delorme         : Alterado em 31-03-2010 - 08:52  (INICIO)
cGirEst := GetNewPar("MV_GIREST","")
if !Empty(cGirEst)
	cQuery += 					"B1_GRUPO IN "+FormatIn(cGirEst,"/")+" AND "
endif
// Luis Delorme         : Alterado em 31-03-2010 - 08:52  (FIM)
//-----------------------------------------------------------
cQuery += 					"B2_COD = B1_COD AND "
cQuery += 					"B2_FILIAL = D2_FILIAL AND "
cQuery += 					"B2_LOCAL= '01' AND "
cQuery += 					"F4_DUPLIC= 'S' AND "
cQuery += 					"SB2.D_E_L_E_T_ = ' ' AND "
cQuery += 					"SD2.D_E_L_E_T_ = ' ' AND "
cQuery += 					"SB5.D_E_L_E_T_ = ' ' AND "
cQuery += 					"SB1.D_E_L_E_T_ = ' ' "
cQuery += "GROUP BY D2_EMISSAO, B1_GRUPO, B5_CODCAI, D2_FILIAL"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSQL, .F., .T. )
// 
DBSelectArea("VPK")
//
aVPK := {}
while !( cAliasSQL )->( Eof() )
	//
	aAdd(aVPK, {  (cAliasSQL )->(D2_FILIAL),;
	( cAliasSQL )->(D2_EMISSAO),;
	( cAliasSQL )->(B1_GRUPO),;
	( cAliasSQL )->(B5_CODCAI),;
	( cAliasSQL )->(ESTOQUE_ATUAL),;
	( cAliasSQL )->(CUSTO_ESTOQUE),;
	( cAliasSQL )->(QUANT_VENDIDA),;
	( cAliasSQL )->(CUSTO_VENDIDO),;
	( cAliasSQL )->(VALOR_VENDIDO),;
	( cAliasSQL )->(VALOR_LIQ_VENDIDO),;
	0 })
	
	//
	( cAliasSQL )->( DBSkip() )
enddo
//
( cAliasSQL )->( dbCloseArea() )
//#############################################################################
//# Monta a query para obter informacoes de titulo (prazo medio)              #
//#############################################################################
cQuery := "SELECT " +	"F2_DOC, F2_EMISSAO, E1_VALOR, E1_VENCREA, F2_VALFAT "
cQuery += "FROM " +		RetSqlName("SF2")+" SF2, "
cQuery += 					RetSqlName("SE1")+" SE1 "
cQuery += "WHERE " + 	"F2_EMISSAO >= '" + DTOS(ddatabase - 40) + "' AND "
cQuery += 					"F2_DUPL = E1_NUM  AND "
cQuery +=					"(F2_FILIAL = E1_FILIAL OR E1_FILIAL = '  ') AND "
cQuery += 					"SF2.D_E_L_E_T_ = ' ' AND "
cQuery += 					"SE1.D_E_L_E_T_ = ' ' "

cQuery += "ORDER BY F2_DOC "
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSQL, .F., .T. )
cNFIni := ""
nPrzMed := 0
aPrzMed := {}
while !( cAliasSQL )->( Eof() )
	if ( cAliasSQL )->(F2_DOC) <> cNFIni  .and. cNFIni <> ""
		aAdd(aPrzMed,{cNFIni,nPrzMed})
		nPrzMed := 0
	endif
	//
	cNFIni 	:= ( cAliasSQL )->(F2_DOC)
	nDias 	:= stod((cAliasSQL)->(E1_VENCREA)) - stod((cAliasSQL)->(F2_EMISSAO))
	nValTit	:=( cAliasSQL )->(E1_VALOR)
	nTotalNF	:=( cAliasSQL )->(F2_VALFAT)
	nPrzMed	+= nValTit * nDias / nTotalNF
	//
	( cAliasSQL )->( DBSkip() )
enddo
//
aAdd(aPrzMed,{cNFIni,nPrzMed})
//
( cAliasSQL )->( dbCloseArea() )
//
//#############################################################################
//# Monta a query para obter informacoes de titulo (prazo medio)              #
//#############################################################################
cQuery := "SELECT " +	"D2_FILIAL, " 		// OK !
cQuery +=					"D2_DOC, " 			// OK !
cQuery +=					"D2_EMISSAO, " 			// OK !
cQuery += 					"B1_GRUPO, " 		// OK !
cQuery += 					"B5_CODCAI, " 		// OK !
cQuery += 					"SUM(D2_TOTAL) TOTAL " 		// TODO: ESSE CAMPO EH IGUAL AO PROXIMO
cQuery += "FROM " +	RetSqlName("SD2")+" SD2, "
cQuery += 				RetSqlName("SB1")+" SB1, "
cQuery += 				RetSqlName("SB5")+" SB5, "
cQuery += 				RetSqlName("SF4")+" SF4 "
cQuery += "WHERE " + 	"D2_EMISSAO >= '" + DTOS(ddatabase - 40) + "' AND "
cQuery += 					"B1_COD = D2_COD AND "
cQuery += 					"B1_COD = B5_COD AND "
cQuery += 					"F4_DUPLIC = 'S' AND "
cQuery += 					"SD2.D_E_L_E_T_ = ' ' AND "
cQuery += 					"SB5.D_E_L_E_T_ = ' ' AND "
cQuery += 					"SB1.D_E_L_E_T_ = ' ' "
cQuery += "GROUP BY D2_EMISSAO, D2_DOC, B1_GRUPO, B5_CODCAI, D2_FILIAL"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSQL, .F., .T. )
// 
DBSelectArea("VPK")
//
while !( cAliasSQL )->( Eof() )
	nPos := aScan(aVPK,{|x| x[1]+x[2]+x[3]+x[4] ==;
	( cAliasSQL )->(D2_FILIAL)+( cAliasSQL )->(D2_EMISSAO)+( cAliasSQL )->(B1_GRUPO)+( cAliasSQL )->(B5_CODCAI) })
	nPos2 := aScan(aPrzMed,{|x| x[1] == ( cAliasSQL )->(D2_DOC) })
	if nPos2 > 0 .and. nPos > 0
		aVPK[nPos,11]+= aPrzMed[nPos2,2]*( cAliasSQL )->(TOTAL) / aVPK[nPos,9] 
	endif
	//
	( cAliasSQL )->( DBSkip() )
enddo
//
( cAliasSQL )->( dbCloseArea() )
//
for nni := 1 to Len(aVPK)
	reclock("VPK",.t.)
	VPK_FILIAL := aVPK[nni,1]
	VPK_DATMOV := stod(aVPK[nni,2])
	VPK_GRUPO  := aVPK[nni,3]
	VPK_CODCAI := aVPK[nni,4]
	VPK_QTDEST := aVPK[nni,5]
	VPK_CUSEST := aVPK[nni,6]
	VPK_QTDVDA := aVPK[nni,7]
	VPK_CUSVDA := aVPK[nni,8]
	VPK_VALVDA := aVPK[nni,9]
	VPK_VALLIQ := aVPK[nni,10]
	VPK_PRZMED := aVPK[nni,11]
	msunlock()
next
//
return .t.
