#Include 'Protheus.ch'


/* ====================================================*
* Função: EECAF521
* Parametros: 
* Objetivo: Adapter de integração do Logix para compensacao de adiantamentos a fornecedores
* Obs: 
* Autor: Tiago Henrique Tudisco dos Santos - THTS
* Data:  18/04/2017
* =====================================================*/
Function EECAF521(nOpc)
Local nI 		:= 0
Local aOrdAF521	:= SaveOrd({"EEQ"}) 

If (nOpc == 3 .And. !Empty(EEQ->EEQ_FINNUM) .And. Empty(EEQ->EEQ_SEQBX))

	EasyEnvEAI("EECAF521",nOpc)
	
EndIf

RestOrd(aOrdAF521,.T.)
Return .T.


/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: Tiago Henrique Tudisco dos Santos - THTS
* Data:  18/04/2017
* =====================================================*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)

	oEasyIntEAI:oMessage:SetVersion("1.001")
	oEasyIntEAI:oMessage:SetMainAlias("EEQ")

	oEasyIntEAI:SetModule("EEC",29)

	//Envio##Resposta
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF521ASENB")//ENVIO DE BUSINESS MESSAGE           (<-Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF521ARESR")//RESPOSTA SOBRE O ENVIO DA BUSINESS  (->Response)

	oEasyIntEAI:Execute()

Return oEasyIntEAI:GetResult()


/*========================================================================================
Funcao Adapter: AF521ASENB
Parametros    : "oMessage" - Objeto XML com conteúdo da tag "BusinessContent" recebida                
Objetivos     : Envio da Business 
Autor         : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora     : 18/04/2017
Revisao       : 
Obs.          : 
==========================================================================================*/
Function AF521ASENB(oEasyMessage)

Local oXml          := EXml():New()
Local oBusiness     := ENode():New()
Local oRequest      := ENode():New() 
Local oRec          := ENode():New()
Local oCont		    := ENode():New()
Local aOrdAF521     := SaveOrd({"EEQ","EC6","SYF","SA6"}) 
Local oCompensa
Local oList
Local oBank
Local cNumAdt

EC6->(dbSetOrder(1)) //EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
SYF->(dbSetOrder(1)) //YF_FILIAL+YF_MOEDA

EC6->(dbSeek(xFilial("EC6") + "EXPORT" + EEQ->EEQ_EVENT))

oRequest:SetField("Operation", "EECAF521")

//<BusinessContent>
oBusiness:SetField("CompanyId"          ,SM0->M0_CODIGO)
oBusiness:SetField("BranchId"           ,FWFilial())

oBusiness:SetField("DocumentPrefix"     ,EEQ->EEQ_PREFIX)
oBusiness:SetField("DocumentNumber"     ,EEQ->EEQ_FINNUM)
oBusiness:SetField("DocumentParcel"     ,Right(EEQ->EEQ_PARC,1))
oBusiness:SetField("DocumentTypeCode"   ,EEQ->EEQ_TPTIT)
oBusiness:SetField("PaymentDate"        ,EasyTimeStamp(dDataBase,.T.,.T.))
oBusiness:SetField("PaymentValue"       ,EEQ->EEQ_VL)

If SYF->(dbSeek(xFilial("SYF") + AvKey(EEQ->EEQ_MOEDA, "YF_MOEDA")))
    If EC6->EC6_TXCV == "2"
        oBusiness:SetField('CurrencyCode'       ,SYF->YF_CODCERP)
    Else
        oBusiness:SetField('CurrencyCode'       ,SYF->YF_CODVERP)
    EndIf
EndIf
//Enviar a taxa da data de embarque na compensacao
oBusiness:SetField('CurrencyRate',EEQ->EEQ_TX)
oBusiness:SetField("VendorCode"  ,EEQ->EEQ_FORN)
oBusiness:SetField("StoreId"     ,EEQ->EEQ_FOLOJA)

oBusiness:SetField("PaymentMethodCode"  ,"004")
oBusiness:SetField("PaymentMeans"       ,"000")

//<Bank>
oBank:=ENode():New()

cBanco  := EEQ->EEQ_BANC
cAgencia:= EEQ->EEQ_AGEN
cConta  := EEQ->EEQ_NCON

