//EECAF210
#include "average.ch"

Function EECAF210(nOpc)
Private aRotina   := MenuDef()
//Private lRecall   := .F.

   //Só permite inclusão de título ou exclusao se não estiver baixado. Não é possível alterar título no Logix devido a contabilização, só altera quando alterada a data de embarque.
   If (nOpc == 3 .AND. ( ( Empty(EEQ->EEQ_FINNUM) .OR. Type("cEvDtEmba") == "C" .AND. cEvDtEmba == "073" .AND. EEQ->EEQ_EVENT $ "121/122" ) .OR.;
                          !Empty(EEQ->EEQ_FINNUM) .AND. ( IsInCallStack("AF200GParc") .OR. (Type("lIntAltLGX") == "L" .And. lIntAltLGX) )    )).OR.; //NCF - 20/08/2014 - Flag que permite alteração de vcto. de título integrado ao Logix
      nOpc == 5 .AND. !Empty(EEQ->EEQ_FINNUM) .AND. Empty(EEQ->EEQ_SEQBX) .AND. If(!Empty(EEQ->EEQ_PARVIN),EEQ->EEQ_PARC == EEQ->EEQ_PARVIN,.T.)
                                                                                //NCF - 02/07/2014 - So efetuar comparação quando o campo estiver preenchido, ou seja
      EasyEnvEAI("EECAF210",nOpc,.T.)                                           //                   quando houve quebra da parcela principal.
   EndIf

Return .T.

Static Function MenuDef()

Local aRotina :=  {  { "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","AF210MAN" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "AF210MAN" , 0 , 3},; //"Incluir"
                     { "Alterar",   "AF210MAN" , 0 , 4},; //"Alterar"
                     { "Excluir",   "AF210MAN" , 0 , 5} } //"Excluir"                  

Return aRotina

Static Function AF210MAN()
Return Nil

/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: Nilson Cesar C. Filho
* Data: 20/12/2011 - 15:00 hs 
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
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF210ASENB") //Envio de Business
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF210ARESR")	//Rebimento de retorno da Business Enviada
	//
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()

