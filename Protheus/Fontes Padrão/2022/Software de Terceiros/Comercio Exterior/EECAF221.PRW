#include "average.ch"
/*
Funcao     : EECAF221()
Parametros : Nenhum
Retorno    : .T
Objetivos  : -
Autor      : Allan Oliveira Monteiro - Estorno da Baixa a Receber
Data/Hora  : 01/02/2012
*/

Function EECAF221(nOpc)  
Private aRotina   := MenuDef()

   If !Empty(EEQ->EEQ_FINNUM) .And. !Empty(EEQ->EEQ_SEQBX)
      EasyEnvEAI("EECAF221",nOpc) 
   EndIf

Return .T.


Static Function MenuDef()

Local aRotina :=  {  { "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","AF221Man" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "AF221Man" , 0 , 3},; //"Incluir"
                     { "Alterar",   "AF221Man" , 0 , 4},; //"Alterar"
                     { "Excluir",   "AF221Man" , 0 , 5,3} } //"Excluir"
                   

Return aRotina  

Function AF221Man(cAlias,nReg,nOpc)

Return Nil

Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI
	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("EEQ")
	oEasyIntEAI:SetModule("EEC",29) 
		

	//*** Envio
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF221ASENB") //ENVIO DE BUSINESS MESSAGE           (<-Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF221ARESR") //RESPOSTA SOBRE O ENVIO DA BUSINESS  (->Response)
	//***
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()


Function AF221ASENB(oEasyMessage) 
Local oXml      := EXml():New()
Local oBusiness := ENode():New()
Local oRequest  := ENode():New()
Local oRec      := ENode():New()
Local aOrd := SaveOrd({"EC6"})
Local cEmpMsg := SM0->M0_CODIGO
Local cFilMsg := AvGetM0Fil() 
Local cParam, nPosDiv

nEAIRecNo:= EEQ->(RecNo()) //declarada na função EasyEAIBuffer()

If !Empty( cParam := Alltrim(EasyGParam("MV_EEC0033",,"")) )
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

   oRequest:SetField("Operation", "EECAF221")
    
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
   oBusiness:SetField('DocumentParcel',RetAsc( Val(IF(!Empty(EEQ->EEQ_PARVIN), EEQ->EEQ_PARVIN, EEQ->EEQ_PARC)),1,.T. ) )
   //   <DocumentTypeCode></DocumentTypeCode> - Tipo do Título
   oBusiness:SetField('DocumentTypeCode',EEQ->EEQ_TPTIT)

   //   <DischargeSequence></DischargeSequence> - Sequência da Baixa. Utilizado para estornar a baixa.
   oBusiness:SetField("DischargeSequence",EEQ->EEQ_SEQBX)

   //</BusinessContent>
   oRec:SetField('BusinessRequest',oRequest)
   oRec:SetField('BusinessContent',oBusiness) 
   oXml:AddRec(oRec) 
   
   If IsInCallStack("EasyEAIBuffer")                                       
      //Tratamento para não perder seq. de baixa dos títulos caso ocorra falha na integração
      If EEQ->(Deleted())
         If Type('lRecall') == 'L'
            lRecall := .T.
         EndIf  
         EEQ->(RecLock("EEQ",.F.))
         EEQ->(dbRecall())
         EEQ->(MsUnLock())
      EndIf
   EndIf
   
   RestOrd(aOrd,.T.)
   
Return oXml

*-------------------------------------------------*
Function AF221ARESR(oEasyMessage) 
*-------------------------------------------------*
Local oBusinessCont  := oEasyMessage:GetBsnContent()
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
            EEQ->EEQ_SEQBX := ""
            If IsInCallStack("EasyEAIBuffer")
               //Tratamento para não perder seq. de baixa de títulos caso ocorra falha na integração
               If !EEQ->(Deleted()) .AND. lRecall
                  EEQ->(dbDelete())
			      lRecall := .F.
               EndIf
            EndIf
            EEQ->(MsUnlock())
         EndIf 
      End Transaction
      oEasyMessage:AddInList("RECEIVE", {"Sucesso" , "Registro Gravado no Destino" , Nil})
   
   EndIf
   
RestOrd(aOrd,.T.)

Return oEasyMessage