SA6->(dbSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
If SA6->(dbSeek(xFilial("SA6") + EEQ->EEQ_BANC + EEQ->EEQ_AGEN + EEQ->EEQ_NCON))
    If !Empty(SA6->A6_DVAGE)
        cAgencia := AllTrim(SA6->A6_AGENCIA) + "-" + SA6->A6_DVAGE
    EndIf
    If !Empty(SA6->A6_DVCTA)
        cConta := AllTrim(SA6->A6_NUMCON) + "-" + SA6->A6_DVCTA
    EndIf
EndIf

oBank:SetField("BankCode"   , cBanco)
oBank:SetField("BankAgency" , cAgencia)
oBank:SetField("BankAccount", cConta)

oBusiness:SetField("Bank"      ,oBank)
//</Bank>

oBusiness:SetField("FinancialCode"     ,EC6->EC6_NATFIN)
oBusiness:SetField("HistoryText"       ,"")

oCont:SetField("DocumentPrefix"      ,""           )
oCont:SetField("DocumentNumber"      ,EEQ->EEQ_NROP)

oBusiness:SetField('PaymentDocument',oCont)

oBusiness:SetField("DischargeSequence" ,"1")

cNumAdt := AF521ADBUS() //Busca o numero do adiantamento

oCompensa := ENode():New()
oCompensa:SetField("CompensationValuesAdvance",EEQ->EEQ_VL)
oCompensa:SetField("DocumentNumber"           ,cNumAdt)

oList := ENode():New() 
oList:SetField("Compensation",oCompensa)

oBusiness:SetField("ListOfCompensation",oList)

oRec:SetField("BusinessRequest"     ,oRequest)
oRec:SetField("BusinessContent"     ,oBusiness)
oXml:AddRec(oRec)

RestOrd(aOrdAF521,.T.)

Return oXml


/*========================================================================================
Funcao Adapter: AF521ARESR
Parametros    : "oEasyMessage" - Objeto XML com conteúdo da tag "BusinessContent" recebida                
Objetivos     : RECEBER uma RESPONSE (apos envio de BUSINNES) e gravar arquivo 
Autor         : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora     : 18/04/2017
Revisao       : 
Obs.          : 
==========================================================================================*/
Function AF521ARESR(oEasyMessage)

Local oRetCont  := oEasyMessage:GetRetContent()
Local aOrd      := SaveOrd({"EEQ"})
Local cSeq      := ""           

If isCpoInXML(oRetCont, "_DischargeSequence")
    cSeq  := EasyGetXMLinfo("EEQ_SEQBX",oRetCont, "_DischargeSequence" )//Numero do Documento retornado pelo ERP

    EEQ->(Reclock("EEQ",.F.))
    EEQ->EEQ_SEQBX := cSeq
    EEQ->(MsUnlock())
EndIf

//oEasyMessage:AddInList("RECEIVE", {"Sucesso" , "Registro Gravado no Destino" , Nil})

RestOrd(aOrd,.T.)

Return oEasyMessage

/*========================================================================================
Funcao Adapter: AF521ADBUS
Parametros    :
Objetivos     : Retornar o numero do adiantamento vinculado a parcela de cambio
Autor         : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora     : 18/04/2017
Revisao       : 
Obs.          : 
==========================================================================================*/
Static Function AF521ADBUS()
Local cRet      := ""
Local aOrdAdt521:= SaveOrd({"EEQ"})

EEQ->(DbSetOrder(16)) ////EEQ_FILIAL, EEQ_PREEMB, EEQ_EVENT, EEQ_FASE, EEQ_FORN, EEQ_FOLOJA, EEQ_PARC
If EEQ->(dbSeek(EEQ->EEQ_FILIAL + AvKey(EEQ->EEQ_PROR,"EEQ_PREEMB") + "609" + AvKey("F","EEQ_FASE") + AvKey(EEQ->EEQ_FORN,"EEQ_FORN") + AvKey(EEQ->EEQ_FOLOJA,"EEQ_FOLOJA") + AvKey(EEQ->EEQ_PAOR,"EEQ_PARC")))
    cRet := EEQ->EEQ_FINNUM
EndIf

RestOrd(aOrdAdt521,.T.)

Return cRet