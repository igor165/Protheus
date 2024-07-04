// ######################################################################################
// Projeto: BSC
// Modulo : Book de Planejamento estratégico
// Fonte  : BSC055_Book.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 09.05.05 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC055_Book.ch"

/*------------------------------------------------------------------------------------
@class TBSC055
@entity RELBOOKSTRA
Book de Planejamento estratégico
@table BSC055
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "RELBOOKSTRA"
#define TAG_GROUP  "RELBOOKSTRAS"
#define TEXT_ENTITY STR0001/*//"Book de Planejamento estratégico"*/
#define TEXT_GROUP  STR0002/*//"Book de Planejamento estratégico"*/

//Posicoes no array de parametros (aParms)
#define PATH			01//BSCPATH da Working THREAD
#define ARQNOME   		02//Nome do relatorio em disco
#define NOME			03//Nome
#define DESCRICAO		04//Descrição
#define IMPDESC			05//Imprime Descrição?
#define IMPORGANIZA		06//Imprime Organizacao?
#define IMPESTRATE		07//Imprime Estrategia?
#define IMPPERSPECT		08//Imprime Pespectiva?
#define IMPOBJETIVO		09//Imprime Objetivo?
#define IMPINDICADO		10//Imprime Indicador?
#define ORGDE			11//Da organizacao
#define ORGATE			12//Ate organizao
#define ESTRADE			13//Da estrategia
#define ESTRAATE		14//Ate estrategia
#define PERSPDE			15//Da perspectiva
#define PERSPATE		16//Ate perspectiva
#define OBJDE			17//Do objetivo	
#define OBJATE			18//Ate objetivo
#define INDDE			19//Do indicador
#define INDATE			20//Ate indocador
#define ID				21//ID do relatorio
#define PARENTID		22//Parent ID do relatorio (Estrategia)
#define TEMADE			23//Do tema
#define TEMAATE			24//Ate o tema
#define INICIADE		25//Da inciativa
#define INICIAATE		26//Ate inciativa
#define TAREFADE		27//Da tarefa
#define TAREFAATE		28//Ate a tarefa
#define REUNIADE		29//Da reuniao
#define REUNIAATE		30//Ate a reuniao
#define IMPTEMA  		31//Imprime tema?
#define IMPINICIA		32//Imprime iniciativa?
#define IMPTAREFA		33//Imprime tarefa?
#define IMPREUNIAO		34//Imprime reuniao?
#define USUALOGADO		35//Usuario logado?
#define PATHSITE		36//Endereco do site.
#define IMPORTANCIA		37//da tarefa
#define URGENCIA		38//da tarefa

class TBSC055 from TBITable
	//Estrategia
	data oEstrategia
	
	method New() constructor
	method NewBSC055()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)
	method BSCRelBookEstJob(aParms)

	//registro atual
	method oToXMLNode(nParentID)
	method nUpdFromXML(oXML, cPath)
	method oToXMLOrgList(nParentID)	
	method oToXMLEstList(nParentID)	
	method oToXMLPerList(nParentID)	
	method oToXMLTemList(nParentID) 
	method oToXMLObjList(nParentID)	
	method oToXMLIndList(nParentID)	
	method oToXMLIniList(nParentID)
	method oToXMLTarList(nParentID)
	method oToXMLReuList(nParentID)

	// executar 
	method nExecute(nID, cExecCMD)

endclass

method New() class TBSC055
	::NewBSC055()
