#Include 'Protheus.ch'

#Include "PROTHEUS.ch"
#Include "FWMVCDEF.CH"
#Include "FWADAPTEREAI.CH"
#include 'CTBISAL.CH'

Static lCTBA030 := .F.
Static lCTBA040 := .F.
Static lCTBA060 := .F.
Static lCTBA800a := .F.
Static lCTBA140 := .F.
Static lCTBA020 := .F.
Static cMessage := 'AccountingBalance' //Nome da Mensagem �nica

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBISAL
Mensagem unica de exportacao saldos cont�beis - ACCOUNTINGBALANCE

@param   cXml          Vari�vel com conte�do XML para envio/recebimento.
@param   cTypeTrans    Tipo de transa��o (Envio / Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Vers�o da mensagem.
@param   cTransac      Nome da transa��o.

@return  aRet   - (array)   Cont�m o resultado da execu��o e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execu��o da fun��o
       aRet[2] - (caracter) Mensagem XML para envio

@author Alvaro Camillo Neto
@since 18/09/2015
@version MP12
/*/
//-------------------------------------------------------------------
Function CTBISAL(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
	Local cXmlRet				:= ''
	Local lRet					:= .T.
	Local aRetEAI               := {} //Retorno EAI

	lCTBA030 		:= FWHasEAI("CTBA030",.T.,,.T.)
	lCTBA040 		:= FWHasEAI("CTBA040",,,.T.)
	lCTBA060 		:= FWHasEAI("CTBA060",,,.T.)
	lCTBA800a 		:= FWHasEAI("CTBA800A",,,.T.)
	lCTBA140		:= FWHasEAI("CTBA140",,,.T.)
	lCTBA020 		:= FWHasEAI("CTBA020",,,.T.)

	If cTypeTrans == TRANS_RECEIVE
		If cTypeMsg == EAI_MESSAGE_BUSINESS
			//Verificando a vers�o da Mensagem
			If cVersion = "1."
				aRetEAI := v1000(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
			ElseIf cVersion = "2."
				aRetEAI := v2000(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
			Else
				lRet    := .F.
				cXmlRet := STR0010 //"A vers�o da mensagem informada n�o foi implementada!"
				aRetEAI := {lRet, cXmlRet, cMessage}
			EndIf
		ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE
			//Verificando a vers�o da Mensagem
			If cVersion = "1."
				aRetEAI := v1000(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
			ElseIf cVersion = "2."
				aRetEAI := v2000(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
			Else
				lRet    := .F.
				cXmlRet := STR0010 //"A vers�o da mensagem informada n�o foi implementada!"
				aRetEAI := {lRet, cXmlRet, cMessage}
			EndIf
		ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
			lRet    := .T.
			cXMLRet := '1.000|2.000'
			aRetEAI := {lRet, cXmlRet, cMessage}
		EndIf
	EndIf

Return aRetEAI

/*/{Protheus.doc} v1000
Implementa��o do adapter EAI, vers�o 1.x

@author  Alison Kaique
@version P12
@since   Sep/2018
/*/
Static Function v1000(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
	Local cXmlRet				:= ''
	Local lRet					:= .T.
	Local cErroXml		    	:= ""
	Local cWarnXml		    	:= ""
	Local aAutoCab		    	:= {}
	Local aErroAuto		    	:= {}
	Local oXmlCtbISal			:= ''
	Local cAuxDePara 			:= ""
	Local cEntGer				:= SuperGetMV("MV_CTBCGER",.F.,"")
	Local cMarca 				:= ""
	Local dDataIni 			    := STOD("")
	Local dDataFim 		    	:= STOD("")
	Local cSaldo 				:= "1"
	Local cMoeda 				:= "01"
	Local cConta				:= Nil
	Local cCusto				:= Nil
	Local cItem 				:= Nil
	Local cClasse 		     	:= Nil
	Local cContaGer 			:= Nil
	Local nSldAtu				:= 0
	Local nSldAtuDeb			:= 0
	Local nSldAtuCred			:= 0
	Local nSldAnt				:= 0
	Local nSldAntDeb			:= 0
	Local nSldAntCred			:= 0
	Local nMov					:= 0
	Local nMovDeb				:= 0
	Local nMovCred			    := 0
	Local aRet					:= {}
	Local cPlano				:= ""
	Local aRetEAI               := {} //Retorno EAI

	dbSelectArea("CT0")
	CT0->(dbSetOrder(1)) //CT0_FILIAL+CT0_ID
	If !Empty(cEntGer)
		If !CT0->(dbSeek(xFilial("CT0") + cEntGer))
			lRet    := .F.
			cXmlRet := STR0002 // "A entidade selecionada no parametro MV_CTBCGER n�o est� cadastrada, verificar cadastro de entidades adicionais"
			aRetEAI := {lRet, cXmlRet, cMessage}
		Else
			cPlano := cEntGer
		EndIf
	EndIf

	If lRet
		// verifica��o do tipo de transa��o recebimento ou envio
		// trata o envio
		If  cTypeTrans == TRANS_RECEIVE
			If (cTypeMsg == EAI_MESSAGE_WHOIS )
				cXmlRet := '1.000'
			ElseIF ( cTypeMsg == EAI_MESSAGE_BUSINESS )
				If FindFunction("CFGA070INT")
					oXmlCtbISal := XmlParser(cXml, "_", @cErroXml, @cWarnXml)
					If oXmlCtbISal <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
						If lRet

							If XmlChildEx( oXmlCtbISal:_TOTVSMessage:_MessageInformation:_Product, '_NAME') <> Nil
								cMarca :=  Alltrim(oXmlCtbISal:_TOTVSMessage:_MessageInformation:_Product:_Name:Text)
							EndIf

							If XmlChildEx(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_INITIALDATE') != Nil
								dDataIni := StoD(STRTran(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_InitialDate:Text,'-'))
							Endif

							If XmlChildEx(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_FINALDATE') != Nil
								dDataFim := StoD(STRtran(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_FinalDate:Text,'-'))
							Endif

							If XmlChildEx(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_BALANCETYPE') != Nil
								cSaldo := Alltrim(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_BalanceType:Text)
							Else
								cSaldo := '1'
							Endif

							//Moeda da Linha do Lan�amento Cont�bil

							If XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_CURRENCYINTERNALID') <> Nil
								cValExt := oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_CurrencyInternalID:Text
								//Pega o valor interno da moeda recebida
								aMoedaInt := IntMoeInt( cValExt, cMarca )
								If aMoedaInt[1]
									cValInt := aMoedaInt[2][3]
									cMoeda := cValInt
								Endif
							ElseIf XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_CURRENCYCODE') <> Nil
								cMoeda := Alltrim(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_CurrencyCode:Text)
							EndIf

							cMoeda := IIF(!Empty(cMoeda),cMoeda,"01")

							//Conta Cont�bil
							If XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_ACCOUNTANTACCOUNTINTERNALID') <> Nil
								cValExt	:= oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantAccountInternalId:Text
								cValInt	:= Alltrim(GetCtint(cValExt, cMarca))
								cConta		:= Alltrim(cValInt)

								If Empty(cValInt) .Or. !(ValidEnt("CT1",cConta))
									cXmlRet+='<Message type="ERROR" code="c2">'+ STR0009 + cValExt + STR0005 +'</Message>'//"Plano de contas "Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
									lRet:=.F.
								EndIf

							ElseIf XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_ACCOUNTANTACCOUNTCODE') <> Nil
								cConta	:= Alltrim(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantAccountCode:Text)

								If !(ValidEnt("CT1",cConta))
									cXmlRet+='<Message type="ERROR" code="c2">'+ STR0009 + cConta + STR0005 +'</Message>'//"Plano de contas "Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
									lRet:=.F.
								EndIf

							EndIf


							//Tratamento dos centros de custos

							//InternalId do Centro de Custo a D�bito da Linha do Lan�amento Cont�bil
							If lRet
								If XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_COSTCENTERINTERNALID') <> Nil
									If !Empty(AllTrim(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_CostCenterInternalId:Text))
										cValExt := oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_CostCenterInternalId:Text
										aResult := IntCusInt(cValExt,cMarca)
										if aResult[1]
											cCusto := aResult[2][3]
										Else
											cXmlRet+='<Message type="ERROR" code="c2">'+ STR0004 + cValExt + STR0005 +'</Message>' //"Centro de Custo "  cValExt  " n�o existe"
											lRet:=.F.
										EndIf

									Endif
								ElseIf XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_COSTCENTERCODE') <> Nil .And. lRet
									//Centro de Custo a D�bito da Linha do Lan�amento Cont�bil
									cCusto	:= AllTrim(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_CostCenterCode:Text)

									If !(ValidEnt("CTT",cCusto))
										cXmlRet+='<Message type="ERROR" code="c2">'+ STR0004 + cCusto + STR0005 +'</Message>'//Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
										lRet:=.F.
									EndIf
								EndIf
							EndIf

							//Item cont�bil
							If lRet
								If XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_ACCOUNTANTITEMINTERNALID') <> Nil .And.;
										!Empty(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantItemInternalId:Text)
									cValExt := oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantItemInternalId:Text
									aResult := C040AGetInt(cValExt, cMarca)
									if aResult[1]
										cItem := aResult[2][3]
									Else
										cXmlRet+='<Message type="ERROR" code="c2">'+ STR0006 + cValExt + STR0005 +'</Message>'//Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
										lRet:=.F.
									EndIf

								ElseIf XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_ACCOUNTANTITEMCODE') <> Nil .And. lRet
									cItem := oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantItemCode:Text

									If !(ValidEnt("CTD",cItem))
										cXmlRet+='<Message type="ERROR" code="c2">'+ STR0006 + cItem + STR0005 +'</Message>'//Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
										lRet:=.F.
									EndIf
								EndIf
							EndIf
							//Classe de valor a d�bito
							If lRet
								If XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_CLASSVALUEINTERNALID') <> Nil
									cValExt := oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_ClassValueInternalId:Text
									aRet := C060GetInt(cValExt, cMarca)
									If aRet[1]
										cClasse := aRet[2][3]
									Else
										cXmlRet+='<Message type="ERROR" code="c2">'+ STR0007 + cValExt + STR0005 +'</Message>'//Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
										lRet:=.F.
									EndIf

								ElseIf XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_CLASSVALUECODE') <> Nil .And. lRet
									cClasse := oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_ClassValueCode:Text

									If !(ValidEnt("CTH",cClasse))
										cXmlRet+='<Message type="ERROR" code="c2">'+ STR0007 + cClasse + STR0005 +'</Message>'//Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
										lRet:=.F.
									EndIf

								EndIf
							EndIf
							If lRet
								//Conta Gerencial
								If XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_MANAGERIALACCOUNTINGENTITYINTERNALID') <> Nil
									If !Empty(cPlano)
										cValExt := oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_ManagerialAccountingEntityInternalId:Text
										aRet := IntGerInt(cValExt, cMarca)
										If aRet[1]
											cContaGer := aRet[2][4]
										Else
											cXmlRet+='<Message type="ERROR" code="c2">'+ STR0008 + cValExt + STR0005 +'</Message>'//Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
											lRet:=.F.

										EndIf
									Else
										cXmlRet+='<Message type="ERROR" code="c2">'+ STR0002 +'</Message>'//"A entidade selecionada no parametro MV_CTBCGER n�o est� cadastrada, verificar cadastro de entidades adicionais"
										lRet:=.F.
									EndIf

								ElseIf XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_MANAGERIALACCOUNTINGENTITYCODE') <> Nil .And. lRet
									If !Empty(cPlano)
										cContaGer := oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_ManagerialAccountingEntityCode:Text

										If !(ValidEnt("CV0",cEntGer+cContaGer))
											cXmlRet+='<Message type="ERROR" code="c2">'+ STR0008 + cContaGer + STR0005 +'</Message>'//Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
											lRet:=.F.
										EndIf
									Else
										cXmlRet+='<Message type="ERROR" code="c2">'+ STR0002 +'</Message>'//"A entidade selecionada no parametro MV_CTBCGER n�o est� cadastrada, verificar cadastro de entidades adicionais"
										lRet:=.F.
									EndIf
								EndIf
							EndIf
							If lRet
								aRet := SldCtbEAI(dDataIni,dDataFim,cSaldo,cMoeda,cConta,cCusto,cItem,cClasse,cEntGer,cContaGer)

								If aRet[1]

									nSldAtu			:= aRet[2][1]
									nSldAtuDeb			:= aRet[2][2]
									nSldAtuCred		:= aRet[2][3]
									nSldAnt			:= aRet[2][4]
									nSldAntDeb			:= aRet[2][5]
									nSldAntCred		:= aRet[2][6]
									nMov				:= aRet[2][7]
									nMovDeb			:= aRet[2][8]
									nMovCred			:= aRet[2][9]

									cXmlRet+='<CurrentBalance>'+cValToChar(nSldAtu)+'</CurrentBalance>'
									cXmlRet+='<CurrentDebtBalance>'+cValToChar(nSldAtuDeb)+'</CurrentDebtBalance>'
									cXmlRet+='<CurrentCreditBalance>'+cValToChar(nSldAtuCred)+'</CurrentCreditBalance>'
									cXmlRet+='<PreviousBalance>'+cValToChar(nSldAnt)+'</PreviousBalance>'
									cXmlRet+='<PreviousDebtBalance>'+cValToChar(nSldAntDeb)+'</PreviousDebtBalance>'
									cXmlRet+='<PreviousCreditBalance>'+cValToChar(nSldAntCred)+'</PreviousCreditBalance>'
									cXmlRet+='<PeriodMovement>'+cValToChar(nMov)+'</PeriodMovement>'
									cXmlRet+='<PeriodDebtMovement>'+cValToChar(nMovDeb)+'</PeriodDebtMovement>'
									cXmlRet+='<PeriodCreditMovement>'+cValToChar(nMovCred)+'</PeriodCreditMovement>'
								EndIf
							EndIf

						Endif
					Else
						cXmlRet+='<Message type="ERROR" code="c2">'+STR0003+'</Message>'//Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
						lRet:=.F.
					Endif
				Else
					cXmlRet+='<Message type="ERROR" code="c2">'+STR0001+'</Message>'//"Para o funcionamento do EAI � necess�rio a �ltima atualiza��o da lib Protheus. Acione o Suporte Totvs."
					lRet:=.F.
				Endif
			Endif
		EndIf

		cXmlRet:=EncodeUTF8(cXmlRet)

		aRetEAI := { lRet, cXmlRet, cMessage }
	EndIf

Return aRetEAI

/*/{Protheus.doc} v2000
Implementa��o do adapter EAI, vers�o 2.x

@author  Alison Kaique
@version P12
@since   Sep/2018
/*/
Static Function v2000(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
	Local cXmlRet				:= ''
	Local lRet					:= .T.
	Local cErroXml		    	:= ""
	Local cWarnXml		    	:= ""
	Local aAutoCab		    	:= {}
	Local aErroAuto		    	:= {}
	Local oXmlCtbISal			:= ''
	Local cAuxDePara 			:= ""
	Local cEntGer				:= SuperGetMV("MV_CTBCGER",.F.,"")
	Local cMarca 				:= ""
	Local dDataIni 			    := STOD("")
	Local dDataFim 		    	:= STOD("")
	Local cSaldo 				:= "1"
	Local cMoeda 				:= "01"
	Local cConta				:= Nil
	Local cCusto				:= Nil
	Local cItem 				:= Nil
	Local cClasse 		     	:= Nil
	Local cContaGer 			:= Nil
	Local nSldAtu				:= 0
	Local nSldAtuDeb			:= 0
	Local nSldAtuCred			:= 0
	Local nSldAnt				:= 0
	Local nSldAntDeb			:= 0
	Local nSldAntCred			:= 0
	Local nMov					:= 0
	Local nMovDeb				:= 0
	Local nMovCred			    := 0
	Local aRet					:= {}
	Local cPlano				:= ""
	Local aEntCtb               := CarrEntCtb() //array de verifica��o das entidades contabeis adicionais, com 5 posicoes
	Local nY                    := 0 //Controle de FOR
	Local aRetEAI               := {} //Retorno EAI
	Local aEntidades            := {} //Entidades Adicionais Contidas no XML

	If lRet
		// verifica��o do tipo de transa��o recebimento ou envio
		// trata o envio
		If  cTypeTrans == TRANS_RECEIVE
			If (cTypeMsg == EAI_MESSAGE_WHOIS )
				cXmlRet := '2.000'
			ElseIF ( cTypeMsg == EAI_MESSAGE_BUSINESS )
				If FindFunction("CFGA070INT")
					oXmlCtbISal := XmlParser(cXml, "_", @cErroXml, @cWarnXml)
					If oXmlCtbISal <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
						If lRet

							If XmlChildEx( oXmlCtbISal:_TOTVSMessage:_MessageInformation:_Product, '_NAME') <> Nil
								cMarca :=  Alltrim(oXmlCtbISal:_TOTVSMessage:_MessageInformation:_Product:_Name:Text)
							EndIf

							If XmlChildEx(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_INITIALDATE') != Nil
								dDataIni := StoD(STRTran(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_InitialDate:Text,'-'))
							Endif

							If XmlChildEx(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_FINALDATE') != Nil
								dDataFim := StoD(STRtran(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_FinalDate:Text,'-'))
							Endif

							If XmlChildEx(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_BALANCETYPE') != Nil
								cSaldo := Alltrim(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_BalanceType:Text)
							Else
								cSaldo := '1'
							Endif

							//Moeda da Linha do Lan�amento Cont�bil

							If XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_CURRENCYINTERNALID') <> Nil
								cValExt := oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_CurrencyInternalID:Text
								//Pega o valor interno da moeda recebida
								aMoedaInt := IntMoeInt( cValExt, cMarca )
								If aMoedaInt[1]
									cValInt := aMoedaInt[2][3]
									cMoeda := cValInt
								Endif
							ElseIf XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_CURRENCYCODE') <> Nil
								cMoeda := Alltrim(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_CurrencyCode:Text)
							EndIf

							cMoeda := IIF(!Empty(cMoeda),cMoeda,"01")

							//Conta Cont�bil
							If XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_ACCOUNTANTACCOUNTINTERNALID') <> Nil
								cValExt	:= oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantAccountInternalId:Text
								cValInt	:= Alltrim(GetCtint(cValExt, cMarca))
								cConta		:= Alltrim(cValInt)

								If Empty(cValInt) .Or. !(ValidEnt("CT1",cConta))
									cXmlRet+='<Message type="ERROR" code="c2">'+ STR0009 + cValExt + STR0005 +'</Message>'//"Plano de contas "Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
									lRet:=.F.
								EndIf

							ElseIf XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_ACCOUNTANTACCOUNTCODE') <> Nil
								cConta	:= Alltrim(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantAccountCode:Text)

								If !(ValidEnt("CT1",cConta))
									cXmlRet+='<Message type="ERROR" code="c2">'+ STR0009 + cConta + STR0005 +'</Message>'//"Plano de contas "Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
									lRet:=.F.
								EndIf

							EndIf


							//Tratamento dos centros de custos

							//InternalId do Centro de Custo a D�bito da Linha do Lan�amento Cont�bil
							If lRet
								If XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_COSTCENTERINTERNALID') <> Nil
									If !Empty(AllTrim(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_CostCenterInternalId:Text))
										cValExt := oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_CostCenterInternalId:Text
										aResult := IntCusInt(cValExt,cMarca)
										if aResult[1]
											cCusto := aResult[2][3]
										Else
											cXmlRet+='<Message type="ERROR" code="c2">'+ STR0004 + cValExt + STR0005 +'</Message>' //"Centro de Custo "  cValExt  " n�o existe"
											lRet:=.F.
										EndIf

									Endif
								ElseIf XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_COSTCENTERCODE') <> Nil .And. lRet
									//Centro de Custo a D�bito da Linha do Lan�amento Cont�bil
									cCusto	:= AllTrim(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_CostCenterCode:Text)

									If !(ValidEnt("CTT",cCusto))
										cXmlRet+='<Message type="ERROR" code="c2">'+ STR0004 + cCusto + STR0005 +'</Message>'//Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
										lRet:=.F.
									EndIf
								EndIf
							EndIf

							//Item cont�bil
							If lRet
								If XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_ACCOUNTANTITEMINTERNALID') <> Nil .And.;
										!Empty(oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantItemInternalId:Text)
									cValExt := oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantItemInternalId:Text
									aResult := C040AGetInt(cValExt, cMarca)
									if aResult[1]
										cItem := aResult[2][3]
									Else
										cXmlRet+='<Message type="ERROR" code="c2">'+ STR0006 + cValExt + STR0005 +'</Message>'//Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
										lRet:=.F.
									EndIf

								ElseIf XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_ACCOUNTANTITEMCODE') <> Nil .And. lRet
									cItem := oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountantItemCode:Text

									If !(ValidEnt("CTD",cItem))
										cXmlRet+='<Message type="ERROR" code="c2">'+ STR0006 + cItem + STR0005 +'</Message>'//Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
										lRet:=.F.
									EndIf
								EndIf
							EndIf
							//Classe de valor a d�bito
							If lRet
								If XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_CLASSVALUEINTERNALID') <> Nil
									cValExt := oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_ClassValueInternalId:Text
									aRet := C060GetInt(cValExt, cMarca)
									If aRet[1]
										cClasse := aRet[2][3]
									Else
										cXmlRet+='<Message type="ERROR" code="c2">'+ STR0007 + cValExt + STR0005 +'</Message>'//Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
										lRet:=.F.
									EndIf

								ElseIf XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_CLASSVALUECODE') <> Nil .And. lRet
									cClasse := oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_ClassValueCode:Text

									If !(ValidEnt("CTH",cClasse))
										cXmlRet+='<Message type="ERROR" code="c2">'+ STR0007 + cClasse + STR0005 +'</Message>'//Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
										lRet:=.F.
									EndIf

								EndIf
							EndIf

							If lRet
								//Percorrendo Array de Entidades Cont�beis Adicionais
								For nY := 01 To Len(aEntCtb)
									//Verifica se a Entidade est� dispon�vel
									If (aEntCtb[nY, 01])
										//Verifica se a Tag Existe
										//Conta Gerencial
										If XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_MANAGERIALACCOUNTINGENTITY' + StrZero(nY + 04, 02) + 'INTERNALID') <> Nil
											cValExt := &("oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_ManagerialAccountingEntity" + StrZero(nY + 04, 02) + "InternalId:Text")
											aRet := IntGerInt(cValExt, cMarca)
											If aRet[1]
												cContaGer := aRet[2][4]
												AAdd(aEntidades, cContaGer)
											Else
												cXmlRet +='<Message type="ERROR" code="c2">' + STR0008 + StrZero(nY + 04, 02) + " " + cValExt + STR0005 +'</Message>'//Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
												lRet :=.F.
											EndIf
										ElseIf XmlChildEx( oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent,'_MANAGERIALACCOUNTINGENTITY' + StrZero(nY + 04, 02) + 'CODE') <> Nil .And. lRet
											cContaGer := &("oXmlCtbISal:_TotvsMessage:_BusinessMessage:_BusinessContent:_ManagerialAccountingEntity" + StrZero(nY + 04, 02) + "Code:Text")

											If !(ValidEnt("CV0", StrZero(nY + 04, 02) + cContaGer))
												cXmlRet +='<Message type="ERROR" code="c2">' + STR0008 + StrZero(nY + 04, 02) + " " + cContaGer + STR0005 +'</Message>'//Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
												lRet :=.F.
											Else
												AAdd(aEntidades, cContaGer)
											EndIf
										Else
											AAdd(aEntidades, "")
										EndIf
									Else
										AAdd(aEntidades, "")
									EndIf
								Next nY
							EndIf

							If lRet
								aRet := SldCtbEAI(dDataIni,dDataFim,cSaldo,cMoeda,cConta,cCusto,cItem,cClasse,cEntGer, /*cContaGer*/, aEntidades)

								If aRet[1]

									nSldAtu			:= aRet[2][1]
									nSldAtuDeb			:= aRet[2][2]
									nSldAtuCred		:= aRet[2][3]
									nSldAnt			:= aRet[2][4]
									nSldAntDeb			:= aRet[2][5]
									nSldAntCred		:= aRet[2][6]
									nMov				:= aRet[2][7]
									nMovDeb			:= aRet[2][8]
									nMovCred			:= aRet[2][9]

									cXmlRet+='<CurrentBalance>'+cValToChar(nSldAtu)+'</CurrentBalance>'
									cXmlRet+='<CurrentDebtBalance>'+cValToChar(nSldAtuDeb)+'</CurrentDebtBalance>'
									cXmlRet+='<CurrentCreditBalance>'+cValToChar(nSldAtuCred)+'</CurrentCreditBalance>'
									cXmlRet+='<PreviousBalance>'+cValToChar(nSldAnt)+'</PreviousBalance>'
									cXmlRet+='<PreviousDebtBalance>'+cValToChar(nSldAntDeb)+'</PreviousDebtBalance>'
									cXmlRet+='<PreviousCreditBalance>'+cValToChar(nSldAntCred)+'</PreviousCreditBalance>'
									cXmlRet+='<PeriodMovement>'+cValToChar(nMov)+'</PeriodMovement>'
									cXmlRet+='<PeriodDebtMovement>'+cValToChar(nMovDeb)+'</PeriodDebtMovement>'
									cXmlRet+='<PeriodCreditMovement>'+cValToChar(nMovCred)+'</PeriodCreditMovement>'
								EndIf
							EndIf

						Endif
					Else
						cXmlRet+='<Message type="ERROR" code="c2">'+STR0003+'</Message>'//Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
						lRet:=.F.
					Endif
				Else
					cXmlRet+='<Message type="ERROR" code="c2">'+STR0001+'</Message>'//"Para o funcionamento do EAI � necess�rio a �ltima atualiza��o da lib Protheus. Acione o Suporte Totvs."
					lRet:=.F.
				Endif
			Endif
		EndIf

		cXmlRet:=EncodeUTF8(cXmlRet)

		aRetEAI := { lRet, cXmlRet, cMessage }
	EndIf

