#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OGI250.CH"

#DEFINE DOGI250ROT "OGI250"
#DEFINE DOGI250MSG "PACKINGLIST"
#DEFINE DOGI250VER "1.000"

/*/{Protheus.doc} OGI250
Adapter de Integração SIGAAGR 
 Mensagem Única: PackingList
 Validação realizada na função IntegDef do OGA250
@type function
@author Marcos Wagner Junior
@version 12
@since 05/07/2017
@param [cXml], Caracter, XML recebido pelo EAI Protheus
@param [cType], Caracter, Tipo de transação
@param [cTypeMessage], Caracter, Tipo da mensagem do EAI
@param [cVersion], Caracter, Versão da Mensagem Única TOTVS
@param [cTransaction], Caracter, Nome da mensagem iniciada no adapter
@return Array Informações de retorno
@obs Informações de retorno:
@obs Array[1] - Processamento foi executado com sucesso (.T.) ou não (.F.)
@obs Array[2] - Uma string contendo informações sobre o processamento
@obs Array[3] - Uma string com o nome da mensagem única desta mensagem
/*/
Function OGI250(cXml, cTypeTran, cTypeMsg, cVersion)

	Local oXml			:=NIL
	Local oModel		:=NIL
	Local aErro			:=NIL
	Local cCode 		:=''
	Local cLocalCode	:=NIL
	Local cType			:=NIL
	Local cErro			:=NIL
	Local cEvent		:=NIL
	Local cInternalId	:=NIL
	Local cValExt		:=NIL
	Local nX			:=NIL
	Local lRet:=.T.
	Local oModel, oAux, oStruct
	Local nI := 0
	Local nJ := 0
	
	Local nPos := 0
	Local aAux := {}
	Local aC := {}
	Local aH := {}
	Local nItErro := 0
	Local lAux := .T.
	Local cStsPsg := '0'
	Local cStatus := '0'

	Private cXmlRet		:= ''
	Private cProduct	:= NIL

	Do Case
		Case (cTypeTran ==TRANS_SEND )
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',STR0015 , 0, 0, {})
		Case ( cTypeTran == TRANS_RECEIVE )
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',STR0016 +cXMLRet , 0, 0, {})
			Do Case
				Case (cTypeMsg == EAI_MESSAGE_WHOIS )//whois 
					cXmlRet := '1.000'
				Case (cTypeMsg == EAI_MESSAGE_RESPONSE )//resposta da mensagem única TOTVS
					oXml:=tXmlManager():New()
					oXml:Parse(cXml)
					If Empty(oXml:Error())
						/*conout("conout response 2")
						cProduct:=oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product','name')
						For nX:=1 to oXml:xPathChildCount("/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId")
						conout("conout response 3")
							cInternalId:=oXml:xPathGetNodeValue("/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId["+cValToCharn(nX)+"]/Origin")
							cValExt:=oXml:xPathGetNodeValue("/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId["+cValToCharn(nX)+"]/Destination")
							If !Empty(cValExt) .and. !Empty(cInternalId)
								conout("conout response 4")
								GF250PutId( cProduct,  cValExt, cInternalId)
							Endif
						Next*/
					Endif
					oXml:=Nil
				Case (cTypeMsg == EAI_MESSAGE_RECEIPT )//Receipt. Não realizo nenhuma ação

				Case ( cTypeMsg == EAI_MESSAGE_BUSINESS )//chegada de mensagem de negócios
					oXml:=tXmlManager():New()
					oXml:Parse(cXml)
					If Empty(cErro:=oXml:Error())
			      		cValExt:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Identification/Key')
			      		cEvent:=AllTrim(Upper(oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event')))
			      		cCode:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/InternalId')
			      		cType:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/Type')
			      		cProduct:=oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product','name')
			      		Ticket:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/Ticket')
		      			cCodeOrig := cCode //Utilizado para gravação do De / Para 
		      			
			      		cCodeDest := OGIDEPAR('NJJ','NJJ_CODROM',cCode,'')
						If Len(StrTokArr(cCodeDest, "|") ) > 0 
							//cCode := StrTokArr(cCodeDest, "|")[3]
						EndIf
						 
		      			//cInternalId:=GF250MakeId(cCode)
						//conout("conout INICIO cCode: "+cCode)
						//conout("conout cInternalId: "+cInternalId)
			      			
			      		If cEvent=='UPSERT'
			      			//conout("conout UPSERT 1: "+cCode)
			      			If !Empty(cCode) .and. NJJ->(DbSeek(xFilial('NJJ')+cCode))//se encontrou, é atualização
			      				If NJJ->NJJ_STATUS >= '2'
									lRet := .f.
									cXMLRet := STR0001 //"O status do Romaneio não permite a operação"
								EndIf
								cEvent := MODEL_OPERATION_UPDATE
								//conout("conout UPSERT 2: "+cCode)
							Else
								cEvent := MODEL_OPERATION_INSERT
								/*If !Empty(Ticket)
									cAliasQry := GetNextAlias()
									cQry :=    " SELECT NJJ.NJJ_STATUS, NJJ.NJJ_CODROM "
									cQry +=    " FROM " + RetSQLName("NJJ") + " NJJ "
									cQry +=    " WHERE NJJ.NJJ_FILIAL = '" + XFilial("NJJ") + "' "
									cQry +=    "   AND NJJ.NJJ_TKTCLA = '" + Ticket + "'"
									cQry +=    "   AND NJJ.D_E_L_E_T_    = ' ' "
									cQry := ChangeQuery( cQry ) 
									dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
									(cAliasQry)->( dbGoTop() )      
									If (cAliasQry)->( !Eof() )        
										cEvent:=MODEL_OPERATION_UPDATE
										NJJ->(DbSeek(xFilial('NJJ')+(cAliasQry)->NJJ_CODROM))
										cCode := (cAliasQry)->NJJ_CODROM
										cInternalId:=GF250MakeId((cAliasQry)->NJJ_CODROM)
										If (cAliasQry)->NJJ_STATUS >= '2'
											lRet := .f.
											cXMLRet := STR0001 //"O status do Romaneio não permite a operação"
										EndIf
									EndIf
									(cAliasQry)->(dbCloseArea())
								EndIf*/
								//conout("conout UPSERT 3: "+cCode)
								If cEvent == MODEL_OPERATION_INSERT
									//conout("conout UPSERT 3.1: ")

									//conout("conout UPSERT 3.1: ")


									//conout("conout UPSERT 3.2: ")
										//cCode := GetSXENum('NJJ','NJJ_CODROM')
										If Empty(cCode)
											cCode := GetNextNJJ(cCode)
										EndIf


								EndIf
							Endif
							//conout("conout UPSERT 7: "+cCode)
						ElseIf cEvent=='DELETE'
							If !Empty(cCode) .and. NJJ->(DbSeek(xFilial('NJJ')+cCode))
								cEvent:=MODEL_OPERATION_DELETE
							Else
								If !Empty(Ticket)
									cAliasQry := GetNextAlias()
									cQry :=    " SELECT NJJ.NJJ_CODROM "
									cQry +=    " FROM " + RetSQLName("NJJ") + " NJJ "
									cQry +=    " WHERE NJJ.NJJ_FILIAL = '" + XFilial("NJJ") + "' "
									cQry +=    "   AND NJJ.NJJ_TKTCLA = '" + Ticket + "'"
									cQry +=    "   AND NJJ.D_E_L_E_T_    = ' ' "
									cQry := ChangeQuery( cQry ) 
									dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
									(cAliasQry)->( dbGoTop() )      
									If (cAliasQry)->( !Eof() )        
										cEvent:=MODEL_OPERATION_DELETE
										NJJ->(DbSeek(xFilial('NJJ')+(cAliasQry)->NJJ_CODROM))
										cCode := (cAliasQry)->NJJ_CODROM
										//conout("conout NOVO 7 - "+cCode)
										//cInternalId:=GF250MakeId((cAliasQry)->NJJ_CODROM)
									Else
										lRet:=.F.
										cXmlRet:= STR0002 //'Romaneio não encontrado com a chave informada (Cod Romaneio / Ticket)'
									EndIf
									(cAliasQry)->(dbCloseArea())
								Else
									lRet:=.F.
									cXmlRet:= STR0002 //'Romaneio não encontrado com a chave informada (Cod Romaneio / Ticket)'
								EndIf
							Endif
						Else
							lRet:=.F.
							cXmlRet:= STR0003 //'Operação inválida. Somente são permitidas as operações UPSERT e DELETE.'
						Endif
						//conout("conout lRetlRet: ")
						If lRet
						//conout("conout lRet TRUE ")
				      		cPlate   				:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/Plate')
				      		cCarrierFederalID   	:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/CarrierFederalID') //SA4.A4_CGC | NJJ.NJJ_CODTRA
				      		dbSelectArea("SA4")
				      		dbSetOrder(03)
				      		If !Empty(cCarrierFederalID) .AND. dbSeek(xFilial("SA4")+cCarrierFederalID)
				      			cCarrierFederalID := SA4->A4_COD
				      		Else
				      			If !Empty(cCarrierFederalID)
					      			lRet := .f.
									cXMLRet := STR0004 + cCarrierFederalID //"Não foi encontrado Transportador com o CNPJ/CPF informado: " 
								EndIf
				      			cCarrierFederalID := ""
				      		EndIf
			      			dbSetOrder(01)
			      			
				      		DriverFederalID 		:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/DriverFederalID') //DA4_CGC | NJJ.NJJ_CODMOT
				      		dbSelectArea("DA4")
				      		dbSetOrder(03)
				      		If !Empty(DriverFederalID) .AND. dbSeek(xFilial("DA4")+DriverFederalID)
				      			DriverFederalID := DA4->DA4_COD
				      		Else
				      			If !Empty(DriverFederalID)
					      			lRet := .f.
									cXMLRet := STR0005 + DriverFederalID //"Não foi encontrado Motorista com o CNPJ/CPF informado: " 
								EndIF
								DriverFederalID := ""
				      		EndIf
				      		dbSetOrder(01)
				      		
				      		EntityFederalID 		:= AllTrim(oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/EntityFederalID')) //NJ0_CGC | NJJ.NJJ_CODENT | NJJ.NJJ_LOJENT
							cAliasQry := GetNextAlias()
							cQry :=    " SELECT NJ0.NJ0_CODENT, NJ0.NJ0_LOJENT "
							cQry +=    " FROM " + RetSQLName("NJ0") + " NJ0 "
							cQry +=    " WHERE NJ0.NJ0_FILIAL    = '" + XFilial("NJ0") + "' "
							cQry +=    "   AND NJ0.NJ0_CGC       = '" + EntityFederalID + "'"
							cQry +=    "   AND NJ0.D_E_L_E_T_    = ' ' "
							cQry := ChangeQuery( cQry ) 
							dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
							(cAliasQry)->( dbGoTop() )      
							If (cAliasQry)->( !Eof() )        
								EntityFederalID := (cAliasQry)->NJ0_CODENT
								EntityStore     := (cAliasQry)->NJ0_LOJENT
							Else
								If !Empty(EntityFederalID)
									lRet := .f.
									cXMLRet := STR0006 + EntityFederalID  //"Não foi encontrada Entidade com o CNPJ/CPF informado: " 
								EndIF
								EntityFederalID := ""
								EntityStore     := ""
							EndIf
							(cAliasQry)->(dbCloseArea())
				      		DeliveryEn := AllTrim(oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/DeliveryEntity')) //NJ0_CGC | NJJ.NJJ_ENTENT | NJJ.NJJ_ENTLOJ
				      		DeliverySt := "    "
							//conout("Conout AAA - 1"+XFilial("NJ0"))
							//conout("Conout AAA - 1"+DeliveryEn)
							cAliasQry := GetNextAlias()
							cQry :=    " SELECT NJ0.NJ0_CODENT, NJ0.NJ0_LOJENT "
							cQry +=    " FROM " + RetSQLName("NJ0") + " NJ0 "
							cQry +=    " WHERE NJ0.NJ0_FILIAL    = '" + XFilial("NJ0") + "' "
							cQry +=    "   AND NJ0.NJ0_CGC       = '" + DeliveryEn + "'"
							cQry +=    "   AND NJ0.D_E_L_E_T_    = ' ' "
							cQry := ChangeQuery( cQry ) 
							dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
							(cAliasQry)->( dbGoTop() )      
							If (cAliasQry)->( !Eof() )        
								DeliveryEn := (cAliasQry)->NJ0_CODENT
								DeliverySt := (cAliasQry)->NJ0_LOJENT
								//conout("Conout AAA - 2.1 - "+DeliveryEn)
								//conout("Conout AAA - 2.1 - "+DeliverySt)
							Else
								//conout("Conout AAA - 3.1 - ")
								If !Empty(DeliveryEn)
									//conout("Conout AAA - 3.2 - ")
									lRet := .f.
									cXMLRet := STR0006 + DeliveryEn // "Não foi encontrada Entidade com o CNPJ/CPF informado: "
								EndIf
								DeliveryEn := ""
								DeliverySt := ""
							EndIf
							(cAliasQry)->(dbCloseArea())

				      		SpecificForm   			:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/SpecificForm')
							If Empty(SpecificForm)
								SpecificForm := '1'
							EndIf
				      		InvoiceSeries   		:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/InvoiceSeries')
				      		InvoiceNumber   		:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/InvoiceNumber')
				      		InvoiceIssue   			:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/InvoiceIssue')
				      		InvoiceType   			:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/InvoiceType')
				      		NFeKey   				:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/NFeKey')
				      		FiscalQuantity			:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/FiscalQuantity')
				      		FiscalQuantity := IIF(Empty(FiscalQuantity),'0',FiscalQuantity)
				      		UnitaryValue   			:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/UnitaryValue')
				      		UnitaryValue := IIF(Empty(UnitaryValue),'0',UnitaryValue)
				      		TotalValue   			:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/TotalValue')
				      		TotalValue := IIF(Empty(TotalValue),'0',TotalValue)
				      		TIOCode   				:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/TIOCode')
							TIOCode := OGIDEPAR('NJJ','NJJ_TES',TIOCode,'SF4')
							If !Empty(cXmlRet)
								lRet := .f.
							EndIf
				      		FreightValue   			:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/FreightValue')
				      		FreightValue := IIF(Empty(FreightValue),'0',FreightValue)
				      		FreightType   			:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/FreightType')
				      		InsuranceValue   		:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/InsuranceValue')
				      		InsuranceValue := IIF(Empty(InsuranceValue),'0',InsuranceValue)
				      		ExpenseValue   			:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/ExpenseValue')
				      		ExpenseValue := IIF(Empty(ExpenseValue),'0',ExpenseValue)
				      		ProdInvSeries	        :=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/ProducerInvoiceSeries')
				      		ProdInvNumber	        :=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/ProducerInvoiceNumber')
				      		InvoiceMessage 			:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/InvoiceMessage')
				      		Note   					:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/Note')
				      		CropCode   				:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/CropCode')
							CropCode := OGIDEPAR('NJJ','NJJ_CODSAF',CropCode,'NJU')
							If !Empty(cXmlRet)
								lRet := .f.
							EndIf
							ItemCode   				:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/ItemCode')
							ItemCode := OGIDEPAR('NJJ','NJJ_CODPRO',ItemCode,'SB1')
							If !Empty(cXmlRet)
								lRet := .f.
							EndIf
							Location   				:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/Location')
							Location := OGIDEPAR('NJJ','NJJ_LOCAL',Location,'NNR')
							If !Empty(cXmlRet)
								lRet := .f.
							EndIf
							Table   				:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/Table')
							Table := OGIDEPAR('NJJ','NJJ_TABELA',Table,'NNI')
							If !Empty(cXmlRet)
								lRet := .f.
							EndIf
				      		WeightDat1   			:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/WeightDate1')
							WeightDat1              := StrTran(SubStr(WeightDat1,1,10),'-','') 
				      		WeightTim1   			:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/WeightTime1')
				      		Weight1   				:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/Weight1')
				      		WeightMdl1   			:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/WeightMoel1')
				      		WeightDat2   			:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/WeightDate2')
				      		WeightDat2              := StrTran(SubStr(WeightDat2,1,10),'-','')
				      		WeightTim2   			:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/WeightTime2')
				      		Weight2   				:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/Weight2')
				      		WeightMdl2   			:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/WeightModel2')
				      		SubtotalWeight          :=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/SubtotalWeight')
				      		If !Empty(Weight1) .AND. !Empty(Weight2)
					      		If Weight1 > Weight2
					      			SubtotalWeight := AllTrim(Str(Abs( Val(Weight1) - Val(Weight2) ))) 	
					      		Else
					      			SubtotalWeight := AllTrim(Str(Abs( Val(Weight2) - Val(Weight1) )))
					      		EndIf
				      		EndIf
				      		RelatedBranch   		:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/RelatedBranch')
				      		RelatedPackingList   	:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/RelatedPackingList')
				      		PackingListDate			:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/PackingListDate')
				      		OriginalPackingList   	:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/OriginalPackingList')
							TransferServices 	    :=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/TransferServices')
				      		ContractCode   			:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/ContractCode')
				      		AuthorizationNumber   	:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/AuthorizationNumber')
				      		TransactionDocument		:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/TransactionDocument')
				      		ReportIdentification	:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/ReportIdentification')
				      		CollectionOrder   		:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/CollectionOrder')
				      		ReleaseQuality   		:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/ReleaseQuality')
							If ExistSX3("NJJ_CARTA")
								LetterLevelCode		:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/LetterLevelCode')
							EndIf
							If ExistSX3("NJJ_CODCTG")
								GrainTranspCode		:=oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/GrainTranspCode')
							EndIf
							
							aCpoMaster := {}
							//conout("conout NOVO 8 - "+cCode)
							//If cEvent <> MODEL_OPERATION_INSERT
								aAdd( aCpoMaster, { 'NJJ_CODROM', cCode 			 } )
							//conout("conout NOVO 8.1 - "+cCode)

							aAdd( aCpoMaster, { 'NJJ_TIPO'  , cType 			 } )
							aAdd( aCpoMaster, { 'NJJ_PLACA' , cPlate 			 } )
							aAdd( aCpoMaster, { 'NJJ_CODTRA', cCarrierFederalID  } )
							aAdd( aCpoMaster, { 'NJJ_CODMOT', DriverFederalID 	 } )
							aAdd( aCpoMaster, { 'NJJ_CODENT', EntityFederalID 	 } )
							aAdd( aCpoMaster, { 'NJJ_LOJENT', EntityStore 		 } )
							aAdd( aCpoMaster, { 'NJJ_ENTENT', DeliveryEn     	 } )
							aAdd( aCpoMaster, { 'NJJ_ENTLOJ', DeliverySt         } )
							aAdd( aCpoMaster, { 'NJJ_TPFORM', SpecificForm 		 } )
							aAdd( aCpoMaster, { 'NJJ_DOCSER', InvoiceSeries 	 } )
							aAdd( aCpoMaster, { 'NJJ_DOCNUM', InvoiceNumber 	 } )
							aAdd( aCpoMaster, { 'NJJ_DOCEMI', InvoiceIssue 	 	 } )
							aAdd( aCpoMaster, { 'NJJ_DOCESP', InvoiceType 		 } )
							aAdd( aCpoMaster, { 'NJJ_CHVNFE', NFeKey 			 } )
							aAdd( aCpoMaster, { 'NJJ_QTDFIS', FiscalQuantity 	 } )
							aAdd( aCpoMaster, { 'NJJ_VLRUNI', UnitaryValue 	 	 } )
							aAdd( aCpoMaster, { 'NJJ_VLRTOT', TotalValue 		 } )
							aAdd( aCpoMaster, { 'NJJ_TES' 	, TIOCode 		 	 } )
							aAdd( aCpoMaster, { 'NJJ_FRETE' , FreightValue 		 } )
							aAdd( aCpoMaster, { 'NJJ_SEGURO', InsuranceValue 	 } )
							aAdd( aCpoMaster, { 'NJJ_DESPES', ExpenseValue 		 } )
							aAdd( aCpoMaster, { 'NJJ_NFPSER', ProdInvSeries	 } )
							aAdd( aCpoMaster, { 'NJJ_NFPNUM', ProdInvNumber	 } )
							aAdd( aCpoMaster, { 'NJJ_MSGNFS', InvoiceMessage 		 } )
							aAdd( aCpoMaster, { 'NJJ_OBS'   , Note 				 } )
							aAdd( aCpoMaster, { 'NJJ_TPFRET', FreightType 		 } )
							aAdd( aCpoMaster, { 'NJJ_CODSAF', CropCode 		  	 } )
							aAdd( aCpoMaster, { 'NJJ_CODPRO', ItemCode 		 	 } )
							aAdd( aCpoMaster, { 'NJJ_LOCAL' , Location 		 	 } )
							If !Empty(Table)
								aAdd( aCpoMaster, { 'NJJ_TABELA', Table 		 } )
							EndIf
							aAdd( aCpoMaster, { 'NJJ_TKTCLA', Ticket 		 	 } )
							aAdd( aCpoMaster, { 'NJJ_DATPS1', WeightDat1 		 } )
							aAdd( aCpoMaster, { 'NJJ_HORPS1', WeightTim1 		 } )
							aAdd( aCpoMaster, { 'NJJ_PESO1' , Weight1 		 	 } )
							aAdd( aCpoMaster, { 'NJJ_MODPS1', WeightMdl1 		 } )
							aAdd( aCpoMaster, { 'NJJ_DATPS2', WeightDat2 		 } )
							aAdd( aCpoMaster, { 'NJJ_HORPS2', WeightTim2 		 } )
							aAdd( aCpoMaster, { 'NJJ_PESO2' , Weight2 		 	 } )
							aAdd( aCpoMaster, { 'NJJ_MODPS2', WeightMdl2 		 } )
							aAdd( aCpoMaster, { 'NJJ_PSSUBT', SubtotalWeight 	 } )
							aAdd( aCpoMaster, { 'NJJ_FILREL', RelatedBranch 	 } )
							aAdd( aCpoMaster, { 'NJJ_ROMREL', RelatedPackingList } )
							aAdd( aCpoMaster, { 'NJJ_DATA' 	, PackingListDate 	 } )
							aAdd( aCpoMaster, { 'NJJ_ROMORI', OriginalPackingList} )
							aAdd( aCpoMaster, { 'NJJ_TRSERV', IIF(!Empty(TransferServices),TransferServices,"0") 	 } )
							aAdd( aCpoMaster, { 'NJJ_CODCTR', ContractCode 		 } )
							aAdd( aCpoMaster, { 'NJJ_CODAUT', AuthorizationNumber} )
							aAdd( aCpoMaster, { 'NJJ_DOCEST', TransactionDocument} )
							aAdd( aCpoMaster, { 'NJJ_QPAREC', ReportIdentification	 } )
							aAdd( aCpoMaster, { 'NJJ_ORDCLT', CollectionOrder 		 } )
							aAdd( aCpoMaster, { 'NJJ_LIBQLD', ReleaseQuality 		 } )
							If ExistSX3("NJJ_CARTA")
								aAdd( aCpoMaster, { 'NJJ_CARTA' , LetterLevelCode 	 } )
							EndIf
							If ExistSX3("NJJ_CODCTG")
								aAdd( aCpoMaster, { 'NJJ_CODCTG', GrainTranspCode 	 } )
							EndIf
							
							If Val(Weight1) > 0
								cStsPsg := '1'
								If Val(Weight2) > 0 
									cStsPsg := '2'
									cStatus := '1'
								EndIf
							EndIf
							
							If cStsPsg <> '0'
								aAdd( aCpoMaster, { 'NJJ_STSPES', cStsPsg } )
							EndIF
							If cStatus <> '0'
								aAdd( aCpoMaster, { 'NJJ_STATUS', cStatus } )
							EndIF 
							
							aCpoDetNJK := {}
							nIAux := 0
							If cEvent == MODEL_OPERATION_UPDATE
								dbSelectArea("NJK")
								dbSetOrder(1)
								If dbSeek(xFilial("NJK")+cCode)
									While NJK->(!Eof()) .AND. NJK->NJK_FILIAL == xFilial("NJK") .AND. AllTrim(NJK->NJK_CODROM) == AllTrim(cCode)  
										If NJK->NJK_TPCLAS == "1"
											aAux := {}
										    aAdd( aAux, { 'NJK_CODDES',NJK->NJK_CODDES } )
										    aAdd( aAux, { 'NJK_ITEM'  ,NJK->NJK_ITEM } )
											aAdd( aAux, { 'NJK_OBRGT' ,NJK->NJK_OBRGT } )									
											aAdd( aAux, { 'NJK_TPCLAS',NJK->NJK_TPCLAS } )
					                        aAdd( aAux, { 'NJK_PERDES',AllTrim(Str(NJK->NJK_PERDES)) } )
					                        aAdd( aCpoDetNJK, aAux )
					                        nIAux++
					                    EndIf
	
										NJK->(dbSkip())
									End
								
								EndIf
							EndIf

			                //Quantidade de filhos da ListOfClassification.
			                nQtdeNJK := oXml:XPAthChildCount('/TOTVSMessage/BusinessMessage/BusinessContent/ListOfClassification')
			                //--------------------------------------------                                        
			                aListNJK := oXml:XPathGetChildArray('/TOTVSMessage/BusinessMessage/BusinessContent/ListOfClassification')
							For nI := 1 to nQtdeNJK  

								aFilho := oXml:XPathGetChildArray(aListNJK[nI,2])  //Gera array com os dados da NJK

								aAux := {}
								
								nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'DiscountCode' } )
								//if npos >0 
								//conout("conout ADD ARRAY NJK - nI 1: "+aFilho[nPos,3])
								//Endif
			                    If nPos > 0 .And. !Empty(aFilho[nPos,3] )
			                    //conout("conout ADD ARRAY NJK - nI 2: "+Str(nI))
			                    	aFilho[nPos,3] := OGIDEPAR('NJK','NJK_CODDES',aFilho[nPos,3],'NNH')
									If !Empty(cXmlRet)
										lRet := .f.
									EndIf
								    aAdd( aAux, { 'NJK_CODDES', aFilho[nPos,3] } )
								    
								    aAdd( aAux, { 'NJK_ITEM'  ,StrZero(nI+nIAux,3) } )
									aAdd( aAux, { 'NJK_OBRGT' ,'2'} )									
									aAdd( aAux, { 'NJK_TPCLAS',IIF(cEvent == MODEL_OPERATION_INSERT,'1','2')} )
									
									nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'ClassificationResult' } ) 
				                    If nPos > 0
				                        aAdd( aAux, { 'NJK_PERDES', aFilho[nPos,3] } )
				                    EndIf
				                    
				                     aAdd( aCpoDetNJK, aAux )
				                     
				                EndIf
			                   
							Next

							aCpoDetNJM := {}

							nIAux := 0
							If cEvent == MODEL_OPERATION_UPDATE
								dbSelectArea("NJM")
								dbSetOrder(1)
								If dbSeek(xFilial("NJM")+cCode)
									While NJM->(!Eof()) .AND. NJM->NJM_FILIAL == xFilial("NJM") .AND. AllTrim(NJM->NJM_CODROM) == AllTrim(cCode)  

										aAux := {}

										aAdd( aAux, { 'NJM_CODROM', NJM->NJM_CODROM } )
										aAdd( aAux, { 'NJM_ITEROM', NJM->NJM_ITEROM } )
				                        aAdd( aAux, { 'NJM_CODENT', NJM->NJM_CODENT } )
				                        aAdd( aAux, { 'NJM_LOJENT', NJM->NJM_LOJENT } )
				                        aAdd( aAux, { 'NJM_CODSAF', NJM->NJM_CODSAF } )
				                        aAdd( aAux, { 'NJM_TALHAO', NJM->NJM_TALHAO } )
				                        aAdd( aAux, { 'NJM_CODPRO', NJM->NJM_CODPRO } )
				                        aAdd( aAux, { 'NJM_LOCAL' , NJM->NJM_LOCAL } )
				                        aAdd( aAux, { 'NJM_CODCTR', NJM->NJM_CODCTR } )
				                        aAdd( aAux, { 'NJM_OPEFIS', NJM->NJM_OPEFIS } )
				                        aAdd( aAux, { 'NJM_TES'   , NJM->NJM_TES } )
				                        aAdd( aAux, { 'NJM_PERDIV', AllTrim(Str(NJM->NJM_PERDIV)) } )
				                        aAdd( aAux, { 'NJM_QTDFCO', AllTrim(Str(NJM->NJM_QTDFCO)) } )
				                        aAdd( aAux, { 'NJM_LOTCTL', NJM->NJM_LOTCTL } )
				                        aAdd( aAux, { 'NJM_TPFORM', NJM->NJM_TPFORM } )
				                        aAdd( aAux, { 'NJM_DOCSER', NJM->NJM_DOCSER } )
				                        aAdd( aAux, { 'NJM_DOCNUM', NJM->NJM_DOCNUM } )
				                        aAdd( aAux, { 'NJM_DOCITE', NJM->NJM_DOCITE } )
				                        aAdd( aAux, { 'NJM_DOCEMI', DTOS(NJM->NJM_DOCEMI) } )
				                        aAdd( aAux, { 'NJM_DOCESP', NJM->NJM_DOCESP } )
				                        aAdd( aAux, { 'NJM_CHVNFE', NJM->NJM_CHVNFE } )
				                        aAdd( aAux, { 'NJM_MSGNFS', NJM->NJM_MSGNFS } )
				                        //conout("Conout já gravado NJM->NJM_QTDFIS: "+AllTrim(Str(NJM->NJM_QTDFIS)))
				                        aAdd( aAux, { 'NJM_QTDFIS', AllTrim(Str(NJM->NJM_QTDFIS)) } )
				                        aAdd( aAux, { 'NJM_VLRUNI', AllTrim(Str(NJM->NJM_VLRUNI)) } )
				                        aAdd( aAux, { 'NJM_VLRTOT', AllTrim(Str(NJM->NJM_VLRTOT)) } )
				                        aAdd( aAux, { 'NJM_FRETE' , AllTrim(Str(NJM->NJM_FRETE)) } )
				                        aAdd( aAux, { 'NJM_SEGURO', AllTrim(Str(NJM->NJM_SEGURO)) } )
				                        aAdd( aAux, { 'NJM_DESPES', AllTrim(Str(NJM->NJM_DESPES)) } )
				                        aAdd( aAux, { 'NJM_NFPSER', NJM->NJM_NFPSER } )
				                        aAdd( aAux, { 'NJM_NFPNUM', NJM->NJM_NFPNUM } )
				                        aAdd( aAux, { 'NJM_CONDPG', NJM->NJM_CONDPG } )
				                        aAdd( aAux, { 'NJM_TRSERV', NJM->NJM_TRSERV } )
				                        aAdd( aAux, { 'NJM_CODAUT', NJM->NJM_CODAUT } )

				                        aAdd( aCpoDetNJM, aAux )
				                        nIAux++
	
										NJM->(dbSkip())
									End
								
								EndIf
							EndIf

			                //Quantidade de filhos da ListOfTaxData.
			                nQtdeNJM := oXml:XPAthChildCount('/TOTVSMessage/BusinessMessage/BusinessContent/ListOfTaxData')
			                //--------------------------------------------                                        
			                aListNJM := oXml:XPathGetChildArray('/TOTVSMessage/BusinessMessage/BusinessContent/ListOfTaxData')
							For nI := 1 to nQtdeNJM  

								aFilho := oXml:XPathGetChildArray(aListNJM[nI,2])  //Gera array com os dados da NJM							

								aAux := {}
								//conout("conout NOVO 9 - "+cCode)
								//If cEvent <> MODEL_OPERATION_INSERT
									aAdd( aAux, { 'NJM_CODROM', cCode } )
								//conout("conout NOVO 9.1 - "+cCode)
								//EndIf
								
								aAdd( aAux, { 'NJM_ITEROM', StrZero(nI+nIAux,2) } )
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'EntityFederalID' } ) 
			                    If nPos > 0
			                    	cAliasQry := GetNextAlias()
									cQry :=    " SELECT NJ0.NJ0_CODENT, NJ0.NJ0_LOJENT "
									cQry +=    " FROM " + RetSQLName("NJ0") + " NJ0 "
									cQry +=    " WHERE NJ0.NJ0_FILIAL    = '" + XFilial("NJ0") + "' "
									cQry +=    "   AND NJ0.NJ0_CGC       = '" + aFilho[nPos,3] + "'"
									cQry +=    "   AND NJ0.D_E_L_E_T_    = ' ' "
									cQry := ChangeQuery( cQry ) 
									dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
									(cAliasQry)->( dbGoTop() )      
									If (cAliasQry)->( !Eof() )        
										EntityFederalID := (cAliasQry)->NJ0_CODENT
										EntityStore     := (cAliasQry)->NJ0_LOJENT
									Else
										If !Empty(EntityFederalID)
											lRet := .f.
											cXMLRet := STR0006 + aFilho[nPos,3] //"Não foi encontrada Entidade com o CNPJ/CPF informado: "  
										EndIF
										EntityFederalID := ""
										EntityStore     := ""
									EndIf
									(cAliasQry)->(dbCloseArea())
			                        aAdd( aAux, { 'NJM_CODENT', EntityFederalID } )
			                        aAdd( aAux, { 'NJM_LOJENT', EntityStore } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'CropCode' } ) 
			                    If nPos > 0
									aFilho[nPos,3] := OGIDEPAR('NJM','NJM_CODSAF',aFilho[nPos,3],'NJU')
									If !Empty(cXmlRet)
										lRet := .f.
									EndIf
			                        aAdd( aAux, { 'NJM_CODSAF', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'CultLand' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_TALHAO', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'ItemCode' } )
			                    If nPos > 0
									aFilho[nPos,3] := OGIDEPAR('NJM','NJM_CODPRO',aFilho[nPos,3],'SB1')
									If !Empty(cXmlRet)
										lRet := .f.
									EndIf
			                        aAdd( aAux, { 'NJM_CODPRO', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'Location' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_LOCAL', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'ContractCode' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_CODCTR', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'FiscalOperationCode' } ) 
			                    If nPos > 0
									aFilho[nPos,3] := OGIDEPAR('NJM','NJM_OPEFIS',aFilho[nPos,3],'SX5')
									If !Empty(cXmlRet)
										lRet := .f.
									EndIf			                    
			                        aAdd( aAux, { 'NJM_OPEFIS', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'TIOCode' } ) 
			                    If nPos > 0
									aFilho[nPos,3] := OGIDEPAR('NJM','NJM_TES',aFilho[nPos,3],'SF4')
									If !Empty(cXmlRet)
										lRet := .f.
									EndIf
			                        aAdd( aAux, { 'NJM_TES', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'DivisionPercentage' } )
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_PERDIV', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'PhysicalQuantity' } )
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_QTDFCO', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'Lot' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_LOTCTL', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'SpecificForm' } )
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_TPFORM', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'InvoiceSeries' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_DOCSER', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'InvoiceNumber' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_DOCNUM', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'InvoiceItem' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_DOCITE', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'InvoiceIssue' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_DOCEMI', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'InvoiceType' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_DOCESP', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'NFeKey' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_CHVNFE', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'InvoiceMessage' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_MSGNFS', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'FiscalQuantity' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_QTDFIS', aFilho[nPos,3] } )
			                    EndIf

			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'UnitaryValue' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_VLRUNI', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'TotalValue' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_VLRTOT', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'FreightValue' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_FRETE', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'InsuranceValue' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_SEGURO', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'ExpenseValue' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_DESPES', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'ProducerInvoiceSeries' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_NFPSER', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'ProducerInvoiceNumber' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_NFPNUM', aFilho[nPos,3] } )
			                    EndIf
			                    
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'PaymentTerm' } ) 
			                    If nPos > 0
									aFilho[nPos,3] := OGIDEPAR('NJM','NJM_CONDPG',aFilho[nPos,3],'SE4')
									If !Empty(cXmlRet)
										lRet := .f.
									EndIf
			                        aAdd( aAux, { 'NJM_CONDPG', aFilho[nPos,3] } )
			                    EndIf
			                    
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'Transaction' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_TRSERV', aFilho[nPos,3] } )
			                    EndIf
			                    nPos := aScan(aFilho,{|x| AllTrim( x[1] )== 'AuthorizationNumber' } ) 
			                    If nPos > 0
			                        aAdd( aAux, { 'NJM_CODAUT', aFilho[nPos,3] } )
			                    EndIf
			                    //conout("conout OGI250 AAA "+AllTrim(Str(Len(aAux))))
			                    If Len(aAux) > 3
			                    	aAdd( aCpoDetNJM, aAux )
			                    //conout("conout OGI250 BBB ")
			                    EndIf
							Next

							oModel := FWLoadModel( 'OGA250' )
							// Temos que definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
							oModel:SetOperation( cEvent )
							// Antes de atribuirmos os valores dos campos temos que ativar o modelo
							oModel:Activate()
							// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho
							oAux := oModel:GetModel( 'NJJUNICO' )   // Modelo da NJJ Cab. Romaneio = NJJUNICO, dos Itens == NJMUnico
							// Obtemos a estrutura de dados do cabeçalho
							If cEvent <> MODEL_OPERATION_DELETE
								oStruct := oAux:GetStruct()
								aAux := oStruct:GetFields()
								If lRet
									For nI := 1 To Len( aCpoMaster )
										// Verifica se os campos passados existem na estrutura do cabeçalho
										If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoMaster[nI][1] ) } ) ) > 0
											// È feita a atribuição do dado aos campo do Model do cabeçalho
											If oAux:oFormModelStruct:aFields[nPos][4] == 'N'
												aCpoMaster[nI][2] := Val(aCpoMaster[nI][2])
											ElseIf oAux:oFormModelStruct:aFields[nPos][4] == 'D'
												aCpoMaster[nI][2] := STOD(aCpoMaster[nI][2])
											EndIf
											oModel:GetModel('NJJUNICO'):GetStruct():SetProperty(aCpoMaster[nI][1], MODEL_FIELD_WHEN,{||.T.})
											If !Empty(aCpoMaster[nI][2])
												If !( lAux := oModel:SetValue( 'NJJUNICO', aCpoMaster[nI][1],aCpoMaster[nI][2] ) )
													aErro:=oModel:GetErrorMessage()
													// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
													// o método SetValue retorna .F.
													lRet := .F.
													cXMLRet := AllToChar(aErro[6]) + CRLF +;
															   AllToChar(aErro[7]) + CRLF + CRLF +;
															   "Campo: " + AllToChar(aErro[2]) + CRLF +;
															   "Valor: " + AllToChar(aErro[9])
													//cXMLRet := STR0007 +  aCpoMaster[nI][1] // "Conteúdo inválido do campo: "
													Exit
												EndIf
											EndIf
										EndIf
									Next
								EndIf
								
								If lRet
									// Instanciamos apenas a parte do modelo referente aos dados do item
									oAux := oModel:GetModel( 'NJKUNICO' )
									oAux:SetNoDelete( .f. )
									oAux:SetNoInsert( .f. )
									// Obtemos a estrutura de dados do item
									oStruct := oAux:GetStruct()
									aAux := oStruct:GetFields()
									nItErro := 0
									
									lDelNJK := .F.
									
									//conout( "conout oAux:Length() - " + Str(oAux:Length() ) )
									For nx := 1 to oAux:Length()
										//conout("entrou 1.1")
									 	oAux:GoLine( nx )
										oAux:DeleteLine()
										lDelNJK := .T.
									Next
									FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',STR0017 , 0, 0, {})
									
									For nI := 1 To Len( aCpoDetNJK )

										// Incluímos uma linha nova
										// ATENÇÃO: O itens são criados em uma estrutura de grid (FORMGRID), portanto já é criada uma primeira linha
										//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
										
										If lDelNJK
											FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',STR0018 , 0, 0, {})
										EndIf
										
										If nI > 1 .Or. lDelNJK
											
											//conout("conout - linha posicionada" + Str(oAux:GetLine()))
										
											If oAux:AddLine()
												FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',STR0019 , 0, 0, {})
											Else
												FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',STR0020 , 0, 0, {})
											EndIf
											
											FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',STR0021 , 0, 0, {})
										EndIf
										
										For nJ := 1 To Len( aCpoDetNJK[nI] )
											// Verifica se os campos passados existem na estrutura de item
											If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoDetNJK[nI][nJ][1] ) } ) ) > 0
												If oAux:oFormModelStruct:aFields[nPos][4] == 'N'
													aCpoDetNJK[nI][nJ][2] := Val(aCpoDetNJK[nI][nJ][2])
												ElseIf oAux:oFormModelStruct:aFields[nPos][4] == 'D'
													aCpoDetNJK[nI][nJ][2] := STOD(aCpoDetNJK[nI][nJ][2])
												EndIf
												oModel:GetModel('NJKUNICO'):GetStruct():SetProperty(aCpoDetNJK[nI][nJ][1], MODEL_FIELD_WHEN,{||.T.})
												If !Empty(aCpoDetNJK[nI][nJ][2])
													If !( lAux := oModel:SetValue( 'NJKUNICO', aCpoDetNJK[nI][nJ][1], aCpoDetNJK[nI][nJ][2] ) )
														// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
														// o método SetValue retorna .F.
														lRet := .F.
														//cXMLRet := STR0009 + aCpoDetNJK[nI][nJ][1]  //"Conteúdo inválido do campo: "
														cXMLRet := AllToChar(aErro[6]) + CRLF +;
																   AllToChar(aErro[7]) + CRLF + CRLF +;
																   "Campo: " + AllToChar(aErro[2]) + CRLF +;
																   "Valor: " + AllToChar(aErro[9])
														nItErro := nI
														Exit
													EndIf
												EndIf
											EndIf
										Next
										If !lRet
											Exit
										EndIf
									Next
									/*If nI < oAux:Length()
										For nx := nI+1 to oAux:Length() 
											oAux:GoLine( nx )
											oAux:DeleteLine()
										Next
									EndIf*/
								EndIf
								//conout("conout cTypecTypecType 1")
								If lRet //.AND. !(cType $ "2|4|6|8") //Só entra para Tipo = Venda
								//conout("conout cTypecTypecType 2")
									// Instanciamos apenas a parte do modelo referente aos dados do item
									oAux := oModel:GetModel( 'NJMUNICO' )
									// Obtemos a estrutura de dados do item
									oStruct := oAux:GetStruct()
									aAux := oStruct:GetFields()
									lDelNJM := .F.
									 
									For nx := 1 to oAux:Length()
									 	oAux:GoLine( nx )
										oAux:DeleteLine()
										lDelNJM := .T.
									Next
									//conout("conout NJM inicio 0")
									nItErro := 0
									For nI := 1 To  Len( aCpoDetNJM )
										// Incluímos uma linha nova
										// ATENÇÃO: O itens são criados em uma estrutura de grid (FORMGRID), portanto já é criada uma primeira linha
										//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
										//conout("conout NJM inicio 1")
										If nI > 1 .Or. lDelNJM
											//conout("conout NJM inicio 2 - "+AllTrim(Str(Len( aCpoDetNJM[nI] ))))
											oAux:AddLine()
										EndIf
										For nJ := 1 To Len( aCpoDetNJM[nI] )
											// Verifica se os campos passados existem na estrutura de item
											If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoDetNJM[nI][nJ][1] ) } ) ) > 0
												cConteudo := AllTrim(aCpoDetNJM[nI][nJ][2])
												If oAux:oFormModelStruct:aFields[nPos][4] == 'N'
													aCpoDetNJM[nI][nJ][2] := Val(aCpoDetNJM[nI][nJ][2])
												ElseIf oAux:oFormModelStruct:aFields[nPos][4] == 'D'
													aCpoDetNJM[nI][nJ][2] := STOD(aCpoDetNJM[nI][nJ][2])
												EndIf
												//conout("conout NJM VERIFICA SE é NJM_CODSAF")
												If aCpoDetNJM[nI][nJ][1] == "NJM_CODSAF"
												//conout("conout NJM é NJM_CODSAF"+M->NJJ_CODSAF)
													aCpoDetNJM[nI][nJ][2] := M->NJJ_CODSAF
												EndIf
												oModel:GetModel('NJMUNICO'):GetStruct():SetProperty(aCpoDetNJM[nI][nJ][1], MODEL_FIELD_WHEN,{||.T.})
												If cEvent == MODEL_OPERATION_UPDATE
													lAux := oModel:LoadValue( 'NJMUNICO', aCpoDetNJM[nI][nJ][1], aCpoDetNJM[nI][nJ][2] )
													//conout("conout NJM update")
												Else
													lAux := oModel:SetValue( 'NJMUNICO', aCpoDetNJM[nI][nJ][1], aCpoDetNJM[nI][nJ][2] )
													//conout("conout NJM insert")
												EndIf

												If !( lAux )
													//conout("conout campo __: "+aCpoDetNJM[nI][nJ][1]+" valor: "+AllTrim(Str(aCpoDetNJM[nI][nJ][2])))
													aErro:=oModel:GetErrorMessage()
													// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
													// o método SetValue retorna .F.
													lRet := .F.
													//cXMLRet := STR0009 + aCpoDetNJM[nI][nJ][1]  //"Conteúdo inválido do campo: "
													cXMLRet := AllToChar(aErro[6]) + CRLF +;
															   AllToChar(aErro[7]) + CRLF + CRLF +;
															   "Campo: " + AllToChar(aErro[2]) + CRLF +;
															   "Valor: " + cConteudo 
													nItErro := nI
													Exit
												EndIf
											EndIf
										Next
										If !lRet
											Exit
										EndIf
									Next
								EndIf
							EndIf
							//conout("conout lRet 2 ")
							If lRet
								//conout("conout lRet 2 TRUE")
								// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
								// neste momento os dados não são gravados, são somente validados.
								//If ( lRet := oModel:VldData() )
								If lRet := oModel:VldData()
								//conout("conout lRet 3 TRUE")
								aErro:=oModel:GetErrorMessage()
								
									// Se o dados foram validados faz-se a gravação efetiva dos
									// dados (commit)
									oModel:CommitData()
									
									If cEvent == MODEL_OPERATION_INSERT
										//cInternalId := GF250MakeId(NJJ->NJJ_CODROM)
										//conout("conout cEvent 1.1 "+cInternalId)
										//cInternalId := GF250PutId( cProduct,  cCodeOrig , cInternalId)
										
										//conout("conout cEvent 1.1 "+cProduct)
										//conout("conout cEvent 1.1 "+cCodeOrig)
										//conout("conout cEvent 1.1 "+cInternalId)
									Else
										//conout("conout cEvent MODEL_OPERATION_???")
										If cEvent == MODEL_OPERATION_DELETE
											//cInternalId := GF250PutId( cProduct,  cCodeOrig , cInternalId, .T.)
											//conout("conout cEvent MODEL_OPERATION_DELETE")
											//conout("conout cEvent 1.2 "+cInternalId)
											//conout("conout cEvent 1.2 "+cProduct)
											//conout("conout cEvent 1.2 "+cCodeOrig)
											//conout("conout cEvent 1.2 "+cInternalId)
										EndIF
									EndIf
									
									aErro:=oModel:GetErrorMessage()
								Else
									aErro:=oModel:GetErrorMessage()
									If !Empty(aErro)
										cErro:= STR0010 //'A integração não foi bem sucedida.'
										cErro+= STR0011 +Alltrim(aErro[5])+'-'+AllTrim(aErro[6]) //'Foi retornado o seguinte erro: '
										If !Empty(Alltrim(aErro[7]))
											cErro+=STR0012+AllTrim(aErro[7]) //'Solução - '
										Endif
									Else
										cErro:=STR0010
										cErro+=STR0013 //'Verifique os dados enviados'
									Endif
									cXMLRet := cErro 
									aSize(aErro,0)
									aErro:=nil
									
								EndIf
							EndIf
							//conout("conout cEvent 2.1")
							oModel:Deactivate()
							oModel:Destroy()
						Endif
					Else
						lRet := .f.
						cXmlRet:=cErro
					Endif
					oXml:=nil
					//conout("conout cEvent 3.1")
			EndCase
	EndCase
	//conout("conout cEvent 4.1")


	//conout("conout cXmlRet "+cXmlRet)
	oModel:=nil
