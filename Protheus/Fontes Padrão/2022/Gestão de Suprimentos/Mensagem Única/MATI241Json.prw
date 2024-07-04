#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#Include "MATI240.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATI241O   ºAutor  ³Totvs Cascavel     º Data ³  20/06/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Funcao de integracao com o adapter EAI para baixa da       º±±
±±º          ³ movimentacao de estoque (Stockturnover) utilizando o 	  º±±
±±º          ³ conceito de mensagem unica.                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATI241O                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATI241Json( oEAIObEt, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj, a241ISD3 )
Local aArea			:= GetArea()
Local aAreaSD3		:= SD3->(GetArea())
Local aCab			:= {}
Local aItens		:= {}
Local atotitem		:= {}
Local aErroAuto		:= {}
Local aRateio		:= {}
Local aMatRet		:= {}
Local aResponse		:= {}
Local lRet			:= .T.
Local lUnitPrice	:= .F.
Local cXMLRet		:= ""
Local cLogErro		:= ""
Local cEvent		:= "upsert"
Local cXmlErro		:= ""
Local cXmlWarn		:= ""
Local cTpMov		:= ""
Local cProd			:= ""
Local cUnMed		:= ""
Local cArmzm		:= ""
Local cLote			:= ""
Local cSubLote		:= ""
Local cEnd			:= ""
Local cCostCenter	:= ""
Local cNumSer		:= ""
Local cProdExt		:= ""
Local cArmzmExt		:= ""
Local cUnMedExt		:= ""
Local nCount		:= 0
Local nOpcx			:= 0
Local nQuant		:= 0
Local nX1			:= 1
Local nCont			:= 0
Local nX			:= 0
Local nTamB1Cod		:= 0
Local nTamF5Cod     := 0
Local nTamAHCod     := 0
Local nTamNNRCod    := 0
Local nTamB8Lote    := 0
Local nTamB8SubL    := 0
Local nTamCTTCod    := 0
Local dtEmiss		:= CToD("")
Local dtValLot		:= CToD("")
Local dtEmiCab   	:= CToD("")

//Variaveis utilizadas no De/Para de Codigo Interno X Codigo Externo
Local cMarca		:= "" //Armazena a Marca (LOGIX,PROTHEUS,RM...) que enviou o XML
Local cValExt		:= "" //Codigo externo utilizada no De/Para de codigos - Tabela XXF
Local cValInt		:= "" //Codigo interno utilizado no De/Para de codigos - Tabela XXF

Local cCusVer		:= RTrim(PmsMsgUVer('COSTCENTER',		'CTBA030')) //Versão do Centro de Custo
Local cUndVer		:= RTrim(PmsMsgUVer('UNITOFMEASURE',	'QIEA030')) //Versão da Unidade de Medida
Local cLocVer		:= RTrim(PmsMsgUVer('WAREHOUSE',		'AGRA045')) //Versão do Local de Estoque
Local cPrdVer		:= RTrim(PmsMsgUVer('ITEM',				'MATA010')) //Versão do Produto
Local cPrjVer		:= RTrim(PmsMsgUVer('PROJECT',			'PMSA200')) //Versão do Projeto
Local cTrfVer		:= RTrim(PmsMsgUVer('TASKPROJECT',		'PMSA203')) //Versão da Tarefa

//Instancia objeto JSON
Local ofwEAIObj		:= FWEAIobj():NEW()
Local cEntity		:= "StockTurnover"
Local nCtLtSTI		:= 0
Local lEstorno 		:= .F.

Private oXmlM241		:= Nil
Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .T.
Private lMsHelpAuto		:= .T.

Default oEAIObEt		:= Nil
Default nTypeTrans		:= "3"
Default cTypeMessage	:= ""
Default cVersion		:= ""
Default cTransac		:= ""
Default lEAIObj			:= .F.
Default a241ISD3		:= {}

AdpLogEAI(1, "MATI241", nTypeTrans, cTypeMessage, oEAIObEt)

If ( Type("Inclui") == "U" )
	Private Inclui := .F.
EndIf

If ( Type("Altera") == "U" )
	Private Altera := .F.
EndIf

