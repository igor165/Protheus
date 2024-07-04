#Include "PROTHEUS.ch"
#Include "FWADAPTEREAI.ch"
#Include "FWMVCDEF.ch"
#Include "FINI070LST.ch"

Static __nTamFil		:= 0
Static __nTamPref		:= 0
Static __nTamNum		:= 0
Static __nTamPar		:= 0
Static __nTamTipo		:= 0 
Static __nTamCli		:= 0
Static __nTamLoja		:= 0
Static __nTamSeq		:= 0
Static __nTamMot		:= 0
Static __cVersaoCust	:= ""

/*/{Protheus.doc} IntegDef
Função para chamada para processar a mensagem única

@param cXml, XML recebido pelo EAI Protheus
@param cTypeTrans, Tipo de transação ("0" = TRANS_RECEIVE, "1" = TRANS_SEND)
@param cTypeMsg, Tipo da mensagem do EAI ("20" = EAI_MESSAGE_BUSINESS, "21" = EAI_MESSAGE_RESPONSE
                 "22" = EAI_MESSAGE_RECEIPT, "23" = EAI_MESSAGE_WHOIS)
@param cVersion, Versão da Mensagem Única TOTVS
@param cTransac, Nome da transação.

@author Pedro Alencar
@since 01/09/2016	
@version 12
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
	Local aRet := {}
	
	aRet := FINI070LST(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return aRet

/*/{Protheus.doc} FINI070LST
Adapter da mensagem de lista de baixas a receber

@param cXml, XML da mensagem
@param cTypeTrans, Determina se é uma mensagem a ser enviada ou recebida (TRANS_SEND ou TRANS_RECEIVE)
@param cTypeMsg, Tipo de mensagem (EAI_MESSAGE_WHOIS, EAI_MESSAGE_RESPONSE ou EAI_MESSAGE_BUSINESS)
@param cVersion, Versão da Mensagem Única TOTVS
@param cTransac, Nome da transação.

@return lRet, Indica se a mensagem foi processada com sucesso
@return cXmlRet, XML de retorno do adapter

@author Pedro Alencar
@since 01/09/2016
@version 12
/*/
Function FINI070LST(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
	Local aArea := GetArea()
	Local lRet := .T.
	Local cXMLRet := ""

	If ( cTypeTrans == TRANS_RECEIVE )

		If ( cTypeMsg == EAI_MESSAGE_WHOIS )

			cXmlRet := "1.000|1.001|1.002|1.005"

		ElseIf ( cTypeMsg == EAI_MESSAGE_BUSINESS )
			
			lRet := RecBusXML( cXml, @cXMLRet, cVersion )
		
		EndIf
		
	Endif

	RestArea( aArea )

Return {lRet, cXmlRet, "LISTOFACCOUNTRECEIVABLESETTLEMENTS"}

/*/{Protheus.doc} RecBusXML
Função para tratar o XML recebido na mensagem de Business Content

@param cXml, XML recebido
@param cXMLRet, Variável com a mensagem de resposta. Passada por referência.
@param cVersion, Versão da Mensagem Única TOTVS
@return lRet, Indica se processou a mensagem recebida com sucesso

