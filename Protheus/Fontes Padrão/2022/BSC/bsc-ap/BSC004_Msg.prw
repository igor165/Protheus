// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC004_Msg.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 17.11.04 | 1645 Leandro Marcelino Santos
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC004_Msg.ch"

/*--------------------------------------------------------------------------------------
@entity Mensagens
Mensagens no BSC. Contém mensagens enviadas aos usuários do BSC.
@table BSC004
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "MENSAGEM"
#define TAG_GROUP  "MENSAGENS"
#define TEXT_ENTITY STR0001/*//"Mensagem"*/
#define TEXT_GROUP  STR0002/*//"Mensagens"*/

class TBSC004 from TBITable
	method New() constructor
	method NewBSC004()

	// diversos registros
	method oToXMLList(nParentID, nCommand)
	method aPeopleByUser(nUserID)

	// registro atual
	method oToXMLNode(nDestID, cLoadCMD)
	method nInsFromXML(oXML, cPath)
	method nDelFromXML(nID)

endclass
	
method New() class TBSC004
	::NewBSC004()
return
method NewBSC004() class TBSC004
	local oField
	
	// Table
	::NewTable("BSC004")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N")) // ID da Pessoa Remetente
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(oField := TBIField():New("NOME",	"C",	255))
	oField:lSensitive(.f.)
	::addField(TBIField():New("TEXTO",		"M"))
	::addField(TBIField():New("ANEXO",		"C", 255))
	::addField(TBIField():New("DATAENV",	"D"))
	::addField(TBIField():New("HORAENV",	"C", 008))
	::addField(TBIField():New("ANEXO",		"C", 255))
	::addField(TBIField():New("PRIORIDADE",	"N")) // 5.Alta 6.Normal 7.Baixa
	::addField(TBIField():New("PASTA",		"N")) // 1.Enviado 3.Excluido 4.Excluido Definitivamente
	
	// Indexes
	::addIndex(TBIIndex():New("BSC004I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC004I02",	{"NOME", "CONTEXTID"},	.f.))
	::addIndex(TBIIndex():New("BSC004I03",	{"PARENTID", "ID"},	.t.))
	::addIndex(TBIIndex():New("BSC004I04",	{"DATAENV", "HORAENV"}, .f.))

return

