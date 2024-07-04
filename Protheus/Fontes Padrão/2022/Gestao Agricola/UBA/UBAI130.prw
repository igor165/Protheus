#Include 'UBAW130.CH'
#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integra��o com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC

#Define MAX_FILE_LENGTH 600	//Tamanho maximo permitido para o XML gerado (em KB)


/*/{Protheus.doc} UBAI130
//Adapter Periodo Produtivo
@author carlos.augusto
@since 29/06/2018
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Function UBAI130( cXML, nTypeTrans, cTypeMessage )
	Local aArea		:= GetArea()		//Salva contexto do alias atual  
	Local aSaveLine	:= FWSaveRows()		//Salva contexto do model ativo

	Local aRet 		  := {}				//Array de retorno da fun��o
	Local lRet 		  := .T.			//Indica o resultado da execu��o da fun��o
	Local cXMLRet	  := ''				//Xml que ser� enviado pela fun��o
	Local cError	  := ''				//Mensagem de erro do parse no xml recebido como par�metro
	Local cWarning	  := ''				//Mensagem de alerta do parse no xml recebido como par�metro
	Local cReferen    := ''				//Referencia. Normalmente a "marca" da mensagem: PROTHEUS / LOGIX / RM / DATASUL, etc.
	Local oXML 		  := Nil				//Objeto com o conte�do do arquivo Xml

	//*************************************
	// Trata o recebimento de mensagem                              
	//*************************************
	If ( nTypeTrans == TRANS_RECEIVE )

		//*********************************
		// Recebimento da Business Message
		//*********************************
		If ( cTypeMessage == EAI_MESSAGE_BUSINESS )
			oXML := tXmlManager():New()
			oXML := XmlParser( cXML, '_', @cError, @cWarning )	

			If ( ( oXML <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) ) )

				//-- Verifica se a marca foi informada
				If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") = "U" .And. !Empty(oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
					cReferen := oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					lRet := .F.
					cXmlRet := STR0002 //'Erro no retorno. A Referencia/Marca � obrigat�ria!'
					//Carrega array de retorno
					aRet := {lRet, cXmlRet,  "ProductionPeriod" } 
					Return aRet
				EndIf
			Else
				//Tratamento no erro do parse Xml
				lRet    := .F.
				cXMLRet := STR0002 //'Erro na manipula��o do Xml recebido. '
				cXMLRet += IIf ( !Empty(cError), cError, cWarning )

				cXMLRet := EncodeUTF8(cXMLRet)
			EndIf
		ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )

			//--------------------------------------------
			//--- RECEBIMENTO DA WHOIS   
			//--------------------------------------------			
		ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )
			cXMLRet := "1.000|1.001|1.002"
		EndIf
	ElseIf ( nTypeTrans == TRANS_SEND )
	EndIf
	//-------------------------------------
	//-- Carrega array de retorno - PARA INTEGRA��O
	aRet := {lRet, cXmlRet, "ProductionPeriod"}
	//-------------------------------------

	//Restaura ambiente
	FWRestRows( aSaveLine )     
	RestArea(aArea)

Return aRet

