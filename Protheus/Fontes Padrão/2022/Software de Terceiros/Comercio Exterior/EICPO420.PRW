#INCLUDE "Average.ch"
#INCLUDE "EICPO420.ch"

/*
Programa : EICPO420.PRW
Autor    : Igor Chiba (Average)
Data     : 23/05/2014
Revisao  :
Uso      : Manutencao
*/
*--------------------------------------------------------------------
Function EICPO420(lEnvio,nOpc,aCab,cAlias,lWk,cPo_num)
*--------------------------------------------------------------------
Local lRet:= .F.
DEFAULT lEnvio := .F.
PRIVATE cAlias_W2 := cAlias
PRIVATE lWork := lWk

IF lEnvio  //CHAMANDO DE OUTROS FONTES SÓ FAZER ENVIO SE FOR INCLUSAO , ALTERACAO OU EXCLUSAO
   IF (!EMPTY(cPo_num)) .AND. (cPo_num <> SW2->W2_PO_NUM)
      SW2->(DBSETORDER(1))
      SW2->(DBSEEK(xFilial("SW2")+cPo_num))
   ENDIF
   //lret := (EasyEnvEAI("EICPO420",nOpc))
   MsAguarde({|| lret := EasyEnvEAI("EICPO420",nOpc)}, STR0001)  //"Integração EAI - Pedido. Aguarde..."
   return lret
endif

IF (ValType(aCab) == "U" .or. (len(aCab) == 0))
   EasyHelp(STR0002,STR0003) //"Dados PO não informados"###"Atenção"
   RETURN .F.
ENDIF

IF nOpc <> 5 //nao for exclusao

   IF (nPos:= ascan(aCab,{|x| AllTrim(x[1]) == "W2_CONAPRO"})) <> 0
      cConapro := UPPER(ALLTRIM(aCab[nPos][2]))
      IF EMPTY(cConapro)
         EasyHelp(STR0004,STR0003) //"Confirmação Pedido não informada"###"Atenção"
         RETURN .F.
      ENDIF
   ENDIF


   IF (nPos:= ascan(aCab,{|x| AllTrim(x[1]) == "W2_PO_NUM"})) <> 0
      cPo_Num:= UPPER(ALLTRIM(aCab[nPos][2]))
      IF EMPTY(cPo_Num)
         EasyHelp(STR0005,STR0003)//"Numero do Pedido Easy não informado"###"Atenção"
         RETURN .F.
      ELSE
         IF !SW2->(DBSEEK(xFilial('SW2')+AVKEY(cPo_Num,'W2_PO_NUM')))
            EasyHelp(StrTran(STR0006,"###",ALLTRIM(cPo_Num)),STR0003)//"Pedido Easy : ### não encontrado"###"Atenção"
            RETURN .F.
         ENDIF

         IF (nPos:= ascan(aCab,{|x| AllTrim(x[1]) == "W2_PO_SIGA"})) <> 0
            cPo_Siga := UPPER(ALLTRIM(aCab[nPos][2]))
            IF EMPTY(cPo_Siga)
               EasyHelp(STR0007,STR0003) //"Numero do Pedido ERP não informado"###"Atenção"
            ELSEIF AVKEY(cPo_Siga,'W2_PO_SIGA') <> SW2->W2_PO_SIGA
               EasyHelp(STR0008,STR0003) //"Numero do Pedido ERP inválido."###"Atenção"
               RETURN .F.
            ENDIF
         ENDIF

         IF ALLTRIM(cConaPro) == '42'
            SW2->(MSUNLOCK())
            SW2->(RECLOCK('SW2',.F.))
            SW2->W2_CONAPRO := '1'
            SW2->(MSUNLOCK())
         ENDIF
      ENDIF
   ENDIF

ENDIF

Return .t.


*--------------------------------------------------------------------
/* ====================================================*
* Função: IntegDefK
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix
* Obs:
* =====================================================*/
*--------------------------------------------------------------------*
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
*--------------------------------------------------------------------*
Local oEasyIntEAI
Local cAlias:="SW2"

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)

	oEasyIntEAI:oMessage:SetVersion("3.003")
	oEasyIntEAI:oMessage:SetMainAlias("SW2")
	oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| EICPO420(.F.,oEasyMessage:GetOperation(),oEasyMessage:GetEAutoArray("SW2")) } )

	oEasyIntEAI:SetModule("EIC",17)
	// Recebimento
	oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "PO420RECB") //RECEBIMENTO DE BUSINESS MESSAGE     (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "PO420RESB") //RESPOSTA SOBRE O RECEBIMENTO        (<-Response)
    // Envio -- Jacomo Lisa - 28/05/2014
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "PO420SEND") //ENVIO DO PEDIDO                     (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "PO420RESP") //RESPOSTA SOBRE O ENVIO              (<-Response)

	oEasyIntEAI:Execute()

Return oEasyIntEAI:GetResult()

*------------------------------------------------*
Function PO420RECB(oMessage)
*------------------------------------------------*
Local oBusinessCont  := oMessage:GetMsgContent()
Local oCab           := ERec():New()
Local oParams        := ERec():New()
//Local oBusinesEvent  := oMessage:GetEvtContent()
//Local cEvento        := Upper(EasyGetXMLinfo(,oBusinesEvent,"_Event"))
Local nI
Local oBatch         := EBatch():New()
Local oExecAuto      := EExecAuto():New()
Local oInformation   := oMessage:GetMsgInfo()



