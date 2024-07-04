#include "protheus.ch"
#include "quicksearch.ch"

QSSTRUCT PLSQ090 DESCRIPTION "Custo Autorizações por Tipo Prestador" MODULE 33

QSMETHOD INIT QSSTRUCT PLSQ090

	//Relacionamento das tabelas	
	QSTABLE "BAG" JOIN "BE2" // baseado no SX9
	
	// campos do SX3 e indices do SIX
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2)) 
	SX3->(MsSeek("BAG_CODIGO")) 
	cDescCampo := AllTrim(X3TITULO("BAG_CODIGO"))
	
	SX3->(MsSeek("BAG_DESCRI")) 
	cDesc := AllTrim(X3TITULO("BAG_DESCRI"))  
	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2)) 
	SX3->(MsSeek("BE2_VLPGGU")) 
	nVlrGuia := AllTrim(X3TITULO("BE2_VLPGGU")) 
			
	QSPARENTFIELD "BAG_CODIGO" INDEX ORDER 1 LABEL cDescCampo //"Tipo de Prestador" //BAG_FILIAL, BAG_CODIGO
    
	// campos do SX3
	QSFIELD "BAG_CODIGO" LABEL cDescCampo //"Tipo de Prestador"
	QSFIELD "BAG_DESCRI" LABEL cDesc //"Descrição"  
	QSFIELD SUM "BE2_VLPGGU" LABEL nVlrGuia //"Custo Previsto Total" 
	
	QSACTION "PLSA260MOV" LABEL "Visualizar"
	
	//Filtros (o primeiro é o padrão)
	QSFILTER "Autorizadas  Hoje"          WHERE "BE2_STATUS = '1' AND BE2_DATPRO = '"+DTOS(Date())+"' "
	QSFILTER "Autorizadas  na Semana"     WHERE "BE2_STATUS = '1' AND (BE2_DATPRO >= '"+DTOS(Date()-7)+"' AND BE2_DATPRO <= '"+DTOS(Date())+"')"
	QSFILTER "Autorizadas  no Ultimo Mes" WHERE "BE2_STATUS = '1' AND (BE2_DATPRO >= '"+DTOS(Date()-30)+"' AND BE2_DATPRO <= '"+DTOS(Date())+"')"

Return    