@author Pedro Alencar
@since 01/09/2016
@version 12
/*/
Static Function RecBusXML( cXml, cXMLRet, cVersion )
	Local lRet			:= .T.
	Local oXML			:= Nil
	Local cEvent		:= ""
	Local cMarca		:= ""
	Local cPathBC		:= "/TOTVSMessage/BusinessMessage/BusinessContent/"
	Local aLstBx		:= {}
	Local nX			:= 0
	Local aAuxList		:= {}
	Local nY			:= 0
	Local cVarAux		:= ""
	Local cTag			:= ""
	Local cBxExt		:= ""
	Local nOperation	:= 0
	Local cPrefTit		:= ""
	Local cNumTit		:= ""
	Local cParcel		:= ""
	Local cTipo			:= ""
	Local cCliente		:= ""
	Local cLoja			:= ""
	Local cSeq			:= ""
	Local dDtBaixa		:= CtoD("//")
	Local dDtEntrada	:= CtoD("//")
	Local nValRec		:= 0
	Local nTxMoeda		:= 0
	Local cMotBaixa		:= ""
	Local cHistBx		:= ""
	Local cFormPag		:= ""
	Local cMoeda		:= ""
	Local cBanco		:= ""
	Local cAgencia		:= ""
	Local cConta		:= ""
	Local cPathAux		:= ""
	Local aVAs			:= {}
	Local aOutrosVal	:= {}
	Local aCab			:= {}
	Local aLstCab		:= {}
	Local nOpbaixa		:= 1
	Local aErroAuto		:= {}
	Local cIntBx		:= ""
	Local aDadosTit		:= {}
	Local aIdsExt		:= {}
	Local aDePara		:= {}
	Local cChaveFK7 	:= ""
	Local lBank			:= .F.
	Local aTitSitu		:= {}
	Local lPagParcial   := .F.

	Local aRatEvEz		:= {}
    Local dDtCan        := dDataBase
	Private lMsErroAuto		:= .F.
	Private lMsHelpAuto		:= .T.
	Private lAutoErrNoFile	:= .T.
	Private cIntegSeq		:= "" //Variável dentro da FINA070. Necessário para garantir a correta sequencia de baixa.
	Private aBaixaSE5		:= {} //Utilizado para capturar a sequencia de baixa na SE5.
	
	oXML := tXMLManager():New()
	lRet := oXML:Parse( cXml )

	If lRet
		//Inicia as variáveis estáticas com os tamanhos dos campos do título
		IniTamSX3()
	
		cEvent := Upper( oXml:XPathGetNodeValue( "/TOTVSMessage/BusinessMessage/BusinessEvent/Event" ) )
		cMarca := oXml:XPathGetAtt( "/TOTVSMessage/MessageInformation/Product", "name" )
		
		//Loop na tag de lista de baixas a receber
		aLstBx := oXml:XPathGetChildArray( cPathBC + "ListOfAccountReceivableSettlement" )
		For nX := 1 to Len( aLstBx )
			lBank := .F.
			aAuxList := oXml:XPathGetChildArray( aLstBx[nX][2] )
            If  Len(aAuxList) == 0 
				Loop
            EndIf
			If cEvent != "DELETE" //Trato o AccountReceivableDocumentInternalId primeiro

				cVarAux := AllTrim(oXml:XPathGetNodeValue(aLstBx[nX][2]+"/AccountReceivableDocumentInternalId")) 
						
				If !Empty( cVarAux )
					lRet := TrataIdTit( cVarAux, cMarca, @cPrefTit, @cNumTit, @cParcel, @cTipo, @cCliente, @cLoja, @cChaveFK7, @cXmlRet )
				Else
					lRet := .F.
					cXmlRet := STR0001 + "AccountReceivableDocumentInternalId" //"Tag obrigatória não informada: "
				Endif

			EndIf

			//Loop nas tags de cada item da lista de baixa a receber
			For nY := 1 to Len( aAuxList )
				
				//Pega o nome da tag e o valor da mesma
				cTag := AllTrim( aAuxList[nY][1] )
				cVarAux := aAuxList[nY][3]
				
				//Se for cancelamento da baixa, só lê a tag de internalId
				If cEvent == "DELETE"
				
					If cTag == "InternalId"
						
						cBxExt := cVarAux
						If !Empty( cBxExt )
							lRet := TrataIdBx( cBxExt, cEvent, cMarca, @nOperation, @cIntBx, @cPrefTit, @cNumTit, @cParcel, @cTipo, @cCliente, @cLoja, @cSeq, @cXmlRet )
							Loop
						Else
							lRet := .F.
							cXmlRet := STR0001 + "InternalId" //"Tag obrigatória não informada: "
						Endif
						
					Endif

					//Verifica se o cancelamento vai retirar o título do banco
					If UPPER(cTag) == "REVERSEREMITTANCEBANK"
						lBank := cVarAux == "1"
                    EndIf
                    
                    If UPPER(cTag) == "CANCELDATE"
						dDtCan := StoD( StrTran( cVarAux, "-" ) ) 
					EndIf

				Else //Se for inclusão de baixa, lê todas as tags do XML

					//Verifica qual é a tag e faz os tratamentos necessários para guardar o valor de cada uma delas
					Do Case
						
						Case cTag == "InternalId"
							
							cBxExt := cVarAux
							If !Empty( cBxExt )
								lRet := TrataIdBx( cBxExt, cEvent, cMarca, @nOperation,,,,,,,,, @cXmlRet )
							Else
								lRet := .F.
								cXmlRet := STR0001 + "InternalId" //"Tag obrigatória não informada: "
							Endif
						
						Case cTag == "ParcialPayment"
							
							If !Empty( cVarAux )								
								If (UPPER( AllTrim( cVarAux ) ) == "TRUE")
									lPagParcial := .T.
								EndIf
							Else
								lRet := .F.
								cXmlRet := STR0001 + "ParcialPayment" //"Tag obrigatória não informada: "
							EndIf
						
						Case cTag == "PaymentDate"
						
							If !Empty( cVarAux )
								dDtBaixa := StoD( StrTran( cVarAux, "-" ) )
							Else
								lRet := .F.
								cXmlRet := STR0001 + "PaymentDate" //"Tag obrigatória não informada: "
							Endif
						
						Case cTag == "CreditDate"
							
							dDtEntrada := StoD( StrTran( cVarAux, "-" ) )
							
						Case cTag == "PaymentValue"
						
							If !Empty( cVarAux )
								nValRec := Val( cVarAux )
							Else
								lRet := .F.
								cXmlRet := STR0001 + "PaymentValue" //"Tag obrigatória não informada: "
							Endif

						Case cTag == "OtherValues"
						
							If Len(oXml:XPathGetChildArray( aAuxList[nY][2] )) > 0
								cPathAux := aAuxList[nY][2]							
								lRet := TrataOther( oXML, cPathAux, @aOutrosVal, @cXmlRet )
								//aOutrosVal[1] = Juros | [2] = Desconto | [3] = Abatimento | [4] = Despesa | [5] = Multa 
							Else
								aAdd( aOutrosVal, 0 )
								aAdd( aOutrosVal, 0 )
								aAdd( aOutrosVal, 0 )
								aAdd( aOutrosVal, 0 )
								aAdd( aOutrosVal, 0 )							
							Endif		
						
						Case cTag == "ListOfComplementaryValues"
						
							If Len(oXml:XPathGetChildArray( aAuxList[nY][2] )) > 0
								cPathAux := aAuxList[nY][2]
								lRet := TrataVA( oXML, cMarca, cPathAux, cChaveFK7, @aVAs, @cXmlRet, cPrefTit, cNumTit, cParcel, cTipo, cCliente, cLoja )
								//aVAs[x][1] = Chave FK7 do título | [2] = Código do VA | [3] = Valor informado
							Endif
						
						Case cTag == "CurrencyInternalId"
						
							If !Empty( cVarAux )
								lRet := TrataIdMoe( cVarAux, cMarca, @cMoeda, @cXmlRet )							
							Endif		
						
						Case cTag == "CurrencyRate"
						
							If !Empty( cVarAux )
								nTxMoeda := Val( cVarAux )
							Endif
						
						Case cTag == "PaymentMethod"
						
							If !Empty( cVarAux )
								If Empty( cMotBaixa )
									cMotBaixa := RetMotBx( 1, cVarAux )
								EndIf
							Else
								lRet := .F.
								cXmlRet := STR0001 + "PaymentMethod" //"Tag obrigatória não informada: "
							Endif
								
						Case cTag == "CustomPaymentMethod" .And. VAL(cVersion) > 1.004

							If Empty( cMotBaixa )
								cMotBaixa := cVarAux
							EndIf
							
						Case cTag == "BankInternalId"
						
							If !Empty( cVarAux )
								lRet := TrataIdBco( cVarAux, cMarca, @cBanco, @cAgencia, @cConta, @cXmlRet )							
							Endif
							
						Case cTag == "HistoryText"
						
							cHistBx := AllTrim( cVarAux )

						Case cTag == "PaymentMeans"

							If !Empty(cVarAux)

								cFormPag := AllTrim( cVarAux )

								If cFormPag == "000"		//OUTROS
									cFormPag := "OUT"
								ElseIf cFormPag == "001"	//DINHEIRO
									cFormPag := "R$"
								ElseIf cFormPag == "002"	//CHEQUE
									cFormPag := "CH"
								ElseIf cFormPag == "003"	//CARTÃO
									cFormPag := "CC"
								ElseIf cFormPag == "004"	//CARTÃO DE DEBITO
									cFormPag := "CD"
								ElseIf cFormPag == "005"	//PARCELADO
									cFormPag := "FI"
								ElseIf cFormPag == "006"	//VALE
									cFormPag := "VA"
								ElseIf cFormPag == "007"	//DEBITO EM CONTA CORRENTE
									cFormPag := "DC"
								ElseIf cFormPag == "008"	//BOLETO
									cFormPag := "BOL"
								ElseIf cFormPag == "009"	//DEBITO EM FOLHA
									cFormPag := "DF"
								Else
									lRet := .F.
									cXmlRet := STR0011 + "PaymentMeans" //"Valor inválido na TAG "
								EndIf    

							EndIf

						Case cTag == "ListOfFinancialNatureApportionment"
							If !Empty( cVarAux )
								cPathAux := aAuxList[nY][2]
								lRet := TrataEvEz( oXml, cMarca, cPathAux, @aRatEvEz, @cXmlRet )
							EndIf

					End Case
				
				Endif
				
				If !lRet
					Exit
				Endif

			Next nY
			
			//Se não houver erro, monta o vetor com as informações da cada baixa informada no XML
			If lRet
												
				//Define o vetor com os campos que serão enviados para a execauto e limpa as variáveis para não ficar sujeira na próxima baixa da lista
				aAdd( aCab, { "E1_PREFIXO", cPrefTit, NIL } )
				aAdd( aCab, { "E1_NUM", cNumTit, NIL } )
				aAdd( aCab, { "E1_PARCELA", cParcel, NIL } )
				aAdd( aCab, { "E1_TIPO", cTipo, NIL } )
				aAdd( aCab, { "E1_CLIENTE", cCliente, NIL } )
				aAdd( aCab, { "E1_LOJA", cLoja, NIL } )
								
				//Se não for cancelamento da baixa, monta o aCabs com as informações da baixa. Senão, faz apenas os tratamentos para o cancelamento
				If cEvent != "DELETE"
					
					//Guarda os dados do título no vetor para gerar o de/para da baixa posteriormente				
					aAdd( aDadosTit, { cPrefTit, cNumTit, cParcel, cTipo, cCliente, cLoja, cBxExt } )
					cPrefTit := ""
					cNumTit := ""
					cParcel := ""
					cTipo := ""
					cCliente := ""
					cLoja := ""
					
					aAdd( aCab, { "AUTDTBAIXA", dDtBaixa, NIL } )
					dDtBaixa := CtoD( "//" )
					If !Empty( dDtEntrada )
						aAdd( aCab, { "AUTDTCREDITO", dDtEntrada, NIL } )
						dDtEntrada := CtoD( "//" )
					Endif
					aAdd( aCab, { "AUTVALREC", nValRec, NIL } )
					nValRec := 0
					
					If nTxMoeda > 0 
						aAdd( aCab, { "AUTTXMOEDA", nTxMoeda, NIL } )
						nTxMoeda := 0
					ElseIf !Empty( cMoeda )
						nTxMoeda := RecMoeda( dDtBaixa, Val(cMoeda) )
						If nTxMoeda > 0
							aAdd( aCab, { "AUTTXMOEDA", nTxMoeda, NIL } )
						EndIf
						nTxMoeda := 0
						cMoeda := ""
					Endif
					
					aAdd( aCab, { "AUTMOTBX", cMotBaixa, NIL } )
					cMotBaixa := ""
					If !Empty( cBanco ) .AND. !Empty( cAgencia ) .AND. !Empty( cConta )
						aAdd( aCab, { "AUTBANCO", cBanco, NIL } )
						aAdd( aCab, { "AUTAGENCIA", cAgencia, NIL } )
						aAdd( aCab, { "AUTCONTA", cConta, NIL } )
						cBanco := ""
						cAgencia := ""
						cConta := ""
					Endif
					If !Empty( cHistBx )
						aAdd( aCab, { "AUTHIST", cHistBx, NIL } )
						cHistBx := ""
					Endif

					If !Empty(cFormPag)
						aAdd( aCab, { "AUTFORMAPG", cFormPag, NIL } )
						cFormPag := ""
					EndIf

					If Len(AOUTROSVAL) > 0
						//aOutrosVal[1] = Juros | [2] = Desconto | [3] = Abatimento | [4] = Despesa | [5] = Multa
						If aOutrosVal[1] > 0
							aAdd( aCab, { "AUTJUROS", aOutrosVal[1], NIL } )
						EndIf
						If aOutrosVal[2] > 0
							aAdd( aCab, { "AUTDESCONT", aOutrosVal[2], NIL } )
						EndIf
						If aOutrosVal[3] > 0
							aAdd( aCab, { "AUTDECRESC", aOutrosVal[3], NIL } )
						EndIf
						If aOutrosVal[4] > 0
							aAdd( aCab, { "AUTACRESC", aOutrosVal[4], NIL } )
						EndIf
						If aOutrosVal[5] > 0
							aAdd( aCab, { "AUTMULTA", aOutrosVal[5], NIL } )
						EndIf
						aSize ( aOutrosVal, 0 )					
					EndIf

                    aAdd( aCab, { "PAGPARCIAL", lPagParcial, NIL } ) //indica se a baixa e parcial ou total
                    
					//Guarda o vetor da baixa e o de valores acessórios no vetor de lista de baixas que será utilizado nas chamadas de execauto
					aAdd( aLstCab, { aClone( aCab ), aClone( aVAs ) } )
					aSize ( aCab, 0 )
					aSize ( aVAs, 0 )
					
				Else //Se for Cancelamento
                    
                    aAdd( aCab, { "AUTDTCAN", dDtCan, NIL } )

					Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /" + MV_CRNEG, cPrefTit, cNumTit, cParcel, cTipo,,, cCliente, cLoja )
					//Baixas na ordem em que foram feitas
					aSort( aBaixaSE5,,, {|x,y| x[9] < y[9] } )
					nOpBaixa := aScan( aBaixaSE5, { |x| RTrim( x[9] ) == RTrim( cSeq ) } )
					If nOpBaixa == 0
						nOpBaixa := 1
					Endif
					aSize( aBaixaSE5, 0 ) //Zera o array, pois o mesmo é usado também dentro do FINA070
					
					//Guarda o vetor da baixa e o de valores acessórios (no caso de cancelamento, Nil) no vetor de lista de baixas que será utilizado nas chamadas de execauto
					aAdd( aLstCab, { aClone( aCab ), Nil } )
					aSize ( aCab, 0 )
					
					//Guarda o ExternalId da baixa no vetor para excluir o de/para da baixa posteriormente				
					aAdd( aIdsExt, {cIntBx,lBank} )
					cIntBx := ""
					
				Endif
			
			Else
				Exit
			Endif

		Next nX
		
		BEGIN TRANSACTION
			
			SetFunName( "F070LST" )
			
			For nX := 1 to Len( aLstCab )
				
				//aLstCab[nX][1] = aCab (Vetor com os campos a serem gravados na execauto) | aLstCab[nX][2] = aVAs (Vetor de valores acessórios) 
				MsExecAuto( {|a,b,c,d,e| FINA070(a,b,,c,,,,d,e)}, aLstCab[nX][1], nOperation, nOpbaixa, aLstCab[nX][2], aRatEvEz )
								
				If lMsErroAuto
					
					lRet := .F.
					aErroAuto := GetAutoGRLog()
					For nY := 1 To Len( aErroAuto )
						cXMLRet += _NoTags( aErroAuto[nY] ) + CRLF
					Next nY
					
					DisarmTransaction()
					
				Else
					
					If nOperation == 3 //Inclusão da baixa
						If Empty(cIntegSeq) .And. Empty(SE5->E5_SEQ) //Se não carregou a variavel e o E5_SEQ estiver vazio, então efetua rollback pois não gravou a sequencia correta 
							lRet := .F.
							cXmlRet := STR0002 //"Não foi possível definir a sequência de baixa correta. Verifique se a rotina Baixas a Receber (FINA070) está atualizada."
							DisarmTransaction()
						Else
							If Empty(cIntegSeq)
								cIntegSeq := SE5->E5_SEQ
							EndIf
														
							cPrefTit := aDadosTit[nX][1]
							cNumTit := aDadosTit[nX][2]
							cParcel := aDadosTit[nX][3]
							cTipo := aDadosTit[nX][4]
							cCliente := aDadosTit[nX][5]
							cLoja := aDadosTit[nX][6]
							
							//Monta o internalId do protheus para a baixa em questão
							cIntBx := F70MontInt( FWxFilial("SE1"), cPrefTit, cNumTit, cParcel, cTipo, cCliente, cLoja, cIntegSeq )							
							cIntegSeq := "" //Limpa a variável do sequencial para não gravar a mesma sequência na próxima baixa da lista
							
							//aDadosTit[nX][7] = ExternalId da baixa recebida no XML
							aAdd( aDePara, { cIntBx, aDadosTit[nX][7] } )
							
						Endif
					ElseIf nOperation == 5 //Cancelamento da baixa
						
						aTitSitu := {}
						aAdd( aDePara, aIdsExt[nX][1] )
						
						If aIdsExt[nX][2] // Retira o título do banco no cancelamento
							
							aTitSitu := aClone(aLstCab[nX][1])
							aAdd(aTitSitu,{"AUTSITUACA"	, "0"	,Nil})
							aAdd(aTitSitu,{"AUTBANCO"	, ""	,Nil})
							aAdd(aTitSitu,{"AUTAGENCIA"	, ""	,Nil})
							aAdd(aTitSitu,{"AUTCONTA"	, ""	,Nil})
							aAdd(aTitSitu,{"AUTNUMBCO"	, ""	,Nil})

							MSExecAuto({|a, b| FINA060(a, b)}, 2, aTitSitu )

							If lMsErroAuto
								lRet := .F.
								aErroAuto := GetAutoGRLog()
								For nY := 1 To Len( aErroAuto )
									cXMLRet += _NoTags( aErroAuto[nY] ) + CRLF
								Next nY
								DisarmTransaction()
							EndIf
						EndIF
					Endif
				Endif
				
				If !lRet
					Exit
				Endif
				
			Next nX
		
		END TRANSACTION
		
		//Grava ou apaga o de/para das baixas e monta o XML de resposta para o caso de ser inclusão
		If lRet
		
			If nOperation == 3 //Inclusão da baixa
		
				cXMLRet := "<ListOfInternalId>"			
				For nX := 1 to Len( aDePara )					
					//Inclui o registro de de/para (XXF)
					CFGA070Mnt( cMarca, "SE1", "E1_BAIXA", aDePara[nX][2], aDePara[nX][1] )
					cXMLRet += "<InternalId>"
					cXMLRet +=     "<Name>LISTOFACCOUNTRECEIVABLESETTLEMENTS</Name>" 
					cXMLRet +=     "<Origin>" + aDePara[nX][2] + "</Origin>" //Valor recebido da outra marca
					cXMLRet +=     "<Destination>" + aDePara[nX][1] + "</Destination>" //Valor interno gerado no Protheus
					cXMLRet += "</InternalId>"
				Next nX 				
				cXMLRet += "</ListOfInternalId>"
		
			ElseIf nOperation == 5 //Cancelamento da baixa
				
				For nX := 1 to Len( aDePara )					
					//Exclui o registro de de/para (XXF)
					CFGA070Mnt( cMarca, "SE1", "E1_BAIXA",, aDePara[nX], .T. )
				Next nX
				
			Endif
			
		Endif
		
	Endif

	aSize ( aLstBx, 0 )
	aLstBx := Nil
	aSize ( aAuxList, 0 )
	aAuxList := Nil		
	aSize ( aVAs, 0 )
	aVAs := Nil
	aSize ( aOutrosVal, 0 )
	aOutrosVal := Nil
	aSize ( aCab, 0 )
	aCab := Nil
	aSize ( aLstCab, 0 )
	aLstCab := Nil
	aSize ( aErroAuto, 0 )
	aErroAuto := Nil
	aSize ( aDadosTit, 0 )
	aDadosTit := Nil
	aSize ( aIdsExt, 0 )
	aIdsExt := Nil	
	aSize ( aDePara, 0 )
	aDePara := Nil
Return lRet

/*/{Protheus.doc} TrataIdBx
Função para tratar o InternalId recebido na baixa e definir a operação que será executada

