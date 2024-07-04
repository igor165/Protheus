// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC018B_Cob.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC018B_Cob.ch"

/*--------------------------------------------------------------------------------------
@class TBSC018B
@entity TARCOB
Lista de cobranca da tarefa. (pessoas)
@table BSC018B
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "TARCOB"
#define TAG_GROUP  "TARCOBS"
#define TEXT_ENTITY STR0001/*//"Pessoa em Cobrança"*/
#define TEXT_GROUP  STR0002/*//"Pessoas em Cobrança"*/

class TBSC018B from TBITable
	method New() constructor
	method NewBSC018B()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)

	// registro atual
	method oToXMLNode()
	method nInsFromXML(nID)
	method nUpdFromXML(nID)
	method nDelFromXML(nID)
	
	method nDuplicate(nParentID, nNewParentID, nNewContextID)	
endclass

method New() class TBSC018B
	::NewBSC018B()
return
method NewBSC018B() class TBSC018B
	// Table
	::NewTable("BSC018B")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("PESSOAID",	"N"))
	::addField(TBIField():New("TIPOPESSOA",	"C",	1)) //G = Grupo, P = Individual
	// Indexes
	::addIndex(TBIIndex():New("BSC018BI01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC018BI02",	{"CONTEXTID"},	.f.))
	::addIndex(TBIIndex():New("BSC018BI03",	{"PARENTID", "ID"},	.t.))
	::addIndex(TBIIndex():New("BSC018BI04",	{"PARENTID", "PESSOAID", "TIPOPESSOA"},	.t.))
return

// Arvore
method oArvore(nParentID) class TBSC018B
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
			oAttrib:lSet("NOME", alltrim(::cValue("NOME")))
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Encerra filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC018B
	local oNode, oAttrib, oXMLNode, nInd, cTipoPessoa, nId
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .t.)
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
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"ID", "CONTEXTID","NOME" })
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1]=="PESSOAID")
				aFields[nInd][1] := "ID"    
				nId := aFields[nInd][2]
			elseif(aFields[nInd][1] == "TIPOPESSOA")
				cTipoPessoa := aFields[nInd][2]
			endif	
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		// Virtuais
		if(cTipoPessoa=="G")
			oTable := ::oOwner():oGetTable("PGRUPO")
			oTable:lSeek(1, {nId})
			oNode:oAddChild(TBIXMLNode():New("NOME", oTable:cValue("NOME")))
			oNode:oAddChild(TBIXMLNode():New("CARGO", ""))
		else
			oTable := ::oOwner():oGetTable("PESSOA")
			oTable:lSeek(1, {nId})
			oNode:oAddChild(TBIXMLNode():New("NOME", oTable:cValue("NOME")))
			oNode:oAddChild(TBIXMLNode():New("CARGO", oTable:cValue("CARGO")))
		endif
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode() class TBSC018B
	local aFields, nInd, nID, cTipoPessoa, nRespId, oTable
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		elseif(aFields[nInd][1] == "PESSOAID")
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
	oXMLNode:oAddChild(TBIXMLNode():New("NOME", oTable:cValue("NOME")))
return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC018B
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
method nUpdFromXML(oXML, cPath) class TBSC018B
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
method nDelFromXML(nID) class TBSC018B
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
method nDuplicate(nParentID, nNewParentID, nNewContextID) class TBSC018B
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

function _BSC015B_Cob()
return