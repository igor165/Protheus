/*
Funcao      : EECAE113
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Funcões responsáveis pelo WorkFlow de LC
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 31/03/2011 10:39
Revisao     :
Obs.        :
*/
*------------------*
Function EECAE113() 
*------------------*
Return Nil
*----------------------------------*
Function EECWFLBVAR(oEasyWorkFlow)
*----------------------------------*
Local aOrd := SaveOrd("EEC"), i
Private aCposWF := {}  // GFP - 03/09/2013

cRet:= oEasyWorkFlow:RetChave()
EEC->(DbSetOrder(1))

If EEC->(DbSeek(cRet)) 
   If !Empty(EEC->EEC_LIBSIS)
      oEasyWorkFlow:AddVal("EMBNUM" , EEC->EEC_PREEMB )
      oEasyWorkFlow:AddVal("DTLIB"  , EEC->EEC_LIBSIS )
      oEasyWorkFlow:AddVal("DATA"   , dDataBase       )  

      IF(EasyEntryPoint("EECAE113"),ExecBlock("EECAE113",.F.,.F.,"CPOS_WF"),)   // GFP - 03/09/2013
   
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
Function EECWFLBENV(oEasyWorkFlow)
*-------------------------------*

RecLock("EEC",.F.)
EEC->EEC_ID_LB := oEasyWorkFlow:RetID()
MsUnlock()

Return Nil

*-------------------------------*
Function EECWFLBCOND()
*-------------------------------*
Local aChaves := {}

Begin Sequence

If !Empty(M->EEC_LIBSIS) .AND. M->EEC_LIBSIS <> EEC->EEC_LIBSIS
   aAdd(aChaves,xFilial("EEC")+M->EEC_PREEMB)   
EndIf
   
End Sequence

Return aChaves