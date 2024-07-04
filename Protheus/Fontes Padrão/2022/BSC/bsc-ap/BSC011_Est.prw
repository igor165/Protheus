// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC011_Est.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC011_Est.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet->TBITable->TBSC011
Planos estrategicos de medio/longo prazo da organização.
@entity Estratégia
@table BSC011
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "ESTRATEGIA"
#define TAG_GROUP  "ESTRATEGIAS"
#define TEXT_ENTITY STR0001 // "Estratégia"
#define TEXT_GROUP  STR0002 // "Estratégias"

class TBSC011 from TBITable
	method New() constructor
	method NewBSC011()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)
	method oXMLTipo()

	// registro atual
	method oToXMLNode( nParentID)
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	method nExecute(nID, cExecCMD)
	method nUpdProMapEst(nID, oXml) //Atualiza as propriedades sobre o mapa estrategico. 
	method oLstProMapEst(nID, oXml) //Lista as propriedades sobre o mapa estrategico. 
		
	method nDuplicate(nID, nNewParentID, cNewName, lCriarLink, nLinkType)
endclass
	
method New() class TBSC011
	::NewBSC011()
return

method NewBSC011() class TBSC011
	local oField

	// Table
	::NewTable("BSC011")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID", 	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(TBIField():New("DIVISOES",	"N"))
	::addField(oField := TBIField():New("NOME",		"C",	60))
	oField:lSensitive(.f.)
	::addField(TBIField():New("NOMEDIV1",	"C",	255))
	::addField(TBIField():New("NOMEDIV2",	"C",	255))
	::addField(TBIField():New("NOMEDIV3",	"C",	255))
	::addField(TBIField():New("DESCRICAO",	"C",	255))
	::addField(TBIField():New("DATAINI",	"D"))
	::addField(TBIField():New("DATAFIN",	"D"))
	::addField(TBIField():New("BSCSTATUS",	"N"))  // 0 - Em execução.  1 - Parada, manutenção.  2 - Parada, há nova revisão.
	// Indexes
	::addIndex(TBIIndex():New("BSC011I01",	{"ID"}					,.T.))
	::addIndex(TBIIndex():New("BSC011I02",	{"NOME", "PARENTID"}	,.T.))
	::addIndex(TBIIndex():New("BSC011I03",	{"PARENTID", "ID"}		,.T.))
	::addIndex(TBIIndex():New("BSC011I04",	{"PARENTID"}			,.F.))
return

// Árvore
method oArvore(nParentID) class TBSC011
	local oXMLArvore, oNode, oTable, oChild, lAcessaEstrategia, lMostraEst := .f.

	::SetOrder(2) // Alfabetica por nomes.
	::cSqlFilter("PARENTID = "+cBIStr(nParentID)) // Filtrar pelo pai.
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

			lAcessaEstrategia := ::oOwner():foSecurity:lHasAccess("ESTRATEGIA", ::nValue("ID"), "CARREGAR")
			if(lAcessaEstrategia)
				oAttrib := TBIXMLAttrib():New()
				oAttrib:lSet("ID", ::nValue("ID"))
				oAttrib:lSet("NOME", alltrim(::cValue("NOME")))/*//"Nome"*/
				oAttrib:lSet("FEEDBACK", ::nValue("FEEDBACK"))
				oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
				lMostraEst := .t.

				// Children (Perspectivas)
				oTable := ::oOwner():oGetTable("PERSPECTIVA")
				oChild := oTable:oArvore(::nValue("ID"))
				if(valtype(oChild) == "O")
					oNode:oAddChild(oChild)
				endif	
			endif
			::_Next()	
		enddo
	endif	
	::cSQLFilter("") // Limpar filtro
	if(!lMostraEst)
		oXMLArvore := nil
	endif
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC011
	local oNode, oXMLNode, oAttrib, aFields, nInd, lAcessaEstrategia
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", BSC_STRING)
	// Cidade
	oAttrib:lSet("TAG001", "DATAINI")
	oAttrib:lSet("CAB001", STR0004)/*//"Inicio"*/
	oAttrib:lSet("CLA001", BSC_DATE)
	// Estado
	oAttrib:lSet("TAG002", "DATAFIN")
	oAttrib:lSet("CAB002", STR0005)/*//"Final"*/
	oAttrib:lSet("CLA002", BSC_DATE)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(2) // Alfabetica por nomes
	if valtype(nParentID) != "U"
		::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
		::lFiltered(.t.)
	endif
	::_First()
	while(!::lEof())
		// Nao lista o ID 0, de inclusao
		if(::nValue("ID")==0)
			::_Next()
			loop
		endif

		lAcessaEstrategia := ::oOwner():foSecurity:lHasAccess("ESTRATEGIA", ::nValue("ID"), "CARREGAR")

		if(lAcessaEstrategia)
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"CONTEXTID", "DESCRICAO"})
			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			next
		endif
		::_Next()
	end
	if valtype(nParentID) != "U"
		::cSQLFilter("") // Limpar filtro.
	endif
