#INCLUDE "PROTHEUS.CH"
#include "average.ch"
/*
Programa : EICLC510.PRW
Autor    : Igor Chiba (Average)
Data     : 23/06/14
Revisao  : 
Uso      : Adapter de lançamentos contabies 
*/
*--------------------------------------------------------------------
Function EICLC510(aRegs,nOpc)
*--------------------------------------------------------------------
LOCAL lRet     :=.T.
PRIVATE aECF   := ACLONE(aRegs)
PRIVATE nOpcao := nOpc
lret:=EasyEnvEAI("EICLC510",nOpc)  

Return lret


*------------------------------*
Static Function MenuDef()       
*------------------------------*
Local aRotina :=  {  { "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","LC510Man" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "LC510Man" , 0 , 3},; //"Incluir"
                     { "Alterar",   "LC510Man" , 0 , 4},; //"Alterar"
                     { "Excluir",   "LC510Man" , 0 , 5,3} } //"Excluir"
                   

Return aRotina  


*----------------------------------*
Function LC510Man(cAlias,nReg,nOpc)
*----------------------------------*

Return Nil

/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: 
* =====================================================*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("ECF")
	oEasyIntEAI:SetModule("EIC",17)
 
    //*** ENVIO	
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "EICLCSEND") //ENVIO DA COTACAO AO ERP
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "EICLCRESP")	//Rebimento de retorno da   
	                                               
	
	
	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult()
    


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
Function EICLCSEND()
* ------------------------------------------------*
Local oXml      := EXml():New()
Local oEvent    := ENode():New()
Local oRec      := ENode():New()
Local oIdent    := ENode():New()
Local aOrd      := SaveOrd({"ECF","EC6"}) 
Local nI
Local dDtLancto, dDtRetFunc
Private oBusiness := ENode():New()

ECF->(DBGOTO(aECF[1]))
//chave
oKeyNode   := ENode():New()
oKeyNode:SetField(EAtt():New("name","Branch"))
oKeyNode:SetField(ETag():New("" ,ECF->ECF_FILIAL))
oIdent:SetField(ETag():New("key",oKeyNode))

oKeyNode   := ENode():New()
oKeyNode:SetField(EAtt():New("name","Source"))
oKeyNode:SetField(ETag():New("" ,ECF->ECF_ORIGEM))
oIdent:SetField(ETag():New("key",oKeyNode))

oKeyNode   := ENode():New()
oKeyNode:SetField(EAtt():New("name","Batch"))
oKeyNode:SetField(ETag():New("" ,ECF->ECF_NR_CON))
oIdent:SetField(ETag():New("key",oKeyNode))

oKeyNode   := ENode():New()
oKeyNode:SetField(EAtt():New("name","Process"))
oKeyNode:SetField(ETag():New("" ,ECF->ECF_HAWB))
oIdent:SetField(ETag():New("key",oKeyNode))
//FIM CHAVE
   
//evento
oEvent:SetField("Entity", "EICLC510")
If nOpcao == 5  
    oEvent:SetField("Event" ,"delete" )
ELSE
   oEvent:SetField("Event" ,"upsert" )
ENDIF

oEvent:SetField("Identification",oIdent)

SW6->(DBSETORDER(1))
SW6->(DBSEEK(ECF->ECF_FILIAL+ECF->ECF_HAWB))//Tem que ser com o filial do ECF porque pode ser varias filiais

If nOpcao == 5
   dDtIni := RetDate(ECF->ECF_FILIAL,'IMPORT',ECF->ECF_HAWB,ECF->ECF_NR_CON,'MENOR')
   dDtFim := RetDate(ECF->ECF_FILIAL,'IMPORT',ECF->ECF_HAWB,ECF->ECF_NR_CON,'MAIOR') 
ELSE 
   dDtIni := RetDate(SW6->W6_FILIAL,'IMPORT',SW6->W6_HAWB,cLote,'MENOR')
   dDtFim := RetDate(SW6->W6_FILIAL,'IMPORT',SW6->W6_HAWB,cLote,'MAIOR') 
ENDIF               

//capa
oBusiness:SetField("CompanyId"        ,EICEmpFLogix(.T.))
oBusiness:SetField("BranchId"         ,EICFilFLogix(.T., IF(EMPTY(ECF->ECF_FILIAL),cFilAtual,ECF->ECF_FILIAL)))
oBusiness:SetField("OriginCode"       ,'EIC')
oBusiness:SetField("PeriodStartDate"  ,EasyTimeStamp(dDtIni,.t.,.t.))
oBusiness:SetField("PeriodEndDate"    ,EasyTimeStamp(dDtFim,.t.,.t.))
If nOpcao == 5 
   oBusiness:SetField("BatchNumber"   ,ECF->ECF_LOTERP)
