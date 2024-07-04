#Include 'Protheus.ch'
#Include 'FWAdapterEAI.ch'
#Include 'PMSI200.ch'

#Define ERR 1
#Define WAR 2
#Define CRLF Chr(10) + Chr(13)

//-------------------------------------------------------------------
/*/{Protheus.doc} PMSI200
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de projetos (AF8, AFC) utilizando o conceito de mensagem unica.

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   nTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   28/06/2012
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem Xml para envio

@obs     O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
         o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
         TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
         O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------
Function PMSI200(cXML, nTypeTrans, cTypeMessage)
   Local lRet       := .T.
   Local cXMLRet    := ""
   Local cError     := ""
   Local cWarning   := ""
   Local aProjeto   := {}
   Local aAltPrj    := {}
   Local cCompanyID := ""
   Local cBranchId  := ""
   Local cEmpresa   := ""
   Local aEmpFil    := {}
   Local cFilial    := ""
   Local cCode      := ""
   Local nShortCode := 0
   Local cProduct   := ""
   Local cAlias     := "AF8"
   Local cField     := "AF8_PROJET"
   Local cValInt    := ""
   Local nOpcx      := 0
   Local cRevisa    := "0001"
   Local aErro      := {}
   Local nCount     := 1
   Local cEvent     := "upsert"
   Local cEntity    := "Project"
   Local aContratos := {}
   Local cProjAnt   := ""
   Local aMessages  := {}
   Local cCalend	:= SuperGetMv("MV_INTCAL",,"001")
   Local cCNODesc	:= ""
   Local cCNOCodExt := ""
   Local aRet		:= {}
   Local cSONGovId	:= ""
   Local cSONWorkId	:= ""
   Local cSONCodExt := ""
   Local cSONDesc	:= ""
   Local cAliasAF8	:= ""
   Local cAliasSC5	:= ""
   Local cAliasSF2	:= ""
   Local cCNOAntigo	:= ""
   Local aExcSON		:= {}
   
   Private oXml           := Nil
   Private lMsErroAuto    := .F.
   Private lMsHelpAuto    := .T.
   Private lAutoErrNoFile := .T.

   //Mensagem de Entrada
   If nTypeTrans == TRANS_RECEIVE
      //Business Message
      If cTypeMessage == EAI_MESSAGE_BUSINESS
         // Faz o parse do xml em um objeto
         oXml := xmlParser(cXml, "_", @cError, @cWarning)

         // Verifica se a mensagem recebida é uma mensagem de projeto ou de contrato
         If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
            // Verifica se a empresa foi informada
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CompanyId:Text") != "U" .Or. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CompanyId:Text)
               cCompanyID := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CompanyId:Text
            Else
               lRet    := .F.
               cXmlRet := STR0001 //O código da empresa é obrigatório!
               aAdd(aMessages, {cXMLRet , 1, Nil})
            EndIf

            // Verifica se a filial foi informada
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BranchId:Text") != "U" .Or. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BranchId:Text)
               cBranchId := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BranchId:Text
            Else
               lRet    := .F.
               cXmlRet := STR0002 //O código da filial é obrigatório!
               aAdd(aMessages, {cXMLRet , 1, Nil})
            EndIf

            // Código do Produto da Integração
            cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_Name:Text

            // Verifica se a filial atual é a mesma filial de inclusão do cadastro
            If FindFunction("IntChcEmp")
               aAux := IntChcEmp(oXML, cAlias, cProduct)
               If !aAux[1]
                  lRet := aAux[1]
                  cXmlRet := aAux[2]
                  aAdd(aMessages, {cXMLRet , 1, Nil})
               EndIf
            EndIf

            // Verifica se o projeto foi informado
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShortCode:Text") != "U" .Or. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShortCode:Text)
               nShortCode := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShortCode:Text
            Else
               lRet    := .F.
               cXmlRet := STR0003 //O código do projeto é obrigatório!
               aAdd(aMessages, {cXMLRet , 1, Nil})
            EndIf

            // Verifica se o InternalId foi informado
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .Or. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
               cValExt := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
            Else
               lRet    := .F.
               cXmlRet := STR0004 //O código do InternalId é obrigatório!
               aAdd(aMessages, {cXMLRet , 1, Nil})
            EndIf

            // Código do Projeto
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text") != "U" .Or. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text)
               // Existe uma limitação no Protheus para o tamanho do Code: 10 - O RM pode enviar até o tamanho 30
               If(Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text) <= TamSX3("AF8_PROJET")[1])
                  cCode := PadR(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text, TamSX3("AF8_PROJET")[1])
               Else
                  lRet := .F.
                  cXmlRet := STR0005 //O tamanho do Code não pode ultrapassar o limite configurado:
                  aAdd(aMessages, {cXMLRet , 1, Nil})
               EndIf
            EndIf

            // Filial do Produto
            aAdd(aProjeto, {"AF8_FILIAL", xFilial("AF8"), Nil})

            //Pesquisa o IntenalId do Projeto
            cValInt  := RTrim(CFGA070Int(cProduct, cAlias, cField, cValExt))

            // Verifica se o projeto foi informado
            If Empty(cCode)
               lRet    := .F.
               cXmlRet := STR0006 //O código do projeto é obrigatório!
               aAdd(aMessages, {cXMLRet , 1, Nil})
            Else
               aAdd(aProjeto, {"AF8_PROJET", PadR(cCode, TamSX3("AF8_PROJET")[1]), Nil})
            EndIf

            If Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
               If !Empty(cValInt)
                  nOpcx := 4 //Alteração

               Else
                  nOpcx := 3 //Inclusão

                  // Chave interna será filial + código
                  cValInt  := IntPrjExt(, , cCode)[2]
               EndIf

               // Versão do Projeto
               aAdd(aProjeto, {"AF8_REVISA", cRevisa, Nil})

               // Tipo do Projeto
               aAdd(aProjeto, {"AF8_TPPRJ", "0002", Nil})

               // Novo Calendário - Tabela AEG 
               If SuperGetMv("MV_PMSCALE" , .T. , .F. )
               	    If !Empty(cCalend)
                        DbSelectArea("AEG")
                        AEG->(DbSetOrder(1))
                        If AEG->(DbSeek(xFilial("AEG") + PadR(cCalend,TamSx3("AEG_CODIGO")[1])))
                            aAdd(aProjeto, {"AF8_CALEND", cCalend, Nil})
                        Else
                            lRet    := .F.
                            cXmlRet := STR0101 + " " + STR0112 + xFilial("AEG") + " " + STR0116 + PadR(cCalend,TamSx3("AEG_CODIGO")[1])//"Calendário não cadastrado. (AEG) Filial:##  Calendario:## 
                            aAdd(aMessages, {cXMLRet , 1, Nil})
                        EndIf
              	    Else
                        lRet    := .F.
                        cXmlRet := STR0102	//"Calendário não informado no parâmetro MV_INTCAL"
                        aAdd(aMessages, {cXMLRet , 1, Nil})
                    EndIf
               Else // Calendário - Tabela SH7 / SH9
      				aAdd(aProjeto, {"AF8_CALEND", cCalend, Nil})
               EndIf

               // Descrição do Projeto
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text") == "U" .Or. Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text)
                  If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text") == "U" .Or. Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text)
                     lRet    := .F.
                     cXmlRet := STR0007 //A descrição do projeto é obrigatório!
                     aAdd(aMessages, {cXMLRet , 1, Nil})
                  Else
                     aAdd(aProjeto, {"AF8_DESCRI", oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text, Nil})
                     cSONDesc		:= oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text
                  EndIf
               Else
                  aAdd(aProjeto, {"AF8_DESCRI", oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text, Nil})
                  cSONDesc		:= oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text
               EndIf

               // Verifica se a data do projeto foi informada
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text") == "U" .Or. Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text)
                  cData := Date()
               Else
                  cData := Stod(StrTran(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text, "-", ""))
               EndIf

               // Data do Projeto
               aAdd(aProjeto, {"AF8_DATA", cData, Nil})

               // Verifica se a data de início
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BeginDate:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BeginDate:Text)
                  aAdd(aProjeto, {"AF8_START", Stod(StrTran(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BeginDate:Text, "-", "")), Nil})
               EndIf

               // Verifica se a data de término
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinalDate:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinalDate:Text)
                  aAdd(aProjeto, {"AF8_FINISH", Stod(StrTran(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinalDate:Text, "-", "")), Nil})
               EndIf
               
               // Verifica se enviou código CNO
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WorkCode:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WorkCode:Text)
               	   cSONCodExt	:= AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WorkCode:Text)	
               EndIf
               
               //Verifica se enviou o Ind. Obra
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WorkId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WorkId:Text)
               	   cSONWorkId	:= AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WorkId:Text)
               EndIf	
               
               //Verifica se enviou o CPF\CNPJ
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WorkGovernmentalId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WorkGovernmentalId:Text)
               	   cSONGovId	:= AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WorkGovernmentalId:Text)
               EndIf	  
                            
            ElseIf Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
               nOpcx := 5 //Exclusão
            Else
               lRet    := .F.
               cXmlRet := STR0008 //O Event informado é inválido!
               aAdd(aMessages, {cXMLRet , 1, Nil})
            EndIf

            If lRet
               
               // Inicia transação
               Begin Transaction
               
               If cPaisloc == "BRA"
                  aRet := PMSI200WN( nOpcx, cCode, cSONCodExt, cSONDesc, cSONWorkId, cSONGovId )
                  
                  If aRet[1]
                        aAdd(aProjeto, {"AF8_CNO",aRet[2],Nil})
                  Else
                        DisarmTransaction()
                     lRet := .F.
                     aMessages := aRet[3]
                  EndIf
               EndIf
               
               If lRet 
               
	               //Realiza a troca de filial e troca de código do projeto
	               If nOpcx == 4
	                  // Posiciona no registro a ser alterado
	                  If AF8->(dbSeek(PadR(Separa(cValInt, "|")[2], TamSX3("AF8_FILIAL")[1]) + PadR(Separa(cValInt, "|")[3], TamSX3("AF8_PROJET")[1])))
	                     
                        If cPaisloc == "BRA"
	                        cCNOAntigo := AF8->AF8_CNO
	                     EndIf
                        
	                     // Houve troca de código?
	                     If AF8->AF8_PROJET != cCode
	                        // Troca o código do projeto
	                        cProjAnt := AF8->AF8_PROJET
	                        aAdd(aAltPrj, {"AF8_PROJET",     AF8->AF8_PROJET, .F.})
	                        aAdd(aAltPrj, {"NEW_AF8_PROJET", cCode,           .F.})
	
	                        MSExecAuto({|x, y| PMSA200(, , , x, y)}, aAltPrj, 10)
	
	                        If lMsErroAuto
	                           aErro := GetAutoGRLog()
	
	                           lRet := .F.
	                           cXMLRet := '<![CDATA['
	                           For nCount := 1 To Len(aErro)
	                              cXMLRet += cValToChar(aErro[nCount]) + CRLF
	                           Next nCount
	                           cXMLRet += ']]>'
	                           aAdd(aMessages, {cXMLRet , 1, Nil})
	
	                           // Cancela transação
	                           DisarmTransaction()
	                        Else
	                           aErro := UpdProjAtiv(cProjAnt, cCode, cProduct)
	
	                           // Busca os contratos com o novo código
	                           aContratos := CntPrj(cCode)
	
	                           If !aErro[1]
	                              // Cancela transação
	                              DisarmTransaction()
	
	                              lRet    := aErro[1]
	                              cXmlRet := aErro[2]
	                              aAdd(aMessages, {cXMLRet , 1, Nil})
	                           EndIf
	                        EndIf
	
	                        If lRet
	                           // Exclui o antigo InternalID
	                           CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T., 1)
	
	                           // Gera o novo código interno do projeto
	                           cValInt  := IntPrjExt(, , cCode)[2]
	                           CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F., 1)
	                        EndIf
	                     EndIf
	                  Else
	                     lRet    := .F.
	                     cXmlRet := STR0009 // "Projeto não encontrado na base de dados!"
	                     aAdd(aMessages, {cXMLRet , 1, Nil})
	                  EndIf
	               ElseIf nOpcx == 5
	                  If AF8->(dbSeek(PadR(Separa(cValInt, "|")[2], TamSX3("AF8_FILIAL")[1]) + PadR(Separa(cValInt, "|")[3], TamSX3("AF8_PROJET")[1])))
		                  cCNOAntigo := cCode 
		                  ExcluiFilhos(cCode, cRevisa, cProduct)	                  
	                  Endif
	               EndIf
	
	               If lret 
		               // Executa comando para insert, update ou delete conforme evento
		               MSExecAuto({|a, b, c, d, e, f| PMSA200(a, b, c, d, e, f)}, nOpcx, cRevisa, .F., aProjeto, nOpcx, aContratos)
		               
		               // Se houve erros no processamento do MSExecAuto
		               If lMsErroAuto
		                  aErro := GetAutoGRLog()
		
		                  lRet := .F.
		                  cXMLRet := '<![CDATA['
		                  For nCount := 1 To Len(aErro)
		                     cXMLRet += cValToChar(aErro[nCount]) + CRLF
		                  Next nCount
		                  cXMLRet += ']]>'
		                  aAdd(aMessages, {cXMLRet , 1, Nil})
		
		                  // Cancela transação
		                  DisarmTransaction()
		               Else
		                  // Atualiza o de/para
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
		               
                     If cPaisloc == "BRA"
                        //Verificação de relacionamentos (outras dependencias do CNO) 
                        If (nOpcx == 4 .And. !Empty(cCNOAntigo) .And. AF8->AF8_CNO <> cCNOAntigo) .OR. (nOpcx == 5)
                           aExcSON := ExcSON(cCNOAntigo)
                           If !aExcSON[1]
                              lRet := .F.
                              aMessages := aExcSON[2]
                           EndIf
                        EndIf
                     EndIf
	               EndIf
               EndIf
               
               End Transaction
               
            EndIf
         Else
            lRet    := .F.
            cXmlRet := STR0010 //Erro ao parsear xml!
            aAdd(aMessages, {cXMLRet , 1, Nil})
         EndIf
      ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
         lRet    := .F.
         cXmlRet := STR0103	//"Resposta não implementada."
         aAdd(aMessages, {cXMLRet , 1, Nil})
      ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
         cXMLRet := '2.000'
      EndIf
   ElseIf nTypeTrans == TRANS_SEND
      lRet    := .F.
      cXmlRet := STR0104	//"Envio não implementado."
      aAdd(aMessages, {cXMLRet , 1, Nil})
   EndIf

   If !lRet
      cXMLRet := ""

      For nCount := 1 To Len(aMessages)
         cXMLRet += aMessages[nCount][1] + CRLF
      Next nCount
   EndIf
Return {lRet, cXMLRet, "PROJECT"}

//-------------------------------------------------------------------
/*/{Protheus.doc} IntPrjExt
Monta o InternalID do Projeto de acordo com o código passado
no parâmetro.