return oXMLNode

// Carregar ou atualizar entidade no client
method oToXMLNode(nParentID) class TBSC011
	local aFields, nInd, nID
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif
	next
	
	// Perspectivas
	oXMLNode:oAddChild( ::oOwner():oGetTable("PERSPECTIVA"):oToXMLList(nID) )
	oXMLNode:oAddChild( ::oOwner():oGetTable("MAPAEST"):oToXMLList(nID) )
	oXMLNode:oAddChild( ::oOwner():oGetTable("DASHBOARD"):oToXMLList(nID) )
	oXMLNode:oAddChild( ::oOwner():oGetTable("FERRAMENTA"):oToXMLList(nID) )
	oXMLNode:oAddChild( ::oOwner():oGetTable("RELATORIO"):oToXMLList(nID) )
	oXMLNode:oAddChild( ::oOwner():oGetTable("GRAPH"):oToXMLList(nID) )
	oXMLNode:oAddChild( ::oOwner():oGetTable("TEMAEST"):oToXMLList(nID) )
	oXMLNode:oAddChild( ::oOwner():oGetTable("DESDOB"):oToXMLList(nID) )
	// Acrescenta lista de Organizações
	oXMLNode:oAddChild(::oOwner():oGetTable("ORGANIZACAO"):oToXMLList())
	oXMLNode:oAddChild(::oXMLTipo() )
	oXMLNode:oAddChild(::oOwner():oContext(self, nParentId))

return oXMLNode
// Tipos de desdobramentos.
method oXMLTipo() class TBSC011
	local oAttrib, oNode, oXMLOutput

	// Atributos.
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai.
	oXMLOutput := TBIXMLNode():New("TIPOLINKS",,oAttrib)
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("TIPOLINK"))
	oNode:oAddChild(TBIXMLNode():New("ID", 1))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0014))	//Compartilhado
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("TIPOLINK"))
	oNode:oAddChild(TBIXMLNode():New("ID", 2))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0015))	//Contributivo

return oXMLOutput

// Inserir nova entidade
method nInsFromXML(oXML, cPath) class TBSC011
	local aFields, nInd, nStatus := BSC_ST_OK
	local nID, oTable
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID","CONTEXTID","DIVISOES","NOMEDIV1","NOMEDIV2","NOMEDIV3"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1]	== "NOME")
			aAdd( aFields, {"NOMEDIV1", aFields[nInd][2]} )
		endif		
	next
	aAdd( aFields, {"ID", nID := ::nMakeID()} )
	aAdd( aFields, {"CONTEXTID", nID} )
	aAdd( aFields, {"NOMEDIV2", ""} )
	aAdd( aFields, {"NOMEDIV3", ""} )

	// Grava
	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := BSC_ST_UNIQUE
		else
			nStatus := BSC_ST_INUSE
		endif
	else
		// Grava perspectivas basicas
		oTable := ::oOwner():oGetTable("PERSPECTIVA")
		oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", nID}, {"CONTEXTID", nID},;
			{"NOME", STR0006},{"DESCRICAO", STR0007},{"ORDEM", 4} })
			/*//"Aprendizado e Crescimento"*/
			/*//"Para alcançarmos nossa visão, como sustentaremos nossa capacidade de mudar e melhorar?"*/
		oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", nID}, {"CONTEXTID", nID},;
			{"NOME", STR0008},;
			{"DESCRICAO", STR0009},;
			{"ORDEM", 3} })
			/*//"Processo Interno"*/
			/*//"Para satisfazermos nossos acionistas e clientes, em que processos de negócios devemos alcançar a excelência?"*/
		oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", nID}, {"CONTEXTID", nID},;
			{"NOME", STR0010},;
			{"DESCRICAO", STR0011},;
			{"ORDEM", 2} })
			/*//"Cliente"*/
			/*//"Para alcançarmos nossa visão, como deveríamos ser vistos pelos nossos clientes?"*/
		oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", nID}, {"CONTEXTID", nID},;
			{"NOME", STR0012},;
			{"DESCRICAO", STR0013},;
			{"ORDEM", 1} })
			/*//"Financeira"*/
			/*//"Para sermos bem sucedidos financeiramente, como deveríamos ser vistos pelos nossos acionistas?"*/
	endif
