#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AVERAGE.CH"
#INCLUDE "EICSI411.ch" 
#INCLUDE "rwmake.ch" 

/*
Funcao      : EICSI411
Parametros  : 
Retorno     : 
Objetivos   : Criada a rotina para cancelamento das SI (Logix)
Autor       : Jacomo Abenathar Fernandes Lisa	
Data/Hora   : 16/05/2014
Revisao     : 
Obs.        : 
*/


*------------------------*
Function EICSI411(aSW1,nOpc)
*------------------------*
LOCAL cSI,cMotivo,dData,nPos,lRet:= .T.
LOCAL cUnReq := "99999" // Unidade Requisitante Padrão
SW1->(DBSETORDER(1))
Default nOpc := 0


IF nOpc == 5
   EasyHelp(STR0002) //"A ação de exclusão não pode ser realizada para a solicitação de importação. Para anular o processo, envie uma ação de cancelamento."
   RETURN .F.
ENDIF
IF (ValType(aSW1) == "U" .or. (len(aSW1) == 0))
   EasyHelp(STR0003) //Solicitação de importação não informada"
   RETURN .F.
ENDIF


IF (nPos:= ascan(aSW1,{|x| AllTrim(x[1]) == "W1_SI_NUM"}))>0
   cSI := ALLTRIM(aSW1[nPos][2])
ENDIF

IF (nPos:= ascan(aSW1,{|x| AllTrim(x[1]) == "W1_MOTCANC"}))>0
   cMotivo := UPPER(ALLTRIM(aSW1[nPos][2]))
   IF (EMPTY(cMotivo))
      EasyHelp(STR0004) //"O motivo do cancelamento não foi informado."
      RETURN .F.
   ENDIF      
ENDIF

IF (nPos:= ascan(aSW1,{|x| AllTrim(x[1]) == "W1_DT_CANC"}))>0
   dData := aSW1[nPos][2]
ENDIF

IF !SW1->(DBSEEK(xFilial("SW1")+AvKey(cUnReq,"W1_CC")+AvKey(cSI,"W1_SI_NUM")))
   EasyHelp(STR0001) //"A solicitação de importação informada não foi encontrada."
   RETURN .F.
ELSEIF SW1->W1_STATUS # "F"//$ "A/B/C/E" 
   
   IF cMotivo == "MERCADO INTERNO"
      SW1->(RecLock("SW1", .F.))
      SW1->W1_STATUS  := "C"
      SW1->W1_MOTCANC := cMotivo
      SW1->W1_DT_CANC := dData  
      SW1->W1_SALDO_Q := 0
      SW1->W1_NR_CONC := "" //wfs 11/08/2014 
      SW1->(MSUNLOCK())
      //IGOR CHIBA 28/05/14 ALEM DE CANCELAR SI TEM QUE CANCELAR SUAS COTAÇÕES
      RejeitaSWT(SW1->W1_SI_NUM,SW1->W1_COD_I,ALLTRIM(STR(SW1->W1_REG)),'','4')//reprovando todas que foram canceladas
   ELSE
      SW1->(RecLock("SW1", .F.))
      SW1->W1_STATUS  := "E"
      SW1->W1_MOTCANC := cMotivo
      SW1->W1_DT_CANC := dData
      SW1->W1_SALDO_Q := 0 
      SW1->(MSUNLOCK())
   ENDIF
ELSE
   EasyHelp(STR0005 + GetW1Status()) //"A solicitação de importação não pode ser cancelada pois o processo encontra-se em fase subsequente. Status atual: " + GetW1Status())
   RETURN .F.
ENDIF


return .T.


/* ====================================================*
* Função: IntegDefK
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Auto: Jacomo Abenathar Fernandes Lisa - 15/05/2014
* =====================================================*/
*--------------------------------------------------------------------*
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
*--------------------------------------------------------------------*
Local oEasyIntEAI
Private aOrderAuto
   
    aOrderAuto := {{"SW1",1}}//Para mudar a ordem da validacao da chave

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("SW1")
	oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| EICSI411(oEasyMessage:GetEAutoArray("SW1") ,oEasyMessage:GetOperation())} )
    
	oEasyIntEAI:SetModule("EIC",17)
	// Recebimento
	oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "SI411RECB") //RECEBIMENTO DE BUSINESS MESSAGE     (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "SI411RESB") //RESPOSTA SOBRE O RECEBIMENTO        (<-Response)
	//
	oEasyIntEAI:Execute()

