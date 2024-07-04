// ######################################################################################
// Projeto: BSC
// Modulo : Relatório de Indicadores
// Fonte  : BSC053_Ind.prw
// ---------+-------------------+-------------------------------------------------F-------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 06.01.04 | 1645 Leandro Marcelino Santos
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC053_Ind.ch"

/*--------------------------------------------------------------------------------------
@class TBSC053
@entity RelInd
Relatório de Indicadores
@table BSC053
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "RELIND"
#define TAG_GROUP  "RELINDS"
#define TEXT_ENTITY STR0001/*//"Relatório de Indicador"*/
#define TEXT_GROUP  STR0002/*//"Relatórios de Indicadores"*/

class TBSC053 from TBITable
	method New() constructor
	method NewBSC053()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)
	method BSCRelIndJob(aParms)

	// registro atual
	method oToXMLNode(nParentID)
	method nUpdFromXML(oXML, cPath)
	
	// executar 
	method nExecute(nID, cExecCMD)
endclass

method New() class TBSC053
	::NewBSC053()
return
method NewBSC053() class TBSC053
	
	// Table
	::NewTable("BSC053")
	::cEntity(TAG_ENTITY)
	
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("NOME",		"C",	60))
	::addField(TBIField():New("DESCRICAO",	"C",	255))
	::addField(TBIField():New("IMPDESC",	"L")) // Imprime descrição
	::addField(TBIField():New("DEPERSPEC",	"N"))
	::addField(TBIField():New("ATEPERSPEC",	"N"))
	::addField(TBIField():New("DEDATA",		"D"))
	::addField(TBIField():New("ATEDATA",	"D"))
	::addField(TBIField():New("SITUACAO",	"N")) //1-Atingido, 2-Nao Atingido, 3-Ambos

	::addField(TBIField():New("ORDEMOBJ",	"N")) //1-Crescente, 2-Decrescente
	::addField(TBIField():New("ORDEMIND",	"N")) //1-Crescente, 2-Decrescente

	// Indexes
	::addIndex(TBIIndex():New("BSC053I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC053I02",	{"NOME", "CONTEXTID"},.t.))
	::addIndex(TBIIndex():New("BSC053I03",	{"PARENTID", "ID"},	.t.))

return

// Arvore
method oArvore(nParentID) class TBSC053
	local oXMLArvore, oNode
	
	::SetOrder(2) // Por ordem de Nome
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
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Encerra filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC053
	local aFields, oNode, oAttrib, oXMLNode, nInd
	
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
	::SetOrder(2) // Por ordem de Nome
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","IMPDESC","DEPERSPEC","ATEPERSPEC","DEDATA","ATEDATA"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentID) class TBSC053
	local aFields, nInd, nStatus := BSC_ST_OK, dDataAlvo
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	::SetOrder(1) // Por ordem de ID
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	if(::lEof())
		// Inseri registro
		if(!::lAppend({ {"ID", ::nMakeID()}, {"CONTEXTID", nParentID}, {"PARENTID", nParentID} }))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif	
	endif

	if nStatus == BSC_ST_OK
		// Acrescenta os valores ao XML
		aFields := ::xRecord(RF_ARRAY)
		for nInd := 1 to len(aFields)
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			if(aFields[nInd][1] == "ID")
				nID := aFields[nInd][2]
			endif	
		next
	endif
	
	::cSQLFilter("") // Filtra pelo pai
	oXMLNode:oAddChild(::oOwner():oGetTable("PERSPECTIVA"):oToXMLList(nParentId))
	
 	dDataAlvo := ::oOwner():xSessionValue("DATAALVO")
	if(valtype(dDataAlvo)=="U")
		dDataAlvo := date()
	endif	     

	// Acrescenta children
	oXMLNode:oAddChild(TBIXMLNode():New("DATAALVO", dDataAlvo))

	/* Opções de situação do Objetivo*/
	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("SITUACOES",,oAttrib)

	// "Atingido"
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("SITUACAO"))
	oNode:oAddChild(TBIXMLNode():New("ID", 1))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0007))/*//"1-Atingido"*/

	// "Não atingido"
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("SITUACAO"))
	oNode:oAddChild(TBIXMLNode():New("ID", 2))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0008))/*//"2-Não atingido"/*/

	// "Ambos"
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("SITUACAO"))
	oNode:oAddChild(TBIXMLNode():New("ID", 3))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0009))/*//"3-Ambos"*/

	oXMLNode:oAddChild(oXMLOutput)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("ORDENSOBJ")

	// "1-Crescente"
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("ORDEM"))
	oNode:oAddChild(TBIXMLNode():New("ID", 1))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0010))/*//"1-Crescente"*/

	// "2-Decrescente"
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("ORDEM"))
	oNode:oAddChild(TBIXMLNode():New("ID", 2))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0011))/*//"2-Decrescente"/*/

	oXMLNode:oAddChild(oXMLOutput)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("ORDENSIND")

	// "1-Crescente"
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("ORDEM"))
	oNode:oAddChild(TBIXMLNode():New("ID", 1))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0010))/*//"1-Crescente"*/

	// "2-Decrescente"
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("ORDEM"))
	oNode:oAddChild(TBIXMLNode():New("ID", 2))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0011))/*//"2-Decrescente"/*/

	oXMLNode:oAddChild(oXMLOutput)

