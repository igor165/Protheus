#INCLUDE "PROTHEUS.CH"
#include "average.ch"
/*
Programa : EICQC410.PRW
Autor    : Igor Chiba (Average)
Data     : 03/06/14
Revisao  : 
Uso      : Envio e retorno de cotações
*/
*--------------------------------------------------------------------
Function EICQC410(lEnvio,oObj,aCab)
*--------------------------------------------------------------------
LOCAL cUnReq   := "99999" // Unidade Requisitante Padrão
LOCAL lRet     :=.T.
LOCAL nI,nJ, nPos
DEFAULT lEnvio :=.F.
IF lEnvio  //CHAMANDO DE OUTROS FONTES SÓ FAZER ENVIO SE FOR INCLUSAO , ALTERACAO OU EXCLUSAO
   oModel := oObj
   nOpc   := oModel:GetOperation()
   
   IF STR(nOpc,1) $ ('345')
      IF nOpc == 5 //EXCLUSAO
         
         oModelSWS  := oModel:GetModel( 'SWSDETAIL' )//MODEL ITEM 
         oModelSWT  := oModel:GetModel( 'SWTDETAIL' )//MODEL COTACAO
         aItemDel   := {} //array com itens que possuem cotacoes a serem deletadas
         aDelet     := {} //cotacoes a serem deletadas    
         ASWS       := {}
         ASWT       := {}
         //FOR DE ITEM 
         For nI:=1 to oModelSWS:Length()//ALTERACAO NAO PRECISA TESTAR SE TA DELETADO POIS PRECISA ENVIAR DELETADOS
            oModelSWS:GoLine( nI )
         
            //FOR DE COTACOES
            For nJ:=1 to oModelSWT:Length()
               oModelSWT:GoLine( nJ )
               IF oModelSWT:GetValue('WT_COD_I')+oModelSWT:GetValue('WT_SI_NUM')+oModelSWT:GetValue('WT__CC') <> oModelSWS:GetValue('WS_COD_I')+oModelSWS:GetValue('WS_SI_NUM')+oModelSWS:GetValue('WS__CC')
                  LOOP
               ENDIF
               
               IF !EMPTY( oModelSWT:GetValue('WT_NUMERP'))
			      If (nPos := aScan(aDelet,{|X| X[1] == nI})) == 0
				     AADD(aDelet,{nI,{}})
					 nPos := Len(aDelet)
				  EndIf
                  AADD(aDelet[nPos][2],nJ)    //DELET DA COTACAO
               ENDIF
          
            NEXT
        NEXT
        
         IF len(aDelet) <> 0
            ASWT := aDelet
            lRet := EasyEnvEAI("EICQC410",5)    
         ENDIF                          
      
      ELSEIF nOpc == 4 //ALTERACAO
         oModelSWS  := oModel:GetModel( 'SWSDETAIL' )//MODEL ITEM 
         oModelSWT  := oModel:GetModel( 'SWTDETAIL' )//MODEL COTACAO
         aItemDel   := {} //array com itens que possuem cotacoes a serem deletadas
         aItemUps   := {} //array com itens que possuem cotacoes a serem upsert
         aDelet     := {} //cotacoes a serem deletadas    
         aUpSert    := {} //cotacoes a serem upsert  
         ASWS       := {}
         ASWT       := {}
         //FOR DE ITEM 
         For nI:=1 to oModelSWS:Length()//ALTERACAO NAO PRECISA TESTAR SE TA DELETADO POIS PRECISA ENVIAR DELETADOS
            oModelSWS:GoLine( nI )
         
            //FOR DE COTACOES
            For nJ:=1 to oModelSWT:Length()
               oModelSWT:GoLine( nJ )
			   
               IF oModelSWT:GetValue('WT_COD_I')+oModelSWT:GetValue('WT_SI_NUM')+oModelSWT:GetValue('WT__CC') <> oModelSWS:GetValue('WS_COD_I')+oModelSWS:GetValue('WS_SI_NUM')+oModelSWS:GetValue('WS__CC')
                  LOOP
               ENDIF
               
               IF oModelSWT:ISDELETED()  .AND. !EMPTY( oModelSWT:GetValue('WT_NUMERP'))
			      If (nPos := aScan(aDelet,{|X| X[1] == nI})) == 0
				     AADD(aDelet,{nI,{}})
					 nPos := Len(aDelet)
				  EndIf
                  AADD(aDelet[nPos][2],nJ)    //DELET DA COTACAO
               ELSEIF !oModelSWT:ISDELETED() .AND.  (oModelSWT:GetValue('WT_STATUS') == '2' .OR. oModelSWT:GetValue('WT_STATUS') == '3')//SE 
                  IF Empty(oModelSWT:GetValue("WT_ID"))
                     oModelSWT:SetValue("WT_ID",MontaId())
                  ENDIF
				  
			      If (nPos := aScan(aUpSert,{|X| X[1] == nI})) == 0
				     AADD(aUpSert,{nI,{}})
					 nPos := Len(aUpSert)
				  EndIf
                  AADD(aUpSert[nPos][2],nJ)    //DELET DA COTACAO
               ENDIF
          
            NEXT
        NEXT
        
         IF len(aDelet) <> 0
            ASWT := aDelet
            lRet := EasyEnvEAI("EICQC410",5)    
         ENDIF                          
         
         IF lRet //se deu erro na exclusao nao mandar upsert
            ASWT := aUpSert
            IF LEN(aUpSert) <> 0 
               lRet :=EasyEnvEAI("EICQC410",4)
            ENDIF    
         ENDIF
         
      ELSE //INCLUSAO 
         oModelSWS  := oModel:GetModel( 'SWSDETAIL' )//MODEL ITEM 
         oModelSWT  := oModel:GetModel( 'SWTDETAIL' )//MODEL COTACAO
         aItemUps   := {} //array com itens que possuem cotacoes a serem upsert
         aUpSert    := {} //cotacoes a serem upsert  
         ASWS       := {}
         ASWT       := {}
        
         //FOR DE ITEM 
         For nI:=1 to oModelSWS:Length()
            oModelSWS:GoLine( nI )
            IF oModelSWS:ISDELETED()
               LOOP
            ENDIF
            //FOR DE COTACOES
            For nJ:=1 to oModelSWT:Length()
               oModelSWT:GoLine( nJ )
               IF oModelSWT:GetValue('WT_COD_I')+oModelSWT:GetValue('WT_SI_NUM')+oModelSWT:GetValue('WT__CC') <> oModelSWS:GetValue('WS_COD_I')+oModelSWS:GetValue('WS_SI_NUM')+oModelSWS:GetValue('WS__CC')
                  LOOP
               ENDIF
               
               IF !oModelSWT:ISDELETED() .AND.  (oModelSWT:GetValue('WT_STATUS') == '2' .OR. oModelSWT:GetValue('WT_STATUS') == '3')//SE 
                  IF Empty(oModelSWT:GetValue("WT_ID"))
                     oModelSWT:SetValue("WT_ID",MontaId())
                  ENDIF
				  
			      If (nPos := aScan(aUpSert,{|X| X[1] == nI})) == 0
				     AADD(aUpSert,{nI,{}})
					 nPos := Len(aUpSert)
				  EndIf
                  AADD(aUpSert[nPos][2],nJ)    //DELET DA COTACAO
               ENDIF
            NEXT
         NEXT
        
         ASWT := aUpSert
         IF LEN(aUpSert) <> 0 
            lret:=EasyEnvEAI("EICQC410",3)  
         ENDIF    
      ENDIF
   
   ENDIF
   
   RETURN lRet   
   
