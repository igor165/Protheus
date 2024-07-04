#Include 'Protheus.ch'  
#Include 'FWAdapterEAI.ch'
#Include 'PMSI203.ch'

#Define ERR 1
#Define WAR 2
#Define CRLF Chr(10) + Chr(13)

//--------------------------------------------------------------------
/*/{Protheus.doc} PMSI203
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de tarefas (AF9) utilizando o conceito de mensagem unica.

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   nTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   11/07/2012
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execu��o da fun��o
         aRet[2] - (caracter) Mensagem Xml para envio

@obs     O m�todo ir� retornar um objeto do tipo TOTVSBusinessEvent caso
         o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
         TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
         O tipo da classe pode ser definido com a fun��o EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------
Function PMSI203(cXML, nTypeTrans, cTypeMessage)
   Local lRet             := .T.                       //
   Local cXMLRet          := ""                        //
   Local cError           := ""                        //
   Local cWarning         := ""                        //
   Local aTarefa          := {}                        //
   Local cCompanyID       := ""                        //
   Local cBranchId        := ""                        //
   Local cEmpresa         := ""                        //
   Local aEmpFil          := {}                        //
   Local cFilial          := ""                        //
   Local aTables          := {}                        //
   Local cCode            := ""                        //
   Local nShortCode       := 0                         //
   Local cProduct         := ""                        //
   Local cAlias           := "AF9"                     //
   Local cField           := "AF9_TAREFA"              //
   Local cValInt          := ""                        //
   Local nOpcx            := 0                         //
   Local aErro            := {}                        //
   Local nCount           := 1                         //
   Local cEvent           := ""                        //
   Local cEntity          := "TaskProject"             //
   Local cProjeto         := ""                        //
   Local cProjetoId       := 0                         //
   Local cRevisa          := "0001"                    //
   Local cUnMed           := ""                        //
   Local aAux             := {}                        //
   Local aAltTrf          := {}                        //
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

         // Se n�o houve erros
         If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
            // Verifica se a empresa foi informada
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CompanyId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CompanyId:Text)
               cCompanyID := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CompanyId:Text
            Else
               lRet    := .F.
               cXmlRet := STR0001 //O c�digo da empresa � obrigat�rio!
               aAdd(aMessages, {cXMLRet , 1, Nil})
            EndIf

            // Verifica se a filial foi informada
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BranchId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BranchId:Text)
               cBranchId := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BranchId:Text
            Else
               lRet    := .F.
               cXmlRet := STR0002 //O c�digo da filial � obrigat�rio!
               aAdd(aMessages, {cXMLRet , 1, Nil})
            EndIf

            cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_Name:Text

            // Verifica se a filial atual � a mesma filial de inclus�o do cadastro
            If FindFunction("IntChcEmp")
               aAux := IntChcEmp(oXML, cAlias, cProduct)
               If !aAux[1]
                  lRet := aAux[1]
                  cXmlRet := aAux[2]
                  aAdd(aMessages, {cXMLRet , 1, Nil})
               EndIf
            EndIf

            // Verifica se o InternalId foi informado
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
               cValExt := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
            Else
               lRet    := .F.
               cXmlRet := STR0003 //O c�digo do InternalId � obrigat�rio!
               aAdd(aMessages, {cXMLRet , 1, Nil})
            EndIf

            // C�digo da tarefa
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text)
               cCode := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text
            EndIf

            // Verifica se a tarefa foi informada
            If Empty(cCode)
               lRet    := .F.
               cXmlRet := STR0004 //O c�digo da tarefa � obrigat�rio!
               aAdd(aMessages, {cXMLRet , 1, Nil})
            EndIf

            // Verifica se o c�digo do projeto foi informado
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ProjectInternalId:Text") == "U" .Or. Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ProjectInternalId:Text)
               lret    := .F.
               cXmlRet := STR0005 //O InternalID do projeto n�o foi informado!
               aAdd(aMessages, {cXMLRet , 1, Nil})
            Else
               cProjetoId := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ProjectInternalId:Text
            EndIf

            // Procura o c�digo do projeto na tabela de de/para
            aAux := IntPrjInt(cProjetoId, cProduct)

            // Retorna um erro caso o projeto n�o seja encontrado
            If !aAux[1]
               lret    := .F.
               cXmlRet := aAux[2]
               aAdd(aMessages, {cXMLRet , 1, Nil})
            Else
               cProjeto := aAux[2][3]
            EndIf

            //Pesquisa o IntenalId da tarefa
            cValInt := RTrim(CFGA070Int(cProduct, cAlias, cField, cValExt))

            // Filial do Produto
            aAdd(aTarefa, {"AF9_FILIAL", PadR(xFilial("AF9"), TamSX3("AF9_FILIAL")[1]), Nil})

            // Projeto da Tarefa
            aAdd(aTarefa, {"AF9_PROJET", PadR(cProjeto, TamSX3("AF9_PROJET")[1]), Nil})

            // Revis�o do Projeto
            aAdd(aTarefa, {"AF9_REVISA", cRevisa, Nil})

            // C�digo da tarefa
            aAdd(aTarefa, {"AF9_TAREFA", PadR(cCode, TamSX3("AF9_TAREFA")[1]), Nil})

            If Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
                If !Empty(cValInt)
                  nOpcx := 4 //Altera��o
                Else
                  nOpcx := 3 //Inclus�o

                  // Chave interna ser� filial + c�digo
                  cValInt := IntTrfExt(cEmpAnt, xFilial("AF9"), cProjeto, cRevisa, cCode)[2]

                  // Permite gerar PV/NFS?
                  aAdd(aTarefa, {"AF9_FATURA", "1", Nil})
                  
                  // Novo Calend�rio - Tabela AEG 
                  If SuperGetMv("MV_PMSCALE" , .T. , .F. )
	                If !Empty(cCalend)
		              	DbSelectArea("AEG")
	    	           	AEG->(DbSetOrder(1))
	       	        	If AEG->(DbSeek(xFilial("AEG") + PadR(cCalend,TamSx3("AEG_CODIGO")[1])))
	           	    		aAdd(aTarefa, {"AF9_CALEND", cCalend, Nil})
	              	 	Else
	               			lRet    := .F.
		                	cXmlRet := "Calendario n�o cadastrado. (AEG)"
		                	aAdd(aMessages, {cXMLRet , 1, Nil})
		          		EndIf
			        Else
	    		        lRet    := .F.
	           		    cXmlRet := "Calendario n�o informado no parametro MV_INTCAL"
	                	aAdd(aMessages, {cXMLRet , 1, Nil})
	              	EndIf
	              Else // Calend�rio - Tabela SH7 / SH9 
	           		aAdd(aTarefa, {"AF9_CALEND", cCalend, Nil})
	           	  EndIf 
                EndIf
               // Verifica se a descri��o da tarefa foi informada
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text") == "U" .Or. Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text)
                  If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text") == "U" .Or. Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text)
                     lRet    := .F.
                     cXmlRet := STR0007 //A descri��o da tarefa � obrigat�ria!
                     aAdd(aMessages, {cXMLRet , 1, Nil})
                  Else
                     aAdd(aTarefa, {"AF9_DESCRI", oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text, Nil})
                  EndIf
               Else
                  aAdd(aTarefa, {"AF9_DESCRI", oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text, Nil})
               EndIf

               // N�vel da tarefa
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Level:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Level:Text)
                  aAdd(aTarefa, {"AF9_NIVEL", PadL(cValToChar(Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Level:Text) + 1), 3, '0'), Nil})
               Else
                  lret    := .F.
                  cXmlRet := STR0008 //O n�vel da tarefa n�o foi informado!
                  aAdd(aMessages, {cXMLRet , 1, Nil})
               EndIf

               // N�vel Pai
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ParentNode:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ParentNode:Text)
                    aAux := IntEDTInt(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ParentNodeInternalId:Text, cProduct)

                    If aAux[1]
                       aAdd(aTarefa, {"AF9_EDTPAI", aAux[2][5], Nil})
                    Else
                       lRet := .F.
                       cXmlRet := aAux[2]
                       aAdd(aMessages, {cXMLRet , 1, Nil})
                    EndIf
               Else
                  lret    := .F.
                  cXmlRet := STR0010 //O n�vel superior n�o foi informado!
                  aAdd(aMessages, {cXMLRet , 1, Nil})
               EndIf

               // Unidade de Medida
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UnitOfMeasureInternalId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UnitOfMeasureInternalId:Text)
                   aAux := IntUndInt(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UnitOfMeasureInternalId:Text, cProduct)

                   If !aAux[1]
                      lRet := aAux[1]
                      cXmlRet := aAux[2]
                      aAdd(aMessages, {cXMLRet , 1, Nil})
                   Else
                      aAdd(aTarefa, {"AF9_UM", aAux[2][3], Nil})
                   EndIf
               Else
                   lRet := .F.
                   cXmlRet := STR0012 //O InternalId da Unidade de Medida n�o foi informado!
                   aAdd(aMessages, {cXMLRet , 1, Nil})
               EndIf

               // Quantidade
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Amount:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Amount:Text)
                  aAdd(aTarefa, {"AF9_QUANT", Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Amount:Text), Nil})
               EndIf

               // Custo Unit�rio
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UnitCost:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UnitCost:Text)
                  aAdd(aTarefa, {"AF9_CUSTO", Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UnitCost:Text), Nil})
               EndIf

               // Valor Total
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TotalValue:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TotalValue:Text)
                  aAdd(aTarefa, {"AF9_TOTAL", Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TotalValue:Text), Nil})
               EndIf
            ElseIf Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
               nOpcx := 5 //Exclus�o
            Else
               lRet    := .F.
               cXmlRet := STR0013 //O Event informado � inv�lido!
               aAdd(aMessages, {cXMLRet , 1, Nil})
            EndIf

            If lRet
               If nOpcx == 4
                  // Posiciona no registro a ser alterado
                  dbSelectArea("AF9")
                  dbSetOrder(1)

                  If AF9->(MsSeek(PadR(Separa(cValInt, "|")[2], TamSX3("AF9_FILIAL")[1]) + PadR(Separa(cValInt, "|")[3], TamSX3("AF9_PROJET")[1]) + PadR(Separa(cValInt, "|")[4], TamSX3("AF9_REVISA")[1]) + PadR(Separa(cValInt, "|")[5], TamSX3("AF9_TAREFA")[1])))
                     // Houve troca de c�digo?
                     If AF9->AF9_TAREFA != cCode
                        // Chama a rotina autom�tica para a troca de c�digo
                        aAdd(aAltTrf, {"AF9_FILIAL",     xFilial("AF9"),  .F.})         //<-- codigo da filial da terefa
                        aAdd(aAltTrf, {"AF9_PROJET",     cProjeto,        .F.})         //<-- codigo do projeto da tarefa
                        //aAdd(aAltTrf, {"AF9_REVISA",     cRevisa,         .F.})         //<-- codigo da revisao
                        aAdd(aAltTrf, {"NEW_AF9_TAREFA", cCode,           .F.})         //<-- codigo novo para a tarefa
                        aAdd(aAltTrf, {"AF9_TAREFA",     AF9->AF9_TAREFA, .F.})         //<-- codigo atual da tarefa

                        MSExecAuto({|x, y, z, a| PMSA203(x, y, z, a)}, 10, , , aAltTrf) //<-- chamada da execauto - opcao 10

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
                           cValInt := IntTrfExt(cEmpAnt, xFilial("AF9"), cProjeto, cRevisa, cCode)[2]
                        EndIf
                     EndIf
                  EndIf
               EndIf

               // Executa comando para insert, update ou delete conforme evento
               MSExecAuto({|a, b, c, d, e, f, g, h, i, j, k, l, m| PMSA203(a, b, c, d, e, f, g, h, i, j, k, l, m)}, nOpcx, , , aTarefa, , , , , , , , , )

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
               Else
                  If nOpcx == 5
                     CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T., 1)
                  Else
                     CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F., 1)
                  EndIf

                  cXMLRet := '<ListOfInternalId>'
                  cXMLRet +=    '<InternalId>'
                  cXMLRet +=       '<Name>' + cEntity + '</Name>'
                  cXMLRet +=       '<Origin>' + cValExt + '</Origin>'
                  cXMLRet +=       '<Destination>' + cValInt + '</Destination>'
                  cXMLRet +=    '</InternalId>'
                  cXMLRet += '</ListOfInternalId>'
               EndIf
            EndIf
         Else
            lRet    := .F.
            cXmlRet := STR0014 //Erro ao parsear xml!
            aAdd(aMessages, {cXMLRet , 1, Nil})
         EndIf
      ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
         lRet    := .F.
         cXmlRet := "Resposta n�o implementada."
         aAdd(aMessages, {cXMLRet , 1, Nil})
      ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
         cXMLRet := '2.000'
      EndIf
   ElseIf nTypeTrans == TRANS_SEND
      lRet    := .F.
      cXmlRet := "Envio n�o implementado."
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
/*/{Protheus.doc} IntTrfExt
Monta o InternalID da Tarefa de acordo com o c�digo passado
no par�metro.

