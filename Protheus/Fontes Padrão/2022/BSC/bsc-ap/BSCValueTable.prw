// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSCValueTable.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC015A_Val.ch"
/*--------------------------------------------------------------------------------------
@class BSCValueTable
Classe abstrata modelo para implementação de planilha de valores do bsc.
Será usada em todo o BSC para gerar planilhas.
--------------------------------------------------------------------------------------*/
class TBSCValueTable from TBITable
	method New(cTableName) constructor
	method NewBSCValueTable(cTableName)

	// atributos
	data fcTagEntity
	data fcTagGroup
	data fcTextEntity
	data fcTextGroup

	// diversos registros
	method oArvore()
	method oToXMLList()

	// registro atual
	method oToXMLNode(nParentID) // como e tabela, precisa do parent para filtrar
	method oToXMLByPeriod(nParentID, cLoadCMD)	
	method nUpdFromXML(oXML, cPath)
	method nDuplicate(nParentID, nNewParentID, nNewContextID)
	method XMLMeta(oXMLNode,oPeriodTable,dDataAlvo,aMetaDe,aMetaAte,nFreqAgrup,nFrequencia,nParentID) //Valor das metas para o indicador.
	method lChkProxMeta(nFrequencia,dDataMeta,dProxData)

	//Controle de Planilhas
	method nInsIndicador(oIndicador) // tabela Indicador posicionada no Indicador correta
	method nDelIndicador(oIndicador) // tabela Indicador posicionada no Indicador correta
	method nMudaPeriodo(nParentID, dDataIni, dDataFin)
	method nRecalcula(nParentID)
	method aDateConv(dDataIni, nFrequencia)
	method lDateSeek(nParentID, dDataIni, nFrequencia)
	method nDataComp(aFirst, aSecond)
	method dPerToDate(nAno,nMes,nDia,nAgrupFreq)	
	method getPerText(aDate,nIdFrequencia) //Retorna o texto da frequencia

endclass
	
method New(cTableName) class TBSCValueTable
	::NewBSCValueTable(cTableName)
return
method NewBSCValueTable(cTableName) class TBSCValueTable
	// Table
	::NewTable(cTableName)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("ANO", 		"C",	4))
	::addField(TBIField():New("MES", 		"C",	2))
	::addField(TBIField():New("DIA", 		"C",	2))
	::addField(TBIField():New("PARCELA",	"N", 	19, 	6))
	::addField(TBIField():New("MONTANTE",	"N", 	19, 	6))

	// Indexes
	::addIndex(TBIIndex():New(cTableName+"I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New(cTableName+"I02",	{"PARENTID", "ANO", "MES", "DIA"},	.t.))
	::addIndex(TBIIndex():New(cTableName+"I03",	{"PARENTID", "ID"},	.t.))
return

// Arvore
method oArvore(nParentID) class TBSCValueTable
	local oXMLArvore
	local cTipo := "PLANILHA", crTipo := "RPLANILHA"
	if("FCS"$::cEntity())
		cTipo := "FCSPLAN"
		crTipo := "FCSRPLAN"
	endif
	
	// Tag conjunto
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 1)
	oAttrib:lSet("TIPO", cTipo) //"PLANILHA" ou "FCSPLAN"
	oAttrib:lSet("NOME", STR0003)/*//"Planilhas"*/
	oXMLArvore := TBIXMLNode():New(cTipo+"S","",oAttrib) //"PLANILHAS" ou "FCSPLANS"

	// Nodes
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", nParentID)
	oAttrib:lSet("NOME", STR0013)/*//"Planilha de Resultado"*/
	oXMLArvore:oAddChild(TBIXMLNode():New(cTipo, "", oAttrib))  //"PLANILHA" ou "FCSPLAN"

	// Nodes
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", nParentID)
	oAttrib:lSet("NOME", STR0014)/*//"Planilha de Referência"*/
	oXMLArvore:oAddChild(TBIXMLNode():New(crTipo, "", oAttrib))  //"RPLANILHA" ou "FCSRPLAN"

return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSCValueTable
	local oNode, oAttrib, oXMLNode
	local cTipo := "PLANILHA", crTipo := "RPLANILHA"
	if("FCS"$::cEntity())
		cTipo := "FCSPLAN"
		crTipo := "FCSRPLAN"
	endif
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", cTipo+"S") //"PLANILHA" ou "FCSPLAN"
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", STR0004)/*//"Planilha"*/
	oAttrib:lSet("CLA000", BSC_STRING)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(cTipo+"S",,oAttrib) //"PLANILHA" ou "FCSPLAN"
	
	// Gera recheio
	oNode := oXMLNode:oAddChild(TBIXMLNode():New(cTipo)) //"PLANILHA" ou "FCSPLAN"
	oNode:oAddChild(TBIXMLNode():New("ID", nParentID))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0013))/*//"Planilha de Resultado"*/

	oNode := oXMLNode:oAddChild(TBIXMLNode():New(crTipo))
	oNode:oAddChild(TBIXMLNode():New("ID", nParentID))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0014))/*//"Planilha de Referência"*/

return oXMLNode

// Carregar o nó com base no ParentId.
method oToXMLNode(nParentID, cLoadCMD) class TBSCValueTable
	local aFields, nInd, oTable
	local oXMLNode, oNode, oAttrib, nTipoMnt
	local lCumulativo, nFrequencia, nDecimais, nNextIndex
	local cTipo := ""
	if("FCS"$::cEntity())
		cTipo := "FCSIND"
	else
		cTipo := "INDICADOR"
	endif
	
	// === Desvio de código ===
	if(valtype(cLoadCMD)!="U")
		return ::oToXMLByPeriod(nParentID, cLoadCMD)
	endif

	// Encontro a frequencia da Indicador
	oTable := ::oOwner():oGetTable(cTipo) //INDICADOR ou FCSIND
	oTable:lSeek(1, {nParentID})
	nFrequencia := oTable:nValue("FREQ")
	nDecimais := oTable:nValue("DECIMAIS")
	lCumulativo	 := oTable:lValue("CUMULATIVO")
	nTipoMnt := oTable:nValue("TCUMULA")
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", ::fcTagEntity)
	oAttrib:lSet("RETORNA", .t.)
	// Ano
	oAttrib:lSet("TAG000", "ANO")
	oAttrib:lSet("CAB000", "Ano")
	oAttrib:lSet("CLA000", BSC_STRING)
	
	nNextIndex := 1 // Inicia o contador do index.
	if(nFrequencia != BSC_FREQ_ANUAL .and. nFrequencia != BSC_FREQ_SEMANAL)
		// Mes
		oAttrib:lSet("TAG001", "MES")
		oAttrib:lSet("CAB001", 	iif(nFrequencia == BSC_FREQ_SEMESTRAL		, STR0005,; 	//Semestre
								iif(nFrequencia == BSC_FREQ_QUADRIMESTRAL	, STR0015,; 	//Quadrimestre
								iif(nFrequencia == BSC_FREQ_TRIMESTRAL		, STR0006,; 	//Trimestre
								iif(nFrequencia == BSC_FREQ_BIMESTRAL		, STR0007,; 	//Bimestre
																			  STR0008))))) 	//Mês
		oAttrib:lSet("CLA001", BSC_STRING)
		nNextIndex++
		if(	nFrequencia == BSC_FREQ_QUINZENAL 	.or.;
			nFrequencia == BSC_FREQ_DIARIA )

			// Dia
			oAttrib:lSet("TAG002", "DIA")
			oAttrib:lSet("CAB002", 	iif(nFrequencia == BSC_FREQ_QUINZENAL	, STR0009,;   	//Quinzena
																			  STR0011))	//Dia
			oAttrib:lSet("CLA002", BSC_STRING)
			nNextIndex++
		endif
	elseif (nFrequencia != BSC_FREQ_ANUAL)
		// Semana
		oAttrib:lSet("TAG001", "MES")
		oAttrib:lSet("CAB001", 	STR0010)	//Semana
		oAttrib:lSet("CLA001", BSC_STRING)
		nNextIndex++
	endif
	// Valor
	oAttrib:lSet("TAG"+strzero(nNextIndex,3), "PARCELA")
	oAttrib:lSet("CAB"+strzero(nNextIndex,3), STR0001)/*//"Valor"*/
	oAttrib:lSet("CLA"+strzero(nNextIndex,3), BSC_FLOAT)
	oAttrib:lSet("EDT"+strzero(nNextIndex,3), .t.)
	oAttrib:lSet("CUM"+strzero(nNextIndex,3), lCumulativo)
	nNextIndex++
	// Montante
	oAttrib:lSet("TAG"+strzero(nNextIndex,3), "MONTANTE")
	oAttrib:lSet("CAB"+strzero(nNextIndex,3), STR0012)/*//"Montante"*/
	oAttrib:lSet("CLA"+strzero(nNextIndex,3), BSC_FLOAT)
	oAttrib:lSet("EDT"+strzero(nNextIndex,3), (nTipoMnt==BSC_MT_EDT))
	oAttrib:lSet("CUM"+strzero(nNextIndex,3), .f.)
	
	// Gera no principal
	oXMLNode := TBIXMLNode():New(::fcTagGroup,,oAttrib)
	
	// Gera recheio
	::SetOrder(2) // Por ordem de data
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	lVerNumeros := ::oOwner():foSecurity:lHasParentAccess(cTipo, nParentID, "NUMEROS") //cTipo= INDICADOR ou FCSIND

	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(::fcTagEntity))
		aFields := ::xRecord(RF_ARRAY)
		for nInd := 1 to len(aFields)
			if((aFields[nInd][1]=="MONTANTE" .or. aFields[nInd][1]=="PARCELA") .and. !lVerNumeros)
				aFields[nInd][2] := 0
			endif
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end

	// Gero no final completo
	oNode := TBIXMLNode():New(::cEntity())
	oNode:oAddChild(TBIXMLNode():New("ID", 1))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0004))/*//"Planilha"*/
	oNode:oAddChild(TBIXMLNode():New("DECIMAIS", nDecimais))
	oNode:oAddChild(oXMLNode)

	::_First()
	oNode:oAddChild(::oOwner():oContext(self))

	::cSQLFilter("") // Encerra filtro
