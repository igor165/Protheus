// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC012_Pes.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC012_Pes.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet->TBITable->TBSC012
Pessoas a serem responsabilizadas ou cobradas por atividades no BSC.
@entity Pessoa
@table BSC012
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "PESSOA"
#define TAG_GROUP  "PESSOAS"
#define TEXT_ENTITY STR0001/*//"Pessoa"*/
#define TEXT_GROUP  STR0002/*//"Pessoas"*/

class TBSC012 from TBITable
	method New() constructor
	method NewBSC012() 

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)

	// registro atual
	method oToXMLNode(nParentID)
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	method cGetPessoaName(nID)

	method nDuplicate(nParentID, nNewParentID, nNewContextID)

endclass
	
method New() class TBSC012
	::NewBSC012()
return
method NewBSC012() class TBSC012
	local oField

	// Table
	::NewTable("BSC012")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",		"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(TBIField():New("USERID",	"N"))  // Deve ser um ID da tabela de usuarios
	::addField(oField := TBIField():New("NOME"	,"C",50))
	oField:lSensitive(.f.)
	::addField(oField := TBIField():New("CARGO","C",20))
	oField:lSensitive(.f.)
	::addField(TBIField():New("ENDERECO",	"C",	120))
	::addField(TBIField():New("CIDADE",	"C",	20))
	::addField(TBIField():New("ESTADO",	"C",	20))
	::addField(TBIField():New("PAIS",		"C",	20))
	::addField(TBIField():New("FONE",		"C",	20))
	::addField(TBIField():New("RAMAL",		"C",	10))
	::addField(TBIField():New("EMAIL",		"C",	80))
	// Indexes
	::addIndex(TBIIndex():New("BSC012I01",	{"ID"}					,.t.))
	::addIndex(TBIIndex():New("BSC012I02",	{"NOME", "PARENTID"}	,.t.))
	::addIndex(TBIIndex():New("BSC012I03",	{"PARENTID", "ID"}		,.t.))
	::addIndex(TBIIndex():New("BSC012I04",	{"USERID"}				,.f.))
	::addIndex(TBIIndex():New("BSC012I05",	{"PARENTID"}			,.f.))
return

// Árvore.
method oArvore(nParentID) class TBSC012
	local oXMLArvore, oNode
	
	::SetOrder(2) // Alfabetica por nomes
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtrar pelo pai.
	::lFiltered(.t.)
	::_First() // Não filtra organizações
	if(!::lEof())
		// Tag conjunto.
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", 1)
		oAttrib:lSet("TIPO", TAG_GROUP)
		oAttrib:lSet("NOME", TEXT_GROUP)
		oXMLArvore := TBIXMLNode():New(TAG_GROUP,"",oAttrib)
		// Nodes (Nós)
		while(!::lEof())
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", ::nValue("ID"))
			oAttrib:lSet("NOME", alltrim(::cValue("NOME")))
			oAttrib:lSet("FEEDBACK", ::nValue("FEEDBACK"))
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif	
	::cSQLFilter("") // Limpar filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC012
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
	// Cargo
	oAttrib:lSet("TAG001", "CARGO")
	oAttrib:lSet("CAB001", STR0003)/*//"Cargo"*/
	oAttrib:lSet("CLA001", BSC_STRING)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(2) // Alfabetica por nomes
	if(!empty(nParentID))
		::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	else
		::cSQLFilter("ID <> "+cBIStr(0))
	endif
	::lFiltered(.t.)	
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"CONTEXTID","DESCRICAO","ENDERECO","CIDADE","ESTADO","PAIS","USERID","FONE","EMAIL","RAMAL"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Limpar filtro.
return oXMLNode


// Carregar
method oToXMLNode(nParentID) class TBSC012
	local nID, aFields, nInd
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
	next
	

	// Acrescenta combos, listas
	oXMLNode:oAddChild(::oOwner():oGetTable("USUARIO"):oToXMLList())
	oXMLNode:oAddChild(::oOwner():oContext(self, nParentID))
return oXMLNode

// Inserir nova entidade
method nInsFromXML(oXML, cPath) class TBSC012
	local aFields, nInd, cNome, nStatus := BSC_ST_OK
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "NOME")
			cNome := aFields[nInd][2]
		endif	
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
method nUpdFromXML(oXML, cPath) class TBSC012
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

	// Grava
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
method nDelFromXML(nID) class TBSC012
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
method nDuplicate(nParentID, nNewParentID, nNewContextID) class TBSC012
	local nStatus := BSC_ST_OK, aFields, nID
	
	::oOwner():oOltpController():lBeginTransaction()

	::SetOrder(1) // Por ordem de id
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	
	while(!::lEof() .and. nStatus == BSC_ST_OK .and. ::nValue("PARENTID") == nParentID)
		// Copia temporario
		aFields := ::xRecord(RF_ARRAY, {"ID", "PARENTID", "CONTEXTID"})
		aAdd( aFields, {"ID",  nID := ::nMakeID()} )
		aAdd( aFields, {"PARENTID", nNewParentID} )
		aAdd( aFields, {"CONTEXTID", nNewContextID} )
	
		// Grava
		::SavePos()
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif
		::RestPos()
		::_Next()
	enddo

	::cSQLFilter("") // Zera filtro

	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()

return nStatus

method cGetPessoaName(nID) class TBSC012
	local cPessoaName := STR0007 // "Pessoa nao localizada"

	if(::lSeek(1, {nID}))
		cPessoaName := ::cValue("NOME")
	endif

return cPessoaName           

function _bsc012_pes()
return