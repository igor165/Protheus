// ######################################################################################
// Projeto: BSC
// Modulo : Reunioes
// Fonte  : BSC060_Reu.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// 05.08.04 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC060_Reu.ch"

/*--------------------------------------------------------------------------------------
@class TBSC060
@entity Reuniao
Reuniao que pode englobar diversos itens de uma estrategia, convocando diversas pessoas.
Possui retornos que podem ser dados antes ou após a realização da mesma.
@table BSC060
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "REUNIAO"
#define TAG_GROUP  "REUNIOES"
#define TEXT_ENTITY STR0001/*//"Reunião"*/
#define TEXT_GROUP  STR0002/*//"Reuniões"*/

class TBSC060 from TBITable
	method New() constructor
	method NewBSC060()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)

	// registro atual
	method oToXMLNode(nParentID)
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	method nExecute(nID, cExecCMD)
	method nDuplicate(nParentID, nNewParentID, nNewContextID)
endclass

method New() class TBSC060
	::NewBSC060()
return

method NewBSC060() class TBSC060
	local oField
	// Table
	::NewTable("BSC060")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(oField := TBIField():New("NOME",	"C",	120)) //Assunto
	oField:lSensitive(.f.)
	::addField(TBIField():New("DETALHES",	"C",	255))
	::addField(TBIField():New("DATAREU",	"D"))
	::addField(TBIField():New("HORAINI",	"C", 	8))
	::addField(TBIField():New("HORAFIM",	"C", 	8))
	::addField(TBIField():New("LOCAL",		"C",	80))
	::addField(TBIField():New("RESPID",		"N"))	// ID de pessoa responsavel, quem marcou a reuniao
	::addField(TBIField():New("TIPOPESSOA",	"C",	1)) //G = Grupo, P = Individual

	// Indexes
	::addIndex(TBIIndex():New("BSC060I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC060I02",	{"NOME", "CONTEXTID"}))
	::addIndex(TBIIndex():New("BSC060I03",	{"PARENTID", "ID"}))
	::addIndex(TBIIndex():New("BSC060I04",	{"DATAREU"}))
	::addIndex(TBIIndex():New("BSC060I05",	{"PARENTID"}))
return

// Carrega a Arvore.
method oArvore(nParentID) class TBSC060
	local oXMLArvore, oNode
	
 	::SetOrder(4) // Ordem de data
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First() // Não filtra organizações
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
	::cSQLFilter("") // Retira filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC060
	local oNode, oAttrib, oXMLNode, nInd, cNome
	local cPath := ::oOwner():cBscPath(), aPath
	aPath := aBIToken(cPath, "\")
	cPath := ""
	for nInd := 1 to len(aPath)
		if(!empty(aPath[nInd]))
			cPath += "\\"+alltrim(aPath[nInd])
		endif
	next
	cPath += "\\"
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Assunto
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", STR0003) // "Assunto"
	oAttrib:lSet("CLA000", BSC_STRING)
	// Data
	oAttrib:lSet("TAG001", "DATAREU")
	oAttrib:lSet("CAB001", STR0004) // "Data"
	oAttrib:lSet("CLA001", BSC_DATE)
	// Hora
	oAttrib:lSet("TAG002", "HORAINI")
	oAttrib:lSet("CAB002", STR0005) // "Início"
	oAttrib:lSet("CLA002", BSC_STRING)
	// Hora
	oAttrib:lSet("TAG003", "HORAFIM")
	oAttrib:lSet("CAB003", STR0007) // "Término"
	oAttrib:lSet("CLA003", BSC_STRING)
	// Local
	oAttrib:lSet("TAG004", "LOCAL")
	oAttrib:lSet("CAB004", STR0006) // "Local"
	oAttrib:lSet("CLA004", BSC_STRING)

	// Gerar o nó principal.
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(4) // Por ordem de data
	if(!empty(nParentID))
		::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
		::lFiltered(.t.)
	endif
	::_First()
	while(!::lEof())
		// Nao lista o ID 0.
		if(::nValue("ID")==0)
			::_Next()
			loop
		endif
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DETALHES","RESPID"})
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1]=="NOME")
				cNome := alltrim(aFields[nInd][2])
			endif
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		//Campos Virtuais.
		oNode:oAddChild(TBIXMLNode():New("CPATH", cPath))
		oNode:oAddChild(TBIXMLNode():New("ORGREU", cNome+"-"+alltrim(::oOwner():oAncestor("ORGANIZACAO", self):cValue("NOME"))))
		::_Next()
	end
	::cSQLFilter("") // Limpar o filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentID) class TBSC060
	local nID, aFields, nInd, cTipoPessoa, nRespID
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

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

	// Acrescenta combos, listas
	//oXMLNode:oAddChild(::oOwner():oGetTable("PESSOA"):oToXMLList())
	// Acrescenta children - Convocados
	oXMLNode:oAddChild(::oOwner():oGetTable("REUCON"):oToXMLList(nID))
	// Acrescenta children - Documentos (Ata e outros doctos)
	oXMLNode:oAddChild(::oOwner():oGetTable("REUDOC"):oToXMLList(nID))
	// Acrescenta children - Retornos
	oXMLNode:oAddChild(::oOwner():oGetTable("REURET"):oToXMLList(nID))
	// Acrescenta children - Pauta
	oXMLNode:oAddChild(::oOwner():oGetTable("REUPAU"):oToXMLList(nID))

