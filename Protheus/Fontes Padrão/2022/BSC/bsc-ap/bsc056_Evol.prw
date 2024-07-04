// ######################################################################################
// Projeto: BSC
// Modulo : Retolatórios
// Fonte  : bsc056_Ind.prw
// Utiliz : Gera o html do relatorio de evolucao de Indicadores.
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.06 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC056_Evol.ch"

/*------------------------------------------------------------------------------------
@class TBSC056
@entity RELEVOL
Evolução de indicadores
@table BSC056
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "RELEVOL"
#define TAG_GROUP  "RELEVOLS"
#define TEXT_ENTITY STR0014 /*//"Evolução de Indicador"*/
#define TEXT_GROUP  STR0003 /*//"Evolução de Indicadores"*/

//Posicoes no array de parametros (aParms)
#define PATH			01//BSCPATH da Working THREAD
#define ARQNOME   		02//Nome do relatorio em disco
#define NOME			03//Nome
#define DESCRICAO		04//Descrição
#define IMPDESC			05//Imprime Descrição?
#define IMPREF  		06//Imprime Referência?
#define PERSPDE			07//Da perspectiva
#define PERSPATE		08//Ate perspectiva
#define OBJDE			09//Do objetivo	
#define OBJATE			10//Ate objetivo
#define INDDE			11//Do indicador
#define INDATE			12//Ate indocador
#define ID				13//ID do relatorio
#define PARENTID		14//Parent ID do relatorio (Estrategia)
#define DATADE			15//Da data
#define DATAATE			16//Ate a data

#define USUALOGADO		17//Usuario logado?
#define PATHSITE		18//Endereco do site.

#define ORDEMOBJ		19//Ordenação Objetivos
#define ORDEMIND		20//Ordenação Indicadores

class TBSC056 from TBITable
	//Estrategia
	data oEstrategia
	
	method New() constructor
	method NewBSC056()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)
	method BSCRelEvolucao(aParms)

	//registro atual
	method oToXMLNode(nParentID)
	method nUpdFromXML(oXML, cPath)
	method oToXMLOrgList(nParentID)	
	method oToXMLEstList(nParentID)	
	method oToXMLPerList(nParentID)	
	method oToXMLTemList(nParentID) 
	method oToXMLObjList(nParentID)	
	method oToXMLIndList(nParentID)	

	// executar 
	method nExecute(nID, cExecCMD)

endclass

method New() class TBSC056
	::NewBSC056()
return
method NewBSC056() class TBSC056
	
	// Table
	::NewTable("BSC056")
	::cEntity(TAG_ENTITY)

	::addField(TBIField():New("ID",		"N"))
	::addField(TBIField():New("NOME",		"C",60))
	::addField(TBIField():New("DESCRICAO",	"C",255))
	// Fields

	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("PERSPDE",	"N"))
	::addField(TBIField():New("PERSPATE",	"N"))
	::addField(TBIField():New("OBJDE", 		"N"))
	::addField(TBIField():New("OBJATE",		"N"))
	::addField(TBIField():New("INDDE",		"N"))
	::addField(TBIField():New("INDATE",		"N"))
	::addField(TBIField():New("DATADE",		"D"))
	::addField(TBIField():New("DATAATE",	"D"))

	::addField(TBIField():New("IMPREF"		,"C",01))
	::addField(TBIField():New("IMPDESC"		,"C",01)) 

	::addField(TBIField():New("ORDEMOBJ",	"N")) //1-Crescente, 2-Decrescente
	::addField(TBIField():New("ORDEMIND",	"N")) //1-Crescente, 2-Decrescente

	// Indexes
	::addIndex(TBIIndex():New("BSC056I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC056I02",	{"NOME", "CONTEXTID"}))
	::addIndex(TBIIndex():New("BSC056I03",	{"PARENTID", "ID"}))

return

// Arvore
method oArvore(nParentID) class TBSC056
	local oXMLArvore, oNode
	
	::SetOrder(2) // Por ordem de Nome
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
method oToXMLList(nParentID) class TBSC056
	local aFields, oNode, oAttrib, oXMLNode, nInd
	
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
	::SetOrder(2) // Por ordem de Nome
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","IMPDESC"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentID) class TBSC056
	local aFields, nInd, nStatus := BSC_ST_OK, nOrganiza:=0
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)
	local oXMLOutput := nil    

	::oEstrategia  := ::oOwner():oGetTable("ESTRATEGIA")
	//Posiciona na estrategia
	if(::oEstrategia:lSeek(1,{nParentID}))
		nOrganiza := ::oEstrategia:nValue("PARENTID")
	endif
	
	::SetOrder(1) // Por ordem de ID
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	if(::lEof())
		// Inseri registro
		if(!::lAppend({ {"ID", ::nMakeID()}, {"CONTEXTID", nParentID}, {"PARENTID", nParentID} }))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif	
	endif

	if nStatus == BSC_ST_OK
		// Acrescenta os valores ao XML
		aFields := ::xRecord(RF_ARRAY)
		for nInd := 1 to len(aFields)
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			if(aFields[nInd][1] == "ID")
				nID := aFields[nInd][2]
			endif	
		next
	endif
	::cSQLFilter("") // Filtra pelo pai
	
	//Dados para as combos de:
	oXMLNode:oAddChild(::oToXMLPerList(nParentID))//Perspectiva
	oXMLNode:oAddChild(::oToXMLObjList(nParentID))//Objetivo 
	oXMLNode:oAddChild(::oToXMLIndList(nParentID))//Indicador  

	// Tag pai
	oXMLOutput := TBIXMLNode():New("ORDENSOBJ")

	// "1-Crescente"
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("ORDEM"))
	oNode:oAddChild(TBIXMLNode():New("ID", 1))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0026))/*//"1-Crescente"*/

	// "2-Decrescente"
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("ORDEM"))
	oNode:oAddChild(TBIXMLNode():New("ID", 2))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0027))/*//"2-Decrescente"/*/

	oXMLNode:oAddChild(oXMLOutput)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("ORDENSIND")

	// "1-Crescente"
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("ORDEM"))
	oNode:oAddChild(TBIXMLNode():New("ID", 1))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0026))/*//"1-Crescente"*/

	// "2-Decrescente"
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("ORDEM"))
	oNode:oAddChild(TBIXMLNode():New("ID", 2))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0027))/*//"2-Decrescente"/*/

	oXMLNode:oAddChild(oXMLOutput)
	
