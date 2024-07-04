#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "LOJI120.CH"

Static cMarca	:= ""

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJI120
Funcao de integracao com o adapter EAI para envio e recebimento de
operadores de caixa utilizando o conceito de mensagem unica.
@type function
@param Caracter, cXML, Variavel com conteudo xml para envio/recebimento.
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)

@author rafael.pessoa
@version P12
@since 21/05/2018
@return Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
		aRet[1] - (boolean) Indica o resultado da execução da função
		aRet[2] - (caracter) Mensagem Xml para envio
/*/
//-------------------------------------------------------------------
Function LOJI120( cXML, nTypeTrans, cTypeMessage )

Local lRet     	:= .T.
Local cXMLRet  	:= ""
Local cError	:= ""
Local cWarning 	:= "" 
Local aRet		:= {}             
Local cVersao   := "" //Versao da mensagem
Local oXml	 	:= Nil

Private lMsErroAuto   	:= .F.
Private lAutoErrNoFile	:= .T.

If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS  .Or. ( cTypeMessage == EAI_MESSAGE_RESPONSE )
		oXml := XmlParser(cXml, "_", @cError, @cWarning)
		
		If oXml <> Nil .And. Empty(cError) .And. Empty(cWarning)
			
			// Versão da mensagem
            If Type("oXml:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. !Empty(oXml:_TOTVSMessage:_MessageInformation:_version:Text)
               cVersao := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
               
               	If cVersao == "2"
		            aRet := v2000(cXml, nTypeTrans, cTypeMessage, oXml)
		        Else
		            lRet    := .F.
		            cXmlRet := STR0001 //"A versão da mensagem informada não foi implementada!"
		            aRet := { lRet , cXMLRet }
		        EndIf
               
            Else
               lRet := .F.
               cXmlRet := STR0002 //"Versão da mensagem não informada!"
               aRet := { lRet , cXMLRet }
            EndIf
			
		Else
			// "Falha ao gerar o objeto XML"
			lRet := .F.
			cXMLRet := STR0003 //"Falha ao manipular o XML."
			aRet := { lRet , cXMLRet }
		EndIf

	ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := '2.000'
		aRet := { lRet , cXMLRet, "CASHIEROPERATOR" }
	EndIf

ElseIf ( nTypeTrans == TRANS_SEND )//Trata o envio de mensagem

	cVersao := StrTokArr(RTrim(PmsMsgUVer('CASHIEROPERATOR','LOJA120')), ".")[1]
	
    //Faz chamada da versão especifica   
   	If cVersao == "2"
        aRet := v2000(cXml, nTypeTrans, cTypeMessage, oXml)
    Else
        lRet    := .F.
        cXmlRet := STR0001 //"A versão da mensagem não foi informada ou não foi implementada!"
        aRet := { lRet , cXMLRet }
    EndIf
	
EndIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} V2000
Funcao de integracao com o adapter EAI para envio e recebimento de
operadores de caixa utilizando o conceito de mensagem unica.
@type function
@param Caracter, cXML, Variavel com conteudo xml para envio/recebimento.
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)
@param Objeto, oXml, Objeto xml com a mensagem recebida.

@author rafael.pessoa
@version P12
@since 21/05/2018
@return Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
		aRet[1] - (boolean) Indica o resultado da execução da função
		aRet[2] - (caracter) Mensagem Xml para envio
/*/
//-------------------------------------------------------------------
Static Function v2000(cXml, nTypeTrans, cTypeMessage, oXml)

Local lRet     		:= .T.
Local cXMLRet  		:= ""
Local cError 		:= ""  
Local cOperador		:= "" 
Local cValInt 		:= "" 
Local cEvent   		:= "upsert" 
Local nOpcx			:= 3
Local aAux			:= {}             
Local cValExt		:= ""
Local oXmlContent	:= Nil
Local cOperName		:= ""
Local nI			:= 0
Local cNumCart		:= "" //Numero do cartao
Local nDescPer		:= 0
Local nDescVal  	:= 0
Local nTotValDesc 	:= 0
Local nTotPerDesc 	:= 0
Local cAcesUser 	:= ""
Local nPerSang  	:= 3 	//Permite Sangria 
Local nPerCancItem  := 3 	//Permite Cancelar item 
Local nPerCancVenda := 3 	//Permite Cancelar Venda
Local nPerGaveta    := 3 	//Permite usar gaveta de dinheiro
Local nPerEditPay   := 3 	//Permite editar pagamentos
Local nLimSangDin   := 0 	//Limite sangria em Dinheiro
Local aSang			:= {}	//array para garvação do Limite Sangria 
Local cIntOperador  := "" 	//Valor interno do operador
Local cExtOperador  := "" 	//Valor externo do operador
Local oConfigOpe	:= Nil	//Objeto JsonObject com as informações do operador

