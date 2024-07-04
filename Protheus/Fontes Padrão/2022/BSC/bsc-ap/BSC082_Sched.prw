// ######################################################################################
// Projeto: BSC
// Modulo : Agendador
// Fonte  : TBSC082.prw
// ---------+---------------------------+------------------------------------------------
// Data     | Autor                     | Descricao
// ---------+---------------------------+------------------------------------------------
// 19.10.04 | 0739 Aline Correa do Vale |
// 08.06.09 | 3510 Gilmar P. Santos     | FNC: 00000012280/2009
// --------------------------------------------------------------------------------------
#define TAG_ENTITY "AGENDAMENTO"
#define TAG_GROUP  "AGENDAMENTOS"
#define TEXT_ENTITY STR0001/*//"Agendamento"*/
#define TEXT_GROUP  STR0002/*//"Agendamentos"*/

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC082_Sched.ch"

class TBSC082 from TBITable

	method New() constructor
	method NewBSC082()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)

	// registro atual
	method oToXMLNode(nParentID)
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	method nDuplicate(nParentID, nNewParentID, nNewContextID)
endclass
	
method New() class TBSC082
	::NewBSC082() 
return

method NewBSC082() class TBSC082

	// Table
	::NewTable("BSC082")
	::cEntity("AGENDADOR")
	// Fields
	::addField(TBIField():New("ID"			,"N"))
	::addField(TBIField():New("PARENTID"	,"N"))
	::addField(TBIField():New("CONTEXTID"	,"N"))
	::addField(TBIField():New("FEEDBACK"	,"N"))
	::addField(TBIField():New("NOME"		,"C"	,60)) //nome do agendamento
	::addField(TBIField():New("DATAINI"		,"D"	,8))   	//data inicial válida
	::addField(TBIField():New("HORAINI"		,"C"	,5))   	//hora inicial válida
	::addField(TBIField():New("DATAFIM"		,"D"	,8))   	//data final válida
	::addField(TBIField():New("HORAFIM"		,"C"	,5))   	//hora final válida
	::addField(TBIField():New("FREQ"		,"N"	  ))	//frequencia: 1-Diário 2-Semanal 3-Mensal
	::addField(TBIField():New("DIAFIRE"		,"N"	  ))	//dia do mês ou semana que será executado
	::addField(TBIField():New("HORAFIRE"	,"C"	,5))   	//horário que será executado
	::addField(TBIField():New("DATAEXE"		,"D"	,8))	//data da última execução
	::addField(TBIField():New("HORAEXE"		,"C"	,5))    //horário da última execução
	::addField(TBIField():New("DATANEXT"	,"D"	,8))	//data da próxima execução
	::addField(TBIField():New("HORANEXT"	,"C"	,5))	//horário da próxima execução
	::addField(TBIField():New("ACAO"		,"C"	,120))	//acao a ser executada neste agendamento
	::addField(TBIField():New("ENV"			,"C"	,50))	//Enviroment da execucao     
	::addField(TBIField():New("IDACAO"		,"N"	  ))	//Identificador da ação atual. 
	::addField(TBIField():New("ELEMENTO"	,"N"	  ))	//Elemento selecionado. 
		
	// Indexes
	::addIndex(TBIIndex():New("BSC082I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC082I02",	{"NOME", "CONTEXTID"},	.t.)) //Ação
	::addIndex(TBIIndex():New("BSC082I03",	{"PARENTID", "ID"},	.t.))
	::addIndex(TBIIndex():New("BSC082I04",	{"DATAINI", "HORAINI", "ID"}, .f.))
return