//IGOR CHIBA PRE ADAPTER PARA AQUISICAO 16/06/2014
cOrder   := EasyGetXMLinfo(, oBusinessCont, "_OrderPurpose")
cTypeOrd := EasyGetXMLinfo(, oBusinessCont, "_ordertypecode")
cErp     := oInformation:_PRODUCT:_NAME:TEXT
IF cOrder  == '1' .AND. cTypeOrd == '004' .AND. cErp == 'LOGIX' //como o xml é o mesmo para PO e aquisicao estes campos decidem quando sera aquisicao
   RETURN ESSRECB(oMessage)
ENDIF

//ADAPTER PARA PO
oRequestPO:=oBusinessCont:_Other:_ADDFIELDS:_ADDFIELD

If ValType(oRequestPO) <> "A"
   aArray := {oRequestPO}
Else
   aArray := oRequestPO
EndIf


oCab:SetField("W2_CONAPRO" ,EasyGetXMLinfo(, oBusinessCont, "_funcmsgorder" ))//confirmado pelo ERP
oCab:SetField("W2_PO_SIGA" ,EasyGetXMLinfo("W2_PO_SIGA", oBusinessCont, "_OrderId" ) )
For nI:=1  to len(aArray)
   IF ALLTRIM(UPPER(aArray[nI]:_FIELD:TEXT)) == 'ORDEREXTCOD'
     oCab:SetField("W2_PO_NUM" ,EasyGetXMLinfo("W2_PO_NUM" , aArray[nI]    , "_Value" )  ) //EasyGetXMLinfo("W2_PO_NUM" , aArray[2]    , "_Value" )
   ENDIF
Next

oExecAuto:SetField("SW2",oCab)

oParams:SetField("nOpc",4)//Alteracao
oExecAuto:SetField("PARAMS"  ,oParams)

oBatch:AddRec(oExecAuto)


Return oBatch

*-------------------------------------------------*
Function PO420RESB(oMessage)
*-------------------------------------------------*
Local oXml      //:= EXml():New() //comentado por wfs 22/08/2014
Local oBusinessCont:= oMessage:GetMsgContent()
Local cOrderId:= ""


    /* Tratamento de retorno */
    If !oMessage:HasErrors()

       	cOrderId	:= EasyGetXMLinfo(, oBusinessCont, "_OrderId")

       	oXml:= ENode():New()
       	oXml:SetField('OrderId', cOrderId)
    Else
       oXMl := oMessage:GetContentList("RESPONSE")
    EndIf

Return oXml


*------------------------------------------------*
Function PO420SEND(oMessage)
*------------------------------------------------*
Local oXml      := EXml():New()
Local oBusiness := ENode():New()
Local oEvent    := ENode():New()
Local oRec      := ENode():New()
Local oIdent    := ENode():New()
Local aOrd      := {}
//variaveis predefinidas
Local cPoNum      := &(cAlias_W2+"->W2_PO_NUM")
Local nFunMsgOrd,n1
Local cOrderID    := ""
Local cUserID     := ""
Local cCondPagERP := ""
Local cCotacao    := ""
Local aPrgEnt     := {}
IF lWork
   aOrd := SaveOrd({"SW1","SW2","SW3","SWT","WORK"})
ELSE
   aOrd := SaveOrd({"SW1","SW2","SW3","SWT"})
ENDIF
SWT->(DBSETORDER(1))//WT_FILIAL+WT_NR_CONC+WT_COD_I+WT_FORN+WT_FORLOJ
SW1->(DBSETORDER(1))//W1_FILIAL+W1_CC+W1_SI_NUM+W1_COD_I
SY1->(DBSETORDER(1))//Y1_FILIAL+Y1_COD
SY6->(DBSETORDER(1))//Y6_FILIAL+Y6_COD+STR(Y6_DIAS_PA,3,0)
SYF->(DBSETORDER(1))//YF_FILIAL+YF_MOEDA
//evento
oEvent:SetField("Entity", "EICPO420")
//oEvent:SetField("Event" , "upsert")//Evento da Capa //Foi la para baixo por causa do while no work

//chave
oKeyNode:= ENode():New()
oKeyNode:SetField(EAtt():New("name","OrderExtCod"))
oKeyNode:SetField(ETag():New("" ,cPoNum))
oIdent:SetField(ETag():New("key",oKeyNode))


//oEvent:SetField("Identification",oIdent)//Foi la para baixo por causa do while no work
/* Alterada de moeda de venda para moeda de compra.
   Verificar a possibilidade de parametrizar, para publicação.
   wfs */
IF SYF->(DBSEEK(xFilial("SYF")+&(cAlias_W2+"->W2_MOEDA")))
   cMoeda:= SYF->YF_CODCERP //SYF->YF_CODVERP
ENDIF
/*IF SY1->(DBSEEK(xFilial("SY1")+&(cAlias_W2+"->W2_COMPRA"))) //NCF - 18/04/2016 - Retirado pois o código de Usuário ficará no próprio ERP Externo
   cUserID:=SY1->Y1_CODERP
ENDIF*/
IF SY6->(DBSEEK(xFilial("SY6")+&(cAlias_W2+"->W2_COND_PA")+STR(&(cAlias_W2+"->W2_DIAS_PA"),3,0)))
   cCondPagERP:=SY6->Y6_CODERP
