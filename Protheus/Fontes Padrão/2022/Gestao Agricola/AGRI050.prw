#Include 'AGRI050.CH'
#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC

#Define MAX_FILE_LENGTH 600	//Tamanho maximo permitido para o XML gerado (em KB)

/*/{Protheus.doc} AGRI050
/Adapter de variedade
@author silvana.torres
@since 09/10/2017
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Function AGRI050( cXML, nTypeTrans, cTypeMessage )
	Local aArea		:= GetArea()		//Salva contexto do alias atual  
	Local aAreaNNV	:= NNV->(GetArea())	//Salva contexto do alias NNV
	Local aSaveLine	:= FWSaveRows()		//Salva contexto do model ativo

	Local aRet 		  := {}				//Array de retorno da função
	Local lRet 		  := .T.			//Indica o resultado da execução da função
	Local cXMLRet	  := ''				//Xml que será enviado pela função
	Local cError	  := ''				//Mensagem de erro do parse no xml recebido como parâmetro
	Local cWarning	  := ''				//Mensagem de alerta do parse no xml recebido como parâmetro
	Local cEvent	  := 'upsert'		//Operação realizada na master e na detail ( upsert ou delete )
	Local cCodigo	  := ''				//Codigo da variedade
	Local cCodPro	  := ''				//Codigo do produto
	Local cDescri	  := ''				//Descrição da variedade
	Local cID 		  := ''				//Código InternalId
	Local aMsgErro	  := {}				//Mensagem de erro na gravação do Model				
	Local cLogErro	  := ''				//Log de erro da execução da rotina
	Local cEntity	  := 'AgriculturalVariety'
	Local nI          := 0
	Local nCount	  := 0 

	//--- Variaveis do Retorno - Função CFGA070Mnt [http://tdn.totvs.com/pages/viewpage.action?pageId=173083053]
	Local cReferen    := ''				//Referencia. Normalmente a "marca" da mensagem: PROTHEUS / LOGIX / RM / DATASUL, etc.
	Local cAlias	  := 'NNV'			//Alias do de/para (SA1, SA2, etc.)
	Local cField      := "NNV_CODIGO"	//É o campo de referencia do De/para (A1_COD, B1_COD, etc. )
	Local cValExt	  := ''				//Código externo para gravacao - Código InternalId do PIMS
	Local cValInt	  := ''				//Código interno para gravação

	Local oXML 		  := Nil				//Objeto com o conteúdo do arquivo Xml
	Local oXMLEvent	  := Nil				//Objeto com o conteúdo da BusinessEvent apenas
	Local oXMLContent := Nil				//Objeto com o conteúdo da BusinessContent apenas
	Local lContinua	  := .T.
	Local aVldRel	  := {}
	
	Private oModel 	  := Nil 				//Objeto com o model da tabela de preços
	Private oModelNNV := Nil				//Objeto com o model da master apenas


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
					cXmlRet := STR0003 //'Erro no retorno. A Referencia/Marca é obrigatória!'
					//Carrega array de retorno
					aRet := {lRet, cXmlRet,  "AgriculturalVariety" } 
					Return aRet
				EndIf

				oXMLEvent 	:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent
				oXMLContent := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent

				//Guarda o código da tabela recebido na mensagem.
				//Para utilização com De/Para, altere o código aqui para pegar o codigo da tabela XX5
				If ( XmlChildEx( oXMLContent, '_CODE' ) != Nil )
					cCodigo := PADR(oXMLContent:_Code:Text,TamSx3("NNV_CODIGO")[1] ," ")
					If Empty(cCodigo)
						lRet := .F.
						cXmlRet := STR0009 //"É obrigatório informar o código da variedade."
						//Carrega array de retorno
						aRet := {lRet, cXmlRet,  "AgriculturalVariety" } 
						Return aRet
					EndIf

				EndIf

				If ( XmlChildEx( oXMLContent, '_INTERNALID' ) != Nil )
					cID := PADR(oXMLContent:_InternalId:Text,TamSx3("NNV_ID")[1] ," ")
				EndIf

				If ( XmlChildEx( oXMLContent, '_ITEMCODE' ) != Nil )
					cCodPro := PADR(oXMLContent:_ItemCode:Text,TamSx3("NNV_CODPRO")[1] ," ")
					If Empty(cCodPro)
						lRet := .F.
						cXmlRet := STR0010 //"É obrigatório informar o código do produto."
						//Carrega array de retorno
						aRet := {lRet, cXmlRet,  "AgriculturalVariety" } 
						Return aRet
					EndIf
				EndIf

				If ( XmlChildEx( oXMLContent, '_DESCRIPTION' ) != Nil )
					cDescri := PADR(oXMLContent:_Description:Text,TamSx3("NNV_DESCRI")[1] ," ")
				EndIf

				//Carrega model com estrutura da Tabela de Variedade
				oModel    := FwLoadModel( 'AGRA050' )	
				oModelNNV := oModel:GetModel('AGRA050_NNV')	//Model Safra	

				//Posiciona tabela NNV
				dbSelectArea('NNV')
				NNV->( dbSetOrder(3) )	// NNV_FILIAL + NNV_ID
				lRet := NNV->( DbSeek( fwxFilial('NNV') + cID  ) )

				If lRet
					If cCodigo != NNV->NNV_CODIGO //Alterou o codigo da Variedade
						NNV->( dbSetOrder(1) ) //NNV_FILIAL+NNV_CODPRO+NNV_CODIGO 
						If NNV->( DbSeek( fwxFilial('NNV') + cCodPro + cCodigo) )
							lContinua := .F.
							cXMLRet := EncodeUTF8(STR0011) //"Já existe um registro integrado com este código."
						EndIf
					EndIf
				EndIf

				If lContinua

					//Verifica a operação realizada
					If ( Upper( oXMLEvent:_Event:Text ) == 'UPSERT' )
						If lRet
							lRet := .T.
							//Alteração
							oModel:SetOperation( MODEL_OPERATION_UPDATE )
						Else
							lRet := .T.
							//Inclusão
							oModel:SetOperation( MODEL_OPERATION_INSERT )
						EndIf
					Else
						lRet := .T.
						//Exclusão do registro quando operação for Delete.
						//Para registro com movimentações o retorno será mensagem do model para o adapter.
						oModel:SetOperation( MODEL_OPERATION_DELETE )
					EndIf

					//Controla Transação por Causa do Produto			

					If ( oModel:nOperation = MODEL_OPERATION_UPDATE )

						//Reposiciona
						NNV->( dbSetOrder(3) )	// NNV_FILIAL + NNV_ID
						NNV->( DbSeek( fwxFilial('NNV') + cID  ) )
						If cCodigo != NNV->NNV_CODIGO
							aVldRel := NNVVldRel(NNV->NNV_CODIGO)
							lRet := aVldRel[1]
							cXMLRet := aVldRel[2]
						EndIf
						
						If lRet
							oModel:Activate()
							If lRet
								lRet := oModelNNV:SetValue('NNV_DESCRI',cDescri)
							EndIf
							If lRet
								lRet := oModelNNV:LoadValue('NNV_CODIGO',cCodigo)
							EndIf
							If lRet
								lRet := ExistCpo('SB1',cCodPro,1) 
								If lRet
									lRet := oModelNNV:LoadValue('NNV_CODPRO',cCodPro)
								Else
									lRet := .F. //"Produto inválido." "Produto não cadastrado no Protheus: "
									oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0012, STR0013 + cCodPro, "", "")
								EndIf
							EndIf
						EndIf

					ElseIf ( oModel:nOperation = MODEL_OPERATION_INSERT )
						oModel:Activate()

						If lRet
							lRet := oModelNNV:SetValue('NNV_FILIAL',fwxFilial('NNV'))
						EndIf
						If lRet
							lRet := oModelNNV:SetValue('NNV_CODPRO',cCodPro)
						EndIf
						If lRet	
							lRet := oModelNNV:SetValue('NNV_CODIGO',cCodigo)
						EndIf
						If lRet	
							lRet := oModelNNV:SetValue('NNV_DESCRI',cDescri)
						EndIf
						If lRet
							lRet := oModelNNV:SetValue('NNV_ID',cID)
						EndIf

					ElseIf (oModel:nOperation = MODEL_OPERATION_DELETE )
						//Reposiciona
						NNV->( dbSetOrder(3) )	// NNV_FILIAL + NNV_ID
						NNV->( DbSeek( fwxFilial('NNV') + cID  ) )
						oModel:Activate()	
					EndIf

					If lRet

						If lRet := oModel:VldData()
							//Grava o model
							lRet := oModel:CommitData()
						Endif
					EndIf
					If !lRet
						If Empty(cXMLRet)
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
							cXMLRet := EncodeUTF8( cXMLRet )
						EndIf
					Else 
						//--------------------------------------------
						//--- TRATAMENTO DE RETORNO PARA O DE/PARA
						//--------------------------------------------
						cValExt := cID
						// Se o evento é diferente de DELETE
						If oModel:nOperation != MODEL_OPERATION_DELETE
							//--EMPRESA - FILIAL - CODIGO 
							cValInt := FWCodEmp() + "|" + FWCodFil() + "|" + oModelNNV:GetValue('NNV_CODIGO') 
							CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt , .F.,,, cEntity)
						Else
							//--EMPRESA - FILIAL - CODIGO 
							cValInt := FWCodEmp() + "|" + FWCodFil() + "|" + oModelNNV:GetValue('NNV_CODIGO') 
							// Exclui o registro na tabela XXF (de/para)
							CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt , .T.,,, cEntity)
						EndIf

						//-- Monta o XML de Retorno
						cXmlRet := "<ListOfInternalId>"
						cXmlRet +=    "<InternalId>"
						cXmlRet +=       "<Name>" + cEntity + "</Name>"
						cXmlRet +=       "<Origin>" + cValExt + "</Origin>"
						cXmlRet += 		 "<Destination>" + FWCodEmp() + "|" + FWCodFil() + "|" + oModelNNV:GetValue('NNV_CODIGO') + "</Destination>"
						cXmlRet +=    "</InternalId>"
						cXmlRet += "</ListOfInternalId>"
					EndIf				

					oModel:Deactivate()
					oModel:Destroy()
				EndIf
			Else
				//Tratamento no erro do parse Xml
				lRet    := .F.
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
					cXmlRet := STR0003 //'Erro no retorno. A Referencia/Marca é obrigatória!'
					AdpLogEAI(5, "AGRI050", cXMLRet, lRet)
					//Carrega array de retorno
					aRet := {lRet, cXmlRet,  "AgriculturalVariety" } 
					Return aRet
				EndIf

				If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") = "U"
					// Verifica se o código interno foi informado
					If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text") = "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text)
						cValInt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text
					Else
						lRet    := .F.
						cXmlRet := STR0004 //'Erro no retorno. O OriginalInternalId é obrigatório!'
						//Carrega array de retorno
						aRet := {lRet, cXmlRet,  "AgriculturalVariety" } 
						Return aRet
					EndIf

					// Verifica se o código externo foi informado
					If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text") = "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text)
						cValExt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text
					Else
						lRet    := .F.
						cXmlRet := STR0005 //'Erro no retorno. O DestinationInternalId é obrigatório!'
						//Carrega array de retorno
						aRet := {lRet, cXmlRet,  "AgriculturalVariety" } 
						Return aRet
					EndIf

					// Obtém a mensagem original enviada
					If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") = "U" .And. !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
						cXML := oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
					Else
						lRet    := .F.
						cXmlRet := STR0006 //'Conteúdo do MessageContent vazio!'
						//Carrega array de retorno
						aRet := {lRet, cXmlRet,  "AgriculturalVariety" } 
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
							cXmlRet := STR0007 //'Evento do retorno inválido!'
						EndIf
					Else
						lRet := .F.
						cXmlRet := STR0008 //'Erro no parser do retorno!'
						//Carrega array de retorno
						aRet := {lRet, cXmlRet, "AgriculturalVariety" } 
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
		oModel 	  := FWModelActive()				//Instancia objeto model
		oModelNNV := oModel:GetModel( 'AGRA050_NNV' )	//Instancia objeto model tabela especifica

		//Verifica se a tabela está sendo excluída
		If ( oModel:nOperation == 5 )
			cEvent := 'delete'
		EndIf

		//Monta Business Event
		cXMLRet := '<BusinessEvent>'
		cXMLRet +=     '<Entity>'+ cEntity +'</Entity>'
		cXMLRet +=     '<Event>' + cEvent + '</Event>'
		cXMLRet += '</BusinessEvent>'

		cXMLRet += '<BusinessContent>'
		cXMLRet += 	'<Code>' + oModelNNV:GetValue('NNV_DESCRI') + '</Code>'
		cXMLRet += 	'<InternalID>' + fwxFilial("NNV") + "|" + oModelNNV:GetValue('NNV_CODIGO') + '</InternalID>'
		cXMLRet += 	'<ItemCode>' + oModelNNV:GetValue('NNV_CODPRO') + '</ItemCode>'            
		cXMLRet += 	'<Description>'	+ oModelNNV:GetValue('NNV_DESCRI') + '</Description>'     
		cXMLRet += '</BusinessContent>'	
	EndIf

	//-------------------------------------
	//-- Carrega array de retorno - PARA INTEGRAÇÃO
	aRet := {lRet, cXmlRet, "AgriculturalVariety"}
	//-------------------------------------

	//Restaura ambiente
	FWRestRows( aSaveLine )     
	RestArea(aAreaNNV)
	RestArea(aArea)

Return aRet


/*/{Protheus.doc} NNVVldRel
//Verifica Integridade 
@author carlos.augusto
@since 03/07/2018
@version undefined
@param cNN2Codigo, characters, descricao
@type function
/*/
Static Function NNVVldRel(cNNVCodigo)
	Local aArea	    := GetArea()
	Local cMensagem	:= ""
	Local lRetorno	:= .T.
	Local cNN4_TALHAO
	Local cDXL_CODIGO
	
	cNN4_TALHAO := GetDataSql("SELECT NN4_TALHAO res FROM " + RetSqlName("NN4") + " NN4 " + ;
							" WHERE NN4.D_E_L_E_T_ = ' ' " +;
							" AND NN4.NN4_FILIAL = '" + FWXFILIAL("NN4") + "' " + ;
							" AND NN4.NN4_CODVAR = '" + cNNVCodigo + "'")
	If Empty(cNN4_TALHAO)
		cDXL_CODIGO := GetDataSql("SELECT DXL_CODIGO res FROM " + RetSqlName("DXL") + " DXL " + ;
								" WHERE DXL.D_E_L_E_T_ = ' ' " +;
								" AND DXL.DXL_FILIAL = '" + FWXFILIAL("DXL") + "' " + ;
								" AND DXL.DXL_CODVAR = '" + cNNVCodigo + "'")
		If .Not. Empty(cDXL_CODIGO)
			lRetorno := .F.
			cMensagem += STR0014 + cDXL_CODIGO + "." //"Encontrado relacionamento da variedade com o fardão: "
		EndIf			
	Else
		lRetorno := .F.
		cMensagem += STR0015 + cNN4_TALHAO + "." //"Encontrado relacionamento da variedade com o talhão: " 
	EndIF
	RestArea(aArea)
	
	
Return {lRetorno,cMensagem}