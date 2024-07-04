// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC030_Dsb.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC030_Dsb.ch"

/*--------------------------------------------------------------------------------------
@class TBSC030
@entity DashBoard
Painel de instrumentos cuztomizado do BSC.
@table BSC030
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "DASHBOARD"
#define TAG_GROUP  "DASHBOARDS"
#define TEXT_ENTITY STR0001/*//"Painel de Instrumentos"*/
#define TEXT_GROUP  STR0002/*//"Painéis de Instrumentos"*/

class TBSC030 from TBITable
	method New() constructor
	method NewBSC030()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)

	// registro atual
	method oToXMLNode(nParentID)
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)

	method nDuplicate(nParentID, nNewParentID, nNewContextID, aIndIds)

endclass

method New() class TBSC030
	::NewBSC030()
return
method NewBSC030() class TBSC030
	local oField
	// Table
	::NewTable("BSC030")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(oField := TBIField():New("NOME",		"C",	60))
	oField:lSensitive(.f.)
	::addField(TBIField():New("ORGANIZADO",	"L"))
	::addField(TBIField():New("DESCRICAO",	"C",	255))
	::addField(TBIField():New("NOTAS",		"M"))
	// Indexes
	::addIndex(TBIIndex():New("BSC030I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC030I02",	{"NOME", "CONTEXTID"},	.t.))
	::addIndex(TBIIndex():New("BSC030I03",	{"PARENTID", "ID"},	.t.))
return

// Arvore
method oArvore(nParentID) class TBSC030
	local oXMLArvore, oNode
	
	::SetOrder(2) // Por ordem de nome.
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai.
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
	::cSQLFilter("") // Limpar filtro.
return oXMLArvore

// Lista XML para anexar ao pai.
method oToXMLList(nParentID) class TBSC030
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
	// Gerar nó principal.
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(2) // Por ordem de nome.
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtrar pelo pai.
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","NOTAS"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Limpar filtro.
return oXMLNode

// Carregar
method oToXMLNode(nContextID) class TBSC030
	local aFields, nInd, nID, dDataAlvo, lParcelada, nPosId
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	nPosId := aScan(aFields, {|x| x[1] == "ID"})
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		elseif(aFields[nInd][1] == "CONTEXTID")
			if(nBIVal(nContextID)==0 .or. aFields[nPosId][2] > 0)
				nContextID := aFields[nInd][2]
			endif
		endif	
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
	oXMLNode:oAddChild(TBIXMLNode():New("PARCELADA", lParcelada))
	oXMLNode:oAddChild(TBIXMLNode():New("DATAALVO", dDataAlvo))
	oXMLNode:oAddChild(::oOwner():oGetTable("CARD"):oToXMLList(nID, nContextID))

return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC030
	local aFields, nInd, nID, nStatus := BSC_ST_OK
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrair valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
	next
	aAdd( aFields, {"ID", nID := ::nMakeID()} )
	
	// Gravar
	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := BSC_ST_UNIQUE
		else
			nStatus := BSC_ST_INUSE
		endif
	else
		// Gravar os cards chamando nInsFromXML de CARD
		nStatus := ::oOwner():oGetTable("CARD"):nInsFromXML(oXML, cPath, ::nValue("ID"), ::nValue("CONTEXTID"))
	endif	
return nStatus

// Atualizar entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC030
	local nStatus := BSC_ST_OK,	nID, nInd
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY)

	// Extrair valores do XML
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
		else
			// Gravar os cards chamando nUpdFromXML de CARD
			nStatus := ::oOwner():oGetTable("CARD"):nUpdFromXML(oXML, cPath, ::nValue("ID"), ::nValue("CONTEXTID"))
		endif	
	endif
return nStatus

// Excluir entidade do server
method nDelFromXML(nID) class TBSC030
	local nStatus := BSC_ST_OK
	local oTableChild
	
	::oOwner():oOltpController():lBeginTransaction()

	// Deletar os cards chamando nDelFromXML de CARD
	oTableChild := ::oOwner():oGetTable("CARD")
	oTableChild:SetOrder(3) // Por ordem de ParentId
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo paI
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		if(!oTableChild:lDelete())
			nStatus := BSC_ST_INUSE
		endif
		oTableChild:_Next()
	enddo
	oTableChild:cSQLFilter("") // Limpa o filtro

	// Deleta o elemento
	if(nStatus == BSC_ST_OK)
		if(::lSeek(1, {nID}))
			if(!::lDelete())
				nStatus := BSC_ST_INUSE
			endif
		else
			nStatus := BSC_ST_BADID
		endif	
    endif

	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()
return nStatus

// Duplica os registros filhos de nParentID, colocando-os como filhos de nNewParentID do contexto nNewContextID
method nDuplicate(nParentID, nNewParentID, nNewContextID, aIndIds) class TBSC030
	local nStatus := BSC_ST_OK, aFields, nID, nOldId
	
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
		else
			// Children
			::restPos()
			nOldId := ::nValue("ID")

			nStatus := ::oOwner():oGetTable("CARD"):nDuplicate(nOldID, nId, nNewContextID, aIndIds)
		endif

		::_Next()
	enddo
	::cSQLFilter("") // Zera filtro

	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()
return nStatus          

function _BSC0030_Dsb()
return