Return aRetEAI

//-------------------------------------------------------------------
/*/{Protheus.doc} SldCtbEAI
Fun��o que retorna o saldo cont�bil segundo os par�metros

@return aRet[1] Indica se encontrou com sucesso
@return aRet[2] Saldos cont�beis

@author Alvaro Camillo Neto
@since 18/09/2015
@version MP12
/*/
//-------------------------------------------------------------------
Static Function SldCtbEAI(dDataIni,dDataFim,cSaldo,cMoeda,cConta,cCusto,cItem,cClasse,cEntGer,cContaGer, aEntidades)
	Local aRetAux		:= {}
	Local aRet			:= {}
	Local aEnt			:= {}
	Local lRet			:= .T.
	Local cArqBase	    := ""
	Local cIdent		:= ""
	Local cEnt5 		:= ""
	Local cEnt6 		:= ""
	Local cEnt7 		:= ""
	Local cEnt8 		:= ""
	Local cEnt9 		:= ""
	Local nSaldoAtu 	:= 0
	Local nAtuDeb		:= 0
	Local nAtuCrd		:= 0
	Local nSaldoAnt	    := 0
	Local nAntDeb		:= 0
	Local nAntCrd		:= 0
	Local nMovDeb 	    := 0
	Local nMovCred	    := 0
	Local nMov	 		:= 0
	Local nY            := 0 //Controle de FOR

	Default aEntidades := {}

	cSaldo := Alltrim(cSaldo)
	cMoeda := Alltrim(cMoeda)
	cEntGer := Alltrim(cEntGer)

	If cContaGer == Nil .AND. Len(aEntidades) == 0 //Entidades Cont�beis Principais
		If cConta != Nil .And. cCusto == Nil .And. cItem == Nil .And. cClasse == Nil  //Saldo por Conta
			cArqBase	:= "CT1"
		ElseIf cConta == Nil .And. cCusto != Nil .And. cItem == Nil .And. cClasse == Nil  //Saldo por Centro de Custo
			cArqBase	:= "CTU"
			cIdent		:= "CTT"
		ElseIf cConta == Nil .And. cCusto == Nil .And. cItem != Nil .And. cClasse == Nil  //Saldo por Item
			cArqBase	:= "CTU"
			cIdent		:= "CTD"
		ElseIf cConta == Nil .And. cCusto == Nil .And. cItem == Nil .And. cClasse != Nil //Saldo por Item
			cArqBase	:= "CTU"
			cIdent		:= "CTH"
		ElseIf cClasse != Nil
			cArqBase	:= "CTH"
		ElseIf cItem != Nil
			cArqBase	:= "CTD"
		ElseIf cCusto != Nil
			cArqBase	:= "CTT"
		EndIf

		aRetAux	:= SaldoCQPer(cArqBase,cConta,cCusto,cItem,cClasse,cIdent,dDataIni,dDataFim,cMoeda,cSaldo)
	ElseIf Len(aEntidades) > 0 //Todas Entidades Cont�beis Adicionais
		cConta		:= IIf(cConta == Nil , "", cConta)
		cCusto		:= IIf(cCusto == Nil , "", cCusto)
		cItem		:= IIf(cItem == Nil  , "", cItem)
		cClasse	    := IIf(cClasse == Nil, "", cClasse)

		//Entidades Cont�beis Principais
		AAdd(aEnt, cConta)
		AAdd(aEnt, cCusto)
		AAdd(aEnt, cItem)
		AAdd(aEnt, cClasse)

		//Entidades Cont�beis Adicionais
		For nY := 01 To Len(aEntidades)
			AAdd(aEnt, aEntidades[nY])
		Next nY

		// Fecha a transa��o para a cria��o do arquivo temporario dos saldos cont�beis.
		EndTran()
		aRetAux := CtbSldCubo(aEnt, aEnt, dDataIni, dDataFim, cMoeda, cSaldo,/*aSelFil*/,/*lMantemTmp*/,.T.)
	Else //Entidade Cont�bil Adicionail configurada no par�metro MV_CTBCGER

	cEnt5 := IIF(cEntGer == '05',cContaGer , '')
	cEnt6 := IIF(cEntGer == '06',cContaGer , '')
	cEnt7 := IIF(cEntGer == '07',cContaGer , '')
	cEnt8 := IIF(cEntGer == '08',cContaGer , '')
	cEnt9 := IIF(cEntGer == '09',cContaGer , '')

	cConta		:= IIF(cConta == Nil,"",cConta)
	cCusto		:= IIF(cCusto == Nil,"",cCusto)
	cItem		:= IIF(cItem == Nil,"",cItem)
	cClasse	:= IIF(cClasse == Nil,"",cClasse)

	aAdd(aEnt,cConta)

	aAdd(aEnt,cCusto)

	aAdd(aEnt,cItem)

	aAdd(aEnt,cClasse)

	If cEntGer >= "05"
		aAdd(aEnt,cEnt5)
	EndIf
	If cEntGer >= "06"
		aAdd(aEnt,cEnt6)
	EndIf
	If cEntGer >= "07"
		aAdd(aEnt,cEnt7)
	EndIf
	If cEntGer >= "08"
		aAdd(aEnt,cEnt8)
	EndIf
	If cEntGer >= "09"
		aAdd(aEnt,cEnt9)
	EndIf

	// Fecha a transa��o para a cria��o do arquivo temporario dos saldos cont�beis.
	EndTran()
	aRetAux := CtbSldCubo(aEnt,aEnt,dDataIni,dDataFim,cMoeda,cSaldo,/*aSelFil*/,/*lMantemTmp*/,.T.)