// cTipo := '23'//"ECF_CONTAB" ,"1=Sim;2=Nao;3=Sol.Canc.;4=Cancelado"
//ELSE

   //oBusiness:SetField("BatchNumber"   ,'')
ENDIF

//itens
nCont:=0 
oListItem:= ENode():New()
FOR nI:=1 to len(aECF) 

   ECF->(DBGOTO(aECF[nI]))                   

   IF ECF->(DELETED())
      LOOP
   ENDIF
   
// IF !ECF->ECF_CONTAB $ ctipo //Esse tratamento foi para antes da chamada // "ECF_CONTAB" ,"1=Sim;2=Nao;3=Sol.Canc.;4=Cancelado"
//    LOOP
// ENDIF
   
   nCont++
   Private oItem := ENode():New()   
   IF nOpcao == 5  
      oItem:SetField("EntryNumber"          ,ECF->ECF_LANCAM)
      oItem:SetField("RelationshipNumber" ,ECF->ECF_RELACA)
   ELSE
      //ATUALIZANDO LANCAM
      IF EMPTY(ECF->ECF_LANCAM)
         ECF->(RECLOCK('ECF',.F.)) 
         ECF->ECF_LANCAM := ALLTRIM(STR(nCont))
         ECF->(MSUNLOCK())
      ENDIF
      oItem:SetField("EntryNumber"          ,ECF->ECF_LANCAM)
      //oItem:SetField("RelationshipNumber" ,'')
   ENDIF
   
   dDtLancto := If( !Empty( dDtRetFunc := LC500GtDtLc()), dDtRetfunc , ECF->ECF_DTCONT )
   oItem:SetField("MovementDate"         ,EasyTimeStamp(dDtLancto/*ECF->ECF_DTCONT*/,.t.,.t.))
   
   EC6->(DBSEEK(XFILIAL('EC6')+AVKEY("IMPORT",'EC6_TPMODU')+AVKEY(ECF->ECF_ID_CAM,'EC6_ID_CAM')))
   oItem:SetField("DebitAccountCode"     ,ECF->ECF_CTA_DB)
   oItem:SetField("CreditAccountCode"    ,ECF->ECF_CTA_CR)
   oItem:SetField("EntryValue"           ,Abs(ECF->ECF_VALOR) ) //NCF - 02/12/2016
   oItem:SetField("HistoryCode"          ,If("999" $ ECF->ECF_ID_CAM , "999" , EC6->EC6_COD_HI) )                                                                   //NCF - 03/03/2017 - Evento de estorno 999 precisa enviar histórico da descrição
   oItem:SetField("ComplementaryHistory" ,If("999" $ ECF->ECF_ID_CAM , Alltrim(ECF->ECF_DESCR)+" - PROC.: "+ECF->ECF_HAWB , EC6->EC6_COM_HI+" - "+ECF->ECF_HAWB) )  //                   já que o cadastro do evento não existirá na EC6
   oItem:SetField("CostCenterCode"       ,ECF->ECF_CC)
   
   If EasyEntryPoint("EICLC510")
      ExecBlock("EICLC510", .f., .f., "LANCAMENTO_CONTABIL")
   Endif
   
   oListItem:SetField("Entry",oItem)
NEXT
oBusiness:SetField("Entries",oListItem)


oRec:SetField("BusinessEvent",oEvent)
oRec:SetField("BusinessContent",oBusiness) 
oXml:AddRec(oRec)
   
RestOrd(aOrd,.t.)

Return oXml
                     

/*
Programa : EICLCRESP
Autor    : Igor Chiba (Average)
Data     : 23/06/14
Revisao  : 
Uso      : RESPOSTA DO ADAPTER
*/

*-------------------------------------------------*
Function EICLCRESP(oMessage) 
*-------------------------------------------------*
Local oXml           := EXml():New()
Local oBusinessCont  := oMessage:GetBsnContent()
Local oBusinessEvent := oMessage:GetEvtContent()      
Local oRetCont       := oMessage:GetRetContent()
Local cEvento        := Upper(EasyGetXMLinfo(,oBusinessEvent,"_Event"))
Local nI
Local cFilECF:="" 
Local cModulo:=AVKEY("IMPORT",'ECF_TPMODU')
Local cHAWB  := ""
Local cLote  := ""
Local aBusinessCont:= {}

//PEGAR NUMERO DO LOTE
If ValType(oBusinessEvent:_IDENTIFICATION:_KEY) <> "A"
   aKey := {oBusinessEvent:_IDENTIFICATION:_KEY}
Else
   aKey := oBusinessEvent:_IDENTIFICATION:_KEY
EndIf
aEval(aKey, {|x| If(Upper(Alltrim(x:_NAME:Text)) == "BRANCH" , cFilECF:= AVKEY(x:TEXT,'ECF_FILIAL'),)}) 
aEval(aKey, {|x| If(Upper(Alltrim(x:_NAME:Text)) == "PROCESS", cHAWB  := AVKEY(x:TEXT,'ECF_HAWB'  ),)}) 
aEval(aKey, {|x| If(Upper(Alltrim(x:_NAME:Text)) == "BATCH"  , cLote  := AVKEY(x:TEXT,'ECF_NR_CON'),)}) 

