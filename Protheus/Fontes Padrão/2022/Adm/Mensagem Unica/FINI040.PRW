#Include 'Protheus.ch'
#Include 'fwAdapterEAI.ch'
#Include 'FINI040.CH'
#INCLUDE "FWLIBVERSION.CH"

Static cMessage  := "AccountReceivableDocument"
Static lFI040POS := ExistBlock("FI040POS")
Static __lMetric := .F.

//----------------------------------------------------------------------------------
/*/{Protheus.doc} FINI040
Funcao de integracao com o adapter EAI para envio e recebimento do
título a receber (SE1) utilizando o conceito de mensagem unica
(AccountReceivableDocument).

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   cTypeTrans    Tipo de transação (Envio/Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Versão da mensagem.
@param   cTransac      Nome da transação.

@author  Leandro Luiz da Cruz
@version P11
@since   17/04/2013
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
aRet[1] - (boolean) Indica o resultado da execução da função
aRet[2] - (caractere) Mensagem Xml para envio
aRet[3] - (caractere) Nome da mensagem para retorno no WHOIS

@obs     O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//----------------------------------------------------------------------------------
Function FINI040(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
	
	Local aArea   := GetArea()
	Local lRet    := .F.
	Local cXmlRet := ""
	Local aRet    := {}
	
	__lMetric	:= FwLibVersion() >= "20210517" 

	If (cTypeMsg == EAI_MESSAGE_WHOIS)
		lRet    := .T.
		cXmlRet := '1.000|2.000|2.002|2.003|2.004|2.005|2.006|2.007|2.008|3.000'
	
	ElseIf (cTypeTrans == TRANS_SEND .or. cTypeTrans == TRANS_RECEIVE)
		If cVersion = "1." .or. cVersion = "2."
			aRet := v2000(cXml, cTypeTrans, cTypeMsg, cVersion)
			lRet    := aRet[1]
			cXmlRet := aRet[2]
		ElseIf cVersion = "3."
			aRet := v3000(cXml, cTypeTrans, cTypeMsg, cVersion)
			lRet    := aRet[1]
			cXmlRet := aRet[2]
		Else
			lRet    := .F.
			cXmlRet := STR0027 // "A versão da mensagem informada não foi implementada!"
		Endif
	Endif
	
	// Ponto de entrada no final da rotina para tratamento do XML.
	If lFI040POS
		aRet := ExecBlock("FI040POS", .F., .F., {lRet, cXmlRet, cTypeTrans, cTypeMsg, cVersion, cTransac})
		If ValType(aRet) = "A" .and. len(aRet) > 1
			lRet    := aRet[1]
			cXmlRet := aRet[2]
		Endif
	Endif
	
	RestArea(aArea)
Return {lRet, cXmlRet, cMessage}

//----------------------------------------------------------------------------------
/*/{Protheus.doc} v2000
@author  Leandro Luiz da Cruz
@since   17/04/2013
/*/
//----------------------------------------------------------------------------------
Static Function v2000(cXml, cTypeTrans, cTypeMsg, cVersion)
Local lRet       := .T.
Local nOpcx      := 0
Local cEvent     := "upsert"
Local cAlias     := "SE1"
Local cField     := "E1_NUM"
Local cBase      := "E1_BASE"
Local cImpBase   := "0.0"
Local cXmlRet    := ""
Local cMarca     := ""
Local cValInt    := ""
Local cValExt    := ""
Local cCliente   := ""
Local cPrefixo   := ""
Local cParcela   := ""
Local cNumDoc    := ""
Local cRelacao   := ""
Local cTipoDoc   := ""
Local cNaturez   := ""
Local cSE1       := ""
Local cSE1b      := ""
Local cE1        := ""
Local cImposto   := ""
Local cError     := ""
Local cWarning   := ""
Local nI         := 0
Local aTit       := {}
Local aAux       := {}
Local aRatAux    := {}
Local aImposto   := {"ISS", "IRRF", "INSS", "COFINS", "PIS", "CSLL"}
Local aRateio    := {}
Local nCont      := 0
Local dVenc      := Nil
Local cMoeVer    := ""
Local cCliVer    := ""
Local cLoja      := ""
Local cTarefa    := ""
Local aRatPrj    := {}
Local xAux       := Nil
Local aIntPrj    := {}
Local cValIntRat := ""
Local cValExtRat := ""
Local cInternoId := ""
Local aAuxVA     := {}
Local nLaco      := 0
Local cFK7Chv    := ""
Local lFI040SE1  := ExistBlock("FI040SE1")
Local aAuxInc    := {}
Local lHotel     := SuperGetMV( "MV_INTHTL", , .F. )
Local cCustRat   := SuperGetMV( "MV_HTLCCRT", , "" )
Local dDataAux   := dDataBase
Local lRatNat    := .F.
Local aRatNat    := {}
Local aNat       := {}
Local aNatCC     := {}
Local aAuxSEZ    := {}
Local nJ         := 0
Local aAuxEnt    := {}
Local nValTit    := 0
Local cChaveTit  := ""
Local lFKD       := TableInDic("FKD")
Local cCodVA     := ""
Local nValAcess  := 0
Local lCposVA    := SE1->(ColumnPos("E1_CONHTL")) > 0 .And. SE1->(ColumnPos("E1_TCONHTL")) > 0
Local lV2005     := VAL(STRTRAN(cVersion,".","")) >= 2005
Local cIdDoc     := ""
Local aValAce    := {}
Local cNatExt    := ""
Local aAuxRet    := {}
Local dDataDel   := dDataBase

Private oXmlAux        := Nil
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.

	AdpLogEAI(1, "FINI040", cTypeTrans, cTypeMsg, cXML)

	If cTypeTrans == TRANS_RECEIVE

		If cTypeMsg == EAI_MESSAGE_BUSINESS
			oXml := xmlParser(cXml, "_", @cError, @cWarning)

			If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)

				//Verifica se a marca foi informada
				If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
					cMarca := oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					lRet := .F.
					cXmlRet := STR0007 //"Informe a Marca!"
					AdpLogEAI(5, "FINI040", cXMLRet, lRet)
					Return {lRet, _NoTags(cXmlRet)}
				EndIf

				//Verifica se o InternalId foi informado
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
					cValExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
				Else
					lRet := .F.
					cXmlRet := STR0008 //"O InternalId é obrigatório!"
					AdpLogEAI(5, "FINI040", cXMLRet, lRet)
					Return {lRet, _NoTags(cXmlRet)}
				EndIf

				//Obtém o valor interno
				aAux := IntTRcInt(cValExt, cMarca)

				// Obtém dados utilizado somente no UPSERT
				If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
					// Se o registro existe
					If aAux[1]
						nOpcx := 4 // Update

						cPrefixo := PadR(aAux[2][3],TamSX3("E1_PREFIXO")[1])
						cNumDoc  := PadR(aAux[2][4],TamSX3("E1_NUM")[1])
						cParcela := PadR(aAux[2][5],TamSX3("E1_PARCELA")[1])
						cTipoDoc := PadR(aAux[2][6],TamSX3("E1_TIPO")[1])

						cChaveTit := FWxFilial("SE1") + cPrefixo + cNumDoc + cParcela + cTipoDoc

						dbSelectArea( "SE1" )
						SE1->( dbSetOrder( 1 ) ) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

						If SE1->( ! msSeek( cChaveTit ) )
							lRet := .F.
							cXmlRet := STR0044 + AllTrim( cChaveTit ) //"O de/para do título a ser alterado foi encontrado, porém o registro de título no contas a receber não foi encontrado no Protheus. Verifique se o mesmo não foi excluído manualmente. Chave do título: "
							Return {lRet, _NoTags(cXmlRet)}
						Endif

					Else
						nOpcx := 3 // Insert

						//Prefixo
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentPrefix:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentPrefix:Text)
							cPrefixo := PadR(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentPrefix:Text, TamSX3("E1_PREFIXO")[1])
						ElseIf lHotel
							cPrefixo := SuperGetMV( "MV_HTLPREF", , "" ) //Prefixo para hotelaria
						ElseIf IsIntegTop() //Possui integração com o RM Solum
							cPrefixo := PadR(GetNewPar("MV_SLMPRER", ""), TamSX3("E1_PREFIXO")[1])
						EndIf

						// Verifica se não possui numeração automática.
						cRelacao := GetSX3Cache("E1_NUM", "X3_RELACAO")
						If !empty(cRelacao)
							cNumDoc := &cRelacao
						Endif

						If empty(cNumDoc)
							//Verifica se o Número do Título foi informado
							If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text)
								cNumDoc := AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text)
							Else
								lRet := .F.
								cXmlRet := STR0009 //"Informe o Número do Título"
								AdpLogEAI(5, "FINI040", cXMLRet, lRet)
								Return {lRet, _NoTags(cXmlRet)}
							EndIf
						Endif
						cNumDoc := PadR(cNumDoc, TamSX3("E1_NUM")[1])

						//Parcela
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentParcel:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentParcel:Text)
							cParcela := AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentParcel:Text)
						EndIf

						//Verifica se o Tipo do Título foi informado
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentTypeCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentTypeCode:Text)
							cTipoDoc := AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentTypeCode:Text)
						Else
							lRet := .F.
							cXmlRet := STR0010 //"Informe o Tipo do Título"
							AdpLogEAI(5, "FINI040", cXMLRet, lRet)
							Return {lRet, _NoTags(cXmlRet)}
						EndIf
					EndIf

					aAdd(aTit, {"E1_NUM",     PadR(cNumDoc, TamSX3("E1_NUM")[1]),      Nil})
					aAdd(aTit, {"E1_PREFIXO", cPrefixo,                                Nil})
					aAdd(aTit, {"E1_PARCELA", PadR(cParcela, TamSX3("E1_PARCELA")[1]), Nil})
					aAdd(aTit, {"E1_TIPO",    PadR(cTipoDoc, TamSX3("E1_TIPO")[1]),    Nil})

					// Verifica se Natureza foi informada
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialNatureInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialNatureInternalId:Text)
						cNatExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialNatureInternalId:Text
						aAux := F10GetInt(cNatExt, cMarca) //Adapter FINI010I

						If aAux[1]
							cNaturez := aAux[2][3]
							aAdd(aTit, {"E1_NATUREZ", PadR(cNaturez, TamSX3("E1_NATUREZ")[1]), Nil})
						Else
							lRet := .F.
							cXmlRet := STR0037 + " -> " + cNatExt //"Natureza não encontrada no de/para."
							AdpLogEAI(5, "FINI040", cXMLRet, lRet)
							Return {lRet, _NoTags(cXmlRet)}
						EndIf
					Else
						//Se for integração com hotelaria, pega a natureza do parâmetro
						If lHotel
							If AllTrim( cTipoDoc ) == "RA"
								cNaturez := SuperGetMV( "MV_HTLNARA", , "" ) //Natureza pra RA
							ElseIf AllTrim( cTipoDoc ) == "PR"
								cNaturez := SuperGetMV( "MV_HTLNAPR", , "" ) //Natureza pra PR
							ElseIf AllTrim( cTipoDoc ) == "CC"
								cNaturez := SuperGetMV( "MV_HTLNACC", , "" ) //Natureza pra CC
							ElseIf AllTrim( cTipoDoc ) == "CD"
								cNaturez := SuperGetMV( "MV_HTLNACD", , "" ) //Natureza pra CD
							ElseIf AllTrim( cTipoDoc ) == "NCC"
								cNaturez := SuperGetMV( "MV_HTLNANC", , "" ) //Natureza pra NCC
							ElseIf AllTrim( cTipoDoc ) == "R$"
								cNaturez := SuperGetMV( "MV_HTLNADH", , "" ) //Natureza pra R$
							Endif
						Else
							// Utiliza o parâmetro MV_SLMNATR criado para a integração Protheus x RM Solum para
							// as demais integrações quando o FinancialNatureInternalId não for informado
							cNaturez := RTrim(GetNewPar("MV_SLMNATR", ""))
						Endif

						If !Empty(cNaturez)
							aAdd(aTit, {"E1_NATUREZ", PadR(cNaturez, TamSX3("E1_NATUREZ")[1]), Nil})
						Else
							lRet := .F.
							If lHotel
								cXmlRet := STR0038 + "MV_HTLNARA | MV_HTLNAPR | MV_HTLNACC | MV_HTLNACD | MV_HTLNANC | MV_HTLNADH" //"Natureza não informada. Verifique os parâmetros: "
							Else
								cXmlRet := STR0039 //"Natureza não informada. Verifique o parâmetro MV_SLMNATR."
								AdpLogEAI(5, "FINI050", cXMLRet, lRet)
							Endif
							Return {lRet, _NoTags(cXmlRet)}
						EndIf

					EndIf

					//Obtém o Código Interno do Cliente
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerInternalId:Text)
						cCliVer := MsgUVer('MATA030', 'CUSTOMERVENDOR')
						aAux := IntCliInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerInternalId:Text, cMarca, cCliVer) //Adapter MATI030
						If !aAux[1]
							lRet := aAux[1]
							cXmlRet := aAux[2]
							AdpLogEAI(5, "FINI040", cXMLRet, lRet)
							Return {lRet, _NoTags(cXmlRet)}
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
					Else //Se já for o código Protheus do Cliente (tags CustomerCode e StoreId)
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text)
							cCliente := AllTrim( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text )
							aAdd(aTit, {"E1_CLIENTE", PadR(cCliente, TamSX3("E1_CLIENTE")[1]), Nil})
						EndIf
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_StoreId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_StoreId:Text)
							cLoja := AllTrim( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_StoreId:Text )
							aAdd(aTit, {"E1_LOJA", PadR(cLoja, TamSX3("E1_LOJA")[1]), Nil})
						EndIf
					EndIf

					If Empty( cCliente ) .OR. Empty ( cLoja )
						lRet := .F.
						cXmlRet := STR0043 //"Código de cliente não informado."
						AdpLogEAI(5, "FINI040", cXMLRet, lRet)
						Return {lRet, _NoTags(cXmlRet)}
					Endif

					//Verifica se a data de emissão do título foi informada
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_IssueDate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_IssueDate:Text)
						aAdd(aTit, {"E1_EMISSAO", SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_IssueDate:Text,"-","")), Nil})
					Else
						lRet := .F.
						cXmlRet := STR0014 //"Informe a data de emissão do título."
						AdpLogEAI(5, "FINI040", cXMLRet, lRet)
						Return {lRet, _NoTags(cXmlRet)}
					EndIf

					//Verifica se o Vencimento do Título foi informado
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DueDate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DueDate:Text)
						aAdd(aTit, {"E1_VENCTO", SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DueDate:Text,"-","")), Nil})
						aAdd(aTit, {"E1_VENCREA", SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DueDate:Text,"-","")), Nil})
					Else
						lRet := .F.
						cXmlRet := STR0015 //"Informe o Vencimento do Título"
						AdpLogEAI(5, "FINI040", cXMLRet, lRet)
						Return {lRet, _NoTags(cXmlRet)}
					EndIf

					// Verifica se o Valor do Título foi informado
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text)
						nValTit := Val(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text,",","."))
						aAdd(aTit, {"E1_VALOR", nValTit, Nil})
						aAdd(aTit, {"E1_VLCRUZ", nValTit, Nil})
					Else
						lRet := .F.
						cXmlRet := STR0016 //"Informe o Valor do Título"
						AdpLogEAI(5, "FINI040", cXMLRet, lRet)
						Return {lRet, _NoTags(cXmlRet)}
					EndIf

					// Desconto financeiro (%)
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DiscountPercentage:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DiscountPercentage:Text)
						aAdd(aTit, {"E1_DESCFIN", Val(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DiscountPercentage:Text,",",".")), Nil})
					EndIf

					// Histórico
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Observation:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Observation:Text)
						aAdd(aTit, {"E1_HIST", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Observation:Text, NIL})
					Endif

					// Origem
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Origin:Text)
						aAdd(aTit, {"E1_ORIGEM", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Origin:Text, Nil})
					Else
						aAdd(aTit, {"E1_ORIGEM", "FINI040", Nil})
					EndIf

					// Moeda
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyInternalId:Text)
						cMoeVer := MsgUVer('CTBA140', 'CURRENCY')
						aAux := IntMoeInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyInternalId:Text, cMarca, cMoeVer) //Adapter CTBI140
						If !aAux[1]
							lRet := aAux[1]
							cXmlRet := aAux[2]
							AdpLogEAI(5, "FINI040", cXMLRet, lRet)
							Return {lRet, _NoTags(cXmlRet)}
						Else
							If cMoeVer = "1."
								aAdd(aTit, {"E1_MOEDA", Val(aAux[2][2]), Nil})
							Else
								aAdd(aTit, {"E1_MOEDA", Val(aAux[2][3]), Nil})
							Endif
						EndIf
					Else
						aAdd(aTit, {"E1_MOEDA", 1, Nil})
					EndIf

					//Caso a tag HolderCode venha preenchida, alimento os dados do portador, agencia e conta com base nesses dados
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_HolderCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_HolderCode:Text)
						aAdd(aTit, {"E1_PORTADO", PadR(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_HolderCode:Text,TamSX3("E1_PORTADO")[1]), Nil})
					EndIf

					//Valor Real do Título
					If( XmlChildEx( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_REALVALUE" ) <> Nil )
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RealValue:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RealValue:Text)
							aAdd(aTit, {"E1_VLRREAL", Val(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RealValue:Text,",",".")), NIL})
						Endif
					Endif

					//Número NSU (transação com cartão)
					If( XmlChildEx( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_UNIQUESERIALNUMBER" ) <> Nil )
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UniqueSerialNumber:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UniqueSerialNumber:Text)
							aAdd(aTit, {"E1_NSUTEF", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UniqueSerialNumber:Text, NIL})
						Endif
					Endif

					//Possui rateio
					If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ApportionmentDistribution:_Apportionment") != "U"
						//Se não for Array
						If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ApportionmentDistribution:_Apportionment") != "A"
							//Transforma em array
							XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ApportionmentDistribution:_Apportionment,"_Apportionment")
						EndIf

						For nI := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ApportionmentDistribution:_Apportionment)
							// Atualiza o objeto com a posição atual
							oXmlAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ApportionmentDistribution:_Apportionment[nI]
							// Se possui projeto informado
							If Type("oXmlAux:_ProjectInternalId:Text") != "U" .And. !Empty(oXmlAux:_ProjectInternalId:Text)
								// Verifica se o código do projeto é válido
								aAux := IntPrjInt(oXmlAux:_ProjectInternalId:Text, cMarca) //Empresa/Filial/Projeto
								If !aAux[1]
									lRet := .F.
									cXmlRet := aAux[2] + " Título " + cNumDoc //" Título "
									AdpLogEAI(5, "FINI040", cXMLRet, lRet)
									Return {lRet, _NoTags(cXmlRet)}
								Else
									xAux := aAux[2][3]
								EndIf

								If Type("oXmlAux:_TaskInternalId:Text") != "U" .And. !Empty(oXmlAux:_TaskInternalId:Text)
									aAux := IntTrfInt(oXmlAux:_TaskInternalId:Text, cMarca) //Empresa/Filial/Projeto/Revisao/Tarefa
									If !aAux[1]
										lRet := .F.
										cXmlRet := aAux[2] + " Título " + cNumDoc //" Título "
										AdpLogEAI(5, "FINI040", cXMLRet, lRet)
										Return {lRet, _NoTags(cXmlRet)}
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
										cXmlRet := STR0040 //"Não existe Tarefa para o Projeto informado."
										AdpLogEAI(5, "FINI040", cXMLRet, lRet)
										Return {lRet, _NoTags(cXmlRet)}
									EndIf
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
									cXmlRet := STR0041 + cNumDoc //"Valor do rateio inválido para o título "
									AdpLogEAI(5, "FINI040", cXMLRet, lRet)
									Return {lRet, _NoTags(cXmlRet)}
								EndIf
							EndIf
						Next nI
					EndIf

					//Código da Agência
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgencyNumber:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgencyNumber:Text)
						aAdd(aTit, {"E1_AGEDEP", PadR(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgencyNumber:Text,TamSX3("E1_AGEDEP")[1]), NIL})
					Endif

					//Número da Conta
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AccountNumber:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AccountNumber:Text)
						aAdd(aTit, {"E1_CONTA", PadR(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AccountNumber:Text,TamSX3("E1_CONTA")[1]), NIL})
					Endif

					//Nosso Número
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OurNumberBanking:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OurNumberBanking:Text)
						aAdd(aTit, {"E1_NUMBCO", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OurNumberBanking:Text, NIL})
					Endif

					//Código de Barra
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Barcode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Barcode:Text)
						aAdd(aTit, {"E1_CODBAR", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Barcode:Text, NIL})
					Endif

					//Nr. Contrato
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ContractNumber:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ContractNumber:Text)
						aAdd(aTit, {"E1_CONTRAT", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ContractNumber:Text, NIL})
					Endif

					//Percentual de Juros Diária
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InterestPercentage:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InterestPercentage:Text)
						aAdd(aTit, {"E1_PORCJUR", Val(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InterestPercentage:Text,",",".")), NIL})
					EndIf

					//Valor de Multa Diária (Taxa de Permanência)
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AssessmentValue:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AssessmentValue:Text)
						aAdd(aTit, {"E1_VALJUR", Val(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AssessmentValue:Text,",",".")), NIL})
					EndIf

				//Valor de desconto de bolsa (educacional)
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UnconditionalScholarshipValue:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UnconditionalScholarshipValue:Text)
					aAdd(aTit, {"E1_VLBOLSA", Val(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UnconditionalScholarshipValue:Text,",",".")), NIL})
				EndIf

					If lFKD
						//////////////////////
						//VALORES ACESSORIOS//
						//////////////////////
						If(Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues") == "O")
							If(Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue") == "A")
								For nLaco := 1 to Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue)
									If(Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue[" + cValtoChar(nLaco) + "]") != "U")
										If(Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue[" + cValToChar(nLaco) + "]:_ComplementaryValueInternalId:Text") != "U" .And. ! Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue[nLaco]:_ComplementaryValueInternalId:Text))
											cInternoId := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue[nLaco]:_ComplementaryValueInternalId:Text
											aAuxVA := F035GETINT(cInternoId,cMarca)
											If(aAuxVa[1])
												If(Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue["+ cValToChar(nLaco) +"]:_InformedValue:Text") != "U" .And. ! Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue[nLaco]:_InformedValue:Text))
													//adicionar em modo vetor
													cCodVA := aAuxVa[2,3]
													nValAcess := Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue[nLaco]:_InformedValue:Text)
													If nValAcess != 0
														aAdd(aValAce, {cCodVA, nValAcess})
													EndIf
												EndIf
											Else
												lRet := .F.
												cXmlRet := STR0042 +' '+ cInternoId //"Erro ao encontrar o valor acessorio"
												Exit
											EndIf
										EndIf
									EndIf
								Next nLaco
							ElseIf(Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue") == "O")
								If(Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue:_ComplementaryValueInternalId:Text") != "U" .And.;
								! Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue:_ComplementaryValueInternalId:Text))
									cInternoId := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue:_ComplementaryValueInternalId:Text
									aAuxVA := F035GETINT(cInternoId,cMarca)
									If(aAuxVa[1])
										If(Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue:_InformedValue:Text") != "U" .And.;
										! Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue:_InformedValue:Text))
											//adicionar em modo vetor
											cCodVA := aAuxVa[2,3]
											nValAcess := Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue:_InformedValue:Text)
											If nValAcess != 0
												aAdd(aValAce, {cCodVA, nValAcess})
											EndIf
										EndIf
									Else
										lRet := .F.
										cXmlRet := STR0042 + cInternoId //"Erro ao encontrar o valor acessorio"
									EndIf
								EndIf
							EndIf
						EndIf
					Endif

					If XmlChildEx( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_OTHER" ) <> Nil

						//Registro Acadêmico do Aluno
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_AcademicRecord:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_AcademicRecord:Text)
							aAdd(aTit, {"E1_NUMRA", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_AcademicRecord:Text, NIL})
						EndIf

						//Período Letivo
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_AcademicPeriod:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_AcademicPeriod:Text)
							aAdd(aTit, {"E1_PERLET", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_AcademicPeriod:Text, NIL})
						EndIf

						//Matriz Aplicada
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_AppliedMatrix:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_AppliedMatrix:Text)
							aAdd(aTit, {"E1_IDAPLIC", Val(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_AppliedMatrix:Text,",",".")), NIL})
						EndIf

						//Identificador Interno do Produto
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_ItemInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_ItemInternalId:Text)
							cCodProd := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_ItemInternalId:Text

							aAuxRet := IntProInt(cCodProd, cMarca, /*Versão*/)

							If aAuxRet[1]
								aAdd(aTit, { "E1_PRODUTO", aAuxRet[2][3] , NIL})
							EndIf
						EndIf

						//Turma (Classe)
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_Class:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_Class:Text)
							aAdd(aTit, {"E1_TURMA", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_Class:Text, NIL})
						EndIf

						//Tag com o número de conta hoteleira a qual o título estará associado
						If( XmlChildEx( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other, "_HOTELACCOUNTCODE" ) <> Nil )
							If Type( "oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_HotelAccountCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_HotelAccountCode:Text )
								aAdd( aTit, {"E1_CONHTL", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_HotelAccountCode:Text, NIL} )
							EndIf
						Endif

						//Tag com o tipo de conta hoteleira a qual o título estará associado (1=Evento; 2=Grupo; 3=Individual; 4=Avulsa)
						If( XmlChildEx( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other, "_HOTELACCOUNTTYPE" ) <> Nil )
							If Type( "oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_HotelAccountType:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_HotelAccountType:Text )
								aAdd( aTit, {"E1_TCONHTL", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_HotelAccountType:Text, NIL} )
							EndIf
						Endif

					EndIf

					//Código da Conta Contábil - Débito
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingCodeDebit:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingCodeDebit:Text)
						cContaD := CFGA070INT( cMarca, "CT1", "CT1_CONTA", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingCodeDebit:Text)
						If !Empty(cContaD)
							aAdd(aTit, {"E1_DEBITO", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingCodeDebit:Text, NIL})
						EndIf
					EndIf

					//Código da Conta Contábil - Crédito
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingCodeCredit:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingCodeCredit:Text)
						cContaC := CFGA070INT( cMarca, "CT1", "CT1_CONTA", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingCodeCredit:Text)
						If !Empty(cContaC)
							aAdd(aTit, {"E1_CREDIT", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingCodeCredit:Text, NIL})
						EndIf
					EndIf

					//Código do Centro de Custo - Débito
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_CostCenterDebit:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_CostCenterDebit:Text)
						aAuxRet := IntCusInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_CostCenterDebit:Text,cMarca)
						If !aAuxRet[1]
							lRet := aAuxRet[1]
							cXmlRet := STR0035 //"Centro de custo não encontrado no De/Para"
							AdpLogEAI(5, "FINI040", cXmlRet, lRet)
							Return {lRet, _NoTags(cXmlRet)}
						Else
							aAdd(aTit, {"E1_CCD", aAuxRet[2][3], NIL})
						EndIf
					EndIf

					//Código do Centro de Custo - Crédito
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_CostCenterCredit:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_CostCenterCredit:Text)
						aAuxRet := IntCusInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_CostCenterCredit:Text,cMarca)
						If !aAuxRet[1]
							lRet := aAuxRet[1]
							cXmlRet := STR0035 //"Centro de custo não encontrado no De/Para"
							AdpLogEAI(5, "FINI040", cXmlRet, lRet)
							Return {lRet, _NoTags(cXmlRet)}
						Else
							aAdd(aTit, {"E1_CCC", aAuxRet[2][3], NIL})
						EndIf
					EndIf

					//Código do Item Contábil - Débito
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_DepartamentDebit:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_DepartamentDebit:Text)
						aItemCtb := C040GetInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_DepartamentDebit:Text,cMarca)
						If aItemCtb[1]
							aAdd(aTit, {"E1_ITEMD",aItemCtb[2][3], Nil})
						EndIf
					EndIf

					//Código do Item Contábil - Crédito
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_DepartamentCredit:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_DepartamentCredit:Text)
						aItemCtb := C040GetInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_DepartamentCredit:Text,cMarca)
						If aItemCtb[1]
							aAdd(aTit, {"E1_ITEMC",aItemCtb[2][3], Nil})
						EndIf
					EndIf

					//Código da Classe de Valor - Débito
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_ClassValueDebit:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_ClassValueDebit:Text)
						aAuxRet := C060GetInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_ClassValueDebit:Text,cMarca) //Adapter CTBI060
						If !aAuxRet[1]
							lRet := aAux[1]
							cXmlRet := STR0036 //"Classe de valor não encontrada no De/Para"
							AdpLogEAI(5, "FINI040", cXMLRet, lRet)
							Return {lRet, _NoTags(cXmlRet)}
						Else
							aAdd(aTit, {"E1_CLVLDB", aAuxRet[2][3], Nil})
						EndIf
					EndIf

					//Código da Classe de Valor - Crédito
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_ClassValueCredit:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_ClassValueCredit:Text)
						aAuxRet := C060GetInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_ClassValueCredit:Text,cMarca) //Adapter CTBI060
						If !aAuxRet[1]
							lRet := aAux[1]
							cXmlRet := STR0036 //"Classe de valor não encontrada no De/Para"
							AdpLogEAI(5, "FINI040", cXMLRet, lRet)
							Return {lRet, _NoTags(cXmlRet)}
						Else
							aAdd(aTit, {"E1_CLVLCR",aAuxRet[2][3], Nil})
						EndIf
					EndIf

					//Tratamento específico para integração com RM Classis
					If Upper(AllTrim(cMarca)) == "RM"
						aAdd(aTit, {"E1_IDLAN", 1, Nil})
					EndIf

					//Rateio por natureza e centro de custos
					If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment") != "U"
						//Se não for Array
						If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment") != "A"
							//Transforma em array
							XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment,"_FinancialNatureApportionment")
						EndIf

						lRatNat := .T.
						aAdd( aTit, { "E1_MULTNAT", "1", Nil } ) //Rateio multinaturezs = sim

						For nI := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment)
							//Atualiza o objeto com a posição atual
							oXmlAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI]

							//Código da Natureza
							If Type("oXmlAux:_FinancialNatureInternalId:Text") != "U" .And. !Empty(oXmlAux:_FinancialNatureInternalId:Text)
								//Fazer de/para
							Else
								//Natureza definida no parâmetro MV_HTLNART
								aAdd( aNat, { "EV_NATUREZ", PADR( cNaturez, TamSx3("EV_NATUREZ")[1] ), Nil } )
							EndIf

							//Valor distribuido para a natureza em questão
							If Type("oXmlAux:_Value:Text") != "U" .And. !Empty(oXmlAux:_Value:Text)
								aAdd( aNat, { "EV_VALOR", Val( oXmlAux:_Value:Text ), Nil } )
							Else
								If lHotel //Remover esse tratamento após tratar a execauto para calcular EV com base no percentual e vice-versa (assim como já foi feito na SEZ)
									aAdd( aNat, { "EV_VALOR", nValTit, Nil } )
								Else
									aAdd( aNat, { "EV_VALOR", 0, Nil } )
								Endif
							EndIf

							//Percentual distribuido para a natureza em questão
							If Type("oXmlAux:_Percentage:Text") != "U" .And. !Empty(oXmlAux:_Percentage:Text)
								aAdd( aNat, { "EV_PERC", Val( oXmlAux:_Percentage:Text ), Nil } )
							Else
								aAdd( aNat, { "EV_PERC", 0, Nil } )
							EndIf

							//Rateio por centro de custos
							If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[" + cValToChar(nI) + "]:_ListOfCostCenterApportionment:_CostCenterApportionment") != "U"
								//Se não for Array
								If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[" + cValToChar(nI) + "]:_ListOfCostCenterApportionment:_CostCenterApportionment") != "A"
									//Transforma em array
									XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI]:_ListOfCostCenterApportionment:_CostCenterApportionment,"_CostCenterApportionment")
								EndIf

								aAdd( aNat, { "EV_RATEICC", "1", Nil } ) //indica que há rateio por centro de custo

								For nJ := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI]:_ListOfCostCenterApportionment:_CostCenterApportionment)
									//Atualiza o objeto com a posição atual
									oXmlAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI]:_ListOfCostCenterApportionment:_CostCenterApportionment[nJ]

									//Código do Centro de custos
									If Type("oXmlAux:_CostCenterInternalId:Text") != "U" .And. !Empty(oXmlAux:_CostCenterInternalId:Text)
										//Fazer de/para
									Else
										//Centro de Custo definido no parâmetro MV_HTLCCRT
										aAdd( aAuxSEZ, { "EZ_CCUSTO", cCustRat, Nil } )
									EndIf

									//Entidade adicional (05, 06, 07, 08 ou 09) - Código da conta
									If Type("oXmlAux:_GenericEntityInternalId:Text") != "U" .And. !Empty(oXmlAux:_GenericEntityInternalId:Text)

										//Obtém o valor interno da tabela XXF (de/para)
										aAuxEnt := IntGerInt( oXmlAux:_GenericEntityInternalId:Text, cMarca, "1.000")
										If aAuxEnt[1]
											aAdd( aAuxSEZ, { "EZ_EC05DB", aAuxEnt[2][4], Nil } )
										Endif

									Else
										aAdd( aAuxSEZ, Nil )
									EndIf

									//Valor distribuido para o centro de custo em questão
									If Type("oXmlAux:_Value:Text") != "U" .And. !Empty(oXmlAux:_Value:Text)
										aAdd( aAuxSEZ, { "EZ_VALOR", Val( oXmlAux:_Value:Text ), Nil } )
									Else
										aAdd( aAuxSEZ, { "EZ_VALOR", 0, Nil } )
									EndIf

									//Percentual distribuido para o centro de custo em questão
									If Type("oXmlAux:_Percentage:Text") != "U" .And. !Empty(oXmlAux:_Percentage:Text)
										aAdd( aAuxSEZ, { "EZ_PERC", Val( oXmlAux:_Percentage:Text ), Nil } )
									Else
										aAdd( aAuxSEZ, { "EZ_PERC", 0, Nil } )
									EndIf

									aAdd( aNatCC, aClone( aAuxSEZ ) )
									aSize ( aAuxSEZ, 0 )
								Next nJ
							Endif

							aAdd( aNat, { "AUTRATEICC", aClone( aNatCC ), Nil } ) //Adiciona o array de multiplos centros de custos no array da natureza
							aSize ( aNatCC, 0 )

							aAdd( aRatNat, aClone( aNat ) ) //Adiciona o array de natureza no array de rateio por multiplas naturezas
							aSize ( aNat, 0 )
						Next nI
					EndIf

				ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"

					//Data de Exclusão
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DeletionDate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DeletionDate:Text)
						dDataDel := SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DeletionDate:Text ,"-",""))
						If !Empty(dDataDel)
							dDataBase:= dDataDel
						Endif
					EndIf
					// Se o registro existe
					If aAux[1]
						nOpcx := 5 // Delete

						cPrefixo := PadR(aAux[2][3] , TamSX3("E1_PREFIXO")[1]) //  aAux[2][3]
						cNumDoc  := PadR(aAux[2][4] , TamSX3("E1_NUM")    [1]) //  aAux[2][4]
						cParcela := PadR(aAux[2][5] , TamSX3("E1_PARCELA")[1]) //  aAux[2][5]
						cTipoDoc := PadR(aAux[2][6] , TamSX3("E1_TIPO")   [1]) //aAux[2][6]

						dbSelectArea("SE1")
						SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

						If SE1->(dbSeek(xFilial("SE1") + cPrefixo + cNumDoc + cParcela + cTipoDoc))
							cCliente := SE1->E1_CLIENTE
							cLoja    := SE1->E1_LOJA
						Else
							cCliente := ""
							cLoja    := ""
						EndIf

						aAdd(aTit, {"E1_PREFIXO", PadR(cPrefixo, TamSX3("E1_PREFIXO")[1]), Nil})
						aAdd(aTit, {"E1_NUM",     PadR(cNumDoc,  TamSX3("E1_NUM")[1]),     Nil})
						aAdd(aTit, {"E1_PARCELA", PadR(cParcela, TamSX3("E1_PARCELA")[1]), Nil})
						aAdd(aTit, {"E1_TIPO",    PadR(cTipoDoc, TamSX3("E1_TIPO")[1]),    Nil})

						//Rateio
						aAdd(aRatAux, {"AFT_PREFIX", PadR(cPrefixo, TamSX3("AFT_PREFIX")[1]), Nil})
						aAdd(aRatAux, {"AFT_NUM",    PadR(cNumDoc,  TamSX3("AFT_NUM")[1]),    Nil})
						aAdd(aRatAux, {"AFT_PARCEL", PadR(cParcela, TamSX3("AFT_PARCEL")[1]), Nil})
						aAdd(aRatAux, {"AFT_TIPO",   PadR(cTipoDoc, TamSX3("AFT_TIPO")[1]),   Nil})
						aAdd(aRatAux, {"AFT_CLIENT", PadR(cCliente, TamSX3("AFT_CLIENT")[1]), Nil})
						aAdd(aRatAux, {"AFT_LOJA",   PadR(cLoja,    TamSX3("AFT_LOJA")[1]),   Nil})
						aAdd(aRatPrj, aRatAux)
						aRatAux := {}

						//De/Para do rateio
						aRatAux := RatCAR(SE1->E1_FILIAL + cPrefixo + cNumDoc + cParcela + cTipoDoc + cCliente + cLoja)

						for nI := 1 To Len(aRatAux)
							cValIntRat := IntTRcExt(, , cPrefixo, cNumDoc, cParcela, cTipoDoc)[2] + "|" + AllTrim(cCliente) + "|" + AllTrim(cLoja) + "|" + AllTrim(aRatAux[nI][6]) + "|" + StrZero(1, TamSX3("AFT_REVISA")[1]) + "|" + AllTrim(aRatAux[nI][7])
							cValExtRat := AllTrim(CFGA070Ext(cMarca, "AFT", "AFT_TAREFA", cValIntRat))

							aAdd(aIntPrj, {"AFT", "AFT_TAREFA", cValIntRat, cValExtRat})
						Next nI
					Else
						lRet := .F.
						dDataBase := dDataAux
						cXmlRet := STR0017 //"O Título a ser excluído não foi encontrado na base Protheus"
						Return {lRet, _NoTags(cXmlRet)}
					EndIf
				Else
					lRet := .F.
					dDataBase := dDataAux
					cXmlRet := STR0018 //"O evento informado é inválido"
					Return {lRet, _NoTags(cXmlRet)}
				EndIf

				If lRet
					cValInt := IntTRcExt(, , cPrefixo, cNumDoc, cParcela, cTipoDoc)[2]

					// Ponto de Entrada para tratamento do Array de campos enviado na MSExecAuto
					If lFI040SE1
						aAuxInc := ExecBlock("FI040SE1",.F.,.F.,{aTit,nOpcx})
						If ValType(aAuxInc) == "A" .And. Len(aAuxInc) > 0
							aTit := aClone(aAuxInc)
						EndIf
					EndIf

					AdpLogEAI(3, "aTit: ", aTit)
					AdpLogEAI(3, "cValInt: ", cValInt)
					AdpLogEAI(3, "cValExt: ", cValExt)
					AdpLogEAI(3, "aRatPrj: ", aRatPrj)
					AdpLogEAI(3, "aIntPrj: ", aIntPrj)
					AdpLogEAI(4, nOpcx)

					BEGIN TRANSACTION

						MSExecAuto({|a, b, c, d| FINA040(a, b,, c,,,, d)}, aTit, nOpcx, If(lRatNat, aRatNat, nil), If(lFKD, aValAce, nil))

						// Se houve erros no processamento do MSExecAuto
						If lMsErroAuto
							aErroAuto := GetAutoGRLog()

							cXMLRet := "<![CDATA["
							For nI := 1 To Len(aErroAuto)
								cXMLRet += aErroAuto[nI] + Chr(10)
							Next nI
							cXMLRet += "]]>"

							lRet := .F.

							DisarmTransaction()
							MsUnLockAll()
						Else
							//Grava o rateio de projeto fora da rotina automatica
							//A pedido da equipe de Controladoria
							If Len(aRatPrj) > 0
								pmsWsCR(cValToChar(nOpcx) ,aRatPrj)
							EndIf

							If nOpcx != 5 // Se o evento é diferente de delete
								// Grava o registro na tabela XXF (de/para)
								CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F., 1)

								//De/Para do rateio
								For nI := 1 To Len(aIntPrj)
									CFGA070Mnt(cMarca, aIntPrj[nI][1], aIntPrj[nI][2], aIntPrj[nI][4], aIntPrj[nI][3], .F., 1)
								Next nI

								// Monta o XML de retorno
								cXMLRet := "<ListOfInternalId>"
								cXMLRet +=    "<InternalId>"
								cXMLRet +=       "<Name>" + cMessage + "</Name>"
								cXMLRet +=       "<Origin>" + cValExt + "</Origin>"
								cXmlRet +=       "<Destination>" + cValInt + "</Destination>"
								cXMLRet +=    "</InternalId>"
								For nI := 1 To Len(aIntPrj)
									cXMLRet += "<InternalId>"
									cXMLRet +=    "<Name>ApportionmentInternalId</Name>"
									cXMLRet +=    "<Origin>" + aIntPrj[nI][4] + "</Origin>"
									cXmlRet +=    "<Destination>" + aIntPrj[nI][3] + "</Destination>"
									cXMLRet += "</InternalId>"
								Next nI
								cXMLRet += "</ListOfInternalId>"
							Else
								// Exclui o registro na tabela XXF (de/para)
								CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .T., 1)

								//De/Para do rateio
								For nI := 1 To Len(aIntPrj)
									CFGA070Mnt(cMarca, aIntPrj[nI][1], aIntPrj[nI][2], aIntPrj[nI][4], aIntPrj[nI][3], .T., 1)
								Next nI
							EndIf
						Endif

					END TRANSACTION

					aSize( aRatNat, 0 )
					aRatNat := Nil
					aSize( aNat, 0 )
					aNat := Nil
					aSize( aNatCC, 0 )
					aNatCC := Nil
					aSize( aAuxSEZ, 0 )
					aAuxSEZ := Nil
					aSize( aAuxEnt, 0 )
					aAuxEnt := Nil
				Endif
			Else
				lRet    := .F.
				cXmlRet := STR0019 //"Erro no parser!"
				Return {lRet, _NoTags(cXmlRet)}
			EndIf
		ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE
			//Faz o parser do XML de retorno em um objeto
			oXML := xmlParser(cXML, "_", @cError, @cWarning)

			//Se não houve erros na resposta
			If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"

				//Verifica se a marca foi informada
				If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
					cMarca := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					lRet := .F.
					cXmlRet := STR0020 //"Erro no retorno. O Product é obrigatório!"
					Return {lRet, _NoTags(cXmlRet)}
				EndIf

				//Se não for array
				If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") != "A"
					// Transforma em array
					XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, "_InternalId")
				EndIf

				For nI := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId)
					cValInt := ""
					cValExt := ""

					//Verifica se o InternalId foi informado
					If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[" + Str(nI) + "]:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Origin:Text)
						cValInt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Origin:Text
					Else
						lRet := .F.
						cXmlRet := STR0021 //"Erro no retorno. O OriginalInternalId é obrigatório!"
						AdpLogEAI(5, "FINI040", cXMLRet, lRet)
						Return {lRet, _NoTags(cXmlRet)}
					EndIf

					//Verifica se o código externo foi informado
					If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[" + Str(nI) + "]:_Destination:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Destination:Text)
						cValExt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Destination:Text
					Else
						lRet := .F.
						cXmlRet := STR0022 //"Erro no retorno. O DestinationInternalId é obrigatório!"
						AdpLogEAI(5, "FINI040", cXMLRet, lRet)
						Return {lRet, _NoTags(cXmlRet)}
					EndIf

					CFGA070Mnt( cMarca, cAlias, cField, cValExt, cValInt, .F., 1 )

					// Envia os valores de InternalId e ExternalId para o Log
					AdpLogEAI(3, "cValInt" + Str(nI) + ": ", cValInt) // InternalId
					AdpLogEAI(3, "cValExt" + Str(nI) + ": ", cValExt) // ExternalId
				Next nI

			Else
				//Se não for array
				If Type("oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
					//Transforma em array
					XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
				EndIf

				//Percorre o array para obter os erros gerados
				For nI := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
					cError := oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nI]:Text + Chr(10)
				Next nI

				lRet := .F.
				cXmlRet := cError
			EndIf
		EndIf

		If __lMetric
			// Metrica de integrações com outros produtos
    		FwCustomMetrics():setSumMetric("Marca_"+Alltrim(cMarca), "financeiro-protheus_qtd-clientes-eai-com-financeiro_total", 1)
		Endif

		//Mensagem de saída
	ElseIf cTypeTrans == TRANS_SEND

		cValInt := IntTRcExt(, SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)[2]

		// Verica operação realizada
		If Inclui
			AdpLogEAI(4, 3)
		ElseIf Altera
			AdpLogEAI(4, 4)
		Else
			AdpLogEAI(4, 5)
		EndIf

		If !Inclui .And. !Altera
			cEvent := 'delete'
			CFGA070Mnt(, cAlias, cField,, cValInt, .T.) // excluindo da XXF
		EndIf

		cXMLRet := '<BusinessEvent>'
		cXMLRet +=  '<Entity>' + cMessage + '</Entity>'
		cXMLRet +=  '<Event>' + cEvent + '</Event>'
		cXMLRet +=  '<Identification>'
		cXMLRet +=   '<key name="InternalId">' + cValInt + '</key>'
		cXMLRet +=  '</Identification>'
		cXMLRet += '</BusinessEvent>'
		cXMLRet += '<BusinessContent>'
		cXMLRet +=  '<InternalId>' + cValInt + '</InternalId>'
		cXMLRet +=  '<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet +=  '<BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet +=  '<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		cXMLRet +=  '<DocumentPrefix>' + RTrim(SE1->E1_PREFIXO) + '</DocumentPrefix>'
		cXMLRet +=  '<DocumentNumber>' + RTrim(SE1->E1_NUM) + '</DocumentNumber>'
		cXMLRet +=  '<DocumentParcel>' + RTrim(SE1->E1_PARCELA) + '</DocumentParcel>'
		cXMLRet +=  '<DocumentTypeCode>' + RTrim(SE1->E1_TIPO) + '</DocumentTypeCode>'
		cXMLRet +=  '<ListOfSourceDocument/>'
		cXMLRet +=  '<IssueDate>' + Transform(DToS(SE1->E1_EMISSAO), "@R 9999-99-99") + '</IssueDate>'
		cXMLRet +=  '<DueDate>' + Transform(DToS(SE1->E1_VENCTO), "@R 9999-99-99") + '</DueDate>'
		cXMLRet +=  '<RealDueDate>' + Transform(DTOS(SE1->E1_VENCREA),"@R 9999-99-99") + '</RealDueDate>'
		If Empty(SE1->E1_CLIENTE)
			cXMLRet +=  '<CustomerCode/>'
			cXmlRet +=  '<StoreId/>'
			cXmlRet +=  '<CustomerInternalId/>'
		Else
			cXMLRet +=  '<CustomerCode>' + RTrim(SE1->E1_CLIENTE) + '</CustomerCode>'
			cXmlRet +=  '<StoreId>' + RTrim(SE1->E1_LOJA) + '</StoreId>'
			cXmlRet +=  '<CustomerInternalId>' + IntCliExt(, , SE1->E1_CLIENTE, SE1->E1_LOJA, MsgUVer('MATA030', 'CUSTOMERVENDOR'))[2] + '</CustomerInternalId>' //Adapter MATI030
		EndIf
		cXMLRet +=  '<NetValue>' + AllTrim(CValToChar(SE1->E1_VALOR)) + '</NetValue>'
		cXMLRet +=  '<GrossValue>' + AllTrim(CValToChar(SE1->E1_VALOR)) + '</GrossValue>'
		If Empty(SE1->E1_MOEDA)
			cXMLRet +=  '<CurrencyCode/>'
			cXmlRet +=  '<CurrencyInternalId/>'
		Else
			cXMLRet +=  '<CurrencyCode>' + PadL(SE1->E1_MOEDA, 2, '0') +'</CurrencyCode>'
			cXmlRet +=  '<CurrencyInternalId>' + IntMoeExt(, , PadL(SE1->E1_MOEDA, 2, '0'), MsgUVer('CTBA140', 'CURRENCY'))[2] + '</CurrencyInternalId>' //Adapter CTBI140
		EndIf
		cXMLRet +=  '<CurrencyRate>' + cValToChar(SE1->E1_TXMOEDA) + '</CurrencyRate>'
		If Empty(SE1->E1_NATUREZ)
			cXmlRet +=  '<FinancialNatureInternalId/>'
		Else
			cXmlRet +=  '<FinancialNatureInternalId>' + F10MontInt(, SE1->E1_NATUREZ) + '</FinancialNatureInternalId>' //Adapter FINI010I
		EndIf
		//Accounting
		cXMLRet +=  '<Accounting>'
		cXMLRet +=   '<AccountingCodeDebit>' + AllTrim(SE1->E1_DEBITO) + '</AccountingCodeDebit>'
		cXMLRet +=   '<AccountingCodeCredit>' + AllTrim(SE1->E1_CREDIT) + '</AccountingCodeCredit>'
		cXMLRet +=   '<CostCenterDebit>' + AllTrim(SE1->E1_CCD) + '</CostCenterDebit>'
		cXMLRet +=   '<CostCenterCredit>' + AllTrim(SE1->E1_CCC) + '</CostCenterCredit>'
		cXMLRet +=   '<DepartamentDebit>' + AllTrim(SE1->E1_ITEMD) + '</DepartamentDebit>'
		cXMLRet +=   '<DepartamentCredit>' + AllTrim(SE1->E1_ITEMC) + '</DepartamentCredit>'
		cXMLRet +=   '<ClassValueDebit>' + AllTrim(SE1->E1_CLVLDB) + '</ClassValueDebit>'
		cXMLRet +=   '<ClassValueCredit>' + AllTrim(SE1->E1_CLVLCR) + '</ClassValueCredit>'
		cXMLRet +=  '</Accounting>'

		//Other
		cXMLRet +=  '<Other>'
		cXMLRet +=   '<AcademicRecord>' + AllTrim(SE1->E1_NUMRA) + '</AcademicRecord>'
		cXMLRet +=   '<AcademicPeriod>' + AllTrim(SE1->E1_PERLET) + '</AcademicPeriod>'
		cXMLRet +=   '<AppliedMatrix>' + AllTrim(Str(SE1->E1_IDAPLIC)) + '</AppliedMatrix>'
		cXMLRet +=   '<ItemInternalId>' + AllTrim(SE1->E1_PRODUTO) + '</ItemInternalId>'
		cXMLRet +=   '<Class>' + AllTrim(SE1->E1_TURMA) + '</Class>'
		If lCposVA .And. lV2005
			cXMLRet +=   '<HotelAccountCode>' + AllTrim(SE1->E1_CONHTL) + '</HotelAccountCode>'
			cXMLRet +=   '<HotelAccountType>' + AllTrim(SE1->E1_TCONHTL) + '</HotelAccountType>'
		EndIf
		cXMLRet +=  '</Other>'

		If Inclui .Or. Altera
			cXMLRet +=  '<Taxes>'
			SA1->(DbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA))
			For nI := 1 to Len(aImposto)
				cSE1 := (cE1 + aImposto[nI])
				IF SE1->(FieldPos(cSE1)) > 0 // indica de o imposto existe no localizado ou não. cSE1 é o nome do campo do imposto
					cSE1b := (cBase + aImposto[nI])
					cImpBase := '0.0'
					If nI == 2 .Or. nI == 3
						If AllTrim(SA1->A1_PESSOA) == "J"
							cImposto := aImposto[nI]+"-PJ"
						Elseif AllTrim(SA1->A1_PESSOA) == "F"
							cImposto := aImposto[nI] + "-PF"
						Else
							cImposto := aImposto[nI]
						Endif
					Else
						cImposto:= aImposto[nI]
					Endif

					If nI == 4
						cImpBase := CValToChar(SE1->E1_BASECOF)
					ElseIf nI == 2
						cImpBase := IIf(cPaisLoc == "BRA", CValToChar(SE1->E1_BASEIRF), '0.0')
					ElseIf nI == 3
						cImpBase := IIf(cPaisLoc == "BRA", CValToChar(SE1->E1_BASEINS), '0.0')
					Else
						cImpBase := IIf(SE1->(FieldPos(cSE1b)) > 0, CValToChar(SE1->&(cSE1b)), '0.0')
					Endif
					cXMLRet +=   '<Tax CalculationBasis="' + cImpBase +'" CityCode="' + SA1->A1_COD_MUN + '"  CountryCode="' + SA1->A1_PAIS + '" Percentage="0.0" Reason="003" Recalculate="true" ReductionBasedPercent="0.0" StateCode="' + SA1->A1_ESTADO + '" Taxe="' + cImposto + '" Value="' + CValToChar(SE1->&(cSE1)) + '"/>'
				Endif
			Next nI
			cXMLRet +=  '</Taxes>'

			If IsIntegTop() //Possui integração com o RM Solum
				aRateio := RatCAR(SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA)
			EndIf

			If empty(aRateio)
				cXMLRet +=  '<ApportionmentDistribution/>'
			Else
				cXMLRet +=  '<ApportionmentDistribution>'
				For nI := 1 To Len(aRateio)
					cXMLRet +=   '<Apportionment>'
					cXMLRet +=    '<CostCenterInternalId/>'
					cXMLRet +=    '<ProjectInternalId>' + IIf(!Empty(AllTrim(aRateio[nI][6])), AllTrim(IntPrjExt(, , aRateio[nI][6])[2]), '') + '</ProjectInternalId>' //Adapter PMSI200
					cXMLRet +=    '<TaskInternalId>' + IIf(!Empty(AllTrim(aRateio[nI][7])), IntTrfExt(, , aRateio[nI][6], '0001', aRateio[nI][7])[2], '') + '</TaskInternalId>' //Adapter PMSI203
					cXMLRet +=    '<Value>' + cValToChar(IIf(!Empty(aRateio[nI][8]), aRateio[nI][8], 0)) + '</Value>'
					cXMLRet +=    '<Percent>' + cValToChar(IIf(!Empty(aRateio[nI][5]), aRateio[nI][5], 0)) + '</Percent>'
					cXMLRet +=   '</Apportionment>'
				Next nI
				cXMLRet +=  '</ApportionmentDistribution>'
			Endif
		EndIf

		cXMLRet +=  '<Observation>' + AllTrim(SE1->E1_HIST) + '</Observation>'
		cXMLRet +=  '<Origin>' + AllTrim(SE1->E1_ORIGEM) + '</Origin>'
		cXMLRet +=  '<HolderCode>' + AllTrim(SE1->E1_PORTADO) + '</HolderCode>'
		cXMLRet +=  '<AgencyNumber>' + AllTrim(SE1->E1_AGEDEP) + '</AgencyNumber>'
		cXMLRet +=  '<AccountNumber>' + AllTrim(SE1->E1_CONTA) + '</AccountNumber>'
		cXMLRet +=  '<OurNumberBanking>' + AllTrim(SE1->E1_NUMBCO) + '</OurNumberBanking>'
		cXMLRet +=  '<ContractNumber>' + AllTrim(SE1->E1_CONTRAT) + '</ContractNumber>'
		cXMLRet +=  '<InterestPercentage>' + AllTrim(Str(SE1->E1_PORCJUR)) + '</InterestPercentage>'
		cXMLRet +=  '<AssessmentValue>' + AllTrim(Str(SE1->E1_VALJUR)) + '</AssessmentValue>'

		// Valores acessórios.
		cFK7Chv := SE1->(E1_FILIAL + '|' + E1_PREFIXO + '|' + E1_NUM + '|' + E1_PARCELA + '|' + E1_TIPO + '|' + E1_CLIENTE + '|' + E1_LOJA)
		cIdDoc  := FINBuscaFK7(cFK7Chv, "SE1")
		FKD->(dbSetOrder(2))  // FKD_FILIAL, FKD_IDDOC, FKD_CODIGO.
		If FKD->(dbSeek(xFilial() + cIdDoc, .F.))
			cXMLRet += '<ListOfComplementaryValues>'
			Do While FKD->(!eof() .and. FKD_FILIAL + FKD_IDDOC == xFilial() + cIdDoc)
				cXMLRet += ' <ComplementaryValue>'
				cXMLRet += '  <ComplementaryValueInternalId>' + F035MntInt(nil, FKD->FKD_CODIGO) + '</ComplementaryValueInternalId>'
				cXMLRet += '  <InformedValue>' + cValToChar(FKD->FKD_VALOR) + '</InformedValue>'
				cXMLRet += ' </ComplementaryValue>'
				FKD->(dbSkip())
			EndDo
			cXMLRet += '</ListOfComplementaryValues>'
		Else
			cXMLRet += '<ListOfComplementaryValues/>'
		Endif

		cXMLRet += '</BusinessContent>'
	EndIf

	AdpLogEAI(5, "FINI040", cXMLRet, lRet)
	dDataBase := dDataAux

