#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FINI080.CH"

//----------------------------------------------------------------------------------
/*/{Protheus.doc} FINI080
Funcao de integracao com o adapter EAI para baixa do título
a pagar (SE2) utilizando o conceito de mensagem unica
(AccountPayableDocumentDischarge).

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
Function FINI080(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

Local lRet        := .T.
Local cXmlRet     := ''
Local cErroXml    := ''
Local cWarnXml    := ''
Local aArea       := GetArea()
Local aAreaSE2    := {}
Local aAreaSE5    := {}
Local cRequest    := "AccountPayableDocumentDischarge"
Local cInternalId := ''
Local oXml        := Nil
Local nI          := 0
Local aImposto    := {"IRRF"}
Local cValorImp   := "0" //valor do imposto em caracter para concatenar
Local cImpBase    := "0.0"

dbSelectArea("SE2")
aAreaSE2:= SE2->(GetArea())

dbSelectArea("SE5")
aAreaSE5:= SE5->(GetArea())

Do Case
	Case ( cTypeTrans == TRANS_SEND )
		If lRet

			cInternalId:=F80MontInt(,SE2->E2_PREFIXO ,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,SE5->E5_SEQ)

			If !ALTERA
				cRequest:= "ReversalOfAccountPayableDocumentDischarge"

				cXMLRet +='<BusinessRequest>'
				cXMLRet +=	'<Operation>'+cRequest+'</Operation>'
				cXMLRet +='</BusinessRequest>'
				cXMLRet +='<BusinessContent>'
				cXMLRet +=	'<InternalId>' + cInternalId + '</InternalId>'
				cXMLRet +=	'<CancelDate>' + Transform(dToS(dDataBase),"@R 9999-99-99") + '</CancelDate>'	// Data de Cancelamento da Baixa
				cXMLRet +='</BusinessContent>'

				CFGA070Mnt( , 'SE2','E2_BAIXA', , cInternalId,.T. )
			Else
				cRequest:= "AccountPayableDocumentDischarge"

				cXMLRet +='<BusinessRequest>'
				cXMLRet +=	'<Operation>'+cRequest+'</Operation>'
				cXMLRet +='</BusinessRequest>'
				cXMLRet +='<BusinessContent>'
				cXMLRet +=		'<AccountPayableDocumentInternalId>'+F55MontInt(,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO, SE2->E2_FORNECE,SE2->E2_LOJA,'SE2')+'</AccountPayableDocumentInternalId>'
				cXMLRet +=      '<InternalId>'		+ cInternalId + '</InternalId>'
				cXMLRet +=		'<CompanyId>'	 	+ cEmpAnt + '</CompanyId>'
				cXMLRet +=		'<BranchId>'		+ cFilAnt + '</BranchId>'
				cXMLRet +=		'<PaymentDate>'		+ Transform(dToS(SE5->E5_DATA),"@R 9999-99-99") + '</PaymentDate>'	// Data em que o Cliente Efetuou o Pagamento do Título
				cXMLRet +=		'<DebitDate>'		+ Transform(dToS(SE5->E5_DTDISPO),"@R 9999-99-99") + '</DebitDate>'    // Data em que o Valor foi debitado na Conta da Empresa
				cXMLRet +=		'<PaymentValue>'	+ cValToChar(SE5->E5_VALOR) + '</PaymentValue>'	  		//Valor do Pagamento

				SA2->(dbSetOrder(1))
				SA2->(DbSeek(xFilial("SA2") + SE5->E5_CLIFOR + SE5->E5_LOJA))

				dbSelectArea("SE5")

				//Envia valor do imposto do IRRF
				cXMLRet +=		'<Taxes>'
				For nI := 1 to Len(aImposto)
					cImposto := aImposto[nI]

					if cImposto == "IRRF"
						//verifica o tipo do cliente
						If AllTrim(SA2->A2_TIPO) == "J"
							cImposto += "-PJ"
						Elseif AllTrim(SA2->A2_TIPO) == "F"
							cImposto += "-PF"
						endif

						//verifica  se é gerado na emissão ou na baixa
						If AllTrim(SA2->A2_CALCIRF) == "1"
							//verifica se é primeira baixa
							If SE2->E2_SALDO + SE5->E5_VALOR + SE5->E5_VLDESCO - SE5->E5_VLJUROS - SE5->E5_VLMULTA  == SE2->E2_VALOR
								cImpBase	:= IIf(SE5->(FieldPos("E2_BASEIRF")) > 0, cValToChar(SE2->E2_BASEIRF), '0.0')
								cValorImp 	:= cValToChar(SE2->E2_IRRF)
							Else
								cImpBase 	:= "0"
								cValorImp 	:= "0"
							EndIf

						ElseIf AllTrim(SA2->A2_CALCIRF) == "2"
							cImpBase := IIf(SE5->(FieldPos("E5_BASEIRF")) > 0, cValToChar(SE5->E5_BASEIRF), '0.0')
							cValorImp := cValToChar(SE5->E5_VRETIRF)
						EndIF
					endIf
					If Val(cVersion) < 3
						cXMLRet += 		'<Tax CalculationBasis="' + cImpBase +'" CityCode="' + RTrim(SA2->A2_COD_MUN) + '"  CountryCode="' + RTrim(SA2->A2_PAIS)
						cXMLRet += 			'" Percentage="0.0" Reason="003" Recalculate="true" ReductionBasedPercent="0.0" StateCode="' + RTrim(SA2->A2_ESTADO)
						cXMLRet += 			'" Taxe="' + EncodeUTF8(cImposto) + '" Value="' + cValorImp + '"/>'
					Else
						cXMLRet += '<Tax>'
						cXMLRet += 		'<Tax>' + EncodeUTF8(cImposto) + '</Tax>'
						cXMLRet += 		'<CountryCode>' + RTrim(SA2->A2_PAIS) + '</CountryCode>'
						cXMLRet += 		'<StateCode>' + RTrim(SA2->A2_ESTADO) + '</StateCode>'
						cXMLRet += 		'<CityCode>' + RTrim(SA2->A2_COD_MUN) + '</CityCode>'
						cXMLRet += 		'<CalculationBasis>' + cImpBase + '</CalculationBasis>'
						cXMLRet += 		'<Value>' + cValorImp + '</Value>'
						cXMLRet += '</Tax>'
					Endif
				Next nI
				cXMLRet +=		'</Taxes>'

				cXMLRet +=		'<OtherValues>'
				cXMLRet +=			'<InterestValue>'	+ cValToChar(SE5->E5_VLJUROS) + '</InterestValue>'     	//Valor de Juros Pagos
				cXMLRet +=			'<DiscountValue>'	+ cValToChar(SE5->E5_VLDESCO) + '</DiscountValue>'	 	//Valor de Desconto Concedido
				cXMLRet +=			'<FineValue>'	  	+ cValToChar(SE5->E5_VLMULTA) + '</FineValue>'			//Valor da Multa Paga
				cXMLRet +=		'</OtherValues>'
				cXMLRet += 		'<CurrencyInternalId>'	+ C40MontInt(,Iif((SE2->E2_MOEDA<10),STrZero(SE2->E2_MOEDA,TAMSx3("CTO_MOEDA")[1],0),cValToChar(SE2->E2_MOEDA))) +'</CurrencyInternalId>'
				cXMLRet += 	 	'<CurrencyRate>' 	+ cValToChar(SE5->E5_TXMOEDA) + '</CurrencyRate>'
				cXMLRet +=		'<VendorInternalId>' + IntForExt(, , SE2->E2_FORNECE, SE2->E2_LOJA, MsgUVer('MATA020', 'CUSTOMERVENDOR'))[2] + '</VendorInternalId>'
				cXMLRet +=		'<StoreId>' 		+ SE2->E2_LOJA + '</StoreId>'
				cXMLRet +=		'<PaymentMethodCode>'	+ RetMotBx(2, SE5->E5_MOTBX, cVersion) + '</PaymentMethodCode>'	// Forma de baixa
				If Val(cVersion) >= 3
					cXMLRet +=		'<CustomPaymentMethod>' + _NoTags(RTrim(SE5->E5_MOTBX)) + '</CustomPaymentMethod>'	// Forma de baixa específica
				Endif
				If !Empty(SE5->E5_BANCO)
					cXMLRet +=		'<BankInternalId>' + M70MontInt(,SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA) + '</BankInternalId>'	//banco da baixa
				Endif
				cXMLRet +=		'<FinancialNatureInternalId>' 	+ F10MontInt(,SE2->E2_NATUREZ) + '</FinancialNatureInternalId>'
				cXMLRet +=		'<HistoryText>'		+ SE5->E5_HISTOR + '</HistoryText>'
				cXMLRet += 	'<DischargeSequence>'	+ SE5->E5_SEQ + '</DischargeSequence>'					//Sequência da Baixa. Utilizado para estornar a baixa
				cXMLRet +='</BusinessContent>'
			Endif
		Else
			Help(,,"FI080DEPEND",,cXmlRet,1,0)
			If InTransact()
				DisarmTransaction()
			Endif
		Endif

	Case ( cTypeTrans == TRANS_RECEIVE )
		Do Case
			Case ( cTypeMsg == EAI_MESSAGE_WHOIS )
				cXmlRet := '2.000|2.003|2.004|3.000'
			Case ( cTypeMsg == EAI_MESSAGE_RESPONSE )
				If lRet
					oXml := XmlParser(cXml, "_", @cErroXml, @cWarnXml)
					If oXml <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
						Fi080Respo(@oXml)
						oXml:=nil
						DelClassIntF()
					Else
						lRet:=.F.
						cXmlRet:=STR0001//'Erro no xml recebido.'
					Endif
				Endif
			Case ( cTypeMsg == EAI_MESSAGE_BUSINESS )
				If lRet
					oXml := XmlParser(cXml, "_", @cErroXml, @cWarnXml)
					If oXml <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
						aRet:=Fi080Rece(@oXml,cVersion)
						lRet:=aRet[1]
						cXmlRet:=aRet[2]
						DelArray(@aRet)
						oXml:=nil
						DelClassIntF()
					Else
						lRet:=.F.
						cXmlRet:=STR0001//'Erro no xml recebido.'
					Endif
				Endif
		EndCase
EndCase

RestArea(aAreaSE5)
DelArray(@aAreaSE5)

RestArea(aAreaSE2)
DelArray(@aAreaSE2)

RestArea( aArea )
DelArray(@aArea)

cXmlRet:=EncodeUTF8(cXmlRet)

Return { lRet, cXmlRet, cRequest }

//-------------------------------------------------------------------
/*/{Protheus.doc} F80MontInt
Recebe um registro no Protheus e gera o InternalId deste registro

