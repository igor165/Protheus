#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "MATI390.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} MATI390
Programa de interpretacao da mensagem unica

@since 11/11/2012
@version P11.5
@param	cXML - Variavel com conteudo xml para envio/recebimento.
@param	nTypeTrans - Tipo de transacao. (Envio/Recebimento)
@param	cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc)
@param	dDtValAnt - Antiga data de validade do lote
@return	aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno
	aRet[1] - (boolean) Indica o resultado da execução da função
	aRet[2] - (caracter) Mensagem Xml para envio
*/
//-------------------------------------------------------------------
Function MATI390(cXML,nTypeTrans,cTypeMessage,dDtValAnt)
Local lRet		:= .T.
Local cXMLRet	:= ""
Local cEvent	:= "upsert"     
Local cWarning	:= ""
Local cError	:= ""
Local cMarca	:= ""
Local nCount	:= 0
Local oXmlA390	:= NIL

If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := '1.000'
	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
		oXmlA390 := XmlParser( cXml, '_', @cError, @cWarning )
		
		If oXmlA390 <> Nil .And. Empty(cError) .And. Empty(cWarning)
			cMarca   := oXmlA390:_TotvsMessage:_MessageInformation:_Product:_Name:Text
			oXmlA390 := oXmlA390:_TotvsMessage
			
			//-- Identifica se o processamento pelo parceiro ocorreu com sucesso.
			If XmlChildEx( oXmlA390:_ResponseMessage:_ProcessingInformation, '_STATUS' ) <> Nil .And. ;
				Upper(oXmlA390:_ResponseMessage:_ProcessingInformation:_Status:Text)=='OK'
			Else
				lRet    := .F.
				cXmlRet := STR0001 //-- Processamento pela outra aplicação não teve sucesso
				
				//-- Transforma estrutura das mensagens de erro em array para concatenar com a mensagem de retorno
				If XmlChildEx( oXmlA390:_ResponseMessage:_ProcessingInformation, '_LISTOFMESSAGES' ) <> Nil .And. ;
					ValType(oXmlA390:_ResponseMessage:_ProcessingInformation:_ListOfMessages) <> 'A'
					XmlNode2Arr(oXmlA390:_ResponseMessage:_ProcessingInformation:_ListOfMessages, "_ListOfMessages")
				EndIf
				
				For nCount := 1 To Len( oXmlA390:_ResponseMessage:_ProcessingInformation:_ListOfMessages )
					If XmlChildEx( oXmlA390:_ResponseMessage:_ProcessingInformation:_ListOfMessages[nCount], '_MESSAGE' ) <> Nil
						cXmlRet += ' | ' + oXmlA390:_ResponseMessage:_ProcessingInformation:_ListOfMessages[nCount]:_Message:Text
					EndIf
				Next nCount
				
				If InTransact()
					DisarmTransaction()
				EndIf
			EndIf
		Else
			lRet    := .F.
			cXmlRet := STR0002 +cWarning +' | ' +cError //-- XML mal formatado: ### | ###
		EndIf
	Endif
ElseIf nTypeTrans == TRANS_SEND
	cXMLRet := '<BusinessEvent>'
	cXMLRet += '	<Entity>VALIDITYLOT</Entity>'
	cXMLRet += '	<Event>' +cEvent +'</Event>'
	cXMLRet += '	<Identification>'
	cXMLRet += '		<key name="ItemCode">' +SB8->B8_PRODUTO +'</key>'
	cXMLRet += '		<key name="WarehouseCode">' +SB8->B8_LOCAL +'</key>'
	cXMLRet += '		<key name="NewLotExpirationDate">' +Transform(DToS(SB8->B8_DTVALID),"@R 9999-99-99") +'</key>'
	cXMLRet += '		<key name="LotNumber">' +SB8->B8_LOTECTL +'</key>'
	cXMLRet += '		<key name="SubLotNumber">' +SB8->B8_NUMLOTE +'</key>'
	cXMLRet += '	</Identification>'
	cXMLRet += '</BusinessEvent>'
	
	cXMLRet += '<BusinessContent> '
	cXMLRet += '	<CompanyId>' +cEmpAnt +'</CompanyId> '
	cXMLRet += '	<BranchId>' +cFilAnt +'</BranchId> '
	cXMLRet += '	<CompanyInternalId>' +cEmpAnt +"|" +xFilial("SB8") +'</CompanyInternalId> '
	cXMLRet += '	<InternalId>' +cEmpAnt +"|" +RTrim(xFilial("SB8")) +"|" +RTrim(SB8->B8_LOCAL) +"|" +RTrim(SB8->B8_LOTECTL) +"|" +RTrim(SB8->B8_NUMLOTE) +'</InternalId> '
	cXMLRet += '	<ItemCode>' +SB8->B8_PRODUTO +'</ItemCode> '
	cXMLRet += '	<WarehouseCode>' +SB8->B8_LOCAL +'</WarehouseCode> '
	cXMLRet += '	<LotCreationDate>' +Transform(DToS(SB8->B8_DATA),"@R 9999-99-99") +'</LotCreationDate> '
	If !Empty(dDtValAnt)
		cXMLRet += '<LotExpirationDate>' +Transform(DToS(dDtValAnt),"@R 9999-99-99") +'</LotExpirationDate> '
	EndIf
	cXMLRet += '	<NewLotExpirationDate>' +Transform(DToS(SB8->B8_DTVALID),"@R 9999-99-99") +'</NewLotExpirationDate> '
	cXMLRet += '	<LotNumber>' +SB8->B8_LOTECTL +'</LotNumber> '
	cXMLRet += '	<SubLotNumber>' +SB8->B8_NUMLOTE +'</SubLotNumber> '
	cXMLRet += '</BusinessContent> '
EndIf

Return {lRet,cXMLRet}