return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC060
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
	else
		// Extrai e grava lista de pessoas convocadas
		oTable := ::oOwner():oGetTable("REUCON")
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_REUCONS"), "_REUCON"))!="U")
			if(valtype(&("oXMLInput:"+cPath+":_REUCONS:_REUCON"))=="A")
				for nInd := 1 to len(&("oXMLInput:"+cPath+":_REUCONS:_REUCON"))
					aREUCON := &("oXMLInput:"+cPath+":_REUCONS:_REUCON["+cBIStr(nInd)+"]")
					oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
						{"TIPOPESSOA", aREUCON:_TIPOPESSOA:TEXT},;
						{"CONTEXTID", ::nValue("CONTEXTID")}, {"PESSOAID", nBIVal(aREUCON:_ID:TEXT)} })
				next	
			elseif(valtype(&("oXMLInput:"+cPath+":_REUCONS:_REUCON"))=="O")
				aREUCON := &("oXMLInput:"+cPath+":_REUCONS:_REUCON")
				oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
					{"TIPOPESSOA", aREUCON:_TIPOPESSOA:TEXT},;
					{"CONTEXTID", ::nValue("CONTEXTID")}, {"PESSOAID", nBIVal(aREUCON:_ID:TEXT)} })
			endif
		endif	
	endif
return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC060
	local nStatus := BSC_ST_OK,	nID, nInd
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY)

	// Extração de valores XML.
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
	next

	// Verificar condições de gravação (append ou update).
	if(!::lSeek(1, {nID}))
		nStatus := BSC_ST_BADID
	else
		if(!::lUpdate(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE // Status único.
			else
				nStatus := BSC_ST_INUSE // Status caso já exista.
			endif
		else
			// Apaga lista de convocados anteriormente
			oTable := ::oOwner():oGetTable("REUCON")
			oTable:cSQLFilter("PARENTID = "+cBIStr(::nValue("ID"))) // Filtra pelo pai
			oTable:lFiltered(.t.)
			oTable:_First()
			while(!oTable:lEof())
				oTable:lDelete()
				oTable:_Next()
			enddo
			oTable:cSQLFilter("") // Encerra filtro	
   		
			// Extrai e grava lista de pessoas convocadas (REUCONS)
			if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_REUCONS"), "_REUCON"))!="U")
				if(valtype(&("oXMLInput:"+cPath+":_REUCONS:_REUCON"))=="A")
					for nInd := 1 to len(&("oXMLInput:"+cPath+":_REUCONS:_REUCON"))
						aREUCON := &("oXMLInput:"+cPath+":_REUCONS:_REUCON["+cBIStr(nInd)+"]")
						oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
							{"TIPOPESSOA", aREUCON:_TIPOPESSOA:TEXT},;
							{"CONTEXTID", ::nValue("CONTEXTID")}, {"PESSOAID", nBIVal(aREUCON:_ID:TEXT)} })
					next	
				elseif(valtype(&("oXMLInput:"+cPath+":_REUCONS:_REUCON"))=="O")
					aREUCON := &("oXMLInput:"+cPath+":_REUCONS:_REUCON")
					oTable:lAppend({ {"ID", oTable:nMakeID()}, {"PARENTID", ::nValue("ID")}, ;
						{"TIPOPESSOA", aREUCON:_TIPOPESSOA:TEXT},;
						{"CONTEXTID", ::nValue("CONTEXTID")}, {"PESSOAID", nBIVal(aREUCON:_ID:TEXT)} })
				endif
			endif	
		endif
	endif
return nStatus