@param cBxExt, ExternalId da baixa recebido no XMl.
@param cEvent, Evento da mensagem (UPSERT ou DELETE).
@param cMarca, Marca que está enviando a mensagem.
@param nOperation, Operação que será executada no processamento (inclusão ou exclusão). Passada por referência.
@param cIntBx, Retorna o InternalId encontrado no de/para Protheus. Passado por referência.
@param cPrefTit, Prefixo do título encontrado no de/para. Passado por referência.
@param cNumTit, Número do título encontrado no de/para. Passado por referência.
@param cParcel, Parcela do título encontrado no de/para. Passado por referência.
@param cTipo, Tipo do título encontrado no de/para. Passado por referência.
@param cCliente, Código do cliente do título encontrado no de/para. Passado por referência.
@param cLoja, Loja do cliente do título encontrado no de/para. Passado por referência.
@param cSeq, Sequencia da baixa encontrada no de/para. Passado por referência.
@param cXMLRet, Variável com a mensagem de resposta. Passada por referência.
@return lRet, Indica se a operação foi definida com sucesso.

@author Pedro Alencar
@since 01/09/2016
@version 12
/*/
Static Function TrataIdBx( cBxExt, cEvent, cMarca, nOperation, cIntBx, cPrefTit, cNumTit, cParcel, cTipo, cCliente, cLoja, cSeq, cXmlRet )
	Local lRet := .T.
	Local aRetBx := {}
	Default cBxExt := ""
	Default cEvent := ""
	Default cMarca := ""
	Default nOperation := 0	
	Default cIntBx := ""
	Default cPrefTit := ""
	Default cNumTit := ""
	Default cParcel := ""
	Default cTipo := ""
	Default cCliente := ""
	Default cLoja := ""
	Default cSeq := ""
	Default cXmlRet := ""
	
	aRetBx := F70GetInt( cBxExt, cMarca )
	
	If aRetBx[1]		
		If cEvent == "UPSERT"
			lRet := .F.
			cXmlRet := STR0003 + cBxExt //"Já existe uma baixa com esse internalId. Caso deseje modificar esta baixa, é necessário realizar o cancelamento da baixa e baixar o título novamente. InternalId informado: "
		ElseIf cEvent == "DELETE"
			nOperation := 5
			cIntBx := aRetBx[3]
			
			If Len( aRetBx[2] ) >= 9
				cPrefTit :=  PadR( aRetBx[2][3], __nTamPref )
				cNumTit := PadR( aRetBx[2][4], __nTamNum ) 
				cParcel := PadR( aRetBx[2][5], __nTamPar )
				cTipo := PadR( aRetBx[2][6], __nTamTipo )
				cCliente := PadR( aRetBx[2][7], __nTamCli )
				cLoja := PadR( aRetBx[2][8], __nTamLoja )
				cSeq := PadR( aRetBx[2][9], __nTamSeq )
			Else
				lRet := .F.
				cXmlRet := STR0004 //"Houve um problema no de/para do internalId da baixa. Verifique se o de/para está cadastrado corretamente no Protheus."
			Endif
		Endif										 
	Else			
		If cEvent == "UPSERT"
			nOperation := 3
		ElseIf cEvent == "DELETE"
			lRet := .F.
			cXmlRet := STR0005 + cBxExt //"Não foi possível encontrar a baixa para realizar o cancelamento: "
		Endif			
	Endif
	
	aSize ( aRetBx, 0 )
	aRetBx := Nil	
Return lRet

/*/{Protheus.doc} TrataIdTit
Função para tratar o InternalId do título a receber recebido na baixa

