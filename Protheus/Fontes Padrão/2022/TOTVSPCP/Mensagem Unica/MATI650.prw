#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "MATI650.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MATI650

Funcao de integracao com o adapter EAI para recebimento do  cadastro de
Ordem de produ��o (SC2) utilizando o conceito de mensagem unica.

@param   cXml          Vari�vel com conte�do XML para envio/recebimento.
@param   nTypeTrans    Tipo de transa��o. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)
@param   cVersao       Vers�o da mensagem recebida pelo EAI.

@author  Lucas Konrad Fran�a
@version P12
@since   02/09/2015
@return  aRet   - (array)   Cont�m o resultado da execu��o e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execu��o da fun��o
       aRet[2] - (caracter) Mensagem XML para envio
       aRet[3] - (caracter) Nome da mensagem

@obs    O m�todo ir� retornar um objeto do tipo TOTVSBusinessEvent caso
        o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
        TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
        O tipo da classe pode ser definido com a fun��o EAI_BUSINESS_REQUEST.
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

   //Verifica se est� sendo executado para realizar a integra��o com o PPI.
   //Se a vari�vel lRunPPI estiver definida, e for .T., assume que � para o PPI.
   //Vari�vel � criada no fonte mata650.prx, na fun��o MATA650PPI().
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
         
         //Verifica a vers�o da Mensagem.
         If Left(cVersao,1) == "2"
            Begin Transaction
                aRet := v2000(cXml, nTypeTrans, cTypeMessage, oXml)
                If aRet[1] == .F.
                    DisarmTransaction()
                Endif
            End Transaction
         Else
            Return {.F.,STR0003,"PRODUCTIONORDER"} //"A vers�o da mensagem n�o foi implementada."
         EndIf
      ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
         aRet := v2000(cXml, nTypeTrans, cTypeMessage, oXml)
      EndIf
   ElseIf nTypeTrans == TRANS_SEND
      If lIntegPPI
         //Envio para o Totvs MES. Sempre envia a V2000. N�o utiliza EAI.
         aRet := v2000(cXml, nTypeTrans, cTypeMessage, oXml)
      Else
         //Implementado apenas V2 da mensagem ProductionOrder.
         If Left(cVersao,1) == "2"
            aRet := v2000(cXml, nTypeTrans, cTypeMessage)
         Else
            lRet    := .F.
            Return {lRet, STR0003,"PRODUCTIONORDER"} //"A vers�o da mensagem informada n�o foi implementada!"
         EndIf
      EndIf
   EndIf

   lRet    := aRet[1]
   cXMLRet := aRet[2]
Return {lRet, cXmlRet,"PRODUCTIONORDER"}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} v2000

Funcao de integracao com o adapter EAI para recebimento do  cadastro de
Ordem de produ��o (SC2) utilizando o conceito de mensagem unica.

@param   cXml        Vari�vel com conte�do XML para envio/recebimento.
@param   nTypeTrans   Tipo de transa��o. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Lucas Konrad Fran�a
@version P12
@since   02/09/2015
@return  aRet  - (array)   Cont�m o resultado da execu��o e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execu��o da fun��o
       aRet[2] - (caracter) Mensagem XML para envio

@obs    O m�todo ir� retornar um objeto do tipo TOTVSBusinessEvent caso
       o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
       TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
       O tipo da classe pode ser definido com a fun��o EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------------------------------------
