#Include 'average.ch'

/*========================================================================================
Funcao        : EECAF218 - Inclusão/Estorno das despesas dos contratos
Parametros    : -              
Objetivos     : Apenas função nominal para cadastrar o adapter do fonte EECAF218
Autor         : Felipe Sales Martinez - FSM
Data/Hora     : 19/01/2012 - 17:21 hs
Revisao       : 
Obs.          : 
==========================================================================================*/

Function EECAF218(nOpc)

Private aRotina   := MenuDef()

If EF3->EF3_VL_MOE > 0 //NCF - 28/10/2015 - Desnopado -  Estava permitindo integrar evento 640 de contrato com valor zerado em determinados casos.
  If (nOpc == 3 /*.And. Empty(EF3->EF3_TITFIN)*/ .And. Empty(EF3->EF3_SEQBX)) .OR.; //AAF 30/01/2015 - Retirada a validação pois o titulo pode ser gerado e liquidado na mesma operação, antes de gravar na base, pois a integração só ocorre com o descarregamento do buffer.
     (nOpc == 5 .And. !Empty(EF3->EF3_TITFIN) )      
     EasyEnvEAI("EECAF218",nOpc)     
  EndIf
EndIf 

Return .T.


Static Function MenuDef()

Local aRotina :=  {  { "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","AF218MAN" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "AF218MAN" , 0 , 3},; //"Incluir"
                     { "Alterar",   "AF218MAN" , 0 , 4},; //"Alterar"
                     { "Excluir",   "AF218MAN" , 0 , 5} } //"Excluir"                  

Return aRotina

Static Function AF218MAN()
Return Nil

/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: Allan Oliveira Monteiro 
* Data: 11/01/2012 - 15:10 hs 
* =====================================================*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("EF1")

	oEasyIntEAI:SetModule("EFF",30)
	
	// *** Envio
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF218ASENB") //Envio de Business
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF218ARESR")	//Rebimento de retorno da Business Enviada
	// ***
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()


/*========================================================================================
Funcao Adapter: AF218ASENB
Parametros    : "oMessage" - Objeto XML com conteúdo da tag "BusinessContent" recebida                
Objetivos     : 
Autor         : Felipe Sales Martinez - FSM
Data/Hora     : 19/01/2012 - 17:30 hs
Revisao       : 
Obs.          : 
==========================================================================================*/
*------------------------------------------------*
Function AF218ASENB(oEasyMessage) 
*------------------------------------------------* 
Local oXml      := EXml():New()
Local oRec      := ENode():New()
Local oEvent    := ENode():New()
Local oIdent    := ENode():New()
//Local oBusiness := ENode():New()
Local oList := ENode():New()
Local oSourceD := ENode():New()
Local oKeyNode
Local oApport := ENode():New()
Local oAppList := ENode():New()
Local cInfo := ""
Local aOrdEF3 := SaveOrd({"EF3","EC6","EF1"}) 
Local cTpMODU := If(EF1->EF1_TPMODU = "I","FIIM", "FIEX") + EF3->EF3_TP_EVE
Local cEmpMsg := SM0->M0_CODIGO
Local cFilMsg := AvGetM0Fil() 
Local cParam, nPosDiv
Local cChaveEF3 := EF3->(EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT)
Local aOrdEF3 := SaveOrd('EF3')
Private oBusiness   := ENode():New()
Private nTxContrato := 0

EF3->(DbSetOrder(1))
If EF3->(DbSeek( cChaveEf3+AvKey('100','EF3_CODEVE') ))
   nTxContrato := EF3->EF3_TX_MOE 
EndIf
RestOrd(aOrdEF3,.T.)
 
If !Empty( cParam := Alltrim(EasyGParam("MV_EEC0036",,"")) )
   If (nPosDiv := At('/',cParam)) > 0
      cEmpMsg := Substr(cParam,1,nPosDiv-1) 
      cFilMsg := Substr(cParam,nPosDiv+1,Len(cParam))
   Else
      cEmpMsg := cParam 
      cFilMsg := cParam         
   EndIf  
EndIf

EC6->(DbSetOrder(1))//EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC 
EC6->(DbSeek(xFilial("EC6") + AvKey(cTpMODU,"EC6_TPMODU") + AvKey(EF3->EF3_CODEVE,"EC6_ID_CAM")))

