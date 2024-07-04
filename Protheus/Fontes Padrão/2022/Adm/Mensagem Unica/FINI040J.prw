#Include 'Protheus.ch'
#Include 'fwAdapterEAI.ch'
#Include 'FINI040.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA040O   ºAutor  ³Totvs Cascavel     º Data ³  27/06/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de integracao com o adapter EAI para envio e   	  º±±
±±º          ³ recebimento do título a receber (SE1) utilizando o conceitoº±±
±±º          ³ de mensagem unica (AccountReceivableDocument).        	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINI040J                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINI040J( oEAIObEt, cTypeTrans, cTypeMessage, cVersion)
Local lRet             := .T.
Local nOpcx            := 0
Local lLog             := .T.
Local cEvent           := "upsert"
Local cAlias           := "SE1"
Local cField           := "E1_NUM"
Local cBase            := "E1_BASE"
Local cImpBase         := "0.0"
Local cXmlRet          := ""
Local cErroXml         := ""
Local cWarnXml         := ""
Local cMarca           := ""
Local cValInt          := ""
Local cValExt          := ""
Local cCliente         := ""
Local cPrefixo         := ""
Local cParcela         := ""
Local cNumDoc          := ""
Local cTipoDoc         := ""
Local cNaturez         := ""
Local cSE1             := ""
Local cSE1b            := ""
Local cE1              := ""
Local cImposto         := ""
Local cError           := ""
Local cWarning         := ""
Local nI               := 0
Local aTit             := {}
Local aAux             := {}
Local aRatAux          := {}
Local aImposto         := {"ISS", "IRRF", "INSS", "COFINS", "PIS", "CSLL"}
Local aTitPrv          := {}
Local aRateio          := {}
Local nCont			   := 0
Local dVenc            := Nil
Local cLoja            := ""
Local cTarefa          := ""
Local aRatPrj          := {}
Local xAux             := Nil
Local aIntPrj          := {}
Local cValIntRat       := ""
Local cValExtRat       := ""
Local cRelacao		   := ""
Local lNumDoc		   := .T.
Local cInternoId       := ""
Local aAuxVA           := {}
Local nLaco            := 0
Local aValorVA         := {}
Local cChaveFK7        := ""
Local lFI040SE1			:= ExistBlock("FI040SE1")
Local aAuxInc			:= {}
Local nK				:= 0
Local lHotel		   := SuperGetMV( "MV_INTHTL", , .F. )
Local cCustRat		   := SuperGetMV( "MV_HTLCCRT", , "" )
Local dDataAux		   := dDataBase
Local lRatNat 		   := .F.
Local aRatNat 		   := {}
Local aNat             := {}
Local aNatCC		   := {}
Local aAuxSEZ          := {}
Local nJ 			   := 0
Local aAuxEnt 		   := {}
Local nValTit 		   := 0
Local cChaveTit		   := ""
Local lFKD 				:= TableInDic("FKD")
Local cCodVA 			:= ""
Local cValAcess 		:= ""
Local lCposVA			:= SE1->(ColumnPos("E1_CONHTL")) > 0 .And. SE1->(ColumnPos("E1_TCONHTL")) > 0
Local cMsgUnica  		:= "ACCOUNTRECEIVABLEDOCUMENT"

//Instancia objeto JSON
Local ofwEAIObj			:= FWEAIobj():NEW()
Local cLogErro			:= ""
Local nX				:= 0
Local nCount			:= 0
Local nLtOfItID			:= 1

Private oXmlAux        	:= Nil
Private lMsErroAuto    	:= .F.
Private lAutoErrNoFile 	:= .T.

IIf(lLog, AdpLogEAI(1, "FINI040", cTypeTrans, cTypeMessage, oEAIObEt), ConOut(STR0006))