Return {lRet, cXmlRet}

/*/{Protheus.doc} v3000
Implementação do adapter EAI, versões 3.x

@author  Felipe Raposo
@since   12/03/2019
/*/
Static Function v3000(cXml, cTypeTrans, cTypeMsg, cVersion)

	Local lRet       := .T.
	Local nOpcx      := 0
	Local cEvent     := "upsert"
	Local cAlias     := "SE1"
	Local cField     := "E1_NUM"
	Local cBase      := "E1_BASE"
	Local cImpBase   := "0.0"
	Local cXmlRet    := ""
	Local cMarca     := ""
	Local cValInt    := ""
	Local cValExt    := "" //InternalId 
	Local cValExtAcc := ""
	Local cValIntAcc := ""
	Local cCliente   := ""
	Local cPrefixo   := ""
	Local cParcela   := ""
	Local cNumDoc    := ""
	Local cRelacao   := ""
	Local cTipoDoc   := ""
	Local cNaturez   := ""
	Local cSE1       := ""
	Local cSE1b      := ""
	Local cE1        := ""
	Local cImposto   := ""
	Local cError     := ""
	Local cWarning   := ""
	Local nI         := 0
	Local aTit       := {}
	Local aAux       := {}
	Local aRatAux    := {}
	Local aImposto   := {"ISS", "IRRF", "INSS", "COFINS", "PIS", "CSLL"}
	Local aRateio    := {}
	Local nCont      := 0
	Local dVenc      := Nil
	Local cMoeVer    := ""
	Local cCliVer    := ""
	Local cLoja      := ""
	Local cTarefa    := ""
	Local aRatPrj    := {}
	Local xAux       := Nil
	Local aIntPrj    := {}
	Local cValIntRat := ""
	Local cValExtRat := ""
	Local cInternoId := ""
	Local aAuxVA     := {}
	Local nLaco      := 0
	Local cFK7Chv    := ""
	Local lFI040SE1  := ExistBlock("FI040SE1")
	Local aAuxInc    := {}
	Local lHotel     := SuperGetMV( "MV_INTHTL", , .F. )
	Local cCustRat   := SuperGetMV( "MV_HTLCCRT", , "" )
	Local dDataAux   := dDataBase
	Local lRatNat    := .F.
	Local aRatNat    := {}
	Local aNat       := {}
	Local aNatCC     := {}
	Local aAuxSEZ    := {}
	Local nJ         := 0
	Local aAuxEnt    := {}
	Local nValTit    := 0
	Local cChaveTit  := ""
	Local lFKD       := TableInDic("FKD")
	Local cCodVA     := ""
	Local nValAcess  := 0
	Local lCposVA    := SE1->(ColumnPos("E1_CONHTL")) > 0 .And. SE1->(ColumnPos("E1_TCONHTL")) > 0
	Local lV2005     := VAL(STRTRAN(cVersion,".","")) >= 2005
	Local cIdDoc     := ""
	Local aValAce    := {}
	Local lEntCtb05 := SE1->(ColumnPos("E1_EC05DB") > 0 .and. ColumnPos("E1_EC05CR") > 0)
	Local lEntCtb06 := SE1->(ColumnPos("E1_EC06DB") > 0 .and. ColumnPos("E1_EC06CR") > 0)
	Local lEntCtb07 := SE1->(ColumnPos("E1_EC07DB") > 0 .and. ColumnPos("E1_EC07CR") > 0)
	Local lEntCtb08 := SE1->(ColumnPos("E1_EC08DB") > 0 .and. ColumnPos("E1_EC08CR") > 0)
	Local lEntCtb09 := SE1->(ColumnPos("E1_EC09DB") > 0 .and. ColumnPos("E1_EC09CR") > 0)
	Local aErroRet	:= {}
	Local cNatExt	:= ""
	Local aAuxRet	:= {}
	Local dDataDel	:= dDataBase
	
	Private oXmlAux        := Nil
	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.
	
	AdpLogEAI(1, "FINI040", cTypeTrans, cTypeMsg, cXML)
	
	If cTypeTrans == TRANS_RECEIVE
	
		If cTypeMsg == EAI_MESSAGE_BUSINESS
			oXml := xmlParser(cXml, "_", @cError, @cWarning)
	
			If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
	
				//Verifica se a marca foi informada
				If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
					cMarca := oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					lRet := .F.
					cXmlRet := STR0007 //"Informe a Marca!"
					AdpLogEAI(5, "FINI040", cXMLRet, lRet)
					Return {lRet, _NoTags(cXmlRet)}
				EndIf
	
				//Verifica se o InternalId foi informado
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
					cValExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
				Else
					lRet := .F.
					cXmlRet := STR0008 //"O InternalId é obrigatório!"
					AdpLogEAI(5, "FINI040", cXMLRet, lRet)
					Return {lRet, _NoTags(cXmlRet)}
				EndIf
	
				//Obtém o valor interno
				aAux := IntTRcInt(cValExt, cMarca)
	
				// Obtém dados utilizado somente no UPSERT
				If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
					// Se o registro existe
					If aAux[1]
						nOpcx := 4 // Update
	
						cPrefixo := PadR(aAux[2][3],TamSX3("E1_PREFIXO")[1])
						cNumDoc  := PadR(aAux[2][4],TamSX3("E1_NUM")[1])
						cParcela := PadR(aAux[2][5],TamSX3("E1_PARCELA")[1])
						cTipoDoc := PadR(aAux[2][6],TamSX3("E1_TIPO")[1])
	
						cChaveTit := FWxFilial("SE1") + cPrefixo + cNumDoc + cParcela + cTipoDoc
	
						dbSelectArea( "SE1" )
						SE1->( dbSetOrder( 1 ) ) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	
						If SE1->( ! msSeek( cChaveTit ) )
							lRet := .F.
							cXmlRet := STR0044 + AllTrim( cChaveTit ) //"O de/para do título a ser alterado foi encontrado, porém o registro de título no contas a receber não foi encontrado no Protheus. Verifique se o mesmo não foi excluído manualmente. Chave do título: "
							Return {lRet, _NoTags(cXmlRet)}
						Endif
	
					Else
						nOpcx := 3 // Insert
	
						//Prefixo
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentPrefix:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentPrefix:Text)
							cPrefixo := PadR(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentPrefix:Text, TamSX3("E1_PREFIXO")[1])
						ElseIf lHotel
							cPrefixo := SuperGetMV( "MV_HTLPREF", , "" ) //Prefixo para hotelaria
						ElseIf IsIntegTop() //Possui integração com o RM Solum
							cPrefixo := PadR(GetNewPar("MV_SLMPRER", ""), TamSX3("E1_PREFIXO")[1])
						EndIf
	
						// Verifica se não possui numeração automática.
						cRelacao := GetSX3Cache("E1_NUM", "X3_RELACAO")
						If !empty(cRelacao)
							cNumDoc := &cRelacao
						Endif
	
						If empty(cNumDoc)
							//Verifica se o Número do Título foi informado
							If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text)
								cNumDoc := AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text)
							Else
								lRet := .F.
								cXmlRet := STR0009 //"Informe o Número do Título"
								AdpLogEAI(5, "FINI040", cXMLRet, lRet)
								Return {lRet, _NoTags(cXmlRet)}
							EndIf
						Endif
						cNumDoc := PadR(cNumDoc, TamSX3("E1_NUM")[1])
	
						//Parcela
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentParcel:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentParcel:Text)
							cParcela := AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentParcel:Text)
						EndIf
	
						//Verifica se o Tipo do Título foi informado
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentTypeCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentTypeCode:Text)
							cTipoDoc := AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentTypeCode:Text)
						Else
							lRet := .F.
							cXmlRet := STR0010 //"Informe o Tipo do Título"
							AdpLogEAI(5, "FINI040", cXMLRet, lRet)
							Return {lRet, _NoTags(cXmlRet)}
						EndIf
					EndIf
	
					aAdd(aTit, {"E1_NUM",     PadR(cNumDoc, TamSX3("E1_NUM")[1]),      Nil})
					aAdd(aTit, {"E1_PREFIXO", cPrefixo,                                Nil})
					aAdd(aTit, {"E1_PARCELA", PadR(cParcela, TamSX3("E1_PARCELA")[1]), Nil})
					aAdd(aTit, {"E1_TIPO",    PadR(cTipoDoc, TamSX3("E1_TIPO")[1]),    Nil})
	
					// Verifica se Natureza foi informada
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialNatureInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialNatureInternalId:Text)
						cNatExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialNatureInternalId:Text
						aAux := F10GetInt(cNatExt, cMarca) //Adapter FINI010I
	
						If aAux[1]
							cNaturez := aAux[2][3]
							aAdd(aTit, {"E1_NATUREZ", PadR(cNaturez, TamSX3("E1_NATUREZ")[1]), Nil})
						Else
							lRet := .F.
							aAdd(aErroRet, STR0037 + " -> " + cNatExt)//"Natureza não encontrada no de/para."
						EndIf
					Else
						//Se for integração com hotelaria, pega a natureza do parâmetro
						If lHotel
							If AllTrim( cTipoDoc ) == "RA"
								cNaturez := SuperGetMV( "MV_HTLNARA", , "" ) //Natureza pra RA
							ElseIf AllTrim( cTipoDoc ) == "PR"
								cNaturez := SuperGetMV( "MV_HTLNAPR", , "" ) //Natureza pra PR
							ElseIf AllTrim( cTipoDoc ) == "CC"
								cNaturez := SuperGetMV( "MV_HTLNACC", , "" ) //Natureza pra CC
							ElseIf AllTrim( cTipoDoc ) == "CD"
								cNaturez := SuperGetMV( "MV_HTLNACD", , "" ) //Natureza pra CD
							ElseIf AllTrim( cTipoDoc ) == "NCC"
								cNaturez := SuperGetMV( "MV_HTLNANC", , "" ) //Natureza pra NCC
							ElseIf AllTrim( cTipoDoc ) == "R$"
								cNaturez := SuperGetMV( "MV_HTLNADH", , "" ) //Natureza pra R$
							Endif
						Else
							// Utiliza o parâmetro MV_SLMNATR criado para a integração Protheus x RM Solum para
							// as demais integrações quando o FinancialNatureInternalId não for informado
							cNaturez := RTrim(GetNewPar("MV_SLMNATR", ""))
						Endif
	
						If !Empty(cNaturez)
							aAdd(aTit, {"E1_NATUREZ", PadR(cNaturez, TamSX3("E1_NATUREZ")[1]), Nil})
						Else
							lRet := .F.
							If lHotel
								cXmlRet := STR0038 + "MV_HTLNARA | MV_HTLNAPR | MV_HTLNACC | MV_HTLNACD | MV_HTLNANC | MV_HTLNADH" //"Natureza não informada. Verifique os parâmetros: "
							Else
								cXmlRet := STR0039 //"Natureza não informada. Verifique o parâmetro MV_SLMNATR."
							Endif
							AdpLogEAI(5, "FINI050", cXMLRet, lRet)
							Return {lRet, _NoTags(cXmlRet)}
						EndIf
	
					EndIf
	
					//Obtém o Código Interno do Cliente
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerInternalId:Text)
						cCliVer := MsgUVer('MATA030', 'CUSTOMERVENDOR')
						aAux := IntCliInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerInternalId:Text, cMarca, cCliVer) //Adapter MATI030
						If !aAux[1]
							lRet := .F.
							aAdd(aErroRet,aAux[2])
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
					Else //Se já for o código Protheus do Cliente (tags CustomerCode e StoreId)
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text)
							cCliente := AllTrim( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text )
							aAdd(aTit, {"E1_CLIENTE", PadR(cCliente, TamSX3("E1_CLIENTE")[1]), Nil})
						EndIf
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_StoreId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_StoreId:Text)
							cLoja := AllTrim( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_StoreId:Text )
							aAdd(aTit, {"E1_LOJA", PadR(cLoja, TamSX3("E1_LOJA")[1]), Nil})
						EndIf
					EndIf
	
					If Empty( cCliente ) .OR. Empty ( cLoja )
						cXmlRet := STR0043 //"Código de cliente não informado."
						AdpLogEAI(5, "FINI050", cXMLRet, lRet)
						Return {.F., _NoTags(cXmlRet)}
					Endif
	
					//Verifica se a data de emissão do título foi informada
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_IssueDate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_IssueDate:Text)
						aAdd(aTit, {"E1_EMISSAO", SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_IssueDate:Text,"-","")), Nil})
					Else
						lRet := .F.
						cXmlRet := STR0014 //"Informe a data de emissão do título."
						AdpLogEAI(5, "FINI040", cXMLRet, lRet)
						Return {lRet, _NoTags(cXmlRet)}
					EndIf
	
					//Verifica se o Vencimento do Título foi informado
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DueDate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DueDate:Text)
						aAdd(aTit, {"E1_VENCTO", SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DueDate:Text,"-","")), Nil})
						aAdd(aTit, {"E1_VENCREA", SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DueDate:Text,"-","")), Nil})
					Else
						lRet := .F.
						cXmlRet := STR0015 //"Informe o Vencimento do Título"
						AdpLogEAI(5, "FINI040", cXMLRet, lRet)
						Return {lRet, _NoTags(cXmlRet)}
					EndIf
	
					// Verifica se o Valor do Título foi informado
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text)
						nValTit := Val(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text,",","."))
						aAdd(aTit, {"E1_VALOR", nValTit, Nil})
						aAdd(aTit, {"E1_VLCRUZ", nValTit, Nil})
					Else
						lRet := .F.
						cXmlRet := STR0016 //"Informe o Valor do Título"
						AdpLogEAI(5, "FINI040", cXMLRet, lRet)
						Return {lRet, _NoTags(cXmlRet)}
					EndIf
	
					// Desconto financeiro (%)
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DiscountPercentage:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DiscountPercentage:Text)
						aAdd(aTit, {"E1_DESCFIN", Val(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DiscountPercentage:Text,",",".")), Nil})
					EndIf
	
					// Histórico
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Observation:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Observation:Text)
						aAdd(aTit, {"E1_HIST", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Observation:Text, NIL})
					Endif
	
					// Origem
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Origin:Text)
						aAdd(aTit, {"E1_ORIGEM", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Origin:Text, Nil})
					Else
						aAdd(aTit, {"E1_ORIGEM", "FINI040", Nil})
					EndIf
	
					// Moeda
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyInternalId:Text)
						cMoeVer := MsgUVer('CTBA140', 'CURRENCY')
						aAux := IntMoeInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyInternalId:Text, cMarca, cMoeVer) //Adapter CTBI140
						If !aAux[1]
							lRet := .F.
							aAdd(aErroRet, aAux[2])
						Else
							If cMoeVer = "1."
								aAdd(aTit, {"E1_MOEDA", Val(aAux[2][2]), Nil})
							Else
								aAdd(aTit, {"E1_MOEDA", Val(aAux[2][3]), Nil})
							Endif
						EndIf
					Else
						aAdd(aTit, {"E1_MOEDA", 1, Nil})
					EndIf
	
					//Caso a tag HolderCode venha preenchida, alimento os dados do portador, agencia e conta com base nesses dados
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_HolderCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_HolderCode:Text)
						aAdd(aTit, {"E1_PORTADO", PadR(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_HolderCode:Text,TamSX3("E1_PORTADO")[1]), Nil})
					EndIf
	
					//Valor Real do Título
					If( XmlChildEx( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_REALVALUE" ) <> Nil )
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RealValue:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RealValue:Text)
							aAdd(aTit, {"E1_VLRREAL", Val(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RealValue:Text,",",".")), NIL})
						Endif
					Endif
	
					//Número NSU (transação com cartão)
					If( XmlChildEx( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_UNIQUESERIALNUMBER" ) <> Nil )
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UniqueSerialNumber:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UniqueSerialNumber:Text)
							aAdd(aTit, {"E1_NSUTEF", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UniqueSerialNumber:Text, NIL})
						Endif
					Endif
	
					//Possui rateio
					If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ApportionmentDistribution:_Apportionment") != "U"
						//Se não for Array
						If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ApportionmentDistribution:_Apportionment") != "A"
							//Transforma em array
							XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ApportionmentDistribution:_Apportionment,"_Apportionment")
						EndIf
	
						For nI := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ApportionmentDistribution:_Apportionment)
							// Atualiza o objeto com a posição atual
							oXmlAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ApportionmentDistribution:_Apportionment[nI]
							// Se possui projeto informado
							If Type("oXmlAux:_ProjectInternalId:Text") != "U" .And. !Empty(oXmlAux:_ProjectInternalId:Text)
								// Verifica se o código do projeto é válido
								aAux := IntPrjInt(oXmlAux:_ProjectInternalId:Text, cMarca) //Empresa/Filial/Projeto
								If !aAux[1]
									lRet := .F.
									cXmlRet := aAux[2] + " Título " + cNumDoc //" Título "
									AdpLogEAI(5, "FINI040", cXMLRet, lRet)
									Return {lRet, _NoTags(cXmlRet)}
								Else
									xAux := aAux[2][3]
								EndIf
	
								If Type("oXmlAux:_TaskInternalId:Text") != "U" .And. !Empty(oXmlAux:_TaskInternalId:Text)
									aAux := IntTrfInt(oXmlAux:_TaskInternalId:Text, cMarca) //Empresa/Filial/Projeto/Revisao/Tarefa
									If !aAux[1]
										lRet := .F.
										cXmlRet := aAux[2] + " Título " + cNumDoc //" Título "
										AdpLogEAI(5, "FINI040", cXMLRet, lRet)
										Return {lRet, _NoTags(cXmlRet)}
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
										cXmlRet := STR0040 //"Não existe Tarefa para o Projeto informado."
										AdpLogEAI(5, "FINI040", cXMLRet, lRet)
										Return {lRet, _NoTags(cXmlRet)}
									EndIf
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
									cXmlRet := STR0041 + cNumDoc //"Valor do rateio inválido para o título "
									AdpLogEAI(5, "FINI040", cXMLRet, lRet)
									Return {lRet, _NoTags(cXmlRet)}
								EndIf
							EndIf
						Next nI
					EndIf
	
					//Código da Agência
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgencyNumber:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgencyNumber:Text)
						aAdd(aTit, {"E1_AGEDEP", PadR(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgencyNumber:Text,TamSX3("E1_AGEDEP")[1]), NIL})
					Endif
	
					//Número da Conta
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AccountNumber:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AccountNumber:Text)
						aAdd(aTit, {"E1_CONTA", PadR(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AccountNumber:Text,TamSX3("E1_CONTA")[1]), NIL})
					Endif
	
					//Nosso Número
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OurNumberBanking:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OurNumberBanking:Text)
						aAdd(aTit, {"E1_NUMBCO", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OurNumberBanking:Text, NIL})
					Endif
	
					//Código de Barra
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Barcode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Barcode:Text)
						aAdd(aTit, {"E1_CODBAR", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Barcode:Text, NIL})
					Endif
	
					//Nr. Contrato
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ContractNumber:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ContractNumber:Text)
						aAdd(aTit, {"E1_CONTRAT", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ContractNumber:Text, NIL})
					Endif
	
					//Percentual de Juros Diária
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InterestPercentage:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InterestPercentage:Text)
						aAdd(aTit, {"E1_PORCJUR", Val(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InterestPercentage:Text,",",".")), NIL})
					EndIf
	
					//Valor de Multa Diária (Taxa de Permanência)
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AssessmentValue:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AssessmentValue:Text)
						aAdd(aTit, {"E1_VALJUR", Val(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AssessmentValue:Text,",",".")), NIL})
					EndIf
	
					//Valor de desconto de bolsa (educacional)
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UnconditionalScholarshipValue:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UnconditionalScholarshipValue:Text)
						aAdd(aTit, {"E1_VLBOLSA", Val(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UnconditionalScholarshipValue:Text,",",".")), NIL})
					EndIf
					
					// Valores acessórios.
					If lFKD 
						If(Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues") == "O")
							If(Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue") == "A")
								
								For nLaco := 1 to Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue)
									If(Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue[" + cValtoChar(nLaco) + "]") != "U")
										If(Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue[" + cValToChar(nLaco) + "]:_ComplementaryValueInternalId:Text") != "U" .And.;
										!Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue[nLaco]:_ComplementaryValueInternalId:Text))
											cInternoId := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue[nLaco]:_ComplementaryValueInternalId:Text
											aAuxVA := F035GETINT(cInternoId,cMarca)
											If(aAuxVa[1])
												If(Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue["+ cValToChar(nLaco) +"]:_InformedValue:Text") != "U" .And.;
												!Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue[nLaco]:_InformedValue:Text))
													//adicionar em modo vetor
													cCodVA := aAuxVa[2,3]
													nValAcess := val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue[nLaco]:_InformedValue:Text)
													If nValAcess != 0
														aAdd(aValAce, {cCodVA, nValAcess})
													Endif
												EndIf
											Else
												lRet := .F.
												aAdd(aErroRet, STR0042 +' '+ cInternoId)//"Erro ao encontrar o valor acessorio"
												Exit
											EndIf
										EndIf
									EndIf
								Next nLaco
							
							ElseIf(Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue") == "O")
								If(Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue:_ComplementaryValueInternalId:Text") != "U" .And.;
								!Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue:_ComplementaryValueInternalId:Text))
									cInternoId := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue:_ComplementaryValueInternalId:Text
									aAuxVA := F035GETINT(cInternoId,cMarca)
									If(aAuxVa[1])
										If(Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue:_InformedValue:Text") != "U" .And.;
										!Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue:_InformedValue:Text))
											//adicionar em modo vetor
											cCodVA := aAuxVa[2,3]
											nValAcess := val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue:_InformedValue:Text)
											If nValAcess != 0
												aAdd(aValAce, {cCodVA, nValAcess})
											Endif
										EndIf
									Else
										lRet := .F.
										aAdd(aErroRet, STR0042 +' '+ cInternoId)//"Erro ao encontrar o valor acessorio"
										
									EndIf
								EndIf
							EndIf
						EndIf
					Endif
	
					If XmlChildEx( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_OTHER" ) <> Nil
						//Registro Acadêmico do Aluno
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_AcademicRecord:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_AcademicRecord:Text)
							aAdd(aTit, {"E1_NUMRA", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_AcademicRecord:Text, NIL})
						EndIf
	
						//Período Letivo
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_AcademicPeriod:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_AcademicPeriod:Text)
							aAdd(aTit, {"E1_PERLET", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_AcademicPeriod:Text, NIL})
						EndIf
	
						//Matriz Aplicada
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_AppliedMatrix:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_AppliedMatrix:Text)
							aAdd(aTit, {"E1_IDAPLIC", Val(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_AppliedMatrix:Text,",",".")), NIL})
						EndIf
	
						//Identificador Interno do Produto
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_ItemInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_ItemInternalId:Text)
							cCodProd := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_ItemInternalId:Text
							aAuxRet := IntProInt(cCodProd, cMarca, /*Versão*/)
							If aAuxRet[1]
								aAdd(aTit, { "E1_PRODUTO", aAuxRet[2][3] , NIL})
							EndIf
						EndIf
	
						//Turma (Classe)
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_Class:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_Class:Text)
							aAdd(aTit, {"E1_TURMA", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_Class:Text, NIL})
						EndIf
	
						//Tag com o número de conta hoteleira a qual o título estará associado
						If( XmlChildEx( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other, "_HOTELACCOUNTCODE" ) <> Nil )
							If Type( "oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_HotelAccountCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_HotelAccountCode:Text )
								aAdd( aTit, {"E1_CONHTL", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_HotelAccountCode:Text, NIL} )
							EndIf
						Endif
	
						//Tag com o tipo de conta hoteleira a qual o título estará associado (1=Evento; 2=Grupo; 3=Individual; 4=Avulsa)
						If( XmlChildEx( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other, "_HOTELACCOUNTTYPE" ) <> Nil )
							If Type( "oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_HotelAccountType:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_HotelAccountType:Text )
								aAdd( aTit, {"E1_TCONHTL", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Other:_HotelAccountType:Text, NIL} )
							EndIf
						Endif
					EndIf
	
					If XmlChildEx( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_ACCOUNTING" ) <> Nil
						// Conta contábil - Débito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingAccountDebitInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingAccountDebitInternalId:Text
							cValIntAcc := CFGA070INT(cMarca, "CT1", "CT1_CONTA", cValExtAcc)
							If !Empty(cValIntAcc)
								aAux    := Separa(cValIntAcc, '|')
								aAdd(aTit, {"E1_DEBITO", aAux[3], NIL})
							Else
								lRet := .F.
								aAdd(aErroRet, cValExtAcc+STR0032)
							Endif
						EndIf

						// Conta contábil - Crédito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingAccountCreditInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingAccountCreditInternalId:Text
							cValIntAcc := CFGA070INT(cMarca, "CT1", "CT1_CONTA", cValExtAcc)
							If !Empty(cValIntAcc)
								aAux    := Separa(cValIntAcc, '|')
								aAdd(aTit, {"E1_CREDIT", aAux[3], NIL})
							Else
								lRet := .F.
								aAdd(aErroRet, cValExtAcc+STR0032)
							Endif
						EndIf

						// Centro de custo - Débito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_CostCenterDebitInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_CostCenterDebitInternalId:Text
							aAuxRet := IntCusInt(cValExtAcc, cMarca)
							If aAuxRet[1]
								aAdd(aTit, {"E1_CCD", aAuxRet[2,3], NIL})
							Else
								lRet := .F.
								aAdd(aErroRet, aAuxRet[2])
							Endif
						EndIf

						// Centro de custo - Crédito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_CostCenterCreditInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_CostCenterCreditInternalId:Text
							aAuxRet := IntCusInt(cValExtAcc, cMarca)
							If aAuxRet[1]
								aAdd(aTit, {"E1_CCC", aAuxRet[2,3], NIL})
							Else
								lRet := .F.
								aAdd(aErroRet, aAuxRet[2])
							Endif
						EndIf
	
						// Item contábil - Débito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingItemDebitInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingItemDebitInternalId:Text
							aAuxRet := C040GetInt(cValExtAcc, cMarca)
							If aAuxRet[1]
								aAdd(aTit, {"E1_ITEMD", aAuxRet[2,3], NIL})
							Else
								lRet := .F.
								aAdd(aErroRet, aAuxRet[2])
							Endif
						EndIf
	
						// Item contábil - Crédito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingItemCreditInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingItemCreditInternalId:Text
							aAuxRet := C040GetInt(cValExtAcc, cMarca)
							If aAuxRet[1]
								aAdd(aTit, {"E1_ITEMC", aAuxRet[2,3], NIL})
							Else
								lRet := .F.
								aAdd(aErroRet, aAuxRet[2])
							Endif
						EndIf
	
						// Classe de valor - Débito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_ClassValueDebitInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_ClassValueDebitInternalId:Text
							aAuxRet := C060GetInt(cValExtAcc, cMarca)
							If aAuxRet[1]
								aAdd(aTit, {"E1_CLVLDB", aAuxRet[2,3], NIL})
							Else
								lRet := .F.
								aAdd(aErroRet, aAuxRet[2])
							Endif
						EndIf
	
						// Classe de valor - Crédito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_ClassValueCreditInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_ClassValueCreditInternalId:Text
							aAuxRet := C060GetInt(cValExtAcc, cMarca)
							If aAuxRet[1]
								aAdd(aTit, {"E1_CLVLCR", aAuxRet[2,3], NIL})
							Else
								lRet := .F.
								aAdd(aErroRet, aAuxRet[2])
							Endif
						EndIf
	
						// Entidade contábil 5 - Débito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity5DebitInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity5DebitInternalId:Text
							aAuxRet := IntGerInt(cValExtAcc, cMarca)
							If aAuxRet[1]
								aAdd(aTit, {"E1_EC05DB", aAuxRet[2,4], NIL})
							Else
								lRet := .F.
								aAdd(aErroRet, aAuxRet[2])
							Endif
						EndIf
	
						// Entidade contábil 5 - Crédito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity5CreditInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity5CreditInternalId:Text
							aAuxRet := IntGerInt(cValExtAcc, cMarca)
							If aAuxRet[1]
								aAdd(aTit, {"E1_EC05CR", aAuxRet[2,4], NIL})
							Else
								lRet := .F.
								aAdd(aErroRet, aAuxRet[2])
							Endif
						EndIf
	
						// Entidade contábil 6 - Débito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity6DebitInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity6DebitInternalId:Text
							aAuxRet := IntGerInt(cValExtAcc, cMarca)
							If aAuxRet[1]
								aAdd(aTit, {"E1_EC06DB", aAuxRet[2,4], NIL})
							Else
								lRet := .F.
								aAdd(aErroRet, aAuxRet[2])
							Endif
						EndIf
	
						// Entidade contábil 6 - Crédito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity6CreditInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity6CreditInternalId:Text
							aAuxRet := IntGerInt(cValExtAcc, cMarca)
							If aAuxRet[1]
								aAdd(aTit, {"E1_EC06CR", aAuxRet[2,4], NIL})
							Else
								lRet := .F.
								aAdd(aErroRet, aAuxRet[2])
							Endif
						EndIf
	
						// Entidade contábil 7 - Débito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity7DebitInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity7DebitInternalId:Text
							aAuxRet := IntGerInt(cValExtAcc, cMarca)
							If aAuxRet[1]
								aAdd(aTit, {"E1_EC07DB", aAuxRet[2,4], NIL})
							Else
								lRet := .F.
								aAdd(aErroRet, aAuxRet[2])
							Endif
						EndIf
	
						// Entidade contábil 7 - Crédito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity7CreditInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity7CreditInternalId:Text
							aAuxRet := IntGerInt(cValExtAcc, cMarca)
							If aAuxRet[1]
								aAdd(aTit, {"E1_EC07CR", aAuxRet[2,4], NIL})
							Else
								lRet := .F.
								aAdd(aErroRet, aAuxRet[2])
							Endif
						EndIf
	
						// Entidade contábil 8 - Débito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity8DebitInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity8DebitInternalId:Text
							aAuxRet := IntGerInt(cValExtAcc, cMarca)
							If aAuxRet[1]
								aAdd(aTit, {"E1_EC08DB", aAuxRet[2,4], NIL})
							Else
								lRet := .F.
								aAdd(aErroRet, aAuxRet[2])
							Endif
						EndIf
	
						// Entidade contábil 8 - Crédito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity8CreditInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity8CreditInternalId:Text
							aAuxRet := IntGerInt(cValExtAcc, cMarca)
							If aAuxRet[1]
								aAdd(aTit, {"E1_EC08CR", aAuxRet[2,4], NIL})
							Else
								lRet := .F.
								aAdd(aErroRet, aAuxRet[2])
							Endif
						EndIf
	
						// Entidade contábil 9 - Débito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity9DebitInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity9DebitInternalId:Text
							aAuxRet := IntGerInt(cValExtAcc, cMarca)
							If aAuxRet[1]
								aAdd(aTit, {"E1_EC09DB", aAuxRet[2,4], NIL})
							Else
								lRet := .F.
								aAdd(aErroRet, aAuxRet[2])
							Endif
						EndIf
	
						// Entidade contábil 9 - Crédito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity9CreditInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity9CreditInternalId:Text
							aAuxRet := IntGerInt(cValExtAcc, cMarca)
							If aAuxRet[1]
								aAdd(aTit, {"E1_EC09CR", aAuxRet[2,4], NIL})
							Else
								lRet := .F.
								aAdd(aErroRet, aAuxRet[2])
							Endif
						EndIf
					Endif
	
					//Tratamento específico para integração com RM Classis
					If Upper(AllTrim(cMarca)) == "RM"
						aAdd(aTit, {"E1_IDLAN", 1, Nil})
					EndIf
	
					//Rateio por natureza e centro de custos
					If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment") != "U"
						//Se não for Array
						If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment") != "A"
							//Transforma em array
							XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment,"_FinancialNatureApportionment")
						EndIf
	
						lRatNat := .T.
						aAdd( aTit, { "E1_MULTNAT", "1", Nil } ) //Rateio multinaturezs = sim
	
						For nI := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment)
							//Atualiza o objeto com a posição atual
							oXmlAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI]
	
							//Código da Natureza
							If Type("oXmlAux:_FinancialNatureInternalId:Text") != "U" .And. !Empty(oXmlAux:_FinancialNatureInternalId:Text)
								//Fazer de/para
							Else
								//Natureza definida no parâmetro MV_HTLNART
								aAdd( aNat, { "EV_NATUREZ", PADR( cNaturez, TamSx3("EV_NATUREZ")[1] ), Nil } )
							EndIf
	
							//Valor distribuido para a natureza em questão
							If Type("oXmlAux:_Value:Text") != "U" .And. !Empty(oXmlAux:_Value:Text)
								aAdd( aNat, { "EV_VALOR", Val( oXmlAux:_Value:Text ), Nil } )
							Else
								If lHotel //Remover esse tratamento após tratar a execauto para calcular EV com base no percentual e vice-versa (assim como já foi feito na SEZ)
									aAdd( aNat, { "EV_VALOR", nValTit, Nil } )
								Else
									aAdd( aNat, { "EV_VALOR", 0, Nil } )
								Endif
							EndIf
	
							//Percentual distribuido para a natureza em questão
							If Type("oXmlAux:_Percentage:Text") != "U" .And. !Empty(oXmlAux:_Percentage:Text)
								aAdd( aNat, { "EV_PERC", Val( oXmlAux:_Percentage:Text ), Nil } )
							Else
								aAdd( aNat, { "EV_PERC", 0, Nil } )
							EndIf
	
							//Rateio por centro de custos
							If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[" + cValToChar(nI) + "]:_ListOfCostCenterApportionment:_CostCenterApportionment") != "U"
								//Se não for Array
								If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[" + cValToChar(nI) + "]:_ListOfCostCenterApportionment:_CostCenterApportionment") != "A"
									//Transforma em array
									XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI]:_ListOfCostCenterApportionment:_CostCenterApportionment,"_CostCenterApportionment")
								EndIf
	
								aAdd( aNat, { "EV_RATEICC", "1", Nil } ) //indica que há rateio por centro de custo
	
								For nJ := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI]:_ListOfCostCenterApportionment:_CostCenterApportionment)
									//Atualiza o objeto com a posição atual
									oXmlAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI]:_ListOfCostCenterApportionment:_CostCenterApportionment[nJ]
	
									//Código do Centro de custos
									If Type("oXmlAux:_CostCenterInternalId:Text") != "U" .And. !Empty(oXmlAux:_CostCenterInternalId:Text)
										//Fazer de/para
									Else
										//Centro de Custo definido no parâmetro MV_HTLCCRT
										aAdd( aAuxSEZ, { "EZ_CCUSTO", cCustRat, Nil } )
									EndIf
	
									//Entidade adicional (05, 06, 07, 08 ou 09) - Código da conta
									If Type("oXmlAux:_GenericEntityInternalId:Text") != "U" .And. !Empty(oXmlAux:_GenericEntityInternalId:Text)
	
										//Obtém o valor interno da tabela XXF (de/para)
										aAuxEnt := IntGerInt( oXmlAux:_GenericEntityInternalId:Text, cMarca, "1.000")
										If aAuxEnt[1]
											aAdd( aAuxSEZ, { "EZ_EC05DB", aAuxEnt[2][4], Nil } )
										Endif
	
									Else
										aAdd( aAuxSEZ, Nil )
									EndIf
	
									//Valor distribuido para o centro de custo em questão
									If Type("oXmlAux:_Value:Text") != "U" .And. !Empty(oXmlAux:_Value:Text)
										aAdd( aAuxSEZ, { "EZ_VALOR", Val( oXmlAux:_Value:Text ), Nil } )
									Else
										aAdd( aAuxSEZ, { "EZ_VALOR", 0, Nil } )
									EndIf
	
									//Percentual distribuido para o centro de custo em questão
									If Type("oXmlAux:_Percentage:Text") != "U" .And. !Empty(oXmlAux:_Percentage:Text)
										aAdd( aAuxSEZ, { "EZ_PERC", Val( oXmlAux:_Percentage:Text ), Nil } )
									Else
										aAdd( aAuxSEZ, { "EZ_PERC", 0, Nil } )
									EndIf
	
									aAdd( aNatCC, aClone( aAuxSEZ ) )
									aSize ( aAuxSEZ, 0 )
								Next nJ
							Endif
	
							aAdd( aNat, { "AUTRATEICC", aClone( aNatCC ), Nil } ) //Adiciona o array de multiplos centros de custos no array da natureza
							aSize ( aNatCC, 0 )
	
							aAdd( aRatNat, aClone( aNat ) ) //Adiciona o array de natureza no array de rateio por multiplas naturezas
							aSize ( aNat, 0 )
						Next nI
					EndIf
	
				ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
	
					//Data de Exclusão
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DeletionDate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DeletionDate:Text)
						dDataDel := SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DeletionDate:Text ,"-",""))
						If !Empty(dDataDel)
							dDataBase:= dDataDel
						Endif
					EndIf
					// Se o registro existe
					If aAux[1]
						nOpcx := 5 // Delete
	
						cPrefixo := PadR(aAux[2][3] , TamSX3("E1_PREFIXO")[1]) //  aAux[2][3]
						cNumDoc  := PadR(aAux[2][4] , TamSX3("E1_NUM")    [1]) //  aAux[2][4]
						cParcela := PadR(aAux[2][5] , TamSX3("E1_PARCELA")[1]) //  aAux[2][5]
						cTipoDoc := PadR(aAux[2][6] , TamSX3("E1_TIPO")   [1]) //  aAux[2][6]
	
						dbSelectArea("SE1")
						SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	
						If SE1->(dbSeek(xFilial("SE1") + cPrefixo + cNumDoc + cParcela + cTipoDoc))
							cCliente := SE1->E1_CLIENTE
							cLoja    := SE1->E1_LOJA
						Else
							cCliente := ""
							cLoja    := ""
						EndIf
	
						aAdd(aTit, {"E1_PREFIXO", PadR(cPrefixo, TamSX3("E1_PREFIXO")[1]), Nil})
						aAdd(aTit, {"E1_NUM",     PadR(cNumDoc,  TamSX3("E1_NUM")[1]),     Nil})
						aAdd(aTit, {"E1_PARCELA", PadR(cParcela, TamSX3("E1_PARCELA")[1]), Nil})
						aAdd(aTit, {"E1_TIPO",    PadR(cTipoDoc, TamSX3("E1_TIPO")[1]),    Nil})
	
						//Rateio
						aAdd(aRatAux, {"AFT_PREFIX", PadR(cPrefixo, TamSX3("AFT_PREFIX")[1]), Nil})
						aAdd(aRatAux, {"AFT_NUM",    PadR(cNumDoc,  TamSX3("AFT_NUM")[1]),    Nil})
						aAdd(aRatAux, {"AFT_PARCEL", PadR(cParcela, TamSX3("AFT_PARCEL")[1]), Nil})
						aAdd(aRatAux, {"AFT_TIPO",   PadR(cTipoDoc, TamSX3("AFT_TIPO")[1]),   Nil})
						aAdd(aRatAux, {"AFT_CLIENT", PadR(cCliente, TamSX3("AFT_CLIENT")[1]), Nil})
						aAdd(aRatAux, {"AFT_LOJA",   PadR(cLoja,    TamSX3("AFT_LOJA")[1]),   Nil})
						aAdd(aRatPrj, aRatAux)
						aRatAux := {}
	
						//De/Para do rateio
						aRatAux := RatCAR(SE1->E1_FILIAL + cPrefixo + cNumDoc + cParcela + cTipoDoc + cCliente + cLoja)
	
						for nI := 1 To Len(aRatAux)
							cValIntRat := IntTRcExt(, , cPrefixo, cNumDoc, cParcela, cTipoDoc)[2] + "|" + AllTrim(cCliente) + "|" + AllTrim(cLoja) + "|" + AllTrim(aRatAux[nI][6]) + "|" + StrZero(1, TamSX3("AFT_REVISA")[1]) + "|" + AllTrim(aRatAux[nI][7])
							cValExtRat := AllTrim(CFGA070Ext(cMarca, "AFT", "AFT_TAREFA", cValIntRat))
	
							aAdd(aIntPrj, {"AFT", "AFT_TAREFA", cValIntRat, cValExtRat})
						Next nI
					Else
						lRet := .F.
						dDataBase := dDataAux
						cXmlRet := STR0017 //"O Título a ser excluído não foi encontrado na base Protheus"
						Return {lRet, _NoTags(cXmlRet)}
					EndIf
				Else
					lRet := .F.
					dDataBase := dDataAux
					cXmlRet := STR0018 //"O evento informado é inválido"
					Return {lRet, _NoTags(cXmlRet)}
				EndIf
	
				If lRet
					cValInt := IntTRcExt(, , cPrefixo, cNumDoc, cParcela, cTipoDoc)[2]
	
					// Ponto de Entrada para tratamento do Array de campos enviado na MSExecAuto
					If lFI040SE1
						aAuxInc := ExecBlock("FI040SE1",.F.,.F.,{aTit,nOpcx})
						If ValType(aAuxInc) == "A" .And. Len(aAuxInc) > 0
							aTit := aClone(aAuxInc)
						EndIf
					EndIf
	
					AdpLogEAI(3, "aTit: ", aTit)
					AdpLogEAI(3, "cValInt: ", cValInt)
					AdpLogEAI(3, "cValExt: ", cValExt)
					AdpLogEAI(3, "aRatPrj: ", aRatPrj)
					AdpLogEAI(3, "aIntPrj: ", aIntPrj)
					AdpLogEAI(4, nOpcx)
	
					BEGIN TRANSACTION
	
						MSExecAuto({|a, b, c, d| FINA040(a, b,, c,,,, d)}, aTit, nOpcx, If(lRatNat, aRatNat, nil), If(lFKD, aValAce, nil))
	
						// Se houve erros no processamento do MSExecAuto
						If lMsErroAuto
							aErroAuto := GetAutoGRLog()
	
							cXMLRet := "<![CDATA["
							For nI := 1 To Len(aErroAuto)
								cXMLRet += aErroAuto[nI] + Chr(10)
							Next nI
							cXMLRet += "]]>"
	
							lRet := .F.
	
							DisarmTransaction()
							MsUnLockAll()
						Else
							//Grava o rateio de projeto fora da rotina automatica
							//A pedido da equipe de Controladoria
							If Len(aRatPrj) > 0
								pmsWsCR(cValToChar(nOpcx) ,aRatPrj)
							EndIf
	
							If nOpcx != 5 // Se o evento é diferente de delete
								// Grava o registro na tabela XXF (de/para)
								CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F., 1)
	
								//De/Para do rateio
								For nI := 1 To Len(aIntPrj)
									CFGA070Mnt(cMarca, aIntPrj[nI][1], aIntPrj[nI][2], aIntPrj[nI][4], aIntPrj[nI][3], .F., 1)
								Next nI
	
								// Monta o XML de retorno
								cXMLRet := "<ListOfInternalId>"
								cXMLRet +=    "<InternalId>"
								cXMLRet +=       "<Name>AccountReceivableDocument</Name>"
								cXMLRet +=       "<Origin>" + cValExt + "</Origin>"
								cXmlRet +=       "<Destination>" + cValInt + "</Destination>"
								cXMLRet +=    "</InternalId>"
								For nI := 1 To Len(aIntPrj)
									cXMLRet += "<InternalId>"
									cXMLRet +=    "<Name>ApportionmentInternalId</Name>"
									cXMLRet +=    "<Origin>" + aIntPrj[nI][4] + "</Origin>"
									cXmlRet +=    "<Destination>" + aIntPrj[nI][3] + "</Destination>"
									cXMLRet += "</InternalId>"
								Next nI
								cXMLRet += "</ListOfInternalId>"
							Else
								// Exclui o registro na tabela XXF (de/para)
								CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .T., 1)
	
								//De/Para do rateio
								For nI := 1 To Len(aIntPrj)
									CFGA070Mnt(cMarca, aIntPrj[nI][1], aIntPrj[nI][2], aIntPrj[nI][4], aIntPrj[nI][3], .T., 1)
								Next nI
							EndIf
						Endif
	
					END TRANSACTION
				Else
					For nI := 1 To Len(aErroRet)
						cXMLRet += aErroRet[nI] + Chr(10)
					Next
				Endif
			Else
				lRet    := .F.
				cXmlRet := STR0019 //"Erro no parser!"
				Return {lRet, _NoTags(cXmlRet)}
			EndIf
		ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE
			//Faz o parser do XML de retorno em um objeto
			oXML := xmlParser(cXML, "_", @cError, @cWarning)
	
			//Se não houve erros na resposta
			If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
	
				//Verifica se a marca foi informada
				If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
					cMarca := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					lRet := .F.
					cXmlRet := STR0020 //"Erro no retorno. O Product é obrigatório!"
					Return {lRet, _NoTags(cXmlRet)}
				EndIf
	
				//Se não for array
				If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") != "A"
					// Transforma em array
					XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, "_InternalId")
				EndIf
	
				For nI := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId)
					cValInt := ""
					cValExt := ""
	
					//Verifica se o InternalId foi informado
					If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[" + Str(nI) + "]:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Origin:Text)
						cValInt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Origin:Text
					Else
						lRet := .F.
						cXmlRet := STR0021 //"Erro no retorno. O OriginalInternalId é obrigatório!"
						AdpLogEAI(5, "FINI040", cXMLRet, lRet)
						Return {lRet, _NoTags(cXmlRet)}
					EndIf
	
					//Verifica se o código externo foi informado
					If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[" + Str(nI) + "]:_Destination:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Destination:Text)
						cValExt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Destination:Text
					Else
						lRet := .F.
						cXmlRet := STR0022 //"Erro no retorno. O DestinationInternalId é obrigatório!"
						AdpLogEAI(5, "FINI040", cXMLRet, lRet)
						Return {lRet, _NoTags(cXmlRet)}
					EndIf
	
					CFGA070Mnt( cMarca, cAlias, cField, cValExt, cValInt, .F., 1 )
	
					// Envia os valores de InternalId e ExternalId para o Log
					AdpLogEAI(3, "cValInt" + Str(nI) + ": ", cValInt) // InternalId
					AdpLogEAI(3, "cValExt" + Str(nI) + ": ", cValExt) // ExternalId
				Next nI
	
			Else
				//Se não for array
				If Type("oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
					//Transforma em array
					XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
				EndIf
	
				//Percorre o array para obter os erros gerados
				For nI := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
					cError := oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nI]:Text + Chr(10)
				Next nI
	
				lRet := .F.
				cXmlRet := cError
			EndIf
		EndIf

		If __lMetric
			// Metrica de integrações com outros produtos
    		FwCustomMetrics():setSumMetric("Marca_"+Alltrim(cMarca), "financeiro-protheus_qtd-clientes-eai-com-financeiro_total", 1)
		Endif
		
		//Mensagem de saída
	ElseIf cTypeTrans == TRANS_SEND
	
		cValInt := IntTRcExt(, SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)[2]
	
		// Verica operação realizada
		If Inclui
			AdpLogEAI(4, 3)
		ElseIf Altera
			AdpLogEAI(4, 4)
		Else
			AdpLogEAI(4, 5)
		EndIf
	
		If !Inclui .And. !Altera
			cEvent := 'delete'
			CFGA070Mnt(, cAlias, cField,, cValInt, .T.) // excluindo da XXF
		EndIf
	
		cXMLRet := '<BusinessEvent>'
		cXMLRet +=  '<Entity>' + cMessage + '</Entity>'
		cXMLRet +=  '<Event>' + cEvent + '</Event>'
		cXMLRet +=  '<Identification>'
		cXMLRet +=   '<key name="InternalId">' + cValInt + '</key>'
		cXMLRet +=  '</Identification>'
		cXMLRet += '</BusinessEvent>'
		cXMLRet += '<BusinessContent>'
		cXMLRet +=  '<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet +=  '<BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet +=  '<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		cXMLRet +=  '<InternalId>' + cValInt + '</InternalId>'
		If Inclui .or. Altera
			cXMLRet +=  '<DocumentPrefix>' + RTrim(SE1->E1_PREFIXO) + '</DocumentPrefix>'
			cXMLRet +=  '<DocumentNumber>' + RTrim(SE1->E1_NUM) + '</DocumentNumber>'
			cXMLRet +=  '<DocumentParcel>' + RTrim(SE1->E1_PARCELA) + '</DocumentParcel>'
			cXMLRet +=  '<DocumentTypeCode>' + RTrim(SE1->E1_TIPO) + '</DocumentTypeCode>'
			If Empty(SE1->E1_CLIENTE)
				cXMLRet +=  '<CustomerCode/>'
				cXmlRet +=  '<StoreId/>'
				cXmlRet +=  '<CustomerInternalId/>'
			Else
				cXMLRet +=  '<CustomerCode>' + RTrim(SE1->E1_CLIENTE) + '</CustomerCode>'
				cXmlRet +=  '<StoreId>' + RTrim(SE1->E1_LOJA) + '</StoreId>'
				cXmlRet +=  '<CustomerInternalId>' + IntCliExt(,, SE1->E1_CLIENTE, SE1->E1_LOJA, MsgUVer('MATA030', 'CUSTOMERVENDOR'))[2] + '</CustomerInternalId>' //Adapter MATI030
			EndIf
			cXMLRet +=  '<HolderCode>' + AllTrim(SE1->E1_PORTADO) + '</HolderCode>'
			cXMLRet +=  '<AgencyNumber>' + AllTrim(SE1->E1_AGEDEP) + '</AgencyNumber>'
			cXMLRet +=  '<AccountNumber>' + AllTrim(SE1->E1_CONTA) + '</AccountNumber>'
			cXMLRet +=  '<ContractNumber>' + AllTrim(SE1->E1_CONTRAT) + '</ContractNumber>'
			cXMLRet +=  '<OurNumberBanking>' + AllTrim(SE1->E1_NUMBCO) + '</OurNumberBanking>'
			cXMLRet +=  '<IssueDate>' + Transform(DToS(SE1->E1_EMISSAO), "@R 9999-99-99") + '</IssueDate>'
			cXMLRet +=  '<DueDate>' + Transform(DToS(SE1->E1_VENCTO), "@R 9999-99-99") + '</DueDate>'
			cXMLRet +=  '<RealDueDate>' + Transform(DTOS(SE1->E1_VENCREA),"@R 9999-99-99") + '</RealDueDate>'
			cXMLRet +=  '<InterestPercentage>' + AllTrim(Str(SE1->E1_PORCJUR)) + '</InterestPercentage>'
			cXMLRet +=  '<AssessmentValue>' + AllTrim(Str(SE1->E1_VALJUR)) + '</AssessmentValue>'
			cXMLRet +=  '<NetValue>' + cValToChar(SE1->E1_VALOR) + '</NetValue>'
			cXMLRet +=  '<GrossValue>' + cValToChar(SE1->E1_VALOR) + '</GrossValue>'
			If Empty(SE1->E1_MOEDA)
				cXMLRet +=  '<CurrencyCode/>'
				cXmlRet +=  '<CurrencyInternalId/>'
			Else
				cXMLRet +=  '<CurrencyCode>' + PadL(SE1->E1_MOEDA, 2, '0') +'</CurrencyCode>'
				cXmlRet +=  '<CurrencyInternalId>' + IntMoeExt(,, PadL(SE1->E1_MOEDA, 2, '0'), MsgUVer('CTBA140', 'CURRENCY'))[2] + '</CurrencyInternalId>' //Adapter CTBI140
			EndIf
			cXMLRet +=  '<CurrencyRate>' + cValToChar(SE1->E1_TXMOEDA) + '</CurrencyRate>'
	
			cXMLRet +=  '<Taxes>'
			SA1->(DbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA))
			For nI := 1 to Len(aImposto)
				cSE1 := (cE1 + aImposto[nI])
				IF SE1->(FieldPos(cSE1)) > 0 // indica de o imposto existe no localizado ou não. cSE1 é o nome do campo do imposto
					cSE1b := (cBase + aImposto[nI])
					cImpBase := '0.0'
					If nI == 2 .Or. nI == 3
						If AllTrim(SA1->A1_PESSOA) == "J"
							cImposto := aImposto[nI]+"-PJ"
						Elseif AllTrim(SA1->A1_PESSOA) == "F"
							cImposto := aImposto[nI] + "-PF"
						Else
							cImposto := aImposto[nI]
						Endif
					Else
						cImposto:= aImposto[nI]
					Endif
	
					If nI == 4
						cImpBase := CValToChar(SE1->E1_BASECOF)
					ElseIf nI == 2
						cImpBase := IIf(cPaisLoc == "BRA", CValToChar(SE1->E1_BASEIRF), '0.0')
					ElseIf nI == 3
						cImpBase := IIf(cPaisLoc == "BRA", CValToChar(SE1->E1_BASEINS), '0.0')
					Else
						cImpBase := IIf(SE1->(FieldPos(cSE1b)) > 0, CValToChar(SE1->&(cSE1b)), '0.0')
					Endif
					cXMLRet +=   '<Tax CalculationBasis="' + cImpBase +'" CityCode="' + SA1->A1_COD_MUN + '"  CountryCode="' + SA1->A1_PAIS + '" Percentage="0.0" Reason="003" Recalculate="true" ReductionBasedPercent="0.0" StateCode="' + SA1->A1_ESTADO + '" Taxe="' + cImposto + '" Value="' + CValToChar(SE1->&(cSE1)) + '"/>'
				Endif
			Next nI
			cXMLRet +=  '</Taxes>'
	
			If IsIntegTop() //Possui integração com o RM Solum
				aRateio := RatCAR(SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA)
			EndIf
			If empty(aRateio)
				cXMLRet +=  '<ApportionmentDistribution/>'
			Else
				cXMLRet +=  '<ApportionmentDistribution>'
				For nI := 1 To Len(aRateio)
					cXMLRet +=   '<Apportionment>'
					cXMLRet +=    '<CostCenterInternalId/>'
					cXMLRet +=    '<ProjectInternalId>' + IIf(!Empty(AllTrim(aRateio[nI][6])), AllTrim(IntPrjExt(, , aRateio[nI][6])[2]), '') + '</ProjectInternalId>' //Adapter PMSI200
					cXMLRet +=    '<TaskInternalId>' + IIf(!Empty(AllTrim(aRateio[nI][7])), IntTrfExt(, , aRateio[nI][6], '0001', aRateio[nI][7])[2], '') + '</TaskInternalId>' //Adapter PMSI203
					cXMLRet +=    '<Value>' + cValToChar(IIf(!Empty(aRateio[nI][8]), aRateio[nI][8], 0)) + '</Value>'
					cXMLRet +=    '<Percent>' + cValToChar(IIf(!Empty(aRateio[nI][5]), aRateio[nI][5], 0)) + '</Percent>'
					cXMLRet +=   '</Apportionment>'
				Next nI
				cXMLRet +=  '</ApportionmentDistribution>'
			Endif
	
			cXMLRet +=  '<Observation>' + _NoTags(AllTrim(SE1->E1_HIST)) + '</Observation>'
			cXMLRet +=  '<Origin>' + AllTrim(SE1->E1_ORIGEM) + '</Origin>'
			If Empty(SE1->E1_NATUREZ)
				cXmlRet +=  '<FinancialNatureInternalId/>'
			Else
				cXmlRet +=  '<FinancialNatureInternalId>' + F10MontInt(, SE1->E1_NATUREZ) + '</FinancialNatureInternalId>' //Adapter FINI010I
			EndIf
	
			// Accounting
			cXMLRet +=  '<Accounting>'
			If empty(SE1->E1_DEBITO)
				cXMLRet +=   '<AccountingAccountDebit/>'
				cXMLRet +=   '<AccountingAccountDebitInternalId/>'
			Else
				cXMLRet +=   '<AccountingAccountDebit>' + RTrim(SE1->E1_DEBITO) + '</AccountingAccountDebit>'
				cXMLRet +=   '<AccountingAccountDebitInternalId>' + cEmpAnt + "|" + xFilial("CT1") + "|" + RTrim(SE1->E1_DEBITO) + '</AccountingAccountDebitInternalId>'
			Endif
			If empty(SE1->E1_CREDIT)
				cXMLRet +=   '<AccountingAccountCredit/>'
				cXMLRet +=   '<AccountingAccountCreditInternalId/>'
			Else
				cXMLRet +=   '<AccountingAccountCredit>' + RTrim(SE1->E1_CREDIT) + '</AccountingAccountCredit>'
				cXMLRet +=   '<AccountingAccountCreditInternalId>' + cEmpAnt + "|" + xFilial("CT1") + "|" + RTrim(SE1->E1_CREDIT) + '</AccountingAccountCreditInternalId>'
			Endif
	
			If empty(SE1->E1_CCD)
				cXMLRet +=   '<CostCenterDebit/>'
				cXMLRet +=   '<CostCenterDebitInternalId/>'
			Else
				cXMLRet +=   '<CostCenterDebit>' + RTrim(SE1->E1_CCD) + '</CostCenterDebit>'
				cXMLRet +=   '<CostCenterDebitInternalId>' + IntCusExt(,, SE1->E1_CCD)[2] + '</CostCenterDebitInternalId>'
			Endif
			If empty(SE1->E1_CCC)
				cXMLRet +=   '<CostCenterCredit/>'
				cXMLRet +=   '<CostCenterCreditInternalId/>'
			Else
				cXMLRet +=   '<CostCenterCredit>' + RTrim(SE1->E1_CCC) + '</CostCenterCredit>'
				cXMLRet +=   '<CostCenterCreditInternalId>' + IntCusExt(,, SE1->E1_CCC)[2] + '</CostCenterCreditInternalId>'
			Endif
	
			If empty(SE1->E1_ITEMD)
				cXMLRet +=   '<AccountingItemDebit/>'
				cXMLRet +=   '<AccountingItemDebitInternalId/>'
			Else
				cXMLRet +=   '<AccountingItemDebit>' + RTrim(SE1->E1_ITEMD) + '</AccountingItemDebit>'
				cXMLRet +=   '<AccountingItemDebitInternalId>' + cEmpAnt + "|" + xFilial("CTD") + "|" + RTrim(SE1->E1_ITEMD) + '</AccountingItemDebitInternalId>'
			Endif
			If empty(SE1->E1_ITEMC)
				cXMLRet +=   '<AccountingItemCredit/>'
				cXMLRet +=   '<AccountingItemCreditInternalId/>'
			Else
				cXMLRet +=   '<AccountingItemCredit>' + RTrim(SE1->E1_ITEMC) + '</AccountingItemCredit>'
				cXMLRet +=   '<AccountingItemCreditInternalId>' + cEmpAnt + "|" + xFilial("CTD") + "|" + RTrim(SE1->E1_ITEMC) + '</AccountingItemCreditInternalId>'
			Endif
	
			If empty(SE1->E1_CLVLDB)
				cXMLRet +=   '<ClassValueDebit/>'
				cXMLRet +=   '<ClassValueDebitInternalId/>'
			Else
				cXMLRet +=   '<ClassValueDebit>' + RTrim(SE1->E1_CLVLDB) + '</ClassValueDebit>'
				cXMLRet +=   '<ClassValueDebitInternalId>' + cEmpAnt + "|" + xFilial("CTH") + "|" + RTrim(SE1->E1_CLVLDB) + '</ClassValueDebitInternalId>'
			Endif
			If empty(SE1->E1_CLVLCR)
				cXMLRet +=   '<ClassValueCredit/>'
				cXMLRet +=   '<ClassValueCreditInternalId/>'
			Else
				cXMLRet +=   '<ClassValueCredit>' + RTrim(SE1->E1_CLVLCR) + '</ClassValueCredit>'
				cXMLRet +=   '<ClassValueCreditInternalId>' + cEmpAnt + "|" + xFilial("CTH") + "|" + RTrim(SE1->E1_CLVLCR) + '</ClassValueCreditInternalId>'
			Endif
	
			If !lEntCtb05 .or. empty(SE1->E1_EC05DB)
				cXMLRet +=   '<AccountingEntity5Debit/>'
				cXMLRet +=   '<AccountingEntity5DebitInternalId/>'
			Else
				cXMLRet +=   '<AccountingEntity5Debit>' + RTrim(SE1->E1_EC05DB) + '</AccountingEntity5Debit>'
				cXMLRet +=   '<AccountingEntity5DebitInternalId>' + IntGerExt(,, "05", SE1->E1_EC05DB)[2] + '</AccountingEntity5DebitInternalId>'
			Endif
			If !lEntCtb05 .or. empty(SE1->E1_EC05CR)
				cXMLRet +=   '<AccountingEntity5Credit/>'
				cXMLRet +=   '<AccountingEntity5CreditInternalId/>'
			Else
				cXMLRet +=   '<AccountingEntity5Credit>' + RTrim(SE1->E1_EC05CR) + '</AccountingEntity5Credit>'
				cXMLRet +=   '<AccountingEntity5CreditInternalId>' + IntGerExt(,, "05", SE1->E1_EC05CR)[2] + '</AccountingEntity5CreditInternalId>'
			Endif
	
			If !lEntCtb06 .or. empty(SE1->E1_EC06DB)
				cXMLRet +=   '<AccountingEntity6Debit/>'
				cXMLRet +=   '<AccountingEntity6DebitInternalId/>'
			Else
				cXMLRet +=   '<AccountingEntity6Debit>' + RTrim(SE1->E1_EC06DB) + '</AccountingEntity6Debit>'
				cXMLRet +=   '<AccountingEntity6DebitInternalId>' + IntGerExt(,, "06", SE1->E1_EC06DB)[2] + '</AccountingEntity6DebitInternalId>'
			Endif
			If !lEntCtb06 .or. empty(SE1->E1_EC06CR)
				cXMLRet +=   '<AccountingEntity6Credit/>'
				cXMLRet +=   '<AccountingEntity6CreditInternalId/>'
			Else
				cXMLRet +=   '<AccountingEntity6Credit>' + RTrim(SE1->E1_EC06CR) + '</AccountingEntity6Credit>'
				cXMLRet +=   '<AccountingEntity6CreditInternalId>' + IntGerExt(,, "06", SE1->E1_EC06CR)[2] + '</AccountingEntity6CreditInternalId>'
			Endif
	
			If !lEntCtb07 .or. empty(SE1->E1_EC07DB)
				cXMLRet +=   '<AccountingEntity7Debit/>'
				cXMLRet +=   '<AccountingEntity7DebitInternalId/>'
			Else
				cXMLRet +=   '<AccountingEntity7Debit>' + RTrim(SE1->E1_EC07DB) + '</AccountingEntity7Debit>'
				cXMLRet +=   '<AccountingEntity7DebitInternalId>' + IntGerExt(,, "07", SE1->E1_EC07DB)[2] + '</AccountingEntity7DebitInternalId>'
			Endif
			If !lEntCtb07 .or. empty(SE1->E1_EC07CR)
				cXMLRet +=   '<AccountingEntity7Credit/>'
				cXMLRet +=   '<AccountingEntity7CreditInternalId/>'
			Else
				cXMLRet +=   '<AccountingEntity7Credit>' + RTrim(SE1->E1_EC07CR) + '</AccountingEntity7Credit>'
				cXMLRet +=   '<AccountingEntity7CreditInternalId>' + IntGerExt(,, "07", SE1->E1_EC07CR)[2] + '</AccountingEntity7CreditInternalId>'
			Endif
	
			If !lEntCtb08 .or. empty(SE1->E1_EC08DB)
				cXMLRet +=   '<AccountingEntity8Debit/>'
				cXMLRet +=   '<AccountingEntity8DebitInternalId/>'
			Else
				cXMLRet +=   '<AccountingEntity8Debit>' + RTrim(SE1->E1_EC08DB) + '</AccountingEntity8Debit>'
				cXMLRet +=   '<AccountingEntity8DebitInternalId>' + IntGerExt(,, "08", SE1->E1_EC08DB)[2] + '</AccountingEntity8DebitInternalId>'
			Endif
			If !lEntCtb08 .or. empty(SE1->E1_EC08CR)
				cXMLRet +=   '<AccountingEntity8Credit/>'
				cXMLRet +=   '<AccountingEntity8CreditInternalId/>'
			Else
				cXMLRet +=   '<AccountingEntity8Credit>' + RTrim(SE1->E1_EC08CR) + '</AccountingEntity8Credit>'
				cXMLRet +=   '<AccountingEntity8CreditInternalId>' + IntGerExt(,, "08", SE1->E1_EC08CR)[2] + '</AccountingEntity8CreditInternalId>'
			Endif
	
			If !lEntCtb09 .or. empty(SE1->E1_EC09DB)
				cXMLRet +=   '<AccountingEntity9Debit/>'
				cXMLRet +=   '<AccountingEntity9DebitInternalId/>'
			Else
				cXMLRet +=   '<AccountingEntity9Debit>' + RTrim(SE1->E1_EC09DB) + '</AccountingEntity9Debit>'
				cXMLRet +=   '<AccountingEntity9DebitInternalId>' + IntGerExt(,, "09", SE1->E1_EC09DB)[2] + '</AccountingEntity9DebitInternalId>'
			Endif
			If !lEntCtb09 .or. empty(SE1->E1_EC09CR)
				cXMLRet +=   '<AccountingEntity9Credit/>'
				cXMLRet +=   '<AccountingEntity9CreditInternalId/>'
			Else
				cXMLRet +=   '<AccountingEntity9Credit>' + RTrim(SE1->E1_EC09CR) + '</AccountingEntity9Credit>'
				cXMLRet +=   '<AccountingEntity9CreditInternalId>' + IntGerExt(,, "09", SE1->E1_EC09CR)[2] + '</AccountingEntity9CreditInternalId>'
			Endif
	
			cXMLRet +=  '</Accounting>'
	
			//Other
			cXMLRet +=  '<Other>'
			cXMLRet +=   '<AcademicRecord>' + AllTrim(SE1->E1_NUMRA) + '</AcademicRecord>'
			cXMLRet +=   '<AcademicPeriod>' + AllTrim(SE1->E1_PERLET) + '</AcademicPeriod>'
			cXMLRet +=   '<AppliedMatrix>' + AllTrim(Str(SE1->E1_IDAPLIC)) + '</AppliedMatrix>'
			cXMLRet +=   '<ItemInternalId>' + AllTrim(SE1->E1_PRODUTO) + '</ItemInternalId>'
			cXMLRet +=   '<Class>' + AllTrim(SE1->E1_TURMA) + '</Class>'
			If lCposVA .And. lV2005
				cXMLRet +=   '<HotelAccountCode>' + AllTrim(SE1->E1_CONHTL) + '</HotelAccountCode>'
				cXMLRet +=   '<HotelAccountType>' + AllTrim(SE1->E1_TCONHTL) + '</HotelAccountType>'
			EndIf
			cXMLRet +=  '</Other>'
	
			// Valores acessórios.
			cFK7Chv := SE1->(E1_FILIAL + '|' + E1_PREFIXO + '|' + E1_NUM + '|' + E1_PARCELA + '|' + E1_TIPO + '|' + E1_CLIENTE + '|' + E1_LOJA)
			cIdDoc  := FINBuscaFK7(cFK7Chv, "SE1")
			FKD->(dbSetOrder(2))  // FKD_FILIAL, FKD_IDDOC, FKD_CODIGO.
			If FKD->(dbSeek(xFilial() + cIdDoc, .F.))
				cXMLRet += '<ListOfComplementaryValues>'
				Do While FKD->(!eof() .and. FKD_FILIAL + FKD_IDDOC == xFilial() + cIdDoc)
					cXMLRet += ' <ComplementaryValue>'
					cXMLRet += '  <ComplementaryValueInternalId>' + F035MntInt(nil, FKD->FKD_CODIGO) + '</ComplementaryValueInternalId>'
					cXMLRet += '  <InformedValue>' + cValToChar(FKD->FKD_VALOR) + '</InformedValue>'
					cXMLRet += ' </ComplementaryValue>'
					FKD->(dbSkip())
				EndDo
				cXMLRet += '</ListOfComplementaryValues>'
			Else
				cXMLRet += '<ListOfComplementaryValues/>'
			Endif
		Endif
	
		cXMLRet += '</BusinessContent>'
	EndIf
	
	AdpLogEAI(5, "FINI040", cXMLRet, lRet)
	dDataBase := dDataAux
	