return oXMLNode

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC053
	local nStatus := BSC_ST_OK,	nParentID, nInd
	private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			nParentID := aFields[nInd][2]
		endif	
	next

	// Verifica condições de gravação (append ou update)
	::SetOrder(1) // Por ordem de ID
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	if(::lEof())
		// Inseri registro
		if(!::lAppend({ {"ID", ::nMakeID()}, {"CONTEXTID", nParentID}, {"PARENTID", nParentID} }))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif	
	else
		if(!::lUpdate(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif	
	endif       
	::cSQLFilter("") // Filtra pelo pai

return nStatus

// Execute
method nExecute(nID, cExecCMD) class TBSC053
	local nStatus := BSC_ST_OK
	local aParms := {}
	local oEstrategia, dDataAlvo, lParcelada

	// Data na qual o BSC se baseia para analisar os dados e gerar snapshot
	dDataAlvo := ::oOwner():xSessionValue("DATAALVO")
	if(empty(dDataAlvo))
		dDataAlvo := date()
	endif	     

	// Analise de metas Parcelada ou Acumuladas
	lParcelada := ::oOwner():xSessionValue("PARCELADA")
	if(valtype(lParcelada)=="U")
		lParcelada := .f.
	endif	     

	if(::lSeek(1, {nID})) // Posiciona no ID informado

		// 1 - Nome
		aAdd(aParms, alltrim(::cValue("NOME")))

		// 2 - Descrição
		aAdd(aParms, ::cValue("DESCRICAO"))

		// 3 - Imprime Descrição?
		aAdd(aParms, ::lValue("IMPDESC"))

		// 4 - De Data
		aAdd(aParms, ::dValue("DEDATA"))

		// 5 - Ate Data
		aAdd(aParms, ::dValue("ATEDATA"))                                   

		// 6 - De Perspectiva
		aAdd(aParms, ::nValue("DEPERSPEC"))

		// 7 - Ate Perspectiva
		aAdd(aParms, ::nValue("ATEPERSPEC"))

		// 8 - ID da Organização
		oEstrategia := ::oOwner():oGetTable("ESTRATEGIA")
		oEstrategia:lSeek(1, {::nValue("PARENTID")})
		aAdd(aParms, oEstrategia:nValue("PARENTID"))

		// 9 - ID da Estratégia
		aAdd(aParms, ::nValue("PARENTID"))

		// 10 - ID do Relatório
		aAdd(aParms, ::nValue("ID"))
	
		// 11 - BSCPATH da Working THREAD
		aAdd(aParms, ::oOwner():cBscPath())

		// 12 - Nome do relatorio
		aAdd(aParms, alltrim(cExecCMD))

		// 13 - Data Alvo
		aAdd(aParms, dDataAlvo )

		// 14 - Usuário Logado
		aAdd(aParms, ::oOwner():foSecurity:fnUserCard )

		// 15 - Parcelada
		aAdd(aParms, lParcelada )

		// 16 - Situacao do Objetivo. 1-Atingido, 2-Nao atingido, 3-Ambos
		aAdd(aParms, ::nValue("SITUACAO"))
		
		// 17 - Ordenação de Objetivos. 1-Crescente, 2-Decrescente
		aAdd(aParms, ::nValue("ORDEMOBJ"))

		// 18 - Ordenação de Indicadores. 1-Crescente, 2-Decrescente
		aAdd(aParms, ::nValue("ORDEMIND"))

		// Executando JOB
		::BSCRelIndJob(aParms)
	
	else

		nStatus := 	BSC_ST_BADID

	endif

return nStatus

// Funcao executa o job
method BSCRelIndJob(aParms) class TBSC053
	local cTopDb, cTopAlias, cTopServer, cConType, nTopError
	local cNome, cDescricao, lImpDesc, oScoreCardObj, cBscPath, nSituacao, nOrdemObj, nOrdemInd
	local dDataAlvo, lParcelada
	local nI, nStart := 0, nUserCard
	local aCores := {"#EA8C88","#EA8C88","#EA8C88","#FFEB9B","#FFEB9B","#FFEB9B","8BBF96","8BBF96","8BBF96","#4E85E6","#4E85E6","#4E85E6"}
	local cUrl := left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))
