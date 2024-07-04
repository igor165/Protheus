// EECAF212 - Inclusao de adiantamento(001) - Exclusao de adiantamento(002) - Alteracao de adiantamento(003)
#include "average.ch"


Function EECAF212(nOpc)
Private aRotina   := MenuDef()
//Private lRecall   := .F.

   //Só permite inclusão de título ou exclusao se não estiver baixado. Não é possível alterar título no Logix devido a contabilização, só altera quando alterada a data de embarque.
   If (nOpc == 3 .AND. ( ( Empty(EEQ->EEQ_FINNUM) .OR.  Type("cEvDtEmba") == "C" .AND. cEvDtEmba == "073" ) .OR.;
                          !Empty(EEQ->EEQ_FINNUM) .AND. IsInCallStack("AF200GParc")) ).OR.;
      nOpc == 5 .AND. !Empty(EEQ->EEQ_FINNUM) .AND. If( Type("lAF212EsBxAuto") == "L" .And. lAF212EsBxAuto , !Empty(EEQ->EEQ_SEQBX) , Empty(EEQ->EEQ_SEQBX) ) //Empty(EEQ->EEQ_SEQBX) /*.AND. EEQ->EEQ_PARC == EEQ->EEQ_PARVIN*/
                                                    //NCF - 15/05/2015 - Permitir estornar baixa automaticamente para adiantamentos via ativação da flag
      EasyEnvEAI("EECAF212",nOpc)
   EndIf

Return .T.

Static Function MenuDef()

Local aRotina :=  {  { "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","AF212MAN" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "AF212MAN" , 0 , 3},; //"Incluir"
                     { "Alterar",   "AF212MAN" , 0 , 4},; //"Alterar"
                     { "Excluir",   "AF212MAN" , 0 , 5} } //"Excluir"                  

Return aRotina

Static Function AF212MAN()
Return Nil 

/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: Bruno Akyo Kubagawa
* Data: 19/01/2011 - 15:00 hs 
* =====================================================*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("EEQ")
	//oEasyIntEAI:oMessage:SetMenu(MenuDef())//VER
	//oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| EECAE100(oEasyMessage:GetEAutoArray("EEQ"),, oEasyMessage:GetOperation())} )

	oEasyIntEAI:SetModule("EEC",29)
	
	// Recebimento
	//oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "AF210ARECB") //RECEBIMENTO DE BUSINESS
	//oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "AF210ARESB") //RESPONDE BUSINESS RECEBIDA
	//
	// Envio
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF212ASENB") //Envio de Business
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF212ARESR")	//Rebimento de retorno da Business Enviada
	//
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()

*------------------------------------------------*
Function AF212ASENB(oEasyMessage) 
*------------------------------------------------* 
Local oXml      := EXml():New()
Local oRec      := ENode():New()
Local oBusiness := ENode():New()
//Local aArray    := EECRatItEmb(EEQ->EEQ_PREEMB,EEQ->EEQ_VL)
Local oEvent    := ENode():New()
Local oIdent    := Enode():New()
Local oKeyNode, oCost, oDistr, oSD, oSDT
Local cEmpMsg := SM0->M0_CODIGO
Local cFilMsg := AvGetM0Fil() 
Local cParam, nPosDiv
 
If !Empty( cParam := Alltrim(EasyGParam("MV_EEC0033",,"")) )
   If (nPosDiv := At('/',cParam)) > 0
      cEmpMsg := Substr(cParam,1,nPosDiv-1) 
      cFilMsg := Substr(cParam,nPosDiv+1,Len(cParam))
   Else
      cEmpMsg := cParam 
      cFilMsg := cParam         
   EndIf  
