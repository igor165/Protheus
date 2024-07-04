#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'PCOI100.CH'

/*/{Protheus.doc} PCOI100
Função de integração com o adapter EAI para recebimento dos itens da Planilha Orcamentária
utilizando o conceito de mensagem única.

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   cTypeTrans    Tipo de transação (Envio / Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Versão da mensagem.
@param   cTransac      Nome da transação.

@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio
       aRet[3] - (caracter) Nome da mensagem

@author	    Alexandre. Circenis
@since		15/04/2014
@version	MP11.90
/*/
Function PCOI100(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

	Local lRet       := .T.
	Local cXmlRet    := ''
	Local cErroXml   := ''
	Local cWarnXml   := ''
	Local nCntConta  := 0
	Local nCntPeri   := 0
	Local nCntItem   := 0
	Local cAK2ValInt := ''
	Local cAK2ValExt := ''
	Local aAK2ValInt := {}
	Local cValInt    := ''
	Local cMarca     := ''

	Local cVersao    := ''
	Local cContaOrca := ''
	Local cVersaoPla := ''
	Local cOrcame    := ''

	Local oListConta := Nil
	Local oListItem  := Nil
	Local oListaPeri := Nil

	Local cCCusto    := ''
	Local cItemConta := ''
	Local cClasVal   := ''
	Local cEnt05     := ''
	Local cEnt06     := ''
	Local cEnt07     := ''
	Local cEnt08     := ''
	Local cEnt09     := ''
	Local cClaOrc    := ''
	Local cDescri    := ''
	Local cOperacao  := ''
	Local nMoeda     := 0
	Local cUnidOrca  := ''
	Local cDeletado  := ''
	Local aCab       := {}
	Local aCabAux    := {}
	Local aItens     := {}
	Local aItensAux  := {}
	Local aPeriodo   := {}
	Local aPer       := {}
	Local lGrav      := .F.
	Local dPerAux
	Local nPos       := 0
	Local cValPer    := ""
	Local aItem      := {}
	Local nBudgetIt  := 0
	Local oBudgetIt  := Nil

	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .T.
	Private lMostraErro    := .F.
	Private lAutoErrNoFile := .T.
	Private oXmlPCO100     := Nil
	Private cErro          := ""

	AK1->(DbSetOrder(1)) // AK1_FILIAL, AK1_CODIGO, AK1_VERSAO.
	AK2->(DbSetOrder(1)) // AK2_FILIAL, AK2_ORCAME, AK2_VERSAO, AK2_CO, AK2_PERIOD, AK2_ID.
	AK3->(DbSetOrder(1)) // AK3_FILIAL, AK3_ORCAME, AK3_VERSAO, AK3_CO.

	// Verificação do tipo de transação recebimento ou envio.
	Do Case
	Case  cTypeTrans == TRANS_SEND
		// Não havera neste momento do envio de informações

	Case  cTypeTrans == TRANS_RECEIVE
		If cTypeMsg == EAI_MESSAGE_BUSINESS
			oXmlPCO100 := XmlParser(cXml, "_", @cErroXml, @cWarnXml)

			If oXmlPCO100 <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
				If ( XmlChildEx( oXmlPCO100:_TOTVSMessage, '_BUSINESSMESSAGE' ) <> nil )

					// Versão da mensagem única
					If XmlChildEx( oXmlPCO100:_TOTVSMessage:_MessageInformation, '_VERSION') <> Nil
						cVersao := StrTokArr(oXmlPCO100:_TOTVSMessage:_MessageInformation:_Version:Text, ".")[1]
					Else
						lRet    := .F.
						cXmlRet := STR0008  // "Versão da mensagem não informada!"
					EndIf

					// Recebe nome do produto (ex: RM ou PROTHEUS).
					If XmlChildEx( oXmlPCO100:_TOTVSMessage:_MessageInformation:_Product, '_NAME') <> Nil
						cMarca :=  oXmlPCO100:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
					EndIf

					// Recebe o código da conta no cadastro externo.
					If XmlChildEx( oXmlPCO100:_TOTVSMessage:_BusinessMessage, '_BUSINESSEVENT') <> Nil

						If XmlChildEx( oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessEvent, '_IDENTIFICATION') <> Nil
							cAK2ValExt := oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_key:Text

							// Apenas verifica se existe o registro no XXF para saber se é inclusão, alteração ou exclusão.
							aAK2ValInt := P100GetInt(cAK2ValExt, cMarca)
							If aAK2ValInt[1] // Registro encontrado na integração.
								cAK2ValInt := aAK2ValInt[3]
							EndIf
						EndIf

						// Verificação da existência do conteudo da mensagem de negócio.
						If XmlChildEx( oXmlPCO100:_TOTVSMessage:_BusinessMessage, '_BUSINESSCONTENT') <> Nil

							// Planilha orcamentária.
							If XmlChildEx( oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_BUDGETWORKSHEET') <> Nil
								cOrcame := oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BudgetWorksheet:Text

								Aadd(aCabAux, {"AK2_ORCAME", cOrcame, NIL})
								If Empty(cOrcame) .OR. !ExistCpo("AK1", cOrcame)
									cErro += '<Message type="ERROR" code="c2">' + STR0009 + '</Message>'  // "Planilha Inválida ou em Branco"
								Endif

								// Versão da planilha orcamentária.
								If XmlChildEx( oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent,'_WORKSHEETVERSION') <> Nil
									cVersaoPla := oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WorksheetVersion:Text

									Aadd(aCabAux, {"AK2_VERSAO", cVersaoPla, Nil})
									If Empty(cVersaoPla) .OR. !ExistCpo("AK1", PadR(cOrcame, Len(AK1->AK1_CODIGO)) + cVersaoPla)
										cErro += '<Message type="ERROR" code="c2">' + STR0010 + '</Message>'  // "Vers?o Inválida ou em Branco"
									Endif
								EndIf
							EndIf

							aPeriodo := P100Period(aCabAux)

							// Laço para processamento das contas do orçamento.
							If XmlChildEx(oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_LISTOFBUDGETACCOUNT") <> Nil
								If XmlChildEx(oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfBudgetAccount, "_BUDGETACCOUNT") <> Nil

									If ValType(oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfBudgetAccount:_BudgetAccount) <> 'A'
										oListConta := {oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfBudgetAccount:_BudgetAccount}
									Else
										oListConta := oXmlPCO100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfBudgetAccount:_BudgetAccount
									EndIf

									For nCntConta:= 1 To Len(oListConta)
										aCab   := Aclone(aCabAux)
										aItens := {}
										lGrav  := .F.

										// Conta orcamentária.
										If XmlChildEx( oListConta[nCntConta],'_ACCOUNTID') <> Nil
											cContaOrca := oListConta[nCntConta]:_AccountID:Text
											Aadd(aCab ,{"AK2_CO",cContaOrca,Nil})
											If Empty(cContaOrca) .OR. !ExistCpo( "AK5", cContaOrca) .OR. !P100ValSint("AK5", cContaOrca)
												cErro += '<Message type="ERROR" code="c2">' + STR0011 + ': "' + cContaOrca + '"</Message>'  // "Conta Inválida ou em Branco"
											Endif
										EndIf

										If XmlChildEx( oListConta[nCntConta],'_LISTOFBUDGETITEM') <> Nil
											If ValType(oListConta[nCntConta]:_ListOfBudgetItem) <> 'A'
												oListItem := {oListConta[nCntConta]:_ListOfBudgetItem}
											Else
												oListItem := oListConta[nCntConta]:_ListOfBudgetItem
											EndIf
											For nCntItem:= 1 To Len(oListItem)

												If XmlChildEx( oListItem[nCntItem],'_BUDGETITEM') <> Nil
													If ValType(oListItem[nCntItem]:_BudgetItem) <> 'A'
														oBudgetIt := {oListItem[nCntItem]:_BudgetItem}
													Else
														oBudgetIt := oListItem[nCntItem]:_BudgetItem
													EndIf

													For nBudgetIt := 1 To Len( oBudgetIt )
														aItensAux := {}

														// Centro de custo.
														If XmlChildEx( oBudgetIt[nBudgetIt],'_COSTCENTER') <> Nil
															cCCusto := oBudgetIt[nBudgetIt]:_CostCenter:Text
															Aadd(aItensAux, {"AK2_CC",cCCusto, NIL})
															If !ExistCpo( "CTT", cCCusto ) .OR. !P100ValSint("CTT", cCCusto)
																cErro += '<Message type="ERROR" code="c2">' + STR0012 + ': "' + cCCusto + '"</Message>'  // "Centro de custo Invalido"
															Endif
														EndIf

														// Item contábil.
														If XmlChildEx( oBudgetIt[nBudgetIt],'_ACCOUNTINGITEM') <> Nil
															cItemConta := oBudgetIt[nBudgetIt]:_AccountingItem:Text
															Aadd(aItensAux, {"AK2_ITCTB",cItemConta, NIL})

															If !ExistCpo( "CTD", cItemConta ).OR. !P100ValSint("CTD", cItemConta)
																cErro += '<Message type="ERROR" code="c2">' + STR0013 + ': "' + cItemConta + '"</Message>'  // "Item Conta Invalido"
															Endif
														EndIf

														// Classe de valor.
														If XmlChildEx( oBudgetIt[nBudgetIt],'_CLASSVALUE') <> Nil
															cClasVal := oBudgetIt[nBudgetIt]:_ClassValue:Text
																Aadd(aItensAux, {"AK2_CLVLR",cClasVal, NIL})
															If !ExistCpo( "CTH", cClasVal ).OR. !P100ValSint("CTH", cClasVal)
																cErro += '<Message type="ERROR" code="c2">' + STR0014 + ': "' + cClasVal + '"</Message>'  // "Classe de Valor Invalida"
															Endif

														EndIf

														// Classe orçamentária.
														If XmlChildEx( oBudgetIt[nBudgetIt],'_CLASSBUDGET') <> Nil
															cClaOrc := oBudgetIt[nBudgetIt]:_ClassBudget:Text

															Aadd(aItensAux, {"AK2_CLASSE",cClaOrc, NIL})

															If Empty(cClaOrc) .OR. !ExistCpo( "AK6", cClaOrc )
																cErro += '<Message type="ERROR" code="c2">' + STR0015 + ': "' + cClaOrc + '"</Message>'  // "Classe de Orçamentária Invalida ou em Branco"
															Endif
														EndIf

														// Descrição do item.
														If XmlChildEx( oBudgetIt[nBudgetIt],'_DESCRIPTION') <> Nil
															cDescri := oBudgetIt[nBudgetIt]:_Description:Text
															Aadd(aItensAux, {"AK2_DESCRI",cDescri, NIL})
														EndIf

														// Operação do item.
														If XmlChildEx( oBudgetIt[nBudgetIt],'_OPERATION') <> Nil
															cOperacao := oBudgetIt[nBudgetIt]:_Operation:Text

															Aadd(aItensAux, {"AK2_OPER",cOperacao, NIL})
															If !ExistCpo( "AKF", cOperacao )
																cErro += '<Message type="ERROR" code="c2">' + STR0016 + ': "' + cOperacao + '"</Message>'  // "Operaç?o Invalida"
															Endif
														EndIf

														// Moeda do item.
														If XmlChildEx( oBudgetIt[nBudgetIt],'_CURRENCY') <> Nil
															nMoeda := Val(oBudgetIt[nBudgetIt]:_Currency:Text)
															Aadd(aItensAux, {"AK2_MOEDA",nMoeda, NIL})

															If !ExistCpo( "CTO", cValtoChar(PadL(nMoeda, TamSX3("CTO_MOEDA")[1],"0" )))
																cErro += '<Message type="ERROR" code="c2">' + STR0017 + ': "' + cValtoChar(PadL(nMoeda, TamSX3("CTO_MOEDA")[1],"0" )) + '"</Message>'  // "Moeda Invalida"
															Endif
														EndIf

														// Unidade orçamentária.
														If XmlChildEx( oBudgetIt[nBudgetIt],'_BUDGETUNIT') <> Nil
															cUnidOrca := oBudgetIt[nBudgetIt]:_BudgetUnit:Text
															If !EMPTY(cUnidOrca)
																Aadd(aItensAux, {"AK2_UNIORC",cUnidOrca, NIL})
																If !ExistCpo( "AMF", cUnidOrca )
																	cErro += '<Message type="ERROR" code="c2">' + STR0018 + ': "' + cUnidOrca + '"</Message>'  // "Unidade Orçamentária Invalida"
																Endif
															EndIf
														EndIf

														// Entidade contábil 05.
														If XmlChildEx( oBudgetIt[nBudgetIt],'_ACCOUNTENT05') <> Nil
															cEnt05 := oBudgetIt[nBudgetIt]:_AccountEnt05:Text
															Aadd(aItensAux, {"AK2_ENT05",cEnt05, NIL})
															If !(CTB105EntC(/*cPlano*/,cEnt05,.F.,"05"))
																cErro += '<Message type="ERROR" code="c2">' + STR0019 + ': "' + cEnt05 + '"</Message>'  // "Conta entidade 05 inválida"
															Endif
														EndIf

														// Entidade contábil 06.
														If XmlChildEx( oBudgetIt[nBudgetIt],'_ACCOUNTENT06') <> Nil
															cEnt06 := oBudgetIt[nBudgetIt]:_AccountEnt06:Text
															Aadd(aItensAux, {"AK2_ENT06",cEnt06, NIL})
															If !(CTB105EntC(/*cPlano*/,cEnt06,.F.,"06"))
																cErro += '<Message type="ERROR" code="c2">' + STR0020 + ': "' + cEnt06 + '"</Message>'  // "Conta entidade 06 inválida"
															Endif
														EndIf

														// Entidade contábil 07.
														If XmlChildEx( oBudgetIt[nBudgetIt],'_ACCOUNTENT07') <> Nil
															cEnt07 := oBudgetIt[nBudgetIt]:_AccountEnt07:Text
															Aadd(aItensAux, {"AK2_ENT07",cEnt07, NIL})
															If !(CTB105EntC(/*cPlano*/,cEnt07,.F.,"07"))
																cErro += '<Message type="ERROR" code="c2">' + STR0021 + ': "' + cEnt07 + '"</Message>'  // "Conta entidade 07 inválida"
															Endif
														Endif

														// Entidade contábil 08.
														If XmlChildEx( oBudgetIt[nBudgetIt],'_ACCOUNTENT08') <> Nil
															cEnt08 := oBudgetIt[nBudgetIt]:_AccountEnt08:Text
															Aadd(aItensAux, {"AK2_ENT08",cEnt08, NIL})
															If !(CTB105EntC(/*cPlano*/,cEnt08,.F.,"08"))
																cErro += '<Message type="ERROR" code="c2">' + STR0022 + ': "' + cEnt08 + '"</Message>'  // "Conta entidade 08 inválida"
															Endif
														Endif

														// Entidade contábil 09.
														If XmlChildEx( oBudgetIt[nBudgetIt],'_ACCOUNTENT09') <> Nil
															cEnt09 := oBudgetIt[nBudgetIt]:_AccountEnt09:Text
															Aadd(aItensAux, {"AK2_ENT09",cEnt09, NIL})
															If !(CTB105EntC(/*cPlano*/,cEnt09,.F.,"09"))
																cErro += '<Message type="ERROR" code="c2">' + STR0023 + ': "' + cEnt09 + '"</Message>'  // "Conta entidade 09 inválida"
															Endif
														Endif

														// Item excluído.
														If XmlChildEx( oBudgetIt[nBudgetIt],'_IITEMDELETED') <> Nil
															cDeletado := oBudgetIt[nBudgetIt]:_ItemDeleted:Text
															If cDeletado == "1"
																Aadd(aItensAux,{"AUTDELETA","S",Nil})
															EndIf
														EndIf

														cId := P100GetId(aCab, aItensAux)
														Aadd(aItensAux, {"AK2_ID",cId, NIL})
														if cId <> "*"
															Aadd(aItensAux, {"LINPOS","AK2_ID", cId})
														endif

														// Lista de períodos e valores do orçamento.
														If XmlChildEx( oBudgetIt[nBudgetIt],'_LISTOFBUDGETEDAMOUNT') <> Nil
															If ValType(oBudgetIt[nBudgetIt]:_ListOfBudgetedAmount:_BudgetedAmount) <> 'A'
																oListaPeri := {oBudgetIt[nBudgetIt]:_ListOfBudgetedAmount:_BudgetedAmount}
															Else
																oListaPeri := oBudgetIt[nBudgetIt]:_ListOfBudgetedAmount:_BudgetedAmount
															EndIf
															aPer := {}
															For nCntPeri := 1 To Len(oListaPeri)
																cValPer := oListaPeri[nCntPeri]:_amount:Text
																cValPer := StrTran(cValPer, ".", ",")
																dPerAux := SToD(StrTran(oListaPeri[nCntPeri]:_dateperiod:Text,"-",""))
																nPos    := AScan( aPeriodo, { |x| x[1] == dPerAux } )
																If nPos > 0
																	Aadd(aPer, {aPeriodo[nPos][1],aPeriodo[nPos][2] ,cValPer, NIL})
																Endif
															Next nCntPeri

															If Len(aPer)>0
																Aadd(aItensAux, {"Periodo", aClone(aPer)})
															Endif
															Aadd(aItens, aClone(aItensAux))
														EndIf
													Next
												EndIf
											Next nCntItem
										EndIf

										If Empty(cErro)
											P100Grav(aCab, aItens)
											lGrav:= .T.
										Endif

										If !lGrav
											lRet := .F.
											cXMLRet += cErro
										Else
											cAK2ValInt := P100MntInt(cFilAnt,AK2->AK2_ORCAME,AK2->AK2_VERSAO,AK2->AK2_CO,AK2->AK2_CC,AK2->AK2_CLASSE,DTOS(AK2->AK2_PERIOD))

											If !Empty(cAK2ValExt) .And. !Empty(cAK2ValInt)
												CFGA070Mnt( cMarca, "AK2", "AK2_ORCAME", cAK2ValExt, cAK2ValInt )
												// Monta XML com status do processamento da rotina automática OK.
												cXMLRet := "<ListOfInternalId>"
												cXMLRet +=     "<InternalId>"
												cXMLRet +=         "<Name>AccountingEntry</Name>"
												cXMLRet +=         "<Origin>" + cAK2ValExt + "</Origin>" // Valor recebido na tag
												cXMLRet +=         "<Destination>" 	+ cAK2ValInt + "</Destination>" // Valor XXF gerado
												cXMLRet +=     "</InternalId>"
												cXMLRet += "</ListOfInternalId>"
											EndIf
										EndIf
									next nCntConta
								EndIf
							EndIf
						Else
							lRet    := .F.
							cXmlRet := STR0024  // "Bussines CONTENT não informado!"
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE

		ElseIf cTypeMsg == EAI_MESSAGE_WHOIS // Informação das versões compatíveis com a mensagem única.
			cXMLRet := '1.000'
		EndIf
	EndCase

Return { lRet, cXmlRet }


/*{Protheus.doc} P100MntInt
Recebe um registro no Protheus e gera o InternalId deste registro

@param		cIntFil	Filial do Registro
@param		cOrcame	Codigo do Orcamento
@param		cVersao	Codigo da Versao do Orcamento
@param		cCO 	Codigo da Conta Orcamentaria
@param		cItem	Codigo do Item do Orcamento.

@author	marylly.araujo
@version	MP11.90
@since		12/11/13
@return	cRetorno - Retorna o InternalId do registro
@sample	exemplo de retorno - {'Empresa'|'Filial'|'Planilha'|'Versão'|'Conta Orçamentária'|'Centro de Custo'|'Classe de Orçamentária'|'Período'}
*/
Function P100MntInt(cIntFil, cOrcame, cVersao, cCO, cCC, cClasse, dData )
	Local cRetCode	:= ""
	Default cIntFil	:= xFilial('AK2')
	cIntFil	:= xFilial("AK2", cIntFil)

	cRetCode := cEmpAnt + '|' + RTrim(cIntFil) + '|' + RTrim(cOrcame) + '|' + RTrim(cVersao)  + '|' + RTrim(cCO) + '|' + RTrim(cCC) + '|' +  RTrim(cClasse) + '|' +  RTrim(dData)

Return cRetCode

/*{Protheus.doc} P100GetInt
Recebe um codigo, busca seu InternalId e faz a quebra da chave

@param		cCode	InternalID recebido na mensagem.
@param		cMarca	Produto que enviou a mensagem

@author	marylly.araujo
@version	MP11.90
@since		15/04/2014
@return	aRetorno Array contendo os campos da chave primaria da natureza e o seu internalid.
@sample	exemplo de retorno - {.T., {'Empresa', 'xFilial', 'Planilha','Versão','Conta Orçamentária','Centro de Custo','Classe Orçamentária','Período'}, InternalId}
*/
Function P100GetInt(cCodigo, cMarca)

	Local cValInt    := ""
	Local aRetorno   := {}
	Local aAux       := {}
	Local nX         := 0
	Local aCampos    := {/*cEmpAnt*/, 'AK2_FILIAL', 'AK2_ORCAME', 'AK2_VERSAO', 'AK2_CO', 'AK2_CC', 'AK2_CLASSE', 'AK2_PERIOD'}

	cValInt := CFGA070Int(cMarca, 'AK2', 'AK2_ORCAME', cCodigo)
	If !Empty(cValInt)
		aAux := Separa(cValInt, '|')

		// Corrigindo o tamanho dos campos
		aAux[1] := Padr(aAux[1], Len(cEmpAnt))
		For nX := 2 to Len(aAux)
			aAux[nX] := Padr(aAux[nX], TamSX3(aCampos[nX])[1])
		Next nX

		aAdd(aRetorno, .T.)
		aAdd(aRetorno, aAux)
		aAdd(aRetorno, cValInt)
	Else
		aAdd(aRetorno, .F.)
	EndIf

Return aRetorno

/*{Protheus.doc} P100GETID
Recebe um código, busca seu InternalId e faz a quebra da chave

@param		aItem  Linha que está sendo inserida ou alterada

@author	marylly.araujo
@version	MP11.90
@since		15/04/2014
@return	 	cId    Se linha já existe retorna o ID da Linha. Se não existe retorna "*"
@sample	exemplo de retorno - 0001
*/
Function P100GetId(aCab, aItem)
	Local aArea      := GetArea()
	Local cCC        := Criavar("AK2_CC",     .T.) // Centro de Custo
	Local cIC        := Criavar("AK2_ITCTB",  .T.) // Item Contabil
	Local cCV        := Criavar("AK2_CLVLR",  .T.) // Classe de Valor
	Local cOP        := Criavar("AK2_OPER",   .T.) // Operação
	Local cCL        := Criavar("AK2_CLASSE", .T.) // Classe orçamentária
	Local cMO        := Criavar("AK2_MOEDA",  .T.) // Moeda
	Local cE5        := NIL
	Local cE6        := NIL
	Local cE7        := NIL
	Local cE8        := NIL
	Local cE9        := NIL
	Local cQuery     := ""
	Local cRet       := "*"

	If Len (aCab) > 0
		if aScan(aItem, {|x| x[1] = "AK2_CC"}) >0
			cCC := aItem[aScan(aItem, {|x| x[1] = "AK2_CC"})][2]
		endif
		if aScan(aItem, {|x| x[1] = "AK2_ITCTB"}) >0
			cIC := aItem[aScan(aItem, {|x| x[1] = "AK2_ITCTB"})][2]
		endif
		if aScan(aItem, {|x| x[1] = "AK2_CLVLR"}) >0
			cCV := aItem[aScan(aItem, {|x| x[1] = "AK2_CLVLR"})][2]
		endif
		if aScan(aItem, {|x| x[1] = "AK2_OPER"}) >0
			cOP := aItem[aScan(aItem, {|x| x[1] = "AK2_OPER"})][2]
		endif
		if aScan(aItem, {|x| x[1] = "AK2_CLASSE"}) >0
			cCL := aItem[aScan(aItem, {|x| x[1] = "AK2_CLASSE"})][2]
		endif
		if aScan(aItem, {|x| x[1] = "AK2_MOEDA"}) >0
			cMO := aItem[aScan(aItem, {|x| x[1] = "AK2_MOEDA"})][2]
		endif
		if AK2->(FieldPos("AK2_ENT05")) > 0
			cE5 := Criavar("AK2_ENT05", .T.) // Moeda

			if aScan(aItem, {|x| x[1] = "AK2_ENT05"}) >0
				cE5 := aItem[aScan(aItem, {|x| x[1] = "AK2_ENT05"})][2]
			endif
		endif
		if AK2->(FieldPos("AK2_ENT06")) > 0
			cE6 := Criavar("AK2_ENT06", .T.) // Moeda
			if aScan(aItem, {|x| x[1] = "AK2_ENT06"}) >0
				cE6 := aItem[aScan(aItem, {|x| x[1] = "AK2_ENT06"})][2]
			endif
		endif
		if AK2->(FieldPos("AK2_ENT07")) > 0
			cE7 := Criavar("AK2_ENT07", .T.) // Moeda
			if aScan(aItem, {|x| x[1] = "AK2_ENT07"}) >0
				cE7 := aItem[aScan(aItem, {|x| x[1] = "AK2_ENT07"})][2]
			endif
		endif
		if AK2->(FieldPos("AK2_ENT08")) > 0
			cE8 := Criavar("AK2_ENT08", .T.) // Moeda
			if aScan(aItem, {|x| x[1] = "AK2_ENT08"}) >0
				cE8 := aItem[aScan(aItem, {|x| x[1] = "AK2_ENT08"})][2]
			endif
		endif
		if AK2->(FieldPos("AK2_ENT09")) > 0
			cE9 := Criavar("AK2_ENT09", .T.) // Moeda
			if aScan(aItem, {|x| x[1] = "AK2_ENT09"}) >0
				cE9 := aItem[aScan(aItem, {|x| x[1] = "AK2_ENT09"})][2]
			endif
		endif

		cQuery := "select AK2_ID"
		cQuery += " from "+RetSQLName("AK2")
		cQuery += " where AK2_FILIAL = '"+XFilial("AK2")+"'"
		cQuery += " and AK2_ORCAME = '"+aCab[aScan(aCab, {|x| x[1] = "AK2_ORCAME"})][2] +"'"
		cQuery += " and AK2_VERSAO = '"+aCab[aScan(aCab, {|x| x[1] = "AK2_VERSAO"})][2] +"'"
		cQuery += " and AK2_CO = '"+aCab[aScan(aCab, {|x| x[1] = "AK2_CO"})][2] +"'"
		cQuery += " and AK2_CLASSE ='"+ cCL +"'" // classe orçamentária
		cQuery += " and AK2_CC ='"+ cCC +"'" // Centro de Custo
		cQuery += " and AK2_ITCTB ='"+ cIC +"'" // Item Contabil
		cQuery += " and AK2_CLVLR  ='"+ cCV +"'" // Classe de Valor
		cQuery += " and AK2_OPER  ='"+ cOP +"'" // Operação
		cQuery += " and AK2_MOEDA  = "+ AllTrim(Str(cMO))  // Moeda
		if cE5 <> NIL // Há Campo AK2_ENT05
			cQuery += " and AK2_ENT05  ='"+ cE5 +"'" // Entidade05
		endif
		if cE6 <> NIL // Há Campo AK2_ENT06
			cQuery += " and AK2_ENT06  ='"+ cE6 +"'" // Entidade06
		endif
		if cE7 <> NIL // Há Campo AK2_ENT07
			cQuery += " and AK2_ENT07  ='"+ cE7 +"'" // Entidade07
		endif
		if cE8 <> NIL // Há Campo AK2_ENT08
			cQuery += " and AK2_ENT08  ='"+ cE8 +"'" // Entidade08
		endif
		if cE9 <> NIL // Há Campo AK2_ENT09
			cQuery += " and AK2_ENT09  ='"+ cE9 +"'" // Entidade09
		endif
		cQuery += " and D_E_L_E_T_  = ' '" // Não Deletados

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAK2", .T., .T. )

		if !Eof()
			cRet := TMPAK2->AK2_ID
		endif
	Endif
	dbcloseArea()
	tcDelFile("TMPAK2")

	RestArea(aArea)

Return cRet

/*{Protheus.doc} P100Period
Retorna os períodos da planilha.

@param		aPlan  array com os dados da planilha.

@author	TOTVS
@version	MP11.90
@since		02/07/2014
@return	Os períodos da planilha orçamentária.
@sample	exemplo de retorno - 0001
*/
Function P100Period(aPlan)

	Local aArea    := GetArea()
	Local aPeraux  := {}
	Local aRetPer  := {}
	local nx       := 0
	Local dAux1
	Local dAux2
	Local nTamAK1  := Len(AK1->AK1_CODIGO)

	Default aPlan:= {}

	DbSelectArea("AK1")
	AK1->(DbSetOrder(1)) // AK1_FILIAL, AK1_CODIGO, AK1_VERSAO.

	If Len(aPlan) >0
		If AK1->(dbSeek(xFilial("AK1")+PadR(aPlan[1][2], nTamAK1)+aPlan[2][2]))

			aPeraux := PcoRetPer()
			For nx:=1 to len(aPeraux)
				dAux1:= CTOD(Substr(aPeraux[nx],1,10))
				dAux2:= CTOD(Substr(aPeraux[nx],14,16))
				Aadd(aRetPer, {dAux1, dAux2})
			Next
		Endif
	Endif

	RestArea(aArea)

Return aRetPer

/*{Protheus.doc} P100Grav
Grava os itens da planilha

@param		aPlan   array com os dados da planilha.
@param		aItens  array com os itens da planilha.

@author	TOTVS
@version	MP11.90
@since		28/07/2014
@return	Log de erros.
@sample	exemplo de retorno - 0001
*/
Function P100Grav(aPlan, aItens)

	Local nX         := 0
	Local nY         := 0
	Local nW         := 0
	Local nAlt       := 0
	Local nPosCl     := 0
	Local cChaveAK2  := ""
	Local nPosPer    := 0
	Local nID        := ""
	Local nTamAK1    := Len(AK1->AK1_CODIGO)
	Local nTamAK2    := Len(AK2->AK2_CO)
	Local nPosMoeda  := 0
	Local nPosDelete := 0
	Local l100GExc   := .F.
	Local l100GInc   := .F.

	Default aPlan  := {}
	Default aItens := {}

	Begin Transaction
		nID		 := PcoAK2NextID(aPlan)
		PcoIniLan("000252")
		For nX := 1 To Len(aItens)

			nAlt       := (aScan(aItens[nX], {|x| x[1] = "LINPOS"}))
			nPosCl     := (aScan(aItens[nX], {|x| x[1] = "AK2_CLASSE"}))
			nPosPer    := Len(aItens[nX]) // Última posição do array sempre será o array de periodos
			nPeriodo   := Len(aItens[nX][nPosPer][2]) // Tamanho do último array
			nPosMoeda  := (aScan(aItens[nX], {|x| x[1] = "AK2_MOEDA"}))
			nPosDelete := (aScan(aItens[nX], {|x| x[1] = "AUTDELETA"}))
			l100GExc   := (nPosDelete > 0 .AND. aItens[nX][nPosDelete][2] == 'S')

			For nY := 1 To nPeriodo
					If nAlt > 0
						cChaveAK2 := (xFilial("AK2")+PadR(aPlan[1][2], nTamAK1)+aPlan[2][2]+Padr(aPlan[3][2], nTamAK2) + DTOS(aItens[nX][nPosPer][2][nY][1])+ aItens [nX][nAlt][3])
					Else
						cChaveAK2:= ""
					Endif
					dbSelectArea("AK2")
					dbSetOrder(1)//AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO+DTOS(AK2_PERIOD)+AK2_ID
					If AK2->(dbSeek(cChaveAK2)) .and. !Empty(cChaveAK2) .And. AllTrim(ValType(aItens[nX][nPosPer][2])) == "A"
						l100GInc := .F.
						RecLock("AK2",.F.)
						//Verifica se vai excluir
						If (l100GExc)
							AK2->(DBDelete())
						Else
							For nW := 1 To (Len(aItens[nX])-2)
								&( aItens[nX][nW][1] ) := aItens[nX][nW][2]
							Next nW
							AK2->AK2_VALOR	:= PcoPlanVal(aItens[nX][nPosPer][2][nY][3], aItens[nX][nPosCl][2])//adicionar classe
						EndIf

						AK2->(MsUnlock())
					ElseIf !(l100GExc)
						If AllTrim(ValType(aItens[nX][nPosPer][2])) == "A" //vld se existe um array nessa posição, p/ ñ gerar error log
							l100GInc := .T.
							RecLock("AK2",.T.)
							If !Empty(aItens[nX][nPosPer][2][nY][3])
								AK2->AK2_FILIAL	:= xFilial("AK2")
								AK2->AK2_ORCAME 	:= aPlan[1][2]
								AK2->AK2_VERSAO 	:= aPlan[2][2]
								AK2->AK2_CO 	  	:= aPlan[3][2]
								AK2->AK2_PERIOD	:= aItens[nX][nPosPer][2][nY][1]
								AK2->AK2_DATAI	:= aItens[nX][nPosPer][2][nY][1]
								AK2->AK2_DATAF	:= aItens[nX][nPosPer][2][nY][2]
								AK2->AK2_VALOR	:= PcoPlanVal(aItens[nX][nPosPer][2][nY][3], aItens[nX][nPosCl][2])//adicionar classe
								AK2->AK2_ID		:= StrZero(nID, Len(AK2->AK2_ID))
								If nPosMoeda == 0
									AK2->AK2_MOEDA := 1
								Endif

								For nW := 1 to (Len(aItens[nX])-2)
									&( aItens[nX][nW][1] ) := aItens[nX][nW][2]
								Next nW
							Endif
							AK2->(MsUnlock())
						EndIf
					Endif

					If (l100GInc)
						PcoDetLan("000252","01","PCOA100",,,, .F.)
					Else
						PcoDetLan("000252","01","PCOA100", IIf(l100GExc, .T., .F.)/*lDeleta*/,,, .F.)
					EndIf

				Next nY
				nID:= PcoAK2NextID(aPlan)
			Next nX
		PcoFinLan("000252")
	End Transaction

Return


/*{Protheus.doc} P100ValSint
Valida se a entidade é sintética ou analítica.

@param		cAlias  Alias da tabela
@param		cConta  Número da conta

@author	TOTVS
@version	MP11.90
@since		28/07/2014
@return
*/
Static Function P100ValSint(cAliasEnt, cCampo)
	Local lRet  := .T.

	dbSelectArea(cAliasEnt)
	dbSetOrder(1)

	If dbSeek(xFilial(cAliasEnt)+cCampo)
		If cAliasEnt== "AK5"
			lRet := (AK5->AK5_TIPO == "2")
		Else
			lRet := ((cAliasEnt)->&((cAliasEnt)+"_CLASSE")) == "2"
		Endif
	Endif

Return lRet

/*{Protheus.doc} PcoAK2NextID
Novo ID do item

@param		aPlan   array com os dados da planilha.
@param		aItens  array com os itens da planilha.

@author	TOTVS
@version	MP11.90
@since		28/07/2014
@return	Log de erros.
@sample	exemplo de retorno - 0001
*/
Static Function PcoAK2NextID(aPlan)

	Local nItAK2   := 0
	Local aArea    := AK2->(GetArea())
	Local nTamAK1  := Len(AK1->AK1_CODIGO)
	Local nTamAK2  := Len(AK2->AK2_CO)
	Local cChave   := xFilial("AK2") + PadR(aPlan[1][2], nTamAK1) + aPlan[2][2] + Padr(aPlan[3][2], nTamAK2)

	dbSelectArea("AK2")
	dbSetOrder(5)  // AK2_FILIAL, AK2_ORCAME, AK2_VERSAO, AK2_CO, AK2_ID, AK2_PERIOD.
	If dbSeek(cChave)
		While AK2->(!Eof() .And. AK2_FILIAL + AK2_ORCAME + AK2_VERSAO + AK2_CO == cChave)
			nItAK2 := VAL(AK2->AK2_ID)
			AK2->(dbSkip())
		End
	EndIf
	nItAK2++

	RestArea(aArea)

Return(nItAK2)