//--------------------------------------
//recebimento mensagem
//--------------------------------------
If cTypeTrans == TRANS_RECEIVE .And. ValType( oEAIObEt ) == 'O'

	//--------------------------------------
	//chegada de mensagem de negocios
	//--------------------------------------
	If cTypeMessage == EAI_MESSAGE_BUSINESS
	
		//Verifica se a marca foi informada
		If oEAIObEt:getHeaderValue("ProductName") !=  nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") )  
			cMarca := UPPER(oEAIObEt:getHeaderValue("ProductName"))
		Else
			lRet := .F.
			cLogErro := ""	
			ofwEAIObj:Activate()
			ofwEAIObj:setProp("ReturnContent")
			cLogErro := STR0007 //"Informe a Marca!"
			ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
			IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), ConOut(STR0006))
																						
			Return { lRet, ofwEAIObj, cMsgUnica }	
		EndIf

		//Verifica se o InternalId foi informado
		If oEAIObEt:getPropValue("InternalId") != nil .And. !Empty( oEAIObEt:getPropValue("InternalId") )
			cValExt := oEAIObEt:getPropValue("InternalId")
		Else
			lRet := .F.
			cLogErro := ""	
			ofwEAIObj:Activate()
			ofwEAIObj:setProp("ReturnContent")
			cLogErro := STR0008 //"O InternalId é obrigatório!"
			ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
			IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), ConOut(STR0006))
																						
			Return { lRet, ofwEAIObj, cMsgUnica }	
		EndIf

		//Obtém o valor interno
		aAux := IntTRcInt(cValExt, cMarca)
		
		// Obtém dados utilizado somente no UPSERT
		If Upper(AllTrim(oEAIObEt:getEvent())) == "UPSERT" .Or. Upper(AllTrim(oEAIObEt:getEvent())) == "REQUEST"
			// Se o registro existe
			If aAux[1]
				nOpcx := 4 // Update

				cPrefixo := PadR(aAux[2][3],TamSX3("E1_PREFIXO")[1])
				cNumDoc  := PadR(aAux[2][4],TamSX3("E1_NUM")[1])
				cParcela := PadR(aAux[2][5],TamSX3("E1_PARCELA")[1])
				cTipoDoc := PadR(aAux[2][6],TamSX3("E1_TIPO")[1])
										
				cChaveTit := FWxFilial("SE1") + cPrefixo + cNumDoc + cParcela + cTipoDoc
					
				dbSelectArea( "SE1" )
				SE1->( dbSetOrder( 1 ) ) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

				If SE1->( ! msSeek( cChaveTit ) )
					lRet := .F.
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0044 + AllTrim( cChaveTit ) //"O de/para do título a ser alterado foi encontrado, porém o registro de título no contas a receber não foi encontrado no Protheus. Verifique se o mesmo não foi excluído manualmente. Chave do título: "
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																								
					Return { lRet, ofwEAIObj, cMsgUnica }						
				Endif
					
			Else
				nOpcx := 3 // Insert

				//Prefixo
				If oEAIObEt:getPropValue("DocumentPrefix") != nil .And. !Empty( oEAIObEt:getPropValue("DocumentPrefix") ) 
					cPrefixo := PadR(oEAIObEt:getPropValue("DocumentPrefix"), TamSX3("E1_PREFIXO")[1])
				ElseIf lHotel
					cPrefixo := SuperGetMV( "MV_HTLPREF", , "" ) //Prefixo para hotelaria
				ElseIf IsIntegTop() //Possui integração com o RM Solum
					cPrefixo := PadR(GetNewPar("MV_SLMPRER", ""), TamSX3("E1_PREFIXO")[1])
				EndIf										
					
				//Pega o inicializador padrão do campo de número do título
				cRelacao := Posicione('SX3', 2, Padr('E1_NUM', 10), 'X3_RELACAO')
				//Verifica se não possui numeração automática
				If Empty(&cRelacao)					
					//Verifica se o Número do Título foi informado
					If oEAIObEt:getPropValue("DocumentNumber") != nil .And. !Empty( oEAIObEt:getPropValue("DocumentNumber") ) 							                     
						cNumDoc := AllTrim(oEAIObEt:getPropValue("DocumentNumber"))
					Else 
						lRet := .F.
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0009 //"Informe o Número do Título"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
						IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), ConOut(STR0006))
																									
						Return { lRet, ofwEAIObj, cMsgUnica }						
					EndIf
				Else
					lNumDoc := .F.
				Endif
				//Parcela
				If oEAIObEt:getPropValue("DocumentParcel") != nil .And. !Empty( oEAIObEt:getPropValue("DocumentParcel") )  
					cParcela := AllTrim(oEAIObEt:getPropValue("DocumentParcel"))
				EndIf

				//Verifica se o Tipo do Título foi informado
				If oEAIObEt:getPropValue("DocumentTypeCode") != nil .And. !Empty( oEAIObEt:getPropValue("DocumentTypeCode") )  
					cTipoDoc := AllTrim(oEAIObEt:getPropValue("DocumentTypeCode"))
				Else
					lRet := .F.
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0010 //"Informe o Tipo do Título"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
					IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), ConOut(STR0006))
																									
					Return { lRet, ofwEAIObj, cMsgUnica }					
				EndIf
			EndIf

			If lNumDoc
				aAdd(aTit, {"E1_NUM",     PadR(cNumDoc, TamSX3("E1_NUM")[1]),      Nil})
			EndIf

			aAdd(aTit, {"E1_PREFIXO", cPrefixo,                                Nil})
			aAdd(aTit, {"E1_PARCELA", PadR(cParcela, TamSX3("E1_PARCELA")[1]), Nil})
			aAdd(aTit, {"E1_TIPO",    PadR(cTipoDoc, TamSX3("E1_TIPO")[1]),    Nil})
			
			// Verifica se Natureza foi informada
			If oEAIObEt:getPropValue("FinancialNatureInternalId") != nil .And. !Empty( oEAIObEt:getPropValue("FinancialNatureInternalId") )  
				cNatExt := oEAIObEt:getPropValue("FinancialNatureInternalId")
				aAux := F10GetInt(cNatExt, cMarca) //Adapter FINI010I
										
				If aAux[1]
					cNaturez := aAux[2][3]
					aAdd(aTit, {"E1_NATUREZ", PadR(cNaturez, TamSX3("E1_NATUREZ")[1]), Nil})
				Else
					lRet := .F.
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0037 + " -> " + cNatExt //"Natureza não encontrada no de/para."
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
					IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), ConOut(STR0006))
																									
					Return { lRet, ofwEAIObj, cMsgUnica }					
				EndIf
			Else
				//Se for integração com hotelaria, pega a natureza do parâmetro
				If lHotel
					If AllTrim( cTipoDoc ) == "RA"
						cNaturez := SuperGetMV( "MV_HTLNARA", , "" ) //Natureza pra RA
					ElseIf AllTrim( cTipoDoc ) == "PR"
						cNaturez := SuperGetMV( "MV_HTLNAPR", , "" ) //Natureza pra PR
					ElseIf AllTrim( cTipoDoc ) == "CC"
						cNaturez := SuperGetMV( "MV_HTLNACC", , "" ) //Natureza pra CC
					ElseIf AllTrim( cTipoDoc ) == "CD"
						cNaturez := SuperGetMV( "MV_HTLNACD", , "" ) //Natureza pra CD
					ElseIf AllTrim( cTipoDoc ) == "NCC"
						cNaturez := SuperGetMV( "MV_HTLNANC", , "" ) //Natureza pra NCC
					ElseIf AllTrim( cTipoDoc ) == "R$"
						cNaturez := SuperGetMV( "MV_HTLNADH", , "" ) //Natureza pra R$
					Endif
				Else
					// Utiliza o parâmetro MV_SLMNATR criado para a integração Protheus x RM Solum para
					// as demais integrações quando o FinancialNatureInternalId não for informado
					cNaturez := RTrim(GetNewPar("MV_SLMNATR", ""))
				Endif

				If !Empty(cNaturez)
					aAdd(aTit, {"E1_NATUREZ", PadR(cNaturez, TamSX3("E1_NATUREZ")[1]), Nil})
				Else
					lRet := .F.
					cLogErro := ""
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
					If lHotel
						cLogErro := STR0038 + "MV_HTLNARA | MV_HTLNAPR | MV_HTLNACC | MV_HTLNACD | MV_HTLNANC | MV_HTLNADH" //"Natureza não informada. Verifique os parâmetros: "
					Else
						cLogErro := STR0039 //"Natureza não informada. Verifique o parâmetro MV_SLMNATR."
						IIf(lLog, AdpLogEAI(5, "FINI050", ofwEAIObj, lRet), ConOut(STR0006))
					Endif
					Return { lRet, ofwEAIObj, cMsgUnica }						
				EndIf
							
			EndIf

			//Obtém o Código Interno do Cliente
			If oEAIObEt:getPropValue("CustomerInternalId") != nil .And. !Empty( oEAIObEt:getPropValue("CustomerInternalId") ) 
				aAux := IntCliInt(oEAIObEt:getPropValue("CustomerInternalId"), cMarca) //Adapter MATI030
				If !aAux[1]
					lRet := aAux[1]
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := aAux[2]
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
					IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), ConOut(STR0006))
																									
					Return { lRet, ofwEAIObj, cMsgUnica }						
				Else
					cCliente := aAux[2][3]
					cLoja := aAux[2][4]
					aAdd(aTit, {"E1_CLIENTE", PadR(cCliente, TamSX3("E1_CLIENTE")[1]), Nil})
					aAdd(aTit, {"E1_LOJA", PadR(cLoja, TamSX3("E1_LOJA")[1]), Nil})
				EndIf
			Else //Se já for o código Protheus do Cliente (tags CustomerCode e StoreId)
				If oEAIObEt:getPropValue("CustomerCode") != nil .And. !Empty( oEAIObEt:getPropValue("CustomerCode") )  
					cCliente := AllTrim( oEAIObEt:getPropValue("CustomerCode") )
					aAdd(aTit, {"E1_CLIENTE", PadR(cCliente, TamSX3("E1_CLIENTE")[1]), Nil})
				EndIf
				If oEAIObEt:getPropValue("StoreId") != nil .And. !Empty( oEAIObEt:getPropValue("StoreId") ) 
					cLoja := AllTrim( oEAIObEt:getPropValue("StoreId") )
					aAdd(aTit, {"E1_LOJA", PadR(cLoja, TamSX3("E1_LOJA")[1]), Nil})
				EndIf
			EndIf
				
			If Empty( cCliente ) .OR. Empty ( cLoja )					
				lRet := .F.
				cLogErro := ""	
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				cLogErro := STR0043 //"Código de cliente não informado."
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																									
				Return { lRet, ofwEAIObj, cMsgUnica }				
			Endif
				
			//Verifica se a data de emissão do título foi informada
			If oEAIObEt:getPropValue("IssueDate") != nil .And. !Empty( oEAIObEt:getPropValue("IssueDate") )  
				aAdd(aTit, {"E1_EMISSAO", SToD(StrTran(oEAIObEt:getPropValue("IssueDate"),"-","")), Nil})
			Else
				lRet := .F.
				cLogErro := ""	
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				cLogErro := STR0014 //"Informe a data de emissão do título."
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
				IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), ConOut(STR0006))
																									
				Return { lRet, ofwEAIObj, cMsgUnica }						
			EndIf

			//Verifica se o Vencimento do Título foi informado
			If oEAIObEt:getPropValue("DueDate") != nil .And. !Empty( oEAIObEt:getPropValue("DueDate") )   
				aAdd(aTit, {"E1_VENCTO", SToD(StrTran(oEAIObEt:getPropValue("DueDate"),"-","")), Nil})
				aAdd(aTit, {"E1_VENCREA", SToD(StrTran(oEAIObEt:getPropValue("DueDate"),"-","")), Nil})
			Else
				lRet := .F.
				cLogErro := ""	
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				cLogErro := STR0015 //"Informe o Vencimento do Título"
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
				IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), ConOut(STR0006))
																									
				Return { lRet, ofwEAIObj, cMsgUnica }					
			EndIf

			// Verifica se o Valor do Título foi informado
			If oEAIObEt:getPropValue("NetValue") != nil .And. !Empty( oEAIObEt:getPropValue("NetValue") )  
				nValTit := oEAIObEt:getPropValue("NetValue")   
				aAdd(aTit, {"E1_VALOR", nValTit, Nil})
				aAdd(aTit, {"E1_VLCRUZ", nValTit, Nil})
			Else
				lRet := .F.
				cLogErro := ""	
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				cLogErro := STR0016 //"Informe o Valor do Título"
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
				IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), ConOut(STR0006))
																									
				Return { lRet, ofwEAIObj, cMsgUnica }					
			EndIf
					
			//Desconto financeiro (%)
			If oEAIObEt:getPropValue("DiscountPercentage") != nil .And. !Empty( oEAIObEt:getPropValue("DiscountPercentage") )   
				aAdd(aTit, {"E1_DESCFIN", Val(StrTran(oEAIObEt:getPropValue("DiscountPercentage"),",",".")), Nil})
			EndIf				

			// Histórico
			If oEAIObEt:getPropValue("Observation") != nil .And. !Empty( oEAIObEt:getPropValue("Observation") )  
				aAdd(aTit, {"E1_HIST", oEAIObEt:getPropValue("Observation"), NIL})
			Endif

			//Origem
			If oEAIObEt:getPropValue("Origin") != nil .And. !Empty( oEAIObEt:getPropValue("Origin") )  
				aAdd(aTit, {"E1_ORIGEM", oEAIObEt:getPropValue("Origin"), Nil})
			Else
				aAdd(aTit, {"E1_ORIGEM", "FINI040", Nil})
			EndIf
			
			//Moeda
			If oEAIObEt:getPropValue("CurrencyInternalId") != nil .And. !Empty( oEAIObEt:getPropValue("CurrencyInternalId") )  
				aAux := IntMoeInt(oEAIObEt:getPropValue("CurrencyInternalId"), cMarca) //Adapter CTBI140
				If !aAux[1]
					lRet := aAux[1]
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := aAux[2]
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
					IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), ConOut(STR0006))
																										
					Return { lRet, ofwEAIObj, cMsgUnica }					
				Else
					aAdd(aTit, {"E1_MOEDA", Val(aAux[2][3]), Nil})
				EndIf
			Else
				aAdd(aTit, {"E1_MOEDA", 1, Nil})
			EndIf

			//Caso a tag HolderCode venha preenchida, alimento os dados do portador, agencia e conta com base nesses dados
			If oEAIObEt:getPropValue("HolderCode") != nil .And. !Empty( oEAIObEt:getPropValue("HolderCode") )  
				aAdd(aTit, {"E1_PORTADO", PadR(oEAIObEt:getPropValue("HolderCode"),TamSX3("E1_PORTADO")[1]), Nil})
			EndIf
					
			//Valor Real do Título
			If oEAIObEt:getPropValue("RealValue") != nil .And. !Empty( oEAIObEt:getPropValue("RealValue") )    
				aAdd(aTit, {"E1_VLRREAL", oEAIObEt:getPropValue("RealValue"), NIL})
			Endif
					
			//Número NSU (transação com cartão)
			If oEAIObEt:getPropValue("UniqueSerialNumber") != nil .And. !Empty( oEAIObEt:getPropValue("UniqueSerialNumber") )     
				aAdd(aTit, {"E1_NSUTEF", oEAIObEt:getPropValue("UniqueSerialNumber"), NIL})
			Endif
					
			//Possui rateio
			If oEAIObEt:getPropValue("ApportionmentDistribution") != nil  
				
				oAppDistb := oEAIObEt:getPropValue("ApportionmentDistribution")

				For nI := 1 To Len( oAppDistb )  
					// Se possui projeto informado
					If oAppDistb[nI]:getPropValue("ProjectInternalId") != nil .And. !Empty( oAppDistb[nI]:getPropValue("ProjectInternalId") )    
						// Verifica se o código do projeto é válido
						aAux := IntPrjInt(oAppDistb[nI]:getPropValue("ProjectInternalId"), cMarca) //Empresa/Filial/Projeto
						If !aAux[1]
							lRet := .F.
							cLogErro := ""	
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := aAux[2] + " Título " + cNumDoc //" Título "
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
							IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), ConOut(STR0006))
																												
							Return { lRet, ofwEAIObj, cMsgUnica }								
						Else
							xAux := aAux[2][3]
						EndIf

						If oAppDistb[nI]:getPropValue("TaskInternalId") != nil .And. !Empty( oAppDistb[nI]:getPropValue("TaskInternalId") )  
							aAux := IntTrfInt(oAppDistb[nI]:getPropValue("TaskInternalId"), cMarca) //Empresa/Filial/Projeto/Revisao/Tarefa
							If !aAux[1]
								lRet := .F.
								cLogErro := ""	
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := aAux[2] + " Título " + cNumDoc //" Título "
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
								IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), ConOut(STR0006))
																													
								Return { lRet, ofwEAIObj, cMsgUnica }									
							Else
								cTarefa := PadR(aAux[2][5], TamSX3("AFT_TAREFA")[1])
							EndIf
						ElseIf cTipoDoc $ MVRECANT
							// No Adiantamento não é informada uma tarefa, só Projeto.
							// Aqui se obtém a primeira Tarefa do Projeto informado.
							AF9->(DbSetOrder(5)) // AF9_FILIAL + AF9_PROJET + AF9_TAREFA

							If AF9->(dbSeek(xFilial("AF9") + PadR(xAux, TamSX3("AF9_PROJET")[1])))
								cTarefa := AF9->AF9_TAREFA
							Else
								lRet := .F.
								cLogErro := ""	
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := STR0040 //"Não existe Tarefa para o Projeto informado."
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
								IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), ConOut(STR0006))
																													
								Return { lRet, ofwEAIObj, cMsgUnica }	
							EndIf
						EndIf

						// Se possui valor informado
						If oAppDistb[nI]:getPropValue("Value") != nil .And. !Empty( oAppDistb[nI]:getPropValue("Value") )  
							// Se já existe o projeto/tarefa somar os valores
							If (nCont := aScan(aRatPrj, {|x| RTrim(x[1][2]) == RTrim(xAux) .And. RTrim(x[3][2]) == RTrim(cTarefa)})) > 0
								aRatPrj[nCont][10][2] := aRatPrj[nCont][10][2] + oAppDistb[nI]:getPropValue("Value")
							Else
								aAdd(aRatAux, {"AFT_PROJET", PadR(xAux, TamSX3("AFT_PROJET")[1]),  Nil})
								aAdd(aRatAux, {"AFT_REVISA", StrZero(1, TamSX3("AFT_REVISA")[1]),  Nil})
								aAdd(aRatAux, {"AFT_TAREFA", cTarefa,                              Nil})
								aAdd(aRatAux, {"AFT_PREFIX", cPrefixo,                             Nil})
								aAdd(aRatAux, {"AFT_NUM",    cNumDoc,                              Nil})
								aAdd(aRatAux, {"AFT_PARCEL", cParcela,                             Nil})
								aAdd(aRatAux, {"AFT_TIPO",   cTipoDoc,                             Nil})
								aAdd(aRatAux, {"AFT_CLIENT", cCliente,                             Nil})
								aAdd(aRatAux, {"AFT_LOJA",   cLoja,                                Nil})
								aAdd(aRatAux, {"AFT_VALOR1", oAppDistb[nI]:getPropValue("Value"),  Nil})
								aAdd(aRatAux, {"AFT_DATA",   dVenc,                                Nil})
								aAdd(aRatAux, {"AFT_VENREA", dVenc,                                Nil})
								aAdd(aRatPrj, aRatAux)
								aRatAux := {}

								//De/Para do rateio de projeto
								cValIntRat := IntTRcExt(, , cPrefixo, cNumDoc, cParcela, cTipoDoc)[2] + "|" + AllTrim(cCliente) + "|" + AllTrim(cLoja) + "|" + AllTrim(xAux) + "|" + StrZero(1, TamSX3("AFT_REVISA")[1]) + "|" + AllTrim(cTarefa)

								If oAppDistb[nI]:getPropValue("InternalId") != nil .And. !Empty( oAppDistb[nI]:getPropValue("InternalId") )   
									cValExtRat := oAppDistb[nI]:getPropValue("InternalId")
								Else
									cValExtRat := oAppDistb[nI]:getPropValue("TaskInternalId")
								EndIf

								aAdd(aIntPrj, {"AFT", "AFT_TAREFA", cValIntRat, cValExtRat})
							EndIf
						Else
							lRet := .F.
							cLogErro := ""	
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0041 + cNumDoc //"Valor do rateio inválido para o título "
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
							IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), ConOut(STR0006))
																													
							Return { lRet, ofwEAIObj, cMsgUnica }							
						EndIf
					EndIf
				Next nI
			EndIf
				
			//Código da Agência
			If oEAIObEt:getPropValue("AgencyNumber") != nil .And. !Empty( oEAIObEt:getPropValue("AgencyNumber") )  
				aAdd(aTit, {"E1_AGEDEP", PadR(oEAIObEt:getPropValue("AgencyNumber"),TamSX3("E1_AGEDEP")[1]), NIL})
			Endif

			//Número da Conta
			If oEAIObEt:getPropValue("AccountNumber") != nil .And. !Empty( oEAIObEt:getPropValue("AccountNumber") )  
				aAdd(aTit, {"E1_CONTA", PadR(oEAIObEt:getPropValue("AccountNumber"),TamSX3("E1_CONTA")[1]), NIL})
			Endif
			
			//Nosso Número
			If oEAIObEt:getPropValue("OurNumberBanking") != nil .And. !Empty( oEAIObEt:getPropValue("OurNumberBanking") )  
				aAdd(aTit, {"E1_NUMBCO", oEAIObEt:getPropValue("OurNumberBanking"), NIL})
			Endif

			//Código de Barra
			If oEAIObEt:getPropValue("Barcode") != nil .And. !Empty( oEAIObEt:getPropValue("Barcode") )  
				aAdd(aTit, {"E1_CODBAR", oEAIObEt:getPropValue("Barcode"), NIL})
			Endif

			//Nr. Contrato
			If oEAIObEt:getPropValue("ContractNumber") != nil .And. !Empty( oEAIObEt:getPropValue("ContractNumber") )  
				aAdd(aTit, {"E1_CONTRAT", oEAIObEt:getPropValue("ContractNumber"), NIL})
			Endif

			//Percentual de Juros Diária
			If oEAIObEt:getPropValue("InterestPercentage") != nil .And. !Empty( oEAIObEt:getPropValue("InterestPercentage") ) 
				aAdd(aTit, {"E1_PORCJUR", oEAIObEt:getPropValue("InterestPercentage"), NIL})
			EndIf

			//Valor de Multa Diária (Taxa de Permanência)
			If oEAIObEt:getPropValue("AssessmentValue") != nil .And. !Empty( oEAIObEt:getPropValue("AssessmentValue") )  
				aAdd(aTit, {"E1_VALJUR", oEAIObEt:getPropValue("AssessmentValue"), NIL})
			EndIf
			
			If lFKD					
				//////////////////////
				//VALORES ACESSORIOS//
				//////////////////////
				If oEAIObEt:getPropValue("ListOfComplementaryValues") != nil 
				
					oLstCpVl := oEAIObEt:getPropValue("ListOfComplementaryValues")

					For nLaco := 1 to Len( oLstCpVl )
						If oLstCpVl[nLaco]:getPropValue("ComplementaryValueInternalId") != nil .And. !Empty( oLstCpVl[nLaco]:getPropValue("ComplementaryValueInternalId") )   
							cInternoId := oLstCpVl[nLaco]:getPropValue("ComplementaryValueInternalId")
							aAuxVA := F035GETINT(cInternoId,cMarca)
							If(aAuxVa[1])
								If oLstCpVl[nLaco]:getPropValue("InformedValue") != nil .And. !Empty( oLstCpVl[nLaco]:getPropValue("InformedValue") )  
									//adicionar em modo vetor
									cCodVA := aAuxVa[2,3]
									cValAcess := oLstCpVl[nLaco]:getPropValue("InformedValue")
									aAdd(aValorVA , {cCodVA, cValAcess} )
								EndIf
							Else
								lRet := .F.
								cLogErro := ""	
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := STR0042 + cInternoId //"Erro ao encontrar o valor acessorio"
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
								
								Exit
							EndIf
						EndIf
					Next nLaco
				EndIf	
								
			Endif
				
			//Registro Acadêmico do Aluno
			If oEAIObEt:getPropValue("Other"):getPropValue("AcademicRecord") != nil .And. !Empty( oEAIObEt:getPropValue("Other"):getPropValue("AcademicRecord") )   
				aAdd(aTit, {"E1_NUMRA",oEAIObEt:getPropValue("Other"):getPropValue("AcademicRecord"), NIL})
			EndIf

			//Período Letivo
			If oEAIObEt:getPropValue("Other"):getPropValue("AcademicPeriod") != nil .And. !Empty( oEAIObEt:getPropValue("Other"):getPropValue("AcademicPeriod") ) 
				aAdd(aTit, {"E1_PERLET", oEAIObEt:getPropValue("Other"):getPropValue("AcademicPeriod"), NIL})
			EndIf

			//Matriz Aplicada
			If oEAIObEt:getPropValue("Other"):getPropValue("AppliedMatrix") != nil .And. !Empty( oEAIObEt:getPropValue("Other"):getPropValue("AppliedMatrix") )  
				aAdd(aTit, {"E1_IDAPLIC", oEAIObEt:getPropValue("Other"):getPropValue("AppliedMatrix"), NIL})
			EndIf
			
			//Identificador Interno do Produto
			If oEAIObEt:getPropValue("Other"):getPropValue("ItemInternalId") != nil .And. !Empty( oEAIObEt:getPropValue("Other"):getPropValue("ItemInternalId") )   
				cCodProd := oEAIObEt:getPropValue("Other"):getPropValue("ItemInternalId")
					
				aAuxRet := IntProInt(cCodProd, cMarca, /*Versão*/)
						
				If aAuxRet[1]
					aAdd(aTit, { "E1_PRODUTO", aAuxRet[2][3] , NIL})
				EndIf
			EndIf

			//Turma (Classe)
			If oEAIObEt:getPropValue("Other"):getPropValue("Class") != nil .And. !Empty( oEAIObEt:getPropValue("Other"):getPropValue("Class") )  
				aAdd(aTit, {"E1_TURMA", oEAIObEt:getPropValue("Other"):getPropValue("Class"), NIL})
			EndIf
					
			//Tag com o número de conta hoteleira a qual o título estará associado
			If oEAIObEt:getPropValue("Other"):getPropValue("HotelAccountCode") != nil .And. !Empty( oEAIObEt:getPropValue("Other"):getPropValue("HotelAccountCode") )   
				aAdd( aTit, {"E1_CONHTL", oEAIObEt:getPropValue("Other"):getPropValue("HotelAccountCode"), NIL} )
			EndIf
					
			//Tag com o tipo de conta hoteleira a qual o título estará associado (1=Evento; 2=Grupo; 3=Individual; 4=Avulsa)
			If oEAIObEt:getPropValue("Other"):getPropValue("HotelAccountType") != nil .And. !Empty( oEAIObEt:getPropValue("Other"):getPropValue("HotelAccountType") )   
				aAdd( aTit, {"E1_TCONHTL", oEAIObEt:getPropValue("Other"):getPropValue("HotelAccountType"), NIL} )
			EndIf

			//Código da Conta Contábil - Débito
			If oEAIObEt:getPropValue("Accounting"):getPropValue("AccountingCodeDebit") != nil .And. !Empty( oEAIObEt:getPropValue("Accounting"):getPropValue("AccountingCodeDebit") ) 
				cContaD := CFGA070INT( cMarca, "CT1", "CT1_CONTA", oEAIObEt:getPropValue("Accounting"):getPropValue("AccountingCodeDebit"))
				If !Empty(cContaD)
					aAdd(aTit, {"E1_DEBITO", oEAIObEt:getPropValue("Accounting"):getPropValue("AccountingCodeDebit"), NIL})
				EndIf
			EndIf

			//Código da Conta Contábil - Crédito
			If oEAIObEt:getPropValue("Accounting"):getPropValue("AccountingCodeCredit") != nil .And. !Empty( oEAIObEt:getPropValue("Accounting"):getPropValue("AccountingCodeCredit") )  
				cContaC := CFGA070INT( cMarca, "CT1", "CT1_CONTA", oEAIObEt:getPropValue("Accounting"):getPropValue("AccountingCodeCredit"))
				If !Empty(cContaC)
					aAdd(aTit, {"E1_CREDIT", oEAIObEt:getPropValue("Accounting"):getPropValue("AccountingCodeCredit"), NIL})
				EndIf
			EndIf

			//Código do Centro de Custo - Débito
			If oEAIObEt:getPropValue("Accounting"):getPropValue("CostCenterDebit") != nil .And. !Empty( oEAIObEt:getPropValue("Accounting"):getPropValue("CostCenterDebit") )  
				aAuxRet := IntCusInt(oEAIObEt:getPropValue("Accounting"):getPropValue("CostCenterDebit"),cMarca)
				If !aAuxRet[1]
					lRet := aAuxRet[1]
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0035 //"Centro de custo não encontrado no De/Para"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
					IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), Conout("Centro de custo não encontrado no De/Para"))
																													
					Return { lRet, ofwEAIObj, cMsgUnica }						
				Else
					aAdd(aTit, {"E1_CCD", aAuxRet[2][3], NIL})
				EndIf
			EndIf

			//Código do Centro de Custo - Crédito
			If oEAIObEt:getPropValue("Accounting"):getPropValue("CostCenterCredit") != nil .And. !Empty( oEAIObEt:getPropValue("Accounting"):getPropValue("CostCenterCredit") )  
				aAuxRet := IntCusInt(oEAIObEt:getPropValue("Accounting"):getPropValue("CostCenterCredit"),cMarca)
				If !aAuxRet[1]
					lRet := aAuxRet[1]
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0035 //"Centro de custo não encontrado no De/Para"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
					IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), Conout("Centro de custo não encontrado no De/Para"))
																													
					Return { lRet, ofwEAIObj, cMsgUnica }						
				Else
					aAdd(aTit, {"E1_CCC", aAuxRet[2][3], NIL})
				EndIf
			EndIf

			//Código do Item Contábil - Débito
			If oEAIObEt:getPropValue("Accounting"):getPropValue("DepartamentDebit") != nil .And. !Empty( oEAIObEt:getPropValue("Accounting"):getPropValue("DepartamentDebit") )  
				aItemCtb := C040GetInt(oEAIObEt:getPropValue("Accounting"):getPropValue("DepartamentDebit"),cMarca)
				If aItemCtb[1]
					aAdd(aTit, {"E1_ITEMD",aItemCtb[2][3], Nil})
				EndIf
			EndIf

			//Código do Item Contábil - Crédito
			If oEAIObEt:getPropValue("Accounting"):getPropValue("DepartamentCredit") != nil .And. !Empty( oEAIObEt:getPropValue("Accounting"):getPropValue("DepartamentCredit") )  
				aItemCtb := C040GetInt(oEAIObEt:getPropValue("Accounting"):getPropValue("DepartamentCredit"),cMarca)
				If aItemCtb[1]
					aAdd(aTit, {"E1_ITEMC",aItemCtb[2][3], Nil})
				EndIf
			EndIf
			
			//Código da Classe de Valor - Débito
			If oEAIObEt:getPropValue("Accounting"):getPropValue("ClassValueDebit") != nil .And. !Empty( oEAIObEt:getPropValue("Accounting"):getPropValue("ClassValueDebit") )   
				aAuxRet := C060GetInt(oEAIObEt:getPropValue("Accounting"):getPropValue("ClassValueDebit"),cMarca) //Adapter CTBI060
				If !aAuxRet[1]
					lRet := aAuxRet[1]
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0036 //"Classe de valor não encontrada no De/Para"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
					IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), Conout("Centro de custo não encontrado no De/Para"))
																													
					Return { lRet, ofwEAIObj, cMsgUnica }						
				Else
					aAdd(aTit, {"E1_CLVLDB", aAuxRet[2][3], Nil})
				EndIf
			EndIf

			//Código da Classe de Valor - Crédito
			If oEAIObEt:getPropValue("Accounting"):getPropValue("ClassValueCredit") != nil .And. !Empty( oEAIObEt:getPropValue("Accounting"):getPropValue("ClassValueCredit") )   
				aAuxRet := C060GetInt(oEAIObEt:getPropValue("Accounting"):getPropValue("ClassValueCredit"),cMarca) //Adapter CTBI060
				If !aAuxRet[1]
					lRet := aAuxRet[1]
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0036 //"Classe de valor não encontrada no De/Para"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
					IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), Conout("Centro de custo não encontrado no De/Para"))
																													
					Return { lRet, ofwEAIObj, cMsgUnica }					
				Else
					aAdd(aTit, {"E1_CLVLCR",aAuxRet[2][3], Nil})
				EndIf
			EndIf
               
			//Tratamento específico para integração com RM Classis
			If Upper(AllTrim(cMarca)) == "RM"
				aAdd(aTit, {"E1_IDLAN", 1, Nil})
			EndIf
			
			//Rateio por natureza e centro de custos
			If oEAIObEt:getPropValue("ListOfFinancialNatureApportionment") != nil    

				oLstFinNat := oEAIObEt:getPropValue("ListOfFinancialNatureApportionment")
									
				lRatNat := .T.
				aAdd( aTit, { "E1_MULTNAT", "1", Nil } ) //Rateio multinaturezs = sim
					
				For nI := 1 To Len( oLstFinNat )  
												
					//Código da Natureza
					If oLstFinNat[nI]:getPropValue("FinancialNatureInternalId") != nil .And. !Empty( oLstFinNat[nI]:getPropValue("FinancialNatureInternalId") )  
						//Fazer de/para
					Else
						//Natureza definida no parâmetro MV_HTLNART							
						aAdd( aNat, { "EV_NATUREZ", PADR( cNaturez, TamSx3("EV_NATUREZ")[1] ), Nil } )																																								
					EndIf
						
					//Valor distribuido para a natureza em questão
					If oLstFinNat[nI]:getPropValue("Value") != nil .And. !Empty( oLstFinNat[nI]:getPropValue("Value") )  
						aAdd( aNat, { "EV_VALOR", oLstFinNat[nI]:getPropValue("Value"), Nil } )							
					Else
						If lHotel //Remover esse tratamento após tratar a execauto para calcular EV com base no percentual e vice-versa (assim como já foi feito na SEZ)
							aAdd( aNat, { "EV_VALOR", nValTit, Nil } )
						Else					
							aAdd( aNat, { "EV_VALOR", 0, Nil } )
						Endif
					EndIf
						
					//Percentual distribuido para a natureza em questão
					If oLstFinNat[nI]:getPropValue("Percentage") != nil .And. !Empty( oLstFinNat[nI]:getPropValue("Percentage") )  
						aAdd( aNat, { "EV_PERC", oLstFinNat[nI]:getPropValue("Percentage"), Nil } )
					Else
						aAdd( aNat, { "EV_PERC", 0, Nil } )
					EndIf
						
					//Rateio por centro de custos
					If oLstFinNat[nI]:getPropValue("ListOfCostCenterApportionment") != nil   

						oLstCstCet := oLstFinNat[nI]:getPropValue("ListOfCostCenterApportionment")
							
						aAdd( aNat, { "EV_RATEICC", "1", Nil } ) //indica que há rateio por centro de custo
																										
						For nJ := 1 To Len( oLstCstCet )   
								
							//Código do Centro de custos
							If oLstCstCet[nJ]:getPropValue("CostCenterInternalId") != nil .And. !Empty( oLstCstCet[nJ]:getPropValue("CostCenterInternalId") )  
								//Fazer de/para
							Else
								//Centro de Custo definido no parâmetro MV_HTLCCRT
								aAdd( aAuxSEZ, { "EZ_CCUSTO", cCustRat, Nil } )
							EndIf
								
							//Entidade adicional (05, 06, 07, 08 ou 09) - Código da conta
							If oLstCstCet[nJ]:getPropValue("GenericEntityInternalId") != nil .And. !Empty( oLstCstCet[nJ]:getPropValue("GenericEntityInternalId") )   
									
								//Obtém o valor interno da tabela XXF (de/para)
								aAuxEnt := IntGerInt( oLstCstCet[nJ]:getPropValue("GenericEntityInternalId"), cMarca, "1.000")
								If aAuxEnt[1]
									aAdd( aAuxSEZ, { "EZ_EC05DB", aAuxEnt[2][4], Nil } )
								Endif
									
							Else
								aAdd( aAuxSEZ, Nil )
							EndIf
								
							//Valor distribuido para o centro de custo em questão
							If oLstCstCet[nJ]:getPropValue("Value") != nil .And. !Empty( oLstCstCet[nJ]:getPropValue("Value") )  
								aAdd( aAuxSEZ, { "EZ_VALOR", oLstCstCet[nJ]:getPropValue("Value"), Nil } )
							Else
								aAdd( aAuxSEZ, { "EZ_VALOR", 0, Nil } )
							EndIf
								
							//Percentual distribuido para o centro de custo em questão
							If oLstCstCet[nJ]:getPropValue("Percentage") != nil .And. !Empty( oLstCstCet[nJ]:getPropValue("Percentage") )  
								aAdd( aAuxSEZ, { "EZ_PERC", oLstCstCet[nJ]:getPropValue("Percentage"), Nil } )
							Else
								aAdd( aAuxSEZ, { "EZ_PERC", 0, Nil } )
							EndIf

							aAdd( aNatCC, aClone( aAuxSEZ ) )
							aSize ( aAuxSEZ, 0 )
						Next nJ
					Endif
						
					aAdd( aNat, { "AUTRATEICC", aClone( aNatCC ), Nil } ) //Adiciona o array de multiplos centros de custos no array da natureza
					aSize ( aNatCC, 0 )
						
					aAdd( aRatNat, aClone( aNat ) ) //Adiciona o array de natureza no array de rateio por multiplas naturezas
					aSize ( aNat, 0 )
				Next nI
			EndIf
			
		ElseIf Upper(AllTrim(oEAIObEt:getEvent())) == "DELETE"  
					
			//Data de Exclusão
			If oEAIObEt:getPropValue("DeletionDate") != nil .And. !Empty( oEAIObEt:getPropValue("DeletionDate") )   
				dDataDel := SToD(StrTran(oEAIObEt:getPropValue("DeletionDate") ,"-",""))
				If !Empty(dDataDel)
					dDataBase:= dDataDel
				Endif
			EndIf
			// Se o registro existe
			If aAux[1]
				nOpcx := 5 // Delete

				cPrefixo := aAux[2][3]
				cNumDoc  := aAux[2][4]
				cParcela := aAux[2][5]
				cTipoDoc := aAux[2][6]

				dbSelectArea("SE1")
				SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

				If SE1->(dbSeek(xFilial("SE1") + cPrefixo + cNumDoc + cParcela + cTipoDoc))
					cCliente := SE1->E1_CLIENTE
					cLoja    := SE1->E1_LOJA
				Else
					cCliente := ""
					cLoja    := ""
				EndIf

				aAdd(aTit, {"E1_PREFIXO", PadR(cPrefixo, TamSX3("E1_PREFIXO")[1]), Nil})
				aAdd(aTit, {"E1_NUM",     PadR(cNumDoc,  TamSX3("E1_NUM")[1]),     Nil})
				aAdd(aTit, {"E1_PARCELA", PadR(cParcela, TamSX3("E1_PARCELA")[1]), Nil})
				aAdd(aTit, {"E1_TIPO",    PadR(cTipoDoc, TamSX3("E1_TIPO")[1]),    Nil})

				//Rateio
				aAdd(aRatAux, {"AFT_PREFIX", PadR(cPrefixo, TamSX3("AFT_PREFIX")[1]), Nil})
				aAdd(aRatAux, {"AFT_NUM",    PadR(cNumDoc,  TamSX3("AFT_NUM")[1]),    Nil})
				aAdd(aRatAux, {"AFT_PARCEL", PadR(cParcela, TamSX3("AFT_PARCEL")[1]), Nil})
				aAdd(aRatAux, {"AFT_TIPO",   PadR(cTipoDoc, TamSX3("AFT_TIPO")[1]),   Nil})
				aAdd(aRatAux, {"AFT_CLIENT", PadR(cCliente, TamSX3("AFT_CLIENT")[1]), Nil})
				aAdd(aRatAux, {"AFT_LOJA",   PadR(cLoja,    TamSX3("AFT_LOJA")[1]),   Nil})
				aAdd(aRatPrj, aRatAux)
				aRatAux := {}

				//De/Para do rateio
				aRatAux := RatCAR(SE1->E1_FILIAL + cPrefixo + cNumDoc + cParcela + cTipoDoc + cCliente + cLoja)

				for nI := 1 To Len(aRatAux)
					cValIntRat := IntTRcExt(, , cPrefixo, cNumDoc, cParcela, cTipoDoc)[2] + "|" + AllTrim(cCliente) + "|" + AllTrim(cLoja) + "|" + AllTrim(aRatAux[nI][6]) + "|" + StrZero(1, TamSX3("AFT_REVISA")[1]) + "|" + AllTrim(aRatAux[nI][7])
					cValExtRat := AllTrim(CFGA070Ext(cMarca, "AFT", "AFT_TAREFA", cValIntRat))

					aAdd(aIntPrj, {"AFT", "AFT_TAREFA", cValIntRat, cValExtRat})
				Next nI
			Else
				lRet := .F.
				dDataBase := dDataAux
				cLogErro := ""	
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				cLogErro := STR0017 //"O Título a ser excluído não foi encontrado na base Protheus"
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																													
				Return { lRet, ofwEAIObj, cMsgUnica }					
			EndIf
		Else
			lRet := .F.
			dDataBase := dDataAux
			cLogErro := ""	
			ofwEAIObj:Activate()
			ofwEAIObj:setProp("ReturnContent")
			cLogErro := STR0018 //"O evento informado é inválido"
			ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																													
			Return { lRet, ofwEAIObj, cMsgUnica }				
		EndIf

		If lRet
			cValInt := IntTRcExt(, , cPrefixo, cNumDoc, cParcela, cTipoDoc)[2]

	 		// Ponto de Entrada para tratamento do Array de campos enviado na MSExecAuto
	        If lFI040SE1
	           	aAuxInc := ExecBlock("FI040SE1",.F.,.F.,{aTit,nOpcx})
	           	If ValType(aAuxInc) == "A" .And. Len(aAuxInc) > 0
	           		aTit := aClone(aAuxInc)
	           	EndIf
	   		EndIf

			//LOG
			If lLog
				AdpLogEAI(3, "aTit: ", aTit)
				AdpLogEAI(3, "cValInt: ", cValInt)
				AdpLogEAI(3, "cValExt: ", cValExt)
				AdpLogEAI(3, "aRatPrj: ", aRatPrj)
				AdpLogEAI(3, "aIntPrj: ", aIntPrj)
				AdpLogEAI(4, nOpcx)
			Else
				ConOut(STR0006)
			EndIf

			BEGIN TRANSACTION
			
			MSExecAuto({|x,y,z,a| FINA040(x,y,z,a)}, aTit, nOpcx, /*aTitPrv*/, Iif( lRatNat, aRatNat, Nil )  )

			// Se houve erros no processamento do MSExecAuto
			If lMsErroAuto
	       		// Obtém o log de erros
				aErroAuto := GetAutoGRLog()
	
	         	// Varre o array obtendo os erros e quebrando a linha
				cLogErro := ""
				For nCount := 1 To Len(aErroAuto)
					cLogErro += StrTran( StrTran( aErroAuto[nCount], "<", "" ), "-", "" ) + Chr(10)
				Next nCount
					
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
	
				lRet := .F.			
					
				DisarmTransaction()
				MsUnLockAll()
			Else
				//Grava o rateio de projeto fora da rotina automatica
				//A pedido da equipe de Controladoria
				If Len(aRatPrj) > 0
					pmsWsCR(cValToChar(nOpcx) ,aRatPrj)
				EndIf
				
				If nOpcx != 5 // Se o evento é diferente de delete
					// Grava o registro na tabela XXF (de/para)
					CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F., 1)

					//De/Para do rateio
					For nI := 1 To Len(aIntPrj)
						CFGA070Mnt(cMarca, aIntPrj[nI][1], aIntPrj[nI][2], aIntPrj[nI][4], aIntPrj[nI][3], .F., 1)
					Next nI
					
					// Monta o JSON de retorno
					ofwEAIObj:Activate()
																			
					ofwEAIObj:setProp("ReturnContent")
										
					ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID",{},'InternalId',,.T.)
					ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[nLtOfItID]:setprop("Name",cMsgUnica,,.T.)
					ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[nLtOfItID]:setprop("Origin",cValExt,,.T.)
					ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[nLtOfItID]:setprop("Destination",cValInt,,.T.)					
					For nI := 1 To Len(aIntPrj)
						nLtOfItID++
						ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID",{},'InternalId',,.T.)
						ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[nLtOfItID]:setprop("Name","ApportionmentInternalId",,.T.)
						ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[nLtOfItID]:setprop("Origin",aIntPrj[nI][4],,.T.)
						ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[nLtOfItID]:setprop("Destination",aIntPrj[nI][3],,.T.)	
					Next nI
												
					If lFKD
						////////////////////////////////////////////////
						//Gravando os Valores acessorios na tabela FKD//
						////////////////////////////////////////////////
						cChaveTit := xFilial("SE1") + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
						cChaveFK7 := FINGRVFK7("SE1", cChaveTit)
	
						FINGRVFKD(cChaveFK7,aValorVA)
					Endif
					
				Else
					// Exclui o registro na tabela XXF (de/para)
					CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .T., 1)
						
					If lFKD
						//Excluindo a FK7 e a FKD
						cChaveTit := xFilial("SE1") + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
						FinDelFKS(cChaveTit,"SE1")
					Endif
						
					//De/Para do rateio
					For nI := 1 To Len(aIntPrj)
						CFGA070Mnt(cMarca, aIntPrj[nI][1], aIntPrj[nI][2], aIntPrj[nI][4], aIntPrj[nI][3], .T., 1)
					Next nI
					
					// Monta o JSON de retorno
					ofwEAIObj:Activate()
																			
					ofwEAIObj:setProp("ReturnContent")
										
					ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID",{},'InternalId',,.T.)
					ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Name",cMsgUnica,,.T.)
					ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Origin",cValExt,,.T.)
					ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Destination",cValInt,,.T.)						
				EndIf
			Endif
				
			END TRANSACTION
			
			aSize( aRatNat, 0 )
			aRatNat := Nil
			aSize( aNat, 0 )
			aNat := Nil
			aSize( aNatCC, 0 )
			aNatCC := Nil
			aSize( aAuxSEZ, 0 )
			aAuxSEZ := Nil
			aSize( aAuxEnt, 0 )
			aAuxEnt := Nil
		Endif
		
	//--------------------------------------
	//resposta da mensagem Unica TOTVS
	//--------------------------------------	
	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
	
		//Se não houve erros na resposta
		If Upper(oEAIObEt:getPropValue("ProcessingInformation"):getPropValue("Status")) == "OK" 
			
			//Verifica se a marca foi informada
			If  oEAIObEt:getHeaderValue("ProductName") !=  nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") )  
				cMarca := UPPER(oEAIObEt:getHeaderValue("ProductName"))
			Else
				lRet := .F.
				cLogErro := ""	
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				cLogErro := STR0020 //"Erro no retorno. O Product é obrigatório!"
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																						
				Return { lRet, ofwEAIObj, cMsgUnica }					
			EndIf
	
			oObLisOfIt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")
	
			For nI := 1 To Len( oObLisOfIt )							
				cValInt := ""
				cValExt := ""
				
				//Verifica se o InternalId foi informado
				If oObLisOfIt[nI]:getPropValue('Origin') != nil .And. !Empty( oObLisOfIt[nI]:getPropValue('Origin') )
					cValInt := oObLisOfIt[nI]:getPropValue('Origin')
				Else
					lRet := .F.
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0021 //"Erro no retorno. O OriginalInternalId é obrigatório!"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
					IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), ConOut(STR0006))
																							
					Return { lRet, ofwEAIObj, cMsgUnica }	
				EndIf

				//Verifica se o código externo foi informado
				If oObLisOfIt[nI]:getPropValue('Destination') != nil .And. !Empty( oObLisOfIt[nI]:getPropValue('Destination') ) 
					cValExt := oObLisOfIt[nI]:getPropValue('Destination')
				Else
					lRet := .F.
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0022 //"Erro no retorno. O DestinationInternalId é obrigatório!"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
					IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), ConOut(STR0006))
																							
					Return { lRet, ofwEAIObj, cMsgUnica }	
				EndIf
				
				If Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == "UPSERT"
					CFGA070Mnt( cMarca, cAlias, cField, cValExt, cValInt, .F., 1 )
				Endif
				
				//Envia os valores de InternalId e ExternalId para o Log
				If lLog
					AdpLogEAI(3, "cValInt" + Str(nI) + ": ", cValInt) // InternalId
					AdpLogEAI(3, "cValExt" + Str(nI) + ": ", cValExt) // ExternalId
				Else
					ConOut(STR0006)
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
		Return {.T., '1.000|2.000|2.002|2.003|2.004|2.005|2.006|3.000', cMsgUnica}
	EndIf