@param cTitExt, ExternalId do título a receber.
@param cMarca, Marca que está enviando a mensagem.
@param cPrefTit, Prefixo do título encontrado no de/para. Passado por referência.
@param cNumTit, Número do título encontrado no de/para. Passado por referência.
@param cParcel, Parcela do título encontrado no de/para. Passado por referência.
@param cTipo, Tipo do título encontrado no de/para. Passado por referência.
@param cCliente, Código do cliente do título encontrado no de/para. Passado por referência.
@param cLoja, Loja do cliente do título encontrado no de/para. Passado por referência.
@param cChaveFK7, Chave do título a receber gerada na FK7. Passado por referência.
@param cXMLRet, Variável com a mensagem de resposta. Passada por referência.
@return lRet, Indica se de/para foi encontrado com sucesso.

@author Pedro Alencar
@since 01/09/2016
@version 12
/*/
Static Function TrataIdTit( cTitExt, cMarca, cPrefTit, cNumTit, cParcel, cTipo, cCliente, cLoja, cChaveFK7, cXmlRet )
	Local lRet := .T.
	Local aRetTit := {}
	Local aAreaSE1 := {}
	Local cFilSE1 := ""
	Local cChaveTit := ""
	Default cTitExt := ""
	Default cMarca := ""
	Default cPrefTit := ""
	Default cNumTit := ""
	Default cParcel := ""
	Default cTipo := ""
	Default cCliente := ""
	Default cLoja := ""
	Default cXmlRet := ""
	
	aRetTit := IntTRcInt( cTitExt, cMarca )
			
	If aRetTit[1]
		cFilSE1 := PadR( aRetTit[2][2], __nTamFil )
		cPrefTit := PadR( aRetTit[2][3], __nTamPref )
		cNumTit := PadR( aRetTit[2][4], __nTamNum )
		cParcel := PadR( aRetTit[2][5], __nTamPar )
		cTipo := PadR( aRetTit[2][6], __nTamTipo )
		
		aAreaSE1 := SE1->( GetArea() )
		SE1->( dbSetOrder( 1 ) ) //E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO

		cChaveTit := cFilSE1 + cPrefTit + cNumTit + cParcel + cTipo
		If SE1->( msSeek( cChaveTit ) )
			cCliente := SE1->E1_CLIENTE
			cLoja := SE1->E1_LOJA
			
			cChaveTit := cFilSE1 + "|" + cPrefTit + "|" + cNumTit + "|" + cParcel + "|" + cTipo + "|" + cCliente + "|" + cLoja
			cChaveFK7 := FINGRVFK7( "SE1", cChaveTit )			
		Else
			lRet := .F.
			cXmlRet := STR0006 + cChaveTit //"O título informado para baixa não foi encontrado no Protheus: "
		Endif
		
		RestArea( aAreaSE1 )
	Else
		lRet := .F.
		cXmlRet := STR0007 + cTitExt //"O título informado para baixa não foi encontrado no de/para Protheus: "
	Endif
	
	aSize ( aRetTit, 0 )
	aRetTit := Nil
	aSize ( aAreaSE1, 0 )
	aAreaSE1 := Nil	
Return lRet

/*/{Protheus.doc} RetMotBx
Função para encontrar o código de motivo de baixa no Protheus, com base no valor recebido no XML 