@param		cFil		Filial do Registro
@Param		cPrefix	Prefixo do titulo
@param		cNum		Numeo do titulo
@param		cparcel	parcela do titulo
@param		cTipo		Tipo do titulo
@param		cFornece	Fornecedor do titulo
@param		cLoja		Loja do título
@param   cSequencia  Sequencia da baixa do titulo

@author  Jandir Deodato
@version P11.8
@since   30/04/13
@return  cRetorno - Retorna o InternalId do registro

@sample  exemplo de retorno - {'Empresa'|'xFilial'|'Prefixo'|'Numero'|'Parcela'|'Tipo'|'Fornecedor'|'Loja'|'Sequencia}}
								//		01		02				03		04			05		06			07		08			09
/*/
//-------------------------------------------------------------------
Function F80MontInt(cFil,cPrefix,cNum,cParcel,cTipo,cFornece,cLoja,cSequencia)

Local cRetCode:=''

Default cFil := xFilial('SE2')

cFil := xFilial("SE2",cFil)

cRetCode:=cEmpAnt+'|'+rTrim(cFil)+'|'+rTrim(cPrefix)+'|'+rTrim(cNum)+'|'+rTrim(cParcel)+'|'+rTrim(cTipo)+'|'+rTrim(cFornece)+'|'+rTrim(cLoja)+'|'+rTrim(cSequencia)

Return cRetCode

//-------------------------------------------------------------------
/*/{Protheus.doc} F80GetInt
Recebe um codigo, busca seu internalId e faz a quebra da chave

@param   cCode		 InternalID recebido na mensagem.
@param   cMarca      Produto que enviou a mensagem

@author  Jandir Deodato
@version P11.8
@since   30/04/13
@return  aRetorno Array contendo os campos da chave primaria do titulo a receber,a sequencia da baixa  e o seu internalid.

@sample  exemplo de retorno - {.T., {'Empresa', 'xFilial', 'Prefixo', 'Numero', 'Parcela','Tipo','cFornece','Loja',Sequecia},InternalId}
/*/										//   01          02         03        04          05      06     07         08    09
//-------------------------------------------------------------------

Function F80GetInt(cCode, cMarca)

Local cValInt		:= ''
Local aRetorno	:= {}
Local aAux			:= {}
Local nX			:= 0
Local aCampos		:= {cEmpAnt,'E2_FILIAL','E2_PREFIXO','E2_NUM','E2_PARCELA','E2_TIPO','E2_FORNECE','E2_LOJA','E5_SEQ'}

cValInt := CFGA070Int(cMarca,'SE2','E2_BAIXA',cCode)

If !Empty(cValInt)
	aadd(aRetorno,.T.)

	aAux := Separa(cValInt,'|')

	aadd(aRetorno,aClone(aAux))
	aadd(aRetorno,cValInt)

	aRetorno[2][1] := Padr(aRetorno[2][1],Len(cEmpAnt))

	For nx := 2 to len(aRetorno[2]) //corrigindo  o tamanho dos campos
		aRetorno[2][nX] := Padr(aRetorno[2][nX],TamSX3(aCampos[nx])[1])
	Next nx
Else
	aadd(aRetorno,.F.)
Endif

DelArray(@aAux)

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} Fi070Rece(oXml)
	Função de processamento do recebimento da baixa a receber - Via mensagem única

	@param	oXml		Objeto Xml ja parseado
	@param	cVersion	Caratcter Informando a versão do XML

	@author	Jandir Deodato
	@version	P11
	@since	03/07/2013
	@return	lRet	- Indica se o processamento ocorreu com sucesso ou não
	@Return	cXmlRet - Mensagem Xml gerada no processamento
	
/*/
//-------------------------------------------------------------------
Function Fi080Rece(oXml,cVersion)

Local lRet					:= .T.
Local cXmlRet				:= ''
Local cExternalId			:= ''
Local cTitInter			:= ''
Local cMarca				:= ''
Local cAlias				:= 'SE2'
Local cRequest			:= ''
Local cPrefix				:= ''
Local cNum					:= ''
Local cParcel				:= ''
Local cTipo				:= ''
Local cFornece			:= ''
Local cLoja				:= ''
Local aArea				:= GetArea()
Local aTitulo				:= {}
Local aInterBx			:= {}
Local aRet					:= {}
Local nOpc					:= 0

Default cVersion := ''

If XmlChildEx(oXml:_TotvsMessage:_BusinessMessage,'_BUSINESSREQUEST') <> nil .and. XmlChildEx(oXml:_TotvsMessage:_BusinessMessage:_BusinessRequest,'_OPERATION') <> NIL
	cRequest:= oXml:_TotvsMessage:_BusinessMessage:_BusinessRequest:_Operation:Text
Endif

IF Upper(Alltrim(cRequest))=='ACCOUNTPAYABLEDOCUMENTDISCHARGE'
	nOpc:=3
ElseIf Upper(Alltrim(cRequest))=='REVERSALOFACCOUNTPAYABLEDOCUMENTDISCHARGE'
	nOpc:=5
Else
	lRet:=.F.
	cXmlRet+=STR0002+ " " //'O conteúdo  da tag Request é inválido ou não foi enviado.'
Endif

If XmlChildEx(oXml:_TotvsMessage:_MessageInformation,'_PRODUCT') <> nil .and. XmlChildEx(oXml:_TotvsMessage:_MessageInformation:_Product,'_NAME') <> NIL
	cMarca:=oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
Else
	lRet:=.F.
	cXmlRet+=STR0003 +" "//'Não foi encontrada a tag que identifica a marca integrada.'
Endif

If(oXml:=XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage,'_BUSINESSCONTENT'))==nil//a partir deste ponto, utilizo somente informações da business
	lRet:=.F.
	cXmlRet+=STR0004	//'BusinessContent não encontrada na mensagem.'