Return {lRet, cXmlRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} RatCAR
Recebe a chave de busca do Titulo à Receber e monta o rateio.

@author  Leandro Luiz da Cruz
@version P11
@since   18/04/2013

@return aResult
/*/
//-------------------------------------------------------------------
Static Function RatCAR(cChave)

	Local aResult  := {}
	Local aPrjtTrf := {}
	Local aCntrCst := {}
	Local nI       := 0
	Local aAreaAnt := GetArea()

	dbSelectArea("AFT")
	AFT->(dbSetOrder(2)) // AFT_FILIAL+AFT_PREFIX+AFT_NUM+AFT_PARCEL+AFT_TIPO+AFT_CLIENT+AFT_LOJA+AFT_PROJET+AFT_REVISA+AFT_TAREFA

	//Povoa o array de Projeto
	If AFT->(dbSeek(cChave))
		While AFT->(!Eof()) .And. cChave == AFT->AFT_FILIAL + AFT->AFT_PREFIX + AFT->AFT_NUM + AFT->AFT_PARCEL + AFT->AFT_TIPO + AFT->AFT_CLIENT + AFT->AFT_LOJA
			aAdd(aPrjtTrf, Array(4))
			nI++
			aPrjtTrf[nI][1] := AFT->AFT_PROJET
			aPrjtTrf[nI][2] := AFT->AFT_REVISA
			APrjtTrf[nI][3] := AFT->AFT_TAREFA
			APrjtTrf[nI][4] := AFT->AFT_VALOR1
			AFT->(dbSkip())
		EndDo
	EndIf

	aResult := IntRatPrjCC(aCntrCst, aPrjtTrf)

	RestArea(aAreaAnt)
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntTRcInt
Recebe um InternalID e retorna o código do Título a Receber.

@param   cInternalID InternalID recebido na mensagem.
@param   cRefer      Produto que enviou a mensagem
@param   cVersao     Versão da mensagem única (Default 2.000)

@author  Leandro Luiz da Cruz
@version P11
@since   15/07/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
lógica indicando se o registro foi encontrado no de/para.
No segundo parâmetro uma variável array com a empresa,
filial, prefixo, número do título, parcela e tipo.

@sample  IntTRcInt('01|99') irá retornar
{.T., {'01', '01', 'PHT', '99', '1', '1'}}
/*/
//-------------------------------------------------------------------
Function IntTRcInt(cInternalID, cRefer, cVersao)

	Local   aResult	:= {}
	Local   aTemp	:= {}
	Local   cValInt	:= ''
	Local   cAlias	:= 'SE1'
	Local   cField	:= 'E1_NUM'

	Default cVersao  := '2.000'

	cValInt := CFGA070Int(cRefer, cAlias, cField, cInternalID)

	If Empty(cValInt)
		aAdd(aResult, .F.)
		aAdd(aResult, STR0031  + AllTrim(cInternalID) + STR0032 ) //"Título a receber " " não encontrado no de/para"
	Else
		If AllTrim(cVersao) $ '2.000|2.002|2.003|2.004|2.005|2.006'
			aAdd(aResult, .T.)
			aTemp := Separa(cValInt, '|')
			aAdd(aResult, aTemp)
			aAdd(aResult, cValInt)
		Else
			aAdd(aResult, .F.)
			aAdd(aResult, STR0033 + Chr(10) + STR0034) //"Versão do título a receber não suportada." "As versões suportadas são: 2.000 e 3.000"
		EndIf
	EndIf
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntTRcExt
Monta o InternalID do Título a Receber com o código passado
no parâmetro.