ELSE//RECEBIMENTO DA COTACAO VENCEDORA
   
   IF (ValType(aCab) == "U" .or. (len(aCab) == 0))
      EasyHelp("Dados PO não informados","Atenção")
      RETURN .F.
   ENDIF     
   
   IF (nPos := ascan(aCab,{|x| AllTrim(x[1]) == "WT_NUMERP"})) <> 0 .AND.;
      (nPos1:= ascan(aCab,{|x| AllTrim(x[1]) == "WT_FORN"})) <> 0 .AND.;
      (nPos2:= ascan(aCab,{|x| AllTrim(x[1]) == "WT_COD_I"})) <> 0   
      
      cNumERP := aCab[nPos][2]
      cForn   := aCab[nPos1][2]
      cCodI   := aCab[nPos2][2]
      IF EMPTY(cNumERP) .OR. EMPTY(cForn) .OR. EMPTY(cCodI) 
         EasyHelp("Num ERP não informado","Atenção")
         RETURN .F.                               
      ELSE
        SWT->(DBSETORDER(5)) 
        IF SWT->(DBSEEK(xFilial("SWT")+AVKEY(cCodI,'WT_COD_I')+AVKEY(cForn,'WT_FORN')+AVKEY(".",'WT_FORLOJ')+AVKEY(cNumErp,'WT_NUMERP')))  
           SWT->(MSUNLOCK())
           SWT->(RECLOCK('SWT',.F.)) 
           SWT->WT_STATUS := '3'//APROVADA
           SWT->(MSUNLOCK())
           
		   //reprovando todas que nao foram aprovada 
		   RejeitaSWT(SWT->WT_SI_NUM,SWT->WT_COD_I,ALLTRIM(STR(SWT->WT_REG)),SWT->WT_NUMERP,'4')
		   
           //ATUALIZANDO A SW1
		   SW1->(DBSETORDER(1))                     
           IF SW1->(DBSEEK(xFilial("SW1")+AvKey(cUnReq,"W1_CC")+AvKey(SWT->WT_SI_NUM,"W1_SI_NUM")))
              SW1->(MSUNLOCK())
              SW1->(RECLOCK('SW1',.F.))
			  
			  //** AAF 22/07/2014
			  SW1->W1_NR_CONC := SWT->WT_NR_CONC
			  SW1->W1_MOTCANC := ""
              SW1->W1_DT_CANC := CTOD("  /  /  ")
              //**
              
              SW1->W1_STATUS  := 'D' //“D - Aguardando Purchase Order” 
              SW1->(MSUNLOCK())
           ENDIF           
        ELSE
           EasyHelp("Cotação vencedora não existe no Easy Import Control","Atenção")
           lret := .F.                               
        ENDIF 
        SWT->(DBSETORDER(1)) 
      ENDIF                         
   ENDIF
