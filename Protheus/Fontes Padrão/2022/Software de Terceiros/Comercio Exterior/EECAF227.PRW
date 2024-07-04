#Include 'average.ch'
/*
Funcao     : EECAF227()
Parametros : Nenhum
Retorno    : .T
Objetivos  : Compensação de Adiantamento
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 10/01/2012
*/

Function EECAF227()
   Local lRet := .T.
   Private aRotina   := MenuDef() 

   If !Empty(EEQ->EEQ_FINNUM) .And. Empty(EEQ->EEQ_SEQBX)
      If EEQ->EEQ_EVENT == "603" //THTS - 28/03/2018 - Adiantamento Pos-Embarque
            lRet := EasyEnvEAI("EECAF227",3)
      Else
            lRet := EasyEnvEAI("EECAF227",3,.T.)
      EndIf
   EndIf 
   
Return lRet


Static Function MenuDef()

   Local aRotina :=  {  { "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                        { "Visualizar","AF227Man" , 0 , 2},; //"Visualizar"
                        { "Incluir",   "AF227Man" , 0 , 3},; //"Incluir"
                        { "Alterar",   "AF227Man" , 0 , 4},; //"Alterar"
                        { "Excluir",   "AF227Man" , 0 , 5,3} } //"Excluir"
                   

Return aRotina  

Function AF227Man(cAlias,nReg,nOpc)
   //
Return Nil

Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
   Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("EEQ")
	//oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| EECAT170(oEasyMessage:GetEAutoArray("EE5"),,oEasyMessage:GetOperation(), oEasyMessage:GetEAutoArray("EEK"))} )
	oEasyIntEAI:SetModule("EEC",29) 
	
	// *** Envio
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF227ASENB") //ENVIO DE BUSINESS MESSAGE           (<-Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF227ARESR") //RESPOSTA SOBRE O ENVIO DA BUSINESS  (->Response)
	// ***
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()


