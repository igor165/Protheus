// ######################################################################################
// Projeto: BSC
// Modulo : Reunioes
// Fonte  : BSC063_Reu.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC063_ReuPau.ch"

/*--------------------------------------------------------------------------------------
@class TBSC063
@entity REUPAU
Retorno sobre andamento da reunião (antes ou após).
@table BSC063
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "REUPAU"
#define TAG_GROUP  "REUPAUS"
#define TEXT_ENTITY STR0001/*//"Pauta"*/
#define TEXT_GROUP  STR0002/*//"Pautas"*/

class TBSC063 from TBITable
	method New() constructor
	method NewBSC063()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)

	// registro atual
	method oToXMLNode()
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	method xVirtualField(cField, xValue)

	method RegraNode(oNode)
endclass

method New() class TBSC063
	::NewBSC063()
return
method NewBSC063() class TBSC063
	local oField

	// Table
	::NewTable("BSC063")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(TBIField():New("NOME",		"C",	20))
	::addField(TBIField():New("ELEMID",		"N"))
	::addField(TBIField():New("DETALHES",	"M"))
	// Virtuais
	oVirtual := TBIField():New("ORG",	"C", 60)
	oVirtual:bGet({|oTable| oTable:xVirtualField("ORGANIZACAO")})
	oVirtual:bSet({|oTable, cValue| oTable:xVirtualField("ORGANIZACAO", cValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("EST",	"C", 60)
	oVirtual:bGet({|oTable| oTable:xVirtualField("ESTRATEGIA")})
	oVirtual:bSet({|oTable, cValue| oTable:xVirtualField("ESTRATEGIA", cValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("ELEMENTO",	"C", 60)
	oVirtual:bGet({|oTable| oTable:xVirtualField("ELEMENTO")})
	oVirtual:bSet({|oTable, cValue| oTable:xVirtualField("ELEMENTO", cValue)})
	::addField(oVirtual)
	// Indexes
	::addIndex(TBIIndex():New("BSC063I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC063I02",	{"NOME", "CONTEXTID"}))
	::addIndex(TBIIndex():New("BSC063I03",	{"PARENTID", "ID"},	.t.))
return

// xVirtualField
method xVirtualField(cField, xValue) class TBSC063
	local oTable, xRet := xValue
	local cElemento := alltrim(::cValue("NOME"))

	if(!empty(cElemento))
		oTable := ::oOwner():oGetTable(cElemento)
		if(oTable:lSeek(1,{::nValue("ELEMID")}))
			if(cField=="ELEMENTO")
				xRet := oTable:cValue("NOME")
			else
				xRet := ::oOwner():oAncestor(cField, oTable):cValue("NOME")
			endif
		endif
	endif
	if(valtype(xRet)=="U")
		xRet := ""
	endif
return xRet

// Arvore
method oArvore(nParentID) class TBSC063
	local oXMLArvore, oNode
	
	::SetOrder(1) // Por ordem de ID
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
			oAttrib:lSet("NOME", alltrim(::cValue(STR0003)))/*//"Elemento"*/
			oAttrib:lSet("FEEDBACK", ::nValue("FEEDBACK"))
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Encerra filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC063
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Tipo de Elemento
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", STR0003)/*//"Elemento" */
	oAttrib:lSet("CLA000", BSC_STRING)
	// Organizacao
	oAttrib:lSet("TAG001", "ORG")
	oAttrib:lSet("CAB001", STR0005)/*//"Organizacao" */
	oAttrib:lSet("CLA001", BSC_STRING)
	// Estrategia
	oAttrib:lSet("TAG002", "EST")
	oAttrib:lSet("CAB002", STR0006)/*//"Estrategia" */
	oAttrib:lSet("CLA002", BSC_STRING)
	// Elemento
	oAttrib:lSet("TAG003", "ELEMENTO")
	oAttrib:lSet("CAB003", STR0003)/*//"Elemento" */
	oAttrib:lSet("CLA003", BSC_STRING)
	// Detalhes
	oAttrib:lSet("TAG004", "DETALHES")
	oAttrib:lSet("CAB004", STR0004)/*//"Detalhes" */
	oAttrib:lSet("CLA004", BSC_STRING)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(2) // Por ordem de data-hora
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro

return oXMLNode

/*Carregar*/
method oToXMLNode(nParentID) class TBSC063
	Local aFields, nInd, nOrgID
	Local oXMLNode := TBIXMLNode():New(TAG_ENTITY)
	Local oReuniao := ::oOwner():oGetTable("REUNIAO")   

	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		 
		if(aFields[nInd][1] == "PARENTID") 
			/*Quando for inclusão de nova pauta recebe o ID da REUNIÃO..*/
			If !(aFields[nInd][2] == 0)          
				/*Quando não for inclusão de nova pauta recupera o PARENTID do PAUTA.*/
				nParentID := aFields[nInd][2]             
			EndIf
		endif	
	next
    
	/*Recupera o ID da ORGANIZACAO da qual a REUNIÃO pertence.*/
	If(oReuniao:lSeek(1,{nParentID}))
		nOrgID := oReuniao:nValue("PARENTID")
	EndIf 
	
	/*Adiciona um node filho, oArvores*/
	oNode := oXMLNode:oAddChild(TBIXMLNode():New("ARVORES"))
	::SavePos()
	oNode:oAddChild(self:oOwner():oArvore(,,,nOrgID))
	::RestPos()

	/*Adiciona Regras para os node da arvore*/
	::RegraNode(oNode)

return oXMLNode

method RegraNode(oNode) class TBSC063
	local oNodeAux, oAtributos, oTable
	local lIsRecord, cEntidade, nEntId, cOwner, nElementos, nI
		                                
	// Guarda quantidade de filhos do node
	nElementos := oNode:nChildCount()
	
    for nI := 1 to nElementos
    	//Guarda o node filho em um node auxiliar
		oNodeAux := oNode:oChildByPos(nI)

		//Guarda atributos do node auxiliar		
		oAtributos := oNodeAux:oAttrib()
		if(valtype(oAtributos)=="O")
			if(valtype(oAtributos:cValue("ID"))!="U")
				//Se existir um atributo ID guarda este valor
				nEntId := oAtributos:nValue("ID")
			endif
			//Verifica se o node e' do tipo Vector ou Record
			lIsRecord := (valtype(oAtributos:cValue("TIPO"))=="U")
		endif        

		// Se o node for do tipo Record, então insere atributos novos
		if(lIsRecord)                          

			cOwner		:= "U"
			cEntidade 	:= oNodeAux:cTagName()

			oTable := ::oOwner():oGetTable(cEntidade)
			//Encontra a organizacao e a estrategia do Elemento e adiciona no Node
			if(cEntidade != 'ARVORE' .and. oTable:lSeek(1,{nEntID}))
				oNodeAux:oAttrib():lSet("ORGNOME", Alltrim(::oOwner():oAncestor("ORGANIZACAO", oTable):cValue("NOME")))
				if(!cEntidade $ 'PESSOA/REUNIAO/ORGANIZACAO')
					oNodeAux:oAttrib():lSet("ESTNOME", Alltrim(::oOwner():oAncestor("ESTRATEGIA", oTable):cValue("NOME")))
				else
					oNodeAux:oAttrib():lSet("ESTNOME"	, "")
			    endif
			else // Se não encontrar regras, adiciona os valores padrões como branco
				oNodeAux:oAttrib():lSet("ORGNOME"	, "")
				oNodeAux:oAttrib():lSet("ESTNOME"	, "")
		    endif
		endif

		//method recursivo, verifica se o node atual possui filhos 
		//para atribuição de regras, assim sucessivamente até verificar toda a árvore
		::RegraNode(oNodeAux)
    next

return


// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC063
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
method nUpdFromXML(oXML, cPath) class TBSC063
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
method nDelFromXML(nID) class TBSC063
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

function _BSC063_ReuPau()
return