ENDIF

Return lret


*------------------------------*
Static Function MenuDef()       
*------------------------------*
Local aRotina :=  {  { "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","CQC410Man" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "CQC410Man" , 0 , 3},; //"Incluir"
                     { "Alterar",   "CQC410Man" , 0 , 4},; //"Alterar"
                     { "Excluir",   "CQC410Man" , 0 , 5,3} } //"Excluir"
                   

Return aRotina  


*----------------------------------*
Function CQC410Man(cAlias,nReg,nOpc)
*----------------------------------*

Return Nil

/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: 
* Data: 13/12/2011
* =====================================================*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.002")
	oEasyIntEAI:oMessage:SetMainAlias("SWT")
	oEasyIntEAI:SetModule("EIC",17)
 
	oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| EICQC410(.F.,oEasyMessage:GetOperation(),oEasyMessage:GetEAutoArray("SWT")) } )

    //*** RECEBIMENTO	
	// Recebimento
	oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "EICQCRECB") //RECEBIMENTO DA COTACAO VENCEDORA     (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "EICQCRESP1") //RESPOSTA SOBRE O RECEBIMENTO        (<-Response)

    //*** ENVIO	
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "EICQCSEND") //ENVIO DA COTACAO AO ERP
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "EICQCRESP2")	//Rebimento de retorno da   
	                                               
	
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()
    

*------------------------------------------------*
Function EICQCRECB(oMessage) 
*------------------------------------------------* 
Local oBusinessCont  := oMessage:GetMsgContent()
Local oCotacao
Local oParams        := ERec():New()
Local nI,nJ,nX
Local oBatch     := EBatch():New()
Local oExecAuto

oParams:SetField("nOpc",4)//Alteracao

oItens:=oBusinessCont:_ListOfQuotationItem:_QUOTATIONITEM

If ValType(oItens) <> "A"
   aItens:= {oItens}
Else
   aItens := oItens
EndIf
      
