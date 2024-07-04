// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC041D_TemLocObj.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 27.12.04 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC041D_TemLocbj.ch"

/*--------------------------------------------------------------------------------------
@class TBSC041D
@entity MAPATEMA
Objeto que representa um tema do mapa estrategico.
@table BSC041D
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "TEMAOBJETIVO"
#define TAG_GROUP  "TEMAOBJETIVOS"
#define TEXT_ENTITY STR0001/*//"Mapa Estratégico"*/
#define TEXT_GROUP  STR0002/*//"Mapas Estratégicos"*/

class TBSC041D from TBITable
	method New() constructor
	method NewBSC041D()

	method oToXMLList(nParentID)
	method nInsFromXML(nTemaID,nEstrategia,oXML)
	method nUpdFromXML(nTemaID,nEstrategiaID,oXML)
	method nDelFromXML(nTemaID)

	method nDuplicate(nParentID, nNewParentID, nNewContextID, aObjIds)
	
endclass

method New() class TBSC041D
	::NewBSC041D()
return

method NewBSC041D() class TBSC041D

	// Table
	::NewTable("BSC041D")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID",		   	"N"))
	::addField(TBIField():New("PARENTID",	"N"))//Tema
	::addField(TBIField():New("CONTEXTID",	"N"))//Estrategia
	::addField(TBIField():New("OBJETIVOID",	"N"))

	// Indexes
	::addIndex(TBIIndex():New("BSC041DI01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC041DI02",	{"PARENTID","OBJETIVOID"},.f.))
	::addIndex(TBIIndex():New("BSC041DI03",		{"OBJETIVOID"},.f.))
	
return

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC041D

return oXMLNode

//Faz a atualização dos temas gravados
method nUpdFromXML(nTemaID,nEstrategiaID,oXML) class TBSC041D
	local aFields, nStatus := BSC_ST_OK
	local nFoundItem, aItemOk := {} , nItem := 0
	private aTemaObj := oXml

	if(valtype(aTemaObj)!="A")
		aTemaObj := { aTemaObj }
	endif	

	::cSQLFilter("PARENTID = " + cBIStr(nTemaID))
	::lFiltered(.t.)
	::_First()

	while(!::lEof())
		nFoundItem := ascan(aTemaObj,{|x| x:_OBJETIVOID:TEXT == alltrim(::cValue("OBJETIVOID"))})

		if(nFoundItem > 0)
			aadd(aItemOk, nFoundItem)
		endif			
		
		if(nFoundItem == 0)
			//Nao encontrou no XML apaga.
			if(!::lDelete())
				nStatus := BSC_ST_INUSE
				exit							
			endif
		else
			//Encontrou atualiza.
		endif    
		
		::_Next()
	end
	::cSQLFilter("")

	for nItem := 1 to len(aTemaObj)
		nFoundItem := ascan(aItemOk , {|x| x == nItem})
		if nFoundItem == 0
			//Nao esta no array de itemOk Inclui.
			::nInsFromXML(nTemaID,nEstrategiaID,oXml, nItem)
		endif
	next nItem

return nStatus

//Insere a entidade no server
method nInsFromXML(nTemaID,nEstrategia,oXml,nItemInc) class TBSC041D
	local aFields,nInd,nTemas ,nStatus := BSC_ST_OK
	private aTemaObj := oXml

	default nItemInc := 0
	
	if(valtype(aTemaObj)!="A")
		aTemaObj := { aTemaObj }
	endif	

	for nTemas := 1 to len(aTemaObj)
		//Verifica se devo incluir um item especifico.
		if(nItemInc == 0 .or. nTemas == nItemInc)
			aFields := ::xRecord(RF_ARRAY, {"ID","PARENTID","CONTEXTID"})
		
			// Extrai valores do XML
			for nInd := 1 to len(aFields)
				cType := ::aFields(aFields[nInd][1]):cType()
				aFields[nInd][2] := xBIConvTo(cType, &("aTemaObj["+alltrim(str(nTemas))+"]:_"+aFields[nInd][1]+":TEXT"))
			next
	
			aAdd( aFields, {"ID", ::nMakeID()})
			aAdd( aFields, {"PARENTID", nTemaId})
			aAdd( aFields, {"CONTEXTID",nEstrategia})				
			
			// Grava
			if(!::lAppend(aFields))
				if(::nLastError()==DBERROR_UNIQUE)
					nStatus := BSC_ST_UNIQUE
				else
					nStatus := BSC_ST_INUSE
				endif
			endif
		endif
	next nTemas

return nStatus

// Excluir entidade do server
method nDelFromXML(nTemaID) class TBSC041D
	nStatus := BSC_ST_OK

	::cSQLFilter("PARENTID = " + cBIStr(nTemaID))
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		if(!::lDelete())
			nStatus := BSC_ST_INUSE
		endif
		::_Next()
	end
	::cSQLFilter("")

return nStatus


// Duplica os Cards baseado na matriz
// aIndIDs - Contem todo o mapa de ids dos indicadores correspondendo a fonte da alteracao
method nDuplicate(nOldParentId, nNewParentID, nNewContextID, aObjIDs) class TBSC041D
	local nStatus := BSC_ST_OK, nInd, nID, aFields := {}
	local nObjID, nNewObjID
	
	::oOwner():oOltpController():lBeginTransaction()

	::savePos() 
	for nInd := 1 to len(aObjIDs)
	
		nObjID := aObjIDs[nInd][1]
		nNewObjID := aObjIDs[nInd][2]
	
		if(::lSeek(2, {nOldParentId,nObjID}))
			// Copia temporario
			aFields := {}
			nID := ::nMakeID()

			aAdd( aFields, {"ID", nID } )
			aAdd( aFields, {"PARENTID"	, nNewParentID} )
			aAdd( aFields, {"CONTEXTID"	, nNewContextID} )
			aAdd( aFields, {"OBJETIVOID", nNewObjID} )
		
 			// Grava
			if(! ::lAppend(aFields))
				if(::nLastError()==DBERROR_UNIQUE)
					nStatus := BSC_ST_UNIQUE
				else
					nStatus := BSC_ST_INUSE
				endif
				exit
			endif
		endif
	next nInd
	::restPos()	 
	
	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()

	
return nStatus       

function _BSC041d_TemLocObj()
return