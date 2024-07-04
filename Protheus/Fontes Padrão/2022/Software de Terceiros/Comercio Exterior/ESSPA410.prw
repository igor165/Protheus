#INCLUDE "PROTHEUS.CH"
#include "average.ch"
/*
Programa : ESSPA410.PRW
Autor    : Igor Chiba (Average)
Data     : 13/06/14
Revisao  : 
Uso      : RECEBIMENTO DA AQUISICAO DE SERVICO
*/
*--------------------------------------------------------------------
Function ESSPA410(aCab,aItens,nOpc)
*--------------------------------------------------------------------
LOCAL lRet     :=.T.

//WFS
If !EasyGParam("MV_ESS_EAI",, .F.)
   EasyHelp("A integração com o Easy Siscoserv não está habilitada. Verifique o parâmetro MV_ESS_EAI.", "Atenção")
   Return .F.
EndIf
   
IF (ValType(aCab) == "U" .or. (len(aCab) == 0))  .OR. (ValType(aItens) == "U" .or. (len(aItens) == 0))
   EasyHelp("Dados não informados","Atenção")
   RETURN .F.
ELSE
   
   IF nOpc == 0 
      EasyHelp("Operação não permitida.","Atenção")
      RETURN .F.
   ENDIF
   
   MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},aCab,aItens,,nOpc) 
ENDIF     
//EasyGetXMLinfo(, oBusinessCont, "_OrderPurpose") <> '1'/*1 – compra*/ .OR.  EasyGetXMLinfo(, oBusinessCont, "_ordertypecode") <> '004'//004 - Serviço

//

Return lret

/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: 
* Data: 13/12/2011
* =====================================================*/
/*AVISO O INTEG DEF NAO PRECISA ESTAR NESTE FONTE POIS É UTILIZADO O DO EICPO420

Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("EJW")
	oEasyIntEAI:SetModule("ESS",85)
 
	oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| ESSPA410(oEasyMessage:GetEAutoArray("EJW"),;
	                                                            oEasyMessage:GetEAutoArray("EJX"),;
	                                                            oEasyMessage:GetOperation()) } )

    //*** RECEBIMENTO	
	// Recebimento
	oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "ESSRECB") //RECEBIMENTO DA COTACAO VENCEDORA     (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "ESSRESP1") //RESPOSTA SOBRE O RECEBIMENTO        (<-Response)

                                                  
	
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()
*/    

*------------------------------------------------*
Function ESSRECB(oMessage) 
*------------------------------------------------* 
Local oBusinessCont  := oMessage:GetMsgContent()      
Local oBusinesEvent  := oMessage:GetEvtContent()
Local oInformation   := oMessage:GetMsgInfo()
Local oAquisi        := ERec():New()
Local oItsAquis      := ETab():New()
Local oParams        := ERec():New()
Local cEvento        := Upper(EasyGetXMLinfo(,oBusinesEvent,"_Event"))
Local nI
Local oBatch     := EBatch():New()
Local oExecAuto  := EExecAuto():New()

                                          

oParams:SetField("cMainAlias","EJW")
oParams:SetField("bFunction", {|oEasyMessage| ESSPA410(oEasyMessage:GetEAutoArray("EJW"),;
	                                                            oEasyMessage:GetEAutoArray("EJX"),;
	                                                            oEasyMessage:GetOperation()) })

cErp := oInformation:_PRODUCT:_NAME:TEXT
//oOTH:SetField("ERP" ,cERP)

//capa                                                  
oAquisi:SetField("EJW_ORIGEM" ,cErp)

cOrderId := EasyGetXMLinfo('EJW_PROCES', oBusinessCont, "_OrderId")   //EJW_PROCES/ EJX_PROCES
oAquisi:SetField("EJW_PROCES" ,cOrderId)

cCustome := EasyGetXMLinfo('EJW_EXPOR', oBusinessCont, "_CustomerInternalId")//EJW_EXPOR 
oAquisi:SetField("EJW_EXPORT" ,cCustome)                                    
oAquisi:SetField("EJW_LOJEXP" ,AVKEY('.','A2_LOJA'))//DEFAULT COMO PONTO
                                    
SE4->(DBSETORDER(1))
cPay     := EasyGetXMLinfo('EJW_CONDPG', oBusinessCont, "_PaymentTermCode")//EJW_CONDPG
IF SE4->(DBSEEK(XFILIAL('SE4')+AVKEY(cPay,'E4_CODIGO')))
   oAquisi:SetField("EJW_CONDPG" ,cPay )                   
ENDIF

dRegDate := EasyGetXMLinfo("EJW_DTPROC", oBusinessCont, "_RegisterDate")//EJW_DTPROC
oAquisi:SetField("EJW_DTPROC" ,dRegDate )
           
oAquisi:SetField("EJW_TPPROC" , 'A')//TIPO PROCESSO

 
dhini    := EasyGetXMLinfo("EJX_DTPRIN", oBusinessCont, "_dhinidelivery")//EJX_DTPRIN
//oAquisi:SetField("EJX_DTPRIN" ,dhini)//AWF-11/07/2014 - Foi la para os itens

