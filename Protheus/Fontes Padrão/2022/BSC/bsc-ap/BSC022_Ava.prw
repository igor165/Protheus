// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC022_Ava.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 09.12.03 | 1645 Leandro Marcelino Santos
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC022_Ava.ch"

/*--------------------------------------------------------------------------------------
@class TBSC022
@entity Avaliação
Histórico de Avaliações
@table BSC022
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "AVALIACAO"
#define TAG_GROUP  "AVALIACOES"
#define TEXT_ENTITY STR0001/*//"Avaliação"*/
#define TEXT_GROUP  STR0002/*//"Avaliações"*/

class TBSC022 from TBITable
	method New() constructor
	method NewBSC022()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)
	
	// registro atual
	method oToXMLNode(nParentID)
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	method xVirtualField(cField, xValue)
	
	method nDuplicate(nParentID, nNewParentID, nNewContextID)
endclass

method New() class TBSC022
	::NewBSC022()
return
method NewBSC022() class TBSC022
	local oField
	
	// Table
	::NewTable("BSC022")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(oField := TBIField():New("NOME",		"C",	60))
	oField:lSensitive(.f.)
	::addField(TBIField():New("DTAVAL",		"D"))
	::addField(TBIField():New("TEXTO",		"M"))
	::addField(TBIField():New("RESPID",		"N"))
	::addField(TBIField():New("TIPOPESSOA",	"C",	1)) //G = Grupo, P = Individual
	
	// Indexes
	::addIndex(TBIIndex():New("BSC022I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC022I02",	{"NOME", "CONTEXTID"}))
	::addIndex(TBIIndex():New("BSC022I03",	{"PARENTID", "ID"},	.t.))
	::addIndex(TBIIndex():New("BSC022I04",	{"DTAVAL"}))
return

// Arvore
method oArvore(nParentID) class TBSC022
	local oXMLArvore, oNode
	
	::SetOrder(4) // Por ordem de data alvo.
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtrar pelo pai.
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
			oAttrib:lSet("ID"		, ::nValue("ID"))
			oAttrib:lSet("NOME"		, alltrim(::cValue(STR0003)))/*//"Nome"*/
			oAttrib:lSet("FEEDBACK"	, 0)
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Limpar filtro
return oXMLArvore

// Lista XML para anexar ao pai (mbrowse).
method oToXMLList(nParentID) class TBSC022
	local oNode, oAttrib, oXMLNode, nInd, nRespId, cTipoPessoa, oTable
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Data
	oAttrib:lSet("TAG000", "DTAVAL")
	oAttrib:lSet("CAB000", STR0004)/*//"Data Avaliação"*/
	oAttrib:lSet("CLA000", BSC_DATE)
	// Nome
	oAttrib:lSet("TAG001", "NOME")
	oAttrib:lSet("CAB001", TEXT_ENTITY)
	oAttrib:lSet("CLA001", BSC_STRING)
	// Responsável
	oAttrib:lSet("TAG002", "RESPID")
	oAttrib:lSet("CAB002", STR0005)/*//"Responsável"*/
	oAttrib:lSet("CLA002", BSC_STRING)
	
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gerar o recheio
	::SetOrder(4) // Por ordem de data avaliação
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai.
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
		oNode:oAddChild(TBIXMLNode():New("RESPID", oTable:cValue("NOME")))
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentID) class TBSC022
	local nID, aFields, nInd, nRespId, cTipoPessoa
	local oTable, oXMLNode := TBIXMLNode():New(TAG_ENTITY)
	local nUsuAtual := ::oOwner():foSecurity:oLoggedUser():nValue("ID")

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		elseif(aFields[nInd][1]=="RESPID")
			nRespId := aFields[nInd][2]
		elseif(aFields[nInd][1] == "TIPOPESSOA")
			cTipoPessoa := aFields[nInd][2]
		endif
		if(aFields[nInd][1]<>"RESPID")
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		endif
	next

	// Virtuais
	if(cTipoPessoa=="G")
		oTable := ::oOwner():oGetTable("PGRUPO")
	else
		oTable := ::oOwner():oGetTable("PESSOA")
	endif
	if(nId==0)
		oTable:lSeek(4, {nUsuAtual})
		oXMLNode:oAddChild(TBIXMLNode():New("RESPID", oTable:nValue("ID")))
	else
		oTable:lSeek(1, {nRespId})
		oXMLNode:oAddChild(TBIXMLNode():New("RESPID", nRespId))
	endif
	oXMLNode:oAddChild(TBIXMLNode():New("RESPONSAVEL", oTable:cValue("NOME"))) //cNomeUsu ???

	// Combos
	oTable := self
	if(nID==0)
		oTable := ::oOwner():oGetTable("INDICADOR")
		oTable:lSeek(1, {nParentID})
	endif	
	oXMLNode:oAddChild(::oOwner():oContext(self, nParentID))

return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC022
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
method nUpdFromXML(oXML, cPath) class TBSC022
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
method nDelFromXML(nID) class TBSC022
	local nStatus := BSC_ST_OK
	
	// Deleta o elemento
	if(::lSeek(1, {nID}))
		if(!::lDelete())
			nStatus := BSC_ST_INUSE
		endif
	else
		nStatus := BSC_ST_BADID
    endif

	// Quando implementar security
	// nStatus := BSC_ST_NORIGHTS
return nStatus

// Duplica os registros filhos de nParentID, colocando-os como filhos de nNewParentID do contexto nNewContextID
method nDuplicate(nParentID, nNewParentID, nNewContextID) class TBSC022
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

function _BSC022_Ava()
return