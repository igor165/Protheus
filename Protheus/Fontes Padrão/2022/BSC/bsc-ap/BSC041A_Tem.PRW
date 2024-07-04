// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC041A_Tem.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 13.12.04 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC041A_Tem.ch"

/*--------------------------------------------------------------------------------------
@class TBSC041A
@entity MAPATEMA
Objeto que representa um tema do mapa estrategico.
@table BSC041A
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "TEMAEST"
#define TAG_GROUP  "TEMASEST"
	
#define TEXT_ENTITY STR0001/*//"Tema estratégico"*/
#define TEXT_GROUP  STR0002/*//"Temas estratégico"*/

class TBSC041A from TBITable
	method New() constructor
	method NewBSC041A()

	// diversos registros
	method oToXMLList(nParentID)
	method oToXMLObjList(nContextID)// Lista os objetivos para anexar ao pai.
	method oFillCbbTemas(nParentID) ////Preencher a drop Down dos temas.
	
	// registro atual
	method oToXMLNode( nParentID)
	method nInsFromXML(oXML, cPath)  // Inclusao do registro.
	method nUpdFromXML(oXML, cPath)  // Alteracao do registro.	
	method nDelFromXML(nID) //Apaga o registro.

	//nDuplicate
	method nDuplicate(nParentID, nNewParentID, nNewContextID, aObjIDs)			
endclass

method New() class TBSC041A
	::NewBSC041A()
return

method NewBSC041A() class TBSC041A

	// Table
	::NewTable("BSC041A")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID",		"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("NOME",		"C",060))
	::addField(TBIField():New("DESCRICAO",	"C",255))
	
	// Indexes
	::addIndex(TBIIndex():New("BSC041AI01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC041AI02",	{"PARENTID", "ID"},	.t.))

return

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC041A
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

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(1) // Por ordem de nome
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()

	aFields := ::xRecord(RF_ARRAY, {"PARENT","CONTEXTID","DESCRICAO"})

	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENT","CONTEXTID","DESCRICAO"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))			
		next

		::_Next()
	end
	::cSQLFilter("") // Encerra filtro

return oXMLNode

method oToXMLNode(nId,cLoadCMD) class TBSC041A
	local aFields, nInd, nContextId
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "CONTEXTID")
			nContextId := aFields[nInd][2]
		endif
	next

	// Acrescenta children
	oXMLNode:oAddChild(::oToXMLObjList(nContextId))	//Adiciona os objetivo.
	oXMLNode:oAddChild(::oOwner():oGetTable("TEMESTOBJ"):oToXMLList(nId))//Adiciona o relacionamento.	

return oXMLNode        

// Lista os objetivos para anexar ao pai
method oToXMLObjList(nContextID) class TBSC041A
	local oNode, oAttrib, oXMLNode, nInd
	local oObjetivo := ::oOwner():oGetTable("OBJETIVO")
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", "OBJETIVO")
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", STR0003)//Objetivos
	oAttrib:lSet("CLA000", BSC_STRING)
	// Gera no principal
	oXMLNode := TBIXMLNode():New("OBJETIVOS",,oAttrib)
	
	// Gera recheio
	oObjetivo:SetOrder(2) // Por ordem de nome
	if nBiVal(nContextID) > 0
		oObjetivo:cSQLFilter("CONTEXTID = "+cBIStr(nContextID)) // Filtra pelo pai
		oObjetivo:lFiltered(.t.)
	endif
	
	oObjetivo:_First()

	while(!oObjetivo:lEof())
		// Nao lista o ID 0, de inclusao
		if(oObjetivo:nValue("ID")==0)
			oObjetivo:_Next()
			loop
		endif			
	
		aFields := oObjetivo:xRecord(RF_ARRAY, {"PARENTID","DESCRICAO"})
		oNode := oXMLNode:oAddChild(TBIXMLNode():New("OBJETIVO"))

		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next

		oObjetivo:_Next()
	end
	oObjetivo:cSQLFilter("") // Encerra filtro
	
