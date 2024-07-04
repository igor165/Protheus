#include "protheus.ch"
#include "quicksearch.ch"

QSSTRUCT PLSQ080 DESCRIPTION "Custo Autorizações por Solicitante" MODULE 33

QSMETHOD INIT QSSTRUCT PLSQ080

	//Relacionamento das tabelas	
	QSTABLE "BB0" JOIN "BE2" // baseado no SX9
	
	// campos do SX3 e indices do SIX		
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2)) 
	SX3->(MsSeek("BB0_NOME")) 
	cDescCampo := AllTrim(X3TITULO("BB0_NOME")) 
	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2)) 
	SX3->(MsSeek("BE2_VLPGGU")) 
	nVlrGuia := AllTrim(X3TITULO("BE2_VLPGGU")) 
	
	QSPARENTFIELD "BB0_NOME" INDEX ORDER 2 LABEL cDescCampo
    
	// campos do SX3
	QSFIELD "BB0_NOME" LABEL cDescCampo//"Solicitante" 
	QSFIELD SUM "BE2_VLPGGU" LABEL nVlrGuia //"Custo Previsto Total" 
	
	QSACTION "PLSA260MOV" LABEL "Visualizar"
	
	//Filtros (o primeiro é o padrão)
	QSFILTER "Autorizadas  Hoje"          WHERE "BE2_STATUS = '1' AND BE2_DATPRO = '"+DTOS(Date())+"' "
	QSFILTER "Autorizadas  na Semana"     WHERE "BE2_STATUS = '1' AND (BE2_DATPRO >= '"+DTOS(Date()-7)+"' AND BE2_DATPRO <= '"+DTOS(Date())+"')"
	QSFILTER "Autorizadas  no Ultimo Mes" WHERE "BE2_STATUS = '1' AND (BE2_DATPRO >= '"+DTOS(Date()-30)+"' AND BE2_DATPRO <= '"+DTOS(Date())+"')"

Return  