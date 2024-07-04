#Include 'Protheus.ch'
#Include 'fwAdapterEAI.ch'
#Include 'FINI050.ch'
#INCLUDE "FWLIBVERSION.CH"

Static cMessage  := "AccountPayableDocument"
Static lFI050POS := ExistBlock("FI050POS")
Static __lMetric := .F.

/*/{Protheus.doc} FINI050
Funcao de integracao com o adapter EAI para envio e recebimento do
título a pagar (SE2/AFR/CV4) utilizando o conceito de mensagem unica
(AccountPayableDocument).

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   cTypeTrans    Tipo de transação (Envio/Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Versão da mensagem.
@param   cTransac      Nome da transação.

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   23/02/2013
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
aRet[1] - (boolean) Indica o resultado da execução da função
aRet[2] - (caracter) Mensagem Xml para envio
aRet[3] - (caracter) Nome da transação

@obs     O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
Function FINI050(cXml AS CHARACTER, cTypeTrans AS CHARACTER, cTypeMsg AS CHARACTER,;
                    cVersion AS CHARACTER, cTransac AS CHARACTER, lEAIObj AS LOGICAL) AS ARRAY

    Local aArea   AS ARRAY
    Local lRet    AS LOGICAL
    Local cXmlRet AS CHARACTER
    Local aRet    AS ARRAY

    aArea   := GetArea()
    lRet    := .F.
    cXmlRet := ""
    aRet    := {}

    __lMetric := FwLibVersion() >= "20210517" 

    If (cTypeMsg == EAI_MESSAGE_WHOIS)
        lRet    := .T.
        cXmlRet := '1.000|2.000|2.001|3.000'
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
            cXmlRet := STR0008 // "A versão da mensagem informada não foi implementada!"
        Endif
    Endif

    // Ponto de entrada no final da rotina para tratamento do XML.
    If lFI050POS
        aRet := ExecBlock("FI050POS", .F., .F., {lRet, cXmlRet, cTypeTrans, cTypeMsg, cVersion, cTransac, lEAIObj})
        If ValType(aRet) = "A" .and. len(aRet) > 1
            lRet    := aRet[1]
            cXmlRet := aRet[2]
        Endif
    Endif

    RestArea(aArea)
Return {lRet, cXmlRet, cMessage}

/*/{Protheus.doc} v2000
Implementação do adapter EAI, versões 1.x e 2.x

