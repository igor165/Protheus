#INCLUDE "Average.ch"
#Include "EICAP111.ch"
/*
Programa  : EICAP111.PRW
Objetivo  : Realizar a baixa/ compensação do título financeiro
Autor     : Jacomo 
Data      : 25/06/2014
Parametros: lEnvio  = se .T. indica se irá enviar o XML, .F. indica que será recebimento
Uso       : 
*/
*--------------------------------------------------------------------*
Function EICAP111(lEnvio,nOpc,cHawb,nRecnoTRB,cTabAlias,cTipo,lVal,nRecComp)
*--------------------------------------------------------------------*  
Local   lOk      :=.F.
Default cTabAlias:='SWB'
Default cTipo    := ""  
Default lVal     := .F.
Private nRec     := 0                         
Private cAlias   := cTabAlias
Private nCompParc:= nRecComp 
Private lAdiantPO:=  .F.

If Empty(cTipo)
   lAdiantPO:=  .T.
EndIf

SWB->(DBSETORDER(1))
IF lEnvio
   IF VALTYPE(nRecnoTRB) == "N" .AND. nRecnoTRB <> 0 .OR. cTabAlias == "TRB"
      //SWB->(DBGOTO(nRecnoTRB))
      nRec := nRecnoTRB
      lOk  := ProcIntegracao(nOpc) //EasyEnvEAI("EICAP111",nOpc)
   ELSE
      SWB->(DBSEEK(xFilial("SWB")+cHawb+"D"))
      DO WHILE SWB->(!EOF()) .AND. SWB->WB_FILIAL == xFilial("SWB") .AND. SWB->WB_HAWB == cHawb .AND. SWB->WB_PO_DI == "D"  
         IF (!EMPTY(cTipo)) .AND. Left(SWB->WB_TIPOREG,1) <> cTipo
            SWB->(DBSKIP())
            LOOP
         ENDIF
         IF lVal .AND. AvFlags("EAI_PGANT_INV_NF") .AND.;
            ( SWB->WB_EVENT <> "608" .OR. ( SWB->WB_EVENT == "608" .AND. (!EMPTY(SWB->WB_NUMDUP)) .AND. (!EMPTY(SWB->WB_SEQBX)) ) )
            SWB->(DBSKIP())
            LOOP
         ENDIF
         nRec := SWB->(RECNO())
         lOk  := ProcIntegracao(nOpc) //EasyEnvEAI("EICAP111",nOpc) 
         SWB->(DBSKIP())
      ENDDO
   ENDIF
ENDIF

/*Atualização de status do processo de embarque/ desembaraço*/
AP110AtuStatus(cHawb)

RETURN lOk     

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
	
	oEasyIntEAI:oMessage:SetVersion("1.001")
	oEasyIntEAI:oMessage:SetMainAlias("SWB")
	oEasyIntEAI:SetModule("EIC",17)

	// Envio 
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AP111SEND") //ENVIO                               (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AP111RESP") //RESPOSTA SOBRE O ENVIO              (<-Response)
	// Envio 

	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult() 
/* ====================================================*
* Função: AP110SEND(oMessage)
* Objetivo: Envio das parcelas de Cambio
* Obs: 
* =====================================================*/
*------------------------------------------------*
Function AP111SEND(oMessage) 
*------------------------------------------------* 
Local oXml       := EXml():New()
Local oBusCont   := ENode():New()
Local oBusinReq  := ENode():New() 
Local oRec       := ENode():New()
Local aOrd       := {}
Local oCont
Local cBanco     := ""
Local cAgencia   := ""
Local cConta     := ""
Local nRecOld    := 0

aOrd := SaveOrd({"SWA","SWB","SW2","EC6","SYF","SW6","SW9"}) 

//Muda pra parcela compensada (101)
If Type("nCompParc") == "N" .AND. nCompParc > 0
   nRecOld := TRB->(RecNo())
   TRB->(dbGoTo(nCompParc))
EndIf

EC6->(DBSETORDER(1))//EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
EC6->(DBSEEK(xFilial("EC6")+"IMPORT"+IF((cAlias)->WB_EVENT == "608","101",(cAlias)->WB_EVENT) ))

   
oBusinReq:SetField("Operation"   ,"EICAP111")