@param nTipo,Identificação da coluna de retorno (1-códigos numéricos-XML, 2-códigos alfa-PROTHEUS)
@param cCod, Código da Enumeração do XML
@return cRet, código do motivo de baixa no Protheus

@author Pedro Alencar
@since 01/09/2016
@version 12
/*/
Static Function RetMotBx( nTipo, cCod )		
	Local aDeParaMot := {}
	Local nPosic := 0
	Local cRet := ""	
	Default nTipo := 1
	
	//Vetor de de/para com o relacionamento entre os motivos de baixa e codigos a serem trafegados no XML
	aDeParaMot := { { "001", "AD"  }, { "002", "AB"  }, { "003", "DV"  }, { "004", "NC"  }, ;
					  { "005", "NP"  }, { "006", "BX"  }, { "007", "NOR" }, { "008", "DAC" }, ;
					  { "009", "DEB" }, { "010", "VEN" }, { "011", "LIQ" }, { "012", "FAT" }, ;
					  { "013", "CRD" }, { "014", "CEC" }, { "015", "BOL" }, { "016", "SUB" } }
	
	//Procura a posição do código recebido no array de de/para
	nPosic := aScan( aDeParaMot, { |x| x[nTipo] == AllTrim( Upper(cCod) ) } )
	
	If nPosic > 0
		cRet := Padr( aDeParaMot[nPosic][Iif( nTipo == 1, 2, 1 )], __nTamMot )
	Else
		cRet := Space( __nTamMot )
	Endif 
	
	aSize ( aDeParaMot, 0 )
	aDeParaMot := Nil
Return cRet


/*/{Protheus.doc} TrataIdMoe
Função para tratar o InternalId da moeda da baixa