Static Function v2000(cXml, nTypeTrans, cTypeMessage, oXml)
   Local lRet       := .T.
   Local lEnvOper   := .T. //Vari�vel para controlar se envia as opera��es
   Local lEnvEmp    := .T. //Vari�vel para controlar se envia os empenhos (componentes)
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
         //Produto da integra��o
         If Type("oXml:_TotvsMessage:_MessageInformation:_Product:_name:Text") <> "U"
            cMarca :=  oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
            aAdd(aOrdem, {"C2_PROGRAM",cMarca, Nil})
         EndIf

         // Evento
         If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
            cEvent := Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
         Else
            lRet   := .F.
            cXmlRet := STR0008 //"O evento � obrigat�rio"
            Return {lRet, cXMLRet}
         EndIf

         // ProductionOrderUniqueID
         If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ProductionOrderUniqueID:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ProductionOrderUniqueID:Text)
            cValExt := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ProductionOrderUniqueID:Text
         Else
            lRet   := .F.
            cXmlRet := STR0009 //"O c�digo do ProductionOrderUniqueID � obrigat�rio."
            Return {lRet, cXMLRet}
         EndIf

        //Obt�m o InternalId
        aValInt := F650GetInt(cValExt, cMarca)

        // Se o evento � Upsert
        If cEvent == "UPSERT"
            //Verifica se o registro foi encontrado
            If !aValInt[1]
               nOpc := 3 //Op��o de inclus�o
               //N�mero da OP.
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Number:Text") != "U" .And. ;
                  !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Number:Text)
                  cOrdem  := PadR(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Number:Text, nTamNum+nTamItem+nTamSeq+nTamGrd)

                  //Se foi enviado numera��o de ordem, verifica se existe OP com esta numera��o.
                  SC2->(dbSetOrder(1))
                  If SC2->(dbSeek(xFilial("SC2")+cOrdem))
                     lRet    := .F.
                     cXmlRet := STR0011 + AllTrim(cOrdem) + STR0012 //"J� existe uma ordem de produ��o com a numera��o '" ### "'. Inclus�o n�o permitida."
                     Return {lRet,cXmlRet}
                  EndIf
                  
                  //Recupera cada campo da chave da SC2.
                  cNum    := SubStr(cOrdem,1,nTamNum)
                  cItem   := SubStr(cOrdem,nTamNum+1,nTamItem)
                  cSequen := SubStr(cOrdem,nTamNum+nTamItem+1,nTamSeq)
                  cItmGrd := SubStr(cOrdem,nTamNum+nTamItem+nTamSeq+1,nTamGrd)

                  //Verifica se a numera��o da OP preenche no m�nimo os campos C2_NUM, C2_ITEM e C2_SEQUEN.
                  If Empty(cNum) .Or. Empty(cItem) .Or. Empty(cSequen)
                     lRet := .F.
                     cXmlRet := STR0013 //"Numera��o da ordem de produ��o inv�lida."
                     Return {lRet,cXmlRet}
                  EndIf

                  // Armazena o n�mero da OP no array.
                  aAdd(aOrdem, {"C2_FILIAL" , xFilial("SC2")     , NIL})
                  aAdd(aOrdem, {"C2_NUM"    , cNum   , Nil})
                  aAdd(aOrdem, {"C2_ITEM"   , cItem  , Nil})
                  aAdd(aOrdem, {"C2_SEQUEN" , cSequen, Nil})
                  aAdd(aOrdem, {"C2_ITEMGRD", cItmGrd, Nil})
               Else
                  // Numera��o da OP ser� gerada conforme inicializador padr�o da SC2.
                  aAdd(aOrdem, {"C2_FILIAL" , xFilial("SC2")     , NIL})
               EndIf
            Else
               nOpc := 4 //Op��o de altera��o
               cFilOP := aValInt[2,2]
               cOrdem := aValInt[2,3]

               //Valida se a OP existe.
               SC2->(dbSetOrder(1))
               If !SC2->(dbSeek(cFilOP+cOrdem))
                  lRet    := .F.
                  cXmlRet := STR0014 + AllTrim(cFilOP+cOrdem) + STR0015 //"N�o foi encontrada ordem de produ��o com a numera��o '" ### "'. Altera��o n�o permitida."
                  Return {lRet,cXmlRet}
               EndIf

               cOrdem := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)

               // Armazena o n�mero da OP no array.
               aAdd(aOrdem, {"C2_FILIAL" , SC2->C2_FILIAL , NIL})
               aAdd(aOrdem, {"C2_NUM"    , SC2->C2_NUM    , Nil})
               aAdd(aOrdem, {"C2_ITEM"   , SC2->C2_ITEM   , Nil})
               aAdd(aOrdem, {"C2_SEQUEN" , SC2->C2_SEQUEN , Nil})
               aAdd(aOrdem, {"C2_ITEMGRD", SC2->C2_ITEMGRD, Nil})
               aAdd(aOrdem, {"C2_PRODUTO", SC2->C2_PRODUTO, Nil})

               cProduto := SC2->C2_PRODUTO
            EndIf

            //Busca o c�digo do produto.
            If nOpc == 3 //N�o permite alterar o produto da OP
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
                  //Se n�o existir o ItemInternalID, utiliza o ItemCode.
                  If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text") != "U" .And. ;
                     !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text)
                     cProduto := PadR(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text,Len(SC2->C2_PRODUTO))
                     aAdd(aOrdem, {"C2_PRODUTO",cProduto,Nil})
                  Else
                     lRet := .F.
                     cXmlRet := STR0016 //"O c�digo do produto � obrigat�rio."
                     Return {lRet,cXmlRet}
                  EndIf
               EndIf
            EndIf

            SB1->(dbSetOrder(1))
            If !SB1->(dbSeek(xFilial("SB1")+cProduto))
               lRet := .F.
               cXmlRet := STR0024 + AllTrim(cProduto) + STR0025 //"Produto '"####"' n�o cadastrado."
               Return {lRet, cXmlRet}
            EndIf

            //Quantidade da OP.
            If nOpc == 3 //N�o permite alterar a quantidade da OP.
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Quantity:Text") != "U" .And. ;
                  !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Quantity:Text)
                  aAdd(aOrdem,{"C2_QUANT",Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Quantity:Text),Nil})
               Else
                  lRet := .F.
                  cXmlRet := STR0017 //"Quantidade da ordem de produ��o � obrigat�rio."
                  Return {lRet,cXmlRet}
               EndIf
            EndIf

            //Previs�o inicio da OP
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_StartOrderDateTime:Text") != "U" .And. ;
               !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_StartOrderDateTime:Text)
               dData := StoD(getDate(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_StartOrderDateTime:Text))
               If Empty(dData)
                  lRet := .F.
                  cXmlRet := STR0018 //"Data de in�cio da Ordem de produ��o informada em formato incorreto. Utilize AAAA-MM-DD."
                  Return {lRet,cXmlRet}
               EndIf
               aAdd(aOrdem,{"C2_DATPRI",dData,Nil})
            Else
               //Se for MODIFICA��O, utiliza a mesma data que j� existe na SC2.
               If nOpc == 4
                  aAdd(aOrdem,{"C2_DATPRI",SC2->C2_DATPRI,Nil})
               Else
                  lRet := .F.
                  cXmlRet := STR0019 //"Data de in�cio da ordem de produ��o � obrigat�rio."
                  Return {lRet,cXmlRet}
               EndIf
            EndIf

            //Data de entrega da OP
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EndOrderDateTime:Text") != "U" .And. ;
               !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EndOrderDateTime:Text)
               dData := StoD(getDate(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EndOrderDateTime:Text))
               If Empty(dData)
                  lRet := .F.
                  cXmlRet := STR0020 //"Data de entrega da Ordem de produ��o informada em formato incorreto. Utilize AAAA-MM-DD."
                  Return {lRet,cXmlRet}
               EndIf
               aAdd(aOrdem,{"C2_DATPRF",dData,Nil})
            Else
               //Se for MODIFICA��O, utiliza a mesma data que j� existe na SC2.
               If nOpc == 4
                  aAdd(aOrdem,{"C2_DATPRF",SC2->C2_DATPRF,Nil})
               Else
                  lRet := .F.
                  cXmlRet := STR0021 //"Data de entrega da ordem de produ��o � obrigat�rio."
                  Return {lRet,cXmlRet}
               EndIf
            EndIf

            //Data de emiss�o da OP
            If nOpc == 3
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EmissionDate:Text") != "U" .And. ;
                  !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EmissionDate:Text)
                  dData := StoD(getDate(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EmissionDate:Text))
                  If Empty(dData)
                     lRet := .F.
                     cXmlRet := STR0026 //"Data de emiss�o da Ordem de produ��o informada em formato incorreto. Utilize AAAA-MM-DD."
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
            		cXmlRet := STR0032 //"Classe de valor n�o cadastrada. "
                    Return {lRet,cXmlRet}
            	EndIf
            Else
            	// Classe de Valor
            	If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ClassValueCode:Text") != "U" .And. ;
            	   !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ClassValueCode:Text)
            	    aAdd( aOrdem, {"C2_CLVL", PadR(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ClassValueCode:Text,TamSX3("C2_CLVL")[1]), Nil } )
            	Endif
            EndIf

            //Armaz�m da ordem (C2_LOCAL)
            If nOpc == 3 //N�o permite alterar o armaz�m da OP
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
            If nOpc == 3 //N�o permite alterar a unidade de medida da OP
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

            //Se for inclus�o, adiciona a revis�o atual.
            If nOpc == 3
               aAdd(aOrdem,{"C2_REVISAO", IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU ), Nil})
            EndIf

            aAdd(aOrdem,{"C2_TPOP"   , "F", Nil}) //Sempre cria ordens do tipo FIRME.

            
            //Verifica se h� lista de materiais no xml
            //O processamento ser� efetuado na fun��o GetEmpenho()
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfMaterialOrders") != "U" 

                If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfMaterialOrders:_MaterialOrder") == "A"
                    aXmlMatOrd := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfMaterialOrders:_MaterialOrder
                ElseIf Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfMaterialOrders:_MaterialOrder") == "O"
                    aXmlMatOrd := {oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfMaterialOrders:_MaterialOrder}
                Endif

                if nOpc == 3
					If len(aXmlMatOrd) >  0
						aAdd(aOrdem,{"AUTEXPLODE", "S", Nil}) //Se for inclus�o da OP e o xml possuir a lista de material, ser� obedecida a lista de material enviado e n�o a estrutura do produto da OP
						aAdd(aOrdem,{"GERAOPI", "N", Nil}) //Flag para explodir a estrutura e gerar empenhos e ordens intermedi�rias.
						aAdd(aOrdem,{"GERASC" , "N", Nil}) //Flag para explodir a estrutura e gerar empenhos e ordens intermedi�rias.
						aAdd(aOrdem,{"GERAEMP" , "N", Nil}) // N�o gera os empenhos.
					Else
						aAdd(aOrdem,{"AUTEXPLODE", "S", Nil}) //Se for inclus�o da OP e o xml n�o possuir a lista de material, ser� gerado os empenhos conforme a estrutura do produto da OP.
					EndIf
				EndIf
			Else
				if nOpc == 3
					aAdd(aOrdem,{"AUTEXPLODE", "S", Nil}) //Se for inclus�o da OP e o xml n�o possuir a lista de material, ser� gerado os empenhos conforme a estrutura do produto da OP.
				Endif
			EndIf
         ElseIf cEvent == "DELETE"
            If !aValInt[1]
               lRet := .F.
               cXmlRet := STR0010 //"N�o foi encontrada ordem de produ��o para efetuar a exclus�o."
               Return {lRet,cXmlRet}
            EndIf
            nOpc := 5 //Op��o de exclus�o
            cFilOP := aValInt[2,2]
            cOrdem := aValInt[2,3]
            SC2->(dbSetOrder(1))
            If !SC2->(dbSeek(cFilOP+cOrdem))
               lRet    := .F.
               cXmlRet := STR0014 + AllTrim(cFilOP+cOrdem) + STR0022 //"N�o foi encontrada ordem de produ��o com a numera��o '" ### "'. Exclus�o n�o permitida."
               Return {lRet,cXmlRet}
            EndIf

            // Armazena o n�mero da OP no array.
            aAdd(aOrdem, {"C2_FILIAL" , SC2->C2_FILIAL , NIL})
            aAdd(aOrdem, {"C2_NUM"    , SC2->C2_NUM    , Nil})
            aAdd(aOrdem, {"C2_ITEM"   , SC2->C2_ITEM   , Nil})
            aAdd(aOrdem, {"C2_SEQUEN" , SC2->C2_SEQUEN , Nil})
            aAdd(aOrdem, {"C2_ITEMGRD", SC2->C2_ITEMGRD, Nil})
         Else
            lRet    := .F.
            cXmlRet := STR0023 //"O evento informado � inv�lido. Utilize UPSERT ou DELETE."
            Return {lRet,cXmlRet}
         EndIf

         //Se for EXCLUS�O ou ALTERA��O guarda o valor interno.
         If nOpc == 5 .Or. nOpc == 4
            cValInt := IntOPExt(/*Empresa*/, /*Filial*/, SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD), /*Vers�o*/)[2]
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
                cValInt := IntOPExt(/*Empresa*/, /*Filial*/, SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD), /*Vers�o*/)[2]
                CFGA070Mnt(cMarca, "SC2", "C2_NUM", cValExt, cValInt, .F., 1)
            EndIf

            //Gera��o dos empenhos
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
               Se existir empenhos (ListOfMaterialOrders) ou opera��es (ListOfActivityOrders)
               fazer a leitura/carga dos dados aqui.
               Para empenhos, utilizar EXECAUTO do MATA381, sempre exclu�ndo o que j� existir cadastrado na SD4 e 
               assumindo somente o que vier no ListOfMaterialOrders. 
               Para opera��es, verificar se utiliza a SHY e gravar os dados na SHY. Se n�o estiver parametrizado
               para utilizar a SHY, desconsiderar as informa��es recebidas.
            */
        EndIf

      ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
         
      ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
         cXmlRet := '2.000|2.001|2.002|2.003|2.004|2.005|2.006'
      EndIf
   ElseIf nTypeTrans == TRANS_SEND
      // Verifica se � uma exclus�o
      If !Inclui .And. !Altera
         cEvent := 'delete'
      Else
         cEvent := 'upsert'
      EndIf
      
      //Se est� excluindo, ou se est� sendo executado por rotinas espec�ficas do Carga M�quina, n�o envia as opera��es e empenhos.
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
      cXMLRet +=       '<key name="InternalID">' + IntOPExt(/*Empresa*/, /*Filial*/, &(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)'), /*Vers�o*/)[2] + '</key>'
      cXMLRet +=    '</Identification>'
      cXMLRet += '</BusinessEvent>'
      cXMLRet += '<BusinessContent>'
      cXmlRet +=    '<Number>' + AllTrim(&(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)')) + '</Number>' //N�mero Ordem Produ��o
      cXmlRet +=    '<Origin />' //Identifica��o da origem da mensagem (ex:APS, Ch�o de F�brica). Este campo foi necess�rio pois existe mais de um m�dulo do Datasul que envia Ordem de Produ��o
      cXmlRet +=    '<ProductionOrderUniqueID>'+IntOPExt(/*Empresa*/, /*Filial*/, &(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)'), /*Vers�o*/)[2]+'</ProductionOrderUniqueID>'
      cXmlRet +=    '<FatherNumber />' //N�mero Ordem Produ��o Pai
      cXmlRet +=    '<FatherProductionOrderUniqueID />' //Identifica��o Ordem Produ��o Pai
      cXmlRet +=    '<ItemCode>'+ AllTrim(&(cPont+'->C2_PRODUTO'))+'</ItemCode>' //C�digo Item
      cXmlRet +=    '<ListOfItemGrids />' //Grades, n�o utilizado no Protheus
      cXmlRet +=    '<ItemDescription>'+_NoTags(AllTrim(SB1->B1_DESC))+'</ItemDescription>'
      cXmlRet +=    '<Type>1</Type>' //Todas as ordens do Protheus s�o Internas.
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
      cXmlRet +=    '<MinimumQuantity />' //Quantidade M�nima
      cXmlRet +=    '<MaximumQuantity />' //Quantidade M�xima
      cXmlRet +=    '<ReportQuantity>'+ cValToChar(&(cPont+'->C2_QUJE')) +'</ReportQuantity>' //Quantidade Reportada
      cXmlRet +=    '<ApprovedQuantity />' //Quantidade Aprovada
      cXmlRet +=    '<ReworkQuantity />' //Quantidade Retrabalhada
      cXmlRet +=    '<ScrapQuantity />' //Quantidade Refugada
      cXmlRet +=    '<AuxiliarItemCode />' //C�digo Item Auxiliar
      cXmlRet +=    '<IsStatusOrder />' //Reporte Fecha Ordem Produ��o
      cXmlRet +=    '<UnitOfMeasureCode>'+ AllTrim(&(cPont+'->C2_UM')) +'</UnitOfMeasureCode>' //Unidade Medida
      cXmlRet +=    '<RequestOrderCode>'+ AllTrim(&(cPont+'->C2_PEDIDO')) +'</RequestOrderCode>' //C�digo Pedido Ordem Produ��o
      cXmlRet +=    '<StatusType />' //Estado
      cXmlRet +=    '<StatusOrderType>'+getStatusT()+'</StatusOrderType>' //Estado Ordem
      cXmlRet +=    '<ProductionLineCode />' //C�digo Linha Produ��o
      cXmlRet +=    '<ProductionLineDescription />' //Descri��o Linha Produ��o
      cXmlRet +=    '<PlannerUser />' //Planejador
      cXmlRet +=    '<ReferenceCode />' //C�digo Refer�ncia (Caracter�stica do Item)
      cXmlRet +=    '<ReportOrderType>2</ReportOrderType>' //Reporta Produ��o
      cXmlRet +=    '<AllocationType />' //Tipo de Aloca��o
      cXmlRet +=    '<SiteCode />' //C�digo Estabelecimento
      cXmlRet +=    '<WarehouseCode>'+ AllTrim(&(cPont+'->C2_LOCAL')) +'</WarehouseCode>' //C�digo Dep�sito
      cXmlRet +=    '<EndOrderCPDate />'//Data Fim Ordem Produ��o CP
      cXmlRet +=    '<StartOrderCPDate />'//Data In�cio Ordem Produ��o CP
      cXmlRet +=    '<ReleaseOrderDate />' //Data Libera��o Ordem Produ��o
      cXmlRet +=    '<TimeReleaseQuantity />' //Segs Libera��o OP
      cXmlRet +=    '<StartOrderDateTime>'+getDateTime(&(cPont+'->C2_DATPRI'),"00:00:00")+'</StartOrderDateTime>' //Data/Hora In�cio Ordem Produ��o
      cXmlRet +=    '<StartOrderQuantity />' //Segs In�cio Ordem Produ��o
      cXmlRet +=    '<EndOrderDateTime>'+getDateTime(&(cPont+'->C2_DATPRF'),"00:00:00")+'</EndOrderDateTime>' //Data/Hora Fim Ordem Produ��o
      cXmlRet +=    '<EndOrderQuantity />' //Segs Fim Ordem Produ��o
      cXmlRet +=    '<StartEarlierDateTime />' //Data/Hora In�cio Mais Cedo
      cXmlRet +=    '<EndLaterDateTime />' //Data/Hora Fim Mais Tarde
      cXmlRet +=    '<AbbreviationProviderName>'+ AllTrim(_NoTags(getClient(&(cPont+'->C2_PEDIDO')))) +'</AbbreviationProviderName>' //Nome Cliente
      cXmlRet +=    '<CustomerGroupCode />' //C�digo Grupo Cliente
      cXmlRet +=    '<CustomerRequestCode />' //C�digo Pedido Cliente
      cXmlRet +=    '<LastPertNumber />' //�ltima Sequ�ncia
      cXmlRet +=    '<PertRequestNumber />' //Sequ�ncia Pedido
      If lAddLote
         cLotCode := ExecBlock('MTI650LOTE',.F.,.F.,cPont+"->")
         If ValType(cLotCode) == "C"
            cXmlRet += '<LotCode>'+ AllTrim(_NoTags(cLotCode)) +'</LotCode>' //Lote/S�rie
         Else
            cXmlRet += '<LotCode />' //Lote/S�rie
         EndIf
      Else
         cXmlRet +=    '<LotCode />' //Lote/S�rie
      EndIf
      cXmlRet +=    '<MaterialListCode />' //C�digo Lista Componentes
      cXmlRet +=    '<ScriptCode>'+ AllTrim(&(cPont+'->C2_ROTEIRO')) +'</ScriptCode>' //C�digo Roteiro
      cXmlRet +=    '<MaterialCalculationType />' //C�lculo Custo Material
      cXmlRet +=    '<LaborType />' //Reporta M�o de Obra
      cXmlRet +=    '<LaborCostType />' //Custeio Proporcional M�o de Obra
      cXmlRet +=    '<MaterialCostType />' //Custeio Proporcional Material
      cXmlRet +=    '<OverheadCostType />' //Custeio Proporcional GGF
      cXmlRet +=    '<LaborCalculationType />' //C�lculo Custo M�o de Obra
      cXmlRet +=    '<OverheadCalculationType />' //C�lculo Custo Gastos Gerais de Fabrica��o
      cXmlRet +=    '<OverheadType />' //Reporta Gastos Gerais de Fabrica��o
      cXmlRet +=    '<ScrapItemCode />' //C�digo Item Refugo
      cXmlRet +=    '<ScrapItemValue />' //Rela��o Refugo/Item
      cXmlRet +=    '<BusinessUnitCode />' //C�digo Unidade Neg�cio
      cXmlRet +=    '<StockGroupCode />' //C�digo Grupo Estoque
      cXmlRet +=    '<StockGroupDescription />' //Descri��o Grupo Estoque
      cXmlRet +=    '<FamilyCode />' //C�digo Fam�lia
      cXmlRet +=    '<FamilyDescription />' //Descri��o Fam�lia
      cXmlRet +=    '<NetWeight />' //Peso L�quido
      cXmlRet +=    '<GrossWeight />' //Peso Bruto
      cXmlRet +=    '<DeliveryNumber />' //N�mero Entrega
      cXmlRet +=    '<Priority />' //Prioridade
      
      //################
      //INICIO OPERACOES
      //################
      cXmlRet +=    '<ListOfActivityOrders>' // Opera��es

      //Busca as Opera��es da ordem.
      //Procura primeiro na SH8. Se n�o encontrar, busca as opera��es da SHY. Caso n�o encontre, busca na SG2.
      aOper := {}
      If lEnvOper
         //Somente envia opera��es nas a��es de inclus�o e altera��o.
         
         cAliasOper := GetNextAlias()
         cFiltroG2 := ""
         dbSelectArea("SOE")
         SOE->(dbSetOrder(1))
         If SOE->(dbSeek(xFilial("SOE")+"SC2"))
            //Se est� parametrizado para considerar o filtro das opera��es nas ordens, busca o filtro da tabela SG2
            //para filtrar as tabelas SH8, SHY e SG2.
            If AllTrim(SOE->OE_VAR2) == "1"
               SOE->(dbSeek(xFilial("SOE")+"SG2"))
               cFiltroG2 := StrTran(SOE->OE_FILTRO,'"',"'")
            EndIf
         EndIf
         
         //Busca as opera��es na SH8. Se n�o encontrar, busca na SHY. Se n�o encontrar, busca na SG2.
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
               aAdd(aOper,{SH8->(H8_OPER),;             //C�digo da opera��o
                           SH8->(H8_CTRAB),;              //C�digo do centro de trabalho
                           A680Tempo(SH8->(H8_DTINI), SH8->(H8_HRINI), SH8->(H8_DTFIM), SH8->(H8_HRFIM)),; //Tempo maquina
                           ConvTime(SH8->(H8_SETUP),,,"C"),; //Tempo Setup/Prepara��o
                           SH8->(H8_ROTEIRO),;            //C�digo do roteiro
                           "MOD"+&(cPont+'->C2_CC'),;     //C�digo M�o de Obra Direta
                           SH8->(H8_RECURSO),;            //C�digo da m�quina
                           getDateTime(Iif(Empty(SH8->(H8_DTINI)),&(cPont+'->C2_DATPRI'),SH8->(H8_DTINI)) , SH8->(H8_HRINI)),; //Data/Hora In�cio Programa��o
                           getDateTime(Iif(Empty(SH8->(H8_DTFIM)),&(cPont+'->C2_DATPRF'),SH8->(H8_DTFIM)) , SH8->(H8_HRFIM)),; //Data/Hora Fim Programa��o 
                           SH8->(Recno()),; //InternalID
                           cDenOperac,; //Descri��o da operacao
                           nLotePad,;   //Lote padr�o
                           nTemPad,;    //Tempo padr�o
                           SH8->(H8_QUANT),; //Quantidade da opera��o
                           &(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)'),; //Num. OP.
                           &(cPont+'->C2_PRODUTO'),; //C�digo do Produto
                           SB1->(B1_DESC),;  //Descri��o do produto
                           &(cPont+'->C2_UM'),; //Unidade de medida da OP
                           SH8->H8_DESDOBR,; //Desdobramento da opera��o
                           nMaoObra,;
                           cPont+"->" }) //Ponteiro usado para acessar as informa��es da SC2. Deve ser sempre o ultimo par�metro.
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
                  aAdd(aOper,{SHY->(HY_OPERAC),;             //C�digo da opera��o
                              SHY->(HY_CTRAB),;              //C�digo do centro de trabalho
                              SHY->(HY_TEMPOM),; //Tempo maquina
                              SHY->(HY_TEMPOS),; //Tempo Setup/Prepara��o
                              SHY->(HY_ROTEIRO),;            //C�digo do roteiro
                              "MOD"+&(cPont+'->C2_CC'),;     //C�digo M�o de Obra Direta
                              SHY->(HY_RECURSO),;            //C�digo da m�quina
                              getDateTime(Iif(Empty(SHY->(HY_DATAINI)),&(cPont+'->C2_DATPRI'),SHY->(HY_DATAINI)) , Iif(Empty(SHY->HY_HORAINI),"00:00:00",SHY->HY_HORAINI)),; //Data/Hora In�cio Programa��o
                              getDateTime(Iif(Empty(SHY->(HY_DATAFIM)),&(cPont+'->C2_DATPRF'),SHY->(HY_DATAFIM)) , Iif(Empty(SHY->HY_HORAFIM),"00:00:00",SHY->HY_HORAFIM)),; //Data/Hora Fim Programa��o
                              SHY->(Recno()),;  //InternalID
                              cDenOperac,;      //Descri��o da operacao
                              nLotePad,;        //Lote padr�o
                              nTemPad,;         //Tempo padr�o
                              SHY->(HY_QUANT),; //Quantidade da opera��o
                              &(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)'),; //Num. OP.
                              &(cPont+'->C2_PRODUTO'),; //C�digo do Produto
                              SB1->(B1_DESC),;  //Descri��o do produto
                              &(cPont+'->C2_UM'),; //Unidade de medida da OP
                              "000",; // Desdobramento da opera��o
                              SHY->HY_MAOOBRA,;
                              cPont+"->" }) //Ponteiro usado para acessar as informa��es da SC2. Deve ser sempre o ultimo par�metro.
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
                  
                  aAdd(aOper,{SG2->(G2_OPERAC),;                   //C�digo da opera��o
                              SG2->(G2_CTRAB),;                    //C�digo do centro de trabalho
                              getTimeG2(&(cPont+'->C2_QUANT')),; //Tempo maquina
                              A690HoraCt(SG2->(G2_SETUP)),;        //Tempo Setup/Prepara��o
                              SG2->(G2_CODIGO),;                   //C�digo do roteiro
                              "MOD"+AllTrim(&(cPont+'->C2_CC')),;  //C�digo M�o de Obra Direta
                              SG2->(G2_RECURSO),;                  //C�digo da m�quina
                              getDateTime(&(cPont+'->C2_DATPRI'), "00:00:00"),; //Data/Hora In�cio Programa��o
                              getDateTime(&(cPont+'->C2_DATPRF'), "00:00:00"),; //Data/Hora Fim Programa��o
                              SG2->(Recno()),;        //InternalID
                              SG2->(G2_DESCRI),;      //Descri��o da operacao
                              SG2->(G2_LOTEPAD),;     //Lote padr�o
                              SG2->(G2_TEMPAD),;      //Tempo padr�o
                              &(cPont+'->C2_QUANT'),; //Quantidade da opera��o
                              &(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)'),; //Num. OP.
                              &(cPont+'->C2_PRODUTO'),; //C�digo do Produto
                              SB1->(B1_DESC),;  //Descri��o do produto
                              &(cPont+'->C2_UM'),; //Unidade de medida da OP
                              "000",; // Desdobramento da opera��o
                              SG2->G2_MAOOBRA,;
                              cPont+"->" }) //Ponteiro usado para acessar as informa��es da SC2. Deve ser sempre o ultimo par�metro.
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

         //Le o array com as opera��es, e adiciona na mensagem
         For nI := 1 To Len(aOper)
            //P.E. para alterar o c�digo do recurso e a descri��o da opera��o.
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
            cXmlRet +=          '<ProductionOrderNumber>'+ AllTrim(aOper[nI,CODOP]) +'</ProductionOrderNumber>' //N�mero Ordem Produ��o
            cXmlRet +=          '<ActivityID>'+ cValToChar(aOper[nI,INTERNALID]) +'</ActivityID>' //ID Opera��o
            cXmlRet +=          '<ActivityCode>'+ AllTrim(aOper[nI,COD_OPER]) +'</ActivityCode>' //C�digo Opera��o
            cXmlRet +=          '<ActivityDescription>'+ AllTrim(_NoTags(aOper[nI,DESCOPER])) +'</ActivityDescription>' //Descri��o Opera��o
            cXmlRet +=          '<Split>'+ AllTrim(aOper[nI,DESDOBR]) +'</Split>'
            cXmlRet +=          '<ItemCode>'+ AllTrim(aOper[nI,CODPROD]) +'</ItemCode>' //C�digo Item
            cXmlRet +=          '<ItemDescription>'+ _NoTags(AllTrim(aOper[nI,DESCPROD])) +'</ItemDescription>' //Descri��o Item
            cXmlRet +=          '<ListOfItemGrids />' //Grades, n�o utilizado no Protheus
            cXmlRet +=          '<ActivityType>'+Iif(lIntegPPI,"1","")+'</ActivityType>' //Tipo Opera��o ###QUANDO INTEGRA��O COM PCFACTORY, ENVIAR SEMPRE 1
            cXmlRet +=          '<WorkCenterCode>'+ AllTrim(aOper[nI,COD_CT]) +'</WorkCenterCode>' //C�digo Centro Trabalho
            cXmlRet +=          '<WorkCenterDescription>'+ AllTrim(_NoTags(getCTrab(aOper[nI,COD_CT]))) +'</WorkCenterDescription>' //Descri��o Centro Trabalho
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
               cXmlRet +=       '<TimeMachine>'+ cValToChar(nTimeMac) +'</TimeMachine>' //Tempo M�quina
            Else
               cXmlRet +=       '<TimeMachine>'+ cValToChar(aOper[nI,TIME_MAQ]) +'</TimeMachine>' //Tempo M�quina
            EndIf
            cXmlRet +=          '<TimeSetup>'+ cValToChar(aOper[nI,TIME_SETUP]) +'</TimeSetup>' //Tempo Prepara��o
            cXmlRet +=          '<ScriptCode>'+ AllTrim(aOper[nI,COD_ROTEIR]) +'</ScriptCode>' //C�digo Roteiro
            cXmlRet +=          '<EndLaterDateTime />' //Data/Hora Fim Mais Tarde
            cXmlRet +=          '<ResourceQuantity>'+ cValToChar(aOper[nI,MAOOBRA]) + '</ResourceQuantity>' //Quantidade Recurso
            cXmlRet +=          '<PercentageOverlapValue />' //% Overlap
            cXmlRet +=          '<PercentageScrapValue />' //% Refugo
            cXmlRet +=          '<PercentageValue />' //Propor��o
            cXmlRet +=          '<LaborCode>'+ AllTrim(aOper[nI,COD_MOD]) +'</LaborCode>' //C�digo M�o de Obra Direta
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
            cXmlRet +=          '<AlternativeActivityCode />' //Codigo Opera��o Alternativa
            cXmlRet +=          '<UnitActivityCode>'+ AllTrim(aOper[nI,CODUMOP]) +'</UnitActivityCode>' //C�digo Unidade Opera��o
            cXmlRet +=          '<ReworkQuantity />' //Quantidade Retrabalhada
            cXmlRet +=          '<ScrapItemCode />' //C�digo Item Refugo
            cXmlRet +=          '<ScrapItemValue />' //Rela��o Refugo/Item
            cXmlRet +=          '<TimePostprocessing />' //Tempo P�s Processo
            cXmlRet +=          '<UsedCapacity />' //Capacidade Utilizada
            cXmlRet +=          '<LoadQuantity />' //Carga Batelada
            cXmlRet +=          '<StatusType />' //Estado
            cXmlRet +=          '<StartRealDateTime />' //Data/Hora In�cio Real
            cXmlRet +=          '<EndRealDateTime />' //Data/Hora Fim Real
            cXmlRet +=          '<StartEarlierDateTime />' //Data/Hora In�cio Mais Cedo
            cXmlRet +=          '<OrderReferenceNumber />' //N�mero Ordem Refer�ncia
            cXmlRet +=          '<IsActivityStart />' //Primeira Opera��o
            cXmlRet +=          '<IsActivityEnd>'+Iif(nI==Len(aOper), "true", "false")+'</IsActivityEnd>' //�ltima Opera��o
            cXmlRet +=          '<ApprovedQuantity />' //Quantidade Aprovada
            cXmlRet +=          '<ScrapQuantity />' //Quantidade Refugada
            cXmlRet +=          '<ReportQuantity />' //Quantidade Reportada
            cXmlRet +=          '<IsLastReport />' //Reporte Fecha Opera��o
            cXmlRet +=          '<MaterialItemValue />' //Rela��o Item Operac/Item
            cXmlRet +=          '<TreatmentTimeType />' //Tipo Tratamento Tempo
            cXmlRet +=          '<StandardLotQuantity />' //Lote Padr�o
            cXmlRet +=          '<MultipleLotQuantity />' //Lote M�ltiplo
            cXmlRet +=          '<MinimumLotQuantity />' //Lote M�nimo
            cXmlRet +=          '<MachineCode>'+ AllTrim(aOper[nI,COD_MAQ]) +'</MachineCode>' //C�digo M�quina
            cXmlRet +=          '<StartPlanDateTime>'+ AllTrim(aOper[nI,DT_INI_PRG]) +'</StartPlanDateTime>' //Data/Hora In�cio Programa��o
            cXmlRet +=          '<EndPlanDateTime>'+ AllTrim(aOper[nI,DT_FIM_PRG]) +'</EndPlanDateTime>' //Data/Hora Fim Programa��o
            cXmlRet +=          '<IsSignificantTime />' //Tempo Significativo
            cXmlRet +=          '<ActivityControlCode />' //C�digo Ponto Controle
            cXmlRet +=          '<ActivityItemValue />' //Rela��o Opera��o/Item
            cXmlRet +=          '<TimeMOD>0</TimeMOD>' // Tempo de m�o de obra
            cXmlRet +=          '<TimeIndMES>3</TimeIndMES>' // Tratativa de tempo 1 = Tempo M�quina; 2 = Tempo m�o-de-obra; 3 = Escolha pelo MES
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
               cXmlRet +=       '<SecondUnitActivityCode>'+ AllTrim(cUM2) +'</SecondUnitActivityCode>' //Segunda Unidade Opera��o
            Else
               cXmlRet +=       '<SecondUnitActivityCode />' //Segunda Unidade Opera��o
            EndIf
            If lActFator
               aParam := {}
               aAdd(aParam,aOper[nI,CODOP])
               aAdd(aParam,aOper[nI,CODPROD])
               aAdd(aParam,aOper[nI,COD_ROTEIR])
               aAdd(aParam,aOper[nI,COD_OPER])
               nFator := ExecBlock('MTI650FCOP',.F.,.F.,aParam)
               If ValType(nFator) == "N"
                  cXmlRet +=       '<SecondUnitActivityFactor>'+ cValToChar(nFator) +'</SecondUnitActivityFactor>' //Fator de convers�o para segunda unidade de medida da opera��o
               Else
                  cXmlRet +=       '<SecondUnitActivityFactor />' //Fator de convers�o para segunda unidade de medida da opera��o
               EndIf
            Else
               cXmlRet +=       '<SecondUnitActivityFactor />' //Fator de convers�o para segunda unidade de medida da opera��o
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
         
         //Se existirem empenhos no array aEmpenhos, n�o faz as buscas na SD4.
         //Este array � alimentado nos programas MATA381 (Empenho m�ltiplo) 
         //e MATA380 (Empenho simples).
         //Estrutura do array: aEmpenhos[1] - Sequ�ncia da estrutura
         //                    aEmpenhos[2] - C�digo do empenho
         //                    aEmpenhos[3] - Local de estoque
         //                    aEmpenhos[4] - Quantidade
         //                    aEmpenhos[5] - RECNO
         //                    aEmpenhos[6] - Data do empenho
         //                    aEmpenhos[7] - Roteiro de opera��es
         //                    aEmpenhos[8] - C�digo da opera��o
         //                    aEmpenhos[9] - N�mero do lote
         //                    aEmpenhos[10] - N�mero do Sub-Lote
         //                    aEmpenhos[11] - Data de validade do lote
         
         If Type("aEmpenhos") == "A"
            aEmpen := aClone(aEmpenhos)
         Else
            cAliasSD4 := GetNextAlias()
            //Somente envia os componentes se for opera��o de inclus�o ou altera��o.

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
                            (cAliasSD4)->(D4_COD)  ,; //C�digo do empenho
                            (cAliasSD4)->(D4_LOCAL),; //Local de estoque
                            (cAliasSD4)->(D4_QUANT),; //Quantidade
                            (cAliasSD4)->(RECSD4)  ,; //Recno
                            (cAliasSD4)->(D4_DATA)  ; //Data empenho
                            })

               
               cRoteiro  := (cAliasSD4)->(D4_ROTEIRO)
               cOperacao := (cAliasSD4)->(D4_OPERAC)  
               
               //Se opera��o em branco, mandar a �ltima opera��o
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
               
               // Se n�o existe D4_ROTEIRO, verificar SGF
               // Se n�o achar rela��o na SGF, enviar �ltima opera��o do roteiro 
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
               aAdd(aEmpen[Len(aEmpen)],cRoteiro) //C�digo Roteiro
               aAdd(aEmpen[Len(aEmpen)],cOperacao) //C�digo Opera��o
                
               aAdd(aEmpen[Len(aEmpen)],(cAliasSD4)->(D4_LOTECTL)) //C�digo do Lote
               aAdd(aEmpen[Len(aEmpen)],(cAliasSD4)->(D4_NUMLOTE)) //C�digo do Sub-Lote
               aAdd(aEmpen[Len(aEmpen)],ConvDati650(STOD((cAliasSD4)->(D4_DTVALID)))) //Validade
               
               (cAliasSD4)->(dbSkip())
            End
            (cAliasSD4)->(dbCloseArea())
         EndIf
         SB1->(dbSetOrder(1))
         SDC->(dbSetOrder(2))
         For nI := 1 To Len(aEmpen)

            //PE MTI650FILC - Filtrar Componentes para n�o compor a lista de materiais
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
               cXmlRet +=          '<ProductionOrderNumber>'+ AllTrim(&(cPont+'->(C2_NUM+C2_ITEM+C2_SEQUEN)')) +'</ProductionOrderNumber>' //N�mero Ordem Produ��o
               cXmlRet +=          '<MaterialID>'+ cValToChar(aEmpen[nI,D4RECNO]) +'</MaterialID>' //ID Reserva
               cXmlRet +=          '<MaterialCode>'+ AllTrim(aEmpen[nI,D4COD]) +'</MaterialCode>' //C�digo Item Reserva
               cXmlRet +=          '<MaterialDescription>'+ cDescProd+'</MaterialDescription>' //Descri��o Item
               cXmlRet +=          '<ListOfMaterialGrids />' //Grades, n�o utilizado no Protheus
               cXmlRet +=          '<FatherItemCode />' //C�digo Item Pai
               cXmlRet +=          '<FatherItemDescription />' //Descri��o Item Pai
               cXmlRet +=          '<ListOfFatherGrids />' //Grades, n�o utilizado no Protheus
               cXmlRet +=          '<ReferenceCode />' //C�digo Refer�ncia
               cXmlRet +=          '<OrderReferenceNumber />' //N�mero Ordem Refer�ncia
               cXmlRet +=          '<ScriptCode>'+ AllTrim(aEmpen[nI,D4ROTEIRO]) +'</ScriptCode>' //C�digo Roteiro
               cXmlRet +=          '<ActivityID />' //ID Opera��o
               cXmlRet +=          '<ActivityCode>'+ AllTrim(aEmpen[nI,D4OPERAC]) +'</ActivityCode>' //C�digo Opera��o
               cXmlRet +=          '<LocationCode />' //C�digo Localiza��o
               cXmlRet +=          '<WarehouseCode>'+ AllTrim(aEmpen[nI,D4LOCAL]) +'</WarehouseCode>' //C�digo Dep�sito
               cXmlRet +=          '<LotCode>'+ AllTrim(aEmpen[nI,D4LOTECTL]) +'</LotCode>' //C�digo Lote/S�rie
               cXmlRet +=          '<StatusType />' //Estado
               cXmlRet +=          '<UnitOfMeasureCode />' //Unidade Medida
               cXmlRet +=          '<MaterialListCode />' //C�digo Lista Componentes
               cXmlRet +=          '<MaterialDate>'+ AllTrim(aEmpen[nI,D4DATA]) +'</MaterialDate>' //Data Reserva
               cXmlRet +=          '<MaterialQuantity>'+ cValToChar(aEmpen[nI,D4QUANT]) +'</MaterialQuantity>' //Quantidade Reserva
               cXmlRet +=          '<PertMaterialNumber>'+ AllTrim(aEmpen[nI,D4TRT]) +'</PertMaterialNumber>' //Sequ�ncia Reserva
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
            
      //Splits da ordem de produ��o
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
      //��������������������������������������������������������������Ŀ
     //� Ponto de Entrada para incluir tags especificas               �
     //����������������������������������������������������������������
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
Monta o InternalID da Ordem de produ��o de acordo com o c�digo passado
no par�metro.

@param   cEmpresa   C�digo da empresa (Default cEmpAnt)
@param   cFil       C�digo da Filial (Default cFilAnt)
@param   cNumOp     C�digo da ordem de produ��o (C2_NUM+C2_ITEM+C2_SEQ)
@param   cVersao    Vers�o da mensagem �nica (Default 2.000)

@author  Lucas Konrad Fran�a
@version P12
@since   02/09/2015
@return  aResult Array contendo no primeiro par�metro uma vari�vel
         l�gica indicando se o registro foi encontrado.
         No segundo par�metro uma vari�vel string com o InternalID
         montado.

@sample  IntOPExt(,,'01') ir� retornar {.T.,'01|01|01'}
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
      aAdd(aResult, STR0005 + Chr(10) + STR0006) // "Vers�o da ordem de produ��o n�o suportada." "As vers�es suportadas s�o: 2.000"
   EndIf   
Return aResult

// --------------------------------------------------------------------------------------
/*/{Protheus.doc} getStatusT
Retorna o StatusType da OP

@author  Lucas Konrad Fran�a
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
      cStatus := "1" //Prevista/N�o Iniciada
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
         cStatus := "1" //Em aberto/N�o iniciada
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
Monta o InternalID da Ordem de produ��o de acordo com o c�digo passado
no par�metro.

@param   cPedido   C�digo do pedido da Ordem de produ��o

@author  Lucas Konrad Fran�a
@version P12
@since   03/09/2015
@return  cNome - Nome do cliente (A1_NOME)

@sample  getClient('123456') ir� retornar 'TOTVS'
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
Busca a descri��o do Centro de trabalho

@param   cCTrab c�digo do centro de trabalho

@author  Lucas Konrad Fran�a
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
Calcula o tempo de m�quina utilizando a SG2.

@param   nQuantOP - Quantidade da ordem de produ��o

@author  Lucas Konrad Fran�a
@version P12
@since   04/09/2015
@return  nTemp - Tempo de m�quina calculado
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

@author  Lucas Konrad Fran�a
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
Adiciona o cabe�alho da mensagem quando utilizado integra��o com o PPI.

@param   cXML  - XML gerado pelo adapter. Par�metro recebido por refer�ncia.

@author  Lucas Konrad Fran�a
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

@param   dDate  - Data que ser� transformada para String
@param   cHora  - Hora

@author  Lucas Konrad Fran�a
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

Retorna somente a data de uma vari�vel datetime

@param dDateTime - Vari�vel DateTime

@return dDate - Retorna a data.

@author  Lucas Konrad Fran�a
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

@author  Lucas Konrad Fran�a
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

@author  Lucas Konrad Fran�a
@version P12
@since   01/10/2018

@return  aRetorno Array contendo no primeiro par�metro uma vari�vel
l�gica indicando se o registro foi encontrado no de/para.
No segundo par�metro uma vari�vel array com a empresa,
filial e a numera��o da OP.
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
      //Ajusta o tamanho da numera��o da OP.
      nTamNum  := TamSX3("C2_NUM")[1]
      nTamItem := TamSX3("C2_ITEM")[1]
      nTamSeq  := TamSX3("C2_SEQUEN")[1]
      nTamGrd  := TamSX3("C2_ITEMGRD")[1]
      aAux[3]  := PadR(aAux[3],nTamNum+nTamItem+nTamSeq+nTamGrd)
      aAdd(aRetorno,aAux)
   Else
      aAdd(aRetorno, .F. )
      aAdd(aRetorno, STR0027 + AllTrim(cCode) ) //"Ordem de produ��o n�o encontrada no DE/PARA. -> "
   Endif
Return aRetorno


//-------------------------------------------------------------------------------------------------
/*{Protheus.doc} GetEmpenho
Recebe a lista de materiais da ordem de produ��o para gerar os empenhos

@param   CxML    XML recebido pelo EAI
@param   cOrdem  Ordem de produ��o 
@param   nOpc    Se est� ocorrendo uma inclus�o/altera��o da OP
@param   oXml    O Xml que foi passado para o adapter
@param   lRet    Retorno True (Sucesso )  ou False (Com erro)
@param   cXmlRet Retorno das mensagens de erro que ocorreram na execu��o do mata381
@param   cMarca  Produto da integra��o


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


	//Verifica se h� lista de materiais no xml
	//Esta verifica��o somente pode ocorrer na inclus�o e se n�o houver a lista de materiais.
	//Se tiver a tag listOfMaterialOrders e n�o tiver a tag MaterialOrders, deve excluir os empenhos j� existentes
	//Se n�o possuir a tag listOfMaterialOrders, significa que n�o haver� a altera��o/exclus�o dos empenhos.
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
		//Se n�o possuir a tag listOfMaterialOrders, significa que n�o haver� a altera��o/exclus�o dos empenhos.
		//Na inclus�o, significa que os empenhos ser�o criados conforme a engenharia.
		lRet := .T.
		Return lRet
	EndIf

	//Verifica se houve movimenta��o para a OP. Se existir, n�o permite alterar os empenhos.
    If !canUpdEmp(cOrdem)
        cXmlRet :=STR0031 //"N�o � poss�vel alterar os empenhos desta ordem, pois j� foram realizadas movimenta��es para a ordem."
        lRet := .F.
        Return .F.
    EndIf

	aCab  := {}
	aEmpenhos := {}


	//Cabe�alho com o n�mero da OP que serus�o dos empenhos.
	aCab := {{"D4_OP",cOrdem,NIL}} 

	For nI:= 1 to len(aXmlMatOrd)

		aLine := {}     

		//Sequencia do empenho
		If XmlChildEx(aXmlMatOrd[nI],"_PERTMATERIALNUMBER") != Nil .And. ;
			!Empty(aXmlMatOrd[nI]:_PertMaterialNumber:Text)
			cMatNumber := aXmlMatOrd[nI]:_PertMaterialNumber:Text

			aAdd(aLine,{"D4_TRT" , Padr(cMatNumber,nTamTRT) ,NIL})
		EndIf

		//N�mero Ordem Produ��o / ProductionOrderNumber
		If XmlChildEx(aXmlMatOrd[nI],"_PRODUCTIONORDERNUMBER") != Nil .And. ;
			!Empty(aXmlMatOrd[nI]:_ProductionOrderNumber:Text)
			cProdOrder := aXmlMatOrd[nI]:_ProductionOrderNumber:Text

			If PadR(cProdOrder, nTamOP)  <> cOrdem 
				lRet := .F.
				cXmlRet := STR0029 //"Ordem de produ��o da lista de materiais n�o pertence a ordem de produ��o importada"
				Return lRet
			EndIf
			aAdd(aLine,{"D4_OP" ,PadR(cProdOrder, nTamOP)     ,NIL})
		Else
			aAdd(aLine,{"D4_OP" ,cOrdem  ,NIL})
		EndIf


		//C�digo Item Reserva / MaterialCode
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
			cXmlRet := "MaterialCode " + STR0028 // � obrigat�rio."
			Return lRet
		EndIf

		SB1->(dbSetOrder(1))
		If !SB1->(dbSeek(xFilial("SB1")+cMatCode))
			lRet := .F.
			cXmlRet := STR0024 + AllTrim(cMatCode) + STR0025 //"Produto '"####"' n�o cadastrado."
			Return lRet
		EndIf

		//C�digo Roteiro / _ScriptCode
		If XmlChildEx(aXmlMatOrd[nI],"_SCRIPTCODE") != Nil .And. ;
			!Empty(aXmlMatOrd[nI]:_ScriptCode:Text)
			
			cScriptCod := aXmlMatOrd[nI]:_ScriptCode:Text

			aAdd(aLine,{"D4_ROTEIRO",Padr(cScriptCod, nTamROTEIR),NIL})
		EndIf

		//C�digo Opera��o / _ActivityCode 
		If XmlChildEx(aXmlMatOrd[nI],"_ACTIVITYCODE") != Nil .And. ;
			!Empty(aXmlMatOrd[nI]:_ActivityCode:Text)
			cActivity := aXmlMatOrd[nI]:_ActivityCode:Text

			aAdd(aLine,{"D4_OPERAC",Padr(cActivity,nTamOPERAC),NIL})
		EndIf            

		//C�digo Dep�sito / _WarehouseCode
		If XmlChildEx(aXmlMatOrd[nI],"_WAREHOUSECODE") != Nil .And. ;
			!Empty(aXmlMatOrd[nI]:_WarehouseCode:Text)
			
			cWarehouse := aXmlMatOrd[nI]:_WarehouseCode:Text

			aAdd(aLine,{"D4_LOCAL" ,Padr(cWarehouse,nTamLOCAL),NIL})
		Else
			aAdd(aLine,{"D4_LOCAL" ,SB1->B1_LOCPAD,Nil})
		EndIf

		//C�digo Lote/S�rie / _LotCode (lote)
		If XmlChildEx(aXmlMatOrd[nI],"_LOTCODE") != Nil .And. ;
			!Empty(aXmlMatOrd[nI]:_LotCode:Text)
			cLotCode := aXmlMatOrd[nI]:_LotCode:Text
			
			aAdd(aLine,{"D4_LOTECTL",Padr(cLotCode,nTamLOTECT),NIL})
		EndIf

		//endere�os dos empenhos:
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
			cXmlRet := "MaterialQuantity" + STR0028 // � obrigat�rio."
			Return lRet
		EndIf

		//Integra��o com o PIMS
		// Internal ID da Classe de Valor
		aLineNLI := {}
					
		If	XmlChildEx(aXmlMatOrd[nI],"_CLASSVALUEINTERNALID" ) != Nil .AND. ;
			!EMPTY( aXmlMatOrd[nI]:_ClassValueInternalId:Text )
			
			//Obt�m o valor interno
			cValExt := aXmlMatOrd[nI]:_ClassValueInternalId:Text
			aAux := C060GetInt(cValExt, cMarca)
			If aAux[1]
				aAdd( aLineNLI, { "NLI_CLVAL", PadR(aAux[2][3], TamSX3("CTH_CLVL")[1]), Nil } )
			Else
				lRet := .F.
				cXmlRet := STR0032 //"Classe de valor n�o cadastrada. "
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
				cXmlRet := STR0033 //"C�digo da fazenda n�o encontrado."
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

		// Quantidade da Popula��o (plans/ha)
		If 	XmlChildEx(aXmlMatOrd[nI],"_POPULATIONQUANTITY" ) != Nil .AND. ;
			!EMPTY( aXmlMatOrd[nI]:_PopulationQuantity:Text )
			aAdd( aLineNLI, { "NLI_POPQTD", val(replace(alltrim(transform(val(aXmlMatOrd[nI]:_PopulationQuantity:Text),X3Picture("NLI_POPQTD"))),",",".")), NIL } )
		Endif

		// Numero da Peneira
		If 	XmlChildEx(aXmlMatOrd[nI],"_NUMBEROFSIEVE" ) != Nil .AND. ;
			!EMPTY( aXmlMatOrd[nI]:_NumberOfSieve:Text )
			aAdd( aLineNLI, { "NLI_NUMPEN", val(replace(alltrim(transform(val(aXmlMatOrd[nI]:_NumberOfSieve:Text),X3Picture("NLI_NUMPEN"))),",",".")), NIL } )
		Endif

		// Quantidade de �rea Produtiva (h�)
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
				cXmlRet := STR0034 //"C�digo da cultura n�o encontrado."
				Return .F.
			Else
				If '|' $ cValInt 
               aAux := Separa(cValInt,'|')
               cValInt := aAux[3]
            EndIf
				aAdd( aLineNLI, { "NLI_CULTRA", PadR(cValInt, TamSX3("NP3_CODIGO")[1]), NIL } )
			Endif
		Else
			// C�digo da Cultura
			If XmlChildEx(aXmlMatOrd[nI],"_CULTURECODE" ) != Nil .AND. ;
				!EMPTY( aXmlMatOrd[nI]:_CultureCode:Text )
				aAdd( aLineNLI, { "NLI_CULTRA", aXmlMatOrd[nI]:_CultureCode:Text , NIL } )
			Endif
		Endif

		// ID de Integra��o do Centro de Custo
		If XmlChildEx(aXmlMatOrd[nI],"_COSTCENTERINTERNALID" ) != Nil .AND. ;
			!EMPTY( aXmlMatOrd[nI]:_CostCenterInternalId:Text )
			cValExt := aXmlMatOrd[nI]:_CostCenterInternalId:Text
			aAux := IntCusInt(cValExt, cMarca)
		
			If !aAux[1]
				lRet := .F.
				cXmlRet := STR0035 //"Centro de custo n�o encontrado." 
				Return .F.
			EndIf
			aAdd( aLineNLI, { "NLI_CC", aAux[2][3] , NIL } )
		Else
			// ID de Integra��o do Centro de Custo
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
				cXmlRet := STR0036 //"C�digo da fitossanidade n�o encontrado."
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
		
		//C�digo do Usu�rio Requisitante Proposta
		If 	XmlChildEx(aXmlMatOrd[nI],"_USERREQUESTERCODE" ) != Nil .AND. ;
			!EMPTY( aXmlMatOrd[nI]:_UserRequesterCode:Text )
			aAdd( aLineNLI, { "NLI_REQCOD", aXmlMatOrd[nI]:_UserRequesterCode:Text , NIL } )
		Endif

		//Nome do Usu�rio Requisitante
		If 	XmlChildEx(aXmlMatOrd[nI],"_USERREQUESTERNAME" ) != Nil .AND. ;
			!EMPTY( aXmlMatOrd[nI]:_UserRequesterName:Text )
			aAdd( aLineNLI, { "NLI_REQNOM", aXmlMatOrd[nI]:_UserRequesterName:Text, NIL } )
		Endif

		If len(aLineNLI) > 0
			aAdd(aLine,{"AUT_D4_AGR",aLineNLI,NIL})
		Endif 
		// Fim integra��o com o PIMS

		//endere�os dos empenhos:
		//If XmlChildEx(aXmlMatOrd[nI],"_LISTOFALLOCATEDMATERIAL") != Nil .And. ;
		//	!Empty(aXmlMatOrd[nI]:_ListOfAllocatedMaterial)
		//	aXmlLocMat := aXmlMatOrd[nI]:_ListOfAllocatedMaterial:_AllocatedMaterial
		//else 
		//	aXmlLocMat := {}
		//EndIf

		//Endere�o
		aEnder := {}
		For nI2 := 1 to len(aXmlLocMat)

			aLineEnder := {}
            cLocatCode := ""

			//Localiza��o/Endere�o / LocationCode
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
				cXmlRet := "AllocationQuantity " + STR0028 // � obrigat�rio."
				Return lRet
			EndIf

			//N�mero de Serie / NumberSeries
			If XmlChildEx(aXmlLocMat[nI2],"_NUMBERSERIES") != Nil .And. ;
				!Empty(aXmlLocMat[nI2]:_NumberSeries:Text)
				cSeries := aXmlLocMat[nI2]:_NumberSeries:Text

				aAdd(aLineEnder,{"DC_NUMSERI"  ,Padr(cSeries,nTamNUMSER),Nil})
			EndIf

			//C�digo SubLote/S�rie / _SubLoteCode (sublote)
			If XmlChildEx(aXmlLocMat[nI2],"_SUBLOTECODE") != Nil .And. ;
				!Empty(aXmlLocMat[nI2]:_SubLoteCode:Text)
				cSubLotCo2 := aXmlLocMat[nI2]:_SubLoteCode:Text
				
				If cSubLotCod != cSubLotCo2
					lRet := .F.
					cXmlRet := STR0037 //"N�o � permitido informar sublotes diferentes para um mesmo material."
					Return lRet
				EndIf
			EndIf
			
			// Inclus�o do endere�o no array
			If !Empty(cLocatCode)
				aAdd(aEnder,aLineEnder)
			EndIf
		next nI2 //Endere�o

		//Adiciona os endere�os na linha do empenho
		if len(aEnder) > 0 
			aAdd(aLine,{"AUT_D4_END",aEnder,Nil})
		Endif
		
		//Adiciona a linha do empenho no array de itens.
		aAdd(aEmpenhos,aLine)
		
	Next nI //Empenho


	If nOpc == 3 //Inclus�o
		//Se o array de empenhos estiver preenchido, o empenho ser� criado pelo mata381 e n�o pelo mata650
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
	ElseIf nOpc == 4 //Altera��o
		
		//Se o array de empenhos estiver preenchido, o empenho ser� criado pelo mata381 e n�o pelo mata650
		//Porque foi enviado o ListOfMaterialOrder
		

		// Exclus�o das Ordens de Produ��o que foram originadas pelo empenho de produtos intermedi�rios
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
			//Par�metro para excluir todas as ordens/Empenhos intermedi�rios geradas a partir da OP intermedi�ria
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


		//Se tiver a tag listOfMaterialOrders e n�o tiver a tag MaterialOrders, deve excluir os empenhos j� existentes
		//Se n�o possuir a tag listOfMaterialOrders, significa que n�o haver� a altera��o/exclus�o dos empenhos.
		
		//Exclus�o dos Empenhos j� existentes para a ordem de produ��o principal
		aCabEx := {{"D4_OP",cOrdem,NIL},;
				{"INDEX",2,Nil}}
		SD4->(dbSetOrder(2))
		If SD4->(dbSeek(xFilial("SD4")+cOrdem))
			//Executa o MATA381 para exclus�o dos empenhos que j� existiam na OP principal.
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
			
		//Inclus�o dos Empenhos da ListOfMaterialOrder que foram enviados na altera��o da OP
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
Verifica se a ordem de produ��o possui movimenta��o.

@param   cNumOp Ordem de produ��o 

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

Faz a convers�o de uma data string, ou de string para data
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
