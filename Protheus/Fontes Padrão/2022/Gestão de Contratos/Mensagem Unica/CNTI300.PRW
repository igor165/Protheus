#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integra��o com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC
#Include 'PROTHEUS.CH'
#Include 'CNTI300.CH'

//==============================================================================================================================
/*/{Protheus.doc} CNTI300
Fun��o para processamento de mensagem �nica de integra��es do contrato.
Uso: CNTA300

@sample 	CNTI300( cXML, nTypeTrans, cTypeMessage )

@param		cXML 			Variavel com conteudo xml para envio/recebimento.
			nTypeTrans 		Tipo de transacao. (Envio/Recebimento)
			cTypeMessage	Tipo de mensagem.  (Business Type, WhoIs, Request)
			
@return		aRet			Array contendo o resultado da execu��o e o xml de retorno.
			aRet[1] 		[Logico] 	Indica o resultado da execu��o da fun��o. 
			aRet[2]			[Caracter] 	Mensagem Xml para envio.	
			
@author		Israel.Escorizza
@since		09/02/2018

@version	P12.1.20
/*/
//==============================================================================================================================
Function CNTI300( cXML, nTypeTrans, cTypeMessage , cVersion )
Local aArea		:= GetArea()								//- Salva contexto do alias atual  
Local aSaveLine	:= FWSaveRows()								//- Salva contexto do model ativo
Local cVersions := '2.000|2.001'

DO	CASE
	CASE cTypeMessage == EAI_MESSAGE_WHOIS
		aRet := {.T., cVersions, 'CONTRACT'}
		
	CASE Left(AllTrim(cVersion),1) == '2'
		aRet :=  CN300V2000(cXML, nTypeTrans, cTypeMessage)
	
	OTHERWISE
		aRet :=  {.F.,STR0001}
END DO

FWRestRows( aSaveLine )     
RestArea(aArea)
Return aRet

//==============================================================================================================================
/*/{Protheus.doc} CN300V2000
Fun��o para processamento de mensagem �nica de integra��es do contrato. Vers�o 2.000

@sample 	CN300V2000( cXML, nTypeTrans, cTypeMessage )

@param		cXML 			Variavel com conteudo xml para envio/recebimento.
			nTypeTrans 		Tipo de transacao. (Envio/Recebimento)
			cTypeMessage	Tipo de mensagem.  (Business Type, WhoIs, Request)
			
@return		aRet			Array contendo o resultado da execu��o e o xml de retorno.
			aRet[1] 		[Logico] 	Indica o resultado da execu��o da fun��o. 
			aRet[2]			[Caracter] 	Mensagem Xml para envio.	
			
@author		Israel.Escorizza
@since		09/02/2018

@version	P12.1.20
/*/
//==============================================================================================================================
Function CN300V2000( cXML, nTypeTrans, cTypeMessage)
Local aArea		:= GetArea()								//- Salva contexto do alias atual  
Local aSaveLine	:= FWSaveRows()								//- Salva contexto do model ativo

Local cEvent 	:= ''										//- Evento			

Local nPlan		:= 1										//- Variavel de controle de la�o das planilhas
Local nItem		:= 1										//- Variavel de controle de la�o dos itens

Local lRet 		:= .T.										//- Indica o resultado da execu��o da fun��o

//-- Vari�veis de controle do contrato ----------------------------------------------------------------------------------------
Local oModel	:= Nil										//- Objeto do modelo de dados completo
Local oModelCN9	:= Nil
Local oModelCNA	:= Nil
Local oModelCNB	:= Nil

Local cCtrFil	:= '' 										//- Filial do contrato
Local cCtrNum	:= '' 										//- N�mero do contrato
Local cCtrRev	:= '' 										//- Revis�o do contrato
Local cCtrTip	:= '' 										//- Tipo do contrato 
Local cDatIni	:= '' 										//- Data de inicio do contrato
Local cDtIniF	:= ''										//- Data de inicio do contrato formatada
Local cDatFim	:= '' 										//- Data de termino do contrato
Local cDtFimF	:= ''										//- Data de termino do contrato formatada
Local cCtrSit	:= ''										//- Situa��o do contrato
Local nCtrVlr	:= 0 										//- Valor atual do contrato (Valor Total)

