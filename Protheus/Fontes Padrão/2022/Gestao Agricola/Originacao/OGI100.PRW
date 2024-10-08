#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integra��o com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC
#Include 'OGI100.CH'

#Define MAX_FILE_LENGTH 600	//Tamanho maximo permitido para o XML gerado (em KB)

/*/{Protheus.doc} OGI100
//Adapter Safra
@author bruna.rocio
@since 28/07/2017
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Function OGI100( cXML, nTypeTrans, cTypeMessage )
	Local aArea		:= GetArea()		//Salva contexto do alias atual  
	Local aAreaNJU	:= NJU->(GetArea())	//Salva contexto do alias nju
	Local aSaveLine	:= FWSaveRows()		//Salva contexto do model ativo

	Local aRet 		  := {}				//Array de retorno da fun��o
	Local lRet 		  := .T.			//Indica o resultado da execu��o da fun��o	
	Local cXMLRet	  := ''				//Xml que ser� enviado pela fun��o
	Local cError	  := ''				//Mensagem de erro do parse no xml recebido como par�metro
	Local cWarning	  := ''				//Mensagem de alerta do parse no xml recebido como par�metro
	Local cEvent	  := 'upsert'		//Opera��o realizada na master e na detail ( upsert ou delete )
	Local cCodSaf	  := ''				//Codigo da safra
	Local cId 		  := ''				//C�digo InternalId
	Local aMsgErro	  := {}				//Mensagem de erro na grava��o do Model				
	Local cLogErro	  := ''				//Log de erro da execu��o da rotina
	Local cEntity	  := 'AgriculturalYear'
	Local nI          := 0 
	Local nCount	  := 0

	Local oXML 		  := Nil			//Objeto com o conte�do do arquivo Xml
	Local oXMLEvent	  := Nil			//Objeto com o conte�do da BusinessEvent apenas
	Local oXMLContent := Nil			//Objeto com o conte�do da BusinessContent apenas

	//--- Variaveis do Retorno - Fun��o CFGA070Mnt [http://tdn.totvs.com/pages/viewpage.action?pageId=173083053]
	Local cReferen    := ''				//Referencia. Normalmente a "marca" da mensagem: PROTHEUS / LOGIX / RM / DATASUL, etc.
	Local cAlias	  := 'NJU'			//Alias do de/para (SA1, SA2, etc.)
	Local cField      := "NJU_CODSAF"	//� o campo de referencia do De/para (A1_COD, B1_COD, etc. )
	Local cValExt	  := ''				//C�digo externo para gravacao - C�digo InternalId do PIMS
	Local cValInt	  := ''				//C�digo interno para grava��o
	Local lContinua	  := .T.

	Private oModel 	  := Nil 			//Objeto com o model da tabela de pre�os
	Private oModelNJU := Nil			//Objeto com o model da master apenas

	//--------------------------------------------
	//-- Trata o recebimento de mensagem                              
	//--------------------------------------------
	If ( nTypeTrans == TRANS_RECEIVE )

		//--------------------------------------------
		//-- Recebimento da Business Message
		//--------------------------------------------
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
					aRet := {lRet, cXmlRet,  "AgriculturalYear" } 
					Return aRet
				EndIf

				oXMLEvent 	:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent
				oXMLContent := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent

				//Guarda o c�digo da tabela recebido na mensagem.
				//-- Campo SAFRA
				If ( XmlChildEx( oXMLContent, '_CODE' ) != Nil )
					cCodSaf := PADR(oXMLContent:_Code:Text,TamSx3("NJU_CODSAF")[1] ," ")
				EndIf

				//-- Campo ID
				If ( XmlChildEx( oXMLContent, '_INTERNALID' ) != Nil )
					cID := PADR(oXMLContent:_InternalID:Text,TamSx3("NJU_ID")[1] ," ")
				EndIf

				//Carrega model com estrutura da Tabela de Safra
				oModel    := FwLoadModel( 'OGA100' )	
				oModelNJU := oModel:GetModel('NJUUNICO')	//Model Safra	

				//Posiciona tabela NJU
				dbSelectArea('NJU')
				NJU->( dbSetOrder(2) )	//Filial + Safra | NJU_FILIAL + NJU_ID
				lRet := NJU->( DbSeek( fwxFilial('NJU') + cID  ) )

				If lRet
					cCodSaf := PADR(cCodSaf, TamSX3('NJU_CODSAF')[1],'')

					If cCodSaf != NJU->NJU_CODSAF //Alterou o codigo da Safra
						NJU->( dbSetOrder(1) )
						If NJU->( DbSeek( fwxFilial('NJU') + cCodSaf) )
							lContinua := .F.
							cXMLRet := EncodeUTF8(STR0009) // "J� existe um registro integrado com este c�digo."
						EndIf
					EndIf
				EndIf

				If lContinua

					//Verifica a opera��o realizada
					If ( Upper( oXMLEvent:_Event:Text ) == 'UPSERT' )
						If lRet
							//Altera��o
							oModel:SetOperation( MODEL_OPERATION_UPDATE )
						Else
							lRet := .T.
							//Inclus�o
							oModel:SetOperation( MODEL_OPERATION_INSERT )
						EndIf
					ElseIf ( Upper( oXMLEvent:_Event:Text ) == 'DELETE' )
						//Exclus�o do registro quando opera��o for Delete.
						//Para registro com movimenta��es o retorno ser� mensagem do model para o adapter.
						oModel:SetOperation( MODEL_OPERATION_DELETE )
						lRet	:= .T.
					EndIf

					If ( oModel:nOperation = MODEL_OPERATION_UPDATE )

						//Reposiciona
						NJU->( dbSetOrder(2) )	//Filial + Safra | NJU_FILIAL + NJU_ID
						NJU->( DbSeek( fwxFilial('NJU') + cID  ) )
						If cCodSaf != NJU->NJU_CODSAF
							lRet	:= .F.
							cXMLRet := EncodeUTF8(STR0010) //"N�o � permitido alterar o c�digo da Safra no Protheus."
						Else
							oModel:Activate()
							
							oModelNJU:LoadValue('NJU_CODSAF',cCodSaf)
							oModelNJU:SetValue('NJU_DESCRI',oXmlContent:_Description:Text)
						EndIf
					ElseIf ( oModel:nOperation = MODEL_OPERATION_INSERT )

						oModel:Activate()

						oModelNJU:SetValue('NJU_FILIAL',fwxFilial('NJU'))
						oModelNJU:SetValue('NJU_CODSAF',cCodSaf)
						oModelNJU:SetValue('NJU_DESCRI',oXmlContent:_Description:Text)
						oModelNJU:SetValue('NJU_ID'    ,cID)

					ElseIf (oModel:nOperation = MODEL_OPERATION_DELETE )
						//Reposiciona
						NJU->( dbSetOrder(2) )	//Filial + Safra | NJU_FILIAL + NJU_ID
						NJU->( DbSeek( fwxFilial('NJU') + cID  ) )
						oModel:Activate()	
					EndIf			

					If lRet
						If lRet := oModel:VldData()
							//Grava o model
							lRet := oModel:CommitData()
						Endif

						If !lRet
							//Trata erro de grava��o do model
							aMsgErro := oModel:GetErrorMessage()
							cLogErro := ''
							For nI := 1 To Len(aMsgErro)
								If ( ValType( aMsgErro[nI] ) == 'C' )
									cLogErro += aMsgErro[nI] + '|'
								EndIf 
							Next nI

							// Monta XML de Erro de execu��o da rotina automatica.
							cXMLRet := EncodeUTF8( cLogErro )
						Else 
							//--------------------------------------------
							//--- TRATAMENTO DE RETORNO PARA O DE/PARA
							//--------------------------------------------
							cValExt := cID
							// Se o evento � diferente de DELETE
							If oModel:nOperation != MODEL_OPERATION_DELETE
								cValInt := FWCodEmp() + "|" + FWCodFil() + "|" + oModelNJU:GetValue('NJU_CODSAF') 
								CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt , .F.,,, cEntity)
							Else
								cValInt := FWCodEmp() + "|" + FWCodFil() + "|" + oModelNJU:GetValue('NJU_CODSAF') 
								// Exclui o registro na tabela XXF (de/para)
								CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt , .T.,,, cEntity)
							EndIf

							//-- Monta o XML de Retorno
							cXmlRet := "<ListOfInternalId>"
							cXmlRet +=    "<InternalId>"
							cXmlRet +=       "<Name>" + cEntity + "</Name>"
							cXmlRet +=       "<Origin>" + cValExt + "</Origin>"
							cXmlRet += 		 "<Destination>" + FWCodEmp() + "|" + FWCodFil() + "|" + oModelNJU:GetValue('NJU_CODSAF') + "</Destination>"
							cXmlRet +=    "</InternalId>"
							cXmlRet += "</ListOfInternalId>"
						EndIf
					EndIf

					oModel:Deactivate()
					oModel:Destroy()
				EndIf
			Else
				//Tratamento no erro do parse Xml
				lRet := .F.
				cXMLRet := STR0001
				cXMLRet += IIf ( !Empty(cError), cError, cWarning )

				cXMLRet := EncodeUTF8(cXMLRet)
			EndIf

			//----------------------------------------------------------------------
			//--- RECEBIMENTO DA RESPONSEMESSAGE 
			//-- QUEM RECEBE � O PIMS - O MESMO � TRATADO PELA EQUIPE DO PIMS
			//-- REALIZADO NO FONTE � PARA TESTE COM INTEGRA��O PROTHEUS X PROTHEUS
			//----------------------------------------------------------------------
		ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )

			//--Faz o parser do XML de retorno em um objeto
			oXML := xmlParser(cXML, "_", @cError, @cWarning)

			//-- Se n�o houve erros na resposta
			If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
				// Verifica se a marca foi informada
				If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") = "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
					cReferen := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					lRet    := .F.
					cXmlRet := STR0002 //'Erro no retorno. A Referencia/Marca � obrigat�ria!'
					AdpLogEAI(5, "OGI100", cXMLRet, lRet)
					//Carrega array de retorno
					aRet := {lRet, cXmlRet,  "AgriculturalYear" } 
					Return aRet
				EndIf

				If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") = "U"
					// Verifica se o c�digo interno foi informado
					If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text") = "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text)
						cValInt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text
					Else
						lRet    := .F.
						cXmlRet := STR0003 //'Erro no retorno. O OriginalInternalId � obrigat�rio!'
						//Carrega array de retorno
						aRet := {lRet, cXmlRet,  "AgriculturalYear" } 
						Return aRet
					EndIf

					// Verifica se o c�digo externo foi informado
					If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text") = "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text)
						cValExt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text
					Else
						lRet    := .F.
						cXmlRet := STR0004 //'Erro no retorno. O DestinationInternalId � obrigat�rio!'
						//Carrega array de retorno
						aRet := {lRet, cXmlRet,  "AgriculturalYear" } 
						Return aRet
					EndIf

					// Obt�m a mensagem original enviada
					If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") = "U" .And. !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
						cXML := oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
					Else
						lRet    := .F.
						cXmlRet := STR0005 //'Conte�do do MessageContent vazio!'
						//Carrega array de retorno
						aRet := {lRet, cXmlRet,  "AgriculturalYear" } 
						Return aRet
					EndIf

					// Faz o parse do XML em um objeto
					oXML := XmlParser(cXML, "_", @cError, @cWarning)

					// Se n�o houve erros no parse
					If oXML <> Nil .And. Empty(cError) .And. Empty(cWarning)
						If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
							// Insere / Atualiza o registro na tabela XXF (de/para)
							CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt, .F.,,, cEntity)
						ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
							// Exclui o registro na tabela XXF (de/para)
							CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt, .T.,,, cEntity)
						Else
							lRet := .F.
							cXmlRet := STR0006 //'Evento do retorno inv�lido!'
						EndIf
					Else
						lRet := .F.
						cXmlRet := STR0007 //'Erro no parser do retorno!'
						//Carrega array de retorno
						aRet := {lRet, cXmlRet, "AgriculturalYear" } 
						Return aRet
					EndIf
				Endif
			Else
				// Se n�o for array
				If Type("oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
					// Transforma em array
					XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
				EndIf

				// Percorre o array para obter os erros gerados
				For nCount := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
					cError := oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + Chr(10)
				Next nCount

				lRet := .F.
				cXmlRet := cError
			EndIf

			//--------------------------------------------
			//--- RECEBIMENTO DA WHOIS   
			//--------------------------------------------			
		ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )
			cXMLRet := "1.000|1.001|1.002"
		EndIf	

		//--------------------------------------------
		//--- ENVIO PARA INTEGRA��O 
		//--------------------------------------------
	ElseIf ( nTypeTrans == TRANS_SEND )
		oModel 	  := FWModelActive()				//Instancia objeto model
		oModelNJU := oModel:GetModel( 'NJUUNICO' )	//Instancia objeto model tabela especifica

		//Verifica se a tabela est� sendo exclu�da
		If ( oModel:nOperation == 5 )
			cEvent := 'delete'
		EndIf

		//Monta Business Event
		cXMLRet := '<BusinessEvent>'
		cXMLRet +=     '<Entity>' + cEntity + '</Entity>'
		cXMLRet +=     '<Event>' + cEvent + '</Event>'
		cXMLRet += '</BusinessEvent>'

		cXMLRet += '<BusinessContent>'
		cXMLRet += 	'<Code>' + oModelNJU:GetValue('NJU_DESCRI') + '</Code>'
		cXMLRet +=  '<InternalID>' + FWCodFil() + "|" + oModelNJU:GetValue('NJU_CODSAF') + '</InternalID>'
		cXMLRet += 	'<Description>'   + oModelNJU:GetValue('NJU_DESCRI') + '</Description>'
		cXMLRet += '</BusinessContent>'	
	EndIf

	//-------------------------------------
	//-- Carrega array de retorno - PARA INTEGRA��O
	aRet := {lRet, cXmlRet,  "AgriculturalYear" } 
	//-------------------------------------

	//Restaura ambiente
	FWRestRows( aSaveLine )     
	RestArea(aAreaNJU)
	RestArea(aArea)

Return aRet