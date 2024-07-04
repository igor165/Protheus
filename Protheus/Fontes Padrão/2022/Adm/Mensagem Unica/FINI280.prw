#Include "PROTHEUS.ch"
#Include "FWMVCDEF.CH"
#Include "FWADAPTEREAI.CH"
#Include "FINI280.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FINI280
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
Function FINI280( cXml, nType , cTypeMsg )
Local cXmlRet		:= ''
Local cEntity		:= ''
Local cMuCliVers	:= ''
Local cEvent		:= 'upsert'
Local oXml			:= ''
Local cErroXml		:= ''
Local cWarnXml		:= ''
Local cVersao		:= ''
Local cBase			:= "E1_BASE"
Local cField		:= "E1_NUM"
Local cExternalId	:= ""
Local cInternalId	:= ""
Local cImpBase		:= "0.0"
Local cMarca		:= ""
Local cAliasSE1		:= "SE1"
Local cValInt		:= ""
Local cValExt		:= ""
Local cCliente		:= ""
Local cPrefixo		:= ""
Local cParcela		:= ""
Local cNumDoc		:= ""
Local cTipoDoc		:= ""
Local cNaturez		:= ""
Local cSE1			:= ""			
Local cSE1b			:= ""
Local cE1			:= ""
Local cImposto		:= ""
Local cOrigem		:= ""
Local cFatura		:= F280GetTit()[3]
Local nValJuros		:= 0
Local nDescont		:= 0
Local nX			:= 0
Local nI			:= 0
Local nCount		:= 0
Local nTaxa			:= 0
Local lRet			:= .T.
Local aDischarge	:= F280GetTit()[1]
Local aReceivable	:= F280GetTit()[2]
Local aRetorno		:= {}
Local aImposto		:= {"ISS", "IRRF", "INSS", "COFINS", "PIS", "CSLL"}
Local nPrf			:= TamSX3("E1_PREFIXO")[1]
Local nNum			:= TamSX3("E1_NUM")[1]
Local nPcl			:= TamSX3("E1_PARCELA")[1]
Local nTpo			:= TamSX3("E1_TIPO")[1]
Local cMsgVer		:= ''

If FWIsInCallStack('FA280AUT')
	cEntity := 'FinancingTrading'
Else
	cEntity := 'ReversalOfFinancingTrading'
EndIf