@author  Leandro Luiz da Cruz
@since   17/04/2013
/*/
Static Function v2000(cXml AS CHARACTER, cTypeTrans AS CHARACTER, cTypeMsg AS CHARACTER, cVersion AS CHARACTER) AS ARRAY

	Local aAux      AS ARRAY
	Local aAuxEv    AS ARRAY
	Local aAuxEz    AS ARRAY
	Local aBcoDef   AS ARRAY
	Local aDePara   AS ARRAY
	Local aErroRet  AS ARRAY
	Local aRatAux   AS ARRAY
	Local aRatCC    AS ARRAY
	Local aRateio   AS ARRAY
	Local aRatEvEz  AS ARRAY
	Local aRatEz    AS ARRAY
	Local aRatPrj   AS ARRAY
	Local aRetPe    AS ARRAY
	Local aTit      AS ARRAY
	Local aValAce   AS ARRAY

	Local cAlias    AS CHARACTER
	Local cError    AS CHARACTER
	Local cEvent    AS CHARACTER
	Local cFAgeDv   AS CHARACTER
	Local cFCtaDv   AS CHARACTER
	Local cField    AS CHARACTER
	Local cFK7Chv   AS CHARACTER
	Local cForAge   AS CHARACTER
	Local cForBco   AS CHARACTER
	Local cForCta   AS CHARACTER
	Local cFornec   AS CHARACTER
	Local cForVer   AS CHARACTER
	Local cIdDoc    AS CHARACTER
	Local cLoja     AS CHARACTER
	Local cMarca    AS CHARACTER
	Local cMoeVer   AS CHARACTER
	Local cNatRat   AS CHARACTER
	Local cNaturez  AS CHARACTER
	Local cNumDoc   AS CHARACTER
	Local cParcela  AS CHARACTER
	Local cPrefixo  AS CHARACTER
	Local cProduct  AS CHARACTER
	Local cRelacao  AS CHARACTER
	Local cTarefa   AS CHARACTER
	Local cTipoDoc  AS CHARACTER
	Local cValExt   AS CHARACTER
	Local cValInt   AS CHARACTER
	Local cWarning  AS CHARACTER
	Local cXmlRet   AS CHARACTER
	Local cTpRatRM  AS CHARACTER

	Local dVenc     AS DATE
	Local dVencReal AS DATE

	Local lRatNat   AS LOGICAL
	Local lRet      AS LOGICAL

	Local nCont     AS NUMERIC
	Local nCount    AS NUMERIC
	Local nI        AS NUMERIC
	Local nOpcx     AS NUMERIC
	Local nTamDoc   AS NUMERIC
	Local nValAce   AS NUMERIC
	Local nDecPerc	AS NUMERIC

	Private oXml           AS OBJECT
	Private oXmlAux        AS OBJECT
	Private lMsErroAuto    AS LOGICAL
	Private lAutoErrNoFile AS LOGICAL

	aAux      := {}
	aAuxEv    := {}
	aAuxEz    := {}
	aBcoDef   := {}
	aDePara   := {}
	aErroRet  := {}
	aRatAux   := {}
	aRatCC    := {}
	aRateio   := {}
	aRatEvEz  := {}
	aRatEz    := {}
	aRatPrj   := {}
	aRetPe    := {}
	aTit      := {}
	aValAce   := {}

	cAlias    := "SE2"
	cError    := ""
	cEvent    := 'upsert'
	cFAgeDv   := ""
	cFCtaDv   := ""
	cField    := "E2_NUM"
	cFK7Chv   := ""
	cForAge   := ""
	cForBco   := ""
	cForCta   := ""
	cFornec   := ""
	cForVer   := ""
	cIdDoc    := ""
	cLoja     := ""
	cMarca    := ""
	cMoeVer   := ""
	cNatRat   := ""
	cNaturez  := ""
	cNumDoc   := ""
	cParcela  := ""
	cPrefixo  := ""
	cProduct  := ""
	cRelacao  := ""
	cTarefa   := ""
	cTipoDoc  := ""
	cValExt   := ""
	cValInt   := ""
	cWarning  := ""
	cXmlRet   := ""

	dVenc     := Nil
	dVencReal := Nil

    lRatNat   := GetMv("MV_MULNATP",.F.,.F.) // Identifica se possui multiplas naturezas CP
    cTpRatRM  := GetMv("MV_TPRATRM",.F.,'1') // Indica se Grava Rateio (CV4) ou Não - Uso combinado com MV_MULNATP
	lRet      := .T.

	nCont     := 0
	nCount    := 0
	nI        := 0
	nOpcx     := 0
	nTamDoc   := TamSX3("E2_NUM")[1]
	nValAce   := 0
	nDecPerc	:= TamSX3("CTJ_PERCEN")[2] // Decimal do campo Percentual

	oXml           := Nil
	oXmlAux        := Nil
	lMsErroAuto    := .F.
	lAutoErrNoFile := .T.

	AdpLogEAI(1, "FINI050", cTypeTrans, cTypeMsg, cXML)

	// Mensagem de Entrada
	If cTypeTrans == TRANS_RECEIVE
		If cTypeMsg == EAI_MESSAGE_BUSINESS
			oXml := xmlParser(cXml, "_", @cError, @cWarning)

			If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)  // Verifica se a marca foi informada
				If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
					cMarca := oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					lRet := .F.
					cXmlRet := STR0012 //"Informe a Marca!"
					AdpLogEAI(5, "FINI050", cXMLRet, lRet)
					Return {lRet, cXmlRet}
				EndIf

				//Verifica se o InternalId foi informado
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
					cValExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
				Else
					lRet := .F.
					cXmlRet := STR0013 //"O InternalId é obrigatório!"
					AdpLogEAI(5, "FINI050", cXMLRet, lRet)
					Return {lRet, cXmlRet}
				EndIf

				//Obtém o valor interno da tabela XXF (de/para)
				cValInt := RTrim(CFGA070INT(cMarca, cAlias, cField, cValExt))

				If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
					// Se o registro existe
					If !Empty(cValInt)
						nOpcx := 4 // Update

						cPrefixo := PadR(Separa(cValInt, '|')[3], TamSX3("E2_PREFIXO")[1])
						cNumDoc  := PadR(Separa(cValInt, '|')[4], TamSX3("E2_NUM")[1])
						cParcela := PadR(Separa(cValInt, '|')[5], TamSX3("E2_PARCELA")[1])
						cTipoDoc := PadR(Separa(cValInt, '|')[6], TamSX3("E2_TIPO")[1])
						cFornec  := PadR(Separa(cValInt, '|')[7], TamSX3("E2_FORNECE")[1])
						cLoja    := PadR(Separa(cValInt, '|')[8], TamSX3("E2_LOJA")[1])
					Else
						nOpcx := 3 // Insert

						//Verifica se o Prefíxo do Título foi informado
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentPrefix:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentPrefix:Text)
							cPrefixo := PadR(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentPrefix:Text, TamSx3("E2_PREFIXO")[1])
						ElseIf IsIntegTop() //Possui integração com o RM Solum
							cPrefixo := PadR(GetNewPar("MV_SLMPREP", ""), TamSx3("E2_PREFIXO")[1])
						EndIf

						//Verifica se a parcela do Título foi informado
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentParcel:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentParcel:Text)
							cParcela := PadR(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentParcel:Text, TamSx3("E2_PARCELA")[1])
						EndIf

						//Verifica se o Tipo do Título foi informado
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentTypeCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentTypeCode:Text)
							cTipoDoc := PadR(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentTypeCode:Text, TamSx3("E2_TIPO")[1])
						Else
							lRet := .F.
							cXmlRet := STR0015 //"Informe o Tipo do Título"
							AdpLogEAI(5, "FINI050", cXMLRet, lRet)
							Return {lRet, cXmlRet}
						EndIf

						//Obtém o Código Interno do Fornecedor
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_VendorInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_VendorInternalId:Text)
							cForVer := MsgUVer('MATA020', 'CUSTOMERVENDOR')
							aAux := IntForInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_VendorInternalId:Text, cMarca, cForVer)
							If !aAux[1]
								lRet := aAux[1]
								cXmlRet := aAux[2]
								AdpLogEAI(5, "FINI050", cXMLRet, lRet)
								Return {lRet, cXmlRet}
							Else
								If cForVer = "1."
									cFornec := PadR(aAux[2][1], TamSx3("E2_FORNECE")[1])
									cLoja := PadR(aAux[2][2], TamSx3("E2_LOJA")[1])
								Else
									cFornec := PadR(aAux[2][3], TamSx3("E2_FORNECE")[1])
									cLoja := PadR(aAux[2][4], TamSx3("E2_LOJA")[1])
								Endif
							EndIf
						EndIf

						If IsIntegTop() //Possui integração com o RM Solum
							cNumDoc := GetNumSE2(cPrefixo, cFornec, cLoja)
						Else
							//Pega o inicializador padrão do campo de número do título
							cRelacao := GetSX3Cache("E2_NUM", "X3_RELACAO")

							//Verifica se não possui numeração automática
							If !empty(cRelacao)
								cNumDoc := &cRelacao

								If "GETSXENUM" $ Upper(cRelacao) .AND. __lSx8 .AND. !Empty(cNumDoc)
									ConfirmSX8()
									cNumDoc := ConfDocSXE(cPrefixo , cNumDoc, PadR(cParcela,TamSx3("E2_PARCELA")[1]) ,cFornec , cLoja ,cTipoDoc) // Confirmar doc e verificar se não existe na base							
								EndIf

							Endif

							If empty(cNumDoc)
								//Verifica se o Número do Título foi informado
								If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text)
									cNumDoc := AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text)
								Endif

								// Se não conseguiu um número de documento busca numeração automática.
								If empty(cNumDoc)
									cNumDoc := GetNumSE2(cPrefixo, cFornec, cLoja)
								EndIf
							Endif

							cNumDoc := PadR(cNumDoc, nTamDoc)
						EndIf
					EndIf

					// Verifica se Natureza foi informada
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialNatureInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialNatureInternalId:Text)
						cNatExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialNatureInternalId:Text
						aAux := F10GetInt(cNatExt, cMarca) //Adapter FINI010I

						If aAux[1]
							cNatRat := PadR(aAux[2][3], TamSx3("E2_NATUREZ")[1]) //Natureza para o Rateio
							aAdd(aTit, {"E2_NATUREZ", PadR(aAux[2][3], TamSx3("E2_NATUREZ")[1]), Nil})
						Else
							lRet := .F.
							cXmlRet := STR0016 + " -> " + cNatExt //"Natureza não encontrada no de/para."
							AdpLogEAI(5, "FINI050", cXMLRet, lRet)
							Return {lRet, cXmlRet}
						EndIf
					Else // Utiliza o parâmetro MV_SLMNATP criado para a integração Protheus x RM Solum para
						// as demais integrações quando o FinancialNatureInternalId não for informado
						cNaturez := RTrim(GetNewPar("MV_SLMNATP", ""))						

						If !Empty(cNaturez)
							cNatRat  := PadR(cNaturez, TamSx3("E2_NATUREZ")[1])
							aAdd(aTit, {"E2_NATUREZ", PadR(cNaturez, TamSx3("E2_NATUREZ")[1]), Nil})
						Else
							lRet := .F.
							cXmlRet := STR0017 //"Natureza não informada. Verifique o parâmetro MV_SLMNATP."
							AdpLogEAI(5, "FINI050", cXMLRet, lRet)
							Return {lRet, cXmlRet}
						EndIf
					EndIf

					//Verifica se a emissão do Título foi informada
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_IssueDate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_IssueDate:Text)
						aAdd(aTit, {"E2_EMISSAO", SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_IssueDate:Text,"-","")), Nil})
					EndIf

					//Verifica se o Vencimento do Título foi informado
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DueDate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DueDate:Text)
						dVenc := SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DueDate:Text,"-",""))
						aAdd(aTit, {"E2_VENCTO", dVenc, Nil})
					Else
						lRet := .F.
						cXmlRet := STR0019 //"Informe o Vencimento do Título."
						AdpLogEAI(5, "FINI050", cXMLRet, lRet)
						Return {lRet, cXmlRet}
					EndIf

					//Verifica se o Vencimento real do Título foi informado
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RealDueDate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RealDueDate:Text)
						dVencReal := Datavalida(SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RealDueDate:Text,"-","")))
						aAdd(aTit, {"E2_VENCREA", dVencReal, Nil})
					Else
						dVencReal := Datavalida(SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DueDate:Text,"-","")))
						aAdd(aTit, {"E2_VENCREA", dVencReal, Nil})
					EndIf

					//Verifica se o Valor do Título foi informado
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text") != "U" .And. If(Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text), .F.,;
						Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text) > 0)
						aAdd(aTit, {"E2_VALOR", Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text), Nil})
						aAdd(aTit, {"E2_VLCRUZ", Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text), Nil})						

					Else
						lRet := .F.
						cXmlRet := STR0020 //"Informe o Valor do Título."
						AdpLogEAI(5, "FINI050", cXMLRet, lRet)
						Return {lRet, cXmlRet}
					EndIf

					// Histórico
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Observation:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Observation:Text)
						aAdd(aTit, {"E2_HIST", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Observation:Text, NIL})
					Endif

					// Verifica se a origem foi informada
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Origin:Text)
						aAdd(aTit, {"E2_ORIGEM", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Origin:Text, Nil})
					Else
						aAdd(aTit, {"E2_ORIGEM", "FINI050", Nil})
					EndIf

					// Verifica se a moeda foi informada
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyInternalId:Text)
						cMoeVer := MsgUVer('CTBA140', 'CURRENCY')
						aAux := IntMoeInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyInternalId:Text, cMarca, cMoeVer) //Adapter CTBI140
						If !aAux[1]
							lRet := aAux[1]
							cXmlRet := aAux[2]
							AdpLogEAI(5, "FINI040", cXMLRet, lRet)
							Return {lRet, cXmlRet}
						Else
							If cMoeVer = "1."
								aAdd(aTit, {"E2_MOEDA", Val(aAux[2][2]), Nil})
							Else
								aAdd(aTit, {"E2_MOEDA", Val(aAux[2][3]), Nil})
							Endif
						EndIf
					Else
						aAdd(aTit, {"E2_MOEDA", 1, Nil})
					EndIf

					//Código do Banco do Fornecedor
					If XmlChildEx(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_BANKCODE") <> Nil
						cForBco := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BankCode:Text
						aAdd(aTit, {"E2_FORBCO", cForBco , Nil})
					EndIf
					//Agência Bancária do Fornecedor
					If XmlChildEx(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_BANKBRANCH") <> Nil
						cForAge := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BankBranch:Text
						aAdd(aTit, {"E2_FORAGE", cForAge , Nil})
					EndIf
					//Conta Bancária do Fornecedor
					If XmlChildEx(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_CHECKINGACCOUNTNUMBER") <> Nil
						cForCta := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CheckingAccountNumber:Text
						aAdd(aTit, {"E2_FORCTA", cForCta , Nil})
					EndIf
					//Dígito Verificador da Agência Bancária do Fornecedor
					If XmlChildEx(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_BRANCHKEY") <> Nil
						cFAgeDv := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BranchKey:Text
						aAdd(aTit, {"E2_FAGEDV", cFAgeDv , Nil})
					EndIf
					//Dígito Verificador da Conta Bancária do Fornecedor
					If XmlChildEx(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_CHECKINGACCOUNTNUMBERKEY") <> Nil
						cFCtaDv := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CheckingAccountNumberKey:Text
						aAdd(aTit, {"E2_FCTADV", cFCtaDv , Nil})
					EndIf

					//Busca as informações bancárias do parâmetro MV_CXFIN quando for título antecipado
					If cTipoDoc $ MVPAGANT
						// carrega o banco/agencia/conta padrão do parametro MV_CXFIN
						aBcoDef := xCxFina()

						aAdd(aTit, {"AUTBANCO",   aBcoDef[1], Nil})
						aAdd(aTit, {"AUTAGENCIA", aBcoDef[2], Nil})
						aAdd(aTit, {"AUTCONTA",   aBcoDef[3], Nil})

						SA6->(DbSetOrder(1)) // A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON

						If !(SA6->(dbSeek(xFilial("SA6") + PADR(aBcoDef[1], TamSX3("A6_COD")[1]) + PADR(aBcoDef[2], TamSX3("A6_AGENCIA")[1]) + PADR(aBcoDef[3], TamSX3("A6_NUMCON")[1]))))
							lRet := .F.
							cXmlRet := STR0021 //"Banco não encontrado. Verifique o parâmetro MV_CXFIN."
							AdpLogEAI(5, "FINI050", cXMLRet, lRet)
							Return {lRet, cXmlRet}
						EndIf
					EndIf

					//Possui rateio
					If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ApportionmentDistribution:_Apportionment") != "U"
						//Se não for Array
						If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ApportionmentDistribution:_Apportionment") != "A"
							//Transforma em array
							XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ApportionmentDistribution:_Apportionment,"_Apportionment")
						EndIf

						For nCount := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ApportionmentDistribution:_Apportionment)
							// Atualiza o objeto com a posição atual
							oXmlAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ApportionmentDistribution:_Apportionment[nCount]

							//caso o ratio venha com o valor zerado e com porcentagem 100%
							//será gravado somento o centro de custo sem o ratio
							If Type("oXmlAux:_Value:Text") != "U" .And. oXmlAux:_Value:Text = "0" .AND.;
								Type("oXmlAux:_Percentual:Text") != "U" .And. oXmlAux:_Percentual:Text = "100"

								If Type("oXmlAux:_CostCenterInternalId:Text") != "U" .And. !Empty(oXmlAux:_CostCenterInternalId:Text)
									// Obtém a chave interna do Centro de Custo
									aAux := IntCusInt(oXmlAux:_CostCenterInternalId:Text, cMarca)

									If !aAux[1]
										lRet := .F.
										cXmlRet := aAux[2] + STR0022 + cNumDoc + "." //" Título "
										AdpLogEAI(5, "FINI050", cXMLRet, lRet)
										Return {lRet, cXmlRet}
									EndIf

									aAdd(aTit, {"E2_CCUSTO", aAux[2][3], NIL})
								EndIF
							Else
								// Se possui Centro de Custo Informado
								If Type("oXmlAux:_CostCenterInternalId:Text") != "U" .And. !Empty(oXmlAux:_CostCenterInternalId:Text)
									// Obtém a chave interna do Centro de Custo
									aAux := IntCusInt(oXmlAux:_CostCenterInternalId:Text, cMarca)
									If !aAux[1]
										lRet := .F.
										cXmlRet := aAux[2] + STR0022 + cNumDoc + "." //" Título "
										AdpLogEAI(5, "FINI050", cXMLRet, lRet)
										Return {lRet, cXmlRet}
									EndIf

									// Se possui valor informado
									If Type("oXmlAux:_Value:Text") != "U" .And. !Empty(oXmlAux:_Value:Text)
                                        IF ((cTpRatRM == "1") .OR. EMPTY(lRatNat))
                                            // Se já existe o centro de custo somar os valores
                                            If (nCont := aScan(aRatCC, {|x| RTrim(x[3][2]) == RTrim(aAux[2][3])})) > 0
                                                aRatCC[nCont][2][2] := aRatCC[nCont][2][2] + Val(oXmlAux:_Value:Text)
                                                aRatCC[nCont][1][2] := Round(aRatCC[nCont][2][2] * 100 / Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text), nDecPerc)
                                            Else
                                                aAdd(aRatAux, {"CTJ_PERCEN", Round(Val(oXmlAux:_Value:Text) * 100 / Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text), nDecPerc), Nil})
                                                aAdd(aRatAux, {"CTJ_VALOR",  Val(oXmlAux:_Value:Text),                                                                                            Nil})
                                                aAdd(aRatAux, {"CTJ_CCD",    PadR(aAux[2][3], TamSX3("CTJ_CCD")[1]),                                                                              Nil})
                                                aAdd(aRatAux, {"CTJ_DESC",   "TIT. A PAGAR " + cNumDoc,                                                                                           Nil})
                                                aAdd(aRatCC, aRatAux)
                                                aRatAux := {}
                                            EndIf
                                        ENDIF
										//Inclusão Rateio por centro de Custo/ItemContábil e Classe de Valor a ser utilizado no Rateio MultiNatureza 										 
										If lRatNat
											aAuxEz := {}
											IncluiSEZ(@aAuxEz,cMarca,cNatRat,Val(oXmlAux:_Value:Text),@aErroRet)
											If Len(aAuxEz) > 0 
												aAdd(aRatEz,aAuxEz)
											Endif
										Endif										
									Else
										lRet := .F.
										cXmlRet := STR0023 + cNumDoc //"Valor do rateio inválido para o título "
										AdpLogEAI(5, "FINI050", cXMLRet, lRet)
										Return {lRet, cXmlRet}
									EndIf
								EndIf								

								// Se possui projeto informado
								If Type("oXmlAux:_ProjectInternalId:Text") != "U" .And. !Empty(oXmlAux:_ProjectInternalId:Text)
									// Verifica se o código do projeto é válido (retorno .T. or .F.)
									aAux := IntPrjInt(oXmlAux:_ProjectInternalId:Text, cMarca) //Empresa/Filial/Projeto
									If !aAux[1]
										lRet := .F.
										cXmlRet := aAux[2] + STR0022 + cNumDoc //" Título "
										AdpLogEAI(5, "FINI050", cXMLRet, lRet)
										Return {lRet, cXmlRet}
									Else
										xAux := aAux[2][3]
									EndIf

									If Type("oXmlAux:_TaskInternalId:Text") != "U" .And. !Empty(oXmlAux:_TaskInternalId:Text)
										aAux := IntTrfInt(oXmlAux:_TaskInternalId:Text, cMarca) //Empresa/Filial/Projeto/Revisao/Tarefa
										If !aAux[1]
											lRet := .F.
											cXmlRet := aAux[2] + STR0022 + cNumDoc //" Título "
											AdpLogEAI(5, "FINI050", cXMLRet, lRet)
											Return {lRet, cXmlRet}
										Else
											cTarefa := PadR(aAux[2][5], TamSX3("AFR_TAREFA")[1])
										EndIf
									ElseIf cTipoDoc $ MVPAGANT
										// No Adiantamento não é informada uma tarefa, só Projeto.
										// Aqui se obtém a primeira Tarefa do Projeto informado.
										AF9->(DbSetOrder(5)) // AF9_FILIAL + AF9_PROJET + AF9_TAREFA

										If AF9->(dbSeek(xFilial("AF9") + PadR(xAux, TamSX3("AF9_PROJET")[1])))
											cTarefa := AF9->AF9_TAREFA
										Else
											lRet := .F.
											cXmlRet := STR0024 //"Não existe Tarefa para o Projeto informado."
											AdpLogEAI(5, "FINI050", cXMLRet, lRet)
											Return {lRet, cXmlRet}
										EndIf
									EndIf

									// Se possui valor informado
									If Type("oXmlAux:_Value:Text") != "U" .And. !Empty(oXmlAux:_Value:Text)
										// Se já existe o projeto/tarefa somar os valores
										If (nCont := aScan(aRatPrj, {|x| RTrim(x[1][2]) == RTrim(xAux) .And. RTrim(x[2][2]) == RTrim(cTarefa)})) > 0
											aRatPrj[nCont][4][2] := aRatPrj[nCont][4][2] + Val(oXmlAux:_Value:Text)
										Else
											aAdd(aRatAux, {"AFR_PROJET", PadR(xAux, TamSX3("AF9_PROJET")[1]),  Nil})
											aAdd(aRatAux, {"AFR_TAREFA", cTarefa,                              Nil})
											aAdd(aRatAux, {"AFR_TIPOD",  PadR("0004", TamSx3("AFR_TIPOD")[1]), Nil})
											aAdd(aRatAux, {"AFR_VALOR1", Val(oXmlAux:_Value:Text),             Nil})
											aAdd(aRatAux, {"AFR_REVISA", StrZero(1, TamSX3("AFR_REVISA")[1]),  Nil})
											aAdd(aRatAux, {"AFR_PREFIX", cPrefixo,                             Nil})
											aAdd(aRatAux, {"AFR_NUM",    cNumDoc,                              Nil})
											aAdd(aRatAux, {"AFR_PARCEL", cParcela,                             Nil})
											aAdd(aRatAux, {"AFR_TIPO",   cTipoDoc,                             Nil})
											aAdd(aRatAux, {"AFR_FORNEC", cFornec,                              Nil})
											aAdd(aRatAux, {"AFR_LOJA",   cLoja,                                Nil})
											aAdd(aRatAux, {"AFR_DATA",   dVenc,                                Nil})
											aAdd(aRatAux, {"AFR_VENREA", dVencReal,                            Nil})
											aAdd(aRatPrj, aRatAux)
											aRatAux := {}
										EndIf
									Else
										lRet := .F.
										cXmlRet := STR0023 + cNumDoc //"Valor do rateio inválido para o título "
										AdpLogEAI(5, "FINI050", cXMLRet, lRet)
										Return {lRet, cXmlRet}
									EndIf
								EndIf
							EndIF
						Next nCount

						//Montagem do Rateio MultiNatureza
						If lRatNat .and. Len(aRatEz) > 0
							aAdd(aTit, {"E2_MULTNAT","1", NIL })								
							//Adicionando o vetor da natureza
    						aadd( aAuxEv ,{"EV_NATUREZ" , cNatRat, Nil })//natureza a ser rateada
    						aadd( aAuxEv ,{"EV_VALOR" , Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text), Nil })//valor do rateio na natureza    
							aadd( aAuxEv ,{"EV_PERC" , "100", Nil })//percentual do rateio na natureza							
    						aadd( aAuxEv ,{"EV_RATEICC" , "1", Nil })//indicando que há rateio por centro de custo											
							aadd(aAuxEv,{"AUTRATEICC" , aRatEz, Nil })//recebendo dentro do array da natureza os multiplos centros de custo
    						aAdd(aRatEvEz,aAuxEv)//adicionando a natureza ao rateio de multiplas naturezas
							aAdd(aTit,{"AUTRATEEV",ARatEvEz,Nil})//adicionando ao vetor aCab o vetor do rateio																										
						Endif
					EndIf

					// Valores acessórios.
					aValAce := {}
					If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue") != "U"
						//Se não for Array
						If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue") != "A"
							//Transforma em array
							XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue, "_ComplementaryValue")
						EndIf

						For nCount := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue)
							// Atualiza o objeto com a posição atual
							oXmlAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue[nCount]
							aAux := F035GetInt(oXmlAux:_ComplementaryValueInternalId:Text, cMarca)
							If len(aAux) > 2 .and. aAux[1]
								nValAce := val(oXmlAux:_InformedValue:Text)
								If nValAce <> 0
									aAdd(aValAce, {aAux[2, 3], nValAce})
								Endif
							Else
								lRet := .F.
								cXmlRet := STR0036  // "Valor acessório não encontrado no destino."
								AdpLogEAI(5, "FINI050", cXMLRet, lRet)
								Return {lRet, cXmlRet}
							Endif
						Next nCount
					EndIf

					aAdd(aTit, {"E2_PREFIXO", cPrefixo,  Nil})
					aAdd(aTit, {"E2_NUM",     cNumDoc,   Nil})
					aAdd(aTit, {"E2_PARCELA", cParcela,  Nil})
					aAdd(aTit, {"E2_TIPO",    cTipoDoc,  Nil})
					aAdd(aTit, {"E2_FORNECE", cFornec,   Nil})
					aAdd(aTit, {"E2_LOJA",    cLoja,     Nil})

					// Se há rateio por Centro de Custo
					If !Empty(aRatCC)
						aAdd(aTit, {"E2_RATEIO", "S", Nil})
					EndIf

					// Inclui o array de rateio por Projeto/Tarefa no array do títulos
					If !Empty(aRatPrj)
						aAdd(aTit, {"E2_PROJPMS", "2",     Nil})
						aAdd(aTit, {"AUTRATAFR",  aRatPrj, Nil})
					EndIf
				ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
					// Se o registro existe
					If !Empty(cValInt)
						nOpcx := 5 // Delete
						cPrefixo := PadR(Separa(cValInt, '|')[3], TamSX3("E2_PREFIXO")[1])
						cNumDoc  := PadR(Separa(cValInt, '|')[4], TamSX3("E2_NUM")[1])
						cParcela := PadR(Separa(cValInt, '|')[5], TamSX3("E2_PARCELA")[1])
						cTipoDoc := PadR(Separa(cValInt, '|')[6], TamSX3("E2_TIPO")[1])
						cFornec  := PadR(Separa(cValInt, '|')[7], TamSX3("E2_FORNECE")[1])
						cLoja    := PadR(Separa(cValInt, '|')[8], TamSX3("E2_LOJA")[1])

						aAdd(aTit, {"E2_PREFIXO", cPrefixo, Nil})
						aAdd(aTit, {"E2_NUM",     cNumDoc,  Nil})
						aAdd(aTit, {"E2_PARCELA", cParcela, Nil})
						aAdd(aTit, {"E2_TIPO",    cTipoDoc, Nil})
						aAdd(aTit, {"E2_FORNECE", cFornec,  Nil})
						aAdd(aTit, {"E2_LOJA",    cLoja,    Nil})
					Else
						lRet := .F.
						cXmlRet := STR0025 //"O Título a ser excluído não foi encontrado na base Protheus!"
						AdpLogEAI(5, "FINI050", cXMLRet, lRet)
						Return {lRet, cXmlRet}
					EndIf
				Else
					lRet := .F.
					cXmlRet := STR0026 //"O evento informado é inválido."
					AdpLogEAI(5, "FINI050", cXMLRet, lRet)
					Return {lRet, cXmlRet}
				EndIf

				cValInt := cEmpAnt + '|' + RTrim(xFilial(cAlias)) + '|' + RTrim(cPrefixo) + '|' + RTrim(cNumDoc) + '|' + RTrim(cParcela) + '|' + RTrim(cTipoDoc) + '|' + RTrim(cFornec) + '|' + RTrim(cLoja)
				AdpLogEAI(3, "aTit: ", aTit)
				AdpLogEAI(3, "aRatCC: ", aRatCC)
				AdpLogEAI(3, "cValInt: ", cValInt)
				AdpLogEAI(3, "cValExt: ", cValExt)
				AdpLogEAI(4, nOpcx)

				If ExistBlock("F050E2")
					aRetPe := ExecBlock("F050E2",.F.,.F.,{aTit,aRatCC})
					If ValType(aRetPe) == "A" .And. Len(aRetPe) > 0
						If ValType(aRetPe[1]) == "A"
							aTit := aClone(aRetPe[1])
						EndIf
						If ValType(aRetPe[2]) == "A"
							aRatCC	:= aClone(aRetPe[2])
						EndIf
					EndIf
				EndIf				

				MsExecAuto({|a,b,c,d,e,f,g,h,i,j,k,l| FINA050(a,b,c,d,e,f,g,h,i,j,k,l)}, aTit, nOpcx, nOpcx, /*bExecuta*/, /*aDadosBco*/, /*lExibeLanc*/, /*lOnline*/, aRatCC, /*aTitPrv*/, /*lMsBlQl*/, /*lPaMovBco*/, aValAce)

				// Se houve erros no processamento do MSExecAuto
				If lMsErroAuto
					aErroAuto := GetAutoGRLog()

					cXMLRet := "<![CDATA["
					For nI := 1 To Len(aErroAuto)
						cXMLRet += aErroAuto[nI] + CRLF
					Next nI
					cXMLRet += "]]>"

					lRet := .F.
				Else
					If nOpcx != 5 // Se o evento é diferente de delete
						// Grava o registro na tabela XXF (de/para)
						CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F., 1)

						// Monta o XML de retorno
						cXMLRet := "<ListOfInternalId>"
						cXMLRet +=    "<InternalId>"
						cXMLRet +=       "<Name>AccountPayableDocument</Name>"
						cXMLRet +=       "<Origin>" + cValExt + "</Origin>"
						cXmlRet +=       "<Destination>" + cValInt + "</Destination>"
						cXMLRet +=    "</InternalId>"
						cXMLRet += "</ListOfInternalId>"
					Else
						// Exclui o registro na tabela XXF (de/para)
						CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .T., 1)
					EndIf
				EndIf
			Else
				lRet    := .F.
				cXmlRet := STR0007 //"Erro no parser!"
				Return {lRet, cXmlRet}
			EndIf
		ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE
			//Faz o parser do XML de retorno em um objeto
			oXML := xmlParser(cXML, "_", @cError, @cWarning)

			// Se não houve erros na resposta
			If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
				If Upper(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_Event:Text) == "UPSERT"
					// Verifica se a marca foi informada
					If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
						cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
					Else
						lRet := .F.
						cXmlRet := STR0027 //"Erro no retorno. A tag Product é obrigatória!"
						AdpLogEAI(5, "FINI050", cXMLRet, lRet)
						Return {lRet, cXmlRet}
					EndIf

					// Se não for array
					If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") != "A"
						// Transforma em array
						XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, "_InternalId")
					EndIf

					For nI := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId)
						//Array para armazenar os valores de retorno para gravar no de/para onde:
						//[1] Armazena o Origin
						//[2] Armazena o Destination
						aAdd(aDePara, Array(2))

						//Verifica se o InternalId foi informado
						If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[" + Str(nI) + "]:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Origin:Text)
							aDePara[nI][1] := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Origin:Text
						Else
							lRet := .F.
							cXmlRet := STR0028 //"Erro no retorno. A tag Origin é obrigatório!"
							AdpLogEAI(5, "FINI050", cXMLRet, lRet)
							Return {lRet, cXmlRet}
						EndIf

						//Verifica se o código externo foi informado
						If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[" + Str(nI) + "]:_Destination:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Destination:Text)
							aDePara[nI][2] := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Destination:Text
						Else
							lRet := .F.
							cXmlRet := STR0029 //"Erro no retorno. A tag Destination é obrigatória!"
							AdpLogEAI(5, "FINI050", cXMLRet, lRet)
							Return {lRet, cXmlRet}
						EndIf

						//Envia os valores de InternalId e ExternalId para o Log
						AdpLogEAI(3, "cValInt" + Str(nI) + ": ", aDePara[nI][1]) // InternalId
						AdpLogEAI(3, "cValExt" + Str(nI) + ": ", aDePara[nI][2]) // ExternalId

						nCont++
					Next nI

					//Obtém a mensagem original enviada
					If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
						cXML := oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
					Else
						lRet := .F.
						cXmlRet := STR0030 //"Conteúdo da tag MessageContent inválido ou vazio!"
						AdpLogEAI(5, "FINI050", cXMLRet, lRet)
						Return {lRet, cXmlRet}
					EndIf

					//Faz o parse do XML em um objeto
					oXML := XmlParser(cXML, "_", @cError, @cWarning)

					//Se não houve erros no parse
					If oXML != Nil .And. Empty(cError) .And. Empty(cWarning)
						//Loop para manipular os InternalId no de/para
						For nI := 1 To nCont
							If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
								//Insere / Atualiza o registro na tabela XXF (de/para)
								CFGA070Mnt(cProduct, cAlias, cField, aDePara[nI][2], aDePara[nI][1], .F., 1)
							ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
								//Exclui o registro na tabela XXF (de/para)
								CFGA070Mnt(cProduct, cAlias, cField, aDePara[nI][2], aDePara[nI][1], .T., 1)
							Else
								lRet := .F.
								cXmlRet := STR0031 //"Conteúdo da tag Event do retorno inválido!"
							EndIf
						Next nI
					Else
						lRet := .F.
						cXmlRet := STR0032 //"Erro no parser do retorno!"
						AdpLogEAI(5, "FINI050", cXMLRet, lRet)
						Return {lRet, cXmlRet}
					EndIf
				EndIf
			Else
				//Se não for array
				If Type("oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
					//Transforma em array
					XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
				EndIf

				//Percorre o array para obter os erros gerados
				For nI := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
					cError := oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nI]:Text + CRLF
				Next nI

				lRet := .F.
				cXmlRet := cError
			EndIf
		Endif

		If __lMetric
			cMarca := Iif(Empty(cMarca),cProduct,cMarca)
			// Metrica de integrações com outros produtos
    		FwCustomMetrics():setSumMetric("Marca_"+Alltrim(cMarca), "financeiro-protheus_qtd-clientes-eai-com-financeiro_total", 1)
		Endif

	ElseIf cTypeTrans == TRANS_SEND

		cValInt := cEmpAnt + "|" + RTrim(xFilial('SE2')) + '|' + RTrim(SE2->E2_PREFIXO) + '|' + RTrim(SE2->E2_NUM) + '|' + RTrim(SE2->E2_PARCELA) + '|' + RTrim(SE2->E2_TIPO) + '|' + RTrim(SE2->E2_FORNECE) + '|' + RTrim(SE2->E2_LOJA)

		// Verifica operação realizada
		If Inclui
			AdpLogEAI(4, 3)
		ElseIf Altera
			AdpLogEAI(4, 4)
		Else
			AdpLogEAI(4, 5)
		EndIf

		If !Inclui .And. !Altera
			cEvent := 'delete' //Exclusão
			CFGA070Mnt(, cAlias, cField,, cValInt, .T.) // excluindo da XXF
		EndIf

		cXMLRet := '<BusinessEvent>'
		cXMLRet +=    '<Entity>AccountPayableDocument</Entity>'
		cXMLRet +=    '<Event>' + cEvent + '</Event>'
		cXMLRet +=    '<Identification>'
		cXMLRet +=       '<key name="InternalId">' + cValInt + '</key>'
		cXMLRet +=    '</Identification>'
		cXMLRet += '</BusinessEvent>'
		cXMLRet += '<BusinessContent>'
		cXMLRet +=    '<CompanyId>' + _NoTags(RTrim(cEmpAnt)) + '</CompanyId>'
		cXMLRet +=    '<BranchId>' + _NoTags(RTrim(cFilAnt)) + '</BranchId>'
		cXMLRet +=    '<InternalId>' + cValInt + '</InternalId>'
		cXMLRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		cXMLRet +=    '<DocumentPrefix>' + _NoTags(RTrim(SE2->E2_PREFIXO)) + '</DocumentPrefix>'
		cXMLRet +=    '<DocumentNumber>' + _NoTags(RTrim(SE2->E2_NUM)) + '</DocumentNumber>'
		cXMLRet +=    '<DocumentParcel>' + _NoTags(RTrim(SE2->E2_PARCELA)) + '</DocumentParcel>'
		cXMLRet +=    '<DocumentTypeCode>' + _NoTags(RTrim(SE2->E2_TIPO)) + '</DocumentTypeCode>'
		cXMLRet +=    '<IssueDate>' + Transform(DTOS(SE2->E2_EMISSAO), "@R 9999-99-99") + '</IssueDate>'
		cXMLRet +=    '<DueDate>' + Transform(DTOS(SE2->E2_VENCTO), "@R 9999-99-99") + '</DueDate>'
		cXMLRet +=    '<RealDueDate>' + Transform(DTOS(SE2->E2_VENCREA), "@R 9999-99-99") + '</RealDueDate>'

		If Empty(SE2->E2_FORNECE)
			cXMLRet += '<VendorCode/>'
			cXMLRet += '<StoreId/>'
			cXmlRet += '<VendorInternalId/>'
		Else
			cXMLRet += '<VendorCode>' + _NoTags(RTrim(SE2->E2_FORNECE)) + '</VendorCode>'
			cXMLRet += '<StoreId>' + _NoTags(RTrim(SE2->E2_LOJA)) + '</StoreId>'
			cXmlRet += '<VendorInternalId>' + IntForExt(, , SE2->E2_FORNECE, SE2->E2_LOJA, MsgUVer('MATA020', 'CUSTOMERVENDOR'))[2] + '</VendorInternalId>' // Adapter MATI020
		EndIf
		cXMLRet +=    '<NetValue>' + cValToChar(SE2->E2_VALOR) + '</NetValue>'
		cXMLRet +=    '<GrossValue>' + cValToChar(SE2->E2_VALOR) + '</GrossValue>' // Possui o valor original do titulo
		If Empty(SE2->E2_MOEDA)
			cXMLRet += '<CurrencyCode/>'
			cXmlRet += '<CurrencyInternalId/>'
		Else
			cXMLRet += '<CurrencyCode>' + PadL(SE2->E2_MOEDA, 2, '0') + '</CurrencyCode>'
			cXmlRet += '<CurrencyInternalId>' + IntMoeExt(, , PadL(SE2->E2_MOEDA, 2, '0'), MsgUVer('CTBA140', 'CURRENCY'))[2] + '</CurrencyInternalId>' // Adapter CTBI140
		EndIf
		cXMLRet += '<CurrencyRate>' + cValToChar(SE2->E2_TXMOEDA) + '</CurrencyRate>'

		If Inclui .Or. Altera
			// Integração com o TOTVS Obras e Projetos
			If IsIntegTop() //Possui integração com o RM Solum
				aRateio := RatCAP(SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA)

				If !Empty(aRateio)
					cXMLRet += '<ApportionmentDistribution>'

					For nI := 1 To Len(aRateio)
						cXMLRet +=   '<Apportionment>'
						cXMLRet +=      '<CostCenterCode>' + _NoTags(RTrim(IIf(!Empty(AllTrim(aRateio[nI][1])), aRateio[nI][1], SE2->E2_CCD))) + '</CostCenterCode>'
						cXMLRet +=      '<CostCenterInternalId>' + IIf(!Empty(AllTrim(aRateio[nI][1])), IntCusExt(, , aRateio[nI][1])[2], IntCusExt(, , SE2->E2_CCD)[2]) + '</CostCenterInternalId>' //Adapter CTBI030
						cXMLRet +=      '<ProjectInternalId>' + IIf(!Empty(AllTrim(aRateio[nI][6])), IntPrjExt(, , aRateio[nI][6])[2], '') + '</ProjectInternalId>' //Adapter PMSI200
						cXMLRet +=      '<TaskInternalId>' + IIf(!Empty(AllTrim(aRateio[nI][7])), IntTrfExt(, , aRateio[nI][6], '0001', aRateio[nI][7])[2], '') + '</TaskInternalId>' //Adapter PMSI203
						If !Empty(aRateio[nI][8])
							cXMLRet +=      '<Value>' + cValToChar(aRateio[nI][8]) + '</Value>'
						Else
							cXMLRet +=      '<Value>' + cValToChar(aRateio[nI][5] * SE2->E2_VALOR / 100) + '</Value>'
						EndIf
						cXMLRet +=   '</Apportionment>'
					Next nI

					cXMLRet += '</ApportionmentDistribution>'
				Else
					cXMLRet += '<ApportionmentDistribution/>'
				EndIf
			ElseIF !lRatNat
				//Rateio por Centro de Custo
				CV4->(dbSetOrder(1)) // CV4_FILIAL+DTOS(CV4_DTSEQ)+CV4_SEQUEN
				If CV4->(dbSeek(AllTrim(SE2->E2_ARQRAT)))
					cXmlRet += '<ApportionmentDistribution>'
					While CV4->(!Eof() .And. CV4_FILIAL + DTOS(CV4_DTSEQ) + CV4_SEQUEN == AllTrim(SE2->E2_ARQRAT))
						cXmlRet += '<Apportionment>'
						cXmlRet +=    '<CostCenterCode>' + _NoTags(RTrim(CV4->CV4_CCD)) + '</CostCenterCode>' // Adapter FINI010I
						cXmlRet +=    '<CostCenterInternalId>' + IntCusExt(, , CV4->CV4_CCD)[2] + '</CostCenterInternalId>'
						cXmlRet +=    '<Value>' + cValToChar(CV4->CV4_VALOR) + '</Value>'
						cXmlRet += '</Apportionment>'
						CV4->(DbSkip())
					EndDo
					cXmlRet += '</ApportionmentDistribution>'
				Else
					cXMLRet += '<ApportionmentDistribution/>'
				EndIf
			Else //Rateio MultiNatureza
				DbSelectArea("SEZ")				
				SEZ->(dbSetOrder(5)) // EZ_FILIAL+EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_RECPAG
				If SEZ->(dbSeek(xFilial("SEZ")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA+E2_NATUREZ)+"P"))
					cXmlRet += '<ApportionmentDistribution>'
					While SEZ->(!Eof() .And. SEZ->EZ_FILIAL+SEZ->EZ_PREFIXO+SEZ->EZ_NUM+SEZ->EZ_PARCELA+SEZ->EZ_TIPO+SEZ->EZ_CLIFOR+SEZ->EZ_LOJA+SEZ->EZ_NATUREZ+SEZ->EZ_RECPAG == SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA+E2_NATUREZ)+"P")
						cXmlRet += '<Apportionment>'
						cXmlRet +=    '<CostCenterCode>' + _NoTags(RTrim(SEZ->EZ_CCUSTO)) + '</CostCenterCode>' // Adapter FINI010I
						cXmlRet +=    '<CostCenterInternalId>' + IntCusExt(, , SEZ->EZ_CCUSTO)[2] + '</CostCenterInternalId>'
						cXmlRet +=    '<Value>' + cValToChar(SEZ->EZ_VALOR) + '</Value>'
						If !Empty(SEZ->EZ_ITEMCTA)
							cXmlRet +=    '<AccountingItemCode>' + _NoTags(RTrim(SEZ->EZ_ITEMCTA)) + '</AccountingItemCode>'          
         					cXmlRet +=    '<AccountingItemInternalId>'+C040MntInt(,SEZ->EZ_ITEMCTA)+'</AccountingItemInternalId>'          
						Endif
						If !Empty(SEZ->EZ_CLVL)
         					cXmlRet +=    '<ClassValueCode>' + _NoTags(RTrim(SEZ->EZ_CLVL)) + '</ClassValueCode>'          
         					cXmlRet +=    '<ClassValueInternalId>'+C060MntInt(,SEZ->EZ_CLVL)+'</ClassValueInternalId>'
						Endif
						cXmlRet += '</Apportionment>'
						SEZ->(DbSkip())
					EndDo
					cXmlRet += '</ApportionmentDistribution>'
				Else
					cXMLRet += '<ApportionmentDistribution/>'
				EndIf	
			EndIf
		EndIf

		cXMLRet += '<Observation>' + _NoTags(RTrim(SE2->E2_HIST)) + '</Observation>'
		cXMLRet += '<Origin>' + _NoTags(RTrim(SE2->E2_ORIGEM)) + '</Origin>'
		If Empty(SE2->E2_NATUREZ)
			cXmlRet += '<FinancialNatureInternalId/>'
		Else
			cXMLRet += '<FinancialNatureInternalId>' + F10MontInt(, SE2->E2_NATUREZ) + '</FinancialNatureInternalId>' // Adapter FINI010I
		EndIf
		cXMLRet += '<BankCode>' + _NoTags(RTrim(SE2->E2_FORBCO)) + '</BankCode>'
		cXMLRet += '<BankBranch>' + _NoTags(RTrim(SE2->E2_FORAGE)) + '</BankBranch>'
		cXMLRet += '<BranchKey>'+ _NoTags(RTrim(SE2->E2_FAGEDV)) + '</BranchKey>'
		cXMLRet += '<CheckingAccountNumber>'+ _NoTags(RTrim(SE2->E2_FORCTA)) + '</CheckingAccountNumber>'
		cXMLRet += '<CheckingAccountNumberKey>' + _NoTags(RTrim(SE2->E2_FCTADV)) + '</CheckingAccountNumberKey>'

		// Valores acessórios.
		cFK7Chv := SE2->(E2_FILIAL + '|' + E2_PREFIXO + '|' + E2_NUM + '|' + E2_PARCELA + '|' + E2_TIPO + '|' + E2_FORNECE + '|' + E2_LOJA)
		cIdDoc  := FINBuscaFK7(cFK7Chv, "SE2")
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

	AdpLogEAI(5, "FINI050", cXMLRet, lRet)

