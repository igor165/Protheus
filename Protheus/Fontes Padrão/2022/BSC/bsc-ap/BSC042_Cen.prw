// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC042_Cen.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC042_Cen.ch"

/*--------------------------------------------------------------------------------------
@entity Central
DashBoard Painel Geral contém o nível mais alto de dashboard.
@table BSC042
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "CENTRAL"
#define TAG_GROUP  "CENTRAIS"
#define TEXT_ENTITY STR0001/*//"Central Estratégica"*/
#define TEXT_GROUP  STR0002/*//"Centrais Estratégicas"*/

class TBSC042 from TBITable
	method New() constructor
	method NewBSC042()

	method oToXMLNode(nParentID)
	method nUpdFromXML(oXML, cPath, nParentID)
endclass
	
method New() class TBSC042
	::NewBSC042()
return
method NewBSC042() class TBSC042
	// Table
	::NewTable("BSC042")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	// Indexes
	::addIndex(TBIIndex():New("BSC042I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC042I02",	{"CONTEXTID"},	.f.))
	::addIndex(TBIIndex():New("BSC042I03",	{"PARENTID", "ID"},	.t.))
return

// Carregar
method oToXMLNode(nParentID) class TBSC042
	local oXMLOutput, oPersNode, oPerNode, oCardsNode
	local oPerspectiva, oObjetivo, dDataAlvo, lParcelada

	oXMLOutput := TBIXMLNode():New(TAG_ENTITY)
	oXMLOutput:oAddChild(TBIXMLNode():New("ID", nParentID))
	oXMLOutput:oAddChild(TBIXMLNode():New("NOME", ""))
	oXMLOutput:oAddChild(TBIXMLNode():New("PARENTID", nParentID))
	oXMLOutput:oAddChild(TBIXMLNode():New("CONTEXTID", nParentID))

 	dDataAlvo := ::oOwner():xSessionValue("DATAALVO")
	if(valtype(dDataAlvo)=="U")
		dDataAlvo := date()
	endif	     

	lParcelada := ::oOwner():xSessionValue("PARCELADA")
	if(empty(lParcelada))
		lParcelada := .f.
	endif	     

	// Acrescenta children
	oXMLOutput:oAddChild(TBIXMLNode():New("PARCELADA", lParcelada))
	oXMLOutPut:oAddChild(TBIXMLNode():New("DATAALVO", dDataAlvo))
	
	// Perpectiva
	oPersNode := oXMLOutput:oAddChild(TBIXMLNode():New("PERSPECTIVAS"))
	oPerspectiva := ::oOwner():oGetTable("PERSPECTIVA")
	oPerspectiva:cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	oPerspectiva:lFiltered(.t.)
	oPerspectiva:SetOrder(4)
	oPerspectiva:_First()
	while(!oPerspectiva:lEof())
		if(!oPerspectiva:lValue("OPERAC"))
			oPerNode := oPersNode:oAddChild(TBIXMLNode():New("PERSPECTIVA"))
			oPerNode:oAddChild(TBIXMLNode():New("ID", oPerspectiva:nValue("ID")))
			oPerNode:oAddChild(TBIXMLNode():New("NOME", oPerspectiva:cValue("NOME")))
			oPerNode:oAddChild(TBIXMLNode():New("ORDEM", oPerspectiva:nValue("ORDEM")))
			// Objetivo
			oObjetivo := ::oOwner():oGetTable("OBJETIVO")
			oObjetivo:cSQLFilter("PARENTID = "+oPerspectiva:cValue("ID")) // Filtra pelo pai
			oObjetivo:lFiltered(.t.)
			oObjetivo:_First()
			oCardsNode := oPerNode:oAddChild(TBIXMLNode():New("CARDS"))
			while(!oObjetivo:lEof())
				oCardsNode:oAddChild(oObjetivo:oXMLCard())
				oObjetivo:_Next()
			end
			oObjetivo:cSQLFilter("") // Encerra filtro
		endif
		oPerspectiva:_Next()
	end
	oPerspectiva:cSQLFilter("") // Encerra filtro
return oXMLOutput               

function _BSC042_Cen()
return