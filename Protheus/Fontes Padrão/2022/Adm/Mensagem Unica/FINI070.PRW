#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FINI070.CH"

//----------------------------------------------------------------------------------
/*/{Protheus.doc} FINI070
Funcao de integracao com o adapter EAI para baixa do título
a receber (SE1) utilizando o conceito de mensagem unica
(AccountReceivableDocumentDischarge).

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   cTypeTrans    Tipo de transação (Envio/Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Versão da mensagem.
@param   cTransac      Nome da transação.

@author  Wilson de Godoi
@version P12
@since   07/03/2012
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
Function FINI070(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

Local lRet        := .T.
Local cXmlRet     := ''
Local cErroXml    := ''
Local cWarnXml    := ''
Local cIntId      := ''
Local aArea       := GetArea()
Local aAreaSE5    := {}
Local aAreaSE1    := {}
Local aRet        := {}
Local cRequest    := "AccountReceivableDocumentDischarge"
Local cSequencia  := ' '
Local nValJuros   := 0
Local aImposto    := {{"PIS", SE1->E1_BASEPIS, SE1->E1_PIS},;
						{"COFINS", SE1->E1_BASECOF, SE1->E1_COFINS},;
						{"CSLL", SE1->E1_BASECSL, SE1->E1_CSLL},;
						{"IRRF-PF", SE1->E1_BASEIRF, SE1->E1_IRRF},;
						{"ISS", SE1->E1_BASEISS, SE1->E1_ISS} }
Local nVlrRec     := '0'
Local nImp        := 1
Local aAreaAt     := {}
Local cSeq        := ""
Local nDesconto   := 0

Private oXml as object

dbSelectArea("SE5")
aAreaSE5 := SE5->(GetArea())

dbSelectArea("SE1")
aAreaSE1 := SE1->(GetArea())

Do Case
	Case ( cTypeTrans == TRANS_SEND )
		If Fi070Depen(@cXmlRet)
			If !ALTERA
				If Type("cIntegSeq") <> "U"
					cSequencia := cIntegSeq
				Endif

				cIntId := F70MontInt(,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,cSequencia)

				cRequest := "ReversalOfAccountReceivableDocumentDischarge"

				cXMLRet +='<BusinessRequest>'
				cXMLRet +=	'<Operation>' + cRequest + '</Operation>'
				cXMLRet +='</BusinessRequest>'
				cXMLRet +='<BusinessContent>'
				cXMLRet +=		'<CompanyId>' + cEmpAnt + '</CompanyId>'
				cXMLRet +=		'<BranchId>' + cFilAnt + '</BranchId>'
				cXMLRet +=		'<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
				cXMLRet +=      '<InternalId>' + cIntId + '</InternalId>'
				cXMLRet +=		'<CancelDate>' + Transform(dToS(dDataBase),"@R 9999-99-99") + '</CancelDate>' // Data de Cancelamento da Baixa
				cXMLRet +='</BusinessContent>'

				CFGA070Mnt( , 'SE1','E1_BAIXA', , cIntId,.T. )
			Else

               	cSeq := SE5->E5_SEQ
				nVlrRec := SE5->E5_VALOR

				SE5->( dbsetorder(7) )
				SE5->( DbSeek( xFilial("SE5")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA+cSeq ) )

				cRequest := "AccountReceivableDocumentDischarge"

				cXMLRet +='<BusinessRequest>'
				cXMLRet +=	'<Operation>' + cRequest + '</Operation>'
				cXMLRet +='</BusinessRequest>'
				cXMLRet +='<BusinessContent>'
				cXMLRet +=		'<CompanyId>' + cEmpAnt + '</CompanyId>'
				cXMLRet +=		'<BranchId>' + cFilAnt + '</BranchId>'
				cXMLRet +=		'<CompanyInternalId>'+ cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
				cXMLRet +=      '<InternalId>' + F70MontInt(,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,SE5->E5_SEQ) + '</InternalId>'
				cXMLRet +=		'<AccountReceivableDocumentInternalId>' + F55MontInt(,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,,,'SE1') + '</AccountReceivableDocumentInternalId>'
				cXMLRet +=		'<PaymentDate>' + Transform(dToS(SE5->E5_DATA),"@R 9999-99-99") + '</PaymentDate>'		// Data em que o Cliente Efetuou o Pagamento do Título
				cXMLRet +=		'<CreditDate>' + Transform(dToS(SE5->E5_DTDISPO),"@R 9999-99-99") + '</CreditDate>'		// Data em que o Valor foi Crédito na Conta da Empresa
				cXMLRet +=		'<EntryDate>' + Transform(dToS(SE5->E5_DTDIGIT),"@R 9999-99-99") + '</EntryDate>'		// Data de Lançamento da Baixa no Sistema
				cXMLRet +=		'<PaymentValue>' + cValToChar(nVlrRec) + '</PaymentValue>'								// Valor do Pagamento
				cXMLRet +=		'<OtherValues>'

				If SE5->E5_VLJUROS > 0 .And. SE5->E5_VLACRES > 0
					nValJuros := SE5->E5_VLJUROS - SE5->E5_VLACRES
				Else
					nValJuros := SE5->E5_VLJUROS
				EndIf

				nDesconto := SE5->E5_VLDESCO - SE5->E5_VLDECRE
				cXMLRet +=			'<InterestValue>' + cValToChar(nValJuros) + '</InterestValue>'			// Valor de Juros Pagos
				cXMLRet +=			'<DiscountValue>' + CValToChar(nDesconto) + '</DiscountValue>'			// Valor de Desconto Concedido
				cXMLRet +=			'<AbatementValue>' + CValToChar(SE5->E5_VLDECRE) + '</AbatementValue>'	// Valor de Abatimento
				cXMLRet +=			'<NotaryCostsValue>0</NotaryCostsValue>'								// Não temos - Valor de Despesas de Cartório
				cXMLRet +=			'<ExpensesValue>' + CValToChar(SE5->E5_VLACRES) + '</ExpensesValue>'	// Valor de Despesas Financeiras
				cXMLRet +=			'<FineValue>' + CValToChar(SE5->E5_VLMULTA) + '</FineValue>'			// Valor da Multa Paga
				If nDesconto >= SE1->E1_VLBOLSA
					cXMLRet +=		'<ScholarshipValue>'+ cValToChar( SE1->E1_VLBOLSA ) + '</ScholarshipValue>'
				EndIf
				cXMLRet +=		'</OtherValues>'

				aAreaAt := GetArea()
				DbSelectArea("SA1")
				SA1->(dbSetOrder(1))
				SA1->(DbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))

				If AllTrim(SA1->A1_PESSOA) == "J"
					aImposto[4,1] := "IRRF-PJ"
				EndIf

				//Novas Tag para envio do pcc na baixa total do título
				cXMLRet +=	'<Taxes>'
				For nImp := 1 to Len(aImposto)
					If Val(cVersion) < 3
						cXMLRet += '<Taxe'
						cXMLRet += ' CountryCode="' + RTrim(SA1->A1_PAIS) + '" StateCode="' + _NoTags(RTrim(SA1-> A1_ESTADO)) + '" CityCode="' + RTrim(SA1->A1_CODMUN) + '"'
						cXMLRet += ' CalculationBasis="' + CValToChar(Iif(SE1->E1_SALDO == 0, aImposto[nImp,2], 0)) + '"'
						cXMLRet += ' Percentage="0" ReductionBasedPercent="0"'
						cXMLRet += ' Taxe="' + EncodeUTF8(aImposto[nImp, 1]) + '" Value="' + cValToChar(Iif(SE1->E1_SALDO == 0, aImposto[nImp, 3], 0)) + '" Reason="003"/>'
					Else
						cXMLRet += '<Tax>'
						cXMLRet += 		'<Tax>' + EncodeUTF8(aImposto[nImp, 1]) + '</Tax>'
						cXMLRet += 		'<CountryCode>' + RTrim(SA1->A1_PAIS) + '</CountryCode>'
						cXMLRet += 		'<StateCode>' + RTrim(SA1->A1_ESTADO) + '</StateCode>'
						cXMLRet += 		'<CityCode>' + RTrim(SA1->A1_CODMUN) + '</CityCode>'
						cXMLRet += 		'<CalculationBasis>' + cValToChar(Iif(SE1->E1_SALDO == 0, aImposto[nImp, 2], 0)) + '</CalculationBasis>'
						cXMLRet += 		'<Value>' + cValToChar(Iif(SE1->E1_SALDO == 0, aImposto[nImp, 3], 0)) + '</Value>'
						cXMLRet += '</Tax>'
					Endif
				Next nImp
				cXMLRet += '</Taxes>'

				RestArea(aAreaAt)

				cXMLRet += 		'<CurrencyInternalId>' + C40MontInt(,Iif((SE1->E1_MOEDA<10),STrZero(SE1->E1_MOEDA,TAMSx3("CTO_MOEDA")[1],0),cValtoChar(SE1->E1_MOEDA))) + '</CurrencyInternalId>'
				cXMLRet += 	 	'<CurrencyRate>' + cValToChar(SE1->E1_TXMOEDA) + '</CurrencyRate>'
				cXMLRet += 	 	'<CustomerInternalId>' + IntCliExt(, , SE1->E1_CLIENTE, SE1->E1_LOJA, MsgUVer('MATA030', 'CUSTOMERVENDOR'))[2] + '</CustomerInternalId>'
				cXMLRet +=		'<StoreId>' + _NoTags(RTrim(SE5->E5_HISTOR)) + '</StoreId>'
				cXMLRet +=		'<PaymentMethod>' + RetMotBx(2, SE5->E5_MOTBX, cVersion) + '</PaymentMethod>'			// Forma de baixa
				If Val(cVersion) >= 3
					cXMLRet +=		'<CustomPaymentMethod>' + _NoTags(RTrim(SE5->E5_MOTBX)) + '</CustomPaymentMethod>'	// Forma de baixa específica
				Endif
				

				If Empty(SE5->E5_BANCO)
					cXMLRet +=	'<HolderCode/>'
				Else
					cXMLRet +=	'<HolderCode>' + M70MontInt(,SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA) + '</HolderCode>'	// Portador da Baixa
				Endif

				cXMLRet +=		'<FinancialInternalId>' + F10MontInt(,SE1->E1_NATUREZ) + '</FinancialInternalId>'	// Deve ser mandado como o de/para
				cXMLRet +=		'<HistoryText>' + _NoTags(RTrim(SE5->E5_HISTOR)) + '</HistoryText>'
				cXMLRet +=		'<DischargeSequence>' + _NoTags(RTrim(SE5->E5_SEQ)) + '</DischargeSequence>'			// Sequência da Baixa. Utilizado para estornar a baixa
				cXMLRet +=	'</BusinessContent>'
			EndIf
		Else
			Help(,,"FI070DEPEND",,cXmlRet,1,0)
		Endif

	Case ( cTypeTrans == TRANS_RECEIVE )
		Do Case
			Case (cTypeMsg == EAI_MESSAGE_WHOIS )
				cXmlRet := '2.000|2.001|2.002|3.000'
			Case (cTypeMsg == EAI_MESSAGE_RESPONSE )
				If lRet
					oXml := XmlParser(cXml, "_", @cErroXml, @cWarnXml)

					If Type("oXml:_TOTVSMESSAGE:_RESPONSEMESSAGE:_PROCESSINGINFORMATION:_STATUS:TEXT") <> "U" .AND. Alltrim(oXml:_TOTVSMESSAGE:_RESPONSEMESSAGE:_PROCESSINGINFORMATION:_STATUS:TEXT) == "ERROR"
				   		lRet 	:= .F.
				  		cXmlRet	:= oXml:_TOTVSMESSAGE:_RESPONSEMESSAGE:_PROCESSINGINFORMATION:_LISTOFMESSAGES:_MESSAGE:TEXT
					ElseIf oXml <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
						Fi070Respo(@oXml)
						oXml := nil
						DelClassIntF()
					Else
						lRet := .F.
						cXmlRet := STR0001//'Erro no xml recebido.'
					Endif
				Endif
			Case ( cTypeMsg == EAI_MESSAGE_BUSINESS )
				If lRet
					oXml := XmlParser(cXml, "_", @cErroXml, @cWarnXml)
					If oXml <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
						aRet := Fi070Rece(@oXml)
						lRet := aRet[1]
						cXmlRet := aRet[2]
						DelArray(@aRet)
						oXml := Nil
						DelClassIntF()
					Else
						lRet := .F.
						cXmlRet:=STR0001//'Erro no xml recebido.'
					Endif
				Endif
		EndCase
EndCase

RestArea(aAreaSE1)
DelArray(@aAreaSE1)

RestArea(aAreaSE5)
DelArray(@aAreaSE5)

RestArea( aArea )
DelArray(@aArea)

cXmlRet := EncodeUTF8(cXmlRet)
Return {lRet, cXmlRet, cRequest}

//-------------------------------------------------------------------
/*/{Protheus.doc} Fi070Rece(oXml)
	Função de processamento do recebimento da baixa a receber - Via mensagem única

	@param	oXml		Objeto Xml ja parseado

	@author	Jandir Deodato
	@version	P11
	@since	03/07/2013
	@return	lRet	- Indica se o processamento ocorreu com sucesso ou não
	@Return	cXmlRet - Mensagem Xml gerada no processamento
