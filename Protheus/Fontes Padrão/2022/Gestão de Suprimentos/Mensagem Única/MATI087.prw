#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWADAPTEREAI.CH"


// --------------------------------------------------------------------------------------
/*/{Protheus.doc} MATI087 
Função de integração com o adapter EAI para envio de usuário.

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   nTypeTrans    Tipo de transação. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Raphael Augustos
@version P11.8
@since   13/05/2013
@return  lRet - (boolean)  Indica o resultado da execução da função
         cXmlRet - (caracter) Mensagem XML para envio
/*/
// --------------------------------------------------------------------------------------

Function MATI087(cXml,nTypeTrans,cTypeMessage)
Local lRet       := .T. 		//Retorno do EAI     
Local cXMLRet    := ""  		//Retorno do EAI
Local cEvent     := "upsert" 	//Evento padrão da BusinessMessage Inserção|Alteração
Local cNumUser   := ""			// Código do usuário SY1->Y1_COD

Private oXmlM087   := Nil   

//Tratamento do recebimento de mensagens
If ( nTypeTrans == TRANS_RECEIVE )

	//-- Recebimento da WhoIs - Qual é a versão da mensagem
	If	( cTypeMessage == EAI_MESSAGE_WHOIS )
		cXMLRet := '4.001'
	//-- Recebimento da Response Message
	ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )

		cXMLRet := "OK"

	//-- Receipt Message (Aviso de receb. em transmissoes assincronas)
	ElseIf ( cTypeMessage == EAI_MESSAGE_RECEIPT )

		cXMLRet := "OK"

	//-- Recebimento da Business Message
	ElseIf ( cTypeMessage == EAI_MESSAGE_BUSINESS )	

	EndIf
	
//Tratamento do envio de mensagens	
ElseIf nTypeTrans == TRANS_SEND
	
	cNumUser   := SY1->Y1_USER
	aUser      := FWSFALLUSERS({SY1->Y1_USER})
	If Valtype(aUser) == "A" .And. Len(aUser) > 0
		cLogin     := aUser[1][3]	
		//-- Inclusao ou Alteracao
		If Inclui .Or. Altera
			//Monta XML de envio de mensagem unica
			cXMLRet := '<BusinessEvent>'
			cXMLRet +=     '<Entity>USER</Entity>'
			cXMLRet +=     '<Event>' + cEvent + '</Event>'
			cXMLRet +=     '<Identification>'
			cXMLRet +=         '<key name="InternalId">' + cNumUser + '</key>'
			cXMLRet +=     '</Identification>'	
			cXMLRet += '</BusinessEvent>'			
			cXMLRet    +=	'<BusinessContent>'
			cXMLRet    += 		'<Code>'+ cNumUser +'</Code>'    
			cXMLRet    +=		'<InternalId>' + cNumUser + '</InternalId>'
			cXMLRet    +=	    '<Name>'+ AllTrim(SY1->Y1_NOME) +'</Name>'
			cXMLRet    +=	    '<Login>' + cLogin +  '</Login>'
			cXMLRet    +=	    '<ActiveInactiveStatus>true</ActiveInactiveStatus>'
			cXMLRet    +=	    '<CommunicationInformation>'
			cXMLRet    +=	        '<PhoneNumber>' + Alltrim(SY1->Y1_TEL) + '</PhoneNumber>'
			cXMLRet    +=	        '<PhoneExtension></PhoneExtension>'
			cXMLRet    +=	        '<FaxNumber>' + AllTrim(SY1->Y1_FAX) + '</FaxNumber>'
			cXMLRet    +=	        '<FaxNumberExtension></FaxNumberExtension>'
			cXMLRet    +=	        '<HomePage></HomePage>'
			cXMLRet    +=	        '<Email>' + AllTrim(SY1->Y1_EMAIL) + '</Email>'
			cXMLRet    +=	    '</CommunicationInformation>'
			cXMLRet    +=	'</BusinessContent>'
		//-- Exclusao
		Else
			cEvent     := "delete" 
			cXMLRet := '<BusinessEvent>'
			cXMLRet +=     '<Entity>USER</Entity>'
			cXMLRet +=     '<Event>' + cEvent + '</Event>'
			cXMLRet +=     '<Identification>'
			cXMLRet +=         '<key name="InternalId">'+ cNumUser + '</key>'
			cXMLRet +=     '</Identification>'	
			cXMLRet += '</BusinessEvent>'
			cXMLRet    +=	'<BusinessContent>'
			cXMLRet    += 		'<Code>'+ cNumUser +'</Code>'    
			cXMLRet    +=		'<InternalId>' + cNumUser + '</InternalId>'
			cXMLRet    +=	'</BusinessContent>'		
		EndIf
	Else
		lRet := .F.
		cXMLRet := "Problema ao enviar o comprador: " + AllTrim(SY1->Y1_USER)
	EndIf
EndIf    
                  
Return { lRet, cXMLRet }