return oNode

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSCValueTable
	local aFields, nInd, nInd1, nParentID, nStatus := BSC_ST_OK
	private aValores, oXMLInput := oXML

	if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_VALORES"), "_VALOR"))!="U")
	
		aValores := &("oXMLInput:"+cPath+":_VALORES:_VALOR")
		if(valtype(aValores)!="A")
			aValores := { aValores }
		endif

		for nInd1 := 1 to len(aValores)

			// Extrai planilha
			oTable := ::oOwner():oGetTable(::cEntity())
			aFields := { {"ID", NIL}, {"PARCELA", NIL}, {"MONTANTE", NIL}, {"PARENTID", NIL} }
			for nInd := 1 to len(aFields)
				cType := oTable:aFields(aFields[nInd][1]):cType()
				aFields[nInd][2] := xBIConvTo(cType, &("aValores["+cBIStr(nInd1)+"]:_"+aFields[nInd][1]+":TEXT"))
				if(aFields[nInd][1] == "ID")
					nID := aFields[nInd][2]
				elseif(aFields[nInd][1] == "PARENTID")
					nParentID := aFields[nInd][2]
				endif
			next     

			// Grava Planilha
			if(!oTable:lSeek(1, {nID}))
				nStatus := BSC_ST_BADID
			else
				if(!oTable:lUpdate(aFields))
					if(oTable:nLastError()==DBERROR_UNIQUE)
						nStatus := BSC_ST_UNIQUE
					else
						nStatus := BSC_ST_INUSE
					endif
				endif 	
			endif
		
		next
	endif
	
	//Recalcula planilha atualizada
	::nRecalcula(nParentID)
	
return nStatus

// Insere nova entidade
method nInsIndicador(oIndicador) class TBSCValueTable
	local nStatus := BSC_ST_OK
	local nParentID, nContextID, nFrequencia
	local oEstrategia, dDataIni, dDataFin
	local cAno, cMes, cDia
	
	// Carrego vars
	nParentID := oIndicador:nValue("ID")
	nContextID := oIndicador:nValue("CONTEXTID")
	nFrequencia := oIndicador:nValue("FREQ")
	
	// Encontro o plano estratégico
	oEstrategia := ::oOwner():oAncestor("ESTRATEGIA", oIndicador)
	dDataIni := oEstrategia:dValue("DATAINI")
	dDataFin := oEstrategia:dValue("DATAFIN")
	
	cAno := "0"
	cMes := "0"
	cDia := "0"
	while(dDataIni <= dDataFin)
		aDate := ::aDateConv(dDataIni, nFrequencia)
		if(cDia!=aDate[3] .or. cMes!=aDate[2] .or. cAno!=aDate[1])
			cAno := aDate[1]
			cMes := aDate[2]
			cDia := aDate[3]
			::lAppend({ {"ID", ::nMakeID()}, {"PARENTID", nParentID}, {"CONTEXTID", nContextID},;
						{"ANO", cAno}, {"MES", cMes}, {"DIA", cDia} })
		endif
		dDataIni++
	enddo

return nStatus

// Excluir entidade do server
method nDelIndicador(oIndicador) class TBSCValueTable
	local nStatus := BSC_ST_OK
	local nParentID := oIndicador:nValue("ID")
	
	::oOwner():oOltpController():lBeginTransaction()

	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(nStatus == BSC_ST_OK .and. !::lEof())
		if(!::lDelete())
			nStatus := BSC_ST_INUSE
		endif
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro

	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()
return nStatus

// Duplica os registros filhos de nParentID, colocando-os como filhos de nNewParentID do contexto nNewContextID
method nDuplicate(nParentID, nNewParentID, nNewContextID) class TBSCValueTable
	local nStatus := BSC_ST_OK, aFields, nID
	
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

