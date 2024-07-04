#Include 'Protheus.ch'  
#Include 'FWAdapterEAI.ch'
#Include 'PMSI201.ch'

#Define CRLF Chr(10) + Chr(13)

//--------------------------------------------------------------------
/*/{Protheus.doc} PMSI201A
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de Obras/Etapas (AFC) utilizando o conceito de mensagem unica.

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   nTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   11/07/2012
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem Xml para envio

@obs     O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
         o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
         TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
         O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------

Function PMSI201A(cXML, nTypeTrans, cTypeMessage)
   Local lRet             := .T.                       //
   Local cXMLRet          := ""                        //
   Local cError           := ""                        //
   Local cWarning         := ""                        //
   Local aEDT             := {}                        //
   Local aAltEDT          := {}                        //
   Local cCompanyID       := ""                        //
   Local cBranchId        := ""                        //
   Local cEmpresa         := ""                        //
   Local aEmpFil          := {}                        //
   Local cFilial          := ""                        //
   Local cCode            := ""                        //
   Local cProduct         := ""                        //
   Local cAlias           := "AFC"                     //
   Local cField           := "AFC_EDT"                 //
   Local cValInt          := ""                        //
   Local nOpcx            := 0                         //
   Local aErro            := {}                        //
   Local nCount           := 1                         //
   Local cEvent           := ""                        //
   Local cEntity          := ""                        //
   Local cProjeto         := ""                        //
   Local cProjetoId       := 0                         //
   Local cRevisao         := "0001"                    //
   Local cTemp            := ""                        //
   Local aMessages        := {}                        //
   Local cCalend	      := SuperGetMv("MV_INTCAL",,"001")

   Private oXml
   Private lMsErroAuto    := .F.
   Private lMsHelpAuto    := .T.
   Private lAutoErrNoFile := .T.

   //Mensagem de Entrada
   If nTypeTrans == TRANS_RECEIVE
      //Business Message
      If cTypeMessage == EAI_MESSAGE_BUSINESS
         // Faz o parse do xml em um objeto
         oXml := XmlParser(cXml, "_", @cError, @cWarning)

         // Se não houve erros
         If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
            // Verifica se a empresa foi informada
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CompanyId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CompanyId:Text)
               cCompanyID := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CompanyId:Text
            Else
               lRet    := .F.
               cXmlRet := STR0001 //O código da empresa é obrigatório!
               aAdd(aMessages, {cXMLRet , 1, Nil})
            EndIf

            // Verifica se a filial foi informada
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BranchId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BranchId:Text)
               cBranchId := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BranchId:Text
            Else
               lRet    := .F.
               cXmlRet := STR0002 //O código da filial é obrigatório!
               aAdd(aMessages, {cXMLRet , 1, Nil})
            EndIf

            // Verifica se o produto foi informada
            If Type("oXml:_TOTVSMessage:_MessageInformation:_Product:_Name:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_Name:Text)
               cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
            Else
               lRet    := .F.
               cXmlRet := STR0003 //O nome do produto é obrigatório!
               aAdd(aMessages, {cXMLRet , 1, Nil})
            EndIf

            // Verifica se a filial atual é a mesma filial de inclusão do cadastro
            If FindFunction("IntChcEmp")
               aAux := IntChcEmp(oXML, cAlias, cProduct)
               If !aAux[1]
                  lRet := aAux[1]
                  cXmlRet := aAux[2]
                  aAdd(aMessages, {cXMLRet , 1, Nil})
               EndIf
            EndIf

            // Verifica se a entidade foi informada
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Entity:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Entity:Text)
               cEntity := oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Entity:Text
            Else
               lRet    := .F.
               cXmlRet := STR0004 //O nome da mensagem (Entity) é obrigatório!
               aAdd(aMessages, {cXMLRet , 1, Nil})
            EndIf

            // Verifica se o InternalId foi informado
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
               cValExt := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
            Else
               lRet    := .F.
               cXmlRet := STR0005 //O código do InternalId é obrigatório!
               aAdd(aMessages, {cXMLRet , 1, Nil})
            EndIf

            // Código da EDT
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text)
               cCode := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text
               aAdd(aEDT, {"AFC_EDT", PadR(cCode, TamSX3("AFC_EDT")[1]), Nil})
            Else
               lRet    := .F.
               cXmlRet := STR0006 //O código da EDT (Etapa) é obrigatório!
               aAdd(aMessages, {cXMLRet , 1, Nil})
            EndIf

            //Pesquisa o IntenalId da Etapa
            cValInt := RTrim(CFGA070Int(cProduct, cAlias, cField, cValExt))

            // Verifica se o código do projeto foi informado
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ProjectInternalId:Text") == "U" .Or. Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ProjectInternalId:Text)
               lret    := .F.
               cXmlRet := STR0007 //O código do projeto não foi informado!
               aAdd(aMessages, {cXMLRet , 1, Nil})
            Else
               cProjetoId := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ProjectInternalId:Text
            EndIf

            // Procura o código do projeto na tabela de de/para
            aTemp := IntPrjInt(cProjetoId, cProduct)

            // Retorna um erro caso o projeto não seja encontrado
            If aTemp[1]
               cProjeto := aTemp[2][3]
            Else
               lret    := .F.
               cXmlRet := aTemp[2]
               aAdd(aMessages, {cXMLRet , 1, Nil})
            EndIf

            // Filial do EDT
            aAdd(aEDT, {"AFC_FILIAL", xFilial("AFC"), Nil})

            // Projeto do EDT
            aAdd(aEDT, {"AFC_PROJET", PadR(cProjeto, TamSX3("AF8_PROJET")[1]), Nil})

            // Revisão do Projeto
            aAdd(aEDT, {"AFC_REVISA", cRevisao, Nil})

            If Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
               If !Empty(cValInt)
                  nOpcx := 4 //Alteração
               Else
                  nOpcx := 3 //Inclusão

                  // Chave interna será empresa + filial + Projeto + revisão + código
                  cValInt := IntEDTExt(/*cEmpresa*/, /*cFil*/, cProjeto, cRevisao, cCode)[2]
               EndIf

               // Permite gerar PV/NFS?
               aAdd(aEDT, {"AFC_FATURA", "1", Nil})
               
               // Novo Calendário - Tabela AEG 
               If SuperGetMv("MV_PMSCALE" , .T. , .F. )
                  If !Empty(cCalend)
                     DbSelectArea("AEG")
                     AEG->(DbSetOrder(1))
                     If AEG->(DbSeek(xFilial("AEG") + PadR(cCalend,TamSx3("AEG_CODIGO")[1])))
                        aAdd(aEDT, {"AFC_CALEND", cCalend, Nil})
                     Else
                        lRet    := .F.
                        cXmlRet := "Calendario não cadastrado. (AEG)"
                        aAdd(aMessages, {cXMLRet , 1, Nil})
                     EndIf
                  Else
               	   lRet    := .F.
                     cXmlRet := "Calendario não informado no parametro MV_INTCAL"
                     aAdd(aMessages, {cXMLRet , 1, Nil})
                  EndIf  
               Else // Calendário - Tabela SH7 / SH9
                  aAdd(aEDT, {"AFC_CALEND", cCalend, Nil})
               EndIf
               
               // Nível da tarefa
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Level:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Level:Text)
                  aAdd(aEDT, {"AFC_NIVEL",  PadL(cValToChar(Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Level:Text) + 1), 3, '0'), Nil})
               EndIf

               // Nível Pai
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ParentNodeInternalId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ParentNodeInternalId:Text)
                  aTemp := IntEDTInt(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ParentNodeInternalId:Text, cProduct)

                  If aTemp[1]
                     aAdd(aEDT, {"AFC_EDTPAI", aTemp[2][5], Nil})
                  Else
                     lret    := .F.
                     cXmlRet := aTemp[2]
                     aAdd(aMessages, {cXMLRet , 1, Nil})
                  EndIf
               EndIf

               // Descrição do EDT
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text") == "U" .Or. Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text)
                  If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text") == "U" .Or. Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text)
                     lRet    := .F.
                     cXmlRet := STR0010 //A descrição da EDT (Obra/Etapa) é obrigatória!
                     aAdd(aMessages, {cXMLRet , 1, Nil})
                  Else
                     aAdd(aEDT, {"AFC_DESCRI", oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text, Nil})
                  EndIf
               Else
                  aAdd(aEDT, {"AFC_DESCRI", oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text, Nil})
               EndIf

               //Quantidade
               aAdd(aEDT, {"AFC_QUANT", 1.00, Nil})

               // Custo Unitário
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UnitCost:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UnitCost:Text)
                  aAdd(aEDT, {"AFC_CUSTO", Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UnitCost:Text), Nil})
               EndIf

               // Preço Total
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TotalValue:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TotalValue:Text)
                  aAdd(aEDT, {"AFC_TOTAL", Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TotalValue:Text), Nil})
               EndIf
            ElseIf Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
               nOpcx := 5 //Exclusão
            Else
               lRet    := .F.
               cXmlRet := STR0011 //O Event informado é inválido!
               aAdd(aMessages, {cXMLRet , 1, Nil})
            EndIf

            If lRet
               // Inicia transação
               Begin Transaction

               If nOpcx == 4
                  // Grava na tabela de EDT (Etapa)
                  dbSelectArea("AFC")
                  AFC->(dbSetOrder(1)) //AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDT+AFC_ORDEM

                  If AFC->(dbSeek(PadR(Separa(cValInt, "|")[2], TamSX3("AFC_FILIAL")[1]) + PadR(Separa(cValInt, "|")[3], TamSX3("AFC_PROJET")[1]) + PadR(Separa(cValInt, "|")[4], TamSX3("AFC_REVISA")[1]) + PadR(Separa(cValInt, "|")[5], TamSX3("AFC_EDT")[1])))
                     // Houve alteração do código do EDT
                     If AFC->AFC_EDT != cCode
                        aAdd(aAltEDT, {"AFC_PROJET",  AFC->AFC_PROJET, .F.}) // <-- código do projeto a qual a EDT pertence
                        aAdd(aAltEDT, {"AFC_FILIAL",  AFC->AFC_FILIAL, .F.}) // <-- filial da EDT
                        aAdd(aAltEDT, {"AFC_REVISA",  AFC->AFC_REVISA, .F.}) // <-- revisão do projeto
                        aAdd(aAltEDT, {"NEW_AFC_EDT", cCode,           .F.}) // <-- novo codigo para a EDT
                        aAdd(aAltEDT, {"AFC_EDT",     AFC->AFC_EDT,    .F.}) // <-- código atual da EDT

                        MSExecAuto({|x, y, z, a, b| PMSA201(x, y, z, a, b)}, 10, , , , aAltEDT) //<-- chamada da execauto - opcao 10

                        If lMsErroAuto
                           aErro := GetAutoGRLog()

                           lRet := .F.
                           cXMLRet := '<![CDATA['
                           For nCount := 1 To Len(aErro)
                              cXMLRet += aErro[nCount] + CRLF
                           Next nCount
                           cXMLRet += ']]>'
                           aAdd(aMessages, {cXMLRet , 1, Nil})
                        Else
                           //Exclui o de/para antigo
                           CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T., 1)
                           // Atualiza o InternalID
                           cValInt := IntEDTExt(/*cEmpresa*/, /*cFil*/, cProjeto, cRevisao, cCode)[2]
                           //Inclui o novo código no de/para
                           CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F., 1)

                           cXMLRet := '<ListOfInternalId>'
                           cXMLRet +=    '<InternalId>'
                           cXMLRet +=       '<Name>' + cEntity + '</Name>'
                           cXMLRet +=       '<Origin>' + cValExt + '</Origin>'
                           cXMLRet +=       '<Destination>' + cValInt + '</Destination>'
                           cXMLRet +=    '</InternalId>'
                           cXMLRet += '</ListOfInternalId>'
                        EndIf
                     EndIf
                  EndIf
               ElseIf nOpcx == 5
                  ExcluiFilhos(cProjeto, cRevisao, cProduct, cCode)
               EndIf

				 If !lMsErroAuto
	               // Executa comando para insert, update ou delete conforme evento
	               MSExecAuto({|a, b, c, d, e, f| PMSA201(a, b, c, d, e, f)}, nOpcx, , , , aEDT, )
	
	               // Se houve erros no processamento do MSExecAuto
	               If lMsErroAuto
	                  aErro := GetAutoGRLog()
	
	                  lRet := .F.
	                  cXMLRet := '<![CDATA['
	                  For nCount := 1 To Len(aErro)
	                     cXMLRet += aErro[nCount] + CRLF
	                  Next nCount
	                  cXMLRet += ']]>'
	                  aAdd(aMessages, {cXMLRet , 1, Nil})
	
	                  // Cancela transação
	                  DisarmTransaction()
	               Else
	                  If nOpcx == 5
	                     CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T., 1)
	                  ElseIf nOpcx == 3
	                     CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F., 1)
	                  EndIf
	
	                  cXMLRet := '<ListOfInternalId>'
	                  cXMLRet +=    '<InternalId>'
	                  cXMLRet +=       '<Name>' + cEntity + '</Name>'
	                  cXMLRet +=       '<Origin>' + cValExt + '</Origin>'
	                  cXMLRet +=       '<Destination>' + cValInt + '</Destination>'
	                  cXMLRet +=    '</InternalId>'
	                  cXMLRet += '</ListOfInternalId>'
	
	                  // Confirma transação
	                  EndTran()
	               EndIf
				 EndIf
				 If lMsErroAuto
		           // Cancela transação
		           DisarmTransaction()
				 EndIf
				 // Confirma transação
				 End Transaction 
            EndIf
         Else
            lRet    := .F.
            cXmlRet := STR0012 //Erro ao parsear xml!
            aAdd(aMessages, {cXMLRet , 1, Nil})
         EndIf
      ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
         lRet    := .F.
         cXmlRet := "Resposta não implementada."
         aAdd(aMessages, {cXMLRet , 1, Nil})
      ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
         cXMLRet := '2.000'
      EndIf
   ElseIf nTypeTrans == TRANS_SEND
      lRet    := .F.
      cXmlRet := "Envio não implementado."
      aAdd(aMessages, {cXMLRet , 1, Nil})
   EndIf

   If !lRet
      cXMLRet := ""

      For nCount := 1 To Len(aMessages)
         cXMLRet += aMessages[nCount][1] + CRLF
      Next nCount
   EndIf