//--------------------------------------
//recebimento mensagem
//--------------------------------------
If ( nTypeTrans == TRANS_RECEIVE ) .And. ValType( oEAIObEt ) == 'O'

	//--------------------------------------
	//chegada de mensagem de negocios
	//--------------------------------------
	If cTypeMessage == EAI_MESSAGE_BUSINESS
		
		If oEAIObEt:getHeaderValue("ProductName") !=  nil   					
			cMarca :=  Upper(oEAIObEt:getHeaderValue("ProductName"))
		EndIf
			
		If oEAIObEt:getEvent() !=  nil .And. !Empty( oEAIObEt:getEvent() )   
				
			If oEAIObEt:getPropValue("InternalId") != nil  .And. !Empty( oEAIObEt:getPropValue("InternalId") )   
				cValExt := oEAIObEt:getPropValue("InternalId")
			Endif
			
			If Empty( oEAIObEt:getPropValue("MovementTypeCode") )   
				If AllTrim( oEAIObEt:getPropValue("Type") ) $ "E/001"   //Entrada - Conforme definido no XSD     
					cTpMov	:= SuperGetMv('MV_MTI241E',.F.,"")
				ElseIf AllTrim( oEAIObEt:getPropValue("Type") ) $ "S/000"  //Saída - Conforme definido no XSD	
					cTpMov	:= SuperGetMv('MV_MTI241S',.F.,"")
				EndIf
			Else
				cTpMov	:= oEAIObEt:getPropValue("MovementTypeCode")  
			EndIf

			nTamF5Cod := TamSX3("F5_CODIGO")[1]
			cTpMov    := PadR(cTpMov,nTamF5Cod)

			SF5->(dbSetOrder(1))
				
			If Valtype(cTpMov) <> 'C' .Or. Empty(cTpMov) .Or. !SF5->(dbSeek(xFilial("SF5")+cTpMov))
				lRet := .F.
				cLogErro := ""	
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				// "O Tipo de movimentação não foi cadastrado nos parâmetros"
				cLogErro := STR0018 + "MV_MTI241E | MV_MTI241S ou o tipo de movimentação: " + RTrim(cTpMov) + " não foi cadastrado."
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
															
				Return { lRet, ofwEAIObj, cEntity }				
			Else
				AADD(aCab ,{'D3_TM' 		,cTpMov					,Nil} )
			EndIf
			
			If oEAIObEt:getPropValue("RegisterDateTime") != nil    
				dtEmiCab :=  StrTran(oEAIObEt:getPropValue("RegisterDateTime"), '-', '')
				dtEmiCab := STOD( dtEmiCab )
				aAdd(aCab,{"D3_EMISSAO",dtEmiCab,Nil})
			Else
				aAdd(aCab,{"D3_EMISSAO",dDataBase,Nil})
			EndIf

			nTamB1Cod  := TamSX3("B1_COD")[1]
			nTamAHCod  := TamSX3("AH_UNIMED")[1]
			nTamNNRCod := TamSX3("NNR_CODIGO")[1]
			nTamB8Lote := TamSX3("B8_LOTECTL")[1]
			nTamB8SubL := TamSX3("B8_NUMLOTE")[1]
			nTamCTTCod := TamSX3("CTT_CUSTO")[1]

			oLtOfStTn := oEAIObEt:getPropValue("ListOfStockTurnoverItem")
				
			For nX1 := 1 To  len( oLtOfStTn )
					
				lUnitPrice := .F.
				If lRet
					cValExt := oLtOfStTn[nX1]:getPropValue("InternalId")
					cValInt := CFGA070INT(cMarca,'SD3','D3_NUMSEQ',cValExt)
																																	
					If lRet
						If oLtOfStTn[nX1]:getPropValue("ItemInternalId") != nil    
							cProdExt := oLtOfStTn[nX1]:getPropValue("ItemInternalId")  
								
							cProd := CFGA070INT( cMarca, 'SB1', 'B1_COD', cProdExt )
							cProd := MTIGetCod(cProd)
							cProd := PadR(cProd,nTamB1Cod)
							If !Empty(cProd) .And. SB1->(DbSeek(xFilial('SB1')+cProd))
								aAdd(aItens,{"D3_COD",cProd,})
							Else
								lRet := .F.
								cLogErro := ""	
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := STR0002 + " " + RTrim(cProd) //'Não encontrado o Produto'
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																			
								Return { lRet, ofwEAIObj, cEntity }									
							EndIf								
						ElseIf oLtOfStTn[nX1]:getPropValue("ItemCode") != nil  
							cProd := oLtOfStTn[nX1]:getPropValue("ItemCode")  
							cProd := PadR(cProd,nTamB1Cod)
							aAdd(aItens,{"D3_COD",cProd,})
						Else
							lRet := .F.
							cLogErro := ""	
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0003 //'Não existe a Tag ItemCode'
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																			
							Return { lRet, ofwEAIObj, cEntity }								
						EndIf
					EndIf
						
					If lRet
						If oLtOfStTn[nX1]:getPropValue("UnitOfMeasureInternalId") != nil   
							cUnMedExt := oLtOfStTn[nX1]:getPropValue("UnitOfMeasureInternalId") 
								
							cUnMed := CFGA070INT( cMarca, 'SAH', 'AH_UNIMED', cUnMedExt )
							cUnMed	:= MTIGetCod(cUnMed)
							cUnMed := PadR(cUnMed,nTamAHCod)
							If SAH->(DbSeek(xFilial("SAH")+cUnMed))
								aAdd(aItens,{"D3_UM",cUnMed,})
							Else
								lRet := .F.
								cLogErro := ""	
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := 'Não encontrado o unidade de medida ' + cUnMed
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																				
								Return { lRet, ofwEAIObj, cEntity }									
							EndIf
						ElseIf oLtOfStTn[nX1]:getPropValue("UnitOfMeasureCode") != nil   
							cUnMed := oLtOfStTn[nX1]:getPropValue("UnitOfMeasureCode")  
							cUnMed := PadR(cUnMed,nTamAHCod)
							aAdd(aItens,{"D3_UM",cUnMed,})
						Else
							lRet := .F.
							cLogErro := ""	
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0004 //'Não existe a Tag UnitOfMeasure'
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																				
							Return { lRet, ofwEAIObj, cEntity }	
						EndIf
					EndIf
												
					If lRet
						If oLtOfStTn[nX1]:getPropValue("WarehouseInternalId") != nil 
							cArmzmExt := oLtOfStTn[nX1]:getPropValue("WarehouseInternalId")  
														
							cArmzm := CFGA070INT( cMarca, 'NNR', 'NNR_CODIGO', cArmzmExt )

							If Empty(cArmzm) .And. Upper(cMarca) == 'QUIRONS'
								cArmzm := cArmzmExt
							Endif

							cArmzm	:= MTIGetCod(cArmzm)
							cArmzm := PadR(cArmzm,nTamNNRCod)

							If !Empty(cArmzm) .And. NNR->(DbSeek(xFilial("NNR")+cArmzm))

								aAdd(aItens,{"D3_LOCAL",cArmzm,})
							Else
								lRet := .F.
								cLogErro := ""	
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := STR0005 + " " + RTrim(cArmzm) //'Não encontrado o Armazem'
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																					
								Return { lRet, ofwEAIObj, cEntity }									
							EndIf
						ElseIf oLtOfStTn[nX1]:getPropValue("WarehouseCode") != Nil
							cArmzm := oLtOfStTn[nX1]:getPropValue("WarehouseCode") 
							cArmzm := PadR(cArmzm,nTamNNRCod)
							aAdd(aItens,{"D3_LOCAL",cArmzm,})
						Else
							lRet := .F.
							cLogErro := ""	
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0006 //'Não existe a Tag "WarehouseCode"'
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)

							Return { lRet, ofwEAIObj, cEntity }	
						EndIf
					EndIf

					If lRet
						If oLtOfStTn[nX1]:getPropValue("UnitPrice") != nil 
							If ValType(oLtOfStTn[nX1]:getPropValue("UnitPrice")) == 'N'
								aAdd(aItens,{"D3_CUSTO1",oLtOfStTn[nX1]:getPropValue("UnitPrice"),})
							ElseIf ValType(oLtOfStTn[nX1]:getPropValue("UnitPrice")) == 'C'
								aAdd(aItens,{"D3_CUSTO1",Val(oLtOfStTn[nX1]:getPropValue("UnitPrice")),})
							Endif
							lUnitPrice := .T.
						EndIf
					EndIf
						
					If lRet
						If oLtOfStTn[nX1]:getPropValue("Quantity") != nil 
							If ValType(oLtOfStTn[nX1]:getPropValue("Quantity")) == 'N'
								nQuant := oLtOfStTn[nX1]:getPropValue("Quantity")
							ElseIf  ValType(oLtOfStTn[nX1]:getPropValue("Quantity")) == 'C'
								nQuant := Val(oLtOfStTn[nX1]:getPropValue("Quantity"))
							Endif
							aAdd(aItens,{"D3_QUANT",nQuant,})
						Else
							lRet := .F.
							cLogErro := ""	
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0007 //'Não exite a Tag "Quantity"'
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																					
							Return { lRet, ofwEAIObj, cEntity }	
						EndIf
					EndIf					
																								
					If lRet .And. lUnitPrice
						If oLtOfStTn[nX1]:getPropValue("TotalPrice") != nil 
							If ValType(oLtOfStTn[nX1]:getPropValue("TotalPrice")) == 'N'
								aAdd(aItens,{"D3_TOTAL",Round(oLtOfStTn[nX1]:getPropValue("TotalPrice"),2),})
							ElseIf ValType(oLtOfStTn[nX1]:getPropValue("TotalPrice")) == 'C'
								aAdd(aItens,{"D3_TOTAL",Round(Val(oLtOfStTn[nX1]:getPropValue("TotalPrice")),2),})
							Endif
						EndIf
					EndIf
						
					If lRet
						If oLtOfStTn[nX1]:getPropValue("EmissionDate") != nil 
							dtEmiss := StrTran(oLtOfStTn[nX1]:getPropValue("EmissionDate"), '-', '')
							dtEmiss := STOD( dtEmiss )
							aAdd(aItens,{"D3_EMISSAO",dtEmiss,})
						Else
							lRet := .F.
							cLogErro := ""	
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0008 //'Não existe a Tag "Date"'
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																					
							Return { lRet, ofwEAIObj, cEntity }	
						EndIf
					EndIf
						 						 
					If lRet
						If oLtOfStTn[nX1]:getPropValue("RequestItemInternalId") != nil  
							cSA := CFGA070INT(cMarca,'SCP','CP_ITEM', oLtOfStTn[nX1]:getPropValue("RequestItemInternalId"))
							If !Empty(cSA)
								aSA := Separa(cSA,"|")
								If Len(aSA) > 0
									aAdd(aItens,{"D3_NUMSA",aSA[1,3],})
									aAdd(aItens,{"D3_ITEMSA",aSA[1,4],})
								Endif
							Endif
						Endif
					EndIf
						
					If lRet .And. Rastro(cProd)
						If oLtOfStTn[nX1]:getPropValue("LotOrSerialNumber") != nil 
							cLote		:= oLtOfStTn[nX1]:getPropValue("LotOrSerialNumber")
							cLote := PadR(cLote,nTamB8Lote)
							aAdd(aItens,{"D3_LOTECTL",cLote,})
						Else
							lRet := .F.
							cLogErro := ""	
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0009 //'Não existe a Tag "LotNumber"'
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																					
							Return { lRet, ofwEAIObj, cEntity }	
						EndIf
							
						If lRet
							If oLtOfStTn[nX1]:getPropValue("LotExpirationDate") != nil  
								dtValLot 	:= StrTran(oLtOfStTn[nX1]:getPropValue("LotExpirationDate"), '-', '')
								dtValLot	:= STOD( dtValLot )
								aAdd(aItens,{"D3_DTVALID",dtValLot,})
							Else
								lRet := .F.
								cLogErro := ""	
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := STR0011 //'Não existe a Tag "LotExpirationDate"'
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																						
								Return { lRet, ofwEAIObj, cEntity }	
							EndIf
						EndIf
							
						If lRet .And. Rastro(cProd,"S")
							If oLtOfStTn[nX1]:getPropValue("SubLotNumber") != nil  
								cSubLote := oLtOfStTn[nX1]:getPropValue("SubLotNumber")
								cSubLote := PadR(cSubLote,nTamB8SubL)
								SD5->(DbSetOrder(2))
								If SD5->(dbSeek(xFilial("SD5")+cProd+cArmzm+cLote+cSubLote))
									aAdd(aItens,{"D3_NUMLOTE",cSubLote,})
								EndIf
							Else
								lRet := .F.
								cLogErro := ""	
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := STR0010 //'Não existe a Tag "SubLotNumber"'
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																						
								Return { lRet, ofwEAIObj, cEntity }	
							EndIf
						EndIf
					EndIf
						
					If lRet .And. Localiza(cProd)
						If oLtOfStTn[nX1]:getPropValue("BinLocation") != nil  
							cEnd	:= oLtOfStTn[nX1]:getPropValue("BinLocation")
							aAdd(aItens,{"D3_LOCALIZ",cEnd,})
						Elseif cTpMov > "500"
							lRet := .F.
							cLogErro := ""	
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := "BinLocation não informado corretamente" //'Não existe a Tag "Address"'
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																						
							Return { lRet, ofwEAIObj, cEntity }	
						EndIf
							
						If lRet .And. oLtOfStTn[nX1]:getPropValue("NumberSeries") != nil 
							cNumSer	:= oLtOfStTn[nX1]:getPropValue("NumberSeries")
							aAdd(aItens,{"D3_NUMSERI",cNumSer,})
						EndIf
					EndIf
												
					If lRet
						If oLtOfStTn[nX1]:getPropValue("CostCenterInternalId") != nil  
							cCostCenter := oLtOfStTn[nX1]:getPropValue("CostCenterInternalId")
							cCostCenter := CFGA070INT(cMarca,'CTT','CTT_CUSTO',cCostCenter)
							cCostCenter := MTIGetCod(cCostCenter)
							cCostCenter := PadR(cCostCenter,nTamCTTCod)
							If !Empty(cCostCenter) .And. CTT->(DbSeek(xFilial("CTT")+cCostCenter))
								aAdd(aItens,{"D3_CC",cCostCenter,NIL})
							Else
								lRet := .F.
								cLogErro := ""	
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := STR0020 + " " + RTrim(cCostCenter) //"Centro de custo inválido/não encontrado."
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																							
								Return { lRet, ofwEAIObj, cEntity }	
							EndIf
						EndIf
					EndIf
												
					If Upper(oEAIObEt:getHeaderValue('Event')) == "UPSERT"
						Inclui	:= .T.
						nOpcx	:= 3	// Inclusao
					Else
						nOpcx	:= 6	// Estorno
						aAdd(aItens,{"D3_NUMSEQ",MTIGetCod(cValInt)})
						aAdd(aItens,{"INDEX",7,})
					EndIf
						
					If lRet .And. Upper(Alltrim(cMarca)) == "PIMS"
						If oEAIObEt:getPropValue("Code") != nil .And. !Empty( oEAIObEt:getPropValue("Code") )
							AADD(aItens ,{'D3_NRBPIMS',oEAIObEt:getPropValue("Code") ,Nil} )
						EndIf
					ENDIF

					If lRet .And. oLtOfStTn[nX1]:getPropValue("MainOrderCode") != nil 
						AADD(aItens ,{'D3_OP',oLtOfStTn[nX1]:getPropValue("MainOrderCode")	,Nil} )
					EndIf
				Else
					If lRet
						lRet := .F.
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0016 //"Atualize EAI"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																						
						Return { lRet, ofwEAIObj, cEntity }	
					EndIf
				EndIf
				aadd(atotitem,aItens)
				aItens := {}
			Next nX1
		EndIf
			
		// ponto de entrada inserido para controlar dados especificos do cliente
		If lRet .And. ExistBlock("MT241EAI")
		       
			aMatRet := ExecBlock("MT241EAI", .F., .F. , {aCab, atotitem })
		  	If ValType(aMatRet) == "A"
		  		aCab := aClone(aMatRet[1]) 
		    	atotitem := aClone(aMatRet[2])
			EndIf

		EndIf 
			
		If lRet
			//-----------------------------
			// Executa rotina a automatica
			//-----------------------------
			SD3->(dbSetOrder(4)) 
			SD3->(dbSeek( xFilial("SD3") + AllTrim(MTIGetCod(cValInt)) )) 
			
			MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,atotitem, nOpcx)
				
			If lMsErroAuto
				// Obtém o log de erros
				aErroAuto := GetAutoGRLog()
		
		      	// Varre o array obtendo os erros e quebrando a linha
		     	lRet := .F.
				cLogErro := ""
				For nCount := 1 To Len(aErroAuto)
					cLogErro += StrTran( StrTran( aErroAuto[nCount], "<", "" ), "-", "" ) + (" | ")
				Next nCount
						
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)					
			Else

				lEstorno := (nOpcx == 6)

				aResponse := GetItemSD3(SD3->D3_DOC)

				If Len(aResponse) > 0
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
				Endif

				For nX := 1 To Len(aResponse)

					If nOpcX == 3
						cValInt := cEmpAnt + '|' + RTrim(xFilial('SD3')) + '|' + RTrim(aResponse[nX][1]) + '|' + RTrim(aResponse[nX][2])
						cValExt := oLtOfStTn[nX]:getPropValue("InternalId")

						CFGA070Mnt(cMarca,"SD3","D3_NUMSEQ",cValExt,cValInt, lEstorno)

						ofwEAIObj:getPropValue("ReturnContent"):setprop('ListOfInternalId', {})

						oFwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalId")[nX]:setprop("Name", cEntity,,.T.)
						oFwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalId")[nX]:setprop("Origin", cValExt,,.T.)
						oFwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalId")[nX]:setprop("Destination",cValInt,,.T.)
					Else

					Endif

				Next 

			EndIf
		EndIf
		
		
	//--------------------------------------
	//resposta da mensagem Unica TOTVS
	//--------------------------------------
	ElseIf   cTypeMessage == EAI_MESSAGE_RESPONSE
	
		//-- Identifica se o processamento pelo parceiro ocorreu com sucesso
		If Upper(oEAIObEt:getPropValue("ProcessingInformation"):getPropValue("Status")) == "OK"
		
			If oEAIObEt:getHeaderValue("ProductName") !=  nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") ) 
				cMarca := oEAIObEt:getHeaderValue("ProductName")
			Endif
					
			oObLisOfIt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalId")

			For nCount := 1 To Len( oObLisOfIt )
				cValInt := oObLisOfIt[nCount]:getPropValue('Destination') 
				cValExt := oObLisOfIt[nCount]:getPropValue('Origin') 
					
				AdpLogEAI(3, "Origin[" + Str(nCount) + "]: ", cValInt)
				AdpLogEAI(3, "Destination[" + Str(nCount) + "]: ", cValExt)
					
				If !Empty(cValExt) .And.!Empty(cValInt)
					If Type("l185") <> "U" .And. l185 .And. ValType(a241ISD3) == "A" //delete
						CFGA070Mnt(cMarca, "SD3", "D3_NUMSEQ", cValExt, cValInt, .F.)
					Else //upsert
						CFGA070Mnt(cMarca, "SD3", "D3_NUMSEQ", cValExt, cValInt)
					EndIf

					lRet := .T.
				Else
					lRet := .F.
				EndIf
			Next nCount
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
				
			If InTransact()
				DisarmTransaction()
			EndIf
		EndIf

	//--------------------------------------
	//whois
	//--------------------------------------	
	ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
		Return {.T., '1.000|1.001|1.002|1.003|1.004|1.005', cEntity}
	EndIf