// Carregar especial
method oToXMLByPeriod(nParentID, cLoadCMD) class TBSCValueTable
	local aFields, nInd, aLoadCMD, nAgrupFreq
	local oXMLNode, oNode, oAttrib
	local oTable, nFrequencia, nDecimais, nNextIndex, lCumulativo, nTipoMnt//, nLineCount
	local nAno, nMes, nDia, nParcela, nMontante
	local aLast, aActual, aDefine, aDe, aAte, aMetaDe, aMetaAte, lVerNumeros
	local cTipo := ""
	If( "FCS" $ ::cEntity() )
		cTipo := "FCSIND"
	Else
		cTipo := "INDICADOR"
	EndIf
	
	// Parsear argumentos
	aLoadCMD 	:= aBIToken(cLoadCMD, ";", .f.)
	aDe 		:= aBIToken(aLoadCMD[1], "-", .t.)
	aAte 		:= aBIToken(aLoadCMD[2], "-", .t.)
	nAgrupFreq 	:= nBIVal(aLoadCMD[3])
	lShowMeta  	:= cBIStr(aLoadCMD[4]) == ".T."
	
	// Encontro a frequencia da Indicador
	oTable 		:= ::oOwner():oGetTable(cTipo) //INDICADOR ou FCSIND
	oTable:lSeek(1, {nParentID})
	nFrequencia := oTable:nValue("FREQ")
	nDecimais 	:= oTable:nValue("DECIMAIS")
	lCumulativo	:= oTable:lValue("CUMULATIVO")
	nTipoMnt 	:= oTable:nValue("TCUMULA")
	
	// Frequencia 0
	if(nAgrupFreq == 0)
		nAgrupFreq := nFrequencia
	endif
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", ::fcTagEntity)
	oAttrib:lSet("RETORNA", .t.)
	// Ano
	oAttrib:lSet("TAG000", "ANO")
	oAttrib:lSet("CAB000", "Ano")
	oAttrib:lSet("CLA000", BSC_STRING)
	nNextIndex := 1
	if(nAgrupFreq != BSC_FREQ_ANUAL .and. nAgrupFreq != BSC_FREQ_SEMANAL)
		// Mes
		oAttrib:lSet("TAG001", "MES")
		oAttrib:lSet("CAB001",	iif(nAgrupFreq == BSC_FREQ_SEMESTRAL		, STR0005,;		//Semestre
		iif(nAgrupFreq == BSC_FREQ_QUADRIMESTRAL	, STR0015,;		//Quadrimestre
		iif(nAgrupFreq == BSC_FREQ_TRIMESTRAL		, STR0006,;		//Trimestre
		iif(nAgrupFreq == BSC_FREQ_BIMESTRAL		, STR0007,;		//Bimestre
		STR0008)))))	//Mês
		oAttrib:lSet("CLA001", BSC_STRING)
		nNextIndex++
		if(nAgrupFreq == BSC_FREQ_QUINZENAL)
			// Dia
			oAttrib:lSet("TAG002", "DIA")
			oAttrib:lSet("CAB002", 	iif(nAgrupFreq == BSC_FREQ_QUINZENAL	, STR0009,;		//Quinzena
			STR0011))		//Dia
			oAttrib:lSet("CLA002", BSC_STRING)
			nNextIndex++
		endif
	elseif (nAgrupFreq != BSC_FREQ_ANUAL)
		// Semana
		oAttrib:lSet("TAG001", "MES")
		oAttrib:lSet("CAB001", 	STR0010)	//Semana
		oAttrib:lSet("CLA001", BSC_STRING)
		nNextIndex++
	endif
	// Valor
	oAttrib:lSet("TAG"+strzero(nNextIndex,3), "PARCELA")
	oAttrib:lSet("CAB"+strzero(nNextIndex,3), STR0001)/*//"Valor"*/
	oAttrib:lSet("CLA"+strzero(nNextIndex,3), BSC_FLOAT)
	oAttrib:lSet("EDT"+strzero(nNextIndex,3), .t.)
	oAttrib:lSet("CUM"+strzero(nNextIndex,3), lCumulativo)
	nNextIndex++
	// Montante
	oAttrib:lSet("TAG"+strzero(nNextIndex,3), "MONTANTE")
	oAttrib:lSet("CAB"+strzero(nNextIndex,3), STR0012)/*//"Montante"*/
	oAttrib:lSet("CLA"+strzero(nNextIndex,3), BSC_FLOAT)
	oAttrib:lSet("EDT"+strzero(nNextIndex,3), (nTipoMnt==BSC_MT_EDT))
	oAttrib:lSet("CUM"+strzero(nNextIndex,3), .f.)
	
	// Gera no principal
	oXMLNode := TBIXMLNode():New(::fcTagGroup,,oAttrib)
	
	// Gera recheio
	oPeriodTable := TBIPeriodTable():New(nFrequencia, nAgrupFreq)
	
	aMetaDe    	:= aDe
	aMetaAte	:= aAte
	
	aLast 		:= {}
	aAtual 		:= {}
	nMontante 	:= 0 // Inicio Montante em 0
	lVerNumeros := ::oOwner():foSecurity:lHasParentAccess(cTipo, nParentID, "NUMEROS") //cTipo=INDICADOR ou FCSIND
	
	::SetOrder(2) // Por ordem de data
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	if(!::lEof())
		// Trata 1o. registro aLast
		aFields := ::xRecord(RF_ARRAY)
		while(!::lEof())
			nAno := ::nValue("ANO")
			nMes := ::nValue("MES")
			nDia := ::nValue("DIA")
			nParcela := if(lVerNumeros, ::nValue("PARCELA"), 0)
			
			if(nTipoMnt != BSC_MT_EDT)
				nMontante += nParcela
			endif
			
			aLast := {nAno, nMes, nDia, nParcela, nMontante}
			::_Next()
			if(::nDataComp(aLast, aDe) >= 0 .And. ::nDataComp(aLast, aAte) <= 0)
				exit
			endif
		enddo
		// Converte aLast no formato agrupado
		aLast := oPeriodTable:aConvert(nAno, nMes, nDia)
		aAdd(aLast, nParcela)
		aAdd(aLast, nMontante)
		aDefine := aClone(aLast)
		
		// Conta linhas para projetar a média do montante
		//		nLineCount := 1
		
		while(!::lEof())
			
			// Trabalha e consiste aActual
			nAno := ::nValue("ANO")
			nMes := ::nValue("MES")
			nDia := ::nValue("DIA")
			nParcela := if(lVerNumeros, ::nValue("PARCELA"), 0)
			
			if(nTipoMnt != BSC_MT_EDT)
				nMontante += nParcela
			endif

			aActual := {nAno, nMes, nDia, nParcela, nMontante}
			
			if(::nDataComp(aActual, aDe) < 0 .or. ::nDataComp(aActual, aAte) > 0)
				::_Next()
				loop
			endif
			
			// Converte aActual no formato agrupado
			aActual := oPeriodTable:aConvert(nAno, nMes, nDia)
			aAdd(aActual, nParcela)
			aAdd(aActual, nMontante)
			
			if( ::nDataComp(aActual, aLast) == 0 )
				// Soma valores a define
				aDefine[4] += aActual[4]
				
				if(lCumulativo)
					if(nTipoMnt != BSC_MT_EDT)
						aDefine[5] += aActual[5]
					endif
				else
					aDefine[5] += aActual[4]
				endif
			else
				// Acrecenta define no destino
				oNode := oXMLNode:oAddChild(TBIXMLNode():New(::fcTagEntity))
				for nInd := 1 to len(aFields)
					if(aFields[nInd][1] == "ANO")
						aFields[nInd][2] := aDefine[1]
					elseif(aFields[nInd][1] == "MES")
						aFields[nInd][2] := aDefine[2]
					elseif(aFields[nInd][1] == "DIA")
						aFields[nInd][2] := aDefine[3]
					elseif(aFields[nInd][1] == "PARCELA")
						aFields[nInd][2] := aDefine[4]
					elseif(aFields[nInd][1] == "MONTANTE")
						if(lCumulativo)
							aFields[nInd][2] = aDefine[5]
						else
							aFields[nInd][2] = aDefine[4]
						endif
					endif
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
				next
				// Adiciona as metas para esta Linha da Planilha
				if (lShowMeta)
					dDataAlvo := ::dPerToDate(aLast[1],aLast[2],aLast[3],nAgrupFreq)
					::XMLMeta(oXMLNode,oPeriodTable,dDataAlvo,aMetaDe,aMetaAte,nAgrupFreq,nFrequencia,nParentID)
				endif
				aDefine := aClone(aActual)
			endif
			aLast := aActual
			::_Next()
			// Conta linhas para projetar a média do montante
			//			nLineCount += 1
		enddo
		
		// Acrecenta last no destino
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(::fcTagEntity))
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1] == "ANO")
				aFields[nInd][2] := aDefine[1]
			elseif(aFields[nInd][1] == "MES")
				aFields[nInd][2] := aDefine[2]
			elseif(aFields[nInd][1] == "DIA")
				aFields[nInd][2] := aDefine[3]
			elseif(aFields[nInd][1] == "PARCELA")
				aFields[nInd][2] := aDefine[4]
			elseif(aFields[nInd][1] == "MONTANTE")  
				if(lCumulativo)
					aFields[nInd][2] = aDefine[5]
				else
					aFields[nInd][2] = aDefine[4]
				endif
			endif
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		// Adiciona as metas para esta Linha da Planilha
		if (lShowMeta .and. lVerNumeros)
			if nFrequencia == BSC_FREQ_DIARIA .And. nAgrupFreq == BSC_FREQ_QUINZENAL
				dDataAlvo := cTod( str(aActual[3]) + "/" + str(aActual[2]) + "/" + str(aActual[1]))
			Else
				dDataAlvo := ::dPerToDate(aLast[1],aLast[2],aLast[3],nAgrupFreq)
			EndIf
			::XMLMeta(oXMLNode,oPeriodTable,dDataAlvo,aMetaDe,aMetaAte,nAgrupFreq,nFrequencia,nParentID)
		endif
	endif
	::cSQLFilter("") // Encerra filtro
	
	// Gero no final completo
	oNode := TBIXMLNode():New(::cEntity())
	oNode:oAddChild(TBIXMLNode():New("ID", 1))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0004))/*//"Planilha"*/
	oNode:oAddChild(TBIXMLNode():New("DECIMAIS", nDecimais))
	oNode:oAddChild(oXMLNode)
return oNode
            

