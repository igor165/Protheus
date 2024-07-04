#include "MATQ410.CH"
#include "protheus.ch"
#include "quicksearch.ch"

//------------------------------------------------------------------------------
/*/{Protheus.doc} MATQ410

Consulta Rápida (Quick View) de Pedido de Venda por Cliente

@param		Nenhum
	
@return	Nenhum 

@author	Vendas CRM
@since		20/05/2014       
@version	P12   
/*/
//------------------------------------------------------------------------------

QSSTRUCT MATQ410 DESCRIPTION STR0001 MODULE 5   //"Pedido de Venda por Cliente"

QSMETHOD INIT QSSTRUCT MATQ410

Local cWhere
	
	QSTABLE "SC5" JOIN "SC6" ON "SC6.C6_NUM = SC5.C5_NUM"
	QSTABLE "SC5" LEFT JOIN "SA1" ON "SA1.A1_LOJA = SC5.C5_LOJACLI AND SA1.A1_COD = SC5.C5_CLIENTE"
	
	// campos do SX3 e indices do SIX
	QSPARENTFIELD "A1_NREDUZ" INDEX ORDER 5
	QSPARENTFIELD "A1_CGC" INDEX ORDER 3
	
	// campos do SX3
	QSFIELD "C5_NUM", "C5_MOEDA"
	
	QSFIELD SUM "C6_VALOR"
	
	QSFIELD "A1_CGC", "A1_NREDUZ"
	
	QSFIELD "CODCLI" EXPRESSION "SC5.C5_CLIENTE + SC5.C5_LOJACLI" LABEL STR0002 ;  //"Cliente"
	FIELDS "SC5.C5_CLIENTE", "SC5.C5_LOJACLI" GROUP BY TYPE "C" ;
	SIZE GetSx3Cache("C5_CLIENTE","X3_TAMANHO") + GetSx3Cache("C5_LOJACLI","X3_TAMANHO")
	
	QSFIELD "C5_EMISSAO"

	QSFIELD "STATUS" ;
	EXPRESSION "CASE WHEN SC5.C5_LIBEROK = '' AND SC5.C5_NOTA = '' AND SC5.C5_BLQ = '' THEN '" + STR0003 + ;  //"Aberto"
	"' WHEN (SC5.C5_NOTA <> '' OR SC5.C5_LIBEROK = 'E')  AND SC5.C5_BLQ = '' THEN '" + STR0004 + "' END" ;  //"Encerrado"
	LABEL STR0005 FIELDS "SC5.C5_LIBEROK", "SC5.C5_NOTA", "SC5.C5_BLQ" TYPE "C" SIZE 10  //"Status"
	
	cWhere := 	"SC5.C5_EMISSAO >= '{1}' AND SC5.C5_EMISSAO <= '" + DTOS(Date()) + "' " +;
				"AND	((SC5.C5_LIBEROK	= '' AND SC5.C5_NOTA = '' AND SC5.C5_BLQ = '')" +;
				"OR ((C5_NOTA <> '' OR C5_LIBEROK = 'E') AND	SC5.C5_BLQ = ''))"
	
	QSFILTER STR0006 WHERE StrTran(cWhere, "{1}", DTOS(Date() - 30))  //"Últimos 30 dias"
	
	QSFILTER STR0007 WHERE StrTran(cWhere, "{1}", DTOS(Date() - 60))   //"Últimos 60 dias"
	
	QSFILTER STR0008 WHERE StrTran(cWhere, "{1}", DTOS(Date() - 90))   //"Últimos 90 dias"
	
	QSFILTER STR0009 WHERE StrTran(cWhere, "{1}", DTOS(Date() - 120))   //"Últimos 120 dias"

	QSFILTER STR0010 WHERE StrTran(cWhere, "{1}", DTOS(Date() - 360))  //"Últimos 360 dias"
	
Return