/*/
//-------------------------------------------------------------------
Function Fi070Rece(oXml)

Local lRet			:= .T.
Local cXmlRet		:= ''
Local cExternalId	:= ''
Local cTitInter		:= ''
Local cMarca		:= ''
Local cRequest		:= ''
Local cPrefix		:= ''
Local cNum			:= ''
Local cParcel		:= ''
Local cTipo			:= ''
Local aArea			:= GetArea()
Local aTitulo		:= {}
Local aInterBx		:= {}
Local aRet			:= {}
Local nOpc			:= 0

If XmlChildEx(oXml:_TotvsMessage:_BusinessMessage,'_BUSINESSREQUEST') <> nil .And. XmlChildEx(oXml:_TotvsMessage:_BusinessMessage:_BusinessRequest,'_OPERATION') <> NIL
	cRequest := oXml:_TotvsMessage:_BusinessMessage:_BusinessRequest:_Operation:Text
Endif

If Upper(Alltrim(cRequest)) == 'ACCOUNTRECEIVABLEDOCUMENTDISCHARGE'
	nOpc := 3
ElseIf Upper(Alltrim(cRequest)) == 'REVERSALOFACCOUNTRECEIVABLEDOCUMENTDISCHARGE'
	nOpc := 5
Else
	lRet := .F.
	cXmlRet += STR0003 + " " //'O conteúdo  da tag Request é inválido ou não foi enviado.'
Endif

If XmlChildEx(oXml:_TotvsMessage:_MessageInformation,'_PRODUCT') <> nil .And. XmlChildEx(oXml:_TotvsMessage:_MessageInformation:_Product,'_NAME') <> NIL
	cMarca := oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
Else
	lRet := .F.
	cXmlRet += STR0004 + " "//'Não foi encontrada a tag que identifica a marca integrada.'
Endif

If(oXml := XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage,'_BUSINESSCONTENT')) == Nil//a partir deste ponto, utilizo somente informações da business
	lRet := .F.
	cXmlRet += STR0005//'BusinessContent não encontrada na mensagem.'
Endif

If 	lRet
	cExternalId := Fi070Parse(@oXml,"_InternalId")

	If !Empty (cExternalId)
		aInterBx := F70GetInt(cExternalId, cMarca)

		If (nOpc == 3 .And. !aInterBx[1]) //se inclusão, nao deve achar correspondente. Se estorno, obrigatório ter
			cTitInter := Fi070Parse(@oXml,'_AccountReceivableDocumentInternalId')

			aTitulo := IntTRcInt(cTitInter,cMarca)//Resgatando os dados do título pelo InternalId

			If aTitulo[1]
				cPrefix := PadR(aTitulo[2][3],TamSX3("E1_PREFIXO")[1])
				cNum := PadR(aTitulo[2][4],TamSX3("E1_NUM")[1])
				cParcel := PadR(aTitulo[2][5],TamSX3("E1_PARCELA")[1])
				cTipo := PadR(aTitulo[2][6],TamSX3("E1_TIPO")[1])
			Else
				lRet := .F.
				cXmlRet := STR0006//'Não foi encontrado o título para baixa.'
			Endif

			DelArray(@aTitulo)
		ElseIf (nOpc == 5 .And. aInterBx[1])
			cPrefix := PadR(aInterBx[2][3],TamSX3("E1_PREFIXO")[1])
			cNum := PadR(aInterBx[2][4],TamSX3("E1_NUM")[1])
			cParcel := PadR(aInterBx[2][5],TamSX3("E1_PARCELA")[1])
			cTipo := PadR(aInterBx[2][6],TamSX3("E1_TIPO")[1])
		Else
			lRet := .F.

			If nOpc == 3
				cXmlRet := STR0007//'Já existe movimento de baixa com este InternalId.'
				cXmlRet += " "+STR0008//"Caso deseje modificar esta baixa, é necessário realizar o estorno da baixa e baixar o título novamente."
			Else
				cXmlRet := STR0009//'Não foi encontrada a baixa para realizar o estorno.'
			Endif
		EndIf
		If lRet
			aRet := Fi070Baixa(@oXml,nOpc,cMarca,cPrefix,cNum,cParcel,cTipo,iif(aInterBx[1],aInterBx[2][9],'');
					,cExternalId,iif(aInterBx[1],aInterBx[3],''))//prefixo, num, parcela, tipo

			lRet := aRet[1]
			cXmlRet := aRet[2]

			DelArray(@aRet)
		Endif

		DelArray(@aInterBx)
	Else
		lRet := .F.
		cXmlRet := STR0010//'A tag InternalId não foi encontrada na mensagem.'
	Endif
Endif

RestArea(aARea)
DelArray(@aArea)

Return {lRet,cXmlRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} Fi070Baixa(oXml,nOpc,cMarca,cPrefix,cNum,cParcel,cTipo,cSeq,cExternalId,cInternalId)
	Função de processamento da baixa a receber

	@param	oXml		Objeto Xml ja parseado
	@Param nOpc		Opção da baixa - 3: baixa, 5 - estorno da baixa
	@Param cMarca		Marca integrada
	@param	cPrefix	Prefixo do título
	@param	cNum		Numeo do titulo
	@param cParcel	Parcela do titulo
	@param	cTipo		Tipo do titulo
	@Param cSeq		Sequencia da baixa
	@param cExternalId Codigo externo recebico
	@param	cInternalId	Código Interno

	@author	Jandir Deodato
	@version	P11
	@since	03/07/2013
	@return	lRet	- Indica se o processamento ocorreu com sucesso ou não
	@Return	cXmlRet - Mensagem Xml gerada no processamento

/*/
//-------------------------------------------------------------------