return nStatus

// Atualizar entidade existente no server
method nUpdFromXML(oXML, cPath) class TBSC011
	local nStatus := BSC_ST_OK,	nID, cSenha, nInd, dDataIni,dDataFin, oIndicador
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY,{"DIVISOES","NOMEDIV1","NOMEDIV2","NOMEDIV3"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
		if(aFields[nInd][1] == "DATAINI")
			dDataIni := aFields[nInd][2]
		endif	
		if(aFields[nInd][1] == "DATAFIN")
			dDataFin := aFields[nInd][2]
		endif	
	next

	// Grava
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
			// Se foi o periodo for modificado verificar valores das planilhas 
			// de todas os indicadores onde forem necessários

			oIndicador := oBSCCore:oGetTable("INDICADOR")

			// Verifica todos os indicadores da estratégia
			oIndicador:SetOrder(1)
			oIndicador:cSQLFilter("CONTEXTID = "+cBIStr(nID)) // Filtra pelo pai
			oIndicador:lFiltered(.t.)
			oIndicador:_First()
			while(!oIndicador:lEof())

				::oOwner():oGetTable("PLANILHA"):nMudaPeriodo(oIndicador:nValue("ID"), dDataIni, dDataFin)
				::oOwner():oGetTable("RPLANILHA"):nMudaPeriodo(oIndicador:nValue("ID"), dDataIni, dDataFin)
				
				// Atualiza tabela de valores da META..
				::oOwner():oGetTable("META"):nMudaPeriodo(oIndicador:nValue("ID"), dDataIni, dDataFin)

				oIndicador:_Next()
			end
			
			oIndicador:cSQLFilter("")
		endif	
	endif

return nStatus

// Excluir entidade do server
// Sempre alerta quanto ao que fazer
method nDelFromXML(nID) class TBSC011
	Local nStatus 		:= BSC_ST_OK 
	Local oPerspectiva 	:= ::oOwner():oGetTable("PERSPECTIVA") 
	Local oDashBoard 	:= ::oOwner():oGetTable("DASHBOARD")  
	Local oDesdobra		:= ::oOwner():oGetTable("DESDOB")
	Local oGrafico		:= ::oOwner():oGetTable("GRAPH")    
	Local oMapa			:= ::oOwner():oGetTable("MAPAEST")  
	Local oTema 		:= ::oOwner():oGetTable("TEMAEST")  
	Local oMapaTema		:= ::oOwner():oGetTable("MAPATEMA")
	
	::oOwner():oOltpController():lBeginTransaction()

	//Remove as PERSPECTIVAS. 
	oPerspectiva:SetOrder(3) 
	While(!oPerspectiva:lEof() .AND. oPerspectiva:nValue("PARENTID") == nID .AND.  nStatus == BSC_ST_OK)
		nStatus := oPerspectiva:nDelFromXML( oPerspectiva:nValue("ID") )
		oPerspectiva:_Next()
	EndDo

	//Remove os DASHBOARDS.
	oDashBoard:SetOrder(3) 
	While(!oDashBoard:lEof() .AND. oDashBoard:nValue("PARENTID") == nID .AND. nStatus == BSC_ST_OK)
		nStatus := oDashBoard:nDelFromXML(oDashBoard:nValue("ID"))
		oDashBoard:_Next()
	EndDo     
	      
	//Remove os DESDOBRAMENTOS.
	oDesdobra:SetOrder(3) 
	While(!oDesdobra:lEof() .AND. oDesdobra:nValue("PARENTID") == nID .AND. nStatus == BSC_ST_OK)
		nStatus := oDesdobra:nDelFromXML(oDesdobra:nValue("ID"))
		oDesdobra:_Next()
	EndDo    
	
	//Remove os GRAFICOS.
	oGrafico:SetOrder(3) 
	While(!oGrafico:lEof() .AND. oGrafico:nValue("PARENTID") == nID .AND. nStatus == BSC_ST_OK)
		nStatus := oGrafico:nDelFromXML(oGrafico:nValue("ID"))
		oGrafico:_Next()
	EndDo 

	//Remove os MAPAS ESTRATÉGICOS.
	oMapa:SetOrder(3) 
	While(!oMapa:lEof() .AND. oMapa:nValue("PARENTID") == nID .AND. nStatus == BSC_ST_OK)
		nStatus := oMapa:nDelFromXML(oMapa:nValue("ID"))
		oMapa:_Next()
	EndDo         

	//Remove os TEMAS ESTRATÉGICOS.
	oTema:SetOrder(2) 
	While(!oTema:lEof() .AND. oTema:nValue("PARENTID") == nID .AND. nStatus == BSC_ST_OK)
		nStatus := oTema:nDelFromXML(oTema:nValue("ID"))
		oTema:_Next()
	EndDo

	//Remove os TEMAS ESTRATÉGICOS.
	oMapaTema:SetOrder(2) 
	While(!oMapaTema:lEof() .AND. oMapaTema:nValue("PARENTID") == nID .AND. nStatus == BSC_ST_OK)
		nStatus := oMapaTema:nDelFromXML(oMapaTema:nValue("ID"))
		oMapaTema:_Next()
	EndDo
                
    //Remove a ESTRATEGIA.
	If(nStatus == BSC_ST_OK)
		If(::lSeek(1, {nID}))
			If(!::lDelete())
				nStatus := BSC_ST_INUSE
			EndIf
		Else
			nStatus := BSC_ST_BADID
		EndIf	
    EndIf

	If(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	EndIf

	::oOwner():oOltpController():lEndTransaction()
return nStatus

//Atualiza as propriedades referente ao mapa estrategico. 
method nUpdProMapEst(nID, oXml) class TBSC011
	local aFields, nInd,nStatus := BSC_ST_OK
	private aMapaProp := oXml
	
	if(::lSeek(1, {nID}))
		aFields := ::xRecord(RF_ARRAY, {"ID","PARENTID","CONTEXTID","FEEDBACK","NOME",;
										"BSCSTATUS","DESCRICAO","DATAINI","DATAFIN",})
	
		// Extrai valores do XML
		for nInd := 1 to len(aFields)
			cType := ::aFields(aFields[nInd][1]):cType()
			aFields[nInd][2] := xBIConvTo(cType, &("aMapaProp:_"+ aFields[nInd][1] + ":TEXT"))
		next
	
		// Grava
		if(!::lUpdate(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif
	endif		
	
return nStatus

//Lista as propriedades referente ao mapa estrategico. 
method oLstProMapEst(nID) class TBSC011 
	local aFields, nInd, oNodeProp
	local oXMLNode := TBIXMLNode():New("MAPAPROPS")

	if(::lSeek(1, {nID}) )
		oNodeProp := oXMLNode:oAddChild(TBIXMLNode():New("MAPAPROP"))
		// Acrescenta os valores ao XML
		aFields := ::xRecord(RF_ARRAY, {"ID","PARENTID","CONTEXTID","FEEDBACK","NOME",;
										"BSCSTATUS","DESCRICAO","DATAINI","DATAFIN",})
		for nInd := 1 to len(aFields)
			oNodeProp:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next         
	endif		

return oXMLNode

// Duplica a estrategia nID, registrando-a filha de nNewParentID
// se nNewParentID não for definido será filha da mesma Organização
// cNewName será o nome da nova estratégia, se for omitido, 
// o novo nome será "DUP_"+nome-da-estrategia-origem"
method nDuplicate(nID, nNewParentID, cNewName, lCriarLink, nLinkType) class TBSC011
	local nStatus := BSC_ST_OK, aFields, nNewID, aObjIDs, aIndIDs,aIndTemas
	
	::oOwner():oOltpController():lBeginTransaction()

	if( ::lSeek(1, {nID}) )
		// Organização
		if( valtype(nNewParentID)!="N" )
			nNewParentID := ::nValue("PARENTID")
		endif
	    
		// Nome
		if(empty(cNewName))
			cNewName := "DUP_"+::cValue("NOME")
		endif
	
		// Copia temporario
		aFields := ::xRecord(RF_ARRAY, {"ID", "PARENTID", "CONTEXTID", "NOME" })
		aAdd( aFields, {"ID",  nNewID := ::nMakeID()} )
		aAdd( aFields, {"PARENTID", nNewParentID} )
		aAdd( aFields, {"CONTEXTID", nNewID} )
		aAdd( aFields, {"NOME", cNewName} )

		// Grava
		::savePos()
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		else
			// Children
			::restPos()
			aObjIDs := {}
			aIndIDs := {}
			aIndTemas:={}
			nStatus := ::oOwner():oGetTable("PERSPECTIVA"):nDuplicate(nID, nNewID, nNewID, @aObjIDs,@aIndIds,@aIndTemas)
			if(nStatus == BSC_ST_OK)
				nStatus := ::oOwner():oGetTable("MAPAEST"):nDuplicate(nID, nNewID, nNewID, aObjIDs,aIndTemas)
			endif
			if(nStatus == BSC_ST_OK)
				nStatus := ::oOwner():oGetTable("DASHBOARD"):nDuplicate(nID, nNewID, nNewID, aIndIds)
			endif
			if(nStatus == BSC_ST_OK .and. lCriarLink)
				nStatus := ::oOwner():oGetTable("DESDOB"):nDuplicate(nID, nNewID, nNewID, aObjIDs, nLinkType)
			endif
			if(nStatus == BSC_ST_OK)
				nStatus := ::oOwner():oGetTable("TEMAEST"):nDuplicate(nID, nNewID, nNewID, aObjIDs)
			endif
		endif
	endif  
	
	
	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()

return nStatus

// Execute
method nExecute(nID, cExecCMD) class TBSC011
	local nStatus := BSC_ST_OK
	local aParms := {}

	if(::lSeek(1, {nID})) // Posiciona no ID informado

		if(::oOwner():foSecurity:lHasAccess("ORGANIZACAO", ::nValue("PARENTID"), "INCLUIR"))
			// 1 - ExecCMD
			aAdd(aParms, cExecCMD)

			// 2 - ID da Estratégia
			aAdd(aParms, ::nValue("ID"))

			// 3 - BscPath da working thread
			aAdd(aParms, ::oOwner():cBscPath())

			// 4 - Setupcard deste usuario
			aAdd(aParms, ::oOwner():foSecurity:fnUserCard)

			// Executando JOB
			StartJob("BSCEstDupJob", GetEnvServer(), .f., aParms)
		else

			nStatus := 	BSC_ST_BADID
		endif

	else

		nStatus := 	BSC_ST_BADID

	endif

return nStatus

// Funcao executa o job
function BSCEstDupJob(aParms)
	local cBscPath, oE, nNewParentId, aToken
	local cExecCMD, nEstID, oLogger, cNewName, nCard, lCriarLink, nLinkType
	public oBSCCore, cBSCErrorMsg := ""

	// Coleta os parametros
	// 1 - ExecCMD
	aToken := aBIToken(aParms[1],";")
	cExecCMD	:= cBIStr(aToken[1])
	nNewParentID := nBiVal(aToken[2])
	lCriarLink := if(upper(aToken[3])='FALSE',.f.,.t.)
	nLinkType := if(len(aToken)>3,aToken[4],1)

	// 2 - ID da Estratégia
	nEstID			:= aParms[2]
	// 3 - BSCPATH da Working THREAD
	cBscPath		:= aParms[3]
	// 4 - SetupCard
	nCard			:= nBIVal(aParms[4])

	oBSCCore := TBSCCore():New(cBscPath)
	ErrorBlock( {|oE| __BSCError(oE)})

	set exclusive off
	set talk off
	set scoreboard off
	set date brit
	set epoch to 1960
	set century on
	set cursor on
	set deleted on

	// Arquivo de log
	oBSCCore:LogInit()
	oBSCCore:Log("Duplicando estratégia...", BSC_LOG_SCRFILE)

	if(oBSCCore:nDBOpen() < 0)
		oBSCCore:Log(cBIMsgTopError(nTopError), BSC_LOG_SCRFILE)
		oBSCCore:Log("  ")
		return
	endif
	
	// Atenticação
	oBSCCore:foSecurity:lSetupCard(nCard)

	// Parametros
	cNewName := cExecCMD
	    
	// Framework
	oEstrategia := oBSCCore:oGetTable("ESTRATEGIA")
	if( oEstrategia:nDuplicate(nEstID, nNewParentID, cNewName, lCriarLink, nLinkType) != BSC_ST_OK)
		oBSCCore:Log("Ocorreu um erro durante a duplicação.", BSC_LOG_SCRFILE)
	endif
	
	// Fim
	oBSCCore:Log("Duplicacao concluída.", BSC_LOG_SCRFILE)

return

function _bsc011_est()
return