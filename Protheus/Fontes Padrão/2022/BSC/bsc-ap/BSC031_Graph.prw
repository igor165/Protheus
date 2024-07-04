// ######################################################################################
// Projeto: BSC
// Modulo : Grafico
// Fonte  : BSC031_Graph.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 04.06.04 | 1776 Alexandre Silva
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC031_Graph.ch"

/*--------------------------------------------------------------------------------------
@class TBSC031
@entity Graph.   
Forme para cadastro dos graficos utilizados no BSC.
@table BSC031
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "GRAPH"
#define TAG_GROUP  "GRAPHS"
#define TEXT_ENTITY STR0001/*//"Grafico"*/
#define TEXT_GROUP  STR0002/*//"Graficos"*/

class TBSC031 from TBITable
	data faXMLGraphObj

	method New() constructor
	method NewBSC031()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)

	// registro atual
	method oToXMLNode(nParentID)   
	method oXMLPosLegenda() //Posicao da legenda  grafico
	method oXMLEstilo() //Estilo do grafico
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	method xVirtualField(cField, xValue)
	method oXMLGraphData()//Carrega os dados do grafico

endclass

method New() class TBSC031
	::NewBSC031()
return

method NewBSC031() class TBSC031
	// Table
	::NewTable("BSC031")
	// Fields
	::addField(TBIField():New("ID"			,	"N"))
	::addField(TBIField():New("PARENTID"	,	"N"))
	::addField(TBIField():New("CONTEXTID"	,	"N"))
	::addField(TBIField():New("NOME"		,	"C",060))

	::addField(TBIField():New("INDICADOID"	,	"N"))//Indicador Selecionado.
	::addField(TBIField():New("IDFREQATUA"	,	"N"))//Frequencia de analise selecionada.
	::addField(TBIField():New("REFERENCIA"	,	"L"))//Indica se deve ser mostrado no grafico os valores de referencia.
	::addField(TBIField():New("META"		,	"L"))//Indica se deve ser mostrado no grafico os valores de referencia.

	::addField(TBIField():New("PERIODODE"	,	"N"))//Periodo para analise
	::addField(TBIField():New("PERIODOATE"	,	"N"))//Periodo para analise

	::addField(TBIField():New("AVALIACAO"	,	"C", 255))
	::addField(TBIField():New("GRAPHDATA"	,	"D"))
	::addField(TBIField():New("HORA"		,	"C"))

	::addField(TBIField():New("XMLGRAPHS"	,	"M"))// Só pode haver 1 unico campo memo

	// Virtual
	oVirtual := TBIField():New("ESTDE",		"D")
	oVirtual:bGet({|oTable| oTable:xVirtualField("ESTDE")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("ESTDE", xValue)})
	::addField(oVirtual)

	oVirtual := TBIField():New("ESTATE",		"D")
	oVirtual:bGet({|oTable| oTable:xVirtualField("ESTATE")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("ESTATE", xValue)})
	::addField(oVirtual)

	// Indexes
	::addIndex(TBIIndex():New("BSC031I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC031I02",	{"NOME", "CONTEXTID"},	.t.))
	::addIndex(TBIIndex():New("BSC031I03",	{"PARENTID", "ID"},	.t.))

	//Arrays
	::faXMLGraphObj := {{"ESTILO","1"},{"CORPORLINHA","T"},{"LINHAXCOL","T"},{"MOSTRALEGENDA","F"},;
						{"POSLEGENDA","2"},{"INDCOLOR","-10037761"},{"REFCOLOR","-9208321"},{"METACOLOR","-11936875"},;
						{"ZOOM","3"},{"METASERIE","F"}}

return

// xVirtualField
method xVirtualField(cField, xValue) class TBSC031
	local oEstrategia, xRet := xValue
	if(valtype(xRet)=="U")
		oEstrategia := ::oOwner():oGetTable("ESTRATEGIA")
		oEstrategia:lSeek(1, {::nValue("CONTEXTID")})
		if(cField=="ESTDE")
			xRet := oEstrategia:dValue("DATAINI")
		elseif(cField=="ESTATE")
			xRet := oEstrategia:dValue("DATAFIN")
		endif
	endif	
return xRet

