#INCLUDE "Average.ch"
/*
Programa : EECAF510.PRW
Autor    : Alan Henrique Almeida da Costa - AHAC 
Data     : 11/07/14
Objetivo : Efetivação das Parcelas de Invoice
Uso      : Integração do Easy Siscoserv com Logix via WebService - EF TDE_REQ9.0_ESS - Projeto Proposta 140117
*/
*--------------------------------------------------------------------
Function EECAF510(cTab,nOpc)
*--------------------------------------------------------------------
LOCAL lOk      := .T.
PRIVATE cAlias := cTab
Private cFilEEQ := (cAlias)->EEQ_FILIAL,;
        cTpProc := (cAlias)->EEQ_TPPROC,;
        cHawb   := (cAlias)->EEQ_PROCES,;
        cPreEmb := (cAlias)->EEQ_PREEMB,;
        cNrInvo := (cAlias)->EEQ_NRINVO

If Type("lMsErroAuto") == "L" .And. lMsErroAuto
   oAvObjEAI := AvObject():New()
EndIf

lOk:= EasyEnvEAI("EECAF510",nOpc)

If Type("lMsErroAuto") == "L" .And. lMsErroAuto .and. !lOk
   EasyHelp(oAvObjEAI:GetStrErrors())
EndIf

Return lOk

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

If Type("cAlias") == "U"
   cAlias := "EEQ"
EndIf

   oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
   
   oEasyIntEAI:oMessage:SetVersion("1.001")
   oEasyIntEAI:oMessage:SetMainAlias(cAlias)
   oEasyIntEAI:SetModule("ESS",85)

   // Envio 
   oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF510SEND") //ENVIO                               (->Business)
   oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF510RESP") //RESPOSTA SOBRE O ENVIO              (<-Response)
   // Envio 

   oEasyIntEAI:Execute()
   
Return oEasyIntEAI:GetResult() 

/* ====================================================*
* Função: AF510SEND(oMessage)
* Objetivo: Envio das parcelas da Invoice - SIGAESS
* Obs: 
* =====================================================*/
*------------------------------------------------*
Function AF510SEND(oMessage) 
*------------------------------------------------* 
Local oXml       := EXml():New()
Local oBusiness  := ENode():New()
Local oBusinEvent:= ENode():New() 
Local oIdent     := ENode():New()  
Local oRec       := ENode():New()
Local aOrd       := {}
Local dMaiorDt   :=cTod("//")
Local cTpMod       := "EXPORT"

If (IsInCallStack("ESSRS400") .Or. IsInCallStack("ESSRS403") .Or. IsInCallStack("ESSPS401") .Or. IsInCallStack("ESSPS400") .Or. IsInCallStack("ESSIN100")) .Or. (Type("aAF500Auto") == "A" .And.  (aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_REGIST" }) > 0 .Or. aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" }) > 0))
   cTpMod := "SISCSV"
EndIf

aOrd := SaveOrd({"ELA", "EEQ", "EC6"}) 
If nReg <> 0  //AHAC - 11/08/2014 - RecNo Private em EECAF500 - Origem da Chamada
   EEQ->(DBGOTO(nReg)) 
EndIf
ELA->(DBSETORDER(4))                                        //ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO 
ELA->(DBSEEK(xFilial("ELA") + (cAlias)->EEQ_TPPROC + (cAlias)->EEQ_PROCES + (cAlias)->EEQ_NRINVO))
EC6->(DBSETORDER(1))                                        //EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
EC6->(DBSEEK(xFilial("EC6")+cTpMod+(cAlias)->EEQ_EVENT))

//<BusinessEvent>

   //Entity e Event
   oBusinEvent:SetField("Entity", "EECAF510")

   oBusinEvent:SetField("Event" , IF(nEAIEvent <> 5,"upsert","delete"))

      //<Identification>
      oKeyNode:= ENode():New()
      oKeyNode:SetField(EAtt():New("name","Branch"))
      oKeyNode:SetField(ETag():New("",cFilEEQ))
      oIdent:SetField(ETag():New("key",oKeyNode))

      oKeyNode:= ENode():New()
      oKeyNode:SetField(EAtt():New("name","Type"))
      oKeyNode:SetField(ETag():New("",cTpProc))
      oIdent:SetField(ETag():New("key",oKeyNode))

      oKeyNode:= ENode():New()
      oKeyNode:SetField(EAtt():New("name","Process"))
      oKeyNode:SetField(ETag():New("",cHawb))
      oIdent:SetField(ETag():New("key",oKeyNode))

      oKeyNode:= ENode():New()
      oKeyNode:SetField(EAtt():New("name","Invoice"))
      oKeyNode:SetField(ETag():New("",cNrInvo))
      oIdent:SetField(ETag():New("key",oKeyNode))

   //<Identification>

   oBusinEvent:SetField("Identification",oIdent)