// Devolve um array com { cAno, cMes, cDia } convertida
method aDateConv(dDataIni, nFrequencia) class TBSCValueTable
	local nTempMes, nTempDia
	local cAno := "0000", cMes := "00", cDia := "00"
	
	// Atenção - Manter cAno, cMes e cDia com zeros na frente para evitar erros de indice

	if(nFrequencia == BSC_FREQ_ANUAL)
		cAno := strzero(year(dDataIni), 4)
		cMes := "00"
		cDia := "00"
	elseif(nFrequencia == BSC_FREQ_SEMESTRAL)
		nTempMes := iif(month(dDataIni)>6, 2, 1)
		cAno := strzero(year(dDataIni),4)
		cMes := strzero(nTempMes,2)
		cDia := "00"
	elseif(nFrequencia == BSC_FREQ_QUADRIMESTRAL)
		nTempMes := iif(month(dDataIni)<=4, 1, iif(month(dDataIni)<=8, 2, 3))
		cAno := strzero(year(dDataIni),4)
		cMes := strzero(nTempMes,2)
		cDia := "00"
	elseif(nFrequencia == BSC_FREQ_TRIMESTRAL)
		nTempMes := iif(month(dDataIni)<=3, 1, iif(month(dDataIni)<=6, 2, iif(month(dDataIni)<=9, 3, 4)))
		cAno := strzero(year(dDataIni),4)
		cMes := strzero(nTempMes,2)
		cDia := "00"
	elseif(nFrequencia == BSC_FREQ_BIMESTRAL)
		nTempMes := iif(month(dDataIni)<=2, 1, iif(month(dDataIni)<=4, 2, iif(month(dDataIni)<=6, 3, ;
					iif(month(dDataIni)<=8, 4, iif(month(dDataIni)<=10, 5, 6)))))
		cAno := strzero(year(dDataIni),4)
		cMes := strzero(nTempMes,2)
		cDia := "00"
	elseif(nFrequencia == BSC_FREQ_MENSAL)
		nTempMes := month(dDataIni)
		cAno := strzero(year(dDataIni),4)
		cMes := strzero(nTempMes,2)
		cDia := "00"
	elseif(nFrequencia == BSC_FREQ_QUINZENAL)
		nTempDia := iif(day(dDataIni)>15, 2, 1)
		cAno := strzero(year(dDataIni),4)
		cMes := strzero(month(dDataIni),2)
		cDia := strzero(nTempDia,2)
	elseif(nFrequencia == BSC_FREQ_SEMANAL)
		cAno := strzero(year(dDataIni),4)
		cMes := strzero(nBIWeekOfYear(dDataIni),2)
		cDia := "00"
	elseif(nFrequencia == BSC_FREQ_DIARIA)
		cAno := strzero(year(dDataIni),4)
		cMes := strzero(month(dDataIni),2)
		cDia := strzero(day(dDataIni),2)
	endif
return {cAno, cMes, cDia}         


//Retorna o texto da frequencia
method getPerText(aDate,nIdFrequencia) class TBSCValueTable
	local cRet := ""           

	do case
		case nIdFrequencia == BSC_FREQ_ANUAL
			cRet := aDate[1]
		case nIdFrequencia == BSC_FREQ_SEMESTRAL 
			if val(aDate[2]) ==  1
				cRet := "1º Sem/" + aDate[1]
			else                             
				cRet := "2º Sem/" + aDate[1]
			endif
		case nIdFrequencia == BSC_FREQ_QUADRIMESTRAL
			if val(aDate[2]) ==  1		
				cRet := "1º Quad/" + aDate[1]
			elseif val(aDate[2]) ==  2
				cRet := "2º Quad/" + aDate[1]
			else                              
				cRet := "3º Quad/" + aDate[1]
			endif
		case nIdFrequencia == BSC_FREQ_TRIMESTRAL 
			if val(aDate[2]) ==  1		
				cRet := "1º Tri/" + aDate[1]
			elseif val(aDate[2]) ==  2
				cRet := "2º Tri/" + aDate[1]
			elseif val(aDate[2]) ==  3
				cRet := "3º Tri/" + aDate[1]
			else                              
				cRet := "4º Tri/" + aDate[1]
			endif
		case nIdFrequencia == BSC_FREQ_BIMESTRAL 
			if val(aDate[2]) ==  1		
				cRet := "1º Bim/" + aDate[1]
			elseif val(aDate[2]) ==  2
				cRet := "2º Bim/" + aDate[1]
			elseif val(aDate[2]) ==  3
				cRet := "3º Bim/" + aDate[1]
			elseif val(aDate[2]) ==  4
				cRet := "4º Bim/" + aDate[1]
			elseif val(aDate[2]) ==  5
				cRet := "5º Bim/" + aDate[1]
			else                              
				cRet := "6º Bim/" + aDate[1]
			endif
		case nIdFrequencia == BSC_FREQ_MENSAL
			if val(aDate[2]) ==  1		
				cRet := "Jan/" + aDate[1]
			elseif val(aDate[2]) ==  2
				cRet := "Fev/" + aDate[1]
			elseif val(aDate[2]) ==  3
				cRet := "Mar/" + aDate[1]
			elseif val(aDate[2]) ==  4
				cRet := "Abr/" + aDate[1]
			elseif val(aDate[2]) ==  5
				cRet := "Mai/" + aDate[1]
			elseif val(aDate[2]) ==  6
				cRet := "Jun/" + aDate[1]
			elseif val(aDate[2]) ==  7
				cRet := "Jul/" + aDate[1]
			elseif val(aDate[2]) ==  8
				cRet := "Ago/" + aDate[1]
			elseif val(aDate[2]) ==  9
				cRet := "Set/" + aDate[1]
			elseif val(aDate[2]) ==  10
				cRet := "Out/" + aDate[1]
			elseif val(aDate[2]) ==  11
				cRet := "Nov/" + aDate[1]
			else                              
				cRet := "Dez/" + aDate[1]
			endif
		case nIdFrequencia == BSC_FREQ_QUINZENAL
			if val(aDate[2]) ==  1		
				cRet := "Jan/" + aDate[1]
			elseif val(aDate[2]) ==  2
				cRet := "Fev/" + aDate[1]
			elseif val(aDate[2]) ==  3
				cRet := "Mar/" + aDate[1]
			elseif val(aDate[2]) ==  4
				cRet := "Abr/" + aDate[1]
			elseif val(aDate[2]) ==  5
				cRet := "Mai/" + aDate[1]
			elseif val(aDate[2]) ==  6
				cRet := "Jun/" + aDate[1]
			elseif val(aDate[2]) ==  7
				cRet := "Jul/" + aDate[1]
			elseif val(aDate[2]) ==  8
				cRet := "Ago/" + aDate[1]
			elseif val(aDate[2]) ==  9
				cRet := "Set/" + aDate[1]
			elseif val(aDate[2]) ==  10
				cRet := "Out/" + aDate[1]
			elseif val(aDate[2]) ==  11
				cRet := "Nov/" + aDate[1]
			else                              
				cRet := "Dez/" + aDate[1]
			endif     

			if val(aDate[3]) == 1
				cRet := "1º Quinz/"	+ cRet
			else
				cRet := "2º Quinz/"	+ cRet
			endif			
			
		case nIdFrequencia == BSC_FREQ_SEMANAL 
			cRet := aDate[3] + "/" + aDate[2] + "/" + aDate[1]
		case nIdFrequencia == BSC_FREQ_DIARIA
			cRet := aDate[3] + "/" + aDate[2] + "/" + aDate[1]
	endcase

return cRet




// lDateSeek - busca pela data já convertida
method lDateSeek(nParentID, dDataIni, nFrequencia) class TBSCValueTable
	local aKey := ::aDateConv(dDataIni, nFrequencia)
	aSize(aKey, 4)
	aIns(aKey, 1)
	aKey[1] := nParentID
return ::lSeek(2, aKey)

// method nDataComp:  (aFirst < aSecond) = -1, (aFirst > aSecond) = 1, (aFirst == aSecond) = 0
// Comparações entre datas da mesma frequência
method nDataComp(aFirst, aSecond) class TBSCValueTable
	local nRet := 0
	if(aFirst[1] < aSecond[1]) // Ano <
		nRet := -1
	elseif(aFirst[1] > aSecond[1]) // Ano >
		nRet := 1	
	else // Ano ==
		if(aFirst[2] < aSecond[2]) // Mes <
			nRet := -1
		elseif(aFirst[2] > aSecond[2]) // Mes >
			nRet := 1	
		else // Mes ==
			if(aFirst[3] < aSecond[3]) // Dia <
				nRet := -1
			elseif(aFirst[3] > aSecond[3]) // Dia >
				nRet := 1	
			else // Dia ==
				nRet := 0
			endif
		endif
	endif
return nRet

