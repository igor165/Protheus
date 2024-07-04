#INCLUDE "AGRI010.CH"
#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC

#Define MAX_FILE_LENGTH 600	//Tamanho maximo permitido para o XML gerado (em KB)

/*/{Protheus.doc} AGRI010
//Integração Talhoes
@author carlos.augusto
@since 11/10/2017
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Function AGRI010( cXML, nTypeTrans, cTypeMessage )
	Local aArea		:= GetArea()			//Salva contexto do alias atual  
	Local aAreaNN3	:= NN3->(GetArea())	//Salva contexto do alias NN3
	Local aAreaNN4	:= NN4->(GetArea())	//Salva contexto do alias NN4
	Local aSaveLine	:= FWSaveRows()		//Salva contexto do model ativo

	Local aRet 		  := {}				//Array de retorno da função
	Local lRet 		  := .T.			//Indica o resultado da execução da função
	Local cXMLRet	  := ''				//Xml que será enviado pela função
	Local cError	  := ''				//Mensagem de erro do parse no xml recebido como parâmetro
	Local cWarning	  := ''				//Mensagem de alerta do parse no xml recebido como parâmetro
	Local cEvent	  := 'upsert'		//Operação realizada na master e na detail ( upsert ou delete )
	Local cCodTal	  := ''				//Codigo do talhao
	Local cDesTal	  := ''				//Descricao do talhao
	Local cCodFaz	  := ''				//Codigo da Fazenda
	Local cCodSet	  := ''				//Codigo do Setor
	Local cCodSaf	  := ''				//Codigo da safra
	Local cID		  := ''				//Código InternalId INtegração PIMS 
	Local aCodVar	  := {}				//Array das Variedades
	Local aQtdVar	  := {}				//Array das Quantidades - Quantidade de Area Produtiva (ha)
	Local cQtdArea	  := ''
	Local nCount      := 0
	Local nVar		  := 0				//Quantidade de variedades
	Local lEncVar	  := .F.
	Local aMsgErro	  := {}				//Mensagem de erro na gravação do Model				
	Local cLogErro	  := ''				//Log de erro da execução da rotina
	Local nI          := 0 
	Local cEntity	  := 'PartOfLand'

	//--- Variaveis do Retorno - Função CFGA070Mnt [http://tdn.totvs.com/pages/viewpage.action?pageId=173083053]
	Local cReferen    := ''				//Referencia. Normalmente a "marca" da mensagem: PROTHEUS / LOGIX / RM / DATASUL, etc.
	Local cAlias	  := 'NN3'			//Alias do de/para (SA1, SA2, etc.)
	Local cField      := "NN3_TALHAO"	//É o campo de referencia do De/para (A1_COD, B1_COD, etc. )
	Local cValExt	  := ''				//Código externo para gravacao - Código InternalId do PIMS
	Local cValInt	  := ''				//Código interno para gravação
	Local cValIntOld  := ''				//Código interno para gravação anterior
	Local cTalhaoOld  := ''				//Codigo do talhao anterior na tabela XXF

	Local oXML 		  := Nil				//Objeto com o conteúdo do arquivo Xml
	Local oXMLEvent	  := Nil				//Objeto com o conteúdo da BusinessEvent apenas
	Local oXMLContent := Nil				//Objeto com o conteúdo da BusinessContent apenas
	Local lUpdate	  := .F.				//Variavel para controlar alteracao de internalId
	Local lContinua	  := .T.
	Local cTalXml	  := ""
	Local lAtivar	  := .F.
	Local aVldRel	  := {}
	
	Private _oModel    := Nil 				//Objeto com o model da tabela de preços
	Private _oModelNN3 := Nil				//Objeto com o model da master apenas
	Private _oModelNN4 := Nil				//Objeto com o model da master apenas

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
					cXmlRet := STR0004 //'Erro no retorno. A Referencia/Marca é obrigatória!'
					//Carrega array de retorno
					aRet := {lRet, cXmlRet,  "PartOfLand" } 
					Return aRet
				EndIf

				oXMLEvent 	:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent
				oXMLContent := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent

				//Guarda o código da tabela recebido na mensagem.
				//Para utilização com De/Para, altere o código aqui para pegar o codigo da tabela XX5

				//-- InternalID esta em Event > Identification na tag <Key > 
				//-- Verificar se é extamente assim que o PIMS envia o InternalID
				/* 	Elemento: InternalID
				Description: InternalID
				Type: Char
				Length: 136 - verificar qual o tamanho que o PIMS enviará o InternalId
				Field: NN3_ID
				Required: sim */
				If ( XmlChildEx( oXMLContent, '_INTERNALID' ) != Nil )
					cID := PADR(oXMLContent:_InternalID:Text,TamSx3("NN3_ID")[1] ," ")
				EndIf

				/* 	Elemento: Code
				Description: Codigo do Talhao
				Type: Char
				Length: 10 (6)
				Field: NN3_TALHAO
				Required: sim */
				If ( XmlChildEx( oXMLContent, '_CODE' ) != Nil )
					cCodTal := AllTrim(oXMLContent:_Code:Text)
				EndIf

				/* 	Elemento: Description
				Description: Descricao do Talhao
				Type: Char
				Length: 40
				Field:NN3_DESCRI
				Required: sim */
				If ( XmlChildEx( oXMLContent, '_DESCRIPTION' ) != Nil )
					cDesTal := AllTrim(oXMLContent:_Description:Text)
				EndIf

				/* 	Elemento: FarmCode
				Description: Codigo da Fazenda
				Type: Char
				Length: 2
				Field: NN3_FAZ
				Required: sim */
				If ( XmlChildEx( oXMLContent, '_FARMCODE' ) != Nil )
					cCodFaz := PADR(oXMLContent:_FarmCode:Text,TamSx3("NN2_CODIGO")[1] ," ")
				EndIf

				/* 	Elemento: AgriculturalSectorCode
				Description: Codigo do Setor
				Type: Number
				Length: 10 (4)
				Field: 
				Required: sim */
				If ( XmlChildEx( oXMLContent, '_AGRICULTURALSECTORCODE' ) != Nil )
					cCodSet := AllTrim(oXMLContent:_AgriculturalSectorCode:Text)
				EndIf


				/* 	Elemento: AgriculturalYearCode
				Description: Codigo do Ano Agrícola
				Type: Char
				Length: 15
				Field: NN3_SAFRA
				Required: sim */
				If ( XmlChildEx( oXMLContent, '_AGRICULTURALYEARCODE' ) != Nil )
					cCodSaf := PADR(oXMLContent:_AgriculturalYearCode:Text,TamSx3("NJU_CODSAF")[1] ," ")
				EndIf

				If ( XmlChildEx( oXMLContent, '_PRODUCTIONPERIODCODE' ) != Nil )
					cCodPer := PADR(oXMLContent:_ProductionPeriodCode:Text,10 ," ")
				EndIf


				/* 	Elemento: QuantityProductiveArea
				Description: Codigo do Ano Agrícola
				Type: Char
				Length: 15
				Field: NN3_SAFRA
				Required: sim */
				If ( XmlChildEx( oXMLContent, '_QUANTITYPRODUCTIVEAREA' ) != Nil )
					cQtdArea := AllTrim(oXMLContent:_QuantityProductiveArea:Text)
				EndIf				

				/* 	Elemento: ListOfVarieties
				Description: Lista das Variedades
				Type: Lista de objetos de VarietyItemInformation
				Length: Ilimitado

				Elemento: VarietyItemInformation
				Description: Amarração Talhão X Variedade
				Type: VarietyCode
				Length: 1

				Elemento: VarietyCode
				Description: Codigo da Variedade
				Type: Char
				Length: 6
				Field: NN4_CODVAR

				Elemento: Quantity
				Description: Quantidade
				Type: Decimal
				Length: 14.2
				Field: NN4_HECTAR

				Required: sim */
				If ValType(oXMLContent:_ListOfVarieties:_VarietyItemInformation) == "A" //Quando eh mais de um elemento, vem array

					For nCount := 1 To Len(oXMLContent:_ListOfVarieties:_VarietyItemInformation)
						aAdd(aCodVar,PADR(oXMLContent:_ListOfVarieties:_VarietyItemInformation[nCount]:_VarietyCode:Text,TamSx3("NN4_CODVAR")[1] ," "))
						aAdd(aQtdVar,oXMLContent:_ListOfVarieties:_VarietyItemInformation[nCount]:_Quantity:Text)
					Next nCount

				ElseIf ValType(oXMLContent:_ListOfVarieties:_VarietyItemInformation) == "O" //Quando eh um elemento, vem objeto

					aAdd(aCodVar,PADR(oXMLContent:_ListOfVarieties:_VarietyItemInformation:_VarietyCode:Text,TamSx3("NN4_CODVAR")[1] ," "))
					aAdd(aQtdVar,oXMLContent:_ListOfVarieties:_VarietyItemInformation:_Quantity:Text)

				EndIf

				//Fim entrada de dados

				//Carrega model com estrutura da Tabela de Talhoes
				_oModel    := FwLoadModel( 'AGRA010' )	
				_oModelNN3 :=_oModel:GetModel('AGRA010_NN3')	//Cab Talhoes
				_oModelNN4 :=_oModel:GetModel('AGRA010_NN4')	//Grid Talhoes

				dbSelectArea('NN3')
				NN3->( dbSetOrder(4) )	//NN3_FILIAL+NN3_ID
				lRet := NN3->( DbSeek( fwxFilial('NN3') + cID ) )

				cTalXml := PADR(AllTrim(cCodSet) + "-" + AllTrim(cCodTal) + "-" + AllTrim(cCodPer),TamSx3("NN3_TALHAO")[1] ," ")
				If lRet
					If cTalXml != NN3->NN3_TALHAO //Alterou o codigo do talhao
						NN3->( dbSetOrder(1) ) //NN3_FILIAL+NN3_SAFRA+NN3_FAZ+NN3_TALHAO
						If NN3->( DbSeek( fwxFilial('NN3') + cCodSaf + cCodFaz + cTalXml) )
							lContinua := .F.
							cXMLRet := EncodeUTF8(STR0010) //"Já existe um registro integrado com este código."
						EndIf
					EndIf
				EndIf

				If lContinua					

					//Verifica a operação realizada
					If ( Upper( oXMLEvent:_Event:Text ) == 'UPSERT' )
						If lRet
							lRet := .T.
							//Alteração
							_oModel:SetOperation( MODEL_OPERATION_UPDATE )
						Else
							lRet := .T.
							//Inclusão
							_oModel:SetOperation( MODEL_OPERATION_INSERT )
						EndIf
					Else
						lRet := .T.
						//Exclusão do registro quando operação for Delete.
						//Para registro com movimentações o retorno será mensagem do model para o adapter.
						_oModel:SetOperation( MODEL_OPERATION_DELETE )
					EndIf

					If (_oModel:nOperation = MODEL_OPERATION_UPDATE )
						
						//Reposiciona
						NN3->( dbSetOrder(4) )	//NN3_FILIAL+NN3_ID
						NN3->( DbSeek( fwxFilial('NN3') + cID ) )
						
						aVldRel := NN3VldRel(NN3->NN3_TALHAO)
						lRet := aVldRel[1]
						cXMLRet := aVldRel[2]
						
						If lRet
							_oModel:Activate()			
									
							If lRet
								If lRet
									lRet := _oModelNN3:SetValue('NN3_DESCRI',cDesTal )
								EndIf
								If lRet
									lRet := _oModelNN3:LoadValue('NN3_TALHAO', cTalXml)
								EndIf
								If lRet
									lRet := _oModelNN3:SetValue('NN3_FECHAD','N' )
								EndIf
								If lRet
									lRet := _oModelNN3:LoadValue('NN3_HECTAR', AgrStrToNm(cQtdArea))
								EndIf
								If lRet
									If ExistCpo("NJU", cCodSaf, 1)
										lRet := _oModelNN3:LoadValue('NN3_SAFRA', cCodSaf )
									Else
										lRet := .F.
										//"Safra inválida.", "Safra não cadastrada no Protheus: "
										 _oModel:SetErrorMessage( , , _oModel:GetId() , "", "", STR0016, STR0017 + cCodFaz, "", "")								
									EndIf
								EndIf
								If lRet
									If ExistCpo("NN2", cCodFaz,2)
										lRet := _oModelNN3:LoadValue('NN3_FAZ',   cCodFaz )
									Else
										lRet := .F.
										//"Fazenda inválida.", "Fazenda não cadastrada no Protheus: "
										 _oModel:SetErrorMessage( , , _oModel:GetId() , "", "", STR0014, STR0015 + cCodFaz, "", "")
									EndIf
								EndIf
								
								If lRet
									If ValType(oXMLContent:_ListOfVarieties:_VarietyItemInformation) == "A"
	
										//Primeiro deletar as variedades que nao vieram ou atualizar as que vieram
										For nVar := 1 to _oModelNN4:Length()
											_oModelNN4:GoLine(nVar)
											lEncVar := .F.
											For nCount:= 1 To Len(oXMLContent:_ListOfVarieties:_VarietyItemInformation)
												If _oModelNN4:GetValue('NN4_CODVAR') == aCodVar[nCount]
													lEncVar := .T.
													If lRet //Atualiza hectar
														lRet := _oModelNN4:LoadValue('NN4_HECTAR',AgrStrToNm(aQtdVar[nCount]))
													EndIf							
													exit
												EndIf
											Next nCount
											If !lEncVar //Deleta a linha que nao veio na integracao
												_oModelNN4:GoLine(nVar)
												_oModelNN4:DeleteLine()
											EndIf
										Next nVar
	
										//Adicionar as novas variedades
										For nCount:= 1 To Len(oXMLContent:_ListOfVarieties:_VarietyItemInformation)
											lEncVar := .F.
											For nVar := 1 to _oModelNN4:Length()
												_oModelNN4:GoLine(nVar)
												If _oModelNN4:GetValue('NN4_CODVAR') == aCodVar[nCount]
													lEncVar := .T. //Se encontrou, nao adicionar
													exit
												EndIf
											Next nVar
											If !lEncVar
												_oModelNN4:AddLine()
												_oModelNN4:GoLine(_oModelNN4:Length())
												If lRet .And. _oModelNN4:IsInserted() //Somente se for uma linha nova
													lRet := ExistCpo('NNV',_oModelNN3:GetValue('NN3_CODPRO')+aCodVar[nCount],1)
													If lRet
														lRet := _oModelNN4:LoadValue('NN4_CODVAR',aCodVar[nCount]) //Para nao disparar valid de tela 'M->'
													Else
														_oModel:GetModel():SetErrorMessage(_oModel:GetId(), , _oModel:GetId(), "", "", STR0003, aCodVar[nCount], "", "") //"Variedade não encontrada com o produto informado."
													EndIf
												EndIf
												If lRet .And. _oModelNN4:IsInserted() //Somente se for uma linha nova
													lRet := _oModelNN4:SetValue('NN4_DESVAR',Posicione("NNV",2,xFilial("NNV")+aCodVar[nCount],"NNV_DESCRI")) //A definir
												EndIf
												If lRet //Insere hectar
													lRet := _oModelNN4:LoadValue('NN4_HECTAR',AgrStrToNm(aQtdVar[nCount]))
												EndIf
												If lRet
													lRet := _oModelNN4:LoadValue('NN4_ITEM', StrZero( nCount , TamSX3('NN4_ITEM')[1]))
												EndIf
												If lRet
													lRet := _oModelNN4:LoadValue('NN4_TALHAO', cTalXml)
												EndIf
											EndIf
										Next nCount
	
									ElseIf ValType(oXMLContent:_ListOfVarieties:_VarietyItemInformation) == "O"
	
										For nVar := 1 to _oModelNN4:Length()
											_oModelNN4:GoLine(nVar)
											_oModelNN4:DeleteLine()
										Next nVar								
	
										_oModelNN4:AddLine()
										_oModelNN4:GoLine(_oModelNN4:Length())
										lRet := _oModelNN4:LoadValue('NN4_ITEM',StrZero( _oModelNN4:Length() , TamSX3('NN4_ITEM')[1]))
										If lRet //.And. _oModelNN4:IsInserted()
											lRet := ExistCpo('NNV',_oModelNN3:GetValue('NN3_CODPRO')+aCodVar[1],1)
											If lRet
												lRet := _oModelNN4:LoadValue('NN4_CODVAR',aCodVar[1]) //Para nao disparar valid de tela 'M->'
											Else
												_oModel:GetModel():SetErrorMessage(_oModel:GetId(), , _oModel:GetId(), "", "", STR0003, aCodVar[1], "", "") //"Variedade não encontrada com o produto informado."
											EndIf
										EndIf							
										If lRet //.And.  _oModelNN4:IsInserted()
											lRet := _oModelNN4:SetValue('NN4_DESVAR',Posicione("NNV",2,xFilial("NNV")+aCodVar[1],"NNV_DESCRI"))
										EndIf
										If lRet
											lRet := _oModelNN4:LoadValue('NN4_HECTAR',AgrStrToNm(aQtdVar[1]))
										EndIf	
										If lRet
											lRet := _oModelNN4:LoadValue('NN4_ITEM', StrZero( _oModelNN4:Length() , TamSX3('NN4_ITEM')[1]))
										EndIf
										If lRet
											lRet := _oModelNN4:LoadValue('NN4_TALHAO', cTalXml)
										EndIf							
									EndIf
								EndIf
							EndIf
						EndIf
					ElseIf (_oModel:nOperation = MODEL_OPERATION_INSERT )
						
						NN3->( dbSetOrder(1) ) //NN3_FILIAL+NN3_SAFRA+NN3_FAZ+NN3_TALHAO
						lAtivar := NN3->( DbSeek( fwxFilial('NN3') + cCodSaf + cCodFaz + cTalXml) )
						
						If lAtivar
							//Alteração
							_oModel:SetOperation( MODEL_OPERATION_UPDATE )
						EndIf

						_oModel:Activate()	

						If lAtivar
							If lRet
								lRet := _oModelNN3:SetValue('NN3_FILIAL',fwxFilial('NN3'))
							EndIf
	
							If lRet
								lRet := _oModelNN3:LoadValue("NN3_TALHAO", cTalXml)
							EndIf
	
							If lRet
								If ExistCpo("NJU", cCodSaf, 1)
									lRet := _oModelNN3:LoadValue('NN3_SAFRA', cCodSaf )
								Else
									lRet := .F.
									//"Safra inválida.""Safra não cadastrada no Protheus: "
									 _oModel:SetErrorMessage( , , _oModel:GetId() , "", "", STR0016, STR0017 + cCodFaz, "", "")								
								EndIf
							EndIf
							If lRet
								If ExistCpo("NN2", cCodFaz,2)
									lRet := _oModelNN3:LoadValue('NN3_FAZ',   cCodFaz )
								Else
									lRet := .F.
									//"Fazenda inválida.""Fazenda não cadastrada no Protheus: "
									 _oModel:SetErrorMessage( , , _oModel:GetId() , "", "", STR0014, STR0015 + cCodFaz, "", "")
								EndIf
							EndIf
	
							If lRet
								lRet := _oModelNN3:SetValue('NN3_DESCRI',cDesTal )
							EndIf
	
							If lRet //Deve ter variedade relacionada ao produto para permitir o preenchimento
								lRet := _oModelNN3:LoadValue('NN3_CODPRO', PADR(AllTrim(Posicione("NNV",2,xFilial("NNV")+ aCodVar[1],"NNV_CODPRO")),TamSX3('NN3_CODPRO')[1],' '))
							EndIf
	
							If lRet
								lRet := _oModelNN3:LoadValue('NN3_HECTAR', AgrStrToNm(cQtdArea))
							EndIf
							If lRet
								lRet := _oModelNN3:LoadValue('NN3_FECHAD','N' )
							EndIf
							If lRet
								lRet := _oModelNN3:LoadValue('NN3_ID', cID )
							EndIf					
						Else
							If lRet
								lRet := _oModelNN3:SetValue('NN3_FILIAL',fwxFilial('NN3'))
							EndIf
	
							If lRet
								lRet := _oModelNN3:SetValue("NN3_TALHAO", cTalXml)
							EndIf
	
							If lRet
								lRet := _oModelNN3:SetValue('NN3_DESCRI',cDesTal )
							EndIf
	
							If lRet
								lRet := _oModelNN3:SetValue('NN3_FAZ',   cCodFaz )
							EndIf
	
							If lRet
								lRet := _oModelNN3:SetValue('NN3_SAFRA', cCodSaf )
							EndIf
	
							If lRet //Deve ter variedade relacionada ao produto para permitir o preenchimento
								lRet := _oModelNN3:SetValue('NN3_CODPRO', PADR(AllTrim(Posicione("NNV",2,xFilial("NNV")+ aCodVar[1],"NNV_CODPRO")),TamSX3('NN3_CODPRO')[1],' '))
							EndIf
	
							If lRet
								lRet := _oModelNN3:LoadValue('NN3_HECTAR', AgrStrToNm(cQtdArea))
							EndIf
							If lRet
								lRet := _oModelNN3:SetValue('NN3_FECHAD','N' )
							EndIf
							If lRet
								lRet := _oModelNN3:SetValue('NN3_ID', cID )
							EndIf
						EndIf
						
						If lRet .And. ValType(oXMLContent:_ListOfVarieties:_VarietyItemInformation) == "A"

							For nCount := 1 To Len(oXMLContent:_ListOfVarieties:_VarietyItemInformation)
								If nCount > 1
									_oModelNN4:AddLine()
								EndIf
								_oModelNN4:GoLine(nCount)
								If lRet
									If ExistCpo('NNV',_oModelNN3:GetValue('NN3_CODPRO')+aCodVar[nCount],1)
										lRet := _oModelNN4:LoadValue('NN4_CODVAR',aCodVar[nCount]) //Para nao disparar valid de tela 'M->'
									Else
										lRet := _oModelNN4:SetValue('NN4_CODVAR',aCodVar[nCount])
									EndIf
								EndIf
								If lRet
									lRet := _oModelNN4:LoadValue('NN4_HECTAR',AgrStrToNm(aQtdVar[nCount]))
								EndIf
								If lRet
									lRet := _oModelNN4:SetValue('NN4_DESVAR',Posicione("NNV",2,xFilial("NNV")+aCodVar[nCount],"NNV_DESCRI"))
								EndIf
								If lRet
									lRet := _oModelNN4:LoadValue('NN4_ITEM', StrZero( nCount , TamSX3('NN4_ITEM')[1]))
								EndIf

							Next nCount

						ElseIf lRet .And. ValType(oXMLContent:_ListOfVarieties:_VarietyItemInformation) == "O"

							_oModelNN4:GoLine(1)
							lRet := _oModelNN4:LoadValue('NN4_ITEM',StrZero( _oModelNN4:Length() , TamSX3('NN4_ITEM')[1]))
							If lRet
								If ExistCpo('NNV',_oModelNN3:GetValue('NN3_CODPRO')+aCodVar[1],1)
									lRet := _oModelNN4:LoadValue('NN4_CODVAR',aCodVar[1]) //Para nao disparar valid de tela 'M->'
								Else
									lRet := _oModelNN4:SetValue('NN4_CODVAR',aCodVar[1])
								EndIf
							EndIf
							If lRet
								lRet := _oModelNN4:LoadValue('NN4_HECTAR',AgrStrToNm(aQtdVar[1]))
							EndIf
							If lRet
								lRet := _oModelNN4:SetValue('NN4_DESVAR',Posicione("NNV",2,xFilial("NNV")+aCodVar[1],"NNV_DESCRI"))
							EndIf
							
						EndIf
					ElseIf (_oModel:nOperation = MODEL_OPERATION_DELETE )
						_oModel:SetOperation( MODEL_OPERATION_UPDATE)
						//Reposiciona
						NN3->( dbSetOrder(4) )	//NN3_FILIAL+NN3_ID
						If NN3->( DbSeek( fwxFilial('NN3') + cID ) )	
							_oModel:Activate()	
							If lRet
								lRet := _oModelNN3:SetValue('NN3_FECHAD','S' )
							EndIf
						Else
							lRet := .F.
							//"Talhão não encontrado.""Talhão não cadastrado no Protheus."
							_oModel:SetErrorMessage( , , _oModel:GetId() , "", "", STR0012, STR0013, "", "")
						EndIF
						
					EndIf


					If lRet
						If lRet :=_oModel:VldData()
							//Grava o model
							lRet :=_oModel:CommitData()
						Endif
					EndIf
					If !lRet
						If Empty(cXMLRet)
							//Trata erro de gravação do model
							aMsgErro :=_oModel:GetErrorMessage()
	
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
						If _oModel:nOperation != MODEL_OPERATION_DELETE
							//--EMPRESA - FILIAL - CODIGO 
							cValInt := FWCodEmp() + "|" + FWCodFil() + "|" + _oModelNN3:GetValue('NN3_TALHAO')
							cValIntOld := FWCodEmp() + "|" + FWCodFil() + "|" + cTalhaoOld 

							If lUpdate
								CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValIntOld , .T.,,, cEntity)
							EndIf
							CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt , .F.,,, cEntity)
						Else
							//--EMPRESA - FILIAL - CODIGO 
							cValInt := FWCodEmp() + "|" + FWCodFil() + "|" + _oModelNN3:GetValue('NN3_TALHAO') 
							// Exclui o registro na tabela XXF (de/para)
							CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt , .T.,,, cEntity)
						EndIf

						//-- Monta o XML de Retorno
						cXmlRet := "<ListOfInternalId>"
						cXmlRet +=    "<InternalId>"
						cXmlRet +=       "<Name>" + cEntity + "</Name>"
						cXmlRet +=       "<Origin>" + cValExt + "</Origin>"
						cXmlRet += 		 "<Destination>" + FWCodEmp() + "|" + FWCodFil() + "|" + _oModelNN3:GetValue('NN3_TALHAO') + "</Destination>"
						cXmlRet +=    "</InternalId>"
						cXmlRet += "</ListOfInternalId>"					
					EndIf
					_oModel:Deactivate()
					_oModel:Destroy()
				EndIf

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

			//--------------------------------------------
			//--- RECEBIMENTO DA WHOIS   
			//--------------------------------------------			
		ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )
			cXMLRet := "1.000|1.001|1.002"
		EndIf

	ElseIf ( nTypeTrans == TRANS_SEND )
		_oModel    := FWModelActive()
		_oModelNN3 := _oModel:GetModel('AGRA010_NN3')
		_oModelNN4 := _oModel:GetModel('AGRA010_NN4')

		//Verifica se a tabela está sendo excluída
		If ( _oModel:nOperation == 5 )
			cEvent := 'delete'
		EndIf

		//Monta Business Event
		cXMLRet := '<BusinessEvent>'
		cXMLRet +=     '<Entity>'+ cEntity +'</Entity>'
		cXMLRet +=     '<Event>' + cEvent + '</Event>'
		cXMLRet += '</BusinessEvent>'

		cXMLRet += '<BusinessContent>'
		cXMLRet +=    '<Code>'                  + _oModelNN3:GetValue('NN3_DESCRI') + '</Code>'
		cXMLRet +=    '<InternalID>'            + fwxFilial("NN3") + "|" + _oModelNN3:GetValue('NN3_SAFRA') + "|"  + _oModelNN3:GetValue('NN3_FAZ')+ "|"  + _oModelNN3:GetValue('NN3_TALHAO') + '</InternalID>' 
		cXMLRet +=    '<Description>'           + _oModelNN3:GetValue('NN3_DESCRI') + '</Description>'
		cXMLRet +=    '<FarmCode>'              + "20"    + '</FarmCode>'
		cXMLRet +=    '<AgriculturalSectorCode>'+ "2019"                              + '</AgriculturalSectorCode>'
		cXMLRet +=    '<AgriculturalYearCode>'  + "1819"  + '</AgriculturalYearCode>'
		cXMLRet +=    '<ProductionPeriodCode>'  + "02"                              + '</ProductionPeriodCode>'
		cXMLRet +=    '<QuantityProductiveArea>100</QuantityProductiveArea>'
		cXMLRet +=    '<ListOfVarieties>'

		//Variedades da integracao
		For nCount := 1 to _oModelNN4:Length()
			_oModelNN4:GoLine(nCount)
			If !_oModelNN4:IsDeleted() 

				cXMLRet +=        '<VarietyItemInformation>'
				cXMLRet +=            '<VarietyCode>'+ "2018"+ '</VarietyCode>'
				cXMLRet +=            '<Quantity>100</Quantity>'
				cXMLRet +=         '</VarietyItemInformation>'

			EndIf
		Next nCount

		cXMLRet += 	'			</ListOfVarieties>'
		cXMLRet += '</BusinessContent>'	
	EndIf

	//Carrega array de retorno
	aRet := {lRet, cXmlRet, "PartOfLand"}

	//Restaura ambiente
	FWRestRows( aSaveLine )     
	RestArea(aAreaNN3)
	RestArea(aAreaNN4)
	RestArea(aArea)

Return aRet


/*/{Protheus.doc} NN3VldRel
//Verifica Integridade 
@author carlos.augusto
@since 03/07/2018
@version undefined
@param cNN2Codigo, characters, descricao
@type function
/*/
Static Function NN3VldRel(cNN3Codigo)
	Local aArea	    := GetArea()
	Local cMensagem	:= ""
	Local lRetorno	:= .T.
	Local cDXL_CODIGO
	
	cDXL_CODIGO := GetDataSql("SELECT DXL_CODIGO res FROM " + RetSqlName("DXL") + " DXL " + ;
							" WHERE DXL.D_E_L_E_T_ = ' ' " +;
							" AND DXL.DXL_FILIAL = '" + FWXFILIAL("DXL") + "' " + ;
							" AND DXL.DXL_TALHAO = '" + cNN3Codigo + "'")
							
	If .Not. Empty(cDXL_CODIGO)
		lRetorno := .F.
		cMensagem += STR0011 + cDXL_CODIGO + "." //"Encontrado relacionamento do talhão com o fardão: "
	EndIf
	RestArea(aArea)
	
Return {lRetorno,cMensagem}