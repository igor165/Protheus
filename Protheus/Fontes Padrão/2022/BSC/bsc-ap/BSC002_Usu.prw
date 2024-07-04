// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC002_Est.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC002_Usu.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet->TBITable->TBSC002
@entity Usuario
Usuarios do sistema BSC.
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "USUARIO"
#define TAG_GROUP  "USUARIOS"
#define TEXT_ENTITY STR0001 // "Usuário"
#define TEXT_GROUP  STR0002 // "Usuários"

class TBSC002 from TBITable

	data faRegra

	method New() constructor
	method NewBSC002() 

	method oArvore()
	method oToXMLList()
	method oXMLUserProtheus()

	method oToXMLNode()
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	
	method nSqlCount()
	method getRegra(nIDOwner,cNomeEnt,nEntId)
	
endclass
	
method New() class TBSC002
	::NewBSC002()
return
method NewBSC002() class TBSC002
	// Table
	::NewTable("BSC002")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID", 		"N"))
	::addField(TBIField():New("CONTEXTID", 	"N"))
	::addField(TBIField():New("PARENTID", 	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(TBIField():New("NOME", 		"C", 	25))
	::addField(TBIField():New("SENHA", 		"C", 	40))
	::addField(TBIField():New("COMPNOME",	"C",	30))
	::addField(TBIField():New("CARGO",		"C",	20))
	::addField(TBIField():New("FONE",		"C",	20))
	::addField(TBIField():New("RAMAL",		"C",	10))
	::addField(TBIField():New("EMAIL",		"C",	80))
	::addField(TBIField():New("ADMIN",		"L"))
	::addField(TBIField():New("AUTENTIC",	"N"))
	::addField(TBIField():New("USERPROT",	"L"))
	::addField(TBIField():New("UPDTREE",	"L"))
	
	// Indexes
	::addIndex(TBIIndex():New("BSC002I01",	{"ID"},	.t.))
	::addIndex(TBIIndex():New("BSC002I02",	{"NOME", "CONTEXTID"}, .t.))
	
	// Vetor com Regras de Segurança.
	// Não alterar a ordem dos registros que ja existem em ACESSO_ORG.
	::faRegra := { {"ORGANIZACAO", { {"ARQUITETURA", BSC_SEC_ARQUITETURA	, STR0008 /*"Arquitetura"*/ 		},;
								  { "REUNIOES"		, BSC_SEC_REUNIOES		, STR0009 /*"Reuniões"*/ 			},;
								  { "PESSOAS"		, BSC_SEC_PESSOAS 		, STR0010 /*"Pessoas"*/ 			} } },;
				{"ESTRATEGIA",	{ { "ARQUITETURA"	, BSC_SEC_ARQUITETURA	, STR0011 /*"Arquitetura"*/ 		},;
								  { "PAINEIS"		, BSC_SEC_PAINEIS		, STR0012 /*"Painéis"*/ 			},;
								  { "RELATORIOS"	, BSC_SEC_RELATORIOS	, STR0013 /*"Relatórios"*/ 			},;
								  { "GRAFICOS"		, BSC_SEC_GRAFICOS		, STR0014 /*"Gráficos"*/ 			},;
								  { "NUMEROS"		, BSC_SEC_NUMEROS		, STR0015 /*"Ver Números"*/ 		},;
								  { "CORES"			, BSC_SEC_CORES			, STR0016 /*"Ver Cores"*/ 			},;
								  { "ACESSOEST"		, BSC_SEC_ACESSOEST		, STR0017 /*"Acessar Estratégia"*/	} } },;
				{"PERSPECTIVA",	{ { "NUMEROS"		, BSC_SEC_NUMEROS		, STR0015 /*"Ver Números"*/ 		},;
								  { "CORES"			, BSC_SEC_CORES			, STR0016 /*"Ver Cores"*/ 			} } },;
				{"OBJETIVO",	{ { "NUMEROS"		, BSC_SEC_NUMEROS		, STR0015 /*"Ver Números"*/ 		},;
								  { "CORES"			, BSC_SEC_CORES			, STR0016 /*"Ver Cores"*/ 			} } },;
				{"INDICADOR",	{ { "METAS"			, BSC_SEC_METAS			, STR0018 /*"Metas"*/ 				},;
								  { "AVALIACOES"	, BSC_SEC_AVALIACOES	, STR0019 /*"Avaliações"*/ 			},;
								  { "PLANILHAS"		, BSC_SEC_PLANILHAS		, STR0020 /*"Planilhas"*/			},;
								  { "FONTEDADOS"	, BSC_SEC_FONTEDADOS	, STR0021 /*"Fontes de Dados"*/ 	},;
								  { "DOCUMENTOS"	, BSC_SEC_DOCUMENTOS	, STR0022 /*"Documentos"*/ 			},;
								  { "NUMEROS"		, BSC_SEC_NUMEROS		, STR0015 /*"Ver Números"*/ 		},;
								  { "CORES"			, BSC_SEC_CORES			, STR0016 /*"Ver Cores"*/ 			} } },;
				{"ACESSOS_ORGA",{ { "ACESSAR_ORG"	, BSC_SEC_ACESSAORG		, STR0023 /*"Acessar Organização"*/	}}},;    
				{"INICIATIVA",	{ { "TAREFAS"		, BSC_SEC_TAREFAS		, STR0024 /*"Tarefas"*/ 			},;
								  { "RETORNOS"		, BSC_SEC_RETORNOS		, STR0025 /*"Retornos"*/ 			},;
								  { "DOCUMENTOS"	, BSC_SEC_DOCUMENTOS	, STR0026 /*"Documentos"*/ 			} } } }
	
return

// Árvore
method oArvore() class TBSC002
	local oNode, oAttrib
	
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 1)
	oAttrib:lSet("TIPO", "USUARIOS")
	oAttrib:lSet("NOME", STR0002) //"Usuários"
	oNode := TBIXMLNode():New("USUARIOS","",oAttrib)

	::SetOrder(2) // Alfabetica por nomes.
	::_First()
	while(!::lEof())
		if(::nValue("ID")!=0)
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", ::nValue("ID"))
			oAttrib:lSet("NOME", alltrim(::cValue("NOME")))
			oAttrib:lSet("FEEDBACK", ::nValue("FEEDBACK"))
			oNode:oAddChild(TBIXMLNode():New("USUARIO", "", oAttrib))
		endif	
		::_Next()
	end
return oNode

// Lista XML para anexar ao pai
method oToXMLList() class TBSC002
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
	// PrimNome
	oAttrib:lSet("TAG001", "COMPNOME")
	oAttrib:lSet("CAB001", STR0004)/*//"Nome"*/
	oAttrib:lSet("CLA001", BSC_STRING)
	// Cargo
	oAttrib:lSet("TAG002", "CARGO")
	oAttrib:lSet("CAB002", STR0005)/*//"Cargo"*/
	oAttrib:lSet("CLA002", BSC_STRING)
	// Admin
	oAttrib:lSet("TAG003", "ADMIN")
	oAttrib:lSet("CAB003", STR0006)/*//"Administrador"*/
	oAttrib:lSet("CLA003", BSC_BOOLEAN)

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)

	// Gera o recheio
	::SetOrder(2) // Alfabetica por nomes
	::_First()
	while(!::lEof())
		if(::nValue("ID")!=0)
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"CONTEXTID","DESCRICAO","SENHA","FONE","RAMAL","EMAIL","AUTENTIC"})
			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			next
		endif	
		::_Next()
	end

