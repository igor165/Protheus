// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC046_MapObj.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 06.07.05 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC046_Map.ch"

/*--------------------------------------------------------------------------------------
@class TBSC046
@entity MAPAOBJ
Lista de relações Objetivos -> FCS -> Processos/Sequência
@table BSC046
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "MAPAOBJ"
#define TAG_GROUP  "MAPAOBJS"
#define TEXT_ENTITY STR0001/*//"Mapa de Objetivos"*/
#define TEXT_GROUP  STR0002/*//"Mapas de Objetivos"*/

class TBSC046 from TBITable
	method New() constructor
	method NewBSC046()

	method oToXMLList(nParentID)
	method oToXMLNode(nParentID)
	method nUpdFromXML(oXML, cPath, nParentID)
	method nDelFromXML(nID)

	method nDuplicate(nOldParentId, nNewParentID, nNewContextID, aObjIDs)
	
endclass

method New() class TBSC046
	::NewBSC046()
return
method NewBSC046() class TBSC046
	// Table
	::NewTable("BSC046")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",		"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	
	// Indexes
	::addIndex(TBIIndex():New("BSC046I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC046I02",	{"CONTEXTID"},	.f.))
	::addIndex(TBIIndex():New("BSC046I03",	{"PARENTID", "ID"},	.t.))
	
return

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC046
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", "MAPAREL")
	oAttrib:lSet("RETORNA", .f.)
	// Gera no principal
	oXMLNode := TBIXMLNode():New("MAPARELS",,oAttrib)
	
	// Gera recheio
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New("MAPAREL"))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID", "CONTEXTID"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro

return oXMLNode

// Carregar
method oToXMLNode(nParentID) class TBSC046
	local oFCS, dDataAlvo
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY), lParcelada
	local oObjetivo, oNode
	local aPessoas := {}

	//Lista de Pessoas
	aPessoas := ::oOwner():aListPessoas(::oOwner():foSecurity:oLoggedUser():nValue("ID"))	

	// Objetivo
	oObjetivo := ::oOwner():oGetTable("OBJETIVO")
	oObjetivo:lSeek(1, {nParentID})

	// MAPAOBJ
	oXMLNode:oAddChild(TBIXMLNode():New("ID", oObjetivo:nValue("ID")))
	oXMLNode:oAddChild(TBIXMLNode():New("PARENTID", oObjetivo:nValue("PARENTID")))
	oXMLNode:oAddChild(TBIXMLNode():New("CONTEXTID", oObjetivo:nValue("CONTEXTID")))
	oXMLNode:oAddChild(TBIXMLNode():New("NOME", oObjetivo:cValue("NOME")))
	oXMLNode:oAddChild(TBIXMLNode():New("RETORNA", .f.))

	oNode := oXMLNode:oAddChild(TBIXMLNode():New("OBJETIVOS"))
	oNode:oAddChild(oObjetivo:oToXMLMapNode(aPessoas))

	// FCS
	oNode := oXMLNode:oAddChild(TBIXMLNode():New("FCSS"))
	oFCS := ::oOwner():oGetTable("FCS")
	oFCS:SetOrder(2) //ordem de nome de FCS
	oFCS:cSqlFilter("PARENTID = " + cBIStr(nParentID)) //filtra pelo pai - Objetivo
	oFCS:lFiltered(.t.)
	oFCS:_First()
	while(!oFCS:lEOF())
		oNode:oAddChild(oFCS:oToXMLMapNode())
		oFCS:_Next()
	enddo
	oFCS:cSqlFilter("")

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

	// Relacoes
	oXMLNode:oAddChild(::oToXMLList(nParentID))
    oXMLNode:oAddChild(::oOwner():oContext(oObjetivo, nParentID))

