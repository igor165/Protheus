// ######################################################################################
// Projeto: BSC
// Modulo : Reunioes
// Fonte  : BSC062_ReuRet.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// 05.08.04 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC062_ReuRet.ch"

/*--------------------------------------------------------------------------------------
@class TBSC062
@entity REURET
Retorno sobre andamento da reunião (antes ou após).
@table BSC062
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "REURET"
#define TAG_GROUP  "REURETS"
#define TEXT_ENTITY STR0001/*//"Retorno"*/
#define TEXT_GROUP  STR0002/*//"Retornos"*/

class TBSC062 from TBITable
	method New() constructor
	method NewBSC062()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)

	// registro atual
	method oToXMLNode(nParentID)
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	method nDuplicate(nParentID, nNewParentID, nNewContextID)
endclass

method New() class TBSC062
	::NewBSC062()
return
method NewBSC062() class TBSC062
	local oField

	// Table
	::NewTable("BSC062")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(oField := TBIField():New("NOME",		"C",	160))
	oField:lSensitive(.f.)
	::addField(TBIField():New("TEXTO",		"M"))
	::addField(TBIField():New("DATAR",		"D"))
	::addField(TBIField():New("HORAR",		"C", 	8))
	::addField(TBIField():New("RESPID",		"N"))	// ID de pessoa em cobranca
	::addField(TBIField():New("TIPOPESSOA",	"C",	1)) //G = Grupo, P = Individual
	// Indexes
	::addIndex(TBIIndex():New("BSC062I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC062I02",	{"NOME", "CONTEXTID"},	.t.))
	::addIndex(TBIIndex():New("BSC062I03",	{"PARENTID", "ID"},	.t.))
	::addIndex(TBIIndex():New("BSC062I04",	{"DATAR", "HORAR"},	.t.))
return

// Arvore
method oArvore(nParentID) class TBSC062
	local oXMLArvore, oNode
	
	::SetOrder(4) // Por ordem de data-hora
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
			oAttrib:lSet("FEEDBACK", ::nValue("FEEDBACK"))
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Encerra filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC062
	local oNode, oAttrib, oXMLNode, nInd, cTipoPessoa, nRespID
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", BSC_STRING)
	// Responsavel
	oAttrib:lSet("TAG001", "RESPONSAVEL")
	oAttrib:lSet("CAB001", STR0004)/*//"Responsável"*/
	oAttrib:lSet("CLA001", BSC_STRING)
	// Data
	oAttrib:lSet("TAG002", "DATAR")
	oAttrib:lSet("CAB002", STR0005)/*//"Data"*/
	oAttrib:lSet("CLA002", BSC_DATE)
	// Hora
	oAttrib:lSet("TAG003", "HORAR")
	oAttrib:lSet("CAB003", STR0006)/*//"Hora"*/
	oAttrib:lSet("CLA003", BSC_STRING)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(4) // Por ordem de data-hora
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","TEXTO"})
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1]=="RESPID")
				nRespId := aFields[nInd][2]
			elseif(aFields[nInd][1] == "TIPOPESSOA")
				cTipoPessoa := aFields[nInd][2]
			else
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			endif
		next
		::_Next()

		// Virtuais
		if(cTipoPessoa=="G")
			oTable := ::oOwner():oGetTable("PGRUPO")
		else
			oTable := ::oOwner():oGetTable("PESSOA")
		endif
		oTable:lSeek(1, {nRespId})
		oNode:oAddChild(TBIXMLNode():New("RESPONSAVEL", oTable:cValue("NOME")))

	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentId) class TBSC062
	local nID, aFields, nInd, cTipoPessoa, nRespID
	local oTable, oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		elseif(aFields[nInd][1] == "RESPID")
			nRespId := aFields[nInd][2]
		elseif(aFields[nInd][1] == "TIPOPESSOA")
			cTipoPessoa := aFields[nInd][2]
		endif	
	next
	// Virtuais
	if(cTipoPessoa=="G")
		oTable := ::oOwner():oGetTable("PGRUPO")
	else
		oTable := ::oOwner():oGetTable("PESSOA")
	endif
	oTable:lSeek(1, {nRespId})
	oXMLNode:oAddChild(TBIXMLNode():New("RESPONSAVEL", oTable:cValue("NOME")))
return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC062
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
method nUpdFromXML(oXML, cPath) class TBSC062
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
method nDelFromXML(nID) class TBSC062
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

// Duplica os registros filhos de nParentID, colocando-os como filhos de nNewParentID do contexto nNewContextID
method nDuplicate(nParentID, nNewParentID, nNewContextID) class TBSC062
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
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif

		::_Next()
	enddo
	::cSQLFilter("") // Zera filtro

	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()

return nStatus         

function _BSC062_ReuRet()
return
