#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "CTBI010.CH"

Static cMessage   := "AccountingCalendar"
Static cModelId   := "CTBA012"
Static cIniPer    := ""
Static cFimPer    := ""

/*/{Protheus.doc} CTBI010
Função de integração com o adapter EAI para envio e recebimento do cadastro de
calendário contábil (CTG/CQD) utilizando o conceito de mensagem única.

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   cTypeTrans    Tipo de transação (Envio / Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Versão da mensagem.
@param   cTransac      Nome da transação.

@author  Felipe Raposo
@version P12
@since   10/05/2018
@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio
       aRet[3] - (caracter) Nome da mensagem
/*/
Function CTBI010(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

Local aRet := {.F., "", cMessage}

If (cTypeMsg == EAI_MESSAGE_WHOIS)
	aRet[1] := .T.
	aRet[2] := '1.000'

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
@since   10/05/2018
/*/
Static Function v1000(cXml, cTypeTrans, cTypeMsg, cVersion)

Local lRet       := .F.
Local cXmlRet    := ""
Local nX, nY

Local oXml, cRefer, cEvent
Local aErro, cErro

Local aArea      := {}
Local aCTGArea   := {}
Local aCQDArea   := {}
Local lFound     := .F.
Local cNodePath  := ""
Local aIntID     := {}
Local aValInt    := {}
Local cValInt    := ""
Local cValExt    := ""
Local cRecKey    := ""

Local cFinYear   := ""
Local cPeriod    := ""
Local aPeriods   := {}
Local aProcess   := {}

Local nAutoOper  := 0
Local aCabAuto   := {}
Local aDetAuto   := {}
Local aLineAux   := {}
Local aSubLAux   := {}
Local lListProc  := .F.
Local aDetPrc    := {}

Local oModel, oMdlCTG, oMdlCQD

Private lMsErroAuto := .F.

aArea    := GetArea()
aCTGArea := CTG->(GetArea())
aCQDArea := CQD->(GetArea())

If (cTypeTrans == TRANS_SEND)
	If (cTypeMsg == EAI_MESSAGE_BUSINESS)
		lRet    := .T.
		cValInt := C010CalInt(cFilAnt, CTG->CTG_CALEND, CTG->CTG_EXERC)

		cXMLRet := '<BusinessEvent>'
		cXMLRet += ' <Entity>' + cMessage + '</Entity>'
		cXMLRet += ' <Event>' + If(ALTERA .or. INCLUI, 'upsert', 'delete') + '</Event>'
		cXMLRet += ' <Identification><key name="InternalId">' + cValInt + '</key></Identification>'
		cXMLRet += '</BusinessEvent>'
		cXMLRet += '<BusinessContent>'
		cXMLRet += ' <CompanyId>' + _NoTags(cEmpAnt) + '</CompanyId>'
		cXMLRet += ' <BranchId>' + _NoTags(cFilAnt) + '</BranchId>'
		cXMLRet += ' <CompanyInternalId>' + _NoTags(cEmpAnt + '|' + cFilAnt) + '</CompanyInternalId>'
		cXMLRet += ' <CalendarCode>' + _NoTags(RTrim(CTG->CTG_CALEND)) + '</CalendarCode>'
		cXMLRet += ' <InternalId>' + cValInt + '</InternalId>'
		cXMLRet += ' <FinancialYear>' + _NoTags(RTrim(CTG->CTG_EXERC)) + '</FinancialYear>'

		// Lista de períodos.
		cRecKey := CTG->(xFilial() + CTG_CALEND + CTG_EXERC)
		CTG->(dbSetOrder(1))  // CTG_FILIAL, CTG_CALEND, CTG_EXERC, CTG_PERIOD.
		If CTG->(dbSeek(cRecKey + cIniPer, .F.))
			cXMLRet += ' <ListOfAccountingPeriods>'
			Do While CTG->(!eof() .and. CTG_FILIAL + CTG_CALEND + CTG_EXERC == cRecKey .and. CTG_PERIOD <= cFimPer)
				cXMLRet += '  <PeriodOfAccount>'
				cXMLRet += '   <PeriodCode>' + _NoTags(RTrim(CTG->CTG_PERIOD)) + '</PeriodCode>'
				cXMLRet += '   <InitialDate>' + Transform(dtos(CTG->CTG_DTINI), "@R 9999-99-99") + '</InitialDate>'
				cXMLRet += '   <FinalDate>' + Transform(dtos(CTG->CTG_DTFIM), "@R 9999-99-99") + '</FinalDate>'
				cXMLRet += '   <PeriodStatus>' + _NoTags(RTrim(CTG->CTG_STATUS)) + '</PeriodStatus>'

				CQD->(dbSetOrder(1))  // CQD_FILIAL, CQD_CALEND, CQD_EXERC, CQD_PERIOD, CQD_PROC.
				If CQD->(dbSeek(xFilial() + CTG->(CTG_CALEND + CTG_EXERC + CTG_PERIOD), .F.))
					cXMLRet += '   <ListOfProcess>'
					Do While CQD->(!eof() .and. CQD_FILIAL + CQD_CALEND + CQD_EXERC + CQD_PERIOD == xFilial() + CTG->(CTG_CALEND + CTG_EXERC + CTG_PERIOD))
						cXMLRet += '    <Process>'
						cXMLRet += '     <Code>' + _NoTags(RTrim(CQD->CQD_PROC)) + '</Code>'
						cXMLRet += '     <Status>' + _NoTags(RTrim(CQD->CQD_STATUS)) + '</Status>'
						If !empty(CQD->CQD_DTINI)
							cXMLRet += '     <StartDate>' + Transform(dtos(CQD->CQD_DTINI), "@R 9999-99-99") + '</StartDate>'
						Endif
						If !empty(CQD->CQD_DTFIM)
							cXMLRet += '     <EndDate>' + Transform(dtos(CQD->CQD_DTFIM), "@R 9999-99-99") + '</EndDate>'
						Endif
						cXMLRet += '    </Process>'
						CQD->(dbSkip())
					EndDo
					cXMLRet += '   </ListOfProcess>'
				Endif

				cXMLRet += '  </PeriodOfAccount>'
				CTG->(dbSkip())
			EndDo
			cXMLRet += ' </ListOfAccountingPeriods>'
		Endif
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
						CFGA070Mnt(cRefer, "CTG", "CTG_CALEND", nil, cValInt, .T.)
					ElseIf !empty(cValInt) .and. !empty(cValExt)
						CFGA070Mnt(cRefer, "CTG", "CTG_CALEND", cValExt, cValInt)
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
			cValExt := oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/InternalId')

			// Verifica se encontrou uma chave no de/para.
			aValInt := C010GetInt(cValExt, cRefer)
			If aValInt[1]
				CTG->(dbSetOrder(1))  // CTG_FILIAL, CTG_CALEND, CTG_EXERC, CTG_PERIOD.
				lFound  := CTG->(dbSeek(aValInt[2, 2] + aValInt[2, 3] + aValInt[2, 4], .F.))
				cValInt := RTrim(aValInt[3])
			Endif

			If lFound
				If cEvent == 'UPSERT'
					nAutoOper := 4
				ElseIf cEvent == 'DELETE'
					nAutoOper := 5
				Else
					lRet  := .F.
					cErro := STR0004  // "Operação inválida. Somente são permitidas as operações UPSERT e DELETE."
				Endif
			Else
				If cEvent == 'UPSERT'
					nAutoOper := 3
				ElseIf cEvent == 'DELETE'
					lRet  := .F.
					cErro := STR0005  // "Registro não encontrado no Protheus."
				Else
					lRet  := .F.
					cErro := STR0004  // "Operação inválida. Somente são permitidas as operações UPSERT e DELETE."
				Endif
			Endif

			If lRet
				// Caminho do Business Content.
				cNodePath := '/TOTVSMessage/BusinessMessage/BusinessContent/'

				// Monta o cabeçalho da msExecAuto.
				If nAutoOper == 3
					cValInt := oXml:xPathGetNodeValue(cNodePath + 'CalendarCode')
					If empty(cValInt) .or. CTG->(dbSetOrder(1), dbSeek(xFilial() + cValInt, .F.))
						cValInt := CriaVar('CTG_CALEND', .T.)  // Pega inicializador padrão do campo.
						If empty(cValInt)  // Se não houver, usa sequência do sistema.
							cValInt := GetSXENum('CTG', 'CTG_CALEND')
						Endif
					Endif
				Else
					cValInt := CTG->CTG_CALEND
				Endif
				aAdd(aCabAuto, {"CTG_CALEND", cValInt, nil})

				cFinYear := oXml:xPathGetNodeValue(cNodePath + 'FinancialYear')
				aAdd(aCabAuto, {"CTG_EXERC", cFinYear, nil})

				// Monta itens.
				If nAutoOper <> 5
					aPeriods := oXml:XPathGetChildArray(cNodePath + "/ListOfAccountingPeriods")
					For nX := 1 to len(aPeriods)
						aAdd(aDetAuto, {})
						aLineAux := aTail(aDetAuto)
						cPeriod  := oXml:xPathGetNodeValue(aPeriods[nX, 2] + "/PeriodCode")
						aAdd(aLineAux, {"CTG_PERIOD", cPeriod, nil})
						aAdd(aLineAux, {"CTG_DTINI",  stod(StrTran(oXml:xPathGetNodeValue(aPeriods[nX, 2] + "/InitialDate"), "-", "")), nil})
						aAdd(aLineAux, {"CTG_DTFIM",  stod(StrTran(oXml:xPathGetNodeValue(aPeriods[nX, 2] + "/FinalDate"), "-", "")), nil})
						aAdd(aLineAux, {"CTG_STATUS", oXml:xPathGetNodeValue(aPeriods[nX, 2] + "/PeriodStatus"), nil})

						// Variável com os processos do item.
						aAdd(aDetPrc, {})

						// Monta os processos.
						aProcess := oXml:XPathGetChildArray(aPeriods[nX, 2] + "/ListOfProcess")
						If !empty(aProcess)
							lListProc := .T.
							aSubLAux  := aTail(aDetPrc)
							aAdd(aSubLAux, cPeriod)
							aAdd(aSubLAux, {})
							For nY := 1 to len(aProcess)
								aAdd(aSubLAux[2], {})
								aLineAux := aTail(aSubLAux[2])
								aAdd(aLineAux, oXml:xPathGetNodeValue(aProcess[nY, 2] + "/Code"))
								aAdd(aLineAux, oXml:xPathGetNodeValue(aProcess[nY, 2] + "/Status"))
								If oXml:xPathHasNode(aProcess[nY, 2] + "/StartDate") .or. oXml:xPathHasNode(aProcess[nY, 2] + "/EndDate")
									aAdd(aLineAux, oXml:xPathGetNodeValue(aProcess[nY, 2] + "/StartDate"))
									aAdd(aLineAux, oXml:xPathGetNodeValue(aProcess[nY, 2] + "/EndDate"))
								Endif
							Next nY
						Endif
					Next nX
				Endif

				Begin Transaction

				// Executa rotina.
				msExecAuto({|x, y, z| CTBA010(x, y, z)}, aCabAuto, aDetAuto, nAutoOper)

				If lMsErroAuto
					If __lSX8
						RollBackSX8()
					Endif

					cErro := STR0007  // "A integração não foi bem sucedida. "
					aErro := GetAutoGRLog()
					If !Empty(aErro)
						cErro += STR0008 + CRLF // 'Foi retornado o seguinte erro: '
						For nX := 1 To Len(aErro)
							cErro += aErro[nX] + CRLF
						Next nX
					Else
						cErro += STR0010  // "Verifique os dados enviados."
					Endif

					lRet := .F.
				Else
					If __lSX8
						ConfirmSX8()
					Endif

					// Grava os processos.
					If lListProc
						CTG->(dbSetOrder(1))  // CTG_FILIAL, CTG_CALEND, CTG_EXERC, CTG_PERIOD.
						CTG->(dbSeek(xFilial() + cValInt + cFinYear, .F.))

						// Carga inicial na tabela CQD.
						CT012LOAD()

						oModel := FwLoadModel(cModelId)
						oModel:SetOperation(MODEL_OPERATION_UPDATE)
						If oModel:Activate()
							oMdlCTG := oModel:GetModel("CTGDETAIL")
							oMdlCQD := oModel:GetModel("CQDDETAIL")
							For nX := 1 to len(aDetPrc)
								cPeriod  := aDetPrc[nX, 1]
								aLineAux := aDetPrc[nX, 2]

								If oMdlCTG:SeekLine({{"CTG_PERIOD", cPeriod}})
									For nY := 1 to len(aLineAux)
										If oMdlCQD:SeekLine({{"CQD_PROC", aLineAux[nY, 1]}})
											oMdlCQD:SetValue("CQD_STATUS", aLineAux[nY, 2])
											If len(aLineAux[nY]) > 2
												oMdlCQD:SetValue("CQD_DTINI",  stod(StrTran(aLineAux[nY, 3], "-", "")))
												oMdlCQD:SetValue("CQD_DTFIM",  stod(StrTran(aLineAux[nY, 4], "-", "")))
											Endif
										Endif
									Next nY
								Endif
							Next nX
							lRet := oModel:VldData() .and. oModel:CommitData()

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
						Else
							lRet  := .F.
							cErro := StrTran(STR0006, "%cModelId%", cModelId)  // "Erro ao ativar modelo %cModelId%."
						Endif

						oModel:Deactivate()
						oModel:Destroy()
						oModel := nil
					Endif
				Endif

				// Verifica se gravou tudo com sucesso.
				If lRet
					// Atualiza o de/para local.
					If nAutoOper = 3 .or. nAutoOper = 5
						cValInt := C010CalInt(cFilAnt, cValInt, cFinYear)
						If nAutoOper = 5
							CFGA070Mnt(cRefer, "CTG", "CTG_CALEND", nil, cValInt, .T.)
						ElseIf nAutoOper = 3
							CFGA070Mnt(cRefer, "CTG", "CTG_CALEND", cValExt, cValInt)
						Endif
					Endif

					// Se gravou certo, retorna o código gravado.
					cXmlRet := '<ListOfInternalId>'
					cXmlRet += ' <InternalId>'
					cXmlRet += '  <Name>AccountingCalendarInternalId</Name>'
					cXmlRet += '  <Origin>' + cValExt + '</Origin>'
					cXmlRet += '  <Destination>' + cValInt + '</Destination>'
					cXmlRet += ' </InternalId>'
					cXmlRet += '</ListOfInternalId>'
				Else
					DisarmTransaction()
				Endif

				End Transaction
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

RestArea(aCQDArea)
RestArea(aCTGArea)
RestArea(aArea)

Return {lRet, cXmlRet, cMessage}


/*/{Protheus.doc} C010GetInt
Recebe um codigo, busca seu InternalId e faz a quebra da chave

@param   cCodigo       InternalID recebido na mensagem.
@param   cMarca        Produto que enviou a mensagem
@param   lPeriodo      Será a chave do período.

@author	Alvaro Camillo Neto
@version	MP11.90
@since		28/08/13
@return	aRetorno Array contendo os campos da chave primaria da natureza e o seu internalid.
@sample	exemplo de retorno - {.T., {'Empresa', 'xFilial', 'Codigo' }, InternalId}
/*/
Static Function C010GetInt(cCodigo, cMarca , lPeriodo)

Local cValInt    := ''
Local aRetorno   := {}
Local aAux       := {}
Local aCampos    := {}
Local nX

Default lPeriodo := .F.

If lPeriodo
	 aCampos := {cEmpAnt, 'CTG_FILIAL', 'CTG_CALEND', 'CTG_EXERC', 'CTG_PERIOD'}
	 cValInt := CFGA070Int(cMarca, 'CTG', 'CTG_PERIOD', cCodigo)
Else
	 aCampos := {cEmpAnt, 'CTG_FILIAL', 'CTG_CALEND', 'CTG_EXERC'}
	 cValInt := CFGA070Int(cMarca, 'CTG', 'CTG_CALEND', cCodigo)
EndIf

If Empty(cValInt)
	aRetorno := {.F., {}, ""}
Else
	aAux := Separa(cValInt, '|')

	// Corrigindo o tamanho dos campos.
	aAux[1] := Padr(aAux[1], Len(cEmpAnt))
	For nX := 2 to Len(aAux)
		aAux[nX] := Padr(aAux[nX], TamSX3(aCampos[nX])[1])
	Next nX

	aRetorno := {.T., aAux, cValInt}
EndIf

Return aRetorno


/*/{Protheus.doc} C010CalInt
Recebe um registro no Protheus e gera o InternalId deste registro

@param   cFilPar       Filial do registro
@Param   cCod          Código do calendário
@param   cExerc        Exercício

@author  	Alvaro Camillo Neto
@version 	P11.9
@since   	09/09/13
@return  	cRetorno - Retorna o InternalId do registro
/*/
Function C010CalInt(cFilPar, cCod, cExerc)
Return cEmpAnt + '|' + Alltrim(xFilial("CTG", cFilPar)) + '|' + Alltrim(cCod) + '|' + Alltrim(cExerc)


/*/{Protheus.doc} CTI010Ini
Atribui o valor inicial dos periodos para exportação

@param		cIniPeriod, Periodo Inicial

@author 	Alvaro Camillo Neto
@version 	P11.9
@since 		09/09/13
/*/
Function CTI010Ini(cPeriod)
	cIniPer := cPeriod
Return


/*/{Protheus.doc} CTI010Ini
Atribui o valor inicial dos periodos para exportação

@param		cFimPeriod, Periodo Final

@author 	Alvaro Camillo Neto
@version	P11.9
@since 		09/09/13
/*/
Function CTI010Fim(cPeriod)
	cFimPer := cPeriod
Return
