	// ######################################################################################
// Projeto: BSC
// Modulo : Relatório de Tarefas (5w2h)
// Fonte  : BSC054_5w2h.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 03.05.04 | 1645 Leandro Marcelino Santos
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC054_5w2h.ch"

/*--------------------------------------------------------------------------------------
@class TBSC054
@entity RelPlano
Relatório Palano de Ação
@table BSC054
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "REL5W2H"
#define TAG_GROUP  "REL5W2HS"
#define TEXT_ENTITY STR0001/*//"Relatório de Plano de Ação"*/
#define TEXT_GROUP  STR0002/*//"Relatórios de Planos de Ação"*/

class TBSC054 from TBITable
	method New() constructor
	method NewBSC054()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)
	method BSCRel5w2hJob(aParms)

	// registro atual
	method oToXMLNode(nParentID)
	method nUpdFromXML(oXML, cPath)
	
	// executar 
	method nExecute(nID, cExecCMD)
endclass

method New() class TBSC054
	::NewBSC054()
return
method NewBSC054() class TBSC054
	
	// Table
	::NewTable("BSC054")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("NOME",		"C",	60))
	::addField(TBIField():New("DESCRICAO",	"C",	255))
	::addField(TBIField():New("IMPDESC",	"L")) // Imprime descrição
	::addField(TBIField():New("INICIODE",	"D"))
	::addField(TBIField():New("INICIOATE",	"D"))
	::addField(TBIField():New("TERMINODE",	"D"))
	::addField(TBIField():New("TERMINOATE",	"D"))
	::addField(TBIField():New("PESID",		"N"))
	::addField(TBIField():New("PERSID",		"N"))
	::addField(TBIField():New("OBJID",		"N"))
	::addField(TBIField():New("INICID",		"N"))
	::addField(TBIField():New("SITID",		"N"))
	::addField(TBIField():New("IMPORTANCI","N")) //(1) A-Vital; (2) B-Importante; (3) C-Interessante
	::addField(TBIField():New("URGENCIA","N")) //(1) 0-Urgente; (2) 1-Curto Prazo; (3) 2-Médio Prazo; (4) 3-Longo Prazo (sem prazo)

	// Indexes
	::addIndex(TBIIndex():New("BSC054I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC054I02",	{"NOME", "CONTEXTID"},	.t.))
	::addIndex(TBIIndex():New("BSC054I03",	{"PARENTID", "ID"},	.t.))

	//Copiar Coluna;
	::faCopyColumn := {{"IMPORTANCIA","IMPORTANCI"}}//Origem destino;
return

// Arvore
method oArvore(nParentID) class TBSC054
	local oXMLArvore, oNode
	
	::SetOrder(1) // Por ordem de ID
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
method oToXMLList(nParentID) class TBSC054
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
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","IMPDESC","INICIODE","INICIOATE",;
										"TERMINODE","TERMINOATE","PESID","PERSID","OBJID","INICID","SITID"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentID) class TBSC054
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

	//Combos
	oTable := ::oOwner():oGetTable("ESTRATEGIA")
	oTable:lSeek(1, {nParentID})
	nOrgID := ::oOwner():oAncestor("ORGANIZACAO", oTable):nValue("ID")
	oXMLNode:oAddChild(::oOwner():oGetTable("PESSOA"):oToXMLList(nOrgID))

	// Acrescenta children
	oXMLNode:oAddChild(::oOwner():oGetTable("PERSPECTIVA"):oToXMLContextList(nParentID))
	oXMLNode:oAddChild(::oOwner():oGetTable("OBJETIVO"):oToXMLContextList(nParentID))
	oXMLNode:oAddChild(::oOwner():oGetTable("INICIATIVA"):oToXMLContextList(nParentID))
	oXMLNode:oAddChild(::oOwner():oGetTable("TAREFA"):oXMLSituacao())
	oXMLNode:oAddChild(::oOwner():oGetTable("TAREFA"):oXMLImportancia())
	oXMLNode:oAddChild(::oOwner():oGetTable("TAREFA"):oXMLUrgencia())
	
