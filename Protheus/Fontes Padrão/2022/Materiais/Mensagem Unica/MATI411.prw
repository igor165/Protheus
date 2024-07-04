#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'
#Include 'MATI411.CH'


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³ MATI411     º Autor ³ Jefferson Tomaz    º Data ³ 15/08/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Funcao de integracao com o adapter EAI para recebimento de   º±±
±±º          ³ dados do pedido de venda (SC5) e itens do pedido (SC6)       º±±
±±º          ³ utilizando o conceito de mensagem unica.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Param.   ³ cXML - Variavel com conteudo xml para envio/recebimento.     º±±
±±º          ³ nTypeTrans - Tipo de transacao. (Envio/Recebimento)          º±±
±±º          ³ cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc) º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno  ³ aRet - Array contendo o resultado da execucao e a mensagem   º±±
±±º          ³        Xml de retorno.                                       º±±
±±º          ³ aRet[1] - (boolean) Indica o resultado da execução da função º±±
±±º          ³ aRet[2] - (caracter) Mensagem Xml para envio                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ MATA410                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATI411( cXML, nTypeTrans, cTypeMessage )

Local lRet     	:= .T.
Local lBuscaPed	:= Nil
Local aCab			:= {}
Local aItens		:= {}
Local aErroAuto	:= {}
Local nCount      := 0
Local nPrcVen     := 0 
Local nOpcx			:= 0 
Local nContAux    := 0
Local nValDesc    := 0
Local nContAux2   := 0
Local nValor      := 0
Local nItens      := 1
Local cLogErro 	:= ""
Local cXMLRet  	:= ""
Local cError		:= ""
Local cWarning 	:= ""
Local cInfAd      := ""
Local cMenNota    := ""
Local cNfOri      := ""
Local cSerieOri   := ""
Local cItemOri    := ""
Local nQtdeOri    := 0 
Local cProd       := "" 
Local cIdentB6    := ""  
Local nTamSX3ITEM := TamSx3("C6_ITEM")[1]
Local cOrderItem  := StrZero(0, nTamSX3ITEM) 
Local cData       := "" 
Local cTes        := ""
Local cValExt     := "" 
Local cValInt     := ""
Local cMarca      := ""
Local cItemCode   := "" 
Local cCodCli     := ""
Local cLojCli     := "" 
Local cCodTransp	:= ""
Local cValExtPed  := ""
Local cValIntPed  := ""
Local cAlias      := "SC5"
Local cField      := "C5_NUM"
Local cNatOpera   := ""
Local aTpOpera    := {}

Private oXmlM410		  := Nil
Private nCountM410	  := 1
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T. 

