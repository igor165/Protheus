#include "TOPCONN.CH"
/*
Funcao      : EECAP107
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Funcões responsáveis pelo WorkFlow do Pedido de Exportacão
Autor       : Thiago Rinaldi Pinto - TRP
Data/Hora   : 03/03/2011 15:10
Revisao     :
Obs.        :
*/
*------------------*
Function EECAP107()                                  
*------------------*
Return Nil
*----------------------------------*
Function EECWFPEVAR(oEasyWorkFlow)
*----------------------------------*
Local aOrd := SaveOrd("EE7"), i
Private aCposWF := {}  // GFP - 03/09/2013

cRet:= oEasyWorkFlow:RetChave()
EE7->(DbSetOrder(1))

If EE7->(DbSeek(cRet)) 
   oEasyWorkFlow:AddVal("NUMPED", EE7->EE7_PEDIDO)
   oEasyWorkFlow:AddVal("DATA",   dDataBase)
   
   IF(EasyEntryPoint("EECAP107"),ExecBlock("EECAP107",.F.,.F.,"CPOS_WF"),)   // GFP - 03/09/2013
   
   If Len(aCposWF) > 0
      For i := 1 To Len(aCposWF)
         oEasyWorkFlow:AddVal(aCposWF[i][1]  , aCposWF[i][2] )
      Next i
   EndIf
EndIf

RestOrd(aOrd, .T.)
Return Nil

*-------------------------------*
Function EECWFPEENV(oEasyWorkFlow)
*-------------------------------*

RecLock("EE7",.F.)
EE7->EE7_ID_AP := oEasyWorkFlow:RetID()
EE7->EE7_DTSLCR := dDataBase //Muda data da solicitação de crédito para data atual (pois o email foi enviado)
MsUnlock()

Return Nil

*-------------------------------*
Function EECWFPERET(oProc)
*-------------------------------*
oWorkFlow := EasyWorkFlow():New("PEDIDO")

oWorkFlow:LoadChave()

oWorkFlow:LoadVars()

dbSelectArea("EE7")
EE7->(dbSetOrder(1))
   
EE7->(dbSeek(oWorkFlow:RetChave()))

RecLock("EE7",.F.)
   
EE7->EE7_DTAPCR := dDataBase
//Muda o status para crédito aprovado.
EE7->EE7_STATUS := "3"
EE7->EE7_STTDES := Tabela("YC",EE7->EE7_STATUS)
MsUnlock()

Return .T.  

*-------------------------------*
Function EECWFPECOND()
*-------------------------------*
Local aChaves := {}

Begin Sequence

If Empty(M->EE7_DTAPCR) .AND. !Empty(M->EE7_DTSLCR)
   aAdd(aChaves, xFilial("EE7")+M->EE7_PEDIDO)
EndIf
   
End Sequence

Return aChaves