return oXMLNode

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC056
	local nStatus := BSC_ST_OK,	nParentID, nInd
	private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			nParentID := aFields[nInd][2]
		endif	
	next

	// Verifica condições de gravação (append ou update)
	::SetOrder(1) // Por ordem de ID
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	if(::lEof())
		// Inseri registro
		if(!::lAppend({ {"ID", ::nMakeID()}, {"CONTEXTID", nParentID}, {"PARENTID", nParentID} }))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif	
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

// Execute      
method nExecute(nID, cExecCMD) class TBSC056
	local nStatus := BSC_ST_OK
	local aParms := {}
	local cPathSite	:= left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))
	oEstrategia 	:= oBSCCore:oGetTable("ESTRATEGIA")
	
	if(::lSeek(1, {nID}) .and. oEstrategia:lSeek(1,{nID})  ) // Posiciona no ID informado

		aAdd(aParms, ::oOwner():cBscPath()) 	// 01 - BSCPATH da Working THREAD
		aAdd(aParms, alltrim(cExecCMD))			// 02 - Nome do relatoriem disco.
		aAdd(aParms, alltrim(::cValue("NOME")))	// 03 - Nome
		aAdd(aParms, ::cValue("DESCRICAO"))		// 04 - Descrição
		aAdd(aParms, ::cValue("IMPDESC"))		// 05 - Imprime Descrição?
		aAdd(aParms, ::cValue("IMPREF"))  		// 06 - Imprime tabela referência?
		aAdd(aParms, ::nValue("PERSPDE"))		// 07 - Da perspectiva
		aAdd(aParms, ::nValue("PERSPATE"))		// 08 - Ate perspectiva
		aAdd(aParms, ::nValue("OBJDE"))			// 09 - Do objetivo	
		aAdd(aParms, ::nValue("OBJATE"))		// 10 - Ate objetivo
		aAdd(aParms, ::nValue("INDDE"))			// 11 - Do indicador
		aAdd(aParms, ::nValue("INDATE"))		// 12 - Ate indicador
		aAdd(aParms, ::nValue("ID"))			// 13 - ID do Relatório
		aAdd(aParms, oEstrategia:nValue("ID"))	// 14 - Parent ID do relatorio (Estrategia)
		aAdd(aParms, ::dValue("DATADE"))		// 15 - Da data
		aAdd(aParms, ::dValue("DATAATE"))		// 16 - Até a data
		aAdd(aParms, ::oOwner():foSecurity:fnUserCard)// 17 - Usuario logado?
		aAdd(aParms, strtran(cPathSite,"\","/"))//18 - Diretorio do site.		

		aAdd(aParms, ::nValue("ORDEMOBJ"))		//19 - Ordem de objetivos
		
		aAdd(aParms, ::nValue("ORDEMIND"))		//20 - Ordem de indicadores

		// Executando JOB
		::BSCRelEvolucao(aParms)
		
	else

		nStatus := 	BSC_ST_BADID

	endif

return nStatus
      
//Lista as organizacoes
method oToXMLOrgList(nParentID) class TBSC056
	local oOrganizacao := ::oOwner():oGetTable("ORGANIZACAO")
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()

	// Tipo
	oAttrib:lSet("TIPO", "ORGANIZACAO")
	oAttrib:lSet("RETORNA", .f.)

	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", "Organizacao")
	oAttrib:lSet("CLA000", BSC_STRING)

	// Gera no principal
	oXMLNode := TBIXMLNode():New("ORGANIZACOES",,oAttrib)
	
	//Localizando a organizacao
	if(::oEstrategia:lSeek(1,{nParentID}) .and. oOrganizacao:lSeek(1,{::oEstrategia:nValue("PARENTID")}))	
		// Gera recheio
		oNode := oXMLNode:oAddChild(TBIXMLNode():New("ORGANIZACAO"))
		aFields := oOrganizacao:xRecord(RF_ARRAY, {"DESCRICAO","MISSAO","VISAO","NOTAS","QUALIDADE","VALORES","ENDERECO","FONE","EMAIL","PAGINA"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
	endif
	
return oXMLNode

//Lista das estrategias
method oToXMLEstList(nParentID) class TBSC056
	local oNode, oXMLNode, oAttrib, aFields, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", "ESTRATEGIA")
	oAttrib:lSet("RETORNA", .f.)

	// Gera no principal
	oXMLNode := TBIXMLNode():New("ESTRATEGIAS",,oAttrib)

	if(::oEstrategia:lSeek(1,{nParentID}))
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::oEstrategia:xRecord(RF_ARRAY, {"CONTEXTID", "DESCRICAO"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
	endif
                   
return oXMLNode

//Lista das perspectivas
method oToXMLPerList(nParentID) class TBSC056
	local oNode, oAttrib, oXMLNode, nInd
	local oPerspectiva  := ::oOwner():oGetTable("PERSPECTIVA")	

	// Colunas
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("TIPO", "PERSPECTIVA")	// Tipo
	// Gera no principal
	oXMLNode := TBIXMLNode():New("PERSPECTIVAS",,oAttrib)
	
	// Gera recheio
	oPerspectiva:SetOrder(1) // Por ordem de perspectiva
	oPerspectiva:cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	oPerspectiva:lFiltered(.t.)
	oPerspectiva:_First()
	while(!oPerspectiva:lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New("PERSPECTIVA"))
		aFields := oPerspectiva:xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","HEIGHT","BACKCOLOR"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		oPerspectiva:_Next()
	end
	oPerspectiva:cSQLFilter("") // Encerra filtro

return oXMLNode

//Lista dos temas
method oToXMLTemList(nParentID) class TBSC056

	local oTema	:= ::oOwner():oGetTable("TEMAEST")		

return oTema:oToXMLList(nParentID)

//Listar todos os objetivos
method oToXMLObjList(nContextId) class TBSC056
	local oNode, oAttrib, oXMLNode, nind
	local oObjetivo  := ::oOwner():oGetTable("OBJETIVO")		
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("TIPO", "OBJETIVO")// Tipo
	oAttrib:lSet("RETORNA", .f.)
	
	// Gera no principal
	oXMLNode := TBIXMLNode():New("OBJETIVOS",,oAttrib)
	
	oObjetivo:SetOrder(1) // Por ordem de id
	oObjetivo:cSQLFilter("CONTEXTID = "+cBIStr(nContextId)) // Filtra pelo pai
	oObjetivo:lFiltered(.t.)
	oObjetivo:_First()
	while(!oObjetivo:lEof())
		// Nao lista o ID 0, de inclusao
		if(oObjetivo:nValue("ID")==0)
			oObjetivo:_Next()
			loop
		endif			
		oNode := oXMLNode:oAddChild(TBIXMLNode():New("OBJETIVO"))
		aFields := oObjetivo:xRecord(RF_ARRAY, {"PARENTID","DESCRICAO"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next

		oObjetivo:_Next()
	end
	oObjetivo:cSQLFilter("") // Encerra filtro
	
return oXMLNode

//Lista de Indicadores
method oToXMLIndList(nContextId) class TBSC056
	local oNode, oAttrib, oXMLNode, nInd
	local oIndicador  := ::oOwner():oGetTable("INDICADOR")		
		
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", "INDICADOR")
	oAttrib:lSet("RETORNA", .f.)
	// Gera no principal
	oXMLNode := TBIXMLNode():New("INDICADORES",,oAttrib)
	
	// Gera recheio
	oIndicador:SetOrder(1) // Por ordem de id
	oIndicador:cSQLFilter("CONTEXTID = "+cBIStr(nContextId)) 
	oIndicador:lFiltered(.t.)
	oIndicador:_First()

	while(!oIndicador:lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := oIndicador:xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","UNIDADE","FREQ","RESPID","DATASRCID","TIPOPESSOA"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		oIndicador:_Next()
	end
	oIndicador:cSQLFilter("") // Encerra filtro

return oXMLNode

// Funcao executada pelo job. Faz a chamada para os relatorios.
//aReportName[1]=Descricao do link.
//aReportName[2]=URL para o relatorio.
//aReportName[3]=Figura do relatorio.
method BSCRelEvolucao(aParms) class TBSC056
	local aReportName := {}

	// Arquivo de log
	oBSCCore:LogInit()
	oBSCCore:Log(STR0031, BSC_LOG_SCRFILE) // "Iniciando geração do relatórios de Evolução de Indicadores."

	oBSCCore:lSetupCard(aParms[USUALOGADO])

	/*Parametro para os relatorios: oBSCCore, Nome do Relatorio, Nome do Relatorio em Spool,nParentId ,De, Ate*/
	
	bsc056_Ind(oBSCCore,"rel056_" + cBIStr(aParms[ID])+".html", strtran(aParms[ARQNOME],".html",".html"),aParms[PARENTID],aParms[INDDE],aParms[INDATE],aParms[OBJDE],aParms[OBJATE],aParms[PERSPDE],aParms[PERSPATE],aParms[PATHSITE], aParms[IMPREF]=="T",aParms[DATADE],aParms[DATAATE],aParms[IMPDESC]=="T",aParms[DESCRICAO], aParms[ORDEMOBJ], aParms[ORDEMIND])
	aadd(aReportName,{STR0020,"rel056_" + cBIStr(aParms[ID])+".html" ,strtran(aParms[ARQNOME],".html",".html"),"images/ic_20_medida.gif"})
          
	oBSCCore:Log(STR0025 + aParms[NOME] + "]", BSC_LOG_SCRFILE) //"Finalizado geração do relatório de Evolução de Indicadores. "
	::fcMsg := STR0025 + aParms[NOME] + "]"
return


/*-------------------------------------------------------------------------------------
@function BSC056PreCab(oCore,oItem,aCabDados,nParentID)
Adiciona oContextno cabecalho para impressa
@oCore 	= Instancia do BscCore.
@oItem		= Instancia do item principal do relatorio.
@aCabDados = Cabecalho de dados por referencia.
@nParentID	= O ID do item pai do objeto atual.
create siga1776 - 01/07/2005
--------------------------------------------------------------------------------------*/
function BSC056PreCab(oCore,oItem,aCabDados,nParentID) 
	local oContext 	:= 	oCore:oContext(oItem, nParentId)
	local nItem		:= 	0
	local cTitCab	:= 	""
	local cTitVal	:= 	""
	aCabDados		:= 	{}
    for nItem := len(oContext:FACHILDREN) to 1 step -1
		cTitCab := oContext:FACHILDREN[nItem]:FACHILDREN[1]:FCVALUE//Item 
		cTitVal := oContext:FACHILDREN[nItem]:FACHILDREN[3]:FCVALUE//Valor
		aadd(aCabDados,{cTitCab,cTitVal})	
	next nItem

return .t.
/*-------------------------------------------------------------------------------------
@function BSC056LisPes(oCore,oItem,aCabDados,nParentID)
Retorna a lista com as pessoas
@oCore 		= Instancia do BscCore.
@nIDPessoa	= ID para localizacao 
@cTipoPessoa= Grupo ou pessoa para localizar
create siga1776 - 05/07/2005
--------------------------------------------------------------------------------------*/
function BSC056LisPes(oBSCCore,nIDPessoa,cTipoPessoa)
	
	local oPessoa	:=	oBSCCore:oGetTable("PESSOA")
	local oGrupo	:=	oBSCCore:oGetTable("PGRUPO")
	local cPessoas	:=	"&nbsp;"//Espaco
	
	if(cTipoPessoa=="P")
		cPessoas	:=	oPessoa:cGetPessoaName(nIDPessoa)
	elseif(cTipoPessoa == "G")
		cPessoas	:=	oGrupo:cGetGrupoName(nIDPessoa)
	endif								

return cPessoas 

/*-------------------------------------------------------------------------------------
@function BSC056LisPes(oCore,oItem,aCabDados,nParentID)
Retorna o cargo de uma pessoa
@oCore 		= Instancia do BscCore.
@nIDPessoa	= ID para localizacao 
@cTipoPessoa= Grupo ou pessoa para localizar
create siga1776 - 08/07/2005
--------------------------------------------------------------------------------------*/
function BSC056PesCar(oBSCCore,nIDPessoa,cTipoPessoa)
	local oPessoa 	:= nil
	local cCargo	:= ""
	
	if(cTipoPessoa=="P")
		oPessoa	:=	oBSCCore:oGetTable("PESSOA")
		if(oPessoa:lSeek(1, {nIDPessoa}))
			cCargo := oPessoa:cValue("CARGO")
		endif
	endif
	
return cCargo

// ######################################################################################
// Projeto: BSC
// Modulo : Evolucao de indicadores
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.06 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------
function bsc056_Ind(oBSCCore,cReportName,cSpoolName,nContextID,nIndDe,nIndAte,nObjDe,nObjAte,nPerspDe,nPerspAte,cPath, lImprimeRef, dDataDe, dDataAte, lImprimeDescri, cDescricao, nOrdemObj, nOrdemInd)
	Local oHtmFile := TBIFileIO():New(oBSCCore:cBscPath()+"relato\" + cReportName)
	Local oIndicador 
	Local oTendencia 
	Local oObjetivo
	Local oPlanReferencia	
	Local oPlanIndicador	
	Local oPlanilha  
	
	Local aDadosCab		:={}		
	Local aLstValores	:={}
	Local aDataDe 		:={}
	Local aDataAte 		:={}
	
	local nItem := 0		
	Local nIndID 
	Local nObjetivo := 0
	
	Local cFiltro 
	Local cCmdObjEof
	Local cCmdObjFirst
	Local cCmdObjNext
	local cCmdIndEof
	Local cCmdIndFirst
	Local cCmdIndNext 
	
	Local lReportHasData := .F.     

	// Cria o arquivo htm
	If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oBSCCore:Log(STR0001 + cReportName+ "]", BSC_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL056_"*/
		oBSCCore:Log(STR0002, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
		return
	endif
       
	if( nOrdemObj = 2 )
		cCmdObjEof := {||oObjetivo:lBof()}
		cCmdObjFirst := {||oObjetivo:_Last()}
		cCmdObjNext := {||oObjetivo:_Prior()}
	else
		cCmdObjEof := {||oObjetivo:lEof()}
		cCmdObjFirst := {||oObjetivo:_First()}
		cCmdObjNext := {||oObjetivo:_Next()}
	endif
	
	if( nOrdemInd = 2 )
		cCmdIndEof := {||oIndicador:lBof()}
		cCmdIndFirst := {||oIndicador:_Last()}
		cCmdIndNext := {||oIndicador:_Prior()}
	else
		cCmdIndEof := {||oIndicador:lEof()}
		cCmdIndFirst := {||oIndicador:_First()}
		cCmdIndNext := {||oIndicador:_Next()}
	endif

	oIndicador		:= oBSCCore:oGetTable("INDICADOR")
	oPlanIndicador	:= oBSCCore:oGetTable("PLANILHA")
	oPlanReferencia	:= oBSCCore:oGetTable("RPLANILHA")
	oTendencia		:= oBSCCore:oGetTable("INDTEND")

	oObjetivo		:= oBSCCore:oGetTable("OBJETIVO")
	oObjetivo:SetOrder(4) // Por ordem de Perspectiva + Nome
	
	if(!empty(nPerspDe) .and. !empty(nPerspAte))
		//oObjetivo:SetOrder(1) // Por ordem de ID
		cFiltro := "CONTEXTID = " + cBIStr(nContextID) + " AND PARENTID >=" + cBIStr(nPerspDe) + " AND PARENTID <= " + cBIStr(nPerspAte)
		if(!empty(nObjDe) .and. !empty(nObjAte))
			cFiltro += " AND ID >=" + cBIStr(nObjDe) + " AND ID <= " + cBIStr(nObjAte)
		endif
		oObjetivo:cSqlFilter(cFiltro)
		oObjetivo:lFiltered(.t.)
	endif      
	
	oIndicador:SetOrder(5) // Por ordem de ParentId(Objetivo) + Nome
	cFiltro := "CONTEXTID = " + cBIStr(nContextID)
	
	if(!empty(nIndDe) .and. !empty(nIndAte))
		cFiltro += " AND ID >=" + cBIStr(nIndDe) + " AND ID <= " + cBIStr(nIndAte)
	endif
	
	if(!empty(nObjDe) .and. !empty(nObjAte))
		cFiltro += " AND PARENTID >=" + cBIStr(nObjDe) + " AND PARENTID <= " + cBIStr(nObjAte)
	endif   
	
	oIndicador:cSQLFilter(cFiltro)
	oIndicador:lFiltered(.t.)

	Eval(cCmdObjFirst)
	
	nObjetivo := oObjetivo:nValue("ID")
	
	while( !Eval(cCmdObjEof) )
		oIndicador:lSoftSeek(5,{nObjetivo, ""})
	
	    if( nOrdemInd = 2 .AND. !oIndicador:lBof() )
	    	while( !oIndicador:lEof() .and. oIndicador:nValue("PARENTID") == nObjetivo )
	    		oIndicador:_Next()
	    	enddo

			oIndicador:_Prior()
	    endif        

		while( !Eval(cCmdIndEof) .and. !oIndicador:lEof() .and. oIndicador:nValue("PARENTID") == nObjetivo)
			//Atualiza os dados do cabecalho
			BSC055PreCab(oBSCCore,oIndicador,@aDadosCab,nContextID)
  
			oHtmFile:nWriteLN('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">')
			oHtmFile:nWriteLN('<html>')
			oHtmFile:nWriteLN('<head>')
			oHtmFile:nWriteLN('<title>'+ STR0003 +'</title>') //"Evolução de indicadores"		
			oHtmFile:nWriteLN('<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>')
			oHtmFile:nWriteLN('<META HTTP-EQUIV="Pragma" CONTENT="no-cache"> ')
            oHtmFile:nWriteLN('<META HTTP-EQUIV="Expires" CONTENT="-1"> ')
			oHtmFile:nWriteLN('<script language="JavaScript" type="text/JavaScript">')
			oHtmFile:nWriteLN('<!--')
			oHtmFile:nWriteLN('function MM_reloadPage(init) {  //reloads the window if Nav4 resized')
			oHtmFile:nWriteLN('if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {')
			oHtmFile:nWriteLN('document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}')
			oHtmFile:nWriteLN('else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();')
			oHtmFile:nWriteLN('}')
			oHtmFile:nWriteLN('MM_reloadPage(true);')
			oHtmFile:nWriteLN('//-->')
			oHtmFile:nWriteLN('</script>')
			oHtmFile:nWriteLN('<link href="'+ cPath+'images/bscRel055.css" rel="stylesheet" type="text/css" />')
			oHtmFile:nWriteLN('</head>')
		
			oHtmFile:nWriteLN('</head>')
			oHtmFile:nWriteLN('<body>')   
			
			if !(lReportHasData)
			
				oHtmFile:nWriteLN('    <table width="100%" border="0" cellspacing="0" cellpadding="0">')
				oHtmFile:nWriteLN('		   <tr><td>&nbsp;</td></tr>')
				oHtmFile:nWriteLN('        <tr>')
				oHtmFile:nWriteLN('            <td width="150"><img src="' + cPath + 'images/logo_sigabsc.gif"></td>')
				oHtmFile:nWriteLN('            <td>')
				oHtmFile:nWriteLN('                <table width="100%" border="0" cellspacing="0" cellpadding="0">')
				oHtmFile:nWriteLN('                    <tr><td align="center"><font size="4" face="Verdana, Arial, Helvetica, sans-serif">'+STR0004+'</font></td></tr>') //Organização
				oHtmFile:nWriteLN('                    <tr><td align="center"><font size="5" face="Verdana, Arial, Helvetica, sans-serif">' + aDadosCab[1,2] + '</font></td></tr>')
				oHtmFile:nWriteLN('                </table>')
				oHtmFile:nWriteLN('            </td>')
				oHtmFile:nWriteLN('            <td width="150" align="right" valign="top"><font class="texto">'+ STR0029 + ':' + dtoc(date()) + '</font></td>') //Emissão
				oHtmFile:nWriteLN('        </tr>')
				oHtmFile:nWriteLN('    </table>')    
				
				oHtmFile:nWriteLN('    <table width="100%" border="0" cellspacing="0" cellpadding="0">')
				oHtmFile:nWriteLN('			<tr><td>&nbsp;</td></tr>')
   				oHtmFile:nWriteLN('			<tr><td align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>' + STR0030 /*"Relatório de Evolução de Indicadores"*/ + '</strong></font></td></tr>')
				oHtmFile:nWriteLN('			<tr><td>&nbsp;</td></tr>')
				oHtmFile:nWriteLN('    </table>')
			 
			EndIf 
			
			oHtmFile:nWriteLN('<table width="100%" border="0" cellpadding="0" cellspacing="7">')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td height="0" valign="top"> <table width="100%" height="61" border="0" cellpadding="0" cellspacing="0">')
		
			oHtmFile:nWriteLN('<tr bgcolor="#F5F5F3">')
			oHtmFile:nWriteLN('<td height="53" colspan="2" valign="top"> <table width="769" height="21" border="0" cellpadding="0" cellspacing="0">')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="769"><table width="770" height="145" border="0" cellpadding="0" cellspacing="0">')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td height="126" colspan="2"><br />')
			oHtmFile:nWriteLN('<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">')
			
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="67" rowspan="8" valign="top"><div align="center"></div></td>')
			oHtmFile:nWriteLN('<td width="192" height="17" class="subTit">'+STR0004+'</td>')//Organizacao
			oHtmFile:nWriteLN('<td colspan="2"><span class="titOrgani">'+ aDadosCab[1,2] +'</span></td>')
			oHtmFile:nWriteLN('</tr>')
			
			oHtmFile:nWriteLN('<tr>')  			
			oHtmFile:nWriteLN('<td height="17" class="subTit">'+STR0005+'</td>')//Estrategia
			oHtmFile:nWriteLN('<td colspan="2"><span class="titOrgani">'+ aDadosCab[2,2] +'</span></td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td height="8" class="subTit">'+STR0006+'</td>')//Perspectiva
			oHtmFile:nWriteLN('<td colspan="2"><span class="titOrgani">'+ aDadosCab[3,2]+'</span></td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td height="8" class="subTit">'+STR0007+'</td>')//Objetivo
			oHtmFile:nWriteLN('<td colspan="2" class="titOrgani">'+ aDadosCab[4,2] +'</td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td height="16" colspan="3"><img src="'+ cPath+'images/linhadivisoriatitulo.jpg" width="100%" height="14" /></td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td height="10" colspan="2" class="subTit">'+STR0008+'</td>')//Responsavel
			oHtmFile:nWriteLN('<td width="510" height="0" class="subTit2">'+bsc055LisPes(oBSCCore,oIndicador:nValue("RESPID"),oIndicador:cValue("TIPOPESSOA"))+'</td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td height="11" colspan="2" class="subTit">'+STR0009+'</td>')//Responsavel pela coleta
			oHtmFile:nWriteLN('<td width="510" height="0" class="subTit2">'+bsc055LisPes(oBSCCore,oIndicador:nValue("MEDRESPID"),oIndicador:cValue("TIPOPESSOA"))+'</td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td height="13" colspan="2" class="subTit">'+STR0010+'</td>')
			oHtmFile:nWriteLN('<td width="510" height="13" class="subTit2">'+bsc055LisPes(oBSCCore,oIndicador:nValue("RRESPID"),oIndicador:cValue("TIPOPESSOA"))+'</td>')
			oHtmFile:nWriteLN('</tr>')
			
			if(lImprimeDescri)
				oHtmFile:nWriteLN('<tr><td valign="top">&nbsp;</td>')
				oHtmFile:nWriteLN('<td height="13" colspan="2" class="subTit">'+STR0012+'</td></tr>')
				oHtmFile:nWriteLN('<tr><td valign="top">&nbsp;</td>')
				oHtmFile:nWriteLN('<td width="510" height="13" colspan="6" class="subTit2">'+cDescricao+'</td>')
				oHtmFile:nWriteLN('</tr>')
			endif    
			
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td valign="top">&nbsp;</td>')
			oHtmFile:nWriteLN('<td height="19" colspan="3"><img src="'+ cPath+'images/linhadivisoriatitulo.jpg" width="100%" height="14" /></td>')
			oHtmFile:nWriteLN('</tr>')
	
			oHtmFile:nWriteLN('</table></td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="200">&nbsp;</td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table></td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table>')
	
			oHtmFile:nWriteLN('<table width="71"  border="0" cellspacing="2" cellpadding="0">')
			oHtmFile:nWriteLN('<tr> ')
			oHtmFile:nWriteLN('<td width="20%" valign="middle"> <div align="center"><img src="'+ cPath+'images/icone_indicador.gif" width="56" height="46" align="left" /></div></td>')
			oHtmFile:nWriteLN('<td width="20%" valign="middle" bordercolor="#999999" class="titOrgani">'+ STR0011 +'</td>')//"Indicador"
			oHtmFile:nWriteLN('<td width="60" valign="middle" bordercolor="#999999"> <table width="594" height="27"  border="1" align="center" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
			oHtmFile:nWriteLN('<tr> ')
			oHtmFile:nWriteLN('<td width="590" height="25" bgcolor="#FFFFFF" class="titOrganiBlack">'+oIndicador:cValue("NOME")+'</td>')
			oHtmFile:nWriteLN('</tr>')
			
			oHtmFile:nWriteLN('</table></td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr valign="top">')
			oHtmFile:nWriteLN('<td width="155" valign="middle" class="text_01">'+STR0018+'</td>')
			oHtmFile:nWriteLN('<td height="23" colspan="3" class="text_01"><table width="99%" height="22"  border="1" align="center" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
			oHtmFile:nWriteLN('<tr>')
	
			if(oIndicador:cValue("ASCEND")=="T")
				oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+STR0016+'</td>')
			else
				oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+STR0017+'</td>')
			endif
	
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table></td>')
			oHtmFile:nWriteLN('</tr>')
	
			oHtmFile:nWriteLN('</table></td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table>')
			oHtmFile:nWriteLN('<table width="100%"  border="0" cellpadding="0" cellspacing="0">')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td colspan="2"><img src="'+ cPath+'images/barra_tit_01_a.jpg" width="16" height="23" /></td>')
			oHtmFile:nWriteLN('<td width="151">')
			oHtmFile:nWriteLN('<!-- In&iacute;cio do bloco para DIV Usu&aacute;rios-->')
			oHtmFile:nWriteLN('<img src="'+ cPath+'images/barra_tit_02_a.jpg" width="153" height="23" align="absbottom" />')
			oHtmFile:nWriteLN('<!-- Fim do bloco para DIV Usu&aacute;rios-->')
			oHtmFile:nWriteLN('</td>')
			oHtmFile:nWriteLN('<div id="bar" class="subTit">'+STR0019+'</div>')//Lista de Valores
			oHtmFile:nWriteLN('<td width="594"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="594" height="23" /></td>')
			oHtmFile:nWriteLN('<td width="490" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg"><img src="'+ cPath+'images/fundo_barra_tit.jpg" width="1" height="7" /></td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr valign="top">')
			oHtmFile:nWriteLN('<td height="68" colspan="6"> <table width="770" id="tbl01">')
			oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
			oHtmFile:nWriteLN('<td width="390" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0021+'</div></td>')//Tabelade Resultados 
			
			if(lImprimeRef)
				oHtmFile:nWriteLN('<td width="390" height="20" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0024+'</div></td>')//Tabelade Referencia 
			endif
			
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="390" class="form_input" id="tbl01"><table width="100%" border="0">')
	
			//Planilha de valores        
			aDataDe:= oPlanIndicador:aDateConv(dDataDe, oIndicador:nValue("FREQ"))
			aDataAte:= oPlanIndicador:aDateConv(dDataAte, oIndicador:nValue("FREQ"))
			oPlanilha	:= oPlanIndicador:oToXMLNode(oIndicador:nValue("ID"))
	
			oIndicador:SetOrder(5) // Por ordem de Nome
			aLstValores := aBsc055ePlan(oPlanilha,oIndicador:nValue("FREQ"))
	
			oHtmFile:nWriteLN('<tr align="center" class="subTit2">')
			oHtmFile:nWriteLN('<td width="14%">'+aLstValores[1,1]+'</td>')
			oHtmFile:nWriteLN('<td width="14%">'+aLstValores[1,2]+'</td>')
			oHtmFile:nWriteLN('<td width="13%">'+aLstValores[1,3]+'</td>')
			oHtmFile:nWriteLN('<td width="23%">'+aLstValores[1,4]+'</td>')
			oHtmFile:nWriteLN('<td width="36%">'+aLstValores[1,5]+'</td>')
			aDataAte[2] := if(aDataAte[2]=='00','',aDataAte[2])
			aDataAte[3] := if(aDataAte[3]=='00','',aDataAte[3])
			aDataDe[2] := if(aDataDe[2]=='00','',aDataDe[2])
			aDataDe[3] := if(aDataDe[3]=='00','',aDataDe[3])
			for nItem := 2 to len(aLstValores)
				if(aLstValores[nItem,1]+aLstValores[nItem,2]+aLstValores[nItem,3] >= aDataDe[1]+aDataDe[2]+aDataDe[3] .and.;
				aLstValores[nItem,1]+aLstValores[nItem,2]+aLstValores[nItem,3] <= aDataAte[1]+aDataAte[2]+aDataAte[3])
						oHtmFile:nWriteLN('</tr>')
							oHtmFile:nWriteLN('<tr align="center" class="text_01">')
							oHtmFile:nWriteLN('<td>'+aLstValores[nItem,1]+'</td>')
							oHtmFile:nWriteLN('<td>'+aLstValores[nItem,2]+'</td>')
							oHtmFile:nWriteLN('<td>'+aLstValores[nItem,3]+'</td>')
							oHtmFile:nWriteLN('<td>'+aLstValores[nItem,4]+'</td>')
							oHtmFile:nWriteLN('<td>'+aLstValores[nItem,5]+'</td>')
						oHtmFile:nWriteLN('</tr>')
				endif
			next nItem			
	
			if(lImprimeRef)
				oPlanilha	:= oPlanReferencia:oToXMLNode(oIndicador:nValue("ID"))
				oIndicador:SetOrder(5) // Por ordem de Nome
				aLstValores := aBsc055ePlan(oPlanilha,oIndicador:nValue("FREQ"))
	
				oHtmFile:nWriteLN('</table></td>')
				oHtmFile:nWriteLN('<td width="390" height="40" id="tbl01"> <table width="100%" border="0">')
				oHtmFile:nWriteLN('<tr align="center" class="subTit2">')
				oHtmFile:nWriteLN('<td width="14%">'+aLstValores[1,1]+'</td>')
				oHtmFile:nWriteLN('<td width="14%">'+aLstValores[1,2]+'</td>')
				oHtmFile:nWriteLN('<td width="13%">'+aLstValores[1,3]+'</td>')
				oHtmFile:nWriteLN('<td width="23%">'+aLstValores[1,4]+'</td>')
				oHtmFile:nWriteLN('<td width="36%">'+aLstValores[1,5]+'</td>')
	
				for nItem := 2 to len(aLstValores)
				if(aLstValores[nItem,1]+aLstValores[nItem,2]+aLstValores[nItem,3] >= aDataDe[1]+aDataDe[2]+aDataDe[3] .and.;
				aLstValores[nItem,1]+aLstValores[nItem,2]+aLstValores[nItem,3] <= aDataAte[1]+aDataAte[2]+aDataAte[3])
						oHtmFile:nWriteLN('</tr>')
							oHtmFile:nWriteLN('<tr align="center" class="text_01">')
							oHtmFile:nWriteLN('<td>'+aLstValores[nItem,1]+'</td>')
							oHtmFile:nWriteLN('<td>'+aLstValores[nItem,2]+'</td>')
							oHtmFile:nWriteLN('<td>'+aLstValores[nItem,3]+'</td>')
							oHtmFile:nWriteLN('<td>'+aLstValores[nItem,4]+'</td>')
							oHtmFile:nWriteLN('<td>'+aLstValores[nItem,5]+'</td>')
						oHtmFile:nWriteLN('</tr>')
					endif
				next nItem			
	
				oHtmFile:nWriteLN('</table></td>')
				oHtmFile:nWriteLN('</tr>')
				oHtmFile:nWriteLN('</table></td>')
			else
				oHtmFile:nWriteLN('</table></td>')
				oHtmFile:nWriteLN('</tr>')
				oHtmFile:nWriteLN('</table></td>')
			endif
	
			//Indicadicador de Tendencia				
			if(oIndicador:cValue("TIPOIND")== "T")
				oHtmFile:nWriteLN('<table width="100%"  border="0" cellpadding="0" cellspacing="0">')
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td colspan="2"><img src="'+ cPath+'images/barra_tit_01_a.jpg" width="16" height="23" /></td>')
				oHtmFile:nWriteLN('<td width="306">')
				oHtmFile:nWriteLN('<!-- In&iacute;cio do bloco para DIV Usu&aacute;rios-->')
				oHtmFile:nWriteLN('<img src="'+ cPath+'images/barra_tit_02_a.jpg" width="306" height="23" align="absbottom" />')
				oHtmFile:nWriteLN('<!-- Fim do bloco para DIV Usu&aacute;rios-->')
				oHtmFile:nWriteLN('</td>')
				oHtmFile:nWriteLN('<div id="bar" class="subTit">'+STR0022+'</div>')//Lista dos Indicadores que são influenciados
				oHtmFile:nWriteLN('<td width="439"><div align="right"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="439" height="23" /></div></td>')
				oHtmFile:nWriteLN('<td width="488" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg"><img src="'+ cPath+'images/fundo_barra_tit.jpg" width="1" height="7" /></td>')
				oHtmFile:nWriteLN('</tr>')
				oHtmFile:nWriteLN('<tr valign="top">')
				oHtmFile:nWriteLN('<td height="49" colspan="6"> <table width="770" id="tbl01">')
				oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
				oHtmFile:nWriteLN('<td height="20" bgcolor="#7BA0CA"><div align="center" class="titTab">')
				oHtmFile:nWriteLN('<div align="center" class="titTab" id="tbl01">'+STR0023+'</div></td>')//Indicador
				oHtmFile:nWriteLN('</tr>')
	
				nIndID := oIndicador:nValue("ID")
				oIndicador:SavePos()           
				oIndicador:cSQLFilter("") // Encerra filtro		
				oTendencia:lSoftSeek(3,{nIndID}) 
				while(! oTendencia:lEof() .and. oTendencia:nValue("PARENTID")== nIndID)
					if(oIndicador:lSeek(1,{oTendencia:nValue("INDICADOR")}))					
						oHtmFile:nWriteLN('<tr>')
							oHtmFile:nWriteLN('<td height="20" class="textTab" id="tbl01">' + oIndicador:cValue("NOME")	+ '')
							oHtmFile:nWriteLN('<div align="center" class="textTab"> </div>')
							oHtmFile:nWriteLN('<div align="center" class="textTab"></div></td>')
						oHtmFile:nWriteLN('</tr>')
					endif						
					oTendencia:_Next()
				enddo
				oIndicador:SetOrder(5) // Por ordem de Nome
				oIndicador:cSQLFilter(cFiltro) // Filtra pelo pai
				oIndicador:lFiltered(.t.)
				oIndicador:RestPos()
	
				oHtmFile:nWriteLN('</table></td>')
				oHtmFile:nWriteLN('</tr>')
			endif
			oHtmFile:nWriteLN('</table>')
	
			oHtmFile:nWriteLN('</td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table>')
			oHtmFile:nWriteLN('</body>')
			oHtmFile:nWriteLN('</html>')
			oHtmFile:nWriteLN('</br>')
			oHtmFile:nWriteLN('<DIV style="page-break-after:always"></DIV> ')
	            
			lReportHasData := .T.
		
			Eval(cCmdIndNext)
		end

		Eval(cCmdObjNext)
		nObjetivo := oObjetivo:nValue("ID")
	enddo

	oIndicador:cSQLFilter("")
	oObjetivo:cSqlFilter("")
     
	If!(lReportHasData)
		oHtmFile:nWriteLN(STR0028) /*"Não foram encontrados dados dentro dos parâmetros passados."*/
	EndIf

	oHtmFile:lClose()

Return

function _BSC056_Evol()
return
