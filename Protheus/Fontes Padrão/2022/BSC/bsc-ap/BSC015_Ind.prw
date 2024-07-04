// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC015_Ind.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC015_Ind.ch"

/*--------------------------------------------------------------------------------------
@entity Indicador
Indicador no BSC. Contém os alvos.
Indicador de performance. Indicadores estao atreladas a objetivos.
@table BSC015
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "INDICADOR"
#define TAG_GROUP  "INDICADORES"
#define TEXT_ENTITY STR0001/*//"Indicador"*/
#define TEXT_GROUP  STR0002/*//"Indicadores"*/

class TBSC015 from TBITable
	method New() constructor
	method NewBSC015()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)
	method oContextList(nContextID)
	method oToEntityList(cEntity, aIDs)
	method aCompletado(cNomeUsuario, dDataDe, dDataAte)
	method nExecute(cCmd)

	// registro atual
	method oToXMLNode(nParentID, cLoadCMD)
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	method nFeedBack()
	method oXMLUnidade()
	method oXMLFrequencia()
	method oXMLTipoMonts()
	method oGetFrequencia(nFreq)
	method oMakeCard(dDataAlvo, lParcelada)
	method oXMLCard()
	method getFreqText(nIdFrequencia)

	method nDuplicate(nParentID, nNewParentID, nNewContextID, aIndIds)

endclass
	
method New() class TBSC015
	::NewBSC015()
return
method NewBSC015() class TBSC015
	local oField
	
	// Tabela.
	::NewTable("BSC015")
	::cEntity(TAG_ENTITY)
	// Campos.
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(oField := TBIField():New("NOME",		"C",	60))
	oField:lSensitive(.f.)
	::addField(TBIField():New("DESCRICAO",	"C",	255))
	::addField(TBIField():New("UNIDADE",	"C", 	25))	// String indica Unidade
	::addField(TBIField():New("DECIMAIS",	"N"))	// Numero de casas decimais
	oField := TBIField():New("PESO",		"N")	// Peso do indicador
	oField:bDefault({|| 1})
	::addField(oField)
	::addField(TBIField():New("FREQ",		"N"))	// Constante no bscdefs.ch indica Frequencia
	::addField(TBIField():New("ASCEND",		"L"))
	::addField(TBIField():New("TIPOIND",	"C",	1)) //" "=Resultado, "T"=Tendencia

	// Responsável.
	::addField(TBIField():New("RESPID",		"N"))	// ID de pessoa responsavel pela cobranca
	::addField(TBIField():New("TIPOPESSOA",	"C",	1)) //G = Grupo, P = Individual

	// Acumulador.
	::addField(TBIField():New("CUMULATIVO",	"L"))   // acumula as entradas
	::addField(TBIField():New("FCUMULA",	"N"))   // frequencia de acumulador
	::addField(TBIField():New("TCUMULA",	"N"))   // tipo de acumulador

	// Coleta.
	::addField(TBIField():New("MEDRESPID",	"N"))	// ID de pessoa responsavel pela medicao
	::addField(TBIField():New("MEDTIPOPES",	"C",	1)) //G = Grupo, P = Individual
	::addField(TBIField():New("METRICA",	"C",	255))  // descricao da metrica
	::addField(TBIField():New("FORMA",		"C",	255))  // descricao da forma de coleta

	// Referencia
	::addField(TBIField():New("RNOME",		"C",	60))
	::addField(TBIField():New("RDESCRICAO",	"C",	255))
	::addField(TBIField():New("RUNIDADE",	"C", 	25))	// String indica Unidade
	::addField(TBIField():New("RDECIMAIS",	"N"))	// Numero de casas decimais
	oField := TBIField():New("RPESO",		"N")	// Peso
	oField:bDefault({|| 1})
	::addField(oField)
	::addField(TBIField():New("RFREQ",		"N"))	// Constante no bscdefs.ch indica Frequencia
	::addField(TBIField():New("RRESPID",	"N"))	// ID de pessoa responsavel pela cobranca
	::addField(TBIField():New("RTIPOPES",	"C",	1)) //G = Grupo, P = Individual

	// Indexes
	::addIndex(TBIIndex():New("BSC015I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC015I02",	{"NOME", "CONTEXTID"},	.t.))
	::addIndex(TBIIndex():New("BSC015I03",	{"PARENTID", "ID"},	.t.))
	::addIndex(TBIIndex():New("BSC015I04",	{"TIPOIND", "NOME", "CONTEXTID"}, .f.))
	::addIndex(TBIIndex():New("BSC015I05",	{"PARENTID", "NOME"},	.f.))
	::addIndex(TBIIndex():New("BSC015I06",	{"PARENTID"},	.f.))
return

// nFeedBack
method nFeedBack() class TBSC015
return ::oMakeCard():fnFeedBack

// Arvore
method oArvore(nParentID) class TBSC015
	local oXMLArvore, oNode
	
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
			oAttrib:lSet("TIPOIND", alltrim(::cValue("TIPOIND")))
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Limpar o filtro.
return oXMLArvore

