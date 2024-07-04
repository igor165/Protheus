#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "PCOI008.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

Static cMessage   := "BudgetUnity"

/*/{Protheus.doc} PCOI008
Fun��o de integra��o com o adapter EAI para envio e recebimento do cadastro de
unidades or�ament�ria (AMF) utilizando o conceito de mensagem �nica.

@param   cXml          Vari�vel com conte�do XML para envio/recebimento.
@param   cTypeTrans    Tipo de transa��o (Envio / Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Vers�o da mensagem.
@param   cTransac      Nome da transa��o.

@author  Felipe Raposo
@version P12
@since   09/04/2018
@return  aRet   - (array)   Cont�m o resultado da execu��o e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execu��o da fun��o
       aRet[2] - (caracter) Mensagem XML para envio
/*/
Function PCOI008(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

Local aRet := {.F., "", cMessage}
Local nX

If (cTypeTrans == TRANS_SEND .or. cTypeTrans == TRANS_RECEIVE)
	If cVersion = "1."
		aRet := v1000(cXml, cTypeTrans, cTypeMsg, cVersion)
	Else
		aRet[2] := STR0001 //"A vers�o da mensagem informada n�o foi implementada!"
	Endif
Endif

Return aRet


/*/{Protheus.doc} v1000
Implementa��o do adapter EAI, vers�o 1.x

@author  Felipe Raposo
@version P12
@since   03/04/2018
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
		cValInt := _NoTags(RTrim(oModel:GetValue('AMFMASTER', 'AMF_CODIGO')))

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
		cXMLRet += ' <InternalId>' + cEmpAnt + '|' + xFilial("AMF") + '|' + cValInt + '</InternalId>'
		cXMLRet += ' <Description>' + _NoTags(RTrim(oModel:GetValue('AMFMASTER', 'AMF_DESCRI'))) + '</Description>'
		cXMLRet += ' <BranchControl>' + _NoTags(oModel:GetValue('AMFMASTER', 'AMF_CONTFI')) + '</BranchControl>'
		If oModel:GetValue('AMFMASTER', 'AMF_MSBLQL') = '1'
			cXMLRet += ' <Enabled>2</Enabled>'
		Else
			cXMLRet += ' <Enabled>1</Enabled>'
		Endif
		cXMLRet += '</BusinessContent>'
		oModel := nil
	Endif

ElseIf (cTypeTrans == TRANS_RECEIVE)
	If (cTypeMsg == EAI_MESSAGE_RESPONSE)  // Resposta da mensagem �nica TOTVS.
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
						CFGA070Mnt(cRefer, "AMF", "AMF_CODIGO", nil, cValInt, .T.)
					ElseIf !empty(cValInt) .and. !empty(cValExt)
						CFGA070Mnt(cRefer, "AMF", "AMF_CODIGO", cValExt, cValInt)
					Else
						lRet  := .F.
						cErro := STR0002 + "|" //"Erro no processamento pela outra aplica��o"
						cErro += STR0003 //"Erro ao processar de/para de c�digos."
					Endif
				Next nX
			Else
				lRet  := .F.
				cErro :=  STR0002 + "|" //"Erro no processamento pela outra aplica��o"
				aErro := oXml:XPathGetChildArray('/TOTVSMessage/ResponseMessage/ProcessingInformation/ListOfMessages')
				For nX := 1 To len(aErro)
					cErro += oXml:xPathGetAtt(aErro[nX, 2], 'type') + ": " + Alltrim(oXml:xPathGetNodeValue(aErro[nX, 2])) + "|"
				Next nX
			Endif
		Endif
		oXml := nil

	ElseIf (cTypeMsg == EAI_MESSAGE_RECEIPT)  // Recibo.
		// N�o realiza nenhuma a��o.

	ElseIf (cTypeMsg == EAI_MESSAGE_BUSINESS)  // Chegada de mensagem de neg�cios.
		oXml := tXmlManager():New()
		oXml:Parse(cXml)
		If Empty(cErro := oXml:Error())
			lRet    := .T.
			cRefer  := oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
			cEvent  := AllTrim(Upper(oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event')))
			cValExt := oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/InternalId')
			cValInt := RTrim(CFGA070Int(cRefer, "AMF", "AMF_CODIGO", cValExt))
			aValInt := StrToKarr2(cValInt, "|", .T.)

			// Verifica se encontrou uma chave no de/para.
			If len(aValInt) > 2
				AMF->(dbSetOrder(1))  // AMF_FILIAL, AMF_CODIGO.
				lFound := AMF->(dbSeek(xFilial(nil, aValInt[2]) + aValInt[3], .F.))
			Endif

			If lFound
				If cEvent == 'UPSERT'
					nMVCOper := MODEL_OPERATION_UPDATE
				ElseIf cEvent == 'DELETE'
					nMVCOper := MODEL_OPERATION_DELETE
				Else
					lRet  := .F.
					cErro := STR0004 //"Opera��o inv�lida. Somente s�o permitidas as opera��es UPSERT e DELETE."
				Endif
			Else
				If cEvent == 'UPSERT'
					nMVCOper := MODEL_OPERATION_INSERT
				ElseIf cEvent == 'DELETE'
					lRet  := .F.
					cErro := STR0005 //"Registro n�o encontrado no Protheus."
				Else
					lRet  := .F.
					cErro := STR0004 //'Opera��o inv�lida. Somente s�o permitidas as opera��es UPSERT e DELETE.'
				Endif
			Endif

			If lRet
				oModel := FwLoadModel('PCOA008')
				oModel:SetOperation(nMVCOper)
				If oModel:Activate()
					If nMVCOper <> MODEL_OPERATION_DELETE
						If nMVCOper == MODEL_OPERATION_INSERT
							// Se o c�digo n�o tiver inicializador padr�o, usa GetSXENum().
							cValInt := oModel:GetValue('AMFMASTER', 'AMF_CODIGO')
							If empty(cValInt)
								cValInt := GetSXENum('AMF', 'AMF_CODIGO')
								oModel:SetValue('AMFMASTER', 'AMF_CODIGO', cValInt)
							Endif
							cValInt := cEmpAnt + '|' + xFilial("AMF") + '|' + cValInt
						Endif
						cNodePath := '/TOTVSMessage/BusinessMessage/BusinessContent/'
						oModel:SetValue('AMFMASTER', 'AMF_DESCRI', oXml:xPathGetNodeValue(cNodePath + 'Description'))

						xValue := oXml:xPathGetNodeValue(cNodePath + 'BranchControl')
						If xValue <> nil .and. oModel:GetValue('AMFMASTER', 'AMF_CONTFI') <> xValue
							oModel:SetValue('AMFMASTER', 'AMF_CONTFI', xValue)
						Endif

						xValue := oXml:xPathGetNodeValue(cNodePath + 'Enabled')
						If xValue <> nil
							oModel:SetValue('AMFMASTER', 'AMF_MSBLQL', If(xValue = "1", "2", "1"))
						Endif
					Endif
					lRet := oModel:VldData() .and. oModel:CommitData()

					// Se gravou certo, retorna o c�digo gravado.
					If lRet
						// Atualiza o de/para local.
						If nMVCOper = MODEL_OPERATION_DELETE
							CFGA070Mnt(cRefer, "AMF", "AMF_CODIGO", nil, cValInt, .T.)
						ElseIf nMVCOper = MODEL_OPERATION_INSERT
							CFGA070Mnt(cRefer, "AMF", "AMF_CODIGO", cValExt, cValInt)
						Endif

						cXmlRet := '<ListOfInternalId>'
						cXmlRet += ' <InternalId>'
						cXmlRet += '  <Name>ComplementaryValuesTypeInternalId</Name>'
						cXmlRet += '  <Origin>' + cValExt + '</Origin>'
						cXmlRet += '  <Destination>' + cValInt + '</Destination>'
						cXmlRet += ' </InternalId>'
						cXmlRet += '</ListOfInternalId>'
					Endif
				Else
					lRet  := .F.
					cErro := STR0006 //"Erro ao ativar modelo PCOA008."
				Endif

				If !lRet
					cErro := STR0007 //"A integra��o n�o foi bem sucedida."
					aErro := oModel:GetErrorMessage()
					If !Empty(aErro)
						cErro += STR0008 + Alltrim(aErro[5]) + '-' + AllTrim(aErro[6]) //"Foi retornado o seguinte erro: "
						If !Empty(Alltrim(aErro[7]))
							cErro += CRLF + STR0009 + AllTrim(aErro[7]) //"Solu��o - "
						Endif
					Else
						cErro += STR0010 //"Verifique os dados enviados"
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
EndIf

DelClassIntF()

// Se deu erro no processamento.
If !empty(cErro)
	lRet    := .F.
	cXmlRet := "<![CDATA[" + _NoTags(cErro) + "]]>"
Endif

Return {lRet, cXmlRet, cMessage}
