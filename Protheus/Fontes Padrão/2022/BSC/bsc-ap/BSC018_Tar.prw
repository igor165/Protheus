// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC018_Tar.prw
// ---------+-----------------------+----------------------------------------------------
// Data     | Autor                 | Descricao
// ---------+-----------------------+----------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli |
// 08.06.09 | 3510 Gilmar P. Santos | FNC: 00000012280/2009
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC018_Tar.ch"

/*--------------------------------------------------------------------------------------
@class TBSC018
@entity Tarefa
Parte de iniciativa, usada para dividí-la.
@table BSC018
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "TAREFA"
#define TAG_GROUP  "TAREFAS"
#define TEXT_ENTITY STR0001/*//"Tarefa"*/
#define TEXT_GROUP  STR0002/*//"Tarefas"*/

class TBSC018 from TBITable
	method New() constructor
	method NewBSC018()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)
	method oXMLImportancia()
	method oXMLUrgencia()
	method aCompletado(cNomeUsuario, dDataDe, dDataAte)

	// registro atual
	method oToXMLNode(nParentID)
	method nInsFromXML(nID)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(oXML, cPath)
	method oXMLSituacao()
	method xVirtualField(cField, xValue)
	
	method nDuplicate(nParentID, nNewParentID, nNewContextID)
endclass

method New() class TBSC018
	::NewBSC018()
return
method NewBSC018() class TBSC018
	local oField

	// Table
	::NewTable("BSC018")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(oField := TBIField():New("NOME",		"C",	120))
	oField:lSensitive(.f.)
	::addField(TBIField():New("TEXTO",		"M"))
	::addField(oField := TBIField():New("LOCAL",		"C",	 20))
	oField:lSensitive(.f.)
	::addField(TBIField():New("DATAINI",	"D"))
	::addField(TBIField():New("DATAFIN",	"D"))
	::addField(TBIField():New("CE_MAOOBRA",	"N", 19, 2))
	::addField(TBIField():New("CE_MATERIA",	"N", 19, 2))
	::addField(TBIField():New("CE_TERCEIR",	"N", 19, 2))
	::addField(TBIField():New("CR_MAOOBRA",	"N", 19, 2))
	::addField(TBIField():New("CR_MATERIA",	"N", 19, 2))
	::addField(TBIField():New("CR_TERCEIR",	"N", 19, 2))
	::addField(TBIField():New("HORASEST",	"N"))
	::addField(TBIField():New("HORASREAL",	"N"))
	::addField(TBIField():New("SITID",		"N")) // Situações definidas em ::oXMLSituacao()
	::addField(TBIField():New("COMPLETADO",	"N"))
	::addField(TBIField():New("IMPORTANCI","N")) //A-Vital; B-Importante; C-Interessante
	::addField(TBIField():New("URGENCIA","N")) //0-Urgente; 1-Curto Prazo; 2-Médio Prazo; 3-Longo Prazo (sem prazo)

	// Virtual Fields
	oVirtual := TBIField():New("SITUACAO",	"C", 20)
	oVirtual:bGet({|oTable| oTable:xVirtualField("SITUACAO")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("SITUACAO", xValue)})
	::addField(oVirtual)
	// Indexes
	::addIndex(TBIIndex():New("BSC018I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC018I02",	{"NOME", "CONTEXTID"},	.t.))
	::addIndex(TBIIndex():New("BSC018I03",	{"PARENTID", "ID"},	.t.))
	::addIndex(TBIIndex():New("BSC018I04",	{"URGENCIA", "NOME", "CONTEXTID"},	.f.))

	//Copiar Coluna;
	::faCopyColumn := {{"IMPORTANCIA","IMPORTANCI"}} //Origem destino;
	
return

// Campos virtuais
method xVirtualField(cField, xValue) class TBSC018
	local xRet := xValue
	if(valtype(xValue)=="U")
		if(cField=="SITUACAO")
			xRet := ::oXMLSituacao():oChildByName("SITUACAO", ::nValue("SITID"))
			if(xRet != nil)
				xRet := xRet:oChildByName("NOME"):cGetValue()
			endif
		endif
	endif