Function AF227ASENB(oEasyMessage) 
   Local oXml      := EXml():New()
   //Local oBusiness := ENode():New()
   Local oRequest  := ENode():New()
   Local oRec      := ENode():New()
   Local oListOfCreditDocument
   Local oCreditDocument
   Local oListOfDepositData
   Local oDepositData
   Local aOrd := SaveOrd({"EC6"})
   Local dDataCredito
   Local aAdiantamentos := {}
   Local cEmpMsg := SM0->M0_CODIGO
   Local cFilMsg := AvGetM0Fil() 
   Local cParam, nPosDiv

   Private oBusiness := ENode():New()
   Private lTxDtEmba := .F.     //MPG - será enviada a TAXA do adiantamento por padrão.

   If EasyEntryPoint("EECAF227")
      ExecBlock("EECAF227",.F.,.F., "AF227ASENB_INICIO")
   Endif
   
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

   oRequest:SetField("Operation", "EECAF227")

   oBusiness:SetField('CompanyId' ,cEmpMsg)
   oBusiness:SetField('BranchId'  ,cFilMsg)
   oBusiness:SetField('DocumentPrefix',EEQ->EEQ_PREFIX)
   oBusiness:SetField('DocumentNumber',EEQ->EEQ_FINNUM)
   oBusiness:SetField('DocumentParcel',RetAsc( Val(EEQ->EEQ_PARC), 1 ,.T. ) )
   oBusiness:SetField('DocumentTypeCode',EEQ->EEQ_TPTIT)

      //   <PaymentDate></PaymentDate> - Data em que o Cliente Efetuou o Pagamento do Título
   oBusiness:SetField('PaymentDate',EasyTimeStamp(EEC->EEC_DTEMBA, .T. , .T.))

   If !Empty(EEQ->EEQ_DTCE)
      dDataCredito := EEQ->EEQ_DTCE
   Else
      dDataCredito := EEQ->EEQ_PGT
   EndIf

   If !Empty(dDataCredito)
      //   <CreditDate></CreditDate> - Data em que o Valor foi Crédito na Conta da Empresa
	  oBusiness:SetField('CreditDate',EasyTimeStamp(EEC->EEC_DTEMBA, .T. , .T.))
   EndIf

   //   <EntryDate></EntryDate> - Data de Lançamento da Baixa no Sistema
   oBusiness:SetField('EntryDate',EasyTimeStamp(dDataBase, .T. , .T.))
   //   <PaymentValue></PaymentValue> - Valor do Pagamento
   oBusiness:SetField('PaymentValue',EEQ->(EEQ_VL - EEQ_CGRAFI))

   If EEQ->(FieldPos("EEQ_DESCON")) > 0 .And. EEQ->EEQ_DESCON <> 0
      oOtherValues := ENode():New()
      oOtherValues:SetField("DiscountValue",EEQ->EEQ_DESCON) 
      oBusiness:SetField('OtherValues',oOtherValues)
   EndIf
   
   aAdiantamentos := GetAdiantamentos(EEQ->EEQ_PROR,EEQ->EEQ_PAOR,EEQ->EEQ_FAOR)
   
   //RMD - 24/11/14 - Define se será enviada a taxa da data de embarque ou da parcela (EEQ)
   If lTxDtEmba
      oBusiness:SetField('CurrencyRate' ,Alltrim(STR(BuscaTaxa(EEQ->EEQ_MOEDA,EEC->EEC_DTEMBA,,.F.,,,EC6->EC6_TXCV))))
   Else
      oBusiness:SetField('CurrencyRate' ,RetAdiantCpo(aAdiantamentos,'CurrencyRate'))
   EndIf
    
   //   <CustomerCode></CustomerCode> - Código do Cliente
   oBusiness:SetField('CustomerCode',EEQ->EEQ_IMPORT)
   //   <StoreId></StoreId> - Loja
   oBusiness:SetField('StoreId',EEQ->EEQ_IMLOJA)
   //   <PaymentMethod></PaymentMethod> - Forma de Baixa - 001-AD - ADIANTAMENTO, 002-AB - ABATIMENTO, 003-DV - DEVOLUÇÃO, 004-NC - NOTA DE CRÉDITO/TÍTULOS DE CRÉDITO, 005-NP - NOTA PROMISSÓRIA, 006-BX - BAIXA, 007-NOR - NORMAL, 008-DAC - DACAO, 009-DEB - DEBITO CC, 010-VEN - VENDOR, 011-LIQ - LIQUIDA, 012-FAT - FATURAS, 013-CRD - CREDITO, 014-CEC - COMP CARTE</xs:documentation>
   oBusiness:SetField('PaymentMethod',"004")
   //   <PaymentMeans></PaymentMeans> - Meio de Pagamento - 000-OUTROS, 001-DINHEIRO, 002-CHEQUE, 003-CARTAO, 004-CARTAO DE DEBITO, 005-PARCELADO, 006-VALE</xs:documentation>
   oBusiness:SetField('PaymentMeans',"000")
   //   <HolderCode></HolderCode> - Portador da Baixa
   If !Empty(EasyGParam("MV_AVG0215",.T.,""))
      oBusiness:SetField('HolderCode',EasyGParam("MV_AVG0215",.T.,""))
   Else                                                                           //NCF - 12/03/2014
      oBusiness:SetField('HolderCode', RetAdiantCpo(aAdiantamentos,'HolderCode') /*EasyHolderCode(EEQ->EEQ_BANC ,EEQ->EEQ_AGEN,EEQ->EEQ_NCON ,EEQ->EEQ_BANC ,EEQ->EEQ_AGEN,EEQ->EEQ_NCON,"EXPORT",EEQ->EEQ_EVENT,EEQ->EEQ_IMPORT,EEQ->EEQ_IMLOJA,EEQ->EEQ_FORN,EEQ->EEQ_FOLOJA,"A")*/)
   EndIf
   
   If !Empty(EasyGParam("MV_AVG0216",,""))
      oBusiness:SetField('HolderType',EasyGParam("MV_AVG0216",,""))
   Else
      //   <HolderType></HolderType> - Tipo de Portador da Baixa                 //NCF - 12/03/2014
      oBusiness:SetField('HolderType', RetAdiantCpo(aAdiantamentos,'HolderType') /*EasyTypeHolder(EEQ->EEQ_BANC ,EEQ->EEQ_AGEN,EEQ->EEQ_NCON ,EEQ->EEQ_BANC ,EEQ->EEQ_AGEN,EEQ->EEQ_NCON,"EXPORT",EEQ->EEQ_EVENT,EEQ->EEQ_IMPORT,EEQ->EEQ_IMLOJA,EEQ->EEQ_FORN,EEQ->EEQ_FOLOJA,"A")*/) // "C"
   EndIf
   
   //   <FinancialCode></FinancialCode> - Código da Natureza (Protheus)
   oBusiness:SetField('FinancialCode',EC6->EC6_NATFIN)
   //   <HistoryText></HistoryText> - Historico do Movimento - máximo 200
   //oBusiness:SetField('HistoryText',"")

   //   <ListOfCreditDocument> - type = "ListOfCreditDocumentType" - Título de Crédito
   oListOfCreditDocument := ENode():New()
   
   //      <CreditDocument>
      oCreditDocument := ENode():New()
   //         <CompanyId></CompanyId> - Empresa
         oCreditDocument:SetField('CompanyId'       ,cEmpMsg)
   //   <BranchId>55</BranchId>
         oCreditDocument:SetField('BranchId'        ,cFilMsg)
   //         <DocumentPrefix></DocumentPrefix> - Prefixo (Serie) do Título
         oCreditDocument:SetField('DocumentPrefix',RetAdiantCpo(aAdiantamentos,'DocumentPrefix'))
   //         <DocumentNumber></DocumentNumber> - Número do Título
         oCreditDocument:SetField('DocumentNumber',RetAdiantCpo(aAdiantamentos,'DocumentNumber'))
   //         <DocumentParcel></DocumentParcel> - Parcela
         oCreditDocument:SetField('DocumentParcel',RetAdiantCpo(aAdiantamentos,'DocumentParcel'))
   //         <DocumentTypeCode></DocumentTypeCode> - Código do Tipo de Documento
         oCreditDocument:SetField('DocumentTypeCode',RetAdiantCpo(aAdiantamentos,'DocumentTypeCode'))
   //         <CustomerCode></CustomerCode> - Código do Cliente
         oCreditDocument:SetField('CustomerCode',RetAdiantCpo(aAdiantamentos,'CustomerCode'))
   //         <StoreId></StoreId> - Loja
         oCreditDocument:SetField('StoreId',RetAdiantCpo(aAdiantamentos,'StoreId'))
   //         <DocumentValue></DocumentValue> - Valor do Documento de Crédito	
         //oCreditDocument:SetField('DocumentValue',Str(RetAdiantCpo(aAdiantamentos,'DocumentValue')))
         oCreditDocument:SetField('DocumentValue',EEQ->(EEQ_VL - EEQ_CGRAFI))
   //      </CreditDocument>
      oListOfCreditDocument:SetField("CreditDocument",oCreditDocument)      
   //   </ListOfCreditDocument>
   oBusiness:SetField("ListOfCreditDocument",oListOfCreditDocument)

   //   <ListOfDepositData> - type="ListOfDepositDataType" - Dados do Depósito Bancário
   oListOfDepositData := ENode():New()
   //      <DepositData>
      oDepositData := ENode():New()
      If !Empty(EEQ->EEQ_PGT)
   //         <DepositDate></DepositDate> - Data em que o depósito foi realizado no banco
         //oDepositData:SetField('DepositDate',EasyTimeStamp(EEQ->EEQ_PGT,.T.,.T.))
      EndIf
   //         <DepositValue></DepositValue> - Valor do Depósito Bancário
         //oDepositData:SetField('DepositValue',Str(EEQ->EEQ_EQVL))
   //      </DepositData>
      //oListOfDepositData:SetField("DepositData",oDepositData)   
   //   </ListOfDepositData>
   //oBusiness:SetField("ListOfDepositData",oListOfDepositData)
   //   <DischargeSequence></DischargeSequence> - Sequência da Baixa. Utilizado para estornar a baixa.
   oBusiness:SetField("DischargeSequence",EEQ->EEQ_SEQBX)

	If EasyEntryPoint("EECAF227")
	   ExecBlock("EECAF227",.F.,.F., "MSG_COMP_ADIANT_ALTERA_DADOS_TAGS")
	Endif

   //</BusinessContent>
   oRec:SetField('BusinessRequest',oRequest)
   oRec:SetField('BusinessContent',oBusiness) 
   oXml:AddRec(oRec)
   RestOrd(aOrd,.T.)
   
