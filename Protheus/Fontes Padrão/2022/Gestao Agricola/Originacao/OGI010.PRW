#Include 'OGI010.CH'
#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC

#Define MAX_FILE_LENGTH 600	//Tamanho maximo permitido para o XML gerado (em KB)

/*/{Protheus.doc} OGI010
//Adapter para Entidades
@author carlos.augusto
@since 18/06/2018
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Function OGI010( cXML, nTypeTrans, cTypeMessage )
	Local aArea		:= GetArea()			//Salva contexto do alias atual
	Local aAreaDX8	:= NJ0->(GetArea())	//Salva contexto do alias nju
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

	Local oXML 		  := Nil				//Objeto com o conteúdo do arquivo Xml
	Local oXMLEvent	  := Nil				//Objeto com o conteúdo da BusinessEvent apenas
	Local oXMLContent := Nil				//Objeto com o conteúdo da BusinessContent apenas

	Local cEntity	  := 'AgriculturalOwner'
	Local oModel 	  := Nil 				//Objeto com o model da rotina
	Local oModelNJ0   := Nil				//Objeto com o submodel de entidade
	Local cId 		  := ''				//Código InternalId
	Local cReferen    := ''				//Referencia. Normalmente a "marca" da mensagem: PROTHEUS / LOGIX / RM / DATASUL, etc.
	Local cAlias	  := 'NJ0'			//Alias do de/para (SA1, SA2, etc.)
	Local cField      := "NJ0_CODENT"	//É o campo de referencia do De/para (A1_COD, B1_COD, etc. )
	Local cValExt	  := ''				//Código externo para gravacao - Código InternalId do PIMS
	Local cValInt	  := ''				//Código interno para gravação

	Local cEntidade   := ""
	Local cLoja       := StrZero( 1 , TamSX3('NJ0_LOJENT')[1])
	Local cCGC		  := ""
	Local cCodEnt	  := ""
	Local lContinua	  := .T.
	Local lAtivar	  := .F.

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
					cXmlRet := STR0002 //'Erro no retorno. A Referencia/Marca é obrigatória!'
					//Carrega array de retorno
					aRet := {lRet, cXmlRet,  "AgriculturalOwner" }
					Return aRet
				EndIf

				oXMLEvent 	:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent
				oXMLContent := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent

				//Guarda o código da tabela recebido na mensagem.
				//Para utilização com De/Para, altere o código aqui para pegar o codigo da tabela XX5
				If ( XmlChildEx( oXMLContent, '_CODE' ) != Nil )
					cEntidade := oXMLContent:_Code:Text
				EndIf

				//-- Campo ID
				If ( XmlChildEx( oXMLContent, '_INTERNALID' ) != Nil )
					cID := PADR(oXMLContent:_InternalID:Text,TamSx3("NJ0_ID")[1] ," ")
				EndIf

				//Carrega model com estrutura da Tabela de Entidade
				oModel    := FwLoadModel( 'OGA010' )
				oModel:GetModel("NJ0UNICO"):GetStruct():SetProperty('NJ0_LOJENT', MODEL_FIELD_VALID,{|| ExistChav('NJ0',cCodEnt+cLoja) })
				oModel:GetModel("NJ0UNICO"):GetStruct():SetProperty('NJ0_CGC',    MODEL_FIELD_VALID,{|| Vazio() .Or. CGC(cCGC) })
				oModelNJ0 := oModel:GetModel('NJ0UNICO')	//Model Entidade

				//Posiciona tabela NJ0
				dbSelectArea('NJ0')
				NJ0->( dbSetOrder(7) )	//Filial  NJ0_ID
				lRet := NJ0->( DbSeek( fwxFilial('NJ0') + cID  ) )

				If lRet
					cCodEnt := PADR(cEntidade, TamSX3('NJ0_CODENT')[1],'')

					If cCodEnt != NJ0->NJ0_CODENT //Alterou o codigo da Entidade
						NJ0->( dbSetOrder(1) )
						If NJ0->( DbSeek( fwxFilial('NJ0') + cCodEnt + cLoja ) )
							lContinua := .F.
							cXMLRet := EncodeUTF8(STR0004) //"Já existe um registro integrado com este código."
						EndIf
					EndIf
				EndIf

				If lContinua

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

						If ( oModel:nOperation = MODEL_OPERATION_UPDATE )

							//Reposiciona
							NJ0->( dbSetOrder(7) )	//Filial  NJ0_ID
							NJ0->( DbSeek( fwxFilial('NJ0') + cID  ) )

							If cCodEnt != NJ0->NJ0_CODENT
								lRet	:= .F.
								cXMLRet := EncodeUTF8(STR0005) //"Não é permitido alterar o código da Entidade no Protheus."
							Else
								oModel:Activate()

								If lRet
									oModelNJ0:LoadValue('NJ0_CODENT', cCodEnt)
									oModelNJ0:LoadValue('NJ0_LOJENT', cLoja)
									oModelNJ0:LoadValue('NJ0_NOME'  , PADR(oXmlContent:_Name:Text, TamSX3('NJ0_NOME')[1],'')) //Nome
									oModelNJ0:LoadValue('NJ0_NOMLOJ', Substr(oXmlContent:_Name:Text, 1,TamSX3('NJ0_NOMLOJ')[1])) //Nome Reduzido
									oModelNJ0:LoadValue('NJ0_ATIVO','1')

									If ( XmlChildEx( oXMLContent, '_GOVERNMENTALINFORMATION' ) != Nil )

										If AllTrim( Upper( oXMLContent:_GOVERNMENTALINFORMATION:_ID:_NAME:TEXT ) ) == 'INSCRICAO ESTADUAL'
											oModelNJ0:LoadValue('NJ0_INSCR', PADR(oXMLContent:_GOVERNMENTALINFORMATION:_ID:TEXT, TamSX3('NJ0_INSCR')[1],'')) //inscrição estadual
										ElseIf AllTrim( Upper( oXMLContent:_GOVERNMENTALINFORMATION:_ID:_NAME:TEXT ) )  $ 'CPF|CNPJ'
											cCGC := oXMLContent:_GOVERNMENTALINFORMATION:_ID:TEXT
											cCGC := StrTran(cCGC,".","")
											cCGC := StrTran(cCGC,"/","")
											cCGC := StrTran(cCGC,"-","")
											oModelNJ0:LoadValue('NJ0_CGC', PADR(cCGC, TamSX3('NJ0_CGC')[1],'')) //CPF
										EndIf
									EndIf
								EndIf
							EndIf
						ElseIf ( oModel:nOperation = MODEL_OPERATION_INSERT )

							cCodEnt := PADR(cEntidade, TamSX3('NJ0_CODENT')[1],'')
							NJ0->( dbSetOrder(1) )
							lAtivar := NJ0->( DbSeek( fwxFilial('NJ0') + cCodEnt + cLoja ) )

							If lAtivar
								//Alteração
								oModel:SetOperation( MODEL_OPERATION_UPDATE )
							EndIf

							oModel:Activate()


							oModelNJ0:LoadValue('NJ0_FILIAL', fwxFilial('NJ0'))
							oModelNJ0:LoadValue('NJ0_CODENT', cCodEnt)
							oModelNJ0:LoadValue('NJ0_LOJENT'  , cLoja)
							oModelNJ0:LoadValue('NJ0_NOME'  , PADR(oXmlContent:_Name:Text, TamSX3('NJ0_NOME')[1],'')) //Nome
							oModelNJ0:LoadValue('NJ0_NOMLOJ', Substr(oXmlContent:_Name:Text, 1,TamSX3('NJ0_NOMLOJ')[1])) //Nome Reduzido
							oModelNJ0:LoadValue('NJ0_CLASSE'  , '1')
							If ( XmlChildEx( oXMLContent, '_GOVERNMENTALINFORMATION' ) != Nil )

								If AllTrim( Upper( oXMLContent:_GOVERNMENTALINFORMATION:_ID:_NAME:TEXT ) ) == 'INSCRICAO ESTADUAL'
									oModelNJ0:LoadValue('NJ0_INSCR', PADR(oXMLContent:_GOVERNMENTALINFORMATION:_ID:TEXT, TamSX3('NJ0_INSCR')[1],'')) //inscrição estadual
								ElseIf AllTrim( Upper( oXMLContent:_GOVERNMENTALINFORMATION:_ID:_NAME:TEXT ) )  $ 'CPF|CNPJ'
									cCGC := oXMLContent:_GOVERNMENTALINFORMATION:_ID:TEXT
									cCGC := StrTran(cCGC,".","")
									cCGC := StrTran(cCGC,"/","")
									cCGC := StrTran(cCGC,"-","")
									oModelNJ0:LoadValue('NJ0_CGC', PADR(cCGC, TamSX3('NJ0_CGC')[1],'')) //CPF
								EndIf
							EndIf
							oModelNJ0:LoadValue('NJ0_ID', cID)
							oModelNJ0:LoadValue('NJ0_ATIVO','1') //Registro Ativo
						EndIf

					Else
						//Exclusão
						//Relacionamento não vai deixar excluir, então, vamos desativar o registro
						oModel:SetOperation( MODEL_OPERATION_UPDATE )
						oModel:Activate()
						If ( !lRet )
							cXMLRet := EncodeUTF8(STR0001)	//'Registro não encontrado!'
						Else
							oModelNJ0:LoadValue('NJ0_ATIVO','2') //Registro Desativado
						EndIf
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
								cValInt := FWCodEmp() + "|" + FWCodFil() + "|" + oModelNJ0:GetValue('NJ0_CODENT')
								CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt , .F.,,, cEntity)
							Else
								cValInt := FWCodEmp() + "|" + FWCodFil() + "|" + oModelNJ0:GetValue('NJ0_CODENT')
								// Exclui o registro na tabela XXF (de/para)
								CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt , .T.,,, cEntity)
							EndIf

							//-- Monta o XML de Retorno
							cXmlRet := "<ListOfInternalId>"
							cXmlRet +=    "<InternalId>"
							cXmlRet +=       "<Name>" + cEntity + "</Name>"
							cXmlRet +=       "<Origin>" + cValExt + "</Origin>"
							cXmlRet += 		 "<Destination>" + FWCodEmp() + "|" + FWCodFil() + "|" + oModelNJ0:GetValue('NJ0_CODENT') + "</Destination>"
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
				cXMLRet := STR0002 // 'Erro na manipulação do Xml recebido. '
				cXMLRet += IIf ( !Empty(cError), cError, cWarning )

				cXMLRet := EncodeUTF8(cXMLRet)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Recebimento da Response Message                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )

			cXMLRet := 	'<Code>' + NJ0->NJ0_CODENT + '</Code>'

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Recebimento da WhoIs                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )

			cXMLRet := '1.000'

		EndIf

	ElseIf ( nTypeTrans == TRANS_SEND )
		oModel 	  := FWModelActive()				    //Instancia objeto model
		oModelNJ0 := oModel:GetModel( 'NJ0UNICO' )	//Instancia objeto model tabela especifica

		//Verifica se a tabela está sendo excluída
		If ( oModel:nOperation == 5 )
			cEvent := 'delete'
		EndIf

//		//Monta Business Event
//		cXMLRet := '<BusinessEvent>'
//		cXMLRet +=     '<Entity>AgriculturalOwner</Entity>'
//		cXMLRet +=     '<Event>' + cEvent + '</Event>'
//		cXMLRet +=     '<Identification>'
//		cXMLRet +=         '<key name="InternalID">' + fwxFilial("DX8") + "|" + oModelNJ0:GetValue('NJ0_CODENT') + oModelNJ0:GetValue('NJ0_LOJENT') + '</key>'
//		cXMLRet +=     '</Identification>'
//		cXMLRet += '</BusinessEvent>'
//
//		cXMLRet += '<BusinessContent>'
//		cXMLRet += 		'<Code>'       + oModelNJ0:GetValue('NJ0_CODENT') + '</Code>'
//		cXMLRet += 		'<Name>'       + oModelNJ0:GetValue('NJ0_NOME')   + '</Name>'
//		cXMLRet +=      '<Address>'
//		cXMLRet +=      	'<Address>'    + oModelNJ0:GetValue('DX8_END')     + '</Address>'
//		cXMLRet +=      	'<Complement>' + oModelNJ0:GetValue('DX8_ENDCPL')  + '</Complement>'
//		cXMLRet +=      	'<District>'   + oModelNJ0:GetValue('DX8_BAIRRO')  + '</District>'
//		cXMLRet +=      	'<ZipCode>'    + oModelNJ0:GetValue('DX8_CEP')     + '</ZipCode>'
//				
//		cXMLRet +=          '<City>'
//        cXMLRet +=          	'<CityCode>'         + oModelNJ0:GetValue('DX8_COD_MU')                 + '</CityCode>'
//        cXMLRet +=              '<CityInternalId>'   + cFilAnt + '|' + oModelNJ0:GetValue('DX8_COD_MU') + '</CityInternalId>'
//        cXMLRet +=              '<CityDescription>'  + oModelNJ0:GetValue('DX8_MUN')                    + '</CityDescription>'
//        cXMLRet +=          '</City>'
//        
//        cXMLRet +=          '<State>'
//        cXMLRet +=              '<StateCode>'         + oModelNJ0:GetValue('DX8_EST') + '</StateCode>'
//        cXMLRet +=              '<StateInternalId>'   + cFilAnt + '|' + oModelNJ0:GetValue('DX8_EST')  + '</StateInternalId>'
//        cXMLRet +=              '<StateDescription>'  + cUFDescr             + '</StateDescription>'
//        cXMLRet +=          '</State>"
//		
//		cXMLRet +=      '</Address>'
//		cXMLRet += 		'<OwnerRelationship>1</OwnerRelationship>'
//		cXMLRet += '</BusinessContent>'

		//Monta Business Event
//		 cXMLRet := '<BusinessEvent>'
//		cXMLRet +=     '<Entity>AgriculturalOwner</Entity>'
//		cXMLRet +=     '<Event>' + cEvent + '</Event>'
//		cXMLRet +=     '<Identification>'
//		cXMLRet +=         '<key name="InternalID">' + fwxFilial("NJ0") + "|" + oModelNJ0:GetValue('NJ0_CODENT') + oModelNJ0:GetValue('NJ0_LOJENT') + '</key>'
//		cXMLRet +=     '</Identification>'
//		cXMLRet += '</BusinessEvent>'
//
//		cXMLRet += '<BusinessContent>'
//		cXMLRet += '<Code>' + oModelNJ0:GetValue('NJ0_CODENT') + '</Code>'
//		cXMLRet += '<InternalId>||5654545</InternalId>'
//		cXMLRet += '<Name>' + oModelNJ0:GetValue('NJ0_NOME') + ' </Name>'
//		cXMLRet += '<EntityType>Person</EntityType>'
//		cXMLRet += '<GovernmentalInformation>'
//		cXMLRet += 		'<Id name="CPF" scope="Federal">27452572009</Id>'
//		cXMLRet += '</GovernmentalInformation>'
//		cXMLRet += '<Address>'
//		cXMLRet += 		'<Address>Prudente de Moraes</Address>'
//		cXMLRet += 		'<ZIPCode>454654654</ZIPCode>'
//		cXMLRet += 		'<POBox>4564654</POBox>'
//		cXMLRet += '</Address>'
//
//		cXMLRet += '<ListOfCommunicationInformation>'
//		cXMLRet += 		'<CommunicationInformation>'
//		cXMLRet += 			'<PhoneNumber>(18) 99732-7503</PhoneNumber>'
//		cXMLRet += 		'</CommunicationInformation>'
//		cXMLRet += '</ListOfCommunicationInformation>'
//
//		cXMLRet += '<OwnerRelationship>2</OwnerRelationship>'
//		cXMLRet += '</BusinessContent>'	

		cXMLRet := '<BusinessEvent>'
		cXMLRet +=     '<Entity>AgriculturalOwner</Entity>'
		cXMLRet +=     '<Event>' + cEvent + '</Event>'
		cXMLRet +=     '<Identification>'
		cXMLRet +=         '<key name="InternalID">' + fwxFilial("NJ0") + "|" + oModelNJ0:GetValue('NJ0_CODENT') + oModelNJ0:GetValue('NJ0_LOJENT') + '</key>'
		cXMLRet +=     '</Identification>'
		cXMLRet += '</BusinessEvent>'

		cXMLRet += '<BusinessContent>'
		cXMLRet += '<Code>' + oModelNJ0:GetValue('NJ0_NOME') + '</Code>'
		cXMLRet += '<InternalId>||8280565235582832599</InternalId>'
		cXMLRet += '<Name>AGRÍCOLA Y</Name>'
		cXMLRet += '<EntityType>Company</EntityType>'
		cXMLRet += '<GovernmentalInformation>'
		cXMLRet += 		'<Id name="CNPJ" scope="Federal">18.001.712/0001-10</Id>'
		cXMLRet += '</GovernmentalInformation>'
		cXMLRet += '<Address>'
		cXMLRet += 		'<Address>Prudente de Moraes</Address>'
		cXMLRet += 		'<ZIPCode>454654654</ZIPCode>'
		cXMLRet += 		'<POBox>4564654</POBox>'
		cXMLRet += '</Address>'

		cXMLRet += '<ListOfCommunicationInformation>'
		cXMLRet += 		'<CommunicationInformation>'
		cXMLRet += 			'<PhoneNumber>(18) 99732-7503</PhoneNumber>'
		cXMLRet += 		'</CommunicationInformation>'
		cXMLRet += '</ListOfCommunicationInformation>'

		cXMLRet += '<OwnerRelationship>2</OwnerRelationship>'
		cXMLRet += '</BusinessContent>'

	EndIf

	//Carrega array de retorno
	aRet := {lRet, cXmlRet, "AgriculturalOwner"}

	//Restaura ambiente
	FWRestRows( aSaveLine )
	RestArea(aAreaDX8)
	RestArea(aArea)

Return aRet
