#Include 'Protheus.ch'


/* ====================================================*
* Função: EECAF223
* Parametros: nOpc
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: Felipe Sales Martinez 
* Data:  
* =====================================================*/
Function EECAF223(nOpc)
Local aNotas := {}
Local cDtEmb := ""
Local nCont := 0
Local cNotaInt := ""
//Private cNotaInt  := ""
//Private cSerieInt := ""
//Private cDataInt  := ""
Private nEventInt := nOpc

//Funcao utilizada apenas para cadastrar o PRW no Adapter:
Private aRotina   := MenuDef()

EE9->(DbSetOrder(3))
EE9->(DbSeek(xFilial()+EEC->EEC_PREEMB))
Do While EE9->( !EOF() ) .And. EE9->( xFilial("EE9") == EE9_FILIAL ) .And. EE9->EE9_PREEMB == EEC->EEC_PREEMB
    
    cDtEmb :=  AllTrim( EasyTimeStamp( EEC->EEC_DTEMBA, .T., .T. ) ) 

    If aScan(aNotas,{|X| X[1] == AllTrim(EE9->EE9_NF) .And. X[2] == AllTrim(EE9->EE9_SERIE) }) == 0
       aAdd(aNotas, { AllTrim(EE9->EE9_NF), AllTrim(EE9->EE9_SERIE), cDtEmb , EE9->(Recno())} )
    EndIf
    
    EE9->( DBSkip())
    
EndDo

For nCont := 1 To Len(aNotas)

    cNotaInt   := aNotas[nCont][1]
    //cSerieInt := aNotas[nCont][2]
    //cDataInt   := aNotas[nCont][3] 
    EE9->(DbGoTo(aNotas[nCont][4]))
    If !Empty(cNotaInt)
       EasyEnvEAI("EECAF223",nEventInt)
    EndIf

Next nCont

Return .T.

/* ====================================================*
* Função: MenuDef
* Parametros: 
* Objetivo: 
* Obs: 
* Autor: Felipe Sales Martinez 
* Data:  
* =====================================================*/
Static Function MenuDef()

Local aRotina :=  {  { "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","AF223MAN" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "AF223MAN" , 0 , 3},; //"Incluir"
                     { "Alterar",   "AF223MAN" , 0 , 4},; //"Alterar"
                     { "Excluir",   "AF223MAN" , 0 , 5} } //"Excluir"                  

Return aRotina

Static Function AF223MAN()

Return Nil


/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: Felipe Sales Martinez
* Data: 
* =====================================================*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI
/*
  Variavei privadas da funcao EECAF223:
  cNotaInt / cSerieInt / cDataInt
*/

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("EEC")
	oEasyIntEAI:SetModule("EEC",29) 
	
		
	// *** Envio
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF223ASENB") //ENVIO DE BUSINESS MESSAGE           (<-Business)
	// ***
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()


/* ====================================================*
* Função: AF223ASENB
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: Felipe Sales Martinez
* Data: 
* =====================================================*/
Function AF223ASENB(oEasyMessage) 
Local oXml      := EXml():New()
Local oBusiness := ENode():New()
Local oEvent    := ENode():New()
Local oIdent    := ENode():New()
Local oRec      := ENode():New()
Local oKeyNode
Local aOrd := SaveOrd({"EEC"}) 
Local cEmp := ""

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","CompanyId"))
   oKeyNode:SetField(ETag():New("" ,SM0->M0_CODIGO))
   oIdent:SetField(ETag():New("key",oKeyNode))
   
   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","BranchId"))
   oKeyNode:SetField(ETag():New("" ,AvGetM0Fil()))
   oIdent:SetField(ETag():New("key",oKeyNode))
   
   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","InvoiceNumber"))
//   oKeyNode:SetField(ETag():New("" , cNotaInt)) 
   oKeyNode:SetField(ETag():New("" , EE9->EE9_NF  )) 
   oIdent:SetField(ETag():New("key",oKeyNode))
      
   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","InvoiceSerie"))