If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS
		
		oXmlM410 := XmlParser(cXml, "_", @cError, @cWarning) 
		
		If oXmlM410 <> Nil .And. Empty(cError) .And. Empty(cWarning) 
		   
			Begin Transaction
				
			If Type("oXmlM410:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U" 					
				cMarca :=  oXmlM410:_TotvsMessage:_MessageInformation:_Product:_Name:Text
			EndIf
			
			Aadd(aCab,{"C5_FILIAL" ,xFilial("SC5") , Nil })
		
			If Upper(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
				//InternalId do pedido
           	If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. !Empty(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
              	cValExtPed := oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
              		
              	//Obtém o InternalId
              	cValIntPed := RTrim(CFGA070INT(cMarca, cAlias, cField, cValExtPed))
              		
              	If !Empty(cValIntPed)
                		AAdd(aCab, { 'C5_NUM',  PadR(cValIntPed, TamSX3("C5_NUM")[1]),         Nil})
                		nOpcx := 4 //UPDATE
              	Else
                		nOpcx := 3 //INSERT
              	EndIf
             	ElseIf Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderId:Text") <> "U"
					If Empty(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderId:Text)
						nOpcx:= 3
					Else
						cValIntPed := oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderId:Text
						nOpcx:= 4
					EndiF
				Else
					nOpcx := 3
				Endif
			ElseIf Upper(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
				nOpcx := 5
				If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") <> "U"
					If !Empty(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
           			cValExtPed := oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
           
           			//Obtém o InternalId
           			cValIntPed := RTrim(CFGA070INT(cMarca, cAlias, cField, cValExtPed))
           
           			If !Empty(cValIntPed)
                  		AAdd(aCab, { 'C5_NUM', PadR(cValIntPed, TamSX3("C5_NUM")[1]), Nil})
              		Endif
              	Endif
              Elseif Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderID:Text") <> "U"
					If !Empty(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderID:Text)
						cValIntPed := oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderId:Text
               		Aadd(aCab,{"C5_NUM",cValIntPed, Nil })
               	Endif
              Endif
			EndIf
			
			If nOpcx <> 5
				
				Aadd(aCab,{"C5_TIPO"			,"N"				           	, Nil })
				
				 
				If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text") <> "U"					
					//--------------------------------------------------------------------------------------
					//-- Tratamento utilizando a tabela XXF com um De/Para de codigos   
					//--------------------------------------------------------------------------------------
					cValExt := AllTrim(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text)  
				   	cValInt := CFGA070INT( cMarca ,  "SA1", "A1_COD" , cValExt ) 					    
				   	cCodCli := Substr(cValInt,1,TamSX3('A1_COD')[1])
				  	cLojCli := Substr(cValInt,TamSX3('A1_COD')[1]+1,TamSX3('A1_LOJA')[1])   
				  		
				   	Aadd(aCab,{"C5_CLIENTE"		,cCodCli		           	, Nil })
					Aadd(aCab,{"C5_LOJACLI"		,cLojCli		           	, Nil })							   
				   
				   	If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DeliveryCustomerCode:Text") <> "U"
						If Alltrim(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text) == AllTrim(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DeliveryCustomerCode:Text)
							Aadd(aCab,{"C5_CLIENT"		,cCodCli		           	, Nil })
							Aadd(aCab,{"C5_LOJAENT"		,cLojCli		           	, Nil })
						Else
							If !Empty( cValInt := CFGA070INT(cMarca,"SA1","A1_COD",oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DeliveryCustomerCode:Text))		
								cCodCli := Substr(cValInt,1,TamSX3('A1_COD')[1])
								cLojCli := Substr(cValInt,TamSX3('A1_COD')[1]+1,TamSX3('A1_LOJA')[1])						
							
								Aadd(aCab,{"C5_CLIENT"		,cCodCli		        	, Nil })
								Aadd(aCab,{"C5_LOJAENT"		,cLojCli		        	, Nil })					
							EndIf							
						EndIf
					EndIf					    
				EndIf
				
				If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CarrierCode:Text") <> "U" 
					If !Empty( cCodTransp := AllTrim(CFGA070INT( cMarca , "SA4" , "A4_COD", oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CarrierCode:Text )) )
						Aadd(aCab,{"C5_TRANSP"			,cCodTransp          	, Nil })
					EndIf
				EndIf
				If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentTermCode:Text") <> "U"
					Aadd(aCab,{"C5_CONDPAG"		     ,oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentTermCode:Text       , Nil })
				EndIf 
				If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialDiscount:Text") <> "U"
					Aadd(aCab,{"C5_DESCFI"			,Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialDiscount:Text)  , Nil })
				EndIf
				If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text") <> "U"
					//--Tratamento para data no formato Ano/Mes/Dia
					cData := oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text					
					Aadd(aCab,{"C5_EMISSAO"			,  cTod( Substr( cData, 9, 2 ) + '/' + SubStr( cData, 6, 2 ) + '/' + SubStr( cData, 1, 4 ) )    , Nil })
				EndIf
				If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:Text") <> "U"
					Aadd(aCab,{"C5_TPFRETE"			,oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:Text          	, Nil })
				EndIf
				If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightValue:Text") <> "U"
					Aadd(aCab,{"C5_FRETE"			,Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightValue:Text)     	, Nil })
				EndIf
				If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RedeliveryCarrierCode:Text") <> "U"
					Aadd(aCab,{"C5_REDESP"			,oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RedeliveryCarrierCode:Text	, Nil })
				EndIf
				
				If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceMessages:_InvoiceMessage") <> "U"
					If ValType(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceMessages:_InvoiceMessage) <> "A" 						
						XmlNode2Arr(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceMessages:_InvoiceMessage, "_InvoiceMessage")
					EndIf	
					For nContAux := 1 To Len(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceMessages:_InvoiceMessage)
						If !Empty(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceMessages:_InvoiceMessage[nContAux]:Text)
							cMenNota += oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceMessages:_InvoiceMessage[nContAux]:Text 		
						EndIf
					Next nCountAux  
					
					If !Empty(cMenNota)
						Aadd(aCab,{"C5_MENNOTA"			,cMenNota			, Nil })
					EndIf
				EndIf

				If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InsuranceValue:Text") <> "U"  
					Aadd(aCab,{"C5_SEGURO"			,Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InsuranceValue:Text) 	 , Nil })
				EndIf
				If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetWeight:Text") <> "U"
					Aadd(aCab,{"C5_PESOL"			,Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetWeight:Text)	   	, Nil })
				EndIf
				If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GrossWeight:Text") <> "U"
					Aadd(aCab,{"C5_PBRUTO"			,Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GrossWeight:Text)	   	, Nil })
				EndIf                                                                                                                
				If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NumberOfVolumes:Text") <> "U"
					Aadd(aCab,{"C5_VOLUME1"			,Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NumberOfVolumes:Text)   , Nil })
				EndIf                                                                                                                  
				
				Aadd(aCab,{"C5_ORIGEM","MSGEAI", Nil })
				
				If ValType(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item) <> "A"
					XmlNode2Arr(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item, "_ITEM")
				EndIf
				
				For nCount:= 1 To Len(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item)
					nCountM410 := nCount  
					
					If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+Str(nCountM410) + "]:_ListOfReturnedInputDocuments:_ReturnedInputDocument") <> "U"
						
						If ValType(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ListOfReturnedInputDocuments:_ReturnedInputDocument) <> "A" 
							XmlNode2Arr(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ListOfReturnedInputDocuments:_ReturnedInputDocument,"_ReturnedInputDocument")
						EndIf
						
						For nContAux := 1 To Len(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ListOfReturnedInputDocuments:_ReturnedInputDocument)
				
							Aadd(aItens, {})
							nValDesc   := 0
							cInfAd     := ""

							cOrderItem := RetAsc(Soma1(cOrderItem), nTamSX3ITEM,.T.)
						   
							Aadd(aItens[nItens], {"C6_FILIAL"	 ,xFilial("SC6"), Nil })						   														
							Aadd(aItens[nItens], {"C6_ITEM"		 , cOrderItem   , Nil })
							
							If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_ItemCode:Text") <> "U"					
								cItemCode := oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemCode:Text
								cProd     := CFGA070INT( cMarca ,  "SB1" ,"B1_COD", cItemCode )
								cProd     := PADR(cProd, TamSX3("B1_COD")[1])
								Aadd(aItens[nItens], {"C6_PRODUTO", cProd        , Nil })
							EndIf 
							If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_NatureOperation:Text") <> "U"
								cNatOpera := AllTrim(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_NatureOperation:Text)
							Endif
							
							//Busca Tipo de Operação (Protheus)
							aTpOpera := A411TPOPER(cNatOpera)
							
							If !aTpOpera[1]
								cXMLRet	:= aTpOpera[2]
								lRet		:= .F.
								Exit
							Else
								If !Empty(aTpOpera[2])
									cTes := MaTesInt(2,aTpOpera[2],cCodCli,cLojCli,"C",AllTrim(cProd),"")
										
									If Empty(cTes)
										cTes := MaTesInt(2,"IT",cCodCli,cLojCli,"C",AllTrim(cProd),"")
										
										If Empty(cTes)
											If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_TypeOperation:Text") <> "U"
												cTes := AllTrim(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_TypeOperation:Text)
											Endif
										Endif
									Endif
									
									Aadd(aItens[nItens], {"C6_TES"	,cTes	 , Nil })
								Else
									cTes := MaTesInt(2,"IT",cCodCli,cLojCli,"C",AllTrim(cProd),"")
										
									If Empty(cTes)
										If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_TypeOperation:Text") <> "U"
											cTes := AllTrim(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_TypeOperation:Text)
										Endif
									Endif
									
									Aadd(aItens[nItens], {"C6_TES"	,cTes	 , Nil })
								Endif							
							Endif
							If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_ListOfReturnedInputDocuments:_ReturnedInputDocument[" + STR(nContAux) +"]:_InputDocumentQuantity:Text") <> "U"
						      //-- Quantidade retornada por nota de entrada
						      nQtdeOri := Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ListOfReturnedInputDocuments:_ReturnedInputDocument[nContAux]:_InputDocumentQuantity:Text)
						      nQtdeOri := A410Arred(nQtdeOri,"C6_QTDVEN")
							EndIf 
							If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_Quantity:Text") <> "U"					
								Aadd(aItens[nItens], {"C6_QTDVEN", nQtdeOri   	 , Nil })
								Aadd(aItens[nItens], {"C6_QTDLIB", 0             , Nil })
							EndIf
							If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_UnityPrice:Text") <> "U"												
								nPrcVen := Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_UnityPrice:Text)
								nPrcVen := A410Arred(nPrcVen,"C6_PRCVEN")
								Aadd(aItens[nItens], {"C6_PRCVEN",nPrcVen			 , Nil })							
							EndIf	
							If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_TotalPrice:Text") <> "U"												
								nValor := A410Arred(nQtdeOri*nPrcVen,"C6_VALOR")
								Aadd(aItens[nItens], {"C6_VALOR"	,nValor			 , Nil })
							EndIf							                                                                                                                                                              
							If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_ItemDescription:Text") <> "U"
								Aadd(aItens[nItens], {"C6_DESCRI"	,oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDescription:Text	   	, Nil })
							EndIf
							If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_DeliveryDate:Text") <> "U"
								Aadd(aItens[nItens], {"C6_ENTREG"	,CtoD(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_DeliveryDate:Text)		, Nil })
							EndIf
							If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_OrderID:Text") <> "U"
								Aadd(aItens[nItens], {"C6_NUM"		,oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_OrderID:Text						, Nil })
							EndIf
							If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_CustomerOrderNumber:Text") <> "U"
								Aadd(aItens[nItens], {"C6_PEDCLI"	,oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_CustomerOrderNumber:Text		, Nil })
							EndIf
							If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_DiscountPercentage:Text") <> "U"
								If Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_DiscountPercentage:Text) > 0
									Aadd(aItens[nItens], {"C6_DESCONT"	,Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_DiscountPercentage:Text) , Nil })
								Endif
							EndIf 
						
							If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[" +STR(nCountM410) +"]:_ItemDiscounts:_ItemDiscount") <> "U"
								If ValType(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount) <> "A"
									XmlNode2Arr(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount, "_ItemDiscount")
								EndIf	
								For nContAux2 := 1 To Len(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount)  
									If !Empty(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount[nContAux2]:Text)
										nValDesc += Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount[nContAux2]:Text) 	
									EndIf
								Next nContAux2
								
								If nValDesc <> 0
								  nValDesc := Round(nValDesc,TamSx3("C6_VALDESC")[2])
								  Aadd(aItens[nItens], {"C6_VALDESC"	, nValDesc , Nil})
								EndIf 
							EndIf
				
							If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_ListOfReturnedInputDocuments:_ReturnedInputDocument["+ STR(nContAux) +"]:_InputDocumentNumber:Text") <> "U"
								cNfOri := PADR(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ListOfReturnedInputDocuments:_ReturnedInputDocument[nContAux]:_InputDocumentNumber:Text,TamSx3("D1_DOC")[1] )
							   Aadd(aItens[nItens], {"C6_NFORI" , cNfOri , NIL })  
							EndIf
							If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_ListOfReturnedInputDocuments:_ReturnedInputDocument["+ STR(nContAux) +"]:_InputDocumentSerie:Text") <> "U"
						   	cSerieOri := PADR(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ListOfReturnedInputDocuments:_ReturnedInputDocument[nContAux]:_InputDocumentSerie:Text, TamSx3("D1_SERIE")[1])						
						    	Aadd(aItens[nItens], {"C6_SERIORI" , cSerieOri , NIL }) 
						   EndIf
						   If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_ListOfReturnedInputDocuments:_ReturnedInputDocument["+ STR(nContAux) +"]:_InputDocumentSequence:Text") <> "U"
						     	cItemOri := oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ListOfReturnedInputDocuments:_ReturnedInputDocument[nContAux]:_InputDocumentSequence:Text
						      cItemOri := StrZero(Val(cItemOri), TamSX3("D1_ITEM")[1])
						      Aadd(aItens[nItens], {"C6_ITEMORI" , cItemOri , NIL }) 
						   EndIf
						   
							SD1->(dbSetOrder(1)) //-- D1_FILIAL + D1_DOC + D1_SERIE +  D1_FORNEC + D1_LOJA  + D1_COD + D1_ITEM
							If SD1->(MsSeek( xFilial("SD1") + cNfOri + cSerieOri+ cCodCli + cLojCli + cProd  + cItemOri))
								If SD1->D1_VALDESC > 0
									If nQtdeOri <> SD1->D1_QUANT
										nValDesc := Round((nQtdeOri*Round(SD1->D1_VALDESC,TamSx3("C6_VALDESC")[2]))/SD1->D1_QUANT,TamSx3("C6_VALDESC")[2])
									Else
										nValDesc := Round(SD1->D1_VALDESC,TamSx3("C6_VALDESC")[2])
									Endif
									
									nPos := aScan(aItens[nItens],{|x| Alltrim(x[1]) == "C6_VALDESC"})
									If nPos > 0
										aItens[nItens,nPos,2] := nValDesc
									Else
										Aadd(aItens[nItens], {"C6_VALDESC" , nValDesc , NIL })
									Endif
								Endif
								cIdentB6 := SD1->D1_IDENTB6
								Aadd(aItens[nItens], {"C6_IDENTB6" , cIdentB6 , NIL }) 
							EndIf 								
							
							If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[" + STR(nCountM410) +" ]:_ItemMessages:_ItemMessage") <> "U" ;
								.And. SC6->(FieldPos('C6_CODINF')) > 0    
								If ValType(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemMessages:_ItemMessage) <> "A" 
									XmlNode2Arr(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemMessages:_ItemMessage, "_ItemMessage")
								EndIf	
								For nContAux2 := 1 To Len(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemMessages:_ItemMessage)
									If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[" + STR(nCountM410) +"]:_ItemMessages:_ItemMessage[" + STR(nContAux2) + "]:Text") <> "U"
										cInfAd += oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemMessages:_ItemMessage[nContAux2]:Text 		
									EndIf
								Next nContAux2
								
								If !Empty(cInfAd)
								  Aadd(aItens[nItens], {"C6_INFAD"	,cInfAd , Nil })
								EndIf
							EndIf 	 
													
							//-- Tag criada para realizar o vinculo entre um pedido de retorno simbólico e um pedido de venda de conta e ordem
							If  SC6->( FieldPos("C6_PEDVINC") ) > 0 .And. Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_AccountOrderId:Text") <> "U" 						
						    	Aadd(aItens[nItens], {"C6_PEDVINC" , oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_AccountOrderId:Text , NIL }) 
						    EndIf																	
							
							nItens := nItens + 1
							
						Next nContAux			
					
					Else 
					
						Aadd(aItens, {})
						nValDesc   := 0
						cInfAd     := ""	
									
						Aadd(aItens[nItens], {"C6_FILIAL"	,xFilial("SC6")					                                                          	      										, Nil })
						If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_OrderItem:Text") <> "U"
							cOrderItem := oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_OrderItem:Text
							cOrderItem := RetAsc(cOrderItem, nTamSX3ITEM,.T.)
							Aadd(aItens[nItens], {"C6_ITEM",	   cOrderItem ,Nil })
						EndIf
						If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_ItemCode:Text") <> "U"					
							cItemCode := oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemCode:Text
							cProd     := CFGA070INT( cMarca ,  "SB1","B1_COD" , cItemCode )
							cProd     := PADR(cProd, TamSX3("B1_COD")[1])
							Aadd(aItens[nItens], {"C6_PRODUTO", cProd      ,Nil })
						EndIf
						If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_Quantity:Text") <> "U"					
							nQtdeOri := A410Arred(Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_Quantity:Text),"C6_QTDVEN") 					
							Aadd(aItens[nItens], {"C6_QTDVEN" ,nQtdeOri, Nil })
							Aadd(aItens[nItens], {"C6_QTDLIB" , 0          ,Nil})
						EndIf
						If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_UnityPrice:Text") <> "U"					
							nPrcVen := A410Arred(Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_UnityPrice:Text),"C6_PRCVEN") 					
							Aadd(aItens[nItens], {"C6_PRCVEN" , nPrcVen , Nil })
						EndIf
						If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_TotalPrice:Text") <> "U"					
							nValor := A410Arred(nQtdeOri*nPrcVen,"C6_VALOR")					
							Aadd(aItens[nItens], {"C6_VALOR"	,nValor, Nil })
						EndIf
						If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_NatureOperation:Text") <> "U"
							cNatOpera := AllTrim(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_NatureOperation:Text)
						Endif

						//Busca Tipo de Operação (Protheus)
						aTpOpera := A411TPOPER(cNatOpera)
							
						If !aTpOpera[1]
							cXMLRet	:= aTpOpera[2]
							lRet		:= .F.
							Exit
						Else
							If !Empty(aTpOpera[2])
								cTes := MaTesInt(2,aTpOpera[2],cCodCli,cLojCli,"C",AllTrim(cProd),"")
									
								If Empty(cTes)
									cTes := MaTesInt(2,"IT",cCodCli,cLojCli,"C",AllTrim(cProd),"")
									
									If Empty(cTes)
										If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_TypeOperation:Text") <> "U"
											cTes := AllTrim(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_TypeOperation:Text)
										Endif
									Endif
								Endif
								
								Aadd(aItens[nItens], {"C6_TES"	,cTes	 , Nil })
							Else
								cTes := MaTesInt(2,"IT",cCodCli,cLojCli,"C",AllTrim(cProd),"")
									
								If Empty(cTes)
									If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_TypeOperation:Text") <> "U"
										cTes := AllTrim(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_TypeOperation:Text)
									Endif
								Endif
								
								Aadd(aItens[nItens], {"C6_TES"	,cTes	 , Nil })
							Endif							
						Endif                                                                                                                                                             
						If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_ItemDescription:Text") <> "U"
							Aadd(aItens[nItens], {"C6_DESCRI"	,oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDescription:Text	   	, Nil })
						EndIf
						If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_DeliveryDate:Text") <> "U"
							Aadd(aItens[nItens], {"C6_ENTREG"	,CtoD(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_DeliveryDate:Text)		, Nil })
						EndIf
						If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_OrderID:Text") <> "U"
							Aadd(aItens[nItens], {"C6_NUM"		,oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_OrderID:Text						, Nil })
						EndIf
						If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_CustomerOrderNumber:Text") <> "U"
							Aadd(aItens[nItens], {"C6_PEDCLI"	,oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_CustomerOrderNumber:Text		, Nil })
						EndIf
						If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_DiscountPercentage:Text") <> "U"
							Aadd(aItens[nItens], {"C6_DESCONT"  ,Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_DiscountPercentage:Text) , Nil })
						EndIf 
						
						If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_ItemDiscounts:_ItemDiscount") <> "U"
							If ValType(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount) <> "A"
								XmlNode2Arr(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount, "_ItemDiscount")
							EndIf	
							For nContAux := 1 To Len(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount)  
								If !Empty(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount[nContAux]:Text)
									nValDesc += Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount[nContAux]:Text) 	
								EndIf
							Next nContAux
							
							If nValDesc <> 0
								Aadd(aItens[nItens], {"C6_VALDESC",nValDesc , Nil})
							EndIf 
						EndIf
						
						If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[" + STR(nCountM410) +" ]:_ItemMessages:_ItemMessage") <> "U" ;
							.And. SC6->(FieldPos('C6_CODINF')) > 0    
							If ValType(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemMessages:_ItemMessage) <> "A" 
								XmlNode2Arr(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemMessages:_ItemMessage, "_ItemMessage")
							EndIf	
							For nContAux2 := 1 To Len(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemMessages:_ItemMessage)
								If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[" + STR(nCountM410) +"]:_ItemMessages:_ItemMessage[" + STR(nContAux2) + "]:Text") <> "U"
									cInfAd += oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemMessages:_ItemMessage[nContAux2]:Text 		
								EndIf
							Next nContAux2
							
							If !Empty(cInfAd)
								Aadd(aItens[nItens], {"C6_INFAD"	,cInfAd , Nil })
							EndIf
						EndIf 	 
												
						//-- Tag criada para realizar o vinculo entre um pedido de retorno simbólico e um pedido de venda de conta e ordem
						If SC6->( FieldPos("C6_PEDVINC") ) > 0 .And. Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_AccountOrderId:Text") <> "U" 						
					    	Aadd(aItens[nItens], {"C6_PEDVINC" , oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_AccountOrderId:Text , NIL }) 
					   EndIf	
					
						nItens++				
					EndIf	
													
				Next nCount
				
		  	EndIf
			
			// ponto de entrada inserido para controlar dados especificos do cliente
		   If lRet .And. ExistBlock("MT411EAI")
			  	aRetPe := ExecBlock("MT411EAI",.F.,.F.,{aCab,aItens,nOpcx})
				If ValType(aRetPe) == "A" .And. Len(aRetPe) == 2 .And. ValType(aRetPe[1]) == "A" .And. ValType(aRetPe[2]) == "A" 
					aCab 	:= aClone(aRetPe[1])
					aItens := aClone(aRetPe[2])
				EndIf
	       EndIf
	       
			If lRet
				SC5->(DbSetOrder(1))
				If nOpcx == 5 
					If !ITFINDREG(cValIntPed)
						lRet := .F.
						cXMLRet := "001" + STR0003 //" - Pedido de venda não encontrado"
						DisarmTransaction()
					Endif
				Elseif nOpcx == 4
					If !ITFINDREG(cValIntPed)
						lRet := .F.
						cXMLRet := STR0004 //"Pedido de venda não encontrado"
						DisarmTransaction()
					Endif 
				Endif
			Endif
				
			If lRet
				MSExecAuto({|x,y,z|Mata410(x,y,z)},aCab,aItens,nOpcx)      
				
				If lMsErroAuto  
					aErroAuto := GetAutoGRLog()
					For nCount := 1 To Len(aErroAuto)
						cLogErro += _NoTags(aErroAuto[nCount]) 
					Next nCount
					// Monta XML de Erro de execução da rotina automatica.
					lRet := .F.
					cXMLRet := EncodeUTF8( cLogErro )
					DisarmTransaction()  
				Else
					SC5->(DbSetOrder(1))
					If nOpcx <> 5
						If nOpcx == 3
							lBuscaPed := ITFINDREG(SC5->C5_NUM)
						Else
							lBuscaPed := ITFINDREG(cValIntPed)
						Endif
						
						If !lBuscaPed
							lRet := .F.
							cXMLRet := STR0005 //"Pedido de venda não foi incluido ou alterado no Protheus" 
							DisarmTransaction()
						Endif 
					Endif
					
					If lRet
						If nOpcx == 3
							// Monta xml com status do processamento da rotina automatica OK.
							cXMLRet := "<OrderId>"+SC5->C5_NUM+"</OrderId>
						Else
							cXMLRet := "<OrderId>"+cValIntPed+"</OrderId>
						Endif
						
						If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. !Empty(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
							If nOpcx == 3
           					// Insere ou atualiza o registro na tabela XXF (de/para)
           					CFGA070Mnt(cMarca, cAlias, cField, cValExtPed, SC5->C5_NUM, .F., 1)
        					ElseIf nOpcx == 4
           					// Insere ou atualiza o registro na tabela XXF (de/para)
           					CFGA070Mnt(cMarca, cAlias, cField, cValExtPed, cValIntPed, .F., 1)
        					ElseIf nOpcx == 5
           					// Exclui o registro na tabela XXF (de/para)
           					CFGA070Mnt(cMarca, cAlias, cField, cValExtPed, cValIntPed, .T., 1)
        					EndIf
     					EndIf
					Endif
				EndIf
			Endif
		
			End Transaction
			
		Else
			// "Falha ao gerar o objeto XML"
			lRet := .F.
			cXMLRet := "Falha ao manipular o XML"
		EndIf
	
	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
		cXMLRet := '<TAGX>TESTE DE RECEPCAO RESPONSE MESSAGE</TAGX>'
	ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := '1.000'
	EndIf
	
ElseIf nTypeTrans == TRANS_SEND
	cXMLRet := '<TAGX>TESTE DE ENVIO</TAGX>'
EndIf

Return { lRet, cXMLRet }

/*/{Protheus.doc} ITFINDREG
Verifica existencia do registro e posiciona.

@param   cNumPed		Numero do pedido

@author  Rodrigo Machado Pontes
@version P11
@since   27/08/2015

@return lRet	- .T. Caso exista registro, .F. não existe registro
/*/
Static Function ITFINDREG(cNumPed) 

Local cQry	:= ""
Local lRet	:= .F.

cQry	:= " SELECT R_E_C_N_O_ AS REG"
cQry	+= " FROM " + RetSqlName("SC5") + " SC5"
cQry	+= " WHERE	SC5.C5_NUM 		= '" + cNumPed 	+ "'"
cQry	+= " AND 	SC5.D_E_L_E_T_	= ''"
cQry	+= " AND	SC5.C5_FILIAL		= '" + xFilial("SC5") + "'" 

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"SC5REG",.T.,.T.)

