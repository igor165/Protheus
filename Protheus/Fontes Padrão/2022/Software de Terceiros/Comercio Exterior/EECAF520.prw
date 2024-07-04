#Include 'Protheus.ch'


/* ====================================================*
* Função: EECAF520
* Parametros: nOpc: 3 Inclusao; 5 - Exclusão
* Objetivo: Adapter de integração do Logix para adiantamentos de fornecedores 
* Obs: 
* Autor: Tiago Henrique Tudisco dos Santos - THTS
* Data:  04/04/2017
* =====================================================*/
Function EECAF520(nOpc)
Local aOrdAF520	:= SaveOrd({"EEC","EEQ"}) 

If (nOpc == 3 .And. Empty(EEQ->EEQ_FINNUM)) .Or. (nOpc == 5 .And. !Empty(EEQ->EEQ_FINNUM) .And. Empty(EEQ->EEQ_SEQBX))

	aAdd(aEAIAF520,{EEQ->EEQ_EVENT,EEQ->EEQ_FORN,EEQ->EEQ_FOLOJA,nOpc,{EEQ->(Recno())}})
	EasyEnvEAI("EECAF520",nOpc)
	
EndIf

RestOrd(aOrdAF520,.T.)
Return .T.


/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: Tiago Henrique Tudisco dos Santos - THTS
* Data:  04/04/2017
* =====================================================*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)

	oEasyIntEAI:oMessage:SetVersion("1.000")
	oEasyIntEAI:oMessage:SetMainAlias("EEQ")

	oEasyIntEAI:SetModule("EEC",29)

	//Envio##Resposta
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF520ASENB")//ENVIO DE BUSINESS MESSAGE           (<-Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF520ARESR")//RESPOSTA SOBRE O ENVIO DA BUSINESS  (->Response)

	oEasyIntEAI:Execute()

Return oEasyIntEAI:GetResult()


/*========================================================================================
Funcao Adapter: AF520ASENB
Parametros    : "oMessage" - Objeto XML com conteúdo da tag "BusinessContent" recebida                
Objetivos     : Envio da Business 
Autor         : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora     : 04/04/2017
Revisao       : 
Obs.          : 
==========================================================================================*/
Function AF520ASENB(oEasyMessage)

Local oXml			:= EXml():New()
Local oBusiness  	:= ENode():New()
Local oBusinEvent	:= ENode():New()
Local oIdent		:= ENode():New()
Local oRec			:= ENode():New()
Local cEvent		:= ""
Local cBanco		:= ""
Local cAgencia	:= ""
Local cConta		:= ""
Local cEmpMsg		:= SM0->M0_CODIGO
Local cFilMsg		:= AvGetM0Fil()
Local aOrd			:= {}
Local aAF520REC 	:= {}
Local oKeyNode
Local oAccountPayable
Local oListOfAccountPayable
Local dEmissao
Local dDtVenc
Local cParam, nPosDiv, nI
Local oSD
Local oSDT
Local nPos
Local aArrayCC := {}
Local oDistr
Local oCost
Local nY
aOrd := SaveOrd({"EC6","EEQ","SYF","SA6"}) 

If !Empty( cParam := Alltrim(EasyGParam("MV_EEC0036",,"")) )
	If (nPosDiv := At('/',cParam)) > 0
		cEmpMsg := Substr(cParam,1,nPosDiv-1) 
		cFilMsg := Substr(cParam,nPosDiv+1,Len(cParam))
	Else
		cEmpMsg := cParam 
		cFilMsg := cParam         
	EndIf  
EndIf

//Verifica os recnos que serao executados na mesma list da mensagem
If Type("aEAIAF520") != "U"
	nPos := aScan(aEAIAF520,{|x| x[1] == EEQ->EEQ_EVENT .And. x[2] == EEQ->EEQ_FORN .And. x[3] == EEQ->EEQ_FOLOJA .And. x[4] == nEAIEvent})
	If nPos > 0
		aAF520REC := aClone(aEAIAF520[nPos][5])
	Else
		aAF520REC := {EEQ->(Recno())}
	EndIf
EndIf

//Entity e Event
oBusinEvent:SetField("Entity", "EECAF520")
cEvent := If(nEAIEvent == 3,"upsert","delete")
oBusinEvent:SetField("Event" ,cEvent )

//<Identification>
oKeyNode:= ENode():New()
oKeyNode:SetField(EAtt():New("name"	,"Branch"))
oKeyNode:SetField(ETag():New(""			,EEQ->EEQ_FILIAL))
oIdent:SetField(ETag():New("key"		,oKeyNode))

oKeyNode:= ENode():New()
oKeyNode:SetField(EAtt():New("name"	,"Process"))
oKeyNode:SetField(ETag():New(""			,EEQ->EEQ_PREEMB))
oIdent:SetField(ETag():New("key"		,oKeyNode))

oKeyNode:= ENode():New()
oKeyNode:SetField(EAtt():New("name"	,"Invoice"))
oKeyNode:SetField(ETag():New(""			,EEQ->EEQ_NRINVO))
oIdent:SetField(ETag():New("key"		,oKeyNode))