// Lista XML para anexar ao pai, de todas as Indicadores de um objetivo / estrategia
method oToEntityList(cEntity, aIDs) class TBSC015
	local oNode, oAttrib, oXMLNode
	local oTable, cIDs, nInd
	
	if(cEntity=="ESTRATEGIA")
		cIDs := cBIConcatWSep(",", aIDs) // Converter os IDs em cadeia para sql
		cIDs := strtran(cIDs, '"', "'")
		aIds := {} // Limpar Ids

		oTable := ::oOwner():oGetTable("PERSPECTIVA")
		oTable:SetOrder(2) // Por ordem de nome
		oTable:cSQLFilter("PARENTID IN ("+cIDs+")") // Filtra pelo pai
		oTable:lFiltered(.t.)
		oTable:_First()
		while(!oTable:lEof())
			aAdd(aIDs, oTable:nValue("ID"))
			oTable:_Next()
		end
		oTable:cSQLFilter("") // Encerra filtro

		cIDs := cBIConcatWSep(",", aIDs) // Converter os IDs em cadeia para sql
		cIDs := strtran(cIDs, '"', "'")
		aIds := {} // Limpar Ids

		oTable := ::oOwner():oGetTable("OBJETIVO")
		oTable:SetOrder(2) // Por ordem de nome
		oTable:cSQLFilter("PARENTID IN ("+cIDs+")") // Filtra pelo pai
		oTable:lFiltered(.t.)
		oTable:_First()
		while(!oTable:lEof())
			aAdd(aIDs, oTable:nValue("ID"))
			oTable:_Next()
		end
		oTable:cSQLFilter("") // Limpar o filtro.

	endif
	
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
	
	// Gera o recheio
	cIDs := cBIConcatWSep(",", aIDs) // Converter os IDs em cadeia para sql
	cIDs := strtran(cIDs, '"', "'")
	::SetOrder(4) // Por ordem de Tipo de indicador + nome
	::cSQLFilter("PARENTID IN ("+cIDs+")") // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		//aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","UNIDADE","FREQ","RESPID","DATASRCID","TIPOPESSOA"})
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","UNIDADE","DATASRCID","TIPOPESSOA"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		oNode:oAddChild(TBIXMLNode():New("FEEDBACK", ::nFeedBack()))
		::_Next()
	end
	::cSQLFilter("") // Limpar o filtro
return oXMLNode

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC015
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
	   
	::SavePos()
	::SetOrder(2)
	
    If (::lSeek(6,{cBIStr(nParentID)} ) )

		While(!::lEof() .And. ::cValue("PARENTID") == cBIStr(nParentID))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","UNIDADE","FREQ","RESPID","DATASRCID","TIPOPESSOA"})
			
			For nInd := 1 to Len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			Next
			
			oNode:oAddChild(TBIXMLNode():New("FEEDBACK", ::nFeedBack()))
			::_Next()
		End      
	EndIf

	::RestPos() 
	
return oXMLNode

// Lista XML para anexar ao pai
method oContextList(nContextID) class TBSC015
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
	::SetOrder(2) // Por ordem de nome
	::cSQLFilter("CONTEXTID = "+cBIStr(nContextID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","DATASRCID"})
//		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","UNIDADE","FREQ","RESPID","DATASRCID"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode


// Unidade
method oXMLUnidade() class TBSC015
	local oAttrib, oNode, oXMLOutput
	local nInd, aUnidades := { "Reais", "Dólares", "Kgs", "Tons", "%", "Pontos" }
	
	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("UNIDADES",,oAttrib)

	for nInd := 1 to len(aUnidades)
		oNode := oXMLOutput:oAddChild(TBIXMLNode():New("UNIDADE"))
		oNode:oAddChild(TBIXMLNode():New("ID", nInd))
		oNode:oAddChild(TBIXMLNode():New("NOME", aUnidades[nInd]))
	next
return oXMLOutput

// Frequencia
method oXMLFrequencia() class TBSC015
	local oAttrib, oNode, oXMLOutput

	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("FREQUENCIAS",,oAttrib)
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("FREQUENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", BSC_FREQ_ANUAL))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0004))	//Anual
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("FREQUENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", BSC_FREQ_SEMESTRAL))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0005))	//Semestral
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("FREQUENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", BSC_FREQ_QUADRIMESTRAL))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0006))	//Quadrimestral
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("FREQUENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", BSC_FREQ_TRIMESTRAL))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0007))	//Trimestral
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("FREQUENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", BSC_FREQ_BIMESTRAL))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0008))	//Bimestral
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("FREQUENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", BSC_FREQ_MENSAL))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0009))	//Mensal
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("FREQUENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", BSC_FREQ_QUINZENAL))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0010))	//Quinzenal
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("FREQUENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", BSC_FREQ_SEMANAL))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0011))	//Semanal
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("FREQUENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", BSC_FREQ_DIARIA))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0012))	//Diaria

return oXMLOutput

// Frequencia
method oGetFrequencia(nFreq) class TBSC015
	local aFrequencias := {}
	aadd(aFrequencias,STR0004)	//Anual
	aadd(aFrequencias,STR0005)	//Semestral
	aadd(aFrequencias,STR0007)	//Trimestral
	aadd(aFrequencias,STR0008)	//Bimestral
	aadd(aFrequencias,STR0009)	//Mensal
	aadd(aFrequencias,STR0010)	//Quinzenal
	aadd(aFrequencias,STR0011)	//Semanal
	aadd(aFrequencias,STR0012)	//Diaria
	aadd(aFrequencias,STR0006)	//Quadrimestral
return if(nFreq>0,aFrequencias[nFreq],"")

// Tipos de Montante
method oXMLTipoMonts() class TBSC015
	local oAttrib, oNode, oXMLOutput

	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("TIPOMONTS",,oAttrib)
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("TIPOMONT"))
	oNode:oAddChild(TBIXMLNode():New("ID", BSC_MT_SUM))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0013)) // Somatório
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("TIPOMONT"))
	oNode:oAddChild(TBIXMLNode():New("ID", BSC_MT_AVG))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0014)) // Média
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("TIPOMONT"))
	oNode:oAddChild(TBIXMLNode():New("ID", BSC_MT_EDT))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0015)) // Editável

return oXMLOutput


