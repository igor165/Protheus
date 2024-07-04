#INCLUDE "Average.ch"
/*
Programa  : EICAP110.PRW
Autor     : Jacomo 
Data      : 25/06/2014
Parametros: lEnvio  = se .T. indica se irá enviar o XML, .F. indica que será recebimento
            nOpc    = 3 = Inclusão/Alteração | 5 = exclusão/estorno
            cHawb   = Numero do Pedido/Embarque a ser utilizado
            cFaseAP = referente ao WA_PO_DI, indicando se será antecipado ou fase de desembaraço
            cTipParc
            lJumpVal
            cTipo
            aArray  = se o Array estiver preenchido, realizar o envio apenas o que estiver gravado sendo que:
            	aArray[nPos][1] = Processo (WB_HAWB)
            	aArray[nPos][2] = Tipo do Processo (WB_PO_DI)
            	aArray[nPos][3] = Tipo da Parcela (WB_TIPOREG)
            	aArray[nPos][4] = Fornecedor (WB_FORN)
            	aArray[nPos][5] = Loja (WB_LOJA)
            	aArray[nPos][6] = Recno(SWB->(Recno()) )
            .
            .
            .
            lTitEf - indica se a chamada foi realizada pelo recebimento de importação ou pela
                     rotina de integração de parcelas pendentes, para a geração dos títulos
                     efetivos das parcelas de câmbio com evento 608. Válido para os cenários onde a
                     configuração AvFlags("EAI_PGANT_INV_NF") estiver habilitada 
Uso       : 
Revisão: WFS - quando a tabela recebida em cTabAlias for SWN, a origem será
         o recebimento de importação e apenas para os cenários onde a configuração
         AvFlags("EAI_PGANT_INV_NF") estiver habilitada, devendo ocorrer os tratametos
         com base no evento 608.
         wfs jun/2017 - correção na exclusão da parcela de câmbio da invoice.
         Complementado tratamento do envio da taxa da parcela da Invoice, que passa a considerar
         os parâmetro MV_EIC0013 e MV_DTB_APD, este último através da função FI400DtRefTaxa().       
*/
*-------------------------------------------------------------------- 
Function EICAP110(lEnvio,nOpc,cHawb,cFaseAP,cTipParc,lJumpVal,cTipo,aAltParc,cTabAlias, lTitEf)
*--------------------------------------------------------------------
LOCAL nI
Local lRet:= .T.
Local lAtuStatus:= .F.
DEFAULT lEnvio   := .T.
DEFAULT lJumpVal := .F.
DEFAULT aAltParc :={}
DEFAULT cTabAlias:= 'SWB' //igor chiba 14/08/014
DEFAULT cTipParc := ""
Default lTitEf   := .F. 
PRIVATE aEnvia    := {}
PRIVATE aExclui   := {}
Private nPosEnvia
Private cPO_HAWB  := cHawb
Private cFase     := cFaseAP
Private nTotCC    := 0                                                       
Private cAliax    := cTabAlias
Private lEfetivo

lEfetivo:= lTitEf

IF cAliax == 'SWB'
   ValEnvCBO(cFase,lJumpVal,.F.,cTipo,aAltParc,cTipParc,nOpc)
ELSEIF cAliax == 'TRB'
   IF (nOpc <> 5 .OR. !Empty(GetNumTit())) .AND. !ProcIntegracao(nOpc) //EasyEnvEAI("EICAP110",nOpc)
      lRet:= .F.
   ENDIF
   lAtuStatus:= .T.
ENDIF

lEnvio:= lEnvio .And. (Len(aExclui) > 0 .Or. Len(aEnvia) > 0 )
IF lEnvio
   
   /* Quando a exclusão não for concluída, a inclusão/ alteração não será reenviada */
   aIntegra := AClone(aExclui)
   Begin Sequence
      FOR nI := 1 TO LEN(aExclui) // Faz o Envio das parcelas ja separadas por [Processo,Invoice,Fornecedor e Tipo]
         nPosEnvia := nI
         IF !Empty(GetNumTit()) .AND. !ProcIntegracao(5) //EasyEnvEAI("EICAP110",5)
            lRet:= .F.
            Break
         ENDIF
      NEXT

      aIntegra := AClone(aEnvia)
      FOR nI := 1 TO LEN(aEnvia) // Faz o Envio das parcelas ja separadas por [Processo,Invoice,Fornecedor e Tipo]
         nPosEnvia := nI
         IF (nOpc <> 5 .OR. !Empty(GetNumTit())) .AND. !ProcIntegracao(nOpc) //EasyEnvEAI("EICAP110",nOpc)
            lRet:= .F.
            Break
         ENDIF
      NEXT
   End Sequence
   lAtuStatus:= .T.
ENDIF

/*Atualização de status do processo de embarque/ desembaraço*/
If /*lAtuStatus .And. */ cFase == "D"          //NCF - 26/04/2018 - Sempre atualizar status quando câmbio principal
   AP110AtuStatus(cHawb)
EndIf

Return lRet

*-------------------------------------------------------*
/*======================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
*======================================================*/
*-------------------------------------------------------*
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
*-------------------------------------------------------*
Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.000")
	oEasyIntEAI:oMessage:SetMainAlias("SWB")
	oEasyIntEAI:SetModule("EIC",17)

	// Envio 
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AP110SEND") //ENVIO                               (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AP110RESP") //RESPOSTA SOBRE O ENVIO              (<-Response)
	// Envio 

	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult() 

/* ====================================================*
* Função: AP110SEND(oMessage)
* Objetivo: Envio das parcelas de Cambio
* Obs: 
* =====================================================*/
*------------------------------------------------*
Function AP110SEND(oMessage) 
*------------------------------------------------* 
Local oXml       := EXml():New()
Local oBusiness  := ENode():New()
Local oBusinEvent:= ENode():New() 
Local oIdent     := ENode():New()  
Local oRec       := ENode():New()
Local aOrd       := {}
Local cBanco
Local cAgencia
Local cConta
//Variaveis utilizadas para somatoria de totais ou Datas
Local cEvent := ""
Local nGrossValue   := 0
Local dDueDate      := STOD("  /  /  ")
Local dDtVencimento := STOD("  /  /  ")
Local nTaxa := 0 ,n, i, cAuxCpo
Private oAccountPayable

aOrd := SaveOrd({"SWA","SWB","SW2","EC6","SYF","SW6","SW9"}) 
EC6->(DBSETORDER(1))//EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
SW2->(DBSETORDER(1))//W2_FILIAL+W2_PO_NUM
SYF->(DBSETORDER(1))//YF_FILIAL+YF_MOEDA 
SW6->(DBSETORDER(1))//W6_FILIAL+W6_HAWB
SW9->(DBSETORDER(1))//W9_FILIAL+W9_INVOICE+W9_FORN+W9_FORLOJ+W9_HAWB