Return {lRet, cXMLRet}

/*/{Protheus.doc} v3000
Implementação do adapter EAI, versões 3.x.

@author  Felipe Raposo
@since   14/03/2018
/*/
Static Function v3000(cXml AS CHARACTER, cTypeTrans AS CHARACTER, cTypeMsg AS CHARACTER, cVersion AS CHARACTER) AS ARRAY

	Local aAux     AS ARRAY
	Local aAuxEv   AS ARRAY
	LOcal aAuxEz   AS ARRAY
	Local aBcoDef  AS ARRAY
	Local aDePara  AS ARRAY
	Local aErroRet AS ARRAY
	Local aRatAux  AS ARRAY
	Local aRatCC   AS ARRAY
	Local aRateio  AS ARRAY
	Local aRatEvEz AS ARRAY
	Local aRatEz   AS ARRAY
	Local aRatPrj  AS ARRAY
	Local aRetPe   AS ARRAY
	Local aTit     AS ARRAY
	Local aValAce  AS ARRAY

	Local cAlias     AS CHARACTER
	Local cError     AS CHARACTER
	Local cEvent     AS CHARACTER
	Local cFAgeDv    AS CHARACTER
	Local cFCtaDv    AS CHARACTER
	Local cField     AS CHARACTER
	Local cFK7Chv    AS CHARACTER
	Local cForAge    AS CHARACTER
	Local cForBco    AS CHARACTER
	Local cForCta    AS CHARACTER
	Local cFornec    AS CHARACTER
	Local cForVer    AS CHARACTER
	Local cIdDoc     AS CHARACTER
	Local cLoja      AS CHARACTER
	Local cMarca     AS CHARACTER
	Local cMoeVer    AS CHARACTER
	Local cNatRat    AS CHARACTER
	Local cNaturez   AS CHARACTER
	Local cNumDoc    AS CHARACTER
	Local cParcela   AS CHARACTER
	Local cPrefixo   AS CHARACTER
	Local cProduct   AS CHARACTER
	Local cRelacao   AS CHARACTER
	Local cTarefa    AS CHARACTER
	Local cTipoDoc   AS CHARACTER
	Local cValExt    AS CHARACTER
	Local cValExtAcc AS CHARACTER
	Local cValInt    AS CHARACTER
	Local cWarning   AS CHARACTER
	Local cXmlRet    AS CHARACTER
	Local cTpRatRM   AS CHARACTER

	Local dVenc      AS DATE
	Local dVencReal  AS DATE

	Local lEntCtb05  AS LOGICAL
	Local lEntCtb06  AS LOGICAL
	Local lEntCtb07  AS LOGICAL
	Local lEntCtb08  AS LOGICAL
	Local lEntCtb09  AS LOGICAL
	Local lRatNat    AS LOGICAL
	Local lRet       AS LOGICAL

	Local nCont      AS NUMERIC
	Local nCount     AS NUMERIC
	Local nI         AS NUMERIC
	Local nOpcx      AS NUMERIC
	Local nTamDoc    AS NUMERIC
	Local nValAce    AS NUMERIC
	Local nDecPerc	 AS NUMERIC

	Private oXml           AS OBJECT
	Private oXmlAux        AS OBJECT
	Private lMsErroAuto    AS LOGICAL
	Private lAutoErrNoFile AS LOGICAL

	aAux     := {}
	aAuxEv   := {}
	aAuxEz   := {}
	aBcoDef  := {}
	aDePara  := {}
	aErroRet := {}
	aRatAux  := {}
	aRatCC   := {}
	aRateio  := {}
	aRatEvEz := {}
	aRatEz   := {}
	aRatPrj  := {}
	aRetPe   := {}
	aTit     := {}
	aValAce  := {}

	cAlias     := "SE2"
	cError     := ""
	cEvent     := 'upsert'
	cFAgeDv    := ""
	cFCtaDv    := ""
	cField     := "E2_NUM"
	cFK7Chv    := ""
	cForAge    := ""
	cForBco    := ""
	cForCta    := ""
	cFornec    := ""
	cForVer    := ""
	cIdDoc     := ""
	cLoja      := ""
	cMarca     := ""
	cMoeVer    := ""
	cNatRat    := ""
	cNaturez   := ""
	cNumDoc    := ""
	cParcela   := ""
	cPrefixo   := ""
	cProduct   := ""
	cRelacao   := ""
	cTarefa    := ""
	cTipoDoc   := ""
	cValExt    := ""
	cValExtAcc := ""
	cValInt    := ""
	cWarning   := ""
	cXmlRet    := ""

	dVenc      := Nil
	dVencReal  := Nil

	lEntCtb05  := SE2->(ColumnPos("E2_EC05DB") > 0 .and. ColumnPos("E2_EC05CR") > 0)
	lEntCtb06  := SE2->(ColumnPos("E2_EC06DB") > 0 .and. ColumnPos("E2_EC06CR") > 0)
	lEntCtb07  := SE2->(ColumnPos("E2_EC07DB") > 0 .and. ColumnPos("E2_EC07CR") > 0)
	lEntCtb08  := SE2->(ColumnPos("E2_EC08DB") > 0 .and. ColumnPos("E2_EC08CR") > 0)
	lEntCtb09  := SE2->(ColumnPos("E2_EC09DB") > 0 .and. ColumnPos("E2_EC09CR") > 0)

    lRatNat   := GetMv("MV_MULNATP",.F.,.F.) // Identifica se possui multiplas naturezas CP
    cTpRatRM  := GetMv("MV_TPRATRM",.F.,'1') // Indica se Grava Rateio (CV4) ou Não - Uso combinado com MV_MULNATP
	lRet       := .T.

	nCont      := 0
	nCount     := 0
	nI         := 0
	nOpcx      := 0
	nTamDoc    := TamSX3("E2_NUM")[1]
	nValAce    := 0
	nDecPerc   := TamSX3("CTJ_PERCEN")[2] // Decimal do campo Percentual

	oXml           := Nil
	oXmlAux        := Nil
	lMsErroAuto    := .F.
	lAutoErrNoFile := .T.

	AdpLogEAI(1, "FINI050", cTypeTrans, cTypeMsg, cXML)

	// Mensagem de Entrada
	If cTypeTrans == TRANS_RECEIVE
		If cTypeMsg == EAI_MESSAGE_BUSINESS
			oXml := xmlParser(cXml, "_", @cError, @cWarning)

			If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)  // Verifica se a marca foi informada
				If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
					cMarca := oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					lRet := .F.
					cXmlRet := STR0012 //"Informe a Marca!"
					AdpLogEAI(5, "FINI050", cXMLRet, lRet)
					Return {lRet, cXmlRet}
				EndIf

				//Verifica se o InternalId foi informado
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
					cValExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
				Else
					lRet := .F.
					cXmlRet := STR0013 //"O InternalId é obrigatório!"
					AdpLogEAI(5, "FINI050", cXMLRet, lRet)
					Return {lRet, cXmlRet}
				EndIf

				//Obtém o valor interno da tabela XXF (de/para)
				cValInt := RTrim(CFGA070INT(cMarca, cAlias, cField, cValExt))

				If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
					// Se o registro existe
					If !Empty(cValInt)
						nOpcx := 4 // Update

						cPrefixo := PadR(Separa(cValInt, '|')[3], TamSX3("E2_PREFIXO")[1])
						cNumDoc  := PadR(Separa(cValInt, '|')[4], TamSX3("E2_NUM")[1])
						cParcela := PadR(Separa(cValInt, '|')[5], TamSX3("E2_PARCELA")[1])
						cTipoDoc := PadR(Separa(cValInt, '|')[6], TamSX3("E2_TIPO")[1])
						cFornec  := PadR(Separa(cValInt, '|')[7], TamSX3("E2_FORNECE")[1])
						cLoja    := PadR(Separa(cValInt, '|')[8], TamSX3("E2_LOJA")[1])
					Else
						nOpcx := 3 // Insert

						//Verifica se o Prefíxo do Título foi informado
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentPrefix:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentPrefix:Text)
							cPrefixo := PadR(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentPrefix:Text, TamSx3("E2_PREFIXO")[1])
						ElseIf IsIntegTop() //Possui integração com o RM Solum
							cPrefixo := PadR(GetNewPar("MV_SLMPREP", ""), TamSx3("E2_PREFIXO")[1])
						EndIf

						//Verifica se a parcela do Título foi informado
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentParcel:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentParcel:Text)
							cParcela := PadR(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentParcel:Text, TamSx3("E2_PARCELA")[1])
						EndIf

						//Verifica se o Tipo do Título foi informado
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentTypeCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentTypeCode:Text)
							cTipoDoc := PadR(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentTypeCode:Text, TamSx3("E2_TIPO")[1])
						Else
							lRet := .F.
							cXmlRet := STR0015 //"Informe o Tipo do Título"
							AdpLogEAI(5, "FINI050", cXMLRet, lRet)
							Return {lRet, cXmlRet}
						EndIf

						//Obtém o Código Interno do Fornecedor
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_VendorInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_VendorInternalId:Text)
							cForVer := MsgUVer('MATA020', 'CUSTOMERVENDOR')
							aAux := IntForInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_VendorInternalId:Text, cMarca, cForVer)
							If !aAux[1]
								lRet := aAux[1]
								cXmlRet := aAux[2]
								AdpLogEAI(5, "FINI050", cXMLRet, lRet)
								Return {lRet, cXmlRet}
							Else
								If cForVer = "1."
									cFornec := PadR(aAux[2][1], TamSx3("E2_FORNECE")[1])
									cLoja := PadR(aAux[2][2], TamSx3("E2_LOJA")[1])
								Else
									cFornec := PadR(aAux[2][3], TamSx3("E2_FORNECE")[1])
									cLoja := PadR(aAux[2][4], TamSx3("E2_LOJA")[1])
								Endif
							EndIf
						EndIf

						If IsIntegTop() //Possui integração com o RM Solum
							cNumDoc := GetNumSE2(cPrefixo, cFornec, cLoja)
						Else
							//Pega o inicializador padrão do campo de número do título
							cRelacao := GetSX3Cache("E2_NUM", "X3_RELACAO")

							//Verifica se não possui numeração automática
							If !empty(cRelacao)
								cNumDoc := &cRelacao
							Endif

							If empty(cNumDoc)
								//Verifica se o Número do Título foi informado
								If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text)
									cNumDoc := AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text)
								Endif

								// Se não conseguiu um número de documento busca numeração automática.
								If empty(cNumDoc)
									cNumDoc := GetNumSE2(cPrefixo, cFornec, cLoja)
								EndIf
							Endif

							cNumDoc := PadR(cNumDoc, nTamDoc)
						EndIf
					EndIf

					// Verifica se Natureza foi informada
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialNatureInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialNatureInternalId:Text)
						cNatExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialNatureInternalId:Text
						aAux := F10GetInt(cNatExt, cMarca) //Adapter FINI010I

						If aAux[1]
							cNatRat := PadR(aAux[2][3], TamSx3("E2_NATUREZ")[1]) //Natureza para o Rateio MultiNatP
							aAdd(aTit, {"E2_NATUREZ", PadR(aAux[2][3], TamSx3("E2_NATUREZ")[1]), Nil})
						Else
							lRet := .F.
							cXmlRet := STR0016 + " -> " + cNatExt //"Natureza não encontrada no de/para."
							AdpLogEAI(5, "FINI050", cXMLRet, lRet)
							AAdd(aErroRet, cXmlRet)
						EndIf
					Else // Utiliza o parâmetro MV_SLMNATP criado para a integração Protheus x RM Solum para
						// as demais integrações quando o FinancialNatureInternalId não for informado
						cNaturez := RTrim(GetNewPar("MV_SLMNATP", ""))

						If !Empty(cNaturez)
							cNatRat  := PadR(cNaturez, TamSx3("E2_NATUREZ")[1])
							aAdd(aTit, {"E2_NATUREZ", PadR(cNaturez, TamSx3("E2_NATUREZ")[1]), Nil})
						Else
							lRet := .F.
							cXmlRet := STR0017 //"Natureza não informada. Verifique o parâmetro MV_SLMNATP."
							AdpLogEAI(5, "FINI050", cXMLRet, lRet)
							AAdd(aErroRet, cXmlRet)
						EndIf
					EndIf

					//Verifica se a emissão do Título foi informada
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_IssueDate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_IssueDate:Text)
						aAdd(aTit, {"E2_EMISSAO", SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_IssueDate:Text,"-","")), Nil})
					EndIf

					//Verifica se o Vencimento do Título foi informado
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DueDate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DueDate:Text)
						dVenc := SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DueDate:Text,"-",""))
						aAdd(aTit, {"E2_VENCTO", dVenc, Nil})
					Else
						lRet := .F.
						cXmlRet := STR0019 //"Informe o Vencimento do Título."
						AdpLogEAI(5, "FINI050", cXMLRet, lRet)
						AAdd(aErroRet, cXmlRet)
					EndIf

					//Verifica se o Vencimento real do Título foi informado
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RealDueDate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RealDueDate:Text)
						dVencReal := Datavalida(SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RealDueDate:Text,"-","")))
						aAdd(aTit, {"E2_VENCREA", dVencReal, Nil})
					Else
						dVencReal := Datavalida(SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DueDate:Text,"-","")))
						aAdd(aTit, {"E2_VENCREA", dVencReal, Nil})
					EndIf

					//Verifica se o Valor do Título foi informado
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text") != "U" .And. If(Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text), .F.,;
					Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text) > 0)
						aAdd(aTit, {"E2_VALOR", Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text), Nil})
						aAdd(aTit, {"E2_VLCRUZ", Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text), Nil})
					Else
						lRet := .F.
						cXmlRet := STR0020 //"Informe o Valor do Título."
						AdpLogEAI(5, "FINI050", cXMLRet, lRet)
						AAdd(aErroRet, cXmlRet)
					EndIf

					// Histórico
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Observation:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Observation:Text)
						aAdd(aTit, {"E2_HIST", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Observation:Text, NIL})
					Endif

					// Verifica se a origem foi informada
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Origin:Text)
						aAdd(aTit, {"E2_ORIGEM", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Origin:Text, Nil})
					Else
						aAdd(aTit, {"E2_ORIGEM", "FINI050", Nil})
					EndIf

					// Verifica se a moeda foi informada
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyInternalId:Text)
						cMoeVer := MsgUVer('CTBA140', 'CURRENCY')
						aAux := IntMoeInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyInternalId:Text, cMarca, cMoeVer) //Adapter CTBI140
						If !aAux[1]
							lRet := aAux[1]
							cXmlRet := aAux[2]
							AdpLogEAI(5, "FINI040", cXMLRet, lRet)
							AAdd(aErroRet, cXmlRet)
						Else
							If cMoeVer = "1."
								aAdd(aTit, {"E2_MOEDA", Val(aAux[2][2]), Nil})
							Else
								aAdd(aTit, {"E2_MOEDA", Val(aAux[2][3]), Nil})
							Endif
						EndIf
					Else
						aAdd(aTit, {"E2_MOEDA", 1, Nil})
					EndIf

					//Código do Banco do Fornecedor
					If XmlChildEx(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_VENDORBANKCODE") <> Nil
						cForBco := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_VendorBankCode:Text
						aAdd(aTit, {"E2_FORBCO", cForBco , Nil})
					EndIf
					//Agência Bancária do Fornecedor
					If XmlChildEx(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_VENDORBANKBRANCH") <> Nil
						cForAge := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_VendorBankBranch:Text
						aAdd(aTit, {"E2_FORAGE", cForAge , Nil})
					EndIf
					//Dígito Verificador da Agência Bancária do Fornecedor
					If XmlChildEx(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_VENDORBANKBRANCHKEY") <> Nil
						cFAgeDv := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_VendorBankBranchKey:Text
						aAdd(aTit, {"E2_FAGEDV", cFAgeDv , Nil})
					EndIf
					//Conta Bancária do Fornecedor
					If XmlChildEx(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_VENDORCHECKINGACCOUNTNUMBER") <> Nil
						cForCta := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_VendorCheckingAccountNumber:Text
						aAdd(aTit, {"E2_FORCTA", cForCta , Nil})
					EndIf
					//Dígito Verificador da Conta Bancária do Fornecedor
					If XmlChildEx(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_VENDORCHECKINGACCOUNTNUMBERKEY") <> Nil
						cFCtaDv := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_VendorCheckingAccountNumberKey:Text
						aAdd(aTit, {"E2_FCTADV", cFCtaDv , Nil})
					EndIf

					//Busca as informações bancárias do parâmetro MV_CXFIN quando for título antecipado
					If cTipoDoc $ MVPAGANT
						// carrega o banco/agencia/conta padrão do parametro MV_CXFIN
						aBcoDef := xCxFina()

						aAdd(aTit, {"AUTBANCO",   aBcoDef[1], Nil})
						aAdd(aTit, {"AUTAGENCIA", aBcoDef[2], Nil})
						aAdd(aTit, {"AUTCONTA",   aBcoDef[3], Nil})

						SA6->(DbSetOrder(1)) // A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON

						If !(SA6->(dbSeek(xFilial("SA6") + PADR(aBcoDef[1], TamSX3("A6_COD")[1]) + PADR(aBcoDef[2], TamSX3("A6_AGENCIA")[1]) + PADR(aBcoDef[3], TamSX3("A6_NUMCON")[1]))))
							lRet := .F.
							cXmlRet := STR0021 //"Banco não encontrado. Verifique o parâmetro MV_CXFIN."
							AdpLogEAI(5, "FINI050", cXMLRet, lRet)
							AAdd(aErroRet, cXmlRet)
						EndIf
					EndIf

					//Possui rateio
					If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ApportionmentDistribution:_Apportionment") != "U"
						//Se não for Array
						If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ApportionmentDistribution:_Apportionment") != "A"
							//Transforma em array
							XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ApportionmentDistribution:_Apportionment,"_Apportionment")
						EndIf

						For nCount := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ApportionmentDistribution:_Apportionment)
							// Atualiza o objeto com a posição atual
							oXmlAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ApportionmentDistribution:_Apportionment[nCount]

							//caso o ratio venha com o valor zerado e com porcentagem 100%
							//será gravado somento o centro de custo sem o ratio
							if Type("oXmlAux:_Value:Text") != "U" .And. oXmlAux:_Value:Text = "0" .AND.;
								Type("oXmlAux:_Percentual:Text") != "U" .And. oXmlAux:_Percentual:Text = "100"

								If Type("oXmlAux:_CostCenterInternalId:Text") != "U" .And. !Empty(oXmlAux:_CostCenterInternalId:Text)
									// Obtém a chave interna do Centro de Custo
									aAux := IntCusInt(oXmlAux:_CostCenterInternalId:Text, cMarca)

									If !aAux[1]
										lRet := .F.
										cXmlRet := aAux[2] + STR0022 + cNumDoc + "." //" Título "
										AdpLogEAI(5, "FINI050", cXMLRet, lRet)
										AAdd(aErroRet, cXmlRet)
									EndIf

									aAdd(aTit, {"E2_CCUSTO", aAux[2][3], NIL})
								EndIF
							else
								// Se possui Centro de Custo Informado
								If Type("oXmlAux:_CostCenterInternalId:Text") != "U" .And. !Empty(oXmlAux:_CostCenterInternalId:Text)
									// Obtém a chave interna do Centro de Custo
									aAux := IntCusInt(oXmlAux:_CostCenterInternalId:Text, cMarca)
									If !aAux[1]
										lRet := .F.
										cXmlRet := aAux[2] + STR0022 + cNumDoc + "." //" Título "
										AdpLogEAI(5, "FINI050", cXMLRet, lRet)
										AAdd(aErroRet, cXmlRet)
									EndIf

									// Se possui valor informado
									If Type("oXmlAux:_Value:Text") != "U" .And. !Empty(oXmlAux:_Value:Text)
                                        IF ((cTpRatRM == "1") .OR. EMPTY(lRatNat))
                                            // Se já existe o centro de custo somar os valores
                                            If (nCont := aScan(aRatCC, {|x| RTrim(x[3][2]) == RTrim(aAux[2][3])})) > 0
                                                aRatCC[nCont][2][2] := aRatCC[nCont][2][2] + Val(oXmlAux:_Value:Text)
                                                aRatCC[nCont][1][2] := Round(aRatCC[nCont][2][2] * 100 / Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text), nDecPerc)
                                            Else
                                                aAdd(aRatAux, {"CTJ_PERCEN", Round(Val(oXmlAux:_Value:Text) * 100 / Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text), nDecPerc), Nil})
                                                aAdd(aRatAux, {"CTJ_VALOR",  Val(oXmlAux:_Value:Text),                                                                                            Nil})
                                                aAdd(aRatAux, {"CTJ_CCD",    PadR(aAux[2][3], TamSX3("CTJ_CCD")[1]),                                                                              Nil})
                                                aAdd(aRatAux, {"CTJ_DESC",   "TIT. A PAGAR " + cNumDoc,                                                                                           Nil})
                                                aAdd(aRatCC, aRatAux)
                                                aRatAux := {}
                                            EndIf
                                        ENDIF
										//Inclusão Rateio por centro de Custo/ItemContábil e Classe de Valor a ser utilizado no Rateio MultiNatureza 										 
										If lRatNat
											aAuxEz := {}
											IncluiSEZ(@aAuxEz,cMarca,cNatRat,Val(oXmlAux:_Value:Text),@aErroRet)
											If Len(aAuxEz) > 0
												aAdd(aRatEz,aAuxEz)
											Endif
										Endif

									Else
										lRet := .F.
										cXmlRet := STR0023 + cNumDoc //"Valor do rateio inválido para o título "
										AdpLogEAI(5, "FINI050", cXMLRet, lRet)
										AAdd(aErroRet, cXmlRet)
									EndIf
								EndIf								

								// Se possui projeto informado
								If Type("oXmlAux:_ProjectInternalId:Text") != "U" .And. !Empty(oXmlAux:_ProjectInternalId:Text)
									// Verifica se o código do projeto é válido (retorno .T. or .F.)
									aAux := IntPrjInt(oXmlAux:_ProjectInternalId:Text, cMarca) //Empresa/Filial/Projeto
									If !aAux[1]
										lRet := .F.
										cXmlRet := aAux[2] + STR0022 + cNumDoc //" Título "
										AdpLogEAI(5, "FINI050", cXMLRet, lRet)
										AAdd(aErroRet, cXmlRet)
									Else
										xAux := aAux[2][3]
									EndIf

									If Type("oXmlAux:_TaskInternalId:Text") != "U" .And. !Empty(oXmlAux:_TaskInternalId:Text)
										aAux := IntTrfInt(oXmlAux:_TaskInternalId:Text, cMarca) //Empresa/Filial/Projeto/Revisao/Tarefa
										If !aAux[1]
											lRet := .F.
											cXmlRet := aAux[2] + STR0022 + cNumDoc //" Título "
											AdpLogEAI(5, "FINI050", cXMLRet, lRet)
											AAdd(aErroRet, cXmlRet)
										Else
											cTarefa := PadR(aAux[2][5], TamSX3("AFR_TAREFA")[1])
										EndIf
									ElseIf cTipoDoc $ MVPAGANT
										// No Adiantamento não é informada uma tarefa, só Projeto.
										// Aqui se obtém a primeira Tarefa do Projeto informado.
										AF9->(DbSetOrder(5)) // AF9_FILIAL + AF9_PROJET + AF9_TAREFA

										If AF9->(dbSeek(xFilial("AF9") + PadR(xAux, TamSX3("AF9_PROJET")[1])))
											cTarefa := AF9->AF9_TAREFA
										Else
											lRet := .F.
											cXmlRet := STR0024 //"Não existe Tarefa para o Projeto informado."
											AdpLogEAI(5, "FINI050", cXMLRet, lRet)
											AAdd(aErroRet, cXmlRet)
										EndIf
									EndIf

									// Se possui valor informado
									If Type("oXmlAux:_Value:Text") != "U" .And. !Empty(oXmlAux:_Value:Text)
										// Se já existe o projeto/tarefa somar os valores
										If (nCont := aScan(aRatPrj, {|x| RTrim(x[1][2]) == RTrim(xAux) .And. RTrim(x[2][2]) == RTrim(cTarefa)})) > 0
											aRatPrj[nCont][4][2] := aRatPrj[nCont][4][2] + Val(oXmlAux:_Value:Text)
										Else
											aAdd(aRatAux, {"AFR_PROJET", PadR(xAux, TamSX3("AF9_PROJET")[1]),  Nil})
											aAdd(aRatAux, {"AFR_TAREFA", cTarefa,                              Nil})
											aAdd(aRatAux, {"AFR_TIPOD",  PadR("0004", TamSx3("AFR_TIPOD")[1]), Nil})
											aAdd(aRatAux, {"AFR_VALOR1", Val(oXmlAux:_Value:Text),             Nil})
											aAdd(aRatAux, {"AFR_REVISA", StrZero(1, TamSX3("AFR_REVISA")[1]),  Nil})
											aAdd(aRatAux, {"AFR_PREFIX", cPrefixo,                             Nil})
											aAdd(aRatAux, {"AFR_NUM",    cNumDoc,                              Nil})
											aAdd(aRatAux, {"AFR_PARCEL", cParcela,                             Nil})
											aAdd(aRatAux, {"AFR_TIPO",   cTipoDoc,                             Nil})
											aAdd(aRatAux, {"AFR_FORNEC", cFornec,                              Nil})
											aAdd(aRatAux, {"AFR_LOJA",   cLoja,                                Nil})
											aAdd(aRatAux, {"AFR_DATA",   dVenc,                                Nil})
											aAdd(aRatAux, {"AFR_VENREA", dVencReal,                            Nil})
											aAdd(aRatPrj, aRatAux)
											aRatAux := {}
										EndIf
									Else
										lRet := .F.
										cXmlRet := STR0023 + cNumDoc //"Valor do rateio inválido para o título "
										AdpLogEAI(5, "FINI050", cXMLRet, lRet)
										AAdd(aErroRet, cXmlRet)
									EndIf
								EndIf
							EndIF
						Next nCount

						//Rateio Multinatureza
						If lRatNat .and. Len(aAuxEz) > 0
							aAdd(aTit, {"E2_MULTNAT","1", NIL })								
							//Adicionando o vetor da natureza
    						aadd( aAuxEv ,{"EV_NATUREZ" , cNatRat, Nil })//natureza a ser rateada
    						aadd( aAuxEv ,{"EV_VALOR" , Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetValue:Text), Nil })//valor do rateio na natureza    
							aadd( aAuxEv ,{"EV_PERC" , "100", Nil })//percentual do rateio na natureza							
    						aadd( aAuxEv ,{"EV_RATEICC" , "1", Nil })//indicando que há rateio por centro de custo											
							aadd(aAuxEv,{"AUTRATEICC" , aRatEz, Nil })//recebendo dentro do array da natureza os multiplos centros de custo
    						aAdd(aRatEvEz,aAuxEv)//adicionando a natureza ao rateio de multiplas naturezas
							aAdd(aTit,{"AUTRATEEV",ARatEvEz,Nil})//adicionando ao vetor aCab o vetor do rateio																										
						Endif
					EndIf

					// Valores acessórios.
					aValAce := {}
					If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue") != "U"
						//Se não for Array
						If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue") != "A"
							//Transforma em array
							XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue, "_ComplementaryValue")
						EndIf

						For nCount := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue)
							// Atualiza o objeto com a posição atual
							oXmlAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfComplementaryValues:_ComplementaryValue[nCount]
							aAux := F035GetInt(oXmlAux:_ComplementaryValueInternalId:Text, cMarca)
							If len(aAux) > 2 .and. aAux[1]
								nValAce := val(oXmlAux:_InformedValue:Text)
								If nValAce <> 0
									aAdd(aValAce, {aAux[2, 3], nValAce})
								Endif
							Else
								lRet := .F.
								cXmlRet := STR0036  // "Valor acessório não encontrado no destino."
								AdpLogEAI(5, "FINI050", cXMLRet, lRet)
								AAdd(aErroRet, cXmlRet)
							Endif
						Next nCount
					EndIf

					//Entidades Contábeis
					If XmlChildEx( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_ACCOUNTING" ) <> Nil
						// Conta contábil - Débito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingAccountDebitInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingAccountDebitInternalId:Text

							If !(Empty(cValExtAcc))
								cValIntAcc := CFGA070INT(cMarca, "CT1", "CT1_CONTA", cValExtAcc)
								If !Empty(cValIntAcc)
									aAux    := Separa(cValIntAcc, '|')
									aAdd(aTit, {"E2_DEBITO", aAux[3], NIL})
								Else
									lRet := .F.
									aAdd(aErroRet, cValExtAcc + STR0037) // " não encontrado no de/para"
								Endif
							EndIf
						EndIf

						// Conta contábil - Crédito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingAccountCreditInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingAccountCreditInternalId:Text

							If !(Empty(cValExtAcc))
								cValIntAcc := CFGA070INT(cMarca, "CT1", "CT1_CONTA", cValExtAcc)
								If !Empty(cValIntAcc)
									aAux    := Separa(cValIntAcc, '|')
									aAdd(aTit, {"E2_CREDIT", aAux[3], NIL})
								Else
									lRet := .F.
									aAdd(aErroRet, cValExtAcc + STR0037) // " não encontrado no de/para"
								Endif
							EndIf
						EndIf

						// Centro de custo - Débito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_CostCenterDebitInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_CostCenterDebitInternalId:Text

							If !(Empty(cValExtAcc))
								aAuxRet := IntCusInt(cValExtAcc, cMarca)
								If aAuxRet[1]
									aAdd(aTit, {"E2_CCD", aAuxRet[2,3], NIL})
								Else
									lRet := .F.
									aAdd(aErroRet, aAuxRet[2])
								Endif
							EndIf
						EndIf

						// Centro de custo - Crédito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_CostCenterCreditInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_CostCenterCreditInternalId:Text

							If !(Empty(cValExtAcc))
								aAuxRet := IntCusInt(cValExtAcc, cMarca)
								If aAuxRet[1]
									aAdd(aTit, {"E2_CCC", aAuxRet[2,3], NIL})
								Else
									lRet := .F.
									aAdd(aErroRet, aAuxRet[2])
								Endif
							EndIf
						EndIf

						// Item contábil - Débito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingItemDebitInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingItemDebitInternalId:Text

							If !(Empty(cValExtAcc))
								aAuxRet := C040GetInt(cValExtAcc, cMarca)
								If aAuxRet[1]
									aAdd(aTit, {"E2_ITEMD", aAuxRet[2,3], NIL})
								Else
									lRet := .F.
									aAdd(aErroRet, aAuxRet[2])
								Endif
							EndIf
						EndIf

						// Item contábil - Crédito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingItemCreditInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingItemCreditInternalId:Text

							If !(Empty(cValExtAcc))
								aAuxRet := C040GetInt(cValExtAcc, cMarca)
								If aAuxRet[1]
									aAdd(aTit, {"E2_ITEMC", aAuxRet[2,3], NIL})
								Else
									lRet := .F.
									aAdd(aErroRet, aAuxRet[2])
								Endif
							EndIf
						EndIf

						// Classe de valor - Débito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_ClassValueDebitInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_ClassValueDebitInternalId:Text

							If !(Empty(cValExtAcc))
								aAuxRet := C060GetInt(cValExtAcc, cMarca)
								If aAuxRet[1]
									aAdd(aTit, {"E2_CLVLDB", aAuxRet[2,3], NIL})
								Else
									lRet := .F.
									aAdd(aErroRet, aAuxRet[2])
								Endif
							EndIf
						EndIf

						// Classe de valor - Crédito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_ClassValueCreditInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_ClassValueCreditInternalId:Text

							If !(Empty(cValExtAcc))
								aAuxRet := C060GetInt(cValExtAcc, cMarca)
								If aAuxRet[1]
									aAdd(aTit, {"E2_CLVLCR", aAuxRet[2,3], NIL})
								Else
									lRet := .F.
									aAdd(aErroRet, aAuxRet[2])
								Endif
							EndIf
						EndIf

						// Entidade contábil 5 - Débito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity5DebitInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity5DebitInternalId:Text

							If !(Empty(cValExtAcc))
								aAuxRet := IntGerInt(cValExtAcc, cMarca)
								If aAuxRet[1]
									aAdd(aTit, {"E2_EC05DB", aAuxRet[2,4], NIL})
								Else
									lRet := .F.
									aAdd(aErroRet, aAuxRet[2])
								Endif
							EndIf
						EndIf

						// Entidade contábil 5 - Crédito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity5CreditInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity5CreditInternalId:Text

							If !(Empty(cValExtAcc))
								aAuxRet := IntGerInt(cValExtAcc, cMarca)
								If aAuxRet[1]
									aAdd(aTit, {"E2_EC05CR", aAuxRet[2,4], NIL})
								Else
									lRet := .F.
									aAdd(aErroRet, aAuxRet[2])
								Endif
							EndIf
						EndIf

						// Entidade contábil 6 - Débito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity6DebitInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity6DebitInternalId:Text

							If !(Empty(cValExtAcc))
								aAuxRet := IntGerInt(cValExtAcc, cMarca)
								If aAuxRet[1]
									aAdd(aTit, {"E2_EC06DB", aAuxRet[2,4], NIL})
								Else
									lRet := .F.
									aAdd(aErroRet, aAuxRet[2])
								Endif
							EndIf
						EndIf

						// Entidade contábil 6 - Crédito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity6CreditInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity6CreditInternalId:Text

							If !(Empty(cValExtAcc))
								aAuxRet := IntGerInt(cValExtAcc, cMarca)
								If aAuxRet[1]
									aAdd(aTit, {"E2_EC06CR", aAuxRet[2,4], NIL})
								Else
									lRet := .F.
									aAdd(aErroRet, aAuxRet[2])
								Endif
							EndIf
						EndIf

						// Entidade contábil 7 - Débito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity7DebitInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity7DebitInternalId:Text

							If !(Empty(cValExtAcc))
								aAuxRet := IntGerInt(cValExtAcc, cMarca)
								If aAuxRet[1]
									aAdd(aTit, {"E2_EC07DB", aAuxRet[2,4], NIL})
								Else
									lRet := .F.
									aAdd(aErroRet, aAuxRet[2])
								Endif
							EndIf
						EndIf

						// Entidade contábil 7 - Crédito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity7CreditInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity7CreditInternalId:Text

							If !(Empty(cValExtAcc))
								aAuxRet := IntGerInt(cValExtAcc, cMarca)
								If aAuxRet[1]
									aAdd(aTit, {"E2_EC07CR", aAuxRet[2,4], NIL})
								Else
									lRet := .F.
									aAdd(aErroRet, aAuxRet[2])
								Endif
							EndIf
						EndIf

						// Entidade contábil 8 - Débito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity8DebitInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity8DebitInternalId:Text

							If !(Empty(cValExtAcc))
								aAuxRet := IntGerInt(cValExtAcc, cMarca)
								If aAuxRet[1]
									aAdd(aTit, {"E2_EC08DB", aAuxRet[2,4], NIL})
								Else
									lRet := .F.
									aAdd(aErroRet, aAuxRet[2])
								Endif
							EndIf
						EndIf

						// Entidade contábil 8 - Crédito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity8CreditInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity8CreditInternalId:Text

							If !(Empty(cValExtAcc))
								aAuxRet := IntGerInt(cValExtAcc, cMarca)
								If aAuxRet[1]
									aAdd(aTit, {"E2_EC08CR", aAuxRet[2,4], NIL})
								Else
									lRet := .F.
									aAdd(aErroRet, aAuxRet[2])
								Endif
							EndIf
						EndIf

						// Entidade contábil 9 - Débito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity9DebitInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity9DebitInternalId:Text

							If !(Empty(cValExtAcc))
								aAuxRet := IntGerInt(cValExtAcc, cMarca)
								If aAuxRet[1]
									aAdd(aTit, {"E2_EC09DB", aAuxRet[2,4], NIL})
								Else
									lRet := .F.
									aAdd(aErroRet, aAuxRet[2])
								Endif
							EndIf
						EndIf

						// Entidade contábil 9 - Crédito
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity9CreditInternalId:Text") != "U"
							cValExtAcc := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Accounting:_AccountingEntity9CreditInternalId:Text

							If !(Empty(cValExtAcc))
								aAuxRet := IntGerInt(cValExtAcc, cMarca)
								If aAuxRet[1]
									aAdd(aTit, {"E2_EC09CR", aAuxRet[2,4], NIL})
								Else
									lRet := .F.
									aAdd(aErroRet, aAuxRet[2])
								Endif
							EndIf
						EndIf
					EndIf

					aAdd(aTit, {"E2_PREFIXO", cPrefixo,  Nil})
					aAdd(aTit, {"E2_NUM",     cNumDoc,   Nil})
					aAdd(aTit, {"E2_PARCELA", cParcela,  Nil})
					aAdd(aTit, {"E2_TIPO",    cTipoDoc,  Nil})
					aAdd(aTit, {"E2_FORNECE", cFornec,   Nil})
					aAdd(aTit, {"E2_LOJA",    cLoja,     Nil})

					// Se há rateio por Centro de Custo
					If !Empty(aRatCC)
						aAdd(aTit, {"E2_RATEIO", "S", Nil})
					EndIf

					// Inclui o array de rateio por Projeto/Tarefa no array do títulos
					If !Empty(aRatPrj)
						aAdd(aTit, {"E2_PROJPMS", "2",     Nil})
						aAdd(aTit, {"AUTRATAFR",  aRatPrj, Nil})
					EndIf
				ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
					// Se o registro existe
					If !Empty(cValInt)
						nOpcx := 5 // Delete
						cPrefixo := PadR(Separa(cValInt, '|')[3], TamSX3("E2_PREFIXO")[1])
						cNumDoc  := PadR(Separa(cValInt, '|')[4], TamSX3("E2_NUM")[1])
						cParcela := PadR(Separa(cValInt, '|')[5], TamSX3("E2_PARCELA")[1])
						cTipoDoc := PadR(Separa(cValInt, '|')[6], TamSX3("E2_TIPO")[1])
						cFornec  := PadR(Separa(cValInt, '|')[7], TamSX3("E2_FORNECE")[1])
						cLoja    := PadR(Separa(cValInt, '|')[8], TamSX3("E2_LOJA")[1])

						aAdd(aTit, {"E2_PREFIXO", cPrefixo, Nil})
						aAdd(aTit, {"E2_NUM",     cNumDoc,  Nil})
						aAdd(aTit, {"E2_PARCELA", cParcela, Nil})
						aAdd(aTit, {"E2_TIPO",    cTipoDoc, Nil})
						aAdd(aTit, {"E2_FORNECE", cFornec,  Nil})
						aAdd(aTit, {"E2_LOJA",    cLoja,    Nil})
					Else
						lRet := .F.
						cXmlRet := STR0025 //"O Título a ser excluído não foi encontrado na base Protheus!"
						AdpLogEAI(5, "FINI050", cXMLRet, lRet)
						Return {lRet, cXmlRet}
					EndIf
				Else
					lRet := .F.
					cXmlRet := STR0026 //"O evento informado é inválido."
					AdpLogEAI(5, "FINI050", cXMLRet, lRet)
					Return {lRet, cXmlRet}
				EndIf

				If (lRet)
					cValInt := cEmpAnt + '|' + RTrim(xFilial(cAlias)) + '|' + RTrim(cPrefixo) + '|' + RTrim(cNumDoc) + '|' + RTrim(cParcela) + '|' + RTrim(cTipoDoc) + '|' + RTrim(cFornec) + '|' + RTrim(cLoja)
					AdpLogEAI(3, "aTit: ", aTit)
					AdpLogEAI(3, "aRatCC: ", aRatCC)
					AdpLogEAI(3, "cValInt: ", cValInt)
					AdpLogEAI(3, "cValExt: ", cValExt)
					AdpLogEAI(4, nOpcx)

					If ExistBlock("F050E2")
						aRetPe := ExecBlock("F050E2",.F.,.F.,{aTit,aRatCC})
						If ValType(aRetPe) == "A" .And. Len(aRetPe) > 0
							If ValType(aRetPe[1]) == "A"
								aTit := aClone(aRetPe[1])
							EndIf
							If ValType(aRetPe[2]) == "A"
								aRatCC	:= aClone(aRetPe[2])
							EndIf
						EndIf
					EndIf

					MsExecAuto({|a,b,c,d,e,f,g,h,i,j,k,l| FINA050(a,b,c,d,e,f,g,h,i,j,k,l)}, aTit, nOpcx, nOpcx, /*bExecuta*/, /*aDadosBco*/, /*lExibeLanc*/, /*lOnline*/, aRatCC, /*aTitPrv*/, /*lMsBlQl*/, /*lPaMovBco*/, aValAce)

					// Se houve erros no processamento do MSExecAuto
					If lMsErroAuto
						aErroAuto := GetAutoGRLog()

						cXMLRet := "<![CDATA["
						For nI := 1 To Len(aErroAuto)
							cXMLRet += aErroAuto[nI] + CRLF
						Next nI
						cXMLRet += "]]>"

						lRet := .F.
					Else
						If nOpcx != 5 // Se o evento é diferente de delete
							// Grava o registro na tabela XXF (de/para)
							CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F., 1)

							// Monta o XML de retorno
							cXMLRet := "<ListOfInternalId>"
							cXMLRet +=    "<InternalId>"
							cXMLRet +=       "<Name>AccountPayableDocument</Name>"
							cXMLRet +=       "<Origin>" + cValExt + "</Origin>"
							cXmlRet +=       "<Destination>" + cValInt + "</Destination>"
							cXMLRet +=    "</InternalId>"
							cXMLRet += "</ListOfInternalId>"
						Else
							// Exclui o registro na tabela XXF (de/para)
							CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .T., 1)
						EndIf
					EndIf
				Else
					cXMLRet := ""
					For nI := 1 To Len(aErroRet)
						cXMLRet += aErroRet[nI] + Chr(10)
					Next
				EndIf
			Else
				lRet    := .F.
				cXmlRet := STR0007 //"Erro no parser!"
				Return {lRet, cXmlRet}
			EndIf
		ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE
			//Faz o parser do XML de retorno em um objeto
			oXML := xmlParser(cXML, "_", @cError, @cWarning)

			// Se não houve erros na resposta
			If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
				If Upper(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_Event:Text) == "UPSERT"
					// Verifica se a marca foi informada
					If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
						cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
					Else
						lRet := .F.
						cXmlRet := STR0027 //"Erro no retorno. A tag Product é obrigatória!"
						AdpLogEAI(5, "FINI050", cXMLRet, lRet)
						Return {lRet, cXmlRet}
					EndIf

					// Se não for array
					If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") != "A"
						// Transforma em array
						XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, "_InternalId")
					EndIf

					For nI := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId)
						//Array para armazenar os valores de retorno para gravar no de/para onde:
						//[1] Armazena o Origin
						//[2] Armazena o Destination
						aAdd(aDePara, Array(2))

						//Verifica se o InternalId foi informado
						If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[" + Str(nI) + "]:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Origin:Text)
							aDePara[nI][1] := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Origin:Text
						Else
							lRet := .F.
							cXmlRet := STR0028 //"Erro no retorno. A tag Origin é obrigatório!"
							AdpLogEAI(5, "FINI050", cXMLRet, lRet)
							Return {lRet, cXmlRet}
						EndIf

						//Verifica se o código externo foi informado
						If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[" + Str(nI) + "]:_Destination:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Destination:Text)
							aDePara[nI][2] := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Destination:Text
						Else
							lRet := .F.
							cXmlRet := STR0029 //"Erro no retorno. A tag Destination é obrigatória!"
							AdpLogEAI(5, "FINI050", cXMLRet, lRet)
							Return {lRet, cXmlRet}
						EndIf

						//Envia os valores de InternalId e ExternalId para o Log
						AdpLogEAI(3, "cValInt" + Str(nI) + ": ", aDePara[nI][1]) // InternalId
						AdpLogEAI(3, "cValExt" + Str(nI) + ": ", aDePara[nI][2]) // ExternalId

						nCont++
					Next nI

					//Obtém a mensagem original enviada
					If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
						cXML := oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
					Else
						lRet := .F.
						cXmlRet := STR0030 //"Conteúdo da tag MessageContent inválido ou vazio!"
						AdpLogEAI(5, "FINI050", cXMLRet, lRet)
						Return {lRet, cXmlRet}
					EndIf

					//Faz o parse do XML em um objeto
					oXML := XmlParser(cXML, "_", @cError, @cWarning)

					//Se não houve erros no parse
					If oXML != Nil .And. Empty(cError) .And. Empty(cWarning)
						//Loop para manipular os InternalId no de/para
						For nI := 1 To nCont
							If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
								//Insere / Atualiza o registro na tabela XXF (de/para)
								CFGA070Mnt(cProduct, cAlias, cField, aDePara[nI][2], aDePara[nI][1], .F., 1)
							ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
								//Exclui o registro na tabela XXF (de/para)
								CFGA070Mnt(cProduct, cAlias, cField, aDePara[nI][2], aDePara[nI][1], .T., 1)
							Else
								lRet := .F.
								cXmlRet := STR0031 //"Conteúdo da tag Event do retorno inválido!"
							EndIf
						Next nI
					Else
						lRet := .F.
						cXmlRet := STR0032 //"Erro no parser do retorno!"
						AdpLogEAI(5, "FINI050", cXMLRet, lRet)
						Return {lRet, cXmlRet}
					EndIf
				EndIf
			Else
				//Se não for array
				If Type("oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
					//Transforma em array
					XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
				EndIf

				//Percorre o array para obter os erros gerados
				For nI := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
					cError := oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nI]:Text + CRLF
				Next nI

				lRet := .F.
				cXmlRet := cError
			EndIf
		Endif

		If __lMetric
			cMarca := Iif(Empty(cMarca),cProduct,cMarca)
			// Metrica de integrações com outros produtos
    		FwCustomMetrics():setSumMetric("Marca_"+Alltrim(cMarca), "financeiro-protheus_qtd-clientes-eai-com-financeiro_total", 1)
		Endif

	ElseIf cTypeTrans == TRANS_SEND

		cValInt := cEmpAnt + "|" + RTrim(xFilial('SE2')) + '|' + RTrim(SE2->E2_PREFIXO) + '|' + RTrim(SE2->E2_NUM) + '|' + RTrim(SE2->E2_PARCELA) + '|' + RTrim(SE2->E2_TIPO) + '|' + RTrim(SE2->E2_FORNECE) + '|' + RTrim(SE2->E2_LOJA)

		// Verica operação realizada
		If Inclui
			AdpLogEAI(4, 3)
		ElseIf Altera
			AdpLogEAI(4, 4)
		Else
			AdpLogEAI(4, 5)
		EndIf

		If !Inclui .And. !Altera
			cEvent := 'delete' //Exclusão
			CFGA070Mnt(, cAlias, cField,, cValInt, .T.) // excluindo da XXF
		EndIf

		cXMLRet := '<BusinessEvent>'
		cXMLRet +=    '<Entity>AccountPayableDocument</Entity>'
		cXMLRet +=    '<Event>' + cEvent + '</Event>'
		cXMLRet +=    '<Identification>'
		cXMLRet +=       '<key name="InternalId">' + cValInt + '</key>'
		cXMLRet +=    '</Identification>'
		cXMLRet += '</BusinessEvent>'
		cXMLRet += '<BusinessContent>'
		cXMLRet +=    '<CompanyId>' + _NoTags(RTrim(cEmpAnt)) + '</CompanyId>'
		cXMLRet +=    '<BranchId>' + _NoTags(RTrim(cFilAnt)) + '</BranchId>'
		cXMLRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		cXMLRet +=    '<InternalId>' + cValInt + '</InternalId>'
		If Inclui .or. Altera
			cXMLRet +=    '<DocumentPrefix>' + _NoTags(RTrim(SE2->E2_PREFIXO)) + '</DocumentPrefix>'
			cXMLRet +=    '<DocumentNumber>' + _NoTags(RTrim(SE2->E2_NUM)) + '</DocumentNumber>'
			cXMLRet +=    '<DocumentParcel>' + _NoTags(RTrim(SE2->E2_PARCELA)) + '</DocumentParcel>'
			cXMLRet +=    '<DocumentTypeCode>' + _NoTags(RTrim(SE2->E2_TIPO)) + '</DocumentTypeCode>'
			cXMLRet +=    '<IssueDate>' + Transform(DTOS(SE2->E2_EMISSAO), "@R 9999-99-99") + '</IssueDate>'
			cXMLRet +=    '<DueDate>' + Transform(DTOS(SE2->E2_VENCTO), "@R 9999-99-99") + '</DueDate>'
			cXMLRet +=    '<RealDueDate>' + Transform(DTOS(SE2->E2_VENCREA), "@R 9999-99-99") + '</RealDueDate>'

			If Empty(SE2->E2_FORNECE)
				cXMLRet += '<VendorCode/>'
				cXMLRet += '<StoreId/>'
				cXmlRet += '<VendorInternalId/>'
			Else
				cXMLRet += '<VendorCode>' + _NoTags(RTrim(SE2->E2_FORNECE)) + '</VendorCode>'
				cXMLRet += '<StoreId>' + _NoTags(RTrim(SE2->E2_LOJA)) + '</StoreId>'
				cXmlRet += '<VendorInternalId>' + IntForExt(, , SE2->E2_FORNECE, SE2->E2_LOJA, MsgUVer('MATA020', 'CUSTOMERVENDOR'))[2] + '</VendorInternalId>' // Adapter MATI020
			EndIf
			cXMLRet +=    '<NetValue>' + cValToChar(SE2->E2_VALOR) + '</NetValue>'
			cXMLRet +=    '<GrossValue>' + cValToChar(SE2->E2_VALOR) + '</GrossValue>' // Possui o valor original do titulo
			If Empty(SE2->E2_MOEDA)
				cXMLRet += '<CurrencyCode/>'
				cXmlRet += '<CurrencyInternalId/>'
			Else
				cXMLRet += '<CurrencyCode>' + PadL(SE2->E2_MOEDA, 2, '0') + '</CurrencyCode>'
				cXmlRet += '<CurrencyInternalId>' + IntMoeExt(, , PadL(SE2->E2_MOEDA, 2, '0'), MsgUVer('CTBA140', 'CURRENCY'))[2] + '</CurrencyInternalId>' // Adapter CTBI140
			EndIf
			cXMLRet += '<CurrencyRate>' + cValToChar(SE2->E2_TXMOEDA) + '</CurrencyRate>'

			If Inclui .Or. Altera
				// Integração com o TOTVS Obras e Projetos
				If IsIntegTop() //Possui integração com o RM Solum
					aRateio := RatCAP(SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA)

					If !Empty(aRateio)
						cXMLRet += '<ApportionmentDistribution>'

						For nI := 1 To Len(aRateio)
							cXMLRet +=   '<Apportionment>'
							cXMLRet +=      '<CostCenterCode>' + _NoTags(RTrim(IIf(!Empty(AllTrim(aRateio[nI][1])), aRateio[nI][1], SE2->E2_CCD))) + '</CostCenterCode>'
							cXMLRet +=      '<CostCenterInternalId>' + IIf(!Empty(AllTrim(aRateio[nI][1])), IntCusExt(, , aRateio[nI][1])[2], IntCusExt(, , SE2->E2_CCD)[2]) + '</CostCenterInternalId>' //Adapter CTBI030
							cXMLRet +=      '<ProjectInternalId>' + IIf(!Empty(AllTrim(aRateio[nI][6])), IntPrjExt(, , aRateio[nI][6])[2], '') + '</ProjectInternalId>' //Adapter PMSI200
							cXMLRet +=      '<TaskInternalId>' + IIf(!Empty(AllTrim(aRateio[nI][7])), IntTrfExt(, , aRateio[nI][6], '0001', aRateio[nI][7])[2], '') + '</TaskInternalId>' //Adapter PMSI203
							If !Empty(aRateio[nI][8])
								cXMLRet +=      '<Value>' + cValToChar(aRateio[nI][8]) + '</Value>'
							Else
								cXMLRet +=      '<Value>' + cValToChar(aRateio[nI][5] * SE2->E2_VALOR / 100) + '</Value>'
							EndIf
							cXMLRet +=   '</Apportionment>'
						Next nI

						cXMLRet += '</ApportionmentDistribution>'
					Else
						cXMLRet += '<ApportionmentDistribution/>'
					EndIf
				Elseif !lRatNat 
					//Rateio por Centro de Custo
					CV4->(dbSetOrder(1)) // CV4_FILIAL+DTOS(CV4_DTSEQ)+CV4_SEQUEN
					If CV4->(dbSeek(AllTrim(SE2->E2_ARQRAT)))
						cXmlRet += '<ApportionmentDistribution>'
						While CV4->(!Eof() .And. CV4_FILIAL + DTOS(CV4_DTSEQ) + CV4_SEQUEN == AllTrim(SE2->E2_ARQRAT))
							cXmlRet += '<Apportionment>'
							cXmlRet +=    '<CostCenterCode>' + _NoTags(RTrim(CV4->CV4_CCD)) + '</CostCenterCode>' // Adapter FINI010I
							cXmlRet +=    '<CostCenterInternalId>' + IntCusExt(, , CV4->CV4_CCD)[2] + '</CostCenterInternalId>'
							cXmlRet +=    '<Value>' + cValToChar(CV4->CV4_VALOR) + '</Value>'
							cXmlRet += '</Apportionment>'
							CV4->(DbSkip())
						EndDo
						cXmlRet += '</ApportionmentDistribution>'
					Else
						cXMLRet += '<ApportionmentDistribution/>'
					EndIf
				Else
					DbSelectArea("SEZ")
					SEZ->(dbSetOrder(5)) // EZ_FILIAL+EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_RECPAG
					If SEZ->(dbSeek(xFilial("SEZ")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA+E2_NATUREZ)+"P"))
						cXmlRet += '<ApportionmentDistribution>'
						While SEZ->(!Eof() .And. SEZ->EZ_FILIAL+SEZ->EZ_PREFIXO+SEZ->EZ_NUM+SEZ->EZ_PARCELA+SEZ->EZ_TIPO+SEZ->EZ_CLIFOR+SEZ->EZ_LOJA+SEZ->EZ_NATUREZ+SEZ->EZ_RECPAG == SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA+E2_NATUREZ)+"P")
							cXmlRet += '<Apportionment>'
							cXmlRet +=    '<CostCenterCode>' + _NoTags(RTrim(SEZ->EZ_CCUSTO)) + '</CostCenterCode>' // Adapter FINI010I
							cXmlRet +=    '<CostCenterInternalId>' + IntCusExt(, , SEZ->EZ_CCUSTO)[2] + '</CostCenterInternalId>'
							cXmlRet +=    '<Value>' + cValToChar(SEZ->EZ_VALOR) + '</Value>'
							If !Empty(SEZ->EZ_ITEMCTA)
								cXmlRet +=    '<AccountingItemCode>' + _NoTags(RTrim(SEZ->EZ_ITEMCTA)) + '</AccountingItemCode>'          
         						cXmlRet +=    '<AccountingItemInternalId>'+C040MntInt(,SEZ->EZ_ITEMCTA)+'</AccountingItemInternalId>'          
							Endif
							If !Empty(SEZ->EZ_CLVL)
         						cXmlRet +=    '<ClassValueCode>' + _NoTags(RTrim(SEZ->EZ_CLVL)) + '</ClassValueCode>'          
         						cXmlRet +=    '<ClassValueInternalId>'+C060MntInt(,SEZ->EZ_CLVL)+'</ClassValueInternalId>'
							Endif
							cXmlRet += '</Apportionment>'
							SEZ->(DbSkip())
						EndDo
						cXmlRet += '</ApportionmentDistribution>'
					Else
						cXMLRet += '<ApportionmentDistribution/>'
					EndIf					
				EndIf
			EndIf

			cXMLRet += '<Observation>' + _NoTags(RTrim(SE2->E2_HIST)) + '</Observation>'
			cXMLRet += '<Origin>' + _NoTags(RTrim(SE2->E2_ORIGEM)) + '</Origin>'
			If Empty(SE2->E2_NATUREZ)
				cXmlRet += '<FinancialNatureInternalId/>'
			Else
				cXMLRet += '<FinancialNatureInternalId>' + F10MontInt(, SE2->E2_NATUREZ) + '</FinancialNatureInternalId>' // Adapter FINI010I
			EndIf
			cXMLRet += '<VendorBankCode>' + _NoTags(RTrim(SE2->E2_FORBCO)) + '</VendorBankCode>'
			cXMLRet += '<VendorBankBranch>' + _NoTags(RTrim(SE2->E2_FORAGE)) + '</VendorBankBranch>'
			cXMLRet += '<VendorBankBranchKey>'+ _NoTags(RTrim(SE2->E2_FAGEDV)) + '</VendorBankBranchKey>'
			cXMLRet += '<VendorCheckingAccountNumber>'+ _NoTags(RTrim(SE2->E2_FORCTA)) + '</VendorCheckingAccountNumber>'
			cXMLRet += '<VendorCheckingAccountNumberKey>' + _NoTags(RTrim(SE2->E2_FCTADV)) + '</VendorCheckingAccountNumberKey>'

			// Accounting
			cXMLRet +=  '<Accounting>'
			If empty(SE2->E2_DEBITO)
				cXMLRet +=   '<AccountingAccountDebit/>'
				cXMLRet +=   '<AccountingAccountDebitInternalId/>'
			Else
				cXMLRet +=   '<AccountingAccountDebit>' + RTrim(SE2->E2_DEBITO) + '</AccountingAccountDebit>'
				cXMLRet +=   '<AccountingAccountDebitInternalId>' + cEmpAnt + "|" + xFilial("CT1") + "|" + RTrim(SE2->E2_DEBITO) + '</AccountingAccountDebitInternalId>'
			Endif
			If empty(SE2->E2_CREDIT)
				cXMLRet +=   '<AccountingAccountCredit/>'
				cXMLRet +=   '<AccountingAccountCreditInternalId/>'
			Else
				cXMLRet +=   '<AccountingAccountCredit>' + RTrim(SE2->E2_CREDIT) + '</AccountingAccountCredit>'
				cXMLRet +=   '<AccountingAccountCreditInternalId>' + cEmpAnt + "|" + xFilial("CT1") + "|" + RTrim(SE2->E2_CREDIT) + '</AccountingAccountCreditInternalId>'
			Endif

			If empty(SE2->E2_CCD)
				cXMLRet +=   '<CostCenterDebit/>'
				cXMLRet +=   '<CostCenterDebitInternalId/>'
			Else
				cXMLRet +=   '<CostCenterDebit>' + RTrim(SE2->E2_CCD) + '</CostCenterDebit>'
				cXMLRet +=   '<CostCenterDebitInternalId>' + IntCusExt(,, SE2->E2_CCD)[2] + '</CostCenterDebitInternalId>'
			Endif
			If empty(SE2->E2_CCC)
				cXMLRet +=   '<CostCenterCredit/>'
				cXMLRet +=   '<CostCenterCreditInternalId/>'
			Else
				cXMLRet +=   '<CostCenterCredit>' + RTrim(SE2->E2_CCC) + '</CostCenterCredit>'
				cXMLRet +=   '<CostCenterCreditInternalId>' + IntCusExt(,, SE2->E2_CCC)[2] + '</CostCenterCreditInternalId>'
			Endif

			If empty(SE2->E2_ITEMD)
				cXMLRet +=   '<AccountingItemDebit/>'
				cXMLRet +=   '<AccountingItemDebitInternalId/>'
			Else
				cXMLRet +=   '<AccountingItemDebit>' + RTrim(SE2->E2_ITEMD) + '</AccountingItemDebit>'
				cXMLRet +=   '<AccountingItemDebitInternalId>' + cEmpAnt + "|" + xFilial("CTD") + "|" + RTrim(SE2->E2_ITEMD) + '</AccountingItemDebitInternalId>'
			Endif
			If empty(SE2->E2_ITEMC)
				cXMLRet +=   '<AccountingItemCredit/>'
				cXMLRet +=   '<AccountingItemCreditInternalId/>'
			Else
				cXMLRet +=   '<AccountingItemCredit>' + RTrim(SE2->E2_ITEMC) + '</AccountingItemCredit>'
				cXMLRet +=   '<AccountingItemCreditInternalId>' + cEmpAnt + "|" + xFilial("CTD") + "|" + RTrim(SE2->E2_ITEMC) + '</AccountingItemCreditInternalId>'
			Endif

			If empty(SE2->E2_CLVLDB)
				cXMLRet +=   '<ClassValueDebit/>'
				cXMLRet +=   '<ClassValueDebitInternalId/>'
			Else
				cXMLRet +=   '<ClassValueDebit>' + RTrim(SE2->E2_CLVLDB) + '</ClassValueDebit>'
				cXMLRet +=   '<ClassValueDebitInternalId>' + cEmpAnt + "|" + xFilial("CTH") + "|" + RTrim(SE2->E2_CLVLDB) + '</ClassValueDebitInternalId>'
			Endif
			If empty(SE2->E2_CLVLCR)
				cXMLRet +=   '<ClassValueCredit/>'
				cXMLRet +=   '<ClassValueCreditInternalId/>'
			Else
				cXMLRet +=   '<ClassValueCredit>' + RTrim(SE2->E2_CLVLCR) + '</ClassValueCredit>'
				cXMLRet +=   '<ClassValueCreditInternalId>' + cEmpAnt + "|" + xFilial("CTH") + "|" + RTrim(SE2->E2_CLVLCR) + '</ClassValueCreditInternalId>'
			Endif

			If !lEntCtb05 .or. empty(SE2->E2_EC05DB)
				cXMLRet +=   '<AccountingEntity5Debit/>'
				cXMLRet +=   '<AccountingEntity5DebitInternalId/>'
			Else
				cXMLRet +=   '<AccountingEntity5Debit>' + RTrim(SE2->E2_EC05DB) + '</AccountingEntity5Debit>'
				cXMLRet +=   '<AccountingEntity5DebitInternalId>' + IntGerExt(,, "05", SE2->E2_EC05DB)[2] + '</AccountingEntity5DebitInternalId>'
			Endif
			If !lEntCtb05 .or. empty(SE2->E2_EC05CR)
				cXMLRet +=   '<AccountingEntity5Credit/>'
				cXMLRet +=   '<AccountingEntity5CreditInternalId/>'
			Else
				cXMLRet +=   '<AccountingEntity5Credit>' + RTrim(SE2->E2_EC05CR) + '</AccountingEntity5Credit>'
				cXMLRet +=   '<AccountingEntity5CreditInternalId>' + IntGerExt(,, "05", SE2->E2_EC05CR)[2] + '</AccountingEntity5CreditInternalId>'
			Endif

			If !lEntCtb06 .or. empty(SE2->E2_EC06DB)
				cXMLRet +=   '<AccountingEntity6Debit/>'
				cXMLRet +=   '<AccountingEntity6DebitInternalId/>'
			Else
				cXMLRet +=   '<AccountingEntity6Debit>' + RTrim(SE2->E2_EC06DB) + '</AccountingEntity6Debit>'
				cXMLRet +=   '<AccountingEntity6DebitInternalId>' + IntGerExt(,, "06", SE2->E2_EC06DB)[2] + '</AccountingEntity6DebitInternalId>'
			Endif
			If !lEntCtb06 .or. empty(SE2->E2_EC06CR)
				cXMLRet +=   '<AccountingEntity6Credit/>'
				cXMLRet +=   '<AccountingEntity6CreditInternalId/>'
			Else
				cXMLRet +=   '<AccountingEntity6Credit>' + RTrim(SE2->E2_EC06CR) + '</AccountingEntity6Credit>'
				cXMLRet +=   '<AccountingEntity6CreditInternalId>' + IntGerExt(,, "06", SE2->E2_EC06CR)[2] + '</AccountingEntity6CreditInternalId>'
			Endif

			If !lEntCtb07 .or. empty(SE2->E2_EC07DB)
				cXMLRet +=   '<AccountingEntity7Debit/>'
				cXMLRet +=   '<AccountingEntity7DebitInternalId/>'
			Else
				cXMLRet +=   '<AccountingEntity7Debit>' + RTrim(SE2->E2_EC07DB) + '</AccountingEntity7Debit>'
				cXMLRet +=   '<AccountingEntity7DebitInternalId>' + IntGerExt(,, "07", SE2->E2_EC07DB)[2] + '</AccountingEntity7DebitInternalId>'
			Endif
			If !lEntCtb07 .or. empty(SE2->E2_EC07CR)
				cXMLRet +=   '<AccountingEntity7Credit/>'
				cXMLRet +=   '<AccountingEntity7CreditInternalId/>'
			Else
				cXMLRet +=   '<AccountingEntity7Credit>' + RTrim(SE2->E2_EC07CR) + '</AccountingEntity7Credit>'
				cXMLRet +=   '<AccountingEntity7CreditInternalId>' + IntGerExt(,, "07", SE2->E2_EC07CR)[2] + '</AccountingEntity7CreditInternalId>'
			Endif

			If !lEntCtb08 .or. empty(SE2->E2_EC08DB)
				cXMLRet +=   '<AccountingEntity8Debit/>'
				cXMLRet +=   '<AccountingEntity8DebitInternalId/>'
			Else
				cXMLRet +=   '<AccountingEntity8Debit>' + RTrim(SE2->E2_EC08DB) + '</AccountingEntity8Debit>'
				cXMLRet +=   '<AccountingEntity8DebitInternalId>' + IntGerExt(,, "08", SE2->E2_EC08DB)[2] + '</AccountingEntity8DebitInternalId>'
			Endif
			If !lEntCtb08 .or. empty(SE2->E2_EC08CR)
				cXMLRet +=   '<AccountingEntity8Credit/>'
				cXMLRet +=   '<AccountingEntity8CreditInternalId/>'
			Else
				cXMLRet +=   '<AccountingEntity8Credit>' + RTrim(SE2->E2_EC08CR) + '</AccountingEntity8Credit>'
				cXMLRet +=   '<AccountingEntity8CreditInternalId>' + IntGerExt(,, "08", SE2->E2_EC08CR)[2] + '</AccountingEntity8CreditInternalId>'
			Endif

			If !lEntCtb09 .or. empty(SE2->E2_EC09DB)
				cXMLRet +=   '<AccountingEntity9Debit/>'
				cXMLRet +=   '<AccountingEntity9DebitInternalId/>'
			Else
				cXMLRet +=   '<AccountingEntity9Debit>' + RTrim(SE2->E2_EC09DB) + '</AccountingEntity9Debit>'
				cXMLRet +=   '<AccountingEntity9DebitInternalId>' + IntGerExt(,, "09", SE2->E2_EC09DB)[2] + '</AccountingEntity9DebitInternalId>'
			Endif
			If !lEntCtb09 .or. empty(SE2->E2_EC09CR)
				cXMLRet +=   '<AccountingEntity9Credit/>'
				cXMLRet +=   '<AccountingEntity9CreditInternalId/>'
			Else
				cXMLRet +=   '<AccountingEntity9Credit>' + RTrim(SE2->E2_EC09CR) + '</AccountingEntity9Credit>'
				cXMLRet +=   '<AccountingEntity9CreditInternalId>' + IntGerExt(,, "09", SE2->E2_EC09CR)[2] + '</AccountingEntity9CreditInternalId>'
			Endif

			cXMLRet +=  '</Accounting>'

			// Valores acessórios.
			cFK7Chv := SE2->(E2_FILIAL + '|' + E2_PREFIXO + '|' + E2_NUM + '|' + E2_PARCELA + '|' + E2_TIPO + '|' + E2_FORNECE + '|' + E2_LOJA)
			cIdDoc  := FINBuscaFK7(cFK7Chv, "SE2")
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

	AdpLogEAI(5, "FINI050", cXMLRet, lRet)