// Lista XML para anexar ao pai
method oToXMLList(nParentID, nCommand) class TBSC004
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", STR0003) //"Assunto"
	oAttrib:lSet("CLA000", BSC_STRING)
	// Data
	oAttrib:lSet("TAG001", "DATAENV")
	oAttrib:lSet("CAB001", STR0004) //"Data Envio"
	oAttrib:lSet("CLA001", BSC_DATE)
	// Hora
	oAttrib:lSet("TAG002", "HORAENV")
	oAttrib:lSet("CAB002", STR0005) //"Hora Envio"
	oAttrib:lSet("CLA002", BSC_STRING)
	if(nCommand == 2) //Caixa de Entrada
		// Hora
		oAttrib:lSet("TAG003", "PRIORIDADE")
		oAttrib:lSet("CAB003", STR0006) //"Prioridade"
		oAttrib:lSet("CLA003", BSC_STRING)
	endif

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)

	// Gera recheio  
	oDestinatario := ::oOwner():oGetTable("DESTINATARIO")
	if(nCommand == BSC_MSG_ENVIADA)
		::SetOrder(4)
		::cSQLFilter("PARENTID IN (" + cBIConcatWSep(",", ::aPeopleByUser(::oOwner():foSecurity:oLoggedUser():nValue("ID"), nParentID)) + ") AND PASTA = " + cBIStr(BSC_MSG_ENVIADA))
		::lFiltered(.t.)
		::_First()
		while(!::lEof())
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"ID", "PARENTID", "CONTEXTID"})
			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))			
			next
			oDestinatario:SetOrder(2)
			oDestinatario:lSeek(3, {::nValue("ID"), BSC_MSG_REMETENTE})
			oNode:oAddChild(TBIXMLNode():New("ID", oDestinatario:nValue("ID")))
			::_Next()
		end
		::cSQLFilter("")
	elseif(nCommand == BSC_MSG_RECEBIDA)
		oDestinatario:cSQLFilter("PESSID IN (" + cBIConcatWSep(",", ::aPeopleByUser(::oOwner():foSecurity:oLoggedUser():nValue("ID"), nParentID)) + ") AND PASTA = " + cBIStr(BSC_MSG_RECEBIDA) + " AND REMETENTE = " + cBIStr(BSC_MSG_DESTINATARIO)) 
		oDestinatario:lFiltered(.t.)
		oDestinatario:_First()
		while(!oDestinatario:lEof())
		
			::lSeek(1,{oDestinatario:nValue("PARENTID")})

			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"ID", "PARENTID","CONTEXTID"})
			for nInd := 1 to len(aFields)
				if(aFields[nInd][1]=="PRIORIDADE")
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1],;
						if(aFields[nInd][2]==BSC_MSG_BAIXA, STR0007,; //Baixa
						if(aFields[nInd][2]==BSC_MSG_MEDIA, STR0008, STR0009)))) //Média / Alta
				else
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
				endif
			next
			oNode:oAddChild(TBIXMLNode():New("ID", oDestinatario:nValue("ID")))
	
			oDestinatario:_Next()
		end
		oDestinatario:cSQLFilter("")
	elseif(nCommand == BSC_MSG_EXCLUIDA)
		oDestinatario:cSQLFilter("PESSID IN (" + cBIConcatWSep(",", ::aPeopleByUser(::oOwner():foSecurity:oLoggedUser():nValue("ID"), nParentID)) + ") AND PASTA = " + cBIStr(BSC_MSG_EXCLUIDA))
		oDestinatario:lFiltered(.t.)
		oDestinatario:_First()
		while(!oDestinatario:lEof())
		
			::lSeek(1,{oDestinatario:nValue("PARENTID")})

			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"ID", "PARENTID","CONTEXTID"})
			for nInd := 1 to len(aFields)
				if(aFields[nInd][1]=="PRIORIDADE")
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1],;
						if(aFields[nInd][2]==BSC_MSG_BAIXA, STR0007,; //Baixa
						if(aFields[nInd][2]==BSC_MSG_MEDIA, STR0008, STR0009)))) //Média / Alta
				else
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
				endif
			next
			oNode:oAddChild(TBIXMLNode():New("ID", oDestinatario:nValue("ID")))
	
			oDestinatario:_Next()
		end
		oDestinatario:cSQLFilter("")
	endif
return oXMLNode

// Carregar
method oToXMLNode(nDestID, cLoadCMD) class TBSC004
	local nID, aFields, nInd, oDestinatario
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	nID := 0
	if(cBIStr(cLoadCMD) != "_BLANK")
		oDestinatario := ::oOwner():oGetTable("DESTINATARIO")
		oDestinatario:lSeek(1,{nDestID})
		nID := oDestinatario:nValue("PARENTID")
		::lSeek(1, {nID})
    endif
    
	// Acrescenta os valores ao XML
	if(cBIStr(cLoadCMD) != "_BLANK")
		aFields := ::xRecord(RF_ARRAY,{"PASTA"})
	else
		aFields := ::xRecord(RF_ARRAY)
	endif
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
	next   
	if(cBIStr(cLoadCMD) != "_BLANK")
		oXMLNode:oAddChild(TBIXMLNode():New("PASTA", oDestinatario:nValue("PASTA")))
	endif
                                        
	oPessoa := ::oOwner():oGetTable("PESSOA")
	
	//Cria lista de remetentes
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("TIPO", "PESSOA")
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", STR0010 /*Nome*/)
	oAttrib:lSet("CLA000", BSC_STRING)
	oAttrib:lSet("RETORNA", .f.)
	oNode1 := oXMLNode:oAddChild(TBIXMLNode():New("REMETENTES",,oAttrib))
	if(nID==0)	
		//Se for envio de uma nova mensagem, cria lista de remetentes com as pessoas vinculadas ao usuário logado
		oPessoa:cSQLFilter("USERID = " + cBIStr(::oOwner():foSecurity:oLoggedUser():nValue("ID"))+" AND PARENTID = " + cBIStr(nDestID))
	else
		//Se leitura de uma mensagem, cria lista somente a pessoa remetente
		oPessoa:cSQLFilter("ID = " + cBIStr(::nValue("PARENTID")))
	endif
	oPessoa:lFiltered(.t.)
	oPessoa:_First()
	while(!oPessoa:lEof())
		oNode2 := oNode1:oAddChild(TBIXMLNode():New("PESSOA"))
		oNode2:oAddChild(TBIXMLNode():New("USERID", oPessoa:nValue("USERID")))
		oNode2:oAddChild(TBIXMLNode():New("ID", oPessoa:nValue("ID")))
		oNode2:oAddChild(TBIXMLNode():New("NOME", oPessoa:cValue("NOME")))
		oPessoa:_Next()
	end
	oPessoa:cSQLFilter("")

	//Cria lista de remetentes Auxiliar
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("TIPO", "PESSOA")
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", STR0010 /*Nome*/)
	oAttrib:lSet("CLA000", BSC_STRING)
	oAttrib:lSet("RETORNA", .f.)
	oNode1 := oXMLNode:oAddChild(TBIXMLNode():New("REMS",,oAttrib))
	oPessoa:cSQLFilter("USERID = " + cBIStr(::oOwner():foSecurity:oLoggedUser():nValue("ID"))+" AND PARENTID = " + cBIStr(nDestID))
	oPessoa:lFiltered(.t.)
	oPessoa:_First()
	while(!oPessoa:lEof())
		oNode2 := oNode1:oAddChild(TBIXMLNode():New("PESSOA"))
		oNode2:oAddChild(TBIXMLNode():New("USERID", oPessoa:nValue("USERID")))
		oNode2:oAddChild(TBIXMLNode():New("ID", oPessoa:nValue("ID")))
		oNode2:oAddChild(TBIXMLNode():New("NOME", oPessoa:cValue("NOME")))
		oPessoa:_Next()
	end
	oPessoa:cSQLFilter("")

	//Cria lista de destinatarios Auxiliar
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("TIPO", "PESSOA")
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", STR0010 /*Nome*/)
	oAttrib:lSet("CLA000", BSC_STRING)
	oAttrib:lSet("RETORNA", .f.)
	oNode1 := oXMLNode:oAddChild(TBIXMLNode():New("DESTS",,oAttrib))
	oPessoa:cSQLFilter("USERID != " + cBIStr(::oOwner():foSecurity:oLoggedUser():nValue("ID")) + " AND ID != 0 AND PARENTID = " + cBIStr(nDestID))
