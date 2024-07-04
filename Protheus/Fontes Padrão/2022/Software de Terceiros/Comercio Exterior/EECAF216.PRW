#include "average.ch"
/*========================================================================================
Funcao        : EECAF216 - Despesas Nacionais
Parametros    : nOpc              
Objetivos     : Apenas função nominal para cadastrar o adapter do fonte EECAF216
Autor         : Allan Oliveira Monteiro - AOM 
Data/Hora     : 18/01/2012 - 11:08 hs
Revisao       : 
Obs.          : 
==========================================================================================*/
Function EECAF216(nOpc)

Private aRotina   := MenuDef()

   // GFP - 08/03/2012 - Verifica se Data de Vencimento está preenchida.
   If !Empty(EET->EET_DTVENC) .OR. /*nOpc <> 3*/ ( ( nOpc == 3 .And. Empty(EET->EET_FINNUM) ) .OR. (nOpc == 5 .And. !Empty(EET->EET_FINNUM) )  )
      EasyEnvEAI("EECAF216",nOpc)
   EndIf

Return .T.


Static Function MenuDef()

Local aRotina :=  {  { "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","AF216MAN" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "AF216MAN" , 0 , 3},; //"Incluir"
                     { "Alterar",   "AF216MAN" , 0 , 4},; //"Alterar"
                     { "Excluir",   "AF216MAN" , 0 , 5} } //"Excluir"                  

Return aRotina

Static Function AF216MAN()
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
	oEasyIntEAI:oMessage:SetMainAlias("EET")

	oEasyIntEAI:SetModule("EEC",29)
	
	// *** Recebimento
	// *** Envio
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AF216ASENB") //Envio de Business
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AF216ARESR")	//Rebimento de retorno da Business Enviada
	// ***
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()

*------------------------------------------------*
Function AF216ASENB(oEasyMessage) 
*------------------------------------------------* 
Local oXml      := EXml():New()
Local oRec      := ENode():New()
Local aArray    := EECRatItEmb(EET->EET_PEDIDO,EET->EET_VALORR)
Local oCost,oDistr, oSD, oSDT 

Local oEvent    := ENode():New()
Local oIdent    := ENode():New()
Local oBusiness := ENode():New()
Local oKeyNode, oKeyNode2, oKeyNode3, oKeyNode4,oKeyNode5, oKeyNode6 , i 
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