//   oKeyNode:SetField(ETag():New("" ,cSerieInt))
   oKeyNode:SetField(ETag():New("" ,EE9->EE9_SERIE))
   oIdent:SetField(ETag():New("key",oKeyNode)) 

   oEvent:SetField("Entity", "EECAF223")
 
   // BAK - Alteracao da variavel para nEAIEvent - 22_06_2012
   //If Type("nEventInt") <> "U" .And. nEventInt == 5 //Exclusao
   //   oEvent:SetField("Event" , "delete")
   //Else //Inclusao/Alteracao
   //   oEvent:SetField("Event" , "upsert")
   //EndIf 
   
   If Type("nEAIEvent") <> "U"  
      If nEAIEvent == 3
         oEvent:SetField("Event" ,"upsert" )
      ElseIf nEAIEvent == 5
         oEvent:SetField("Event" ,"delete" )
      EndIf
   Else
      oEvent:SetField("Event" , "error")
   EndIf
   oEvent:SetField("Identification",oIdent)
   
   cEmp := EasyMasEmp(EE9->EE9_PEDIDO)
   oBusiness:SetField("CompanyId" , cEmp)
   oBusiness:SetField("BranchId"  , AvGetM0Fil())

//   oBusiness:SetField("BranchId"  , AvGetM0Fil())
//   oBusiness:SetField("InvoiceNumber", cNotaInt )
   oBusiness:SetField("InvoiceNumber", EE9->EE9_NF )
//   oBusiness:SetField("InvoiceSerie", cSerieInt )
   oBusiness:SetField("InvoiceSerie", EE9->EE9_SERIE)
//   If !Empty(cDataInt)
//      oBusiness:SetField("ShipmentDate", cDataInt )
//   EndIf
   If !Empty(EEC->EEC_DTEMBA)
      oBusiness:SetField("ShipmentDate", AllTrim( EasyTimeStamp( EEC->EEC_DTEMBA, .T., .T. ) ) )
   Else
      oBusiness:SetField("ShipmentDate", "0000-00-00"  ) //Tratamento para retornar somente "AAAA-MM-DD"
   EndIf
     
   oRec:SetField("BusinessEvent"  ,oEvent)
   oRec:SetField("BusinessContent",oBusiness) 
   oXml:AddRec(oRec)

   RestOrd(aOrd,.T.)

Return oXml

Static Function EasyMasEmp(cInfo)
Local cEmp   := ""
Local cParam := AllTrim(Upper(EasyGParam("MV_EEC0009",,""))) 
Local cSeparador := ""
Local nPos := 0

If EasyGParam("MV_EEC0009",.T.) .And. !(cParam == "#EE7_PEDIDO#")
   cSeparador := StrTran(cParam,"#EE7_PEDIDO#","")
   cSeparador := AllTrim(Upper(StrTran(cSeparador,"#EE7_FORN#","")))
   If !Empty(cSeparador) .And. (nPos := At(cSeparador,cInfo)) > 0
      // "#EE7_PEDIDO# - #EE7_FORN#"
      If At("#EE7_PEDIDO#",cParam) < At("#EE7_FORN#",cParam)
         cEmp := AllTrim(SubStr(cInfo,nPos+1,Len(cInfo)))
      // #EE7_FORN#" - "#EE7_PEDIDO#
      Else
         cEmp := AllTrim(SubStr(cInfo,1,nPos-1))
      EndIf
   Else
      // "#EE7_PEDIDO##EE7_FORN#"
      If At("#EE7_PEDIDO#",cParam) < At("#EE7_FORN#",cParam)
         cEmp := AllTrim(SubStr(cInfo,6+1,Len(cInfo)))
      // #EE7_FORN#""#EE7_PEDIDO#
      Else
         cEmp := AllTrim(SubStr(cInfo,1,2))
      EndIf
   EndIf
Else
   cEmp := SM0->M0_CODIGO
EndIf

Return cEmp