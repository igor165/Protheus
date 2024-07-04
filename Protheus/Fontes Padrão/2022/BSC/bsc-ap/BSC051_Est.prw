// ######################################################################################
// Projeto: BSC
// Modulo : Relatório de Estratégia
// Fonte  : BSC051_Est.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 17.12.03 | 1645 Leandro Marcelino Santos
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC051_Est.ch"

/*--------------------------------------------------------------------------------------
@class TBSC051
@entity RelEst
Raletório de Estratégias
@table BSC051
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "RELEST"
#define TAG_GROUP  "RELESTS"
#define TEXT_ENTITY STR0001/*//"Relatório de Estratégia"*/
#define TEXT_GROUP  STR0002/*//"Relatórios de Estratégias"*/

class TBSC051 from TBITable
	method New() constructor
	method NewBSC051()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)
	method BSCRelEstJob(aParms)

	// registro atual
	method oToXMLNode(nParentID)
	method nUpdFromXML(oXML, cPath)
	
	// executar 
	method nExecute(nID, cExecCMD)
endclass

method New() class TBSC051
	::NewBSC051()
return
method NewBSC051() class TBSC051
	
	// Table
	::NewTable("BSC051")
	::cEntity(TAG_ENTITY)
	
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("NOME",		"C",	60))
	::addField(TBIField():New("DESCRICAO",	"C",	255))
	::addField(TBIField():New("IMPDESC",	"L")) // Imprime descrição
	
	// Indexes
	::addIndex(TBIIndex():New("BSC051I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC051I02",	{"NOME", "CONTEXTID"},	.t.))
	::addIndex(TBIIndex():New("BSC051I03",	{"PARENTID", "ID"},	.t.))

return

// Arvore
method oArvore(nParentID) class TBSC051
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
method oToXMLList(nParentID) class TBSC051
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
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","IMPDESC","ORGID","ESTID"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentID) class TBSC051
	local aFields, nInd, nStatus := BSC_ST_OK
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
	
	// Monta combo de Organizações e Estratégias
//	oXMLNode:oAddChild(::oOnwer():oGetTable("ORGANIZACAO"):oToXMLList())
//	oXMLNode:oAddChild(::oOnwer():oGetTable("ESTRATEGIA"):oToXMLList())
	
return oXMLNode

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC051
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

return nStatus

// Execute
method nExecute(nID, cExecCMD) class TBSC051
	local nStatus := BSC_ST_OK
	local aParms := {}
	local oEstrategia	
	
	if(::lSeek(1, {nID})) // Posiciona no ID informado

		// 1 - Nome
		aAdd(aParms, alltrim(::cValue("NOME")))

		// 2 - Descrição
		aAdd(aParms, ::cValue("DESCRICAO"))

		// 3 - Imprime Descrição?
		aAdd(aParms, ::lValue("IMPDESC"))

		// 4 - ID da Organização
		oEstrategia := ::oOwner():oGetTable("ESTRATEGIA")
		oEstrategia:lSeek(1, {::nValue("PARENTID")})
		aAdd(aParms, oEstrategia:nValue("PARENTID"))

		// 5 - ID da Estratégia
		aAdd(aParms, ::nValue("PARENTID"))

		// 6 - ID do Relatório
		aAdd(aParms, ::nValue("ID"))
	
		// 7 - BscPath da working thread
		aAdd(aParms, ::oOwner():cBscPath())

		// 8 - Nome do relatorio
		aAdd(aParms,alltrim(cExecCMD))

		// Executando JOB
		::BSCRelEstJob(aParms)
	
	else

		nStatus := 	BSC_ST_BADID

	endif

return nStatus