@param   cEmpresa   Código da empresa (Default cEmpAnt)
@param   cFil       Código da Filial (Default cFilAnt)
@param   cProjeto   Código do Projeto
@param   cVersao    Versão da mensagem única (Default 2.000)

@author  Leandro Luiz da Cruz
@version P11
@since   04/02/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado.
         No segundo parâmetro uma variável string com o InternalID
         montado.

@sample  IntPrjExt(, , '0000000001') irá retornar {.T., '01|01|0000000001'}
/*/
//-------------------------------------------------------------------
Function IntPrjExt(cEmpresa, cFil, cProjeto, cVersao)
   Local   aResult  := {}
   Default cEmpresa := cEmpAnt
   Default cFil     := xFilial('AF8')
   Default cVersao  := '2.000'

   If cVersao == '2.000'
      aAdd(aResult, .T.)
      aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cProjeto))
   Else
      aAdd(aResult, .F.)
      aAdd(aResult, STR0093 + CRLF + STR0094) //"Versão do projeto não suportada." "As versões suportadas são: 2.000"
   EndIf
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntPrjInt
Recebe um InternalID e retorna o código do Projeto.

@param   cInternalID InternalID recebido na mensagem.
@param   cRefer      Produto que enviou a mensagem
@param   cVersao     Versão da mensagem única (Default 2.000)

@author  Leandro Luiz da Cruz
@version P11
@since   04/02/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado no de/para.
         No segundo parâmetro uma variável array com a empresa,
         filial, o código do projeto e a revisão do projeto.

@sample  IntPrjInt('01|01|0000000001') irá retornar
{.T., {'01', '01', '0000000001'}}
/*/
//-------------------------------------------------------------------
Function IntPrjInt(cInternalID, cRefer, cVersao)
   Local   aResult  := {}
   Local   cAlias   := "AF8"
   Local   cField   := "AF8_PROJET"
   Local   cTemp    := ""
   Local   aTemp    := {}

   Default cVersao  := '2.000'

   cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)

   If Empty(cTemp)
      aAdd(aResult, .F.)
      aAdd(aResult, STR0098 + AllTrim(cInternalID) + STR0097) //"Projeto " " não encontrado no de/para!"
   Else
      If cVersao == '2.000'
         aAdd(aResult, .T.)
         aTemp := Separa(cTemp, '|')
         aAdd(aResult, aTemp)
      Else
         aAdd(aResult, .F.)
         aAdd(aResult, STR0093 + CRLF + STR0094) //"Versão do projeto não suportada." "As versões suportadas são: 2.000"
      EndIf
   EndIf
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} CntPrj
Recebe o código do projeto e retorna os contratos do projeto.