@param   cEmpresa   C�digo da empresa (Default cEmpAnt)
@param   cFil       C�digo da Filial (Default cFilAnt)
@param   cProjeto   C�digo do Projeto
@param   cRevisao   C�digo da Revis�o (Default 0001)
@param   cTarefa    C�digo da Tarefa
@param   cVersao    Vers�o da mensagem �nica (Default 2.000)

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   30/01/2013
@return  aResult Array contendo no primeiro par�metro uma vari�vel
         l�gica indicando se o registro foi encontrado.
         No segundo par�metro uma vari�vel string com o InternalID
         montado.

@sample  IntTrfExt(, , '0000000001', '0001', '001') ir� retornar
{.T., '01|01|0000000001|0001|001'}
/*/
//-------------------------------------------------------------------
Function IntTrfExt(cEmpresa, cFil, cProjeto, cRevisao, cTarefa, cVersao)
   Local   aResult  := {}
   Default cEmpresa := cEmpAnt
   Default cFil     := xFilial('AF9')
   Default cRevisao := '0001'
   Default cVersao  := '2.000'

   If cVersao == '2.000'
      aAdd(aResult, .T.)
      aAdd(aResult, cEmpresa + '|' + Rtrim(cFil) + '|' + Rtrim(cProjeto) + '|' + Rtrim(cRevisao) + '|' + Rtrim(cTarefa))
   Else
      aAdd(aResult, .F.)
      aAdd(aResult, STR0086 + CRLF + STR0090) // "Vers�o da EDT n�o suportada." "As vers�es suportadas s�o: 2.000"
   EndIf
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntTrfInt
Recebe um InternalID e retorna o c�digo da Tarefa.

@param   cInternalID InternalID recebido na mensagem.
@param   cRefer      Produto que enviou a mensagem
@param   cVersao     Vers�o da mensagem �nica (Default 2.000).

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   30/01/2013

@return  aResult Array contendo no primeiro par�metro uma vari�vel
         l�gica indicando se o registro foi encontrado no de/para.
         No segundo par�metro uma vari�vel array com a empresa,
         filial, o c�digo do projeto, a revis�o do projeto e o
         c�digo da Tarefa.

@obs     O produto (cRefer) pode ser obtido na tag
         oXml:_TOTVSMessage:_MessageInformation:_Product:_Name:Text

@sample  IntTrfInt('01|01|0000000001|0001|001.01.01', 'RM') ir�
retornar {.T., {'01', '01', '0000000001', '0001', '001.01.01'}}
/*/
//-------------------------------------------------------------------
Function IntTrfInt(cInternalID, cRefer, cVersao)
   Local   aResult  := {}
   Local   cAlias   := "AF9"
   Local   cField   := "AF9_TAREFA"
   Local   cTemp    := ""
   Local   aTemp    := {}

   Default cVersao  := '2.000'

   cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)

   If Empty(cTemp)
      aAdd(aResult, .F.)
      aAdd(aResult, STR0087 + AllTrim(cInternalID) + STR0088) // "Tarefa " + AllTrim(cInternalID) + " n�o encontrada no de/para!"
   Else
      If cVersao == '2.000'
         aAdd(aResult, .T.)
         aTemp := Separa(cTemp, '|')
         aAdd(aResult, aTemp)
      Else
         aAdd(aResult, .F.)
         aAdd(aResult, STR0086 + CRLF + STR0090) // "Vers�o da EDT n�o suportada." "As vers�es suportadas s�o: 2.000"
      EndIf
   EndIf
Return aResult
