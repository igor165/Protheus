#Include 'average.ch'


/*========================================================================================
Funcao        : EECAF226 - Baixa das despesas dos contratos
Parametros    : -              
Objetivos     : Apenas função nominal para cadastrar o adapter do fonte EECAF226
Autor         : Felipe Sales Martinez - FSM
Data/Hora     : 23/01/2012 - 12:21 hs
Revisao       : 
Obs.          : 
==========================================================================================*/

Function EECAF226()

Private aRotina   := MenuDef()
                                                                 //NCF - 26/09/2014 - Permitir baixa automática dos eventos de juros
   If (!Empty(EF3->EF3_TITFIN) .And. Empty(EF3->EF3_SEQBX)) .Or. ( Empty(EF3->EF3_TITFIN) .And. Empty(EF3->EF3_SEQBX) .and. (Type('lLiqJurEF3Auto')=='L' .And. lLiqJurEF3Auto) )
         
      EasyEnvEAI("EECAF226",3)  
      
   EndIf

Return .T.


Static Function MenuDef()

Local aRotina :=  {  { "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","AF226MAN" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "AF226MAN" , 0 , 3},; //"Incluir"
                     { "Alterar",   "AF226MAN" , 0 , 4},; //"Alterar"
                     { "Excluir",   "AF226MAN" , 0 , 5} } //"Excluir"                  

Return aRotina

Static Function AF226MAN()
Return Nil

/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: Felipe Sales Martinez
* Data: 23/01/2012 - 15:10 hs 
* =====================================================*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("EF1")

	oEasyIntEAI:SetModule("EFF",30)
	
	// *** Envio
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF226ASENB") //Envio de Business
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF226ARESR")	//Rebimento de retorno da Business Enviada
	// ***
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()


/*========================================================================================
Funcao Adapter: AF226ASENB
Parametros    : "oMessage" - Objeto XML com conteúdo da tag "BusinessContent" recebida                
Objetivos     : 
Autor         : Felipe Sales Martinez - FSM
Data/Hora     : 23/01/2012 - 15:30 hs
Revisao       : 
Obs.          : 
==========================================================================================*/
*------------------------------------------------*
Function AF226ASENB(oEasyMessage) 
*------------------------------------------------* 
Local oXml      := EXml():New()
Local oRec      := ENode():New()
Local oRequest  := ENode():New()
Local oBusiness := ENode():New()
Local oPayMent  := ENode():New()
Local oBank     := ENode():New()
Local cInfo := "", cBankCode := "", cBankAgency := "", cBankAccount :=  "" 
Local aOrdEF3 := SaveOrd({"EF3","EC6","EF1","SA6"}) 
Local cTpMODU := If(EF1->EF1_TPMODU = "I","FIIM", "FIEX") + EF3->EF3_TP_EVE
Local cEmpMsg := SM0->M0_CODIGO
Local cFilMsg := AvGetM0Fil() 
Local cParam, nPosDiv
 
If !Empty( cParam := Alltrim(EasyGParam("MV_EEC0036",,"")) )
   If (nPosDiv := At('/',cParam)) > 0
      cEmpMsg := Substr(cParam,1,nPosDiv-1) 
      cFilMsg := Substr(cParam,nPosDiv+1,Len(cParam))
   Else
      cEmpMsg := cParam 
      cFilMsg := cParam         
   EndIf  
EndIf

EC6->(DbSetOrder(1))//EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC 
EC6->(DbSeek(xFilial("EC6") + AvKey(cTpMODU,"EC6_TPMODU") + AvKey(EF3->EF3_CODEVE,"EC6_ID_CAM")))