// Carregar
method oToXMLNode(nParentID, cLoadCMD) class TBSC015
	local nID, aFields, nInd, oXMLNode, oTable
	local cTipoPessoa, nRespID, cRefTpPessoa, nRefRespId, cColTpPessoa, nColRespId
	local oDWConsulta	:=	::oOwner():oGetTable("DWCONSULTA")	
	local oUser		 	:=	::oOwner():foSecurity:oLoggedUser()
	
	if(!empty(cLoadCMD) .and. cLoadCMD == 'CARD')
		oXMLNode := ::oXMLCard()
	else
	
		oXMLNode := TBIXMLNode():New(TAG_ENTITY)
		// Acrescenta os valores ao XML
		aFields := ::xRecord(RF_ARRAY)
		for nInd := 1 to len(aFields)
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			if(aFields[nInd][1] == "ID")
				nID := aFields[nInd][2]
			elseif(aFields[nInd][1] == "RESPID")
				nRespId := aFields[nInd][2]
			elseif(aFields[nInd][1] == "TIPOPESSOA")
				cTipoPessoa := aFields[nInd][2]
			elseif(aFields[nInd][1] == "MEDRESPID")
				nColRespId := aFields[nInd][2]
			elseif(aFields[nInd][1] == "MEDTIPOPES")
				cColTpPessoa := aFields[nInd][2]
			elseif(aFields[nInd][1] == "RRESPID")
				nRefRespId := aFields[nInd][2]
			elseif(aFields[nInd][1] == "RTIPOPES")
				cRefTpPessoa := aFields[nInd][2]
			endif	
		next
		// Virtuais
		if(cTipoPessoa=="G")
			oTable := ::oOwner():oGetTable("PGRUPO")
		else
			oTable := ::oOwner():oGetTable("PESSOA")
		endif
		oTable:lSeek(1, {nRespId})
		oXMLNode:oAddChild(TBIXMLNode():New("RESPONSAVEL", oTable:cValue("NOME")))

		if(cRefTpPessoa=="G")
			oTable := ::oOwner():oGetTable("PGRUPO")
		else
			oTable := ::oOwner():oGetTable("PESSOA")
		endif
		oTable:lSeek(1, {nRefRespId})
		oXMLNode:oAddChild(TBIXMLNode():New("RRESPONSAVEL", oTable:cValue("NOME")))

		// Virtuais
		if(cColTpPessoa=="G")
			oTable := ::oOwner():oGetTable("PGRUPO")
		else
			oTable := ::oOwner():oGetTable("PESSOA")
		endif
		oTable:lSeek(1, {nColRespId})
		oXMLNode:oAddChild(TBIXMLNode():New("CRESPONSAVEL", oTable:cValue("NOME")))

		oXMLNode:oAddChild(TBIXMLNode():New("FEEDBACK", ::nFeedBack()))
		
		// Acrescenta combos
		oXMLNode:oAddChild(::oXMLUnidade())
		oXMLNode:oAddChild(::oXMLFrequencia())
		oXMLNode:oAddChild(::oXMLTipoMonts())
		oXMLNode:oAddChild(::oOwner():oContext(self,nParentID))
		oTable := self
		if(nID==0)
			oTable := ::oOwner():oGetTable("OBJETIVO")
			oTable:lSeek(1, {nParentID})
		endif	
	
		// Acrescenta children
		oXMLNode:oAddChild(::oOwner():oGetTable("META"):oToXMLList(nID))
		oXMLNode:oAddChild(::oOwner():oGetTable("AVALIACAO"):oToXMLList(nID))
		oXMLNode:oAddChild(::oOwner():oGetTable("DATASRC"):oToXMLList(nID))
		oXMLNode:oAddChild(::oOwner():oGetTable("PLANILHA"):oToXMLList(nID))  // RPLANILHA ja esta' inclusa
		oXMLNode:oAddChild(::oOwner():oGetTable("INDDOC"):oToXMLList(nID))
		oXMLNode:oAddChild(::oOwner():oGetTable("INDTEND"):oToXMLList(nId))
		if(nID==0)
			oXMLNode:oAddChild(::oOwner():oGetTable("INDICADOR"):oToXMLList(nParentId))
		else
			oXMLNode:oAddChild(::oOwner():oGetTable("INDICADOR"):oToXMLList(oTable:cValue("PARENTID")))
		endif
		//Lista de consultas
		oXMLNode:oAddChild(oDWConsulta:oToXmlList(nID))
		oXMLNode:oAddChild(TBIXMLNode():New("BSC_USER",alltrim(oUser:cValue("NOME"))))
	endif

return oXMLNode
	
// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC015
	local aFields, nInd, nStatus := BSC_ST_OK, aIndTend  
	local nId, nContextID,nQtdReg
	local oDWConsulta	:=	::oOwner():oGetTable("DWCONSULTA")	
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "CONTEXTID")		
			nContextID := aFields[nInd][2]
		endif
	next
	nID	:=	::nMakeID()
	aAdd( aFields, {"ID",nID} )
	
	// Grava
	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := BSC_ST_UNIQUE
		else
			nStatus := BSC_ST_INUSE
		endif
	else
		// Extrai e grava lista de pessoas convocadas
		oTable := ::oOwner():oGetTable("INDTEND")
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_INDTENDS"), "_INDTEND"))!="U")
			if(valtype(&("oXMLInput:"+cPath+":_INDTENDS:_INDTEND"))=="A")
				for nInd := 1 to len(&("oXMLInput:"+cPath+":_INDTENDS:_INDTEND"))
					aINDTEND := &("oXMLInput:"+cPath+":_INDTENDS:_INDTEND["+cBIStr(nInd)+"]")
					oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
						{"CONTEXTID", ::nValue("CONTEXTID")},;
						{"INDICADOR", nBIVal(aINDTEND:_ID:TEXT)} })
				next	
			elseif(valtype(&("oXMLInput:"+cPath+":_INDTENDS:_INDTEND"))=="O")
				aINDTEND := &("oXMLInput:"+cPath+":_INDTENDS:_INDTEND")
				oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
					{"CONTEXTID", ::nValue("CONTEXTID")},;
					{"INDICADOR", nBIVal(aINDTEND:_ID:TEXT)} })
			endif
		endif	
	endif	
	
	// Grava planilha
	::oOwner():oGetTable("PLANILHA"):nInsIndicador(self)
	::oOwner():oGetTable("RPLANILHA"):nInsIndicador(self)
	::oOwner():oGetTable("META"):nInsIndicador(self)

	//Gravacao da planilha de consultas
	if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_DWCONSULTAS"), "_DWCONSULTA"))!="U")
		
		aRegNode := &("oXMLInput:"+cPath+":_"+"DWCONSULTAS")//Pegando os valores da planilhas

		if(valtype(aRegNode:_DWCONSULTA)=="A")
			for nQtdReg := 1 to len(aRegNode:_DWCONSULTA)
				nStatus	:= oDWConsulta:nInsFromXML(aRegNode:_DWCONSULTA[nQtdReg],nID,nContextID)
				if(nStatus != BSC_ST_OK)
					::fcMsg := oDWConsulta:fcMsg
					exit
				endif			
			next nQtdReg
		elseif(valtype(aRegNode:_DWCONSULTA)=="O")
			nStatus	:= oDWConsulta:nInsFromXML(aRegNode:_DWCONSULTA,nID,nContextID)
			::fcMsg := oDWConsulta:fcMsg			
		endif
		
	endif