oKeyNode:= ENode():New()
oKeyNode:SetField(EAtt():New("name"	,"Vendor"))
oKeyNode:SetField(ETag():New(""			,EEQ->EEQ_FORN))
oIdent:SetField(ETag():New("key"		,oKeyNode))

oKeyNode:= ENode():New()
oKeyNode:SetField(EAtt():New("name"	,"Store"))
oKeyNode:SetField(ETag():New(""			,EEQ->EEQ_FOLOJA))
oIdent:SetField(ETag():New("key"		,oKeyNode))

/*oKeyNode   := ENode():New()
oKeyNode:SetField(EAtt():New("name"	,"Event"))
oKeyNode:SetField(ETag():New(""			,EEQ->EEQ_EVENT ))
oIdent:SetField(ETag():New("key"		,oKeyNode))
*/
oBusinEvent:SetField("Identification"		,oIdent)

oBusiness:SetField("CompanyId"				,cEmpMsg)
oBusiness:SetField("CompanyInternalId"		,cEmpMsg)
oBusiness:SetField("BranchId"				,cFilMsg)
oBusiness:SetField("batchNumber"			,"")//Não utilizado

oListOfAccountPayable	:= ENode():New()

For nI := 1 To Len(aAF520REC) //Recno das parcelas
	
	oAccountPayable			:= ENode():New()
	
	EEQ->(dbGoTo(aAF520REC[nI]))
	
	EC6->(dbSetOrder(1))//EC6_FILIAL + EC6_TPMODU + EC6_ID_CAM + EC6_IDENTC
	EC6->(dbSeek(xFilial("EC6") + AvKey("EXPORT","EC6_TPMODU") + AvKey(EEQ->EEQ_EVENT,"EC6_ID_CAM")))
	
	oAccountPayable:SetField("InternalId"				,EEQ->(RecNo()))
	oAccountPayable:SetField("DocumentPrefix"			,EC6->EC6_PREFIX)
	oAccountPayable:SetField("DocumentNumber"			,EEQ->EEQ_FINNUM)
	oAccountPayable:SetField("DocumentParcel"			,Right(EEQ->EEQ_PARC,1))
	oAccountPayable:SetField("DocumentTypeCode"			,EC6->EC6_TPTIT)
	oAccountPayable:SetField("BlockAmendmentDocument","B") //Bloqueado no Logix

	If EEQ->EEQ_TIPO == "P" .And. IsInCallStack("EECAE100") .And. EEQ->EEQ_EVENT != "609"//Cambio a Pagar
		oSD    := ENode():New()
		oSDT    := ENode():New()
		oSD:SetField('SourceDocument'					,Substr(EEC->EEC_PREEMB,1,10))  
		oSD:SetField('SourceDocumentValue'				,EEC->EEC_TOTPED)
		oSDT:SetField('SourceDocument'           		,oSD)
		oAccountPayable:SetField('ListOfSourceDocument'	,oSDT)
	EndIf

	If Empty(EEQ->EEQ_PGT)
		dEmissao	:= EEQ->EEQ_EMISSA //Data de Emissao
	Else
		dEmissao	:= EEQ->EEQ_PGT //Data de Liquidacao
	EndIf

	dDtVenc 	:= EEQ->EEQ_VCT //Data de Vencimento
	If dDtVenc < dEmissao
		dDtVenc := dEmissao
	EndIf
	
	oAccountPayable:SetField("IssueDate"				,EasyTimeStamp(dEmissao,.T.,.T.))
	oAccountPayable:SetField("DueDate"					,EasyTimeStamp(dDtVenc,.T.,.T.))
	oAccountPayable:SetField("RealDueDate"				,EasyTimeStamp(DataValida(dDtVenc),.T.,.T.))
	oAccountPayable:SetField("VendorCode"				,EEQ->EEQ_FORN)
	oAccountPayable:SetField("VendorInternalId"		,EEQ->EEQ_FORN)
	oAccountPayable:SetField("StoreId"					,EEQ->EEQ_FOLOJA)
	oAccountPayable:SetField("NetValue"				,EEQ->EEQ_VL)
	oAccountPayable:SetField("GrossValue"				,EEQ->EEQ_VL)
	
	SYF->(dbSetOrder(1)) //YF_FILIAL+YF_MOEDA
	SYF->(dbSeek(xFilial() + EEQ->EEQ_MOEDA))
	If EC6->EC6_TXCV == "2" //COMPRA 
		oAccountPayable:SetField('CurrencyCode'       ,SYF->YF_CODCERP)
	Else //VENDA
		oAccountPayable:SetField('CurrencyCode'       ,SYF->YF_CODVERP)
	EndIf
	
	oAccountPayable:SetField("CurrencyInternalId"		,EEQ->EEQ_MOEDA)
	If EEQ->EEQ_EVENT == "609" .And. EEQ->EEQ_TIPO == "A" //Adiantamento
		oAccountPayable:SetField("CurrencyRate"			,EEQ->EEQ_TX)
	Else
		oAccountPayable:SetField("CurrencyRate"			,STR(BuscaTaxa(EEQ->EEQ_MOEDA,EEC->EEC_DTEMBA,,.F.,,,EC6->EC6_TXCV)))
	EndIf
	//Rateio por Centro de Custo
	aArrayCC := EECRatItEmb(EEC->EEC_PREEMB,EEQ->EEQ_VL)
    oDistr    := ENode():New()
    For nY := 1 To Len(aArrayCC)
       oCost     := ENode():New()
       oCost:SetField("CostCenterInternalId",aArrayCC[nY][1])
       oCost:SetField("Value"         ,aArrayCC[nY][2])

       oDistr:SetField('Apportionment',oCost)
    Next i
    
    If !Empty(aArrayCC)
      oAccountPayable:SetField('ApportionmentDistribution',oDistr)
    EndIf

	If EEQ->EEQ_EVENT == "609" .And. EEQ->EEQ_TIPO == "A" //Adiantamento
		//Dados bancarios
		oBank:=ENode():New()      
		
		cBanco		:= EEQ->EEQ_BANC
		cAgencia	:= EEQ->EEQ_AGEN
		cConta		:= EEQ->EEQ_NCON
		
		SA6->(dbSetOrder(1)) //A6_FILIAL + A6_COD + A6_AGENCIA + A6_NUMCON
		If SA6->(dbSeek(xFilial("SA6") + EEQ->EEQ_BANC + EEQ->EEQ_AGEN + EEQ->EEQ_NCON))
			If !Empty(SA6->A6_DVAGE)
				cAgencia:= AllTrim(SA6->A6_AGENCIA) + "-" + SA6->A6_DVAGE
			EndIf
			If !Empty(SA6->A6_DVCTA)
				cConta:= AllTrim(SA6->A6_NUMCON) + "-" + SA6->A6_DVCTA
			EndIf
		EndIf
		
		oBank:SetField("BankCode"				, cBanco)
		oBank:SetField("BankAgency"				, cAgencia)      
		oBank:SetField("BankAccount"			, cConta)
		//Fim dados bancarios
		
		oAccountPayable:SetField("Bank"			,oBank)
	EndIf
	
	oAccountPayable:SetField("Observation"	,EEQ->EEQ_OBS)
	oAccountPayable:SetField("Origin"		,"SIGAEEC")

	oAccountPayable:SetField("FinancialNatureInternalId",EC6->EC6_NATFIN)

	oListOfAccountPayable:SetField("AccountPayableDocument"	, oAccountPayable)

