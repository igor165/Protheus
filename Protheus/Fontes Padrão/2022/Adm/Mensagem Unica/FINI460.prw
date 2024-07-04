#Include "PROTHEUS.ch"
#Include "FWMVCDEF.CH"
#Include "FWADAPTEREAI.CH"
#Include "FINI460.CH"

#DEFINE OPER_LIQUIDAR  16
#DEFINE OPER_CANCELAR  12

Static nFil			:= Nil
Static nPrf			:= Nil
Static nNum			:= Nil
Static nPcl			:= Nil
Static nTpo			:= Nil
Static nNat			:= Nil
Static nNosNum		:= Nil
Static nCodBar		:= Nil
Static nTamCCDeb	:= Nil
Static nTamCCCred	:= Nil
Static nTamCTDeb	:= Nil
Static nTamCTCred	:= Nil
Static nTamITDeb	:= Nil
Static nTamITCred	:= Nil
Static nTamClDeb	:= Nil
Static nTamClCred	:= Nil
Static nTamRegAca	:= Nil
Static nTamPerAca	:= Nil
Static nTamMatApl	:= Nil
Static nTamClasse	:= Nil
Static nTamItem		:= Nil
Static nTamContr	:= Nil
Static nTamPort		:= Nil
Static nTamAgenc	:= Nil
Static nTamConta	:= Nil
Static nTamData		:= Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FINI460
Mensagem unica de envio das mensagens FinancingTrading e ReversalOfFinancingTrading

@param cXml Xml passado para a rotina
@param nType Determina se e uma mensagem a ser enviada/recebida ( TRANS_SEND ou TRANS_RECEIVE)
@param cTypeMsg Tipo de mensagem ( EAI_MESSAGE_WHOIS,EAI_MESSAGE_RESPONSE,EAI_MESSAGE_BUSINESS)

@return lRet indica se a mensagem foi processada com sucesso
@return cXmlRet Xml de retorno da funcao

@author Pedro Pereira Lima
@since 28/03/2014
@version P12 
/*/
//-------------------------------------------------------------------
Function FINI460( cXml, nType, cTypeMsg, cVersion, cTransaction )
Local cXmlRet			:= ''
Local cEntity			:= ''
Local oXml				:= ''
Local cErroXml			:= ''
Local cWarnXml			:= ''
Local cVersao			:= ''
Local cBase				:= "E1_BASE"
Local cField			:= "E1_NUM"
Local cImpBase			:= "0.0"
Local cValInt			:= ""
Local cValExt			:= ""
Local cAliasSE1			:= "SE1"
Local cCliente			:= ""
Local cLoja				:= ""
Local cPrefixo			:= ""
Local cParcela			:= ""
Local cNumDoc			:= ""
Local cTipoDoc			:= ""
Local cNaturez			:= ""
Local cSE1				:= ""			
Local cSE1b				:= ""
Local cE1				:= ""
Local cImposto			:= ""
Local cLiquid			:= ""
Local nX				:= 0
Local nI				:= 0
Local nCount			:= 0
Local lRet				:= .T.
Local aDischarge		:= {}
Local aReceivable		:= {}
Local aRetorno			:= {}
Local aImposto			:= {"ISS", "IRRF", "INSS", "COFINS", "PIS", "CSLL"}
Local nTamCli  			:= TamSX3("A1_COD")[1]
Local nTamLoja			:= TamSX3("A1_LOJA")[1]
Local nDesconto			:= 0
Local cMsgVer			:= ''
//RM TO PROTHEUS
Local aBaixar			:= {}
Local aParcelas			:= {}
Local aNewTit			:= {}
Local cOrigin			:= ""
Local cOper				:= ""
Local cExtLiqID			:= ""
Local cIntLiqID			:= ""
Local cNossoNum			:= ""
Local cCodeBar			:= ""
Local nRecnobx			:= 0
Local nValJuros			:= 0
Local nValAbati			:= 0
Local nValAcres			:= 0
Local nValMult			:= 0
Local nValDesc			:= 0
Local cDateProc			:= ""
Local dDateProc			:= CTOD("//")
Local cValBaixar		:= ""
Local nValBaixar		:= 0
Local cValParcel		:= ""
Local nValParcel		:= 0
Local cVencParc			:= ""
Local dVencParc			:= CTOD("  /  /    ")
Local cVencEmis			:= ""
Local dVencEmis			:= CTOD("  /  /    ")
Local cErrorMessage		:= ""
Local nMoeda			:= 1
Local cMoeda			:= ""
Local cMoedaExt			:= ""
Local aTitSE1			:= {}
Local nLenSE1			:= 0
Local cContaDebito		:= ""
Local cContaCredito		:= ""
Local cCCDebito			:= ""
Local cCCCredito		:= ""
Local cItemDebito		:= ""
Local cItemCredito		:= ""
Local cClDebito			:= ""
Local cClCredito		:= ""
Local cRegAcademico		:= ""
Local cPerAcademico		:= ""
Local cMatrAplicada		:= ""
Local cItemContEdu		:= ""
Local cClasContEdu		:= ""
Local aItemCtb			:= {}
Local aClasCtb			:= {}
Local aCCusCtb			:= {}
Local aCntaCtb			:= {}
Local nCount1			:= 0 
Local cInternoID		:= ""
Local aAuxVa			:= {}
Local cValorVA			:= ""
Local aValDocVA			:= {}
Local aValorVa			:= {}
Local nValAcre			:= 0
Local nValDecre			:= 0
Local aNDocVAs			:= {}
Local cParcelaRec		:= ""
Local cPrefixoRec		:= ""
Local cTipoDocRec		:= ""
Local cDocNumRec		:= ""
Local cAuxRec			:= ""
Local aAuxRec			:= {}
Local cNatureRec		:= ""
Local nTamNumRec		:= TamSx3("E1_NUM")[1]
Local nTamPreRec		:= TamSx3("E1_PREFIXO")[1]
Local nTamTipRec		:= TamSx3("E1_TIPO")[1]
Local lFKC_FKD			:= TableInDic("FKD") .and. TableInDic("FKC") .And. ExistFunc("FVALACESS") /* verifica se as tabelas dos vlr acessórios estão no dicionário.*/
Local cEvent			:= ""
Local cRotina			:= 'FINA460'
Local cModeloMU			:= ''
Local cPortador			:= ''
Local cAgencia			:= ''
Local cConta			:= ''
Local cContrato			:= ''
Local lMvrmclass		:= GetNewPar("MV_RMCLASS", .F.)

Private cMarca			:= ""
Private cLote			:= LoteCont("FIN")
Private __nOpcOuMo      := 2
Private lParcAuto       := .F.
Private lAutoErrNoFile  := .T.

Default cTypeMsg		:= " "
Default cVersion		:= " "
Default cTransaction	:= " "

If Type( "__aBaixados" ) == "U" .And. Type( "__aNovosTit" ) == "U" .And. Type( "__cNroLiqui" ) == "U" 
	cLiquid		:= F460GetTit()[3]
	aDischarge	:= F460GetTit()[1]
	aReceivable	:= F460GetTit()[2]	
Else
	cLiquid		:= F460GetTit( __aBaixados, __aNovosTit, __cNroLiqui )[3]
	aDischarge	:= F460GetTit( __aBaixados, __aNovosTit, __cNroLiqui )[1]
	aReceivable	:= F460GetTit( __aBaixados, __aNovosTit, __cNroLiqui )[2]
EndIf

If nNum == NIL
	F460IniStat()
EndIf

cNaturez	:= SuperGetMV('MV_INTNAT',.F.,""  )
cNaturez	:= If( Empty(cNaturez),"",PadR(cNaturez, nNat ))

If IsInCallStack('F460ACommit')
	cEntity := 'FinancingTrading'
Else
	cEntity := 'ReversalOfFinancingTrading'
EndIf

