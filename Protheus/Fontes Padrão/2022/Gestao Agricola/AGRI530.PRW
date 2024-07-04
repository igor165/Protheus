#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC

#Define MAX_FILE_LENGTH 600	//Tamanho maximo permitido para o XML gerado (em KB)

/*/{Protheus.doc} AGRI530
//Requisicao ordem de colheita 
@author carlos.augusto
@since 25/01/2018
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@param Codigo da Empresa
@param Codigo da Filial
@param Data da Pesagem do Romaneio
@param Numero da Ordem e Colheita
@param Codigo do Produto
@type function
/*/
Function AGRI530( cXML, nTypeTrans, cTypeMessage)
Local aArea		:= GetArea()			//Salva contexto do alias atual  
	Local aLines	:= FWSaveRows()		//Salva contexto do model ativo

	Local aRet 		  := {}				//Array de retorno da função
	Local lRet 		  := .T.			//Indica o resultado da execução da função
	Local cXMLRet	  := ''				//Xml que será enviado pela função
	Local cError	  := ''				//Mensagem de erro do parse no xml recebido como parâmetro
	Local cWarning	  := ''				//Mensagem de alerta do parse no xml recebido como parâmetro
	Local nCount      := 0

	//--- Variaveis do Retorno - Função CFGA070Mnt [http://tdn.totvs.com/pages/viewpage.action?pageId=173083053]

	Local oXML 		  := Nil				//Objeto com o conteúdo do arquivo Xml
	Local oXMLContent := Nil				//Objeto com o conteúdo da BusinessContent apenas
	Local cFiltData
	Local cFiltOrd
	Local cFiltItem
	Local oModel
	Local oModelNNJ
	Local oModelDXL

	//*************************************
	// Trata o recebimento de mensagem                              
	//*************************************
	If ( nTypeTrans == TRANS_RECEIVE )

		//*********************************
		// Recebimento da Business Message
		//*********************************
		If ( cTypeMessage == EAI_MESSAGE_BUSINESS )

		//Simulacao do PIMS INICIO
				
			cXmlRet += ' <ListOfHarvestOrders>'
			
			cXmlRet += ' <HarvestOrder>'
			cXmlRet += ' <HarvestOrderCode>123456789' + cValToChar(nCount) + '</HarvestOrderCode>'
			cXmlRet += ' <HarvestOrderDate>2018-01-2' + cValToChar(nCount) + '</HarvestOrderDate>'
			cXmlRet += ' <StartHarvestForecast>2018-02-0' + cValToChar(nCount) + '</StartHarvestForecast>'
			cXmlRet += ' <ClosingHarvestForecast>2018-06-2' + cValToChar(nCount) + '</ClosingHarvestForecast>'
			cXmlRet += ' <HarvestSystemCode>77' + cValToChar(nCount) + '</HarvestSystemCode>'
			cXmlRet += ' <HarvestSystemDescription>Sistema de Colheita ' + cValToChar(nCount) + '</HarvestSystemDescription>'
			cXmlRet += ' <FarmCode>SP</FarmCode>'
			cXmlRet += ' <FarmDescription>Descrição da Fazenda ' + cValToChar(nCount) + '</FarmDescription>'
			cXmlRet += ' <SectorCode>TALHAO0000</SectorCode>'
			cXmlRet += ' <SectorDescription>Descrição do Setor ' + cValToChar(nCount) + '</SectorDescription>'
			cXmlRet += ' <PartOfLandCode>000001</PartOfLandCode>'
			cXmlRet += ' <PartOfLandDescription>Descrição do Talhão ' + cValToChar(nCount) + '</PartOfLandDescription>'
			cXmlRet += ' <ItemCode>A0000001       </ItemCode>'
			cXmlRet += ' <ItemInternalId>99|12345678901234' + cValToChar(nCount) + '</ItemInternalId>'
			cXmlRet += ' <VarietyCode>000001</VarietyCode>'
			cXmlRet += ' <VarietyDescription>Descrição da Variedade ' + cValToChar(nCount) + '</VarietyDescription>'
			cXmlRet += ' <OccupationCode>123456789' + cValToChar(nCount) + '</OccupationCode>'
			cXmlRet += ' <OccupationDescription>Descrição da Ocupação ' + cValToChar(nCount) + '</OccupationDescription>'
			cXmlRet += ' <HarvestedArea>123459' + cValToChar(nCount) + '</HarvestedArea>'
			cXmlRet += ' <HarvestEstimate>123459' + cValToChar(nCount) + '</HarvestEstimate>'
			cXmlRet += ' <MainOrderCode>000033</MainOrderCode>'
			cXmlRet += ' <MainOrderInternalId>AAA|131313131313' + cValToChar(nCount) + '</MainOrderInternalId>'
			cXmlRet += ' </HarvestOrder>'
			
			For nCount := 1 To 9
			
			cXmlRet += ' <HarvestOrder>'
			cXmlRet += ' <HarvestOrderCode>123456789' + cValToChar(nCount) + '</HarvestOrderCode>'
			cXmlRet += ' <HarvestOrderDate>2018-01-2' + cValToChar(nCount) + '</HarvestOrderDate>'
			cXmlRet += ' <StartHarvestForecast>2018-02-0' + cValToChar(nCount) + '</StartHarvestForecast>'
			cXmlRet += ' <ClosingHarvestForecast>2018-06-2' + cValToChar(nCount) + '</ClosingHarvestForecast>'
			cXmlRet += ' <HarvestSystemCode>77' + cValToChar(nCount) + '</HarvestSystemCode>'
			cXmlRet += ' <HarvestSystemDescription>Sistema de Colheita ' + cValToChar(nCount) + '</HarvestSystemDescription>'
			cXmlRet += ' <FarmCode>12345' + cValToChar(nCount) + '</FarmCode>'
			cXmlRet += ' <FarmDescription>Descrição da Fazenda ' + cValToChar(nCount) + '</FarmDescription>'
			cXmlRet += ' <SectorCode>12345' + cValToChar(nCount) + '</SectorCode>'
			cXmlRet += ' <SectorDescription>Descrição do Setor ' + cValToChar(nCount) + '</SectorDescription>'
			cXmlRet += ' <PartOfLandCode>12345' + cValToChar(nCount) + '</PartOfLandCode>'
			cXmlRet += ' <PartOfLandDescription>Descrição do Talhão ' + cValToChar(nCount) + '</PartOfLandDescription>'
			cXmlRet += ' <ItemCode>12345678901234' + cValToChar(nCount) + '</ItemCode>'
			cXmlRet += ' <ItemInternalId>99|12345678901234' + cValToChar(nCount) + '</ItemInternalId>'
			cXmlRet += ' <VarietyCode>12344' + cValToChar(nCount) + '</VarietyCode>'
			cXmlRet += ' <VarietyDescription>Descrição da Variedade ' + cValToChar(nCount) + '</VarietyDescription>'
			cXmlRet += ' <OccupationCode>123456789' + cValToChar(nCount) + '</OccupationCode>'
			cXmlRet += ' <OccupationDescription>Descrição da Ocupação ' + cValToChar(nCount) + '</OccupationDescription>'
			cXmlRet += ' <HarvestedArea>1234567.9' + cValToChar(nCount) + '</HarvestedArea>'
			cXmlRet += ' <HarvestEstimate>1234567.9' + cValToChar(nCount) + '</HarvestEstimate>'
			cXmlRet += ' <MainOrderCode>131313131313' + cValToChar(nCount) + '</MainOrderCode>'
			cXmlRet += ' <MainOrderInternalId>AAA|131313131313' + cValToChar(nCount) + '</MainOrderInternalId>'
			cXmlRet += ' </HarvestOrder>'
			
			Next Count
		
			
			cXmlRet += ' </ListOfHarvestOrders>'

		ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )

	         //--Faz o parser do XML de retorno em um objeto
	         oXML := xmlParser(cXML, "_", @cError, @cWarning)
	         oXMLContent := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent

			If ValType(oXMLContent:_ListOfHarvestOrders:_HarvestOrder) == "A" //Quando eh mais de um elemento, vem array

				For nCount := 1 To Len(oXMLContent:_ListOfHarvestOrders:_HarvestOrder)
					AGRA530OCD(oXMLContent:_ListOfHarvestOrders:_HarvestOrder[nCount], @_cCLTTEMP)
				Next nCount

			ElseIf ValType(oXMLContent:_ListOfHarvestOrders:_HarvestOrder) == "O" //Quando eh um elemento, vem objeto
				AGRA530OCD(oXMLContent:_ListOfHarvestOrders:_HarvestOrder, @_cCLTTEMP)
			EndIf

		//--------------------------------------------
		//--- RECEBIMENTO DA WHOIS   
		//--------------------------------------------			
		ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )
			cXMLRet := "1.000|1.001|1.002"
		EndIf

	ElseIf ( nTypeTrans == TRANS_SEND )
		oModel    := FWModelActive()
		If IsInCallStack("AGRA500") .Or. IsInCallStack("OGA250") .Or. IsInCallStack("OGA251") .Or. IsInCallStack('GFEA523') .OR. IsInCallStack('OGA250REA') .OR. IsInCallStack('OGA250CAN') 
			If IsInCallStack("AGRA500") .Or. IsInCallStack('GFEA523')
				oModelNNJ := oModel:GetModel('AGRA500_NJJ')
			Else
				oModelNNJ := oModel:GetModel('NJJUNICO')
			EndIf
			cFiltData := oModelNNJ:getValue("NJJ_DATA")
			cFiltOrd  := oModelNNJ:getValue("NJJ_ORDCLT")
			cFiltItem := oModelNNJ:getValue("NJJ_CODPRO")
		ElseIf IsInCallStack("AGRA601")
		
			oModelDXL := oModel:GetModel('DXLMASTER')
			cFiltData := oModelDXL:getValue("DXL_DTDIGI")
			cFiltOrd  := oModelDXL:getValue("DXL_ORDCLT")
			cFiltItem := oModelDXL:getValue("DXL_CODPRO")
		
		EndIf

		cXMLRet := AGRA530XML(/* Empresa */, /* Filial */, /* Data da Pesagem */ cFiltData, cFiltOrd, cFiltItem)
		
	EndIf
	FwRestRows(aLines)
	RestArea(aArea)
	
		aRet := {lRet, cXmlRet, "GETHARVESTORDER"}

Return aRet