//--------------------------------------
//envio mensagem
//--------------------------------------
ElseIf nTypeTrans == TRANS_SEND

	If	Type("l185")<>"U" .And. l185 .And. ValType(a241ISD3)=="A"
		If !Empty(AllTrim(SD3->D3_ESTORNO))
			cEvent := 'delete'
		Endif
	Elseif Type("l241") <> "U" .And. !Empty(AllTrim(SD3->D3_ESTORNO))
		cEvent := "delete"
	EndIf
		
	cNumDoc := SD3->D3_DOC
	cNumSeq := SD3->D3_NUMSEQ
	
	//Montagem da mensagem
	ofwEAIObj:Activate()
	ofwEAIObj:setEvent(cEvent)
	
	ofwEAIObj:setprop("Code", RTrim(cNumDoc))	
	ofwEAIObj:setprop("InternalId", cEmpAnt + '|' + RTrim(xFilial('SD3')) + '|' + RTrim(cNumDoc) + '|' + RTrim(cNumSeq) )
	ofwEAIObj:setprop("CompanyId", cEmpAnt)	
	ofwEAIObj:setprop("BranchId", xFilial("SD3"))
	ofwEAIObj:setprop("CompanyInternalId", cEmpAnt + '|' + RTrim(xFilial('SD3')))
	ofwEAIObj:setprop("Number", "")
	If SD3->D3_TM <= "500"
		ofwEAIObj:setprop("Type", "E")
	Else
		ofwEAIObj:setprop("Type", "S")
	EndIf
	ofwEAIObj:setprop("MovementTypeCode", RTrim(SD3->D3_TM))
	If SF5->(dbSeek(xFilial("SF5")+SD3->D3_TM))
		ofwEAIObj:setprop("DocumentType", RTrim(SF5->F5_TIPO))
	Else
		ofwEAIObj:setprop("DocumentType", "")
	EndIf
	ofwEAIObj:setprop("Series", Space(8))   
	ofwEAIObj:setprop("RegisterDateTime", Transform(DToS(SD3->D3_EMISSAO),"@R 9999-99-99")) 	
	ofwEAIObj:setprop("DeliveryDateTime", Transform(DToS(dDataBase),"@R 9999-99-99")) 	
	ofwEAIObj:setprop("AbatementDateTime", Transform(DToS(dDataBase),"@R 9999-99-99")) 	
	
	//-- Item da movimentacao
	SD3->(DbSetOrder(2))
	If	SD3->(DbSeek(xFilial("SD3")+cNumDoc))

		ofwEAIObj:setprop('ListOfStockTurnoverItem')

		nX := 0

		While SD3->( !Eof() .And. SD3->D3_FILIAL + SD3->D3_DOC == xFilial("SD3")+cNumDoc )
			
			If cEvent == "delete" .And. Empty(AllTrim(SD3->D3_ESTORNO))
				SD3->(DbSkip())
			Endif

			nX++

			If ((ValType(a241ISD3)=="A" .And. Ascan( a241ISD3, SD3->(Recno()))>0) .Or. (((ValType(a241ISD3)<> "A" .And. Ascan(a241ISD3, SD3->(Recno()))==0) .Or. Len(a241ISD3) == 0) .And.  (cEvent == "upsert" .Or. cEvent == "delete" )))

				ofwEAIObj:setprop('ListOfStockTurnoverItem', {})

				nCtLtSTI := nX //Len( oObjLtSTI )

				oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setProp("Code",	RTrim(cNumDoc),,.T.)  
				oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("InternalId", cEmpAnt + '|' + RTrim(xFilial('SD3')) + '|' + RTrim(SD3->D3_DOC) + '|' + RTrim(SD3->D3_NUMSEQ),,.T.)  
				oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("EmissionDate", Transform(DToS(SD3->D3_EMISSAO),"@R 9999-99-99"),,.T.)  
				oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("ItemCode", RTrim(SD3->D3_COD),,.T.) 
				oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("ItemInternalId", IntProExt(/*cEmpresa*/, /*cFilial*/, SD3->D3_COD, /*cPrdVer*/)[2],,.T.)  
				oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("ItemReferenceCode", RTrim(SD3->D3_COD),,.T.)  
				oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("UnitPrice", (SD3->D3_CUSTO1/SD3->D3_QUANT),,.T.)  
				oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("TotalPrice", SD3->D3_CUSTO1,,.T.)  
				oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("Quantity", SD3->D3_QUANT,,.T.)  
				oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("UnitOfMeasureInternalId", IntUndExt(/*cEmpresa*/, /*cFilial*/, SD3->D3_UM, cUndVer)[2],,.T.)  
				oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("UnitOfMeasureCode", RTrim(SD3->D3_UM),,.T.)  
				oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("WarehouseInternalId", IntLocExt(/*cEmpresa*/, /*cFilial*/, SD3->D3_LOCAL)[2],,.T.)  
				oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("WarehouseCode", RTrim(SD3->D3_LOCAL),,.T.)  
				oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("DeliveryDateTime", Transform(DToS(dDataBase),"@R 9999-99-99"),,.T.)  
				
				If Empty(SD3->D3_CC)
					oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("CostCenterInternalId", "",,.T.)
					oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("CostCenterCode", "",,.T.)
				Else
					oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("CostCenterInternalId", IntCusExt(/*cEmpresa*/, /*cFilial*/, SD3->D3_CC, cCusVer)[2],,.T.)
					oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("CostCenterCode", RTrim(SD3->D3_CC),,.T.)
				EndIf
				
				If Empty(SD3->D3_CONTA)
					oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("AccountantAcountInternalId", "",,.T.)
				Else
					oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("AccountantAcountInternalId", cEmpAnt + '|' + RTrim(xFilial('SD3')) + '|' + RTrim(SD3->D3_CONTA),,.T.)
				EndIf
				oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("AccountantAcountInternalId", RTrim(SD3->D3_OP),,.T.) 
				
				If Empty(SD3->D3_PROJPMS)
					oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("ProjectInternalId", "",,.T.)
					oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("TaskInternalId", "",,.T.)
				Else
					oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("ProjectInternalId", IntPrjExt(/*cEmpresa*/, /*cFilial*/, SD3->D3_PROJPMS, cPrjVer)[2],,.T.)
					oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("TaskInternalId", IntTrfExt(/*cEmpresa*/, /*cFilial*/, SD3->D3_PROJPMS, '0001', SD3->D3_TASKPMS, cTrfVer)[2],,.T.)
				EndIf
				
				oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("RequestItemInternalId", "",,.T.)
				
				If !Empty(SD3->D3_NUMSA) .And. !Empty(SD3->D3_ITEMSA)

					SCP->(dbSetOrder(1))

					If SCP->(dbSeek(xFilial('SCP')+SD3->D3_NUMSA+SD3->D3_ITEMSA))
						oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("RequestItemInternalId", cEmpAnt + "|" + RTrim(xFilial("SCP")) + "|" + RTrim(SCP->CP_NUM) + "|" + RTrim(SCP->CP_ITEM + "|" + RTrim(DtoS(SCP->CP_EMISSAO))),,.T.)
					Else
						oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("RequestItemInternalId", cEmpAnt + "|" + RTrim(xFilial("SD3")) + "|" + RTrim(SD3->D3_NUMSA) + "|" + RTrim(SD3->D3_ITEMSA),,.T.)
					Endif	

				Endif
								
				oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("Observation", "",,.T.) 
				oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("LotOrSerialNumber", RTrim(SD3->D3_LOTECTL),,.T.) 
				
				If Empty(SD3->D3_DTVALID)
					oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("LotExpirationDate", "",,.T.)
				Else
					oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("LotExpirationDate", Transform(DToS(SD3->D3_DTVALID),"@R 9999-99-99"),,.T.)
				EndIf
				
				oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("BinLocation", RTrim(SD3->D3_LOCALIZ),,.T.) 
				oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("NumberSeries", RTrim(SD3->D3_NUMSERI),,.T.) 
				
				SB2->(dbSeek(xFilial("SB2")+SD3->D3_COD+SD3->D3_LOCAL))
			 	If SD3->D3_TM <= "500"
					oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("TotalStock", (SB2->B2_QATU - MTICalPrd(SD3->(D3_FILIAL+D3_DOC+D3_COD),SD3->D3_LOCAL)),,.T.)
				Else
					oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("TotalStock", (SB2->B2_QATU + MTICalPrd(SD3->(D3_FILIAL+D3_DOC+D3_COD),SD3->D3_LOCAL)),,.T.)			
				EndIf
				
				If !Empty(SD3->D3_LOTECTL)
					If SD3->D3_TM <= "500"
						oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("LotStock", (SaldoLote(SD3->D3_COD,SD3->D3_LOCAL,SD3->D3_LOTECTL,NIL,.T.,.T.,NIL,dDataBase)- MTICalPrd(SD3->(D3_FILIAL+D3_DOC+D3_COD),SD3->D3_LOCAL,SD3->D3_LOTECTL)),,.T.)
					Else
						oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("LotStock", (SaldoLote(SD3->D3_COD,SD3->D3_LOCAL,SD3->D3_LOTECTL,NIL,.T.,.T.,NIL,dDataBase)+ MTICalPrd(SD3->(D3_FILIAL+D3_DOC+D3_COD),SD3->D3_LOCAL,SD3->D3_LOTECTL)),,.T.)				
					EndIf						
				EndIf
								
				If !Empty(SD3->D3_LOCALIZ)
					If SD3->D3_TM <= "500"
						oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("BinStock", (SaldoSBF(SD3->D3_LOCAL,SD3->D3_LOCALIZ,SD3->D3_COD,NIL,SD3->D3_LOTECTL,NIL,.T.)- MTICalPrd(SD3->(D3_FILIAL+D3_DOC+D3_COD),SD3->D3_LOCAL,SD3->D3_LOTECTL,SD3->D3_LOCALIZ)),,.T.)
					Else
						oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("BinStock", (SaldoSBF(SD3->D3_LOCAL,SD3->D3_LOCALIZ,SD3->D3_COD,NIL,SD3->D3_LOTECTL,NIL,.T.)+ MTICalPrd(SD3->(D3_FILIAL+D3_DOC+D3_COD),SD3->D3_LOCAL,SD3->D3_LOTECTL,SD3->D3_LOCALIZ)),,.T.)
					EndIf						
				EndIf
				
				If !Empty(SD3->D3_NUMSERI)
					If SD3->D3_TM <= "500"
						oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("SeriesStock", (SaldoSBF(SD3->D3_LOCAL,SD3->D3_LOCALIZ,SD3->D3_COD,SD3->D3_NUMSERI,SD3->D3_LOTECTL,NIL,.T.)- MTICalPrd(SD3->(D3_FILIAL+D3_DOC+D3_COD),SD3->D3_LOCAL,SD3->D3_LOTECTL,SD3->D3_LOCALIZ,SD3->D3_NUMSERI)),,.T.)
					Else
						oFwEAIObj:getPropValue("ListOfStockTurnoverItem")[nX]:setprop("SeriesStock", (SaldoSBF(SD3->D3_LOCAL,SD3->D3_LOCALIZ,SD3->D3_COD,SD3->D3_NUMSERI,SD3->D3_LOTECTL,NIL,.T.)+ MTICalPrd(SD3->(D3_FILIAL+D3_DOC+D3_COD),SD3->D3_LOCAL,SD3->D3_LOTECTL,SD3->D3_LOCALIZ,SD3->D3_NUMSERI)),,.T.)
					EndIf								
				EndIf	

				If IsIntegTop() //Possui integração com o RM Solum
					aRateio := RatEst(SD3->D3_FILIAL + SD3->D3_COD + SD3->D3_LOCAL + DTOS(SD3->D3_EMISSAO) + SD3->D3_NUMSEQ)

					//-- Rateio da movimentação
					For nCont := 1 To Len(aRateio)
						oObjRatEst := ofwEAIObj:get("ListOfStockTurnoverItem")[nCtLtSTI]:setprop("ListOfApportionStockTurnoverItem", {},,.T.)
						
						oObjRatEst[nCont]:setprop("InternalId", cEmpAnt + '|' + RTrim(xFilial('SD3')) + '|' + RTrim(cNumDoc) + '|' + RTrim(SD3->D3_NUMSEQ)+ '|' + RTrim(cValToChar(nCont)),,.T.) 
						oObjRatEst[nCont]:setprop("DepartamentCode", "",,.T.) 
						oObjRatEst[nCont]:setprop("DepartamentInternalId", "",,.T.) 
						oObjRatEst[nCont]:setprop("CostCenterInternalId", IntCusExt(/*cEmpresa*/, /*cFilial*/, aRateio[nCont][1])[2],,.T.) 
						oObjRatEst[nCont]:setprop("AccountantAcountInternalId", RTrim(aRateio[nCont][2]),,.T.)  
						oObjRatEst[nCont]:setprop("ProjectInternalId", IIf(!Empty(aRateio[nCont][6]), IntPrjExt(/*cEmpresa*/, /*cFilial*/, aRateio[nCont][6])[2], ''),,.T.)  
						oObjRatEst[nCont]:setprop("SubProjectInternalId", "",,.T.) 
						oObjRatEst[nCont]:setprop("TaskInternalId", IIf(!Empty(aRateio[nCont][7]), IntTrfExt(/*cEmpresa*/, /*cFilial*/, aRateio[nCont][6], '0001', aRateio[nCont][7])[2], ''),,.T.) 
						oObjRatEst[nCont]:setprop("Value", 0,,.T.) 
						oObjRatEst[nCont]:setprop("Percentual", aRateio[nCont][5],,.T.) 
						oObjRatEst[nCont]:setprop("Quantity", aRateio[nCont][8],,.T.) 
						oObjRatEst[nCont]:setprop("Observation", "",,.T.) 
					Next nCont
					
				EndIf

			EndIf
			SD3->(DbSkip())
		EndDo
	EndIf
