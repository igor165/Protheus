// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC012A_Gru.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 23.02.05 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC012A_Gru.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet->TBITable->TBSC012A
@entity Grupo
Grupos de PESSOAs do sistema BSC.
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "PGRUPO"
#define TAG_GROUP  "PGRUPOS"
#define TEXT_ENTITY STR0001/*//"Grupo de Pessoas"*/
#define TEXT_GROUP  STR0002/*//"Grupos de Pessoas"*/

class TBSC012A from TBITable
	method New() constructor
	method NewBSC012A() 

	method oArvore()
	method oToXMLList( nParentID )

	method oToXMLNode( nParentID )
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	method cGetGrupoName(nID)
	method nDuplicate(nParentID, nNewParentID, nNewContextID)
endclass
	
method New() class TBSC012A
	::NewBSC012A()
return
method NewBSC012A() class TBSC012A
	local oField

	// Table
	::NewTable("BSC012A")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID", 		"N"))
	::addField(TBIField():New("CONTEXTID", 	"N"))
	::addField(TBIField():New("PARENTID", 	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(oField := TBIField():New("NOME", "C", 	30))
	oField:lSensitive(.f.)
	::addField(TBIField():New("DESCRICAO",	"C", 255))

	// Indexes
	::addIndex(TBIIndex():New("BSC012AI01",	{"ID"},	.t.))
	::addIndex(TBIIndex():New("BSC012AI02",	{"NOME", "CONTEXTID"}, .t.))
	::addIndex(TBIIndex():New("BSC012AI03",	{"PARENTID", "ID"}))
	::addIndex(TBIIndex():New("BSC012AI04",	{"PARENTID"}))
return

// Árvore.
method oArvore() class TBSC012A
	local oXMLNode, oNode, oAttrib

	oPessoa := ::oOwner():oGetTable("PESSOA")
	oPessoa:SetOrder(1) // Por ordem de ID

	oGrpxPes := ::oOwner():oGetTable("GRPXPESSOA")
	oGrpxPes:SetOrder(3) // Por ordem de ID de Grupo (parentID)
	
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 1)
	oAttrib:lSet("TIPO", "GRPXPESSOAS")
	oAttrib:lSet("NOME", "Grupos de Pesoas")
	oXMLNode := TBIXMLNode():New("GRPXPESSOAS","",oAttrib)

	::SetOrder(2) // Alfabética por nomes.
	::_First()
	while(!::lEof())
		if(::nValue("ID")!=0)
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", ::nValue("ID"))
			oAttrib:lSet("NOME", alltrim(::cValue("NOME")))
			oAttrib:lSet("FEEDBACK", ::nValue("FEEDBACK"))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New("GRPXPESSOA", "", oAttrib))
			
			oGrpxPes:cSQLFilter("PARENTID = "+cBIStr(::nValue("ID"))) // Filtra pelo pai
			oGrpxPes:lFiltered(.t.)
			oGrpxPes:_First()
			if(!oGrpxPes:lEof())
				oAttrib := TBIXMLAttrib():New() // Novo atributo.
				oAttrib:lSet("ID", 1)
				oAttrib:lSet("TIPO", "PESSOAS")
				oAttrib:lSet("NOME", "Pessoas do grupo")
				oNode := oNode:oAddChild(TBIXMLNode():New("PESSOAS","",oAttrib))

				while(!oGrpxPes:lEof())
				
					oPessoa:lSeek(1,{oGrpxPes:nValue("PESSOAID")})

					oAttrib := TBIXMLAttrib():New()
					oAttrib:lSet("ID", oPessoa:nValue("ID"))
					oAttrib:lSet("NOME", alltrim(oPessoa:cValue("NOME")))
					oAttrib:lSet("FEEDBACK", oPessoa:nValue("FEEDBACK"))
					oNode:oAddChild(TBIXMLNode():New("PESSOA", "", oAttrib))

					oGrpxPes:_Next()
                end                    
            endif
			oGrpxPes:cSQLFilter("") // Limpar o filtro	
		endif	
		::_Next()
	end
return oXMLNode

