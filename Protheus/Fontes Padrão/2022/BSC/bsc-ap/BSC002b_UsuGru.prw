// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC002A_UsuGru.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 10.03.04 | 1645 Leandro Marcelino Santos
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC002b_UsuGru.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet->TBITable->TBSC002A
@entity Usuario x Grupo
Usuarios do sistema BSC.
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "GRPUSUARIO"
#define TAG_GROUP  "GRPUSUARIOS"
#define TEXT_ENTITY STR0001/*//"Usuário x Grupo"*/
#define TEXT_GROUP  STR0002/*//"Usuários x Grupos"*/

class TBSC002B from TBITable
	method New() constructor
	method NewBSC002B() 

	method oToXMLUsersByGroup(nGroupID)
	method oToXMLGroupsByUser(nUserID)
	method aUsersByGroup(nGroupID)
	method aGroupsByUser(nUserID)
	method oToXMLList(nGroupID)	
	
endclass
	
method New() class TBSC002B
	::NewBSC002B()
return

method NewBSC002B() class TBSC002B
	// Table
	::NewTable("BSC002B")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID", 		"N"))
	::addField(TBIField():New("CONTEXTID", 	"N"))
	::addField(TBIField():New("PARENTID", 	"N"))
	::addField(TBIField():New("IDUSUARIO",	"N"))

	// Indexes
	::addIndex(TBIIndex():New("BSC002BI01",	{"ID"},.t.))
	::addIndex(TBIIndex():New("BSC002BI02",	{"IDUSUARIO","PARENTID"}, .t.))
	::addIndex(TBIIndex():New("BSC002BI03",	{"PARENTID","IDUSUARIO"}, .t.))
return

// Lista todos os usuarios de um grupo, devolve array de IDs
method aUsersByGroup(nGroupID) class TBSC002B
	local aUsuarios := {}
	    
	::cSQLFilter("PARENTID = " + cBIStr(nGroupID)) // Filtra pelo parametro passado
	::lFiltered(.t.)
	::_First()
	while(!::lEof()) 
		aAdd(aUsuarios, ::nValue("IDUSUARIO"))
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro	
return aUsuarios

// Lista todos os grupos que um usuario esta inserido, devolve array de IDs
method aGroupsByUser(nUserID) class TBSC002B
	local aGrupos := {}
	    
	::cSQLFilter("IDUSUARIO = " + cBIStr(nUserID)) // Filtra pelo parametro passado
	::lFiltered(.t.)
	::_First()
	while(!::lEof()) 
		aAdd(aGrupos, ::nValue("PARENTID"))
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro	
return aGrupos

// Lista XML com todos os usuarios de um grupo
method oToXMLUsersByGroup(nGroupID) class TBSC002B
	local oNode, oAttrib, oXMLNode
	    
	// Instancia Tabela de Usuarios
	oUsuario := ::oOwner():oGetTable("USUARIO")
	oUsuario:SetOrder(1) // Por ordem de ID
	
	// Cria node de Usuarios
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 1)
	oAttrib:lSet("TIPO", "USUARIOS")
	oAttrib:lSet("NOME", "Usuario")
	oXMLNode :=	TBIXMLNode():New("USUARIOS","",oAttrib)

	::cSQLFilter("PARENTID = " + cBIStr(nGroupID)) // Filtra pelo parametro passado
	::lFiltered(.t.)
	::_First()
	while(!::lEof()) 

		// Posiciono Usuario para pegar o Nome
		oUsuario:lSeek(1,{::nValue("IDUSUARIO")})

		// Cria elementos no node de Usuario
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", oUsuario:nValue("PARENTID"))
		oAttrib:lSet("NOME", alltrim(oUsuario:cValue("NOME")))
		oNode:oAddChild(TBIXMLNode():New("USUARIO", "", oAttrib))

		::_Next()
	end
	::cSQLFilter("") // Encerra filtro	

return oXMLNode

// Lista XML com todos os grupos de um usuario
method oToXMLGroupsByUser(nUserID) class TBSC002B
	local oNode, oAttrib, oXMLNode
	    
	// Instancia Tabela de Grupos
	oGrupo := ::oOwner():oGetTable("GRUPO")
	oGrupo:SetOrder(1) // Por ordem de ID
	
	// Cria node de Grupos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 1)
	oAttrib:lSet("TIPO", "GRUPOS")
	oAttrib:lSet("NOME", "Grupo")
	oXMLNode :=	TBIXMLNode():New("GRUPOS","",oAttrib)

	::cSQLFilter("IDUSUARIO = " + cBIStr(::nValue(nUserID))) // Filtra pelo parametro passado
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
method oToXMLList(nGroupID) class TBSC002B
	local oNode, oAttrib, oXMLNode, nInd, cUsuarios, oUsuario
	
	oUsuario := ::oOwner():oGetTable("USUARIO")
	oUsuario:SetOrder(1) // Por ordem de ID
	
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
	// Admin
	oAttrib:lSet("TAG003", "ADMIN")
	oAttrib:lSet("CAB003", STR0005)/*//"Administrador"*/
	oAttrib:lSet("CLA003", BSC_BOOLEAN)

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)

	if(valtype(nGroupID)!="U")
		cUsuarios := cBIConcatWSep(",", ::oOwner():oGetTable("GRPUSUARIO"):aUsersByGroup(nGroupID) )
		cUsuarios := strtran(cUsuarios, '"', "'")
		oUsuario:cSQLFilter("ID IN (" + cUsuarios + ")") // Filtra pelo parametro passado
		oUsuario:lFiltered(.t.)
	endif

	// Gera recheio
	oUsuario:SetOrder(2) // Alfabetica por nomes
	oUsuario:_First()
	while(!oUsuario:lEof())
		if(oUsuario:nValue("ID")!=0)
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := oUsuario:xRecord(RF_ARRAY, {"CONTEXTID","DESCRICAO","SENHA","FONE","RAMAL","EMAIL","AUTENTIC"})
			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			next
		endif	
		oUsuario:_Next()
	end
	oUsuario:cSQLFilter("") // Encerra filtro	

return oXMLNode    

function _BSC002b_UsuGru()
return ::New()