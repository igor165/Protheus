#INCLUDE "Average.ch"
/*
Programa : EECAF511.PRW
Autor    : Alan Henrique Almeida da Costa - AHAC 
Data     : 11/07/14
Objetivo : Liquidação da Parcela de Invoice
Uso      : Integração do Easy Siscoserv com Logix via WebService - EF TDE_REQ9.0_ESS - Projeto Proposta 140117
*/
*--------------------------------------------------------------------
Function EECAF511(cTab,nOpc)
*--------------------------------------------------------------------
LOCAL lOk      := .T.
PRIVATE cAlias := cTab
Private cFilEEQ := (cAlias)->EEQ_FILIAL,;
        cPreEmb := (cAlias)->EEQ_PREEMB,;
        cNrInvo := (cAlias)->EEQ_NRINVO,;
        cParc   := (cAlias)->EEQ_PARC 

If Type("lMsErroAuto") == "L" .And. lMsErroAuto
   oAvObjEAI := AvObject():New()
EndIf

lOk:= EasyEnvEAI("EECAF511",nOpc)

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
   oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF511SEND") //ENVIO                               (->Business)
   oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF511RESP") //RESPOSTA SOBRE O ENVIO              (<-Response)
   // Envio 

   oEasyIntEAI:Execute()
   
Return oEasyIntEAI:GetResult() 

/* ====================================================*
* Função: AF510SEND(oMessage)
* Objetivo: Envio das parcelas da Invoice - SIGAESS
* Obs: 
* =====================================================*/
*------------------------------------------------*
Function AF511SEND(oMessage) 
*------------------------------------------------* 
Local oXml         := EXml():New()
Local oBusiness    := ENode():New()
Local oBusinRequest:= ENode():New() 
Local oRec         := ENode():New()
Local aOrd         := {}
Local cTpMod       := "EXPORT"
Local cBanco     := ""
Local cAgencia   := ""
Local cConta     := ""
Local oCont

If (IsInCallStack("ESSRS400") .Or. IsInCallStack("ESSRS403") .Or. IsInCallStack("ESSPS401") .Or. IsInCallStack("ESSPS400") .Or. IsInCallStack("ESSIN100")) .Or. (Type("aAF500Auto") == "A" .And.  (aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_REGIST" }) > 0 .Or. aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" }) > 0))
   cTpMod := "SISCSV"
EndIf

aOrd := SaveOrd({"EEQ", "EC6"})
If nReg <> 0  //AHAC - 11/08/2014 - RecNo Private em EECAF500 - Origem da Chamada
   EEQ->(DBGOTO(nReg)) 
EndIf
EC6->(DBSETORDER(1)) //EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
EC6->(DBSEEK(xFilial("EC6")+AVKEY("SISCSV","EC6_TPMODU")+(cAlias)->EEQ_EVENT))

//<BusinessRequest>
   oBusinRequest:SetField("Operation", "EECAF511")
//</BusinessRequest>