//Verifico o tipo de mensagem
If nType == TRANS_SEND //Envio

	If !Inclui .And. !Altera
		cEvent := "delete"
		cModeloMU := 'REVERSALOFFINANCINGTRADING'
	Else
		cEvent := "upsert"
		cModeloMU := 'FINANCINGTRADING'
	EndIf

	If Empty( cVersion )
		lRet    := .F.
		cXmlRet := "Versão não informada no cadastro do adapter." //STR0027 //"Versão não informada no cadastro do adapter."
		Return { lRet, cXmlRet }
	Else
		cVersao := StrTokArr( cVersion, "." )[1]
	EndIf

	If cVersao	< '2.000'
		cXMLRet :=	'<BusinessRequest>'
		cXMLRet +=		'<Operation>' + cEntity + '</Operation>'
		cXMLRet +=		'<Identification>'
		cXMLRet +=			'<key name="InternalId">' + cEmpAnt + '|' + cFilAnt + '|' + 'L' + AllTrim(cLiquid) + '</key>'
		cXMLRet +=		'</Identification>'
		cXMLRet +=	'</BusinessRequest>'
		cXMLRet +=	'<BusinessContent>'
	Else
		cXMLRet :=	'<BusinessEvent>'
		cXMLRet +=		'<Operation>' + cEntity + '</Operation>'
		cXMLRet +=		'<Event>' + cEvent + '</Event>'
		cXMLRet +=		'<Identification>'
		cXMLRet +=			'<InternalId>' + cEmpAnt + '|' + cFilAnt + '|' + 'L' + AllTrim(cLiquid) + '</InternalId>'
		cXMLRet +=		'</Identification>'
		cXMLRet +=	'</BusinessEvent>'
		cXMLRet +=	'<BusinessContent>'
	EndIf

	If Upper(cEntity) == 'FINANCINGTRADING'

		cXMLRet +=		'<InternalId>' + cEmpAnt + '|' + cFilAnt + '|' + 'L' + AllTrim(cLiquid) + '</InternalId>'
		cXMLRet +=		'<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet +=		'<CompanyInternalId>' + cEmpAnt + '|' + RTrim(xFilial("SE1")) + '</CompanyInternalId>'
		cXMLRet +=		'<BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet +=		'<TradingDate>' + Transform(DtoS(dDataBase),"@R 9999-99-99") + '</TradingDate>'
		cXMLRet +=		'<TradingId>' + 'L' + AllTrim(cLiquid) + '</TradingId>'
		cXMLRet	+=		'<HistoryText/>'
		
		//TAGs da baixa de título para compor a lista de títulos faturados
		cXmlRet	+=	'<ListOfDischarge>'
		
		For nX := 1 To Len(aDischarge)
			DbSelectArea('SE1')
			DbSetOrder(1)
			DbSeek(xFilial('SE1') + PadR(aDischarge[nX][01],nPrf) + PadR(aDischarge[nX][02],nNum) + PadR(aDischarge[nX][03],nPcl) + PadR(aDischarge[nX][04],nTpo))
			cXmlRet +=	'<Discharge>'
			cXMLRet +=	'<AccountReceivableDocumentInternalId>'+F55MontInt(,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,,,'SE1')+'</AccountReceivableDocumentInternalId>'
				
			//A partir do registro posicionado na SE1 posiciono a SE5
			DbSelectArea('SE5')
			DbSetOrder(7) //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
			DbSeek(xFilial('SE5') + SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA))
				
			While !SE5->(Eof()) .And. xFilial('SE1') + SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) ==;
										SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
				If (SE5->E5_SITUACA == 'C' .And. SE5->E5_MOTBX != 'LIQ' .And. SE5->E5_TIPODOC != 'BA') .OR. (SE5->E5_TIPODOC $ 'C2|CM|CX|DC|J2|JR|M2|MT|VM')
					SE5->(DbSkip())
					Loop
				Else
					Exit
				EndIf
			EndDo
			
			If SE5->E5_VLDESCO > 0 .And. SE1->E1_VLBOLSA > 0 
				nDesconto := SE5->E5_VLDESCO - SE1->E1_VLBOLSA
			Else
				nDesconto := SE5->E5_VLDESCO
			EndIf
			
			//Adicionado a soma de desconto no valor de pagamento, pois na intgração do RMCLASSIS precisa passar o valor do título 
			//sem considerar os descontos efetuado no Backoffice, pois só é controlada a baixa e geração de novos títulos
			//devido ao NOSSONUMERO ser controlado pela RM.
			cXMLRet +=		'<PaymentValue>' + CValToChar(SE5->E5_VALOR+nDesconto) + '</PaymentValue>'
			cXMLRet +=		'<CustomerCode>' + IntCliExt(,,SE1->E1_CLIENTE,SE1->E1_LOJA,)[2] + '</CustomerCode>'
			cXMLRet +=		'<StoreId>' + RTrim(SE1->E1_LOJA) + '</StoreId>'
			cXMLRet	+=		'<FinancialCode>' + RTrim(SE1->E1_NATUREZ) + '</FinancialCode>'	
			cXmlRet +=	'</Discharge>'
		Next nX				

		cXmlRet += '</ListOfDischarge>'	
		//TAGs da baixa de título para compor a lista de títulos faturados
		
		//TAGs da inclusão de títulos para compor a lista de novos títulos gerados
		cXmlRet += '<ListOfNewDocuments>'
		For nX := 1 To Len(aReceivable)
			DbSelectArea('SE1')
			DbSetOrder(1)
			DbSeek(xFilial('SE1') + PadR(aReceivable[nX][01],nPrf) + PadR(aReceivable[nX][02],nNum) + PadR(aReceivable[nX][03],nPcl) + PadR(aReceivable[nX][04],nTpo))
			
			cXmlRet	+=	'<ReceivableDocument>'
			cXMLRet +=		'<InternalId>' + IntTRcExt(, SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)[2] + '</InternalId>'										 
			cXMLRet +=		'<DocumentPrefix>' + RTrim(SE1->E1_PREFIXO) + '</DocumentPrefix>'
			cXMLRet +=		'<DocumentNumber>' + RTrim(SE1->E1_NUM) + '</DocumentNumber>'
			cXMLRet +=		'<DocumentParcel>' + RTrim(SE1->E1_PARCELA) + '</DocumentParcel>'
			cXMLRet +=		'<DocumentTypeCode>' + RTrim(SE1->E1_TIPO) + '</DocumentTypeCode>'
			cXMLRet	+=		'<HolderCode>' + RTrim(SE1->E1_PORTADO) + '</HolderCode>'
			
			//Caso seja integração com RM Classis, passo a filial da tabela SA6 no HolderType
			//Solução paliativa para problema causado pelo compartilhamento da tabela SA6
			If lMvrmclass 
				cXMLRet	+=	'<HolderType>' + AllTrim(xFilial("SA6")) + '</HolderType>'
			Else
				cXMLRet	+=	'<HolderType/>'
			EndIf
			cXMLRet +=		'<AgencyNumber>' + AllTrim(SE1->E1_AGEDEP) + '</AgencyNumber>'
			cXMLRet +=		'<AccountNumber>' + AllTrim(SE1->E1_CONTA) + '</AccountNumber>'
			cXMLRet +=		'<ContractNumber>' + AllTrim(SE1->E1_CONTRAT) + '</ContractNumber>'	
			cXMLRet +=		'<IssueDate>' + Transform(DToS(SE1->E1_EMISSAO), "@R 9999-99-99") + '</IssueDate>'
			cXMLRet	+=		'<DiscountDate/>'
			cXMLRet	+=		'<DiscountPercentage>' + AllTrim(cValToChar(SE1->E1_DESCFIN)) + '</DiscountPercentage>'
			cXMLRet +=		'<InterestPercentage>' + AllTrim(Str(SE1->E1_PORCJUR)) + '</InterestPercentage>'
			cXMLRet +=		'<AssessmentValue>' + "0" + '</AssessmentValue>'
			cXMLRet +=		'<DueDate>' + Transform(DToS(SE1->E1_VENCTO), "@R 9999-99-99") + '</DueDate>'
			cXMLRet	+=		'<ExtendedDate/>'
			cXMLRet	+=		'<AccountingDate/>'
			cXMLRet	+=		'<ChargeInterest/>'
			cXMLRet +=		'<CustomerCode>' + RTrim(SE1->E1_CLIENTE) + '</CustomerCode>'							
			cXmlRet +=		'<CustomerInternalId>' + IntCliExt(/*Empresa*/, /*Filial*/, SE1->E1_CLIENTE, SE1->E1_LOJA, /*Versão*/)[2] + '</CustomerInternalId>'
			cXmlRet +=		'<StoreId>' + RTrim(SE1->E1_LOJA) + '</StoreId>'
			cXMLRet	+=		'<CustomerBankCode>' + RTrim(SE1->E1_BCOCLI) + '</CustomerBankCode>'
			cXMLRet +=		'<GrossValue>' + AllTrim(CValToChar(SE1->E1_VALOR)) + '</GrossValue>'
			cXMLRet	+=		'<InvoiceAmount/>'
			cXMLRet +=		'<CurrencyCode>' + PadL(SE1->E1_MOEDA, 2, '0') +'</CurrencyCode>'
			cXmlRet +=		'<CurrencyInternalId/>'
			cXMLRet +=		'<CurrencyRate>' + AllTrim(cValToChar(E1_TXMOEDA)) + '</CurrencyRate>'
			cXMLRet +=		'<Taxes>'
			
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
					cXMLRet += '<Tax CalculationBasis="' + cImpBase +'" CityCode="' + SA1->A1_COD_MUN + '"  CountryCode="' + SA1->A1_PAIS + '" Percentage="0.0" Reason="003" Recalculate="true" ReductionBasedPercent="0.0" StateCode="' + SA1->A1_ESTADO + '" Taxe="' + cImposto + '" Value="' + CValToChar(SE1->&(cSE1)) + '"/>'
				Endif
			Next nI
			cXMLRet +=		'</Taxes>'		
					
			aRateio := RatCAR(SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA)
	
			IIf(!Empty(aRateio), cXMLRet += '<ApportionmentDistribution>', '')
	
			For nI := 1 To Len(aRateio)
				cXMLRet +=		'<Apportionment>'
				cXMLRet +=			'<CostCenterInternalId/>'
				cXMLRet +=			'<ProjectInternalId>' + IIf(!Empty(AllTrim(aRateio[nI][6])), AllTrim(IntPrjExt(/*cEmpresa*/, /*cFilial*/, aRateio[nI][6])[2]), '') + '</ProjectInternalId>'
				cXMLRet +=			'<TaskInternalId>' + IIf(!Empty(AllTrim(aRateio[nI][7])), IntTrfExt(/*cEmpresa*/, /*cFilial*/, aRateio[nI][6], '0001', aRateio[nI][7])[2], '') + '</TaskInternalId>'
				cXMLRet +=			'<Value>' + cValToChar(IIf(!Empty(aRateio[nI][4]), aRateio[nI][4], 0)) + '</Value>'
				cXMLRet +=		'</Apportionment>'
			Next nI
	
			IIf(!Empty(aRateio), cXMLRet += '</ApportionmentDistribution>', '<ApportionmentDistribution/>')
	
			cXMLRet +=		'<Origin>' + AllTrim(SE1->E1_ORIGEM) + '</Origin>'
			cXMLRet +=		'<OurNumberBanking>' + AllTrim(SE1->E1_NUMBCO) + '</OurNumberBanking>'							 
			cXmlRet +=		'<FinancialNatureInternalId>' + F10MontInt(/*cFil*/, SE1->E1_NATUREZ) + '</FinancialNatureInternalId>'

			If AllTrim(cVersion) == '1.002'
				cXmlRet +=		'<FinancialIncrease>' + AllTrim(CValToChar(E1_ACRESC)) + '</FinancialIncrease>'
				cXmlRet +=		'<FinancialDecrease>' + AllTrim(CValToChar(E1_DECRESC)) + '</FinancialDecrease>'
			EndIf			

			cXmlRet +=	'</ReceivableDocument>'				
		Next nX
		cXmlRet += '</ListOfNewDocuments>'
		//TAGs da inclusão de títulos para compor a lista de novos títulos gerados			
	Else
		cXmlRet +=	'<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet +=	'<CompanyInternalId>' + cEmpAnt + '|' + RTrim(xFilial("SE1")) + '</CompanyInternalId>'
		cXmlRet +=	'<BranchId>' + cFilAnt + '</BranchId>'
		cXmlRet +=	'<ReversalDate>' + Transform(DtoS(dDataBase),"@R 9999-99-99") + '</ReversalDate>'
		cXmlRet +=	'<TradingId>' + 'L' + AllTrim( cLiquid ) + '</TradingId>'  
	EndIf
	
	cXMLRet +=	'</BusinessContent>'