Return oEasyIntEAI:GetResult() 

*------------------------------------------------*
Function SI411RECB(oMessage) 
*------------------------------------------------* 
Local oBusinessCont     := oMessage:GetMsgContent()
//Local oBusinesEvent     := oMessage:GetEvtContent()
//Local cEvento           := Upper(EasyGetXMLinfo(,oBusinesEvent,"_Event"))
      
Local oBatch     := EBatch():New()
Local oSW1       := ERec():New()//Arrays com os Registros da capa da SI

Local oExecAuto  := EExecAuto():New()
local cUn_Req    := AvKey("99999","W1_CC")
local cSi_Num    := EasyGetXMLinfo("W1_SI_NUM" , oBusinessCont, "_Code")
//Local oInformation   := oMessage:GetMsgInfo()



//IGOR CHIBA PRE ADAPTER PARA CANCELAMENTO AQUISICAO 16/06/2014
cType := EasyGetXMLinfo(, oBusinessCont, "_Type")
IF cType == '001' //como o xml é o mesmo para PO e aquisicao estes campos decidem quando sera aquisicao
   RETURN ESS411RECB(oMessage)
ENDIF
       
   
oSW1:SetField("W1_SI_NUM"  , AvKey(cSi_Num,"W1_SI_NUM") )  //Codigo da SI (W1_SI_NUM)
oSW1:SetField("W1_CC"      , cUn_Req )   //Codigo da SI (W1_SI_NUM)
oSW1:SetField("W1_DT_CANC" , EasyGetXMLinfo("W1_DT_CANC", oBusinessCont, "_CancelDateTime"   ) )   //Codigo da SI (W1_SI_NUM)
oSW1:SetField("W1_MOTCANC" , EasyGetXMLinfo("W1_MOTCANC", oBusinessCont, "_CancelReason"     ) )  //Codigo da SI (W1_SI_NUM)
   
SW1->(DBSETORDER(1))      
IF SW1->(DBSEEK(xFilial("SW1")+cUn_Req+ AvKey(cSi_Num,"W1_SI_NUM")))  // GFP - 23/08/2013
   oSW1:SetField("W1_COD_I" ,SW1->W1_COD_I )   //Codigo da SI (W1_SI_NUM)
ELSE
   oSW1:SetField("W1_COD_I" , AvKey("","W1_COD_I"))   //Codigo da SI (W1_SI_NUM)
ENDIF 

oExecAuto:SetField("SW1",oSW1)//Registros da Capa
oParams := ERec():New()
oParams:SetField("nOpc",4)//Alteracao

oExecAuto:SetField("PARAMS"  ,oParams)

oBatch:AddRec(oExecAuto)

Return oBatch

*-------------------------------------------------*
Function SI411RESB(oMessage) 
*-------------------------------------------------*
Local oXml:= EXml():New()

    If oMessage:HasErrors()     
       oXMl := oMessage:GetContentList("RESPONSE")
    EndIf

Return oXml

/*
Função    : GetW1Status()
Objetivos : Rotina executada apenas quando for MSExecAuto e Integração com o Logix
Autor     : Jacomo Abenathar Fernandes Lisa
Data      : 27/05/2014
*/
*-----------------------------*
Static Function GetW1Status()
*-----------------------------*
LOCAL cRet := ""
IF SW1->W1_STATUS=='A'
   cRet := STR0006 //"Pendente"
ELSEIF SW1->W1_STATUS=='B'
   cRet := STR0007 //"Em processo de cotação" 
ELSEIF SW1->W1_STATUS=='C'
   cRet := STR0008 //"Cotado no mercado nacional"
ELSEIF SW1->W1_STATUS=='D'
   cRet := STR0009 //"Aguardando Purchase Order" 
ELSEIF SW1->W1_STATUS=='E'
   cRet := STR0010 //"Cancelado" 
ELSEIF SW1->W1_STATUS=='F'
   cRet := STR0011 //"Atendida - em fase de Purchase Order" 
ELSEIF SW1->W1_STATUS=='G'
   cRet := STR0012 //"Contrato" 
ENDIF

Return cRet