SA6->(DbSetOrder(1))//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
//SA6->(DbSeek(xFilial("SA6") +AvKey(EF1->EF1_BAN_FI,"A6_COD") ))
SA6->(DbSeek(xFilial("SA6") +AvKey(EF1->EF1_BAN_FI,"A6_COD") +AvKey(EF1->EF1_AGENFI,"A6_AGENCIA") +AvKey(EF1->EF1_NCONFI,"A6_NUMCON"))) //AAF 10/08/2015 - Utilizar agencia e conta também.

   If RecLock("EF3",.F.) .AND. Empty(EF3->EF3_TITFIN) // GFP - 23/02/2012
      EF3->EF3_PREFIX := EC6->EC6_PREFIX
      EF3->EF3_TPTIT := EC6->EC6_TPTIT
      EF3->(MsUnlock())
   EndIf

    /* BusinessEvent */

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","CompanyId"))
   oKeyNode:SetField(ETag():New("" ,SM0->M0_CODIGO))
   oIdent:SetField(ETag():New("key",oKeyNode))
   
   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","BranchId"))
   oKeyNode:SetField(ETag():New("" ,AvGetM0Fil()))
   oIdent:SetField(ETag():New("key",oKeyNode))
   
   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","TipoModulo"))
   oKeyNode:SetField(ETag():New("" , EF3->EF3_TPMODU))   
   oIdent:SetField(ETag():New("key",oKeyNode))
      
   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","NrContrato"))
   oKeyNode:SetField(ETag():New("" , EF3->EF3_CONTRA ))
   oIdent:SetField(ETag():New("key",oKeyNode)) 

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","AgencFecha"))
   oKeyNode:SetField(ETag():New("" , EF3->EF3_BAN_FI))
   oIdent:SetField(ETag():New("key",oKeyNode)) 

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","Praca"))
   oKeyNode:SetField(ETag():New("" , EF3->EF3_PRACA))
   oIdent:SetField(ETag():New("key",oKeyNode)) 

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","SeqContrato"))
   oKeyNode:SetField(ETag():New("" , EF3->EF3_SEQCNT))
   oIdent:SetField(ETag():New("key",oKeyNode)) 

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","CodEvento"))
   oKeyNode:SetField(ETag():New("" , EF3->EF3_CODEVE))
   oIdent:SetField(ETag():New("key",oKeyNode)) 

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","NroParcela"))
   oKeyNode:SetField(ETag():New("" , RetAsc( Val(EF3->EF3_PARC),1,.T. )))
   oIdent:SetField(ETag():New("key",oKeyNode))

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","Invoice"))
   oKeyNode:SetField(ETag():New("" , EF3->EF3_INVOIC))
   oIdent:SetField(ETag():New("key",oKeyNode))

	oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","InvImport"))
   oKeyNode:SetField(ETag():New("" , EF3->EF3_INVIMP))
   oIdent:SetField(ETag():New("key",oKeyNode))

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","Linha"))
   oKeyNode:SetField(ETag():New("" , EF3->EF3_LINHA))
   oIdent:SetField(ETag():New("key",oKeyNode))

   oEvent:SetField("Entity", "EECAF218")

   If Type("nEAIEvent") <> "U" .And. nEAIEvent == 5 //Exclusao
      oEvent:SetField("Event" , "delete")
   Else //Inclusao/Alteracao
      oEvent:SetField("Event" , "upsert")
   EndIf
   
   oEvent:SetField("Identification",oIdent)
   
   
   /* BusinessContent */
   
   oBusiness:SetField('CompanyId'       ,cEmpMsg)
   oBusiness:SetField('BranchId'        ,cFilMsg)
   
   oBusiness:SetField("DocumentPrefix"        , EF3->EF3_PREFIX)
   oBusiness:SetField("DocumentNumber"        , EF3->EF3_TITFIN)
   oBusiness:SetField("DocumentTypeCode"      , EF3->EF3_TPTIT)
   
   oSourceD:SetField("SourceDocument", EF1->EF1_CONTRA )
   oSourceD:SetField("SourceDocumentTypeCode", EF3->EF3_TPTIT)
   oSourceD:SetField("SourceDocumentValue", EF1->EF1_VL_MOE)
   oList:SetField("SourceDocument", oSourceD)
   oBusiness:SetField("ListOfSourceDocument", oList)
   
   If Left( AllTrim(EF3->EF3_CODEVE),1 ) == "7"
      If EC6->(FieldPos("EC6_DESINT")) == 0 .OR. !EC6->EC6_DESINT == '2'
         cInfo := EF1->EF1_DT_JUR
	  ElseIf EF3->(FieldPos("EF3_DTOREV")) > 0 .AND. !Empty(EF3->EF3_DTOREV)
	     cInfo := EF3->EF3_DTOREV
	  Else
	     cInfo := EF3->EF3_DT_EVE
	  EndIf
   Else
      If !Empty(EF3->EF3_DT_EVE)
         cInfo := EF3->EF3_DT_EVE
      Else 
         If EF3->(FIELDPOS("EF3_DTEMTT")) > 0
            cInfo := EF3->EF3_DTEMTT
         Else
            cInfo := dDataBase
         EndIf 
      EndIf
   EndIf 
   
   cInfo := EasyTimesTamp(cInfo, .T., .T.)
   If !Empty(cInfo)
      oBusiness:SetField("IssueDate"      , cInfo)
   EndIf
   
   cInfo := Max(EF3->EF3_DT_EVE, dDatabase)
   cInfo := EasyTimesTamp(cInfo, .T., .T.)
   oBusiness:SetField("DueDate"        , cInfo )
   
   cInfo := DataValida(Max(EF3->EF3_DT_EVE, dDatabase), .T.)
   If !Empty(cInfo)
      cInfo := EasyTimesTamp(cInfo, .T., .T.)
      oBusiness:SetField("RealDueDate"    , cInfo)
   EndIf
   

   If !Empty(EF3->EF3_FORN)
       cInfo := EF3->EF3_FORN
   Else
       cInfo := SA6->A6_CODFOR  
   EndIf
   oBusiness:SetField("VendorCode" , cInfo)

   If !Empty(EF3->EF3_LOJAFO)
      cInfo := EF3->EF3_LOJAFO
   Else
      cInfo := SA6->A6_LOJFOR
   EndIf   
   oBusiness:SetField("StoreId"      , cInfo)
   
   oBusiness:SetField("NetValue"     , EF3->EF3_VL_MOE)
   oBusiness:SetField("GrossValue"   , EF3->EF3_VL_MOE)
    
   //cInfo := If(!Empty(EF3->EF3_MOE_IN), EF3->EF3_MOE_IN, EF1->EF1_MOEDA )  //NCF - 03/12/2014 - Parca encargos, a moeda é R$
   cInfo := If( Left(EF3->EF3_CODEVE,1) $ '3/4', Avkey('R$', 'YF_MOEDA') , If(!Empty(EF3->EF3_MOE_IN), EF3->EF3_MOE_IN, EF1->EF1_MOEDA ) )
        
   SYF->( dbSetOrder(1) ) //YF_FILIAL+YF_MOEDA
   SYF->( dbSeek( xFilial() + cInfo ))
   If EC6->EC6_TXCV == "2" //COMPRA 
      oBusiness:SetField('CurrencyCode'       ,SYF->YF_CODCERP)
   Else //VENDA
      oBusiness:SetField('CurrencyCode'       ,SYF->YF_CODVERP)
   EndIf
    
   oBusiness:SetField("CurrencyRate" , EF3->EF3_TX_MOE)
   oApport:SetField("CostCenterCode", EC6->EC6_CCUSTO)
   oApport:SetField("Value"         , EF3->EF3_VL_MOE)
   oApport:SetField("FinancialCode", EC6->EC6_NATFIN)
   oAppList:SetField("Apportionment", oApport)
   oBusiness:SetField("ApportionmentDistribution", oAppList)
      
   oBusiness:SetField("Observation"  , EF3->EF3_OBS)
   oBusiness:SetField("Origin"        , "SIGAEFF")

   If EasyEntryPoint("EECAF218")
      ExecBlock("EECAF218", .f., .f., "MSG_CAP_INC_ALTERA_DADOS_TAGS")
   Endif   
   
   oRec:SetField("BusinessEvent"  ,oEvent)
   oRec:SetField("BusinessContent",oBusiness) 
   oXml:AddRec(oRec)
   
   If IsInCallStack("EasyEAIBuffer") 
      //Tratamento para não perder títulos caso ocorre falha na integração
      If EF3->(Deleted())
         If Type('lRecall') == 'L'
	        lRecall := .T.
	     EndIf  
         EF3->(RecLock("EF3",.F.))
         EF3->(dbRecall())
         EF3->(MsUnLock())
      EndIf
   EndIf
    	