DbSelectArea("SC5REG")
SC5REG->(DbGotop())
If SC5REG->(!EOF())
	lRet := .T.
	
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(DbGoto(SC5REG->REG))
Endif

SC5REG->(DbCloseArea())

Return lRet

/*{Protheus.doc} A411TPOPER
De/Para da natureza de operação com tipo de operação (TES Inteligente)

@param   cNatOpera	Natureza de operação (Logix)

@author  Rodrigo M Pontes
@version P11
@since   02/03/16
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado no de/para
		 e validado existencia.
         No segundo parâmetro uma variável caracter com o tipo de
		 operação ou mensagem de erro.

*/

Static Function A411TPOPER(cNatOpera)

Local aRetTipo	:= {.T.,""}
Local cQry			:= ""
Local nTamTipo	:= TamSx3("FM_TIPO")[1]

If Select("TPOPER") > 0
	TPOPER->(DbCloseArea())
Endif

cQry	:= " SELECT X5_DESCRI"
cQry	+= " FROM " + RetSqlName("SX5")
cQry	+= " WHERE D_E_L_E_T_ = ''"
cQry	+= " AND X5_TABELA = 'IT'"
cQry	+= " AND X5_CHAVE = '" + cNatOpera + "'"

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TPOPER",.T.,.T.)

DbSelectArea("TPOPER")
If TPOPER->(!EOF())
	aRetTipo[1] := .T.
	aRetTipo[2] := SubStr(AllTrim(TPOPER->X5_DESCRI),1,nTamTipo)
Endif

TPOPER->(DbCloseArea())

If !Empty(aRetTipo[2])
	If Select("VLDTP") > 0
		VLDTP->(DbCloseArea())
	Endif
	
	cQry	:= " SELECT X5_DESCRI"
	cQry	+= " FROM " + RetSqlName("SX5")
	cQry	+= " WHERE D_E_L_E_T_ = ''"
	cQry	+= " AND X5_TABELA = 'DJ'"
	cQry	+= " AND X5_CHAVE = '" + aRetTipo[2] + "'"
	
	cQry := ChangeQuery(cQry)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"VLDTP",.T.,.T.)
	
	DbSelectArea("VLDTP")
	If VLDTP->(EOF())
		aRetTipo[1] := .F.
		aRetTipo[2] := "Tipo de Operação: " + aRetTipo[2] + " não encontrado no cadastro da tabela 'DJ' - SX5"
	Endif
	
	VLDTP->(DbCloseArea())
Endif

Return aRetTipo