Return {lRet, cXMLRet}

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

//-------------------------------------------------------------------
/*/{Protheus.doc} RatCAP
Recebe a chave de busca do titulo à pagar e monta o rateio.

@author  Leandro Luiz da Cruz
@version P11
@since   20/03/2013

@return aResult

@obs Alterar também o fonte FINI050T
/*/
//-------------------------------------------------------------------
Static Function RatCAP(cChave)
	Local aResult  := {}
	Local aPrjtTrf := {}
	Local aCntrCst := {}
	Local nI       := 0

	AFR->(dbSetOrder(2)) // Rateio por Projeto/Tarefa - AFR_FILIAL+AFR_PREFIX+AFR_NUM+AFR_PARCEL+AFR_TIPO+AFR_FORNEC+AFR_LOJA+AFR_PROJET+AFR_REVISA+AFR_TAREFA
	CV4->(dbSetOrder(1)) // Rateios por Centro de Custo - CV4_FILIAL+DTOS(CV4_DTSEQ)+CV4_SEQUEN

	//Povoa o array de Projeto
	If AFR->(dbSeek(cChave))
		While !AFR->(Eof()) .And. cChave == AFR->AFR_FILIAL + AFR->AFR_PREFIX + AFR->AFR_NUM + AFR->AFR_PARCEL + AFR->AFR_TIPO + AFR->AFR_FORNEC + AFR->AFR_LOJA
			aAdd(aPrjtTrf, Array(4))
			nI++
			aPrjtTrf[nI][1] := AFR->AFR_PROJET
			aPrjtTrf[nI][2] := Nil
			aPrjtTrf[nI][3] := AFR->AFR_TAREFA
			aPrjtTrf[nI][4] := AFR->AFR_VALOR1
			AFR->(dbSkip())
		EndDo
	EndIf

	nI := 0
	cChave := AllTrim(SE2->E2_ARQRAT)

	//Povoa o array de Centro de Custo
	If Upper(SE2->E2_RATEIO) == "S" //Possui rateio de centro de custo
		If CV4->(dbSeek(cChave))
			While CV4->(!Eof()) .And. CV4->CV4_FILIAL+DTOS(CV4->CV4_DTSEQ)+CV4->CV4_SEQUEN == cChave

				aAdd(aCntrCst, Array(5))
				nI++
				aCntrCst[nI][1] := CV4->CV4_CCD
				aCntrCst[nI][2] := CV4->CV4_DEBITO
				aCntrCst[nI][3] := CV4->CV4_ITEMD
				aCntrCst[nI][4] := Nil
				aCntrCst[nI][5] := CV4->CV4_PERCEN
				CV4->(dbSkip())
			EndDo
		EndIf
	EndIf

	aResult := IntRatPrjCC(aCntrCst, aPrjtTrf)
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntTPgInt
Recebe um InternalID e retorna o código do título a pagar.