ENDIF
//capa
//<BusinessContent>
nFunMsgOrd := IF(nEAIEvent == 3, 9 , 10)
cOrderID   := IF(nEAIEvent<> 3, &(cAlias_W2+"->W2_PO_SIGA") ,"")

   oBusiness:SetField("CompanyId"      	,SM0->M0_CODIGO)
   oBusiness:SetField("CompanyInternalId",SM0->M0_CODIGO) //wfs
   oBusiness:SetField("BranchId"        ,SM0->M0_CODFIL) //wfs
   oBusiness:SetField("funcmsgorder"   ,nFunMsgOrd )//Inclusão = 9 || Alteração = 10
   oBusiness:SetField("OrderPurpose"   ,"1" )//Objetivo do Pedido:1 – compra|2 – venda
   oBusiness:SetField("ordertypecode"  ,"001" )//001 – Normal
   oBusiness:SetField("OrderId"        ,cOrderID)//Se diferente de inclusão, mandar preenchido com o W2_PO_SIGA
   oBusiness:SetField("FreightType"    ,"3") // IF(&(cAlias_W2+"->W2_FREPPCC") == "PP","1","2") -- W2_FREPPCC: qndo Prepaid(CIF) = 1 || Qndo Collect(FOB) = 2
   oBusiness:SetField("FreightValue"   ,&(cAlias_W2+"->W2_FRETEIN") )//Valor do Frete
   oBusiness:SetField("CurrencyCode"   ,cMoeda) // (YF_CODVERP)Moeda do Pedido
   If EasyGParam("MV_EIC_PCO",,.F.) .And. SW2->W2_IMPCO == "1" .And. !EasyGParam("MV_PCOIMPO",,.T.)
      oBusiness:SetField("CustomerCode"   ,Posicione("SYT", 1, xFilial("SYT")+&(cAlias_W2+"->W2_IMPORT"), "YT_FORN"))
   Else
      oBusiness:SetField("CustomerCode"   ,&(cAlias_W2+"->W2_FORN"))
   EndIf
   //oBusiness:SetField("UserInternalId" ,cUserID)//(Y1_CODERP) - Internal Id do Usuário        //NCF - 18/04/2016
   oBusiness:SetField("PaymentTermCode",cCondPagERP)//(Y6_CODERP) - Cond Pagamento do ERP

   //</SalesOrderItens>
      oSalesOrder:= ENode():New() //<SalesOrderItens>

      IF lWork
         WORK->(DBGOTOP())
         bWhile := {||WORK->(!EOF())  }
      ELSE
         SW3->(DBSETORDER(1))
         SW3->(DBSEEK(xFilial("SW3")+&(cAlias_W2+"->W2_PO_NUM")))
         bWhile := {|| SW3->(!EOF()) .AND. SW3->W3_FILIAL == xFilial("SW3") .AND. SW3->W3_PO_NUM == &(cAlias_W2+"->W2_PO_NUM") }
      ENDIF
      lTodosMarcados:=.T.//Controle do envento da capa do estorno
      DO WHILE EVAL(bWhile)
         IF lWork
            IF nEAIEvent # 5 .AND. EMPTY(WORK->WKFLAGWIN) .AND. EMPTY(Work->WKREC_SW3)  //AWF - 21/07/2014 - Envia a Delecao dos itens desmarcados na alteracao
               WORK->(DBSKIP())
               LOOP
            ENDIF
         ELSE
            IF SW3->W3_SEQ <> 0
               SW3->(DBSKIP())
               LOOP
            ENDIF
         ENDIF
         //<Item>
         oItens:= ENode():New()
         oItens:SetField("OrderId"       , cOrderID) //Numero do Pedido ERP
         oItens:SetField("numitemrequest", IF(lWork,WORK->WKSI_NUM,SW3->W3_SI_NUM)  )//SW3->W3_SI_NUM)//Sequencia do Item (Inteiro, não negativo)
         oItens:SetField("ItemCode"      , IF(lWork,WORK->WKCOD_I,SW3->W3_COD_I)   )//SW3->W3_COD_I)//Codigo do Item
         nQtd  := IF(lWork,WORK->WKQTDE-WORK->WKSLD_ELI , SW3->W3_QTDE-SW3->W3_SLD_ELI)
         oItens:SetField("Quantity"      , nQtd)//Quantidade Total do Item
         oItens:SetField("UnityPrice"    , IF(lWork,WORK->WKPRECO,SW3->W3_PRECO)  )//SW3->W3_PRECO)//Preco Unitario
         IF cAlias_W2 == "SW2"
            cObs := IF(!EMPTY(SW2->W2_OBS),MSMM(SW2->W2_OBS), "")
         ELSE
            cObs := M->W2_VM_OBS
         ENDIF
         oItens:SetField("ItemMessages"  , cObs)//Memo de Observacao

         IF lWork
            lSeekSW1 := SW1->(DBSEEK(xFilial("SW1")+WORK->WKCC+WORK->WKSI_NUM+WORK->WKCOD_I))
            //lSeekSWT := SWT->(DBSEEK(xFilial("SWT")+SW1->W1_NR_CONC+WORK->WKCOD_I))
            lSeekSWT := SWT->(DBSEEK(xFilial("SWT")+SW1->W1_NR_CONC+WORK->WKCOD_I+&(cAlias_W2+"->W2_FORN")+&(cAlias_W2+"->W2_FORLOJ")))
         ELSE
            lSeekSW1 := SW1->(DBSEEK(xFilial("SW1")+SW3->W3_CC+SW3->W3_SI_NUM+SW3->W3_COD_I))
            //lSeekSWT := SWT->(DBSEEK(xFilial("SWT")+SW1->W1_NR_CONC+SW3->W3_COD_I))
            lSeekSWT := SWT->(DBSEEK(xFilial("SWT")+SW1->W1_NR_CONC+SW3->W3_COD_I+&(cAlias_W2+"->W2_FORN")+&(cAlias_W2+"->W2_FORLOJ")))
         ENDIF

         //Verificação da cotação vencedora
         If lSeekSWT

         	lSeekSWT:= .F.

         	While SWT->(!Eof()) .And. SWT->WT_FILIAL == SWT->(xFilial()) .And.;
         			SWT->WT_NR_CONC == SW1->W1_NR_CONC .And. SWT->WT_COD_I == SW1->W1_COD_I .And.;
         			SWT->(WT_FORN+WT_FORLOJ) == &(cAlias_W2+"->W2_FORN")+&(cAlias_W2+"->W2_FORLOJ")

         		If SWT->WT_STATUS == "3" .And. SWT->WT_SI_NUM == SW1->W1_SI_NUM //aprovado
         			lSeekSWT:= .T.
         			Exit
         		EndIf

         		SWT->(DBSkip())
         	EndDo

         EndIf
         IF lSeekSWT
            oItens:SetField("contractnumber", SWT->WT_NUMERP)//(WT_NUMERP) -- Numero da Cotação Aprovada
         ElseIf lSeekSW1 .AND. !Empty(SW1->W1_C3_NUM) .AND.  &(cAlias_W2+"->W2_CONTR") == "1"
            oItens:SetField("contractnumber", SW1->W1_C3_NUM)//(W1_C3_NUM) -- Numero do Contrato
         EndIf

         IF lSeekSW1 .AND. (!EMPTY(SW1->W1_NR_CONC))
             //<OTHER>
             oOther_I:= ENode():New()
                //<ADDFIELDs>
                oA_Fields:= ENode():New()
                   //<ADDFIELD>
                   oA_Field:= ENode():New()
                   oA_Field:SetField("field","ExternalCode") //Indentificar o numero do (Pedido na Trade) quadro de concorrência
                   oA_Field:SetField("value",SW1->W1_NR_CONC)//Indentificar o numero do (Pedido na Trade) quadro de concorrência
                   //</ADDFIELD>
                oA_Fields:SetField("ADDFIELD",oA_Field)
                //</ADDFIELDs>
             oOther_I:SetField("ADDFIELDS",oA_Fields)

            oItens:SetField("OTHER", oOther_I)
         ENDIF

         //<CROSSDOCKING>
             oCROSSDOCKING:= ENode():New()
             //<CROSSDOCKING_ITEM>
                IF lWork
                   aPrgEnt := PO420PrgEntrega(.F.,WORK->WKCOD_I,WORK->WKCC,WORK->WKSI_NUM,cPoNum)//lEspecifico,cCodItem,cUR,cSI,cPO,cPLI,cProc
                ELSE
                   aPrgEnt := PO420PrgEntrega(.F.,SW3->W3_COD_I,SW3->W3_CC,SW3->W3_SI_NUM,cPoNum)//lEspecifico,cCodItem,cUR,cSI,cPO,cPLI,cProc
                ENDIF
                FOR n1 := 1 to len(aPrgEnt)
                   oC_D_Item    := ENode():New()
                   oC_D_Item:SetField("dhfindelivery" ,EasyTimeStamp(aPrgEnt[n1][2],.t.,.F.))//Work->WKDT_ENTR ) //Data principal de Entrega
                   oC_D_Item:SetField("quantdelivery" ,aPrgEnt[n1][3])//Work->WKQTDE)  //Qtd de Item no pedido
                   oC_D_Item:SetField("orderline",aPrgEnt[n1][1])
                   oCROSSDOCKING:SetField("CROSSDOCKING_ITEM", oC_D_Item)
                NEXT
             //</CROSSDOCKING_ITEM>
         oItens:SetField("CROSSDOCKING", oCROSSDOCKING)
         //</CROSSDOCKING>

         IF nEAIEvent # 5 .AND. lWork .AND. EMPTY(WORK->WKFLAGWIN) .AND. !EMPTY(Work->WKREC_SW3) //AWF - 21/07/2014 -Envia a Delecao dos itens desmarcados na alteracao
            oItens:SetField("Event", "delete")//Evento do Item
         ENDIF

         IF nEAIEvent == 5 .AND. lWork//ESTORNO
            IF !EMPTY(WORK->WKFLAGWIN)  //Apenas enviar a tag <Event>delete</Event> qndo tiver marcado esse item para estorno
               oItens:SetField("Event", "delete")//Evento do Item
            ELSE
               lTodosMarcados:=.F.//Controle do envento da capa do estorno
            ENDIF
         ENDIF
         //</Item>
         oSalesOrder:SetField("Item",oItens)
         IF(lWork, WORK->(DBSKIP()) , SW3->(DBSKIP()) )
      ENDDO
   //</SalesOrderItens>
   //<OTHER>
      oOTHER:= ENode():New()
         //<ADDFIELDs>
         oADDFIELDs:= ENode():New()
            //<ADDFIELD>
            oADDFIELD:= ENode():New()
            oADDFIELD:SetField("field","OrderExtCod") //Indentificar o numero do Pedido na Trade
            oADDFIELD:SetField("value",cPoNum)        //Indentificar o numero do Pedido na Trade
            //</ADDFIELD>

         oADDFIELDs:SetField("ADDFIELD",oADDFIELD)
         //</ADDFIELDs>
      oOTHER:SetField("ADDFIELDS",oADDFIELDs)

   //</OTHER>
   //<SUMMARY>
      oSummary:= ENode():New()
	  oSummary:SetField("ordertotalnetamount",&(cAlias_W2+"->W2_FOB_TOT"))//Total do Pedido(itens)
	  nTot:= &(cAlias_W2+"->(W2_FOB_TOT+W2_INLAND+W2_PACKING+W2_FRETEIN+W2_OUT_DES-W2_DESCONT)")
      oSummary:SetField("ordertotalamount"   ,nTot)
   //</SUMMARY>


   oBusiness:SetField("SalesOrderItens",oSalesOrder)
   oBusiness:SetField("OTHER"          ,oOTHER)
   oBusiness:SetField("SUMMARY"        ,oSummary)

   IF nEAIEvent == 5 .AND. lWork .AND. lTodosMarcados .AND. lLeuTodosItens//AWF - 21/07/2014 - Variavel lLeuTodosItens iniciada no EICPO400.PRW - Function PO400Work(bMsg,cOpcao,nValItens) - Function PO400Estor(cAlias,nReg,nOpc)
      oEvent:SetField("Event" , "delete")//Evento da Capa
   ELSE
      oEvent:SetField("Event" , "upsert")//Evento da Capa
   ENDIF
   oEvent:SetField("Identification",oIdent)

   oRec:SetField("BusinessEvent"  ,oEvent)
   oRec:SetField("BusinessContent",oBusiness)
   oXml:AddRec(oRec)

   RestOrd(aOrd,.t.)