// Excluir entidade do server
method nDelFromXML(nID) class TBSC060
	local nStatus := BSC_ST_OK
	
	::oOwner():oOltpController():lBeginTransaction()

	// Procura por children (Pessoas Convocadas)
	oTableChild := ::oOwner():oGetTable("REUCON")
	oTableChild:SetOrder(3) // Por ordem de ParentId
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo paI
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("REUCON"):nDelFromXML(oTableChild:nValue("ID"))
		oTableChild:_Next()
	enddo
	oTableChild:cSQLFilter("") // Limpa o filtro

	// Procura por children (Documentos)
	oTableChild := ::oOwner():oGetTable("REUDOC")
	oTableChild:SetOrder(3) // Por ordem de ParentId
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo paI
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("REUDOC"):nDelFromXML(oTableChild:nValue("ID"))
		oTableChild:_Next()
	enddo
	oTableChild:cSQLFilter("") // Limpa o filtro

	// Procura por children (Retorno)
	oTableChild := ::oOwner():oGetTable("REURET")
	oTableChild:SetOrder(3) // Por ordem de ParentId
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo paI
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("REURET"):nDelFromXML(oTableChild:nValue("ID"))
		oTableChild:_Next()
	enddo
	oTableChild:cSQLFilter("") // Limpa o filtro

	// Procura por children (Pauta)
	oTableChild := ::oOwner():oGetTable("REUPAU")
	oTableChild:SetOrder(3) // Por ordem de ParentId
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo paI
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("REUPAU"):nDelFromXML(oTableChild:nValue("ID"))
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
method nDuplicate(nParentID, nNewParentID, nNewContextID) class TBSC060
	local nStatus := BSC_ST_OK, aFields, nID
	
	::oOwner():oOltpController():lBeginTransaction()

	::SetOrder(1) // Por ordem de id
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	
	while !::lEof() .and. nStatus == BSC_ST_OK .and. ::nValue("PARENTID") == nParentID
		// Copia temporario
		aFields := ::xRecord(RF_ARRAY, {"ID", "PARENTID", "CONTEXTID"})
		aAdd( aFields, {"ID",  nID := ::nMakeID()} )
		aAdd( aFields, {"PARENTID", nNewParentID} )
		aAdd( aFields, {"CONTEXTID", nNewContextID} )

		// Grava
		::SavePos()
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
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