// vermelhp ea8c88 AZUL 1085C9 verde 8bbf96 Amarelo ffeb9b
	// Coleta os parametros
	// 1 - Nome
	cNome			:= aParms[1]
	// 2 - Descrição
	cDescricao 		:= aParms[2]
	// 3 - Imprime Descrição?
	lImpDesc		:= aParms[3]
	// 4 - De Data
	dDeData			:= aParms[4]
	// 5 - Ate Data
	dAteData		:= aParms[5]
	// 6 - De Perspectiva
	nDePerspec		:= aParms[6]
	// 7 - Ate Perspectiva
	nAtePerspec		:= aParms[7]  	
	// 8 - ID da Organização
	nOrgID			:= aParms[8]
	// 9 - ID da Estratégia
	nEstID			:= aParms[9]
	// 10 - ID do Relatório
	nID				:= aParms[10]
	// 11 - BSCPATH da Working THREAD
	cBscPath 		:= aParms[11]
	// 12 - Nome do arquivo que sera salvo
	cReportName 	:= aParms[12]
	// 13 - Data Alvo
	dDataAlvo 		:= aParms[13]
	// 14 - Usuário Logado
	nUserCard		:= aParms[14]
	// 15 - Parcelada
	lParcelada 		:= aParms[15]
	// 16 - Situacao do Objetivo.1-Atingido, 2-Nao Atingido, 3-Ambos
	nSituacao 		:= aParms[16]
	// 17 - Ordenação de Objetivos. 1-Crescente, 2-Decrescente
	nOrdemObj		:= aParms[17]
	// 18 - Ordenação de Indicadores. 1-Crescente, 2-Decrescente
	nOrdemInd		:= aParms[18]

    /*Ajusta o range De-Ate para ordem crescente.*/          
	If(nDePerspec > nAtePerspec)	      
		/*6 - De Perspectiva*/
		nDePerspec		:= aParms[7]
		/*7 - Ate Perspectiva*/
		nAtePerspec		:= aParms[6] 
	EndIf
	
	// Init
	ErrorBlock( {|oE| __BSCError(oE)})

	// Arquivo de log
	oBSCCore:LogInit()
	oBSCCore:Log("Iniciando geração do relatório [REL053_" + cBIStr(nID) + ".html]", BSC_LOG_SCRFILE)

	oBSCCore:lSetupCard(nUserCard)
	
	oOrganizacao := ::oOwner():oGetTable("ORGANIZACAO")
	oEstrategia := ::oOwner():oGetTable("ESTRATEGIA")
	oPerspectiva := ::oOwner():oGetTable("PERSPECTIVA")
	oObjetivo := ::oOwner():oGetTable("OBJETIVO")
	oObjetivo:SetOrder(2) // Por ordem de nome

	oIniciativa := ::oOwner():oGetTable("INICIATIVA")
	oIniciativa:SetOrder(2) // Por ordem de nome
	
	oIndicador := ::oOwner():oGetTable("INDICADOR")
	oIndicador:SetOrder(2) // Por ordem de nome

	oMeta := ::oOwner():oGetTable("META")
	oMeta:SetOrder(4) 

	oOrganizacao:lSeek(1,{nOrgID})
	
	oEstrategia:lSeek(1,{nEstID})  

	::oOwner():Log(STR0003 + cBIStr(nID) + ".html]", BSC_LOG_SCRFILE)/*//"Iniciando geração do arquivo [REL053_"*/
                                
	// Gera arquivo HTM	
	oHtmFile := TBIFileIO():New(oBSCCore:cBscPath()+"relato\"+cReportName)

	// Cria o arquivo htm
	if ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oBSCCore:Log(STR0004 + cBIStr(nID) + ".html]", BSC_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL053_"*/
		oBSCCore:Log(STR0005, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
		return
	endif
	
	aPerspectiva := {}

	oPerspectiva:cSqlFilter("PARENTID = "+cBIStr(nEstID))
	oPerspectiva:lFiltered(.t.)
	oPerspectiva:lSoftSeek(1,{nDePerspec})

	while(!oPerspectiva:lEof() .and. (oPerspectiva:nValue("ID") <= nAtePerspec .or. empty(nAtePerspec)))

		oObjetivo:cSQLFilter("PARENTID = "+cBIStr(oPerspectiva:nValue("ID"))) // Filtra pelo pai
		oObjetivo:lFiltered(.t.)

		oObjetivo:_First()
		while(!oObjetivo:lEof())
			                                             
			oObjScoreCard := oObjetivo:oMakeCard(dDataAlvo, lParcelada)

			oIndicador:cSQLFilter("PARENTID = "+oObjetivo:cValue("ID")) // Filtra pelo pai
			oIndicador:lFiltered(.t.)

			oIndicador:_First()
	 		while(!oIndicador:lEof())

				oMeta:cSQLFilter("PARENTID = "+oIndicador:cValue("ID")) // Filtra pelo pai
				oMeta:lFiltered(.t.)
				oMeta:_First()
				
				oIndScoreCard := oIndicador:oMakeCard(dDataAlvo, lParcelada)
				
				if(oMeta:dValue("DATAALVO") >= dDeData .and. oMeta:dValue("DATAALVO") <= dAteData)
				
					oIndScoreCard := oIndicador:oMakeCard(dDataAlvo, lParcelada)
	                if((nSituacao=1 .and. oObjScoreCard:fnPercMeta >= 100) .or.;
	 	               (nSituacao=2 .and. oObjScoreCard:fnPercMeta < 100) .or.;
	 	               empty(nSituacao) .or. nSituacao=3)
							aadd(aPerspectiva,{	oPerspectiva:cValue("NOME"),;
										oObjetivo:cValue("NOME"),;
										oObjScoreCard:fcPercMeta,;
										oIndicador:cValue("NOME"),;
										oIndScoreCard:fdDataAlvo,;
										cBIStr(oIndScoreCard:fnAlvo)+" "+oIndScoreCard:fcUnidade,;
										cBIStr(oIndScoreCard:fnAtual)+" "+oIndScoreCard:fcUnidade,;
										oObjScoreCard:fnPercMeta >= 100,;
										if(oObjScoreCard:fnFeedBack>0,aCores[oObjScoreCard:fnFeedBack],''),;
										if(oIndScoreCard:fnFeedBack>0,aCores[oIndScoreCard:fnFeedBack],'')}) //#A9373E"
					endif
				endif
											
				oMeta:cSQLFilter("")

				oIndicador:_Next()
			end  
        
			oIndicador:cSQLFilter("")

			oObjetivo:_Next()
		end
		oObjetivo:cSQLFilter("")

		oPerspectiva:_Next()
	end 
	oPerspectiva:cSQLFilter("")

	// Montagem do cabeçalho do html
	oHtmFile:nWriteLN('<html>')
	oHtmFile:nWriteLN('<head>')
	oHtmFile:nWriteLN('<title>Balanced ScoreCard</title>')
	oHtmFile:nWriteLN('<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">')
	oHtmFile:nWriteLN('<META HTTP-EQUIV="Pragma" CONTENT="no-cache"> ')
    oHtmFile:nWriteLN('<META HTTP-EQUIV="Expires" CONTENT="-1"> ')
	oHtmFile:nWriteLN('</head>')
	oHtmFile:nWriteLN('<body>')
	oHtmFile:nWriteLN('<table width="100%" border="0" cellspacing="0" cellpadding="0">')
	oHtmFile:nWriteLN('<tr>')
	oHtmFile:nWriteLN('<td width="150" valign="top"><img src="' + cUrl + 'images/logo_sigabsc.gif"></td>')
	oHtmFile:nWriteLN('<td> <table width="100%" border="0" cellspacing="0" cellpadding="0">')
	oHtmFile:nWriteLN('<tr><td align="center"><font size="4" face="Verdana, Arial, Helvetica, sans-serif">' +STR0012+/*Organização*/'</font></td></tr>')
	oHtmFile:nWriteLN('<tr><td align="center"><font size="5" face="Verdana, Arial, Helvetica, sans-serif">' + oOrganizacao:cValue("NOME") + '</font></td></tr>')
	oHtmFile:nWriteLN('</table>')
	oHtmFile:nWriteLN('</td>')
	oHtmFile:nWriteLN('<td width="150" align="right" valign="top"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + STR0013 /*Emissão:*/ + dtoc(date()) + '</font></td></tr>')
	oHtmFile:nWriteLN('</table>')
	oHtmFile:nWriteLN('<table width="100%" border="0" cellspacing="0" cellpadding="0">')

	oHtmFile:nWriteLN('	<tr><td>&nbsp;</td></tr>')
   	oHtmFile:nWriteLN('	<tr><td align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>' + STR0001 /*Relatório de Indicadores*/ + '</strong></font></td></tr>')
	oHtmFile:nWriteLN('	<tr><td>&nbsp;</td></tr>')

	oHtmFile:nWriteLN('<tr><td align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">'+ STR0014 /*Estratégia:*/+ oEstrategia:cValue("NOME") + '</font></td></tr>')
	oHtmFile:nWriteLN('<tr><td align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">TimeFrame: ' + oEstrategia:cValue("DATAINI") + ' a ' + oEstrategia:cValue("DATAFIN") + '</font></td>')
	oHtmFile:nWriteLN('</tr>')
	oHtmFile:nWriteLN('<tr><td><div align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + STR0015 /*Metas*/  + if(lParcelada, 'parceladas', 'acumuladas')  + STR0017 /*' no período de '*/ + dtoc(dDeData) + ' a ' + dtoc(dAteData) + '</font></div></td></tr>')
	oHtmFile:nWriteLN('<tr><td><div align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + STR0016 /*Data de Análise:*/ + DToC(dDataAlvo) + '</font></div></td></tr>')
	oHtmFile:nWriteLN('<tr><td><font size="2" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;</font></td></tr>')

	if len(aPerspectiva) > 0
		do case
			case nOrdemObj != 2 .AND. nOrdemInd != 2
				asort(aPerspectiva,,,{|x,y| x[1] < y[1] .OR. ( x[1] == y[1] .AND. ( x[2] < y[2] .OR. ( x[2] == y[2] .AND. x[4] <= y[4] ) ) ) })
			case nOrdemObj != 2 .AND. nOrdemInd = 2
				asort(aPerspectiva,,,{|x,y| x[1] < y[1] .OR. ( x[1] == y[1] .AND. ( x[2] < y[2] .OR. ( x[2] == y[2] .AND. x[4] >= y[4] ) ) ) })
			case nOrdemObj = 2  .AND. nOrdemInd != 2
				asort(aPerspectiva,,,{|x,y| x[1] < y[1] .OR. ( x[1] == y[1] .AND. ( x[2] > y[2] .OR. ( x[2] == y[2] .AND. x[4] <= y[4] ) ) ) })
			case nOrdemObj = 2  .AND. nOrdemInd = 2
				asort(aPerspectiva,,,{|x,y| x[1] < y[1] .OR. ( x[1] == y[1] .AND. ( x[2] > y[2] .OR. ( x[2] == y[2] .AND. x[4] >= y[4] ) ) ) })
        endcase
            
		if lImpDesc
			oHtmFile:nWriteLN('<tr><td><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>'+ STR0018 /*Descrição:*/ +'</strong>' + aParms[2] + '</font></td></tr>')
		endif
		oHtmFile:nWriteLN('</table>')
		
		cPerspectiva := cObjetivo := cIndicador := ""
		lQuebra := .F.

		nLinha := 0
		
		for nI := 1 to len(aPerspectiva)
		
			if cPerspectiva != aPerspectiva[nI,1]
				cPerspectiva := aPerspectiva[nI,1]
				
				if lQuebra
					lQuebra := .F.
					nLinha:=0
					oHtmFile:nWriteLN('<tr bgcolor="#ACA6D2">')
					oHtmFile:nWriteLN('<td><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>%' + STR0019/*Objetivo*/ + '</strong></font></td>')
					oHtmFile:nWriteLN('<td>&nbsp;</td>')
					oHtmFile:nWriteLN('<td>&nbsp;</td>')
					if(aPerspectiva[nI-1,8]) //atingiu a meta
						oHtmFile:nWriteLN('<td bgcolor='+aPerspectiva[nI-1,9]+'><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + aPerspectiva[nI-1,3] + '</font></td>')
					else
						oHtmFile:nWriteLN('<td bgcolor='+aPerspectiva[nI-1,9]+'><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + aPerspectiva[nI-1,3] + '</font></td>')
					endif
					oHtmFile:nWriteLN('</tr>')

					oHtmFile:nWriteLN('</table>')
				endif

				oHtmFile:nWriteLN('<table width="100%" border="0" cellspacing="0" cellpadding="0">')
				oHtmFile:nWriteLN('<tr><td>&nbsp;</td></tr>')
				oHtmFile:nWriteLN('<tr><td><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>' + STR0020 /*Perspectiva:*/  + '</strong>' + aPerspectiva[nI,1] + '</font></td></tr>')
				oHtmFile:nWriteLN('<tr><td>&nbsp;</td></tr>')
				oHtmFile:nWriteLN('</table>')

				oHtmFile:nWriteLN('<table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#FFFFFF">')
				oHtmFile:nWriteLN('<tr bgcolor="#ACA6D2">')
				oHtmFile:nWriteLN('<td width="30%"><div align="center"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Objetivo</font></strong></div></td>')
				oHtmFile:nWriteLN('<td width="30%"><div align="center"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Indicador</font></strong></div></td>')
				oHtmFile:nWriteLN('<td width="20%"><div align="center"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Meta</font></strong></div></td>')
				oHtmFile:nWriteLN('<td width="20%"><div align="center"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Realizado</font></strong></div></td>')
				oHtmFile:nWriteLN('</tr>')
			endif
			nLinha++
			
			if cObjetivo != aPerspectiva[nI,2]
				cObjetivo := aPerspectiva[nI,2]   
				                      
                if lQuebra
					nLinha:=0
					oHtmFile:nWriteLN('<tr bgcolor="#ACA6D2">')
					oHtmFile:nWriteLN('<td><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>%'+ STR0019 /*Objetivo*/ +'</strong></font></td>')
					oHtmFile:nWriteLN('<td>&nbsp;</td>')
					oHtmFile:nWriteLN('<td>&nbsp;</td>')
					if(aPerspectiva[nI-1,8]) //atingiu a meta
						oHtmFile:nWriteLN('<td bgcolor='+aPerspectiva[nI-1,9]+'><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + aPerspectiva[nI-1,3] + '</font></td>')
					else
						oHtmFile:nWriteLN('<td bgcolor='+aPerspectiva[nI-1,9]+'><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + aPerspectiva[nI-1,3] + '</font></td>')
					endif
					oHtmFile:nWriteLN('</tr>')
					oHtmFile:nWriteLN('<tr>')
					oHtmFile:nWriteLN('<td colspan="4">&nbsp;</td>')
					oHtmFile:nWriteLN('</tr>')
				endif

				if(nLinha%2==0)
					oHtmFile:nWriteLN('<tr bgcolor="#D3D1E9">')
				else
					oHtmFile:nWriteLN('<tr bgcolor="#E2E1F2">')
				endif

				oHtmFile:nWriteLN('<td><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + aPerspectiva[nI,2] + '</font></td>')
			else

				if(nLinha%2==0)
					oHtmFile:nWriteLN('<tr bgcolor="#D3D1E9">')
				else
					oHtmFile:nWriteLN('<tr bgcolor="#E2E1F2">')
				endif

				oHtmFile:nWriteLN('<td>&nbsp;</td>')
			endif
            
			if cIndicador != aPerspectiva[nI,4]
				cIndicador := aPerspectiva[nI,4]
				oHtmFile:nWriteLN('<td><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + aPerspectiva[nI,4] + '</font></td>')
			else
				oHtmFile:nWriteLN('<td>&nbsp;</td>')
			endif
			
			oHtmFile:nWriteLN('<td>')
			oHtmFile:nWriteLN('<table border="0" cellspacing="0" cellpadding="0">')
			oHtmFile:nWriteLN('<td width="105" align="left"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + cBITagEmpty(aPerspectiva[nI,6]) + '</font></td>')
			oHtmFile:nWriteLN('</table>')
			oHtmFile:nWriteLN('</td>')

			if(aPerspectiva[nI,8]) //atingiu a meta
				oHtmFile:nWriteLN('<td bgcolor='+aPerspectiva[nI,10]+'><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + cBITagEmpty(aPerspectiva[nI,7]) + '</font></td>')
			else
				oHtmFile:nWriteLN('<td bgcolor='+aPerspectiva[nI,10]+'><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + cBITagEmpty(aPerspectiva[nI,7]) + '</font></td>')
			endif
			oHtmFile:nWriteLN('</tr>')
			
			lQuebra := .T.

		next
		
		oHtmFile:nWriteLN('<tr bgcolor="#ACA6D2">')
		oHtmFile:nWriteLN('<td><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>% Objetivo</strong></font></td>')
		oHtmFile:nWriteLN('<td>&nbsp;</td>')
		oHtmFile:nWriteLN('<td>&nbsp;</td>')
		if(aPerspectiva[nI-1,8]) //atingiu a meta
			oHtmFile:nWriteLN('<td bgcolor='+aPerspectiva[nI-1,9]+'><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + aPerspectiva[nI-1,3] + '</font></td>')
		else
			oHtmFile:nWriteLN('<td bgcolor='+aPerspectiva[nI-1,9]+'><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + aPerspectiva[nI-1,3] + '</font></td>')
		endif
		oHtmFile:nWriteLN('</tr>')

		oHtmFile:nWriteLN('</table>')
	else
		oHtmFile:nWriteLN('<tr><td align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Não foram encontradas informações dentro das especificações passadas.</font></td></tr>')
	endif

    // finaliza html
	oHtmFile:nWriteLN('</body>')
	oHtmFile:nWriteLN('</html>')
	
	oHtmFile:lClose()

	oBSCCore:Log(STR0006+cNome+"]", BSC_LOG_SCRFILE)/*//"Finalizando geração do relatório ["*/
	::fcMsg := STR0006+cNome+"]"
return
                   
function _BSC053_Ind()
return