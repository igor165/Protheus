#include 'totvs.ch'
#include 'FWADAPTEREAI.CH'
#include 'PCOI100A.CH'

/*/{Protheus.doc} PCOI100A
Fun��o de integra��o com o adapter EAI para recebimento dos itens da planilha or�ament�ria
utilizando o conceito de mensagem unica.

Tal mensagem �nica difere-se da PCOI100 em rela��o a tratar a manuten��o da planilha
or�ament�ria (inclus�o, altera��o e exclus�o).

@param   cXml          Vari�vel com conte�do XML para envio/recebimento.
@param   cTypeTrans    Tipo de transa��o (Envio / Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Vers�o da mensagem.
@param   cTransac      Nome da transa��o.

@return  aRet   - (array)   Cont�m o resultado da execu��o e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execu��o da fun��o
       aRet[2] - (caracter) Mensagem XML para envio
       aRet[3] - (caracter) Nome da mensagem

@author	    Alison Lemes
@since		13/04/2018
@version	MP12.1.17
/*/
Function PCOI100A(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

	Local cXMLRet			:= ''
	Local cErroXml			:= ''
	Local cWarnXml			:= ''
	Local aErroAuto			:= {}
	Local nCountConta		:= 0
	Local nCountPeri		:= 0
	Local nCountItem		:= 0
	Local lRet				:= .T.
	Local cAK2ValInt		:= ''
	Local cAK2ValExt		:= ''
	Local aAK2ValInt		:= {}
	Local cMarca			:= ''
	Local aAK1Area			:= {}
	Local aAK2Area			:= {}
	Local aAK3Area			:= {}
	Local nOpcExec			:= 0
	Local cOperation		:= ''

	Local cVersao			:= ''
	Local cContaOrca		:= ''
	Local cVersaoPla		:= ''
	Local cOrcame			:= ''
	Local cPerBegin			:= ''
	Local cPerEnd			:= ''

	Local aListConta		:= {}
	Local aListItem			:= {}
	Local aListaPeri		:= {}

	Local cCCusto			:= ''
	Local cItemConta		:= ''
	Local cClasVal			:= ''
	Local cEnt05			:= ''
	Local cEnt06			:= ''
	Local cEnt07			:= ''
	Local cEnt08			:= ''
	Local cEnt09			:= ''
	Local cClaOrc			:= ''
	Local cDescri			:= ''
	Local cOperacao   		:= ''
	Local nMoeda			:= 0
	Local cUnidOrca			:= ''
	Local cDeleted			:= ''
	Local aAuxCab			:= {}
	Local aCab				:= {}
	Local aItens			:= {}
	Local aItensAux			:= {}
	Local aEstrut			:= {}
	Local aEstrutAux		:= {}
	Local aPeriodo			:= {}
	Local aPer				:= {}
	Local lGrav				:= .F.
	Local dPerAux
	Local nPos				:= 0
	Local cValPer			:= ''
	Local nBudgetItem		:= 0
	Local aBudgetItem		:= {}
	Local cMessage			:= 'BudgetWorksheet' // Nome da mensagem �nica.
	Local cErro				:= ''
	Local lNewVersion		:= .F. // Nova vers�o da planilha
	Local nE

	Private lMsErroAuto		:= .F.
	Private lMsHelpAuto		:= .T.
	Private lMostraErro		:= .F.
	Private lAutoErrNoFile	:= .T.
	Private oXmlPCO100		:= Nil

	aAK1Area := AK1->(GetArea())
	aAK2Area := AK2->(GetArea())
	aAK3Area := AK3->(GetArea())

	AK1->(DbSetOrder(1)) // AK1_FILIAL, AK1_CODIGO, AK1_VERSAO.
	AK2->(DbSetOrder(1)) // AK2_FILIAL, AK2_ORCAME, AK2_VERSAO, AK2_CO, AK2_PERIOD, AK2_ID.
	AK3->(DbSetOrder(1)) // AK3_FILIAL, AK3_ORCAME, AK3_VERSAO, AK3_CO.

	// Verifica��o do tipo de transa��o recebimento ou envio.
	If cTypeTrans == TRANS_SEND
		// N�o haver�, por enquanto, o envio de informa��es.

	ElseIf cTypeTrans == TRANS_RECEIVE
		If cTypeMsg == EAI_MESSAGE_RESPONSE
			// Nada a fazer.

		ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
			// Informa��o das vers�es compat�veis com a mensagem �nica.
			cXMLRet := '1.000'

		ElseIf cTypeMsg == EAI_MESSAGE_BUSINESS
			oXmlPCO100 := XmlParser(cXml, "_", @cErroXml, @cWarnXml)

			If oXmlPCO100 <> Nil .AND. Empty(cErroXml) .AND. Empty(cWarnXml)
				If XmlChildEx(oXmlPCO100:_TOTVSMessage, '_BUSINESSMESSAGE') <> Nil

					// Vers�o da mensagem �nica
					If XmlChildEx(oXmlPCO100:_TOTVSMessage:_MessageInformation, '_VERSION') <> Nil
						cVersao := StrTokArr(oXmlPCO100:_TOTVSMessage:_MessageInformation:_Version:Text, ".")[1]
					Else
						lRet := .F.
						cErro := STR0008 // "Vers�o da mensagem n�o informada!"
					EndIf

					// Recebe nome do produto (ex: RM ou PROTHEUS).
					If XmlChildEx(oXmlPCO100:_TOTVSMessage:_MessageInformation:_Product, '_NAME') <> Nil
						cMarca := oXmlPCO100:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
					EndIf

					// Recebe o c�digo externo da conta no cadastro.
					If XmlChildEx(oXmlPCO100:_TOTVSMessage:_BusinessMessage, '_BUSINESSEVENT') <> Nil

						If XmlChildEx(oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessEvent, '_IDENTIFICATION') <> Nil
							cAK2ValExt := oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_key:Text
						EndIf

						// Verifica��o da exist�ncia do conteudo da mensagem de neg�cio.
						If XmlChildEx(oXmlPCO100:_TOTVSMessage:_BusinessMessage, '_BUSINESSCONTENT') <> Nil
							// Planilha or�ament�ria.
							If XmlChildEx(oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_BUDGETWORKSHEET') <> Nil
								cOrcame := oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BudgetWorksheet:Text
								cOrcame := PadR(cOrcame, TamSX3('AK1_CODIGO')[01])

								// Verifica se a Planilha foi informada no XML
								If Empty(cOrcame)
									cErro += STR0009  // "Planilha inv�lida ou em branco"
								EndIf

								If Empty(cErro)
									// Verifica se ser� inclus�o, altera��o ou exclus�o de uma planilha
									cOperation := Upper(oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
									If cOperation == "UPSERT"
										If AK1->(DbSeek(FWxFilial('AK1') + cOrcame, .F.))
											nOpcExec := 4  // 4-Altera��o
										Else
											nOpcExec := 3  // 3-Inclus�o
										EndIf
									ElseIf cOperation == "DELETE"
										nOpcExec := 6  // 6-Exclus�o
									Else
										cErro += STR0024  // "XML inv�lido"
									EndIf
								EndIf

								If Empty(cErro)
									// Vers�o da planilha or�ament�ria.
									If XmlChildEx(oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent,'_WORKSHEETVERSION') <> Nil
										cVersaoPla := oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WorksheetVersion:Text
									EndIf

									If Empty(cVersaoPla)
										cErro += STR0010  // "Vers�o da planilha inv�lida ou em branco"
									EndIf

									// Verifica se � uma nova vers�o da planilha.
									If nOpcExec == 4  .and. !(AK1->(DbSeek(FWxFilial('AK1') + cOrcame + cVersaoPla, .F.)))
										lNewVersion := .T.
									EndIf
								EndIf

								If Empty(cErro)
									Begin Transaction

									aAuxCab := {}
									AAdd(aAuxCab, {"AK1_CODIGO", cOrcame,    nil})
									AAdd(aAuxCab, {"AK1_VERSAO", cVersaoPla, nil})

									// Descri��o da planilha or�ament�ria.
									If XmlChildEx(oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent,'_DESCRIPTION') <> Nil
										AAdd(aAuxCab, {"AK1_DESCRI", oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text, nil})
									EndIf

									// Tipo de per�odo.
									If XmlChildEx(oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent,'_PERIODTYPE') <> Nil
										AAdd(aAuxCab, {"AK1_TPPERI", oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PeriodType:Text, nil})
									EndIf

									// Inicio do per�odo.
									If XmlChildEx(oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent,'_PERIODBEGIN') <> Nil
										cPerBegin := oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PeriodBegin:Text
										If !Empty(cPerBegin)
											cPerBegin := getDate(cPerBegin)
										EndIf
										AAdd(aAuxCab, {"AK1_INIPER", stod(cPerBegin), nil})
									EndIf

									// Fim do per�odo.
									If XmlChildEx(oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent,'_PERIODEND') <> Nil
										cPerEnd := oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PeriodEnd:Text
										If !Empty(cPerEnd)
											cPerEnd := getDate(cPerEnd)
										EndIf
										AAdd(aAuxCab, {"AK1_FIMPER", stod(cPerEnd), nil})
									EndIf

									// Mensagem.
									If XmlChildEx(oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent,'_NOTE') <> Nil
										AAdd(aAuxCab, {"AK1_MEMO", oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Note:Text, nil})
									EndIf

									// Preparando Array para Inclus�o de Nova Planilha
									If (nOpcExec == 3 .or. nOpcExec == 6)
										lMsErroAuto := .F.
										MSExecAuto({|x, y, z, a, b, c| PCOA100(x, y, z, a, b, c)}, nOpcExec, /*cRevisa*/, /*lRev*/, /*lSim*/, aAuxCab, /*xAutoItens*/)
										If lMsErroAuto
											aErroAuto := GetAutoGRLog()
											cErro := STR0025 + CRLF  // "Erro na manute��o da planilha or�ament�ria"
											For nE := 1 To Len(aErroAuto)
												cErro += aErroAuto[nE] + CRLF
											Next nE
										ElseIf nOpcExec == 3
											nOpcExec := 4
										EndIf
									EndIf

									If empty(cErro)
										// Retornando os periodos da planilha.
										aPeriodo := P100Period(cOrcame, cVersaoPla)

										// La�o para processamento das contas do or�amento.
										If XmlChildEx(oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_LISTOFBUDGETACCOUNT") <> Nil
											If XmlChildEx(oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfBudgetAccount, "_BUDGETACCOUNT") <> Nil

												If ValType(oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfBudgetAccount:_BudgetAccount) <> 'A'
													aListConta := {oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfBudgetAccount:_BudgetAccount}
												Else
													aListConta := oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfBudgetAccount:_BudgetAccount
												EndIf

												// Preparando o array auxiliar de cabe�alho.
												aAuxCab := {}
												AAdd(aAuxCab, {"AK2_ORCAME", cOrcame,    nil})
												AAdd(aAuxCab, {"AK2_VERSAO", cVersaoPla, nil})

												// Percorrendo as contas da planilha.
												For nCountConta := 1 To Len(aListConta)
													aCab       := Aclone(aAuxCab)
													aItens     := {}
													aEstrut    := {}
													aEstrutAux := {}
													lGrav      := .F.

													// Conta or�ament�ria.
													If XmlChildEx(aListConta[nCountConta], '_ACCOUNTID') <> Nil
														cContaOrca := aListConta[nCountConta]:_AccountID:Text
														Aadd(aCab, {"AK2_CO", cContaOrca, nil})
													EndIf

													// Incluindo contas na estrutura da planilha.
													AAdd(aEstrutAux, {"AK3_ORCAME", cOrcame,    nil})
													AAdd(aEstrutAux, {"AK3_VERSAO", cVersaoPla, nil})
													AAdd(aEstrutAux, {"AK3_CO",     cContaOrca, nil})

													// Posicionar na conta or�ament�ria.
													AK5->(DbSetOrder(1)) // AK5_FILIAL + AK5_CODIGO.
													If AK5->(DbSeek(FWxFilial('AK5') + cContaOrca, .F.))
														AAdd(aEstrutAux, {"AK3_PAI",    AK5->AK5_COSUP,  nil})
														AAdd(aEstrutAux, {"AK3_TIPO",   AK5->AK5_TIPO,   nil})
														AAdd(aEstrutAux, {"AK3_DESCRI", AK5->AK5_DESCRI, nil})
													EndIf

													AAdd(aEstrut, AClone(aEstrutAux))
													lMsErroAuto := .F.
													MSExecAuto({|x, y, z, a, b, c, d| PCOA100(x, y, z, a, b, c, d)}, nOpcExec, /*cRevisa*/, /*lRev*/, /*lSim*/, aCab, /*aItens*/, aEstrut)

													// Verificando se houve erros.
													If lMsErroAuto
														aErroAuto := GetAutoGRLog()
														cErro += STR0026 + CRLF  // "Erro na manuten��o da estrutura da conta or�ament�ria"
														For nE := 1 To Len(aErroAuto)
															cErro += aErroAuto[nE] + CRLF
														Next nE
													EndIf

													// Itens da planilha.
													If Empty(cErro) .and. XmlChildEx(aListConta[nCountConta],'_LISTOFBUDGETITEM') <> Nil
														If ValType(aListConta[nCountConta]:_ListOfBudgetItem) <> 'A'
															aListItem := {aListConta[nCountConta]:_ListOfBudgetItem}
														Else
															aListItem := aListConta[nCountConta]:_ListOfBudgetItem
														EndIf

														// Percorrendo os itens da planilha.
														For nCountItem:= 1 To Len(aListItem)
															If XmlChildEx(aListItem[nCountItem],'_BUDGETITEM') <> Nil
																If ValType(aListItem[nCountItem]:_BudgetItem) <> 'A'
																	aBudgetItem := {aListItem[nCountItem]:_BudgetItem}
																Else
																	aBudgetItem := aListItem[nCountItem]:_BudgetItem
																EndIf

																For nBudgetItem := 1 To Len(aBudgetItem)
																	aItensAux := {}

																	// Centro de Custo.
																	If XmlChildEx(aBudgetItem[nBudgetItem],'_COSTCENTER') <> Nil
																		cCCusto := aBudgetItem[nBudgetItem]:_CostCenter:Text
																		Aadd(aItensAux, {"AK2_CC", cCCusto, nil})
																	EndIf

																	// Item cont�bil.
																	If XmlChildEx(aBudgetItem[nBudgetItem],'_ACCOUNTINGITEM') <> Nil
																		cItemConta := aBudgetItem[nBudgetItem]:_AccountingItem:Text
																		Aadd(aItensAux, {"AK2_ITCTB", cItemConta, nil})
																	EndIf

																	// Classe de valor.
																	If XmlChildEx(aBudgetItem[nBudgetItem],'_CLASSVALUE') <> Nil
																		cClasVal := aBudgetItem[nBudgetItem]:_ClassValue:Text
																		Aadd(aItensAux, {"AK2_CLVLR", cClasVal, nil})
																	EndIf

																	// Classe or�ament�ria.
																	If XmlChildEx(aBudgetItem[nBudgetItem],'_CLASSBUDGET') <> Nil
																		cClaOrc := aBudgetItem[nBudgetItem]:_ClassBudget:Text
																		Aadd(aItensAux, {"AK2_CLASSE", cClaOrc, nil})
																	EndIf

																	// Descri��o do item.
																	If XmlChildEx(aBudgetItem[nBudgetItem],'_DESCRIPTION') <> Nil
																		cDescri := aBudgetItem[nBudgetItem]:_Description:Text
																		Aadd(aItensAux, {"AK2_DESCRI", cDescri, nil})
																	EndIf

																	// Opera��o do item.
																	If XmlChildEx(aBudgetItem[nBudgetItem],'_OPERATION') <> Nil
																		cOperacao := aBudgetItem[nBudgetItem]:_Operation:Text
																		Aadd(aItensAux, {"AK2_OPER", cOperacao, nil})
																	EndIf

																	// Moeda do item
																	If XmlChildEx(aBudgetItem[nBudgetItem],'_CURRENCY') <> Nil
																		nMoeda := val(aBudgetItem[nBudgetItem]:_Currency:Text)
																		Aadd(aItensAux, {"AK2_MOEDA", nMoeda, nil})
																	EndIf

																	// Unidade or�ament�ria.
																	If XmlChildEx(aBudgetItem[nBudgetItem],'_BUDGETUNIT') <> Nil
																		cUnidOrca := aBudgetItem[nBudgetItem]:_BudgetUnit:Text
																		Aadd(aItensAux, {"AK2_UNIORC", cUnidOrca, nil})
																	EndIf

																	// Entidade cont�bil 05.
																	If XmlChildEx(aBudgetItem[nBudgetItem],'_ACCOUNTENT05') <> Nil
																		cEnt05 := aBudgetItem[nBudgetItem]:_AccountEnt05:Text
																		Aadd(aItensAux, {"AK2_ENT05", cEnt05, nil})
																	EndIf

																	// Entidade cont�bil 06.
																	If XmlChildEx(aBudgetItem[nBudgetItem],'_ACCOUNTENT06') <> Nil
																		cEnt06 := aBudgetItem[nBudgetItem]:_AccountEnt06:Text
																		Aadd(aItensAux, {"AK2_ENT06", cEnt06, nil})
																	EndIf

																	// Entidade cont�bil 07.
																	If XmlChildEx(aBudgetItem[nBudgetItem],'_ACCOUNTENT07') <> Nil
																		cEnt07 := aBudgetItem[nBudgetItem]:_AccountEnt07:Text
																		Aadd(aItensAux, {"AK2_ENT07", cEnt07, nil})
																	EndIf

																	// Entidade cont�bil 08.
																	If XmlChildEx(aBudgetItem[nBudgetItem],'_ACCOUNTENT08') <> Nil
																		cEnt08 := aBudgetItem[nBudgetItem]:_AccountEnt08:Text
																		Aadd(aItensAux, {"AK2_ENT08", cEnt08, nil})
																	EndIf

																	// Entidade cont�bil 09.
																	If XmlChildEx(aBudgetItem[nBudgetItem],'_ACCOUNTENT09') <> Nil
																		cEnt09 := aBudgetItem[nBudgetItem]:_AccountEnt09:Text
																		Aadd(aItensAux, {"AK2_ENT09", cEnt09, nil})
																	EndIf

																	// Item exclu�do.
																	If XmlChildEx(aBudgetItem[nBudgetItem],'_ITEMDELETED') <> Nil
																		cDeleted := aBudgetItem[nBudgetItem]:_ItemDeleted:Text
																		If cDeleted == "1"
																			Aadd(aItensAux,{"AUTDELETA", "S", nil})
																		EndIf
																	EndIf

																	cId := P100GetId(aCab, aItensAux)
																	Aadd(aItensAux, {"AK2_ID", cId, nil})
																	If cId <> "*"
																		Aadd(aItensAux, {"LINPOS", "AK2_ID", cId})
																	EndIf

																	// Lista de per�odos e valores do or�amento.
																	If XmlChildEx(aBudgetItem[nBudgetItem],'_LISTOFBUDGETEDAMOUNT') <> Nil
																		If ValType(aBudgetItem[nBudgetItem]:_ListOfBudgetedAmount:_BudgetedAmount) <> 'A'
																			aListaPeri := {aBudgetItem[nBudgetItem]:_ListOfBudgetedAmount:_BudgetedAmount}
																		Else
																			aListaPeri := aBudgetItem[nBudgetItem]:_ListOfBudgetedAmount:_BudgetedAmount
																		EndIf

																		aPer := {}
																		For nCountPeri := 1 To Len(aListaPeri)
																			cValPer := aListaPeri[nCountPeri]:_amount:Text
																			cValPer := StrTran(cValPer, ".", ",")
																			dPerAux := SToD(StrTran(aListaPeri[nCountPeri]:_DatePeriod:Text, "-", ""))
																			nPos := AScan(aPeriodo, {|x| x[1] == dPerAux})

																			If nPos > 0
																				Aadd(aPer, {aPeriodo[nPos][1], aPeriodo[nPos][2], cValPer, nil})
																			EndIf
																		Next nCountPeri

																		If Len(aPer) > 0
																			Aadd(aItensAux, {"Periodo", aClone(aPer)})
																		EndIf
																		Aadd(aItens, aClone(aItensAux))
																	EndIf
																Next nBudgetItem
															EndIf
														Next nCountItem
													EndIf

													If Empty(cErro)
														P100Grav(aCab, aItens)
														lGrav := .T.

														// Gerando nova vers�o.
														If lNewVersion
															// Posicionar na planilha.
															AK1->(DbSetOrder(1)) // AK1_FILIAL, AK1_CODIGO, AK1_VERSAO.
															If AK1->(DbSeek(FWxFilial('AK1') + cOrcame, .F.))
																dbSelectArea("AKE")
																RegToMemory("AKE", .T.)
																M->AKE_ORCAME	:= AK1->AK1_CODIGO
																M->AKE_DATAI	:= MsDate()
																M->AKE_HORAI	:= Time()
																M->AKE_REVISA	:= AK1->AK1_VERSAO
																M->AKE_DESCRI	:= AK1->AK1_DESCRI
																M->AKE_USERI	:= __cUserId
																PcoRevisa(AK1->(Recno()),, AK1->AK1_VERSAO, cVersaoPla,, .T., .F., .T.)
															EndIf
														EndIf
													EndIf

													If !lGrav .or. !empty(cErro)
														lRet := .F.
														cXMLRet := '<Message type="ERROR" code="c2">' + _NoTags(cErro) + '</Message>'
													Else
														cAK2ValInt := P100MntInt(cFilAnt,;
															PadR(cOrcame,    TamSX3('AK2_ORCAME')[01]),;
															PadR(cVersaoPla, TamSX3('AK2_VERSAO')[01]),;
															PadR(cContaOrca, TamSX3('AK2_CO')[01]),;
															PadR(cCCusto,    TamSX3('AK2_CC')[01]),;
															PadR(cClaOrc,    TamSX3('AK2_CLASSE')[01]),;
															DTOS(dPerAux))

														If !Empty(cAK2ValExt) .And. !Empty(cAK2ValInt)
															CFGA070Mnt(cMarca, "AK2", "AK2_ORCAME", cAK2ValExt, cAK2ValInt)
															cXMLRet := "<ListOfInternalId>"
															cXMLRet +=     "<InternalId>"
															cXMLRet +=         "<Name>" + cMessage + "</Name>"
															cXMLRet +=         "<Origin>" + cAK2ValExt + "</Origin>"
															cXMLRet +=         "<Destination>" + cAK2ValInt + "</Destination>"
															cXMLRet +=     "</InternalId>"
															cXMLRet += "</ListOfInternalId>"
														EndIf
													EndIf
												Next nCountConta
											EndIf
										EndIf
									EndIf

									If !lRet
										DisarmTransaction()
									EndIf

									End Transaction
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return {lRet, cXMLRet, cMessage}

/*/{Protheus.doc} getDate

Retorna somente a data de uma vari�vel datetime

@param cDateTime - Vari�vel dateTime no formado YYYY-MM-DD.

@return cDate - Retorna a data no formado YYYYMMDD.

@author  Lucas Konrad Fran�a
@version P12
@since   24/09/2015
/*/
Static Function getDate(cDateTime)
Return SubStr(cDateTime, 1, 4) + SubStr(cDateTime, 6, 2) + SubStr(cDateTime, 9, 2)

/*{Protheus.doc} P100Period
Retorna os periodos da planilha

@param		cWorksheet  C�digo da Planilha
@param      cVersion    Vers�o da Planilha

@author	Alison Lemes
@version	MP12.1.17
@since		13/04/2018
@return	Os periodos da planilha or�ament�ria
@sample	exemplo de retorno - 0001
*/
Static Function P100Period(cWorksheet, cVersion)

	Local aArea    := GetArea()
	Local aPeraux  := {}
	Local aRetPer  := {}
	local nX       := 0
	Local dAux1    := {}
	Local dAux2    := {}

	Default cWorksheet := ''
	Default cVersion   := ''

	If !Empty(cWorksheet) .AND. !Empty(cVersion)
		AK1->(DbSetOrder(1)) // AK1_FILIAL, AK1_CODIGO, AK1_VERSAO.
		If AK1->(DbSeek(FWxFilial("AK1") + PadR(cWorksheet, Len(AK1->AK1_CODIGO)) + cVersion, .F.))
			aPeraux := PcoRetPer()
			For nX := 1 to len(aPeraux)
				dAux1 := CTOD(Substr(aPeraux[nX], 01, 10))
				dAux2 := CTOD(Substr(aPeraux[nX], 14, 16))
				Aadd(aRetPer, {dAux1, dAux2})
			Next
		EndIf
	EndIf

	RestArea(aArea)

Return aRetPer
