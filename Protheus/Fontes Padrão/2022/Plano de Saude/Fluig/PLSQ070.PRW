#include "protheus.ch"
#include "quicksearch.ch"

QSSTRUCT PLSQ070 DESCRIPTION "Custo Autorizações por Local de Atendimento" MODULE 33

QSMETHOD INIT QSSTRUCT PLSQ070

   //Relacionamento das tabelas	
	QSTABLE "BD1" JOIN "BE2" // baseado no SX9

	// campos do SX3 e indices do SIX		
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2)) 
	SX3->(MsSeek("BD1_DESLOC")) 
	cDescCampo := AllTrim(X3TITULO("BD1_DESLOC")) 
	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2)) 
	SX3->(MsSeek("BE2_VLPGGU")) 
	nVlrGuia := AllTrim(X3TITULO("BE2_VLPGGU")) 
	
	QSPARENTFIELD "BD1_DESLOC" INDEX ORDER 2 LABEL cDescCampo
    
	// campos do SX3
	QSFIELD "BD1_DESLOC" LABEL cDescCampo //"Local Atendimento" 
	QSFIELD SUM "BE2_VLPGGU" LABEL nVlrGuia //"Custo Previsto Total" 
	
	QSACTION "PLSA260MOV" LABEL "Visualizar"
	
	//Filtros (o primeiro é o padrão)
	QSFILTER "Autorizadas  Hoje"          WHERE "BE2_STATUS = '1' AND BE2_DATPRO = '"+DTOS(Date())+"' "
	QSFILTER "Autorizadas  na Semana"     WHERE "BE2_STATUS = '1' AND (BE2_DATPRO >= '"+DTOS(Date()-7)+"' AND BE2_DATPRO <= '"+DTOS(Date())+"')"
	QSFILTER "Autorizadas  no Ultimo Mes" WHERE "BE2_STATUS = '1' AND (BE2_DATPRO >= '"+DTOS(Date()-30)+"' AND BE2_DATPRO <= '"+DTOS(Date())+"')"

Return      