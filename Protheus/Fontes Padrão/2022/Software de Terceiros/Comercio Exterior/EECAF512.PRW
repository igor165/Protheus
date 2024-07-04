#INCLUDE "Average.ch"
/*
Programa : EECAF512.PRW
Autor    : Alan Henrique Almeida da Costa - AHAC 
Data     : 11/07/14
Objetivo : Estorno da liquidação da Parcela de Invoice
Uso      : Integração do Easy Siscoserv com Logix via WebService - EF TDE_REQ9.0_ESS - Projeto Proposta 140117
*/
*--------------------------------------------------------------------
Function EECAF512(cTab,nOpc)
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

lOk:= EasyEnvEAI("EECAF512",nOpc)

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
   
   oEasyIntEAI:oMessage:SetVersion("1.0")
   oEasyIntEAI:oMessage:SetMainAlias(cAlias)
   oEasyIntEAI:SetModule("ESS",85)

   // Envio 
   oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF512SEND") //ENVIO                               (->Business)
   oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF512RESP") //RESPOSTA SOBRE O ENVIO              (<-Response)
   // Envio 

   oEasyIntEAI:Execute()
   
Return oEasyIntEAI:GetResult() 

/* ====================================================*
* Função: AF512SEND(oMessage)
* Objetivo: Envio das parcelas da Invoice - SIGAESS
* Obs: 
* =====================================================*/
*------------------------------------------------*
Function AF512SEND(oMessage) 
*------------------------------------------------* 
Local oXml         := EXml():New()
Local oBusiness    := ENode():New()
Local oBusinRequest:= ENode():New() 
Local oRec         := ENode():New()
Local aOrd         := {}
Local cTpMod       := "EXPORT"

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
   oBusinRequest:SetField("Operation", "EECAF512")
//</BusinessRequest>

//<BusinessContent>
   oBusiness:SetField("CompanyId"             ,SM0->M0_CODIGO)
   oBusiness:SetField("BranchId"              ,FWFilial())
   oBusiness:SetField("DocumentPrefix"        ,EC6->EC6_PREFIX)  
   oBusiness:SetField("DocumentNumber"        ,(cAlias)->EEQ_FINNUM)
   oBusiness:SetField("DocumentParcel"        ,(cAlias)->EEQ_PARC) 
   oBusiness:SetField("DocumentTypeCode"      ,EC6->EC6_TPTIT)
   oBusiness:SetField("VendorCode"            ,(cAlias)->EEQ_FORN)
   oBusiness:SetField("StoreId"               ,(cAlias)->EEQ_FOLOJA)
   oBusiness:SetField("DischargeSequence"     ,(cAlias)->EEQ_SEQBX)
//<BusinessContent>

oRec:SetField("BusinessRequest",oBusinRequest)// OK
oRec:SetField("BusinessContent",oBusiness) //  OK
oXml:AddRec(oRec)
   
RestOrd(aOrd,.t.)

Return oXml

/* ====================================================*\
* Função: AF512RESP(oMessage)                          *
* Objetivo: Resposta do Envio                          *
* Obs:                                                 *
\* ====================================================*/
*------------------------------------------------*
Function AF512RESP(oMessage)
*------------------------------------------------*

   EEQ->(DbSetOrder(4))//EEQ_FILIAL + EEQ_NRINVO + EEQ_PREEMB + EEQ_PARC 
   If EEQ->(dbSeek(cFilEEQ + cNrInvo + cPreEmb + cParc)) // Posiciona na parcela da invoice
      EEQ->(RECLOCK('EEQ',.F.))
      EEQ->EEQ_SEQBX := ""
      EEQ->(MSUNLOCK())
   EndIf

Return oMessage
