#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "MATI030B.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MATI030B
Funcao de integracao com o adapter EAI para tratamento da mensagem CUSTOMERVENDORINFORMATION
Onde se recebe o CPF/CNPJ do cliente e retorna a lista de cliente com o CPF/CNPJ com
os seguintes dados: codigo, loja, nome fantasia e nome
@param		cXml			Variável com conteúdo XML para envio/recebimento.
@param		nTypeTrans		Tipo de transação. (Envio/Recebimento)
@param		cTypeMessage	Tipo de mensagem. (Business Type, WhoIs, etc)
@param		cVersion		Versão da Mensagem Única TOTVS
@param		cTransaction	Informa qual o nome da mensagem iniciada no adapter. Ex. "CUSTOMERVENDOR".
							Esta informação é importante quando temos a mesma rotina cadastrada para mais de uma mensagem.
@author	Reynaldo Tetsu Miyashita
@version	P12
@since		18/05/2015
@return	lRet - (boolean)  Indica o resultado da execução da função
			cXmlRet - (caracter) Mensagem XML para envio
/*/
//-------------------------------------------------------------------------------------------------
Function MATI030B(cXML, nTypeTrans, cTypeMessage, cVersion, cTransaction)

Local cError   := ""
Local cWarning := ""
Local cVersao  := ""
Local lRet     := .T.
Local cXmlRet  := ""
Local aRet     := {}

Private oXml    := Nil
	
//Mensagem de Entrada
If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS .Or. cTypeMessage == EAI_MESSAGE_RESPONSE
		If ! Empty(cVersion)
			oXml := xmlParser(cXml, "_", @cError, @cWarning)
			If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
				// Versão da mensagem
				If Type("oXml:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. ! Empty(oXml:_TOTVSMessage:_MessageInformation:_version:Text)
					cVersao		:= StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
					If cVersao == "1"
						aRet		:= v1000(cXml, nTypeTrans, cTypeMessage, cVersion, cTransaction)
					Else
						lRet		:= .F.
						cXmlRet	:= STR0003	//"A versão da mensagem informada não foi implementada!"
						Return {lRet, cXmlRet}
					EndIf
				Else
					lRet    := .F.
					cXmlRet := STR0001	//"Versão da mensagem não informada!"
					Return {lRet, cXmlRet}
				EndIf
			Else
				lRet    := .F.
				cXmlRet := STR0002	//"Erro no parser!"
				Return {lRet, cXmlRet}
			EndIf
		Else
			lRet		:= .F.
			cXmlRet	:= STR0004	//"Versão não informada no cadastro do adapter."
			Return {lRet, cXmlRet}
		EndIf
	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
		aRet	:= v1000(cXml, nTypeTrans, cTypeMessage, cVersion, cTransaction)
	Endif
	
// Mensagem de Saida	
ElseIf nTypeTrans == TRANS_SEND
	If XX4->(ColumnPos("XX4_SNDVER")) > 0
		If ! Empty(cVersion)
			cVersao		:= StrTokArr(cVersion, ".")[1]
			If cVersao == "1"
				aRet		:= v1000(cXml, nTypeTrans, cTypeMessage, cVersion, cTransaction)
			Else
				lRet		:= .F.
				cXmlRet	:= STR0003	//"A versão da mensagem informada não foi implementada!"
				Return {lRet, cXmlRet}
			EndIf
		Else
			lRet		:= .F.
			cXmlRet	:= STR0004	//"Versão não informada no cadastro do adapter."
			Return {lRet, cXmlRet}
		EndIf
	Else
		ConOut(STR0005)	//"A LIB da framework Protheus está desatualizada!"
		aRet	:= v1000(cXml, nTypeTrans, cTypeMessage, "1.000 ", cTransaction) //Se o campo versão não existir chamar a versão 1
	EndIf
EndIf

lRet    := aRet[1]
cXMLRet := aRet[2]
Return {lRet, cXmlRet}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} v1000
Funcao de integracao com o adapter EAI para consulta de informações do cadastro 
de clientes (SA1) utilizando o conceito de mensagem unica.
@author reynaldo
@since 18/05/2015
@version 1.0
@param		cXML - Variavel com conteudo xml para envio/recebimento.     
@param		nTypeTrans - Tipo de transacao. (Envio/Recebimento)          
@param		cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc) 
@param		cVersion		Versão da Mensagem Única TOTVS
@param		cTransaction	Informa qual o nome da mensagem iniciada no adapter. Ex. "CUSTOMERVENDOR".
							Esta informação é importante quando temos a mesma rotina cadastrada para mais de uma mensagem.
@return 
	aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.                                       
		aRet[1] - (boolean) Indica o resultado da execução da função 
		aRet[2] - (caracter) Mensagem Xml para envio                 
/*/
//-------------------------------------------------------------------------------------------------
Static Function v1000( cXML, nTypeTrans, cTypeMessage, cVersion, cTransaction )