Function Fi070Baixa(oXml,nOpc,cMarca,cPrefix,cNum,cParcel,cTipo,cSeq,cExternalId,cInternalId)
Local aArea			:= GetArea()
Local aAreaSE1		:= {}
Local aCab			:= {}
Local aBanco		:= {}
Local aErroAuto		:= {}
Local lRet			:= .T.
Local cXmlRet		:= ''
Local cCliente		:= ''
Local cLoja			:= ''
Local cMotBaixa		:= ''
Local cBanco		:= ''
Local cHist			:= ''
Local cLogErro		:= ''
Local cAlias		:= "SE1"
Local cCampo		:= "E1_BAIXA"
Local nX			:= 0
Local nJuros		:= 0
Local nMulta		:= 0
Local nDesconto		:= 0
Local nAbat			:= 0
Local nTaxa			:= 0
Local nOpBaixa		:= 1
Local dDtBaixa		:= CtoD("//")
Local dDtEntrada	:= CtoD("//")
Local aCurrency		:= {}

Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .T.
Private cIntegSeq		:= '' //variável dentro da fina070. Necessário para garantir a correta sequencia de baixa.

If nOpc == 5
	Private aBaixaSE5 := {}//utilizado para capturar a sequencia de baixa no E5
Endif

DbSelectArea('SE1')
aAreaSE1 := SE1->(GetArea())
SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA

AADD(aCab,{"E1_PREFIXO",cPrefix,NIL})
AADD(aCab,{"E1_NUM",cNum,NIL})
AADD(aCab,{"E1_PARCELA",cParcel,NIL})
AADD(aCab,{"E1_TIPO",cTipo,NIL})

IF SE1->(dbSeek(xFilial('SE1') + cPrefix + cNum + cParcel + cTipo))
	cCliente := SE1->E1_CLIENTE
	cLoja := SE1->E1_LOJA

	AADD(aCab,{"E1_CLIENTE",cCliente,NIL})
	AADD(aCab,{"E1_LOJA",cLoja,NIL})

	If nOpc == 3 //inclusão da baixa
		dDtBaixa := StoD(StrTran(Fi070Parse(@oXml,'_PaymentDate'),"-"))

		If !Empty(dDtBaixa)
			AADD(aCab,{"AUTDTBAIXA",dDtBaixa,NIL}) // Data de Lançamento da Baixa no Sistema (AUTDTBAIXA)
		Endif

		dDtEntrada := StoD(StrTran(Fi070Parse(@oXml,'_CreditDate'),"-"))

		If !Empty(dDtEntrada)
			AADD(aCab,{"AUTDTCREDITO",dDtEntrada,NIL}) // Data em que o Valor foi Crédito na Conta da Empresa
		Endif

		AADD(aCab,{"AUTVALREC",Val(Fi070Parse(@oXml,'_PaymentValue')),NIL}) // Valor do Pagamento (AUTVALREC)

		nTaxa := Val(Fi070Parse(@oXml,'_CurrencyRate'))

		If nTaxa > 0
			AADD(aCab,{"AUTTXMOEDA",nTaxa,NIL})
		Else
			aCurrency := IntMoeInt(Fi070Parse(@oXml,'_CurrencyInternalId'),cMarca)
			If aCurrency[1]
				nTaxa := RecMoeda(dDtBaixa,Val(aCurrency[2][3]))
				If nTaxa > 0
					AADD(aCab,{"AUTTXMOEDA",nTaxa,NIL})
				EndIf
			EndIf
		EndIf

		cMotBaixa := Fi070Parse(@oXml,"_PaymentMethod")
		cMotBaixa := RetMotBx(1,cMotBaixa)
		If Empty(cMotBaixa)
			cMotBaixa := Fi070Parse(@oXml,"_CustomPaymentMethod")
		Endif

		If !Empty(cMotBaixa)
			AADD(aCab,{"AUTMOTBX",cMotBaixa,NIL}) //Forma de Baixa
		Endif

		//Dados do banco
		cBanco := Fi070Parse(@oXml,"_HolderCode")

		If !Empty (cBanco)
			aBanco := M70GetInt(cBanco,cMarca)
			If aBanco[1]
				AADD(aCab,{"AUTBANCO",aBanco[2][3],NIL}) //Portador
				AADD(aCab,{"AUTAGENCIA",aBanco[2][4],NIL}) //Portador
				AADD(aCab,{"AUTCONTA",aBanco[2][5],NIL}) //Portador
			Else
				cXmlRet := STR0011//'O banco da baixa não foi encontrado. Verifique.'
				lRet := .F.
			Endif
			DelArray(@aBanco)
		Endif

		If lRet
			cHist := Fi070Parse(@oXml,"_HistoryText")

			If !Empty(cHist)
				AADD(aCab,{"AUTHIST",cHist,NIL})
			EndIf

			//OtherValues
			If(oXml := XmlChildEx(oXml,'_OTHERVALUES')) <> NIL
				nJuros := Val(Fi070Parse(@oXml,'_InterestValue'))
				If nJuros > 0
					AADD(aCab,{"AUTJUROS",nJuros,NIL}) 	//Valor de Juros Pagos (AUTJUROS)
				EndIf
				nDesconto := Val(Fi070Parse(@oXml,'_DiscountValue'))
				If nDesconto > 0
					AADD(aCab,{"AUTDESCONT",nDesconto,NIL}) 	//Valor de Desconto Concedido (AUTDESCONT)
				EndIf
				nAbat := Val(Fi070Parse(@oXml,'_AbatementValue'))
				If nAbat > 0
					AADD(aCab,{"AUTDECRESC",nAbat,NIL}) //Valor de Abatimento (AUTDECRESC)
				EndIf
				nDespesa := Val(Fi070Parse(@oXml,'_ExpensesValue'))
				If nDespesa > 0
					AADD(aCab,{"AUTACRESC",nDespesa,NIL})  //Valor de Despesas Financeiras
				EndIf
				nMulta := Val(Fi070Parse(@oXml,'_FineValue'))
				If nMulta > 0
					AADD(aCab,{"AUTMULTA",nMulta,NIL})      //Valor da Multa Paga  (AUTMULTA)
				EndIf
			Endif
			//OtherValues
		Endif

	Else//mensagem de estorno de baixa.
		Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /"+MV_CRNEG,cPrefix, cNum, cParcel,cTipo,,,cCliente,cLoja)
		// baixas na ordem que foram feitas
		aSort(aBaixaSE5,,, {|x,y| x[9] < y[9] } )
		nOpBaixa := aScan(aBaixaSE5,{|x|rTrim(x[9]) == rTrim(cSeq)})
		If nOpBaixa == 0
			nOpBaixa := 1
		Endif
		aSize(aBaixaSE5,0)//zerando o array, pois o mesmo é usado também dentro da fina070
	Endif

	If lRet
		BEGIN TRANSACTION

			MSExecAuto({|x, y, z, a| FINA070(x, y, z, a)}, aCab, nOpc,, nOpBaixa)

			If lMsErroAuto
				aErroAuto := GetAutoGRLog()
				For nX := 1 To Len(aErroAuto)
					cLogErro += StrTran(StrTran(StrTran(aErroAuto[nX],"<"," "),"-"," "),"/"," ")+" "
				Next nX
				// Monta XML de Erro de execução da rotina automatica.
				lRet := .F.
				cXMLRet := cLogErro
				DelArray(@aErroauto)
			Else
				If nOpc == 3 // inclusão da baixa
					If Empty(cIntegSeq) .And. Empty(SE5->E5_SEQ) // não carregou a variavel e o campo E5_SEQ, efetuo o rollback
						DisarmTransaction()
						lRet := .F.
						cXmlRet := _NoTags(STR0013) //'Para utilizar corretamente esta funcionalidade, é necessário atualizar a rotina Baixas a Receber (FINA070)'
					Else
						If Empty(cIntegSeq)
							cIntegSeq := SE5->E5_SEQ
						EndIf
						cInternalId := F70MontInt(,cPrefix,cNum,cParcel,cTipo,cCliente,cLoja,cIntegSeq)
						CFGA070Mnt( cMarca, cAlias,cCampo, cExternalId, cInternalId )
						cXmlRet := '<OriginInternalID>'+cExternalId+'</OriginInternalID>'
		 				cXmlRet += ' <DestinationInternalID>'+cInternalId+'</DestinationInternalID>'
		 			Endif
				Else//estorno da baixa
					CFGA070Mnt( , cAlias,cCampo, , cInternalId,.T. ) //excluindo o de-para
					cXmlRet := '<OriginInternalID>'+cExternalId+'</OriginInternalID>'
		 			cXmlRet += ' <DestinationInternalID>'+cInternalId+'</DestinationInternalID>'
				Endif
			Endif

		END TRANSACTION
	Endif

