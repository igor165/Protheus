#Include 'PROTHEUS.CH'    
#Include 'FWADAPTEREAI.CH'
#Include 'MATI410.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATI410O   ºAutor  ³Totvs Cascavel     º Data ³  29/06/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de integracao com o adapter EAI para envio e   	  º±±
±±º          ³ recebimento do Pedido de Venda (SC5/SC6/AGG)  utilizando o º±±
±±º          ³ conceito de mensagem unica (Order).					      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATI410O                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MATI410O( oEAIObEt, nTypeTrans, cTypeMessage)
	Local cError   	      	:= ""
	Local cWarning 	      	:= ""
	Local lRet     		  	:= .T.
	Local cXmlRet  		  	:= ""
	Local aRet     		  	:= {}
	Local cAlias           	:= "SC5"
	Local cField           	:= "C5_NUM"
	Local cEvent           	:= "upsert"
	Local cValExt          	:= ""
	Local cValInt          	:= ""
	Local cMarca           	:= ""
	Local cNumPed          	:= ""
	Local cCliente         	:= ""
	Local cLoja            	:= ""
	Local cDatEmis         	:= ""
	Local cItemSC6         	:= ""
	Local cTES             	:= ""
	Local cAux             	:= ""
	Local aCab             	:= {}
	Local aItens           	:= {}
	Local aErroAuto        	:= {}
	Local aAux             	:= {}
	Local aCCusto          	:= {}
	Local aItemRat         	:= {}
	Local aLinha           	:= {}
	Local aDePara          	:= {}
	Local aItemAux         	:= {}
	Local aRateio          	:= {}
	Local aAreaSON         	:= {}
	Local aCodTransp        := {}
	Local nOpcx            	:= 0
	Local nI               	:= 0
	Local nJ               	:= 0
	Local nLin             	:= 0
	Local nPrcTtl          	:= 0
	Local nPercDesc        	:= 0
	Local nValDesc         	:= 0
	Local nK               	:= 0
	Local nL               	:= 0
	Local nM               	:= 0
	Local aAdtPC           	:= {}
	Local cCond            	:= ""
	Local cNameInternalId  	:= ""
	Local cCusVer          	:= RTrim(PmsMsgUVer('CUSTOMERVENDOR',            'MATA030' .OR. 'CRMA980')) //Versão do Cliente/Fornecedor
	Local cCosVer          	:= RTrim(PmsMsgUVer('COSTCENTER',                'CTBA030')) //Versão do Centro de Custo
	Local cUndVer          	:= RTrim(PmsMsgUVer('UNITOFMEASURE',             'QIEA030')) //Versão da Unidade de Medida
	Local cConVer          	:= RTrim(PmsMsgUVer('PAYMENTCONDITION',          'MATA360')) //Versão da Condição de Pagamento
	Local cMoeVer          	:= RTrim(PmsMsgUVer('CURRENCY',                  'CTBA140')) //Versão da Moeda
	Local cLocVer          	:= RTrim(PmsMsgUVer('WAREHOUSE',                 'AGRA045')) //Versão do Local de Estoque
	Local cPrdVer          	:= RTrim(PmsMsgUVer('ITEM',                      'MATA010')) //Versão do Produto
	Local cPrjVer          	:= RTrim(PmsMsgUVer('PROJECT',                   'PMSA200')) //Versão do Projeto
	Local cTrfVer          	:= RTrim(PmsMsgUVer('TASKPROJECT',               'PMSA203')) //Versão da Tarefa
	Local cTRcVer          	:= RTrim(PmsMsgUVer('ACCOUNTRECEIVABLEDOCUMENT', 'FINA040')) //Versão do Título a Receber
	Local cPdVVer          	:= RTrim(PmsMsgUVer('ORDER',                     'MATA410')) //Versão do Pedido de Venda
	Local aCodcfop		  	:= {}
	Local cTpOpera         	:= ""
	Local cCodProd		  	:= ""
	Local cSONCodExt       	:= ""
	Local aCodVend		  	:= {}
	Local aCodTab			:= {}
	Local lWorkCode			:= AF8->(ColumnPos("AF8_CNO"))>0
	Local aItemAPos        	:= {}
	Local aAposEsp         	:= {}
	Local n15Anos          	:= 0
	Local n20Anos          	:= 0
	Local n25Anos          	:= 0
	Local cLote			  	:= ""
	Local cSubLote		  	:= ""
	Local cSerie			:= ""
	Local cLocaliz		  	:= ""
	Local aReserva		  	:= ""
	Local aReserv		  	:= {} //Array com as Reservas que devem ser processadas junto com a Venda.
	Local cValExtRes       	:= ""
	Local cDocRes          	:= "" //Documento Responsável pela Reserva
	Local lIntegSC0		  	:= FWHasEAI("LOJA704", .T.,, .T.) //Flag integracao da ItemReserve
	Local lLock				:= .F.
	   
	//Instancia objeto JSON
	Local ofwEAIObj			:= FWEAIobj():NEW()
	Local cMsgUnica			:= "Order"
	Local nCtItem			:= 0
	Local nContAGG			:= 0
	Local nX				:= 0
	Local nLtOfItID			:= 1
	Local cCodPed			:= ""
	Local cLogErro			:= ""
	   
	Private lMsErroAuto    	:= .F.
	Private lAutoErrNoFile 	:= .T.
	
	AdpLogEAI(1, "MATI410", nTypeTrans, cTypeMessage, oEAIObEt)
	
	//Mensagem de Entrada
	If nTypeTrans == TRANS_RECEIVE .And. ValType( oEAIObEt ) == 'O'
	
	  	//Regra de Negócio
		If cTypeMessage == EAI_MESSAGE_BUSINESS
		
			If oEAIObEt:getPropValue("OrderPurpose") !=  nil .And. !Empty( oEAIObEt:getPropValue("OrderPurpose") )    
				If AllTrim(oEAIObEt:getPropValue("OrderPurpose")) == "2"
                    //Marca
					If oEAIObEt:getHeaderValue("ProductName") !=  nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") )    
						cMarca := oEAIObEt:getHeaderValue("ProductName")
					Else
						lRet := .F.
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0013 // "Informe a Marca!"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
						AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																									
					EndIf
	
	                //InternalId do pedido
					If oEAIObEt:getPropValue("InternalId") != nil .And. !Empty( oEAIObEt:getPropValue("InternalId") )  
						cValExt := oEAIObEt:getPropValue("InternalId")
					Else
						lRet := .F.
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0014 // "O InternalId é obrigatório!"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
						AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																									
					EndIf

	                //Obtém o InternalId
					cValInt := RTrim(CFGA070INT(cMarca, cAlias, cField, cValExt))
					If Empty(cValInt) .And. (Upper(AllTrim(oEAIObEt:getEvent())) == "UPSERT" .Or. Upper(AllTrim(oEAIObEt:getEvent())) == "REQUEST") 
						lLock := LockByName("MATI410"+cEmpAnt+cFilAnt+cValExt)
						If !lLock 
						 	lRet := .F.
							cLogErro := ""	
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0051 //"Esse registro encontra-se bloqueado por outro usuário, tente novamente mais tarde."
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
							AdpLogEAI(3, "MATI410", ofwEAIObj, lRet)
						EndIf
					EndIf
	                //Se encontrou no de/para
					If !Empty(cValInt)
						cNumPed := PadR(StrTokArr(cValInt, "|")[3], TamSX3("C5_NUM")[1])
	
						If Upper(AllTrim(oEAIObEt:getEvent())) == "UPSERT" .Or. Upper(AllTrim(oEAIObEt:getEvent())) == "REQUEST"   
							nOpcx := 4 //UPDATE
						Else
							nOpcx := 5 //DELETE
	                        
	
							If SC6->(dbSeek(xFilial("SC6") + cNumPed))
								While xFilial("SC6") + cNumPed == SC6->C6_FILIAL + SC6->C6_NUM
									cAux := IntPdVExt(/*cEmpresa*/, SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, cPdVVer)[2]
									
	                                // Array que será usado ao manipular o de/para de itens
									aAdd(aItemAux, RTrim(CFGA070Ext(cMarca, "SC6", "C6_ITEM", cAux)))
									aAdd(aItemAux, cAux)
									aAdd(aItemAux, "SC6")
									aAdd(aItemAux, "C6_ITEM")
									
									aAdd(aDePara, {RTrim(CFGA070Ext(cMarca, "SC6", "C6_ITEM", cAux)),cAux,"SC6","C6_ITEM"})
	
									SC6->(dbSkip())
								EndDo
							EndIf
						EndIf
	
						aAdd(aCab, {"C5_FILIAL", xFilial("SC5"), Nil})
						aAdd(aCab, {"C5_NUM",    cNumPed,         Nil})
					Else
						If Upper(AllTrim(oEAIObEt:getEvent())) == "UPSERT" .Or. Upper(AllTrim(oEAIObEt:getEvent())) == "REQUEST"  
							nOpcx := 3 //INSERT
						Else
							lRet := .F.
							cLogErro := ""	
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0017 // "O registro a ser excluído não foi encontrado na base Protheus."
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
							AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																										
						EndIf
					EndIf
	
	                //Se não é exclusão
					If nOpcx != 5
	                    // Tipo pedido
						aAdd(aCab, {"C5_TIPO", "N", Nil})
	
	                    // Obtém o Código Interno do Cliente e a Loja
						If oEAIObEt:getPropValue("CustomerInternalId") != nil .And. !Empty( oEAIObEt:getPropValue("CustomerInternalId") )   
							aAux := IntCliInt(oEAIObEt:getPropValue("CustomerInternalId"), cMarca, cCusVer)
							If !aAux[1]
								lRet := aAux[1]
								cLogErro := ""	
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := aAux[2]
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
								AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																											
							Else
								cCliente := aAux[2][3]
								cLoja := aAux[2][4]
								aAdd(aCab, {"C5_CLIENTE", cCliente, Nil})
								aAdd(aCab, {"C5_LOJACLI",    cLoja,    Nil})
							EndIf
						ElseIf oEAIObEt:getPropValue("CustomerCode") != nil .And. !Empty( oEAIObEt:getPropValue("CustomerCode") )    
							If Len(oEAIObEt:getPropValue("CustomerCode")) > TamSX3("C5_CLIENTE")[1]
								cCliente := SubStr(oEAIObEt:getPropValue("CustomerCode"), 1, TamSX3("C5_CLIENTE")[1])
								cLoja    := PadR(SubStr(oEAIObEt:getPropValue("CustomerCode"), TamSX3("C5_CLIENTE")[1] + 1), TamSX3("C5_LOJACLI")[1])
							Else
								cCliente := PadR(oEAIObEt:getPropValue("CustomerCode"), TamSX3("C5_CLIENTE")[1])
								cLoja   := "01"
							EndIf
							aAdd(aCab, {"C5_CLIENTE", cCliente, Nil})
							aAdd(aCab, {"C5_LOJACLI",    cLoja,    Nil})
						EndIf
	
	                    //Obtém o Código Interno da Condição de Pagamento
						If oEAIObEt:getPropValue("PaymentConditionInternalId") != nil .And. !Empty( oEAIObEt:getPropValue("PaymentConditionInternalId") )  
							aAux := IntConInt(oEAIObEt:getPropValue("PaymentConditionInternalId"), cMarca, cConVer)
							If !aAux[1]
								lRet := aAux[1]
								cLogErro := ""	
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := aAux[2]
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
								AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																											
							Else
								cCond := aAux[2][3]
								aAdd(aCab, {"C5_CONDPAG", cCond, Nil})
							EndIf
						ElseIf IsIntegTop() .Or. Upper(AllTrim(cMarca)) == "HIS"
							cCond := SuperGetMV("MV_SLMCOND", .F., "")
							aAdd(aCab, {"C5_CONDPAG", cCond, Nil})
						ElseIf oEAIObEt:getPropValue("PaymentTermCode") != nil .And. !Empty( oEAIObEt:getPropValue("PaymentTermCode") )    
							cCond := oEAIObEt:getPropValue("PaymentTermCode")
							aAdd(aCab, {"C5_CONDPAG", cCond, Nil})
						EndIf
	
	                    // Data de Emissão
						If oEAIObEt:getPropValue("RegisterDate") != nil .And. !Empty( oEAIObEt:getPropValue("RegisterDate") )  
							cDatEmis := oEAIObEt:getPropValue("RegisterDate")
							aAdd(aCab, {"C5_EMISSAO", cTod(SubStr(cDatEmis, 9, 2) + "/" + SubStr(cDatEmis, 6, 2 ) + "/" + SubStr(cDatEmis, 1, 4 )), Nil})
						EndIf
	
	                    // Tipo de Frete
						If oEAIObEt:getPropValue("FreightType") != nil .And. !Empty( oEAIObEt:getPropValue("FreightType") )  
							aAdd(aCab, {"C5_TPFRETE", getTpFre(AllTrim(oEAIObEt:getPropValue("FreightType")), nTypeTrans), Nil})
						EndIf
						
						// Transportadora
						If oEAIObEt:getPropValue("CarrierCode") != nil .And. !Empty( oEAIObEt:getPropValue("CarrierCode") )  
							aCodTransp 	:= StrTokArr(CFGA070Int(cMarca, "SA4", "A4_COD", oEAIObEt:getPropValue("CarrierCode")),"|")
							If Len( aCodTransp ) > 0
								If !Empty( aCodTransp[Len(aCodTransp)] )
									aAdd(aCab, {"C5_TRANSP", aCodTransp[Len(aCodTransp)], Nil})
								Endif
							Else
								aCodTransp 	:= StrTokArr( oEAIObEt:getPropValue("CarrierCode"),"|")
								If Len( aCodTransp ) > 0
									SA4->(dbSetOrder(1))
					 				If SA4->(dbSeek(xFilial("SA4") + aCodTransp[Len(aCodTransp)]))
										aAdd(aCab, {"C5_TRANSP", aCodTransp[Len(aCodTransp)], Nil})
									Endif
								Endif
							Endif						
						EndIf
						
						// Mensagem da nota
						If oEAIObEt:getPropValue("InvoiceMessage") != nil .And. !Empty( oEAIObEt:getPropValue("InvoiceMessage") )   
							aAdd(aCab, {"C5_MENNOTA", oEAIObEt:getPropValue("InvoiceMessage"), Nil})
						EndIf

	                    // Frete
						If oEAIObEt:getPropValue("FreightValue") != nil .And. !Empty( oEAIObEt:getPropValue("FreightValue") )   
							aAdd(aCab, {"C5_FRETE", oEAIObEt:getPropValue("FreightValue"), Nil})
						EndIf
	
	                    // Peso Bruto
						If oEAIObEt:getPropValue("GrossWeight") != nil .And. !Empty( oEAIObEt:getPropValue("GrossWeight") )  
							aAdd(aCab, {"C5_PBRUTO", oEAIObEt:getPropValue("GrossWeight"), Nil})
						EndIf
	
	                    // Valor do Seguro
						If oEAIObEt:getPropValue("InsuranceValue") != nil .And. !Empty( oEAIObEt:getPropValue("InsuranceValue") )  
							aAdd(aCab, {"C5_SEGURO", oEAIObEt:getPropValue("InsuranceValue"), Nil})
						EndIf
						
	                    // Codigo Vendedor
						If oEAIObEt:getPropValue("SellerCode") != nil .And. !Empty( oEAIObEt:getPropValue("SellerCode") )  
							aCodVend 	:= StrTokArr(CFGA070Int(cMarca, "SA3", "A3_COD", oEAIObEt:getPropValue("SellerCode")),"|")
							
							If Len( aCodVend ) > 0
								If !Empty( aCodVend[Len(aCodVend)] )
									aAdd(aCab, {"C5_VEND1", aCodVend[Len(aCodVend)], Nil})
								Endif
							Endif
						EndIf
						
	                    // Tabela de Preco
						If oEAIObEt:getPropValue("PriceTableNumber") != nil .And. !Empty( oEAIObEt:getPropValue("PriceTableNumber") )  
							aCodTab 	:= StrTokArr(CFGA070Int(cMarca, "DA0", "DA0_CODTAB", oEAIObEt:getPropValue("PriceTableNumber")),"|")
							
							If Len( aCodTab ) > 0
								If !Empty( aCodTab[Len(aCodTab)] )
									aAdd(aCab, {"C5_TABELA", aCodTab[Len(aCodTab)], Nil})
								Endif
							Endif
						EndIf
						// Numero da Nota
						If oEAIObEt:getPropValue("InvoiceNumber") != nil .And. !Empty( oEAIObEt:getPropValue("InvoiceNumber") )  
							aAdd(aCab, {"C5_NOTA", Rtrim(oEAIObEt:getPropValue("InvoiceNumber")), Nil})
						EndIf
						If oEAIObEt:getPropValue("InvoiceSerie") != nil .And. !Empty( oEAIObEt:getPropValue("InvoiceSerie") )  
							aAdd(aCab, {"C5_SERIE", Rtrim(oEAIObEt:getPropValue("InvoiceSerie")), Nil})
						EndIf
	                    //Moeda
						If oEAIObEt:getPropValue("CurrencyId") != nil .And. !Empty( oEAIObEt:getPropValue("CurrencyId") )   
							cAux := oEAIObEt:getPropValue("CurrencyId")
							aAux := GetCurrId(cAux,cMarca, /*cMoeVer*/)
							If !aAux[1]
								lRet := aAux[1]
								cLogErro := ""	
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := aAux[2]
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
								AdpLogEAI(1, "MATI410", nTypeTrans, cTypeMessage, ofwEAIObj)
																											
							Else
								aAdd(aCab, {"C5_MOEDA", Val(aAux[2][3]), Nil})
							EndIf
						ElseIf oEAIObEt:getPropValue("CurrencyCode") != nil .And. !Empty( oEAIObEt:getPropValue("CurrencyCode") )   
							aAdd(aCab, {"C5_MOEDA", Val(oEAIObEt:getPropValue("CurrencyCode")), Nil})
						EndIf
	                     
	                    //Natureza
						If IsIntegTop() .Or. Upper(AllTrim(cMarca)) == "HIS"
							aAdd(aCab, {"C5_NATUREZ", GetNewPar("MV_SLMNTPV", .F., ""), Nil})
						EndIf
	                     
						If lWorkCode
		                    //Codigo da Obra - Utilizamos o codigo da obra externo
							If oEAIObEt:getPropValue("WorkCode") != nil  
								If !Empty( oEAIObEt:getPropValue("WorkCode") )  
									aAreaSON := SON->(GetArea())
									cSONCodExt := AllTrim(oEAIObEt:getPropValue("WorkCode"))
									SON->(DbSetOrder(3))
									If SON->( DBSeek( xFilial("SON") + cSONCodExt ) )
										aAdd(aCab,{"C5_CNO", SON->ON_CODIGO, Nil})
									Else
										lRet := .F.
										cLogErro := ""	
										ofwEAIObj:Activate()
										ofwEAIObj:setProp("ReturnContent")
										cLogErro := STR0046 //"Código da obra não localizado no Cadastro Nacional de Obras!"
										ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
										AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																													
									EndIf
									RestArea(aAreaSON)
								Else
									aAdd(aCab,{"C5_CNO"," ", Nil})
								EndIf
							EndIf
						EndIf
	               
	                    //Origem
						If Upper(AllTrim(cMarca)) == "LOGIX"
							aAdd(aCab,{"C5_ORIGEM",Upper(AllTrim(cMarca)), Nil })
						Else
							aAdd(aCab,{"C5_ORIGEM","MSGEAI", Nil})
						Endif
	
						//Monta o array dos itens
						oLtOfItem := oEAIObEt:getPropValue("SalesOrderItens")
	
						For nI := 1 To Len( oLtOfItem )    
							cItemSC6 := StrZero(nI, TamSX3("C6_ITEM")[1])
							cCodProd := ""
							aItemAPos:= {}
							aReserva := ""
							cLote	 := ""
							cSubLote := ""
							cSerie	 := ""
							cLocaliz := ""
							
	                        // Array que será usado ao manipular o de/para de itens
							aAdd(aDePara, Array(4))
							aDePara[nI][1] := oLtOfItem[nI]:getPropValue("InternalId")    
							aDePara[nI][2] := PadL(oLtOfItem[nI]:getPropValue("OrderItem"), TamSx3("C6_ITEM")[1], "0")
							aDePara[nI][3] := "SC6"
							aDePara[nI][4] := "C6_ITEM"
	
							aAdd(aItemAux, {"C6_ITEM", cItemSC6, Nil})
	
	                        // Obtém o Código Interno do produto
							If oLtOfItem[nI]:getPropValue("ItemInternalId") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("ItemInternalId") )   
								aAux := IntProInt(oLtOfItem[nI]:getPropValue("ItemInternalId"), cMarca)
								If !aAux[1]
									lRet := aAux[1]
									cLogErro := ""	
									ofwEAIObj:Activate()
									ofwEAIObj:setProp("ReturnContent")
									cLogErro := aAux[2]
									ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
									AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																												
								Else
									cCodProd := aAux[2][3]
									aAdd(aItemAux, {"C6_PRODUTO",cCodProd , Nil})
								EndIf
							ElseIf oLtOfItem[nI]:getPropValue("ItemCode") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("ItemCode") )   
								cCodProd := oLtOfItem[nI]:getPropValue("ItemCode")
								aAdd(aItemAux, {"C6_PRODUTO", cCodProd, Nil})
							EndIf
	
	                        // Descrição do produto
							If oLtOfItem[nI]:getPropValue("ItemDescription") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("ItemDescription") )   
								aAdd(aItemAux , {"C6_DESCRI" , AllTrim(oLtOfItem[nI]:getPropValue("ItemDescription")) , Nil } )
							EndIf
	
	                        // Obtém o código interno do local de estoque
							If oLtOfItem[nI]:getPropValue("WarehouseInternalId") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("WarehouseInternalId") )  
								aAux := IntLocInt(oLtOfItem[nI]:getPropValue("WarehouseInternalId"), cMarca)
								If !aAux[1]
									lRet := aAux[1]
									cLogErro := ""	
									ofwEAIObj:Activate()
									ofwEAIObj:setProp("ReturnContent")
									cLogErro := aAux[2]
									ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
									AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																												
								Else
									aAdd(aItemAux, {"C6_LOCAL", aAux[2][3], Nil})
								EndIf
							EndIf
	
	                        // Unidade de Medida do Item
							If oLtOfItem[nI]:getPropValue("UnitOfMeasureInternalId") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("UnitOfMeasureInternalId") )  
								aAux := IntUndInt(oLtOfItem[nI]:getPropValue("UnitOfMeasureInternalId"), cMarca, /*cUndVer*/)
								If !aAux[1]
									lRet := aAux[1]
									cLogErro := ""	
									ofwEAIObj:Activate()
									ofwEAIObj:setProp("ReturnContent")
									cLogErro := aAux[2]
									ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
									AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																												
								Else
									aAdd(aItemAux, {"C6_UM", aAux[2][3], Nil})
								EndIf
							ElseIf oLtOfItem[nI]:getPropValue("ItemUnitOfMeasure") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("ItemUnitOfMeasure") )   
								aAdd(aItemAux, {"C6_UM", oLtOfItem[nI]:getPropValue("ItemUnitOfMeasure"), Nil})
							EndIf
	
	                        // Projeto
							If oLtOfItem[nI]:getPropValue("ListOfApportionOrderItem") != nil   
								
								oObjLtPro := oLtOfItem[nI]:getPropValue("ListOfApportionOrderItem") 
			                         
								For nK := 1 to Len( oObjLtPro )  
									If oObjLtPro[nK]:getPropValue("ProjectInternalId") != nil .And. !Empty( oObjLtPro[nK]:getPropValue("ProjectInternalId") )    
										aAux := IntPrjInt(oObjLtPro[nK]:getPropValue("ProjectInternalId"), cMarca)
	
										If !aAux[1]
											lRet := aAux[1]
											cLogErro := ""	
											ofwEAIObj:Activate()
											ofwEAIObj:setProp("ReturnContent")
											cLogErro := aAux[2]
											ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
											IIf(lLog, AdpLogEAI(5, "MATI410", ofwEAIObj, lRet), ConOut(STR0012))
																														
										Else
											aAdd(aItemAux, {"C6_PROJPMS", aAux[2][3], Nil})
											Exit
										EndIf
									Endif
								Next nK
							EndIf
	
	                        // Tarefa
							If oLtOfItem[nI]:getPropValue("ListOfApportionOrderItem") != nil  
								
								oObjLtTar := oLtOfItem[nI]:getPropValue("ListOfApportionOrderItem")
			                         
								For  nK := 1 to Len( oObjLtTar )   
			                         	
									If oObjLtTar[nK]:getPropValue("TaskInternalId") != nil .And. !Empty( oObjLtTar[nK]:getPropValue("TaskInternalId") ) 
										aAux := IntTrfInt(oObjLtTar[nK]:getPropValue("TaskInternalId"), cMarca)
	
										If !aAux[1]
											lRet := aAux[1]
											cLogErro := ""	
											ofwEAIObj:Activate()
											ofwEAIObj:setProp("ReturnContent")
											cLogErro := aAux[2]
											ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
											IIf(lLog, AdpLogEAI(5, "MATI410", ofwEAIObj, lRet), ConOut(STR0012))
																														
										Else
											aAdd(aItemAux, {"C6_TASKPMS", aAux[2][5], Nil})
											Exit
										EndIf
									Endif
								Next nK
							EndIf
	
	                        // Quantidade
							If oLtOfItem[nI]:getPropValue("Quantity") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("Quantity") )   
								aAdd(aItemAux, {"C6_QTDVEN", oLtOfItem[nI]:getPropValue("Quantity"), Nil})
							EndIf
	
	                        // Preço unitário
							If oLtOfItem[nI]:getPropValue("UnityPrice") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("UnityPrice") ) 
								aAdd(aItemAux, {"C6_PRCVEN", oLtOfItem[nI]:getPropValue("UnityPrice"), Nil})
	                           
								aAdd(aItemAux, {"C6_PRUNIT", oLtOfItem[nI]:getPropValue("UnityPrice"), Nil})
							EndIf
	
	                        // Preço total
							If oLtOfItem[nI]:getPropValue("TotalPrice") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("TotalPrice") )  
								nPrcTtl += oLtOfItem[nI]:getPropValue("TotalPrice")
								aAdd(aItemAux, {"C6_VALOR", A410Arred(oLtOfItem[nI]:getPropValue("TotalPrice"),"C6_VALOR"), Nil})
							Else
								If oLtOfItem[nI]:getPropValue("Quantity") != nil .And. oLtOfItem[nI]:getPropValue("UnityPrice") != nil
									nPrcTtl += A410Arred(oLtOfItem[nI]:getPropValue("Quantity") * oLtOfItem[nI]:getPropValue("UnityPrice"),"C6_VALOR")
									aAdd(aItemAux, {"C6_VALOR", A410Arred(oLtOfItem[nI]:getPropValue("Quantity") * oLtOfItem[nI]:getPropValue("UnityPrice"),"C6_VALOR"), Nil})
								Endif
							EndIf
	
	                        // Valor de desconto do item
							If oLtOfItem[nI]:getPropValue("ItemDiscounts"):getPropValue("ItemDiscount") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("ItemDiscounts"):getPropValue("ItemDiscount") ) 
								aAdd(aItemAux, {"C6_VALDESC", oLtOfItem[nI]:getPropValue("ItemDiscounts"):getPropValue("ItemDiscount"), Nil})
							EndIf
							
							//INICIO TRATAMENTO TES
							If !Empty(cCliente) .And. !Empty(cLoja) .And. !Empty(cCodProd)
								If oLtOfItem[nI]:getPropValue("TypeOperation") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("TypeOperation") )  
								
									If Len(Alltrim(oLtOfItem[nI]:getPropValue("TypeOperation"))) <= 2
									
										cTpOpera :=PADR(oLtOfItem[nI]:getPropValue("TypeOperation"),TamSX3('FM_TIPO')[1] )

										cTesPrd  := MaTesInt(2, cTpOpera, cCliente, cLoja, "C", cCodProd)
																			
										If !Empty(cTesPrd)
											aAdd(aItemAux, {"C6_TES", cTesPrd, Nil})
											aAdd(aItemAux, {"C6_OPER", cTpOpera , Nil}) // adicionado para gravar o tipo de operação.
										Elseif Empty(cTesPrd) .AND. oLtOfItem[nI]:getPropValue("TaxOpCode") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("TaxOpCode") )   
											
											aCodcfop 	:= StrTokArr(CFGA070Int(cMarca, "SF4", "F4_CODIGO", oLtOfItem[nI]:getPropValue("TaxOpCode")),"|")
											If !Empty(aCodcfop[3])
												aAdd(aItemAux, {"C6_TES", aCodcfop[3] , Nil})
											Else
												lRet := .F.
												cLogErro := ""	
												ofwEAIObj:Activate()
												ofwEAIObj:setProp("ReturnContent")
												cLogErro := STR0044 //"CFOP não relacionada a nenhuma TES no De/Para de Mensagem"
												ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
												AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																															
											Endif
										Else
											lRet := .F.
											cLogErro := ""	
											ofwEAIObj:Activate()
											ofwEAIObj:setProp("ReturnContent")
											cLogErro := STR0045 //"Tipo de operação não possui nenhuma TES atrelada."
											ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
											AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																															
										Endif
									Else
									
										// Tipo de entrada e saída - TES
										If oLtOfItem[nI]:getPropValue("TypeOperation") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("TypeOperation") )  
											aAdd(aItemAux, {"C6_TES", oLtOfItem[nI]:getPropValue("TypeOperation"), Nil})
										Else
										// Se possui integração com o TOP
											If IsIntegTop() .Or. Upper(AllTrim(cMarca)) == "HIS"
											// Caso a TES não tenha sido informada, assume a TES do parametro MV_SLMTS
												cTES := AllTrim(GetMV("MV_SLMTS"))
												If !Empty(cTES)
													aAdd(aItemAux, {"C6_TES", cTES, Nil})
												Else
													lRet := .F.
													cLogErro := ""	
													ofwEAIObj:Activate()
													ofwEAIObj:setProp("ReturnContent")
													cLogErro := STR0020 //"Preencha o parâmetro MV_SLMTS no Protheus."
													ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
													AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																																	
												EndIf
											EndIf
											
										Endif
									Endif
								Endif
							EndIf	
     	                    //FIM - TRATAMENTO TES
                            //Aposentadoria Especial REINF    
							If oLtOfItem[nI]:getPropValue("Retirement15Years") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("Retirement15Years") ) // Apos Especial 15 anos    
								n15Anos := oLtOfItem[nI]:getPropValue("Retirement15Years")
							EndIf
							If oLtOfItem[nI]:getPropValue("Retirement20Years") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("Retirement20Years") ) // Apos Especial 20 anos    
								n20Anos := oLtOfItem[nI]:getPropValue("Retirement20Years")
							EndIf
							If oLtOfItem[nI]:getPropValue("Retirement25Years") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("Retirement25Years") )  // Apos Especial 25 anos   
								n25Anos := oLtOfItem[nI]:getPropValue("Retirement25Years")
							EndIf
							If (n15Anos + n20Anos + n25Anos) > 0
								aAdd(aItemAPos, {cItemSC6,n15Anos,n20Anos,n25Anos})
							EndIf
							If Len(aItemAPos) > 0
								aAdd(aAposEsp, {cItemSC6, aItemAPos})
							EndIf
	
							 //Verifica Lote do Item
							If oLtOfItem[nI]:getPropValue("LotNumber") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("LotNumber") )  
								cLote := oLtOfItem[nI]:getPropValue("LotNumber")
								aAdd(aItemAux, {"C6_LOTECTL", cLote , Nil} )
							Endif
	
			                 //Verifica SubLote do Item
							If oLtOfItem[nI]:getPropValue("SubLotNumber") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("SubLotNumber") )  
								cSubLote := oLtOfItem[nI]:getPropValue("SubLotNumber")
								aAdd(aItemAux, {"C6_NUMLOTE", cSubLote , Nil} )
							Endif
			                
    		                 //Verifica Serie do Item
							If oLtOfItem[nI]:getPropValue("SeriesItem") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("SeriesItem") )  
								cSerie := oLtOfItem[nI]:getPropValue("SeriesItem")
								aAdd(aItemAux, {"C6_NUMSERI", cSerie , Nil} )
							Endif
	
			                 //Verifica Endereço do Item
							If oLtOfItem[nI]:getPropValue("AddressingItem") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("AddressingItem") )  
								cLocaliz := oLtOfItem[nI]:getPropValue("AddressingItem")
								aAdd(aItemAux, {"C6_LOCALIZ", cLocaliz, Nil} )
							Endif
	
			                 //Verifica Data Faturamneto
							If oLtOfItem[nI]:getPropValue("InvoicingDate") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("InvoicingDate") )  
								cDatFat := oLtOfItem[nI]:getPropValue("InvoicingDate")
								cDatFat := cTod(SubStr(cDatFat, 9, 2) + "/" + SubStr(cDatFat, 6, 2 ) + "/" + SubStr(cDatFat, 1, 4 ))
								aAdd(aItemAux, {"C6_DATFAT", cDatFat, Nil} )
							Endif
			                 //Verifica Data de Entrega
							If oLtOfItem[nI]:getPropValue("DeliveryDate") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("DeliveryDate") )  
								cDataEnt := oLtOfItem[nI]:getPropValue("DeliveryDate")
								cDataEnt := cTod(SubStr(cDataEnt, 9, 2) + "/" + SubStr(cDataEnt, 6, 2 ) + "/" + SubStr(cDataEnt, 1, 4 ))
								aAdd(aItemAux, {"C6_ENTREG", cDataEnt, Nil} )
							Endif
							//Verifica Numero da Nota
							If oLtOfItem[nI]:getPropValue("InvoiceNumber") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("InvoiceNumber") )  
								cNota := oLtOfItem[nI]:getPropValue("InvoiceNumber")
								aAdd(aItemAux, {"C6_NOTA", cNota, Nil} )								
							Endif
							//Verifica Numero da Serie da Nota
							If oLtOfItem[nI]:getPropValue("InvoiceSerie") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("InvoiceSerie") )  
								cSerie := oLtOfItem[nI]:getPropValue("InvoiceSerie")
								aAdd(aItemAux, {"C6_SERIE", cSerie, Nil} )
							Endif							
			                 //Verifica Quantidade Alocada
							If oLtOfItem[nI]:getPropValue("AlloccatedQuantity") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("AlloccatedQuantity") )  
								aAdd(aItemAux, {"C6_QTDEMP", oLtOfItem[nI]:getPropValue("AlloccatedQuantity"), Nil} )
							Endif
			                 //Verifica Quantidade Entregue
							If oLtOfItem[nI]:getPropValue("QuantityDelivered") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("QuantityDelivered") )  
								aAdd(aItemAux, {"C6_QTDENT", oLtOfItem[nI]:getPropValue("QuantityDelivered"), Nil} )
							Endif
			                 //Verifica Reserva do Item
							If oLtOfItem[nI]:getPropValue("ItemReserveInternalId") != nil .And. !Empty( oLtOfItem[nI]:getPropValue("ItemReserveInternalId") )  
			                  
								cValExtRes:= oLtOfItem[nI]:getPropValue("ItemReserveInternalId")
								aAux      := StrTokArr(CFGA070Int(cMarca, "SC0", "C0_DOCRES", cValExtRes), "|")
											
								If ValType(aAux) == "A" .And. Len(aAux) > 0
			                 
									aReserva:= ReserItEai( cFilant,;
										aAux[3],;
										cCodProd,;
										cLote,;
										cSubLote,;
										cLocaliz,;
										cSerie)
									If len(aReserva) > 0
										aadd(aReserv,{aReserva[1][1],aReserva[1][2] })
										aAdd(aItemAux, {"C6_RESERVA", aReserva[1][2], Nil} )
									Else
										lRet := .F.
									Endif
								Endif
								                         	
								If !lRet
									cLogErro := ""	
									ofwEAIObj:Activate()
									ofwEAIObj:setProp("ReturnContent")
									cLogErro := STR0047+Alltrim(cValExtRes)+STR0048 //"A Reserva :" " não existe no De\Para Protheus."
									ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
									AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																																
								Endif
							Endif
			                 //Fim - Reserva
							 
	                        // Verifica se há rateio para este item. Caso tenha, informa o valor 1 para o campo SC6->C6_RATEIO.
							If oLtOfItem[nI]:getPropValue("ListOfApportionOrderItem") != nil  
								
								oObjLtRat := oLtOfItem[nI]:getPropValue("ListOfApportionOrderItem")
			                         
								For nK := 1 to Len( OObjLtRat )   
			                         	
									If oObjLtRat[nK]:getPropValue("InternalId") != nil .And. !Empty( oObjLtRat[nK]:getPropValue("InternalId") ) 
										aAdd(aItemAux, {"C6_RATEIO", "1", Nil})
										Exit
									Endif
								Next nK
							Endif
	
							aAdd(aItens, aClone(aItemAux))
							aItemAux := {}
	
							If oLtOfItem[nI]:getPropValue("ListOfApportionOrderItem") != nil  .And. !Empty( oLtOfItem[nI]:getPropValue("ListOfApportionOrderItem") )  
								
								oLstRat := oLtOfItem[nI]:getPropValue("ListOfApportionOrderItem")
	
								For nJ := 1 To Len( oLstRat )  
	
	                                // Possui centro de custo informado
									If oLstRat[nJ]:getPropValue("CostCenterInternalId") != nil .And. !Empty( oLstRat[nJ]:getPropValue("CostCenterInternalId") )  
	                                    // Possui percentual informado
										If oLstRat[nJ]:getPropValue("Percentual") != nil .And. !Empty( oLstRat[nJ]:getPropValue("Percentual") )   
	                                        // O centro de Custo existe no de/para e na base
											aAux := IntCusInt(oLstRat[nJ]:getPropValue("CostCenterInternalId"), cMarca, /*cCosVer*/)
											If !aAux[1]
												lRet := .F.
												cLogErro := ""	
												ofwEAIObj:Activate()
												ofwEAIObj:setProp("ReturnContent")
												cLogErro := aAux[2] + STR0022 /*" Item "*/ + AllTrim(oLtOfItem[nI]:getPropValue("OrderItem")) + "."
												ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
												AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																																			
											EndIf
	
	                                        // Valida o Centro de Custo obtido
											If !IntVldCC(aAux[2][3], Date(), "MATI410")[1]
												lRet := .F.
												cLogErro := ""	
												ofwEAIObj:Activate()
												ofwEAIObj:setProp("ReturnContent")
												cLogErro := STR0042 + STR0022 /*" Item "*/ + AllTrim(oLtOfItem[nI]:getPropValue("OrderItem")) + "."
												ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
												AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																																			
											EndIf
	
	                                        // Verifica se já existe o centro de custo para este item
											nLin := aScan(aCCusto, {|x| x[3] == aAux[2][3]})
	
	                                        // Caso já exista o centro de custo para o item somar o %
											If nLin > 0
												aCCusto[nLin][2] += oLstRat[nJ]:getPropValue("Percentual")
											Else
												aAdd(aCCusto, {cItemSC6, oLstRat[nJ]:getPropValue("Percentual"), aAux[2][3]})
											EndIf
										Else
											lRet := .F.
											cLogErro := ""	
											ofwEAIObj:Activate()
											ofwEAIObj:setProp("ReturnContent")
											cLogErro := STR0023 /*"Percentual de rateio inválido para o item "*/ + cItemSC6 + "."
											ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
											AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																																			
										EndIf
									EndIf
								Next nJ
	
                               // Monta o array com os itens do rateio de centro de custo agrupados por centro de custo
								aAux := {}
	
								For nJ := 1 To Len(aCCusto)
									aAdd(aLinha, {"AGG_FILIAL",  xFilial("AGG"),                           Nil})
									aAdd(aLinha, {"AGG_PEDIDO",  "",                                       Nil})
									aAdd(aLinha, {"AGG_FORNECE", cCliente,                                 Nil})
									aAdd(aLinha, {"AGG_LOJA",    cLoja,                                    Nil})
									aAdd(aLinha, {"AGG_ITEMPD",  aCCusto[nJ][1],                           Nil})
									aAdd(aLinha, {"AGG_ITEM",    StrZero(nJ, TamSx3("AGG_ITEM")[1]),       Nil})
									aAdd(aLinha, {"AGG_PERC",    aCCusto[nJ][2],                           Nil})
									aAdd(aLinha, {"AGG_CC",      aCCusto[nJ][3],                           Nil})
									aAdd(aLinha, {"AGG_CONTA",   "",                                       Nil})
									aAdd(aLinha, {"AGG_ITEMCT",  "",                                       Nil})
									aAdd(aLinha, {"AGG_CLVL",    "",                                       Nil})
									aAdd(aAux, aLinha)
									aLinha := {}
								Next nJ
	
								aCCusto := {}
	
								aAdd(aItemRat, {cItemSC6, aAux})
							EndIf
						Next nI
						
	                     //Se não for array
						If oEAIObEt:getPropValue("ListOfCreditDocument") != nil .And. !Empty( oEAIObEt:getPropValue("ListOfCreditDocument") )  
							If !Adiantamento(cCond)
								lRet := .F.
								cLogErro := ""	
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := STR0033 //"Para utilizar título de adiantamento a condição de pagamento do pedido deve ser do tipo adiantamento."
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
								AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																																			
							EndIf
	
							//Atualiza objeto com a posição atual
							oObjLtCred := oEAIObEt:getPropValue("ListOfCreditDocument")
	
							For nL := 1 To Len( oObjLtCred )  
	
	                           	//Adiantamentos
								If oObjLtCred[nL]:getPropValue("CreditDocumentInternalId") != nil .And. !Empty( oObjLtCred[nL]:getPropValue("CreditDocumentInternalId") )   
									aAux := IntTRcInt(oObjLtCred[nL]:getPropValue("CreditDocumentInternalId"), cMarca, cTRcVer)
	
									If !aAux[1]
										lRet := aAux[1]
										cLogErro := ""	
										ofwEAIObj:Activate()
										ofwEAIObj:setProp("ReturnContent")
										cLogErro := aAux[2]
										ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
										AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																																					
									EndIf
								Else
									lRet := .F.
									cLogErro := ""	
									ofwEAIObj:Activate()
									ofwEAIObj:setProp("ReturnContent")
									cLogErro := STR0034 //"O InternalID do título de adiantamento não foi informado."
									ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
									AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																																				
								EndIf
	
								dbSelectArea("SE1")
								SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	
								If SE1->(dbSeek(xFilial("SE1") + PadR(aAux[2][3], TamSX3("FIE_PREFIX")[1]) + PadR(aAux[2][4], TamSX3("FIE_NUM")[1]) + PadR(aAux[2][5], TamSX3("FIE_PARCEL")[1]) + PadR(aAux[2][6], TamSX3("FIE_TIPO")[1])))
									cCliente := SE1->E1_CLIENTE
									cLoja    := SE1->E1_LOJA
								Else
									lRet := .F.
									cLogErro := ""	
									ofwEAIObj:Activate()
									ofwEAIObj:setProp("ReturnContent")
									cLogErro := STR0035 + AllTrim(oObjLtCred[nL]:getPropValue("CreditDocumentInternalId")) + STR0036 //"Título de adiantamento " " não encontrado na base."
									ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
									AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																																				
								EndIf
	
								If oObjLtCred[nL]:getPropValue("Value") != nil .And. !Empty( oObjLtCred[nL]:getPropValue("Value") )  
									lRet := .F.
									cLogErro := ""	
									ofwEAIObj:Activate()
									ofwEAIObj:setProp("ReturnContent")
									cLogErro := STR0037 //"O valor a ser abatido no título de adiantamento não foi informado."
									ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
									AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																																				
								EndIf
	
								aAdd(aLinha, {"FIE_FILIAL", xFilial("FIE"),                            	Nil})
								aAdd(aLinha, {"FIE_CART",   "R",                                       	Nil}) // Carteira receber
								aAdd(aLinha, {"FIE_PEDIDO", "",                                        	Nil})
								aAdd(aLinha, {"FIE_PREFIX", PadR(aAux[2][3], TamSX3("FIE_PREFIX")[1]), 	Nil})
								aAdd(aLinha, {"FIE_NUM",    PadR(aAux[2][4], TamSX3("FIE_NUM")[1]),    	Nil})
								aAdd(aLinha, {"FIE_PARCEL", PadR(aAux[2][5], TamSX3("FIE_PARCEL")[1]), 	Nil})
								aAdd(aLinha, {"FIE_TIPO",   PadR(aAux[2][6], TamSX3("FIE_TIPO")[1]),   	Nil})
								aAdd(aLinha, {"FIE_CLIENT", PadR(cCliente,   TamSX3("FIE_CLIENT")[1]), 	Nil})
								aAdd(aLinha, {"FIE_LOJA",   PadR(cLoja,      TamSX3("FIE_LOJA")[1]),   	Nil})
								aAdd(aLinha, {"FIE_VALOR",  oObjLtCred[nL]:getPropValue("Value"),    	Nil}) // Valor do ra que está vinculado ao pedido
	
								aAdd(aAdtPC, aClone(aLinha))
								aLinha := {}
							Next nL
						EndIf
	
	                   	//Valor do Desconto
						If oEAIObEt:getPropValue("Discounts") != nil .And. !Empty( oEAIObEt:getPropValue("Discounts") )   
							//Atualiza objeto com posicao atual
							oObjDisct := oEAIObEt:getPropValue("Discounts")
	                        
	                        //Valor de desconto
							nValDesc += Round(oObjDisct[1]:getPropValue("Discount"),TamSx3("C6_VALDESC")[2])
							
							nPercDesc := Round(nValDesc / nPrcTtl,2) * 100
							nSomaDesc := 0
							nDescIt := 0
							
							If nPercDesc > 0
								//Monta o array dos itens
								oObjItens := oEAIObEt:getPropValue("SalesOrderItens")
		                                               					 		
								For nM := 1 To Len( oObjItens )  
		                           
									nDescIt := ( oObjItens[nM]:getPropValue("UnityPrice") * nPercDesc ) / 100
		                           
									nSomaDesc += nDescIt
		                           
									If nM == Len( oObjItens )  
										If nSomaDesc <> nValDesc
											nDescIt += nValDesc - nSomaDesc
										Endif
									Endif
		                           
		                           // Verifica se já existe valor de desconto do item
									nJ := aScan(aItens[nM], {|x| x[1] == "C6_VALDESC"})
		
		                           // Caso já exista somar o valor
									If nJ > 0
										aItens[nM][nJ][2] := nDescIt
									Else
										aAdd(aItens[nM], {"C6_VALDESC", nDescIt, Nil})
									EndIf
								Next nM
							Endif
						EndIf
					EndIf
					 
					 // ponto de entrada inserido para controlar dados especificos do cliente
					If ExistBlock("MT410EAI")
						aRetPe := ExecBlock("MT410EAI",.F.,.F.,{aCab,aItens,oEAIObEt:getJSON()}) 
						If ValType(aRetPe) == "A" .And. Len(aRetPe) == 2 .And. ValType(aRetPe[1]) == "A" .And. ValType(aRetPe[2]) == "A"
							aCab 	:= aClone(aRetPe[1])
							aItens := aClone(aRetPe[2])
						EndIf
					EndIf
					  
					AdpLogEAI(4, nOpcx)
					AdpLogEAI(3, "aCab: ", aCab)
					AdpLogEAI(3, "aItens: ", aItens)
					AdpLogEAI(3, "aItemRat: ", aItemRat)
					AdpLogEAI(3, "aAdtPC: ", aAdtPC)
					AdpLogEAI(3, "aDePara: ", aDePara)
					
					
					//Verifica se houve erro antes da rotina automatica
					If Empty( cLogErro )
						Begin Transaction
		
						  //Inclusão das Reservas nos Itens, esse processo tem que ser feito dentro
			   			  //da transação, devido à regra usada pelo varejo.
							If Len(aReserv) > 0 .AND. FindFunction("LJ704ESTR") .AND. lIntegSC0
								LJ704ESTR(aReserv,nOpcx)
							Endif
		
							If nOpcx == 5
								If FindFunction("LJ704LRES") .AND. lIntegSC0
		                  	 	//Localiza Número do Documento responsável de uma reserva válida
		                  	 	//antes da exclusão do Pedido.
									LJ704LRES(xFilial("SC5"),cNumPed,@cDocRes)
								Endif
								MSExecAuto({|x,y,z|MATA410(x,y,z)},aCab,aItens,nOpcx)
							Else								
								MsExecAuto({|a,b,c,d,e,f,g,h,i,j,k,l,m,n,o| MATA410(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o )}, aCab, aItens, nOpcx, .F., aItemRat, aAdtPC,,,,,,,,,aAposEsp)										
							EndIf
		
		                  	// Se houve erros no processamento do MSExecAuto
							If lMsErroAuto 
								// Obtém o log de erros
								aMsgErro := GetAutoGRLog()
								nErrSize := Len(aMsgErro)
								lRet := .F.
								
								cLogErro := ""
								For nI := 1 To nErrSize
									cLogErro += aMsgErro[nI]  
								Next nI
								
								If Empty( cLogErro )
									cLogErro := MostraErro()
								Endif
				
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
							  	ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)								
								
								lRet := .F.		
						
		                     	//Desfaz a transacao
								DisarmTransaction()
								msUnlockAll()
							Else
								//Exclusão das reservas nos itens, esse processo tem que ser feito dentro
								//da transação, devido à regras usada pelo varejo.
								If nOpcx == 5 .AND. !Empty(cDocRes)
									If FindFunction("LJ704ESTR") .AND. lIntegSC0
										LJ704ESTR(,nOpcx,cDocRes,xFilial("SC5"),cMarca)
									Endif
								Endif
		                  
								If nOpcx <> 5
									dbSelectArea("SC6")
									SC6->(dbsetorder(1))
			
									SC6->(dbSeek(xFilial("SC6") + SC5->C5_NUM))
									While SC6->(!EOF()) .And. SC6->(C6_FILIAL + C6_NUM) == SC5->(C5_FILIAL + C5_NUM)
										RecLock("SC6", .F.)
										SC6->C6_PMSID := C6_NUM
										msUnlock()
			
										SC6->(dbSkip())
									EndDo
								Endif
		
								If nOpcx == 3 // INSERT
		                        	// Obtém o valor inserido pelo inicializador padrão após a execução da rotina automática
									cValInt := IntPdVExt(cEmpAnt, xFilial("SC5"), SC5->C5_NUM, /*cItem*/, cPdVVer)[2] // EMPRESA|FILIAL|PEDIDO
								EndIf
		
								AdpLogEAI(3, "cValInt: ", cValInt)
								AdpLogEAI(3, "cValExt: ", cValExt)
								
								If nOpcx != 5 
		                        	// Insere ou atualiza o registro na tabela XXF (de/para)
									CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F., 1)
								Else
		                        	// Exclui o registro na tabela XXF (de/para)
									CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .T., 1)
								EndIf
		
		                     	// Loop para manipular os Itens na tabela XXF (de/para)
								For nI := 1 To Len(aDePara)
									If nOpcx != 5
										cAux := IntPdVExt(cEmpAnt, xFilial("SC6"), SC5->C5_NUM, aDePara[nI][2], cPdVVer)[2]
										CFGA070Mnt(cMarca, aDePara[nI][3], aDePara[nI][4], aDePara[nI][1], cAux, .F., 1)
									Else
										CFGA070Mnt(cMarca, aDePara[nI][3], aDePara[nI][4], aDePara[nI][1], aDePara[nI][2], .T., 1)
									EndIf
								Next nI
								
								// Monta o JSON de retorno
								ofwEAIObj:Activate()
																						
								ofwEAIObj:setProp("ReturnContent")
													
								ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID",{},'InternalId',,.T.)
								ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[nLtOfItID]:setprop("Name","OrderInternalId",,.T.)
								ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[nLtOfItID]:setprop("Origin",cValExt,,.T.)
								ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[nLtOfItID]:setprop("Destination",cValInt,,.T.)	
								
								For nI := 1 To Len(aDePara)
									nLtOfItID++
									ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID",{},'InternalId',,.T.)
									ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[nLtOfItID]:setprop("Name","ItemInternalId",,.T.)
									ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[nLtOfItID]:setprop("Origin",aDePara[nI][1],,.T.)
	
									If nOpcx == 3 // INSERT
										ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[nLtOfItID]:setprop("Destination",cEmpAnt + "|" + xFilial("SC5") + "|" + SC5->C5_NUM + "|" + aDePara[nI][2] + "|2",,.T.)
									Else
										ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[nLtOfItID]:setprop("Destination",CFGA070Int(cMarca, aDePara[nI][3], aDePara[nI][4], aDePara[nI][1]),,.T.)
									EndIf
								Next nI
							EndIf
		
						End Transaction
						MsUnlockAll()											
					Endif
				If nOpcx == 3
					UnLockByName("MATI410"+cEmpAnt+cFilAnt+cValExt)	
				EndIf
				ElseIf AllTrim(oEAIObEt:getPropValue("OrderPurpose")) == "1"   
					aAdd(aRet, FWIntegDef("MATA120", cTypeMessage, nTypeTrans, oEAIObEt))
	
					If !Empty(aRet)
						lRet := aRet[1][1]
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := aRet[1][2]
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
						AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																																						
					EndIf
				Else
					lRet := .F.
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0024 // "Tipo de Pedido inválido!"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
					AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																																				
				EndIf
			Else
				lRet := .F.
				cLogErro := ""	
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				cLogErro := STR0025 // "Tipo de pedido não enviado."
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
				AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																																				
			EndIf
			
		//--------------------------------------
		//resposta da mensagem Unica TOTVS
		//--------------------------------------			
		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
			
	         //Se não houve erros na resposta
			If Upper(oEAIObEt:getPropValue("ProcessingInformation"):getPropValue("Status")) == "OK" 
	            //Verifica se a marca foi informada
				If oEAIObEt:getHeaderValue("ProductName") !=  nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") )
					cMarca := oEAIObEt:getHeaderValue("ProductName")
				Else
					lRet := .F.
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0027 // "Erro no retorno. O Product é obrigatório!"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
					AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																							
				EndIf
	
				oObLisOfIt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")
	
				For nI := 1 To Len( oObLisOfIt )
					cNameInternalId := oObLisOfIt[nI]:getPropValue('Name')  
					aAdd(aDePara, Array(4))
	
	               //Verifica se o InternalId foi informado
					If oObLisOfIt[nI]:getPropValue('Origin') != nil .And. !Empty( oObLisOfIt[nI]:getPropValue('Origin') )
	                  //Não armazena Rateio
						If 'ORDERINTERNALID' == AllTrim(Upper(cNameInternalId)) .Or. 'ITEMINTERNALID' == AllTrim(Upper(cNameInternalId))
							aDePara[nI][3] := oObLisOfIt[nI]:getPropValue('Origin')
						EndIf
					Else
						lRet := .F.
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0028 // "Erro no retorno. O OriginalInternalId é obrigatório!"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
						AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																								
					EndIf
	
	               //Verifica se o código externo foi informado
					If oObLisOfIt[nI]:getPropValue('Destination') != nil .And. !Empty( oObLisOfIt[nI]:getPropValue('Destination') )
	                  //Não armazena Rateio
						If 'ORDERINTERNALID' == AllTrim(Upper(cNameInternalId)) .Or. 'ITEMINTERNALID' == AllTrim(Upper(cNameInternalId))
							aDePara[nI][4] := oObLisOfIt[nI]:getPropValue('Destination')
						EndIf
					Else
						lRet := .F.
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0029 // "Erro no retorno. O DestinationInternalId é obrigatório!"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
						AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
																								
					EndIf
	
	               //Envia os valores de InternalId e ExternalId para o Log
					AdpLogEAI(3, "cValInt" + Str(nI) + ": ", aDePara[nI][2]) // InternalId
					AdpLogEAI(3, "cValExt" + Str(nI) + ": ", aDePara[nI][3]) // ExternalId
	               
					If 'ORDERINTERNALID' == AllTrim(Upper(cNameInternalId))
						aDePara[nI][1] := "SC5"
						aDePara[nI][2] := cField
					ElseIf 'ITEMINTERNALID' == AllTrim(Upper(cNameInternalId))
						aDePara[nI][1] := "SC6"
						aDePara[nI][2] := "C6_ITEM"
					EndIf
				Next nI
				
	         	//Loop para manipular os InternalId no de/para
				For nI := 1 To Len(aDePara)
					If Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == "UPSERT" .Or. Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == "REQUEST" 
						CFGA070Mnt(cMarca, aDePara[nI][1], aDePara[nI][2], aDePara[nI][4], aDePara[nI][3], .F., 1)
					ElseIf Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == "DELETE"
						CFGA070Mnt(cMarca, aDePara[nI][1], aDePara[nI][2], aDePara[nI][4], aDePara[nI][3], .T., 1)
					Else
						lRet := .F.
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0031 // "Evento do retorno inválido!"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
					EndIf
				Next nI
			Else
				cLogErro := ""
				If oEAIObEt:getpropvalue('ProcessingInformation') != nil
					oMsgError := oEAIObEt:getpropvalue('ProcessingInformation'):getpropvalue("ListOfMessages")
					For nX := 1 To Len( oMsgError )
						cLogErro += oMsgError[nX]:getpropvalue('Message') + Chr(10)
					Next nX
				Endif
		
				lRet := .F.
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)				
			EndIf
			
		//--------------------------------------
		//whois
		//--------------------------------------			
		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			Return {.T., "1.000|3.000|3.001|3.002|3.004|3.005|4.003", cMsgUnica}
		EndIf
	      
	//--------------------------------------
	//envio mensagem
	//--------------------------------------
	ElseIf nTypeTrans == TRANS_SEND
	
	  	//Verica operação realizada e insere no LOG
		Do Case
			Case Inclui
				AdpLogEAI(4, 3)
			Case Altera
				AdpLogEAI(4, 4)
			OtherWise
				AdpLogEAI(4, 5)
				cEvent := "delete"
				cCodPed := SC5->C5_NUM
		EndCase
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		SC5->(dbSeek(xFilial("SC5") + SC5->C5_NUM))
		
		ofwEAIObj:Activate()
		
		ofwEAIObj:setEvent(cEvent)
		
		ofwEAIObj:setprop("InternalId",IntPdVExt(cEmpAnt, xFilial("SC5"), IIf(Empty(cCodPed),SC5->C5_NUM,cCodPed), Nil, cPdVVer)[2])		
		ofwEAIObj:setprop("OrderPurpose","2")
		ofwEAIObj:setprop("CompanyId",cEmpAnt)
		ofwEAIObj:setprop("BranchId",cFilAnt)
		ofwEAIObj:setprop("CompanyInternalId",cEmpAnt + '|' + RTrim(cFilAnt))
		ofwEAIObj:setprop("OrderId",RTrim(SC5->C5_NUM))
	      
		If Inclui .Or. Altera
			
			ofwEAIObj:setprop("CustomerInternalId",IntCliExt(/*Empresa*/, /*Filial*/, SC5->C5_CLIENTE, SC5->C5_LOJACLI, /*cCusVer*/)[2])
			ofwEAIObj:setprop("CustomerCode",RTrim(SC5->C5_CLIENTE) + RTrim(SC5->C5_LOJACLI))
			ofwEAIObj:setprop("CurrencyCode",PadR(RTrim(cValToChar(SC5->C5_MOEDA)), TamSx3('C5_MOEDA')[1] ))
			ofwEAIObj:setprop("CurrencyId",IntMoeExt(/*cEmpresa*/, /*Filial*/, PadR(RTrim(cValToChar(SC5->C5_MOEDA)),TamSx3('C5_MOEDA')[1] ), /*cMoeVer*/)[2])
			ofwEAIObj:setprop("PaymentTermCode",RTrim(SC5->C5_CONDPAG))
			ofwEAIObj:setprop("PaymentConditionInternalId",IntConExt(/*Empresa*/, /*Filial*/, SC5->C5_CONDPAG, cConVer)[2])
			ofwEAIObj:setprop("RegisterDate",Transform(DtoS( SC5->C5_EMISSAO),'@R 9999-99-99'))
			ofwEAIObj:setprop("FreightType",getTpFre(SC5->C5_TPFRETE, nTypeTrans))
			ofwEAIObj:setprop("FreightValue",SC5->C5_FRETE)
			ofwEAIObj:setprop("GrossWeight",SC5->C5_PBRUTO)
			ofwEAIObj:setprop("InsuranceValue",SC5->C5_SEGURO)
			If !Empty( SC5->C5_VEND1 )
				ofwEAIObj:setprop("SellerCode", IntVenExt(cEmpAnt,/*cFilAnt*/,SC5->C5_VEND1,/*cVerVend*/)[2])	
			Endif
			oObjDisc := ofwEAIObj:setprop('Discounts',{},'Discounts',,.T.)
			oObjDisc[1]:setProp("Discount",SC5->C5_DESC1)
			oObjDisc := ofwEAIObj:setprop('Discounts',{},'Discounts',,.T.)
			oObjDisc[2]:setProp("Discount",SC5->C5_DESC2)
			oObjDisc := ofwEAIObj:setprop('Discounts',{},'Discounts',,.T.)
			oObjDisc[3]:setProp("Discount",SC5->C5_DESC3)
			oObjDisc := ofwEAIObj:setprop('Discounts',{},'Discounts',,.T.)
			oObjDisc[4]:setProp("Discount",SC5->C5_DESC4)
			If !Empty( SC5->C5_TABELA )
				ofwEAIObj:setprop("PriceTableNumber",cEmpAnt + "|" + RTrim(xFilial("DA0")) + "|" + SC5->C5_TABELA)
			Endif
			
			// Transportadora
			If !Empty( SC5->C5_TRANSP )
				ofwEAIObj:setprop("CarrierCode", cEmpAnt + "|" + RTrim(xFilial("SA4")) + "|" + SC5->C5_TRANSP)
			Endif

			// Mensagem do pedido/nota
			If !Empty( SC5->C5_MENNOTA )
				ofwEAIObj:setprop( "InvoiceMessage", RTrim(SC5->C5_MENNOTA) )
			Endif
			
			// Nota 
			ofwEAIObj:setprop( "InvoiceNumber", RTrim(SC5->C5_NOTA) )
			ofwEAIObj:setprop( "InvoiceSerie", RTrim(SC5->C5_SERIE) )

			If lWorkCode
		         //Codigo da Obra - Utilizamos o codigo da obra externo.
				If !Empty( SC5->C5_CNO )
					SON->(DbSetOrder(1))
					If SON->( MsSeek( xFilial("SON") + SC5->C5_CNO ) )
						cSONCodExt := SON->ON_CNO
					EndIf
				EndIf
		
				ofwEAIObj:setprop("WorkCode",cSONCodExt)
			EndIf
	        
	         // Itens Pedido de Venda
			SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	
			If SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM))
				While SC6->(!EOF()) .And. SC6->C6_FILIAL + SC6->C6_NUM == SC5->C5_FILIAL + SC5->C5_NUM

					oObjItem := ofwEAIObj:setprop('SalesOrderItens',{},'Item',,.T.)
					nCtItem := Len( oObjItem )
					oObjItem[nCtItem]:setprop("InternalId", IntPdVExt(cEmpAnt, xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, cPdVVer)[2],,.T.)
					oObjItem[nCtItem]:setprop("CompanyId", cEmpAnt,,.T.)
					oObjItem[nCtItem]:setprop("BranchId", RTrim(cFilAnt),,.T.)
					oObjItem[nCtItem]:setprop("OrderId", RTrim(SC6->C6_NUM),,.T.)
					oObjItem[nCtItem]:setprop("OrderItem", RTrim(SC6->C6_ITEM),,.T.)
					oObjItem[nCtItem]:setprop("ItemCode", RTrim(SC6->C6_PRODUTO),,.T.)
					oObjItem[nCtItem]:setprop("ItemDescription", RTrim(SC6->C6_DESCRI),,.T.)
					oObjItem[nCtItem]:setprop("ItemInternalId", IntProExt(/*cEmpresa*/, /*cFilial*/, SC6->C6_PRODUTO)[2],,.T.)
					oObjItem[nCtItem]:setprop("ItemUnitOfMeasure", RTrim(SC6->C6_UM),,.T.)
					oObjItem[nCtItem]:setprop("UnitOfMeasureInternalId", IntUndExt(/*Empresa*/, /*Filial*/, SC6->C6_UM, cUndVer)[2],,.T.)
					oObjItem[nCtItem]:setprop("Quantity", SC6->C6_QTDVEN,,.T.)
					oObjItem[nCtItem]:setprop("QuantityReached", "",,.T.)
					oObjItem[nCtItem]:setprop("UnityPrice", SC6->C6_PRCVEN,,.T.)
					oObjItem[nCtItem]:setprop("TotalPrice", SC6->C6_VALOR,,.T.)
					oObjItem[nCtItem]:setprop("CostCenterCode", "",,.T.)
					oObjItem[nCtItem]:setprop("CostCenterInternalId", "",,.T.) 
					oObjItem[nCtItem]:setprop("ItemDiscounts")
					oObjItem[nCtItem]:getPropValue("ItemDiscounts"):setprop("ItemDiscount", SC6->C6_VALDESC,,.T.) 
					oObjItem[nCtItem]:setprop("WarehouseInternalId", IntLocExt(/*Empresa*/, /*Filial*/, SC6->C6_LOCAL)[2],,.T.)
					oObjItem[nCtItem]:setprop("TypeOperation", RTrim(SC6->C6_TES),,.T.)
					oObjItem[nCtItem]:setprop("RequestItemInternalId", "",,.T.)
					oObjItem[nCtItem]:setprop("InvoicingDate", Transform(DtoS( SC6->C6_DATFAT ),'@R 9999-99-99'),,.T.)
					oObjItem[nCtItem]:setprop("DeliveryDate", Transform(DtoS( SC6->C6_ENTREG ),'@R 9999-99-99'),,.T.)
	           		oObjItem[nCtItem]:setprop("InvoiceNumber", RTrim(SC6->C6_NOTA),,.T.)
					oObjItem[nCtItem]:setprop("InvoiceSerie" , RTrim(SC6->C6_SERIE),,.T.)
					oObjItem[nCtItem]:setprop("AlloccatedQuantity", SC6->C6_QTDEMP,,.T.)
					oObjItem[nCtItem]:setprop("QuantityDelivered", SC6->C6_QTDENT,,.T.)
	               // Integração com o TOTVS Obras e Projetos
					If IsIntegTop()
						aRateio := RatPV(SC6->C6_FILIAL + SC6->C6_NUM + SC6->C6_CLI + SC6->C6_LOJA + SC6->C6_ITEM)
						
						If Len( aRateio ) > 0

							For nI := 1 To Len(aRateio)
								oObjItem[nCtItem]:setprop('ListOfApportionOrderItem',{},'ApportionOrderItem',,.T.)
								oObjItem[nCtItem]:get("ListOfApportionOrderItem")[nI]:setprop("InternalId", IntPdVExt(cEmpAnt, xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, cPdVVer)[2],,.T.)
								oObjItem[nCtItem]:get("ListOfApportionOrderItem")[nI]:setprop("DepartamentCode", "",,.T.)
								oObjItem[nCtItem]:get("ListOfApportionOrderItem")[nI]:setprop("DepartamentInternalId", "",,.T.)
								oObjItem[nCtItem]:get("ListOfApportionOrderItem")[nI]:setprop("CostCenterInternalId", IIf(!Empty(aRateio[nI][1]), IntCusExt(/*cEmpresa*/, /*cFilial*/, aRateio[nI][1], /*cCosVer*/)[2], ''),,.T.)
								oObjItem[nCtItem]:get("ListOfApportionOrderItem")[nI]:setprop("ProjectInternalId", IIf(!Empty(aRateio[nI][6]), IntPrjExt(/*cEmpresa*/, /*cFilial*/, aRateio[nI][6])[2], ''),,.T.)
								oObjItem[nCtItem]:get("ListOfApportionOrderItem")[nI]:setprop("SubProjectInternalId", "",,.T.)
								oObjItem[nCtItem]:get("ListOfApportionOrderItem")[nI]:setprop("TaskInternalId", IIf(!Empty(AllTrim(aRateio[nI][7])), IntTrfExt(/*cEmpresa*/, /*cFilial*/, aRateio[nI][6], '0001', aRateio[nI][7])[2], ''),,.T.)
								If Empty(aRateio[nI][5]) .Or. aRateio[nI][5] == 0
									oObjItem[nCtItem]:get("ListOfApportionOrderItem")[nI]:setprop("Value", 0,,.T.)
								Else
									oObjItem[nCtItem]:get("ListOfApportionOrderItem")[nI]:setprop("Value", (aRateio[nI][5] * SC6->C6_PRCVEN * SC6->C6_QTDVEN / 100),,.T.)
								Endif
								oObjItem[nCtItem]:get("ListOfApportionOrderItem")[nI]:setprop("Percentual", aRateio[nI][5],,.T.)
								oObjItem[nCtItem]:get("ListOfApportionOrderItem")[nI]:setprop("Quantity", aRateio[nI][8],,.T.)
								oObjItem[nCtItem]:get("ListOfApportionOrderItem")[nI]:setprop("Observation", "",,.T.)
							Next nI

						Endif
	
					Else
	                  // Rateio por Centro de Custo
						If SC6->C6_RATEIO == '1'
							AGG->(DbSetOrder(1)) // AGG_FILIAL+AGG_PEDIDO+AGG_FORNEC+AGG_LOJA+AGG_ITEMPD+AGG_ITEM
	
							If AGG->(DbSeek(xFilial('SC6') + SC6->C6_NUM + SC6->C6_CLI + SC6->C6_LOJA + SC6->C6_ITEM))
	
								While AGG->(!EOF() .And. AGG->AGG_FILIAL + AGG->AGG_PEDIDO + AGG->AGG_FORNEC + AGG->AGG_LOJA + AGG->AGG_ITEMPD == xFilial('SC6') + SC6->C6_NUM + SC6->C6_CLI + SC6->C6_LOJA + SC6->C6_ITEM)
									nContAGG++	
									oObjItem[nCtItem]:setprop('ListOfApportionOrderItem',{},'ApportionOrderItem',,.T.)
									oObjItem[nCtItem]:get("ListOfApportionOrderItem")[nContAGG]:setprop("InternalId", IntPdVExt(cEmpAnt, xFilial('AGG'), AGG->AGG_PEDIDO, AGG->AGG_ITEMPD, cPdVVer)[2] + '|' + RTrim(AGG->AGG_ITEM),,.T.)
									oObjItem[nCtItem]:get("ListOfApportionOrderItem")[nContAGG]:setprop("CostCenterInternalId", IIf(!Empty(AllTrim(AGG->AGG_CC)), IntCusExt(/*cEmpresa*/, /*cFilial*/, AGG->AGG_CC, cCosVer)[2], ''),,.T.)
									oObjItem[nCtItem]:get("ListOfApportionOrderItem")[nContAGG]:setprop("AccountantAcountInternalId", IIf(!Empty(AGG->AGG_CONTA), cEmpAnt + "|" + xFilial("CT1") + "|" + AllTrim(AGG->AGG_CONTA), ''),,.T.)
									oObjItem[nCtItem]:get("ListOfApportionOrderItem")[nContAGG]:setprop("Percentual", AGG->AGG_PERC,,.T.)
								
									AGG->(DbSkip())
								EndDo
	
							EndIf
						EndIf
					EndIf
	
					SC6->(dbSkip())
				EndDo
	
				SC6->(dbCloseArea())
			EndIf
	
		EndIf
	
	EndIf

	AdpLogEAI(5, "MATI410", ofwEAIObj, lRet)
	