return oXMLNode

// Carregar
method oToXMLNode() class TBSC002
	local nID, aFields, nInd
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)  

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
	next
	oXMLNode:oAddChild(::oXMLUserProtheus())
	
return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC002
	local aFields, nInd, cNome, nParentID, nStatus := BSC_ST_OK
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "SENHA")
			aFields[nInd][2] := cBIStr2Hex(pswencript(aFields[nInd][2]))
		endif	
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
method nUpdFromXML(oXML, cPath) class TBSC002
	local nInd, nStatus := BSC_ST_OK, nID
	private oXMLInput := oXML
	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		elseif(aFields[nInd][1] == "SENHA")
			if(!empty(aFields[nInd][2]))
				aFields[nInd][2] := cBIStr2Hex(pswencript(aFields[nInd][2]))
			else
				aFields[nInd] := NIL
			endif
		endif	
	next
	aFields := aBIPackArray(aFields)

	// Verifica condições de gravação (append ou update)
	if(!::lSeek(1, {nID}))
		nStatus := BSC_ST_BADID
	else
		if(!::lUpdate(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE // Único.
			else
				nStatus := BSC_ST_INUSE
			endif
		endif
	endif    

return nStatus

// Exclui entidade
method nDelFromXML(nID) class TBSC002
	local nStatus := BSC_ST_OK
	local oDeskTop:= ::oOwner():oGetTable("DESKTOP")
	
	if(nID!=1)
		// Deleta o elemento
		if(nStatus != BSC_ST_HASCHILD)
			if(::lSeek(1, {nID}))
				if(!::lDelete())
					nStatus := BSC_ST_INUSE
				else
					oDeskTop:cSQLFilter("USUARIOID = " + cBIStr(nID)) // Filtra pelo pai
					oDeskTop:lFiltered(.t.)
					oDeskTop:_First()
					while(!oDeskTop:lEof())
						if(!oDeskTop:lDelete())
							nStatus := BSC_ST_INUSE
						endif
						oDeskTop:_Next()
					end
					oDeskTop:cSQLFilter("") // Encerra filtro
				endif
			else
				nStatus := BSC_ST_BADID
			endif	
	    endif

	else
		nStatus := BSC_ST_NORIGHTS
	endif	                                    
	
return nStatus

method nSqlCount() class TBSC002
	local nCount
	
	nCount := _Super:nSqlCount()
	
	if(::lSeek(1,{0}))
		nCount--
	endif

return nCount


method getRegra(nIDOwner,cNomeEnt,nEntId) class TBSC002    
	local nStatus 	:= BSC_ST_OK
	local oRegra 	:= ::oOwner():oGetTable("REGRA")
	local oXMLNode 	:= TBIXMLNode():New("REGRAS")  
	local oNode 	:= nil 
	local cAtributo	:= ""
	local nPos		:= 0
	local nJ		:= 0
        
	nPos :=ascan(::faRegra,{|x| x[1] == cNomeEnt})
	if nPos !=0
		for nJ := 1 to len(::faRegra[nPos,2])  
			oNode := oXMLNode:oAddChild(TBIXMLNode():New("REGRA"))    
			
			oNode:oAddChild(TBIXMLNode():New("NOME", ::faRegra[nPos,2,nJ,3]))
			oNode:oAddChild(TBIXMLNode():New("IDOPERACAO", ::faRegra[nPos,2,nJ,2])) 
			oNode:oAddChild(TBIXMLNode():New("IDENT", nEntId))
			oNode:oAddChild(TBIXMLNode():New("NOMEENT", cNomeEnt))
						
			if (oRegra:lSeek(4, {"U", nIDOwner , padr(cNomeEnt,30) , nEntId , ::faRegra[nPos,2,nJ,2] }))
				oNode:oAddChild(TBIXMLNode():New("VALOR", oRegra:lValue("PERMITIDA")))
				oNode:oAddChild(TBIXMLNode():New("IDREGRA", oRegra:cValue("ID")))
			else   
				oNode:oAddChild(TBIXMLNode():New("VALOR", .f.))
				oNode:oAddChild(TBIXMLNode():New("IDREGRA", 0))
			endif  
			
		next	
    endif         
    
return oXMLNode


method oXMLUserProtheus() class TBSC002
	local oXMLNode, oNode, oAttrib, aUsuarios, nInd
	         
	__ap5nomv(.t.)
	aUsuarios := FWSFAllUsers()
    __ap5nomv(.f.)

	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .F.)
	oXMLNode := TBIXMLNode():New("NOMES",,oAttrib)
	
	// Acrescenta os Usuarios ao XML
	for nInd := 1 to len(aUsuarios)
		oNode := oXMLNode:oAddChild(TBIXMLNode():New("NOME"))
		oNode:oAddChild(TBIXMLNode():New("ID", nInd))
		oNode:oAddChild(TBIXMLNode():New("NOME", aUsuarios[nInd,3]))
	next

return oXMLNode

function _BSC002_Usu()
return ::New()