return oXMLNode

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC054
	local nStatus := BSC_ST_OK,	nParentID, nInd, oTable, cNome
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
method nExecute(nID, cExecCMD) class TBSC054
	local nStatus := BSC_ST_OK, oEstrategia
	local aParms := {}
	
	if(::lSeek(1, {nID})) // Posiciona no ID informado

		// 1 - Nome
		aAdd(aParms, alltrim(::cValue("NOME")))
		// 2 - Descrição
		aAdd(aParms, ::cValue("DESCRICAO"))
		// 3 - Imprime Descrição?
		aAdd(aParms, ::lValue("IMPDESC"))
		// 4 - Inicio de
		aAdd(aParms, ::dValue("INICIODE"))
		// 5 - Inicio ate
		aAdd(aParms, ::dValue("INICIOATE"))
		// 6 - Termino de
		aAdd(aParms, ::dValue("TERMINODE"))
		// 7 - Termino ate
		aAdd(aParms, ::dValue("TERMINOATE"))
		// 8 - Id da Pessoa
		aAdd(aParms, ::nValue("PESID"))
		// 9 - ID da Organização
		oEstrategia := ::oOwner():oGetTable("ESTRATEGIA")
		oEstrategia:lSeek(1, {::nValue("PARENTID")})
		aAdd(aParms, oEstrategia:nValue("PARENTID"))
		// 10 - ID da Estratégia
		aAdd(aParms, ::nValue("PARENTID"))
		// 11 - Id da Perspectiva
		aAdd(aParms, ::nValue("PERSID"))
		// 12 - Id do Objetivo 
		aAdd(aParms, ::nValue("OBJID"))
		// 13 - Id da Iniciativa
		aAdd(aParms, ::nValue("INICID"))
		// 14 - Id da Situação
		aAdd(aParms, ::nValue("SITID"))
		// 15 - ID do Relatório
		aAdd(aParms, ::nValue("ID"))
		// 16 - BSCPATH da Working THREAD
		aAdd(aParms, ::oOwner():cBscPath())
		// 17 - Nome do relatorio
		aAdd(aParms, alltrim(cExecCMD))
		// 18 - Grau de importancia
		aAdd(aParms, ::nValue("IMPORTANCI"))
		// 19 - Classificação da urgencia da tarefa
		aAdd(aParms, ::nValue("URGENCIA"))

		// Executando JOB
		::BSCRel5w2hJob(aParms)
	else
		nStatus := 	BSC_ST_BADID
	endif

return nStatus