@param   cInternalID InternalID recebido na mensagem.
@param   cRefer      Produto que enviou a mensagem
@param   cVersao     Versão da mensagem única (Default 2.000)

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   08/10/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
lógica indicando se o registro foi encontrado no de/para.
No segundo parâmetro uma variável array com a empresa,
filial, prefixo, número do título, parcela, tipo, fornecedor
e loja.

@sample  IntTrInt("01|99", "RM") irá retornar
{.T., {'01', '01', 'TIT', '000000099', '01', 'NF', '00001', '01'}}
/*/
//-------------------------------------------------------------------
Function IntTPgInt(cInternalID, cRefer, cVersao)
	Local   aResult  := {}
	Local   aTemp    := {}
	Local   cTemp    := ''
	Local   cAlias   := 'SE2'
	Local   cField   := 'E2_NUM'
	Default cVersao  := '2.000'

	cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)

	If Empty(cTemp)
		aAdd(aResult, .F.)
		aAdd(aResult, STR0002)  // 'Registro não encontrado no Protheus. Verifique.'
	Else
		If cVersao = '2.'
			aAdd(aResult, .T.)
			aTemp := Separa(cTemp, '|')
			aAdd(aResult, aTemp)
		ElseIf cVersao = '3.'
			aAdd(aResult, .T.)
			aTemp := Separa(cTemp, '|')
			aAdd(aResult, aTemp)
		Else
			aAdd(aResult, .F.)
			aAdd(aResult, STR0034 + CRLF + STR0035 + "3.x") //"Versão do título a pagar não suportada."-"A versão suportada é: "
		EndIf
	EndIf
Return aResult

/*/{Protheus.doc} IntTPgExt
Monta o InternalID do título a pagar com o código passado
no parâmetro.

