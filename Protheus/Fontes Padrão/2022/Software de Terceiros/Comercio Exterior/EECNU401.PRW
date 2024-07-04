/*
Funcao      : EECNU401
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Funcões responsáveis pelo WorkFlow de Solic. Numerario
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 31/03/2011 11:46
Revisao     :
Obs.        :
*/
*------------------*
Function EECNU401() 
*------------------*
Return Nil
*----------------------------------*
Function EECWFNRVAR(oEasyWorkFlow)
*----------------------------------*
Local aOrd := SaveOrd("EEU"), i
Private aCposWF := {}  // GFP - 03/09/2013

cRet:= oEasyWorkFlow:RetChave()
EEU->(DbSetOrder(1))

If EEU->(DbSeek(cRet)) 
   oEasyWorkFlow:AddVal("EMBNUM"  , EEU->EEU_PREEMB  )
   oEasyWorkFlow:AddVal("DESPESA" , EEU->EEU_DESPES  )
   oEasyWorkFlow:AddVal("DATA"    , EEU->EEU_DT_EFE  )
   oEasyWorkFlow:AddVal("VALOR"   , EEU->EEU_VALOR   )
   oEasyWorkFlow:AddVal("USUARIO" , EEU->EEU_LIBERA  )
   oEasyWorkFlow:AddVal("DTATUAL" , dDataBase        )
   
   IF(EasyEntryPoint("EECNU401"),ExecBlock("EECNU401",.F.,.F.,"CPOS_WF"),)   // GFP - 03/09/2013
   
   If Len(aCposWF) > 0
      For i := 1 To Len(aCposWF)
         oEasyWorkFlow:AddVal(aCposWF[i][1]  , aCposWF[i][2] )
      Next i
   EndIf
EndIf                                               

RestOrd(aOrd, .T.)
Return Nil

*-------------------------------*
Function EECWFNRENV(oEasyWorkFlow)
*-------------------------------*

RecLock("EEU",.F.)
EEU->EEU_ID := oEasyWorkFlow:RetID()
MsUnlock()

Return Nil