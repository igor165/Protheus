#Include 'Protheus.ch'
#Include 'fwAdapterEAI.ch'
#Include 'FINI040A.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} FINI040A
Funcao de integracao com o adapter EAI para envio e recebimento de
substituição de título a receber utilizando o conceito de mensagem unica.

@param	cXml       - XML recebido pelo EAI Protheus
		cTypeTrans - Tipo de transação
					"0" = TRANS_RECEIVE
					"1" = TRANS_SEND
		cTypeMsg   - Tipo da mensagem do EAI
					"20" = EAI_MESSAGE_BUSINESS
					"21" = EAI_MESSAGE_RESPONSE
					"22" = EAI_MESSAGE_RECEIPT
					"23" = EAI_MESSAGE_WHOIS
		cVersion   - Versão da Mensagem Única TOTVS
		cTransac   - Nome da mensagem iniciada no adapter.

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   02/10/2013
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem Xml para envio

@obs     O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
         o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
         TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
         O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------
Function FINI040A(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

	Local lLog             := FindFunction("AdpLogEAI")
	Local lRet             := .T.
	Local cXmlRet          := ""
	Local nOpcx            := 6
	Local cAlias           := "SE1"
	Local cField           := "E1_NUM"
	Local nI               := 0
	Local cError           := ""
	Local cWarning         := ""
	Local cProduct         := ""
	Local cValInt          := ""
	Local cValInt2         := ""
	Local cValExt          := ""
	Local cValExt2         := ""
	Local lCopiaProv       := .F.
	Local aTit             := {}
	Local aTitPrv          := {}
	Local cPrefixo         := ""
	Local cNumDoc          := ""
	Local cParcela         := ""
	Local cTipoDoc         := ""
	Local nCont            := 0
	Local dVenc            := Nil
	Local cMoeVer          := ""
	Local cCliVer          := ""
	Local cLoja            := ""
	Local cTarefa          := ""
	Local aRatPrj          := {}
	Local xAux             := Nil
	Local aIntPrj          := {}
	Local cValIntRat       := ""
	Local cValExtRat       := ""
	Local aRatAux          := {}

	Private oXml           := Nil
	Private oXmlAux        := Nil
	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.

	IIf(lLog, AdpLogEAI(1, "FINI040A", cTypeTrans, cTypeMsg, cXml), ConOut(STR0001)) //"Atualize o pmsxsolum.prw para utilizar o log"

	// Mensagem de Entrada
	If cTypeTrans == TRANS_RECEIVE
		If cTypeMsg == EAI_MESSAGE_BUSINESS
			oXml := xmlParser(cXml, "_", @cError, @cWarning)

			If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
				//Verifica se a marca foi informada
				If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
					cProduct := oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					lRet := .F.
					cXmlRet := STR0002 //"Informe o produto!"
					IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0001))
					Return {lRet, cXmlRet}
				EndIf

				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CopyDataFromTemporary:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CopyDataFromTemporary:Text)
					If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CopyDataFromTemporary:Text) == "TRUE" .Or. oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CopyDataFromTemporary:Text == "1"
						lCopiaProv := .T.
					EndIf
				EndIf

				//Verifica se o InternalId do título provisório foi informado
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TemporaryAccountReceivableDocument:_InternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TemporaryAccountReceivableDocument:_InternalId:Text)
					cValExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TemporaryAccountReceivableDocument:_InternalId:Text
				Else
					lRet := .F.
					cXmlRet := STR0003 //"O InternalId do título provisório é obrigatório!"
					IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0001))
					Return {lRet, cXmlRet}
				EndIf

				//Verifica se o InternalId do título efetivo foi informado
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_InternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_InternalId:Text)
					cValExt2 := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_InternalId:Text
				Else
					lRet := .F.
					cXmlRet := STR0004 //"O InternalId do título efetivo é obrigatório!"
					IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0001))
					Return {lRet, cXmlRet}
				EndIf

				//Obtém o valor interno da tabela XXF (de/para)
				cValInt := RTrim(CFGA070Int(cProduct, cAlias, cField, cValExt))

				If Empty(cValInt)
					lRet := .F.
					cXmlRet := STR0005 //"O título provisório não foi encontrado!"
					IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0001))
					Return {lRet, cXmlRet}
				Else
					cPrefixo := PadR(Separa(cValInt, '|')[3], TamSX3("E1_PREFIXO")[1])
					cNumDoc  := PadR(Separa(cValInt, '|')[4], TamSX3("E1_NUM")[1])
					cParcela := PadR(Separa(cValInt, '|')[5], TamSX3("E1_PARCELA")[1])
					cTipoDoc := PadR(Separa(cValInt, '|')[6], TamSX3("E1_TIPO")[1])

					dbSelectArea("SE1")
					SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

					If SE1->(dbSeek(xFilial("SE1") + cPrefixo + cNumDoc + cParcela + cTipoDoc))
						aAux := {}
						aAdd(aAux, {"E1_PREFIXO", cPrefixo,        Nil})
						aAdd(aAux, {"E1_NUM",     cNumDoc,         Nil})
						aAdd(aAux, {"E1_PARCELA", cParcela,        Nil})
						aAdd(aAux, {"E1_TIPO",    cTipoDoc,        Nil})
						aAdd(aAux, {"E1_CLIENTE", SE1->E1_CLIENTE, Nil})
						aAdd(aAux, {"E1_LOJA",    SE1->E1_LOJA,    Nil})
						aAdd(aTitPrv, aAux)
					Else
						lRet := .F.
						cXmlRet := STR0006 //"O título provisório não foi encontrado na base de dados!"
						IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0001))
						Return {lRet, cXmlRet}
					EndIf
				EndIf

				//Verifica se o Prefixo do Título foi informado
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_DocumentPrefix:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_DocumentPrefix:Text)
					cPrefixo := AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_DocumentPrefix:Text)
				ElseIf IsIntegTop() //Possui integração com o RM Solum
					cPrefixo := GetNewPar("MV_SLMPRER", "")
				Else
					lRet := .F.
					cXmlRet := STR0007 //"Informe o prefixo do título."
					IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0001))
					Return {lRet, cXmlRet}
				EndIf

				//Verifica se o número do título foi informado
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_DocumentNumber:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_DocumentNumber:Text)
					// Verifica se não possui numeração automática
					If Empty(Posicione('SX3', 2, Padr('E1_NUM', 10), 'X3_RELACAO'))
						cNumDoc := AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_DocumentNumber:Text)
					EndIf
				Else
					lRet := .F.
					cXmlRet := STR0008 //"Informe o número do título"
					IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0001))
					Return {lRet, cXmlRet}
				EndIf

				//Verifica se a parcela do título foi informada
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_DocumentParcel:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_DocumentParcel:Text)
					cParcela := AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_DocumentParcel:Text)
				EndIf

				//Verifica se o tipo do título foi informado
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_DocumentTypeCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_DocumentTypeCode:Text)
					cTipoDoc := AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_DocumentTypeCode:Text)
				Else
					lRet := .F.
					cXmlRet := STR0010 //"Informe o tipo do título"
					IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0001))
					Return {lRet, cXmlRet}
				EndIf

				aAdd(aTit, {"E1_PREFIXO", PadR(cPrefixo, TamSX3("E1_PREFIXO")[1]), Nil})
				aAdd(aTit, {"E1_NUM",     PadR(cNumDoc,  TamSX3("E1_NUM")[1]),     Nil})
				aAdd(aTit, {"E1_PARCELA", PadR(cParcela, TamSX3("E1_PARCELA")[1]), Nil})
				aAdd(aTit, {"E1_TIPO",    PadR(cTipoDoc, TamSX3("E1_TIPO")[1]),    Nil})

				cValInt2 := IntTRcExt(, , cPrefixo, cNumDoc, cParcela, cTipoDoc)[2]

				// Verifica se Natureza foi informada
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_FinancialNatureInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_FinancialNatureInternalId:Text)
					cNatExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_FinancialNatureInternalId:Text
					aAux := F10GetInt(cNatExt, cProduct) //Adapter FINI010I

					If aAux[1]
						aAdd(aTit, {"E1_NATUREZ", PadR(aAux[2][3], TamSX3("E1_NATUREZ")[1]), Nil})
					Else
						lRet := .F.
						cXmlRet := STR0011 + " " + cNatExt //"Natureza não encontrada no de/para."
						IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0001))
						Return {lRet, cXmlRet}
					EndIf
				ElseIf lCopiaProv
					aAdd(aTit, {"E1_NATUREZ", SE1->E1_NATUREZ, Nil})
				Else // Utiliza o parâmetro MV_SLMNATR criado para a integração Protheus x RM Solum para
					// as demais integrações quando o FinancialNatureInternalId não for informado
					cNaturez := RTrim(GetNewPar("MV_SLMNATR", ""))

					If !Empty(cNaturez)
						aAdd(aTit, {"E1_NATUREZ", PadR(cNaturez, TamSX3("E1_NATUREZ")[1]), Nil})
					Else
						lRet := .F.
						cXmlRet := STR0012 //"Natureza não informada. Verifique o parâmetro MV_SLMNATR."
						IIf(lLog, AdpLogEAI(5, "FINI050", cXMLRet, lRet), ConOut(STR0001))
						Return {lRet, cXmlRet}
					EndIf
				EndIf

				//Obtém o Código Interno do Cliente
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_CustomerInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_CustomerInternalId:Text)
					cCliVer := MsgUVer('MATA030', 'CUSTOMERVENDOR')
					aAux := IntCliInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_CustomerInternalId:Text, cProduct, cCliVer)
					If !aAux[1]
						lRet := aAux[1]
						cXmlRet := aAux[2]
						IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0001))
						Return {lRet, cXmlRet}
					Else
						If cCliVer = "1."
							cCliente := aAux[2][1]
							cLoja    := aAux[2][2]
						Else
							cCliente := aAux[2][3]
							cLoja    := aAux[2][4]
						Endif
						aAdd(aTit, {"E1_CLIENTE", PadR(cCliente, TamSX3("E1_CLIENTE")[1]), Nil})
						aAdd(aTit, {"E1_LOJA", PadR(cLoja, TamSX3("E1_LOJA")[1]), Nil})
					EndIf
				ElseIf lCopiaProv
					aAdd(aTit, {"E1_CLIENTE", SE1->E1_CLIENTE, Nil})
					aAdd(aTit, {"E1_LOJA", SE1->E1_LOJA, Nil})
				EndIf

				//Verifica se a data de emissão do título foi informada
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_IssueDate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_IssueDate:Text)
					aAdd(aTit, {"E1_EMISSAO", SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_IssueDate:Text,"-","")), Nil})
				ElseIf lCopiaProv
					aAdd(aTit, {"E1_EMISSAO", SE1->E1_EMISSAO, Nil})
				Else
					lRet := .F.
					cXmlRet := STR0013 //"Informe a data de emissão do título."
					IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0001))
					Return {lRet, cXmlRet}
				EndIf

				//Verifica se o Vencimento do Título foi informado
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_DueDate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_DueDate:Text)
					dVenc := SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_DueDate:Text,"-",""))
					aAdd(aTit, {"E1_VENCTO",  dVenc, Nil})
					aAdd(aTit, {"E1_VENCREA", dVenc, Nil})
				ElseIf lCopiaProv
					aAdd(aTit, {"E1_VENCTO", SE1->E1_VENCTO, Nil})
					aAdd(aTit, {"E1_VENCREA", SE1->E1_VENCREA, Nil})
				Else
					lRet := .F.
					cXmlRet := STR0014 //"Informe o vencimento do título"
					IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0001))
					Return {lRet, cXmlRet}
				EndIf

				// Verifica se o Valor do Título foi informado
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_NetValue:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_NetValue:Text)
					aAdd(aTit, {"E1_VALOR", Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_NetValue:Text), Nil})
					aAdd(aTit, {"E1_VLCRUZ", Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_NetValue:Text), Nil})
				ElseIf lCopiaProv
					aAdd(aTit, {"E1_VALOR", SE1->E1_VALOR, Nil})
					aAdd(aTit, {"E1_VLCRUZ", SE1->E1_VLCRUZ, Nil})
				Else
					lRet := .F.
					cXmlRet := STR0015 //"Informe o valor do título"
					IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0001))
					Return {lRet, cXmlRet}
				EndIf

				// Desconto financeiro (%)
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_DiscountPercentage:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_DiscountPercentage:Text)
					aAdd(aTit, {"E1_DESCFIN", Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_DiscountPercentage:Text), Nil})
				ElseIf lCopiaProv
					aAdd(aTit, {"E1_DESCFIN", SE1->E1_DESCFIN, Nil})
				EndIf

				// Histórico
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_Observation:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_Observation:Text)
					aAdd(aTit, {"E1_HIST", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_Observation:Text, NIL})
				ElseIf lCopiaProv
					aAdd(aTit, {"E1_HIST", SE1->E1_HIST, Nil})
				EndIf

				// Origem do título
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_Origin:Text)
					aAdd(aTit, {"E1_ORIGEM", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_Origin:Text, Nil})
				ElseIf lCopiaProv
					aAdd(aTit, {"E1_ORIGEM", SE1->E1_ORIGEM, Nil})
				Else
					aAdd(aTit, {"E1_ORIGEM", "FINI040A", Nil})
				EndIf

				// Moeda
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_CurrencyInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_CurrencyInternalId:Text)
					cMoeVer := MsgUVer('CTBA140', 'CURRENCY')
					aAux := IntMoeInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_CurrencyInternalId:Text, cProduct, cMoeVer) //Adapter CTBI140
					If !aAux[1]
						lRet := aAux[1]
						cXmlRet := aAux[2]
						IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0001))
						Return {lRet, cXmlRet}
					Else
						If cMoeVer = "1."
							aAdd(aTit, {"E1_MOEDA", Val(aAux[2][2]), Nil})
						Else
							aAdd(aTit, {"E1_MOEDA", Val(aAux[2][3]), Nil})
						Endif
					EndIf
				ElseIf lCopiaProv
					aAdd(aTit, {"E1_MOEDA", SE1->E1_MOEDA, Nil})
				Else
					aAdd(aTit, {"E1_MOEDA", 1, Nil})
				EndIf
			Else
				lRet    := .F.
				cXmlRet := STR0016 //"Erro no parser!"
				IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0001))
				Return {lRet, cXmlRet}
			EndIf

			//Possui rateio
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_ListOfApportion:_Apportion") != "U"
				//Se não for Array
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_ListOfApportion:_Apportion") != "A"
					//Transforma em array
					XmlNode2Arr(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_ListOfApportion:_Apportion,"_Apportion")
				EndIf

				For nI := 1 To Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_ListOfApportion:_Apportion)
					// Atualiza o objeto com a posição atual
					oXmlAux := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountReceivableDocument:_ListOfApportion:_Apportion[nI]
					// Se possui projeto informado
					If Type("oXmlAux:_ProjectInternalId:Text") != "U" .And. !Empty(oXmlAux:_ProjectInternalId:Text)
						// Verifica se o código do projeto é válido
						aAux := IntPrjInt(oXmlAux:_ProjectInternalId:Text, cProduct) //Empresa/Filial/Projeto
						If !aAux[1]
							lRet := .F.
							cXmlRet := aAux[2] + " " + STR0019 + " " + cNumDoc //"Título"
							IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0006))
							Return {lRet, cXmlRet}
						Else
							xAux := aAux[2][3]
						EndIf

						If Type("oXmlAux:_TaskInternalId:Text") != "U" .And. !Empty(oXmlAux:_TaskInternalId:Text)
							aAux := IntTrfInt(oXmlAux:_TaskInternalId:Text, cProduct) //Empresa/Filial/Projeto/Revisao/Tarefa
							If !aAux[1]
								lRet := .F.
								cXmlRet := aAux[2] + " " + STR0019 + " " + cNumDoc //"Título"
								IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0006))
								Return {lRet, cXmlRet}
							Else
								cTarefa := PadR(aAux[2][5], TamSX3("AFT_TAREFA")[1])
							EndIf
						ElseIf cTipoDoc $ MVRECANT
							// No Adiantamento não é informada uma tarefa, só Projeto.
							// Aqui se obtém a primeira Tarefa do Projeto informado.
							AF9->(DbSetOrder(5)) // AF9_FILIAL + AF9_PROJET + AF9_TAREFA

							If AF9->(dbSeek(xFilial("AF9") + PadR(xAux, TamSX3("AF9_PROJET")[1])))
								cTarefa := AF9->AF9_TAREFA
							Else
								lRet := .F.
								cXmlRet := STR0020 //"Não existe tarefa para o projeto informado."
								IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0006))
								Return {lRet, cXmlRet}
							EndIf
						Else
							lRet := .F.
							cXmlRet := STR0021 //"Tarefa do projeto não informada."
							IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0006))
							Return {lRet, cXmlRet}
						EndIf

						// Se possui valor informado
						If Type("oXmlAux:_Value:Text") != "U" .And. !Empty(oXmlAux:_Value:Text)
							// Se já existe o projeto/tarefa somar os valores
							If (nCont := aScan(aRatPrj, {|x| RTrim(x[1][2]) == RTrim(xAux) .And. RTrim(x[3][2]) == RTrim(cTarefa)})) > 0
								aRatPrj[nCont][10][2] := aRatPrj[nCont][10][2] + Val(oXmlAux:_Value:Text)
							Else
								aAdd(aRatAux, {"AFT_PROJET", PadR(xAux, TamSX3("AFT_PROJET")[1]),  Nil})
								aAdd(aRatAux, {"AFT_REVISA", StrZero(1, TamSX3("AFT_REVISA")[1]),  Nil})
								aAdd(aRatAux, {"AFT_TAREFA", cTarefa,                              Nil})
								aAdd(aRatAux, {"AFT_PREFIX", cPrefixo,                             Nil})
								aAdd(aRatAux, {"AFT_NUM",    cNumDoc,                              Nil})
								aAdd(aRatAux, {"AFT_PARCEL", cParcela,                             Nil})
								aAdd(aRatAux, {"AFT_TIPO",   cTipoDoc,                             Nil})
								aAdd(aRatAux, {"AFT_CLIENT", cCliente,                             Nil})
								aAdd(aRatAux, {"AFT_LOJA",   cLoja,                                Nil})
								aAdd(aRatAux, {"AFT_VALOR1", Val(oXmlAux:_Value:Text),             Nil})
								aAdd(aRatAux, {"AFT_DATA",   dVenc,                                Nil})
								aAdd(aRatAux, {"AFT_VENREA", dVenc,                                Nil})
								aAdd(aRatPrj, aRatAux)
								aRatAux := {}

								//De/Para do rateio de projeto
								cValIntRat := IntTRcExt(, , cPrefixo, cNumDoc, cParcela, cTipoDoc)[2] + "|" + AllTrim(cCliente) + "|" + AllTrim(cLoja) + "|" + AllTrim(xAux) + "|" + StrZero(1, TamSX3("AFT_REVISA")[1]) + "|" + AllTrim(cTarefa)

								If Type("oXmlAux:_InternalId:Text") != "U" .And. !Empty(oXmlAux:_InternalId:Text)
									cValExtRat := oXmlAux:_InternalId:Text
								Else
									cValExtRat := oXmlAux:_TaskInternalId:Text
								EndIf

								aAdd(aIntPrj, {"AFT", "AFT_TAREFA", cValIntRat, cValExtRat})
							EndIf
						Else
							lRet := .F.
							cXmlRet := STR0022 + cNumDoc //"Valor do rateio inválido para o título "
							IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0006))
							Return {lRet, cXmlRet}
						EndIf
					EndIf
				Next nI
			EndIf

			If lCopiaProv // Copiar os rateios do título provisório
				// Rateio de projeto
				If Empty(aRatPrj)
					dbSelectArea("AFT")
					AFT->(dbSetOrder(2)) // AFT_FILIAL+AFT_PREFIX+AFT_NUM+AFT_PARCEL+AFT_TIPO+AFT_CLIENT+AFT_LOJA+AFT_PROJET+AFT_REVISA+AFT_TAREFA

					If AFT->(dbSeek(xFilial("AFT") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENT + SE1->E1_LOJA))
						While xFilial("AFT") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENT + SE1->E1_LOJA == AFT->AFT_FILIAL + AFT->AFT_PREFIX + AFT->AFT_NUM + AFT->AFT_PARCEL + AFT->AFT_TIPO + AFT->AFT_CLIENT + AFT->AFT_LOJA .And. !AFT->(Eof())
							aAux := {}
							aAdd(aAux, {"AFT_PROJET", AFT->AFT_PROJET, Nil})
							aAdd(aAux, {"AFT_REVISA", AFT->AFT_REVISA, Nil})
							aAdd(aAux, {"AFT_TAREFA", AFT->AFT_TAREFA, Nil})
							aAdd(aAux, {"AFT_PREFIX", AFT->AFT_PREFIX, Nil})
							aAdd(aAux, {"AFT_NUM",    AFT->AFT_NUM,    Nil})
							aAdd(aAux, {"AFT_PARCEL", AFT->AFT_PARCEL, Nil})
							aAdd(aAux, {"AFT_TIPO",   AFT->AFT_TIPO,   Nil})
							aAdd(aAux, {"AFT_CLIENT", AFT->AFT_CLIENT, Nil})
							aAdd(aAux, {"AFT_LOJA",   AFT->AFT_LOJA,   Nil})
							aAdd(aAux, {"AFT_VALOR1", AFT->AFT_VALOR1, Nil})
							aAdd(aAux, {"AFT_DATA",   AFT->AFT_DATA,   Nil})
							aAdd(aAux, {"AFT_VENREA", AFT->AFT_VENREA, Nil})
							aAdd(aRatPrj, aAux)

							AFT->(dbSkip())
						EndDo
					EndIf
				EndIf
			EndIf

			//LOG
			If lLog
				AdpLogEAI(3, "aTit: ", aTit)
				AdpLogEAI(3, "aTitPrv: ", aTitPrv)
				AdpLogEAI(3, "cValInt(Título provisório): ", cValInt)
				AdpLogEAI(3, "cValExt(Título provisório): ", cValExt)
				AdpLogEAI(3, "cValInt(Título original): ", cValInt2)
				AdpLogEAI(3, "cValExt(Título original): ", cValExt2)
				AdpLogEAI(3, "aRatPrj: ", aRatPrj)
				AdpLogEAI(3, "aIntPrj: ", aIntPrj)
				AdpLogEAI(4, nOpcx)
			Else
				ConOut(STR0001)
			EndIf

			MSExecAuto({|x,y,z| FINA040(x,y,z)}, aTit, nOpcx, aTitPrv)

			// Se houve erros no processamento do MSExecAuto
			If lMsErroAuto
				aErroAuto := GetAutoGRLog()

				cXMLRet := "<![CDATA["
				For nI := 1 To Len(aErroAuto)
					cXMLRet += aErroAuto[nI] + Chr(10)
				Next nI
				cXMLRet += "]]>"

				lRet := .F.
			Else
				//Grava o rateio de projeto fora da rotina automatica
				//A pedido da equipe de Controladoria
				If Len(aRatPrj) > 0
					pmsWsCR(cValToChar(3), aRatPrj)
				EndIf

				// Inclui o registro na tabela XXF (de/para)
				CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F., 1)
				CFGA070Mnt(cProduct, cAlias, cField, cValExt2, cValInt2, .F., 1)

				//De/Para do rateio
				For nI := 1 To Len(aIntPrj)
					CFGA070Mnt(cProduct, aIntPrj[nI][1], aIntPrj[nI][2], aIntPrj[nI][4], aIntPrj[nI][3], .F., 1)
				Next nI

				// Monta o XML de retorno
				cXMLRet := "<ListOfInternalId>"
				cXMLRet +=    "<InternalId>"
				cXMLRet +=       "<Name>TemporaryAccountReceivableDocumentInternalId</Name>"
				cXMLRet +=       "<Origin>" + cValExt + "</Origin>"
				cXmlRet +=       "<Destination>" + cValInt + "</Destination>"
				cXMLRet +=    "</InternalId>"
				cXMLRet +=    "<InternalId>"
				cXMLRet +=       "<Name>OriginalAccountReceivableDocumentInternalId</Name>"
				cXMLRet +=       "<Origin>" + cValExt2 + "</Origin>"
				cXmlRet +=       "<Destination>" + cValInt2 + "</Destination>"
				cXMLRet +=    "</InternalId>"
				For nI := 1 To Len(aIntPrj)
					cXMLRet += "<InternalId>"
					cXMLRet +=    "<Name>OriginalApportionmentInternalId</Name>"
					cXMLRet +=    "<Origin>" + aIntPrj[nI][4] + "</Origin>"
					cXmlRet +=    "<Destination>" + aIntPrj[nI][3] + "</Destination>"
					cXMLRet += "</InternalId>"
				Next nI
				cXMLRet += "</ListOfInternalId>"
			EndIf
		ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE
			lRet    := .F.
			cXMLRet := STR0017 //"Resposta não implementada."
		ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
			cXMLRet := "1.000"
		EndIf
	ElseIf cTypeTrans == TRANS_SEND
		lRet    := .F.
		cXMLRet := STR0018 //"Envio não implementado."
	EndIf

	IIf(lLog, AdpLogEAI(5, "FINI040A", cXMLRet, lRet), ConOut(STR0001))

Return {lRet, cXMLRet, "AccountReceivableDocumentReplace"}


/*/{Protheus.doc} MsgUVer
	Função que verifica a versão de uma mensagem única cadastrada no adapter EAI.

	Essa função deverá ser EXCLUÍDA e substituída pela função FwAdapterVersion()
	após sua publicação na Lib de 2019.

	@param cRotina		Rotina que possui a IntegDef da Mensagem Unica
	@param cMensagem	Nome da Mensagem única a ser pesquisada

	@author		Felipe Raposo
	@version	P12
	@since		23/11/2018
	@return		xVersion - versão da mensagem única cadastrada. Se não encontrar, retorna nulo.
/*/
Static Function MsgUVer(cRotina, cMensagem)

Local aArea    := GetArea()
Local xVersion

xVersion := FwAdapterVersion(cRotina, cMensagem)

RestArea(aArea)


Return xVersion