return xRet

// Situacao
method oXMLSituacao() class TBSC018
	local oAttrib, oNode, oXMLOutput

	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("SITUACOES",,oAttrib)
	
	// Nao iniciada
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("SITUACAO"))
	oNode:oAddChild(TBIXMLNode():New("ID", 1))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0003))/*//"Não Iniciada"*/

	// Em execucao
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("SITUACAO"))
	oNode:oAddChild(TBIXMLNode():New("ID", 2))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0004))/*//"Em Execução"*/
	
	// Completada
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("SITUACAO"))
	oNode:oAddChild(TBIXMLNode():New("ID", 3))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0005))/*//"Completada"*/

	// Esperando
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("SITUACAO"))
	oNode:oAddChild(TBIXMLNode():New("ID", 4))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0006))/*//"Esperando"*/

	// Adiada
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("SITUACAO"))
	oNode:oAddChild(TBIXMLNode():New("ID", 5))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0007))/*//"Adiada"*/

	//Em execução atrasada
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("SITUACAO"))
	oNode:oAddChild(TBIXMLNode():New("ID", 6))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0021))/*//"Em execução atrasada"*/

	//Em execução adiantada
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("SITUACAO"))
	oNode:oAddChild(TBIXMLNode():New("ID", 7))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0022))/*//"Em execução adiantada"*/
	
return oXMLOutput

// Importancia
method oXMLImportancia() class TBSC018
	local oAttrib, oNode, oXMLOutput

	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("IMPORTANCIAS",,oAttrib)
	
	// Vital
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("IMPORTANCI"))
	oNode:oAddChild(TBIXMLNode():New("ID", 1))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0011))/*////A-Vital*/

	// Importante
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("IMPORTANCI"))
	oNode:oAddChild(TBIXMLNode():New("ID", 2))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0012))/*//"B-Importante"*/
	
	// Interessante
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("IMPORTANCI"))
	oNode:oAddChild(TBIXMLNode():New("ID", 3))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0013))/*//"C-Interessante"*/
return oXMLOutput

// Urgência
method oXMLUrgencia() class TBSC018
	local oAttrib, oNode, oXMLOutput

	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("URGENCIAS",,oAttrib)
	
	// "Urgente"
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("URGENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", 1))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0014))/*//"0-Urgente"*/

	// "Curto Prazo"
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("URGENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", 2))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0015))/*//"1-Curto Prazo"/*/
	
	// "Médio Prazo"
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("URGENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", 3))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0016))/*//"2-Médio Prazo"*/

	// "Longo Prazo (sem prazo)"
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("URGENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", 4))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0017))/*//"3-Longo Prazo (sem prazo)"*/

return oXMLOutput