Else
	lRet:=.F.
	cXmlRet:=STR0006//'Não foi encontrado o título para baixa.'
Endif

RestArea(aAReaSE1)
DelArray(@aAReaSE1)

RestArea(aARea)
DelArray(@aArea)

DelArray(@aCab)

Return{lRet,cXmlRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} DelArray(aArray)
	Função para liberar a memória de arrays

	@param	aArray		Array que será destruido

	@author	Jandir Deodato
	@version	P11
	@since	03/07/2013
	@return	nil
/*/
//-------------------------------------------------------------------
Static function DelArray(aArray)

If Valtype(aArray) == 'A'
	aSize(aArray,0)
	aArray := Nil
Else
	aArray := Nil
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Fi070Parse(oXml,cXml)
	Função que parseia o objeto xml e verifica se o nó existe

	@param	oXml		Objeto xml a ser parseado
	@param cXml		String a ser verificada no xml

	@author	Jandir Deodato
	@version	P11
	@since	03/07/2013
	@return	cRet	conteúdo do no encontrado
/*/

//-------------------------------------------------------------------
Static Function Fi070Parse(oXml,cXml)

Local cRet		:= ''
Local oXmlAux	:= nil

oXmlAux := XmlChildEx( oXml, Upper(cXml) )

If oXmlAux != nil
	cRet := oXmlAux:Text
	oXmlAux := nil
