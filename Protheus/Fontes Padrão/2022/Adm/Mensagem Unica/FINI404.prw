#Include 'Protheus.ch'
#Include 'FWADAPTEREAI.CH'
#Include "FINI404.CH"

Static cMessage  := "ExternalAutonomousPayment"

/*/{Protheus.doc}FINI404
Mensagem unica de integração com RM, envio de dados dos fornecedores autonomos.

@param cXml	        Xml construido pelo FINA404
@param cType 	    Determina se a mensagem é envio ou recebimento (TRANS_SEND ou TRANS_RECEIVE)
@param cTypeMessage Tipo de mensagem ( EAI_MESSAGE_WHOIS, EAI_MESSAGE_RESPONSE, EAI_MESSAGE_BUSINESS)
@param cVersion     Versão da mensagem.
@param cTransac     Nome da transação.

@return Array contendo o resultado da execucao e a mensagem Xml de retorno.
aRet[1] - (boolean) Indica o resultado da execução da função
aRet[2] - (caractere) Mensagem Xml para envio
aRet[3] - (caractere) Nome da mensagem para retorno no WHOIS

@author William Matos
@since  19/06/15
/*/

Function FINI404( cXml, cType, cTypeMessage, cVersion, cTransac)

Local cXmlRet		:= ''
Local cErroXml	:= ''
Local cWarnXml	:= ''
Local lRet		:= .T.
Local oXML		:= Nil

If cType == TRANS_SEND
	If Empty( cVersion ) 
		lRet    := .F.
		cXmlRet := STR0004 //"Versão não informada no cadastro do adapter."
	Else
		cXmlRet := cXml
	EndIf
ElseIf cType == TRANS_RECEIVE

	If cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := '1.000|1.006'

	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

		oXML := XmlParser(cXml, "_", @cErroXml, @cWarnXml)

		If oXML <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
			Fini404Res(oXML, @lRet, @cXmlRet )
		Else
			lRet	:= .F.
			cXMLRet	:= STR0001 +" " + cErroXml + ' | ' + cWarnXml
		EndIf	

	EndIf

EndIf

Return {lRet, cXmlRet, cMessage}

 //-------------------------------------------------------------------
/*/{Protheus.doc} Fini404Res
Atualiza os registros no recibemento do response  

@param		lStatus, indicação do status de processamento (.T.|.F.)
@param		cMsgStatus, mensagem de retorno para o status

@author	TOTVS
@version	12.1.11
@since		03/03/2016
/*/
//-------------------------------------------------------------------
Static Function Fini404Res(oXML, lStatus, cMsgStatus )
Local oXmlClone		:= oXML:_TotvsMessage:_ResponseMessage
Local cMarca		:= oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text
Local nX			:= 0
Local cPrefixo		:= ""
Local cNumDoc		:= ""
Local cParcela		:= ""
Local cTipoDoc		:= ""
Local cFornec		:= ""
Local cLoja			:= ""
Local aTemp			:= {}
Local cTemp			:= ""
Local nTamPref		:= TamSX3("E2_PREFIXO")[1]
Local nTamNum		:= TamSX3("E2_NUM")[1]
Local nTamParc		:= TamSX3("E2_PARCELA")[1]
Local nTamTipo		:= TamSX3("E2_TIPO")[1]
Local nTamForn		:= TamSX3("E2_FORNECE")[1]
Local nTamLoja		:= TamSX3("E2_LOJA")[1]

Default lStatus		:= .T.
Default cMsgstatus	:= ' '

lStatus := Upper( oXmlClone:_ProcessingInformation:_Status:Text)=='OK'

If lStatus
	oXmlClone := oXmlClone:_ReturnContent

	If XmlChildEx( oXmlClone, '_LISTOFINTERNALID' ) <> Nil .And. ;
		XmlChildEx( oXmlClone:_ListOfInternalId, '_INTERNALID' ) <> Nil 
		If Valtype( oXmlClone:_ListOfInternalId:_InternalId ) <> 'A'
			XmlNode2Arr( oXmlClone:_ListOfInternalId:_InternalId, '_InternalId' )
		EndIf
		For nX:=1 to Len (oXmlClone:_ListOfInternalId:_InternalId)

			cTemp := oXmlClone:_ListOfInternalId:_InternalId[nX]:_Origin:Text

			aTemp := Separa(cTemp, '|')

			cPrefixo	:= PadR(aTemp[3],nTamPref)
			cNumDoc		:= PadR(aTemp[4],nTamNum)
			cParcela	:= PadR(aTemp[5],nTamParc)
			cTipoDoc	:= PadR(aTemp[6],nTamTipo)
			cFornec		:= PadR(aTemp[7],nTamForn)
			cLoja		:= PadR(aTemp[8],nTamLoja)

			DbSelectArea("SE2")
			SE2->(DbSetOrder(1))
			If SE2->(DbSeek(XFilial("SE2")+ cPrefixo + cNumDoc + cParcela + cTipoDoc + cFornec + cLoja))
				If Empty(SE2->E2_SEFIP)
					//Grava status X para titulo integrado
					RecLock("SE2",.F.)
					SE2->E2_SEFIP := "X"
					SE2->(MSUnlock())
				Elseif SE2->E2_SEFIP == "X"
					//Grava status Y para titulo integrado novamente após ser baixado
					RecLock("SE2",.F.)
					SE2->E2_SEFIP := "Y"
					SE2->(MSUnlock())
				Endif
			EndIf

		Next nX
	Endif
Else
	oXmlClone := oXmlClone:_ProcessingInformation
	If XmlChildEx( oXmlClone, '_LISTOFMESSAGES' ) <> Nil .And. ;
		XmlChildEx( oXmlClone:_ListOfMessages, '_MESSAGE' ) <> Nil
		If Valtype( oXmlClone:_ListOfMessages:_Message ) <> 'A'
			XmlNode2Arr( oXmlClone:_ListOfMessages:_Message, '_Message' )
		EndIf

		For nX := 1 To Len( oXmlClone:_ListOfMessages:_Message )
			cMsgStatus += oXmlClone:_ListOfMessages:_Message[nX]:Text
		Next nX
	Else
		lStatus		:= .F.
		cMsgStatus	:='<Message type="ERROR" code="c2">' + STR0002 + '</Message>' //'Houve um erro na mensagem e este não pôde ser identificado.'
	EndIf
EndIf

Return