// Arvore
method oArvore(nParentID) class TBSC018
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
			oAttrib:lSet("NOME", alltrim(::cValue("NOME")))
			oAttrib:lSet("FEEDBACK", ::nValue("FEEDBACK"))
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Encerra filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC018
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
	// Data Inicío
	oAttrib:lSet("TAG001", "DATAINI")
	oAttrib:lSet("CAB001", STR0020)/*//"Inicío"*/
	oAttrib:lSet("CLA001", BSC_DATE)
	// Data Fim
	oAttrib:lSet("TAG002", "DATAFIN")
	oAttrib:lSet("CAB002", STR0008)/*//"Término"*/
	oAttrib:lSet("CLA002", BSC_DATE)
	// Situacao
	oAttrib:lSet("TAG003", "SITUACAO")
	oAttrib:lSet("CAB003", STR0009)/*//"Situação"*/
	oAttrib:lSet("CLA003", BSC_STRING)
	// Data Inicio
	oAttrib:lSet("TAG004", "COMPLETADO")
	oAttrib:lSet("CAB004", STR0010)/*//"Completado"*/
	oAttrib:lSet("CLA004", BSC_PERCENT)
	// Importancia
	oAttrib:lSet("TAG005", "IMPORTANCI")
	oAttrib:lSet("CAB005", STR0018)/*//"Importância"*/
	oAttrib:lSet("CLA005", BSC_STRING)
	// Urgencia
	oAttrib:lSet("TAG006", "URGENCIA")
	oAttrib:lSet("CAB006", STR0019)/*//"Urgência"*/
	oAttrib:lSet("CLA006", BSC_STRING)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(2) // Por ordem de nome
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","TEXTO","CE_MAOOBRA","SITID",;
					"CE_MATERIA","CE_TERCEIR","CR_MAOOBRA","CR_MATERIA","CR_TERCEIR","HORASEST","HORASREAL"})
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1]) == "IMPORTANCI"
				if(empty(::nValue("IMPORTANCI")))
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], ""))
				else
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1],if(::nValue("IMPORTANCI")==1,STR0011,;
															(if(::nValue("IMPORTANCI")==2,STR0012,STR0013)))))
				endif
			elseif(aFields[nInd][1]) == "URGENCIA"
				if(empty(::nValue("URGENCIA")))
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], ""))
				else
					if(strzero(::nValue("URGENCIA")-1,1))=="0"
						oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], STR0014))
					elseif(strzero(::nValue("URGENCIA")-1,1))=="1"
						oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], STR0015))
					elseif(strzero(::nValue("URGENCIA")-1,1))=="2"
						oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], STR0016))
					else //"3"
						oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], STR0017))
					endif
				endif
			else
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			endif
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentID) class TBSC018
	Local aFields, aGrupos
	Local nID, nParentID, nInd  
	Local oTable, oTarCob, oPessoa, oPessoaXGrupo 
	
	Local oXMLNode 		:= TBIXMLNode():New(TAG_ENTITY)
	Local lAdmin 		:= ::oOwner():foSecurity:oLoggedUser():lValue("ADMIN")
	Local nCurrentUser 	:= ::oOwner():foSecurity:oLoggedUser():nValue("ID")
	Local lIsResp 		:= .F.

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)   
	
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2])) 
		
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
	next

	// Combos
	oXMLNode:oAddChild(::oXMLSituacao())
	oXMLNode:oAddChild(::oXMLImportancia())
	oXMLNode:oAddChild(::oXMLUrgencia())
	
	oTable := self 
	
	if(nID==0)
		oTable := ::oOwner():oGetTable("INICIATIVA")
		oTable:lSeek(1, {nParentID})
	endif

	// Acrescenta children
	oXMLNode:oAddChild(::oOwner():oGetTable("TARCOB"):oToXMLList(nID))
	oXMLNode:oAddChild(::oOwner():oGetTable("RETORNO"):oToXMLList(nID))
	oXMLNode:oAddChild(::oOwner():oGetTable("TARDOC"):oToXMLList(nID))
	oXMLNode:oAddChild(::oOwner():oContext(self, nParentID))
	oXMLNode:oAddChild(TBIXMLNode():New("ADMINISTRADOR",if(lAdmin,"T","F")))
	
	oTable := self
	
	if(nID==0)
		oXMLNode:oAddChild(TBIXMLNode():New("RESPONSAVEL","T"))
	else
		oPessoa := ::oOwner():oGetTable("PESSOA")
		oPessoa:lSeek(4, {nCurrentUser})
		oTarCob := ::oOwner():oGetTable("TARCOB")
		
		if(oTarCob:lSeek(4, {nID, oPessoa:nValue("ID"), "P"}) .or. oTarCob:lSeek(4, {nID, oPessoa:nValue("ID"), " "}))
			oXMLNode:oAddChild(TBIXMLNode():New("RESPONSAVEL","T"))
		else
			oXMLNode:oAddChild(TBIXMLNode():New("RESPONSAVEL","F"))
		endif
	endif
    
	oTable := ::oOwner():oGetTable("INICIATIVA")
	oTable:lSeek(1, {::nValue("PARENTID")})

	/*Identifica se o usuário corrente é o RESPONSAVEL pela iniciativa.*/                                                                                                     
    If (oTable:cValue("TIPOPESSOA") == "G")   
    	/*Localiza a PESSOA correspondente ao usuário corrente.*/
    	oPessoa := ::oOwner():oGetTable("PESSOA")
    	oPessoa:lSeek(4, {nCurrentUser})
    	/*Recupera os grupos que a PESSOA localizada pertence.*/	                  
    	oPessoaXGrupo := ::oOwner():oGetTable("GRPXPESSOA")       
    	aGrupos := oPessoaXGrupo:aGroupsByPerson(oPessoa:nValue("ID"))    
       	lIsResp := aScan(aGrupos, oTable:nValue("RESPID")) > 0
    Else
   	 	/*Localiza o USUARIO corrente na tebala de PESSOAS e compara com o ID do RESPONSAVEL*/
   	 	oPessoa := ::oOwner():oGetTable("PESSOA")
   	 	oPessoa:lSeek(4, {nCurrentUser})   	 	
  
  		/*Realiza o tratamento para a condição de um usuário estar relacionado com mais de uma PESSOA.*/
   	   	While (!oPessoa:lEof() .And. oPessoa:nValue("USERID") == nCurrentUser) 
   	 		If(oPessoa:nValue("ID") == oTable:nValue("RESPID"))
   	 			lIsResp := .T.
   	 		EndIf
   	 	
   	 		oPessoa:_Next()   	 	
   	 	EndDo  	
      EndIF  	

	oXMLNode:oAddChild(TBIXMLNode():New("ISRESP", Iif(lIsResp, "T", "F"))) 

