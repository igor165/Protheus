#Include 'Protheus.ch'

/* ====================================================*
* Função: 		EECAF225
* Parametros:	nOpc
* Objetivo:	Efetua integração com Logix
* Obs:			Contab. de eventos do contrato de financiamento
* Autor:		Guilherme Fernandes Pilan - GFP
* Data:		19/01/2012 - 09:44
* =====================================================*/
*----------------------------*
Function EECAF225(nOpc)
*----------------------------*
//Funcao utilizada apenas para cadastrar o PRW no Adapter:
Local cQuery, cJoin, lOk, lRet := .T. 
Local cInformix := if(TCGETDB()=="INFORMIX"," AS ","")
Private aRotina   := MenuDef()

   If nOpc <> 5

      EF3->(DbSetOrder(1)) //EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE+EF3_PARC+EF3_INVOIC+EF3_INVIMP+EF3_LINHA
      EF3->(DbSeek(xFilial("EF3")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT)))

      EC6->(DbSetOrder(1))//EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC                          //NCF - 15/01/2015
               
      // Looping nos Eventos do Contrato de Financiamento sem Contabilização
	   Private aEF3 := {}
	   Private oListaErr := AvObject():New()

      If Type("dDataCont") <> "D" 
         dDataCont:= CtoD("")
      EndIf

      Do While EF3->(!Eof()) .AND. EF3->EF3_CONTRA == EF1->EF1_CONTRA .AND.;
                                   EF3->EF3_BAN_FI == EF1->EF1_BAN_FI .AND.;
                                   EF3->EF3_PRACA == EF1->EF1_PRACA .AND.;
                                   EF3->EF3_SEQCNT == EF1->EF1_SEQCNT

         EC6->(DbSeek( xFilial("EC6") +  If(EF3->EF3_TPMODU <> 'I',"FIEX","FIIM") + EF1->EF1_TP_FIN + AvKey(EF3->EF3_CODEVE,"EC6_ID_CAM") )) //NCF - 15/01/2015
	     
         If Empty(EF3->EF3_NR_CON) .AND. Empty(EF3->EF3_NRLOTE) .AND. Empty(EF3->EF3_RELACA) .AND. EF3->EF3_VL_REA <> 0 .AND. EC6->EC6_CONTAB == "1" .AND. (Empty(dDataCont) .OR. EF3->EF3_DT_EVE <= dDataCont)
		    Private oErrEF3 := AvObject():New()
		    aContas := AF225GetContas(oErrEF3)
	        
			aAdd(aEF3,EF3->(RecNo()))
			
			If Empty(aContas[1])
  			   If Empty(aContas[2])
			      oErrEF3:Error("Não foi possível determinar a conta contábil de crédito e débito.")
			   Else
			      oErrEF3:Error("Não foi possível determinar a conta contábil de crédito.")
			   EndIf
			Else
  			   If Empty(aContas[2])
			      oErrEF3:Error("Não foi possível determinar a conta contábil de débito.")
			   EndIf
			EndIf
						
			If oErrEF3:HasErrors()
			   oListaErr:Error("Contrato: "+xFilial("EF3")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT)+", Evento: "+EF3->(EF3_CODEVE+EF3_INVOIC+EF3_PARC+EF3_SEQ))
			   oListaErr:Error(oErrEF3:aError)
			EndIf
		 EndIf
		 
		 EF3->(dbSkip())
	  EndDo
	  
	  If oListaErr:HasErrors()
	     EECVIEW("Foram detectadas contas contabeis não configuradas para esta integração:"+Chr(13)+Chr(10)+oListaErr:GetStrErrors()) 
	     EX103GrvMsg(.F.,EF1->EF1_CONTRA)                                                                                              //NCF - 15/09/2015 - Melhoria no log final da contabilização
	  Else	  
		 If Len(aEF3) > 0
		    lRet := EasyEnvEAI("EECAF225",3)
	        If lRet
	           EX103GrvMsg(.T.,EF1->EF1_CONTRA)
	        EndIf
		 EndIf
	  EndIf
   Else
      lRet := EasyEnvEAI("EECAF225",5)
   EndIf
   
   //Após término da integração, checa se existem registros não retornados (problemas de webservice, o EAI não processa response).
   //If lOk
   	  If Select("WkQry") > 0
         WkQry->(DbCloseArea()) 
      EndIf
   
      cQuery := " SELECT R_E_C_N_O_ AS RECNO FROM " + RetSqlName("EF3") + cInformix +" EF3 "
      cQuery += " WHERE EF3.D_E_L_E_T_ = '' "
      cQuery += " AND EF3_FILIAL = '"+xFilial("EF3") +"' AND EF3_TPMODU = '"+EF1->EF1_TPMODU+"' "
      cQuery += " AND EF3_BAN_FI = '"+EF1->EF1_BAN_FI+"' AND EF3_PRACA  = '"+EF1->EF1_PRACA +"' "
      cQuery += " AND EF3_CONTRA = '"+EF1->EF1_CONTRA+"' AND EF3_SEQCNT = '"+EF1->EF1_SEQCNT+"' "
      cQuery += " AND EF3_NR_CON <> '' AND (EF3_NRLOTE = '' AND EF3_RELACA = '') "
   
      cQuery := ChangeQuery(cQuery)
      DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WkQry", .T., .T.)
      
      WkQry->(dbGoTop())
      lOk := !WkQry->(Eof())
      
      Do While !WkQry->(Eof())
	     EF3->(dbGoTo(WkQry->RECNO))
		 
		 RecLock("EF3",.F.)
		 EF3->EF3_NR_CON := ""
		 EF3->EF3_NRLOTE := ""
         EF3->EF3_RELACA := ""
		 EF3->(MsUnLock())
		 
	     WkQry->(dbSkip())
	  EndDo
	  WkQry->(dbCloseArea())
	  
   //EndIf
   