//	oPessoa:cSQLFilter("USERID != " + cBIStr(::oOwner():foSecurity:oLoggedUser():nValue("ID"))  +;
//					   " AND ID != 0 AND ID != " + cBIStr(nDestID))
	oPessoa:lFiltered(.t.)
	oPessoa:_First()
	while(!oPessoa:lEof())
		oNode2 := oNode1:oAddChild(TBIXMLNode():New("PESSOA"))
		oNode2:oAddChild(TBIXMLNode():New("USERID", oPessoa:nValue("USERID")))
		oNode2:oAddChild(TBIXMLNode():New("ID", oPessoa:nValue("ID")))
		oNode2:oAddChild(TBIXMLNode():New("NOME", oPessoa:cValue("NOME")))
		oPessoa:_Next()
	end
	oPessoa:cSQLFilter("")

	//Cria lista de pessoas não vinculadas ao usuário logado
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("TIPO", "PESSOA")
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", STR0010 /*Nome*/)
	oAttrib:lSet("CLA000", BSC_STRING)
	oAttrib:lSet("RETORNA", .f.)
	oNode1 := oXMLNode:oAddChild(TBIXMLNode():New("PESSOAS",,oAttrib))
	if(nID==0)	
		//Se for envio de uma nova mensagem, cria lista de destinatários com as pessoas não vinculadas ao usuário logado
		oPessoa:cSQLFilter("USERID != " + cBIStr(::oOwner():foSecurity:oLoggedUser():nValue("ID")) + " AND ID != 0 AND PARENTID = " + cBIStr(nDestID))
		oPessoa:lFiltered(.t.)
		oPessoa:_First()
		while(!oPessoa:lEof())
			oNode2 := oNode1:oAddChild(TBIXMLNode():New("PESSOA"))
			oNode2:oAddChild(TBIXMLNode():New("USERID", oPessoa:nValue("USERID")))
			oNode2:oAddChild(TBIXMLNode():New("ID", oPessoa:nValue("ID")))
			oNode2:oAddChild(TBIXMLNode():New("NOME", oPessoa:cValue("NOME")))
			oPessoa:_Next()
		end
		oPessoa:cSQLFilter("")
	else
		//Se leitura de uma mensagem, cria lista somente com as pessoas incluidas na pasta PARA e CC
		oDestinatario:cSQLFilter("PARENTID = " + cBIStr(nID) + " AND (PARACC = " + cBIStr(BSC_MSG_PARA) +;
								 " OR PARACC = " + cBIStr(BSC_MSG_CC) +;
								 ") AND REMETENTE = " + cBIStr(BSC_MSG_DESTINATARIO))
		oDestinatario:lFiltered(.t.)
		oDestinatario:_First()
		while(!oDestinatario:lEof())
			oPessoa:lSeek(1, {oDestinatario:nValue("PESSID")} )
			oNode2 := oNode1:oAddChild(TBIXMLNode():New("PESSOA"))
			oNode2:oAddChild(TBIXMLNode():New("USERID", oPessoa:nValue("USERID")))
			oNode2:oAddChild(TBIXMLNode():New("ID", oPessoa:nValue("ID")))
			oNode2:oAddChild(TBIXMLNode():New("NOME", oPessoa:cValue("NOME")))
			oDestinatario:_Next()
		end
		oDestinatario:cSQLFilter("")
	endif

	//Cria lista de pessoas incluidas na lista de destinatários PARA
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("TIPO", "PESSOA")
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", STR0010 /*Nome*/)
	oAttrib:lSet("CLA000", BSC_STRING)
	oAttrib:lSet("RETORNA", .f.)
	oNode1 := oXMLNode:oAddChild(TBIXMLNode():New("PARAS",,oAttrib))
	if(nID!=0)	
		//Se for envio de uma nova mensagem, cria lista de destinatários com as pessoas não vinculadas ao usuário logado
		oDestinatario:cSQLFilter("PARENTID = " + cBIStr(nID) + " AND PARACC = " + cBIStr(BSC_MSG_PARA) +;
								 " AND REMETENTE = " + cBIStr(BSC_MSG_DESTINATARIO))
		oDestinatario:lFiltered(.t.)
		oDestinatario:_First()
		while(!oDestinatario:lEof())
			oPessoa:lSeek(1, {oDestinatario:nValue("PESSID")} )
			oNode2 := oNode1:oAddChild(TBIXMLNode():New("PESSOA"))
			oNode2:oAddChild(TBIXMLNode():New("USERID", oPessoa:nValue("USERID")))
			oNode2:oAddChild(TBIXMLNode():New("ID", oPessoa:nValue("ID")))
			oNode2:oAddChild(TBIXMLNode():New("NOME", oPessoa:cValue("NOME")))
			oDestinatario:_Next()
		end
		oDestinatario:cSQLFilter("")
	endif
	
	//Cria lista de pessoas incluidas na lista de destinatários CC
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("TIPO", "PESSOA")
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", STR0010 /*Nome*/)
	oAttrib:lSet("CLA000", BSC_STRING)
	oAttrib:lSet("RETORNA", .f.)
	oNode1 := oXMLNode:oAddChild(TBIXMLNode():New("CCS",,oAttrib))
	if(nID!=0)	
		//Se for envio de uma nova mensagem, cria lista de destinatários com as pessoas não vinculadas ao usuário logado
		oDestinatario:cSQLFilter("PARENTID = " + cBIStr(nID) + " AND PARACC = " + cBIStr(BSC_MSG_CC) +;
								 " AND REMETENTE = " + cBIStr(BSC_MSG_DESTINATARIO))
		oDestinatario:lFiltered(.t.)
		oDestinatario:_First()
		while(!oDestinatario:lEof())
			
			oPessoa:lSeek(1,{oDestinatario:nValue("PESSID")})
		
			oNode2 := oNode1:oAddChild(TBIXMLNode():New("PESSOA"))
			oNode2:oAddChild(TBIXMLNode():New("USERID", oPessoa:nValue("USERID")))
			oNode2:oAddChild(TBIXMLNode():New("ID", oPessoa:nValue("ID")))
			oNode2:oAddChild(TBIXMLNode():New("NOME", oPessoa:cValue("NOME")))
			oDestinatario:_Next()
		end
		oDestinatario:cSQLFilter("")
	endif
	