return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC018
	local aFields, nInd, oTable, aTarCob, nStatus := BSC_ST_OK
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID", "SITUACAO"})

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
		// Extrai e grava lista de pessoas em cobrança (TARCOBS)
		oTable := ::oOwner():oGetTable("TARCOB")
	
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_TARCOBS"), "_TARCOB"))!="U")
			if(valtype(&("oXMLInput:"+cPath+":_TARCOBS:_TARCOB"))=="A")
				for nInd := 1 to len(&("oXMLInput:"+cPath+":_TARCOBS:_TARCOB"))
					aTarCob := &("oXMLInput:"+cPath+":_TARCOBS:_TARCOB["+cBIStr(nInd)+"]")
					oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
						{"TIPOPESSOA", aTarCob:_TIPOPESSOA:TEXT},;
						{"CONTEXTID", ::nValue("CONTEXTID")}, {"PESSOAID", nBIVal(aTarCob:_ID:TEXT)} })
				next	
			elseif(valtype(&("oXMLInput:"+cPath+":_TARCOBS:_TARCOB"))=="O")
				aTarCob := &("oXMLInput:"+cPath+":_TARCOBS:_TARCOB")
				oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
					{"TIPOPESSOA", aTarCob:_TIPOPESSOA:TEXT},;
					{"CONTEXTID", ::nValue("CONTEXTID")}, {"PESSOAID", nBIVal(aTarCob:_ID:TEXT)} })
			endif
		endif	
	endif	
return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC018
	local nStatus := BSC_ST_OK,	nID, oTable, aTarCob, nInd
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"SITUACAO"})

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
		else
			// Apaga lista de cobranca anterior
			oTable := ::oOwner():oGetTable("TARCOB")
			oTable:cSQLFilter("PARENTID = "+cBIStr(::nValue("ID"))) // Filtra pelo pai
			oTable:lFiltered(.t.)
			oTable:_First()
			while(!oTable:lEof())
				oTable:lDelete()
				oTable:_Next()
			enddo
			oTable:cSQLFilter("") // Encerra filtro	
   		
			// Extrai e grava lista de pessoas em cobrança (TARCOBS)
			if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_TARCOBS"), "_TARCOB"))!="U")
				if(valtype(&("oXMLInput:"+cPath+":_TARCOBS:_TARCOB"))=="A")
					for nInd := 1 to len(&("oXMLInput:"+cPath+":_TARCOBS:_TARCOB"))
						aTarCob := &("oXMLInput:"+cPath+":_TARCOBS:_TARCOB["+cBIStr(nInd)+"]")
						oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
							{"TIPOPESSOA", aTarCob:_TIPOPESSOA:TEXT},;
							{"CONTEXTID", ::nValue("CONTEXTID")}, {"PESSOAID", nBIVal(aTarCob:_ID:TEXT)} })
					next	
				elseif(valtype(&("oXMLInput:"+cPath+":_TARCOBS:_TARCOB"))=="O")
					aTarCob := &("oXMLInput:"+cPath+":_TARCOBS:_TARCOB")
					oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
						{"TIPOPESSOA", aTarCob:_TIPOPESSOA:TEXT},;
						{"CONTEXTID", ::nValue("CONTEXTID")}, {"PESSOAID", nBIVal(aTarCob:_ID:TEXT)} })
				endif
			endif	
		endif	
	endif