// Arvore
method oArvore(nParentID) class TBSC082
	local oXMLArvore, oNode
	
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 1)
	oAttrib:lSet("TIPO", TAG_GROUP)
	oAttrib:lSet("NOME", TEXT_GROUP)
	oXMLArvore := TBIXMLNode():New(TAG_GROUP,"",oAttrib)

	::SetOrder(4) // Por ordem de data-hora
	if(!empty(nParentID))
		::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
		::lFiltered(.t.)
	endif
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
	::cSQLFilter("") // Encerra filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC082
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", STR0003) //Ação 
	oAttrib:lSet("CLA000", BSC_STRING)
	// Data Inicio
	oAttrib:lSet("TAG001", "DATAINI")
	oAttrib:lSet("CAB001", STR0004)/*//"Data inicio para Execucao"*/
	oAttrib:lSet("CLA001", BSC_DATE)
	// Data Fim
	oAttrib:lSet("TAG002", "DATAFIM")
	oAttrib:lSet("CAB002", STR0005)/*//"Data final para Execucao"*/
	oAttrib:lSet("CLA002", BSC_DATE)


	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(4) // Por ordem de data-hora
	if(!empty(nParentID))
		::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	else
		::cSQLFilter("ID <> "+cBIStr(0)) // Filtra pelo pai
	endif
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID"})
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1]=="RESPID")
				oTable := ::oOwner():oGetTable("PESSOA")
				oTable:lSeek(1, {aFields[nInd][2]})
				aFields[nInd][1] := "RESPONSAVEL"
				aFields[nInd][2] := oTable:cValue("NOME")
			endif
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode() class TBSC082
	Local aFields 		:= ::xRecord(RF_ARRAY)
	Local nInd          := 0
	Local oNode         := Nil
	Local oComando     	:= ""
	Local oXMLNode 		:= TBIXMLNode():New(TAG_ENTITY)
   	Local oAttrib 		:= TBIXMLAttrib():New()
	
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)

	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
	next

	oNode := oXMLNode:oAddChild(TBIXMLNode():New("COMANDOS"))
	
	oComando := oNode:oAddChild(TBIXMLNode():New("COMANDO"))
	oComando:oAddChild(TBIXMLNode():New("ID", 1))
	oComando:oAddChild(TBIXMLNode():New("NOME", STR0012)) // "Notificar Reuniões"
	oComando:oAddChild(TBIXMLNode():New("ACAO", "NotifyMeeting"))

	oComando := oNode:oAddChild(TBIXMLNode():New("COMANDO"))
	oComando:oAddChild(TBIXMLNode():New("ID", 2))
	oComando:oAddChild(TBIXMLNode():New("NOME", STR0013)) //"Importar Fonte de Dados"
	oComando:oAddChild(TBIXMLNode():New("ACAO", "BscDataSrcJob"))

	oComando := oNode:oAddChild(TBIXMLNode():New("COMANDO"))
	oComando:oAddChild(TBIXMLNode():New("ID", 4))
	oComando:oAddChild(TBIXMLNode():New("NOME", STR0015)) //"Notificar Prazo de Iniciativas"
	oComando:oAddChild(TBIXMLNode():New("ACAO", "NotifyDelay"))

	oComando := oNode:oAddChild(TBIXMLNode():New("COMANDO"))
	oComando:oAddChild(TBIXMLNode():New("ID", 5))
	oComando:oAddChild(TBIXMLNode():New("NOME", STR0016)) //"Notificar Prazo de Tarefas"
	oComando:oAddChild(TBIXMLNode():New("ACAO", "NtfDelayTask"))

	oComando := oNode:oAddChild(TBIXMLNode():New("COMANDO"))
	oComando:oAddChild(TBIXMLNode():New("ID", 3))
	oComando:oAddChild(TBIXMLNode():New("NOME", STR0014)) //"Outros"
	oComando:oAddChild(TBIXMLNode():New("ACAO", ""))

	oXMLNode:oAddChild(oNode)

	oXMLNode:oAddChild(::oOwner():oGetTable("REUNIAO"):oToXMLList())
	oXMLNode:oAddChild(::oOwner():oGetTable("DATASRC"):oToXMLList())