ElseIf nType == TRANS_RECEIVE

	Do Case 
		Case cTypeMsg == EAI_MESSAGE_WHOIS
			cXmlRet := '1.000|1.001|1.002|2.000'
		Case cTypeMsg == EAI_MESSAGE_RESPONSE
			cXmlRet := 	cXml
			oXml := XmlParser(cXmlRet, "_", @cErroXml, @cWarnXml)
			
			If oXml != Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
				If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
					//Versão da Mensagem Única
					If XmlChildEx( oXml:_TOTVSMessage:_MessageInformation, '_VERSION') != Nil
						cVersao := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_Version:Text, ".")[1]
					Else
						lRet := .F.
						cXmlRet := STR0001 //"Versão da mensagem não informada!"
					EndIf
						
					//Recebe Nome do Produto (ex: RM ou PROTHEUS) e guarda na variavel cMarca
					If XmlChildEx( oXml:_TOTVSMessage:_MessageInformation:_Product, '_NAME') != Nil .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_Name:Text) 					
						cMarca :=  oXml:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
					Else
						lRet := .F.
						cXmlRet := STR0002 //"Erro no retorno. O Product é obrigatório!"							
					EndIf	
					
					If Upper(cEntity) == "FINANCINGTRADING"
				 
						If XmlChildEx( oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent, "_LISTOFINTERNALID") != Nil .AND. ;
								XmlChildEx( oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_LISTOFINTERNALID,"_INTERNALID") != Nil
	
							If ValType(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId) != "A"
								// Transforma em array
								XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_LISTOFINTERNALID:_INTERNALID, "_INTERNALID")
							EndIf							
	
							For nCount := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_LISTOFINTERNALID:_InternalId)
								cExternalId := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_LISTOFINTERNALID:_InternalId[nCount]:_Destination:Text
								cInternalId := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_LISTOFINTERNALID:_InternalId[nCount]:_Origin:Text
								cName := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_LISTOFINTERNALID:_InternalId[nCount]:_Name:Text
								
								If Upper( cName ) == "FINANCINGTRADINGINTERNALID"
									cAliasSE1 := "FO0"
									cField := "FO0_PROCESS"
								ElseIf Upper( cName ) == "ACCOUNTRECEIVABLEDOCUMENTINTERNALID"
									cAliasSE1 := "SE1"
									cField := "E1_NUM"
								EndIf
								// GRAVO NA XXF
								CFGA070Mnt(cMarca, cAliasSE1, cField, cExternalId, cInternalId, .F., 1)
							Next nCount
								
						EndIf
					
						If XmlChildEx( oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent, '_LISTOFOURNUMBER') != Nil .AND. ;
								XmlChildEx( oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfOurNumber, '_RETURNITEM') != Nil
									
							If ValType(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfOurNumber:_RETURNITEM) != "A"
								// Transforma em array
								XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfOurNumber:_RETURNITEM, "_RETURNITEM")
							EndIf
															
							For nCount := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfOurNumber:_ReturnItem)
								cExternalId:= oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfOurNumber:_ReturnItem[nCount]:_DestinationInternalId:Text
								cInternalId:= oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfOurNumber:_ReturnItem[nCount]:_OriginInternalId:Text
								aRetorno := F460GetInt(cExternalId, cMarca)
										
								If aRetorno[1]
									SE1->(DbSetOrder(1))
									If SE1->(DbSeek(aRetorno[2,2]+aRetorno[2,3]+aRetorno[2,4]+aRetorno[2,5]+aRetorno[2,6]))
										RecLock('SE1',.F.)
											SE1->E1_NUMBCO := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfOurNumber:_ReturnItem[nCount]:_OurNumber:Text 
											SE1->E1_CODBAR := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfOurNumber:_ReturnItem[nCount]:_BarCode:Text
										MsUnlock()
									EndIf
								EndIf															
							Next nCount
						EndIf
					Else 
						//REVERSALOFFINANCINGTRADING
						If XmlChildEx( oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent, '_LISTOFINTERNALID') != Nil .AND. ;
								XmlChildEx( oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_LISTOFINTERNALID, '_INTERNALID') != Nil
	
							If ValType(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_LISTOFINTERNALID:_INTERNALID) != "A"
								// Transforma em array
								XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_LISTOFINTERNALID:_INTERNALID, "_INTERNALID")
							EndIf							
	
							For nCount := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_LISTOFINTERNALID:_InternalId)
								cExternalId := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_LISTOFINTERNALID:_InternalId[nCount]:_Destination:Text
								cInternalId := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_LISTOFINTERNALID:_InternalId[nCount]:_Origin:Text
								cName := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_LISTOFINTERNALID:_InternalId[nCount]:_Name:Text
								
								If Upper( cName ) == "FINANCINGTRADINGINTERNALID"
									//cAliasSE1 := "FO0"
									//cField := "FO0_PROCESS"
								ElseIf Upper( cName ) == "ACCOUNTRECEIVABLEDOCUMENTINTERNALID"
									cAliasSE1 := "SE1"
									cField := "E1_NUM"
								EndIf
								
								//Limpo a XXF após confirmada a exclusão
								CFGA070Mnt(cMarca, cAliasSE1, cField, cExternalId,cInternalId , .T.)
							Next nCount
								
						EndIf   					
					Endif						
				Else 
					//Se não for array
					If ValType(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message) != "A"
						//Transforma em array
						XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
					EndIf
		
					//Percorre o array para obter os erros gerados
					For nCount := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
						cErroXml := oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + Chr(10)
					Next nCount
			
					lRet := .F.
					cXmlRet := cErroXml											
				EndIf				
			Else
				lRet := .F.
				cXmlRet := STR0003 //"Erro no parser!"
			EndIf	
		
		Case cTypeMsg == EAI_MESSAGE_RECEIPT
		
		Case cTypeMsg == EAI_MESSAGE_BUSINESS .And. lFKC_FKD /* Valores Acessórios */

			oXml := XmlParser(cXml, "_", @cErroXml, @cWarnXml)
			
			If oXml <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
				If ( XmlChildEx( oXml:_TOTVSMessage, '_BUSINESSMESSAGE' ) <> nil )
					
					//Versão da Mensagem Única
					If XmlChildEx( oXml:_TOTVSMessage:_MessageInformation, '_VERSION') <> Nil
						cVersao := oXml:_TOTVSMessage:_MessageInformation:_Version:Text
						If cVersao < "2.000"
							lRet    := .F.
							cXmlRet := OemToAnsi(STR0004) + CRLF //"Esta operação somente é suportada no Protheus a partir da versão 2.000 da mensagem FinancingTranding."
						Endif				
					Else
						lRet    := .F.
						cXmlRet := OemToAnsi(STR0001) + CRLF //"Versão da mensagem não informada!"
					EndIf
					
					//Recebe Nome do Produto (ex: RM ou PROTHEUS) e guarda na variavel cMarca
					If lRet .and. XmlChildEx( oXml:_TOTVSMessage:_MessageInformation:_Product, '_NAME') <> Nil
						cMarca :=  oXml:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
					Else
						lRet    := .F.
						cXmlRet += OemToAnsi(STR0002) + CRLF //"Erro no retorno. O Product é obrigatório!"
					EndIf

					//Começa a processar a BusinessEvent
					If lRet .and.  XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage, '_BUSINESSEVENT') <> Nil
						
						//Verifica o tipo de operação a ser realizada, com base no valor da TAG <Event>
						cOper := Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
						 
						//Internal ID da Liquidacao (RM) - A DESENVOLVER
						If XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent,'_INTERNALID') <> Nil
							cExtLiqID := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
							//Encontro o Internal ID da Liquidacao (Protheus)
							//Apenas verifica se existe o Registro no XXF para saber se é Inclusão, Alteração ou Exclusão
							If !Empty(cExtLiqID)  
								aExtLiqID := F460RGetInt(cExtLiqID, cMarca)     
								If aExtLiqID[1]
									If cOper != 'DELETE' // Registro encontrado na integração
										//Aviso que não pode alterar processo de Liquidacao
										lRet    := .F.
										cXmlRet += OemToAnsi(STR0005) + CRLF //"Não é possivel a alteração de processo de Acordo/Liquidacao."
									Endif 
								ElseIf cOper == 'DELETE'
									//Aviso que não pode alterar processo de Liquidacao
									lRet    := .F.
									cXmlRet += OemToAnsi(STR0006) + CRLF //"Não consta o InternalID do processo na estrutura do XML (Business Content - InternalID)." 
								EndIf
							EndIf
                       	Else
							//Aviso que não pode alterar processo de Liquidacao
							lRet    := .F.
							cXmlRet += OemToAnsi(STR0007) + CRLF //"Não consta o InternalID do processo na estrutura do XML (Business Content)." 
						Endif
                       
						//Verifico se é uma inclusão
						If lRet .and. cOper == 'UPSERT'  
                        
                        	//Data do processo da Liquidacao (RM)
							If XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent,'_TRADINGDATE') <> Nil
								cDateProc := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TradingDate:Text 
								dDateProc := StoD(StrTran(cDateProc,"-"))
								If Empty(dDateProc)
									//Valor Inválido 
									lRet    := .F.
									cXmlRet += OemToAnsi(STR0008) + CRLF //"Data de processamento Inválido (TRADINGDATE)." 
	    						Endif
							EndIf
	
							//----------------------------------------------------------------------------------------------------------	     
							//Titulos a Baixar
							//----------------------------------------------------------------------------------------------------------
							If lRet .and. XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_LISTOFDISCHARGE') != Nil .AND. ;
							XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge, '_DISCHARGE') != Nil
										
								If ValType(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge) != "A"
									// Transforma em array
									XmlNode2Arr(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge, "_Discharge")
								EndIf
								
								If (nTamArr := Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge)) > 0
										
									For nCount := 1 To nTamArr
										
										//Valor da baixa do titulo (RM)
										If XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount],'_PAYMENTVALUE') <> Nil
											cValBaixar := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_PaymentValue:Text
											If !Empty(cValBaixar)
												nValBaixar := Val(cValBaixar)
											Else
												lRet    := .F.
												cXmlRet += OemToAnsi(STR0009) + CRLF //"Valor Inválido para baixa de títulos (PAYMENTVALUE)." 
												Exit															
											Endif
										EndIf
											
										//Internal ID do titulo (RM)
										cExternalId:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_AccountReceivableDocumentInternalId:Text
										
										//Obtém o valor interno ID do titulo (Protheus)
										aRetorno := IntTRcInt(cExternalId, cMarca)
										If aRetorno[1]
											cFilTit	:= PadR(aRetorno[2][2],nFil)
											cPrefixo := PadR(aRetorno[2][3],nPrf)
											cNumDoc	:= PadR(aRetorno[2][4],nNum)
											cParcela := PadR(aRetorno[2][5],nPcl)
											cTipoDoc := PadR(aRetorno[2][6],nTpo)
										
											SE1->(DbSetOrder(1))
											//Procuro o titulo a baixar  
											//SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO
											If SE1->(DbSeek(cFilTit + cPrefixo + cNumDoc + cParcela + cTipoDoc))
												nRecnoBx := SE1->(Recno())
											Else
												lRet    := .F.
												cXmlRet += OemToAnsi(STR0010) + CRLF //"Titulo negociado nao encontrado no Protheus." 
												Exit															
											EndIf
										Else
										
											lRet := .F.
											cXmlRet += OemToAnsi(STR0010) + CRLF //"Titulo negociado nao encontrado no Protheus." 
											Exit
										
										EndIf  
										
										//Valor do Acrescimo (RM)
										If XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount],'_FINANCIALINCREASE') <> Nil
											cValAcre := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_FinancialIncrease:Text
											If !Empty(cValAcre)
												nValAcre := Val(cValAcre)
											Else
												nValAcre := 0			
											Endif
										EndIf
										
										//Valor do Decrescimo (RM)
										If XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount],'_FINANCIALDECREASE') <> Nil
											cValDecre := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_FinancialDecrease:Text
											If !Empty(cValDecre)
												nValDecre := Val(cValDecre)
											Else
												nValDecre := 0			
											Endif
										EndIf
										
										/////////////////////////////////////
										//Tratamento da Tag Other Values   //
										/////////////////////////////////////
										If XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount], '_OTHERVALUES') != Nil .And. ;
											ValType(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_OtherValues) <> "U"
											//////////////////////////////////////////////
											//Efetuando a Leitura da TAG Interest Value	//
											//////////////////////////////////////////////
											iF XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_OtherValues, '_INTERESTVALUE') <> Nil .And. ;
											! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_OtherValues:_InterestValue:Text)
													
												nValJuros := Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_OtherValues:_InterestValue:Text)
													
											EndIf
											
											//////////////////////////////////////////////
											//Efetuando a Leitura da TAG DiscountValue	//
											//////////////////////////////////////////////
											If XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_OtherValues, '_DISCOUNTVALUE') <> Nil .And. ;
											! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_OtherValues:_DiscountValue:Text)
													
												nValDesc := Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_OtherValues:_DiscountValue:Text)
													
											EndIf
											
											//////////////////////////////////////////////
											//Efetuando a Leitura da TAG AbatementValue	//
											/////////////////////////////////////////////
										 	If XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_OtherValues, '_ABATEMENTVALUE') <> Nil .And. ;
											! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_OtherValues:_AbatementValue:Text)
												
												nValAbati := Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_OtherValues:_AbatementValue:Text)
												
											EndIf
											
											//////////////////////////////////////////////
											//Efetuando a Leitura da TAG ExpensesValue	//
											//////////////////////////////////////////////
											If XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_OtherValues, '_EXPENSESVALUE') <> Nil .And. ; 
											! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_OtherValues:_ExpensesValue:Text)
												
												nValAcres := Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_OtherValues:_ExpensesValue:Text)
												
											EndIf
											
											//////////////////////////////////////////
											//Efetuando a Leitura da TAG FineValue	//
											//////////////////////////////////////////
											If XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_OtherValues, '_FINEVALUE') <> Nil .And. ;
											! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_OtherValues:_FineValue:Text)
												
											  	nValMult := Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_OtherValues:_FineValue:Text)
												
											EndIf
											
										EndIf
										
										////////////////////////////////////////////////
										//Tratamento da Tag ListOfComplementaryValues //
										////////////////////////////////////////////////
										If(XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount],'_LISTOFCOMPLEMENTARYVALUES') <> NIL)
											If(ValType(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_ListOfComplementaryValues) <> "U")
												/////////////////////////////////////////
												//Tratamento da Tag ComplementaryValue //
												/////////////////////////////////////////
												If(XmlChildEX(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_LISTOFCOMPLEMENTARYVALUES,'_COMPLEMENTARYVALUE') <> NIL)
													
													If(ValType(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_ListOfComplementaryValues:_ComplementaryValue) == "A" )
														For nCount1 := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_ListOfComplementaryValues:_ComplementaryValue)	
															/////////////////////////////////////////
															//Tratamento da Tag ComplementaryValue //
															/////////////////////////////////////////
															If(Valtype(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_ListOfComplementaryValues:_ComplementaryValue[1]:_ComplementaryValueInternalId) == "O" .And. ;
															! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_ListOfComplementaryValues:_ComplementaryValue[nCount1]:_ComplementaryValueInternalId:Text))
																cInternoID := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_ListOfComplementaryValues:_ComplementaryValue[nCount1]:_ComplementaryValueInternalId:Text
																aAuxVa := F035GETINT(cInternoID,cMarca)
																If(aAuxVa[1])
																																
																	////////////////////////////////////
																	//Tratamento da Tag InformedValue //
																	////////////////////////////////////
																	If(Valtype(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_ListOfComplementaryValues:_ComplementaryValue[nCount1]:_InformedValue)== "O" .And. ;
																	! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_ListOfComplementaryValues:_ComplementaryValue[nCount1]:_InformedValue:Text))
																			
																		cValorVA := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_ListOfComplementaryValues:_ComplementaryValue[nCount1]:_InformedValue:Text
																			
																		aAdd(aValorVa,{aAuxVa[2][3],CalcVA(aAuxVa[2][3],Val(cValorVA))})
																		
																	EndIf
																Else
																
																	lRet := .F.
																	cXmlRet := STR0021 + cInternoID //"Erro ao Encontrar o Valor Acessorio"
																
																EndIf
															EndIf
														Next nCount1
													Else
														/////////////////////////////////////////
														//Tratamento da Tag ComplementaryValue //
														/////////////////////////////////////////
														If(type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_ListOfComplementaryValues:_ComplementaryValue:_ComplementaryValueInternalId") == "O" .And. ;
														! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_ListOfComplementaryValues:_ComplementaryValue[nCount1]:_ComplementaryValueInternalId:Text))
															cInternoID := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_ListOfComplementaryValues:_ComplementaryValue[nCount1]:_ComplementaryValueInternalId:Text
															aAuxVa := F035GETINT(cInternoID,cMarca)
															If(aAuxVa[1])
															
																////////////////////////////////////
																//Tratamento da Tag InformedValue //
																////////////////////////////////////
																If(Valtype(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_ListOfComplementaryValues:_ComplementaryValue[nCount1]:_InformedValue)== "O" .And. ;
																! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_ListOfComplementaryValues:_ComplementaryValue[nCount1]:_InformedValue:Text))
																		
																	cValorVA := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_ListOfComplementaryValues:_ComplementaryValue[nCount1]:_InformedValue:Text
																		
																	aAdd(aValorVa,{aAuxVa[2][3],CalcVA(aAuxVa[2][3],Val(cValorVA))})
																	
																EndIf
															Else
															
																lRet := .F.
																cXmlRet := STR0021 + cInternoID //"Erro ao Encontrar o Valor Acessorio"
															
															EndIf
														EndIf
													Endif
												Else
													/////////////////////////////////////////
													//Tratamento da Tag ComplementaryValue //
													/////////////////////////////////////////
													If(! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_ListOfComplementaryValues:_ComplementaryValue:_ComplementaryValueInternalId:Text))
														cInternoID := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_ListOfComplementaryValues:_ComplementaryValue:_ComplementaryValueInternalId:Text
														aAuxVa := F035GETINT(cInternoID,cMarca)
														If(aAuxVa[1])
														
															////////////////////////////////////
															//Tratamento da Tag InformedValue //
															////////////////////////////////////
															If(ValType(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_ListOfComplementaryValues:_ComplementaryValue:_InformedValue) <> NIL .And. ;
															! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_ListOfComplementaryValues:_ComplementaryValue:_InformedValue:Text))
																	
																cValorVA := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfDischarge:_Discharge[nCount]:_ListOfComplementaryValues:_ComplementaryValue:_InformedValue:Text																	
																
																aAdd(aValorVa,{aAuxVa[2][3],CalcVA(aAuxVa[2][3],Val(cValorVA))})
																	
															EndIf
														Else
																													
															lRet := .F.
															cXmlRet := STR0021 + cInternoID //"Erro ao Encontrar o Valor Acessorio"
																															
														EndIf
													EndIf													
												EndIf
											EndIf
										EndIf
										//Estrutura aBaixar
										//[01] Recno SE1
										//[02] Valor Baixa
										//[03] Valor Juros
										//[04] Valor Desconto
										//[05] Valor Abatimento
										//[04] Valor Decrescimo
										//[07] Valor Multa
										//[08] Data de Processamento
										//[09] Valor de Acrescimo
										//[10] Valor de Decrescimo
										
										AADD(aBaixar, {nRecnoBx,nValBaixar,nValJuros,nValDesc,nValAbati,nValAcres,nValMult,dDateProc,nValAcre,nValDecre})
										
										aAdd(aValDocVA,aClone(aValorVA))
										aValorVA := {}
									Next nCount
								Else
									//Não foram enviadas informações dos titulos a baixar
									lRet    := .F.
									cXmlRet += OemToAnsi(STR0011) + CRLF		//"Não foram enviadas as informações de titulos a baixar (DISCHARGE)." 
						   		EndIf        


								//----------------------------------------------------------------------------------------------------------						   		
								//Titulos a Gerar
								//----------------------------------------------------------------------------------------------------------								
								If lRet .and. XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_LISTOFNEWDOCUMENTS') != Nil .AND. ;
								XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments, '_RECEIVABLEDOCUMENT') != Nil
										
									If ValType(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument) != "A"
										// Transforma em array
										XmlNode2Arr(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument, '_ReceivableDocument')
									EndIf
									
									If (nTamArr := Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument)) > 0
										
										For nCount := 1 To nTamArr
											////////////////////////////////////
											//Numero do Documento vindo da RM //
											////////////////////////////////////
											If(XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount],'_DOCUMENTNUMBER') <> NIL)
												
												cDocNumRec := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_DOCUMENTNUMBER:Text
												
												If(Len(cDocNumRec) > nTamNumRec )
												
													lRet := .F.
													cXmlRet += "Numero do Titulo é maior que o aceito no Protheus " + cDocNumRec
													Exit
												
												EndIf
											EndIf
											
											////////////////////////////////
											//Numero do Prefixo do Titulo //
											////////////////////////////////
											If(XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount],'_DOCUMENTPREFIX') <> NIL)
												
												cPrefixoRec := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_DOCUMENTPREFIX:Text
												
												If(Len(cPrefixoRec) > nTamPreRec)
												
													lRet := .F.
													cXmlRet += "Numero do Prefixo do Titulo é maior que o aceito no Protheus " + cPrefixoRec
													Exit
												
												EndIf
											EndIf
											
											////////////////////////////////
											//Numero da Parcela do Titulo //
											////////////////////////////////
											If(XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount],'_DOCUMENTPARCEL') <> NIL)
												cParcelaRec := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_DOCUMENTPARCEL:Text
												lParcAuto   := .T.
											Else
												lParcAuto := .F.
											EndIf
											///////////////////
											//Tipo do Titulo //
											///////////////////
											If(XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount],'_DOCUMENTTYPECODE') <> NIL)
												
												cTipoDocRec := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_DOCUMENTTYPECODE:Text
												
												If(Len(cTipoDocRec) > nTamTipRec)
												
													lRet := .F.
													cXmlRet += "Tipo do Documento é maior que o aceito no Protheus " + cTipoDocRec
													Exit
												
												ElseIf(Len(cTipoDocRec) < nTamTipRec)
												
													cTipoDocRec := PadR(cTipoDocRec,nTamTipRec )
												
												EndIf
											EndIf
											///////////////////////
											//Natureza do Titulo
											//Verifico se está no XML'
											///////////////////////
											If(XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount],'_FINANCIALNATUREINTERNALID') <> NIL)
											
												cAuxRec := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_FINANCIALNATUREINTERNALID:TEXT
												aAuxRec := F10GetInt(cAuxRec,cMarca)
												If (aAuxRec[1])
													cNatureRec := aAuxRec[2][3]											
												Else
													lRet := .F.
													cXmlRet += "Natureza não encontrada no de/para " + cNatureRec
													Exit
												EndIf												
											Else
												// pega natureza do parâmetro MV_INTNAT
												IF !Empty(cNaturez)
													cNatureRec := cNaturez
												Else
													lRet := .F.
													cXmlRet += "Natureza não encontrada no de/para " + cNatureRec
													Exit
												EndIf										
											EndIf

											//Dados bancarios
											cPortador	:= ""
											cAgencia	:= ""
											cConta		:= ""
											cContrato	:= ""
											If XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount],'_HOLDERCODE') <> Nil
												cPortador := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_HolderCode:Text
												If XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount],'_AGENCYNUMBER') <> Nil
													cAgencia := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_AgencyNumber:Text
												EndIf
												If XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount],'_ACCOUNTNUMBER') <> Nil
													cConta := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_AccountNumber:Text
												EndIf
												If XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount],'_CONTRACTNUMBER') <> Nil
													cContrato := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ContractNumber:Text
												EndIf
											EndIf

											//Valor da baixa do titulo (RM)
											If XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount],'_GROSSVALUE') <> Nil
												cValParcel := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_GrossValue:Text
												If !Empty(cValParcel)
													nValParcel := Val(cValParcel)
													If nValParcel <= 0
														lRet    := .F.
													Endif
												Else
													lRet := .F.
												Endif

												//Valor Inválido 
												If !lRet						
													cXmlRet += OemToAnsi(STR0012) + CRLF //"Valor Inválido para a parcela de negociação (GROSSVALUE)." 
													Exit															
												Endif
											EndIf
				
											//Internal ID do Cliente das parcelas (RM)
											If lRet .and. Empty(cCliente)
												If XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount],'_CUSTOMERINTERNALID') <> Nil
													cExtCustom := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_CustomerInternalId:Text
		
													//Obtém o valor interno ID do titulo (Protheus)
													aRetorno := IntCliInt(cExtCustom, cMarca)
													If aRetorno[1]
														SA1->(DbSetOrder(1))
														//aAdd(aResult, cEmpresa + '|' + RTrim(xFilial('SA1')) + '|' + PadR(cCliente, TamSX3('A1_COD')[1]) + '|' + PadR(cLoja, TamSX3('A1_LOJA')[1]) + '|C')  
														//SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO
														If SA1->(DbSeek(xFilial("SA1")+PadR(aRetorno[2,3],nTamCli)+PadR(aRetorno[2,4], nTamLoja )))
															cCliente := SA1->A1_COD
															cLoja := SA1->A1_LOJA
														Else
															lRet    := .F.
															cXmlRet += OemToAnsi(STR0013 + cExtCustom) + CRLF //"Não existe cliente com esse ID " 
															Exit															
														EndIf
													EndIf 
												Endif 
											Endif	

											//Origem das parcelas (RM)
											If Empty(cOrigin)
												//Origem (RM)
												cOrigin:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_Origin:Text
											Endif

											//Internal ID do titulo gerado (RM)
											cExternalId:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_InternalId:Text

											//Obtém o valor interno ID do titulo (Protheus)
											aRetorno := IntTRcInt(cExternalId, cMarca)
											If aRetorno[1]
												lRet    := .F.
												cXmlRet += OemToAnsi(STR0014 + cExternalId) + CRLF //"Já existe título com este ID " 
												Exit															
											EndIf  

											//Data do processo da Liquidacao (RM)			
											If lRet .and. XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount],'_DUEDATE') <> Nil
												cVencParc := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_DueDate:Text 
												dVencParc := StoD(StrTran(cVencParc,"-"))
												If Empty(dVencParc) .or. dVencParc < dDateProc
													lRet    := .F.
													cXmlRet += OemToAnsi(STR0015) + CRLF //"Data de vencimento da parcela é inválida (DUEDATE)." 
													Exit															
												Endif
											EndIf
											
											//Data do Emissão da Liquidacao (RM)			
											If lRet .and. XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount],'_ISSUEDATE') <> Nil
												cVencEmis := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_IssueDate:Text 
												dVencEmis := StoD(StrTran(cVencEmis,"-"))
												If Empty(dVencEmis) .or. dVencEmis < dDateProc
													lRet    := .F.
													cXmlRet += OemToAnsi(STR0024) + CRLF //"Data da emissão da parcela é inválida (ISSUEDATE)"
													Exit															
												Endif
											EndIf

											//Moeda
											If lRet .and. Empty(cMoeda)
												If XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount],'_CURRENCYINTERNALID') <> Nil
													cMoedaExt := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_CurrencyInternalId:Text 
													If !Empty(cMoedaExt)
														aAux := IntMoeInt(cMoedaExt, cMarca) //Adapter CTBI140
														If !aAux[1]
															lRet := .F.
															cXmlRet := aAux[2]
														Else
															nMoeda := Val(aAux[2][3]) 
														EndIf
													Else
														nMoeda := 1
													Endif
												Else
													nMoeda := 1
												Endif
											EndIf
	
											cNossoNum := ""
											//Nosso Numero (RM)			
											If lRet .and. XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount],'_OURNUMBER') <> Nil
												cNossoNum := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_OurNumber:Text 
											EndIf

											//Codigo de Barras (RM)
											cCodeBar := ""			
											If lRet .and. XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount],'_BARCODE') <> Nil
												cCodeBar := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_Barcode:Text 
											EndIf
											
											///////////////////////////////////
											//Tratamento do Codigo InternalID//
											///////////////////////////////////
											
											If(lRet .And. XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount],'_ACCOUNTING') <> NIL)
												////////////////
												//Conta Debito//
												////////////////
												If(XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING,'_DEBITACCOUNTINTERNALID') <> NIL .And. ;
												! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_DebitAccountInternalId:Text))
													
													aCntaCtb := F460GetCnt(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_DebitAccountInternalId:Text,cMarca)
													If(aCntaCtb[1])
													
														cContaDebito := aCntaCtb[2][3] 
													
													EndIf
													
												Else													
													If(XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING,'_DEBITACCOUNTCODE') <> NIL)
													
														cContaDebito := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_DebitAccountCode:Text
													
													EndIf													
												EndIf
												
												/////////////////
												//Conta Credito//
												/////////////////
												If(XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING,'_CREDITACCOUNTINTERNALID') <> NIL .And. ;
												! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_CREDITACCOUNTINTERNALID:Text))
													
													aCntaCtb := F460GetCnt(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_CREDITACCOUNTINTERNALID:Text, cMarca)
													If(aCntaCtb[1])
													
														cContaCredito := aCntaCtb[2][3] 
													
													EndIf
													
												Else
													If(XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING,'_CREDITACCOUNTCODE') <> NIL)
													
														cContaCredito := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_CREDITACCOUNTCODE:Text
													
													EndIf
												EndIf
												
												//////////////////////////
												//Centro de Custo Debito//
												//////////////////////////
												If(XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING,'_DEBITCOSTCENTERINTERNALID') <> NIL .And. ;
												! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_DEBITCOSTCENTERINTERNALID:Text))
													
													aCCusCtb := IntCusInt(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_DEBITCOSTCENTERINTERNALID:Text,cMarca)
													If(aCCusCtb[1])
														
														cCCDebito := aCCusCtb[2][3]
														
													EndIf
													
												Else
													If(XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING,'_DEBITCOSTCENTERCODE' ) <> NIL)
													
														cCCDebito := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_DEBITCOSTCENTERCODE:Text
													
													EndIf 
												EndIf
												
												///////////////////////////
												//Centro de Custo Credito//
												///////////////////////////
												If(XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING,'_CREDITCOSTCENTERINTERNALID') <> NIL .And. ;
												! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_CreditCostCenterInternalId:Text))
													
													//Limpando o Vetor
													aCCusCtb := {}
													aCCusCtb:= IntCusInt(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_CreditCostCenterInternalId:Text,cMarca)
													If(aCCusCtb[1])
													
														cCCCredito := aCCusCtb[2][3]
													
													EndIf
													
												Else
													If(XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING,'_CREDITCOSTCENTERCODE' ) <> NIL)
													
														cCCCredito := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_CreditCostCenterCode:Text
													
													EndIf 
												EndIf
												
												////////////////////////
												//Item Contabil Debito//
												////////////////////////
												If(XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING,'_DEBITACCOUNTINGITEMINTERNALID') <> NIL .And. ;
												! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_DEBITACCOUNTINGITEMINTERNALID:Text))
													
													//efetuando a busca do DE/PARA
													aItemCtb := C040GetInt(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_DEBITACCOUNTINGITEMINTERNALID:Text,cMarca)
													If(aItemCtb[1])
													
														cItemDebito := aItemCtb[2][3]
													
													EndIf
													
												Else
													If(XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING,'_DEBITACCOUNTIGITEMCODE' ) <> NIL)
													
														cItemDebito := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_DEBITACCOUNTIGITEMCODE:Text
													
													EndIf 
												EndIf
												
												/////////////////////////
												//Item Contabil Credito//
												/////////////////////////
												If(XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING,'_CREDITACCOUNTINGITEMINTERNALID') <> NIL .And. ;
												! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_CREDITACCOUNTINGITEMINTERNALID:Text))
													
													//Limpando o Vetor
													aItemCtb := {}
													//efetuando a busca do DE/PARA
													aItemCtb := C040GetInt(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_CREDITACCOUNTINGITEMINTERNALID:Text,cMarca)
													If(aItemCtb[1])
													
														cItemCredito := aItemCtb[2][3]
													
													EndIf
													
												Else
													If(XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING,'_CREDITACCOUNTINGITEMCODE' ) <> NIL)
													
														cItemCredito := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_CREDITACCOUNTINGITEMCODE:Text
													
													EndIf 
												EndIf
												
												//////////////////////////
												//Classe de Valor Debito//
												//////////////////////////
												If(XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING,'_DEBITCLASSVALUEINTERNALID') <> NIL .And. ;
												! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_DebitClassValueInternalId:Text))
												
													//efetuando a busca do DE/PARA
													aClasCtb := C060GetInt(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_DebitClassValueInternalId:Text,cMarca)
													If(aClasCtb[1])
													
														cClDebito := aClasCtb[2][3]
													
													EndIf
													
												Else
													If(XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING,'_DEBITCLASSVALUECODE' ) <> NIL)
													
														cClDebito := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_DebitClassValueCode:Text
													
													EndIf 
												EndIf
												
												///////////////////////////
												//Classe de Valor Credito//
												///////////////////////////
												If(XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING,'_CREDITCLASSVALUEINTERNALID') <> NIL .And. ;
												! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_CreditClassValueInternalId:Text))
												
													//Limpando o Vetor
													aClasCtb := {}
													//efetuando a busca do DE/PARA
													aClasCtb := C060GetInt(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_CreditClassValueInternalId:Text,cMarca)
													If(aClasCtb[1])
													
														cClCredito := aClasCtb[2][3] 
													
													EndIf
													
												Else
													If(XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING,'_CREDITCLASSVALUECODE' ) <> NIL)
													
														cClCredito := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ACCOUNTING:_CreditClassValueCode:Text
													
													EndIf 
												EndIf
											EndIf
											
											/////////////////////////////////
											//Tratamento do Totvs Educacional//
											/////////////////////////////////
											If(lRet .And. XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount],'_OTHER') <> NIL)
												
												/////////////////////////////////////
												//Registro Academico do Educacional//
												/////////////////////////////////////
												If(XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_Other,'_ACADEMICRECORD') <> NIL .And. ;
												! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_Other:_AcademicRecord:Text))
												
													cRegAcademico := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_Other:_AcademicRecord:Text
												
												EndIf
												
												////////////////////////////////////
												//Periodo Academico do Educacional//
												////////////////////////////////////
												If(XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_Other,'_ACADEMICPERIOD') <> NIL .And. ;
												! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_Other:_AcademicPeriod:Text))
												
													cPerAcademico := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_Other:_AcademicPeriod:Text
												
												EndIf
												
												//////////////////////////////////
												//Matriz Aplicada do Educacional//
												//////////////////////////////////
												If(XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_Other,'_APPLIEDMATRIX') <> NIL .And. ;
												! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_Other:_AppliedMatrix:Text))
												
													cMatrAplicada := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_Other:_AppliedMatrix:Text
												
												EndIf
												
												////////////////////////////////
												//Item do Aluno 			  //
												////////////////////////////////
												If(XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_Other,'_ITEMINTERNALID') <> NIL .And.;
												! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_Other:_ItemInternalId:Text))
												
													cItemContEdu := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_Other:_ItemInternalId:Text
												
												EndIf
												
												//////////////////////////////////
												//Classe do Aluno				//
												//////////////////////////////////
												If(XmlChildEx( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_Other,'_CLASS') <> NIL .And. ;
												! Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_Other:_CLASS:Text))												
													cClasContEdu := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_Other:_CLASS:Text
												
												EndIf
											EndIf																			
											
											////////////////////////////////////////////////
											//Tratamento da Tag ListOfComplementaryValues //
											////////////////////////////////////////////////
											If  XmlChildEX( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount],'_LISTOFCOMPLEMENTARYVALUES' ) <> NIL .And. ;
												  ValType( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ListOfComplementaryValues ) <> "U"
												/////////////////////////////////////////
												//Tratamento da Tag ComplementaryValue //
												/////////////////////////////////////////
												If XmlChildEX( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_LISTOFCOMPLEMENTARYVALUES,'_COMPLEMENTARYVALUE' ) <> NIL
													
													If ValType( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ListOfComplementaryValues:_ComplementaryValue ) == "A"
														For nCount1 := 1 To Len( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ListOfComplementaryValues:_ComplementaryValue )	
															/////////////////////////////////////////
															//Tratamento da Tag ComplementaryValue //
															/////////////////////////////////////////
															If Valtype( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ListOfComplementaryValues:_ComplementaryValue[1]:_ComplementaryValueInternalId ) == "O" .And. ;
															! Empty( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ListOfComplementaryValues:_ComplementaryValue[nCount1]:_ComplementaryValueInternalId:Text )
																cInternoID := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ListOfComplementaryValues:_ComplementaryValue[nCount1]:_ComplementaryValueInternalId:Text
																aAuxVa := F035GETINT( cInternoID, cMarca )
																If aAuxVa[1]
																
																	////////////////////////////////////
																	//Tratamento da Tag InformedValue //
																	////////////////////////////////////
																	If Valtype( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ListOfComplementaryValues:_ComplementaryValue[nCount1]:_InformedValue )== "O" .And. ;
																	! Empty( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ListOfComplementaryValues:_ComplementaryValue[nCount1]:_InformedValue:Text )
																																										
																		cValorVA := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ListOfComplementaryValues:_ComplementaryValue[nCount1]:_InformedValue:Text																			
																		aAdd( aValorVa, { aAuxVa[2][3], cValorVA } )
																		
																	EndIf
																Else
																
																	lRet := .F.
																	cXmlRet := STR0021 + cInternoID //"Erro ao Encontrar o Valor Acessorio"
																
																EndIf
															EndIf
														Next nCount1
													Else
														/////////////////////////////////////////
														//Tratamento da Tag ComplementaryValue //
														/////////////////////////////////////////
														If ! Empty( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ListOfComplementaryValues:_ComplementaryValue:_ComplementaryValueInternalId:Text )
															cInternoID := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ListOfComplementaryValues:_ComplementaryValue:_ComplementaryValueInternalId:Text
															aAuxVa := F035GETINT( cInternoID, cMarca )
															If aAuxVa[1]
															
																////////////////////////////////////
																//Tratamento da Tag InformedValue //
																////////////////////////////////////
																If ValType( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ListOfComplementaryValues:_ComplementaryValue:_InformedValue ) <> NIL .And. ;
																! Empty( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ListOfComplementaryValues:_ComplementaryValue:_InformedValue:Text )
																		
																	cValorVA := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfNewDocuments:_ReceivableDocument[nCount]:_ListOfComplementaryValues:_ComplementaryValue:_InformedValue:Text																			
																	aAdd( aValorVa, { aAuxVa[2][3], cValorVA } )																
																		
																EndIf
															Else
																														
																lRet := .F.
																cXmlRet := STR0021 + cInternoID //"Erro ao Encontrar o Valor Acessorio"
																																
															EndIf
														EndIf													
													EndIf
													
												EndIf
											EndIf
																																												
											//Estrutura aParcelas
											//[01] Valor da Parcela
											//[02] Data de Vencimento
											//[03] Cliente
											//[04] Loja 
											//[05] InternalID do Titulo (RM)
											//[06] Nosso Numero (RM)
											//[07] Código de Barras (RM)
											//[08] Centro de Custo Credito(RM)
											//[09] Centro de Custo Debito(RM)
											//[10] Conta Contabil Credito(RM)
											//[11] Conta Contabil Debito(RM)
											//[12] Item Contabil Credito(RM)
											//[13] Item Contabil Debito(RM)
											//[14] Classe Contabil Credito(RM)
											//[15] Classe Contabil Debito(RM)
											//[16] Registro Academico do Aluno (RM)
											//[17] Periodo Academico do Aluno  (RM)
											//[18] Matriz Aplicada do Aluno    (RM)
											//[19] Item (RM)
											//[20] Classe do Aluno(RM)
											//[21] Parcela do Titulo
											//[22] Prefixo do Titulo
											//[23] Tipo do Titulo
											//[24] Numero do Titulo
											//[25] Natureza do Titulo
											//[26] Contrato
											//[27] Portador
											//[28] Depositaria 
											//[29] Num da Conta
											
											AADD(aParcelas, {nValParcel,dVencParc,cCliente,cLoja,cExternalId,cNossoNum,cCodeBar,;
															 cCCCredito,cCCDebito,cContaCredito,cContaDebito,cItemCredito,cItemDebito,;
															 cClCredito,cClDebito,cRegAcademico,cPerAcademico,cMatrAplicada,cItemContEdu,;
															 cClasContEdu,cParcelaRec,cPrefixoRec,cTipoDocRec,cDocNumRec,cNatureRec,cContrato,;
															 cPortador,cAgencia,cConta,dVencEmis,})
															 
											aAdd( aNDocVAs, aClone( aValorVA ) )
											aValorVA := {}
																										
										Next nCount
									Else
										lRet    := .F.
										cXmlRet += OemToAnsi(STR0016) + CRLF //"Não foram enviadas as informações de titulos a baixar (RECEIVABLEDOCUMENT)." 

									EndIf    
								Else
									lRet := .F.
									cXmlRet += OemToAnsi(STR0017) + CRLF //"Verifique a estrutura da mensagem (_LISTOFNEWDOCUMENTS)" 
								
								Endif

								//----------------------------------------------------------------------------------------------------------						   		
								//INCLUSÃO DA LIQUIDAÇÃO
								//----------------------------------------------------------------------------------------------------------								
								If lRet
									lRet := F460LiqAut( 3, dDateProc, aBaixar, aParcelas, cOrigin, @cErrorMessage, aNewTit, aValDocVA, aNDocVAs )
									
									//Se commitou corretamente mando a lista de internal ID
									If !lRet
										//Monta XML de Erro de execução da rotina automatica.
										cXMLRet := _noTags(cErrorMessage)
									Else
										//Monta xml com status do processamento da rotina automatica OK.
										cXMLRet := "<ListOfInternalId>"	
										//Monta xml com status do processamento da rotina automatica OK.
										cIntLiqID := Alltrim(aNewTit[1])
										
										cXMLRet +=     "<InternalId>"
										cXMLRet +=       "<Name>FinancingTradingInternalId</Name>"
										cXMLRet +=       "<Origin>" + CExtLiqID + "</Origin>"
										cXmlRet +=       "<Destination>" + cIntLiqID + "</Destination>"
										cXMLRet +=     "</InternalId>"

										// Grava o registro na tabela XXF (de/para)
										CFGA070Mnt(cMarca, "FO0", "FO0_PROCESS", cExtLiqID, cIntLiqID, .F., 1)
										
										For nX := 2 to Len(aNewTit)
											/*
											aNewTit[nX,1] Prefixo
											aNewTit[nX,2] Numero
											aNewTit[nX,3] Parcela
											aNewTit[nX,4] Tipo
											aNewTit[nX,5] cValExt (InternalID Titulo (Externo)) 
											*/ 
											//Grava o registro na tabela XXF (de/para)
											cValInt := IntTRcExt(, , aNewTit[nX,1], aNewTit[nX,2], aNewTit[nX,3], aNewTit[nX,4])[2]
											cValExt := aNewTit[nX,5]
											// Grava o registro na tabela XXF (de/para)
											CFGA070Mnt(cMarca, "SE1", "E1_NUM", cValExt, cValInt, .F., 1)
										
											//Monta xml com status do processamento da rotina automatica OK.
											cXMLRet +=     "<InternalId>"
											cXMLRet +=       "<Name>AccountReceivableDocumentInternalId</Name>"
											cXMLRet +=       "<Origin>" + cValExt + "</Origin>"
											cXmlRet +=       "<Destination>" + cValInt + "</Destination>"
											cXMLRet +=     "</InternalId>"
										
										Next Nx
																
										cXMLRet += "</ListOfInternalId>"
										
									EndIf
								EndIf
							Else
								lRet := .F.
								cXmlRet += OemToAnsi(STR0018) + CRLF //"Verifique a estrutura da mensagem (_LISTOFDISCHARGE)" 
							Endif
						ElseIf lRet .and. cOper == 'DELETE' 

							//{cEmpAnt,'FO0_FILIAL','FO0_PROCES','FO0_VERSAO'}
							cEmpAnt   := aExtLiqID[2,1]							
							cFilProc  := xFilial("FO0",aExtLiqID[2,2])
							cProcess  := aExtLiqID[2,3]
							cVersao	  := aExtLiqID[2,4]
							cIntLiqID := aExtLiqID[3] //InternalID Protheus
							FO0->(dbSetOrder(1))
							If FO0->(MsSeek(cFilProc+cProcess+cVersao))
								//Cancelo o Processo
								lRet := FI460Can(FO0->FO0_NUMLIQ,@cErrorMessage)
								// Excluo o registro na tabela XXF (de/para)
								CFGA070Mnt(cMarca, "FO0", "FO0_PROCESS", cExtLiqID, cIntLiqID, .T.)
								
								aTitSE1 := aClone(F460IntId())
								
								nLenSE1 := Len(aTitSE1)
								
								For nX := 1 To nLenSE1
									// Excluo o registro na tabela XXF (de/para)
									cValInt := aTitSE1[nX]
									CFGA070Mnt(cMarca, "SE1", "E1_NUM",/*cValExt*/, cValInt, .T.)
								Next
								
								If nLenSE1 > 0
									F460IArrSE1()
									aSize(aTitSE1,0)
									aTitSE1 := Nil
								Endif
								
								cXmlRet := ""
							Else
								lRet := .F.
								cXmlRet := OemToAnsi(STR0019) + cExtLiqID
							Endif
							
						Endif
					EndIf
				Endif
			EndIf
	EndCase
		