oBusCont:SetField("CompanyId"         ,EICEmpFLogix())
oBusCont:SetField("BranchId"          ,EICFilFLogix())
oBusCont:SetField("DocumentPrefix"    ,EC6->EC6_PREFIX)
oBusCont:SetField("DocumentNumber"    ,(cAlias)->WB_NUMDUP)
oBusCont:SetField("DocumentParcel"    ,(cAlias)->WB_PARCELA)
oBusCont:SetField("DocumentTypeCode"  ,EC6->EC6_TPTIT)

//Muda pra parcela da vinculação do adiantamento (TIPOREG = "P")


   IF SYF->(DBSEEK(xFilial("SYF")+(cAlias)->WB_MOEDA)) .AND. EC6->EC6_TXCV = "2"
      cCodERP := SYF->YF_CODCERP
   ELSE
      cCodERP := SYF->YF_CODVERP
   ENDIF
   lSeek    :=  SW9->(DBSEEK(xFilial("SW9")+(cAlias)->WB_INVOICE+(cAlias)->WB_FORN+(cAlias)->WB_LOJA+(cAlias)->WB_HAWB ))

   If Type("nCompParc") == "N" .AND. nCompParc > 0
      TRB->(dbGoTo(nRecOld))
   EndIf

   dPayDate := dDataBase //(cAlias)->WB_CA_DT
   nTaxa := (cAlias)->WB_CA_TX
   IF (cAlias)->WB_EVENT == "608" .AND. Left((cAlias)->WB_TIPOREG,1) == "P" .AND. AvFlags("EAI_PGANT_INV_NF") .AND. lSeek
      nTaxa    := SW9->W9_TX_FOB
      dPayDate := Posicione("SW6",1,xFilial("SW6")+SW9->W9_HAWB,"W6_DT_NF")
   ELSEIF Left((cAlias)->WB_TIPOREG,1) == "P" .AND. !AvFlags("EAI_PGANT_INV_NF")
      If lSeek .And. !lAdiantPO
         nTaxa    := BuscaTaxa((cAlias)->WB_MOEDA,SW9->W9_DT_EMIS,,.F.,,,EC6->EC6_TXCV)
         dPayDate := SW9->W9_DT_EMIS
      EndIf
      If lAdiantPO .And. ((cAlias)->WB_EVENT == "609" .Or. (cAlias)->WB_PO_DI $ "A/F/C") //na compensação, considerar a data base como data da movimentação
         dPayDate := dDataBase
         nTaxa := (cAlias)->WB_CA_TX
      EndIf
   ELSE
      dPayDate := (cAlias)->WB_CA_DT
      nTaxa := (cAlias)->WB_CA_TX
   ENDIF
   
   oBusCont:SetField("PaymentDate"       ,EasyTimeStamp(dPayDate,.T.,.T.) )
   oBusCont:SetField("PaymentValue"      ,IF(Left((cAlias)->WB_TIPOREG,1) == "P", (cAlias)->WB_PGTANT, (cAlias)->WB_FOBMOE) )
   oBusCont:SetField("CurrencyCode"      ,cCodERP)
   oBusCont:SetField("CurrencyRate"      ,nTaxa)
   oBusCont:SetField("VendorCode"        ,(cAlias)->WB_FORN)
   oBusCont:SetField("StoreId"           ,(cAlias)->WB_LOJA)
   oBusCont:SetField("PaymentMethodCode" ,"004")
   oBusCont:SetField("PaymentMeans"      ,"000")

   oBank:=ENode():New()
     
      //WFS 29/08/2014 - complemento dos dados bancários
      cBanco:= (cAlias)->WB_BANCO
      cAgencia:= (cAlias)->WB_AGENCIA
      cConta:= (cAlias)->WB_CONTA
       
      SA6->(DBSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
      If SA6->(DBSeek(xFilial() + (cAlias)->WB_BANCO + (cAlias)->WB_AGENCIA + (cAlias)->WB_CONTA))

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
      
   oBusCont:SetField("Bank"      ,oBank)     
 
   IF EC6->(FIELDPOS("EC6_NATFIN")) <> 0 .AND. !EMPTY(EC6->EC6_NATFIN)
      oBusCont:SetField("FinancialCode" ,EC6->EC6_NATFIN)
   ENDIF
   
   oBusCont:SetField("HistoryText"       ,"")

   oCont    := ENode():New()
   oCont:SetField("DocumentPrefix"      ,""           )
   oCont:SetField("DocumentNumber"      ,(cAlias)->WB_CA_NUM)

   oBusCont:SetField('PaymentDocument',oCont)       
   oBusCont:SetField("DischargeSequence" ,"1")   
   
   IF (cAlias)->WB_EVENT <> "608" .AND. Left((cAlias)->WB_TIPOREG,1) <> "P" .AND. (!EMPTY((cAlias)->WB_TPBXFI)) 
     oAdjust:= ENode():New()
     oAdjust:SetField("CodeValueAdjustment",(cAlias)->WB_TPBXFI)  
     oAdjust:SetField("ValueAdjustment"    ,(cAlias)->WB_FOBMOE)  
     oBusCont:SetField("Adjustment"        ,oAdjust)   
  ENDIF
  IF (cAlias)->WB_EVENT == "608" .OR. Left((cAlias)->WB_TIPOREG,1) == "P"
     oCompens:= ENode():New()
     oCompens:SetField("CompensationValuesAdvance",IF(Left((cAlias)->WB_TIPOREG,1) == "P", (cAlias)->WB_PGTANT, (cAlias)->WB_FOBMOE ))  
	 
	 If Type("nCompParc") == "N" .AND. nCompParc > 0
        nRecWB := SWB->({IndexOrd(),RecNo()})
		SWB->(dbSetOrder(1))
	    
		SWB->(DBSEEK(xFilial("SWB")+TRB->WB_NUMPO+Work1->WA_PO_DI/*"A"*/))
        Do While SWB->( !Eof()  .And.  WB_FILIAL+WB_HAWB+WB_PO_DI == xFilial("SWB")+Work1->WB_NUMPO+Work1->WA_PO_DI/*"A"*/ )
           If SWB->WB_LINHA == TRB->WB_LINHA
              Exit
           EndIf
           SWB->( DBSkip() )
        EndDo
        		
		oCompens:SetField("DocumentNumber",SWB->WB_NUMDUP )
	    
		SWB->(dbSetOrder(nRecWB[1]),dbGoTo(nRecWB[2]))
     Else
	    oCompens:SetField("DocumentNumber",(cAlias)->WB_TITADI )
	 EndIf
	 
	 oComp:= ENode():New()
	 oComp:SetField("Compensation",oCompens)
     oBusCont:SetField("ListOfCompensation",oComp)   
  ENDIF

oRec:SetField("BusinessRequest",oBusinReq)// OK
oRec:SetField("BusinessContent",oBusCont) //  OK
oXml:AddRec(oRec)

RestOrd(aOrd,.t.)

Return oXml


/* ====================================================*\
* Função: AP110RESP(oMessage)                          *
* Objetivo: Resposta do Envio                          *
* Obs:                                                 *
\* ====================================================*/
*------------------------------------------------*
Function AP111RESP(oMessage)
*------------------------------------------------*
Local oRetCont       := oMessage:GetRetContent()
Local aOrd := SaveOrd({"SWB"}) 
Local cSeq := ""           

IF cAlias  == 'SWB'
   SWB->(DBGOTO(nRec))
   SWB->(RecLock("SWB",.F.))
ENDIF

IF IsCpoInXML(oRetCont, "_DischargeSequence")
   cSeq  := EasyGetXMLinfo("WB_SEQBX",oRetCont, "_DischargeSequence" )//Numero do Documento retornado pelo ERP
ENDIF
(cAlias)->WB_SEQBX := cSeq
IF cAlias  == 'SWB'
   SWB->(MSUNLOCK())
ENDIF

oMessage:AddInList("RECEIVE", {"Sucesso" , "Registro Gravado no Destino" , Nil})

RestOrd(aOrd,.t.)
Return oMessage

/*
Funcao      : ProcIntegracao
Parâmetros  : nOpc - operação (inclusão/ alteração/ exclusão)
Objetivos   : Executar a integração com o MsAguarde
Retorno     : Lógico: integrado/ não integrado
Autor       : WFS
Data 	     : 01/2015
Obs         :
Revisão     :
*/
Static Function ProcIntegracao(nOpc)
Local lRet:= .F.
   MsAguarde({|| lRet:= EasyEnvEAI("EICAP111", nOpc)}, STR0001) //"Integração EAI - Baixa do título financeiro. Aguarde..."
Return lRet