//<BusinessEvent>

//capa
//<BusinessContent>
   oBusiness:SetField("CompanyId"             ,SM0->M0_CODIGO)
   oBusiness:SetField("BranchId"              ,FWFilial())
   oBusiness:SetField("DocumentPrefix"        ,EC6->EC6_PREFIX)  
   oBusiness:SetField("DocumentNumber"        ,(cAlias)->EEQ_FINNUM)
   oBusiness:SetField("DocumentParcel"        ,"") 
   oBusiness:SetField("DocumentTypeCode"      ,EC6->EC6_TPTIT)
   oBusiness:SetField("BlockAmendmentDocument","B")
   //<ListOfSourceDocument>
      oListSrcDoc := ENode():New()
      //<SourceDocument>
           oSourcDoc := ENode():New()
           oSourcDoc:SetField("SourceDocument",cHawb)
      //</SourceDocument>
      oListSrcDoc:SetField("SourceDocument",oSourcDoc)
   oBusiness:SetField("ListOfSourceDocument",oListSrcDoc)
   //</ListOfSourceDocument>                          
   
   oBusiness:SetField("IssueDate"   ,EasyTimeStamp(ELA->ELA_DTEMIS,.T.,.T.))
   oBusiness:SetField("DueDate"     ,EasyTimeStamp(dMaiorDt := AF510MAXVENC(),.T.,.T.))
   oBusiness:SetField("RealDueDate" ,EasyTimeStamp(DataValida(dMaiorDt),.T.,.T.))
   oBusiness:SetField("VendorCode"  ,(cAlias)->EEQ_FORN)
   oBusiness:SetField("StoreId"     ,(cAlias)->EEQ_FOLOJA)
   oBusiness:SetField("NetValue"    ,ELA->ELA_VLCAMB + ELA->ELA_VLEXT)
   oBusiness:SetField("GrossValue"  ,ELA->ELA_VLCAMB + ELA->ELA_VLEXT)
   cCodERP:=""
   IF SYF->(DBSEEK(xFilial("SYF")+(cAlias)->EEQ_MOEDA))
      IF EC6->EC6_TXCV == "2"
         cCodERP:= SYF->YF_CODCERP
      ELSE
         cCodERP:= SYF->YF_CODVERP
      ENDIF
   ENDIF                                                
   oBusiness:SetField("CurrencyCode",cCodERP)  

   //AAF 12/08/2014 - Considerar a taxa de emissão da invoice.   
   //IF  ALLTRIM((cAlias)->EEQ_MOEDA) == 'R$' 
   //   oBusiness:SetField("CurrencyRate",1)
   //ELSE                                           
   //oBusiness:SetField("CurrencyRate",BuscaTaxa((cAlias)->EEQ_MOEDA,(cAlias)->EEQ_EMISSA,,.F.,,,EC6->EC6_TXCV))
   oBusiness:SetField("CurrencyRate",ELA->ELA_TX_MOE)
   //ENDIF                                  

   //<ApportionmentDistribution> 
      
   oAppDistri := ENode():New()
      //<Apportionment>
      oApportionment:= ENode():New()
      oApportionment:SetField("CostCenterCode",EC6->EC6_CCUSTO)
      oApportionment:SetField("Value"         ,ELA->ELA_VLCAMB + ELA->ELA_VLEXT)
      oApportionment:SetField("FinancialCode" ,EC6->EC6_NATFIN)

      oAppDistri:SetField("Apportionment",oApportionment)
      //</Apportionment>
   oBusiness:SetField("ApportionmentDistribution",oAppDistri)
   //</ApportionmentDistribution> 
      
   //<ListOfInstallment>
   oListOfInsta:=ENode():New()
   EEQ->(DbSetOrder(4))//EEQ_FILIAL + EEQ_NRINVO + EEQ_PREEMB + EEQ_PARC 
   EEQ->(dbSeek(cFilEEQ + cNrInvo + cPreEmb)) // Posiciona na primeira parcela da invoice
   Do While EEQ->(!EOF()) .And. EEQ->EEQ_FILIAL == cFilEEQ;
                          .And. EEQ->EEQ_NRINVO == cNrInvo;
                          .And. EEQ->EEQ_PREEMB == cPreEmb
      
      If EEQ->EEQ_TPPROC == cTpProc
         //<Installment>
         oInstallment:=ENode():New()
         oInstallment:SetField("DocumentParcel",(cAlias)->EEQ_PARC)
         oInstallment:SetField("ValueParcel"   ,(cAlias)->EEQ_VL)
         oInstallment:SetField("PaymentDate"   ,EasyTimeStamp((cAlias)->EEQ_VCT),.T.,.T.)
         oInstallment:SetField("Observation"   ,EC6->EC6_DESC)
         //</Installment>      
         oListOfInsta:SetField("Installment",oInstallment) 
      EndIf
      EEQ->(DBSKIP())
   EndDo          
      //</ListOfInstallment>
   oBusiness:SetField("ListOfInstallment",oListOfInsta)
   
   
   oBusiness:SetField("Bank"         ,"")
   oBusiness:SetField("Observation"  ,ELA->ELA_COMPL)
   oBusiness:SetField("Origin"       ,"SIGAESS")