EndIf

aSize(aBaixar,0)
aBaixar := Nil

aSize(aParcelas,0)
aParcelas := Nil

aSize(aNewTit,0)
aNewTit := Nil

aSize(aNDocVAs,0)
aNDocVAs := Nil

aSize(aValorVA,0)
aValorVA := Nil

aSize(aAuxVa,0)
aAuxVa := Nil

Return { lRet, cXmlRet, "FINANCINGTRADING" }

//-------------------------------------------------------------------
/*/{Protheus.doc} RatCAR
Recebe a chave de busca do Titulo à Receber e monta o rateio.

@author  Pedro Pereira Lima  
@version P12
@since   08/04/2014

@return aResult
/*/
//-------------------------------------------------------------------
Static Function RatCAR(cChave)
Local aResult  := {}
Local aPrjtTrf := {}
Local aCntrCst := {}
Local nI       := 0

AFT->(dbSetOrder(2)) // AFT_FILIAL+AFT_PREFIX+AFT_NUM+AFT_PARCEL+AFT_TIPO+AFT_CLIENT+AFT_LOJA+AFT_PROJET+AFT_REVISA+AFT_TAREFA

//Povoa o array de Projeto
If AFT->(dbSeek(cChave))
	While AFT->(!Eof()) .And. cChave == AFT->AFT_FILIAL + AFT->AFT_PREFIX + AFT->AFT_NUM + AFT->AFT_PARCEL + AFT->AFT_TIPO + AFT->AFT_CLIENT + AFT->AFT_LOJA
		aAdd(aPrjtTrf, Array(4))
		nI++
		aPrjtTrf[nI][1] := AFT->AFR_PROJET
		aPrjtTrf[nI][2] := Nil
		aPrjtTrf[nI][3] := AFT->AFR_TAREFA
		aPrjtTrf[nI][4] := AFT->AFR_VALOR1
		AFT->(dbSkip())
	EndDo
