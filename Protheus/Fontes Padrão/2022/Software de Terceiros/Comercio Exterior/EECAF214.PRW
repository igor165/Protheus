#include "average.ch"
/*========================================================================================
Funcao        : EECAF214 - Contas a Pagar
Parametros    : -              
Objetivos     : Apenas função nominal para cadastrar o adapter do fonte EECAF214
Autor         : Allan Oliveira Monteiro - AOM 
Data/Hora     : 11/01/2012 - 15:08 hs
Revisao       : 
Obs.          : 
==========================================================================================*/
Function EECAF214(nOpc)
Local nPos      := 0
Private aRotina := MenuDef()
/*
   If nOpc == 3 .AND. ( (Empty(EEQ->EEQ_FINNUM) .OR.;
                        !Empty(EEQ->EEQ_FINNUM) .AND. IsInCallStack("AF200GParc")) ).OR.;
      nOpc == 5 .AND. !Empty(EEQ->EEQ_FINNUM) .AND. Empty(EEQ->EEQ_SEQBX) .AND. EEQ->EEQ_PARC == EEQ->EEQ_PARVIN
*/
   If (nOpc == 3 .AND. ( (Empty(EEQ->EEQ_FINNUM) .OR.;
                        Type("cEvDtEmba") == "C" .AND. cEvDtEmba == "073") .OR.;
                        !Empty(EEQ->EEQ_FINNUM) .AND. (IsInCallStack("AF200GParc") .Or. isInCallStack("GrvAF200Mn"))) ).OR.;
      nOpc == 5 .AND. !Empty(EEQ->EEQ_FINNUM) .AND. Empty(EEQ->EEQ_SEQBX) .AND. (EEQ->EEQ_PARC == EEQ->EEQ_PARVIN .Or. (AvFlags("ADTFOREAI") .And. EEQ->(FieldPos("EEQ_EAIVRS")) > 0 .And. EEQ->EEQ_EAIVRS == "2"))

		//THTS - 06/04/2017 - Se versao da mensagem for 2, chama o adapter EECAF520
        If  AvFlags("ADTFOREAI") .And. EEQ->(FieldPos("EEQ_EAIVRS")) > 0 .And. EEQ->EEQ_EAIVRS == "2" .And. Type("aEAIAF520") != "U" .And. (IsInCallStack("EECAE100") .Or. IsInCallStack("EECAF200"))

	        If Len(aEAIAF520) != 0
	            nPos := aScan(aEAIAF520,{|x| x[1] == EEQ->EEQ_EVENT .And. x[2] == EEQ->EEQ_FORN .And. x[3] == EEQ->EEQ_FOLOJA .And. x[4] == nOpc})
	        EndIf
	        If nPos > 0
	            aAdd(aEAIAF520[nPos][5],EEQ->(Recno()))
	        Else
	            aAdd(aEAIAF520,{EEQ->EEQ_EVENT,EEQ->EEQ_FORN,EEQ->EEQ_FOLOJA,nOpc,{EEQ->(Recno())}})
                EasyEnvEAI("EECAF520",nOpc)
	        EndIf

        Else
            EasyEnvEAI("EECAF214",nOpc)
        EndIf

   EndIf
   
Return .T.


Static Function MenuDef()

Local aRotina :=  {  { "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","AF214MAN" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "AF214MAN" , 0 , 3},; //"Incluir"
                     { "Alterar",   "AF214MAN" , 0 , 4},; //"Alterar"
                     { "Excluir",   "AF214MAN" , 0 , 5} } //"Excluir"                  

Return aRotina

Static Function AF214MAN()

Return Nil


/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: Allan Oliveira Monteiro 
* Data: 11/01/2012 - 15:10 hs 
* =====================================================*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("EEQ")
	//oEasyIntEAI:oMessage:SetMenu(MenuDef())
	//oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| EECAE100(oEasyMessage:GetEAutoArray("EEQ"),, oEasyMessage:GetOperation())} )

	oEasyIntEAI:SetModule("EEC",29)
	
	// *** Recebimento
	//oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "AF210ARECB") //RECEBIMENTO DE BUSINESS
	//oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "AF210ARESB") //RESPONDE BUSINESS RECEBIDA
	// ***
	// *** Envio
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF214ASENB") //Envio de Business
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF214ARESR")	//Rebimento de retorno da Business Enviada
	// ***
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()

