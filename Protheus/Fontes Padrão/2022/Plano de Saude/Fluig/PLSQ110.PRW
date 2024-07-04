#include "protheus.ch"
#include "quicksearch.ch"

QSSTRUCT PLSQ110 DESCRIPTION "Custo Autorizações por Beneficiário" MODULE 33

QSMETHOD INIT QSSTRUCT PLSQ110

	//Relacionamento das tabelas	
	QSTABLE "BA1" JOIN "BE2" // baseado no SX9 
	
	// campos do SX3 e indices do SIX		
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2)) 
	SX3->(MsSeek("BA1_NOMUSR")) 
	cDescCampo := AllTrim(X3TITULO("BA1_NOMUSR"))
	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2)) 
	SX3->(MsSeek("BE2_VLPGGU")) 
	nVlrGuia := AllTrim(X3TITULO("BE2_VLPGGU")) 
	
	QSPARENTFIELD "BA1_NOMUSR" INDEX ORDER 3 LABEL cDescCampo //"Nome Beneficiário" //BA1_FILIAL, BA1_NOMUSR
    
	// campos do SX3
	QSFIELD "BA1_NOMUSR" LABEL cDescCampo //"Nome Beneficiário" 
	QSFIELD SUM "BE2_VLPGGU" LABEL nVlrGuia //"Custo Previsto Total" 
	
	QSACTION "PLSA260MOV" LABEL "Visualizar"
	
	//Filtros (o primeiro é o padrão)
	QSFILTER "Autorizadas  Hoje"          WHERE "BE2_STATUS = '1' AND BE2_DATPRO = '"+DTOS(Date())+"' "
	QSFILTER "Autorizadas  na Semana"     WHERE "BE2_STATUS = '1' AND (BE2_DATPRO >= '"+DTOS(Date()-7)+"' AND BE2_DATPRO <= '"+DTOS(Date())+"')"
	QSFILTER "Autorizadas  no Ultimo Mes" WHERE "BE2_STATUS = '1' AND (BE2_DATPRO >= '"+DTOS(Date()-30)+"' AND BE2_DATPRO <= '"+DTOS(Date())+"')"

Return  