//--------------------------------------
//envio mensagem
//--------------------------------------
ElseIf cTypeTrans == TRANS_SEND

	cValInt := IntTRcExt(, SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)[2]
	
	// Verica operação realizada
	If lLog
		Do Case
		Case Inclui
			AdpLogEAI(4, 3)
		Case Altera
			AdpLogEAI(4, 4)
		OtherWise
			AdpLogEAI(4, 5)
		EndCase
	Else
		ConOut(STR0006)
	EndIf

	If !Inclui .And. !Altera
		cEvent := 'delete'
		CFGA070Mnt(, cAlias, cField,, cValInt, .T.) // excluindo da XXF
	EndIf
	
	ofwEAIObj:Activate()
		
	ofwEAIObj:setEvent(cEvent)
	
	ofwEAIObj:setprop("InternalId",cValInt)		
	ofwEAIObj:setprop("CompanyId",cEmpAnt)
	ofwEAIObj:setprop("BranchId",cFilAnt)
	ofwEAIObj:setprop("CompanyInternalId",cEmpAnt + '|' + cFilAnt)
	ofwEAIObj:setprop("DocumentPrefix",RTrim(SE1->E1_PREFIXO))
	ofwEAIObj:setprop("DocumentNumber", RTrim(SE1->E1_NUM))
	ofwEAIObj:setprop("DocumentParcel", RTrim(SE1->E1_PARCELA))
	ofwEAIObj:setprop("DocumentTypeCode", RTrim(SE1->E1_TIPO))
	ofwEAIObj:setprop('ListOfSourceDocument',{},'ListOfSourceDocument',,.T.)
	ofwEAIObj:setprop("IssueDate", Transform(DToS(SE1->E1_EMISSAO), "@R 9999-99-99"))
	ofwEAIObj:setprop("DueDate", Transform(DToS(SE1->E1_VENCTO), "@R 9999-99-99"))
	ofwEAIObj:setprop("RealDueDate", Transform(DTOS(SE1->E1_VENCREA),"@R 9999-99-99"))
	If Empty(SE1->E1_CLIENTE)
		ofwEAIObj:setprop("CustomerCode", "")
		ofwEAIObj:setprop("StoreId", "")
		ofwEAIObj:setprop("CustomerInternalId", "")
	Else
		ofwEAIObj:setprop("CustomerCode", RTrim(SE1->E1_CLIENTE))
		ofwEAIObj:setprop("StoreId", RTrim(SE1->E1_LOJA))
		ofwEAIObj:setprop("CustomerInternalId", IntCliExt(, , SE1->E1_CLIENTE, SE1->E1_LOJA, )[2]) //Adapter MATI030
	EndIf
	ofwEAIObj:setprop("NetValue", SE1->E1_VALOR)
	ofwEAIObj:setprop("NetValue", SE1->E1_VALOR)
	If Empty(SE1->E1_MOEDA)
		ofwEAIObj:setprop("CurrencyCode", "")
		ofwEAIObj:setprop("CurrencyInternalId", "")
	Else
		ofwEAIObj:setprop("CurrencyCode", PadL(SE1->E1_MOEDA, 2, '0'))
		ofwEAIObj:setprop("CurrencyInternalId", IntMoeExt(, , PadL(SE1->E1_MOEDA, 2, '0'), )[2]) //Adapter CTBI140
	EndIf	
	If Empty(SE1->E1_TXMOEDA)
		ofwEAIObj:setprop("CurrencyRate", "")
	Else
		ofwEAIObj:setprop("CurrencyRate", AllTrim(cValToChar(SE1->E1_TXMOEDA)))
	EndIf
	If Empty(SE1->E1_NATUREZ)
		ofwEAIObj:setprop("FinancialNatureInternalId", "")
	Else
		ofwEAIObj:setprop("FinancialNatureInternalId", F10MontInt(, SE1->E1_NATUREZ)) //Adapter FINI010I
	EndIf
	//Accounting
	oAccounting := ofwEAIObj:setprop("Accounting")
	oAccounting:setProp("AccountingCodeDebit",AllTrim(SE1->E1_DEBITO))
	oAccounting:setProp("AccountingCodeCredit",AllTrim(SE1->E1_CREDIT))
	oAccounting:setProp("CostCenterDebit",AllTrim(SE1->E1_CCD))
	oAccounting:setProp("CostCenterCredit",AllTrim(SE1->E1_CCC))
	oAccounting:setProp("DepartamentDebit",AllTrim(SE1->E1_ITEMD))
	oAccounting:setProp("DepartamentCredit",AllTrim(SE1->E1_ITEMC))
	oAccounting:setProp("ClassValueDebit",AllTrim(SE1->E1_CLVLDB))
	oAccounting:setProp("ClassValueCredit",AllTrim(SE1->E1_CLVLCR))
	//Other
	oOther := ofwEAIObj:setprop("Other")
	oOther:setProp("AcademicRecord",AllTrim(SE1->E1_NUMRA))
	oOther:setProp("AcademicPeriod",AllTrim(SE1->E1_PERLET))
	oOther:setProp("AppliedMatrix",SE1->E1_IDAPLIC)
	oOther:setProp("ItemInternalId",AllTrim(SE1->E1_PRODUTO))
	oOther:setProp("Class",AllTrim(SE1->E1_TURMA))
	If lCposVA 
		oOther:setProp("HotelAccountCode",AllTrim(SE1->E1_CONHTL))
		oOther:setProp("HotelAccountType",AllTrim(SE1->E1_TCONHTL))
	EndIf
	If Inclui .Or. Altera
		SA1->(DbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA))
		For nI := 1 to Len(aImposto)
			cSE1 := (cE1 + aImposto[nI])
			IF SE1->(FieldPos(cSE1)) > 0 // indica de o imposto existe no localizado ou não. cSE1 é o nome do campo do imposto
				cSE1b := (cBase + aImposto[nI])
				cImpBase := '0.0'
				If nI == 2 .Or. nI == 3
					If AllTrim(SA1->A1_PESSOA) == "J"
						cImposto := aImposto[nI]+"-PJ"
					Elseif AllTrim(SA1->A1_PESSOA) == "F"
						cImposto := aImposto[nI] + "-PF"
					Else
						cImposto := aImposto[nI]
					Endif
				Else
					cImposto:= aImposto[nI]
				Endif

				If nI == 4
					cImpBase := CValToChar(SE1->E1_BASECOF)
				ElseIf nI == 2
					cImpBase := IIf(cPaisLoc == "BRA", CValToChar(SE1->E1_BASEIRF), '0.0')
				ElseIf nI == 3
					cImpBase := IIf(cPaisLoc == "BRA", CValToChar(SE1->E1_BASEINS), '0.0')
				Else
					cImpBase := IIf(SE1->(FieldPos(cSE1b)) > 0, CValToChar(SE1->&(cSE1b)), '0.0')
				Endif
				
				ofwEAIObj:setprop('Taxes',{},'Tax',,.T.)
				ofwEAIObj:get("Taxes")[1]:setprop("Name"   	, "CalculationBasis",,.T.)
				ofwEAIObj:get("Taxes")[1]:setprop("Id"   	, cImpBase,,.T.)
				ofwEAIObj:setprop('Taxes',{},'Tax',,.T.)
				ofwEAIObj:get("Taxes")[2]:setprop("Name"   	, "CityCode",,.T.)
				ofwEAIObj:get("Taxes")[2]:setprop("Id"   	, SA1->A1_COD_MUN,,.T.)		
				ofwEAIObj:setprop('Taxes',{},'Tax',,.T.)
				ofwEAIObj:get("Taxes")[3]:setprop("Name"   	, "CountryCode",,.T.)
				ofwEAIObj:get("Taxes")[3]:setprop("Id"   	, SA1->A1_PAIS,,.T.)	
				ofwEAIObj:setprop('Taxes',{},'Tax',,.T.)
				ofwEAIObj:get("Taxes")[4]:setprop("Name"   	, "Percentage",,.T.)
				ofwEAIObj:get("Taxes")[4]:setprop("Id"   	, "0.0",,.T.)	
				ofwEAIObj:setprop('Taxes',{},'Tax',,.T.)
				ofwEAIObj:get("Taxes")[5]:setprop("Name"   	, "Reason",,.T.)
				ofwEAIObj:get("Taxes")[5]:setprop("Id"   	, "003",,.T.)	
				ofwEAIObj:setprop('Taxes',{},'Tax',,.T.)
				ofwEAIObj:get("Taxes")[6]:setprop("Name"   	, "Recalculate",,.T.)
				ofwEAIObj:get("Taxes")[6]:setprop("Id"   	, "true",,.T.)	
				ofwEAIObj:setprop('Taxes',{},'Tax',,.T.)
				ofwEAIObj:get("Taxes")[7]:setprop("Name"   	, "ReductionBasedPercent",,.T.)
				ofwEAIObj:get("Taxes")[7]:setprop("Id"   	, "0.0",,.T.)		
				ofwEAIObj:setprop('Taxes',{},'Tax',,.T.)
				ofwEAIObj:get("Taxes")[8]:setprop("Name"   	, "StateCode",,.T.)
				ofwEAIObj:get("Taxes")[8]:setprop("Id"   	, SA1->A1_ESTADO,,.T.)	
				ofwEAIObj:setprop('Taxes',{},'Tax',,.T.)
				ofwEAIObj:get("Taxes")[9]:setprop("Name"   	, "Taxe",,.T.)
				ofwEAIObj:get("Taxes")[9]:setprop("Id"   	, cImposto,,.T.)	
				ofwEAIObj:setprop('Taxes',{},'Tax',,.T.)
				ofwEAIObj:get("Taxes")[10]:setprop("Name"   , "Value",,.T.)
				ofwEAIObj:get("Taxes")[10]:setprop("Id"   	, CValToChar(SE1->&(cSE1)),,.T.)	
							
			Endif
		Next nI

		If IsIntegTop() //Possui integração com o RM Solum
			aRateio := RatCAR(SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA)
		EndIf

		For nI := 1 To Len(aRateio)
			ofwEAIObj:setprop('ApportionmentDistribution',{},'Apportionment',,.T.)
       		ofwEAIObj:get("ApportionmentDistribution")[nI]:setprop("CostCenterInternalId", "",,.T.)
       		ofwEAIObj:get("ApportionmentDistribution")[nI]:setprop("ProjectInternalId", IIf(!Empty(AllTrim(aRateio[nI][6])), AllTrim(IntPrjExt(, , aRateio[nI][6])[2]), ''),,.T.)
			ofwEAIObj:get("ApportionmentDistribution")[nI]:setprop("TaskInternalId", IIf(!Empty(AllTrim(aRateio[nI][7])), IntTrfExt(, , aRateio[nI][6], '0001', aRateio[nI][7])[2], ''),,.T.)
			ofwEAIObj:get("ApportionmentDistribution")[nI]:setprop("Value", IIf(!Empty(aRateio[nI][8]), aRateio[nI][8], 0),,.T.)
			ofwEAIObj:get("ApportionmentDistribution")[nI]:setprop("Percent", IIf(!Empty(aRateio[nI][5]), aRateio[nI][5], 0),,.T.)
		Next nI

	EndIf
	ofwEAIObj:setprop("Observation",AllTrim(SE1->E1_HIST))
	ofwEAIObj:setprop("Origin",AllTrim(SE1->E1_ORIGEM))
	ofwEAIObj:setprop("HolderCode",AllTrim(SE1->E1_PORTADO))
	ofwEAIObj:setprop("AgencyNumber",AllTrim(SE1->E1_AGEDEP))
	ofwEAIObj:setprop("AccountNumber",AllTrim(SE1->E1_CONTA))
	ofwEAIObj:setprop("OurNumberBanking",AllTrim(SE1->E1_NUMBCO))
	ofwEAIObj:setprop("ContractNumber",AllTrim(SE1->E1_CONTRAT))
	ofwEAIObj:setprop("InterestPercentage",SE1->E1_PORCJUR)
	ofwEAIObj:setprop("AssessmentValue",SE1->E1_VALJUR)
	
