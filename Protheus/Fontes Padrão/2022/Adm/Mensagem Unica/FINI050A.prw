#Include 'Protheus.ch'
#Include 'fwAdapterEAI.ch'
#Include 'FINI050A.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} FINI050A
Funcao de integracao com o adapter EAI para envio e recebimento de
substituição de título a pagar utilizando o conceito de mensagem unica.

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   nTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   02/10/2013
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem Xml para envio

@obs     O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
         o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
         TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
         O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------
Function FINI050A(cXml, nTypeTrans, cTypeMessage)
   Local cXmlRet          := ""
   Local lRet             := .T.
   Local nOpcx            := 6
   Local cAlias           := "SE2"
   Local cField           := "E2_NUM"
   Local cOperation       := "AccountPayableDocumentReplace"
   Local nI               := 0
   Local cError           := ""
   Local cWarning         := ""
   Local cValInt          := ""
   Local cValInt2         := ""
   Local cValExt          := ""
   Local cValExt2         := ""
   Local lCopiaProv       := .F.
   Local aTit             := {}
   Local aTitPrv          := {}
   Local aAux             := {}
   Local aBcoDefault      := {}
   Local cFilial          := ""
   Local cPrefixo         := ""
   Local cNumDoc          := ""
   Local cParcela         := ""
   Local cTipoDoc         := ""
   Local cFornec          := ""
   Local cLoja            := ""
   Local dVenc            := Nil
   Local dVencReal        := Nil
   Local cAux             := ""
   Local nAux             := 0
   Local aRatCC           := {}
   Local aRatPrj          := {}
   Local lLog             := FindFunction('AdpLogEAI')
   Local aRatAux          := {}
   Private oXml           := Nil
   Private oXmlAux        := Nil
   Private lMsErroAuto    := .F.
   Private lAutoErrNoFile := .T.

   IIf(lLog, AdpLogEAI(1, "FINI050A", nTypeTrans, cTypeMessage, cXML), ConOut(STR0001)) //"Atualize o pmsxsolum.prw para utilizar o log"

   //Mensagem de Entrada
   If nTypeTrans == TRANS_RECEIVE
      If cTypeMessage == EAI_MESSAGE_BUSINESS
         oXml := xmlParser(cXml, "_", @cError, @cWarning)

         If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
            //Verifica se a marca foi informada
            If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
               cMarca := oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text
            Else
               lRet := .F.
               cXmlRet := STR0002 //"Informe o produto!"
               IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
               Return {lRet, cXmlRet}
            EndIf

            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CopyDataFromTemporary:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CopyDataFromTemporary:Text)
               If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CopyDataFromTemporary:Text) == "TRUE" .Or. oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CopyDataFromTemporary:Text == "1"
                  lCopiaProv := .T.
               EndIf
            EndIf

            //Verifica se o InternalId do título provisório foi informado
            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TemporaryAccountPayableDocument:_InternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TemporaryAccountPayableDocument:_InternalId:Text)
               cValExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TemporaryAccountPayableDocument:_InternalId:Text
            Else
               lRet := .F.
               cXmlRet := STR0003 //"O InternalId do título provisório é obrigatório!"
               IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
               Return {lRet, cXmlRet}
            EndIf

            //Verifica se o InternalId do título efetivo foi informado
            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_InternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_InternalId:Text)
               cValExt2 := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_InternalId:Text
            Else
               lRet := .F.
               cXmlRet := STR0004 //"O InternalId do título efetivo é obrigatório!"
               IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
               Return {lRet, cXmlRet}
            EndIf

            //Obtém o valor interno da tabela XXF (de/para)
            cValInt := RTrim(CFGA070INT(cMarca, cAlias, cField, cValExt))

            // Se o registro existe
            If !Empty(cValInt)
               cFilial  := PadR(Separa(cValInt, '|')[2], TamSX3("E2_FILIAL")[1])
               cPrefixo := PadR(Separa(cValInt, '|')[3], TamSX3("E2_PREFIXO")[1])
               cNumDoc  := PadR(Separa(cValInt, '|')[4], TamSX3("E2_NUM")[1])
               cParcela := PadR(Separa(cValInt, '|')[5], TamSX3("E2_PARCELA")[1])
               cTipoDoc := PadR(Separa(cValInt, '|')[6], TamSX3("E2_TIPO")[1])
               cFornec  := PadR(Separa(cValInt, '|')[7], TamSX3("E2_FORNECE")[1])
               cLoja    := PadR(Separa(cValInt, '|')[8], TamSX3("E2_LOJA")[1])

               dbSelectArea("SE2")
               SE2->(dbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

               If !SE2->(dbSeek(cFilial + cPrefixo + cNumDoc + cParcela + cTipoDoc + cFornec + cLoja))
                  lRet := .F.
                  cXmlRet := STR0005 + cValInt + STR0006 //"O título provisório " " não foi encontrado na base!"
                  IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
                  Return {lRet, cXmlRet}
               EndIf

               nOpcx := 6 // Substituição
               aAdd(aAux, {"E2_PREFIXO", cPrefixo,        Nil})
               aAdd(aAux, {"E2_NUM",     cNumDoc,         Nil})
               aAdd(aAux, {"E2_PARCELA", cParcela,        Nil})
               aAdd(aAux, {"E2_TIPO",    cTipoDoc,        Nil})
               aAdd(aAux, {"E2_FORNECE", cFornec,         Nil})
               aAdd(aAux, {"E2_LOJA",    cLoja,           Nil})
               aAdd(aAux, {"E2_EMISSAO", SE2->E2_EMISSAO, Nil})
               aAdd(aAux, {"E2_VENCTO",  SE2->E2_VENCTO,  Nil})
               aAdd(aAux, {"E2_VALOR",   SE2->E2_VALOR,   Nil})
               aAdd(aAux, {"E2_MOEDA",   SE2->E2_MOEDA,   Nil})
               aAdd(aAux, {"E2_ORIGEM",  SE2->E2_ORIGEM,  Nil})
               aAdd(aTitPrv, aAux)
               aAux := {}

               //Verifica se o Prefíxo do Título foi informado
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_DocumentPrefix:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_DocumentPrefix:Text)
                  cPrefixo := PadR(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_DocumentPrefix:Text, TamSX3("E2_PREFIXO")[1])
               ElseIf GetNewPar("MV_PMSITMU", "0") == "1" //Possui integração com o RM Solum
                  cPrefixo := PadR(GetNewPar("MV_SLMPREP", ""), TamSX3("E2_PREFIXO")[1])
               EndIf

               //Verifica se o Número do Título foi informado
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_DocumentNumber:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_DocumentNumber:Text)
                  cNumDoc := PadR(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_DocumentNumber:Text, TamSX3("E2_NUM")[1])
               Else
                  lRet := .F.
                  cXmlRet := STR0007 //"Informe o número do título"
                  IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
                  Return {lRet, cXmlRet}
               EndIf

               //Verifica se a parcela do Título foi informado
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_DocumentParcel:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_DocumentParcel:Text)
                  cParcela := PadR(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_DocumentParcel:Text, TamSX3("E2_PARCELA")[1])
               EndIf

               //Verifica se o Tipo do Título foi informado
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_DocumentTypeCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_DocumentTypeCode:Text)
                  cTipoDoc := PadR(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_DocumentTypeCode:Text, TamSX3("E2_TIPO")[1])
               Else
                  lRet := .F.
                  cXmlRet := STR0008 //"Informe o tipo do título"
                  IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
                  Return {lRet, cXmlRet}
               EndIf

               //Obtém o Código Interno do Fornecedor
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_VendorInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_VendorInternalId:Text)
                  aAux := IntForInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_VendorInternalId:Text, cMarca)
                  If !aAux[1]
                     lRet := aAux[1]
                     cXmlRet := aAux[2]
                     IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
                     Return {lRet, cXmlRet}
                  Else
                     cFornec := PadR(aAux[2][3], TamSX3("E2_FORNECE")[1])
                     cLoja := PadR(aAux[2][4], TamSX3("E2_LOJA")[1])
                  EndIf
               Else
                  lRet := .F.
                  cXmlRet := STR0009 //"Informe o InternalId do fornecedor."
                  IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
                  Return {lRet, cXmlRet}
               EndIf

               cValInt2 := cEmpAnt + '|' + RTrim(xFilial(cAlias)) + '|' + RTrim(cPrefixo) + '|' + RTrim(cNumDoc) + '|' + RTrim(cParcela) + '|' + RTrim(cTipoDoc) + '|' + RTrim(cFornec) + '|' + RTrim(cLoja)

               // Verifica se Natureza foi informada
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_FinancialNatureInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_FinancialNatureInternalId:Text)
                  aAux := F10GetInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_FinancialNatureInternalId:Text, cMarca) //Adapter FINI010I

                  If aAux[1]
                     aAdd(aTit, {"E2_NATUREZ", PadR(aAux[2][3], TamSx3("E2_NATUREZ")[1]), Nil})
                  Else
                     lRet := .F.
                     cXmlRet := STR0010 //"Natureza não encontrada no de/para."
                     IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
                     Return {lRet, cXmlRet}
                  EndIf
               Else // Utiliza o parâmetro MV_SLMNATP criado para a integração Protheus x RM Solum para
                    // as demais integrações quando o FinancialNatureInternalId não for informado
                  cAux := RTrim(GetNewPar("MV_SLMNATP", ""))

                  //Verifica se a natureza obtida existe na base
                  If !Empty(cAux)
                     aAdd(aTit, {"E2_NATUREZ", PadR(cAux, TamSx3("E2_NATUREZ")[1]), Nil})
                  Else
                     lRet := .F.
                     cXmlRet := STR0011 //"Natureza não informada. Verifique o parâmetro MV_SLMNATP."
                     IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
                     Return {lRet, cXmlRet}
                  EndIf
               EndIf

               //Verifica se a emissão do Título foi informada
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_IssueDate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_IssueDate:Text)
                  aAdd(aTit, {"E2_EMISSAO", SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_IssueDate:Text,"-","")), Nil})
               EndIf

               //Verifica se o Vencimento do Título foi informado
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_DueDate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_DueDate:Text)
                  dVenc := SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_DueDate:Text,"-",""))
                  aAdd(aTit, {"E2_VENCTO", dVenc, Nil})
               ElseIf lCopiaProv
                  dVenc := SE2->E2_VENCTO
                  aAdd(aTit, {"E2_VENCTO", dVenc, Nil})
               Else
                  lRet := .F.
                  cXmlRet := STR0012 //"Informe o vencimento do título."
                  IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
                  Return {lRet, cXmlRet}
               EndIf

               //Verifica se o Vencimento real do Título foi informado
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_RealDueDate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_RealDueDate:Text)
                  dVencReal := Datavalida(SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_RealDueDate:Text,"-","")))
                  aAdd(aTit, {"E2_VENCREA", dVencReal, Nil})
               ElseIf lCopiaProv
                  dVencReal := SE2->E2_VENCREA
                  aAdd(aTit, {"E2_VENCREA", dVencReal, Nil})
               Else
                  dVencReal := Datavalida(SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_DueDate:Text,"-","")))
                  aAdd(aTit, {"E2_VENCREA", dVencReal, Nil})
               EndIf

               //Verifica se o Valor do Título foi informado
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_NetValue:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_NetValue:Text)
                  aAdd(aTit, {"E2_VALOR", Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_NetValue:Text), Nil})
                  aAdd(aTit, {"E2_VLCRUZ", Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_NetValue:Text), Nil})
               ElseIf lCopiaProv
                  aAdd(aTit, {"E2_VALOR", SE2->E2_VALOR, Nil})
                  aAdd(aTit, {"E2_VLCRUZ", SE2->E2_VLCRUZ, Nil})
               Else
                  lRet := .F.
                  cXmlRet := STR0013 //"Informe o valor do título."
                  IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
                  Return {lRet, cXmlRet}
               EndIf

               //Verifica se amoeda foi informada
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_CurrencyInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_CurrencyInternalId:Text)
                  aAux := IntMoeInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_CurrencyInternalId:Text, cMarca) //Adapter CTBI140
                  If !aAux[1]
                     lRet := aAux[1]
                     cXmlRet := aAux[2]
                     IIf(lLog, AdpLogEAI(5, "FINI040", cXMLRet, lRet), ConOut(STR0001))
                     Return {lRet, cXmlRet}
                  Else
                     aAdd(aTit, {"E2_MOEDA", Val(aAux[2][3]), Nil})
                  EndIf
               Else
                  aAdd(aTit, {"E2_MOEDA", 1, Nil})
               EndIf

               //Verifica se a origem foi informada
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Origin:Text)
                  aAdd(aTit, {"E2_ORIGEM", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Origin:Text, Nil})
               Else
                  aAdd(aTit, {"E2_ORIGEM", "FINI050", Nil})
               EndIf

               If cTipoDoc $ MVPAGANT
                  // carrega o banco/agencia/conta padrão do parametro MV_CXFIN
                  aBcoDefault := xCxFina()

                  aAdd(aTit, {"AUTBANCO",   aBcoDefault[1], Nil})
                  aAdd(aTit, {"AUTAGENCIA", aBcoDefault[2], Nil})
                  aAdd(aTit, {"AUTCONTA",   aBcoDefault[3], Nil})

                  SA6->(DbSetOrder(1)) // A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON

                  If SA6->(dbSeek(xFilial("SA6") + PADR(aBcoDefault[1], TamSX3("A6_COD")[1]) + PADR(aBcoDefault[2], TamSX3("A6_AGENCIA")[1]) + PADR(aBcoDefault[3], TamSX3("A6_NUMCON")[1])))
                     aAdd(aTit, {"E2_MOEDA", SA6->A6_MOEDA, Nil})
                  Else
                     lRet := .F.
                     cXmlRet := STR0014 //"Banco não encontrado. Verifique o parâmetro MV_CXFIN."
                     IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
                     Return {lRet, cXmlRet}
                  EndIf
               EndIf

               //Possui rateio
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_ListOfApportion:_Apportion") != "U"
                  //Se não for Array
                  If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_ListOfApportion:_Apportion") != "A"
                     //Transforma em array
                     XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_ListOfApportion:_Apportion,"_Apportion")
                  EndIf

                  For nI := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_ListOfApportion:_Apportion)
                     // Atualiza o objeto com a posição atual
                     oXmlAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_ListOfApportion:_Apportion[nI]

                     // Se possui Centro de Custo Informado
                     If Type("oXmlAux:_CostCenterInternalId:Text") != "U" .And. !Empty(oXmlAux:_CostCenterInternalId:Text)
                        // Obtém a chave interna do Centro de Custo
                        aAux := IntCusInt(oXmlAux:_CostCenterInternalId:Text, cMarca)
                        If !aAux[1]
                           lRet := .F.
                           cXmlRet := aAux[2] + STR0015 + cNumDoc + "." //" Título "
                           IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
                           Return {lRet, cXmlRet}
                        EndIf

                        // Se possui valor informado
                        If Type("oXmlAux:_Value:Text") != "U" .And. !Empty(oXmlAux:_Value:Text)
                           // Se já existe o centro de custo somar os valores
                           If (nAux := aScan(aRatCC, {|x| RTrim(x[3][2]) == RTrim(aAux[2][3])})) > 0
                              aRatCC[nAux][2][2] := aRatCC[nAux][2][2] + Val(oXmlAux:_Value:Text)
                              aRatCC[nAux][1][2] := Round(aRatCC[nAux][2][2] * 100 / Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_NetValue:Text), 2)
                           Else
                              aAdd(aRatAux, {"CTJ_PERCEN", Round(Val(oXmlAux:_Value:Text) * 100 / Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalAccountPayableDocument:_NetValue:Text), 2), Nil})
                              aAdd(aRatAux, {"CTJ_VALOR",  Val(oXmlAux:_Value:Text),                                                                                                                            Nil})
                              aAdd(aRatAux, {"CTJ_CCD",    PadR(aAux[2][3], TamSX3("CTJ_CCD")[1]),                                                                                                              Nil})
                              aAdd(aRatAux, {"CTJ_DESC",   "TIT. A PAGAR " + cNumDoc,                                                                                                                           Nil})
                              aAdd(aRatCC, aRatAux)
                              aRatAux := {}
                           EndIf
                        Else
                           lRet := .F.
                           cXmlRet := STR0016 + cNumDoc //"Valor do rateio inálido para o título "
                           IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
                           Return {lRet, cXmlRet}
                        EndIf
                     EndIf

                     // Se possui projeto informado
                     If Type("oXmlAux:_ProjectInternalId:Text") != "U" .And. !Empty(oXmlAux:_ProjectInternalId:Text)
                        // Verifica se o código do projeto é álido (retorno .T. or .F.)
                        aAux := IntPrjInt(oXmlAux:_ProjectInternalId:Text, cMarca) //Empresa/Filial/Projeto
                        If !aAux[1]
                           lRet := .F.
                           cXmlRet := aAux[2] + STR0015 + cNumDoc
                           IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
                           Return {lRet, cXmlRet}
                        Else
                           xAux := aAux[2][3]
                        EndIf

                        If Type("oXmlAux:_TaskInternalId:Text") != "U" .And. !Empty(oXmlAux:_TaskInternalId:Text)
                           aAux := IntTrfInt(oXmlAux:_TaskInternalId:Text, cMarca) //Empresa/Filial/Projeto/Revisao/Tarefa
                           If !aAux[1]
                              lRet := .F.
                              cXmlRet := aAux[2] + STR0015 + cNumDoc
                              IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
                              Return {lRet, cXmlRet}
                           Else
                              cTarefa := PadR(aAux[2][5], TamSX3("AFR_TAREFA")[1])
                           EndIf
                        Else
                           // No Adiantamento não é informada uma tarefa, só Projeto.
                           // Aqui se obtém a primeira Tarefa do Projeto informado.
                           AF9->(DbSetOrder(5)) // AF9_FILIAL + AF9_PROJET + AF9_TAREFA

                           If AF9->(dbSeek(xFilial("AF9") + PadR(xAux, TamSX3("AF9_PROJET")[1])))
                              cTarefa := AF9->AF9_TAREFA
                           Else
                              lRet := .F.
                              cXmlRet := STR0017 //"Não existe Tarefa para o Projeto informado."
                              IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
                              Return {lRet, cXmlRet}
                           EndIf
                        EndIf

                        // Se possui valor informado
                        If Type("oXmlAux:_Value:Text") != "U" .And. !Empty(oXmlAux:_Value:Text)
                           // Se já existe o projeto/tarefa somar os valores
                           If (nAux := aScan(aRatPrj, {|x| RTrim(x[1][2]) == RTrim(xAux) .And. RTrim(x[2][2]) == RTrim(cTarefa)})) > 0
                              aRatPrj[nAux][4][2] := aRatPrj[nAux][4][2] + Val(oXmlAux:_Value:Text)
                           Else
                              aAux := {}
                              aAdd(aAux, {"AFR_PROJET", PadR(xAux, TamSX3("AF9_PROJET")[1]),  Nil})
                              aAdd(aAux, {"AFR_TAREFA", cTarefa,                              Nil})
                              aAdd(aAux, {"AFR_TIPOD",  PadR("0004", TamSx3("AFR_TIPOD")[1]), Nil})
                              aAdd(aAux, {"AFR_VALOR1", Val(oXmlAux:_Value:Text),             Nil})
                              aAdd(aAux, {"AFR_REVISA", StrZero(1, TamSX3("AFR_REVISA")[1]),  Nil})
                              aAdd(aAux, {"AFR_PREFIX", cPrefixo,                             Nil})
                              aAdd(aAux, {"AFR_NUM",    cNumDoc,                              Nil})
                              aAdd(aAux, {"AFR_PARCEL", cParcela,                             Nil})
                              aAdd(aAux, {"AFR_TIPO",   cTipoDoc,                             Nil})
                              aAdd(aAux, {"AFR_FORNEC", cFornec,                              Nil})
                              aAdd(aAux, {"AFR_LOJA",   cLoja,                                Nil})
                              aAdd(aAux, {"AFR_DATA",   dVenc,                                Nil})
                              aAdd(aAux, {"AFR_VENREA", dVencReal,                            Nil})
                              aAdd(aRatPrj, aAux)
                           EndIf
                        Else
                           lRet := .F.
                           cXmlRet := STR0016 + cNumDoc
                           IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
                           Return {lRet, cXmlRet}
                        EndIf
                     EndIf
                  Next nCount
               EndIf

               aAdd(aTit, {"E2_PREFIXO", cPrefixo,  Nil})
               aAdd(aTit, {"E2_NUM",     cNumDoc,   Nil})
               aAdd(aTit, {"E2_PARCELA", cParcela,  Nil})
               aAdd(aTit, {"E2_TIPO",    cTipoDoc,  Nil})
               aAdd(aTit, {"E2_FORNECE", cFornec,   Nil})
               aAdd(aTit, {"E2_LOJA",    cLoja,     Nil})

               If lCopiaProv // Copiar os rateios do título provisório
                  // Rateio de projeto
                  If Empty(aRatPrj)
                     dbSelectArea("AFR")
                     AFR->(dbSetOrder(2)) //AFR_FILIAL+AFR_PREFIX+AFR_NUM+AFR_PARCEL+AFR_TIPO+AFR_FORNEC+AFR_LOJA+AFR_PROJET+AFR_REVISA+AFR_TAREFA

                     If AFR->(dbSeek(xFilial("AFR") + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA))
                        While xFilial("AFR") + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA == AFR->AFR_FILIAL + AFR->AFR_PREFIX + AFR->AFR_NUM + AFR->AFR_PARCEL + AFR->AFR_TIPO + AFR->AFR_FORNEC + AFR->AFR_LOJA .And. !AFR->(Eof())
                           aAux := {}
                           aAdd(aAux, {"AFR_PROJET", AFR->AFR_PROJET, Nil})
                           aAdd(aAux, {"AFR_TAREFA", AFR->AFR_TAREFA, Nil})
                           aAdd(aAux, {"AFR_TIPOD",  AFR->AFR_TIPOD,  Nil})
                           aAdd(aAux, {"AFR_VALOR1", AFR->AFR_VALOR1, Nil})
                           aAdd(aAux, {"AFR_REVISA", AFR->AFR_REVISA, Nil})
                           aAdd(aAux, {"AFR_PREFIX", AFR->AFR_PREFIX, Nil})
                           aAdd(aAux, {"AFR_NUM",    AFR->AFR_NUM,    Nil})
                           aAdd(aAux, {"AFR_PARCEL", AFR->AFR_PARCEL, Nil})
                           aAdd(aAux, {"AFR_TIPO",   AFR->AFR_TIPO,   Nil})
                           aAdd(aAux, {"AFR_FORNEC", AFR->AFR_FORNEC, Nil})
                           aAdd(aAux, {"AFR_LOJA",   AFR->AFR_LOJA,   Nil})
                           aAdd(aAux, {"AFR_DATA",   AFR->AFR_DATA,   Nil})
                           aAdd(aAux, {"AFR_VENREA", AFR->AFR_VENREA, Nil})
                           aAdd(aAux, {"AFR_VIAINT", AFR->AFR_VIAINT, Nil})
                           aAdd(aRatPrj, aAux)

                           AFR->(dbSkip())
                        EndDo
                     EndIf
                  EndIf

                  // Rateio de centro de custo
                  If Empty(aRatCC)
                     dbSelectArea("CV4")
                     CV4->(dbSetOrder(1)) //CV4_FILIAL+DTOS(CV4_DTSEQ)+CV4_SEQUEN

                     If CV4->(dbSeek(SE2->E2_ARQRAT))
                        While RTrim(CV4_FILIAL + DTOS(CV4_DTSEQ) + CV4_SEQUEN) == RTrim(SE2->E2_ARQRAT) .And. !CV4->(Eof())
                           aAux := {}
                           aAdd(aAux, {"CTJ_DEBITO", CV4->CV4_DEBITO,           Nil})
                           aAdd(aAux, {"CTJ_CREDIT", CV4->CV4_CREDIT,           Nil})
                           aAdd(aAux, {"CTJ_PERCEN", CV4->CV4_PERCEN,           Nil})
                           aAdd(aAux, {"CTJ_VALOR",  CV4->CV4_VALOR,            Nil})
                           aAdd(aAux, {"CTJ_DESC",   "TIT. A PAGAR " + cNumDoc, Nil})
                           aAdd(aAux, {"CTJ_CCC",    CV4->CV4_CCC,              Nil})
                           aAdd(aAux, {"CTJ_CCD",    CV4->CV4_CCD,              Nil})
                           aAdd(aAux, {"CTJ_ITEMD",  CV4->CV4_ITEMD,            Nil})
                           aAdd(aAux, {"CTJ_ITEMC",  CV4->CV4_ITEMC,            Nil})
                           aAdd(aAux, {"CTJ_CLVLDB", CV4->CV4_CLVLDB,           Nil})
                           aAdd(aAux, {"CTJ_CLVLCR", CV4->CV4_CLVLCR,           Nil})
                           aAdd(aRatCC, aAux)

                           CV4->(dbSkip())
                        EndDo
                     EndIf
                  EndIf
               EndIf

               // Se há rateio por Centro de Custo
               If !Empty(aRatCC)
                  aAdd(aTit, {"E2_RATEIO", "S", Nil})
               EndIf

               // Inclui o array de rateio por Projeto/Tarefa no array do títulos
               If !Empty(aRatPrj)
                  aAdd(aTit, {"E2_PROJPMS", "2",    Nil})
                  aAdd(aTit, {"AUTRATAFR",  aRatPrj, Nil})
               EndIf
            Else
               lRet := .F.
               cXmlRet := STR0018 //"O título provisório não foi encontrado no sistema! Verifique o InternalID."
               IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
               Return {lRet, cXmlRet}
            EndIf

            If lLog
               AdpLogEAI(3, "aTit: ", aTit)
               AdpLogEAI(3, "aRatCC: ", aRatCC)
               AdpLogEAI(3, "cValInt(Título provisório): ", cValInt)
               AdpLogEAI(3, "cValExt(Título provisório): ", cValExt)
               AdpLogEAI(3, "cValInt(Título original): ", cValInt2)
               AdpLogEAI(3, "cValExt(Título original): ", cValExt2)
               AdpLogEAI(4, nOpcx)
            Else
               ConOut(STR0001)
            EndIf

            MsExecAuto({|x,y,z,a,b,c,d,e,f| FINA050(x,y,z,a,b,c,d,e,f)}, aTit, nOpcx, nOpcx, /*bExecuta*/, /*aDadosBco*/, /*lExibeLanc*/, /*lOnline*/, aRatCC, aTitPrv)

            // Se houve erros no processamento do MSExecAuto
            If lMsErroAuto
               aErroAuto := GetAutoGRLog()

               cXMLRet := "<![CDATA["
               For nI := 1 To Len(aErroAuto)
                  cXMLRet += aErroAuto[nI] + Chr(10)
               Next nI
               cXMLRet += "]]>"

               lRet := .F.
            Else
               // Grava o registro na tabela XXF (de/para)
               CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F., 1)
               CFGA070Mnt(cMarca, cAlias, cField, cValExt2, cValInt2, .F., 1)

               // Monta o XML de retorno
               cXMLRet := "<ListOfInternalId>"
               cXMLRet +=    "<InternalId>"
               cXMLRet +=       "<Name>" + "TemporaryAccountPayableDocumentInternalId" + "</Name>"
               cXMLRet +=       "<Origin>" + cValExt + "</Origin>"
               cXmlRet +=       "<Destination>" + cValInt + "</Destination>"
               cXMLRet +=    "</InternalId>"
               cXMLRet +=    "<InternalId>"
               cXMLRet +=       "<Name>" + "OriginalAccountPayableDocumentInternalId" + "</Name>"
               cXMLRet +=       "<Origin>" + cValExt2 + "</Origin>"
               cXmlRet +=       "<Destination>" + cValInt2 + "</Destination>"
               cXMLRet +=    "</InternalId>"
               cXMLRet += "</ListOfInternalId>"
            EndIf
         Else
            lRet    := .F.
            cXmlRet := STR0019 //"Erro no parser!"
            IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
            Return {lRet, cXmlRet}
         EndIf
      ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
         lRet := .F.
         cXMLRet := STR0020 //"Resposta não implementada."
      ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
         cXMLRet += "1.000"
      EndIf
   ElseIf nTypeTrans == TRANS_SEND
      lRet := .F.
      cXMLRet := STR0021 //"Envio não implementado."
   EndIf

   IIf(lLog, AdpLogEAI(5, "FINI050A", cXMLRet, lRet), ConOut(STR0001))