//<BusinessEvent>
   IF cAliax == 'SWB'
      (cAliax)->(DBGOTO(aIntegra[nPosEnvia][7][1])) // Posiciona no primeiro registro do conjuto de dados.
   ENDIF

  //Entity e Event
   oBusinEvent:SetField("Entity", "EICAP110")
   cEvent := IF(nEAIEvent <> 5,"upsert","delete")        
   oBusinEvent:SetField("Event" ,cEvent )

  //<Identification>
     oKeyNode:= ENode():New()
     oKeyNode:SetField(EAtt():New("name","Branch"))
     oKeyNode:SetField(ETag():New("",  IF(cAliax=="SWB",(cAliax)->WB_FILIAL , xFilial("SWB") )  ))
     oIdent:SetField(ETag():New("key",oKeyNode))

     oKeyNode:= ENode():New()
     oKeyNode:SetField(EAtt():New("name","Type"))
     oKeyNode:SetField(ETag():New("",(cAliax)->WB_PO_DI))
     oIdent:SetField(ETag():New("key",oKeyNode))

     oKeyNode:= ENode():New()
     oKeyNode:SetField(EAtt():New("name","Process"))
     oKeyNode:SetField(ETag():New("",(cAliax)->WB_HAWB))
     oIdent:SetField(ETag():New("key",oKeyNode))

     oKeyNode:= ENode():New()
     oKeyNode:SetField(EAtt():New("name","Invoice"))
     oKeyNode:SetField(ETag():New("",(cAliax)->WB_INVOICE))
     oIdent:SetField(ETag():New("key",oKeyNode))

     oKeyNode:= ENode():New()
     oKeyNode:SetField(EAtt():New("name","Vendor"))
     oKeyNode:SetField(ETag():New("",(cAliax)->WB_FORN))
     oIdent:SetField(ETag():New("key",oKeyNode))

     oKeyNode:= ENode():New()
     oKeyNode:SetField(EAtt():New("name","Store"))
     oKeyNode:SetField(ETag():New("",(cAliax)->WB_LOJA))
     oIdent:SetField(ETag():New("key",oKeyNode))
     
     //Se vier do Desembaraço e for Frete/Antecipado, não enviar linha, porem se vier da fase pedido, enviar a linha
     IF ((cAliax)->WB_EVENT == "608" .AND. (!EMPTY((cAliax)->WB_CA_DT)) ) .OR. (cAliax)->WB_EVENT == "609"
        oKeyNode:= ENode():New()
        oKeyNode:SetField(EAtt():New("name","Line"))
        oKeyNode:SetField(ETag():New("",(cAliax)->WB_LINHA))
        oIdent:SetField(ETag():New("key",oKeyNode))
     ENDIF

   oBusinEvent:SetField("Identification",oIdent)

   oBusiness:SetField("CompanyId"             ,EICEmpFLogix())
   oBusiness:SetField("CompanyInternalId"     ,EICEmpFLogix())
   oBusiness:SetField("BranchId"              ,EICFilFLogix())
   oBusiness:SetField("batchNumber"           ,"")//Não utilizado
   
   oListSrcDoc := ENode():New()
   oSourcDoc := ENode():New()          //17/10/2016 - Retirado o Left para mandar nro. do processo completo.
   oSourcDoc:SetField("SourceDocument",/*Left(*/(cAliax)->WB_HAWB/*,10)*/ ) //********************LEFT TEMPORARIO - RETIRAR QUANDO O XSD QUE PERMITE TAMANHO LIVRE FOR ATUALIZADO NO DESTINO
   oListSrcDoc:SetField("SourceDocument",oSourcDoc)   
   
   oListOfAccountPayable := ENode():New()
   If cAliax == 'SWB'
      nParcs := Len(aIntegra[nPosEnvia][7])
   Else
      nParcs := 1
   EndIf
   
   For i:= 1 TO nParcs
     If cAliax == 'SWB'
         (cAliax)->(dbGoTo(aIntegra[nPosEnvia][7][i]))
     EndIf

     If(cAliax)->WB_EVENT == "608" .AND. !EMPTY((cAliax)->WB_CA_DT) .And. lEfetivo
        EC6->(DBSeek(xFilial("EC6") + "IMPORT" + AvKey("101", "WB_EVENT")))
     Else
        EC6->(DBSEEK(xFilial("EC6")+"IMPORT"+(cAliax)->WB_EVENT))
     EndIf
         
	  oAccountPayable := ENode():New()
	  oAccountPayable:SetField("InternalId"            ,(cAliax)->(RecNo()))
	  oAccountPayable:SetField("DocumentPrefix"        ,EC6->EC6_PREFIX)

	  If (cAliax)->WB_EVENT == "608"// .AND. !Empty((cAliax)->WB_CA_DT)
         /* A chamada da integração a partir do recebimento de importação será para a geração ou
            estorno do título efetivo, evento 101, onde o número do título de adiantamento
            (evento 608) não deve ser enviado.*/
         If lEfetivo
            oAccountPayable:SetField("DocumentNumber"        ,(cAliax)->WB_NUMDUP)
         Else
            oAccountPayable:SetField("DocumentNumber"        ,(cAliax)->WB_TITADI)
         EndIf
      Else
         oAccountPayable:SetField("DocumentNumber"        ,(cAliax)->WB_NUMDUP)
      EndIf

	  cParcela:= If((cAliax)->WB_EVENT $ "608/609","1",(cAliax)->WB_PARCELA)
	  oAccountPayable:SetField("DocumentParcel"        ,cParcela)
      
	  oAccountPayable:SetField("DocumentTypeCode"      ,EC6->EC6_TPTIT)
	  oAccountPayable:SetField("BlockAmendmentDocument","B")
      
	  oAccountPayable:SetField("ListOfSourceDocument",oListSrcDoc)
      
	  dEmissao := dDataBase
	  If (cAliax)->WB_PO_DI == "A" .AND. SW2->(DBSEEK(xFilial("SW2")+(cAliax)->WB_HAWB))
         //dEmissao := SW2->W2_PO_DT //comentado por wfs
         cAuxCpo:= FI400DtEmAdiCpo()
         dEmissao:= &("(cAliax)->" + SubStr(cAuxCpo, 6, Len(cAuxCpo)))//(cAliax)->WB_DT_DESE //a emissão do adiantamento é a data do desembolso.
      ElseIf (cAliax)->WB_PO_DI == "D" .AND. Left((cAliax)->WB_TIPOREG,1) == '1' .AND. SW9->(DBSEEK(xFilial("SW9")+(cAliax)->WB_INVOICE+(cAliax)->WB_FORN+(cAliax)->WB_LOJA+(cAliax)->WB_HAWB))
         cAuxCpo:= FI400DtEmInvCpo()
         dEmissao := &(cAuxCpo)//SW9->W9_DT_EMIS
      ElseIf (cAliax)->WB_PO_DI == "D" .AND. Left((cAliax)->WB_TIPOREG,1) <> '1' 
         dEmissao := SW6->W6_DT_HAWB
      EndIF
   
      dDueDate := (cAliax)->WB_DT_VEN
     
      If dDueDate < dEmissao
         dDueDate := dEmissao
      EndIf
   
      oAccountPayable:SetField("IssueDate"   ,EasyTimeStamp(dEmissao,.T.,.T.))
      oAccountPayable:SetField("DueDate"     ,EasyTimeStamp(dDueDate,.T.,.T.))
      oAccountPayable:SetField("RealDueDate" ,EasyTimeStamp(DataValida(dDueDate),.T.,.T.))
      oAccountPayable:SetField("VendorCode"  ,(cAliax)->WB_FORN)
      oAccountPayable:SetField("VendorInternalId"  ,(cAliax)->WB_FORN)
      oAccountPayable:SetField("StoreId"     ,(cAliax)->WB_LOJA)
      oAccountPayable:SetField("NetValue"    ,(cAliax)->WB_FOBMOE+(cAliax)->WB_PGTANT)
      oAccountPayable:SetField("GrossValue"  ,(cAliax)->WB_FOBMOE+(cAliax)->WB_PGTANT)
   
      If SYF->(DBSEEK(xFilial("SYF")+(cAliax)->WB_MOEDA)) .AND. EC6->EC6_TXCV = "2"
         cCodERP := SYF->YF_CODCERP
      Else
         cCodERP := SYF->YF_CODVERP
      EndIf

      oAccountPayable:SetField("CurrencyCode",cCodERP)
      oAccountPayable:SetField("CurrencyInternalId",(cAliax)->WB_MOEDA)
   
      If (cAliax)->WB_EVENT $ "608/609" .AND. (!EMPTY((cAliax)->WB_CA_DT))
         nTaxa := (cAliax)->WB_CA_TX //BuscaTaxa((cAliax)->WB_MOEDA,(cAliax)->WB_CA_DT,,.F.,,,EC6->EC6_TXCV)
      ElseIf (cAliax)->WB_EVENT == "101" .AND. AvFlags("EAI_PGANT_INV_NF") .AND. (cAliax)->WB_PO_DI == "D" .AND.;
             ExisteNfe((cAliax)->WB_HAWB) //SW6->(DBSEEK(xFilial("SW6")+(cAliax)->WB_HAWB)) .AND. (!EMPTY(SW6->W6_DT_NF))
         SW9->(DBSEEK(xFilial("SW9")+(cAliax)->WB_INVOICE+(cAliax)->WB_FORN+(cAliax)->WB_LOJA+(cAliax)->WB_HAWB ))
         nTaxa := SW9->W9_TX_FOB
      Else
         If EasyGParam("MV_EIC0013",, .F.)         
            nTaxa := BuscaTaxa((cAliax)->WB_MOEDA, dEmissao,,.F.,,,EC6->EC6_TXCV)
         Else
            nTaxa := BuscaTaxa((cAliax)->WB_MOEDA, FI400DTRefTaxa(),,.F.,,,EC6->EC6_TXCV)
         EndIf
      EndIf

      oAccountPayable:SetField("CurrencyRate",nTaxa)
      
      oAppDistri := ENode():New()
      If (cAliax)->WB_EVENT $ "608/609" .AND. (!EMPTY((cAliax)->WB_CA_DT))//(cAliax)->WB_EVENT $ "608/609" .OR. (alltrim(UPPER((cAliax)->WB_INVOICE)) $ "FRETE/SEGURO")
         oApportionment:= ENode():New()
         oApportionment:SetField("CostCenterInternalId",EC6->EC6_CCUSTO) //CostCenterCode
         oApportionment:SetField("Value"         ,(cAliax)->WB_FOBMOE+(cAliax)->WB_PGTANT) 
         oAppDistri:SetField("Apportionment",oApportionment)
      Else //Parcelas da invoice do desembaraço
         If Left((cAliax)->WB_TIPOREG,1) == "1"
            aValorCC := LC500RatCC(xFilial("SW3"),(cAliax)->WB_HAWB,(cAliax)->WB_FORN,(cAliax)->WB_INVOICE,AVSX3('WB_FOBMOE',4),           ,        ,@nTotCC,"SW8",(cAliax)->WB_LOJA) 
            aRatCC   := LC500RatCC(xFilial("SW3"),(cAliax)->WB_HAWB,(cAliax)->WB_FORN,(cAliax)->WB_INVOICE,AVSX3('WB_FOBMOE',4),(cAliax)->WB_FOBMOE+(cAliax)->WB_PGTANT,aValorCC,nTotCC ,"SW8",(cAliax)->WB_LOJA) 
         Else
            aValorCC := LC500RatCC(xFilial("SW3"),(cAliax)->WB_HAWB,                 ,                    ,AVSX3('WB_FOBMOE',4),           ,        ,@nTotCC,"SW8",                 ) 
            aRatCC   := LC500RatCC(xFilial("SW3"),(cAliax)->WB_HAWB,                 ,                    ,AVSX3('WB_FOBMOE',4),(cAliax)->WB_FOBMOE+(cAliax)->WB_PGTANT,aValorCC,nTotCC ,"SW8",                 ) 
         EndIf
         
         For n := 1 TO LEN(aRatCC)
             oApportionment:= ENode():New()
             oApportionment:SetField("CostCenterInternalId",aRatCC[n][1]) //CostCenterCode
             oApportionment:SetField("Value"         ,aRatCC[n][2]) 
             oAppDistri:SetField("Apportionment",oApportionment)
         Next n
      EndIf

      oAccountPayable:SetField("ApportionmentDistribution",oAppDistri)

	  If (cAliax)->WB_EVENT == "608" .AND. !EMPTY((cAliax)->WB_CA_DT) .And. !lEfetivo .OR.;
	      cAliax <> "SWB"
      
         oBank:=ENode():New()      
         
         //complemento dos dados bancários
         cBanco:= (cAliax)->WB_BANCO
         cAgencia:= (cAliax)->WB_AGENCIA
         cConta:= (cAliax)->WB_CONTA
       
         SA6->(DBSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
         If SA6->(DBSeek(xFilial() + (cAliax)->WB_BANCO + (cAliax)->WB_AGENCIA + (cAliax)->WB_CONTA))
            If !Empty(SA6->A6_DVAGE)
               cAgencia:= AllTrim(SA6->A6_AGENCIA) + "-" + SA6->A6_DVAGE 
            EndIf
            If !Empty(SA6->A6_DVCTA)
               cConta:= AllTrim(SA6->A6_NUMCON) + "-" + SA6->A6_DVCTA 
            EndIf
         EndIf

         oBank:SetField("BankCode"   , cBanco)
         oBank:SetField("BankAgency" , cAgencia)      
         oBank:SetField("BankAccount", cConta)

         oAccountPayable:SetField("Bank"      ,oBank)
      EndIf     

      oAccountPayable:SetField("Observation",EC6->EC6_DESC)
      oAccountPayable:SetField("Origin"     ,"SIGAEIC")
             
      If EC6->(FIELDPOS("EC6_NATFIN")) <> 0 .AND. !EMPTY(EC6->EC6_NATFIN)
         oAccountPayable:SetField("FinancialNatureInternalId" ,EC6->EC6_NATFIN)
      EndIf

      If EasyEntryPoint("EICAP110")
         ExecBlock("EICAP110", .f., .f., "ACCOUNTPAYABLE")
      Endif

      oListOfAccountPayable:SetField("AccountPayableDocument", oAccountPayable)
   Next i

   oBusiness:SetField("ListOfAccountPayableDocument", oListOfAccountPayable)
   
   oRec:SetField("BusinessEvent"  ,oBusinEvent)
   oRec:SetField("BusinessContent",oBusiness)
   oXml:AddRec(oRec)
   
RestOrd(aOrd,.t.)

Return oXml


/* ====================================================*\
* Função: AP110RESP(oMessage)                          *
* Objetivo: Resposta do Envio                          *
* Obs:                                                 *
\* ====================================================*/
*----------------------------------------------*
Function AP110RESP(oMessage)
*----------------------------------------------*
Local oRetCont       := oMessage:GetRetContent()
Local oBusinessEvent := oMessage:GetEvtContent()
Local cFilWB:=cInv:=cHawb:=cLinha:=cForn:=cLoja:=cTipo:=""
Local i, aArray, oList, nSWBRec

cEvent:= EasyGetXMLinfo(,oBusinessEvent, "_Event" )//Evento do XML
If IsCpoInXML(oRetCont, "_ListOfInternalIdDocument") .AND. IsCpoInXML(oRetCont:_ListOfInternalIdDocument, "_InternalIdDocument")
   
   oList:= oRetCont:_ListOfInternalIdDocument:_InternalIdDocument
   
   If ValType(oList) <> "A"
      aArray := {oList}
   Else
      aArray := oList
   EndIf
   
   For i := 1 To len(aArray)
      nSWBRec    := val(EasyGetXMLinfo(,aArray[i],"_Origin"))
      cDocNumber := EasyGetXMLinfo(,aArray[i],"_destination")
      
      (cAliax)->(DBGoTo(nSWBRec))
      
      If cAliax == "SWB"
         SWB->(RecLock("SWB",.F.))
      EndIf
      
      If UPPER(cEvent) == "UPSERT"
         If (cAliax)->WB_EVENT <> "608"
            (cAliax)->WB_NUMDUP := cDocNumber               
         
         ElseIf (cAliax)->WB_EVENT == "608" .And. lEfetivo
            /* Quando a inclusão for executada após a confirmação da integração da nota fiscal, 
               significa que refere-se ao cenário onde a configuração AvFlags("EAI_PGANT_INV_NF")
               está habilitada. Neste cenário, o número do título deve ser gravado no campo WB_NUMDUP. */
            (cAliax)->WB_NUMDUP := cDocNumber
         Else
            (cAliax)->WB_TITADI := cDocNumber
         EndIf
      Else //Evento == "Delete"
         If (cAliax)->WB_EVENT <> "608"
            (cAliax)->WB_NUMDUP := ""
         ElseIf (cAliax)->WB_EVENT == "608" .And. lEfetivo
            /* Quando a exclusão for executada após a confirmação da integração da nota fiscal, 
               significa que refere-se ao cenário onde a configuração AvFlags("EAI_PGANT_INV_NF")
               está habilitada. Neste cenário, o número do título deve ser apagado do campo WB_NUMDUP. */
            (cAliax)->WB_NUMDUP := ""
         Else
            (cAliax)->WB_TITADI := ""
         EndIf
      EndIf
      
      If cAliax == "SWB"
         SWB->(MSUNLOCK())
      EndIf
	  
   Next i
EndIf

Return oMessage

/* ====================================================*\
* Função: ValEnvCBO(oMessage)                          *
* Objetivo: Resposta do Envio                          *
* Obs:                                                 *
* Parametros: cFase    = WB_PO_DI                      *
*             lJumpVal = Pula Validação de alteração   *
*             lJustVal = Só Valid (Chamada na EICDI500)*
*             aAltParc = array com as invoices das     *
*parcelas que foram alteradas no eicap100              *
*             cParAlt = *
* Revisão: WFS - abr/2015
           Com os títulos em aberto contabilizados,
           o Logix bloqueia a alteração. Implentado o
           envio da exclusão para toda a alteração
           existente.
\* ====================================================*/
*------------------------------------------------*
Function ValEnvCBO(cFase,lJumpVal,lJustVal,cTipo,aAltParc,cParAlt,nOpc)
*------------------------------------------------*
Local aArray     := {}
Local i, j
Local lAlterou   := .F.
Local aTodosDel  := {}  
//local lRet       := .T.          
Private aAltInvoice

Default cParAlt  := "" //igor chiba tipos de parcelas que sofreram alteracao
Default lJustVal := .F. 
Default lJumpVal := .F.                                  
Default aAltParc :={}
Default nOpc:= 0

   If Type("aDelCambio") == "U"
      aDelCambio:= {}
   EndIf
   /****************
    Itens Alterados
    ****************/
   SW6->(DBSETORDER(1))
   SWB->(DBSETORDER(1))
   IF cFase == "D" .AND. !lJumpVal

      IF DIAlterou(M->W6_HAWB) //FI400DIAlterou(M->W6_HAWB,"A")
         If ValType(aAltInvoice) == "A"
            For i := 1 To Len(aAltInvoice)
               aAdd(aAltParc, {Left(aAltInvoice[i],Len(SWB->WB_INVOICE+SWB->WB_FORN)), {}})
            Next i
         EndIf
         lAlterou := .T.
         cParAlt += '1'
      ENDIF
      IF (M->W6_FREMOED <> SW6->W6_FREMOED) .OR. (M->W6_VLFRECC <> SW6->W6_VLFRECC) .OR.;
         (M->W6_TX_FRET <> SW6->W6_TX_FRET) .OR. (M->W6_CONDP_F <> SW6->W6_CONDP_F) .OR.;
         (M->W6_DIASP_F <> SW6->W6_DIASP_F) .OR. (M->W6_VENCFRE <> SW6->W6_VENCFRE) .OR.;
         (M->W6_FORNECF <> SW6->W6_FORNECF) .OR. (M->W6_LOJAF <> SW6->W6_LOJAF)
         
         lAlterou := .T.
         cParAlt += 'A' //FRETE
      ENDIF
   
      IF (M->W6_SEGMOED <> SW6->W6_SEGMOED ) .OR. (M->W6_VL_USSE <> SW6->W6_VL_USSE ) .OR.;
         (M->W6_TX_SEG  <> SW6->W6_TX_SEG  ) .OR. (M->W6_DIASP_S <> SW6->W6_DIASP_S ) .OR.;
         (M->W6_CONDP_S <> SW6->W6_CONDP_S ) .OR. (M->W6_VENCSEG <> SW6->W6_VENCSEG ) .OR.;
         (M->W6_FORNECS <> SW6->W6_FORNECS ) .OR. (M->W6_LOJAS   <> SW6->W6_LOJAS )
         
         lAlterou := .T. 
         cParAlt  += 'B'//SEGURO
      ENDIF
      IF lJustVal
         Return cParAlt//lAlterou
      ENDIF

   ENDIF
   
   /* Envio apenas das parcelas de câmbio que foram alteradas na
      rotina de manutenção.
      Verifica se existem invoices com parcelas alteradas. */
   If lJumpVal .And. Len(aAltParc) > 0 .And. Len(aAltParc[1]) > 0 .And. ValType(aAltParc[1][2]) == "A" .And. Len(aAltParc[1][2]) > 0

      For i:= 1 To Len(aAltParc)
         For j:= 1 To Len(aAltParc[i][2])

            /* Carga das variáveis aEnvie e aExclui para processamento da exclusão e inclusão das parcelas. */
            SWB->(DBGoTo(aAltParc[i][2][j]))

            nPos:= AScan(aEnvia,{|x| x[1] == SWB->WB_HAWB   ;
                               .And. x[2] == SWB->WB_PO_DI  ;
                               .And. x[3] == Left(SWB->WB_TIPOREG,1);
                               .And. x[4] == SWB->WB_INVOICE;
                               .And. x[5] == SWB->WB_FORN   ;
                               .And. x[6] == If(EICLoja(), SWB->WB_LOJA, "") }) 

            If nPos == 0
               AAdd(aEnvia, {SWB->WB_HAWB, SWB->WB_PO_DI, Left(SWB->WB_TIPOREG,1), SWB->WB_INVOICE, SWB->WB_FORN, If(EICLoja(), SWB->WB_LOJA, ""), {SWB->(RecNo())} })

               //Na alteração, todos os títulos serão excluídos e reenviados.
               If !Empty(SWB->WB_NUMDUP)
                  AAdd(aExclui, {SWB->WB_HAWB, SWB->WB_PO_DI, Left(SWB->WB_TIPOREG,1), SWB->WB_INVOICE, SWB->WB_FORN, If(EICLoja(), SWB->WB_LOJA, ""), {SWB->(RecNo())}})
               EndIf
            Else
               AAdd(aEnvia[nPos][7], SWB->(RecNo()))
               //Na alteração, todos os títulos serão excluídos e reenviados.
               If !Empty(SWB->WB_NUMDUP)
                  AAdd(aExclui[nPos][7], SWB->(RecNo()))
               EndIf
            EndIf
         Next
      Next

   Else
      IF lAlterou .OR. cFase $ "A/F/C" .OR. lJumpVal
         SWB->(DBSEEK(xFilial("SWB")+cPO_Hawb+cFase))
         DO WHILE SWB->(!EOF()) .AND. SWB->WB_HAWB == cPO_Hawb                                                        

            EC6->(DbSETORDER(1))
            EC6->(DbSeek(xFilial("EC6")+"IMPORT"+SWB->WB_EVENT)) 
            IF VALTYPE(cTipo) <> "U" .AND. Left(SWB->WB_TIPOREG,1) <> cTipo .OR. Left(SWB->WB_TIPOREG,1) == "P" //Compensação
               SWB->(DBSKIP())
               LOOP
            ENDIF
            IF SWB->WB_HAWB <> cPO_Hawb .OR. SWB->WB_PO_DI <> cFase
               SWB->(DBSKIP())
               LOOP
            ENDIF
            IF cFase $ "A/F/C" .AND. ( (!EMPTY(SWB->WB_CA_DT)  .AND. !EMPTY(SWB->WB_NUMDUP) );
                            .OR.    ( EMPTY(SWB->WB_CA_DT)  .AND.  EMPTY(SWB->WB_NUMDUP) ) )
               SWB->(DBSKIP())
               LOOP
            ENDIF

            /* Ao executar a rotina de integração de títulos pendentes, enviar apenas os títulos que,
               de fato, não foram integrados ou atualizados no ERP. */
            If !IntegPendente(SWB->WB_HAWB, .F., nOpc) .And. !lAlterou .And. Len(aAltParc) == 0 //wfs jun/2017 - acrescentado parâmetro da operação realizada
               SWB->(DBSkip())
               Loop
            EndIf

            IF SWB->WB_EVENT == "608" .OR. SWB->WB_EVENT == "609" .AND. cFase $ "A/F/C"
               //IGOR CHIBA SE SEGURO B OU FRETE A FORAM ALTERADAS no processo ou Uma parcela no cambio foi alterada
               IF Left(SWB->WB_TIPOREG,1) $ cParAlt .OR.  ASCAN(aAltParc, {|x| x[1] == SWB->WB_INVOICE+SWB->WB_FORN}) <> 0 
                  AADD(aEnvia,{SWB->WB_HAWB,SWB->WB_PO_DI,Left(SWB->WB_TIPOREG,1),SWB->WB_INVOICE,SWB->WB_FORN,IF(EICLOJA(),SWB->WB_LOJA,""),{SWB->(RECNO())} })
               ENDIF
            //Caso for uma parecela de Invoice, separar por [Processo,Invoice,Fornecedor e Tipo]
            ELSEIF (ASCAN(aAltParc, {|x| x[1] == SWB->WB_INVOICE+SWB->WB_FORN}) <> 0 .OR.  (Left(SWB->WB_TIPOREG,1) <> "1" .OR. lJumpVal) .AND. Left(SWB->WB_TIPOREG,1) $ cParAlt) .And. (Empty(SWB->WB_SEQBX) .And. Empty(SWB->WB_PGTANT))//wfs - enviar apenas títulos não baixados na alteração

               nPos:= AScan(aEnvia,{|x| x[1] == SWB->WB_HAWB   ; //PROCESSO
                                  .AND. x[2] == SWB->WB_PO_DI  ; //TIPO DO PROCESSO
                                  .AND. x[3] == Left(SWB->WB_TIPOREG,1); //TIPO DA PARCELA
                                  .AND. x[4] == SWB->WB_INVOICE; //INVOICE
                                  .AND. x[5] == SWB->WB_FORN   ; //FORNECEDOR
                                  .AND. x[6] == IF(EICLOJA(),SWB->WB_LOJA,"") }) 

               If nPos == 0
                  AADD(aEnvia,{SWB->WB_HAWB,SWB->WB_PO_DI,Left(SWB->WB_TIPOREG,1),SWB->WB_INVOICE,SWB->WB_FORN,IF(EICLOJA(),SWB->WB_LOJA,""),{SWB->(RECNO())} })
                  //Na alteração, todos os títulos serão excluídos e reenviados.
                  If !Empty(SWB->WB_NUMDUP)
                     AAdd(aExclui, {SWB->WB_HAWB, SWB->WB_PO_DI, Left(SWB->WB_TIPOREG,1), SWB->WB_INVOICE, SWB->WB_FORN, If(EICLoja(), SWB->WB_LOJA, ""), {SWB->(RecNo())}})
                  EndIf
               ELSE // Caso ja esteja gravado no aEnvia a separção por [Processo,Invoice,Fornecedor e Tipo], adiciona o RecNo no array do aEnvia[Npos][7]
                  IF ASCAN(aEnvia[nPos][7],{|Y| Y == SWB->(RECNO()) }) == 0   
                     AADD(aEnvia[nPos][7],SWB->(RECNO()))
                     //Na alteração, todos os títulos serão excluídos e reenviados.
                     If !Empty(SWB->WB_NUMDUP)
                        AAdd(aExclui[nPos][7], SWB->(RECNO()))
                     EndIf
                  ENDIF
               ENDIF
               If nOpc == 5 //Parcelas de câmbio pendentes de exclusão, caso os títulos no ERP sejam excluídos
                  AAdd(aDelCambio, SWB->(RecNo()))
               EndIf
            EndIf
         
            SWB->(DBSKIP())
         ENDDO
      ENDIF
   EndIf

   
   /****************
    Itens Excluídos
    ****************/
   For i := 1 To Len(aDeletados)
      If ValType(aDeletados[i]) == "A" .And. aDeletados[i][1] == "SWB"
         AAdd(aTodosDel, aDeletados[i][2])
      EndIf
   Next 

   /* wfs
      array adeletados está com a estrutura diferente, dependendo da origem da chamada*/
   For i:= 1 To Len(aEAIDeletados)
      If aEAIDeletados[i][1] == "SWB"
         AAdd(aTodosDel, aEAIDeletados[i][2])
      EndIf
   Next

   For i:= 1 To Len(aTodosDel)
      /* Adicionará para exclusão os recno's que não foram adicionados na alteração */
      SWB->(DBGoTo(aTodosDel[i]))
      If Left(SWB->WB_TIPOREG,1) <> "P" .Or. lJumpVal //quando array adeletados, não havia lJumpVal; acrescentado para aEAIDeletados; observar
         nPos:= AScan(aExclui, {|x| x[1] == SWB->WB_HAWB .And.    ;
                                    x[2] == SWB->WB_PO_DI .And.   ;
                                    x[3] == Left(SWB->WB_TIPOREG,1) .And. ;
                                    x[4] == SWB->WB_INVOICE .And. ;
                                    x[5] == SWB->WB_FORN .And.    ;
                                    x[6] == If(EICLoja(), SWB->WB_LOJA, "")})

         If nPos > 0 .And. AScan(aExclui[nPos][7], {|x| x == SWB->(RecNo())}) == 0
            AAdd(aExclui[nPos][7], SWB->(RecNo()))
         Else
            AAdd(aExclui, {SWB->WB_HAWB, SWB->WB_PO_DI, Left(SWB->WB_TIPOREG,1), SWB->WB_INVOICE, SWB->WB_FORN, If(EICLoja(), SWB->WB_LOJA, ""), {SWB->(RecNo())}})
         EndIf
      EndIf
   Next

RETURN cParAlt


*--------------------------------------------------*
STATIC FUNCTION DIAlterou(cHAWB)
*--------------------------------------------------*
LOCAL nAlias:=SELECT(), nInd6:=SW6->(INDEXORD()), nInd9:=SW9->(INDEXORD())
LOCAL nInd7:=SW7->(INDEXORD())
LOCAL ldataEMB := !EMPTY(GetNewPar("MV_DTB_APD",""))
LOCAL lSW9 := .F.
LOCAL dDtEmbG := CTOD("")
LOCAL dDtEmbM := CTOD("")
LOCAL nIndiceRecSWB
LOCAL aOrdE2 := {}
Local aOrdSW9 := {} //MCF - 21/03/2017  
PRIVATE lRETURN:= .F.
Private dDtEmis := Iif(Empty(EasyGParam("MV_DTEMIS",,"SW9->W9_DT_EMIS")),"SW9->W9_DT_EMIS",EasyGParam("MV_DTEMIS",,"SW9->W9_DT_EMIS"))
dDtEmis := Iif(Empty(dDtEmis),"SW9->W9_DT_EMIS",dDtEmis) 
aPos            := {}
aAltInvoice     := {}                // Controla se vai deletar e gerar os Titulos da Invoice
lAltodasInvoice := .F.           // Controla se vai deletar e gerar os Titulos de todas as Invoices
lAltInvoice     :=.F.                                                                              
  
   SW6->(DBSETORDER(1))
   SW6->(DBSEEK(xFilial("SW6")+cHAWB))
   
   aOrdSW9 := SaveOrd({"SW9"}) //MCF - 21/03/2017
   
   Work_SW9->(DBGOTOP())
   Do While !Work_SW9->(EOF())
      IF EMPTY(Work_SW9->WK_RECNO)// Invoices incluidas
         AADD(aAltInvoice, Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+IF(EICLOJA(),Work_SW9->W9_FORLOJ,"") )
         Work_SW9->(dbSkip())
         LOOP
      ENDIF

      SW9->(DBGOTO(WORK_SW9->WK_RECNO))

      IF DI500RetVal("TOT_INV", "TAB", .T.) # DI500RetVal("TOT_INV", "WORK", .T. ).OR.;  // EOB - 28/05/08 - chamada da função DI500RetVal
         SW9->W9_COND_PA+STR(SW9->W9_DIAS_PA,3) # WORK_SW9->W9_COND_PA+STR(WORK_SW9->W9_DIAS_PA,3)  .OR.;
         SW9->W9_FREINC  # WORK_SW9->W9_FREINC

         AADD(aAltInvoice, Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+IF(EICLOJA(),Work_SW9->W9_FORLOJ,"") )
      ENDIF
              
      Work_SW9->(dbSkip())
   EndDo
   
   IF !EMPTY(aAltInvoice)
      lRETURN:= .T.
   ENDIF
   
   IF ASCAN(aDeletados , {|D| D[1] = "SW9" }  ) # 0 .OR. ASCAN(aDeletados , {|D| D[1] = "EZZ" }  ) # 0
      lRETURN:= .T.
   ENDIF
   
   IF !lDataEMB//Tratamento do parâmetro MV_DTB_APD
      cDatEmb := "SW6->W6_DT_EMB"
   ELSE                                                                                                          
      cDatEmb := ALLTRIM(GetNewPar("MV_DTB_APD","SW6->W6_DT_EMB"))
   ENDIF
   
   if "W6_DT_EMB" $ cDatEmb
      if EMPTY(&cDatEmb)
         cDatEmb := "SW6->W6_DT_ETD" // NCF 13/05/09  - Pega a data ETD se a data de Embarque não
      EndIf
   EndIf
   
   If Left(cDatEmb,5) == "SW6->"  //Caso o conteúdo do parâmetro possuir o Alias do Campo "SW6->"
      dDtEmbG:= &(cDatEmb)
      dDtEmbM:= &("M->" + Right(cDatEmb,Len(cDatEmb)-5))
   ElseIf Left(cDatEmb,3) == "W6_" // Ou só o campo    
      dDtEmbG := &("SW6->" + cDatEmb )
      dDtEmbM := &("M->" + cDatEmb )
   Else
      lSW9 := .T.
   EndIf
   
   Work_SW9->(DbGoTop())
   
   Begin Sequence
   
      //Se o campo do parametro for da tabela SW9, verifica-se invoice por invoice até achar uma alteração
      SW9->(DbSetOrder(3))
      SW9->(DBSEEK(xFilial("SW9")+cHAWB))
      Do While !Work_SW9->(EOF()) .And. lSW9
         Do WHILE SW9->W9_HAWB == cHAWB .AND. SW9->W9_INVOICE = Work_SW9->W9_INVOICE
            
            If Left(cDatEmb,5) == "SW9->" //Caso o conteúdo do parâmetro possuir o Alias do Campo "SW6->"
               dDtEmbG := &(cDatEmb)
               dDtEmbM := &("Work_SW9->" + Right(cDatEmb,Len(cDatEmb)-5))
            ElseIf Left(cDatEmb,3) == "W9_" //Ou só o campo
               dDtEmbG := &("SW9->" + cDatEmb )
               dDtEmbM := &("Work_SW9->" + cDatEmb )
            EndIf
		 
            IF dDtEmbG # dDtEmbM
               //** BHF - 11/12/08 -> Verificação para alteração das parcelas de cambio.
		       nIndiceRecSWB := SaveOrd("SWB")
   	 	       
      	 	   SWB->(dbSetOrder(1))
       	       If SWB->(dbSeek(xFilial("SWB")+SW6->W6_HAWB+'D'))
                  While !SWB->(EOF()) .And. (SWB->WB_HAWB == SW6->W6_HAWB)
                     If !Empty(SWB->WB_CA_DT)
                        lAltodasInvoice:=.F.
                        Exit
                     Else
                        lAltodasInvoice:=.T.
	                 EndIf
	              
	                 SWB->(dbSkip())
      	          EndDo
               EndIf
			
               RestOrd(nIndiceRecSWB,.T.)
			
               lRETURN:= .T.       
               Break
            ENDIF
		 
            SW9->(DbSkip())
         EndDo
	  
         Work_SW9->(DbSkip())
      EndDo
   
   End Sequence
   
   SW9->(DbSetOrder(1))
   
   If EMPTY(dDtEmbG)
      dDtEmbG  := SW6->W6_DT_EMB
      dDtEmbM  := M->W6_DT_EMB
      IF EMPTY(dDtEmbG)
   	     dDtEmbG  := SW6->W6_DT_ETA
         dDtEmbM  := M->W6_DT_ETA
   	  ENDIF
   EndIf
   
   If dDtEmbG # dDtEmbM
      nIndiceRecSWB := SaveOrd("SWB")
      
      SWB->(DbSetOrder(1))
      If SWB->(dbSeek(xFilial("SWB")+SW6->W6_HAWB+'D'))
         Do While !SWB->(EOF()) .And. SWB->WB_HAWB == SW6->W6_HAWB
            If !Empty(SWB->WB_CA_DT)
               lAltodasInvoice:=.F.
               Exit
            Else
               lAltodasInvoice:=.T.
	        EndIf
	        
	        SWB->(dbSkip())
         EndDo
      EndIf
	  
      RestOrd(nIndiceRecSWB,.T.)
      lRETURN:= .T.
   EndIf
   
   SWB->(DBSETORDER(1))
   SW9->(DBSetOrder(3))
   IF SW9->( DBSeek(xFilial("SW9")+SW6->W6_HAWB) )  .And.  !SWB->(dbSeek(xFilial("SWB")+SW6->W6_HAWB))
      lAltodasInvoice:=.T.
      lRETURN:= .T.
   ENDIF
   
   RestOrd(aOrdSW9, .T.) //MCF - 21/03/2017
   
SW6->(DBSETORDER(nInd6))
SW7->(DBSETORDER(nInd7))
SELECT(nAlias)

RETURN lRETURN

Static Function GetNumTit()
Local cNumTit
Local nRecWB := (cAliax)->(RecNo())

If cAliax == 'SWB'
   (cAliax)->(DBGOTO(aIntegra[nPosEnvia][7][1]))
EndIf

If (cAliax)->WB_EVENT == "608" .AND. cFase == "D"
   If lEfetivo
      cNumTit:= (cAliax)->WB_NUMDUP
   Else
      cNumTit:= (cAliax)->WB_TITADI
   EndIf
Else
   cNumTit:= (cAliax)->WB_NUMDUP
EndIf
(cAliax)->(DBGOTO(nRecWB))
Return cNumTit


/*
Funcao      : ProcIntegracao
Parâmetros  : nOpc - operação (inclusão/ alteração/ exclusão)
Objetivos   : Executar a integração com o MsAguarde
Retorno     : Lógico: integrado/ não integrado
Autor       : WFS
Data 	     : 01/2015
Obs         :
Revisão     :
*/
Static Function ProcIntegracao(nOpc)
Local lRet:= .F.
   MsAguarde({|| lRet:= EasyEnvEAI("EICAP110", nOpc)}, "Integração EAI - Título financeiro. Aguarde...") //"Integração EAI - Título Financeiro. Aguarde..."
Return lRet

/*
Funcao      : AP110AtuStatus
Parâmetros  : cHawb - número do processo de embarque/ desembaraço
              lAtualizaProc - parâmetro lógico que indica se a função deve atualizar o
              status do processo (.T.) ou apenas retornar o status atual (.F.). 
Objetivos   : Atualização do status do processo, referente as pendências de integração com o financeiro.
Autor       : WFS
Data 	     : 01/2015
Obs         :
Revisão     :
*/

Function AP110AtuStatus(cHawb, lAtualizaProc)
Local aOrd:= SaveOrd({"SW6", "SWB"})
Local cStatus:= "1"
Local cEventos:= ""
Local lNaoIntegrou:= .F.
Default lAtualizaProc:= .T.

Begin Sequence

   SW6->(DBSetOrder(1)) //W6_FILIAL+W6_HAWB
   SWB->(DBSetOrder(1)) //WB_FILIAL+WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA

   SW6->(DBSeek(xFilial() + cHawb))
   SWB->(DBSeek(xFilial() + cHawb))

   /* Verificação aplicável para os eventos contábeis referentes as parcelas de 
      câmbio da invoice (101 e 608), frete (102) e seguro (103). */
   cEventos:= "101/102/103/608"
   While SWB->(!Eof()) .And.;
         SWB->(WB_FILIAL + WB_HAWB) == SWB->(xFilial()) + cHawb

      If !(SWB->WB_EVENT $ cEventos)
         SWB->(DBSkip())
         Loop
      EndIf
   
      /* trecho subsituído pela função IntegPendente()
      If ExisteNfe(cHawb)
         // Retorno do status quando houver nota fiscal para o processo. 
         lNaoIntegrou:= Pend_PosNF()
      Else
         // Retorno do status quando NÃO houver nota fiscal para o processo. 
         lNaoIntegrou:= Pend_PreNF()
      EndIf */

      lNaoIntegrou:= IntegPendente(cHawb)

      /* Se foi encontrada alguma pendência de integração, interrompe a verificação.*/ 
      If lNaoIntegrou
         Break
      EndIf

      SWB->(DBSkip())
   EndDo

End Sequence

If lNaoIntegrou .Or. (Type("lTitEAI_OK") <> "U" .And. !lTitEAI_OK)
   cStatus:= "2"
EndIf

/* Atualização do status no processo de embarque/ desembaraço. */
If lAtualizaProc
    /*
    If SW6->(IsLocked())
        SW6->W6_TITOK:= cStatus
    Else
        SW6->(RecLock("SW6", .F.))
        SW6->W6_TITOK:= cStatus
        SW6->(MsUnlock())
    EndIf
    */
    If !SW6->(EOF())

        If !SW6->(IsLocked())
            SW6->(RecLock("SW6", .F.))
        EndIf

        SW6->W6_TITOK:= cStatus
        SW6->(MsUnlock())
        
	ElseIf IsMemVar("W6_TITOK")
		M->W6_TITOK:= cStatus
    
    EndIf
EndIf

RestOrd(aOrd, .T.)
Return cStatus

/*
Funcao      : Pend_PosNF
Parâmetros  : lValidaBaixa - indica se será verificada a pendência de baixa do título
Retorno     : Lógico - indica se a parcela está pendente (.T.) de integração  
Objetivos   : Verificar se existe parcela de câmbio pendente de integração
              após a geração da nota fiscal.
Autor       : WFS
Data        : 01/2015
Obs         : A tabela SWB deve estar posicionada
Revisão     :
*/
Static Function Pend_PosNF(lValidaBaixa)
Local lRet:= .F.
Default lValidaBaixa:= .T.

Begin Sequence

   If AvFlags("EAI_PGANT_INV_NF")

      If Empty(SWB->WB_NUMDUP)
         /* Pendende de envio da integração do título e da compensação com o adiantamento quando o evento for 608. */
         lRet:= .T.
         Break
      EndIf
         
      If SWB->WB_EVENT == "608" .And. Empty(SWB->WB_SEQBX) .And. lValidaBaixa
         /* Pendende de envio da compensação. */
         lRet:= .T.
         Break
      EndIf
   EndIf

   Do Case

      Case SWB->WB_EVENT == "101" //Invoice
         /* Cenário ocorrerá apenas quando o AvFlags("EAI_PGANT_INV_NF") estiver habilitado e
            apenas para o evento 101. Para frete (102) e seguro (103) as integrações serão realizadas
            antes da geração da nota fiscal.*/
         If Empty(SWB->WB_NUMDUP)
            /* Pendende de envio da integração do título. */
            lRet:= .T.
            Break
         EndIf

      //Case SWB->WB_EVENT == "102" //Frete
      //Case SWB->WB_EVENT == "103" //Seguro

      Case SWB->WB_EVENT == "608" //Invoice
         If Empty(SWB->WB_NUMDUP) .Or. (Empty(SWB->WB_SEQBX) .And. lValidaBaixa)
            /* Pendende de envio da integração do título e/ ou da compensação com o adiantamento. */
            lRet:= .T.
            Break
         EndIf
         
      OtherWise
         lRet:= .F.
   End Case

End Sequence

Return lRet

/*
Funcao      : Pend_PreNF
Parâmetros  : lValidaBaixa - indica se será verificada a pendência de baixa do título
Retorno     : Lógico - indica se a parcela está pendente (.T.) de integração
Objetivos   : Verificar se existe parcela de câmbio pendente de integração
              antes da geração da nota fiscal.
Autor       : WFS
Data        : 01/2015
Obs         : A tabela SWB deve estar posicionada
Revisão     :
*/
Static Function Pend_PreNF(lValidaBaixa)
Local lRet:= .F.
Default lValidaBaixa:= .T.

Begin Sequence

   Do Case

      Case SWB->WB_EVENT == "101" .And. SWB->WB_PO_DI == "D"  //NCF - 26/04/2018 - Verificar somente câmbio principal não antecipado  //Invoice
         If AvFlags("EAI_PGANT_INV_NF")
            If !Empty(SWB->WB_NUMDUP)
               /* Pendende de estorno do título. */
               lRet:= .T.
               Break
            EndIf
         Else
            If Empty(SWB->WB_NUMDUP)
               /* Pendende de envio da integração do título. */
               lRet:= .T.
               Break
            EndIf
         EndIf
      
      Case SWB->WB_EVENT == "102" //Frete
         If Empty(SWB->WB_NUMDUP)
            /* Pendende de envio da integração do título. */
            lRet:= .T.
            Break
         EndIf
      
      Case SWB->WB_EVENT == "103" //Seguro
         If Empty(SWB->WB_NUMDUP)
            /* Pendende de envio da integração do título. */
            lRet:= .T.
            Break
         EndIf

      Case SWB->WB_EVENT == "608" //Invoice
         If !Empty(SWB->WB_NUMDUP) .Or. (!Empty(SWB->WB_SEQBX) .And. lValidaBaixa) 
            /* Pendende estorno do título e/ ou da compensação. */
            lRet:= .T.
            Break
         EndIf
         
      OtherWise
         lRet:= .F.
   End Case

End Sequence

Return lRet

/*
Funcao      : ExiteNfe()
Parâmetros  : cHawb - número do processo de embarque/ desembaraço
Retorno     : Lógico - indica se existe nota fiscal gerada para o processo (.T.)
Objetivos   : Vide retorno 
Autor       : WFS
Data 	     : 01/2015
Obs         :
Revisão     :
*/
Static Function ExisteNfe(cHawb)
Local lRet:= .F.

   SF1->(DBSetOrder(5)) //F1_FILIAL+F1_HAWB+F1_TIPO_NF+F1_DOC+F1_SERIE
   If SF1->(DBSeek(xFilial() + cHawb))
      lRet:= .T.
   EndIf
      
Return lRet

/*
Funcao      : IntegPendente()
Parâmetros  : cHawb - número do processo de embarque/ desembaraço
              lValidaBaixa - indica se será verificada a pendência de baixa do título
              nOpc - operação realizada. Quando não enviado, assume 0: todas operações
Retorno     : Lógico - indica se a parcela está pendente (.T.) de integração/ atualização no ERP
Objetivos   : Verificar se a parcela de câmbio está pendente de envio ao ERP 
Autor       : WFS
Data        : 01/2015
Obs         :
Revisão     : wfs jun/2017 - Acrescentada a verificação de parcelas e títulos não excluídos
*/
Static Function IntegPendente(cHawb, lValidaBaixa, nOpc)
Local lPendente:= .F.
Default lValidaBaixa:= .T.
Default nOpc:= 0

Begin Sequence

   /* Quando for apenas atualização de status, consiste todas as operações.
      Para identificação de pendências de integração, condiciona a verificação */
   If nOpc <> 5
      If ExisteNfe(cHawb)
         /* Retorno do status quando houver nota fiscal para o processo. */  
         lPendente:= Pend_PosNF(lValidaBaixa)
      Else
         /* Retorno do status quando NÃO houver nota fiscal para o processo. */
         lPendente:= Pend_PreNF(lValidaBaixa)
      EndIf
   EndIf

   /* caso possua pendência, aborta e não realiza a próxima verificação */
   If lPendente
      Break
   EndIf

   /* Retorna o status quando a invoice foi excluída e o câmbio foi mantido por erro de integração da exclusão 
      do título no financeiro do ERP */
   If nOpc == 0 .Or. nOpc == 5
      lPendente:= Pend_EstInvoice()
   EndIf

End Sequence
Return lPendente

/*
Funcao      : Pend_EstInvoice()
Parâmetros  : 
Retorno     : Lógico - quando a parcela de câmbio não possuir invoice, retorna que está pentende de
              integração da exclusão do título do financeiro e, consequentemente, da parcela de câmbio.
Objetivos   : Verificar se a parcela de câmbio possui invoice no processo
Autor       : WFS
Data        : jun/2017
Obs         : A tabela SWB deve estar posicionada no registro a ser procurado
Revisão     :
*/
Static Function Pend_EstInvoice()
Local lPendente:= .F.
Local aOrd:= SaveOrd({"SW9"})

Begin Sequence

   SW9->(DBSetOrder(1)) //W9_FILIAL+W9_INVOICE+W9_FORN+W9_FORLOJ+W9_HAWB

   /* caso a parcela possua número de título e não possua invoice, estará pendente de exclusão */
   If SWB->WB_PO_DI == "D" .And. SWB->WB_EVENT = "101" .And. Left(SWB->WB_TIPOREG,1) == "1"             // /NCF - 26/04/2018 - Verificar somente câmbio principal - parcela não antecipada
      lPendente:= !Empty(SWB->WB_NUMDUP) .And.;
                  !SW9->(DBSeek(xFilial() + SWB->WB_INVOICE + SWB->WB_FORN + SWB->WB_LOJA + SWB->WB_HAWB))
   EndIf
   
End Sequence

RestOrd(aOrd, .T.)
Return lPendente
