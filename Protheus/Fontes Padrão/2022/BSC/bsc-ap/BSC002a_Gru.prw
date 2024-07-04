// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC002a_Gru.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 17.03.04 | 1645 Leandro Marcelino Santos
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC002a_Gru.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet->TBITable->TBSC002A
@entity Grupo
Grupos de Usuarios do sistema BSC.
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "GRUPO"
#define TAG_GROUP  "GRUPOS"
#define TEXT_ENTITY STR0001/*//"Grupo"*/
#define TEXT_GROUP  STR0002/*//"Grupos"*/

class TBSC002A from TBITable
	data faRegra
	
	method New() constructor
	method NewBSC002A() 

	method oArvore()
	method oToXMLList()

	method oToXMLNode()
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)

	method nSqlCount()
	method getRegra(nIDOwner,cNomeEnt,nEntId)

endclass
	
method New() class TBSC002A
	::NewBSC002A()
return
method NewBSC002A() class TBSC002A
	local oField

	// Table
	::NewTable("BSC002A")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID", 		"N"))
	::addField(TBIField():New("CONTEXTID", 	"N"))
	::addField(TBIField():New("PARENTID", 	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(oField := TBIField():New("NOME", 		"C", 	30))
	oField:lSensitive(.f.)

	// Indexes
	::addIndex(TBIIndex():New("BSC002AI01",	{"ID"},	.t.))
	::addIndex(TBIIndex():New("BSC002AI02",	{"NOME", "CONTEXTID"}, .t.))
return

// Arvore
method oArvore() class TBSC002A
	local oXMLNode, oNode, oAttrib

	oUsuario := ::oOwner():oGetTable("USUARIO")
	oUsuario:SetOrder(1) // Por ordem de ID

	oGrpUsuario := ::oOwner():oGetTable("GRPUSUARIO")
	oGrpUsuario:SetOrder(3) // Por ordem de ID de Grupo
	
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 1)
	oAttrib:lSet("TIPO", "GRUPOS")
	oAttrib:lSet("NOME", STR0002) //"Grupos"
	oXMLNode := TBIXMLNode():New("GRUPOS","",oAttrib)

	::SetOrder(2) // Alfabetica por nomes
	::_First()
	while(!::lEof())
		if(::nValue("ID")!=0)
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", ::nValue("ID"))
			oAttrib:lSet("NOME", alltrim(::cValue("NOME")))
			oAttrib:lSet("FEEDBACK", ::nValue("FEEDBACK"))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New("GRUPO", "", oAttrib))
			
			oGrpUsuario:cSQLFilter("PARENTID = "+cBIStr(::nValue("ID"))) // Filtra pelo pai
			oGrpUsuario:lFiltered(.t.)
			oGrpUsuario:_First()
			if(!oGrpUsuario:lEof())
				oAttrib := TBIXMLAttrib():New()
				oAttrib:lSet("ID", 1)
				oAttrib:lSet("TIPO", "USUARIOS")
				oAttrib:lSet("NOME", STR0024)//"Usuários"
				oNode := oNode:oAddChild(TBIXMLNode():New("USUARIOS","",oAttrib))

				while(!oGrpUsuario:lEof())
					oUsuario:lSeek(1,{oGrpUsuario:nValue("IDUSUARIO")})
					oAttrib := TBIXMLAttrib():New()
					oAttrib:lSet("ID", oUsuario:nValue("ID"))
					oAttrib:lSet("NOME", alltrim(oUsuario:cValue("NOME")))
					oAttrib:lSet("FEEDBACK", oUsuario:nValue("FEEDBACK"))
					oNode:oAddChild(TBIXMLNode():New("USUARIO", "", oAttrib))

					oGrpUsuario:_Next()
                end                    
            endif
			oGrpUsuario:cSQLFilter("") // Encerra filtro	
		endif	
		::_Next()
	end
return oXMLNode

// Lista XML para anexar ao pai
method oToXMLList() class TBSC002A
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
	::SetOrder(2) // Alfabetica por nomes
	::_First()
	while(!::lEof())
		if(::nValue("ID")!=0)
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"CONTEXTID"})
			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			next
		endif	
		::_Next()
	end
return oXMLNode

// Carregar
method oToXMLNode() class TBSC002A
	local nID, aFields, nInd, oNode
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)  
	local oOrg := ::oOWner():oGetTable("ORGANIZACAO")

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
	next
	
	// Filhos
	oXMLNode:oAddChild(::oOwner():oGetTable("GRPUSUARIO"):oToXMLList(nID))

	// Combo
	oXMLNode:oAddChild(::oOwner():oGetTable("USUARIO"):oToXMLList())

	// Organização
	oNode := oXMLNode:oAddChild(oOrg:oToXMLList())

return oXMLNode
  


// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC002A
	local aFields, nInd, oTable, aGrpUsuario, nStatus := BSC_ST_OK
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
	else

		// Extrai e grava lista de pessoas nos grupo (GRPUSUARIO)
		oTable := ::oOwner():oGetTable("GRPUSUARIO")
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_GRPUSUARIOS"), "_GRPUSUARIO"))!="U")
			if(valtype(&("oXMLInput:"+cPath+":_GRPUSUARIOS:_GRPUSUARIO"))=="A")
				for nInd := 1 to len(&("oXMLInput:"+cPath+":_GRPUSUARIOS:_GRPUSUARIO"))
					aGrpUsuario := &("oXMLInput:"+cPath+":_GRPUSUARIOS:_GRPUSUARIO["+cBIStr(nInd)+"]")
					oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
						{"CONTEXTID", ::nValue("CONTEXTID")}, {"IDUSUARIO", nBIVal(aGrpUsuario:_ID:TEXT)} })
				next	
			elseif(valtype(&("oXMLInput:"+cPath+":_GRPUSUARIOS:_GRPUSUARIO"))=="O")
				aGrpUsuario := &("oXMLInput:"+cPath+":_GRPUSUARIOS:_GRPUSUARIO")
				oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
					{"CONTEXTID", ::nValue("CONTEXTID")}, {"IDUSUARIO", nBIVal(aGrpUsuario:_ID:TEXT)} })
			endif
		endif	
	endif	
return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC002A
	local aFields, nStatus := BSC_ST_OK, nID, oGrpUsuario, aTarCob, nInd
	private oXMLInput := oXML, oTable
	
	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
	next
	aFields := aBIPackArray(aFields)

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
		else


			// Apaga lista
			oTable := ::oOwner():oGetTable("GRPUSUARIO")
			oTable:cSQLFilter("PARENTID = "+cBIStr(::nValue("ID"))) // Filtra pelo pai
			oTable:lFiltered(.t.)
			oTable:_First()
			while(!oTable:lEof())
				oTable:lDelete()
				oTable:_Next()
			enddo
			oTable:cSQLFilter("") // Encerra filtro	
   		
			// Extrai e grava lista de pessoas em grupos (GRPUSUARIOS)
			if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_GRPUSUARIOS"), "_GRPUSUARIO"))!="U")
				if(valtype(&("oXMLInput:"+cPath+":_GRPUSUARIOS:_GRPUSUARIO"))=="A") 
					for nInd := 1 to len(&("oXMLInput:"+cPath+":_GRPUSUARIOS:_GRPUSUARIO"))
						aGrpUsuario := &("oXMLInput:"+cPath+":_GRPUSUARIOS:_GRPUSUARIO["+cBIStr(nInd)+"]")
						oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
							{"CONTEXTID", ::nValue("CONTEXTID")}, {"IDUSUARIO", nBIVal(aGrpUsuario:_ID:TEXT)} })
					next	
				elseif(valtype(&("oXMLInput:"+cPath+":_GRPUSUARIOS:_GRPUSUARIO"))=="O")
					aGrpUsuario := &("oXMLInput:"+cPath+":_GRPUSUARIOS:_GRPUSUARIO")
					oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
						{"CONTEXTID", ::nValue("CONTEXTID")}, {"IDUSUARIO", nBIVal(aGrpUsuario:_ID:TEXT)} })
				endif
			endif	
		endif	
	endif
return nStatus

// Exclui entidade
method nDelFromXML(nID) class TBSC002A
	local nStatus := BSC_ST_OK

	// Procura por children (GrpUsuario)
	oGrpUsuario := ::oOwner():oGetTable("GRPUSUARIO")
	if(oGrpUsuario:lSoftSeek(3, {nID}))
    	if(oGrpUsuario:nValue("PARENTID")==nID)
			nStatus := BSC_ST_HASCHILD
    	endif
    endif	
	
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

method nSqlCount() class TBSC002A
	local nCount
	
	nCount := _Super:nSqlCount()
	
	if(::lSeek(1,{0}))
		nCount--
	endif

return nCount