For nI:=1 to len(aItens)    
   
   IF VALTYPE(aItens[nI]:_LISTOFQUOTATIONPROPOSAL:_QUOTATIONPROPOSAL) <> "A"
      aProposal := {aItens[nI]:_LISTOFQUOTATIONPROPOSAL:_QUOTATIONPROPOSAL}
   ELSE 
      aProposal := aItens[nI]:_LISTOFQUOTATIONPROPOSAL:_QUOTATIONPROPOSAL
   ENDIF
   
   //pegando cada codigo da cotacao vencedora
   For nJ:=1 to len(aProposal)
      cCod:=aProposal[nJ]:_Code:Text
      
      oCotacao := ERec():New()
      oCotacao:SetField("WT_NUMERP" ,cCod)//CODIGO DO ERP
      
      //** AAF 24/07/2014 - Necessário fornecedor e item para que o código ERP seja único.
      oCotacao:SetField("WT_FORN" ,aProposal[nJ]:_CustomerVendorCode:Text)
      oCotacao:SetField("WT_COD_I" , aItens[nI]:_ItemCode:Text)
      //**
      oCotacao:SetField("WT_FORLOJ" , ".")//NCF - 15/04/2016 - Precisa informar todos os campos da chave de pesquisa
      
      oExecAuto  := EExecAuto():New()
      oExecAuto:SetField("SWT",oCotacao)
      oExecAuto:SetField("PARAMS"  ,oParams)
      
      oBatch:AddRec(oExecAuto) 
   Next
Next

Return oBatch

*-------------------------------------------------*
Function EICQCRESP1(oMessage) 
*-------------------------------------------------*
Local oRespond 
       
    If !oMessage:HasErrors()
        oRespond  := ENode():New() 
        oRespond:SetField('ListOfInternalId',"")
    Else
        oRespond := oMessage:GetContentList("RESPONSE")
    EndIf

Return oRespond

/* ====================================================*
* Função:     EICQCSEND
* Parametros: (Nenhum)
* Objetivo: GERAR XML PARA INCLUSAO, EXLCUSAO E ALTERACAO   
*             
* Obs:        
* Autor:      
* Data:       
*/
* ------------------------------------------------*
Function EICQCSEND
* ------------------------------------------------*
Local oXml      := EXml():New()
Local oBusiness := ENode():New()
Local oEvent    := ENode():New()
Local oRec      := ENode():New()
Local oIdent    := ENode():New()
Local aOrd      := SaveOrd({"SWS","SWT"}) 
Local nJ,nI
Local oModelSWS := oModel:GetModel( 'SWSDETAIL' )// oModelSWS:Length()
Local oModelSWT := oModel:GetModel( 'SWTDETAIL' )//

//chave
oKeyNode   := ENode():New()
oKeyNode:SetField(EAtt():New("name","Competition"))
oKeyNode:SetField(ETag():New("" ,M->WR_NR_CONC))
oIdent:SetField(ETag():New("key",oKeyNode))
   
//evento
oEvent:SetField("Entity", "EICQC410")
If nOpc == 3  
    oEvent:SetField("Event" ,"upsert" )
ELSEIF  nOpc == 4

   IF nEAIEvent == 5  //ENVIO DE EXCLUSAO DA ALTERACAO
      oEvent:SetField("Event" ,"delete" )
   ELSE
      oEvent:SetField("Event" ,"upsert" )
   ENDIF
Else
    oEvent:SetField("Event" ,"delete" )
EndIf
oEvent:SetField("Identification",oIdent)

//capa
oBusiness:SetField("CompanyId"        ,SM0->M0_CODIGO)
oBusiness:SetField("BranchId"         ,FWFilial())
oBusiness:SetField("CompanyInternalId",SM0->M0_CODIGO)
oBusiness:SetField("ValidityStartDate",EasyTimeStamp(M->WR_INIVAL,.t.,.F.))
oBusiness:SetField("ValidityEndDate"  ,EasyTimeStamp(M->WR_FIMVAL,.t.,.F.))


