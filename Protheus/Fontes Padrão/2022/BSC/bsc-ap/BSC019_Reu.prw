// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC019_Tar.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC019_Reu.ch"

/*--------------------------------------------------------------------------------------
@class TBSC019
@entity Reuniao
Reunião associada a inicativa. Cj forma a agenda da iniciativa.
@table BSC019
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "REUNIAO"
#define TAG_GROUP  "REUNIOES"
#define TEXT_ENTITY STR0001/*//"Reunião"*/
#define TEXT_GROUP  STR0002/*//"Reuniões"*/

class TBSC019 from TBITable
	method New() constructor
	method NewBSC019()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)

	// registro atual
	method oToXMLNode(nParentID)
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
endclass

method New() class TBSC019
	::NewBSC019()
return
method NewBSC019() class TBSC019
	// Table
	::NewTable("BSC019")
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(TBIField():New("NOME",		"C",	120))
	::addField(TBIField():New("ASSUNTO",	"C",	160))
	::addField(TBIField():New("DATAR",		"D"))
	::addField(TBIField():New("HORAR",		"C", 	8))
	::addField(TBIField():New("LOCAL",		"C",	80))
	::addField(TBIField():New("ATA",		"M"))
	// Indexes
	::addIndex(TBIIndex():New("BSC019I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC019I02",	{"NOME", "CONTEXTID"},	.t.))
	::addIndex(TBIIndex():New("BSC019I03",	{"PARENTID", "ID"},	.t.))
return

// Arvore
method oArvore(nParentID) class TBSC019
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
			oAttrib:lSet("NOME", alltrim(::cValue("NOME")))
			oAttrib:lSet("FEEDBACK", ::nValue("FEEDBACK"))
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Encerra filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC019
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
	// Assunto
	oAttrib:lSet("TAG001", "ASSUNTO")
	oAttrib:lSet("CAB001", STR0003)/*//"Assunto"*/
	oAttrib:lSet("CLA001", BSC_STRING)
	// Data
	oAttrib:lSet("TAG002", "DATAR")
	oAttrib:lSet("CAB002", STR0004)/*//"Data"*/
	oAttrib:lSet("CLA002", BSC_DATE)
	// Hora
	oAttrib:lSet("TAG003", "HORAR")
	oAttrib:lSet("CAB003", STR0005)/*//"Hora"*/
	oAttrib:lSet("CLA003", BSC_STRING)
	// Local
	oAttrib:lSet("TAG004", "LOCAL")
	oAttrib:lSet("CAB004", STR0006)/*//"Local"*/
	oAttrib:lSet("CLA004", BSC_STRING)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(2) // Por ordem de nome
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","ATA"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentID) class TBSC019
	local nID, nParentID, aFields, nInd, nOrgID
	local oTable, oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
	next

	// Acrescenta combos
	oTable := self
	if(nID==0)
		oTable := ::oOwner():oGetTable("INICIATIVA")
		oTable:lSeek(1, {nParentID})
	endif	
	nOrgID := ::oOwner():oAncestor("ORGANIZACAO", oTable):nValue("ID")
	oXMLNode:oAddChild(::oOwner():oGetTable("PESSOA"):oToXMLList(nOrgID))

	// Acrescenta children
	oXMLNode:oAddChild(::oOwner():oGetTable("REUCOB"):oToXMLList(nID))
	
return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC019
	local aFields, nInd, aReucob, oTable, nStatus := BSC_ST_OK
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
		// Extrai e grava lista de pessoas em cobrança (REUCOBS)
		oTable := ::oOwner():oGetTable("REUCOB")
		if(lBIIsXmlNode(&("oXMLInput:"+cPath+":_REUCOBS"), "_REUCOB"))
			if(valtype(&("oXMLInput:"+cPath+":_REUCOBS:_REUCOB"))=="A")
				for nInd := 1 to len(&("oXMLInput:"+cPath+":_REUCOBS:_REUCOB"))
					aTarDoc := &("oXMLInput:"+cPath+":_REUCOBS:_REUCOB["+cBIStr(nInd)+"]")
					oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
						{"CONTEXTID", ::nValue("CONTEXTID")}, {"PESSOAID", nBIVal(aTarDoc:_ID:TEXT)} })
				next	
			elseif(valtype(&("oXMLInput:"+cPath+":_REUCOBS:_REUCOB"))=="O")
				aTarDoc := &("oXMLInput:"+cPath+":_REUCOBS:_REUCOB")
				oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
					{"CONTEXTID", ::nValue("CONTEXTID")}, {"PESSOAID", nBIVal(aTarDoc:_ID:TEXT)} })
			endif
		endif	
	endif	
return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC019
	local nID, aReucob, oTable, nStatus := BSC_ST_OK, nInd
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
		else
			// Apaga lista de cobranca anterior
			oTable := ::oOwner():oGetTable("REUCOB")
			oTable:cSQLFilter("PARENTID = "+cBIStr(::nValue("ID"))) // Filtra pelo pai
			oTable:lFiltered(.t.)
			oTable:_First()
			while(!oTable:lEof())
				oTable:lDelete()
				oTable:_Next()
			enddo
			oTable:cSQLFilter("") // Encerra filtro	
   		
			// Extrai e grava lista de pessoas em cobrança (REUCOBS)
			if(lBIIsXmlNode(&("oXMLInput:"+cPath+":_REUCOBS"), "_REUCOB"))
				if(valtype(&("oXMLInput:"+cPath+":_REUCOBS:_REUCOB"))=="A")
					for nInd := 1 to len(&("oXMLInput:"+cPath+":_REUCOBS:_REUCOB"))
						aTarDoc := &("oXMLInput:"+cPath+":_REUCOBS:_REUCOB["+cBIStr(nInd)+"]")
						oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
							{"CONTEXTID", ::nValue("CONTEXTID")}, {"PESSOAID", nBIVal(aTarDoc:_ID:TEXT)} })
					next	
				elseif(valtype(&("oXMLInput:"+cPath+":_REUCOBS:_REUCOB"))=="O")
					aTarDoc := &("oXMLInput:"+cPath+":_REUCOBS:_REUCOB")
					oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
						{"CONTEXTID", ::nValue("CONTEXTID")}, {"PESSOAID", nBIVal(aTarDoc:_ID:TEXT)} })
				endif
			endif	
		endif	
	endif
return nStatus

// Excluir entidade do server
method nDelFromXML(nID) class TBSC019
	local nStatus := BSC_ST_OK
	
	// Procura por children (Pessoas)
	oTable := ::oOwner():oGetTable("REUCOB")
	if(oTable:lSoftSeek(3, {nID}))
    	if(oTable:nValue("PARENTID")==nID)
			nStatus := BSC_ST_HASCHILD
    	endif
    endif	

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