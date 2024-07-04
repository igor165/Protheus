#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "MATI340.CH"           

//-------------------------------------------------------------------
/*{Protheus.doc} MATI340
Programa de interpretacao da mensagem unica

@since 11/01/2012
@version P11.5
@param	cXML - Variavel com conteudo xml para envio/recebimento.
@param	nTypeTrans - Tipo de transacao. (Envio/Recebimento)
@param	cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc)
@param	cAliasSB7 - Alias de trabalho do acerto de inventário para busca das informações do ajuste
@param	nQuant - Quantidade total considerada como saldo do documento inventariado
@param	nQuant2UM - Qtde total considerada como saldo do documento inventariado na segunda unidade de medida
@return	aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno
	aRet[1] - (boolean) Indica o resultado da execução da função
	aRet[2] - (caracter) Mensagem Xml para envio
*/
//-------------------------------------------------------------------
Function MATI340(cXML,nTypeTrans,cTypeMessage,nQuant,nQuant2UM, lAcertoSd)
Local	aArea		:= GetArea()
Local 	aAreaB7	:= {}
Local	lRet     	:= .T.
Local 	cXMLRet  	:= ""
Local 	cEvent   	:= "upsert"     
Local 	cWarning 	:= ""
Local 	cError		:= ""       
Local cAliasSB7 	:= "SB7"   
Local  	nCount		:= 0
Local	oXmlA340	:= Nil


If nTypeTrans == TRANS_RECEIVE
	If   cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := '1.000'
	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
		oXmlA340 := XmlParser(cXml, "_", @cError, @cWarning)    		
		VarInfo('XML RESPONSE',cXML)
		
		If oXmlA340 <> Nil .And. Empty(cError) .And. Empty(cWarning)
			cMarca     := oXmlA340:_TotvsMessage:_MessageInformation:_Product:_Name:Text
			oXmlA340   := oXmlA340:_TotvsMessage:_ResponseMessage
			
			//--  Identifica se o processamento teve erro
			If !(XmlChildEx( oXmlA340:_ProcessingInformation, '_STATUS' ) <> Nil .And. Upper(oXmlA340:_ProcessingInformation:_Status:Text) == 'OK')       
				lRet    := .F.
				cXmlRet := STR0003 //-- Processamento pela outra aplicação não teve sucesso
				
				//-- Transforma estrutura das mensagens de erro em array para concatenar com a mensagem de retorno              
				If XmlChildEx(oXmlA340:_ProcessingInformation,'_LISTOFMESSAGES') <> NIL .And. ;
					ValType(oXmlA340:_ProcessingInformation:_ListOfMessages) <> 'A'
					XmlNode2Arr(oXmlA340:_ProcessingInformation:_ListOfMessages, "_ListOfMessages")
				EndIf

				For nCount := 1 To Len(oXmlA340:_ProcessingInformation:_ListOfMessages)   
					If XmlChildEx( oXmlA340:_ProcessingInformation:_ListOfMessages[nCount], '_MESSAGE' ) <> NIL
						cXmlRet += ' | ' + oXmlA340:_ProcessingInformation:_ListOfMessages[nCount]:_Message:Text
					Endif					
				Next nCount 
				
				If InTransact()
					DisarmTransaction()
				EndIf
			EndIf
		Else
			lRet := .F.
			cXmlRet := STR0001 + ' | ' + STR0002 //-- Falha na manipulação do arquivo XML' #### 'De-Para não pode ser gravado'
		EndIf
	EndIf
