#include "average.ch"
/*
Funcao     : EECAF213()
Parametros : Nenhum
Retorno    : .T
Objetivos  : -
Autor      : Bruno Akyo Kubagawa  - Baixa a Receber
Data/Hora  : 10/01/2012
*/

Function EECAF213()  
Private aRotina   := MenuDef()

   If !Empty(EEQ->EEQ_FINNUM) .And. Empty(EEQ->EEQ_SEQBX)
      EasyEnvEAI("EECAF213",3)
   EndIf

Return .T.


Static Function MenuDef()

Local aRotina :=  {  { "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","AF213Man" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "AF213Man" , 0 , 3},; //"Incluir"
                     { "Alterar",   "AF213Man" , 0 , 4},; //"Alterar"
                     { "Excluir",   "AF213Man" , 0 , 5,3} } //"Excluir"
                   


Return aRotina

Function AF213Man(cAlias,nReg,nOpc)

Return Nil

Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI
	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("EEQ")
	oEasyIntEAI:SetModule("EEC",29) 
		

	//*** Envio
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF213ASENB") //ENVIO DE BUSINESS MESSAGE           (<-Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF213ARESR") //RESPOSTA SOBRE O ENVIO DA BUSINESS  (->Response)
	//***
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()


Function AF213ASENB(oEasyMessage) 
Local oXml      := EXml():New()
Local oBusiness := ENode():New()
Local oRequest  := ENode():New()
Local oRec      := ENode():New()
Local oListOfDepositData
Local oDepositData
Local aOrd := SaveOrd({"EC6"})
Local dDataCredito
Local oOtherValues 
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


   nEAIRecNo:= EEQ->(RecNo())

   EC6->(DbSetOrder(1))//EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
   EC6->(DbSeek(xFilial("EC6") + AvKey("EXPORT","EC6_TPMODU") + AvKey(EEQ->EEQ_EVENT,"EC6_ID_CAM")))

   oRequest:SetField("Operation", "EECAF213")

    
   //<BusinessContent>
   //   <CompanyId>01</CompanyId>
   oBusiness:SetField('CompanyId'       ,cEmpMsg)
   //   <BranchId>55</BranchId>
   oBusiness:SetField('BranchId'        ,cFilMsg)
   //   <DocumentPrefix></DocumentPrefix> - Prefixo (Série) do título
   oBusiness:SetField('DocumentPrefix',EEQ->EEQ_PREFIX)
   //   <DocumentNumber></DocumentNumber> - Número do Título
   oBusiness:SetField('DocumentNumber',EEQ->EEQ_FINNUM)
   //   <DocumentParcel></DocumentParcel> - Parcela do Título
   oBusiness:SetField('DocumentParcel', RetAsc( Val(IF(!Empty(EEQ->EEQ_PARVIN), EEQ->EEQ_PARVIN, EEQ->EEQ_PARC)),1,.T. ) ) //ORIGEM
   //   <DocumentTypeCode></DocumentTypeCode> - Tipo do Título
   oBusiness:SetField('DocumentTypeCode',EEQ->EEQ_TPTIT)

   If EasyVerModal("EEQ")
      dDataCredito := EEQ->EEQ_DTCE
   Else
      dDataCredito := EEQ->EEQ_PGT
   EndIf 
   
   If !Empty(EEQ->EEQ_DTCE)
      //   <PaymentDate></PaymentDate> - Data em que o valor foi creditado na conta da empresa
      oBusiness:SetField('PaymentDate',EasyTimeStamp(EEQ->EEQ_DTCE/*EEQ->EEQ_PGT*/, .T. , .T.))
   EndIf  
   
   If !Empty(dDataCredito)
      //   <CreditDate></CreditDate> - Data em que o Cliente Efetuou o Pagamento do Título
      oBusiness:SetField('CreditDate',EasyTimeStamp(dDataCredito, .T. , .T.))
   EndIf

   //   <EntryDate></EntryDate> - Data de Lançamento da Baixa no Sistema
   oBusiness:SetField('EntryDate',EasyTimeStamp(dDataBase, .T. , .T.))
   //   <PaymentValue></PaymentValue> - Valor do Pagamento
   oBusiness:SetField('PaymentValue',Str(EEQ->(EEQ_VL - EEQ_CGRAFI /*- EEQ_ADEDUZ*/)/*EEQ_VLFCAM*/))

   If EEQ->(FieldPos("EEQ_DESCON")) > 0 .And. EEQ->EEQ_DESCON <> 0
      oOtherValues := ENode():New()
      oOtherValues:SetField("DiscountValue",EEQ->EEQ_DESCON) 
      oBusiness:SetField('OtherValues',oOtherValues)
   EndIf  

   //   <CurrencyCode></CurrencyCode> - Código da Moeda
    SYF->(dbSetOrder(1))  //YF_FILIAL+YF_MOEDA
    SYF->(dbSeek(xFilial()+EEQ->EEQ_MOEDA))
    If EC6->EC6_TXCV == "2" //COMPRA 
    	oBusiness:SetField('CurrencyCode'       ,SYF->YF_CODCERP)
    Else //VENDA
    	oBusiness:SetField('CurrencyCode'       ,SYF->YF_CODVERP)
    EndIf
   //   <CurrencyRate></CurrencyRate> - Taxa da Moeda
   oBusiness:SetField('CurrencyRate',EEQ->EEQ_TX)
   //oBusiness:SetField('CurrencyRate'       ,STR(BuscaTaxa(EEQ->EEQ_MOEDA,EEC->EEC_DTEMBA,,.F.,,,EC6->EC6_TXCV)))
   //   <CustomerCode></CustomerCode> - Código do Cliente
   oBusiness:SetField('CustomerCode',EEQ->EEQ_IMPORT)
   //   <StoreId></StoreId> - Loja
   oBusiness:SetField('StoreId',EEQ->EEQ_IMLOJA)
   //   <PaymentMethod></PaymentMethod> - Forma de Baixa - 001-AD - ADIANTAMENTO, 002-AB - ABATIMENTO, 003-DV - DEVOLUÇÃO, 004-NC - NOTA DE CRÉDITO/TÍTULOS DE CRÉDITO, 005-NP - NOTA PROMISSÓRIA, 006-BX - BAIXA, 007-NOR - NORMAL, 008-DAC - DACAO, 009-DEB - DEBITO CC, 010-VEN - VENDOR, 011-LIQ - LIQUIDA, 012-FAT - FATURAS, 013-CRD - CREDITO, 014-CEC - COMP CARTE</xs:documentation>
   oBusiness:SetField('PaymentMethod',"006")
   //   <PaymentMeans></PaymentMeans> - Meio de Pagamento - 000-OUTROS, 001-DINHEIRO, 002-CHEQUE, 003-CARTAO, 004-CARTAO DE DEBITO, 005-PARCELADO, 006-VALE</xs:documentation>
   oBusiness:SetField('PaymentMeans',"000")
   
   //NCF - 12/11/2013 - Verificar se a baixa se refere a parcela de câmbio vinculada a contrato de Financiamento
   aPtBxTitFin := EX400BxTFin()
   If aPtBxTitFin[1]  //Utiliza o portador do cadastrado na tabela de Tipos de Financiamento (EF7)
      //   <HolderCode></HolderCode> - Portador da Baixa
      oBusiness:SetField('HolderCode', aPtBxTitFin[2][1] )
      //   <HolderType></HolderType> - Tipo de Portador da Baixa
      oBusiness:SetField('HolderType', aPtBxTitFin[2][2] )    
   Else               //Utiliza o portador do cadastrado na conta por banco (ECI)
      //   <HolderCode></HolderCode> - Portador da Baixa
      if !EasyVerModal("EEQ")
         oBusiness:SetField('HolderCode',EasyHolderCode(EEQ->EEQ_BANC ,EEQ->EEQ_AGEN,EEQ->EEQ_NCON ,EEQ->EEQ_BANC ,EEQ->EEQ_AGEN,EEQ->EEQ_NCON,"EXPORT",EEQ->EEQ_EVENT,EEQ->EEQ_IMPORT,EEQ->EEQ_IMLOJA,EEQ->EEQ_FORN,EEQ->EEQ_FOLOJA))
         //   <HolderType></HolderType> - Tipo de Portador da Baixa
         oBusiness:SetField('HolderType',EasyTypeHolder(EEQ->EEQ_BANC ,EEQ->EEQ_AGEN,EEQ->EEQ_NCON ,EEQ->EEQ_BANC ,EEQ->EEQ_AGEN,EEQ->EEQ_NCON,"EXPORT",EEQ->EEQ_EVENT,EEQ->EEQ_IMPORT,EEQ->EEQ_IMLOJA,EEQ->EEQ_FORN,EEQ->EEQ_FOLOJA)) // "B"
      Else
         oBusiness:SetField('HolderCode',EasyHolderCode(EEQ->EEQ_BCOEXT ,EEQ->EEQ_AGCEXT,EEQ->EEQ_CNTEXT ,EEQ->EEQ_BCOEXT ,EEQ->EEQ_AGCEXT,EEQ->EEQ_CNTEXT,"EXPORT",EEQ->EEQ_EVENT,EEQ->EEQ_IMPORT,EEQ->EEQ_IMLOJA,EEQ->EEQ_FORN,EEQ->EEQ_FOLOJA))
         //   <HolderType></HolderType> - Tipo de Portador da Baixa
         oBusiness:SetField('HolderType',EasyTypeHolder(EEQ->EEQ_BCOEXT ,EEQ->EEQ_AGCEXT,EEQ->EEQ_CNTEXT ,EEQ->EEQ_BCOEXT ,EEQ->EEQ_AGCEXT,EEQ->EEQ_CNTEXT,"EXPORT",EEQ->EEQ_EVENT,EEQ->EEQ_IMPORT,EEQ->EEQ_IMLOJA,EEQ->EEQ_FORN,EEQ->EEQ_FOLOJA)) // "B"
      endif
   EndIf
   //   <FinancialCode></FinancialCode> - Código da Natureza (Protheus)
   oBusiness:SetField('FinancialCode',EC6->EC6_NATFIN)
   //   <HistoryText></HistoryText> - Historico do Movimento - máximo 200
   //oBusiness:SetField('HistoryText',"")

   //   <ListOfDepositData> - type="ListOfDepositDataType" - Dados do Depósito Bancário
   oListOfDepositData := ENode():New()
   //      <DepositData>
      oDepositData := ENode():New()
      If !Empty(EEQ->EEQ_PGT)
   //         <DepositDate></DepositDate> - Data em que o depósito foi realizado no banco
         oDepositData:SetField('DepositDate',EasyTimeStamp(EEQ->EEQ_PGT,.T.,.T.))
      EndIf
   //         <DepositValue></DepositValue> - Valor do Depósito Bancário
         //oDepositData:SetField('DepositValue',Str(EEQ->EEQ_EQVL)) //NOPADO POR AOM - 26/01/2012 - Pois o valor vai ser enviado em moeda estrangeira
         oDepositData:SetField('DepositValue',Str(EEQ->(EEQ_VL - EEQ_CGRAFI - If(FieldPos("EEQ_DESCON") > 0, EEQ_DESCON, 0) )))
         
   //      </DepositData>
      oListOfDepositData:SetField("DepositData",oDepositData)   
   //   </ListOfDepositData>
   oBusiness:SetField("ListOfDepositData",oListOfDepositData)
   //   <DischargeSequence></DischargeSequence> - Sequência da Baixa. Utilizado para estornar a baixa.
   oBusiness:SetField("DischargeSequence",EEQ->EEQ_SEQBX)

   //</BusinessContent>
   oRec:SetField('BusinessRequest',oRequest)
   oRec:SetField('BusinessContent',oBusiness) 
   oXml:AddRec(oRec)
   RestOrd(aOrd,.T.)
   
