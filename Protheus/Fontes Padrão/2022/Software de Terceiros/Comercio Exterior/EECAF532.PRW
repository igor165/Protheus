#INCLUDE "Average.ch"
/*
Programa : EECAF532.PRW
Autor    : Alessandro Alves Ferreira
Data     : 01/10/2014
Objetivo : Estorno da Baixa de Titulos de Invoice de Serviço a Receber
Uso      : 
*/
*---------------------------
Function EECAF532(cTab,nOpc)
*---------------------------
LOCAL lOk      := .T.
PRIVATE cAlias := cTab
Private cFilEEQ := (cAlias)->EEQ_FILIAL,;
        cPreEmb := (cAlias)->EEQ_PREEMB,;
        cNrInvo := (cAlias)->EEQ_NRINVO,;
        cParc   := (cAlias)->EEQ_PARC 

If Type("lMsErroAuto") == "L" .And. lMsErroAuto
   oAvObjEAI := AvObject():New()
EndIf

If !Empty((cAlias)->EEQ_FINNUM) .And. !Empty((cAlias)->EEQ_SEQBX)
   lOk:= EasyEnvEAI("EECAF532",nOpc)
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
   oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF532SEND") //ENVIO                               (->Business)
   oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF532RESP") //RESPOSTA SOBRE O ENVIO              (<-Response)
   // Envio 

   oEasyIntEAI:Execute()
   
Return oEasyIntEAI:GetResult() 

*------------------------------------------------*
Function AF532SEND(oMessage) 
*------------------------------------------------* 
Local oXml         := EXml():New()
Local oBusiness    := ENode():New()
Local oBusinRequest:= ENode():New() 
Local oRec         := ENode():New()
Local aOrd         := {}
Local cTpMod       := "SISCSV"

//Parcela de câmbio originada pela rotina de câmbio desvinculado (não originado pelo SIGAESS)
If AvFlags("EEC_LOGIX") .And. Empty((cAlias)->EEQ_PROCES)
   cTpMod:= "EXPORT"
EndIf

aOrd := SaveOrd({"EEQ", "EC6"}) 
If nReg <> 0  //AHAC - 11/08/2014 - RecNo Private em EECAF500 - Origem da Chamada
   EEQ->(DBGOTO(nReg)) 
EndIf
EC6->(DBSETORDER(1)) //EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
EC6->(DBSEEK(xFilial("EC6")+AVKEY(cTpMod,"EC6_TPMODU")+(cAlias)->EEQ_EVENT))

//<BusinessRequest>
   oBusinRequest:SetField("Operation", "EECAF532")
//</BusinessRequest>

//<BusinessContent>
   oBusiness:SetField("CompanyId"             ,SM0->M0_CODIGO)
   oBusiness:SetField("BranchId"              ,FWFilial())
   oBusiness:SetField("DocumentPrefix"        ,EC6->EC6_PREFIX)  
   oBusiness:SetField("DocumentNumber"        ,(cAlias)->EEQ_FINNUM)
   oBusiness:SetField("DocumentParcel"        ,RetAsc( Val((cAlias)->EEQ_PARC),1,.T. )) 
   oBusiness:SetField("DocumentTypeCode"      ,EC6->EC6_TPTIT)
   oBusiness:SetField("DischargeSequence"     ,(cAlias)->EEQ_SEQBX)
//<BusinessContent>

oRec:SetField("BusinessRequest",oBusinRequest)// OK
oRec:SetField("BusinessContent",oBusiness) //  OK
oXml:AddRec(oRec)
   
RestOrd(aOrd,.t.)

Return oXml

*------------------------------------------------*
Function AF532RESP(oMessage)
*------------------------------------------------*

   EEQ->(DbSetOrder(4))//EEQ_FILIAL + EEQ_NRINVO + EEQ_PREEMB + EEQ_PARC 
   If EEQ->(dbSeek(cFilEEQ + cNrInvo + cPreEmb + cParc)) // Posiciona na parcela da invoice
      EEQ->(RECLOCK('EEQ',.F.))
      EEQ->EEQ_SEQBX := ""
      EEQ->(MSUNLOCK())
   EndIf

Return oMessage