Endif

If 	lRet
	 cExternalId:=Fi080Parse(@oXml,"_InternalId")

	If !Empty (cExternalId)
		aInterBx:=F80GetInt(cExternalId, cMarca)

		If (nOpc==3 .and. !aInterBx[1]) //se inclusão, nao deve achar correspondente. Se estorno, obrigatório ter
			cTitInter:=Fi080Parse(@oXml,'_AccountPayableDocumentInternalId')

			aTitulo:=F55GetInt(cTitInter, cMarca,cAlias)//Resgatando os dados do título pelo InternalId

			If aTitulo[1]
				cPrefix:=aTitulo[2][3]
				cNum:=aTitulo[2][4]
				cParcel:=aTitulo[2][5]
				cTipo:=aTitulo[2][6]
				cFornece:=aTitulo[2][7]
				cLoja:=aTitulo[2][8]
			Else
				lRet:=.F.
				cXmlRet:=STR0005
			Endif

			DelArray(@aTitulo)
		ElseIf (nOpc==5 .and. aInterBx[1])
			cPrefix:=aInterBx[2][3]
			cNum:=aInterBx[2][4]
			cParcel:=aInterBx[2][5]
			cTipo:=aInterBx[2][6]
			cFornece:=aInterBx[2][7]
			cLoja :=aInterBx[2][8]
		Else
			lRet:=.F.

			If nOpc==3
				cXmlRet:=STR0006//'Já existe movimento de baixa com este InternalId.'
				cXmlRet+=" "+STR0007//"Caso deseje modificar esta baixa, é necessário realizar o estorno da baixa e baixar o título novamente."
			Else
				cXmlRet:=STR0008//'Não foi encontrada a baixa para realizar o estorno.'
			Endif
		EndIf

		If lRet
			aRet:=Fi080Baixa(@oXml,nOpc,cMarca,cPrefix,cNum,cParcel,cTipo,cFornece,cLoja,iif(aInterBx[1],aInterBx[2][9],'');
			, cExternalId,iif(aInterBx[1],aInterBx[3],''), cVersion)//prefixo, num, parcela, tipo

			lRet:=aRet[1]
			cXmlRet:=aRet[2]
			DelArray(@aRet)
		Endif

		DelArray(@aInterBx)
	Else
		lRet:=.F.
		cXmlRet:=STR0009//'A tag InternalId não foi encontrada na mensagem.'
	Endif