Return oXml


*------------------------------------------------*
Function PO420RESP(oMessage)
*------------------------------------------------*
Local oRetCont       := oMessage:GetRetContent()
Local oBusinessCont  := oMessage:GetRetContent()
Local oBusinessEvent := oMessage:GetEvtContent()
Local cPONum  := ""
Local cOrderID := EasyGetXMLinfo(,oRetCont,"_OrderId")
Local cStatus  := EasyGetXMLinfo(,oRetCont,"_Status")
Local aOrd     := SaveOrd({"SW1","SW2"})

   If ValType(oBusinessEvent:_IDENTIFICATION:_KEY) <> "A"
      aKey := {oBusinessEvent:_IDENTIFICATION:_KEY}
   Else
      aKey := oBusinessEvent:_IDENTIFICATION:_KEY
   EndIf

   aEval(aKey, {|x| If(Upper(Alltrim(x:_NAME:Text)) == "ORDEREXTCOD", cPONum := x:TEXT,)}) //Buscar o numero do Pedido para posicionar no retorno.

   IF (!EMPTY(cPONum)) .AND. (cPONum <> SW2->W2_PO_NUM)
      SW2->(DBSETORDER(1))
      SW2->(DBSEEK(xFilial("SW2")+cPONum))
   ENDIF