EndIf

If Len(aRetAux) >= 8

	nAtuDeb		:= aRetAux[4]
	nAtuCrd		:= aRetAux[5]
	nSaldoAtu		:= nAtuDeb - nAtuCrd
	nAntDeb		:= aRetAux[7]
	nAntCrd		:= aRetAux[8]
	nSaldoAnt		:= nAntDeb - nAntCrd

	nMovDeb 		:= nAtuDeb - nAntDeb
	nMovCred		:= nAtuCrd - nAntCrd
	nMov	 		:= nMovDeb - nMovCred

	aAdd(aRet,nSaldoAtu)
	aAdd(aRet,nAtuDeb)
	aAdd(aRet,nAtuCrd)
	aAdd(aRet,nSaldoAnt)
	aAdd(aRet,nAntDeb)
	aAdd(aRet,nAntCrd)
	aAdd(aRet,nMov)
	aAdd(aRet,nMovDeb)
	aAdd(aRet,nMovCred)
Else
	lRet := .F.
EndIf


Return {lRet,aRet }


//-------------------------------------------------------------------
/*/{Protheus.doc} GetCtInt
Busca o c�digo interno da conta cont�bil, com base no c�digo externo recebido

@param		cValExt Valor externo recebido na mensagem.
@param		cMarca	Produto que enviou a mensagem

@author	Pedro Alencar
@version	MP11.90
@since		17/03/14
@return	cRet C�digo da Conta interna
/*/										//   01          02         03
//-------------------------------------------------------------------
Static Function GetCtInt(cValExt, cMarca)
	Local cRet := ""
	Local aValInt := {}

	cRet := CFGA070INT( cMarca, "CT1" , "CT1_CONTA", cValExt )

	//Retira PIPES utilizados na InternalID
	If !Empty(cRet) .AND. "|" $ cRet
		aValInt := Separa(cRet,"|")

		If Len(aValInt) > 2
			cRet := aValInt[3]
		EndIf
	EndIf