Return oXml

*-------------------------------------------------*
Function AF227ARESR(oEasyMessage) 
*-------------------------------------------------*
   Local oMessage := oEasyMessage:GetRetContent()
   Local aOrd := SaveOrd({"EEQ"}) 
   Local cParcela := EasyGetXMLinfo(, oMessage, "_DocumentParcel")
   Local lSeek

   If !Empty(cParcela)
      cParcela := RetAsc(cParcela,AvSX3("EEQ_PARC",AV_TAMANHO),.F.)
   EndIf

   If Type("nEAIRecNo") == "N" //declarada na função EasyEAIBuffer()
      EEQ->(DBGoTo(nEAIRecNo))
      lSeek:= .T.
   Else
      EEQ->(DbSetOrder(12)) // EEQ_FILIAL+EEQ_PREFIX+EEQ_TPTIT+EEQ_FINNUM+EEQ_PARC  // GFP - 08/02/2012
      lSeek:= EEQ->(DbSeek(xFilial("EEQ") + AvKey(EasyGetXMLinfo(, oMessage, "_DocumentPrefix"  ),"EEQ_PREFIX") +;
                                            AvKey(EasyGetXMLinfo(, oMessage, "_DocumentTypeCode"),"EEQ_TPTIT" ) +;
                                            AvKey(EasyGetXMLinfo(, oMessage, "_DocumentNumber"  ),"EEQ_FINNUM") +;
                                            AvKey(cParcela,"EEQ_PARC")))
   EndIf
   If lSeek
      Begin Transaction
      If EEQ->(RecLock("EEQ",.F.)) 
         EEQ->EEQ_SEQBX :=      EasyGetXMLinfo( , oMessage                     , "_DischargeSequence")   //NCF - 07/06/2021 - Garantir retornar a mesma taxa que foi enviada na BusinessMessage
         EEQ->EEQ_TX    := Val( EasyGetXMLinfo( , oEasyMessage:GetBsnContent() , "_CurrencyRate"     ) ) //BuscaTaxa(EEQ->EEQ_MOEDA,EEQ->EEQ_EMISSA,,.F.,,,EC6->EC6_TXCV)    //NCF - 12/08/2014 - Modificar a taxa da cambial de adiantamento vinculado ao processo (que é a taxa do Ad. Principal)
         EEQ->EEQ_EQVL  := Round( EEQ->EEQ_VL*EEQ->EEQ_TX , AvSX3("EEQ_EQVL",AV_DECIMAL) )                                                                       //                   para a taxa da moeda na Data do Embarque (quando é enviado a baixa da cambial de adiantamento).
         EEQ->(MsUnlock())                                                                
      EndIf
      End Transaction
   EndIf

   RestOrd(aOrd,.T.)