return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TBSC004
	local aFields, nInd, nStatus := BSC_ST_OK, lEnviarEmail := .f., i
	local cServer, cPorta, cConta, cAutUsuario, cAutSenha, cTo := "", cAssunto, cCorpo, cAnexos, cFrom, cCopia
	local oConexao := ::oOwner():oGetTable("SMTPCONF")
	local oPessoas := ::oOwner():oGetTable("PESSOA"), aTo  := {}, aCopia := {}
	private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY, {"ID"})
	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		if(aFields[nInd][1]=="DATAENV")
			aFields[nInd][2] := date()
		elseif(aFields[nInd][1]=="HORAENV")
			aFields[nInd][2] := time()
		elseif(aFields[nInd][1]=="PASTA")
			aFields[nInd][2] := BSC_MSG_ENVIADA
		else
			aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		endif
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

	// Extrai e grava lista de destinatarios da lista PARA
	oDestinatario := ::oOwner():oGetTable("DESTINATARIO")
	oDestinatario:lAppend({	{"ID", oDestinatario:nMakeID()},;	// ID
							{"PARENTID",  ::nValue("ID")},;		// ParentID 
							{"PESSID", ::nValue("PARENTID")},;	// ID do Remetente
							{"SITUACAO", 0},; 					// Nula
							{"PASTA", BSC_MSG_ENVIADA},; 		// Enviada
							{"PARACC", 0},; 					// Nula
							{"REMETENTE", BSC_MSG_REMETENTE} })	// Remetente

	if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_PARAS"), "_PESSOA"))!="U")
		if(valtype(&("oXMLInput:"+cPath+":_PARAS:_PESSOA"))=="A")
			for nInd := 1 to len(&("oXMLInput:"+cPath+":_PARAS:_PESSOA"))
				aPara := &("oXMLInput:"+cPath+":_PARAS:_PESSOA["+cBIStr(nInd)+"]")
				aadd(aTo, &("oXMLInput:"+cPath+":_PARAS:_PESSOA["+cBIStr(nInd)+"]:_ID:TEXT"))
				oDestinatario:lAppend({	{"ID", oDestinatario:nMakeID()},;		// ID
										{"PARENTID", ::nValue("ID")},;			// ParentID 
										{"PESSID", nBIVal(aPara:_ID:TEXT)},;	// ID do Destinatário
										{"SITUACAO", 2},; 						// Não Lida
										{"PASTA", BSC_MSG_RECEBIDA},;			// Caixa de Entrada
										{"PARACC", BSC_MSG_PARA},;				// Para
										{"REMETENTE", BSC_MSG_DESTINATARIO} }) 	// Destinatario
			next
		elseif(valtype(&("oXMLInput:"+cPath+":_PARAS:_PESSOA"))=="O")
			aPara := &("oXMLInput:"+cPath+":_PARAS:_PESSOA")
			aadd(aTo, &("oXMLInput:"+cPath+":_PARAS:_PESSOA:_ID:TEXT"))
			oDestinatario:lAppend({	{"ID", oDestinatario:nMakeID()},;		// ID
									{"PARENTID",  ::nValue("ID")},;			// ParentID 
									{"PESSID", nBIVal(aPara:_ID:TEXT)},;	// ID do Destinatário
									{"SITUACAO", 2},; 						// Não Lida
									{"PASTA", BSC_MSG_RECEBIDA},;			// Caixa de Entrada
									{"PARACC", BSC_MSG_PARA},;				// Para
									{"REMETENTE", BSC_MSG_DESTINATARIO} }) 	// Destinatario
		endif
	endif

	// Extrai e grava lista de destinatarios da lista CC
	if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_CCS"), "_PESSOA"))!="U")
		if(valtype(&("oXMLInput:"+cPath+":_CCS:_PESSOA"))=="A")
			for nInd := 1 to len(&("oXMLInput:"+cPath+":_CCS:_PESSOA"))
				aCC := &("oXMLInput:"+cPath+":_CCS:_PESSOA["+cBIStr(nInd)+"]")
				aadd(aCopia, &("oXMLInput:"+cPath+":_CCS:_PESSOA["+cBIStr(nInd)+"]:_ID:TEXT"))
				oDestinatario:lAppend({	{"ID", oDestinatario:nMakeID()},;		// ID
										{"PARENTID", ::nValue("ID")},;			// ParentID
										{"PESSID", nBIVal(aCC:_ID:TEXT)},;		// ID do Destinatário
										{"SITUACAO", 2},; 						// Não Lida
										{"PASTA", BSC_MSG_RECEBIDA},;			// Caixa de Entrada
										{"PARACC", BSC_MSG_CC},;				// CC
										{"REMETENTE", BSC_MSG_DESTINATARIO} }) 	// Destinatario
			next
		elseif(valtype(&("oXMLInput:"+cPath+":_CCS:_PESSOA"))=="O")
			aCC := &("oXMLInput:"+cPath+":_CCS:_PESSOA")
			aadd(aCopia, &("oXMLInput:"+cPath+":_CCS:_PESSOA:_ID:TEXT"))
			oDestinatario:lAppend({	{"ID", oDestinatario:nMakeID()},;		// ID
									{"PARENTID", ::nValue("ID")},;			// ParentID 
									{"PESSID", nBIVal(aCC:_ID:TEXT)},; 		// ID do Destinatário
									{"SITUACAO", 2},; 						// Não Lida
									{"PASTA", BSC_MSG_RECEBIDA},;			// Caixa de Entrada
									{"PARACC", BSC_MSG_CC},;				// CC
									{"REMETENTE", BSC_MSG_DESTINATARIO} }) 	// Destinatario
		endif
	endif

	if(nStatus==BSC_ST_OK)
		lEnviarEmail := if(xBIConvTo("L",oXMLInput:_REGISTROS:_MENSAGEM:_EMAIL:TEXT),.t.,.f.)
	endif
	if(lEnviarEmail .and. nStatus==BSC_ST_OK)
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

			// inclusao do email dos Destinatarios
			cTo := ""
			for i := 1 to len(aTo)
				if(oPessoas:lSeek(1, {aTo[i]}))
					cTo	+= if(empty(cTo),"",",")+alltrim(oPessoas:cValue("EMAIL"))
				endif
			next

			cCopia := ""
			for i := 1 to len(aCopia)
				if(oPessoas:lSeek(1, {aCopia[i]}))
					cCopia += if(empty(cCopia),"",",")+alltrim(oPessoas:cValue("EMAIL"))
				endif
			next

			if(oPessoas:lSeek(1, {::nValue("PARENTID")}))
				cFrom:= alltrim(oPessoas:cValue("NOME"))+' <'+alltrim(oPessoas:cValue("EMAIL"))+'>'
			endif

			cCorpo 	:= alltrim(::cValue("TEXTO"))
			cAssunto:= TEXT_ENTITY+": " + alltrim(::cValue("NOME"))
			cAnexos	:= ""//alltrim(::cValue("ANEXO"))
			oConexao:SendMail(cServer, cPorta, cConta, cAutUsuario, cAutSenha, cTo, cAssunto, cCorpo, cAnexos, cFrom, cCopia)
		endif
		oConexao:cSQLFilter("") // Retira filtro

	endif
	              
