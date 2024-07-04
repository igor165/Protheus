#INCLUDE "Average.ch"
/*
Programa : EECAF531.PRW
Autor    : Alessandro Alves Ferreira
Data     : 01/10/2014
Objetivo : Baixa de Titulos de Invoice de Serviço a Receber
Uso      : 
*/
*--------------------------------------------------------------------
Function EECAF531(cTab,nOpc)
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

If !Empty(EEQ->EEQ_FINNUM) .And. Empty(EEQ->EEQ_SEQBX)
   lOk:= EasyEnvEAI("EECAF531",nOpc)
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
   
   oEasyIntEAI:oMessage:SetVersion("1.000")
   oEasyIntEAI:oMessage:SetMainAlias(cAlias)
   oEasyIntEAI:SetModule(cModulo, nModulo)


   // Envio 
   oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF531SEND") //ENVIO                               (->Business)
   oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF531RESP") //RESPOSTA SOBRE O ENVIO              (<-Response)
   // Envio 

   oEasyIntEAI:Execute()
   
Return oEasyIntEAI:GetResult() 

*------------------------------------------------*
Function AF531SEND(oMessage) 
*------------------------------------------------* 
Local oXml         := EXml():New()
Local oBusiness    := ENode():New()
Local oBusinRequest:= ENode():New() 
Local oRec         := ENode():New()
Local aOrd         := {}
Local cTpMod       := "SISCSV"
Local cBanco     := ""
Local cAgencia   := ""
Local cConta     := ""
Local oCont

//Parcela de câmbio originada pela rotina de câmbio desvinculado (não originado pelo SIGAESS)
If AvFlags("EEC_LOGIX") .And. Empty((cAlias)->EEQ_PROCES)
   cTpMod:= "EXPORT"
EndIf

aOrd := SaveOrd({"EEQ", "EC6"})
If nReg <> 0
   EEQ->(DBGOTO(nReg)) 
EndIf

EC6->(DBSETORDER(1)) //EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
EC6->(DBSEEK(xFilial("EC6")+AVKEY(cTpMod,"EC6_TPMODU")+(cAlias)->EEQ_EVENT))

   oBusinRequest:SetField("Operation", "EECAF531")

   oBusiness:SetField("CompanyId"             ,SM0->M0_CODIGO)
   oBusiness:SetField("BranchId"              ,FWFilial())
   oBusiness:SetField("DocumentPrefix"        ,EC6->EC6_PREFIX)  
   oBusiness:SetField("DocumentNumber"        ,(cAlias)->EEQ_FINNUM)
   oBusiness:SetField("DocumentParcel"        ,RetAsc(Val((cAlias)->EEQ_PARC),1,.T. )) 
   oBusiness:SetField("DocumentTypeCode"      ,EC6->EC6_TPTIT)
   
   If !Empty((cAlias)->EEQ_DTCE)
      oBusiness:SetField('PaymentDate',EasyTimeStamp((cAlias)->EEQ_DTCE, .T. , .T.))
   EndIf  
   
   If !Empty((cAlias)->EEQ_PGT/*dDataCredito*/)
      oBusiness:SetField('CreditDate',EasyTimeStamp((cAlias)->EEQ_PGT, .T. , .T.))
   EndIf
   
   oBusiness:SetField('EntryDate',EasyTimeStamp(dDataBase, .T. , .T.))
   oBusiness:SetField('PaymentValue',Str((cAlias)->(EEQ_VL-EEQ_DESCON)))

   If EEQ->(FieldPos("EEQ_DESCON")) > 0 .And. (cAlias)->EEQ_DESCON <> 0
      oOtherValues := ENode():New()
      oOtherValues:SetField("DiscountValue",(cAlias)->EEQ_DESCON) 
      oBusiness:SetField('OtherValues',oOtherValues)
   EndIf
   
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
   oBusiness:SetField('CustomerCode'          ,(cAlias)->EEQ_IMPORT)
   oBusiness:SetField('StoreId'               ,(cAlias)->EEQ_IMLOJA)
   oBusiness:SetField("PaymentMethod"         ,"006")
   oBusiness:SetField("PaymentMeans"          ,"000")
   
   aPtBxTitFin := EX400BxTFin()
   If aPtBxTitFin[1]  //Utiliza o portador do cadastrado na tabela de Tipos de Financiamento (EF7)
      oBusiness:SetField('HolderCode', aPtBxTitFin[2][1] )
      oBusiness:SetField('HolderType', aPtBxTitFin[2][2] )    
   Else               //Utiliza o portador do cadastrado na conta por banco (ECI)
      oBusiness:SetField('HolderCode',(cAlias)->(EasyHolderCode(EEQ_BANC ,EEQ_AGEN,EEQ_NCON ,EEQ_BANC ,EEQ_AGEN,EEQ_NCON,cTpMod,EEQ_EVENT,EEQ_IMPORT,EEQ_IMLOJA,EEQ_FORN,EEQ_FOLOJA)))
      oBusiness:SetField('HolderType',(cAlias)->(EasyTypeHolder(EEQ_BANC ,EEQ_AGEN,EEQ_NCON ,EEQ_BANC ,EEQ_AGEN,EEQ_NCON,cTpMod,EEQ_EVENT,EEQ_IMPORT,EEQ_IMLOJA,EEQ_FORN,EEQ_FOLOJA))) // "B"
   EndIf
   oBusiness:SetField('FinancialCode',EC6->EC6_NATFIN)

   oDepositData := ENode():New()
   If !Empty((cAlias)->EEQ_PGT)
      oDepositData:SetField('DepositDate',EasyTimeStamp((cAlias)->EEQ_PGT,.T.,.T.))
   EndIf
   oDepositData:SetField('DepositValue',Str((cAlias)->(EEQ_VL-EEQ_DESCON)))//AOM - 26/01/2012
         
   oListOfDepositData := ENode():New()
   oListOfDepositData:SetField("DepositData",oDepositData)   
   
   oBusiness:SetField("ListOfDepositData",oListOfDepositData)
   oBusiness:SetField("DischargeSequence",(cAlias)->EEQ_SEQBX)
   
   oRec:SetField("BusinessRequest",oBusinRequest)// OK
   oRec:SetField("BusinessContent",oBusiness) //  OK
   oXml:AddRec(oRec)
   
RestOrd(aOrd,.T.)

Return oXml

*------------------------------------------------*
Function AF531RESP(oMessage)
*------------------------------------------------*
Local oRetCont  := oMessage:GetRetContent()

EEQ->(DbSetOrder(4))//EEQ_FILIAL + EEQ_NRINVO + EEQ_PREEMB + EEQ_PARC 
If EEQ->(dbSeek(cFilEEQ + cNrInvo + cPreEmb + cParc)) // Posiciona na parcela da invoice
   EEQ->(RECLOCK('EEQ',.F.))
   EEQ->EEQ_SEQBX := EasyGetXMLinfo(,oRetCont, "_DischargeSequence")
   EEQ->(MSUNLOCK())
EndIf

Return oMessage