EndIf

IIf(lLog, AdpLogEAI(5, "FINI040", ofwEAIObj, lRet), ConOut(STR0006))
dDataBase := dDataAux
Return {lRet, ofwEAIObj, cMsgUnica}

//-------------------------------------------------------------------
/*/{Protheus.doc} RatCAR
Recebe a chave de busca do Titulo à Receber e monta o rateio.

@author  Leandro Luiz da Cruz
@version P11
@since   18/04/2013

@return aResult
/*/
//-------------------------------------------------------------------
Static Function RatCAR(cChave)
   
Local aResult  := {}
Local aPrjtTrf := {}
Local aCntrCst := {}
Local nI       := 0
Local aAreaAnt := GetArea()

dbSelectArea("AFT")
AFT->(dbSetOrder(2)) // AFT_FILIAL+AFT_PREFIX+AFT_NUM+AFT_PARCEL+AFT_TIPO+AFT_CLIENT+AFT_LOJA+AFT_PROJET+AFT_REVISA+AFT_TAREFA

//Povoa o array de Projeto
If AFT->(dbSeek(cChave))
	While AFT->(!Eof()) .And. cChave == AFT->AFT_FILIAL + AFT->AFT_PREFIX + AFT->AFT_NUM + AFT->AFT_PARCEL + AFT->AFT_TIPO + AFT->AFT_CLIENT + AFT->AFT_LOJA
		aAdd(aPrjtTrf, Array(4))
		nI++
		aPrjtTrf[nI][1] := AFT->AFT_PROJET
		aPrjtTrf[nI][2] := AFT->AFT_REVISA
		APrjtTrf[nI][3] := AFT->AFT_TAREFA
		APrjtTrf[nI][4] := AFT->AFT_VALOR1
		AFT->(dbSkip())
	EndDo
EndIf

aResult := IntRatPrjCC(aCntrCst, aPrjtTrf)

RestArea(aAreaAnt)
Return aResult
