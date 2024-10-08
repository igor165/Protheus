#INCLUDE "PROTHEUS.CH"
#INCLUDE "QUICKSEARCH.CH"
#INCLUDE "TECQ005.CH"

QSSTRUCT TECQ005 DESCRIPTION STR0001 MODULE 28 // "Previs�o de Materias de Consumo" 

QSMETHOD INIT QSSTRUCT TECQ005
	
	QSTABLE "TFH" JOIN "TFF" ON "TFF.TFF_COD = TFH.TFH_CODPAI" 
	QSTABLE "TFF" JOIN "TFL" ON "TFL.TFL_CODIGO = TFF.TFF_CODPAI"
	QSTABLE "TFL" JOIN "CN9" ON "CN9.CN9_NUMERO = TFL.TFL_CONTRT AND CN9_REVISA = TFL.TFL_CONREV"
	QSTABLE "TFH" LEFT JOIN "SB1" ON "SB1.B1_COD = TFH.TFH_PRODUT"
	
	// campos do SX3 e indices do SIX
	QSPARENTFIELD "TFL_CONTRT" INDEX ORDER 4 
	QSPARENTFIELD "TFH_PRODUT" INDEX ORDER 4 
	
	// campos do SX3
	QSFIELD "TFL_CONTRT","TFH_PRODUT","B1_DESC","TFH_QTDVEN"
	
	QSFIELD "VLRTOT" EXPRESSION "((TFH_QTDVEN * TFH_PRCVEN) - TFH_VALDES)" LABEL STR0004 ; // "Valor Total"
	FIELDS "TFH_QTDVEN", "TFH_PRCVEN", "TFH_VALDES" TYPE "N" SIZE 14 DECIMAL 2 PICTURE "@E 99,999,999,999.99"
	
	QSFIELD "TFH_PERFIM"

	QSFILTER STR0003 WHERE "CN9.CN9_SITUAC = '05' AND '"+DTOS(Date())+"' BETWEEN TFH.TFH_PERINI AND TFH.TFH_PERFIM" // "Todos" 
Return
