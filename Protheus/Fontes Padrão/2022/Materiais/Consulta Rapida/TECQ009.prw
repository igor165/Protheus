#INCLUDE "PROTHEUS.CH"
#INCLUDE "QUICKSEARCH.CH"
#INCLUDE "TECQ009.CH"

QSSTRUCT TECQ009 DESCRIPTION STR0001 MODULE 28 // "Realizado de Apontamentos de Materiais de Consumo" 

QSMETHOD INIT QSSTRUCT TECQ009
Local cWhere := ""
	
	QSTABLE "TFT" JOIN "TFL" ON "TFL.TFL_CODIGO = TFT.TFT_CODTFL"
	QSTABLE "TFT" JOIN "TFH" ON "TFH.TFH_COD = TFT.TFT_CODTFH" 
	QSTABLE "TFL" JOIN "CN9" ON "CN9.CN9_NUMERO = TFL.TFL_CONTRT AND CN9_REVISA = TFL.TFL_CONREV"
	QSTABLE "TFH" LEFT JOIN "SB1" ON "SB1.B1_COD = TFT.TFT_PRODUT"
	
	// campos do SX3 e indices do SIX
	QSPARENTFIELD "TFL_CONTRT" INDEX ORDER 4 
	QSPARENTFIELD "B1_DESC" INDEX ORDER 3 LABEL STR0008 // "Desc. Produto"
	
	// campos do SX3
	QSFIELD "TFL_CONTRT","TFT_PRODUT","B1_DESC","TFT_DTAPON","TFT_QUANT"

	QSFIELD "VLRTOT" EXPRESSION "(TFT_QUANT * TFH_PRCVEN)" LABEL STR0007 ; // "Valor Total"
	FIELDS "TFT_QUANT", "TFH_PRCVEN" TYPE "N" SIZE 14 DECIMAL 2 PICTURE "@E 99,999,999,999.99"
	
	cWhere := "CN9.CN9_SITUAC = '05' AND TFT.TFT_DTAPON >= '{1}' AND TFT.TFT_DTAPON <= '" + DTOS(Date()) + "'"
	
	QSFILTER STR0003 WHERE StrTran(cWhere, "{1}", DTOS(Date())) // "Hoje" 
	QSFILTER STR0004 WHERE StrTran(cWhere, "{1}", DTOS(Date() - 7)) // "�ltimos 7 dias" 
	QSFILTER STR0005 WHERE StrTran(cWhere, "{1}", DTOS(Date() - 30)) // "�ltimos 30 dias" 
	QSFILTER STR0006 WHERE StrTran(cWhere, "{1}", DTOS(Date() - 60)) // "�ltimos 60 dias" 
Return
