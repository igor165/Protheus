#Include 'average.ch'
/*
Funcao     : EECAF230()
Parametros : Nenhum
Retorno    : .T
Objetivos  : Estorno da compensação do adiantamento
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 10/01/2012
*/

Function EECAF230()  
Local lRet := .T.
Private aRotina   := MenuDef()   

   If !Empty(EEQ->EEQ_FINNUM) .And. !Empty(EEQ->EEQ_SEQBX)
      If EEQ->EEQ_EVENT == "603"//THTS - 28/03/2018 - Adiantamento Pos-Embarque
         lRet := EasyEnvEAI("EECAF230",3)
      Else      
         lRet := EasyEnvEAI("EECAF230",3,.T.)
      EndIf
   EndIf   
   
Return lRet


Static Function MenuDef()

Local aRotina :=  {  { "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","AF230Man" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "AF230Man" , 0 , 3},; //"Incluir"
                     { "Alterar",   "AF230Man" , 0 , 4},; //"Alterar"
                     { "Excluir",   "AF230Man" , 0 , 5,3} } //"Excluir"
                   

Return aRotina  

Function AF230Man(cAlias,nReg,nOpc)

Return Nil

Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI
	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("EEQ")
	oEasyIntEAI:SetModule("EEC",29) 
		
	//*** Envio
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF230ASENB") //ENVIO DE BUSINESS MESSAGE           (<-Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF230ARESR") //RESPOSTA SOBRE O ENVIO DA BUSINESS  (->Response)
	//***
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()


Function AF230ASENB(oEasyMessage) 
Local oXml      := EXml():New()
Local oBusiness := ENode():New()
Local oRequest  := ENode():New()
Local oRec      := ENode():New()
Local aOrd := SaveOrd({"EC6"})
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

   oRequest:SetField("Operation", "EECAF230")

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
   oBusiness:SetField('DocumentParcel',RetAsc( Val(EEQ->EEQ_PARC), 1 ,.T. ) )
   //   <DocumentTypeCode></DocumentTypeCode> - Tipo do Título
   oBusiness:SetField('DocumentTypeCode',EEQ->EEQ_TPTIT)
   //   <DischargeSequence></DischargeSequence> - Sequencia da Baixa
   oBusiness:SetField("DischargeSequence",EEQ->EEQ_SEQBX)

   //</BusinessContent>
   oRec:SetField('BusinessRequest',oRequest)
   oRec:SetField('BusinessContent',oBusiness) 
   oXml:AddRec(oRec)
   RestOrd(aOrd,.T.)
   
Return oXml

*-------------------------------------------------*
Function AF230ARESR(oEasyMessage) 
*-------------------------------------------------*
Local oMessage := oEasyMessage:GetBsnContent()
Local aOrd := SaveOrd({"EEQ"}) 
Local cParcela := EasyGetXMLinfo(, oMessage, "_DocumentParcel")
Local lSeek:= .F.

   If !Empty(cParcela)
      cParcela := RetAsc(cParcela,AvSX3("EEQ_PARC",AV_TAMANHO),.F.)
   EndIf

   If Type("nEAIRecNo") == "N" //declarada na função EasyEAIBuffer()
      EEQ->(DBGoTo(nEAIRecNo))
      lSeek:= .T.
   Else
      EEQ->(DbSetOrder(12)) //EEQ_FILIAL+EEQ_PREFIX+EEQ_TPTIT+EEQ_FINNUM+EEQ_PARC
      lSeek:= EEQ->(DbSeek(xFilial("EEQ") + AvKey(EasyGetXMLinfo(, oMessage, "_DocumentPrefix"),"EEQ_PREFIX") +;
                                        AvKey(EasyGetXMLinfo(, oMessage, "_DocumentTypeCode"),"EEQ_TPTIT") +;
                                        AvKey(EasyGetXMLinfo(, oMessage, "_DocumentNumber"),"EEQ_FINNUM") +;
                                        AvKey(cParcela,"EEQ_PARC")))
   EndIf
   If lSeek
      //Begin Transaction
      EEQ->(RecLock("EEQ",.F.)) 
      EEQ->EEQ_SEQBX := ""
      EEQ->(MsUnlock())
      
      If !EEQ->EEQ_EVENT == "603" //THTS - 29/03/2018 - Executa somente quando NÃO for compensacao pos-embarque
         AvStAction("007") // Estorno do titulo a receber
      EndIf

      //End Transaction
   EndIf
   RestOrd(aOrd,.T.)

Return oEasyMessage
