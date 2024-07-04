#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH' //Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH'     //Include para rotinas com MVC
#Include 'FISI042.CH'

Function FISI042(cXml, nTypeTrans, cTypeMessage, cVersion)
Local cError   := ""
Local cWarning := ""
Local cVersao  := ""
Local lRet     := .T.
Local cXmlRet  := ""
Local aRet     := {}
Private oXML   := Nil

//Mensagem de Entrada
If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS .Or. cTypeMessage == EAI_MESSAGE_RESPONSE
		oXml := xmlParser(cXml, "_", @cError, @cWarning)

		If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
			// Versão da mensagem
			If Type("oXml:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. !Empty(oXml:_TOTVSMessage:_MessageInformation:_version:Text)
				cVersao := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
			Else
				lRet := .F.
				cXmlRet := STR0001 //"Versão da mensagem não informada!"
				Return {lRet, cXmlRet}
			EndIf
		Else
			lRet := .F.
			cXmlRet := STR0002 //"Erro no parser!"
			Return {lRet, cXmlRet}
		EndIf

		If cVersao == "1"
			aRet := v1000(cXml, nTypeTrans, cTypeMessage, oXml)
		Else
			lRet    := .F.
			cXmlRet := STR0003 //"A versão da mensagem informada não foi implementada!"
			Return {lRet, cXmlRet}
		EndIf
	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
		aRet := v1000(cXml, nTypeTrans, cTypeMessage, oXml)
	Endif
EndIf

If  Len(aRet)>=2
	lRet    := aRet[1]
	cXMLRet := aRet[2]
EndIf 

Return {lRet, cXmlRet, "ADJUSTMENTSINTAXCALCULATIONEFD"}

//-------------------------------------------------------------------
/*/{Protheus.doc} v1000
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de Ajuste de Creditos (EFD Contribuicoes) 
utilizando o conceito de mensagem unica.

@param Caracter, cXML, Variavel com conteudo xml para envio/recebimento.
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)
@param Objeto, oXml, Objeto xml com a mensagem recebida.

@author Flavio L Vicco
@version 1.0
@since 05/05/2017
@return Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
aRet[1] - (boolean) Indica o resultado da execução da função
aRet[2] - (caracter) Mensagem Xml para envio

@obs
O método irá retornar um objeto do tipo TOTVSBusinessEvent caso o tipo
da mensagem seja EAI_BUSINESS_EVENT ou um tipo TOTVSBusinessRequest
caso a mensagem seja do tipo TOTVSBusinessRequest.
O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------
Static Function v1000(cXml, nTypeTrans, cTypeMessage, oXml)
Local lRet      := .T.          // Retorna se a execucao foi bem sucedida ou nao
Local cXmlRet   := ""           // Xml de retorno da IntegDef
Local aMsgErro  := {}           // Array com erro na validação do Model
Local nI        := 1            // Contadores de uso geral
Local cProduct  := ""           // Marca, Referência (RM, PROTHEUS, DATASUL etc)
Local cValInt   := ""           // Valor interno no Protheus
Local cValExt   := ""           // Valor externo
Local cAlias    := "CF5"        // Alias da tabela no Protheus
Local cField    := "CF5_CODIGO" // Campo identificador no Protheus
Local oModel    := Nil          // Model completo do fisa042
Local oModelCF5 := Nil          // Model com a master apenas
Local aDoc      := {}           // Array com os valores recebidos
Local aAux      := {}           // Array de uso geral
Local nOpcx     := 0            // Operação realizada

//Variaveis de Tags
Local cCode     := ""
Local cAccExt   := ""
Local cAccInt   := ""
Local dRefDate  := CToD ("//")
Local cAcc      := ""
Local aAcc      := {}
Local cBCCode   := ""

Private lMsErroAuto := .F.

//Recebimento
If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS
		// Verifica se o InternalId foi informado
		If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
			cValExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
		Else
			lRet := .F.
			cXmlRet := STR0004 //"O código do InternalId é obrigatório!"
			Return {lRet, cXmlRet}
		EndIf

		// Verifica se a marca foi informada
		If Type("oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text") != "U" .And. !Empty(oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
			cProduct := oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text
		Else
			lRet := .F.
			cXmlRet := STR0005 //"O Produto é obrigatório!"
			Return {lRet, cXmlRet}
		EndIf

		// Verifica se a filial atual é a mesma filial de inclusão do cadastro
		If FindFunction("IntChcEmp")
			aAux := IntChcEmp(oXml, cAlias, cProduct)
			If !aAux[1]
				lRet := aAux[1]
				cXmlRet := aAux[2]
				Return {lRet, cXmlRet}
			EndIf
		EndIf

		// Posiciona tabela CF5
		dbSelectArea(cAlias)
		CF5->(DbSetOrder(1)) //CF5_FILIAL+CF5_CODIGO+CF5_INDAJU+CF5_PISCOF+CF5_CODAJU+DTOS(CF5_DTREF)+CF5_CODCRE

		// Carrega model com estrutura da tabela CF5
		oModel := FwLoadModel("FISA042")

		// Obtém o valor interno da tabela XXF (de/para)
		aAux := IntConInt(cValExt, cProduct, /*Versão*/)

		// Se o evento é UPSERT
		If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
			If !aAux[1]
				// Inclusão
				oModel:SetOperation(MODEL_OPERATION_INSERT)

				nOpcx := 3
			Else
				// Posiciona no registro encontrado
				cCode := aAux[2][3]

				If !CF5->(dbSeek(xFilial("CF5") + cCode))
					lRet := .F.
					cXMLRet := (STR0007 + " -> " + cCode) //"Registro não encontrado!"
					Return {lRet, cXmlRet}
				EndIF

				// Alteração
				oModel:SetOperation(MODEL_OPERATION_UPDATE)

				nOpcx := 4
			EndIf

		ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"

			If aAux[1]

				// Posiciona no registro encontrado
				cCode := aAux[2][3]

				If !CF5->(dbSeek(xFilial("CF5") + cCode))
					lRet := .F.
					cXMLRet := (STR0007 + " -> " + cCode) //"Registro não encontrado!"
					Return {lRet, cXmlRet}
				EndIF

				// Exclusão
				oModel:SetOperation(MODEL_OPERATION_DELETE)

				nOpcx := 5
			Else

				lRet := .F.
				cXMLRet := (STR0007 + " -> " + cValExt) //"Registro não encontrado!"
				Return {lRet, cXmlRet}

			EndIf
		Else
			lRet := .F.
			cXmlRet := STR0008 //"O evento informado é inválido"
			Return {lRet, cXmlRet}
		EndIf

		//-------------------------------------------------------------------
		// Model ativado neste trecho para obter o valor do campo CF5_CODIGO
		//-------------------------------------------------------------------
		oModel:Activate()
		oModelCF5 := oModel:GetModel("FISA042MOD") // Model parcial da Master (CF5)

		cCode := oModelCF5:GetValue('CF5_CODIGO')

		If oModel:nOperation != MODEL_OPERATION_DELETE
			// Recebimento dos dados
			aAdd(aDoc, {"CF5_FILIAL", xFilial("CF5"), Nil})

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Indicador do Ajuste ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AdjustmentIndicator:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AdjustmentIndicator:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AdjustmentIndicator:Text) > TamSX3("CF5_INDAJU")[1]
					lRet := .F.
					cXmlRet := STR0009 + AllTrim(cValToChar(TamSX3("CF5_INDAJU")[1])) + STR0010 //"O campo Indicador do Ajuste (CF5_INDAJU) suporta", " caracteres"
					Return {lRet, cXmlRet}
				EndIf
				aAdd(aDoc, {"CF5_INDAJU", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AdjustmentIndicator:Text, Nil})
			Else
				lRet := .F.
				cXmlRet := STR0011 //"Campo obrigatório não informado - Indicador do Ajuste (CF5_INDAJU)"
				Return {lRet, cXmlRet}
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Ajuste de PIS/COFINS ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AdjustmentType:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AdjustmentType:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AdjustmentType:Text) > TamSX3("CF5_PISCOF")[1]
					lRet := .F.
					cXmlRet := STR0012 + AllTrim(cValToChar(TamSX3("CF5_PISCOF")[1])) + STR0010 //"O campo Ajuste de PIS/COFINS (CF5_PISCOF) suporta", " caracteres"
					Return {lRet, cXmlRet}
				EndIf
				aAdd(aDoc, {"CF5_PISCOF", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AdjustmentType:Text, Nil})
			Else
				lRet := .F.
				cXmlRet := STR0013 //"Campo obrigatório não informado - Ajuste de PIS/COFINS (CF5_PISCOF)"
				Return {lRet, cXmlRet}
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Valor do Ajuste ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AdjustmentValue:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AdjustmentValue:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AdjustmentValue:Text) > (TamSX3("CF5_VALAJU")[1])
					lRet := .F.
					cXmlRet := STR0014 + AllTrim(cValToChar(TamSX3("CF5_VALAJU")[1])) + STR0010 //"O campo Valor do Ajuste (CF5_VALAJU) suporta", " caracteres"
					Return {lRet, cXmlRet}
				EndIf
				aAdd(aDoc, {"CF5_VALAJU", Val( StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AdjustmentValue:Text, ",", "." ) ), Nil})
			Else
				lRet := .F.
				cXmlRet := STR0015 //"Campo obrigatório não informado - Valor do Ajuste (CF5_VALAJU)"
				Return {lRet, cXmlRet}
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Codigo do Ajuste ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AdjustmentCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AdjustmentCode:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AdjustmentCode:Text) > TamSX3("CF5_CODAJU")[1]
					lRet := .F.
					cXmlRet := STR0016 + AllTrim(cValToChar(TamSX3("CF5_CODAJU")[1])) + STR0010 //"O campo Codigo do Ajuste (CF5_CODAJU) suporta", " caracteres"
					Return {lRet, cXmlRet}
				EndIf
				aAdd(aDoc, {"CF5_CODAJU", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AdjustmentCode:Text, Nil})
			Else
				lRet := .F.
				cXmlRet := STR0017 //"Campo obrigatório não informado - Codigo do Ajuste (CF5_CODAJU)"
				Return {lRet, cXmlRet}
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Data de Referencia ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReferenceDate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReferenceDate:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReferenceDate:Text) > (TamSX3("CF5_DTREF")[1]) + 2
					lRet := .F.
					cXmlRet := STR0018 + AllTrim(cValToChar(TamSX3("CF5_DTREF")[1])) + STR0010 //"O campo Data de Referencia (CF5_DTREF) suporta", " caracteres"
					Return {lRet, cXmlRet}
				EndIf
				dRefDate := SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ReferenceDate:Text,"-",""))
				aAdd(aDoc, {"CF5_DTREF", dRefDate , Nil})
			Else
				lRet := .F.
				cXmlRet := STR0019 //"Campo obrigatório não informado - Data de Referencia (CF5_DTREF)"
				Return {lRet, cXmlRet}
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Credito/Debito      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CreditDebitAdjustment:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CreditDebitAdjustment:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CreditDebitAdjustment:Text) > TamSX3("CF5_TPAJST")[1]
					lRet := .F.
					cXmlRet := STR0037 + AllTrim(cValToChar(TamSX3("CF5_TPAJST")[1])) + STR0010 //"O campo Indicador do Ajuste (CF5_TPAJST) suporta", " caracteres"
					Return {lRet, cXmlRet}
				EndIf
				aAdd(aDoc, {"CF5_TPAJST", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CreditDebitAdjustment:Text, Nil})
			Else
				lRet := .F.
				cXmlRet := STR0038 //"Campo obrigatório não informado - Indicador de Credito/Debito (CF5_TPAJST)"
				Return {lRet, cXmlRet}
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tags nao obrigatorias  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Numero do Documento ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text) > TamSX3("CF5_NUMDOC")[1]
					lRet := .F.
					cXmlRet := STR0020 + AllTrim(cValToChar(TamSX3("CF5_NUMDOC")[1])) + STR0010 //"O campo Numero do Documento (CF5_NUMDOC) suporta", " caracteres"
					Return {lRet, cXmlRet}
				EndIf
				aAdd(aDoc, {"CF5_NUMDOC", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text, Nil})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Descricao do Ajuste ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AdjustmentDescription:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AdjustmentDescription:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AdjustmentDescription:Text) > TamSX3("CF5_DESAJU")[1]
					lRet := .F.
					cXmlRet := STR0021 + AllTrim(cValToChar(TamSX3("CF5_DESAJU")[1])) + STR0010 //"O campo Descricao do Ajuste (CF5_DESAJU) suporta", " caracteres"
					Return {lRet, cXmlRet}
				EndIf
				aAdd(aDoc, {"CF5_DESAJU", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AdjustmentDescription:Text, Nil})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Tipo Credito ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CreditType:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CreditType:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CreditType:Text) > TamSX3("CF5_CODCRE")[1]
					lRet := .F.
					cXmlRet := STR0022 + AllTrim(cValToChar(TamSX3("CF5_CODCRE")[1])) + STR0010 //"O campo Tipo Credito (CF5_CODCRE) suporta", " caracteres"
					Return {lRet, cXmlRet}
				EndIf

				cBCCode := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CreditType:Text
				cBCCode := Padr(SubStr(cBCCode,1,TamSx3("CF5_CODCRE")[1]),TamSx3("CF5_CODCRE")[1])

			 	SX5->(DbSetOrder(1))
		    	If SX5->(MsSeek(xFilial("SX5") + "ZR" + cBCCode))
		    		aAdd(aDoc, {"CF5_CODCRE", cBCCode , Nil})
		    	Else
		    		lRet := .F.
					cXmlRet := STR0023 + cBCCode + STR0024 + " '" + xFilial("SX5") + " '" //"Codigo Tipo Credito: ", " Não encontrado na base de dados da Filial:"
					Return {lRet, cXmlRet}
		    	EndIf

				aAdd(aDoc, {"CF5_CODCRE", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CreditType:Text, Nil})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tipo de Atividade CPRB ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TypeActivity:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TypeActivity:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TypeActivity:Text) > TamSX3("CF5_TIPATV")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF5_TIPATV")[1])) + STR0010 //"O campo Tipo Credito (CF5_TIPATV) suporta", " caracteres"
					Return {lRet, cXmlRet}
				EndIf
				aAdd(aDoc, {"CF5_TIPATV", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TypeActivity:Text, Nil})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Codigo da Situacao Tribut ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaxSituation:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaxSituation:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaxSituation:Text) > TamSX3("CF5_CST")[1]
					lRet := .F.
					cXmlRet := STR0026 + AllTrim(cValToChar(TamSX3("CF5_CST")[1])) + STR0010 //"O campo Codigo da Situacao Tribut (CF5_CST) suporta", " caracteres"
					Return {lRet, cXmlRet}
				EndIf

				cBCCode := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaxSituation:Text
				cBCCode := Padr(SubStr(cBCCode,1,TamSx3("CF5_CST")[1]),TamSx3("CF5_CST")[1])

			 	SX5->(DbSetOrder(1))
		    	If SX5->(MsSeek(xFilial("SX5") + "SX" + cBCCode))
		    		aAdd(aDoc, {"CF5_CST", cBCCode , Nil})
		    	Else
		    		lRet := .F.
					cXmlRet := STR0027 + cBCCode + STR0024 + " '" + xFilial("SX5") + " '" //"Codigo da Situacao Tribut: ", " Não encontrado na base de dados da Filial:"
					Return {lRet, cXmlRet}
		    	EndIf

				aAdd(aDoc, {"CF5_CST", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaxSituation:Text, Nil})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Base Calculo ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaxBase:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaxBase:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaxBase:Text) > TamSX3("CF5_BASE")[1]
					lRet := .F.
					cXmlRet := STR0028 + AllTrim(cValToChar(TamSX3("CF5_BASE")[1])) + STR0010 //"O campo Codigo da Situacao Tribut (CF5_BASE) suporta", " caracteres"
					Return {lRet, cXmlRet}
				EndIf
				aAdd(aDoc, {"CF5_BASE", Val( StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaxBase:Text, ",", "." ) ), Nil})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Aliquota do Ajuste ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaxRate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaxRate:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaxRate:Text) > TamSX3("CF5_ALQ")[1]
					lRet := .F.
					cXmlRet := STR0029 + AllTrim(cValToChar(TamSX3("CF5_ALQ")[1])) + STR0010 //"O campo Aliquota do Ajuste (CF5_ALQ) suporta", " caracteres"
					Return {lRet, cXmlRet}
				EndIf
				aAdd(aDoc, {"CF5_ALQ", Val( StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaxRate:Text, ",", "." ) ), Nil})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Conta Contabil ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AccountantAccountInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AccountantAccountInternalId:Text)

				cAccExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AccountantAccountInternalId:Text
				cAccInt := CFGA070INT( cProduct, 'CT1', 'CT1_CONTA', cAccExt )

				If Empty(cAccInt)
					lRet := .F.
					cXmlRet := STR0030 //"Conta Contábil não encontrada no Protheus."
					Return {lRet, cXmlRet}
				EndIf

				aAcc := Separa(cAccInt, '|')

				If Len(AllTrim(aAcc[3])) > TamSX3("CF5_CONTA")[1]
					lRet := .F.
					cXmlRet := STR0031 + AllTrim(cValToChar(TamSX3("CF5_CONTA")[1])) + STR0010 //"O campo Conta Contabil (CF5_CONTA) suporta", " caracteres"   
					Return {lRet, cXmlRet}
				EndIf

				cAcc := Padr(SubStr(aAcc[3],1,TamSx3("CF5_CONTA")[1]),TamSx3("CF5_CONTA")[1])

				dbSelectArea("CT1")
				CT1->(dbSetOrder(1))
				If 	CT1->(MsSeek(xFilial("CT1")+cAcc))
					aAdd(aDoc, {"CF5_CONTA", cAcc, Nil})
				Else
					lRet := .F.
					cXmlRet := STR0032 + aAcc[3] + STR0033 + aAcc[1] + STR0034 //"Conta Contábil: ", " não encontrada na base de dados da Filial: ", "Verifique o conteúdo da Tag AccountantAccountInternalId"
					Return {lRet, cXmlRet}
				EndIf

			ElseIf Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AccountantAccountCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AccountantAccountCode:Text)

				aAcc := Separa(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AccountantAccountCode:Text, '|')

				If Len(aAcc[1]) > TamSX3("CF5_CONTA")[1]
					lRet := .F.
					cXmlRet := STR0031 + AllTrim(cValToChar(TamSX3("CF5_CONTA")[1])) + STR0010 //"O campo Conta Contabil (CF5_CONTA) suporta", " caracteres"  
					Return {lRet, cXmlRet}
				EndIf

				cAcc := Padr(SubStr(aAcc[1],1,TamSx3("CF5_CONTA")[1]),TamSx3("CF5_CONTA")[1])

				dbSelectArea("CT1")
				CT1->(dbSetOrder(1))
				If 	CT1->(MsSeek(xFilial("CT1")+cAcc))
					aAdd(aDoc, {"CF5_CONTA", cAcc, Nil})
				Else
					lRet := .F.
					cXmlRet := STR0032 + aAcc[1] + STR0033 + xFilial("CT1") + STR0035 //"Conta Contábil: ", " não encontrada na base de dados da Filial: ", "Verifique o conteúdo da Tag AccountantAccountCode"
					Return {lRet, cXmlRet}
				EndIf

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Informacao complementar ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ComplementaryInformation:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ComplementaryInformation:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ComplementaryInformation:Text) > TamSX3("CF5_INFCOM")[1]
					lRet := .F.
					cXmlRet := STR0036 + AllTrim(cValToChar(TamSX3("CF5_INFCOM")[1])) + STR0010 //"O campo Codigo da Situacao Tribut (CF5_INFCOM) suporta", " caracteres"
					Return {lRet, cXmlRet}
				EndIf
				aAdd(aDoc, {"CF5_INFCOM", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ComplementaryInformation:Text, Nil})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Codigo Contribuinte     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ContributionCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ContributionCode:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ContributionCode:Text) > TamSX3("CF5_CODCON")[1]
					lRet := .F.
					cXmlRet := STR0039 + AllTrim(cValToChar(TamSX3("CF5_CODCON")[1])) + STR0010 //"O campo Codigo da Contribuicao (CF5_CODCON) suporta", " caracteres"
					Return {lRet, cXmlRet}
				EndIf

				cBCCode := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ContributionCode:Text
				cBCCode := Padr(SubStr(cBCCode,1,TamSx3("CF5_CODCON")[1]),TamSx3("CF5_CODCON")[1])

			 	SX5->(DbSetOrder(1))
		    	If SX5->(MsSeek(xFilial("SX5") + "MY" + cBCCode))
		    		aAdd(aDoc, {"CF5_CODCON", cBCCode , Nil})
		    	Else
		    		lRet := .F.
					cXmlRet := STR0040 + cBCCode + STR0024 + " '" + xFilial("SX5") + " '" //"Codigo da Contribuicao: ", " Não encontrado na base de dados da Filial:"
					Return {lRet, cXmlRet}
		    	EndIf

				aAdd(aDoc, {"CF5_CODCON", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ContributionCode:Text, Nil})
			EndIf

		EndIf

		// Obtém a estrutura de dados
		aAux := oModelCF5:GetStruct():GetFields()

		For nI := 1 To Len(aDoc)
			// Verifica se os campos passados existem na estrutura do modelo
			If aScan(aAux, {|x| AllTrim(x[3]) == AllTrim(aDoc[nI][1])}) > 0
				// É feita a atribuição do dado ao campo do Model
				If ValType(aDoc[nI][2]) == "C"
					If !oModel:SetValue('FISA042MOD', aDoc[nI][1], AllTrim(aDoc[nI][2])) .And. (oModel:nOperation != MODEL_OPERATION_UPDATE)
						lRet := .F.
						cXmlRet := STR0041 + AllToChar(aDoc[nI][2]) + STR0042 + aDoc[nI][1] + "." //"Não foi possível atribuir o valor ", " ao campo: "
						Return {lRet, cXmlRet}
					EndIf
				ElseIf !oModel:SetValue('FISA042MOD', aDoc[nI][1], aDoc[nI][2])  .And. (oModel:nOperation != MODEL_OPERATION_UPDATE)
					lRet := .F.
					cXmlRet := STR0041 + AllToChar(aDoc[nI][2]) + STR0042 + aDoc[nI][1] + "." //"Não foi possível atribuir o valor ", " ao campo: "
					Return {lRet, cXmlRet}
				EndIf
			EndIf
		Next nI

		// Se os dados não são válidos
		If !oModel:VldData()
			// Obtém o log de erros
			aMsgErro := oModel:GetErrorMessage()

			cXmlRet := STR0043 + AllToChar(aMsgErro[6]) + CRLF //"Mensagem do erro: "
			cXmlRet += STR0044 + AllToChar(aMsgErro[7]) + CRLF //"Mensagem da solução: "
			cXmlRet += STR0045 + AllToChar(aMsgErro[8]) + CRLF //"Valor atribuído: "
			cXmlRet += STR0046 + AllToChar(aMsgErro[9]) + CRLF //"Valor anterior: "
			cXmlRet += STR0047 + AllToChar(aMsgErro[1]) + CRLF //"Id do formulário de origem: "
			cXmlRet += STR0048 + AllToChar(aMsgErro[2]) + CRLF //"Id do campo de origem: "
			cXmlRet += STR0049 + AllToChar(aMsgErro[3]) + CRLF //"Id do formulário de erro: "
			cXmlRet += STR0050 + AllToChar(aMsgErro[4]) + CRLF //"Id do campo de erro: "
			cXmlRet += STR0051 + AllToChar(aMsgErro[5]) //"Id do erro: "

			lRet := .F.
			Return {lRet, cXmlRet}
		Else
			// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
			oModel:CommitData()
		EndIf

		// Obtém o InternalId
		cValInt := IntConExt(/*Empresa*/, /*Filial*/, cCode, /*Versão*/)[2]

		// Se o evento é diferente de delete
		If oModel:nOperation != MODEL_OPERATION_DELETE
			// Grava o registro na tabela XXF (de/para)
			CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F., , , "ADJUSTMENTSINTAXCALCULATIONEFD")
			ConfirmSX8()

			// Monta o XML de retorno
			cXMLRet := "<ListOfInternalId>"
			cXMLRet +=     "<InternalId>"
			cXMLRet +=         "<Name>" + 'OtherDocumentsF100' + "</Name>"
			cXMLRet +=         "<Origin>" + cValExt + "</Origin>"
			cXMLRet +=         "<Destination>" + cValInt + "</Destination>"
			cXMLRet +=     "</InternalId>"
			cXMLRet += "</ListOfInternalId>"
		Else
			// Exclui o registro na tabela XXF (de/para)
			CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T., , , "ADJUSTMENTSINTAXCALCULATIONEFD")
		EndIf

	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS // Recebimento da WhoIs
		cXmlRet := "1.000"
	EndIf

