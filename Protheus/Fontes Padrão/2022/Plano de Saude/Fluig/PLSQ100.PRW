#include "protheus.ch"
#include "quicksearch.ch"

QSSTRUCT PLSQ100 DESCRIPTION "Custo Autorizações por Evento em Saúde" MODULE 33

QSMETHOD INIT QSSTRUCT PLSQ100          

	//Relacionamento das tabelas	
	QSTABLE "BR8" JOIN "BE2" // baseado no SX9 
	
	// campos do SX3 e indices do SIX		
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2)) 
	SX3->(MsSeek("BR8_DESCRI")) 
	cDescCampo := AllTrim(X3TITULO("BR8_DESCRI"))
	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2)) 
	SX3->(MsSeek("BE2_VLPGGU")) 
	nVlrGuia := AllTrim(X3TITULO("BE2_VLPGGU")) 
	
	QSPARENTFIELD "BR8_DESCRI" INDEX ORDER 2 LABEL cDescCampo //"Evento em Saúde" //BR8_FILIAL, BR8_DESCRI
    
	// campos do SX3
	QSFIELD "BR8_DESCRI" LABEL cDescCampo //"Evento em Saúde" 
	QSFIELD SUM "BE2_VLPGGU" LABEL nVlrGuia //"Custo Previsto Total" 
	
	QSACTION "PLSA260MOV" LABEL "Visualizar"
	
	//Filtros (o primeiro é o padrão)
	QSFILTER "Autorizadas  Hoje"          WHERE "BE2_STATUS = '1' AND BE2_DATPRO = '"+DTOS(Date())+"' "
	QSFILTER "Autorizadas  na Semana"     WHERE "BE2_STATUS = '1' AND (BE2_DATPRO >= '"+DTOS(Date()-7)+"' AND BE2_DATPRO <= '"+DTOS(Date())+"')"
	QSFILTER "Autorizadas  no Ultimo Mes" WHERE "BE2_STATUS = '1' AND (BE2_DATPRO >= '"+DTOS(Date()-30)+"' AND BE2_DATPRO <= '"+DTOS(Date())+"')"
Return       