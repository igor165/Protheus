// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC015D_Tend.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 10.05.05 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC015D_Tend.ch"

/*--------------------------------------------------------------------------------------
@class TBSC015D
@entity INDTEND
Relacao de indicador de tendencia x Indicador de Resultado
@table BSC015D
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "INDTEND"
#define TAG_GROUP  "INDTENDS"
#define TEXT_ENTITY STR0001/*//"Indicador de Tendencia"*/
#define TEXT_GROUP  STR0002/*//"Indicadores de Tendencia"*/

class TBSC015D from TBITable
	method New() constructor
	method NewBSC015D()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)

	// registro atual
	method oToXMLNode(nParentID)
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)

	method oToEntityList(cEntity, aIDs)
	method nDuplicate(nParentID, nNewParentID, nNewContextID)

endclass

method New() class TBSC015D
	::NewBSC015D()
return
method NewBSC015D() class TBSC015D
	// Table
	::NewTable("BSC015D")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(TBIField():New("INDICADOR",	"N"))
	// Indexes
	::addIndex(TBIIndex():New("BSC015DI01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC015DI02",	{"CONTEXTID"} ))
	::addIndex(TBIIndex():New("BSC015DI03",	{"PARENTID", "ID"},	.t.))
	::addIndex(TBIIndex():New("BSC015DI04",	{"INDICADOR"}, .f.))
return

// Arvore
method oArvore(nParentID) class TBSC015D
	local oXMLArvore, oNode
	
	::SetOrder(3) // Por ordem de nome
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
			oAttrib:lSet("NOME", alltrim(::cValue("NOME")))
			oAttrib:lSet("FEEDBACK", ::nValue("FEEDBACK"))
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Encerra filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC015D
	local oNode, oAttrib, oXMLNode, nInd, oTable, nIndicador
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", BSC_STRING)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(2) // Por ordem de nome
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"ID","PARENTID","CONTEXTID"})
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1]=="INDICADOR")
				aFields[nInd][1] := "ID"
				nIndicador := aFields[nInd][2]
			endif
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		oTable := ::oOwner():oGetTable("INDICADOR")
		oTable:lSeek(1, {nIndicador})
		oNode:oAddChild(TBIXMLNode():New("NOME", oTable:cValue("NOME")))

		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentID) class TBSC015D
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
	oXMLNode:oAddChild(::oOwner():oContext(self, nParentID))
return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC015D
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
	else
		// Extrai e grava lista de pessoas convocadas
		oTable := ::oOwner():oGetTable("INDTEND")
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_INDTENDS"), "_INDTEND"))!="U")
			if(valtype(&("oXMLInput:"+cPath+":_INDTENDS:_INDTEND"))=="A")
				for nInd := 1 to len(&("oXMLInput:"+cPath+":_INDTENDS:_INDTEND"))
					aINDTEND := &("oXMLInput:"+cPath+":_INDTENDS:_INDTEND["+cBIStr(nInd)+"]")
					oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
						{"CONTEXTID", ::nValue("CONTEXTID")} })
				next	
			elseif(valtype(&("oXMLInput:"+cPath+":_INDTENDS:_INDTEND"))=="O")
				aINDTEND := &("oXMLInput:"+cPath+":_INDTENDS:_INDTEND")
				oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
					{"CONTEXTID", ::nValue("CONTEXTID")} })
			endif
		endif	
	endif	
return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC015D
	local nInd, nStatus := BSC_ST_OK,	nID
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
method nDelFromXML(nID) class TBSC015D
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

// Lista XML para anexar ao pai, de todas os Indicadores de tendencia de um Indicador Resultado
method oToEntityList(cEntity, aIDs) class TBSC015D
	local oNode, oAttrib, oXMLNode, oResultado
	local oTable, cIDs, nInd
	
	if(cEntity=="ESTRATEGIA")
		cIDs := cBIConcatWSep(",", aIDs) // Converter os IDs em cadeia para sql
		cIDs := strtran(cIDs, '"', "'")
		aIds := {} // Limpar Ids

		oTable := ::oOwner():oGetTable("PERSPECTIVA")
		oTable:SetOrder(2) // Por ordem de nome
		oTable:cSQLFilter("PARENTID IN ("+cIDs+")") // Filtra pelo pai
		oTable:lFiltered(.t.)
		oTable:_First()
		while(!oTable:lEof())
			aAdd(aIDs, oTable:nValue("ID"))
			oTable:_Next()
		end
		oTable:cSQLFilter("") // Encerra filtro

		cIDs := cBIConcatWSep(",", aIDs) // Converter os IDs em cadeia para sql
		cIDs := strtran(cIDs, '"', "'")
		aIds := {} // Limpar Ids

		oTable := ::oOwner():oGetTable("OBJETIVO")
		oTable:SetOrder(2) // Por ordem de nome
		oTable:cSQLFilter("PARENTID IN ("+cIDs+")") // Filtra pelo pai
		oTable:lFiltered(.t.)
		oTable:_First()
		while(!oTable:lEof())
			aAdd(aIDs, oTable:nValue("ID"))
			oTable:_Next()
		end
		oTable:cSQLFilter("") // Encerra filtro

	endif
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", BSC_STRING)
	// Gera no principal
	oXMLNode := TBIXMLNode():New("INDICADORES",,oAttrib)
	
	// Gera recheio
	cIDs := cBIConcatWSep(",", aIDs) // Converter os IDs em cadeia para sql
	cIDs := strtran(cIDs, '"', "'")
	::SetOrder(2) // Por ordem de nome
	::cSQLFilter("INDICADOR IN ("+cIDs+")") // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	oResultado := ::oOwner():oGetTable("INDICADOR")
	while(!::lEof())
		oResultado:lSeek(1, {::nValue("PARENTID")})
		oNode := oXMLNode:oAddChild(TBIXMLNode():New("INDICADOR"))
		aFields := oResultado:xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","UNIDADE","FREQ","RESPID","DATASRCID","TIPOPESSOA"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		oNode:oAddChild(TBIXMLNode():New("FEEDBACK", oResultado:nFeedBack()))
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Duplica os registros filhos de nParentID, colocando-os como filhos de nNewParentID do contexto nNewContextID
method nDuplicate(nParentID, nNewParentID, nNewContextID) class TBSC015D
	local nStatus := BSC_ST_OK, aFields, nID
	
	::oOwner():oOltpController():lBeginTransaction()

	::SetOrder(1) // Por ordem de id
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof() .and. nStatus == BSC_ST_OK)
		// Copia temporario
		aFields := ::xRecord(RF_ARRAY, {"ID", "PARENTID", "CONTEXTID"})
		aAdd( aFields, {"ID",  nID := ::nMakeID()} )
		aAdd( aFields, {"PARENTID", nNewParentID} )
		aAdd( aFields, {"CONTEXTID", nNewContextID} )

		// Grava
		::savePos()
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif
		::restPos()

		::_Next()
	enddo
	::cSQLFilter("") // Zera filtro

	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()
return nStatus            

function _BSC015d_Tend()
return
