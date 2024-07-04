// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC010_Org.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC010_Org.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet->TBITable->TBSC010
Container principal do sistema, contém todos os elementos.
@entity: Organização
@table BSC010
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "ORGANIZACAO"
#define TAG_GROUP  "ORGANIZACOES"
#define TEXT_ENTITY STR0001 // "Organização"
#define TEXT_GROUP  STR0002 // "Organizações"

class TBSC010 from TBITable
	method New() constructor
	method NewBSC010()

	// diversos registros
	method oArvore()
	method oToXMLList()

	// registro atual
	method oToXMLNode()
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	
	method nDuplicate(nID, nNewParentID, nNewContextID)
endclass
	
method New() class TBSC010
	::NewBSC010()
return
method NewBSC010() class TBSC010
	local oField

	// Table
	::NewTable("BSC010")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",		"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(oField := TBIField():New("NOME",		"C",	60))
	oField:lSensitive(.f.)
	::addField(TBIField():New("DESCRICAO",	"C",	255))
	::addField(TBIField():New("MISSAO",	"C",	255))
	::addField(TBIField():New("VISAO",		"C",	255))
	::addField(TBIField():New("NOTAS",		"C",	255))
	::addField(TBIField():New("QUALIDADE",	"C",	255))
	::addField(TBIField():New("VALORES",	"C",	255))
	::addField(TBIField():New("ENDERECO",	"C",	120))
	::addField(TBIField():New("CIDADE",	"C",	20))
	::addField(TBIField():New("ESTADO",	"C",	20))
	::addField(TBIField():New("PAIS",		"C",	20))
	::addField(TBIField():New("FONE",		"C",	20))
	::addField(TBIField():New("EMAIL",		"C",	80))
	::addField(TBIField():New("PAGINA",	"C",	80))

	// Indexes
	::addIndex(TBIIndex():New("BSC010I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC010I02",	{"NOME", "CONTEXTID"},	.t.))
return

// Arvore
method oArvore(nID) class TBSC010
	local oXMLArvore, oNode, oTable, oChild

	// Organizações.
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 1)
	oAttrib:lSet("TIPO", TAG_GROUP)
	oAttrib:lSet("NOME", TEXT_GROUP)
	oXMLArvore := TBIXMLNode():New(TAG_GROUP,"",oAttrib)

	::SetOrder(2) // Alfabetica por nomes.
	::cSQLFilter("ID = " + cBIStr(nID)) 
	::lFiltered(.T.)
	::_First() 
	while(!::lEof())

		// Nao lista o ID 0, de inclusao
		if(::nValue("ID")==0)
			::_Next()
			loop
		endif			

		oTable := ::oOwner():oGetTable("ESTRATEGIA")
		oChild := oTable:oArvore(::nValue("ID"))
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", ::nValue("ID"))
		oAttrib:lSet("NOME", alltrim(::cValue("NOME")))
		oAttrib:lSet("FEEDBACK", ::nValue("FEEDBACK"))

		if(valtype(oChild) == "O")
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			oNode:oAddChild(oChild) // Children (Estrategias)
		elseif(::oOwner():foSecurity:oLoggedUser():lValue("ADMIN") .or. ::oOwner():foSecurity:lHasAccess("ORGANIZACAO", ::nValue("ID"), "CARREGAR")) //se for Administrador
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
		endif
		                      
		::_Next()
	enddo      
	
	::cSQLFilter("")
	
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList() class TBSC010
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
	// Cidade
	oAttrib:lSet("TAG001", "CIDADE")
	oAttrib:lSet("CAB001", STR0003)/*//"Cidade"*/
	oAttrib:lSet("CLA001", BSC_STRING)
	// Estado
	oAttrib:lSet("TAG002", "ESTADO")
	oAttrib:lSet("CAB002", STR0004)/*//"Estado"*/
	oAttrib:lSet("CLA002", BSC_STRING)
	// Pais
	oAttrib:lSet("TAG003", "PAIS")
	oAttrib:lSet("CAB003", STR0005)/*//"País"*/
	oAttrib:lSet("CLA003", BSC_STRING)
	// Gera no principal.
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(1)
	::_First()    
	
	while(!::lEof())

		// Nao lista o ID 0, de inclusao
		if(::nValue("ID")==0)
			::_Next()
			loop
		endif		
		
		if(::oOwner():foSecurity:oLoggedUser():lValue("ADMIN") .or. ::oOwner():foSecurity:lHasAccess("ORGANIZACAO", ::nValue("ID"), "CARREGAR"))
		
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"DESCRICAO","MISSAO","VISAO","NOTAS","QUALIDADE","VALORES","ENDERECO","FONE","EMAIL","PAGINA"})
			
			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			next    
		 
		endif
		::_Next()
	end