*------------------------------------------------*
Function AF210ASENB(oEasyMessage) 
*------------------------------------------------* 
Local oXml      := EXml():New()
Local oRec      := ENode():New()
Local oBusiness := ENode():New()
Local aArray    := {}
Local oEvent    := ENode():New()
Local oIdent    := Enode():New()
Local oKeyNode, oKeyNode2, oKeyNode3, oKeyNode4, oKeyNode5, i, nInc
Local cQry      := ""
Local aTotalTit := {}
Local lAlteraTit:= .F.
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
       EEQ->(MsUnlock())
    EndIf
    //NCF - 16/09/2014 - Alteração do título para parcelas desmembradas
    If nEAIEvent == 3 .And. !Empty(EEQ->EEQ_FINNUM)
       lAlteraTit := .T.
       #IFDEF TOP 
       
          cQry := "Select EEQ_FILIAL, EEQ_PREEMB, EEQ_NRINVO, EEQ_PARC, EEQ_VCT, EEQ_VL, EEQ_CGRAFI "
          cQry += "From " + RetSqlName("EEQ") + " EEQ "
          cQry += "Where EEQ.D_E_L_E_T_ <> '*' and EEQ_FILIAL = '" + xFilial("EEQ") + "' and "
          cQry += "EEQ_FINNUM = '" + EEQ->EEQ_FINNUM + "' and "
          cQry += "EEQ_PREEMB = '" + EEQ->EEQ_PREEMB + "' "
          cQry += "Order by EEQ_PARC ASC" 
        
          cQry := ChangeQuery(cQry)
          dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "PARCS", .F., .T.) 
          EasyTCFields("PARCS")
          aTotalTit := {PARCS->EEQ_PARC,0,0,PARCS->EEQ_VCT}
          Do While PARCS->(!Eof())
             aTotalTit[2] += PARCS->EEQ_VL
             aTotalTit[3] += PARCS->EEQ_CGRAFI
             If PARCS->EEQ_VCT > aTotalTit[4]
                aTotalTit[4] := PARCS->EEQ_VCT   
             EndIf
             PARCS->(DbSkip())
          EndDo
          PARCS->(DbCloseArea())
       #Else
          aOrdEEQ := SaveOrd('EEQ')
          cChave  := xFilial('EEQ') + EEQ->EEQ_NRINVO + EEQ->EEQ_PREEMB 
          EEQ->(DbSetOrder(4))
          EEQ->(DbSeek(cChave))
          aTotalTit := {EEQ->EEQ_PARC,0,0,EEQ->EEQ_VCT}
          Do While Left( EEQ->(&(IndexKey())) , Len(cChave) ) == cChave 
             aTotalTit[2] += PARCS->EEQ_VL
             aTotalTit[3] += PARCS->EEQ_CGRAFI
             If EEQ->EEQ_VCT > aTotalTit[4]
                aTotalTit[4] := PARCS->EEQ_VCT   
             EndIf 
             If Val(EEQ->EEQ_PARC) < Val(aTotalTit[1])
                aTotalTit[1] := EEQ->EEQ_PARC
             EndIf            
             EEQ->(DbSkip())
          EndDo
          RestOrd(aOrdEEQ,.T.)            
       #ENDIF     
    EndIf 

    oKeyNode   := ENode():New()
    oKeyNode:SetField(EAtt():New("name","DocumentPrefix"))     //PREFIXO
    oKeyNode:SetField(ETag():New("" , EEQ->EEQ_PREFIX))

    oKeyNode2   := ENode():New()
    oKeyNode2:SetField(EAtt():New("name","DocumentNumber"))    //NUMERO
    oKeyNode2:SetField(ETag():New("" , EEQ->EEQ_FINNUM))
    
    oKeyNode3   := ENode():New()
    oKeyNode3:SetField(EAtt():New("name","DocumentParcel"))    //PARCELA
    oKeyNode3:SetField(ETag():New("" ,RetAsc( Val(If(lAlteraTit,aTotalTit[1],EEQ->EEQ_PARC)),1,.T. ) )) 
    
    oKeyNode4   := ENode():New()
    oKeyNode4:SetField(EAtt():New("name","DocumentTypeCode"))  //TIPO
    oKeyNode4:SetField(ETag():New("" , EEQ->EEQ_TPTIT))
    
    oKeyNode5   := ENode():New()
    oKeyNode5:SetField(EAtt():New("name","Process"))  			//PROCESSO
    oKeyNode5:SetField(ETag():New("" ,EEQ->EEQ_PREEMB))

    oIdent:SetField(ETag():New("key",oKeyNode))
    oIdent:SetField(ETag():New("key",oKeyNode2)) 
    oIdent:SetField(ETag():New("key",oKeyNode3))
    oIdent:SetField(ETag():New("key",oKeyNode4))
    oIdent:SetField(ETag():New("key",oKeyNode5))    

    oEvent:SetField("Entity", "EECAF210")
    
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
	
    oBusiness:SetField('CompanyId'       ,cEmpMsg)
    oBusiness:SetField('BranchId'        ,cFilMsg)
    oBusiness:SetField('DocumentPrefix'  ,EEQ->EEQ_PREFIX)
    oBusiness:SetField('DocumentNumber'  ,EEQ->EEQ_FINNUM)
    oBusiness:SetField('DocumentParcel'  ,RetAsc( Val(IF(!Empty(EEQ->EEQ_PARVIN), EEQ->EEQ_PARVIN, EEQ->EEQ_PARC)), 1 ,.T. ) )
    oBusiness:SetField('DocumentTypeCode',EEQ->EEQ_TPTIT)
    
    oBusiness:SetField('Situation'          ,"001")
    If !Empty(EEC->EEC_DTEMBA)
       oBusiness:SetField('IssueDate'          ,EasyTimeStamp(EEC->EEC_DTEMBA, .T., .T.))       
    EndIf

    /*If !Empty(EEQ->EEQ_VCT)
       oBusiness:SetField('DiscountDate'       ,EasyTimeStamp(DataValida(EEQ->EEQ_VCT, .T.), .T., .T.))
    EndIf*/

    //oBusiness:SetField('DiscountPercentage' ,"0")
    
    If !Empty(EEQ->EEQ_HVCT)
        oBusiness:SetField('DueDate'            ,EasyTimeStamp(DataValida(Max(EEQ->EEQ_HVCT,EEC->EEC_DTEMBA), .T.), .T., .T.))
    Else
        oBusiness:SetField('DueDate'            ,EasyTimeStamp(DataValida(Max(EEQ->EEQ_VCT,EEC->EEC_DTEMBA), .T.), .T., .T.))
	EndIf

    If !Empty(EEQ->EEQ_VCT) 
        oBusiness:SetField('ExtendedDate'       ,EasyTimeStamp(DataValida(Max(EEQ->EEQ_VCT,EEC->EEC_DTEMBA), .T.), .T., .T.))
    EndIf

    oBusiness:SetField('ChargeInterest'     ,"false")
    oBusiness:SetField('CustomerCode'       ,if(!Empty(EEQ->EEQ_IMPORT),EEQ->EEQ_IMPORT,EEC->EEC_IMPORT))
    oBusiness:SetField('StoreId'            ,if(!Empty(EEQ->EEQ_IMLOJA),EEQ->EEQ_IMLOJA,EEC->EEC_IMLOJA))
	   //Tratamento sem baixa de comissão (a deduzir/conta grafica)
	   oBusiness:SetField('NetValue'           ,STR(If(lAlteraTit,aTotalTit[2]-aTotalTit[3],EEQ->EEQ_VL-EEQ->EEQ_CGRAFI)))
       oBusiness:SetField('GrossValue'         ,STR(If(lAlteraTit,aTotalTit[2]-aTotalTit[3],EEQ->EEQ_VL-EEQ->EEQ_CGRAFI)))
	   aArray    := EECRatItEmb(EEQ->EEQ_PREEMB,If(lAlteraTit,aTotalTit[2]-aTotalTit[3],EEQ->EEQ_VL-EEQ->EEQ_CGRAFI))
	oBusiness:SetField('InvoiceAmount'      ,EEC->EEC_TOTPED)
    
    SYF->(dbSetOrder(1)) //YF_FILIAL+YF_MOEDA
    SYF->(dbSeek(xFilial()+EEQ->EEQ_MOEDA))
    If EC6->EC6_TXCV == "2" //COMPRA 
    	oBusiness:SetField('CurrencyCode'       ,SYF->YF_CODCERP)
    Else //VENDA
    	oBusiness:SetField('CurrencyCode'       ,SYF->YF_CODVERP)
    EndIf
    //NCF - 11/07/2014 - Para inclusão de adiantamentos,  a taxa utilizada deve ser a compra.
    /*If EEQ->EEQ_TIPO == "A" .AND. EEQ->EEQ_FASE == "E"
       oBusiness:SetField('CurrencyRate'       ,STR(BuscaTaxa(EEQ->EEQ_MOEDA,EEC->EEC_DTEMBA,,.F.,,,"2")))
    Else*/
       oBusiness:SetField('CurrencyRate'       ,STR(BuscaTaxa(EEQ->EEQ_MOEDA,EEC->EEC_DTEMBA,,.F.,,,EC6->EC6_TXCV)))
    /*EndIf*/ //NCF - 11/12/2014 - O Saldo de adiantamento deve ser inserido obedecendo a mesma regra do saldo em aberto (cotação 
    
    oDistr    := ENode():New()
    For i := 1 To Len(aArray)
       oCost     := ENode():New()
       oCost:SetField("CostCenterCode",aArray[i][1])
       oCost:SetField("Value"         ,STR(aArray[i][2]))
       oDistr:SetField('Apportionment',oCost)
    Next i
    
    If !Empty(aArray)
      oBusiness:SetField('ApportionmentDistribution',oDistr)
    EndIf

    oBusiness:SetField('Observation'     ,EEQ->EEQ_OBS)
    
    oSDT    := ENode():New()
    If EEC->(FieldPos("EEC_CODERP")) > 0 
       oSD    := ENode():New()
       If !Empty(EEC->EEC_CODERP)
          oSD:SetField('SourceDocument'            ,EEC->EEC_CODERP)
       Else
          //oSD:SetField('SourceDocument'            ,Substr(EEC->EEC_PREEMB,1,10))  
		  oSD:SetField('SourceDocument'            ,EEC->EEC_PREEMB)  //AAF 05/01/2017 - Enviar todos os caracteres. A limitação deve ser no ERP.
       EndIf
       oSD:SetField('SourceDocumentTypeCode'   ,EasyGParam("MV_AVG0205",,"XP"))
       oSD:SetField('SourceDocumentValue'      ,EEC->EEC_TOTPED)
       oSDT:SetField('SourceDocument'           ,oSD)
    EndIf

    aNfs := EECGetNfs(EEQ->EEQ_PREEMB)
    
    For nInc := 1 To Len(aNfs)
       oSD    := ENode():New()
       oSD:SetField('SourceDocument'            ,aNfs[nInc][1])
       oSD:SetField('SourceDocumentTypeCode'   ,EasyGParam("MV_AVG0205",,"XP"))
       oSD:SetField('SourceDocumentValue'      ,aNfs[nInc][3])
       oSDT:SetField('SourceDocument'           ,oSD)
    Next

    oBusiness:SetField('ListOfSourceDocument',oSDT)
    oBusiness:SetField('Origin'     ,"EEC")      
    
	oRec:SetField('BusinessEvent'  ,oEvent)
	oRec:SetField('BusinessContent',oBusiness) 
	
	oXml:AddRec(oRec)
    
    If IsInCallStack("EasyEAIBuffer") 
       //Tratamento para não perder títulos caso ocorre falha na integração
       If EEQ->(Deleted())
          If Type('lRecall') == 'L'
	         lRecall := .T.
	      EndIf  
          EEQ->(RecLock("EEQ",.F.))
          EEQ->(dbRecall())
          EEQ->(MsUnLock())
       EndIf
    EndIf
    