SYB->(DbSetOrder(1))//YB_FILIAL+YB_DESP
SYB->(DbSeek(xFilial("SYB") + AvKey(EET->EET_DESPES,"YB_DESP")))
 
    oKeyNode   := ENode():New()
    oKeyNode:SetField(EAtt():New("name","DocumentPrefix"))     //PREFIXO
    oKeyNode:SetField(ETag():New("" , SYB->YB_PREFIX )) //EET->EET_PREFIX

    oKeyNode2   := ENode():New()
    oKeyNode2:SetField(EAtt():New("name","DocumentNumber"))    //NUMERO
    oKeyNode2:SetField(ETag():New("" , EET->EET_FINNUM ))
   
    oKeyNode3   := ENode():New()
    oKeyNode3:SetField(EAtt():New("name","Occurrence"))    //OCORRENCIA
    oKeyNode3:SetField(ETag():New("" ,"Q")) 
   
    oKeyNode4   := ENode():New()
    oKeyNode4:SetField(EAtt():New("name","Sequence"))  //SEQUENCIA
    oKeyNode4:SetField(ETag():New("" , EET->EET_SEQ ))
   
    oKeyNode5   := ENode():New()
    oKeyNode5:SetField(EAtt():New("name","Purchase"))  //PEDIDO
    oKeyNode5:SetField(ETag():New("" , EET->EET_PEDIDO ))
   
    oKeyNode6   := ENode():New()
    oKeyNode6:SetField(EAtt():New("name","Spending"))  //DESPESA
    oKeyNode6:SetField(ETag():New("" , EET->EET_DESPES ))

    oKeyNode2   := ENode():New()
    oKeyNode2:SetField(EAtt():New("name","BranchId")) //FILIAL
    oKeyNode2:SetField(ETag():New("" , xFIlial("EET") ))

    oIdent:SetField(ETag():New("key",oKeyNode))
    oIdent:SetField(ETag():New("key",oKeyNode2)) 
    oIdent:SetField(ETag():New("key",oKeyNode3))
    oIdent:SetField(ETag():New("key",oKeyNode4))
    oIdent:SetField(ETag():New("key",oKeyNode5))
    oIdent:SetField(ETag():New("key",oKeyNode6))
    
    oEvent:SetField("Entity", "EECAF216")
    IF Type("nEAIEvent") <> "U" .And. nEAIEvent == 5 //Exclusao
       oEvent:SetField("Event" , "delete")
    ELSE //Inclusao/Alteracao
       oEvent:SetField("Event" , "upsert")
    ENDIF
    oEvent:SetField("Identification",oIdent)

    oBusiness:SetField('CompanyId'       , cEmpMsg)
    oBusiness:SetField('BranchId'        , cFilMsg)
    oBusiness:SetField('DocumentPrefix'  , SYB->YB_PREFIX)
    oBusiness:SetField('DocumentTypeCode', SYB->YB_TPTIT ) //EET->EET_TIPTIT)
    oBusiness:SetField('DocumentNumber'  , EET->EET_FINNUM)
    oBusiness:SetField('DocumentParcel'  , RetAsc( Val(EET->EET_PARTIT),1,.T. ))
    
    oSD    := ENode():New()
    oSDT    := ENode():New()
    If EEC->(FieldPos("EEC_CODERP")) > 0 .And. !Empty(EEC->EEC_CODERP)
       oSD:SetField('SourceDocument'            ,EEC->EEC_CODERP)
    Else
       oSD:SetField('SourceDocument'            ,Substr(EET->EET_PEDIDO,1,10))  
    EndIf
  
    oSD:SetField('SourceDocumentValue',EEC->EEC_TOTPED)
    oSDT:SetField('SourceDocument'           ,oSD)
    oBusiness:SetField('ListOfSourceDocument',oSDT)
    
   
    If !Empty(EET->EET_DESADI)
       oBusiness:SetField('IssueDate'          ,Left(FWTimeStamp(3,EET->EET_DESADI ,"00:00:00"), 10))       
    EndIf
    /*
    If !Empty(EET->EET_DTVENC)
       oBusiness:SetField('DueDate'            ,Left(FWTimeStamp(3,EET->EET_DTVENC    ,"00:00:00"), 10))
    EndIf*/
    
    If !Empty(DataValida(EET->EET_DTVENC, .T.))
       oBusiness:SetField('RealDueDate'        ,Left(FWTimeStamp(3,DataValida(EET->EET_DTVENC, .T.),"00:00:00"), 10))
    EndIf
    oBusiness:SetField('VendorCode'         ,EET->EET_FORNEC                      )
    oBusiness:SetField('StoreId'            ,EET->EET_LOJAF                       ) 
    oBusiness:SetField('NetValue'           ,EET->EET_VALORR                      ) 
    oBusiness:SetField('GrossValue'         ,EET->EET_VALORR                      )
    
    SYF->(dbSetOrder(1)) //YF_FILIAL+YF_MOEDA
    SYF->(dbSeek(xFilial()+AvKey(EasyGParam("MV_SIMB1",,"R$"), "YF_MOEDA") ))
    If SYB->YB_TXCV == "2" //COMPRA 
    	oBusiness:SetField('CurrencyCode'       ,SYF->YF_CODCERP)
    Else //VENDA
    	oBusiness:SetField('CurrencyCode'       ,SYF->YF_CODVERP)
    EndIf

    oDistr    := ENode():New()
    For i := 1 To Len(aArray)
       oCost     := ENode():New()
       oCost:SetField("CostCenterCode",aArray[i][1])
       oCost:SetField("Value"         ,aArray[i][2])
       If SYB->(FieldPos("YB_NATURE")) > 0
          oCost:SetField("FinancialCode" ,SYB->YB_NATURE)
       EndIf
       oDistr:SetField('Apportionment',oCost)
    Next i
    
    If !Empty(aArray)
      oBusiness:SetField('ApportionmentDistribution',oDistr)
    EndIf
    
    oBusiness:SetField('Observation'        ,"")
    oBusiness:SetField('Origin'             ,"SIGAEEC")
    
    
	oRec:SetField('BusinessEvent'  ,oEvent)
	oRec:SetField('BusinessContent',oBusiness) 
	
	oXml:AddRec(oRec)

        
Return oXml