// Recalcula valor montante da planilha
method nRecalcula(nParentID) class TBSCValueTable
	local oIndicador, nStatus := BSC_ST_OK
	local aDataOld, dDataAux, aDataAux, nMontante, nMontRec
	local nLineCount
	local cTipo := ""
	if("FCS"$::cEntity())
		cTipo := "FCSIND"
	else
		cTipo := "INDICADOR"
	endif
	                             
	//Posiciona no indicador da planilha
	oIndicador := ::oOwner():oGetTable(cTipo) //INDICADOR ou FCSIND
	oIndicador:lSeek(1,{nParentID})
	
	// Iniciar aDataOld
	aDataOld := {"0000", "00", "00"}

	// Primeira passada, primeiro registro a proc.
	nLineCount := 0
	nMontante := 0

	::SetOrder(2)
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
        
		//Verifica se Indicador é Cumulativo
		if(oIndicador:lValue("CUMULATIVO"))
		
			// Indicador cumulativo
			dDataAux := ::dPerToDate(::nValue("ANO"), ::nValue("MES"), ::nValue("DIA"), oIndicador:nValue("FREQ"))
			aDataAux := ::aDateConv(dDataAux, oIndicador:nValue("FCUMULA"))
			if(::nDataComp(aDataOld, aDataAux) != 0 .and. oIndicador:nValue("FCUMULA") != 0)
				aDataOld := aDataAux
				nMontante := ::nValue("PARCELA")

				// Para de contar as linhas por algum tempo
				nLineCount := 1

			else
			
				// Tipo de acumulação
				do case
					case oIndicador:nValue("TCUMULA") == BSC_MT_SUM
						nMontante += ::nValue("PARCELA")
					case oIndicador:nValue("TCUMULA") == BSC_MT_AVG
						nMontante += ::nValue("PARCELA")
					case oIndicador:nValue("TCUMULA") == BSC_MT_EDT
						nMontante := ::nValue("MONTANTE")
					otherwise
						// BSC_ST_SUM é default
						nMontante += ::nValue("PARCELA")
				endcase
				// Conta quantas linhas até o momento
				nLineCount++

			endif
			
		else

			nMontante := ::nValue("PARCELA")

		endif

		nMontRec := nMontante
		if (oIndicador:nValue("TCUMULA") == BSC_MT_AVG)
			nMontRec := round(nMontante/nLineCount, oIndicador:nValue("DECIMAIS"))
		endif
		
		if(!::lUpdate({{"MONTANTE", nMontRec}}))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif
		
		::_Next()
	enddo
	::cSQLFilter("")

return nStatus

// --------------------------------------------------------------------------------------------
// Classe para trabalhar com periodos
class TBIPeriodTable from TBIObject
	data faTable
	data fnFreqOrigem
	data fnFreqDestino

	method New(nFreqOrigem, nFreqDestino) constructor
	method NewBIPeriodTable(nFreqOrigem, nFreqDestino)
	method aConvert(nAno, nMes, nDia)
endclass

method New(nFreqOrigem, nFreqDestino) class TBIPeriodTable
	::NewBIPeriodTable(nFreqOrigem, nFreqDestino)
return

method NewBIPeriodTable(nFreqOrigem, nFreqDestino) class TBIPeriodTable
	
	if nFreqOrigem == BSC_FREQ_QUADRIMESTRAL .or. nFreqDestino == BSC_FREQ_QUADRIMESTRAL
		if nFreqOrigen == BSC_FREQ_QUADRIMESTRAL		//Se a freq. origem for quadrimestral		
			if nFreqDestino < 2 // Quando for quadrimestral so converte para anual
				::fnFreqDestino := nFreqDestino
			else
				::fnFreqDestino := nFreqOrigem
			endif
		else//Se a freq. destino for quadrimestral
			if nFreqOrigem > 2//origem tem que ser maior que 2
				::fnFreqDestino := nFreqDestino
			else
				::fnFreqDestino	:= nFreqOrigem
			endif		
		endif
		::fnFreqOrigem := nFreqOrigem
	else
		::fnFreqOrigem := nFreqOrigem
		::fnFreqDestino := iif(nFreqDestino <= nFreqOrigem, nFreqDestino, nFreqOrigem)
	endif

	if(nFreqOrigem == BSC_FREQ_SEMANAL)
		if(nFreqDestino != BSC_FREQ_ANUAL)
			::fnFreqDestino := BSC_FREQ_SEMANAL
		else
			::fnFreqDestino := iif(nFreqDestino <= nFreqOrigem, nFreqDestino, nFreqOrigem)
		endif			
	endif

/*  // Referencia para montagem de tabela
	// 				Ano, 	Sem, 	Quad, 	Trim, 	Bim, 	Mes 	
	::faTable := {;
				{	0, 		1, 		1, 		1, 		1, 		1 	},;
				{	0, 		1, 		1, 		1, 		1, 		2 	},;
				{	0, 		1, 		1, 		1, 		2, 		3 	},;
				{	0, 		1, 		1, 		2, 		2, 		4 	},;
				{	0, 		1, 		2, 		2, 		3, 		5 	},;
				{	0, 		1, 		2, 		2, 		3, 		6 	},;
				{	0, 		2, 		2, 		3, 		4, 		7 	},;
				{	0, 		2, 		2, 		3, 		4, 		8 	},;
				{	0, 		2, 		3, 		3, 		5, 		9 	},;
				{	0, 		2, 		3, 		4, 		5, 		10	},;
				{	0, 		2, 		3, 		4, 		6, 		11	},;
				{	0, 		2, 		3, 		4, 		6, 		12	}}
*/	
	::faTable := array(12, 9)
	
	// Ano
	::faTable[01][BSC_FREQ_ANUAL] := 0
	::faTable[02][BSC_FREQ_ANUAL] := 0
	::faTable[03][BSC_FREQ_ANUAL] := 0
	::faTable[04][BSC_FREQ_ANUAL] := 0
	::faTable[05][BSC_FREQ_ANUAL] := 0
	::faTable[06][BSC_FREQ_ANUAL] := 0
	::faTable[07][BSC_FREQ_ANUAL] := 0
	::faTable[08][BSC_FREQ_ANUAL] := 0
	::faTable[09][BSC_FREQ_ANUAL] := 0
	::faTable[10][BSC_FREQ_ANUAL] := 0
	::faTable[11][BSC_FREQ_ANUAL] := 0
	::faTable[12][BSC_FREQ_ANUAL] := 0
	
	// Semestre
	::faTable[01][BSC_FREQ_SEMESTRAL] := 1
	::faTable[02][BSC_FREQ_SEMESTRAL] := 1
	::faTable[03][BSC_FREQ_SEMESTRAL] := 1
	::faTable[04][BSC_FREQ_SEMESTRAL] := 1
	::faTable[05][BSC_FREQ_SEMESTRAL] := 1
	::faTable[06][BSC_FREQ_SEMESTRAL] := 1
	::faTable[07][BSC_FREQ_SEMESTRAL] := 2
	::faTable[08][BSC_FREQ_SEMESTRAL] := 2
	::faTable[09][BSC_FREQ_SEMESTRAL] := 2
	::faTable[10][BSC_FREQ_SEMESTRAL] := 2
	::faTable[11][BSC_FREQ_SEMESTRAL] := 2
	::faTable[12][BSC_FREQ_SEMESTRAL] := 2

	// Quadrimestral
	::faTable[01][BSC_FREQ_QUADRIMESTRAL] := 1
	::faTable[02][BSC_FREQ_QUADRIMESTRAL] := 1
	::faTable[03][BSC_FREQ_QUADRIMESTRAL] := 1
	::faTable[04][BSC_FREQ_QUADRIMESTRAL] := 1
	::faTable[05][BSC_FREQ_QUADRIMESTRAL] := 2
	::faTable[06][BSC_FREQ_QUADRIMESTRAL] := 2
	::faTable[07][BSC_FREQ_QUADRIMESTRAL] := 2
	::faTable[08][BSC_FREQ_QUADRIMESTRAL] := 2
	::faTable[09][BSC_FREQ_QUADRIMESTRAL] := 3
	::faTable[10][BSC_FREQ_QUADRIMESTRAL] := 3
	::faTable[11][BSC_FREQ_QUADRIMESTRAL] := 3
	::faTable[12][BSC_FREQ_QUADRIMESTRAL] := 3

	// Trimestral
	::faTable[01][BSC_FREQ_TRIMESTRAL] := 1
	::faTable[02][BSC_FREQ_TRIMESTRAL] := 1
	::faTable[03][BSC_FREQ_TRIMESTRAL] := 1
	::faTable[04][BSC_FREQ_TRIMESTRAL] := 2
	::faTable[05][BSC_FREQ_TRIMESTRAL] := 2
	::faTable[06][BSC_FREQ_TRIMESTRAL] := 2
	::faTable[07][BSC_FREQ_TRIMESTRAL] := 3
	::faTable[08][BSC_FREQ_TRIMESTRAL] := 3
	::faTable[09][BSC_FREQ_TRIMESTRAL] := 3
	::faTable[10][BSC_FREQ_TRIMESTRAL] := 4
	::faTable[11][BSC_FREQ_TRIMESTRAL] := 4
	::faTable[12][BSC_FREQ_TRIMESTRAL] := 4

	//Bimestral
	::faTable[01][BSC_FREQ_BIMESTRAL] := 1
	::faTable[02][BSC_FREQ_BIMESTRAL] := 1
	::faTable[03][BSC_FREQ_BIMESTRAL] := 2
	::faTable[04][BSC_FREQ_BIMESTRAL] := 2
	::faTable[05][BSC_FREQ_BIMESTRAL] := 3
	::faTable[06][BSC_FREQ_BIMESTRAL] := 3
	::faTable[07][BSC_FREQ_BIMESTRAL] := 4
	::faTable[08][BSC_FREQ_BIMESTRAL] := 4
	::faTable[09][BSC_FREQ_BIMESTRAL] := 5
	::faTable[10][BSC_FREQ_BIMESTRAL] := 5
	::faTable[11][BSC_FREQ_BIMESTRAL] := 6
	::faTable[12][BSC_FREQ_BIMESTRAL] := 6

	//Mensal
	::faTable[01][BSC_FREQ_MENSAL] := 1
	::faTable[02][BSC_FREQ_MENSAL] := 2
	::faTable[03][BSC_FREQ_MENSAL] := 3
	::faTable[04][BSC_FREQ_MENSAL] := 4
	::faTable[05][BSC_FREQ_MENSAL] := 5
	::faTable[06][BSC_FREQ_MENSAL] := 6
	::faTable[07][BSC_FREQ_MENSAL] := 7
	::faTable[08][BSC_FREQ_MENSAL] := 8
	::faTable[09][BSC_FREQ_MENSAL] := 9
	::faTable[10][BSC_FREQ_MENSAL] := 10
	::faTable[11][BSC_FREQ_MENSAL] := 11
	::faTable[12][BSC_FREQ_MENSAL] := 12

	//Quinzenal
	::faTable[01][BSC_FREQ_QUINZENAL] := 1
	::faTable[02][BSC_FREQ_QUINZENAL] := 2
	::faTable[03][BSC_FREQ_QUINZENAL] := 3
	::faTable[04][BSC_FREQ_QUINZENAL] := 4
	::faTable[05][BSC_FREQ_QUINZENAL] := 5
	::faTable[06][BSC_FREQ_QUINZENAL] := 6
	::faTable[07][BSC_FREQ_QUINZENAL] := 7
	::faTable[08][BSC_FREQ_QUINZENAL] := 8
	::faTable[09][BSC_FREQ_QUINZENAL] := 9
	::faTable[10][BSC_FREQ_QUINZENAL] := 10
	::faTable[11][BSC_FREQ_QUINZENAL] := 11
	::faTable[12][BSC_FREQ_QUINZENAL] := 12

	//Semanal
	::faTable[01][BSC_FREQ_SEMANAL] := 1
	::faTable[02][BSC_FREQ_SEMANAL] := 2
	::faTable[03][BSC_FREQ_SEMANAL] := 3
	::faTable[04][BSC_FREQ_SEMANAL] := 4
	::faTable[05][BSC_FREQ_SEMANAL] := 5
	::faTable[06][BSC_FREQ_SEMANAL] := 6
	::faTable[07][BSC_FREQ_SEMANAL] := 7
	::faTable[08][BSC_FREQ_SEMANAL] := 8
	::faTable[09][BSC_FREQ_SEMANAL] := 9
	::faTable[10][BSC_FREQ_SEMANAL] := 10
	::faTable[11][BSC_FREQ_SEMANAL] := 11
	::faTable[12][BSC_FREQ_SEMANAL] := 12
	
	//Diaria
	::faTable[01][BSC_FREQ_DIARIA] := 1
	::faTable[02][BSC_FREQ_DIARIA] := 2
	::faTable[03][BSC_FREQ_DIARIA] := 3
	::faTable[04][BSC_FREQ_DIARIA] := 4
	::faTable[05][BSC_FREQ_DIARIA] := 5
	::faTable[06][BSC_FREQ_DIARIA] := 6
	::faTable[07][BSC_FREQ_DIARIA] := 7
	::faTable[08][BSC_FREQ_DIARIA] := 8
	::faTable[09][BSC_FREQ_DIARIA] := 9
	::faTable[10][BSC_FREQ_DIARIA] := 10
	::faTable[11][BSC_FREQ_DIARIA] := 11
	::faTable[12][BSC_FREQ_DIARIA] := 12