return nStatus

// Delete mensagem da Caixa de Entrada / Itens Enviados / Itens excluidos
// O ID recebido sempre será do destinatário
method nDelFromXML(nID) class TBSC004
	local nStatus := BSC_ST_OK
	local oDestinatario, lRemetente, lExclui

	oDestinatario := ::oOwner():oGetTable("DESTINATARIO")
	//Posiciona ponteiro na tabela de Destinatarios BSC004A
	oDestinatario:lSeek(1,{nID})                
	//Posiciona ponteiro na tabela de Remetente BSC004
	::lSeek(1,{oDestinatario:nValue("PARENTID")})
	//Verifica se o nID solicitado é de remetente ou destinatário
	lRemetente := (oDestinatario:nValue("REMETENTE")==BSC_MSG_REMETENTE)

	if(lRemetente)
		if(::nValue("PASTA")==BSC_MSG_ENVIADA)
			::lUpdate({{"PASTA", BSC_MSG_EXCLUIDA}})
			oDestinatario:cSQLFilter("PARENTID = " + cBIStr(::nValue("ID")) + " AND REMETENTE = " + cBIStr(BSC_MSG_REMETENTE))
			oDestinatario:lFiltered(.t.)
			oDestinatario:_First()
			while(!oDestinatario:lEof())
				oDestinatario:lUpdate({{"PASTA", BSC_MSG_EXCLUIDA}})
				oDestinatario:_Next()
			end 
			oDestinatario:cSQLFilter("")
		elseif(::nValue("PASTA")==BSC_MSG_EXCLUIDA)
			//Antes de verificar se a mensagem pode ser excluida definitivamente o registro corrente
			//deve ser enviado para a (Pasta = 4)
			::lUpdate({{"PASTA", BSC_MSG_DESCARTADA}})
			oDestinatario:cSQLFilter("PARENTID = " + cBIStr(::nValue("ID")) + " AND REMETENTE = " + cBIStr(BSC_MSG_REMETENTE))
			oDestinatario:lFiltered(.t.)
			oDestinatario:_First()
			while(!oDestinatario:lEof())
				oDestinatario:lUpdate({{"PASTA", BSC_MSG_DESCARTADA}})
				oDestinatario:_Next()
			end 
			oDestinatario:cSQLFilter("")         

			//Verifica se todos os destinatarios excluiram a mensagem definitivamente (Pasta = 4),
			//caso todos tenham efetuado esta exclusão os registros referentes a esta mensagem
			//serão excluidos definitivamente da tabela BSC004 e BSC004A
			lExclui := .t.
			oDestinatario:cSQLFilter("PARENTID = " + cBIStr(::nValue("ID")) + " AND REMETENTE = " + cBIStr(BSC_MSG_DESTINATARIO))
			oDestinatario:lFiltered(.t.)
			oDestinatario:_First()
			while(!oDestinatario:lEof() .and. lExclui)
			    lExclui := (oDestinatario:nValue("PASTA")==BSC_MSG_DESCARTADA)
				oDestinatario:_Next()
			end 
			oDestinatario:cSQLFilter("")
			
			if(lExclui)
				//Exclui da tabela de Destinatarios (BSC004A)
				oDestinatario:cSQLFilter("PARENTID = " + cBIStr(::nValue("ID")))
				oDestinatario:lFiltered(.t.)
				oDestinatario:_First()
				while(!oDestinatario:lEof())
					if(!oDestinatario:lDelete())
						nStatus := BSC_ST_INUSE
					endif
					oDestinatario:_Next()
				end
				oDestinatario:cSQLFilter("")
				//Exclui da tabela de Remetente (Mensagem original - BSC004)
				if(!::lDelete())
					nStatus := BSC_ST_INUSE
				endif
			endif
		endif
	else
		if(oDestinatario:nValue("PASTA")==BSC_MSG_RECEBIDA)
			oDestinatario:lUpdate({{"PASTA", BSC_MSG_EXCLUIDA}})
		elseif(oDestinatario:nValue("PASTA")==BSC_MSG_EXCLUIDA)
			//Antes de verificar se a mensagem pode ser excluida definitivamente o registro corrente
			//deve ser enviado para a (Pasta = 4)
			oDestinatario:lUpdate({{"PASTA", BSC_MSG_DESCARTADA}})

			//Verifica se todos os destinatarios e se o Remetente excluiram a mensagem definitivamente 
			//(Pasta = 4), caso todos tenham efetuado esta exclusão os registros referentes a esta mensagem
			//serão excluidos definitivamente da tabela BSC004 e BSC004A
			oDestinatario:SavePos()
			lExclui := .t.
			oDestinatario:cSQLFilter("PARENTID = " + cBIStr(oDestinatario:nValue("PARENTID")) + " AND REMETENTE = " + cBIStr(BSC_MSG_DESTINATARIO))
			oDestinatario:lFiltered(.t.)
			oDestinatario:_First()
			while(!oDestinatario:lEof() .and. lExclui)
			    lExclui := (oDestinatario:nValue("PASTA")==BSC_MSG_DESCARTADA)
				oDestinatario:_Next()
			end 
			oDestinatario:cSQLFilter("")
			oDestinatario:RestPos()              
			  
			//Verifica se o Remetente excluiu a mensagem definitivamente
			::lSeek(1,{oDestinatario:nValue("PARENTID")})
			lExclui := (::nValue("PASTA")==BSC_MSG_DESCARTADA)
			
			if(lExclui)
				//Exclui da tabela de Destinatarios (BSC004A)
				oDestinatario:cSQLFilter("PARENTID = " + cBIStr(oDestinatario:nValue("PARENTID")))
				oDestinatario:lFiltered(.t.)
				oDestinatario:_First()
				while(!oDestinatario:lEof())
					if(!oDestinatario:lDelete())
						nStatus := BSC_ST_INUSE
					endif
					oDestinatario:_Next()
				end
				oDestinatario:cSQLFilter("")

				//Exclui da tabela de Remetente (Mensagem original - BSC004)
				if(!::lDelete())
					nStatus := BSC_ST_INUSE
				endif
			endif
		endif
	endif

