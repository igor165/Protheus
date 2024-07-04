////////////////
// Versao 001 //
////////////////

#include "protheus.ch"

Function VEICLSAN()
Return()


/*/{Protheus.doc} DMS_NotaFiscal

	@author       Vinicius Gati
	@since        02/06/2015
	@description  Representa nota fiscal no protheus e conterá metodos para manipulacao das notas
/*/
Class DMS_NotaFiscal
	METHOD New() CONSTRUCTOR
	METHOD Exists()
EndClass

/*/{Protheus.doc} DMS_NotaFiscal:Exists

	@author       Vinicius Gati
	@since        02/06/2015
	@description  Verifica se a nota fiscal já existe
/*/
METHOD Exists(cA2Cod, cA2Loja, cNf, cSerie) CLASS DMS_NotaFiscal
	Local cQuery := "" 
	cQuery       += " SELECT COALESCE( COUNT(*), 0 ) FROM " + RetSqlName("SF1") + " WHERE D_E_L_E_T_ <> '*' AND F1_FILIAL = '" + xfilial("SF1") + "' " // busca padrao dados f1
	cQuery       += " AND F1_FORNECE = '"+cA2Cod+"' AND F1_LOJA = '"+cA2Loja+"' AND F1_DOC = '"+cNf+"' AND F1_SERIE = '" + cSerie + "' "
	nQtd         := VAL( FM_SQL(cQuery) )
Return nQtd > 0