return

method aConvert(nAno, nMes, nDia,nFreqOrigem, nFreqDestino) class TBIPeriodTable
	local nPos, nRetAno := 0, nRetMes := 0, nRetDia := 0

	default nFreqOrigem  := ::fnFreqOrigem
	default nFreqDestino := ::fnFreqDestino
		
	if(nFreqOrigem == nFreqDestino)
		nRetAno := nAno
		nRetMes := nMes
		nRetDia := nDia
	elseif(nFreqDestino == BSC_FREQ_SEMANAL)
		if(nFreqOrigem  == BSC_FREQ_DIARIA)
			nRetAno := nAno
			nRetMes := nBIWeekOfYear( ctod(cBIStr(nDia)+"/"+cBIStr(nMes)+"/"+cBIStr(nAno)) )
			nRetDia := 0
		endif		
	elseif(nFreqDestino == BSC_FREQ_QUINZENAL)
		if(nFreqOrigem == BSC_FREQ_DIARIA)
			nRetAno := nAno
			nRetMes := nMes
			nRetDia := iif(nDia <= 15, 1, 2)
		endif		
	elseif(nFreqDestino == BSC_FREQ_ANUAL .and. nFreqOrigem == BSC_FREQ_SEMANAL)
			nRetAno := nAno
			nRetMes := 0
			nRetDia := 0
	else
		// ::fnFreqOrigem == BSC_FREQ_SEMESTRAL
		// ::fnFreqOrigem == BSC_FREQ_QUADRIMESTRAL
		// ::fnFreqOrigem == BSC_FREQ_TRIMESTRAL
		// ::fnFreqOrigem == BSC_FREQ_BIMESTRAL
		// ::fnFreqOrigem == BSC_FREQ_MENSAL
		// ::fnFreqOrigem == BSC_FREQ_QUINZENAL
		// ::fnFreqOrigem == BSC_FREQ_SEMANAL
		// ::fnFreqOrigem == BSC_FREQ_DIARIA

		// ::fnFreqDestino == BSC_FREQ_ANUAL
		// ::fnFreqDestino == BSC_FREQ_SEMESTRAL
		// ::fnFreqDestino == BSC_FREQ_QUADRIMESTRAL
		// ::fnFreqDestino == BSC_FREQ_TRIMESTRAL
		// ::fnFreqDestino == BSC_FREQ_BIMESTRAL
		// ::fnFreqDestino == BSC_FREQ_MENSAL

		nRetAno := nAno
		nPos := aScan(::faTable, {|x| x[nFreqOrigem] == nMes})
		nRetMes := ::faTable[nPos][nFreqDestino]
		nRetDia := 0
	endif

return { nRetAno, nRetMes, nRetDia }

//Retorna as metas para o Indicador Selecionado.
method XMLMeta(oXMLNode,oPeriodTable,dDataAlvo,aMetaDe,aMetaAte,nFreqAgrup,nFrequencia,nParentID) class TBSCValueTable
	local oNodeMeta 	:=	Nil
	local oMeta			:=	Nil
	local dProxData		:=	Date()
	local dDataMeta		:=	Date()
	local aActual		:= {}
	local lParcelada, lExisteMeta := .t.

	// Analise de metas Parcelada ou Acumuladas
	If(empty(lParcelada))
		lParcelada := ::oOwner():xSessionValue("PARCELADA")
	EndIf   
	If( empty( lParcelada ) )
		lParcelada := .F.
	EndIf

	//Meta
	oMeta := ::oOwner():oGetTable("META")
	oMeta:lSoftSeek(4, {cBIStr(lParcelada), nParentID, dDataAlvo})
	if(oMeta:lEof() .or. oMeta:lValue("PARCELADA") != lParcelada .or. oMeta:nValue("PARENTID") != nParentID)
		lExisteMeta := .f.
	endif

	if(lExisteMeta)
		dDataMeta := oMeta:dValue("DATAALVO")
		aActual	  := oPeriodTable:aConvert(year(dDataMeta),month(dDataMeta),day(dDataMeta),BSC_FREQ_DIARIA,nFrequencia)
			
		if(::lChkProxMeta(nFreqAgrup, dDataAlvo ,dDataMeta) ;
			.and. ::nDataComp(aActual, aMetaDe) >= 0 .And.	::nDataComp(aActual, aMetaAte) <= 0)
				oNodeMeta := oXMLNode:oAddChild(TBIXMLNode():New("VALOR")) 
				oNodeMeta:oAddChild(TBIXMLNode():New("ANO", year(dDataMeta)))
				oNodeMeta:oAddChild(TBIXMLNode():New("MES", month(dDataMeta)))
				oNodeMeta:oAddChild(TBIXMLNode():New("DIA", day(dDataMeta)))
				oNodeMeta:oAddChild(TBIXMLNode():New("META","T"))
				oNodeMeta:oAddChild(TBIXMLNode():New("PARCELA" , oMeta:nValue("VERDE")))
				oNodeMeta:oAddChild(TBIXMLNode():New("MONTANTE", oMeta:nValue("VERDE")))
				oMeta:_Next()                           
				if(oMeta:nValue("PARENTID") == nParentID)
					dProxData := oMeta:dValue("DATAALVO")
				if(::lChkProxMeta(nFreqAgrup, dProxData ,dDataMeta);
					.and. ::nDataComp(aActual, aMetaDe) >= 0 .and. ::nDataComp(aActual, aMetaAte) <= 0)
						::XMLMeta(oXMLNode,oPeriodTable,dProxData,aMetaDe,aMetaAte,nFreqAgrup,nFrequencia,nParentID)
					endif
				endif
		endif
	endif