Endif

Return cRet

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
/*/{Protheus.doc} RetMotBx
  Resgata o motivo de baixa a partir dos códigos da mensagem única.

@since 05/07/13
@version P11
@param
	nTipo - NUM - Identificação da coluna de retorno
				1 - códigos alfa - PROTHEUS
				2 - códigos numéricos - XML
	cCod - CHAR - Código da Enumeração do XML
	cVersion - CHAR - Versão da mensagem.
@return
	cRet - CHAR - informação conforme o processo
/*/
//-------------------------------------------------------------------

Static Function RetMotBx(nTipo, cCod, cVersion)

Local cMotBxa   := ''
Local nValIdent 	:= 0

Static aEnumBxas := {}
If empty(aEnumBxas)
	aAdd(aEnumBxas, {'001', 'AD'})
	aAdd(aEnumBxas, {'002', 'AB'})
	aAdd(aEnumBxas, {'003', 'DV'})
	aAdd(aEnumBxas, {'004', 'NC'})
	aAdd(aEnumBxas, {'005', 'NP'})
	aAdd(aEnumBxas, {'006', 'BX'})
	aAdd(aEnumBxas, {'007', 'NOR'})
	aAdd(aEnumBxas, {'008', 'DAC'})
	aAdd(aEnumBxas, {'009', 'DEB'})
	aAdd(aEnumBxas, {'010', 'VEN'})
	aAdd(aEnumBxas, {'011', 'LIQ'})
	aAdd(aEnumBxas, {'012', 'FAT'})
	aAdd(aEnumBxas, {'013', 'CRD'})
	aAdd(aEnumBxas, {'014', 'CEC'})
	aAdd(aEnumBxas, {'015', 'BOL'})