If lRet
	//conout("conout retornou true ")
	cXMLRet := '<ReturnContentType>'
	cXMLRet += '<InternalId>' + cCode + '</InternalId>'
	cXMLRet += '</ReturnContentType>'
	//conout("conout cXMLRet 2 - "+cXMLRet)
Else
	//conout("conout retornou FALSE ")
EndIf
	//DelClassIntF()
Return {lRet,cXmlRet,"MYMESSAGE"}

Function GF250MakeId(cId,cEmp,cFil)
	Local cREt
	
	Default cEmp:=cEmpAnt
	Default cFil:=xFilial('NJJ')
	cREt:=rTrim(cEmp)+'|'+rTrim(cFil)+'|'+cId

Return cREt


Function GF250PutId( cRefer,  cValExt, cValInt, lDelete)
	Default lDelete:=.F.
Return CFGA070MNT( cRefer, 'NJJ', 'NJJ_CODROM', cValExt, cValInt, lDelete)

//---------------------------------------------------------------------
/*/{Protheus.doc} OGIDEPAR

@author Marcos Wagner Jr.
@since 29/06/17
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function OGIDEPAR(cTabela, cCpoDePara, cCodDePara, cTabF3)
Local aOldArea := GetArea()
Local cCodOld := ''
Local lEncontrou := .f.
//conout("conout OGIDEPAR: TABELA "+cTabela + ' CONTEUDO:'+cCodDePara+" ---F3: "+cTabF3)
If !Empty(cCodDePara)
	If !Empty(cTabF3)
		//conout("conout OGIDEPAR")
		If cTabF3 == "SX5"
			cCodOld := cCodDePara
			cCodDePara := "DJ"+cCodDePara
		EndIf
	
		If ExistCpo(cTabF3, cCodDePara )
			lEncontrou := .t.
			//conout("conout OGIDEPAR ExistCPO 1")
		Else
			//conout("conout OGIDEPAR ExistCPO 2")
		EndIf
	
		If cTabF3 == "SX5"
			cCodDePara := cCodOld
		EndIf
	EndIf

	If !lEncontrou
		//conout("conout OGIDEPAR não lEncontrou")
		cCodDePara := AllTrim(CFGA070INT( cProduct, cTabela, cCpoDePara, cCodDePara ))
		If Empty(cCodDePara) .And. cCpoDePara <> "NJJ_CODROM"
			//conout("conout OGIDEPAR lEncontrou 2")
			cXmlRet := STR0014 + cCpoDePara //"Não foi encontrado Cadastro De/Para para o campo : " 
		EndIF
	EndIf

EndIf

RestArea(aOldArea)

Return cCodDePara

//---------------------------------------------------------------------
/*/{Protheus.doc} GetNextNJJ

@author Marcos Wagner Jr.
@since 27/11/17
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
Static Function GetNextNJJ(cRomaneio)

//conout("conout GetNextNJJ")
cRomaneio := GetSXENum('NJJ','NJJ_CODROM')
//conout("conout GetNextNJJ 2 - "+cRomaneio)

If NJJ->(DbSeek(xFilial('NJJ')+cRomaneio))
//conout("conout GetNextNJJ 3 - ")
	While NJJ->(DbSeek(xFilial('NJJ')+cRomaneio))//não posso gravar com o mesmo, gravo com outro.
		cRomaneio := GetSXENum('NJJ','NJJ_CODROM')

//conout("conout GetNextNJJ 4 - "+cRomaneio)

		If !NJJ->(DbSeek(xFilial('NJJ')+cRomaneio))
			//cInternalId:=GF250MakeId(cRomaneio)
//conout("conout GetNextNJJ 5.1 - "+cRomaneio)
			ConfirmSX8()
			Exit
		Else
//conout("conout GetNextNJJ 5.2 - "+cRomaneio)
			//ConfirmSX8()
		Endif
	EndDo
Else
	ConfirmSX8()
EndIf

//conout("conout GetNextNJJ FIM - "+cRomaneio)

Return cRomaneio