return 

//Transforma uma data no formato dos indicadores para uma data padrao. 
method dPerToDate(nAno,nMes,nDia,nAgrupFreq,lLastDay) class TBSCValueTable
	local dData := ctod("")
	
	/*Por DEFAULT sempre é retornada a primeira data do período informado.*/          
	Default lLastDay := .F.
	
	If !(lLastDay)
		Do Case
			case nAgrupFreq == BSC_FREQ_ANUAL	
				dData := cTod("01/01/"+ str(nAno,4) )
				
			case nAgrupFreq == BSC_FREQ_SEMESTRAL
				if(nMes == 1)
					dData := cTod("01/01/"+ str(nAno,4) )
				else
					dData := cTod("01/07/"+ str(nAno,4) )
				endif
				
			case nAgrupFreq == BSC_FREQ_QUADRIMESTRAL	
				if(nMes == 1)
					dData := cTod("01/01/"+ str(nAno,4))										
				elseif(nMes ==2)
					dData := cTod("01/05/"+ str(nAno,4))										
				else
					dData := cTod("01/09/"+ str(nAno,4))											
				endif
				
			case nAgrupFreq == BSC_FREQ_TRIMESTRAL	
				if(nMes == 1)
					dData := cTod("01/01/"+ str(nAno,4))										
				elseif(nMes == 2)
					dData := cTod("01/04/"+ str(nAno,4))										
				elseif(nMes == 3)
					dData := cTod("01/07/"+ str(nAno,4))											
				else
					dData := cTod("01/10/"+ str(nAno,4))														
				endif
				
			case nAgrupFreq == BSC_FREQ_BIMESTRAL
				if(nMes == 1)
					dData := cTod("01/01/"+ str(nAno,4))
				elseif(nMes == 2)
					dData := cTod("01/03/"+ str(nAno,4))
				elseif(nMes == 3)
					dData := cTod("01/05/"+ str(nAno,4))
				elseif(nMes == 4)
					dData := cTod("01/07/"+ str(nAno,4))
				elseif(nMes == 5)
					dData := cTod("01/09/"+ str(nAno,4))
				else
					dData := cTod("01/11/"+ str(nAno,4))
				endif
				
			case nAgrupFreq == BSC_FREQ_MENSAL
				dData := cTod("01/" + str(nMes,2)+"/"+ str(nAno,4) )
	
			case nAgrupFreq == BSC_FREQ_QUINZENAL
				if(nDia <= 15)
					dData := cTod("01/" + str(nMes,2)+"/"+ str(nAno,4) )
				else
					dData := cTod("16/" + str(nMes,2)+"/"+ str(nAno,4) )
				endif
		Endcase	 
    
  	/*TODO - Analisar o motivo pelo qual há a necessidade de se posicionar no primeiro dia do período e 
  	unificar o IF e o ELSE deste método.*/
	Else   
	
		Do Case
			case nAgrupFreq == BSC_FREQ_ANUAL	
				dData := lastDay(cTod("01/12/"+ str(nAno,4)))
				
			case nAgrupFreq == BSC_FREQ_SEMESTRAL
				if(nMes == 1)
					dData := lastDay(cTod("01/06/"+ str(nAno,4) ))
				else
					dData := lastDay(cTod("01/12/"+ str(nAno,4) ))
				endif
				
			case nAgrupFreq == BSC_FREQ_QUADRIMESTRAL	
				if(nMes == 1)
					dData := lastDay(cTod("01/04/"+ str(nAno,4)))										
				elseif(nMes ==2)
					dData := lastDay(cTod("01/08/"+ str(nAno,4)))										
				else
					dData := lastDay(cTod("01/12/"+ str(nAno,4)))											
				endif
				
			case nAgrupFreq == BSC_FREQ_TRIMESTRAL	
				if(nMes == 1)
					dData := lastDay(cTod("01/03/"+ str(nAno,4)))										
				elseif(nMes == 2)
					dData := lastDay(cTod("01/06/"+ str(nAno,4)))										
				elseif(nMes == 3)
					dData := lastDay(cTod("01/09/"+ str(nAno,4)))											
				else
					dData := lastDay(cTod("01/12/"+ str(nAno,4)))														
				endif
				
			case nAgrupFreq == BSC_FREQ_BIMESTRAL
				if(nMes == 1)
					dData := lastDay(cTod("01/02/"+ str(nAno,4)))
				elseif(nMes == 2)
					dData := lastDay(cTod("01/04/"+ str(nAno,4)))
				elseif(nMes == 3)
					dData := lastDay(cTod("01/06/"+ str(nAno,4)))
				elseif(nMes == 4)
					dData := lastDay(cTod("01/08/"+ str(nAno,4)))
				elseif(nMes == 5)
					dData := lastDay(cTod("01/10/"+ str(nAno,4)))
				else
					dData := lastDay(cTod("01/12/"+ str(nAno,4)))
				endif
				
			case nAgrupFreq == BSC_FREQ_MENSAL
				dData := lastDay(cTod("01/" + str(nMes,2)+"/"+ str(nAno,4)))
	
			case nAgrupFreq == BSC_FREQ_QUINZENAL
				if(nDia <= 15)
					dData := cTod("15/" + str(nMes,2)+"/"+ str(nAno,4))
				else
					dData := lastDay(cTod("16/" + str(nMes,2)+"/"+ str(nAno,4)))
				endif
		Endcase
	EndIf 
	
	/*SEMANAL e DIARIA não necessitam de nenhum tratamento especial.*/
 	Do Case
 		case nAgrupFreq == BSC_FREQ_SEMANAL
			/*Define o primeiro dia da semana como sendo o DOMINGO.*/			
			dData := dBIWeekToDate(nMes, nAno)
			
		case nAgrupFreq == BSC_FREQ_DIARIA		
			dData := cTod( str(nDia,2)+ "/" + str(nMes,2)+"/"+ str(nAno,4) )
	Endcase

return dData               