EndIf

Return {lRet, cXmlRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} IntConExt
Monta o InternalID da Movimentacao de acordo com o codigo
passado no parametro.

@param Caracter, cEmpresa, Codigo da empresa (Default cEmpAnt)
@param Caracter, cFil, Codigo da Filial (Default cFilAnt)
@param Caracter, cCodigo, Codigo da Movimentação
@param Caracter, cVersao, Versão da mensagem unica (Default 2.000)

@author Flavio L Vicco
@version 1.0
@since 05/05/2017
@return  Array, Array contendo no primeiro parametro uma variavel
logica indicando se o registro foi encontrado.
No segundo parametro uma variavel string com o InternalID
montado.

@sample
IntConExt(, , '001') irá retornar {.T., '01|01|001'}
/*/
//-------------------------------------------------------------------
Static Function IntConExt(cEmpresa, cFil, cCodigo, cVersao)
   Local   aResult  := {}
   Default cEmpresa := cEmpAnt
   Default cFil     := xFilial('CF5')
   Default cVersao  := '1.000'

   If cVersao == '1.000'
      aAdd(aResult, .T.)
      aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cCodigo))
   Else
      aAdd(aResult, .F.)
      aAdd(aResult, STR0052 + Chr(10) + STR0053 + "1.000" ) //"Versão da rotina não suportada.", "As versões suportadas são: "
   EndIf
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntConInt
Recebe um InternalID e retorna o codigo da Movimentacao.

@param Caracter, cInternalID, InternalID recebido na mensagem.
@param Caracter, cRefer, Produto que enviou a mensagem
@param Caracter, cVersao, Versão da mensagem unica (Default 2.000)

@author Flavio L Vicco
@version 1.0
@since 05/05/2017
@return Array, Array contendo no primeiro parametro uma variavel
logica indicando se o registro foi encontrado no de/para.
No segundo parametro uma variavel array com a empresa,
filial e o Codigo da Movimentacao.

@sample
IntConInt('01|01|001') irá retornar {.T., {'01', '01', '001'}}
/*/
//-------------------------------------------------------------------
Static Function IntConInt(cInternalID, cRefer, cVersao)
   Local   aResult  := {}
   Local   aTemp    := {}
   Local   cTemp    := ''
   Local   cAlias   := 'CF5'
   Local   cField   := 'CF5_CODIGO'
   Default cVersao  := '1.000'

   cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)

   If Empty(cTemp)
      aAdd(aResult, .F.)
      aAdd(aResult, STR0054 + " -> " + cInternalID) //"Registro não encontrado no de/para!"
   Else
      If cVersao == '1.000'
         aAdd(aResult, .T.)
         aTemp := Separa(cTemp, '|')
         aAdd(aResult, aTemp)
      Else
         aAdd(aResult, .F.)
         aAdd(aResult, STR0052 + Chr(10) + STR0053 + "1.000") //"Versão da rotina não suportada.", "As versões suportadas são: "
      EndIf
   EndIf
Return aResult
