#INCLUDE "Average.ch"
#Include "TOPCONN.ch"
/*
Programa : EICNF100.PRW
Autor    : Jacomo
Data     : 23/05/2014
Revisao  :
Uso      : Manutencao
*/
*--------------------------------------------------------------------
Function EICNF100(lEnvio,nOpc)
*--------------------------------------------------------------------
LOCAL lRet := .T.
DEFAULT lEnvio := .T.
PRIVATE cInvFiscal:=""

IF lEnvio  //CHAMANDO DO EICDI154 E EICDI554 PARA FAZER O ENVIO

   MsAguarde({|| lRet:=EasyEnvEAI("EICNF100",nOpc)}, "Integração EAI - Nota Fiscal. Aguarde...")//"Integração EAI - Nota Fiscal. Aguarde..."   
   
   IF EMPTY(cInvFiscal)
      RETURN .F.
   ENDIF
   
ENDIF

Return lRet

Function NF100IntDef(cXML, nTypeTrans, cTypeMessage, oEasyIntEAI)
Return IntegDef(cXML, nTypeTrans, cTypeMessage, oEasyIntEAI)

*--------------------------------------------------------------------
/* ====================================================*
* Função: IntegDefK
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix
* Obs:
* =====================================================*/
*--------------------------------------------------------------------*
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage, oEasyIntEAI)
*--------------------------------------------------------------------*
Local cAlias:="SF1"

If ValType(oEasyIntEAI) <> "O" .OR. Upper(GetClassName(oEasyIntEAI)) <> "EASYINTEAI"
   oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
EndIf

oEasyIntEAI:oMessage:SetVersion("3.003")
oEasyIntEAI:oMessage:SetMainAlias("SF1")
oEasyIntEAI:SetModule("EIC",17)

// Recebimento - Jacomo Lisa - 10/06/2014
oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "NF100RECB") //RECEBIMENTO DE BUSINESS MESSAGE     (->Business)
oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "NF100RESB") //RESPOSTA SOBRE O RECEBIMENTO        (<-Response)
oEasyIntEAI:oMessage:SetBFunction( {|| .T. } )
// Recebimento - Jacomo Lisa - 10/06/2014

// Envio -- Alex Wallauer - 11/06/2014
oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "NF100SEND") //ENVIO                               (->Business)
oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "NF100RESP") //RESPOSTA SOBRE O ENVIO              (<-Response)
// Envio -- Alex Wallauer - 11/06/2014

oEasyIntEAI:Execute()

Return oEasyIntEAI:GetResult()

*------------------------------------------------*
Function NF100RECB(oMessage) // Recebimento - Jacomo Lisa - 10/06/2014
*------------------------------------------------*
Local oBusinessCont  := oMessage:GetBsnContent()
Local oBatch         := EBatch():New()
LOCAL cNotaFiscal,cSerie
LOCAL cNF_Serie
LOCAL cInvNFiscal ,cInvSerie
LOCAL cForn
Local cObservation
Local cErro    := ""
Local oXMLErro := EXml():New()
Local oNode    := ENode():New()

cObservation := EasyGetXMLinfo(            , oBusinessCont, "_Observation" )

If Empty(cObservation) //Mensagem de Numeração de Nota Fiscal transmitida ao Sefaz

   cNF_Serie  := EasyGetXMLinfo(            , oBusinessCont, "_InternalId" )// Nota|Serie concatenada com pipe
   cInvNFiscal:= EasyGetXMLinfo("F1_DOC"    , oBusinessCont, "_InvoiceNumber")//Numero gerado pelo ERP
   cInvSerie  := EasyGetXMLinfo("F1_SERIE"  , oBusinessCont, "_InvoiceSerie" )//Serie gerada pelo ERP
   cForn      := EasyGetXMLinfo("F1_FORNECE", oBusinessCont, "_VendorCode" )

   
   cNotaFiscal := SUBSTR(cNF_Serie,1, AT("|",cNF_Serie)-1 )
   cSerie      := SUBSTR(cNF_Serie,AT("|",cNF_Serie)+1 )

   If !EICAtuDocNF(cNotaFiscal,cSerie,cForn,cInvNFiscal,cInvSerie)
      cErro:= "Não foi possível localizar a nota fiscal (Nro: " + cNotaFiscal + " Serie: " + cSerie + " Fornecedor: " + cForn + ")."
   EndIf

Else //Mensagem de Retorno do Sefaz de Cancelamento de Nota Fiscal

   cNumero := AvKey(EasyGetXMLinfo("F1_DOC"    , oBusinessCont, "_InvoiceNumber"),"F1_DOC")
   cSerie  := AvKey(EasyGetXMLinfo("F1_SERIE"  , oBusinessCont, "_InvoiceSerie" ),"F1_SERIE")
   cForn   := AvKey(EasyGetXMLinfo("F1_FORNECE", oBusinessCont, "_VendorCode" )  ,"F1_FORNECE")
   cLoja   := AVKEY(".","F1_LOJA")
   
   SF1->(DBSETORDER(1))//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
   
   If SF1->(DBSeek(xFilial("SF1")+cNumero+cSerie+cForn+cLoja))
  	  SF1->(RecLock("SF1",.F.))
	  SF1->F1_MENNOTA := cObservation
      SF1->(MSUNLOCK())
	  
	  If AllTrim(EasyGetXMLinfo("F1_OK", oBusinessCont, "_InvoiceSituation" )) == "2"
	     SF1->(RecLock("SF1",.F.))
         SF1->F1_STATUS  := "3" //Cancelada
		 SF1->F1_SERORIG := "_"
         SF1->(MSUNLOCK())
		 
         //Atualiza grupo
         cHawb := SF1->F1_HAWB
         cTpNF := SF1->F1_TIPO_NF
         cGrupo:= SF1->F1_CTR_NFC
         aNFs := {}
	  
	     lOk := .T.
         SF1->(DBSETORDER(5))
         SF1->(DBSEEK(xFilial("SF1")+cHawb+cTpNF))
         Do While SF1->(!EoF() .AND. F1_FILIAL+F1_HAWB+F1_TIPO_NF == xFilial("SF1")+cHawb+cTpNF)
         
            If cGrupo # SF1->F1_CTR_NFC
               SF1->( DbSkip() )
               Loop
            EndIf
		 
		    lOk := lOK .AND. SF1->F1_STATUS $ "0/3/4"
		 
            SF1->(dbSkip())
         EndDo
	  
         SF1->(DBSEEK(xFilial("SF1")+cHawb+cTpNF))
         Do While SF1->(!EoF() .AND. F1_FILIAL+F1_HAWB+F1_TIPO_NF == xFilial("SF1")+cHawb+cTpNF)
         
            If cGrupo # SF1->F1_CTR_NFC
               SF1->( DbSkip() )
               Loop
            EndIf
		 
            SF1->(RecLock("SF1",.F.))
            SF1->F1_OK := If(lOk,"1","0")
            SF1->(MSUNLOCK())
		 
            SF1->(dbSkip())
         EndDo
      EndIf
   Else
      cErro:= "Não foi possível localizar a nota fiscal (Nro: " + cNumero + " Serie: " + cSerie + " Fornecedor: " + cForn + ")."
   EndIf
