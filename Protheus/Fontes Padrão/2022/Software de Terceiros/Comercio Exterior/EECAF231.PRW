#include "average.ch"
/*========================================================================================
Funcao        : EECAF231 - Baixa de Título a Receber com valor de comissão a deduzir
Parametros    : 
Objetivos     : 
Autor         : 
Data/Hora     : 
Revisao       : 
Obs.          : 
==========================================================================================*/
Function EECAF231(nOpc)

   If nOpc <> 5 .OR. Empty(EEQ->EEQ_SEQBX) //Em caso de alteração, a sequencia de baixa será estornada.
      EasyEnvEAI("EECAF231",nOpc,.T.) 
   EndIf

Return .T.


Static Function MenuDef()

Local aRotina :=  {  { "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","AF231MAN" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "AF231MAN" , 0 , 3},; //"Incluir"
                     { "Alterar",   "AF231MAN" , 0 , 4},; //"Alterar"
                     { "Excluir",   "AF231MAN" , 0 , 5} } //"Excluir"                  

Return aRotina

Static Function AF231MAN()
Return Nil


Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("EEQ")

	oEasyIntEAI:SetModule("EEC",29)
	
	// *** Recebimento
	// *** Envio
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF231ASENB") //Envio de Business
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF231ARESR")	//Rebimento de retorno da Business Enviada
	// ***
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()

*-------------------------------*
Function AF231ASENB(oEasyMessage)
*-------------------------------*
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
Local cPortBx   := ""
Local cTpPortBx := "" 
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

   oRequest:SetField("Operation", "EECAF231")

    
   oBusiness:SetField('CompanyId'     ,cEmpMsg)
   oBusiness:SetField('BranchId'      ,cFilMsg)
   oBusiness:SetField('DocumentPrefix',EEQ->EEQ_PREFIX)
   oBusiness:SetField('DocumentNumber',EEQ->EEQ_FINNUM)
   oBusiness:SetField('DocumentParcel',RetAsc( Val(IF(!Empty(EEQ->EEQ_PARVIN), EEQ->EEQ_PARVIN, EEQ->EEQ_PARC)),1,.T. ) )
   oBusiness:SetField('DocumentTypeCode',EEQ->EEQ_TPTIT)

   oBusiness:SetField('PaymentDate',EasyTimeStamp(EEC->EEC_DTEMBA, .T., .T.))
   oBusiness:SetField('CreditDate',EasyTimeStamp(EEC->EEC_DTEMBA, .T., .T.))
   oBusiness:SetField('EntryDate',EasyTimeStamp(dDataBase, .T. , .T.))

   oBusiness:SetField('PaymentValue',Str(EEQ->EEQ_VL))
   //oBusiness:SetField('PaymentValue',Str(EEQ->EEQ_ADEDUZ+EEQ->EEQ_CGRAFI))

    SYF->(dbSetOrder(1))  //YF_FILIAL+YF_MOEDA
    SYF->(dbSeek(xFilial()+EEQ->EEQ_MOEDA))
    If EC6->EC6_TXCV == "2" //COMPRA 
    	oBusiness:SetField('CurrencyCode'       ,SYF->YF_CODCERP)
    Else //VENDA
    	oBusiness:SetField('CurrencyCode'       ,SYF->YF_CODVERP)
    EndIf
   
   oBusiness:SetField('CurrencyRate',STR(BuscaTaxa(EEQ->EEQ_MOEDA,EEC->EEC_DTEMBA,,.F.,,,EC6->EC6_TXCV)))

   oBusiness:SetField('CustomerCode',EEQ->EEQ_IMPORT)

   oBusiness:SetField('StoreId',EEQ->EEQ_IMLOJA)
   oBusiness:SetField('PaymentMethod',"006")
   oBusiness:SetField('PaymentMeans',"000")
   
   //NCF - 16/06/2016 - Flexibilizar busca do portador para baixa de comissão
   cPortBx   := EasyHolderCode(EEQ->EEQ_BANC ,EEQ->EEQ_AGEN,EEQ->EEQ_NCON ,EEQ->EEQ_BANC ,EEQ->EEQ_AGEN,EEQ->EEQ_NCON,"EXPORT",EEQ->EEQ_EVENT,EEQ->EEQ_IMPORT,EEQ->EEQ_IMLOJA,EEQ->EEQ_FORN,EEQ->EEQ_FOLOJA)
   cTpPortBx := EasyTypeHolder(EEQ->EEQ_BANC ,EEQ->EEQ_AGEN,EEQ->EEQ_NCON ,EEQ->EEQ_BANC ,EEQ->EEQ_AGEN,EEQ->EEQ_NCON,"EXPORT",EEQ->EEQ_EVENT,EEQ->EEQ_IMPORT,EEQ->EEQ_IMLOJA,EEQ->EEQ_FORN,EEQ->EEQ_FOLOJA)
   
   If Empty(cPortBx) .Or. Empty(cTpPortBx)
      cPortBx   := Alltrim(EasyGParam("MV_EEC0028",,""))
      cTpPortBx := Alltrim(EasyGParam("MV_EEC0029",,""))
   EndIf

   oBusiness:SetField('HolderCode',Alltrim(EasyGParam("MV_EEC0028",,"")))
   oBusiness:SetField('HolderType',Alltrim(EasyGParam("MV_EEC0029",,""))) // "B"

   oBusiness:SetField('FinancialCode',EC6->EC6_NATFIN)
   
   oListOfDepositData := ENode():New()
      oDepositData := ENode():New()
         oDepositData:SetField('DepositDate',EasyTimeStamp(EEC->EEC_DTEMBA, .T., .T.))
         oDepositData:SetField('DepositValue',Str(EEQ->EEQ_VL))//AOM - 26/01/2012
      oListOfDepositData:SetField("DepositData",oDepositData)   
   oBusiness:SetField("ListOfDepositData",oListOfDepositData)

   oBusiness:SetField("DischargeSequence",EEQ->EEQ_SEQBX)

   oRec:SetField('BusinessRequest',oRequest)
   oRec:SetField('BusinessContent',oBusiness) 
   
   oXml:AddRec(oRec)
   RestOrd(aOrd,.T.)
   
Return oXml

*-------------------------------------------------*
Function AF231ARESR(oEasyMessage) 
*-------------------------------------------------*
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