EndIf
RestArea(aAreaSD3)
RestArea(aArea)

AdpLogEAI(5, "MATI241", ofwEAIObj, lRet)

Return { lRet, ofwEAIObj, cEntity }
	
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
Static Function MTIGetCod(cCodigo)

While At('|',cCodigo) > 0
	cCodigo:= Substr(cCodigo,At('|',cCodigo)+1)
EndDo

Return cCodigo

//-------------------------------------------------------------------
/*/{Protheus.doc} RatEst
Recebe a chave de busca da movimentação de estoque e monta o rateio

@author  Leandro Luiz da Cruz
@version P11
@since   19/03/2013

@return aResult
/*/
//-------------------------------------------------------------------
Static Function RatEst(chaveSD3)
   Local aResult  := {}
   Local aPrjtTrf := {}
   Local aCntrCst := {}
   Local nI       := 0
   Local aAreaAFI := AFI->(GetArea())

   AFI->(dbSetOrder(2))//AFI_FILIAL + AFI_COD + AFI_LOCAL + DTOS(AFI_EMISSA) + AFI_NUMSEQ + AFI_PROJET + AFI_REVISA + AFI_TAREFA

   //Povoa o array de Projeto
   If AFI->(dbSeek(chaveSD3))
      While !AFI->(Eof()) .And. chaveSD3 == AFI->AFI_FILIAL + AFI->AFI_COD + AFI->AFI_LOCAL + DTOS(AFI->AFI_EMISSA) + AFI->AFI_NUMSEQ
         aAdd(aPrjtTrf, Array(4))
         nI++
         aPrjtTrf[nI][1] := AFI->AFI_PROJET
         aPrjtTrf[nI][2] := AFI->AFI_REVISA
         aPrjtTrf[nI][3] := AFI->AFI_TAREFA
         aPrjtTrf[nI][4] := AFI->AFI_QUANT
         AFI->(dbSkip())
      EndDo
   EndIf

   If Len(aPrjtTrf) > 0
      aAdd(aCntrCst, {SD3->D3_CC, SD3->D3_CONTA, SD3->D3_ITEMCTA, SD3->D3_CLVL, 100})

      aResult := IntRatPrjCC(aCntrCst, aPrjtTrf)
   EndIf

   RestArea(aAreaAFI)
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} GetItemSD3
Retorna os items da SD3 para gravaçao do Response
@author  flavio.martins
@version P11
@since   08/03/2022

@return aResult
/*/
//-------------------------------------------------------------------
Static Function GetItemSD3(cDocto)
Local cAliasSD3	:= GetNextAlias()
Local aDados 	:= {}

BeginSql Alias cAliasSD3
	
	SELECT D3_DOC,
	       D3_NUMSEQ
	FROM %Table:SD3%
	WHERE D3_FILIAL = %xFilial:SD3%
	  AND D3_DOC = %Exp:cDocto%
	  AND %NotDel%
	ORDER BY D3_NUMSEQ

EndSql

While (cAliasSD3)->(!Eof())

	Aadd(aDados, {(cAliasSD3)->D3_DOC, (cAliasSD3)->D3_NUMSEQ})
	(cAliasSD3)->(dbSkip())

EndDo

(cAliasSD3)->(dbCloseArea())

Return aDados
