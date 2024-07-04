#include "average.ch"

/*
Funcao     : EECAF217()
Parametros : Nenhum
Retorno    : .T
Objetivos  : -
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 10/01/2012
*/

Function EECAF217(nOpc)  
Private aRotina   := MenuDef()

If ( (nOpc == 3 .And. ( Empty(EF3->EF3_TITFIN) .Or. Ex400ExcInc() )) .Or. (nOpc == 5 .And. !Empty(EF3->EF3_TITFIN) ) ) .And. EF3->EF3_TPMODU <> "I" //NCF - 22/06/2016 - Não envia Captação de contrato FINIMP
   EasyEnvEAI("EECAF217",nOpc)
EndIf

Return .T.


Static Function MenuDef()

Local aRotina :=  {  { "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","AF217Man" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "AF217Man" , 0 , 3},; //"Incluir"
                     { "Alterar",   "AF217Man" , 0 , 4},; //"Alterar"
                     { "Excluir",   "AF217Man" , 0 , 5,3} } //"Excluir"
                   

Return aRotina  

Function AF217Man(cAlias,nReg,nOpc)

Return Nil

Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI
    
    VarInfo("cXML",cXML)
	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("EF1")
	//oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| EECAT170(oEasyMessage:GetEAutoArray("EE5"),,oEasyMessage:GetOperation(), oEasyMessage:GetEAutoArray("EEK"))} )
	oEasyIntEAI:SetModule("EEC",29)
	
	//*** Recebimento
	//oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "AT171ARECB") //RECEBIMENTO DE BUSINESS MESSAGE     (->Business)
	//oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "AT171ARESB") //RESPOSTA SOBRE O RECEBIMENTO        (<-Response)
	//***
	
	//*** Envio
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF217ASENB") //ENVIO DE BUSINESS MESSAGE           (<-Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF217ARESR") //RESPOSTA SOBRE O ENVIO DA BUSINESS  (->Response)
	//***
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()


Function AF217ASENB(oEasyMessage) 
Local oXml      := EXml():New()
//Local oBusiness := ENode():New()
Local oEvent    := ENode():New()
Local oIdent    := ENode():New()
Local oRec      := ENode():New()
Local oKeyNode, oKeyNode2,oKeyNode3, oKeyNode4, oKeyNode5, oKeyNode6, oKeyNode7
Local cDebitAccount := "" 
Local cCreditAccount := ""
Local cCostCenterCode := ""
Local cBankCode := ""
Local cAgencyNumber := ""
Local cBankAccount := ""
Local cLoteDado := ""
Local cLote := ""
Local cSequencia := ""
Local aOrd := SaveOrd({"EC6"})
Local dMovDate
Local cBanMov := ""
Local cAgMov := ""
Local cCtaMov := ""
Local cLojaFor := ""
Local cEmpMsg := SM0->M0_CODIGO
Local cFilMsg := AvGetM0Fil() 
Local cParam, nPosDiv
Private oBusiness := ENode():New()
 
If !Empty( cParam := Alltrim(EasyGParam("MV_EEC0035",,"")) )
   If (nPosDiv := At('/',cParam)) > 0
      cEmpMsg := Substr(cParam,1,nPosDiv-1) 
      cFilMsg := Substr(cParam,nPosDiv+1,Len(cParam))
   Else
      cEmpMsg := cParam 
      cFilMsg := cParam         
   EndIf  