SA6->(DbSetOrder(1))//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
SA6->(DbSeek(xFilial("SA6") +AvKey(EF1->EF1_BAN_FI,"A6_COD") ))


    /* BusinessRequest */
   oRequest:SetField("Operation", "EECAF226")
   
   
   /* BusinessContent */
   
   oBusiness:SetField('CompanyId'       ,cEmpMsg)
   oBusiness:SetField('BranchId'        ,cFilMsg)
   
   oBusiness:SetField("DocumentPrefix"         , EF3->EF3_PREFIX)
   oBusiness:SetField("DocumentNumber"         , EF3->EF3_TITFIN)
   oBusiness:SetField("DocumentParcel"         , RetAsc( Val(EF3->EF3_PARC),1,.T. ))
   oBusiness:SetField("DocumentTypeCode", EF3->EF3_TPTIT)

   //RMD - 01/12/14 - Considera a data de liquidação, caso exista
   If EF3->(FieldPos("EF3_DTOREV")) > 0 .And. !Empty(EF3->EF3_DTOREV)
       cInfo := EasyTimesTamp(EF3->EF3_DTOREV, .T., .T.)
       oBusiness:SetField("PaymentDate" , cInfo)
   ElseIf !Empty(EF3->EF3_DT_EVE)
       cInfo := EasyTimesTamp(EF3->EF3_DT_EVE, .T., .T.)
       oBusiness:SetField("PaymentDate" , cInfo)
   EndIf
   oBusiness:SetField('PaymentValue'  ,STR(EF3->EF3_VL_MOE))
   cInfo := If(!Empty(EF3->EF3_MOE_IN), EF3->EF3_MOE_IN, EF1->EF1_MOEDA )
   
   SYF->( dbSetOrder(1) )
   SYF->( dbSeek( xFilial() + cInfo ) )
   If EC6->EC6_TXCV == "2" //COMPRA 
      oBusiness:SetField('CurrencyCode'       ,SYF->YF_CODCERP)
   Else //VENDA
      oBusiness:SetField('CurrencyCode'       ,SYF->YF_CODVERP)
   EndIf
   
   oBusiness:SetField("CurrencyRate" , EF3->EF3_TX_MOE)
   
   If !Empty(EF3->EF3_FORN)
       cInfo := EF3->EF3_FORN
   Else
       cInfo := SA6->A6_CODFOR  
   EndIf
   oBusiness:SetField("VendorCode" , cInfo)

   
   If !Empty(EF3->EF3_LOJAFO)
      cInfo := EF3->EF3_LOJAFO
   Else
      cInfo := SA6->A6_LOJFOR
   EndIf   
   oBusiness:SetField("StoreId"      , cInfo)
   
   oBusiness:SetField("PaymentMethodCode" , "004")
   oBusiness:SetField("PaymentMeans" , "000")

   //AAF 29/12/2014 - Envio da agencia e conta corretos.
   SA6->(DbSetOrder(1))//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
   If !Empty(EF3->EF3_BANC) //MCF - 16/06/2016
      cBankCode :=  EF3->EF3_BANC
      cBankAgency := EF3->EF3_AGEN
      cBankAccount :=  EF3->EF3_NCON
      SA6->(DbSeek(xFilial("SA6") +AvKey(EF3->EF3_BANC,"A6_COD") +AvKey(EF3->EF3_AGEN,"A6_AGENCIA") +AvKey(EF3->EF3_NCON,"A6_NUMCON")))
   ElseIf !Empty(EF1->EF1_BAN_MO)
      cBankCode :=  EF1->EF1_BAN_MO
      cBankAgency := EF1->EF1_AGENMO
      cBankAccount :=  EF1->EF1_NCONMO
	  SA6->(DbSeek(xFilial("SA6") +AvKey(EF1->EF1_BAN_MO,"A6_COD") +AvKey(EF1->EF1_AGENMO,"A6_AGENCIA") +AvKey(EF1->EF1_NCONMO,"A6_NUMCON")))
   Else
      cBankCode :=  EF1->EF1_BAN_FI
      cBankAgency := EF1->EF1_AGENFI
      cBankAccount :=  EF1->EF1_NCONFI       
	  SA6->(DbSeek(xFilial("SA6") +AvKey(EF1->EF1_BAN_FI,"A6_COD") +AvKey(EF1->EF1_AGENFI,"A6_AGENCIA") +AvKey(EF1->EF1_NCONFI,"A6_NUMCON")))
   EndIf
   
   cBankAgency  := AllTrim(SA6->A6_AGENCIA) + If( Empty(SA6->A6_DVAGE), "" ,   "-" + AllTrim(SA6->A6_DVAGE) )
   cBankAccount :=  AllTrim(SA6->A6_NUMCON) + If( Empty(SA6->A6_DVCTA), "" ,   "-" + AllTrim(SA6->A6_DVCTA) )
   
   oBank:SetField("BankCode", cBankCode )
   oBank:SetField("BankAgency",cBankAgency)
   oBank:SetField("BankAccount",cBankAccount)
   oBusiness:SetField("Bank", oBank)
   
   oBusiness:SetField("FinancialCode" , EC6->EC6_NATFIN)
   
   oPayMent:SetField("DocumentPrefix", "") //Campo obrigatorio
   oPayMent:SetField("DocumentNumber", EF1->EF1_CONTRA)
   oBusiness:SetField("PaymentDocument", oPayMent)

   oBusiness:SetField("DischargeSequence", EF3->EF3_SEQBX)


   oRec:SetField("BusinessRequest",oRequest)
   oRec:SetField("BusinessContent",oBusiness) 
   oXml:AddRec(oRec)
	