@param   cEmpresa   Código da empresa (Default cEmpAnt)
@param   cFil       Código da Filial (Default xFilial(SE2))
@param   cPrefixo   Prefixo do Título
@param   cNumTit    Número do Título
@param   cParcela   Parcela do Título
@param   cTipo      Tipo do Título
@param   cVersao    Versão da mensagem única (Default 2.000)

@author  Leandro Luiz da Cruz
@version P11
@since   08/10/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
lógica indicando se o registro foi encontrado.
No segundo parâmetro uma variável string com o InternalID
montado.

@sample  IntTrExt(, , 'TIT', '000000001', '01', 'DP', '00001', '01')
irá retornar {.T., '01|01|TIT|000000001|01|DP|00001|01'}
/*/
Function IntTPgExt(cEmpresa, cFil, cPrefixo, cNumTit, cParcela, cTipo, cFornec, cLoja, cVersao)

Local aResult  := {}
Default cEmpresa := cEmpAnt
Default cVersao  := '2.000'

If cVersao = '2.' .or. cVersao = '3.'
	aAdd(aResult, .T.)
	aAdd(aResult, cEmpresa + '|' + RTrim(xFilial('SE2', cFil)) + '|' + RTrim(cPrefixo) + '|' + RTrim(cNumTit) + '|' + RTrim(cParcela) + '|' + RTrim(cTipo) + '|' + RTrim(cFornec) + '|' + RTrim(cLoja))
Else
	aAdd(aResult, .F.)
	aAdd(aResult, STR0034 + Chr(10) + STR0035 + "2.x / 3.x") //"Versão do título a pagar não suportada."-"A versão suportada é: "
EndIf

Return aResult

/*/{Protheus.doc} GetNumSE2
Gera um número de título a pagar para o perfixo, fornecedor e loja.