EndIf

   // Chave - EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE
   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","BranchId"))     // EF3_FILIAL
   oKeyNode:SetField(ETag():New("" ,EF3->EF3_FILIAL))

   oKeyNode2   := ENode():New()
   oKeyNode2:SetField(EAtt():New("name","ModuleType"))    // EF3_TPMODU
   oKeyNode2:SetField(ETag():New("" , EF3->EF3_TPMODU))   
      
   oKeyNode3   := ENode():New()
   oKeyNode3:SetField(EAtt():New("name","ContractNumber"))     // EF3_CONTRA
   oKeyNode3:SetField(ETag():New("" ,EF3->EF3_CONTRA))

   oKeyNode4   := ENode():New()
   oKeyNode4:SetField(EAtt():New("name","ClosureBranch"))    // EF3_BAN_FI
   oKeyNode4:SetField(ETag():New("" , EF3->EF3_BAN_FI))   
   
   oKeyNode5  := ENode():New()
   oKeyNode5:SetField(EAtt():New("name","Market"))     // EF3_PRACA
   oKeyNode5:SetField(ETag():New("" ,EF3->EF3_PRACA))

   oKeyNode6   := ENode():New()
   oKeyNode6:SetField(EAtt():New("name","ContractSequence"))    // EF3_SEQCNT
   oKeyNode6:SetField(ETag():New("" ,EF3->EF3_SEQCNT))   
   
   oKeyNode7   := ENode():New()
   oKeyNode7:SetField(EAtt():New("name","EventCode"))     // EF3_CODEVE
   oKeyNode7:SetField(ETag():New("" ,EF3->EF3_CODEVE))

   oIdent:SetField(ETag():New("key",oKeyNode))
   oIdent:SetField(ETag():New("key",oKeyNode2))
   oIdent:SetField(ETag():New("key",oKeyNode3)) 
   oIdent:SetField(ETag():New("key",oKeyNode4)) 
   oIdent:SetField(ETag():New("key",oKeyNode5))
   oIdent:SetField(ETag():New("key",oKeyNode6)) 
   oIdent:SetField(ETag():New("key",oKeyNode7))

   //<BusinessEvent>
   //   <Entity>Entity</Entity>
        oEvent:SetField("Entity", "EECAF217")
   //   <Event>upsert</Event>
      If Type("nEAIEvent") <> "U" .And. nEAIEvent == 5 //Exclusao
         oEvent:SetField("Event" , "delete")
      Else //Inclusao/Alteracao
         oEvent:SetField("Event" , "upsert")
      EndIf
   //   <Identification></Identification>
        oEvent:SetField("Identification",oIdent)
   //</BusinessEvent>
 
   //<BusinessContent>
   //   <CompanyId>01</CompanyId>
   //     oBusiness:SetField('CompanyId'  ,)
   //   <BranchId>55</BranchId>
   //     oBusiness:SetField('BranchId'   ,)

   //Se o campo EF1_BAN_MO estiver vazio, enviar EF1_BAN_FI, EF1_AGENFI e EF1_NCONFI.
   If !Empty(EF1->EF1_BAN_MO)
      SA6->(dbSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
      SA6->(dbSeek(xFilial("SA6")+EF1->EF1_BAN_MO+EF1->EF1_AGENMO+EF1->EF1_NCONMO))
   
      cBankCode := EF1->EF1_BAN_MO
      cAgencyNumber := AllTrim(EF1->EF1_AGENMO) + If(!Empty(SA6->A6_DVAGE), "-" + AllTrim(SA6->A6_DVAGE), "")
      cBankAccount := AllTrim(EF1->EF1_NCONMO) + If(!Empty(SA6->A6_DVCTA), "-" + AllTrim(SA6->A6_DVCTA), "")
   Else
      SA6->(dbSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
      SA6->(dbSeek(xFilial("SA6")+EF1->EF1_BAN_MO+EF1->EF1_AGENMO+EF1->EF1_NCONMO))
      
      cBankCode := EF1->EF1_BAN_FI
      cAgencyNumber := AllTrim(EF1->EF1_AGENFI) + If(!Empty(SA6->A6_DVAGE), "-" + AllTrim(SA6->A6_DVAGE), "") 
      cBankAccount := AllTrim(EF1->EF1_NCONFI) + If(!Empty(SA6->A6_DVCTA), "-" + AllTrim(SA6->A6_DVCTA), "") 
   EndIf

   oBusiness:SetField('CompanyId' , cEmpMsg)
   oBusiness:SetField('BranchId'  , cFilMsg)

   //   <Bank>
   oBankType := ENode():New()
   //      <BankCode>BankCode</BankCode> 
           oBankType:SetField('BankCode'          ,cBankCode)
   //      <AgencyNumber>AgencyNumber</AgencyNumber>
           oBankType:SetField('AgencyNumber'      ,cAgencyNumber)
   //      <BankAccount>BankAccount</BankAccount>
           oBankType:SetField('BankAccount'       ,cBankAccount)
   //   </Bank>
   oBusiness:SetField('Bank' ,oBankType)
   //   <MovementDate>2001-01-01</MovementDate>
        /*If !Empty(EF1->EF1_DT_JUR)
		   dMovDate := EF1->EF1_DT_JUR
        Else*/If !Empty(EF3->EF3_DT_EVE)
		   dMovDate := EF3->EF3_DT_EVE
        Else
		   dMovDate := dDataBase
		EndIf
        oBusiness:SetField('MovementDate'         ,EasyTimeStamp(dMovDate, .T. , .T.))
   //   <EntryValue>0.0</EntryValue>
        oBusiness:SetField('EntryValue'           ,Str(EF3->EF3_VL_REA))
   //   <MovementType>1</MovementType>
        oBusiness:SetField('MovementType'         ,"2") // Tipo de Movimento 1-Débito, 2-Crédito

   If EF1->EF1_TP_FIN $ "01/02/03" //ACC/ACE/PRE
      If !Empty(EF3->EF3_BANC)
         cBanMov := EF3->EF3_BANC
         cAgMov := EF3->EF3_AGEN
         cCtaMov := EF3->EF3_NCON
      ElseIf !Empty(EF1->EF1_BAN_MO)
         cBanMov := EF1->EF1_BAN_MO
         cAgMov := EF1->EF1_AGENMO
         cCtaMov := EF1->EF1_NCONMO
      Else
         cBanMov := EF1->EF1_BAN_FI
         cAgMov := EF1->EF1_AGENFI
         cCtaMov := EF1->EF1_NCONFI
      EndIf
   EndIf 
   
   If Type("lAvLoja") == "L" .And. lAvLoja
      cLojaFor := EF3->EF3_LOJAFO
   EndIf
   
   EC6->(dbSetOrder(1))// EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
   If EC6->(dbSeek(xFilial("EC6")+"FI"+IIF(EF3->EF3_TPMODU=="E","EX","IM")+EF3->EF3_TP_EVE+EF3->EF3_CODEVE)) //iif(EF1->EF1_TPMODU <> "I","FIEX","FIIM")+ EF1->EF1_TP_FIN
      cDebitAccount :=  EasyMascCon( EC6->EC6_CTA_DB,EF3->EF3_FORN,cLojaFor,"","",cBanMov,cAgMov,cCtaMov,iif(EF1->EF1_TPMODU <> "I","FIEX","FIIM")+ EF1->EF1_TP_FIN,EF3->EF3_CODEVE)
      cCreditAccount :=  EasyMascCon( EC6->EC6_CTA_CR,EF3->EF3_FORN,cLojaFor,"","",cBanMov,cAgMov,cCtaMov,iif(EF1->EF1_TPMODU <> "I","FIEX","FIIM")+ EF1->EF1_TP_FIN,EF3->EF3_CODEVE)
      cCostCenterCode := EC6->EC6_CCUSTO
   EndIf
   
   oAppDistribution := ENode():New()
   oApportionment := ENode():New()
   //   <ApportionmentDistribution>
   //      <Apportionment>
   //         <DebitAccount>DebitAccount</DebitAccount>
              oApportionment:SetField('DebitAccount'       ,cDebitAccount)
   //         <CreditAccount>CreditAccount</CreditAccount>
              oApportionment:SetField('CreditAccount'      ,cCreditAccount)
   //         <CostCenterCode>CostCenterCode</CostCenterCode>
              oApportionment:SetField('CostCenterCode'     ,cCostCenterCode)
   //      </Apportionment>
   //   </ApportionmentDistribution>
   oAppDistribution:SetField('Apportionment' ,oApportionment)
   oBusiness:SetField('ApportionmentDistribution' ,oAppDistribution)
   
   //   <HistoryCode>HistoryCode</HistoryCode>
        oBusiness:SetField('HistoryCode'          ,EC6->EC6_COD_HI)
   //   <ComplementaryHistory>ComplementaryHistory</ComplementaryHistory>
        oBusiness:SetField('ComplementaryHistory' ,EC6->EC6_COM_HI)
   //   <DocumentType>1</DocumentType>
        oBusiness:SetField('DocumentType'         ,"2") // Tipo de Documento 1-DB Débito, 2-CR Crédito, 3-DP Duplicata, 4-CH Cheque
   //   <DocumentNumber>DocumentNumber</DocumentNumber>
        oBusiness:SetField('DocumentNumber'       ,EF1->EF1_CONTRA)

   If Type("nEAIEvent") == "N" .And. nEAIEvent <> 3
      cLoteDado := EF3->EF3_TITFIN
      cLote := SubStr(cLoteDado,1,AvSX3("EF3_TITFIN",AV_TAMANHO)/2)
      cSequencia := Right(cLoteDado,AvSX3("EF3_TITFIN",AV_TAMANHO)/2)
   EndIf
   
   If !Empty(cLote)
      oBusiness:SetField('BatchNumber'          ,cLote)
   EndIf
   If !Empty(cSequencia)
      oBusiness:SetField('BatchSequence'        ,cSequencia)
   EndIf
        
   If EasyEntryPoint("EECAF217")
      ExecBlock("EECAF217", .f., .f., "MSG_CAPT_CONTRATO_ALTERA_DADOS_TAGS")
   Endif   

   //</BusinessContent>
   oRec:SetField('BusinessEvent'  ,oEvent)
   oRec:SetField('BusinessContent',oBusiness) 
   oXml:AddRec(oRec)

   RestOrd(aOrd,.T.)

Return oXml

*-------------------------------------------------*
Function AF217ARESR(oEasyMessage) 
*-------------------------------------------------*
Local oBusinessCont  := oEasyMessage:GetRetContent()
Local oBusinessEvent := oEasyMessage:GetEvtContent():_IDENTIFICATION
Local oBsnEvent := oEasyMessage:GetEvtContent()                      //NCF - 02/12/2014 
Local cBranchId := "" 
Local cModuleType := "" 
Local cContractNumber := "" 
Local cClosureBranch := "" 
Local cMarket := "" 
Local cContractSequence := "" 
Local cEventCode := "" 
Local cTitFin := ""
Local cNumber := ""
Local cSequence := ""
Local aOrd := SaveOrd({"EF1","EF3"}) 

   If !(ValType(oBusinessEvent:_Key) == "A")
      aKey := {oBusinessEvent:_Key}
   Else
      aKey := oBusinessEvent:_Key
   EndIf

   // Chave - EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE
   aEval(aKey,  {|x| If(x:_NAME:Text == "BranchId", cBranchId := x:TEXT,) })
   aEval(aKey,  {|x| If(x:_NAME:Text == "ModuleType", cModuleType := x:TEXT,) }) 
   aEval(aKey,  {|x| If(x:_NAME:Text == "ContractNumber", cContractNumber := x:TEXT,) }) 
   aEval(aKey,  {|x| If(x:_NAME:Text == "ClosureBranch", cClosureBranch := x:TEXT,) }) 
   aEval(aKey,  {|x| If(x:_NAME:Text == "Market", cMarket := x:TEXT,) }) 
   aEval(aKey,  {|x| If(x:_NAME:Text == "ContractSequence", cContractSequence := x:TEXT,) }) 
   aEval(aKey,  {|x| If(x:_NAME:Text == "EventCode", cEventCode := x:TEXT,) }) 

   cNumber := EasyGetXMLinfo(, oBusinessCont, "_BatchNumber")
   cSequence :=  EasyGetXMLinfo(, oBusinessCont, "_BatchSequence") 
   If ValType(cNumber) == "C" .And. ValType(cSequence) == "C"
      //cTitFin := cNumber + Replic("0",AVSX3("EF3_TITFIN",3)-Len(cNumber)-Len(cSequence)) + cSequence
      cTitFin := Str(Val(cNumber),AvSX3("EF3_TITFIN",AV_TAMANHO)/2)+Str(Val(cSequence),AvSX3("EF3_TITFIN",AV_TAMANHO)/2)
   EndIf
   cEvento := EasyGetXMLinfo(, oBsnEvent, "_Event")
   EF3->(DbSetOrder(1)) //EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE+EF3_PARC+EF3_INVOIC+EF3_INVIMP+EF3_LINHA
   If EF3->(DbSeek(AvKey(cBranchId,"EF3_FILIAL")+AvKey(cModuleType,"EF3_TPMODU")+AvKey(cContractNumber,"EF3_CONTRA")+AvKey(cClosureBranch,"EF3_BAN_FI")+AvKey(cMarket,"EF3_PRACA")+AvKey(cContractSequence,"EF3_SEQCNT")+AvKey(cEventCode,"EF3_CODEVE")))                                                             
      If AllTrim(Upper(cEvento)) == "UPSERT"
         Begin Transaction
            EF3->(RecLock("EF3",.F.)) 
            EF3->EF3_TITFIN := cTitFin
            EF3->(MsUnlock())  
         End Transaction
         oEasyMessage:AddInList("RECEIVE", {"Sucesso" , "Registro Gravado no Destino" , Nil})
      ElseIf AllTrim(Upper(cEvento)) == "DELETE"
         Begin Transaction
            EF3->(RecLock("EF3",.F.)) 
            EF3->EF3_TITFIN := ""
            EF3->(MsUnlock())  
         End Transaction      
      EndIf
   Else
      oEasyMessage:AddInList("RECEIVE", {"Erro" , "Registro não encontrada no Destino" , Nil})
   EndIf

   RestOrd(aOrd,.T.)

Return oEasyMessage