EndIf

If !Empty(cErro)
   oNode:SetField("", AvgXMLEncoding(cErro))
   oXMLErro:AddRec(oNode)
   oMessage:lError:= .T.
   oMessage:AddInList("RESPONSE", oXMLErro)
EndIf

Return oBatch

*-------------------------------------------------*
Function NF100RESB(oMessage) // Resposta do Recebimento - Jacomo Lisa - 10/06/2014
*-------------------------------------------------*
Local oRespond 
       
    If !oMessage:HasErrors()
        oRespond  := ENode():New() 
        oRespond:SetField('ListOfInternalId',"")
    Else
        oRespond := oMessage:GetContentList("RESPONSE")
    EndIf

Return oRespond

*------------------------------------------------*
Function NF100SEND(oMessage) // Envio -- Alex Wallauer - 11/06/2014
*------------------------------------------------*
Local oXml       := EXml():New()
Local OIdent     := ENode():New()
Local oRec       := ENode():New()
Local aOrd       := {}
PRIVATE  oBusiness  := ENode():New()
PRIVATE  oBusinEvent:= ENode():New()
PRIVATE nInvAmount := 0
private cCodERP    := ""
private cOperacao  := ""
private nPesoBR    :=  0
private nPesoLIQ   :=  0
PRIVATE aImp       := {}
PRIVATE cMasterInv := ""
PRIVATE cMasterSer := ""
PRIVATE oListOfItens  := ENode():New()
//variáveis para uso em ponto de entrada
Private nVolumes:= 0
Private cPacking:= ""

aOrd := SaveOrd({"SF1","SWN","SY6","SW8","EIJ","EIM","SWW","SW9"})
//SWT->(DBSETORDER(1))//WT_FILIAL+WT_NR_CONC+WT_COD_I+WT_FORN+WT_FORLOJ

//<BusinessEvent>

//Entity e Event
oBusinEvent:SetField("Entity", "EICNF100")

oBusinEvent:SetField("Event" , "upsert")

//<Identification>

oKeyNode:= ENode():New()
oKeyNode:SetField(EAtt():New("name","ImportProcess"))
If EasyGParam("MV_NRDI",, .F.)
   oKeyNode:SetField(ETag():New("",Right(SF1->F1_HAWB, 6)))//conforme XSD
Else
   oKeyNode:SetField(ETag():New("",Left(SF1->F1_HAWB, 6)))//conforme XSD
EndIf
oIdent:SetField(ETag():New("key",oKeyNode))

oKeyNode:= ENode():New()
oKeyNode:SetField(EAtt():New("name","Invoice"))
oKeyNode:SetField(ETag():New("",SF1->F1_DOC))
oIdent:SetField(ETag():New("key",oKeyNode))

oKeyNode:= ENode():New()
oKeyNode:SetField(EAtt():New("name","Serie"))
oKeyNode:SetField(ETag():New("",SF1->F1_SERIE))
oIdent:SetField(ETag():New("key",oKeyNode))

oKeyNode:= ENode():New()
oKeyNode:SetField(EAtt():New("name","Vendor"))
oKeyNode:SetField(ETag():New("",SF1->F1_FORNECE))
oIdent:SetField(ETag():New("key",oKeyNode))

oKeyNode:= ENode():New()
oKeyNode:SetField(EAtt():New("name","Store"))
oKeyNode:SetField(ETag():New("",SF1->F1_LOJA))
oIdent:SetField(ETag():New("key",oKeyNode))

oKeyNode:= ENode():New()
oKeyNode:SetField(EAtt():New("name","Type"))
oKeyNode:SetField(ETag():New("",SF1->F1_TIPO))
oIdent:SetField(ETag():New("key",oKeyNode))

//<Identification>

oBusinEvent:SetField("Identification",oIdent)

//<BusinessEvent>


//capa
//<BusinessContent>
oBusiness:SetField("CompanyId"        ,SM0->M0_CODIGO)
oBusiness:SetField("BranchId"         ,FWFilial())
oBusiness:SetField("CompanyInternalId",SM0->M0_CODIGO)
oBusiness:SetField("InternalId"       ,"")
oBusiness:SetField("InvoiceNumber"    ,IF(nEAIEvent = 5 .Or. SF1->F1_TIPO_NF == "9" ,SF1->F1_DOC  ,""))//F1_DOC, em caso de cancelamento, caso contrário Vazio.
oBusiness:SetField("InvoiceSerie"     ,IF(nEAIEvent = 5 .Or. SF1->F1_TIPO_NF == "9" ,SF1->F1_SERIE,""))//F1_SERIE, em caso de cancelamento, caso contrário Vazio.
oBusiness:SetField("InvoiceSubSerie"  ,"")
oBusiness:SetField("InvoiceModel"     ,"")
oBusiness:SetField("InvoiceSituation" ,IF(nEAIEvent = 5,"2","1"))//“1” em caso de geração de nota fiscal, “2” em caso de cancelamento de nota fiscal.
cTipoNF:="NFE"//Com base em WN_TIPO_NF: 1 e 3 enviar "NFE", 2 enviar "NFC", 5 enviar "NFM" e 6 enviar "NFP"
IF SF1->F1_TIPO_NF = "2"
   cTipoNF:="NFC"
ELSEIF SF1->F1_TIPO_NF = "5"
   cTipoNF:="NFM"
ELSEIF SF1->F1_TIPO_NF = "6"
   cTipoNF:="NFP"
ENDIF
oBusiness:SetField("TypeOfDocument"   ,cTipoNF)//Com base em WN_TIPO_NF: 1 e 3 enviar "NFE", 2 enviar "NFC", 5 enviar "NFM" e 6 enviar "NFP"
oBusiness:SetField("VendorCode"      ,SF1->F1_FORNECE)
oBusiness:SetField("VendorInternalId",SF1->F1_FORNECE)
oBusiness:SetField("IssueDate"        ,EasyTimeStamp(SF1->F1_EMISSAO,.T.,.T.))