RestOrd(aOrdEF3,.T.)

Return oXml

/*========================================================================================
Funcao Adapter: AF226ARESR
Parametros    : "oMessage" - Objeto XML com conteúdo da tag "BusinessContent" recebida                
Objetivos     : RECEBER uma RESPONSE (apos envio de BUSINNES) e gravar arquivo 
Autor         : Felipe Sales Martinez - FSM
Data/Hora     : 23/01/2012 - 17:30 hs
Revisao       : 
Obs.          : 
==========================================================================================*/
*------------------------------------------------*
Function AF226ARESR(oEasyMessage) 
*------------------------------------------------* 
Local oBusinessCont  := oEasyMessage:GetRetContent()
Local aOrdEF3 := SaveOrd({"EF3"}) 
Local cPrefixo := EasyGetXMLInfo("EF3_PREFIX" , oBusinessCont ,"_DocumentPrefix" )
Local cTitulo :=  EasyGetXMLInfo("EF3_TITFIN" , oBusinessCont ,"_DocumentNumber" ) 
Local cParc := EasyGetXMLInfo("EF3_PARC" , oBusinessCont ,"_DocumentParcel" )
Local cTipo := EasyGetXMLInfo("EF3_TPTIT" , oBusinessCont ,"_DocumentTypeCode" )

If !Empty(cParc)
   cParc := RetAsc(cParc,AvSX3("EF3_PARC",AV_TAMANHO),.F.)
EndIf

EF3->( DbSetOrder(9) ) //EF3_FILIAL+EF3_PREFIX+EF3_TPTIT+EF3_TITFIN+EF3_PARC  // GFP - 16/02/2012
If EF3->(DbSeek( xFilial("EF3") + AvKey(cPrefixo,"EF3_PREFIX") + AvKey(cTipo,"EF3_TPTIT") +;
          AvKey(cTitulo,"EF3_TITFIN") + AvKey(cParc,"EF3_PARC")))  ;
   .Or. ;
   EF3->(DbSeek( xFilial("EF3") + AvKey(cPrefixo,"EF3_PREFIX") + AvKey(cTipo,"EF3_TPTIT") +;
          AvKey(cTitulo,"EF3_TITFIN") + AvKey("","EF3_PARC")))

   Begin Transaction

       If EF3->(RecLock("EF3",.F.))
          EF3->EF3_SEQBX := EasyGetXMLInfo( "EF3_SEQBX", oBusinessCont ,"_DischargeSequence" )
          EF3->(MsUnlock())
       EndIf

   End Transaction

EndIf

RestOrd(aOrdEF3,.T.)


Return oEasyMessage 

