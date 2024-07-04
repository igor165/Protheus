// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC030A_Crd.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC030A_Crd.ch"

/*--------------------------------------------------------------------------------------
@class TBSC030A
@entity Card
Scorecard, cartao de entidade com score, elemento que compoe o dashboard.
@table BSC030A
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "CARD"
#define TAG_GROUP  "CARDS"
#define TEXT_ENTITY STR0001/*//"Cartão"*/
#define TEXT_GROUP  STR0002/*//"Cartões"*/

class TBSC030A from TBITable
	method New() constructor
	method NewBSC030A()

	// data
	data foScoreCard

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)

	// registro atual
	method oToXMLNode()
	method nInsFromXML(oXML, cPath, oDashBoard)
	method nUpdFromXML(oXML, cPath, oDashBoard)
	method xVirtualField(cField, xValue)

	method nDuplicate(nParentID, nNewParentID, nNewContextID, aIndIds)
endclass

method New() class TBSC030A
	::NewBSC030A()
return
method NewBSC030A() class TBSC030A
	local oField, oVirtual
	
	// Table
	::NewTable("BSC030A")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("ENTID",		"N"))	// ID da entidade representada no card
	::addField(TBIField():New("ENTITY",		"C", 20))	// Tipo(nome) da entidade representada no card
	::addField(TBIField():New("CARDX",		"N"))	// Coord dashboard
	::addField(TBIField():New("CARDY",		"N"))	// Coord dashboard
	::addField(TBIField():New("VISIVEL",	"L"))	// Visible dashboard
	oField := TBIField():New("ORDEM",		"N")
	oField:bDefault({|| -1})
	::addField(oField)
	
	// Indexes
	::addIndex(TBIIndex():New("BSC030AI01",	{"ID"},	.t.))
	::addIndex(TBIIndex():New("BSC030AI02",	{"CONTEXTID", "ID"}, .t.))
	::addIndex(TBIIndex():New("BSC030AI03",	{"PARENTID", "ID"},	.t.))

return

// xVirtualField
method xVirtualField(cField, xValue) class TBSC030A
	local oTable, xRet := xValue
	if(valtype(xValue)=="U")
		oTable := ::oOwner():oGetTable("INDICADOR")
		oTable:lSeek(1, {::nValue("ENTID")})
		xRet := oTable:xValue(cField)
	endif
return xRet

// Lista XML para anexar ao pai
method oToXMLList(nParentID, nContextID) class TBSC030A
	local oNode, oAttrib, oXMLNode, oXMLIndicador, nLenIndicador
	local oIndicador, oObjetivo, nInd, nInd1, aBaseIDs := {} 

	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .t.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", BSC_STRING)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Tabela Indicador
	oIndicador := ::oOwner():oGetTable("INDICADOR")
	oObjetivo := ::oOwner():oGetTable("OBJETIVO")

	// Se nao for incluir
	if(nParentID!=0)
		::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
		::lFiltered(.t.)
		::_First()
		
		while(!::lEof())
			// Cria o nó XML "CARD" a partir da Indicador
			oIndicador:lSeek(1, {::nValue("ENTID")})     

			oObjetivo:lSeek(1, {oIndicador:nValue("PARENTID")})

			oNode := oXMLNode:oAddChild(oIndicador:oXMLCard())
			aAdd(aBaseIds, ::nValue("ENTID"))
			// Acrescenta os nós desta tabela
			aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","ENTID","ENTITY"})
			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			next

			oNode:oAddChild(TBIXMLNode():New("PARENTNAME", oObjetivo:cValue("NOME")))

			::_Next()
		end
		::cSQLFilter("") // Encerra filtro
	endif

	// Travo registro zero para trabalho
	if( !::lSeek(1, {0}) )
		while( !::lAppend({ {"ID", 0}, {"PARENTID", 0}, {"CONTEXTID", 0} }) )
			sleep(500)
		end
	endif
	while( !::lLock() )
		sleep(500)
	end
	
	// Varro Indicadores
	oXMLIndicador := oIndicador:oToEntityList("ESTRATEGIA", {nContextID})
	nLenIndicador := oXMLIndicador:nChildCount("INDICADOR")
	for nInd1 := 1 to nLenIndicador
		oNode := oXMLIndicador:oChildByName("INDICADOR", nInd1)
		nID := oNode:oChildByName("ID"):nGetValue()
		if(aScan(aBaseIds, nID)==0)
			// Cria o nó XML "CARD" a partir da Indicador
			oIndicador:lSeek(1, {nID})
		
			oObjetivo:lSeek(1, {oIndicador:nValue("PARENTID")})

			oNode := oXMLNode:oAddChild(oIndicador:oXMLCard())
			// Acrescenta os nós desta tabela
			aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","ENTID","ENTITY"})
			for nInd := 1 to len(aFields)
				if(aFields[nInd][1] $ "ID/ORDEM/CARDX/CARDY/VISIVEL")
					oNode:oChildByName(aFields[nInd][1]):SetValue(aFields[nInd][2])
				else
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
				endif	
			next

			oNode:oAddChild(TBIXMLNode():New("PARENTNAME", oObjetivo:cValue("NOME")))
		endif	
	next
	::lUnlock()