// Funcao executa o job
method BSCRel5w2hJob(aParms) class TBSC054
	local cTopDb, cTopAlias, cTopServer, cConType, nTopError
	local cNome, cDescricao, lImpDesc, cBscPath, nImportancia, nUrgencia, cFiltro, cImporUrgen := ""
	local lImprime := .T., nRegistro := 0, x, aPesCob := {}, aTarefa := {}, cSituacao
	local nStart := 0, nI, nJ, lEstrategia,	lPerspectiva, lObjetivo, lIniciativa   
	local oGrupoPes := nil  
	local cUrl := left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))

	// Coleta os parametros
	// 1 - Nome
	cNome		:= aParms[1]
	// 2 - Descrição
	cDescricao 	:= aParms[2]
	// 3 - Imprime Descrição?
	lImpDesc	:= aParms[3]
	// 4 - Inicio de
	dInicioDe	:= aParms[4]
	// 5 - Inicio ate
	dInicioAte	:= aParms[5]
	// 6 - Termino de
	dTerminoDe	:= aParms[6]
	// 7 - Termino ate
	dTerminoAte	:= aParms[7]
	// 8 - Id da Pessoa
	nPesID		:= aParms[8]
	// 9 - ID da Organização
	nOrgID		:= aParms[9]
	// 10 - ID da Estratégia
	nEstID		:= aParms[10]
	// 11 - Id da Perspectiva
	nPersID		:= aParms[11]
	// 12 - Id do Objetivo 
	nObjID		:= aParms[12]
	// 13 - Id da Iniciativa
	nInicID		:= aParms[13]
	// 14 - Id da Situação
	nSitID		:= aParms[14]
	// 15 - ID do Relatório
	nID			:= aParms[15]
	// 16 - BSCPATH da Working THREAD
	cBscPath	:= aParms[16]
	// 17 - Nome do arquivo que sera salvo
	cReportName := aParms[17]
	// 18 - Grau de importancia
	nImportancia := aParms[18]
	// 19 - Classificação da urgencia da tarefa
	nUrgencia := aParms[19]

	ErrorBlock( {|oE| __BSCError(oE)})

	// Arquivo de log
	oBSCCore:LogInit()
	oBSCCore:Log(STR0003 + cBIStr(nID) + ".html]", BSC_LOG_SCRFILE)/*//"Iniciando geração do relatório [REL054_"*/

	oHtmFile := TBIFileIO():New(oBSCCore:cBscPath()+"relato\"+cReportName)

	// Cria o arquivo htm
	If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oBSCCore:Log(STR0004 + cBIStr(nID) + ".html]", BSC_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL054_"*/
		oBSCCore:Log(STR0005, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
		return
	endif

	oOrganizacao := ::oOwner():oGetTable("ORGANIZACAO")
	oEstrategia := ::oOwner():oGetTable("ESTRATEGIA")
	oPerspectiva := ::oOwner():oGetTable("PERSPECTIVA")
	oObjetivo := ::oOwner():oGetTable("OBJETIVO")
	oIniciativa := ::oOwner():oGetTable("INICIATIVA")
	oTarefa := ::oOwner():oGetTable("TAREFA")
	oTarefa:SetOrder(2) // Por ordem de nome
	
	oPessoa := ::oOwner():oGetTable("PESSOA")
	oPessoa:SetOrder(2)

	oPesCob := ::oOwner():oGetTable("TARCOB")
	oPesCob:SetOrder(1)

	oOrganizacao:lSeek(1,{nOrgID})
	oEstrategia:lSeek(1,{nEstID})
	
	// Array com estrutura de tarefas
	aTarefa	:= {}
	if(nPersID!=0)  // Selecionou Estratégia
		oPerspectiva:cSQLFilter("ID = "+cBIStr(nPersID)) // Filtra pela Perspectiva
	else
		oPerspectiva:cSQLFilter("PARENTID = "+cBIStr(nEstID)) // Filtra pelo pai
	endif
	oPerspectiva:lFiltered(.t.)
	oPerspectiva:_First()

	cFiltro := ''
	if(!empty(nImportancia)) // Selecionou Importancia
		cFiltro += " and IMPORTANCI = "+cBIStr(nImportancia)
	endif
	if(!empty(nUrgencia)) // Selecionou Urgencia
		cFiltro += " and URGENCIA = "+cBIStr(nUrgencia)
	endif

	while(!oPerspectiva:lEof())

		if(nObjID!=0)  // Selecionou Objetivo
			oObjetivo:cSQLFilter("PARENTID = "+cBIStr(oPerspectiva:nValue("ID")) +;
			                     " and ID = "+cBIStr(nObjID)) // Filtra pelo Objetivo
		else
			oObjetivo:cSQLFilter("PARENTID = "+cBIStr(oPerspectiva:nValue("ID"))) // Filtra pelo pai
		endif
		oObjetivo:lFiltered(.t.)
		oObjetivo:_First()
		while(!oObjetivo:lEof())
			                                             
			if(nInicID!=0)  // Selecionou Iniciativa
				oIniciativa:cSQLFilter("PARENTID = "+cBIStr(oObjetivo:cValue("ID")) +;
									   "and ID = "+cBIStr(nInicID)) // Filtra pela Iniciativa
			else
				oIniciativa:cSQLFilter("PARENTID = "+cBIStr(oObjetivo:cValue("ID"))) // Filtra pelo pai
			endif
			oIniciativa:lFiltered(.t.)
			oIniciativa:_First()
			while(!oIniciativa:lEof())

				if(nSitID!=0) // Selecionou Situacao
					oTarefa:cSQLFilter(	"PARENTID = "+cBIStr(oIniciativa:cValue("ID"))+" and "+;
										"SITID = "+cBIStr(nSitID)+cFiltro) // Filtra pelo pai e pela Situacao
				else
					oTarefa:cSQLFilter("PARENTID = "+cBIStr(oIniciativa:cValue("ID"))+cFiltro) // Filtra pelo pai
				endif
				
				oTarefa:lFiltered(.t.)
				oTarefa:_First()
				while(!oTarefa:lEof())
				
					if(	(oTarefa:dValue("DATAINI") >= dInicioDe .and. oTarefa:dValue("DATAINI") <= dInicioAte) .or. ;
						(oTarefa:dValue("DATAFIN") >= dTerminoDe .and. oTarefa:dValue("DATAFIN") <= dTerminoAte) )

						oPesCob:cSQLFilter("PARENTID = "+oTarefa:cValue("ID")) // Filtra pelo pai
						oPesCob:lFiltered(.t.)
						if(nPesID!=0)                                  
							if oPesCob:cValue("TIPOPESSOA") == "G"
								oGrupoPes := ::oOwner():oGetTable("GRPXPESSOA")  
								oGrupoPes:lSeek(3,{oPesCob:nValue("PESSOAID"),nPesID})
								lImprime := !oGrupoPes:lEof()								
							else 
								oPesCob:lSeek(4,{oPesCob:nValue("PARENTID"),nPesID,"P"})
								lImprime := !oPesCob:lEof()
							endif							
						endif                               
						if(lImprime)
							oPesCob:_First()        
							nRegistro++ // Controla o número de registro na matriz
							while(!oPesCob:lEof())

								oPessoa:lseek(1,{oPesCob:nValue("PESSOAID")})
								if(!oPessoa:lEof())

									oSituacao := oTarefa:oXMLSituacao()
									oSituacao := oSituacao:oChildByName("SITUACAO", oTarefa:nValue("SITID"))
									if(valtype(oSituacao)!="U")
										oSituacao := oSituacao:oChildByName("NOME")
										cSituacao := oSituacao:cGetValue()
									else
										cSituacao := ""
									endif
									if(ascan(aTarefa,{|x| x[1] == nRegistro})==0)
										cImporUrgen := if(oTarefa:nValue("IMPORTANCI")==1,"A",(if(oTarefa:nValue("IMPORTANCI")==2,"B","C")))
										cImporUrgen := if(empty(oTarefa:nValue("IMPORTANCI")),"",cImporUrgen)
										cImporUrgen += "/"
										cImporUrgen += if(empty(oTarefa:nValue("URGENCIA")),"",strzero(oTarefa:nValue("URGENCIA")-1,1))
										aadd(aTarefa,{	nRegistro,;
													  	cSituacao,;
													  	oPerspectiva:cValue("NOME"),;
													  	oObjetivo:cValue("NOME"),;
													  	oIniciativa:cValue("NOME"),;
													  	oTarefa:cValue("NOME"),;
													  	oTarefa:dValue("DATAINI"),;
													  	oTarefa:dValue("DATAFIN"),;
													  	oTarefa:cValue("LOCAL"),;
													 	oTarefa:cValue("TEXTO"),;
													 	oTarefa:nValue("CE_MAOOBRA"),;
													 	oTarefa:nValue("CE_MATERIA"),;
													 	oTarefa:nValue("CE_TERCEIR"),;
													 	oTarefa:nValue("CR_MAOOBRA"),;
													 	oTarefa:nValue("CR_MATERIA"),;
													 	oTarefa:nValue("CR_TERCEIR"),;
													 	oTarefa:nValue("HORASEST"),;
													 	oTarefa:nValue("HORASREAL"),;
													 	oObjetivo:cValue("NOME"),;
													 	cImporUrgen})
									endif
									aadd(aPesCob,{nRegistro, oPessoa:cValue("NOME")})
								endif
				
								oPesCob:_Next()
							end
						endif
						oPesCob:cSQLFilter("")
						
					endif
					
					oTarefa:_Next()
				end
				oTarefa:cSQLFilter("")
				
				oIniciativa:_Next()
			end
			oIniciativa:cSQLFilter("")

			oObjetivo:_Next()
		end
		oObjetivo:cSQLFilter("")

		oPerspectiva:_Next()
	end 
	oPerspectiva:cSQLFilter("")

	// Montagem do cabeçalho do relatório
	oHtmFile:nWriteLN('<html>')
	oHtmFile:nWriteLN('<head>')
	oHtmFile:nWriteLN('<title>Balanced ScoreCard</title>')
	oHtmFile:nWriteLN('<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">')
	oHtmFile:nWriteLN('<META HTTP-EQUIV="Pragma" CONTENT="no-cache"> ')
    oHtmFile:nWriteLN('<META HTTP-EQUIV="Expires" CONTENT="-1"> ')
	oHtmFile:nWriteLN('</head>')
	oHtmFile:nWriteLN('<body>')
	oHtmFile:nWriteLN('<table width="980" border="0" cellspacing="0" cellpadding="0">') //Inicio table 1

	oHtmFile:nWriteLN('<tr>')
	oHtmFile:nWriteLN('<td>')
	oHtmFile:nWriteLN('<table width="100%" border="0" cellspacing="0" cellpadding="0">')
	oHtmFile:nWriteLN('<tr>')
	oHtmFile:nWriteLN('<td width="150"><img src="' + cUrl + 'images/logo_sigabsc.gif"></td>')
	oHtmFile:nWriteLN('<td>')
	oHtmFile:nWriteLN('<table width="100%" border="0" cellspacing="0" cellpadding="0">')
	oHtmFile:nWriteLN('<tr><td align="center"><font size="4" face="Verdana, Arial, Helvetica, sans-serif">'+STR0023+'</font></td></tr>') //Organização
	oHtmFile:nWriteLN('<tr><td align="center"><font size="5" face="Verdana, Arial, Helvetica, sans-serif">' + oOrganizacao:cValue("NOME") + '</font></td></tr>')
	oHtmFile:nWriteLN('</table>')
	oHtmFile:nWriteLN('</td>')
	oHtmFile:nWriteLN('<td width="150" align="right" valign="top"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">'+STR0034+' '+dtoc(date()) + '</font></td>') //Emissão:
	oHtmFile:nWriteLN('</tr>')
	oHtmFile:nWriteLN('</table>')
	oHtmFile:nWriteLN('</td>')
	oHtmFile:nWriteLN('</tr>')

	oHtmFile:nWriteLN('	<tr><td>&nbsp;</td></tr>')
   	oHtmFile:nWriteLN('	<tr><td align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>' + STR0001 /*Relatório de Plano de Ação */ + '</strong></font></td></tr>')
	oHtmFile:nWriteLN('	<tr><td>&nbsp;</td></tr>')
	
	oHtmFile:nWriteLN('<tr><td align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">'+STR0024+' - ' + alltrim(oEstrategia:cValue("NOME")) + '</font></td></tr>') //Estratégia
	oHtmFile:nWriteLN('<tr><td align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">'+STR0025 + oEstrategia:cValue("DATAINI") + STR0026 + oEstrategia:cValue("DATAFIN") + '</font></td>') //TimeFrame: ## a
	oHtmFile:nWriteLN('<tr><td>&nbsp;</td></tr>')
	if(len(aTarefa)>0)

		asort(aTarefa,,,{|x,y| x[2]+x[6] < y[2]+y[6]})
		
		if lImpDesc        
			oHtmFile:nWriteLN('<tr><td><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>'+STR0027+' </strong>' + alltrim(cBITagEmpty(aParms[2])) + '</font></td></tr>') //Descrição:
			oHtmFile:nWriteLN('<tr><td>&nbsp;</td></tr>')
		endif

		if(nPesID!=0)               
			oPessoa:lseek(1,{nPesID})
			oHtmFile:nWriteLN('<tr><td align="left"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">')
			oHtmFile:nWriteLN('<strong>'+STR0028+' </strong>' + oPessoa:cValue("NOME")) //Pessoa:
			if(!empty(oPessoa:cValue("CARGO")))
				oHtmFile:nWriteLN('<strong> /'+STR0029+' </strong>' + oPessoa:cValue("CARGO")) //Cargo:
			endif
			oHtmFile:nWriteLN('</font></td></tr>')
			oHtmFile:nWriteLN('<tr><td>&nbsp;</td></tr>')
		endif

		if(nPersID!=0)
		  	oHtmFile:nWriteLN('<tr><td align="left"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">')
		  	oHtmFile:nWriteLN('<strong>'+STR0030+' </strong>' + aTarefa[1,3] + '</font></td></tr>') //Perspectiva:
			oHtmFile:nWriteLN('<tr><td>&nbsp;</td></tr>')
		elseif(nObjID!=0)
		  	oHtmFile:nWriteLN('<tr><td align="left"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">')
		  	oHtmFile:nWriteLN('<strong>'+STR0031+' </strong>' + aTarefa[1,4] + '</font></td></tr>') //Objetivo:
			oHtmFile:nWriteLN('<tr><td>&nbsp;</td></tr>')
		elseif(nInicID!=0)
		  	oHtmFile:nWriteLN('<tr><td align="left"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">')
		  	oHtmFile:nWriteLN('<strong>'+STR0032+' </strong>' + aTarefa[1,5] + '</font></td></tr>') //Iniciativa:
			oHtmFile:nWriteLN('<tr><td>&nbsp;</td></tr>')
		endif

		// Montagem do corpo do relatório
		oHtmFile:nWriteLN('<tr><td>')
		cSituacao := "ZZZZZZ"
		for nI := 1 to len(aTarefa)
			if(cSituacao != aTarefa[nI,2])
				cSituacao := aTarefa[nI,2]
				if(nI!=1)
					oHtmFile:nWriteLN('</table>') // Fim table 2
					oHtmFile:nWriteLN('</td>')
					oHtmFile:nWriteLN('</tr>')
				  	oHtmFile:nWriteLN('<tr><td>&nbsp;</td></tr>')
					oHtmFile:nWriteLN('<tr><td>')
				endif

				oHtmFile:nWriteLN('<table border="1" cellspacing="0" cellpadding="0" bordercolor="#FFFFFF">') // Inicio table 2
				oHtmFile:nWriteLN('<tr bgcolor="#E2E8F2"><td colspan="8"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>' + cSituacao + '</strong></font></td></tr>')
				oHtmFile:nWriteLN('<tr bgcolor="#ACA6D2">')
				oHtmFile:nWriteLN('<td align="center" width="290"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">'+STR0007+'<br><em>What</em></font></strong></td>')
				oHtmFile:nWriteLN('<td align="center" width="90"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">'+STR0008+'<br><em>When</em></font></strong></td>')
				oHtmFile:nWriteLN('<td align="center" width="120"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">'+STR0009+'<br><em>Who</em></font></strong></td>')
				oHtmFile:nWriteLN('<td align="center" width="120"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">'+STR0010+'<br><em>Where</em></font></strong></td>')
				oHtmFile:nWriteLN('<td align="center" width="120"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">'+STR0011+'<br><em>How</em></font></strong></td>')
				oHtmFile:nWriteLN('<td align="center" width="110"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">'+STR0012+'<br><em>How Much</em></font></strong></td>')
				oHtmFile:nWriteLN('<td align="center" width="120"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">'+STR0013+'<br><em>Why</em></font></strong></td>')
				oHtmFile:nWriteLN('<td align="center" width="80"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">'+STR0014+'<br>'+STR0015+'</font></strong></td>')
				oHtmFile:nWriteLN('</tr>')
			endif
			oHtmFile:nWriteLN('<tr>')

			// O Que (What)
			oHtmFile:nWriteLN('<td width="290" valign="top" bgcolor="#D3D1E9"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">' + cBITagEmpty(aTarefa[nI,06]) + '</font></td>')

			// Quando (When)
			oHtmFile:nWriteLN('<td width="90" valign="top" bgcolor="#E2E1F2">')
			oHtmFile:nWriteLN('<table width="90" border="0" cellpadding="0" cellspacing="0">')
			// Data Inicial
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">'+STR0033+'</font></td>') //Data Inicial
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">' + cBITagEmpty(aTarefa[nI,07]) + '</font></td>')
			oHtmFile:nWriteLN('</tr>')
			// Data Final
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">'+STR0016+'</font></td>') //Data Final
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">' + cBITagEmpty(aTarefa[nI,08]) + '</font></td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table>')
			oHtmFile:nWriteLN('</td>')

			// Pessoas Em Cobranca                    
			oHtmFile:nWriteLN('<td width="120" valign="top" bgcolor="#D3D1E9"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">')
			nPos := ascan(aPesCob,{|x| x[1] == aTarefa[nI,1]})
			for nJ := nPos to len(aPesCob)
				if(aPesCob[nJ,1]==aTarefa[nI,1])
					oHtmFile:nWriteLN(aPesCob[nJ,02] + '<br>')
				endif
			next
			oHtmFile:nWriteLN('</font></td>')
			
			// Para Quem (Where)
			oHtmFile:nWriteLN('<td width="120" valign="top" bgcolor="#E2E1F2"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">' + cBITagEmpty(aTarefa[nI,09]) + '</font></td>')
			
			// Como (How)
			oHtmFile:nWriteLN('<td width="120" valign="top" bgcolor="#D3D1E9"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">' + cBITagEmpty(aTarefa[nI,10]) + '</font></td>')
                        
			// Quanto (How Much)
			oHtmFile:nWriteLN('<td width="110" valign="top" bgcolor="#E2E1F2">')
			oHtmFile:nWriteLN('<table width="110" border="0" cellpadding="0" cellspacing="0">')
			// Custo Estimado
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">'+STR0017+'</font></td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">' + mascara(aTarefa[nI,11] + aTarefa[nI,12] + aTarefa[nI,13]) + '</font></td>')
			oHtmFile:nWriteLN('</tr>')
			// Horas Estimadas
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">'+STR0018+'</font></td>') //Horas Estimadas
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">' + cBITagEmpty(cBIStr(aTarefa[nI,17])) + '</font></td>')
			oHtmFile:nWriteLN('</tr>')
			// Custo Real
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">'+STR0019+'</font></td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">' + mascara(aTarefa[nI,14] + aTarefa[nI,15] + aTarefa[nI,16]) + '</font></td>')
			oHtmFile:nWriteLN('</tr>')
			// Horas Real
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">'+STR0020+'</font></td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">' + cBITagEmpty(cBIStr(aTarefa[nI,18])) + '</font></td>')
			oHtmFile:nWriteLN('</tr>')
			
			oHtmFile:nWriteLN('</table>')
			oHtmFile:nWriteLN('</td>')
			                   
			// Por Que (Why)
			oHtmFile:nWriteLN('<td width="120" valign="top" bgcolor="#D3D1E9"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">' + cBITagEmpty(aTarefa[nI,19]) + '</font></td>')
			
			// Importância/Urgência
			oHtmFile:nWriteLN('<td width="80" valign="top" bgcolor="#D3D1E9" align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">' + cBITagEmpty(aTarefa[nI,20]) + '</font></td>')

			oHtmFile:nWriteLN('</tr>') 
		next
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('</td>')
		oHtmFile:nWriteLN('</tr>')
	
		// Montagem do rodapé do relatório
		oHtmFile:nWriteLN('</table>') // Fim table 1
		
	else
		oHtmFile:nWriteLN('<tr><td align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">'+STR0021+'</font></td></tr>')
		oHtmFile:nWriteLN('<tr><td align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">'+STR0022+'</font></td></tr>')
	endif
	oHtmFile:nWriteLN('</body>')
	oHtmFile:nWriteLN('</html>')

	oHtmFile:lClose()

	oBSCCore:Log(STR0006+cNome+"]", BSC_LOG_SCRFILE) /*"Finalizando geração do relatório ["*/
	::fcMsg := STR0006+cNome+"]"
return

static function mascara(nValor)
return if(nValor==0,"-",transform(nValor,"@E 999,999,999.99"))
                            
function _BSC054_5w2h()
return