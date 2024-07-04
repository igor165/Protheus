#INCLUDE "Average.ch"
//#Include "EICAP113.ch"

/*
Programa  : EICAP113.PRW
Objetivo  : Realizar a baixa de titulos FFC de Importação.
Autor     : THTS - Tiago Henrique Tudisco dos Santos
Data      : 24/01/2018
Parametros: 
Uso       : 
*/
Function EICAP113(cTabAlias,aCambioBx)
Local lRet      := .F.
Private cAlias  := cTabAlias
Private aCambio := aCambioBx

MsAguarde({|| lRet:= EasyEnvEAI("EICAP113",3)}, "Integração EAI - Baixa do título financeiro. Aguarde...") //"Integração EAI - Baixa do título financeiro. Aguarde..."

RETURN lRet


/*
Função      : IntegDef()
Objetivo    : Efetua integração com Logix 
Autor       : THTS - Tiago Henrique Tudisco dos Santos
Data        : 24/01/2018
*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)

Local oEasyIntEAI

   oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)

	oEasyIntEAI:oMessage:SetVersion("1.000")
	oEasyIntEAI:oMessage:SetMainAlias("SWB")
	oEasyIntEAI:SetModule("EIC",17)

	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AP113SEND") //ENVIO                               (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AP113RESP") //RESPOSTA SOBRE O ENVIO              (<-Response)

	oEasyIntEAI:Execute()

Return oEasyIntEAI:GetResult()


/*
Função      : AP113SEND()
Objetivo    : Envio das parcelas de Cambio
Autor       : THTS - Tiago Henrique Tudisco dos Santos
Data        : 24/01/2018
*/
Function AP113SEND(oMessage) 

Local oXml       := EXml():New()
Local oBusCont   := ENode():New()
Local oBusinReq  := ENode():New() 
Local oRec       := ENode():New()
Local oTitList   := ENode():New()
Local oTitulo
Local oInfoXML
Local aOrd       := {}
Local nI

aOrd := SaveOrd({"SW6"}) 
SWB->(dbGoTo(aCambio[1]))
oInfoXML := AP111SEND()
oInfoXML := oInfoXML:getRec(1):GetFieldContent("BusinessContent")

oBusinReq:SetField("Operation"  ,"EICAP113")

oBusCont:SetField("CompanyInternalId"   ,SM0->M0_CODIGO)
oBusCont:SetField("CompanyId"           ,EICEmpFLogix())
oBusCont:SetField("BranchId"            ,EICFilFLogix())

//Dados do Banco
oBusCont:SetField(oInfoXML:GetField("Bank"))

oBusCont:SetField(oInfoXML:GetField("PaymentDate"))
oBusCont:SetField(oInfoXML:GetField("PaymentMethodCode"))
oBusCont:SetField("VendorInternalId",oInfoXML:GetFieldCont("VendorCode"))
oBusCont:SetField(oInfoXML:GetField("StoreId"))
oBusCont:SetField("CurrencyInternalId"  ,oInfoXML:GetFieldCont("CurrencyCode"))
oBusCont:SetField(oInfoXML:GetField("CurrencyRate"))

For nI := 1 To Len(aCambio)
    SWB->(dbGoTo(aCambio[nI]))
    oInfoXML := AP111SEND()
    oInfoXML := oInfoXML:getRec(1):GetFieldContent("BusinessContent")

    oTitulo := ENode():New()
    
    oTitulo:SetField("AccountPayableDocumentInternalId" ,oInfoXML:GetFieldCont("DocumentNumber"))
    oTitulo:SetField("InternalId"                       ,oInfoXML:GetFieldCont("DocumentNumber"))
    oTitulo:SetField(oInfoXML:GetField("PaymentValue"))
    oTitulo:SetField(oInfoXML:GetField("PaymentMeans"))
    oTitulo:SetField("FinancialNatureInternalId"        ,oInfoXML:GetFieldCont("FinancialCode"))
    oTitulo:SetField("Origin"                           ,"SIGAEIC")
    //DocumentPrefix E DocumentNumber
    oTitulo:SetField(oInfoXML:GetField("PaymentDocument"))
    oTitulo:SetField("DischargeSequence"                ,oInfoXML:GetFieldCont("DischargeSequence"))
    //CodeValueAdjustment E ValueAdjustment
    oTitulo:SetField(oInfoXML:GetField("Adjustment"))
    
    oTitList:SetField("AccountPayableSettlements",oTitulo)

Next

oBusCont:SetField("ListOfAccountPayableSettlements",oTitList)

oRec:SetField("BusinessRequest",oBusinReq)
oRec:SetField("BusinessContent",oBusCont)
oXml:AddRec(oRec)

RestOrd(aOrd,.T.)

Return oXml


/*
Função      : AP113RESP()
Objetivo    : Retorno das parcelas de Cambio
Autor       : THTS - Tiago Henrique Tudisco dos Santos
Data        : 24/01/2018
*/
Function AP113RESP(oMessage)
Local oRetCont  := oMessage:GetRetContent()
Local aArray    := {}
Local oList
Local cSeqBX
Local cSeqLote
Local cNumTit
Local nI
Local aOrd := SaveOrd({"SWB"})

If isCpoInXML(oRetCont, "_ListOfInternalIdDocument") .And. isCpoInXML(oRetCont:_ListOfInternalIdDocument, "_InternalIdDocument")
  
	oList:= oRetCont:_ListOfInternalIdDocument:_InternalIdDocument
	If ValType(oList) <> "A"
		aArray := {oList}
	Else
		aArray := oList
	EndIf
    SWB->(dbSetOrder(8)) //WB_FILIAL + WB_NUMDUP
	For nI := 1 To Len(aArray)
		cNumTit     := EasyGetXMLinfo(,aArray[nI],"_Destination")
        cSeqBX    	:= EasyGetXMLinfo(,aArray[nI],"_DischargeSequence")
		cSeqLote 	:= EasyGetXMLinfo(,aArray[nI],"_BatchPaymentNumber")
        
        If SWB->(dbSeek(xFilial("SWB") + AvKey(cNumTit,"WB_NUMDUP")))
            SWB->(RecLock("SWB",.F.))
            SWB->WB_SEQBX   := cSeqBX
            SWB->WB_SEQLOTE := cSeqLote
            SWB->(MSUNLOCK())
        EndIf
	Next 

EndIf

RestOrd(aOrd,.T.)

Return oMessage
