#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TBICONN.CH" 
#INCLUDE "TBICODE.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATI410EC2.CH"


/*/{Protheus.doc} MATI410EC2
Grava o Pedido de Vendas via mensagem unica

@author     Victor Furukawa
@version    1.0
@type       function
@since      10/06/2021
@param      xEnt, J, Json, contendo as informações para gerar o pedido de venda
@param      nTypeTrans, N, numero do tipo de transação
@param      cTypeMessage, C, tipo da mensagem
@return     Array
/*/

Function MATI410EC2(xEnt, nTypeTrans, cTypeMessage)

Local aItens  := {}
Local aLinha  := {}
Local aCabec  := {}
Local aLog    := {}
Local aVetSE1 := {}
Local aVetSE2 := {}
Local aCliExt := {}
Local aCodRes := {}

Local nX        := 0
Local nI        := 0
Local nZ        := 0
Local nTotDesc  := 0
Local nTotAcres := 0
Local nDesc     := 0 
Local nTotFre   := 0
Local nValPg    := 0 
Local nRatFor   := 0
Local nValTot   := 0

Local cProdExt := ""
Local cMarca   := ""
Local cCodCli  := ""
Local cLojCli  := ""
Local cTransp  := ""
Local cMensag  := ""
Local cDocInt  := ""
Local cDocCod  := ""
Local cArm     := ""
Local cCodRes  := ""
Local cDescf   := ""
Local cAlias   := "SC5"
Local cCampo   := "C5_NUM"
Local cCodFor  := ""
Local cC0Num   := ""
Local cMsgRet  := ""
Local cFile    := RetSQLName("F78")
Local cCondPg  := ""
Local cTpOpera := ""
Local cTES	   := ""


Local lRet        := .T.
Local lInteg      := .T.
Local lGerTx      := GetMV("MV_LJGERTX")

Local oItens
Local oForma

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

cMarca  := xEnt:getHeaderValue("ProductName")
cEvent  := alltrim(Upper(xEnt:getPropValue("Event")))    //"upsert" ou "Delete" 

If !Empty(CFGA070Int( cMarca, "SA1","A1_COD", xEnt:getPropValue("CustomerVendorInternalId"))) 
	aCliExt := STRTOKARR(CFGA070Int( cMarca, "SA1","A1_COD", xEnt:getPropValue("CustomerVendorInternalId"), RetSqlName("SA1")),"|")	
Else
	aCliExt := {"","","",""}
Endif

If len(aCliExt[3]) <> TamSx3("A1_COD")[1]
	cCodCli := ""	
Else
	cCodCli := aCliExt[3]
Endif

cLojCli := Padl(aCliExt[4], TamSx3("A1_LOJA")[1])
cPedExt := xEnt:getPropValue("InternalId")
cPedInt := ALLTRIM(CFGA070Int( cMarca, "SC5","C5_NUM", cPedExt, RetSqlName("SC5")))
cDocInt := xEnt:getPropValue("ECommerceOrder")

If MsFile(cFile)
	cDocInt := PADR(cDocInt, TamSx3("F78_ID")[1])
Else
	cDocInt := ""
Endif