EndIf

   EC6->(dbSetOrder(1))//EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM
   EC6->(dbSeek(xFilial()+'EXPORT'+EEQ->EEQ_EVENT))

   If RecLock("EEQ",.F.) .AND. Empty(EEQ->EEQ_FINNUM) // GFP - 23/02/2012
      EEQ->EEQ_PREFIX := EC6->EC6_PREFIX
      EEQ->EEQ_TPTIT  := EC6->EC6_TPTIT
   EndIf

    oKeyNode   := ENode():New()
    oKeyNode:SetField(EAtt():New("name","DocumentPrefix"))     //PREFIXO
    oKeyNode:SetField(ETag():New("" ,EEQ->EEQ_PREFIX))

    oKeyNode2   := ENode():New()
    oKeyNode2:SetField(EAtt():New("name","DocumentNumber"))    //NUMERO
    oKeyNode2:SetField(ETag():New("" , EEQ->EEQ_FINNUM))
    
    oKeyNode3   := ENode():New()
    oKeyNode3:SetField(EAtt():New("name","DocumentParcel"))    //PARCELA
    oKeyNode3:SetField(ETag():New("" ,/*RetAsc( Val(EEQ->EEQ_PARC),1,.T. )*/"1" )) //NCF - 16/05/2016 - Para adiantamentos, o número da parcela é crescente para o Cliente e por 
                                                                                   //                   este motivo na parcela 37 em diante o sistema começa a transformar em caracteres
    oKeyNode4   := ENode():New()                                                   //                   não suportados pelo ENCODE UTF-8 além de limitar o range até a parcela 99 pois o 
    oKeyNode4:SetField(EAtt():New("name","DocumentTypeCode"))  //TIPO              //                   XSD da mensagem na versão desta integração (1_000) limita o tamanho da parcela à 1.     
    oKeyNode4:SetField(ETag():New("" ,EEQ->EEQ_TPTIT))
    
    oKeyNode5   := ENode():New()
    oKeyNode5:SetField(EAtt():New("name","Process"))  //TIPO
    oKeyNode5:SetField(ETag():New("" ,EEQ->EEQ_PREEMB))

    oIdent:SetField(ETag():New("key",oKeyNode))
    oIdent:SetField(ETag():New("key",oKeyNode2)) 
    oIdent:SetField(ETag():New("key",oKeyNode3))
    oIdent:SetField(ETag():New("key",oKeyNode4))
    oIdent:SetField(ETag():New("key",oKeyNode5))    

    oEvent:SetField("Entity", "EECAF212")
    
    If Type("nEAIEvent") <> "U"  
       If nEAIEvent == 3
          oEvent:SetField("Event" ,"upsert" )
       ElseIf nEAIEvent == 5
          oEvent:SetField("Event" ,"delete" )
       EndIf
    Else
       oEvent:SetField("Event" , "error")
    EndIf
    
    oEvent:SetField("Identification",oIdent)

//<BusinessContent>
//	<CompanyId>99</CompanyId>
   oBusiness:SetField('CompanyId'       ,cEmpMsg)
//	<BranchId>01</BranchId>
   oBusiness:SetField('BranchId'        ,cFilMsg)
//	<DocumentPrefix>EEC</DocumentPrefix>
   oBusiness:SetField('DocumentPrefix'     ,EEQ->EEQ_PREFIX)
//	<DocumentNumber>000000022</DocumentNumber>
//   If !Empty(EEQ->EEQ_FINNUM)
      oBusiness:SetField('DocumentNumber'     ,EEQ->EEQ_FINNUM)

      cHolderCode := EasyHolderCode(EEQ->EEQ_BANC ,EEQ->EEQ_AGEN,EEQ->EEQ_NCON ,EEQ->EEQ_BANC ,EEQ->EEQ_AGEN,EEQ->EEQ_NCON,"EXPORT",EEQ->EEQ_EVENT,EEQ->EEQ_IMPORT,EEQ->EEQ_IMLOJA,EEQ->EEQ_FORN,EEQ->EEQ_FOLOJA,"B")
      cHolderType := EasyTypeHolder(EEQ->EEQ_BANC ,EEQ->EEQ_AGEN,EEQ->EEQ_NCON ,EEQ->EEQ_BANC ,EEQ->EEQ_AGEN,EEQ->EEQ_NCON,"EXPORT",EEQ->EEQ_EVENT,EEQ->EEQ_IMPORT,EEQ->EEQ_IMLOJA,EEQ->EEQ_FORN,EEQ->EEQ_FOLOJA,"B")
      If ! Empty(cHolderCode) .and. ! Empty(cHolderType)
            oBusiness:SetField('HolderCode', cHolderCode )
            oBusiness:SetField('HolderType', cHolderType )
      EndIf

