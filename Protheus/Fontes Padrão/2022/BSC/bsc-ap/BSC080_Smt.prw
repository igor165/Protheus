// ######################################################################################
// Projeto: BSC
// Modulo : Configuracao de Envio de Mensagens e Avisos SMTP
// Esta tabela soh contem um registro com o ID 1, obrigatoriamente.
// Fonte  : BSC080_SMT.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 24.09.04 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC080_SMT.ch"

/*--------------------------------------------------------------------------------------
@class TBSC080
@entity Mensagem
Envio de Mensagens e avisos do sistemas.
@table BSC080
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "SMPTCONF"
#define TAG_GROUP  "SMPTCONFS"
#define TEXT_ENTITY STR0001/*//"Configuracao"*/
#define TEXT_GROUP  STR0002/*//"Configuracoes"*/

class TBSC080 from TBITable
	method New() constructor
	method NewBSC080()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)

	// registro atual
	method oToXMLNode(nParentID)
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	method nDuplicate(nParentID, nNewParentID, nNewContextID)
	method SendMail(cServer, cPorta, cConta, cUsuario, cSenha, cTo, cAssunto, cCorpo, cAnexos)
endclass

method New() class TBSC080
	::NewBSC080()
return

method NewBSC080() class TBSC080
	local oField
	// Table
	::NewTable("BSC080")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(oField := TBIField():New("NOME",	"C",120)) //Conta de email
	oField:lSensitive(.f.)
	::addField(TBIField():New("SERVIDOR",	"C",	120)) //Servidor SMTP
	oField:lSensitive(.f.)
	::addField(TBIField():New("PORTA",		"C",	4))	  //Porta SMTP
	::addField(TBIField():New("USUARIO",	"C", 	50)) //Nome do Usuario para autenticacao
	::addField(TBIField():New("SENHA",		"C", 	50)) //Senha de autenticacao
	// Indexes
	::addIndex(TBIIndex():New("BSC080I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC080I02",	{"NOME", "CONTEXTID"}))
	::addIndex(TBIIndex():New("BSC080I03",	{"PARENTID", "ID"}))
return

// Arvore
method oArvore(nParentID) class TBSC080
	local oXMLArvore, oNode
	
	// Tag conjunto
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 1)
	oAttrib:lSet("TIPO", TAG_GROUP)
	oAttrib:lSet("NOME", TEXT_GROUP)
	oXMLArvore := TBIXMLNode():New(TAG_GROUP,"",oAttrib)

 	::SetOrder(2) // Ordem de conta de email
	::cSQLFilter("ID = "+cBIStr('1')) // Filtra pelo ID 1
	::lFiltered(.t.)
	::_First()
	// Nodes
	while(!::lEof())
		// Nao lista o ID 0, de inclusao
		if(::nValue("ID")==0)
			::_Next()
			loop
		endif			

		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", ::nValue("ID"))
		oAttrib:lSet("NOME", alltrim(::cValue("NOME")))
		oAttrib:lSet("FEEDBACK", ::nValue("FEEDBACK"))
		oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
		::_Next()
	enddo
	::cSQLFilter("") // Retira filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC080
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Conta de email para envio
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", STR0003) /*Conta de email*/
	oAttrib:lSet("CLA000", BSC_STRING)
	// Servidor SMTP
	oAttrib:lSet("TAG001", "SERVIDOR")
	oAttrib:lSet("CAB001", STR0004)/*//"Servidor SMTP"*/
	oAttrib:lSet("CLA001", BSC_STRING)
	// Porta SMTP
	oAttrib:lSet("TAG002", "PORTA")
	oAttrib:lSet("CAB002", STR0005)/*//"Porta SMTP"*/
	oAttrib:lSet("CLA002", BSC_STRING)
	// Usuario para Autenticacao
	oAttrib:lSet("TAG003", "USUARIO")
	oAttrib:lSet("CAB003", STR0006)/*//"Usuario para Autenticacao"*/
	oAttrib:lSet("CLA003", BSC_STRING)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(2) // Por ordem de conta
	::cSQLFilter("ID = "+cBIStr('1')) // Filtra pelo ID 1
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","SENHA"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentID) class TBSC080
	local nID, nParentID, aFields, nInd, nOrgID
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		elseif(aFields[nInd][1] == "PARENTID")
			nOrgID := aFields[nInd][2]
		endif
	next

	if(nID != 0)
		nParentId := nOrgId
	endif

return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC080
	local aFields, nInd, aREUCON, oTable, nStatus := BSC_ST_OK
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
method nUpdFromXML(oXML, cPath) class TBSC080
	local nStatus := BSC_ST_OK,	nID, nInd
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			nID := 1 //o ID será sempre 1
		endif	
	next

	// Verifica condições de gravação (append ou update)
	if(!::lSeek(1, {nID})) //o ID será sempre 1
		// Grava
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif
		//nStatus := BSC_ST_BADID
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
method nDelFromXML(nID) class TBSC080
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

// Duplica os registros filhos de nParentID, colocando-os como filhos de nNewParentID do contexto nNewContextID
method nDuplicate(nParentID, nNewParentID, nNewContextID) class TBSC080
	local nStatus := BSC_ST_OK, aFields, nID
	
	::oOwner():oOltpController():lBeginTransaction()

	::SetOrder(1) // Por ordem de id
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		// Copia temporario
		aFields := ::xRecord(RF_ARRAY, {"ID", "PARENTID", "CONTEXTID"})
		aAdd( aFields, {"ID",  nID := ::nMakeID()} )
		aAdd( aFields, {"PARENTID", nNewParentID} )
		aAdd( aFields, {"CONTEXTID", nNewContextID} )

		// Grava
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
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

// metodo de envio de email
method SendMail(cServer, cPorta, cConta, cUsuario, cSenha, cTo, cAssunto, cCorpo, cAnexos, cFrom, cCopia, cOculto) class TBSC080
	Local oCarteiro	:= Nil

	Default cFrom 	:= ""
	Default cCopia 	:= ""
	Default cOculto 	:= ""

	oCarteiro := TBIMailSender():New()
	oCarteiro:setServidor(cServer, cPorta)
	oCarteiro:setConta(cConta)
	oCarteiro:setUsuario(cUsuario, cSenha)

	oCarteiro:SendMessage( cTo, cAssunto, cCorpo, cAnexos, cFrom, cCopia, cOculto)
return nil
                        
function _BSC080_Smt()
return