Return oXml

/*========================================================================================
Funcao Adapter: AF200ARESR
Parametros    : "oMessage" - Objeto XML com conteúdo da tag "BusinessContent" recebida                
Objetivos     : RECEBER uma RESPONSE (apos envio de BUSINNES) e gravar arquivo 
Autor         : Bruno Akyo Kubagawa - BAK
Data/Hora     : 18/01/2012
Revisao       : 
Obs.          : 
==========================================================================================*/
*------------------------------------------------*
Function AF210ARESR(oEasyMessage) 
*------------------------------------------------* 
Local oBusinessCont  := oEasyMessage:GetRetContent()
Local oBusinessEvent := oEasyMessage:GetEvtContent()
Local cPrefixo := "", cNumero := "", cTipo := "", cPREEMB := "", cParcela := "", cEvento := ""
Local aOrdEEQ := SaveOrd({"EEQ"}) 

   If ValType(oBusinessEvent:_IDENTIFICATION:_KEY) <> "A"
      aKey := {oBusinessEvent:_IDENTIFICATION:_KEY}
   Else
      aKey := oBusinessEvent:_IDENTIFICATION:_KEY
   EndIf
    
   aEval(aKey, {|x| If(Upper(Alltrim(x:_NAME:Text)) == "DOCUMENTPARCEL", cParcela := x:TEXT,)}) 
   aEval(aKey, {|x| If(Upper(Alltrim(x:_NAME:Text)) == "PROCESS", cPREEMB := x:TEXT,)}) 
   
   cEvento := EasyGetXMLinfo(, oBusinessEvent, "_Event")
   
   If !Empty(cParcela)
      cParcela := RetAsc(cParcela,AvSX3("EEQ_PARC",AV_TAMANHO),.F.)
   EndIf
   
   EEQ->(DbSetOrder(1)) //EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC+EEQ_FASE                                    
   If !Empty(cPREEMB) .And. EEQ->(DbSeek(xFilial("EEQ") + AvKey(cPREEMB,"EEQ_PREEMB") + AvKey(cParcela,"EEQ_PARC"))) 
      //Begin Transaction
      EEQ->(RecLock("EEQ",.F.)) 
      If AllTrim(Upper(cEvento)) == "UPSERT"
         EEQ->EEQ_FINNUM := AvKey(EasyGetXMLinfo(, oBusinessCont, "_DocumentNumber"),"EEQ_FINNUM")
      ElseIf AllTrim(Upper(cEvento)) == "DELETE"
         EEQ->EEQ_FINNUM := ""
         If IsInCallStack("EasyEAIBuffer")
            //Tratamento para não perder títulos caso ocorre falha na integração                                             //NCF - 24/03/2014 - Não deleta parcela de Adiantamento quando alteração do embarque
            If !EEQ->(Deleted()) .AND. lRecall//.AND. !(Type("cEvDtEmba") == "C" .AND. cEvDtEmba <> "073" .AND. EEQ->EEQ_EVENT $ "121/122") .AND. EEQ->EEQ_TIPO <> 'A'//Em caso de alteração de data de embarque, o titulo será gerado novamente.
               EEQ->(dbDelete())
			   lRecall := .F.
            EndIf
         EndIf
      EndIf     
      EEQ->(MsUnlock())  
      //End Transaction
      //oEasyMessage:AddInList("RECEIVE", {"Sucesso" , "Registro Gravado no Destino" , Nil})
   //Else
      //oEasyMessage:AddInList("RECEIVE", {"Erro" , "Parcela não encontrada no Destino" , Nil})
   EndIf

   If !oEasyMessage:HasErrors() .AND. AllTrim(Upper(cEvento)) == "UPSERT"
      If EasyGParam("MV_EEC0025",,.T.) .AND. EEQ->EEQ_EVENT $ "122"//EEQ->EEQ_ADEDUZ > 0 .AND. EEQ->(FieldPos("EEQ_SEQBX2")) > 0//Tratamento de baixa de comissão 
      
         //If InTransaction()        
         //   EndTran()
         //EndIf             //NCF - 11/07/2014 - Controle transferido para o Adapter
         //MsUnLockAll()
         //BeginTran()
         
         AvStAction("085") //Baixa de Comissão a Deduzir da Fatura
      EndIf
   
      If EEQ->EEQ_TIPO == "A" .AND. EEQ->EEQ_FASE == "E" .AND. !oEasyMessage:HasErrors() .AND. AllTrim(Upper(cEvento)) == "UPSERT"

         //If InTransaction()
         //   EndTran()
         //EndIf             //NCF - 11/07/2014 - Controle transferido para o Adapter
         //MsUnLockAll()
         //BeginTran()
                  
         AvStAction("078") //COMPENSACAO
      EndIf
   EndIf
   
RestOrd(aOrdEEQ,.T.)
Return nil

Function EECGetNfs(cPreemb)
Local aList := {}
Local aOrd := SaveOrd("EE9")
Local nPos := 0

	EE9->(DbSetOrder(3)) //EE9_FILIAL+EE9_PREEMB+EE9_SEQEMB
	EE9->(DbSeek(xFilial()+cPreemb))
	While EE9->(!Eof() .And. EE9_FILIAL+EE9_PREEMB == xFilial()+cPreemb)
	   If (nPos := aScan(aList, {|x| x[1]+x[2] == EE9->(EE9_NF+EE9_SERIE) })) == 0
	      aAdd(aList, {EE9->EE9_NF, EE9->EE9_SERIE,0})
	      nPos := Len(aList)
	   EndIf
	   aList[nPos][3] += EE9->EE9_PRCTOT
	   EE9->(DbSkip())
	EndDo

Restord(aOrd, .T.)
Return aList
