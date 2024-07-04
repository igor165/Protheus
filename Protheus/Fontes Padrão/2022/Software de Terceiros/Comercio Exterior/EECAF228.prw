#Include 'Protheus.ch'

/* ====================================================*
* Função: 		EECAF228
* Parametros:	nOpc
* Objetivo:	Efetua integração com Logix
* Obs:			Estorno da Contab. de eventos do contrato de financiamento
* Autor:		Guilherme Fernandes Pilan - GFP
* Data:		26/01/2012 - 09:44
* =====================================================*/
*----------------------------*
Function EECAF228(nOpc)
*----------------------------*
//Funcao utilizada apenas para cadastrar o PRW no Adapter:
Private aRotina   := MenuDef()

Return Nil

/* ====================================================*
* Função:		MenuDef
* Parametros:	-
* Objetivo:	Menu da Rotina
* Obs: 		-
* Autor:		Guilherme Fernandes Pilan - GFP
* Data:		26/01/2012 - 09:44
* =====================================================*/
*----------------------------*
Static Function MenuDef()
*----------------------------*

Local aRotina :=  {{ "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","AF228MAN" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "AF228MAN" , 0 , 3},; //"Incluir"
                     { "Alterar",   "AF228MAN" , 0 , 4},; //"Alterar"
                     { "Excluir",   "AF228MAN" , 0 , 5} } //"Excluir"                  

Return aRotina

*----------------------------*
Static Function AF228MAN()
*----------------------------*
Return Nil

/* ====================================================*
* Função:		IntegDef
* Parametros:	cXML, nTypeTrans, cTypeMessage
* Objetivo:	Efetua integração com Logix 
* Obs:			-
* Autor:		Guilherme Fernandes Pilan - GFP
* Data:		26/01/2012 - 11:31
* =====================================================*/
*-------------------------------------------------------*
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
*-------------------------------------------------------*
Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("ECE")
	oEasyIntEAI:SetModule("EFF",30) 
		
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF228ASENB") //ENVIO DE BUSINESS MESSAGE           (<-Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF228ARESR") //RESPOSTA SOBRE O ENVIO DA BUSINESS  (->Response)
	
	oEasyIntEAI:Execute()

Return oEasyIntEAI:GetResult()

/* ====================================================*
* Função:		AF228ASENB
* Parametros:	cXML, nTypeTrans, cTypeMessage
* Objetivo:	Efetua integração com Logix 
* Obs:			-
* Autor:		Guilherme Fernandes Pilan - GFP
* Data:		26/01/2012 - 11:32
* =====================================================*/
*---------------------------------*
Function AF228ASENB(oEasyMessage) 
*---------------------------------*
Local oXml          := EXml():New()
Local oBusiness    := ENode():New()
Local oEntries     := ENode():New()
Local oEntry, oKeyNode
Local oRec        := ENode():New()
Local oEvent      := ENode():New()
Local oIdent      := ENode():New()
Local nUltimo, aDtEve := {}
Local cSeq := "", cSeqAli := "", cChaveECE := ""

   EC6->(DbSetOrder(1)) //EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","Contract"))
   oKeyNode:SetField(ETag():New("" ,ECE->ECE_CONTRA))
   oIdent:SetField(ETag():New("key",oKeyNode))
   
   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","Module"))
   oKeyNode:SetField(ETag():New("" ,ECE->ECE_TPMODU))
   oIdent:SetField(ETag():New("key",oKeyNode)) 

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","Bank"))
   oKeyNode:SetField(ETag():New("" ,ECE->ECE_BANCO))
   oIdent:SetField(ETag():New("key",oKeyNode)) 
   
   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","Place"))
   oKeyNode:SetField(ETag():New("" ,ECE->ECE_PRACA))
   oIdent:SetField(ETag():New("key",oKeyNode)) 

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","Sequence"))
   oKeyNode:SetField(ETag():New("" ,ECE->ECE_SEQCNT))
   oIdent:SetField(ETag():New("key",oKeyNode)) 
   
   oEvent:SetField("Entity" , "EECAF228")
   oEvent:SetField("Event" , "upsert")
 
   oBusiness:SetField("CompanyId"  , SM0->M0_CODIGO)
   oBusiness:SetField("BranchId"   , AvGetM0Fil())
   oBusiness:SetField("OriginCode" , "EFF")

   // Sequencia automática do Número Contabil 
   If Select("Work") > 0
      Work->(DbCloseArea()) 
      FErase("Work")   
   EndIf

   cQuery := "SELECT * FROM " + RetSqlName("ECE") + " WHERE ECE_NR_CON <> '' AND D_E_L_E_T_ = '' ORDER BY ECE_NR_CON DESC"
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "Work", .T., .T.)

   cSeqAli := Work->ECE_NR_CON

   If !Empty(cSeqAli)   
      cSeq := StrZero(Val(SomaIt(cSeqAli)),4,0)
   Else
      cSeq := StrZero(1,4,0)
   EndIf

   cChaveECE := ECE->(ECE_FILIAL+ECE_TPMODU+ECE_CONTRA+ECE_BANCO+ECE_PRACA+ECE_SEQCNT)
   
   // Looping nos Eventos do Contrato de Financiamento Excluídos sem Contabilização
   Do While ECE->(!Eof()) .AND. ECE->(ECE_FILIAL+ECE_TPMODU+ECE_CONTRA+ECE_BANCO+ECE_PRACA+ECE_SEQCNT) == cChaveECE
   
      If Empty(ECE->ECE_NR_CON) .AND. ECE->ECE_VALOR <> 0  // Sem Número de Contabilização e Valor diferente de 0
         Private oEntry   := ENode():New()
      
         If RecLock("ECE",.F.)
            ECE->ECE_NR_CON := cSeq
            ECE->(MsUnlock())
         EndIf
         
         oEntry:SetField("EntryNumber"  , ECE->ECE_NR_CON)
        
         EC6->(DbSeek(xFilial("EC6")+If(ECE->ECE_TPMODU == "E","EXPORT","IMPORT")+ECE->ECE_ID_CAM))
      
         oEntry:SetField("DebitAccountCode"  , EC6->EC6_CDBEST)
         oEntry:SetField("CreditAccountCode" , EC6->EC6_CCREST)

         oEntry:SetField("MovementDate"  , EasyTimeStamp(ECE->ECE_DT_LAN, .T., .T.))
		 
		 oEntry:SetField("EntryValue"  , Abs(ECE->ECE_VALOR))

         oEntry:SetField("HistoryCode"  , EC6->EC6_COD_HI)   

         oEntry:SetField("ComplementaryHistory"  , Left("Evento: " + AllTrim(ECE->ECE_ID_CAM) + " Contrato: " + AllTrim(ECE->ECE_CONTRA) + If(!Empty(ECE->ECE_INVEXP), " Invoice: " + AllTrim(ECE->ECE_INVEXP), ""), 200))

         oEntry:SetField("CostCenterCode"  , EC6->EC6_CCUSTO)
    
         aAdd(aDtEve, ECE->ECE_DT_LAN) // Armazena data para verificar menor e maior data do lote.
		 
		 If EasyEntryPoint("EECAF228")
            ExecBlock("EECAF228", .f., .f., "LANCAMENTO_CONTABIL")
         Endif

         oEntries:SetField("Entry" , oEntry)
         
         cSeq := StrZero(Val(SomaIt(cSeq)),4,0)
      EndIf      
      ECE->(DbSkip())
   EndDo

   oEvent:SetField("Identification",oIdent)

   // Verifica menor e maior data do lote
   nUltimo := Len(aDtEve)
   If nUltimo > 0
      aSort(aDtEve)
      oBusiness:SetField("PeriodStartDate"  , EasyTimeStamp(aDtEve[1], .T., .T.))
      oBusiness:SetField("PeriodEndDate"    , EasyTimeStamp(aDtEve[nUltimo], .T., .T.))
   EndIf
   
   oBusiness:SetField("Entries",oEntries) 
   oRec:SetField("BusinessEvent",oEvent) 
   oRec:SetField("BusinessContent",oBusiness) 
   oXml:AddRec(oRec)