return nStatus

// Excluir entidade do server
method nDelFromXML(nID) class TBSC018
	local nStatus := BSC_ST_OK, oTableChild
	
	::oOwner():oOltpController():lBeginTransaction()

	// Procura por children (Documentos)
	oTableChild:= ::oOwner():oGetTable("TARDOC")
	oTableChild:SetOrder(3) // Por ordem de ParentId
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo paI
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("TARDOC"):nDelFromXML(oTableChild:nValue("ID"))
		oTableChild:_Next()
	enddo
	oTableChild:cSQLFilter("") // Limpa o filtro

	// Procura por children (Retornos)
	oTableChild:= ::oOwner():oGetTable("RETORNO")
	oTableChild:SetOrder(3) // Por ordem de ParentId
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo paI
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("RETORNO"):nDelFromXML(oTableChild:nValue("ID"))
		oTableChild:_Next()
	enddo
	oTableChild:cSQLFilter("") // Limpa o filtro

	// Procura por children (Tarefas)
	oTableChild:= ::oOwner():oGetTable("TARCOB")
	oTableChild:SetOrder(3) // Por ordem de ParentId
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo paI
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("TARCOB"):nDelFromXML(oTableChild:nValue("ID"))
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
method nDuplicate(nParentID, nNewParentID, nNewContextID) class TBSC018
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
			::restPos()
			nOldId := ::nValue("ID")
			nStatus := ::oOwner():oGetTable("TARCOB"):nDuplicate(nOldId, nID, nNewContextID)
			if(nStatus == BSC_ST_OK)
				nStatus := ::oOwner():oGetTable("TARDOC"):nDuplicate(nOldId, nID, nNewContextID)
			endif
			if(nStatus == BSC_ST_OK)
				nStatus := ::oOwner():oGetTable("RETORNO"):nDuplicate(nOldId, nID, nNewContextID)
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

method aCompletado(cNomeUsuario, dDataDe, dDataAte) class TBSC018
	local aAtingido := {}, aPessoaID := {}, aTarefasID := {}, aUsuarios := {}
	local oTarCob, oPessoa, oUsuarios, oTarefas
	local ni:=1, nt, nMedia := 0, nTarefas := 0

	oUsuarios := ::oOwner():oGetTable("USUARIO")
	oUsuarios:cSQLFilter("USERPROT = 'T' AND NOME = '"+cNomeUsuario+"'")
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

	oTarCob := ::oOwner():oGetTable("TARCOB")
	oTarCob:SetOrder(1) // Por ordem de id
	oTarCob:lFiltered(.t.)

	for ni:=1 to len(aPessoaID)
		oTarCob:cSQLFilter("PESSOAID = "+cBiStr(aPessoaID[ni])) // Filtra pelo responsavel
		oTarCob:_First()
		while(oTarCob:nValue("PESSOAID") == aPessoaID[ni] .and. !eof())
			if(ascan(aTarefasID, oTarCob:nValue("PARENTID")) == 0)
				aadd(aTarefasID, oTarCob:nValue("PARENTID"))
			endif
			oTarCob:_next()
		enddo
	next
	oTarCob:cSQLFilter("") // Zera filtro

	oTarefas := ::oOwner():oGetTable("TAREFA")
	oTarefas:cSQLFilter("DATAINI >= '"+dtos(dDataDe)+"' AND DATAFIN >='"+dtos(dDataDe)+"' AND DATAINI <= '"+dtos(dDataAte)+"' AND DATAFIN <='"+dtos(dDataAte)+"'" )
	oTarefas:lFiltered(.t.)
	for nt:=1 to len(aTarefasID)
		if(oTarefas:lSeek(1, {aTarefasID[nt]}) )
			nMedia += oTarefas:nValue("COMPLETADO")
			nTarefas ++
		endif
	next
	oTarefas:cSQLFilter("") // Zera filtro
	nMedia := if(nTarefas>0,nMedia / nTarefas,0)
	aadd(aAtingido,nMedia)