@param   cPrefixo   Prefixo do Título
@param   cFornec    Código do Fornecedor
@param   cLoja      Loja do Fornecedor

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   12/11/2013
@return  cNumero    Número do título a ser gerado.
/*/
Static Function GetNumSE2(cPrefixo, cFornec, cLoja)

	Local cNumero   := ""
	Local cMay      := ""
	Local cQuery    := ""
	Local cAliasTop := ""

	cQuery := "SELECT MAX(E2_NUM) AS NUMERO "
	cQuery += "FROM " + RetSqlName("SE2") + " "
	cQuery += "WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
	cQuery += "AND E2_PREFIXO = '" + cPrefixo + "' "
	cQuery += "AND E2_FORNECE = '" + cFornec + "' "
	cQuery += "AND E2_LOJA    = '" + cLoja + "' "
	cQuery += "AND D_E_L_E_T_ = ' '"
	cAliasTop := MPSysOpenQuery(ChangeQuery(cQuery))

	If (cAliasTop)->(!Eof() .and. !empty(NUMERO))
		cNumero := Soma1((cAliasTop)->NUMERO)
	Else
		cNumero := StrZero(1, Len(SE2->E2_NUM))
	EndIf
	(cAliasTop)->(dbCloseArea())

	dbSelectArea("SE2")
	cMay := "SE2" + xFilial("SE2") + cNumero + cFornec + cLoja
	While !MayIUseCode(cMay)
		cNumero := Soma1(cNumero)
		cMay := "SE2" + xFilial("SE2") + cNumero + cFornec + cLoja
	EndDo

Return cNumero


/*/{Protheus.doc} ConfDoc
Verificar se o E2_NUM passado existe na base, caso exista pegar o próximo número

