#INCLUDE "Ecoxfun.ch"
#include "Average.ch"

*------------------------------*
FUNCTION BuscaF_Fornec(cCodigo)
*------------------------------*
IF SA2->(DBSEEK(xFilial("SA2")+cCodigo))
   cDesc := SA2->A2_NREDUZ
ELSE
   cDesc := SPACE(20)
ENDIF
RETURN cDesc


*----------------------------------------------------------------------------
FUNCTION ECOBuscaTaxa(PInd, PData,lMostraMsg,cMemo,cTipoTx)
*----------------------------------------------------------------------------
LOCAL cFilialAtu:=xFilial("ECB")
Local lUltimo := EasyGParam("MV_ECOTAXA",,.F.)//Se .T. busca a ultima taxa do cadastro de taxa contabil, se .F. Retorna 1  

IF(lMostraMsg==NIL,lMostraMsg:=.T.,)
IF(cTipoTx==NIL,cTipoTx:='1',)
ECB->(DBSETORDER(2))
SX3->(DbSetOrder(2))
If cTipoTx='2'   // Caso o parametro para buscar a Tx.da exportacao esteja .T., verifica a existencia do campo
   If ! SX3->(dbSeek("ECB_TX_EXP"))            
      cTipoTx:='1'
   EndIF
Endif   
SX3->(DbSetOrder(1))

IF PInd=="US$" .AND. !ECB->(DBSEEK(cFilialAtu+"US$"))
   PInd:="USD"
ENDIF

If ! ECB->(DBSEEK(cFilialAtu+PInd+DTOS(PData)))
   
   ECB->(DBSEEK(cFilialAtu+PInd+DTOS(PData),.T.))      
    
   // TLM 28/03/2008 Acerto da rotina busca taxa, para buscar a última taxa do cadastro da tabela ECB
   
   IF ECB->(EOF()) //.OR. Pind <> ECB->ECB_MOEDA .OR. PData <> ECB->ECB_DATA 
      ECB->(DBSKIP(-1))
   ENDIF

   DO WHILE !ECB->(BOF()) .and. ECB->ECB_FILIAL==xFilial("ECB") .and. Pind == ECB->ECB_MOEDA .and. ;
   EMPTY(IF(cTipoTx="1",ECB->ECB_TX_CTB,ECB->ECB_TX_EXP))
      ECB->(DBSKIP(-1))
   ENDDO
   
   IF ECB->ECB_DATA > PData .OR. Pind <> ECB->ECB_MOEDA
      ECB->(DBSKIP(-1))
      IF Pind <> ECB->ECB_MOEDA
         ECB->(DBSEEK(xFilial("ECB")+Pind))
      ENDIF
   ENDIF  
ENDIF

IF If(cTipoTx='1', EMPTY(ECB->ECB_TX_CTB), EMPTY(ECB->ECB_TX_EXP))
   IF lMostraMsg
      E_MSG(STR0001 + If(cTipoTx='1', STR0007, STR0008) + PIND + STR0002 + DTOC(PDATA)+" ("+ProcName(1)+")",1) //"VALOR DE CONVERSAO ZERADO --> "###" Em "
   ElseIf cMemo#Nil
      // cMemo foi definido no ECOCR200 (Integracao)
      cMemo+=STR0001 + If(cTipoTx='1', STR0007, STR0008) + PIND + STR0002 + DTOC(PDATA)+"."+CRLF //"Valor de conversao zerado --> "###" em "
   ENDIF
ENDIF

MRetorno:=If(cTipoTx='1', ECB->ECB_TX_CTB, ECB->ECB_TX_EXP)

//ASK 04/03/2008 Busca a  última taxa do cadastro de taxas contábeis.
If lUltimo .And. MRetorno = 0.00000000  
   ECB->(DbGoTop())
   Do While !ECB->(BOF()) .and. ECB->ECB_FILIAL==xFilial("ECB") .and. Pind == ECB->ECB_MOEDA 
      If PData > ECB->ECB_DATA 
         ECB->(DBSKIP(-1))
         Exit
      Else                        
         ECB->(DbSkip())   
      EndIf   
   EndDo
EndIf

IF Pind <> ECB->ECB_MOEDA .OR. MRetorno = 0.00000000 
   MRetorno = 1
ENDIF

IF PData < AVCTOD("01/07/94")
   MRetorno = MRetorno / 2750
ENDIF

RETURN MRetorno


*------------------------------*
FUNCTION ECondPgto(cCodigo)
*------------------------------*
LOCAL cDesc
DO CASE
   CASE EMPTY(cCodigo)
        cDesc = SPACE(12)
   CASE cCodigo = "1"
        cDesc = STR0003 //"Vista     "
   CASE cCodigo = "2"
        cDesc = STR0004 //"Financiado"
   OTHERWISE
ENDCASE

RETURN cDesc

*------------------------------------*
FUNCTION BuscaOrigem(cCodigo,lCodigo)
*------------------------------------*
LOCAL cOrigem
IF(lCodigo==NIL,lCodigo:=.F.,)

IF EMPTY(cCodigo)
   cOrigem := SPACE(13)
ELSEIF cCodigo = "1"
   cOrigem := STR0005 //"Integracao   "
ELSE
   cOrigem := STR0006 //"Contabilidade"
ENDIF

RETURN If(lCodigo,cCodigo+'-','')+cOrigem

*--------------------------------*
FUNCTION TaxaDi_Normal()
*--------------------------------*

EC8->(DBSETORDER(2))
EC8->(DBSEEK(xFilial('EC8')+EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC))
EC2->(DBSEEK(xFilial('EC2')+EC8->EC8_HAWB+EC8->EC8_FORN+EC8->EC8_MOEDA+EC8->EC8_IDENTC))

IF EC2->EC2_TX_DI = 0
   RETURN ECOBuscaTaxa(EC5->EC5_MOE_FO,dDt_UltOc)
ELSE
   IF ! l201_Cont
      RETURN EC2->EC2_TX_DI
   ELSE
      RETURN ECOBuscaTaxa(EC5->EC5_MOE_FO,dDt_UltOc)
   ENDIF
ENDIF