oListItem:= ENode():New()
For nI:=1 to LEN(ASWT)
   oModelSWS:GoLine(ASWT[nI][1])//possui apenas itens que serao usados
   
   oItem         := ENode():New()   
   oItem:SetField("ExternalItemCode"  ,oModelSWS:GetValue( 'WS_COD_I'))
   oItem:SetField("ItemCode"          ,oModelSWS:GetValue( 'WS_COD_I'))
   oItem:SetField("RequestInternalId" ,oModelSWS:GetValue( 'WS_SI_NUM'))
   oItem:SetField("RequestCode"       ,oModelSWS:GetValue( 'WS_SI_NUM'))
   
   
   oListQuota:= ENode():New() //<listofquotation>
   cItem     := oModelSWS:GetValue('WS_COD_I')
   cSI       := oModelSWS:GetValue('WS_SI_NUM')
   cCC       := oModelSWS:GetValue('WS__CC')
   
   // oModelSWT:SetFilterDefault()

   For nJ:=1 to LEN(ASWT[nI][2])
      
      oModelSWT:GoLine(ASWT[nI][2][nJ])         
      IF cItem+cSI+cCC <>  oModelSWT:GetValue('WT_COD_I')+oModelSWT:GetValue('WT_SI_NUM')+oModelSWS:GetValue('WS__CC')
         LOOP
      ENDIF
      
      MontaSWT() 
   NEXT
   oItem:SetField("ListOfQuotationProposal",oListQuota)
   oListItem:SetField("QuotationItem",oItem)
NExt

oBusiness:SetField("ListOfQuotationItem",oListItem)


oRec:SetField("BusinessEvent",oEvent)
oRec:SetField("BusinessContent",oBusiness) 
oXml:AddRec(oRec)
   
RestOrd(aOrd,.t.)

Return oXml

*------------------------------------------------*
Function EICQCRESP2(oEasyMessage) 
*------------------------------------------------* 
Local oBusinessCont  := oEasyMessage:GetRetContent()       
Local oBusinesEvent  := oEasyMessage:GetEvtContent()
Local cEvento        := Upper(EasyGetXMLinfo(,oBusinesEvent,"_Event"))
Local nI,nj, nK
LOCAL oModel    := FWModelActive()
Local oModelSWS := oModel:GetModel('SWSDETAIL')
Local oModelSWT := oModel:GetModel('SWTDETAIL')

oList:=oBusinessCont:_LISTOFINTERNALID:_INTERNALID//AWF - 14/07/2014

If ValType(oList) <> "A"
   aArray := {oList}
Else
   aArray := oList
EndIf

For nK:=1  to len(aArray)

   oInternal:= aArray[nK]//:_INTERNALID//AWF - 14/07/2014

   cId := EasyGetXMLinfo(,oInternal,"_Origin")

   SWT->(DBSETORDER(4))

   IF ALLTRIM(cEvento) == 'UPSERT'

      cRetorno := EasyGetXMLinfo(,oInternal,"_destination")

      //RETIRANDO OS DOIS PRIMEIROS ||
      For nJ:=1 to 2
          IF (nPos:=AT("|",cRetorno)) <> 0
             cRetorno:= SUBSTR(cRetorno,nPos+1,len(cRetorno))
         ENDIF
      Next

      //PEGANDO O VALOR DO NUM ERP
      IF (nPos:=AT("|",cRetorno)) <> 0
         cCod:= SUBSTR(cRetorno,1,nPos-1)
      ENDIF

      //posicionar no item egravar num erp oModelSWT:SeekLine({{"WT_ID"  ,cId }})
      For nI:=1 to oModelSWS:Length()
	     oModelSWS:GoLine( nI )
		 
	     For nJ:=1 to oModelSWT:Length()
            oModelSWT:GoLine( nJ )
            IF ALLTRIM(cId) ==  ALLTRIM(oModelSWT:GETValue("WT_ID"))
               //oModelSWT:SetValue("WT_NUMERP",cCod)
               oModelSWT:LoadValue("WT_NUMERP",cCod)
            ENDIF
         next nJ
	  Next nI

   ELSE //delet
      IF SWT->(DBSEEK(xFilial("SWT")+AVKEY(cId,'WT_ID')))
  
         SWT->(MSUNLOCK())
         SWT->(RECLOCK('SWT',.F.))
         SWT->WT_NUMERP := ""
         SWT->(DBDELETE())
         SWT->(MSUNLOCK())   
         SWT->(DBCOMMIT())
      ENDIF
      //posicionar no item e grava o num erp oModelSWT:SeekLine({{"WT_ID"  ,cId }})   
      IF  nOpc # 5 //AWF - 11/07/2014 - Se diferentede EXCLUSAO pq senao dá erro de edicao.
         For nI:=1 to oModelSWS:Length()
	        oModelSWS:GoLine( nI )
		    
			For nJ:=1 to oModelSWT:Length()
               oModelSWT:GoLine( nJ )                    
               IF ALLTRIM(cId) ==  ALLTRIM(oModelSWT:GETValue("WT_ID"))
                  oModelSWT:LoadValue("WT_NUMERP",' ')  
               ENDIF
            next nJ
		 Next nI
      ENDIF

   ENDIF