return aAtingido

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ntfDelayTask
Notific aos responsáveis a existência de tarefas vencidas ou a vencer em até sete dias

@protected
@param		aParam Array opcional informando path do BSC e mensagens "a vencer" e "vencidas"
@author		3510 - Gilmar P. Santos
@version	P10 R1.3
@since		08/06/2009
@return		.T.
/*/
//--------------------------------------------------------------------------------------
function ntfDelayTask( aParam )
	local nStatus		:= BSC_ST_OK
	local aTo			:= {}
	local cSituacao		:= ""
	local cImportancia	:= ""
	local cUrgencia		:= ""
	local cServer		:= ""
	local cPorta		:= ""
	local cConta		:= ""
	local cAutUsuario	:= ""
	local cAutSenha		:= ""
	local cTo 			:= ""
	local cAssunto		:= ""
	local cCorpo		:= ""
	local cEmail		:= ""
	local oConexao		:= nil
	local oPessoas		:= nil
	local oGrupo		:= nil
	local oTarefa		:= nil
	local oTarCob		:= nil
	local dHoje			:= date()
	local nAux			:= 0
	local cMsgAVenc		:= if( len( aParam ) > 1 .AND. !Empty( aParam[2] ), aParam[2], STR0023 ) //AVISO DE TAREFAS A VENCER EM ATÉ 7 DIAS
	local cMsgVencida	:= if( len( aParam ) > 2 .AND. !Empty( aParam[3] ), aParam[3], STR0024 ) //AVISO DE TAREFAS VENCIDAS
	local cBSCPath		:= if( len( aParam ) > 0 .AND. !Empty( aParam[1] ), aParam[1], "\" )
	public oBSCCore

	oBSCCore := TBSCCore():New( cBSCPath )
	if( oBSCCore:nDBOpen() < 0 )
		oBSCCore:Log( cBIMsgTopError( nTopError ), BSC_LOG_SCRFILE )
		oBSCCore:Log( "  " )
		return
	endif

	ErrorBlock( {|oE| __BSCError(oE)} )

	set exclusive off
	set talk off
	set scoreboard off
	set date brit
	set epoch to 1960
	set century on
	set cursor on
	set deleted on

	oConexao	:= oBSCCore:oGetTable("SMTPCONF")
	oPessoas	:= oBSCCore:oGetTable("PESSOA")
	oGrupo		:= oBSCCore:oGetTable("GRPXPESSOA")
	oTarefa		:= oBSCCore:oGetTable("TAREFA")
	oTarCob		:= oBSCCore:oGetTable("TARCOB")

	oTarefa:cSQLFilter( "DATAFIN <= '" + cBiStr( dTos( dHoje + 7 ) ) + "' AND SITID <> 3" ) // Filtra as vencidas e a vencer em 7 dias
	oTarefa:lFiltered( .T. )
	oTarefa:_First()
	if( !oTarefa:lEof() )
		//posiciona na configuração de email
		oConexao:cSQLFilter( "ID = " + cBIStr( 1 ) ) // Filtra o ID 1 onde tem a configuracao SMTP
		oConexao:lFiltered( .T. )
		oConexao:_First()
		if( !oConexao:lEof() )
			cServer		:= alltrim( oConexao:cValue( "SERVIDOR" ) )
			cPorta		:= alltrim( oConexao:cValue( "PORTA" ) )
			cConta		:= alltrim( oConexao:cValue( "NOME" ) )
			cAutUsuario	:= alltrim( oConexao:cValue( "USUARIO" ) )
			cAutSenha	:= alltrim( oConexao:cValue( "SENHA" ) )
		endif

		while( !oTarefa:lEof() .and. !oConexao:lEof() ) //posiciona cfg. da organização
			oTarCob:cSQLFilter( "PARENTID = " + oTarefa:cValue( "ID" ) )
			oTarCob:lFiltered( .T. )
			oTarCob:_First()

			cTo := ""
			while( !oTarCob:lEof() )
				// inclusao do email da Pessoa responsavel ou do Grupo de pessoas responsaveis
				if( oTarCob:cValue( "TIPOPESSOA" ) == "G" )
					aTo := oGrupo:aPersonsByGroup( oTarCob:nValue( "PESSOAID" ) )
					for nAux := 1 to len( aTo )
						if( oPessoas:lSeek( 1, {aTo[nAux]} ) )
							cEmail := Alltrim( oPessoas:cValue( "EMAIL" ) )

							if ( !empty( cEmail ) )
								cTo += if( empty( cTo ), "", "," ) + cEmail
							endif
						endif
					next
				else
					if( oPessoas:lSeek( 1, {oTarCob:nValue( "PESSOAID" )} ) )
						cEmail := Alltrim( oPessoas:cValue( "EMAIL" ) )

						if ( !empty( cEmail ) )
							cTo := cEmail
						endif
					endif
				endif

				oTarCob:_Next()
			enddo

			if !Empty( cTo )
				if( oTarefa:dValue( "DATAFIN" ) > dHoje )
					cAssunto := cMsgAVenc
				else
					cAssunto := cMsgVencida
				endif

				nAux := oTarefa:nValue( "SITID" )
				do case              
					case nAux = 1
						cSituacao := STR0003 //Nao iniciada
					case nAux = 2
						cSituacao := STR0004 //Em execucao
					case nAux = 3
						cSituacao := STR0005 //Completada
					case nAux = 4
						cSituacao := STR0006 //Esperando
					case nAux = 5
						cSituacao := STR0007 //Adiada
					case nAux = 6
						cSituacao := STR0021 //Em execução atrasada
					case nAux = 7
						cSituacao := STR0022 //Em execução adiantada
					otherwise
						cSituacao := ""
				endcase

				nAux := oTarefa:nValue( "URGENCIA" )
				do case              
					case nAux = 1
						cUrgencia := STR0014 //0-Urgente
					case nAux = 2
						cUrgencia := STR0015 //1-Curto Prazo
					case nAux = 3
						cUrgencia := STR0016 //2-Médio Prazo
					case nAux = 4
						cUrgencia := STR0017 //3-Longo Prazo (sem prazo)
					otherwise
						cUrgencia := ""
				endcase

				nAux := oTarefa:nValue( "IMPORTANCI" )
				do case              
					case nAux = 1
						cImportancia := STR0011 //A-Vital
					case nAux = 2
						cImportancia := STR0012 //B-Importante
					case nAux = 3
						cImportancia := STR0013 //C-Interessante
					otherwise
						cImportancia := ""
				endcase

				cCorpo		:= TEXT_ENTITY + ": " + alltrim( oTarefa:cValue( "NOME" ) ) + "<br>"
				cCorpo		+= "<br>"
				cCorpo		+= alltrim( oTarefa:cValue( "TEXTO" ) ) + "<br>"
				cCorpo		+= "<br>"
				cCorpo		+= STR0020 + ": " + oTarefa:cValue( "DATAINI" ) + "<br>"
				cCorpo		+= STR0008 + ": " + oTarefa:cValue( "DATAFIN" ) + "<br>"
				cCorpo		+= "<br>"
				cCorpo		+= STR0019 + ": " + cUrgencia + "<br>"
				cCorpo		+= STR0018 + ": " + cImportancia + "<br>"
				cCorpo		+= "<br>"
				cCorpo		+= STR0009 + ": " + cSituacao
				oConexao:SendMail( cServer, cPorta, cConta, cAutUsuario, cAutSenha, cTo, cAssunto, cCorpo, "" )
			endif

			oTarefa:_Next()
		enddo
	else
		nStatus := 	BSC_ST_BADID
	endif

return nStatus

function _BSC018_Tar()
return