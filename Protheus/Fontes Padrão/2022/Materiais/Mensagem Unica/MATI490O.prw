#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
//#INCLUDE 'TURXEAI.CH'
//#INCLUDE 'TURIDEF.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} MATI490O

Funcao de integracao com o adapter EAI para recebimento e envio de informações
Comissão de Vendas (SalesCharge) utilizando o conceito de mensagem unica JSON

@sample		MATI490O( oEAIObEt, nTypeTrans, cTypeMessage ) 

@param		oEAIObEt 
@param		nTypeTrans 
@param		cTypeMessage

@return		lRet 
@return		ofwEAIObj
@return		cMsgUnica

@author		Totvs Cascavel
@since		26/09/2018
@version	12
/*/
//------------------------------------------------------------------------------
Function MATI490O( oEAIObEt, nTypeTrans, cTypeMessage ) 

	Local lRet      := .T. 
	Local lDelete	:= .F.
	Local nOpcx    	:= 3
	Local nLisOfCm	:= 0
	Local nX		:= 0
	Local aErroAuto := {}
	Local aAuto		:= {}
	Local aCodVend	:= {}
	Local cEvento   := 'upsert'
	Local cMsgUnica := 'SalesCharge'
	Local cMarca    := 'PROTHEUS'
	Local cAlias    := 'SE3'
	Local cCampo    := 'E3_NUM'
	Local cCodeInt  := ''
	Local cIntID    := '' 
	Local cExtID    := '' 
	Local cLogErro	:= ''
	Local cVedInt	:= ''
	Local cTitInt	:= ''
	Local cValExt	:= ''
	Local cValInt	:= ''
	Local cProduct	:= ''
	Local ofwEAIObj	:= FWEAIobj():NEW()
	
	Default	oEAIObEt := Nil
	
	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile	:= .T.
	
	Do Case
		//--------------------------------------
		//envio mensagem
		//--------------------------------------
		Case nTypeTrans == TRANS_SEND
		
			If lDelete := !ALTERA .AND. !INCLUI
				cEvento := 'delete'
			EndIf
			
			cIntID 	:= cEmpAnt+"|"+FWxFilial("SE3")+"|"+SE3->E3_PREFIXO+"|"+SE3->E3_NUM+"|"+SE3->E3_PARCELA+"|"+SE3->E3_SEQ+"|"+SE3->E3_VEND
			cVedInt := IntVenExt(cEmpAnt,/*cFilAnt*/,SE3->E3_VEND)[2]
			cTitInt := IntTRcExt(, SE3->E3_FILIAL, SE3->E3_PREFIXO, SE3->E3_NUM, SE3->E3_PARCELA, SE3->E3_TIPO)[2]
		
			//Montagem da mensagem
			ofwEAIObj:Activate()
			ofwEAIObj:setEvent(cEvento)	
			
			ofwEAIObj:setprop("CompanyId", cEmpAnt)
			ofwEAIObj:setprop("BranchId", cFilAnt)
			ofwEAIObj:setprop("CompanyInternalId", cEmpAnt + '|' + cFilAnt)
			ofwEAIObj:setprop("InternalID", cIntID )
			ofwEAIObj:setprop("SellerInternalId", cVedInt )
			ofwEAIObj:setprop("AccountReceivableDocumentInternalId", cTitInt )
			ofwEAIObj:setprop("AccountReceivableDocumentPrefix", SE3->E3_PREFIXO )
			ofwEAIObj:setprop("AccountReceivableDocumentNumber", SE3->E3_NUM )
			ofwEAIObj:setprop("AccountReceivableDocumentParcel", SE3->E3_PARCELA )
			ofwEAIObj:setprop("AccountReceivableDocumentTypeCode", SE3->E3_TIPO )
			ofwEAIObj:setprop("CustomerVendorInternalId", IntCliExt(, , SE3->E3_CODCLI, SE3->E3_LOJA)[2] )
			ofwEAIObj:setprop("CustomerVendorCode", SE3->E3_CODCLI )
			ofwEAIObj:setprop("CustomerVendorStore", SE3->E3_LOJA )
			ofwEAIObj:setprop("IssueDate", SubStr(DToC(SE3->E3_EMISSAO), 7, 4) + '-' + SubStr(DToC(SE3->E3_EMISSAO), 4, 2) + '-' + SubStr(DToC(SE3->E3_EMISSAO), 1, 2) )
			ofwEAIObj:setprop("BaseValue", SE3->E3_BASE )
			ofwEAIObj:setprop("SalesChargePercentage", SE3->E3_PORC )
			ofwEAIObj:setprop("Value", SE3->E3_COMIS )
			ofwEAIObj:setprop("DueDate", SubStr(DToC(SE3->E3_VENCTO), 7, 4) + '-' + SubStr(DToC(SE3->E3_VENCTO), 4, 2) + '-' + SubStr(DToC(SE3->E3_VENCTO), 1, 2) )
			ofwEAIObj:setprop("CurrencyInternalId", SE3->E3_MOEDA )
			ofwEAIObj:setprop("Currency", SE3->E3_MOEDA )
		
		//--------------------------------------
		//recebimento mensagem
		//--------------------------------------	
		Case nTypeTrans == TRANS_RECEIVE .And. Type("oEAIObEt") != Nil
			Do Case
			
				//--------------------------------------
	  			//whois
	  			//--------------------------------------
				Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
				
					cWhois := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cWhois := "1.000"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Whois", cWhois)
				    
				
				//--------------------------------------
				//resposta da mensagem Unica TOTVS
				//--------------------------------------
				Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
					
					//Verifica tipo do evento Inclusao/Alteracao/Exclusao
					If Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == 'DELETE'
						lDelete := .T.					
					Endif	
		
					If oEAIObEt:getHeaderValue("ProductName") !=  nil
						cProduct := oEAIObEt:getHeaderValue("ProductName")
					Else
						lRet := .F.
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := "Erro no retorno. O Product é obrigatório!" //Ajustar Include
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
					Endif
					
					If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin") != nil
						cValInt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin")
					Else
						lRet := .F.
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := "Erro no retorno. O OriginalInternalId é obrigatório!" //Ajustar Include
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
					Endif
					
					If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination") != nil
						cValExt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination")
					Else
						lRet := .F.
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := "Erro no retorno. O DestinationInternalId é obrigatório" //Ajustar Include
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
					Endif
					
					If !Empty(cValInt) .And. !Empty(cValExt) .And. lRet
						CFGA070MNT(cProduct, cAlias, cCampo, cValExt, cValInt, lDelete)
					Endif
				
				
				//--------------------------------------
				//chegada de mensagem de negocios
				//--------------------------------------
				Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
					
					cEvent := Upper(AllTrim(oEAIObEt:getEvent()))
					
					If oEAIObEt:getHeaderValue("ProductName") !=  nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") )
						cProduct := oEAIObEt:getHeaderValue("ProductName")
					Else
						lRet := .F.
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := "ProductName é obrigatório!" //Ajustar Include
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)	
					EndIf
					
					//Codigo externo
					If oEAIObEt:getPropValue("InternalID") != nil .And. !Empty( oEAIObEt:getPropValue("InternalID") )
						cValExt := oEAIObEt:getPropValue("InternalID")
					Endif
					
	            	// Codigo Vendedor
					If oEAIObEt:getPropValue("SellerInternalId") != nil .And. !Empty( oEAIObEt:getPropValue("SellerInternalId") )  
						aCodVend 	:= StrTokArr(CFGA070Int(cProduct, "SA3", "A3_COD", oEAIObEt:getPropValue("SellerInternalId")),"|")
							
						If Len( aCodVend ) > 0
							If !Empty( aCodVend[Len(aCodVend)] )
								aAdd(aAuto, {"E3_VEND", aCodVend[Len(aCodVend)], Nil})
							Endif
						Endif
					EndIf
					
					//Numero titulo
					If oEAIObEt:getPropValue("AccountReceivableDocumentNumber") != nil .And. !Empty( oEAIObEt:getPropValue("AccountReceivableDocumentNumber") )
						aAdd(aAuto, {"E3_NUM", oEAIObEt:getPropValue("AccountReceivableDocumentNumber"), Nil})
					Endif
					
					//Prefixo
					If oEAIObEt:getPropValue("AccountReceivableDocumentPrefix") != nil .And. !Empty( oEAIObEt:getPropValue("AccountReceivableDocumentPrefix") )
						aAdd(aAuto, {"E3_PREFIXO", oEAIObEt:getPropValue("AccountReceivableDocumentPrefix"), Nil})
					Endif

					//Parcela
					If oEAIObEt:getPropValue("AccountReceivableDocumentParcel") != nil .And. !Empty( oEAIObEt:getPropValue("AccountReceivableDocumentParcel") )
						aAdd(aAuto, {"E3_PARCELA", oEAIObEt:getPropValue("AccountReceivableDocumentParcel"), Nil})
					Endif
					
					//Tipo
					If oEAIObEt:getPropValue("AccountReceivableDocumentTypeCode") != nil .And. !Empty( oEAIObEt:getPropValue("AccountReceivableDocumentTypeCode") )
						aAdd(aAuto, {"E3_TIPO", oEAIObEt:getPropValue("AccountReceivableDocumentTypeCode"), Nil})
					Endif
							
					//Emissao
					If oEAIObEt:getPropValue("IssueDate") != nil .And. !Empty( oEAIObEt:getPropValue("IssueDate") )
						cDatEmis := oEAIObEt:getPropValue("IssueDate")
						aAdd(aAuto, {"E3_EMISSAO", cTod(SubStr(cDatEmis, 9, 2) + "/" + SubStr(cDatEmis, 6, 2 ) + "/" + SubStr(cDatEmis, 1, 4 )), Nil})
					Endif	
					
					//Codigo cliente
					If oEAIObEt:getPropValue("CustomerVendorCode") != nil .And. !Empty( oEAIObEt:getPropValue("CustomerVendorCode") )
						aAdd(aAuto, {"E3_CODCLI", oEAIObEt:getPropValue("CustomerVendorCode"), Nil})
					Endif	
					
					//Loja cliente
					If oEAIObEt:getPropValue("CustomerVendorStore") != nil .And. !Empty( oEAIObEt:getPropValue("CustomerVendorStore") )
						aAdd(aAuto, {"E3_LOJA", oEAIObEt:getPropValue("CustomerVendorStore"), Nil})
					Endif		
					
					//Base
					If oEAIObEt:getPropValue("BaseValue") != nil .And. !Empty( oEAIObEt:getPropValue("BaseValue") )
						aAdd(aAuto, {"E3_BASE", oEAIObEt:getPropValue("BaseValue"), Nil})
					Endif	
					
					//Percentual
					If oEAIObEt:getPropValue("SalesChargePercentage") != nil .And. !Empty( oEAIObEt:getPropValue("SalesChargePercentage") )
						aAdd(aAuto, {"E3_PORC", oEAIObEt:getPropValue("SalesChargePercentage"), Nil})
					Endif	
					
					//Vencimento
					If oEAIObEt:getPropValue("DueDate") != nil .And. !Empty( oEAIObEt:getPropValue("DueDate") )
						cDatVenc := oEAIObEt:getPropValue("DueDate")
						aAdd(aAuto, {"E3_VENCTO", cTod(SubStr(cDatVenc, 9, 2) + "/" + SubStr(cDatVenc, 6, 2 ) + "/" + SubStr(cDatVenc, 1, 4 )), Nil})
					Endif		

					//Moeda
					If oEAIObEt:getPropValue("Currency") != nil .And. !Empty( oEAIObEt:getPropValue("Currency") )
						aAdd(aAuto, {"E3_MOEDA", oEAIObEt:getPropValue("Currency"), Nil})
					Endif
					
					//Valida se roda rotina automatica
					If lRet
					
						//Obtém o valor interno da tabela XXF (de/para)		
						cValInt := CFGA070Int(cProduct, cAlias, cCampo, cValExt)
						
						If !Empty( cValInt )
							//Verifica tipo de evento
							If cEvent == 'UPSERT' .Or. cEvent == 'REQUEST'
								nOpcx := 4 // Update	
							ElseIf cEvent == 'DELETE'
								nOpcx := 5 // Update
								lDelete := .T.
							Endif
						Endif
					
						// Executa comando para insert, update ou delete conforme evento
						MSExecAuto({|x,y| Mata490(x,y)},aAuto,nOpcx)
						
						// Se houve erros no processamento do MSExecAuto
						If lMsErroAuto
			         		aErroAuto := GetAutoGRLog()
			             	cLogErro := ""
				
							nContErro := Len(aErroAuto)
			               	For nX := 1 To nContErro
			                  	cLogErro += aErroAuto[nX] + Chr(10)
			               	Next nX
				               	
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
				         	ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
								 
				      		lRet := .F.
						Else
							cValInt := cEmpAnt+"|"+FWxFilial("SE3")+"|"+SE3->E3_PREFIXO+"|"+SE3->E3_NUM+"|"+SE3->E3_PARCELA+"|"+SE3->E3_SEQ+"|"+SE3->E3_VEND
						
							// Monta o JSON de retorno
							ofwEAIObj:Activate()
																							
							ofwEAIObj:setProp("ReturnContent")
														
							ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID",{},'InternalId',,.T.)
							ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Name",cMsgUnica,,.T.)
							ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Origin",cValExt,,.T.)
							ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Destination",cValInt,,.T.)				
											
							CFGA070Mnt(cProduct, cAlias, cCampo, cValExt, cValInt, lDelete)	
						EndIf
						
					Endif	
				
			EndCase
			
	EndCase
	
	aSize(aErroAuto,0 )
	aErroAuto := {}

	aSize(aAuto,0 )
	aAuto := {}	
	
	aSize(aCodVend,0 )
	aCodVend := {}

Return { lRet, ofwEAIObj, cMsgUnica }

//-------------------------------------------------------------------
/*/{Protheus.doc} IntInpInt
Recebe um InternalID e retorna o código do Vendedor.


@author 	Totvs Cascavel
@version	P12.1.17
@since		26/09/2018
@return	aResult Array contendo no primeiro parâmetro uma variável
			lógica indicando se o registro foi encontrado no de/para.
			No segundo parâmetro uma variável array com a empresa,
			filial ,InternalId
/*/
//-------------------------------------------------------------------
Static Function IntVenExt(cEmp,cFil,cInternalId)
	Local aResult  		:= {}
	
	Default cEmp		:= cEmpAnt
	Default cFil		:= xFilial("SA3") 
	Default cInternalID	:= ""

	aAdd(aResult, .T.)
	aAdd(aResult, cEmp + '|' + RTrim(cFil) + '|' + RTrim(cInternalId) )

Return(aResult)


