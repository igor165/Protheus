// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC015E_Con.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 18.06.06 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC015E_Con.ch"

/*--------------------------------------------------------------------------------------
@class TBSC015E
@entity DataSource
Cadastro de consultas do DW para acesso no BSC.
@table BSC015E
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "DWCONSULTA"
#define TAG_GROUP  "DWCONSULTAS"
#define TEXT_ENTITY STR0001/*//"Consulta do DW"*/
#define TEXT_GROUP  STR0002/*//"Consultas do DW"*/

class TBSC015E from TBITable
	method New() constructor
	method NewBSC015E()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)

	// registro atual
	method oToXMLNode(nParentID,cRequest)
	method nInsFromXML(oXML,nParentID,nContextID)
	method nUpdFromXML(oXML,nParentID,nContextID)
	method nDelFromXML(oXML)

	
	// executar 
	method nDuplicate(nParentID, nNewParentID, nNewContextID)
	method nExecute(nID, cExecCMD, cArquivo)
	method lInsDetCons(oObjDW,oXMLCons,cSessao,nConsID)	
	
endclass

method New() class TBSC015E
	::NewBSC015E()
return
method NewBSC015E() class TBSC015E
	// Table
	::NewTable("BSC015E")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"			,"N"))
	::addField(TBIField():New("PARENTID"	,"N"))
	::addField(TBIField():New("CONTEXTID"	,"N"))
	::addField(TBIField():New("IDCONS"		,"N"))//Id consulta do dw
	::addField(TBIField():New("URL"			,"C",255))	
	::addField(TBIField():New("DW"			,"C",020))
	::addField(TBIField():New("CONSULTA"	,"C",020))
	
	// Indexes
	::addIndex(TBIIndex():New("BSC015EI01",{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC015EI02",{"PARENTID"},.f.))
	
return

// Arvore
method oArvore(nParentID) class TBSC015E
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
method oToXMLList(nParentID) class TBSC015E
	local aFields, oNode, oAttrib, oXMLNode, nInd

	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	
	//URL
	oAttrib:lSet("TAG000", "URL")
	oAttrib:lSet("CAB000", "URL")
	oAttrib:lSet("EDT000", "F")
	oAttrib:lSet("CUM000", "F")
	oAttrib:lSet("CLA000", BSC_STRING)

	//DW
	oAttrib:lSet("TAG001", "DW")
	oAttrib:lSet("CAB001", STR0003) //"DataWareHouse"
	oAttrib:lSet("EDT001", "F")
	oAttrib:lSet("CUM001", "F")		
	oAttrib:lSet("CLA001", BSC_STRING)

	//CONSULTA
	oAttrib:lSet("TAG002", "CONSULTA")
	oAttrib:lSet("CAB002", STR0004) //"Consulta"
	oAttrib:lSet("CUM002", "F")	
	oAttrib:lSet("EDT002", "F")	
	oAttrib:lSet("CLA002", BSC_STRING)

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	//Gera o conteudo
	::SetOrder(2) // Por ordem de nome
	if(!empty(nParentID))
		::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	else
		::cSQLFilter("PARENTID > 0 ")
	endif
	
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro

return oXMLNode

// Carregar
method oToXMLNode(nParentID,cRequest) class TBSC015E
	local aRequest 	:=	aBIToken(cRequest,"|",.f.)	
	local oXMLNode 	:=	TBIXMLNode():New(TAG_ENTITY)
	local oObjDW	:=	WSSIGADW():New()
	local oUser		:=	::oOwner():foSecurity:oLoggedUser()
	local oDWs		:=	nil
	local oXMLNodeDW:=	nil
	local oXMLQuery	:=	nil
	local oNode		:=	nil
	local oNodeQuery:=	nil
	local oListQuery:=	nil
	local nDw		:= 	0
	local nParentID	:=	0
	local nQuery	:=	0
	local cUrl		:=	""
	local cDw		:=	""	
	local cSessao	:=	""
	local cDwRequest:=	"" 
	local cUrlWsDw	:=  getJobProfString("URLWSDW", "http://localhost/dw/SIGADW.apw")//Endereco do web service do dw
	local lDetConsul:=	.f.

	oObjDW:_URL := cUrlWsDw
	
	do case
		case aRequest[1] == "REQ_DWLISTA"
			nParentID	:=	aRequest[2]
			oXMLNode:oAddChild(::oToXmlList(nParentID))
		case aRequest[1] == "REQUEST_DWACCESS"
			cUrl:= lower(aRequest[2])
			cDw	:=	aRequest[3]
			cDwRequest	:= dwEncodeParm("dwacesss",DWConcatWSep("!", {"http://"+lower(alltrim(cUrl)), alltrim(cDw), padr(oUser:cValue("NOME"),25), time() }))
			oXMLNode:oAddChild(TBIXMLNode():New("REQUEST" 	, cDwRequest))
		case aRequest[1] == "REQ_DATAWAREHOUSE"
			lDetConsul	:=	aRequest[3] == "true"
			oXMLNodeDW	:=	TBIXMLNode():New(TAG_GROUP)	
			//Logando no DW				
			oObjDW:LOGIN(alltrim(aRequest[2]),"","BSCADMIN","BSC")
			cSessao	:=	oObjDW:CLOGINRESULT
			//Requisitando a lista dos DataWareHouse
			oObjDW:RETDW(cSessao)
   			oDWs 	:= oObjDW:OWSRETDWRESULT:OWSDWLIST
			for nDw = 1 to len(oDWs)
				//Criando o no DataWareHouse
				oNode  	:= oXMLNodeDW:oAddChild(TBIXMLNode():New(TAG_ENTITY))
				oNode:oAddChild(TBIXMLNode():New("ID" 	,nDw))
				oNode:oAddChild(TBIXMLNode():New("NOME",oDWs[nDw]:CNAME))
				
				//Acessando o DW				
				oObjDW:LOGINDW(alltrim(cSessao),alltrim(oDWs[nDw]:CNAME))
				if(oObjDW:LLOGINDWRESULT)
					//Requisitando as consultas do DW logado.
					oObjDW:LISTCONSULTAS(cSessao, cBIStr(oDWs[nDw]:nID))
					if len(oObjDW:OWSLISTCONSULTASRESULT:OWSQUERYLIST) >0
						oListQuery	:=	oObjDW:OWSLISTCONSULTASRESULT:OWSQUERYLIST
						oXMLQuery 	:=	oNode:oAddChild(TBIXMLNode():New("QUERY_LISTS"))
						
						for nQuery := 1 to len(oListQuery)
							oNodeQuery 	:=	oXMLQuery:oAddChild(TBIXMLNode():New("QUERY_LIST"))
							oNodeQuery:oAddChild(TBIXMLNode():New("ID" 	,oListQuery[nQuery]:CID))
							oNodeQuery:oAddChild(TBIXMLNode():New("NOME",oListQuery[nQuery]:CNAME))
							//Estrutura da consulta.
							if(lDetConsul)
								::lInsDetCons(oObjDW,oNodeQuery,cSessao,val(oListQuery[nQuery]:CID))
							endif
						next nQuery
					endif
				endif					
			next nDw 
			oObjDW:LOGOUT(cSessao)
			oXMLNode:oAddChild(oXMLNodeDW)
		otherwise		
	endcase		
	
return oXMLNode     

/*
*Insere os campos de Data e Indicador do DW na consulta.
*/
method lInsDetCons(oObjDW,oXMLCons,cSessao,nConsID) class TBSC015E
	local lgetStruCon	:=	oObjDW:RETCONSULTA(cSessao,nConsID,.f.)
	local oXMLDatas 	:=	oXMLCons:oAddChild(TBIXMLNode():New("DATAS"))
	local oXMLInds		:=	oXMLCons:oAddChild(TBIXMLNode():New("INDICADORES"))
	local oXMLData		:=	nil
	local oXMLInd		:=	nil
	local nItens		:=	0		
	local aFieldsX	:=	{}   
	local aFieldsY	:=	{}   
	local aIndicador:=	{}

	if(lgetStruCon)
		aFieldsX	:=	oObjDW:OWSRETCONSULTARESULT:OWSCONSULTASTRU[1]:OWSFIELDSX:OWSFIELDSDET
		aFieldsY	:=	oObjDW:OWSRETCONSULTARESULT:OWSCONSULTASTRU[1]:OWSFIELDSY:OWSFIELDSDET
		aIndicador	:=	oObjDW:OWSRETCONSULTARESULT:OWSCONSULTASTRU[1]:OWSMEASURES:OWSFIELDSDET		
		//Adicionando os campos do tipo data						
		for nItens := 1 to len(aFieldsX)
			if(aFieldsX[nItens]:CTYPE == "D")
				oXMLData 	:=	oXMLDatas:oAddChild(TBIXMLNode():New("CPO_DATA"))
				oXMLData:oAddChild(TBIXMLNode():New("ID" 	,aFieldsX[nItens]:CID))
				oXMLData:oAddChild(TBIXMLNode():New("NOME" 	,aFieldsX[nItens]:CNAME))
			endif			
		next nItens		

		for nItens := 1 to len(aFieldsY)
			if(aFieldsY[nItens]:CTYPE == "D" .and. aFieldsY[nItens]:CTEMPORAL == "0")
				oXMLData 	:=	oXMLDatas:oAddChild(TBIXMLNode():New("CPO_DATA"))
				oXMLData:oAddChild(TBIXMLNode():New("ID" 	,aFieldsY[nItens]:CID))
				oXMLData:oAddChild(TBIXMLNode():New("NOME" 	,aFieldsY[nItens]:CNAME))
			endif			
		next nItens		
		
		for nItens := 1 to len(aIndicador)
			if(aIndicador[nItens]:CTYPE == "N")
				oXMLInd 	:=	oXMLInds:oAddChild(TBIXMLNode():New("CPO_DATA"))
				oXMLInd:oAddChild(TBIXMLNode():New("ID" 	,aIndicador[nItens]:CID))
				oXMLInd:oAddChild(TBIXMLNode():New("NOME" 	,aIndicador[nItens]:CNAME))		
			endif
		next nItens		
	endif		
	
return .t.

// Insere nova entidade
method nInsFromXML(oXML,nParentID,nContextID) class TBSC015E
	local aFields	:=	{}
	local aIndTend	:=	{}
	local nInd		:=	0
	local nStatus 	:=	BSC_ST_OK	
	private oXMLInput	:= oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID","PARENTID","CONTEXTID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))
	next

	if nStatus == BSC_ST_OK
		aAdd(aFields, {"ID"			, ::nMakeID()})
		aAdd(aFields, {"PARENTID"	, nParentID})	
		aAdd(aFields, {"CONTEXTID"	, nContextID})	
		
		// Grava
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif	
	endif

return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML,nParentID,nContextID) class TBSC015E
	local aFields, nInd, nStatus := BSC_ST_OK, aIndTend,nQtdReg:=0
	local lAddNew := .F.
	local lValorPrevio	:= .f.

	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID"})
	
	// Extrai valores do XML
	for nInd := 1 to len(aFields)

		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))

		if(aFields[nInd][1] == "ID" .and. aFields[nInd][2] == -99)
			aFields[nInd][2]:= ::nMakeID()
			lAddNew := .T.
		endif
	next

	//Faz a gravacao dos dados.
	if(lAddNew .and. nStatus == BSC_ST_OK)
		//Adiciona um novo registro.		
		aAdd(aFields, {"PARENTID"	, nParentID})	
		aAdd(aFields, {"CONTEXTID"	, nContextID})			
		// Grava
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif	
	elseif(nStatus == BSC_ST_OK)
		/*Atualiza os registros existentes.
		  Para esta entidade nao e necessaria a atualizacao do registro ja existente.
		*/
		/*
		if(!::lSeek(1, {cCodID}))
			nStatus := BSC_ST_BADID
		else       
			//Gravacao do Indicador
			
			if(!::lUpdate(aFields))
				if(::nLastError()==DBERROR_UNIQUE)
					nStatus := BSC_ST_UNIQUE
				else
					nStatus := BSC_ST_INUSE
				endif
			endif	
		endif		
		*/
	endif

return nStatus

// Excluir entidade do server
method nDelFromXML(oXML) class TBSC015E
	local aFields	:=	{}
	local nInd		:=	0
	local nStatus 	:= 	BSC_ST_OK,cCodID
	local nID		:=	0

	private oXMLInput:= oXML

	aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","IDCONS","URL","DW","CONSULTA"})
	
	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		if(aFields[nInd][1] == "ID")
			cType := ::aFields(aFields[nInd][1]):cType()
			aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))
			nID := aFields[nInd][2]
			exit
		endif	
	next

	//Exclui o elemento.
	if(::lSeek(1,{nID}))
		if(!::lDelete())
			nStatus := BSC_ST_INUSE
		endif
	else
		nStatus := BSC_ST_BADID
	endif	

return nStatus

// Duplica os registros filhos de nParentID, colocando-os como filhos de nNewParentID do contexto nNewContextID
method nDuplicate(nParentID, nNewParentID, nNewContextID) class TBSC015E
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

// Execute
method nExecute(nID, cExecCMD) class TBSC015E
	local nStatus := BSC_ST_OK

return nStatus      

function _BSC015e_Con()
return