return nStatus

// Insere nova entidade
method aPeopleByUser(nUserID, nIDOrg) class TBSC004
	local aPessIDs := {}
	local oPessoas := ::oOwner():oGetTable("PESSOA")
	
	oPessoas:cSQLFilter("USERID = " + cBIStr(nUserID) + " AND PARENTID = " + cBIStr(nIDOrg))
	oPessoas:lFiltered(.t.)
	oPessoas:_First()
	while(!oPessoas:lEof())
		aAdd(aPessIDs, oPessoas:nValue("ID"))
		oPessoas:_Next()
	end
	oPessoas:cSQLFilter("")

return  aPessIds

//Retorna um XML completo para Mensagens Enviadas
class TBSCMensagensEnviadas from TBIObject  
	method New() constructor
	method NewBSCMensagensEnviadas()

	// registro atual
	method oToXMLNode(nParentID, cLoadCmd)

endclass
method New() class TBSCMensagensEnviadas
	::NewBSCMensagensEnviadas()
return
method NewBSCMensagensEnviadas() class TBSCMensagensEnviadas
	::NewObject()
return
method oToXMLNode(nParentID, cLoadCmd) class TBSCMensagensEnviadas
	local oXMLMsg
	
	oXMLMsg := TBIXMLNode():New("MENSAGENS_ENVIADAS")
	oXMLMsg:oAddChild(TBIXMLNode():New("ID", nParentID))
	oXMLMsg:oAddChild(TBIXMLNode():New("PARENTID", 0))
	oXMLMsg:oAddChild(TBIXMLNode():New("CONTEXTID", 0))
	oXMLMsg:oAddChild(TBIXMLNode():New("NOME", "Itens Enviados"))
	oXMLMsg:oAddChild(::oOwner():oGetTable("MENSAGEM"):oToXMLList(nParentID,1))
	