//PEGANDO NUMERO DO LANCAMENTO
oReturn:=oRetCont
IF VALTYPE(oReturn:_ENTRIES:_ENTRY) <> 'A'
   aEntry:={oReturn:_ENTRIES:_ENTRY}
ELSE 
   aEntry:=oReturn:_ENTRIES:_ENTRY
ENDIF         

/* WFS 17/10/2017
Será considerado o número de lançamento (ECF_LANCAM) enviado na integração,
evitando eventuais alterações de retorno do LOGIX, relacionado à esta tag */
If ValType(oBusinessCont:_ENTRIES:_ENTRY) <> "A"
   aBusinessCont:= {oBusinessCont:_ENTRIES:_ENTRY}
Else
   aBusinessCont:= oBusinessCont:_ENTRIES:_ENTRY
EndIf

If Len(aBusinessCont) <> Len(aEntry)
   oMessage:Error("Erro na estrutra do XMLs de retorno - ENTRIES")
   aEntry:= {}
EndIf

For nI:=1 to len(aEntry)
   //cLacan:= EasyGetXMLinfo('ECF_LANCAM',aEntry[nI], "_ENTRYNUMBER" )
   cLacan:= EasyGetXMLinfo("ECF_LANCAM", aBusinessCont[nI], "_ENTRYNUMBER")

   IF cEvento == 'UPSERT'               
      cRelacao:= EasyGetXMLinfo('ECF_RELACAM',aEntry[nI], "_RELATIONSHIPNUMBER" )
      cErp    := EasyGetXMLinfo('ECF_LOTERP',oReturn  , "_BATCHNUMBER" )
   ELSE//"delete"
      cRelacao := ''
      cErp     := ''
   ENDIF
   ECF->(DBSETORDER(12))//ECF_FILIAL+ECF_TPMODU+ECF_HAWB+ECF_NR_CON+ECF_LANCAM
   ECF->(DBSEEK(cFilECF+cModulo+cHAWB+cLote+cLacan))
   DO WHILE ECF->(!EOF()) .AND. ECF->ECF_FILIAL == cFilECF;
                          .AND. ECF->ECF_TPMODU == cModulo;
                          .AND. ECF->ECF_HAWB   == cHAWB;
                          .AND. ECF->ECF_NR_CON == cLote; 
                          .AND. ECF->ECF_LANCAM == cLacan
                       
      ECF->(MSUNLOCK())
      ECF->(RECLOCK('ECF',.F.)) 
      ECF->ECF_LOTERP := cERP
      ECF->ECF_RELACA := cRelacao
      ECF->(MSUNLOCK())
      ECF->(DBSKIP())
   ENDDO 
Next

If oMessage:HasErrors()     
   oXMl := oMessage:GetContentList("RESPONSE")
   VarInfo("oMessage", oMessage:GetStrErrors(,,.F.))
EndIf

Return oXml

                                                                                     
/*
Programa : RETDATE
Autor    : Igor Chiba (Average)
Data     : 23/06/14
Revisao  : 
Uso      : retornar a ultima data ou a primeira
*/
*----------------------------*
Static Function RetDate(cFil,cTpModu,cHawb,cLote,cTipo)
*----------------------------*       
LOCAL cQuery := ''         
LOCAL dRet   := DATE()   
LOCAL cFilOld:= cFilAnt
cFilAnt:=cFIL
       
IF cTipo == 'MENOR'
   cQuery += " SELECT MIN(ECF_DTCONT) DATA   FROM "+RETSQLNAME('ECF')+" ECF  WHERE " +RetSqlCond("ECF")
ELSE
   cQuery += " SELECT MAX(ECF_DTCONT) DATA   FROM "+RETSQLNAME('ECF')+" ECF  WHERE " +RetSqlCond("ECF")
ENDIF

cQuery += " AND ECF_TPMODU ='"+cTpModu+"' "
cQuery += " AND ECF_HAWB   ='"+cHAwb  +"' "
cQuery += " AND ECF_NR_CON ='"+cLote  +"' " 


IF SELECT('TEMP') <> 0 
   TEMP->(DBCLOSEAREA())
ENDIF                  

dbUseArea( .t., "TopConn", TCGenQry(,,cQuery),"TEMP", .F., .F. )
TCSetField("TEMP", "DATA", "D")
                                                    
TEMP->(DBGOTOP())
DO WHILE TEMP->(!EOF())
   dRet:=TEMP->DATA
   
   EXIT
ENDDO
IF EMPTY(dRet)
   dRet:= DATE()
ENDIF

cFilAnt := cFilOld

Return dRet