RestOrd(aOrdEF3,.T.)

Return oXml

/*========================================================================================
Funcao Adapter: AF218ARESR
Parametros    : "oMessage" - Objeto XML com conteúdo da tag "BusinessContent" recebida                
Objetivos     : RECEBER uma RESPONSE (apos envio de BUSINNES) e gravar arquivo 
Autor         : Felipe Sales Martinez - FSM
Data/Hora     : 19/01/2012 - 17:30 hs
Revisao       : 
Obs.          : 
==========================================================================================*/
*------------------------------------------------*
Function AF218ARESR(oEasyMessage) 
*------------------------------------------------* 
//Local oMessage := oEasyMessage:GetMsgContent()
//Local oInfo    := oEasyMessage:GetMsgInfo() 
Local oBusinessCont  := oEasyMessage:GetRetContent()
Local oBusinessEvent := oEasyMessage:GetEvtContent()
Local cModulo := ""
Local cContrato  := "" 
Local cAgenc := ""
Local cPraca:= ""
Local cSeq := ""
Local cCodEvento := ""
Local cEvent := ""
Local cFilial := ""
Local cParc := ""
Local cInvoic := ""
Local cInvImp := ""
Local cLinha := ""
Local cNumero := ""
Local aOrdEF3 := SaveOrd({"EF3"}) 

   If !(ValType(oBusinessEvent:_IDENTIFICATION:_Key) == "A")
      aKey := {oBusinessEvent:_IDENTIFICATION:_Key}
   Else
      aKey := oBusinessEvent:_IDENTIFICATION:_Key
   EndIf
   
   aEval(aKey,  {|x| If(x:_NAME:Text == "BranchId"  , cFilial := x:TEXT,) }) 
   aEval(aKey,  {|x| If(x:_NAME:Text == "TipoModulo", cModulo := x:TEXT,) }) 
   aEval(aKey,  {|x| If(x:_NAME:Text == "NrContrato", cContrato := x:TEXT,) }) 
   aEval(aKey,  {|x| If(x:_NAME:Text == "AgencFecha", cAgenc := x:TEXT,) })
   aEval(aKey,  {|x| If(x:_NAME:Text == "Praca"      , cPraca := x:TEXT,) }) 
   aEval(aKey,  {|x| If(x:_NAME:Text == "SeqContrato", cSeq := x:TEXT,) })
   aEval(aKey,  {|x| If(x:_NAME:Text == "CodEvento"  , cCodEvento := x:TEXT,) }) 
   aEval(aKey,  {|x| If(x:_NAME:Text == "NroParcela" , cParc := x:TEXT,) }) 
   aEval(aKey,  {|x| If(x:_NAME:Text == "Invoice" , cInvoic := x:TEXT,) }) 
   aEval(aKey,  {|x| If(x:_NAME:Text == "InvImport" , cInvImp := x:TEXT,) }) 
   aEval(aKey,  {|x| If(x:_NAME:Text == "Linha"      , cLinha := x:TEXT,) }) 
   
   cEvent  := EasyGetXMLInfo(, oBusinessEvent,"_Event"   )
   
   If !Empty(cParc)
      cParc := RetAsc(cParc,AvSX3("EF3_PARC",AV_TAMANHO),.F.)
   EndIf
   
   EF3->(DbSetOrder(1)) // EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE+EF3_PARC+EF3_INVOIC+EF3_INVIMP+EF3_LINHA   
   If EF3->(DbSeek( AvKey(cFilial,"EF3_FILIAL") + AvKey(cModulo,"EF3_TPMODU") + AvKey(cContrato,"EF3_CONTRA")  + AvKey(cAgenc,"EF3_BAN_FI") + AvKey(cPraca,"EF3_PRACA") + AvKey(cSeq,"EF3_SEQCNT") + AvKey(cCodEvento,"EF3_CODEVE") + AvKey(cParc,"EF3_PARC") + AvKey(cInvoic,"EF3_INVOIC") + AvKey(cInvImp,"EF3_INVIMP") + AvKey(cLinha,"EF3_LINHA") ));
      .Or. ;
      EF3->(DbSeek( AvKey(cFilial,"EF3_FILIAL") + AvKey(cModulo,"EF3_TPMODU") + AvKey(cContrato,"EF3_CONTRA")  + AvKey(cAgenc,"EF3_BAN_FI") + AvKey(cPraca,"EF3_PRACA") + AvKey(cSeq,"EF3_SEQCNT") + AvKey(cCodEvento,"EF3_CODEVE") + AvKey("","EF3_PARC") + AvKey(cInvoic,"EF3_INVOIC") + AvKey(cInvImp,"EF3_INVIMP") + AvKey(cLinha,"EF3_LINHA") ))
      
      Begin Transaction
	      EF3->(RecLock("EF3",.F.)) 
	      If  AllTrim(UPPER(cEvent)) == "UPSERT"   
	         EF3->EF3_TITFIN := EasyGetXMLInfo(, oBusinessCont ,"_DocumentNumber"   )
	      Else
	         EF3->EF3_TITFIN := ""
             If IsInCallStack("EasyEAIBuffer")
                //Tratamento para não perder títulos caso ocorre falha na integração
                If !EF3->(Deleted()) .AND. lRecall
                   EF3->(dbDelete())
			       lRecall := .F.
                EndIf
             EndIf
	      EndIf
	      EF3->(MsUnlock())  
	  End Transaction 

   EndIf

RestOrd(aOrdEF3,.T.)


Return oEasyMessage