Return oXml

/* ====================================================*
* Função:		AF228ARESR
* Parametros:	oEasyMessage
* Objetivo:	Efetua integração com Logix 
* Obs:			-
* Autor:		Guilherme Fernandes Pilan - GFP
* Data:		26/01/2012 - 11:48
* =====================================================*/
*-------------------------------------------------*
Function AF228ARESR(oEasyMessage) 
*-------------------------------------------------*
Local oBusinessCont  := oEasyMessage:GetRetContent()
Local oBusinessEvent := oEasyMessage:GetEvtContent()
Local cContract := "", cTpMod := "", cBanco := "", cPraca := "", cSequence := ""
Local i
Local aKey, aEntry, xEntry

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

   aEval(aKey,  {|x| If(x:_NAME:Text == "Contract" , cContract := x:TEXT,) }) 
   aEval(aKey,  {|x| If(x:_NAME:Text == "Module"   , cTpMod := x:TEXT,)     })
   aEval(aKey,  {|x| If(x:_NAME:Text == "Bank"     , cBanco := x:TEXT,)     })
   aEval(aKey,  {|x| If(x:_NAME:Text == "Place"    , cPraca := x:TEXT,)     })
   aEval(aKey,  {|x| If(x:_NAME:Text == "Sequence" , cSequence := x:TEXT,) })
   
   For i := 1 To Len(aEntry)
      ECE->(DbSetOrder(5)) //ECE_FILIAL+ECE_TPMODU+ECE_CONTRA+ECE_BANCO+ECE_PRACA+ECE_SEQCNT+ECE_NR_CON
	  xEntry := Val(aEntry[i]:_EntryNumber:TEXT)
      xEntry := StrZero(xEntry,AVSX3("ECE_NR_CON",3),AVSX3("ECE_NR_CON",4)) //Tamanho, Decimal
        
	  If ECE->(DbSeek(xFilial("ECE")+AvKey(cTpMod,"ECE_TPMODU")+AvKey(cContract,"ECE_CONTRA")+AvKey(cBanco,"ECE_BANCO")+AvKey(cPraca,"ECE_PRACA")+AvKey(cSequence,"ECE_SEQCNT")+xEntry))
         Begin Transaction
            ECE->(RecLock("ECE",.F.))
            ECE->ECE_RELACA := aEntry[i]:_RelationshipNumber:TEXT //EasyGetXMLinfo(, oBusinessCont:_Entries:_Entry, "_RelationshipNumber")
            ECE->(MsUnlock())  
         End Transaction
      
      EndIf
   Next i
   
Return oEasyMessage