Return lRet

/* ====================================================*
* Função:		MenuDef
* Parametros:	-
* Objetivo:	Menu da Rotina
* Obs: 		-
* Autor:		Guilherme Fernandes Pilan - GFP
* Data:		19/01/2012 - 09:44
* =====================================================*/
*----------------------------*
Static Function MenuDef()
*----------------------------*

Local aRotina :=  {{ "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","AF225MAN" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "AF225MAN" , 0 , 3},; //"Incluir"
                     { "Alterar",   "AF225MAN" , 0 , 4},; //"Alterar"
                     { "Excluir",   "AF225MAN" , 0 , 5} } //"Excluir"                  

Return aRotina

*----------------------------*
Static Function AF225MAN()
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
	oEasyIntEAI:oMessage:SetMainAlias("EF1")
	oEasyIntEAI:SetModule("EFF",30) 
		
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF225ASENB") //ENVIO DE BUSINESS MESSAGE           (<-Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF225ARESR") //RESPOSTA SOBRE O ENVIO DA BUSINESS  (->Response)
	
	oEasyIntEAI:Execute(.T.) //Executa o adapter de response mesmo em caso de response com erros.

Return oEasyIntEAI:GetResult()

/* ====================================================*
* Função:		AF225ASENB
* Parametros:	cXML, nTypeTrans, cTypeMessage
* Objetivo:	Efetua integração com Logix 
* Obs:			-
* Autor:		Guilherme Fernandes Pilan - GFP
* Data:		17/01/2012 - 11:32
* =====================================================*/
*---------------------------------*
Function AF225ASENB(oEasyMessage) 
*---------------------------------*
Local oXml          := EXml():New()
Local oBusiness    := ENode():New()
Local oEntries     := ENode():New()
Local oKeyNode
Local oRec        := ENode():New()
Local oEvent      := ENode():New()
Local oIdent      := ENode():New()
Local nUltimo, aDtEve := {}
Local cSeq := "", cSeqAli := ""
Local cForn    := ""
Local cLojaFor := ""
Local cBanMov := ""
Local cAgMov := ""
Local cCtaMov := ""
Local cEmpMsg := SM0->M0_CODIGO
Local cFilMsg := AvGetM0Fil() 
Local cParam, nPosDiv, i
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
  
   EC6->(DbSetOrder(1)) //EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","Contract"))
   oKeyNode:SetField(ETag():New("" ,EF1->EF1_CONTRA))
   oIdent:SetField(ETag():New("key",oKeyNode))
   
   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","Module"))
   oKeyNode:SetField(ETag():New("" ,EF1->EF1_TPMODU))
   oIdent:SetField(ETag():New("key",oKeyNode)) 

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","Bank"))
   oKeyNode:SetField(ETag():New("" ,EF1->EF1_BAN_FI))
   oIdent:SetField(ETag():New("key",oKeyNode)) 
   
   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","Place"))
   oKeyNode:SetField(ETag():New("" ,EF1->EF1_PRACA))
   oIdent:SetField(ETag():New("key",oKeyNode)) 

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","Sequence"))
   oKeyNode:SetField(ETag():New("" ,EF1->EF1_SEQCNT))
   oIdent:SetField(ETag():New("key",oKeyNode)) 
   
   oEvent:SetField("Entity" , "EECAF225")
   
   If Type("nEAIEvent") <> "U" .And. nEAIEvent == 5 //Exclusao
      oEvent:SetField("Event" , "delete")
   Else //Inclusao/Alteracao
      oEvent:SetField("Event" , "upsert")
   EndIf
   
   oBusiness:SetField("CompanyId"  , cEmpMsg)
   oBusiness:SetField("BranchId"   , cFilMsg)
   oBusiness:SetField("OriginCode" , "EFF")

   // Sequencia automática do Número Contabil 
   /*If Select("Work") > 0
      Work->(DbCloseArea()) 
      FErase("Work")   
   EndIf

   cQuery := "SELECT * FROM " + RetSqlName("EF3") + " WHERE EF3_NR_CON <> '' AND D_E_L_E_T_ = '' ORDER BY EF3_NR_CON DESC"
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "Work", .T., .T.)

   cSeqAli := Work->EF3_NR_CON

   Work->(dbCloseArea())
   
   If !Empty(cSeqAli)   
      cSeq := StrZero(Val(SomaIt(cSeqAli)),4,0)
   Else*/
      cSeq := StrZero(1,4,0)
   //EndIf
   
   //EF3->(dbSetOrder(1)) //EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE+EF3_PARC+EF3_INVOIC+EF3_INVIMP+EF3_LINHA
   //EF3->(dbSeek(xFilial("EF3")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT)))
   
   // Looping nos Eventos do Contrato de Financiamento sem Contabilização
   /*Do While EF3->(!Eof()) .AND. EF3->EF3_CONTRA == EF1->EF1_CONTRA .AND.;
                                   EF3->EF3_BAN_FI == EF1->EF1_BAN_FI .AND.;
                                   EF3->EF3_PRACA == EF1->EF1_PRACA .AND.;
                                   EF3->EF3_SEQCNT == EF1->EF1_SEQCNT*/
	
	For i := 1 To Len(aEF3)
	   EF3->(dbGoTo(aEF3[i]))
	   
       EC6->(dbSeek(xFilial("EC6")+If(EF3->EF3_TPMODU == "E","FIEX","FIIM")+EF3->EF3_TP_EVE+EF3->EF3_CODEVE)) /*EF1->EF1_TP_FIN*/ //AAF 29/07/2014 - Usar tipo de evento do EF3, pois pode ser diferente do EF1 no ACC/ACE
	   
       Private oEntry   := ENode():New()
       
       If Empty(EF3->EF3_NR_CON)
	      RecLock("EF3",.F.)
          EF3->EF3_NR_CON := cSeq
          EF3->(MsUnlock())
       EndIf
         
       oEntry:SetField("EntryNumber"         , EF3->EF3_NR_CON)
       
       If !Empty(EF3->EF3_RELACA)                                  //NCF - 21/06/2016 - Não enviar se eetiver vazio (Validação do xsd)
	      oEntry:SetField("RelationshipNumber"  , EF3->EF3_RELACA)
	    EndIF
       
       oEntry:SetField("MovementDate"  , EasyTimeStamp(EF3->EF3_DT_EVE, .T., .T.))         
      
       aContas := AF225GetContas()
	   
       oEntry:SetField("DebitAccountCode"  , aContas[1]) //NCF - 15/10/2013 - Alteração na formaçao da chave do tipo de Modulo
       oEntry:SetField("CreditAccountCode" , aContas[2]) //NCF - 15/10/2013 - Alteração na formaçao da chave do tipo de Modulo
	   
       //oEntry:SetField("MovementDate"  , EasyTimeStamp(EF3->EF3_DT_EVE, .T., .T.))
	   
	   oEntry:SetField("EntryValue"  , Abs(EF3->EF3_VL_REA))

       oEntry:SetField("HistoryCode"  , EC6->EC6_COD_HI)

       oEntry:SetField("ComplementaryHistory"  , Left("Evento: " + AllTrim(EF3->EF3_CODEVE) + " Contrato: " + AllTrim(EF3->EF3_CONTRA) + If(!Empty(EF3->EF3_INVOIC), " Invoice: " + AllTrim(EF3->EF3_INVOIC), ""), 200))

       oEntry:SetField("CostCenterCode"  , EC6->EC6_CCUSTO)
      
       aAdd(aDtEve, EF3->EF3_DT_EVE) // Armazena data para verificar menor e maior data do lote.

	   If EasyEntryPoint("EECAF225")
          ExecBlock("EECAF225", .f., .f., "LANCAMENTO_CONTABIL")
       Endif
	   
       oEntries:SetField("Entry" , oEntry)
       
       cSeq := StrZero(Val(SomaIt(cSeq)),4,0)
    Next i
    
    oEvent:SetField("Identification",oIdent)
    
    // Verifica menor e maior data do lote
    nUltimo := Len(aDtEve)
    If nUltimo > 0
       aSort(aDtEve)
       oBusiness:SetField("PeriodStartDate"  , EasyTimeStamp(aDtEve[1], .T., .T.))
       oBusiness:SetField("PeriodEndDate"    , EasyTimeStamp(aDtEve[nUltimo], .T., .T.))
    EndIf
    
	If !Empty(EF3->EF3_NRLOTE) .And. Type("nEAIEvent") <> "U" .And. nEAIEvent == 5 // Exclusao
       oBusiness:SetField("BatchNumber" , EF3->EF3_NRLOTE)
    /*Else
       oBusiness:SetField("BatchNumber" , "")*/  //NCF - 21/06/2016 - Não enviar se estiver vazio (Validação do .xsd)
    EndIf
	
    oBusiness:SetField("Entries",oEntries)
    oRec:SetField("BusinessEvent",oEvent)
    oRec:SetField("BusinessContent",oBusiness)
    oXml:AddRec(oRec)
	