@param   cProjeto InternalID recebido na mensagem.

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   02/02/2013
@return  aContratos Array contendo todos os contratos cadastrados
                    para o projeto informado. Array no formato
                    {"ANE_CONTRA", ANE->ANE_CONTRA, Nil}
/*/
//-------------------------------------------------------------------
Static Function CntPrj(cProjeto)
   Local aContratos := {}
   Local aTemp      := {}
   Local aAreaANE   := {}

   If GetNewPar("MV_PMSITMU", "0") == "1"
      aAreaANE := ANE->(GetArea())

      dbSelectArea("ANE")
      dbSetOrder(1) // ANE_FILIAL+ANE_PROJET+ANE_REVISA+ANE_CONTRA

      If dbSeek(xFilial("ANE") + PadR(cProjeto, TamSX3("ANE_PROJET")[1]) + PadR("0001", TamSX3("ANE_REVISA")[1], "0"))
         While ANE->ANE_FILIAL == xFilial("ANE") .And. AllTRim(ANE->ANE_PROJET) == AllTRim(cProjeto) .And. ANE->ANE_REVISA == PadR("0001", TamSX3("ANE_REVISA")[1], "0")
            aTemp := {}
            aAdd(aTemp, {"ANE_CONTRA", ANE->ANE_CONTRA, Nil})
            aAdd(aContratos, aTemp)

            dbSkip()
         EndDo
      EndIf

      RestArea(aAreaANE)
   EndIf
Return aContratos

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcluiFilhos
Recebe um projeto e exclui todos os filhos (EDT/Tarefa) do de/para.

@param   cProjeto Código do projeto.
@param   cRevisao Código da revisão.

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   03/0/2013
@return  lRet Variável indicando se a rotina foi executada com sucesso.
/*/
//-------------------------------------------------------------------
Static Function ExcluiFilhos(cProjeto, cRevisao, cProduct)
   Local lRet     := .T.
   Local aAreaAFC := AFC->(GetArea())
   Local aAreaAF9 := AF9->(GetArea())
   Local aAreaANE := ANE->(GetArea())
   Local cAlias   := ""
   Local cField   := ""
   LOcal cValInt  := ""
   Local cValExt  := ""

   cProjeto := PadR(cProjeto, TamSX3("AF8_PROJET")[1])
   cRevisao := PadR(cRevisao, TamSX3("AF8_REVISA")[1])

   // Exclui os EDTs do de/para
   AFC->(dbSetOrder(1)) //AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDT+AFC_ORDEM
   cAlias := "AFC"

   If AFC->(dbSeek(cFilAnt + cProjeto + cRevisao))
      While AFC->AFC_FILIAL + AFC->AFC_PROJET + AFC->AFC_REVISA  == cFilAnt + cProjeto + cRevisao
         If Val(AFC->AFC_NIVEL) > 2
            cField  := "AFC_EDT"
            cValInt := IntEDTExt(cEmpAnt, cFilAnt, cProjeto, cRevisao, AFC->AFC_EDT, /*cVersao*/)[2]
            cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

            CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T., 1) //XXF_REFER+XXF_TABLE+XXF_ALIAS+XXF_FIELD+XXF_INTVAL+XXF_EXTVAL
         Else
            cField := "AFC_PROJET"
            cValInt := IntEDTExt(cEmpAnt, cFilAnt, cProjeto, AFC->AFC_REVISA, AFC->AFC_EDT, /*cVersao*/)[2]
            cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

            CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T., 1) //XXF_REFER+XXF_TABLE+XXF_ALIAS+XXF_FIELD+XXF_INTVAL+XXF_EXTVAL
         EndIf

         AFC->(dbSkip())
      EndDo
   EndIf

   AF9->(dbSetOrder(1)) //AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_TAREFA+AF9_ORDEM
   cAlias := "AF9"
   cField := "AF9_TAREFA"

   If AF9->(dbSeek(cFilAnt + cProjeto + cRevisao))
      While AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA == cFilAnt + cProjeto + cRevisao
         cValInt := IntTrfExt(cEmpAnt, cFilAnt, cProjeto, AF9->AF9_REVISA, AF9->AF9_TAREFA, /*cVersao*/)[2]
         cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

         CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T., 1) //XXF_REFER+XXF_TABLE+XXF_ALIAS+XXF_FIELD+XXF_INTVAL+XXF_EXTVAL

         AF9->(dbSkip())
      EndDo
   EndIf

   ANE->(dbSetOrder(1)) //ANE_FILIAL+ANE_PROJET+ANE_REVISA+ANE_CONTRA
   cAlias := "ANE"
   cField := "ANE_CONTRA"

   If ANE->(dbSeek(cFilAnt + cProjeto + cRevisao))
      While ANE->ANE_FILIAL + ANE->ANE_PROJET + ANE->ANE_REVISA == cFilAnt + cProjeto + cRevisao
         cValInt := IntCntExt(cEmpAnt, cFilAnt, cProjeto, ANE->ANE_REVISA, ANE->ANE_CONTRA, /*cVersao*/)[2]
         cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

         CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T., 1) //XXF_REFER+XXF_TABLE+XXF_ALIAS+XXF_FIELD+XXF_INTVAL+XXF_EXTVAL

         ANE->(dbSkip())
      EndDo
   EndIf

   RestArea(aAreaAFC)
   RestArea(aAreaAF9)
   RestArea(aAreaANE)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdProjAtiv
Função para atualizar o código do projeto na obra, na etapa e na tarefa.

@param   cProjAnt Código do Projeto original.
@param   cProj    Código do projeto.

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   08/10/2013

@return  aRet Array com uma variável lógica informando se o de/para
              foi atualizado com sucesso e um array com os erros.
/*/
//-------------------------------------------------------------------
Static Function UpdProjAtiv(cProjAnt, cProj, cProduct)
   Local nI         := 1            // Índice do for
   Local cXMLDePara := ""           // XML da mensagem InternalID
   Local cEvent     := "upsert"     // Operação a ser realizada (upsert/delete)
   Local cEntity    := "InternalId" // Nome da mensagem
   Local cValIntOld := ""           // IntenalID
   Local cValInt    := ""           // IntenalID
   Local cValExt    := ""           // ExternalID
   Local aArea      := GetArea()    // Guarda a área em uso
   Local aAreaAFC   := {}           // Guarda a área da tabela AFC
   Local aAreaAF9   := {}           // Guarda a área da tabela AF9
   Local aAreaANE   := {}           // Guarda a área da tabela ANE
   Local aRet       := {}           // Armazena o retorno da msg de InternalID
   Local aObra      := {}           // EDTs de nível 002
   Local aEtapa     := {}           // ETDs de nível > 002
   Local aTarefa    := {}           // Tarefas
   Local aContrato  := {}           // Contratos do Projeto
   Local aTemp      := {}           // Array auxiliar
   Local cAlias     := ""           // Alias da tabela
   Local cField     := ""           // Campo chave do de/para

   cProjAnt := PadR(cProjAnt, TamSX3("AF8_PROJET")[1])
   cProj    := PadR(cProj, TamSX3("AF8_PROJET")[1])

   //Dados de EDT (Obra/Etapa)
   aAreaAFC := AFC->(GetArea())
   dbSelectArea("AFC")
   AFC->(dbSetOrder(1))

   cAlias := "AFC"

   If AFC->(dbSeek(AF8->AF8_FILIAL + cProj))
      While AF8->AF8_FILIAL + cProj == AFC->AFC_FILIAL + AFC->AFC_PROJET .And. !AFC->(Eof())
         If Val(AFC->AFC_NIVEL) == 1
            AFC->(dbSkip())
            Loop
         EndIf

         cValIntOld := IntEDTExt(cEmpAnt, AFC->AFC_FILIAL, cProjAnt, AFC->AFC_REVISA, AFC->AFC_EDT, '2.000')[2]
         cValInt := IntEDTExt(cEmpAnt, AFC->AFC_FILIAL, cProj, AFC->AFC_REVISA, AFC->AFC_EDT, '2.000')[2]

         If Val(AFC->AFC_NIVEL) > 2
            cField := "AFC_EDT"
            cValExt := RTrim(CFGA070Ext(cProduct, cAlias, cField, cValIntOld))

            aAdd(aTemp, cValInt)
            aAdd(aTemp, cValExt)
            aAdd(aTemp, cValIntOld)

            aAdd(aEtapa, aTemp)
         Else
            cField := "AFC_PROJET"
            cValExt := RTrim(CFGA070Ext(cProduct, cAlias, cField, cValIntOld))

            aAdd(aTemp, cValInt)
            aAdd(aTemp, cValExt)
            aAdd(aTemp, cValIntOld)

            aAdd(aObra, aTemp)
         EndIf

         CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValIntOld, .T., 1)
         CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F., 1)

         aTemp := {}
         AFC->(dbSkip())
      EndDo
   EndIf

   aAreaAF9 := AF9->(GetArea())
   dbSelectArea("AFC")
   AFC->(dbSetOrder(1))

   cAlias := "AF9"
   cField := "AF9_TAREFA"

   If AF9->(dbSeek(AF8->AF8_FILIAL + cProj))
      While AF8->AF8_FILIAL + cProj == AF9->AF9_FILIAL + AF9->AF9_PROJET .And. !AF9->(Eof())
         cValIntOld := IntEDTExt(cEmpAnt, AF9->AF9_FILIAL, cProjAnt, AF9->AF9_REVISA, AF9->AF9_TAREFA, '2.000')[2]
         cValInt := IntEDTExt(cEmpAnt, AF9->AF9_FILIAL, cProj, AF9->AF9_REVISA, AF9->AF9_TAREFA, '2.000')[2]
         cValExt := RTrim(CFGA070Ext(cProduct, cAlias, cField, cValIntOld))

         aAdd(aTemp, cValInt)
         aAdd(aTemp, cValExt)
            aAdd(aTemp, cValIntOld)

         aAdd(aTarefa, aTemp)

         CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValIntOld, .T., 1)
         CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F., 1)

         aTemp := {}
         AF9->(dbSkip())
      EndDo
   EndIf

   aAreaANE := ANE->(GetArea())
   dbSelectArea("ANE")
   ANE->(dbSetOrder(1))

   cAlias := "ANE"
   cField := "ANE_CONTRA"

   If ANE->(dbSeek(AF8->AF8_FILIAL + cProj))
      While AF8->AF8_FILIAL + cProj == ANE->ANE_FILIAL + ANE->ANE_PROJET .And. !ANE->(EoF())
         cValIntOld := IntCntExt(cEmpAnt, ANE->ANE_FILIAL, cProjAnt, ANE->ANE_REVISA, ANE->ANE_CONTRA, '1.000')[2]
         cValInt := IntCntExt(cEmpAnt, ANE->ANE_FILIAL, cProj, ANE->ANE_REVISA, ANE->ANE_CONTRA, '1.000')[2]
         cValExt := RTrim(CFGA070Ext(cProduct, cAlias, cField, cValIntOld))

         aAdd(aTemp, cValInt)
         aAdd(aTemp, cValExt)
            aAdd(aTemp, cValIntOld)

         aAdd(aContrato, aTemp)

         CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValIntOld, .T., 1)
         CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F., 1)

         aTemp := {}
         ANE->(dbSkip())
      EndDo
   EndIf

   cXMLDePara := '<BusinessRequest>'
   cXMLDePara +=    '<Operation>' + cEntity + '</Operation>'
   cXMLDePara += '</BusinessRequest>'
   cXMLDePara += '<BusinessContent>'
   cXMLDePara +=    '<ListOfEntity>'
   If Len(aObra) > 0
      cXMLDePara +=    '<Entity>'
      cXMLDePara +=       '<Name>' + 'SubProject' + '</Name>'
      cXMLDePara +=       '<Event>' + cEvent + '</Event>'
      cXMLDePara +=       '<ListOfInternalId>'
      For nI := 1 To Len(aObra)
         cXMLDePara +=       '<InternalId>'
         cXMLDePara +=          '<Origin>' + aObra[nI][1] + '</Origin>'
         cXMLDePara +=          '<Destination>' + aObra[nI][2] + '</Destination>'
         cXMLDePara +=       '</InternalId>'
      Next nI
      cXMLDePara +=       '</ListOfInternalId>'
      cXMLDePara +=    '</Entity>'
   EndIf
   If Len(aEtapa) > 0
      cXMLDePara +=    '<Entity>'
      cXMLDePara +=       '<Name>' + 'StepProject' + '</Name>'
      cXMLDePara +=       '<Event>' + cEvent + '</Event>'
      cXMLDePara +=       '<ListOfInternalId>'
      For nI := 1 To Len(aEtapa)
         cXMLDePara +=       '<InternalId>'
         cXMLDePara +=          '<Origin>' + aEtapa[nI][1] + '</Origin>'
         cXMLDePara +=          '<Destination>' + aEtapa[nI][2] + '</Destination>'
         cXMLDePara +=       '</InternalId>'
      Next nI
      cXMLDePara +=       '</ListOfInternalId>'
      cXMLDePara +=    '</Entity>'
   EndIf
   If Len(aTarefa) > 0
      cXMLDePara +=    '<Entity>'
      cXMLDePara +=       '<Name>' + 'TaskProject' + '</Name>'
      cXMLDePara +=       '<Event>' + cEvent + '</Event>'
      cXMLDePara +=       '<ListOfInternalId>'
      For nI := 1 To Len(aTarefa)
         cXMLDePara +=       '<InternalId>'
         cXMLDePara +=          '<Origin>' + aTarefa[nI][1] + '</Origin>'
         cXMLDePara +=          '<Destination>' + aTarefa[nI][2] + '</Destination>'
         cXMLDePara +=       '</InternalId>'
      Next nI
      cXMLDePara +=       '</ListOfInternalId>'
      cXMLDePara +=    '</Entity>'
   EndIf
   If Len(aContrato) > 0
      cXMLDePara +=    '<Entity>'
      cXMLDePara +=       '<Name>' + 'Contract' + '</Name>'
      cXMLDePara +=       '<Event>' + cEvent + '</Event>'
      cXMLDePara +=       '<ListOfInternalId>'
      For nI := 1 To Len(aContrato)
         cXMLDePara +=       '<InternalId>'
         cXMLDePara +=          '<Origin>' + aContrato[nI][1] + '</Origin>'
         cXMLDePara +=          '<Destination>' + aContrato[nI][2] + '</Destination>'
         cXMLDePara +=       '</InternalId>'
      Next nI
      cXMLDePara +=       '</ListOfInternalId>'
      cXMLDePara +=    '</Entity>'
   EndIf
   cXMLDePara +=    '</ListOfEntity>'
   cXMLDePara += '</BusinessContent>'

   If Len(aObra) > 0 .Or. Len(aEtapa) > 0 .Or. Len(aTarefa) > 0 .Or. Len(aContrato) > 0
      // Envia a mensagem de alteração de InternalID em uma nova thread
      // O EAI Protheus impede que um adapter chame outro adapter para enviar uma mensagem
      // na mesma pilha de execução
      aRet := EnvInternalID(cXMLDePara, TRANS_SEND, EAI_MESSAGE_BUSINESS)
   Else
      aRet := {.T., ""}
   EndIf

   If ValType(aRet) != 'A'
      aRet := {.F., STR0105}	//"Mensagem InternalID não pode ser enviada!"
   EndIf

   RestArea(aArea)
   RestArea(aAreaAFC)
   RestArea(aAreaAF9)
   RestArea(aAreaANE)
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} EnvInternalID
Função para atualizar o código do projeto na obra, na etapa e na tarefa.

@param   cXML          XML com o conteúdo da mensagem.
@param   nTypeTrans   Tipo de envio (Send/Receive).
@param   cTypeMessage Tipo de Mensagem (Business/Response/Receipt/WhoIs).

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   08/10/2013

@return  aRet Array com uma variável lógica informando se o de/para
              foi atualizado com sucesso e um array com os erros.
/*/
//-------------------------------------------------------------------
Static Function EnvInternalID(cXML, nTypeTrans, cTypeMessage)
   Local oServer    := Nil
   Local cRpcServer := GetServerIp()
   Local nRPCPort   := Val(GetPvProfString("TCP", "Port", "\\undefined", GetAdv97()))
   Local cRPCEnv    := GetEnvServer()
   Local uRet       := Nil

   // Criando objeto do tipo tRpc
   oServer := TRPC():New(cRPCEnv)

   // Conectando ao servidor
   If oServer:Connect(cRpcServer, nRPCPort)
      // Executando Funcao
      uRet := oServer:CallProc("PMSA200B", cXML, nTypeTrans, cTypeMessage, cEmpAnt, cFilAnt)

      oServer:Disconnect()
   Else
      ConOut(STR0106 + cRPCServer)	//"Conexao indisponivel com o servidor: "
   EndIf
