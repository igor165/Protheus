#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "CTBI130A.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

Static cMessage   := STR0001 //"AccountantAccountMask"

/*/{Protheus.doc} CTBI130A
Função de integração com o adapter EAI para envio e recebimento do cadastro de
máscara de entidade contábil (CTM) utilizando o conceito de mensagem única.

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
Function CTBI130A(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

Local aRet := {.F., "", cMessage}
Local nX

If (cTypeTrans == TRANS_SEND .or. cTypeTrans == TRANS_RECEIVE)
	If cVersion = "1."
		aRet := v1000(cXml, cTypeTrans, cTypeMsg, cVersion)
	Else
		aRet[2] := STR0002 //"A versão da mensagem informada não foi implementada!"
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

Local oXml, cRefer, cEvent
Local aErro, cErro

Local lFound     := .F.
Local cNodePath  := ""
Local aIntID     := {}
Local aValInt    := {}
Local cValInt    := ""
Local cValExt    := ""

Local aSegment   := {}
Local nAutoOper  := 0
Local aCabAux    := {}
Local aDetAux    := {}
Local aErroAuto  := {}

Private lMsErroAuto := .F.

If (cTypeMsg == EAI_MESSAGE_WHOIS)
	lRet    := .T.
	cXmlRet := '1.000'

ElseIf (cTypeTrans == TRANS_SEND)
	If (cTypeMsg == EAI_MESSAGE_BUSINESS)
		lRet   := .T.
		cValInt := _NoTags(RTrim(M->CTM_CODIGO))

		cXMLRet := '<BusinessEvent>'
		cXMLRet += ' <Entity>' + cMessage + '</Entity>'
		cXMLRet += ' <Event>' + If(ALTERA .or. INCLUI, 'upsert', 'delete') + '</Event>'
		cXMLRet += ' <Identification><key name="code">' + cValInt + '</key></Identification>'
		cXMLRet += '</BusinessEvent>'
		cXMLRet += '<BusinessContent>'
		cXMLRet += ' <CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet += ' <BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet += ' <CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		cXMLRet += ' <Code>' + cValInt + '</Code>'
		cXMLRet += ' <InternalId>' + cEmpAnt + '|' + xFilial("CTM") + '|' + cValInt + '</InternalId>'
		cXMLRet += ' <Description>' + _NoTags(RTrim(M->CTM_DESCM)) + '</Description>'
		cXMLRet += ' <Identifier>' + AllTrim(Str(M->CTM_IDENT)) + '</Identifier>'
		cXMLRet += ' <ListOfSegment>'
		For nX := 1 to len(aCols)
			If !aTail(aCols[nX])
				cXMLRet += ' <Segment>'
				cXMLRet += '   <Length>' + _NoTags(RTrim(GdFieldGet("CTM_DIGITO", nX))) + '</Length>'
				cXMLRet += '   <Description>' + _NoTags(RTrim(GdFieldGet("CTM_DESC", nX))) + '</Description>'
				cXMLRet += '   <Separator>' + _NoTags(RTrim(GdFieldGet("CTM_SEPARA", nX))) + '</Separator>'
				cXMLRet += ' </Segment>'
			Endif
		Next nX
		cXMLRet += ' </ListOfSegment>'
		cXMLRet += '</BusinessContent>'
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
						CFGA070Mnt(cRefer, "CTM", "CTM_CODIGO", nil, cValInt, .T.)
					ElseIf !empty(cValInt) .and. !empty(cValExt)
						CFGA070Mnt(cRefer, "CTM", "CTM_CODIGO", cValExt, cValInt)
					Else
						lRet  := .F.
						cErro := STR0003 //"Erro no processamento pela outra aplicação|"
						cErro += STR0004 //"Erro ao processar de/para de códigos."
					Endif
				Next nX
			Else
				lRet  := .F.
				cErro := STR0003 //"Erro no processamento pela outra aplicação|"
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
			cValInt := RTrim(CFGA070Int(cRefer, "CTM", "CTM_CODIGO", cValExt))
			aValInt := StrToKarr2(cValInt, "|", .T.)

			// Verifica se encontrou uma chave no de/para.
			If len(aValInt) > 2
				CTM->(dbSetOrder(1))  // CTM_FILIAL, CTM_CODIGO.
				lFound := CTM->(dbSeek(xFilial(nil, aValInt[2]) + aValInt[3], .F.))
			Endif

			If lFound
				If cEvent == 'UPSERT'
					nAutoOper := 4
				ElseIf cEvent == 'DELETE'
					nAutoOper := 5
				Else
					lRet  := .F.
					cErro := STR0005 //"Operação inválida. Somente são permitidas as operações UPSERT e DELETE."
				Endif
			Else
				If cEvent == 'UPSERT'
					nAutoOper := 3
				ElseIf cEvent == 'DELETE'
					lRet  := .F.
					cErro := STR0006 //"Registro não encontrado no Protheus."
				Else
					lRet  := .F.
					cErro := STR0005 //'Operação inválida. Somente são permitidas as operações UPSERT e DELETE.'
				Endif
			Endif

			If lRet
				// Caminho do Business Content.
				cNodePath := '/TOTVSMessage/BusinessMessage/BusinessContent/'

				// Monta o cabeçalho da msExecAuto.
				If nAutoOper == 3
					cValInt := CriaVar('CTM_CODIGO', .T.)  // Pega inicializador padrão do campo.
					If empty(cValInt)  // Se não houver, usa sequência do sistema.
						cValInt := GetSXENum('CTM', 'CTM_CODIGO')
					Endif
				Else
					cValInt := CTM->CTM_CODIGO
				Endif
				aAdd(aCabAux, cValInt)
				aAdd(aCabAux, oXml:xPathGetNodeValue(cNodePath + 'Description'))
				aAdd(aCabAux, val(oXml:xPathGetNodeValue(cNodePath + 'Identifier')))

				// Monta itens.
				If nAutoOper <> 5
					aSegment := oXml:XPathGetChildArray(cNodePath + "/ListOfSegment")
					For nX := 1 to len(aSegment)
						aAdd(aDetAux, array(3))
						aDetAux[nX, 1] := StrZero(val(oXml:xPathGetNodeValue(aSegment[nX, 2] + "/Length")), 2)
						aDetAux[nX, 2] := oXml:xPathGetNodeValue(aSegment[nX, 2] + "/Description")
						aDetAux[nX, 3] := oXml:xPathGetNodeValue(aSegment[nX, 2] + "/Separator")
					Next nX
				Endif

				// Executa rotina.
				msExecAuto({|x, y, z| CTB130Est(x, y, z)}, nAutoOper, aCabAux, aDetAux)

				If lMsErroAuto
					If __lSX8
						RollBackSX8()
					Endif
					aErroAuto := GetAutoGRLog()

					cErro := STR0007 //"A integração não foi bem sucedida. "
					If !Empty(aErroAuto)
						cErro += STR0008 + CRLF //"Foi retornado o seguinte erro: "
						For nX := 1 To Len(aErroAuto)
							cErro += aErroAuto[nX] + CRLF
						Next nX
					Else
						cErro += STR0009 //"Verifique os dados enviados"
					Endif

					lRet := .F.
				Else
					If __lSX8
						ConfirmSX8()
					Endif

					// Atualiza o de/para local.
					If nAutoOper = 3 .or. nAutoOper = 5
						cValInt := cEmpAnt + "|" + xFilial("CTM") + "|" + cValInt
						If nAutoOper = 5
							CFGA070Mnt(cRefer, "CTM", "CTM_CODIGO", nil, cValInt, .T.)
						ElseIf nAutoOper = 3
							CFGA070Mnt(cRefer, "CTM", "CTM_CODIGO", cValExt, cValInt)
						Endif
					Endif

					// Se gravou certo, retorna o código gravado.
					cXmlRet := '<ListOfInternalId>'
					cXmlRet += ' <InternalId>'
					cXmlRet += '  <Name>ComplementaryValuesTypeInternalId</Name>'
					cXmlRet += '  <Origin>' + cValExt + '</Origin>'
					cXmlRet += '  <Destination>' + cValInt + '</Destination>'
					cXmlRet += ' </InternalId>'
					cXmlRet += '</ListOfInternalId>'
				Endif
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
