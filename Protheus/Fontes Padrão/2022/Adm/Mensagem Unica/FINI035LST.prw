#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FINI035.CH"

Static cMessage   := "ListOfComplementaryValue"
Static cModelId   := "FINA035"


/*/{Protheus.doc} IntegDef
Função para chamada para processar a mensagem única

@param cXml, XML recebido pelo EAI Protheus
@param nType, Tipo de transação ("0" = TRANS_RECEIVE, "1" = TRANS_SEND)
@param cTypeMsg, Tipo da mensagem do EAI ("20" = EAI_MESSAGE_BUSINESS, "21" = EAI_MESSAGE_RESPONSE
                 "22" = EAI_MESSAGE_RECEIPT, "23" = EAI_MESSAGE_WHOIS)
@param cVersion, Versão da Mensagem Única TOTVS

@author Pedro Alencar
@since 21/09/2016
@version 12
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return FINI035LST(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)


/*/{Protheus.doc} FINI035LST
Função de integração com o adapter EAI para envio e recebimento do cadastro de
tipos de valores acessórios (FKC) utilizando o conceito de mensagem única.

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   cTypeTrans    Tipo de transação (Envio / Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Versão da mensagem.
@param   cTransac      Nome da transação.

@author  Felipe Raposo
@version P12
@since   23/04/2018
@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio
       aRet[3] - (caracter) Nome da mensagem
/*/
Function FINI035LST(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

Local aRet := {.F., "", cMessage}

If (cTypeMsg == EAI_MESSAGE_WHOIS)
	lRet    := .T.
	cXmlRet := '1.000|1.001'
	aRet := {lRet, cXmlRet, cMessage}

ElseIf (cTypeTrans == TRANS_SEND .or. cTypeTrans == TRANS_RECEIVE)
	If cVersion = "1."
		aRet := v1000(cXml, cTypeTrans, cTypeMsg, cVersion)
	Else
		aRet[2] := STR0001 // "A versão da mensagem informada não foi implementada!"
	Endif
Endif

Return aRet


/*/{Protheus.doc} v1000
Implementação do adapter EAI, versão 1.x

@author  Felipe Raposo
@version P12
@since   23/04/2018
/*/
Static Function v1000(cXml, cTypeTrans, cTypeMsg, cVersion)

Local lRet       := .F.
Local cXmlRet    := ""
Local nX, nItem

Local oXml, oModel, cRefer, cEvent, nMVCOper
Local aErro, cErro

Local lFound     := .F.
Local aValues    := {}
Local xAuxValue

Local cBMPath    := '/TOTVSMessage/BusinessMessage/BusinessContent/'
Local aIntID     := {}
Local aValInt    := {}
Local cValInt    := ""
Local cValExt    := ""
Local aListCV    := {}
Local a070Mnt    := {}

If (cTypeTrans == TRANS_SEND)
	If (cTypeMsg == EAI_MESSAGE_BUSINESS)
		lRet   := .T.
		oModel := FwModelActive()
		cValInt := oModel:GetValue('FKCMASTER', 'FKC_CODIGO')

		cXMLRet := '<BusinessEvent>'
		cXMLRet += ' <Entity>' + cMessage + '</Entity>'
		cXMLRet += ' <Event>' + If(oModel:GetOperation() = MODEL_OPERATION_DELETE, 'delete', 'upsert') + '</Event>'
		cXMLRet += ' <Identification><key name="code">' + cValInt + '</key></Identification>'
		cXMLRet += '</BusinessEvent>'
		cXMLRet += '<BusinessContent>'
		cXMLRet += ' <CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		cXMLRet += ' <CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet += ' <BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet += ' <ListOfComplementaryValues>'
		cXMLRet += '  <ComplementaryValue>'
		cXMLRet += '   <InternalId>' + F035MntInt(nil, cValInt) + '</InternalId>'
		cXMLRet += '   <Code>' + cValInt + '</Code>'
		cXMLRet += '   <Description>' + _NoTags(EncodeUTF8(RTrim(oModel:GetValue('FKCMASTER', 'FKC_DESC')))) + '</Description>'

		xAuxValue := oModel:GetValue('FKCMASTER', 'FKC_ACAO')
		If xAuxValue = "1"
			cXMLRet += '   <Action>add</Action>'
		ElseIf xAuxValue = "2"
			cXMLRet += '   <Action>subtract</Action>'
		Endif

		xAuxValue := oModel:GetValue('FKCMASTER', 'FKC_TPVAL')
		If xAuxValue = "1"
			cXMLRet += '   <ValueType>percentage</ValueType>'
		ElseIf xAuxValue = "2"
			cXMLRet += '   <ValueType>value</ValueType>'
		Endif

		xAuxValue := oModel:GetValue('FKCMASTER', 'FKC_APLIC')
		If xAuxValue = "1"
			cXMLRet += '   <Application>before</Application>'
		ElseIf xAuxValue = "2"
			cXMLRet += '   <Application>after</Application>'
		ElseIf xAuxValue = "3"
			cXMLRet += '   <Application>fixed</Application>'
		Endif

		xAuxValue := oModel:GetValue('FKCMASTER', 'FKC_PERIOD')
		If xAuxValue = "1"
			cXMLRet += '   <Periodicity>single</Periodicity>'
		ElseIf xAuxValue = "2"
			cXMLRet += '   <Periodicity>daily</Periodicity>'
		ElseIf xAuxValue = "3"
			cXMLRet += '   <Periodicity>monthly</Periodicity>'
		ElseIf xAuxValue = "4"
			cXMLRet += '   <Periodicity>yearly</Periodicity>'
		Endif

		xAuxValue := oModel:GetValue('FKCMASTER', 'FKC_ATIVO')
		cXMLRet += '   <Enabled>' + If(xAuxValue = "2", "false", "true") + '</Enabled>'
		cXMLRet += '   <Portfolio>' + oModel:GetValue('FKCMASTER', 'FKC_RECPAG') + '</Portfolio>'
		cXMLRet += '   <DayFactor>' + cValToChar(oModel:GetValue('FKCMASTER', 'FKC_NDIAS')) + '</DayFactor>'
		If cVersion >= "1.001"
			cXMLRet += '   <AccountingVariable>' + _NoTags(EncodeUTF8(RTrim(oModel:GetValue('FKCMASTER', 'FKC_VARCTB')))) + '</AccountingVariable>'
			cXMLRet += '   <Rule>' + _NoTags(EncodeUTF8(RTrim(oModel:GetValue('FKCMASTER', 'FKC_REGRA')))) + '</Rule>'
		Endif
		cXMLRet += '  </ComplementaryValue>'
		cXMLRet += ' </ListOfComplementaryValues>'
		cXMLRet += '</BusinessContent>'
		oModel := nil
	Endif

ElseIf (cTypeTrans == TRANS_RECEIVE)
	If (cTypeMsg == EAI_MESSAGE_RESPONSE)  // Resposta da mensagem única TOTVS.
		// Gravo o de/para local, caso tenha sido gravado o dado no sistema remoto.
		lRet := .T.
		oXml := tXmlManager():New()
		oXml:Parse(cXml)
		If Empty(cErro := oXml:Error())
			If upper(oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ProcessingInformation/Status')) = "OK"
				cRefer := oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
				cEvent := AllTrim(Upper(oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReceivedMessage/Event')))
				aIntID := oXml:XPathGetChildArray('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId')
				For nX := 1 to len(aIntID)
					cValExt := oXml:xPathGetNodeValue(aIntID[nX, 2] + '/Destination')
					cValInt := oXml:xPathGetNodeValue(aIntID[nX, 2] + '/Origin')
					If cEvent = 'DELETE' .and. !empty(cValInt)
						CFGA070Mnt(cRefer, "FKC", "FKC_CODIGO", nil, cValInt, .T.)
					ElseIf !empty(cValInt) .and. !empty(cValExt)
						CFGA070Mnt(cRefer, "FKC", "FKC_CODIGO", cValExt, cValInt)
					Else
						lRet  := .F.
						cErro := STR0002 + "|"  // "Erro no processamento pela outra aplicação"
						cErro += STR0003        // "Erro ao processar de/para de códigos."
					Endif
				Next nX
			Else
				lRet  := .F.
				cErro := STR0002 + "|"  // "Erro no processamento pela outra aplicação"
				aErro := oXml:XPathGetChildArray('/TOTVSMessage/ResponseMessage/ProcessingInformation/ListOfMessages')
				For nX := 1 To len(aErro)
					cErro += oXml:xPathGetAtt(aErro[nX, 2], 'type') + ": " + Alltrim(oXml:xPathGetNodeValue(aErro[nX, 2])) + "|"
				Next nX
			Endif
		Endif
		oXml := nil

	ElseIf (cTypeMsg == EAI_MESSAGE_RECEIPT)  // Recibo.
		// Não realiza nenhuma ação.

	ElseIf (cTypeMsg == EAI_MESSAGE_BUSINESS)  // Chegada de mensagem de negócios.
		oXml := tXmlManager():New()
		oXml:Parse(cXml)
		If Empty(cErro := oXml:Error())
			lRet    := .T.
			cRefer  := oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
			cEvent  := AllTrim(Upper(oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event')))
			aListCV := oXml:XPathGetChildArray(cBMPath + "ListOfComplementaryValues")
			oModel  := FwLoadModel(cModelId)  // Carrega o model.

			// Processa todos os itens do list.
			Begin Transaction
			For nItem := 1 to len(aListCV)
				// Busca a chave do registro a ser gravado.
				cValExt := oXml:xPathGetNodeValue(aListCV[nItem, 2] + "/InternalId")
				aValInt := F035GetInt(cValExt, cRefer)

				// Verifica se encontrou uma chave no de/para.
				If aValInt[1]
					cValInt := aValInt[3]
					FKC->(dbSetOrder(1))  // FKC_FILIAL, FKC_CODIGO.
					lFound := FKC->(dbSeek(xFilial(nil, aValInt[2, 2]) + aValInt[2, 3], .F.))
				Else
					lFound := .F.
				Endif

				If lFound
					If cEvent == 'UPSERT'
						nMVCOper := MODEL_OPERATION_UPDATE
					ElseIf cEvent == 'DELETE'
						nMVCOper := MODEL_OPERATION_DELETE
					Else
						lRet  := .F.
						cErro := STR0004  // "Operação inválida. Somente são permitidas as operações UPSERT e DELETE."
					Endif
				Else
					If cEvent == 'UPSERT'
						nMVCOper := MODEL_OPERATION_INSERT
					ElseIf cEvent == 'DELETE'
						lRet  := .F.
						cErro := STR0005  // "Registro não encontrado no Protheus."
					Else
						lRet  := .F.
						cErro := STR0004  // "Operação inválida. Somente são permitidas as operações UPSERT e DELETE."
					Endif
				Endif

				If lRet
					oModel:SetOperation(nMVCOper)
					If oModel:Activate()
						If nMVCOper <> MODEL_OPERATION_DELETE
							If nMVCOper == MODEL_OPERATION_INSERT
								// Se o código não tiver inicializador padrão, usa GetSXENum().
								cValInt := oModel:GetValue('FKCMASTER', 'FKC_CODIGO')
								If empty(cValInt)
									cValInt := ProxCodVA()
									oModel:SetValue('FKCMASTER', 'FKC_CODIGO', cValInt)
								Endif
								cValInt := cEmpAnt + '|' + xFilial("FKC") + '|' + cValInt
							Endif

							// Campos obrigatórios.
							aAdd(aValues, {'FKC_DESC',   oXml:xPathGetNodeValue(aListCV[nItem, 2] + '/Description')})

							xAuxValue := lower(oXml:xPathGetNodeValue(aListCV[nItem, 2] + '/Action'))
							If xAuxValue = "add"
								aAdd(aValues, {'FKC_ACAO',   '1'})
							ElseIf xAuxValue = "subtract"
								aAdd(aValues, {'FKC_ACAO',   '2'})
							Endif

							xAuxValue := lower(oXml:xPathGetNodeValue(aListCV[nItem, 2] + '/ValueType'))
							If xAuxValue = "percentage"
								aAdd(aValues, {'FKC_TPVAL',  '1'})
							ElseIf xAuxValue = "value"
								aAdd(aValues, {'FKC_TPVAL',  '2'})
							Endif

							xAuxValue := lower(oXml:xPathGetNodeValue(aListCV[nItem, 2] + '/Application'))
							If xAuxValue = "before"
								aAdd(aValues, {'FKC_APLIC',  '1'})
							ElseIf xAuxValue = "after"
								aAdd(aValues, {'FKC_APLIC',  '2'})
							ElseIf xAuxValue = "fixed"
								aAdd(aValues, {'FKC_APLIC',  '3'})
							Endif

							xAuxValue := lower(oXml:xPathGetNodeValue(aListCV[nItem, 2] + '/Periodicity'))
							If xAuxValue = "single"
								aAdd(aValues, {'FKC_PERIOD', '1'})
							ElseIf xAuxValue = "daily"
								aAdd(aValues, {'FKC_PERIOD', '2'})
							ElseIf xAuxValue = "monthly"
								aAdd(aValues, {'FKC_PERIOD', '3'})
							ElseIf xAuxValue = "yearly"
								aAdd(aValues, {'FKC_PERIOD', '4'})
							Endif

							xAuxValue := lower(oXml:xPathGetNodeValue(aListCV[nItem, 2] + '/Enabled'))
							If xAuxValue = "true"
								aAdd(aValues, {'FKC_ATIVO',  '1'})
							ElseIf xAuxValue = "false"
								aAdd(aValues, {'FKC_ATIVO',  '2'})
							Endif

							aAdd(aValues, {'FKC_RECPAG', oXml:xPathGetNodeValue(aListCV[nItem, 2] + '/Portfolio')})

							// Campos não obrigatórios.
							If oXml:xPathHasNode(aListCV[nItem, 2] + '/DayFactor')
								aAdd(aValues, {'FKC_NDIAS',  val(oXml:xPathGetNodeValue(aListCV[nItem, 2] + '/DayFactor'))})
							Endif

							// Campos adicionados na versão 1.001.
							If cVersion >= "1.001"
								If oXml:xPathHasNode(aListCV[nItem, 2] + '/AccountingVariable')
									aAdd(aValues, {'FKC_VARCTB', oXml:xPathGetNodeValue(aListCV[nItem, 2] + '/AccountingVariable')})
								ElseIf nMVCOper == MODEL_OPERATION_INSERT
									aAdd(aValues, {'FKC_VARCTB', ProxVarCTB() }) // MV_VARCVA
								Endif

								If oXml:xPathHasNode(aListCV[nItem, 2] + '/Rule')
									aAdd(aValues, {'FKC_REGRA',  oXml:xPathGetNodeValue(aListCV[nItem, 2] + '/Rule')})
								Endif
							ElseIf nMVCOper == MODEL_OPERATION_INSERT
								aAdd(aValues, {'FKC_VARCTB', ProxVarCTB() }) // MV_VARCVA
							Endif

							// Atualiza os campos.
							For nX := 1 to len(aValues)
								xAuxValue := oModel:GetValue('FKCMASTER', aValues[nX, 1])
								If nMVCOper == MODEL_OPERATION_INSERT .or. !(RTrim(cValToChar(xAuxValue)) == RTrim(cValToChar(aValues[nX, 2])))
									oModel:SetValue('FKCMASTER', aValues[nX, 1], aValues[nX, 2])
								Endif
							Next nX
						Endif
					
						If oModel:VldData()
						   oModel:CommitData()

							If nMVCOper == MODEL_OPERATION_INSERT
								ConfirmSX8()
							EndIf
							// Atualiza o de/para local.
							If nMVCOper = MODEL_OPERATION_DELETE
								CFGA070Mnt(cRefer, "FKC", "FKC_CODIGO", nil, cValInt, .T.)
							ElseIf nMVCOper = MODEL_OPERATION_INSERT
								CFGA070Mnt(cRefer, "FKC", "FKC_CODIGO", cValExt, cValInt)
							Endif
							aAdd(a070Mnt, {cValInt, cValExt})
						Else
						    lRet  := .F.		
						Endif				
					Else
						lRet  := .F.
						cErro := StrTran(STR0006, "%cModelId%", cModelId)  // "Erro ao ativar modelo %cModelId%."
					Endif

					If !lRet
						cErro := STR0007  // "A integração não foi bem sucedida. "
						aErro := oModel:GetErrorMessage()
						If !Empty(aErro)
							cErro += STR0008 + Alltrim(aErro[5]) + '-' + AllTrim(aErro[6])  // "Foi retornado o seguinte erro: "
							If !Empty(Alltrim(aErro[7]))
								cErro += CRLF + STR0009 + AllTrim(aErro[7])  // "Solução: "
							Endif
						Else
							cErro += STR0010  // "Verifique os dados enviados."
						Endif
					Endif

					oModel:Deactivate()
				Endif

				// Se houve erro no processamento, sai do looping.
				If !lRet
					Exit
				Endif
			Next nItem

			oModel:Destroy()
			oModel := nil
			End Transaction
		Else
			lRet := .F.
		Endif
		oXml := nil

		// Verifica se não deu erro no processamento.
		If lRet .and. empty(cErro)
			cXmlRet := '<ListOfInternalId>'
			For nX := 1 to len(a070Mnt)
				cValInt := a070Mnt[nX, 1]
				cValExt := a070Mnt[nX, 2]
				cXmlRet += ' <InternalId>'
				cXmlRet += '  <Name>LISTOFCOMPLEMENTARYVALUE</Name>'
				cXmlRet += '  <Origin>'+ cValExt +'</Origin>'
				cXmlRet += '  <Destination>'+ cValInt +'</Destination>'
				cXmlRet += ' </InternalId>'
			Next nX
			cXmlRet += '</ListOfInternalId>'
		Endif
	Endif
EndIf

DelClassIntF()

// Verifica se deu erro no processamento.
If !empty(cErro)
	lRet    := .F.
	cXmlRet := "<![CDATA[" + _NoTags(cErro) + "]]>"
Endif

Return {lRet, cXmlRet, cMessage}


/*/{Protheus.doc} F035GetInt
Função para pegar o código Protheus do valor acessório a partir do código externo

@param cCodigo, InternalID recebido na mensagem
@param cMarca, Produto que enviou a mensagem
@return aRet, Vetor contendo os campos da chave primária do valor acessório
@sample Exemplo de retorno: {.T., {"T1", "D MG 01", "000001"}, "T1|D MG 01|000001"}

@author Pedro Alencar
@since 21/09/2016
@version 12
/*/
Function F035GetInt(cCodigo, cMarca)

Local cValInt := ""
Local aRet    := {}
Local aAux    := {}
Local aCampos := {cEmpAnt, "FKC_FILIAL", "FKC_CODIGO"}
Local nX

cValInt := RTrim(CFGA070Int(cMarca, "FKC", "FKC_CODIGO", cCodigo))
If Empty(cValInt)
	aAdd(aRet, .F.)
Else
	aAux := StrToKarr2(cValInt, "|", .T.)
	aAdd(aRet, .T.)
	aAdd(aRet, aAux)
	aAdd(aRet, cValInt)

	aRet[2][1] := Padr(aRet[2][1], Len(cEmpAnt))

	// Garante que o tamanho dos campos esteja correto
	For nX := 2 To Len(aRet[2])
		aRet[2][nX] := Padr(aRet[2][nX], TamSX3(aCampos[nx])[1])
	Next nX
EndIf

Return aRet


/*/{Protheus.doc} F035MntInt
Função para montar a chave interna do valor acessório no Protheus

@param cFilVA, Filial da tabela de valores acessórios
@param cCodVA, Código do valor acessório

@author Pedro Alencar
@since 21/09/2016
@version 12
/*/
Function F035MntInt(cFilVA, cCodVA)
Local cRet := ""
Default cFilVA := FWxFilial("FKC")
cRet := RTrim(cEmpAnt + "|" + cFilVA + "|" + cCodVA)
Return cRet

/*/{Protheus.doc} ProxCodVA
Rotina para retornar o Proximo numero para gravação de código

@return cRet, Código sequêncial válido

@author Pedro Alencar
@since 21/09/2016
@version 12
/*/
Static Function ProxCodVA()
	Local aAreaFKC	:= {}
	Local aArea		:= GetArea()
	Local cRet := ""
	Local lLivre := .F.

	aAreaFKC := FKC->( GetArea() )
	cRet := GetSxeNum( "FKC", "FKC_CODIGO" )
	FKC->( dbSetOrder( 1 ) ) //FKC_FILIAL + FKC_CODIGO

	While !lLivre
		If FKC->( msSeek( FWxFilial("FKC") + cRet ) )
			ConfirmSX8()
			cRet := GetSxeNum( "FKC", "FKC_CODIGO" )
		Else
			lLivre := .T.
		Endif
	Enddo

	FKC->( RestArea( aAreaFKC ) )
	RestArea(aArea)
Return cRet

/*/{Protheus.doc} ProxVarCTB
Rotina para retornar o Proximo código válido para variável contábil
do cadastro de valores acessórios

@return cRet, Código sequêncial válido

@author Pedro Alencar
@since 21/09/2016
@version 12
/*/
Static Function ProxVarCTB()
	Local cRet := ""
	Local cVarCTB := GetMV( "MV_VARCVA", , "VACTB001" )
	Local lValido := .F.

	//Loop para encontrar o próximo codigo sequencial disponível
	While !lValido
		//Valida se o código já não está em uso
		lValido := F035VldVar( cVarCTB )

		//Se o código já estiver em uso, incrementa e tenta validar novamente
		If !lValido
			cVarCTB := Soma1( cVarCTB )
		Endif
	EndDo

	//Pega o código válido para retornar para a gravação dos campos
	cRet := cVarCTB

	//Atualiza o parâmetro com o próximo código a ser utilizado
	cVarCTB := Soma1( cVarCTB )
	PutMV( "MV_VARCVA", cVarCTB )
Return cRet