Next 


RETURN .T.

oEasyMessage:AddInList("RECEIVE", {"Sucesso" , "Registro Gravado no Destino" , Nil})



Return oEasyMessage



*----------------------*
STATIC FUNCTION MontaSWT()
*----------------------*

oQuota     := ENode():New()//<quotationproposal> 
oQuota:SetField("ProposalInternalId"  ,oModelSWT:GetValue('WT_ID'))
oQuota:SetField("RegistrationDate"    ,EasyTimeStamp(M->WR_DT_CONC,.t.,.F.))
//oQuota:SetField("ExternalCode"        ,oModelSWT:GetValue('WT_ID'))
oQuota:SetField("CustomerVendorCode"  ,oModelSWT:GetValue('WT_FORN'))
oQuota:SetField("Code"                ,oModelSWT:GetValue('WT_NUMERP'))
oQuota:SetField("Winner"              ,IF('3' $ ALLTRIM(oModelSWT:GetValue('WT_STATUS')),'1','0'))//“3-Aprovada” MANDA 1  SE NAO MANDA 0

SYF->(DBSEEK(xFilial('SYF')+oModelSWT:GetValue('WT_MOEDA')))
oQuota:SetField("CurrencyCode"    ,SYF->YF_CODVERP) 

SY6->(DBSEEK(xFIlial('SY6')+ oModelSWT:GetValue('WT_COD_PAG')+STR(oModelSWT:GetValue('WT_DIASPAG'),3,0)))
oQuota:SetField("PaymentTermCode"  ,SY6->Y6_CODERP)                               

IF AvRetInco(oModelSWT:GetValue('WT_INCOTER'),"CONTEM_FRETE")//SE CONTEM FRETE
   oQuota:SetField("FreightType"      ,'1') 
ELSE
   oQuota:SetField("FreightType"      ,'2') 
ENDIF

SY1->(DBSEEK(xFilial('SY1')+M->WR_COMPRA))
//AAF 06/08/2014 - Conforme alinhamento com TOTVS, conceito de comprador do Logix não permitirá integração.
//oQuota:SetField("UserCode"            ,SY1->Y1_CODERP)       
//oQuota:SetField("UserInternalId"   ,M->WR_COMPRA) 

cObs:=GetObs()
oQuota:SetField("Observation"        ,cObs)  

oQuota:SetField("UnitPrice"          ,oModelSWT:GetValue('WT_VL_UNIT'))  

    oListDeliveri:= ENode():New()//<ListDeliveries>
      
       oDeliverie    := ENode():New()   //<>Deliveries
       
       oDeliverie:SetField("DeliveryRequestItem" ,1) 
       oDeliverie:SetField("Quantity"              ,oModelSWT:GetValue('WT_QTDE'))  
       oDeliverie:SetField("DeliveryDate"         ,EasyTimeStamp(oModelSWT:GetValue('WT_DT_FORN'),.t.,.F.))  
       
       oListDeliveri:SetField("Deliveries", oDeliverie) //</deliveries>
    
    oQuota:SetField("ListOfDeliveries", oListDeliveri)//</listdeliveries> 
    
oListQuota:SetField("QuotationProposal", oQuota)//</quotationproposal>
   
