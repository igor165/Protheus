// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC041_Map.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC041_Map.ch"

/*--------------------------------------------------------------------------------------
@class TBSC041
@entity MAPAEST
Lista de relações (causa e efeito) do mapa.
@table BSC041
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "MAPAEST"
#define TAG_GROUP  "MAPAESTS"
#define TEXT_ENTITY STR0001/*//"Mapa Estratégico"*/
#define TEXT_GROUP  STR0002/*//"Mapas Estratégicos"*/

class TBSC041 from TBITable
	method New() constructor
	method NewBSC041()

	method oToXMLList(nParentID)
	method oToXMLNode(nParentID)
	method nUpdFromXML(oXML, cPath, nParentID)
	method nDelFromXML(nID)

	method nDuplicate(nOldParentId, nNewParentID, nNewContextID, aObjIDs,aTemaIDs)
	
endclass

method New() class TBSC041
	::NewBSC041()
return
method NewBSC041() class TBSC041
	// Table
	::NewTable("BSC041")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",		"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("SRCID",		"N"))
	::addField(TBIField():New("DESTID",	"N"))
	::addField(TBIField():New("SCRTYPE",	"C",01))
	::addField(TBIField():New("DESTYPE",	"C",01))
	::addField(TBIField():New("LINECTRLX",	"N"))
	::addField(TBIField():New("LINECTRLY",	"N"))
	::addField(TBIField():New("LINETYPE",	"N"))
	
	// Indexes
	::addIndex(TBIIndex():New("BSC041I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC041I02",	{"CONTEXTID"},	.f.))
	::addIndex(TBIIndex():New("BSC041I03",	{"PARENTID", "ID"},	.t.))
	::addIndex(TBIIndex():New("BSC041I04",	{"PARENTID", "SRCID", "DESTID"}, .f.))
	::addIndex(TBIIndex():New("BSC041I05",	{"PARENTID", "DESTID", "SRCID"}, .f.))
	
return

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC041
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
method oToXMLNode(nParentID) class TBSC041
	local oTablePer, oTableObj, oNodePer1, oNodePer2, oNodeObj, dDataAlvo
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY), lParcelada
	local oEstrategia, cNome,oTableTema,oNodeTemas
	local aPessoas := {}

	//Lista de Pessoas
	aPessoas := ::oOwner():aListPessoas(::oOwner():foSecurity:oLoggedUser():nValue("ID"))	

	// Estrategia
	oEstrategia := ::oOwner():oGetTable("ESTRATEGIA")
	oEstrategia:lSeek(1, {nParentID})
	cNome := alltrim(oEstrategia:cValue("NOME"))

	// Mapaest
	oXMLNode:oAddChild(TBIXMLNode():New("ID", nParentID))
	oXMLNode:oAddChild(TBIXMLNode():New("PARENTID", nParentID))
	oXMLNode:oAddChild(TBIXMLNode():New("CONTEXTID", nParentID))
	oXMLNode:oAddChild(TBIXMLNode():New("NOME", cNome))

	//Carrega as proriedades do mapa estrategico.
	oXMLNode:oAddChild(oEstrategia:oLstProMapEst(nParentID))

	//Carrega os dados para o drop down, do tema estrategico.
	oXMLNode:oAddChild(::oOwner():oGetTable("TEMAEST"):oFillCbbTemas(nParentID))
	 	
	//Carrega os temas.
	oTableTema := ::oOwner():oGetTable("MAPATEMA")

	// Perpectivas
	oNodePer1 := oXMLNode:oAddChild(TBIXMLNode():New("PERSPECTIVAS"))
	oTablePer := ::oOwner():oGetTable("PERSPECTIVA")
	oTablePer:SetOrder(4) // Por ordem de perspectiva
	oTablePer:cSQLFilter("PARENTID = " + cBIStr(nParentID)) // Filtra pelo pai
	oTablePer:lFiltered(.t.)
	oTablePer:_First()
	while(!oTablePer:lEof())                              
		if(!oTablePer:lValue("OPERAC"))
			oNodePer2 := oNodePer1:oAddChild(oTablePer:oNodePersp())

			// Objetivos
			oNodeObj := oNodePer2:oAddChild(TBIXMLNode():New("OBJETIVOS"))
			oTableObj := ::oOwner():oGetTable("OBJETIVO")
			oTableObj:cSQLFilter("PARENTID = "+oTablePer:cValue("ID")) // Filtra pelo pai
			oTableObj:lFiltered(.t.)
			oTableObj:_First()

			while(!oTableObj:lEof())
				oNodeObj:oAddChild(oTableObj:oToXMLMapNode(aPessoas))
				oTableObj:_Next()
			enddo

			oTableObj:cSQLFilter("") // Encerra filtro

			//Retornando o no dos temas
			oNodeTemas := oTableTema:oToXMLLoad(oTablePer:nValue("PARENTID"),oTablePer:nValue("ID"))
			
			if(valtype(oNodeTemas)=="O")
				oNodePer2:oAddChild(oNodeTemas)
			endif
		endif
		oTablePer:_Next()
	enddo
	oTablePer:cSQLFilter("") // Encerra filtro

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
	