Return oXml

/* ====================================================*
* Função:		AF225ARESR
* Parametros:	oEasyMessage
* Objetivo:	Efetua integração com Logix 
* Obs:			-
* Autor:		Guilherme Fernandes Pilan - GFP
* Data:		19/01/2012 - 11:48
* =====================================================*/
*-------------------------------------------------*
Function AF225ARESR(oEasyMessage) 
*-------------------------------------------------*
Local oBusinessCont 
Local oBusinessEvent := oEasyMessage:GetEvtContent()
Local cContract := "", cTpMod := "", cBanco := "", cPraca := "", cSequence := ""
Local i
Local aKey, aEntry, xEntry
Local cLote := ""
Local aOrd  := SaveOrd("EF3")

   If !(ValType(oBusinessEvent:_IDENTIFICATION:_Key) == "A")
      aKey := {oBusinessEvent:_IDENTIFICATION:_Key}
   Else
      aKey := oBusinessEvent:_IDENTIFICATION:_Key
   EndIf

   If Type("nEAIEvent") == "U"
      nEAIEvent:= 0
   EndIf

   aEval(aKey,  {|x| If(x:_NAME:Text == "Contract" , cContract := x:TEXT,) }) 
   aEval(aKey,  {|x| If(x:_NAME:Text == "Module"   , cTpMod := x:TEXT,)     })
   aEval(aKey,  {|x| If(x:_NAME:Text == "Bank"     , cBanco := x:TEXT,)     })
   aEval(aKey,  {|x| If(x:_NAME:Text == "Place"    , cPraca := x:TEXT,)     })
   aEval(aKey,  {|x| If(x:_NAME:Text == "Sequence" , cSequence := x:TEXT,) })
   
   If !oEasyMessage:HasErrors()
      
      oBusinessCont  := oEasyMessage:GetRetContent() 
      cLote := oBusinessCont:_BatchNumber:TEXT
      If !(ValType(oBusinessCont:_Entries:_Entry) == "A")
         aEntry := {oBusinessCont:_Entries:_Entry}
      Else
         aEntry := oBusinessCont:_Entries:_Entry
      EndIf

      For i := 1 To Len(aEntry)
         EF3->(DbSetOrder(8)) //EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_NR_CON
         xEntry := Val(aEntry[i]:_EntryNumber:TEXT)
         xEntry := StrZero(xEntry,AVSX3("EF3_NR_CON",3),AVSX3("EF3_NR_CON",4)) //Tamanho, Decimal
         
         cChave := xFilial("EF3")+AvKey(cTpMod,"EF3_TPMODU")+AvKey(cContract,"EF3_CONTRA")+AvKey(cBanco,"EF3_BAN_FI")+AvKey(cPraca,"EF3_PRACA")+AvKey(cSequence,"EF3_SEQCNT")+xEntry

         EF3->(DbSeek(cChave))
         Do While EF3->( !Eof() .AND. cChave == EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_NR_CON)
            If Empty(EF3->EF3_NRLOTE) .OR. nEAIEvent == 5 .AND. EF3->EF3_NRLOTE == AvKey(cLote,"EF3_NRLOTE")
               EXIT
            EndIf
            
            EF3->(dbSkip())
         EndDo
         
         If !Eof() .AND. cChave == EF3->(EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_NR_CON)
            Begin Transaction
               EF3->(RecLock("EF3",.F.))
               If nEAIEvent == 5 //Exclusao			   
                  EF3->EF3_NRLOTE := ""
                  EF3->EF3_RELACA := ""
               Else
                  EF3->EF3_NRLOTE := cLote
                  EF3->EF3_RELACA := aEntry[i]:_RelationshipNumber:TEXT //EasyGetXMLinfo(, oBusinessCont:_Entries:_Entry, "_RelationshipNumber")
               EndIf
               EF3->(MsUnlock())  
            End Transaction
         EndIf
      Next i
   Else
      EF3->(DbSetOrder(8)) //EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_NR_CON
      EF3->(DbSeek(xFilial("EF3")+AvKey(cTpMod,"EF3_TPMODU")+AvKey(cContract,"EF3_CONTRA")+AvKey(cBanco,"EF3_BAN_FI")+AvKey(cPraca,"EF3_PRACA")+AvKey(cSequence,"EF3_SEQCNT")))      
	  Do While !EF3->(Eof()) .And. xFilial("EF3") == EF3->EF3_FILIAL .And. AvKey(cTpMod,"EF3_TPMODU") == EF3->EF3_TPMODU .And. ;
	                               AvKey(cContract,"EF3_CONTRA") == EF3->EF3_CONTRA .And. AvKey(cBanco,"EF3_BAN_FI") == EF3->EF3_BAN_FI .And. ;
	                               AvKey(cPraca,"EF3_PRACA") == EF3->EF3_PRACA .And. AvKey(cSequence,"EF3_SEQCNT") == EF3->EF3_SEQCNT

         If !Empty(EF3->EF3_NR_CON) .And. Empty(EF3->EF3_NRLOTE) .And. Empty(EF3->EF3_RELACA)
            Begin Transaction
               EF3->(RecLock("EF3",.F.))
  		       EF3->EF3_NR_CON := ""
               EF3->(MsUnlock())  
            End Transaction
         EndIf
         
		 EF3->(dbSkip())
      EndDo
   EndIf

