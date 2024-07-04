// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC019A_Cob.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC019A_Cob.ch"

/*--------------------------------------------------------------------------------------
@class TBSC019A
@entity REUCOB
Lista de cobranca da reunião. (pessoas)
@table BSC019A
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "REUCOB"
#define TAG_GROUP  "REUCOBS"
#define TEXT_ENTITY STR0001/*//"Pessoa em Cobrança"*/
#define TEXT_GROUP  STR0002/*//"Pessoas em Cobrança"*/

class TBSC019A from TBITable
	method New() constructor
	method NewBSC019A()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)

	// registro atual
	method oToXMLNode()
	method nInsFromXML(nID)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(oXML, cPath)
	method xVirtualField(cField, xValue)
endclass

method New() class TBSC019A
	::NewBSC019A()
return
method NewBSC019A() class TBSC019A
	// Table
	::NewTable("BSC019A")
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("PESSOAID",	"N"))
	// Virtuais
	oVirtual := TBIField():New("NOME",	"C", 50)
	oVirtual:bGet({|oTable| oTable:xVirtualField("NOME")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("NOME", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("CARGO",	"C", 20)
	oVirtual:bGet({|oTable| oTable:xVirtualField("CARGO")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("CARGO", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("FONE",	"C", 20)
	oVirtual:bGet({|oTable| oTable:xVirtualField("FONE")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("FONE", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("RAMAL",	"C", 10)
	oVirtual:bGet({|oTable| oTable:xVirtualField("RAMAL")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("RAMAL", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("EMAIL",	"C", 80)
	oVirtual:bGet({|oTable| oTable:xVirtualField("EMAIL")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("EMAIL", xValue)})
	::addField(oVirtual)
	// Indexes
	::addIndex(TBIIndex():New("BSC019AI01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC019AI02",	{"CONTEXTID"},	.f.))
	::addIndex(TBIIndex():New("BSC019AI03",	{"PARENTID", "ID"},	.t.))
	::addIndex(TBIIndex():New("BSC019AI04",	{"PARENTID", "PESSOAID"},	.t.))
return

// xVirtualField
method xVirtualField(cField, xValue) class TBSC019A
	local oTable, xRet := xValue
	if(valtype(xValue)=="U")
		oTable := ::oOwner():oGetTable("PESSOA")
		oTable:lSeek(1, {::nValue("PESSOAID")})
		xRet := oTable:xValue(cField)
	endif
return xRet

// Arvore
method oArvore(nParentID) class TBSC019A
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
			oAttrib:lSet("NOME", alltrim(::cValue(STR0003)))/*//"Nome"*/
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Encerra filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC019A
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"ID", "PARENTID","CONTEXTID","NOME","DESCRICAO","CARGO","FONE","RAMAL","EMAIL"})
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1]=="PESSOAID")
				aFields[nInd][1] := "ID"
			endif	
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode() class TBSC019A
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
return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC019A
	local aFields, nInd, nStatus := BSC_ST_OK
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
	next
	aAdd( aFields, {"ID", ::nMakeID()} )
	
	// Grava
	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := BSC_ST_UNIQUE
		else
			nStatus := BSC_ST_INUSE
		endif
	endif	
return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC019A
	local nStatus := BSC_ST_OK,	nID, nInd
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
	next

	// Verifica condições de gravação (append ou update)
	if(!::lSeek(1, {nID}))
		nStatus := BSC_ST_BADID
	else
		if(!::lUpdate(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif	
	endif
return nStatus

// Excluir entidade do server
method nDelFromXML(nID) class TBSC019A
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

	// Quando implementar security
	// nStatus := BSC_ST_NORIGHTS
return nStatus