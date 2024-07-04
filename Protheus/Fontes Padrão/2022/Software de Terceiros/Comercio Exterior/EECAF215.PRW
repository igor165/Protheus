#include "average.ch"
/*========================================================================================
Funcao        : EECAF215 - Baixa de Contas a Pagar
Parametros    : -              
Objetivos     : Apenas função nominal para cadastrar o adapter do fonte EECAF215
Autor         : Allan Oliveira Monteiro - AOM 
Data/Hora     : 17/01/2012 - 11:08 hs
Revisao       : 
Obs.          : 
==========================================================================================*/
Function EECAF215()
Private aRotina   := MenuDef()

   If !Empty(EEQ->EEQ_FINNUM) .And. Empty(EEQ->EEQ_SEQBX)
      EasyEnvEAI("EECAF215",3)
   EndIf
   
Return .T.


Static Function MenuDef()

Local aRotina :=  {  { "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","AF215MAN" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "AF215MAN" , 0 , 3},; //"Incluir"
                     { "Alterar",   "AF215MAN" , 0 , 4},; //"Alterar"
                     { "Excluir",   "AF215MAN" , 0 , 5} } //"Excluir"                  

Return aRotina

Static Function AF215MAN()
Return Nil


/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: Allan Oliveira Monteiro 
* Data: 11/01/2012 - 15:10 hs 
* =====================================================*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("EEQ")

	oEasyIntEAI:SetModule("EEC",29)
	
	// *** Recebimento
	// *** Envio
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF215ASENB") //Envio de Business
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF215ARESR")	//Rebimento de retorno da Business Enviada
	// ***
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()

*------------------------------------------------*
Function AF215ASENB(oEasyMessage) 
*------------------------------------------------* 
Local oXml      := EXml():New()
Local oRec      := ENode():New()
Local oBank , oCont
Local oRequest  := ENode():New()
Local oBusiness := ENode():New()
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
EC6->(DbSeek(xFilial("EC6") + AvKey("EXPORT","EC6_TPMODU") + AvKey(EEQ->EEQ_EVENT,"EC6_ID_CAM")))

nEAIRecNo:= EEQ->(RecNo())

    oRequest:SetField("Operation", "EECAF215")

    oBusiness:SetField('CompanyId'       ,cEmpMsg)
    oBusiness:SetField('BranchId'        ,cFilMsg)
    oBusiness:SetField('DocumentPrefix'  ,EEQ->EEQ_PREFIX)
    oBusiness:SetField('DocumentNumber'  ,EEQ->EEQ_FINNUM) 
    oBusiness:SetField('DocumentParcel'  ,RetAsc( Val(IF(!Empty(EEQ->EEQ_PARVIN), EEQ->EEQ_PARVIN, EEQ->EEQ_PARC)),1,.T. )) //ORIGEM
    oBusiness:SetField('DocumentTypeCode',EEQ->EEQ_TPTIT)
    If !Empty(EEQ->EEQ_PGT)
       oBusiness:SetField('PaymentDate'     ,Left(FWTimeStamp(3,EEQ->EEQ_PGT ,"00:00:00"), 10))
    Else
       oBusiness:SetField('PaymentDate'     ,Left(FWTimeStamp(3,dDataBase ,"00:00:00"), 10))
    EndIf
    oBusiness:SetField('PaymentValue'  ,STR(EEQ->EEQ_VL))
    SYF->(dbSetOrder(1)) //YF_FILIAL+YF_MOEDA
    SYF->(dbSeek(xFilial()+EEQ->EEQ_MOEDA))
    If EC6->EC6_TXCV == "2" //COMPRA 
    	oBusiness:SetField('CurrencyCode'       ,SYF->YF_CODCERP)
    Else //VENDA
    	oBusiness:SetField('CurrencyCode'       ,SYF->YF_CODVERP)
    EndIf
    oBusiness:SetField('CurrencyRate'           ,EEQ->EEQ_TX     )
    oBusiness:SetField('VendorCode'             ,EEQ->EEQ_FORN   )
    oBusiness:SetField('StoreId'                ,EEQ->EEQ_FOLOJA )
    oBusiness:SetField('PaymentMethodCode'      ,"004"           )
    oBusiness:SetField('PaymentMeans'           ,"000"           )
    
    
    SA6->(DbSetOrder(1))  //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
    If SA6->(DbSeek(xFilial("SA6") + EEQ->EEQ_BANC + EEQ->EEQ_AGEN + EEQ->EEQ_NCON))
    
       oBank    := ENode():New()
       oBank:SetField("BankCode"      ,AllTrim(EEQ->EEQ_BANC))
       oBank:SetField("BankAgency"    ,AllTrim(EEQ->EEQ_AGEN) + If(!Empty(SA6->A6_DVAGE), "-" + AllTrim(SA6->A6_DVAGE), "")) 
       oBank:SetField("BankAccount"   ,AllTrim(EEQ->EEQ_NCON) + If(!Empty(SA6->A6_DVCTA), "-" + AllTrim(SA6->A6_DVCTA), ""))
       oBusiness:SetField('Bank',oBank)
       
    EndIf 
    
    oBusiness:SetField('FinancialCode'           ,EC6->EC6_NATFIN           )
    oBusiness:SetField('HistoryText'             ,""                        )
    
    oCont    := ENode():New()
    oCont:SetField("DocumentPrefix"      ,""           )
    oCont:SetField("DocumentNumber"      ,EEQ->EEQ_NROP)
    oBusiness:SetField('PaymentDocument',oCont)
       
    If EEQ->(FieldPos("EEQ_SEQBX")) > 0 
       oBusiness:SetField('DischargeSequence'   ,EEQ->EEQ_SEQBX )
    EndIf
    
	oRec:SetField('BusinessRequest',oRequest)
	oRec:SetField('BusinessContent',oBusiness) 
	
	oXml:AddRec(oRec)
    
Return oXml

/*========================================================================================
Funcao Adapter: AF215ARESR
Parametros    : "oMessage" - Objeto XML com conteúdo da tag "BusinessContent" recebida                
Objetivos     : RECEBER uma RESPONSE (apos envio de BUSINNES) e gravar arquivo 
Autor         : Allan Oliveira Monteiro - AOM
Data/Hora     : 11/01/2012 - 15:36 hs
Revisao       : 
Obs.          : 
==========================================================================================*/
*------------------------------------------------*
Function AF215ARESR(oEasyMessage) 
*------------------------------------------------* 
Local oBusinessCont  := oEasyMessage:GetRetContent()
Local aOrdEEQ := SaveOrd({"EEQ"}) 
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

RestOrd(aOrdEEQ,.T.)
Return oEasyMessage 