return oXMLNode

// Carregar.
method oToXMLNode() class TBSC010
	local oTable, nID, aFields, nInd
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
	next

	// Estrategias
	oTable := ::oOwner():oGetTable("ESTRATEGIA")
	oXMLNode:oAddChild( oTable:oToXMLList(nID) )

	// Pessoas
	oTable := ::oOwner():oGetTable("PESSOA")
	oXMLNode:oAddChild( oTable:oToXMLList(nID) )
	
	// Grupo de Pessoas
	oTable := ::oOwner():oGetTable("PGRUPO")
	oXMLNode:oAddChild( oTable:oToXMLList(nID) )

	// Reunioes
	oTable := ::oOwner():oGetTable("REUNIAO")
	oXMLNode:oAddChild( oTable:oToXMLList(nID) )
return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC010
	local aFields,cNome
	local nCopyParent, nInd, nStatus := BSC_ST_OK 
	
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
			nStatus := BSC_ST_UNIQUE // Status único.
		else
			nStatus := BSC_ST_INUSE
		endif
	Else  
		/*Recebe o ID da organização que será copiada.*/ 
		nCopyParent :=  nBIVal(&("oXMLInput:"+cPath+":_COPY_PARENT:TEXT"))
	    /*A duplicação ocorre quando for passado o ID da organização original.*/
		If ((nInd := aScan(aFields, {|x| x[1] == "CONTEXTID"})) > -1) .And. (nCopyParent > 0)
			::nDuplicate( nCopyParent, ::nValue("id"), nBIVal(aFields[nInd, 2]) )
		EndIf
	endif
	
return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC010
	local nStatus := BSC_ST_OK,	nID, cSenha, nInd
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
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
		endif	
	endif
return nStatus