@param   cPrefixo   Prefixo do Título
@param   cNumDoc    Numero do Título
@param   cParcela   Parcela do Título
@param   cFornec    Código do Fornecedor
@param   cLoja      Loja do Fornecedor
@param   cTipoDoc   Tipo do Título

@author  rafael rondon
@version P12
@since   22/11/2021
@return  cRet    	Número do título a ser gerado.
/*/
Static Function ConfDocSXE(cPrefixo As Character, cNumDoc As Character, cParcela As Character, cFornec As Character, cLoja As Character ,cTipoDoc As Character) As Character

Local aArea 		As Array
Local aAreaSE2 		As Array
Local cRet			As Character

Default cPrefixo 	:= ''
Default cNumDoc 	:= ''
Default cParcela 	:= ''
Default cFornec 	:= ''
Default cLoja 		:= ''
Default cTipoDoc 	:= ''

aArea := GetArea()
aAreaSE2 := SE2->(GetArea())
cRet := cNumDoc

cPrefixo 	:= PadR(cPrefixo,TamSx3("E2_PREFIXO")[1])
cNumDoc 	:= PadR(cNumDoc,TamSx3("E2_NUM")[1])
cParcela 	:= PadR(cParcela,TamSx3("E2_PARCELA")[1])
cFornec 	:= PadR(cFornec,TamSx3("E2_FORNECE")[1])
cLoja 		:= PadR(cLoja,TamSx3("E2_LOJA")[1])
cTipoDoc 	:= PadR(cTipoDoc,TamSx3("E2_TIPO")[1])

DbSelectArea("SE2")
SE2->(DbSetOrder(1)) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA                                                                                               
While SE2->(DbSeek(xFilial("SE2") + cPrefixo + cNumDoc + cParcela + cTipoDoc + cFornec + cLoja))
	cNumDoc := GetSXENum("SE2","E2_NUM")
	ConfirmSX8()	
	cRet := cNumDoc
EndDo

RestArea(aAreaSE2)
RestArea(aArea)

Return cRet

/*/{Protheus.doc} IncluiSEZ
Funcao Static para alimentar as variaveis com as informações do Rateio
MultiNat

@param   aRatEz        Array com as informações do Rateio.
@param   cMarca        Nome do Produto que está sendo integrado.
@param   cNatureza     Natureza do Titulo que está sendo Integrado.
@param   nValor        Valor do Titulo. 
@param   aErroRet      Array contendo as informações de erro, caso houver.

@author  Victor Tomio Furukawa
@version P12
@since   06/12/2021
@return  Nil
/*/

Static Function IncluiSEZ(aRatEz as Array, cMarca as Character, cNatureza as Character, nValor as Numeric, aErroRet as Array) 

Local aArea       as Array
Local aCusto      as Array
Local aItemCta    as Array
Local aItemCLVL   as Array
Local cCLVL       as Character
Local cCusto      as Character
Local cItemCta    as Character
Local cVersaoCust as Character
Local nValRat     as Numeric

//Protecao caso a função seja chamada sem
Default aRatEz    := {}
Default aErroRet  := {}
Default cMarca    := ""
Default cNatureza := ""
Default nValor    := 0

aArea       := GetArea()
aCusto      := {}
aItemCta    := {}
aItemCLVL   := {}
cCLVL       := SPACE(TamSX3("EZ_CLVL")[1])
cCusto      := SPACE(TamSX3("EZ_CCUSTO")[1])
cItemCta    := SPACE(TamSX3("EZ_ITEMCTA")[1])
cVersaoCust := MsgUver( 'CTBA030' , 'COSTCENTER' )
nValRat     := 0 
  
  //Centro de custo
  If Type("oXmlAux:_CostCenterInternalId:Text")#"U" .And.!Empty(oXmlAux:_CostCenterInternalId:Text)
  	aCusto := IntCusInt(oXmlAux:_CostCenterInternalId:Text, cMarca, cVersaoCust)

	If aCusto[1]
		If cVersaoCust = '1'
			cCusto:=Padr(aCusto[2][2], TamSx3("EZ_CCUSTO")[1])
		Else
			cCusto:=Padr(aCusto[2][3], TamSx3("EZ_CCUSTO")[1])			
		Endif
	Else
		lRet := .F.
		lIncluir := .F.
		aadd(aErroRet,aCusto[2])//"Centro de Custo não encontrado no de/para!"
	Endif
		aadd( aRatEz ,{"EZ_CCUSTO" , cCusto , Nil })//centro de custo da natureza 			   		   		
  Endif  

    If Type("oXmlAux:_Value:Text")#"U" .And.!Empty(oXmlAux:_Value:Text)
	  nValRat := Val(oXmlAux:_Value:Text)
	  aadd( aRatEz ,{"EZ_VALOR", nValRat, Nil })//valor do rateio neste centro de custo	  
    Else
  	  lRet := .F.
	  lIncluir := .F.
	  aadd(aErroRet,"Valor para Rateio Invalido ou Zerado!")
    Endif	  	

	//Item Contábil
	If Type("oXmlAux:_AccountingItemInternalId:Text")#"U" .And.!Empty(oXmlAux:_AccountingItemInternalId:Text)

		cValExt := oXmlAux:_AccountingItemInternalId:Text
		aItemCta := C040AGetInt(cValExt, cMarca)
		If aItemCta[1]
			cItemCta := Padr(aItemCta[2][3], TamSx3("EZ_ITEMCTA")[1])			
		EndIf
	Endif

	//Caso não tenha enviado o Item Contabil através do Internal ID, busca por essa TAG
	If Empty(cItemCta) .And. Type("oXmlAux:_AccountingItem:Text")#"U" .And.!Empty(oXmlAux:_AccountingItem:Text)
		cItemCta := Padr(oXmlAux:_AccountingItem:Text, , TamSx3("EZ_ITEMCTA")[1])
	EndIf
	
	If !Empty(cItemCta)
		aadd( aRatEz ,{"EZ_ITEMCTA" , cItemCta , Nil })
	Endif

	//Classe de Valor
	If Type("oXmlAux:_ClassValueInternalId:Text")#"U" .And.!Empty(oXmlAux:_ClassValueInternalId:Text)
		cValExt := oXmlAux:_ClassValueInternalId:Text
		aItemCLVL := C060GetInt(cValExt, cMarca)
		If aItemCLVL[1]
			cCLVL := Padr(aItemCLVL[2][3],TamSx3("EZ_CLVL")[1])
		EndIf
	Endif

	If Empty(cCLVL) .And. Type("oXmlAux:_ClassValue:Text")#"U" .And.!Empty(oXmlAux:_ClassValue:Text)
		cCLVL := Padr(oXmlAux:_ClassValue:Text, TamSx3("EZ_CLVL")[1])
	EndIf

	If !Empty(cCLVL)
		aadd( aRatEz ,{"EZ_CLVL" , cCLVL , Nil })
	Endif	

	RestArea(aArea)

Return Nil

