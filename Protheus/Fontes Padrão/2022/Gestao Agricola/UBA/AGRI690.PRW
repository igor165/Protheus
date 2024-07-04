#Include 'AGRI690.CH'
#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC

#Define MAX_FILE_LENGTH 600	//Tamanho maximo permitido para o XML gerado (em KB)

/*/{Protheus.doc} AGRI050
//TODO Descrição auto-gerada.
@author bruna.rocio
@since 28/07/2017
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Function AGRI690( cXML, nTypeTrans, cTypeMessage )
	Local aArea		:= GetArea()			//Salva contexto do alias atual  
	Local aAreaDX8	:= DX8->(GetArea())	//Salva contexto do alias nju
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

	Local oModel 	  := Nil 				//Objeto com o model da rotina
	Local oModelDX8   := Nil				//Objeto com o submodel de produtor

	Local cProdutor   := ""
	Local cLoja       := StrZero( 1 , TamSX3('DX8_LOJA')[1])
	

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

				oXMLEvent 	:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent
				oXMLContent := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent

				If ( XmlChildEx( oXMLContent, '_OWNERRELATIONSHIP' ) != Nil ) .And. oXMLContent:_OwnerRelationship:Text == "2"
																					
					//Guarda o código da tabela recebido na mensagem.
					//Para utilização com De/Para, altere o código aqui para pegar o codigo da tabela XX5
					If ( XmlChildEx( oXMLContent, '_CODE' ) != Nil )
						cProdutor := oXMLContent:_Code:Text
					EndIf
					
					//Carrega model com estrutura da Tabela de Safra
					oModel    := FwLoadModel( 'AGRA690' )	
					oModelDX8 := oModel:GetModel('DX8MASTER')	//Model Safra	
					
					oModelDX8:GetStruct():SetProperty('DX8_END',MODEL_FIELD_OBRIGAT, .F.)
	
					//Posiciona tabela DX8
					dbSelectArea('DX8')
					DX8->( dbSetOrder(1) )	//Filial + Produtor + Loja
					lRet := DX8->( dbSeek( fwxFilial('DX8') + PADR(cProdutor,TamSX3('DX8_CODIGO')[1],' ') + PADR(cLoja,TamSX3('DX8_LOJA')[1],' ') ) )
					
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
						
						oModel:Activate()
									
						If ( oModel:nOperation = MODEL_OPERATION_UPDATE )
		
							oModelDX8:SetValue('DX8_NOME'  , PADR(oXmlContent:_Name:Text, TamSX3('DX8_NOME')[1],'')) //Nome
							oModelDX8:SetValue('DX8_NMREDU', Substr(oXmlContent:_Name:Text, 1,TamSX3('DX8_NMREDU')[1])) //Nome Reduzido
							
							If ( XmlChildEx( oXMLContent, '_ADDRESS' ) != Nil )
								If ( XmlChildEx( oXMLContent:_Address, '_ADDRESS' ) != Nil )
									oModelDX8:SetValue('DX8_END'   , PADR(oXMLContent:_Address:_Address:Text   , TamSX3('DX8_END')[1],''))    //Endereço
								EndIf
								If ( XmlChildEx( oXMLContent:_Address, '_ZIPCode' ) != Nil )
									oModelDX8:SetValue('DX8_CEP'   , PADR(oXMLContent:_Address:_ZIPCode:Text   , TamSX3('DX8_CEP')[1],''))    //CEP
								EndIf
							EndIf
							
							
							If ( XmlChildEx( oXMLContent, '_GOVERNMENTALINFORMATION' ) != Nil )
									
								If AllTrim( Upper( oXMLContent:_GOVERNMENTALINFORMATION:_ID:_NAME:TEXT ) ) == 'INSCRICAO ESTADUAL'
									oModelDX8:SetValue('DX8_INSCR', PADR(oXMLContent:_GOVERNMENTALINFORMATION:_ID:TEXT, TamSX3('DX8_INSCR')[1],'')) //inscrição estadual
								ElseIf AllTrim( Upper( oXMLContent:_GOVERNMENTALINFORMATION:_ID:_NAME:TEXT ) )  $ 'CPF'
									oModelDX8:SetValue('DX8_CGC', PADR(oXMLContent:_GOVERNMENTALINFORMATION:_ID:TEXT, TamSX3('DX8_CGC')[1],'')) //CPF
									oModelDX8:SetValue('DX8_TIPENT', PADR("F", TamSX3('DX8_TIPENT')[1],'')) //Fisica
								ElseIf AllTrim( Upper( oXMLContent:_GOVERNMENTALINFORMATION:_ID:_NAME:TEXT ) )  $ 'CNPJ'
									oModelDX8:SetValue('DX8_CGC', PADR(oXMLContent:_GOVERNMENTALINFORMATION:_ID:TEXT, TamSX3('DX8_CGC')[1],'')) //CNPJ
									oModelDX8:SetValue('DX8_TIPENT', PADR("J", TamSX3('DX8_TIPENT')[1],'')) //J
								EndIf
							EndIf
							
						ElseIf ( oModel:nOperation = MODEL_OPERATION_INSERT )
							
							oModelDX8:SetValue('DX8_FILIAL', fwxFilial('DX8'))
							oModelDX8:SetValue('DX8_CODIGO', PADR(cProdutor, TamSX3('DX8_CODIGO')[1],''))
							oModelDX8:SetValue('DX8_LOJA'  , cLoja)
							
							oModelDX8:SetValue('DX8_NOME'  , PADR(oXmlContent:_Name:Text, TamSX3('DX8_NOME')[1],'')) //Nome
							oModelDX8:SetValue('DX8_NMREDU', Substr(oXmlContent:_Name:Text, 1,TamSX3('DX8_NMREDU')[1])) //Nome Reduzido
							
							If ( XmlChildEx( oXMLContent, '_ADDRESS' ) != Nil )
								If ( XmlChildEx( oXMLContent:_Address, '_ADDRESS' ) != Nil )
									oModelDX8:SetValue('DX8_END'   , PADR(oXMLContent:_Address:_Address:Text   , TamSX3('DX8_END')[1],''))    //Endereço
								EndIf
								If ( XmlChildEx( oXMLContent:_Address, '_ZIPCode' ) != Nil )
									oModelDX8:SetValue('DX8_CEP'   , PADR(oXMLContent:_Address:_ZIPCode:Text   , TamSX3('DX8_CEP')[1],''))    //CEP
								EndIf
							EndIf
	
							If ( XmlChildEx( oXMLContent, '_GOVERNMENTALINFORMATION' ) != Nil )
									
								If AllTrim( Upper( oXMLContent:_GOVERNMENTALINFORMATION:_ID:_NAME:TEXT ) ) == 'INSCRICAO ESTADUAL'
									oModelDX8:SetValue('DX8_INSCR', PADR(oXMLContent:_GOVERNMENTALINFORMATION:_ID:TEXT, TamSX3('DX8_INSCR')[1],'')) //inscrição estadual
								ElseIf AllTrim( Upper( oXMLContent:_GOVERNMENTALINFORMATION:_ID:_NAME:TEXT ) )  $ 'CPF'
									oModelDX8:SetValue('DX8_CGC', PADR(oXMLContent:_GOVERNMENTALINFORMATION:_ID:TEXT, TamSX3('DX8_CGC')[1],'')) //CPF
									oModelDX8:SetValue('DX8_TIPENT', PADR("F", TamSX3('DX8_TIPENT')[1],'')) //Fisica
								ElseIf AllTrim( Upper( oXMLContent:_GOVERNMENTALINFORMATION:_ID:_NAME:TEXT ) )  $ 'CNPJ'
									oModelDX8:SetValue('DX8_CGC', PADR(oXMLContent:_GOVERNMENTALINFORMATION:_ID:TEXT, TamSX3('DX8_CGC')[1],'')) //CNPJ
									oModelDX8:SetValue('DX8_TIPENT', PADR("J", TamSX3('DX8_TIPENT')[1],'')) //J
								EndIf
							EndIf						
																																					
							oModelDX8:SetValue('DX8_ATIVO','1') //Registro Ativo
						EndIf			
						
					Else
						//Exclusão
						//Relacionamento não vai deixar excluir, então, vamos desativar o registro
						oModel:SetOperation( MODEL_OPERATION_UPDATE )
						oModel:Activate()
						If ( !lRet )
							cXMLRet := EncodeUTF8(STR0001)	//'Registro não encontrado!'
						Else
							oModelDX8:LoadValue('DX8_ATIVO','2') //Registro Desativado
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
						EndIf
	
					EndIf
					oModel:Deactivate()
					oModel:Destroy()
				
				ElseIf ( XmlChildEx( oXMLContent, '_OWNERRELATIONSHIP' ) != Nil ) .And. oXMLContent:_OwnerRelationship:Text == "1"
					cXMLRet := EncodeUTF8('Realizar desenvolvimento para criar filial')
					lRet := .F.
					
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
			
			cXMLRet := 	'<Code>' + DX8->DX8_CODIGO + '</Code>'

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Recebimento da WhoIs                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )

			cXMLRet := '1.000'

		EndIf	

	ElseIf ( nTypeTrans == TRANS_SEND )
		oModel 	  := FWModelActive()				    //Instancia objeto model
		oModelDX8 := oModel:GetModel( 'DX8MASTER' )	//Instancia objeto model tabela especifica
	
		//Verifica se a tabela está sendo excluída
		If ( oModel:nOperation == 5 )
			cEvent := 'delete'
		EndIf

//		//Monta Business Event
//		cXMLRet := '<BusinessEvent>'
//		cXMLRet +=     '<Entity>AgriculturalOwner</Entity>'
//		cXMLRet +=     '<Event>' + cEvent + '</Event>'
//		cXMLRet +=     '<Identification>'
//		cXMLRet +=         '<key name="InternalID">' + fwxFilial("DX8") + "|" + oModelDX8:GetValue('DX8_CODIGO') + oModelDX8:GetValue('DX8_LOJA') + '</key>'
//		cXMLRet +=     '</Identification>'
//		cXMLRet += '</BusinessEvent>'
//
//		cXMLRet += '<BusinessContent>'
//		cXMLRet += 		'<Code>'       + oModelDX8:GetValue('DX8_CODIGO') + '</Code>'
//		cXMLRet += 		'<Name>'       + oModelDX8:GetValue('DX8_NOME')   + '</Name>'
//		cXMLRet +=      '<Address>'
//		cXMLRet +=      	'<Address>'    + oModelDX8:GetValue('DX8_END')     + '</Address>'
//		cXMLRet +=      	'<Complement>' + oModelDX8:GetValue('DX8_ENDCPL')  + '</Complement>'
//		cXMLRet +=      	'<District>'   + oModelDX8:GetValue('DX8_BAIRRO')  + '</District>'
//		cXMLRet +=      	'<ZipCode>'    + oModelDX8:GetValue('DX8_CEP')     + '</ZipCode>'
//				
//		cXMLRet +=          '<City>'
//        cXMLRet +=          	'<CityCode>'         + oModelDX8:GetValue('DX8_COD_MU')                 + '</CityCode>'
//        cXMLRet +=              '<CityInternalId>'   + cFilAnt + '|' + oModelDX8:GetValue('DX8_COD_MU') + '</CityInternalId>'
//        cXMLRet +=              '<CityDescription>'  + oModelDX8:GetValue('DX8_MUN')                    + '</CityDescription>'
//        cXMLRet +=          '</City>'
//        
//        cXMLRet +=          '<State>'
//        cXMLRet +=              '<StateCode>'         + oModelDX8:GetValue('DX8_EST') + '</StateCode>'
//        cXMLRet +=              '<StateInternalId>'   + cFilAnt + '|' + oModelDX8:GetValue('DX8_EST')  + '</StateInternalId>'
//        cXMLRet +=              '<StateDescription>'  + cUFDescr             + '</StateDescription>'
//        cXMLRet +=          '</State>"
//		
//		cXMLRet +=      '</Address>'
//		cXMLRet += 		'<OwnerRelationship>1</OwnerRelationship>'
//		cXMLRet += '</BusinessContent>'

		//Monta Business Event 
		/* cXMLRet := '<BusinessEvent>'
		cXMLRet +=     '<Entity>AgriculturalOwner</Entity>'
		cXMLRet +=     '<Event>' + cEvent + '</Event>'
		cXMLRet +=     '<Identification>'
		cXMLRet +=         '<key name="InternalID">' + fwxFilial("DX8") + "|" + oModelDX8:GetValue('DX8_CODIGO') + oModelDX8:GetValue('DX8_LOJA') + '</key>'
		cXMLRet +=     '</Identification>'
		cXMLRet += '</BusinessEvent>'

		cXMLRet += '<BusinessContent>'
		cXMLRet += '<Code>999997</Code>'
		cXMLRet += '<InternalId>||5654545</InternalId>'
		cXMLRet += '<Name>Carlos</Name>'
		cXMLRet += '<EntityType>Person</EntityType>'
		cXMLRet += '<GovernmentalInformation>'
		cXMLRet += 		'<Id name="CPF" scope="Federal">27452572009</Id>'
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
		cXMLRet += '</BusinessContent>'		*/
		
	EndIf

	//Carrega array de retorno
	aRet := {lRet, cXmlRet, "PRODUTOR"}

	//Restaura ambiente
	FWRestRows( aSaveLine )     
	RestArea(aAreaDX8)
	RestArea(aArea)

Return aRet