return oXMLNode

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC046
	local nStatus := BSC_ST_OK, nParentID, nPerpsID, nEstID, nTmpRelID := 0
	local nInd, nInd1, nInd2, aFields, cType, oTable
	local nPosNewId,nPosType,oFcs
	private aObjetivos, aFcss, aUpdConnectID := {},aMapaProp
	private oXMLInput := oXML
	
	// Extrai parentid
	nParentID := nBIVal(&("oXMLInput:"+cPath+":_PARENTID:TEXT"))

	if(nStatus == BSC_ST_OK .and. XmlChildCount(&("oXMLInput:"+cPath+":_FCSS"))>0)
		oTable := ::oOwner():oGetTable("FCS")
		aFcss := &("oXMLInput:"+cPath+":_FCSS:_FCS")
        if(valtype(aFcss)=="A")
			for nInd1 := 1 to len(aFcss)
				// Extrai o Fcs
				aFields := { {"ID", NIL}, { "MAPX", NIL }, {"MAPY", NIL}, {"MAPCOLOR", NIL}}
				for nInd := 1 to len(aFields)
					cType := oTable:aFields(aFields[nInd][1]):cType()
					aFields[nInd][2] := xBIConvTo(cType, &("aFcss["+cBIStr(nInd1)+"]:_"+aFields[nInd][1]+":TEXT"))
					if(aFields[nInd][1] == "ID")
						nID := aFields[nInd][2]
					endif
				next
				// Grava Fcs
				if(!oTable:lSeek(1, {nID}))
					nStatus := BSC_ST_BADID
				else
					if(!oTable:lUpdate(aFields))
						if(oTable:nLastError()==DBERROR_UNIQUE)
							nStatus := BSC_ST_UNIQUE
						else
							nStatus := BSC_ST_INUSE
						endif
					endif	
				endif
			next
		elseif(valtype(aFcss)=="O")
			aFields := { {"ID", NIL}, { "MAPX", NIL }, {"MAPY", NIL}, {"MAPCOLOR", NIL}}
			for nInd := 1 to len(aFields)
				cType := oTable:aFields(aFields[nInd][1]):cType()
				aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_FCSS:_FCS:_"+aFields[nInd][1]+":TEXT"))
				if(aFields[nInd][1] == "ID")
					nID := aFields[nInd][2]
				endif
			next
		
			// Grava Fcs
			if(!oTable:lSeek(1, {nID}))
				nStatus := BSC_ST_BADID
			else
				if(!oTable:lUpdate(aFields))
					if(oTable:nLastError()==DBERROR_UNIQUE)
						nStatus := BSC_ST_UNIQUE
					else
						nStatus := BSC_ST_INUSE
					endif
				endif	
			endif
		endif
	endif

return nStatus

// Excluir entidade do server
method nDelFromXML(nID) class TBSC046
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

return nStatus

// Duplica o mapa estrategico baseado na matriz
// aObjIDs - Contem todo o mapa de ids dos Fcss correspondendo a fonte da alteracao
method nDuplicate(nOldParentId, nNewParentID, nNewContextID, aObjIDs) class TBSC046
	local nStatus := BSC_ST_OK, aFields, nInd, nID, nSrcId, nDesID
	local nObjID, nNewSrcID, nNewDesID, nPosId 
	
	::oOwner():oOltpController():lBeginTransaction()

	::SetOrder(3) // Por ordem de SRCID
	::cSQLFilter("PARENTID = "+ cBIStr(nOldParentId) )
					 
	::lFiltered(.t.)
	::_First()
	while(!::lEof() .and. nStatus == BSC_ST_OK)
		nSrcId := ::nValue("SRCID")
		nDesID := ::nValue("DESTID")
		
		//Verifica a conexao de oriem		
		if alltrim(::cValue("SCRTYPE"))=="T"
			nPosId := ascan(aTemaIDs , {|x| x[1] == nSrcId})
			nNewSrcID := aTemaIDs[nPosId][2]
		else
			nPosId := ascan(aObjIDs , {|x| x[1] == nSrcId})
			nNewSrcID := aObjIDs[nPosId][2]			
		endif

		//Verifica a conexao de destino.
		if alltrim(::cValue("DESTYPE"))=="T"
			nPosId := ascan(aTemaIDs , {|x| x[1] == nDesId})
			nNewDesID := aTemaIDs[nPosId][2]
		else
			nPosId := ascan(aObjIDs , {|x| x[1] == nDesId})
			nNewDesID := aObjIDs[nPosId][2]			
		endif

		// Copia temporario
		aFields := ::xRecord(RF_ARRAY, {"ID", "PARENTID", "CONTEXTID", "SRCID","DESTID"})
		aAdd( aFields, {"ID",  nID := ::nMakeID()} )
		aAdd( aFields, {"PARENTID", nNewParentID} )
		aAdd( aFields, {"CONTEXTID", nNewContextID} )
		aAdd( aFields, {"SRCID"	, nNewSrcID} )
		aAdd( aFields, {"DESTID", nNewDesID} )

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

function _BSC046_MapObj()
return