return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC015
	Local nFrequencia, nID, nInd, nQtdReg, nAzul1, nVerde, nAmarelo, nVermelho, nContextID, nFCumula, nTCumula 
	Local nStatus := BSC_ST_OK	
	Local lAscendente	
	Local aIndTend	
	Local oMeta, oDWConsulta := ::oOwner():oGetTable("DWCONSULTA")	
	
	Private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	

		if(aFields[nInd][1] == "CONTEXTID")
			nContextID := aFields[nInd][2]
		endif	
	next

	// Verifica condições de gravação (append ou update)
	if(!::lSeek(1, {nID}))
		nStatus := BSC_ST_BADID
	else       
		lAscendente := ::lValue("ASCEND")
		nFrequencia := ::nValue("FREQ")
		nRFrequencia := ::nValue("RFREQ")
		lCumulativo := ::lValue("CUMULATIVO")
		nFCumula := ::nValue("FCUMULA") 
		nTCumula := ::nValue("TCUMULA") 
		
		if(!::lUpdate(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		else	
			// Se a Orientação for alterada, deve alterar valores da meta
			if(lAscendente != ::lValue("ASCEND"))
				oMeta := ::oOwner():oGetTable("META")
				oMeta:cSQLFilter("PARENTID = " + cBIStr(::nValue("ID")))
				oMeta:lFiltered(.t.)
				oMeta:_First()
				while(!oMeta:lEof())
					nAzul1	  := oMeta:nValue("VERMELHO")
					nVerde	  := oMeta:nValue("AMARELO")
					nAmarelo  := oMeta:nValue("VERDE")
					nVermelho := oMeta:nValue("AZUL1")

					oMeta:lUpdate({{"AZUL1",nAzul1},{"VERDE",nVerde},{"AMARELO",nAmarelo},{"VERMELHO",nVermelho}})

					oMeta:_Next()
				end
				oMeta:cSQLFilter("") // Encerra filtro	
			endif

			// Se a Frequencia for alterada, deve recriar os valores
			if(nFrequencia != ::nValue("FREQ"))
				::oOwner():oGetTable("PLANILHA"):nDelIndicador(self)
				::oOwner():oGetTable("PLANILHA"):nInsIndicador(self)
				::oOwner():oGetTable("PLANILHA"):nRecalcula(::nValue("ID"))
                
				::oOwner():oGetTable("META"):nDelIndicador(self)
				::oOwner():oGetTable("META"):nInsIndicador(self)
				::oOwner():oGetTable("META"):nRecalcAcum(self)
				
			endif	
			
			if(nRFrequencia != ::nValue("RFREQ"))
				::oOwner():oGetTable("RPLANILHA"):nDelIndicador(self)
				::oOwner():oGetTable("RPLANILHA"):nInsIndicador(self)
				::oOwner():oGetTable("RPLANILHA"):nRecalcula(::nValue("ID"))
			endif	

			/*Se status de Cumulativo ou Frequencia Cumulativa forem alterados, devo recalcular a Planilha.*/
			if(nTCumula != ::nValue("TCUMULA") .or. nFCumula != ::nValue("FCUMULA"))			
				::oOwner():oGetTable("PLANILHA"):nRecalcula(::nValue("ID"))
				::oOwner():oGetTable("RPLANILHA"):nRecalcula(::nValue("ID"))
				::oOwner():oGetTable("META"):nRecalcAcum(self)
			endif	
			
			if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_DWCONSULTAS"), "_REG_EXCLUIDO"))!="U")

				aRegNode := &("oXMLInput:"+cPath+":_DWCONSULTAS:_REG_EXCLUIDO")//Pegando os valores da planilhas

				if(valtype(aRegNode:_EXCLUIDOS:_DWCONSULTA)=="A")		
					aRegNode := aRegNode:_EXCLUIDOS:_DWCONSULTA
					for nQtdReg := 1 to len(aRegNode)
						nStatus	:= oDWConsulta:nDelFromXML(aRegNode[nQtdReg])
						if(nStatus != BSC_ST_OK)
							::fcMsg := oDWConsulta:fcMsg
							exit
						endif			
					next nQtdReg
				else
					nStatus	:= oDWConsulta:nDelFromXML(aRegNode:_EXCLUIDOS:_DWCONSULTA)				
				endif
			endif				

			//Atualizando os valores da planilha
			if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_DWCONSULTAS"), "_DWCONSULTA"))!="U")

				aRegNode := &("oXMLInput:"+cPath+":_DWCONSULTAS")//Pegando os valores da planilhas
				if(valtype(aRegNode:_DWCONSULTA)=="A")
					for nQtdReg := 1 to len(aRegNode:_DWCONSULTA)
						nStatus	:= oDWConsulta:nUpdFromXML(aRegNode:_DWCONSULTA[nQtdReg],nID,nContextID)
						if(nStatus != BSC_ST_OK)
							::fcMsg := oDWConsulta:fcMsg
							exit
						endif			
					next nQtdReg
				elseif(valtype(aRegNode:_DWCONSULTA)=="O")
					nStatus	:= oDWConsulta:nUpdFromXML(aRegNode:_DWCONSULTA,nID,nContextID)
					::fcMsg := oDWConsulta:fcMsg					
				endif			
			endif
		endif	
		// Apaga os indicadores de resultado ligados ao indicador de Tendencia
		oTable := ::oOwner():oGetTable("INDTEND")
		oTable:cSQLFilter("PARENTID = "+cBIStr(::nValue("ID"))) // Filtra pelo pai
		oTable:lFiltered(.t.)
		oTable:_First()
		while(!oTable:lEof())
			oTable:lDelete()
			oTable:_Next()
		enddo
		oTable:cSQLFilter("") // Limpar o filtro	

		// Extrai e grava lista de pessoas convocadas
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_INDTENDS"), "_INDTEND"))!="U")
			if(valtype(&("oXMLInput:"+cPath+":_INDTENDS:_INDTEND"))=="A")
				for nInd := 1 to len(&("oXMLInput:"+cPath+":_INDTENDS:_INDTEND"))
					aINDTEND := &("oXMLInput:"+cPath+":_INDTENDS:_INDTEND["+cBIStr(nInd)+"]")
					oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
						{"CONTEXTID", ::nValue("CONTEXTID")},;
						{"INDICADOR", nBIVal(aINDTEND:_ID:TEXT)} })
				next	
			elseif(valtype(&("oXMLInput:"+cPath+":_INDTENDS:_INDTEND"))=="O")
				aINDTEND := &("oXMLInput:"+cPath+":_INDTENDS:_INDTEND")
				oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
					{"CONTEXTID", ::nValue("CONTEXTID")},;
					{"INDICADOR", nBIVal(aINDTEND:_ID:TEXT)} })
			endif
		endif	
	endif