//	<DocumentParcel>1</DocumentParcel>
   oBusiness:SetField('DocumentParcel'     ,RetAsc( Val(IF(!Empty(EEQ->EEQ_PARVIN), EEQ->EEQ_PARVIN, EEQ->EEQ_PARC)), 1 ,.T. ) )
//	<DocumentTypeCode/>
   oBusiness:SetField('DocumentTypeCode'   ,EEQ->EEQ_TPTIT)
//	<Situation>001</Situation>
   oBusiness:SetField('Situation'          ,"001")
// 	<IssueDate>2012-01-18</IssueDate>
   //If !Empty(EEC->EEC_DTEMBA)
      oBusiness:SetField('IssueDate'       ,If(nEAIEvent <> 5, EasyTimeStamp(EEQ->EEQ_PGT, .T., .T.), EasyTimeStamp(EEQ->EEQ_DTCE, .T., .T.) ) )       
   //EndIf
//	<DiscountDate></DiscountDate>
    /*If !Empty(EEQ->EEQ_VCT)
       oBusiness:SetField('DiscountDate'       ,EasyTimeStamp(DataValida(EEQ->EEQ_VCT, .T.), .T., .T.))
    EndIf*/
//	<DiscountPercentage>0</DiscountPercentage>
//   oBusiness:SetField('DiscountPercentage' ,"0")
//	<DueDate>2012-01-18</DueDate>    
   //If !Empty(EEQ->EEQ_HVCT)
      //oBusiness:SetField('DueDate'         ,EasyTimeStamp(DataValida(Min(Max(EEQ->EEQ_HVCT,EEQ->EEQ_PGT),EEQ->EEQ_VCT), .T.), .T., .T.))
	  oBusiness:SetField('DueDate'         ,EasyTimeStamp(DataValida(EEQ->EEQ_PGT, .T.), .T., .T.))
   //EndIf
//	<ExtendedDate>2012-01-18</ExtendedDate>
   //If !Empty(EEQ->EEQ_VCT) 
      //oBusiness:SetField('ExtendedDate'    ,EasyTimeStamp(DataValida(EEQ->EEQ_VCT, .T.), .T., .T.))
	  oBusiness:SetField('ExtendedDate'    ,EasyTimeStamp(DataValida(EEQ->EEQ_PGT, .T.), .T., .T.))
   //EndIf
//	<AccountingDate></AccountingDate>
//   oBusiness:SetField('AccountingDate'   ,)
//	<ChargeInterest>false</ChargeInterest>
   oBusiness:SetField('ChargeInterest'     ,"false")
//	<CustomerCode>000001</CustomerCode>
   oBusiness:SetField('CustomerCode'       ,EEQ->EEQ_IMPORT)   
//	<StoreId>01</StoreId>
   oBusiness:SetField('StoreId'            ,EEQ->EEQ_IMLOJA)
//	<CustomerBankCode></CustomerBankCode>
   oBusiness:SetField('CustomerBankCode'   ,EEQ->EEQ_BANC)  
//	<NetValue>90000</NetValue>
   oBusiness:SetField('NetValue'           ,STR(EEQ->EEQ_VL-EEQ->EEQ_CGRAFI))
//	<GrossValue>90000</GrossValue>
   oBusiness:SetField('GrossValue'         ,STR(EEQ->EEQ_VL-EEQ->EEQ_CGRAFI))
//	<InvoiceAmount>90000</InvoiceAmount>
   oBusiness:SetField('InvoiceAmount'      ,STR(EEQ->EEQ_VL))
