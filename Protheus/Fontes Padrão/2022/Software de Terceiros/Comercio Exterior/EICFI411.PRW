#INCLUDE "Average.ch"
#INCLUDE "EICFI411.ch"

/*
Programa : EICFI411.PRW
Objetivo : Integração EAI para geração de títulos efetivos de despesas nacionais
Autor    : igor chiba 
Data     : 03/07/14
Revisão  :
Obs.     : 
*/

*--------------------------------------------------------------------
Function EICFI411(cTab,nOpc,lLiberacao)
*--------------------------------------------------------------------
LOCAL lOk         := .T.
DEFAULT lLiberacao:= .F.
PRIVATE cAlias    := cTab      
PRIVATE nRecnoSWD := SWD->(RECNO())
PRIVATE lPrest    := lLiberacao
//MFR 15/08/2017 TE-5660
Private cDespesa


Begin Sequence

   IF cAlias = "SWD" .AND. TYPE("aForDesp") = "A"
      nRecnoSWD := aForDesp[1,3]
   ENDIF

   /* Verificação de cadastros relacionados obrigatórios para execução da integração. */
   If !FI411Valid()
      lOk:= .F.
      Break
   EndIf
   
   //MFR 15/08/2017 TE-5660
   // MsAguarde({|| lOk:= EasyEnvEAI("EICFI411",nOpc)}, STR0001)//"Integração EAI - Despesas. Aguarde..."
   If cDespesa == "903" .and. EasyFindAdpt("EICFI414")        
                                                        //CRIAR UM STR          
      MsAguarde({|| lOk:= EasyEnvEAI("EICFI414",nOpc)}, STR0004)//"Integração EAI - Devolução de adiantamento ao despachante. Aguarde..."
   else
      MsAguarde({|| lOk:= EasyEnvEAI("EICFI411",nOpc)}, STR0001)//"Integração EAI - Despesas. Aguarde..."
   EndIf

End Sequence

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

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.000")
	oEasyIntEAI:oMessage:SetMainAlias("SWD")
	oEasyIntEAI:SetModule("EIC",17)

	// Envio 
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "FI411SEND") //ENVIO                               (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "FI411RESP") //RESPOSTA SOBRE O ENVIO              (<-Response)
	// Envio 

	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult() 

/* ====================================================*
* Função: AP110SEND(oMessage)
* Objetivo: Envio das parcelas de Cambio
* Obs: 
* =====================================================*/
*------------------------------------------------*
Function FI411SEND(oMessage) 
*------------------------------------------------* 
Local oXml       := EXml():New()
Local oBusiness  := ENode():New()
Local oBusinEvent:= ENode():New() 
Local oIdent     := ENode():New()  
Local oRec       := ENode():New()
Local oListOfAccountPayable
Local oTaxes, oTax, oAttributes
Local aOrd       := {}
Local lAchou     := .F.
Local nI
Local cEvento   := ""
Local cBanco    := ""
Local cAgencia  := ""
Local cConta    := ""
Local lSA6      := .F.
Local cPago     := ""
Local cBaseAd   := ""
Local cCodERP:= ""
Local cMoeda := "R$"
Local lISS   := .F.

aOrd := SaveOrd({"SYB","EC6","SYF","SW9","SA6","SYT"}) 
EC6->(DBSETORDER(1))//EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
SYF->(DBSETORDER(1))//YF_FILIAL+YF_MOEDA  
SYB->(DBSETORDER(1))//YB_FILIAL+YB_DESP
SA6->(DBSetOrder(1))//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
SW9->(DBSetOrder(3))//W9_FILIAL+W9_HAWB
SYT->(DBSetOrder(1))//YT_FILIAL+YT_COD_IMP
SW6->(DBSetOrder(1))//W6_FILIAL+W6_HAWB

IF cAlias =='M'
   cHawb   := M->WD_HAWB
   nValorR := M->WD_VALOR_R
   cDespesa:= M->WD_DESPESA
ELSE
   cHawb   := (cAlias)->WD_HAWB
   nValorR := (cAlias)->WD_VALOR_R
   cDespesa:= (cAlias)->WD_DESPESA
ENDIF
      
SYB->(DBSEEK(xFilial("SYB")+cDespesa))
SW6->(DBSeek(xFilial() + cHawb))
SYT->(DBSeek(xFilial() + SW6->W6_IMPORT))

//Evento contábil default - assumirá os eventos abaixo se não houver outra informada no cadastro da despesa
cEvento:= SYB->YB_EVENT
If Empty(cEvento)
   If cDespesa == "901"//Se for adiantamento de despesa, evento 151 (carga padrão no programa EICNU400)  
      cEvento:= "151"
   Else //se for despesa efetiva
      cEvento:= "320"
   EndIf