//<BusinessContent>
   oBusiness:SetField("CompanyId"             ,SM0->M0_CODIGO)
   oBusiness:SetField("BranchId"              ,FWFilial())
   oBusiness:SetField("DocumentPrefix"        ,EC6->EC6_PREFIX)  
   oBusiness:SetField("DocumentNumber"        ,(cAlias)->EEQ_FINNUM)
   oBusiness:SetField("DocumentParcel"        ,(cAlias)->EEQ_PARC) 
   oBusiness:SetField("DocumentTypeCode"      ,EC6->EC6_TPTIT)
   oBusiness:SetField("PaymentDate"           ,EasyTimeStamp((cAlias)->EEQ_PGT),.T.,.T.)
   oBusiness:SetField("PaymentValue"          ,(cAlias)->EEQ_VL)
   cCodERP := ''
   IF SYF->(DBSEEK(xFilial("SYF")+(cAlias)->EEQ_MOEDA))
      IF EC6->EC6_TXCV == "2"
         cCodERP:= SYF->YF_CODCERP
      ELSE
         cCodERP:= SYF->YF_CODVERP
      ENDIF
   ENDIF
   oBusiness:SetField("CurrencyCode"           ,cCodERP)
   oBusiness:SetField("CurrencyRate"          ,(cAlias)->EEQ_TX)
   oBusiness:SetField("VendorCode"            ,(cAlias)->EEQ_FORN)
   oBusiness:SetField("StoreId"               ,(cAlias)->EEQ_FOLOJA)
   oBusiness:SetField("PaymentMethodCode"     ,"004")
   oBusiness:SetField("PaymentMeans"          ,"000")
   //<Bank>
      oBank := ENode():New()
         /* comentado por WFS em 01/09/2014
         oBank:SetField("BankCode"       ,(cAlias)->EEQ_BANC)
         oBank:SetField("BankAgency"     ,(cAlias)->EEQ_AGEN)
         oBank:SetField("BankAccount"    ,(cAlias)->EEQ_NCON)*/
      
         //WFS 01/09/2014 - complemento dos dados bancários
         cBanco:= (cAlias)->EEQ_BANC
         cAgencia:= (cAlias)->EEQ_AGEN
         cConta:= (cAlias)->EEQ_NCON
       
         SA6->(DBSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
         If SA6->(DBSeek(xFilial() + (cAlias)->EEQ_BANC + (cAlias)->EEQ_AGEN + (cAlias)->EEQ_NCON))

            If !Empty(SA6->A6_DVAGE)
               cAgencia:= AllTrim(SA6->A6_AGENCIA) + "-" + SA6->A6_DVAGE 
            EndIf

            If !Empty(SA6->A6_DVCTA)
               cConta:= AllTrim(SA6->A6_NUMCON) + "-" + SA6->A6_DVCTA 
            EndIf
         EndIf
               
         oBank:SetField("BankCode"       ,cBanco)
         oBank:SetField("BankAgency"     ,cAgencia)
         oBank:SetField("BankAccount"    ,cConta)
      
      oBusiness:SetField("Bank"              ,oBank)
   //</Bank>
   If !Empty(EC6->EC6_NATFIN)
      oBusiness:SetField("FinancialCode"      ,EC6->EC6_NATFIN)
   EndIf
   oBusiness:SetField("HistoryText"           ,"")
   
   //WFS 05/09/2014
       oCont:= ENode():New()
       oCont:SetField("DocumentPrefix"  ,""           )
       oCont:SetField("DocumentNumber"  ,(cAlias)->EEQ_NROP)
   oBusiness:SetField('PaymentDocument', oCont)
    
   oBusiness:SetField("DischargeSequence"     ,"1")
//<BusinessContent>

oRec:SetField("BusinessRequest",oBusinRequest)// OK
oRec:SetField("BusinessContent",oBusiness) //  OK
oXml:AddRec(oRec)
   
RestOrd(aOrd,.T.)

Return oXml


/* ====================================================*\
* Função: AF511RESP(oMessage)                          *
* Objetivo: Resposta do Envio                          *
* Obs:                                                 *
\* ====================================================*/
*------------------------------------------------*
Function AF511RESP(oMessage)
*------------------------------------------------*
Local oRetCont  := oMessage:GetRetContent()

EEQ->(DbSetOrder(4))//EEQ_FILIAL + EEQ_NRINVO + EEQ_PREEMB + EEQ_PARC 
If EEQ->(dbSeek(cFilEEQ + cNrInvo + cPreEmb + cParc)) // Posiciona na parcela da invoice
   EEQ->(RECLOCK('EEQ',.F.))
   EEQ->EEQ_SEQBX := EasyGetXMLinfo(,oRetCont, "_DischargeSequence")
   EEQ->(MSUNLOCK())
EndIf

Return oMessage