Endif

RestArea(aARea)
DelArray(@aArea)

Return {lRet,cXmlRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} Fi080Baixa(oXml,nOpc,cMarca,cPrefix,cNum,cParcel,cTipo,cFornece,cLoja,cSeq,cExternalId,cInternalId)
	Função de processamento da baixa a receber

	@param	oXml		Objeto Xml ja parseado
	@Param nOpc		Opção da baixa - 3: baixa, 5 - estorno da baixa
	@Param cMarca		Marca integrada
	@param	cPrefix	Prefixo do título
	@param	cNum		Numeo do titulo
	@param cParcel	Parcela do titulo
	@param	cTipo		Tipo do titulo
	@param	cFornece	Fornecedor do título
	@param cLoja		Loja do Fornecedor
	@Param cSeq		Sequencia da baixa
	@param cExternalId Codigo externo recebico
	@param	cInternalId	Código Interno
	@param	cVersion	Versao

	@author	Jandir Deodato
	@version	P11
	@since	03/07/2013
	@return	lRet	- Indica se o processamento ocorreu com sucesso ou não
	@Return	cXmlRet - Mensagem Xml gerada no processamento

/*/
//-------------------------------------------------------------------

Function Fi080Baixa(oXml,nOpc,cMarca,cPrefix,cNum,cParcel,cTipo,cFornece,cLoja,cSeq,cExternalId,cInternalId,cVersion)

Local aArea		:= GetArea()
Local aCab			:= {}
Local aBanco		:= {}
Local aErroAuto	:= {}
Local lRet			:= .T.
Local cXmlRet		:= ''
Local cMotBaixa	:= ''
Local cCodMtBx	:= ''
Local cBanco		:= ''
Local cHist		:= ''
Local cLogErro	:= ''
Local cAlias		:= "SE2"
Local cCampo		:= "E2_BAIXA"
Local nX			:= 0
Local nJuros		:= 0
Local nMulta		:= 0
Local nDesconto	:= 0
Local nTaxa		:= 0
Local nOpBaixa	:= 1
Local dDtBaixa	:= CtoD("//")
Local dDtEntrada	:= CtoD("//")
Local aMotBx		:= ReadMotBx()

Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .T.

Default cVersion		:= ''

If nOpc==5
	Private aBaixaSE5:={}//utilizado para capturar a sequencia de baixa no E5
Endif

AADD(aCab,{"E2_PREFIXO",cPrefix,NIL})
AADD(aCab,{"E2_NUM",cNum,NIL})
AADD(aCab,{"E2_PARCELA",cParcel,NIL})
AADD(aCab,{"E2_TIPO",cTipo,NIL})
AADD(aCab,{"E2_FORNECE",cFornece,NIL})
AADD(aCab,{"E2_LOJA",cLoja,NIL})

If nOpc==3 //inclusão da baixa
	dDtBaixa:=StoD(StrTran(Fi080Parse(@oXml,'_PaymentDate'),"-"))

	If !Empty(dDtBaixa)
		AADD(aCab,{"AUTDTBAIXA",dDtBaixa,NIL}) // Data de Lançamento da Baixa no Sistema (AUTDTBAIXA)
	Endif

	dDtEntrada:=StoD(StrTran(Fi080Parse(@oXml,'_DebitDate'),"-"))

	If !Empty(dDtEntrada)
		AADD(aCab,{"AUTDTDEB",dDtEntrada,NIL}) // Data em que o Valor foi debitado na Conta da Empresa
	Endif

	AADD(aCab,{"AUTVLRPG",Val(Fi080Parse(@oXml,'_PaymentValue')),NIL}) // Valor do Pagamento (AUTVLRPG)
	nTaxa:=Val(Fi080Parse(@oXml,'_CurrencyRate'))

	If nTaxa > 0
		AADD(aCab,{"AUTTXMOEDA",nTaxa,NIL})
	EndIf

	cCodMtBx := Fi080Parse(@oXml,"_PaymentMethodCode")
	cMotBaixa := RetMotBx( 1 , cCodMtBx , cVersion , Alltrim( Fi080Parse( @oXml , "_PaymentMethodString" ) ) )

	if Val(cVersion) >= 3
		If (nY := ascan(aMotBx,{|x| SubStr(x,1,3) == cMotBaixa })) > 0 
			cMotBaixa := SubStr(aMotBx[nY],1,3)				
		Elseif !(Val(cCodMtBx) <= 020 .or. Val(cCodMtBx) == 999)
			cLogErro := "PaymentMethodCode esta incorreto."
			// Monta XML de Erro de execução da rotina automatica.
			lRet:=.F.
			cXMLRet:= cLogErro
			DelArray( @aErroauto )
		Else
			cLogErro := "PaymentMethodString nao esta cadastrado no sistema."
			// Monta XML de Erro de execução da rotina automatica.
			lRet:=.F.
			cXMLRet:= cLogErro
			DelArray( @aErroauto )
		EndIf
	EndIf
	
	If Empty(cMotBaixa)
		cMotBaixa := Fi080Parse(@oXml,"_CustomPaymentMethod")
	Endif

	If !Empty(cMotBaixa)
		AADD(aCab,{"AUTMOTBX",cMotBaixa,NIL}) //Forma de Baixa
	Endif

	//Dados do banco
	cBanco:=Fi080Parse(@oXml,"_BankInternalId")

	If !Empty (cBanco)
		aBanco:=M70GetInt(cBanco,cMarca)

		If aBanco[1]
			AADD(aCab,{"AUTBANCO",aBanco[2][3],NIL}) //Portador
			AADD(aCab,{"AUTAGENCIA",aBanco[2][4],NIL}) //Portador
			AADD(aCab,{"AUTCONTA",aBanco[2][5],NIL}) //Portador
		Else
			cXmlRet:=STR0010//'O banco da baixa não foi encontrado. Verifique.'
			lRet:=.F.
		Endif

		DelArray(@aBanco)
	Endif

	If lRet
		cHist:=Fi080Parse(@oXml,"_HistoryText")

		If !Empty(cHist)
			AADD(aCab,{"AUTHIST",cHist,NIL})
		EndIf
		//OtherValues
		iF(oXml:=XmlChildEx(oXml,'_OTHERVALUES')) <> NIL
			nJuros:=Val(Fi080Parse(@oXml,'_InterestValue'))
			If nJuros>0
				AADD(aCab,{"AUTJUROS",nJuros,NIL}) 	//Valor de Juros Pagos (AUTJUROS)
			EndIf
			nDesconto:=Val(Fi080Parse(@oXml,'_DiscountValue'))
			If nDesconto > 0
				AADD(aCab,{"AUTDESCONT",nDesconto,NIL}) 	//Valor de Desconto Concedido (AUTDESCONT)
			EndIf
			nMulta:=Val(Fi080Parse(@oXml,'_FineValue'))
			If nMulta >0
				AADD(aCab,{"AUTMULTA",nMulta,NIL})      //Valor da Multa Paga  (AUTMULTA)
			EndIf
		Endif
		//OtherValues
	Endif

Else//mensagem de estorno de baixa.
	Sel080Baixa("VL /BA /CP /",cPrefix,cNum,cParcel,cTipo,0,,cFornece,cLoja)
	nOpBaixa:=aScan(aBaixaSE5,{|x|rTrim(x[9])==rTrim(cSeq)})
	If nOpBaixa==0
		nOpBaixa:=1
	Endif
	aSize(aBaixaSE5,0)//zerando o array, pois o mesmo é usado também dentro da fina080
Endif

If lRet
	BEGIN TRANSACTION

		MSExecAuto({|x, y, z, a| FINA080(x, y, z, a)}, aCab, nOpc,, nOpBaixa)

		If lMsErroAuto
			aErroAuto := GetAutoGRLog()
			For nX := 1 To Len(aErroAuto)
				cLogErro += StrTran(StrTran(StrTran(aErroAuto[nX],"<"," "),"-"," "),"/"," ")+" "
			Next nX
			// Monta XML de Erro de execução da rotina automatica.
			lRet:=.F.
			cXMLRet:= cLogErro
			DelArray(@aErroauto)
		Else
			If nOpc==3 // inclusão da baixa
				cInternalId:=F80MontInt(,cPrefix,cNum,cParcel,cTipo,cFornece,cLoja,SE5->E5_SEQ)
				CFGA070Mnt( cMarca, cAlias,cCampo, cExternalId, cInternalId )
				cXmlRet:='<OriginInternalID>'+cExternalId+'</OriginInternalID>'
 				cXmlRet+=' <DestinationInternalID>'+cInternalId+'</DestinationInternalID>'
			Else//estorno da baixa
				CFGA070Mnt( , cAlias,cCampo, , cInternalId,.T. ) //excluindo o de-para
				cXmlRet:='<OriginInternalID>'+cExternalId+'</OriginInternalID>'
	 			cXmlRet+=' <DestinationInternalID>'+cInternalId+'</DestinationInternalID>'
			Endif
		Endif
	END TRANSACTION

Endif

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

If Valtype(aArray)=='A'
	aSize(aArray,0)
	aArray:=nil
Else
	aArray:=nil
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Fi080Parse(oXml,cXml)
	Função que parseia o objeto xml e verifica se o nó existe

	@param	oXml		Objeto xml a ser parseado
	@param cXml		String a ser verificada no xml

	@author	Jandir Deodato
	@version	P11
	@since	03/07/2013
	@return	cRet	conteúdo do no encontrado
/*/
//-------------------------------------------------------------------
Static Function Fi080Parse(oXml,cXml)
Local cRet		:= ''
Local oXmlAux	:= nil