RestOrd(aOrd,.T.)   

Return oEasyMessage

//AAF 04/09/2015 - Espera o EF3 posicionado para retornar as contas debito e credito
Function AF225GetContas(oObj)
Local cCtaDebit := cCtaCredit := ""
Local cIncoterm := "" //THTS - 01/06/2017 - TE-5822 - Contabilização com conta contabil por Incoterm
Local aOrdEEC   := {} //THTS - 01/06/2017 - TE-5822 - Contabilização com conta contabil por Incoterm

EC6->(dbSeek(xFilial("EC6")+If(EF3->EF3_TPMODU == "E","FIEX","FIIM")+EF3->EF3_TP_EVE+EF3->EF3_CODEVE)) /*EF1->EF1_TP_FIN*/ //AAF 29/07/2014 - Usar tipo de evento do EF3, pois pode ser diferente do EF1 no ACC/ACE
	   
//If EF1->EF1_TP_FIN $ "01/02/03" //ACC/ACE/PRE
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
//EndIf

If Type("nEAIEvent") <> "U"
   If nEAIEvent == 5 //Exclusao
	  If Empty(EC6->EC6_CDBEST)
	 	 cCtaDebit := EC6->EC6_CTA_CR
	  Else
		 cCtaDebit := EC6->EC6_CDBEST
	  EndIf
	
	  If Empty(EC6->EC6_CCREST)
		 cCtaCredit := EC6->EC6_CTA_DB
	  Else
		  cCtaCredit := EC6->EC6_CCREST
	  EndIf            
   Else
	  cCtaDebit  := EC6->EC6_CTA_DB
	  cCtaCredit := EC6->EC6_CTA_CR
   EndIf