// Funcao executa o job
//function BSCRelEstJob(aParms)
method BSCRelEstJob(aParms) class TBSC051
	local cTopDb, cTopAlias, cTopServer, cConType, nTopError, cBscPath
	local cNome, cDescricao, lImpDesc, nOrgID, nEstID, oLogger
	local oOrganizacao, oEstrategia, oPerspectiva, oObjetivo, oIndicador, oMeta, oIniciativa
	local nJ, nI, nStart := 0, lExisteDados := .f., nLinha 
	local uRl := left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))

	// Coleta os parametros
	// 1 - Nome
	cNome			:= aParms[1]
	// 2 - Descrição
	cDescricao 		:= aParms[2]
	// 3 - Imprime Descrição?
	lImpDesc		:= aParms[3]
	// 4 - ID da Organização
	nOrgID			:= aParms[4]
	// 5 - ID da Estratégia
	nEstID			:= aParms[5]
	// 6 - ID do Relatório
	nID				:= aParms[6]
	// 7 - BSCPATH da Working THREAD
	cBscPath		:= aParms[7]
	// 8 - Nome do arquivo que sera salvo
	cReportName := aParms[8]

	ErrorBlock( {|oE| __BSCError(oE)})

	oOrganizacao := ::oOwner():oGetTable("ORGANIZACAO")
	oEstrategia := ::oOwner():oGetTable("ESTRATEGIA")
	oPerspectiva := ::oOwner():oGetTable("PERSPECTIVA")
	oObjetivo := ::oOwner():oGetTable("OBJETIVO")
	oObjetivo:SetOrder(2) // Por ordem de nome
	
	oIndicador := ::oOwner():oGetTable("INDICADOR")
	oIndicador:SetOrder(2) // Por ordem de nome
	
	oMeta := ::oOwner():oGetTable("META")
	oMeta:SetOrder(2) // Por ordem de nome
	
	oIniciativa := ::oOwner():oGetTable("INICIATIVA")
	oIniciativa:SetOrder(2) // Por ordem de nome
	
	oOrganizacao:lSeek(1,{nOrgID})
	
	oEstrategia:lSeek(1,{nEstID})
	
	// Gera arquivo HTM	
	::oOwner():Log(STR0004 + cBIStr(nID) + ".html]", BSC_LOG_SCRFILE)/*//"Iniciando geração do arquivo [REL051_"*/
	oHtmFile := TBIFileIO():New(::oOwner():cBscPath()+"relato\"+cReportName)

	// Cria o arquivo htm
	if ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oBSCCore:Log(STR0005 + cBIStr(nID) + ".html]", BSC_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL051_"*/
		oBSCCore:Log(STR0006, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
		return BSC_ST_GENERALERROR
	endif
	
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
	oHtmFile:nWriteLN('<td width="150"><img src="' + uRl +'images/logo_sigabsc.gif"></td>')
	oHtmFile:nWriteLN('<td>')
	oHtmFile:nWriteLN('<table width="100%" border="0" cellspacing="0" cellpadding="0">')
	oHtmFile:nWriteLN('<tr><td align="center"><font size="4" face="Verdana, Arial, Helvetica, sans-serif">'+STR0009 /*Organização*/ +'</font></td></tr>')
	oHtmFile:nWriteLN('<tr><td align="center"><font size="5" face="Verdana, Arial, Helvetica, sans-serif">' + oOrganizacao:cValue("NOME") + '</font></td></tr>')
	oHtmFile:nWriteLN('</table>')
	oHtmFile:nWriteLN('</td>')
	oHtmFile:nWriteLN('<td width="150" align="right" valign="top"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + STR0010 /*Emissão:*/ + dtoc(date()) + '</font></td>')
	oHtmFile:nWriteLN('</tr>')
	oHtmFile:nWriteLN('</table>')                                                       
	oHtmFile:nWriteLN('<table width="100%" border="0" cellspacing="0" cellpadding="0">')
   
	oHtmFile:nWriteLN('<tr><td>&nbsp;</td></tr>')
   	oHtmFile:nWriteLN('<tr><td align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>' + STR0001 /*Relatório de Estratégia*/ + '</strong></font></td></tr>')
	oHtmFile:nWriteLN('<tr><td>&nbsp;</td></tr>')
	
	oHtmFile:nWriteLN('<tr><td align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + STR0011 /*Estratégia:*/ + oEstrategia:cValue("NOME") + '</font></td></tr>')
	oHtmFile:nWriteLN('<tr><td align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' +STR0012 /*Período:*/ + oEstrategia:cValue("DATAINI") + STR0013 /* à */ + oEstrategia:cValue("DATAFIN") + '</font></td></tr>')
	oHtmFile:nWriteLN('<tr><td>&nbsp;</td></tr>')
	
	if lImpDesc
		oHtmFile:nWriteLN('<tr><td><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Descrição: </strong>' + aParms[2] + '</font></td></tr>')
		oHtmFile:nWriteLN('<tr><td>&nbsp;</td></tr>')
	endif
	
	oHtmFile:nWriteLN('</table>')
	
	oPerspectiva:cSQLFilter("PARENTID = "+cBIStr(oEstrategia:nValue("ID"))) // Filtra pelo pai
	oPerspectiva:lFiltered(.t.)
	oPerspectiva:_First()
	while(!oPerspectiva:lEof())

		// Monta cabeçalho da perspectiva
		oHtmFile:nWriteLN('<table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#FFFFFF">')
		
		oHtmFile:nWriteLN('<tr><td colspan="4"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Perspectiva: ' +;
							oPerspectiva:cValue("NOME") +;
							if(oPerspectiva:lValue("OPERAC"),"&nbsp;(" + STR0008 +")&nbsp;","") +'</strong></font></td></tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="30%" bgcolor="#ACA6D2" align="center"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Objetivos</font></strong></td>')
		oHtmFile:nWriteLN('<td width="30%" bgcolor="#ACA6D2" align="center"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Indicadores</font></strong></td>')
		oHtmFile:nWriteLN('<td width="20%" bgcolor="#ACA6D2" align="center"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Metas</font></strong></td>')
		oHtmFile:nWriteLN('<td width="20%" bgcolor="#ACA6D2" align="center"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Iniciativas</font></strong></td>')
		oHtmFile:nWriteLN('</tr>')

		nLinha := 0
		oObjetivo:cSQLFilter("PARENTID = "+cBIStr(oPerspectiva:nValue("ID"))) // Filtra pelo pai
		oObjetivo:lFiltered(.t.)
		oObjetivo:_First()    
		
		while(!oObjetivo:lEof())
			lExisteDados := .t.
			nLinha++
	
			// Array com estrutura do relatório por Objetivo
			aIndicador 	:= {}
			aIniciativa	:= {}
			                                             
			oIndicador:cSQLFilter("PARENTID = "+oObjetivo:cValue("ID")) // Filtra pelo pai
			oIndicador:lFiltered(.t.)
			oIndicador:_First()                  
			while(!oIndicador:lEof())

				// Adiciona nome do indicador corrente, deixando um vetor limpo para inclução das metas
				aAdd(aIndicador, {oIndicador:cValue("NOME"),{""}})

				aMeta := {}
				oMeta:SetOrder(4)
				oMeta:cSQLFilter("PARENTID = "+oIndicador:cValue("ID")) // Filtra pelo pai
				oMeta:lFiltered(.t.)
				oMeta:_First()
				while(!oMeta:lEof())                                                                   
				
					// Prepara vetor de metas
					aAdd(aMeta,{oMeta:cValue("VERDE"), oIndicador:cValue("UNIDADE"), oMeta:dValue("DATAALVO")})

					oMeta:_Next()
				end                                           
				oMeta:cSQLFilter("")
				
				// Adiciona o vetor de metas ao vetor de seu indicador
				aIndicador[len(aIndicador),2] := aClone(aMeta)

				oIndicador:_Next()
			end            
			oIndicador:cSQLFilter("")
	                                         
			oIniciativa:cSQLFilter("PARENTID = "+oObjetivo:cValue("ID")) // Filtra pelo pai
			oIniciativa:lFiltered(.t.)
			oIniciativa:_First()
			while(!oIniciativa:lEof())          

				// Prepara vetor com as iniciativa para o objetivo
				aAdd(aIniciativa, oIniciativa:cValue("NOME"))
				
				oIniciativa:_Next()
			end
			oIniciativa:cSQLFilter("")

			// Cria linha pro objetivo
			if(nLinha%2==0)
				oHtmFile:nWriteLN('<tr bgcolor="#D3D1E9">')
			else
				oHtmFile:nWriteLN('<tr bgcolor="#E2E1F2">')
			endif
			
			oHtmFile:nWriteLN('<td width="30%" align="left" valign="top"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + oObjetivo:cValue("NOME") + '</font></td>')
			
            // Indicadores
			if(len(aIndicador)==0)
				oHtmFile:nWriteLN('<td>&nbsp;</td>')
			else
				oHtmFile:nWriteLN('<td width="30%" align="left" valign="top"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">')
				for nI := 1 to len(aIndicador)
					// Cria celulas de indicadores
					oHtmFile:nWriteLN(aIndicador[nI,1] + '<br>')
					if(len(aIndicador[nI,2])>1)
						for nJ := 2 to len(aIndicador[nI,2])
							oHtmFile:nWriteLN('&nbsp;<br>')
						next
					endif
				next
				oHtmFile:nWriteLN('</font></td>')
			endif
			
			// Metas
			if(len(aIndicador)==0)
				oHtmFile:nWriteLN('<td>&nbsp;</td>')
			else
				oHtmFile:nWriteLN('<td width="20%" align="left" valign="top">')
				oHtmFile:nWriteLN('<table border="0" cellpadding="0" cellspacing="0">')
				for nI := 1 to len(aIndicador) 
					if(len(aIndicador[nI,2])==0)
						oHtmFile:nWriteLN('<tr>&nbsp;</tr>')
					else
						for nJ := 1 to len(aIndicador[nI,2])
							oHtmFile:nWriteLN('<tr>')
							oHtmFile:nWriteLN('<td align="right" width="90"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + aIndicador[nI,2,nJ,1] + ' ' + aIndicador[nI,2,nJ,2] + '</font></td>')
							oHtmFile:nWriteLN('<td align="center" width="85"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + cBITagEmpty(aIndicador[nI,2,nJ,3]) + '</font></td>')
							oHtmFile:nWriteLN('</tr>')
						next
					endif
				next
				oHtmFile:nWriteLN('</table>')
				oHtmFile:nWriteLN('</td>')
			endif
			
			// Iniciativas
			if(len(aIniciativa)==0)
				oHtmFile:nWriteLN('<td>&nbsp;</td>')
			else
				oHtmFile:nWriteLN('<td width="30%" align="left" valign="top"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">')
				for nI := 1 to len(aIniciativa)
					oHtmFile:nWriteLN(aIniciativa[nI] + '<br>')
	            next
				oHtmFile:nWriteLN('</font></td>')
			endif
			oHtmFile:nWriteLN('</tr>')   

			oObjetivo:_Next()
		end
		
		oObjetivo:cSQLFilter("")
		
		if(!lExisteDados)
			oHtmFile:nWriteLN('<tr><td colspan="4"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><em>' + STR0014/*"Não existem dados a serem apresentados"*/+ '</em></font></td></tr>')
		endif

		oHtmFile:nWriteLN('</table>')                          
		
        // cria linha em branco entre uma perspectiva e outra
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td colspan="4">&nbsp;</td>')
		oHtmFile:nWriteLN('</tr>')

		oPerspectiva:_Next()
	end 
	oPerspectiva:cSQLFilter("")

    // finaliza html
	oHtmFile:nWriteLN('</body>')
	oHtmFile:nWriteLN('</html>')
		
	oHtmFile:lClose()
	
	::oOwner():Log(STR0007+cNome+"]", BSC_LOG_SCRFILE)/*//"Finalizando geração do relatório ["*/
	::fcMsg := STR0007+cNome+"]"
return

function _BSC051_Est()
return