return oXMLNode

// Incluir entidade do server
method nInsFromXML(oXML, cPath, nParentID, nContextID) class TBSC030A
	local oXMLNode, oIndicador, nStatus := BSC_ST_OK
	local aFields := {}, aRegistros := {}
	local nParentID, nContextID, nInd, nInd1, nPos
	private aCards := {}, oXMLInput := oXML
	
	// Encontrar todos cards que chegaram
	if(valtype(oXML)=="O")
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_CARDS"), "_CARD"))!="U")
			aCards := &("oXMLInput:"+cPath+":_CARDS:_CARD")
			if(valtype(aCards)!="A")
				aCards := { aCards }
			endif	

  			for nInd1 := 1 to len(aCards)
				aFields := { {"ENTITY", "INDICADOR"}, {"ENTID", 0}, {"CARDX", 0}, {"CARDY", 0}, {"ORDEM", -1}, {"VISIVEL", .f.} }
				for nInd := 1 to len(aFields)
					cType := ::aFields(aFields[nInd][1]):cType()
					aFields[nInd][2] := xBIConvTo(cType, &("aCards["+cBIStr(nInd1)+"]:_"+aFields[nInd][1]+":TEXT"))
				next
				aAdd(aFields, {"ID", ::nMakeID()})
				aAdd(aFields, {"PARENTID", nParentID})
				aAdd(aFields, {"CONTEXTID", nContextID})
				if(!::lAppend(aFields))
					if(::nLastError()==DBERROR_UNIQUE)
						nStatus := BSC_ST_UNIQUE
					else
						nStatus := BSC_ST_INUSE
					endif
				endif
			next
		endif
	endif	
    
return nStatus

// Atualizar entidade do server
method nUpdFromXML(oXML, cPath, nParentID, nContextID) class TBSC030A
	local nStatus := BSC_ST_OK
	
	// Deleta anteriores
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		if(!::lDelete())
			nStatus := BSC_ST_INUSE
		endif
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
	
	// Insere os novos
	if(nStatus == BSC_ST_OK)
		nStatus := ::nInsFromXML(oXML, cPath, nParentID, nContextID)
	endif	

	// Quando implementar security
	// nStatus := BSC_ST_NORIGHTS
return nStatus

// Duplica os Cards baseado na matriz
// aIndIDs - Contem todo o mapa de ids dos indicadores correspondendo a fonte da alteracao
method nDuplicate(nOldParentId, nNewParentID, nNewContextID, aIndIDs) class TBSC030A
	local nStatus := BSC_ST_OK, aFields, nInd, nID
	local nIndID, nNewIndID
	
	::oOwner():oOltpController():lBeginTransaction()

	for nInd := 1 to len(aIndIDs)
	
		nIndID := aIndIDs[nInd][1]
		nNewIndID := aIndIDs[nInd][2]

		::SetOrder(1) // Por ordem de ID
		::cSQLFilter("ENTID = "+cBIStr(nIndID) + "AND PARENTID = " + cBIStr(nOldParentId)) // Filtra pelo indicador
		::lFiltered(.t.)
		::_First()
		while(!::lEof() .and. nStatus == BSC_ST_OK)
			// Copia temporario
			aFields := ::xRecord(RF_ARRAY, {"ID", "PARENTID", "CONTEXTID", "ENTID"})
			aAdd( aFields, {"ID",  nID := ::nMakeID()} )
			aAdd( aFields, {"PARENTID", nNewParentID} )
			aAdd( aFields, {"CONTEXTID", nNewContextID} )
			aAdd( aFields, {"ENTID", nNewIndID} )
			
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
	 	
	next

	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()
return nStatus           

function _BSC030a_Crd()
return