@param cMoedaExt, ExternalId da moeda.
@param cMarca, Marca que está enviando a mensagem.
@param cMoeda, Código da moeda encontrada no de/para. Passado por referência.
@param cXMLRet, Variável com a mensagem de resposta. Passada por referência.
@return lRet, Indica se de/para foi encontrado com sucesso.

@author Pedro Alencar
@since 01/09/2016
@version 12
/*/
Static Function TrataIdMoe( cMoedaExt, cMarca, cMoeda, cXmlRet )
	Local lRet := .T.
	Local aRetMoeda := {}
	Default cMoedaExt := ""
	Default cMarca := ""
	Default cMoeda := ""
	Default cXmlRet := ""
	
	aRetMoeda := IntMoeInt( cMoedaExt, cMarca )
			
	If aRetMoeda[1]
		cMoeda := aRetMoeda[2][3]
	Else
		lRet := .F.
		cXmlRet := STR0008 + cMoedaExt //"A moeda informada para baixa não foi encontrada no de/para Protheus: "
	Endif
	
	aSize ( aRetMoeda, 0 )
	aRetMoeda := Nil
Return lRet

/*/{Protheus.doc} TrataIdBco
Função para tratar o InternalId do banco da baixa

@param cBancoExt, ExternalId do banco.
@param cMarca, Marca que está enviando a mensagem.
@param cBanco, Código do banco encontrado no de/para. Passado por referência.
@param cAgencia, Código da agência encontrada no de/para. Passado por referência.
@param cConta, Código da conta encontrada no de/para. Passado por referência.
@param cXMLRet, Variável com a mensagem de resposta. Passada por referência.
@return lRet, Indica se de/para foi encontrado com sucesso.

@author Pedro Alencar
@since 01/09/2016
@version 12
/*/
Static Function TrataIdBco( cBancoExt, cMarca, cBanco, cAgencia, cConta, cXmlRet )
	Local lRet := .T.
	Local aRetBco := {}
	Default cBancoExt := ""
	Default cMarca := ""
	Default cBanco := ""
	Default cAgencia := ""
	Default cConta := ""
	Default cXmlRet := ""
	
	aRetBco := M70GetInt( cBancoExt, cMarca )
	
	If aRetBco[1]
		cBanco := aRetBco[2][3]
		cAgencia := aRetBco[2][4]
		cConta := aRetBco[2][5]
	Else
		lRet := .F.
		cXmlRet := STR0009 + cBancoExt //"O banco informado para baixa não foi encontrado no de/para Protheus: "
	Endif
	
	aSize ( aRetBco, 0 )
	aRetBco := Nil
Return lRet



/*/{Protheus.doc} TrataVA
Função para tratar a lista de valores acessórios informada no XML

@param oXML, Objeto que trata o XML recebido.
@param cMarca, Marca que está enviando a mensagem.
@param cPathAux, Caminho do nó da lista de valores acessórios no XML.
@param cChaveFK7, Chave do título a receber gerada na FK7.
@param aVAs    , Vetor no qual serão retornados os dados de cada valor acessório. Passado por referência.
@param cXMLRet , Variável com a mensagem de resposta. Passada por referência.
@param cPrefTit, Caracter , Prefixo do titulo a ser baixado
@param cNumTit , Caracter , Numero do titulo a ser baixado
@param cParcel , Caracter , Numero da parcela do titulo a ser baixado
@param cTipo   , Caracter , Tipo do titulo a ser baixado
@param cCliente, Caracter , Codigo do cliente do titulo a ser baixado
@param cLoja   , Caracter , Codigo da loja do cliente do titulo a ser baixado. 
@return lRet, Indica se a leitura dos VAs foi realizada com sucesso.

@author Pedro Alencar
@since 01/09/2016
@version 12
/*/
Static Function TrataVA( oXML AS OBJECT, cMarca AS CHARACTER, cPathAux AS CHARACTER, cChaveFK7 AS CHARACTER,;
                        aVAs AS ARRAY, cXmlRet AS CHARACTER ,cPrefTit AS CHARACTER, cNumTit AS CHARACTER,;
                        cParcel AS CHARACTER, cTipo AS CHARACTER,cCliente AS CHARACTER, cLoja AS CHARACTER ) AS LOGICAL
	Local aAuxList AS ARRAY
	Local aLstVA AS ARRAY
	Local cCodVA AS CHARACTER
	Local cTag AS CHARACTER
	Local cVAExt AS CHARACTER
	Local cVarAux AS CHARACTER
	Local lRet AS LOGICAL
	Local lTemFKD AS LOGICAL
	Local nValInfo AS NUMERIC
	Local nX AS NUMERIC
	Local nY AS NUMERIC

	Default aVAs := {}
	Default cCliente := ""
	Default cLoja := ""
	Default cMarca := ""
	Default cNumTit := ""
	Default cParcel := ""
	Default cPathAux := ""
	Default cPrefTit := ""
	Default cTipo := ""
	Default cXmlRet := ""
	
    lRet := .T.

	//Loop na tag de lista de valores acessórios
	aLstVA := oXml:XPathGetChildArray( cPathAux )
	For nX := 1 to Len( aLstVA )
        aAuxList := oXml:XPathGetChildArray( aLstVA[nX][2] )
		
		//Limpa a variável para pegar os valores do próximo item da lista
        cCodVA := ""
        lRet := .T.
        lTemFKD := .F.
        nValInfo := 0
		
		//Loop nas tags de cada item da lista de valores acessórios
        For nY := 1 to Len( aAuxList )
                                                        
            //Pega o nome da tag e o valor da mesma
            cTag := AllTrim( aAuxList[nY][1] )
            cVarAux := aAuxList[nY][3]
            
            //Verifica qual é a tag e faz os tratamentos necessários para guardar o valor de cada uma delas
            Do Case
                Case cTag == "ComplementaryValueInternalId" 
                    cVAExt := cVarAux
                    If ! Empty( cVAExt )
                        lRet := TrataIdVA( cVAExt, cMarca, @cCodVA, @cXmlRet )
                        If lRet						
                            lTemFKD := FindFKD( cCodVA, cPrefTit, cNumTit, cParcel, cTipo, cCliente, cLoja )
                        EndIf
                    Else
                        lRet := .F.
                        cXmlRet := STR0001 + "ComplementaryValueInternalId" //"Tag obrigatória não informada: "
                    Endif
                Case cTag == "InformedValue"
                    If ! Empty( cVarAux )
                        nValInfo := Val( cVarAux )
                    Endif
            EndCase

            If !lRet
                Exit
            Endif

        Next nY
	
        If lRet
            //Se não houver FKD relacionada ao código do VA em questão, 
            //só envia para a execauto se o valor do VA for diferente de zero
            If lTemFKD .AND. !EMPTY(nValInfo)
                aAdd( aVAs, { cChaveFK7, cCodVA, nValInfo } )
            EndIf
        Else
            Exit
        Endif
	Next nX
	
	aSize ( aLstVA, 0 )
	aLstVA := Nil
	aSize ( aAuxList, 0 )
	aAuxList := Nil
Return lRet

/*/{Protheus.doc} FindFKD
Função Responsavel por pesquisar na tabela FKD o VA para saber se existe.
@type function
@author jose.aribeiro
@since 06/10/2016
@version 1.0
@param cCod, caracter, Codigo do Valor Acessorio para pesquisar no VA
@Return lRet, logico , .T. para encontrado e .F. para nao encontrado
/*/
Static Function FindFKD(cCod, cPrefTit, cNumTit, cParcel, cTipo, cCliente, cLoja)
	Local lRet := .T.
	Local cChaveFK7 := ""
	Local cChaveTit := ""
	Local aAreaFKD := FKD->( GetArea() )
	
	cChaveTit := FWxFilial("SE1") + "|" + cPrefTit + "|" + cNumTit + "|" + cParcel + "|" + cTipo + "|" +  cCliente + "|" + cLoja
	cChaveFK7 := FINGRVFK7( "SE1", cChaveTit )

	FKD->( DbSetOrder( 1 ) )
	If ( !FKD->( DbSeek( FWxFilial("FKD") + cCod + cChaveFK7 ) ) )	
		lRet := .F.
	EndIf
	
	RestArea( aAreaFKD )
	
	aSize ( aAreaFKD, 0 )
	aAreaFKD := Nil
Return lRet

/*/{Protheus.doc} TrataIdVA
Função para tratar o InternalId dos valores acessórios da baixa