IF nEAIEvent = 3// Geracao NF
   MontaItens() // Montagem das Tags de Itens primeiro para complementar os totais da Capa
   SWN->(DBSEEK(xFilial("SWN")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
   aImp := GetNFEImp(.T.)

   If EasyEntryPoint("EICNF100")
      ExecBlock("EICNF100",.F.,.F.,"NF100SEND_CAPA")
   EndIf
   
   oBusiness:SetField("InvoiceAmount"             ,nInvAmount)
   oBusiness:SetField("ValueofGoods"              ,SF1->F1_FOB_R)
   oBusiness:SetField("FreightAmount"             ,SF1->F1_FRETE)
   oBusiness:SetField("InsuranceAmount"           ,SF1->F1_SEGURO)
   oBusiness:SetField("DiscountAmount"            ,0)
   oBusiness:SetField("CurrencyRate"              ,0)
   oBusiness:SetField("PaymentConditionCode"      ,cCodERP)
   oBusiness:SetField("PaymentConditionInternalId",cCodERP)
   oBusiness:SetField("CustomerCode"              ,"")
   oBusiness:SetField("CustomerInternalId"        ,"")
   oBusiness:SetField("StoreCode"                 ,"")
   oBusiness:SetField("StoreInternalId"           ,"")
   oBusiness:SetField("MasterInvoiceNumber"       ,cMasterInv)
   oBusiness:SetField("MasterInvoiceSerie"        ,cMasterSer)
   oBusiness:SetField("MasterInvoiceSubSerie"     ,"")
   oBusiness:SetField("TaxOpCode"                 ,cOperacao)
   oBusiness:SetField("CarrierCode"               ,SW6->W6_TRANS)
   IF (nPos := ascan(aImp, {|x| x[2] =="nDI"}) ) > 0
      oBusiness:SetField("ImportDeclaration"         ,aImp[nPos][3])
   ENDIF
   IF (nPos := ascan(aImp, {|x| x[2] =="dDI"}) ) > 0
      oBusiness:SetField("ImportDeclarationDate"     ,EasyTimeStamp(aImp[nPos][3],.T.,.T.) )
   ENDIF
   If EasyGParam("MV_NRDI",, .F.)
      oBusiness:SetField("ImportProcess"             ,Right(SW6->W6_HAWB, 6))
   Else
      oBusiness:SetField("ImportProcess"             ,Left(SW6->W6_HAWB, 6))
   EndIf
   IF (nPos := ascan(aImp, {|x| x[2] =="dDesemb"}) ) > 0
      oBusiness:SetField("ClearanceDate"             ,EasyTimeStamp(aImp[nPos][3],.T.,.T.))
   ENDIF
   IF (nPos := ascan(aImp, {|x| x[2] =="xLocDesemb"}) ) > 0
      oBusiness:SetField("ClearanceSite"             ,aImp[nPos][3])
   ENDIF
   IF (nPos := ascan(aImp, {|x| x[2] =="UFDesemb"}) ) > 0
      oBusiness:SetField("ClearanceUF"               ,aImp[nPos][3])
   ENDIF
   IF (nPos := ascan(aImp, {|x| x[2] =="cExportador"}) ) > 0
      oBusiness:SetField("ExporterCode"              ,aImp[nPos][3])
   ENDIF
   IF (nPos := ascan(aImp, {|x| x[2] =="tpViaTransp"}) ) > 0
      oBusiness:SetField("TransportMode"             ,aImp[nPos][3])
   ENDIF
   IF (nPos := ascan(aImp, {|x| x[2] =="vAFRMM"}) ) > 0
      oBusiness:SetField("AFRMMValue"                ,aImp[nPos][3])
   ENDIF
   IF (nPos := ascan(aImp, {|x| x[2] =="tpIntermedio"}) ) > 0
      oBusiness:SetField("ImportMode"                ,aImp[nPos][3])
   ENDIF
   
   IF (nPos := ascan(aImp, {|x| x[2] =="CNPJ"}) ) > 0
      oBusiness:SetField("BuyerCNPJ"                 ,aImp[nPos][3])
   ENDIF
   IF (nPos := ascan(aImp, {|x| x[2] =="UFTerceiro"}) ) > 0
      oBusiness:SetField("BuyerUF"                   ,aImp[nPos][3])
   ENDIF
   oBusiness:SetField("AccountInTransit"          ,EasyGParam("MV_EIC0046",,"MV_EIC0046") )
   oBusiness:SetField("Packing"                   ,cPacking)
   oBusiness:SetField("Volumes"                   ,nVolumes)
   oBusiness:SetField("GrossWeight"               ,nPesoBR)
   oBusiness:SetField("NetWeight"                 ,nPesoLIQ)
   //<ListOfItens>
   
   //</ListOfItens>
   oBusiness:SetField("ListOfItens",oListOfItens)
ENDIF

If EasyEntryPoint("EICNF100")
   ExecBlock("EICNF100",.F.,.F.,"NF100SEND_FIM_NF")
EndIf

oRec:SetField("BusinessEvent"  ,oBusinEvent)// OK
oRec:SetField("BusinessContent",oBusiness) //  OK
oXml:AddRec(oRec)

RestOrd(aOrd,.t.)

Return oXml

*------------------------------------------------*
Static Function MontaItens()
*------------------------------------------------*
LOCAL aImp := {}
Local nCont
Local cForLojInv
EIM->(DBSETORDER(2))//EIM_FILIAL+EIM_HAWB+EIM_CODIGO
SW9->(DBSETORDER(1))//W9_FILIAL+W9_INVOICE+W9_FORN+W9_FORLOJ+W9_HAWB
SY6->(DBSETORDER(1))//Y6_FILIAL+Y6_COD+STR(Y6_DIAS_PA,3,0)
SW8->(DBSETORDER(6))//W8_FILIAL+W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM
SWN->(DBSETORDER(2))//WN_FILIAL+WN_DOC+WN_SERIE+WN_FORNECE+WN_LOJA//AWF - 30/07/2014

//AAF 03/01/2017 - SWW para somar os valores que compoe custo
SWW->(dbSetOrder(1))//WW_FILIAL+WW_NF_COMP+WW_SE_NFC+WW_FORNECE+WW_LOJA+WW_PO_NUM+WW_NR_CONT

SWN->(DBSEEK(xFilial("SWN")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
DO WHILE SWN->(!EOF())                    .AND.;
   SWN->WN_FILIAL == xFilial("SWN") .AND.;
   SWN->WN_DOC    == SF1->F1_DOC    .AND.;
   SWN->WN_SERIE  == SF1->F1_SERIE  .AND.;
   SWN->WN_FORNECE== SF1->F1_FORNECE.AND.;
   SWN->WN_LOJA   == SF1->F1_LOJA
   
   IF SWN->WN_TIPO_NF # SF1->F1_TIPO_NF .OR. SWN->WN_HAWB # SF1->F1_HAWB
      SWN->(DBSKIP())
      LOOP
   ENDIF
   
   cForLojInv := NF100FnInv() //SWN->WN_FORNECE
   lSeekSW9 := SW9->(DBSEEK(xFilial("SW9")+SWN->WN_INVOICE+cForLojInv+SWN->WN_HAWB))
   lSeekSY6 := SY6->(DBSEEK(xFilial("SY6")+SW9->W9_COND_PA+STR(SW9->W9_DIAS_PA,3,0) ))
   
//F (EMPTY(cMasterInv)) .AND. (EMPTY(cMasterSer)) .AND. (SWN->WN_TIPO_NF $ "2/6")
//EicGetDocNF(SWB->WN_HAWB,@cMasterInv,@cMasterSer)
//NDIF
    IF SWN->(FIELDPOS("WN_DOCORI")) # 0 .AND. SWN->(FIELDPOS("WN_SERORI")) # 0//AWF - 31/07/2014
       cMasterInv := SWN->WN_DOCORI
       cMasterSer := SWN->WN_SERORI
    ENDIF
   
   IF (EMPTY(cCodERP)) .AND. lSeekSY6
      cCodERP := SY6->Y6_CODERP
   ENDIF
   IF lSeekSY6
      cSample := SY6->Y6_MOTIVO
   ENDIF
   IF (EMPTY(cOperacao))
      cOperacao := SWN->WN_CFO
   ENDIF
   IF SWN->WN_TIPO_NF $  "1/5/6" //Primeira, Mãe ou Filha
      nInvAmount += SWN->(WN_VALOR+WN_IPIVAL+WN_VLRPIS+WN_VLRCOF+WN_VL_ICM+WN_DESPICM)//SWN->WN_BASEICM
   ELSEIF SWN->WN_TIPO_NF == STR(3,1,0) // Unica
      nInvAmount += SWN->(WN_VALOR+WN_IPIVAL+WN_VLRPIS+WN_VLRCOF+WN_VL_ICM+WN_DESPICM+WN_DESPESA)//SWN->WN_BASEICM+SWN->WN_DESPESA
   Else
      nInvAmount += SWN->WN_VALOR+SWN->WN_VALICM //AAF - 26/08/2014 - Complementar
   ENDIF
   
   IF SW8->(FieldPos("W8_PESO_BR")) <> 0 .AND. SW8->(DBSEEK(xFilial("SW8")+SWN->WN_HAWB+SWN->WN_INVOICE+SWN->WN_PO_EIC+SWN->WN_ITEM+SWN->WN_PGI_NUM))
      nPesoBR += SWN->WN_QUANT * SW8->W8_PESO_BR
   ELSE
      nPesBRB1 := Posicione("SB1",1,xFilial("SB1")+AvKey(SWN->WN_PRODUTO,"A5_PRODUTO") ,"B1_PESBRU")
      nPesoBR += SWN->WN_QUANT * SB1->B1_PESBRU
   ENDIF
   nPesoLIQ += SWN->WN_PESOL
   
   aImp := GetNFEImp(.T.)
   //<Item>
   oItem:= ENode():New()
   oItem:SetField("InternalId"              ,"")
   oItem:SetField("InvoiceSequence"         ,SWN->WN_LINHA)
   oItem:SetField("OrderNumber"             ,SWN->WN_PO_NUM)
   oItem:SetField("OrderInternalId"         ,SWN->WN_PO_EIC)
   oItem:SetField("OrdemItem"               ,SWN->WN_SI_NUM)
   oItem:SetField("OrderItemInternalId"     ,SWN->WN_SI_NUM)
   oItem:SetField("ItemCode"                ,SWN->WN_PRODUTO)
   oItem:SetField("ItemInternalId"          ,SWN->WN_PRODUTO)
   oItem:SetField("Quantity"                ,SWN->WN_QUANT)
   
   cUM := Posicione("SA5",2,xFilial("SYD")+AvKey(SWN->WN_PRODUTO,"A5_PRODUTO")+ AvKey(SWN->WN_FORNECE,"A5_FORNECE") ,"A5_UNID")
   oItem:SetField("UnitofMeasureCode"       ,Posicione("SAH",1,xFilial("SYD")+AvKey(cUM,"AH_UNIMED") ,"AH_CODERP"))
   oItem:SetField("UnitofMeasureInternalId" ,cUM)
   
   oItem:SetField("UnityPrice"              ,(SWN->WN_VALOR/*+SWN->WN_DESPADU*/) / SWN->WN_QUANT )
   
   nGrossValue := IF(SWN->WN_TIPO_NF # STR(2,1,0),SWN->WN_FOB_R, SWN->WN_VALOR /*- SWN->WN_DESPICM*/ )
   oItem:SetField("GrossValue"              ,nGrossValue)
   oItem:SetField("FreightValue"            ,SWN->WN_FRETE)
   oItem:SetField("InsuranceValue"          ,SWN->WN_SEGURO)
   oItem:SetField("DiscountValue"           ,0)
   //nNetValue :=IF(SWN->WN_TIPO_NF # STR(2,1,0),SWN->WN_FOB_R+SWN->WN_DESPADU , SWN->WN_VALOR - SWN->WN_DESPICM ) //Não funciona NF complementar pois o Logix precisa do valor que incide ICMS também no item
   //nNetValue :=IF(SWN->WN_TIPO_NF # STR(2,1,0),SWN->WN_VALOR+SWN->WN_DESPICM , SWN->WN_VALOR /*- SWN->WN_DESPICM*/ ) //N
   //nNetValue :=IF(SWN->WN_TIPO_NF # STR(2,1,0),SWN->WN_VALOR+SWN->WN_DESPICM , SWN->WN_VALOR /*- SWN->WN_DESPICM*/ ) //AAF
   
   //** AAF 02/09/2014
   IF SWN->WN_TIPO_NF # STR(2,1,0)
      nNetValue := SWN->WN_VALOR+SWN->WN_DESPICM //Nota primeira, unica, mãe e filha contem despesas base de ICMS, pois o Logix sempre considera que as despesas estão no valor do item.
   Else
      nNetValue := SWN->WN_DESPICM //Nota complementar, entra apenas as despesas base de ICMS, para que o Logix não calcule ICMS sobre outras despesas.
   EndIf
   //**
   
   oItem:SetField("NetValue"                ,nNetValue)
   oItem:SetField("AreAndLineOfBusinessCode","")
   oItem:SetField("WarehouseCode"           ,"")
   oItem:SetField("WarehouseInternalId"     ,"")
   IF (!EMPTY(SWN->WN_LOTECTL))
      oItem:SetField("LotNumber"               ,SWN->WN_LOTECTL)
      //oItem:SetField("SubLotNumber"            ,"")
      oItem:SetField("LotExpirationDate"       ,EasyTimeStamp(SWN->WN_DTVALID,.T.,.T.) )
   ENDIF
   oItem:SetField("ContractInternalID"      ,"")
   
   aEntregas := PO420PrgEntrega(.T.,SWN->WN_PRODUTO,SWN->WN_CC,SWN->WN_SI_NUM,SWN->WN_PO_EIC,SWN->WN_PGI_NUM,SWN->WN_HAWB)
   IF LEN(aEntregas) > 0
      oItem:SetField("DeliverySchedule"        ,aEntregas[1][1] )
   ENDIF
   oItem:SetField("NCM"                     ,SWN->WN_TEC)
   oItem:SetField("AccessoryExpense"        ,IF(SWN->WN_TIPO_NF # STR(3,1,0),SWN->WN_DESPICM , SWN->WN_DESPICM)   ) // STR(3,1,0) 3= Unica
   
   //** AAF 29/08/2014 - Outras Despesas
   If SWN->WN_TIPO_NF ==  "3" //Única
      oItem:SetField("OtherExpenses",SWN->WN_DESPESA)
   ElseIf SWN->WN_TIPO_NF ==  "2" //Complementar
      oItem:SetField("OtherExpenses",SWN->WN_DESPESA-SWN->WN_DESPICM)
   //Else
   //   oItem:SetField("OtherExpenses",0)
   EndIf
   //**
   
   //** AAF 02/01/2017 - Despesas que estão inclusas em CustomCosts (despesas aduaneiras - Base II) ou em AccessoryExpenses (despesas acessórias - base ICMS) mas que não devem compor custo do produto  
   If SWN->WN_TIPO_NF $ "1/3/5" .AND. ((nPos := ascan(aImp, {|x| x[2] =="vDespAdu"}) ) > 0 .AND. aImp[nPos][3] > 0 .OR. SWN->WN_DESPICM > 0)
      
	  //Pega o total de despesas enviado ao Logix e retira a parte que compoe custo (fica gravada na SWW)
	  nValSemCusto := aImp[nPos][3] + SWN->WN_DESPICM //Despesas aduaneiras + despesas acessórias
	  IF SWN->WN_TIPO_NF ==  "3"
	     nValSemCusto += SWN->WN_DESPESA //Adiciona outras despesas com custo no caso de nota unica
	  Endif
	  
	  SWW->(dbSeek(xFilial("SWW")+SWN->(WN_DOC+WN_SERIE+WN_FORNECE+WN_LOJA+WN_PO_EIC+WN_ITEM)))
	  Do While SWW->(!Eof() .AND. WW_FILIAL+WW_NF_COMP+WW_SE_NFC+WW_FORNECE+WW_LOJA+WW_PO_NUM+WW_NR_CONT == xFilial("SWW")+SWN->(WN_DOC+WN_SERIE+WN_FORNECE+WN_LOJA+WN_PO_EIC+WN_ITEM))
		
		If SWW->(WW_HAWB+WW_LOTECTL+WW_INVOICE) == SWN->(WN_HAWB+WN_LOTECTL+WN_INVOICE) .AND. SWW->WW_TIPO_NF # "4" //Campos que estao faltando na chave e tipo diferente de custo realizado
		   nValSemCusto -= SWW->WW_VALOR //Subtrai os valores que possuem custo
		EndIf
		
        SWW->(dbSkip())
      EndDo
      
      If nValSemCusto > 0
         oItem:SetField("ExporterExpenses",nValSemCusto)
	  EndIf
   EndIf
   //**
   
   //oItem:SetField("bcIcmsAccessoryExpense"  ,0)
   //oItem:SetField("IcmsAcessoryExpense"     ,0)
   oItem:SetField("TaxOpCodeItem"           ,SWN->WN_CFO)
   
   IF (nPos := ascan(aImp, {|x| x[2] =="nAdicao"}) ) > 0
      oItem:SetField("AddingDiNumber"          ,aImp[nPos][3])
   ENDIF
   IF (nPos := ascan(aImp, {|x| x[2] =="nSeqAdi"}) ) > 0
      oItem:SetField("AddingDiSeq"             ,aImp[nPos][3])//nSeqAdi)
   ENDIF
   IF (nPos := ascan(aImp, {|x| x[2] =="cFabricante"}) ) > 0
      oItem:SetField("Manufacturer"            ,aImp[nPos][3])//cFabricante)
   ENDIF
   IF (nPos := ascan(aImp, {|x| x[2] =="vDescDI"}) ) > 0
      oItem:SetField("DiscountDiValue"         ,aImp[nPos][3])//vDescDI)
   ENDIF
   IF (nPos := ascan(aImp, {|x| x[2] =="vDespAdu"}) ) > 0
      oItem:SetField("CustomsCosts"            ,aImp[nPos][3])//vDespAdu)
   ENDIF
   IF (nPos := ascan(aImp, {|x| x[2] =="vIOF"}) ) > 0
      oItem:SetField("IOFValue"                ,aImp[nPos][3])//vIOF)
   ENDIF
   IF (nPos := ascan(aImp, {|x| x[2] =="nDraw"}) ) > 0
      oItem:SetField("ConcessionActDrawback"   ,aImp[nPos][3])//nDraw)
   ENDIF
   
   oItem:SetField("Sample"                  ,IF(cSample $ "39/41", "true" , "false") )
   
   //<ListOfNVE>
   
   //MFR 26/11/2018 OSSME-1483
   //IF SWN->(FieldPos("WN_NVE")) <> 0 .AND.  EIM->(DBSEEK(xFilial("EIM")+SWN->WN_HAWB+SWN->WN_NVE ))
   IF SWN->(FieldPos("WN_NVE")) <> 0 .AND.  EIM->(DBSEEK(GetFilEIM("DI")+SWN->WN_HAWB+SWN->WN_NVE ))
      oListOfNVE := ENode():New()
      nCont := 1
      //MFR 26/11/2018 OSSME-1483
      //DO WHILE EIM->(!EOF()) .AND. EIM->EIM_FILIAL = xFilial("EIM")  .AND. ;
      DO WHILE EIM->(!EOF()) .AND. EIM->EIM_FILIAL = GetFilEIM("DI")  .AND. ;
         EIM->EIM_HAWB == SWN->WN_HAWB .AND. EIM->EIM_CODIGO == SWN->WN_NVE .AND. nCont <= 8
         //<NVE>
         oNVE:= ENode():New()
         oNVE:SetField("NVECode",EIM->EIM_ATRIB+" "+EIM->EIM_ESPECI)
         oListOfNVE:SetField("NVE",oNVE)
         //</NVE>
         nCont++
         EIM->(DBSKIP())
      ENDDO
      oItem:SetField("ListOfNVE",oListOfNVE)
      //</ListOfNVE>
   ENDIF
   //<ListOfTaxes>
   oListOfTX := ENode():New()
   //<Taxes>  II
   oListOfTX:SetField("Taxes",GetTaxes("II"))
   //</Taxes>  II
   
   //<Taxes>  IPI
   oListOfTX:SetField("Taxes",GetTaxes("IPI"))
   //</Taxes>  IPI
   
   //<Taxes>  PIS
   oListOfTX:SetField("Taxes",GetTaxes("PIS"))
   //</Taxes>  PIS
   
   //<Taxes>  COFINS
   oListOfTX:SetField("Taxes",GetTaxes("COFINS"))
   //</Taxes> COFINS
   
   //<Taxes>  ICMS
   oListOfTX:SetField("Taxes",GetTaxes("ICM"))
   //</Taxes> ICMS
   oItem:SetField("ListOfTaxes",oListOfTX)
   //</ListOfTaxes>
   oListOfItens:SetField("Item",oItem)
   //</Item>
   SWN->(DBSKIP())
ENDDO

RETURN .T.
*------------------------------------------------*
Static Function GetTaxes(cImp)
*------------------------------------------------*
LOCAL oTaxes   := ENode():New()
LOCAL lSeekEIJ := .F.
LOCAL lRecalc  := "false",cReason := ""
LOCAL nCalcBase:=nPercent:=nValue:=nEspCalcBas:=nEspAli:= 0
LOCAL nIncPercnt :=  nIncValue := nRedBasePer:= 0
LOCAL nDefPerc:= nDefValue:= nPresCrePer := nPresCreVal := 0
Local nIndSWZ

IF EIJ->(DBSEEK(xFilial("EIJ")+SWN->WN_HAWB+SWN->WN_ADICAO))
   lSeekEIJ := .T.
ENDIF
DO CASE
   CASE cImp == "II"
        nCalcBase  :=SWN->WN_CIF
        nPercent   :=SWN->WN_IITX
        IF lSeekEIJ
           nRedBasePer:= EIJ->EIJ_ALR_II
        ENDIF
        nValue     :=SWN->WN_IIVAL
        cReason    :=""
        IF lSeekEIJ .AND. EIJ->EIJ_TPAII <> "1"
           nEspCalcBas:= SWN->WN_QUANT
           nEspAli    := EIJ->EIJ_ALU_II
        ENDIF
        
   CASE cImp == "IPI"
   
        nCalcBase  :=SWN->WN_IPIBASE
        nPercent   :=SWN->WN_IPITX 
        nValue     :=SWN->WN_VALIPI
        cReason    :=""
        IF SWN->WN_QTUIPI <> 0
           nEspCalcBas:= SWN->WN_QTUIPI
           nEspAli    := SWN->WN_ALUIPI
        endif
   
   CASE cImp == "PIS"
        nCalcBase  :=SWN->WN_BASPIS
        nPercent   :=SWN->WN_PERPIS
        
        IF lSeekEIJ
           nRedBasePer:= EIJ->EIJ_PRB_PC
        Else
           nRedBasePer:= Posicione("SYD",1,xFilial("SYD")+AvKey(SWN->WN_TEC,"YD_TEC"),"YD_RED_PIS")
        EndIf
        
        nValue     := SWN->WN_VLRPIS
        cReason    :=""
        IF SWN->WN_VLUPIS <> 0
           nEspCalcBas:= SWN->WN_QUANT
           nEspAli    := SWN->WN_VLUPIS
        ENDIF
        If SWN->(FieldPos("WN_ALPISM")) <> 0
           nIncPercnt := SWN->WN_ALPISM
        ENDIF
        If SWN->(FieldPos("WN_VLPISM")) <> 0
           nIncValue  := SWN->WN_VLPISM
        ENDIF
   CASE cImp == "COFINS"
        nCalcBase  :=SWN->WN_BASCOF
        nPercent   :=SWN->WN_PERCOF
        
        IF lSeekEIJ
           nRedBasePer := EIJ->EIJ_PRB_PC
        Else
           nRedBasePer := Posicione("SYD",1,xFilial("SYD")+AvKey(SWN->WN_TEC,"YD_TEC"),"YD_RED_COF")
        EndIf
        
        nValue     := SWN->WN_VLRCOF
        cReason    :=""
        IF SWN->WN_VLUCOF <> 0
           nEspCalcBas:= SWN->WN_QUANT
           nEspAli    := SWN->WN_VLUCOF
        ENDIF
        nIncPercnt := SWN->WN_ALCOFM
        nIncValue  := SWN->WN_VLCOFM
   
   CASE cImp == "ICM"
        nCalcBase  := SWN->WN_BASEICM
        nPercent   := SWN->WN_ICMS_A
        nValue     := SWN->WN_VALICM
        
        nIndSWZ := SWZ->(IndexOrd())
        SWZ->(dbSetOrder(1))
        IF SWZ->(DBSEEK(xFilial("SWZ")+SWN->WN_CFO+SWN->WN_OPERACA))
           nRedBasePer := SWZ->WZ_RED_ICM //IF(SWZ->WZ_RED_ICM#0, (100-SWZ->WZ_RED_ICM)/100 , 1)
           nDefPerc    := SWZ->WZ_ICMSDIF
           nDefValue   := SWN->WN_VICMDIF
           nPresCrePer := SWZ->WZ_PCREPRE
           nPresCreVal := SWN->WN_VICM_CP
        ENDIF
        SWZ->(dbSetOrder(nIndSWZ))
ENDCASE

oTaxes:SetField("Taxe",cImp)
oTaxes:SetField("CalculationBasis",nCalcBase)
oTaxes:SetField("Percentage",nPercent)

IF cImp <> "IPI" .AND. nRedBasePer <> 0
   oTaxes:SetField("ReductionBasedPercent",nRedBasePer)
ENDIF

oTaxes:SetField("Value",nValue)
//IF(cImp <> "ICM" , oTaxes:SetField("Reason",cReason), )

IF cImp <> "ICM" .AND. nEspCalcBas <> 0 .AND. nEspAli <> 0
   oTaxes:SetField("EspecificCalculationBasis",nEspCalcBas)
   oTaxes:SetField("EspecificAliquot",nEspAli)
ENDIF
IF cImp == "ICM"
   oTaxes:SetField("DeferralPercentage",nDefPerc)
   oTaxes:SetField("DeferralValue",nDefValue)
   oTaxes:SetField("PresumedCreditPercentage",nPresCrePer)
   oTaxes:SetField("PresumedCreditValue",nPresCreVal)
ENDIF
IF cImp $ "PIS|COFINS" .AND. nIncValue <> 0
   oTaxes:SetField("IncreasePercentage",nIncPercnt)
   oTaxes:SetField("IncreaseValue",nIncValue)
ENDIF

oTaxes:SetField("Recalculate",lRecalc)

return oTaxes

*------------------------------------------------*
Function NF100RESP(oMessage) // **************************  RESPOSTA DO ENVIO ******************************************************
*------------------------------------------------*
Local oRetCont       := oMessage:GetRetContent()
Local oBusinessEvent := oMessage:GetEvtContent()
Local oBusinessCont  := oMessage:GetBsnContent()
Local cNota:=cSerie:=cHawb:=cForn:=cLoja:=cTipo:=""
Local aOrd := SaveOrd({"SF1"})
SF1->(DBSETORDER(1))//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO

If ValType(oBusinessEvent:_IDENTIFICATION:_KEY) <> "A"
   aKey := {oBusinessEvent:_IDENTIFICATION:_KEY}
Else
   aKey := oBusinessEvent:_IDENTIFICATION:_KEY
EndIf

aEval(aKey, {|x| If(Upper(Alltrim(x:_NAME:Text)) == "IMPORTPROCESS", cHawb := x:TEXT,)})
aEval(aKey, {|x| If(Upper(Alltrim(x:_NAME:Text)) == "INVOICE"      , cNota := x:TEXT,)})
aEval(aKey, {|x| If(Upper(Alltrim(x:_NAME:Text)) == "SERIE"        , cSerie:= x:TEXT,)})
aEval(aKey, {|x| If(Upper(Alltrim(x:_NAME:Text)) == "VENDOR"       , cForn := x:TEXT,)})
aEval(aKey, {|x| If(Upper(Alltrim(x:_NAME:Text)) == "STORE"        , cLoja := x:TEXT,)})
aEval(aKey, {|x| If(Upper(Alltrim(x:_NAME:Text)) == "TYPE"         , cTipo := x:TEXT,)})

cNota := AvKey(cNota ,"F1_DOC")
cSerie:= AvKey(cSerie,"F1_SERIE")
cForn := AvKey(cForn ,"F1_FORNECE")
cLoja := AvKey(cLoja ,"F1_LOJA")
cTipo := AvKey(cTipo ,"F1_TIPO")

cTipoEnv  := EasyGetXMLinfo(,oBusinessCont, "_InvoiceSituation" )//Serie gerada pelo ERP

cInvFiscal:=EasyGetXMLinfo("F1_DOC"   , oRetCont, "_InvoiceNumber" )//Nota gerada pelo ERP
cInvSerie :=EasyGetXMLinfo("F1_SERIE" , oRetCont, "_InvoiceSerie" )//Serie gerada pelo ERP

IF !EMPTY(cInvFiscal) .AND. SF1->(DBSeek(xFilial("SF1")+cNota+cSerie+cForn+cLoja+cTipo))
   SF1->(RecLock("SF1",.F.))
   IF cTipoEnv == "1"//GERACAO
      SF1->F1_STATUS:= "1" //Integrada
   ELSE
      IF AllTrim(SF1->F1_SERORIG) == "_" .OR. Empty(SF1->F1_SERORIG) //CANCELAMENTO SEM INTEGRAÇÃO AO SEFAZ
         SF1->F1_STATUS  := "3" //Cancelada
      ELSE //CANCELAMENTO COM INTEGRAÇÃO AO SEFAZ
         SF1->F1_STATUS:= "2" //Solicitado Cancelamento
      ENDIF
   Endif
   SF1->(MSUNLOCK())
EndIF
//ConOut("********************************************************************************")
//ConOut("*Status gravada no SF1: ["+SF1->F1_STATUS+"] Chave: ["+cNota+cSerie+cForn+cLoja+cTipo+"]")
//ConOut("********************************************************************************")

IF !EMPTY(cInvFiscal) .AND. cTipoEnv == "1"//GERACAO
   EICAtuDocNF(cNota,cSerie,cForn,cInvFiscal,cInvSerie,cTipo)//Grava o nmero provisorio da nota
ENDIF

//IF !EMPTY(cInvFiscal)
//   oEasyMessage:AddInList("RECEIVE", {"Sucesso" , "Registro Gravado no Destino" , Nil})
//ELSE
//   oEasyMessage:AddInList("RECEIVE", {"Erro" , "Numero da nota em branco" , Nil})
//ENDIF

RestOrd(aOrd,.t.)
Return oMessage

*------------------------------------------------------------------------*
Static Function EICAtuDocNF(cNotaFiscal,cSerie,cForn,cInvFiscal,cInvSerie,cTipo)
*------------------------------------------------------------------------*
LOCAL cLoja     := AVKEY(".","F1_LOJA") , aOrdW6
Local lRet := .T.
DEFAULT cTipo   := ""

Begin Sequence

cNumero := AVKEY(cNotaFiscal,"F1_DOC"     )
cSerie  := AVKEY(cSerie     ,"F1_SERIE"   )
cForn   := AVKEY(cForn      ,"F1_FORNECE" )
If !Empty(cTipo)
   cTipo:= AVKEY(cTipo      ,"F1_TIPO" )
EndIf

SF1->(DBSETORDER(1))//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
SWN->(DBSETORDER(2))//WN_FILIAL+WN_DOC+WN_SERIE+WN_FORNECE+WN_LOJA
SWW->(DBSETORDER(1))//WW_FILIAL+WW_NF_COMP+WW_SE_NFC+WW_FORNECE+WW_LOJA+WW_PO_NUM+WW_NR_CONT

IF SF1->(DBSeek(xFilial("SF1")+cNumero+cSerie+cForn+cLoja+cTipo))
   
   nRecSF1:=SF1->(RECNO())//Guarda recno atual
   
   //AAF 30/06/2014 - Atualizar SW6 (apenas porque está na tela e pode confundir o usuário).
   aOrdW6:=SW6->({IndexOrd(),RecNo()})
   If SF1->F1_TIPO_NF $ "1/2/3/5" .AND. SW6->(dbSetOrder(1),dbSeek(xFilial("SW6")+SF1->F1_HAWB))
      SW6->(RecLock("SW6",.F.))
      If SF1->F1_TIPO_NF == "2"
         SW6->W6_NF_COMP:= cInvFiscal
         SW6->W6_SE_NFC := cInvSerie
      Else
         SW6->W6_NF_ENT := cInvFiscal
         SW6->W6_SE_NF  := cInvSerie
         SW6->W6_DT_ENTR:= dDataBase
      EndIf
      SW6->(MsUnLock())
   EndIf
   SW6->(dbSetOrder(aOrdW6[1]),dbGoTo(aOrdW6[2]))
   
   IF !SF1->(DBSeek(xFilial("SF1")+cInvFiscal+cInvSerie+cForn+cLoja+cTipo))
      
      SF1->(DBGOTO(nRecSF1))//Volta para grava no recno certo
      
      SF1->(RecLock("SF1",.F.))
      //    IF (!EMPTY(SF1->F1_NFORIG))//AWF-Tem que jogar a provisoria como origem quando vier a NF definitiva
      SF1->F1_NFORIG := SF1->F1_DOC
      SF1->F1_SERORIG:= SF1->F1_SERIE
      //    ENDIF
      SF1->F1_DOC   := cInvFiscal
      SF1->F1_SERIE := cInvSerie
      SF1->(MSUNLOCK())
      //    ConOut("*******************************************************************************")
      //    ConOut("*Chave gravada no SF1: ["+xFilial("SF1")+cInvFiscal+cInvSerie+cForn+cLoja+cTipo+"]")
      //    ConOut("*******************************************************************************")
   ELSE
      //    SF1->(MSUNLOCK())
      //    ConOut("*******************************************************************************")
      //    ConOut("*Chave ja cadastrada no SF1: ["+xFilial("SF1")+cInvFiscal+cInvSerie+cForn+cLoja+cTipo+"]")
      //    ConOut("*******************************************************************************")
      RETURN .T.
   ENDIF
   
   DO WHILE SWN->(DBSeek(xFilial("SWN")+cNumero+cSerie+cForn+cLoja+cTipo))
      SWN->(RecLock("SWN",.F.))
      SWN->WN_DOC   := cInvFiscal
      SWN->WN_SERIE := cInvSerie
      If SWN->WN_TIPO_NF == '9'
         NF100AtNFT("INCLUSAO")
      EndIf
      SWN->(MSUNLOCK())
   ENDDO
   
   DO WHILE SWW->(DBSeek(xFilial("SWN")+cNumero+cSerie+cForn+cLoja+cTipo))
      SWW->(RecLock("SWW",.F.))
      SWW->WW_NF_COMP:= cInvFiscal
      SWW->WW_SE_NFC := cInvSerie
      SWW->(MSUNLOCK())
   ENDDO
   
   IF Select("WORK1") > 0
      aPos := Work1->({IndexOrd(),RecNo()})
	  
	  Work1->(dbSetOrder(2))
	  Work1->(dbSeek(cNumero+cSerie))
	  Do While Work1->(!Eof() .AND. WK_NFE+WK_SE_NFE == cNumero+cSerie)
	     
		 Work1->WK_NFE    := cInvFiscal
		 Work1->WK_SE_NFE := cInvSerie
		 
	     Work1->(dbSkip())
	  EndDo
	  
	  Work1->(dbSetOrder(aPos[1]),dbGoTo(aPos[2]))
   EndIf
ELSE
   lRet := .F.
   // ConOut("********************************************************************************")
   // ConOut("*Chave nao encontrada no SF1: ["+xFilial("SF1")+cNumero+cSerie+cForn+cLoja+cTipo+"]")
   // ConOut("********************************************************************************")
EndIF

End Sequence

RETURN lRet

/*
Funcao      : NF100AtNFT
Parametros  : cOpcao-> "INCLUSAO" ou "ESTORNO"
Retorno     : <Nenhum>
Objetivos   : Atualizar o número de Nota Fiscal dos itens da NFT com base no Número
              vindo do ERP Externo.
Autor       : Nilson César
Data        : Novembro/2017
Revisao     :
Obs.        : Tabela SF1 e SWN deve estar posicionadas
*/
*---------------------------------*
Function NF100AtNFT(cOpcao)
*---------------------------------*
Local aOrdEIW := SaveOrd("EIW")
Local lCpsEIWOri := EIW->(FIELDPOS("EIW_DOCORI")) # 0 .AND. EIW->(FIELDPOS("EIW_SERORI")) # 0
Local lCpsSWNOri := SWN->(FIELDPOS("WN_DOCORI" )) # 0 .AND. SWN->(FIELDPOS("WN_SERORI" )) # 0
Local lWrkItNFT  := SELECT("WorkItens") > 0    //Integração síncrona da NFT
Local lCpsWKINFT := lWrkItNFT .And. WorkItens->(FieldPos("WKSTATUS"  )) > 0 .And. WorkItens->(FieldPos("WKMENNOTA" )) > 0 .And. ;
                                                                  WorkItens->(FieldPos("WK_OK"     )) > 0 .And. ;
                                                                  WorkItens->(FieldPos("WKNOTAPR"  )) > 0 .And. ;
                                                                  WorkItens->(FieldPos("WKSERIEPR" )) > 0
Default cOpcao := ""

If ChkFile("EIW")
   EIW->(DbSetOrder(1)) 
   If EIW->(DbSeek( xFilial("EIW") + SWN->( WN_HAWB + WN_PO_EIC + WN_ITEM + WN_PGI_NUM + WN_LOTECTL + WN_INVOICE  ) ))
      EIW->(RecLock("EIW",.F.))
      
      IF lCpsEIWOri
         If Empty(EIW->EIW_DOCORI) .And. Empty(EIW->EIW_SERORI)
            If cOpcao == "INCLUSAO" 
               EIW->EIW_DOCORI := EIW->EIW_NOTA
               EIW->EIW_SERORI := EIW->EIW_SERIE
            ElseIf cOpcao == "ESTORNO" 
               EIW->EIW_NOTA   :=  EIW->EIW_DOCORI
               EIW->EIW_SERIE  :=  EIW->EIW_SERORI
               EIW->EIW_DOCORI :=  ""
               EIW->EIW_SERORI :=  ""               
            EndIf
         Else
            If lCpsSWNOri
               If cOpcao == "INCLUSAO"
                  EIW->EIW_DOCORI := SWN->WN_DOCORI
                  EIW->EIW_SERORI := SWN->WN_SERORI
               ElseIf cOpcao == "ESTORNO"
                  EIW->EIW_NOTA   :=  SWN->WN_DOCORI
                  EIW->EIW_SERIE  :=  SWN->WN_SERORI              
               EndIf
            EndIf         
         EndIf
      ENDIF 
      
      If cOpcao == "INCLUSAO"
         EIW->EIW_NOTA  := SWN->WN_DOC
         EIW->EIW_SERIE := SWN->WN_SERIE
      ElseIf cOpcao == "ESTORNO"
         EIW->EIW_NOTA  :=  If( EIW->EIW_NOTA == SWN->WN_DOC, "" ,EIW->EIW_NOTA )
         EIW->EIW_SERIE :=  If( EIW->EIW_SERIE == SWN->WN_SERIE , "" ,EIW->EIW_SERIE )       
      EndIf 
      
      EIW->(MsUnlock())
            
      If lWrkItNFT
         WorkItens->(DbSetOrder(1))
         If WorkItens->(DbSeek(EIW->EIW_PO_NUM+EIW->EIW_POSICA+EIW->EIW_PGI_NU+EIW->EIW_LOTECT+EIW->EIW_INVOIC))
            WorkItens->WN_DOC    := EIW->EIW_NOTA
            WorkItens->WN_SERIE  := EIW->EIW_SERIE
            If lCpsWKINFT
               If cOpcao == "INCLUSAO" 
                  WorkItens->WKSTATUS  := SF1->F1_STATUS
                  WorkItens->WKMENNOTA := SF1->F1_MENNOTA
                  WorkItens->WK_OK     := SF1->F1_OK
               ElseIf cOpcao == "ESTORNO"
                  WorkItens->WKSTATUS  := "0"
                  WorkItens->WKMENNOTA := ""
                  WorkItens->WK_OK     := "0"              
               EndIf
               If lCpsEIWOri
                  If cOpcao == "INCLUSAO" 
                     WorkItens->WKNOTAPR  := EIW->EIW_DOCORI
                     WorkItens->WKSERIEPR := EIW->EIW_SERORI
                  ElseIf cOpcao == "ESTORNO"
                     WorkItens->WKNOTAPR  := ""
                     WorkItens->WKSERIEPR := ""                  
                  EndIf           
               EndIf
            EndIf
         EndIf
      EndIf
      
   EndIf  
EndIf 

RestOrd(aOrdEIW,.T.)

Return

/*
Funcao      : NF100FnInv()
Parâmetros  :
Retorno     : cFornRet - Cod. do fornecedor+loja do pedido
Objetivos   : retornar o código do fornecedor+loja do pedido relacionado ao item da Nota fiscal
Autor       : Nilson César
Data/Hora   : 18/12/2017
*/
Static Function NF100FnInv() 
Local cFornRet :=  AvKey( SWN->WN_FORNECE , "W9_FORN" ) + AvKey( SWN->WN_LOJA , "W9_FORLOJ" )		
Local aOrdSW2 := SaveOrd("SW2")

SW2->(DbSetOrder(1))
If SW2->(DbSeek(xFilial("SW2")+SWN->WN_PO_EIC))
   cFornRet := SW2->( W2_FORN + W2_FORLOJ )
EndIf

RestOrd( aOrdSW2 )

Return cFornRet








 