Endif

nValIdent := aScan( aEnumBxas, { |x| x[nTipo]==Alltrim(Upper(cCod)) } )
If nValIdent > 0
	If nTipo = 1
		cMotBxa := PadR(aEnumBxas[nValIdent, 2], TamSX3('E5_MOTBX')[1])
	Else
		cMotBxa := aEnumBxas[nValIdent, 1]
	Endif
Else
	If nTipo = 1
		cMotBxa := Space(TamSX3('E5_MOTBX')[1])
	Else
		If Val(cVersion) < 3
			cMotBxa := "   "
		Else
			cMotBxa := "999"  // 999-Outros.
		Endif
	Endif
Endif

Return cMotBxa

//-------------------------------------------------------------------
/*/{Protheus.doc} F70MontInt
Recebe um registro no Protheus e gera o InternalId deste registro

@param		cFil		Filial do Registro
@Param		cPrefix	Prefixo do titulo
@param		cNum		Numeo do titulo
@param		cparcel	parcela do titulo
@param		cTipo		Tipo do titulo
@param		Cliente	Cliente do titulo
@param		cLoja		Loja do título
@param   cSequencia  Sequencia da baixa do titulo

@author  Jandir Deodato
@version P11.8
@since   30/04/13
@return  cRetorno - Retorna o InternalId do registro

@sample  exemplo de retorno - {'Empresa'|'xFilial'|'Prefixo'|'Numero'|'Parcela'|'Tipo'|'Cliente'|'Loja'|'Sequencia}}
								//		01		02				03		04			05		06			07		08			09
/*/
//-------------------------------------------------------------------
Function F70MontInt(cFil,cPrefix,cNum,cParcel,cTipo,cCliente,cLoja,cSequencia)
Local cRetCode := ''

Default cFil := xFilial('SE1')

cFil := xFilial("SE1",cFil)

cRetCode := cEmpAnt + '|' + rTrim(cFil) + '|' + Trim(cPrefix) + '|' + rTrim(cNum) + '|' + RTrim(cParcel) + '|' +;
			RTrim(cTipo) + '|' + RTrim(cCliente) + '|' + RTrim(cLoja) + '|' + rTrim(cSequencia)

