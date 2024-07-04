/*
Funcao      : EICDI506
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Funcões responsáveis pelo WorkFlow do Embarque
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 25/03/2011 14:50
Revisao     :
Obs.        :
*/
*------------------*
Function EICDI506() 
*------------------*
Return Nil
*----------------------------------*
Function EICWFEBVAR(oEasyWorkFlow)
*----------------------------------*
Local aOrd := SaveOrd("SW6"), i
Private aCposWF := {}  // GFP - 03/09/2013

cRet:= oEasyWorkFlow:RetChave()
SW6->(DbSetOrder(1))

If SW6->(DbSeek(cRet))
   oEasyWorkFlow:AddVal("EMBNUM", SW6->W6_HAWB    )
   oEasyWorkFlow:AddVal("DTEMB" , SW6->W6_DT_HAWB )
   oEasyWorkFlow:AddVal("DATA"  , dDataBase       )
   
   IF(EasyEntryPoint("EICDI506"),ExecBlock("EICDI506",.F.,.F.,"CPOS_WF"),)   // GFP - 03/09/2013
   
   If Len(aCposWF) > 0
      For i := 1 To Len(aCposWF)
         oEasyWorkFlow:AddVal(aCposWF[i][1]  , aCposWF[i][2] )
      Next i
   EndIf
   
EndIf

RestOrd(aOrd, .T.)
Return Nil

*-------------------------------*
Function EICWFEBENV(oEasyWorkFlow)
*-------------------------------*

RecLock("SW6",.F.)
SW6->W6_ID_EMB := oEasyWorkFlow:RetID()
MsUnlock()

Return Nil 

*-------------------------------*
Function EICWFEBCOND()
*-------------------------------*
Local aChaves := {}

Begin Sequence

SW6->(DbSetOrder(1))
If !SW6->(DbSeek(xFilial("SW6")+M->W6_HAWB))
   aAdd(aChaves,xFilial("SW6")+M->W6_HAWB)
   BREAK
EndIf
   
End Sequence

Return aChaves