return
method NewBSC055() class TBSC055
	
	// Table
	::NewTable("BSC055")
	::cEntity(TAG_ENTITY)

	::addField(TBIField():New("ID",		"N"))
	::addField(TBIField():New("NOME",		"C",60))
	::addField(TBIField():New("DESCRICAO",	"C",255))
	// Fields

	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("ORGDE",		"N"))
	::addField(TBIField():New("ORGATE",	"N"))
	::addField(TBIField():New("ESTRADE",	"N"))
	::addField(TBIField():New("ESTRAATE",	"N"))
	::addField(TBIField():New("PERSPDE",	"N"))
	::addField(TBIField():New("PERSPATE",	"N"))
	::addField(TBIField():New("OBJDE", 	"N"))
	::addField(TBIField():New("OBJATE",	"N"))
	::addField(TBIField():New("INDDE",		"N"))
	::addField(TBIField():New("INDATE",	"N"))
	::addField(TBIField():New("TEMADE",	"N"))
	::addField(TBIField():New("TEMAATE",	"N"))
	::addField(TBIField():New("INICIADE",	"N"))
	::addField(TBIField():New("INICIAATE",	"N"))
	::addField(TBIField():New("TAREFADE",	"N"))
	::addField(TBIField():New("TAREFAATE",	"N"))
	::addField(TBIField():New("REUNIADE",	"N"))
	::addField(TBIField():New("REUNIATE",	"N"))
	::addField(TBIField():New("IMPORTANCI","N")) //(1) A-Vital; (2) B-Importante; (3) C-Interessante
	::addField(TBIField():New("URGENCIA","N")) //(1) 0-Urgente; (2) 1-Curto Prazo; (3) 2-Médio Prazo; (4) 3-Longo Prazo (sem prazo)

	::addField(TBIField():New("IMPTEMA"		,"C",01))
	::addField(TBIField():New("IMPINICIAT"	,"C",01))
	::addField(TBIField():New("IMPTAREFA"	,"C",01))
	::addField(TBIField():New("IMPREUNIAO"	,"C",01))
	::addField(TBIField():New("IMPORGANIZ"	,"C",01))
	::addField(TBIField():New("IMPESTRAT" 	,"C",01))
	::addField(TBIField():New("IMPPERSP"	,"C",01))
	::addField(TBIField():New("IMPOBJET"	,"C",01))
	::addField(TBIField():New("IMPIND"		,"C",01))
	::addField(TBIField():New("IMPDESC"		,"C",01)) 

	// Indexes
	::addIndex(TBIIndex():New("BSC055I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC055I02",	{"NOME", "CONTEXTID"}))
	::addIndex(TBIIndex():New("BSC055I03",	{"PARENTID", "ID"}))

return

// Arvore
method oArvore(nParentID) class TBSC055
	local oXMLArvore, oNode
	
	::SetOrder(2) /*Por ordem de NOME*/
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
method oToXMLList(nParentID) class TBSC055
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
	::SetOrder(2) /*Por ordem de NOME*/
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
method oToXMLNode(nParentID) class TBSC055
	local aFields, nInd, nStatus := BSC_ST_OK, nOrganiza:=0
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

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
	oXMLNode:oAddChild(::oToXMLOrgList(nParentID))//Organizacao
	oXMLNode:oAddChild(::oToXMLEstList(nParentID))//Estrategia
	oXMLNode:oAddChild(::oToXMLPerList(nParentID))//Perspectiva
	oXMLNode:oAddChild(::oToXMLTemList(nParentID))//Tema 
	oXMLNode:oAddChild(::oToXMLObjList(nParentID))//Objetivo 
	oXMLNode:oAddChild(::oToXMLIndList(nParentID))//Indicador  
	oXMLNode:oAddChild(::oToXMLIniList(nParentID))//Iniciativa 
	oXMLNode:oAddChild(::oToXMLTarList(nParentID))//Tarefa     
	oXMLNode:oAddChild(::oToXMLReuList(nOrganiza))//Reuniao    
	oXMLNode:oAddChild(::oOwner():oGetTable("TAREFA"):oXMLImportancia())
	oXMLNode:oAddChild(::oOwner():oGetTable("TAREFA"):oXMLUrgencia())