return nStatus

// Excluir entidade do server
method nDelFromXML(nID) class TBSC015
	local nStatus := BSC_ST_OK, oTableChild
	local oDWConsulta	:=	::oOwner():oGetTable("DWCONSULTA")	
	
	::oOwner():oOltpController():lBeginTransaction()

	// Procura por children (Documentos)
	oTableChild:= ::oOwner():oGetTable("INDDOC")
	oTableChild:SetOrder(3) // Por ordem de ParentId
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo paI
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("INDDOC"):nDelFromXML(oTableChild:nValue("ID"))
		oTableChild:_Next()
	enddo
	oTableChild:cSQLFilter("") // Limpa o filtro

	// Procura por children (Metas)
	oTableChild:= ::oOwner():oGetTable("META")
	oTableChild:SetOrder(3) // Por ordem de ParentId
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo paI
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("META"):nDelFromXML(oTableChild:nValue("ID"))
		oTableChild:_Next()
	enddo
	oTableChild:cSQLFilter("") // Limpa o filtro

	// Procura por children (Fonte de Dados)
	oTableChild:= ::oOwner():oGetTable("DATASRC")
	oTableChild:SetOrder(3) // Por ordem de ParentId
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo paI
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("DATASRC"):nDelFromXML(oTableChild:nValue("ID"))
		oTableChild:_Next()
	enddo
	oTableChild:cSQLFilter("") // Limpa o filtro

	// Procura por children (Avaliação)
	oTableChild:= ::oOwner():oGetTable("AVALIACAO")
	oTableChild:SetOrder(3) // Por ordem de ParentId
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo paI
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("AVALIACAO"):nDelFromXML(oTableChild:nValue("ID"))
		oTableChild:_Next()
	enddo
	oTableChild:cSQLFilter("") // Limpa o filtro

	// Procura por children (Planilha)
	oTableChild:= ::oOwner():oGetTable("PLANILHA")
	if(nStatus == BSC_ST_OK)
		nStatus := oTableChild:nDelIndicador(self)
	endif

	// Procura por children (RPlanilha)
	oTableChild:= ::oOwner():oGetTable("RPLANILHA")
	if(nStatus == BSC_ST_OK)
		nStatus := oTableChild:nDelIndicador(self)
	endif

	// Apaga os indicadores de resultado ligados ao indicador de Tendencia
	oTableChild := ::oOwner():oGetTable("INDTEND")
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(::nValue("ID"))) // Filtra pelo pai
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("INDTEND"):nDelFromXML(oTableChild:nValue("ID"))
		oTableChild:_Next()
	enddo
	oTableChild:cSQLFilter("") // Encerra filtro	
	
	oDWConsulta:SetOrder(2) // Por ordem de id
	oDWConsulta:cSQLFilter("PARENTID = '" + cBiStr(::nValue("ID")) +"'") // Filtra pelo paI
	oDWConsulta:lFiltered(.t.)
	oDWConsulta:_First()

	while(!oDWConsulta:lEof())
		if(!oDWConsulta:lDelete())
			nStatus := BSC_ST_INUSE
		endif
		oDWConsulta:_Next()
	enddo
	
	//Excluir as consultas
	oDWConsulta:cSQLFilter("")

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
method nDuplicate(nParentID, nNewParentID, nNewContextID, aIndIds) class TBSC015
	local nStatus := BSC_ST_OK, aFields, nID, nOldId
	
	::oOwner():oOltpController():lBeginTransaction()

	::SetOrder(1) // Por ordem de id
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof() .and. nStatus == BSC_ST_OK)
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
		else
			// Children
			::restPos()
			nOldId := ::nValue("ID")
			aAdd(aIndIds, {nOldId, nId})
			nStatus := ::oOwner():oGetTable("INDDOC"):nDuplicate(nOldID, nID, nNewContextID)
			if(nStatus == BSC_ST_OK)
				nStatus := ::oOwner():oGetTable("META"):nDuplicate(nOldID, nID, nNewContextID)
			endif
			if(nStatus == BSC_ST_OK)
				nStatus := ::oOwner():oGetTable("AVALIACAO"):nDuplicate(nOldID, nID, nNewContextID)
			endif
			if(nStatus == BSC_ST_OK)
				nStatus := ::oOwner():oGetTable("DATASRC"):nDuplicate(nOldID, nID, nNewContextID)
			endif
			if(nStatus == BSC_ST_OK)
				nStatus := ::oOwner():oGetTable("PLANILHA"):nDuplicate(nOldID, nID, nNewContextID)
			endif
			if(nStatus == BSC_ST_OK)
				nStatus := ::oOwner():oGetTable("RPLANILHA"):nDuplicate(nOldID, nID, nNewContextID)
			endif
			if(nStatus == BSC_ST_OK)
				nStatus := ::oOwner():oGetTable("DWCONSULTA"):nDuplicate(nOldID, nID, nNewContextID)
			endif			
		endif
		::restPos()
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
// @param lParcelada - Indica se a análise é acumulada - (default).f. / (parcelada).t.
method oMakeCard(dDataAlvo, lParcelada) class TBSC015
	local oPlanilha, oMeta, lAzul, nDecimais, lExisteMeta := .t.
	local nValorAtual, nValorAnterior, nTotal, nPercMeta := 0
	local nVermelho, nAmarelo, nVerde, nAzul, nIndicador, nValorAlvo
	local nRealVermelho, nRealAmarelo, nRealVerde, nRealAzul, nBaseVermelho
	local lAscend, cUnidade, nInicial, nFinal, nAtual, nAnterior, cPercMeta
	local lVerCores := .f., lVerNumeros := .f.
	local oScoreCard := TBSCScoreCard():New(), oTendencia
	local lWebex := .f., lCached := .f.

	// Data na qual o BSC se baseia para analisar os dados e gerar snapshot
	if(empty(dDataAlvo))
		lWebex := .t.
		dDataAlvo := ::oOwner():xSessionValue("DATAALVO")
	endif
	if(empty(dDataAlvo))
		dDataAlvo := date()
	endif	     

	// Analise de metas Parcelada ou Acumuladas
	if(valtype(lParcelada)=="U")
		lWebex := .t.
		lParcelada := ::oOwner():xSessionValue("PARCELADA")
	endif
	if(valtype(lParcelada)=="U")
		lParcelada := .f.
	endif	     

	// A principio se estamos em webex, se podemos verificar o cache
	if(lWebex)
		dDataProc := xBIConvTo("D", ::oOwner():xSessionValue("DATAPROC"))
		lParcProc := xBIConvTo("L", ::oOwner():xSessionValue("PARCPROC"))
		if(dDataProc == dDataAlvo .and. lParcProc == lParcelada)
			// Procura em cache
			aProcInds := ::oOwner():xSessionValue("PROCINDS")
			if(valtype(aProcInds)!="A")
				aProcInds := {}
			endif
			nPos := aScan(aProcInds, {|x| x:fnEntID == ::nValue("ID")})
			lCached := (nPos != 0)
			if(lCached)
				oScoreCard := aProcInds[nPos]
			endif
		else
			// A data não bate, opa, regerar o cache então
			::oOwner():xSessionValue("PROCINDS", {})
			::oOwner():xSessionValue("DATAPROC", dDataAlvo)
			::oOwner():xSessionValue("PARCPROC", lParcelada)
			lCached := .f.
		endif
	endif

	if(!lCached)

		// Verifica Segurança
		lVerNumeros := ::oOwner():foSecurity:lHasParentAccess("INDICADOR", ::nValue("ID"), "NUMEROS")
		lVerCores	:= ::oOwner():foSecurity:lHasParentAccess("INDICADOR", ::nValue("ID"), "CORES")
		
		// Abre tabela para MakeCard
		oMeta := ::oOwner():oGetTable("META")
		oPlanilha := ::oOwner():oGetTable("PLANILHA")
		oTendencia := ::oOwner():oGetTable("INDTEND")
		
		oMeta:SavePos()
		oPlanilha:SavePos()
		oTendencia:SavePos()
	
		// Indicador (this)
		oScoreCard:fcNome := ::cValue("NOME")
		oScoreCard:fcDescricao := ::cValue("DESCRICAO")
		oScoreCard:fcEntity := TAG_ENTITY
		oScoreCard:fnEntID := ::nValue("ID")
		oScoreCard:fcTipoInd := ::cValue("TIPOIND")
	
		// Verificar se o Indicador recebe influencia de outros de Tendencia
		oScoreCard:fcInfluencia := .f.
		if(oScoreCard:fcTipoInd!="T")
			oScoreCard:fcInfluencia := oTendencia:lSeek(4, {oScoreCard:fnEntID})
		endif
	
		cUnidade := ::cValue("UNIDADE")
		lAscend := ::lValue("ASCEND")
		nDecimais := ::nValue("DECIMAIS")
		
		// Meta
		oMeta:lSoftSeek(4, {cBIStr(lParcelada), ::nValue("ID"), dDataAlvo})
		if(oMeta:lEof() .or. oMeta:lValue("PARCELADA") != lParcelada .or. oMeta:nValue("PARENTID") != ::nValue("ID"))
			lExisteMeta := .f.
			nRealVermelho := nVermelho := 0
			nRealAmarelo := nAmarelo := 0
			nRealVerde := nVerde := nValorAlvo := 0
			nRealAzul := nAzul := 0
		else
			nRealVermelho := nVermelho := oMeta:nValue("VERMELHO")
			nRealAmarelo := nAmarelo := oMeta:nValue("AMARELO")
			nRealVerde := nVerde := nValorAlvo := oMeta:nValue("VERDE")
			nRealAzul := nAzul := oMeta:nValue("AZUL1")
		endif
	
		// Planilha
		oPlanilha:lDateSeek(::nValue("ID"), dDataAlvo, ::nValue("FREQ"))
		if(oPlanilha:nValue("PARENTID")==::nValue("ID"))
			// Encontrou na planilha
			nValorAtual := oPlanilha:nValue(iif(lParcelada,"PARCELA","MONTANTE"))
			oPlanilha:_Prior()
			if(oPlanilha:nValue("PARENTID")==::nValue("ID"))
				nValorAnterior := oPlanilha:nValue(iif(lParcelada,"PARCELA","MONTANTE"))
			else
				nValorAnterior := 0
			endif
		else	
			// Não encontrou valor na planilha
			nValorAtual := 0
			nValorAnterior := 0
		endif	
			
		// Percentual sobre a meta
		nBaseVermelho := if(nValorAtual < nVermelho, nValorAtual, nVermelho)
		if(lAscend)
			nPercMeta := abs(round( (nValorAtual-nBaseVermelho) / (nValorAlvo-nBaseVermelho) * 100, 0 ))
			cPercMeta := cBIStr(nPercMeta)+"%"
		else
			nPercMeta := abs(round( (nVermelho-nValorAtual) / (nVermelho-nValorAlvo) * 100, 0 ))
			cPercMeta := cBIStr(nPercMeta)+"%"
		endif

		// Calculo percentual
		if(lAscend)
			lAzul := (nValorAtual >= nAzul)
			if(lAzul)
				nInicial := nVermelho
				nFinal := nValorAtual
				nAtual := nValorAtual
				nAnterior := nValorAnterior
				nValorAlvo := nValorAlvo

				nTotal := nValorAtual - nVermelho

				nVermelho := nAmarelo - nVermelho
				nVermelho := int(nVermelho*100/nTotal)
				nAmarelo := nVerde - nAmarelo
				nAmarelo := int(nAmarelo*100/nTotal)
				nVerde := nAzul - nVerde
				nVerde := int(nVerde*100/nTotal)
				nAzul := nValorAtual - nAzul
				nAzul := int(nAzul*100/nTotal)
				nAzul += 100 - (nVermelho+nAmarelo+nVerde+nAzul)
				if(nAzul==0)  // Retira incoerencia do alvo sobre o azul
					nAzul := 1
					nVerde := nVerde-1
				endif
				nIndicador := 100
			else
				nInicial := nVermelho
				nFinal := nAzul
				nAtual := nValorAtual
				nAnterior := nValorAnterior
				nValorAlvo := nValorAlvo
				
				nTotal := nAzul - nVermelho
				nIndicador := round( (nValorAtual-nVermelho)*100/nTotal, 0)
				
				nVermelho := nAmarelo - nVermelho
				nVermelho := int(nVermelho*100/nTotal)
				nAmarelo := nVerde - nAmarelo
				nAmarelo := int(nAmarelo*100/nTotal)
				nVerde := nAzul - nVerde
				nVerde := int(nVerde*100/nTotal)
				nAzul := 0  // Não será apresentado
				nVerde += 100 - (nVermelho+nAmarelo+nVerde)
			endif
		else // not lAscend
			lAzul := (nValorAtual <= nAzul)
			if(lAzul)
				nInicial := nVermelho
				nFinal := nValorAtual
				nAtual := nValorAtual
				nAnterior := nValorAnterior
				nValorAlvo := nValorAlvo
				
				nTotal := nVermelho - nValorAtual
				
				nVermelho := abs(nAmarelo - nVermelho)
				nVermelho := int(nVermelho*100/nTotal)
				nAmarelo := abs(nVerde - nAmarelo)
				nAmarelo := int(nAmarelo*100/nTotal)
				nVerde := abs(nAzul - nVerde)
				nVerde := int(nVerde*100/nTotal)
				nAzul := abs(nValorAtual - nAzul)
				nAzul := int(nAzul*100/nTotal)
				nAzul += 100 - (nVermelho+nAmarelo+nVerde+nAzul)
				if(nAzul==0)  // Retira incoerencia do alvo sobre o azul
					nAzul := 1
					nVerde := nVerde-1
				endif
				nIndicador := 100
			else
				nInicial := nVermelho
				nFinal := nAzul
				nAtual := nValorAtual
				nAnterior := nValorAnterior
				nValorAlvo := nValorAlvo
		
				nTotal := nVermelho - nAzul
				nIndicador := round( (nVermelho-nValorAtual)*100/nTotal, 0)
						
				nVermelho := abs(nAmarelo - nVermelho)
				nVermelho := int(nVermelho*100/nTotal)
				nAmarelo := abs(nVerde - nAmarelo)
				nAmarelo := int(nAmarelo*100/nTotal)
				nVerde := abs(nAzul - nVerde)
				nVerde := int(nVerde*100/nTotal)
				nAzul := 0  // Não será apresentado
				nVerde += 100 - (nVermelho+nAmarelo+nVerde)
			endif
		endif
		
		// Feedback
		nFeedback := BSC_FB_GRAY
		if(lExisteMeta)	
			if(nIndicador < nVermelho)
				if(nValorAtual == nValorAnterior)
					nFeedback := BSC_FB_REDSM
				elseif(nValorAtual < nValorAnterior)
					nFeedback := iif(lAscend, BSC_FB_REDDN, BSC_FB_REDUP)
				else
					nFeedback := iif(lAscend, BSC_FB_REDUP, BSC_FB_REDDN)
				endif
			elseif(nIndicador < nVermelho+nAmarelo)
				if(nValorAtual == nValorAnterior)
					nFeedback := BSC_FB_YELLOWSM
				elseif(nValorAtual < nValorAnterior)
					nFeedback := iif(lAscend, BSC_FB_YELLOWDN, BSC_FB_YELLOWUP)
				else
					nFeedback := iif(lAscend, BSC_FB_YELLOWUP, BSC_FB_YELLOWDN)
				endif
			elseif(nIndicador < nVermelho+nAmarelo+nVerde)
				if(nValorAtual == nValorAnterior)
					nFeedback := BSC_FB_GREENSM
				elseif(nValorAtual < nValorAnterior)
					nFeedback := iif(lAscend, BSC_FB_GREENDN, BSC_FB_GREENUP)
				else
					nFeedback := iif(lAscend, BSC_FB_GREENUP, BSC_FB_GREENDN)
				endif
			else
				if(nValorAtual == nValorAnterior)
					nFeedback := BSC_FB_BLUESM
				elseif(nValorAtual < nValorAnterior)
					nFeedback := iif(lAscend, BSC_FB_BLUEDN, BSC_FB_BLUEUP)
				else
					nFeedback := iif(lAscend, BSC_FB_BLUEUP, BSC_FB_BLUEDN)
				endif
			endif
		endif
			
		// Retorno de Cores
		oScoreCard:fnVermelho 		:= if(lVerCores,nVermelho,0)
		oScoreCard:fnAmarelo 		:= if(lVerCores,nAmarelo,0)
		oScoreCard:fnVerde 			:= if(lVerCores,nVerde,0)
		oScoreCard:fnAzul 			:= if(lVerCores,nAzul,0)
		oScoreCard:fnIndicador 		:= if(lVerCores,nIndicador,0)
		oScoreCard:fnPercMeta 		:= if(lVerCores,nPercMeta,0)
	    	
		// Retorno de Numeros
		oScoreCard:fcUnidade 		:= cUnidade
		oScoreCard:fnInicial 		:= if(lVerNumeros,nInicial,0)
		oScoreCard:fnFinal 			:= if(lVerNumeros,nFinal,0)
		oScoreCard:fnAtual 			:= if(lVerNumeros,nAtual,0)
				
		oScoreCard:fnAnterior 		:= if(lVerNumeros,nAnterior,0)
		oScoreCard:fnAlvo			:= if(lVerNumeros,nValorAlvo,0)
		oScoreCard:fcPercMeta 		:= if(lVerNumeros,cPercMeta,"0")
		oScoreCard:fnRealVermelho 	:= if(lVerNumeros,nRealVermelho,0)
		oScoreCard:fnRealAmarelo 	:= if(lVerNumeros,nRealAmarelo,0)
		oScoreCard:fnRealVerde 		:= if(lVerNumeros,nRealVerde,0)
		oScoreCard:fnRealAzul 		:= if(lVerNumeros,nRealAzul,0)
	
		oScoreCard:fdDataAlvo 		:= dDataAlvo
		oScoreCard:fnFeedBack 		:= if(lVerNumeros .or. lVerCores, nFeedback, BSC_FB_GRAY)
	
		oScoreCard:fnDecimais		:= nDecimais
		
		oScoreCard:fnPeso			:= ::nValue("PESO")
		oScoreCard:flAscendente		:= lAscend
	
		oMeta:RestPos()
		oPlanilha:RestPos()
		oTendencia:RestPos()

		// Se gerou o cartão (lCached = .f.) deve então gravá-lo para não gerar novamente na próxima 
		//aProcInds := ::oOwner():xSessionValue("PROCINDS")
		aProcInds := {}
		aAdd(aProcInds, oScoreCard)
		
	endif

