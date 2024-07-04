#Include 'Protheus.ch'
#Include 'FWAdapterEAI.ch'
#Include 'PMSI200.ch'

#Define CRLF Chr(10) + Chr(13)

/*/{Protheus.doc} PMSI200B
Função para chamar o adapter de mensagem única de InternalID.

@description
Esta função é utilizada para enviar os InternalIDs alterados no Protheus
após a troca de código do projeto.

@author Mateus Gustavo de Freitas e Silva
@since 15/03/2014
@version P11

@param cXML, caracter, XML da mensagem única para envio/recebimento
@param nTypeTrans, numerico, Tipo de transacao. (0-Recebimento, 1-Envio)
@param cTypeMessage, numerico, Tipo de transação da Mensagem. (20-Business, 21-Response, 22-Receipt)

@return array, Array de duas posições sendo a primeira o resultado do processamento e a segunda o texto de resposta.

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
         cXMLRet := 'Recebimento não implementado!'
         aAdd(aMessages, {cXMLRet , 1, Nil})
      ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
         // Faz o parse do xml em um objeto
         oXml := XmlParser(cXml, "_", @cError, @cWarning)

         // Se não houve erros no parser
         If oXml <> Nil .And. Empty(cError) .And. Empty(cWarning)
            // Se não houve erros na resposta
            If Upper(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) != "OK"
               // Se não for array
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
           // Função chamada por outras funções. Exemplo: PMSI200 e PMSI203
           cXMLRet := cXml
        Else
           // Implementação local
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