Return oEasyMessage

Static Function GetAdiantamentos(cEEQ_PROR,cEEQ_PAOR,cEEQ_FAOR)
   Local aAdiantamentos := {}
   Local nOrdEEQ := EEQ->(IndexOrd())
   Local nRecno := EEQ->(Recno())

   BeginSql Alias "QRYEEQ"
      Select 
         R_E_C_N_O_ as RECNO
      From 
         %table:EEQ% EEQ
      WHERE %NotDel%
         AND EEQ_PREEMB = %exp:cEEQ_PROR%
         AND EEQ_PARC   = %exp:cEEQ_PAOR%
         AND EEQ_FASE   = %exp:cEEQ_FAOR%
   EndSql

   QRYEEQ->(dbgotop())
   if QRYEEQ->(!eof())
      // EEQ->(DbSetOrder(1)) 
      // If EEQ->(DbSeek(xFilial("EEQ")+AvKey(cEEQ_PROR,"EEQ_PREEMB")+AvKey(cEEQ_PAOR,"EEQ_PARC")+AvKey(cEEQ_FAOR,"EEQ_FASE"))) 
         EEQ->(DbGoTo( QRYEEQ->RECNO ))
         EC6->(DbSetOrder(1))//EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC 
         EC6->(DbSeek(xFilial("EC6") + AvKey("EXPORT","EC6_TPMODU") + AvKey(EEQ->EEQ_EVENT,"EC6_ID_CAM")))
         aAdd(aAdiantamentos,{"DocumentPrefix",EEQ->EEQ_PREFIX}) // DocumentPrefix - Prefixo (Serie) do Título
         aAdd(aAdiantamentos,{"DocumentNumber",EEQ->EEQ_FINNUM}) // DocumentNumber - Número do Título
         aAdd(aAdiantamentos,{"DocumentParcel",RetAsc(EEQ->EEQ_PARC,1,.F.)}) // DocumentParcel - Parcela
         aAdd(aAdiantamentos,{"DocumentTypeCode",EC6->EC6_TPTIT}) // DocumentTypeCode - Código do Tipo de Documento
         aAdd(aAdiantamentos,{"CustomerCode",EEQ->EEQ_IMPORT}) // CustomerCode - Código do Cliente
         aAdd(aAdiantamentos,{"StoreId",EEQ->EEQ_IMLOJA}) // StoreId - Loja
         aAdd(aAdiantamentos,{"DocumentValue",EEQ->EEQ_VL}) // DocumentValue - Valor do Documento de Crédito	
         aAdd(aAdiantamentos,{"CurrencyRate" ,EEQ->EEQ_TX})
         //NCF - 12/03/2014 - O Evento 602 é o evento de compensação de adiantamento onde deverá estar relacionada máscara para busca do portador da baixa
         //EC6->(DbSeek(xFilial("EC6") + AvKey("EXPORT","EC6_TPMODU") + AvKey("602","EC6_ID_CAM")))
         aAdd(aAdiantamentos,{"HolderCode" ,EasyHolderCode(EEQ->EEQ_BANC ,EEQ->EEQ_AGEN,EEQ->EEQ_NCON ,EEQ->EEQ_BANC ,EEQ->EEQ_AGEN,EEQ->EEQ_NCON,"EXPORT",EEQ->EEQ_EVENT,EEQ->EEQ_IMPORT,EEQ->EEQ_IMLOJA,EEQ->EEQ_FORN,EEQ->EEQ_FOLOJA,"A")})
         aAdd(aAdiantamentos,{"HolderType" ,EasyTypeHolder(EEQ->EEQ_BANC ,EEQ->EEQ_AGEN,EEQ->EEQ_NCON ,EEQ->EEQ_BANC ,EEQ->EEQ_AGEN,EEQ->EEQ_NCON,"EXPORT",EEQ->EEQ_EVENT,EEQ->EEQ_IMPORT,EEQ->EEQ_IMLOJA,EEQ->EEQ_FORN,EEQ->EEQ_FOLOJA,"A")})
      // EndIf
   endif

   QRYEEQ->(dbclosearea())
   EEQ->(DbSetOrder(nOrdEEQ))
   EEQ->(DbGoTo(nRecno))

Return aClone(aAdiantamentos)

Static Function RetAdiantCpo(aAdiantamentos,cCampo)
   Local xInfo
   Local nPos := 0

   If (nPos := aScan(aAdiantamentos,{ |X| AllTrim(Upper(X[1])) == AllTrim(Upper(cCampo))})) > 0
      xInfo := aAdiantamentos[nPos][2]
   EndIf

Return xInfo
