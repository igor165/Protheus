#include "MATQ460.CH"
#include "protheus.ch"
#include "quicksearch.ch"

//------------------------------------------------------------------------------
/*/{Protheus.doc} MATQ460

Consulta Rápida (Quick View) de Notas Fiscais por Cliente

@param		Nenhum
	
@return	Nenhum 

@author	Vendas CRM
@since		20/05/2014       
@version	P12   
/*/
//------------------------------------------------------------------------------

QSSTRUCT MATQ460 DESCRIPTION STR0001 MODULE 5   //"Notas Fiscais por Cliente"

QSMETHOD INIT QSSTRUCT MATQ460

Local cWhere
	
	QSTABLE "SF2" LEFT JOIN "SA1" ON "SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA"
	
	// campos do SX3 e indices do SIX
	QSPARENTFIELD "A1_NREDUZ" INDEX ORDER 5
	QSPARENTFIELD "A1_CGC" INDEX ORDER 3
	
	// campos do SX3
	QSFIELD "F2_CLIENTE", "F2_LOJA", "A1_NREDUZ", "A1_CGC", "F2_DOC", "F2_SERIE", "F2_EMISSAO", "F2_TIPO", "F2_VALBRUT", "F2_COND"
	
	cWhere := "SF2.F2_EMISSAO >= '{1}' AND SF2.F2_EMISSAO <= '" + DTOS(Date()) + "'"
	
	QSFILTER STR0002 WHERE StrTran(cWhere, "{1}", DTOS(Date() - 30))  //"Últimos 30 dias"
	
	QSFILTER STR0003 WHERE StrTran(cWhere, "{1}", DTOS(Date() - 60))   //"Últimos 60 dias"
	
	QSFILTER STR0004 WHERE StrTran(cWhere, "{1}", DTOS(Date() - 90))   //"Últimos 90 dias"
	
	QSFILTER STR0005 WHERE StrTran(cWhere, "{1}", DTOS(Date() - 120))   //"Últimos 120 dias"

	QSFILTER STR0006 WHERE StrTran(cWhere, "{1}", DTOS(Date() - 360))  //"Últimos 360 dias"
	 
Return