Return cRet

User Function MyEAISLD()
	Local aRet := {}
	Local dDataIni := CTOD("01/02/15")
	Local dDataFim := CTOD("28/02/15")
	Local cSaldo   :="1"
	Local cMoeda   :="01"
	Local cConta   :="31006"
	Local cCusto:= "1006"
	Local cItem:= Nil
	Local cClasse:= Nil
	Local cEntGer:= Nil
	Local cContaGer:= Nil

	Local nSecIni := Seconds()

	ConOut("---------------------------------------------------------")

	Begin Transaction

		aRet := SldCtbEAI(dDataIni,dDataFim,cSaldo,cMoeda,cConta,cCusto,cItem,cClasse,cEntGer,cContaGer)

	End Transaction

	nSecFin := Seconds()

	ConOut(" Levou " + cValTochar(nSecFin-nSecIni) )

	VARINFO("aRet",aRet)

	ConOut("---------------------------------------------------------")
Return




//-------------------------------------------------------------------
/*/{Protheus.doc} ValidEnt(cAli,cEnt)
Valida entidades n�o encontradas

@param	cAli Alias
@param cEnt Rotina

@author Mayara Alves
@version P12
@since	29/09/15
/*/
//-------------------------------------------------------------------
Static Function ValidEnt(cAli,cEnt)
	Local lRet := .T.
	Local aArea := GetArea()


	Default cAli := ""
	Default cEnt := ""

	dbSelectArea(cAli)
	(cAli)->(dbSetOrder(1))

	If !(cAli)->(dbSeek(xFilial(cAli)+cEnt))
		lRet := .F.
	EndIf

	Restarea(aArea)
Return lRet

/**
	Carrega Array com informa��es dos Campos de Entidades Cont�beis
**/
Static Function CarrEntCtb()
	Local aRetEnt := {} //Array de Retorno
	Local nQtdEnt := 05 //Quantidade de Entidades Adicionais
	Local nE      := 0 //Controle de FOR
	Local cCpoDeb := '' //Campo Entidade D�bito
	Local cCpoCrd := '' //Campo Entidade Cr�dito

	//Verificando se campos existem
	DBSelectArea('CT2')
	For nE := 01 To nQtdEnt
		//Compondo Campos
		cCpoDeb := 'CT2_EC' + StrZero(nE + 04, 02) + 'DB' //D�bito
		cCpoCrd := 'CT2_EC' + StrZero(nE + 04, 02) + 'CR' //Cr�dito
		If (FieldPos(cCpoDeb) > 0 .AND. FieldPos(cCpoCrd) > 0)
			AAdd(aRetEnt, {.T., cCpoDeb, cCpoCrd})
		EndIf
	Next nE

Return aRetEnt