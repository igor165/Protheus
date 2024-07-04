#Include 'Protheus.ch'
#Include 'FWAdapterEAI.ch'
#Include 'PMSI200.ch'

#Define CRLF Chr(10) + Chr(13)

/*/{Protheus.doc} PMSI200B
Fun��o para chamar o adapter de mensagem �nica de InternalID.

@description
Esta fun��o � utilizada para enviar os InternalIDs alterados no Protheus
ap�s a troca de c�digo do projeto.

@author Mateus Gustavo de Freitas e Silva
@since 15/03/2014
@version P11

@param cXML, caracter, XML da mensagem �nica para envio/recebimento
@param nTypeTrans, numerico, Tipo de transacao. (0-Recebimento, 1-Envio)
@param cTypeMessage, numerico, Tipo de transa��o da Mensagem. (20-Business, 21-Response, 22-Receipt)

@return array, Array de duas posi��es sendo a primeira o resultado do processamento e a segunda o texto de resposta.

/*/
Function PMSI200B(cXML, nTypeTrans, cTypeMessage)
   Local lRet      := .T.
   Local cXMLRet   := ""
   Local cError    := ""
   Local cWarning  := ""
   Local nCount    := 1
   Local aMessages := {}

   Private oXml   := ""

   If nTypeTrans == TRANS_RECEIVE
      If cTypeMessage == EAI_MESSAGE_BUSINESS
         lRet    := .F.
         cXMLRet := 'Recebimento n�o implementado!'
         aAdd(aMessages, {cXMLRet , 1, Nil})
      ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
         // Faz o parse do xml em um objeto
         oXml := XmlParser(cXml, "_", @cError, @cWarning)

         // Se n�o houve erros no parser
         If oXml <> Nil .And. Empty(cError) .And. Empty(cWarning)
            // Se n�o houve erros na resposta
            If Upper(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) != "OK"
               // Se n�o for array
               If ValType(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message) != "A"
                  // Transforma em array
                  XmlNode2Arr(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
               EndIf

               // Percorre o array para obter os erros gerados
               For nCount := 1 To Len(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
                  cXmlRet += oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + CRLF
               Next nCount

               lRet := .F.
               aAdd(aMessages, {cXMLRet , 1, Nil})
            EndIf
         Else
            lRet    := .F.
            cXmlRet := "Erro no Parser!"
            aAdd(aMessages, {cXMLRet , 1, Nil})
         EndIf
      ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
         cXMLRet := '1.000'
      EndIf
   ElseIf nTypeTrans == TRANS_SEND
        If !Empty(cXml)
           // Fun��o chamada por outras fun��es. Exemplo: PMSI200 e PMSI203
           cXMLRet := cXml
        Else
           // Implementa��o local
           cXMLRet := ''
        EndIf
   EndIf

   If !lRet
      cXMLRet := ""

      For nCount := 1 To Len(aMessages)
         cXMLRet += aMessages[nCount][1] + CRLF
      Next nCount
   EndIf
Return {lRet, cXMLRet}