Return  {lRet, ofwEAIObj, cMsgUnica}

// --------------------------------------------------------------------------------------
/*/{Protheus.doc} getTpFre
Faz o de/para do Tipo de Frete

@param   cTipo      Tipo do frete
@param   nTypeTrans Tipo da transação

@author  Leandro Luiz da Cruz
@version P11
@since   06/06/2013
@return  cResult Variavel com o valor obtido
/*/
// --------------------------------------------------------------------------------------
Static Function getTpFre(cTipo, nTypeTrans)
   Local cResult := ""

   If nTypeTrans == TRANS_RECEIVE
      Do Case
         Case cTipo == "1"
            cResult := "C" //CIF
         Case cTipo == "2"
            cResult := "F" //FOB
         Case cTipo == "3"
            cResult := "S" //SFT
		 Case cTipo == '4'
            cResult := "T" //SFT
		 Case cTipo == '5'
            cResult := "R" //SFT
		 Case cTipo == '6'	
            cResult := "D" //SFT
      EndCase
   ElseIf nTypeTrans == TRANS_SEND
      Do Case
         Case cTipo == "C" //CIF
            cResult := "1"
         Case cTipo == "F" //FOB
            cResult := "2"
         Case cTipo == "S" //STF
            cResult := "3"
		Case cTipo == 'T'
            cResult := "4" //SFT
		 Case cTipo == 'R'
            cResult := "5" //SFT
		 Case cTipo == 'D'	
            cResult := "6" //SFT	
      EndCase
   EndIf
Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} RatPV
Recebe a chave de busca do Pedido de Venda e monta o rateio.