If cEvent == "UPSERT"
	IF Empty(cPedInt)  // Processa Inclusão pois o pedido nao existe na XXF 	
		
		dbselectarea("F78")
		F78->(DbSetOrder(1))
		F78->(Dbgotop())
		
		If F78->(dbSeek(xFilial("F78")+ cDocInt))

			DbSelectarea("SA1")
			SA1->(DbSetOrder(1))
			SA1->(DbGotop())
			If !Empty(cCodCli) .and. SA1->(DbSeek(FwXfilial("SA1")+cCodCli+cLojCli))

				DbSelectarea("SE1")
				SE1->(DbSetOrder(1))  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				If SE1->(DbSeek(F78->F78_FILCR+F78->F78_PRFCR+F78->F78_NUMCR+F78->F78_PARCCR+F78->F78_TPCR))
					If Alltrim(F78->F78_TPCR) == 'CC' .OR. SE1->E1_CLIENTE+SE1->E1_LOJA == cCodCli+cLojCli

						cCondpg   := SA1->A1_COND
						cTransp   := CFGA070Int( cMarca, "SA4","A4_COD", xEnt:getPropValue("CarrierCode"),RetSqlName("SA4"))
						cEmissao  := strtran(substr(xEnt:getPropValue("IssueDateDocument"),1,10),"-","")
						nTotDesc  := xEnt:getPropValue("DiscountValue")
						nTotAcres := xEnt:getPropValue("IncreaseValue")     
						nTotFre   := xEnt:getPropValue("FreightValue")				 
						cDocCod   := xEnt:getPropValue("DocumentCode") 
						cMensag   := "EcomerceOrder: " + cDocInt + " - " + "DocumentCode: " + cDocCod

						If !Empty(cCondPg)		

							aAdd(aCabec,{"C5_TIPO"      , "N"  			  		,Nil})			
							aAdd(aCabec,{"C5_CLIENTE"   , cCodCli               ,Nil})			
							aAdd(aCabec,{"C5_LOJACLI"   , cLojCli        		,Nil})	
							aAdd(aCabec,{"C5_TIPOCLI"   , SA1->A1_TIPO	  		,Nil})
							aAdd(aCabec,{"C5_TRANSP"    , cTransp   	  		,Nil})
							aAdd(aCabec,{"C5_EMISSAO"   , sToD(cEmissao)  		,Nil})
							aAdd(aCabec,{"C5_CONDPAG"   , SA1->A1_COND   		,Nil})				
							aAdd(aCabec,{"C5_MENNOTA"   , cMensag			    ,Nil})			
							aAdd(aCabec,{"C5_NATUREZ"   , SA1->A1_NATUREZ 	    ,Nil})
							aAdd(aCabec,{"C5_VEND1"     , SA1->A1_VEND   	    ,Nil})
							aAdd(aCabec,{"C5_DESCFI"    , nTotDesc      	    ,Nil})
							aAdd(aCabec,{"C5_ACRSFIN"   , nTotAcres      	    ,Nil})
							aAdd(aCabec,{"C5_FRETE"     , nTotFre       	    ,Nil})
							aAdd(aCabec,{"C5_RASTR"     , cDocInt         	    ,Nil})
							aAdd(aCabec,{"C5_STATUS"    , "00"          	    ,Nil}) //Inicia como "Pedido Gerado"
							aAdd(aCabec,{"C5_ORIGEM"    , cMarca      	    ,Nil})

							oItens := xEnt:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")  

							If Len(oItens) > 0			

								For nI := 1 To Len(oItens)

									cProdExt  := oItens[nI]:getPropValue("ItemCode")
									nQtd      := oItens[nI]:getPropValue("Quantity")
									nPrcUn    := oItens[nI]:getPropValue("UnitPrice")
									cTES      := Alltrim(oItens[nI]:getPropValue("OperationCode"))	
									
									If Len(cTES) <= 2
										cTpOpera :=PADR(cTES,TamSX3('FM_TIPO')[1] )

										cTES  := MaTesInt(2, cTpOpera, cCodCli, cLojCli, "C", cProdExt)

										If Empty(cTES)
											lRet 	 := .F.
											cMsgRet  := STR0016 //"Tipo de operação não possui nenhuma TES atrelada."
											Return {lRet, cMsgRet}																				
										Endif
									EndIf

									DbSelectarea("SF4")
									SF4->(DbSetOrder(1))
									SF4->(DbGotop())

									If SF4->(Dbseek(xFilial("SF4") + Padl(cTES, TamSx3("F4_CODIGO")[1]))) //Caso nao encontre a TES, não executa

										If SF4->F4_DUPLIC == "S" .and. cMarca == "VTEX" //Não pode utilizar TES que gere financeiro
											lRet 	 := .F.
											cMsgRet  := STR0011  //"Não Permitido TES que gere financeiro"
											Return {lRet, cMsgRet}
										Endif						

									Else

										lRet 	 := .F.
										cMsgRet  := STR0007		//"TES não localizada no cadastro.
										Return {lRet, cMsgRet}

									Endif

									DbSelectarea("SB1")
									SB1->(DbSetOrder(1))
									SB1->(DbGotop())	

									If !SB1->(Dbseek(xFilial("SB1") + PadR(cProdExt, TamSx3("B1_COD")[1]))) //Caso nao encontre o Produto, não executa													

										lRet 	 := .F.
										cMsgRet  := STR0008 // "Produto não localizado."				
										Return {lRet, cMsgRet}

									Endif					

									nDesc     := oItens[nI]:getPropValue("DiscountAmount") 
									cArm      := CFGA070Int( cMarca, "NNR","NNR_CODIGO", oItens[nI]:getPropValue("WarehouseInternalid"),RetSqlName("NNR"))				
									
									If !empty(oItens[nI]:getPropValue("ItemReserveInternalId"))

										aCodRes   := STRTOKARR(CFGA070Int( cMarca, "SC0","C0_DOCRES", oItens[nI]:getPropValue("ItemReserveInternalId"),RetSqlName("SC0")), "|")								
										
										If len(aCodRes) > 0
											cCodRes   := aCodRes[3]	
											cC0Num    := POSICIONE("SC0", 3, xFilial("SC0") + cCodRes, "C0_NUM")						
										Endif
										
									Endif

									aAdd(aLinha,{"C6_ITEM"   	 , StrZero(nI,2)         ,Nil})
									aAdd(aLinha,{"C6_PRODUTO"	 , cProdExt              ,Nil}) 
									aAdd(aLinha,{"C6_QTDVEN" 	 , nQtd   				 ,Nil})	
									aAdd(aLinha,{"C6_PRCVEN" 	 , nPrcUn                ,Nil})
									aAdd(aLinha,{"C6_OPER"    	 , cTpOpera              ,Nil})
									aAdd(aLinha,{"C6_TES"    	 , cTES                  ,Nil})
									aAdd(aLinha,{"C6_VALDESC"  	 , nDesc                 ,Nil})
									aAdd(aLinha,{"C6_RESERVA"  	 , cC0Num                ,Nil})
									aAdd(aItens,aLinha)
								Next
					
								lMsErroAuto := .F. 		

								Begin TRansaction

								MSExecAuto({|x,y,z| Mata410(x,y,z)},aCabec,aItens,3)
					
								If lMsErroAuto 

									cMsgRet := ""
									aLog := {}
									aLog := GetAutoGrLog()

									For nX := 1 To Len(aLog)
										cMsgRet += aLog[nx]
									Next 
							
									lRet := .F.		
									DisarmTransaction()		

								Else						

									//Grava a Tabela SCV (Formas de Pagamento do PV)
									oForma := xEnt:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")

									For nZ := 1 To Len(oForma)		

										nValPg  := oForma[nZ]:getPropValue("PaymentValue")*100
										cFormPg := oForma[nZ]:getPropValue("PaymentMethodCode")
										nValTot := xEnt:getPropValue("TotalPrice") - nTotDesc + nTotAcres
										nRatFor := nValPg / nValTot			

										cDescF  := GetAdvFVal("SX5","X5_DESCRI",xFilial("SX5")+"24"+cFormPg,1,'',.T. )  //SX5->X5_DESCRI
										
										RECLOCK("SCV", .T.)
										SCV->CV_FILIAL  := xFilial("SCV")
										SCV->CV_PEDIDO  := SC5->C5_NUM
										SCV->CV_FORMAPG := cFormPg
										SCV->CV_DESCFOR := cDescF
										SCV->CV_RATFOR  := nRatFor
										MSUNLOCK()   
										
									Next				

									cPedInt := SC5->C5_NUM //Grava o numero do pedido recém gravado.
									
									//Inclui o numero do Pedido na XXF
									lInteg := CFGA070Mnt(cMarca, "SC5", "C5_NUM", cPedExt, cPedInt)

									//Atualiza a tabela de rastreio	
									
									If MsFile(cFile)
										While F78->(!EOF()) .AND. F78->F78_ID == cDocInt									
											RECLOCK("F78", .F.)									
											F78_FILPED  := SC5->C5_FILIAL
											F78_NUMPD   := cPedInt
											MSUNLOCK()   
											F78->(DbSkip())
										EndDo				
									Endif
									
									cPedExt := ALLTRIM(CFGA070Ext( cMarca, "SC5","C5_NUM", cPedInt, RetSqlName("SC5")))

									lRet 	 := .T.
									cMsgRet  := STR0001 + ": '" + cPedExt + "' " + STR0002  // "Pedido: 'Nro do pedido' incluido com sucesso."

								Endif

								End Transaction

							Else 			

								lRet 	 := .F.
								cMsgRet  := STR0003   // "Lista de produtos vazia."
							
							EndIf	

						Else
							
							lRet 	 := .F.
							cMsgRet := STR0012 // "Cliente não possui condição de pagamento."

						Endif 
					Else
						lRet 	 := .F.
						cMsgRet := STR0013 // "Cliente do pedido difere do cliente do título."
					EndIf
				Else
					lRet 	 := .F.
					cMsgRet := STR0014 // "Título não localizado no contas a receber."
				EndIf
									

			Else

				lRet 	 := .F.
				cMsgRet := STR0010 // "Cliente não localizado."

			Endif

		Else 

			lRet 	 := .F.
			cMsgRet := STR0004 // "Não localizado nenhum título para rastreio."

		Endif

	Else //Caso achou o Pedido será "Alteração"		

			DbSelectArea("SC5")
			SC5->(DbSetOrder(1))
			If SC5->(DbSeek(xFilial("SC5") + cPedInt))
				DbSelectarea("SA1")
				SA1->(DbSetOrder(1))
				SA1->(DbGotop())
				If !Empty(cCodCli) .and. SA1->(DbSeek(FwXfilial("SA1")+cCodCli+cLojCli)) .and. cCodCli+cLojCli == SC5->C5_CLIENTE+SC5->C5_LOJACLI

					cTransp   := CFGA070Int( cMarca, "SA4","A4_COD", xEnt:getPropValue("CarrierCode"),RetSqlName("SA4"))
					cEmissao  := strtran(substr(xEnt:getPropValue("IssueDateDocument"),1,10),"-","")
					nTotDesc  := xEnt:getPropValue("DiscountValue")
					nTotAcres := xEnt:getPropValue("IncreaseValue")     
					nTotFre   := xEnt:getPropValue("FreightValue") 
					cDocInt   := xEnt:getPropValue("ECommerceOrder") 
					cDocCod   := xEnt:getPropValue("DocumentCode") 
					cMensag   := "EcomerceOrder: " + cDocInt + " - " + "DocumentCode: " + cDocCod
				
					aAdd(aCabec,{"C5_NUM"       , cPedInt  		  		,Nil})			
					aAdd(aCabec,{"C5_TIPO"      , "N"  			  		,Nil})							
					aAdd(aCabec,{"C5_CLIENTE"   , SA1->A1_COD           ,Nil})			
					aAdd(aCabec,{"C5_LOJACLI"   , SA1->A1_LOJA   		,Nil})	
					aAdd(aCabec,{"C5_TIPOCLI"   , SA1->A1_TIPO	  		,Nil})
					aAdd(aCabec,{"C5_TRANSP"    , cTransp   	  		,Nil})
					aAdd(aCabec,{"C5_EMISSAO"   , sToD(cEmissao)  		,Nil})
					aAdd(aCabec,{"C5_CONDPAG"   , SA1->A1_COND   		,Nil})				
					aAdd(aCabec,{"C5_MENNOTA"   , cMensag			    ,Nil})			
					aAdd(aCabec,{"C5_NATUREZ"   , SA1->A1_NATUREZ 	    ,Nil})
					aAdd(aCabec,{"C5_VEND1"     , SA1->A1_VEND   	    ,Nil})
					aAdd(aCabec,{"C5_DESCFI"    , nTotDesc      	    ,Nil})
					aAdd(aCabec,{"C5_ACRSFIN"   , nTotAcres      	    ,Nil})
					aAdd(aCabec,{"C5_FRETE"     , nTotFre       	    ,Nil})
					aAdd(aCabec,{"C5_RASTR"     , cDocInt         	    ,Nil})
					aAdd(aCabec,{"C5_STATUS"    , "00"          	    ,Nil}) //Inicia como "Pedido Gerado"
					aAdd(aCabec,{"C5_ORIGEM"    , cMarca      	    ,Nil})

					oItens := xEnt:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")  

					If Len(oItens) > 0			

						For nI := 1 To Len(oItens)

							cProdExt  := oItens[nI]:getPropValue("ItemCode")
							nQtd      := oItens[nI]:getPropValue("Quantity")
							nPrcUn    := oItens[nI]:getPropValue("UnitPrice")
							cTES      := oItens[nI]:getPropValue("OperationCode")

							If Len(cTES) <= 2
								cTpOpera :=PADR(cTES,TamSX3('FM_TIPO')[1] )

								cTES  := MaTesInt(2, cTpOpera, cCodCli, cLojCli, "C", cProdExt)

								If Empty(cTES)
									lRet 	 := .F.
									cMsgRet  := STR0016   //"Tipo de operação não possui nenhuma TES atrelada."
									Return {lRet, cMsgRet}																				
								Endif
							EndIf

							If SF4->(Dbseek(xFilial("SF4") + PadR(cTES, TamSx3("F4_CODIGO")[1]))) //Caso nao encontre a TES, não acrescenta no aLinha

								If SF4->F4_DUPLIC == "S" .and. cMarca == "VTEX" //Não pode utilizar TES que gere financeiro //Não é possivel utilizar TES que gere financeiro - Regra VTEX
									lRet 	 := .F.
									cMsgRet  := STR0011 // "Não é permitida a utilização de TES que gere financeiro." 
									Return {lRet, cMsgRet}
								Endif						

							Else

								lRet 	 := .F.
								cMsgRet  := STR0007 // "TES não localizada."
								Return {lRet, cMsgRet}

							Endif		

							DbSelectarea("SB1")
							SB1->(DbSetOrder(1))
							SB1->(DbGotop())	

							If !SB1->(Dbseek(xFilial("SB1") + PadR(cProdExt, TamSx3("B1_COD")[1]))) //Caso nao encontre o Produto, não executa													

								lRet 	 := .F.
								cMsgRet  := STR0008 // "Produto não localizado."				
								Return {lRet, cMsgRet}

							Endif			

							nDesc     := oItens[nI]:getPropValue("DiscountAmount") 
							cArm      := CFGA070Int( cMarca, "NNR","NNR_CODIGO", oItens[nI]:getPropValue("WarehouseInternalid"),RetSqlName("NNR"))				
							cCodRes   := CFGA070Int( cMarca, "SC0","C0_NUM", oItens[nI]:getPropValue("ItemReserveInternalId"),RetSqlName("SC0"))								

							aAdd(aLinha,{"C6_ITEM"   	 , StrZero(nI,2)         ,Nil})
							aAdd(aLinha,{"C6_PRODUTO"	 , cProdExt              ,Nil}) 
							aAdd(aLinha,{"C6_QTDVEN" 	 , nQtd   				 ,Nil})	
							aAdd(aLinha,{"C6_PRCVEN" 	 , nPrcUn                ,Nil})
							aAdd(aLinha,{"C6_OPER"    	 , cTpOpera              ,Nil})
							aAdd(aLinha,{"C6_TES"    	 , cTES                  ,Nil})
							aAdd(aLinha,{"C6_VALDESC"  	 , nDesc                 ,Nil})
							aAdd(aLinha,{"C6_RESERVA"  	 , cCodRes               ,Nil})
							aAdd(aItens,aLinha)
						Next
			
						lMsErroAuto := .F. 		

						Begin TRansaction

						MSExecAuto({|x,y,z| Mata410(x,y,z)},aCabec,aItens,4)
			
						If lMsErroAuto 

							cMsgRet := ""
							aLog := {}
							aLog := GetAutoGrLog()

							For nX := 1 To Len(aLog)
								cMsgRet += aLog[nx]
							Next 
					
							lRet := .F.		
							DisarmTransaction()		

						Else										
							
							lRet 	 := .T.
							cMsgRet  := STR0001 + ": '" + cPedExt + "' " + STR0005    //"Pedido: 'Nro do pedido' alterado com sucesso."

						Endif

						End Transaction

					Else 			

						lRet 	 := .F.
						cMsgRet  := STR0003 // "Lista de produtos vazia."
					
					EndIf

				Else

					lRet 	 := .F.
					cMsgRet  := STR0015 // "Cliente do pedido não pode ser alterado."

				EndIf

			Else
				lRet 	 := .F.
				cMsgRet := STR0006 // "Pedido não localizado."
			Endif		

	Endif