IF cAlias_W2 == "SW2"
   &("cAlias_W2")->(RecLock("SW2",.F.))
ENDIF
&(cAlias_W2+"->W2_PO_SIGA") := cOrderID
&(cAlias_W2+"->W2_CONAPRO") := cStatus
IF cAlias_W2 == "SW2"
   &("cAlias_W2")->(MSUNLOCK())
ENDIF

If lWork

   SW1->(DBSetOrder(1))
   WORK->(DBGoTop())

   While WORK->(!Eof())

      If SW1->(DBSeek(xFilial() + WORK->WKCC + WORK->WKSI_NUM + WORK->WKCOD_I))

         SW1->(RecLock("SW1",.F.))

         //Operações de inclusão e alteração
         If nEAIEvent <> 5  //Alterar o Saldo da Quantidade e da SI

            //Quando a operação for alteração, o item pode ser retirado (desmarcado) do pedido
            If Empty(WORK->WKFLAGWIN)
               //se não possuir cotação, volta para o status pendente; se possuir, fica aguardando P.O.
               If Empty(SW1->W1_NR_CONC) .AND. Empty(SW1->W1_C3_NUM)
                  SW1->W1_STATUS:= "A" //WFS 20/08/2014 - Pendente
               ElseIf Empty(SW1->W1_NR_CONC)  .AND. !Empty(SW1->W1_C3_NUM)
                  SW1->W1_STATUS:= "G" //GFP - 06/09/2016 - Contratos
               Else
                  SW1->W1_STATUS:= "D" //WFS 20/08/2014 - Aguardando Purchase Order
               EndIf
            Else
               SW1->W1_QTDE    := WORK->WKQTDE
               SW1->W1_SALDO_Q:= 0
               SW1->W1_STATUS := "F" //WFS 30/07/2014 - Atendida - em fase de Purchase Order
            EndIf

         //Operação de estorno
         Else
            //Quando a operação for estorno, o item pode marcado é que será retirado do pedido.
            If !Empty(WORK->WKFLAGWIN)
               //se não possuir cotação, volta para o status pendente; se possuir, fica aguardando P.O.
               If Empty(SW1->W1_NR_CONC)  .AND. Empty(SW1->W1_C3_NUM)
                  SW1->W1_STATUS:= "A" //WFS 20/08/2014 - Pendente
               ElseIf Empty(SW1->W1_NR_CONC)  .AND. !Empty(SW1->W1_C3_NUM)
                  SW1->W1_STATUS:= "G" //GFP - 17/08/2016 - Contratos
               Else
                  SW1->W1_STATUS:= "D" //WFS 20/08/2014 - Aguardando Purchase Order
               EndIf
            EndIf
         EndIf

         SW1->(MsUnlock())

      EndIf

      WORK->(DBSkip())
   EndDo
EndIf

//Varinfo("RESPONSE",{ .T., oMessage:XMESSAGE })
oMessage:AddInList("RECEIVE", {"Sucesso" , "Registro Gravado no Destino" , Nil})

RestOrd(aOrd,.t.)
Return oMessage

/*
Programa   : PO420PrgEntrega()
Objetivo   : Montar a programação de entregas a partir do Purchase Order
Parâmetros : Flag que indica se retornará uma programação de entrega em específico,
             produto, unidade requisitante, solicitação de importação (ordem de compra),
             purchase order, P.L.I., embarque.
Retorno    : Array multidimensional -
             {{1 - número da programação de entregas, 2 - data de entrega prevista, 3 - quantidade prevista}}
Autor      : Alex Wallauer (AWR)
Data       :
Revisão    : Revisado e adaptado por WFS
*/
*-------------------------------------------------------------------------------*
Function PO420PrgEntrega(lEspecifico,cCodItem,cUR,cSI,cPO,cPLI,cProc)
*-------------------------------------------------------------------------------*
LOCAL aEntregas:={}, nPos
LOCAL cFilSW3,cFilSW5,cFilSW6
LOCAL aSave