return oXMLNode

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC055
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
method nExecute(nID, cExecCMD) class TBSC055
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
		aAdd(aParms, ::cValue("IMPORGANIZ"))	// 06 - Imprime Organizacao?
		aAdd(aParms, ::cValue("IMPESTRAT" ))	// 07 - Imprime Estrategia?
		aAdd(aParms, ::cValue("IMPPERSP"))		// 08 - Imprime Pespectiva?
		aAdd(aParms, ::cValue("IMPOBJET"))		// 09 - Imprime Objetivo?
		aAdd(aParms, ::cValue("IMPIND"))		// 10 - Imprime Indicador?
		aAdd(aParms, ::nValue("ORGDE"))			// 11 - Da organizacao
		aAdd(aParms, ::nValue("ORGATE"))		// 12 - Ate organizao
		aAdd(aParms, ::nValue("ESTRADE"))		// 13 - Da estrategia
		aAdd(aParms, ::nValue("ESTRAATE"))		// 14 - Ate estrategia
		aAdd(aParms, ::nValue("PERSPDE"))		// 15 - Da perspectiva
		aAdd(aParms, ::nValue("PERSPATE"))		// 16 - Ate perspectiva
		aAdd(aParms, ::nValue("OBJDE"))			// 17 - Do objetivo	
		aAdd(aParms, ::nValue("OBJATE"))		// 18 - Ate objetivo
		aAdd(aParms, ::nValue("INDDE"))			// 19 - Do indicador
		aAdd(aParms, ::nValue("INDATE"))		// 20 - Ate indicador
		aAdd(aParms, ::nValue("ID"))			// 21 - ID do Relatório
		aAdd(aParms, oEstrategia:nValue("ID"))	// 22 - Parent ID do relatorio (Estrategia)
		aAdd(aParms, ::nValue("TEMADE"))		// 23 - Do tema
		aAdd(aParms, ::nValue("TEMAATE"))		// 24 - Ate o tema
		aAdd(aParms, ::nValue("INICIADE"))		// 25 - Da inciativa
		aAdd(aParms, ::nValue("INICIAATE"))		// 26 - Ate inciativa
		aAdd(aParms, ::nValue("TAREFADE"))		// 27 - Da tarefa
		aAdd(aParms, ::nValue("TAREFAATE"))		// 28 - Ate a tarefa
		aAdd(aParms, ::nValue("REUNIADE"))		// 29 - Da reuniao
		aAdd(aParms, ::nValue("REUNIATE"))		// 30 - Ate a reuniao
		aAdd(aParms, ::cValue("IMPTEMA"))  		// 31 - Imprime tema?
		aAdd(aParms, ::cValue("IMPINICIAT"))	// 32 - Imprime iniciativa?
		aAdd(aParms, ::cValue("IMPTAREFA"))		// 33 - Imprime tarefa?
		aAdd(aParms, ::cValue("IMPREUNIAO"))	// 34 - Imprime reuniao?
		aAdd(aParms, ::oOwner():foSecurity:fnUserCard)// 35 - Usuario logado?
		aAdd(aParms, strtran(cPathSite,"\","/"))//36 - Diretorio do site.		
		aAdd(aParms, ::cValue("IMPORTANCI"))	// 37 - da tarefa
		aAdd(aParms, ::cValue("URGENCIA"))		// 38 - da tarefa

		// Executando JOB
		::BSCRelBookEstJob(aParms)
		
	else

		nStatus := 	BSC_ST_BADID

	endif

return nStatus
      
//Lista as organizacoes
method oToXMLOrgList(nParentID) class TBSC055
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
method oToXMLEstList(nParentID) class TBSC055
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
method oToXMLPerList(nParentID) class TBSC055
	local oNode, oAttrib, oXMLNode, nInd
	local oPerspectiva  := ::oOwner():oGetTable("PERSPECTIVA")	

	// Colunas
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("TIPO", "PERSPECTIVA")	// Tipo
	// Gera no principal
	oXMLNode := TBIXMLNode():New("PERSPECTIVAS",,oAttrib)
	
	// Gera recheio
	oPerspectiva:SetOrder(2) /*Por ordem de NOME*/
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
method oToXMLTemList(nParentID) class TBSC055

	local oTema	:= ::oOwner():oGetTable("TEMAEST")		

return oTema:oToXMLList(nParentID)

//Listar todos os objetivos
method oToXMLObjList(nContextId) class TBSC055
	local oNode, oAttrib, oXMLNode, nind
	local oObjetivo  := ::oOwner():oGetTable("OBJETIVO")		
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("TIPO", "OBJETIVO")// Tipo
	oAttrib:lSet("RETORNA", .f.)
	
	// Gera no principal
	oXMLNode := TBIXMLNode():New("OBJETIVOS",,oAttrib)
	
	oObjetivo:SetOrder(2) /*Por ordem de NOME*/
	oObjetivo:cSQLFilter("CONTEXTID = " + cBIStr(nContextId)) // Filtra pelo pai
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
method oToXMLIndList(nContextId) class TBSC055
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
	oIndicador:SetOrder(2) /*Por ordem de NOME*/
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

//Lista de inciativas
method oToXMLIniList(nParentID) class TBSC055
	local oIniciativa := ::oOwner():oGetTable("INICIATIVA")		
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", "INICIATIVA")
	oAttrib:lSet("RETORNA", .f.)

	// Gera no principal
	oXMLNode := TBIXMLNode():New("INICIATIVAS",,oAttrib)
	
	// Gera conteudo
	oIniciativa:SetOrder(2) /*Por ordem de NOME*/
	oIniciativa:cSQLFilter("CONTEXTID = "+cBIStr(nParentID)) // Filtra pelo pai
	oIniciativa:lFiltered(.t.)
	oIniciativa:_First()
	while(!oIniciativa:lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New("INICIATIVA"))
		aFields := oIniciativa:xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","CUSTOEST","CUSTOREAL","HORASEST","HORASREAL","STATUS","COMPLETADO"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		oIniciativa:_Next()
	end 
	oIniciativa:cSQLFilter("") // Encerra filtro

return oXMLNode

//Lista de tarefas
method oToXMLTarList(nParentID) class TBSC055
	local oTarefa := ::oOwner():oGetTable("TAREFA")
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", "TAREFA")
	oAttrib:lSet("RETORNA", .f.)

	// Gera no principal
	oXMLNode := TBIXMLNode():New("TAREFAS",,oAttrib)
	
	// Gera recheio
	oTarefa:SetOrder(2) /*Por ordem de NOME*/
	oTarefa:cSQLFilter("CONTEXTID = "+cBIStr(nParentID)) // Filtra pelo pai
	oTarefa:lFiltered(.t.)
	oTarefa:_First()
	while(!oTarefa:lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New("TAREFA"))
		aFields := oTarefa:xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","TEXTO","DATAINI","CE_MAOOBRA","SITID",;
					"CE_MATERIA","CE_TERCEIR","CR_MAOOBRA","CR_MATERIA","CR_TERCEIR","HORASEST","HORASREAL"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		oTarefa:_Next()
	end
	oTarefa:cSQLFilter("") // Encerra filtro

return oXMLNode

//Lista de reunioes
method oToXMLReuList(nParentID) class TBSC055
	local oReuniao := ::oOwner():oGetTable("REUNIAO")
	local oNode, oAttrib, oXMLNode, nInd

	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", "REUNIAO")
	oAttrib:lSet("RETORNA", .f.)

	// Gera no principal
	oXMLNode := TBIXMLNode():New("REUNIOES",,oAttrib)
	
	// Gera o conteudo
	oReuniao:SetOrder(1) /*Por ordem de ID*/
	oReuniao:cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	oReuniao:lFiltered(.t.)
	oReuniao:_First()
	while(!oReuniao:lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New("REUNIAO"))

		aFields := oReuniao:xRecord(RF_ARRAY, {"TIPOPESSOA","RESPID","LOCAL","HORAFIM","HORAINI","DATAREU","DETALHES","FEEDBACK","PARENTID","CONTEXTID","DETALHES","RESPID"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		oReuniao:_Next()
	end
	oReuniao:cSQLFilter("") // Encerra filtro

return oXMLNode

// Funcao executada pelo job. Faz a chamada para os relatorios.
//aReportName[1]=Descricao do link.
//aReportName[2]=URL para o relatorio.
//aReportName[3]=Figura do relatorio.
method BSCRelBookEstJob(aParms) class TBSC055
	local aReportName 	:= {}
	local cReport	  	:= alltrim(strtran(aParms[ARQNOME],".html",""))
	
	Local cEntidade 	:= ''
	Local aFaixa		:= {}	           

	// Arquivo de log
	oBSCCore:LogInit()
	oBSCCore:Log(STR0015, BSC_LOG_SCRFILE) /*"Iniciando geração do conjunto de relatórios do Book de Planejamento Estratégico."*/

	oBSCCore:lSetupCard(aParms[USUALOGADO])

	/*Parametro para os relatorios:	oBSCCore, Nome do Relatorio, Nome do Relatorio em Spool,nParentId ,De, Ate*/
	
	//Imprime o relatorio de Descricao?
	if(aParms[IMPDESC]=="T")
		bsc055_Desc(oBSCCore, cReport+"desc.html", cReport+"desc.html", aParms[PARENTID], aParms[ID], aParms[PATHSITE])
		aadd(aReportName,{STR0004, cReport+"desc", cReport+"desc.html",""})
	endif
	
	//Imprime Organizacao?
	if(aParms[IMPORGANIZA]=="T")
		bsc055A_Org(oBSCCore, cReport+"a.html", cReport+"a.html", aParms[PARENTID], aParms[ORGDE], aParms[ORGATE], aParms[PATHSITE])
		aadd(aReportName,{STR0005, cReport+"a", cReport+"a.html","images/ic_20_organizacao.gif"})
	endif
	
	//Imprime Estrategia?
	if(aParms[IMPESTRATE]=="T")	
		bsc055B_Est(oBSCCore, cReport+"b.html", cReport+"b.html",aParms[PARENTID], aParms[ESTRADE], aParms[ESTRAATE], aParms[PATHSITE])
		aadd(aReportName,{STR0006, cReport+"b", cReport+"b.html","images/ic_20_estrategia.gif"})
	endif
           
	
	//Imprime Pespectiva?
	if(aParms[IMPPERSPECT]=="T")   
		cEntidade 	:= 'PERSPECTIVA'
		aFaixa 		:= {aParms[PERSPDE], aParms[PERSPATE]}          
		
		bsc055C_Per(oBSCCore, cReport+"c.html", cReport+"c.html", aParms[PARENTID], BSCGetValueByID(cEntidade, aFaixa[1]), BSCGetValueByID(cEntidade, aFaixa[2]), aParms[PATHSITE])
		aadd(aReportName,{STR0007, cReport+"c", cReport+"c.html","images/ic_20_perspectiva.gif"})
	endif
	
	//Imprime Tema?
	if(aParms[IMPTEMA]=="T") 
		cEntidade 	:= 'TEMAEST'
		aFaixa 		:= {aParms[TEMADE],  aParms[TEMAATE]}
	
		bsc055F_Tema(oBSCCore, cReport+"f.html", cReport+"f.html", aParms[PARENTID], BSCGetValueByID(cEntidade, aFaixa[1]), BSCGetValueByID(cEntidade, aFaixa[2]), aParms[PATHSITE])
		aadd(aReportName,{STR0008,  cReport+"f", cReport+"f.html","images/ic_20_temaestrategico.gif"})
	endif	
	
	//Imprime Objetivo?
	if(aParms[IMPOBJETIVO]=="T")
		cEntidade 	:= 'OBJETIVO'
		aFaixa		:= {aParms[OBJDE],  aParms[OBJATE]}
		
		
		bsc055D_Obj(oBSCCore, cReport+"d.html", cReport+"d.html", aParms[PARENTID], BSCGetValueByID(cEntidade, aFaixa[1]), BSCGetValueByID(cEntidade, aFaixa[2]), aParms[PATHSITE])
		aadd(aReportName,{STR0009, cReport+"d", cReport+"d.html","images/ic_20_objetivo.gif"})
	endif

	//Imprime Indicador?
	if(aParms[IMPINDICADO]=="T")  
		cEntidade 	:= 'INDICADOR' 
		aFaixa		:= {aParms[INDDE],  aParms[INDATE]}
	
		bsc055E_Ind(oBSCCore, cReport+"e.html", cReport+"e.html", aParms[PARENTID], BSCGetValueByID(cEntidade, aFaixa[1]), BSCGetValueByID(cEntidade, aFaixa[2]), aParms[PATHSITE])
		aadd(aReportName,{STR0010, cReport+"e", cReport+"e.html","images/ic_20_medida.gif"})
	endif
	
	//Imprime Iniciativa?
	if(aParms[IMPINICIA]=="T") 
		cEntidade 	:= 'INICIATIVA' 
		aFaixa		:= {aParms[INICIADE],  aParms[INICIAATE]}
	
		bsc055G_Ini(oBSCCore, cReport+"g.html", cReport+"g.html", aParms[PARENTID], BSCGetValueByID(cEntidade, aFaixa[1]), BSCGetValueByID(cEntidade, aFaixa[2]), aParms[PATHSITE])
		aadd(aReportName,{STR0011, cReport+"g", cReport+"g.html","images/ic_20_iniciativa.gif"})
	endif

	//Imprime Tarefa?
	if(aParms[IMPTAREFA]=="T")  
		cEntidade := 'TAREFA'
		aFaixa		:= {aParms[TAREFADE],   aParms[TAREFAATE]}
		
		bsc055H_Tar(oBSCCore, cReport+"h.html", cReport+"h.html", aParms[PARENTID], BSCGetValueByID(cEntidade, aFaixa[1]), BSCGetValueByID(cEntidade, aFaixa[2]), aParms[IMPORTANCIA], aParms[URGENCIA], aParms[PATHSITE])
		aadd(aReportName,{STR0012, cReport+"h", cReport+"h.html","images/ic_20_tarefa.gif"})
	endif

	//Imprime Reuniao?
	if(aParms[IMPREUNIAO]=="T")  
		cEntidade 	:= 'REUNIAO'
		aFaixa		:= {aParms[REUNIADE],   aParms[REUNIAATE]}
		
		bsc055I_Reu(oBSCCore, cReport+"i.html", cReport+"i.html", aParms[ORGDE], BSCGetValueByID(cEntidade, aFaixa[1]), BSCGetValueByID(cEntidade, aFaixa[2]), aParms[PATHSITE])
		aadd(aReportName,{STR0013, cReport+"i", cReport+"i.html","images/ic_20_reuniao.gif"})
	endif
	
	//Imprime o relatorio de Indice
	bsc055_Index(oBSCCore,aParms[ARQNOME], cReport+".html", aReportName, aParms[PATHSITE])

	oBSCCore:Log(STR0016 + aParms[NOME] + "]" , BSC_LOG_SCRFILE) /*Finalizando geração do relatório [*/
	::fcMsg := STR0016 + aParms[NOME] + "]"
return


/*-------------------------------------------------------------------------------------
@function BSC055PreCab(oCore,oItem,aCabDados,nParentID)
Adiciona oContextno cabecalho para impressa
@oCore 	= Instancia do BscCore.
@oItem		= Instancia do item principal do relatorio.
@aCabDados = Cabecalho de dados por referencia.
@nParentID	= O ID do item pai do objeto atual.
create siga1776 - 01/07/2005
--------------------------------------------------------------------------------------*/
function BSC055PreCab(oCore,oItem,aCabDados,nParentID) 
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
@function bsc055LisPes(oCore,oItem,aCabDados,nParentID)
Retorna a lista com as pessoas
@oCore 		= Instancia do BscCore.
@nIDPessoa	= ID para localizacao 
@cTipoPessoa= Grupo ou pessoa para localizar
create siga1776 - 05/07/2005
--------------------------------------------------------------------------------------*/
function bsc055LisPes(oBSCCore,nIDPessoa,cTipoPessoa)
	
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
@function bsc055LisPes(oCore,oItem,aCabDados,nParentID)
Retorna o cargo de uma pessoa
@oCore 		= Instancia do BscCore.
@nIDPessoa	= ID para localizacao 
@cTipoPessoa= Grupo ou pessoa para localizar
create siga1776 - 08/07/2005
--------------------------------------------------------------------------------------*/
function bsc055PesCar(oBSCCore,nIDPessoa,cTipoPessoa)
	local oPessoa 	:= nil
	local cCargo	:= ""
	
	if(cTipoPessoa=="P")
		oPessoa	:=	oBSCCore:oGetTable("PESSOA")
		if(oPessoa:lSeek(1, {nIDPessoa}))
			cCargo := oPessoa:cValue("CARGO")
		endif
	endif
	
return cCargo

/*-------------------------------------------------------------------------------------
@function BSCGetValueByID   
Retorna o conteúdo do campo de determinada entidade de acordo com o ID informado.
@cEntidade		= Entidade da qual o conteúdo do campo será retornado.
@cID   			= ID que será buscado.
@cCampo			= Campo do qual o conteúdo será retornado. Default: 'NOME'
-------------------------------------------------------------------------------------*/
function BSCGetValueByID(cEntidade, cID, cCampo)
	Local oTable 	:= oBSCCore:oGetTable(cEntidade)
	Local cRet 		:= ''
	
	Default cCampo := 'NOME'
	
	if(oTable:lSeek(1, {cID}))
		cRet := oTable:cValue(cCampo)
	endif   			
return cRet
                     
function _BSC055_Book()
return
