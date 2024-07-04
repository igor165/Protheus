// ######################################################################################
// Projeto: BSC
// Modulo : Estrategia - Desdobramento
// Fonte  : BSC011A_DESDOB.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 07.12.04 | 0739 Aline Corrêa do Vale
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC011A_DESDOB.ch"

/*--------------------------------------------------------------------------------------
@class TBSC011A
@entity Desdobramento
Lista de Desdobramentos de estratégia.
@table BSC011A
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "DESDOB"
#define TAG_GROUP  "DESDOBS"
#define TEXT_ENTITY STR0001/*//"Desdobramento de Estratégia"*/
#define TEXT_GROUP  STR0002/*//"Desdobramentos de Estratégia"*/

class TBSC011A from TBITable
	method New() constructor
	method NewBSC011A()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)
	method oXMLTipo()
	method oToEntityList(cEntity, aIDs)

	// registro atual
	method oToXMLNode(nParentID)
	method nInsFromXML(nID)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(oXML, cPath)
	method xVirtualField(cField, xValue)
	method nDuplicate(nParentID, nNewParentID, nNewContextID, aObjIDs, nLinkType)
endclass

method New() class TBSC011A
	::NewBSC011A()
return
method NewBSC011A() class TBSC011A
	// Table
	::NewTable("BSC011A")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("ORIGEMID",	"N"))
	::addField(TBIField():New("DESTINOID",	"N"))
	::addField(TBIField():New("NOME",		"C", 255))
	::addField(TBIField():New("ENTIDADE",	"C", 20))
	::addField(TBIField():New("TIPODES",	"N"))
	// Virtuais
	oVirtual := TBIField():New("LINKTYPE",	"C", 15)
	oVirtual:bGet({|oTable| oTable:xVirtualField("LINKTYPE")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("LINKTYPE", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("ESTORIGEM",	"C", 50)
	oVirtual:bGet({|oTable| oTable:xVirtualField("ESTORIGEM")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("ESTORIGEM", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("ORIGEM",	"C", 50)
	oVirtual:bGet({|oTable| oTable:xVirtualField("ORIGEM")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("ORIGEM", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("ORGDESTINO",	"C", 50)
	oVirtual:bGet({|oTable| oTable:xVirtualField("ORGDESTINO")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("ORGDESTINO", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("ESTDESTINO",	"C", 50)
	oVirtual:bGet({|oTable| oTable:xVirtualField("ESTDESTINO")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("ESTDESTINO", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("ORGID",	"N")
	oVirtual:bGet({|oTable| oTable:xVirtualField("ORGID")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("ORGID", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("ESTID",	"N")
	oVirtual:bGet({|oTable| oTable:xVirtualField("ESTID")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("ESTID", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("DESTINO",	"C", 50)
	oVirtual:bGet({|oTable| oTable:xVirtualField("DESTINO")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("DESTINO", xValue)})
	::addField(oVirtual)

	// Indexes
	::addIndex(TBIIndex():New("BSC011AI01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC011AI02",	{"CONTEXTID"},	.f.))
	::addIndex(TBIIndex():New("BSC011AI03",	{"PARENTID", "ID"},  .t.))
	::addIndex(TBIIndex():New("BSC011AI04",	{"ORIGEMID", "DESTINOID"}, .f.))
	::addIndex(TBIIndex():New("BSC011AI05",	{"DESTINOID", "ORIGEMID"}, .f.))
return

// xVirtualField
method xVirtualField(cField, xValue) class TBSC011A
	local oTable, xRet := xValue, nTipo

	if(valtype(xValue)=="U")
		if(cField=="ESTORIGEM")
			oTable := ::oOwner():oGetTable("OBJETIVO") //alltrim(::cValue("ENTIDADE")))
			oTable:lSeek(1, {::nValue("ORIGEMID")})
			xRet := ::oOwner():oAncestor("ESTRATEGIA", oTable):cValue("NOME")
		
		elseif(cField=="ORGDESTINO")
			oTable := ::oOwner():oGetTable("OBJETIVO")  //alltrim(::cValue("ENTIDADE")))
			oTable:lSeek(1, {::nValue("DESTINOID")})
			xRet := ::oOwner():oAncestor("ORGANIZACAO", oTable):cValue("NOME")
		elseif(cField=="ESTID")
			oTable := ::oOwner():oGetTable("OBJETIVO") //alltrim(::cValue("ENTIDADE")))
			oTable:lSeek(1, {::nValue("DESTINOID")})
			xRet := ::oOwner():oAncestor("ESTRATEGIA", oTable):cValue("ID")
		
		elseif(cField=="ORGID")
			oTable := ::oOwner():oGetTable("OBJETIVO")  //alltrim(::cValue("ENTIDADE")))
			oTable:lSeek(1, {::nValue("DESTINOID")})
			xRet := ::oOwner():oAncestor("ORGANIZACAO", oTable):cValue("ID")
	
		elseif(cField=="ESTDESTINO")
			oTable := ::oOwner():oGetTable("OBJETIVO")  //alltrim(::cValue("ENTIDADE")))
			oTable:lSeek(1, {::nValue("DESTINOID")})
			xRet := ::oOwner():oAncestor("ESTRATEGIA", oTable):cValue("NOME")
	
		elseif(cField=="ORIGEM")
			oTable := ::oOwner():oGetTable("OBJETIVO")  //alltrim(::cValue("ENTIDADE")))
			oTable:lSeek(1, {::nValue("ORIGEMID")})
			xRet := oTable:cValue("NOME")
	
		elseif(cField=="DESTINO")
			oTable := ::oOwner():oGetTable("OBJETIVO")  //alltrim(::cValue("ENTIDADE")))
			oTable:lSeek(1, {::nValue("DESTINOID")})
			xRet := oTable:cValue("NOME")
		elseif(cField=="LINKTYPE")
			nTipo := ::nValue("TIPODES")
			do case
				case(nTipo=1)
					xRet := STR0009
				case(nTipo=2)
					xRet := STR0010
				otherwise
					xRet := ""
			endcase
		else
			xRet := ""
		endif
	endif
	
return xRet

// Arvore
method oArvore(nParentID) class TBSC011A
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
method oToXMLList(nParentID) class TBSC011A
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome Entidade Origem
	oAttrib:lSet("TAG000", "ESTORIGEM")
	oAttrib:lSet("CAB000", STR0007 + " "+STR0004) //Entidade Origem
	oAttrib:lSet("CLA000", BSC_STRING)
	// Nome Entidade Origem
	oAttrib:lSet("TAG001", "ORIGEM")
	oAttrib:lSet("CAB001", STR0004) //Entidade Origem
	oAttrib:lSet("CLA001", BSC_STRING)
	// Nome da Organizacao Destino
	oAttrib:lSet("TAG002", "ORGDESTINO")
	oAttrib:lSet("CAB002", STR0008) //Organizacao
	oAttrib:lSet("CLA002", BSC_STRING)
	// Nome da Estrategia Entidade
	oAttrib:lSet("TAG003", "ESTDESTINO")
	oAttrib:lSet("CAB003", STR0007) //Estrategia
	oAttrib:lSet("CLA003", BSC_STRING)
	// Nome Entidade Destino
	oAttrib:lSet("TAG004", "DESTINO")
	oAttrib:lSet("CAB004", STR0005) //Entidade Destino
	oAttrib:lSet("CLA004", BSC_STRING)
	// Tipo
	oAttrib:lSet("TAG005", "LINKTYPE")
	oAttrib:lSet("CAB005", STR0006) //Tipo de Link
	oAttrib:lSet("CLA005", BSC_STRING) //0=Compartilhada 1=Contributiva 
	// Descricao
	oAttrib:lSet("TAG006", "NOME")
	oAttrib:lSet("CAB006", STR0003) //Descricao
	oAttrib:lSet("CLA006", BSC_STRING)

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		// Nao lista o ID 0, de inclusao
		if(::nValue("ID")==0)
			::_Next()
			loop
		endif			
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY )
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentID) class TBSC011A
	local aFields, nInd
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
	next
	// depois filtrar a organizacao para a estrategia
	oXMLNode:oAddChild( ::oOwner():oGetTable("ORGANIZACAO"):oToXMLList() )
	oXMLNode:oAddChild( ::oOwner():oGetTable("ESTRATEGIA"):oToXMLList() )
	oXMLNode:oAddChild( ::oOwner():oGetTable("OBJETIVO"):oToXMLList(nil, .f.) )
	oXMLNode:oAddChild( ::oXMLTipo() )
	oXMLNode:oAddChild(::oOwner():oContext(self, nParentID))

return oXMLNode

// Tipos de desdobramentos
method oXMLTipo() class TBSC011A
	local oAttrib, oNode, oXMLOutput

	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("TIPOLINKS",,oAttrib)
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("TIPOLINK"))
	oNode:oAddChild(TBIXMLNode():New("ID", 1))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0009))	//Compartilhado
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("TIPOLINK"))
	oNode:oAddChild(TBIXMLNode():New("ID", 2))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0010))	//Contributivo

return oXMLOutput

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC011A
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
method nUpdFromXML(oXML, cPath) class TBSC011A
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
method nDelFromXML(nID) class TBSC011A
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

// Lista XML para anexar ao pai, de todos os Objetivos desdobrados a partir de um Objetivo
method oToEntityList(cEntity, aIDs) class TBSC011A
	local oNode, oAttrib, oXMLNode
	local cIDs, nInd
	
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
	cIDs := cBIConcatWSep(",", aIDs) // Converter os IDs em cadeia para sql
	cIDs := strtran(cIDs, '"', "'")
	::SetOrder(2) // Por ordem de nome
	::cSQLFilter("DESTINOID IN ("+cIDs+")") // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","ID","TIPODES","ENTIDADE"})
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1]=="ORIGEMID")
				oNode:oAddChild(TBIXMLNode():New("ID", aFields[nInd][2]))
			else
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			endif
		next
		//oNode:oAddChild(TBIXMLNode():New("FEEDBACK", ::nFeedBack()))
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Criar link dos registros filhos de nParentID, colocando-os como filhos de nNewParentID do contexto nNewContextID
// aObjIDs é recebido com os Id antigos e novos para criar link
method nDuplicate(nParentID, nNewParentID, nNewContextID, aObjIDs, nLinkType) class TBSC011A
	local nStatus := BSC_ST_OK, aFields, nID, i
	
	::oOwner():oOltpController():lBeginTransaction()

	for i:=1 to len(aObjIDs)
		// Copia temporario
		aFields := ::xRecord(RF_ARRAY, {"ID", "PARENTID", "CONTEXTID","ORIGEMID","DESTINOID","TIPODES","ENTIDADE"})
		aAdd( aFields, {"ID",  nID := ::nMakeID()} )
		aAdd( aFields, {"PARENTID", nNewParentID} )
		aAdd( aFields, {"CONTEXTID", nNewContextID} )
		aAdd( aFields, {"ORIGEMID", aObjIDs[i][2]} ) //new Id
		aAdd( aFields, {"DESTINOID", aObjIDs[i][1]} ) //old Id
		aAdd( aFields, {"TIPODES", nLinkType} )
		aAdd( aFields, {"ENTIDADE", "OBJETIVO"} )

		// Grava
		::savePos()
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
			break
		else
			// Children
			::restPos()
		endif

	next

	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()

return nStatus

function _BSC011A_Desdob()
return