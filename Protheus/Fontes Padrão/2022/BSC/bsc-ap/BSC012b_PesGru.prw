// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC012B_PesGru.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 22.02.05 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC012B_PesGru.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet->TBITable->TBSC012B
@entity Pessoa x Grupo
Pessoas do sistema BSC.
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "GRPXPESSOA"
#define TAG_GROUP  "GRPXPESSOAS"
#define TEXT_ENTITY STR0001/*//"Pessoa x Grupo"*/
#define TEXT_GROUP  STR0002/*//"Pessoas x Grupos"*/

class TBSC012B from TBITable
	method New() constructor
	method NewBSC012B() 

	method oToXMLPersonsByGroup(nGroupID)
	method oToXMLGroupsByPerson(nPersonID)
	method aPersonsByGroup(nGroupID)
	method aGroupsByPerson(nPersonID)
	method oToXMLList(nGroupID)	
	method nDelFromXML(nID)
	
endclass
	
method New() class TBSC012B
	::NewBSC012B()
return

method NewBSC012B() class TBSC012B
	// Table
	::NewTable("BSC012B")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID", 		"N"))
	::addField(TBIField():New("CONTEXTID", 	"N"))
	::addField(TBIField():New("PARENTID", 	"N")) //do grupo
	::addField(TBIField():New("PESSOAID",	"N"))

	// Indexes
	::addIndex(TBIIndex():New("BSC012BI01",	{"ID"},.t.))
	::addIndex(TBIIndex():New("BSC012BI02",	{"PESSOAID","PARENTID"}, .t.))
	::addIndex(TBIIndex():New("BSC012BI03",	{"PARENTID","PESSOAID"}, .t.))
	::addIndex(TBIIndex():New("BSC012BI04",	{"PARENTID"}, .f.))
return

// Lista todos os Pessoas de um grupo, devolve array de IDs
method aPersonsByGroup(nGroupID) class TBSC012B
	local aPessoas := {}
	    
	::cSQLFilter("PARENTID = " + cBIStr(nGroupID)) // Filtra pelo parametro passado
	::lFiltered(.t.)
	::_First()
	while(!::lEof()) 
		aAdd(aPessoas, ::nValue("PESSOAID"))
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro	
return aPessoas

// Lista todos os grupos que um Pessoa esta inserido, devolve array de IDs
method aGroupsByPerson(nPersonID) class TBSC012B
	local aGrupos := {}
	    
	::cSQLFilter("PESSOAID = " + cBIStr(nPersonID)) // Filtra pelo parametro passado
	::lFiltered(.t.)
	::_First()
	while(!::lEof()) 
		aAdd(aGrupos, ::nValue("PARENTID"))
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro	
return aGrupos

// Lista XML com todos os Pessoas de um grupo
method oToXMLPersonsByGroup(nGroupID) class TBSC012B
	local oNode, oAttrib, oXMLNode
	    
	// Instancia Tabela de Pessoas
	oPessoa := ::oOwner():oGetTable("PESSOA")
	oPessoa:SetOrder(1) // Por ordem de ID
	
	// Cria node de Pessoas
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 1)
	oAttrib:lSet("TIPO", "PESSOAS")
	oAttrib:lSet("NOME", "PESSOA")
	oXMLNode :=	TBIXMLNode():New("PESSOAS","",oAttrib)

	::cSQLFilter("PARENTID = " + cBIStr(nGroupID)) // Filtra pelo parametro passado
	::lFiltered(.t.)
	::_First()
	while(!::lEof()) 

		// Posiciono Pessoa para pegar o Nome
		oPessoa:lSeek(1,{::nValue("PESSOAID")})

		// Cria elementos no node de Pessoa
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", oPessoa:nValue("PARENTID"))
		oAttrib:lSet("NOME", alltrim(oPessoa:cValue("NOME")))
		oNode:oAddChild(TBIXMLNode():New("PESSOA", "", oAttrib))

		::_Next()
	end
	::cSQLFilter("") // Encerra filtro	

return oXMLNode

// Lista XML com todos os grupos de um Pessoa
method oToXMLGroupsByPerson(nPersonID) class TBSC012B
	local oNode, oAttrib, oXMLNode
	    
	// Instancia Tabela de Grupos
	oGrupo := ::oOwner():oGetTable("GRUPO")
	oGrupo:SetOrder(1) // Por ordem de ID
	
	// Cria node de Grupos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 1)
	oAttrib:lSet("TIPO", "GRUPOS")
	oAttrib:lSet("NOME", "GRUPO")
	oXMLNode :=	TBIXMLNode():New("GRUPOS","",oAttrib)

	::cSQLFilter("PESSOAID = " + cBIStr(::nValue(nPersonID))) // Filtra pelo parametro passado
	::lFiltered(.t.)
	::_First()
	while(!::lEof()) 

		// Posiciono Grupo para pegar o Nome
		oGrupo:lSeek(1,{::nValue("PARENTID")})
		
		// Cria elementos no node de Grupos
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", oGrupo:nValue("PARENTID"))
		oAttrib:lSet("NOME", alltrim(oGrupo:cValue("NOME")))
		oNode:oAddChild(TBIXMLNode():New("GRUPO", "", oAttrib))

		::_Next()
	end
	::cSQLFilter("") // Encerra filtro	

return oXMLNode

// Lista XML para anexar ao pai
method oToXMLList(nGroupID) class TBSC012B
	local oNode, oAttrib, oXMLNode, nInd, cPessoas, oPessoa
	
	oPessoa := ::oOwner():oGetTable("PESSOA")
	oPessoa:SetOrder(1) // Por ordem de ID
	
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
	oAttrib:lSet("CAB001", STR0003)/*//"Nome"*/
	oAttrib:lSet("CLA001", BSC_STRING)
	// Cargo
	oAttrib:lSet("TAG002", "CARGO")
	oAttrib:lSet("CAB002", STR0004)/*//"Cargo"*/
	oAttrib:lSet("CLA002", BSC_STRING)

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)

	if(valtype(nGroupID)!="U")
		cPessoas := cBIConcatWSep(",", ::oOwner():oGetTable("GRPXPESSOA"):aPersonsByGroup(nGroupID) )
		cPessoas := strtran(cPessoas, '"', "'")
		oPessoa:cSQLFilter("ID IN (" + cPessoas + ")") // Filtra pelo parametro passado
		oPessoa:lFiltered(.t.)
	endif

	// Gera recheio
	oPessoa:SetOrder(2) // Alfabetica por nomes
	oPessoa:_First()
	while(!oPessoa:lEof())
		if(oPessoa:nValue("ID")!=0)
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := oPessoa:xRecord(RF_ARRAY, {"CONTEXTID","DESCRICAO","SENHA","FONE","RAMAL","EMAIL","AUTENTIC"})
			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			next
		endif	
		oPessoa:_Next()
	end
	oPessoa:cSQLFilter("") // Encerra filtro	

return oXMLNode

// Excluir entidade do server
method nDelFromXML(nID) class TBSC012B
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

return nStatus                  

function _BSC012B_PesGru()
return