Local cCodFor	:= '' 										//- Codigo do Fornecedor da Planilha
Local cLojFor	:= '' 										//- Codigo da Loja do Fornecedor da Planilha 

//-- Variaveis de controle do XML ---------------------------------------------------------------------------------------------
Local oXML 		 := Nil										//- Objeto com o conte�do do arquivo Xml

Local cXmlRet	:= ''										//- Xml que ser� enviado pela fun��o
Local cXmlErro	:= ''										//- Mensagem de erro do parse no xml recebido como par�metro
Local cXmlWarn	:= ''										//- Mensagem de alerta do parse no xml recebido como par�metro

Local nXml		:= 0										//- Variavel de controle de la�o do XML
Local cSituacAnt:= CN100SitCtr()
Local cInternalId := ""
Local cTempVal := ""

//-- Inicio do Adapter  -------------------------------------------------------------------------------------------------------
DO 	CASE
	CASE nTypeTrans == TRANS_RECEIVE
		DO	CASE
			CASE cTypeMessage == EAI_MESSAGE_BUSINESS
				lRet := .F.
				cXmlRet := STR0001							//- "Op��o n�o disponivel nesta vers�o."
				
			CASE cTypeMessage == EAI_MESSAGE_RESPONSE
				oXML := XmlParser( cXML, '_', @cXmlErro, @cXmlWarn )
				
				If  oXML <> Nil .And. ( Empty(cXmlErro)  .And.  Empty(cXmlWarn) )				
					cMarca  := oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text
					oXML := XmlChildEx(oXML, '_TOTVSMESSAGE')
					If XmlChildEx( oXML:_ResponseMessage:_ProcessingInformation, '_STATUS' ) <> Nil .And.;
					 	Upper(oXML:_ResponseMessage:_ProcessingInformation:_Status:Text)=='OK'					 	
					 	
					 	oXML := XmlChildEx( oXML:_ResponseMessage:_ReturnContent, "_LISTOFINTERNALID" )  
		
						If oXML <> Nil
							
							If XmlChildEx( oXML, "_INTERNALID" ) <> Nil
								
								If Valtype( oXML:_InternalId ) <> "A"
									XmlNode2Arr( oXML:_InternalId, "_InternalId" )
								EndIf
								
								For nXml := 1 To Len( oXML:_InternalId )
								
									If	XmlChildEx( oXML:_InternalId[nXml], "_ORIGIN" ) <> Nil .And. ;
										XmlChildEx( oXML:_InternalId[nXml], "_DESTINATION" ) <> Nil
									
										CFGA070Mnt( cMarca, 'CN9', 'CN9_NUMERO', ;
											oXML:_InternalId[nXml]:_Destination:Text, ;
											oXML:_InternalId[nXml]:_Origin:Text )											
									EndIf
																		
								Next nXml							
							Else							
								lRet := .F.
								cXmlRet := STR0003 // "N�o enviado conte�do de retorno para cadastro de de-para"							
							EndIf							
						Else							
							lRet := .F.
							cXmlRet := STR0004 // "N�o � poss�vel gravar de-para por causa de erro na leitura do retorno"						
						EndIf
					Else
						lRet    := .F.						
						If XmlChildEx( oXML:_TotvsMessage:_ResponseMessage:_ProcessingInformation, "_LISTOFMESSAGES" ) <> Nil
							oXML := oXML:_TotvsMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages
							
							If XmlChildEx( oXML, "_MESSAGE" ) <> Nil 
								
								If Valtype( oXML:_Message ) <> "A"
									XmlNode2Arr( oXML:_Message, "_Message" )
								EndIf
								
								For nXml := 1 To Len( oXML:_Message )								
									cXmlRet += Alltrim( oXML:_Message[nXml]:Text ) + "|"								
								Next nXml
							
							Else
								cXmlRet := STR0005 //"Erro no processamento, mas sem detalhes do erro pela outra aplica��o"
							EndIf
							
						EndIf						
					EndIf
				Else
					lRet    := .F.
					cXmlRet := STR0002 + cXmlErro + '|' + cXmlWarn //-"Falha de XML:"
				EndIf				
		END DO
		
	CASE nTypeTrans == TRANS_SEND
		
	
		oModel		:= FwModelActive()						//- Objeto do modelo de dados completo
		oModelCN9	:= oModel:GetModel('CN9MASTER')
		oModelCNA	:= oModel:GetModel('CNADETAIL')
		oModelCNB	:= oModel:GetModel('CNBDETAIL')

		cCtrFil	:= oModelCN9:GetValue('CN9_FILCTR') 		//- Filial do contrato
		cCtrNum	:= oModelCN9:GetValue('CN9_NUMERO') 		//- N�mero do contrato
		cCtrRev	:= oModelCN9:GetValue('CN9_REVISA') 		//- Revis�o do contrato
		cCtrTip	:= oModelCN9:GetValue('CN9_TPCTO' )			//- Tipo do contrato 
		cDatIni	:= oModelCN9:GetValue('CN9_DTINIC')			//- Data de inicio do contrato
		cDtIniF := Year2Str(cDatIni) +"-"+ Month2Str(cDatIni) +"-"+ Day2Str(cDatIni)
		cDatFim	:= oModelCN9:GetValue('CN9_DTFIM' )			//- Data de termino do contrato
		cDtFimF := Year2Str(cDatFim) +"-"+ Month2Str(cDatFim) +"-"+ Day2Str(cDatFim)
		nCtrVlr	:= oModelCN9:GetValue('CN9_VLATU' )			//- Valor atual do contrato (Valor Total)

		cCodFor	:= oModelCNA:GetValue('CNA_FORNEC')			//- Codigo do Fornecedor da Planilha
		cLojFor	:= oModelCNA:GetValue('CNA_LJFORN')			//- Codigo da Loja do Fornecedor da Planilha 
		
		cCtrSit	:= oModelCN9:GetValue('CN9_SITUAC')+'|'		//- Situa��o do contrato
		
		cInternalId := cEmpAnt +'|'+ cCtrFil +'|'+ cCtrNum +'|'+ cCtrRev
		
		
		//Se Cancelado OU (Em Elaboracao e situacao anterior Vigente)
		If  ( (cCtrSit == "01|") .Or. (cCtrSit == "02|" .And. cSituacAnt == "05") .Or. ( oModel:GetOperation() == MODEL_OPERATION_DELETE ) ) 
			cEvent := 'delete'
			
			CFGA070Mnt( , "CN9", "CN9_NUMERO", , cInternalId, .T. ) //Exclui De/Para
		Else
			cEvent := 'upsert'
		EndIf
		
		//Monta Business Event
		cXMLRet := '<BusinessEvent>'
		cXMLRet +=     '<Entity>Contract</Entity>'
		cXMLRet +=     '<Event>' + cEvent + '</Event>'
		cXMLRet +=     '<Identification>'
		cXMLRet +=         '<key name="InternalID">' + cInternalId + '</key>'
		cXMLRet +=     '</Identification>'
		cXMLRet += '</BusinessEvent>'
		
		cXmlRet	+=	'<BusinessContent>'
		cXmlRet	+= 	'<CompanyId>' 				+ cEmpAnt + '</CompanyId>'															//- Empresa
		cXmlRet	+= 	'<BranchId>'				+ cCtrFil + '</BranchId>'															//- Filial
		cXmlRet	+=  '<InternalId>'				+ cInternalId + '</InternalId>'   			//- InternalId Contrato - EMPRESA|CN9_FILIAL|CN9_NUMERO|CN9_REVISA
		cXmlRet	+= 	'<ContractNumber>'			+ cCtrNum + '</ContractNumber>'														//- N�mero do contrato
		cXmlRet	+= 	'<ContractReview>'			+ cCtrRev + '</ContractReview>'														//- Revis�o do contrato
		cXmlRet	+= 	'<BeginDate>'				+ cDtIniF + '</BeginDate>'															//- Data de inicio do contrato
		cXmlRet	+= 	'<FinalDate>'				+ cDtFimF +	'</FinalDate>'															//- Data de termino do contrato
		
		cXmlRet	+= 	'<CustomerCode>' 			+ cCodFor + '</CustomerCode>'														//- C�digo do fornecedor Cod_Fornecedor
		cXmlRet	+= 	'<StoreId>' 				+ cLojFor + '</StoreId>'															//- C�dico da loja do fornecedor
		cXmlRet	+= 	'<CustomerInternalId>' 		+ IntForExt(, cCtrFil, cCodFor, cLojFor)[2] + '</CustomerInternalId>'		//- InternalId Fornecedor - EMPRESA|A2_FILIAL|A2_COD|A2_LOJA
		
		cXmlRet	+= 	'<ContractTotalValue>' 		+ cValToChar(nCtrVlr) + '</ContractTotalValue>'										//- Valor atual do contrato
		cXmlRet	+= 	'<ContractTypeCode>' 		+ cCtrTip + '</ContractTypeCode>'													//- Tipo do contrato
		cXmlRet	+= 	'<ContractTypeInternalId>' 	+ cEmpAnt +'|'+ cCtrFil +'|'+ cCtrTip + '</ContractTypeInternalId>'					//- InternalId Tipo do contrato - EMPRESA|CN1_FILIAL|CN1_CODIGO
				
		cXmlRet	+= 	'<ListOfSheet>' //-- Lista de Planilhas
		For nPlan := 1 To oModelCNA:Length()
			oModelCNA:GoLine(nPlan)
			If !oModelCNA:IsDeleted()
				cXmlRet	+= 	'<Sheet>' 	
				cXmlRet	+= 		'<SheetNumber>'		+ oModelCNA:GetValue('CNA_NUMERO') 				+ '</SheetNumber>'				//- Numero da Planilha
				cXmlRet	+=  	'<SheetType>'		+ oModelCNA:GetValue('CNA_TIPPLA') 				+ '</SheetType>'				//- Tipo da Planilha		
				cXmlRet	+= 		'<SheetTotalValue>'	+ cValToChar(oModelCNA:GetValue('CNA_VLTOT' )) 	+ '</SheetTotalValue>'			//- Valor Total da Planilha	 		
		
				cXmlRet	+= 		'<ListOfItem>' //-- Lista de Itens		
				For nItem := 1 To oModelCNB:Length()
					oModelCNB:GoLine(nItem)
					If !oModelCNB:IsDeleted()
						cXmlRet	+= 	'<Item>'
						cXmlRet	+=		'<ItemCode>'					+ oModelCNB:GetValue('CNB_PRODUT') + '</ItemCode>'						//- C�digo da Produto
						cXmlRet	+=		'<ItemInternalId>' 				+ cEmpAnt +'|'+ cCtrFil +'|'+ oModelCNB:GetValue('CNB_PRODUT') +'</ItemInternalId>'				//- InternalId do Produto			- EMPRESA|B1_FILIAL|B1_COD
						
						/*Conta cont�bil*/
						cTempVal:= oModelCNB:GetValue('CNB_CONTA')
						cXmlRet	+= '<AccountantAcountCode>'		+ cTempVal + '</AccountantAcountCode>'						 
						if(!Empty(cTempVal))
							//Montado conforme exemplo do CTBI020, n�o tem fun��o gen�rica para montar o InternalId da conta cont�bil 
							cTempVal := cEmpAnt + "|" + xFilial("CT1", cCtrFil) + "|" + AllTrim(cTempVal)
						endIf
						cXmlRet	+= '<AccountantAcountInternalId>'	+ cTempVal + '</AccountantAcountInternalId>'						

						/*Centro de Custo*/
						cTempVal:= oModelCNB:GetValue('CNB_CC')
						cXmlRet	+= '<CostCenterCode>'		+ cTempVal													+ '</CostCenterCode>'				
						cXmlRet	+= '<CostCenterInternalId>'	+ IIF(Empty(cTempVal),"",IntCusExt(, cCtrFil, cTempVal)[2])	+ '</CostCenterInternalId>'

						/*Item Cont�bil*/
						cTempVal:= oModelCNB:GetValue('CNB_ITEMCT')
						cXmlRet	+= '<AccountingItemCode>'		+ cTempVal													+ '</AccountingItemCode>' 
						cXmlRet	+= '<AccountingItemInternalId>'	+ IIF(Empty(cTempVal), "", C040MntInt(cCtrFil,cTempVal))	+ '</AccountingItemInternalId>'

						/*Classe de Valor*/
						cTempVal:= oModelCNB:GetValue('CNB_CLVL')
						cXmlRet	+= '<ClassValueCode>'		+ cTempVal													+ '</ClassValueCode>'
						cXmlRet	+= '<ClassValueInternalId>' + IIF(Empty(cTempVal), "", C060MntInt(cCtrFil,cTempVal))	+ '</ClassValueInternalId>'
						
						cXmlRet	+= 		'<ItemQuantity>' 				+ cValToChar(oModelCNB:GetValue('CNB_QUANT' )) + '</ItemQuantity>'			//- Quantidade
						cXmlRet	+= 		'<ItemUnitPrice>' 				+ cValToChar(oModelCNB:GetValue('CNB_VLUNIT')) + '</ItemUnitPrice>'			//- Pre�o Unit�rio
						cXmlRet	+= 		'<ItemTotalValue>' 				+ cValToChar(oModelCNB:GetValue('CNB_VLTOT' )) + '</ItemTotalValue>'		//- Valor Total
						cXmlRet	+= 		'<PercentageOfDiscount>' 		+ cValToChar(oModelCNB:GetValue('CNB_DESC'  )) + '</PercentageOfDiscount>'	//- % de Desconto
						cXmlRet	+= 	'</Item>'	
					EndIf 	
				Next nItem	
				cXmlRet	+= 		'</ListOfItem>'	
				cXmlRet	+= '</Sheet>'
			EndIf
		Next nPlan
		cXmlRet	+= '</ListOfSheet>'
		cXmlRet	+= '</BusinessContent>'
END DO

CN100LStCt()//Limpa a vari�vel est�tica __cSitACtr do CNTA100
FWRestRows(aSaveLine)     
RestArea(aArea)
Return {lRet,cXmlRet, 'CONTRACT'}

//==============================================================================================================================
/*/{Protheus.doc} CnCtrxPims()
Fun��o respons�vel por validar se o contrato ir� realizar integra��o com o PIMS
@author		Israel.Escorizza
@since		16/02/2018
@version	P12.1.20
/*/
//==============================================================================================================================
Function CnCtrxPims()      
	Local lRet	 	:= .F.
	Local lIntPIMS	:= SuperGetMV('MV_CNXPIMS',.F.,.F.) // Integra��o PIMS ativa 
	Local lCtrPIMS	:= CN300RetSt('INTPIMS') //Contrato deve ser integrado com o PIMS
	
	If (lIntPIMS .And. lCtrPIMS)	
		lRet := !(	(Alltrim(CN9->CN9_SITUAC) $ '09|A' .And. !FwIsInCallStack('CN300Delet')) .Or.;
		 			(AllTrim(CN9->CN9_SITUAC) == '02' .And. CN100SitCtr() != '05')) 
	EndIf
Return lRet