// Lista XML para anexar ao pai
method oToXMLList( nParentID ) class TBSC012A
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
	// Descricao
	oAttrib:lSet("TAG001", "DESCRICAO")
	oAttrib:lSet("CAB001", STR0003) //Descrição
	oAttrib:lSet("CLA001", BSC_STRING)

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)

	// Gera recheio
	::SetOrder(2) // Alfabetica por nomes
	if(!empty(nParentID))
		::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	else
		::cSQLFilter("ID <> "+cBIStr(0))
	endif
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"CONTEXTID"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro

return oXMLNode

// Carregar
method oToXMLNode( nParentID ) class TBSC012A
	local nID, aFields, nInd, nOrgID
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif
		if(aFields[nInd][1] == "PARENTID")
			nOrgID := aFields[nInd][2]
		endif
	next

	if(nID != 0)
		nParentId := nOrgId
	endif

	// Filhos
	oXMLNode:oAddChild(::oOwner():oGetTable("GRPXPESSOA"):oToXMLList(nID))

	// Acrescenta combos, listas
	oXMLNode:oAddChild(::oOwner():oGetTable("PESSOA"):oToXMLList(nParentId))

	oXMLNode:oAddChild(::oOwner():oContext(self, nParentId))

return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC012A
	local aFields, nInd, oTable, aGRPXPESSOA, nStatus := BSC_ST_OK
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

		// Extrai e grava lista de pessoas nos grupo (GRPXPESSOA)
		oTable := ::oOwner():oGetTable("GRPXPESSOA")
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_GRPXPESSOAS"), "_GRPXPESSOA"))!="U")
			if(valtype(&("oXMLInput:"+cPath+":_GRPXPESSOAS:_GRPXPESSOA"))=="A")
				for nInd := 1 to len(&("oXMLInput:"+cPath+":_GRPXPESSOAS:_GRPXPESSOA"))
					aGRPXPESSOA := &("oXMLInput:"+cPath+":_GRPXPESSOAS:_GRPXPESSOA["+cBIStr(nInd)+"]")
					oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
						{"CONTEXTID", ::nValue("CONTEXTID")}, {"PESSOAID", nBIVal(aGRPXPESSOA:_ID:TEXT)} })
				next	
			elseif(valtype(&("oXMLInput:"+cPath+":_GRPXPESSOAS:_GRPXPESSOA"))=="O")
				aGrpXPessoa := &("oXMLInput:"+cPath+":_GRPXPESSOAS:_GRPXPESSOA")
				oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
					{"CONTEXTID", ::nValue("CONTEXTID")}, {"PESSOAID", nBIVal(aGRPXPESSOA:_ID:TEXT)} })
			endif
		endif	
	endif	
return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC012A
	local aFields, nStatus := BSC_ST_OK, nID, oGRPXPESSOA, aTarCob, nInd
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
			oTable := ::oOwner():oGetTable("GRPXPESSOA")
			oTable:cSQLFilter("PARENTID = "+cBIStr(::nValue("ID"))) // Filtra pelo pai
			oTable:lFiltered(.t.)
			oTable:_First()
			while(!oTable:lEof())
				oTable:lDelete()
				oTable:_Next()
			enddo
			oTable:cSQLFilter("") // Encerra filtro	
   		
			// Extrai e grava lista de pessoas em grupos (GRPXPESSOA)
			if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_GRPXPESSOAS"), "_GRPXPESSOA"))!="U")
				if(valtype(&("oXMLInput:"+cPath+":_GRPXPESSOAS:_GRPXPESSOA"))=="A") 
					for nInd := 1 to len(&("oXMLInput:"+cPath+":_GRPXPESSOAS:_GRPXPESSOA"))
						aGRPXPESSOA := &("oXMLInput:"+cPath+":_GRPXPESSOAS:_GRPXPESSOA["+cBIStr(nInd)+"]")
						oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
							{"CONTEXTID", ::nValue("CONTEXTID")}, {"PESSOAID", nBIVal(aGRPXPESSOA:_ID:TEXT)} })
					next	
				elseif(valtype(&("oXMLInput:"+cPath+":_GRPXPESSOAS:_GRPXPESSOA"))=="O")
					aGRPXPESSOA := &("oXMLInput:"+cPath+":_GRPXPESSOAS:_GRPXPESSOA")
					oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
						{"CONTEXTID", ::nValue("CONTEXTID")}, {"PESSOAID", nBIVal(aGRPXPESSOA:_ID:TEXT)} })
				endif
			endif	
		endif	
	endif
