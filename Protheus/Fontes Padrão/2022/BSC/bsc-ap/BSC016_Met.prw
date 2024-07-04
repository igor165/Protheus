// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC016_Met.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC016_Met.ch"

/*--------------------------------------------------------------------------------------
@class TBSC016
@entity Meta
Meta de performance. Alvos estão atrelados a Indicadores e divididos ao logo do tempo.
@table BSC016
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "META"
#define TAG_GROUP  "METAS"
#define TEXT_ENTITY STR0001/*//"Meta"*/
#define TEXT_GROUP  STR0002/*//"Metas"*/   

class TBSC016 from TBSCValueTable
	method New() constructor
	method NewBSC016()

	// Diversos registros.
	method oArvore(nParentID)
	method oToXMLList(nParentID)
	// Registro atual.
	method oToXMLNode(nParentID)
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	method xVirtualField(cField, xValue)
	method nDuplicate(nParentID, nNewParentID, nNewContextID)
	method nDelIndicador(oIndicador)
	
	method nInsIndicador(oIndicador) //Insere nova entidade  
	method nRecalcAcum(oIndicador)   //Recalcula as metas acumuladas
	method nUpdMeta(aFields)		 //Se existir atualiza caso contrario insere
endclass

method New() class TBSC016
	::NewBSC016()
