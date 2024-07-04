/*
Funcao      : EICAP102
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Funcões responsáveis pelo WorkFlow de Cambio
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 25/04/2011 14:50
Revisao     :
Obs.        :
*/
*------------------*
Function EICAP102() 
*------------------*
Return Nil
*----------------------------------*
Function EICWFLQVAR(oEasyWorkFlow)
*----------------------------------*
Local aOrd := SaveOrd("SWB"), i
Private aCposWF := {}  // GFP - 03/09/2013

cRet:= oEasyWorkFlow:RetChave()
SWA->(DbSetOrder(1))
SWB->(DbSetOrder(1))

If SWB->(DbSeek(cRet))
   If SWA->(DbSeek(SWB->(WB_FILIAL+WB_HAWB))) 
      Do While SWB->(!Eof()) .AND. SWB->WB_FILIAL == xFilial("SWB") .AND. SWB->WB_HAWB == SWA->WA_HAWB
         If !Empty(SWB->WB_CA_DT)
            oEasyWorkFlow:AddVal("DTVENC"  , SWB->WB_DT_VEN  )
            oEasyWorkFlow:AddVal("INVOICE" , SWB->WB_INVOICE )
            oEasyWorkFlow:AddVal("DTLIQ"   , SWB->WB_CA_DT   )
            oEasyWorkFlow:AddVal("DATA"    , dDataBase       ) 
         EndIf 
         SWB->(DbSkip())
      EndDo
      
      IF(EasyEntryPoint("EICAP102"),ExecBlock("EICAP102",.F.,.F.,"CPOS_WF"),)   // GFP - 03/09/2013
   
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
Function EICWFLQENV(oEasyWorkFlow)
*-------------------------------*

RecLock("SWB",.F.)
SWB->WB_ID_LQ := oEasyWorkFlow:RetID()
MsUnlock()

Return Nil

*-------------------------------*
Function EICWFLQCOND()
*-------------------------------*
Local aChaves := {}

Begin Sequence


TRB->(DbGoTop())   
Do While TRB->(!Eof()) .AND. SWB->WB_HAWB == TRB->WB_HAWB
   If !Empty(TRB->WB_CA_DT)
      aAdd(aChaves,xFilial("SWB")+TRB->(WB_HAWB+WB_PO_DI))
      BREAK
   EndIf
   TRB->(DbSkip())
EndDo

End Sequence

Return aChaves