//	<CurrencyCode></CurrencyCode>
   SYF->(dbSetOrder(1))  //YF_FILIAL+YF_MOEDA
   SYF->(dbSeek(xFilial()+EEQ->EEQ_MOEDA))
   If EC6->EC6_TXCV == "2" //COMPRA 
   	  oBusiness:SetField('CurrencyCode'    ,SYF->YF_CODCERP)
   Else //VENDA
      oBusiness:SetField('CurrencyCode'    ,SYF->YF_CODVERP)
   EndIf
//	<CurrencyRate>1.5</CurrencyRate>    
   //oBusiness:SetField('CurrencyRate'       ,STR(BuscaTaxa(EEQ->EEQ_MOEDA,EEC->EEC_DTEMBA,,.F.,,,EC6->EC6_TXCV)))
   oBusiness:SetField('CurrencyRate'       ,EEQ->EEQ_TX)
//	<Taxes></Taxes>    
//	<ApportionmentDistribution>
//		<Apportionment>
//			<CostCenterCode/>
   //For i := 1 To Len(aArray)
      oCost     := ENode():New()
      oDistr    := ENode():New()
      oCost:SetField("CostCenterCode"      ,EasyGParam("MV_AVG0210",,""))
//			<Value>75000</Value>        
      oCost:SetField("Value"               ,EEQ->EEQ_VL)
//			<FinancialCode></FinancialCode>
//      oCost:SetField("FinancialCode"      ,)
//		</Apportionment>
      oDistr:SetField('Apportionment',oCost)
   //Next i
   //If !Empty(aArray)
      oBusiness:SetField('ApportionmentDistribution',oDistr)
   //EndIf
//	</ApportionmentDistribution>
//	<Observation/>
   oBusiness:SetField('Observation'        ,EEQ->EEQ_OBS)
//	<ListOfSourceDocument>
//		<SourceDocument>
   oSDT    := ENode():New()
   //If EEC->(FieldPos("EEC_CODERP")) > 0 
      oSD    := ENode():New()
//			<SourceDocument>NF - LOGI</SourceDocument>
      oSD:SetField('SourceDocument'            ,EEQ->EEQ_IMPORT)
//			<SourceDocumentSerie></SourceDocumentSerie>
//			<SourceDocumentSubSerie></SourceDocumentSubSerie>
//			<SourceDocumentTypeCode>XP</SourceDocumentTypeCode>
      oSD:SetField('SourceDocumentTypeCode'    ,EasyGParam("MV_AVG0205",,"XP"))
//			<SourceDocumentValue>90000</SourceDocumentValue>
      oSD:SetField('SourceDocumentValue'       ,EEQ->EEQ_VL)
//		</SourceDocument>
      oSDT:SetField('SourceDocument'           ,oSD)
//	</ListOfSourceDocument>
   //EndIf
   
   oBusiness:SetField('ListOfSourceDocument',oSDT)
//	<Origin>EEC</Origin>
   oBusiness:SetField('Origin'     ,"EEC") 
//</BusinessContent>

   oRec:SetField('BusinessEvent'  ,oEvent)
   oRec:SetField('BusinessContent',oBusiness) 
   oXml:AddRec(oRec)
   
   If FindFunction("SetDataInt")
      SetDataInt( {"EECAF212", EEQ->(Recno())} )
   EndIf
    
Return oXml