// Arvore
method oArvore(nParentID) class TBSC031
	local oXMLArvore, oNode
	
	::SetOrder(2) // Por ordem de nome
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
			oAttrib:lSet("NOME", alltrim(::cValue("NOME")))
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Encerra filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC031
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
	::SetOrder(2) // Por ordem de nome
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","XMLGRAPHS","INDICADOID",;
							"IDFREQATUA","META","REFERENCIA","PERIODODE","PERIODOATE","AVALIACAO","HORA"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))			
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentID) class TBSC031
	local aFields, nInd, nID, nContextID,oXMLInput
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY), lParcelada
	local cError := "", cWarning := ""
	
	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		elseif (aFields[nInd][1] == "XMLGRAPHS")
			// Parseia xml in
			if ! empty(aFields[nInd][2])
				oXMLInput := XmlParser(alltrim(aFields[nInd][2]), '_', @cError, @cWarning)
				if empty(cError)
					oXMLNode:oAddChild(::oXMLGraphData(oXMLInput))
				else
					::Log(STR0025, BSC_LOG_SCRFILE) // "Erro no parse do campo XMLGRAPH"				
				endif
			endif
			loop
		elseif (aFields[nInd][1] == "CONTEXTID")
			nContextID := aFields[nInd][2]
		endif	
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
	next

	lParcelada := ::oOwner():xSessionValue("PARCELADA")
	if(empty(lParcelada))
		lParcelada := .f.
	endif	     

	// Acrescenta children                                                              
	oXMLNode:oAddChild(TBIXMLNode():New("PARCELADA", lParcelada))

	// Acrescenta combos
	//Estilo dos graficos
	oXMLNode:oAddChild(::oXMLEstilo())
	//Texto para a posicao da legenda do grafico.
	oXMLNode:oAddChild(::oXMLPosLegenda())
    //Indicadores
	oXMLNode:oAddChild(::oOwner():oGetTable("INDICADOR"):oContextList(nContextID))
	//Frequencia
	oXMLNode:oAddChild(::oOwner():oGetTable("INDICADOR"):oXMLFrequencia())

return oXMLNode

method oXMLGraphData(oXMLGraphData) class TBSC031
local oXMLOutput, oNode, nItem  
private oObj, cTmpRealName, cTmpTextName

oXMLOutput := TBIXMLNode():New("XMLGRAPHS")
oNode 	   := oXMLOutput:oAddChild(TBIXMLNode():New("XMLGRAPH"))
oObj 	   := oXMLGraphData:_XMLGRAPH 

for nItem := 1 to len(::faXMLGraphObj)
	if type("oObj:_"+Alltrim(::faXMLGraphObj[nItem,1])) == "O"
		cTmpRealName := "oObj:_"+Alltrim(::faXMLGraphObj[nItem,1])+":REALNAME"
		cTmpTextName := "oObj:_"+Alltrim(::faXMLGraphObj[nItem,1])+":TEXT"
		oNode:oAddChild(TBIXMLNode():New(&cTmpRealName,&cTmpTextName))
	else
		oNode:oAddChild(TBIXMLNode():New(Alltrim(::faXMLGraphObj[nItem,1]),Alltrim(::faXMLGraphObj[nItem,2])))	
	endif
next nItem

return oXMLOutput


// Posicao da legenda do grafico.
method oXMLPosLegenda() class TBSC031
	local oAttrib, oNode, oXMLOutput
	local nInd, aEstilos:= {}

	aadd(aEstilos,STR0003) //"Superior"
	aadd(aEstilos,STR0004) //"Esquerda"
	aadd(aEstilos,STR0005) //"Direira"
	aadd(aEstilos,STR0006) //"Inferior"

	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("POSLEGENDAS",,oAttrib)
	
	for nInd := 1 to len(aEstilos)
		oNode := oXMLOutput:oAddChild(TBIXMLNode():New("POSLEGENDA"))
		oNode:oAddChild(TBIXMLNode():New("ID", nInd))
		oNode:oAddChild(TBIXMLNode():New("NOME", aEstilos[nInd]))
	next
return oXMLOutput


// Estilo
method oXMLEstilo() class TBSC031
	local oAttrib, oNode, oXMLOutput
	local nInd, aEstilos:= {}

	aadd(aEstilos,STR0007) //"Coluna"
	aadd(aEstilos,STR0008) //"Barra"
	aadd(aEstilos,STR0009) //"Area"
	aadd(aEstilos,STR0010) //"Linha"
	//aadd(aEstilos,STR0011) //"Torta"
	//aadd(aEstilos,STR0012) //"Bolha"
	//aadd(aEstilos,STR0013) //"Dipersão"
	aadd(aEstilos,STR0014) //"HeatMap"
	aadd(aEstilos,STR0015) //"Barra  3D"
	aadd(aEstilos,STR0016) //"Coluna 3D"
	aadd(aEstilos,STR0017) //"Area   3D"
	aadd(aEstilos,STR0018) //"Linha  3D"
	aadd(aEstilos,STR0019) //"HeatMap3D"
    //aadd(aEstilos,STR0020) //"Torta 3D"
	//aadd(aEstilos,STR0021) //"StackBar"
	aadd(aEstilos,STR0022) //"StackColumn"
	aadd(aEstilos,STR0023) //"StackColumn3D"
	aadd(aEstilos,STR0024)	 //"StackBar3D"

	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("ESTILOS",,oAttrib)
	
	for nInd := 1 to len(aEstilos)
		oNode := oXMLOutput:oAddChild(TBIXMLNode():New("ESTILO"))
		oNode:oAddChild(TBIXMLNode():New("ID", nInd))
		oNode:oAddChild(TBIXMLNode():New("NOME", aEstilos[nInd]))
	next