oXmlAux:=XmlChildEx( oXml, Upper(cXml) )

If oXmlAux != nil
	cRet:=oXmlAux:Text
	oXmlAux:=nil
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

/*/{Protheus.doc} RetMotBx
  Resgata o motivo de baixa a partir dos códigos da mensagem única.

@since 05/07/13
@version P11
@param
	nTipo    - NUM - Identificação da coluna de retorno
				1 - códigos alfa - PROTHEUS
				2 - códigos numéricos - XML
	cCod     - CHAR - Código da Enumeração do XML
	cVersion - CHAR - Versão da mensagem.
@return
	cRet - CHAR - informação conforme o processo
/*/
Static Function RetMotBx(nTipo, cCod, cVersion , cStrMotBx)

Local cMotBxa   := ''
Local nValIdent := 0

Default cVersion := '0'
Default cStrMotBx := ''

Static aEnumBxas := {}
If empty(aEnumBxas)
	if Val(cVersion) >= 3 .and. cCod == '999' .and. !Empty(cStrMotBx)
		aAdd(aEnumBxas, {'999', substr( cStrMotBx , 1 , TamSX3('E5_MOTBX')[1] )})	
	EndIF
	aAdd(aEnumBxas, {'001', 'CH'})
	aAdd(aEnumBxas, {'002', 'CHT'})
	aAdd(aEnumBxas, {'003', 'CHA'})
	aAdd(aEnumBxas, {'004', 'BOR'})
	aAdd(aEnumBxas, {'005', 'DOC'})
	aAdd(aEnumBxas, {'006', 'GPS'})
	aAdd(aEnumBxas, {'007', 'BOL'})
	aAdd(aEnumBxas, {'008', 'CRC'})
	aAdd(aEnumBxas, {'009', 'DEP'})
	aAdd(aEnumBxas, {'010', 'LIC'})
	aAdd(aEnumBxas, {'011', 'CAX'})
	aAdd(aEnumBxas, {'012', 'NOR'})
	aAdd(aEnumBxas, {'013', 'DAC'})
	aAdd(aEnumBxas, {'014', 'DEV'})
	aAdd(aEnumBxas, {'015', 'DEB'})
	aAdd(aEnumBxas, {'016', 'VEN'})
	aAdd(aEnumBxas, {'017', 'LIQ'})
	aAdd(aEnumBxas, {'018', 'FAT'})
	aAdd(aEnumBxas, {'019', 'CRD'})
	aAdd(aEnumBxas, {'020', 'CEC'})