DEFAULT lEspecifico := .F.

IF EMPTY(cCodItem)
   RETURN aEntregas
ENDIF
IF EMPTY(cUR)
   RETURN aEntregas
ENDIF
IF EMPTY(cSI)
   RETURN aEntregas
ENDIF
IF EMPTY(cPO)
   RETURN aEntregas
ENDIF

aSave:=SaveOrd({"SW3","SW5","SW6"})
cFilSW3:=xFilial("SW3")
cFilSW5:=xFilial("SW5")
cFilSW6:=xFilial("SW6")

SW3->(dbSetOrder(1))//W3_FILIAL+W3_PO_NUM+W3_CC+W3_SI_NUM+W3_COD_I
IF !SW3->(DbSeek(cFilSW3+cPO+cUR+cSI+cCodItem))
   RETURN aEntregas
ENDIF

/* WFS - modificação na montagem da programação de entregas.*/
/* Quando o pedido for de entreposto, deve ser enviado o purchase order e a
   solicitação de importação originais, para que o sistema monte a programação
   completa. Esse tratamento objetiva prever o envio dos dados a partir da geração
   nota fiscal de nacionalização, para busca de uma programação específica.*/
If !Empty(SW3->W3_PO_DA) .And. lEspecifico
   SW5->(DBSetOrder(8)) //W5_FILIAL + W5_PGI_NUM + W5_PO_NUM + W5_POSICAO
   If !SW5->(DBSeek(xFilial() + SW3->W3_PGI_DA + SW3->W3_PO_DA + SW3->W3_POSI_DA))
      Return aEntregas
   Else
      cPO:= SW3->W3_PO_DA
      cSI:= SW5->W5_SI_NUM
   EndIf
EndIf

/* Verificação da programação de entregas com base nos dados do pedido
   e utilização dos itens nas fases subsequentes.*/
aEntregas:= PrgPedido(cFilSW3 + cPO + cUR + cSI + cCodItem)

IF lEspecifico
   IF EMPTY(cPLI) .OR. EMPTY(cProc) .OR. LEN(aEntregas) == 0
      RETURN {}
   ENDIF
   IF (nPos:=ASCAN(aEntregas, {|E| AvKey(E[4], "W5_PGI_NUM") == cPLI .AND. AvKey(E[5], "W5_HAWB") == cProc} )) # 0
      RETURN { aEntregas[nPos] }
   ELSE
      RETURN {}
   ENDIF
ENDIF

RestOrd(aSave, .T.)
Return aEntregas

/*
Programa   : PrgPedido()
Objetivo   : Montar a programação de entregas a partir do pedido, respeitando a chave de comparação.
Parâmetros : Chave que determina qual item do pedido deve ser considerado para a montagem
             da programação de entregas. Chave composta pela filial, pedido, unidade requisitante,
             solicitação de importação (ordem de compra) e produto.
             Segundo parâmetro: apenas quando entreposto, serão enviados a PLI e posição do processo original
             para distinção do item.
Retorno    : Array multidimensional com a programação de entregas -
             {{1 - número da programação de entregas, 2 - data de entrega prevista, 3 - quantidade prevista, 4 - P.L.I, 5 - Embarque}}
Autor      : WFS
Data       :
Revisão    :
*/

Static Function PrgPedido(cChave, cChvEntreposto)
Local aOrd:= SaveOrd("SW3")
Local aSeqZero:= {}
Local aEntregas:= {}
Local aRet:= {}
Local nCont:= 0
Default:= ""

Begin Sequence

   SW3->(DBSetOrder(1)) //W3_FILIAL + W3_PO_NUM + W3_CC + W3_SI_NUM + W3_COD_I
   If !SW3->(DBSeek(cChave))
      Break
   EndIf

   Do While SW3->(!Eof()) .And.;
            SW3->W3_FILIAL + SW3->W3_PO_NUM + SW3->W3_CC + SW3->W3_SI_NUM + SW3->W3_COD_I == cChave

      /* Quando não for processo de entreposto, não haverá necessidade de comparar
         a P.L.I. e a posição do processo original; quando entreposto, terá PLI automática ou manual; quando
         automática, itens de vários processos podem passar a compor um mesmo processo na fase de nacionalização e,
         quando manual, o campo W3_PGI_DA não será preenchido.*/
      If !Empty(cChvEntreposto) .And. (SW3->(W3_PGI_DA + W3_POSI_DA) <> cChvEntreposto .And. PLIAutomatica(SW3->W3_PGI_NUM))
         SW3->(DBSkip())
         Loop
      EndIf

      /* Quando a sequência 0 tiver saldo, será a última programação*/
      If SW3->W3_SEQ == 0

         If SW3->W3_SALDO_Q <> 0
            AAdd(aSeqZero, {0, SW3->W3_DT_ENTR, SW3->W3_SALDO_Q, SW3->W3_PGI_NUM, ""})
            /*{{1 - número da programação de entregas, 2 - data de entrega prevista, 3 - quantidade prevista, 4 - P.L.I, 5 - Embarque}}*/
         EndIf

      Else

      /* Quando a sequência for diferente de 0, a programação de entregas será o agrupamento
         que representa o uso desta sequência na fase posterior (preparação de licença de importação),
         iniciando pela última sequência armazenada no array aEntregas*/

         aRet:= PrgPLI(SW5->(xFilial()) + SW3->W3_PGI_NUM + SW3->W3_CC + SW3->W3_SI_NUM + SW3->W3_COD_I)

         /* Retorno: {{1 - número da programação de entregas, 2 - data de entrega prevista, 3 - quantidade prevista, 4 - P.L.I, 5 - Embarque}}*/
         For nCont:= 1 To Len(aRet)
            AAdd(aEntregas, {StrZero(Len(aEntregas) + 1, 3), aRet[nCont][2], aRet[nCont][3], aRet[nCont][4], aRet[nCont][5]})
         Next

      EndIf

      SW3->(DBSkip())

   EndDo

   If Len(aSeqZero) > 0
      AAdd(aEntregas, {StrZero(Len(aEntregas) + 1, 3), aSeqZero[1][2], aSeqZero[1][3], aSeqZero[1][4], aSeqZero[1][5]})
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return AClone(aEntregas)