@param cVAExt, ExternalId do valor acessório.
@param cMarca, Marca que está enviando a mensagem.
@param cCodVA, Código do valor acessório encontrado no de/para. Passado por referência.
@param cXMLRet, Variável com a mensagem de resposta. Passada por referência.
@return lRet, Indica se de/para foi encontrado com sucesso.

@author Pedro Alencar
@since 01/09/2016
@version 12
/*/
Static Function TrataIdVA( cVAExt, cMarca, cCodVA, cXmlRet )
	Local lRet := .T.
	Local aRetVA := {}
	Default cVAExt := ""
	Default cMarca := ""
	Default cCodVA := ""
	Default cXmlRet := ""
	
	aRetVA := F035GetInt( cVAExt, cMarca )
	
	If aRetVA[1]
		cCodVA := aRetVA[2][3]
	Else
		lRet := .F.
		cXmlRet := STR0010 + cVAExt //"O valor acessório informado para a baixa não foi encontrado no de/para Protheus: "
	Endif
	
	aSize ( aRetVA, 0 )
	aRetVA := Nil
Return lRet

/*/{Protheus.doc} TrataOther
Função para tratar a lista de outros valores informada no XML

@param oXML, Objeto que trata o XML recebido.
@param cPathAux, Caminho do nó da lista de outros valores no XML.
@param aOutrosVal, Vetor no qual serão retornados os dados de cada valor. Passado por referência.
@param cXMLRet, Variável com a mensagem de resposta. Passada por referência.
@return lRet, Indica se a leitura dos VAs foi realizada com sucesso.

@author Pedro Alencar
@since 01/09/2016
@version 12
/*/
Static Function TrataOther( oXML, cPathAux, aOutrosVal, cXmlRet )
	Local lRet			:= .T.
	Local aLstOther 	:= {}
	Local nX			:= 0
	Local cTag			:= ""
	Local cVarAux		:= ""
	Local nJuros		:= 0
	Local nDesconto 	:= 0
	Local nAbat			:= 0
	Local nDespesa		:= 0
	Local nMulta 		:= 0
	Default cPathAux	:= ""
	Default aOutrosVal	:= {}
	Default cXmlRet		:= ""
	
	//Loop na tag de lista de valores acessórios
	aLstOther := oXml:XPathGetChildArray( cPathAux )
	For nX := 1 to Len( aLstOther )
										
		//Pega o nome da tag e o valor da mesma
		cTag := AllTrim( aLstOther[nX][1] )
		cVarAux := aLstOther[nX][3]
		
		//Verifica qual é a tag e faz os tratamentos necessários para guardar o valor de cada uma delas
		Do Case
			
			Case cTag == "InterestValue" 
				
				If ! Empty( cVarAux )
					nJuros := Val( cVarAux )
				Endif
				
			Case cTag == "DiscountValue"
				
				If ! Empty( cVarAux )
					nDesconto := Val( cVarAux )
				Endif
				
			Case cTag == "AbatementValue" 
		
				If ! Empty( cVarAux )
					nAbat := Val( cVarAux )
				Endif
		
			Case cTag == "ExpensesValue"
			
				If ! Empty( cVarAux )
					nDespesa := Val( cVarAux )
				Endif
			
			Case cTag == "FineValue"	
				
				If ! Empty( cVarAux )
					nMulta := Val( cVarAux )
				Endif
				
		End Case			
		
	Next nX
	
	aAdd( aOutrosVal, nJuros )
	aAdd( aOutrosVal, nDesconto )
	aAdd( aOutrosVal, nAbat )
	aAdd( aOutrosVal, nDespesa )
	aAdd( aOutrosVal, nMulta )
	
	aSize ( aLstOther, 0 )
	aLstOther := Nil
Return lRet

/*/{Protheus.doc} IniTamSX3
Inicia as variáveis estáticas com os tamanhos dos campos do título

@author Pedro Alencar
@since 01/09/2016
@version 12
/*/
Static Function IniTamSX3()
	__nTamFil		:= TamSX3("E1_FILIAL")[1]
	__nTamPref		:= TamSX3("E1_PREFIXO")[1]
	__nTamNum		:= TamSX3("E1_NUM")[1]
	__nTamPar		:= TamSX3("E1_PARCELA")[1]
	__nTamTipo		:= TamSX3("E1_TIPO")[1]
	__nTamCli		:= TamSX3("E1_CLIENTE")[1]
	__nTamLoja		:= TamSX3("E1_LOJA")[1]
	__nTamSeq		:= TamSX3("E5_SEQ")[1]
	__nTamMot		:= TamSX3("FK1_MOTBX")[1]	
	__cVersaoCust	:= MsgUVer('CTBA030', 'COSTCENTER')
Return Nil

/*/{Protheus.doc} TrataEvEz
Trata o reteio de natureza com centro de custo 
@type  Static Function

@param oXml, Object, XML
@param cMarca, Character, Referência da integração
@param cPathAux, Character, Path do rateio
@param aRatEvEz, Array, Array para retorno do rateio
@param cXmlRet, Character, variável para retorno de erros
@return lRet, Logical, retorno lógico

