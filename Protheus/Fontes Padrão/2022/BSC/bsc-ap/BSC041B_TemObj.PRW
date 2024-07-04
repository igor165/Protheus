// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC041B_TemObj.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 27.12.04 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC041B_TemObj.ch"

/*--------------------------------------------------------------------------------------
@class TBSC041B
@entity MAPATEMA
Objeto que representa um tema do mapa estrategico.
@table BSC041B
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "TEMESTOBJ"
#define TAG_GROUP  "TEMSESTOBJ"
#define TEXT_ENTITY STR0001/*//"Tema estrategico / Objetivo "*/
#define TEXT_GROUP  STR0002/*//"Tema estrategico / Objetivos"*/

class TBSC041B from TBITable
	method New() constructor
	method NewBSC041B()

	//Multiplos registros
	method oToXMLList(nParentID)
	method nInsFromXML(nTemaID,nEstrategia,oXML)
	method nUpdFromXML(nTemaID,nEstrategiaID,oXML)
	method nDelFromXML(nTemaID)

	//nDuplicate
	method nDuplicate(nParentID, nNewParentID, nNewContextID, aObjIds)
	
endclass

method New() class TBSC041B
	::NewBSC041B()
return

method NewBSC041B() class TBSC041B

	// Table
	::NewTable("BSC041B")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID",		"N"))
	::addField(TBIField():New("PARENTID",	"N"))//Tema Estrategico
	::addField(TBIField():New("CONTEXTID",	"N"))//Estrategia
	::addField(TBIField():New("OBJETIVOID","N"))//Id dos Objetivos

	// Indexes
	::addIndex(TBIIndex():New("BSC041BI01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC041BI02",	{"PARENTID","OBJETIVOID"},.f.))
	
return

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC041B
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()

	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(1)
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()

	while(!::lEof())
	
		aFields := ::xRecord(RF_ARRAY, {"ID","PARENT","CONTEXTID","DESCRICAO"})  
		
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1] == "OBJETIVOID")
				oNode:oAddChild(TBIXMLNode():New("ID", aFields[nInd][2]))			
			else
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))			
			endif			

		next

		::_Next()
	end
	::cSQLFilter("") // Encerra filtro

return oXMLNode

//Faz a atualização dos temas gravados
method nUpdFromXML(nTemaID,nEstrategiaID,oXML) class TBSC041B
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
		nFoundItem := ascan(aTemaObj,{|x| x:_ID:TEXT == alltrim(::cValue("OBJETIVOID"))})

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
method nInsFromXML(nTemaID,nEstrategia,oXml,nItemInc) class TBSC041B
	local aFields,nInd,nTemas ,nStatus := BSC_ST_OK
	private aTemaObj := oXml

	default nItemInc := 0
	
	if(valtype(aTemaObj)!="A")
		aTemaObj := { aTemaObj }
	endif	

	for nTemas := 1 to len(aTemaObj)
		//Verifica se devo incluir um item especifico.
		if(nItemInc == 0 .or. nTemas == nItemInc)
			aFields := ::xRecord(RF_ARRAY, {"OBJETIVOID","PARENTID","CONTEXTID"})
		
			// Extrai valores do XML
			for nInd := 1 to len(aFields)
				cType := ::aFields(aFields[nInd][1]):cType()
				aFields[nInd][2] := xBIConvTo(cType, &("aTemaObj["+alltrim(str(nTemas))+"]:_"+aFields[nInd][1]+":TEXT"))
				if(aFields[nInd][1] == "ID")			
					aAdd( aFields, {"OBJETIVOID", aFields[nInd][2]})
					aFields[nInd][2] := ::nMakeID()
				endif
			next
	
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
method nDelFromXML(nTemaID) class TBSC041B
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
method nDuplicate(nOldParentId, nNewParentID, nNewContextID, aObjIDs) class TBSC041B
	local nStatus := BSC_ST_OK, nInd, nID, aFields := {}
	local nObjID, nNewObjID
	
	::oOwner():oOltpController():lBeginTransaction()

	::SetOrder(2) // Por ordem de SRCID
	::cSQLFilter("PARENTID = "+ cBIStr(nOldParentId) )
					 
	::lFiltered(.t.)
	::_First()
	while(!::lEof() .and. nStatus == BSC_ST_OK)
		nSrcId := ::nValue("OBJETIVOID")

		nPosId := ascan(aObjIDs , {|x| x[1] == nSrcId})
		nNewObjID := aObjIDs[nPosId][2]			

		// Copia temporario
		aFields := {}
		nID := ::nMakeID()

		aAdd( aFields, {"ID", nID } )
		aAdd( aFields, {"PARENTID"	, nNewParentID} )
		aAdd( aFields, {"CONTEXTID"	, nNewContextID} )
		aAdd( aFields, {"OBJETIVOID", nNewObjID} )

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

	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()
	
return nStatus            

function _BSC041b_TemObj()
return