//<BusinessContent>

oRec:SetField("BusinessEvent"  ,oBusinEvent)// OK
oRec:SetField("BusinessContent",oBusiness) //  OK
oXml:AddRec(oRec)
   
RestOrd(aOrd,.t.)

Return oXml

/* ====================================================*\
* Função: AF510RESP(oMessage)                          *
* Objetivo: Resposta do Envio                          *
* Obs:                                                 *
\* ====================================================*/
*------------------------------------------------*
Function AF510RESP(oMessage)
*------------------------------------------------*
Local oReturn        := oMessage:GetRetContent()
Local oBusinesEvent  := oMessage:GetEvtContent()
Local cEvento        := Upper(EasyGetXMLinfo(,oBusinesEvent,"_Event"))
Local cFinNum

cFinNum:= EasyGetXMLinfo( ,oReturn, "_DocumentNumber" )

EEQ->(DbSetOrder(4))//EEQ_FILIAL + EEQ_NRINVO + EEQ_PREEMB + EEQ_PARC 
EEQ->(dbSeek(cFilEEQ + cNrInvo + cPreEmb)) // Posiciona na primeira parcela da invoice
Do While EEQ->(!EOF()) .And. EEQ->EEQ_FILIAL == cFilEEQ;
                       .And. EEQ->EEQ_NRINVO == cNrInvo;
                       .And. EEQ->EEQ_PREEMB == cPreEmb
   EEQ->(RECLOCK('EEQ',.F.))
   IF cEvento == "DELETE"
      EEQ->EEQ_FINNUM := ""
   Else
      EEQ->EEQ_FINNUM := cFinNum
   Endif
   EEQ->(MSUNLOCK())
   EEQ->(DBSKIP())
EndDo

Return oMessage

/* ====================================================*\
* Função: AF510MAXVENC()                               *
* Objetivo: Retorna maior data de Vencimento das parcelas de invoice (EEQ)    *
* Obs:                                                 *
\* ====================================================*/
*------------------------------------------------*
Static Function AF510MAXVENC()
*------------------------------------------------*       	
Local aOrd    := SaveOrd({"EEQ"})
Local dMaior  := (cAlias)->EEQ_VCT

EEQ->(DbSetOrder(4))//EEQ_FILIAL + EEQ_NRINVO + EEQ_PREEMB + EEQ_PARC 
EEQ->(dbSeek(cFilEEQ + cNrInvo + cPreEmb)) // Posiciona na primeira parcela da invoice

Do While EEQ->(!EOF()) .And. EEQ->EEQ_FILIAL == cFilEEQ;
                       .And. EEQ->EEQ_NRINVO == cNrInvo;
                       .And. EEQ->EEQ_PREEMB == cPreEmb
   If dMaior < EEQ->EEQ_VCT
      dMaior := EEQ->EEQ_VCT
   EndIf
   EEQ->(DBSKIP())
EndDo

RestOrd(aOrd,.T.)
Return dMaior
