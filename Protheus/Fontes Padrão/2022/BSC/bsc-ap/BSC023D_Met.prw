// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC023D_Met.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC023D_Met.ch"

/*--------------------------------------------------------------------------------------
@class TBSC023D
@entity Meta
Meta de performance. Alvos est�o atrelados a Indicadores de FCS e divididos ao logo do tempo.
@table BSC023D
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "FCSMETA"
#define TAG_GROUP  "FCSMETAS"
#define TEXT_ENTITY STR0001/*//"Meta"*/
#define TEXT_GROUP  STR0002/*//"Metas"*/

class TBSC023D from TBITable
	method New() constructor
	method NewBSC023D()

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

method New() class TBSC023D
	::NewBSC023D()
return
method NewBSC023D() class TBSC023D
	local oVirtual, oField
	
	// Table
	::NewTable("BSC023D")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(oField := TBIField():New("NOME",		"C",	60))
	oField:lSensitive(.f.)
	::addField(TBIField():New("DESCRICAO",	"C",	255))
	::addField(TBIField():New("DATAALVO",	"D"))
	::addField(TBIField():New("PARCELADA",	"C", 	1))  // L�gico: "T" - verdadeiro ; "F" ou " "
	::addField(TBIField():New("ITEM",		"N"))
	::addField(TBIField():New("ITEM2",		"N"))
	::addField(TBIField():New("AZUL1",		"N", 19, 6))
	::addField(TBIField():New("VERDE",		"N", 19, 6))
	::addField(TBIField():New("AMARELO",	"N", 19, 6))
	::addField(TBIField():New("VERMELHO",	"N", 19, 6))
	::addField(TBIField():New("AVALMEMO",	"M"))
	::addField(TBIField():New("RESPID",		"N"))	// ID de pessoa em cobranca
	::addField(TBIField():New("TIPOPESSOA",	"C",	1)) //G = Grupo, P = Individual
	// Virtual Fields
	oVirtual := TBIField():New("ASCEND",	"L")
	oVirtual:bGet({|oTable| oTable:xVirtualField("ASCEND")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("ASCEND", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("DECIMAIS",	"N")
	oVirtual:bGet({|oTable| oTable:xVirtualField("DECIMAIS")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("DECIMAIS", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("FREQ",	"N")
	oVirtual:bGet({|oTable| oTable:xVirtualField("FREQ")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("FREQ", xValue)})
	::addField(oVirtual)
	// Indexes
	::addIndex(TBIIndex():New("BSC023DI01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC023DI02",	{"NOME", "CONTEXTID"}))
	::addIndex(TBIIndex():New("BSC023DI03",	{"PARENTID", "ID"},	.t.))
	::addIndex(TBIIndex():New("BSC023DI04",	{"PARCELADA", "PARENTID", "DATAALVO"}, .t.))
return

// xVirtualField
method xVirtualField(cField, xValue) class TBSC023D
	local oTable, xRet := xValue
	if(valtype(xValue)=="U")
		oTable := ::oOwner():oGetTable("FCSIND")
		oTable:lSeek(1, {::nValue("PARENTID")})
		xRet := oTable:xValue(cField)
	endif
return xRet

// Arvore
method oArvore(nParentID) class TBSC023D
	local oXMLArvore, oNode
	
	::SetOrder(4) // Por ordem de data alvo
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
method oToXMLList(nParentID) class TBSC023D
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
	// Data Alvo
	oAttrib:lSet("TAG001", "DATAALVO")
	oAttrib:lSet("CAB001", STR0004)/*//"Data Alvo"*/
	oAttrib:lSet("CLA001", BSC_DATE)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(4) // Por ordem de data alvo
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","AZUL","VERDE","AMARELO","VERMELHO","AVALMEMO","RESPID", "TIPOPESSOA"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentID) class TBSC023D
	local nID, aFields, nInd, cTipoPessoa, nRespID
	local oTable, oXMLNode := TBIXMLNode():New(TAG_ENTITY)
	local lVerNumeros, nEstID, oEstrategia

	// Verifica Seguran�a
	lVerNumeros := ::oOwner():foSecurity:lHasParentAccess("FCSMETA", ::nValue("ID"), "NUMEROS")

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY,{"ASCEND","DECIMAIS","FREQ"})
	for nInd := 1 to len(aFields)
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		elseif(	aFields[nInd][1] == "AZUL1" .or.;
				aFields[nInd][1] == "VERDE" .or.;
				aFields[nInd][1] == "AMARELO" .or.;
				aFields[nInd][1] == "VERMELHO" )
			if(valtype(nParentID)!="U") // Somente novo registro
				aFields[nInd][2] := if(lVerNumeros,aFields[nInd][2],0)
			endif
		elseif(aFields[nInd][1] == "RESPID")
			nRespId := aFields[nInd][2]
		elseif(aFields[nInd][1] == "TIPOPESSOA")
			cTipoPessoa := aFields[nInd][2]
		endif
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
	next

	// Virtuais
	if(cTipoPessoa=="G")
		oTable := ::oOwner():oGetTable("PGRUPO")
	else
		oTable := ::oOwner():oGetTable("PESSOA")
	endif
	oTable:lSeek(1, {nRespId})
	oXMLNode:oAddChild(TBIXMLNode():New("RESPONSAVEL", oTable:cValue("NOME")))

	// Combos
	oTable := self
	if(nID==0)
		oTable := ::oOwner():oGetTable("FCSIND")
		oTable:lSeek(1, {nParentID})
	endif	

	oXMLNode:oAddChild(TBIXMLNode():New("ASCEND", oTable:lValue("ASCEND")))
	oXMLNode:oAddChild(TBIXMLNode():New("DECIMAIS", oTable:nValue("DECIMAIS")))
	oXMLNode:oAddChild(TBIXMLNode():New("FREQ", oTable:nValue("FREQ")))

	nEstID := ::oOwner():oAncestor("ESTRATEGIA", oTable):nValue("ID")
	oEstrategia := ::oOwner():oGetTable("ESTRATEGIA")
	oEstrategia:lSeek(1, {nEstID})
	oXMLNode:oAddChild(TBIXMLNode():New("DATAINI", oEstrategia:dValue("DATAINI")))
	oXMLNode:oAddChild(TBIXMLNode():New("DATAFIN", oEstrategia:dValue("DATAFIN")))

	oXMLNode:oAddChild(::oOwner():oContext(self, nParentID))

return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC023D
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
method nUpdFromXML(oXML, cPath) class TBSC023D
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

	// Verifica condi��es de grava��o (append ou update)
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
method nDelFromXML(nID) class TBSC023D
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
method nDuplicate(nParentID, nNewParentID, nNewContextID) class TBSC023D
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
			exit
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

function _BSC023d_Met()
return