ElseIf nTypeTrans == TRANS_SEND
	If nQuant == NIL
		nQuant := ((cAliasSB7)->B7_QUANT)
	EndIf
	If nQuant2UM == NIL
		nQuant2UM := ((cAliasSB7)->B7_QTSEGUM)
	EndIf
	
	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>INVENTORY</Entity>'
	cXMLRet +=     '<Event>' +cEvent +'</Event>'
	cXMLRet +=     '<Identification>'	
	cXMLRet +=         '<key name="DateInventory">' +DToS((cAliasSB7)->B7_DATA)	+'</key>'
	cXMLRet +=         '<key name="ItemCode">' + cEmpAnt + '|' + RTrim(xFilial('SB1'))+  '|' + ((cAliasSB7)->B7_COD) +'</key>'	
	cXMLRet +=         '<key name="WareHouseCode">' + cEmpAnt + '|' + RTrim(xFilial('NNR'))+ '|' +((cAliasSB7)->B7_LOCAL) 	+'</key>'					
	
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'
	
	cXMLRet += ' <BusinessContent> '
    cXMLRet +=		' <CompanyId>' +cEmpAnt +'</CompanyId> '
    cXMLRet +=		' <BranchId>' +cFilAnt +'</BranchId> '
    cXMLRet +=		' <CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
         
	cXMLRet +=         '<ItemCode>' + cEmpAnt + '|' + RTrim(xFilial('SB1'))+  '|' + ((cAliasSB7)->B7_COD) +'</ItemCode> '	
	cXMLRet +=         '<WarehouseCode>' + cEmpAnt + '|' + RTrim(xFilial('NNR'))+ '|' +((cAliasSB7)->B7_LOCAL) +'</WarehouseCode> '
    
    If lAcertoSd
    	cXMLRet +=		' <DocumentNumber>' +SD3->D3_DOC +'</DocumentNumber> '
    Else
    	cXMLRet +=		' <DocumentNumber>INVENT</DocumentNumber> '    	
	EndIf    	
    
    
    cXMLRet +=		' <Quantity>' +cValToChar(nQuant) + '</Quantity> '
    cXMLRet +=		' <Quantity2UnitMeasure>' +cValToChar(nQuant2UM) +'</Quantity2UnitMeasure> '
    
    cXMLRet +=		' <DateInventory>' +	Transform(DToS(((cAliasSB7)->B7_DATA)),"@R 9999-99-99")+ '</DateInventory> '
	
	cXMLRet +=		' <LotNumber>' +((cAliasSB7)->B7_LOTECTL) +'</LotNumber> '
	cXMLRet +=		' <SubLotNumber>' +((cAliasSB7)->B7_NUMLOTE) +'</SubLotNumber> '
	
	cXMLRet +=		' <LotExpirationDate>' +Transform(DToS(((cAliasSB7)->B7_DTVALID)),"@R 9999-99-99") +'</LotExpirationDate> ' 
	
	If lAcertoSd
		SB2->(dbSeek(xFilial("SB2")+SD3->D3_COD+SD3->D3_LOCAL))
	 	If SD3->D3_TM <= "500"
			cXMLRet += 	'<TotalStock>'  + AllTrim(cValToChar(SB2->B2_QATU - MTICalPrd(SD3->(D3_FILIAL+D3_DOC+D3_COD),SD3->D3_LOCAL))) + '</TotalStock>'
		Else
			cXMLRet += 	'<TotalStock>'  + AllTrim(cValToChar(SB2->B2_QATU + MTICalPrd(SD3->(D3_FILIAL+D3_DOC+D3_COD),SD3->D3_LOCAL))) + '</TotalStock>'				
		EndIf
		If !Empty(SD3->D3_LOTECTL)
			If SD3->D3_TM <= "500"
				cXMLRet +=	'<LotStock>' + AllTrim(cValToChar(SaldoLote(SD3->D3_COD,SD3->D3_LOCAL,SD3->D3_LOTECTL,NIL,.T.,.T.,NIL,dDataBase)- MTICalPrd(SD3->(D3_FILIAL+D3_DOC+D3_COD),SD3->D3_LOCAL,SD3->D3_LOTECTL))) + '</LotStock>'
			Else
				cXMLRet +=	'<LotStock>' + AllTrim(cValToChar(SaldoLote(SD3->D3_COD,SD3->D3_LOCAL,SD3->D3_LOTECTL,NIL,.T.,.T.,NIL,dDataBase)+ MTICalPrd(SD3->(D3_FILIAL+D3_DOC+D3_COD),SD3->D3_LOCAL,SD3->D3_LOTECTL))) + '</LotStock>'					
			EndIf						
		EndIf
		If !Empty(SD3->D3_LOCALIZ)
			If SD3->D3_TM <= "500"
				cXMLRet +=	'<BinStock>' + AllTrim(cValToChar(SaldoSBF(SD3->D3_LOCAL,SD3->D3_LOCALIZ,SD3->D3_COD,NIL,SD3->D3_LOTECTL,NIL,.T.)- MTICalPrd(SD3->(D3_FILIAL+D3_DOC+D3_COD),SD3->D3_LOCAL,SD3->D3_LOTECTL,SD3->D3_LOCALIZ))) + '</BinStock>'
			Else
				cXMLRet +=	'<BinStock>' + AllTrim(cValToChar(SaldoSBF(SD3->D3_LOCAL,SD3->D3_LOCALIZ,SD3->D3_COD,NIL,SD3->D3_LOTECTL,NIL,.T.)+ MTICalPrd(SD3->(D3_FILIAL+D3_DOC+D3_COD),SD3->D3_LOCAL,SD3->D3_LOTECTL,SD3->D3_LOCALIZ))) + '</BinStock>'					
			EndIf						
		EndIf
		If !Empty(SD3->D3_NUMSERI)
			If SD3->D3_TM <= "500"
				cXMLRet +=	'<SeriesStock>' + AllTrim(cValToChar(SaldoSBF(SD3->D3_LOCAL,SD3->D3_LOCALIZ,SD3->D3_COD,SD3->D3_NUMSERI,SD3->D3_LOTECTL,NIL,.T.)- MTICalPrd(SD3->(D3_FILIAL+D3_DOC+D3_COD),SD3->D3_LOCAL,SD3->D3_LOTECTL,SD3->D3_LOCALIZ,SD3->D3_NUMSERI))) + '</SeriesStock>'
			Else
				cXMLRet +=	'<SeriesStock>' + AllTrim(cValToChar(SaldoSBF(SD3->D3_LOCAL,SD3->D3_LOCALIZ,SD3->D3_COD,SD3->D3_NUMSERI,SD3->D3_LOTECTL,NIL,.T.)+ MTICalPrd(SD3->(D3_FILIAL+D3_DOC+D3_COD),SD3->D3_LOCAL,SD3->D3_LOTECTL,SD3->D3_LOCALIZ,SD3->D3_NUMSERI))) + '</SeriesStock>'
			EndIf								
		EndIf	
								
	Else
	//--B7		
		SB2->(dbSeek(xFilial("SB2")+((cAliasSB7)->B7_COD)+((cAliasSB7)->B7_LOCAL)))
		cXMLRet += '<TotalStock>'  + AllTrim(cValToChar(SB2->B2_QATU)) + '</TotalStock>'
				
		If !Empty((cAliasSB7)->B7_LOTECTL)
			cXMLRet +=	'<LotStock>' 	  + AllTrim(cValToChar(SaldoLote(((cAliasSB7)->B7_COD), ((cAliasSB7)->B7_LOCALIZ),((cAliasSB7)->B7_LOTECTL),NIL,.T.,.T.,NIL,dDataBase))) + '</LotStock>'
		EndIf
		
		If !Empty((cAliasSB7)->B7_LOCALIZ)
			cXMLRet +=	'<BinStock>' 	  + AllTrim(cValToChar(SaldoSBF(((cAliasSB7)->B7_LOCAL),((cAliasSB7)->B7_LOCALIZ),((cAliasSB7)->B7_COD),NIL,((cAliasSB7)->B7_LOTECTL),NIL,.T.))) + '</BinStock>'
		EndIf
		
		If !Empty((cAliasSB7)->B7_NUMSERI)
			cXMLRet +=	'<SeriesStock>' + AllTrim(cValToChar(SaldoSBF(((cAliasSB7)->B7_LOCAL),((cAliasSB7)->B7_LOCALIZ),((cAliasSB7)->B7_COD),((cAliasSB7)->B7_NUMSERI),((cAliasSB7)->B7_LOTECTL),NIL,.T.))) + '</SeriesStock>'
		EndIf							
	EndIf	
	
	cXMLRet += ' </BusinessContent> '
	
	If !Empty(aAreaB7)
		SB7->(RestArea(aAreaB7))
	EndIf
