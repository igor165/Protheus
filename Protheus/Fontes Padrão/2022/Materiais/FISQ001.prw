#include "protheus.ch"
#include "quicksearch.ch"
#include "FISQ001.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISQ001
WidGet Nota Fiscal de Saída

@author By Wise
@since 03/03/2014
@version MP11.8, MP12
/*/
//-------------------------------------------------------------------

QSSTRUCT FISQ001 DESCRIPTION STR0001 MODULE 9 //"Notas Fiscais de Saída"

QSMETHOD INIT QSSTRUCT FISQ001
Local cDate
Local cSPED := Padr("SPED",GetSx3Cache("F2_ESPECIE","X3_TAMANHO"))
Local cSerie	:= SerieNfId("SF2",3,"F2_SERIE")
	
	QSTABLE "SA1" JOIN "SF2" // baseado no SX9
	
	// indices de pesquisa
	QSPARENTFIELD "F2_CLIENTE" INDEX ORDER 2 
	QSPARENTFIELD "A1_NOME" INDEX ORDER 2 SET RELATION TO "F2_CLIENTE","F2_LOJA" WITH "A1_COD","A1_LOJA" LABEL "Nome do Cliente"
	QSPARENTFIELD "F2_DOC","F2_SERIE" INDEX ORDER 1
	
	// campos do grid
	QSFIELD cSerie, "F2_DOC", "F2_CLIENTE", "F2_LOJA", "A1_NOME", "F2_MOEDA", "F2_VALBRUT", "F2_FIMP", "F2_EMISSAO" 

	// acoes relacionadas
	QSACTION MENUDEF "MATA030" OPERATION 2 LABEL STR0002 //"Visualizar Cliente"
	QSACTION MENUDEF "MATC090" OPERATION 2 LABEL STR0003 //"Visualizar Nota Fiscal"
	
	// filtros
	cDate := DTOS(Date())
	QSFILTER STR0004 WHERE "F2_EMISSAO = '" + cDate + "'" //"Dia"
	QSFILTER STR0005 WHERE "F2_EMISSAO = '" + cDate + "' AND F2_FIMP = ' ' .AND. F2_ESPECIE = '" + cSPED +  "'" //"Dia nao transmitida"
	QSFILTER STR0006 WHERE "F2_EMISSAO = '" + cDate + "' AND F2_FIMP = 'S'" //"Dia autorizada"
	QSFILTER STR0007 WHERE "F2_EMISSAO = '" + cDate + "' AND F2_FIMP = 'T'" //"Dia transmitida"
	QSFILTER STR0008 WHERE "F2_EMISSAO = '" + cDate + "' AND F2_FIMP = 'D'" //"Dia uso denegado"
	QSFILTER STR0009 WHERE "F2_EMISSAO = '" + cDate + "' AND F2_FIMP = 'N'" //"Dia nao autorizada"

	cDate := DTOS(Date() - 7)
	QSFILTER STR0010 WHERE "F2_EMISSAO > '" + cDate + "'"
	QSFILTER STR0011 WHERE "F2_EMISSAO > '" + cDate + "' AND F2_FIMP = ' ' .AND. F2_ESPECIE = '" + cSPED +  "'"
	QSFILTER STR0012 WHERE "F2_EMISSAO > '" + cDate + "' AND F2_FIMP = 'S'"
	QSFILTER STR0013 WHERE "F2_EMISSAO > '" + cDate + "' AND F2_FIMP = 'T'"
	QSFILTER STR0014 WHERE "F2_EMISSAO > '" + cDate + "' AND F2_FIMP = 'D'"
	QSFILTER STR0015 WHERE "F2_EMISSAO > '" + cDate + "' AND F2_FIMP = 'N'"
	
	cDate := DTOS(Date() - 30)
	QSFILTER STR0016 WHERE "F2_EMISSAO > '" + cDate + "'"
	QSFILTER STR0017 WHERE "F2_EMISSAO > '" + cDate + "' AND F2_FIMP = ' ' .AND. F2_ESPECIE = '" + cSPED +  "'"
	QSFILTER STR0018 WHERE "F2_EMISSAO > '" + cDate + "' AND F2_FIMP = 'S'"
	QSFILTER STR0019 WHERE "F2_EMISSAO > '" + cDate + "' AND F2_FIMP = 'T'"
	QSFILTER STR0020 WHERE "F2_EMISSAO > '" + cDate + "' AND F2_FIMP = 'D'"
	QSFILTER STR0021 WHERE "F2_EMISSAO > '" + cDate + "' AND F2_FIMP = 'N'"
Return