// Excluir entidade do server
method nDelFromXML(nID) class TBSC010
	Local nStatus 		:= BSC_ST_OK
	Local oEstrategia 	:= ::oOwner():oGetTable("ESTRATEGIA") 
	Local oPessoa 		:= ::oOwner():oGetTable("PESSOA")    
	Local oGrupoPessoa	:= ::oOwner():oGetTable("PGRUPO")  
	Local oReuniao		:= ::oOwner():oGetTable("REUNIAO")

	::oOwner():oOltpController():lBeginTransaction()

	//Remove as ESTRATEGIAS.
	oEstrategia:SetOrder(3) 
	While(!oEstrategia:lEof() .AND. oEstrategia:nValue("PARENTID") == nID .AND. nStatus == BSC_ST_OK)
		nStatus := oEstrategia:nDelFromXML(oEstrategia:nValue("ID"))
		oEstrategia:_Next()
	EndDo

	//Remove as PESSOAS.
	oPessoa:SetOrder(3) 
	While(!oPessoa:lEof() .AND. oPessoa:nValue("PARENTID") == nID .AND. nStatus == BSC_ST_OK)
		nStatus := oPessoa:nDelFromXML(oPessoa:nValue("ID"))
		oPessoa:_Next() 		
	EndDo        
	
	//Remove os GRUPOS DE PESSOAS.
	oGrupoPessoa:SetOrder(3)
	While(!oGrupoPessoa:lEof() .AND. oGrupoPessoa:nValue("PARENTID") == nID .AND. nStatus == BSC_ST_OK)
		nStatus := oGrupoPessoa:nDelFromXML(oGrupoPessoa:nValue("ID"))
		oGrupoPessoa:_Next()
	EndDo

	//Remove as REUNIOES.
	oReuniao:SetOrder(3) 
	While(!oReuniao:lEof() .AND. oReuniao:nValue("PARENTID") == nID .AND. nStatus == BSC_ST_OK)
		nStatus := oReuniao:nDelFromXML(oReuniao:nValue("ID"))
		oReuniao:_Next()
	EndDo

	//Remove a ORGANIZACAO.
	If(nStatus == BSC_ST_OK)
		If(::lSeek(1, {nID}))
			If(!::lDelete())
				nStatus := BSC_ST_INUSE
			endIf
		Else
			nStatus := BSC_ST_BADID
		EndIf	
    EndIf

	If(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	EndIf

	::oOwner():oOltpController():lEndTransaction()

return nStatus

// Duplica o registro nID
method nDuplicate(nID, nNewID, nNewContextID) class TBSC010
	local nStatus := BSC_ST_OK, aFields
	Local oEstrategia	:= ::oOwner():oGetTable("ESTRATEGIA")
	Local oPessoa		:= ::oOwner():oGetTable("PESSOA")
	Local oGrupos		:= ::oOwner():oGetTable("PGRUPO")
	Local oReuniao		:= ::oOwner():oGetTable("REUNIAO")
	
	default nID 	:= ::cValue("id")
	default nNewID	:= 0
	
	::oOwner():oOltpController():lBeginTransaction()

	::SetOrder(1) // Por ordem de id
	::cSQLFilter("ID = "+cBIStr(nID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	
	If !::lEof()
		If nNewID < 1
			// Copia temporario
			aFields := ::xRecord(RF_ARRAY, {"ID", "PARENTID", "CONTEXTID"})
			aAdd( aFields, {"ID",  nNewID := ::nMakeID()} )
			aAdd( aFields, {"PARENTID", nID} )
			aAdd( aFields, {"CONTEXTID", nNewContextID} )
	
			// Grava
			If(!::lAppend(aFields))
				if(::nLastError()==DBERROR_UNIQUE)
					nStatus := BSC_ST_UNIQUE
				else
					nStatus := BSC_ST_INUSE
				endif
			EndIf
		EndIf
		
		//Duplica elementos filhos da organização.		
		
		//Duplica Estratégias.
		If ( nStatus == BSC_ST_OK )	 	
		   	
		   	oEstrategia:SetOrder(1) 
			oEstrategia:cSqlFilter("PARENTID = " + cBIStr(nID))
			oEstrategia:lFiltered(.t.)
			oEstrategia:_First()

			/*Realiza a duplicação de todas as estrattégia de uma determinada organização.*/
		    While ( !oEstrategia:lEof() ) 
				Conout(STR0006 + oEstrategia:cValue("NOME")) /*"Duplicando estratégia "*/				
				nStatus := oEstrategia:nDuplicate(oEstrategia:nValue("id"), nNewID, nNewContextID)
				oEstrategia:_Next()
			EndDo 
			
			oEstrategia:cSQLFilter("")
										
		EndIf
		
		//Duplica as pessoas cadastradas.
		If nStatus == BSC_ST_OK
			nStatus := oPessoa:nDuplicate(nID, nNewID, nNewContextID)
		EndIf
		
		//Duplica os grupos cadastrados.
		If nStatus == BSC_ST_OK         
			nStatus := oGrupos:nDuplicate(nID, nNewID, nNewContextID)
		EndIf
		
		//Duplica as reuniões cadastradas.
		If nStatus == BSC_ST_OK
			nStatus := oReuniao:nDuplicate(nID, nNewID, nNewContextID)
		EndIf
		
	EndIf
	
	::cSQLFilter("") 

	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()

return nStatus

function _bsc010_org()
return