return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC082
	local aFields, nInd, nStatus := BSC_ST_OK 
	local dNextFire		:= nil  
	local nPosDtNext	:= 0
	local nPosHrNext	:= 0
	private oXMLInput 	:= oXML

	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		if(aFields[nInd][1] == "HORAINI" .or. aFields[nInd][1] == "HORAFIM")
			cHora := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
			if(len(alltrim(cHora)) < 5)
				cHora := "0"+alltrim(cHora)
			endif
			aFields[nInd][2] := cHora
		else
			aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		endif
		
		if aFields[nInd][1] == "DATANEXT"
			//Captura a posicao data da próxima execução
			nPosDtNext := nInd
		elseif aFields[nInd][1] == "HORANEXT"
			//Captura a posicao hora da próxima execução
			nPosHrNext := nInd
		endif
		
	next   
	
	
	//Calcula a proxima execução    
	dNextFire := buildNextFire(		val(oXMLInput:_REGISTROS:_AGENDAMENTO:_FREQ:TEXT),; 
									allTrim(oXMLInput:_REGISTROS:_AGENDAMENTO:_HORAFIRE:TEXT),;  
									cTod(oXMLInput:_REGISTROS:_AGENDAMENTO:_DATAINI:TEXT),;  
									val(oXMLInput:_REGISTROS:_AGENDAMENTO:_DIAFIRE:TEXT),;
									allTrim(oXMLInput:_REGISTROS:_AGENDAMENTO:_HORAFIM:TEXT),;  
									cTod(oXMLInput:_REGISTROS:_AGENDAMENTO:_DATAFIM:TEXT) )
		if dNextFire == nil
			aFields[nPosHrNext][2] := space(5)
			aFields[nPosDtNext][2] := space(8)
		else
			aFields[nPosHrNext][2] := oXMLInput:_REGISTROS:_AGENDAMENTO:_HORAFIRE:TEXT 
			aFields[nPosDtNext][2] := dNextFire
		endif
	
	
	
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
method nUpdFromXML(oXML, cPath) class TBSC082
	local nStatus := BSC_ST_OK,	nID, nInd, cHora := ""  
	local dNextFire		:= nil  
	local nPosDtNext	:= 0
	local nPosHrNext	:= 0
	private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		if(aFields[nInd][1] == "HORAINI" .or. aFields[nInd][1] == "HORAFIM")
			cHora := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
			if(len(alltrim(cHora)) < 5)
				cHora := "0"+alltrim(cHora)
			endif
			aFields[nInd][2] := cHora
		else
			aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		endif
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
		if aFields[nInd][1] == "DATANEXT"
			//Captura a posicao data da próxima execução
			nPosDtNext := nInd
		elseif aFields[nInd][1] == "HORANEXT"
			//Captura a posicao hora da próxima execução
			nPosHrNext := nInd
		endif
	next    
	
	//Calcula a proxima execução    
	dNextFire := buildNextFire(		val(oXMLInput:_REGISTROS:_AGENDAMENTO:_FREQ:TEXT),; 
									allTrim(oXMLInput:_REGISTROS:_AGENDAMENTO:_HORAFIRE:TEXT),;  
									cTod(oXMLInput:_REGISTROS:_AGENDAMENTO:_DATAINI:TEXT),;  
									val(oXMLInput:_REGISTROS:_AGENDAMENTO:_DIAFIRE:TEXT),;
									allTrim(oXMLInput:_REGISTROS:_AGENDAMENTO:_HORAFIM:TEXT),;  
									cTod(oXMLInput:_REGISTROS:_AGENDAMENTO:_DATAFIM:TEXT) )
	if dNextFire == nil
		aFields[nPosHrNext][2] := space(5)
		aFields[nPosDtNext][2] := space(8)
	else
		aFields[nPosHrNext][2] := oXMLInput:_REGISTROS:_AGENDAMENTO:_HORAFIRE:TEXT 
		aFields[nPosDtNext][2] := dNextFire
	endif

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
method nDelFromXML(nID) class TBSC082
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

// Duplica os registros filhos de nParentID, colocando-os como filhos de nNewParentID do conDETALHES nNewContextID
method nDuplicate(nParentID, nNewParentID, nNewContextID) class TBSC082
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

function _BSC082_Sched()
return