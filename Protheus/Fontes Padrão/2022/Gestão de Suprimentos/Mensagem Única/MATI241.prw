#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#Include "MATI240.CH"
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Function  ≥ MATI241  ∫ Autor ≥ Alex Egydio          ∫ Data ≥  27/12/12  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Desc.    ≥ Funcao de integracao com o adapter EAI para baixa da         ∫±±
±±∫          ≥ movimentacao de estoque (Stockturnover) utilizando o conceito∫±±
±±∫          ≥ de mensagem unica.                                           ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Param.   ≥ cXML - Variavel com conteudo xml para envio/recebimento.     ∫±±
±±∫          ≥ nTypeTrans - Tipo de transacao. (Envio/Recebimento)          ∫±±
±±∫          ≥ cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc) ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Retorno  ≥ aRet - Array contendo o resultado da execucao e a mensagem   ∫±±
±±∫          ≥        Xml de retorno.                                       ∫±±
±±∫          ≥ aRet[1] - (boolean) Indica o resultado da execuÁ„o da funÁ„o ∫±±
±±∫          ≥ aRet[2] - (caracter) Mensagem Xml para envio                 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Uso      ≥ MATA241                                                      ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function MATI241( cXML, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj, a241ISD3 )
Local aCab			:= {}
Local aItens		:= {}
Local atotitem	:={}
Local aErroAuto	:= {}
Local aRateio		:= {}
Local aMatRet		:= {}
Local lRet			:= .T.
Local lUnitPrice	:= .F.
Local cXMLRet		:= ""
Local cLogErro	:= ""
Local cEvent		:= "upsert"
Local cXmlErro	:= ""
Local cXmlWarn	:= ""
Local cTpMov		:= ""
Local cProd		:= ""
Local cUnMed		:= ""
Local cArmzm		:= ""
Local cLote		:= ""
Local cSubLote	:= ""
Local cEnd			:= ""
Local cCostCenter	:= ""
Local cNumSer		:= ""
Local cProdExt	:= ""
Local cArmzmExt	:= ""
Local cUnMedExt	:= ""
Local nCount		:= 0
Local nOpcx		:= 0
Local nQuant		:= 0
Local nX1			:= 1
Local nCont		:= 0
Local dtEmiss		:= CToD("")
Local dtValLot	:= CToD("")
Local dtEmiCab   := CToD("")

//Variaveis utilizadas no De/Para de Codigo Interno X Codigo Externo
Local cMarca		:= "" //Armazena a Marca (LOGIX,PROTHEUS,RM...) que enviou o XML
Local cValExt		:= "" //Codigo externo utilizada no De/Para de codigos - Tabela XXF
Local cValInt		:= "" //Codigo interno utilizado no De/Para de codigos - Tabela XXF

Local cCusVer		:= RTrim(PmsMsgUVer('COSTCENTER',		'CTBA030')) //Vers„o do Centro de Custo
Local cUndVer		:= RTrim(PmsMsgUVer('UNITOFMEASURE',	'QIEA030')) //Vers„o da Unidade de Medida
Local cLocVer		:= RTrim(PmsMsgUVer('WAREHOUSE',		'AGRA045')) //Vers„o do Local de Estoque
Local cPrdVer		:= RTrim(PmsMsgUVer('ITEM',				'MATA010')) //Vers„o do Produto
Local cPrjVer		:= RTrim(PmsMsgUVer('PROJECT',			'PMSA200')) //Vers„o do Projeto
Local cTrfVer		:= RTrim(PmsMsgUVer('TASKPROJECT',		'PMSA203')) //Vers„o da Tarefa

Local cQuery := ""
Local cAliasMov := GetNextAlias()
Local oTempTbl := Nil
Local cChaveAnt := ""

Local aSaldos := {}
// Array para cache dos saldos totalizados dos itens da movimentaÁ„o para evitar consulta em disco
// Estrutura:
//	aSaldos[x][1] = Chave identificadora do registro
//	aSaldos[x][2] = Saldo totalizado

Private oXmlM241		:= Nil
Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .T.
Private lMsHelpAuto		:= .T.

Default cXml			:= ""
Default nTypeTrans		:= "3"
Default cTypeMessage	:= ""
Default cVersion		:= ""
Default cTransac		:= ""
Default lEAIObj			:= .F.
Default a241ISD3		:= {}

If lEAIObj
	Return MATI241Json( cXML, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj, a241ISD3 )
EndIf

AdpLogEAI(1, "MATI241", nTypeTrans, cTypeMessage, cXML)

If ( Type("Inclui") == "U" )
	Private Inclui := .F.
EndIf

If ( Type("Altera") == "U" )
	Private Altera := .F.
EndIf

