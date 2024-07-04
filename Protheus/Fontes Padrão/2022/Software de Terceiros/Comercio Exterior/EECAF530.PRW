#INCLUDE "Average.ch"
/*
Programa : EECAF530.PRW
Autor    : Alessandro Alves Ferreira - AHAC 
Data     : 01/10/2014
Objetivo : Titulos de Invoice de Serviço a Receber
Uso      : 
*/
*--------------------------------------------------------------------
Function EECAF530(cTab,nOpc)
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

If nOpc <> 5 .OR. !Empty((cAlias)->EEQ_FINNUM)
   lOk:= EasyEnvEAI("EECAF530",nOpc)
EndIf
If Type("lMsErroAuto") == "L" .And. lMsErroAuto .and. !lOk
   EasyHelp(oAvObjEAI:GetStrErrors())
EndIf

Return lOk

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
   oEasyIntEAI:SetModule(cModulo, nModulo)

   // Envio 
   oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF530SEND") //ENVIO                               (->Business)
   oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF530RESP") //RESPOSTA SOBRE O ENVIO              (<-Response)
   // Envio 

   oEasyIntEAI:Execute()
   
Return oEasyIntEAI:GetResult() 

*------------------------------------------------*
Function AF530SEND(oMessage) 
*------------------------------------------------* 
Local oXml       := EXml():New()
Local oBusiness  := ENode():New()
Local oBusinEvent:= ENode():New() 
Local oIdent     := ENode():New()  
Local oRec       := ENode():New()
Local aOrd       := {}
Local dMaiorDt   :=cTod("//")
Local cTpMod       := "SISCSV"

//Parcela de câmbio originada pela rotina de câmbio desvinculado (não originado pelo SIGAESS)
If AvFlags("EEC_LOGIX") .And. Empty((cAlias)->EEQ_PROCES)
   cTpMod:= "EXPORT"
EndIf

aOrd := SaveOrd({"ELA", "EEQ", "EC6"}) 
If nReg <> 0
   EEQ->(DBGOTO(nReg)) 
EndIf
ELA->(DBSETORDER(4))                                        //ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO 
ELA->(DBSEEK(xFilial("ELA") + (cAlias)->EEQ_TPPROC + (cAlias)->EEQ_PROCES + (cAlias)->EEQ_NRINVO))
EC6->(DBSETORDER(1))                                        //EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
EC6->(DBSEEK(xFilial("EC6")+AVKEY(cTpMod,"EC6_TPMODU")+(cAlias)->EEQ_EVENT))