EndIf   
                                      
EC6->(DBSeek(xFilial() + AvKey("IMPORT", "EC6_TPMODU") + AvKey(cEvento, "EC6_ID_CAM")))
lISS:= !Empty(EC6->EC6_NATURE)

//<BusinessEvent>

  //Entity e Event
  oBusinEvent:SetField("Entity", "EICFI411")

  oBusinEvent:SetField("Event" , IF(nEAIEvent <> 5,"upsert","delete"))

  //<Identification>

     oKeyNode:= ENode():New()
     oKeyNode:SetField(EAtt():New("name","expense"))
     oKeyNode:SetField(ETag():New("",cDespesa + "-" + SYB->YB_DESCR))
     oIdent:SetField(ETag():New("key",oKeyNode))

     oKeyNode:= ENode():New()
     oKeyNode:SetField(EAtt():New("name","Process"))
     oKeyNode:SetField(ETag():New("",cHawb))
     oIdent:SetField(ETag():New("key",oKeyNode))

     oKeyNode:= ENode():New()
     oKeyNode:SetField(EAtt():New("name","IssueDate"))
     oKeyNode:SetField(ETag():New("",IF(cAlias =='M',M->WD_DES_ADI,(cAlias)->WD_DES_ADI)))
     oIdent:SetField(ETag():New("key",oKeyNode))

     /* ISS:
        Quando o campo EC6_NATURE estiver preenchido com o código LOGIX que corresponde tipo
        de valor (ou ajuste financeiro), este conteúdo será transmitido na tax TaxCode. */
     If lISS  
        oKeyNode:= ENode():New()
        oKeyNode:SetField(EAtt():New("name", "TaxCode"))
        oKeyNode:SetField(ETag():New("", EC6->EC6_NATURE))
        oIdent:SetField(ETag():New("key", oKeyNode))
     EndIf
     
  //<Identification>

  oBusinEvent:SetField("Identification",oIdent)

//<BusinessEvent>

