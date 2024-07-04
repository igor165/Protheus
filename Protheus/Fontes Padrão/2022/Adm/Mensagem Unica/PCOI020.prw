#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "PCOI020.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

Static cMessage   := "BudgetClass"

/*/{Protheus.doc} PCOI020
Função de integração com o adapter EAI para envio e recebimento do cadastro de
classes orçamentárias (AK6) utilizando o conceito de mensagem única.

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   cTypeTrans    Tipo de transação (Envio / Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Versão da mensagem.
@param   cTransac      Nome da transação.

@author  Felipe Raposo
@version P12
@since   10/04/2018
@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio
/*/
Function PCOI020(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

Local aRet := {.F., "", cMessage}
Local nX

If (cTypeTrans == TRANS_SEND .or. cTypeTrans == TRANS_RECEIVE)
	If cVersion = "1."
		aRet := v1000(cXml, cTypeTrans, cTypeMsg, cVersion)
	Else
		aRet[2] := STR0001 //"A versão da mensagem informada não foi implementada!"
	Endif
Endif

Return aRet


/*/{Protheus.doc} v1000
Implementação do adapter EAI, versão 1.x

@author  Felipe Raposo
@version P12
@since   10/04/2018
/*/
Static Function v1000(cXml, cTypeTrans, cTypeMsg, cVersion)

Local lRet       := .F.
Local cXmlRet    := ""
Local nX

Local oXml, oModel, cRefer, cEvent, nMVCOper
Local aErro, cErro

Local lFound     := .F.
Local xValue
Local cNodePath  := ""
Local aIntID     := {}
Local aValInt    := {}
Local cValInt    := ""
Local cValExt    := ""

If (cTypeMsg == EAI_MESSAGE_WHOIS)
	lRet    := .T.
	cXmlRet := '1.000'

ElseIf (cTypeTrans == TRANS_SEND)
	If (cTypeMsg == EAI_MESSAGE_BUSINESS)
		lRet   := .T.
		oModel := FwModelActive()
		cValInt := _NoTags(RTrim(oModel:GetValue('AK6MASTER', 'AK6_CODIGO')))

		cXMLRet := '<BusinessEvent>'
		cXMLRet += ' <Entity>' + cMessage + '</Entity>'
		cXMLRet += ' <Event>' + If(oModel:GetOperation() = MODEL_OPERATION_DELETE, 'delete', 'upsert') + '</Event>'
		cXMLRet += ' <Identification><key name="code">' + cValInt + '</key></Identification>'
		cXMLRet += '</BusinessEvent>'
		cXMLRet += '<BusinessContent>'
		cXMLRet += ' <CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet += ' <BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet += ' <CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		cXMLRet += ' <Code>' + cValInt + '</Code>'
		cXMLRet += ' <InternalId>' + cEmpAnt + '|' + xFilial("AK6") + '|' + cValInt + '</InternalId>'
		cXMLRet += ' <Description>' + _NoTags(RTrim(oModel:GetValue('AK6MASTER', 'AK6_DESCRI'))) + '</Description>'
		cXMLRet += ' <Entity>' + _NoTags(RTrim(oModel:GetValue('AK6MASTER', 'AK6_ENTIDA'))) + '</Entity>'
		cXMLRet += ' <Index>' + cValToChar(oModel:GetValue('AK6MASTER', 'AK6_INDICE')) + '</Index>'
		cXMLRet += ' <Identification>' + _NoTags(RTrim(oModel:GetValue('AK6MASTER', 'AK6_VISUAL'))) + '</Identification>'
		cXMLRet += ' <IdentificationRequired>' + _NoTags(RTrim(oModel:GetValue('AK6MASTER', 'AK6_OBRIGA'))) + '</IdentificationRequired>'
		cXMLRet += ' <StandardOperationInternalId>' + _NoTags(RTrim(cEmpAnt + '|' + xFilial("AKF") + '|' + oModel:GetValue('AK6MASTER', 'AK6_OPERPA'))) + '</StandardOperationInternalId>'
		cXMLRet += ' <UnitOfMeasureText>' + _NoTags(RTrim(oModel:GetValue('AK6MASTER', 'AK6_UM'))) + '</UnitOfMeasureText>'
		cXMLRet += ' <OperationRequired>' + _NoTags(RTrim(oModel:GetValue('AK6MASTER', 'AK6_OPER'))) + '</OperationRequired>'
		cXMLRet += ' <Observation>' + _NoTags(RTrim(StrTran(oModel:GetValue('AK6MASTER', 'AK6_MEMO'), CRLF, ' '))) + '</Observation>'
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
						CFGA070Mnt(cRefer, "AK6", "AK6_CODIGO", nil, cValInt, .T.)
					ElseIf !empty(cValInt) .and. !empty(cValExt)
						CFGA070Mnt(cRefer, "AK6", "AK6_CODIGO", cValExt, cValInt)
					Else
						lRet  := .F.
						cErro := STR0002 + "|" //"Erro no processamento pela outra aplicação"
						cErro += STR0003 //"Erro ao processar de/para de códigos."
					Endif
				Next nX
			Else
				lRet  := .F.
				cErro := STR0002 + "|" //"Erro no processamento pela outra aplicação"
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
			cValExt := oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/InternalId')
			cValInt := RTrim(CFGA070Int(cRefer, "AK6", "AK6_CODIGO", cValExt))
			aValInt := StrToKarr2(cValInt, "|", .T.)

			// Verifica se encontrou uma chave no de/para.
			If len(aValInt) > 2
				AK6->(dbSetOrder(1))  // AK6_FILIAL, AK6_CODIGO, AK6_DESCRI.
				lFound := AK6->(dbSeek(xFilial(nil, aValInt[2]) + aValInt[3], .F.))
			Endif

			If lFound
				If cEvent == 'UPSERT'
					nMVCOper := MODEL_OPERATION_UPDATE
				ElseIf cEvent == 'DELETE'
					nMVCOper := MODEL_OPERATION_DELETE
				Else
					lRet  := .F.
					cErro := STR0004 //'Operação inválida. Somente são permitidas as operações UPSERT e DELETE.'
				Endif
			Else
				If cEvent == 'UPSERT'
					nMVCOper := MODEL_OPERATION_INSERT
				ElseIf cEvent == 'DELETE'
					lRet  := .F.
					cErro := STR0005 //'Registro não encontrado no Protheus.'
				Else
					lRet  := .F.
					cErro := STR0004 //'Operação inválida. Somente são permitidas as operações UPSERT e DELETE.'
				Endif
			Endif

			If lRet
				oModel := FwLoadModel('PCOA020')
				oModel:SetOperation(nMVCOper)
				If oModel:Activate()
					If nMVCOper <> MODEL_OPERATION_DELETE
						If nMVCOper == MODEL_OPERATION_INSERT
							// Se o código não tiver inicializador padrão, usa GetSXENum().
							cValInt := oModel:GetValue('AK6MASTER', 'AK6_CODIGO')
							If empty(cValInt)
								cValInt := GetSXENum('AK6', 'AK6_CODIGO')
								oModel:SetValue('AK6MASTER', 'AK6_CODIGO', cValInt)
							Endif
							cValInt := cEmpAnt + '|' + xFilial("AK6") + '|' + cValInt
						Endif
						cNodePath := '/TOTVSMessage/BusinessMessage/BusinessContent/'
						oModel:SetValue('AK6MASTER', 'AK6_DESCRI', oXml:xPathGetNodeValue(cNodePath + 'Description'))

						xValue := oXml:xPathGetNodeValue(cNodePath + 'Entity')
						If xValue <> nil .and. oModel:GetValue('AK6MASTER', 'AK6_ENTIDA') <> xValue
							oModel:SetValue('AK6MASTER', 'AK6_ENTIDA', xValue)
						Endif

						xValue := oXml:xPathGetNodeValue(cNodePath + 'Index')
						If xValue <> nil .and. oModel:GetValue('AK6MASTER', 'AK6_INDICE') <> val(xValue)
							oModel:SetValue('AK6MASTER', 'AK6_INDICE', val(xValue))
						Endif

						xValue := oXml:xPathGetNodeValue(cNodePath + 'Identification')
						If xValue <> nil .and. oModel:GetValue('AK6MASTER', 'AK6_VISUAL') <> xValue
							oModel:SetValue('AK6MASTER', 'AK6_VISUAL', xValue)
						Endif

						xValue := oXml:xPathGetNodeValue(cNodePath + 'IdentificationRequired')
						If xValue <> nil .and. oModel:GetValue('AK6MASTER', 'AK6_OBRIGA') <> xValue
							oModel:SetValue('AK6MASTER', 'AK6_OBRIGA', xValue)
						Endif

						xValue := oXml:xPathGetNodeValue(cNodePath + 'StandardOperationInternalId')
						If xValue <> nil
							xValue := RTrim(CFGA070INT(cRefer, "AKF", 'AKF_CODIGO', xValue))
							If !empty(xValue)
								xValue := StrTokArr(xValue, "|")[3]
							Endif
							If oModel:GetValue('AK6MASTER', 'AK6_OPERPA') <> xValue
								oModel:SetValue('AK6MASTER', 'AK6_OPERPA', xValue)
							Endif
						Endif

						xValue := oXml:xPathGetNodeValue(cNodePath + 'UnitOfMeasureText')
						If xValue <> nil .and. oModel:GetValue('AK6MASTER', 'AK6_UM') <> xValue
							oModel:SetValue('AK6MASTER', 'AK6_UM', xValue)
						Endif

						xValue := oXml:xPathGetNodeValue(cNodePath + 'OperationRequired')
						If xValue <> nil .and. oModel:GetValue('AK6MASTER', 'AK6_OPER') <> xValue
							oModel:SetValue('AK6MASTER', 'AK6_OPER', xValue)
						Endif

						xValue := oXml:xPathGetNodeValue(cNodePath + 'Observation')
						If xValue <> nil .and. oModel:GetValue('AK6MASTER', 'AK6_MEMO') <> xValue
							oModel:SetValue('AK6MASTER', 'AK6_MEMO', xValue)
						Endif
					Endif
					lRet := oModel:VldData() .and. oModel:CommitData()

					// Se gravou certo, retorna o código gravado.
					If lRet
						// Atualiza o de/para local.
						If nMVCOper = MODEL_OPERATION_DELETE
							CFGA070Mnt(cRefer, "AK6", "AK6_CODIGO", nil, cValInt, .T.)
						ElseIf nMVCOper = MODEL_OPERATION_INSERT
							CFGA070Mnt(cRefer, "AK6", "AK6_CODIGO", cValExt, cValInt)
						Endif

						cXmlRet := '<ListOfInternalId>'
						cXmlRet += ' <InternalId>'
						cXmlRet += '  <Origin>' + cValExt + '</Origin>'
						cXmlRet += '  <Destination>' + cValInt + '</Destination>'
						cXmlRet += ' </InternalId>'
						cXmlRet += '</ListOfInternalId>'
					Endif
				Else
					lRet  := .F.
					cErro := STR0006 //"Erro ao ativar modelo PCOA020."
				Endif

				If !lRet
					cErro := STR0007 //'A integração não foi bem sucedida. '
					aErro := oModel:GetErrorMessage()
					If !Empty(aErro)
						cErro += STR0008 + Alltrim(aErro[5]) + '-' + AllTrim(aErro[6]) //'Foi retornado o seguinte erro: '
						If !Empty(Alltrim(aErro[7]))
							cErro += CRLF + STR0009 + AllTrim(aErro[7]) //'Solução - '
						Endif
					Else
						cErro += STR0010 //'Verifique os dados enviados'
					Endif
				Endif
				oModel:Deactivate()
				oModel:Destroy()
				oModel := nil
			Endif
		Else
			lRet := .F.
		Endif
		oXml := nil
	Endif
Endif

DelClassIntF()

// Se deu erro no processamento.
If !empty(cErro)
	lRet    := .F.
	cXmlRet := "<![CDATA[" + _NoTags(cErro) + "]]>"
Endif

Return {lRet, cXmlRet, cMessage}
