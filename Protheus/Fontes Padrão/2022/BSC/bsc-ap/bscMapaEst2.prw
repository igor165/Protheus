// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSCMAPAEST2.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 27.02.07 | 1776 Alexandre Silva
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSCMAPAEST2.ch"

/*--------------------------------------------------------------------------------------
@class TBSCMAPA_EST2
@entity MAPAEST2
Representacao do mapa estrategico modelo 2.
@table Nao existe tabela associada a esta entidade.
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "MAPAEST2"
#define TAG_GROUP  "MAPAESTS2"
#define TEXT_ENTITY STR0001/*//"Mapa Estratégico"*/
#define TEXT_GROUP  STR0002/*//"Mapas Estratégicos"*/

class TBSCMAPA_EST2 from TBITable
	method New() constructor
	method NewBSCMAPA_EST2()

	method oToXMLList(nParentID)
	method oToXMLNode(nParentID)
	method nUpdFromXML(oXML, cPath)
	
endclass

method New() class TBSCMAPA_EST2
	::NewBSCMAPA_EST2()
return

method NewBSCMAPA_EST2() class TBSCMAPA_EST2
	// Table
	::cEntity(TAG_ENTITY)
return

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSCMAPA_EST2
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
method oToXMLNode(nParentID) class TBSCMAPA_EST2
	local oTablePer, oTableObj, oNodePer1, oNodePer2, oNodeObj
	local oXMLNode 	:= TBIXMLNode():New(TAG_ENTITY)
	local aPessoas 	:= {}
	local oCard	   	:= nil
	local oXmlObj  	:= nil
	local dDataAlvo	:= nil
	local lParcelada:= nil	

	//
	oXMLNode:oAddChild(TBIXMLNode():New("ID", nParentID))
	oXMLNode:oAddChild(TBIXMLNode():New("PARENTID", nParentID))
	oXMLNode:oAddChild(TBIXMLNode():New("CONTEXTID", nParentID))

 	dDataAlvo := ::oOwner():xSessionValue("DATAALVO")
	if(valtype(dDataAlvo)=="U")
		dDataAlvo := date()
	endif	     
  
	lParcelada := ::oOwner():xSessionValue("PARCELADA")
	if(empty(lParcelada))
		lParcelada := .f.
	endif	     

	oXMLNode:oAddChild(TBIXMLNode():New("PARCELADA", lParcelada))
	oXMLNode:oAddChild(TBIXMLNode():New("DATAALVO", dDataAlvo))
	
	//Lista de Pessoas
	aPessoas := ::oOwner():aListPessoas(::oOwner():foSecurity:oLoggedUser():nValue("ID"))	
	
	//Filtra todas as perspectivas deste mapa estrategico.
	oNodePer1 := oXMLNode:oAddChild(TBIXMLNode():New("PERSPECTIVAS"))
	oTablePer := ::oOwner():oGetTable("PERSPECTIVA")
	oTablePer:SetOrder(4) // Por ordem de perspectiva.
	oTablePer:cSQLFilter("PARENTID = " + cBIStr(nParentID)) //Filtra pelo pai.
	oTablePer:lFiltered(.t.)
	oTablePer:_First()
	while(! oTablePer:lEof())                              
		if(! oTablePer:lValue("OPERAC"))
			oNodePer2 := oNodePer1:oAddChild(oTablePer:oNodePersp())

			// Objetivos
			oNodeObj := oNodePer2:oAddChild(TBIXMLNode():New("OBJETIVOS"))
			oTableObj:= ::oOwner():oGetTable("OBJETIVO")
			oTableObj:cSQLFilter("PARENTID = "+oTablePer:cValue("ID")) // Filtra pelo pai
			oTableObj:lFiltered(.t.)
			oTableObj:_First()

			while(!oTableObj:lEof())
				oXmlObj  := oTableObj:oToXMLMapNode(aPessoas)
				oCard	:=	oTableObj:oMakeCard(dDataAlvo,lParcelada)				
				oXmlObj:oAddChild(TBIXMLNode():New("FAROL",oCard:FNFEEDBACK))
				oNodeObj:oAddChild(oXmlObj)
				oTableObj:_Next()
			enddo

			oTableObj:cSQLFilter("") // Encerra filtro
		endif
		oTablePer:_Next()
	enddo
	oTablePer:cSQLFilter("") // Encerra filtro
	
return oXMLNode

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSCMAPA_EST2
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

			aFields := {	{"ID", NIL}, {"BACKCOLOR", NIL} ,{"MP2DEGRADE",NIL}, {"MP2HEIGHT",NIL},{"MP2WIDTH",NIL},;
					   		{"MP2X",NIL},{"MP2Y",NIL}, {"MP2TITCOR",NIL},{"MP2FONTE",NIL},{"MP2FONTAM",NIL},{"MP2FONEST",NIL}}
			
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
					aFields := { {"ID", NIL}, { "MP2X", NIL }, {"MP2Y", NIL},{"MP2HEIGHT", NIL} ,;
								{"MP2WIDTH", NIL},{"MP2FONTE",NIL},{"MP2FONTAM",NIL},{"MP2FONEST",NIL},{"MP2FONCOR",NIL}}
								
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
		next
	endif

return nStatus

function _BSCMapaEst2()
return