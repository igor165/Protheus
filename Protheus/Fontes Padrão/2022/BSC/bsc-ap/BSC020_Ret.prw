// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC020_Ret.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC020_Ret.ch"

/*--------------------------------------------------------------------------------------
@class TBSC020
@entity Retorno
Retorno sobre andamento da iniciativa.
@table BSC020
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "RETORNO"
#define TAG_GROUP  "RETORNOS"
#define TEXT_ENTITY STR0001/*//"Retorno"*/
#define TEXT_GROUP  STR0002/*//"Retornos"*/

class TBSC020 from TBITable
	method New() constructor
	method NewBSC020()

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

method New() class TBSC020
	::NewBSC020()
return
method NewBSC020() class TBSC020
	local oField

	// Table
	::NewTable("BSC020")
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
	// Indexes
	::addIndex(TBIIndex():New("BSC020I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC020I02",	{"NOME", "CONTEXTID"},	.t.))
	::addIndex(TBIIndex():New("BSC020I03",	{"PARENTID", "ID"},	.t.))
return

// Arvore
method oArvore(nParentID) class TBSC020
	local oXMLArvore, oNode
	
	::SetOrder(2) // Por ordem de nome
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
method oToXMLList(nParentID) class TBSC020
	local oNode, oAttrib, oXMLNode, nInd
	
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
	::SetOrder(2) // Por ordem de nome
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","TEXTO"})
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1]=="RESPID")
				oTable := ::oOwner():oGetTable("PESSOA")
				oTable:lSeek(1, {aFields[nInd][2]})
				aFields[nInd][1] := "RESPONSAVEL"
				aFields[nInd][2] := oTable:cValue("NOME")
			endif
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentID) class TBSC020
	local nID, aFields, nInd, nOrgID, nRespId := 0
	local oTable, oXMLNode := TBIXMLNode():New(TAG_ENTITY)
	local nUsuAtual := ::oOwner():foSecurity:oLoggedUser():nValue("ID")
	local lAdmin := ::oOwner():foSecurity:oLoggedUser():lValue("ADMIN")

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		if(aFields[nInd][1] == "RESPID")
			nRespId := aFields[nInd][2]
		else
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		endif	
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
	next

	oTable := self
	if(nID==0)
		oTable := ::oOwner():oGetTable("PESSOA")
		oTable:lSeek(4, {nUsuAtual})
		oXMLNode:oAddChild(TBIXMLNode():New("RESPID", oTable:nValue("ID")))
		oXMLNode:oAddChild(TBIXMLNode():New("RESPONSAVEL", oTable:cValue("NOME")))
		oXMLNode:oAddChild(TBIXMLNode():New("ALTERAR","T"))
		oTable := ::oOwner():oGetTable("TAREFA")
		oTable:lSeek(1, {nParentID})
	else
		oTable := ::oOwner():oGetTable("PESSOA")
		oTable:lSeek(1, {nRespId})
		oXMLNode:oAddChild(TBIXMLNode():New("RESPID", nRespId))
		oXMLNode:oAddChild(TBIXMLNode():New("RESPONSAVEL", oTable:cValue("NOME")))
		if(nUsuAtual==oTable:nValue("USERID") .or. lAdmin)
			oXMLNode:oAddChild(TBIXMLNode():New("ALTERAR","T"))
		else
			oXMLNode:oAddChild(TBIXMLNode():New("ALTERAR","F"))
		endif
	endif

	nOrgID := ::oOwner():oAncestor("ORGANIZACAO", oTable):nValue("ID")
	oXMLNode:oAddChild(::oOwner():oContext(self, nParentID))

return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC020
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
method nUpdFromXML(oXML, cPath) class TBSC020
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
method nDelFromXML(nID) class TBSC020
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
method nDuplicate(nParentID, nNewParentID, nNewContextID) class TBSC020
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

function _BSC020_Ret()
return