#INCLUDE "PROTHEUS.CH"
#INCLUDE "QUICKSEARCH.CH"
#INCLUDE "TECQ011.CH"

QSSTRUCT TECQ011 DESCRIPTION STR0001 MODULE 28 // "Atendentes Desalocados" 

QSMETHOD INIT QSSTRUCT TECQ011
Local cWhere := ""
	QSTABLE "AA1" LEFT JOIN "SRJ" ON "SRJ.RJ_FUNCAO = AA1.AA1_FUNCAO" 
	
	// campos do SX3 e indices do SIX
	QSPARENTFIELD "AA1_CODTEC" INDEX ORDER 1 
	QSPARENTFIELD "AA1_NOMTEC" INDEX ORDER 5 
	
	// campos do SX3
	QSFIELD "AA1_CODTEC","AA1_NOMTEC","RJ_DESC"

	QSACTION MENUDEF "TECA020" OPERATION 1 LABEL STR0002 // "Visualizar Atendente"
	
	cWhere := "NOT EXISTS( " +;
					"SELECT 1 " +; 
					"FROM "+RetSqlName("ABB")+" ABBEX " +; 
					"WHERE ABBEX.D_E_L_E_T_=' ' " +; 
						"AND ABBEX.ABB_FILIAL = AA1.AA1_FILIAL " +; 
						"AND ABBEX.ABB_CODTEC = AA1.AA1_CODTEC " +;
						"AND ABBEX.ABB_DTINI BETWEEN '"+DTOS(Date())+"' AND '{1}'" +;
				")"
	
	QSFILTER STR0003 WHERE StrTran(cWhere, "{1}", DTOS(Date())) // "Hoje" 
	QSFILTER STR0004 WHERE StrTran(cWhere, "{1}", DTOS(Date() + 7)) // "Próximos 7 dias" 
	QSFILTER STR0005 WHERE StrTran(cWhere, "{1}", DTOS(Date() + 15)) // "Próximos 15 dias" 
	QSFILTER STR0006 WHERE StrTran(cWhere, "{1}", DTOS(Date() + 30)) // "Próximos 30 dias"
Return