// Execute
method nExecute(nID, cExecCMD) class TBSC060
	local nStatus := BSC_ST_OK, cNome, oTable, i
	local cServer, cPorta, cConta, cAutUsuario, cAutSenha, cTo := "", cAssunto, cCorpo, cAnexos, cPauta:=""
	local oConexao := ::oOwner():oGetTable("SMTPCONF")
	local oPessoas := ::oOwner():oGetTable("PESSOA")
	local oReuConv := ::oOwner():oGetTable("REUCON")
	local oPauta   := ::oOwner():oGetTable("REUPAU")
	local oGrupo   := ::oOwner():oGetTable("GRPXPESSOA")

	if(::lSeek(1, {nID})) // Posiciona no ID da Reuniao informada
		//posiciona na configuração de email
		oConexao:cSQLFilter("ID = "+cBIStr(1)) // Filtra o ID 1 onde tem a configuracao SMTP
		oConexao:lFiltered(.t.)
		oConexao:_First()
		if(!::lEof() .and. !oConexao:lEof()) //posiciona cfg. da organização
			cServer		:= alltrim(oConexao:cValue("SERVIDOR"))
			cPorta		:= alltrim(oConexao:cValue("PORTA"))
			cConta		:= alltrim(oConexao:cValue("NOME"))
			cAutUsuario	:= alltrim(oConexao:cValue("USUARIO"))
			cAutSenha	:= alltrim(oConexao:cValue("SENHA"))
			// inclusao do email da Pessoa responsavel ou do Grupo de pessoas responsaveis
			if(::cValue("TIPOPESSOA") == "G") //grupo de pessoas
				aTo := oGrupo:aPersonsByGroup(::nValue("RESPID"))
				cTo := ""
				for i := 1 to len(aTo)
					if(oPessoas:lSeek(1, {aTo[i]}))
						cTo	+= if(empty(cTo),"",",")+alltrim(oPessoas:cValue("EMAIL"))
					endif
				next
			else
				if(oPessoas:lSeek(1, {::nValue("RESPID")}))
					cTo		:= alltrim(oPessoas:cValue("EMAIL"))
				endif
			endif

			// inclusao das Pessoas convocadas e/ou dos Grupos de pessoas convocadas
			oReuConv:lFiltered(.t.)
			oReuConv:cSQLFilter("PARENTID = "+cBIStr(::nValue("ID"))) // Filtra pelo pai
			oReuConv:_First()
			while(!oReuConv:lEof())
				if(oReuConv:cValue("TIPOPESSOA") == "G") //grupo de pessoas
					aTo := oGrupo:aPersonsByGroup(oReuConv:nValue("PESSOAID"))
					for i := 1 to len(aTo)
						if(oPessoas:lSeek(1, {aTo[i]}))
							cTo	+= if(empty(cTo),"",",")+alltrim(oPessoas:cValue("EMAIL"))
						endif
					next
				elseif(oPessoas:lSeek(1, {oReuConv:nValue("PESSOAID")}))
					cTo	+= if(empty(cTo),"",",")+alltrim(oPessoas:cValue("EMAIL"))
				endif
				oReuConv:_Next()
			enddo
			oReuConv:cSQLFilter("") // Encerra filtro	

			oPauta:cSQLFilter("PARENTID = "+cBIStr(::nValue("ID"))) // Filtra pelo pai
			oPauta:lFiltered(.t.)
			oPauta:_First()
			if(!oPauta:lEof())
				cPauta := '<b><br>' + STR0010 + '<br></b>' // "Pauta da Reunião"				
			end
			while(!oPauta:lEof())
				cNome := alltrim(oPauta:cValue("NOME"))
				// busca o elemento da pauta para trazer sua descrição
				if(!empty(cNome))
					oTable := ::oOwner():oGetTable(cNome)
					if(oTable:lSeek(1,{oPauta:nValue("ELEMID")}))
						cNome += ": "+ oTable:cValue("NOME")
					endif
				endif

				cPauta += cNome + '<br>'
				cPauta += alltrim(oPauta:cValue("DETALHES")) + '<br><br> '
				oPauta:_Next()
			enddo
			oPauta:cSQLFilter("") // Encerra filtro	

			cAssunto	:= TEXT_ENTITY+": " + alltrim(::cValue("NOME"))
			cCorpo		:= STR0004 +": "+ alltrim(::cValue("DATAREU"))+ '<br>'
			cCorpo		+= STR0005 +": "+ alltrim(::cValue("HORAINI"))+" "+STR0007+":"+ alltrim(::cValue("HORAFIM"))+ '<br>'
			cCorpo		+= STR0006 +": "+ alltrim(::cValue("LOCAL")) + '<br>'
			cCorpo		+= STR0009 +": "+alltrim(::cValue("DETALHES")) + '<br>'
			cCorpo		+= cPauta
			cAnexos		:= ""//::cValue("ANEXOS")
			oConexao:SendMail(cServer, cPorta, cConta, cAutUsuario, cAutSenha, cTo, cAssunto, cCorpo, cAnexos)
		endif
		oConexao:cSQLFilter("") // Retira filtro
	else
		nStatus := 	BSC_ST_BADID
	endif
return nStatus

