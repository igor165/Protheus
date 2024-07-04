// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC017_Ini.prw
// ---------+-----------------------+----------------------------------------------------
// Data     | Autor                 | Descricao
// ---------+-----------------------+----------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli |
// 08.06.09 | 3510 Gilmar P. Santos | FNC: 00000012280/2009
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC017_Ini.ch"

/*--------------------------------------------------------------------------------------
@class TBSC017
@entity Iniciativa
Plano de ação associado a um ou mais objetivos.
@table BSC017
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "INICIATIVA"
#define TAG_GROUP  "INICIATIVAS"
#define TEXT_ENTITY STR0001/*//"Iniciativa"*/
#define TEXT_GROUP  STR0002/*//"Iniciativas"*/

class TBSC017 from TBITable
	method New() constructor
	method NewBSC017()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)
	method oToXMLContextList(nContextID)

	// registro atual
	method oToXMLNode(nParentID)
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	method xVirtualField(cField, xValue)
	method nDuplicate(nParentID, nNewParentID, nNewContextID)  
	method xGetSituacao() 
	method oXMLSitIniciativa() 
	
endclass

method New() class TBSC017
	::NewBSC017()
return
method NewBSC017() class TBSC017
	local oField

	// Table
	::NewTable("BSC017")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(oField := TBIField():New("NOME",		"C",	60))
	oField:lSensitive(.f.)
	::addField(TBIField():New("DESCRICAO",	"C",	255))
	::addField(TBIField():New("DATAINI",	"D"))
	::addField(TBIField():New("DATAFIN",	"D"))
	::addField(TBIField():New("RESPID",		"N"))	// ID de pessoa em cobranca
	::addField(TBIField():New("TIPOPESSOA",	"C",	1)) //G = Grupo, P = Individual
	// Virtual Fields
	oVirtual := TBIField():New("CUSTOEST",	"N")
	oVirtual:bGet({|oTable| oTable:xVirtualField("CUSTOEST")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("CUSTOEST", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("CUSTOREAL",	"N")
	oVirtual:bGet({|oTable| oTable:xVirtualField("CUSTOREAL")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("CUSTOREAL", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("HORASEST",	"N")
	oVirtual:bGet({|oTable| oTable:xVirtualField("HORASEST")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("HORASEST", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("HORASREAL",	"N")
	oVirtual:bGet({|oTable| oTable:xVirtualField("HORASREAL")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("HORASREAL", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("SITUACAO", "C", 20)
	oVirtual:bGet({|oTable| oTable:xVirtualField("SITUACAO")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("SITUACAO", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("NSITUACAO", "N")
	oVirtual:bGet({|oTable| oTable:xVirtualField("NSITUACAO")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("NSITUACAO", xValue)})
	::addField(oVirtual)
	oVirtual := TBIField():New("COMPLETADO", "N")
	oVirtual:bGet({|oTable| oTable:xVirtualField("COMPLETADO")})
	oVirtual:bSet({|oTable, xValue| oTable:xVirtualField("COMPLETADO", xValue)})
	::addField(oVirtual)
	// Indexes
	::addIndex(TBIIndex():New("BSC017I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC017I02",	{"NOME", "CONTEXTID"},	.t.))
	::addIndex(TBIIndex():New("BSC017I03",	{"PARENTID", "ID"},	.t.))  
	::addIndex(TBIIndex():New("BSC017I04",	{"PARENTID"},	.F.)) 
	
return

// xVirtualField
method xVirtualField(cField, xValue) class TBSC017
	local oTable, nTar, xRet := xValue
	if(valtype(xValue)=="U")
		nTar := 0
		xRet := 0
		if(cField=="CUSTOEST")
			oTable := ::oOwner():oGetTable("TAREFA")
			oTable:cSQLFilter("PARENTID = "+::cValue("ID")) // Filtra pelo pai
			oTable:lFiltered(.t.)
			oTable:_First()
			while(!oTable:lEof())
				xRet += oTable:nValue("CE_MAOOBRA")+oTable:nValue("CE_MATERIA")+oTable:nValue("CE_TERCEIR")
				oTable:_Next()
			enddo
			oTable:cSQLFilter("") // Encerra filtro
		elseif(cField=="CUSTOREAL")
			oTable := ::oOwner():oGetTable("TAREFA")
			oTable:cSQLFilter("PARENTID = "+::cValue("ID")) // Filtra pelo pai
			oTable:lFiltered(.t.)
			oTable:_First()
			while(!oTable:lEof())
				xRet += oTable:nValue("CR_MAOOBRA")+oTable:nValue("CR_MATERIA")+oTable:nValue("CR_TERCEIR")
				oTable:_Next()
			enddo
			oTable:cSQLFilter("") // Encerra filtro
		elseif(cField=="HORASEST")
			oTable := ::oOwner():oGetTable("TAREFA")
			oTable:cSQLFilter("PARENTID = "+::cValue("ID")) // Filtra pelo pai
			oTable:lFiltered(.t.)
			oTable:_First()
			while(!oTable:lEof())
				xRet += oTable:nValue("HORASEST")
				oTable:_Next()
			enddo
			oTable:cSQLFilter("") // Encerra filtro
		elseif(cField=="HORASREAL")
			oTable := ::oOwner():oGetTable("TAREFA")
			oTable:cSQLFilter("PARENTID = "+::cValue("ID")) // Filtra pelo pai
			oTable:lFiltered(.t.)
			oTable:_First()
			while(!oTable:lEof())
				xRet += oTable:nValue("HORASREAL")
				oTable:_Next()
			enddo
			oTable:cSQLFilter("") // Encerra filtro
		elseif(cField=="SITUACAO" .or. cField=="NSITUACAO")   
		  	xRet := ::xGetSituacao(cField)
		elseif(cField=="COMPLETADO")
			oTable := ::oOwner():oGetTable("TAREFA")
			oTable:cSQLFilter("PARENTID = "+::cValue("ID")) // Filtra pelo pai
			oTable:lFiltered(.t.)
			oTable:_First()
			while(!oTable:lEof())
				xRet += oTable:nValue("COMPLETADO")
				oTable:_Next()
				nTar++
			enddo
			xRet := round(xRet/nTar, 2)
			oTable:cSQLFilter("") // Encerra filtro
		else
			xRet := 0
		endif
	endif
return xRet


//*** Verifica a sistuação da iniciativa ***//
// Regra:
// Se alguma iniciativa estiver em "Em execução atrasada" então o status será "Em execução atrasada"
// Se não existir nenhuma em "Em execução atrasada" e alguma iniciativa "Em execução" então o status será "Em execução". 
// Se existir somente um tipo de iniciativa o mesmo será respeitado
// Casa contrário status será "Execução com restrição".
method xGetSituacao(cField) class TBSC017 
	local oTable, nTar, xRet , nValida, lExec, lFirstReg                
		oTable := ::oOwner():oGetTable("TAREFA")
		oTable:cSQLFilter("PARENTID = "+::cValue("ID")) // Filtra pelo pai
		oTable:lFiltered(.t.)
		oTable:_First()
		xRet := STR0007 //"Parada"
		nTar := 1        
		nValida := 0
		lExec := .f.    
		lFirstReg := .t.
		while(!oTable:lEof())  
			nValida := oTable:nValue("SITID")  
			if(nValida==6)
				xRet := STR0021 //"Em execução atrasada"
				exit
			elseif(nValida==2) //Em execução
				lExec := .t.
			elseif(lExec == .f.)
				if (lFirstReg)
					nTar := nValida 
					lFirstReg := .f.
				elseif (nTar <> 99 .and. nTar <> nValida )
					nTar := 99							
				endif
			endif           
			oTable:_Next()
		enddo
		oTable:cSQLFilter("") // Encerra filtro  
		if cField=="NSITUACAO"
			if(nValida == 6)  
				xRet := 6				
			elseif(lExec == .t.)
				xRet := 2 
			elseif(nValida == 0)
				xRet := 1
			else
				xRet := nTar
			endif
		else
			if(nValida <> 6)
				if(lExec == .t.)
					xRet := STR0015 //"Em execução"
				elseif (nTar == 99)		
					xRet := STR0016 //"Em aberto com restrição"
				elseif (nTar == 1)		
					xRet := STR0007 //"Parada"			
				elseif (nTar == 3)		
					xRet := STR0008 //"Completada"			
				elseif (nTar == 4)		
					xRet := STR0018 //"Esperando"			
				elseif (nTar == 5)															
					xRet := STR0019 //"Adiada"			
				elseif (nTar == 7)			
					xRet := STR0020 //"Em execução adiantada"
				endif
			endif			
		endif
return xRet



/* Opções de situação da Iniciativa*/
method oXMLSitIniciativa() class TBSC017 
local oAttrib, oNode, oXMLOutput
	
	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("STATUS_INICIATIVA",,oAttrib)
	
    
	//Parada
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("STATUS"))
	oNode:oAddChild(TBIXMLNode():New("ID", 1))
	oNode:oAddChild(TBIXMLNode():New("NOME", "Parada"))
	
	//"Em Execucao
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("STATUS"))
	oNode:oAddChild(TBIXMLNode():New("ID", 2))
	oNode:oAddChild(TBIXMLNode():New("NOME", "Em Execucao"))
	
	//Completada
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("STATUS"))
	oNode:oAddChild(TBIXMLNode():New("ID", 3))
	oNode:oAddChild(TBIXMLNode():New("NOME", "Completada"))
	
	//Esperando
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("STATUS"))
	oNode:oAddChild(TBIXMLNode():New("ID", 4))
	oNode:oAddChild(TBIXMLNode():New("NOME", "Esperando"))
	
	//Adiada
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("STATUS"))
	oNode:oAddChild(TBIXMLNode():New("ID", 5))
	oNode:oAddChild(TBIXMLNode():New("NOME", "Adiada"))
	
	//Em execução atrasada
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("STATUS"))
	oNode:oAddChild(TBIXMLNode():New("ID", 6))
	oNode:oAddChild(TBIXMLNode():New("NOME", "Em execução atrasada"))                                                                  
	
	//Em execução adiantada
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("STATUS"))
	oNode:oAddChild(TBIXMLNode():New("ID", 7))
	oNode:oAddChild(TBIXMLNode():New("NOME", "Em execução adiantada"))

	//Em aberto com restrição
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("STATUS"))
	oNode:oAddChild(TBIXMLNode():New("ID", 99))
	oNode:oAddChild(TBIXMLNode():New("NOME", "Em aberto com restrição"))
	

return oXMLOutput





// Arvore
method oArvore(nParentID) class TBSC017
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
method oToXMLList(nParentID) class TBSC017
	local oNode, oAttrib, oXMLNode, nInd, cTipoPessoa, nRespID
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", BSC_STRING)
	// Data Inicio
	oAttrib:lSet("TAG001", "DATAINI")
	oAttrib:lSet("CAB001", STR0004)/*//"Início"*/
	oAttrib:lSet("CLA001", BSC_DATE)
	// Data Fim
	oAttrib:lSet("TAG002", "DATAFIN")
	oAttrib:lSet("CAB002", STR0005)/*//"Término"*/
	oAttrib:lSet("CLA002", BSC_DATE)
	// Completado
	oAttrib:lSet("TAG003", "COMPLETADO")
	oAttrib:lSet("CAB003", STR0013)/*//"Completado"*/
	oAttrib:lSet("CLA003", BSC_PERCENT)
	//Status
	oAttrib:lSet("TAG004", "SITUACAO")
	oAttrib:lSet("CAB004", STR0014)/*//"Status"*/
	oAttrib:lSet("CLA004", BSC_STRING)
	// Responsavel
	oAttrib:lSet("TAG005", "RESPONSAVEL")
	oAttrib:lSet("CAB005", STR0003)/*//"Responsável"*/
	oAttrib:lSet("CLA005", BSC_STRING)
	
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	::SavePos()
	::SetOrder(2)
	
    If (::lSeek(4,{cBIStr(nParentID)} ) )
	
		while(!::lEof() .And. ::cValue("PARENTID") == cBIStr(nParentID))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","CUSTOEST","CUSTOREAL","HORASEST","HORASREAL"})
			for nInd := 1 to len(aFields)
				if(aFields[nInd][1]=="RESPID") 			// Substituo RESPID por RESPONSAVEL (nome)
					nRespID := aFields[nInd][2]
				elseif(aFields[nInd][1]=="TIPOPESSOA") 	// Substituo RESPID por RESPONSAVEL (nome)
					cTipoPessoa := aFields[nInd][2]
				endif
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			next
			// Virtuais
			if(cTipoPessoa=="G")
				oTable := ::oOwner():oGetTable("PGRUPO")
			else
				oTable := ::oOwner():oGetTable("PESSOA")
			endif
			oTable:lSeek(1, {nRespId})
			oNode:oAddChild(TBIXMLNode():New("RESPONSAVEL", oTable:cValue("NOME")))
			::_Next()
		end 
		
	Endif  
	
	::RestPos()
	
return oXMLNode

// Lista XML para anexar ao Contexto
method oToXMLContextList(nContextID) class TBSC017
	local oNode, oAttrib, oXMLNode, nInd, cTipoPessoa, nRespID
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", BSC_STRING)
	// Responsavel
	oAttrib:lSet("TAG001", "RESPONSAVEL")
	oAttrib:lSet("CAB001", STR0003)/*//"Responsável"*/
	oAttrib:lSet("CLA001", BSC_STRING)
	// Data Inicio
	oAttrib:lSet("TAG002", "DATAINI")
	oAttrib:lSet("CAB002", STR0004)/*//"Início"*/
	oAttrib:lSet("CLA002", BSC_DATE)
	// Data Fim
	oAttrib:lSet("TAG003", "DATAFIN")
	oAttrib:lSet("CAB003", STR0005)/*//"Término"*/
	oAttrib:lSet("CLA003", BSC_DATE)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(2) // Por ordem de nome
	::cSQLFilter("CONTEXTID = "+cBIStr(nContextID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","CUSTOEST","CUSTOREAL","HORASEST","HORASREAL","STATUS","COMPLETADO"})
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1]=="RESPID") // Substituo RESPID por RESPONSAVEL (nome)
				nRespID := aFields[nInd][2]
			elseif(aFields[nInd][1]=="TIPOPESSOA") // Substituo RESPID por RESPONSAVEL (nome)
				cTipoPessoa := aFields[nInd][2]
			endif
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		// Virtuais
		if(cTipoPessoa=="G")
			oTable := ::oOwner():oGetTable("PGRUPO")
		else
			oTable := ::oOwner():oGetTable("PESSOA")
		endif
		oTable:lSeek(1, {nRespId})
		oNode:oAddChild(TBIXMLNode():New("RESPONSAVEL", oTable:cValue("NOME")))
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

/*Carregar*/
method oToXMLNode(nParentID) class TBSC017
	Local aFields, aGrupos 
	Local nInd, nID, nRespID
	Local cTipoPessoa
	Local oTable, oPessoa, oPessoaXGrupo
      
	Local oXMLNode 		:= TBIXMLNode():New(TAG_ENTITY)
	Local lIsAdmin 		:= ::oOwner():foSecurity:oLoggedUser():lValue("ADMIN") /*Idenfifica se o usuário é ADMINISTRADOR.*/
	Local nCurrentUser 	:= ::oOwner():foSecurity:oLoggedUser():nValue("ID") /*Recupera o id do usuário CORRENTE.*/
	Local lIsResp 		:= .F.

	/*Acrescenta os valores ao XML*/
	aFields := ::xRecord(RF_ARRAY) 
	
	for nInd := 1 to len(aFields)  
	
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		elseif(aFields[nInd][1]=="RESPID") 
			nRespID := aFields[nInd][2]
		elseif(aFields[nInd][1]=="TIPOPESSOA") 
			cTipoPessoa := aFields[nInd][2]
		endif	
	next	
	
	/*Substitue RESPID pelo NOME do RESPONSAVEL [PESSOA ou GRUPO de PESSOAS]*/
	oTable	:= ::oOwner():oGetTable(Iif(cTipoPessoa == "G","PGRUPO","PESSOA"))
	oTable:lSeek(1, {nRespId})
	oXMLNode:oAddChild(TBIXMLNode():New("RESPONSAVEL", oTable:cValue("NOME")))
	
	oTable := self
	
	if(nID == 0)
		oTable := ::oOwner():oGetTable("OBJETIVO")
		oTable:lSeek(1, {nParentID})
	endif*
	       
	/*Identifica se o usuário corrente é o RESPONSAVEL pela iniciativa.*/                                                                                                     
    If (cTipoPessoa == "G")   
    	/*Localiza a PESSOA correspondente ao usuário corrente.*/
    	oPessoa := ::oOwner():oGetTable("PESSOA")
    	oPessoa:lSeek(4, {nCurrentUser})
    	/*Recupera os grupos que a PESSOA localizada pertence.*/	                  
    	oPessoaXGrupo := ::oOwner():oGetTable("GRPXPESSOA")       
    	aGrupos := oPessoaXGrupo:aGroupsByPerson(oPessoa:nValue("ID"))    
       	lisResp := aScan(aGrupos, nRespID) > 0
    Else
   		/*Localiza o USUARIO corrente na tebala de PESSOAS e compara com o ID do RESPONSAVEL*/
   	 	oPessoa := ::oOwner():oGetTable("PESSOA")
   	 	oPessoa:lSeek(4, {nCurrentUser})   	 	
   	   	 
   	   	/*Realiza o tratamento para a condição de um usuário estar relacionado com mais de uma PESSOA.*/
   	   	While (!oPessoa:lEof() .And. oPessoa:nValue("USERID") == nCurrentUser) 
   	 		If(oPessoa:nValue("ID") == nRespID)
   	 			lIsResp := .T.
   	 		EndIf
   	 	
   	 		oPessoa:_Next()   	 	
   	 	EndDo       
    EndIF             
	
	oXMLNode:oAddChild(::oOwner():oGetTable("INIDOC"):oToXMLList(nID))
	oXMLNode:oAddChild(::oOwner():oGetTable("TAREFA"):oToXMLList(nID))
	oXMLNode:oAddChild(TBIXMLNode():New("ADMINISTRADOR"	, Iif(lIsAdmin	, "T", "F"))) 
	oXMLNode:oAddChild(TBIXMLNode():New("ISRESP"		, Iif(lIsResp	, "T", "F"))) 
	oXMLNode:oAddChild(::oOwner():oContext(self, nParentID))

return oXMLNode                                                                       

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC017
	local aFields, nInd, nStatus := BSC_ST_OK
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
method nUpdFromXML(oXML, cPath) class TBSC017
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
method nDelFromXML(nID) class TBSC017
	local nStatus := BSC_ST_OK, oTableChild
	
	::oOwner():oOltpController():lBeginTransaction()

	// Procura por children (Documentos)
	oTableChild:= ::oOwner():oGetTable("INIDOC")
	oTableChild:SetOrder(3) // Por ordem de ParentId
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo paI
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("INIDOC"):nDelFromXML(oTableChild:nValue("ID"))
		oTableChild:_Next()
	enddo
	oTableChild:cSQLFilter("") // Limpa o filtro

	// Procura por children (Tarefas)
	oTableChild:= ::oOwner():oGetTable("TAREFA")
	oTableChild:SetOrder(3) // Por ordem de ParentId
	oTableChild:cSQLFilter("PARENTID = "+cBIStr(nID)) // Filtra pelo paI
	oTableChild:lFiltered(.t.)
	oTableChild:_First()
	while(!oTableChild:lEof() .and. nStatus == BSC_ST_OK)
		nStatus := ::oOwner():oGetTable("TAREFA"):nDelFromXML(oTableChild:nValue("ID"))
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
method nDuplicate(nParentID, nNewParentID, nNewContextID) class TBSC017
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
			nStatus := ::oOwner():oGetTable("INIDOC"):nDuplicate(nOldId, nID, nNewContextID)
			if(nStatus == BSC_ST_OK)
				nStatus := ::oOwner():oGetTable("TAREFA"):nDuplicate(nOldId, nID, nNewContextID)
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

/****************************************************************************/
//funçao para notificar sobre a atraso na reunião, tem a mesma função que o metodo    */
//nExecute porém o start é pelo Job do TBSC082 que descende de TBIScheduler */
/****************************************************************************/
function notifyDelay(aParam)
	local nStatus := BSC_ST_OK, aTo := {}, i, lCompleta:= .f., cSituacao := ""
	local cServer, cPorta, cConta, cAutUsuario, cAutSenha, cTo := "", cAssunto, cCorpo
	local oOrganizacao, oEstrategia, oPerspectiva, oIniciativa, oConexao, oPessoas, oGrupo, oTarefa
	local dHoje := date(), cNome := "", nTar := 0
	local cMsgAVenc		:= if( len( aParam ) > 1 .AND. !Empty( aParam[2] ), aParam[2], STR0010 ) //AVISO DE INICIATIVAS A VENCER EM ATÉ 7 DIAS
	local cMsgVencida	:= if( len( aParam ) > 2 .AND. !Empty( aParam[3] ), aParam[3], STR0009 ) //AVISO DE INICIATIVAS VENCIDAS
	local cPath			:= if( len( aParam ) > 0 .AND. !Empty( aParam[1] ), aParam[1], "\" )
	
	public oBSCCore, cBSCErrorMsg := ""

	oBSCCore := TBSCCore():New(cPath) //environment
	if(oBSCCore:nDBOpen() < 0)
		oBSCCore:Log(cBIMsgTopError(nTopError), BSC_LOG_SCRFILE)
		oBSCCore:Log("  ")
		return
	endif
	ErrorBlock( {|oE| __BSCError(oE)})

	set exclusive off
	set talk off
	set scoreboard off
	set date brit
	set epoch to 1960
	set century on
	set cursor on
	set deleted on

	oOrganizacao := oBSCCore:oGetTable("ORGANIZACAO")
	oEstrategia := oBSCCore:oGetTable("ESTRATEGIA")
	oPerspectiva := oBSCCore:oGetTable("PERSPECTIVA")
	oConexao := oBSCCore:oGetTable("SMTPCONF")
	oPessoas := oBSCCore:oGetTable("PESSOA")
	oIniciativa := oBSCCore:oGetTable("INICIATIVA")
	oGrupo   := oBSCCore:oGetTable("GRPXPESSOA")
	oTarefa := oBSCCore:oGetTable("TAREFA")

	oIniciativa:cSQLFilter("DATAFIN <= '"+cBiStr(dTos(dHoje+7))+"'") // Filtra as vencidas e a vencer em 7 dias
	oIniciativa:lFiltered(.t.)
	oIniciativa:_First()
	if(!oIniciativa:lEof())
		//posiciona na configuração de email
		oConexao:cSQLFilter("ID = "+cBIStr(1)) // Filtra o ID 1 onde tem a configuracao SMTP
		oConexao:lFiltered(.t.)
		oConexao:_First()
		if(!oConexao:lEof())
			cServer		:= alltrim(oConexao:cValue("SERVIDOR"))
			cPorta		:= alltrim(oConexao:cValue("PORTA"))
			cConta		:= alltrim(oConexao:cValue("NOME"))
			cAutUsuario	:= alltrim(oConexao:cValue("USUARIO"))
			cAutSenha	:= alltrim(oConexao:cValue("SENHA"))
		endif

		while(!oIniciativa:lEof() .and. !oConexao:lEof()) //posiciona cfg. da organização
		//.and. validaSituacao()
			cNome := ""
			oTarefa:cSQLFilter("PARENTID = "+oIniciativa:cValue("ID")) // Filtra pelo pai
			oTarefa:lFiltered(.t.)
			oTarefa:_First()
			cSituacao := STR0007 //"Parada"
			nTar := 3
			while(!oTarefa:lEof())
				nValida := oTarefa:nValue("SITID")
				if(nValida==2)
					cSituacao := STR0006 //"Em execução"
					exit
				endif	
				if(nValida==3 .and. nTar==3) //se todos = 3
					cSituacao := STR0008 //"Completada"
					lCompleta := .t.
				else
					nTar := if(nValida==3,nTar,nValida)
					cSituacao := STR0007 //"Parada"
				endif
				oTarefa:_Next()
			enddo
			oTarefa:cSQLFilter("") // Encerra filtro

			// inclusao do email da Pessoa responsavel ou do Grupo de pessoas responsaveis
			if(oIniciativa:cValue("TIPOPESSOA") == "G") //grupo de pessoas
				aTo := oGrupo:aPersonsByGroup(oIniciativa:nValue("RESPID"))
				cTo := ""
				for i := 1 to len(aTo)
					if(oPessoas:lSeek(1, {aTo[i]}))
						cTo += if(empty(cTo),"",",")+alltrim(oPessoas:cValue("EMAIL"))
						cNome += if(empty(cNome),"",",")+alltrim(oPessoas:cValue("NOME"))
					endif
				next
			else
				if(oPessoas:lSeek(1, {oIniciativa:nValue("RESPID")}))
					cTo		:= alltrim(oPessoas:cValue("EMAIL"))
					cNome += alltrim(oPessoas:cValue("NOME"))
				endif
			endif
			if(!lCompleta)
				if(oIniciativa:dValue("DATAFIN") > dHoje)
					cAssunto := cMsgAVenc //"AVISO DE INICIATIVAS A VENCER EM ATÉ 7 DIAS"
				else
					cAssunto := cMsgVencida //"AVISO DE INICIATIVAS VENCIDAS"
				endif

				cCorpo		:= TEXT_ENTITY+": " + alltrim(oIniciativa:cValue("NOME"))+'<br>'
				cCorpo		+= '<br>'
				cCorpo		+= STR0011+": "+ alltrim(oIniciativa:cValue("DESCRICAO"))+ '<br>'
				cCorpo		+= STR0004+": "+ oIniciativa:cValue("DATAINI")+'<br>'
				cCorpo		+= STR0005+": "+ oIniciativa:cValue("DATAFIN")+'<br>'
				cCorpo		+= '<br>'
				cCorpo		+= STR0012+": "+ cSituacao
				oConexao:SendMail(cServer, cPorta, cConta, cAutUsuario, cAutSenha, cTo, cAssunto, cCorpo, "")
			endif
			oIniciativa:_Next()
			lCompleta := .f.
		enddo
		oConexao:cSQLFilter("") // Retira filtro
	else
		nStatus := 	BSC_ST_BADID
	endif

return nStatus  

function _BSC017_Ini()
return

