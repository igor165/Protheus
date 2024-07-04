// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC044_DriInd.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 17.05.05 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"

/*--------------------------------------------------------------------------------------
@class TBSC044
@entity Drill
Drill down dos Indicadores de Resultado.
@table BSC044
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "DRILL"
#define TAG_GROUP  "DRILLS"
#define TEXT_ENTITY "Drill"
#define TEXT_GROUP  "Drills"

class TBSC044 from TBITable
	method New() constructor
	method NewBSC044()

	method oToXMLNode(nParentID)
	method nUpdFromXML(oXML, cPath, nParentID)
	
endclass
	
method New() class TBSC044
	::NewBSC044()
return

method NewBSC044() class TBSC044
	// Table
	::NewTable("BSC044")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	//::addField(TBIField():New("DESCRICAO",	"C",	255))
	// Indexes
	::addIndex(TBIIndex():New("BSC044I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC044I02",	{"CONTEXTID"},	.f.))
	::addIndex(TBIIndex():New("BSC044I03",	{"PARENTID", "ID"},	.t.))
return

// Carregar
method oToXMLNode(nParentID) class TBSC044
	local oXMLOutput, oXMLIndicador, oIndResult,  oIndicador, oPessoa
	local nInd1, nLenIndicador, nEstratID, nIndicadorID, dDataAlvo
	local  oCardsNode, lParcelada
	
	// No principal
	oXMLOutput := TBIXMLNode():New(TAG_ENTITY)

	// Indicador de Resultado - principal
	oIndResult := ::oOwner():oGetTable("INDICADOR")
	oIndResult:lSeek(1, {nParentID})
    oXMLOutput:oAddChild(::oOwner():oContext(oIndResult, nParentID))

	nEstratID := oIndResult:nValue("CONTEXTID")

	// Cabecalho da central
	oXMLOutput:oAddChild(TBIXMLNode():New("ID", nEstratID))
	oXMLOutput:oAddChild(TBIXMLNode():New("NOME", oIndResult:cValue("NOME")))
	oXMLOutput:oAddChild(TBIXMLNode():New("DESCRICAO", oIndResult:cValue("DESCRICAO")))
	oXMLOutput:oAddChild(TBIXMLNode():New("METRICA", oIndResult:cValue("METRICA")))
	oXMLOutput:oAddChild(TBIXMLNode():New("FREQUENCIA", oIndResult:oGetFrequencia(oIndResult:nValue("FREQ"))))
	// Responsavel
	if(oIndResult:cValue("TIPOPESSOA")=="G")
		oPessoa := ::oOwner():oGetTable("PGRUPO")
	else
		oPessoa := ::oOwner():oGetTable("PESSOA")
	endif
	oPessoa:lSeek(1, {oIndResult:nValue("RESPID")})
	oXMLOutput:oAddChild(TBIXMLNode():New("RESPONSAVEL", oPessoa:cValue("NOME")))
	oXMLOutput:oAddChild(TBIXMLNode():New("PARENTID", oIndResult:nValue("PARENTID"))) //nEstratID
	oXMLOutput:oAddChild(TBIXMLNode():New("CONTEXTID", nEstratID))

	// XML com cards do indicador de Resultado - principal
	oCardsNode := oXMLOutput:oAddChild(TBIXMLNode():New("CARDS"))
	oNode := oCardsNode:oAddChild(oIndResult:oXMLCard())
	oNode:oAddChild(TBIXMLNode():New("VISIVEL",.t.))
	
	// XML com cards do Indicadores de Tendência
	oIndTend 		:= ::oOwner():oGetTable("INDTEND")
	oIndicador 		:= ::oOwner():oGetTable("INDICADOR")
	oXMLIndicador 	:= oIndTend:oToEntityList("INDICADOR", oIndResult:nValue("ID")) //Indicador de resultado
	//oXMLIndicador 	:= oIndicador:oToEntityList("INDICADOR", nParentID) //Indicador de resultado
	nLenIndicador	:= oXMLIndicador:nChildCount("INDICADOR")
	for nInd1 := 1 to nLenIndicador
		oNode := oXMLIndicador:oChildByName("INDICADOR", nInd1)
		nIndicadorID := oNode:oChildByName("ID"):nGetValue()
		oIndicador:lSeek(1, {nIndicadorID})
		oNode := oCardsNode:oAddChild(oIndicador:oXMLCard())
		oNode:oAddChild(TBIXMLNode():New("ID",nIndicadorID))
		oNode:oAddChild(TBIXMLNode():New("VISIVEL",.t.))
		oNode:oAddChild(TBIXMLNode():New("ORDEM", 0))
		oNode:oAddChild(TBIXMLNode():New("CARDX", 0))
		oNode:oAddChild(TBIXMLNode():New("CARDY", 0))
	next

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
	oXMLOutput:oAddChild(TBIXMLNode():New("DATAALVO", dDataAlvo))
return oXMLOutput
                        
function _BSC044_DriInd()
return