EndIf

RestArea(aArea)
Return {lRet,cXMLRet}


//-------------------------------------------------------------------
/*/{Protheus.doc} MTICalPrd()
Soma a quantidade de produtos iguais do mesmo lote ou endereço
para considerar no calculo do saldo anterior
@author Leonardo Quintania
@since 11/12/2013	
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function MTICalPrd(cChave,cArmazem,cLote,cEndereco,cNumSerie)
Local nRet			:= 0
Local aRestSD3		:= SD3->(GetArea())

Default cLote		:= ""
Default cEndereco	:= ""
Default cNumSerie	:= ""

SD3->(DbSetOrder(2))
If	SD3->(DbSeek(cChave))
	While SD3->(!EOF()) .And. SD3->(D3_FILIAL+D3_DOC+D3_COD) == cChave
		If cArmazem == SD3->D3_LOCAL
			If Empty(cLote+cEndereco+cNumSerie) .Or. SD3->D3_LOTECTL == cLote .Or. SD3->D3_LOCALIZ == cEndereco .Or. SD3->D3_NUMSERI == cNumSerie
				nRet+=	SD3->D3_QUANT
			EndIf
		Endif
		SD3->(DbSkip())
	EndDo
EndIf
SD3->(RestArea(aRestSD3))

Return nRet
