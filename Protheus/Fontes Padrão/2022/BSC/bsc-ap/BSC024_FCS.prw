// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC024_FCS.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 21.06.04 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC024_FCS.ch"

/*--------------------------------------------------------------------------------------
@entity FCS - Fator Critico de Sucesso
FCS - Fator Critico de Sucesso no BSC. Contém as Indicadores e Compoem Processos
@table BSC024
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "FCS"
#define TAG_GROUP  "FCSS"
#define TEXT_ENTITY STR0001/*//"Fator Critico de Sucesso"*/
#define TEXT_GROUP  STR0002/*//"Fatores Criticos de Sucesso"*/

class TBSC024 from TBITable
	method New() constructor
	method NewBSC024()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID, lFeedBack)
	method oToXMLContextList(nContextID)

	// registro atual
	method oToXMLNode(nParentID, cLoadCmd)
	method oToXMLMapNode()
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	method oMakeCard(dDataAlvo, lParcelada)
	method oXMLCard()
	method nFeedBack()

	method nDuplicate(nParentID, nNewParentID, nNewContextID, aObjIDs, aIndIds)

endclass
	
method New() class TBSC024
	::NewBSC024()
return
method NewBSC024() class TBSC024
	local oField
	
	// Table
	::NewTable("BSC024")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("PERCENTUAL",	"N", 6, 2)) //Percentual de Atendimento pelo Processo
	::addField(oField := TBIField():New("NOME",		"C",	60))
	oField:lSensitive(.f.)
	::addField(TBIField():New("DESCRICAO",	"C",	255))
	::addField(TBIField():New("MAPTYPE",	"N"))
	::addField(TBIField():New("MAPCOLOR",	"N"))
	::addField(TBIField():New("MAPX",	"N"))
	::addField(TBIField():New("MAPY",	"N"))

	// Indexes
	::addIndex(TBIIndex():New("BSC024I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC024I02",	{"NOME", "CONTEXTID"},	.t.))
	::addIndex(TBIIndex():New("BSC024I03",	{"PARENTID", "ID"},	.t.))

return

// nFeedBack
method nFeedBack() class TBSC024
return ::oMakeCard():fnFeedBack