method getRegra(nIDOwner,cNomeEnt,nEntId) class TBSC002A    
	local nStatus 	:= BSC_ST_OK
	local oRegra 	:= ::oOwner():oGetTable("REGRA")
	local oXMLNode 	:= TBIXMLNode():New("REGRAS")  
	local oNode 	:= nil 
	local cAtributo	:= ""
	local nPos		:= 0
	local nJ		:= 0 
	local aRegra	:= {}
	
	
	// Array com Regras de Segurança
	aRegra := { {"ORGANIZACAO", { { "ARQUITETURA"	, BSC_SEC_ARQUITETURA	, STR0005 /*"Arquitetura"*/ 		},;
								  { "REUNIOES"		, BSC_SEC_REUNIOES		, STR0006 /*"Reuniões"*/ 			},;
								  { "PESSOAS"		, BSC_SEC_PESSOAS 		, STR0007 /*"Pessoas"*/ 			} } },;
				{"ESTRATEGIA",	{ { "ARQUITETURA"	, BSC_SEC_ARQUITETURA	, STR0008 /*"Arquitetura"*/ 		},;
								  { "PAINEIS"		, BSC_SEC_PAINEIS		, STR0009 /*"Painéis"*/ 			},;
								  { "RELATORIOS"	, BSC_SEC_RELATORIOS	, STR0010 /*"Relatórios"*/ 			},;
								  { "GRAFICOS"		, BSC_SEC_GRAFICOS		, STR0011 /*"Gráficos"*/ 			},;
								  { "NUMEROS"		, BSC_SEC_NUMEROS		, STR0012 /*"Ver Números"*/ 		},;
								  { "CORES"			, BSC_SEC_CORES			, STR0013 /*"Ver Cores"*/ 			},;
								  { "ACESSOEST"		, BSC_SEC_ACESSOEST		, STR0014 /*"Acessar Estratégia"*/	} } },;
				{"PERSPECTIVA",	{ { "NUMEROS"		, BSC_SEC_NUMEROS		, STR0012 /*"Ver Números"*/ 		},;
								  { "CORES"			, BSC_SEC_CORES			, STR0013 /*"Ver Cores"*/ 			} } },;
				{"OBJETIVO",	{ { "NUMEROS"		, BSC_SEC_NUMEROS		, STR0012 /*"Ver Números"*/ 		},;
								  { "CORES"			, BSC_SEC_CORES			, STR0013 /*"Ver Cores"*/ 			} } },;
				{"INDICADOR",	{ { "METAS"			, BSC_SEC_METAS			, STR0015 /*"Metas"*/ 				},;
								  { "AVALIACOES"	, BSC_SEC_AVALIACOES	, STR0016 /*"Avaliações"*/ 			},;
								  { "PLANILHAS"		, BSC_SEC_PLANILHAS		, STR0017 /*"Planilhas"*/ 			},;
								  { "FONTEDADOS"	, BSC_SEC_FONTEDADOS	, STR0018 /*"Fontes de Dados"*/ 	},;
								  { "DOCUMENTOS"	, BSC_SEC_DOCUMENTOS	, STR0019 /*"Documentos"*/ 			},;
								  { "NUMEROS"		, BSC_SEC_NUMEROS		, STR0012 /*"Ver Números"*/ 		},;
								  { "CORES"			, BSC_SEC_CORES			, STR0013 /*"Ver Cores"*/ 			} } },;
				{"ACESSOS_ORGA",{ { "ACESSAR_ORG"	, BSC_SEC_ACESSAORG		, STR0020 /*"Acessar Organização"*/	} } },;
				{"INICIATIVA",	{ { "TAREFAS"		, BSC_SEC_TAREFAS		, STR0021 /*"Tarefas"*/ 			},;
								  { "RETORNOS"		, BSC_SEC_RETORNOS		, STR0022 /*"Retornos"*/ 			},;
								  { "DOCUMENTOS"	, BSC_SEC_DOCUMENTOS	, STR0023 /*"Documentos"*/ 			} } } }
		                                
	::faRegra	:= aRegra 
   
	nPos :=ascan(::faRegra,{|x| x[1] == cNomeEnt})
	if nPos !=0
		for nJ := 1 to len(::faRegra[nPos,2])  
			oNode := oXMLNode:oAddChild(TBIXMLNode():New("REGRA"))    
			
			oNode:oAddChild(TBIXMLNode():New("NOME", ::faRegra[nPos,2,nJ,3]))
			oNode:oAddChild(TBIXMLNode():New("IDOPERACAO", ::faRegra[nPos,2,nJ,2])) 
			oNode:oAddChild(TBIXMLNode():New("IDENT", nEntId))
			oNode:oAddChild(TBIXMLNode():New("NOMEENT", cNomeEnt))
						
			if (oRegra:lSeek(4, {"G", nIDOwner , padr(cNomeEnt,30) , nEntId , ::faRegra[nPos,2,nJ,2] }))
				oNode:oAddChild(TBIXMLNode():New("VALOR", oRegra:lValue("PERMITIDA")))
				oNode:oAddChild(TBIXMLNode():New("IDREGRA", oRegra:cValue("ID")))
			else   
				oNode:oAddChild(TBIXMLNode():New("VALOR", .f.))
				oNode:oAddChild(TBIXMLNode():New("IDREGRA", 0))
			endif  
			
		next	
    endif         
    
return oXMLNode   

function _BSC002a_Gru()
return ::New()