/*========================================================================================
Funcao Adapter: AF216ARESR
Parametros    : "oMessage" - Objeto XML com conteúdo da tag "BusinessContent" recebida                
Objetivos     : RECEBER uma RESPONSE (apos envio de BUSINNES) e gravar arquivo 
Autor         : Allan Oliveira Monteiro - AOM
Data/Hora     : 11/01/2012 - 15:36 hs
Revisao       : 
Obs.          : 
==========================================================================================*/
*------------------------------------------------*
Function AF216ARESR(oEasyMessage) 
*------------------------------------------------* 
Local oMessage := oEasyMessage:GetMsgContent()
Local oInfo    := oEasyMessage:GetMsgInfo()
Local oBusinessCont  := oEasyMessage:GetRetContent()
Local oBusinessEvent := oEasyMessage:GetEvtContent()
Local cTitFin  := ""
Local cParc := ""
Local cEvent   := "" 
Local cPedido  := ""  
Local cOcorrencia := "" 
Local cBranchId := "" 
Local cSeq := ""
Local cDespesa := "" 
Local aOrdEET := SaveOrd({"EET"}) 
Local cPrfx := ""
Local cTpCd := ""
Private lExcluiuTit := .F.

   If !(ValType(oBusinessEvent:_IDENTIFICATION:_Key) == "A")
      aKey := {oBusinessEvent:_IDENTIFICATION:_Key}
   Else
      aKey := oBusinessEvent:_IDENTIFICATION:_Key
   EndIf
   
   aEval(aKey,  {|x| If(x:_NAME:Text == "Purchase"  , cPedido := x:TEXT,      ) }) 
   aEval(aKey,  {|x| If(x:_NAME:Text == "Occurrence", cOcorrencia := x:TEXT,  ) })
   aEval(aKey,  {|x| If(x:_NAME:Text == "Sequence"  , cSeq := x:TEXT,         ) }) 
   aEval(aKey,  {|x| If(x:_NAME:Text == "Spending"  , cDespesa := x:TEXT,     ) }) 
   aEval(aKey,  {|x| If(x:_NAME:Text == "BranchId"    , cBranchId := x:TEXT,    ) }) 
   
   // cBranchId := EasyGetXMLinfo(, oBusinessCont, "_BranchId")
   cEvent := EasyGetXMLInfo(, oBusinessEvent,"_Event"   )
   cParc := EasyGetXMLinfo(, oBusinessCont, "_DocumentParcel")
   cPrfx := EasyGetXMLinfo(, oBusinessCont, "_DocumentPrefix")
   cTpCd := EasyGetXMLinfo(, oBusinessCont, "_DocumentTypeCode")
   cTitFin := EasyGetXMLinfo(, oBusinessCont, "_DocumentNumber")

   If !Empty(cParc)
      cParc := RetAsc(cParc,AvSX3("EET_PARTIT",AV_TAMANHO),.F.)
   EndIf

   EET->(DbSetOrder(1))//EET_FILIAL+EET_PEDIDO+EET_OCORRE+EET_SEQ+EET_DESPES 
   If !Empty(cPedido) .And. EET->(DbSeek( AvKey(cBranchId,"EET_FILIAL") + AvKey(cPedido,"EET_PEDIDO") + AvKey(cOcorrencia,"EET_OCORRE") + AvKey(cSeq,"EET_SEQ") + AvKey(cDespesa,"EET_DESPES") ))
      // Begin Transaction
         If  UPPER(cEvent) == "UPSERT"
            EET->(RecLock("EET",.F.))
            EET->EET_PREFIX := AvKey(cPrfx, "EET_PREFIX")
            EET->EET_TIPTIT := AvKey(cTpCd, "EET_TIPTIT")
            EET->EET_FINNUM := AvKey(cTitFin,"EET_FINNUM")
            EET->EET_PARTIT := AvKey(cParc,"EET_PARTIT")
            EET->(MsUnlock())
         Else
            EET->EET_FINNUM := ""
            EET->EET_PARTIT := ""
         EndIf
      // End Transaction 
      
      oEasyMessage:AddInList("RECEIVE", {"Sucesso" , "Registro Gravado no Destino" , Nil})
   Else
      oEasyMessage:AddInList("RECEIVE", {"Erro" , "Parcela não encontrada no Destino" , Nil})
   EndIf

RestOrd(aOrdEET,.T.)
Return oEasyMessage 