ElseIf cEvent == "DELETE"

	lRet := .T.

	cDocInt   := xEnt:getPropValue("ECommerceOrder") 

	If !Empty(cPedExt)

			DbSelectArea("SC5")
			SC5->(DbSetOrder(1))
			If SC5->(DbSeek(xFilial("SC5") + cPedInt))								
			
				aAdd(aCabec,{"C5_NUM", cPedInt,Nil})					
				
				oItens := xEnt:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")  

				If Len(oItens) > 0			

					For nI := 1 To Len(oItens)

						cProdExt  := oItens[nI]:getPropValue("ItemCode")
						nQtd      := oItens[nI]:getPropValue("Quantity")
						nPrcUn    := oItens[nI]:getPropValue("UnitPrice")
						cTES      := oItens[nI]:getPropValue("OperationCode")
						nDesc     := oItens[nI]:getPropValue("DiscountAmount") 
						cArm      := CFGA070Int( cMarca, "NNR","NNR_CODIGO", oItens[nI]:getPropValue("WarehouseInternalid"),RetSqlName("NNR"))				
						cCodRes   := CFGA070Int( cMarca, "SC0","C0_NUM", oItens[nI]:getPropValue("ItemReserveInternalId"),RetSqlName("SC0"))								

						aAdd(aLinha,{"LINPOS"        ,"C6_ITEM"	             ,StrZero(nI,2)})
						aAdd(aLinha,{"C6_ITEM"   	 , StrZero(nI,2)         ,Nil})
						aAdd(aLinha,{"C6_PRODUTO"	 , cProdExt              ,Nil}) 
						aAdd(aLinha,{"C6_QTDVEN" 	 , nQtd   				 ,Nil})	
						aAdd(aLinha,{"C6_PRCVEN" 	 , nPrcUn                ,Nil})
						aAdd(aLinha,{"C6_TES"    	 , cTES                  ,Nil})
						aAdd(aLinha,{"C6_VALDESC"  	 , nDesc                 ,Nil})
						aAdd(aLinha,{"C6_RESERVA"  	 , cCodRes               ,Nil})
						aadd(aLinha,{"AUTDELETA","S" ,                        Nil})
						aAdd(aItens,aLinha)
						
					Next
		 
					lMsErroAuto := .F. 		

					Begin TRansaction

					MSExecAuto({|x,y,z| Mata410(x,y,z)},aCabec,aItens,5) //nOpc = 5 - Deleta o pedido
		
					If lMsErroAuto 

 						cMsgRet := ""
 						aLog := {}
						aLog := GetAutoGrLog()

						For nX := 1 To Len(aLog)
							cMsgRet += aLog[nx]
						Next 
				
						lRet := .F.		
						DisarmTransaction()		

					Else						

							//Exclui os titulos inseridos Carteira a Pagar e a Receber
							If MsFile(cFile)
								DbSelectArea("F78")
								F78->(DbSetOrder(1))
								F78->(Dbgotop())
								If F78->(DbSeek(xFilial("F78")+cDocInt)) 

									While F78->(!eof()) .AND. ALLTRIM(F78->F78_ID) == cDocInt	
										DbSelectArea("SE1")
										SE1->(DbSetOrder(1))

										If SE1->(DbSeek(F78->F78_FILCR+F78->F78_PRFCR+F78->F78_NUMCR+F78->F78_PARCCR+F78->F78_TPCR))										    									
										
											If lGerTx
												If SAE->(dbSeek(xFilial("SAE")+SE1->E1_ADM)) 
											
													cCodfor := L070IncSA2()
													DbSelectArea("SE2")
													SE2->(DbSetOrder(1))

													If SE2->(DbSeek(F78->F78_FILCR+F78->F78_PRFCR+F78->F78_NUMCR+F78->F78_PARCCR+F78->F78_TPCR+cCodfor+PADR( "01", TAMSX3("E2_LOJA")[1])))										    									

														aVetSE2 := {}										
														aAdd(aVetSE2, {"E2_FILIAL" , F78->F78_FILCR , Nil})										
														aAdd(aVetSE2, {"E2_PREFIXO", F78->F78_PRFCR , Nil})
														aAdd(aVetSE2, {"E2_NUM"    , F78->F78_NUMCR , Nil})
														aAdd(aVetSE2, {"E2_PARCELA", F78->F78_PARCCR, Nil})
														aAdd(aVetSE2, {"E2_TIPO"   , F78->F78_TPCR  , Nil})
														aAdd(aVetSE2, {"E2_NATUREZ" ,SE2->E2_NATUREZ, NIL})
														aAdd(aVetSE2, {"E2_FORNECE" ,SE2->E2_FORNECE, NIL})
														aAdd(aVetSE2, {"E2_LOJA"    ,SE2->E2_LOJA   , NIL})
														aAdd(aVetSE2, {"E2_EMISSAO" ,SE2->E2_EMISSAO, NIL})
														aAdd(aVetSE2, {"E2_VENCTO"  ,SE2->E2_VENCTO , NIL})
														aAdd(aVetSE2, {"E2_VENCREA" ,SE2->E2_VENCREA, NIL})
														aAdd(aVetSE2, {"E2_VALOR"   ,SE2->E2_VALOR  , NIL})

    													lMsErroAuto  := .F.

														MSExecAuto({|x,y,z| FINA050(x,y,z)}, aVetSE2,,5)     
										
														If lMsErroAuto 

		 													cMsgRet := ""
 															aLog := {}
															aLog := GetAutoGrLog()

															For nX := 1 To Len(aLog)
																cMsgRet += aLog[nx]
															Next 
				
															lRet := .F.		
															DisarmTransaction()															

														Endif													

													Endif
												Endif
											Endif

											aVetSE1 := {}										
											aAdd(aVetSE1, {"E1_FILIAL"  , F78->F78_FILCR   , Nil})										
											aAdd(aVetSE1, {"E1_PREFIXO" , F78->F78_PRFCR   , Nil})
											aAdd(aVetSE1, {"E1_NUM"     , F78->F78_NUMCR   , Nil})
											aAdd(aVetSE1, {"E1_PARCELA" , F78->F78_PARCCR  , Nil})
											aAdd(aVetSE1, {"E1_TIPO"    , F78->F78_TPCR    , Nil})
											aAdd(aVetSE1, {"E1_NATUREZ" ,SE1->E1_NATUREZ   , NIL})
											aAdd(aVetSE1, {"E1_CLIENTE" ,SE1->E1_CLIENTE   , NIL})
											aAdd(aVetSE1, {"E1_LOJA"    ,SE1->E1_LOJA      , NIL})
											aAdd(aVetSE1, {"E1_VENCTO"  ,SE1->E1_VENCTO    , NIL})
											aAdd(aVetSE1, {"E1_VENCREA" ,SE1->E1_VENCREA   , NIL})
											aAdd(aVetSE1, {"E1_VALOR"   ,SE1->E1_VALOR     , NIL})									
    										  									

											MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 5)     
										
											If lMsErroAuto 

 												cMsgRet := ""
 												aLog := {}
												aLog := GetAutoGrLog()

												For nX := 1 To Len(aLog)
													cMsgRet += aLog[nx]
												Next 
				
												lRet := .F.		
												DisarmTransaction()													

											Endif																				

										Endif							
									
										F78->(DbSkip())

									EndDo																							
								EndIf
							
								dbselectarea("F78")
								F78->(DbSetOrder(1))
								F78->(Dbgotop())

								While F78->(!EOF()) .AND. ALLTRIM(F78->F78_ID) == cDocInt

										RecLock("F78", .F.)																		
	          								F78->( DbDelete() )
          								MsUnlock()   							

									F78->(DbSkip())
								EndDo								
								
								//EXclui o numero do Pedido no De-PARA - XXF
								CFGA070Mnt(cMarca, cAlias, cCampo, cPedExt, cPedint, .T.)

							Endif				

						Endif						

					End Transaction				

				Else 			

					lRet 	 := .F.
					cMsgRet  := STR0003 // "Lista de produtos vazia."
				
				EndIf

			Else
				lRet 	 := .F.
				cMsgRet := STR0006 // "Pedido não localizado."
			Endif

	Else 

			lRet 	 := .F.
			cMsgRet := STR0009 // "Número do Pedido não informado."

	Endif

Endif

Return {lRet, cMsgRet}