*------------------------------------------------*
Function AF214ASENB(oEasyMessage) 
*------------------------------------------------* 
Local oXml      := EXml():New()
Local oRec      := ENode():New()
Local aArray    := EECRatItEmb(EEQ->EEQ_PREEMB,EEQ->EEQ_VL)
Local oCost,oDistr, oSD, oSDT 

Local oEvent    := ENode():New()
Local oIdent    := ENode():New()
Local oBusiness := ENode():New()
Local oKeyNode, oKeyNode2, oKeyNode3, oKeyNode4,oKeyNode5, oKeyNode6 , i 
Local cEmpMsg := SM0->M0_CODIGO
Local cFilMsg := AvGetM0Fil() 
Local cParam, nPosDiv
 
If !Empty( cParam := Alltrim(EasyGParam("MV_EEC0036",,"")) )
   If (nPosDiv := At('/',cParam)) > 0
      cEmpMsg := Substr(cParam,1,nPosDiv-1) 
      cFilMsg := Substr(cParam,nPosDiv+1,Len(cParam))
   Else
      cEmpMsg := cParam 
      cFilMsg := cParam         
   EndIf  
EndIf

EC6->(DbSetOrder(1))//EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC 
EC6->(DbSeek(xFilial("EC6") + AvKey("EXPORT","EC6_TPMODU") + AvKey(EEQ->EEQ_EVENT,"EC6_ID_CAM")))
 
    If RecLock("EEQ",.F.) .AND. Empty(EEQ->EEQ_FINNUM) // GFP - 23/02/2012
       EEQ->EEQ_PREFIX := EC6->EC6_PREFIX
       EEQ->EEQ_TPTIT  := EC6->EC6_TPTIT
    EndIf
 
    oKeyNode   := ENode():New()
    oKeyNode:SetField(EAtt():New("name","DocumentPrefix"))     //PREFIXO
    oKeyNode:SetField(ETag():New("" ,EEQ->EEQ_PREFIX))

    oKeyNode2   := ENode():New()
    oKeyNode2:SetField(EAtt():New("name","DocumentNumber"))    //NUMERO
    oKeyNode2:SetField(ETag():New("" ,  EEQ->EEQ_FINNUM))          
    
    oKeyNode3   := ENode():New()
    oKeyNode3:SetField(EAtt():New("name","DocumentParcel"))    //PARCELA
    oKeyNode3:SetField(ETag():New("" ,RetAsc(Val(EEQ->EEQ_PARC),1,.T.) )) 
    
    oKeyNode4   := ENode():New()
    oKeyNode4:SetField(EAtt():New("name","DocumentTypeCode"))  //TIPO
    oKeyNode4:SetField(ETag():New("" ,EEQ->EEQ_TPTIT))
    
    oKeyNode5   := ENode():New()
    oKeyNode5:SetField(EAtt():New("name","Process"))  			//PROCESSO
    oKeyNode5:SetField(ETag():New("" ,EEQ->EEQ_PREEMB))
    
    oKeyNode6   := ENode():New()
    oKeyNode6:SetField(EAtt():New("name","Event"))  				//EVENTO
    oKeyNode6:SetField(ETag():New("" ,EEQ->EEQ_EVENT ))

    oIdent:SetField(ETag():New("key",oKeyNode))
    oIdent:SetField(ETag():New("key",oKeyNode2)) 
    oIdent:SetField(ETag():New("key",oKeyNode3))
    oIdent:SetField(ETag():New("key",oKeyNode4))
    oIdent:SetField(ETag():New("key",oKeyNode5))
    oIdent:SetField(ETag():New("key",oKeyNode6))

    oEvent:SetField("Entity", "EECAF214")
        
    IF Type("nEAIEvent") <> "U" .And. nEAIEvent == 5 //Exclusao
       oEvent:SetField("Event" , "delete")
    ELSE //Inclusao/Alteracao
       oEvent:SetField("Event" , "upsert")
    ENDIF

    oEvent:SetField("Identification",oIdent)

    oBusiness:SetField('CompanyId'       ,cEmpMsg)
    oBusiness:SetField('BranchId'        ,cFilMsg)
    oBusiness:SetField('DocumentPrefix'  ,"EEC")
    oBusiness:SetField('DocumentNumber'  , EEQ->EEQ_FINNUM)
    oBusiness:SetField('DocumentParcel'  ,RetAsc(Val(IF(!Empty(EEQ->EEQ_PARVIN), EEQ->EEQ_PARVIN, EEQ->EEQ_PARC)),AVSX3("E2_PARCELA",3),.T.))
    oBusiness:SetField('DocumentTypeCode',EC6->EC6_TPTIT)
    
    
    oSD    := ENode():New()
    oSDT    := ENode():New()
    //If EEC->(FieldPos("EEC_CODERP")) > 0 .AND. !Empty(EEC->EEC_CODERP)
    //   oSD:SetField('SourceDocument'            ,EEC->EEC_CODERP)
    //Else
       oSD:SetField('SourceDocument'            ,Substr(EEC->EEC_PREEMB,1,10))  
    //EndIf
  
    oSD:SetField('SourceDocumentValue',EEC->EEC_TOTPED)
    oSDT:SetField('SourceDocument'           ,oSD)
    oBusiness:SetField('ListOfSourceDocument',oSDT)
    
   
    If !Empty(EEC->EEC_DTEMBA)
       oBusiness:SetField('IssueDate'          ,Left(FWTimeStamp(3,EEC->EEC_DTEMBA ,"00:00:00"), 10))       
    EndIf
    

    oBusiness:SetField('DueDate'            ,Left(FWTimeStamp(3,Max(EEQ->EEQ_VCT,EEC->EEC_DTEMBA),"00:00:00"), 10))
    
    oBusiness:SetField('RealDueDate'        ,Left(FWTimeStamp(3,DataValida(Max(EEQ->EEQ_VCT,EEC->EEC_DTEMBA), .T.),"00:00:00"), 10))

    oBusiness:SetField('VendorCode'         ,EEQ->EEQ_FORN                      )
    oBusiness:SetField('StoreId'            ,EEQ->EEQ_FOLOJA                    ) 
    oBusiness:SetField('NetValue'           ,STR(EEQ->EEQ_VL)                   ) 
    oBusiness:SetField('GrossValue'         ,STR(EEQ->EEQ_VL)                   )
    SYF->(dbSetOrder(1)) //YF_FILIAL+YF_MOEDA
    SYF->(dbSeek(xFilial()+EEQ->EEQ_MOEDA))
    If EC6->EC6_TXCV == "2" //COMPRA 
    	oBusiness:SetField('CurrencyCode'       ,SYF->YF_CODCERP)
    Else //VENDA
    	oBusiness:SetField('CurrencyCode'       ,SYF->YF_CODVERP)
    EndIf
    oBusiness:SetField('CurrencyRate'       ,STR(BuscaTaxa(EEQ->EEQ_MOEDA,EEC->EEC_DTEMBA,,.F.,,,EC6->EC6_TXCV)))
    
    oDistr    := ENode():New()
    For i := 1 To Len(aArray)
       oCost     := ENode():New()
       oCost:SetField("CostCenterCode",aArray[i][1])
       oCost:SetField("Value"         ,aArray[i][2])
       If EC6->(FieldPos("EC6_NATFIN")) > 0
          oCost:SetField("FinancialCode" ,EC6->EC6_NATFIN)
       EndIf
       oDistr:SetField('Apportionment',oCost)
    Next i
    
    If !Empty(aArray)
      oBusiness:SetField('ApportionmentDistribution',oDistr)
    EndIf
    
    oBusiness:SetField('Observation'        ,EEQ->EEQ_OBS)
    oBusiness:SetField('Origin'             ,"SIGAEEC")
    
    
	oRec:SetField('BusinessEvent'  ,oEvent)
	oRec:SetField('BusinessContent',oBusiness) 
	
	oXml:AddRec(oRec)
    
    If IsInCallStack("EasyEAIBuffer")
       //Tratamento para não perder títulos caso ocorre falha na integração
       If EEQ->(Deleted())
          EEQ->(RecLock("EEQ",.F.))
          EEQ->(dbRecall())
          EEQ->(MsUnLock())
       EndIf
    EndIf
    