return oScoreCard

// oMakeCard()
// Retorna um CARD pronto no formato XML.
method oXMLCard() class TBSC015
	local oXMLCard := ::oMakeCard():oToXMLCard()

	// Não ha mais necessidade de enviar indicadores ao card de indicador
	// 28/07/2004 - Leandro
	// Anexar Indicadores relacionadas
	// oXMLCard:oAddChild(::oToEntityList("OBJETIVO", {::nValue("PARENTID")}))
return oXMLCard

//Retorna o texto da frequencia
method getFreqText(nIdFrequencia) class TBSC015
	local cNomeFreq := ""

	do case
		case nIdFrequencia == BSC_FREQ_ANUAL
			cNomeFreq := STR0004
		case nIdFrequencia == BSC_FREQ_SEMESTRAL 
			cNomeFreq := STR0005
		case nIdFrequencia == BSC_FREQ_QUADRIMESTRAL
			cNomeFreq := STR0006
		case nIdFrequencia == BSC_FREQ_TRIMESTRAL 
			cNomeFreq := STR0007
		case nIdFrequencia == BSC_FREQ_BIMESTRAL 
			cNomeFreq := STR0008
		case nIdFrequencia == BSC_FREQ_MENSAL
			cNomeFreq := STR0009
		case nIdFrequencia == BSC_FREQ_QUINZENAL
			cNomeFreq := STR0010
		case nIdFrequencia == BSC_FREQ_SEMANAL 
			cNomeFreq := STR0011
		case nIdFrequencia == BSC_FREQ_DIARIA
			cNomeFreq := STR0012
	endcase

