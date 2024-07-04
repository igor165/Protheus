#include "protheus.ch"
#include "quicksearch.ch"
#include "FISQ002.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISQ002
WidGet ISS por Município

@author By Wise
@since 03/03/2014
@version MP11.8, MP12
/*/
//-------------------------------------------------------------------

QSSTRUCT FISQ002 DESCRIPTION STR0001 MODULE 9 //"ISS por Município"

QSMETHOD INIT QSSTRUCT FISQ002
Local nMonth := Month(Date())
Local nYear := Year(Date())
Local cMonth
Local cYear
	
	QSTABLE "SF3" JOIN "SA1" ON "SA1.A1_COD = SF3.F3_CLIEFOR AND SA1.A1_LOJA = SF3.F3_LOJA"
	QSTABLE "SA1" JOIN "CC2"
	QSTABLE "SF3" JOIN "SF2" ON "SF2.F2_DOC = SF3.F3_NFISCAL AND SF2.F2_CLIENTE = SF3.F3_CLIEFOR AND SF2.F2_LOJA = SF3.F3_LOJA"
	
	// indices de pesquisa
	QSPARENTFIELD "CC2_EST","CC2_CODMUN" INDEX ORDER 1 
	QSPARENTFIELD "CC2_MUN" INDEX ORDER 2
	
	// campos do grid
	QSFIELD "CC2_CODMUN", "CC2_MUN", "F3_EMISSAO", "F2_MOEDA"

	QSFIELD SUM "F3_VALICM"

	// acoes relacionadas
	QSACTION MENUDEF "FISA010" OPERATION 2 LABEL STR0002 //"Visualizar Municipio"
	
	// filtros	
	
	cMonth := StrZero(nMonth,2)
	cYear := StrZero(nYear,4)
	
	QSFILTER STR0003 WHERE "SF3.F3_EMISSAO >= '" + cYear + cMonth + "01' AND SF3.F3_EMISSAO <= '" + cYear + cMonth + ; //"Mês Corrente"
	"31' AND (SF3.F3_TIPO = 'S' OR SF3.F3_TIPO='L') AND SUBSTRING(SF3.F3_CFO, 1, 1) >= '5' AND (SF3.F3_CODISS <> ' ' AND SF3.F3_TIPO<>'L')" 
	
	If nMonth == 1
		nMonth := 12
		nYear--
		cYear := StrZero(nYear,4)
	Else
		nMonth--
	EndIf
	
	cMonth := StrZero(nMonth,2)
	
	QSFILTER STR0004 WHERE "SF3.F3_EMISSAO >= '" + cYear + cMonth + "01' AND SF3.F3_EMISSAO <= '" + cYear + cMonth + ; //"Ultimo mês"
	"31' AND (SF3.F3_TIPO = 'S' OR SF3.F3_TIPO='L') AND SUBSTRING(SF3.F3_CFO, 1, 1) >= '5' AND (SF3.F3_CODISS <> ' ' AND SF3.F3_TIPO<>'L')"
	
	If nMonth == 1
		nMonth := 12
		nYear--
		cYear := StrZero(nYear,4)
	Else
		nMonth--
	EndIf
	
	cMonth := StrZero(nMonth,2)
	
	QSFILTER STR0005 WHERE "SF3.F3_EMISSAO >= '" + cYear + cMonth + "01' AND SF3.F3_EMISSAO <= '" + cYear + cMonth + ; //"Penultimo mês"
	"31' AND (SF3.F3_TIPO = 'S' OR SF3.F3_TIPO='L') AND SUBSTRING(SF3.F3_CFO, 1, 1) >= '5' AND (SF3.F3_CODISS <> ' ' AND SF3.F3_TIPO<>'L')"
Return