Local aArea		:= {}
Local aReceive	:= {}
Local aClientes	:= {}
Local aRet			:= {}
Local cQuery		:= ""
Local cXMLRet 	:= ""
Local cTmpAlias	:= ""
Local nCnt			:= 1
Local lRet			:= .T.
Local cError		:= ""
Local cWarning	:= ""
Local cFilSA1		:= ""

Private oXmlM030

//Trata o recebimento de mensagens
If ( nTypeTrans == TRANS_RECEIVE )

	aArea		:= GetArea()
	//Trata o recebimento de dados (BusinessContent)
	If ( cTypeMessage == EAI_MESSAGE_BUSINESS )

		oXmlM030 := XmlParser( cXml, "_", @cError, @cWarning )

		//Verifica se houve erro na criacao do objeto XML
		If ( oXmlM030 <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) )

			// se for Cliente
			If ( AllTrim( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text ) ) == "CUSTOMER")

				//--------------------------------------------------------------------------------------
				//-- Tratamento utilizando a tabela XXF com um De/Para de codigos
				//--------------------------------------------------------------------------------------
				// CPF ou CNPJ
				If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text" ) <> "U" )
					aAdd( aReceive, { "A1_CGC", oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text, Nil } )
				EndIf

				cTmpAlias	:= GetNextAlias()
				cQuery		:= "SELECT A1_COD, A1_LOJA, A1_NOME, A1_NREDUZ "
				cQuery		+=   "FROM " + RetSqlName("SA1") + " SA1 "
				cQuery		+=  "WHERE A1_FILIAL = '"+FwxFilial("SA1")+"' "
				cQuery		+=    "AND D_E_L_E_T_ = ' ' "
				cQuery		+=    "AND " + aReceive[01,01] + " = '" + aReceive[01,02] + "' "
				cQuery		+=  "ORDER BY " + SqlOrder(SA1->(IndexKey()))
				cQuery		:= ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpAlias,.T.,.T.)
				If Select(cTmpAlias) >0
					While (cTmpAlias)->(!Eof())
						aAdd( aClientes,{(cTmpAlias)->A1_COD, (cTmpAlias)->A1_LOJA, (cTmpAlias)->A1_NOME, (cTmpAlias)->A1_NREDUZ})
						(cTmpAlias)->(dbSkip())
					EndDo
				EndIf
				(cTmpAlias)->(DbCloseArea())

				cXMLRet += '<ListOfCustomerVendorInformationResult>'
				If Empty(aClientes)
					cXMLRet += '<CustomerVendorInformationResult>'
					cXMLRet += '<Exists>false</Exists>'
					cXMLRet += '</CustomerVendorInformationResult>'
				Else
					For nCnt := 1 To len(aClientes)
						cXMLRet += '<CustomerVendorInformationResult>'
						cXMLRet += '<Exists>true</Exists>'
						cXMLRet += '<Code>' + aClientes[nCnt,01] + aClientes[nCnt,02] + '</Code>'
						cXMLRet += '<Name>' + aClientes[nCnt,03] + '</Name>'
						cXMLRet += '<ShortName>' + aClientes[nCnt,04] + '</ShortName>'
						cXMLRet += '</CustomerVendorInformationResult>'
					Next nCnt
				EndIf
				cXMLRet += '</ListOfCustomerVendorInformationResult>'

			// se for Fornecedor
			ElseIf ( AllTrim( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text ) ) == "VENDOR")
				aRet := FWIntegDef( "MATA020?", cTypeMessage, nTypeTrans, cXml)
				If ( !Empty(aRet) )
					lRet    := aRet[1]
					cXmlRet += aRet[2]
				EndIf
			EndIf

		Else
			//Tratamento em caso de falha ao gerar o objeto XML
			lRet        := .F.
			cXMLRet := STR0006 + cWarning	//"Falha ao manipular o XML. "
		EndIf

	//Tratamento de respostas
	ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )

		//Caso não existe a funcao
		If !( FindFunction("CFGA070Mnt") )
			ConOut(STR0007)	//"Atualize EAI"
		EndIf

		//Tratamento de solicitacao de versao
	ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )
		cXMLRet := '1.000'
	EndIf
	RestArea(aArea)
	
//Tratamento de envio de mensagens
ElseIf ( nTypeTrans == TRANS_SEND )
	cFilSA1	:= xFilial("SA1")
	cXMLRet += '<BusinessRequest>'
	cXMLRet += 	'<Operation>MATA030B</Operation>'
	cXMLRet += '</BusinessRequest>'
	cXMLRet += '<BusinessContent>'
	cXMLRet += 	'<CompanyInternalId>' + cEmpAnt + '|' + cFilSA1 + '</CompanyInternalId>'
	cXMLRet += 	'<CompanyId>' + cEmpAnt + '</CompanyId>'
	cXMLRet += 	'<BranchId>' + cFilSA1 + '</BranchId>'
	cXMLRet += 	'<Type>001</Type>'
	cXMLRet += '<BusinessContent>'
	cXMLRet += '<DocumentNumber>'+SA1->A1_CGC+'</DocumentNumber>'
	cXMLRet += '</BusinessContent>'
EndIf

Return { lRet, cXMLRet }