#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "MATI650.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MATI650

Funcao de integracao com o adapter EAI para recebimento do  cadastro de
Ordem de produção (SC2) utilizando o conceito de mensagem unica.

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   nTypeTrans    Tipo de transação. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)
@param   cVersao       Versão da mensagem recebida pelo EAI.

@author  Lucas Konrad França
@version P12
@since   02/09/2015
@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio
       aRet[3] - (caracter) Nome da mensagem

@obs    O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
        o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
        TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
        O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------------------------------------
Function MATI650(cXml, nTypeTrans, cTypeMessage, cVersao)
   Local lRet        := .T.
   Local cXmlRet     := ""
   Local cError      := ""
   Local cWarning    := ""
   Local aRet        := {.T.,"","PRODUCTIONORDER"}
   
   Private lIntegPPI := .F.
   Private oXml      := Nil

   //Verifica se está sendo executado para realizar a integração com o PPI.
   //Se a variável lRunPPI estiver definida, e for .T., assume que é para o PPI.
   //Variável é criada no fonte mata650.prx, na função MATA650PPI().
   If Type("lRunPPI") == "L" .And. lRunPPI
      lIntegPPI := .T.
   EndIf

   //Mensagem de Entrada
   If nTypeTrans == TRANS_RECEIVE
      If cTypeMessage == EAI_MESSAGE_BUSINESS .Or. cTypeMessage == EAI_MESSAGE_RESPONSE
         //Faz o PARSE do XML
         oXml := xmlParser(cXml, "_", @cError, @cWarning)
         If ! (oXml != Nil .And. Empty(cError) .And. Empty(cWarning))
            Return{.F.,STR0007,"PRODUCTIONORDER"} //"Erro no parser."
         EndIf
         
         //Verifica a versão da Mensagem.
         If Left(cVersao,1) == "2"
            Begin Transaction
                aRet := v2000(cXml, nTypeTrans, cTypeMessage, oXml)
                If aRet[1] == .F.
                    DisarmTransaction()
                Endif
            End Transaction
         Else
            Return {.F.,STR0003,"PRODUCTIONORDER"} //"A versão da mensagem não foi implementada."
         EndIf
      ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
         aRet := v2000(cXml, nTypeTrans, cTypeMessage, oXml)
      EndIf
   ElseIf nTypeTrans == TRANS_SEND
      If lIntegPPI
         //Envio para o Totvs MES. Sempre envia a V2000. Não utiliza EAI.
         aRet := v2000(cXml, nTypeTrans, cTypeMessage, oXml)
      Else
         //Implementado apenas V2 da mensagem ProductionOrder.
         If Left(cVersao,1) == "2"
            aRet := v2000(cXml, nTypeTrans, cTypeMessage)
         Else
            lRet    := .F.
            Return {lRet, STR0003,"PRODUCTIONORDER"} //"A versão da mensagem informada não foi implementada!"
         EndIf
      EndIf
   EndIf

   lRet    := aRet[1]
   cXMLRet := aRet[2]
Return {lRet, cXmlRet,"PRODUCTIONORDER"}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} v2000

Funcao de integracao com o adapter EAI para recebimento do  cadastro de
Ordem de produção (SC2) utilizando o conceito de mensagem unica.

@param   cXml        Variável com conteúdo XML para envio/recebimento.
@param   nTypeTrans   Tipo de transação. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Lucas Konrad França
@version P12
@since   02/09/2015
@return  aRet  - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio

@obs    O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
       o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
       TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
       O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------------------------------------
