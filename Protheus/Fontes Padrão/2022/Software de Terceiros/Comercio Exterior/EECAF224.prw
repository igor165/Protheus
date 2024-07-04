#Include 'average.ch'

/* ====================================================*
* Função: 		EECAF224
* Parametros:	nOpc
* Objetivo:	Efetua integração com Logix 
* Obs:			-
* Autor:		Guilherme Fernandes Pilan - GFP
* Data:		17/01/2012 - 11:15
* =====================================================*/
*----------------------------*
Function EECAF224(nOpc)
*----------------------------*
Local nValCamb := 0 
Local nRecno := 0
Local aEntry := {}
Local i := 0
Local dDataEmb
//Funcao utilizada apenas para cadastrar o PRW no Adapter:
Private aRotina   := MenuDef()

EC6->(DbSeek(xFilial()+"EXPORT"+"580"))

EEM->(DbSetOrder(1)) //EEM_FILIAL+EEM_PREEMB+EEM_TIPOCA+EEM_NRNF+EEM_TIPONF
If EEM->(DbSeek(xFilial()+EEC->EEC_PREEMB))
   
   nTotEmb  := 0
   nTotEmbR := 0
      
   nRecno := EEM->(Recno())
   
   If Type("dDtEmbarque") <> "D"
      dDtEmbarque:= CtoD("")
   EndIf

   Begin Sequence
      Do While EEM->(!Eof()) .AND. EEM->EEM_PREEMB == EEC->EEC_PREEMB
         
         //NCF - 06/06/2014 - Obter o rateio apenas de Notas fiscais de Saída
         If EEM->EEM_TIPONF <> '1'
            EEM->(DbSkip())
            Loop 
         EndIf  
         
         aEntry := EECVlNFCC(EEM->EEM_PREEMB, EEM->EEM_NRNF, EEM->EEM_SERIE)    

         If Empty(dDtEmbarque) .And. !Empty(EEC->EEC_DTEMBA)
            dDataEmb := EEC->EEC_DTEMBA
         Else
            dDataEmb := dDtEmbarque
         EndIf
         
         nValMoeda := 0
         aEval(aEntry,{|X| nValMoeda += X[2]})
         
         nTaxaEmb := BuscaTaxa(EEC->EEC_MOEDA,dDataEmb,,.F.,,,EC6->EC6_TXCV)
         
         nTotEmb  += nValMoeda * nTaxaEmb
         nTotEmbR += Round(nValMoeda * nTaxaEmb,2)
         
		 nTotal := Round(nTotEmb,2) - nTotEmbR
		 If nTotal <> 0
		    nTotEmbR += nTotal
		 EndIf
		 
		 nTotalR:= 0
         For i := 1 To Len(aEntry)
            If AllTrim(EasyGParam("MV_EEC0027",,"1")) == "2"
			   nValCamb := Round(aEntry[i][2] * nTaxaEmb,2)//BuscaTaxa(EEC->EEC_MOEDA, dDataEmb),2)
			   nTotal   += aEntry[i][2] * nTaxaEmb
			   nTotalR  += nValCamb
			   
			   If Round(nTotal,2) <> nTotalR
			      nValCamb += Round(nTotal,2) - nTotalR
				  nTotalR  += Round(nTotal,2) - nTotalR
			   EndIf
			Else
			   nValCamb := Round(aEntry[i][2] * (nTaxaEmb - EEM->EEM_TXTB),2)//BuscaTaxa(EEC->EEC_MOEDA, dDataEmb)
			EndIf
            
			//nValCamb := Round(EEM->EEM_VLNF * (BuscaTaxa(EEC->EEC_MOEDA, EEC->EEC_DTEMBA) - EEM->EEM_TXTB),2)
            If nValCamb <> 0
               //Exit
               Break
            EndIf
         Next

         EEM->(DbSkip())
      EndDo
   End Sequence

   //** AAF 02/02/2015 - Checar o evento para saber se está configurado para integrar.
   If nValCamb > 0
      EC6->(DbSeek(xFilial()+"EXPORT"+"580"))  // V.C. NF (CR)        
   Else
      EC6->(DbSeek(xFilial()+"EXPORT"+"581"))  // V.C. NF (DB)        
   EndIf
   //** 
   
   //If (EEM->(DbSeek(xFilial()+EEC->EEC_PREEMB)) .and. !Empty(EEC->EEC_DTEMBA)) .Or. (Empty(EEC->EEC_DTEMBA) .And. nOpc == 5 .AND. !Empty(EXL->EXL_LOTCON))
   EEM->(DbGoto(nRecno))
   If EC6->EC6_CONTAB == "1" .AND. nValCamb <> 0 .And. (!Empty(EEC->EEC_DTEMBA) .AND. Empty(EXL->EXL_LOTCON) .Or. (Empty(EEC->EEC_DTEMBA) .And. nOpc == 5 .AND. !Empty(EXL->EXL_LOTCON)))
      EasyEnvEAI("EECAF224",nOpc)
   EndIf