EndIf

// Não há Rateio por Centro de Custo
aAdd(aCntrCst,{Nil, Nil, Nil, Nil, 100})

aResult := IntRatPrjCC(aCntrCst, aPrjtTrf)

Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} F460GetInt
Recebe um codigo, busca seu internalId e faz a quebra da chave

@param   cCode		 InternalID recebido na mensagem.
@param   cMarca      Produto que enviou a mensagem


@author  Pâmela Bernardo
@version P12
@since   25/04/16
@return  aRetorno Array contendo os campos da chave primaria do titulo a receber,a sequencia da baixa  e o seu internalid.

@sample  exemplo de retorno - {.T., {'Empresa', 'xFilial', 'Prefixo', 'Numero', 'Parcela','Tipo','Cliente','Loja',Sequecia},InternalId}
/*/										//   01          02         03        04          05      06     07         08    09
//-------------------------------------------------------------------
Function F460GetInt(cCode, cMarca)
//a função já esta implementada para a ocasiao de implementar a recepção da baixa.
Local cValInt	:= ''
Local aRetorno	:= {}
Local aAux		:= {}
Local nX		:= 0
Local aCampos	:= {cEmpAnt,'E1_FILIAL','E1_PREFIXO','E1_NUM','E1_PARCELA','E1_TIPO'}

cValInt := CFGA070Int(cMarca, 'SE1', 'E1_NUM', cCode)

If !Empty(cValInt)
	aadd(aRetorno,.T.)
	aAux:=Separa(cValInt,'|')
	aadd(aRetorno,aAux)
	aadd(aRetorno,cValInt)
	aRetorno[2][1]:=Padr(aRetorno[2][1],Len(cEmpAnt))
	For nx:=2 to len (aRetorno[2])//corrigindo  o tamanho dos campos
		aRetorno[2][nX]:=Padr(aRetorno[2][nX],TamSX3(aCampos[nx])[1])
	Next
Else
	aadd(aRetorno,.F.)
Endif

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} F460RGetInt
Recebe um codigo, busca seu InternalId e faz a quebra da chave

@param cCodigo InternalID recebido na mensagem.
@param cMarca Produto que enviou a mensagem

@author	Mauricio Pequim Jr
@version 12.1.13
@since 19/07/2016
@return	aRetorno Array contendo os campos da chave primaria da natureza e o seu internalid.
@sample	exemplo de retorno - {.T., {'Empresa', 'xFilial', 'Codigo Processo','Versão'},InternalId}
/*/										//   01          02         03         
//-------------------------------------------------------------------
Function F460RGetInt(cCodigo, cMarca)
Local cValInt	:= ''
Local aRetorno	:= {}
Local aAux		:= {}
Local nX		:= 0
Local aCampos	:= {cEmpAnt,'FO0_FILIAL','FO0_PROCES','FO0_VERSAO'}