return nStatus

// Exclui entidade
method nDelFromXML(nID) class TBSC012A
	local nStatus := BSC_ST_OK

	::oOwner():oOltpController():lBeginTransaction()

	// Procura por children (GRPXPESSOA)
	oTableChild:= ::oOwner():oGetTable("GRPXPESSOA")
	oTableChild:SetOrder(3) // Por ordem de ParentId
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo paI
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("GRPXPESSOA"):nDelFromXML(oTableChild:nValue("ID"))
		oTableChild:_Next()
	enddo
	oTableChild:cSQLFilter("") // Limpa o filtro

	// Deleta o elemento
	if(nStatus == BSC_ST_OK)
		if(::lSeek(1, {nID}))
			if(!::lDelete())
				nStatus := BSC_ST_INUSE
			endif
		else
			nStatus := BSC_ST_BADID
		endif	
    endif

	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()

return nStatus

method cGetGrupoName(nID) class TBSC012A
	local cGrupoName := STR0004 // "Grupo nao localizada"

	if(::lSeek(1, {nID}))
		cGrupoName := ::cValue("NOME")
	endif

return cGrupoName

// Duplica os registros filhos de nParentID, colocando-os como filhos de nNewParentID do contexto nNewContextID
method nDuplicate(nParentID, nNewParentID, nNewContextID) class TBSC012A
	local nStatus := BSC_ST_OK, aFields, nID
	Local oGrpVsPessoas := ::oOwner():oGetTable("GRPXPESSOA")
	Local oAppdGrpVsPes := ::oOwner():oGetTable("GRPXPESSOA")
	Local oPessoa := ::oOwner():oGetTable("PESSOA")
	
	::oOwner():oOltpController():lBeginTransaction()

	::SetOrder(1) // Por ordem de id
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	
	while !::lEof() .and. nStatus == BSC_ST_OK .and. ::nValue("PARENTID") == nParentID
		// Copia temporario
		aFields := ::xRecord(RF_ARRAY, {"ID", "PARENTID", "CONTEXTID", "NOME"})
		aAdd( aFields, {"ID",  nID := ::nMakeID()} )
		aAdd( aFields, {"PARENTID", nNewParentID} )
		aAdd( aFields, {"CONTEXTID", nNewContextID} )
		aAdd( aFields, {"NOME", "DUP_" + ::cValue("NOME")})
		
		// Grava
		::SavePos()
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		Else
			::RestPos()
			// pesquisa pelas pessoas do grupo que está sendo duplicado
			If oGrpVsPessoas:lSeek(4, { ::nValue("id") })
				While nStatus == BSC_ST_OK .and. !oGrpVsPessoas:lEoF() .and. oGrpVsPessoas:nValue("parentid") == ::nValue("id")
					// procura pela pessoa específica do grupo sendo duplicado
					If oPessoa:lSeek(1, { oGrpVsPessoas:nValue("PESSOAID") })
						// procura pelo nome da pessoa no novo registro de pessoas
						If oPessoa:lSeek(2, { oPessoa:cValue("NOME"), nNewParentID })
							oGrpVsPessoas:SavePos()
							
							aFields := {}
							aAdd( aFields, {"ID", oAppdGrpVsPes:nMakeID()} )
							aAdd( aFields, {"CONTEXTID", nNewContextID} )
							aAdd( aFields, {"PARENTID", nID} )
							aAdd( aFields, {"PESSOAID", oPessoa:nValue("ID") })
							
							If !oAppdGrpVsPes:lAppend(aFields)
								if(oAppdGrpVsPes:nLastError()==DBERROR_UNIQUE)
									nStatus := BSC_ST_UNIQUE
								else
									nStatus := BSC_ST_INUSE
								endif
							EndIf
							oGrpVsPessoas:RestPos()
						EndIf
					EndIf
					
					oGrpVsPessoas:_Next()
				EndDo
			EndIf
		endif
		::RestPos()

		::_Next()
	enddo
	::cSQLFilter("") // Zera filtro

	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()

return nStatus                    

function _BSC012A_Gru()
return