return oXMLNode

//Preencher a drop Down dos temas
method oFillCbbTemas(nParentID)  class TBSC041A
	local oNode, oAttrib, oXMLNode, nInd,nId, oTemEstObj, oEstrategia
	local cNomeEst := ""
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()

	// Gera no principal
	oXMLNode := TBIXMLNode():New("CBBTEMASFILTRO",,oAttrib)

	::SetOrder(1) // Por ordem de nome
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()

	//Recuperando o nome da estrategia
	oEstrategia :=	::oOwner():oGetTable("ESTRATEGIA")	
	if(oEstrategia:lSeek(1, {nParentID}))
		cNomeEst := STR0004 + oEstrategia:cValue("NOME")
	endif

    //Tema padrao
	oNode := oXMLNode:oAddChild(TBIXMLNode():New("CBBTEMAFILTRO","",oAttrib))	
	oNode:oAddChild(TBIXMLNode():New("ID", 0))			
	oNode:oAddChild(TBIXMLNode():New("PARENTID", 0))			
	oNode:oAddChild(TBIXMLNode():New("NOME",cNomeEst))			

	oTemEstObj := ::oOwner():oGetTable("TEMESTOBJ")	
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New("CBBTEMAFILTRO","",oAttrib))	
		aFields := ::xRecord(RF_ARRAY, {"PARENT","CONTEXTID","DESCRICAO"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))			
			if(aFields[nInd][1] == "ID")
				nId := aFields[nInd][2]
			endif
		next

		//Adicionando o relacionamento.
		oNode:oAddChild(oTemEstObj:oToXMLList(nId))//Adiciona o relacionamento.	
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro

return oXMLNode                                   

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC041A
	local aFields, nInd, nStatus := BSC_ST_OK
	local oTema_Objetivo,nParentId:=0
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "PARENTID")
			nParentId := aFields[nInd][2]
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
method nUpdFromXML(oXML, cPath) class TBSC041A
	local nStatus := BSC_ST_OK,	nID, nInd,nContextId
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		elseif(aFields[nInd][1] == "CONTEXTID")
			nContextId := aFields[nInd][2]
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
			//Grava a relacao tema estrategico X objetivo.
			oTema_Objetivo := ::oOwner():oGetTable("TEMESTOBJ")
			if(XmlChildCount( &("oXMLInput:"+cPath+":_TEMSESTOBJ") ) > 0)
				aObjetivo := &("oXMLInput:"+cPath+":_TEMSESTOBJ:_TEMESTOBJ")
				oTema_Objetivo:nUpdFromXML(nId,nContextId,aObjetivo)
			else
				oTema_Objetivo:nUpdFromXML(nId,nContextId,{})
			endif
		endif	
	endif

return nStatus

// Excluir entidade do server
method nDelFromXML(nID) class TBSC041A
	local nStatus := BSC_ST_OK
	
	::oOwner():oOltpController():lBeginTransaction()

	// Procura por children (Relacao Tema Indicador)
	if(nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("TEMESTOBJ"):nDelFromXML(nID)
	endif

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
// aObjIDs - Deve ser passado por referencia
method nDuplicate(nParentID, nNewParentID, nNewContextID, aObjIDs) class TBSC041A
	local nStatus := BSC_ST_OK, aFields, nID, nOldId
	
	::oOwner():oOltpController():lBeginTransaction()

	::SetOrder(1)
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof() .and. nStatus == BSC_ST_OK)
		nOldId := ::nValue("ID")
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
		else
			// Children
			::restPos()
			nStatus := ::oOwner():oGetTable("TEMESTOBJ"):nDuplicate(nOldId,nID,nNewContextID, aObjIDs)
			if(nStatus != BSC_ST_OK)			
				exit
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

function _BSC041a_Tem()
return