return oXMLOutput

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC031
	local aFields, nInd, nID, nStatus := BSC_ST_OK, nItem
	private oXMLInput := oXML,cRealName, cTextName
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrair valores do XML.
	for nInd := 1 to len(aFields)
		if(aFields[nInd][1]=="XMLGRAPHS")
			cFullPath := "oXMLInput:" + cPath + ":_XMLGRAPHS:_XMLGRAPH:"
			oXMLGraphNode := TBIXMLNode():New("XMLGRAPH")
			for nItem := 1 to len(::faXMLGraphObj)
				cRealName := cFullPath+"_" + Alltrim(::faXMLGraphObj[nItem,1]) + ":REALNAME"
				cTextName := cFullPath+"_" + Alltrim(::faXMLGraphObj[nItem,1]) + ":TEXT"
				oXMLGraphNode:oAddChild(TBIXMLNode():New(&(cRealName),&(cTextName)))			
			next nItem
			aFields[nInd][2] := Alltrim(oXMLGraphNode:cXMLString())
		else
			cType := ::aFields(aFields[nInd][1]):cType()
			aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		endif	
	next
	aAdd( aFields, {"ID", nID := ::nMakeID()} )
	
	// Gravar
	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := BSC_ST_UNIQUE
		else
			nStatus := BSC_ST_INUSE
		endif
	else
		//Gravar os filhos.
	endif	
return nStatus

// Atualizar entidade ja existente.
method nUpdFromXML(oXML, cPath) class TBSC031
	local nStatus := BSC_ST_OK,	nID, nInd, nItem
	local oGraphAttrib, oXMLGraphNode
	local cFullPath	:= ""
	private oXMLInput := oXML,cRealName, cTextName
	
	aFields := ::xRecord(RF_ARRAY)

	// Extrair valores do XML.
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		elseif(aFields[nInd][1]=="XMLGRAPHS")
			cFullPath := "oXMLInput:" + cPath + ":_XMLGRAPHS:_XMLGRAPH:"
			oXMLGraphNode := TBIXMLNode():New("XMLGRAPH")
			for nItem := 1 to len(::faXMLGraphObj)
				cRealName := cFullPath+"_" + Alltrim(::faXMLGraphObj[nItem,1]) + ":REALNAME"
				cTextName := cFullPath+"_" + Alltrim(::faXMLGraphObj[nItem,1]) + ":TEXT"
				oXMLGraphNode:oAddChild(TBIXMLNode():New(&(cRealName),&(cTextName)))			
			next nItem
			aFields[nInd][2] := Alltrim(oXMLGraphNode:cXMLString())
		endif	
	next

	// Verifica condições de gravação (append ou update).
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
			// Gravar os cards chamando nUpdFromXML de CARD
			//Gravar os filhos
			//nStatus := ::oOwner():oGetTable("CARD"):nUpdFromXML(oXML, cPath, ::nValue("ID"), ::nValue("CONTEXTID"))
		endif	
	endif
return nStatus

// Excluir entidade do server
method nDelFromXML(nID) class TBSC031
	local nStatus := BSC_ST_OK
	local oTable
	
	// Deletar os cards chamando nDelFromXML de CARD
	oTable := ::oOwner():oGetTable("CARD")
	oTable:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo pai
	oTable:lFiltered(.t.)
	oTable:_First()
	while(!oTable:lEof())
		if(!oTable:lDelete())
			nStatus := BSC_ST_INUSE
		endif
		oTable:_Next()
	end
	oTable:cSQLFilter("") // Limpar filtro.

	// Deletar o elemento.
	if(nStatus == BSC_ST_OK)
		if(::lSeek(1, {nID}))
			if(!::lDelete())
				nStatus := BSC_ST_INUSE
			endif
		else
			nStatus := BSC_ST_BADID
		endif	
    endif

	// Quando implementar security.
	// nStatus := BSC_ST_NORIGHTS
return nStatus

function _BSC031_Graph()
return