return cNomeFreq

method aCompletado(cNomeUsuario, dDataDe, dDataAte) class TBSC015
	local aAtingido := {}, aPessoaID := {}, aUsuarios := {}
	local oPessoa, oUsuarios, oPlanilha
	local ni:=1, nMedia := 0, nIndicadores := 0
	local cAno, cMes, cDia

	oPlanilha := ::oOwner():oGetTable("PLANILHA")
	oUsuarios := ::oOwner():oGetTable("USUARIO")
	//oUsuarios:cSQLFilter("USERPROT = 'T' AND NOME = '"+cNomeUsuario+"'")
	oUsuarios:cSQLFilter("NOME = '"+cNomeUsuario+"'")
	oUsuarios:lFiltered(.t.)
	oUsuarios:lSoftSeek(2,{cNomeUsuario})
	if(alltrim(oUsuarios:cValue("NOME"))==alltrim(cNomeUsuario))
		aadd(aUsuarios,oUsuarios:nValue("ID"))
	endif
	oUsuarios:cSQLFilter("") // Zera filtro

	oPessoa := ::oOwner():oGetTable("PESSOA")
	for ni:=1 to len(aUsuarios)
		oPessoa:cSQLFilter("USERID = "+cBiStr(aUsuarios[ni]))
		oPessoa:lFiltered(.t.)
		oPessoa:_First()
		while(!oPessoa:lEof())
			aadd(aPessoaID,oPessoa:nValue("ID"))
			oPessoa:_next()
		enddo
	next
	oPessoa:cSQLFilter("") // Zera filtro

	::lFiltered(.t.)
	for ni:=1 to len(aPessoaID)
		::cSQLFilter("RESPID = "+cBiStr(aPessoaID[ni])) // Filtra pelo responsavel
		::_First()
		while(::nValue("RESPID") == aPessoaID[ni] .and. !eof())

			cAno := "0"
			cMes := "0"
			cDia := "0"
			while(dDataDe <= dDataAte)
				aDate := oPlanilha:aDateConv(dDataDe, ::nValue("FREQ"))
				if(cDia!=aDate[3] .or. cMes!=aDate[2] .or. cAno!=aDate[1])
					cAno := aDate[1]
					cMes := aDate[2]
					cDia := aDate[3]
					nMedia += ::oMakeCard(dDataDe):fnPercMeta
					nIndicadores ++
				endif
				dDataDe++
			enddo
			::_next()
		enddo
	next

	::cSQLFilter("") // Zera filtro
	nMedia := if(nIndicadores>0,nMedia / nIndicadores,0)
	aadd(aAtingido,nMedia)

return aAtingido


method nExecute(cCmd) class TBSC015   
	local nStatus

	if(::lSeek(1, {xBIConvTo("N",cCmd)}))
		::oOwner():oGetTable("META"):nRecalcAcum(self)
		nStatus := BSC_ST_OK
	else
		nStatus := BSC_ST_BADID	
	endif
return nStatus      

function _bsc015_ind()
return