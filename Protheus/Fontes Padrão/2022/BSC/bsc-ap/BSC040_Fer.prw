// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC040_Fer.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC040_Fer.ch"

/*--------------------------------------------------------------------------------------
Ferramentas.
@entity FERRAMENTA
Banco de ferramentas estratégicas.
(Não há tabela, todas as ferramentas estao registradas em codigo).
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "FERRAMENTA"
#define TAG_GROUP  "FERRAMENTAS"
#define TEXT_ENTITY STR0001/*//"Scorecard"*/
#define TEXT_GROUP  STR0002/*//"Scorecards"*/

class TBSC040 from TBITable
	
	data faTools // Contém a ferramentas disponíveis

	method New() constructor
	method NewBSC040()

	method oToXMLList(nParentID)
endclass
	
method New() class TBSC040
	::NewBSC040()
return
method NewBSC040() class TBSC040
	// Table
	::NewTable("BSC040")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	// Indexes
	::addIndex(TBIIndex():New("BSC040I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC040I02",	{"CONTEXTID"},	.f.))
	::addIndex(TBIIndex():New("BSC040I03",	{"PARENTID", "ID"},	.t.))
	
	// Ferramentas
	::faTools := {{STR0003, "MAPAEST"}, {STR0004, "CENTRAL"}, {STR0005,"MAPAEST2"} }   ;/*//"Mapa Estratégico"*/ /*//"Central Estratégica" "Mapa Estratégico Modelo 2"  */ 
return

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC040
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", BSC_STRING)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	for nInd := 1 to len(::faTools)
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		oNode:oAddChild(TBIXMLNode():New("ID", nParentID))
		oNode:oAddChild(TBIXMLNode():New("NOME", ::faTools[nInd][1]))
		oNode:oAddChild(TBIXMLNode():New("TIPO", ::faTools[nInd][2]))
	next

return oXMLNode        

function _BSC040_Fer()
return