return oXMLNode

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC041
	local nStatus := BSC_ST_OK, nParentID, nIndTema, nPerpsID, nEstID, nTmpRelID := 0
	local nInd, nInd1, nInd2, aFields, cType, oTable, oTableTema 
	local nPosNewId,nPosType,oEstrategia
	private aPerspectivas, aObjetivos, aTemas, aUpdConnectID := {},aMapaProp
	private oXMLInput := oXML
	
	// Extrai parentid
	nParentID := nBIVal(&("oXMLInput:"+cPath+":_PARENTID:TEXT"))

	// Extrai perspectivas
	if(nStatus == BSC_ST_OK .and. XmlChildCount(&("oXMLInput:"+cPath+":_PERSPECTIVAS"))>0)

		aPerspectivas := &("oXMLInput:"+cPath+":_PERSPECTIVAS:_PERSPECTIVA")
		if(valtype(aPerspectivas)!="A")
			aPerspectivas := { aPerspectivas }
		endif	

		for nInd1 := 1 to len(aPerspectivas)

			// Extrai perspectiva
			oTable := ::oOwner():oGetTable("PERSPECTIVA")
			
			aFields := { {"ID", NIL}, {"HEIGHT", NIL} ,{"BACKCOLOR",NIL}}
			for nInd := 1 to len(aFields)
				cType := oTable:aFields(aFields[nInd][1]):cType()
				aFields[nInd][2] := xBIConvTo(cType, &("aPerspectivas["+cBIStr(nInd1)+"]:_"+aFields[nInd][1]+":TEXT"))
				if(aFields[nInd][1] == "ID")
					nID := aFields[nInd][2]
					nPerpsID := nID
				endif
			next

			// Grava Perspectiva
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

			//Obtendo a Estrategia.
			nEstID := oTable:nValue("PARENTID")
			
			// Extrai objetivos
			if(nStatus == BSC_ST_OK .and. XmlChildCount(&("aPerspectivas["+cBIStr(nInd1)+"]:_OBJETIVOS"))>0)

				oTable := ::oOwner():oGetTable("OBJETIVO")

				aObjetivos := aPerspectivas[nInd1]:_OBJETIVOS:_OBJETIVO
				if(valtype(aObjetivos)!="A")
					aObjetivos := { aObjetivos }
				endif	

				for nInd2 := 1 to len(aObjetivos)
							
					// Extrai objetivo
					aFields := { {"ID", NIL}, { "MAPX", NIL }, {"MAPY", NIL},{"MAPHEIGHT", NIL} ,;
								{"MAPWIDTH", NIL}, {"MAPCOLOR",NIL},{"MAPTYPE",NIL}}
					for nInd := 1 to len(aFields)
						cType := oTable:aFields(aFields[nInd][1]):cType()
						aFields[nInd][2] := xBIConvTo(cType, &("aObjetivos["+cBIStr(nInd2)+"]:_"+aFields[nInd][1]+":TEXT"))
						if(aFields[nInd][1] == "ID")
							nID := aFields[nInd][2]
						endif
					next

					// Grava objetivo
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
			endif

			// Extrai e grava os temas.
			oTableTema := ::oOwner():oGetTable("MAPATEMA")
			if(nStatus == BSC_ST_OK .and. XmlChildCount(&("aPerspectivas["+cBIStr(nInd1)+"]:_MAPATEMAS"))>0)
				aTemas := aPerspectivas[nInd1]:_MAPATEMAS:_MAPATEMA
				if(valtype(aTemas)!="A")
					aTemas := { aTemas }
				endif	
				oTableTema:nUpdFromXML(aTemas,nPerpsID,nEstID,@aUpdConnectID)
			else
				oTableTema:nUpdFromXML({},nPerpsID,nEstID,@aUpdConnectID)
			endif
		next
	endif

	// Extrai relacoes
	if(nStatus == BSC_ST_OK)

		// Excluir relacoes atuais deste mapa
		::cSQLFilter("PARENTID = "+cBIStr(nParentID))
		::lFiltered(.t.)
		::_First()
		while(!::lEof())
			if(!::lDelete())
				nStatus := BSC_ST_INUSE
			endif
			::_Next()
		end
		::cSQLFilter("")

		if  XmlChildCount(&("oXMLInput:"+cPath+":_MAPARELS"))>0
			aRelacoes := &("oXMLInput:"+cPath+":_MAPARELS:_MAPAREL")
			if(valtype(aRelacoes)!="A")
				aRelacoes := { aRelacoes }
			endif	
	
			for nInd1 := 1 to len(aRelacoes)
	
				// Extrai relacao
				aFields := { {"SRCID", NIL}, {"DESTID", NIL}, {"SCRTYPE", NIL}, {"DESTYPE", NIL},;				
							  {"LINECTRLX", NIL}, {"LINECTRLY", NIL} , {"LINETYPE", NIL}  }
							
				for nInd := 1 to len(aFields)
					cType := ::aFields(aFields[nInd][1]):cType()
					if(aFields[nInd][1] == "DESTID")
						aFields[nInd][2] := xBIConvTo(cType, &("aRelacoes["+cBIStr(nInd1)+"]:_"+aFields[nInd][1]+":TEXT"))
						//Se for um tema corrige o ID da conexão se necessario.
						if(xBIConvTo("C", &("aRelacoes["+cBIStr(nInd1)+"]:_DESTYPE:TEXT"))== "T")
							nPosNewId := ascan(aUpdConnectID, {|aVal| aVal[1] == aFields[nInd][2]})
							//Atualiza o ID, recebido do java com o gerado pelo Protheus.
							if nPosNewId > 0
								aFields[nInd][2] := aUpdConnectID[nPosNewId][2]
							endif
						endif
					elseif(aFields[nInd][1] == "SRCID")
						aFields[nInd][2] := xBIConvTo(cType, &("aRelacoes["+cBIStr(nInd1)+"]:_"+aFields[nInd][1]+":TEXT"))
						//Se for um tema corrige o ID da conexão se necessario.
						if(xBIConvTo("C", &("aRelacoes["+cBIStr(nInd1)+"]:_SCRTYPE:TEXT"))== "T")
							nPosNewId := ascan(aUpdConnectID, {|aVal| aVal[1] == aFields[nInd][2]})
							//Atualiza o ID, recebido do java com o gerado pelo Protheus.
							if nPosNewId > 0
								aFields[nInd][2] := aUpdConnectID[nPosNewId][2]
							endif
						endif
					else
						aFields[nInd][2] := xBIConvTo(cType, &("aRelacoes["+cBIStr(nInd1)+"]:_"+aFields[nInd][1]+":TEXT"))
						if(aFields[nInd][1] == "ID")
							nID := aFields[nInd][2]
						endif
					endif					
				next

				aAdd(aFields, {"ID", ::nMakeID()})
				aAdd(aFields, {"PARENTID", nParentID})
				aAdd(aFields, {"CONTEXTID", nParentID})
	
				// Grava Relacao
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
	
	// Estrategia
	oEstrategia := ::oOwner():oGetTable("ESTRATEGIA")

	// Extrai as propriedades do mapa estrategico.
	if(nStatus == BSC_ST_OK .and. XmlChildCount(&("oXMLInput:"+cPath+":_MAPAPROPS"))>0)
		aMapaProp := &("oXMLInput:"+cPath+":_MAPAPROPS:_MAPAPROP")
		oEstrategia:nUpdProMapEst(nEstId,aMapaProp)
	endif		

return nStatus

// Excluir entidade do server
method nDelFromXML(nID) class TBSC041
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

// Duplica o mapa estrategico baseado na matriz
// aObjIDs - Contem todo o mapa de ids dos objetivos correspondendo a fonte da alteracao
method nDuplicate(nOldParentId, nNewParentID, nNewContextID, aObjIDs,aTemaIDs) class TBSC041
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

function _BSC041_Map()
return