Default cXml 			:= ""
Default nTypeTrans 		:= 0
Default cTypeMessage 	:= ""
Default oXml 			:= ""

If nTypeTrans == TRANS_RECEIVE

	If XmlChildEx(oXml:_TotvsMessage:_MessageInformation:_Product, "_NAME") <> Nil .And. oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text <> Nil .And. ;
		!Empty(oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
		cMarca := AllTrim(oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
	EndIf

	If cTypeMessage == EAI_MESSAGE_BUSINESS
	
		oXmlContent := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent
		
		//Código do caixa
		If XmlChildEx(oXmlContent, "_INTERNALID") <> Nil .And. oXmlContent:_INTERNALID:Text <> Nil .And. ;
			!Empty(oXmlContent:_INTERNALID:Text) 
			cIntOperador := AllTrim(oXmlContent:_INTERNALID:Text)
			cExtOperador := cIntOperador
				
			//Tratamento utilizando a tabela XXF com um De/Para de codigos
			aAux := Separa(CFGA070Int(cMarca, "SLF", "LF_COD", cIntOperador),"|")
		
			If Len(aAux) >= 3
				cIntOperador := AllTrim(aAux[3])
				DbSelectArea("SLF")
				SLF->(dbSetOrder(1))		
				If SLF->(dbSeek(xFilial("SLF") + cIntOperador))
					cOperador := PADR(cIntOperador,TamSx3("LF_COD")[1])
					cAcesUser := SLF->LF_ACESSO
					nOpcx 	  := 4				//Alteração
				Else
					lRet 	:= .F.
					cXmlRet := STR0004 + cIntOperador + STR0005 //#"Operador de Caixa:" ##"não integrado ao Protheus, verificar integracao de operador. Verificar se o operador esta cadastrado na filial destino correta."
				EndIf	
			EndIf
		
		ElseIf XmlChildEx(oXmlContent, "_CASHIERCODE") <> Nil .And. oXmlContent:_CASHIERCODE:Text <> Nil .And. ; 
			!Empty(oXmlContent:_CASHIERCODE:Text) 
			cOperador := PADR(AllTrim(oXmlContent:_CASHIERCODE:Text),TamSx3("LF_COD")[1]) 
			DbSelectArea("SLF")
			SLF->(dbSetOrder(1))		
			If SLF->(dbSeek(xFilial("SLF") + cOperador))
				cAcesUser := SLF->LF_ACESSO
				nOpcx 	  := 4				//Alteração
			Else			
				lRet 	 := .F.
				cXmlRet := STR0004 + " " + cOperador + STR0006 //#"Operador/Caixa:" ##" verificar se o operador esta cadastrado na filial destino correta."				
			EndIf
		Else	
			lRet	 := .F.
			cXmlRet := STR0007 //"Codigo do caixa não foi informado."
		EndIf

		//Tipo de operacao
		If XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent, "_EVENT") <> Nil .And. AllTrim(Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)) == "DELETE"
			nOpcx := 5 
		EndIf

		If lRet
			//Nome do operador
			If XmlChildEx(oXmlContent, "_NAME") <> Nil .And. oXmlContent:_NAME:Text <> Nil .And. ; 
				!Empty(oXmlContent:_NAME:Text) 
				cOperName := AllTrim(oXmlContent:_NAME:Text) 
			Else	
				lRet	 := .F.
				cXmlRet := STR0008 //"Nome do operador não foi informado."
			EndIf
		EndIf
					
		If lRet
			//Numero do cartão do operador
			If XmlChildEx(oXmlContent, "_CARDNUMBER") <> Nil .And. oXmlContent:_CARDNUMBER:Text <> Nil .And. ; 
				!Empty(oXmlContent:_CARDNUMBER:Text) 
				cNumCart := AllTrim(oXmlContent:_CARDNUMBER:Text) 
			EndIf
		EndIf	
		

		If lRet
			//Desconto Total Percentual 
			If XmlChildEx(oXmlContent, "_DISCOUNTTOTALPERCENT") <> Nil .And. oXmlContent:_DISCOUNTTOTALPERCENT:Text <> Nil .And. ; 
				!Empty(oXmlContent:_DISCOUNTTOTALPERCENT:Text) 
				nTotPerDesc := Val(oXmlContent:_DISCOUNTTOTALPERCENT:Text) 
			EndIf
		EndIf
		
		If lRet
			//Desconto Total Valor 
			If XmlChildEx(oXmlContent, "_DISCOUNTTOTALVALUE") <> Nil .And. oXmlContent:_DISCOUNTTOTALVALUE:Text <> Nil .And. ; 
				!Empty(oXmlContent:_DISCOUNTTOTALVALUE:Text) 
				nTotValDesc := Val(oXmlContent:_DISCOUNTTOTALVALUE:Text) 
			EndIf
		EndIf
		
		If lRet
			//Desconto Item Percentual 
			If XmlChildEx(oXmlContent, "_DISCOUNTITEMPERCENT") <> Nil .And. oXmlContent:_DISCOUNTITEMPERCENT:Text <> Nil .And. ; 
				!Empty(oXmlContent:_DISCOUNTITEMPERCENT:Text) 
				nDescPer := Val(oXmlContent:_DISCOUNTITEMPERCENT:Text) 
			EndIf
		EndIf
		
		If lRet
			//Desconto Item Valor 
			If XmlChildEx(oXmlContent, "_DISCOUNTITEMVALUE") <> Nil .And. oXmlContent:_DISCOUNTITEMVALUE:Text <> Nil .And. ; 
				!Empty(oXmlContent:_DISCOUNTITEMVALUE:Text) 
				nDescVal := Val(oXmlContent:_DISCOUNTITEMVALUE:Text) 
			EndIf
		EndIf		
	
		If lRet
			//Permite Sangria 
			If XmlChildEx(oXmlContent, "_CANWITHDRAWAL") <> Nil .And. oXmlContent:_CANWITHDRAWAL:Text <> Nil .And. ; 
				!Empty(oXmlContent:_CANWITHDRAWAL:Text) 
				nPerSang := Val(oXmlContent:_CANWITHDRAWAL:Text) 
			EndIf
		EndIf
		
		If lRet
			//Permite Cancelar item  
			If XmlChildEx(oXmlContent, "_CANCANCELITEM") <> Nil .And. oXmlContent:_CANCANCELITEM:Text <> Nil .And. ; 
				!Empty(oXmlContent:_CANCANCELITEM:Text) 
				nPerCancItem := Val(oXmlContent:_CANCANCELITEM:Text) 
			EndIf
		EndIf	

		If lRet
			//Permite Cancelar Venda
			If XmlChildEx(oXmlContent, "_CANCANCELSALE") <> Nil .And. oXmlContent:_CANCANCELSALE:Text <> Nil .And. ; 
				!Empty(oXmlContent:_CANCANCELSALE:Text) 
				nPerCancVenda := Val(oXmlContent:_CANCANCELSALE:Text) 
			EndIf
		EndIf
		
		If lRet
			//Permite usar gaveta de dinheiro
			If XmlChildEx(oXmlContent, "_CANOPENDRAWER") <> Nil .And. oXmlContent:_CANOPENDRAWER:Text <> Nil .And. ; 
				!Empty(oXmlContent:_CANOPENDRAWER:Text) 
				nPerGaveta := Val(oXmlContent:_CANOPENDRAWER:Text) 
			EndIf
		EndIf		

		If lRet
			//Permite editar pagamentos
			If XmlChildEx(oXmlContent, "_CANEDITPAYMENT") <> Nil .And. oXmlContent:_CANEDITPAYMENT:Text <> Nil .And. ; 
				!Empty(oXmlContent:_CANEDITPAYMENT:Text) 
				nPerEditPay := Val(oXmlContent:_CANEDITPAYMENT:Text) 
			EndIf
		EndIf
		
		If lRet
			//Permite editar pagamentos
			If XmlChildEx(oXmlContent, "_WITHDRAWALLIMIT") <> Nil .And. oXmlContent:_WITHDRAWALLIMIT:Text <> Nil .And. ; 
				!Empty(oXmlContent:_WITHDRAWALLIMIT:Text) 
				nLimSangDin := Val(oXmlContent:_WITHDRAWALLIMIT:Text) 
				If nLimSangDin > 0
					aSang := {{"R$",nLimSangDin,nLimSangDin}}
				EndIf
			EndIf
		EndIf

		//Realiza Gravação
		If lRet

			oConfigOpe := JsonObject():New()

			oConfigOpe["opcao"]		 := IIF( nOpcx == 5, 3, IIF(nOpcx == 4, 2, 1) )	//1-Inclusao, 2-Alteracao, 3-Exclusao
			oConfigOpe["opername"] 	 := cOperName
			oConfigOpe["shortname"]	 := ""
			oConfigOpe["operador"] 	 := cOperador
			oConfigOpe["permsang"] 	 := nPerSang
			oConfigOpe["permcanit"]  := nPerCancItem
			oConfigOpe["permcanvd"]  := nPerCancVenda
			oConfigOpe["permedipay"] := nPerEditPay
			oConfigOpe["permgaveta"] := nPerGaveta
			oConfigOpe["descper"] 	 := nDescPer
			oConfigOpe["descval"] 	 := nDescVal
			oConfigOpe["numcartao"]  := cNumCart
			oConfigOpe["totperdesc"] := nTotPerDesc
			oConfigOpe["totvaldesc"] := nTotValDesc
			oConfigOpe["sangria"] 	 := aSang
		
			Begin Transaction

				aAux := LjI120Grv(oConfigOpe)

				If !aAux[1]

					lRet 	:= .F.
					cXmlRet += STR0010 + CRLF + aAux[2]		//"Erro ao realizar operação."
					LjGrvLog("LOJI120", cXmlRet)
				Else	

                    cOperador := aAux[2] 

					//Exclusão
					If nOpcx == 5

						If !CFGA070Mnt(cMarca, "SLF", "LF_COD", /*cValExt*/, cEmpAnt + "|" + RTrim(xFilial("SLF")) + "|" + cOperador, .T., /*nOrdem*/, /*cTable*/, /*cOwnerMsg*/)
							lRet := .F.
							cXmlRet += STR0009 //"Não foi possível gravar/excluir na tabela De/Para."
						EndIf
					Else

						//Inclusão
						If nOpcx == 3
							If !CFGA070Mnt(cMarca, "SLF", "LF_COD", cExtOperador, cEmpAnt + "|" + RTrim(xFilial("SLF")) + "|" + cOperador, /*lDelete*/, /*nOrdem*/, /*cTable*/, /*cOwnerMsg*/)
								lRet := .F.
								cXmlRet += STR0009 //"Não foi possível gravar/excluir na tabela De/Para."
							EndIf
						EndIf

	                    //Monta xml com status do processamento da rotina automatica OK.
						If lRet
							cXMLRet += "<CashierCode>" 	        + cExtOperador + "</CashierCode>"  
							cXMLRet += "<ExternalCode>" 		+ cEmpAnt + "|" + RTrim(xFilial("SLF")) + "|" + cOperador + "</ExternalCode>" 
							cXMLRet += "<DestinationInternalId>"+ cEmpAnt + "|" + RTrim(xFilial("SLF")) + "|" + cOperador + "</DestinationInternalId>"
							cXMLRet += "<OriginInternalId>"		+ cExtOperador +"</OriginInternalId>"
						EndIf
					EndIf
				EndIf

			End Transaction

			FwFreeObj(oConfigOpe)
		EndIf
	
	ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )

		//Gravacao do De/Para Codigo Interno X Codigo Externo  
		If Upper(AllTrim(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text)) == "OK"
			If oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text <> Nil .And.	!Empty(oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
				cMarca := oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
			EndIf
		   	
			If oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text <> Nil .And.;
				!Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text)
			
				cValInt := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text
			EndIf
		   	
			If oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text <> Nil .And.;
				!Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text)
			
				cValExt := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text
			EndIf

			If !Empty(cValExt) .And. !Empty(cValInt)
				If !CFGA070Mnt(cMarca, "SLF", "LF_COD", cValExt, cValInt)
					lRet := .F.
					cXmlRet := STR0009 //"Não foi possível gravar/excluir na tabela De/Para."
				EndIf
			Else
				cXmlRet := STR0011 //"Valor Interno ou Externo em branco, não será possível gravar na tabela De/Para."
				lRet := .F.
			EndIf
		Else //Erro
			If oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message <> Nil
   				//Se não for array
				If ValType(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message) <> "A"
          			//Transforma em array
					XmlNode2Arr(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
				EndIf

          		//Percorre o array para obter os erros gerados
				For nI := 1 To Len(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
					cError := oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nI]:Text + CRLF
				Next nI
			EndIf
			
			lRet 	 := .F.
			cXmlRet  := cError
			
		EndIf	

	EndIf
	
	
ElseIf nTypeTrans == TRANS_SEND

	If !Inclui .And. !Altera
		cEvent := 'delete'		
	EndIf

	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>CASHIEROPERATOR</Entity>'
	cXMLRet +=     '<Event>' + cEvent + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="InternalID">' + cEmpAnt + "|" + RTrim(xFilial("SLF")) + "|" + AllTrim(SLF->LF_COD) + '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'
	
	cXMLRet += '<BusinessContent>'
	
	cXMLRet += 		'<CashierCode>'				+ AllTrim(SLF->LF_COD) 		+'</CashierCode>'
	cXMLRet += 		'<CashierCodeInternalId>'	+ cEmpAnt + "|" + RTrim(xFilial("SLF")) + "|" + AllTrim(SLF->LF_COD) 		+'</CashierCodeInternalId>'	
	cXMLRet += 		'<DiscountTotalPercent>'	+ AllTrim(STR(SLF->LF_TOTDESP)) 		+'</DiscountTotalPercent>'
	cXMLRet += 		'<DiscountTotalValue>'		+ AllTrim(STR(SLF->LF_TOTDESV)) 		+'</DiscountTotalValue>'
	cXMLRet += 		'<DiscountItemPercent>'		+ AllTrim(STR(SLF->LF_DESCPER)) 		+'</DiscountItemPercent>'
	cXMLRet += 		'<DiscountItemValue>'		+ AllTrim(STR(SLF->LF_DESCVAL)) 		+'</DiscountItemValue>'
	cXMLRet += 		'<CardNumber>'				+ _NOTAGS(AllTrim(Encript(allTrim(SLF->LF_NUMCART),1 ))) 	+'</CardNumber>'
	
	IIF( Substr(SLF->LF_ACESSO,5,1)  == "S" , nPerSang  	:= 1 , IIF( Substr(SLF->LF_ACESSO,5,1)  == "N" , nPerSang  		:= 2  , nPerSang  		:= 3 ) )						
	IIF( Substr(SLF->LF_ACESSO,7,1)  == "S" , nPerCancItem  := 1 , IIF( Substr(SLF->LF_ACESSO,7,1)  == "N" , nPerCancItem  	:= 2  , nPerCancItem  	:= 3 ) )	
	IIF( Substr(SLF->LF_ACESSO,8,1)  == "S" , nPerCancVenda := 1 , IIF( Substr(SLF->LF_ACESSO,8,1)  == "N" , nPerCancVenda  := 2  , nPerCancVenda  	:= 3 ) )	
	IIF( Substr(SLF->LF_ACESSO,9,1)  == "S" , nPerEditPay  	:= 1 , IIF( Substr(SLF->LF_ACESSO,9,1)  == "N" , nPerEditPay  	:= 2  , nPerEditPay  	:= 3 ) )						
	IIF( Substr(SLF->LF_ACESSO,13,1) == "S" , nPerGaveta  	:= 1 , IIF( Substr(SLF->LF_ACESSO,13,1) == "N" , nPerGaveta  	:= 2  , nPerGaveta  	:= 3 ) )	

	cXMLRet += 		'<CanWithdrawal>'	+ AllTrim(STR(nPerSang))		+'</CanWithdrawal>'
	cXMLRet += 		'<CanCancelItem>'	+ AllTrim(STR(nPerCancItem)) 	+'</CanCancelItem>'
	cXMLRet += 		'<CanCancelSale>'	+ AllTrim(STR(nPerCancVenda))	+'</CanCancelSale>'
	cXMLRet += 		'<CanEditPayment>'	+ AllTrim(STR(nPerEditPay)) 	+'</CanEditPayment>'
	cXMLRet += 		'<CanOpenDrawer>'	+ AllTrim(STR(nPerGaveta))		+'</CanOpenDrawer>'
	
	DbSelectArea("SA6")
	DbSetOrder(1)//A6_FILIAL+A6_COD
	If dbseek(xFilial("SA6")+ SLF->LF_COD )
		cXMLRet += 		'<Name>'					+ AllTrim(SA6->A6_NOME) 				+'</Name>'
		cXMLRet += 		'<ShortName>'				+ AllTrim(SA6->A6_NREDUZ) 				+'</ShortName>'
	EndIf		

	DbSelectArea("MGW")
	MGW->( DbSetOrder(1) ) //MGW_FILIAL+MGW_CAIXA+MGW_FPAGTO 
	If DbSeek (xFilial("MGW")+ SLF->LF_COD + "R$" )	
		cXMLRet += 		'<WithdrawalLimit>'			+ AllTrim(STR(MGW->MGW_LIM1)) 				+'</WithdrawalLimit>'
	EndIf	

	cXMLRet += '</BusinessContent>'				                     	
	
EndIf

Return {lRet, cXmlRet, "CASHIEROPERATOR"}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjI120Grv
Grava as informações do operador\caixa. Inclui, Altera ou Exclui

@param oConfigOpe	- JsonObject com as informações para configurar o operador

@return aRet	   - {Logico	,;	- Definindo se conseguiu efetuar a operação
@return aRet	   	  Caractere}	- Descrição do erro
				
@author  Rafael Tenorio da Costa
@since 	 06/12/2018
@version 1.0				
/*/	
//-------------------------------------------------------------------------------------------------
Function LjI120Grv(oConfigOpe)

	Local aArea	   	 := GetArea()
	Local aAreaSLF 	 := SLF->( GetArea() )
	Local aAreaSA6 	 := SA6->( GetArea() )	
	Local aRet	   	 := {.T., ""}
	Local cOperador	 := ""
	Local aAcesso	 := {}
	Local nOpcao 	 := 0			//1-Inclusao, 2-Alteracao, 3-Exclusao
	Local cOperName  := ""
	Local cNomeRed	 := ""
	Local cOldUser	 := ""
	Local nPermSang  := 0
	Local nPermCanIt := 0
	Local nPermCanVd := 0
	Local nPermEdPay := 0
	Local nPermGavet := 0
	Local nDescPer   := 0
	Local nDescVal   := 0
	Local cNumCartao := ""
	Local nTotPerDes := 0
	Local nTotValDes := 0
	Local aSangria   := {}

	Private aInLoja  := {}			//Variavel necessaria para manipulacao dos caixas

	nOpcao 	   := oConfigOpe["opcao"]
	cOperName  := oConfigOpe["opername"]
	cNomeRed   := oConfigOpe["shortname"]
	cOldUser   := oConfigOpe["olduser"]
	cOperador  := IIF( Empty(oConfigOpe["operador"]), "01", oConfigOpe["operador"] )	//Inicia com 01 para realizar o soma na inclusão
	nPermSang  := oConfigOpe["permsang"]
	nPermCanIt := oConfigOpe["permcanit"]
	nPermCanVd := oConfigOpe["permcanvd"]
	nPermEdPay := oConfigOpe["permedipay"]
	nPermGavet := oConfigOpe["permgaveta"]
	nDescPer   := oConfigOpe["descper"]
	nDescVal   := oConfigOpe["descval"]
	cNumCartao := oConfigOpe["numcartao"]
	nTotPerDes := oConfigOpe["totperdesc"]
	nTotValDes := oConfigOpe["totvaldesc"]
	aSangria   := oConfigOpe["sangria"]

    If nOpcao <> 3
        Do Case
            Case !(nDescPer > 0)
                aRet[1] := .F.
                aRet[2] := I18n(STR0014, {"DiscountItemPercent",cValToChar(nDescPer)})	//"A Tag #1 foi preenchida com o valor negativo #2. Favor ajustar e enviar novamente o request."
            Case !(nDescVal > 0)
                aRet[1] := .F.
                aRet[2] := I18n(STR0014, {"DiscountItemValue", cValToChar(nDescVal)})	//"A Tag #1 foi preenchida com o valor negativo #2. Favor ajustar e enviar novamente o request."
            Case !(nTotPerDes > 0)
                aRet[1] := .F.
                aRet[2] := I18n(STR0014, {"DiscountTotalPercent", cValToChar(nTotPerDes)})	//"A Tag #1 foi preenchida com o valor negativo #2. Favor ajustar e enviar novamente o request."
            Case !(nTotValDes > 0) 
                aRet[1] := .F.
                aRet[2] := I18n(STR0014, {"DiscountTotalValue", cValToChar(nTotValDes)})	//"A Tag #1 foi preenchida com o valor negativo #2. Favor ajustar e enviar novamente o request."
            OTHERWISE
                aRet[1] := .T.
        EndCase
    EndIf

    If aRet[1] //Caso houver algum valor negativo nao configura o Caixa
	    //Configuracao de Caixa
	    aRet[1] := LjConfCaixa(cOperName, nOpcao, cOldUser, .F., @cOperador)
    EndIF
	
	//Se não for exclusão
	If aRet[1] .And. nOpcao <> 3

		//Inclui o caixa
		aRet := LjAtuCaixa( cOperName, /*cModImp*/ , /*cModGav*/ , /*cModCmc7*/, /*cUsaTef*/,;
							cOperador, /*cOldUser*/, /*cAgencia*/, /*cConta*/  , .F.		,;
							cNomeRed)
		
		If aRet[1]

			cAcesUser := SLF->LF_ACESSO

			//Realiza alteracao para gravar permissoes especificas										
			aAcesso := Lj120Acesso(aAcesso, cAcesUser ,.F.)
			
			//Altera acesso de acordo com a mensagem 1-Sim | 2-Não | 3-Solicita Superior 
			aAcesso[5][1]  := IIF( nPermSang  == 1 , "S" , IIF(nPermSang  == 2 , "N" , "X") )
			aAcesso[7][1]  := IIF( nPermCanIt == 1 , "S" , IIF(nPermCanIt == 2 , "N" , "X") )
			aAcesso[8][1]  := IIF( nPermCanVd == 1 , "S" , IIF(nPermCanVd == 2 , "N" , "X") )
			aAcesso[9][1]  := IIF( nPermEdPay == 1 , "S" , IIF(nPermEdPay == 2 , "N" , "X") )
			aAcesso[13][1] := IIF( nPermGavet == 1 , "S" , IIF(nPermGavet == 2 , "N" , "X") )

			//Grava o perfil e o acesso do caixa
			If Lj120Ok( aAcesso   , .F.			,	.F.		  ,	.F.		   ,;
						.F.	 	  , .F.			, cOperador	  ,	nDescPer   ,;
						nDescVal  , .F.			,	"1"		  ,	cNumCartao ,;
						2		  , /*lIntSiac*/, /*cOpSiac*/ ,	nTotPerDes ,;
						nTotValDes, aSangria	)

				aRet[1] := .T.
				aRet[2] := cOperador
			Else

				aRet[1] := .F.
				aRet[2] := I18n(STR0013, {cOperador, "Lj120Ok"})	//"Não foi possível configurar o operador #1. (#2)"
			Endif			
		EndIf
	EndIf

	FwFreeObj(aAcesso)

	RestArea(aAreaSA6)
	RestArea(aAreaSLF)
	RestArea(aArea)

Return aRet