//capa
//<BusinessContent>
   oBusiness:SetField("CompanyId"             ,EICEmpFLogix())
   oBusiness:SetField("CompanyInternalId"     ,EICEmpFLogix())
   oBusiness:SetField("BranchId"              ,EICFilFLogix())
   oBusiness:SetField("batchNumber"           ,"")//Não utilizado
   
   //ListOfAccountPayableDocument
   oListOfAccountPayable := ENode():New()
   
      oAccountPayable := ENode():New()
      oAccountPayable:SetField("InternalId"            ,0)
      oAccountPayable:SetField("DocumentPrefix"        ,EC6->EC6_PREFIX)  
      oAccountPayable:SetField("DocumentNumber"        ,IF(cAlias =='M',M->WD_CTRFIN1,(cAlias)->WD_CTRFIN1))
      oAccountPayable:SetField("DocumentParcel"        ,1)
      oAccountPayable:SetField("DocumentTypeCode"      ,EC6->EC6_TPTIT)
   
      cPago:= IF(cAlias =='M',M->WD_PAGOPOR,(cAlias)->WD_PAGOPOR )   //PAGO POR DESPACHANTE ENVIAR BLOQUEADO
      cBaseAd:= IF(cAlias =='M',M->WD_BASEADI,(cAlias)->WD_BASEADI )   //Base de Adiantamento

      IF cPago == '1' .AND. !lPrest .And. cBaseAd == "1" //PAGO POR DESPACHANTE E NÃO É LIBERACAO e é base de adiantamento
         oAccountPayable:SetField("BlockAmendmentDocument", "B")
      ElseIf cPago == '1' .And. lPrest 
         oAccountPayable:SetField("BlockAmendmentDocument", "X")
      Else   
         oAccountPayable:SetField("BlockAmendmentDocument", "L")
      ENDIF
   
      //<ListOfSourceDocument>
         oListSrcDoc := ENode():New()
         //<SourceDocument>
              oSourcDoc := ENode():New()
              oSourcDoc:SetField("SourceDocument",cHawb)
         //</SourceDocument>
         oListSrcDoc:SetField("SourceDocument",oSourcDoc)
      oAccountPayable:SetField("ListOfSourceDocument",oListSrcDoc)
      //</ListOfSourceDocument>                          
   
      oAccountPayable:SetField("IssueDate"   ,EasyTimeStamp(IF(cAlias =='M',M->WD_DES_ADI,(cAlias)->WD_DES_ADI),.T.,.T.))
      oAccountPayable:SetField("DueDate"     ,EasyTimeStamp(IF(cAlias =='M',M->WD_DT_VENC,(cAlias)->WD_DT_VENC),.T.,.T.))
      oAccountPayable:SetField("RealDueDate" ,EasyTimeStamp(IF(cAlias =='M',DataValida(M->WD_DT_VENC),DataValida((cAlias)->WD_DT_VENC)),.T.,.T.))
      oAccountPayable:SetField("VendorCode"  ,IF(cAlias =='M',M->WD_FORN   ,(cAlias)->WD_FORN))
      oAccountPayable:SetField("VendorInternalId"  ,IF(cAlias =='M',M->WD_FORN   ,(cAlias)->WD_FORN))
      oAccountPayable:SetField("StoreId"     ,IF(cAlias =='M',M->WD_LOJA   ,(cAlias)->WD_LOJA))
      oAccountPayable:SetField("NetValue"    ,nValorR)
      oAccountPayable:SetField("GrossValue"  ,nValorR)

      lAchou := SYF->(DBSeek(xFilial("SYF") + cMoeda))
      IF lAchou
         IF EC6->EC6_TXCV == "2"
            cCodERP:= SYF->YF_CODCERP
         ELSE
            cCodERP:= SYF->YF_CODVERP
         ENDIF
      ENDIF                                                
   
      oAccountPayable:SetField("CurrencyCode", cCodERP)
      oAccountPayable:SetField("CurrencyInternalId",cMoeda)
      oAccountPayable:SetField("CurrencyRate", 1)
   
      //ISS
      If lISS
         oTaxes:= ENode():New()
            oTax:= ENode():New()
               oAttributes:= ENode():New()
               oAttributes:SetField("Taxe", "ISS")
               oAttributes:SetField("CityCode", SYT->YT_CODMUN )
            oTax:SetField("Attributes", oAttributes)
         oTaxes:SetField("Tax", oTax)
         oAccountPayable:SetField("Taxes", oTaxes)
      EndIf
      
      nQtDec := AVSX3('WD_VALOR_R',4)
      // TEM INVOICE
      IF SW9->(DBSEEK(XFILIAL('SW9')+cHawb))
         nTotInv:= 0                                                              
         aValCC := LC500RatCC(XFILIAL('SW8'),cHawb,'','',nQtDec,       ,      ,@nTotInv       ,'SW8') //PRIMEIRA VEZ VAI RETORNAR UM ARRAY DAS INVOICES POR CC
         aValCC := LC500RatCC(XFILIAL('SW8'),cHawb,'','',nQtDec,nValorR,aValCC,nTotInv        ,'SW8') //RATEAR O VALOR DA DEPSA POR CC
      ELSE 
         aValCC := LC500RatCC(XFILIAL('SW7'),cHawb,'','',      ,       ,      ,               ,'SW7') //PRIMEIRA VEZ VAI RETORNAR UM ARRAY DO FOB ITEM POR CC                                                                                  
         aValCC := LC500RatCC(XFILIAL('SW7'),cHawb,'','',nQtDec,nValorR,aValCC,SW6->W6_FOB_TOT,'SW7') //RATEAR O VALOR DA DEPSA POR CC                                                                                   
      ENDIF

      IF LEN(aValCC) <> 0
         oAppDistri := ENode():New()
         For nI:=1 to len(aValCC)         
         //<ApportionmentDistribution>
            //<Apportionment>
               oApportionment:= ENode():New()
               oApportionment:SetField("CostCenterInternalId",aValCC[nI][1]) //CostCenterCode
               oApportionment:SetField("Value"         ,aValCC[nI][2])
            //</Apportionment>
            oAppDistri:SetField("Apportionment",oApportionment)
         //</ApportionmentDistribution>
         Next
         oAccountPayable:SetField("ApportionmentDistribution",oAppDistri)   
      EndIf
   
      IF AllTrim(cDespesa) == "901"
      //<Bank>
         If cAlias == "M"
            lSA6:= SA6->(DBSeek(xFilial() + M->WD_BANCO + M->WD_AGENCIA + M->WD_CONTA))
            cBanco  := M->WD_BANCO
            cAgencia:= M->WD_AGENCIA
            cConta  := M->WD_CONTA
         Else
            lSA6:= SA6->(DBSeek(xFilial() + (cAlias)->WD_BANCO + (cAlias)->WD_AGENCIA + (cAlias)->WD_CONTA))
            cBanco  := (cAlias)->WD_BANCO
            cAgencia:= (cAlias)->WD_AGENCIA
            cConta  := (cAlias)->WD_CONTA
         EndIf
      
         If lSA6
            If !Empty(SA6->A6_DVAGE)
               cAgencia:= AllTrim(cAgencia) + "-" + SA6->A6_DVAGE 
            EndIf

            If !Empty(SA6->A6_DVCTA)
               cConta:= AllTrim(cConta) + "-" + SA6->A6_DVCTA 
            EndIf
         EndIf
            
         oBank:=ENode():New()

         oBank:SetField("BankCode"   ,cBanco)
         oBank:SetField("BankAgency" ,cAgencia)      
         oBank:SetField("BankAccount",cConta)
         
         oAccountPayable:SetField("Bank"      ,oBank)     
      //</Bank>                     
      ENDIF   
 
      cObs := "Processo: " + ALLTRIM(cHawb)+ " - Despesa: " + cDespesa + "-" + SYB->YB_DESCR
      oAccountPayable:SetField("Observation", IF(!Empty(cObs), cObs, ""))
      oAccountPayable:SetField("Origin"     , "SIGAEIC")

      IF EC6->(FIELDPOS("EC6_NATFIN")) <> 0 .AND. !EMPTY(EC6->EC6_NATFIN)
         oAccountPayable:SetField("FinancialNatureInternalId" ,EC6->EC6_NATFIN) //FinancialCode
      ENDIF
      
      oListOfAccountPayable:SetField("AccountPayableDocument", oAccountPayable)
   //ListOfAccountPayableDocument
      
   oBusiness:SetField("ListOfAccountPayableDocument", oListOfAccountPayable)
      