oBusinEvent:SetField("Entity", "EECAF530")
oBusinEvent:SetField("Event" , IF(nEAIEvent <> 5,"upsert","delete"))

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

   oBusinEvent:SetField("Identification",oIdent)

   oBusiness:SetField("CompanyId"             ,SM0->M0_CODIGO)
   oBusiness:SetField("BranchId"              ,FWFilial())
   oBusiness:SetField("DocumentPrefix"        ,EC6->EC6_PREFIX)  
   oBusiness:SetField("DocumentNumber"        ,(cAlias)->EEQ_FINNUM)
   oBusiness:SetField("DocumentParcel"        ,"") 
   oBusiness:SetField("DocumentTypeCode"      ,EC6->EC6_TPTIT)
   //oBusiness:SetField("BlockAmendmentDocument", "B")

   oSourcDoc := ENode():New()
   oSourcDoc:SetField("SourceDocument",cHawb)
   oSourcDoc:SetField('SourceDocumentTypeCode'   ,EasyGParam("MV_AVG0205",,"XP"))

   If nModulo == 85
      oSourcDoc:SetField('SourceDocumentValue'      ,ELA->ELA_VLCAMB + ELA->ELA_VLEXT)
   Else
      oSourcDoc:SetField('SourceDocumentValue'      ,EEQ->EEQ_VL)
   EndIf
   
   oListSrcDoc := ENode():New()
   oListSrcDoc:SetField("SourceDocument",oSourcDoc)
   
   oBusiness:SetField("ListOfSourceDocument",oListSrcDoc)
   oBusiness:SetField('Situation'             ,"001")
   
   If nModulo == 85
      oBusiness:SetField("IssueDate"             ,EasyTimeStamp(ELA->ELA_DTEMIS,.T.,.T.))
   Else
      oBusiness:SetField("IssueDate"             ,EasyTimeStamp(EEQ->EEQ_EMISSA,.T.,.T.))
   EndIf

   oBusiness:SetField("DueDate"         ,EasyTimeStamp(AF530MAXVENC("EEQ_HVCT"),.T.,.T.))
   oBusiness:SetField("RealDueDate"     ,EasyTimeStamp(DataValida(AF530MAXVENC("EEQ_HVCT")),.T.,.T.))


   oBusiness:SetField("CustomerCode" ,(cAlias)->EEQ_IMPORT)
   oBusiness:SetField("StoreId"      ,(cAlias)->EEQ_IMLOJA)
   
   If nModulo == 85
      oBusiness:SetField("NetValue"     ,ELA->ELA_VLCAMB + ELA->ELA_VLEXT)
      oBusiness:SetField("GrossValue"   ,ELA->ELA_VLCAMB + ELA->ELA_VLEXT)
      //oBusiness:SetField('InvoiceAmount',ELA->ELA_VLCAMB + ELA->ELA_VLEXT)
   Else
      oBusiness:SetField("NetValue"     ,EEQ->EEQ_VL)
      oBusiness:SetField("GrossValue"   ,EEQ->EEQ_VL)
      oBusiness:SetField('InvoiceAmount',EEQ->EEQ_VL)
   EndIf

   cCodERP:=""
   IF SYF->(DBSEEK(xFilial("SYF")+(cAlias)->EEQ_MOEDA))
      IF EC6->EC6_TXCV == "2"
         cCodERP:= SYF->YF_CODCERP
      ELSE
         cCodERP:= SYF->YF_CODVERP
      ENDIF
   ENDIF                                                
   oBusiness:SetField("CurrencyCode",cCodERP)  

   If nModulo == 85
      oBusiness:SetField("CurrencyRate",ELA->ELA_TX_MOE)
   Else
      oBusiness:SetField("CurrencyRate",EEQ->EEQ_TX)   
   EndIf

   oApportionment:= ENode():New()
   oApportionment:SetField("CostCenterCode",EC6->EC6_CCUSTO)
   
   If nModulo == 85
      oApportionment:SetField("Value"         ,ELA->ELA_VLCAMB + ELA->ELA_VLEXT)
   Else
      oApportionment:SetField("Value"         ,EEQ->EEQ_VL)
   EndIf

   oApportionment:SetField("FinancialCode" ,EC6->EC6_NATFIN)

   oAppDistri := ENode():New()
   oAppDistri:SetField("Apportionment",oApportionment)
   
   oBusiness:SetField("ApportionmentDistribution",oAppDistri)
   oBusiness:SetField('Observation'     ,"")
   
   oBusiness:SetField('Origin'     ,cModulo/*"ESS"*/)
	
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
Function AF530RESP(oMessage)
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
* Função: AF530MAXVENC()                               *
* Objetivo: Retorna maior data de Vencimento das parcelas de invoice (EEQ)    *
* Obs:                                                 *
\* ====================================================*/
*------------------------------------------------*
Static Function AF530MAXVENC(cCampo)
*------------------------------------------------*       	
Local aOrd    := SaveOrd({"EEQ"})
Local dMaior  := CTOD("  /  /  ")

EEQ->(DbSetOrder(4))//EEQ_FILIAL + EEQ_NRINVO + EEQ_PREEMB + EEQ_PARC 
EEQ->(dbSeek(cFilEEQ + cNrInvo + cPreEmb)) // Posiciona na primeira parcela da invoice

Do While EEQ->(!EOF()) .And. EEQ->EEQ_FILIAL == cFilEEQ;
                       .And. EEQ->EEQ_NRINVO == cNrInvo;
                       .And. EEQ->EEQ_PREEMB == cPreEmb
   If dMaior < (cAlias)->(FieldGet(FieldPos(cCampo)))
      dMaior := (cAlias)->(FieldGet(FieldPos(cCampo)))
   EndIf
   EEQ->(DBSKIP())
EndDo

RestOrd(aOrd,.T.)
Return dMaior