Return {lRet, cXMLRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcluiFilhos
Recebe um projeto e exclui todos os filhos (EDT/Tarefa) do de/para.

@param   cProjeto Código do projeto.
@param   cRevisao Código da revisão.
@param   cEDT      Código do EDT.

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   03/0/2013
@return  lRet Variável indicando se a rotina foi executada com sucesso.
/*/
//-------------------------------------------------------------------
Static Function ExcluiFilhos(cProjeto, cRevisao, cProduct, cEDT)
   Local lRet     := .T.
   Local aAreaAFC := AFC->(GetArea())
   Local aAreaAF9 := AF9->(GetArea())
   Local cAlias   := ""
   Local cField   := ""
   LOcal cValInt  := ""
   Local cValExt  := ""

   cProjeto := PadR(cProjeto, TamSX3("AFC_PROJET")[1])
   cRevisao := PadR(cRevisao, TamSX3("AFC_REVISA")[1])
   cEDT     := PadR(cEDT, Len(AFC->AFC_EDTPAI))

   // Exclui os EDTs do de/para
   AFC->(dbSetOrder(2)) //AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDTPAI+AFC_ORDEM
   cAlias := "AFC"

   If AFC->(dbSeek(cFilAnt + cProjeto + cRevisao + cEDT))
      While AFC->AFC_FILIAL + AFC->AFC_PROJET + AFC->AFC_REVISA + AFC->AFC_EDTPAI  == cFilAnt + cProjeto + cRevisao + cEDT
         If Val(AFC->AFC_NIVEL) > 2
            cField  := "AFC_EDT"
            cValInt := IntEDTExt(cEmpAnt, cFilAnt, cProjeto, cRevisao, AFC->AFC_EDT, /*cVersao*/)[2]
            cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

            Cfga070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T., 1) //XXF_REFER+XXF_TABLE+XXF_ALIAS+XXF_FIELD+XXF_INTVAL+XXF_EXTVAL
         Else
            cField := "AFC_PROJET"
            cValInt := IntEDTExt(cEmpAnt, cFilAnt, cProjeto, AFC->AFC_REVISA, AFC->AFC_EDT, /*cVersao*/)[2]
            cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

            Cfga070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T., 1) //XXF_REFER+XXF_TABLE+XXF_ALIAS+XXF_FIELD+XXF_INTVAL+XXF_EXTVAL
         EndIf

         ExcluiFilhos(cProjeto, cRevisao, cProduct, AFC->AFC_EDT)

         AFC->(dbSkip())
      EndDo
   EndIf

   AF9->(dbSetOrder(2)) //AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_EDTPAI+AF9_ORDEM
   cAlias := "AF9"
   cField := "AF9_TAREFA"
   cEDT   := PadR(cEDT, Len(AF9->AF9_EDTPAI))

   If AF9->(dbSeek(cFilAnt + cProjeto + cRevisao + cEDT))
      While AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_EDTPAI == cFilAnt + cProjeto + cRevisao + cEDT
         cValInt := IntTrfExt(cEmpAnt, cFilAnt, cProjeto, AF9->AF9_REVISA, AF9->AF9_TAREFA, /*cVersao*/)[2]
         cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

         CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T., 1) //XXF_REFER+XXF_TABLE+XXF_ALIAS+XXF_FIELD+XXF_INTVAL+XXF_EXTVAL

         AF9->(dbSkip())
      EndDo
   EndIf

   RestArea(aAreaAFC)
   RestArea(aAreaAF9)
Return lRet