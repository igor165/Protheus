// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC041C_TemLoc.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 13.12.04 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC041C_TemLoc.ch"

/*--------------------------------------------------------------------------------------
@class TBSC041C
@entity MAPATEMA
Objeto que representa um tema do mapa estrategico.
@table BSC041C
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "MAPATEMA"
#define TAG_GROUP  "MAPATEMAS"
#define TEXT_ENTITY STR0001/*//"Mapa Estratégico"*/
#define TEXT_GROUP  STR0002/*//"Mapas Estratégicos"*/

class TBSC041C from TBITable
	method New() constructor
	method NewBSC041C()

	method oToXMLList(nParentID)
	method oToXMLLoad(nEstID,nPerspID)
	method oToXMLNode(nEstId,cLoadCMD)
	method nUpdFromXML(aTemas,nPerpsID, nEstId,aUpdConnectID)
	method nDelFromXML(nID)

	method nDuplicate(nParentID, nNewParentID, nNewContextID, aObjIDs,aIndTemas)
	
endclass

method New() class TBSC041C
	::NewBSC041C()
return

method NewBSC041C() class TBSC041C

	// Table
	::NewTable("BSC041C")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID",		   	"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("NOME",		"C",60))
	::addField(TBIField():New("X",			"N"))
	::addField(TBIField():New("Y",			"N"))
	::addField(TBIField():New("WIDTH",		"N"))
	::addField(TBIField():New("HEIGHT",		"N"))
	::addField(TBIField():New("BACKCOLOR",	"N"))
	
	// Indexes
	::addIndex(TBIIndex():New("BSC041CI01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC041CI02",	{"PARENTID","CONTEXTID"},.F.))//Pespectiva + Estrategia
	
return

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC041C

return oXMLNode

method oToXMLNode(nEstId,cLoadCMD) class TBSC041C
	local oXMLNode,nInd,oNodeTema,oXmlIds
	
	::cSQLFilter("CONTEXTID = " + cBIStr(nEstID)) 
	::lFiltered(.t.)
	::_First()
	
	oXMLNode 	:= TBIXMLNode():New("REC_REFRESH")//Para atualizacao dos temas
	oXmlIds		:= oXMLNode:oAddChild(TBIXMLNode():New(TAG_GROUP))
	
	while(!::lEof())
		oNodeTema := oXmlIds:oAddChild(TBIXMLNode():New(TAG_ENTITY))

		// Acrescenta os valores ao XML
		aFields := ::xRecord(RF_ARRAY,{"ID"}) 
		for nInd := 1 to len(aFields)
			oNodeTema:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next         
	
		//Adicao do ID.
		oNodeTema:oAddChild(TBIXMLNode():New("ID",::cValue("ID")))
		
		::_Next()		
	end		

	oMapaEst := ::oOwner():oGetTable("MAPAEST")

	// Relacoes
	oXMLNode:oAddChild(oMapaEst:oToXMLList(nEstId))

	::cSQLFilter("") // Encerra filtro
	
return oXMLNode

//Le os Dados do Banco
method oToXMLLoad(nEstID,nPerspID) class TBSC041C
	local oXMLNode,nInd,oNodeTema
	
	::cSQLFilter("PARENTID = " + cBIStr(nPerspID) + " AND CONTEXTID = " + cBIStr(nEstID)) 
	::lFiltered(.t.)
	::_First()
	
	oXMLNode:= TBIXMLNode():New(TAG_GROUP)

	while(!::lEof())
	
		oNodeTema := TBIXMLNode():New(TAG_ENTITY)
		// Acrescenta os valores ao XML
		aFields := ::xRecord(RF_ARRAY,{"ID"}) 
		for nInd := 1 to len(aFields)
			oNodeTema:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next         
	
		//Adicao do ID.
		oNodeTema:oAddChild(TBIXMLNode():New("ID",::cValue("ID")))
		
		oXMLNode:oAddChild(oNodeTema)
		
		::_Next()		
	end		

	::cSQLFilter("") // Encerra filtro
	
return oXMLNode