Return 
               
                   
*---------------------------*
Static Function GetObs()
*---------------------------*
Local cObs:=""

cObs:="Incoterm:"    +oModelSWT:GetValue('WT_INCOTER')  +"|"+;
      "Vl.Unit.:"    +oModelSWT:GetValue('WT_MOEDA')          +SPACE(1)+TRANSFORM(oModelSWT:GetValue('WT_VL_UNIT'),AVSX3("WT_VL_UNIT",6))+"|"+;
      "Desp.Int:"    +oModelSWT:GetValue('WT_MOEDA')          +SPACE(1)+TRANSFORM(oModelSWT:GetValue('WT_DESPIN') ,AVSX3("WT_DESPIN ",6))+"|"+;
      "Frete:"       +oModelSWT:GetValue('WT_MOE_FRE')        +SPACE(1)+TRANSFORM(oModelSWT:GetValue('WT_FRE_KG') ,AVSX3("WT_FRE_KG" ,6))+"|"+;
      "Seguro:"      +oModelSWT:GetValue('WT_MOEDA')          +SPACE(1)+TRANSFORM(oModelSWT:GetValue('WT_SEGURO') ,AVSX3("WT_SEGURO" ,6))+"|"+;
      "Desp.Nac.:"   +EasyGParam("MV_SIMB1",,"R$")+SPACE(1)+TRANSFORM(oModelSWT:GetValue('WT_DESPRS') ,AVSX3("WT_DESPRS" ,6))+"|"+;
      "Custo Tot.Un:"+EasyGParam("MV_SIMB1",,"R$")+SPACE(1)+TRANSFORM(oModelSWT:GetValue('WT_TOTURS') ,AVSX3("WT_TOTURS" ,6))+"|"+;
      "Custo Tot.:"  +EasyGParam("MV_SIMB1",,"R$")+SPACE(1)+TRANSFORM(oModelSWT:GetValue('WT_TOTRS')  ,AVSX3("WT_TOTRS"  ,6))
 
     
IF SYE->(DBSEEK(xFilial('SYE')+DTOS(SWR->WR_DT_CONC)+oModelSWT:GetValue('WT_MOEDA')  ))
   cObs+="|Tx.:"+oModelSWT:GetValue('WT_MOEDA')   +SPACE(1)+ TRANSFORM(SYE->YE_VLCON_C,AVSX3("YE_VLCON_C",6))
ENDIF                                                                                            

IF oModelSWT:GetValue('WT_MOE_FRE') <> oModelSWT:GetValue('WT_MOEDA') .AND. SYE->(DBSEEK(xFilial('SYE')+DTOS(SWR->WR_DT_CONC)+oModelSWT:GetValue('WT_MOE_FRE') ) )
   cObs+="|Tx.:"+oModelSWT:GetValue('WT_MOE_FRE') +SPACE(1)+ TRANSFORM(SYE->YE_VLCON_C,AVSX3("YE_VLCON_C",6)) 
ENDIF

Return cObs


*---------------------------*
 Function RejeitaSWT(cSI,cCod_I,cReg,cNumErp,cStatus,cCc)
*---------------------------*
LOCAL cUnReq   := "99999"
Local aRecSWT  := SWT->({IndexOrd(),RecNo()})
Local aRecSW1  := SW1->({IndexOrd(),RecNo()})
Local cAtu
DEFAULT cNumERP:=''
DEFAULT cStatus:=''
DEFAULT cCC    :=''

IF EMPTY(cStatus)
   RETURN .F.
ENDIF

 //REJEITANDO AS DEMAIS COTAÇÕES SWT
 cQuery := "Select R_E_C_N_O_ REG From " + RetSqlName("SWT") + " where D_E_L_E_T_ <> '*' AND"
 cQuery += " WT_FILIAL ='"+XFILIAL('SWT')+"' AND "
 cQuery += " WT_SI_NUM ='"+cSI           +"' AND "
 cQuery += " WT_COD_I  ='"+cCod_I        +"' AND "


 IF !EMPTY(cCC)
    cQuery += " WT__CC    ='"+cCC          +"'"
 ENDIF

 IF !EMPTY(cReg)
    cQuery += " WT_REG    ='"+cReg          +"'"
 ENDIF

 IF !EMPTY(cNumERP)
    cQuery += " AND WT_NUMERP <>'"+cNumErp+"'"  //ATUALIZAR TODOS MENOS O QUE FOI APROVADO
 ENDIF        
         