@author  Leandro Luiz da Cruz
@version P11
@since   13/06/2013

@return aResult
/*/
//-------------------------------------------------------------------
Static Function RatPV(cChave)
   Local aResult  := {}
   Local aPrjtTrf := {}
   Local aCntrCst := {}
   Local nI       := 0

   AGG->(DbSetOrder(1)) // Rateio por Centro de Custo - AGG_FILIAL+AGG_PEDIDO+AGG_FORNEC+AGG_LOJA+AGG_ITEMPD+AGG_ITEM

   //Povoa o array de Centro de Custo
   If Upper(SC6->C6_RATEIO) == '1' //Possui rateio por Centro de Custo
      If AGG->(dbSeek(cChave))
         While AGG->(!EOF()) .And. AGG->AGG_FILIAL + AGG->AGG_PEDIDO + AGG->AGG_FORNEC + AGG->AGG_LOJA + AGG->AGG_ITEMPD == cChave
            aAdd(aCntrCst, Array(5))
            nI++
            aCntrCst[nI][1] := AGG->AGG_CC
            aCntrCst[nI][2] := AGG->AGG_CONTA
            aCntrCst[nI][3] := AGG->AGG_ITEMCT
            aCntrCst[nI][4] := AGG->AGG_CLVL
            aCntrCst[nI][5] := AGG->AGG_PERC
            AGG->(dbSkip())
         EndDo
      EndIf
   EndIf

   // Não há Rateio por Projeto/Tarefa no Pedido de Venda.
   // Aqui estão sendo passados os dados de Projeto/Tarefa do item
   aAdd(aPrjtTrf, {SC6->C6_PROJPMS, Nil, SC6->C6_TASKPMS, SC6->C6_QTDVEN})

   aResult := IntRatPrjCC(aCntrCst, aPrjtTrf)
Return aResult


//--------------------------------------------------------------------
/*/{Protheus.doc} Adiantamento
Recebe uma condição de pagamento e retorna se ela é do tipo adiantamento.