//Tratamento do recebimento de mensagens
If ( nTypeTrans == TRANS_RECEIVE )

	If cTypeMessage == EAI_MESSAGE_BUSINESS
		oXmlM241	:= XmlParser( cXML, '_', @cXmlErro, @cXmlWarn)

		If oXmlM241 <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
			If Type("oXmlM241:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U"
				cMarca :=  oXmlM241:_TotvsMessage:_MessageInformation:_Product:_Name:Text
			EndIf

			oXmlBusin := oXmlM241:_TotvsMessage:_BusinessMessage

			If XmlChildEx(oXmlBusin, '_BUSINESSEVENT') <> Nil .And. XmlChildEx(oXmlBusin:_BusinessEvent, '_EVENT' ) <> Nil

				If XmlChildEx(oXmlM241:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT, '_INTERNALID') <> Nil
					cValExt := oXmlM241:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_INTERNALID:Text
				EndIf

				oXmlBusinItem :=  oXmlM241:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_LISTOFSTOCKTURNOVERITEM

				If ValType(oXmlM241:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_LISTOFSTOCKTURNOVERITEM:_STOCKTURNOVERITEM) <> "A"
					XmlNode2Arr(oXmlM241:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_LISTOFSTOCKTURNOVERITEM:_STOCKTURNOVERITEM,"_STOCKTURNOVERITEM")
				EndIf

				If Type ('oXmlM241:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_MovementTypeCode') <> 'O' .Or. Empty(oXmlM241:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_MovementTypeCode:Text)
					If AllTrim(oXmlM241:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_TYPE:Text) $ "E/001"   //Entrada - Conforme definido no XSD
						cTpMov	:= SuperGetMv('MV_MTI241E',.F.,"")
					ElseIf AllTrim(oXmlM241:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_TYPE:Text) $ "S/000"  //SaÌda - Conforme definido no XSD
						cTpMov	:= SuperGetMv('MV_MTI241S',.F.,"")
					EndIf
				Else
					cTpMov	:= oXmlM241:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_MovementTypeCode:Text
				EndIf

				SF5->(dbSetOrder(1))

				If Valtype(cTpMov) <> 'C' .Or. Empty(cTpMov) .Or. !SF5->(dbSeek(xFilial("SF5")+cTpMov))
					lRet    := .F.
					// "O Tipo de movimentaÁ„o n„o foi cadastrado nos par‚metros"
					cXmlRet := STR0018 + "MV_MTI241E | MV_MTI241S ou o tipo de movimentaÁ„o: " + RTrim(cTpMov) + " n„o foi cadastrado."
				Else
					AADD(aCab ,{'D3_TM' 		,cTpMov					,Nil} )
				EndIf

				If Type ('oXmlM241:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_RegisterDateTime') <> NIL
					dtEmiCab :=  StrTran(oXmlM241:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_RegisterDateTime:Text, '-', '')
					dtEmiCab := STOD( dtEmiCab )
					aAdd(aCab,{"D3_EMISSAO",dtEmiCab,Nil})
				Else
					aAdd(aCab,{"D3_EMISSAO",dDataBase,Nil})
				EndIf

				For nX1 := 1 To  len(oXmlM241:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_LISTOFSTOCKTURNOVERITEM:_STOCKTURNOVERITEM)

					lUnitPrice := .F.
					If lRet
						cValInt := CFGA070INT(cMarca,'SD3','D3_NUMSEQ',cValExt)

						If lRet
							If XmlChildEx(oXmlBusinItem:_STOCKTURNOVERITEM[1], '_ITEMINTERNALID') <> NIL
								cProdExt := oXmlBusinItem:_STOCKTURNOVERITEM[nX1]:_ItemInternalId:Text

								cProd := CFGA070INT( cMarca, 'SB1', 'B1_COD', cProdExt )
								cProd:= MTIGetCod(cProd)
								If SB1->(DbSeek(xFilial('SB1')+cProd))
									aAdd(aItens,{"D3_COD",cProd,})
								Else
									lRet := .F.
									cXMLRet := STR0002 + " " + RTrim(cProd) //'N„o encontrado o Produto'
								EndIf
							ElseIf XmlChildEx(oXmlBusinItem:_STOCKTURNOVERITEM[1], '_ITEMCODE') <> NIL
								cProd := oXmlBusinItem:_STOCKTURNOVERITEM[nX1]:_ItemCode:Text
								aAdd(aItens,{"D3_COD",cProd,})
							Else
								lRet := .F.
								cXMLRet := STR0003 //'N„o existe a Tag ItemCode'
							EndIf
						EndIf

						If lRet
							If XmlChildEx(oXmlBusinItem:_STOCKTURNOVERITEM[nX1], '_UNITOFMEASUREINTERNALID') <> NIL
								cUnMedExt := oXmlBusinItem:_STOCKTURNOVERITEM[nX1]:_UNITOFMEASUREINTERNALID:Text

								cUnMed := CFGA070INT( cMarca, 'SAH', 'AH_UNIMED', cUnMedExt )
								cUnMed	:= MTIGetCod(cUnMed)
								If SAH->(DbSeek(xFilial("SAH")+cUnMed))
									aAdd(aItens,{"D3_UM",cUnMed,})
								Else
									lRet := .F.
									cXMLRet := 'N„o encontrado o unidade de medida ' + cUnMed
								EndIf
							ElseIf XmlChildEx(oXmlBusinItem:_STOCKTURNOVERITEM[nX1], '_UNITOFMEASURECODE') <> NIL
								cUnMed := oXmlBusinItem:_STOCKTURNOVERITEM[nX1]:_UnitOfMeasureCode:Text
								aAdd(aItens,{"D3_UM",cUnMed,})
							Else
								lRet := .F.
								cXMLRet := STR0004 //'N„o existe a Tag UnitOfMeasure'
							EndIf
						EndIf

						If lRet
							If XmlChildEx(oXmlBusinItem:_STOCKTURNOVERITEM[nX1], '_WAREHOUSEINTERNALID') <> NIL
								cArmzmExt := oXmlBusinItem:_STOCKTURNOVERITEM[nX1]:_WarehouseInternalId:Text

								cArmzm := CFGA070INT( cMarca, 'NNR', 'NNR_CODIGO', cArmzmExt )
								cArmzm	:= MTIGetCod(cArmzm)
								If !Empty(cArmzm) .And. NNR->(DbSeek(xFilial("NNR")+cArmzm))
									aAdd(aItens,{"D3_LOCAL",cArmzm,})
								Else
									lRet := .F.
									cXMLRet := STR0005 + " " + RTrim(cArmzm) //'N„o encontrado o Armazem'
								EndIf
							ElseIf XmlChildEx(oXmlBusinItem:_STOCKTURNOVERITEM[nX1], '_WAREHOUSECODE') <> NIL
								cArmzm := oXmlBusinItem:_STOCKTURNOVERITEM[nX1]:_WarehouseCode:Text
								aAdd(aItens,{"D3_LOCAL",cArmzm,})
							Else
								lRet := .F.
								cXMLRet := STR0006 //'N„o existe a Tag "WarehouseCode"'
							EndIf
						EndIf

						If lRet
							If XmlChildEx(oXmlBusinItem:_STOCKTURNOVERITEM[nX1], '_UNITPRICE') <> NIL
								aAdd(aItens,{"D3_CUSTO1",VAL(oXmlBusinItem:_STOCKTURNOVERITEM[nX1]:_UnitPrice:Text),})
								lUnitPrice := .T.
							EndIf
						EndIf

						If lRet
							If XmlChildEx(oXmlBusinItem:_STOCKTURNOVERITEM[nX1], '_QUANTITY') <> NIL
								nQuant := VAL(oXmlBusinItem:_STOCKTURNOVERITEM[nX1]:_Quantity:Text)
								aAdd(aItens,{"D3_QUANT",nQuant,})
							Else
								lRet := .F.
								cXMLRet := STR0007 //'N„o exite a Tag "Quantity"'
							EndIf
						EndIf

						If lRet .And. lUnitPrice
							If XmlChildEx(oXmlBusinItem:_STOCKTURNOVERITEM[nX1], '_TOTALPRICE') <> NIL
								aAdd(aItens,{"D3_TOTAL",Round(VAL(oXmlBusinItem:_STOCKTURNOVERITEM[nX1]:_UnitPrice:Text),2),})
							EndIf
						EndIf

						If lRet
							If XmlChildEx(oXmlBusinItem:_STOCKTURNOVERITEM[nX1], '_EMISSIONDATE') <> NIL    ///EmissionDate
								dtEmiss := StrTran(oXmlBusinItem:_STOCKTURNOVERITEM[nX1]:_EmissionDate:Text, '-', '')
								dtEmiss := STOD( dtEmiss )
								aAdd(aItens,{"D3_EMISSAO",dtEmiss,})
							Else
								lRet := .F.
								cXMLRet := STR0008 //'N„o existe a Tag "Date"'
							EndIf
						EndIf

						If lRet
							If XmlChildEx(oXmlBusinItem:_STOCKTURNOVERITEM[nX1], '_REQUESTITEMINTERNALID') <> NIL  //SolicitaÁ„o de armazem
								cSA := CFGA070INT(cMarca,'SCP','CP_ITEM', oXmlBusinItem:_STOCKTURNOVERITEM[nX1]:_RequestItemInternalId:Text)
								If !Empty(cSA)
									aSA := Separa(cSA,"|")
									If Len(aSA) > 0
										aAdd(aItens,{"D3_NUMSA",aSA[1,3],})
										aAdd(aItens,{"D3_ITEMSA",aSA[1,4],})
									Endif
								Endif
							Endif
						EndIf

						If lRet
							If XmlChildEx(oXmlBusinItem:_STOCKTURNOVERITEM[nX1], '_REQUESTITEMINTERNALID') <> NIL  //SolicitaÁ„o de armazem
								cSA := CFGA070INT(cMarca,'SCP','CP_ITEM', oXmlBusinItem:_STOCKTURNOVERITEM[nX1]:_RequestItemInternalId:Text)
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
							If XmlChildEx(oXmlBusinItem:_STOCKTURNOVERITEM[nX1], '_LOTORSERIALNUMBER') <> NIL
								cLote		:= oXmlBusinItem:_STOCKTURNOVERITEM[nX1]:_LotOrSerialNumber:Text
								aAdd(aItens,{"D3_LOTECTL",cLote,})
							Else
								lRet := .F.
								cXMLRet := STR0009 //'N„o existe a Tag "LotNumber"'
							EndIf

							// Para processos de Requisicao e Estorno nao e obrigatoria a data de validade, somente em Devolucao
							If lRet .And. ValType(cTpMov) == "C" .And. cTpMov <= "500" .And. Upper(oXmlM241:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
								If XmlChildEx(oXmlBusinItem:_STOCKTURNOVERITEM[nX1], '_LOTEXPIRATIONDATE') <> NIL
									dtValLot 	:= StrTran(oXmlBusinItem:_STOCKTURNOVERITEM[nX1]:_LotExpirationDate:Text, '-', '')
									dtValLot	:= STOD( dtValLot )
									aAdd(aItens,{"D3_DTVALID",dtValLot,})
								Else
									lRet := .F.
									cXMLRet := STR0011 //'N„o existe a Tag "LotExpirationDate"'
								EndIf
							EndIf

							If lRet .And. Rastro(cProd,"S")
								If XmlChildEx(oXmlBusinItem:_STOCKTURNOVERITEM[nX1], '_SUBLOTNUMBER') <> NIL
									If dbSeek(xFilial("SD5")+cProd+cArmzm+cLote+oXmlM241:_TotvsMessage:_BusinessMessage:_BusinessContent:_SubLotNumber:Text)
										cSubLote	:= oXmlM241:_TotvsMessage:_BusinessMessage:_BusinessContent:_SubLotNumber:Text
										aAdd(aItens,{"D3_NUMLOTE",cSubLote,})
									EndIf
								Else
									lRet := .F.
									cXMLRet := STR0010 //'N„o existe a Tag "SubLotNumber"'
								EndIf
							EndIf
						EndIf

						If lRet .And. Localiza(cProd)
							If XmlChildEx(oXmlBusinItem:_STOCKTURNOVERITEM[nX1], '_BINLOCATION') <> NIL       // BinLocation
								cEnd	:= oXmlBusinItem:_STOCKTURNOVERITEM[nX1]:_BINLOCATION:Text
								aAdd(aItens,{"D3_LOCALIZ",cEnd,})
							Elseif cTpMov > "500"
								lRet := .F.
								cXMLRet := "BinLocation n„o informado corretamente" //'N„o existe a Tag "Address"'
							EndIf

							If lRet .And. XmlChildEx(oXmlBusinItem:_STOCKTURNOVERITEM[nX1], '_NUMBERSERIES') <> NIL
								cNumSer	:= oXmlBusinItem:_STOCKTURNOVERITEM[nX1]:_NumberSeries:Text
								aAdd(aItens,{"D3_NUMSERI",cNumSer,})
							EndIf
						EndIf

						If lRet
							If XmlChildEx(oXmlBusinItem:_STOCKTURNOVERITEM[nX1], '_COSTCENTERINTERNALID') <> NIL
								cCostCenter := oXmlBusinItem:_STOCKTURNOVERITEM[nX1]:_CostCenterInternalID:Text
								cCostCenter := CFGA070INT(cMarca,'CTT','CTT_CUSTO',cCostCenter)
								cCostCenter := MTIGetCod(cCostCenter)
								If !Empty(cCostCenter)
									If CTT->(DbSeek(xFilial("CTT")+cCostCenter))
										aAdd(aItens,{"D3_CC",cCostCenter,NIL})
									Else
										lRet := .F.
										cXMLRet := STR0020 + " " + RTrim(cCostCenter) //"Centro de custo inv·lido/n„o encontrado."
									EndIf
								EndIf
							EndIf
						EndIf

						If Upper(oXmlM241:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
							Inclui	:= .T.
							nOpcx	:= 3	// Inclusao
						Else
							nOpcx	:= 6	// Estorno
							aAdd(aItens,{"D3_NUMSEQ",MTIGetCod(cValInt)})
							aAdd(aItens,{"INDEX",7,})
						EndIf

						If lRet .And. Upper(Alltrim(cMarca)) == "PIMS"
							If XmlChildEx(oXmlM241:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT, '_CODE') <> NIL .And.;
												!Empty(oXmlM241:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_CODE:Text)
								AADD(aItens ,{'D3_NRBPIMS' 		,oXmlM241:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text					,Nil} )
							EndIf
						EndIf
						If lRet .And. XmlChildEx(oXmlBusinItem:_STOCKTURNOVERITEM[nX1], '_MAINORDERCODE') <> NIL .And.;
											!Empty(oXmlBusinItem:_STOCKTURNOVERITEM[nX1]:_MAINORDERCODE:Text)
							AADD(aItens ,{'D3_OP',oXmlBusinItem:_STOCKTURNOVERITEM[nX1]:_MAINORDERCODE:Text	,Nil} )
						EndIf
					Else
						If lRet
							lRet   := .F.
							cXMLRet := STR0016 //"Atualize EAI"
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
					aErroAuto := GetAutoGRLog()

					For nCount := 1 To Len(aErroAuto)
						cLogErro += StrTran( StrTran( aErroAuto[nCount], "<", "" ), "-", "" ) + (" | ")
					Next nCount

					lRet	 := .F.
					cXMLRet := cLogErro
				Else
					If nOpcx == 3
						cValInt := cEmpAnt + '|' + RTrim(xFilial('SD3')) + '|' + RTrim(SD3->D3_DOC) + '|' + RTrim(SD3->D3_NUMSEQ)
						CFGA070Mnt(cMarca,"SD3","D3_NUMSEQ",cValExt,cValInt)
					Else
						CFGA070Mnt(NIL,"SD3"  ,"D3_NUMSEQ", NIL , cValInt ,.T.) // remove do de/para
					EndIf

					//-- Dados ok para gravaÁ„o
					cXMLRet := '<ListOfInternalId>'
					cXMLRet += 	'<InternalId>'
					cXMLRet += 		'<Name>StockTurnover</Name>'
					cXMLRet += 		'<Origin>'     + cValExt +'</Origin>'
					cXMLRet += 		'<Destination>'+ cValInt +'</Destination>'
					cXMLRet += 	'</InternalId>'
					cXMLRet += '</ListOfInternalId>'
				EndIf
			EndIf
		Else
			lRet    := .F.
			cXMLRet := 	STR0017 + ' | ' +cXmlErro + ' | ' + cXmlWarn //"Xml mal formatado "
		EndIf

	ElseIf   cTypeMessage == EAI_MESSAGE_RESPONSE
		oXmlM241 := XmlParser(cXml, "_", @cXmlErro, @cXmlWarn)

		If oXmlM241 <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
			If Type("oXmlM241:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U"
				cMarca  := oXmlM241:_TotvsMessage:_MessageInformation:_Product:_Name:Text
			EndIf

			oXmlM241 := oXmlM241:_TotvsMessage

			If XmlChildEx( oXmlM241:_ResponseMessage , '_RETURNCONTENT' ) == Nil
				lRet    := .F.
				cXmlRet := "Processamento pela outra aplicaÁ„o n„o teve sucesso, Estrurura ReturnContent n?o Localizada"
				//-- Transforma estrutura das mensagens de erro em array para concatenar com a mensagem de retorno

				If XmlChildEx( oXmlM241:_ResponseMessage:_ProcessingInformation, '_LISTOFMESSAGES' ) <> Nil
					If	ValType(oXmlM241:_ResponseMessage:_ProcessingInformation:_ListOfMessages)<>'A'
						XmlNode2Arr(oXmlM241:_ResponseMessage:_ProcessingInformation:_ListOfMessages, "_ListOfMessages")
					EndIf
					If Type( "oXmlM241:_ResponseMessage:_ProcessingInformation:_ListOfMessages" ) == "A"
						For nCount := 1 To Len( oXmlM241:_ResponseMessage:_ProcessingInformation:_ListOfMessages )
							If XmlChildEx( oXmlM241:_ResponseMessage:_ProcessingInformation:_ListOfMessages[nCount], '_MESSAGE' ) <> Nil
								cXmlRet += ' | ' + oXmlM241:_ResponseMessage:_ProcessingInformation:_ListOfMessages[nCount]:_Message:Text
							EndIf
						Next nCount
					EndIf
				EndIf

			Else
				//-- Identifica se o processamento pelo parceiro ocorreu com sucesso
				If XmlChildEx( oXmlM241:_ResponseMessage , '_RETURNCONTENT' ) <> Nil .And. XmlChildEx( oXmlM241:_ResponseMessage:_ReturnContent , '_LISTOFINTERNALID' ) <> Nil .And. XmlChildEx( oXmlM241:_ResponseMessage:_ReturnContent:_LISTOFINTERNALID, '_INTERNALID' ) <> Nil .And. XmlChildEx(oXmlM241:_ResponseMessage:_ProcessingInformation, '_STATUS' ) <> Nil .And. Upper(oXmlM241:_ResponseMessage:_ProcessingInformation:_Status:Text) == 'OK'

					// Se n„o for array, faz a transformaÁ„o
					If Type("oXmlM241:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") != "A"
						XmlNode2Arr(oXmlM241:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, "_InternalId")
					EndIf

					For nCount := 1 To Len(oXmlM241:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId)
						cValInt := oXmlM241:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nCount]:_Destination:Text
						cValExt := oXmlM241:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nCount]:_Origin:Text


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
					lRet    := .F.
					cXmlRet := "Processamento pela outra aplicaÁ„o n„o teve sucesso" //-- Processamento pela outra aplicaÁ„o n„o teve sucesso
					//-- Transforma estrutura das mensagens de erro em array para concatenar com a mensagem de retorno

					If XmlChildEx( oXmlM241:_ResponseMessage:_ProcessingInformation, '_LISTOFMESSAGES' ) <> Nil
						If	ValType(oXmlM241:_ResponseMessage:_ProcessingInformation:_ListOfMessages)<>'A'
							XmlNode2Arr(oXmlM241:_ResponseMessage:_ProcessingInformation:_ListOfMessages, "_ListOfMessages")
						EndIf
						If Type( "oXmlM241:_ResponseMessage:_ProcessingInformation:_ListOfMessages" ) == "A"
							For nCount := 1 To Len( oXmlM241:_ResponseMessage:_ProcessingInformation:_ListOfMessages )
								If XmlChildEx( oXmlM241:_ResponseMessage:_ProcessingInformation:_ListOfMessages[nCount], '_MESSAGE' ) <> Nil
									cXmlRet += ' | ' + oXmlM241:_ResponseMessage:_ProcessingInformation:_ListOfMessages[nCount]:_Message:Text
								EndIf
							Next nCount
						EndIf
					EndIf
				EndIf
			EndIf

		Else
			lRet    := .F.
			cXMLRet := 	STR0017 + ' | ' +cXmlErro + ' | ' + cXmlWarn //"Xml mal formatado "
		EndIf

	ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := '1.000|1.001|1.002|1.003|1.004|1.005'
	EndIf

//Tratamento do envio de mensagens
ElseIf nTypeTrans == TRANS_SEND
	If	Type("l185")<>"U" .And. l185 .And. ValType(a241ISD3)=="A"
		If Len(a241ISD3) > 0 .And. ValType(a241ISD3[1]) == "N"
			SD3->(DbGoto(a241ISD3[1]))
		EndIf
		If !Empty(AllTrim(SD3->D3_ESTORNO))
			cEvent := 'delete'
		Endif
	Elseif Type("l241") <> "U" .And. !Empty(AllTrim(SD3->D3_ESTORNO))
		cEvent := "delete"
	EndIf

	cNumDoc := SD3->D3_DOC
	cNumSeq := SD3->D3_NUMSEQ
	//Monta XML de envio de mensagem unica

	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>StockTurnover</Entity>'
	cXMLRet +=     '<Event>' + cEvent + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="InternalId">' + cEmpAnt + '|' + RTrim(xFilial('SD3')) + '|' + RTrim(cNumDoc) + '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'

	cXMLRet += '<BusinessContent>'

	cXMLRet += 	'<Code>' + RTrim(cNumDoc) + '</Code>'
	cXMLRet += 	'<InternalId>' + cEmpAnt + '|' + RTrim(xFilial('SD3')) + '|' + RTrim(cNumDoc) + '|' + RTrim(cNumSeq) + '</InternalId>'
	cXMLRet += 	'<CompanyId>' + cEmpAnt + '</CompanyId>'
	cXMLRet += 	'<BranchId>' + RTrim(xFilial("SD3")) + '</BranchId>'
	cXMLRet += 	'<CompanyInternalId>' + cEmpAnt + '|' + RTrim(xFilial('SD3')) + '</CompanyInternalId>'
	cXMLRet += 	'<Number/>'
	If SD3->D3_TM <= "500"
		cXMLRet += 	'<Type>' + "E" + '</Type>'
	Else
		cXMLRet += 	'<Type>' + "S" + '</Type>'
	EndIf
	cXMLRet += 	'<MovementTypeCode>' + RTrim(SD3->D3_TM) + '</MovementTypeCode>'
	If SF5->(dbSeek(xFilial("SF5")+SD3->D3_TM))
		cXMLRet += 	'<DocumentType>' + RTrim(SF5->F5_TIPO) + '</DocumentType>'
	Else
		cXMLRet += 	'<DocumentType/>'
	EndIf
	cXMLRet += 	'<Series>' + Space(8) + '</Series>'
	cXMLRet += 	'<RegisterDateTime>' + Transform(DToS(SD3->D3_EMISSAO),"@R 9999-99-99") + '</RegisterDateTime>'
	cXMLRet += 	'<DeliveryDateTime>' + Transform(DToS(dDataBase),"@R 9999-99-99") + '</DeliveryDateTime>'
	cXMLRet += 	'<AbatementDateTime>' + Transform(DToS(dDataBase),"@R 9999-99-99") + '</AbatementDateTime>'

	oTempTbl := CarregaTot(cNumDoc)

	cQuery := "SELECT SD3.R_E_C_N_O_ RECNO, SD3.* FROM " + RetSqlName("SD3") + " SD3 "
	cQuery += "WHERE SD3.D3_FILIAL = '" + FWxFilial("SD3") + "' "
	cQuery += "AND SD3.D3_DOC = '" + cNumDoc + "' "
	cQuery += "AND SD3.D_E_L_E_T_ = ' ' "
	If cEvent == "delete"
		cQuery += "AND ( SD3.D3_ESTORNO <> '" + CriaVar( "D3_ESTORNO", .F. ) + "' AND SD3.D3_TM <> '499' ) "
	EndIf
	cQuery += "ORDER BY D3_FILIAL, D3_DOC, D3_COD, D3_LOCAL"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasMov)

	cChaveAnt :=  (cAliasMov)->D3_FILIAL + (cAliasMov)->D3_DOC + (cAliasMov)->D3_COD + (cAliasMov)->D3_LOCAL

	//-- Item da movimentacao
	cXMLRet += '<ListOfStockTurnoverItem>'

	While !(cAliasMov)->(EoF())

		If cChaveAnt != (cAliasMov)->D3_FILIAL + (cAliasMov)->D3_DOC + (cAliasMov)->D3_COD + (cAliasMov)->D3_LOCAL
			aSaldos := {}
		EndIf

		If ((ValType(a241ISD3)=="A" .And. Ascan( a241ISD3, (cAliasMov)->RECNO ) > 0 ) .Or. (((ValType(a241ISD3)<> "A" .And. Ascan(a241ISD3, (cAliasMov)->RECNO ) == 0 ) .Or. Len(a241ISD3) == 0) .And.  (cEvent == "upsert" .Or. cEvent == "delete" )))
			cXMLRet += '<StockTurnoverItem>'
			cXMLRet += 	'<Code>' + RTrim(cNumDoc) + '</Code>'
			cXMLRet += 	'<InternalId>' + cEmpAnt + '|' + RTrim(xFilial('SD3')) + '|' + RTrim((cAliasMov)->D3_DOC) + '|' + RTrim((cAliasMov)->D3_NUMSEQ) + '</InternalId>'
			cXMLRet += 	'<EmissionDate>' + Transform((cAliasMov)->D3_EMISSAO,"@R 9999-99-99") + '</EmissionDate>'
			cXMLRet += 	'<ItemCode>' + RTrim((cAliasMov)->D3_COD) + '</ItemCode>'
			cXMLRet += 	'<ItemInternalId>' + IntProExt(/*cEmpresa*/, /*cFilial*/, (cAliasMov)->D3_COD, cPrdVer)[2] + '</ItemInternalId>'
			cXMLRet += 	'<ItemReferenceCode>' + RTrim((cAliasMov)->D3_COD) + '</ItemReferenceCode>'
			cXMLRet += 	'<UnitPrice>' + RTrim(cValToChar((cAliasMov)->D3_CUSTO1/(cAliasMov)->D3_QUANT)) + '</UnitPrice>'
			cXMLRet += 	'<TotalPrice>' + RTrim(cValToChar((cAliasMov)->D3_CUSTO1)) + '</TotalPrice>'
			cXMLRet += 	'<Quantity>' + RTrim(cValToChar((cAliasMov)->D3_QUANT)) + '</Quantity>'
			cXMLRet += 	'<UnitOfMeasureInternalId>' + IntUndExt(/*cEmpresa*/, /*cFilial*/, (cAliasMov)->D3_UM, cUndVer)[2] + '</UnitOfMeasureInternalId>'
			cXMLRet += 	'<UnitOfMeasureCode>' + RTrim((cAliasMov)->D3_UM) + '</UnitOfMeasureCode>'
			cXMLRet += 	'<WarehouseInternalId>' + IntLocExt(/*cEmpresa*/, /*cFilial*/, (cAliasMov)->D3_LOCAL, cLocVer)[2] + '</WarehouseInternalId>'
			cXMLRet += 	'<WarehouseCode>' + RTrim((cAliasMov)->D3_LOCAL) + '</WarehouseCode>'
			cXMLRet += 	'<DeliveryDateTime>' + Transform(DToS(dDataBase),"@R 9999-99-99") + '</DeliveryDateTime>'

			If Empty((cAliasMov)->D3_CC)
				cXMLRet += 	'<CostCenterInternalId/>'
				cXMLRet += 	'<CostCenterCode/>'
			Else
				cXMLRet += 	'<CostCenterInternalId>' + IntCusExt(/*cEmpresa*/, /*cFilial*/, (cAliasMov)->D3_CC, cCusVer)[2] + '</CostCenterInternalId>'
				cXMLRet += 	'<CostCenterCode>' + RTrim((cAliasMov)->D3_CC) + '</CostCenterCode>'
			EndIf

			If Empty((cAliasMov)->D3_CONTA)
				cXMLRet += 	'<AccountantAcountInternalId/>'
			Else
				cXMLRet += 	'<AccountantAcountInternalId>' + cEmpAnt + '|' + RTrim(xFilial('SD3')) + '|' + RTrim((cAliasMov)->D3_CONTA) + '</AccountantAcountInternalId>'
			EndIf
			cXMLRet += 	'<MainOrderCode>' + RTrim((cAliasMov)->D3_OP) + '</MainOrderCode>'

			If Empty((cAliasMov)->D3_PROJPMS)
				cXMLRet += 	'<ProjectInternalId/>'
				cXMLRet += 	'<TaskInternalId/>'
			Else
				cXMLRet += 	'<ProjectInternalId>' + IntPrjExt(/*cEmpresa*/, /*cFilial*/, (cAliasMov)->D3_PROJPMS, cPrjVer)[2] + '</ProjectInternalId>'
				cXMLRet += 	'<TaskInternalId>' + IntTrfExt(/*cEmpresa*/, /*cFilial*/, (cAliasMov)->D3_PROJPMS, '0001', (cAliasMov)->D3_TASKPMS, cTrfVer)[2] + '</TaskInternalId>'
			EndIf

			If !Empty((cAliasMov)->D3_NUMSA) .And. !Empty((cAliasMov)->D3_ITEMSA)
				cXMLRet += 	'<RequestItemInternalId>' + cEmpAnt + "|" + RTrim(xFilial("SD3")) + "|" + RTrim((cAliasMov)->D3_NUMSA) + "|" + RTrim((cAliasMov)->D3_ITEMSA) + '</RequestItemInternalId>'
			Else
				cXMLRet += 	'<RequestItemInternalId/>'
			Endif

			cXMLRet +=	'<Observation>' + " " + '</Observation>'
			cXMLRet +=	'<LotOrSerialNumber>' + RTrim((cAliasMov)->D3_LOTECTL) + '</LotOrSerialNumber>'

			If Empty((cAliasMov)->D3_DTVALID)
				cXMLRet +=	'<LotExpirationDate/>'
			Else
				cXMLRet +=	'<LotExpirationDate>' + Transform((cAliasMov)->D3_DTVALID,"@R 9999-99-99") + '</LotExpirationDate>'
			EndIf

			cXMLRet +=	'<BinLocation>' + RTrim((cAliasMov)->D3_LOCALIZ) + '</BinLocation>'
			cXMLRet +=	'<NumberSeries>' + RTrim((cAliasMov)->D3_NUMSERI) + '</NumberSeries>'

			cXMLRet += MTICalPrd(@aSaldos,oTempTbl:GetAlias(),(cAliasMov)->D3_TM,(cAliasMov)->D3_COD,(cAliasMov)->D3_LOCAL,(cAliasMov)->D3_LOTECTL,(cAliasMov)->D3_LOCALIZ,(cAliasMov)->D3_NUMSERI)

			If IsIntegTop() //Possui integraÁ„o com o RM Solum
				aRateio := RatEst((cAliasMov)->D3_FILIAL + (cAliasMov)->D3_COD + (cAliasMov)->D3_LOCAL + (cAliasMov)->D3_EMISSAO + (cAliasMov)->D3_NUMSEQ)

				cXMLRet +=	'<ListOfApportionStockTurnoverItem>'
				//-- Rateio da movimentaÁ„o
				For nCont := 1 To Len(aRateio)
					cXMLRet +=	'<ApportionStockTurnoverItem>'
					cXMLRet +=		'<InternalId>' + cEmpAnt + '|' + RTrim(xFilial('SD3')) + '|' + RTrim(cNumDoc) + '|' + RTrim((cAliasMov)->D3_NUMSEQ)+ '|' + RTrim(cValToChar(nCont)) + '</InternalId>'
					cXMLRet +=		'<DepartamentCode/>'
					cXMLRet +=		'<DepartamentInternalId/>'
					cXMLRet +=		'<CostCenterInternalId>' + IntCusExt(/*cEmpresa*/, /*cFilial*/, aRateio[nCont][1])[2] + '</CostCenterInternalId>'
					cXMLRet +=		'<AccountantAcountInternalId>' + RTrim(aRateio[nCont][2]) + '</AccountantAcountInternalId>'
					cXMLRet +=		'<ProjectInternalId>' + IIf(!Empty(aRateio[nCont][6]), IntPrjExt(/*cEmpresa*/, /*cFilial*/, aRateio[nCont][6])[2], '') + '</ProjectInternalId>'
					cXMLRet +=		'<SubProjectInternalId/>'
					cXMLRet +=		'<TaskInternalId>' + IIf(!Empty(aRateio[nCont][7]), IntTrfExt(/*cEmpresa*/, /*cFilial*/, aRateio[nCont][6], '0001', aRateio[nCont][7])[2], '')  + '</TaskInternalId>'
					cXMLRet +=		'<Value>' + RTrim(cValToChar(0.00)) + '</Value>'
					cXMLRet +=		'<Percentual>' + RTrim(cValToChar(aRateio[nCont][5])) + '</Percentual>'
					cXMLRet +=		'<Quantity>' + RTrim(cValToChar(aRateio[nCont][8])) + '</Quantity>'
					cXMLRet +=		'<Observation/>'
					cXMLRet +=	'</ApportionStockTurnoverItem>'
				Next nCont

				cXMLRet +=	'</ListOfApportionStockTurnoverItem>'
			EndIf

			cXMLRet += '</StockTurnoverItem>'
		EndIf

		cChaveAnt := (cAliasMov)->D3_FILIAL + (cAliasMov)->D3_DOC + (cAliasMov)->D3_COD + (cAliasMov)->D3_LOCAL

		(cAliasMov)->(dbSkip())

	End

	(cAliasMov)->(dbCloseArea())

	(oTempTbl:GetAlias())->(dbCloseArea())

	cXMLRet += '</ListOfStockTurnoverItem>'
	cXMLRet += '</BusinessContent>'

EndIf

AdpLogEAI(5, "MATI241", cXmlRet, lRet)

Return { lRet, cXMLRet }

//-------------------------------------------------------------------
/*/{Protheus.doc} MTICalPrd()
Soma a quantidade de produtos iguais do mesmo lote ou endereÁo ou sÈrie
para calculo dos saldos anteriores e devolve trecho do XML de envio referente
ao item da movimentaÁ„o.

@author Leonardo Quintania
@since 11/12/2013
@version 1.0
@return NIL

@maintenance mauro.sergio
@date 08/11/2019
@version P12.1.27
@return cXmlRet

AlÈm da mudanÁa do conceito da funÁ„o, foi adicionado um sistema de cache dos valores
para evitar diversas chamadas das funÁıes SaldoLote e SaldoSBF. Essa abordagem foi utilizada
pois neste momento a rotina est· dentro de uma transaÁ„o, e ao tentar alterar um campo
da tabela tempor·ria ponteirando-o, trava a base de dados e o prÛximo dbSeek n„o consegue
finalizar sua execuÁ„o.

/*/
//-------------------------------------------------------------------
Static Function MTICalPrd(aSaldos,cAliTotais,cTes,cCod,cArmazem,cLote,cEndereco,cNumSerie)

	Local nRet			:= 0
	Local cXmlRet		:= ""
	Local cChave		:= ""
	Local nPos			:= 0

	(cAliTotais)->(dbSetOrder(1))

	cChave := "ESTOQUE " + cCod + cArmazem

	nPos := Ascan(aSaldos, {|x| x[1] == cChave})

	If nPos == 0 .And. (cAliTotais)->(dbSeek(cChave))

		SB2->(dbSeek(FWxFilial("SB2")+cCod+cArmazem))
		If cTes <= "500"
			nRet := SB2->B2_QATU - (cAliTotais)->TOTAL
		Else
			nRet := SB2->B2_QATU + (cAliTotais)->TOTAL
		EndIf

		Aadd(aSaldos, {cChave, nRet})

	ElseIf nPos > 0

		nRet := aSaldos[nPos][2]

	EndIf

	cXmlRet += '<TotalStock>'  + AllTrim(cValToChar(nRet)) + '</TotalStock>'

	If !Empty(cLote)

		nRet := 0

		cChave := "LOTE    " + cCod + cArmazem + cLote

		nPos := Ascan(aSaldos, {|x| x[1] == cChave})

		If nPos == 0 .And. (cAliTotais)->(dbSeek(cChave))

			If cTes <= "500"
				nRet := SaldoLote(cCod,cArmazem,cLote,NIL,.T.,.T.,NIL,dDataBase) - (cAliTotais)->TOTAL
			Else
				nRet := SaldoLote(cCod,cArmazem,cLote,NIL,.T.,.T.,NIL,dDataBase) + (cAliTotais)->TOTAL
			EndIf

			Aadd(aSaldos, {cChave, nRet})

		ElseIf nPos > 0

			nRet := aSaldos[nPos][2]

		EndIf

		cXmlRet += '<LotStock>' + AllTrim(cValToChar(nRet)) + '</LotStock>'

	EndIf

	If !Empty(cEndereco)

		nRet := 0

		cChave := "ENDERECO" + cCod + cArmazem + cLote + cEndereco

		nPos := Ascan(aSaldos, {|x| x[1] == cChave})

		If nPos == 0 .And. (cAliTotais)->(dbSeek(cChave))

			If cTes <= "500"
				nRet := SaldoSBF(cArmazem,cEndereco,cCod,NIL,cLote,NIL,.T.) - (cAliTotais)->TOTAL
			Else
				nRet := SaldoSBF(cArmazem,cEndereco,cCod,NIL,cLote,NIL,.T.) + (cAliTotais)->TOTAL
			EndIf

			Aadd(aSaldos, {cChave, nRet})

		ElseIf nPos > 0

			nRet := aSaldos[nPos][2]

		EndIf

		cXmlRet += '<BinStock>' + AllTrim(cValToChar(nRet)) + '</BinStock>'

	EndIf

	If !Empty(cNumSerie)

		nRet := 0

		cChave := "SERIE   " + cCod + cArmazem + cLote + cEndereco + cNumSerie

		nPos := Ascan(aSaldos, {|x| x[1] == cChave})

		If nPos == 0 .And. (cAliTotais)->(dbSeek(cChave))

			If cTes <= "500"
				nRet := SaldoSBF(cArmazem,cEndereco,cCod,cNumSerie,cLote,NIL,.T.) - (cAliTotais)->TOTAL
			Else
				nRet := SaldoSBF(cArmazem,cEndereco,cCod,cNumSerie,cLote,NIL,.T.) + (cAliTotais)->TOTAL
			EndIf

			Aadd(aSaldos, {cChave, nRet})

		ElseIf nPos > 0

			nRet := aSaldos[nPos][2]

		EndIf

		cXmlRet += '<SeriesStock>' + AllTrim(cValToChar(nRet)) + '</SeriesStock>'

	EndIf

Return cXmlRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MTICalPrd()
Soma a quantidade de produtos iguais do mesmo lote ou endereÁo
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
Recebe a chave de busca da movimentaÁ„o de estoque e monta o rateio

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
/*/{Protheus.doc} CarregaTot
Monta tabela tempor·ria com as totalizaÁıes por ArmazÈm, EndereÁo, Lote e SÈrie
para ser consultado pela funÁ„o MTICalPrd

@author  mauro.sergio
@version P12.1.27
@since   08/11/2019

@return oTmpTbl - Objeto da classe FWTemporaryTable
/*/
//-------------------------------------------------------------------
Static Function CarregaTot(cDoc)

	Local aStru   := {}
	Local cQuery  := ""
    Local oTmpTbl := Nil
    Local cAlias  := GetNextAlias()

	Local nTamSD3Cod := TamSX3("D3_COD")[1]
	Local nTamSD3Loc := TamSX3("D3_LOCAL")[1]
	Local nTamSD3Lot := TamSX3("D3_LOTECTL")[1]
	Local nTamSD3End := TamSX3("D3_LOCALIZ")[1]
	Local nTamSD3Ser := TamSX3("D3_NUMSERI")[1]
	Local nTamD3QtdI := TamSX3("D3_QUANT")[1]
	Local nTamD3QtdD := TamSX3("D3_QUANT")[2]

	Local cSD3Name := RetSqlName("SD3")
	Local cFilSD3  := FWxFilial("SD3")

	Aadd(aStru, {"D3_COD"    , "C", nTamSD3Cod, 0})
	Aadd(aStru, {"D3_LOCAL"  , "C", nTamSD3Loc, 0})
	Aadd(aStru, {"D3_LOTECTL", "C", nTamSD3Lot, 0})
	Aadd(aStru, {"D3_LOCALIZ", "C", nTamSD3End, 0})
	Aadd(aStru, {"D3_NUMSERI", "C", nTamSD3Ser, 0})
	Aadd(aStru, {"TOTALIZADO", "C",          8, 0})
	Aadd(aStru, {"TOTAL"     , "N", nTamD3QtdI, nTamD3QtdD})

	oTmpTbl := FWTemporaryTable():New(cAlias)
	oTmpTbl:SetFields( aStru )
	oTmpTbl:AddIndex('I1', {"TOTALIZADO", "D3_COD", "D3_LOCAL", "D3_LOTECTL", "D3_LOCALIZ", "D3_NUMSERI"})
	oTmpTbl:Create()

	cQuery := "INSERT INTO " + oTmpTbl:GetRealName() + " (D3_COD, D3_LOCAL, D3_LOTECTL, D3_LOCALIZ, D3_NUMSERI, TOTALIZADO, TOTAL, D_E_L_E_T_, R_E_C_D_E_L_) "

	// Totalizador por ArmazÈm
	cQuery += "SELECT D3_COD, D3_LOCAL, '" + Space(nTamSD3Lot) + "' D3_LOTECTL, "
	cQuery += "'" + Space(nTamSD3End) + "' D3_LOCALIZ, "
	cQuery += "'" + Space(nTamSD3Ser) + "' D3_NUMSERI, "
	cQuery += "'ESTOQUE' TOTALIZADO, SUM(D3_QUANT) TOTAL, "
	cQuery += "' ' D_E_L_E_T_, "
	cQuery += "0 R_E_C_D_E_L_ "
	cQuery += "FROM " + cSD3Name + " "
	cQuery += "WHERE D3_FILIAL = '" + cFilSD3 + "' "
	cQuery += "AND D3_DOC = '" + cDoc + "' "
	cQuery += "GROUP BY D3_COD, D3_LOCAL "

	cQuery += "UNION ALL "

	// Totalizador por Lote
	cQuery += "SELECT D3_COD, D3_LOCAL, D3_LOTECTL, "
	cQuery += "'" + Space(nTamSD3End) + "' D3_LOCALIZ, "
	cQuery += "'" + Space(nTamSD3Ser) + "' D3_NUMSERI, "
	cQuery += "'LOTE' TOTALIZADO, SUM(D3_QUANT) TOTAL, "
	cQuery += "' ' D_E_L_E_T_, "
	cQuery += "0 R_E_C_D_E_L_ "
	cQuery += "FROM " + cSD3Name + " "
	cQuery += "WHERE D3_FILIAL = '" + cFilSD3 + "' "
	cQuery += "AND D3_DOC = '" + cDoc + "' "
	cQuery += "AND D3_LOTECTL <> '" + Space(nTamSD3Lot) + "' "
	cQuery += "GROUP BY D3_COD, D3_LOCAL, D3_LOTECTL "

	cQuery += "UNION ALL "

	// Totalizador por EndereÁo
	cQuery += "SELECT SD3EXT.D3_COD, SD3EXT.D3_LOCAL, SD3EXT.D3_LOTECTL, SD3EXT.D3_LOCALIZ, "
	cQuery += "'" + Space(nTamSD3Ser) + "' D3_NUMSERI, "
	cQuery += "'ENDERECO' TOTALIZADO, ("
		cQuery += "SELECT SUM(D3_QUANT) FROM " + cSD3Name + " SD3INT "
		cQuery += "WHERE SD3INT.D3_FILIAL = SD3EXT.D3_FILIAL "
		cQuery += "AND SD3INT.D3_DOC = SD3EXT.D3_DOC "
		cQuery += "AND SD3INT.D3_COD = SD3EXT.D3_COD "
		cQuery += "AND SD3INT.D3_LOCAL = SD3EXT.D3_LOCAL "
		cQuery += "AND (SD3INT.D3_LOTECTL = SD3EXT.D3_LOTECTL OR SD3INT.D3_LOCALIZ = SD3EXT.D3_LOCALIZ) "
	cQuery += ") TOTAL, "
	cQuery += "' ' D_E_L_E_T_, "
	cQuery += "0 R_E_C_D_E_L_ "
	cQuery += "FROM " + cSD3Name + " SD3EXT "
	cQuery += "WHERE SD3EXT.D3_FILIAL = '" + cFilSD3 + "' "
	cQuery += "AND SD3EXT.D3_DOC = '" + cDoc + "' "
	cQuery += "AND SD3EXT.D3_LOCALIZ <> '" + Space(nTamSD3End) + "' "
	cQuery += "GROUP BY SD3EXT.D3_FILIAL, SD3EXT.D3_DOC, SD3EXT.D3_COD, SD3EXT.D3_LOCAL, SD3EXT.D3_LOTECTL, SD3EXT.D3_LOCALIZ "

	cQuery += "UNION ALL "

	// Totalizador por SÈrie
	cQuery += "SELECT SD3EXT.D3_COD, SD3EXT.D3_LOCAL, SD3EXT.D3_LOTECTL, SD3EXT.D3_LOCALIZ, SD3EXT.D3_NUMSERI, "
	cQuery += "'SERIE' TOTALIZADO, ("
		cQuery += "SELECT SUM(D3_QUANT) FROM " + cSD3Name + " SD3INT "
		cQuery += "WHERE SD3INT.D3_FILIAL = SD3EXT.D3_FILIAL "
		cQuery += "AND SD3INT.D3_DOC = SD3EXT.D3_DOC "
		cQuery += "AND SD3INT.D3_COD = SD3EXT.D3_COD "
		cQuery += "AND SD3INT.D3_LOCAL = SD3EXT.D3_LOCAL "
		cQuery += "AND (SD3INT.D3_LOTECTL = SD3EXT.D3_LOTECTL OR SD3INT.D3_LOCALIZ = SD3EXT.D3_LOCALIZ OR SD3INT.D3_NUMSERI = SD3EXT.D3_NUMSERI) "
	cQuery += ") TOTAL, "
	cQuery += "' ' D_E_L_E_T_, "
	cQuery += "0 R_E_C_D_E_L_ "
	cQuery += "FROM " + cSD3Name + " SD3EXT "
	cQuery += "WHERE SD3EXT.D3_FILIAL = '" + cFilSD3 + "' "
	cQuery += "AND SD3EXT.D3_DOC = '" + cDoc + "' "
	cQuery += "AND SD3EXT.D3_NUMSERI <> '" + Space(nTamSD3Ser) + "' "
	cQuery += "GROUP BY SD3EXT.D3_FILIAL, SD3EXT.D3_DOC, SD3EXT.D3_COD, SD3EXT.D3_LOCAL, SD3EXT.D3_LOTECTL, SD3EXT.D3_LOCALIZ, SD3EXT.D3_NUMSERI "

	MATExecQry(cQuery)

Return oTmpTbl