cQuery := ChangeQuery(cQuery)
IF SELECT('SWT_TMP') <> 0 
   SWT_TMP->(DBCLOSEAREA()) 
ENDIF   

DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "SWT_TMP", .T., .T.) 
                             
IF !USED()
   RETURN .F.
ENDIF
                                                                  
SWT_TMP->(DBGOTOP())
DO WHILE SWT_TMP->(!EOF())         
   SWT->(DBGOTO(SWT_TMP->REG))
   
   If SWT->WT_STATUS == "3" //Rejeitando o aprovado, voltar o status na SI
      IF SW1->(DBSEEK(xFilial("SW1")+AvKey(cUnReq,"W1_CC")+AvKey(SWT->WT_SI_NUM,"W1_SI_NUM")))
         SW1->(RECLOCK('SW1',.F.))
  	     SW1->W1_NR_CONC := ""
         SW1->W1_STATUS  := 'B' //EM PROCESSO DE COTAÇÃO
         SW1->(MSUNLOCK())
      ENDIF	  
   EndIf
   
   SWT->(RECLOCK('SWT',.F.))
   cAtu := cStatus
   If cStatus == "2"
      IF Empty(SWT->WT_VL_UNIT) .OR. Empty(SWT->WT_TOTRS) .OR.;
      Empty(SWT->WT_COD_PAG) .OR. Empty(SWT->WT_DT_FORN) .OR.;
      Empty(SWT->WT_MOEDA) .OR. Empty(SWT->WT_INCOTER)
         cAtu:='1'//AGUARDANDO COTACAO
      ELSE
         cAtu:='2'//AGUARDANDO AVALIACAO
      ENDIF
   EndIf
   
   SWT->WT_STATUS := cAtu
   SWT->(MSUNLOCK())
   
   SWT_TMP->(DBSKIP())
ENDDO 
SWT_TMP->(DBCLOSEAREA()) 
DBSELECTAREA("SWT")
SWT->(dbSetOrder(aRecSWT[1]),dbGoTo(aRecSWT[2]))
SW1->(dbSetOrder(aRecSW1[1]),dbGoTo(aRecSW1[2]))

Return .T.

/*
FUNCAO  : MontaID()
AUTOR   : IGOR CHIBA
DATA    : 03/06/14
OBJETIVO: GERAR UM SEQUENCIAL + CONCORRENCIA  PARA CADA COTACAO, O WR_ID SEMPRE IRA ARMAZERNAR O ULTIMO UTILIZADO DO SEQUENCIA
*/
*---------------------------*
Static Function MontaID()
*---------------------------*
Local cId :=''                                    
Local cSeq:=''
LOCAL oModel     := FWModelActive()
LOCAL oModelSWT  := oModel:GetModel('SWTDETAIL')

cSeqAtual:=oModelSWT:GetValue("WT_ID")

IF !EMPTY(cSeqAtual) //AWF - 05/08/2014

   cNRConcAtual:=oModel:GetModel('SWRMASTER'):GetValue("WR_NR_CONC")
   cSeq:= SUBSTR(cSeqAtual,LEN(cNRConcAtual)+2)//AWF - 05/08/2014 - Posicina apos o | e pega a seq atual 
   cId:=cNRConcAtual +'|' +cSeq //AWF - 05/08/2014 - Acerta o ID sem regerar nova sequencia

   Return cId       

ENDIF

cSeq   :=oModel:GetModel('SWRMASTER'):GetValue("WR_ID")     

IF EMPTY(cSeq)
   cSeq:= STRZERO(1,02)
ELSE
   cSeq:= STRZERO(VAL(cSeq)+1,02)
ENDIF
oModel:GetModel('SWRMASTER'):SetValue("WR_ID",cSeq)

cId:=oModel:GetModel('SWRMASTER'):GetValue("WR_NR_CONC") +'|' +cSeq 

Return cId               