Else                                   //NCF - 22/06/2016
   cCtaDebit  := EC6->EC6_CTA_DB
   cCtaCredit := EC6->EC6_CTA_CR
EndIf

If !Empty(EF3->EF3_FORN)
   cForn := EF3->EF3_FORN
   If EF3->(FieldPos("EF3_LOJAFO")) > 0
 	  cLojaFor := EF3->EF3_LOJAFO
   Else
	  cLojaFor := ""
   EndIf
Else
   SA6->(DbSetOrder(1))//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
   SA6->(DbSeek(xFilial("SA6") +AvKey(EF1->EF1_BAN_FI,"A6_COD") +AvKey(EF1->EF1_AGENFI,"A6_AGENCIA") +AvKey(EF1->EF1_NCONFI,"A6_NUMCON")))
  
   cForn    := SA6->A6_CODFOR
   cLojaFor := SA6->A6_LOJFOR
EndIf

//THTS - 01/06/2017 - TE-5822 - Contabilização com conta contabil por Incoterm
If !Empty(EF3->EF3_PREEMB)
    aOrdEEC := SaveOrd({"EEC"})
    EEC->(dbSetOrder(1)) //EEC_FILIAL + EEC_PREEMB
    EEC->(dbSeek(xFilial("EEC") + EF3->EF3_PREEMB))
    cIncoterm := EEC->EEC_INCOTE
    RestOrd(aOrdEEC,.T.)
EndIf

cCtaDebit  := EasyMascCon(cCtaDebit ,cForn,cLojaFor,"","",cBanMov,cAgMov,cCtaMov,If(EF1->EF1_TPMODU <> "I","FIEX","FIIM")+ EF1->EF1_TP_FIN,EF3->EF3_CODEVE,oObj,cIncoterm) //NCF - 15/10/2013 - Alteração na formaçao da chave do tipo de Modulo
cCtaCredit := EasyMascCon(cCtaCredit,cForn,cLojaFor,"","",cBanMov,cAgMov,cCtaMov,If(EF1->EF1_TPMODU <> "I","FIEX","FIIM")+ EF1->EF1_TP_FIN,EF3->EF3_CODEVE,oObj,cIncoterm) //NCF - 15/10/2013 - Alteração na formaçao da chave do tipo de Modulo

Return {cCtaDebit,cCtaCredit}