return
method NewBSC016() class TBSC016
	local oVirtual, oField
	
	// Table
	::NewTable("BSC016")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(oField := TBIField():New("NOME",		"C",	60))
	oField:lSensitive(.f.)
	::addField(TBIField():New("DESCRICAO",	"C",	255))
	::addField(TBIField():New("DATAALVO",	"D"))
	::addField(TBIField():New("PARCELADA",	"C", 	1))  // Lógico: "T" - verdadeiro ; "F" ou " "
	::addField(TBIField():New("ITEM",		"N"))
	::addField(TBIField():New("ITEM2",		"N"))
	::addField(TBIField():New("AZUL1",		"N", 19, 6))
	::addField(TBIField():New("VERDE",		"N", 19, 6))
	::addField(TBIField():New("AMARELO",	"N", 19, 6))
	::addField(TBIField():New("VERMELHO",	"N", 19, 6))
	::addField(TBIField():New("AVALMEMO",	"M"))
	::addField(TBIField():New("RESPID",		"N"))	// ID de pessoa em cobranca
	::addField(TBIField():New("TIPOPESSOA",	"C",	1)) //G = Grupo, P = Individual
	// Virtual Fields
	oVirtual := TBIField():New("ASCEND",	"L")
	oVirtual:bGet({|oTable| oTable:xVirtualField("ASCEND")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("ASCEND", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("DECIMAIS",	"N")
	oVirtual:bGet({|oTable| oTable:xVirtualField("DECIMAIS")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("DECIMAIS", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("FREQ",	"N")
	oVirtual:bGet({|oTable| oTable:xVirtualField("FREQ")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("FREQ", xValue)})
	::addField(oVirtual)
	// Indexes.
	::addIndex(TBIIndex():New("BSC016I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC016I02",	{"NOME", "CONTEXTID"}))
	::addIndex(TBIIndex():New("BSC016I03",	{"PARENTID", "ID"},	.t.))
	::addIndex(TBIIndex():New("BSC016I04",	{"PARCELADA", "PARENTID", "DATAALVO"}, .t.))
return

// xVirtualField.
method xVirtualField(cField, xValue) class TBSC016
	local oTable, xRet := xValue
	if(valtype(xValue)=="U")
		oTable := ::oOwner():oGetTable("INDICADOR")
		oTable:lSeek(1, {::nValue("PARENTID")})
		xRet := oTable:xValue(cField)
	endif
return xRet

// Arvore.
method oArvore(nParentID) class TBSC016
	local oXMLArvore, oNode
	
	::SetOrder(4) // Por ordem de data alvo.
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtrar pelo pai.
	::lFiltered(.t.)
	::_First()
	if(!::lEof())
		// Tag conjunto.
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", 1)
		oAttrib:lSet("TIPO", TAG_GROUP)
		oAttrib:lSet("NOME", TEXT_GROUP)
		oXMLArvore := TBIXMLNode():New(TAG_GROUP,"",oAttrib)
		// Nodes
		while(!::lEof())
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", ::nValue("ID"))
			oAttrib:lSet("NOME", alltrim(::cValue(STR0003)))/*//"Nome"*/
			oAttrib:lSet("FEEDBACK", ::nValue("FEEDBACK"))
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Limpar filtro.
return oXMLArvore

// Lista XML para anexar ao pai.
method oToXMLList(nParentID) class TBSC016
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas.
	oAttrib := TBIXMLAttrib():New()
	// Tipo.
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome.
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", BSC_STRING)
	// Data Alvo.
	oAttrib:lSet("TAG001", "DATAALVO")
	oAttrib:lSet("CAB001", STR0004)/*//"Data Alvo"*/
	oAttrib:lSet("CLA001", BSC_DATE)
	// Gerar nó principal.
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(4) // Por ordem de data alvo.
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai.
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","AZUL","VERDE","AMARELO","VERMELHO","AVALMEMO","RESPID", "TIPOPESSOA"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentID) class TBSC016
	local nID, aFields, nInd, cTipoPessoa, nRespID
	local oTable, oXMLNode := TBIXMLNode():New(TAG_ENTITY)
	local lVerNumeros, nEstID, oEstrategia

	// Verifica Segurança.
	lVerNumeros := ::oOwner():foSecurity:lHasParentAccess("META", ::nValue("ID"), "NUMEROS")

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY,{"ASCEND","DECIMAIS","FREQ"})
	for nInd := 1 to len(aFields)
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		elseif( aFields[nInd][1] == "AZUL1" .or.;
				 aFields[nInd][1] == "VERDE" .or.;
				 aFields[nInd][1] == "AMARELO" .or.;
				 aFields[nInd][1] == "VERMELHO" )
			if(valtype(nParentID)!= "U") // Somente para novo registro
				aFields[nInd][2] := if(lVerNumeros,aFields[nInd][2],0)
			endif
		elseif(aFields[nInd][1] == "RESPID")
			nRespId := aFields[nInd][2]
		elseif(aFields[nInd][1] == "TIPOPESSOA")
			cTipoPessoa := aFields[nInd][2]
		endif
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
	next

	// Virtuais
	if(cTipoPessoa=="G")
		oTable := ::oOwner():oGetTable("PGRUPO")
	else
		oTable := ::oOwner():oGetTable("PESSOA")
	endif
	oTable:lSeek(1, {nRespId})
	oXMLNode:oAddChild(TBIXMLNode():New("RESPONSAVEL", oTable:cValue("NOME")))

	// Combos
	oTable := self
	if(nID==0)
		oTable := ::oOwner():oGetTable("INDICADOR")
		oTable:lSeek(1, {nParentID})
	endif	
		
	oXMLNode:oAddChild(TBIXMLNode():New("ASCEND", oTable:lValue("ASCEND")))
	oXMLNode:oAddChild(TBIXMLNode():New("DECIMAIS", oTable:nValue("DECIMAIS")))
	oXMLNode:oAddChild(TBIXMLNode():New("FREQ", oTable:nValue("FREQ")))
		
	nEstID := ::oOwner():oAncestor("ESTRATEGIA", oTable):nValue("ID")
	oEstrategia := ::oOwner():oGetTable("ESTRATEGIA")
	oEstrategia:lSeek(1, {nEstID})
	oXMLNode:oAddChild(TBIXMLNode():New("DATAINI", oEstrategia:dValue("DATAINI")))
	oXMLNode:oAddChild(TBIXMLNode():New("DATAFIN", oEstrategia:dValue("DATAFIN")))

	oXMLNode:oAddChild(::oOwner():oContext(self, nParentID))

return oXMLNode

// Inserir nova entidade.
method nInsFromXML(oXML, cPath) class TBSC016
	local aFields, nInd, nStatus := BSC_ST_OK
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML.
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
method nUpdFromXML(oXML, cPath) class TBSC016
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

	// Verifica condições de gravação (append ou update).
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

// Excluir entidade do server.
method nDelFromXML(nID) class TBSC016
	local nStatus := BSC_ST_OK
	
	// Deletar o elemento.
	if(::lSeek(1, {nID}))
		if(!::lDelete())
			nStatus := BSC_ST_INUSE
		endif
	else
		nStatus := BSC_ST_BADID
    endif

	// Quando implementar security
	// nStatus := BSC_ST_NORIGHTS
return nStatus            

// Insere nova entidade
method nInsIndicador(oIndicador) class TBSC016
	local nStatus := BSC_ST_OK
	local nParentID, nContextID, nFrequencia
	local oEstrategia, dDataIni, dDataFin
	local cAno, cMes, cDia   
	local dData                     
	local nItem	:= 0  
 	
	// Carrega vars.
	nParentID := oIndicador:nValue("ID")
	nContextID := oIndicador:nValue("CONTEXTID")
	nFrequencia := oIndicador:nValue("FREQ")
	
	// Encontra o plano estratégico.
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
			 
			
				dData:= ::dPerToDate(val(cAno),val(cMes),val(cDia),nFrequencia, .T.)
				
				::lAppend({ {"ID", ::nMakeID()},;
							{"PARENTID", nParentID},;
							{"CONTEXTID", nContextID},;
							{"FEEDBACK",0},;
							{"DATAALVO",dData}, ;
							{"PARCELADA","T"},;     
							{"NOME",::getPerText(aDate,nFrequencia) + " - Parcelado"},;
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
		endif   
		dDataIni++
	enddo

return nStatus


//Remove todos os registros
method nDelIndicador(oIndicador) class TBSC016
	local nStatus := BSC_ST_OK

	::cSQLFilter("PARENTID = " + cBIStr(oIndicador:nValue("ID")))
	::lFiltered(.t.)
	::_First()
	while(!::lEof()) 
		if(::lValue("PARCELADA"))
			if(!::lDelete())
				nStatus := BSC_ST_INUSE
			endif
		endif
		::_Next()
	end
	::cSQLFilter("") // Limpar filtro	
return  nStatus


// Duplica os registros filhos de nParentID, colocando-os como filhos de nNewParentID do contexto nNewContextID
method nDuplicate(nParentID, nNewParentID, nNewContextID) class TBSC016
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
			exit
		endif
		::restPos()

		::_Next()
	enddo
	::cSQLFilter("") // Limpar filtro

	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()
return nStatus


//Recalcula as metas acumuladas
method nRecalcAcum(oIndicador) class TBSC016
	local nStatus 	:= BSC_ST_OK
	local aDataAux 	:= {"0000", "00", "00"}
	local aDataOld 	:= {"0000", "00", "00"}
	local aReg			:= {}
	local nLineCount 	:= 0
	local nAcAzul 	:= 0
	local nAcVerde 	:= 0
	local nAcAmarelo 	:= 0
	local nAcVermelho := 0   
	local nTotAzul 	:= 0
	local nTotVerde 	:= 0
	local nTotAmarelo := 0
	local nTotVermelho:= 0   
	local nI			:= 0
	local dDataAux	:= nil   
	local cQuery		:= "" 
	local cMsg			:= ""
	Local cShowAcu 	:= ""
	
	//Verifica se Indicador é Cumulativo.
	if(oIndicador:lValue("CUMULATIVO"))
		//Excluindo metas acumuladas.
		cQuery:="DELETE FROM BSC016 WHERE PARCELADA <> 'T' AND PARENTID =" + cBIStr(oIndicador:nValue("ID"))
		TCSQLEXEC(cBIParseSQL(cQuery, @cMsg))
		TCREFRESH("BSC016")
	
		::SetOrder(4)
		::cSQLFilter("ID <> 0 AND PARCELADA='T' AND PARENTID = "+cBIStr(oIndicador:nValue("ID"))) // Filtra pelo pai
		::lFiltered(.t.)
		::_First()
		while(!::lEof())
				 
			dDataAux := dPerPData(year(::dValue("DATAALVO")), month(::dValue("DATAALVO")), day(::dValue("DATAALVO")), oIndicador:nValue("FREQ"))		 
					 			 
			aDataAux := ::aDateConv(dDataAux, oIndicador:nValue("FCUMULA"))
			if(::nDataComp(aDataOld, aDataAux) != 0 .and. oIndicador:nValue("FCUMULA") != 0)
				aDataOld := aDataAux
				nAcAzul := ::nValue("AZUL1")
				nAcVerde := ::nValue("VERDE")
				nAcAmarelo := ::nValue("AMARELO")
				nAcVermelho := ::nValue("VERMELHO")
				
				// Para de contar as linhas por algum tempo
				nLineCount := 1
			else
				// Tipo de acumulação                      
				if 	oIndicador:nValue("TCUMULA") == BSC_MT_EDT
					nAcAzul := ::nValue("AZUL1")
					nAcVerde := ::nValue("VERDE")
					nAcAmarelo := ::nValue("AMARELO")
					nAcVermelho := ::nValue("VERMELHO")
				else    
					nAcAzul += ::nValue("AZUL1")
					nAcVerde += ::nValue("VERDE")
					nAcAmarelo += ::nValue("AMARELO")
					nAcVermelho += ::nValue("VERMELHO")
				endif		
				
				// Conta quantas linhas até o momento
				nLineCount++
			endif
		
			if (oIndicador:nValue("TCUMULA") == BSC_MT_AVG)
				nTotAzul := round(nAcAzul/nLineCount, oIndicador:nValue("DECIMAIS"))
				nTotVerde := round(nAcVerde/nLineCount, oIndicador:nValue("DECIMAIS"))
				nTotAmarelo := round(nAcAmarelo/nLineCount, oIndicador:nValue("DECIMAIS"))
				nTotVermelho := round(nAcVermelho/nLineCount, oIndicador:nValue("DECIMAIS"))
			else                                                                            
				nTotAzul := nAcAzul
				nTotVerde := nAcVerde
				nTotAmarelo := nAcAmarelo
				nTotVermelho := nAcVermelho
			endif
			
			// Se Indicador for semanal, nome do acumulador igual o nome do parcelado.
			If (oIndicador:nValue("FREQ") == BSC_FREQ_SEMANAL)
				cShowAcu += SubStr(Alltrim(::cValue("NOME")), 1, 10)
				cShowAcu += " - Acumulado"
			Else
				aDataAux := ::aDateConv(dDataAux, oIndicador:nValue("FREQ"))
				cShowAcu += ::getPerText(aDataAux,oIndicador:nValue("FREQ")) + " - Acumulado"
			EndIf			
			
			aAdd(aReg,{	{"PARENTID", 	::nValue("PARENTID")},;  
						{"CONTEXTID",	::nValue("CONTEXTID")},; 
						{"FEEDBACK", 	::nValue("FEEDBACK")},; 
						{"NOME", 		cShowAcu},;
						{"DESCRICAO", 	""},;
						{"DATAALVO", 	::dValue("DATAALVO")},;
						{"PARCELADA", 	"F"},;
						{"AZUL1", 		nTotAzul},;
						{"VERDE", 		nTotVerde},;
						{"AMARELO", 	nTotAmarelo},;
						{"VERMELHO", 	nTotVermelho},;
						{"RESPID", 		::nValue("RESPID")},;
						{"TIPOPESSOA", 	::cValue("TIPOPESSOA")} })
	
			::_Next()
			cShowAcu := ""
		enddo
		::cSQLFilter("")
	          
		//Atualizando os registros
		for nI := 1 to len(aReg)
			::nUpdMeta(aReg[nI])
		next
    endif
return nStatus 

//Se existir atualiza caso contrario insere
method nUpdMeta(aFields) class TBSC016  
	local nStatus 	 := BSC_ST_OK 
	local cParcelada := ""
	local nParentId	 := 0
	local dDataAlvo  := nil
	local nPos		 := 0
	
	nPos := aScan(aFields, {|x| x[1] == "PARCELADA"})
	if(nPos!=0)
		cParcelada := aFields[nPos][2]
	endif
	
	nPos := aScan(aFields, {|x| x[1] == "PARENTID"})
	if(nPos!=0)
		nParentId := aFields[nPos][2]
	endif
	
	nPos := aScan(aFields, {|x| x[1] == "DATAALVO"})
	if(nPos!=0)
		dDataAlvo := aFields[nPos][2]
	endif
	
	if ::lSeek(4, {cParcelada,nParentId,dDataAlvo})
		//Atualiza
		if(!::lUpdate(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif	
	else    
		//Grava
		aAdd(aFields, {"ID", ::nMakeID()})
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif	
	endif

return nStatus           

function _BSC016_Met()
return

/*
 * dPerPdata = Converte um Período para uma data.
 * @param nAno Integer  = Ano. (ex: 2013)
 * @param nMes Integer  = Mes. (ex: 4)
 * @param nDia Integer  = Dia. (ex: 15)
 * @param nFreq Integer = Frequência (ex: 4)
 * @return date = Data no formato d/m/Y
 * @Author Helio Leal 
 */
Static Function dPerPData(nAno, nMes, nDia, nFreq)
	Local dData := cTod("")

	Do Case
		Case nFreq == BSC_FREQ_ANUAL	
		
			dData := cTod("01/01/"+ Str(nAno,4) )
			
		Case nFreq == BSC_FREQ_SEMESTRAL
			
			If(nMes <= 6)
				dData := cTod("01/01/"+ Str(nAno,4) ) // Primeiro Semestre.
			Else
				dData := cTod("01/07/"+ Str(nAno,4) ) // Segundo Semestre.
			EndIf
			
		Case nFreq == BSC_FREQ_QUADRIMESTRAL
		
			If(nMes <= 4)
				dData := cTod("01/01/"+ Str(nAno,4)) // Primeiro Quadrimestre.									
			ElseIf(nMes <=8)
				dData := cTod("01/05/"+ Str(nAno,4)) // Segundo Quadrimestre.		
			Else
				dData := cTod("01/09/"+ Str(nAno,4)) // Terceiro Quadrimestre. 
			EndIf
			
		Case nFreq == BSC_FREQ_TRIMESTRAL
			
			If(nMes <= 3)
				dData := cTod("01/01/"+ Str(nAno,4)) // Primeiro Trimestre. 
			ElseIf(nMes <= 6)
				dData := cTod("01/04/"+ Str(nAno,4)) // Segundo Trimestre.
			ElseIf(nMes <= 9)
				dData := cTod("01/07/"+ Str(nAno,4)) // Terceiro Trimestre.
			Else
				dData := cTod("01/10/"+ Str(nAno,4)) // Quarto Trimestre. 
			EndIf
			
		Case nFreq == BSC_FREQ_BIMESTRAL
			
			If(nMes <= 2)
				dData := cTod("01/01/"+ Str(nAno,4)) // Primeiro Bimestre.
			ElseIf(nMes <= 4)
				dData := cTod("01/03/"+ Str(nAno,4)) // Segundo Bimestre.
			ElseIf(nMes <= 6)
				dData := cTod("01/05/"+ Str(nAno,4)) // Terceiro Bimestre.
			ElseIf(nMes <= 8)
				dData := cTod("01/07/"+ Str(nAno,4)) // Quarto Bimestre.
			ElseIf(nMes <= 10)
				dData := cTod("01/09/"+ Str(nAno,4)) // Quinto Bimestre.
			Else
				dData := cTod("01/11/"+ Str(nAno,4)) // Sexto Bimestre.
			EndIf
			
		Case nFreq == BSC_FREQ_MENSAL
		
			dData := cTod("01/" + Str(nMes,2)+"/"+ Str(nAno,4) )

		Case nFreq == BSC_FREQ_QUINZENAL
		
			If(nDia <= 15)
				dData := cTod("01/" + Str(nMes,2)+"/"+ Str(nAno,4) ) // Primeira Quinzena. 
			Else
				dData := cTod("16/" + Str(nMes,2)+"/"+ Str(nAno,4) ) // Segunda Quinzena. 
			EndIf
			
		Case nFreq == BSC_FREQ_SEMANAL
						
			dData := dBIWeekToDate(nMes, nAno) // Define o primeiro dia da semana como sendo o DOMINGO.

		Case nFreq == BSC_FREQ_DIARIA
				
			dData := cTod( str(nDia,2)+ "/" + Str(nMes,2)+"/"+ Str(nAno,4) )
			
	EndCase
	
Return dData