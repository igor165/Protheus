#INCLUDE "Average.ch"
#Include "EICFI413.ch"
/*
Programa : EICFI413.PRW
Objetivo : Integração EAI para estorno da compensação do adiantamento contra o efetivo - despesas
           nacionais (prestação de contas)
Autor    : igor chiba 
Data     : 03/07/14
Revisão  : WFS - 02/2015
           Implementação do estorno de acordo com a sequencia de baixa, considerando
           a partir da última baixa para a primeira.
           abr/2015
           Tratamento para estornar todas os adiantamento usados para baixa.
           Se ao menos um adiantamento não for estornado, não deve permitir a exclusão do efetivo.
Obs.     : 
*/

*--------------------------------------------------------------------
Function EICFI413()
*--------------------------------------------------------------------
LOCAL lOk:= .F.
Local lEstornou:= .T.

ADIANT->(AvSeekLast(M->WD_DESPESA))
While !ADIANT->(Bof()) .And. ADIANT->WD_DESPESA == M->WD_DESPESA
   If ADIANT->WD_CTRFIN1 == M->WD_CTRFIN1
      MsAguarde({|| lOk:= EasyEnvEAI("EICFI413")}, STR0001) //"Integração EAI - Estorno da baixa. Aguarde...")
      /* Se todos os estornos não forem concluídos, o título incluído pela rotina de prestação de contas 
         não deve ser excluído. */ 
      If !lOk .And. lEstornou
         lEstornou:= .F.
      EndIf
   EndIf
   ADIANT->(DBSkip(-1))
EndDo

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
//Local cAlias:="SWD"

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("SWD")
	oEasyIntEAI:SetModule("EIC",17)

	// Envio 
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "FI413SEND") //ENVIO                               (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "FI413RESP") //RESPOSTA SOBRE O ENVIO              (<-Response)
	// Envio 

	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult() 

/* ====================================================*
* Função: AP110SEND(oMessage)
* Objetivo: Envio das parcelas de Cambio
* Obs: 
* =====================================================*/
*------------------------------------------------*
Function FI413SEND(oMessage) 
*------------------------------------------------* 
Local oXml       := EXml():New()
Local oBusiness  := ENode():New()
Local oRequest   := ENode():New() 
Local oRec       := ENode():New()
Local aOrd       := {}

aOrd := SaveOrd({"SYB","EC6","SYF", "SWD"}) 
EC6->(DBSETORDER(1))//EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
SYF->(DBSETORDER(1))//YF_FILIAL+YF_MOEDA  
SYB->(DBSETORDER(1))
SWD->(DBSetOrder(1)) //WD_FILIAL+WD_HAWB+WD_DESPESA+DTOS(WD_DES_ADI)

SYB->(DBSEEK(xFilial("SYB")+SWD->WD_DESPESA))
EC6->(DBSEEK(xFilial("EC6")+"IMPORT"+SYB->YB_EVENT))

SWD->(DBSeek(xFilial() + M->WD_HAWB + M->WD_DESPESA + DTOS(M->WD_DES_ADI)))
//<BusinessEvent>

  //Entity e Event
  oRequest:SetField("Operation", "EICFI413")

//<BusinessEvent>

//capa
//<BusinessContent>
   oBusiness:SetField("CompanyId"             ,EICEmpFLogix())
   oBusiness:SetField("BranchId"              ,EICFilFLogix())
   oBusiness:SetField("DocumentPrefix"        ,EC6->EC6_PREFIX)  
   oBusiness:SetField("DocumentNumber"        ,SWD->WD_CTRFIN1)
   oBusiness:SetField("DocumentParcel"        ,"")
   oBusiness:SetField("DocumentTypeCode"      ,EC6->EC6_TPTIT)
   oBusiness:SetField("VendorCode"            ,SWD->WD_FORN)
   oBusiness:SetField("StoreId"               ,SWD->WD_LOJA)
   oBusiness:SetField("DischargeSequence"     ,ADIANT->WK_SEQBX)

   oRec:SetField("BusinessRequest",oRequest)// OK
   oRec:SetField("BusinessContent",oBusiness) //  OK
   oXml:AddRec(oRec)
   
RestOrd(aOrd,.t.)

Return oXml

/* ====================================================*\
* Função: FI413RESP(oMessage)                          *
* Objetivo: Resposta do Envio                          *
* Obs:                                                 *
\* ====================================================*/
*------------------------------------------------*
Function FI413RESP(oMessage)
*------------------------------------------------*
CA150ESTPREST()
Return oMessage