/*========================================================================================
Funcao Adapter: AF212ARESR
Parametros    : "oMessage" - Objeto XML com conteúdo da tag "BusinessContent" recebida                
Objetivos     : RECEBER uma RESPONSE (apos envio de BUSINNES) e gravar arquivo 
Autor         : Bruno Akyo Kubagawa - BAK
Data/Hora     : 18/01/2012
Revisao       : 
Obs.          : 
==========================================================================================*/
*------------------------------------------------*
Function AF212ARESR(oEasyMessage) 
*------------------------------------------------* 
Local oBusinessCont  := oEasyMessage:GetRetContent()
Local oBusinessEvent := oEasyMessage:GetEvtContent()
Local cPrefixo := "", cNumero := "", cTipo := "", cPREEMB := "", cParcela := "", cEvento := ""
Local aOrdEEQ := SaveOrd({"EEQ"}) 
Local nRecPrc := 0
Local nPosAdp := 0
Local aDadosRcp 

   If ValType(oBusinessEvent:_IDENTIFICATION:_KEY) <> "A"
      aKey := {oBusinessEvent:_IDENTIFICATION:_KEY}
   Else
      aKey := oBusinessEvent:_IDENTIFICATION:_KEY
   EndIf
   
   aEval(aKey, {|x| If(Upper(Alltrim(x:_NAME:Text)) == "DOCUMENTPARCEL", cParcela := x:TEXT,)}) 
   aEval(aKey, {|x| If(Upper(Alltrim(x:_NAME:Text)) == "PROCESS", cPREEMB := x:TEXT,)}) 
   
   cEvento := EasyGetXMLinfo(, oBusinessEvent, "_Event")

   /*If !Empty(cParcela)
      cParcela := RetAsc(cParcela,AvSX3("EEQ_PARC",AV_TAMANHO),.F.)
   EndIf

   EEQ->(DbSetOrder(1)) //EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC+EEQ_FASE                                    
   If !Empty(cPREEMB) .And. EEQ->(DbSeek(xFilial("EEQ") + AvKey(cPREEMB,"EEQ_PREEMB") + AvKey(cParcela,"EEQ_PARC")))*/
   If FindFunction("GetDataInt")
      aDadosRcp := GetDataInt()
   EndIf
   
   If ValType(aDadosRcp) == "A"
      If( nPosAdp := aScan(aDadosRcp, {|x| x[1] == "EECAF212"} ) ) > 0
        nRecPrc := aDadosRcp[nPosAdp][2]
        If FindFunction("DelDataInt")
           DelDataInt( nPosAdp )
        EndIf
      EndIf
   EndIf 
   
   If nRecPrc <> 0
      EEQ->(DbGoTo(nRecPrc))   
   Else
      If !Empty(cParcela)
         cParcela := AvConvParc(  cParcela , AvSX3("EEQ_PARC",AV_TAMANHO)  ,   , "DECODE"  )
      EndIf
      EEQ->(DbSeek(xFilial("EEQ") + AvKey(cPREEMB,"EEQ_PREEMB") + AvKey(cParcela,"EEQ_PARC")))
   EndIf

   If EEQ->(!Eof())     
      Begin Transaction
      EEQ->(RecLock("EEQ",.F.)) 
      If AllTrim(Upper(cEvento)) == "UPSERT"
         EEQ->EEQ_FINNUM := AvKey(EasyGetXMLinfo(, oBusinessCont, "_DocumentNumber"),"EEQ_FINNUM")
      ElseIf AllTrim(Upper(cEvento)) == "DELETE"
         EEQ->EEQ_FINNUM := ""
      EndIf
      EEQ->(MsUnlock())  
      End Transaction
   EndIf
      //oEasyMessage:AddInList("RECEIVE", {"Sucesso" , "Registro Gravado no Destino" , Nil})
   //Else
      //oEasyMessage:AddInList("RECEIVE", {"Erro" , "Parcela não encontrada no Destino" , Nil})
   /*EndIf*/
   
/*   
   If !oEasyMessage:HasErrors() 
   
      IF AllTrim(Upper(cEvento)) == "UPSERT"
   
         If EEQ->EEQ_TIPO == "A" .AND. EEQ->EEQ_FASE $ "P|C" .AND. !Empty(EEQ->EEQ_PGT) .AND. EEQ->EEQ_EQVL <> 0 

            If InTransaction()
               EndTran()
            EndIf             //NCF - 11/07/2014 - Controle transferido para o Adapter
         
            AvStAction("004") //COMPENSACAO
         EndIf
   
      EndIf
   
   EndIf
*/   

RestOrd(aOrdEEQ,.T.)
Return nil
