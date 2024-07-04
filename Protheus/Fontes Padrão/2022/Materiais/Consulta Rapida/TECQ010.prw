#INCLUDE "PROTHEUS.CH"
#INCLUDE "QUICKSEARCH.CH"
#INCLUDE "TECQ010.CH"

QSSTRUCT TECQ010 DESCRIPTION STR0001 MODULE 28 // "Atendentes por Nome" 

QSMETHOD INIT QSSTRUCT TECQ010
	
	QSTABLE "AA1" LEFT JOIN "SRJ" ON "SRJ.RJ_FUNCAO = AA1.AA1_FUNCAO" 
	QSTABLE "AA1" LEFT JOIN "CTT" ON "CTT.CTT_CUSTO = AA1.AA1_CC"
	
	// campos do SX3 e indices do SIX
	QSPARENTFIELD "AA1_CODTEC" INDEX ORDER 1 
	QSPARENTFIELD "AA1_NOMTEC" INDEX ORDER 5 
	QSPARENTFIELD "RJ_DESC" INDEX ORDER 3 
	QSPARENTFIELD "CTT_CUSTO" INDEX ORDER 4
	
	// campos do SX3
	QSFIELD "AA1_CODTEC", "AA1_NOMTEC", "RJ_DESC", "AA1_CC", "CTT_DESC01"

	QSACTION MENUDEF "TECA020" OPERATION 1 LABEL STR0002 // "Visualizar Atendente"
	
	QSFILTER STR0003 WHERE "AA1.AA1_TIPO = '1'" // "Field Service" 
	QSFILTER STR0004 WHERE "AA1.AA1_TIPO = '2'" // "Help Desk"
	QSFILTER STR0006 WHERE "AA1.AA1_TIPO = '3'" // "Ambos" 
Return