Return oXml

*-------------------------------------------------*
Function AF213ARESR(oEasyMessage) 
*-------------------------------------------------*
Local oBusinessCont  := oEasyMessage:GetRetContent()
Local aOrd := SaveOrd({"EEQ"}) 
Local cParcela := EEQ->EEQ_PARC //Improvisado pois não existe a tag Identification quando é request. Neste caso não sabemos qual a parcela original pois a enviada é a parvin.
Local lSeek

   If Empty(cParcela)
      cParcela := EasyGetXMLinfo(, oBusinessCont, "_DocumentParcel")
      cParcela := RetAsc(cParcela,AvSX3("EEQ_PARC",AV_TAMANHO),.F.)
   EndIf

   If Type("nEAIRecNo") == "N" //declarada na função EasyEAIBuffer()
      EEQ->(DBGoTo(nEAIRecNo))
      lSeek:= .T.
   Else
      EEQ->(DbSetOrder(12)) //EEQ_FILIAL+EEQ_PREFIX+EEQ_TPTIT+EEQ_FINNUM+EEQ_PARC // GFP - 07/02/2012
      lSeek:= EEQ->(DbSeek(xFilial("EEQ") + AvKey(EasyGetXMLinfo(, oBusinessCont, "_DocumentPrefix"),"EEQ_PREFIX") +;
                                            AvKey(EasyGetXMLinfo(, oBusinessCont, "_DocumentTypeCode"),"EEQ_TPTIT") +;
                                            AvKey(EasyGetXMLinfo(, oBusinessCont, "_DocumentNumber"),"EEQ_FINNUM") +;
                                            AvKey(cParcela,"EEQ_PARC")))
   EndIf

   If lSeek
      Begin Transaction
         If EEQ->(RecLock("EEQ",.F.)) 
            EEQ->EEQ_SEQBX := EasyGetXMLinfo(, oBusinessCont, "_DischargeSequence")
            EEQ->(MsUnlock())
         EndIf 
      End Transaction
      oEasyMessage:AddInList("RECEIVE", {"Sucesso" , "Registro Gravado no Destino" , Nil})
   
   EndIf
   
RestOrd(aOrd,.T.)

Return oEasyMessage