/*
Programa   : PrgPLI()
Objetivo   : Montar a programação de entregas a partir da PLI, respeitando a chave de comparação.
Parâmetros : Chave que determina qual item da PLI deve ser considerado para a montagem
             da programação de entregas, composta pelo número da P.L.I., unidade requisitante,
             solicitação de importação (ordem de compra) e produto.
Retorno    : Array multidimensional com a programação de entregas -
             {{1 - número da programação de entregas, 2 - data de entrega prevista, 3 - quantidade prevista, 4 - P.L.I, 5 - Embarque}}
Autor      : WFS
Data       :
Revisão    :
*/

Static Function PrgPLI(cChave)
Local aOrd:= SaveOrd({"SW5", "SW6"})
Local aSeqZero:= {}
Local aEntregas:= {}
Local aRet:= {}
Local nCont:= 0
Local dEntrega

Begin Sequence

   SW5->(DBSetOrder(1)) //W5_FILIAL + W5_PGI_NUM + W5_CC + W5_SI_NUM + W5_COD_I
   SW6->(DBSetOrder(1)) //W6_FILIAL + W6_HAWB

   If !SW5->(DBSeek(cChave))
      Break
   EndIf

   Do While SW5->(!Eof()) .And.;
            SW5->W5_FILIAL + SW5->W5_PGI_NUM + SW5->W5_CC + SW5->W5_SI_NUM + SW5->W5_COD_I == cChave

      /* Consiste a posição, para garantir que é o mesmo item, principalmente nos processos
         de entreposto aduaneiro onde itens de vários processos podem passar a compor um único
         na fase de nacionalização.*/
      If SW5->W5_POSICAO <> SW3->W3_POSICAO
         SW5->(DBSkip())
         Loop
      EndIf

      /* Quando a sequência 0 tiver saldo, será a última programação*/
      If SW5->W5_SEQ == 0
         If SW5->W5_SALDO_Q <> 0
            AAdd(aSeqZero, {0, SW5->W5_DT_ENTR, SW5->W5_SALDO_Q, SW5->W5_PGI_NUM, SW5->W5_HAWB})
            /* {{1 - número da programação de entregas, 2 - data de entrega prevista, 3 - quantidade prevista, 4 - P.L.I, 5 - Embarque}}*/
         EndIf

      Else

      /* Quando a sequência for diferente de 0, a programação de entregas será o agrupamento
         que representa o uso desta sequência na fase posterior (embarque/ desembaraço),
         iniciando pela última sequência armazenada no array aEntregas.
         Quando o processo for de entreposto, será retornado todas as programações que correspondam
         a essa sequência da PLI.*/

         SW6->(DBSeek(SW6->(xFilial()) + SW5->W5_HAWB))

         If Entreposto() //se é entreposto e possui pedido de nacionalização

            /* Busca da programação de entregas com base nos itens do processo de entreposto/ nacionalização.
               Parâmetros: embarque, P.L.I., pedido, unidade requisitante, produto e posição.*/
            aRet:= PrgEntreposto(SW5->W5_HAWB, SW5->W5_PGI_NUM, SW5->W5_PO_NUM, SW5->W5_CC, SW5->W5_COD_I, SW5->W5_POSICAO)

            /* Retorno: {{1 - número da programação de entregas, 2 - data de entrega prevista, 3 - quantidade prevista, 4 - P.L.I, 5 - Embarque}}*/
            For nCont:= 1 To Len(aRet)
               AAdd(aEntregas, {StrZero(Len(aEntregas) + 1, 3), aRet[nCont][2], aRet[nCont][3], aRet[nCont][4], aRet[nCont][5]})
            Next

         Else

            dEntrega:= SW5->W5_DT_ENTR

            If !Empty(SW6->W6_DT_ENTR)
               dEntrega:= SW6->W6_DT_ENTR
            Else
               If !Empty(SW6->W6_PRVENTR)
                  dEntrega:= SW6->W6_PRVENTR
               EndIf
            EndIf

            /* Retorno: {{1 - número da programação de entregas, 2 - data de entrega prevista, 3 - quantidade prevista, 4 - P.L.I, 5 - Embarque}}*/
            AAdd(aEntregas, {StrZero(Len(aEntregas) + 1, 3), dEntrega, SW5->W5_QTDE, SW5->W5_PGI_NUM, SW5->W5_HAWB})
         EndIf
      EndIf

      SW5->(DBSkip())
   EndDo

   If Len(aSeqZero) > 0
      AAdd(aEntregas, {StrZero(Len(aEntregas) + 1, 3), aSeqZero[1][2], aSeqZero[1][3], aSeqZero[1][4], aSeqZero[1][5]})
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return AClone(aEntregas)