Return uRet

Function PMSI200WN(nOpcProj, cCodeProj, cSONCodExt, cSONDesc, cSONWorkId, cSONGovId )
Local aArea			:= GetArea()
Local aAreaSON		:= SON->(GetArea())
Local aAreaAF8		:= AF8->(GetArea())
Local lRet 			:= .T.
Local nOpc			:= 3
Local aWorkNat		:= {}
Local aErro			:= {}
Local aMessages		:= {}	
Local cXMLRet		:= ""
Local cSONInt		:= ""
Local nCount		:= 0
Local lExec			:= .F.	

Private lMsErroAuto	:= .F.
	
If nOpcProj == 4 .Or. nOpcProj == 5
	AF8->(DBSetOrder(1))
	If AF8->(DBSeek(xFilial("AF8")+cCodeProj))
		SON->(DBSetOrder(1)) //SON_FILIAL+SON_CODIGO
			
		If !Empty(cSONCodExt)
			If AF8->AF8_CNO <> cSONCodExt
				SON->(DBSetOrder(3))
				If SON->(DBSeek(xFilial("SON")+cSonCodExt))
					aAdd(aWorkNat,{"ON_CODIGO"	,SON->ON_CODIGO,Nil})
					nOpc := 4
				Else
					nOpc := 3						
				EndIf
				lExec := .T.	
			EndIf
		EndIf	
	EndIf
	