cValInt := CFGA070Int(cMarca, 'FO0', 'FO0_PROCES', cCodigo)
If !Empty(cValInt)
	aAux := Separa(cValInt,'|')
	
	aAdd(aRetorno, .T. )
	aAdd(aRetorno, aAux )
	aAdd(aRetorno, cValInt )
	
	aRetorno[2][1] := Padr(aRetorno[2][1],Len(cEmpAnt))
	
	For nX :=2 to 	Len(aRetorno[2]) //corrigindo  o tamanho dos campos
		aRetorno[2][nX] := Padr(aRetorno[2][nX],TamSX3(aCampos[nx])[1])
	Next nX
Else
	aAdd(aRetorno,.F.)
EndIf

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} F460RGetExt
Monta o InternalID do Título a Receber com o código passado
no parâmetro.

@param   cEmpresa   Código da empresa (Default cEmpAnt)
@param   cFil       Código da Filial (Default xFilial(FO0))
@param   cProcess   Processo de Liquidação
@param   cVersao    Versão do processo de Liquidação via mensagem única (Default 0001)

@author  Mauricio Pequim Jr
@version P12
@since   25/07/2016
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado.
         No segundo parâmetro uma variável string com o InternalID
         montado.

@sample  F460RGetExt(, , '000000000000124', '0001')
         irá retornar {'T1|D MG 01|000000000000124|0001'}
/*/
//-------------------------------------------------------------------
Function F460RGetExt(cEmpresa, cFil, cProcess, cVersao)

Local aResult  := {}

Default cEmpresa := cEmpAnt
Default cFil     := xFilial('FO0')
Default cVersao  := '0001'

aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cProcess) + '|' + RTrim(cVersao))

Return aResult

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F460LiqAut
Rotina automática de Liquição

@param	nOpc 		   Identifica Inclusão ou Exclusão do processo
@param	dDateProc	   Data do Processo da Liquidação
@param	aBaixar		   Informações dos títulos a serem baixados
@param	aParcelas	   Informações das parcelas a gerar
@param	cOrigin		   Origem da Liquidação
@param	cErrorMessage  Mensagem de erro em caso de falha no processo (MVC)
@param	aValDocVA 	   Vetor com os Valores Acessorios por documento a baixar
@param  aNDocVAs       Vetor com os valores acessórios por novo documento a ser gerado 

@author	Mauricio Pequim Jr
@version 12.1.13
@since	19/07/2016
@return	aRetorno Array contendo os campos da chave primaria da natureza e o seu internalid.
@sample	exemplo de retorno - {.T., {'Empresa', 'xFilial', 'Codigo Processo','Versão'},InternalId}
/*/									//   01          02         03             04 
//-------------------------------------------------------------------------------------------------

Function F460LiqAut( nOpc, dDateProc, aBaixar, aParcelas, cOrigin, cErrorMessage, aNewTit, aValDocVA, aNDocVAs )

Local oModel	:= NIL
Local oFO0		:= NIL
Local oFO1		:= NIL
Local oFO2		:= NIL
Local cPrefix	:= ""
Local cNumTit	:= ""
Local cTipo		:= ""
Local cLastParc	:= ""
Local cAtlzParc	:= ""
Local cNaturez	:= ""
Local cVersao 	:= '0001'	
Local cNomeCli	:= ''
Local cCliente	:= ''
Local cLoja		:= ''
Local cTitExtID	:= ''
Local nMoeda	:= 1
Local nTxMulta	:= 0
Local nTxJuros	:= 0
Local nTxJurGer	:= 0
Local nCount	:= 0
Local nTamArr	:= 0	
Local nValBxAnt	:= 0 
Local nLinAtu  	:= 0
Local nTotLiq	:= 0
Local nTotNeg	:= 0
Local nTotAbImp	:= 0
Local nTotAbat	:= 0
Local nAbat		:= 0
Local lRet		:= .T.
Local nValAcres	:= 0
Local nValMul	:= 0
Local nValJuros	:= 0
Local nValDesc	:= 0
Local nValFKD	:= 0
Local nValDecre	:= 0
Local nI		:= 0
Local cChaveTit := ""
Local cChaveFK7 := ""
Local lRecXML	  := .F.
Local lMvrmclass	:= GetNewPar("MV_RMCLASS", .F.)
Local dDataAnt	:= dDataBase 

Default dDateProc := dDatabase
Default cOrigin	  := "FINI460"
Default aNewTit	  := {}

Private lOpcAuto  := .T.

dDatabase := dDateProc