return oXMLMsg	

//Retorna um XML completo para Mensagens Recebidas
class TBSCMensagensRecebidas from TBIObject  
	method New() constructor
	method NewBSCMensagensRecebidas()

	// registro atual
	method oToXMLNode(nParentID, cLoadCmd)

endclass
method New() class TBSCMensagensRecebidas
	::NewBSCMensagensRecebidas()
return
method NewBSCMensagensRecebidas() class TBSCMensagensRecebidas
	::NewObject()
return
method oToXMLNode(nParentID, cLoadCmd) class TBSCMensagensRecebidas
	local oXMLMsg
	
	oXMLMsg := TBIXMLNode():New("MENSAGENS_RECEBIDAS")
	oXMLMsg:oAddChild(TBIXMLNode():New("ID", nParentID))
	oXMLMsg:oAddChild(TBIXMLNode():New("PARENTID", 0))
	oXMLMsg:oAddChild(TBIXMLNode():New("CONTEXTID", 0))
	oXMLMsg:oAddChild(TBIXMLNode():New("NOME", "Caixa de Entrada"))
	oXMLMsg:oAddChild(::oOwner():oGetTable("MENSAGEM"):oToXMLList(nParentID,2))
	
return oXMLMsg	

//Retorna um XML completo para Mensagens Excluidas
class TBSCMensagensExcluidas from TBIObject  
	method New() constructor
	method NewBSCMensagensExcluidas()

	// registro atual
	method oToXMLNode(nParentID, cLoadCmd)

endclass
method New() class TBSCMensagensExcluidas
	::NewBSCMensagensExcluidas()
return
method NewBSCMensagensExcluidas() class TBSCMensagensExcluidas
	::NewObject()
return
method oToXMLNode(nParentID, cLoadCmd) class TBSCMensagensExcluidas
	local oXMLMsg
	
	oXMLMsg := TBIXMLNode():New("MENSAGENS_EXCLUIDAS")
	oXMLMsg:oAddChild(TBIXMLNode():New("ID", nParentID))
	oXMLMsg:oAddChild(TBIXMLNode():New("PARENTID", 0))
	oXMLMsg:oAddChild(TBIXMLNode():New("CONTEXTID", 0))
	oXMLMsg:oAddChild(TBIXMLNode():New("NOME", "Itens Excluidos"))
	oXMLMsg:oAddChild(::oOwner():oGetTable("MENSAGEM"):oToXMLList(nParentID,3))
	
return oXMLMsg
  
function _BSC004_Msg()
return