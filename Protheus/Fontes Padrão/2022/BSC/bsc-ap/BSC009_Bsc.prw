// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC009_Org.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC009_Bsc.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet->TBITable->TBSC009
Lista de organizações.
@entity: Bsc
@table BSC009
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "BSC"
#define TAG_GROUP  "BSCS"
#define TEXT_ENTITY STR0001/*//"Organizações"*/
#define TEXT_GROUP  STR0001/*//"Organizações"*/

class TBSC009 from TBITable
	method New() constructor
	method NewBSC009()

	// registro atual
	method oToXMLNode()
endclass
	
method New() class TBSC009
	::NewBSC009()
return
method NewBSC009() class TBSC009
	local oField

	// Table
	::NewTable("BSC009")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(oField := TBIField():New("NOME",		"C",	60))
	oField:lSensitive(.f.)
	::addField(TBIField():New("DESCRICAO",	"C",	255))

	// Indexes
	::addIndex(TBIIndex():New("BSC009I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC009I02",	{"NOME", "CONTEXTID"},	.t.))
return

// Carregar
method oToXMLNode() class TBSC009
	local oTable, nID, aFields, nInd
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
	next

	// Estrategias
	oTable := ::oOwner():oGetTable("ORGANIZACAO")
	oXMLNode:oAddChild( oTable:oToXMLList(nID) )

return oXMLNode            

function _bsc009_bsc()
return