dhfin    := EasyGetXMLinfo("EJX_DTPRF", oBusinessCont, "_dhfindelivery")//EJX_DTPRF
//oAquisi:SetField("EJX_DTPRF" ,dhfin )//AWF-11/07/2014 - Foi la para os itens

cCurre   := EasyGetXMLinfo("EJW_MOEDA", oBusinessCont, "_CurrencyId")//EJW_MOEDA
cCurre   := BuscaMoe(cCurre)
oAquisi:SetField("EJW_MOEDA" ,cCurre)    //YF_CODVERP


//itens
oItens:=oBusinessCont:_SalesOrderItens:_ITEM
If ValType(oItens) <> "A"
   aListItens:= {oItens}
Else
   aListItens := oItens
EndIf

nCont:=1
For nI:=1 to len(aListItens)    
   
   oItem  := aListItens[nI]
   
   //WFS 26/08/2014 - se não tiver a tag, não será considerado serviço.
   If IsCpoInXML(oItem, "_OTHER")
      oOthers:= oItem:_OTHER:_ADDFIELDS:_ADDFIELD
  
      IF EasyGetXMLinfo(, oOthers, "_Value")  <> 'S' //ITEM NAO É SERVICO 
         LOOP
      ENDIF
   Else
      Loop
   EndIf
   
   nCont++
   oItAquisi  := ERec():New()              
   IF UPPER(EasyGetXMLinfo(,oItem, "_EVENT")) == 'DELETE'
      oItAquisi:SetField("AUTDELETA" ,'S')
   ENDIF
   
   oItAquisi:SetField("EJX_PROCES" ,cOrderId)

   cItem := EasyGetXMLinfo("EJX_ITEM", oItem, "_ItemCode")//EJX_ITEM
   oItAquisi:SetField("EJX_ITEM" ,cItem)
                              

   oItAquisi:SetField("EJX_SEQPRC" ,STRZERO(nCont,4))
   
   cItemunit         := EasyGetXMLinfo("EJX_UM", oItem, "_itemunitofmeasure")//EJX_UM
   oItAquisi:SetField("EJX_UM" ,cItemunit)

   oItAquisi:SetField("EJX_DTPRIN",dhini)//AWF-11/07/2014
   oItAquisi:SetField("EJX_DTPRFI",dhfin)//AWF-11/07/2014

   cQuant            := EasyGetXMLinfo("EJX_QTDE" , oItem, "_Quantity") //EJX_QTDE
   IF  EMPTY(CQuant)
      oItAquisi:SetField("EJX_QTDE" ,1 )
   ELSE
      oItAquisi:SetField("EJX_QTDE" ,cQuant )
   ENDIF
   
   nTotPri           := EasyGetXMLinfo("EJX_VL_MOE", oItem, "_TotalPrice")//EJX_VL_MOE
   oItAquisi:SetField("EJX_VL_MOE" , nTotPri)

   nUnityP           := EasyGetXMLinfo("EJX_PRCUN", oItem, "_UnityPrice")//EJX_PRCUN
   oItAquisi:SetField("EJX_PRCUN" , nUnityP )                        
   
      
   oItAquisi:SetField("EJX_TPPROC" , 'A')//TIPO PROCESSO
   oItsAquis:AddRec(oItAquisi)
Next
    

cfunc    := EasyGetXMLinfo(, oBusinessCont, "_funcmsgorder")//9 - Inclusão 10 - Alteração

nOpc:=0
IF cFunc == '9' .AND. cEvento == 'UPSERT' 
   nOpc:=3
   oParams:SetField("nOpc",3)//INCLUSAO
ELSEIF cFunc ==  '10' .AND. cEvento == 'UPSERT'
   oParams:SetField("nOpc",4)//Alteracao
ELSEIF cFunc ==  '10' .AND. cEvento == 'DELETE'
   oParams:SetField("nOpc",5)//Excluir
ELSE 
   oParams:SetField("nOpc",0)//NENHUM PERMITIDO
ENDIF                                 



oExecAuto:SetField("EJW",oAquisi)
oExecAuto:SetField("EJX",oItsAquis) 
oExecAuto:SetField("PARAMS",oParams)

oBatch:AddRec(oExecAuto) 


Return oBatch

*-----------------------------*
STATIC FUNCTION BuscaMoe(cMoeda)//AWF - 10/07/2014
*-----------------------------*
SYF->(DBSETORDER(5))//YF_FILIAL+YF_CODVERP
IF SYF->(DBSEEK(xFilial()+cMoeda))//Se nao achar devolve a que veio
   cMoeda:= SYF->YF_MOEDA
ENDIF
SYF->(DBSETORDER(1))//YF_FILIAL+YF_CODVERP
Return cMoeda

*-------------------------------------------------*
Function ESSRESP1(oMessage) 
*-------------------------------------------------*
Local oXml      := EXml():New()

If oMessage:HasErrors()     
   oXMl := oMessage:GetContentList("RESPONSE")
EndIf

Return oXml