//Inclusão
If nOpc == 3

	//Carrego as perguntas do processo de liquidação
	pergunte("AFI460",.F.)
	
	If nNum == NIL
		F460IniStat()
	Endif

	_nOper := OPER_LIQUIDAR

	cPrefix		:= PadR(SuperGetMV('MV_INTPRF',.F.," "  ), nPrf )
	cNumTit		:= PadR(SuperGetMV('MV_INTNUM',.F.,"0"  ), nNum )
	If( Empty(aParcelas[1,23]))
		cTipo := PadR(SuperGetMV('MV_INTTIP',.F.,'DP '), nTpo )
	Else
		cTipo := aParcelas[1,23]
	EndIf
	cLastParc := PadR(SuperGetMV('MV_1DUP'  ,.F.," "  ), nPcl )
	
	If lRet
		cNLiquid := F460NumLiq()
		cNumTit	:= F460CodTit(cPrefix,cTipo)
		__nOpcOuMo  := 2
		lAuto := .T.
		DbSelectArea('FO0') //CabeçalhO Liquidação 
		DbSelectArea('FO1') //Titulos Geradores.
		DbSelectArea('FO2') //Parcelas da Liquidação.	
		
		oModel := FWLoadModel("FINA460A")			//Carrega estrutura do model
		oModel:SetOperation( MODEL_OPERATION_INSERT ) //Define operação de inclusao
		oModel:Activate()							//Ativa o model	
		oFO0 := oModel:GetModel('MASTERFO0')
		oFO1 := oModel:GetModel('TITSELFO1')
		oFO2 := oModel:GetModel('TITGERFO2')
		
		cNaturez   := aParcelas[1][25]
		//O primeiro cliente das parcelas a serem geradas será o cliente do processo
		cCliente	:= aParcelas[1][3]
		cLoja		:= aParcelas[1][4]
		cNomeCli	:= Posicione("SA1",1,xFilial("SA1") + cCliente + cLoja, "A1_NOME")
		
		//-------------------------------------------------------------------------------------------------------
		//Carga da FO0 - Cabeçalho da Liquidação
		//-------------------------------------------------------------------------------------------------------
		cProcess := FINIDPROC("FO0","FO0_PROCES",cVersao)
		
		//Utilizado para montagem do Response da Integração
		aNewTit := F460RGetExt(,,cProcess,cVersao)
			
		oFO0:LoadValue("FO0_PROCES"	, cProcess	)
		oFO0:LoadValue("FO0_VERSAO"	, cVersao	)
		oFO0:LoadValue("FO0_RAZAO"	, cNomeCli	)
		oFO0:LoadValue("FO0_CLIENT"	, cCliente	)
		oFO0:LoadValue("FO0_LOJA"	, cLoja		)
		oFO0:LoadValue("FO0_TIPO"	, cTipo		)
		oFO0:LoadValue("FO0_NATURE"	, cNaturez	)
		oFO0:LoadValue("FO0_MOEDA"	, nMoeda	)
		oFO0:LoadValue("FO0_DATA"	, dDateProc	)
		oFO0:LoadValue("FO0_DTVALI"	, dDateProc	) 
		oFO0:LoadValue("FO0_TXJUR"	, nTxJuros	)
		oFO0:LoadValue("FO0_TXMUL"	, nTxMulta	)
		oFO0:LoadValue("FO0_TXJRG"	, nTxJurGer	)
		oFO0:LoadValue("FO0_NUMLIQ"	, cNLiquid	)
		oFO0:LoadValue("FO0_ORIGEM"	, cOrigin	)
		
		//-------------------------------------------------------------------------------------------------------
		//Carga da FO1 - Titulos a Baixar
		//-------------------------------------------------------------------------------------------------------
		//Estrutura aBaixar
		//[01] Recno SE1
		//[02] Valor Baixa
		//[03] Valor Juros
		//[04] Valor Desconto
		//[05] Valor Abatimento
		//[06] Valor Acrescimo
		//[07] Valor Multa
		//[08] Data de Processamento
		//[09] Valor de Acrescimo
		//[10] Valor de Decrescimo
		
		nTamArr := Len(aBaixar)
		For nCount := 1 To nTamArr
		
			nRecno		:= aBaixar[nCount,1]
			nValor		:= aBaixar[nCount,2]			
			nJuros		:= aBaixar[nCount,3]
			nDesco		:= aBaixar[nCount,4]
			nAbat		:= aBaixar[nCount,5] 
			nValAcres	:= aBaixar[nCount,6] + aBaixar[nCount,9]
			nValMul	:= aBaixar[nCount,7]
			nValDecre	:= aBaixar[nCount,10]
			
			SE1->(dbGoTo(nRecno))
			
			nValBxAnt := SE1->E1_VALOR - SE1->E1_SALDO
			nTotAbImp := 0
			nTotAbat  := SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"S",dDateProc,@nTotAbImp)
			nAbat	  := nTotAbat - nTotAbImp  
			
			cChaveTit := SE1->E1_FILORIG +"|"+ SE1->E1_PREFIXO +"|"+ SE1->E1_NUM +"|"+ SE1->E1_PARCELA +"|"+ SE1->E1_TIPO +"|"+ SE1->E1_CLIENTE +"|"+ SE1->E1_LOJA
			cChaveFK7 := FINGRVFK7("SE1", cChaveTit, SE1->E1_FILORIG)
					
			If !oFO1:IsEmpty()
				oFO1:AddLine()
			EndIf
			
			FINGRVFKD(cChaveFK7,aValDocVA[nCount],.T.)
			nValFKD := 0
			For nI := 1 to Len(aValDocVA[nCount])
			
				If(Val(aValDocVA[nCount][nI][2]) != 0)
				
					nValFKD += Val(aValDocVA[nCount][nI][2])
				
				EndIf
			Next nI
			
			oFO1:LoadValue("FO1_MARK"	, .T.				)
			oFO1:LoadValue("FO1_PROCES"	, oFO0:GetValue("FO0_PROCES")	)
			oFO1:LoadValue("FO1_VERSAO"	, oFO0:GetValue("FO0_VERSAO")	)
			oFO1:LoadValue("FO1_FILORI"	, SE1->E1_FILORIG	)
			oFO1:LoadValue("FO1_PREFIX"	, SE1->E1_PREFIXO	)
			oFO1:LoadValue("FO1_NUM"	, SE1->E1_NUM		)
			oFO1:LoadValue("FO1_PARCEL"	, SE1->E1_PARCELA	)
			oFO1:LoadValue("FO1_TIPO"	, SE1->E1_TIPO		)
			oFO1:LoadValue("FO1_CLIENT"	, SE1->E1_CLIENTE	)
			oFO1:LoadValue("FO1_LOJA"	, SE1->E1_LOJA		)
			oFO1:LoadValue("FO1_NATURE"	, SE1->E1_NATUREZ	)
			oFO1:LoadValue("FO1_IDDOC"	, cChaveFK7			)
			oFO1:LoadValue("FO1_MOEDA"	, SE1->E1_MOEDA		)
			oFO1:LoadValue("FO1_TXMOED"	, SE1->E1_TXMOEDA	)
			oFO1:LoadValue("FO1_EMIS"	, SE1->E1_EMISSAO	)
			oFO1:LoadValue("FO1_VENCTO"	, SE1->E1_VENCTO	)
			oFO1:LoadValue("FO1_VENCRE"	, SE1->E1_VENCREA	)
			oFO1:LoadValue("FO1_SALDO"	, SE1->E1_SALDO		)
			oFO1:LoadValue("FO1_BAIXA"	, SE1->E1_BAIXA		)
			oFO1:LoadValue("FO1_VLBAIX"	, nValBxAnt			)
			oFO1:LoadValue("FO1_HIST"	, SE1->E1_HIST		)
			oFO1:LoadValue("FO1_TXJUR"	, 0					)
			oFO1:LoadValue("FO1_VLDIA"	, 0					)
			oFO1:LoadValue("FO1_VLJUR"	, nJuros			)
			oFO1:LoadValue("FO1_TXMUL"	, 0					)
			oFO1:LoadValue("FO1_VLMUL"	, nValMul			)
			oFO1:LoadValue("FO1_DESCON"	, nDesco			)
			oFO1:LoadValue("FO1_VLABT"	, nAbat				)
			oFO1:LoadValue("FO1_ACRESC"	, nValAcres			)
			oFO1:LoadValue("FO1_DECRES"	, nValDecre			)
			oFO1:LoadValue("FO1_VALCVT"	, 0					)
			oFO1:LoadValue("FO1_TOTAL"	, nValor			)
			oFO1:LoadValue("FO1_VACESS"	, nValFKD			)
			//////////////////////////////////////////////////////////////////////////////////////////////////////////
			//Aqui Grava se SE1 para o caso do Acrescimo e decrecimo , quando for cancelado efetuar a baixa completa//
			//////////////////////////////////////////////////////////////////////////////////////////////////////////
			RecLock("SE1",.F.)
			
				SE1->E1_ACRESC := nValAcres
				SE1->E1_DECRESC := nValDecre
						
			SE1->(MsUnlock())
			
			//Totalizador de valor a liquidar
			nTotLiq += nValor
		Next nCount
		
		//-------------------------------------------------------------------------------------------------------
		//Carga da FO2 - Titulos a Gerar
		//-------------------------------------------------------------------------------------------------------
		//Estrutura aParcelas
		//[01] Valor da Parcela
		//[02] Data de Vencimento
		//[03] Cliente
		//[04] Loja 
		//[05] InternalID do Titulo (RM)
		//[06] Nosso Numero (RM)
		//[07] Código de Barras (RM)
		//[08] Centro de Custo Credito(RM)
		//[09] Centro de Custo Debito(RM)
		//[10] Conta Contabil Credito(RM)
		//[11] Conta Contabil Debito(RM)
		//[12] Item Contabil Credito(RM)
		//[13] Item Contabil Debito(RM)
		//[14] Classe Contabil Credito(RM)
		//[15] Classe Contabil Debito(RM)
		//[16] Registro Academico do Aluno (RM)
		//[17] Periodo Academico do Aluno  (RM)
		//[18] Matriz Aplicada do Aluno    (RM)
		//[19] Item (RM)
		//[20] Classe do Aluno(RM)
		//[21] Parcela do Titulo
		//[22] Prefixo do Titulo
		//[23] Tipo do Titulo
		//[24] Numero do Titulo
		//[25] Natureza do Titulo
		//[26] Contrato
		//[27] Portador
		//[28] Depositaria 
		//[29] Num da Conta

		nTamArr := Len(aParcelas)
		For nCount := 1 To nTamArr		
			
			cTitExtID := AllTrim(aParcelas[nCount,5])
			
			If !oFO2:IsEmpty()
				oFO2:AddLine()
			EndIf
			
			///////////////////////////////////////////////////////////////////
			//Aqui eu faço a utilização dos valores informado no XML pela RM //
			// Validação para saber se o cara enviou a chave completa caso   //
			// ele envia uma chave faltando deixa para execAuto recusar
			///////////////////////////////////////////////////////////////////
			If(!Empty(aParcelas[nCount,22]) .Or.  !Empty(aParcelas[nCount,25]) .Or. !Empty(aParcelas[nCount,24]))
				
				cPrefix  := ""
				cNaturez := ""
				cNumTit  := ""
				
				cPrefix	 := Padr(aParcelas[nCount,22], nPrf)
				cNaturez := aParcelas[nCount,25]
				cNumTit	 := Padr(aParcelas[nCount,24], nNum)
				
				If(SE1->(MsSeek(xFilial("SE1")+cPrefix+cNumTit+cLastParc+cTipo)))
				
					lRet := .F.
					cErrorMessage := " Titulo Informado na nova parcela ja existe"
					Exit
				
				EndIf
				
				lRecXML := .T.
				
			EndIf
			
			oFO2:LoadValue("FO2_IDSIM" ,FWUUIDV4() ) //Chave ID tabela FK1.
			oFO2:LoadValue("FO2_PROCES",oFO0:GetValue("FO0_PROCES")) //Processo
			oFO2:LoadValue("FO2_VERSAO",oFO0:GetValue("FO0_VERSAO")) //Versão

			oFO2:LoadValue("FO2_PREFIX", cPrefix)
			
			//Gero numero da Parcela
			nLinAtu := oFO2:GetLine()
			F460GerParc(oFO2, nLinAtu, cPrefix, @cNumTit, cTipo, @cLastParc,.F.)
			oFO2:GoLine(nLinAtu)
	
			oFO2:LoadValue("FO2_NUM"   , cNumTit)

			If Empty(aParcelas[nCount,21])
				cAtlzParc = cLastParc
			Else
				cAtlzParc = aParcelas[nCount,21]
			Endif

			oFO2:LoadValue("FO2_PARCEL", cAtlzParc)
			
			oFO2:LoadValue("FO2_VENCTO", aParcelas[nCount,2])		// data vencto
			oFO2:LoadValue("FO2_VALOR" , aParcelas[nCount,1])		// valor da parcela
			
			oFO2:LoadValue("FO2_TXJUR" , 0 )
			oFO2:LoadValue("FO2_VLJUR" , 0 )

			//Campos especificos da integração RM -Protheus
			If lMvrmclass
				oFO2:LoadValue("FO2_NOSNUM"   , Padr(aParcelas[nCount,6],nNosNum)	)	//Nosso Numero (RM)
				oFO2:LoadValue("FO2_CODBAR"   , Padr(aParcelas[nCount,7],nCodBar)	)	//Código de Barras (RM)
				oFO2:LoadValue("FO2_CCDEBITO" , Padr(aParcelas[nCount,8],nTamCCDeb)	)	//Centro de Custo Debito(RM)
				oFO2:LoadValue("FO2_CCCREDITO", Padr(aParcelas[nCount,9],nTamCCCred))	//Centro de Custo Credito(RM)
				oFO2:LoadValue("FO2_CTDEBITO" , Padr(aParcelas[nCount,10],nTamCTDeb))	//Conta Contabil Debito(RM)
				oFO2:LoadValue("FO2_CTCREDITO", Padr(aParcelas[nCount,11],nTamCTCred))	//Conta Contabil Credito(RM)
				oFO2:LoadValue("FO2_ITDEBITO" , Padr(aParcelas[nCount,12],nTamITDeb))	//Item Contabil Debito(RM)
				oFO2:LoadValue("FO2_ITCREDITO", Padr(aParcelas[nCount,13],nTamITCred))	//Item Contabil Credito(RM)
				oFO2:LoadValue("FO2_CLDEBITO" , Padr(aParcelas[nCount,14],nTamClDeb))	//Classe Contabil Debito(RM)
				oFO2:LoadValue("FO2_CLCREDITO", Padr(aParcelas[nCount,15],nTamClCred))	//Classe Contabil Credito(RM)
				oFO2:LoadValue("FO2_REGACAD"  , Padr(aParcelas[nCount,16],nTamRegAca))	//Registro Academico
				oFO2:LoadValue("FO2_PERACAD"  , Padr(aParcelas[nCount,17],nTamPerAca))	//Periodo Academico
				oFO2:LoadValue("FO2_MATAPLI"  , Val(aParcelas[nCount,18]))				//Matriz Aplicada
				oFO2:LoadValue("FO2_CLASSE"   , Padr(aParcelas[nCount,19],nTamClasse))	//Classe do Aluno
				oFO2:LoadValue("FO2_IDTPROD"  , Padr(aParcelas[nCount,20],nTamItem  ))	//ID do Produto
			EndIf
			//Dados bancarios
			oFO2:LoadValue("FO2_CONTRACT"	, Padr(aParcelas[nCount,26],nTamContr))	//Contrato
			oFO2:LoadValue("FO2_HOLDER"		, Padr(aParcelas[nCount,27],nTamPort))	//Portador
			oFO2:LoadValue("FO2_AGENCY"		, Padr(aParcelas[nCount,28],nTamAgenc))	//Depositaria
			oFO2:LoadValue("FO2_ACCOUNT"	, Padr(aParcelas[nCount,29],nTamConta))	//Num da Conta
			oFO2:LoadValue("FO2_EMISSAO"	, aParcelas[nCount,30])	                //Data da Emissão

			nValParc := aParcelas[nCount,1] + oFO2:GetValue("FO2_VLJUR")
			
			oFO2:LoadValue("FO2_VLPARC", nValParc)
			oFO2:LoadValue("FO2_TOTAL" , nValParc) //valor total negociado
			oFO2:LoadValue("FO2_TIPO" , aParcelas[nCount,23]) //tipo do título
			
			nTotNeg += nValParc
			
			//Utilizado para montagem do Response da Integração
			AADD(aNewTit,{cPrefix, cNumTit, cAtlzParc, cTipo, cTitExtID})
			
			///////////////////////////////////////////////
			// Grava os Valores acessorios na tabela FKD //
			///////////////////////////////////////////////
			cChaveTit := FWxFilial( "SE1" ) + "|" + cPrefix + "|" + cNumTit + "|" + cLastParc + "|" + cTipo + "|" + cCliente + "|" + cLoja
			cChaveFK7 := FINGRVFK7( "SE1", cChaveTit )
			FINGRVFKD( cChaveFK7, aNDocVAs[nCount] )
			
		Next nCount
		
		oFO0:LoadValue("FO0_VLRLIQ"	, nTotLiq )
		oFO0:LoadValue("FO0_VLRNEG"	, nTotNeg )

		If oModel:VldData()
			If oModel:CommitData()
				cErrorMessage := ""	
				//----------------------------------------------------------------------------------------------------------
				// Atualiza Parametro de Ultimo Numero de título utilizado para Liquidacao via integração
				// Caso o as informações venha do XML da RM eu nao efetuo a atualização do parametro
				//----------------------------------------------------------------------------------------------------------
				If(!lRecXML )
					If GetMv("MV_INTNUM",,.T.) < cNumTit
						PutMv("MV_INTNUM", cNumTit)
					Endif
				EndIf
			Else
				lRet := .F.
				cErrorMessage := 'FINI460MOD - ' 
				cErrorMessage += cValToChar(oModel:GetErrorMessage()[4]) + ' - ' 
				cErrorMessage += cValToChar(oModel:GetErrorMessage()[6]) + ' - ' 
				cErrorMessage += cValToChar(oModel:GetErrorMessage()[8])	
			Endif
		Else
			lRet := .F.
			cErrorMessage := 'FINI460MOD - ' 
			cErrorMessage += cValToChar(oModel:GetErrorMessage()[4]) + ' - ' 
			cErrorMessage += cValToChar(oModel:GetErrorMessage()[6]) + ' - ' 
			cErrorMessage += cValToChar(oModel:GetErrorMessage()[8])	
		EndIf	
		oModel:DeActivate()
		oModel:Destroy()
		oModel:= Nil
	Endif	