// Arvore
method oArvore(nParentID) class TBSC024
	local oXMLArvore, oNode, oChild
	
	::SetOrder(2) // Por ordem de nome
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
			oAttrib:lSet("NOME", alltrim(::cValue("NOME")))/*//"Nome"*/
			oAttrib:lSet("FEEDBACK", 0)
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			oChild := ::oOwner():oGetTable("FCSIND"):oArvore(::nValue("ID"))
			if(valtype(oChild) == "O")
				oNode:oAddChild(oChild) // Children (Indicadores)
			endif	
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Encerra filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID, lFeedBack) class TBSC024
	local oNode, oAttrib, oXMLNode, nind
	default lFeedBack := .f.
	
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
	::SetOrder(2) // Por ordem de nome
	if nBiVal(nParentID) > 0
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
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","DESCRICAO"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		// Virtuals
		oNode:oAddChild(TBIXMLNode():New("FEEDBACK", if(lFeedBack,::nFeedBack(),0)))
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Lista XML para anexar ao Contexto
method oToXMLContextList(nContextID) class TBSC024
	local oNode, oAttrib, oXMLNode, nind
	
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
	::SetOrder(2) // Por ordem de nome
	::cSQLFilter("CONTEXTID = "+cBIStr(nContextID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID", "CONTEXTID","DESCRICAO"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		// Virtuals
		oNode:oAddChild(TBIXMLNode():New("FEEDBACK", ::nFeedBack()))
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentID, cLoadCMD) class TBSC024
	local nID, aFields, nInd, nOrgId
	local oXMLNode

	if(!empty(cLoadCMD) .and. cLoadCMD == 'CARD')
		oXMLNode := ::oXMLCard()
	else
		//Recebe a lista com os usuarios

		oXMLNode := TBIXMLNode():New(TAG_ENTITY)
		// Acrescenta os valores ao XML
		aFields := ::xRecord(RF_ARRAY)
		for nInd := 1 to len(aFields)
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			if(aFields[nInd][1] == "ID")
				nID := aFields[nInd][2]
			endif
		next
		// Virtuais
		oXMLNode:oAddChild(TBIXMLNode():New("FEEDBACK", ::nFeedBack()))

		// Acrescenta children
		nOrgId := ::oOwner():oAncestor("ORGANIZACAO", self):nValue("ID")

		oXMLNode:oAddChild(::oOwner():oGetTable("FCSIND"):oToXMLList(nID))

		oXMLNode:oAddChild(::oOwner():oContext(self, nParentID))
	endif

return oXMLNode

// Carregar o no para o mapa estrategico Objetivo x Fcs x Processos
method oToXMLMapNode() class TBSC024
	local nID, aFields, nInd
	local oXMLNode
	
	oXMLNode := TBIXMLNode():New(TAG_ENTITY)
	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif
	next         

	oXMLNode:oAddChild(TBIXMLNode():New("FEEDBACK", ::nFeedBack()))
	
	//Usuado na area de trabalho.
	oXMLNode:oAddChild(TBIXMLNode():New("USEROWNER", 0)) // VERIFICAR SE TEM FUNCIONALIDADE

return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC024
	local aFields, nInd, nStatus := BSC_ST_OK, oTable
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
method nUpdFromXML(oXML, cPath) class TBSC024
	local nStatus := BSC_ST_OK,	nID, nInd
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
		endif
	endif
return nStatus

// Excluir entidade do server
method nDelFromXML(nID) class TBSC024
	local nStatus := BSC_ST_OK, oTableChild
	
	::oOwner():oOltpController():lBeginTransaction()

	// Procura por children (Indicadores)
	oTableChild:= ::oOwner():oGetTable("FCSIND")
	oTableChild:SetOrder(3) // Por ordem de ParentId
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo paI
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("FCSIND"):nDelFromXML(oTableChild:nValue("ID"))
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

// Duplica os registros filhos de nParentID, colocando-os como filhos de nNewParentID do contexto nNewContextID
method nDuplicate(nParentID, nNewParentID, nNewContextID) class TBSC024
	local nStatus := BSC_ST_OK, aFields, nOldID, nID
	
	::oOwner():oOltpController():lBeginTransaction()

	::SetOrder(1) // Por ordem de id
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof() .and. nStatus == BSC_ST_OK)
		nOldID := ::nValue("ID")
		// Copia temporario
		aFields := ::xRecord(RF_ARRAY, {"ID", "PARENTID", "CONTEXTID"})
		aAdd( aFields, {"ID",  nID := ::nMakeID()} )
		aAdd( aFields, {"PARENTID", nNewParentID} )
		aAdd( aFields, {"CONTEXTID", nNewContextID} )

		// Grava
		::savePos()
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
			exit
		else

			::restPos()
			nStatus := ::oOwner():oGetTable("FCSIND"):nDuplicate(nOldID, nID, nNewContextID) 
			
			If !(nStatus == BSC_ST_OK)
				Exit				
			Endif

		endif

		::_Next()
	enddo
	::cSQLFilter("") // Zera filtro

	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()

return nStatus