EndIf

Return .T.

/* ====================================================*
* Função:		MenuDef
* Parametros:	-
* Objetivo:	Menu da Rotina
* Obs: 		-
* Autor:		Guilherme Fernandes Pilan - GFP
* Data:		17/01/2012 - 11:28
* =====================================================*/
*----------------------------*
Static Function MenuDef()
*----------------------------*

Local aRotina :=  {{ "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","AF224MAN" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "AF224MAN" , 0 , 3},; //"Incluir"
                     { "Alterar",   "AF224MAN" , 0 , 4},; //"Alterar"
                     { "Excluir",   "AF224MAN" , 0 , 5} } //"Excluir"                  

Return aRotina

*----------------------------*
Static Function AF224MAN()
*----------------------------*
Return Nil

/* ====================================================*
* Função:		IntegDef
* Parametros:	cXML, nTypeTrans, cTypeMessage
* Objetivo:	Efetua integração com Logix 
* Obs:			-
* Autor:		Guilherme Fernandes Pilan - GFP
* Data:		17/01/2012 - 11:31
* =====================================================*/
*-------------------------------------------------------*
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
*-------------------------------------------------------*
Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("EEC")
	oEasyIntEAI:SetModule("EEC",29) 
		
	// *** Envio
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF224ASENB") //ENVIO DE BUSINESS MESSAGE           (<-Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF224ARESR") //RESPOSTA SOBRE O ENVIO DA BUSINESS  (->Response)
	// ***
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()

