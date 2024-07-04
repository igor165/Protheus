#INCLUDE "PROTHEUS.CH"
#include "average.ch"
/*
Programa : ESSPA411.PRW
Autor    : Igor Chiba (Average)
Data     : 13/06/14
Revisao  : 
Uso      : CANCELAMENTO DE AQUISICAO DE SERVICO
*/
*--------------------------------------------------------------------
Function ESSPA411(aCab,aItem,nOpc)
*--------------------------------------------------------------------
LOCAL lRet     :=.T.
LOCAL nI,nJ

//WFS
If !EasyGParam("MV_ESS_EAI",, .F.)
   EasyHelp("A integração com o Easy Siscoserv não está habilitada. Verifique o parâmetro MV_ESS_EAI.", "Atenção")
   Return .F.
EndIf

IF (ValType(aCab) == "U" .or. (len(aCab) == 0))
   EasyHelp("Dados não informados","Atenção")
   RETURN .F.
ELSE
   MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},aCab,aItem,,nOpc) 
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
/* ATENCAO O INTEG DEF DESTE ADAPTER É UTILIZADO O DO EICSI411
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("EJW")
	oEasyIntEAI:SetModule("ESS",85)
 
	oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| ESSPA411(oEasyMessage:GetEAutoArray("EJW"),;
	                                                            oEasyMessage:GetOperation()) } )

    //*** RECEBIMENTO	
	// Recebimento
	oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "ESS411RECB") //RECEBIMENTO DA COTACAO VENCEDORA     (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "ESS411RESP") //RESPOSTA SOBRE O RECEBIMENTO        (<-Response)

                                                  
	
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()
    
*/
*------------------------------------------------*
Function ESS411RECB(oMessage) 
*------------------------------------------------* 
Local oBusinessCont  := oMessage:GetMsgContent()      
//Local oBusinesEvent  := oMessage:GetEvtContent()
Local oReg           := ERec():New()
Local oParams        := ERec():New()
Local oItsAquis      := ETab():New()
//Local cEvento        := Upper(EasyGetXMLinfo(,oBusinesEvent,"_Event"))
Local nI
Local oBatch         := EBatch():New()
Local oExecAuto      := EExecAuto():New()
Local oInformation   := oMessage:GetMsgInfo()


oParams:SetField("cMainAlias","EJW")
oParams:SetField("bFunction", {|oEasyMessage| ESSPA411(oEasyMessage:GetEAutoArray("EJW"),; 
                                                       oEasyMessage:GetEAutoArray("EJX"),;
                                                       oEasyMessage:GetOperation()) })
                                          
//campos que serao testados para verificar procedencia 
cErp := oInformation:_PRODUCT:_NAME:TEXT

//capa                                                  
oReg:SetField("EJW_ORIGEM" ,cErp)

//capa                                                  
//cOrderId := EasyGetXMLinfo('EJW_PROCES', oBusinessCont, "_RequestInternalId") //comentado por WFS em 26/08/2014  
cOrderId := EasyGetXMLinfo('EJW_PROCES', oBusinessCont, "_Code")
oReg:SetField("EJW_PROCES" ,cOrderId)

dDateCan := EasyGetXMLinfo(           , oBusinessCont, "_CancelDateTime")//EJW_DTPROC
cReason  := EasyGetXMLinfo("EJW_COMPL", oBusinessCont, "_CancelReason")
oReg:SetField("EJW_COMPL" ,cReason+'||'+dDateCan)                                   
                         
oReg:SetField("EJW_TPPROC" , 'A')//TIPO PROCESSO
oReg:SetField("EJW_STTPED" ,'5')                                   
oParams:SetField("nOpc",10)//CANCELAMENTO

EJX->(DBSEEK(XFILIAL('EJX')+AVKEY('A','EJX_TPPROC')+AVKEY(cOrderId ,'EJX_PROCES')))

DO WHILE EJX->(!EOF()) .AND.   EJX->EJX_FILIAL == XFILIAL('EJX') ;
                       .AND.   EJX->EJX_TPPROC == AVKEY('A','EJX_TPPROC') ;
                       .AND.   EJX->EJX_PROCES == AVKEY(cOrderId ,'EJX_PROCES')
   oItAquisi  := ERec():New()              
   
   oItAquisi:SetField("EJX_PROCES" ,EJX->EJX_PROCES)
   oItAquisi:SetField("EJX_ITEM"   ,EJX->EJX_ITEM)
   oItAquisi:SetField("EJX_SEQPRC" ,EJX->EJX_SEQPRC)
   oItAquisi:SetField("EJX_TPPROC" ,EJX->EJX_TPPROC)
   oItsAquis:AddRec(oItAquisi)
   
   EJX->(DBSKIP())
ENDDO


oExecAuto:SetField("EJW",oReg)
oExecAuto:SetField("EJX",oItsAquis)
oExecAuto:SetField("PARAMS",oParams)

oBatch:AddRec(oExecAuto) 


Return oBatch


*-------------------------------------------------*
Function ESS411RESP(oMessage) 
*-------------------------------------------------*
Local oXml      := EXml():New()

If oMessage:HasErrors()     
   oXMl := oMessage:GetContentList("RESPONSE")
EndIf

Return oXml