//Faz a manutencao dos dados dos temas
method nUpdFromXML(aTemas,nPerpsID, nEstId,aUpdConnectID) class TBSC041C
	local aItemOk := {},cTemaCod,nOldId := 0,cOldId:= "" ,nId := 0
	local nFoundItem,nItemInc, nReg, nStatus := BSC_ST_OK

	Private aFields := ::xRecord(RF_ARRAY), aTemaObj

	oTema_Objetivo := ::oOwner():oGetTable("TEMAOBJETIVO")

	//Por ordem de parent e context
	::SetOrder(2)
	::lSeek(2, {nPerpsID , nEstId })

	while(::nValue("PARENTID") == nPerpsID .and. ::nValue("CONTEXTID") == nEstId)

		if(len(aTemas) > 0)
			nFoundItem := ascan(aTemas, {|x| alltrim(right(x:_ID:TEXT,LEN(x:_ID:TEXT)-1)) == alltrim(::cValue("ID"))})
		else
			nFoundItem := 0
		endif

		if(nFoundItem > 0)
			aadd(aItemOk, nFoundItem)
		endif			

		if nFoundItem == 0
			//Nao encontrou no array remove da base.
			//Remover todos TEMA X OBJETIVOS
			oTema_Objetivo:nDelFromXML(::nValue("ID"))
			if(!::lDelete())
				nStatus := BSC_ST_INUSE
			endif
		else
			//Encontrou no array atualizar.
			//Preenchendo o conteudo do aFields
			for nReg := 1 to len(aFields)
				cType := ::aFields(aFields[nReg][1]):cType()
				if(aFields[nReg][1] == "PARENTID")
					aFields[nReg][2] := nPerpsID
				elseif(aFields[nReg][1] == "CONTEXTID")						
					aFields[nReg][2] := nEstId    
				elseif(aFields[nReg][1] == "ID")						
					cTemaCod := &("aTemas[" + cBIStr(nFoundItem) + "]:_" + aFields[nReg][1] +":TEXT")
					aFields[nReg][2] := val(substr(cTemaCod,2,len(cTemaCod)))                        
					nId	:= aFields[nReg][2]
				else
					aFields[nReg][2] := xBIConvTo(cType, &("aTemas[" + cBIStr(nFoundItem) + "]:_" + aFields[nReg][1] +":TEXT"))
				endif
			next

			if(!::lUpdate(aFields))
				if(::nLastError()==DBERROR_UNIQUE)
					nStatus := BSC_ST_UNIQUE
				else
					nStatus := BSC_ST_INUSE
				endif
				exit
			endif	
			
			//Atualiza TEMA X OBJETIVOS deste tema
			if( XmlChildCount(&("aTemas["+cBIStr(nFoundItem)+"]:_TEMAOBJETIVOS"))>0)
				aTemaObj := aTemas[nFoundItem]:_TEMAOBJETIVOS:_TEMAOBJETIVO
				oTema_Objetivo:nUpdFromXML(nId,nEstId,aTemaObj)
			else
				oTema_Objetivo:nUpdFromXML(nId,nEstId,{})
			endif
		endif

		::_Next()
	end

	//Os que sobraram no array tem que serem adicionados.
	for nItemInc := 1 to len(aTemas)
		nFoundItem := ascan(aItemOk , {|x| x == nItemInc})
		if nFoundItem == 0 
			//Preenchendo o conteudo do aFields
			for nReg := 1 to len(aFields)
				cType := ::aFields(aFields[nReg][1]):cType()
				if(aFields[nReg][1] == "ID")
					//Correcao do ID das relacoes quando for tema
					cOldId =  xBIConvTo("C", &("aTemas[" + cBIStr(nItemInc) + "]:_" + aFields[nReg][1] +":TEXT"))
					nOldId = val(Right(cOldId, len(cOLdId) -1))
					aFields[nReg][2] := ::nMakeID()
					aadd(aUpdConnectID,{nOldId,aFields[nReg][2]})
					nId := aFields[nReg][2]
				elseif(aFields[nReg][1] == "PARENTID")
					aFields[nReg][2] := nPerpsID
				elseif(aFields[nReg][1] == "CONTEXTID")						
					aFields[nReg][2] := nEstId    
				else
					aFields[nReg][2] := xBIConvTo(cType, &("aTemas[" + cBIStr(nItemInc) + "]:_" + aFields[nReg][1] +":TEXT"))	
				endif
			next

			if(!::lAppend(aFields))
				if(::nLastError()==DBERROR_UNIQUE)
					nStatus := BSC_ST_UNIQUE
				else
					nStatus := BSC_ST_INUSE
				endif
				exit
			else
				//Incluir TEMA X OBJETIVOS
				if(XmlChildCount(aTemas[nItemInc]:_TEMAOBJETIVOS) > 0)
					oTema_Objetivo:nInsFromXML(nId,nEstId,aTemas[nItemInc]:_TEMAOBJETIVOS:_TEMAOBJETIVO)
				endif						
			endif	
		endif
	next 

return nStatus

// Excluir entidade do server
method nDelFromXML(nID) class TBSC041C
	local nStatus := BSC_ST_OK
	
	::oOwner():oOltpController():lBeginTransaction()

	// Procura por children (Relacao Tema Objetivo)
	if(nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("TEMAOBJETIVO"):nDelFromXML(nID)
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
method nDuplicate(nParentID, nNewParentID, nNewContextID,aObjIDs,aIndTemas) class TBSC041C
	local nStatus := BSC_ST_OK, aFields, nID,nOldID
	
	::oOwner():oOltpController():lBeginTransaction()

	::SetOrder(1)
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof() .and. nStatus == BSC_ST_OK)
		nOldID := ::nValue("ID")
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
			// Mapa Estratégico
			aAdd(aIndTemas, {nOldID, nID})

			// Children
			::restPos()
			nStatus := ::oOwner():oGetTable("TEMAOBJETIVO"):nDuplicate(nParentID, nID, nNewContextID, aObjIDs)
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

function _BSC041c_TemLoc()
return