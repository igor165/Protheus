// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC050_Rels.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 18.12.03 | 1645 Leandro Marcelino Santos
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC050_Rels.ch"

/*--------------------------------------------------------------------------------------
Relatorios
@entity RELATORIO
Banco de relat�rios estrat�gicos.
(N�o h� tabela, todas os relat�rios estao registradas em codigo).
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "RELATORIO"
#define TAG_GROUP  "RELATORIOS"
#define TEXT_ENTITY STR0001/*//"Relat�rio"*/
#define TEXT_GROUP  STR0002/*//"Relat�rios"*/

class TBSC050 from TBITable
	
	data faReports // Cont�m os relat�rios dispon�veis

	method New() constructor
	method NewBSC050()

	method oToXMLList(nParentID)
endclass
	
method New() class TBSC050
	::NewBSC050()
return
method NewBSC050() class TBSC050
	// Table
	::NewTable("BSC050")
	::cEntity(TAG_ENTITY)
	// Campos
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	// Indexes
	::addIndex(TBIIndex():New("BSC050I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC050I02",	{"CONTEXTID"},	.f.))
	::addIndex(TBIIndex():New("BSC050I03",	{"PARENTID", "ID"},	.t.))
	
	// Relat�rios
	::faReports := {{STR0003, "RELEST"}, {STR0009, "RELTAR"}, {STR0010, "RELIND"}, {STR0006, "REL5W2H"}, {STR0007, "RELBOOKSTRA"}, {STR0008, "RELEVOL"}}
			/*//"Relat�rio de Estrat�gia"*/
			/*//"Relat�rio de Tarefas"*/
			/*//"Relat�rio de Indicadores"*/
			/*//"Relat�rio de Plano de A��o"*/
			/*//"Book de Planejamento estrat�gico"*/
return

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC050
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", BSC_STRING)
	// Gera n� principal.
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gerar o recheio.
	for nInd := 1 to len(::faReports)
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		oNode:oAddChild(TBIXMLNode():New("ID", nParentID))
		oNode:oAddChild(TBIXMLNode():New("NOME", ::faReports[nInd][1]))
		oNode:oAddChild(TBIXMLNode():New("TIPO", ::faReports[nInd][2]))
	next

return oXMLNode               
// Not implemented.
function _BSC050_Rels()
return