@author renato.ito
@since 19/06/2019
@version 12

/*/
Static Function TrataEvEz(oXml As Object, cMarca As Character, cPathAux As Character, aRatEvEz As Array, cXmlRet As Character) As Logical
	Local lRet		As Logical
	Local aRetXXF	As Array
	Local aRataux	As Array
	Local aRatEz	As Array
	Local aRat		As Array
	Local aLstCost	As Array
	Local nX		As Numeric
	Local nY		As Numeric
	Local nZ		As Numeric
	Local nVlRatEv	As Numeric
	Local nPercEv	As Numeric	
	Local cTag		As Character
	Local cVarAux	As Character
	Local cNatureza	As Character

	lRet		:= .T.
	aRetXXF		:= {}
	aRataux		:= {}
	aRatEz		:= {}
	aRat		:= {}
	aLstCost	:= {}
	nX			:= 0
	nY			:= 0
	nZ			:= 0
	nVlRatEv	:= 0
	nPercEv		:= 0
	cTag		:= ""
	cVarAux		:= ""
	cNatureza	:= ""

	//Loop na tag de lista do rateio da natureza ListOfFinancialNatureApportionment
	aLstEv := oXml:XPathGetChildArray( cPathAux )
	For nX := 1 to Len( aLstEv )//FinancialNatureApportionment
		
		cVarAux 	:= ""
		aRetXXF 	:= {}
		nVlRatEv	:= 0
		nPercEv		:= 0
		aRatEz		:= {}
		aRat		:= {}

		If !Empty(cVarAux := oXml:XPathGetNodeValue(aLstEv[nX][2]+"/FinancialNatureInternalId"))
			aRetXXF := F10GetInt(cVarAux, cMarca)
			If aRetXXF[1]
				cNatureza := aRetXXF[2][3]
			Else
				lRet := .F.
				cXmlRet += aRetXXF[2]
			EndIf
		Else
			lRet := .F.
			cXmlRet += STR0001 + "FinancialNatureInternalId" //"Tag obrigatória não informada: "
		EndIf

		If !Empty(cVarAux := oXml:XPathGetNodeValue(aLstEv[nX][2]+"/Value"))
			nVlRatEv := VAL(cVarAux)
		Else
			lRet := .F.
			cXmlRet += STR0001 + "Value" //"Tag obrigatória não informada: "
		EndIf

		If !Empty(cVarAux := oXml:XPathGetNodeValue(aLstEv[nX][2]+"/Percentage"))
			nPercEv := VAL(cVarAux)
		EndIf

		aLstCost := oXml:XPathGetChildArray(aLstEv[nX][2]+"/ListOfCostCenterApportionment")
		
		For nZ := 1 to Len(aLstCost)	//Loop na tag de lista do rateio da centro de custo ListOfCostCenterApportionment
			aLstEz := oXml:XPathGetChildArray(aLstCost[nZ][2])
			aRatAux := {}
			For nY := 1 to Len( aLstEz )//  
				//Pega o nome da tag e o valor da mesma
				cTag := AllTrim( aLstEz[nY][1] )
				cVarAux := aLstEz[nY][3]
				aRetXXF		:={}

				Do Case
					Case cTag == "CostCenterInternalId" //Centro de custo
						aRetXXF := IntCusInt(cVarAux, cMarca, __cVersaoCust)
						If aRetXXF[1]
							If __cVersaoCust = '1'
								aadd( aRataux ,{"EZ_CCUSTO", aRetXXF[2][2], Nil })
							Else
								aadd( aRataux ,{"EZ_CCUSTO", aRetXXF[2][3], Nil })
							Endif
						Else
							lRet := .F.
							cXmlRet += aRetXXF[2] //"Centro de Custo não encontrado no de/para!"
						Endif

					Case cTag == "AccountingItemInternalId" //Item Contábil
						aRetXXF := C040AGetInt(cVarAux, cMarca)
						If aRetXXF[1]
							aadd( aRataux ,{"EZ_ITEMCTA", aRetXXF[2][3]	,Nil })
						Else
							lRet := .F.
							cXmlRet += aRetXXF[2]
						EndIf

					Case cTag == "ClassValueInternalId" //Classe de Valor
						aRetXXF := C060GetInt(cVarAux, cMarca)
						If aRetXXF[1]
							aadd( aRataux ,{"EZ_CLVL", aRetXXF[2][3], Nil })
						Else
							lRet := .F.
							cXmlRet += aRetXXF[2]
						EndIf

					Case cTag == "GenericEntityInternalId" ////Entidade adicional (05, 06, 07, 08 ou 09) - Código da conta (Copia do FINI040) ainda não está gravando no MultNatB
						aRetXXF := IntGerInt(cVarAux, cMarca, "1.000")
						If aRetXXF[1]
							aAdd( aAuxSEZ, { "EZ_EC05DB", aRetXXF[2][4], Nil } )
						Else
							lRet := .F.
							cXmlRet += aRetXXF[2]
						EndIf

					Case cTag == "Value"
						aadd( aRataux ,{"EZ_VALOR", VAL(cVarAux), Nil })
					
					Case cTag == "Percentage"
						aadd( aRataux ,{"EZ_PERC", VAL(cVarAux), Nil })

				End Case
			Next
			aadd(aRatEz,aRatAux)
		Next
		
		aadd( aRat ,{"EV_NATUREZ" , cNatureza , Nil })
		aadd( aRat ,{"EV_VALOR" , nVlRatEv, Nil })
		aadd( aRat ,{"EV_PERC" , nPercEv, Nil })
		if Len( aRatEz ) >0 
			aadd( aRat ,{"EV_RATEICC" , "1", Nil })
			aadd( aRat,{"AUTRATEICC" , aRatEz, Nil })
		Else
			aadd( aRat ,{"EV_RATEICC" , "2", Nil })
		EndIf
		aAdd(aRatEvEz,aRat)
	Next

Return lRet

/*/{Protheus.doc} MsgUVer
	Função que verifica a versão de uma mensagem única cadastrada no adapter EAI.

	Essa função deverá ser EXCLUÍDA e substituída pela função FwAdapterVersion()
	após sua publicação na Lib de 2019.

	@param cRotina		Rotina que possui a IntegDef da Mensagem Unica
	@param cMensagem	Nome da Mensagem única a ser pesquisada

	@author		Felipe Raposo
	@version	P12
	@since		23/11/2018
	@return		xVersion - versão da mensagem única cadastrada. Se não encontrar, retorna nulo.
/*/
Static Function MsgUVer(cRotina, cMensagem)

Local aArea    := GetArea()
Local xVersion

xVersion := FwAdapterVersion(cRotina, cMensagem)

RestArea(aArea)

Return xVersion