//Verifico o tipo de mensagem
If nType == TRANS_SEND //Envio

	cXMLRet :=	'<BusinessRequest>'
	cXMLRet +=		'<Operation>' + cEntity + '</Operation>'
	cXMLRet +=		'<Identification>'
	cXMLRet +=			'<key name="InternalId">' + cEmpAnt + '|' + cFilAnt + '|' + 'F' + AllTrim(cFatura) + '</key>'
	cXMLRet +=		'</Identification>'
	cXMLRet +=	'</BusinessRequest>'
	cXMLRet +=	'<BusinessContent>'

	If Upper(cEntity) == 'FINANCINGTRADING'

		cXMLRet +=		'<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet +=		'<CompanyInternalId>' + cEmpAnt + '|' + RTrim(xFilial("SE1")) + '</CompanyInternalId>'
		cXMLRet +=		'<BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet +=		'<TradingDate>' + Transform(DtoS(dDataBase),"@R 9999-99-99") + '</TradingDate>'
		cXMLRet +=		'<TradingId>' + 'F' + AllTrim(cFatura) + '</TradingId>'
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
				If (SE5->E5_SITUACA == 'C' .And. SE5->E5_MOTBX != 'FAT' .And. SE5->E5_TIPODOC != 'BA').OR. (SE5->E5_TIPODOC $ 'C2|CM|CX|DC|J2|JR|M2|MT|VM')
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
			/*Adicionado a soma de desconto no valor de pagamento, pois na intgração do RMCLASSIS precisa passar o valor do título 
			sem considerar os descontos efetuado no Backoffice, pois só é controlada a baixa e geração de novos títulos
			devido ao NOSSONUMERO ser controlado pela RM.*/	
			cXMLRet +=		'<PaymentValue>' + CValToChar(SE5->E5_VALOR+nDesconto) + '</PaymentValue>'
			cXMLRet +=		'<CustomerCode>' + IntCliExt(,,SE1->E1_CLIENTE,SE1->E1_LOJA,)[2] + '</CustomerCode>'			
			cXMLRet +=		'<CustomerCode>' + RTrim(SE1->E1_CLIENTE) + '</CustomerCode>'
			cXMLRet +=		'<StoreId>' + RTrim(SE1->E1_LOJA) + '</StoreId>'
			cXMLRet	+=		'<FinancialCode>' + RTrim(SE1->E1_NATUREZ) + '</FinancialCode>'							
			cXmlRet +=	'</Discharge>
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
			If GetMV("MV_RMCLASS") 
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
			cXmlRet+=		'<CurrencyInternalId/>'
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

			cMsgVer := MsgUVer('FINANCINGTRADING','FINA280')

			If AllTrim(cMsgVer) == '1.002'
				cXmlRet +=		'<FinancialIncrease>' + AllTrim(CValToChar(E1_ACRESC)) + '</FinancialIncrease>'
				cXmlRet +=		'<FinancialDecrease>' + AllTrim(CValToChar(E1_DECRESC)) + '</FinancialDecrease>'
			EndIf
			
			cXmlRet +=	'</ReceivableDocument>'				
		Next nX
		cXmlRet +=	'</ListOfNewDocuments>'
		//TAGs da inclusão de títulos para compor a lista de novos títulos gerados
	Else
		cXMLRet +=	'<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet +=	'<CompanyInternalId>' + cEmpAnt + '|' + RTrim(xFilial("SE1")) + '</CompanyInternalId>'
		cXMLRet +=	'<BranchId>' + cFilAnt + '</BranchId>'
		cXmlRet +=	'<ReversalDate>' + Transform(DtoS(dDataBase),"@R 9999-99-99") + '</ReversalDate>'
		cXmlRet +=	'<TradingId>' + 'F' + AllTrim(cFatura) + '</TradingId>'  
	EndIf
	
	cXMLRet +=	'</BusinessContent>'

ElseIf nType == TRANS_RECEIVE
	Do Case 
		Case cTypeMsg == EAI_MESSAGE_WHOIS
			cXmlRet := '1.000|1.001|1.002'
		Case cTypeMsg == EAI_MESSAGE_RESPONSE
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
													
							
					If XmlChildEx( oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent, '_LISTOFOURNUMBER') != Nil .AND. ;
							XmlChildEx( oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfOurNumber, '_RETURNITEM') != Nil
								
						If ValType(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfOurNumber:_RETURNITEM) != "A"
							// Transforma em array
							XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfOurNumber:_RETURNITEM, "_RETURNITEM")
						EndIf
								
						For nCount := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfOurNumber:_ReturnItem)
							cExternalId:= oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfOurNumber:_ReturnItem[nCount]:_DestinationInternalId:Text
							cInternalId:= oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfOurNumber:_ReturnItem[nCount]:_OriginInternalId:Text
							CFGA070Mnt(cMarca, cAliasSE1, cField, cExternalId, cInternalId, .F., 1) 
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
		
		Case cTypeMsg == EAI_MESSAGE_BUSINESS
		
	EndCase
	
EndIf

Return { lRet, cXmlRet } 

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

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} MsgUVer(cMensagem,cRotina)
Função que verifica a versão de uma mensagem única cadastrada no adapter EAI
		
@param	cMensagem Nome da Mensagem única a ser pesquisada
@param cRotina	 Rotina que possui a IntegDef da Mensagem Unica
@return cVersion Versão da mensagem única cadastrada no Configurador.
	
@author Pedro Pereira Lima
@version P11
@since 25/04/2016											
/*/
//----------------------------------------------------------------------------------------------
Static Function MsgUVer(cMensagem,cRotina)
Local aArea		:= GetArea()
Local cVersion	:= '1.001'
Local oXX4		:= NIL

DEFAULT cRotina := ''
DEFAULT cMensagem := ''

If !EMPTY(oXX4:= If(FINDFUNCTION('FINCLSXX4'),oFINCLSXX4():New(cRotina,cMensagem),NIL))
	cVersion := oXX4:cVersao
	oXX4:CleanUp()
	FreeObj(oXX4)
	oXX4 := NIL
Endif

RestArea(aArea)

Return cVersion