/* ====================================================*
* Função:		AF224ASENB
* Parametros:	cXML, nTypeTrans, cTypeMessage
* Objetivo:	Efetua integração com Logix 
* Obs:			-
* Autor:		Guilherme Fernandes Pilan - GFP
* Data:		17/01/2012 - 11:32
* =====================================================*/
*---------------------------------*
Function AF224ASENB(oEasyMessage) 
*---------------------------------*
Local oXml          := EXml():New()
Local oBusiness    := ENode():New()
Local oEntries     := ENode():New()
Local oKeyNode
Local oRec        := ENode():New()
Local oEvent      := ENode():New()
Local oIdent      := ENode():New()
Local nValCamb := 0
Local cCont := "1"
Local aDtNF := {}
Local cLojaImp := ""
Local cLojaFor := ""
Local aOrd := SaveOrd({"EEM", "EC6" , "EXL"}) 
Local i := 0
Local dDataEmb 
Local cEmpMsg := SM0->M0_CODIGO
Local cFilMsg := AvGetM0Fil() 
Local cParam, nPosDiv
Local cEventCont:= ""
Private oEntry

   If !Empty( cParam := Alltrim(EasyGParam("MV_EEC0034",,"")) )
      If (nPosDiv := At('/',cParam)) > 0
         cEmpMsg := Substr(cParam,1,nPosDiv-1) 
         cFilMsg := Substr(cParam,nPosDiv+1,Len(cParam))
      Else
         cEmpMsg := cParam 
         cFilMsg := cParam         
      EndIf  
   EndIf

   If Type("nEAIEvent") == "U"
      nEAIEvent:= 0
   EndIf

   EC6->(DbSetOrder(1))
   //EEM->(DbSetOrder(1))
   //EEM->(DbSeek(xFilial()+EEC->EEC_PREEMB)) 

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","BranchId"))
   oKeyNode:SetField(ETag():New("" ,AvGetM0Fil()))
   oIdent:SetField(ETag():New("key",oKeyNode))
   
   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","Process"))
   oKeyNode:SetField(ETag():New("" ,EEC->EEC_PREEMB))
   oIdent:SetField(ETag():New("key",oKeyNode)) 
   
   oEvent:SetField("Entity" , "EECAF224")
   
   If nEAIEvent == 5 //Exclusao
      oEvent:SetField("Event" , "delete")
   Else //Inclusao/Alteracao
      oEvent:SetField("Event" , "upsert")
   EndIf
   oEvent:SetField("Identification",oIdent)

   oBusiness:SetField("CompanyId"  , cEmpMsg)
   oBusiness:SetField("BranchId"   , cFilMsg)
   oBusiness:SetField("OriginCode" , "EEC")
   
   If Type("dDtEmbarque") <> "D" .Or. (Empty(dDtEmbarque) .And. !Empty(EEC->EEC_DTEMBA))
      dDataEmb := EEC->EEC_DTEMBA
   Else
      dDataEmb := dDtEmbarque
   EndIf
   
   nTotEmb  := 0
   nTotEmbR := 0
   nTaxaEmb := BuscaTaxa(EEC->EEC_MOEDA,dDataEmb,,.F.,,,EC6->EC6_TXCV)
   
   nIni := 0                                                             
   Do While EEM->(!Eof()) .AND. EEM->EEM_PREEMB == EEC->EEC_PREEMB 
   
      //NCF - 06/06/2014 - Obter o rateio apenas de Notas fiscais de Saída
      If EEM->EEM_TIPONF <> '1'
         EEM->(DbSkip())
         Loop 
      EndIf 
      
      // Valores da nota fiscal por centro de custo
      aEntry := EECVlNFCC(EEM->EEM_PREEMB, EEM->EEM_NRNF, EEM->EEM_SERIE, nEAIEvent == 3, nIni)
      nIni := Val(aEntry[Len(aEntry)][3])

      nValMoeda := 0
      aEval(aEntry,{|X| nValMoeda += X[2]})
               
      nTotEmb  += nValMoeda * nTaxaEmb
      nTotEmbR += Round(nValMoeda * nTaxaEmb,2)
         
	  nTotal := Round(nTotEmb,2) - nTotEmbR
	  If nTotal <> 0
	    nTotEmbR += nTotal
	  EndIf
	  
	  nTotalR:= 0
	  For i := 1 To Len(aEntry)
         
         EC6->(DbSeek(xFilial()+"EXPORT"+"580"))
		 
         If AllTrim(EasyGParam("MV_EEC0027",,"1")) == "2"
            nValCamb := Round(aEntry[i][2] * BuscaTaxa(EEC->EEC_MOEDA,dDataEmb,,.F.,,,EC6->EC6_TXCV),2)//BuscaTaxa(EEC->EEC_MOEDA, dDataEmb),2)
            nTotal   += aEntry[i][2] * BuscaTaxa(EEC->EEC_MOEDA,dDataEmb,,.F.,,,EC6->EC6_TXCV)
            nTotalR  += nValCamb
			   
            If Round(nTotal,2) <> nTotalR
               nValCamb += Round(nTotal,2) - nTotalR
               nTotalR  += Round(nTotal,2) - nTotalR
            EndIf
         Else
            nValCamb := Round(aEntry[i][2] * (BuscaTaxa(EEC->EEC_MOEDA,dDataEmb,,.F.,,,EC6->EC6_TXCV)/*BuscaTaxa(EEC->EEC_MOEDA, dDataEmb)*/ - EEM->EEM_TXTB),2)
         EndIf
		 
         If nValCamb > 0
            EC6->(DbSeek(xFilial()+"EXPORT"+"580"))  // V.C. NF (CR)
            cEventCont:= "580"
         Else
            EC6->(DbSeek(xFilial()+"EXPORT"+"581"))  // V.C. NF (DB)
            cEventCont:= "581"
         EndIf
      
         nValCamb := ABS(nValCamb)
      
         If nValCamb == 0
            Loop
         EndIf
      
         Private oEntry   := ENode():New()

         oEntry:SetField("EntryNumber"         , aEntry[i][3])
         
         If !Empty(aEntry[i][4])                                     //NCF - 16/05/2016 - Não enviar valor vazio - validação do xsd.
            oEntry:SetField("RelationshipNumber"  , aEntry[i][4])
	      EndIf
		 /* AAF - Lancamento deve ser feito por centro de custo.
         If EEM->(RecLock("EEM",.F.))
            EEM->EEM_LANCAM := cCont
            EEM->(MsUnlock())
         EndIf
         */
      
         cCont:= SOMAIT(cCont)
         /*  //NCF - 13/11/2014 - Nopado
         If !Empty(EEC->EEC_DTEMBA)
            oEntry:SetField("MovementDate"  ,Left(FWTimeStamp(3,EEC->EEC_DTEMBA ,"00:00:00"), 10) ) // Data de Movimento
         Else
            oEntry:SetField("MovementDate"  ,Left(FWTimeStamp(3,dDataBase ,"00:00:00"), 10) ) // Data de Movimento
         EndIf
         */
         //NCF - 13/11/2014
         oEntry:SetField("MovementDate"  ,Left(FWTimeStamp(3,dDataEmb ,"00:00:00"), 10) ) // Data de Movimento
         
         If EICLoja()
            cLojaFor := EEC->EEC_FOLOJA
            cLojaImp := EEC->EEC_IMLOJA
         EndIf
      
         If nEAIEvent == 5 //Exclusao
            If Empty(EC6->EC6_CDBEST) //THTS - 01/06/2017 - Adicionado o campo EEC->EEC_INCOTE na chamada da funcao EasyMascCon - TE-5822
               oEntry:SetField("DebitAccountCode"  , EasyMascCon(EC6->EC6_CTA_CR,EEC->EEC_FORN,cLojaFor,EEC->EEC_IMPORT,cLojaImp,"","","","","",,EEC->EEC_INCOTE))
            Else
               oEntry:SetField("DebitAccountCode"  , EasyMascCon(EC6->EC6_CDBEST,EEC->EEC_FORN,cLojaFor,EEC->EEC_IMPORT,cLojaImp,"","","","","",,EEC->EEC_INCOTE))
            EndIf

            If Empty(EC6->EC6_CCREST)
               oEntry:SetField("CreditAccountCode"  , EasyMascCon(EC6->EC6_CTA_DB,EEC->EEC_FORN,cLojaFor,EEC->EEC_IMPORT,cLojaImp,"","","","","",,EEC->EEC_INCOTE))
            Else
               oEntry:SetField("CreditAccountCode"  , EasyMascCon(EC6->EC6_CCREST,EEC->EEC_FORN,cLojaFor,EEC->EEC_IMPORT,cLojaImp,"","","","","",,EEC->EEC_INCOTE))
            EndIf            
         Else
            oEntry:SetField("DebitAccountCode"  , EasyMascCon(EC6->EC6_CTA_DB,EEC->EEC_FORN,cLojaFor,EEC->EEC_IMPORT,cLojaImp,"","","","","",,EEC->EEC_INCOTE))
            oEntry:SetField("CreditAccountCode" , EasyMascCon(EC6->EC6_CTA_CR,EEC->EEC_FORN,cLojaFor,EEC->EEC_IMPORT,cLojaImp,"","","","","",,EEC->EEC_INCOTE))
         EndIf

         oEntry:SetField("EntryValue"  , nValCamb)

         oEntry:SetField("HistoryCode"  , EC6->EC6_COD_HI)   

         oEntry:SetField("ComplementaryHistory"  , Left("Evento: " + cEventCont + ", Embarque: " + AllTrim(EEC->EEC_PREEMB) + " - " + EC6->EC6_COM_HI, 200))

         //oEntry:SetField("CostCenterCode"  , EC6->EC6_CCUSTO) 
         oEntry:SetField("CostCenterCode"  , aEntry[i][1])      
         aAdd(aDtNF, EEM->EEM_DTNF) // Armazena data para verificar menor e maior data do lote.
         
         If EasyEntryPoint("EECAF224")
            ExecBlock("EECAF224", .f., .f., "LANCAMENTO_CONTABIL")
         Endif
		 
         oEntries:SetField("Entry" , oEntry)
      Next

      EEM->(DbSkip())
   EndDo

   nUltimo := Len(aDtNF)
   
   If nUltimo > 0
      aSort(aDtNF)                            //NCF - 13/11/2014
      oBusiness:SetField("PeriodStartDate"  , EasyTimeStamp(dDataEmb, .T., .T.) )
      oBusiness:SetField("PeriodEndDate"    , EasyTimeStamp(dDataEmb, .T., .T.) )
   EndIf

   If !Empty(EXL->EXL_LOTCON) .And. nEAIEvent == 5 // Exclusao
      oBusiness:SetField("BatchNumber" , EXL->EXL_LOTCON)
   EndIf

   oBusiness:SetField("Entries",oEntries) 
   oRec:SetField("BusinessEvent",oEvent) 
   oRec:SetField("BusinessContent",oBusiness) 
   oXml:AddRec(oRec)