Endif

nValIdent := aScan(aEnumBxas, {|x| x[nTipo] == Alltrim(Upper(cCod))})
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
/*/{Protheus.doc} Fi080Respo(oXml)
	Trata a response da mensagem única

	@param	oXml		Objeto xml recebico

	@author	Jandir Deodato
	@version	P11
	@since	03/07/2013
	@return	nil
/*/
//-------------------------------------------------------------------

Function Fi080Respo(oXml)

Local cMarca		:= ''
Local cValInt		:= ''
Local cValExt		:= ''
Local lEstorno	:= .F.

If XmlChildEx(oXml:_TotvsMessage:_MessageInformation,'_TRANSACTION') != NIL
	If Alltrim(Upper(oXml:_TotvsMessage:_MessageInformation:_Transaction:Text))== 'REVERSALOFACCOUNTPAYABLEDOCUMENTDISCHARGE'
		lEstorno:=.T.
	Endif
Endif

If !lEstorno//no estorno, já excluiu a relação de de-para
	If XmlChildEx(oXml:_TotvsMessage:_MessageInformation:_Product,'_NAME') != nil
		cMarca :=  oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
	EndIf

   	If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent,'_ORIGININTERNALID') != NIL
   		cValInt := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_OriginInternalID:Text
   	EndIf

   	If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent,'_DESTINATIONINTERNALID') != nil
   	   cValExt := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_DestinationInternalID:Text
   	EndIf

	If !Empty(cValExt) .And. !Empty(cValInt)
	   CFGA070Mnt( cMarca, "SE2", "E2_BAIXA", cValExt, cValInt )
 	Endif
Endif

Return
