// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC061_ReuCon.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// 10.08.04 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC061_ReuCon.ch"

/*--------------------------------------------------------------------------------------
@class TBSC061_REUCON
@entity REUCON
Lista de cobranca da tarefa. (pessoas)
@table BSC061
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "REUCON"
#define TAG_GROUP  "REUCONS"
#define TEXT_ENTITY STR0001/*//"Pessoa Convocadas"*/
#define TEXT_GROUP  STR0002/*//"Pessoas Convocadas"*/

class TBSC061 from TBITable
	method New() constructor
	method NewBSC061()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)

	// registro atual
	method oToXMLNode()
	method nDelFromXML(nID)

endclass

method New() class TBSC061
	::NewBSC061()
return
method NewBSC061() class TBSC061
	// Table
	::NewTable("BSC061")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("PESSOAID",	"N"))
	::addField(TBIField():New("TIPOPESSOA",	"C",	1)) //G = Grupo, P = Individual
	// Indexes
	::addIndex(TBIIndex():New("BSC061I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC061I02",	{"CONTEXTID"},	.f.))
	::addIndex(TBIIndex():New("BSC061I03",	{"PARENTID", "ID"},	.t.))
	::addIndex(TBIIndex():New("BSC061I04",	{"PARENTID", "PESSOAID", "TIPOPESSOA"},	.t.))
return

// Arvore
method oArvore(nParentID) class TBSC061
	local oXMLArvore, oNode
	
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	if(!::lEof())
		// Tag conjunto
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", 1)
		oAttrib:lSet("TIPO", TAG_GROUP)
		oAttrib:lSet("NOME", TEXT_GROUP)
		oXMLArvore := TBIXMLNode():New(TAG_GROUP,"",oAttrib)
		// Nodes
		while(!::lEof())
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", ::nValue("ID"))
			oAttrib:lSet("NOME", alltrim(::cValue(STR0003))) //Nome
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Encerra filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC061
	local oNode, oAttrib, oXMLNode, nInd, cTipoPessoa, nRespId
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", STR0003) /*Nome*/
	oAttrib:lSet("CLA000", BSC_STRING)

	oAttrib:lSet("TAG001", "CARGO")
	oAttrib:lSet("CAB001", STR0004) /*Cargo*/
	oAttrib:lSet("CLA001", BSC_STRING)

	// Gera recheio
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::setOrder(4)
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"ID", "CONTEXTID","DESCRICAO","CARGO","FONE","RAMAL","EMAIL"})
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1]=="PESSOAID")
				aFields[nInd][1] := "ID"
			endif
			if(aFields[nInd][1]=="ID")
				nRespId := aFields[nInd][2]
			endif
			if(aFields[nInd][1]=="TIPOPESSOA")
				cTipoPessoa := aFields[nInd][2]
			endif
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		// Virtuais
		if(cTipoPessoa=="G")
			oTable := ::oOwner():oGetTable("PGRUPO")
			oTable:lSeek(1, {nRespId})
			oNode:oAddChild(TBIXMLNode():New("NOME", oTable:cValue("NOME")))
			oNode:oAddChild(TBIXMLNode():New("CARGO", ""))
		else
			oTable := ::oOwner():oGetTable("PESSOA")
			oTable:lSeek(1, {nRespId})
			oNode:oAddChild(TBIXMLNode():New("NOME", oTable:cValue("NOME")))
			oNode:oAddChild(TBIXMLNode():New("CARGO", oTable:cValue("CARGO")))
		endif
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode() class TBSC061
	local aFields, nInd, nID
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
	next
	// Acrescenta children
	oXMLNode:oAddChild(::oOwner():oGetTable("REUCON"):oToXMLList(nID))
return oXMLNode

// Excluir entidade do server
method nDelFromXML(nID) class TBSC061
	local nStatus := BSC_ST_OK
	
	// Deleta o elemento
	if(nStatus != BSC_ST_HASCHILD)
		if(::lSeek(1, {nID}))
			if(!::lDelete())
				nStatus := BSC_ST_INUSE
			endif
		else
			nStatus := BSC_ST_BADID
		endif	
    endif

return nStatus

function _BSC061_ReuCon()
return