RestOrd(aOrd, .T.)

Return oXml


/* ====================================================*
* Função:		AF224ARESR
* Parametros:	oEasyMessage
* Objetivo:	Efetua integração com Logix 
* Obs:			-
* Autor:		Guilherme Fernandes Pilan - GFP
* Data:		18/01/2012 - 15:09
* =====================================================*/
*-------------------------------------------------*
Function AF224ARESR(oEasyMessage) 
*-------------------------------------------------*
Local oBusinessCont  := oEasyMessage:GetRetContent()
Local oBusinessEvent := oEasyMessage:GetEvtContent()
Local cBranchId := "" 
Local cPREEMB := ""
Local cEvent := "" 
Local aEntry 
Local aOrd := SaveOrd({"EXL","EEM","EES"}) 
Local nPos := 0 

   If !(ValType(oBusinessEvent:_IDENTIFICATION:_Key) == "A")
      aKey := {oBusinessEvent:_IDENTIFICATION:_Key}
   Else
      aKey := oBusinessEvent:_IDENTIFICATION:_Key
   EndIf
   
   If !(ValType(oBusinessCont:_Entries:_Entry) == "A")
      aEntry := {oBusinessCont:_Entries:_Entry}
   Else
      aEntry := oBusinessCont:_Entries:_Entry
   EndIf

   aEval(aKey,  {|x| If(x:_NAME:Text == "BranchId", cBranchId := x:TEXT,) })
   aEval(aKey,  {|x| If(x:_NAME:Text == "Process", cPREEMB := x:TEXT,) }) 
   
   cEvent :=  EasyGetXMLInfo(, oBusinessEvent,"_Event"   ) 

   EXL->(DbSetOrder(1)) //EXL_FILIAL+EXL_PREEMB
   If EXL->(DbSeek(xFilial("EXL")+AvKey(cPREEMB,"EXL_PREEMB")))                                                            
      //Begin Transaction
         EXL->(RecLock("EXL",.F.))
         If  UPPER(cEvent) == "UPSERT" 
            EXL->EXL_LOTCON :=  EasyGetXMLinfo(, oBusinessCont, "_BatchNumber")
         Else
            EXL->EXL_LOTCON :=  ""
         EndIf
         EXL->(MsUnlock())  
      //End Transaction
      oEasyMessage:AddInList("RECEIVE", {"Sucesso" , "Registro Gravado no Destino" , Nil})
   Else
      oEasyMessage:AddInList("RECEIVE", {"Erro" , "Registro não encontrada no Destino" , Nil})
   EndIf 
   
   /* AAF - LANCAMENTO POR CENTRO DE CUSTO
   EEM->(DbSetOrder(1)) //EEM_FILIAL+EEM_PREEMB+EEM_TIPOCA+EEM_NRNF+EEM_TIPONF
   EEM->(DbSeek(xFilial("EEM") + AvKey(cPREEMB,"EEM_PREEMB")  ))
   While EEM->(!Eof()) .And. xFilial("EEM") == AvKey(cBranchId,"EEM_FILIAL") .And. EEM->EEM_PREEMB == AvKey(cPREEMB,"EEM_PREEMB")  
       If (nPos := aScan(aEntry, {|x| AllTrim(x:_EntryNumber:TEXT) == AllTrim(EEM->EEM_LANCAM) })) > 0 
          If EEM->(RecLock("EEM",.F.)) 
             If UPPER(cEvent) == "UPSERT"   
                EEM->EEM_RELACA := aEntry[nPos]:_RelationshipNumber:TEXT
             Else
                EEM->EEM_RELACA := ""
                EEM->EEM_LANCAM := ""
             EndIf
          EEM->(MsUnlock())
          EndIf
       EndIf
   EEM->(DbSkip())
   EndDo
   */
   
   EES->(DbSetOrder(1)) // EES_FILIAL+EES_PREEMB+EES_NRNF+EES_SERIE+EES_PEDIDO+EES_SEQUEN
   EES->(DbSeek(xFilial("EES")+AvKey(cPREEMB,"EES_PREEMB")))
   Do While EES->(!Eof()) .And. EES->(EES_FILIAL+EES_PREEMB) == xFilial("EEM")+EEM->EEM_PREEMB

      If !Empty(EES->EES_LANCAM)
	     If (nPos := aScan(aEntry, {|x| AllTrim(x:_EntryNumber:TEXT) == AllTrim(EES->EES_LANCAM) })) > 0
            If EES->(RecLock("EES",.F.)) 
               If UPPER(cEvent) == "UPSERT"   
                  EES->EES_RELACA := aEntry[nPos]:_RelationshipNumber:TEXT
               Else
                  EES->EES_RELACA := ""
                  EES->EES_LANCAM := ""
               EndIf
               EES->(MsUnlock())
            EndIf
		 EndIf
	  EndIf
   
      EES->(DbSkip())
   EndDo
   
RestOrd(aOrd)
   
Return oEasyMessage