/*
Programa   : Entreposto()
Objetivo   : Verificar se é processo de entreposto e se possui pedido de nacionalização para
             que seja possível rastrear a programação de entregas.
Parâmetros :
Retorno    : Lógico - True quando é entreposto e há pedido de nacionalização
Autor      : WFS
Data       :
Revisão    :
*/

Static Function Entreposto()
Local lRet:= .F.
Local cPedNacional:= ""
Local aOrd:= SaveOrd("SW2")

Begin Sequence

   SW2->(DBSetOrder(1)) //W2_FILIAL + W2_PO_NUM

   If SW6->W6_TIPODES $ "02/03/04" .And. !Empty(SW6->W6_DI_NUM)

      cPedNacional:= PedidoNac(SW6->W6_DI_NUM)
      If SW2->(DBSeek(xFilial() + cPedNacional))
         lRet:= .T.
      EndIf

   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return lRet

/*
Programa   : PedidoNac()
Objetivo   : Retornar o número do pedido de nacionalização
Parâmetros : Número da D.I.
Retorno    : Número do pedido de Nacionalização
Autor      : WFS
Data       :
Revisão    :
*/
Static Function PedidoNac(cDI)
Return "DA" + AllTrim(cDI)

/*
Programa   : PrgEntreposto()
Objetivo   : Montar a programação de entregas a partir do processo de entreposto, respeitando a chave de
             comparação inicial.
Parâmetros : Chave que determina qual ordem, pedido e item devem ser considerados para a montagem
             da programação de entregas.
Retorno    :
Autor      : WFS
Data       :
Revisão    :
*/
Static Function PrgEntreposto(cEmbarque, cPLI, cPedido, cUnidReq, cProduto, cPosicao)
Local aOrd:= SaveOrd({"SW3", "SW6", "SW7"})
Local aEntregas:= {}
Local aPedidos:= {}
Local nPos
Local cPedNac, cSI

Begin Sequence

   /* Rastreamento do número do pedido de nacionalização*/
   SW6->(DBSetOrder(1)) //W6_FILIAL+W6_HAWB
   SW7->(DBSetOrder(1)) //W7_FILIAL+W7_HAWB+W7_PGI_NUM+W7_CC+W7_SI_NUM+W7_COD_I
   SW6->(DBSeek(xFilial() + cEmbarque))
   SW7->(DBSeek(xFilial() + cEmbarque))

   While SW7->(!Eof()) .And.;
         SW7->W7_HAWB == cEmbarque

         If AScan(aPedidos, SW7->W7_PO_NUM) == 0
            AAdd(aPedidos, SW7->W7_PO_NUM)
         EndIf

      SW7->(DBSkip())
   EndDo

   nPos:= AScan(aPedidos, cPedido)
   cPedNac:= PedidoNac(SW6->W6_DI_NUM) + "/" + StrZero(nPos, 2)

   SW3->(DBSetOrder(8)) //W3_FILIAL+W3_PO_NUM+W3_POSICAO

   If !SW3->(DBSeek(xFilial() + cPedNac))
      Break
   EndIf

   While SW3->(!Eof()) .And. SW3->W3_PO_NUM == cPedNac

      If SW3->W3_COD_I == cProduto .And. SW3->W3_POSI_DA == cPosicao .And. SW3->W3_PGI_DA == cPLI
         cSI:= SW3->W3_SI_NUM
         Exit
      EndIf

      SW3->(DBSkip())
   EndDo

   aEntregas:= PrgPedido(SW3->(xFilial()) + cPedNac + cUnidReq + cSI + cProduto, cPLI + cPosicao) /* 1 - filial, pedido, unidade requisitante, solicitação de importação (ordem de compra) e produto
                                                                                                     2 - PLI do processo original  e posição do item no processo original*/
End Sequence

RestOrd(aOrd, .T.)
Return AClone(aEntregas)


/*
Programa   : PO420PedOri()
Objetivo   : Ao receber o array com os pedidos impactados pela alteração de uma P.L.I. ou
             de um Embarque/ Desembaraço, essa função verificará se o pedido refere-se a
             um processo de entreposto e retornará o pedido original, para que seja possível
             refazer a programação de entregas a partir da origem.
Parâmetros : Array unidimensional com a chave para posicionamento e verificação do pedido.
             Chave composta por: PEDIDO + POSICAO.
Retorno    : Array com os pedidos válidos.
Autor      : WFS
Data       :
Revisão    :
*/
Function PO420PedOri(aPedidos)
Local nCont
Local aOrd:= SaveOrd("SW3")
Local aRet:= {}
Local cPedido:= ""

Default aPedidos:= {}

Begin Sequence

   SW3->(DBSetOrder(8)) //W3_FILIAL + W3_PO_NUM + W3_POSICAO

   For nCont:= 1 To Len(aPedidos)

      If SW3->(DBSeek(xFilial() + aPedidos[nCont]))

         /* Pedido de nacionalização*/
         If !Empty(SW3->W3_PO_DA)
            cPedido:= SW3->W3_PO_DA
         /* Pedido regular*/
         Else
            cPedido:= SW3->W3_PO_NUM
         EndIf

         /* Inclui o purchase order no array de pedidos válidos*/
         If AScan(aRet, cPedido) == 0
            AAdd(aRet, cPedido)
         EndIf

      EndIf

   Next

End Sequence

RestOrd(aOrd, .T.)
Return AClone(aRet)

/*
Programa   : PLIAutomatica()
Objetivo   : Verificar se é uma P.L.I. automática
Parâmetros : Número da preparação da licença de importação
Retorno    : Lógico - True se é PLI automátca
Autor      : WFS
Data       :
Revisão    :
*/
Static Function PLIAutomatica(cCampo)
Return ( At("*", cCampo )==1 .And. Rat("*", cCampo )==Len(cCampo) )