Return oXml

/*========================================================================================
Funcao Adapter: AF214ARESR
Parametros    : "oMessage" - Objeto XML com conteúdo da tag "BusinessContent" recebida                
Objetivos     : RECEBER uma RESPONSE (apos envio de BUSINNES) e gravar arquivo 
Autor         : Allan Oliveira Monteiro - AOM
Data/Hora     : 11/01/2012 - 15:36 hs
Revisao       : 
Obs.          : 
==========================================================================================*/
*------------------------------------------------*
Function AF214ARESR(oEasyMessage) 
*------------------------------------------------* 
Local oMessage := oEasyMessage:GetMsgContent()
Local oInfo    := oEasyMessage:GetMsgInfo()
Local oBusinessCont  := oEasyMessage:GetRetContent()
Local oBusinessEvent := oEasyMessage:GetEvtContent()
Local cTitFin := "", cPrefixo := "", cNumero := "", cTipo := "", cPREEMB := "", cParcela := "", cEvento := ""
Local aOrdEEQ := SaveOrd({"EEQ"}) 

   If !(ValType(oBusinessEvent:_IDENTIFICATION:_Key) == "A")
      aKey := {oBusinessEvent:_IDENTIFICATION:_Key}
   Else
      aKey := oBusinessEvent:_IDENTIFICATION:_Key
   EndIf
   
   aEval(aKey, {|x| If(Upper(Alltrim(x:_NAME:Text)) == "DOCUMENTPARCEL", cParcela := x:TEXT,)}) 
   aEval(aKey, {|x| If(Upper(Alltrim(x:_NAME:Text)) == "PROCESS", cPREEMB := x:TEXT,)})  

   cEvent :=  EasyGetXMLInfo(, oBusinessEvent,"_Event"   )  
   cTitFin := EasyGetXMLinfo(, oBusinessCont, "_DocumentNumber")

   If !Empty(cParcela)
      cParcela := RetAsc(cParcela,AvSX3("EEQ_PARC",AV_TAMANHO),.F.)
   EndIf
      
   EEQ->(DbSetOrder(1)) //EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC+EEQ_FASE                                    
   If !Empty(cPREEMB) .And. EEQ->(DbSeek(xFilial("EEQ") + AvKey(cPREEMB,"EEQ_PREEMB") + AvKey(cParcela,"EEQ_PARC")))                                                        
      //Begin Transaction
         EEQ->(RecLock("EEQ",.F.))
         If  UPPER(cEvent) == "UPSERT"  
            EEQ->EEQ_FINNUM := AvKey(cTitFin,"EEQ_FINNUM")
         Else
            EEQ->EEQ_FINNUM := ""
            If IsInCallStack("EasyEAIBuffer")
               //Tratamento para não perder títulos caso ocorre falha na integração
               If !EEQ->(Deleted())
                  EEQ->(dbDelete())
               EndIf
            EndIf
         EndIf
         EEQ->(MsUnlock())  
      //End Transaction 
      oEasyMessage:AddInList("RECEIVE", {"Sucesso" , "Registro Gravado no Destino" , Nil})
   Else
      oEasyMessage:AddInList("RECEIVE", {"Erro" , "Parcela não encontrada no Destino" , Nil})
   EndIf

RestOrd(aOrdEEQ,.T.)
Return oEasyMessage 