Endif

dDataBase := dDataAnt

Return lRet	

//-------------------------------------------------------------------
/*/{Protheus.doc} F460CodTit
Controla numeração dos títulos da Liquidação (Integração)

@author Mauricio Pequim Jr
@since 19/07/2016
@version P12.1.13

/*/
//-------------------------------------------------------------------
Function F460CodTit(cPrefix)

Local cNumTit		:= ""
Local aAreaSE1	:= SE1->(GetArea())

//Trata numero da liquidacao
SE1->(dbSetOrder(1))
cNumTit := GetMv("MV_INTNUM",,.T.)
cNumTit := Soma1(cNumTit,nNum)

// Verifica na memoria se esta sendo usado por outro usuario e
// verifica se ja existe liquidacao com o mesmo numero
While (!Empty(cNumTit) .and. ( SE1->(MsSeek(xFilial("SE1")+cPrefix+cNumTit)) .or. !MayIUseCode("E1_NUM"+xFilial("SE1")+cPrefix+cNumTit) ))
	cNumTit := Soma1(cNumTit,nNum)	// busca o proximo numero disponivel 
Enddo

//--------------------------------------------------------------------------------
// Avalia se o codigo esta sendo usado 
//--------------------------------------------------------------------------------
While .T.
	If MayIUseCode("E1_NUM"+xFilial("SE1")+cPrefix+cNumTit)
		Exit
	Else
		cNumTit := Soma1(cNumTit,nNum)
	EndIf
Enddo

SE1->(RestArea(aAreaSE1))
	
Return cNumTit	

//-------------------------------------------------------------------
/*/{Protheus.doc} F460IniStat
Inicializa as variáveis static (Integração)

@author Mauricio Pequim Jr
@since 19/07/2016
@version P12.1.13

/*/
//-------------------------------------------------------------------
Function F460IniStat()
	
nFil					:= TamSX3("E1_FILIAL")[1]
nPrf					:= TamSX3("E1_PREFIXO")[1]
nNum					:= TamSX3("E1_NUM")[1]
nPcl					:= TamSX3("E1_PARCELA")[1]
nTpo					:= TamSX3("E1_TIPO")[1]
nNat					:= TamSX3("E1_NATUREZ")[1]
nNosNum					:= TamSX3("E1_NUMBCO")[1]
nCodBar					:= TamSX3("E1_CODBAR")[1]
nTamCCDeb				:= TamSX3("E1_CCD")[1]
nTamCCCred				:= TamSX3("E1_CCC")[1]
nTamCTDeb				:= TamSX3("E1_DEBITO")[1]
nTamCTCred				:= TamSX3("E1_CREDIT")[1]
nTamITDeb				:= TamSX3("E1_ITEMD")[1]
nTamITCred				:= TamSX3("E1_ITEMC")[1]
nTamClDeb				:= TamSX3("E1_CLVLDB")[1]
nTamClCred				:= TamSX3("E1_CLVLCR")[1]
nTamRegAca				:= TamSX3("E1_NUMRA")[1]
nTamPerAca				:= TamSX3("E1_PERLET")[1]
nTamMatApl				:= TamSX3("E1_IDAPLIC")[1]
nTamClasse				:= TamSX3("E1_TURMA")[1]
nTamItem				:= TamSX3("E1_PRODUTO")[1]
nTamContr				:= TamSX3("E1_CONTRAT")[1]
nTamPort				:= TamSX3("E1_PORTADO")[1]
nTamAgenc				:= TamSX3("E1_AGEDEP")[1]
nTamConta				:= TamSX3("E1_CONTA")[1]
nTamData				:= TamSX3("E1_EMISSAO")[1]

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FI460Can
Cancelamento do processo de Liquidação

@author Mauricio Pequim Jr
@since 19/07/2016
@version P12.1.13

/*/
//-------------------------------------------------------------------
Function FI460Can(cNumLiq,cErrorMessage)

Local lRet 		:= .T.  
Local nX			:= 0
Local aErro		:= {}
Local cMsg		:= ""

//Controle de rotina automatica
Private lMsErroAuto		:= .F. //Determina se houve algum tipo de erro durante a execucao do ExecAuto
Private lMsHelpAuto		:= .T. //Define se mostra ou não os erros na tela (T= Nao mostra; F=Mostra)

DEFAULT cNumLiq		:= ""
DEFAULT cErrorMessage	:= ""

//FINA460(,/*xAutoCab*/,/*xAutoItens*/,4 /*xOpcAuto*/,/*xAutoFil*/,cLiqCan /*xNumLiq*/)
MSExecAuto({|a,b,c,d,e,f| FINA460(a,b,c,d,e,f)},/*nPosArotina*/,/*xAutoCab*/,/*xAutoItens*/,5 /*xOpcAuto*/,/*xAutoFil*/,cNumLiq /*xNumLiq*/)

If lMsErroAuto
	aErro := GetAutoGrLog()
	cErrorMessage := ""

	For nX := 1 To Len(aErro)
		cErrorMessage += aErro[nX] + CRLF
	Next nX

	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} CalcVA
Função Responsavel por efetuar a verificação do cadastro do Valor acessorio
caso o valor acessorio seja de desconto ira ser multiplicado por -1
@type function
@author jose.aribeiro
@since 14/09/2016
@version 1.0
@param cCodVA, character, Codigo do Valor Acessorio a ser verificado
/*/
Static Function CalcVA(cCodVA,nValor)

	DbSelectArea("FKC")
	FKC->(DbSetOrder(1))
	If(FKC->(DbSeek(xFilial("FKC")+cCodVA)))
		If(FKC->FKC_ACAO == '2')
					
			nValor := nValor * -1
					
		
		EndIf
	EndIf
Return cValToChar(nValor)

/*/{Protheus.doc} F460GetCnt
Função Responsavel para efetuar o DE/PARA do CT1
@type function
@author jose.aribeiro
@since 26/08/2016
@version 1.0
@param cCodigo, Caracter, Codigo do DE/PARA
@param cMarca , Caracter, Marca para efetuar
@return aRet  , Vetor    , Vetor Contendo as informações do DE/PARA
/*/
Function F460GetCnt( cCodigo, cMarca )
Local cValInt := ""
Local aRet := {}
Local aAux := {}
Local nX := 0
Local aCampos := {cEmpAnt, "CT1_FILIAL", "CT1_CONTA"}

	cValInt := CFGA070Int( cMarca, "CT1", "CT1_CONTA", cCodigo )
	If Empty( cValInt )
		aAdd( aRet, .F. )
	Else
		aAux := Separa( cValInt, "|" )

		aAdd( aRet, .T. )
		aAdd( aRet, aAux )
		aAdd( aRet, cValInt )

		aRet[2][1] := Padr( aRet[2][1], Len(cEmpAnt) )

		//Garante que o tamanho dos campos esteja correto
		For nX := 2 To Len( aRet[2] )
			aRet[2][nX] := Padr( aRet[2][nX], TamSX3(aCampos[nx])[1] )
		Next nX
	EndIf

Return aRet
