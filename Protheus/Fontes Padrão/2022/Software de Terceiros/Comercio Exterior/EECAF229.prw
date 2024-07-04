#Include 'average.ch'

/*========================================================================================
Funcao        : EECAF229 - Estorno da baixa das despesas do contrato
Parametros    : -              
Objetivos     : Apenas função nominal para cadastrar o adapter do fonte EECAF229
Autor         : Felipe Sales Martinez - FSM
Data/Hora     : 23/01/2012 - 12:21 hs
Revisao       : 
Obs.          : 
==========================================================================================*/

Function EECAF229()

Private aRotina   := MenuDef()  

   If !Empty(EF3->EF3_TITFIN) .And. !Empty(EF3->EF3_SEQBX)
         
      EasyEnvEAI("EECAF229",5)  
      
   EndIf 
   
Return .T.


Static Function MenuDef()

Local aRotina :=  {  { "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","AF229MAN" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "AF229MAN" , 0 , 3},; //"Incluir"
                     { "Alterar",   "AF229MAN" , 0 , 4},; //"Alterar"
                     { "Excluir",   "AF229MAN" , 0 , 5} } //"Excluir"                  

Return aRotina

Static Function AF229MAN()
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
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF229ASENB") //Envio de Business
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF229ARESR")	//Rebimento de retorno da Business Enviada
	// ***
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()


/*========================================================================================
Funcao Adapter: AF229ASENB
Parametros    : "oMessage" - Objeto XML com conteúdo da tag "BusinessContent" recebida                
Objetivos     : 
Autor         : Felipe Sales Martinez - FSM
Data/Hora     : 23/01/2012 - 15:30 hs
Revisao       : 
Obs.          : 
==========================================================================================*/
*------------------------------------------------*
Function AF229ASENB(oEasyMessage) 
*------------------------------------------------* 
Local oXml      := EXml():New()
Local oRec      := ENode():New()
Local oRequest  := ENode():New()
Local oBusiness := ENode():New()
Local cInfo := ""
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
   oRequest:SetField("Operation", "EECAF229")
   
   
   /* BusinessContent */
   
   oBusiness:SetField('CompanyId'       ,cEmpMsg)
   oBusiness:SetField('BranchId'        ,cFilMsg)
   
   oBusiness:SetField("DocumentPrefix"  , EF3->EF3_PREFIX)
   oBusiness:SetField("DocumentNumber"  , EF3->EF3_TITFIN)
   oBusiness:SetField("DocumentParcel"  , RetAsc( Val(EF3->EF3_PARC),1,.T. ))
   oBusiness:SetField("DocumentTypeCode", EF3->EF3_TPTIT)

   If !Empty(EF3->EF3_FORN)
       cInfo := EF3->EF3_FORN
   Else
       cInfo := SA6->A6_CODFOR  
   EndIf
   oBusiness:SetField("VendorCode", cInfo)

   If !Empty(EF3->EF3_LOJAFO)
      cInfo := EF3->EF3_LOJAFO
   Else
      cInfo := SA6->A6_LOJFOR
   EndIf   
   oBusiness:SetField("StoreId", cInfo)

   oBusiness:SetField("DischargeSequence", EF3->EF3_SEQBX)

   oRec:SetField("BusinessRequest", oRequest)
   oRec:SetField("BusinessContent", oBusiness) 
   oXml:AddRec(oRec)
   
   If IsInCallStack("EasyEAIBuffer") 
      //Tratamento para não perder seq. de baixa dos títulos caso ocorre falha na integração
      If EF3->(Deleted())
         If Type('lRecall') == 'L'
	        lRecall := .T.
	     EndIf  
         EF3->(RecLock("EF3",.F.))
         EF3->(dbRecall())
         EF3->(MsUnLock())
      EndIf
   EndIf
	
RestOrd(aOrdEF3,.T.)

Return oXml

/*========================================================================================
Funcao Adapter: AF229ARESR
Parametros    : "oMessage" - Objeto XML com conteúdo da tag "BusinessContent" recebida                
Objetivos     : RECEBER uma RESPONSE (apos envio de BUSINNES) e gravar arquivo 
Autor         : Felipe Sales Martinez - FSM
Data/Hora     : 01/02/2012 - 12:16 hs
Revisao       : 
Obs.          : 
==========================================================================================*/
*------------------------------------------------*
Function AF229ARESR(oEasyMessage) 
*------------------------------------------------* 
Local oBusinessCont  := oEasyMessage:GetBsnContent()
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
          AvKey(cTitulo,"EF3_TITFIN") + AvKey(cParc,"EF3_PARC"))) ;
   .Or. ;
   EF3->(DbSeek( xFilial("EF3") + AvKey(cPrefixo,"EF3_PREFIX") + AvKey(cTipo,"EF3_TPTIT") +;
          AvKey(cTitulo,"EF3_TITFIN") + AvKey("","EF3_PARC")))  
          
   Begin Transaction

       If EF3->(RecLock("EF3",.F.))
          EF3->EF3_SEQBX := ""
          If IsInCallStack("EasyEAIBuffer")
             //Tratamento para não perder seq. de baixa dos títulos caso ocorre falha na integração
             If !EF3->(Deleted()) .AND. lRecall
                EF3->(dbDelete())
			    lRecall := .F.
             EndIf
          EndIf
          EF3->(MsUnlock())
       EndIf

   End Transaction

EndIf

RestOrd(aOrdEF3,.T.)

Return oEasyMessage 
