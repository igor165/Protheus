/*
Funcao      : EECAE111
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Funcões responsáveis pelo WorkFlow de LC
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 30/03/2011 15:39
Revisao     :
Obs.        :
*/
*------------------*
Function EECAE111() 
*------------------*
Return Nil
*----------------------------------*
Function EECWFLCVAR(oEasyWorkFlow)
*----------------------------------*
Local aOrd := SaveOrd("EEC"), i
Private aCposWF := {}  // GFP - 03/09/2013

cRet:= oEasyWorkFlow:RetChave()
EEC->(DbSetOrder(1))

If EEC->(DbSeek(cRet)) 
   If !Empty(EEC->EEC_LC_NUM)
      oEasyWorkFlow:AddVal("EMBNUM" , EEC->EEC_PREEMB )
      oEasyWorkFlow:AddVal("DATA"   , EEC->EEC_DTPROC )
      oEasyWorkFlow:AddVal("LCNUM"  , EEC->EEC_LC_NUM )
      oEasyWorkFlow:AddVal("DTATUAL", dDataBase       )
      
      IF(EasyEntryPoint("EECAE111"),ExecBlock("EECAE111",.F.,.F.,"CPOS_WF"),)   // GFP - 03/09/2013
   
      If Len(aCposWF) > 0
         For i := 1 To Len(aCposWF)
            oEasyWorkFlow:AddVal(aCposWF[i][1]  , aCposWF[i][2] )
         Next i
      EndIf
   EndIf   
EndIf

RestOrd(aOrd, .T.)
Return Nil

*-------------------------------*
Function EECWFLCENV(oEasyWorkFlow)
*-------------------------------*

RecLock("EEC",.F.)
EEC->EEC_ID_LC := oEasyWorkFlow:RetID()
MsUnlock()

Return Nil

*-------------------------------*
Function EECWFLCCOND()
*-------------------------------*
Local aChaves := {}

Begin Sequence

If !Empty(M->EEC_LC_NUM)
   aAdd(aChaves,xFilial("EEC")+M->EEC_PREEMB)   
EndIf
   
End Sequence

Return aChaves