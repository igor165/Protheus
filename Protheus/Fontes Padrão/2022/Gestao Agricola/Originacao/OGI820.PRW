#Include 'PROTHEUS.CH'
#Include 'OGI820.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC
#Include 'TBICONN.CH'

Function OGI820SCH(aParam)

	Local aRet := {}
	conout(" ********** INICIANDO CHAMADA OGI820 VIA SCHEDULE  *********  ")
	
	RpcSetType(3)
	RpcSetEnv(aParam[1],aParam[2],,,"AGR",GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas

	aRet := FWIntegDef( "OGI820", EAI_MESSAGE_BUSINESS, TRANS_SEND, "", "OGI820")

	RpcClearEnv()   //Libera o Ambiente
	
	conout(" ********** FINALIZADO CHAMADA OGI820 VIA SCHEDULE  *********  ")

Return .T.

/*/{Protheus.doc} IntegDef
//Adapter Entidade
@author carlos.augusto
@since 16/06/2018
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
	Local aRet := {}

	If ExistFunc("OGI820")
		aRet:= OGI820( cXml, nTypeTrans, cTypeMessage )
	EndIf

Return aRet   


Function OGI820( cXML, nTypeTrans, cTypeMessage)
	Local aArea		:= GetArea()			//Salva contexto do alias atual  
	Local aLines	:= FWSaveRows()		//Salva contexto do model ativo

	Local aRet 		  := {}				//Array de retorno da função
	Local lRet 		  := .T.			//Indica o resultado da execução da função
	Local cXMLRet	  := ''				//Xml que será enviado pela função
	Local cError	  := ''				//Mensagem de erro do parse no xml recebido como parâmetro
	Local cWarning	  := ''				//Mensagem de alerta do parse no xml recebido como parâmetro

	//--- Variaveis do Retorno - Função CFGA070Mnt [http://tdn.totvs.com/pages/viewpage.action?pageId=173083053]
	Local oXML			:= Nil				//Objeto com o conteúdo do arquivo Xml
	Local oXMLContent	:= Nil				//Objeto com o conteúdo da BusinessContent apenas
	Local oXMLEvent		:= Nil
	Local cSafra		:= ""
	Local cIntIdSafra	:= ""
	Local cDataDe		:= ""
	Local cDataAte		:= ""
	Local cCodProd		:= ""
	Local cIntIdProd	:= ""
		
	//*************************************
	// Trata o recebimento de mensagem                              
	//*************************************
	If ( nTypeTrans == TRANS_RECEIVE )
		//*********************************
		// Recebimento da Business Message
		//*********************************
		If ( cTypeMessage == EAI_MESSAGE_BUSINESS )

			oXML := tXmlManager():New()
			oXML := XmlParser( cXML, '_', @cError, @cWarning )	

			If ( ( oXML <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) ) )
				//-- Verifica se a marca foi informada
				If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") = "U" .And. !Empty(oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
					cReferen := oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					lRet := .F.
					cXmlRet := STR0002 //'Erro no retorno. A Referencia/Marca é obrigatória!'
					//Carrega array de retorno
					aRet := {lRet, cXmlRet,  "AGRICULTURALSALEPLANNING" } 
					Return aRet
				EndIf
				oXMLEvent 	:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent
				oXMLContent := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent
				
				//Guarda o código da tabela recebido na mensagem.
				//Para utilização com De/Para, altere o código aqui para pegar o codigo da tabela XX5
				
				If ( XmlChildEx( oXMLContent, '_AGRICULTURALYEARCODE' ) != Nil )
					cSafra		:= PADR(oXMLContent:_AgriculturalYearCode:Text,TamSx3("NJU_CODSAF")[1] ," ")
				EndIf
				
				If ( XmlChildEx( oXMLContent, '_AGRICULTURALYEARINTERNALID' ) != Nil )
					cIntIdSafra := oXMLContent:_AgriculturalYearInternalId:Text
				EndIf
				
				If ( XmlChildEx( oXMLContent, '_PERIODSTARTDATE' ) != Nil )
					cDataDe	:= oXMLContent:_PeriodStartDate:Text
				EndIf	
				
				If ( XmlChildEx( oXMLContent, '_PERIODENDDATE' ) != Nil )
					cDataAte := oXMLContent:_PeriodEndDate:Text
				EndIf 
				
				If ( XmlChildEx( oXMLContent, '_ITEMCODE' ) != Nil )
					cCodProd := oXMLContent:_ItemCode:Text
				EndIf
				
				If ( XmlChildEx( oXMLContent, '_ITEMCODEINTERNALID' ) != Nil )
					cIntIdProd := oXMLContent:_ItemCodeInternalId:Text
				EndIf
								
				cXMLRet := GeraXmlEnv(cSafra,cDataDe,cDataAte,cCodProd)
				
			Else
				//Tratamento no erro do parse Xml
				lRet := .F.
				cXMLRet := STR0001 // 'Erro na manipulação do Xml recebido. '
				cXMLRet += IIf ( !Empty(cError), cError, cWarning )
			EndIf

			cXMLRet := EncodeUTF8(cXMLRet)	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Recebimento da Response Message                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Recebimento da WhoIs                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )

			cXMLRet := '1.000'

		EndIf	

	ElseIf ( nTypeTrans == TRANS_SEND )
		//Monta Business Event
		cXMLRet := '<BusinessEvent>'
		cXMLRet +=     '<Entity>AGRICULTURALSALEPLANNING</Entity>'
		cXMLRet += '</BusinessEvent>'

		cXMLRet += '<BusinessContent>'
			/*cXMLRet += '<CompanyId>18</CompanyId>'
			cXMLRet += '<BranchId>D MG 01</BranchId>'
			cXMLRet += '<CompanyInternalId>18|D MG 01</CompanyInternalId>'
			cXMLRet += '<AgriculturalYearCode>1819</AgriculturalYearCode>'
			cXMLRet += '<AgriculturalYearInternalId> |1819</AgriculturalYearInternalId>'
			cXMLRet += '<UnitOfMeasureCode>KG</UnitOfMeasureCode>'
			cXMLRet += '<UnitOfBusinessCode>D MG</UnitOfBusinessCode>'*/
		cXMLRet += '</BusinessContent>'

	EndIf

	FwRestRows(aLines)
	RestArea(aArea)
	
	aRet := {lRet, cXmlRet, "AGRICULTURALSALEPLANNING"}
	

Return aRet

Static Function GeraXmlEnv(cFSafra,cFDataDe,cFDataAte,cFCodProd)
	Local cXMLRet := ""
	Local nX := 0
	Local cQuery := ''
	Local cAliasQry := GetNextAlias()
	Local cCodProd := ''
	Local cUM1Prod := ''

	//busca itens do plano de venda ativo
	cQuery := " SELECT * FROM " + RetSqlName("N8Y") + " N8Y "
	cQuery += " INNER JOIN " + RetSqlName("N8W") + " N8W ON N8W.D_E_L_E_T_ = '' AND N8W.N8W_FILIAL = N8Y.N8Y_FILIAL AND N8W.N8W_CODPLA = N8Y.N8Y_CODPLA  "
	cQuery += " WHERE N8Y.D_E_L_E_T_ = '' AND N8Y_ATIVO = '1' "
	If !Empty(cFSafra)
		cQuery += " AND N8Y_SAFRA = '"+cFSafra+"' "
	EndIf
	If !Empty(cFCodProd)
		cQuery += " AND N8W_CODPRO = '"+cFCodProd+"' "
	EndIf
	If !Empty(cFDataDe)
		cQuery += " AND N8W_DTINIC >= '"+cFDataDe+"' "
	EndIf	
	If !Empty(cFDataAte)
		If Empty(cFDataDe)//se não passar dataDe
			cQuery += " AND N8W_DTINIC >= '"+DTOS(dDataBase) +"' "
		EndIf
		cQuery += " AND N8W_DTFINA <= '"+cFDataAte+"' "
	EndIf	
	
	cQuery	:=	ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	cXMLRet += '<ListOfSalePlan>' //inicio tag da lista com os itens do plano de venda

	(cAliasQry)->(dbGoTop())
	While (cAliasQry)->(!EOF())

		cXMLRet += '<SalePlanItem>' //inicio tag item do plano
		
		cXMLRet += '<CompanyId>'	
		cXMLRet += cEmpAnt
		cXMLRet += '</CompanyId>'

		cXMLRet += '<BranchId>'	
		cXMLRet += cFilAnt
		cXMLRet += '</BranchId>'

		cXMLRet += '<CompanyInternalId>'
		cXMLRet += cEmpAnt + "|" + cFilAnt
		cXMLRet += '</CompanyInternalId>'

		cXMLRet += '<AgriculturalYearCode>'	
		cXMLRet += (cAliasQry)->N8W_SAFRA
		cXMLRet += '</AgriculturalYearCode>'

		cXMLRet += '<AgriculturalYearInternalId>'
		cXMLRet += FWxFilial("NJU") + "|" + (cAliasQry)->N8W_SAFRA	
		cXMLRet += '</AgriculturalYearInternalId>'

		cXMLRet += '<SalePlanCode>'	
		cXMLRet += (cAliasQry)->N8W_CODPLA
		cXMLRet += '</SalePlanCode>'

		cXMLRet += '<SalePlanItem>'
		cXMLRet += (cAliasQry)->N8W_SEQITE	
		cXMLRet += '</SalePlanItem>'

		cXMLRet += '<SalePlanItemInternalId>'
		cXMLRet += (cAliasQry)->N8W_FILIAL + "|" + (cAliasQry)->N8W_SAFRA + "|" + (cAliasQry)->N8W_CODPLA + "|" + (cAliasQry)->N8W_SEQITE	
		cXMLRet += '</SalePlanItemInternalId>'

		cXMLRet += '<UnitOfBusinessCode>'
			cXMLRet += AllTrim(SubStr((cAliasQry)->N8W_FILIAL, Length(FWSM0Layout(cEmpAnt, 1)) + 1, Length(FWSM0Layout(cEmpAnt, 2)))) 
		cXMLRet += '</UnitOfBusinessCode>'

		cXMLRet += '<MarketRate>'
		cXMLRet += Alltrim((cAliasQry)->N8W_TIPMER)
		cXMLRet += '</MarketRate>'

		cXMLRet += '<PeriodSalePlan>'
		cXMLRet += (cAliasQry)->N8W_MESANO	
		cXMLRet += '</PeriodSalePlan>'

		//DADOS PADRÃO PARA CODIGO DO PRODUTO E UNIDADE DE MEDIDA
		cCodProd := (cAliasQry)->N8W_CODPRO
		cUM1Prod := (cAliasQry)->N8W_UM1PRO	
		If Empty((cAliasQry)->N8W_CODPRO) .AND. !Empty((cAliasQry)->N8W_GRPROD)
			//SE NÃO TEM CODIGO DE PRODUTO INFORMADO E TEM O GRUPO DO PRODUTO INFORMADO NO ITEM DO PLANO	
			dbSelectArea("SB1")
			SB1->(dbSetOrder(4)) //B1_FILIAL+B1_GRUPO+B1_COD
			If SB1->(dbSeek( FWxFilial("SB1") + (cAliasQry)->N8W_GRPROD  )) 
				cCodProd := SB1->B1_COD //pega o primeiro codigo de produto do grupo de produto
				If  Empty((cAliasQry)->N8W_UM1PRO)	
					//SE UNIDADE DE MEDIDA ESTA EM BRANCO NO ITEM DO PLANO
					cUM1Prod := SB1->B1_UM
				EndIf
			EndIf
		EndIf
		
		cXMLRet += '<ItemCode>'	
		cXMLRet += cCodProd
		cXMLRet += '</ItemCode>'

		cXMLRet += '<ItemCodeInternalId>'	
		cXMLRet += FWxFilial("SB1") + "|" + cCodProd
		cXMLRet += '</ItemCodeInternalId>'

		cXMLRet += '<UnitOfMeasureCode>'
		cXMLRet += cUM1Prod
		cXMLRet += '</UnitOfMeasureCode>'

		cXMLRet += '<UnitOfMeasureInternalId>'	
		cXMLRet += FWxFilial("SB1") + "|" + cUM1Prod
		cXMLRet += '</UnitOfMeasureInternalId>'

		cXMLRet += '<CurrencyCode>'
		cXMLRet += Alltrim(STR((cAliasQry)->N8W_MOEDA)) //moeda do item do plano de venda
		cXMLRet += '</CurrencyCode>'

		cXMLRet += '<CurrencyInternalId>'	
		cXMLRet += FWxFilial("SM2") + "|" + Alltrim(STR((cAliasQry)->N8W_MOEDA))
		cXMLRet += '</CurrencyInternalId>'

		cXMLRet += '<CurrencyConversion>'
		cXMLRet += Alltrim(STR((cAliasQry)->N8Y_MOEDA))	//moeda de conversao do plano de vendas
		cXMLRet += '</CurrencyConversion>'

		cXMLRet += '<CurrencyRate>'
		cXMLRet += Alltrim(STR((cAliasQry)->N8W_TAXCON))	 //taxa de conversao da moeda de conversao
		cXMLRet += '</CurrencyRate>'

		cXMLRet += '<UpdateDate>'
		cXMLRet += (cAliasQry)->N8W_DTATUA	
		cXMLRet += '</UpdateDate>'

		cXMLRet += '<ListOfBillingTimeline>' //inicio da tag de lista dos itens do cronograma de faturamento

		For nX := 1 to 2 //correção vitor
			If (nX = 1 .and. (cAliasQry)->N8W_SLDVEN > 0) .OR. (nX = 2 .and. (cAliasQry)->N8W_QTDVEN > 0)
				cXMLRet += '<BillingTimelineItem>' //inicio tag do item do cronograma de faturamento
                if nX = 2 
	                cXMLRet += '<OperationStatus>'
					cXMLRet += Alltrim(STR(nX))
					cXMLRet += '</OperationStatus>'
	            else
	                cXMLRet += '<OperationStatus>'
					cXMLRet += Alltrim(STR(nX))
					cXMLRet += '</OperationStatus>'
                endif

				cXMLRet += '<Quantity>'	
				cXMLRet += Alltrim(IIF(nX = 1, STR((cAliasQry)->N8W_SLDVEN),STR((cAliasQry)->N8W_QTDVEN)))
				cXMLRet += '</Quantity>'

				cXMLRet += '<VolumePercentage>'
				If nX = 1
					nPerc := ROUND(((cAliasQry)->N8W_PERVEN * ((cAliasQry)->N8W_SLDVEN / (cAliasQry)->N8W_QTPRVE)), 2) //PERCENTUAL A VENDER correção vitor
				Else
					nPerc := ROUND(((cAliasQry)->N8W_PERVEN * ((cAliasQry)->N8W_QTDVEN / (cAliasQry)->N8W_QTPRVE)), 2) //PERCENTUAL VENDIDO
				EndIf
				cXMLRet += Alltrim(STR(nPerc))
				cXMLRet += '</VolumePercentage>'

				cXMLRet += '<UnitFinancialCurrent>'	
				cXMLRet += Alltrim(IIF(nX = 1, STR((cAliasQry)->N8W_VLUPFI),STR((cAliasQry)->N8W_VLUNFI)))
				cXMLRet += '</UnitFinancialCurrent>'

				cXMLRet += '<UnitFinancialConverted>'	
				cXMLRet += Alltrim(IIF(nX = 1, STR((cAliasQry)->N8W_VUPFI2),STR((cAliasQry)->N8W_VLUFI2)))
				cXMLRet += '</UnitFinancialConverted>'

				cXMLRet += '</BillingTimelineItem>' //fim tag do item do cronograma de faturamento
			EndIf
		Next nX

		cXMLRet += '</ListOfBillingTimeline>' //fim da tag de lista dos itens do cronograma de faturamento

		cXMLRet += '<ListOfReceiptTimeline>' //inicio da tag de lista dos itens do cronograma de recebimento
		
		For nX := 1 to 2
			If (nX = 1 .and. (cAliasQry)->N8W_SLDREC > 0) .OR. (nX = 2 .and. (cAliasQry)->N8W_QTDREC > 0) //Correção Vitor
				cXMLRet += '<ReceiptTimelineItem>'  //inicio tag do item do cronograma de recebimento

				cXMLRet += '<OperationStatus>'
				cXMLRet += Alltrim(STR(nX))
				cXMLRet += '</OperationStatus>'

				cXMLRet += '<Quantity>'	
				cXMLRet += Alltrim(IIF(nX = 1, STR((cAliasQry)->N8W_SLDREC),STR((cAliasQry)->N8W_QTDREC))) //correção vitor
				cXMLRet += '</Quantity>'

				cXMLRet += '<VolumePercentage>'
				If nX = 1
					nPerc := ROUND(((cAliasQry)->N8W_PERREC * ((cAliasQry)->N8W_SLDREC / (cAliasQry)->N8W_QTPRRE)) , 2) //PERCENTUAL A VENDER CORREÇÃO VITOR
				Else
					nPerc := ROUND(((cAliasQry)->N8W_PERREC * ((cAliasQry)->N8W_QTDREC / (cAliasQry)->N8W_QTPRRE)) , 2) //PERCENTUAL VENDIDO CORREÇÃO VITOR
				EndIf
				cXMLRet += Alltrim(STR(nPerc))
				cXMLRet += '</VolumePercentage>'

				cXMLRet += '</ReceiptTimelineItem>' //fim da tag de lista dos itens do cronograma de recebimento
			EndIf
		Next nX

		cXMLRet += '</ListOfReceiptTimeline>' //fim da tag da lista dos itens do cronograma de recebimento

		cXMLRet += '</SalePlanItem>' //fim da tag do item do plano de venda

		(cAliasQry)->(dbSkip())
	
	EndDo //fecha while 
	
	cXMLRet += '</ListOfSalePlan>' //fim da tag da lista com os itens do plano de venda
	
	(cAliasQry)->(dbCloseArea())

Return cXMLRet 