@param   cCond Código da condição de pagamento.

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   10/12/2013
@return  cResult Valor lógico indicando se a condição de pagamento é do
          tipo adiantamento.
/*/
//--------------------------------------------------------------------
Static Function Adiantamento(cCond)
   Local cResult    := .F.
   Local cE4_CTRADT := ""

   cE4_CTRADT := Posicione("SE4", 1, xFilial("SE4") + PadR(cCond, TamSX3("E4_CODIGO")[1]), "E4_CTRADT")

   If cE4_CTRADT == "1"
      cResult := .T.
   EndIf
Return cResult

//--------------------------------------------------------------------
/*/{Protheus.doc} GetCurrId
Get Currency ID - Utilizado para identificar se o id da moeda já existe,
antes de acrescentar '0'. 

@param   cAux   , Char, Código da Moeda 
@param   cMarca , Char, Marca da integração 
@param   cMoeVer, Char, Versão do Adapter Currency

@author  Squad CRM/Faturamento
@version P12
@since   19/06/2018
@return  IntMoeInt() função que retorna os dados da moeda. 
/*/
//--------------------------------------------------------------------
Static Function GetCurrId(cAux, cMarca, cMoeVer)
   If Empty( CFGA070Int( cMarca, 'CTO', 'CTO_MOEDA', cAux) )
        cAux := SubStr(cAux,1,Len(cAux)-2) + PadL(cAux, 2, "0")
    EndIf
Return IntMoeInt(cAux, cMarca, cMoeVer)
