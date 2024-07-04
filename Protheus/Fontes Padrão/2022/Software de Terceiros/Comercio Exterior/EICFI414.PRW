#INCLUDE "Average.ch"
#INCLUDE "EICFI414.ch" 

/*
Programa : EICFI414.PRW
Objetivo : Integração EAI para  para integração da devolução de adiantamento ao despachante.
Autor    : Maurício Frison 
Data     : 11/08/17
Revisão  : 
Obs.     :  
*/
*--------------------------------------------------------------------
Function EICFI414()
*--------------------------------------------------------------------
LOCAL lOk:= .T.
Local lBaixou:= .F.
Private nSldVlLiq:= 0
Private nVlCompens:= 0

                                            //MFR CRIAR UM STR
      
      MsAguarde({|| lOk:= EasyEnvEAI("EICFI414")}, STR0001)//" rever criar arquivo ch Integração EAI - Gerando a devolução de adiantamento ao despachante. Aguarde..."
      If lOk
         lBaixou:= .T.
      EndIf
   
Return lOk .Or. lBaixou


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
	
	oEasyIntEAI:oMessage:SetVersion("1.001")
	oEasyIntEAI:oMessage:SetMainAlias("SWD")
	oEasyIntEAI:SetModule("EIC",17)

	// Envio 
   //MFR 15/08/2017 TE-5660	
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "FI414SEND") //ENVIO                               (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "FI414RESP") //RESPOSTA SOBRE O ENVIO              (<-Response)
	// Envio 

	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult() 

/* ====================================================*
* Função: AP110SEND(oMessage)
* Objetivo: Envio das parcelas de Cambio
* Obs: 
* =====================================================*/
*------------------------------------------------*
Function FI414SEND(oMessage) 
*------------------------------------------------* 
Local oXml             := EXml():New()
Local oBusiness        := ENode():New()
Local oRequest := ENode():New() 
Local oRec             := ENode():New()
Local aOrd             := {}
Local cBanco  := ""
Local cAgencia:= ""
Local cConta  := ""
Local cMotBx  := "014" //mfr
Local cCodERP := ""
Local cMoeda  := "R$"
Local cEvento := ""
aOrd := SaveOrd({"SYB","EC6","SYF"}) 
EC6->(DBSETORDER(1))//EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
SYF->(DBSETORDER(1))//YF_FILIAL+YF_MOEDA  
SYB->(DBSETORDER(1))

SYB->(DBSEEK(xFilial("SYB")+M->WD_DESPESA))

//Evento contábil default - assumirá os eventos abaixo se não houver outra informada no cadastro da despesa
cEvento:= SYB->YB_EVENT
If Empty(cEvento)
   If M->WD_DESPESA == "901"//Se for adiantamento de despesa, evento 151 (carga padrão no programa EICNU400)
      cEvento:= "151"
   Else //se for despesa efetiva
      cEvento:= "320"
   EndIf
EndIf

EC6->(DBSEEK(xFilial("EC6")+"IMPORT" + cEvento))

//<BusinessEvent>

   //Entity e Event
   oRequest:SetField("Operation", "EICFI414")
//capa
//<BusinessContent>
   oBusiness:SetField("CompanyId"          ,EICEmpFLogix())
   oBusiness:SetField("BranchId"           ,EICFilFLogix())
   
   oBusiness:SetField("DocumentPrefix"     ,EC6->EC6_PREFIX)  
   oBusiness:SetField("DocumentNumber"     ,M->WD_CTRFIN1)
   oBusiness:SetField("DocumentParcel"     ,"")
   oBusiness:SetField("DocumentTypeCode"   ,EC6->EC6_TPTIT)
   oBusiness:SetField("PaymentDate"        ,EasyTimeStamp(dDataBase,.T.,.T.))
   oBusiness:SetField("PaymentValue"       ,M->WD_VALOR_R)

   If SYF->(DBSeek(xFilial("SYF") + AvKey(cMoeda, "YF_MOEDA")))
      If EC6->EC6_TXCV == "2"
         cCodERP:= SYF->YF_CODCERP
      Else
         cCodERP:= SYF->YF_CODVERP
      EndIf
   EndIf
      
   oBusiness:SetField("CurrencyCode", cCodERP)
   oBusiness:SetField("CurrencyRate", 1)
   oBusiness:SetField("VendorCode"  ,M->WD_FORN)
   oBusiness:SetField("StoreId"     ,SWD->WD_LOJA)
   
   oBusiness:SetField("PaymentMethodCode"  ,cMotBx)
   oBusiness:SetField("PaymentMeans"       ,"000")
   
   //<Bank>
   oBank:=ENode():New()

      //complemento dos dados bancários
      cBanco	:= M->WD_BANCO
      cAgencia	:= M->WD_AGENCIA
      cConta	:= M->WD_CONTA
       
      SA6->(DBSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
      If SA6->(DBSeek(xFilial() + M->WD_BANCO + M->WD_AGENCIA + M->WD_CONTA))

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

   oBusiness:SetField("Bank"      ,oBank)     
   //</Bank>                     
   
   oBusiness:SetField("FinancialCode"     ,EC6->EC6_NATFIN)  
   oBusiness:SetField("HistoryText"       ,"")

   
   oRec:SetField("BusinessRequest"  ,oRequest)// OK
   oRec:SetField("BusinessContent",oBusiness) //  OK
   oXml:AddRec(oRec)
   
RestOrd(aOrd,.t.)

Return oXml


/* ====================================================*\
* Função: FI414RESP(oMessage)                          *
* Objetivo: Resposta do Envio                          *
* Obs:                                                 *
\* ====================================================*/
*------------------------------------------------*
Function FI414RESP(oMessage)
*------------------------------------------------*
Local oRetCont:= oMessage:GetRetContent()
Local aOrd:= SaveOrd({"SWD"})

oProInformation:=oRetCont

/* número da última sequência de baixa ocorrida com sucesso do lado Logix */
M->WD_CTRFIN2 := EasyGetXMLinfo( ,oProInformation,"_DischargeSequence" )  

RestOrd(aOrd, .T.)
Return oMessage