Next

oBusiness:SetField("ListOfAccountPayableDocument"		, oListOfAccountPayable)

oRec:SetField("BusinessEvent"	,oBusinEvent)
oRec:SetField("BusinessContent"	,oBusiness)
oXml:AddRec(oRec)

RestOrd(aOrd,.T.)

Return oXml


/*========================================================================================
Funcao Adapter: AF520ARESR
Parametros    : "oEasyMessage" - Objeto XML com conteúdo da tag "BusinessContent" recebida                
Objetivos     : RECEBER uma RESPONSE (apos envio de BUSINNES) e gravar arquivo 
Autor         : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora     : 04/04/2017
Revisao       : 
Obs.          : 
==========================================================================================*/
Function AF520ARESR(oEasyMessage)

Local oRetCont       := oEasyMessage:GetRetContent()
Local oBusinessEvent := oEasyMessage:GetEvtContent()
Local cEvent		 := ""
Local nI
Local aArray		 := {}
Local oList
Local nEEQRec
Local cDocNumber
Local aOrd

aOrd := SaveOrd({"EC6"})

cEvent:= EasyGetXMLinfo(,oBusinessEvent, "_Event" )//Evento do XML
If isCpoInXML(oRetCont, "_ListOfInternalIdDocument") .And. isCpoInXML(oRetCont:_ListOfInternalIdDocument, "_InternalIdDocument")

	oList:= oRetCont:_ListOfInternalIdDocument:_InternalIdDocument
	If ValType(oList) <> "A"
		aArray := {oList}
	Else
		aArray := oList
	EndIf

	For nI := 1 To len(aArray)
		nEEQRec    	:= Val(EasyGetXMLinfo(,aArray[nI],"_Origin"))
		cDocNumber 	:= EasyGetXMLinfo(,aArray[nI],"_destination")

		EEQ->(dbGoTo(nEEQRec))

		EC6->(dbSetOrder(1))//EC6_FILIAL + EC6_TPMODU + EC6_ID_CAM + EC6_IDENTC
		EC6->(dbSeek(xFilial("EC6") + AvKey("EXPORT","EC6_TPMODU") + AvKey(EEQ->EEQ_EVENT,"EC6_ID_CAM")))		
		
		EEQ->(Reclock("EEQ",.F.))
		If Upper(cEvent) == "UPSERT" //Inclusao
			EEQ->EEQ_FINNUM	:= cDocNumber
			EEQ->EEQ_PREFIX	:= EC6->EC6_PREFIX
			EEQ->EEQ_TPTIT	:= EC6->EC6_TPTIT
		Else //Exclusao
			EEQ->EEQ_FINNUM := ""
		EndIf
		EEQ->(MsUnlock())

	Next i

EndIf

RestOrd(aOrd,.T.)

Return oEasyMessage
