#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC
#INCLUDE 'AGRI005.CH'		//Include da rotina 

#Define MAX_FILE_LENGTH 600	//Tamanho maximo permitido para o XML gerado (em KB)

/*/{Protheus.doc} AGRI050
//- INTEGRAÇÃO FAZENDA 

@author bruna.rocio
@since 28/07/2017
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Function AGRI005( cXML, nTypeTrans, cTypeMessage )
	Local aArea		:= GetArea()		//Salva contexto do alias atual  
	Local aAreaNN2	:= NN2->(GetArea())	//Salva contexto do alias NN2
	Local aSaveLine	:= FWSaveRows()		//Salva contexto do model ativo

	Local aRet 		  := {}				//Array de retorno da função
	Local lRet 		  := .T.			//Indica o resultado da execução da função
	Local cXMLRet	  := ''				//Xml que será enviado pela função
	Local cError	  := ''				//Mensagem de erro do parse no xml recebido como parâmetro
	Local cWarning	  := ''				//Mensagem de alerta do parse no xml recebido como parâmetro
	Local cEvent	  := 'upsert'		//Operação realizada na master e na detail ( upsert ou delete )
	Local aMsgErro	  := {}				//Mensagem de erro na gravação do Model				
	Local cLogErro	  := ''				//Log de erro da execução da rotina
	Local nI          := 0 
	Local cCodFaz     := ''
	Local cID 		  := ''				//Código InternalId
	Local cEntity	  := 'Farm'
	Local nCount	  := 0 	

	//--- Variaveis do Retorno - Função CFGA070Mnt [http://tdn.totvs.com/pages/viewpage.action?pageId=173083053]
	Local cReferen    := ''				//Referencia. Normalmente a "marca" da mensagem: PROTHEUS / LOGIX / RM / DATASUL, etc.
	Local cAlias	  := 'NN2'			//Alias do de/para (SA1, SA2, etc.)
	Local cField      := "NN2_CODIGO"	//É o campo de referencia do De/para (A1_COD, B1_COD, etc. )
	Local cValExt	  := ''				//Código externo para gravacao - Código InternalId do PIMS
	Local cValInt	  := ''				//Código interno para gravação

	Local oXML 		  := Nil			//Objeto com o conteúdo do arquivo Xml
	Local oXMLEvent	  := Nil			//Objeto com o conteúdo da BusinessEvent apenas
	Local oXMLContent := Nil			//Objeto com o conteúdo da BusinessContent apenas

	Local oModel 	  := Nil 			//Objeto com o model da rotina de fazenda
	Local oModelNN2   := Nil			//Objeto com o submodel de fazenda
	Local aEntidade	  := {}


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
					cXmlRet := STR0001 //'Erro no retorno. A Referencia/Marca é obrigatória!'
					//Carrega array de retorno
					aRet := {lRet, cXmlRet,  "FAZENDA" } 
					Return aRet
				EndIf

				oXMLEvent 	:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent
				oXMLContent := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent
				
				If ( XmlChildEx( oXMLContent, '_CODE' ) != Nil )
					cCodFaz := PADR(oXMLContent:_Code:Text,TamSx3("NN2_CODIGO")[1] ," ")
				EndIf

				If ( XmlChildEx( oXMLContent, '_INTERNALID' ) != Nil )
					cID := PADR(oXMLContent:_InternalId:Text,TamSx3("NN2_ID")[1] ," ")
				EndIf
				
				//Carrega model com estrutura da Tabela de Fazenda
				oModel    := FwLoadModel( 'AGRA005' )	
				oModelNN2 := oModel:GetModel('AGRA005_NN2')	//Model Fazenda	

				//Posiciona tabela NN2
				dbSelectArea('NN2')
				NN2->(dbSetOrder(4))	//Filial + ID
				lRet := NN2->(dbSeek(FWxFilial('NN2') + cID))

				//Verifica a operação realizada
				If ( Upper( oXMLEvent:_Event:Text ) == 'UPSERT' )
					If lRet
						//Alteração
						oModel:SetOperation( MODEL_OPERATION_UPDATE )
					Else
						lRet := .T.
						//Inclusão
						oModel:SetOperation( MODEL_OPERATION_INSERT )
					EndIf
				ElseIf ( Upper( oXMLEvent:_Event:Text ) == 'DELETE' )
					lRet := .T.

					//Exclusão do registro quando operação for Delete.
					//Para registro com movimentações o retorno será mensagem do model para o adapter.
					oModel:SetOperation( MODEL_OPERATION_DELETE )
				EndIf
				
				// --- Validação Entidade e loja
				If ( oXmlContent:_AgriculturalOwnerCode:Text != Nil )
					If At( "||" , oXmlContent:_AgriculturalOwnerCode:Text ) > 0
						aEntidade := StrTokArr(oXmlContent:_AgriculturalOwnerCode:Text,"||")
					Else
						lRet := .F.

						cXmlRet := "Tag _AgriculturalOwnerCode sem caracterer de Entidade/Loja. Favor atualizar o ambiente PIMS"
						//Carrega array de retorno
						aRet := {lRet, cXmlRet,  "FAZENDA" }
						Return aRet							
					EndIf
				else
					lRet := .F.
					cXmlRet := "Entidade não encontrada no formulario. Favor verificar a tag '_AgriculturalOwnerCode' "
					//Carrega array de retorno
					aRet := {lRet, cXmlRet,  "FAZENDA" }
					Return aRet					
				EndIf
				
				If len(aEntidade) == 0
					lRet := .F.
					cXmlRet := "_AgriculturalOwnerCode com valor nulo ou falha no formato. Favor informar a Entidade e Loja com os separadores '||' . Exemplo: 000001||01 "
					//Carrega array de retorno
					aRet := {lRet, cXmlRet,  "FAZENDA" }
					Return aRet
				ElseIf len(aEntidade) == 1 //Somente o codigo foi enviado
						dbSelectArea('NJ0')
						NJ0->( dbSetOrder(1) )
						If NJ0->( DbSeek( fwxFilial('NJ0') + aEntidade[1] ) )
							aadd(aEntidade,NJ0->NJ0_LOJENT)
						Else
							aadd(aEntidade,StrZero( 1 , TamSX3('NJ0_LOJENT')[1])) //padrão
						EndIf
				Endif
				// caso sejam enviados mais caracteres que o lado do protheus esteja preparado para receber, 
				//é preciso emitir uma mensagem para que o administrador do sistema siga com as adequações necessárias.
				If Len(aEntidade[2]) > TamSX3( "NN2_LJPRO" )[1] 
					lRet := .F.
					cXmlRet := "Loja do Produtor com tamanho maior que a configurada no Protheus. Favor verificar com o administrador para as adequações necessárias."
					//Carrega array de retorno
					aRet := {lRet, cXmlRet,  "FAZENDA" }
					Return aRet
				elseif Len(aEntidade[2]) < TamSX3( "NN2_LJPRO" )[1] 
					//preenche com "0" os espaços que faltam
					aEntidade[2] := PadL( aEntidade[2] , TamSX3( "NN2_LJPRO" )[1] , "0" )
				EndIf
				//----------------------------------------
				oModel:Activate()
								
				If ( oModel:nOperation = MODEL_OPERATION_UPDATE )
					oModelNN2:setValue('NN2_NOME',oXmlContent:_Description:Text)
					oModelNN2:setValue('NN2_PRDTOR',aEntidade[1])
					oModelNN2:setValue('NN2_LJPRO', IIF(Len(aEntidade)==2,aEntidade[2],'01') )
				ElseIf ( oModel:nOperation = MODEL_OPERATION_INSERT )
					oModelNN2:setValue('NN2_FILIAL',FWxFilial('NN2'))
					oModelNN2:setValue('NN2_CODFIL',FWCodFil())
					oModelNN2:setValue('NN2_CODIGO',cCodFaz)
					oModelNN2:setValue('NN2_ID',cID)
					oModelNN2:setValue('NN2_NOME'  ,oXmlContent:_Description:Text)
					//Aqui eu assumo que o produtor já foi previamente cadastrado. Por isso setValue.
					oModelNN2:setValue('NN2_PRDTOR',aEntidade[1])
					oModelNN2:setValue('NN2_LJPRO', IIF(Len(aEntidade)==2,aEntidade[2],'01') )
					oModelNN2:loadValue('NN2_ATIVA' ,'A')
					
				EndIf	
				
				If lRet
					
					If lRet := oModel:VldData()
						//Grava o model
						lRet := oModel:CommitData()
					Endif
					
					If !lRet
						//Trata erro de gravação do model
						aMsgErro := oModel:GetErrorMessage()
						cLogErro := ''

						For nI := 1 To Len(aMsgErro)

							If ( ValType( aMsgErro[nI] ) == 'C' )
								cLogErro += aMsgErro[nI] + '|'
							EndIf 

						Next nI

						// Monta XML de Erro de execução da rotina automatica.
						cXMLRet := EncodeUTF8( cLogErro )
					Else 
						//--------------------------------------------
						//--- TRATAMENTO DE RETORNO PARA O DE/PARA
						//--------------------------------------------
						cValExt := cID
						// Se o evento é diferente de DELETE
						If oModel:nOperation != MODEL_OPERATION_DELETE
							//--EMPRESA - FILIAL - CODIGO 
							//cValInt := FWCodEmp() + "|" + FWCodFil() + "|" + oModelNN2:GetValue('NN2_CODIGO')
							cValInt := oModelNN2:GetValue('NN2_CODIGO') 
							CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt , .F.,,, cEntity)
						Else
							//--EMPRESA - FILIAL - CODIGO 
							//cValInt := FWCodEmp() + "|" + FWCodFil() + "|" + oModelNN2:GetValue('NN2_CODIGO') 
							cValInt := oModelNN2:GetValue('NN2_CODIGO')
							// Exclui o registro na tabela XXF (de/para)
							CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt , .T.,,, cEntity)
						EndIf
						
						//-- Monta o XML de Retorno
						cXmlRet := "<ListOfInternalId>"
						cXmlRet +=    "<InternalId>"
						cXmlRet +=       "<Name>" + cEntity + "</Name>"
						cXmlRet +=       "<Origin>" + cValExt + "</Origin>"
						cXmlRet += 		 "<Destination>" + oModelNN2:GetValue('NN2_CODIGO') + "</Destination>"
						cXmlRet +=    "</InternalId>"
						cXmlRet += "</ListOfInternalId>"
						//cXmlRet += 		 "<Destination>" + FWCodEmp() + "|" + FWCodFil() + "|" + oModelNN2:GetValue('NN2_CODIGO') + "</Destination>"					
					EndIf

				EndIf
				oModel:Deactivate()
				oModel:Destroy()
				
			Else
				//Tratamento no erro do parse Xml
				lRet := .F.
				cXMLRet := STR0002 //'Erro na manipulação do Xml recebido. '
				cXMLRet += IIf ( !Empty(cError), cError, cWarning )

				cXMLRet := EncodeUTF8(cXMLRet)
			EndIf
						
		//----------------------------------------------------------------------
		//--- RECEBIMENTO DA RESPONSEMESSAGE 
		//-- QUEM RECEBE É O PIMS - O MESMO É TRATADO PELA EQUIPE DO PIMS
		//-- REALIZADO NO FONTE É PARA TESTE COM INTEGRAÇÃO PROTHEUS X PROTHEUS
		//----------------------------------------------------------------------
		ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )

	         //--Faz o parser do XML de retorno em um objeto
	         oXML := xmlParser(cXML, "_", @cError, @cWarning)
	
	         //-- Se não houve erros na resposta
	         If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
	            // Verifica se a marca foi informada
	            If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") = "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
	               cReferen := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0001 //'Erro no retorno. A Referencia/Marca é obrigatória!'
	               AdpLogEAI(5, "AGRI005", cXMLRet, lRet)
	               //Carrega array de retorno
	               aRet := {lRet, cXmlRet,  "FAZENDA" } 
	               Return aRet
	            EndIf
				 
				 If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") = "U"
		            // Verifica se o código interno foi informado
		            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text") = "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text)
		               cValInt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text
		            Else
		               lRet    := .F.
		               cXmlRet := STR0003 //'Erro no retorno. O OriginalInternalId é obrigatório!'
		               //Carrega array de retorno
		               aRet := {lRet, cXmlRet,  "FAZENDA" } 
		               Return aRet
		            EndIf
		
		            // Verifica se o código externo foi informado
		            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text") = "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text)
		               cValExt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text
		            Else
		               lRet    := .F.
		               cXmlRet := STR0004 //'Erro no retorno. O DestinationInternalId é obrigatório!'
		               //Carrega array de retorno
		               aRet := {lRet, cXmlRet,  "FAZENDA" } 
		               Return aRet
		            EndIf
		
		            // Obtém a mensagem original enviada
		            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") = "U" .And. !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
		               cXML := oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
		            Else
		               lRet    := .F.
		               cXmlRet := STR0005 //'Conteúdo do MessageContent vazio!'
		               //Carrega array de retorno
		               aRet := {lRet, cXmlRet,  "FAZENDA" } 
		               Return aRet
		            EndIf
		
		            // Faz o parse do XML em um objeto
		            oXML := XmlParser(cXML, "_", @cError, @cWarning)
		
		            // Se não houve erros no parse
		            If oXML <> Nil .And. Empty(cError) .And. Empty(cWarning)
		               If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
		                  // Insere / Atualiza o registro na tabela XXF (de/para)
						  CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt, .F.,,, cEntity)
		               ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
		                  // Exclui o registro na tabela XXF (de/para)
						  CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt, .T.,,, cEntity)
		               Else
		                  lRet := .F.
		                  cXmlRet := STR0006 //'Evento do retorno inválido!'
		               EndIf
		            Else
		               lRet := .F.
		               cXmlRet := STR0007 //'Erro no parser do retorno!'
		               //Carrega array de retorno
		               aRet := {lRet, cXmlRet, "FAZENDA" } 
		               Return aRet
		            EndIf
		         Endif
	         Else
	            // Se não for array
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

	ElseIf ( nTypeTrans == TRANS_SEND )
		oModel 	  := FWModelActive()				    //Instancia objeto model
		oModelNN2 := oModel:GetModel( 'AGRA005_NN2' )	//Instancia objeto model tabela especifica
	
		//Verifica se a tabela está sendo excluída
		If ( oModel:nOperation == 5 )
			cEvent := 'delete'
		EndIf

		//Monta Business Event
		cXMLRet := '<BusinessEvent>'
		cXMLRet +=     '<Entity>' + cEntity + '</Entity>'
		cXMLRet +=     '<Event>' + cEvent + '</Event>'
		cXMLRet += '</BusinessEvent>'

		cXMLRet += '<BusinessContent>'
		cXMLRet += 	'<Code>' + oModelNN2:GetValue('NN2_CODIGO') + '</Code>'
		cXMLRet += 	'<InternalId>' + FWxFilial("NN2") + "|" + oModelNN2:GetValue('NN2_CODIGO') + '</InternalId>'
		cXMLRet += 	'<Description>' + oModelNN2:GetValue('NN2_NOME') + '</Description>'
		cXMLRet += 	'<AgriculturalOwnerCode>' + oModelNN2:GetValue('NN2_PRDTOR') + '</AgriculturalOwnerCode>'
		//os campos abaixo não são usado no PROTHEUS
		cXMLRet +=  '<AgriculturalOwnerInternalId>' + '2' + '</AgriculturalOwnerInternalId>'
		cXMLRet +=  '<FarmRelationship>'     + ' 1 ' +       '</FarmRelationship>'
		cXMLRet += '</BusinessContent>'	
	EndIf

	//Carrega array de retorno
	aRet := {lRet, cXmlRet, "FAZENDA"}

	//Restaura ambiente
	FWRestRows( aSaveLine )     
	RestArea(aAreaNN2)
	RestArea(aArea)

Return aRet