Return cRetCode

//-------------------------------------------------------------------
/*/{Protheus.doc} F70GetInt
Recebe um codigo, busca seu internalId e faz a quebra da chave

@param   cCode		 InternalID recebido na mensagem.
@param   cMarca      Produto que enviou a mensagem

@author  Jandir Deodato
@version P11.8
@since   30/04/13
@return  aRetorno Array contendo os campos da chave primaria do titulo a receber,a sequencia da baixa  e o seu internalid.

@sample  exemplo de retorno - {.T., {'Empresa', 'xFilial', 'Prefixo', 'Numero', 'Parcela','Tipo','Cliente','Loja',Sequecia},InternalId}
/*/									//   01          02         03        04          05      06     07         08    09
//-------------------------------------------------------------------
Function F70GetInt(cCode, cMarca)
//a função já esta implementada para a ocasiao de implementar a recepção da baixa.
Local cValInt	:= ''
Local aRetorno	:= {}
Local aAux		:= {}
Local nX		:= 0
Local aCampos	:= {cEmpAnt,'E1_FILIAL','E1_PREFIXO','E1_NUM','E1_PARCELA','E1_TIPO','E1_CLIENTE','E1_LOJA','E5_SEQ'}

cValInt := CFGA070Int(cMarca, 'SE1', 'E1_BAIXA', cCode)

If !Empty(cValInt)

	aadd(aRetorno,.T.)

	aAux:=Separa(cValInt,'|')

	aadd(aRetorno,aClone(aAux))
	aadd(aRetorno,cValInt)

	aRetorno[2][1]:=Padr(aRetorno[2][1],Len(cEmpAnt))

	For nx:=2 to len (aRetorno[2])//corrigindo  o tamanho dos campos
		aRetorno[2][nX]:=Padr(aRetorno[2][nX],TamSX3(aCampos[nx])[1])
	Next nx
Else
	aadd(aRetorno,.F.)
Endif

DelArray(@aAux)

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} Fi070Respo(oXml)
	Trata a response da mensagem única

	@param	oXml		Objeto xml recebico

	@author	Jandir Deodato
	@version	P11
	@since	03/07/2013
	@return	nil
/*/
//-------------------------------------------------------------------
Function Fi070Respo(oXml)
Local cMarca	:= ''
Local cValInt	:= ''
Local cValExt	:= ''
Local lEstorno	:= .F.
Local lRet		:= .T.
Local nCount	:= 0
Local cXmlRet	:= ''

If XmlChildEx(oXml:_TotvsMessage:_MessageInformation,'_TRANSACTION') != NIL
	If Alltrim(Upper(oXml:_TotvsMessage:_MessageInformation:_Transaction:Text)) == 'REVERSALOFACCOUNTRECEIVABLEDOCUMENTDISCHARGE'
		lEstorno := .T.
	Endif
Endif

If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status,'TEXT') != Nil
	If AllTrim(Upper(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text)) == "ERROR" //Retorno da mensagem com erro
		If ValType(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message) != "A"
			// Transforma em array
			XmlNode2Arr(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
		EndIf

		For nCount := 1 To Len(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
			cXmlRet += oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + Chr(10)
		Next nCount

		lRet := .F.
	EndIf
EndIf

If !lEstorno .And. lRet//no estorno, já excluiu a relação de de-para
	If XmlChildEx(oXml:_TotvsMessage:_MessageInformation:_Product,'_NAME') != nil
		cMarca := oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
	EndIf

   	If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent,'_ORIGININTERNALID') != NIL
   		cValInt := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_OriginInternalID:Text
   	EndIf

   	If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent,'_DESTINATIONINTERNALID') != nil
   	   cValExt := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_DestinationInternalID:Text
   	EndIf

	If !Empty(cValExt) .And. !Empty(cValInt)
	   CFGA070Mnt( cMarca, "SE1", "E1_BAIXA", cValExt, cValInt )
 	Endif
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Fi070Depen(cXml)
	Avalia as dependencias da mensagem de baixa

	@param	cXml		Xml que será devolvido


	@author	Jandir Deodato
	@version	P11
	@since	03/07/2013
	@return	boolean
/*/
//-------------------------------------------------------------------
Static Function Fi070Depen(cXml)

Local lRet := .T.

Default cXml := ''
If !FindFunction('F55MontInt') .Or. !FindFunction ('M70GetInt') .Or. !FindFunction('F10MontInt') .Or. !FindFunction ('C40MontInt')
	lRet := .F.
	cXml += _NoTags(STR0014)  //"Para utilizar esta funcionalidade, é necessário atualizar os adapters FINI055, MATI070, FINI010I e CTBI140. Entre em contato com o Suporte Totvs."
EndIf

Return lRet