// oMakeCard(dDataAlvo, lParcelada)
// Retorna um objeto TBSCScoreCard preenchido
// @param dDataAlvo - Data na qual o BSC se baseia para analisar os dados e gerar snapshot
method oMakeCard(dDataAlvo, lParcelada) class TBSC024
	local nRecCount := 0, nRecFracasso := 0, nFeedback := 0
	local oIndicador, oIndCard, aIndCards := {}, oCard := TBSCScoreCard():New()
	local nInd := 0, lSuccessLine := .t.  
	local lVerCores := .f., lVerNumeros := .f.

	// Verifica Segurança
	lVerNumeros := ::oOwner():foSecurity:lHasParentAccess("FATOR", ::nValue("ID"), "NUMEROS")
	lVerCores	:= ::oOwner():foSecurity:lHasParentAccess("FATOR", ::nValue("ID"), "CORES")

	// Abre tabela para MakeCard
	oIndicador := ::oOwner():oGetTable("FCSIND")
	oIndicador:SavePos()

	// FATOR
	oCard:fcNome := ::cValue("NOME")
	//oCard:fcDescricao := ::cValue("DESCRICAO")
	oCard:fcEntity := TAG_ENTITY
	oCard:fnEntID := ::nValue("ID")
	oCard:fnPercMeta := 0
	oCard:fnIndicador := 0
	
	// Pré-Calculo Indicadores
	oIndicador:cSQLFilter("PARENTID = "+::cValue("ID")) // Filtra pelo pai
	oIndicador:lFiltered(.t.)
	oIndicador:_First()
	while(!oIndicador:lEof())

		oIndCard := oIndicador:oMakeCard(dDataAlvo, lParcelada)
		if(oIndCard:fnFeedBack != BSC_FB_GRAY)
		
			aAdd(aIndCards, oIndCard)
			if(oIndCard:fnFeedback==BSC_FB_REDDN .or. oIndCard:fnFeedback==BSC_FB_YELLOWDN .or. oIndCard:fnFeedback==BSC_FB_GREENDN .or. oIndCard:fnFeedback==BSC_FB_BLUEDN)
				nFeedback -= 1
			elseif(oIndCard:fnFeedback==BSC_FB_REDUP .or. oIndCard:fnFeedback==BSC_FB_YELLOWUP .or. oIndCard:fnFeedback==BSC_FB_GREENUP .or. oIndCard:fnFeedback==BSC_FB_BLUEUP)
				nFeedback += 1
			endif	
			
			// Se passar alguma vez por aqui indica que nao houve sucesso no FATOR
			if(oIndCard:fnIndicador <= oIndCard:fnAmarelo+oIndCard:fnVermelho)
				lSuccessLine := .f.
			endif

			// Contador de cards considerados
			nRecCount++
		endif	
		oIndicador:_Next()
	end
	oIndicador:RestPos()
	oIndicador:cSQLFilter("") // Encerra filtro

	// Verifica se somente houve indicadores não cinzas
	if(nRecCount > 0)

		// Incialiazação das cores
		oCard:fnVermelho := 33
		oCard:fnAmarelo := 33
		oCard:fnVerde := 34
		oCard:fnAzul := 0

		if(lSuccessLine)

			// Sucesso no cumprimento do FATOR
			for nInd := 1 to nRecCount
				oIndCard := aIndCards[nInd]
				oCard:fnPercMeta += oIndCard:fnPercMeta
            next

			// Percentual da meta
			oCard:fnPercMeta := iif(!lVerNumeros, 0, int(oCard:fnPercMeta/nRecCount))
			oCard:fcPercMeta := cBIStr(oCard:fnPercMeta)+"%"

			oCard:fnIndicador := int(oCard:fnPercMeta*0.66)
			oCard:fnIndicador := iif(oCard:fnIndicador < 0, 0, oCard:fnIndicador)
			oCard:fnIndicador := iif(oCard:fnIndicador > 100, 100, oCard:fnIndicador)
			oCard:fcUnidade   := "%"
			oCard:fnInicial   := 0
			oCard:fnFinal     := iif(!lVerNumeros, 0, iif(oCard:fnPercMeta <= 150, 150, oCard:fnPercMeta))
			oCard:fnAtual     := iif(!lVerNumeros, 0, oCard:fnPercMeta)
			oCard:fnAnterior  := 0
	
		else

			// Fracasso no cumprimento do FATOR
			for nInd := 1 to nRecCount
				oIndCard := aIndCards[nInd]
				// Atenção
				// Este trecho comentado pode voltar a vigorar com definição
				// de que os FATORES atingem 100%+ somente quando seus indicadores todos
				// atingigerem as metas definidas
				//if(oIndCard:fnIndicador <= oIndCard:fnAmarelo+oIndCard:fnVermelho)
					oCard:fnPercMeta += oIndCard:fnPercMeta
				//else
				//	oCard:fnPercMeta += 100
				//endif
				nRecFracasso++
			next

			// Percentual da meta
			oCard:fnPercMeta := int(oCard:fnPercMeta/nRecFracasso)
			oCard:fcPercMeta := cBIStr(oCard:fnPercMeta)+"%"

			oCard:fnIndicador := int(oCard:fnPercMeta*0.66)
			oCard:fnIndicador := iif(oCard:fnIndicador < 0, 0, oCard:fnIndicador)
			oCard:fnIndicador := iif(oCard:fnIndicador > 66, 66, oCard:fnIndicador)
			oCard:fcUnidade   := "%"
			oCard:fnInicial   := 0
			oCard:fnFinal     := iif(!lVerNumeros, 0, iif(oCard:fnPercMeta <= 150, 150, oCard:fnPercMeta))
			oCard:fnAtual     := iif(!lVerNumeros, 0, oCard:fnPercMeta)
			oCard:fnAnterior  := 0

		endif // success line

		// Feedback
		oCard:fnFeedback := BSC_FB_GRAY
		if(lVerCores)
			if(oCard:fnIndicador < oCard:fnVermelho)
				if(nFeedback == 0)
					oCard:fnFeedback := BSC_FB_REDSM
				elseif(nFeedback > 0)
					oCard:fnFeedback := BSC_FB_REDUP
				else
					oCard:fnFeedback := BSC_FB_REDDN
				endif	
			elseif(oCard:fnIndicador < oCard:fnAmarelo+oCard:fnVermelho)
				if(nFeedback == 0)
					oCard:fnFeedback := BSC_FB_YELLOWSM
				elseif(nFeedback > 0)
					oCard:fnFeedback := BSC_FB_YELLOWUP
				else
					oCard:fnFeedback := BSC_FB_YELLOWDN
				endif	
			elseif(oCard:fnIndicador < oCard:fnVerde+oCard:fnAmarelo+oCard:fnVermelho)
				if(nFeedback == 0)
					oCard:fnFeedback := BSC_FB_GREENSM
				elseif(nFeedback > 0)
					oCard:fnFeedback := BSC_FB_GREENUP
				else
					oCard:fnFeedback := BSC_FB_GREENDN
				endif	
			else
				if(nFeedback == 0)
					//oCard:fnFeedback := BSC_FB_BLUESM
					oCard:fnFeedback := BSC_FB_GREENSM
				elseif(nFeedback > 0)
					//oCard:fnFeedback := BSC_FB_BLUEUP
					oCard:fnFeedback := BSC_FB_GREENUP
				else
					//oCard:fnFeedback := BSC_FB_BLUEDN
					oCard:fnFeedback := BSC_FB_GREENDN
				endif	
			endif
		endif
	
	else
		
		// Indicadores apontam cinza
		oCard:fnIndicador := 0
		oCard:fnFeedback := BSC_FB_GRAY

		oCard:fnVermelho := 0
		oCard:fnAmarelo := 0
		oCard:fnVerde := 0
		oCard:fnAzul := 0

		oCard:fnPercMeta := 0
		oCard:fcPercMeta := cBIStr(oCard:fnPercMeta)+"%"

	endif
	
return oCard

// oXMLCard()
// Retorna um no XML completo do card
method oXMLCard() class TBSC024

	local oXMLCard := ::oMakeCard():oToXMLCard()
	oXMLCard:oAddChild(TBIXMLNode():New("ID", ::nValue("ID")))
	oXMLCard:oAddChild(TBIXMLNode():New("ORDEM", 0))
	oXMLCard:oAddChild(TBIXMLNode():New("CARDX", 0))
	oXMLCard:oAddChild(TBIXMLNode():New("CARDY", 0))
	oXMLCard:oAddChild(::oOwner():oGetTable("FCSIND"):oToXMLList(::nValue("ID")))

return oXMLCard      

function _BSC024_Fcs()
return