oRec:SetField("BusinessEvent"  ,oBusinEvent)// OK
oRec:SetField("BusinessContent",oBusiness) //  OK
oXml:AddRec(oRec)
   
RestOrd(aOrd,.t.)

Return oXml


/* ====================================================*\
* Função: FI411RESP(oMessage)                          *
* Objetivo: Resposta do Envio                          *
* Obs:                                                 *
\* ====================================================*/
*------------------------------------------------*
Function FI411RESP(oMessage)
*------------------------------------------------*
Local oRetCont       := oMessage:GetRetContent()
Local oBusinessEvent := oMessage:GetEvtContent()      
Local cEvento        := Upper(EasyGetXMLinfo(,oBusinessEvent,"_Event"))
            
IF ALLTRIM(cEvento) <> 'DELETE'
   oProInformation:=oRetCont:_ListOfInternalIdDocument:_InternalIdDocument 
   IF cAlias == 'M'
      M->WD_CTRFIN1 := EasyGetXMLinfo('WD_CTRFIN1' ,oProInformation  , "_Destination" )
      M->WD_VLLIQ   := EasyGetXMLinfo('WD_VLLIQ'   ,oProInformation , "_Value" )
   ELSEIF nRecnoSWD # 0
      SWD->(DBGOTO(nRecnoSWD))
      SWD->(RECLOCK('SWD',.F.))
      SWD->WD_CTRFIN1 := EasyGetXMLinfo('WD_CTRFIN1' ,oProInformation , "_Destination" )
      SWD->WD_VLLIQ   := EasyGetXMLinfo('WD_VLLIQ'   ,oProInformation , "_Value" )
      SWD->(MSUNLOCK())
   ENDIF
ENDIF

Return oMessage


/*
Função   : FI411Valid()
Objetivo : Verificação dos dados obrigatórios dos cadastros relacionados para realização da integração 
Autor    : wfs 
Data     : abr/2015
Revisão  :
Obs.     : 
*/
Function FI411Valid()
Local lRet:= .T.
Local cEvento
//Local cDespesa, cEvento
Local aOrd:= SaveOrd({"EC6", "SYB"})

Begin Sequence

   EC6->(DBSetOrder(1)) //EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
   SYB->(DBSetOrder(1)) //YB_FILIAL+YB_DESP
   
   If cAlias == 'M'
      cDespesa:= M->WD_DESPESA
   Else  
      cDespesa:= (cAlias)->WD_DESPESA
   EndIf   

   SYB->(DBSeek(xFilial() + cDespesa))

   //Evento contábil default - assumirá os eventos abaixo se não houver outra informada no cadastro da despesa
   cEvento:= SYB->YB_EVENT
   If Empty(cEvento)
      If cDespesa == "901"//Se for adiantamento de despesa, evento 151 (carga padrão no programa EICNU400)  
         cEvento:= "151"
      Else //se for despesa efetiva
         cEvento:= "320"
      EndIf
   EndIf   

   EC6->(DBSeek(xFilial() + AvKey("IMPORT", "EC6_TPMODU") + AvKey(cEvento, "EC6_ID_CAM")))

   If EC6->(FieldPos("EC6_NATFIN")) == 0 .Or. Empty(EC6->EC6_NATFIN)
      MsgStop(StrTran(StrTran(STR0003, "####", AvSx3("EC6_NATFIN", AV_TITULO)), "$$$$", cEvento), STR0002) //"O tipo de despesa do ERP para a geração do título no financeiro não foi informado. Verifique o campo '####' do cadastro de Eventos Contábeis, evento IMPORT $$$$.", "Atenção"
      lRet:= .F.
      Break
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return lRet