ElseIf nOpcProj == 3 .And. !Empty(cSONCodExt)

	SON->(DBSetOrder(3))
	If SON->(DBSeek(xFilial("SON")+cSonCodExt))
		aAdd(aWorkNat,{"ON_CODIGO"	,SON->ON_CODIGO,Nil})
		nOpc := 4
	EndIf

	lExec := .T.	
EndIf

If lExec
	aAdd(aWorkNat,{"ON_DESC"	,cSONDesc	,Nil})
	aAdd(aWorkNat,{"ON_IDOBRA"	,cSONWorkId	,Nil})
	aAdd(aWorkNat,{"ON_CNO"		,cSONCodExt ,Nil}) 
	
	If Len(cSONGovId) == 14 
		aAdd(aWorkNat,{"ON_TIPO"	,"1"	,Nil})
	Else
		aAdd(aWorkNat,{"ON_TIPO"	,"2"	,Nil})
	EndIf
	
	If cSONWorkId = "0"
		aAdd(aWorkNat,{"ON_TPINSCR"	,"1"	,Nil})
	ElseIf cSONWorkId $ "1|2"
		aAdd(aWorkNat,{"ON_TPINSCR"	,"4"	,Nil})
	EndIf
	
	aAdd(aWorkNat,{"ON_CGC"	,cSONGovId		,Nil})
	
	MSExecAuto({|x, y| MATA322(x, y)}, nOpc, aWorkNat)
	
	If lMsErroAuto
	   aErro := GetAutoGRLog()
	   lRet := .F.
	   cXMLRet := '<![CDATA['
	   For nCount := 1 To Len(aErro)
	      cXMLRet += cValToChar(aErro[nCount]) + CRLF
	   Next nCount
	   cXMLRet += ']]>'
	   aAdd(aMessages, {cXMLRet , 1, Nil})
	Else
	  If nOpc != 5
	  	 SON->(DBSetOrder(3))
	  	 If SON->(DBSeek(xFilial("SON")+cSONCodExt)) //Garante que estará posicionado no registro certo.
	  	 	cSONInt := SON->ON_CODIGO
	  	 EndIf
	  EndIf
	EndIf  
EndIf

RestArea(aAreaAF8)
RestArea(aAreaSON)
RestArea(aArea)

Return({lRet,cSONInt,aMessages})