Static Function v2000(cXml, nTypeTrans, cTypeMessage, oXml)
   Local lRet       := .T.
   Local lEnvOper   := .T. //Variável para controlar se envia as operações
   Local lEnvEmp    := .T. //Variável para controlar se envia os empenhos (componentes)
   Local lEnvEmpe   := .T.
   Local lActQuant  := ExistBlock("MTI650QTOP")
   Local lRecurso   := ExistBlock("MTI650RCOP")
   Local lActUnit   := ExistBlock("MTI650UMOP")
   Local lActFator  := ExistBlock("MTI650FCOP")
   Local lAddOper   := ExistBlock("MTI650ADOP")
   Local lAddLote   := ExistBlock("MTI650LOTE")
   Local lTimeMachi := ExistBlock("MTI650TMAC")
   Local lUnitTime  := ExistBlock("MTI650UTTP")
   Local lFilComp   := ExistBlock("MTI650FILC")
   Local lDescProd  := ExistBlock("MTI650DESC")
   Local lPCPREVATU := FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
   Local cDescProd  := ""
   Local cXMLRet    := ""
   Local cEvent     := ""
   Local cEntity    := "ProductionOrder"
   Local cDenOperac := ""
   Local cAliasSD4  := ""
   Local cQuery     := ""
   Local cAliasOper := ""
   Local cFiltroG2  := ""
   Local cUM2       := ""
   Local cLotCode   := ""
   Local cMarca     := ""
   Local cValExt    := ""
   Local cValInt    := ""
   Local cSeek      := ""
   Local cRoteiro   := ''
   Local cOperacao  := ''
   Local cUnitTime  := "1"
   Local cOrdem     := ""
   Local cAddXml    := ""
   Local cReqType   := ""
   Local cNum       := ""
   Local cItem      := ""
   Local cSequen    := ""
   Local cItmGrd    := ""
   Local cProduto   := ""
   Local cTipo      := ""
   Local cClassExt  := ""
   Local aAreaAnt   := GetArea()
   Local aDados     := {}
   Local aOper      := {}
   Local aNewOper   := {}
   Local aEmpen     := {}
   Local aParam     := {}
   Local aAux       := {}
   Local aOrdem     := {}
   Local aErroAuto  := {}
   Local aValInt    := {}
   Local nCount     := 0
   Local nI         := 0
   Local nLotePad   := 0
   Local nTemPad    := 0
   Local nQuantOper := 0
   Local nFator     := 0
   Local nTimeMac   := 0
   Local nMaoObra   := 0
   Local nIntSFC    := SuperGetMV("MV_INTSFC",.F.,0)
   Local nTamNum    := TamSX3("C2_NUM")[1]
   Local nTamItem   := TamSX3("C2_ITEM")[1]
   Local nTamSeq    := TamSX3("C2_SEQUEN")[1]
   Local nTamGrd    := TamSX3("C2_ITEMGRD")[1]
   Local nOpc       := 0
   Local dData      := StoD("")
   Local aXmlMatOrd := {}


   //Indices do array aOper
   //#########################
   Local COD_OPER   := 1
   Local COD_CT     := 2
   Local TIME_MAQ   := 3
   Local TIME_SETUP := 4
   Local COD_ROTEIR := 5
   Local COD_MOD    := 6
   Local COD_MAQ    := 7
   Local DT_INI_PRG := 8
   Local DT_FIM_PRG := 9
   Local INTERNALID := 10
   Local DESCOPER   := 11
   Local LOTEPAD    := 12
   Local TEMPAD     := 13
   Local QTDOPER    := 14
   Local CODOP      := 15
   Local CODPROD    := 16
   Local DESCPROD   := 17
   Local CODUMOP    := 18
   Local DESDOBR    := 19
   Local MAOOBRA    := 20
   //#########################

   //Indices do array aEmpen
   //#########################
   Local D4TRT     := 1
   Local D4COD     := 2
   Local D4LOCAL   := 3
   Local D4QUANT   := 4
   Local D4RECNO   := 5
   Local D4DATA    := 6
   Local D4ROTEIRO := 7
   Local D4OPERAC  := 8
   Local D4LOTECTL := 9
   Local D4NUMLOTE := 10
   Local D4DTVALID := 11
   //#########################
     
   Private cTipoTemp   := SuperGetMV("MV_TPHR",.F.,"C")
   Private cPont       := "SC2"
   Private lMsErroAuto := .F.
   Private lAutoErrNoFile := .T.

   If !lIntegPPI
      AdpLogEAI(1, "MATI650", nTypeTrans, cTypeMessage, cXML)
   EndIf

   SetModulo("SIGAPCP","PCP")

   If nTypeTrans == TRANS_RECEIVE
      If cTypeMessage == EAI_MESSAGE_BUSINESS
         //Produto da integração
         If Type("oXml:_TotvsMessage:_MessageInformation:_Product:_name:Text") <> "U"
            cMarca :=  oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
            aAdd(aOrdem, {"C2_PROGRAM",cMarca, Nil})
         EndIf

         // Evento
         If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
            cEvent := Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
         Else
            lRet   := .F.
            cXmlRet := STR0008 //"O evento é obrigatório"
            Return {lRet, cXMLRet}
         EndIf

         // ProductionOrderUniqueID
         If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ProductionOrderUniqueID:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ProductionOrderUniqueID:Text)
            cValExt := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ProductionOrderUniqueID:Text
         Else
            lRet   := .F.
            cXmlRet := STR0009 //"O código do ProductionOrderUniqueID é obrigatório."
            Return {lRet, cXMLRet}
         EndIf

        //Obtém o InternalId
        aValInt := F650GetInt(cValExt, cMarca)

        // Se o evento é Upsert
        If cEvent == "UPSERT"
            //Verifica se o registro foi encontrado
            If !aValInt[1]
               nOpc := 3 //Opção de inclusão
               //Número da OP.
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Number:Text") != "U" .And. ;
                  !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Number:Text)
                  cOrdem  := PadR(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Number:Text, nTamNum+nTamItem+nTamSeq+nTamGrd)

                  //Se foi enviado numeração de ordem, verifica se existe OP com esta numeração.
                  SC2->(dbSetOrder(1))
                  If SC2->(dbSeek(xFilial("SC2")+cOrdem))
                     lRet    := .F.
                     cXmlRet := STR0011 + AllTrim(cOrdem) + STR0012 //"Já existe uma ordem de produção com a numeração '" ### "'. Inclusão não permitida."
                     Return {lRet,cXmlRet}
                  EndIf
                  
                  //Recupera cada campo da chave da SC2.
                  cNum    := SubStr(cOrdem,1,nTamNum)
                  cItem   := SubStr(cOrdem,nTamNum+1,nTamItem)
                  cSequen := SubStr(cOrdem,nTamNum+nTamItem+1,nTamSeq)
                  cItmGrd := SubStr(cOrdem,nTamNum+nTamItem+nTamSeq+1,nTamGrd)

                  //Verifica se a numeração da OP preenche no mínimo os campos C2_NUM, C2_ITEM e C2_SEQUEN.
                  If Empty(cNum) .Or. Empty(cItem) .Or. Empty(cSequen)
                     lRet := .F.
                     cXmlRet := STR0013 //"Numeração da ordem de produção inválida."
                     Return {lRet,cXmlRet}
                  EndIf

                  // Armazena o número da OP no array.
                  aAdd(aOrdem, {"C2_FILIAL" , xFilial("SC2")     , NIL})
                  aAdd(aOrdem, {"C2_NUM"    , cNum   , Nil})
                  aAdd(aOrdem, {"C2_ITEM"   , cItem  , Nil})
                  aAdd(aOrdem, {"C2_SEQUEN" , cSequen, Nil})
                  aAdd(aOrdem, {"C2_ITEMGRD", cItmGrd, Nil})
               Else
                  // Numeração da OP será gerada conforme inicializador padrão da SC2.
                  aAdd(aOrdem, {"C2_FILIAL" , xFilial("SC2")     , NIL})
               EndIf
            Else
               nOpc := 4 //Opção de alteração
               cFilOP := aValInt[2,2]
               cOrdem := aValInt[2,3]

               //Valida se a OP existe.
               SC2->(dbSetOrder(1))
               If !SC2->(dbSeek(cFilOP+cOrdem))
                  lRet    := .F.
                  cXmlRet := STR0014 + AllTrim(cFilOP+cOrdem) + STR0015 //"Não foi encontrada ordem de produção com a numeração '" ### "'. Alteração não permitida."
                  Return {lRet,cXmlRet}
               EndIf

               cOrdem := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)

               // Armazena o número da OP no array.
               aAdd(aOrdem, {"C2_FILIAL" , SC2->C2_FILIAL , NIL})
               aAdd(aOrdem, {"C2_NUM"    , SC2->C2_NUM    , Nil})
               aAdd(aOrdem, {"C2_ITEM"   , SC2->C2_ITEM   , Nil})
               aAdd(aOrdem, {"C2_SEQUEN" , SC2->C2_SEQUEN , Nil})
               aAdd(aOrdem, {"C2_ITEMGRD", SC2->C2_ITEMGRD, Nil})
               aAdd(aOrdem, {"C2_PRODUTO", SC2->C2_PRODUTO, Nil})

               cProduto := SC2->C2_PRODUTO
            EndIf

            //Busca o código do produto.
            If nOpc == 3 //Não permite alterar o produto da OP
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemInternalID:Text") != "U" .And. ;
                  !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemInternalID:Text)
                  aAux := IntProInt(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemInternalID:Text, cMarca)
                  If !aAux[1]
                     lRet := aAux[1]
                     cXmlRet := aAux[2]
                     AdpLogEAI(5, "MATI650", cXMLRet, lRet)
                     Return {lRet, cXmlRet}
                  Else
                     cProduto := PadR(aAux[2][3],Len(SC2->C2_PRODUTO))
                     aAdd(aOrdem, {"C2_PRODUTO",cProduto,Nil})
                  EndIf
               Else
                  //Se não existir o ItemInternalID, utiliza o ItemCode.
                  If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text") != "U" .And. ;
                     !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text)
                     cProduto := PadR(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text,Len(SC2->C2_PRODUTO))
                     aAdd(aOrdem, {"C2_PRODUTO",cProduto,Nil})
                  Else
                     lRet := .F.
                     cXmlRet := STR0016 //"O código do produto é obrigatório."
                     Return {lRet,cXmlRet}
                  EndIf
               EndIf
            EndIf

            SB1->(dbSetOrder(1))
            If !SB1->(dbSeek(xFilial("SB1")+cProduto))
               lRet := .F.
               cXmlRet := STR0024 + AllTrim(cProduto) + STR0025 //"Produto '"####"' não cadastrado."
               Return {lRet, cXmlRet}
            EndIf

            //Quantidade da OP.
            If nOpc == 3 //Não permite alterar a quantidade da OP.
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Quantity:Text") != "U" .And. ;
                  !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Quantity:Text)
                  aAdd(aOrdem,{"C2_QUANT",Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Quantity:Text),Nil})
               Else
                  lRet := .F.
                  cXmlRet := STR0017 //"Quantidade da ordem de produção é obrigatório."
                  Return {lRet,cXmlRet}
               EndIf
            EndIf

            //Previsão inicio da OP
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_StartOrderDateTime:Text") != "U" .And. ;
               !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_StartOrderDateTime:Text)
               dData := StoD(getDate(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_StartOrderDateTime:Text))
               If Empty(dData)
                  lRet := .F.
                  cXmlRet := STR0018 //"Data de início da Ordem de produção informada em formato incorreto. Utilize AAAA-MM-DD."
                  Return {lRet,cXmlRet}
               EndIf
               aAdd(aOrdem,{"C2_DATPRI",dData,Nil})
            Else
               //Se for MODIFICAÇÃO, utiliza a mesma data que já existe na SC2.
               If nOpc == 4
                  aAdd(aOrdem,{"C2_DATPRI",SC2->C2_DATPRI,Nil})
               Else
                  lRet := .F.
                  cXmlRet := STR0019 //"Data de início da ordem de produção é obrigatório."
                  Return {lRet,cXmlRet}
               EndIf
            EndIf

            //Data de entrega da OP
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EndOrderDateTime:Text") != "U" .And. ;
               !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EndOrderDateTime:Text)
               dData := StoD(getDate(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EndOrderDateTime:Text))
               If Empty(dData)
                  lRet := .F.
                  cXmlRet := STR0020 //"Data de entrega da Ordem de produção informada em formato incorreto. Utilize AAAA-MM-DD."
                  Return {lRet,cXmlRet}
               EndIf
               aAdd(aOrdem,{"C2_DATPRF",dData,Nil})
            Else
               //Se for MODIFICAÇÃO, utiliza a mesma data que já existe na SC2.
               If nOpc == 4
                  aAdd(aOrdem,{"C2_DATPRF",SC2->C2_DATPRF,Nil})
               Else
                  lRet := .F.
                  cXmlRet := STR0021 //"Data de entrega da ordem de produção é obrigatório."
                  Return {lRet,cXmlRet}
               EndIf
            EndIf

            //Data de emissão da OP
            If nOpc == 3
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EmissionDate:Text") != "U" .And. ;
                  !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EmissionDate:Text)
                  dData := StoD(getDate(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EmissionDate:Text))
                  If Empty(dData)
                     lRet := .F.
                     cXmlRet := STR0026 //"Data de emissão da Ordem de produção informada em formato incorreto. Utilize AAAA-MM-DD."
                     Return {lRet,cXmlRet}
                  EndIf
                  aAdd(aOrdem,{"C2_EMISSAO",dData,Nil})
               EndIf
            EndIf

            //Prioridade (C2_PRIOR)
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Priority:Text") != "U" .And. ;
               !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Priority:Text)
               aAdd(aOrdem,{"C2_PRIOR",oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Priority:Text,Nil})
            EndIf

            //Classe de Valor (C2_CLVL)
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ClassValueInternalId:Text") != "U" .And. ;
               !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ClassValueInternalId:Text)

            	cClassExt := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ClassValueInternalId:Text
            	aAux := C060GetInt(cClassExt, cMarca)
            	If aAux[1]
            		aAdd(aOrdem,{"C2_CLVL", PadR(aAux[2][3], TamSX3("C2_CLVL")[1]),Nil})
            	Else
            		lRet := .F.
            		cXmlRet := STR0032 //"Classe de valor não cadastrada. "
                    Return {lRet,cXmlRet}
            	EndIf
            Else
            	// Classe de Valor
            	If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ClassValueCode:Text") != "U" .And. ;
            	   !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ClassValueCode:Text)
            	    aAdd( aOrdem, {"C2_CLVL", PadR(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ClassValueCode:Text,TamSX3("C2_CLVL")[1]), Nil } )
            	Endif
            EndIf

            //Armazém da ordem (C2_LOCAL)
            If nOpc == 3 //Não permite alterar o armazém da OP
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text") != "U" .And. ;
                  !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text)
                  aAdd(aOrdem,{"C2_LOCAL",oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text,Nil})
               Else
                  aAdd(aOrdem,{"C2_LOCAL",SB1->B1_LOCPAD,Nil})
               EndIf
            EndIf

            //Tipo (Interno/Externo/Outros - C2_TPPR)
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text") != "U" .And. ;
               !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text)
               cTipo := getOPType(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text)
               If cTipo <> Nil
                  aAdd(aOrdem,{"C2_TPPR",cTipo,Nil})
               EndIf
            EndIf

            //Unidade de medida
            If nOpc == 3 //Não permite alterar a unidade de medida da OP
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UnitOfMeasureCode:Text") != "U" .And. ;
                  !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UnitOfMeasureCode:Text)
                  aAdd(aOrdem,{"C2_UM",oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UnitOfMeasureCode:Text,Nil})
               Else
                  aAdd(aOrdem,{"C2_UM",SB1->B1_UM,Nil})
               EndIf
            EndIf

            //Roteiro 
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ScriptCode:Text") != "U" .And. ;
               !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ScriptCode:Text)
               aAdd(aOrdem,{"C2_ROTEIRO",oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ScriptCode:Text,Nil})
            EndIf

            //Se for inclusão, adiciona a revisão atual.
            If nOpc == 3
               aAdd(aOrdem,{"C2_REVISAO", IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU ), Nil})
            EndIf

            aAdd(aOrdem,{"C2_TPOP"   , "F", Nil}) //Sempre cria ordens do tipo FIRME.

            
            //Verifica se há lista de materiais no xml
            //O processamento será efetuado na função GetEmpenho()
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfMaterialOrders") != "U" 

                If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfMaterialOrders:_MaterialOrder") == "A"
                    aXmlMatOrd := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfMaterialOrders:_MaterialOrder
                ElseIf Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfMaterialOrders:_MaterialOrder") == "O"
                    aXmlMatOrd := {oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfMaterialOrders:_MaterialOrder}
                Endif

                if nOpc == 3
					If len(aXmlMatOrd) >  0
						aAdd(aOrdem,{"AUTEXPLODE", "S", Nil}) //Se for inclusão da OP e o xml possuir a lista de material, será obedecida a lista de material enviado e não a estrutura do produto da OP
						aAdd(aOrdem,{"GERAOPI", "N", Nil}) //Flag para explodir a estrutura e gerar empenhos e ordens intermediárias.
						aAdd(aOrdem,{"GERASC" , "N", Nil}) //Flag para explodir a estrutura e gerar empenhos e ordens intermediárias.
						aAdd(aOrdem,{"GERAEMP" , "N", Nil}) // Não gera os empenhos.
					Else
						aAdd(aOrdem,{"AUTEXPLODE", "S", Nil}) //Se for inclusão da OP e o xml não possuir a lista de material, será gerado os empenhos conforme a estrutura do produto da OP.
					EndIf
				EndIf
			Else
				if nOpc == 3
					aAdd(aOrdem,{"AUTEXPLODE", "S", Nil}) //Se for inclusão da OP e o xml não possuir a lista de material, será gerado os empenhos conforme a estrutura do produto da OP.
				Endif
			EndIf
         ElseIf cEvent == "DELETE"
            If !aValInt[1]
               lRet := .F.
               cXmlRet := STR0010 //"Não foi encontrada ordem de produção para efetuar a exclusão."
               Return {lRet,cXmlRet}
            EndIf
            nOpc := 5 //Opção de exclusão
            cFilOP := aValInt[2,2]
            cOrdem := aValInt[2,3]
            SC2->(dbSetOrder(1))
            If !SC2->(dbSeek(cFilOP+cOrdem))
               lRet    := .F.
               cXmlRet := STR0014 + AllTrim(cFilOP+cOrdem) + STR0022 //"Não foi encontrada ordem de produção com a numeração '" ### "'. Exclusão não permitida."
               Return {lRet,cXmlRet}
            EndIf

            // Armazena o número da OP no array.
            aAdd(aOrdem, {"C2_FILIAL" , SC2->C2_FILIAL , NIL})
            aAdd(aOrdem, {"C2_NUM"    , SC2->C2_NUM    , Nil})
            aAdd(aOrdem, {"C2_ITEM"   , SC2->C2_ITEM   , Nil})
            aAdd(aOrdem, {"C2_SEQUEN" , SC2->C2_SEQUEN , Nil})
            aAdd(aOrdem, {"C2_ITEMGRD", SC2->C2_ITEMGRD, Nil})
         Else
            lRet    := .F.
            cXmlRet := STR0023 //"O evento informado é inválido. Utilize UPSERT ou DELETE."
            Return {lRet,cXmlRet}
         EndIf

         //Se for EXCLUSÃO ou ALTERAÇÃO guarda o valor interno.
         If nOpc == 5 .Or. nOpc == 4
            cValInt := IntOPExt(/*Empresa*/, /*Filial*/, SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD), /*Versão*/)[2]
         EndIf

         MsExecAuto({|x,y| MATA650(x,y)},aOrdem,nOpc)
         If lMsErroAuto
            //Retorna o erro que ocorreu.
            aErroAuto := GetAutoGRLog()
            lRet := .F.
            cXmlRet := ""
            For nCount := 1 To Len(aErroAuto)
               cXmlRet += _noTags(aErroAuto[nCount] + Chr(10))
            Next nCount
            Return {lRet,cXmlRet}
         Else

            //Atualiza a tabela DE/PARA do EAI.
            If nOpc == 5
                CFGA070Mnt(cMarca, "SC2", "C2_NUM", cValExt, cValInt, .T., 1)
            ElseIf nOpc == 3
                cValInt := IntOPExt(/*Empresa*/, /*Filial*/, SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD), /*Versão*/)[2]
                CFGA070Mnt(cMarca, "SC2", "C2_NUM", cValExt, cValInt, .F., 1)
            EndIf

            //Geração dos empenhos
            If nOpc == 3 .Or. nOpc == 4
                if empty(cOrdem)
                    cOrdem := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
                Endif
                If !GetEmpenho(cXML,cOrdem,nOpc, oXml, @lRet, @cXmlRet,cMarca) 
                    Return {lRet,cXmlRet}
                EndIf
            EndIf

            //Monta o INTERNALID para retorno.
            cXmlRet := "<ListOfInternalId>"
            cXmlRet +=    "<InternalId>"
            cXmlRet +=       "<Name>ProductionOrderInternalId</Name>"
            cXmlRet +=       "<Origin>" + cValExt + "</Origin>"
            cXmlRet +=       "<Destination>" + cValInt + "</Destination>"
            cXmlRet +=    "</InternalId>"
            cXmlRet += "</ListOfInternalId>"


            /*
               Se existir empenhos (ListOfMaterialOrders) ou operações (ListOfActivityOrders)
               fazer a leitura/carga dos dados aqui.
               Para empenhos, utilizar EXECAUTO do MATA381, sempre excluíndo o que já existir cadastrado na SD4 e 
               assumindo somente o que vier no ListOfMaterialOrders. 
               Para operações, verificar se utiliza a SHY e gravar os dados na SHY. Se não estiver parametrizado
               para utilizar a SHY, desconsiderar as informações recebidas.
            */
        EndIf

      ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
         
      ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
         cXmlRet := '2.000|2.001|2.002|2.003|2.004|2.005|2.006'
      EndIf
   ElseIf nTypeTrans == TRANS_SEND
      // Verifica se é uma exclusão
      If !Inclui .And. !Altera
         cEvent := 'delete'
      Else
         cEvent := 'upsert'
      EndIf
      
      //Se está excluindo, ou se está sendo executado por rotinas específicas do Carga Máquina, não envia as operações e empenhos.
      If cEvent == 'delete' .Or. IsInCallStack("A690Prior") .Or. IsInCallStack("ProcAtuSC2")
         lEnvOper := .F.
         lEnvEmp  := .F.
      EndIf

      If lIntegPPI
         If Type('cPonteiro') == "C"
            cPont := cPonteiro
         EndIf
      EndIf

      SB1->(dbSetOrder(1))
      SB1->(dbSeek(xFilial("SB1")+&(cPont+'->C2_PRODUTO')))

      // Monta XML de envio de mensagem unica
      cXMLRet := '<BusinessEvent>'
      cXMLRet +=    '<Entity>' + cEntity + '</Entity>'
      cXMLRet +=    '<Event>' + cEvent + '</Event>'
      cXMLRet +=    '<Identification>'
      cXMLRet +=       '<key name="InternalID">' + IntOPExt(/*Empresa*/, /*Filial*/, &(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)'), /*Versão*/)[2] + '</key>'
      cXMLRet +=    '</Identification>'
      cXMLRet += '</BusinessEvent>'
      cXMLRet += '<BusinessContent>'
      cXmlRet +=    '<Number>' + AllTrim(&(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)')) + '</Number>' //Número Ordem Produção
      cXmlRet +=    '<Origin />' //Identificação da origem da mensagem (ex:APS, Chão de Fábrica). Este campo foi necessário pois existe mais de um módulo do Datasul que envia Ordem de Produção
      cXmlRet +=    '<ProductionOrderUniqueID>'+IntOPExt(/*Empresa*/, /*Filial*/, &(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)'), /*Versão*/)[2]+'</ProductionOrderUniqueID>'
      cXmlRet +=    '<FatherNumber />' //Número Ordem Produção Pai
      cXmlRet +=    '<FatherProductionOrderUniqueID />' //Identificação Ordem Produção Pai
      cXmlRet +=    '<ItemCode>'+ AllTrim(&(cPont+'->C2_PRODUTO'))+'</ItemCode>' //Código Item
      cXmlRet +=    '<ListOfItemGrids />' //Grades, não utilizado no Protheus
      cXmlRet +=    '<ItemDescription>'+_NoTags(AllTrim(SB1->B1_DESC))+'</ItemDescription>'
      cXmlRet +=    '<Type>1</Type>' //Todas as ordens do Protheus são Internas.
      cXmlRet +=    '<IsItemCoproduct />' //Coproduto
      If lActQuant
         aParam := {}
         aAdd(aParam,&(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)'))
         aAdd(aParam,&(cPont+'->C2_PRODUTO'))
         aAdd(aParam,"") //Roteiro
         aAdd(aParam,"") //Operacao
         aAdd(aParam,&(cPont+'->C2_QUANT'))
         nQuantOper := ExecBlock('MTI650QTOP',.F.,.F.,aParam)
         If ValType(nQuantOper) != "N"
            nQuantOper := &(cPont+'->C2_QUANT')
         EndIf
         cXmlRet += '<Quantity>'+ cValToChar(nQuantOper) +'</Quantity>' //Quantidade
         nQuantOper := 0
      Else
         cXmlRet += '<Quantity>'+ cValToChar(&(cPont+'->C2_QUANT'))+'</Quantity>' //Quantidade
      EndIf
      cXmlRet +=    '<MinimumQuantity />' //Quantidade Mínima
      cXmlRet +=    '<MaximumQuantity />' //Quantidade Máxima
      cXmlRet +=    '<ReportQuantity>'+ cValToChar(&(cPont+'->C2_QUJE')) +'</ReportQuantity>' //Quantidade Reportada
      cXmlRet +=    '<ApprovedQuantity />' //Quantidade Aprovada
      cXmlRet +=    '<ReworkQuantity />' //Quantidade Retrabalhada
      cXmlRet +=    '<ScrapQuantity />' //Quantidade Refugada
      cXmlRet +=    '<AuxiliarItemCode />' //Código Item Auxiliar
      cXmlRet +=    '<IsStatusOrder />' //Reporte Fecha Ordem Produção
      cXmlRet +=    '<UnitOfMeasureCode>'+ AllTrim(&(cPont+'->C2_UM')) +'</UnitOfMeasureCode>' //Unidade Medida
      cXmlRet +=    '<RequestOrderCode>'+ AllTrim(&(cPont+'->C2_PEDIDO')) +'</RequestOrderCode>' //Código Pedido Ordem Produção
      cXmlRet +=    '<StatusType />' //Estado
      cXmlRet +=    '<StatusOrderType>'+getStatusT()+'</StatusOrderType>' //Estado Ordem
      cXmlRet +=    '<ProductionLineCode />' //Código Linha Produção
      cXmlRet +=    '<ProductionLineDescription />' //Descrição Linha Produção
      cXmlRet +=    '<PlannerUser />' //Planejador
      cXmlRet +=    '<ReferenceCode />' //Código Referência (Característica do Item)
      cXmlRet +=    '<ReportOrderType>2</ReportOrderType>' //Reporta Produção
      cXmlRet +=    '<AllocationType />' //Tipo de Alocação
      cXmlRet +=    '<SiteCode />' //Código Estabelecimento
      cXmlRet +=    '<WarehouseCode>'+ AllTrim(&(cPont+'->C2_LOCAL')) +'</WarehouseCode>' //Código Depósito
      cXmlRet +=    '<EndOrderCPDate />'//Data Fim Ordem Produção CP
      cXmlRet +=    '<StartOrderCPDate />'//Data Início Ordem Produção CP
      cXmlRet +=    '<ReleaseOrderDate />' //Data Liberação Ordem Produção
      cXmlRet +=    '<TimeReleaseQuantity />' //Segs Liberação OP
      cXmlRet +=    '<StartOrderDateTime>'+getDateTime(&(cPont+'->C2_DATPRI'),"00:00:00")+'</StartOrderDateTime>' //Data/Hora Início Ordem Produção
      cXmlRet +=    '<StartOrderQuantity />' //Segs Início Ordem Produção
      cXmlRet +=    '<EndOrderDateTime>'+getDateTime(&(cPont+'->C2_DATPRF'),"00:00:00")+'</EndOrderDateTime>' //Data/Hora Fim Ordem Produção
      cXmlRet +=    '<EndOrderQuantity />' //Segs Fim Ordem Produção
      cXmlRet +=    '<StartEarlierDateTime />' //Data/Hora Início Mais Cedo
      cXmlRet +=    '<EndLaterDateTime />' //Data/Hora Fim Mais Tarde
      cXmlRet +=    '<AbbreviationProviderName>'+ AllTrim(_NoTags(getClient(&(cPont+'->C2_PEDIDO')))) +'</AbbreviationProviderName>' //Nome Cliente
      cXmlRet +=    '<CustomerGroupCode />' //Código Grupo Cliente
      cXmlRet +=    '<CustomerRequestCode />' //Código Pedido Cliente
      cXmlRet +=    '<LastPertNumber />' //Última Sequência
      cXmlRet +=    '<PertRequestNumber />' //Sequência Pedido
      If lAddLote
         cLotCode := ExecBlock('MTI650LOTE',.F.,.F.,cPont+"->")
         If ValType(cLotCode) == "C"
            cXmlRet += '<LotCode>'+ AllTrim(_NoTags(cLotCode)) +'</LotCode>' //Lote/Série
         Else
            cXmlRet += '<LotCode />' //Lote/Série
         EndIf
      Else
         cXmlRet +=    '<LotCode />' //Lote/Série
      EndIf
      cXmlRet +=    '<MaterialListCode />' //Código Lista Componentes
      cXmlRet +=    '<ScriptCode>'+ AllTrim(&(cPont+'->C2_ROTEIRO')) +'</ScriptCode>' //Código Roteiro
      cXmlRet +=    '<MaterialCalculationType />' //Cálculo Custo Material
      cXmlRet +=    '<LaborType />' //Reporta Mão de Obra
      cXmlRet +=    '<LaborCostType />' //Custeio Proporcional Mão de Obra
      cXmlRet +=    '<MaterialCostType />' //Custeio Proporcional Material
      cXmlRet +=    '<OverheadCostType />' //Custeio Proporcional GGF
      cXmlRet +=    '<LaborCalculationType />' //Cálculo Custo Mão de Obra
      cXmlRet +=    '<OverheadCalculationType />' //Cálculo Custo Gastos Gerais de Fabricação
      cXmlRet +=    '<OverheadType />' //Reporta Gastos Gerais de Fabricação
      cXmlRet +=    '<ScrapItemCode />' //Código Item Refugo
      cXmlRet +=    '<ScrapItemValue />' //Relação Refugo/Item
      cXmlRet +=    '<BusinessUnitCode />' //Código Unidade Negócio
      cXmlRet +=    '<StockGroupCode />' //Código Grupo Estoque
      cXmlRet +=    '<StockGroupDescription />' //Descrição Grupo Estoque
      cXmlRet +=    '<FamilyCode />' //Código Família
      cXmlRet +=    '<FamilyDescription />' //Descrição Família
      cXmlRet +=    '<NetWeight />' //Peso Líquido
      cXmlRet +=    '<GrossWeight />' //Peso Bruto
      cXmlRet +=    '<DeliveryNumber />' //Número Entrega
      cXmlRet +=    '<Priority />' //Prioridade
      
      //################
      //INICIO OPERACOES
      //################
      cXmlRet +=    '<ListOfActivityOrders>' // Operações

      //Busca as Operações da ordem.
      //Procura primeiro na SH8. Se não encontrar, busca as operações da SHY. Caso não encontre, busca na SG2.
      aOper := {}
      If lEnvOper
         //Somente envia operações nas ações de inclusão e alteração.
         
         cAliasOper := GetNextAlias()
         cFiltroG2 := ""
         dbSelectArea("SOE")
         SOE->(dbSetOrder(1))
         If SOE->(dbSeek(xFilial("SOE")+"SC2"))
            //Se está parametrizado para considerar o filtro das operações nas ordens, busca o filtro da tabela SG2
            //para filtrar as tabelas SH8, SHY e SG2.
            If AllTrim(SOE->OE_VAR2) == "1"
               SOE->(dbSeek(xFilial("SOE")+"SG2"))
               cFiltroG2 := StrTran(SOE->OE_FILTRO,'"',"'")
            EndIf
         EndIf
         
         //Busca as operações na SH8. Se não encontrar, busca na SHY. Se não encontrar, busca na SG2.
         cQuery := " SELECT R_E_C_N_O_ REC "
         cQuery +=   " FROM " + RetSqlName("SH8") + " SH8 "
         cQuery +=  " WHERE SH8.H8_OP      = '" + AllTrim(&(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)')) + "' "
         cQuery +=    " AND SH8.H8_FILIAL  = '" + xFilial("SH8") + "' "
         cQuery +=    " AND SH8.D_E_L_E_T_ = ' ' "
         If !Empty(cFiltroG2)
            cQuery += " AND SH8.H8_OPER IN ( SELECT SG2.G2_OPERAC "
            cQuery +=                        " FROM " + RetSqlName("SG2") + " SG2 "
            cQuery +=                       " WHERE SG2.G2_FILIAL  = '" + xFilial("SG2") + "' "
            cQuery +=                         " AND SG2.G2_CODIGO  = '" + &(cPont+'->C2_ROTEIRO') + "' "
            cQuery +=                         " AND SG2.G2_PRODUTO = '" + &(cPont+'->C2_PRODUTO') + "' "
            cQuery +=                         " AND SG2.D_E_L_E_T_ = ' ' "
            cQuery +=                         " AND (" + cFiltroG2 + ") ) "
         EndIf
         cQuery += " ORDER BY " + SqlOrder(SH8->(IndexKey(1)))
         
         cQuery := ChangeQuery(cQuery)
         dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasOper,.T.,.T.)
         If (cAliasOper)->(!Eof())
            While (cAliasOper)->(!Eof())
               SH8->(dbGoTo((cAliasOper)->(REC)))
               If SG2->(dbSeek(xFilial("SG2")+&(cPont+'->C2_PRODUTO')+SH8->(H8_ROTEIRO+H8_OPER)))
                  cDenOperac := SG2->(G2_DESCRI)
                  nLotePad   := SG2->(G2_LOTEPAD)
                  nTemPad    := SG2->(G2_TEMPAD)
                  nMaoObra   := SG2->G2_MAOOBRA
               Else
                  cDenOperac := ""
                  nLotePad   := 0
                  nTemPad    := 0
                  nMaoObra   := 0
               EndIf
               aAdd(aOper,{SH8->(H8_OPER),;             //Código da operação
                           SH8->(H8_CTRAB),;              //Código do centro de trabalho
                           A680Tempo(SH8->(H8_DTINI), SH8->(H8_HRINI), SH8->(H8_DTFIM), SH8->(H8_HRFIM)),; //Tempo maquina
                           ConvTime(SH8->(H8_SETUP),,,"C"),; //Tempo Setup/Preparação
                           SH8->(H8_ROTEIRO),;            //Código do roteiro
                           "MOD"+&(cPont+'->C2_CC'),;     //Código Mão de Obra Direta
                           SH8->(H8_RECURSO),;            //Código da máquina
                           getDateTime(Iif(Empty(SH8->(H8_DTINI)),&(cPont+'->C2_DATPRI'),SH8->(H8_DTINI)) , SH8->(H8_HRINI)),; //Data/Hora Início Programação
                           getDateTime(Iif(Empty(SH8->(H8_DTFIM)),&(cPont+'->C2_DATPRF'),SH8->(H8_DTFIM)) , SH8->(H8_HRFIM)),; //Data/Hora Fim Programação 
                           SH8->(Recno()),; //InternalID
                           cDenOperac,; //Descrição da operacao
                           nLotePad,;   //Lote padrão
                           nTemPad,;    //Tempo padrão
                           SH8->(H8_QUANT),; //Quantidade da operação
                           &(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)'),; //Num. OP.
                           &(cPont+'->C2_PRODUTO'),; //Código do Produto
                           SB1->(B1_DESC),;  //Descrição do produto
                           &(cPont+'->C2_UM'),; //Unidade de medida da OP
                           SH8->H8_DESDOBR,; //Desdobramento da operação
                           nMaoObra,;
                           cPont+"->" }) //Ponteiro usado para acessar as informações da SC2. Deve ser sempre o ultimo parâmetro.
               If lAddOper
                  aNewOper := ExecBlock('MTI650ADOP',.F.,.F.,aOper[Len(aOper)])
                  If aNewOper != Nil
                     aAdd(aOper,aNewOper)
                  EndIf
               EndIf
               (cAliasOper)->(dbSkip())

			   SH8->(dbCloseArea())
			   SG2->(dbCloseArea())
            End
			(cAliasOper)->(dbCloseArea())
         Else
            (cAliasOper)->(dbCloseArea())
            cAliasOper := GetNextAlias()
            
            cQuery := " SELECT SHY.R_E_C_N_O_ REC "
            cQuery +=   " FROM " + RetSqlName("SHY") + " SHY "
            cQuery +=  " WHERE SHY.HY_FILIAL  = '" + xFilial("SHY") + "' "
            cQuery +=    " AND SHY.D_E_L_E_T_ = ' ' "
            cQuery +=    " AND SHY.HY_OP      = '" + &(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)') + "' "
            If !Empty(cFiltroG2)
               cQuery += " AND SHY.HY_OPERAC IN ( SELECT SG2.G2_OPERAC "
               cQuery +=                          " FROM " + RetSqlName("SG2") + " SG2 "
               cQuery +=                         " WHERE SG2.G2_FILIAL  = '" + xFilial("SG2") + "' "
               cQuery +=                           " AND SG2.G2_CODIGO  = '" + &(cPont+'->C2_ROTEIRO') + "' "
               cQuery +=                           " AND SG2.G2_PRODUTO = '" + &(cPont+'->C2_PRODUTO') + "' "
               cQuery +=                           " AND SG2.D_E_L_E_T_ = ' ' "
               cQuery +=                           " AND (" + cFiltroG2 + ") )"
            EndIf
            cQuery += " ORDER BY " + SqlOrder(SHY->(IndexKey(1)))
            
            cQuery := ChangeQuery(cQuery)
            dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasOper,.T.,.T.)
            If (cAliasOper)->(!Eof())
               While (cAliasOper)->(!Eof())
                  SHY->(dbGoTo((cAliasOper)->(REC)))
                  If SG2->(dbSeek(xFilial("SG2")+&(cPont+'->C2_PRODUTO')+SHY->(HY_ROTEIRO+HY_OPERAC)))
                     cDenOperac := SG2->(G2_DESCRI)
                     nLotePad   := SG2->(G2_LOTEPAD)
                     nTemPad    := SG2->(G2_TEMPAD)
                  Else
                     cDenOperac := ""
                     nLotePad   := 0
                     nTemPad    := 0
                  EndIf
                  cDenOperac := SHY->HY_DESCRI
                  aAdd(aOper,{SHY->(HY_OPERAC),;             //Código da operação
                              SHY->(HY_CTRAB),;              //Código do centro de trabalho
                              SHY->(HY_TEMPOM),; //Tempo maquina
                              SHY->(HY_TEMPOS),; //Tempo Setup/Preparação
                              SHY->(HY_ROTEIRO),;            //Código do roteiro
                              "MOD"+&(cPont+'->C2_CC'),;     //Código Mão de Obra Direta
                              SHY->(HY_RECURSO),;            //Código da máquina
                              getDateTime(Iif(Empty(SHY->(HY_DATAINI)),&(cPont+'->C2_DATPRI'),SHY->(HY_DATAINI)) , Iif(Empty(SHY->HY_HORAINI),"00:00:00",SHY->HY_HORAINI)),; //Data/Hora Início Programação
                              getDateTime(Iif(Empty(SHY->(HY_DATAFIM)),&(cPont+'->C2_DATPRF'),SHY->(HY_DATAFIM)) , Iif(Empty(SHY->HY_HORAFIM),"00:00:00",SHY->HY_HORAFIM)),; //Data/Hora Fim Programação
                              SHY->(Recno()),;  //InternalID
                              cDenOperac,;      //Descrição da operacao
                              nLotePad,;        //Lote padrão
                              nTemPad,;         //Tempo padrão
                              SHY->(HY_QUANT),; //Quantidade da operação
                              &(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)'),; //Num. OP.
                              &(cPont+'->C2_PRODUTO'),; //Código do Produto
                              SB1->(B1_DESC),;  //Descrição do produto
                              &(cPont+'->C2_UM'),; //Unidade de medida da OP
                              "000",; // Desdobramento da operação
                              SHY->HY_MAOOBRA,;
                              cPont+"->" }) //Ponteiro usado para acessar as informações da SC2. Deve ser sempre o ultimo parâmetro.
                  If lAddOper
                     aNewOper := ExecBlock('MTI650ADOP',.F.,.F.,aOper[Len(aOper)])
                     If aNewOper != Nil
                        aAdd(aOper,aNewOper)
                     EndIf
                  EndIf
                  (cAliasOper)->(dbSkip())
               End
			   (cAliasOper)->(dbCloseArea())
            Else
               (cAliasOper)->(dbCloseArea())
               cAliasOper := GetNextAlias()
               cQuery := " SELECT SG2.R_E_C_N_O_ REC "
               cQuery +=   " FROM " + RetSqlName("SG2") + " SG2 "
               cQuery +=  " WHERE SG2.G2_FILIAL  = '" + xFilial("SG2") + "' "
               cQuery +=    " AND SG2.D_E_L_E_T_ = ' ' "
               cQuery +=    " AND SG2.G2_PRODUTO = '" + &(cPont+'->(C2_PRODUTO)') + "' "
               cQuery +=    " AND SG2.G2_CODIGO  = '" + &(cPont+'->(C2_ROTEIRO)') + "' "
               cQuery += " AND (SG2.G2_DTINI = ' ' "
               cQuery +=   " OR SG2.G2_DTINI < '" + DtOs(&(cPont+'->C2_DATPRI')) + "' )"
               cQuery += " AND (SG2.G2_DTFIM = ' ' "
               cQuery +=   " OR SG2.G2_DTFIM > '" + DtOs(&(cPont+'->C2_DATPRI')) + "' )"
               If !Empty(cFiltroG2)
                  cQuery += " AND (" + cFiltroG2 + ") "
               EndIf
               cQuery += " ORDER BY " + SqlOrder(SG2->(IndexKey(1)))
               
               cQuery := ChangeQuery(cQuery)
               dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasOper,.T.,.T.)
             
               While (cAliasOper)->(!Eof())
                  SG2->(dbGoTo((cAliasOper)->(REC)))
                  
                  aAdd(aOper,{SG2->(G2_OPERAC),;                   //Código da operação
                              SG2->(G2_CTRAB),;                    //Código do centro de trabalho
                              getTimeG2(&(cPont+'->C2_QUANT')),; //Tempo maquina
                              A690HoraCt(SG2->(G2_SETUP)),;        //Tempo Setup/Preparação
                              SG2->(G2_CODIGO),;                   //Código do roteiro
                              "MOD"+AllTrim(&(cPont+'->C2_CC')),;  //Código Mão de Obra Direta
                              SG2->(G2_RECURSO),;                  //Código da máquina
                              getDateTime(&(cPont+'->C2_DATPRI'), "00:00:00"),; //Data/Hora Início Programação
                              getDateTime(&(cPont+'->C2_DATPRF'), "00:00:00"),; //Data/Hora Fim Programação
                              SG2->(Recno()),;        //InternalID
                              SG2->(G2_DESCRI),;      //Descrição da operacao
                              SG2->(G2_LOTEPAD),;     //Lote padrão
                              SG2->(G2_TEMPAD),;      //Tempo padrão
                              &(cPont+'->C2_QUANT'),; //Quantidade da operação
                              &(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)'),; //Num. OP.
                              &(cPont+'->C2_PRODUTO'),; //Código do Produto
                              SB1->(B1_DESC),;  //Descrição do produto
                              &(cPont+'->C2_UM'),; //Unidade de medida da OP
                              "000",; // Desdobramento da operação
                              SG2->G2_MAOOBRA,;
                              cPont+"->" }) //Ponteiro usado para acessar as informações da SC2. Deve ser sempre o ultimo parâmetro.
                  If lAddOper
                     aNewOper := ExecBlock('MTI650ADOP',.F.,.F.,aOper[Len(aOper)])
                     If aNewOper != Nil
                        aAdd(aOper,aNewOper)
                     EndIf
                  EndIf
                  (cAliasOper)->(dbSkip())
               End
               (cAliasOper)->(dbCloseArea())
            EndIf
         EndIf

         //Le o array com as operações, e adiciona na mensagem
         For nI := 1 To Len(aOper)
            //P.E. para alterar o código do recurso e a descrição da operação.
            If lRecurso
               aParam := {}
               aAdd(aParam,aOper[nI,CODOP])
               aAdd(aParam,aOper[nI,COD_ROTEIR])
               aAdd(aParam,aOper[nI,COD_OPER])
               aAdd(aParam,aOper[nI,DESCOPER])
               aAdd(aParam,aOper[nI,COD_MAQ])
               aDados := ExecBlock('MTI650RCOP',.F.,.F.,aParam)
               If ValType(aDados) == "A"
                  If ValType(aDados[1]) == "C"
                     aOper[nI,COD_MAQ] := aDados[1]
                  EndIf
                  If Len(aDados) > 1 .And. ValType(aDados[2]) == "C"
                     aOper[nI,DESCOPER] := aDados[2]
                  EndIf
               EndIf
            EndIf
            cXmlRet +=       '<ActivityOrder>' //
            cXmlRet +=          '<ProductionOrderNumber>'+ AllTrim(aOper[nI,CODOP]) +'</ProductionOrderNumber>' //Número Ordem Produção
            cXmlRet +=          '<ActivityID>'+ cValToChar(aOper[nI,INTERNALID]) +'</ActivityID>' //ID Operação
            cXmlRet +=          '<ActivityCode>'+ AllTrim(aOper[nI,COD_OPER]) +'</ActivityCode>' //Código Operação
            cXmlRet +=          '<ActivityDescription>'+ AllTrim(_NoTags(aOper[nI,DESCOPER])) +'</ActivityDescription>' //Descrição Operação
            cXmlRet +=          '<Split>'+ AllTrim(aOper[nI,DESDOBR]) +'</Split>'
            cXmlRet +=          '<ItemCode>'+ AllTrim(aOper[nI,CODPROD]) +'</ItemCode>' //Código Item
            cXmlRet +=          '<ItemDescription>'+ _NoTags(AllTrim(aOper[nI,DESCPROD])) +'</ItemDescription>' //Descrição Item
            cXmlRet +=          '<ListOfItemGrids />' //Grades, não utilizado no Protheus
            cXmlRet +=          '<ActivityType>'+Iif(lIntegPPI,"1","")+'</ActivityType>' //Tipo Operação ###QUANDO INTEGRAÇÃO COM PCFACTORY, ENVIAR SEMPRE 1
            cXmlRet +=          '<WorkCenterCode>'+ AllTrim(aOper[nI,COD_CT]) +'</WorkCenterCode>' //Código Centro Trabalho
            cXmlRet +=          '<WorkCenterDescription>'+ AllTrim(_NoTags(getCTrab(aOper[nI,COD_CT]))) +'</WorkCenterDescription>' //Descrição Centro Trabalho
            If lUnitTime
               aParam := {}
               aAdd(aParam,aOper[nI,CODOP])
               aAdd(aParam,aOper[nI,CODPROD])
               aAdd(aParam,aOper[nI,COD_ROTEIR])
               aAdd(aParam,aOper[nI,COD_OPER])
               cUnitTime := ExecBlock('MTI650UTTP',.F.,.F.,aParam)
               If ValType(cUnitTime) != "C"
                  cUnitTime := "1"
               EndIf

               cXmlRet +=       '<UnitTimeType>'+ cUnitTime +'</UnitTimeType>' //Tipo Unidade Tempo
            Else
               cXmlRet +=       '<UnitTimeType>'+gUnitTime()+'</UnitTimeType>' //Tipo Unidade Tempo
            EndIf
            cXmlRet +=          '<TimeResource>'+ cValToChar(aOper[nI,TEMPAD]) +'</TimeResource>' //Tempo Recurso
            If lTimeMachi
               aParam := {}
               aAdd(aParam,aOper[nI,CODOP])
               aAdd(aParam,aOper[nI,CODPROD])
               aAdd(aParam,aOper[nI,COD_ROTEIR])
               aAdd(aParam,aOper[nI,COD_OPER])
               aAdd(aParam,&(cPont+'->C2_QUANT'))
               nTimeMac := ExecBlock('MTI650TMAC',.F.,.F.,aParam)
               If ValType(nTimeMac) != "N"
                  nTimeMac := aOper[nI,TIME_MAQ]
               EndIf
               cXmlRet +=       '<TimeMachine>'+ cValToChar(nTimeMac) +'</TimeMachine>' //Tempo Máquina
            Else
               cXmlRet +=       '<TimeMachine>'+ cValToChar(aOper[nI,TIME_MAQ]) +'</TimeMachine>' //Tempo Máquina
            EndIf
            cXmlRet +=          '<TimeSetup>'+ cValToChar(aOper[nI,TIME_SETUP]) +'</TimeSetup>' //Tempo Preparação
            cXmlRet +=          '<ScriptCode>'+ AllTrim(aOper[nI,COD_ROTEIR]) +'</ScriptCode>' //Código Roteiro
            cXmlRet +=          '<EndLaterDateTime />' //Data/Hora Fim Mais Tarde
            cXmlRet +=          '<ResourceQuantity>'+ cValToChar(aOper[nI,MAOOBRA]) + '</ResourceQuantity>' //Quantidade Recurso
            cXmlRet +=          '<PercentageOverlapValue />' //% Overlap
            cXmlRet +=          '<PercentageScrapValue />' //% Refugo
            cXmlRet +=          '<PercentageValue />' //Proporção
            cXmlRet +=          '<LaborCode>'+ AllTrim(aOper[nI,COD_MOD]) +'</LaborCode>' //Código Mão de Obra Direta
            cXmlRet +=          '<UnitItemNumber>'+ cValToChar(aOper[nI,LOTEPAD]) +'</UnitItemNumber>' //Unidades
            If lActQuant
               aParam := {}
               aAdd(aParam,aOper[nI,CODOP])
               aAdd(aParam,aOper[nI,CODPROD])
               aAdd(aParam,aOper[nI,COD_ROTEIR])
               aAdd(aParam,aOper[nI,COD_OPER])
               aAdd(aParam,aOper[nI,QTDOPER])
               nQuantOper := ExecBlock('MTI650QTOP',.F.,.F.,aParam)
               If ValType(nQuantOper) != "N"
                  nQuantOper := aOper[nI,QTDOPER]
               EndIf
               cXmlRet +=       '<ProductionQuantity>'+ cValToChar(nQuantOper) +'</ProductionQuantity>' //Quantidade Produzida
               cXmlRet +=       '<ActivityQuantity>'+ cValToChar(nQuantOper) +'</ActivityQuantity>' //Quantidade Prevista
            Else
               cXmlRet +=       '<ProductionQuantity>'+ cValToChar(aOper[nI,QTDOPER]) +'</ProductionQuantity>' //Quantidade Produzida
               cXmlRet +=       '<ActivityQuantity>'+ cValToChar(aOper[nI,QTDOPER]) +'</ActivityQuantity>'
            EndIf
            cXmlRet +=          '<AlternativeActivityCode />' //Codigo Operação Alternativa
            cXmlRet +=          '<UnitActivityCode>'+ AllTrim(aOper[nI,CODUMOP]) +'</UnitActivityCode>' //Código Unidade Operação
            cXmlRet +=          '<ReworkQuantity />' //Quantidade Retrabalhada
            cXmlRet +=          '<ScrapItemCode />' //Código Item Refugo
            cXmlRet +=          '<ScrapItemValue />' //Relação Refugo/Item
            cXmlRet +=          '<TimePostprocessing />' //Tempo Pós Processo
            cXmlRet +=          '<UsedCapacity />' //Capacidade Utilizada
            cXmlRet +=          '<LoadQuantity />' //Carga Batelada
            cXmlRet +=          '<StatusType />' //Estado
            cXmlRet +=          '<StartRealDateTime />' //Data/Hora Início Real
            cXmlRet +=          '<EndRealDateTime />' //Data/Hora Fim Real
            cXmlRet +=          '<StartEarlierDateTime />' //Data/Hora Início Mais Cedo
            cXmlRet +=          '<OrderReferenceNumber />' //Número Ordem Referência
            cXmlRet +=          '<IsActivityStart />' //Primeira Operação
            cXmlRet +=          '<IsActivityEnd>'+Iif(nI==Len(aOper), "true", "false")+'</IsActivityEnd>' //Última Operação
            cXmlRet +=          '<ApprovedQuantity />' //Quantidade Aprovada
            cXmlRet +=          '<ScrapQuantity />' //Quantidade Refugada
            cXmlRet +=          '<ReportQuantity />' //Quantidade Reportada
            cXmlRet +=          '<IsLastReport />' //Reporte Fecha Operação
            cXmlRet +=          '<MaterialItemValue />' //Relação Item Operac/Item
            cXmlRet +=          '<TreatmentTimeType />' //Tipo Tratamento Tempo
            cXmlRet +=          '<StandardLotQuantity />' //Lote Padrão
            cXmlRet +=          '<MultipleLotQuantity />' //Lote Múltiplo
            cXmlRet +=          '<MinimumLotQuantity />' //Lote Mínimo
            cXmlRet +=          '<MachineCode>'+ AllTrim(aOper[nI,COD_MAQ]) +'</MachineCode>' //Código Máquina
            cXmlRet +=          '<StartPlanDateTime>'+ AllTrim(aOper[nI,DT_INI_PRG]) +'</StartPlanDateTime>' //Data/Hora Início Programação
            cXmlRet +=          '<EndPlanDateTime>'+ AllTrim(aOper[nI,DT_FIM_PRG]) +'</EndPlanDateTime>' //Data/Hora Fim Programação
            cXmlRet +=          '<IsSignificantTime />' //Tempo Significativo
            cXmlRet +=          '<ActivityControlCode />' //Código Ponto Controle
            cXmlRet +=          '<ActivityItemValue />' //Relação Operação/Item
            cXmlRet +=          '<TimeMOD>0</TimeMOD>' // Tempo de mão de obra
            cXmlRet +=          '<TimeIndMES>3</TimeIndMES>' // Tratativa de tempo 1 = Tempo Máquina; 2 = Tempo mão-de-obra; 3 = Escolha pelo MES
            If lActUnit
               aParam := {}
               aAdd(aParam,aOper[nI,CODOP])
               aAdd(aParam,aOper[nI,CODPROD])
               aAdd(aParam,aOper[nI,COD_ROTEIR])
               aAdd(aParam,aOper[nI,COD_OPER])
               cUM2 := ExecBlock('MTI650UMOP',.F.,.F.,aParam)
               If ValType(cUM2) != "C"
                  cUM2 := '  '
               EndIf
               cXmlRet +=       '<SecondUnitActivityCode>'+ AllTrim(cUM2) +'</SecondUnitActivityCode>' //Segunda Unidade Operação
            Else
               cXmlRet +=       '<SecondUnitActivityCode />' //Segunda Unidade Operação
            EndIf
            If lActFator
               aParam := {}
               aAdd(aParam,aOper[nI,CODOP])
               aAdd(aParam,aOper[nI,CODPROD])
               aAdd(aParam,aOper[nI,COD_ROTEIR])
               aAdd(aParam,aOper[nI,COD_OPER])
               nFator := ExecBlock('MTI650FCOP',.F.,.F.,aParam)
               If ValType(nFator) == "N"
                  cXmlRet +=       '<SecondUnitActivityFactor>'+ cValToChar(nFator) +'</SecondUnitActivityFactor>' //Fator de conversão para segunda unidade de medida da operação
               Else
                  cXmlRet +=       '<SecondUnitActivityFactor />' //Fator de conversão para segunda unidade de medida da operação
               EndIf
            Else
               cXmlRet +=       '<SecondUnitActivityFactor />' //Fator de conversão para segunda unidade de medida da operação
            EndIf
            cXmlRet +=          '<ListOfActivityOrderTools />'
            cXmlRet +=       '</ActivityOrder>'
         Next nI
      EndIf
      cXmlRet +=    '</ListOfActivityOrders>'
      //################
      //FIM OPERACOES
      //################
      cXmlRet +=    '<ListOfPertOrders />'
      
      //##################
      //INICIO COMPONENTES
      //##################
      cXmlRet +=    '<ListOfMaterialOrders>' //
      
      If ExistBlock("I650EMP")
         lEnvEmpe := ExecBlock("I650EMP",.F.,.F.,{&(cPont+'->C2_NUM')})
         If ValType(lEnvEmpe) == "L"
            lEnvEmp := lEnvEmpe
         EndIf
      EndIf
     
      //Busca os componentes na SD4
      If lEnvEmp
         aEmpen := {}
         
         //Se existirem empenhos no array aEmpenhos, não faz as buscas na SD4.
         //Este array é alimentado nos programas MATA381 (Empenho múltiplo) 
         //e MATA380 (Empenho simples).
         //Estrutura do array: aEmpenhos[1] - Sequência da estrutura
         //                    aEmpenhos[2] - Código do empenho
         //                    aEmpenhos[3] - Local de estoque
         //                    aEmpenhos[4] - Quantidade
         //                    aEmpenhos[5] - RECNO
         //                    aEmpenhos[6] - Data do empenho
         //                    aEmpenhos[7] - Roteiro de operações
         //                    aEmpenhos[8] - Código da operação
         //                    aEmpenhos[9] - Número do lote
         //                    aEmpenhos[10] - Número do Sub-Lote
         //                    aEmpenhos[11] - Data de validade do lote
         
         If Type("aEmpenhos") == "A"
            aEmpen := aClone(aEmpenhos)
         Else
            cAliasSD4 := GetNextAlias()
            //Somente envia os componentes se for operação de inclusão ou alteração.

            //Faz o select para trazer os componentes ordenados pela sequencia da estrutura.
            //cQuery := " SELECT CAST(SD4.D4_TRT AS INT) TRT, "
            cQuery := " SELECT SD4.D4_TRT, "
            cQuery +=        " SD4.R_E_C_N_O_ RECSD4, "
            cQuery +=        " SD4.D4_COD, "
            cQuery +=        " SD4.D4_LOCAL, "
            cQuery +=        " SD4.D4_QUANT, "
            cQuery +=     " SD4.D4_OPERAC, "
            cQuery +=     " SD4.D4_ROTEIRO, "
            cQuery +=        " SD4.D4_DATA, "
            cQuery +=        " SD4.D4_DTVALID, "
            cQuery +=        " SD4.D4_NUMLOTE, "
            cQuery +=        " SD4.D4_LOTECTL "
            cQuery +=   " FROM " + RetSqlName("SD4") + " SD4 "
            cQuery +=  " WHERE SD4.D4_FILIAL  = '" + xFilial("SD4") + "' "
            cQuery +=    " AND SD4.D_E_L_E_T_ = ' ' "
            cQuery +=    " AND SD4.D4_OP      = '" + AllTrim(&(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)')) + "' "
            cQuery +=  " ORDER BY 1 " //Ordenado pela sequencia da estrutura, para o cliente Inapel.

            cQuery := ChangeQuery(cQuery)

            dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD4,.T.,.T.)
            While !(cAliasSD4)->(Eof())

               aAdd(aEmpen,{(cAliasSD4)->(D4_TRT)  ,; //Seq. estrutura
                            (cAliasSD4)->(D4_COD)  ,; //Código do empenho
                            (cAliasSD4)->(D4_LOCAL),; //Local de estoque
                            (cAliasSD4)->(D4_QUANT),; //Quantidade
                            (cAliasSD4)->(RECSD4)  ,; //Recno
                            (cAliasSD4)->(D4_DATA)  ; //Data empenho
                            })

               
               cRoteiro  := (cAliasSD4)->(D4_ROTEIRO)
               cOperacao := (cAliasSD4)->(D4_OPERAC)  
               
               //Se operação em branco, mandar a última operação
               If Empty(cOperacao)
                  If !Empty(cFiltroG2)
                     cAliasOper := GetNextAlias()
                     cQuery := " SELECT SG2.G2_OPERAC "
                     cQuery +=   " FROM " + RetSqlName("SG2") + " SG2 "
                     cQuery +=  " WHERE SG2.G2_FILIAL  = '" + xFilial("SG2") + "' "
                     cQuery +=    " AND SG2.D_E_L_E_T_ = ' ' "
                     cQuery +=    " AND SG2.G2_PRODUTO = '" + &(cPont+'->(C2_PRODUTO)') + "' "
                     cQuery +=    " AND SG2.G2_CODIGO  = '" + &(cPont+'->(C2_ROTEIRO)') + "' "
                     cQuery +=    " AND (" + cFiltroG2 + ") "
                     cQuery += " ORDER BY SG2.G2_OPERAC DESC "
                     cQuery := ChangeQuery(cQuery)
                     dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasOper,.T.,.T.)
                     If (cAliasOper)->(!Eof())
                        cOperacao := (cAliasOper)->(G2_OPERAC)
                     EndIf
                     (cAliasOper)->(dbCloseArea())
                  Else
                     SG2->(dbSeek(xFilial('SG2')+&(cPont+'->C2_PRODUTO')+&(cPont+'->C2_ROTEIRO')))
                     If !SG2->(dbSeek(xFilial("SG2")+&(cPont+'->C2_PRODUTO')+&(cPont+'->C2_ROTEIRO')+Replicate("z",TamSX3("G2_OPERAC")[1]),.T.))
                        SG2->(dbSkip(-1))
                     EndIf
                     cOperacao := SG2->G2_OPERAC
                  EndIf
               Endif              
               
               // Se não existe D4_ROTEIRO, verificar SGF
               // Se não achar relação na SGF, enviar última operação do roteiro 
               SGF->(dbSetOrder(2))
               SHY->(dbSetOrder(1))
               If SHY->(dbSeek(xFilial("SHY")+&(cPont+"->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)")))
                  If !SHY->(dbSeek(xFilial("SHY")+SHY->(HY_OP+HY_ROTEIRO)+Replicate("z",TamSX3("G2_OPERAC")[1]),.T.))
                     SHY->(dbSkip(-1))
                  EndIf
            
                  cRoteiro := SHY->HY_ROTEIRO
                  If SGF->(dbSeek(xFilial("SGF")+&(cPont+"->C2_PRODUTO")+SHY->HY_ROTEIRO+(cAliasSD4)->D4_COD))
                     cOperacao := SGF->GF_OPERAC
                  Else
                     If !Empty(cFiltroG2)
                        cAliasOper := GetNextAlias()
                        cQuery := " SELECT SHY.HY_OPERAC "
                        cQuery +=   " FROM " + RetSqlName("SHY") + " SHY "
                        cQuery +=  " WHERE SHY.HY_FILIAL  = '" + xFilial("SHY") + "' "
                        cQuery +=    " AND SHY.D_E_L_E_T_ = ' ' "
                        cQuery +=    " AND SHY.HY_OP      = '" + &(cPont+"->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)") + "' "
                        cQuery += " AND SHY.HY_OPERAC IN ( SELECT SG2.G2_OPERAC "
                        cQuery +=                          " FROM " + RetSqlName("SG2") + " SG2 "
                        cQuery +=                         " WHERE SG2.G2_FILIAL  = '" + xFilial("SG2") + "' "
                        cQuery +=                           " AND SG2.G2_CODIGO  = '" + &(cPont+'->C2_ROTEIRO') + "' "
                        cQuery +=                           " AND SG2.G2_PRODUTO = '" + &(cPont+'->C2_PRODUTO') + "' "
                        cQuery +=                           " AND SG2.D_E_L_E_T_ = ' ' "
                        cQuery +=                           " AND (" + cFiltroG2 + ") )"
                        cQuery += " ORDER BY SHY.HY_OPERAC DESC "
                        
                        cQuery := ChangeQuery(cQuery)
                        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasOper,.T.,.T.)
                        
                        If (cAliasOper)->(!Eof())
                           cOperacao := (cAliasOper)->(HY_OPERAC)
                        EndIf
                        (cAliasOper)->(dbCloseArea())
                     Else
                        cOperacao := SHY->HY_OPERAC
                     EndIf
                  EndIf
               Else
                  SG2->(dbSeek(xFilial('SG2')+&(cPont+'->C2_PRODUTO')+&(cPont+'->C2_ROTEIRO')))
                  If !SG2->(dbSeek(xFilial("SG2")+&(cPont+'->C2_PRODUTO')+&(cPont+'->C2_ROTEIRO')+Replicate("z",TamSX3("G2_OPERAC")[1]),.T.))
                     SG2->(dbSkip(-1))
                  EndIf
                  cRoteiro := &(cPont+'->C2_ROTEIRO')
                  If SGF->(dbSeek(xFilial("SGF")+&(cPont+"->C2_PRODUTO")+cRoteiro+(cAliasSD4)->D4_COD+(cAliasSD4)->D4_TRT))
                     cOperacao := SGF->GF_OPERAC
                  Else
                     If !Empty(cFiltroG2)
                        cAliasOper := GetNextAlias()
                        cQuery := " SELECT SG2.G2_OPERAC "
                        cQuery +=   " FROM " + RetSqlName("SG2") + " SG2 "
                        cQuery +=  " WHERE SG2.G2_FILIAL  = '" + xFilial("SG2") + "' "
                        cQuery +=    " AND SG2.D_E_L_E_T_ = ' ' "
                        cQuery +=    " AND SG2.G2_PRODUTO = '" + &(cPont+'->(C2_PRODUTO)') + "' "
                        cQuery +=    " AND SG2.G2_CODIGO  = '" + &(cPont+'->(C2_ROTEIRO)') + "' "
                        cQuery +=    " AND (" + cFiltroG2 + ") "
                        cQuery += " ORDER BY SG2.G2_OPERAC DESC "
                        cQuery := ChangeQuery(cQuery)
                        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasOper,.T.,.T.)
                        If (cAliasOper)->(!Eof())
                           cOperacao := (cAliasOper)->(G2_OPERAC)
                        EndIf
                        (cAliasOper)->(dbCloseArea())
                     Else
                        cOperacao := SG2->G2_OPERAC
                     EndIf
                  EndIf
               Endif
               If Empty(cRoteiro)
                  cRoteiro := &(cPont+'->(C2_ROTEIRO)')
               EndIf
               aAdd(aEmpen[Len(aEmpen)],cRoteiro) //Código Roteiro
               aAdd(aEmpen[Len(aEmpen)],cOperacao) //Código Operação
                
               aAdd(aEmpen[Len(aEmpen)],(cAliasSD4)->(D4_LOTECTL)) //Código do Lote
               aAdd(aEmpen[Len(aEmpen)],(cAliasSD4)->(D4_NUMLOTE)) //Código do Sub-Lote
               aAdd(aEmpen[Len(aEmpen)],ConvDati650(STOD((cAliasSD4)->(D4_DTVALID)))) //Validade
               
               (cAliasSD4)->(dbSkip())
            End
            (cAliasSD4)->(dbCloseArea())
         EndIf
         SB1->(dbSetOrder(1))
         SDC->(dbSetOrder(2))
         For nI := 1 To Len(aEmpen)

            //PE MTI650FILC - Filtrar Componentes para não compor a lista de materiais
            lConsComp := .T.
            If lFilComp
               lConsComp := ExecBlock("MTI650FILC",.F.,.F.,{; 
                                                            &(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)'),;
                                                            aEmpen[nI,D4COD],;
                                                            aEmpen[nI,D4TRT],;
                                                            aEmpen[nI,D4LOTECTL],;
                                                            aEmpen[nI,D4NUMLOTE],;
                                                            aEmpen[nI,D4LOCAL],;
                                                            aEmpen[nI,D4QUANT],;
                                                            aEmpen[nI,D4RECNO],;
                                                            })
               If ValType(lConsComp) != "L"
                  lConsComp := .T.
               EndIf
            EndIf
   
            If lConsComp
               SB1->(dbSeek(xFilial("SB1")+aEmpen[nI,D4COD]))

               If lDescProd
                    cDescProd := ExecBlock("MTI650DESC",.F.,.F.,{aEmpen[nI,D4COD], aEmpen[nI,D4RECNO]}) 
               Else
                    cDescProd := Posicione("SB1",1,xFilial("SB1")+aEmpen[nI,D4COD],"B1_DESC")
               EndIf

                if !Empty(cDescProd)
                    cDescProd := AllTrim(_NoTags(cDescProd))
                EndIf

               cXmlRet +=       '<MaterialOrder>' //
               cXmlRet +=          '<ProductionOrderNumber>'+ AllTrim(&(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)')) +'</ProductionOrderNumber>' //Número Ordem Produção
               cXmlRet +=          '<MaterialID>'+ cValToChar(aEmpen[nI,D4RECNO]) +'</MaterialID>' //ID Reserva
               cXmlRet +=          '<MaterialCode>'+ AllTrim(aEmpen[nI,D4COD]) +'</MaterialCode>' //Código Item Reserva
               cXmlRet +=          '<MaterialDescription>'+ cDescProd+'</MaterialDescription>' //Descrição Item
               cXmlRet +=          '<ListOfMaterialGrids />' //Grades, não utilizado no Protheus
               cXmlRet +=          '<FatherItemCode />' //Código Item Pai
               cXmlRet +=          '<FatherItemDescription />' //Descrição Item Pai
               cXmlRet +=          '<ListOfFatherGrids />' //Grades, não utilizado no Protheus
               cXmlRet +=          '<ReferenceCode />' //Código Referência
               cXmlRet +=          '<OrderReferenceNumber />' //Número Ordem Referência
               cXmlRet +=          '<ScriptCode>'+ AllTrim(aEmpen[nI,D4ROTEIRO]) +'</ScriptCode>' //Código Roteiro
               cXmlRet +=          '<ActivityID />' //ID Operação
               cXmlRet +=          '<ActivityCode>'+ AllTrim(aEmpen[nI,D4OPERAC]) +'</ActivityCode>' //Código Operação
               cXmlRet +=          '<LocationCode />' //Código Localização
               cXmlRet +=          '<WarehouseCode>'+ AllTrim(aEmpen[nI,D4LOCAL]) +'</WarehouseCode>' //Código Depósito
               cXmlRet +=          '<LotCode>'+ AllTrim(aEmpen[nI,D4LOTECTL]) +'</LotCode>' //Código Lote/Série
               cXmlRet +=          '<StatusType />' //Estado
               cXmlRet +=          '<UnitOfMeasureCode />' //Unidade Medida
               cXmlRet +=          '<MaterialListCode />' //Código Lista Componentes
               cXmlRet +=          '<MaterialDate>'+ AllTrim(aEmpen[nI,D4DATA]) +'</MaterialDate>' //Data Reserva
               cXmlRet +=          '<MaterialQuantity>'+ cValToChar(aEmpen[nI,D4QUANT]) +'</MaterialQuantity>' //Quantidade Reserva
               cXmlRet +=          '<PertMaterialNumber>'+ AllTrim(aEmpen[nI,D4TRT]) +'</PertMaterialNumber>' //Sequência Reserva
               cXmlRet +=          '<ReportQuantity />' //Quantidade Atendida
            
               cReqType := " "
            
               If SuperGetMv("MV_REQAUT",.F.,"A") == "A"
                  cReqType := "2"
               Else
                  If SB1->B1_APROPRI == "D"
                     cReqType := "1"
                  ElseIf SB1->B1_APROPRI == "I"
                     cReqType := "2"
                  EndIf
               EndIf

               cXmlRet +=          '<RequestType>'+cReqType+'</RequestType>'
               lGera := .T.
               If Rastro(aEmpen[nI,D4COD]) .And. Empty(aEmpen[nI,D4LOTECTL]) .And. Empty(aEmpen[nI,D4NUMLOTE])
                  lGera := .F.
               EndIf
               If lGera
                  cSeek := xFilial("SDC")+PadR(aEmpen[nI,D4COD],TamSX3("DC_PRODUTO")[1])+;
                                          PadR(aEmpen[nI,D4LOCAL],TamSX3("DC_LOCAL")[1])+;
                                          PadR(&(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)'),TamSX3("DC_OP")[1])+;
                                          PadR(aEmpen[nI,D4TRT],TamSX3("DC_TRT")[1])+;
                                          PadR(aEmpen[nI,D4LOTECTL],TamSX3("DC_LOTECTL")[1])+;
                                          PadR(aEmpen[nI,D4NUMLOTE],TamSX3("DC_NUMLOTE")[1])
                  If SDC->(dbSeek(cSeek))
                     cXmlRet +=       '<ListOfAllocatedMaterial>'
                     While SDC->(!Eof()) .And. ;
                           SDC->(DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE) == cSeek
                        cXmlRet +=       '<AllocatedMaterial>'
                        cXmlRet +=          '<WarehouseCode>'+ AllTrim(SDC->DC_LOCAL) +'</WarehouseCode>'
                        cXmlRet +=          '<LotCode>'+ AllTrim(SDC->DC_LOTECTL) +'</LotCode>'
                        cXmlRet +=          '<LocationCode>'+ AllTrim(SDC->DC_LOCALIZ) +'</LocationCode>'
                        cXmlRet +=          '<ActivityCode>'+ AllTrim(aEmpen[nI,D4OPERAC]) +'</ActivityCode>'
                        cXmlRet +=          '<ScriptCode>'+ AllTrim(aEmpen[nI,D4ROTEIRO]) +'</ScriptCode>'
                        cXmlRet +=          '<AllocationQuantity>'+ cValToChar(SDC->DC_QUANT) +'</AllocationQuantity>'
                        cXmlRet +=          '<AllocationType>3</AllocationType>'
                        cXmlRet +=          '<SubLoteCode>'+ AllTrim(SDC->DC_NUMLOTE) +'</SubLoteCode>'
                        cXmlRet +=          '<NumberSeries>'+ AllTrim(SDC->DC_NUMSERI) +'</NumberSeries>'
                        cXmlRet +=          '<LotDueDate>'+ AllTrim(aEmpen[nI,D4DTVALID]) +'</LotDueDate>'
                        cXmlRet +=       '</AllocatedMaterial>'   
                        SDC->(dbSkip())
                     End
                     cXmlRet +=       '</ListOfAllocatedMaterial>'
                  Else
                     If !Localiza(aEmpen[nI,D4COD])
                        cXmlRet +=    '<ListOfAllocatedMaterial>'
                        cXmlRet +=       '<AllocatedMaterial>'
                        cXmlRet +=          '<WarehouseCode>'+ AllTrim(aEmpen[nI,D4LOCAL]) +'</WarehouseCode>'
                        cXmlRet +=          '<LotCode>'+ AllTrim(aEmpen[nI,D4LOTECTL]) +'</LotCode>'
                        cXmlRet +=          '<LocationCode />'
                        cXmlRet +=          '<ActivityCode>'+ AllTrim(aEmpen[nI,D4OPERAC]) +'</ActivityCode>'
                        cXmlRet +=          '<ScriptCode>'+ AllTrim(aEmpen[nI,D4ROTEIRO]) +'</ScriptCode>'
                        cXmlRet +=          '<AllocationQuantity>'+ cValToChar(aEmpen[nI,D4QUANT]) +'</AllocationQuantity>'
                        cXmlRet +=          '<AllocationType>3</AllocationType>'
                        cXmlRet +=          '<SubLoteCode>'+ AllTrim(aEmpen[nI,D4NUMLOTE]) +'</SubLoteCode>'
                        cXmlRet +=          '<NumberSeries />'
                        cXmlRet +=          '<LotDueDate>'+ AllTrim(aEmpen[nI,D4DTVALID]) +'</LotDueDate>'
                        cXmlRet +=       '</AllocatedMaterial>'
                        cXmlRet +=    '</ListOfAllocatedMaterial>'
                     EndIf
                  EndIf
               EndIf
               cXmlRet +=       '</MaterialOrder>'
            EndIf
         Next nI
      EndIf
      cXmlRet +=    '</ListOfMaterialOrders>'
      //##################
      //FIM COMPONENTES
      //##################
            
      //Splits da ordem de produção
      If nIntSFC == 1
         dbSelectArea("CYY")
         CYY->(dbSetOrder(1))
         dbSelectArea("CY9")
         CY9->(dbSetOrder(1))
         If CYY->(dbSeek(xFilial("CYY")+&(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)')))
            cXmlRet += '<ListOfQuotaActivity>' //Splits
            While CYY->(!Eof()) .And. ;
                  AllTrim(CYY->(CYY_FILIAL+CYY_NRORPO)) == AllTrim(xFilial("CYY")+&(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)'))
               CY9->(dbSeek(xFilial("CY9")+CYY->(CYY_NRORPO+CYY_IDAT)))
               cXmlRet += '<QuotaActivity>'
               cXmlRet +=    '<ProductionOrderNumber>'+ AllTrim(CY9->CY9_NRORPO) +'</ProductionOrderNumber>'
               cXmlRet +=    '<ControlType></ControlType>'
               cXmlRet +=    '<ActivityID>'+ AllTrim(CY9->CY9_CDAT) +'</ActivityID>'
               cXmlRet +=    '<ItemCode>'+ AllTrim(CYY->CYY_CDAC) +'</ItemCode>'
               cXmlRet +=    '<ItemDescription>'+ AllTrim(_NoTags(Posicione("SB1",1,xFilial("SB1")+CYY->CYY_CDAC,"B1_DESC"))) +'</ItemDescription>'
               cXmlRet +=    '<StartActivityDateTime>'+getDateTime(CYY->CYY_DTBGAT,CYY->CYY_HRBGAT)+'</StartActivityDateTime>'
               cXmlRet +=    '<EndActivityDateTime>'+getDateTime(CYY->CYY_DTEDAT,CYY->CYY_HREDAT)+'</EndActivityDateTime>'
               cXmlRet +=    '<ApprovedQuantity>'+cValToChar(CYY->CYY_QTATAP)+'</ApprovedQuantity>'
               cXmlRet +=    '<ScrapQuantity>'+cValToChar(CYY->CYY_QTATRF)+'</ScrapQuantity>'
               cXmlRet +=    '<MachineCode>'+ AllTrim(CYY->CYY_CDMQ) +'</MachineCode>'
               cXmlRet +=    '<MachineDescription>'+ AllTrim(_NoTags(POSICIONE("CYB",1,XFILIAL("CYB")+CYY->CYY_CDMQ,"CYB_DSMQ")))+'</MachineDescription>'
               cXmlRet +=    '<ActivityQuantity>'+ cValToChar(CYY->CYY_QTAT)+'</ActivityQuantity>'
               cXmlRet +=    '<StandardSetup>'+ cValToChar(CYY->CYY_QTPASU)+'</StandardSetup>'
               cXmlRet +=    '<StandardActivity>'+ cValToChar(CYY->CYY_QTPAAT)+'</StandardActivity>'
               cXmlRet +=    '<StandardPostprocessing>'+ cValToChar(CYY->CYY_QTPAPP)+'</StandardPostprocessing>'
               cXmlRet +=    '<StandardMachine>'+ cValToChar(CYY->CYY_QTPAMQ)+'</StandardMachine>'
               cXmlRet +=    '<StandardOperator>'+ cValToChar(CYY->CYY_QTPAOE)+'</StandardOperator>'
               cXmlRet +=    '<UsedCapacity>'+ cValToChar(CYY->CYY_QTVMAT)+'</UsedCapacity>'
               cXmlRet +=    '<ActivityTimeQuantity>'+ AllTrim(CYY->CYY_HRDI)+'</ActivityTimeQuantity>'
               cXmlRet +=    '<ReportQuantity>'+ cValToChar(CYY->CYY_QTATRP)+'</ReportQuantity>'
               cXmlRet +=    '<ReworkQuantity>'+ cValToChar(CYY->CYY_QTATRT)+'</ReworkQuantity>'
               cXmlRet +=    '<StartSetupDateTime>'+ getDateTime(CYY->CYY_DTBGSU,CYY->CYY_HRBGSU)+'</StartSetupDateTime>'
               cXmlRet +=    '<EndSetupDateTime>'+ getDateTime(CYY->CYY_DTEDSU,CYY->CYY_HREDSU)+'</EndSetupDateTime>'
               cXmlRet +=    '<TimeSetup>'+ cValToChar(CY9->CY9_QTTESU)+'</TimeSetup>'
               cXmlRet +=    '<TimeMachine>'+ cValToChar(CY9->CY9_QTTEMQ)+'</TimeMachine>'
               cXmlRet +=    '<TimeOperator>'+ cValToChar(CY9->CY9_QTTERC)+'</TimeOperator>'
               cXmlRet +=    '<TimePostprocessing>'+ cValToChar(CY9->CY9_QTTEPP)+'</TimePostprocessing>'
               cXmlRet +=    '<QuotaActivityID>'+ AllTrim(CYY->CYY_IDATQO)+'</QuotaActivityID>'
               cXmlRet +=    '<WorkCenterCode>'+ AllTrim(CY9->CY9_CDCETR)+'</WorkCenterCode>'
               cXmlRet +=    '<ReportedSplit>'+ Iif(CYY->CYY_LGQORP,"TRUE","FALSE")+'</ReportedSplit>'
               cXmlRet +=    '<StatusActivityType>'+ AllTrim(CYY->CYY_TPSTAT) +'</StatusActivityType>'
               cXmlRet +=    '<ListOfQuotaActivityTools>'
               cXmlRet +=       '<QuotaActivityTool>'
               cXmlRet +=          '<ToolCode>'+ AllTrim(CYY->CYY_CDFE)+'</ToolCode>'
               cXmlRet +=          '<ToolQuantity>'+ cValToChar(CYY->CYY_QTFE)+'</ToolQuantity>'
               cXmlRet +=       '</QuotaActivityTool>'
               cXmlRet +=    '</ListOfQuotaActivityTools>'
               cXmlRet += '</QuotaActivity>'
               CYY->(dbSkip())
            End
            cXmlRet += '</ListOfQuotaActivity>'
         Else
            cXmlRet += '<ListOfQuotaActivity />' //Splits
         EndIf
      Else
         cXmlRet += '<ListOfQuotaActivity />' //Splits
      EndIf
      cXmlRet +=    '<ListOfRequestOrders />'
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Ponto de Entrada para incluir tags especificas               ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If lIntegPPI .And. ExistBlock("PCPADDTAGS")
         cAddXml := ExecBlock("PCPADDTAGS",.F.,.F.,{cEntity,cEvent,cPont})
         If ValType(cAddXml) == "C"
             cXMLRet += cAddXml
         EndIf
     EndIf      
      cXmlRet += '</BusinessContent>'

      If lIntegPPI
         completXml(@cXMLRet)
      EndIf

   EndIf

   If !lIntegPPI
      AdpLogEAI(5, "MATI650", cXMLRet, lRet)
   EndIf
   RestArea(aAreaAnt)
Return {lRet, cXmlRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} IntOPExt
Monta o InternalID da Ordem de produção de acordo com o código passado
no parâmetro.

@param   cEmpresa   Código da empresa (Default cEmpAnt)
@param   cFil       Código da Filial (Default cFilAnt)
@param   cNumOp     Código da ordem de produção (C2_NUM+C2_ITEM+C2_SEQ)
@param   cVersao    Versão da mensagem única (Default 2.000)

@author  Lucas Konrad França
@version P12
@since   02/09/2015
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado.
         No segundo parâmetro uma variável string com o InternalID
         montado.

@sample  IntOPExt(,,'01') irá retornar {.T.,'01|01|01'}
/*/
//-------------------------------------------------------------------
Function IntOPExt(cEmpresa, cFil, cNumOP, cVersao)
   Local aResult    := {}
   Default cEmpresa := cEmpAnt
   Default cFil     := xFilial('SC2')
   Default cVersao  := '2.000'

   If cVersao == '2.000'
      aAdd(aResult, .T.)
      aAdd(aResult, AllTrim(cEmpresa) + '|' + cFil + '|' + AllTrim(cNumOP))
   Else
      aAdd(aResult, .F.)
      aAdd(aResult, STR0005 + Chr(10) + STR0006) // "Versão da ordem de produção não suportada." "As versões suportadas são: 2.000"
   EndIf   
Return aResult

// --------------------------------------------------------------------------------------
/*/{Protheus.doc} getStatusT
Retorna o StatusType da OP

@author  Lucas Konrad França
@version P11
@since   04/09/2015
@return  cStatus -> Status da ordem
/*/
// --------------------------------------------------------------------------------------
Static Function getStatusT()
   Local cStatus    := ""
   Local cQuery     := ""
   Local cAliasTemp := ""
   Local dEmissao   := dDataBase
   Local nRegSD3    := 0
   Local nRegSH6    := 0

   If &(cPont+'->C2_TPOP') == "P"
      cStatus := "1" //Prevista/Não Iniciada
   Else
      cAliasTemp:= "SD3TMP"
      cQuery     := "  SELECT COUNT(*) AS RegSD3, MAX(D3_EMISSAO) AS EMISSAO "
      cQuery     += "   FROM " + RetSqlName('SD3')
      cQuery     += "   WHERE D3_FILIAL   = '" + xFilial('SD3')+ "'"
      cQuery     += "     AND D3_OP       = '" + &(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)') + "'"
      cQuery     += "     AND D3_ESTORNO <> 'S' "
      cQuery     += "     AND D_E_L_E_T_  = ' '"
      cQuery    += "       GROUP BY D3_EMISSAO "
      cQuery    := ChangeQuery(cQuery)
      dbUseArea (.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)
   
      If !SD3TMP->(Eof())
         dEmissao := STOD(SD3TMP->EMISSAO)
         nRegSD3 := SD3TMP->RegSD3
      EndIf
      (cAliasTemp)->(dbCloseArea())
      cAliasTemp:= "SH6TMP"
      cQuery     := "  SELECT COUNT(*) AS RegSH6 "
      cQuery     += "   FROM " + RetSqlName('SH6')
      cQuery     += "   WHERE H6_FILIAL   = '" + xFilial('SH6')+ "'"
      cQuery     += "     AND H6_OP       = '" + &(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)') + "'"
      cQuery     += "     AND D_E_L_E_T_  = ' '"
      cQuery    := ChangeQuery(cQuery)
      dbUseArea ( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)
   
      If !SH6TMP->(Eof())
         nRegSH6 := SH6TMP->RegSH6
      EndIf
      (cAliasTemp)->(dbCloseArea())
      
      If &(cPont+'->C2_TPOP') == "F" .And. Empty(&(cPont+'->C2_DATRF')) .And. (nRegSD3 < 1 .And. nRegSH6 < 1) .And. (Max(dDataBase - &(cPont+'->C2_DATPRI'),0) < If(&(cPont+'->C2_DIASOCI')==0,1,&(cPont+'->C2_DIASOCI'))) //Em aberto
         cStatus := "1" //Em aberto/Não iniciada
      Else
         If &(cPont+'->C2_TPOP') == "F" .And. Empty(&(cPont+'->C2_DATRF')) .And. (nRegSD3 > 0 .Or. nRegSH6 > 0) .And. (Max((ddatabase - dEmissao),0) > If(&(cPont+'->C2_DIASOCI') >= 0,-1,&(cPont+'->C2_DIASOCI'))) //Iniciada
            cStatus := "6" //Iniciada
         Else
            If &(cPont+'->C2_TPOP') == "F" .And. Empty(&(cPont+'->C2_DATRF')) .And. (Max((ddatabase - dEmissao),0) > &(cPont+'->C2_DIASOCI') .Or. Max((ddatabase - &(cPont+'->C2_DATPRI')),0) > &(cPont+'->C2_DIASOCI'))   //Ociosa
               cStatus := "9" //Suspensa/Ociosa
            Else
               If &(cPont+'->C2_TPOP') == "F" .And. !Empty(&(cPont+'->C2_DATRF')) .And. &(cPont+'->(C2_QUJE < C2_QUANT)')  /*Enc.Parcialmente*/ .Or. ;
                  &(cPont+'->C2_TPOP') == "F" .And. !Empty(&(cPont+'->C2_DATRF')) .And. &(cPont+'->(C2_QUJE >= C2_QUANT)') //Enc.Totalmente
                  cStatus := "7" //Finalizada
               Else
                  cStatus := "1"
               EndIf
            EndIf
         EndIf
      EndIf
   EndIf

Return cStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} getClient
Monta o InternalID da Ordem de produção de acordo com o código passado
no parâmetro.

@param   cPedido   Código do pedido da Ordem de produção

@author  Lucas Konrad França
@version P12
@since   03/09/2015
@return  cNome - Nome do cliente (A1_NOME)

@sample  getClient('123456') irá retornar 'TOTVS'
/*/
//-------------------------------------------------------------------
Static Function getClient(cPedido)
   Local cNome := ""
   Local aArea := GetArea()

   If !Empty(cPedido)
      dbSelectArea("SC5")
      SC5->(dbSetOrder(1))
      If SC5->(dbSeek(xFilial("SC5")+cPedido))
         dbSelectArea("SA1")
         SA1->(dbSetOrder(1))
         If SA1->(dbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))
            cNome := AllTrim(SA1->A1_NOME)
         EndIf
      EndIf
   EndIf
   RestArea(aArea)
Return cNome

// --------------------------------------------------------------------------------------
/*/{Protheus.doc} getCTrab
Busca a descrição do Centro de trabalho

@param   cCTrab código do centro de trabalho

@author  Lucas Konrad França
@version P12
@since   17/08/2015
@return  cResult Variavel com o valor obtido
/*/
// --------------------------------------------------------------------------------------
Static Function getCTrab(cCTrab)
   Local cResult  := ""
   Local aAreaAnt := GetArea()

   dbSelectArea("SHB")
   SHB->(dbSetOrder(1))

   If !Empty(cCTrab) .And. SHB->(dbSeek(xFilial("SHB") + cCTrab))
      cResult := AllTrim(SHB->HB_NOME)
   EndIf

   RestArea(aAreaAnt)
Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} getTimeG2()
Calcula o tempo de máquina utilizando a SG2.

@param   nQuantOP - Quantidade da ordem de produção

@author  Lucas Konrad França
@version P12
@since   04/09/2015
@return  nTemp - Tempo de máquina calculado
/*/
//-------------------------------------------------------------------
Static Function getTimeG2(nQuantOP)
   Local nTemp      := 0
   Local nQuantAloc := 0
   Local cTempPad   := 0

   cTempPad := A690HoraCt(SG2->G2_TEMPAD)

   If SG2->G2_TPOPER $ " 1"
      nTemp := Round(nQuantOP * ( IIf( cTempPad == 0, 1, cTempPad) / IIf( SG2->G2_LOTEPAD == 0, 1, SG2->G2_LOTEPAD ) ),5)
      dbSelectArea("SH1")
      dbSeek(xFilial("SH1")+SG2->G2_RECURSO)
      If Found() .And. SH1->H1_MAOOBRA # 0
         nTemp := Round( nTemp / SH1->H1_MAOOBRA,5)
      EndIf
   ElseIf SG2->G2_TPOPER == "4"
      nQuantAloc := nQuantOP % IIf(SG2->G2_LOTEPAD == 0, 1, SG2->G2_LOTEPAD)
      nQuantAloc := Int(nQuantOP) + If(nQuantAloc>0,IIf(SG2->G2_LOTEPAD == 0, 1, SG2->G2_LOTEPAD)-nQuantAloc,0)
      nTemp := Round(nQuantAloc * ( IIf( cTempPad == 0, 1, cTempPad) / IIf( SG2->G2_LOTEPAD == 0, 1, SG2->G2_LOTEPAD ) ),5)
      dbSelectArea("SH1")
      dbSeek(xFilial("SH1")+SG2->G2_RECURSO)
      If Found() .And. SH1->H1_MAOOBRA # 0
         nTemp :=Round( nTemp / SH1->H1_MAOOBRA,5)
      EndIf
   ElseIf SG2->G2_TPOPER == "2" .Or. SG2->G2_TPOPER == "3"
      nTemp := IIf( cTempPad == 0 , 1 , cTempPad )
   EndIf

Return nTemp

//-------------------------------------------------------------------
/*/{Protheus.doc} gUnitTime()
Retorna a unidade de tempo.

@author  Lucas Konrad França
@version P12
@since   04/09/2015
@return  cUnidade - Unidade de tempo. (1->Horas; 2->Minutos; 3->Segundos; 4->Dias)
/*/
//-------------------------------------------------------------------
Static Function gUnitTime()
   Local cUnidade := "1"
Return cUnidade

//-------------------------------------------------------------------
/*/{Protheus.doc} completXml()
Adiciona o cabeçalho da mensagem quando utilizado integração com o PPI.

@param   cXML  - XML gerado pelo adapter. Parâmetro recebido por referência.

@author  Lucas Konrad França
@version P12
@since   13/08/2015
@return  Nil
/*/
//-------------------------------------------------------------------
Static Function completXml(cXML)
   Local cCabec     := ""
   Local cCloseTags := ""
   Local cGenerated := ""

   cGenerated := getDateTime(Date(), Time()) // SubStr(DTOS(Date()), 1, 4) + '-' + SubStr(DTOS(Date()), 5, 2) + '-' + SubStr(DTOS(Date()), 7, 2) + 'T' + Time()

   cCabec := '<?xml version="1.0" encoding="UTF-8" ?>'
   cCabec += '<TOTVSMessage xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="xmlschema/general/events/ProductionOrder_2_004.xsd">'
   cCabec +=     '<MessageInformation version="2.004">'
   cCabec +=         '<UUID>1</UUID>'
   cCabec +=         '<Type>BusinessMessage</Type>'
   cCabec +=         '<Transaction>ProductionOrder</Transaction>'
   cCabec +=         '<StandardVersion>1.0</StandardVersion>'
   cCabec +=         '<SourceApplication>SIGAPCP</SourceApplication>'
   cCabec +=         '<CompanyId>'+cEmpAnt+'</CompanyId>'
   cCabec +=         '<BranchId>'+cFilAnt+'</BranchId>'
   cCabec +=         '<UserId>'+__cUserId+'</UserId>'
   cCabec +=         '<Product name="'+FunName()+'" version="'+GetRPORelease()+'"/>'
   cCabec +=         '<GeneratedOn>' + cGenerated +'</GeneratedOn>'
   cCabec +=         '<ContextName>PROTHEUS</ContextName>'
   cCabec +=         '<DeliveryType>Sync</DeliveryType>'
   cCabec +=     '</MessageInformation>'
   cCabec +=     '<BusinessMessage>'

   cCloseTags := '</BusinessMessage>'
   cCloseTags += '</TOTVSMessage>'
   
   cXML := cCabec + cXML + cCloseTags

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} getDateTime()
Formata uma data e uma hora para o formato DateTime

@param   dDate  - Data que será transformada para String
@param   cHora  - Hora

@author  Lucas Konrad França
@version P12
@since   03/09/2015
@return  cDataHora
/*/
//-------------------------------------------------------------------
Static Function getDateTime(dDate, cHora)
   Local cDataHora := ""
   Local cDate     := ""
   
   If !Empty(dDate) .And. !Empty(cHora)
      If Empty(cHora)
         cHora := "00:00:00"
      EndIf
      If ValType(dDate) == "C"
        dDate := StoD(StrTran(dDate,"-",""))
      EndIf
      cDate := DtoS(dDate)
   
      cDataHora := SubStr(cDate, 1, 4) + '-' + SubStr(cDate, 5, 2) + '-' + SubStr(cDate, 7, 2)
      If !Empty(cHora)
         cDataHora += 'T' + cHora
      EndIf
   EndIf
Return cDataHora

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getDate

Retorna somente a data de uma variável datetime

@param dDateTime - Variável DateTime

@return dDate - Retorna a data.

@author  Lucas Konrad França
@version P12
@since   24/09/2015
/*/
//-------------------------------------------------------------------------------------------------
Static Function getDate(dDateTime)
   Local dDate := Nil
   If AT("T",dDateTime) > 0
      dDate := StrTokArr(dDateTime,"T")[1]
   Else
      dDate := StrTokArr(AllTrim(dDateTime)," ")[1]
   EndIf
   dDate := SubStr(dDate,1,4)+SubStr(dDate,6,2)+SubStr(dDate,9,2)
Return dDate

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getOPType

Identifica o valor correspondente da tag Type para o campo C2_TPPR

@param cType   - Valor recebido na mensagem

@return cType  - Valor correto para gravar no campo C2_TPPR

@author  Lucas Konrad França
@version P12
@since   27/09/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function getOPType(cType)
   If cType == "1"
      cType := "I"
   ElseIf cType == "2"
      cType := "E"
   ElseIf cType $ "3|4|5|6|7|8|9"
      cType := "O"
   Else
      cType := Nil
   EndIf
Return cType

//-------------------------------------------------------------------------------------------------
/*{Protheus.doc} F650GetInt
Recebe um codigo, busca seu InternalID e faz a quebra da chave

@param   cCode    InternalID recebido na mensagem.
@param   cMarca   Produto que enviou a mensagem

@author  Lucas Konrad França
@version P12
@since   01/10/2018

@return  aRetorno Array contendo no primeiro parâmetro uma variável
lógica indicando se o registro foi encontrado no de/para.
No segundo parâmetro uma variável array com a empresa,
filial e a numeração da OP.
*/
//-------------------------------------------------------------------------------------------------
Function F650GetInt(cCode, cMarca)
   Local cValInt  := ''
   Local aRetorno := {}
   Local aAux     := {}
   Local nTamNum  := 0
   Local nTamItem := 0
   Local nTamSeq  := 0
   Local nTamGrd  := 0

   cValInt := RTrim(CFGA070INT(cMarca, "SC2", "C2_NUM", cCode))
   
   If !Empty(cValInt)
      aAdd(aRetorno,.T.)
      aAux     := Separa(cValInt,'|')
      //Ajusta o tamanho da numeração da OP.
      nTamNum  := TamSX3("C2_NUM")[1]
      nTamItem := TamSX3("C2_ITEM")[1]
      nTamSeq  := TamSX3("C2_SEQUEN")[1]
      nTamGrd  := TamSX3("C2_ITEMGRD")[1]
      aAux[3]  := PadR(aAux[3],nTamNum+nTamItem+nTamSeq+nTamGrd)
      aAdd(aRetorno,aAux)
   Else
      aAdd(aRetorno, .F. )
      aAdd(aRetorno, STR0027 + AllTrim(cCode) ) //"Ordem de produção não encontrada no DE/PARA. -> "
   Endif
Return aRetorno


//-------------------------------------------------------------------------------------------------
/*{Protheus.doc} GetEmpenho
Recebe a lista de materiais da ordem de produção para gerar os empenhos

@param   CxML    XML recebido pelo EAI
@param   cOrdem  Ordem de produção 
@param   nOpc    Se está ocorrendo uma inclusão/alteração da OP
@param   oXml    O Xml que foi passado para o adapter
@param   lRet    Retorno True (Sucesso )  ou False (Com erro)
@param   cXmlRet Retorno das mensagens de erro que ocorreram na execução do mata381
@param   cMarca  Produto da integração


@author  Michelle Ramos Henriques
@version P12
@since   29/10/2018

*/
//-------------------------------------------------------------------------------------------------

Function GetEmpenho(cXml,cOrdem,nOpc, oXmlRec, lRet, cXmlRet, cMarca) 

    Local aXmlLocMat    := {}
    Local acab          := {}
    Local aCabEx        := {}
    Local aOrdemEx      := {}
    Local aEnder        := {}
    Local aLine         := {}
    Local aLineEnder    := {}
    Local aItens        := {}
    Local aEmpenhos     := {}
    Local aAux          := {}
    Local aXmlMatOrd    := {}
	Local aLineNLI      := {}
    Local nI            := 0
    Local nI2           := 0
    Local cProdOrder    := ""
    Local cMatNumber    := ""
    Local cMatCode      := ""
    Local cScriptCod    := ""
    Local cActivity     := ""
    Local cWarehouse    := ""
    Local cLotCode      := ""  
    Local cSubLotCod    := ""  
    Local cSubLotCo2    := ""  
    Local cLocatCode    := ""
    Local cAllocQdt     := ""
    Local cSeries       := ""
    Local cAliasOper    := ""
    Local cError        := ""
    Local cWarning      := ""
    Local dMatDate      := StoD("")
    Local nTamTRT       := TamSx3("D4_TRT")[1]                 
    Local nTamOP        := TamSx3("D4_OP")[1]                  
    Local nTamCOD       := TamSx3("D4_COD")[1]                 
    Local nTamROTEIR    := TamSx3("D4_ROTEIRO")[1]             
    Local nTamOPERAC    := TamSx3("D4_OPERAC")[1]              
    Local nTamLOCAL     := TamSx3("D4_LOCAL")[1]               
    Local nTamLOTECT    := TamSx3("D4_LOTECTL")[1]             
    Local nTamLOCALI    := TamSx3("DC_LOCALIZ")[1]             
    Local nTamNUMSER    := TamSx3("DC_NUMSERI")[1]
    Local nTamNUMLOT    := TamSx3("D4_NUMLOTE")[1]             
   
    Local nTamNum    := TamSX3("C2_NUM")[1]
    Local nTamItem   := TamSX3("C2_ITEM")[1]
    Local nTamSeq    := TamSX3("C2_SEQUEN")[1]
    Local nTamGrd    := TamSX3("C2_ITEMGRD")[1]

    Default nOpc   := 3

    Private oXmlEmp := oxmlRec   

    if Empty(oXmlEmp)
        oXmlEmp := xmlParser(cXml, "_", @cError, @cWarning)
        If ! (oXmlEmp != Nil .And. Empty(cError) .And. Empty(cWarning))
            cXmlRet := STR0030 //"Erro no parser."
            lRet := .F.
            Return lRet
        EndIf
    Endif


	//Verifica se há lista de materiais no xml
	//Esta verificação somente pode ocorrer na inclusão e se não houver a lista de materiais.
	//Se tiver a tag listOfMaterialOrders e não tiver a tag MaterialOrders, deve excluir os empenhos já existentes
	//Se não possuir a tag listOfMaterialOrders, significa que não haverá a alteração/exclusão dos empenhos.
	If Type("oXmlEmp:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfMaterialOrders") != "U" 

		If Type("oXmlEmp:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfMaterialOrders:_MaterialOrder") == "A"
			aXmlMatOrd := oXmlEmp:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfMaterialOrders:_MaterialOrder
		ElseIf Type("oXmlEmp:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfMaterialOrders:_MaterialOrder") == "O"
			aXmlMatOrd := {oXmlEmp:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfMaterialOrders:_MaterialOrder}
		Endif

		If nOpc == 3 .And. len(aXmlMatOrd) == 0
			lRet := .T.
			Return lRet
		Endif
	Else
		//Se não possuir a tag listOfMaterialOrders, significa que não haverá a alteração/exclusão dos empenhos.
		//Na inclusão, significa que os empenhos serão criados conforme a engenharia.
		lRet := .T.
		Return lRet
	EndIf

	//Verifica se houve movimentação para a OP. Se existir, não permite alterar os empenhos.
    If !canUpdEmp(cOrdem)
        cXmlRet :=STR0031 //"Não é possível alterar os empenhos desta ordem, pois já foram realizadas movimentações para a ordem."
        lRet := .F.
        Return .F.
    EndIf

	aCab  := {}
	aEmpenhos := {}


	//Cabeçalho com o número da OP que serusão dos empenhos.
	aCab := {{"D4_OP",cOrdem,NIL}} 

	For nI:= 1 to len(aXmlMatOrd)

		aLine := {}     

		//Sequencia do empenho
		If XmlChildEx(aXmlMatOrd[nI],"_PERTMATERIALNUMBER") != Nil .And. ;
			!Empty(aXmlMatOrd[nI]:_PertMaterialNumber:Text)
			cMatNumber := aXmlMatOrd[nI]:_PertMaterialNumber:Text

			aAdd(aLine,{"D4_TRT" , Padr(cMatNumber,nTamTRT) ,NIL})
		EndIf

		//Número Ordem Produção / ProductionOrderNumber
		If XmlChildEx(aXmlMatOrd[nI],"_PRODUCTIONORDERNUMBER") != Nil .And. ;
			!Empty(aXmlMatOrd[nI]:_ProductionOrderNumber:Text)
			cProdOrder := aXmlMatOrd[nI]:_ProductionOrderNumber:Text

			If PadR(cProdOrder, nTamOP)  <> cOrdem 
				lRet := .F.
				cXmlRet := STR0029 //"Ordem de produção da lista de materiais não pertence a ordem de produção importada"
				Return lRet
			EndIf
			aAdd(aLine,{"D4_OP" ,PadR(cProdOrder, nTamOP)     ,NIL})
		Else
			aAdd(aLine,{"D4_OP" ,cOrdem  ,NIL})
		EndIf


		//Código Item Reserva / MaterialCode
		If XmlChildEx(aXmlMatOrd[nI],"_MATERIALID") != Nil .And. ;
			!Empty(aXmlMatOrd[nI]:_MaterialID:Text)

			aAux := IntProInt(aXmlMatOrd[nI]:_MaterialID:Text, cMarca)

			If !aAux[1]
				lRet := aAux[1]
				cXmlRet := aAux[2]
				AdpLogEAI(5, "MATI650", cXMLRet, lRet)
				Return lRet
			Else
				cMatCode := PadR(aAux[2][3],nTamCOD)
				aAdd(aLine, {"D4_COD",cMatCode,Nil})
			EndIf
		
		ElseIf XmlChildEx(aXmlMatOrd[nI],"_MATERIALCODE") != Nil .And. ;
			!Empty(aXmlMatOrd[nI]:_MaterialCode:Text)

			cMatCode := aXmlMatOrd[nI]:_MaterialCode:Text
			cMatCode := Padr(cMatCode, nTamCOD)

			aAdd(aLine,{"D4_COD"    , Padr(cMatCode,nTamCOD) ,NIL})
		Else
			lRet := .F.
			cXmlRet := "MaterialCode " + STR0028 // é obrigatório."
			Return lRet
		EndIf

		SB1->(dbSetOrder(1))
		If !SB1->(dbSeek(xFilial("SB1")+cMatCode))
			lRet := .F.
			cXmlRet := STR0024 + AllTrim(cMatCode) + STR0025 //"Produto '"####"' não cadastrado."
			Return lRet
		EndIf

		//Código Roteiro / _ScriptCode
		If XmlChildEx(aXmlMatOrd[nI],"_SCRIPTCODE") != Nil .And. ;
			!Empty(aXmlMatOrd[nI]:_ScriptCode:Text)
			
			cScriptCod := aXmlMatOrd[nI]:_ScriptCode:Text

			aAdd(aLine,{"D4_ROTEIRO",Padr(cScriptCod, nTamROTEIR),NIL})
		EndIf

		//Código Operação / _ActivityCode 
		If XmlChildEx(aXmlMatOrd[nI],"_ACTIVITYCODE") != Nil .And. ;
			!Empty(aXmlMatOrd[nI]:_ActivityCode:Text)
			cActivity := aXmlMatOrd[nI]:_ActivityCode:Text

			aAdd(aLine,{"D4_OPERAC",Padr(cActivity,nTamOPERAC),NIL})
		EndIf            

		//Código Depósito / _WarehouseCode
		If XmlChildEx(aXmlMatOrd[nI],"_WAREHOUSECODE") != Nil .And. ;
			!Empty(aXmlMatOrd[nI]:_WarehouseCode:Text)
			
			cWarehouse := aXmlMatOrd[nI]:_WarehouseCode:Text

			aAdd(aLine,{"D4_LOCAL" ,Padr(cWarehouse,nTamLOCAL),NIL})
		Else
			aAdd(aLine,{"D4_LOCAL" ,SB1->B1_LOCPAD,Nil})
		EndIf

		//Código Lote/Série / _LotCode (lote)
		If XmlChildEx(aXmlMatOrd[nI],"_LOTCODE") != Nil .And. ;
			!Empty(aXmlMatOrd[nI]:_LotCode:Text)
			cLotCode := aXmlMatOrd[nI]:_LotCode:Text
			
			aAdd(aLine,{"D4_LOTECTL",Padr(cLotCode,nTamLOTECT),NIL})
		EndIf

		//endereços dos empenhos:
		cSubLotCod := ""
		If XmlChildEx(aXmlMatOrd[nI],"_LISTOFALLOCATEDMATERIAL") != Nil .And. ;
			!Empty(aXmlMatOrd[nI]:_ListOfAllocatedMaterial)
			If ValType(aXmlMatOrd[nI]:_ListOfAllocatedMaterial:_AllocatedMaterial) == "A"
				aXmlLocMat := aXmlMatOrd[nI]:_ListOfAllocatedMaterial:_AllocatedMaterial
			Else
				aXmlLocMat := {aXmlMatOrd[nI]:_ListOfAllocatedMaterial:_AllocatedMaterial}
			EndIf
			
			If XmlChildEx(aXmlLocMat[1],"_SUBLOTECODE") != Nil .And. ;
				!Empty(aXmlLocMat[1]:_SubLoteCode:Text)
				
				cSubLotCod := aXmlLocMat[1]:_SubLoteCode:Text
				
				aAdd(aLine,{"D4_NUMLOTE",Padr(cSubLotCod,nTamNUMLOT),Nil})
			EndIf
		Else 
			aXmlLocMat := {}
		EndIf

		//Data Reserva / MaterialDate
		If XmlChildEx(aXmlMatOrd[nI],"_MATERIALDATE") != Nil .And. ;
			!Empty(aXmlMatOrd[nI]:_MaterialDate:Text)
			
			dMatDate := StoD(getDate(aXmlMatOrd[nI]:_MaterialDate:Text))

			aAdd(aLine,{"D4_DATA"   ,dMatDate,NIL})
		EndIf

		//Quantidade Reserva / MaterialQuantity
		If XmlChildEx(aXmlMatOrd[nI],"_MATERIALQUANTITY") != Nil .And. ;
			!Empty(aXmlMatOrd[nI]:_MaterialQuantity:Text)
			
			nMatQuant := Val(aXmlMatOrd[nI]:_MaterialQuantity:Text)

			aAdd(aLine,{"D4_QTDEORI",nMatQuant,NIL})
			aAdd(aLine,{"D4_QUANT",nMatQuant,NIL})
		Else
			lRet := .F.
			cXmlRet := "MaterialQuantity" + STR0028 // é obrigatório."
			Return lRet
		EndIf

		//Integração com o PIMS
		// Internal ID da Classe de Valor
		aLineNLI := {}
					
		If	XmlChildEx(aXmlMatOrd[nI],"_CLASSVALUEINTERNALID" ) != Nil .AND. ;
			!EMPTY( aXmlMatOrd[nI]:_ClassValueInternalId:Text )
			
			//Obtém o valor interno
			cValExt := aXmlMatOrd[nI]:_ClassValueInternalId:Text
			aAux := C060GetInt(cValExt, cMarca)
			If aAux[1]
				aAdd( aLineNLI, { "NLI_CLVAL", PadR(aAux[2][3], TamSX3("CTH_CLVL")[1]), Nil } )
			Else
				lRet := .F.
				cXmlRet := STR0032 //"Classe de valor não cadastrada. "
				Return .F.
			EndIf
		Else
			// Classe de Valor
			If 	XmlChildEx(aXmlMatOrd[nI],"_CLASSVALUECODE" ) != Nil .AND. ;
				!EMPTY( aXmlMatOrd[nI]:_ClassValueCode:Text )
				aAdd( aLineNLI, { "NLI_CLVAL", aXmlMatOrd[nI]:_ClassValueCode:Text, Nil } )
			Endif
		Endif

		// Internal ID da Chave Completa da Fazenda
		If XmlChildEx(aXmlMatOrd[nI],"_FARMINTERNALID" ) != Nil .AND. ;
			!EMPTY( aXmlMatOrd[nI]:_FarmInternalId:Text )
			cValExt := aXmlMatOrd[nI]:_FarmInternalId:Text
			cValInt := CFGA070Int(cMarca, 'NN2', 'NN2_CODIGO', AllTrim(cValExt))
			If Empty(cValInt)
				lRet := .F.
				cXmlRet := STR0033 //"Código da fazenda não encontrado."
				Return .F.
			Else
				If cValInt $ "|"   
               aAux := Separa(cValInt,'|')
               cValInt := aAux[3]
            EndIf 
				aAdd( aLineNLI, { "NLI_FAZ", PadR(cValInt, TamSX3("NN2_CODIGO")[1]), NIL } )
			Endif
		Else
			// Codigo da Fazenda
			If 	XmlChildEx(aXmlMatOrd[nI],"_FARMCODE" ) != Nil .AND. ;
				!EMPTY( aXmlMatOrd[nI]:_FarmCode:Text )
				aAdd( aLineNLI, { "NLI_FAZ", aXmlMatOrd[nI]:_FarmCode:Text, NIL } ) 
			Endif
		Endif
 
		// Quantidade do PMS
		If 	XmlChildEx(aXmlMatOrd[nI],"_COMPONENTQUANTITY" ) != Nil .AND. ;
			!EMPTY( aXmlMatOrd[nI]:_ComponentQuantity:Text )
			aAdd( aLineNLI, { "NLI_QTCOMP", val(replace(alltrim(transform(val(aXmlMatOrd[nI]:_ComponentQuantity:Text),X3Picture("NLI_QTCOMP"))),",",".")), NIL } )
		Endif

		// Quantidade do PMS
		If 	XmlChildEx(aXmlMatOrd[nI],"_PMSQUANTITY" ) != Nil .AND. ;
			!EMPTY( aXmlMatOrd[nI]:_PMSQuantity:Text )
			aAdd( aLineNLI, { "NLI_PMSQTD", val(replace(alltrim(transform(val(aXmlMatOrd[nI]:_PMSQuantity:Text),X3Picture("NLI_PMSQTD"))),",",".")), NIL } )
		Endif

		// Quantidade do PG
		If 	XmlChildEx(aXmlMatOrd[nI],"_PGQUANTITY" ) != Nil .AND. ;
			!EMPTY( aXmlMatOrd[nI]:_PGQuantity:Text )
			aAdd( aLineNLI, { "NLI_PGQTD", val(replace(alltrim(transform(val(aXmlMatOrd[nI]:_PGQuantity:Text),X3Picture("NLI_PGQTD"))),",",".")), NIL } )
		Endif

		// Quantidade da População (plans/ha)
		If 	XmlChildEx(aXmlMatOrd[nI],"_POPULATIONQUANTITY" ) != Nil .AND. ;
			!EMPTY( aXmlMatOrd[nI]:_PopulationQuantity:Text )
			aAdd( aLineNLI, { "NLI_POPQTD", val(replace(alltrim(transform(val(aXmlMatOrd[nI]:_PopulationQuantity:Text),X3Picture("NLI_POPQTD"))),",",".")), NIL } )
		Endif

		// Numero da Peneira
		If 	XmlChildEx(aXmlMatOrd[nI],"_NUMBEROFSIEVE" ) != Nil .AND. ;
			!EMPTY( aXmlMatOrd[nI]:_NumberOfSieve:Text )
			aAdd( aLineNLI, { "NLI_NUMPEN", val(replace(alltrim(transform(val(aXmlMatOrd[nI]:_NumberOfSieve:Text),X3Picture("NLI_NUMPEN"))),",",".")), NIL } )
		Endif

		// Quantidade de Área Produtiva (há)
		If 	XmlChildEx(aXmlMatOrd[nI],"_QUANTITYPRODUCTIVEAREA" ) != Nil .AND. ;
			!EMPTY( aXmlMatOrd[nI]:_QuantityProductiveArea:Text )
			aAdd( aLineNLI, { "NLI_QTDPAR", val(replace(alltrim(transform(val(aXmlMatOrd[nI]:_QuantityProductiveArea:Text),X3Picture("NLI_QTDPAR"))),",","."))  , NIL } )
		Endif

		// Internal ID da chave completa da Cultura
		If XmlChildEx(aXmlMatOrd[nI],"_CULTUREINTERNALID" ) != Nil .AND. ;
			!EMPTY( aXmlMatOrd[nI]:_CultureInternalId:Text )
			cValExt := aXmlMatOrd[nI]:_CultureInternalId:Text
			cValInt := CFGA070Int(cMarca, 'NP3', 'NP3_CODIGO', AllTrim(cValExt))
			If Empty(cValInt)
				lRet := .F.
				cXmlRet := STR0034 //"Código da cultura não encontrado."
				Return .F.
			Else
				If '|' $ cValInt 
               aAux := Separa(cValInt,'|')
               cValInt := aAux[3]
            EndIf
				aAdd( aLineNLI, { "NLI_CULTRA", PadR(cValInt, TamSX3("NP3_CODIGO")[1]), NIL } )
			Endif
		Else
			// Código da Cultura
			If XmlChildEx(aXmlMatOrd[nI],"_CULTURECODE" ) != Nil .AND. ;
				!EMPTY( aXmlMatOrd[nI]:_CultureCode:Text )
				aAdd( aLineNLI, { "NLI_CULTRA", aXmlMatOrd[nI]:_CultureCode:Text , NIL } )
			Endif
		Endif

		// ID de Integração do Centro de Custo
		If XmlChildEx(aXmlMatOrd[nI],"_COSTCENTERINTERNALID" ) != Nil .AND. ;
			!EMPTY( aXmlMatOrd[nI]:_CostCenterInternalId:Text )
			cValExt := aXmlMatOrd[nI]:_CostCenterInternalId:Text
			aAux := IntCusInt(cValExt, cMarca)
		
			If !aAux[1]
				lRet := .F.
				cXmlRet := STR0035 //"Centro de custo não encontrado." 
				Return .F.
			EndIf
			aAdd( aLineNLI, { "NLI_CC", aAux[2][3] , NIL } )
		Else
			// ID de Integração do Centro de Custo
			If 	XmlChildEx(aXmlMatOrd[nI],"_COSTCENTERCODE" ) != Nil .AND. ;
				!EMPTY( aXmlMatOrd[nI]:_CostCenterCode:Text )
				aAdd( aLineNLI, { "NLI_CC", aXmlMatOrd[nI]:_CostCenterCode:Text , NIL } )
			EndIf
		Endif

		// Internal ID do Alvo
		If XmlChildEx(aXmlMatOrd[nI],"_PLANTHEALTHINTERNALID" ) != Nil .AND. ;
			!EMPTY( aXmlMatOrd[nI]:_PlantHealthInternalId:Text )
			cValExt := aXmlMatOrd[nI]:_PlantHealthInternalId:Text
			cValInt := CFGA070Int(cMarca, 'NCD', 'NCD_CODIGO', AllTrim(cValExt))
			If Empty(cValInt)
				lRet := .F.
				cXmlRet := STR0036 //"Código da fitossanidade não encontrado."
				Return .F.
			Else
				aAux := Separa(cValInt,'|')
				aAdd( aLineNLI, { "NLI_FITSSA", PadR(aAux[3], TamSX3("NCD_CODIGO")[1]), NIL } )
			Endif
		Else
			If 	XmlChildEx(aXmlMatOrd[nI],"_PLANTHEALTHCODE" ) != Nil .AND. ;
				!EMPTY( aXmlMatOrd[nI]:_PlantHealthCode:Text )
				aAdd( aLineNLI, { "NLI_FITSSA", aXmlMatOrd[nI]:_PlantHealthCode:Text , NIL } )
			EndIf
		EndIf
		
		//Código do Usuário Requisitante Proposta
		If 	XmlChildEx(aXmlMatOrd[nI],"_USERREQUESTERCODE" ) != Nil .AND. ;
			!EMPTY( aXmlMatOrd[nI]:_UserRequesterCode:Text )
			aAdd( aLineNLI, { "NLI_REQCOD", aXmlMatOrd[nI]:_UserRequesterCode:Text , NIL } )
		Endif

		//Nome do Usuário Requisitante
		If 	XmlChildEx(aXmlMatOrd[nI],"_USERREQUESTERNAME" ) != Nil .AND. ;
			!EMPTY( aXmlMatOrd[nI]:_UserRequesterName:Text )
			aAdd( aLineNLI, { "NLI_REQNOM", aXmlMatOrd[nI]:_UserRequesterName:Text, NIL } )
		Endif

		If len(aLineNLI) > 0
			aAdd(aLine,{"AUT_D4_AGR",aLineNLI,NIL})
		Endif 
		// Fim integração com o PIMS

		//endereços dos empenhos:
		//If XmlChildEx(aXmlMatOrd[nI],"_LISTOFALLOCATEDMATERIAL") != Nil .And. ;
		//	!Empty(aXmlMatOrd[nI]:_ListOfAllocatedMaterial)
		//	aXmlLocMat := aXmlMatOrd[nI]:_ListOfAllocatedMaterial:_AllocatedMaterial
		//else 
		//	aXmlLocMat := {}
		//EndIf

		//Endereço
		aEnder := {}
		For nI2 := 1 to len(aXmlLocMat)

			aLineEnder := {}
            cLocatCode := ""

			//Localização/Endereço / LocationCode
			If XmlChildEx(aXmlLocMat[nI2],"_LOCATIONCODE") != Nil .And. ;
				!Empty(aXmlLocMat[nI2]:_LocationCode:Text)
				cLocatCode := aXmlLocMat[nI2]:_LocationCode:Text

				aAdd(aLineEnder,{"DC_LOCALIZ"  ,Padr(cLocatCode,nTamLOCALI),Nil})
			EndIf

			//Quantidade alocada / AllocationQuantity
			If XmlChildEx(aXmlLocMat[nI2],"_ALLOCATIONQUANTITY") != Nil .And. ;
				!Empty(aXmlLocMat[nI2]:_AllocationQuantity:Text)
				
				cAllocQdt := Val(aXmlLocMat[nI2]:_AllocationQuantity:Text)

				aAdd(aLineEnder,{"DC_QUANT"  ,cAllocQdt,Nil})
			Else
				lRet := .F.
				cXmlRet := "AllocationQuantity " + STR0028 // é obrigatório."
				Return lRet
			EndIf

			//Número de Serie / NumberSeries
			If XmlChildEx(aXmlLocMat[nI2],"_NUMBERSERIES") != Nil .And. ;
				!Empty(aXmlLocMat[nI2]:_NumberSeries:Text)
				cSeries := aXmlLocMat[nI2]:_NumberSeries:Text

				aAdd(aLineEnder,{"DC_NUMSERI"  ,Padr(cSeries,nTamNUMSER),Nil})
			EndIf

			//Código SubLote/Série / _SubLoteCode (sublote)
			If XmlChildEx(aXmlLocMat[nI2],"_SUBLOTECODE") != Nil .And. ;
				!Empty(aXmlLocMat[nI2]:_SubLoteCode:Text)
				cSubLotCo2 := aXmlLocMat[nI2]:_SubLoteCode:Text
				
				If cSubLotCod != cSubLotCo2
					lRet := .F.
					cXmlRet := STR0037 //"Não é permitido informar sublotes diferentes para um mesmo material."
					Return lRet
				EndIf
			EndIf
			
			// Inclusão do endereço no array
			If !Empty(cLocatCode)
				aAdd(aEnder,aLineEnder)
			EndIf
		next nI2 //Endereço

		//Adiciona os endereços na linha do empenho
		if len(aEnder) > 0 
			aAdd(aLine,{"AUT_D4_END",aEnder,Nil})
		Endif
		
		//Adiciona a linha do empenho no array de itens.
		aAdd(aEmpenhos,aLine)
		
	Next nI //Empenho


	If nOpc == 3 //Inclusão
		//Se o array de empenhos estiver preenchido, o empenho será criado pelo mata381 e não pelo mata650
		//Porque foi enviado o ListOfMaterial
		if len(aEmpenhos) > 0 
			MSExecAuto({|x,y,z| mata381(x,y,z)},aCab,aEmpenhos,3)
			If lMsErroAuto
				//Retorna o erro que ocorreu.
				aErroAuto := GetAutoGRLog()
				lRet := .F.
				cXmlRet := ""
				For nI := 1 To Len(aErroAuto)
					cXmlRet += _noTags(aErroAuto[nI] + Chr(10))
				Next nI
				Return lRet
			EndIf
		EndIf
	ElseIf nOpc == 4 //Alteração
		
		//Se o array de empenhos estiver preenchido, o empenho será criado pelo mata381 e não pelo mata650
		//Porque foi enviado o ListOfMaterialOrder
		

		// Exclusão das Ordens de Produção que foram originadas pelo empenho de produtos intermediários
		aOrdemEx := {}
		aCabEx   := {}

		cAlias := GetNextAlias()

		cQuery := " SELECT SD4.D4_OPORIG "
		cQuery +=   " FROM " + RetSqlName("SD4") + " SD4 "
		cQuery +=  " WHERE SD4.D4_FILIAL = '" + xFilial("SD4") + "' "
		cQuery +=    " AND SD4.D4_OP     = '" + cOrdem + "' "
		cQuery +=    " AND SD4.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND SD4.D4_OPORIG <> ' ' "
		cQuery +=    " AND SD4.D4_OPORIG IN ( SELECT SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN+SC2.C2_ITEMGRD "
		cQuery +=                             " FROM " + RetSqlName("SC2") + " SC2 "
		cQuery +=                            " WHERE SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
		cQuery +=                              " AND (SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN+SC2.C2_ITEMGRD)  = SD4.D4_OPORIG "
		cQuery +=                              " AND SC2.D_E_L_E_T_ = ' ' ) "
		cQuery += " ORDER BY SD4.D4_OPORIG "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)        

		While (cAlias)->(!Eof())
			aOrdemEx := {}

			SC2->(dbSeek(xFilial("SC2")+(cAlias)->D4_OPORIG))

			aAdd(aOrdemEx, {"C2_FILIAL" , xFilial("SC2") , NIL})
			aAdd(aOrdemEx, {"C2_NUM"    , SC2->C2_NUM, Nil})
			aAdd(aOrdemEx, {"C2_ITEM"   , SC2->C2_ITEM , Nil})
			aAdd(aOrdemEx, {"C2_SEQUEN" , SC2->C2_SEQUEN , Nil})
			aAdd(aOrdemEx, {"C2_ITEMGRD", SC2->C2_ITEMGRD , Nil})
			//Parâmetro para excluir todas as ordens/Empenhos intermediários geradas a partir da OP intermediária
			aAdd(aOrdemEx, {"DELOPI", "S", Nil, Nil})
			aAdd(aOrdemEx, {"DELSC", "S", Nil, Nil})                   

			MsExecAuto({|x,y| MATA650(x,y)},aOrdemEx,5)
			If lMsErroAuto
				//Retorna o erro que ocorreu.
				aErroAuto := GetAutoGRLog()
				lRet := .F.
				cXmlRet := ""
				For nI := 1 To Len(aErroAuto)
					cXmlRet += _noTags(aErroAuto[nI] + Chr(10))
				Next nI
				Return lRet
			EndIf
			(cAlias)->(dbSkip())
		End
		(cAlias)->(dbCloseArea())


		//Se tiver a tag listOfMaterialOrders e não tiver a tag MaterialOrders, deve excluir os empenhos já existentes
		//Se não possuir a tag listOfMaterialOrders, significa que não haverá a alteração/exclusão dos empenhos.
		
		//Exclusão dos Empenhos já existentes para a ordem de produção principal
		aCabEx := {{"D4_OP",cOrdem,NIL},;
				{"INDEX",2,Nil}}
		SD4->(dbSetOrder(2))
		If SD4->(dbSeek(xFilial("SD4")+cOrdem))
			//Executa o MATA381 para exclusão dos empenhos que já existiam na OP principal.
			MSExecAuto({|x,y,z| mata381(x,y,z)},aCabEx,aItens,5)
			If lMsErroAuto
				//Retorna o erro que ocorreu.
				aErroAuto := GetAutoGRLog()
				lRet := .F.
				cXmlRet := ""
				For nI := 1 To Len(aErroAuto)
					cXmlRet += _noTags(aErroAuto[nI] + Chr(10))
				Next nI
				Return lRet
			EndIf
		EndIf
			
		//Inclusão dos Empenhos da ListOfMaterialOrder que foram enviados na alteração da OP
		If len(aEmpenhos) > 0 
			MSExecAuto({|x,y,z| mata381(x,y,z)},aCab,aEmpenhos,3)
			If lMsErroAuto
				//Retorna o erro que ocorreu.
				aErroAuto := GetAutoGRLog()
				lRet := .F.
				cXmlRet := ""
				For nI := 1 To Len(aErroAuto)
					cXmlRet += _noTags(aErroAuto[nI] + Chr(10))
				Next nI
				Return lRet
			EndIf
		EndIf
		
	EndIf

Return lRet

//-------------------------------------------------------------------------------------------------
/*{Protheus.doc} canUpdEmp
Verifica se a ordem de produção possui movimentação.

@param   cNumOp Ordem de produção 

@author  Michelle Ramos Henriques
@version P12
@since   29/10/2018

*/
//-------------------------------------------------------------------------------------------------

Static Function canUpdEmp(cNumOp)
    Local lRet      := .T.
    Local cQuery    := ""
    Local cAliasMov := "BUSCAMOV"

    cQuery := " SELECT 1 "
    cQuery +=   " FROM " + RetSqlname("SD3") + " SD3 "
    cQuery +=  " WHERE SD3.D3_FILIAL  = '" + xFilial("SD3") + "' "
    cQuery +=    " AND SD3.D_E_L_E_T_ = ' ' "
    cQuery +=    " AND SD3.D3_ESTORNO <> 'S' "
    cQuery +=    " AND SD3.D3_OP      = '" + cNumOp + "' "

    cQuery := ChangeQuery(cQuery)

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasMov,.T.,.T.)

    If (cAliasMov)->(!Eof())
        lRet := .F.
    EndIf
    (cAliasMov)->(dbCloseArea())
Return lRet

/*/{Protheus.doc} PCPConvDat

Copia do PCPConvDat.

Faz a conversão de uma data string, ou de string para data
considerando o formato utilizado em API ('AAAA-MM-DD')

@type  Function
@author mauricio.joao
@since 24/06/2022
@version P12
@param xData, Character/Date, Data em formato String ou Date
@return xData, Character/Date, Retorna a data no formato especificado
/*/
Static Function ConvDati650(xData)
	If !Empty(xData)
		xData := StrZero(Year(xData),4) + "-" + StrZero(Month(xData),2) + "-" + StrZero(Day(xData),2)
	Else
		xData := ""
	EndIf
	
Return xData