Return {lRet, cXMLRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} RatCAP
Recebe a chave de busca do Titulo a Pagar e monta o rateio.

@author  Leandro Luiz da Cruz
@version P11
@since   20/03/2013

@return aResult

@obs Alterar também o fonte FINI050
/*/
//-------------------------------------------------------------------
Static Function RatCAP(cChave)
   Local aResult  := {}
   Local aPrjtTrf := {}
   Local aCntrCst := {}

   AFR->(dbSetOrder(2)) // Rateio por Projeto/Tarefa - AFR_FILIAL+AFR_PREFIX+AFR_NUM+AFR_PARCEL+AFR_TIPO+AFR_FORNEC+AFR_LOJA+AFR_PROJET+AFR_REVISA+AFR_TAREFA
   CV4->(dbSetOrder(1)) // Rateios por Centro de Custo - CV4_FILIAL+DTOS(CV4_DTSEQ)+CV4_SEQUEN

   //Povoa o array de Projeto
   If AFR->(dbSeek(cChave))
      While !AFR->(Eof()) .And. cChave == AFR->AFR_FILIAL + AFR->AFR_PREFIX + AFR->AFR_NUM + AFR->AFR_PARCEL + AFR->AFR_TIPO + AFR->AFR_FORNEC + AFR->AFR_LOJA
         aAdd(aResult, AFR->AFR_PROJET)
         aAdd(aResult, AFR->AFR_REVISA)
         aAdd(aResult, AFR->AFR_TAREFA)
         aAdd(aResult, AFR->AFR_VALOR1)
         aAdd(aPrjtTrf, aResult)

         AFR->(dbSkip())
      EndDo
   EndIf

   cChave := AllTrim(SE2->E2_ARQRAT)
   aResult := {}

   //Povoa o array de Centro de Custo
   If Upper(SE2->E2_RATEIO) == 'S' //Possui rateio de centro de custo
      If CV4->(dbSeek(cChave))
         While CV4->(!Eof()) .And. CV4->CV4_FILIAL+DTOS(CV4->CV4_DTSEQ)+CV4->CV4_SEQUEN == cChave
            aAdd(aResult, CV4->CV4_CCD)
            aAdd(aResult, CV4->CV4_DEBITO)
            aAdd(aResult, CV4->CV4_ITEMD)
            aAdd(aResult, CV4->CV4_CLVLDB)
            aAdd(aResult, CV4->CV4_PERCEN)
            aAdd(aCntrCst, aResult)

            CV4->(dbSkip())
         EndDo
      EndIf
   EndIf

   If Len(aCntrCst) == 0
      aAdd(aCntrCst,{SE2->E2_CCD, SE2->E2_DEBITO, SE2->E2_ITEMD, SE2->E2_CLVLDB, 100})
   EndIf

   If Len(aPrjtTrf) == 0
      aAdd(aPrjtTrf, {SE2->E2_PROJETO, Nil, Nil, SE2->E2_VALOR})
   EndIf

   aResult := IntRatPrjCC(aCntrCst, aPrjtTrf)
Return aResult