//Verifica se meta deve ser mostrada para o indicador atual.
method lChkProxMeta(nFrequencia,dDataMeta,dProxData) class TBSCValueTable
	local lRet := .F.

	if year(dDataMeta) == year(dProxData)
		do case
			case nFrequencia == BSC_FREQ_ANUAL	
				lRet	:= .T.
			case nFrequencia == BSC_FREQ_SEMESTRAL
				if month(dDataMeta) <= 6 .And. month(dProxData) <= 6
					lRet	:= .T.			
				elseIf month(dDataMeta) >= 7 .And. month(dProxData) >= 7 
					lRet	:= .T.
				endif
			case nFrequencia == BSC_FREQ_QUADRIMESTRAL	
				if ( month(dDataMeta) >= 1 .And. month(dDataMeta) <= 4) .And.;
				   ( month(dProxData) >= 1 .And. month(dProxData) <= 4) 				
							lRet := .T.
				elseif ( month(dDataMeta) >= 5 .And. month(dDataMeta) <= 8) .And.;
					   ( month(dProxData) >= 5 .And. month(dProxData) <= 8) 				
							lRet	:= .T.			
				elseif ( month(dDataMeta) >= 9 .And. month(dDataMeta) <= 12) .And.;
					   ( month(dProxData) >= 9 .And. month(dProxData) <= 12) 				
							lRet	:= .T.			
				endif
			case nFrequencia == BSC_FREQ_TRIMESTRAL	
				if ( month(dDataMeta) >= 1 .And. month(dDataMeta) <= 3) .And.;
				   ( month(dProxData) >= 1 .And. month(dProxData) <= 3) 				
							lRet := .T.
				elseif ( month(dDataMeta) >= 4 .And. month(dDataMeta) <= 6) .And.;
					   ( month(dProxData) >= 4 .And. month(dProxData) <= 6) 				
							lRet	:= .T.			
				elseif ( month(dDataMeta) >= 7 .And. month(dDataMeta) <= 9) .And.;
					   ( month(dProxData) >= 7 .And. month(dProxData) <= 9) 				
							lRet	:= .T.			
				elseif ( month(dDataMeta) >= 10 .And. month(dDataMeta) <= 12) .And.;
					   ( month(dProxData) >= 10 .And. month(dProxData) <= 12) 
							lRet	:= .T.			
				endif
			case nFrequencia == BSC_FREQ_BIMESTRAL	
				if ( month(dDataMeta) >= 1 .And. month(dDataMeta) <= 2) .And.;
				   ( month(dProxData) >= 1 .And. month(dProxData) <= 2) 				
							lRet := .T.
				elseif ( month(dDataMeta) >= 3  .And. month(dDataMeta) <= 4) .And.;
					   ( month(dProxData) >= 3  .And. month(dProxData) <= 4) 				
							lRet	:= .T.			
				elseif ( month(dDataMeta) >= 5  .And. month(dDataMeta) <= 6) .And.;
					   ( month(dProxData) >= 5  .And. month(dProxData) <= 6) 				
							lRet	:= .T.			
				elseif ( month(dDataMeta) >= 7  .And. month(dDataMeta) <= 8) .And.;
					   ( month(dProxData) >= 7  .And. month(dProxData) <= 8) 
							lRet	:= .T.			
				elseif ( month(dDataMeta) >= 9  .And. month(dDataMeta) <= 10) .And.;
					   ( month(dProxData) >= 9  .And. month(dProxData) <= 10) 
							lRet	:= .T.			
				elseif ( month(dDataMeta) >= 11 .And. month(dDataMeta) <= 12) .And.;
					   ( month(dProxData) >= 11 .And. month(dProxData) <= 12) 
							lRet	:= .T.			
				endif
			case nFrequencia == BSC_FREQ_MENSAL	
				if month(dDataMeta) == month(dProxData) 
					lRet	:= .T.
				endif			
			case nFrequencia == BSC_FREQ_QUINZENAL
				if month(dDataMeta) ==  month(dProxData)
					if  (day(dDataMeta) >= 1 .And. day(dProxData) >= 1) .And.;
						(day(dDataMeta) <= 15 .And. day(dProxData) <= 15)
							lRet := .T.
					elseif (day(dDataMeta) >= 16 .And. day(dProxData) >= 16)
							lRet := .T.
					endif
				endif
			case nFrequencia == BSC_FREQ_SEMANAL
				if nBIWeekOfYear(dDataMeta) == nBIWeekOfYear(dProxData )
					lRet := .T.
				endif
			case nFrequencia == BSC_FREQ_DIARIA		
				if dDataMeta == dProxData
					lRet := .T.
				endif
		endcase
	endif
		
return lRet

//Atualização das Planilhas de Valores e de Referencia
method nMudaPeriodo(nParentID, dDataIni, dDataFin)  class TBSCValueTable
	local nStatus := BSC_ST_OK, dDataIniAux, dDataFinAux, cAno, cMes, cDia, aDate
	local oIndicador
	local cTipo := ""
	local dData
	local nItem:= 0
	
	if("FCS"$::cEntity())
		cTipo := "FCSIND"
	else
		cTipo := "INDICADOR"
	endif

	oIndicador := ::oOwner():oGetTable(cTipo) //INDICADOR ou FCSIND
	oIndicador:lSeek(1, {nParentID})

	dDataIniAux := dDataIni
	dDataFinAux := dDataFin

	//Inclui dados na Planilha que estirem dentro do novo periodo
	cAno := cMes := cDia := ""
	while(dDataIni <= dDataFin)
		aDate := ::aDateConv(dDataIni, oIndicador:nValue("FREQ"))
		if(cDia!=aDate[3] .or. cMes!=aDate[2] .or. cAno!=aDate[1])
			cAno := aDate[1]
			cMes := aDate[2]
			cDia := aDate[3]
			
			// Altera os valores da tabela de meta se alterar a data  
			If (::cAlias() == "BSC016")
			
				// Converte para uma data no forma d/m/Y							
				dData:= ::dPerToDate(val(cAno),val(cMes),val(cDia), oIndicador:nValue("FREQ"), .T.) 
	
				// Procura se existe registro na data passada (dData) para a estratégia passada(nParentId).								
				if(!::lSeek(4, {'T', nParentID, dData}))					
									
					::lAppend({ {"ID", ::nMakeID()},;
						{"PARENTID", nParentID},;
						{"CONTEXTID", oIndicador:nValue("CONTEXTID")},;
						{"FEEDBACK",0},;
						{"DATAALVO",dData}, ;
						{"PARCELADA","T"},;     
						{"NOME",::getPerText(aDate,oIndicador:nValue("FREQ")) + " - Parcelado"},;
						{"DESCRICAO",""},;
						{"ITEM",nItem},;
						{"ITEM2",0},;
						{"AZUL1",0},;
						{"VERDE",0},;
						{"AMARELO",0},;
						{"VERMELHO",0},;
						{"AMARELO",0},;
			 			{"RESPID",0} })
			 			
			 			nItem++
				EndIf		
			Else
				if(!::lSeek(2, {nParentID, cAno, cMes, cDia}))
					::lAppend({ {"ID", ::nMakeID()}, {"PARENTID", nParentID}, {"CONTEXTID", oIndicador:nValue("CONTEXTID")},;
									{"ANO", cAno}, {"MES", cMes}, {"DIA", cDia} })
				EndIf			
			EndIf
		EndIf
		dDataIni++
	end

	//Deleta dados da Planilha que vierem antes do periodo inicial
	dDataIni := dDataIniAux
	dDataFin := dDataFinAux
	cAno := cMes := cDia := ""
	aDate := ::aDateConv(dDataIni, oIndicador:nValue("FREQ"))	
				
	if(cDia!=aDate[3] .or. cMes!=aDate[2] .or. cAno!=aDate[1])
		cAno := aDate[1]
		cMes := aDate[2]
		cDia := aDate[3] 
		
		// Se for 'meta'. 
		If (::cAlias() == "BSC016")					
		
			// Converte para uma data no formato d/m/Y							
			dData:= ::dPerToDate(val(cAno),val(cMes),val(cDia), oIndicador:nValue("FREQ"), .T.)			
		
			// Procura se existe registro na data passada (dData) para a estratégia passada(nParentId).
			if(::lSeek(4, {'T', nParentID, dData}))
				::_Prior()
				while(!::lBof() .and. ::cValue("PARENTID") == cBIStr(nParentID))
					if(!::lDelete())
						nStatus := BSC_ST_INUSE
					endif
					::_Prior()
				end
			EndIf
		Else
			if(::lSeek(2, {nParentID, cAno, cMes, cDia}))
				::_Prior()
				while(!::lBof() .and. ::cValue("PARENTID") == cBIStr(nParentID))
					if(!::lDelete())
						nStatus := BSC_ST_INUSE
					endif
					::_Prior()
				end
			endif
		EndIf
	endif

	//Deleta dados da Planilha que vierem depois do periodo final.
	dDataIni := dDataIniAux
	dDataFin := dDataFinAux
	cAno := cMes := cDia := ""
	aDate := ::aDateConv(dDataFin, oIndicador:nValue("FREQ"))
	if(cDia!=aDate[3] .or. cMes!=aDate[2] .or. cAno!=aDate[1])
		cAno := aDate[1]
		cMes := aDate[2]
		cDia := aDate[3]    
		
		// Se for 'meta'. 
		If (::cAlias() == "BSC016")		
		
			// Converte para uma data no formato d/m/Y.							
			dData:= ::dPerToDate(val(cAno),val(cMes),val(cDia), oIndicador:nValue("FREQ"), .T.)			
		
			// Procura se existe registro na data passada (dData) para a estratégia passada(nParentId).
			if(::lSeek(4, {'T', nParentID, dData}))
				::_Next()
				while(!::lEof() .and. ::cValue("PARENTID") == cBIStr(nParentID))
					if(!::lDelete())
						nStatus := BSC_ST_INUSE
					endif
					::_Next()
				end
			EndIf
		Else                   
			if(::lSeek(2, {nParentID, cAno, cMes, cDia}))
				::_Next()
				while(!::lEof() .and. ::cValue("PARENTID") == cBIStr(nParentID))
					if(!::lDelete())
						nStatus := BSC_ST_INUSE
					endif
					::_Next()
				end
			endif
		EndIf
	EndIf
	
	// Recalcula a Planilha.
	If !(::cAlias() == "BSC016" )	
		::nRecalcula(oIndicador:nValue("ID"))
	EndIf

return nStatus

function _BSCValueTable()
Return