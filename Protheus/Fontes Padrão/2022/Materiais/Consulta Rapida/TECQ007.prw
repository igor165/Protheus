#INCLUDE "PROTHEUS.CH"
#INCLUDE "QUICKSEARCH.CH"
#INCLUDE "TECQ007.CH"

QSSTRUCT TECQ007 DESCRIPTION STR0001 MODULE 28 // "Realizado de Aloca��o de Recursos Humanos" 

QSMETHOD INIT QSSTRUCT TECQ007
Local cWhere := ""
	
	QSTABLE "CN9" JOIN "ABQ" ON "ABQ.ABQ_CONTRT = CN9.CN9_NUMERO"
	QSTABLE "CN9" JOIN "TFL" ON "TFL.TFL_CONTRT = CN9.CN9_NUMERO AND TFL.TFL_CONREV = CN9.CN9_REVISA"
	QSTABLE "CN9" LEFT JOIN "ABB" ON "ABB.ABB_IDCFAL = CN9.CN9_NUMERO || ABQ.ABQ_ITEM || 'CN9' AND ABB.ABB_ATIVO = '1'"
	QSTABLE "ABB" LEFT JOIN "ABS" ON "ABS.ABS_LOCAL = ABB.ABB_LOCAL"
	QSTABLE "ABB" LEFT JOIN "AA1" ON "AA1.AA1_CODTEC = ABB.ABB_CODTEC"
	
	// campos do SX3 e indices do SIX
	QSPARENTFIELD "AA1_NOMTEC" INDEX ORDER 5
	QSPARENTFIELD "AA1_CODTEC" INDEX ORDER 1
	
	// campos do SX3
	QSFIELD "ABB_DTINI","ABB_CODTEC","AA1_NOMTEC","ABS_DESCRI"
	
	cWhere := "CN9.CN9_SITUAC = '05' AND ABB.ABB_DTINI BETWEEN '{1}' AND '"+ DTOS(Date())+"'"
	
	QSFILTER STR0003 WHERE StrTran(cWhere, "{1}", DTOS(Date())) // "Hoje" 
	QSFILTER STR0004 WHERE StrTran(cWhere, "{1}", DTOS(Date() - 7)) // "�ltimos 7 dias" 
	QSFILTER STR0005 WHERE StrTran(cWhere, "{1}", DTOS(Date() - 30)) // "�ltimos 30 dias" 
	QSFILTER STR0006 WHERE StrTran(cWhere, "{1}", DTOS(Date() - 60)) // "�ltimos 60 dias" 
Return