/****************************************************************************/
//funçao para notificar sobre a reunião, tem a mesma função que o metodo    */
//nExecute porém o start é pelo Job do TBSC082 que descende de TBIScheduler */
/****************************************************************************/
function notifyMeeting(aParam)
	local nStatus := BSC_ST_OK, cNome, oTable, aTo := {}, i
	local cServer, cPorta, cConta, cAutUsuario, cAutSenha, cTo := "", cAssunto, cCorpo, cAnexos, cPauta:=""
	local oOrganizacao, oEstrategia, oPerspectiva, oReuniao, oConexao, oPessoas, oReuConv, oPauta, oGrupo
	local nId := aParam[1]
	local cPath := aParam[2]
	public oBSCCore, cBSCErrorMsg := ""

	oBSCCore := TBSCCore():New(cPath) //environment
	if(oBSCCore:nDBOpen() < 0)
		oBSCCore:Log(cBIMsgTopError(nTopError), BSC_LOG_SCRFILE)
		oBSCCore:Log("  ")
		return
	endif

	oOrganizacao := oBSCCore:oGetTable("ORGANIZACAO")
	oEstrategia := oBSCCore:oGetTable("ESTRATEGIA")
	oPerspectiva := oBSCCore:oGetTable("PERSPECTIVA")
	oConexao := oBSCCore:oGetTable("SMTPCONF")
	oPessoas := oBSCCore:oGetTable("PESSOA")
	oReuniao := oBSCCore:oGetTable("REUNIAO")
	oReuConv := oBSCCore:oGetTable("REUCON")
	oPauta   := oBSCCore:oGetTable("REUPAU")
	oGrupo   := oBSCCore:oGetTable("GRPXPESSOA")

	if(oReuniao:lSeek(1, {nID})) // Posiciona no ID da Reuniao informada
		//posiciona na configuração de email
		oConexao:cSQLFilter("ID = "+cBIStr(1)) // Filtra o ID 1 onde tem a configuracao SMTP
		oConexao:lFiltered(.t.)
		oConexao:_First()
		if(!oReuniao:lEof() .and. !oConexao:lEof()) //posiciona cfg. da organização
			cServer		:= alltrim(oConexao:cValue("SERVIDOR"))
			cPorta		:= alltrim(oConexao:cValue("PORTA"))
			cConta		:= alltrim(oConexao:cValue("NOME"))
			cAutUsuario	:= alltrim(oConexao:cValue("USUARIO"))
			cAutSenha	:= alltrim(oConexao:cValue("SENHA"))

			// inclusao do email da Pessoa responsavel ou do Grupo de pessoas responsaveis
			if(oReuniao:cValue("TIPOPESSOA") == "G") //grupo de pessoas
				aTo := oGrupo:aPersonsByGroup(oReuniao:nValue("RESPID"))
				cTo := ""
				for i := 1 to len(aTo)
					if(oPessoas:lSeek(1, {aTo[i]}))
						cTo += if(empty(cTo),"",",")+alltrim(oPessoas:cValue("EMAIL"))
					endif
				next
			else
				if(oPessoas:lSeek(1, {oReuniao:nValue("RESPID")}))
					cTo		:= alltrim(oPessoas:cValue("EMAIL"))
				endif
			endif

			// inclusao das Pessoas convocadas e/ou dos Grupos de pessoas convocadas
			oReuConv:lFiltered(.t.)
			oReuConv:cSQLFilter("PARENTID = "+cBIStr(oReuniao:nValue("ID"))) // Filtra pelo pai
			oReuConv:_First()
			while(!oReuConv:lEof())
				if(oReuConv:cValue("TIPOPESSOA") == "G") //grupo de pessoas
					aTo := oGrupo:aPersonsByGroup(oReuConv:nValue("PESSOAID"))
					for i := 1 to len(aTo)
						if(oPessoas:lSeek(1, {aTo[i]}))
							cTo	+= if(empty(cTo),"",",")+alltrim(oPessoas:cValue("EMAIL"))
						endif
					next
				elseif(oPessoas:lSeek(1, {oReuConv:nValue("PESSOAID")}))
					cTo	+= if(empty(cTo),"",",")+alltrim(oPessoas:cValue("EMAIL"))
				endif
				oReuConv:_Next()
			enddo
			oReuConv:cSQLFilter("") // Encerra filtro de convocados

			oPauta:lFiltered(.t.)
			oPauta:cSQLFilter("PARENTID = "+cBIStr(oReuniao:nValue("ID"))) // Filtra pelo pai
			oPauta:_First()
			if(!oPauta:lEof())
				cPauta := '<b><br>' + STR0010 + '<br></b>'
			end
			while(!oPauta:lEof())
				cNome := alltrim(oPauta:cValue("NOME"))
				// busca o elemento da pauta para trazer sua descrição
				if(!empty(cNome))
					oTable := oBscCore:oGetTable(cNome)
					if(oTable:lSeek(1,{oPauta:nValue("ELEMID")}))
						cNome += ": "+ oTable:cValue("NOME")
					endif
				endif

				cPauta += cNome + '<br>'
				cPauta += alltrim(oPauta:cValue("DETALHES")) + '<br><br> '
				oPauta:_Next()
			enddo
			oPauta:cSQLFilter("") // Encerra filtro	

			cAssunto	:= TEXT_ENTITY+": " + alltrim(oReuniao:cValue("NOME"))
			cCorpo		:= STR0004 +": "+ alltrim(oReuniao:cValue("DATAREU"))+ '<br>'
			cCorpo		+= STR0005 +": "+ alltrim(oReuniao:cValue("HORAINI"))+" "+STR0007+":"+ alltrim(oReuniao:cValue("HORAFIM"))+ '<br>'
			cCorpo		+= STR0006 +": "+ alltrim(oReuniao:cValue("LOCAL")) + '<br>'
			cCorpo		+= STR0009 +": "+alltrim(oReuniao:cValue("DETALHES")) + '<br>'
			cCorpo		+= cPauta
			cAnexos		:= "" //alltrim(oReuniao:cValue("ANEXOS"))
			oConexao:SendMail(cServer, cPorta, cConta, cAutUsuario, cAutSenha, cTo, cAssunto, cCorpo, cAnexos)
		endif
		oConexao:cSQLFilter("") // Retira filtro
	else
		nStatus := 	BSC_ST_BADID
	endif

return nStatus              

function _BSC060_Reu()
return