@param   cEmpresa   Código da empresa (Default cEmpAnt)
@param   cFil       Código da Filial (Default xFilial(SE1))
@param   cPrefixo   Prefixo do Título
@param   cNumTit    Número do Título
@param   cParcela   Parcela do Título
@param   cTipo      Tipo do Título
@param   cVersao    Versão da mensagem única (Default 2.000)

@author  Leandro Luiz da Cruz
@version P11
@since   15/07/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
lógica indicando se o registro foi encontrado.
No segundo parâmetro uma variável string com o InternalID
montado.

@sample  IntTRcExt(, , 'PHT', '001', '1', 'RA')
irá retornar {.T., '01|01|PHT|001|1|RA'}
/*/
//-------------------------------------------------------------------
Function IntTRcExt(cEmpresa, cFil, cPrefixo, cNumTit, cParcela, cTipo, cVersao)

	Local   aResult  := {}

	Default cEmpresa := cEmpAnt
	Default cFil     := xFilial('SE1')
	Default cVersao  := '2.000'

	If cVersao = '2.' .or. cVersao = '3.'
		aAdd(aResult, .T.)
		aAdd(aResult, cEmpresa + '|' + RTrim(xFilial('SE1', cFil)) + '|' + RTrim(cPrefixo) + '|' + RTrim(cNumTit) + '|' + RTrim(cParcela) + '|' + RTrim(cTipo))
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, STR0033 + Chr(10) + STR0034) //"Versão do título a receber não suportada." "As versões suportadas são: 2.000 e 3.000"
	EndIf
Return aResult

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
